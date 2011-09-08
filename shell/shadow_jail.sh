#!/bin/bash
#===============================================================================
#
#          FILE:  shadow_jail.sh
# 
#         USAGE:  ./shadow_jail.sh 
# 
#   DESCRIPTION:  This script is a demo intended to chroot local services.
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Juan Ortega 
#        SCHOOL:  UAT
#       VERSION:  1.0
#       CREATED:  03/02/2011 01:36:12 AM MST
#      REVISION:  ---
#===============================================================================

#-------------------------------------------------------------------------------
#   Backtitle variable defines the name and version of the project.
#-------------------------------------------------------------------------------
Bk_V="Version 1.0"
Bk_T="Shadow_Jail - $Bk_V"

#===  FUNCTION  ================================================================
#          NAME:  ck_wr
#   DESCRIPTION:  Used by view_daemon() function to check if a service exists.
#    PARAMETERS:  Daemon executable.
#       RETURNS:  None -(void) version number-
#===============================================================================

ck_wr() { echo $(whereis $1|awk '{print $2}'); }

#-------------------------------------------------------------------------------
#   Daemon Variable Declarations
#-------------------------------------------------------------------------------

httpd=$(ck_wr "httpd")		# Apache
named=$(ck_wr "named")		# Bind
cupsd=$(ck_wr "cupsd")		# Cups
mysqld=$(ck_wr "mysqld")	# MySQL
ntpd=$(ck_wr "ntpd")		# NTP
smbd=$(ck_wr "smbd")		# Samba
sendmail=$(ck_wr "sendmail")	# Sendmail
snmpd=$(ck_wr "snmpd")		# SNMP

#-------------------------------------------------------------------------------
#   Environment Setting
#-------------------------------------------------------------------------------
unset DIAG  # Dialog
unset QUIET # No output
SCRIPT=${0##*/}

#===  FUNCTION  ================================================================
#          NAME:  view_daemon
#   DESCRIPTION:  
#    PARAMETERS:  Daemon
#       RETURNS:  None
#===============================================================================

view_daemon() {
  local daemon=$1 version info
  #local cntstr=$((`echo $string|sed 's/[A-Z]//g'|wc -m`+1))
  case "$daemon" in
  "Apache" )
    if [ -x $httpd ];then version=$($httpd -v|grep version|awk '{print $3,$4}')
    else version="Not Installed";fi
    dialog --title " $daemon -> Daemon Info " --msgbox \
      "The Apache HTTP Server Project is an effort to develop\
      and maintain an open-source HTTP server for modern operating\
      systems including UNIX and Windows NT. The goal of this project\
      is to provide a secure, efficient and extensible server that\
      provides HTTP services in sync with the current HTTP standards.\
      \n\nVersion Installed: $version" 14 50
      ;;
  * )
    info="An Error has occured" ;;
  esac
}

#===  FUNCTION  ================================================================
#          NAME:  chroot_daemon
#   DESCRIPTION:  Chroot a Daemon
#    PARAMETERS:  $1 - Deamon Name
#       RETURNS:  
#===============================================================================

