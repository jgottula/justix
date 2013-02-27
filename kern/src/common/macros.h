/* justix
 * (c) 2013 Justin Gottula
 * The source code of this project is distributed under the terms of the
 * simplified BSD license. See the LICENSE file for details.
 */

#ifndef JUSTIX_KERN_COMMON_MACROS
#define JUSTIX_KERN_COMMON_MACROS

#ifndef __ASSEMBLY__

#define NULL 0

#define _BV(_x) (1 << (_x))

#else

%assign true  1
%assign false 0

%macro strz 1
	db %1,`\0`
%endm

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

; warning, CEIL will behave strangely if _x is zero
%define CEIL(_x, _step) ((((_x) - 1) / (_step)) + 1)
%define _BV(_x) (1 << (_x))

%define param(_n) dword [ebp+(4*(_n+2))]
%define local(_n) dword [ebp-(4*(_n))]

%macro frame 0
	push ebp
	mov ebp,esp
%endm

%macro unframe 0
	mov esp,ebp
	pop ebp
%endm

%macro invoke 1-*
%push
%define %$invoke_func %1
	
%rep %0-1
%rotate -1
	push dword %1
%endrep
	
	call %$invoke_func
	
%if %0 > 1
	add esp,(4*(%0-1))
%endif
%pop
%endm

%macro save 1-*
%define %$saved %{1:-1}
%rep %0
	push %1
%rotate 1
%endrep
%endm

%macro unsave 1-*
%rep %0
%rotate -1
	pop %1
%endrep
%endm

%macro params 1-*
%assign %$params_off 8
%rep %0
%define %$%1 ebp+%[%$params_off]
%assign %$params_off %$params_off+4
%rotate 1
%endrep
%endm

%macro locals 1+
%assign %$locals_off 0
%rep %0
%define %$%1 ebp-%[%$locals_off]
%assign %$locals_off %$locals_off+4
%rotate 1
%endrep
	
	sub esp,%$locals_off
%endm

%macro func 1
%push func_%1
	align 4
	global %1:function
%1:
	frame
%endm

%macro func_priv 1
%push func_%1
	align 4
%1:
	frame
%endm

%macro func_end 0
.exit:
%ifdef %$saved
	unsave %$saved
%endif
	unframe
	ret
%pop
%endm

%macro trap 1
%push trap_%1
%assign %$trap_has_code 0
%define %$regs   ebp-36
%define %$eip    ebp+4
%define %$cs     ebp+8
%define %$eflags ebp+12
	align 4
	global %1:function
%1:
	frame
	pushfd
	pushad
%endm

%macro trap_code 1
%push trap_%1
%assign %$trap_has_code 1
%define %$regs   ebp-36
%define %$code   ebp+4
%define %$eip    ebp+8
%define %$cs     ebp+12
%define %$eflags ebp+16
	align 4
	global %1:function
%1:
	frame
	pushfd
	pushad
%endm

%macro trap_end 0
.exit:
	popad
	popfd
	unframe
%if %$trap_has_code != 0
	; leave flags alone
	lea esp,[esp+4]
%endif
	iret
%pop
%endm

%macro gdata 1
	global %1:data
%1:
%endm

#endif

#endif
