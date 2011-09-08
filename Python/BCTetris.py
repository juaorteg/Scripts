from pygame import*;D,b,u=display,list(bin(256)),'1';X=D.set_mode((160,320)).fill;E,l,F,S,p=enumerate,b*25+list(bin(2047)),[list(bin(int(x,36)).zfill(57))for x in'9hf 2i136 9hf 2i136 4qr 4qr 4qr 4qr 1l3 4zvur b2c 7hqm9 35z 4zxfm b2a 2i135 f 7w9g3r6 f fsiw7ic 4qu 4zxfl 4qu 4zxfl 2hxxf 6br 7hs76 b29'.split()],252,3
while p>2:
	p,d,f,S=-3,0,p%20,S-2;time.set_timer(2,S)
	while d-11:
		e=event.wait()
		if e.type==2:
			e=e.key;d,r=(11,-1,0,11,1)[(e&3)+(e>0)],f/4*4+(f+(e==273))%4;z=zip(l[p+d:],F[r]+[0]*230)
			if not(u,u)in z:p+=d;f,d=r,0;[X(-(u in j),((p+i-58)%11*16,(p+i-58)/11*16,16,16))for i,j in E(z)];D.flip()
	for i,j in E(F[f]):
		if j==u:l[p+i]=u
	for i in range(3,278,11):
		if l[i:i+10]==10*[u]:l=b+l[:i]+l[i+11:]
