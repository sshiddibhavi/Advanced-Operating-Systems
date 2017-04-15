
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
  80003c:	e8 9d 0e 00 00       	call   800ede <fork>
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
  800054:	68 80 21 80 00       	push   $0x802180
  800059:	e8 53 01 00 00       	call   8001b1 <cprintf>
		ipc_send(who, 0, 0, 0);
  80005e:	6a 00                	push   $0x0
  800060:	6a 00                	push   $0x0
  800062:	6a 00                	push   $0x0
  800064:	ff 75 e4             	pushl  -0x1c(%ebp)
  800067:	e8 d0 0f 00 00       	call   80103c <ipc_send>
  80006c:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  80006f:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800072:	83 ec 04             	sub    $0x4,%esp
  800075:	6a 00                	push   $0x0
  800077:	6a 00                	push   $0x0
  800079:	56                   	push   %esi
  80007a:	e8 54 0f 00 00       	call   800fd3 <ipc_recv>
  80007f:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  800081:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800084:	e8 72 0a 00 00       	call   800afb <sys_getenvid>
  800089:	57                   	push   %edi
  80008a:	53                   	push   %ebx
  80008b:	50                   	push   %eax
  80008c:	68 96 21 80 00       	push   $0x802196
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
  8000a9:	e8 8e 0f 00 00       	call   80103c <ipc_send>
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
  80010a:	e8 85 11 00 00       	call   801294 <close_all>
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
  800214:	e8 c7 1c 00 00       	call   801ee0 <__udivdi3>
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
  800257:	e8 b4 1d 00 00       	call   802010 <__umoddi3>
  80025c:	83 c4 14             	add    $0x14,%esp
  80025f:	0f be 80 b3 21 80 00 	movsbl 0x8021b3(%eax),%eax
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
  80035b:	ff 24 85 00 23 80 00 	jmp    *0x802300(,%eax,4)
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
  80041f:	8b 14 85 60 24 80 00 	mov    0x802460(,%eax,4),%edx
  800426:	85 d2                	test   %edx,%edx
  800428:	75 18                	jne    800442 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80042a:	50                   	push   %eax
  80042b:	68 cb 21 80 00       	push   $0x8021cb
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
  800443:	68 2a 26 80 00       	push   $0x80262a
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
  800467:	b8 c4 21 80 00       	mov    $0x8021c4,%eax
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
  800ae2:	68 bf 24 80 00       	push   $0x8024bf
  800ae7:	6a 23                	push   $0x23
  800ae9:	68 dc 24 80 00       	push   $0x8024dc
  800aee:	e8 e9 12 00 00       	call   801ddc <_panic>

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
  800b63:	68 bf 24 80 00       	push   $0x8024bf
  800b68:	6a 23                	push   $0x23
  800b6a:	68 dc 24 80 00       	push   $0x8024dc
  800b6f:	e8 68 12 00 00       	call   801ddc <_panic>

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
  800ba5:	68 bf 24 80 00       	push   $0x8024bf
  800baa:	6a 23                	push   $0x23
  800bac:	68 dc 24 80 00       	push   $0x8024dc
  800bb1:	e8 26 12 00 00       	call   801ddc <_panic>

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
  800be7:	68 bf 24 80 00       	push   $0x8024bf
  800bec:	6a 23                	push   $0x23
  800bee:	68 dc 24 80 00       	push   $0x8024dc
  800bf3:	e8 e4 11 00 00       	call   801ddc <_panic>

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
  800c29:	68 bf 24 80 00       	push   $0x8024bf
  800c2e:	6a 23                	push   $0x23
  800c30:	68 dc 24 80 00       	push   $0x8024dc
  800c35:	e8 a2 11 00 00       	call   801ddc <_panic>

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
  800c6b:	68 bf 24 80 00       	push   $0x8024bf
  800c70:	6a 23                	push   $0x23
  800c72:	68 dc 24 80 00       	push   $0x8024dc
  800c77:	e8 60 11 00 00       	call   801ddc <_panic>

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
  800cad:	68 bf 24 80 00       	push   $0x8024bf
  800cb2:	6a 23                	push   $0x23
  800cb4:	68 dc 24 80 00       	push   $0x8024dc
  800cb9:	e8 1e 11 00 00       	call   801ddc <_panic>

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
  800d11:	68 bf 24 80 00       	push   $0x8024bf
  800d16:	6a 23                	push   $0x23
  800d18:	68 dc 24 80 00       	push   $0x8024dc
  800d1d:	e8 ba 10 00 00       	call   801ddc <_panic>

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
  800d2d:	53                   	push   %ebx
  800d2e:	83 ec 04             	sub    $0x4,%esp
	int r;
	void * address = (void *)(pn*PGSIZE);
  800d31:	89 d3                	mov    %edx,%ebx
  800d33:	c1 e3 0c             	shl    $0xc,%ebx
	
	if((uvpt[pn] & PTE_SHARE))
  800d36:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800d3d:	f6 c5 04             	test   $0x4,%ch
  800d40:	74 38                	je     800d7a <duppage+0x50>
	{
		if ((r = sys_page_map(0, address, envid, address, (uvpt[pn] | PTE_SYSCALL))) < 0)
  800d42:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d49:	83 ec 0c             	sub    $0xc,%esp
  800d4c:	81 ca 07 0e 00 00    	or     $0xe07,%edx
  800d52:	52                   	push   %edx
  800d53:	53                   	push   %ebx
  800d54:	50                   	push   %eax
  800d55:	53                   	push   %ebx
  800d56:	6a 00                	push   $0x0
  800d58:	e8 1f fe ff ff       	call   800b7c <sys_page_map>
  800d5d:	83 c4 20             	add    $0x20,%esp
  800d60:	85 c0                	test   %eax,%eax
  800d62:	0f 89 b8 00 00 00    	jns    800e20 <duppage+0xf6>
			panic("sys_page_map: %e", r);
  800d68:	50                   	push   %eax
  800d69:	68 ea 24 80 00       	push   $0x8024ea
  800d6e:	6a 4e                	push   $0x4e
  800d70:	68 fb 24 80 00       	push   $0x8024fb
  800d75:	e8 62 10 00 00       	call   801ddc <_panic>
	}
	else if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW))
  800d7a:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800d81:	f6 c1 02             	test   $0x2,%cl
  800d84:	75 0c                	jne    800d92 <duppage+0x68>
  800d86:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800d8d:	f6 c5 08             	test   $0x8,%ch
  800d90:	74 57                	je     800de9 <duppage+0xbf>
	{
		int perm = 0;
		perm |= PTE_P|PTE_U|PTE_COW;
	
		if ((r = sys_page_map(0, address, envid, address, perm)) < 0)
  800d92:	83 ec 0c             	sub    $0xc,%esp
  800d95:	68 05 08 00 00       	push   $0x805
  800d9a:	53                   	push   %ebx
  800d9b:	50                   	push   %eax
  800d9c:	53                   	push   %ebx
  800d9d:	6a 00                	push   $0x0
  800d9f:	e8 d8 fd ff ff       	call   800b7c <sys_page_map>
  800da4:	83 c4 20             	add    $0x20,%esp
  800da7:	85 c0                	test   %eax,%eax
  800da9:	79 12                	jns    800dbd <duppage+0x93>
			panic("sys_page_map: %e", r);
  800dab:	50                   	push   %eax
  800dac:	68 ea 24 80 00       	push   $0x8024ea
  800db1:	6a 56                	push   $0x56
  800db3:	68 fb 24 80 00       	push   $0x8024fb
  800db8:	e8 1f 10 00 00       	call   801ddc <_panic>
		if ((r = sys_page_map(0, address, 0, address, perm)) < 0)
  800dbd:	83 ec 0c             	sub    $0xc,%esp
  800dc0:	68 05 08 00 00       	push   $0x805
  800dc5:	53                   	push   %ebx
  800dc6:	6a 00                	push   $0x0
  800dc8:	53                   	push   %ebx
  800dc9:	6a 00                	push   $0x0
  800dcb:	e8 ac fd ff ff       	call   800b7c <sys_page_map>
  800dd0:	83 c4 20             	add    $0x20,%esp
  800dd3:	85 c0                	test   %eax,%eax
  800dd5:	79 49                	jns    800e20 <duppage+0xf6>
			panic("sys_page_map: %e", r);
  800dd7:	50                   	push   %eax
  800dd8:	68 ea 24 80 00       	push   $0x8024ea
  800ddd:	6a 58                	push   $0x58
  800ddf:	68 fb 24 80 00       	push   $0x8024fb
  800de4:	e8 f3 0f 00 00       	call   801ddc <_panic>
	}
	else if((uvpt[pn] & ~PTE_U) == 0)
  800de9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800df0:	f7 c2 fb ff ff ff    	test   $0xfffffffb,%edx
  800df6:	75 28                	jne    800e20 <duppage+0xf6>
	{
		//cprintf("im here");
		if ((r = sys_page_map(0, address, envid, address, PTE_P|PTE_U)) < 0)
  800df8:	83 ec 0c             	sub    $0xc,%esp
  800dfb:	6a 05                	push   $0x5
  800dfd:	53                   	push   %ebx
  800dfe:	50                   	push   %eax
  800dff:	53                   	push   %ebx
  800e00:	6a 00                	push   $0x0
  800e02:	e8 75 fd ff ff       	call   800b7c <sys_page_map>
  800e07:	83 c4 20             	add    $0x20,%esp
  800e0a:	85 c0                	test   %eax,%eax
  800e0c:	79 12                	jns    800e20 <duppage+0xf6>
			panic("sys_page_map: %e", r);	
  800e0e:	50                   	push   %eax
  800e0f:	68 ea 24 80 00       	push   $0x8024ea
  800e14:	6a 5e                	push   $0x5e
  800e16:	68 fb 24 80 00       	push   $0x8024fb
  800e1b:	e8 bc 0f 00 00       	call   801ddc <_panic>
	}
	return 0;
}
  800e20:	b8 00 00 00 00       	mov    $0x0,%eax
  800e25:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e28:	c9                   	leave  
  800e29:	c3                   	ret    

00800e2a <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e2a:	55                   	push   %ebp
  800e2b:	89 e5                	mov    %esp,%ebp
  800e2d:	53                   	push   %ebx
  800e2e:	83 ec 08             	sub    $0x8,%esp
	void *addr = (void *) utf->utf_fault_va;
  800e31:	8b 45 08             	mov    0x8(%ebp),%eax
  800e34:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	unsigned pn = ((uint32_t)addr)/PGSIZE;
  800e36:	89 d8                	mov    %ebx,%eax
  800e38:	c1 e8 0c             	shr    $0xc,%eax
	pte_t pte = uvpt[pn];
  800e3b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// Allocate a new page, mapped at temp location
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  800e42:	6a 07                	push   $0x7
  800e44:	68 00 f0 7f 00       	push   $0x7ff000
  800e49:	6a 00                	push   $0x0
  800e4b:	e8 e9 fc ff ff       	call   800b39 <sys_page_alloc>
  800e50:	83 c4 10             	add    $0x10,%esp
  800e53:	85 c0                	test   %eax,%eax
  800e55:	79 12                	jns    800e69 <pgfault+0x3f>
		panic("sys_page_alloc: %e", r);
  800e57:	50                   	push   %eax
  800e58:	68 06 25 80 00       	push   $0x802506
  800e5d:	6a 2b                	push   $0x2b
  800e5f:	68 fb 24 80 00       	push   $0x8024fb
  800e64:	e8 73 0f 00 00       	call   801ddc <_panic>

	// Copy the data from the old page to this new page
	void *addr_pgstart = (void *) ROUNDDOWN(addr, PGSIZE);
  800e69:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr_pgstart, PGSIZE);
  800e6f:	83 ec 04             	sub    $0x4,%esp
  800e72:	68 00 10 00 00       	push   $0x1000
  800e77:	53                   	push   %ebx
  800e78:	68 00 f0 7f 00       	push   $0x7ff000
  800e7d:	e8 46 fa ff ff       	call   8008c8 <memmove>

	// Move the new page to the old page's address
	if ((r = sys_page_map(0, PFTEMP, 0, addr_pgstart, PTE_P|PTE_U|PTE_W)) < 0)
  800e82:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e89:	53                   	push   %ebx
  800e8a:	6a 00                	push   $0x0
  800e8c:	68 00 f0 7f 00       	push   $0x7ff000
  800e91:	6a 00                	push   $0x0
  800e93:	e8 e4 fc ff ff       	call   800b7c <sys_page_map>
  800e98:	83 c4 20             	add    $0x20,%esp
  800e9b:	85 c0                	test   %eax,%eax
  800e9d:	79 12                	jns    800eb1 <pgfault+0x87>
		panic("sys_page_map: %e", r);
  800e9f:	50                   	push   %eax
  800ea0:	68 ea 24 80 00       	push   $0x8024ea
  800ea5:	6a 33                	push   $0x33
  800ea7:	68 fb 24 80 00       	push   $0x8024fb
  800eac:	e8 2b 0f 00 00       	call   801ddc <_panic>

	// Unmap the temp location
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800eb1:	83 ec 08             	sub    $0x8,%esp
  800eb4:	68 00 f0 7f 00       	push   $0x7ff000
  800eb9:	6a 00                	push   $0x0
  800ebb:	e8 fe fc ff ff       	call   800bbe <sys_page_unmap>
  800ec0:	83 c4 10             	add    $0x10,%esp
  800ec3:	85 c0                	test   %eax,%eax
  800ec5:	79 12                	jns    800ed9 <pgfault+0xaf>
		panic("sys_page_unmap: %e", r);
  800ec7:	50                   	push   %eax
  800ec8:	68 19 25 80 00       	push   $0x802519
  800ecd:	6a 37                	push   $0x37
  800ecf:	68 fb 24 80 00       	push   $0x8024fb
  800ed4:	e8 03 0f 00 00       	call   801ddc <_panic>
}
  800ed9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800edc:	c9                   	leave  
  800edd:	c3                   	ret    