chroot_daemon() {
  local chrootdir="/chroot"
  case "$1" in
    "Apache" )
      chrootdir="$chrootdir/httpd"
      dialog --infobox "[Setting up Environment...]" 3 31
      #-------------------------------------------------------------------------------
      #   Copy Files and Libraries
      #-------------------------------------------------------------------------------
      /bin/killall httpd >/dev/null 2>&1
      /usr/bin/strace -e trace=open -o /tmp/.apache_strace $httpd >/dev/null 2>&1
      for i in $(grep -v tmp /tmp/.apache_strace | awk -F\" '{print $(NF-1)}' | awk '{if (k[$1]!=1) {print;k[$1]=1}}');do
	[ ! -d $(dirname $chrootdir$i) ] && /bin/mkdir -m 755 -p $(dirname $chrootdir$i)
        case $(echo "$i" | awk -F\/ '{print $NF}') in
	  passwd|group ) /bin/egrep "nobody|apache" $i > $chrootdir$i ;;
	  nsswitch.conf ) /bin/sed 's/compat/files/g' $i > $chrootdir$i ;;
	  * ) /bin/cp -fp $i $chrootdir$i >/dev/null 2>&1 ;;
        esac
      done
      /bin/egrep "nobody|apache" /etc/shadow > $chrootdir/etc/shadow && /bin/chmod 640 $chrootdir/etc/shadow
      local ld_lib=$(ldd /bin/sh | grep ld | awk '{print $1}') && /bin/cp -fp $ld_lib $chrootdir$ld_lib >/dev/null 2>&1
      if [ /srv/httpd -ef /var/www ];then
        /bin/mkdir -m 755 -p $chrootdir/srv && /bin/ln -s /var/www $chrootdir/srv/httpd
	/bin/mkdir -m 755 -p $chrootdir/var/www && /bin/cp -frp /var/www $chrootdir/var/ >/dev/null 2>&1
      elif [ -d /var/www ];then
        /bin/mkdir -m 755 -p $chrootdir/var/www
        /bin/cp -frp /var/www $chrootdir/var >/dev/null 2>&1
        /bin/sed 's/^DocumentRoot/\#DocumentRoot/g' $chrootdir/etc/httpd/httpd.conf \
       	  | /bin/sed '/^\#DocumentRoot/a\DocumentRoot \"\/var\/www\/htdocs\"' > /tmp/.apache_conf
	  /bin/cp -f /tmp/.apache_conf $chrootdir/etc/httpd/httpd.conf
	  /bin/rm /tmp/.apache_conf
      elif [ -d /www ];then
        /bin/mkdir -m 755 -p $chrootdir/www
        /bin/cp -frp /www $chrootdir >/dev/null >/dev/null 2>&1
	/bin/sed 's/^DocumentRoot/\#DocumentRoot/g' $chrootdir/etc/httpd/httpd.conf \
       	  | /bin/sed '/^\#DocumentRoot/a\DocumentRoot \"\/www\/htdocs\"' > /tmp/.apache_conf
	/bin/cp -f /tmp/.apache_conf $chrootdir/etc/httpd/httpd.conf
	/bin/rm /tmp/.apache_conf
      fi
      /bin/mkdir -m 755 -p $chrootdir/var/run/httpd
      [ ! -d $(dirname $chrootdir$httpd) ] && /bin/mkdir -m 755 -p $(dirname $chrootdir$httpd)
      /bin/cp -fp $httpd $chrootdir$httpd >/dev/null 2>&1
      #-------------------------------------------------------------------------------
      #   Make Nodes
      #-------------------------------------------------------------------------------
      [ ! -d $chrootdir/dev ] && /bin/mkdir -m 755 $chrootdir/dev
      /bin/mknod -m 640 $chrootdir/dev/null c 1 3 >/dev/null 2>&1
      /bin/mknod -m 644 $chrootdir/dev/random c 1 8 >/dev/null 2>&1
      /bin/mknod -m 644 $chrootdir/dev/urandom c 1 9 >/dev/null 2>&1
      /bin/chown root:sys $chrootdir/dev/null
      #-------------------------------------------------------------------------------
      #   Chrooting Apache
      #-------------------------------------------------------------------------------
      /bin/kill -9 $(ps -A | grep httpd | grep -v "<defunct>" | awk '{print $1}') >/dev/null 2>&1
      dialog --title "[Successfull]" --yesno "Apache environment ready.\nStart Daemon now?" 6 30
      if [ $? == 0 ];then 
        dialog --infobox "[Staring Apache...]" 3 24
	/bin/chroot $chrootdir $httpd >/dev/null 2>&1
	[ $? == 0 ] && dialog --infobox "[Apache Started.]" 3 21 && sleep 1 \
	  || dialog --infobox "[Failed to Start.]" 3 22 && sleep 1
      fi
      ;;

