
obj/user/pingpong.debug:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 8d 00 00 00       	call   8000be <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
	envid_t who;

	if ((who = fork()) != 0) {
  80003c:	e8 3c 0e 00 00       	call   800e7d <fork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	74 27                	je     80006f <umain+0x3c>
  800048:	89 c3                	mov    %eax,%ebx
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  80004a:	e8 ac 0a 00 00       	call   800afb <sys_getenvid>
  80004f:	83 ec 04             	sub    $0x4,%esp
  800052:	53                   	push   %ebx
  800053:	50                   	push   %eax
  800054:	68 20 21 80 00       	push   $0x802120
  800059:	e8 53 01 00 00       	call   8001b1 <cprintf>
		ipc_send(who, 0, 0, 0);
  80005e:	6a 00                	push   $0x0
  800060:	6a 00                	push   $0x0
  800062:	6a 00                	push   $0x0
  800064:	ff 75 e4             	pushl  -0x1c(%ebp)
  800067:	e8 6f 0f 00 00       	call   800fdb <ipc_send>
  80006c:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  80006f:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800072:	83 ec 04             	sub    $0x4,%esp
  800075:	6a 00                	push   $0x0
  800077:	6a 00                	push   $0x0
  800079:	56                   	push   %esi
  80007a:	e8 f3 0e 00 00       	call   800f72 <ipc_recv>
  80007f:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  800081:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800084:	e8 72 0a 00 00       	call   800afb <sys_getenvid>
  800089:	57                   	push   %edi
  80008a:	53                   	push   %ebx
  80008b:	50                   	push   %eax
  80008c:	68 36 21 80 00       	push   $0x802136
  800091:	e8 1b 01 00 00       	call   8001b1 <cprintf>
		if (i == 10)
  800096:	83 c4 20             	add    $0x20,%esp
  800099:	83 fb 0a             	cmp    $0xa,%ebx
  80009c:	74 18                	je     8000b6 <umain+0x83>
			return;
		i++;
  80009e:	83 c3 01             	add    $0x1,%ebx
		ipc_send(who, i, 0, 0);
  8000a1:	6a 00                	push   $0x0
  8000a3:	6a 00                	push   $0x0
  8000a5:	53                   	push   %ebx
  8000a6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000a9:	e8 2d 0f 00 00       	call   800fdb <ipc_send>
		if (i == 10)
  8000ae:	83 c4 10             	add    $0x10,%esp
  8000b1:	83 fb 0a             	cmp    $0xa,%ebx
  8000b4:	75 bc                	jne    800072 <umain+0x3f>
			return;
	}

}
  8000b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000b9:	5b                   	pop    %ebx
  8000ba:	5e                   	pop    %esi
  8000bb:	5f                   	pop    %edi
  8000bc:	5d                   	pop    %ebp
  8000bd:	c3                   	ret    

008000be <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000be:	55                   	push   %ebp
  8000bf:	89 e5                	mov    %esp,%ebp
  8000c1:	56                   	push   %esi
  8000c2:	53                   	push   %ebx
  8000c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000c6:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000c9:	e8 2d 0a 00 00       	call   800afb <sys_getenvid>
  8000ce:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000d3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000d6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000db:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e0:	85 db                	test   %ebx,%ebx
  8000e2:	7e 07                	jle    8000eb <libmain+0x2d>
		binaryname = argv[0];
  8000e4:	8b 06                	mov    (%esi),%eax
  8000e6:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000eb:	83 ec 08             	sub    $0x8,%esp
  8000ee:	56                   	push   %esi
  8000ef:	53                   	push   %ebx
  8000f0:	e8 3e ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000f5:	e8 0a 00 00 00       	call   800104 <exit>
}
  8000fa:	83 c4 10             	add    $0x10,%esp
  8000fd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800100:	5b                   	pop    %ebx
  800101:	5e                   	pop    %esi
  800102:	5d                   	pop    %ebp
  800103:	c3                   	ret    

00800104 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80010a:	e8 24 11 00 00       	call   801233 <close_all>
	sys_env_destroy(0);
  80010f:	83 ec 0c             	sub    $0xc,%esp
  800112:	6a 00                	push   $0x0
  800114:	e8 a1 09 00 00       	call   800aba <sys_env_destroy>
}
  800119:	83 c4 10             	add    $0x10,%esp
  80011c:	c9                   	leave  
  80011d:	c3                   	ret    

0080011e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80011e:	55                   	push   %ebp
  80011f:	89 e5                	mov    %esp,%ebp
  800121:	53                   	push   %ebx
  800122:	83 ec 04             	sub    $0x4,%esp
  800125:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800128:	8b 13                	mov    (%ebx),%edx
  80012a:	8d 42 01             	lea    0x1(%edx),%eax
  80012d:	89 03                	mov    %eax,(%ebx)
  80012f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800132:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800136:	3d ff 00 00 00       	cmp    $0xff,%eax
  80013b:	75 1a                	jne    800157 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80013d:	83 ec 08             	sub    $0x8,%esp
  800140:	68 ff 00 00 00       	push   $0xff
  800145:	8d 43 08             	lea    0x8(%ebx),%eax
  800148:	50                   	push   %eax
  800149:	e8 2f 09 00 00       	call   800a7d <sys_cputs>
		b->idx = 0;
  80014e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800154:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800157:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80015b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80015e:	c9                   	leave  
  80015f:	c3                   	ret    

00800160 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800169:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800170:	00 00 00 
	b.cnt = 0;
  800173:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80017a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80017d:	ff 75 0c             	pushl  0xc(%ebp)
  800180:	ff 75 08             	pushl  0x8(%ebp)
  800183:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800189:	50                   	push   %eax
  80018a:	68 1e 01 80 00       	push   $0x80011e
  80018f:	e8 54 01 00 00       	call   8002e8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800194:	83 c4 08             	add    $0x8,%esp
  800197:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80019d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001a3:	50                   	push   %eax
  8001a4:	e8 d4 08 00 00       	call   800a7d <sys_cputs>

	return b.cnt;
}
  8001a9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001af:	c9                   	leave  
  8001b0:	c3                   	ret    

008001b1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001b1:	55                   	push   %ebp
  8001b2:	89 e5                	mov    %esp,%ebp
  8001b4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001b7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001ba:	50                   	push   %eax
  8001bb:	ff 75 08             	pushl  0x8(%ebp)
  8001be:	e8 9d ff ff ff       	call   800160 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001c3:	c9                   	leave  
  8001c4:	c3                   	ret    

008001c5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c5:	55                   	push   %ebp
  8001c6:	89 e5                	mov    %esp,%ebp
  8001c8:	57                   	push   %edi
  8001c9:	56                   	push   %esi
  8001ca:	53                   	push   %ebx
  8001cb:	83 ec 1c             	sub    $0x1c,%esp
  8001ce:	89 c7                	mov    %eax,%edi
  8001d0:	89 d6                	mov    %edx,%esi
  8001d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001db:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001de:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001e1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001e9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001ec:	39 d3                	cmp    %edx,%ebx
  8001ee:	72 05                	jb     8001f5 <printnum+0x30>
  8001f0:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001f3:	77 45                	ja     80023a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001f5:	83 ec 0c             	sub    $0xc,%esp
  8001f8:	ff 75 18             	pushl  0x18(%ebp)
  8001fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8001fe:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800201:	53                   	push   %ebx
  800202:	ff 75 10             	pushl  0x10(%ebp)
  800205:	83 ec 08             	sub    $0x8,%esp
  800208:	ff 75 e4             	pushl  -0x1c(%ebp)
  80020b:	ff 75 e0             	pushl  -0x20(%ebp)
  80020e:	ff 75 dc             	pushl  -0x24(%ebp)
  800211:	ff 75 d8             	pushl  -0x28(%ebp)
  800214:	e8 67 1c 00 00       	call   801e80 <__udivdi3>
  800219:	83 c4 18             	add    $0x18,%esp
  80021c:	52                   	push   %edx
  80021d:	50                   	push   %eax
  80021e:	89 f2                	mov    %esi,%edx
  800220:	89 f8                	mov    %edi,%eax
  800222:	e8 9e ff ff ff       	call   8001c5 <printnum>
  800227:	83 c4 20             	add    $0x20,%esp
  80022a:	eb 18                	jmp    800244 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80022c:	83 ec 08             	sub    $0x8,%esp
  80022f:	56                   	push   %esi
  800230:	ff 75 18             	pushl  0x18(%ebp)
  800233:	ff d7                	call   *%edi
  800235:	83 c4 10             	add    $0x10,%esp
  800238:	eb 03                	jmp    80023d <printnum+0x78>
  80023a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80023d:	83 eb 01             	sub    $0x1,%ebx
  800240:	85 db                	test   %ebx,%ebx
  800242:	7f e8                	jg     80022c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800244:	83 ec 08             	sub    $0x8,%esp
  800247:	56                   	push   %esi
  800248:	83 ec 04             	sub    $0x4,%esp
  80024b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80024e:	ff 75 e0             	pushl  -0x20(%ebp)
  800251:	ff 75 dc             	pushl  -0x24(%ebp)
  800254:	ff 75 d8             	pushl  -0x28(%ebp)
  800257:	e8 54 1d 00 00       	call   801fb0 <__umoddi3>
  80025c:	83 c4 14             	add    $0x14,%esp
  80025f:	0f be 80 53 21 80 00 	movsbl 0x802153(%eax),%eax
  800266:	50                   	push   %eax
  800267:	ff d7                	call   *%edi
}
  800269:	83 c4 10             	add    $0x10,%esp
  80026c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026f:	5b                   	pop    %ebx
  800270:	5e                   	pop    %esi
  800271:	5f                   	pop    %edi
  800272:	5d                   	pop    %ebp
  800273:	c3                   	ret    

00800274 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800274:	55                   	push   %ebp
  800275:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800277:	83 fa 01             	cmp    $0x1,%edx
  80027a:	7e 0e                	jle    80028a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80027c:	8b 10                	mov    (%eax),%edx
  80027e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800281:	89 08                	mov    %ecx,(%eax)
  800283:	8b 02                	mov    (%edx),%eax
  800285:	8b 52 04             	mov    0x4(%edx),%edx
  800288:	eb 22                	jmp    8002ac <getuint+0x38>
	else if (lflag)
  80028a:	85 d2                	test   %edx,%edx
  80028c:	74 10                	je     80029e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80028e:	8b 10                	mov    (%eax),%edx
  800290:	8d 4a 04             	lea    0x4(%edx),%ecx
  800293:	89 08                	mov    %ecx,(%eax)
  800295:	8b 02                	mov    (%edx),%eax
  800297:	ba 00 00 00 00       	mov    $0x0,%edx
  80029c:	eb 0e                	jmp    8002ac <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80029e:	8b 10                	mov    (%eax),%edx
  8002a0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a3:	89 08                	mov    %ecx,(%eax)
  8002a5:	8b 02                	mov    (%edx),%eax
  8002a7:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002ac:	5d                   	pop    %ebp
  8002ad:	c3                   	ret    

008002ae <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002ae:	55                   	push   %ebp
  8002af:	89 e5                	mov    %esp,%ebp
  8002b1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002b4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002b8:	8b 10                	mov    (%eax),%edx
  8002ba:	3b 50 04             	cmp    0x4(%eax),%edx
  8002bd:	73 0a                	jae    8002c9 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002bf:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002c2:	89 08                	mov    %ecx,(%eax)
  8002c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c7:	88 02                	mov    %al,(%edx)
}
  8002c9:	5d                   	pop    %ebp
  8002ca:	c3                   	ret    

008002cb <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002cb:	55                   	push   %ebp
  8002cc:	89 e5                	mov    %esp,%ebp
  8002ce:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002d1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002d4:	50                   	push   %eax
  8002d5:	ff 75 10             	pushl  0x10(%ebp)
  8002d8:	ff 75 0c             	pushl  0xc(%ebp)
  8002db:	ff 75 08             	pushl  0x8(%ebp)
  8002de:	e8 05 00 00 00       	call   8002e8 <vprintfmt>
	va_end(ap);
}
  8002e3:	83 c4 10             	add    $0x10,%esp
  8002e6:	c9                   	leave  
  8002e7:	c3                   	ret    

008002e8 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002e8:	55                   	push   %ebp
  8002e9:	89 e5                	mov    %esp,%ebp
  8002eb:	57                   	push   %edi
  8002ec:	56                   	push   %esi
  8002ed:	53                   	push   %ebx
  8002ee:	83 ec 2c             	sub    $0x2c,%esp
  8002f1:	8b 75 08             	mov    0x8(%ebp),%esi
  8002f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002f7:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002fa:	eb 12                	jmp    80030e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002fc:	85 c0                	test   %eax,%eax
  8002fe:	0f 84 89 03 00 00    	je     80068d <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800304:	83 ec 08             	sub    $0x8,%esp
  800307:	53                   	push   %ebx
  800308:	50                   	push   %eax
  800309:	ff d6                	call   *%esi
  80030b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80030e:	83 c7 01             	add    $0x1,%edi
  800311:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800315:	83 f8 25             	cmp    $0x25,%eax
  800318:	75 e2                	jne    8002fc <vprintfmt+0x14>
  80031a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80031e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800325:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80032c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800333:	ba 00 00 00 00       	mov    $0x0,%edx
  800338:	eb 07                	jmp    800341 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80033d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800341:	8d 47 01             	lea    0x1(%edi),%eax
  800344:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800347:	0f b6 07             	movzbl (%edi),%eax
  80034a:	0f b6 c8             	movzbl %al,%ecx
  80034d:	83 e8 23             	sub    $0x23,%eax
  800350:	3c 55                	cmp    $0x55,%al
  800352:	0f 87 1a 03 00 00    	ja     800672 <vprintfmt+0x38a>
  800358:	0f b6 c0             	movzbl %al,%eax
  80035b:	ff 24 85 a0 22 80 00 	jmp    *0x8022a0(,%eax,4)
  800362:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800365:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800369:	eb d6                	jmp    800341 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80036e:	b8 00 00 00 00       	mov    $0x0,%eax
  800373:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800376:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800379:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80037d:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800380:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800383:	83 fa 09             	cmp    $0x9,%edx
  800386:	77 39                	ja     8003c1 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800388:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80038b:	eb e9                	jmp    800376 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80038d:	8b 45 14             	mov    0x14(%ebp),%eax
  800390:	8d 48 04             	lea    0x4(%eax),%ecx
  800393:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800396:	8b 00                	mov    (%eax),%eax
  800398:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80039e:	eb 27                	jmp    8003c7 <vprintfmt+0xdf>
  8003a0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003a3:	85 c0                	test   %eax,%eax
  8003a5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003aa:	0f 49 c8             	cmovns %eax,%ecx
  8003ad:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003b3:	eb 8c                	jmp    800341 <vprintfmt+0x59>
  8003b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003b8:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003bf:	eb 80                	jmp    800341 <vprintfmt+0x59>
  8003c1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003c4:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003c7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003cb:	0f 89 70 ff ff ff    	jns    800341 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003d1:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003d4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003d7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003de:	e9 5e ff ff ff       	jmp    800341 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003e3:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003e9:	e9 53 ff ff ff       	jmp    800341 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f1:	8d 50 04             	lea    0x4(%eax),%edx
  8003f4:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f7:	83 ec 08             	sub    $0x8,%esp
  8003fa:	53                   	push   %ebx
  8003fb:	ff 30                	pushl  (%eax)
  8003fd:	ff d6                	call   *%esi
			break;
  8003ff:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800402:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800405:	e9 04 ff ff ff       	jmp    80030e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80040a:	8b 45 14             	mov    0x14(%ebp),%eax
  80040d:	8d 50 04             	lea    0x4(%eax),%edx
  800410:	89 55 14             	mov    %edx,0x14(%ebp)
  800413:	8b 00                	mov    (%eax),%eax
  800415:	99                   	cltd   
  800416:	31 d0                	xor    %edx,%eax
  800418:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80041a:	83 f8 0f             	cmp    $0xf,%eax
  80041d:	7f 0b                	jg     80042a <vprintfmt+0x142>
  80041f:	8b 14 85 00 24 80 00 	mov    0x802400(,%eax,4),%edx
  800426:	85 d2                	test   %edx,%edx
  800428:	75 18                	jne    800442 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80042a:	50                   	push   %eax
  80042b:	68 6b 21 80 00       	push   $0x80216b
  800430:	53                   	push   %ebx
  800431:	56                   	push   %esi
  800432:	e8 94 fe ff ff       	call   8002cb <printfmt>
  800437:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80043d:	e9 cc fe ff ff       	jmp    80030e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800442:	52                   	push   %edx
  800443:	68 fe 25 80 00       	push   $0x8025fe
  800448:	53                   	push   %ebx
  800449:	56                   	push   %esi
  80044a:	e8 7c fe ff ff       	call   8002cb <printfmt>
  80044f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800452:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800455:	e9 b4 fe ff ff       	jmp    80030e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80045a:	8b 45 14             	mov    0x14(%ebp),%eax
  80045d:	8d 50 04             	lea    0x4(%eax),%edx
  800460:	89 55 14             	mov    %edx,0x14(%ebp)
  800463:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800465:	85 ff                	test   %edi,%edi
  800467:	b8 64 21 80 00       	mov    $0x802164,%eax
  80046c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80046f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800473:	0f 8e 94 00 00 00    	jle    80050d <vprintfmt+0x225>
  800479:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80047d:	0f 84 98 00 00 00    	je     80051b <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800483:	83 ec 08             	sub    $0x8,%esp
  800486:	ff 75 d0             	pushl  -0x30(%ebp)
  800489:	57                   	push   %edi
  80048a:	e8 86 02 00 00       	call   800715 <strnlen>
  80048f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800492:	29 c1                	sub    %eax,%ecx
  800494:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800497:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80049a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80049e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004a1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004a4:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a6:	eb 0f                	jmp    8004b7 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004a8:	83 ec 08             	sub    $0x8,%esp
  8004ab:	53                   	push   %ebx
  8004ac:	ff 75 e0             	pushl  -0x20(%ebp)
  8004af:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b1:	83 ef 01             	sub    $0x1,%edi
  8004b4:	83 c4 10             	add    $0x10,%esp
  8004b7:	85 ff                	test   %edi,%edi
  8004b9:	7f ed                	jg     8004a8 <vprintfmt+0x1c0>
  8004bb:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004be:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004c1:	85 c9                	test   %ecx,%ecx
  8004c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c8:	0f 49 c1             	cmovns %ecx,%eax
  8004cb:	29 c1                	sub    %eax,%ecx
  8004cd:	89 75 08             	mov    %esi,0x8(%ebp)
  8004d0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004d3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004d6:	89 cb                	mov    %ecx,%ebx
  8004d8:	eb 4d                	jmp    800527 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004da:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004de:	74 1b                	je     8004fb <vprintfmt+0x213>
  8004e0:	0f be c0             	movsbl %al,%eax
  8004e3:	83 e8 20             	sub    $0x20,%eax
  8004e6:	83 f8 5e             	cmp    $0x5e,%eax
  8004e9:	76 10                	jbe    8004fb <vprintfmt+0x213>
					putch('?', putdat);
  8004eb:	83 ec 08             	sub    $0x8,%esp
  8004ee:	ff 75 0c             	pushl  0xc(%ebp)
  8004f1:	6a 3f                	push   $0x3f
  8004f3:	ff 55 08             	call   *0x8(%ebp)
  8004f6:	83 c4 10             	add    $0x10,%esp
  8004f9:	eb 0d                	jmp    800508 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004fb:	83 ec 08             	sub    $0x8,%esp
  8004fe:	ff 75 0c             	pushl  0xc(%ebp)
  800501:	52                   	push   %edx
  800502:	ff 55 08             	call   *0x8(%ebp)
  800505:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800508:	83 eb 01             	sub    $0x1,%ebx
  80050b:	eb 1a                	jmp    800527 <vprintfmt+0x23f>
  80050d:	89 75 08             	mov    %esi,0x8(%ebp)
  800510:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800513:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800516:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800519:	eb 0c                	jmp    800527 <vprintfmt+0x23f>
  80051b:	89 75 08             	mov    %esi,0x8(%ebp)
  80051e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800521:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800524:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800527:	83 c7 01             	add    $0x1,%edi
  80052a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80052e:	0f be d0             	movsbl %al,%edx
  800531:	85 d2                	test   %edx,%edx
  800533:	74 23                	je     800558 <vprintfmt+0x270>
  800535:	85 f6                	test   %esi,%esi
  800537:	78 a1                	js     8004da <vprintfmt+0x1f2>
  800539:	83 ee 01             	sub    $0x1,%esi
  80053c:	79 9c                	jns    8004da <vprintfmt+0x1f2>
  80053e:	89 df                	mov    %ebx,%edi
  800540:	8b 75 08             	mov    0x8(%ebp),%esi
  800543:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800546:	eb 18                	jmp    800560 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800548:	83 ec 08             	sub    $0x8,%esp
  80054b:	53                   	push   %ebx
  80054c:	6a 20                	push   $0x20
  80054e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800550:	83 ef 01             	sub    $0x1,%edi
  800553:	83 c4 10             	add    $0x10,%esp
  800556:	eb 08                	jmp    800560 <vprintfmt+0x278>
  800558:	89 df                	mov    %ebx,%edi
  80055a:	8b 75 08             	mov    0x8(%ebp),%esi
  80055d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800560:	85 ff                	test   %edi,%edi
  800562:	7f e4                	jg     800548 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800564:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800567:	e9 a2 fd ff ff       	jmp    80030e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80056c:	83 fa 01             	cmp    $0x1,%edx
  80056f:	7e 16                	jle    800587 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800571:	8b 45 14             	mov    0x14(%ebp),%eax
  800574:	8d 50 08             	lea    0x8(%eax),%edx
  800577:	89 55 14             	mov    %edx,0x14(%ebp)
  80057a:	8b 50 04             	mov    0x4(%eax),%edx
  80057d:	8b 00                	mov    (%eax),%eax
  80057f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800582:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800585:	eb 32                	jmp    8005b9 <vprintfmt+0x2d1>
	else if (lflag)
  800587:	85 d2                	test   %edx,%edx
  800589:	74 18                	je     8005a3 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80058b:	8b 45 14             	mov    0x14(%ebp),%eax
  80058e:	8d 50 04             	lea    0x4(%eax),%edx
  800591:	89 55 14             	mov    %edx,0x14(%ebp)
  800594:	8b 00                	mov    (%eax),%eax
  800596:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800599:	89 c1                	mov    %eax,%ecx
  80059b:	c1 f9 1f             	sar    $0x1f,%ecx
  80059e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005a1:	eb 16                	jmp    8005b9 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a6:	8d 50 04             	lea    0x4(%eax),%edx
  8005a9:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ac:	8b 00                	mov    (%eax),%eax
  8005ae:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b1:	89 c1                	mov    %eax,%ecx
  8005b3:	c1 f9 1f             	sar    $0x1f,%ecx
  8005b6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005b9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005bc:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005bf:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005c4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005c8:	79 74                	jns    80063e <vprintfmt+0x356>
				putch('-', putdat);
  8005ca:	83 ec 08             	sub    $0x8,%esp
  8005cd:	53                   	push   %ebx
  8005ce:	6a 2d                	push   $0x2d
  8005d0:	ff d6                	call   *%esi
				num = -(long long) num;
  8005d2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005d5:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005d8:	f7 d8                	neg    %eax
  8005da:	83 d2 00             	adc    $0x0,%edx
  8005dd:	f7 da                	neg    %edx
  8005df:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005e2:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005e7:	eb 55                	jmp    80063e <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005e9:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ec:	e8 83 fc ff ff       	call   800274 <getuint>
			base = 10;
  8005f1:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005f6:	eb 46                	jmp    80063e <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005f8:	8d 45 14             	lea    0x14(%ebp),%eax
  8005fb:	e8 74 fc ff ff       	call   800274 <getuint>
                        base = 8;
  800600:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800605:	eb 37                	jmp    80063e <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800607:	83 ec 08             	sub    $0x8,%esp
  80060a:	53                   	push   %ebx
  80060b:	6a 30                	push   $0x30
  80060d:	ff d6                	call   *%esi
			putch('x', putdat);
  80060f:	83 c4 08             	add    $0x8,%esp
  800612:	53                   	push   %ebx
  800613:	6a 78                	push   $0x78
  800615:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800617:	8b 45 14             	mov    0x14(%ebp),%eax
  80061a:	8d 50 04             	lea    0x4(%eax),%edx
  80061d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800620:	8b 00                	mov    (%eax),%eax
  800622:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800627:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80062a:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80062f:	eb 0d                	jmp    80063e <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800631:	8d 45 14             	lea    0x14(%ebp),%eax
  800634:	e8 3b fc ff ff       	call   800274 <getuint>
			base = 16;
  800639:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80063e:	83 ec 0c             	sub    $0xc,%esp
  800641:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800645:	57                   	push   %edi
  800646:	ff 75 e0             	pushl  -0x20(%ebp)
  800649:	51                   	push   %ecx
  80064a:	52                   	push   %edx
  80064b:	50                   	push   %eax
  80064c:	89 da                	mov    %ebx,%edx
  80064e:	89 f0                	mov    %esi,%eax
  800650:	e8 70 fb ff ff       	call   8001c5 <printnum>
			break;
  800655:	83 c4 20             	add    $0x20,%esp
  800658:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80065b:	e9 ae fc ff ff       	jmp    80030e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800660:	83 ec 08             	sub    $0x8,%esp
  800663:	53                   	push   %ebx
  800664:	51                   	push   %ecx
  800665:	ff d6                	call   *%esi
			break;
  800667:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80066a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80066d:	e9 9c fc ff ff       	jmp    80030e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800672:	83 ec 08             	sub    $0x8,%esp
  800675:	53                   	push   %ebx
  800676:	6a 25                	push   $0x25
  800678:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80067a:	83 c4 10             	add    $0x10,%esp
  80067d:	eb 03                	jmp    800682 <vprintfmt+0x39a>
  80067f:	83 ef 01             	sub    $0x1,%edi
  800682:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800686:	75 f7                	jne    80067f <vprintfmt+0x397>
  800688:	e9 81 fc ff ff       	jmp    80030e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80068d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800690:	5b                   	pop    %ebx
  800691:	5e                   	pop    %esi
  800692:	5f                   	pop    %edi
  800693:	5d                   	pop    %ebp
  800694:	c3                   	ret    

