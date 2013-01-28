%macro fill_to 2
	times %1-($-$$) db %2
%endmacro

%macro dw_be 1
	db ((%1) >> 8) & 0xff
	db (%1) & 0xff
%endmacro

%macro dd_be 1
	db (%1) >> 24
	db ((%1) >> 16) & 0xff
	db ((%1) >> 8) & 0xff
	db (%1) & 0xff
%endmacro

%macro dq_be 1
	db (%1) >> 56
	db ((%1) >> 48) & 0xff
	db ((%1) >> 40) & 0xff
	db ((%1) >> 32) & 0xff
	db ((%1) >> 24) & 0xff
	db ((%1) >> 16) & 0xff
	db ((%1) >> 8) & 0xff
	db (%1) & 0xff
%endmacro

%define _BV(_x) (1 << _x)