#		    # Setting up syslog
#		    [ -f /usr/sbin/syslogd -o -f /var/run/syslogd.pid ] && \
#		    	/bin/kill $(cat /var/run/syslogd.pid) 2>&1 > /dev/null && \
#			/usr/sbin/syslogd -ss -l $chrootdir/dev/log 2>&1 >/dev/null
#
#		    [ -f /usr/sbin/syslog-ng -o -f /var/run/syslog-ng.pid ] && \
#		    	/bin/kill $(cat /var/run/syslog-ng.pid) 2>&1 >/dev/null && \
#			/usr/sbin/syslog-ng -ss -l $chrootdir/dev/log 2>&1 >/dev/null
#
#
    "Bind")
      chrootdir="$chrootdir/named"
      dialog --infobox "[Setting up Environment...]" 3 31
      #-------------------------------------------------------------------------------
      #   Copy Files and Libraries
      #-------------------------------------------------------------------------------
      /bin/killall named >/dev/null 2>&1
      /usr/bin/strace -e trace=open -o /tmp/.named_strace $named >/dev/null 2>&1
      for i in $(grep -v tmp /tmp/.named_strace | awk -F\" '{print $(NF-1)}' | awk '{if (k[$1]!=1) {print;k[$1]=1}}');do
	[ ! -d $(dirname $chrootdir$i) ] && /bin/mkdir -m 755 -p $(dirname $chrootdir$i)
        case $(echo "$i" | awk -F\/ '{print $NF}') in
	  null ) 
	    /bin/mknod -m 640 $chrootdir/dev/null c 1 3 >/dev/null 2>&1
	    /bin/chown root:sys $chrootdir/dev/null ;;
	  * ) /bin/cp -fp $i $chrootdir$i >/dev/null 2>&1 ;;
        esac
      done
      local ld_lib=$(ldd /bin/sh | grep ld | awk '{print $1}') && /bin/cp -fp $ld_lib $chrootdir$ld_lib >/dev/null 2>&1
      [ -f /etc/named.conf ] && /bin/cp -fp /etc/named.conf $chrootdir/etc >/dev/null 2>&1
      [ -d /var/run/named ] && /bin/mkdir -m 755 -p $chrootdir/var/run/named \
        && /bin/cp -frp /var/run/named $chrootdir/var/run
      [ -d /var/named ] && /bin/mkdir -m 755 -p $chrootdir/var/named && /bin/cp -frp /var/named $chrootdir/var
      [ ! -d $(dirname $chrootdir$named) ] && /bin/mkdir -m 755 -p $(dirname $chrootdir$named)
      /bin/cp -fp $named $chrootdir$named >/dev/null 2>&1
      #-------------------------------------------------------------------------------
      #   Chrooting Named
      #-------------------------------------------------------------------------------
      /bin/kill -9 $(ps -A | grep named | grep -v "<defunct>" | awk '{print $1}') >/dev/null 2>&1
      dialog --title "[Successfull]" --yesno "Bind environment ready.\nStart Daemon now?" 6 30
      if [ $? == 0 ];then 
        dialog --infobox "[Staring Bind...]" 3 22
	/bin/chroot $chrootdir $named >/tmp/.none5 2>/tmp/.none6
	[ $? == 0 ] && dialog --infobox "[Bind Started.]" 3 19 && sleep 1 \
	  || dialog --infobox "[Failed to Start.]" 3 22 && sleep 1
      fi
      ;;

  "NTPD")
      chrootdir="$chrootdir/ntpd"
      dialog --infobox "[Setting up Environment...]" 3 31
      #-------------------------------------------------------------------------------
      #   Copy Files and Libraries
      #-------------------------------------------------------------------------------
      /bin/killall ntpd >/dev/null 2>&1
      /usr/bin/strace -e trace=open -o /tmp/.ntpd_strace $ntpd >/dev/null 2>&1
      for i in $(grep -v tmp /tmp/.ntpd_strace | awk -F\" '{print $(NF-1)}' | awk '{if (k[$1]!=1) {print;k[$1]=1}}');do
	[ ! -d $(dirname $chrootdir$i) ] && /bin/mkdir -m 755 -p $(dirname $chrootdir$i)
        /bin/cp -fp $i $chrootdir$i >/dev/null 2>&1
      done
      local ld_lib=$(ldd /bin/sh | grep ld | awk '{print $1}') && /bin/cp -fp $ld_lib $chrootdir$ld_lib >/dev/null 2>&1
      [ ! -d $(dirname $chrootdir$ntpd) ] && /bin/mkdir -m 755 -p $(dirname $chrootdir$ntpd)
      /bin/cp -fp $ntpd $chrootdir$ntpd >/dev/null 2>&1
      #-------------------------------------------------------------------------------
      #   Extra Libraries
      #-------------------------------------------------------------------------------
      [ ! -d $chrootdir/usr/lib ] && /bin/mkdir -m 755 -p $chrootdir/usr/lib
      for i in liblwres* libdns* libbind9* libisccfg* libisccc* libisc* libxml2* libz*;do
        /bin/cp -fp /usr/lib/$i $chrootdir/usr/lib >/dev/null 2>&1
      done
      #-------------------------------------------------------------------------------
      #   Make Nodes
      #-------------------------------------------------------------------------------
      [ ! -d $chrootdir/dev ] && /bin/mkdir -m 755 $chrootdir/dev
      /bin/mknod -m 640 $chrootdir/dev/null c 1 3 >/dev/null 2>&1
      /bin/chown root:sys $chrootdir/dev/null
      #-------------------------------------------------------------------------------
      #   Chrooting Named
      #-------------------------------------------------------------------------------
      /bin/kill -9 $(ps -A | grep ntpd | grep -v "<defunct>" | awk '{print $1}') >/dev/null 2>&1
      dialog --title "[Successfull]" --yesno "Ntpd environment ready.\nStart Daemon now?" 6 30
      if [ $? == 0 ];then 
        dialog --infobox "[Staring Ntpd...]" 3 22
	/bin/chroot $chrootdir $ntpd >/tmp/.none5 2>/tmp/.none6
	[ $? == 0 ] && dialog --infobox "[Ntpd Started.]" 3 19 && sleep 1 \
	  || dialog --infobox "[Failed to Start.]" 3 22 && sleep 1
      fi
      ;;

    "Sendmail" )
      chrootdir="$chrootdir/sendmail"
      dialog --infobox "[Setting up Environment...]" 3 31
      #-------------------------------------------------------------------------------
      #   Copy Files and Libraries
      #-------------------------------------------------------------------------------
      /bin/killall httpd >/dev/null 2>&1
      /usr/bin/strace -e trace=open -o /tmp/.sendmail_strace1 $sendmail -L sm-mta -bd -q25m >/dev/null 2>&1
      /usr/bin/strace -e trace=open -o /tmp/.sendmail_strace2 $sendmail -L sm-msp-queue -Ac -q25m >/dev/null 2>&1
      /bin/cat /tmp/.sendmail_strace1 /tmp/.sendmail_strace2 > /tmp/.sendmail_strace3
      for i in $(grep -v tmp /tmp/.sendmail_strace3 | awk -F\" '{print $(NF-1)}' | awk '{if (k[$1]!=1) {print;k[$1]=1}}');do
	[ ! -d $(dirname $chrootdir$i) ] && /bin/mkdir -m 755 -p $(dirname $chrootdir$i)
        case $(echo "$i" | awk -F\/ '{print $NF}') in
	  passwd|group ) /bin/egrep "nobody|mail|smmsp" $i > $chrootdir$i ;;
	  nsswitch.conf ) /bin/sed 's/compat/files/g' $i > $chrootdir$i ;;
	  * ) /bin/cp -fp $i $chrootdir$i >/dev/null 2>&1 ;;
        esac
      done
      /bin/egrep "nobody|mail|smmsp" /etc/shadow > $chrootdir/etc/shadow && /bin/chmod 640 $chrootdir/etc/shadow
      local ld_lib=$(ldd /bin/sh | grep ld | awk '{print $1}') && /bin/cp -fp $ld_lib $chrootdir$ld_lib >/dev/null 2>&1
      [ ! -d $chrootdir/var/spool/clientmqueue ] && /bin/mkdir -m 755 -p $chrootdir/var/spool/clientmqueue
      [ ! -d $chrootdir/var/spool/mqueue ] && /bin/mkdir -m 755 -p $chrootdir/var/spool/mqueue
      [ ! -d $(dirname $chrootdir$sendmail) ] && /bin/mkdir -m 755 -p $(dirname $chrootdir$sendmail)
      /bin/cp -fp $sendmail $chrootdir$sendmail >/dev/null 2>&1
      #-------------------------------------------------------------------------------
      #   Make Nodes
      #-------------------------------------------------------------------------------
      [ ! -d $chrootdir/dev ] && /bin/mkdir -m 755 $chrootdir/dev
      /bin/mknod -m 640 $chrootdir/dev/null c 1 3 >/dev/null 2>&1
      /bin/chown root:sys $chrootdir/dev/null
      #-------------------------------------------------------------------------------
      #   Chrooting Apache
      #-------------------------------------------------------------------------------
      /bin/kill -9 $(ps -A | grep sendmail | grep -v "<defunct>" | awk '{print $1}') >/dev/null 2>&1
      dialog --title "[Successfull]" --yesno "Sendmail environment ready.\nStart Daemon now?" 6 31
      if [ $? == 0 ];then 
        dialog --infobox "[Staring Sendmail...]" 3 26
	/bin/chroot $chrootdir $sendmail -L sm-mta -bd -q25m >/tmp/.none1 2>/tmp/.none2
	/bin/chroot $chrootdir $sendmail -L sm-msp-queue -Ac -q25m >/tmp/.none3 2>/tmp/.none4
	[ $? == 0 ] && dialog --infobox "[Sendmail Started.]" 3 23 && sleep 1 \
	  || dialog --infobox "[Failed to Start.]" 3 22 && sleep 1
      fi
      ;;

    "Cups" )
      chrootdir="$chrootdir/cupsd"
      dialog --infobox "[Setting up Environment...]" 3 31
      #-------------------------------------------------------------------------------
      #   Copy Files and Libraries
      #-------------------------------------------------------------------------------
      /bin/killall cupsd >/dev/null 2>&1
      /usr/bin/strace -e trace=open -o /tmp/.cupsd_strace $cupsd >/dev/null 2>&1
      for i in $(grep -v tmp /tmp/.cupsd_strace|grep open|awk -F\" '{print $(NF-1)}'|awk '{if (k[$1]!=1) {print;k[$1]=1}}');do
	[ ! -d $(dirname $chrootdir$i) ] && /bin/mkdir -m 755 -p $(dirname $chrootdir$i)
        /bin/cp -fp $i $chrootdir$i >/dev/null 2>&1
      done
      [ -f /etc/cups/cupsd.conf ] && /bin/mkdir -m 755 -p $chrootdir/etc/cups \
        && /bin/cp -fp /etc/cups/cupsd.conf $chrootdir/etc/cups/cupsd.conf
      local ld_lib=$(ldd /bin/sh | grep ld | awk '{print $1}') && /bin/cp -fp $ld_lib $chrootdir$ld_lib >/dev/null 2>&1
      [ ! -d $(dirname $chrootdir$cupsd) ] && /bin/mkdir -m 755 -p $(dirname $chrootdir$cupsd)
      /bin/cp -fp $cupsd $chrootdir$cupsd >/dev/null 2>&1
      #-------------------------------------------------------------------------------
      #   Make Nodes
      #-------------------------------------------------------------------------------
      [ ! -d $chrootdir/dev ] && /bin/mkdir -m 755 $chrootdir/dev
      /bin/mknod -m 640 $chrootdir/dev/null c 1 3 >/dev/null 2>&1
      /bin/chown root:sys $chrootdir/dev/null
      #-------------------------------------------------------------------------------
      #   Chrooting Apache
      #-------------------------------------------------------------------------------
      /bin/kill -9 $(ps -A | grep cupsd | grep -v "<defunct>" | awk '{print $1}') >/dev/null 2>&1
      dialog --title "[Successfull]" --yesno "Cupsd environment ready.\nStart Daemon now?" 6 28
      if [ $? == 0 ];then 
        dialog --infobox "[Staring Cupsd...]" 3 23
	/bin/chroot $chrootdir $cupsd > /tmp/.none1 2>/tmp/.none2
	[ $? == 0 ] && dialog --infobox "[Cupsd Started.]" 3 20 && sleep 1 \
	  || dialog --infobox "[Failed to Start.]" 3 22 && sleep 1
      fi
      ;;

  esac
}