00800ede <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ede:	55                   	push   %ebp
  800edf:	89 e5                	mov    %esp,%ebp
  800ee1:	56                   	push   %esi
  800ee2:	53                   	push   %ebx
  800ee3:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
	// Set up page fault handler
	set_pgfault_handler(&pgfault);
  800ee6:	68 2a 0e 80 00       	push   $0x800e2a
  800eeb:	e8 32 0f 00 00       	call   801e22 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800ef0:	b8 07 00 00 00       	mov    $0x7,%eax
  800ef5:	cd 30                	int    $0x30

	// Create child
	envid_t envid = sys_exofork();
  800ef7:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (envid < 0) {
  800efa:	83 c4 10             	add    $0x10,%esp
  800efd:	85 c0                	test   %eax,%eax
  800eff:	79 12                	jns    800f13 <fork+0x35>
		panic("sys_exofork: %e", envid);
  800f01:	50                   	push   %eax
  800f02:	68 2c 25 80 00       	push   $0x80252c
  800f07:	6a 7c                	push   $0x7c
  800f09:	68 fb 24 80 00       	push   $0x8024fb
  800f0e:	e8 c9 0e 00 00       	call   801ddc <_panic>
		return envid;
	}
	if (envid == 0) {
  800f13:	85 c0                	test   %eax,%eax
  800f15:	75 1e                	jne    800f35 <fork+0x57>
		// We are the child.
		thisenv = &envs[ENVX(sys_getenvid())]; // Fix thisenv
  800f17:	e8 df fb ff ff       	call   800afb <sys_getenvid>
  800f1c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f21:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f24:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f29:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800f2e:	b8 00 00 00 00       	mov    $0x0,%eax
  800f33:	eb 7d                	jmp    800fb2 <fork+0xd4>

	// Set page fault handler on the child.
	// The parent needs to do it, else the child wouldn't be able to handle
	// the fault when trying to access it's stack (which happens as soon it starts)
	extern void _pgfault_upcall(void);
	sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);
  800f35:	83 ec 04             	sub    $0x4,%esp
  800f38:	6a 07                	push   $0x7
  800f3a:	68 00 f0 bf ee       	push   $0xeebff000
  800f3f:	50                   	push   %eax
  800f40:	e8 f4 fb ff ff       	call   800b39 <sys_page_alloc>
	sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  800f45:	83 c4 08             	add    $0x8,%esp
  800f48:	68 67 1e 80 00       	push   $0x801e67
  800f4d:	ff 75 f4             	pushl  -0xc(%ebp)
  800f50:	e8 2f fd ff ff       	call   800c84 <sys_env_set_pgfault_upcall>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  800f55:	be 04 60 80 00       	mov    $0x806004,%esi
  800f5a:	c1 ee 0c             	shr    $0xc,%esi
  800f5d:	83 c4 10             	add    $0x10,%esp
  800f60:	bb 00 08 00 00       	mov    $0x800,%ebx
  800f65:	eb 0d                	jmp    800f74 <fork+0x96>
		duppage(envid, pn);
  800f67:	89 da                	mov    %ebx,%edx
  800f69:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f6c:	e8 b9 fd ff ff       	call   800d2a <duppage>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  800f71:	83 c3 01             	add    $0x1,%ebx
  800f74:	39 f3                	cmp    %esi,%ebx
  800f76:	76 ef                	jbe    800f67 <fork+0x89>
	}

	// Also copy the stack we are currently running on
	// I think it should loop from ustacktop to this page, since the stack
	// can have more than 1 page
	duppage(envid, ((uint32_t) &envid)/PGSIZE);
  800f78:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800f7b:	c1 ea 0c             	shr    $0xc,%edx
  800f7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f81:	e8 a4 fd ff ff       	call   800d2a <duppage>

	// Start the child environmnet running
	int r;
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  800f86:	83 ec 08             	sub    $0x8,%esp
  800f89:	6a 02                	push   $0x2
  800f8b:	ff 75 f4             	pushl  -0xc(%ebp)
  800f8e:	e8 6d fc ff ff       	call   800c00 <sys_env_set_status>
  800f93:	83 c4 10             	add    $0x10,%esp
  800f96:	85 c0                	test   %eax,%eax
  800f98:	79 15                	jns    800faf <fork+0xd1>
		panic("sys_env_set_status: %e", r);
  800f9a:	50                   	push   %eax
  800f9b:	68 3c 25 80 00       	push   $0x80253c
  800fa0:	68 9c 00 00 00       	push   $0x9c
  800fa5:	68 fb 24 80 00       	push   $0x8024fb
  800faa:	e8 2d 0e 00 00       	call   801ddc <_panic>
		return r;
	}

	return envid;
  800faf:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800fb2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fb5:	5b                   	pop    %ebx
  800fb6:	5e                   	pop    %esi
  800fb7:	5d                   	pop    %ebp
  800fb8:	c3                   	ret    

00800fb9 <sfork>:

// Challenge!
int
sfork(void)
{
  800fb9:	55                   	push   %ebp
  800fba:	89 e5                	mov    %esp,%ebp
  800fbc:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800fbf:	68 53 25 80 00       	push   $0x802553
  800fc4:	68 a7 00 00 00       	push   $0xa7
  800fc9:	68 fb 24 80 00       	push   $0x8024fb
  800fce:	e8 09 0e 00 00       	call   801ddc <_panic>

00800fd3 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800fd3:	55                   	push   %ebp
  800fd4:	89 e5                	mov    %esp,%ebp
  800fd6:	56                   	push   %esi
  800fd7:	53                   	push   %ebx
  800fd8:	8b 75 08             	mov    0x8(%ebp),%esi
  800fdb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fde:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  800fe1:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  800fe3:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  800fe8:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  800feb:	83 ec 0c             	sub    $0xc,%esp
  800fee:	50                   	push   %eax
  800fef:	e8 f5 fc ff ff       	call   800ce9 <sys_ipc_recv>

	if (r < 0) {
  800ff4:	83 c4 10             	add    $0x10,%esp
  800ff7:	85 c0                	test   %eax,%eax
  800ff9:	79 16                	jns    801011 <ipc_recv+0x3e>
		if (from_env_store)
  800ffb:	85 f6                	test   %esi,%esi
  800ffd:	74 06                	je     801005 <ipc_recv+0x32>
			*from_env_store = 0;
  800fff:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  801005:	85 db                	test   %ebx,%ebx
  801007:	74 2c                	je     801035 <ipc_recv+0x62>
			*perm_store = 0;
  801009:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80100f:	eb 24                	jmp    801035 <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  801011:	85 f6                	test   %esi,%esi
  801013:	74 0a                	je     80101f <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  801015:	a1 04 40 80 00       	mov    0x804004,%eax
  80101a:	8b 40 74             	mov    0x74(%eax),%eax
  80101d:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  80101f:	85 db                	test   %ebx,%ebx
  801021:	74 0a                	je     80102d <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  801023:	a1 04 40 80 00       	mov    0x804004,%eax
  801028:	8b 40 78             	mov    0x78(%eax),%eax
  80102b:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  80102d:	a1 04 40 80 00       	mov    0x804004,%eax
  801032:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  801035:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801038:	5b                   	pop    %ebx
  801039:	5e                   	pop    %esi
  80103a:	5d                   	pop    %ebp
  80103b:	c3                   	ret    

0080103c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80103c:	55                   	push   %ebp
  80103d:	89 e5                	mov    %esp,%ebp
  80103f:	57                   	push   %edi
  801040:	56                   	push   %esi
  801041:	53                   	push   %ebx
  801042:	83 ec 0c             	sub    $0xc,%esp
  801045:	8b 7d 08             	mov    0x8(%ebp),%edi
  801048:	8b 75 0c             	mov    0xc(%ebp),%esi
  80104b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  80104e:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801050:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801055:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  801058:	ff 75 14             	pushl  0x14(%ebp)
  80105b:	53                   	push   %ebx
  80105c:	56                   	push   %esi
  80105d:	57                   	push   %edi
  80105e:	e8 63 fc ff ff       	call   800cc6 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  801063:	83 c4 10             	add    $0x10,%esp
  801066:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801069:	75 07                	jne    801072 <ipc_send+0x36>
			sys_yield();
  80106b:	e8 aa fa ff ff       	call   800b1a <sys_yield>
  801070:	eb e6                	jmp    801058 <ipc_send+0x1c>
		} else if (r < 0) {
  801072:	85 c0                	test   %eax,%eax
  801074:	79 12                	jns    801088 <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  801076:	50                   	push   %eax
  801077:	68 69 25 80 00       	push   $0x802569
  80107c:	6a 51                	push   $0x51
  80107e:	68 76 25 80 00       	push   $0x802576
  801083:	e8 54 0d 00 00       	call   801ddc <_panic>
		}
	}
}
  801088:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80108b:	5b                   	pop    %ebx
  80108c:	5e                   	pop    %esi
  80108d:	5f                   	pop    %edi
  80108e:	5d                   	pop    %ebp
  80108f:	c3                   	ret    

00801090 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801090:	55                   	push   %ebp
  801091:	89 e5                	mov    %esp,%ebp
  801093:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801096:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80109b:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80109e:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8010a4:	8b 52 50             	mov    0x50(%edx),%edx
  8010a7:	39 ca                	cmp    %ecx,%edx
  8010a9:	75 0d                	jne    8010b8 <ipc_find_env+0x28>
			return envs[i].env_id;
  8010ab:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8010ae:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010b3:	8b 40 48             	mov    0x48(%eax),%eax
  8010b6:	eb 0f                	jmp    8010c7 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8010b8:	83 c0 01             	add    $0x1,%eax
  8010bb:	3d 00 04 00 00       	cmp    $0x400,%eax
  8010c0:	75 d9                	jne    80109b <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8010c2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8010c7:	5d                   	pop    %ebp
  8010c8:	c3                   	ret    

008010c9 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010c9:	55                   	push   %ebp
  8010ca:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8010cf:	05 00 00 00 30       	add    $0x30000000,%eax
  8010d4:	c1 e8 0c             	shr    $0xc,%eax
}
  8010d7:	5d                   	pop    %ebp
  8010d8:	c3                   	ret    

008010d9 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010d9:	55                   	push   %ebp
  8010da:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8010dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8010df:	05 00 00 00 30       	add    $0x30000000,%eax
  8010e4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010e9:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010ee:	5d                   	pop    %ebp
  8010ef:	c3                   	ret    

008010f0 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010f0:	55                   	push   %ebp
  8010f1:	89 e5                	mov    %esp,%ebp
  8010f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010f6:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010fb:	89 c2                	mov    %eax,%edx
  8010fd:	c1 ea 16             	shr    $0x16,%edx
  801100:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801107:	f6 c2 01             	test   $0x1,%dl
  80110a:	74 11                	je     80111d <fd_alloc+0x2d>
  80110c:	89 c2                	mov    %eax,%edx
  80110e:	c1 ea 0c             	shr    $0xc,%edx
  801111:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801118:	f6 c2 01             	test   $0x1,%dl
  80111b:	75 09                	jne    801126 <fd_alloc+0x36>
			*fd_store = fd;
  80111d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80111f:	b8 00 00 00 00       	mov    $0x0,%eax
  801124:	eb 17                	jmp    80113d <fd_alloc+0x4d>
  801126:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80112b:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801130:	75 c9                	jne    8010fb <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801132:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801138:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80113d:	5d                   	pop    %ebp
  80113e:	c3                   	ret    

