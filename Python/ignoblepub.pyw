#! #! /usr/bin/python / Usr / bin / python 

 # ignobleepub.pyw, version 1-rc2 # Ignobleepub.pyw, version 1-rc2 

 # To run this program install Python 2.6 from <http://www.python.org/download/> # To run this program install Python 2.6 from <http://www.python.org/download/> 
 # and PyCrypto from http://www.voidspace.org.uk/python/modules.shtml#pycrypto # And PyCrypto from http://www.voidspace.org.uk/python/modules.shtml # pycrypto 
 # (make sure to install the version for Python 2.6). # (Make sure to install the version for Python 2.6). Save this script file as Save this script file as 
 # ignobleepub.pyw and double-click on it to run it. # Ignobleepub.pyw and double-click on it to run it. 

 # Revision history: # Revision history: 
 # 1 - Initial release # 1 - Initial release 

 #""" '"" 
 #Decrypt Barnes & Noble ADEPT encrypted EPUB books. Decrypt Barnes & Noble ADEPT encrypted EPUB books. 
 #""" '"" 

 from __future__ import with_statement from __future__ import with_statement 

 __license__ = 'GPL v3' __license__ = 'GPL v3' 

 import sys import sys 
 import os import os 
 import zlib import zlib 
 import zipfile import zipfile 
 from zipfile import ZipFile, ZIP_STORED, ZIP_DEFLATED from zipfile import ZipFile, ZIP_STORED, ZIP_DEFLATED 
 from contextlib import closing from contextlib import closing 
 import xml.etree.ElementTree as etree import xml.etree.ElementTree as etree 
 import Tkinter import Tkinter 
 import Tkconstants import Tkconstants 
 import tkFileDialog import tkFileDialog 
 import tkMessageBox import tkMessageBox 

 try: try: 
 from Crypto.Cipher import AES from Crypto.Cipher import AES 
 except ImportError: except ImportError: 
 AES = None AES = None 

 META_NAMES = ('mimetype', 'META-INF/rights.xml', 'META-INF/encryption.xml') META_NAMES = ('mimetype', 'META-INF/rights.xml', 'META-INF/encryption.xml') 
 NSMAP = {'adept': 'http://ns.adobe.com/adept', NSMAP = {'adept': 'http://ns.adobe.com/adept', 
 'enc': 'http://www.w3.org/2001/04/xmlenc#'} 'Enc': 'http://www.w3.org/2001/04/xmlenc #'} 

 class ZipInfo(zipfile.ZipInfo): class ZipInfo (zipfile.ZipInfo): 
 def __init__(self, *args, **kwargs): def __init__ (self, * args, ** kwargs): 
 if 'compress_type' in kwargs: if 'compress_type' in kwargs: 
 compress_type = kwargs.pop('compress_type') compress_type = kwargs.pop ('compress_type') 
 super(ZipInfo, self).__init__(*args, **kwargs) super (ZipInfo, self). __init__ (* args, ** kwargs) 
 self.compress_type = compress_type self.compress_type = compress_type 

 class Decryptor(object): Decryptor class (object): 
 def __init__(self, bookkey, encryption): def __init__ (self, bookkey, encryption): 
 enc = lambda tag: '{%s}%s' % (NSMAP['enc'], tag) enc = lambda tag: '{% s}% s'% (NSMAP ['enc'], tag) 
 self._aes = AES.new(bookkey, AES.MODE_CBC) self._aes = AES.new (bookkey, AES.MODE_CBC) 
 encryption = etree.fromstring(encryption) encryption = etree.fromstring (encryption) 
 self._encrypted = encrypted = set() self._encrypted = encrypted = set () 
 expr = './%s/%s/%s' % (enc('EncryptedData'), enc('CipherData'), expr = '. /% s /% s /% s'% (enc ('EncryptedData'), enc ('CipherData'), 
 enc('CipherReference')) enc ('CipherReference')) 
 for elem in encryption.findall(expr): for elem in encryption.findall (expr): 
 path = elem.get('URI', None) path = elem.get ('URI', None) 
 if path is not None: if path not is None: 
 encrypted.add(path) encrypted.add (path) 

 def decompress(self, bytes): def decompress (self, bytes): 
 dc = zlib.decompressobj(-15) dc = zlib.decompressobj (-15) 
 bytes = dc.decompress(bytes) bytes = dc.decompress (bytes) 
 ex = dc.decompress('Z') + dc.flush() ex = dc.decompress ('Z') + dc.flush () 
 if ex: if ex: 
 bytes = bytes + ex bytes = bytes + ex 
 return bytes return bytes 

 def decrypt(self, path, data): def decrypt (self, path, data): 
 if path in self._encrypted: if path in self._encrypted: 
 data = self._aes.decrypt(data)[16:] data = self._aes.decrypt (data) [16:] 
 data = data[:-ord(data[-1])] data = data [:-ord (data [-1])] 
 data = self.decompress(data) data = self.decompress (data) 
 return data return data 


 class ADEPTError(Exception): class ADEPTError (Exception): 
 pass pass 

 def cli_main(argv=sys.argv): def cli_main (argv = sys.argv): 
 progname = os.path.basename(argv[0]) progname = os.path.basename (argv [0]) 
 if AES is None: if AES is None: 
 print "%s: This script requires PyCrypto, which must be installed " \ print "% s: This script requires PyCrypto, which must be installed" \ 
 "separately. Read the top-of-script comment for details." "Separately. Read the top-of-script comment for details." % \ % \ 
 (progname,) (Progname) 
 return 1 return 1 
 if len(argv) != 4: if len (argv)! = 4: 
 print "usage: %s KEYFILE INBOOK OUTBOOK" % (progname,) print "usage:% s KEYFILE INBOOK OUTBOOK"% (progname,) 
 return 1 return 1 
 keypath, inpath, outpath = argv[1:] keypath, inpath, outpath = argv [1:] 
 with open(keypath, 'rb') as f: with open (keypath, 'rb') as f: 
 keyb64 = f.read() keyb64 = f.read () 
 key = keyb64.decode('base64')[:16] key = keyb64.decode ('base64') [: 16] 
 aes = AES.new(key, AES.MODE_CBC) aes = AES.new (key, AES.MODE_CBC) 
 with closing(ZipFile(open(inpath, 'rb'))) as inf: with closing (ZipFile (open (inpath, 'rb'))) as inf: 
 namelist = set(inf.namelist()) namelist = set (inf.namelist ()) 
 if 'META-INF/rights.xml' not in namelist or \ if 'META-INF/rights.xml' not in namelist or \ 
 'META-INF/encryption.xml' not in namelist: 'META-INF/encryption.xml' not in namelist: 
 raise ADEPTError('%s: not an B&N ADEPT EPUB' % (inpath,)) raise ADEPTError ('% s: not an B & N ADEPT EPUB'% (inpath,)) 
 for name in META_NAMES: for name in META_NAMES: 
 namelist.remove(name) namelist.remove (name) 
 rights = etree.fromstring(inf.read('META-INF/rights.xml')) rights = etree.fromstring (inf.read ('META-INF/rights.xml')) 
 adept = lambda tag: '{%s}%s' % (NSMAP['adept'], tag) adept = lambda tag: '{% s}% s'% (NSMAP ['adept'], tag) 
 expr = './/%s' % (adept('encryptedKey'),) expr ='.//% s'% (adept ('encryptedKey'),) 
 bookkey = ''.join(rights.findtext(expr)) bookkey =''. join (rights.findtext (expr)) 
 bookkey = aes.decrypt(bookkey.decode('base64')) bookkey = aes.decrypt (bookkey.decode ('base64')) 
 bookkey = bookkey[:-ord(bookkey[-1])] bookkey = bookkey [:-ord (bookkey [-1])] 
 encryption = inf.read('META-INF/encryption.xml') encryption = inf.read ('META-INF/encryption.xml') 
 decryptor = Decryptor(bookkey[-16:], encryption) decryptor = Decryptor (bookkey [-16:], encryption) 
 kwds = dict(compression=ZIP_DEFLATED, allowZip64=False) kwds = dict (compression = ZIP_DEFLATED, allowZip64 = False) 
 with closing(ZipFile(open(outpath, 'wb'), 'w', **kwds)) as outf: with closing (ZipFile (open (outpath, 'wb'), 'w', ** kwds)) as outf: 
 zi = ZipInfo('mimetype', compress_type=ZIP_STORED) zi = ZipInfo ('mimetype', compress_type = ZIP_STORED) 
 outf.writestr(zi, inf.read('mimetype')) outf.writestr (zi, inf.read ('mimetype')) 
 for path in namelist: for path in namelist: 
 data = inf.read(path) data = inf.read (path) 
 outf.writestr(path, decryptor.decrypt(path, data)) outf.writestr (path, decryptor.decrypt (path, data)) 
 return 0 return 0 


 class DecryptionDialog(Tkinter.Frame): class DecryptionDialog (Tkinter.Frame): 
 def __init__(self, root): def __init__ (self, root): 
 Tkinter.Frame.__init__(self, root, border=5) Tkinter.Frame.__init__ (self, root, border = 5) 
 self.status = Tkinter.Label(self, text='Select files for decryption') self.status = Tkinter.Label (self, text = 'Select files for decryption') 
 self.status.pack(fill=Tkconstants.X, expand=1) self.status.pack (fill = Tkconstants.X, expand = 1) 
 body = Tkinter.Frame(self) body = Tkinter.Frame (self) 
 body.pack(fill=Tkconstants.X, expand=1) body.pack (fill = Tkconstants.X, expand = 1) 
 sticky = Tkconstants.E + Tkconstants.W sticky = Tkconstants.E + Tkconstants.W 
 body.grid_columnconfigure(1, weight=2) body.grid_columnconfigure (1, weight = 2) 
 Tkinter.Label(body, text='Key file').grid(row=0) Tkinter.Label (body, text = 'Key file'). Grid (row = 0) 
 self.keypath = Tkinter.Entry(body, width=30) self.keypath = Tkinter.Entry (body, width = 30) 
 self.keypath.grid(row=0, column=1, sticky=sticky) self.keypath.grid (row = 0, column = 1, sticky = sticky) 
 if os.path.exists('bnepubkey.b64'): if os.path.exists ('bnepubkey.b64'): 
 self.keypath.insert(0, 'bnepubkey.b64') self.keypath.insert (0, 'bnepubkey.b64') 
 button = Tkinter.Button(body, text="...", command=self.get_keypath) button = Tkinter.Button (body, text ="...", command = self.get_keypath) 
 button.grid(row=0, column=2) button.grid (row = 0, column = 2) 
 Tkinter.Label(body, text='Input file').grid(row=1) Tkinter.Label (body, text = 'Input file'). Grid (row = 1) 
 self.inpath = Tkinter.Entry(body, width=30) self.inpath = Tkinter.Entry (body, width = 30) 
 self.inpath.grid(row=1, column=1, sticky=sticky) self.inpath.grid (row = 1, column = 1, sticky = sticky) 
 button = Tkinter.Button(body, text="...", command=self.get_inpath) button = Tkinter.Button (body, text ="...", command = self.get_inpath) 
 button.grid(row=1, column=2) button.grid (row = 1, column = 2) 
 Tkinter.Label(body, text='Output file').grid(row=2) Tkinter.Label (body, text = 'Output file'). Grid (row = 2) 
 self.outpath = Tkinter.Entry(body, width=30) self.outpath = Tkinter.Entry (body, width = 30) 
 self.outpath.grid(row=2, column=1, sticky=sticky) self.outpath.grid (row = 2, column = 1, sticky = sticky) 
 button = Tkinter.Button(body, text="...", command=self.get_outpath) button = Tkinter.Button (body, text ="...", command = self.get_outpath) 
 button.grid(row=2, column=2) button.grid (row = 2, column = 2) 
 buttons = Tkinter.Frame(self) buttons = Tkinter.Frame (self) 
 buttons.pack() buttons.pack () 
 botton = Tkinter.Button( botton = Tkinter.Button ( 
 buttons, text="Decrypt", width=10, command=self.decrypt) buttons, text = "Decrypt", width = 10, command = self.decrypt) 
 botton.pack(side=Tkconstants.LEFT) botton.pack (side = Tkconstants.LEFT) 
 Tkinter.Frame(buttons, width=10).pack(side=Tkconstants.LEFT) Tkinter.Frame (buttons, width = 10). Pack (side = Tkconstants.LEFT) 
 button = Tkinter.Button( button = Tkinter.Button ( 
 buttons, text="Quit", width=10, command=self.quit) buttons, text = "Quit", width = 10, command = self.quit) 
 button.pack(side=Tkconstants.RIGHT) button.pack (side = Tkconstants.RIGHT) 

 def get_keypath(self): def get_keypath (self): 
 keypath = tkFileDialog.askopenfilename( keypath = tkFileDialog.askopenfilename ( 
 parent=None, title='Select B&N EPUB key file', parent = None, title = 'Select B & N EPUB key file, 
 defaultextension='.b64', defaultextension = '. b64', 
 filetypes=[('base64-encoded files', '.b64'), filetypes = [('base64-encoded files', '. b64'), 
 ('All Files', '.*')]) ('All Files','.*')]) 
 if keypath: if keypath: 
 keypath = os.path.normpath(keypath) keypath = os.path.normpath (keypath) 
 self.keypath.delete(0, Tkconstants.END) self.keypath.delete (0, Tkconstants.END) 
 self.keypath.insert(0, keypath) self.keypath.insert (0, keypath) 
 return return 

 def get_inpath(self): def get_inpath (self): 
 inpath = tkFileDialog.askopenfilename( inpath = tkFileDialog.askopenfilename ( 
 parent=None, title='Select B&N-encrypted EPUB file to decrypt', parent = None, title = 'Select B & N-encrypted EPUB file to decrypt', 
 defaultextension='.epub', filetypes=[('EPUB files', '.epub'), defaultextension = '. epub', filetypes = [('EPUB files', '. epub'), 
 ('All files', '.*')]) ('All files','.*')]) 
 if inpath: if inpath: 
 inpath = os.path.normpath(inpath) inpath = os.path.normpath (inpath) 
 self.inpath.delete(0, Tkconstants.END) self.inpath.delete (0, Tkconstants.END) 
 self.inpath.insert(0, inpath) self.inpath.insert (0, inpath) 
 return return 

 def get_outpath(self): def get_outpath (self): 
 outpath = tkFileDialog.asksaveasfilename( outpath = tkFileDialog.asksaveasfilename ( 
 parent=None, title='Select unencrypted EPUB file to produce', parent = None, title = 'Select unencrypted EPUB file to produce', 
 defaultextension='.epub', filetypes=[('EPUB files', '.epub'), defaultextension = '. epub', filetypes = [('EPUB files', '. epub'), 
 ('All files', '.*')]) ('All files','.*')]) 
 if outpath: if outpath: 
 outpath = os.path.normpath(outpath) outpath = os.path.normpath (outpath) 
 self.outpath.delete(0, Tkconstants.END) self.outpath.delete (0, Tkconstants.END) 
 self.outpath.insert(0, outpath) self.outpath.insert (0, outpath) 
 return return 

 def decrypt(self): def decrypt (self): 
 keypath = self.keypath.get() keypath = self.keypath.get () 
 inpath = self.inpath.get() inpath = self.inpath.get () 
 outpath = self.outpath.get() outpath = self.outpath.get () 
 if not keypath or not os.path.exists(keypath): if not keypath or not os.path.exists (keypath): 
 self.status['text'] = 'Specified key file does not exist' self.status ['text'] = 'Specified key file does not exist' 
 return return 
 if not inpath or not os.path.exists(inpath): if not inpath or not os.path.exists (inpath): 
 self.status['text'] = 'Specified input file does not exist' self.status ['text'] = 'Specified input file does not exist' 
 return return 
 if not outpath: if not outpath: 
 self.status['text'] = 'Output file not specified' self.status ['text'] = 'Output file not specified' 
 return return 
 if inpath == outpath: if inpath == outpath: 
 self.status['text'] = 'Must have different input and output files' self.status ['text'] = 'Must have different input and output files' 
 return return 
 argv = [sys.argv[0], keypath, inpath, outpath] argv = [sys.argv [0], keypath, inpath, outpath] 
 self.status['text'] = 'Decrypting...' self.status ['text'] = 'Decrypting ...' 
 try: try: 
 cli_main(argv) cli_main (argv) 
 except Exception, e: except Exception, e: 
 self.status['text'] = 'Error: ' + str(e) self.status ['text'] = 'Error:' + str (e) 
 return return 
 self.status['text'] = 'File successfully decrypted' self.status ['text'] = 'File successfully decrypted' 

 def gui_main(): def gui_main (); 
 root = Tkinter.Tk() root = Tkinter.Tk () 
 if AES is None: if AES is None: 
 root.withdraw() root.withdraw () 
 tkMessageBox.showerror( tkMessageBox.showerror ( 
 "Ignoble EPUB Decrypter", "Ignoble EPUB Decrypter", 
 "This script requires PyCrypto, which must be installed " "This script requires PyCrypto, which must be installed" 
 "separately. Read the top-of-script comment for details.") "Separately. Read the top-of-script comment for details.) 
 return 1 return 1 
 root.title('Ignoble EPUB Decrypter') root.title ('Ignoble EPUB Decrypter') 
 root.resizable(True, False) root.resizable (True, False) 
 root.minsize(300, 0) root.minsize (300, 0) 
 DecryptionDialog(root).pack(fill=Tkconstants.X, expand=1) DecryptionDialog (root). Pack (fill = Tkconstants.X, expand = 1) 
 root.mainloop() root.mainloop () 
 return 0 return 0 

 if __name__ == '__main__': if __name__ == '__main__': 
 if len(sys.argv) > 1: if len (sys.argv)> 1: 
 sys.exit(cli_main()) sys.exit (cli_main ()) 
 sys.exit(gui_main()) sys.exit (gui_main ()) 

Original Hebrew text:
# To run this program install Python 2.6 from <http://www.python.org/download/>
Contribute a better translation
