#include "serial/serial.h"
#include "common/port.h"
#include "common/inline.h"
#include "platform/bios.h"
#include "platform/pic.h"


#define FIFO_SIZE  16
#define BUF_SIZE  256


enum uart_model {
	UART_8250   = 0,
	UART_16450  = 1,
	UART_16550  = 2,
	UART_16550A = 3,
	UART_16750  = 4,
};


struct serial_buf {
	uint8_t data[BUF_SIZE];
	uint32_t begin, end, len;
};

struct serial_port {
	uint8_t model;
	bool has_fifo;
	
	uint16_t addr;
	
	bool active_tx;
	
	volatile struct serial_buf tx_buf, rx_buf;
} serial_ports[4];


static inline void serial_buf_adv(volatile uint32_t *ptr) {
	*ptr = (*ptr + 1) % BUF_SIZE;
}

static void serial_buf_push(volatile struct serial_buf *buf, uint8_t val) {
	uint32_t int_save = cli_save();
	
	buf->data[buf->end] = val;
	
	/* if the buffer overflows, overwrite the oldest characters */
	if (buf->len == BUF_SIZE) {
		serial_buf_adv(&buf->end);
		serial_buf_adv(&buf->begin);
	} else {
		serial_buf_adv(&buf->end);
		++buf->len;
	}
	
	int_restore(int_save);
}

static bool serial_buf_pop(volatile struct serial_buf *buf, uint8_t *val) {
	if (buf->len == 0) {
		return false;
	}
	
	uint32_t int_save = cli_save();
	
	*val = buf->data[buf->begin];
	
	serial_buf_adv(&buf->begin);
	--buf->len;
	
	int_restore(int_save);
	
	return true;
}

static void serial_unload_rx_fifo(struct serial_port *port) {
	uint32_t int_save = cli_save();
	
	uint8_t lsr;
	while ((lsr = inb(port->addr + LSR)) & LSR_RBR_AVAIL) {
		uint8_t val = inb(port->addr + RBR);
		serial_buf_push(&port->rx_buf, val);
	}
	
	int_restore(int_save);
}

static void serial_load_tx_fifo(struct serial_port *port) {
	uint32_t int_save = cli_save();
	
	/* spin until the tx reg/fifo is empty */
	while (!(inb(port->addr + LSR) & LSR_THR_EMPTY));
	
	uint8_t val;
	if (port->has_fifo) {
		/* load the entire FIFO, if possible */
		for (uint32_t i = FIFO_SIZE; i > 0; --i) {
			if (port->tx_buf.len == 0) {
				break;
			}
			
			serial_buf_pop(&port->tx_buf, &val);
			outb(port->addr + THR, val);
		}
	} else {
		serial_buf_pop(&port->tx_buf, &val);
		outb(port->addr + THR, val);
	}
	
	int_restore(int_save);
}

void serial_intr(void) {
	/* interrupts WILL be disabled, as this is only called from an int gate */
	
	for (uint8_t dev = 0; dev < 4; ++dev) {
		struct serial_port *port = serial_ports + dev;
		
		if (port->addr == NULL) {
			continue;
		}
		
		uint8_t iir = inb(port->addr + IIR) & IIR_STATUS;
		
		if (iir == IIR_MSR_CHG) {
			uint8_t msr = inb(port->addr + MSR);
			
			/* TODO */
		} else if (iir == IIR_LSR_CHG) {
			uint8_t lsr = inb(port->addr + LSR);
			
			/* TODO */
		} else if (iir == IIR_THR_EMPTY) {
			if (port->tx_buf.len != 0) {
				serial_load_tx_fifo(port);
			} else {
				port->active_tx = false;
			}
		} else if (iir == IIR_RBR_AVAIL || iir == IIR_CHR_TMOUT) {
			serial_unload_rx_fifo(port);
		} else {
			continue;
		}
		
		debug_write_fmt("serial: dev %xb iir %xb\n", dev, iir);
		
		debug_write_fmt("serial: dev %xb rx buf len %xd:\n",
			dev, port->rx_buf.len);
		for (uint32_t idx = port->rx_buf.begin, len = port->rx_buf.len;
			len != 0; serial_buf_adv(&idx), --len) {
			debug_write_fmt("%xb ", port->rx_buf.data[idx]);
		}
		debug_write_chr('\n');
		for (uint32_t idx = port->rx_buf.begin, len = port->rx_buf.len;
			len != 0; serial_buf_adv(&idx), --len) {
			debug_write_fmt("'%c' ", port->rx_buf.data[idx]);
		}
		debug_write_chr('\n');
	}
}