#===  FUNCTION  ================================================================
#          NAME:  info_daemon
#   DESCRIPTION:  
#    PARAMETERS:  
#       RETURNS:  
#===============================================================================

info_daemon() {
  local daemon=$1
  local DEFAULT_ITEM
  local ANSWER_FILE=$HOME/.answer_info_daemon

  while :; do
    dialog --default-item "DEFAULT_ITEM" --cancel-label "Back" \
      --title " Menu -> Daemons -> $daemon " --backtitle "$Bk_T" --menu \
      "Please select an option or press <Back> to go back." 12 55 5 \
      "View" "Display daemon information" \
      "Chroot" "Chroot $daemon now." \
      "Error Log" "View the Error Log" \
      "Edit" "Edit/View Config files" \
      "Test" "-- Not available yet --" 2>$ANSWER_FILE

      DEFAULT_ITEM=$(< $ANSWER_FILE)
      case "$DEFAULT_ITEM" in
        "View" )      view_daemon $daemon ;;
	"Chroot" )    chroot_daemon $daemon ;;
	"Error Log" ) continue ;;
	"Edit" )      continue ;;
	"Test" )      continue ;;
	* )           break ;;
      esac
  done
}
		
#===  FUNCTION  ================================================================
#          NAME:  browse_daemon
#   DESCRIPTION:  
#    PARAMETERS:  
#       RETURNS:  
#===============================================================================