0080113f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80113f:	55                   	push   %ebp
  801140:	89 e5                	mov    %esp,%ebp
  801142:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801145:	83 f8 1f             	cmp    $0x1f,%eax
  801148:	77 36                	ja     801180 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80114a:	c1 e0 0c             	shl    $0xc,%eax
  80114d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801152:	89 c2                	mov    %eax,%edx
  801154:	c1 ea 16             	shr    $0x16,%edx
  801157:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80115e:	f6 c2 01             	test   $0x1,%dl
  801161:	74 24                	je     801187 <fd_lookup+0x48>
  801163:	89 c2                	mov    %eax,%edx
  801165:	c1 ea 0c             	shr    $0xc,%edx
  801168:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80116f:	f6 c2 01             	test   $0x1,%dl
  801172:	74 1a                	je     80118e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801174:	8b 55 0c             	mov    0xc(%ebp),%edx
  801177:	89 02                	mov    %eax,(%edx)
	return 0;
  801179:	b8 00 00 00 00       	mov    $0x0,%eax
  80117e:	eb 13                	jmp    801193 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801180:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801185:	eb 0c                	jmp    801193 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801187:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80118c:	eb 05                	jmp    801193 <fd_lookup+0x54>
  80118e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801193:	5d                   	pop    %ebp
  801194:	c3                   	ret    

00801195 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801195:	55                   	push   %ebp
  801196:	89 e5                	mov    %esp,%ebp
  801198:	83 ec 08             	sub    $0x8,%esp
  80119b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80119e:	ba fc 25 80 00       	mov    $0x8025fc,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8011a3:	eb 13                	jmp    8011b8 <dev_lookup+0x23>
  8011a5:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8011a8:	39 08                	cmp    %ecx,(%eax)
  8011aa:	75 0c                	jne    8011b8 <dev_lookup+0x23>
			*dev = devtab[i];
  8011ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011af:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8011b6:	eb 2e                	jmp    8011e6 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011b8:	8b 02                	mov    (%edx),%eax
  8011ba:	85 c0                	test   %eax,%eax
  8011bc:	75 e7                	jne    8011a5 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011be:	a1 04 40 80 00       	mov    0x804004,%eax
  8011c3:	8b 40 48             	mov    0x48(%eax),%eax
  8011c6:	83 ec 04             	sub    $0x4,%esp
  8011c9:	51                   	push   %ecx
  8011ca:	50                   	push   %eax
  8011cb:	68 80 25 80 00       	push   $0x802580
  8011d0:	e8 dc ef ff ff       	call   8001b1 <cprintf>
	*dev = 0;
  8011d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011d8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8011de:	83 c4 10             	add    $0x10,%esp
  8011e1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011e6:	c9                   	leave  
  8011e7:	c3                   	ret    

008011e8 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8011e8:	55                   	push   %ebp
  8011e9:	89 e5                	mov    %esp,%ebp
  8011eb:	56                   	push   %esi
  8011ec:	53                   	push   %ebx
  8011ed:	83 ec 10             	sub    $0x10,%esp
  8011f0:	8b 75 08             	mov    0x8(%ebp),%esi
  8011f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011f9:	50                   	push   %eax
  8011fa:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801200:	c1 e8 0c             	shr    $0xc,%eax
  801203:	50                   	push   %eax
  801204:	e8 36 ff ff ff       	call   80113f <fd_lookup>
  801209:	83 c4 08             	add    $0x8,%esp
  80120c:	85 c0                	test   %eax,%eax
  80120e:	78 05                	js     801215 <fd_close+0x2d>
	    || fd != fd2)
  801210:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801213:	74 0c                	je     801221 <fd_close+0x39>
		return (must_exist ? r : 0);
  801215:	84 db                	test   %bl,%bl
  801217:	ba 00 00 00 00       	mov    $0x0,%edx
  80121c:	0f 44 c2             	cmove  %edx,%eax
  80121f:	eb 41                	jmp    801262 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801221:	83 ec 08             	sub    $0x8,%esp
  801224:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801227:	50                   	push   %eax
  801228:	ff 36                	pushl  (%esi)
  80122a:	e8 66 ff ff ff       	call   801195 <dev_lookup>
  80122f:	89 c3                	mov    %eax,%ebx
  801231:	83 c4 10             	add    $0x10,%esp
  801234:	85 c0                	test   %eax,%eax
  801236:	78 1a                	js     801252 <fd_close+0x6a>
		if (dev->dev_close)
  801238:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80123b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80123e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801243:	85 c0                	test   %eax,%eax
  801245:	74 0b                	je     801252 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801247:	83 ec 0c             	sub    $0xc,%esp
  80124a:	56                   	push   %esi
  80124b:	ff d0                	call   *%eax
  80124d:	89 c3                	mov    %eax,%ebx
  80124f:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801252:	83 ec 08             	sub    $0x8,%esp
  801255:	56                   	push   %esi
  801256:	6a 00                	push   $0x0
  801258:	e8 61 f9 ff ff       	call   800bbe <sys_page_unmap>
	return r;
  80125d:	83 c4 10             	add    $0x10,%esp
  801260:	89 d8                	mov    %ebx,%eax
}
  801262:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801265:	5b                   	pop    %ebx
  801266:	5e                   	pop    %esi
  801267:	5d                   	pop    %ebp
  801268:	c3                   	ret    

00801269 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801269:	55                   	push   %ebp
  80126a:	89 e5                	mov    %esp,%ebp
  80126c:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80126f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801272:	50                   	push   %eax
  801273:	ff 75 08             	pushl  0x8(%ebp)
  801276:	e8 c4 fe ff ff       	call   80113f <fd_lookup>
  80127b:	83 c4 08             	add    $0x8,%esp
  80127e:	85 c0                	test   %eax,%eax
  801280:	78 10                	js     801292 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801282:	83 ec 08             	sub    $0x8,%esp
  801285:	6a 01                	push   $0x1
  801287:	ff 75 f4             	pushl  -0xc(%ebp)
  80128a:	e8 59 ff ff ff       	call   8011e8 <fd_close>
  80128f:	83 c4 10             	add    $0x10,%esp
}
  801292:	c9                   	leave  
  801293:	c3                   	ret    

00801294 <close_all>:

void
close_all(void)
{
  801294:	55                   	push   %ebp
  801295:	89 e5                	mov    %esp,%ebp
  801297:	53                   	push   %ebx
  801298:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80129b:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012a0:	83 ec 0c             	sub    $0xc,%esp
  8012a3:	53                   	push   %ebx
  8012a4:	e8 c0 ff ff ff       	call   801269 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8012a9:	83 c3 01             	add    $0x1,%ebx
  8012ac:	83 c4 10             	add    $0x10,%esp
  8012af:	83 fb 20             	cmp    $0x20,%ebx
  8012b2:	75 ec                	jne    8012a0 <close_all+0xc>
		close(i);
}
  8012b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012b7:	c9                   	leave  
  8012b8:	c3                   	ret    

008012b9 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012b9:	55                   	push   %ebp
  8012ba:	89 e5                	mov    %esp,%ebp
  8012bc:	57                   	push   %edi
  8012bd:	56                   	push   %esi
  8012be:	53                   	push   %ebx
  8012bf:	83 ec 2c             	sub    $0x2c,%esp
  8012c2:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012c5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012c8:	50                   	push   %eax
  8012c9:	ff 75 08             	pushl  0x8(%ebp)
  8012cc:	e8 6e fe ff ff       	call   80113f <fd_lookup>
  8012d1:	83 c4 08             	add    $0x8,%esp
  8012d4:	85 c0                	test   %eax,%eax
  8012d6:	0f 88 c1 00 00 00    	js     80139d <dup+0xe4>
		return r;
	close(newfdnum);
  8012dc:	83 ec 0c             	sub    $0xc,%esp
  8012df:	56                   	push   %esi
  8012e0:	e8 84 ff ff ff       	call   801269 <close>

	newfd = INDEX2FD(newfdnum);
  8012e5:	89 f3                	mov    %esi,%ebx
  8012e7:	c1 e3 0c             	shl    $0xc,%ebx
  8012ea:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8012f0:	83 c4 04             	add    $0x4,%esp
  8012f3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012f6:	e8 de fd ff ff       	call   8010d9 <fd2data>
  8012fb:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8012fd:	89 1c 24             	mov    %ebx,(%esp)
  801300:	e8 d4 fd ff ff       	call   8010d9 <fd2data>
  801305:	83 c4 10             	add    $0x10,%esp
  801308:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80130b:	89 f8                	mov    %edi,%eax
  80130d:	c1 e8 16             	shr    $0x16,%eax
  801310:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801317:	a8 01                	test   $0x1,%al
  801319:	74 37                	je     801352 <dup+0x99>
  80131b:	89 f8                	mov    %edi,%eax
  80131d:	c1 e8 0c             	shr    $0xc,%eax
  801320:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801327:	f6 c2 01             	test   $0x1,%dl
  80132a:	74 26                	je     801352 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80132c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801333:	83 ec 0c             	sub    $0xc,%esp
  801336:	25 07 0e 00 00       	and    $0xe07,%eax
  80133b:	50                   	push   %eax
  80133c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80133f:	6a 00                	push   $0x0
  801341:	57                   	push   %edi
  801342:	6a 00                	push   $0x0
  801344:	e8 33 f8 ff ff       	call   800b7c <sys_page_map>
  801349:	89 c7                	mov    %eax,%edi
  80134b:	83 c4 20             	add    $0x20,%esp
  80134e:	85 c0                	test   %eax,%eax
  801350:	78 2e                	js     801380 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801352:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801355:	89 d0                	mov    %edx,%eax
  801357:	c1 e8 0c             	shr    $0xc,%eax
  80135a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801361:	83 ec 0c             	sub    $0xc,%esp
  801364:	25 07 0e 00 00       	and    $0xe07,%eax
  801369:	50                   	push   %eax
  80136a:	53                   	push   %ebx
  80136b:	6a 00                	push   $0x0
  80136d:	52                   	push   %edx
  80136e:	6a 00                	push   $0x0
  801370:	e8 07 f8 ff ff       	call   800b7c <sys_page_map>
  801375:	89 c7                	mov    %eax,%edi
  801377:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80137a:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80137c:	85 ff                	test   %edi,%edi
  80137e:	79 1d                	jns    80139d <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801380:	83 ec 08             	sub    $0x8,%esp
  801383:	53                   	push   %ebx
  801384:	6a 00                	push   $0x0
  801386:	e8 33 f8 ff ff       	call   800bbe <sys_page_unmap>
	sys_page_unmap(0, nva);
  80138b:	83 c4 08             	add    $0x8,%esp
  80138e:	ff 75 d4             	pushl  -0x2c(%ebp)
  801391:	6a 00                	push   $0x0
  801393:	e8 26 f8 ff ff       	call   800bbe <sys_page_unmap>
	return r;
  801398:	83 c4 10             	add    $0x10,%esp
  80139b:	89 f8                	mov    %edi,%eax
}
  80139d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013a0:	5b                   	pop    %ebx
  8013a1:	5e                   	pop    %esi
  8013a2:	5f                   	pop    %edi
  8013a3:	5d                   	pop    %ebp
  8013a4:	c3                   	ret    

008013a5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013a5:	55                   	push   %ebp
  8013a6:	89 e5                	mov    %esp,%ebp
  8013a8:	53                   	push   %ebx
  8013a9:	83 ec 14             	sub    $0x14,%esp
  8013ac:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013af:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013b2:	50                   	push   %eax
  8013b3:	53                   	push   %ebx
  8013b4:	e8 86 fd ff ff       	call   80113f <fd_lookup>
  8013b9:	83 c4 08             	add    $0x8,%esp
  8013bc:	89 c2                	mov    %eax,%edx
  8013be:	85 c0                	test   %eax,%eax
  8013c0:	78 6d                	js     80142f <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013c2:	83 ec 08             	sub    $0x8,%esp
  8013c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013c8:	50                   	push   %eax
  8013c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013cc:	ff 30                	pushl  (%eax)
  8013ce:	e8 c2 fd ff ff       	call   801195 <dev_lookup>
  8013d3:	83 c4 10             	add    $0x10,%esp
  8013d6:	85 c0                	test   %eax,%eax
  8013d8:	78 4c                	js     801426 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013da:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013dd:	8b 42 08             	mov    0x8(%edx),%eax
  8013e0:	83 e0 03             	and    $0x3,%eax
  8013e3:	83 f8 01             	cmp    $0x1,%eax
  8013e6:	75 21                	jne    801409 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013e8:	a1 04 40 80 00       	mov    0x804004,%eax
  8013ed:	8b 40 48             	mov    0x48(%eax),%eax
  8013f0:	83 ec 04             	sub    $0x4,%esp
  8013f3:	53                   	push   %ebx
  8013f4:	50                   	push   %eax
  8013f5:	68 c1 25 80 00       	push   $0x8025c1
  8013fa:	e8 b2 ed ff ff       	call   8001b1 <cprintf>
		return -E_INVAL;
  8013ff:	83 c4 10             	add    $0x10,%esp
  801402:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801407:	eb 26                	jmp    80142f <read+0x8a>
	}
	if (!dev->dev_read)
  801409:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80140c:	8b 40 08             	mov    0x8(%eax),%eax
  80140f:	85 c0                	test   %eax,%eax
  801411:	74 17                	je     80142a <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801413:	83 ec 04             	sub    $0x4,%esp
  801416:	ff 75 10             	pushl  0x10(%ebp)
  801419:	ff 75 0c             	pushl  0xc(%ebp)
  80141c:	52                   	push   %edx
  80141d:	ff d0                	call   *%eax
  80141f:	89 c2                	mov    %eax,%edx
  801421:	83 c4 10             	add    $0x10,%esp
  801424:	eb 09                	jmp    80142f <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801426:	89 c2                	mov    %eax,%edx
  801428:	eb 05                	jmp    80142f <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80142a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80142f:	89 d0                	mov    %edx,%eax
  801431:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801434:	c9                   	leave  
  801435:	c3                   	ret    

