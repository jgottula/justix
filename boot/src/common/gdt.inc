; justix
; (c) 2013 Justin Gottula
; The source code of this project is distributed under the terms of the
; simplified BSD license. See the LICENSE file for details.


%define GDT_ACC_AC    0x01
%define GDT_ACC_RW    0x02
%define GDT_ACC_DC    0x04
%define GDT_ACC_EX    0x08
%define GDT_ACC_PRIVL 0x60
%define GDT_ACC_PR    0x80

%define GDT_FL_GR 0x80
%define GDT_FL_SZ 0x40