00800695 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800695:	55                   	push   %ebp
  800696:	89 e5                	mov    %esp,%ebp
  800698:	83 ec 18             	sub    $0x18,%esp
  80069b:	8b 45 08             	mov    0x8(%ebp),%eax
  80069e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006a1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006a4:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006a8:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006ab:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006b2:	85 c0                	test   %eax,%eax
  8006b4:	74 26                	je     8006dc <vsnprintf+0x47>
  8006b6:	85 d2                	test   %edx,%edx
  8006b8:	7e 22                	jle    8006dc <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006ba:	ff 75 14             	pushl  0x14(%ebp)
  8006bd:	ff 75 10             	pushl  0x10(%ebp)
  8006c0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006c3:	50                   	push   %eax
  8006c4:	68 ae 02 80 00       	push   $0x8002ae
  8006c9:	e8 1a fc ff ff       	call   8002e8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006d1:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006d7:	83 c4 10             	add    $0x10,%esp
  8006da:	eb 05                	jmp    8006e1 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006dc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006e1:	c9                   	leave  
  8006e2:	c3                   	ret    

008006e3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006e3:	55                   	push   %ebp
  8006e4:	89 e5                	mov    %esp,%ebp
  8006e6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006e9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006ec:	50                   	push   %eax
  8006ed:	ff 75 10             	pushl  0x10(%ebp)
  8006f0:	ff 75 0c             	pushl  0xc(%ebp)
  8006f3:	ff 75 08             	pushl  0x8(%ebp)
  8006f6:	e8 9a ff ff ff       	call   800695 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006fb:	c9                   	leave  
  8006fc:	c3                   	ret    

008006fd <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006fd:	55                   	push   %ebp
  8006fe:	89 e5                	mov    %esp,%ebp
  800700:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800703:	b8 00 00 00 00       	mov    $0x0,%eax
  800708:	eb 03                	jmp    80070d <strlen+0x10>
		n++;
  80070a:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80070d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800711:	75 f7                	jne    80070a <strlen+0xd>
		n++;
	return n;
}
  800713:	5d                   	pop    %ebp
  800714:	c3                   	ret    

00800715 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800715:	55                   	push   %ebp
  800716:	89 e5                	mov    %esp,%ebp
  800718:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80071b:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80071e:	ba 00 00 00 00       	mov    $0x0,%edx
  800723:	eb 03                	jmp    800728 <strnlen+0x13>
		n++;
  800725:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800728:	39 c2                	cmp    %eax,%edx
  80072a:	74 08                	je     800734 <strnlen+0x1f>
  80072c:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800730:	75 f3                	jne    800725 <strnlen+0x10>
  800732:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800734:	5d                   	pop    %ebp
  800735:	c3                   	ret    

00800736 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800736:	55                   	push   %ebp
  800737:	89 e5                	mov    %esp,%ebp
  800739:	53                   	push   %ebx
  80073a:	8b 45 08             	mov    0x8(%ebp),%eax
  80073d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800740:	89 c2                	mov    %eax,%edx
  800742:	83 c2 01             	add    $0x1,%edx
  800745:	83 c1 01             	add    $0x1,%ecx
  800748:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80074c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80074f:	84 db                	test   %bl,%bl
  800751:	75 ef                	jne    800742 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800753:	5b                   	pop    %ebx
  800754:	5d                   	pop    %ebp
  800755:	c3                   	ret    

00800756 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800756:	55                   	push   %ebp
  800757:	89 e5                	mov    %esp,%ebp
  800759:	53                   	push   %ebx
  80075a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80075d:	53                   	push   %ebx
  80075e:	e8 9a ff ff ff       	call   8006fd <strlen>
  800763:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800766:	ff 75 0c             	pushl  0xc(%ebp)
  800769:	01 d8                	add    %ebx,%eax
  80076b:	50                   	push   %eax
  80076c:	e8 c5 ff ff ff       	call   800736 <strcpy>
	return dst;
}
  800771:	89 d8                	mov    %ebx,%eax
  800773:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800776:	c9                   	leave  
  800777:	c3                   	ret    

00800778 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800778:	55                   	push   %ebp
  800779:	89 e5                	mov    %esp,%ebp
  80077b:	56                   	push   %esi
  80077c:	53                   	push   %ebx
  80077d:	8b 75 08             	mov    0x8(%ebp),%esi
  800780:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800783:	89 f3                	mov    %esi,%ebx
  800785:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800788:	89 f2                	mov    %esi,%edx
  80078a:	eb 0f                	jmp    80079b <strncpy+0x23>
		*dst++ = *src;
  80078c:	83 c2 01             	add    $0x1,%edx
  80078f:	0f b6 01             	movzbl (%ecx),%eax
  800792:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800795:	80 39 01             	cmpb   $0x1,(%ecx)
  800798:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80079b:	39 da                	cmp    %ebx,%edx
  80079d:	75 ed                	jne    80078c <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80079f:	89 f0                	mov    %esi,%eax
  8007a1:	5b                   	pop    %ebx
  8007a2:	5e                   	pop    %esi
  8007a3:	5d                   	pop    %ebp
  8007a4:	c3                   	ret    

008007a5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007a5:	55                   	push   %ebp
  8007a6:	89 e5                	mov    %esp,%ebp
  8007a8:	56                   	push   %esi
  8007a9:	53                   	push   %ebx
  8007aa:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007b0:	8b 55 10             	mov    0x10(%ebp),%edx
  8007b3:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007b5:	85 d2                	test   %edx,%edx
  8007b7:	74 21                	je     8007da <strlcpy+0x35>
  8007b9:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007bd:	89 f2                	mov    %esi,%edx
  8007bf:	eb 09                	jmp    8007ca <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007c1:	83 c2 01             	add    $0x1,%edx
  8007c4:	83 c1 01             	add    $0x1,%ecx
  8007c7:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007ca:	39 c2                	cmp    %eax,%edx
  8007cc:	74 09                	je     8007d7 <strlcpy+0x32>
  8007ce:	0f b6 19             	movzbl (%ecx),%ebx
  8007d1:	84 db                	test   %bl,%bl
  8007d3:	75 ec                	jne    8007c1 <strlcpy+0x1c>
  8007d5:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007d7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007da:	29 f0                	sub    %esi,%eax
}
  8007dc:	5b                   	pop    %ebx
  8007dd:	5e                   	pop    %esi
  8007de:	5d                   	pop    %ebp
  8007df:	c3                   	ret    

008007e0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007e0:	55                   	push   %ebp
  8007e1:	89 e5                	mov    %esp,%ebp
  8007e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e6:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007e9:	eb 06                	jmp    8007f1 <strcmp+0x11>
		p++, q++;
  8007eb:	83 c1 01             	add    $0x1,%ecx
  8007ee:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007f1:	0f b6 01             	movzbl (%ecx),%eax
  8007f4:	84 c0                	test   %al,%al
  8007f6:	74 04                	je     8007fc <strcmp+0x1c>
  8007f8:	3a 02                	cmp    (%edx),%al
  8007fa:	74 ef                	je     8007eb <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007fc:	0f b6 c0             	movzbl %al,%eax
  8007ff:	0f b6 12             	movzbl (%edx),%edx
  800802:	29 d0                	sub    %edx,%eax
}
  800804:	5d                   	pop    %ebp
  800805:	c3                   	ret    

00800806 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800806:	55                   	push   %ebp
  800807:	89 e5                	mov    %esp,%ebp
  800809:	53                   	push   %ebx
  80080a:	8b 45 08             	mov    0x8(%ebp),%eax
  80080d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800810:	89 c3                	mov    %eax,%ebx
  800812:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800815:	eb 06                	jmp    80081d <strncmp+0x17>
		n--, p++, q++;
  800817:	83 c0 01             	add    $0x1,%eax
  80081a:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80081d:	39 d8                	cmp    %ebx,%eax
  80081f:	74 15                	je     800836 <strncmp+0x30>
  800821:	0f b6 08             	movzbl (%eax),%ecx
  800824:	84 c9                	test   %cl,%cl
  800826:	74 04                	je     80082c <strncmp+0x26>
  800828:	3a 0a                	cmp    (%edx),%cl
  80082a:	74 eb                	je     800817 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80082c:	0f b6 00             	movzbl (%eax),%eax
  80082f:	0f b6 12             	movzbl (%edx),%edx
  800832:	29 d0                	sub    %edx,%eax
  800834:	eb 05                	jmp    80083b <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800836:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80083b:	5b                   	pop    %ebx
  80083c:	5d                   	pop    %ebp
  80083d:	c3                   	ret    

0080083e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80083e:	55                   	push   %ebp
  80083f:	89 e5                	mov    %esp,%ebp
  800841:	8b 45 08             	mov    0x8(%ebp),%eax
  800844:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800848:	eb 07                	jmp    800851 <strchr+0x13>
		if (*s == c)
  80084a:	38 ca                	cmp    %cl,%dl
  80084c:	74 0f                	je     80085d <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80084e:	83 c0 01             	add    $0x1,%eax
  800851:	0f b6 10             	movzbl (%eax),%edx
  800854:	84 d2                	test   %dl,%dl
  800856:	75 f2                	jne    80084a <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800858:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80085d:	5d                   	pop    %ebp
  80085e:	c3                   	ret    

0080085f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80085f:	55                   	push   %ebp
  800860:	89 e5                	mov    %esp,%ebp
  800862:	8b 45 08             	mov    0x8(%ebp),%eax
  800865:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800869:	eb 03                	jmp    80086e <strfind+0xf>
  80086b:	83 c0 01             	add    $0x1,%eax
  80086e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800871:	38 ca                	cmp    %cl,%dl
  800873:	74 04                	je     800879 <strfind+0x1a>
  800875:	84 d2                	test   %dl,%dl
  800877:	75 f2                	jne    80086b <strfind+0xc>
			break;
	return (char *) s;
}
  800879:	5d                   	pop    %ebp
  80087a:	c3                   	ret    

0080087b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	57                   	push   %edi
  80087f:	56                   	push   %esi
  800880:	53                   	push   %ebx
  800881:	8b 7d 08             	mov    0x8(%ebp),%edi
  800884:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800887:	85 c9                	test   %ecx,%ecx
  800889:	74 36                	je     8008c1 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80088b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800891:	75 28                	jne    8008bb <memset+0x40>
  800893:	f6 c1 03             	test   $0x3,%cl
  800896:	75 23                	jne    8008bb <memset+0x40>
		c &= 0xFF;
  800898:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80089c:	89 d3                	mov    %edx,%ebx
  80089e:	c1 e3 08             	shl    $0x8,%ebx
  8008a1:	89 d6                	mov    %edx,%esi
  8008a3:	c1 e6 18             	shl    $0x18,%esi
  8008a6:	89 d0                	mov    %edx,%eax
  8008a8:	c1 e0 10             	shl    $0x10,%eax
  8008ab:	09 f0                	or     %esi,%eax
  8008ad:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008af:	89 d8                	mov    %ebx,%eax
  8008b1:	09 d0                	or     %edx,%eax
  8008b3:	c1 e9 02             	shr    $0x2,%ecx
  8008b6:	fc                   	cld    
  8008b7:	f3 ab                	rep stos %eax,%es:(%edi)
  8008b9:	eb 06                	jmp    8008c1 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008be:	fc                   	cld    
  8008bf:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008c1:	89 f8                	mov    %edi,%eax
  8008c3:	5b                   	pop    %ebx
  8008c4:	5e                   	pop    %esi
  8008c5:	5f                   	pop    %edi
  8008c6:	5d                   	pop    %ebp
  8008c7:	c3                   	ret    

008008c8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008c8:	55                   	push   %ebp
  8008c9:	89 e5                	mov    %esp,%ebp
  8008cb:	57                   	push   %edi
  8008cc:	56                   	push   %esi
  8008cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008d3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008d6:	39 c6                	cmp    %eax,%esi
  8008d8:	73 35                	jae    80090f <memmove+0x47>
  8008da:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008dd:	39 d0                	cmp    %edx,%eax
  8008df:	73 2e                	jae    80090f <memmove+0x47>
		s += n;
		d += n;
  8008e1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008e4:	89 d6                	mov    %edx,%esi
  8008e6:	09 fe                	or     %edi,%esi
  8008e8:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008ee:	75 13                	jne    800903 <memmove+0x3b>
  8008f0:	f6 c1 03             	test   $0x3,%cl
  8008f3:	75 0e                	jne    800903 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008f5:	83 ef 04             	sub    $0x4,%edi
  8008f8:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008fb:	c1 e9 02             	shr    $0x2,%ecx
  8008fe:	fd                   	std    
  8008ff:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800901:	eb 09                	jmp    80090c <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800903:	83 ef 01             	sub    $0x1,%edi
  800906:	8d 72 ff             	lea    -0x1(%edx),%esi
  800909:	fd                   	std    
  80090a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80090c:	fc                   	cld    
  80090d:	eb 1d                	jmp    80092c <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80090f:	89 f2                	mov    %esi,%edx
  800911:	09 c2                	or     %eax,%edx
  800913:	f6 c2 03             	test   $0x3,%dl
  800916:	75 0f                	jne    800927 <memmove+0x5f>
  800918:	f6 c1 03             	test   $0x3,%cl
  80091b:	75 0a                	jne    800927 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80091d:	c1 e9 02             	shr    $0x2,%ecx
  800920:	89 c7                	mov    %eax,%edi
  800922:	fc                   	cld    
  800923:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800925:	eb 05                	jmp    80092c <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800927:	89 c7                	mov    %eax,%edi
  800929:	fc                   	cld    
  80092a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80092c:	5e                   	pop    %esi
  80092d:	5f                   	pop    %edi
  80092e:	5d                   	pop    %ebp
  80092f:	c3                   	ret    

