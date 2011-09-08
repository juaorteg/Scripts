#include <cdk/cdk.h>

//static BINDFN_PROTO(XXXCB);

int main() {
	CDKSCREEN *cdkscreen = 0;
	CDKENTRY *username   = 0;
	WINDOW *cursesWin    = 0;
	char *title          = "<C>Msfrpcd Access<!C>";
	char *label          = "<B>Username:<!B>";
	char *info;

	cursesWin = initscr();
	cdkscreen = initCDKScreen (cursesWin);

	initCDKColor();

	username = newCDKEntry (cdkscreen, CENTER, CENTER, title, label,
			A_NORMAL, '.', vMIXED, 30, 0, 256, FALSE, FALSE);

	//bindCDKObject (vENTRY, username, 'H', XXXCB, 0);

	if (username == 0) {
		destroyCDKScreen(cdkscreen);
		endCDK();
		return(EXIT_FAILURE);
	}
	refreshCDKScreen (cdkscreen);

	info = activateCDKEntry (username, 0);

	if (username->exitType == vESCAPE_HIT) {
		destroyCDKEntry (username);
	}
	else {
		destroyCDKEntry (username);
	}
	destroyCDKScreen(cdkscreen);
	endCDK();
	return (EXIT_SUCCESS);
}

/*
static int  XXXCB (EObjectType cdktype GCC_UNUSED, void *object GCC_UNUSED, void *clientData GCC_UNUSED,
 chtype key GCC_UNUSED)
{
   return (TRUE);
}*/

