#include "config.h"
#include "statusword.h"
#include "ps2.h"
#include "keyboard.h"
#include "uart.h"
#include "interrupts.h"
#include "configstring.h"
#include "diskimg.h"
#include "ide.h"

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

extern unsigned char romtype;

int loadimage(char *filename,int unit)
{
	int result=0;
	switch(unit)
	{
		case 0:
		case 1:
		case 2:
			if(filename && filename[0])
			{
				statusword|=1;
				sendstatus();
				romtype=unit+1;
				result=LoadROM(filename);
			}
			break;
		case '0': /* Pseudo-SD card */
			diskimg_mount(0,unit-'0');				
			return(diskimg_mount(filename,unit-'0'));				
		case '1': /* IDE devices */
		case '2':
			OpenHardfile(filename,unit-'1');
			break;
	}
	statusword&=~1;
	sendstatus();
	return(result);
}

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
		int t;
		handlec64keys();
		Menu_Run();
		diskimg_poll();
		HandleHDD();
		if((framecounter++&8191)==0)
			user_io_send_rtc(get_rtc());
		t=TestKey(KEY_SET1_F11)&2;
		if(TestKey(KEY_SET1_LCTRL) && t)
		{
			while(TestKey(KEY_SET1_F11) || TestKey(KEY_SET1_LCTRL)) /* Wait for both keys released */
				HandlePS2RawCodes(1);
			t=GetTimer(1000);
			Menu_Message("Pausing..",0);
			while(!CheckTimer(t))
				;
			Menu_ShowHide(0);
			while(!(TestKey(KEY_SET1_F11)&2))
				HandlePS2RawCodes(1);
			while(TestKey(KEY_SET1_F11))
				HandlePS2RawCodes(1);
			Menu_Message("Unpausing...",1000);
		}
	}
}