00800930 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800930:	55                   	push   %ebp
  800931:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800933:	ff 75 10             	pushl  0x10(%ebp)
  800936:	ff 75 0c             	pushl  0xc(%ebp)
  800939:	ff 75 08             	pushl  0x8(%ebp)
  80093c:	e8 87 ff ff ff       	call   8008c8 <memmove>
}
  800941:	c9                   	leave  
  800942:	c3                   	ret    

00800943 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800943:	55                   	push   %ebp
  800944:	89 e5                	mov    %esp,%ebp
  800946:	56                   	push   %esi
  800947:	53                   	push   %ebx
  800948:	8b 45 08             	mov    0x8(%ebp),%eax
  80094b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80094e:	89 c6                	mov    %eax,%esi
  800950:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800953:	eb 1a                	jmp    80096f <memcmp+0x2c>
		if (*s1 != *s2)
  800955:	0f b6 08             	movzbl (%eax),%ecx
  800958:	0f b6 1a             	movzbl (%edx),%ebx
  80095b:	38 d9                	cmp    %bl,%cl
  80095d:	74 0a                	je     800969 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80095f:	0f b6 c1             	movzbl %cl,%eax
  800962:	0f b6 db             	movzbl %bl,%ebx
  800965:	29 d8                	sub    %ebx,%eax
  800967:	eb 0f                	jmp    800978 <memcmp+0x35>
		s1++, s2++;
  800969:	83 c0 01             	add    $0x1,%eax
  80096c:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80096f:	39 f0                	cmp    %esi,%eax
  800971:	75 e2                	jne    800955 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800973:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800978:	5b                   	pop    %ebx
  800979:	5e                   	pop    %esi
  80097a:	5d                   	pop    %ebp
  80097b:	c3                   	ret    

0080097c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80097c:	55                   	push   %ebp
  80097d:	89 e5                	mov    %esp,%ebp
  80097f:	53                   	push   %ebx
  800980:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800983:	89 c1                	mov    %eax,%ecx
  800985:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800988:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80098c:	eb 0a                	jmp    800998 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80098e:	0f b6 10             	movzbl (%eax),%edx
  800991:	39 da                	cmp    %ebx,%edx
  800993:	74 07                	je     80099c <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800995:	83 c0 01             	add    $0x1,%eax
  800998:	39 c8                	cmp    %ecx,%eax
  80099a:	72 f2                	jb     80098e <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80099c:	5b                   	pop    %ebx
  80099d:	5d                   	pop    %ebp
  80099e:	c3                   	ret    

0080099f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80099f:	55                   	push   %ebp
  8009a0:	89 e5                	mov    %esp,%ebp
  8009a2:	57                   	push   %edi
  8009a3:	56                   	push   %esi
  8009a4:	53                   	push   %ebx
  8009a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009a8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ab:	eb 03                	jmp    8009b0 <strtol+0x11>
		s++;
  8009ad:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009b0:	0f b6 01             	movzbl (%ecx),%eax
  8009b3:	3c 20                	cmp    $0x20,%al
  8009b5:	74 f6                	je     8009ad <strtol+0xe>
  8009b7:	3c 09                	cmp    $0x9,%al
  8009b9:	74 f2                	je     8009ad <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009bb:	3c 2b                	cmp    $0x2b,%al
  8009bd:	75 0a                	jne    8009c9 <strtol+0x2a>
		s++;
  8009bf:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009c2:	bf 00 00 00 00       	mov    $0x0,%edi
  8009c7:	eb 11                	jmp    8009da <strtol+0x3b>
  8009c9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009ce:	3c 2d                	cmp    $0x2d,%al
  8009d0:	75 08                	jne    8009da <strtol+0x3b>
		s++, neg = 1;
  8009d2:	83 c1 01             	add    $0x1,%ecx
  8009d5:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009da:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009e0:	75 15                	jne    8009f7 <strtol+0x58>
  8009e2:	80 39 30             	cmpb   $0x30,(%ecx)
  8009e5:	75 10                	jne    8009f7 <strtol+0x58>
  8009e7:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009eb:	75 7c                	jne    800a69 <strtol+0xca>
		s += 2, base = 16;
  8009ed:	83 c1 02             	add    $0x2,%ecx
  8009f0:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009f5:	eb 16                	jmp    800a0d <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009f7:	85 db                	test   %ebx,%ebx
  8009f9:	75 12                	jne    800a0d <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009fb:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a00:	80 39 30             	cmpb   $0x30,(%ecx)
  800a03:	75 08                	jne    800a0d <strtol+0x6e>
		s++, base = 8;
  800a05:	83 c1 01             	add    $0x1,%ecx
  800a08:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a0d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a12:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a15:	0f b6 11             	movzbl (%ecx),%edx
  800a18:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a1b:	89 f3                	mov    %esi,%ebx
  800a1d:	80 fb 09             	cmp    $0x9,%bl
  800a20:	77 08                	ja     800a2a <strtol+0x8b>
			dig = *s - '0';
  800a22:	0f be d2             	movsbl %dl,%edx
  800a25:	83 ea 30             	sub    $0x30,%edx
  800a28:	eb 22                	jmp    800a4c <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a2a:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a2d:	89 f3                	mov    %esi,%ebx
  800a2f:	80 fb 19             	cmp    $0x19,%bl
  800a32:	77 08                	ja     800a3c <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a34:	0f be d2             	movsbl %dl,%edx
  800a37:	83 ea 57             	sub    $0x57,%edx
  800a3a:	eb 10                	jmp    800a4c <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a3c:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a3f:	89 f3                	mov    %esi,%ebx
  800a41:	80 fb 19             	cmp    $0x19,%bl
  800a44:	77 16                	ja     800a5c <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a46:	0f be d2             	movsbl %dl,%edx
  800a49:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a4c:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a4f:	7d 0b                	jge    800a5c <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a51:	83 c1 01             	add    $0x1,%ecx
  800a54:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a58:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a5a:	eb b9                	jmp    800a15 <strtol+0x76>

	if (endptr)
  800a5c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a60:	74 0d                	je     800a6f <strtol+0xd0>
		*endptr = (char *) s;
  800a62:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a65:	89 0e                	mov    %ecx,(%esi)
  800a67:	eb 06                	jmp    800a6f <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a69:	85 db                	test   %ebx,%ebx
  800a6b:	74 98                	je     800a05 <strtol+0x66>
  800a6d:	eb 9e                	jmp    800a0d <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a6f:	89 c2                	mov    %eax,%edx
  800a71:	f7 da                	neg    %edx
  800a73:	85 ff                	test   %edi,%edi
  800a75:	0f 45 c2             	cmovne %edx,%eax
}
  800a78:	5b                   	pop    %ebx
  800a79:	5e                   	pop    %esi
  800a7a:	5f                   	pop    %edi
  800a7b:	5d                   	pop    %ebp
  800a7c:	c3                   	ret    

00800a7d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a7d:	55                   	push   %ebp
  800a7e:	89 e5                	mov    %esp,%ebp
  800a80:	57                   	push   %edi
  800a81:	56                   	push   %esi
  800a82:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a83:	b8 00 00 00 00       	mov    $0x0,%eax
  800a88:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a8b:	8b 55 08             	mov    0x8(%ebp),%edx
  800a8e:	89 c3                	mov    %eax,%ebx
  800a90:	89 c7                	mov    %eax,%edi
  800a92:	89 c6                	mov    %eax,%esi
  800a94:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a96:	5b                   	pop    %ebx
  800a97:	5e                   	pop    %esi
  800a98:	5f                   	pop    %edi
  800a99:	5d                   	pop    %ebp
  800a9a:	c3                   	ret    

00800a9b <sys_cgetc>:

int
sys_cgetc(void)
{
  800a9b:	55                   	push   %ebp
  800a9c:	89 e5                	mov    %esp,%ebp
  800a9e:	57                   	push   %edi
  800a9f:	56                   	push   %esi
  800aa0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa1:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa6:	b8 01 00 00 00       	mov    $0x1,%eax
  800aab:	89 d1                	mov    %edx,%ecx
  800aad:	89 d3                	mov    %edx,%ebx
  800aaf:	89 d7                	mov    %edx,%edi
  800ab1:	89 d6                	mov    %edx,%esi
  800ab3:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ab5:	5b                   	pop    %ebx
  800ab6:	5e                   	pop    %esi
  800ab7:	5f                   	pop    %edi
  800ab8:	5d                   	pop    %ebp
  800ab9:	c3                   	ret    

00800aba <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800aba:	55                   	push   %ebp
  800abb:	89 e5                	mov    %esp,%ebp
  800abd:	57                   	push   %edi
  800abe:	56                   	push   %esi
  800abf:	53                   	push   %ebx
  800ac0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ac8:	b8 03 00 00 00       	mov    $0x3,%eax
  800acd:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad0:	89 cb                	mov    %ecx,%ebx
  800ad2:	89 cf                	mov    %ecx,%edi
  800ad4:	89 ce                	mov    %ecx,%esi
  800ad6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ad8:	85 c0                	test   %eax,%eax
  800ada:	7e 17                	jle    800af3 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800adc:	83 ec 0c             	sub    $0xc,%esp
  800adf:	50                   	push   %eax
  800ae0:	6a 03                	push   $0x3
  800ae2:	68 5f 24 80 00       	push   $0x80245f
  800ae7:	6a 23                	push   $0x23
  800ae9:	68 7c 24 80 00       	push   $0x80247c
  800aee:	e8 88 12 00 00       	call   801d7b <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800af3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800af6:	5b                   	pop    %ebx
  800af7:	5e                   	pop    %esi
  800af8:	5f                   	pop    %edi
  800af9:	5d                   	pop    %ebp
  800afa:	c3                   	ret    

00800afb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800afb:	55                   	push   %ebp
  800afc:	89 e5                	mov    %esp,%ebp
  800afe:	57                   	push   %edi
  800aff:	56                   	push   %esi
  800b00:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b01:	ba 00 00 00 00       	mov    $0x0,%edx
  800b06:	b8 02 00 00 00       	mov    $0x2,%eax
  800b0b:	89 d1                	mov    %edx,%ecx
  800b0d:	89 d3                	mov    %edx,%ebx
  800b0f:	89 d7                	mov    %edx,%edi
  800b11:	89 d6                	mov    %edx,%esi
  800b13:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b15:	5b                   	pop    %ebx
  800b16:	5e                   	pop    %esi
  800b17:	5f                   	pop    %edi
  800b18:	5d                   	pop    %ebp
  800b19:	c3                   	ret    

00800b1a <sys_yield>:

void
sys_yield(void)
{
  800b1a:	55                   	push   %ebp
  800b1b:	89 e5                	mov    %esp,%ebp
  800b1d:	57                   	push   %edi
  800b1e:	56                   	push   %esi
  800b1f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b20:	ba 00 00 00 00       	mov    $0x0,%edx
  800b25:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b2a:	89 d1                	mov    %edx,%ecx
  800b2c:	89 d3                	mov    %edx,%ebx
  800b2e:	89 d7                	mov    %edx,%edi
  800b30:	89 d6                	mov    %edx,%esi
  800b32:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b34:	5b                   	pop    %ebx
  800b35:	5e                   	pop    %esi
  800b36:	5f                   	pop    %edi
  800b37:	5d                   	pop    %ebp
  800b38:	c3                   	ret    

00800b39 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b39:	55                   	push   %ebp
  800b3a:	89 e5                	mov    %esp,%ebp
  800b3c:	57                   	push   %edi
  800b3d:	56                   	push   %esi
  800b3e:	53                   	push   %ebx
  800b3f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b42:	be 00 00 00 00       	mov    $0x0,%esi
  800b47:	b8 04 00 00 00       	mov    $0x4,%eax
  800b4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b52:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b55:	89 f7                	mov    %esi,%edi
  800b57:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b59:	85 c0                	test   %eax,%eax
  800b5b:	7e 17                	jle    800b74 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b5d:	83 ec 0c             	sub    $0xc,%esp
  800b60:	50                   	push   %eax
  800b61:	6a 04                	push   $0x4
  800b63:	68 5f 24 80 00       	push   $0x80245f
  800b68:	6a 23                	push   $0x23
  800b6a:	68 7c 24 80 00       	push   $0x80247c
  800b6f:	e8 07 12 00 00       	call   801d7b <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b74:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b77:	5b                   	pop    %ebx
  800b78:	5e                   	pop    %esi
  800b79:	5f                   	pop    %edi
  800b7a:	5d                   	pop    %ebp
  800b7b:	c3                   	ret    

00800b7c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b7c:	55                   	push   %ebp
  800b7d:	89 e5                	mov    %esp,%ebp
  800b7f:	57                   	push   %edi
  800b80:	56                   	push   %esi
  800b81:	53                   	push   %ebx
  800b82:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b85:	b8 05 00 00 00       	mov    $0x5,%eax
  800b8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b90:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b93:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b96:	8b 75 18             	mov    0x18(%ebp),%esi
  800b99:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b9b:	85 c0                	test   %eax,%eax
  800b9d:	7e 17                	jle    800bb6 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9f:	83 ec 0c             	sub    $0xc,%esp
  800ba2:	50                   	push   %eax
  800ba3:	6a 05                	push   $0x5
  800ba5:	68 5f 24 80 00       	push   $0x80245f
  800baa:	6a 23                	push   $0x23
  800bac:	68 7c 24 80 00       	push   $0x80247c
  800bb1:	e8 c5 11 00 00       	call   801d7b <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bb6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb9:	5b                   	pop    %ebx
  800bba:	5e                   	pop    %esi
  800bbb:	5f                   	pop    %edi
  800bbc:	5d                   	pop    %ebp
  800bbd:	c3                   	ret    

00800bbe <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bbe:	55                   	push   %ebp
  800bbf:	89 e5                	mov    %esp,%ebp
  800bc1:	57                   	push   %edi
  800bc2:	56                   	push   %esi
  800bc3:	53                   	push   %ebx
  800bc4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bcc:	b8 06 00 00 00       	mov    $0x6,%eax
  800bd1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd7:	89 df                	mov    %ebx,%edi
  800bd9:	89 de                	mov    %ebx,%esi
  800bdb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bdd:	85 c0                	test   %eax,%eax
  800bdf:	7e 17                	jle    800bf8 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be1:	83 ec 0c             	sub    $0xc,%esp
  800be4:	50                   	push   %eax
  800be5:	6a 06                	push   $0x6
  800be7:	68 5f 24 80 00       	push   $0x80245f
  800bec:	6a 23                	push   $0x23
  800bee:	68 7c 24 80 00       	push   $0x80247c
  800bf3:	e8 83 11 00 00       	call   801d7b <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bf8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bfb:	5b                   	pop    %ebx
  800bfc:	5e                   	pop    %esi
  800bfd:	5f                   	pop    %edi
  800bfe:	5d                   	pop    %ebp
  800bff:	c3                   	ret    

00800c00 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c00:	55                   	push   %ebp
  800c01:	89 e5                	mov    %esp,%ebp
  800c03:	57                   	push   %edi
  800c04:	56                   	push   %esi
  800c05:	53                   	push   %ebx
  800c06:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c09:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c0e:	b8 08 00 00 00       	mov    $0x8,%eax
  800c13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c16:	8b 55 08             	mov    0x8(%ebp),%edx
  800c19:	89 df                	mov    %ebx,%edi
  800c1b:	89 de                	mov    %ebx,%esi
  800c1d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c1f:	85 c0                	test   %eax,%eax
  800c21:	7e 17                	jle    800c3a <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c23:	83 ec 0c             	sub    $0xc,%esp
  800c26:	50                   	push   %eax
  800c27:	6a 08                	push   $0x8
  800c29:	68 5f 24 80 00       	push   $0x80245f
  800c2e:	6a 23                	push   $0x23
  800c30:	68 7c 24 80 00       	push   $0x80247c
  800c35:	e8 41 11 00 00       	call   801d7b <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3d:	5b                   	pop    %ebx
  800c3e:	5e                   	pop    %esi
  800c3f:	5f                   	pop    %edi
  800c40:	5d                   	pop    %ebp
  800c41:	c3                   	ret    

00800c42 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c42:	55                   	push   %ebp
  800c43:	89 e5                	mov    %esp,%ebp
  800c45:	57                   	push   %edi
  800c46:	56                   	push   %esi
  800c47:	53                   	push   %ebx
  800c48:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c50:	b8 09 00 00 00       	mov    $0x9,%eax
  800c55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c58:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5b:	89 df                	mov    %ebx,%edi
  800c5d:	89 de                	mov    %ebx,%esi
  800c5f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c61:	85 c0                	test   %eax,%eax
  800c63:	7e 17                	jle    800c7c <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c65:	83 ec 0c             	sub    $0xc,%esp
  800c68:	50                   	push   %eax
  800c69:	6a 09                	push   $0x9
  800c6b:	68 5f 24 80 00       	push   $0x80245f
  800c70:	6a 23                	push   $0x23
  800c72:	68 7c 24 80 00       	push   $0x80247c
  800c77:	e8 ff 10 00 00       	call   801d7b <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7f:	5b                   	pop    %ebx
  800c80:	5e                   	pop    %esi
  800c81:	5f                   	pop    %edi
  800c82:	5d                   	pop    %ebp
  800c83:	c3                   	ret    

00800c84 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c84:	55                   	push   %ebp
  800c85:	89 e5                	mov    %esp,%ebp
  800c87:	57                   	push   %edi
  800c88:	56                   	push   %esi
  800c89:	53                   	push   %ebx
  800c8a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c92:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9d:	89 df                	mov    %ebx,%edi
  800c9f:	89 de                	mov    %ebx,%esi
  800ca1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ca3:	85 c0                	test   %eax,%eax
  800ca5:	7e 17                	jle    800cbe <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca7:	83 ec 0c             	sub    $0xc,%esp
  800caa:	50                   	push   %eax
  800cab:	6a 0a                	push   $0xa
  800cad:	68 5f 24 80 00       	push   $0x80245f
  800cb2:	6a 23                	push   $0x23
  800cb4:	68 7c 24 80 00       	push   $0x80247c
  800cb9:	e8 bd 10 00 00       	call   801d7b <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cbe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc1:	5b                   	pop    %ebx
  800cc2:	5e                   	pop    %esi
  800cc3:	5f                   	pop    %edi
  800cc4:	5d                   	pop    %ebp
  800cc5:	c3                   	ret    

00800cc6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cc6:	55                   	push   %ebp
  800cc7:	89 e5                	mov    %esp,%ebp
  800cc9:	57                   	push   %edi
  800cca:	56                   	push   %esi
  800ccb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccc:	be 00 00 00 00       	mov    $0x0,%esi
  800cd1:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cd6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cdf:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ce2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ce4:	5b                   	pop    %ebx
  800ce5:	5e                   	pop    %esi
  800ce6:	5f                   	pop    %edi
  800ce7:	5d                   	pop    %ebp
  800ce8:	c3                   	ret    

00800ce9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ce9:	55                   	push   %ebp
  800cea:	89 e5                	mov    %esp,%ebp
  800cec:	57                   	push   %edi
  800ced:	56                   	push   %esi
  800cee:	53                   	push   %ebx
  800cef:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cf7:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cfc:	8b 55 08             	mov    0x8(%ebp),%edx
  800cff:	89 cb                	mov    %ecx,%ebx
  800d01:	89 cf                	mov    %ecx,%edi
  800d03:	89 ce                	mov    %ecx,%esi
  800d05:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d07:	85 c0                	test   %eax,%eax
  800d09:	7e 17                	jle    800d22 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0b:	83 ec 0c             	sub    $0xc,%esp
  800d0e:	50                   	push   %eax
  800d0f:	6a 0d                	push   $0xd
  800d11:	68 5f 24 80 00       	push   $0x80245f
  800d16:	6a 23                	push   $0x23
  800d18:	68 7c 24 80 00       	push   $0x80247c
  800d1d:	e8 59 10 00 00       	call   801d7b <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d22:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d25:	5b                   	pop    %ebx
  800d26:	5e                   	pop    %esi
  800d27:	5f                   	pop    %edi
  800d28:	5d                   	pop    %ebp
  800d29:	c3                   	ret    

00800d2a <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800d2a:	55                   	push   %ebp
  800d2b:	89 e5                	mov    %esp,%ebp
  800d2d:	56                   	push   %esi
  800d2e:	53                   	push   %ebx
	int r;

	// LAB 4: Your code here.
	// Check if page is writable or COW
	pte_t pte = uvpt[pn];
  800d2f:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
	uint32_t perm = PTE_P | PTE_U;
	if (pte && (PTE_COW | PTE_W)) {
		perm |= PTE_COW;
  800d36:	83 f9 01             	cmp    $0x1,%ecx
  800d39:	19 f6                	sbb    %esi,%esi
  800d3b:	81 e6 00 f8 ff ff    	and    $0xfffff800,%esi
  800d41:	81 c6 05 08 00 00    	add    $0x805,%esi
	}

	// Map page
	void *va = (void *) (pn * PGSIZE);
  800d47:	c1 e2 0c             	shl    $0xc,%edx
  800d4a:	89 d3                	mov    %edx,%ebx
	// Map on the child
	if ((r = sys_page_map(0, va, envid, va, perm)) < 0) {
  800d4c:	83 ec 0c             	sub    $0xc,%esp
  800d4f:	56                   	push   %esi
  800d50:	52                   	push   %edx
  800d51:	50                   	push   %eax
  800d52:	52                   	push   %edx
  800d53:	6a 00                	push   $0x0
  800d55:	e8 22 fe ff ff       	call   800b7c <sys_page_map>
  800d5a:	83 c4 20             	add    $0x20,%esp
  800d5d:	85 c0                	test   %eax,%eax
  800d5f:	79 12                	jns    800d73 <duppage+0x49>
		panic("sys_page_alloc: %e", r);
  800d61:	50                   	push   %eax
  800d62:	68 8a 24 80 00       	push   $0x80248a
  800d67:	6a 56                	push   $0x56
  800d69:	68 9d 24 80 00       	push   $0x80249d
  800d6e:	e8 08 10 00 00       	call   801d7b <_panic>
		return r;
	}

	// Change the permission on the parent
	if ((r = sys_page_map(0, va, 0, va, perm)) < 0) {
  800d73:	83 ec 0c             	sub    $0xc,%esp
  800d76:	56                   	push   %esi
  800d77:	53                   	push   %ebx
  800d78:	6a 00                	push   $0x0
  800d7a:	53                   	push   %ebx
  800d7b:	6a 00                	push   $0x0
  800d7d:	e8 fa fd ff ff       	call   800b7c <sys_page_map>
  800d82:	83 c4 20             	add    $0x20,%esp
  800d85:	85 c0                	test   %eax,%eax
  800d87:	79 12                	jns    800d9b <duppage+0x71>
		panic("sys_page_alloc: %e", r);
  800d89:	50                   	push   %eax
  800d8a:	68 8a 24 80 00       	push   $0x80248a
  800d8f:	6a 5c                	push   $0x5c
  800d91:	68 9d 24 80 00       	push   $0x80249d
  800d96:	e8 e0 0f 00 00       	call   801d7b <_panic>
		return r;
	}

	return 0;
}
  800d9b:	b8 00 00 00 00       	mov    $0x0,%eax
  800da0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800da3:	5b                   	pop    %ebx
  800da4:	5e                   	pop    %esi
  800da5:	5d                   	pop    %ebp
  800da6:	c3                   	ret    

00800da7 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800da7:	55                   	push   %ebp
  800da8:	89 e5                	mov    %esp,%ebp
  800daa:	53                   	push   %ebx
  800dab:	83 ec 04             	sub    $0x4,%esp
  800dae:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800db1:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	unsigned pn = ((uint32_t)addr)/PGSIZE;
  800db3:	89 da                	mov    %ebx,%edx
  800db5:	c1 ea 0c             	shr    $0xc,%edx
	pte_t pte = uvpt[pn];
  800db8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(err & FEC_WR) || !(pte & PTE_COW)) {
  800dbf:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800dc3:	74 05                	je     800dca <pgfault+0x23>
  800dc5:	f6 c6 08             	test   $0x8,%dh
  800dc8:	75 14                	jne    800dde <pgfault+0x37>
		panic("fork pgfault handler: does not handle this fault");
  800dca:	83 ec 04             	sub    $0x4,%esp
  800dcd:	68 0c 25 80 00       	push   $0x80250c
  800dd2:	6a 1f                	push   $0x1f
  800dd4:	68 9d 24 80 00       	push   $0x80249d
  800dd9:	e8 9d 0f 00 00       	call   801d7b <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// Allocate a new page, mapped at temp location
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  800dde:	83 ec 04             	sub    $0x4,%esp
  800de1:	6a 07                	push   $0x7
  800de3:	68 00 f0 7f 00       	push   $0x7ff000
  800de8:	6a 00                	push   $0x0
  800dea:	e8 4a fd ff ff       	call   800b39 <sys_page_alloc>
  800def:	83 c4 10             	add    $0x10,%esp
  800df2:	85 c0                	test   %eax,%eax
  800df4:	79 12                	jns    800e08 <pgfault+0x61>
		panic("sys_page_alloc: %e", r);
  800df6:	50                   	push   %eax
  800df7:	68 8a 24 80 00       	push   $0x80248a
  800dfc:	6a 2b                	push   $0x2b
  800dfe:	68 9d 24 80 00       	push   $0x80249d
  800e03:	e8 73 0f 00 00       	call   801d7b <_panic>

	// Copy the data from the old page to this new page
	void *addr_pgstart = (void *) ROUNDDOWN(addr, PGSIZE);
  800e08:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr_pgstart, PGSIZE);
  800e0e:	83 ec 04             	sub    $0x4,%esp
  800e11:	68 00 10 00 00       	push   $0x1000
  800e16:	53                   	push   %ebx
  800e17:	68 00 f0 7f 00       	push   $0x7ff000
  800e1c:	e8 a7 fa ff ff       	call   8008c8 <memmove>

	// Move the new page to the old page's address
	if ((r = sys_page_map(0, PFTEMP, 0, addr_pgstart, PTE_P|PTE_U|PTE_W)) < 0)
  800e21:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e28:	53                   	push   %ebx
  800e29:	6a 00                	push   $0x0
  800e2b:	68 00 f0 7f 00       	push   $0x7ff000
  800e30:	6a 00                	push   $0x0
  800e32:	e8 45 fd ff ff       	call   800b7c <sys_page_map>
  800e37:	83 c4 20             	add    $0x20,%esp
  800e3a:	85 c0                	test   %eax,%eax
  800e3c:	79 12                	jns    800e50 <pgfault+0xa9>
		panic("sys_page_map: %e", r);
  800e3e:	50                   	push   %eax
  800e3f:	68 a8 24 80 00       	push   $0x8024a8
  800e44:	6a 33                	push   $0x33
  800e46:	68 9d 24 80 00       	push   $0x80249d
  800e4b:	e8 2b 0f 00 00       	call   801d7b <_panic>

	// Unmap the temp location
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800e50:	83 ec 08             	sub    $0x8,%esp
  800e53:	68 00 f0 7f 00       	push   $0x7ff000
  800e58:	6a 00                	push   $0x0
  800e5a:	e8 5f fd ff ff       	call   800bbe <sys_page_unmap>
  800e5f:	83 c4 10             	add    $0x10,%esp
  800e62:	85 c0                	test   %eax,%eax
  800e64:	79 12                	jns    800e78 <pgfault+0xd1>
		panic("sys_page_unmap: %e", r);
  800e66:	50                   	push   %eax
  800e67:	68 b9 24 80 00       	push   $0x8024b9
  800e6c:	6a 37                	push   $0x37
  800e6e:	68 9d 24 80 00       	push   $0x80249d
  800e73:	e8 03 0f 00 00       	call   801d7b <_panic>
}
  800e78:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e7b:	c9                   	leave  
  800e7c:	c3                   	ret    

