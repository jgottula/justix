#ifndef JGSYS_KERN_SERIAL_SERIAL
#define JGSYS_KERN_SERIAL_SERIAL

#ifndef __ASSEMBLY__

#define SER_115200  1
#define SER_57600   2
#define SER_38400   3
#define SER_19200   6
#define SER_9600   12
#define SER_4800   24
#define SER_2400   48

#define SER_5BIT 0b00
#define SER_6BIT 0b01
#define SER_7BIT 0b10
#define SER_8BIT 0b11

#define SER_PAR_NONE  0b000
#define SER_PAR_ODD   0b001
#define SER_PAR_EVEN  0b011
#define SER_PAR_MARK  0b101
#define SER_PAR_SPACE 0b111

#define SER_1STOP 0b0
#define SER_2STOP 0b1

#define SER_8N1 (SER_8BIT | SER_PAR_NONE | SER_1STOP)

#define SER_OFF_DLL 0x00 // rw dlab  divisor latch low byte
#define SER_OFF_DLH 0x01 // rw dlab  divisor latch high byte
#define SER_OFF_THR 0x00 //  w       transmitter holding buffer
#define SER_OFF_RBR 0x00 // r        receiver buffer
#define SER_OFF_IER 0x01 // rw       interrupt enable
#define SER_OFF_IIR 0x02 // r        interrupt identification
#define SER_OFF_FCR 0x02 //  w       fifo control
#define SER_OFF_LCR 0x03 // rw       line control
#define SER_OFF_MCR 0x04 // rw       modem control
#define SER_OFF_LSR 0x05 // r        line status
#define SER_OFF_MSR 0x06 // r        modem status
#define SER_OFF_SR  0x07 // rw       scratch register


#include <stdbool.h>
#include <stdint.h>


/* returns a bitmask of serial devices found (bit 0 = found serial 0) */
uint8_t serial_detect(void);
void serial_init(uint8_t dev, uint16_t divisor, uint8_t config);
void serial_send_str(uint8_t dev, const char *str);
void serial_send(uint8_t dev, char chr);
char serial_recv(uint8_t dev);

#else

%assign SER_115200  1
%assign SER_57600   2
%assign SER_38400   3
%assign SER_19200   6
%assign SER_9600   12
%assign SER_4800   24
%assign SER_2400   48

%assign SER_5BIT 0b00
%assign SER_6BIT 0b01
%assign SER_7BIT 0b10
%assign SER_8BIT 0b11

%assign SER_PAR_NONE  0b000
%assign SER_PAR_ODD   0b001
%assign SER_PAR_EVEN  0b011
%assign SER_PAR_MARK  0b101
%assign SER_PAR_SPACE 0b111

%assign SER_1STOP 0b0
%assign SER_2STOP 0b1

%assign SER_8N1 (SER_8BIT | SER_PAR_NONE | SER_1STOP)

%assign SER_OFF_DLL 0x00 ; rw dlab  divisor latch low byte
%assign SER_OFF_DLH 0x01 ; rw dlab  divisor latch high byte
%assign SER_OFF_THR 0x00 ;  w       transmitter holding buffer
%assign SER_OFF_RBR 0x00 ; r        receiver buffer
%assign SER_OFF_IER 0x01 ; rw       interrupt enable
%assign SER_OFF_IIR 0x02 ; r        interrupt identification
%assign SER_OFF_FCR 0x02 ;  w       fifo control
%assign SER_OFF_LCR 0x03 ; rw       line control
%assign SER_OFF_MCR 0x04 ; rw       modem control
%assign SER_OFF_LSR 0x05 ; r        line status
%assign SER_OFF_MSR 0x06 ; r        modem status
%assign SER_OFF_SR  0x07 ; rw       scratch register

extern serial_send_str

%ifndef jgsys_kern_serial_serial
extern serial_detect
extern serial_init
extern serial_send
extern serial_recv
%endif

#endif

#endif