browse_daemons() {
  local DEFAULT_ITEM
  local ANSWER_FILE=$HOME/.answer_daemon
  while :; do
    dialog --default-item "$DEFAULT_ITEM" --cancel-label "Back" \
      --title " Menu -> Daemons " --backtitle "$Bk_T" \
      --menu "Please select a Daemon or press <Back> to go back." 18 57 12 \
      "Apache" "Web Server" \
      "Bind" "Domain Name Server" \
      "Cups" "Print Server" \
      "MySQL" "Database Server" \
      "NFSD" "Network File System" \
      "NTPD" "Network Time Protocol" \
      "RPC" "Remote Procedure Call" \
      "Samba" "Windows File Share" \
      "Sendmail" "SMTP Server" \
      "SNMP" "Simple Network Management Protocol" \
      "SSHD" "Secure Shell Server" \
      "FTP" "File Transfer Protocol" 2>$ANSWER_FILE

      if [[ $? != 0 ]];then break;fi
      DEFAULT_ITEM=$(< $ANSWER_FILE)
      info_daemon $DEFAULT_ITEM
  done
}

#browse_applications() {
#
#
#}

#===  FUNCTION  ================================================================
#          NAME:  main_menu
#   DESCRIPTION:  
#    PARAMETERS:  
#       RETURNS:  
#===============================================================================