00801436 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801436:	55                   	push   %ebp
  801437:	89 e5                	mov    %esp,%ebp
  801439:	57                   	push   %edi
  80143a:	56                   	push   %esi
  80143b:	53                   	push   %ebx
  80143c:	83 ec 0c             	sub    $0xc,%esp
  80143f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801442:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801445:	bb 00 00 00 00       	mov    $0x0,%ebx
  80144a:	eb 21                	jmp    80146d <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80144c:	83 ec 04             	sub    $0x4,%esp
  80144f:	89 f0                	mov    %esi,%eax
  801451:	29 d8                	sub    %ebx,%eax
  801453:	50                   	push   %eax
  801454:	89 d8                	mov    %ebx,%eax
  801456:	03 45 0c             	add    0xc(%ebp),%eax
  801459:	50                   	push   %eax
  80145a:	57                   	push   %edi
  80145b:	e8 45 ff ff ff       	call   8013a5 <read>
		if (m < 0)
  801460:	83 c4 10             	add    $0x10,%esp
  801463:	85 c0                	test   %eax,%eax
  801465:	78 10                	js     801477 <readn+0x41>
			return m;
		if (m == 0)
  801467:	85 c0                	test   %eax,%eax
  801469:	74 0a                	je     801475 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80146b:	01 c3                	add    %eax,%ebx
  80146d:	39 f3                	cmp    %esi,%ebx
  80146f:	72 db                	jb     80144c <readn+0x16>
  801471:	89 d8                	mov    %ebx,%eax
  801473:	eb 02                	jmp    801477 <readn+0x41>
  801475:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801477:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80147a:	5b                   	pop    %ebx
  80147b:	5e                   	pop    %esi
  80147c:	5f                   	pop    %edi
  80147d:	5d                   	pop    %ebp
  80147e:	c3                   	ret    

0080147f <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80147f:	55                   	push   %ebp
  801480:	89 e5                	mov    %esp,%ebp
  801482:	53                   	push   %ebx
  801483:	83 ec 14             	sub    $0x14,%esp
  801486:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801489:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80148c:	50                   	push   %eax
  80148d:	53                   	push   %ebx
  80148e:	e8 ac fc ff ff       	call   80113f <fd_lookup>
  801493:	83 c4 08             	add    $0x8,%esp
  801496:	89 c2                	mov    %eax,%edx
  801498:	85 c0                	test   %eax,%eax
  80149a:	78 68                	js     801504 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80149c:	83 ec 08             	sub    $0x8,%esp
  80149f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014a2:	50                   	push   %eax
  8014a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014a6:	ff 30                	pushl  (%eax)
  8014a8:	e8 e8 fc ff ff       	call   801195 <dev_lookup>
  8014ad:	83 c4 10             	add    $0x10,%esp
  8014b0:	85 c0                	test   %eax,%eax
  8014b2:	78 47                	js     8014fb <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014b7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014bb:	75 21                	jne    8014de <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014bd:	a1 04 40 80 00       	mov    0x804004,%eax
  8014c2:	8b 40 48             	mov    0x48(%eax),%eax
  8014c5:	83 ec 04             	sub    $0x4,%esp
  8014c8:	53                   	push   %ebx
  8014c9:	50                   	push   %eax
  8014ca:	68 dd 25 80 00       	push   $0x8025dd
  8014cf:	e8 dd ec ff ff       	call   8001b1 <cprintf>
		return -E_INVAL;
  8014d4:	83 c4 10             	add    $0x10,%esp
  8014d7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014dc:	eb 26                	jmp    801504 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014de:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014e1:	8b 52 0c             	mov    0xc(%edx),%edx
  8014e4:	85 d2                	test   %edx,%edx
  8014e6:	74 17                	je     8014ff <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014e8:	83 ec 04             	sub    $0x4,%esp
  8014eb:	ff 75 10             	pushl  0x10(%ebp)
  8014ee:	ff 75 0c             	pushl  0xc(%ebp)
  8014f1:	50                   	push   %eax
  8014f2:	ff d2                	call   *%edx
  8014f4:	89 c2                	mov    %eax,%edx
  8014f6:	83 c4 10             	add    $0x10,%esp
  8014f9:	eb 09                	jmp    801504 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014fb:	89 c2                	mov    %eax,%edx
  8014fd:	eb 05                	jmp    801504 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8014ff:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801504:	89 d0                	mov    %edx,%eax
  801506:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801509:	c9                   	leave  
  80150a:	c3                   	ret    

0080150b <seek>:

int
seek(int fdnum, off_t offset)
{
  80150b:	55                   	push   %ebp
  80150c:	89 e5                	mov    %esp,%ebp
  80150e:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801511:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801514:	50                   	push   %eax
  801515:	ff 75 08             	pushl  0x8(%ebp)
  801518:	e8 22 fc ff ff       	call   80113f <fd_lookup>
  80151d:	83 c4 08             	add    $0x8,%esp
  801520:	85 c0                	test   %eax,%eax
  801522:	78 0e                	js     801532 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801524:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801527:	8b 55 0c             	mov    0xc(%ebp),%edx
  80152a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80152d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801532:	c9                   	leave  
  801533:	c3                   	ret    

00801534 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801534:	55                   	push   %ebp
  801535:	89 e5                	mov    %esp,%ebp
  801537:	53                   	push   %ebx
  801538:	83 ec 14             	sub    $0x14,%esp
  80153b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80153e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801541:	50                   	push   %eax
  801542:	53                   	push   %ebx
  801543:	e8 f7 fb ff ff       	call   80113f <fd_lookup>
  801548:	83 c4 08             	add    $0x8,%esp
  80154b:	89 c2                	mov    %eax,%edx
  80154d:	85 c0                	test   %eax,%eax
  80154f:	78 65                	js     8015b6 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801551:	83 ec 08             	sub    $0x8,%esp
  801554:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801557:	50                   	push   %eax
  801558:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80155b:	ff 30                	pushl  (%eax)
  80155d:	e8 33 fc ff ff       	call   801195 <dev_lookup>
  801562:	83 c4 10             	add    $0x10,%esp
  801565:	85 c0                	test   %eax,%eax
  801567:	78 44                	js     8015ad <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801569:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80156c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801570:	75 21                	jne    801593 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801572:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801577:	8b 40 48             	mov    0x48(%eax),%eax
  80157a:	83 ec 04             	sub    $0x4,%esp
  80157d:	53                   	push   %ebx
  80157e:	50                   	push   %eax
  80157f:	68 a0 25 80 00       	push   $0x8025a0
  801584:	e8 28 ec ff ff       	call   8001b1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801589:	83 c4 10             	add    $0x10,%esp
  80158c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801591:	eb 23                	jmp    8015b6 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801593:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801596:	8b 52 18             	mov    0x18(%edx),%edx
  801599:	85 d2                	test   %edx,%edx
  80159b:	74 14                	je     8015b1 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80159d:	83 ec 08             	sub    $0x8,%esp
  8015a0:	ff 75 0c             	pushl  0xc(%ebp)
  8015a3:	50                   	push   %eax
  8015a4:	ff d2                	call   *%edx
  8015a6:	89 c2                	mov    %eax,%edx
  8015a8:	83 c4 10             	add    $0x10,%esp
  8015ab:	eb 09                	jmp    8015b6 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ad:	89 c2                	mov    %eax,%edx
  8015af:	eb 05                	jmp    8015b6 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8015b1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8015b6:	89 d0                	mov    %edx,%eax
  8015b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015bb:	c9                   	leave  
  8015bc:	c3                   	ret    

008015bd <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015bd:	55                   	push   %ebp
  8015be:	89 e5                	mov    %esp,%ebp
  8015c0:	53                   	push   %ebx
  8015c1:	83 ec 14             	sub    $0x14,%esp
  8015c4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015c7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015ca:	50                   	push   %eax
  8015cb:	ff 75 08             	pushl  0x8(%ebp)
  8015ce:	e8 6c fb ff ff       	call   80113f <fd_lookup>
  8015d3:	83 c4 08             	add    $0x8,%esp
  8015d6:	89 c2                	mov    %eax,%edx
  8015d8:	85 c0                	test   %eax,%eax
  8015da:	78 58                	js     801634 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015dc:	83 ec 08             	sub    $0x8,%esp
  8015df:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015e2:	50                   	push   %eax
  8015e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015e6:	ff 30                	pushl  (%eax)
  8015e8:	e8 a8 fb ff ff       	call   801195 <dev_lookup>
  8015ed:	83 c4 10             	add    $0x10,%esp
  8015f0:	85 c0                	test   %eax,%eax
  8015f2:	78 37                	js     80162b <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8015f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015f7:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015fb:	74 32                	je     80162f <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015fd:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801600:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801607:	00 00 00 
	stat->st_isdir = 0;
  80160a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801611:	00 00 00 
	stat->st_dev = dev;
  801614:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80161a:	83 ec 08             	sub    $0x8,%esp
  80161d:	53                   	push   %ebx
  80161e:	ff 75 f0             	pushl  -0x10(%ebp)
  801621:	ff 50 14             	call   *0x14(%eax)
  801624:	89 c2                	mov    %eax,%edx
  801626:	83 c4 10             	add    $0x10,%esp
  801629:	eb 09                	jmp    801634 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80162b:	89 c2                	mov    %eax,%edx
  80162d:	eb 05                	jmp    801634 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80162f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801634:	89 d0                	mov    %edx,%eax
  801636:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801639:	c9                   	leave  
  80163a:	c3                   	ret    

0080163b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80163b:	55                   	push   %ebp
  80163c:	89 e5                	mov    %esp,%ebp
  80163e:	56                   	push   %esi
  80163f:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801640:	83 ec 08             	sub    $0x8,%esp
  801643:	6a 00                	push   $0x0
  801645:	ff 75 08             	pushl  0x8(%ebp)
  801648:	e8 0c 02 00 00       	call   801859 <open>
  80164d:	89 c3                	mov    %eax,%ebx
  80164f:	83 c4 10             	add    $0x10,%esp
  801652:	85 c0                	test   %eax,%eax
  801654:	78 1b                	js     801671 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801656:	83 ec 08             	sub    $0x8,%esp
  801659:	ff 75 0c             	pushl  0xc(%ebp)
  80165c:	50                   	push   %eax
  80165d:	e8 5b ff ff ff       	call   8015bd <fstat>
  801662:	89 c6                	mov    %eax,%esi
	close(fd);
  801664:	89 1c 24             	mov    %ebx,(%esp)
  801667:	e8 fd fb ff ff       	call   801269 <close>
	return r;
  80166c:	83 c4 10             	add    $0x10,%esp
  80166f:	89 f0                	mov    %esi,%eax
}
  801671:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801674:	5b                   	pop    %ebx
  801675:	5e                   	pop    %esi
  801676:	5d                   	pop    %ebp
  801677:	c3                   	ret    

00801678 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801678:	55                   	push   %ebp
  801679:	89 e5                	mov    %esp,%ebp
  80167b:	56                   	push   %esi
  80167c:	53                   	push   %ebx
  80167d:	89 c6                	mov    %eax,%esi
  80167f:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801681:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801688:	75 12                	jne    80169c <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80168a:	83 ec 0c             	sub    $0xc,%esp
  80168d:	6a 01                	push   $0x1
  80168f:	e8 fc f9 ff ff       	call   801090 <ipc_find_env>
  801694:	a3 00 40 80 00       	mov    %eax,0x804000
  801699:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80169c:	6a 07                	push   $0x7
  80169e:	68 00 50 80 00       	push   $0x805000
  8016a3:	56                   	push   %esi
  8016a4:	ff 35 00 40 80 00    	pushl  0x804000
  8016aa:	e8 8d f9 ff ff       	call   80103c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016af:	83 c4 0c             	add    $0xc,%esp
  8016b2:	6a 00                	push   $0x0
  8016b4:	53                   	push   %ebx
  8016b5:	6a 00                	push   $0x0
  8016b7:	e8 17 f9 ff ff       	call   800fd3 <ipc_recv>
}
  8016bc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016bf:	5b                   	pop    %ebx
  8016c0:	5e                   	pop    %esi
  8016c1:	5d                   	pop    %ebp
  8016c2:	c3                   	ret    

