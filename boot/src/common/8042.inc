; justix
; (c) 2013 Justin Gottula
; The source code of this project is distributed under the terms of the
; simplified BSD license. See the LICENSE file for details.

%define PS2_DATA_PORT  0x60
%define PS2_STATUS_REG 0x64
%define PS2_CMD_REG    0x64

%define PS2_SREG_OUT_FULL   0
%define PS2_SREG_IN_FULL    1
%define PS2_SREG_SYS_FLAG   2
%define PS2_SREG_CMD_DATA   3
%define PS2_SREG_TIME_OUT   6
%define PS2_SREG_PARITY_ERR 7