00800e7d <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e7d:	55                   	push   %ebp
  800e7e:	89 e5                	mov    %esp,%ebp
  800e80:	56                   	push   %esi
  800e81:	53                   	push   %ebx
  800e82:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
	// Set up page fault handler
	set_pgfault_handler(&pgfault);
  800e85:	68 a7 0d 80 00       	push   $0x800da7
  800e8a:	e8 32 0f 00 00       	call   801dc1 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800e8f:	b8 07 00 00 00       	mov    $0x7,%eax
  800e94:	cd 30                	int    $0x30

	// Create child
	envid_t envid = sys_exofork();
  800e96:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (envid < 0) {
  800e99:	83 c4 10             	add    $0x10,%esp
  800e9c:	85 c0                	test   %eax,%eax
  800e9e:	79 12                	jns    800eb2 <fork+0x35>
		panic("sys_exofork: %e", envid);
  800ea0:	50                   	push   %eax
  800ea1:	68 cc 24 80 00       	push   $0x8024cc
  800ea6:	6a 7d                	push   $0x7d
  800ea8:	68 9d 24 80 00       	push   $0x80249d
  800ead:	e8 c9 0e 00 00       	call   801d7b <_panic>
		return envid;
	}
	if (envid == 0) {
  800eb2:	85 c0                	test   %eax,%eax
  800eb4:	75 1e                	jne    800ed4 <fork+0x57>
		// We are the child.
		thisenv = &envs[ENVX(sys_getenvid())]; // Fix thisenv
  800eb6:	e8 40 fc ff ff       	call   800afb <sys_getenvid>
  800ebb:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ec0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800ec3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800ec8:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800ecd:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed2:	eb 7d                	jmp    800f51 <fork+0xd4>

	// Set page fault handler on the child.
	// The parent needs to do it, else the child wouldn't be able to handle
	// the fault when trying to access it's stack (which happens as soon it starts)
	extern void _pgfault_upcall(void);
	sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);
  800ed4:	83 ec 04             	sub    $0x4,%esp
  800ed7:	6a 07                	push   $0x7
  800ed9:	68 00 f0 bf ee       	push   $0xeebff000
  800ede:	50                   	push   %eax
  800edf:	e8 55 fc ff ff       	call   800b39 <sys_page_alloc>
	sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  800ee4:	83 c4 08             	add    $0x8,%esp
  800ee7:	68 06 1e 80 00       	push   $0x801e06
  800eec:	ff 75 f4             	pushl  -0xc(%ebp)
  800eef:	e8 90 fd ff ff       	call   800c84 <sys_env_set_pgfault_upcall>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  800ef4:	be 04 60 80 00       	mov    $0x806004,%esi
  800ef9:	c1 ee 0c             	shr    $0xc,%esi
  800efc:	83 c4 10             	add    $0x10,%esp
  800eff:	bb 00 08 00 00       	mov    $0x800,%ebx
  800f04:	eb 0d                	jmp    800f13 <fork+0x96>
		duppage(envid, pn);
  800f06:	89 da                	mov    %ebx,%edx
  800f08:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f0b:	e8 1a fe ff ff       	call   800d2a <duppage>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  800f10:	83 c3 01             	add    $0x1,%ebx
  800f13:	39 f3                	cmp    %esi,%ebx
  800f15:	76 ef                	jbe    800f06 <fork+0x89>
	}

	// Also copy the stack we are currently running on
	// I think it should loop from ustacktop to this page, since the stack
	// can have more than 1 page
	duppage(envid, ((uint32_t) &envid)/PGSIZE);
  800f17:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800f1a:	c1 ea 0c             	shr    $0xc,%edx
  800f1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f20:	e8 05 fe ff ff       	call   800d2a <duppage>

	// Start the child environmnet running
	int r;
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  800f25:	83 ec 08             	sub    $0x8,%esp
  800f28:	6a 02                	push   $0x2
  800f2a:	ff 75 f4             	pushl  -0xc(%ebp)
  800f2d:	e8 ce fc ff ff       	call   800c00 <sys_env_set_status>
  800f32:	83 c4 10             	add    $0x10,%esp
  800f35:	85 c0                	test   %eax,%eax
  800f37:	79 15                	jns    800f4e <fork+0xd1>
		panic("sys_env_set_status: %e", r);
  800f39:	50                   	push   %eax
  800f3a:	68 dc 24 80 00       	push   $0x8024dc
  800f3f:	68 9d 00 00 00       	push   $0x9d
  800f44:	68 9d 24 80 00       	push   $0x80249d
  800f49:	e8 2d 0e 00 00       	call   801d7b <_panic>
		return r;
	}

	return envid;
  800f4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800f51:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f54:	5b                   	pop    %ebx
  800f55:	5e                   	pop    %esi
  800f56:	5d                   	pop    %ebp
  800f57:	c3                   	ret    

00800f58 <sfork>:

// Challenge!
int
sfork(void)
{
  800f58:	55                   	push   %ebp
  800f59:	89 e5                	mov    %esp,%ebp
  800f5b:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800f5e:	68 f3 24 80 00       	push   $0x8024f3
  800f63:	68 a8 00 00 00       	push   $0xa8
  800f68:	68 9d 24 80 00       	push   $0x80249d
  800f6d:	e8 09 0e 00 00       	call   801d7b <_panic>

00800f72 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800f72:	55                   	push   %ebp
  800f73:	89 e5                	mov    %esp,%ebp
  800f75:	56                   	push   %esi
  800f76:	53                   	push   %ebx
  800f77:	8b 75 08             	mov    0x8(%ebp),%esi
  800f7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f7d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  800f80:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  800f82:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  800f87:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  800f8a:	83 ec 0c             	sub    $0xc,%esp
  800f8d:	50                   	push   %eax
  800f8e:	e8 56 fd ff ff       	call   800ce9 <sys_ipc_recv>

	if (r < 0) {
  800f93:	83 c4 10             	add    $0x10,%esp
  800f96:	85 c0                	test   %eax,%eax
  800f98:	79 16                	jns    800fb0 <ipc_recv+0x3e>
		if (from_env_store)
  800f9a:	85 f6                	test   %esi,%esi
  800f9c:	74 06                	je     800fa4 <ipc_recv+0x32>
			*from_env_store = 0;
  800f9e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  800fa4:	85 db                	test   %ebx,%ebx
  800fa6:	74 2c                	je     800fd4 <ipc_recv+0x62>
			*perm_store = 0;
  800fa8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800fae:	eb 24                	jmp    800fd4 <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  800fb0:	85 f6                	test   %esi,%esi
  800fb2:	74 0a                	je     800fbe <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  800fb4:	a1 04 40 80 00       	mov    0x804004,%eax
  800fb9:	8b 40 74             	mov    0x74(%eax),%eax
  800fbc:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  800fbe:	85 db                	test   %ebx,%ebx
  800fc0:	74 0a                	je     800fcc <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  800fc2:	a1 04 40 80 00       	mov    0x804004,%eax
  800fc7:	8b 40 78             	mov    0x78(%eax),%eax
  800fca:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  800fcc:	a1 04 40 80 00       	mov    0x804004,%eax
  800fd1:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  800fd4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fd7:	5b                   	pop    %ebx
  800fd8:	5e                   	pop    %esi
  800fd9:	5d                   	pop    %ebp
  800fda:	c3                   	ret    

00800fdb <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800fdb:	55                   	push   %ebp
  800fdc:	89 e5                	mov    %esp,%ebp
  800fde:	57                   	push   %edi
  800fdf:	56                   	push   %esi
  800fe0:	53                   	push   %ebx
  800fe1:	83 ec 0c             	sub    $0xc,%esp
  800fe4:	8b 7d 08             	mov    0x8(%ebp),%edi
  800fe7:	8b 75 0c             	mov    0xc(%ebp),%esi
  800fea:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  800fed:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  800fef:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  800ff4:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  800ff7:	ff 75 14             	pushl  0x14(%ebp)
  800ffa:	53                   	push   %ebx
  800ffb:	56                   	push   %esi
  800ffc:	57                   	push   %edi
  800ffd:	e8 c4 fc ff ff       	call   800cc6 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  801002:	83 c4 10             	add    $0x10,%esp
  801005:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801008:	75 07                	jne    801011 <ipc_send+0x36>
			sys_yield();
  80100a:	e8 0b fb ff ff       	call   800b1a <sys_yield>
  80100f:	eb e6                	jmp    800ff7 <ipc_send+0x1c>
		} else if (r < 0) {
  801011:	85 c0                	test   %eax,%eax
  801013:	79 12                	jns    801027 <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  801015:	50                   	push   %eax
  801016:	68 3d 25 80 00       	push   $0x80253d
  80101b:	6a 51                	push   $0x51
  80101d:	68 4a 25 80 00       	push   $0x80254a
  801022:	e8 54 0d 00 00       	call   801d7b <_panic>
		}
	}
}
  801027:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80102a:	5b                   	pop    %ebx
  80102b:	5e                   	pop    %esi
  80102c:	5f                   	pop    %edi
  80102d:	5d                   	pop    %ebp
  80102e:	c3                   	ret    

0080102f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80102f:	55                   	push   %ebp
  801030:	89 e5                	mov    %esp,%ebp
  801032:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801035:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80103a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80103d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801043:	8b 52 50             	mov    0x50(%edx),%edx
  801046:	39 ca                	cmp    %ecx,%edx
  801048:	75 0d                	jne    801057 <ipc_find_env+0x28>
			return envs[i].env_id;
  80104a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80104d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801052:	8b 40 48             	mov    0x48(%eax),%eax
  801055:	eb 0f                	jmp    801066 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801057:	83 c0 01             	add    $0x1,%eax
  80105a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80105f:	75 d9                	jne    80103a <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801061:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801066:	5d                   	pop    %ebp
  801067:	c3                   	ret    

00801068 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801068:	55                   	push   %ebp
  801069:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80106b:	8b 45 08             	mov    0x8(%ebp),%eax
  80106e:	05 00 00 00 30       	add    $0x30000000,%eax
  801073:	c1 e8 0c             	shr    $0xc,%eax
}
  801076:	5d                   	pop    %ebp
  801077:	c3                   	ret    

00801078 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801078:	55                   	push   %ebp
  801079:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80107b:	8b 45 08             	mov    0x8(%ebp),%eax
  80107e:	05 00 00 00 30       	add    $0x30000000,%eax
  801083:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801088:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80108d:	5d                   	pop    %ebp
  80108e:	c3                   	ret    