main_menu() {
  local DEFAULT_ITEM
  local ANSWER_FILE=$HOME/.answer
  while :; do
    dialog --cancel-label "Exit" --default-item "$DEFAULT_ITEM" --title " $Bk_T " \
      --backtitle "A collection of chroot scripts to Jail Daemons and Applications" \
      --menu "\nChoose one of the following or press <Exit> to quit.\n" 13 62 5 \
        "Daemons" "Browse local daemons to chroot" \
	"Applications" "Browse local applications to chroot" \
	"Process" "Control and View chroot'ed programs" \
	"Utilities" "Small scripts to refine a sandbox" \
	"Help" "Where to get Help" 2>$ANSWER_FILE

	DEFAULT_ITEM=$(< $ANSWER_FILE)
	  case "$DEFAULT_ITEM" in
            "Daemons" )      browse_daemons ;;
	    "Applications" ) continue ;;
            "Process" )      continue ;;
	    "Utilities" )    continue ;;
	    "Help" )         continue ;;
	    * )		     clear; return 0 ;;
	  esac
  done
}

#-------------------------------------------------------------------------------
#   Get Parameters
#-------------------------------------------------------------------------------
while getopts ":a:b:cd:e:f:g:hi:kloPpqrRs:uV:v" OPT; do
  case $OPT in
    a ) # Advance GUI
      continue
      ;;
    c ) # Check for updates to installed SBo packages
      CHK_UPDATES=1
      unset DIAG
      ;;
    g ) # String search
      GENSEARCH="$OPTARG"
      unset DIAG
      ;;
    q ) # Quiet mode
      QUIET=1
      unset DIAG
      ;;
    t ) # Test mode
      continue
      ;;
    v ) # Print version
      echo $Bk_T
      exit 0
      ;;
    h | * ) # Help
      cat << EOF
[$SCRIPT] [$Bk_V]
Usage: $SCRIPT [Options]

Options are:
  -a              No Automatic Chroot, specifiy locations of everything.
  -d localdir     Location of local copy of the repositories.
  -e error_action Specify what sbopkg is supposed to do on build errors.
                  Valid options are: ask (default), continue, stop.
  -f file         Override default configuration file with specified file.
  -g package(s)   General search for packages matching string.
  -h              Display this help message.
  -i newroot      Invoke 'make install' and isolate
  -k status       Start | Stop | Restart | Status
EOF
      exit 0
      ;;
  esac
done

#-------------------------------------------------------------------------------
#   You Must be root (UID 0) to run this script.
#-------------------------------------------------------------------------------

[ $(id -u) != 0 ] && echo "You must be root to run this script." && exit 1

#-------------------------------------------------------------------------------
#   Start the Main Program
#-------------------------------------------------------------------------------

main_menu
