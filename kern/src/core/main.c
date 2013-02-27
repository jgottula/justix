/* justix
 * (c) 2013 Justin Gottula
 * The source code of this project is distributed under the terms of the
 * simplified BSD license. See the LICENSE file for details.
 */


#include "core/main.h"
#include "common/version.h"
#include "lib/debug.h"
#include "serial/serial.h"
#include "bus/pci.h"
#include "core/task.h"
#include "platform/pic.h"


struct mem_map_entry *mem_map;


void kern_main(void) {
	serial_init();
	serial_config(0, SER_DIV_115200, SER_LCR_8N1);
	pic_enable(4);
	
	debug_write_fmt("justix kern\nCompiled: "
		VER_COMPILE_DATE " " VER_COMPILE_TIME "\n");
	
	//pci_enum();
	
	task_init();
	
	//task_enter_ring3(user_test);
	
	uint8_t *vid = (void *)0xb9000;
	while (true) {
		uint8_t rx;
		
		while (!serial_recv(0, &rx));
		serial_send(0, rx);
		
		*(vid++) = rx;
		*(vid++) = 0x07;
		
		if (vid >= (uint8_t *)0xba000) {
			vid = (void *)0xb9000;
		}
	}
	
	/* TODO: find the size of the memory map and allocate just enough space */
}

/*	; copy the memory map into kernel memory
	invoke memcpy,kern_mem_map,MEM_MAP_OFFSET,0x1000*/