0080108f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80108f:	55                   	push   %ebp
  801090:	89 e5                	mov    %esp,%ebp
  801092:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801095:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80109a:	89 c2                	mov    %eax,%edx
  80109c:	c1 ea 16             	shr    $0x16,%edx
  80109f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010a6:	f6 c2 01             	test   $0x1,%dl
  8010a9:	74 11                	je     8010bc <fd_alloc+0x2d>
  8010ab:	89 c2                	mov    %eax,%edx
  8010ad:	c1 ea 0c             	shr    $0xc,%edx
  8010b0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010b7:	f6 c2 01             	test   $0x1,%dl
  8010ba:	75 09                	jne    8010c5 <fd_alloc+0x36>
			*fd_store = fd;
  8010bc:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010be:	b8 00 00 00 00       	mov    $0x0,%eax
  8010c3:	eb 17                	jmp    8010dc <fd_alloc+0x4d>
  8010c5:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010ca:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010cf:	75 c9                	jne    80109a <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8010d1:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8010d7:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8010dc:	5d                   	pop    %ebp
  8010dd:	c3                   	ret    

008010de <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010de:	55                   	push   %ebp
  8010df:	89 e5                	mov    %esp,%ebp
  8010e1:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010e4:	83 f8 1f             	cmp    $0x1f,%eax
  8010e7:	77 36                	ja     80111f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010e9:	c1 e0 0c             	shl    $0xc,%eax
  8010ec:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8010f1:	89 c2                	mov    %eax,%edx
  8010f3:	c1 ea 16             	shr    $0x16,%edx
  8010f6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010fd:	f6 c2 01             	test   $0x1,%dl
  801100:	74 24                	je     801126 <fd_lookup+0x48>
  801102:	89 c2                	mov    %eax,%edx
  801104:	c1 ea 0c             	shr    $0xc,%edx
  801107:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80110e:	f6 c2 01             	test   $0x1,%dl
  801111:	74 1a                	je     80112d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801113:	8b 55 0c             	mov    0xc(%ebp),%edx
  801116:	89 02                	mov    %eax,(%edx)
	return 0;
  801118:	b8 00 00 00 00       	mov    $0x0,%eax
  80111d:	eb 13                	jmp    801132 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80111f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801124:	eb 0c                	jmp    801132 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801126:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80112b:	eb 05                	jmp    801132 <fd_lookup+0x54>
  80112d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801132:	5d                   	pop    %ebp
  801133:	c3                   	ret    

00801134 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801134:	55                   	push   %ebp
  801135:	89 e5                	mov    %esp,%ebp
  801137:	83 ec 08             	sub    $0x8,%esp
  80113a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80113d:	ba d0 25 80 00       	mov    $0x8025d0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801142:	eb 13                	jmp    801157 <dev_lookup+0x23>
  801144:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801147:	39 08                	cmp    %ecx,(%eax)
  801149:	75 0c                	jne    801157 <dev_lookup+0x23>
			*dev = devtab[i];
  80114b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80114e:	89 01                	mov    %eax,(%ecx)
			return 0;
  801150:	b8 00 00 00 00       	mov    $0x0,%eax
  801155:	eb 2e                	jmp    801185 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801157:	8b 02                	mov    (%edx),%eax
  801159:	85 c0                	test   %eax,%eax
  80115b:	75 e7                	jne    801144 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80115d:	a1 04 40 80 00       	mov    0x804004,%eax
  801162:	8b 40 48             	mov    0x48(%eax),%eax
  801165:	83 ec 04             	sub    $0x4,%esp
  801168:	51                   	push   %ecx
  801169:	50                   	push   %eax
  80116a:	68 54 25 80 00       	push   $0x802554
  80116f:	e8 3d f0 ff ff       	call   8001b1 <cprintf>
	*dev = 0;
  801174:	8b 45 0c             	mov    0xc(%ebp),%eax
  801177:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80117d:	83 c4 10             	add    $0x10,%esp
  801180:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801185:	c9                   	leave  
  801186:	c3                   	ret    

00801187 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801187:	55                   	push   %ebp
  801188:	89 e5                	mov    %esp,%ebp
  80118a:	56                   	push   %esi
  80118b:	53                   	push   %ebx
  80118c:	83 ec 10             	sub    $0x10,%esp
  80118f:	8b 75 08             	mov    0x8(%ebp),%esi
  801192:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801195:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801198:	50                   	push   %eax
  801199:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80119f:	c1 e8 0c             	shr    $0xc,%eax
  8011a2:	50                   	push   %eax
  8011a3:	e8 36 ff ff ff       	call   8010de <fd_lookup>
  8011a8:	83 c4 08             	add    $0x8,%esp
  8011ab:	85 c0                	test   %eax,%eax
  8011ad:	78 05                	js     8011b4 <fd_close+0x2d>
	    || fd != fd2)
  8011af:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8011b2:	74 0c                	je     8011c0 <fd_close+0x39>
		return (must_exist ? r : 0);
  8011b4:	84 db                	test   %bl,%bl
  8011b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8011bb:	0f 44 c2             	cmove  %edx,%eax
  8011be:	eb 41                	jmp    801201 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011c0:	83 ec 08             	sub    $0x8,%esp
  8011c3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011c6:	50                   	push   %eax
  8011c7:	ff 36                	pushl  (%esi)
  8011c9:	e8 66 ff ff ff       	call   801134 <dev_lookup>
  8011ce:	89 c3                	mov    %eax,%ebx
  8011d0:	83 c4 10             	add    $0x10,%esp
  8011d3:	85 c0                	test   %eax,%eax
  8011d5:	78 1a                	js     8011f1 <fd_close+0x6a>
		if (dev->dev_close)
  8011d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011da:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8011dd:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8011e2:	85 c0                	test   %eax,%eax
  8011e4:	74 0b                	je     8011f1 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8011e6:	83 ec 0c             	sub    $0xc,%esp
  8011e9:	56                   	push   %esi
  8011ea:	ff d0                	call   *%eax
  8011ec:	89 c3                	mov    %eax,%ebx
  8011ee:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8011f1:	83 ec 08             	sub    $0x8,%esp
  8011f4:	56                   	push   %esi
  8011f5:	6a 00                	push   $0x0
  8011f7:	e8 c2 f9 ff ff       	call   800bbe <sys_page_unmap>
	return r;
  8011fc:	83 c4 10             	add    $0x10,%esp
  8011ff:	89 d8                	mov    %ebx,%eax
}
  801201:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801204:	5b                   	pop    %ebx
  801205:	5e                   	pop    %esi
  801206:	5d                   	pop    %ebp
  801207:	c3                   	ret    

00801208 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801208:	55                   	push   %ebp
  801209:	89 e5                	mov    %esp,%ebp
  80120b:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80120e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801211:	50                   	push   %eax
  801212:	ff 75 08             	pushl  0x8(%ebp)
  801215:	e8 c4 fe ff ff       	call   8010de <fd_lookup>
  80121a:	83 c4 08             	add    $0x8,%esp
  80121d:	85 c0                	test   %eax,%eax
  80121f:	78 10                	js     801231 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801221:	83 ec 08             	sub    $0x8,%esp
  801224:	6a 01                	push   $0x1
  801226:	ff 75 f4             	pushl  -0xc(%ebp)
  801229:	e8 59 ff ff ff       	call   801187 <fd_close>
  80122e:	83 c4 10             	add    $0x10,%esp
}
  801231:	c9                   	leave  
  801232:	c3                   	ret    

00801233 <close_all>:

void
close_all(void)
{
  801233:	55                   	push   %ebp
  801234:	89 e5                	mov    %esp,%ebp
  801236:	53                   	push   %ebx
  801237:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80123a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80123f:	83 ec 0c             	sub    $0xc,%esp
  801242:	53                   	push   %ebx
  801243:	e8 c0 ff ff ff       	call   801208 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801248:	83 c3 01             	add    $0x1,%ebx
  80124b:	83 c4 10             	add    $0x10,%esp
  80124e:	83 fb 20             	cmp    $0x20,%ebx
  801251:	75 ec                	jne    80123f <close_all+0xc>
		close(i);
}
  801253:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801256:	c9                   	leave  
  801257:	c3                   	ret    

00801258 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801258:	55                   	push   %ebp
  801259:	89 e5                	mov    %esp,%ebp
  80125b:	57                   	push   %edi
  80125c:	56                   	push   %esi
  80125d:	53                   	push   %ebx
  80125e:	83 ec 2c             	sub    $0x2c,%esp
  801261:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801264:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801267:	50                   	push   %eax
  801268:	ff 75 08             	pushl  0x8(%ebp)
  80126b:	e8 6e fe ff ff       	call   8010de <fd_lookup>
  801270:	83 c4 08             	add    $0x8,%esp
  801273:	85 c0                	test   %eax,%eax
  801275:	0f 88 c1 00 00 00    	js     80133c <dup+0xe4>
		return r;
	close(newfdnum);
  80127b:	83 ec 0c             	sub    $0xc,%esp
  80127e:	56                   	push   %esi
  80127f:	e8 84 ff ff ff       	call   801208 <close>

	newfd = INDEX2FD(newfdnum);
  801284:	89 f3                	mov    %esi,%ebx
  801286:	c1 e3 0c             	shl    $0xc,%ebx
  801289:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80128f:	83 c4 04             	add    $0x4,%esp
  801292:	ff 75 e4             	pushl  -0x1c(%ebp)
  801295:	e8 de fd ff ff       	call   801078 <fd2data>
  80129a:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80129c:	89 1c 24             	mov    %ebx,(%esp)
  80129f:	e8 d4 fd ff ff       	call   801078 <fd2data>
  8012a4:	83 c4 10             	add    $0x10,%esp
  8012a7:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012aa:	89 f8                	mov    %edi,%eax
  8012ac:	c1 e8 16             	shr    $0x16,%eax
  8012af:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012b6:	a8 01                	test   $0x1,%al
  8012b8:	74 37                	je     8012f1 <dup+0x99>
  8012ba:	89 f8                	mov    %edi,%eax
  8012bc:	c1 e8 0c             	shr    $0xc,%eax
  8012bf:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012c6:	f6 c2 01             	test   $0x1,%dl
  8012c9:	74 26                	je     8012f1 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012cb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012d2:	83 ec 0c             	sub    $0xc,%esp
  8012d5:	25 07 0e 00 00       	and    $0xe07,%eax
  8012da:	50                   	push   %eax
  8012db:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012de:	6a 00                	push   $0x0
  8012e0:	57                   	push   %edi
  8012e1:	6a 00                	push   $0x0
  8012e3:	e8 94 f8 ff ff       	call   800b7c <sys_page_map>
  8012e8:	89 c7                	mov    %eax,%edi
  8012ea:	83 c4 20             	add    $0x20,%esp
  8012ed:	85 c0                	test   %eax,%eax
  8012ef:	78 2e                	js     80131f <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012f1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8012f4:	89 d0                	mov    %edx,%eax
  8012f6:	c1 e8 0c             	shr    $0xc,%eax
  8012f9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801300:	83 ec 0c             	sub    $0xc,%esp
  801303:	25 07 0e 00 00       	and    $0xe07,%eax
  801308:	50                   	push   %eax
  801309:	53                   	push   %ebx
  80130a:	6a 00                	push   $0x0
  80130c:	52                   	push   %edx
  80130d:	6a 00                	push   $0x0
  80130f:	e8 68 f8 ff ff       	call   800b7c <sys_page_map>
  801314:	89 c7                	mov    %eax,%edi
  801316:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801319:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80131b:	85 ff                	test   %edi,%edi
  80131d:	79 1d                	jns    80133c <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80131f:	83 ec 08             	sub    $0x8,%esp
  801322:	53                   	push   %ebx
  801323:	6a 00                	push   $0x0
  801325:	e8 94 f8 ff ff       	call   800bbe <sys_page_unmap>
	sys_page_unmap(0, nva);
  80132a:	83 c4 08             	add    $0x8,%esp
  80132d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801330:	6a 00                	push   $0x0
  801332:	e8 87 f8 ff ff       	call   800bbe <sys_page_unmap>
	return r;
  801337:	83 c4 10             	add    $0x10,%esp
  80133a:	89 f8                	mov    %edi,%eax
}
  80133c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80133f:	5b                   	pop    %ebx
  801340:	5e                   	pop    %esi
  801341:	5f                   	pop    %edi
  801342:	5d                   	pop    %ebp
  801343:	c3                   	ret    

00801344 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801344:	55                   	push   %ebp
  801345:	89 e5                	mov    %esp,%ebp
  801347:	53                   	push   %ebx
  801348:	83 ec 14             	sub    $0x14,%esp
  80134b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80134e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801351:	50                   	push   %eax
  801352:	53                   	push   %ebx
  801353:	e8 86 fd ff ff       	call   8010de <fd_lookup>
  801358:	83 c4 08             	add    $0x8,%esp
  80135b:	89 c2                	mov    %eax,%edx
  80135d:	85 c0                	test   %eax,%eax
  80135f:	78 6d                	js     8013ce <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801361:	83 ec 08             	sub    $0x8,%esp
  801364:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801367:	50                   	push   %eax
  801368:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80136b:	ff 30                	pushl  (%eax)
  80136d:	e8 c2 fd ff ff       	call   801134 <dev_lookup>
  801372:	83 c4 10             	add    $0x10,%esp
  801375:	85 c0                	test   %eax,%eax
  801377:	78 4c                	js     8013c5 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801379:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80137c:	8b 42 08             	mov    0x8(%edx),%eax
  80137f:	83 e0 03             	and    $0x3,%eax
  801382:	83 f8 01             	cmp    $0x1,%eax
  801385:	75 21                	jne    8013a8 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801387:	a1 04 40 80 00       	mov    0x804004,%eax
  80138c:	8b 40 48             	mov    0x48(%eax),%eax
  80138f:	83 ec 04             	sub    $0x4,%esp
  801392:	53                   	push   %ebx
  801393:	50                   	push   %eax
  801394:	68 95 25 80 00       	push   $0x802595
  801399:	e8 13 ee ff ff       	call   8001b1 <cprintf>
		return -E_INVAL;
  80139e:	83 c4 10             	add    $0x10,%esp
  8013a1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013a6:	eb 26                	jmp    8013ce <read+0x8a>
	}
	if (!dev->dev_read)
  8013a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013ab:	8b 40 08             	mov    0x8(%eax),%eax
  8013ae:	85 c0                	test   %eax,%eax
  8013b0:	74 17                	je     8013c9 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013b2:	83 ec 04             	sub    $0x4,%esp
  8013b5:	ff 75 10             	pushl  0x10(%ebp)
  8013b8:	ff 75 0c             	pushl  0xc(%ebp)
  8013bb:	52                   	push   %edx
  8013bc:	ff d0                	call   *%eax
  8013be:	89 c2                	mov    %eax,%edx
  8013c0:	83 c4 10             	add    $0x10,%esp
  8013c3:	eb 09                	jmp    8013ce <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013c5:	89 c2                	mov    %eax,%edx
  8013c7:	eb 05                	jmp    8013ce <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8013c9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8013ce:	89 d0                	mov    %edx,%eax
  8013d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013d3:	c9                   	leave  
  8013d4:	c3                   	ret    

008013d5 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013d5:	55                   	push   %ebp
  8013d6:	89 e5                	mov    %esp,%ebp
  8013d8:	57                   	push   %edi
  8013d9:	56                   	push   %esi
  8013da:	53                   	push   %ebx
  8013db:	83 ec 0c             	sub    $0xc,%esp
  8013de:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013e1:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013e4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013e9:	eb 21                	jmp    80140c <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013eb:	83 ec 04             	sub    $0x4,%esp
  8013ee:	89 f0                	mov    %esi,%eax
  8013f0:	29 d8                	sub    %ebx,%eax
  8013f2:	50                   	push   %eax
  8013f3:	89 d8                	mov    %ebx,%eax
  8013f5:	03 45 0c             	add    0xc(%ebp),%eax
  8013f8:	50                   	push   %eax
  8013f9:	57                   	push   %edi
  8013fa:	e8 45 ff ff ff       	call   801344 <read>
		if (m < 0)
  8013ff:	83 c4 10             	add    $0x10,%esp
  801402:	85 c0                	test   %eax,%eax
  801404:	78 10                	js     801416 <readn+0x41>
			return m;
		if (m == 0)
  801406:	85 c0                	test   %eax,%eax
  801408:	74 0a                	je     801414 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80140a:	01 c3                	add    %eax,%ebx
  80140c:	39 f3                	cmp    %esi,%ebx
  80140e:	72 db                	jb     8013eb <readn+0x16>
  801410:	89 d8                	mov    %ebx,%eax
  801412:	eb 02                	jmp    801416 <readn+0x41>
  801414:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801416:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801419:	5b                   	pop    %ebx
  80141a:	5e                   	pop    %esi
  80141b:	5f                   	pop    %edi
  80141c:	5d                   	pop    %ebp
  80141d:	c3                   	ret    

0080141e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80141e:	55                   	push   %ebp
  80141f:	89 e5                	mov    %esp,%ebp
  801421:	53                   	push   %ebx
  801422:	83 ec 14             	sub    $0x14,%esp
  801425:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801428:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80142b:	50                   	push   %eax
  80142c:	53                   	push   %ebx
  80142d:	e8 ac fc ff ff       	call   8010de <fd_lookup>
  801432:	83 c4 08             	add    $0x8,%esp
  801435:	89 c2                	mov    %eax,%edx
  801437:	85 c0                	test   %eax,%eax
  801439:	78 68                	js     8014a3 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80143b:	83 ec 08             	sub    $0x8,%esp
  80143e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801441:	50                   	push   %eax
  801442:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801445:	ff 30                	pushl  (%eax)
  801447:	e8 e8 fc ff ff       	call   801134 <dev_lookup>
  80144c:	83 c4 10             	add    $0x10,%esp
  80144f:	85 c0                	test   %eax,%eax
  801451:	78 47                	js     80149a <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801453:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801456:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80145a:	75 21                	jne    80147d <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80145c:	a1 04 40 80 00       	mov    0x804004,%eax
  801461:	8b 40 48             	mov    0x48(%eax),%eax
  801464:	83 ec 04             	sub    $0x4,%esp
  801467:	53                   	push   %ebx
  801468:	50                   	push   %eax
  801469:	68 b1 25 80 00       	push   $0x8025b1
  80146e:	e8 3e ed ff ff       	call   8001b1 <cprintf>
		return -E_INVAL;
  801473:	83 c4 10             	add    $0x10,%esp
  801476:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80147b:	eb 26                	jmp    8014a3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80147d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801480:	8b 52 0c             	mov    0xc(%edx),%edx
  801483:	85 d2                	test   %edx,%edx
  801485:	74 17                	je     80149e <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801487:	83 ec 04             	sub    $0x4,%esp
  80148a:	ff 75 10             	pushl  0x10(%ebp)
  80148d:	ff 75 0c             	pushl  0xc(%ebp)
  801490:	50                   	push   %eax
  801491:	ff d2                	call   *%edx
  801493:	89 c2                	mov    %eax,%edx
  801495:	83 c4 10             	add    $0x10,%esp
  801498:	eb 09                	jmp    8014a3 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80149a:	89 c2                	mov    %eax,%edx
  80149c:	eb 05                	jmp    8014a3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80149e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8014a3:	89 d0                	mov    %edx,%eax
  8014a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014a8:	c9                   	leave  
  8014a9:	c3                   	ret    

008014aa <seek>:

