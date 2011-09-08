#! #! /usr/bin/python / Usr / bin / python 

 # ignoblekeygen.pyw, version 1 # Ignoblekeygen.pyw, version 1 

 # To run this program install Python 2.6 from <http://www.python.org/download/> # To run this program install Python 2.6 from <http://www.python.org/download/> 
 # and PyCrypto from http://www.voidspace.org.uk/python/modules.shtml#pycrypto # And PyCrypto from http://www.voidspace.org.uk/python/modules.shtml # pycrypto 
 # (make sure to install the version for Python 2.6). # (Make sure to install the version for Python 2.6). Save this script file as Save this script file as 
 # ignoblekeygen.pyw and double-click on it to run it. # Ignoblekeygen.pyw and double-click on it to run it. 

 # Revision history: # Revision history: 
 # 1 - Initial release # 1 - Initial release 

# """ '"" 
# Generate Barnes & Noble EPUB user key from name and credit card number. Generate Barnes & Noble EPUB user name and key from credit card number. 
# """ '"" 

 from __future__ import with_statement from __future__ import with_statement 

 __license__ = 'GPL v3' __license__ = 'GPL v3' 

 import sys import sys 
 import os import os 
 import hashlib import hashlib 
 import Tkinter import Tkinter 
 import Tkconstants import Tkconstants 
 import tkFileDialog import tkFileDialog 
 import tkMessageBox import tkMessageBox 

 try: try: 
  from Crypto.Cipher import AES from Crypto.Cipher import AES 
 except ImportError: except ImportError: 
  AES = None AES = None 

 def normalize_name(name): def normalize_name (name): 
  return ''.join(x for x in name.lower() if x != ' ') return''. join (x for x in name.lower () if x! = '') 

 def generate_keyfile(name, ccn, outpath): def generate_keyfile (name, ccn, outpath): 
  name = normalize_name(name) + '\x00' name = normalize_name (name) + '\ x00' 
  ccn = ccn + '\x00' ccn = ccn + '\ x00' 
  name_sha = hashlib.sha1(name).digest()[:16] name_sha = hashlib.sha1 (name). digest () [: 16] 
  ccn_sha = hashlib.sha1(ccn).digest()[:16] ccn_sha = hashlib.sha1 (ccn). digest () [: 16] 
  both_sha = hashlib.sha1(name + ccn).digest() both_sha = hashlib.sha1 (name + ccn). digest () 
  aes = AES.new(ccn_sha, AES.MODE_CBC, name_sha) aes = AES.new (ccn_sha, AES.MODE_CBC, name_sha) 
  crypt = aes.encrypt(both_sha + ('\x0c' * 0x0c)) crypt = aes.encrypt (both_sha + ('\ x0c' * 0x0c)) 
  userkey = hashlib.sha1(crypt).digest() userkey = hashlib.sha1 (crypt). digest () 
  with open(outpath, 'wb') as f: with open (outpath, 'wb') as f: 
  f.write(userkey.encode('base64')) f.write (userkey.encode ('base64')) 
  return userkey return userkey 

 def cli_main(argv=sys.argv): def cli_main (argv = sys.argv): 
  progname = os.path.basename(argv[0]) progname = os.path.basename (argv [0]) 
  if AES is None: if AES is None: 
  print "%s: This script requires PyCrypto, which must be installed " \ print "% s: This script requires PyCrypto, which must be installed" \ 
  "separately. Read the top-of-script comment for details." "Separately. Read the top-of-script comment for details." % \ % \ 
  (progname,) (Progname) 
  return 1 return 1 
  if len(argv) != 4: if len (argv)! = 4: 
  print "usage: %s NAME CC# OUTFILE" % (progname,) print "usage:% s NAME CC # OUTFILE"% (progname,) 
  return 1 return 1 
  name, ccn, outpath = argv[1:] name, ccn, outpath = argv [1:] 
  generate_keyfile(name, ccn, outpath) generate_keyfile (name, ccn, outpath) 
  return 0 return 0 

 class DecryptionDialog(Tkinter.Frame): class DecryptionDialog (Tkinter.Frame): 
  def __init__(self, root): def __init__ (self, root): 
  Tkinter.Frame.__init__(self, root, border=5) Tkinter.Frame.__init__ (self, root, border = 5) 
  self.status = Tkinter.Label(self, text='Enter parameters') self.status = Tkinter.Label (self, text = 'Enter parameters') 
  self.status.pack(fill=Tkconstants.X, expand=1) self.status.pack (fill = Tkconstants.X, expand = 1) 
  body = Tkinter.Frame(self) body = Tkinter.Frame (self) 
  body.pack(fill=Tkconstants.X, expand=1) body.pack (fill = Tkconstants.X, expand = 1) 
  sticky = Tkconstants.E + Tkconstants.W sticky = Tkconstants.E + Tkconstants.W 
  body.grid_columnconfigure(1, weight=2) body.grid_columnconfigure (1, weight = 2) 
  Tkinter.Label(body, text='Name').grid(row=1) Tkinter.Label (body, text = 'Name'). Grid (row = 1) 
  self.name = Tkinter.Entry(body, width=30) self.name = Tkinter.Entry (body, width = 30) 
  self.name.grid(row=1, column=1, sticky=sticky) self.name.grid (row = 1, column = 1, sticky = sticky) 
  Tkinter.Label(body, text='CC#').grid(row=2) Tkinter.Label (body, text = 'CC #'). Grid (row = 2) 
  self.ccn = Tkinter.Entry(body, width=30) self.ccn = Tkinter.Entry (body, width = 30) 
  self.ccn.grid(row=2, column=1, sticky=sticky) self.ccn.grid (row = 2, column = 1, sticky = sticky) 
  Tkinter.Label(body, text='Output file').grid(row=0) Tkinter.Label (body, text = 'Output file'). Grid (row = 0) 
  self.keypath = Tkinter.Entry(body, width=30) self.keypath = Tkinter.Entry (body, width = 30) 
  self.keypath.grid(row=0, column=1, sticky=sticky) self.keypath.grid (row = 0, column = 1, sticky = sticky) 
  self.keypath.insert(0, 'bnepubkey.b64') self.keypath.insert (0, 'bnepubkey.b64') 
  button = Tkinter.Button(body, text="...", command=self.get_keypath) button = Tkinter.Button (body, text ="...", command = self.get_keypath) 
  button.grid(row=0, column=2) button.grid (row = 0, column = 2) 
  buttons = Tkinter.Frame(self) buttons = Tkinter.Frame (self) 
  buttons.pack() buttons.pack () 
  botton = Tkinter.Button( botton = Tkinter.Button ( 
  buttons, text="Generate", width=10, command=self.generate) buttons, text = "Generate", width = 10, command = self.generate) 
  botton.pack(side=Tkconstants.LEFT) botton.pack (side = Tkconstants.LEFT) 
  Tkinter.Frame(buttons, width=10).pack(side=Tkconstants.LEFT) Tkinter.Frame (buttons, width = 10). Pack (side = Tkconstants.LEFT) 
  button = Tkinter.Button( button = Tkinter.Button ( 
  buttons, text="Quit", width=10, command=self.quit) buttons, text = "Quit", width = 10, command = self.quit) 
  button.pack(side=Tkconstants.RIGHT) button.pack (side = Tkconstants.RIGHT) 

  def get_keypath(self): def get_keypath (self): 
  keypath = tkFileDialog.asksaveasfilename( keypath = tkFileDialog.asksaveasfilename ( 
  parent=None, title='Select B&N EPUB key file to produce', parent = None, title = 'Select B & N EPUB key file to produce, 
  defaultextension='.b64', defaultextension = '. b64', 
  filetypes=[('base64-encoded files', '.b64'), filetypes = [('base64-encoded files', '. b64'), 
  ('All Files', '.*')]) ('All Files','.*')]) 
  if keypath: if keypath: 
  keypath = os.path.normpath(keypath) keypath = os.path.normpath (keypath) 
  self.keypath.delete(0, Tkconstants.END) self.keypath.delete (0, Tkconstants.END) 
  self.keypath.insert(0, keypath) self.keypath.insert (0, keypath) 
  return return 

  def generate(self): def generate (self): 
  name = self.name.get() name = self.name.get () 
  ccn = self.ccn.get() ccn = self.ccn.get () 
  keypath = self.keypath.get() keypath = self.keypath.get () 
  if not name: if not name: 
  self.status['text'] = 'Name not specified' self.status ['text'] = 'Name not specified' 
  return return 
  if not ccn: if not ccn: 
  self.status['text'] = 'Credit card number not specified' self.status ['text'] = 'Credit card number not specified' 
  return return 
  if not keypath: if not keypath: 
  self.status['text'] = 'Output keyfile path not specified' self.status ['text'] = 'Output keyfile path not specified' 
  return return 
  self.status['text'] = 'Generating...' self.status ['text'] = 'Generating ...' 
  try: try: 
  generate_keyfile(name, ccn, keypath) generate_keyfile (name, ccn, keypath) 
  except Exception, e: except Exception, e: 
  self.status['text'] = 'Error: ' + str(e) self.status ['text'] = 'Error:' + str (e) 
  return return 
  self.status['text'] = 'Keyfile successfully generated' self.status ['text'] = 'Keyfile successfully generated' 

 def gui_main(): def gui_main (); 
  root = Tkinter.Tk() root = Tkinter.Tk () 
  if AES is None: if AES is None: 
  root.withdraw() root.withdraw () 
  tkMessageBox.showerror( tkMessageBox.showerror ( 
  "Ignoble EPUB Keyfile Generator", "Ignoble EPUB Keyfile Generator", 
  "This script requires PyCrypto, which must be installed " "This script requires PyCrypto, which must be installed" 
  "separately. Read the top-of-script comment for details.") "Separately. Read the top-of-script comment for details.) 
  return 1 return 1 
  root.title('Ignoble EPUB Keyfile Generator') root.title ('Ignoble EPUB Keyfile Generator') 
  root.resizable(True, False) root.resizable (True, False) 
  root.minsize(300, 0) root.minsize (300, 0) 
  DecryptionDialog(root).pack(fill=Tkconstants.X, expand=1) DecryptionDialog (root). Pack (fill = Tkconstants.X, expand = 1) 
  root.mainloop() root.mainloop () 
  return 0 return 0 

 if __name__ == '__main__': if __name__ == '__main__': 
  if len(sys.argv) > 1: if len (sys.argv)> 1: 
  sys.exit(cli_main()) sys.exit (cli_main ()) 
  sys.exit(gui_main()) sys.exit (gui_main ()) 