008016c3 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016c3:	55                   	push   %ebp
  8016c4:	89 e5                	mov    %esp,%ebp
  8016c6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8016cc:	8b 40 0c             	mov    0xc(%eax),%eax
  8016cf:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8016d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016d7:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8016e1:	b8 02 00 00 00       	mov    $0x2,%eax
  8016e6:	e8 8d ff ff ff       	call   801678 <fsipc>
}
  8016eb:	c9                   	leave  
  8016ec:	c3                   	ret    

008016ed <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8016ed:	55                   	push   %ebp
  8016ee:	89 e5                	mov    %esp,%ebp
  8016f0:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f6:	8b 40 0c             	mov    0xc(%eax),%eax
  8016f9:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016fe:	ba 00 00 00 00       	mov    $0x0,%edx
  801703:	b8 06 00 00 00       	mov    $0x6,%eax
  801708:	e8 6b ff ff ff       	call   801678 <fsipc>
}
  80170d:	c9                   	leave  
  80170e:	c3                   	ret    

0080170f <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80170f:	55                   	push   %ebp
  801710:	89 e5                	mov    %esp,%ebp
  801712:	53                   	push   %ebx
  801713:	83 ec 04             	sub    $0x4,%esp
  801716:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801719:	8b 45 08             	mov    0x8(%ebp),%eax
  80171c:	8b 40 0c             	mov    0xc(%eax),%eax
  80171f:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801724:	ba 00 00 00 00       	mov    $0x0,%edx
  801729:	b8 05 00 00 00       	mov    $0x5,%eax
  80172e:	e8 45 ff ff ff       	call   801678 <fsipc>
  801733:	85 c0                	test   %eax,%eax
  801735:	78 2c                	js     801763 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801737:	83 ec 08             	sub    $0x8,%esp
  80173a:	68 00 50 80 00       	push   $0x805000
  80173f:	53                   	push   %ebx
  801740:	e8 f1 ef ff ff       	call   800736 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801745:	a1 80 50 80 00       	mov    0x805080,%eax
  80174a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801750:	a1 84 50 80 00       	mov    0x805084,%eax
  801755:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80175b:	83 c4 10             	add    $0x10,%esp
  80175e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801763:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801766:	c9                   	leave  
  801767:	c3                   	ret    

00801768 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801768:	55                   	push   %ebp
  801769:	89 e5                	mov    %esp,%ebp
  80176b:	53                   	push   %ebx
  80176c:	83 ec 08             	sub    $0x8,%esp
  80176f:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801772:	8b 55 08             	mov    0x8(%ebp),%edx
  801775:	8b 52 0c             	mov    0xc(%edx),%edx
  801778:	89 15 00 50 80 00    	mov    %edx,0x805000
  80177e:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801783:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  801788:	0f 46 d8             	cmovbe %eax,%ebx
	
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  80178b:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  801791:	53                   	push   %ebx
  801792:	ff 75 0c             	pushl  0xc(%ebp)
  801795:	68 08 50 80 00       	push   $0x805008
  80179a:	e8 29 f1 ff ff       	call   8008c8 <memmove>

	
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) 
  80179f:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a4:	b8 04 00 00 00       	mov    $0x4,%eax
  8017a9:	e8 ca fe ff ff       	call   801678 <fsipc>
  8017ae:	83 c4 10             	add    $0x10,%esp
  8017b1:	85 c0                	test   %eax,%eax
  8017b3:	78 1d                	js     8017d2 <devfile_write+0x6a>
		return r;
	assert(r <= n_real); 
  8017b5:	39 d8                	cmp    %ebx,%eax
  8017b7:	76 19                	jbe    8017d2 <devfile_write+0x6a>
  8017b9:	68 0c 26 80 00       	push   $0x80260c
  8017be:	68 18 26 80 00       	push   $0x802618
  8017c3:	68 a3 00 00 00       	push   $0xa3
  8017c8:	68 2d 26 80 00       	push   $0x80262d
  8017cd:	e8 0a 06 00 00       	call   801ddc <_panic>
	return r;
}
  8017d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017d5:	c9                   	leave  
  8017d6:	c3                   	ret    

008017d7 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017d7:	55                   	push   %ebp
  8017d8:	89 e5                	mov    %esp,%ebp
  8017da:	56                   	push   %esi
  8017db:	53                   	push   %ebx
  8017dc:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017df:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e2:	8b 40 0c             	mov    0xc(%eax),%eax
  8017e5:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8017ea:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f5:	b8 03 00 00 00       	mov    $0x3,%eax
  8017fa:	e8 79 fe ff ff       	call   801678 <fsipc>
  8017ff:	89 c3                	mov    %eax,%ebx
  801801:	85 c0                	test   %eax,%eax
  801803:	78 4b                	js     801850 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801805:	39 c6                	cmp    %eax,%esi
  801807:	73 16                	jae    80181f <devfile_read+0x48>
  801809:	68 38 26 80 00       	push   $0x802638
  80180e:	68 18 26 80 00       	push   $0x802618
  801813:	6a 7c                	push   $0x7c
  801815:	68 2d 26 80 00       	push   $0x80262d
  80181a:	e8 bd 05 00 00       	call   801ddc <_panic>
	assert(r <= PGSIZE);
  80181f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801824:	7e 16                	jle    80183c <devfile_read+0x65>
  801826:	68 3f 26 80 00       	push   $0x80263f
  80182b:	68 18 26 80 00       	push   $0x802618
  801830:	6a 7d                	push   $0x7d
  801832:	68 2d 26 80 00       	push   $0x80262d
  801837:	e8 a0 05 00 00       	call   801ddc <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80183c:	83 ec 04             	sub    $0x4,%esp
  80183f:	50                   	push   %eax
  801840:	68 00 50 80 00       	push   $0x805000
  801845:	ff 75 0c             	pushl  0xc(%ebp)
  801848:	e8 7b f0 ff ff       	call   8008c8 <memmove>
	return r;
  80184d:	83 c4 10             	add    $0x10,%esp
}
  801850:	89 d8                	mov    %ebx,%eax
  801852:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801855:	5b                   	pop    %ebx
  801856:	5e                   	pop    %esi
  801857:	5d                   	pop    %ebp
  801858:	c3                   	ret    

00801859 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801859:	55                   	push   %ebp
  80185a:	89 e5                	mov    %esp,%ebp
  80185c:	53                   	push   %ebx
  80185d:	83 ec 20             	sub    $0x20,%esp
  801860:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801863:	53                   	push   %ebx
  801864:	e8 94 ee ff ff       	call   8006fd <strlen>
  801869:	83 c4 10             	add    $0x10,%esp
  80186c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801871:	7f 67                	jg     8018da <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801873:	83 ec 0c             	sub    $0xc,%esp
  801876:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801879:	50                   	push   %eax
  80187a:	e8 71 f8 ff ff       	call   8010f0 <fd_alloc>
  80187f:	83 c4 10             	add    $0x10,%esp
		return r;
  801882:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801884:	85 c0                	test   %eax,%eax
  801886:	78 57                	js     8018df <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801888:	83 ec 08             	sub    $0x8,%esp
  80188b:	53                   	push   %ebx
  80188c:	68 00 50 80 00       	push   $0x805000
  801891:	e8 a0 ee ff ff       	call   800736 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801896:	8b 45 0c             	mov    0xc(%ebp),%eax
  801899:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80189e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018a1:	b8 01 00 00 00       	mov    $0x1,%eax
  8018a6:	e8 cd fd ff ff       	call   801678 <fsipc>
  8018ab:	89 c3                	mov    %eax,%ebx
  8018ad:	83 c4 10             	add    $0x10,%esp
  8018b0:	85 c0                	test   %eax,%eax
  8018b2:	79 14                	jns    8018c8 <open+0x6f>
		fd_close(fd, 0);
  8018b4:	83 ec 08             	sub    $0x8,%esp
  8018b7:	6a 00                	push   $0x0
  8018b9:	ff 75 f4             	pushl  -0xc(%ebp)
  8018bc:	e8 27 f9 ff ff       	call   8011e8 <fd_close>
		return r;
  8018c1:	83 c4 10             	add    $0x10,%esp
  8018c4:	89 da                	mov    %ebx,%edx
  8018c6:	eb 17                	jmp    8018df <open+0x86>
	}

	return fd2num(fd);
  8018c8:	83 ec 0c             	sub    $0xc,%esp
  8018cb:	ff 75 f4             	pushl  -0xc(%ebp)
  8018ce:	e8 f6 f7 ff ff       	call   8010c9 <fd2num>
  8018d3:	89 c2                	mov    %eax,%edx
  8018d5:	83 c4 10             	add    $0x10,%esp
  8018d8:	eb 05                	jmp    8018df <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8018da:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8018df:	89 d0                	mov    %edx,%eax
  8018e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018e4:	c9                   	leave  
  8018e5:	c3                   	ret    

008018e6 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8018e6:	55                   	push   %ebp
  8018e7:	89 e5                	mov    %esp,%ebp
  8018e9:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8018f1:	b8 08 00 00 00       	mov    $0x8,%eax
  8018f6:	e8 7d fd ff ff       	call   801678 <fsipc>
}
  8018fb:	c9                   	leave  
  8018fc:	c3                   	ret    

008018fd <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8018fd:	55                   	push   %ebp
  8018fe:	89 e5                	mov    %esp,%ebp
  801900:	56                   	push   %esi
  801901:	53                   	push   %ebx
  801902:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801905:	83 ec 0c             	sub    $0xc,%esp
  801908:	ff 75 08             	pushl  0x8(%ebp)
  80190b:	e8 c9 f7 ff ff       	call   8010d9 <fd2data>
  801910:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801912:	83 c4 08             	add    $0x8,%esp
  801915:	68 4b 26 80 00       	push   $0x80264b
  80191a:	53                   	push   %ebx
  80191b:	e8 16 ee ff ff       	call   800736 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801920:	8b 46 04             	mov    0x4(%esi),%eax
  801923:	2b 06                	sub    (%esi),%eax
  801925:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80192b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801932:	00 00 00 
	stat->st_dev = &devpipe;
  801935:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80193c:	30 80 00 
	return 0;
}
  80193f:	b8 00 00 00 00       	mov    $0x0,%eax
  801944:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801947:	5b                   	pop    %ebx
  801948:	5e                   	pop    %esi
  801949:	5d                   	pop    %ebp
  80194a:	c3                   	ret    

0080194b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80194b:	55                   	push   %ebp
  80194c:	89 e5                	mov    %esp,%ebp
  80194e:	53                   	push   %ebx
  80194f:	83 ec 0c             	sub    $0xc,%esp
  801952:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801955:	53                   	push   %ebx
  801956:	6a 00                	push   $0x0
  801958:	e8 61 f2 ff ff       	call   800bbe <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80195d:	89 1c 24             	mov    %ebx,(%esp)
  801960:	e8 74 f7 ff ff       	call   8010d9 <fd2data>
  801965:	83 c4 08             	add    $0x8,%esp
  801968:	50                   	push   %eax
  801969:	6a 00                	push   $0x0
  80196b:	e8 4e f2 ff ff       	call   800bbe <sys_page_unmap>
}
  801970:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801973:	c9                   	leave  
  801974:	c3                   	ret    

00801975 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801975:	55                   	push   %ebp
  801976:	89 e5                	mov    %esp,%ebp
  801978:	57                   	push   %edi
  801979:	56                   	push   %esi
  80197a:	53                   	push   %ebx
  80197b:	83 ec 1c             	sub    $0x1c,%esp
  80197e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801981:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801983:	a1 04 40 80 00       	mov    0x804004,%eax
  801988:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80198b:	83 ec 0c             	sub    $0xc,%esp
  80198e:	ff 75 e0             	pushl  -0x20(%ebp)
  801991:	e8 02 05 00 00       	call   801e98 <pageref>
  801996:	89 c3                	mov    %eax,%ebx
  801998:	89 3c 24             	mov    %edi,(%esp)
  80199b:	e8 f8 04 00 00       	call   801e98 <pageref>
  8019a0:	83 c4 10             	add    $0x10,%esp
  8019a3:	39 c3                	cmp    %eax,%ebx
  8019a5:	0f 94 c1             	sete   %cl
  8019a8:	0f b6 c9             	movzbl %cl,%ecx
  8019ab:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8019ae:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8019b4:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8019b7:	39 ce                	cmp    %ecx,%esi
  8019b9:	74 1b                	je     8019d6 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8019bb:	39 c3                	cmp    %eax,%ebx
  8019bd:	75 c4                	jne    801983 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8019bf:	8b 42 58             	mov    0x58(%edx),%eax
  8019c2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8019c5:	50                   	push   %eax
  8019c6:	56                   	push   %esi
  8019c7:	68 52 26 80 00       	push   $0x802652
  8019cc:	e8 e0 e7 ff ff       	call   8001b1 <cprintf>
  8019d1:	83 c4 10             	add    $0x10,%esp
  8019d4:	eb ad                	jmp    801983 <_pipeisclosed+0xe>
	}
}
  8019d6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019dc:	5b                   	pop    %ebx
  8019dd:	5e                   	pop    %esi
  8019de:	5f                   	pop    %edi
  8019df:	5d                   	pop    %ebp
  8019e0:	c3                   	ret    

