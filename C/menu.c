#include <cdk/cdk.h>

//static char *menulist[MAX_MENU_ITEMS][MAX_SUB_ITEMS];

/*#ifdef HAVE_XCURSES
char *XCursesProgramName = "metasploit_ex";
#endif*/

int main() {
	CDKSCREEN *cdkscreen = 0;
	CDKLABEL *infoBox    = 0;
	CDKMENU*menu         = 0;
	WINDOW*cursesWin     = 0;
	int submenusize[7], menuloc[8];
	int selection;

	cursesWin = initscr();
	cdkscreen = initCDKScreen (cursesWin);

	initCDKColor();

	static char *menulist[MAX_MENU_ITEMS][MAX_SUB_ITEMS];

	menulist[0][0] = "</B>File<!B>"; menulist[1][0] = "</B>Exploits<!B>";
	menulist[2][0] = "</B>Auxilary<!B>"; menulist[3][0] = "</B>Payloads<!B>";
	menulist[4][0] = "</B>History<!B>"; menulist[5][0] = "</B>Post-Exploit<!B>";
	menulist[6][0] = "</B>Help<!B>";

	submenusize[0] = 2; menuloc[0] = LEFT;
	submenusize[1] = 2; menuloc[1] = LEFT;
	submenusize[2] = 2; menuloc[2] = LEFT;
	submenusize[3] = 2; menuloc[3] = LEFT;
	submenusize[4] = 2; menuloc[4] = LEFT;
	submenusize[5] = 2; menuloc[5] = LEFT;
	submenusize[6] = 2; menuloc[6] = LEFT;

	menu = newCDKMenu (cdkscreen, menulist, 6, submenusize, menuloc, TOP,
			A_UNDERLINE, A_REVERSE);

	refreshCDKScreen(cdkscreen);

	selection = activateCDKMenu (menu, 0);

	destroyCDKMenu (menu);
	destroyCDKScreen (cdkscreen);
	endCDK();
	return (EXIT_SUCCESS);
}

