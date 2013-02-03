#include <core/main.h>
#include <common/version.h>
#include <lib/debug.h>
#include <serial/serial.h>
#include <bus/pci.h>
#include <core/task.h>


struct mem_map_entry *mem_map;


void kern_main(void) {
	serial_detect();
	serial_init(0, SER_38400, SER_8N1);
	
	debug_write_fmt("JGSYS kern\nCompiled: "
		VER_COMPILE_DATE " " VER_COMPILE_TIME "\n");
	
	pci_enum();
	
	task_init();
	
	task_enter_ring3(user_test);
	
	while (true) {
		
	}
	
	/* TODO: find the size of the memory map and allocate just enough space */
}

/*	; copy the memory map into kernel memory
	invoke memcpy,kern_mem_map,MEM_MAP_OFFSET,0x1000
	
	; this stuff all needs to GO
	invoke video_clear_screen
	mov word [0xb9000],0x7000|'J'
	mov word [0xb9002],0x7000|'G'
	mov word [0xb9004],0x7000|'S'
	mov word [0xb9006],0x7000|'Y'
	mov word [0xb9008],0x7000|'S'
	mov word [0xb900a],0x7000|' '
	mov word [0xb900c],0x7000|'k'
	mov word [0xb900e],0x7000|'e'
	mov word [0xb9010],0x7000|'r'
	mov word [0xb9012],0x7000|'n'
	*/