008019e1 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019e1:	55                   	push   %ebp
  8019e2:	89 e5                	mov    %esp,%ebp
  8019e4:	57                   	push   %edi
  8019e5:	56                   	push   %esi
  8019e6:	53                   	push   %ebx
  8019e7:	83 ec 28             	sub    $0x28,%esp
  8019ea:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8019ed:	56                   	push   %esi
  8019ee:	e8 e6 f6 ff ff       	call   8010d9 <fd2data>
  8019f3:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019f5:	83 c4 10             	add    $0x10,%esp
  8019f8:	bf 00 00 00 00       	mov    $0x0,%edi
  8019fd:	eb 4b                	jmp    801a4a <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8019ff:	89 da                	mov    %ebx,%edx
  801a01:	89 f0                	mov    %esi,%eax
  801a03:	e8 6d ff ff ff       	call   801975 <_pipeisclosed>
  801a08:	85 c0                	test   %eax,%eax
  801a0a:	75 48                	jne    801a54 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a0c:	e8 09 f1 ff ff       	call   800b1a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a11:	8b 43 04             	mov    0x4(%ebx),%eax
  801a14:	8b 0b                	mov    (%ebx),%ecx
  801a16:	8d 51 20             	lea    0x20(%ecx),%edx
  801a19:	39 d0                	cmp    %edx,%eax
  801a1b:	73 e2                	jae    8019ff <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a20:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a24:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a27:	89 c2                	mov    %eax,%edx
  801a29:	c1 fa 1f             	sar    $0x1f,%edx
  801a2c:	89 d1                	mov    %edx,%ecx
  801a2e:	c1 e9 1b             	shr    $0x1b,%ecx
  801a31:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801a34:	83 e2 1f             	and    $0x1f,%edx
  801a37:	29 ca                	sub    %ecx,%edx
  801a39:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801a3d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a41:	83 c0 01             	add    $0x1,%eax
  801a44:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a47:	83 c7 01             	add    $0x1,%edi
  801a4a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a4d:	75 c2                	jne    801a11 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a4f:	8b 45 10             	mov    0x10(%ebp),%eax
  801a52:	eb 05                	jmp    801a59 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a54:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801a59:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a5c:	5b                   	pop    %ebx
  801a5d:	5e                   	pop    %esi
  801a5e:	5f                   	pop    %edi
  801a5f:	5d                   	pop    %ebp
  801a60:	c3                   	ret    

00801a61 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a61:	55                   	push   %ebp
  801a62:	89 e5                	mov    %esp,%ebp
  801a64:	57                   	push   %edi
  801a65:	56                   	push   %esi
  801a66:	53                   	push   %ebx
  801a67:	83 ec 18             	sub    $0x18,%esp
  801a6a:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a6d:	57                   	push   %edi
  801a6e:	e8 66 f6 ff ff       	call   8010d9 <fd2data>
  801a73:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a75:	83 c4 10             	add    $0x10,%esp
  801a78:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a7d:	eb 3d                	jmp    801abc <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801a7f:	85 db                	test   %ebx,%ebx
  801a81:	74 04                	je     801a87 <devpipe_read+0x26>
				return i;
  801a83:	89 d8                	mov    %ebx,%eax
  801a85:	eb 44                	jmp    801acb <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801a87:	89 f2                	mov    %esi,%edx
  801a89:	89 f8                	mov    %edi,%eax
  801a8b:	e8 e5 fe ff ff       	call   801975 <_pipeisclosed>
  801a90:	85 c0                	test   %eax,%eax
  801a92:	75 32                	jne    801ac6 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801a94:	e8 81 f0 ff ff       	call   800b1a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801a99:	8b 06                	mov    (%esi),%eax
  801a9b:	3b 46 04             	cmp    0x4(%esi),%eax
  801a9e:	74 df                	je     801a7f <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801aa0:	99                   	cltd   
  801aa1:	c1 ea 1b             	shr    $0x1b,%edx
  801aa4:	01 d0                	add    %edx,%eax
  801aa6:	83 e0 1f             	and    $0x1f,%eax
  801aa9:	29 d0                	sub    %edx,%eax
  801aab:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801ab0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ab3:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801ab6:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ab9:	83 c3 01             	add    $0x1,%ebx
  801abc:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801abf:	75 d8                	jne    801a99 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801ac1:	8b 45 10             	mov    0x10(%ebp),%eax
  801ac4:	eb 05                	jmp    801acb <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ac6:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801acb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ace:	5b                   	pop    %ebx
  801acf:	5e                   	pop    %esi
  801ad0:	5f                   	pop    %edi
  801ad1:	5d                   	pop    %ebp
  801ad2:	c3                   	ret    

00801ad3 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801ad3:	55                   	push   %ebp
  801ad4:	89 e5                	mov    %esp,%ebp
  801ad6:	56                   	push   %esi
  801ad7:	53                   	push   %ebx
  801ad8:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801adb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ade:	50                   	push   %eax
  801adf:	e8 0c f6 ff ff       	call   8010f0 <fd_alloc>
  801ae4:	83 c4 10             	add    $0x10,%esp
  801ae7:	89 c2                	mov    %eax,%edx
  801ae9:	85 c0                	test   %eax,%eax
  801aeb:	0f 88 2c 01 00 00    	js     801c1d <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801af1:	83 ec 04             	sub    $0x4,%esp
  801af4:	68 07 04 00 00       	push   $0x407
  801af9:	ff 75 f4             	pushl  -0xc(%ebp)
  801afc:	6a 00                	push   $0x0
  801afe:	e8 36 f0 ff ff       	call   800b39 <sys_page_alloc>
  801b03:	83 c4 10             	add    $0x10,%esp
  801b06:	89 c2                	mov    %eax,%edx
  801b08:	85 c0                	test   %eax,%eax
  801b0a:	0f 88 0d 01 00 00    	js     801c1d <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b10:	83 ec 0c             	sub    $0xc,%esp
  801b13:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b16:	50                   	push   %eax
  801b17:	e8 d4 f5 ff ff       	call   8010f0 <fd_alloc>
  801b1c:	89 c3                	mov    %eax,%ebx
  801b1e:	83 c4 10             	add    $0x10,%esp
  801b21:	85 c0                	test   %eax,%eax
  801b23:	0f 88 e2 00 00 00    	js     801c0b <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b29:	83 ec 04             	sub    $0x4,%esp
  801b2c:	68 07 04 00 00       	push   $0x407
  801b31:	ff 75 f0             	pushl  -0x10(%ebp)
  801b34:	6a 00                	push   $0x0
  801b36:	e8 fe ef ff ff       	call   800b39 <sys_page_alloc>
  801b3b:	89 c3                	mov    %eax,%ebx
  801b3d:	83 c4 10             	add    $0x10,%esp
  801b40:	85 c0                	test   %eax,%eax
  801b42:	0f 88 c3 00 00 00    	js     801c0b <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b48:	83 ec 0c             	sub    $0xc,%esp
  801b4b:	ff 75 f4             	pushl  -0xc(%ebp)
  801b4e:	e8 86 f5 ff ff       	call   8010d9 <fd2data>
  801b53:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b55:	83 c4 0c             	add    $0xc,%esp
  801b58:	68 07 04 00 00       	push   $0x407
  801b5d:	50                   	push   %eax
  801b5e:	6a 00                	push   $0x0
  801b60:	e8 d4 ef ff ff       	call   800b39 <sys_page_alloc>
  801b65:	89 c3                	mov    %eax,%ebx
  801b67:	83 c4 10             	add    $0x10,%esp
  801b6a:	85 c0                	test   %eax,%eax
  801b6c:	0f 88 89 00 00 00    	js     801bfb <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b72:	83 ec 0c             	sub    $0xc,%esp
  801b75:	ff 75 f0             	pushl  -0x10(%ebp)
  801b78:	e8 5c f5 ff ff       	call   8010d9 <fd2data>
  801b7d:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b84:	50                   	push   %eax
  801b85:	6a 00                	push   $0x0
  801b87:	56                   	push   %esi
  801b88:	6a 00                	push   $0x0
  801b8a:	e8 ed ef ff ff       	call   800b7c <sys_page_map>
  801b8f:	89 c3                	mov    %eax,%ebx
  801b91:	83 c4 20             	add    $0x20,%esp
  801b94:	85 c0                	test   %eax,%eax
  801b96:	78 55                	js     801bed <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801b98:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ba1:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ba3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ba6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801bad:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bb3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bb6:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801bb8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bbb:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801bc2:	83 ec 0c             	sub    $0xc,%esp
  801bc5:	ff 75 f4             	pushl  -0xc(%ebp)
  801bc8:	e8 fc f4 ff ff       	call   8010c9 <fd2num>
  801bcd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bd0:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801bd2:	83 c4 04             	add    $0x4,%esp
  801bd5:	ff 75 f0             	pushl  -0x10(%ebp)
  801bd8:	e8 ec f4 ff ff       	call   8010c9 <fd2num>
  801bdd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801be0:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801be3:	83 c4 10             	add    $0x10,%esp
  801be6:	ba 00 00 00 00       	mov    $0x0,%edx
  801beb:	eb 30                	jmp    801c1d <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801bed:	83 ec 08             	sub    $0x8,%esp
  801bf0:	56                   	push   %esi
  801bf1:	6a 00                	push   $0x0
  801bf3:	e8 c6 ef ff ff       	call   800bbe <sys_page_unmap>
  801bf8:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801bfb:	83 ec 08             	sub    $0x8,%esp
  801bfe:	ff 75 f0             	pushl  -0x10(%ebp)
  801c01:	6a 00                	push   $0x0
  801c03:	e8 b6 ef ff ff       	call   800bbe <sys_page_unmap>
  801c08:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c0b:	83 ec 08             	sub    $0x8,%esp
  801c0e:	ff 75 f4             	pushl  -0xc(%ebp)
  801c11:	6a 00                	push   $0x0
  801c13:	e8 a6 ef ff ff       	call   800bbe <sys_page_unmap>
  801c18:	83 c4 10             	add    $0x10,%esp
  801c1b:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801c1d:	89 d0                	mov    %edx,%eax
  801c1f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c22:	5b                   	pop    %ebx
  801c23:	5e                   	pop    %esi
  801c24:	5d                   	pop    %ebp
  801c25:	c3                   	ret    

00801c26 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c26:	55                   	push   %ebp
  801c27:	89 e5                	mov    %esp,%ebp
  801c29:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c2c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c2f:	50                   	push   %eax
  801c30:	ff 75 08             	pushl  0x8(%ebp)
  801c33:	e8 07 f5 ff ff       	call   80113f <fd_lookup>
  801c38:	83 c4 10             	add    $0x10,%esp
  801c3b:	85 c0                	test   %eax,%eax
  801c3d:	78 18                	js     801c57 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c3f:	83 ec 0c             	sub    $0xc,%esp
  801c42:	ff 75 f4             	pushl  -0xc(%ebp)
  801c45:	e8 8f f4 ff ff       	call   8010d9 <fd2data>
	return _pipeisclosed(fd, p);
  801c4a:	89 c2                	mov    %eax,%edx
  801c4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c4f:	e8 21 fd ff ff       	call   801975 <_pipeisclosed>
  801c54:	83 c4 10             	add    $0x10,%esp
}
  801c57:	c9                   	leave  
  801c58:	c3                   	ret    

00801c59 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c59:	55                   	push   %ebp
  801c5a:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801c5c:	b8 00 00 00 00       	mov    $0x0,%eax
  801c61:	5d                   	pop    %ebp
  801c62:	c3                   	ret    

00801c63 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c63:	55                   	push   %ebp
  801c64:	89 e5                	mov    %esp,%ebp
  801c66:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801c69:	68 6a 26 80 00       	push   $0x80266a
  801c6e:	ff 75 0c             	pushl  0xc(%ebp)
  801c71:	e8 c0 ea ff ff       	call   800736 <strcpy>
	return 0;
}
  801c76:	b8 00 00 00 00       	mov    $0x0,%eax
  801c7b:	c9                   	leave  
  801c7c:	c3                   	ret    

