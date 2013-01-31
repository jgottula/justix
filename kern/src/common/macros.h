#ifndef JGSYS_KERN_COMMON_MACROS
#define JGSYS_KERN_COMMON_MACROS

#ifndef __ASSEMBLY__

#else

%macro frame 0-1
	push ebp
	mov ebp,esp
%if %0 == 1
	sub esp,%1
%endif
%endm

%macro unframe 0
	mov esp,ebp
	pop ebp
%endm

#endif

#endif
