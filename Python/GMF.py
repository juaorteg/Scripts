###############
# GMFormatter #
###############
# Juan Ortega #
# Date 5/23/07#
###############
from os import chdir, system, mkdir
from time import sleep
from os.path import isfile, isdir, exists
from sys import exit
from progressbar import progressBar # /progressbar.py
system("title GMFormatter")
system("color 09")
system("cls")
start_screen = r"""********************************************************************************
   ________  __ __ ___________                          __   __
  /  _____/ /     \\_   _____/__________  _____ _____ _/  |_/  |_ ___________
 /   \  ___/       \|    __ / __ \_  __ \/     \\__  \\   __\  __/ __ \_  __ \
 \    \_\  \  \ /   \     \( <__> |  | \/  | |  \/ __ \|  | |  |\  ___/|  | \/
  \______  /___|__  /___  /  ____/ __|   __|_|  /____  /__|  __| \___  >__|
         \/       \/    \/                    \/     \/              \/ 

********************************************************************************"""
print start_screen
print
print "\t\t   -=- Drog and Drop the TXT File here -=- "
print
print "\t\t\t -=- Then Press [Enter] -=- "
print "\n"
try:
    file_name = raw_input("  ")
    file_name = file_name.strip("\"")
except KeyboardInterrupt: file_name = "C:\\"
if isfile(file_name) == False:
    while True:
        system("color 0C")
        system("cls")
        print start_screen
        print
        print "\t     -=- File Not Found! Drag the Drop the File again -=- "
        print
        print "\t\t\t -=- Then Press [Enter] -=- "
        print "\n"
        try: file_name = raw_input("  ")
        except KeyboardInterrupt: pass
        file_name = file_name.strip("\"")
        if isfile(file_name) == True: break
system("color 03")
system("cls")
print start_screen
print
print "\t\t-=- Found! Now Drog and Drop a Folder here -=- "
print
print "\t\t\t  -=- Then Press [Enter] -=- "
print "\n"
try:
    folder_name = raw_input("  ")
    folder_name = folder_name.strip("\"")
except KeyboardInterrupt: folder_name = "rqwd5ovncxx20ss"
if isdir(folder_name) == False:
    while True:
        system("color 0C")
        system("cls")
        print start_screen
        print
        print "\t   -=- Folder Not Found! Drag and Drop the Folder again -=- "
        print
        print "\t\t\t -=- Then Press [Enter] -=- "
        print "\n"
        try: folder_name = raw_input("  ")
        except KeyboardInterrupt: pass
        folder_name = folder_name.strip("\"")
        if isdir(folder_name) == True: break           
while True:
    system("color 02")       
    system("cls")
    print start_screen
    print
    print "-=- Checking File for Errors... -=-".rjust(57)
    print
    errorcount = 0
    er = []
    er_normal = []
    over = None
    open_file = open(file_name, "r")
    first_list = open_file.readlines()
    open_file.close()
    for i in range(len(first_list)):
        print "Checking Line: ".rjust(45)+str((i+1)), "\r",
        try:
            first_list[i] = first_list[i].strip("\n")
            first_list[i] = first_list[i].split("\t")
        except IndexError: continue
        for y in range(4):
            try:
                first_list[i][y] = first_list[i][y].lstrip(" ")
                first_list[i][y] = first_list[i][y].rstrip(" ")
                first_list[i][y] = first_list[i][y].strip("\"")
            except IndexError: pass
            try:
                if over !=i:
                    if first_list[i][y] == "":
                        errorcount += 1
                        er.append(i+1)
                        er_normal.append(i)
                        over = i
            except IndexError:
                if over !=i:
                    errorcount += 1
                    er.append(i+1)
                    er_normal.append(i)
                    over = i
    system("color 02")       
    system("cls")
    print start_screen
    print
    print "-=- Checking File for Errors... -=-".rjust(57)
    print
    if errorcount !=0:
        print "Total Errors: ".rjust(45)+str(errorcount)
        if len(er) <=4: print "Errors On Lines: ".rjust(45)+str(er)
        else: print "Errors On Lines: ".rjust(45)+str(er[:4])+"..."
        print
        print "\t      -=- Press [Enter] to Ignore  or  [Ctrl + C] to fix -=-"
        try:
            raw_input("\t\t\t\t\t...")
            break
        except KeyboardInterrupt:
            system("color 04")
            system("cls")
            print start_screen
            print
            print "-=- Fix it, Save it, Close it -=-".rjust(56)
            print
            if len(er) <= 4: print "Fix Lines: ".rjust(40)+str(er)
            else: print "Fix Lines: ".rjust(40)+str(er[:4])+"..."
            try:
                if exists("C:\\WINDOWS\\SYSTEM32\\notepad.exe"): system("notepad "+file_name)
                else: system("\""+file_name+"\"")
            except KeyboardInterrupt: pass
            print "\n"
            try: raw_input("\t\t\t       Press [Enter]...")
            except KeyboardInterrupt: pass        
    else:
        print
        print "-=- No Errors Found -=-".rjust(51)
        print
        try: raw_input("\t\t\t\t     ...")
        except KeyboardInterrupt: pass
        break
number_zero = 0
for z in er_normal:
    if z == 0:
        first_list.remove(first_list[z])
        number_zero += 1
    else:
        qwe = first_list.pop(z-number_zero)
        number_zero += 1
system("color 06")
system("cls")
print start_screen
print
print "-=- Formatting... Press [Ctrl + C] to Stop -=-".rjust(63)
print "\n"
chdir(folder_name)
try: prog = progressBar(0, len(first_list), 46)
except ZeroDivisionError:
    try:
        raw_input("\t\t\t      File Format Error...")
        exit()
    except KeyboardInterrupt: exit()
for j in range(len(first_list)):
    try:
        if isdir(first_list[j][3]) == False: mkdir(first_list[j][3])
        chdir(first_list[j][3])
        file_open = open(first_list[j][2]+".txt", "a")
        file_open.write(first_list[j][0]+"\t"+first_list[j][1]+"\n")
        file_open.close()
        chdir("..")
        if j+1 != len(first_list): prog.updateAmount(j)
        else: prog.updateAmount(len(first_list))
        print "\t\t "+str(prog), "\r",
    except KeyboardInterrupt:
        print
        try:
            print "\n"
            raw_input("\t\t\t\t    Stopped...")
            exit()
        except KeyboardInterrupt: exit()
try:
    print "\n"
    raw_input("\t\t\t\t   Finished...")
except KeyboardInterrupt: pass