00801c7d <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c7d:	55                   	push   %ebp
  801c7e:	89 e5                	mov    %esp,%ebp
  801c80:	57                   	push   %edi
  801c81:	56                   	push   %esi
  801c82:	53                   	push   %ebx
  801c83:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c89:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c8e:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c94:	eb 2d                	jmp    801cc3 <devcons_write+0x46>
		m = n - tot;
  801c96:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c99:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801c9b:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801c9e:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801ca3:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ca6:	83 ec 04             	sub    $0x4,%esp
  801ca9:	53                   	push   %ebx
  801caa:	03 45 0c             	add    0xc(%ebp),%eax
  801cad:	50                   	push   %eax
  801cae:	57                   	push   %edi
  801caf:	e8 14 ec ff ff       	call   8008c8 <memmove>
		sys_cputs(buf, m);
  801cb4:	83 c4 08             	add    $0x8,%esp
  801cb7:	53                   	push   %ebx
  801cb8:	57                   	push   %edi
  801cb9:	e8 bf ed ff ff       	call   800a7d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cbe:	01 de                	add    %ebx,%esi
  801cc0:	83 c4 10             	add    $0x10,%esp
  801cc3:	89 f0                	mov    %esi,%eax
  801cc5:	3b 75 10             	cmp    0x10(%ebp),%esi
  801cc8:	72 cc                	jb     801c96 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801cca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ccd:	5b                   	pop    %ebx
  801cce:	5e                   	pop    %esi
  801ccf:	5f                   	pop    %edi
  801cd0:	5d                   	pop    %ebp
  801cd1:	c3                   	ret    

00801cd2 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801cd2:	55                   	push   %ebp
  801cd3:	89 e5                	mov    %esp,%ebp
  801cd5:	83 ec 08             	sub    $0x8,%esp
  801cd8:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801cdd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ce1:	74 2a                	je     801d0d <devcons_read+0x3b>
  801ce3:	eb 05                	jmp    801cea <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801ce5:	e8 30 ee ff ff       	call   800b1a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801cea:	e8 ac ed ff ff       	call   800a9b <sys_cgetc>
  801cef:	85 c0                	test   %eax,%eax
  801cf1:	74 f2                	je     801ce5 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801cf3:	85 c0                	test   %eax,%eax
  801cf5:	78 16                	js     801d0d <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801cf7:	83 f8 04             	cmp    $0x4,%eax
  801cfa:	74 0c                	je     801d08 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801cfc:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cff:	88 02                	mov    %al,(%edx)
	return 1;
  801d01:	b8 01 00 00 00       	mov    $0x1,%eax
  801d06:	eb 05                	jmp    801d0d <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801d08:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801d0d:	c9                   	leave  
  801d0e:	c3                   	ret    

00801d0f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801d0f:	55                   	push   %ebp
  801d10:	89 e5                	mov    %esp,%ebp
  801d12:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801d15:	8b 45 08             	mov    0x8(%ebp),%eax
  801d18:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801d1b:	6a 01                	push   $0x1
  801d1d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d20:	50                   	push   %eax
  801d21:	e8 57 ed ff ff       	call   800a7d <sys_cputs>
}
  801d26:	83 c4 10             	add    $0x10,%esp
  801d29:	c9                   	leave  
  801d2a:	c3                   	ret    

00801d2b <getchar>:

int
getchar(void)
{
  801d2b:	55                   	push   %ebp
  801d2c:	89 e5                	mov    %esp,%ebp
  801d2e:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801d31:	6a 01                	push   $0x1
  801d33:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d36:	50                   	push   %eax
  801d37:	6a 00                	push   $0x0
  801d39:	e8 67 f6 ff ff       	call   8013a5 <read>
	if (r < 0)
  801d3e:	83 c4 10             	add    $0x10,%esp
  801d41:	85 c0                	test   %eax,%eax
  801d43:	78 0f                	js     801d54 <getchar+0x29>
		return r;
	if (r < 1)
  801d45:	85 c0                	test   %eax,%eax
  801d47:	7e 06                	jle    801d4f <getchar+0x24>
		return -E_EOF;
	return c;
  801d49:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801d4d:	eb 05                	jmp    801d54 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801d4f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801d54:	c9                   	leave  
  801d55:	c3                   	ret    

00801d56 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801d56:	55                   	push   %ebp
  801d57:	89 e5                	mov    %esp,%ebp
  801d59:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d5c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d5f:	50                   	push   %eax
  801d60:	ff 75 08             	pushl  0x8(%ebp)
  801d63:	e8 d7 f3 ff ff       	call   80113f <fd_lookup>
  801d68:	83 c4 10             	add    $0x10,%esp
  801d6b:	85 c0                	test   %eax,%eax
  801d6d:	78 11                	js     801d80 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801d6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d72:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d78:	39 10                	cmp    %edx,(%eax)
  801d7a:	0f 94 c0             	sete   %al
  801d7d:	0f b6 c0             	movzbl %al,%eax
}
  801d80:	c9                   	leave  
  801d81:	c3                   	ret    

00801d82 <opencons>:

int
opencons(void)
{
  801d82:	55                   	push   %ebp
  801d83:	89 e5                	mov    %esp,%ebp
  801d85:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d88:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d8b:	50                   	push   %eax
  801d8c:	e8 5f f3 ff ff       	call   8010f0 <fd_alloc>
  801d91:	83 c4 10             	add    $0x10,%esp
		return r;
  801d94:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d96:	85 c0                	test   %eax,%eax
  801d98:	78 3e                	js     801dd8 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d9a:	83 ec 04             	sub    $0x4,%esp
  801d9d:	68 07 04 00 00       	push   $0x407
  801da2:	ff 75 f4             	pushl  -0xc(%ebp)
  801da5:	6a 00                	push   $0x0
  801da7:	e8 8d ed ff ff       	call   800b39 <sys_page_alloc>
  801dac:	83 c4 10             	add    $0x10,%esp
		return r;
  801daf:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801db1:	85 c0                	test   %eax,%eax
  801db3:	78 23                	js     801dd8 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801db5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801dbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dbe:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801dc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dc3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801dca:	83 ec 0c             	sub    $0xc,%esp
  801dcd:	50                   	push   %eax
  801dce:	e8 f6 f2 ff ff       	call   8010c9 <fd2num>
  801dd3:	89 c2                	mov    %eax,%edx
  801dd5:	83 c4 10             	add    $0x10,%esp
}
  801dd8:	89 d0                	mov    %edx,%eax
  801dda:	c9                   	leave  
  801ddb:	c3                   	ret    

00801ddc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801ddc:	55                   	push   %ebp
  801ddd:	89 e5                	mov    %esp,%ebp
  801ddf:	56                   	push   %esi
  801de0:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801de1:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801de4:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801dea:	e8 0c ed ff ff       	call   800afb <sys_getenvid>
  801def:	83 ec 0c             	sub    $0xc,%esp
  801df2:	ff 75 0c             	pushl  0xc(%ebp)
  801df5:	ff 75 08             	pushl  0x8(%ebp)
  801df8:	56                   	push   %esi
  801df9:	50                   	push   %eax
  801dfa:	68 78 26 80 00       	push   $0x802678
  801dff:	e8 ad e3 ff ff       	call   8001b1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801e04:	83 c4 18             	add    $0x18,%esp
  801e07:	53                   	push   %ebx
  801e08:	ff 75 10             	pushl  0x10(%ebp)
  801e0b:	e8 50 e3 ff ff       	call   800160 <vcprintf>
	cprintf("\n");
  801e10:	c7 04 24 63 26 80 00 	movl   $0x802663,(%esp)
  801e17:	e8 95 e3 ff ff       	call   8001b1 <cprintf>
  801e1c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801e1f:	cc                   	int3   
  801e20:	eb fd                	jmp    801e1f <_panic+0x43>

00801e22 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801e22:	55                   	push   %ebp
  801e23:	89 e5                	mov    %esp,%ebp
  801e25:	53                   	push   %ebx
  801e26:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  801e29:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801e30:	75 28                	jne    801e5a <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  801e32:	e8 c4 ec ff ff       	call   800afb <sys_getenvid>
  801e37:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_U | PTE_W);
  801e39:	83 ec 04             	sub    $0x4,%esp
  801e3c:	6a 06                	push   $0x6
  801e3e:	68 00 f0 bf ee       	push   $0xeebff000
  801e43:	50                   	push   %eax
  801e44:	e8 f0 ec ff ff       	call   800b39 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  801e49:	83 c4 08             	add    $0x8,%esp
  801e4c:	68 67 1e 80 00       	push   $0x801e67
  801e51:	53                   	push   %ebx
  801e52:	e8 2d ee ff ff       	call   800c84 <sys_env_set_pgfault_upcall>
  801e57:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801e5a:	8b 45 08             	mov    0x8(%ebp),%eax
  801e5d:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801e62:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e65:	c9                   	leave  
  801e66:	c3                   	ret    

00801e67 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e67:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e68:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e6d:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e6f:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	# My method is different. Copy the values to the other stack
	# in a convinient way, and then pop everything.
	movl %esp, %ebp		# ebp refers to the exception stack
  801e72:	89 e5                	mov    %esp,%ebp
	movl 48(%ebp), %esp 	# go to other stack
  801e74:	8b 65 30             	mov    0x30(%ebp),%esp

	pushl 40(%ebp)		# eip - ORDER SWITCHED WITH EFLAGS
  801e77:	ff 75 28             	pushl  0x28(%ebp)
	pushl 44(%ebp)      	# eflags
  801e7a:	ff 75 2c             	pushl  0x2c(%ebp)
	pushl 36(%ebp)		# all the 8 remaining regs
  801e7d:	ff 75 24             	pushl  0x24(%ebp)
	pushl 32(%ebp)
  801e80:	ff 75 20             	pushl  0x20(%ebp)
	pushl 28(%ebp)
  801e83:	ff 75 1c             	pushl  0x1c(%ebp)
	pushl 24(%ebp)
  801e86:	ff 75 18             	pushl  0x18(%ebp)
	pushl 20(%ebp)
  801e89:	ff 75 14             	pushl  0x14(%ebp)
	pushl 16(%ebp)
  801e8c:	ff 75 10             	pushl  0x10(%ebp)
	pushl 12(%ebp)
  801e8f:	ff 75 0c             	pushl  0xc(%ebp)
	pushl 8(%ebp)
  801e92:	ff 75 08             	pushl  0x8(%ebp)

	popal			# now just pop everything!
  801e95:	61                   	popa   
	popfl
  801e96:	9d                   	popf   
	ret
  801e97:	c3                   	ret    

00801e98 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801e98:	55                   	push   %ebp
  801e99:	89 e5                	mov    %esp,%ebp
  801e9b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e9e:	89 d0                	mov    %edx,%eax
  801ea0:	c1 e8 16             	shr    $0x16,%eax
  801ea3:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801eaa:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801eaf:	f6 c1 01             	test   $0x1,%cl
  801eb2:	74 1d                	je     801ed1 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801eb4:	c1 ea 0c             	shr    $0xc,%edx
  801eb7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801ebe:	f6 c2 01             	test   $0x1,%dl
  801ec1:	74 0e                	je     801ed1 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ec3:	c1 ea 0c             	shr    $0xc,%edx
  801ec6:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801ecd:	ef 
  801ece:	0f b7 c0             	movzwl %ax,%eax
}
  801ed1:	5d                   	pop    %ebp
  801ed2:	c3                   	ret    
  801ed3:	66 90                	xchg   %ax,%ax
  801ed5:	66 90                	xchg   %ax,%ax
  801ed7:	66 90                	xchg   %ax,%ax
  801ed9:	66 90                	xchg   %ax,%ax
  801edb:	66 90                	xchg   %ax,%ax
  801edd:	66 90                	xchg   %ax,%ax
  801edf:	90                   	nop