int
seek(int fdnum, off_t offset)
{
  8014aa:	55                   	push   %ebp
  8014ab:	89 e5                	mov    %esp,%ebp
  8014ad:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014b0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014b3:	50                   	push   %eax
  8014b4:	ff 75 08             	pushl  0x8(%ebp)
  8014b7:	e8 22 fc ff ff       	call   8010de <fd_lookup>
  8014bc:	83 c4 08             	add    $0x8,%esp
  8014bf:	85 c0                	test   %eax,%eax
  8014c1:	78 0e                	js     8014d1 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8014c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014c6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014c9:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014cc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014d1:	c9                   	leave  
  8014d2:	c3                   	ret    

008014d3 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8014d3:	55                   	push   %ebp
  8014d4:	89 e5                	mov    %esp,%ebp
  8014d6:	53                   	push   %ebx
  8014d7:	83 ec 14             	sub    $0x14,%esp
  8014da:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014dd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014e0:	50                   	push   %eax
  8014e1:	53                   	push   %ebx
  8014e2:	e8 f7 fb ff ff       	call   8010de <fd_lookup>
  8014e7:	83 c4 08             	add    $0x8,%esp
  8014ea:	89 c2                	mov    %eax,%edx
  8014ec:	85 c0                	test   %eax,%eax
  8014ee:	78 65                	js     801555 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014f0:	83 ec 08             	sub    $0x8,%esp
  8014f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014f6:	50                   	push   %eax
  8014f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014fa:	ff 30                	pushl  (%eax)
  8014fc:	e8 33 fc ff ff       	call   801134 <dev_lookup>
  801501:	83 c4 10             	add    $0x10,%esp
  801504:	85 c0                	test   %eax,%eax
  801506:	78 44                	js     80154c <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801508:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80150b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80150f:	75 21                	jne    801532 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801511:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801516:	8b 40 48             	mov    0x48(%eax),%eax
  801519:	83 ec 04             	sub    $0x4,%esp
  80151c:	53                   	push   %ebx
  80151d:	50                   	push   %eax
  80151e:	68 74 25 80 00       	push   $0x802574
  801523:	e8 89 ec ff ff       	call   8001b1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801528:	83 c4 10             	add    $0x10,%esp
  80152b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801530:	eb 23                	jmp    801555 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801532:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801535:	8b 52 18             	mov    0x18(%edx),%edx
  801538:	85 d2                	test   %edx,%edx
  80153a:	74 14                	je     801550 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80153c:	83 ec 08             	sub    $0x8,%esp
  80153f:	ff 75 0c             	pushl  0xc(%ebp)
  801542:	50                   	push   %eax
  801543:	ff d2                	call   *%edx
  801545:	89 c2                	mov    %eax,%edx
  801547:	83 c4 10             	add    $0x10,%esp
  80154a:	eb 09                	jmp    801555 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80154c:	89 c2                	mov    %eax,%edx
  80154e:	eb 05                	jmp    801555 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801550:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801555:	89 d0                	mov    %edx,%eax
  801557:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80155a:	c9                   	leave  
  80155b:	c3                   	ret    

0080155c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80155c:	55                   	push   %ebp
  80155d:	89 e5                	mov    %esp,%ebp
  80155f:	53                   	push   %ebx
  801560:	83 ec 14             	sub    $0x14,%esp
  801563:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801566:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801569:	50                   	push   %eax
  80156a:	ff 75 08             	pushl  0x8(%ebp)
  80156d:	e8 6c fb ff ff       	call   8010de <fd_lookup>
  801572:	83 c4 08             	add    $0x8,%esp
  801575:	89 c2                	mov    %eax,%edx
  801577:	85 c0                	test   %eax,%eax
  801579:	78 58                	js     8015d3 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80157b:	83 ec 08             	sub    $0x8,%esp
  80157e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801581:	50                   	push   %eax
  801582:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801585:	ff 30                	pushl  (%eax)
  801587:	e8 a8 fb ff ff       	call   801134 <dev_lookup>
  80158c:	83 c4 10             	add    $0x10,%esp
  80158f:	85 c0                	test   %eax,%eax
  801591:	78 37                	js     8015ca <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801593:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801596:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80159a:	74 32                	je     8015ce <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80159c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80159f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015a6:	00 00 00 
	stat->st_isdir = 0;
  8015a9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015b0:	00 00 00 
	stat->st_dev = dev;
  8015b3:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015b9:	83 ec 08             	sub    $0x8,%esp
  8015bc:	53                   	push   %ebx
  8015bd:	ff 75 f0             	pushl  -0x10(%ebp)
  8015c0:	ff 50 14             	call   *0x14(%eax)
  8015c3:	89 c2                	mov    %eax,%edx
  8015c5:	83 c4 10             	add    $0x10,%esp
  8015c8:	eb 09                	jmp    8015d3 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ca:	89 c2                	mov    %eax,%edx
  8015cc:	eb 05                	jmp    8015d3 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8015ce:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8015d3:	89 d0                	mov    %edx,%eax
  8015d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015d8:	c9                   	leave  
  8015d9:	c3                   	ret    

008015da <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015da:	55                   	push   %ebp
  8015db:	89 e5                	mov    %esp,%ebp
  8015dd:	56                   	push   %esi
  8015de:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015df:	83 ec 08             	sub    $0x8,%esp
  8015e2:	6a 00                	push   $0x0
  8015e4:	ff 75 08             	pushl  0x8(%ebp)
  8015e7:	e8 0c 02 00 00       	call   8017f8 <open>
  8015ec:	89 c3                	mov    %eax,%ebx
  8015ee:	83 c4 10             	add    $0x10,%esp
  8015f1:	85 c0                	test   %eax,%eax
  8015f3:	78 1b                	js     801610 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8015f5:	83 ec 08             	sub    $0x8,%esp
  8015f8:	ff 75 0c             	pushl  0xc(%ebp)
  8015fb:	50                   	push   %eax
  8015fc:	e8 5b ff ff ff       	call   80155c <fstat>
  801601:	89 c6                	mov    %eax,%esi
	close(fd);
  801603:	89 1c 24             	mov    %ebx,(%esp)
  801606:	e8 fd fb ff ff       	call   801208 <close>
	return r;
  80160b:	83 c4 10             	add    $0x10,%esp
  80160e:	89 f0                	mov    %esi,%eax
}
  801610:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801613:	5b                   	pop    %ebx
  801614:	5e                   	pop    %esi
  801615:	5d                   	pop    %ebp
  801616:	c3                   	ret    

00801617 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801617:	55                   	push   %ebp
  801618:	89 e5                	mov    %esp,%ebp
  80161a:	56                   	push   %esi
  80161b:	53                   	push   %ebx
  80161c:	89 c6                	mov    %eax,%esi
  80161e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801620:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801627:	75 12                	jne    80163b <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801629:	83 ec 0c             	sub    $0xc,%esp
  80162c:	6a 01                	push   $0x1
  80162e:	e8 fc f9 ff ff       	call   80102f <ipc_find_env>
  801633:	a3 00 40 80 00       	mov    %eax,0x804000
  801638:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80163b:	6a 07                	push   $0x7
  80163d:	68 00 50 80 00       	push   $0x805000
  801642:	56                   	push   %esi
  801643:	ff 35 00 40 80 00    	pushl  0x804000
  801649:	e8 8d f9 ff ff       	call   800fdb <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80164e:	83 c4 0c             	add    $0xc,%esp
  801651:	6a 00                	push   $0x0
  801653:	53                   	push   %ebx
  801654:	6a 00                	push   $0x0
  801656:	e8 17 f9 ff ff       	call   800f72 <ipc_recv>
}
  80165b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80165e:	5b                   	pop    %ebx
  80165f:	5e                   	pop    %esi
  801660:	5d                   	pop    %ebp
  801661:	c3                   	ret    

00801662 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801662:	55                   	push   %ebp
  801663:	89 e5                	mov    %esp,%ebp
  801665:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801668:	8b 45 08             	mov    0x8(%ebp),%eax
  80166b:	8b 40 0c             	mov    0xc(%eax),%eax
  80166e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801673:	8b 45 0c             	mov    0xc(%ebp),%eax
  801676:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80167b:	ba 00 00 00 00       	mov    $0x0,%edx
  801680:	b8 02 00 00 00       	mov    $0x2,%eax
  801685:	e8 8d ff ff ff       	call   801617 <fsipc>
}
  80168a:	c9                   	leave  
  80168b:	c3                   	ret    

0080168c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80168c:	55                   	push   %ebp
  80168d:	89 e5                	mov    %esp,%ebp
  80168f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801692:	8b 45 08             	mov    0x8(%ebp),%eax
  801695:	8b 40 0c             	mov    0xc(%eax),%eax
  801698:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80169d:	ba 00 00 00 00       	mov    $0x0,%edx
  8016a2:	b8 06 00 00 00       	mov    $0x6,%eax
  8016a7:	e8 6b ff ff ff       	call   801617 <fsipc>
}
  8016ac:	c9                   	leave  
  8016ad:	c3                   	ret    

008016ae <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016ae:	55                   	push   %ebp
  8016af:	89 e5                	mov    %esp,%ebp
  8016b1:	53                   	push   %ebx
  8016b2:	83 ec 04             	sub    $0x4,%esp
  8016b5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8016bb:	8b 40 0c             	mov    0xc(%eax),%eax
  8016be:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8016c8:	b8 05 00 00 00       	mov    $0x5,%eax
  8016cd:	e8 45 ff ff ff       	call   801617 <fsipc>
  8016d2:	85 c0                	test   %eax,%eax
  8016d4:	78 2c                	js     801702 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016d6:	83 ec 08             	sub    $0x8,%esp
  8016d9:	68 00 50 80 00       	push   $0x805000
  8016de:	53                   	push   %ebx
  8016df:	e8 52 f0 ff ff       	call   800736 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016e4:	a1 80 50 80 00       	mov    0x805080,%eax
  8016e9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016ef:	a1 84 50 80 00       	mov    0x805084,%eax
  8016f4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8016fa:	83 c4 10             	add    $0x10,%esp
  8016fd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801702:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801705:	c9                   	leave  
  801706:	c3                   	ret    

00801707 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801707:	55                   	push   %ebp
  801708:	89 e5                	mov    %esp,%ebp
  80170a:	53                   	push   %ebx
  80170b:	83 ec 08             	sub    $0x8,%esp
  80170e:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801711:	8b 55 08             	mov    0x8(%ebp),%edx
  801714:	8b 52 0c             	mov    0xc(%edx),%edx
  801717:	89 15 00 50 80 00    	mov    %edx,0x805000
  80171d:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801722:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  801727:	0f 46 d8             	cmovbe %eax,%ebx
	
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  80172a:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  801730:	53                   	push   %ebx
  801731:	ff 75 0c             	pushl  0xc(%ebp)
  801734:	68 08 50 80 00       	push   $0x805008
  801739:	e8 8a f1 ff ff       	call   8008c8 <memmove>

	
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) 
  80173e:	ba 00 00 00 00       	mov    $0x0,%edx
  801743:	b8 04 00 00 00       	mov    $0x4,%eax
  801748:	e8 ca fe ff ff       	call   801617 <fsipc>
  80174d:	83 c4 10             	add    $0x10,%esp
  801750:	85 c0                	test   %eax,%eax
  801752:	78 1d                	js     801771 <devfile_write+0x6a>
		return r;
	assert(r <= n_real); 
  801754:	39 d8                	cmp    %ebx,%eax
  801756:	76 19                	jbe    801771 <devfile_write+0x6a>
  801758:	68 e0 25 80 00       	push   $0x8025e0
  80175d:	68 ec 25 80 00       	push   $0x8025ec
  801762:	68 a3 00 00 00       	push   $0xa3
  801767:	68 01 26 80 00       	push   $0x802601
  80176c:	e8 0a 06 00 00       	call   801d7b <_panic>
	return r;
}
  801771:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801774:	c9                   	leave  
  801775:	c3                   	ret    

00801776 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801776:	55                   	push   %ebp
  801777:	89 e5                	mov    %esp,%ebp
  801779:	56                   	push   %esi
  80177a:	53                   	push   %ebx
  80177b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80177e:	8b 45 08             	mov    0x8(%ebp),%eax
  801781:	8b 40 0c             	mov    0xc(%eax),%eax
  801784:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801789:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80178f:	ba 00 00 00 00       	mov    $0x0,%edx
  801794:	b8 03 00 00 00       	mov    $0x3,%eax
  801799:	e8 79 fe ff ff       	call   801617 <fsipc>
  80179e:	89 c3                	mov    %eax,%ebx
  8017a0:	85 c0                	test   %eax,%eax
  8017a2:	78 4b                	js     8017ef <devfile_read+0x79>
		return r;
	assert(r <= n);
  8017a4:	39 c6                	cmp    %eax,%esi
  8017a6:	73 16                	jae    8017be <devfile_read+0x48>
  8017a8:	68 0c 26 80 00       	push   $0x80260c
  8017ad:	68 ec 25 80 00       	push   $0x8025ec
  8017b2:	6a 7c                	push   $0x7c
  8017b4:	68 01 26 80 00       	push   $0x802601
  8017b9:	e8 bd 05 00 00       	call   801d7b <_panic>
	assert(r <= PGSIZE);
  8017be:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017c3:	7e 16                	jle    8017db <devfile_read+0x65>
  8017c5:	68 13 26 80 00       	push   $0x802613
  8017ca:	68 ec 25 80 00       	push   $0x8025ec
  8017cf:	6a 7d                	push   $0x7d
  8017d1:	68 01 26 80 00       	push   $0x802601
  8017d6:	e8 a0 05 00 00       	call   801d7b <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017db:	83 ec 04             	sub    $0x4,%esp
  8017de:	50                   	push   %eax
  8017df:	68 00 50 80 00       	push   $0x805000
  8017e4:	ff 75 0c             	pushl  0xc(%ebp)
  8017e7:	e8 dc f0 ff ff       	call   8008c8 <memmove>
	return r;
  8017ec:	83 c4 10             	add    $0x10,%esp
}
  8017ef:	89 d8                	mov    %ebx,%eax
  8017f1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017f4:	5b                   	pop    %ebx
  8017f5:	5e                   	pop    %esi
  8017f6:	5d                   	pop    %ebp
  8017f7:	c3                   	ret    

008017f8 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8017f8:	55                   	push   %ebp
  8017f9:	89 e5                	mov    %esp,%ebp
  8017fb:	53                   	push   %ebx
  8017fc:	83 ec 20             	sub    $0x20,%esp
  8017ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801802:	53                   	push   %ebx
  801803:	e8 f5 ee ff ff       	call   8006fd <strlen>
  801808:	83 c4 10             	add    $0x10,%esp
  80180b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801810:	7f 67                	jg     801879 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801812:	83 ec 0c             	sub    $0xc,%esp
  801815:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801818:	50                   	push   %eax
  801819:	e8 71 f8 ff ff       	call   80108f <fd_alloc>
  80181e:	83 c4 10             	add    $0x10,%esp
		return r;
  801821:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801823:	85 c0                	test   %eax,%eax
  801825:	78 57                	js     80187e <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801827:	83 ec 08             	sub    $0x8,%esp
  80182a:	53                   	push   %ebx
  80182b:	68 00 50 80 00       	push   $0x805000
  801830:	e8 01 ef ff ff       	call   800736 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801835:	8b 45 0c             	mov    0xc(%ebp),%eax
  801838:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80183d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801840:	b8 01 00 00 00       	mov    $0x1,%eax
  801845:	e8 cd fd ff ff       	call   801617 <fsipc>
  80184a:	89 c3                	mov    %eax,%ebx
  80184c:	83 c4 10             	add    $0x10,%esp
  80184f:	85 c0                	test   %eax,%eax
  801851:	79 14                	jns    801867 <open+0x6f>
		fd_close(fd, 0);
  801853:	83 ec 08             	sub    $0x8,%esp
  801856:	6a 00                	push   $0x0
  801858:	ff 75 f4             	pushl  -0xc(%ebp)
  80185b:	e8 27 f9 ff ff       	call   801187 <fd_close>
		return r;
  801860:	83 c4 10             	add    $0x10,%esp
  801863:	89 da                	mov    %ebx,%edx
  801865:	eb 17                	jmp    80187e <open+0x86>
	}

	return fd2num(fd);
  801867:	83 ec 0c             	sub    $0xc,%esp
  80186a:	ff 75 f4             	pushl  -0xc(%ebp)
  80186d:	e8 f6 f7 ff ff       	call   801068 <fd2num>
  801872:	89 c2                	mov    %eax,%edx
  801874:	83 c4 10             	add    $0x10,%esp
  801877:	eb 05                	jmp    80187e <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801879:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80187e:	89 d0                	mov    %edx,%eax
  801880:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801883:	c9                   	leave  
  801884:	c3                   	ret    

00801885 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801885:	55                   	push   %ebp
  801886:	89 e5                	mov    %esp,%ebp
  801888:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80188b:	ba 00 00 00 00       	mov    $0x0,%edx
  801890:	b8 08 00 00 00       	mov    $0x8,%eax
  801895:	e8 7d fd ff ff       	call   801617 <fsipc>
}
  80189a:	c9                   	leave  
  80189b:	c3                   	ret    

0080189c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80189c:	55                   	push   %ebp
  80189d:	89 e5                	mov    %esp,%ebp
  80189f:	56                   	push   %esi
  8018a0:	53                   	push   %ebx
  8018a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8018a4:	83 ec 0c             	sub    $0xc,%esp
  8018a7:	ff 75 08             	pushl  0x8(%ebp)
  8018aa:	e8 c9 f7 ff ff       	call   801078 <fd2data>
  8018af:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8018b1:	83 c4 08             	add    $0x8,%esp
  8018b4:	68 1f 26 80 00       	push   $0x80261f
  8018b9:	53                   	push   %ebx
  8018ba:	e8 77 ee ff ff       	call   800736 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8018bf:	8b 46 04             	mov    0x4(%esi),%eax
  8018c2:	2b 06                	sub    (%esi),%eax
  8018c4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8018ca:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018d1:	00 00 00 
	stat->st_dev = &devpipe;
  8018d4:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8018db:	30 80 00 
	return 0;
}
  8018de:	b8 00 00 00 00       	mov    $0x0,%eax
  8018e3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018e6:	5b                   	pop    %ebx
  8018e7:	5e                   	pop    %esi
  8018e8:	5d                   	pop    %ebp
  8018e9:	c3                   	ret    

008018ea <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8018ea:	55                   	push   %ebp
  8018eb:	89 e5                	mov    %esp,%ebp
  8018ed:	53                   	push   %ebx
  8018ee:	83 ec 0c             	sub    $0xc,%esp
  8018f1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8018f4:	53                   	push   %ebx
  8018f5:	6a 00                	push   $0x0
  8018f7:	e8 c2 f2 ff ff       	call   800bbe <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8018fc:	89 1c 24             	mov    %ebx,(%esp)
  8018ff:	e8 74 f7 ff ff       	call   801078 <fd2data>
  801904:	83 c4 08             	add    $0x8,%esp
  801907:	50                   	push   %eax
  801908:	6a 00                	push   $0x0
  80190a:	e8 af f2 ff ff       	call   800bbe <sys_page_unmap>
}
  80190f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801912:	c9                   	leave  
  801913:	c3                   	ret    

