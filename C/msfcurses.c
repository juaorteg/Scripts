#include <cdk/cdk.h>

#ifdef HAVE_XCURSES
char *XCursesProgramName = "msfcurses";
#endif

int main() {
	
	/* Decleration */
	CDKSCREEN *cdkscreen = 0;
	//CDKBUTTONBOX *buttonWidget;
	CDKENTRY *entry1, *entry2, *entry3, *entry4;
	WINDOW *cursesWin;
	//const char *buttons[] = [" Connect ", " Exit ", "Start msfrpcd "];
	const char *info1, *info2, *info3, *info4;
	int selection;

	/* Start CDK */
	cursesWin = initscr();
	cdkscreen = initCDKScreen (cursesWin);
	initCDKColor();

	/* Username Field */
	entry1 = newCDKEntry (cdkscreen, CENTER, CENTER, NULL,
			"<B>Username: <!B>", A_NORMAL, ' ', vMIXED,
			20, 0, 30, FALSE, FALSE);
	/* Password Field */
	entry2 = newCDKEntry (cdkscreen, CENTER, getbegy(entry1->win)+entry1->boxHeight-1, NULL,
			"<B>Password: <!B>", A_NORMAL, ' ', vHMIXED,
			20, 0, 30, FALSE, FALSE);
	/* Host Field */
	entry3 = newCDKEntry (cdkscreen, CENTER, getbegy(entry2->win)+entry2->boxHeight-1, NULL,
			"<B>Host: <!B>", A_NORMAL, ' ', vMIXED,
			20, 0, 40, FALSE, FALSE);
	/* Port Field */
	entry4 = newCDKEntry (cdkscreen, CENTER, getbegy(entry3->win)+entry3->boxHeight-1, NULL,
			"<B>Port: <!B>", A_NORMAL, ' ', vINT,
			6, 0, 6, FALSE, FALSE);

	/* Draw the screen */
	refreshCDKScreen (cdkscreen);

	info1 = activateCDKEntry (entry1, 0);
	info2 = activateCDKEntry (entry2, 0);
	info3 = activateCDKEntry (entry3, 0);
	info4 = activateCDKEntry (entry4, 0);

	refreshCDKScreen(cdkscreen);

	destroyCDKScreen(cdkscreen);
	endCDK();
	return(EXIT_SUCCESS);
}