00801ee0 <__udivdi3>:
  801ee0:	55                   	push   %ebp
  801ee1:	57                   	push   %edi
  801ee2:	56                   	push   %esi
  801ee3:	53                   	push   %ebx
  801ee4:	83 ec 1c             	sub    $0x1c,%esp
  801ee7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801eeb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801eef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801ef3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ef7:	85 f6                	test   %esi,%esi
  801ef9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801efd:	89 ca                	mov    %ecx,%edx
  801eff:	89 f8                	mov    %edi,%eax
  801f01:	75 3d                	jne    801f40 <__udivdi3+0x60>
  801f03:	39 cf                	cmp    %ecx,%edi
  801f05:	0f 87 c5 00 00 00    	ja     801fd0 <__udivdi3+0xf0>
  801f0b:	85 ff                	test   %edi,%edi
  801f0d:	89 fd                	mov    %edi,%ebp
  801f0f:	75 0b                	jne    801f1c <__udivdi3+0x3c>
  801f11:	b8 01 00 00 00       	mov    $0x1,%eax
  801f16:	31 d2                	xor    %edx,%edx
  801f18:	f7 f7                	div    %edi
  801f1a:	89 c5                	mov    %eax,%ebp
  801f1c:	89 c8                	mov    %ecx,%eax
  801f1e:	31 d2                	xor    %edx,%edx
  801f20:	f7 f5                	div    %ebp
  801f22:	89 c1                	mov    %eax,%ecx
  801f24:	89 d8                	mov    %ebx,%eax
  801f26:	89 cf                	mov    %ecx,%edi
  801f28:	f7 f5                	div    %ebp
  801f2a:	89 c3                	mov    %eax,%ebx
  801f2c:	89 d8                	mov    %ebx,%eax
  801f2e:	89 fa                	mov    %edi,%edx
  801f30:	83 c4 1c             	add    $0x1c,%esp
  801f33:	5b                   	pop    %ebx
  801f34:	5e                   	pop    %esi
  801f35:	5f                   	pop    %edi
  801f36:	5d                   	pop    %ebp
  801f37:	c3                   	ret    
  801f38:	90                   	nop
  801f39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f40:	39 ce                	cmp    %ecx,%esi
  801f42:	77 74                	ja     801fb8 <__udivdi3+0xd8>
  801f44:	0f bd fe             	bsr    %esi,%edi
  801f47:	83 f7 1f             	xor    $0x1f,%edi
  801f4a:	0f 84 98 00 00 00    	je     801fe8 <__udivdi3+0x108>
  801f50:	bb 20 00 00 00       	mov    $0x20,%ebx
  801f55:	89 f9                	mov    %edi,%ecx
  801f57:	89 c5                	mov    %eax,%ebp
  801f59:	29 fb                	sub    %edi,%ebx
  801f5b:	d3 e6                	shl    %cl,%esi
  801f5d:	89 d9                	mov    %ebx,%ecx
  801f5f:	d3 ed                	shr    %cl,%ebp
  801f61:	89 f9                	mov    %edi,%ecx
  801f63:	d3 e0                	shl    %cl,%eax
  801f65:	09 ee                	or     %ebp,%esi
  801f67:	89 d9                	mov    %ebx,%ecx
  801f69:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f6d:	89 d5                	mov    %edx,%ebp
  801f6f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801f73:	d3 ed                	shr    %cl,%ebp
  801f75:	89 f9                	mov    %edi,%ecx
  801f77:	d3 e2                	shl    %cl,%edx
  801f79:	89 d9                	mov    %ebx,%ecx
  801f7b:	d3 e8                	shr    %cl,%eax
  801f7d:	09 c2                	or     %eax,%edx
  801f7f:	89 d0                	mov    %edx,%eax
  801f81:	89 ea                	mov    %ebp,%edx
  801f83:	f7 f6                	div    %esi
  801f85:	89 d5                	mov    %edx,%ebp
  801f87:	89 c3                	mov    %eax,%ebx
  801f89:	f7 64 24 0c          	mull   0xc(%esp)
  801f8d:	39 d5                	cmp    %edx,%ebp
  801f8f:	72 10                	jb     801fa1 <__udivdi3+0xc1>
  801f91:	8b 74 24 08          	mov    0x8(%esp),%esi
  801f95:	89 f9                	mov    %edi,%ecx
  801f97:	d3 e6                	shl    %cl,%esi
  801f99:	39 c6                	cmp    %eax,%esi
  801f9b:	73 07                	jae    801fa4 <__udivdi3+0xc4>
  801f9d:	39 d5                	cmp    %edx,%ebp
  801f9f:	75 03                	jne    801fa4 <__udivdi3+0xc4>
  801fa1:	83 eb 01             	sub    $0x1,%ebx
  801fa4:	31 ff                	xor    %edi,%edi
  801fa6:	89 d8                	mov    %ebx,%eax
  801fa8:	89 fa                	mov    %edi,%edx
  801faa:	83 c4 1c             	add    $0x1c,%esp
  801fad:	5b                   	pop    %ebx
  801fae:	5e                   	pop    %esi
  801faf:	5f                   	pop    %edi
  801fb0:	5d                   	pop    %ebp
  801fb1:	c3                   	ret    
  801fb2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801fb8:	31 ff                	xor    %edi,%edi
  801fba:	31 db                	xor    %ebx,%ebx
  801fbc:	89 d8                	mov    %ebx,%eax
  801fbe:	89 fa                	mov    %edi,%edx
  801fc0:	83 c4 1c             	add    $0x1c,%esp
  801fc3:	5b                   	pop    %ebx
  801fc4:	5e                   	pop    %esi
  801fc5:	5f                   	pop    %edi
  801fc6:	5d                   	pop    %ebp
  801fc7:	c3                   	ret    
  801fc8:	90                   	nop
  801fc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fd0:	89 d8                	mov    %ebx,%eax
  801fd2:	f7 f7                	div    %edi
  801fd4:	31 ff                	xor    %edi,%edi
  801fd6:	89 c3                	mov    %eax,%ebx
  801fd8:	89 d8                	mov    %ebx,%eax
  801fda:	89 fa                	mov    %edi,%edx
  801fdc:	83 c4 1c             	add    $0x1c,%esp
  801fdf:	5b                   	pop    %ebx
  801fe0:	5e                   	pop    %esi
  801fe1:	5f                   	pop    %edi
  801fe2:	5d                   	pop    %ebp
  801fe3:	c3                   	ret    
  801fe4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801fe8:	39 ce                	cmp    %ecx,%esi
  801fea:	72 0c                	jb     801ff8 <__udivdi3+0x118>
  801fec:	31 db                	xor    %ebx,%ebx
  801fee:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801ff2:	0f 87 34 ff ff ff    	ja     801f2c <__udivdi3+0x4c>
  801ff8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801ffd:	e9 2a ff ff ff       	jmp    801f2c <__udivdi3+0x4c>
  802002:	66 90                	xchg   %ax,%ax
  802004:	66 90                	xchg   %ax,%ax
  802006:	66 90                	xchg   %ax,%ax
  802008:	66 90                	xchg   %ax,%ax
  80200a:	66 90                	xchg   %ax,%ax
  80200c:	66 90                	xchg   %ax,%ax
  80200e:	66 90                	xchg   %ax,%ax

00802010 <__umoddi3>:
  802010:	55                   	push   %ebp
  802011:	57                   	push   %edi
  802012:	56                   	push   %esi
  802013:	53                   	push   %ebx
  802014:	83 ec 1c             	sub    $0x1c,%esp
  802017:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80201b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80201f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802023:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802027:	85 d2                	test   %edx,%edx
  802029:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80202d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802031:	89 f3                	mov    %esi,%ebx
  802033:	89 3c 24             	mov    %edi,(%esp)
  802036:	89 74 24 04          	mov    %esi,0x4(%esp)
  80203a:	75 1c                	jne    802058 <__umoddi3+0x48>
  80203c:	39 f7                	cmp    %esi,%edi
  80203e:	76 50                	jbe    802090 <__umoddi3+0x80>
  802040:	89 c8                	mov    %ecx,%eax
  802042:	89 f2                	mov    %esi,%edx
  802044:	f7 f7                	div    %edi
  802046:	89 d0                	mov    %edx,%eax
  802048:	31 d2                	xor    %edx,%edx
  80204a:	83 c4 1c             	add    $0x1c,%esp
  80204d:	5b                   	pop    %ebx
  80204e:	5e                   	pop    %esi
  80204f:	5f                   	pop    %edi
  802050:	5d                   	pop    %ebp
  802051:	c3                   	ret    
  802052:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802058:	39 f2                	cmp    %esi,%edx
  80205a:	89 d0                	mov    %edx,%eax
  80205c:	77 52                	ja     8020b0 <__umoddi3+0xa0>
  80205e:	0f bd ea             	bsr    %edx,%ebp
  802061:	83 f5 1f             	xor    $0x1f,%ebp
  802064:	75 5a                	jne    8020c0 <__umoddi3+0xb0>
  802066:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80206a:	0f 82 e0 00 00 00    	jb     802150 <__umoddi3+0x140>
  802070:	39 0c 24             	cmp    %ecx,(%esp)
  802073:	0f 86 d7 00 00 00    	jbe    802150 <__umoddi3+0x140>
  802079:	8b 44 24 08          	mov    0x8(%esp),%eax
  80207d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802081:	83 c4 1c             	add    $0x1c,%esp
  802084:	5b                   	pop    %ebx
  802085:	5e                   	pop    %esi
  802086:	5f                   	pop    %edi
  802087:	5d                   	pop    %ebp
  802088:	c3                   	ret    
  802089:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802090:	85 ff                	test   %edi,%edi
  802092:	89 fd                	mov    %edi,%ebp
  802094:	75 0b                	jne    8020a1 <__umoddi3+0x91>
  802096:	b8 01 00 00 00       	mov    $0x1,%eax
  80209b:	31 d2                	xor    %edx,%edx
  80209d:	f7 f7                	div    %edi
  80209f:	89 c5                	mov    %eax,%ebp
  8020a1:	89 f0                	mov    %esi,%eax
  8020a3:	31 d2                	xor    %edx,%edx
  8020a5:	f7 f5                	div    %ebp
  8020a7:	89 c8                	mov    %ecx,%eax
  8020a9:	f7 f5                	div    %ebp
  8020ab:	89 d0                	mov    %edx,%eax
  8020ad:	eb 99                	jmp    802048 <__umoddi3+0x38>
  8020af:	90                   	nop
  8020b0:	89 c8                	mov    %ecx,%eax
  8020b2:	89 f2                	mov    %esi,%edx
  8020b4:	83 c4 1c             	add    $0x1c,%esp
  8020b7:	5b                   	pop    %ebx
  8020b8:	5e                   	pop    %esi
  8020b9:	5f                   	pop    %edi
  8020ba:	5d                   	pop    %ebp
  8020bb:	c3                   	ret    
  8020bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020c0:	8b 34 24             	mov    (%esp),%esi
  8020c3:	bf 20 00 00 00       	mov    $0x20,%edi
  8020c8:	89 e9                	mov    %ebp,%ecx
  8020ca:	29 ef                	sub    %ebp,%edi
  8020cc:	d3 e0                	shl    %cl,%eax
  8020ce:	89 f9                	mov    %edi,%ecx
  8020d0:	89 f2                	mov    %esi,%edx
  8020d2:	d3 ea                	shr    %cl,%edx
  8020d4:	89 e9                	mov    %ebp,%ecx
  8020d6:	09 c2                	or     %eax,%edx
  8020d8:	89 d8                	mov    %ebx,%eax
  8020da:	89 14 24             	mov    %edx,(%esp)
  8020dd:	89 f2                	mov    %esi,%edx
  8020df:	d3 e2                	shl    %cl,%edx
  8020e1:	89 f9                	mov    %edi,%ecx
  8020e3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8020e7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8020eb:	d3 e8                	shr    %cl,%eax
  8020ed:	89 e9                	mov    %ebp,%ecx
  8020ef:	89 c6                	mov    %eax,%esi
  8020f1:	d3 e3                	shl    %cl,%ebx
  8020f3:	89 f9                	mov    %edi,%ecx
  8020f5:	89 d0                	mov    %edx,%eax
  8020f7:	d3 e8                	shr    %cl,%eax
  8020f9:	89 e9                	mov    %ebp,%ecx
  8020fb:	09 d8                	or     %ebx,%eax
  8020fd:	89 d3                	mov    %edx,%ebx
  8020ff:	89 f2                	mov    %esi,%edx
  802101:	f7 34 24             	divl   (%esp)
  802104:	89 d6                	mov    %edx,%esi
  802106:	d3 e3                	shl    %cl,%ebx
  802108:	f7 64 24 04          	mull   0x4(%esp)
  80210c:	39 d6                	cmp    %edx,%esi
  80210e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802112:	89 d1                	mov    %edx,%ecx
  802114:	89 c3                	mov    %eax,%ebx
  802116:	72 08                	jb     802120 <__umoddi3+0x110>
  802118:	75 11                	jne    80212b <__umoddi3+0x11b>
  80211a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80211e:	73 0b                	jae    80212b <__umoddi3+0x11b>
  802120:	2b 44 24 04          	sub    0x4(%esp),%eax
  802124:	1b 14 24             	sbb    (%esp),%edx
  802127:	89 d1                	mov    %edx,%ecx
  802129:	89 c3                	mov    %eax,%ebx
  80212b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80212f:	29 da                	sub    %ebx,%edx
  802131:	19 ce                	sbb    %ecx,%esi
  802133:	89 f9                	mov    %edi,%ecx
  802135:	89 f0                	mov    %esi,%eax
  802137:	d3 e0                	shl    %cl,%eax
  802139:	89 e9                	mov    %ebp,%ecx
  80213b:	d3 ea                	shr    %cl,%edx
  80213d:	89 e9                	mov    %ebp,%ecx
  80213f:	d3 ee                	shr    %cl,%esi
  802141:	09 d0                	or     %edx,%eax
  802143:	89 f2                	mov    %esi,%edx
  802145:	83 c4 1c             	add    $0x1c,%esp
  802148:	5b                   	pop    %ebx
  802149:	5e                   	pop    %esi
  80214a:	5f                   	pop    %edi
  80214b:	5d                   	pop    %ebp
  80214c:	c3                   	ret    
  80214d:	8d 76 00             	lea    0x0(%esi),%esi
  802150:	29 f9                	sub    %edi,%ecx
  802152:	19 d6                	sbb    %edx,%esi
  802154:	89 74 24 04          	mov    %esi,0x4(%esp)
  802158:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80215c:	e9 18 ff ff ff       	jmp    802079 <__umoddi3+0x69>