00801914 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801914:	55                   	push   %ebp
  801915:	89 e5                	mov    %esp,%ebp
  801917:	57                   	push   %edi
  801918:	56                   	push   %esi
  801919:	53                   	push   %ebx
  80191a:	83 ec 1c             	sub    $0x1c,%esp
  80191d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801920:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801922:	a1 04 40 80 00       	mov    0x804004,%eax
  801927:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80192a:	83 ec 0c             	sub    $0xc,%esp
  80192d:	ff 75 e0             	pushl  -0x20(%ebp)
  801930:	e8 02 05 00 00       	call   801e37 <pageref>
  801935:	89 c3                	mov    %eax,%ebx
  801937:	89 3c 24             	mov    %edi,(%esp)
  80193a:	e8 f8 04 00 00       	call   801e37 <pageref>
  80193f:	83 c4 10             	add    $0x10,%esp
  801942:	39 c3                	cmp    %eax,%ebx
  801944:	0f 94 c1             	sete   %cl
  801947:	0f b6 c9             	movzbl %cl,%ecx
  80194a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80194d:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801953:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801956:	39 ce                	cmp    %ecx,%esi
  801958:	74 1b                	je     801975 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80195a:	39 c3                	cmp    %eax,%ebx
  80195c:	75 c4                	jne    801922 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80195e:	8b 42 58             	mov    0x58(%edx),%eax
  801961:	ff 75 e4             	pushl  -0x1c(%ebp)
  801964:	50                   	push   %eax
  801965:	56                   	push   %esi
  801966:	68 26 26 80 00       	push   $0x802626
  80196b:	e8 41 e8 ff ff       	call   8001b1 <cprintf>
  801970:	83 c4 10             	add    $0x10,%esp
  801973:	eb ad                	jmp    801922 <_pipeisclosed+0xe>
	}
}
  801975:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801978:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80197b:	5b                   	pop    %ebx
  80197c:	5e                   	pop    %esi
  80197d:	5f                   	pop    %edi
  80197e:	5d                   	pop    %ebp
  80197f:	c3                   	ret    

00801980 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801980:	55                   	push   %ebp
  801981:	89 e5                	mov    %esp,%ebp
  801983:	57                   	push   %edi
  801984:	56                   	push   %esi
  801985:	53                   	push   %ebx
  801986:	83 ec 28             	sub    $0x28,%esp
  801989:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80198c:	56                   	push   %esi
  80198d:	e8 e6 f6 ff ff       	call   801078 <fd2data>
  801992:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801994:	83 c4 10             	add    $0x10,%esp
  801997:	bf 00 00 00 00       	mov    $0x0,%edi
  80199c:	eb 4b                	jmp    8019e9 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80199e:	89 da                	mov    %ebx,%edx
  8019a0:	89 f0                	mov    %esi,%eax
  8019a2:	e8 6d ff ff ff       	call   801914 <_pipeisclosed>
  8019a7:	85 c0                	test   %eax,%eax
  8019a9:	75 48                	jne    8019f3 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8019ab:	e8 6a f1 ff ff       	call   800b1a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8019b0:	8b 43 04             	mov    0x4(%ebx),%eax
  8019b3:	8b 0b                	mov    (%ebx),%ecx
  8019b5:	8d 51 20             	lea    0x20(%ecx),%edx
  8019b8:	39 d0                	cmp    %edx,%eax
  8019ba:	73 e2                	jae    80199e <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8019bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019bf:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8019c3:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8019c6:	89 c2                	mov    %eax,%edx
  8019c8:	c1 fa 1f             	sar    $0x1f,%edx
  8019cb:	89 d1                	mov    %edx,%ecx
  8019cd:	c1 e9 1b             	shr    $0x1b,%ecx
  8019d0:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8019d3:	83 e2 1f             	and    $0x1f,%edx
  8019d6:	29 ca                	sub    %ecx,%edx
  8019d8:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8019dc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8019e0:	83 c0 01             	add    $0x1,%eax
  8019e3:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019e6:	83 c7 01             	add    $0x1,%edi
  8019e9:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8019ec:	75 c2                	jne    8019b0 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8019ee:	8b 45 10             	mov    0x10(%ebp),%eax
  8019f1:	eb 05                	jmp    8019f8 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019f3:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8019f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019fb:	5b                   	pop    %ebx
  8019fc:	5e                   	pop    %esi
  8019fd:	5f                   	pop    %edi
  8019fe:	5d                   	pop    %ebp
  8019ff:	c3                   	ret    

00801a00 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a00:	55                   	push   %ebp
  801a01:	89 e5                	mov    %esp,%ebp
  801a03:	57                   	push   %edi
  801a04:	56                   	push   %esi
  801a05:	53                   	push   %ebx
  801a06:	83 ec 18             	sub    $0x18,%esp
  801a09:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a0c:	57                   	push   %edi
  801a0d:	e8 66 f6 ff ff       	call   801078 <fd2data>
  801a12:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a14:	83 c4 10             	add    $0x10,%esp
  801a17:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a1c:	eb 3d                	jmp    801a5b <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801a1e:	85 db                	test   %ebx,%ebx
  801a20:	74 04                	je     801a26 <devpipe_read+0x26>
				return i;
  801a22:	89 d8                	mov    %ebx,%eax
  801a24:	eb 44                	jmp    801a6a <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801a26:	89 f2                	mov    %esi,%edx
  801a28:	89 f8                	mov    %edi,%eax
  801a2a:	e8 e5 fe ff ff       	call   801914 <_pipeisclosed>
  801a2f:	85 c0                	test   %eax,%eax
  801a31:	75 32                	jne    801a65 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801a33:	e8 e2 f0 ff ff       	call   800b1a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801a38:	8b 06                	mov    (%esi),%eax
  801a3a:	3b 46 04             	cmp    0x4(%esi),%eax
  801a3d:	74 df                	je     801a1e <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a3f:	99                   	cltd   
  801a40:	c1 ea 1b             	shr    $0x1b,%edx
  801a43:	01 d0                	add    %edx,%eax
  801a45:	83 e0 1f             	and    $0x1f,%eax
  801a48:	29 d0                	sub    %edx,%eax
  801a4a:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801a4f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a52:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801a55:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a58:	83 c3 01             	add    $0x1,%ebx
  801a5b:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801a5e:	75 d8                	jne    801a38 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801a60:	8b 45 10             	mov    0x10(%ebp),%eax
  801a63:	eb 05                	jmp    801a6a <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a65:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801a6a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a6d:	5b                   	pop    %ebx
  801a6e:	5e                   	pop    %esi
  801a6f:	5f                   	pop    %edi
  801a70:	5d                   	pop    %ebp
  801a71:	c3                   	ret    

00801a72 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801a72:	55                   	push   %ebp
  801a73:	89 e5                	mov    %esp,%ebp
  801a75:	56                   	push   %esi
  801a76:	53                   	push   %ebx
  801a77:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a7a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a7d:	50                   	push   %eax
  801a7e:	e8 0c f6 ff ff       	call   80108f <fd_alloc>
  801a83:	83 c4 10             	add    $0x10,%esp
  801a86:	89 c2                	mov    %eax,%edx
  801a88:	85 c0                	test   %eax,%eax
  801a8a:	0f 88 2c 01 00 00    	js     801bbc <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a90:	83 ec 04             	sub    $0x4,%esp
  801a93:	68 07 04 00 00       	push   $0x407
  801a98:	ff 75 f4             	pushl  -0xc(%ebp)
  801a9b:	6a 00                	push   $0x0
  801a9d:	e8 97 f0 ff ff       	call   800b39 <sys_page_alloc>
  801aa2:	83 c4 10             	add    $0x10,%esp
  801aa5:	89 c2                	mov    %eax,%edx
  801aa7:	85 c0                	test   %eax,%eax
  801aa9:	0f 88 0d 01 00 00    	js     801bbc <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801aaf:	83 ec 0c             	sub    $0xc,%esp
  801ab2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ab5:	50                   	push   %eax
  801ab6:	e8 d4 f5 ff ff       	call   80108f <fd_alloc>
  801abb:	89 c3                	mov    %eax,%ebx
  801abd:	83 c4 10             	add    $0x10,%esp
  801ac0:	85 c0                	test   %eax,%eax
  801ac2:	0f 88 e2 00 00 00    	js     801baa <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ac8:	83 ec 04             	sub    $0x4,%esp
  801acb:	68 07 04 00 00       	push   $0x407
  801ad0:	ff 75 f0             	pushl  -0x10(%ebp)
  801ad3:	6a 00                	push   $0x0
  801ad5:	e8 5f f0 ff ff       	call   800b39 <sys_page_alloc>
  801ada:	89 c3                	mov    %eax,%ebx
  801adc:	83 c4 10             	add    $0x10,%esp
  801adf:	85 c0                	test   %eax,%eax
  801ae1:	0f 88 c3 00 00 00    	js     801baa <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801ae7:	83 ec 0c             	sub    $0xc,%esp
  801aea:	ff 75 f4             	pushl  -0xc(%ebp)
  801aed:	e8 86 f5 ff ff       	call   801078 <fd2data>
  801af2:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801af4:	83 c4 0c             	add    $0xc,%esp
  801af7:	68 07 04 00 00       	push   $0x407
  801afc:	50                   	push   %eax
  801afd:	6a 00                	push   $0x0
  801aff:	e8 35 f0 ff ff       	call   800b39 <sys_page_alloc>
  801b04:	89 c3                	mov    %eax,%ebx
  801b06:	83 c4 10             	add    $0x10,%esp
  801b09:	85 c0                	test   %eax,%eax
  801b0b:	0f 88 89 00 00 00    	js     801b9a <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b11:	83 ec 0c             	sub    $0xc,%esp
  801b14:	ff 75 f0             	pushl  -0x10(%ebp)
  801b17:	e8 5c f5 ff ff       	call   801078 <fd2data>
  801b1c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b23:	50                   	push   %eax
  801b24:	6a 00                	push   $0x0
  801b26:	56                   	push   %esi
  801b27:	6a 00                	push   $0x0
  801b29:	e8 4e f0 ff ff       	call   800b7c <sys_page_map>
  801b2e:	89 c3                	mov    %eax,%ebx
  801b30:	83 c4 20             	add    $0x20,%esp
  801b33:	85 c0                	test   %eax,%eax
  801b35:	78 55                	js     801b8c <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801b37:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b40:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b42:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b45:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b4c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b52:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b55:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b57:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b5a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801b61:	83 ec 0c             	sub    $0xc,%esp
  801b64:	ff 75 f4             	pushl  -0xc(%ebp)
  801b67:	e8 fc f4 ff ff       	call   801068 <fd2num>
  801b6c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b6f:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801b71:	83 c4 04             	add    $0x4,%esp
  801b74:	ff 75 f0             	pushl  -0x10(%ebp)
  801b77:	e8 ec f4 ff ff       	call   801068 <fd2num>
  801b7c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b7f:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801b82:	83 c4 10             	add    $0x10,%esp
  801b85:	ba 00 00 00 00       	mov    $0x0,%edx
  801b8a:	eb 30                	jmp    801bbc <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801b8c:	83 ec 08             	sub    $0x8,%esp
  801b8f:	56                   	push   %esi
  801b90:	6a 00                	push   $0x0
  801b92:	e8 27 f0 ff ff       	call   800bbe <sys_page_unmap>
  801b97:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801b9a:	83 ec 08             	sub    $0x8,%esp
  801b9d:	ff 75 f0             	pushl  -0x10(%ebp)
  801ba0:	6a 00                	push   $0x0
  801ba2:	e8 17 f0 ff ff       	call   800bbe <sys_page_unmap>
  801ba7:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801baa:	83 ec 08             	sub    $0x8,%esp
  801bad:	ff 75 f4             	pushl  -0xc(%ebp)
  801bb0:	6a 00                	push   $0x0
  801bb2:	e8 07 f0 ff ff       	call   800bbe <sys_page_unmap>
  801bb7:	83 c4 10             	add    $0x10,%esp
  801bba:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801bbc:	89 d0                	mov    %edx,%eax
  801bbe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bc1:	5b                   	pop    %ebx
  801bc2:	5e                   	pop    %esi
  801bc3:	5d                   	pop    %ebp
  801bc4:	c3                   	ret    

00801bc5 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801bc5:	55                   	push   %ebp
  801bc6:	89 e5                	mov    %esp,%ebp
  801bc8:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bcb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bce:	50                   	push   %eax
  801bcf:	ff 75 08             	pushl  0x8(%ebp)
  801bd2:	e8 07 f5 ff ff       	call   8010de <fd_lookup>
  801bd7:	83 c4 10             	add    $0x10,%esp
  801bda:	85 c0                	test   %eax,%eax
  801bdc:	78 18                	js     801bf6 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801bde:	83 ec 0c             	sub    $0xc,%esp
  801be1:	ff 75 f4             	pushl  -0xc(%ebp)
  801be4:	e8 8f f4 ff ff       	call   801078 <fd2data>
	return _pipeisclosed(fd, p);
  801be9:	89 c2                	mov    %eax,%edx
  801beb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bee:	e8 21 fd ff ff       	call   801914 <_pipeisclosed>
  801bf3:	83 c4 10             	add    $0x10,%esp
}
  801bf6:	c9                   	leave  
  801bf7:	c3                   	ret    

00801bf8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801bf8:	55                   	push   %ebp
  801bf9:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801bfb:	b8 00 00 00 00       	mov    $0x0,%eax
  801c00:	5d                   	pop    %ebp
  801c01:	c3                   	ret    

00801c02 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c02:	55                   	push   %ebp
  801c03:	89 e5                	mov    %esp,%ebp
  801c05:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801c08:	68 3e 26 80 00       	push   $0x80263e
  801c0d:	ff 75 0c             	pushl  0xc(%ebp)
  801c10:	e8 21 eb ff ff       	call   800736 <strcpy>
	return 0;
}
  801c15:	b8 00 00 00 00       	mov    $0x0,%eax
  801c1a:	c9                   	leave  
  801c1b:	c3                   	ret    

00801c1c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c1c:	55                   	push   %ebp
  801c1d:	89 e5                	mov    %esp,%ebp
  801c1f:	57                   	push   %edi
  801c20:	56                   	push   %esi
  801c21:	53                   	push   %ebx
  801c22:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c28:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c2d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c33:	eb 2d                	jmp    801c62 <devcons_write+0x46>
		m = n - tot;
  801c35:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c38:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801c3a:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801c3d:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801c42:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c45:	83 ec 04             	sub    $0x4,%esp
  801c48:	53                   	push   %ebx
  801c49:	03 45 0c             	add    0xc(%ebp),%eax
  801c4c:	50                   	push   %eax
  801c4d:	57                   	push   %edi
  801c4e:	e8 75 ec ff ff       	call   8008c8 <memmove>
		sys_cputs(buf, m);
  801c53:	83 c4 08             	add    $0x8,%esp
  801c56:	53                   	push   %ebx
  801c57:	57                   	push   %edi
  801c58:	e8 20 ee ff ff       	call   800a7d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c5d:	01 de                	add    %ebx,%esi
  801c5f:	83 c4 10             	add    $0x10,%esp
  801c62:	89 f0                	mov    %esi,%eax
  801c64:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c67:	72 cc                	jb     801c35 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801c69:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c6c:	5b                   	pop    %ebx
  801c6d:	5e                   	pop    %esi
  801c6e:	5f                   	pop    %edi
  801c6f:	5d                   	pop    %ebp
  801c70:	c3                   	ret    

00801c71 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c71:	55                   	push   %ebp
  801c72:	89 e5                	mov    %esp,%ebp
  801c74:	83 ec 08             	sub    $0x8,%esp
  801c77:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801c7c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c80:	74 2a                	je     801cac <devcons_read+0x3b>
  801c82:	eb 05                	jmp    801c89 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801c84:	e8 91 ee ff ff       	call   800b1a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801c89:	e8 0d ee ff ff       	call   800a9b <sys_cgetc>
  801c8e:	85 c0                	test   %eax,%eax
  801c90:	74 f2                	je     801c84 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801c92:	85 c0                	test   %eax,%eax
  801c94:	78 16                	js     801cac <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801c96:	83 f8 04             	cmp    $0x4,%eax
  801c99:	74 0c                	je     801ca7 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801c9b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c9e:	88 02                	mov    %al,(%edx)
	return 1;
  801ca0:	b8 01 00 00 00       	mov    $0x1,%eax
  801ca5:	eb 05                	jmp    801cac <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ca7:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801cac:	c9                   	leave  
  801cad:	c3                   	ret    

00801cae <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801cae:	55                   	push   %ebp
  801caf:	89 e5                	mov    %esp,%ebp
  801cb1:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801cb4:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb7:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801cba:	6a 01                	push   $0x1
  801cbc:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801cbf:	50                   	push   %eax
  801cc0:	e8 b8 ed ff ff       	call   800a7d <sys_cputs>
}
  801cc5:	83 c4 10             	add    $0x10,%esp
  801cc8:	c9                   	leave  
  801cc9:	c3                   	ret    

00801cca <getchar>:

int
getchar(void)
{
  801cca:	55                   	push   %ebp
  801ccb:	89 e5                	mov    %esp,%ebp
  801ccd:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801cd0:	6a 01                	push   $0x1
  801cd2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801cd5:	50                   	push   %eax
  801cd6:	6a 00                	push   $0x0
  801cd8:	e8 67 f6 ff ff       	call   801344 <read>
	if (r < 0)
  801cdd:	83 c4 10             	add    $0x10,%esp
  801ce0:	85 c0                	test   %eax,%eax
  801ce2:	78 0f                	js     801cf3 <getchar+0x29>
		return r;
	if (r < 1)
  801ce4:	85 c0                	test   %eax,%eax
  801ce6:	7e 06                	jle    801cee <getchar+0x24>
		return -E_EOF;
	return c;
  801ce8:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801cec:	eb 05                	jmp    801cf3 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801cee:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801cf3:	c9                   	leave  
  801cf4:	c3                   	ret    

00801cf5 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801cf5:	55                   	push   %ebp
  801cf6:	89 e5                	mov    %esp,%ebp
  801cf8:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cfb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cfe:	50                   	push   %eax
  801cff:	ff 75 08             	pushl  0x8(%ebp)
  801d02:	e8 d7 f3 ff ff       	call   8010de <fd_lookup>
  801d07:	83 c4 10             	add    $0x10,%esp
  801d0a:	85 c0                	test   %eax,%eax
  801d0c:	78 11                	js     801d1f <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801d0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d11:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d17:	39 10                	cmp    %edx,(%eax)
  801d19:	0f 94 c0             	sete   %al
  801d1c:	0f b6 c0             	movzbl %al,%eax
}
  801d1f:	c9                   	leave  
  801d20:	c3                   	ret    

00801d21 <opencons>:

int
opencons(void)
{
  801d21:	55                   	push   %ebp
  801d22:	89 e5                	mov    %esp,%ebp
  801d24:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d27:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d2a:	50                   	push   %eax
  801d2b:	e8 5f f3 ff ff       	call   80108f <fd_alloc>
  801d30:	83 c4 10             	add    $0x10,%esp
		return r;
  801d33:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d35:	85 c0                	test   %eax,%eax
  801d37:	78 3e                	js     801d77 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d39:	83 ec 04             	sub    $0x4,%esp
  801d3c:	68 07 04 00 00       	push   $0x407
  801d41:	ff 75 f4             	pushl  -0xc(%ebp)
  801d44:	6a 00                	push   $0x0
  801d46:	e8 ee ed ff ff       	call   800b39 <sys_page_alloc>
  801d4b:	83 c4 10             	add    $0x10,%esp
		return r;
  801d4e:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d50:	85 c0                	test   %eax,%eax
  801d52:	78 23                	js     801d77 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801d54:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d5d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d62:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801d69:	83 ec 0c             	sub    $0xc,%esp
  801d6c:	50                   	push   %eax
  801d6d:	e8 f6 f2 ff ff       	call   801068 <fd2num>
  801d72:	89 c2                	mov    %eax,%edx
  801d74:	83 c4 10             	add    $0x10,%esp
}
  801d77:	89 d0                	mov    %edx,%eax
  801d79:	c9                   	leave  
  801d7a:	c3                   	ret    

