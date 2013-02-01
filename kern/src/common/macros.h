#ifndef JGSYS_KERN_COMMON_MACROS
#define JGSYS_KERN_COMMON_MACROS

#ifndef __ASSEMBLY__

#else

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
	push %1
%endrep
	
	call %$invoke_func
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

/* TODO: remember args/locals and undef all of them in func_end */
/* TODO: allow for sizes? */
%macro params 1-*
%assign %$params_off 8
%rep %0
%define %$%1 ebp+%[%$params_off]
%assign %$params_off %$params_off+4
%rotate 1
%endrep
%endm

/* TODO: remember args/locals and undef all of them in func_end */
/* TODO: allow for sizes? */
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

%macro func_end 0
%ifdef %$saved
	unsave %$saved
%endif
	unframe
	ret
%pop
%endm

/* TODO: fix this */
%macro extern_maybe 1
%ifndef %1
	extern %1
%endif
%endm

#endif

#endif
