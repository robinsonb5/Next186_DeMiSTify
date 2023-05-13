#include "config.h"
#include "statusword.h"
#include "ps2.h"
#include "keyboard.h"
#include "uart.h"
#include "interrupts.h"
#include "configstring.h"
#include "diskimg.h"

#include <stdio.h>
#include <string.h>

#include "c64keys.c"

int LoadROM(const char *fn);

int UpdateKeys(int blockkeys)
{
	handlec64keys();
	return(HandlePS2RawCodes(blockkeys));
}

char romname[12];

char *autoboot()
{
	char *result=0;

	DIRENTRY *de;
	statusword|=1;
	sendstatus();

	configstring_index=0;
	
	configstring_getcorename(romname,8);
	strcpy(&romname[8],"   ");
	
	if(de=GetDirEntry(romname))
		ChangeDirectory(de);

	strcpy(&romname[8],"VHD");
    diskimg_mount(romname,0);

	strcpy(&romname[8],"ROM");
	if(!LoadROM(romname))
		result="ROM loading failed";

	ChangeDirectoryByCluster(0); // return to the root directory

	initc64keys();

//	puts("Autoboot: ");
	if(result)
		puts(result);
	putchar('\n');

	statusword&=~1;
	sendstatus();

	return(result);
}


char *get_rtc();

__weak void mainloop()
{
	int framecounter;
	initc64keys();
	while(1)
	{
		handlec64keys();
		Menu_Run();
		diskimg_poll();
		if((framecounter++&8191)==0)
			user_io_send_rtc(get_rtc());
	}
}