00801d7b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801d7b:	55                   	push   %ebp
  801d7c:	89 e5                	mov    %esp,%ebp
  801d7e:	56                   	push   %esi
  801d7f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801d80:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801d83:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801d89:	e8 6d ed ff ff       	call   800afb <sys_getenvid>
  801d8e:	83 ec 0c             	sub    $0xc,%esp
  801d91:	ff 75 0c             	pushl  0xc(%ebp)
  801d94:	ff 75 08             	pushl  0x8(%ebp)
  801d97:	56                   	push   %esi
  801d98:	50                   	push   %eax
  801d99:	68 4c 26 80 00       	push   $0x80264c
  801d9e:	e8 0e e4 ff ff       	call   8001b1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801da3:	83 c4 18             	add    $0x18,%esp
  801da6:	53                   	push   %ebx
  801da7:	ff 75 10             	pushl  0x10(%ebp)
  801daa:	e8 b1 e3 ff ff       	call   800160 <vcprintf>
	cprintf("\n");
  801daf:	c7 04 24 37 26 80 00 	movl   $0x802637,(%esp)
  801db6:	e8 f6 e3 ff ff       	call   8001b1 <cprintf>
  801dbb:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801dbe:	cc                   	int3   
  801dbf:	eb fd                	jmp    801dbe <_panic+0x43>

00801dc1 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801dc1:	55                   	push   %ebp
  801dc2:	89 e5                	mov    %esp,%ebp
  801dc4:	53                   	push   %ebx
  801dc5:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  801dc8:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801dcf:	75 28                	jne    801df9 <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  801dd1:	e8 25 ed ff ff       	call   800afb <sys_getenvid>
  801dd6:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_U | PTE_W);
  801dd8:	83 ec 04             	sub    $0x4,%esp
  801ddb:	6a 06                	push   $0x6
  801ddd:	68 00 f0 bf ee       	push   $0xeebff000
  801de2:	50                   	push   %eax
  801de3:	e8 51 ed ff ff       	call   800b39 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  801de8:	83 c4 08             	add    $0x8,%esp
  801deb:	68 06 1e 80 00       	push   $0x801e06
  801df0:	53                   	push   %ebx
  801df1:	e8 8e ee ff ff       	call   800c84 <sys_env_set_pgfault_upcall>
  801df6:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801df9:	8b 45 08             	mov    0x8(%ebp),%eax
  801dfc:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801e01:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e04:	c9                   	leave  
  801e05:	c3                   	ret    

00801e06 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e06:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e07:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e0c:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e0e:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	# My method is different. Copy the values to the other stack
	# in a convinient way, and then pop everything.
	movl %esp, %ebp		# ebp refers to the exception stack
  801e11:	89 e5                	mov    %esp,%ebp
	movl 48(%ebp), %esp 	# go to other stack
  801e13:	8b 65 30             	mov    0x30(%ebp),%esp

	pushl 40(%ebp)		# eip - ORDER SWITCHED WITH EFLAGS
  801e16:	ff 75 28             	pushl  0x28(%ebp)
	pushl 44(%ebp)      	# eflags
  801e19:	ff 75 2c             	pushl  0x2c(%ebp)
	pushl 36(%ebp)		# all the 8 remaining regs
  801e1c:	ff 75 24             	pushl  0x24(%ebp)
	pushl 32(%ebp)
  801e1f:	ff 75 20             	pushl  0x20(%ebp)
	pushl 28(%ebp)
  801e22:	ff 75 1c             	pushl  0x1c(%ebp)
	pushl 24(%ebp)
  801e25:	ff 75 18             	pushl  0x18(%ebp)
	pushl 20(%ebp)
  801e28:	ff 75 14             	pushl  0x14(%ebp)
	pushl 16(%ebp)
  801e2b:	ff 75 10             	pushl  0x10(%ebp)
	pushl 12(%ebp)
  801e2e:	ff 75 0c             	pushl  0xc(%ebp)
	pushl 8(%ebp)
  801e31:	ff 75 08             	pushl  0x8(%ebp)

	popal			# now just pop everything!
  801e34:	61                   	popa   
	popfl
  801e35:	9d                   	popf   
	ret
  801e36:	c3                   	ret    

00801e37 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801e37:	55                   	push   %ebp
  801e38:	89 e5                	mov    %esp,%ebp
  801e3a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e3d:	89 d0                	mov    %edx,%eax
  801e3f:	c1 e8 16             	shr    $0x16,%eax
  801e42:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801e49:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e4e:	f6 c1 01             	test   $0x1,%cl
  801e51:	74 1d                	je     801e70 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801e53:	c1 ea 0c             	shr    $0xc,%edx
  801e56:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801e5d:	f6 c2 01             	test   $0x1,%dl
  801e60:	74 0e                	je     801e70 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801e62:	c1 ea 0c             	shr    $0xc,%edx
  801e65:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801e6c:	ef 
  801e6d:	0f b7 c0             	movzwl %ax,%eax
}
  801e70:	5d                   	pop    %ebp
  801e71:	c3                   	ret    
  801e72:	66 90                	xchg   %ax,%ax
  801e74:	66 90                	xchg   %ax,%ax
  801e76:	66 90                	xchg   %ax,%ax
  801e78:	66 90                	xchg   %ax,%ax
  801e7a:	66 90                	xchg   %ax,%ax
  801e7c:	66 90                	xchg   %ax,%ax
  801e7e:	66 90                	xchg   %ax,%ax

00801e80 <__udivdi3>:
  801e80:	55                   	push   %ebp
  801e81:	57                   	push   %edi
  801e82:	56                   	push   %esi
  801e83:	53                   	push   %ebx
  801e84:	83 ec 1c             	sub    $0x1c,%esp
  801e87:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801e8b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801e8f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801e93:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801e97:	85 f6                	test   %esi,%esi
  801e99:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e9d:	89 ca                	mov    %ecx,%edx
  801e9f:	89 f8                	mov    %edi,%eax
  801ea1:	75 3d                	jne    801ee0 <__udivdi3+0x60>
  801ea3:	39 cf                	cmp    %ecx,%edi
  801ea5:	0f 87 c5 00 00 00    	ja     801f70 <__udivdi3+0xf0>
  801eab:	85 ff                	test   %edi,%edi
  801ead:	89 fd                	mov    %edi,%ebp
  801eaf:	75 0b                	jne    801ebc <__udivdi3+0x3c>
  801eb1:	b8 01 00 00 00       	mov    $0x1,%eax
  801eb6:	31 d2                	xor    %edx,%edx
  801eb8:	f7 f7                	div    %edi
  801eba:	89 c5                	mov    %eax,%ebp
  801ebc:	89 c8                	mov    %ecx,%eax
  801ebe:	31 d2                	xor    %edx,%edx
  801ec0:	f7 f5                	div    %ebp
  801ec2:	89 c1                	mov    %eax,%ecx
  801ec4:	89 d8                	mov    %ebx,%eax
  801ec6:	89 cf                	mov    %ecx,%edi
  801ec8:	f7 f5                	div    %ebp
  801eca:	89 c3                	mov    %eax,%ebx
  801ecc:	89 d8                	mov    %ebx,%eax
  801ece:	89 fa                	mov    %edi,%edx
  801ed0:	83 c4 1c             	add    $0x1c,%esp
  801ed3:	5b                   	pop    %ebx
  801ed4:	5e                   	pop    %esi
  801ed5:	5f                   	pop    %edi
  801ed6:	5d                   	pop    %ebp
  801ed7:	c3                   	ret    
  801ed8:	90                   	nop
  801ed9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ee0:	39 ce                	cmp    %ecx,%esi
  801ee2:	77 74                	ja     801f58 <__udivdi3+0xd8>
  801ee4:	0f bd fe             	bsr    %esi,%edi
  801ee7:	83 f7 1f             	xor    $0x1f,%edi
  801eea:	0f 84 98 00 00 00    	je     801f88 <__udivdi3+0x108>
  801ef0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801ef5:	89 f9                	mov    %edi,%ecx
  801ef7:	89 c5                	mov    %eax,%ebp
  801ef9:	29 fb                	sub    %edi,%ebx
  801efb:	d3 e6                	shl    %cl,%esi
  801efd:	89 d9                	mov    %ebx,%ecx
  801eff:	d3 ed                	shr    %cl,%ebp
  801f01:	89 f9                	mov    %edi,%ecx
  801f03:	d3 e0                	shl    %cl,%eax
  801f05:	09 ee                	or     %ebp,%esi
  801f07:	89 d9                	mov    %ebx,%ecx
  801f09:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f0d:	89 d5                	mov    %edx,%ebp
  801f0f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801f13:	d3 ed                	shr    %cl,%ebp
  801f15:	89 f9                	mov    %edi,%ecx
  801f17:	d3 e2                	shl    %cl,%edx
  801f19:	89 d9                	mov    %ebx,%ecx
  801f1b:	d3 e8                	shr    %cl,%eax
  801f1d:	09 c2                	or     %eax,%edx
  801f1f:	89 d0                	mov    %edx,%eax
  801f21:	89 ea                	mov    %ebp,%edx
  801f23:	f7 f6                	div    %esi
  801f25:	89 d5                	mov    %edx,%ebp
  801f27:	89 c3                	mov    %eax,%ebx
  801f29:	f7 64 24 0c          	mull   0xc(%esp)
  801f2d:	39 d5                	cmp    %edx,%ebp
  801f2f:	72 10                	jb     801f41 <__udivdi3+0xc1>
  801f31:	8b 74 24 08          	mov    0x8(%esp),%esi
  801f35:	89 f9                	mov    %edi,%ecx
  801f37:	d3 e6                	shl    %cl,%esi
  801f39:	39 c6                	cmp    %eax,%esi
  801f3b:	73 07                	jae    801f44 <__udivdi3+0xc4>
  801f3d:	39 d5                	cmp    %edx,%ebp
  801f3f:	75 03                	jne    801f44 <__udivdi3+0xc4>
  801f41:	83 eb 01             	sub    $0x1,%ebx
  801f44:	31 ff                	xor    %edi,%edi
  801f46:	89 d8                	mov    %ebx,%eax
  801f48:	89 fa                	mov    %edi,%edx
  801f4a:	83 c4 1c             	add    $0x1c,%esp
  801f4d:	5b                   	pop    %ebx
  801f4e:	5e                   	pop    %esi
  801f4f:	5f                   	pop    %edi
  801f50:	5d                   	pop    %ebp
  801f51:	c3                   	ret    
  801f52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801f58:	31 ff                	xor    %edi,%edi
  801f5a:	31 db                	xor    %ebx,%ebx
  801f5c:	89 d8                	mov    %ebx,%eax
  801f5e:	89 fa                	mov    %edi,%edx
  801f60:	83 c4 1c             	add    $0x1c,%esp
  801f63:	5b                   	pop    %ebx
  801f64:	5e                   	pop    %esi
  801f65:	5f                   	pop    %edi
  801f66:	5d                   	pop    %ebp
  801f67:	c3                   	ret    
  801f68:	90                   	nop
  801f69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f70:	89 d8                	mov    %ebx,%eax
  801f72:	f7 f7                	div    %edi
  801f74:	31 ff                	xor    %edi,%edi
  801f76:	89 c3                	mov    %eax,%ebx
  801f78:	89 d8                	mov    %ebx,%eax
  801f7a:	89 fa                	mov    %edi,%edx
  801f7c:	83 c4 1c             	add    $0x1c,%esp
  801f7f:	5b                   	pop    %ebx
  801f80:	5e                   	pop    %esi
  801f81:	5f                   	pop    %edi
  801f82:	5d                   	pop    %ebp
  801f83:	c3                   	ret    
  801f84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f88:	39 ce                	cmp    %ecx,%esi
  801f8a:	72 0c                	jb     801f98 <__udivdi3+0x118>
  801f8c:	31 db                	xor    %ebx,%ebx
  801f8e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801f92:	0f 87 34 ff ff ff    	ja     801ecc <__udivdi3+0x4c>
  801f98:	bb 01 00 00 00       	mov    $0x1,%ebx
  801f9d:	e9 2a ff ff ff       	jmp    801ecc <__udivdi3+0x4c>
  801fa2:	66 90                	xchg   %ax,%ax
  801fa4:	66 90                	xchg   %ax,%ax
  801fa6:	66 90                	xchg   %ax,%ax
  801fa8:	66 90                	xchg   %ax,%ax
  801faa:	66 90                	xchg   %ax,%ax
  801fac:	66 90                	xchg   %ax,%ax
  801fae:	66 90                	xchg   %ax,%ax

00801fb0 <__umoddi3>:
  801fb0:	55                   	push   %ebp
  801fb1:	57                   	push   %edi
  801fb2:	56                   	push   %esi
  801fb3:	53                   	push   %ebx
  801fb4:	83 ec 1c             	sub    $0x1c,%esp
  801fb7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801fbb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801fbf:	8b 74 24 34          	mov    0x34(%esp),%esi
  801fc3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801fc7:	85 d2                	test   %edx,%edx
  801fc9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801fcd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801fd1:	89 f3                	mov    %esi,%ebx
  801fd3:	89 3c 24             	mov    %edi,(%esp)
  801fd6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801fda:	75 1c                	jne    801ff8 <__umoddi3+0x48>
  801fdc:	39 f7                	cmp    %esi,%edi
  801fde:	76 50                	jbe    802030 <__umoddi3+0x80>
  801fe0:	89 c8                	mov    %ecx,%eax
  801fe2:	89 f2                	mov    %esi,%edx
  801fe4:	f7 f7                	div    %edi
  801fe6:	89 d0                	mov    %edx,%eax
  801fe8:	31 d2                	xor    %edx,%edx
  801fea:	83 c4 1c             	add    $0x1c,%esp
  801fed:	5b                   	pop    %ebx
  801fee:	5e                   	pop    %esi
  801fef:	5f                   	pop    %edi
  801ff0:	5d                   	pop    %ebp
  801ff1:	c3                   	ret    
  801ff2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ff8:	39 f2                	cmp    %esi,%edx
  801ffa:	89 d0                	mov    %edx,%eax
  801ffc:	77 52                	ja     802050 <__umoddi3+0xa0>
  801ffe:	0f bd ea             	bsr    %edx,%ebp
  802001:	83 f5 1f             	xor    $0x1f,%ebp
  802004:	75 5a                	jne    802060 <__umoddi3+0xb0>
  802006:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80200a:	0f 82 e0 00 00 00    	jb     8020f0 <__umoddi3+0x140>
  802010:	39 0c 24             	cmp    %ecx,(%esp)
  802013:	0f 86 d7 00 00 00    	jbe    8020f0 <__umoddi3+0x140>
  802019:	8b 44 24 08          	mov    0x8(%esp),%eax
  80201d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802021:	83 c4 1c             	add    $0x1c,%esp
  802024:	5b                   	pop    %ebx
  802025:	5e                   	pop    %esi
  802026:	5f                   	pop    %edi
  802027:	5d                   	pop    %ebp
  802028:	c3                   	ret    
  802029:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802030:	85 ff                	test   %edi,%edi
  802032:	89 fd                	mov    %edi,%ebp
  802034:	75 0b                	jne    802041 <__umoddi3+0x91>
  802036:	b8 01 00 00 00       	mov    $0x1,%eax
  80203b:	31 d2                	xor    %edx,%edx
  80203d:	f7 f7                	div    %edi
  80203f:	89 c5                	mov    %eax,%ebp
  802041:	89 f0                	mov    %esi,%eax
  802043:	31 d2                	xor    %edx,%edx
  802045:	f7 f5                	div    %ebp
  802047:	89 c8                	mov    %ecx,%eax
  802049:	f7 f5                	div    %ebp
  80204b:	89 d0                	mov    %edx,%eax
  80204d:	eb 99                	jmp    801fe8 <__umoddi3+0x38>
  80204f:	90                   	nop
  802050:	89 c8                	mov    %ecx,%eax
  802052:	89 f2                	mov    %esi,%edx
  802054:	83 c4 1c             	add    $0x1c,%esp
  802057:	5b                   	pop    %ebx
  802058:	5e                   	pop    %esi
  802059:	5f                   	pop    %edi
  80205a:	5d                   	pop    %ebp
  80205b:	c3                   	ret    
  80205c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802060:	8b 34 24             	mov    (%esp),%esi
  802063:	bf 20 00 00 00       	mov    $0x20,%edi
  802068:	89 e9                	mov    %ebp,%ecx
  80206a:	29 ef                	sub    %ebp,%edi
  80206c:	d3 e0                	shl    %cl,%eax
  80206e:	89 f9                	mov    %edi,%ecx
  802070:	89 f2                	mov    %esi,%edx
  802072:	d3 ea                	shr    %cl,%edx
  802074:	89 e9                	mov    %ebp,%ecx
  802076:	09 c2                	or     %eax,%edx
  802078:	89 d8                	mov    %ebx,%eax
  80207a:	89 14 24             	mov    %edx,(%esp)
  80207d:	89 f2                	mov    %esi,%edx
  80207f:	d3 e2                	shl    %cl,%edx
  802081:	89 f9                	mov    %edi,%ecx
  802083:	89 54 24 04          	mov    %edx,0x4(%esp)
  802087:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80208b:	d3 e8                	shr    %cl,%eax
  80208d:	89 e9                	mov    %ebp,%ecx
  80208f:	89 c6                	mov    %eax,%esi
  802091:	d3 e3                	shl    %cl,%ebx
  802093:	89 f9                	mov    %edi,%ecx
  802095:	89 d0                	mov    %edx,%eax
  802097:	d3 e8                	shr    %cl,%eax
  802099:	89 e9                	mov    %ebp,%ecx
  80209b:	09 d8                	or     %ebx,%eax
  80209d:	89 d3                	mov    %edx,%ebx
  80209f:	89 f2                	mov    %esi,%edx
  8020a1:	f7 34 24             	divl   (%esp)
  8020a4:	89 d6                	mov    %edx,%esi
  8020a6:	d3 e3                	shl    %cl,%ebx
  8020a8:	f7 64 24 04          	mull   0x4(%esp)
  8020ac:	39 d6                	cmp    %edx,%esi
  8020ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020b2:	89 d1                	mov    %edx,%ecx
  8020b4:	89 c3                	mov    %eax,%ebx
  8020b6:	72 08                	jb     8020c0 <__umoddi3+0x110>
  8020b8:	75 11                	jne    8020cb <__umoddi3+0x11b>
  8020ba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8020be:	73 0b                	jae    8020cb <__umoddi3+0x11b>
  8020c0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8020c4:	1b 14 24             	sbb    (%esp),%edx
  8020c7:	89 d1                	mov    %edx,%ecx
  8020c9:	89 c3                	mov    %eax,%ebx
  8020cb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8020cf:	29 da                	sub    %ebx,%edx
  8020d1:	19 ce                	sbb    %ecx,%esi
  8020d3:	89 f9                	mov    %edi,%ecx
  8020d5:	89 f0                	mov    %esi,%eax
  8020d7:	d3 e0                	shl    %cl,%eax
  8020d9:	89 e9                	mov    %ebp,%ecx
  8020db:	d3 ea                	shr    %cl,%edx
  8020dd:	89 e9                	mov    %ebp,%ecx
  8020df:	d3 ee                	shr    %cl,%esi
  8020e1:	09 d0                	or     %edx,%eax
  8020e3:	89 f2                	mov    %esi,%edx
  8020e5:	83 c4 1c             	add    $0x1c,%esp
  8020e8:	5b                   	pop    %ebx
  8020e9:	5e                   	pop    %esi
  8020ea:	5f                   	pop    %edi
  8020eb:	5d                   	pop    %ebp
  8020ec:	c3                   	ret    
  8020ed:	8d 76 00             	lea    0x0(%esi),%esi
  8020f0:	29 f9                	sub    %edi,%ecx
  8020f2:	19 d6                	sbb    %edx,%esi
  8020f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020fc:	e9 18 ff ff ff       	jmp    802019 <__umoddi3+0x69>