static void serial_detect_model(struct serial_port *port) {
	uint8_t fcr_save = inb(port->addr + FCR);
	outb(port->addr + FCR, FCR_ENABLE | FCR_64B_ENABLE);
	
	uint8_t iir = inb(port->addr + IIR);
	
	port->model = UART_8250;
	port->has_fifo = false;
	
	if (iir & IIR_FIFO_EXIST) {
		if (iir & IIR_FIFO_IS64B) {
			port->model = UART_16750;
			port->has_fifo = true;
		} else {
			if (iir & IIR_FIFO_WORKS) {
				port->model = UART_16550A;
				port->has_fifo = true;
			} else {
				port->model = UART_16550;
			}
		}
	} else {
		bool sr_works = true;
		
		outb(port->addr + SR, 0x55);
		if (inb(port->addr + SR) != 0x55) {
			sr_works = false;
		}
		
		outb(port->addr + SR, 0xaa);
		if (inb(port->addr + SR) != 0xaa) {
			sr_works = false;
		}
		
		if (sr_works) {
			port->model = UART_16450;
		}
	}
	
	outb(port->addr + FCR, fcr_save);
}

uint8_t serial_init(void) {
	uint8_t serial_mask = 0;
	
	for (uint32_t dev = 0; dev < 4; ++dev) {
		struct serial_port *port = serial_ports + dev;
		
		serial_mask >>= 1;
		
		if (*bios_data.com_port[dev] != 0x0000) {
			port->addr = *bios_data.com_port[dev];
			port->active_tx = false;
			
			serial_detect_model(port);
			
			serial_mask |= 0b1000;
		}
	}
	
	return serial_mask;
}

void serial_config(uint8_t dev, uint16_t divisor, uint8_t lcr) {
	struct serial_port *port = serial_ports + dev;
	if (dev >= 4 || port->addr == NULL) {
		return;
	}
	
	/* set the DLAB */
	uint8_t temp = inb(port->addr + LCR);
	outb(port->addr + LCR, temp | LCR_DLAB);
	
	/* load the baudrate divisor */
	outb(port->addr + DLL, divisor & 0xff);
	outb(port->addr + DLM, (divisor >> 8) & 0xff);
	
	/* unset the DLAB and load line control options */
	outb(port->addr + LCR, lcr & ~LCR_DLAB);
	
	/* interrupt upon: RX avail, TX empty, LSR change, MSR change */
	outb(port->addr + IER, IER_ALL);
	
	/* enable and clear FIFOs; trigger interrupt at the 14-byte level */
	outb(port->addr + FCR, FCR_ENABLE | FCR_CLR_RX | FCR_CLR_TX | FCR_TRIG_14B);
	
	/* configure MCR: RTS=0 (ready to receive), enable IRQs */
	outb(port->addr + MCR, MCR_RTS | MCR_AUX_OUT2);
}

void serial_send(uint8_t dev, uint8_t val) {
	struct serial_port *port = serial_ports + dev;
	if (dev >= 4 || port->addr == NULL) {
		return;
	}
	
	uint32_t int_save = cli_save();
	
	serial_buf_push(&port->tx_buf, val);
	
	/* prime the pump */
	if (!port->active_tx) {
		serial_load_tx_fifo(port);
		port->active_tx = true;
	}
	
	int_restore(int_save);
}

void serial_send_arr(uint8_t dev, uint32_t len, const uint8_t *arr) {
	while (len-- != 0) {
		serial_send(dev, *(arr++));
	}
}

void serial_send_str(uint8_t dev, const uint8_t *str) {
	while (*str != '\0') {
		serial_send(dev, *(str++));
	}
}

bool serial_avail(uint8_t dev) {
	struct serial_port *port = serial_ports + dev;
	if (dev >= 4 || port->addr == NULL) {
		return false;
	}
	
	serial_unload_rx_fifo(port);
	
	return (port->rx_buf.len != 0);
}

bool serial_recv(uint8_t dev, uint8_t *val) {
	struct serial_port *port = serial_ports + dev;
	if (dev >= 4 || port->addr == NULL) {
		return false;
	}
	
	serial_unload_rx_fifo(port);
	
	return serial_buf_pop(&port->rx_buf, val);
}

void serial_flush(uint8_t dev) {
	struct serial_port *port = serial_ports + dev;
	if (dev >= 4 || port->addr == NULL) {
		return;
	}
	
	/* TODO: synchronously flush the entire tx buffer */
}
