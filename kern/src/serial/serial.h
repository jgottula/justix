/* justix
 * (c) 2013 Justin Gottula
 * The source code of this project is distributed under the terms of the
 * simplified BSD license. See the LICENSE file for details. */


#ifndef JUSTIX_KERN_SERIAL_SERIAL
#define JUSTIX_KERN_SERIAL_SERIAL

#ifndef __ASSEMBLY__

#define SER_DIV_115200  1
#define SER_DIV_57600   2
#define SER_DIV_38400   3
#define SER_DIV_19200   6
#define SER_DIV_9600   12
#define SER_DIV_4800   24
#define SER_DIV_2400   48

#define SER_LCR_8N1 (LCR_WORD_8BIT | LCR_PAR_NONE)


enum uart_bit {
	IER_ALL        = 0b00001111,
	IER_RBR_AVAIL  = _BV(0),
	IER_THR_EMPTY  = _BV(1),
	IER_LSR_CHG    = _BV(2),
	IER_MSR_CHG    = _BV(3),
	
	IIR_INT_PEND   = _BV(0),
	IIR_STATUS     = 0b00001111, // reset by:
	IIR_MSR_CHG    = 0b00000000, // MSR read
	IIR_THR_EMPTY  = 0b00000010, // IIR read / THR write
	IIR_RBR_AVAIL  = 0b00000100, // RBR read
	IIR_LSR_CHG    = 0b00000110, // LSR read
	IIR_CHR_TMOUT  = 0b00001100, // RBR read
	IIR_FIFO_IS64B = _BV(5),
	IIR_FIFO_WORKS = _BV(6),
	IIR_FIFO_EXIST = _BV(7),
	
	FCR_ENABLE     = _BV(0),
	FCR_CLR_RX     = _BV(1),
	FCR_CLR_TX     = _BV(2),
	FCR_DMA_MODE   = _BV(3),
	FCR_64B_ENABLE = _BV(5),
	FCR_TRIG_LVL   = 0b11000000,
	FCR_TRIG_1B    = 0b00000000,
	FCR_TRIG_4B    = 0b01000000,
	FCR_TRIG_8B    = 0b10000000,
	FCR_TRIG_14B   = 0b11000000,
	
	LCR_WORD_LEN   = 0b00000011,
	LCR_WORD_5BIT  = 0b00000000,
	LCR_WORD_6BIT  = 0b00000001,
	LCR_WORD_7BIT  = 0b00000010,
	LCR_WORD_8BIT  = 0b00000011,
	LCR_STOP_BITS  = _BV(2),
	LCR_PARITY     = 0b00111000,
	LCR_PAR_NONE   = 0b00000000,
	LCR_PAR_ODD    = 0b00001000,
	LCR_PAR_EVEN   = 0b00011000,
	LCR_PAR_HIGH   = 0b00101000,
	LCR_PAR_LOW    = 0b00111000,
	LCR_BREAK      = _BV(6),
	LCR_DLAB       = _BV(7),
	
	MCR_DTR        = _BV(0),
	MCR_RTS        = _BV(1),
	MCR_AUX_OUT1   = _BV(2),
	MCR_AUX_OUT2   = _BV(3),
	MCR_LOOPBACK   = _BV(4),
	
	LSR_RBR_AVAIL  = _BV(0),
	LSR_ERR_OVER   = _BV(1),
	LSR_ERR_PAR    = _BV(2),
	LSR_ERR_FRAME  = _BV(3),
	LSR_BREAK      = _BV(4),
	LSR_THR_EMPTY  = _BV(5),
	LSR_TXF_EMPTY  = _BV(6),
	LSR_ERR_FIFO   = _BV(7),
	
	MSR_CTS_CHG    = _BV(0),
	MSR_DSR_CHG    = _BV(1),
	MSR_RI_TRAIL   = _BV(2),
	MSR_CD_CHG     = _BV(3),
	MSR_CTS        = _BV(4),
	MSR_DSR        = _BV(5),
	MSR_RING       = _BV(6),
	MSR_CARRIER    = _BV(7),
};

enum uart_reg {
	RBR = 0, // r
	THR = 0, //  w
	DLL = 0, // rw
	IER = 1, // rw
	DLM = 1, // rw
	IIR = 2, // r
	FCR = 2, //  w
	LCR = 3, // rw
	MCR = 4, // rw
	LSR = 5, // r
	MSR = 6, // r
	SR  = 7, // rw
};


/* returns a bitmask of serial devices found (bit n = found dev n) */
void serial_intr(void);
uint8_t serial_init(void);
void serial_config(uint8_t dev, uint16_t divisor, uint8_t lcr);
void serial_send(uint8_t dev, uint8_t val);
void serial_send_arr(uint8_t dev, uint32_t len, const uint8_t *arr);
void serial_send_str(uint8_t dev, const uint8_t *str);
bool serial_avail(uint8_t dev);
bool serial_recv(uint8_t dev, uint8_t *val);
void serial_flush(uint8_t dev);

#else

extern serial_intr
extern serial_init
extern serial_config
extern serial_send
extern serial_send_arr
extern serial_send_str
extern serial_avail
extern serial_recv
extern serial_flush

#endif

#endif
