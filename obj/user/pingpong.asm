
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
  80003c:	e8 bc 0e 00 00       	call   800efd <fork>
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
  800054:	68 00 26 80 00       	push   $0x802600
  800059:	e8 53 01 00 00       	call   8001b1 <cprintf>
		ipc_send(who, 0, 0, 0);
  80005e:	6a 00                	push   $0x0
  800060:	6a 00                	push   $0x0
  800062:	6a 00                	push   $0x0
  800064:	ff 75 e4             	pushl  -0x1c(%ebp)
  800067:	e8 ef 0f 00 00       	call   80105b <ipc_send>
  80006c:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  80006f:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800072:	83 ec 04             	sub    $0x4,%esp
  800075:	6a 00                	push   $0x0
  800077:	6a 00                	push   $0x0
  800079:	56                   	push   %esi
  80007a:	e8 73 0f 00 00       	call   800ff2 <ipc_recv>
  80007f:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  800081:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800084:	e8 72 0a 00 00       	call   800afb <sys_getenvid>
  800089:	57                   	push   %edi
  80008a:	53                   	push   %ebx
  80008b:	50                   	push   %eax
  80008c:	68 16 26 80 00       	push   $0x802616
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
  8000a9:	e8 ad 0f 00 00       	call   80105b <ipc_send>
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
  8000db:	a3 08 40 80 00       	mov    %eax,0x804008

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
  80010a:	e8 a4 11 00 00       	call   8012b3 <close_all>
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
  800214:	e8 47 21 00 00       	call   802360 <__udivdi3>
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
  800257:	e8 34 22 00 00       	call   802490 <__umoddi3>
  80025c:	83 c4 14             	add    $0x14,%esp
  80025f:	0f be 80 33 26 80 00 	movsbl 0x802633(%eax),%eax
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
  80035b:	ff 24 85 80 27 80 00 	jmp    *0x802780(,%eax,4)
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
  80041f:	8b 14 85 e0 28 80 00 	mov    0x8028e0(,%eax,4),%edx
  800426:	85 d2                	test   %edx,%edx
  800428:	75 18                	jne    800442 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80042a:	50                   	push   %eax
  80042b:	68 4b 26 80 00       	push   $0x80264b
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
  800443:	68 ae 2a 80 00       	push   $0x802aae
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
  800467:	b8 44 26 80 00       	mov    $0x802644,%eax
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
  800ae2:	68 3f 29 80 00       	push   $0x80293f
  800ae7:	6a 23                	push   $0x23
  800ae9:	68 5c 29 80 00       	push   $0x80295c
  800aee:	e8 6f 17 00 00       	call   802262 <_panic>

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
  800b63:	68 3f 29 80 00       	push   $0x80293f
  800b68:	6a 23                	push   $0x23
  800b6a:	68 5c 29 80 00       	push   $0x80295c
  800b6f:	e8 ee 16 00 00       	call   802262 <_panic>

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
  800ba5:	68 3f 29 80 00       	push   $0x80293f
  800baa:	6a 23                	push   $0x23
  800bac:	68 5c 29 80 00       	push   $0x80295c
  800bb1:	e8 ac 16 00 00       	call   802262 <_panic>

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
  800be7:	68 3f 29 80 00       	push   $0x80293f
  800bec:	6a 23                	push   $0x23
  800bee:	68 5c 29 80 00       	push   $0x80295c
  800bf3:	e8 6a 16 00 00       	call   802262 <_panic>

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
  800c29:	68 3f 29 80 00       	push   $0x80293f
  800c2e:	6a 23                	push   $0x23
  800c30:	68 5c 29 80 00       	push   $0x80295c
  800c35:	e8 28 16 00 00       	call   802262 <_panic>

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
  800c6b:	68 3f 29 80 00       	push   $0x80293f
  800c70:	6a 23                	push   $0x23
  800c72:	68 5c 29 80 00       	push   $0x80295c
  800c77:	e8 e6 15 00 00       	call   802262 <_panic>

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
  800cad:	68 3f 29 80 00       	push   $0x80293f
  800cb2:	6a 23                	push   $0x23
  800cb4:	68 5c 29 80 00       	push   $0x80295c
  800cb9:	e8 a4 15 00 00       	call   802262 <_panic>

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
  800d11:	68 3f 29 80 00       	push   $0x80293f
  800d16:	6a 23                	push   $0x23
  800d18:	68 5c 29 80 00       	push   $0x80295c
  800d1d:	e8 40 15 00 00       	call   802262 <_panic>

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

00800d2a <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d2a:	55                   	push   %ebp
  800d2b:	89 e5                	mov    %esp,%ebp
  800d2d:	57                   	push   %edi
  800d2e:	56                   	push   %esi
  800d2f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d30:	ba 00 00 00 00       	mov    $0x0,%edx
  800d35:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d3a:	89 d1                	mov    %edx,%ecx
  800d3c:	89 d3                	mov    %edx,%ebx
  800d3e:	89 d7                	mov    %edx,%edi
  800d40:	89 d6                	mov    %edx,%esi
  800d42:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d44:	5b                   	pop    %ebx
  800d45:	5e                   	pop    %esi
  800d46:	5f                   	pop    %edi
  800d47:	5d                   	pop    %ebp
  800d48:	c3                   	ret    

00800d49 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800d49:	55                   	push   %ebp
  800d4a:	89 e5                	mov    %esp,%ebp
  800d4c:	53                   	push   %ebx
  800d4d:	83 ec 04             	sub    $0x4,%esp
	int r;
	void * address = (void *)(pn*PGSIZE);
  800d50:	89 d3                	mov    %edx,%ebx
  800d52:	c1 e3 0c             	shl    $0xc,%ebx
	
	if((uvpt[pn] & PTE_SHARE))
  800d55:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800d5c:	f6 c5 04             	test   $0x4,%ch
  800d5f:	74 38                	je     800d99 <duppage+0x50>
	{
		if ((r = sys_page_map(0, address, envid, address, (uvpt[pn] | PTE_SYSCALL))) < 0)
  800d61:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d68:	83 ec 0c             	sub    $0xc,%esp
  800d6b:	81 ca 07 0e 00 00    	or     $0xe07,%edx
  800d71:	52                   	push   %edx
  800d72:	53                   	push   %ebx
  800d73:	50                   	push   %eax
  800d74:	53                   	push   %ebx
  800d75:	6a 00                	push   $0x0
  800d77:	e8 00 fe ff ff       	call   800b7c <sys_page_map>
  800d7c:	83 c4 20             	add    $0x20,%esp
  800d7f:	85 c0                	test   %eax,%eax
  800d81:	0f 89 b8 00 00 00    	jns    800e3f <duppage+0xf6>
			panic("sys_page_map: %e", r);
  800d87:	50                   	push   %eax
  800d88:	68 6a 29 80 00       	push   $0x80296a
  800d8d:	6a 4e                	push   $0x4e
  800d8f:	68 7b 29 80 00       	push   $0x80297b
  800d94:	e8 c9 14 00 00       	call   802262 <_panic>
	}
	else if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW))
  800d99:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800da0:	f6 c1 02             	test   $0x2,%cl
  800da3:	75 0c                	jne    800db1 <duppage+0x68>
  800da5:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800dac:	f6 c5 08             	test   $0x8,%ch
  800daf:	74 57                	je     800e08 <duppage+0xbf>
	{
		int perm = 0;
		perm |= PTE_P|PTE_U|PTE_COW;
	
		if ((r = sys_page_map(0, address, envid, address, perm)) < 0)
  800db1:	83 ec 0c             	sub    $0xc,%esp
  800db4:	68 05 08 00 00       	push   $0x805
  800db9:	53                   	push   %ebx
  800dba:	50                   	push   %eax
  800dbb:	53                   	push   %ebx
  800dbc:	6a 00                	push   $0x0
  800dbe:	e8 b9 fd ff ff       	call   800b7c <sys_page_map>
  800dc3:	83 c4 20             	add    $0x20,%esp
  800dc6:	85 c0                	test   %eax,%eax
  800dc8:	79 12                	jns    800ddc <duppage+0x93>
			panic("sys_page_map: %e", r);
  800dca:	50                   	push   %eax
  800dcb:	68 6a 29 80 00       	push   $0x80296a
  800dd0:	6a 56                	push   $0x56
  800dd2:	68 7b 29 80 00       	push   $0x80297b
  800dd7:	e8 86 14 00 00       	call   802262 <_panic>
		if ((r = sys_page_map(0, address, 0, address, perm)) < 0)
  800ddc:	83 ec 0c             	sub    $0xc,%esp
  800ddf:	68 05 08 00 00       	push   $0x805
  800de4:	53                   	push   %ebx
  800de5:	6a 00                	push   $0x0
  800de7:	53                   	push   %ebx
  800de8:	6a 00                	push   $0x0
  800dea:	e8 8d fd ff ff       	call   800b7c <sys_page_map>
  800def:	83 c4 20             	add    $0x20,%esp
  800df2:	85 c0                	test   %eax,%eax
  800df4:	79 49                	jns    800e3f <duppage+0xf6>
			panic("sys_page_map: %e", r);
  800df6:	50                   	push   %eax
  800df7:	68 6a 29 80 00       	push   $0x80296a
  800dfc:	6a 58                	push   $0x58
  800dfe:	68 7b 29 80 00       	push   $0x80297b
  800e03:	e8 5a 14 00 00       	call   802262 <_panic>
	}
	else if((uvpt[pn] & ~PTE_U) == 0)
  800e08:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e0f:	f7 c2 fb ff ff ff    	test   $0xfffffffb,%edx
  800e15:	75 28                	jne    800e3f <duppage+0xf6>
	{
		//cprintf("im here");
		if ((r = sys_page_map(0, address, envid, address, PTE_P|PTE_U)) < 0)
  800e17:	83 ec 0c             	sub    $0xc,%esp
  800e1a:	6a 05                	push   $0x5
  800e1c:	53                   	push   %ebx
  800e1d:	50                   	push   %eax
  800e1e:	53                   	push   %ebx
  800e1f:	6a 00                	push   $0x0
  800e21:	e8 56 fd ff ff       	call   800b7c <sys_page_map>
  800e26:	83 c4 20             	add    $0x20,%esp
  800e29:	85 c0                	test   %eax,%eax
  800e2b:	79 12                	jns    800e3f <duppage+0xf6>
			panic("sys_page_map: %e", r);	
  800e2d:	50                   	push   %eax
  800e2e:	68 6a 29 80 00       	push   $0x80296a
  800e33:	6a 5e                	push   $0x5e
  800e35:	68 7b 29 80 00       	push   $0x80297b
  800e3a:	e8 23 14 00 00       	call   802262 <_panic>
	}
	return 0;
}
  800e3f:	b8 00 00 00 00       	mov    $0x0,%eax
  800e44:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e47:	c9                   	leave  
  800e48:	c3                   	ret    

00800e49 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e49:	55                   	push   %ebp
  800e4a:	89 e5                	mov    %esp,%ebp
  800e4c:	53                   	push   %ebx
  800e4d:	83 ec 08             	sub    $0x8,%esp
	void *addr = (void *) utf->utf_fault_va;
  800e50:	8b 45 08             	mov    0x8(%ebp),%eax
  800e53:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	unsigned pn = ((uint32_t)addr)/PGSIZE;
  800e55:	89 d8                	mov    %ebx,%eax
  800e57:	c1 e8 0c             	shr    $0xc,%eax
	pte_t pte = uvpt[pn];
  800e5a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// Allocate a new page, mapped at temp location
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  800e61:	6a 07                	push   $0x7
  800e63:	68 00 f0 7f 00       	push   $0x7ff000
  800e68:	6a 00                	push   $0x0
  800e6a:	e8 ca fc ff ff       	call   800b39 <sys_page_alloc>
  800e6f:	83 c4 10             	add    $0x10,%esp
  800e72:	85 c0                	test   %eax,%eax
  800e74:	79 12                	jns    800e88 <pgfault+0x3f>
		panic("sys_page_alloc: %e", r);
  800e76:	50                   	push   %eax
  800e77:	68 86 29 80 00       	push   $0x802986
  800e7c:	6a 2b                	push   $0x2b
  800e7e:	68 7b 29 80 00       	push   $0x80297b
  800e83:	e8 da 13 00 00       	call   802262 <_panic>

	// Copy the data from the old page to this new page
	void *addr_pgstart = (void *) ROUNDDOWN(addr, PGSIZE);
  800e88:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr_pgstart, PGSIZE);
  800e8e:	83 ec 04             	sub    $0x4,%esp
  800e91:	68 00 10 00 00       	push   $0x1000
  800e96:	53                   	push   %ebx
  800e97:	68 00 f0 7f 00       	push   $0x7ff000
  800e9c:	e8 27 fa ff ff       	call   8008c8 <memmove>

	// Move the new page to the old page's address
	if ((r = sys_page_map(0, PFTEMP, 0, addr_pgstart, PTE_P|PTE_U|PTE_W)) < 0)
  800ea1:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800ea8:	53                   	push   %ebx
  800ea9:	6a 00                	push   $0x0
  800eab:	68 00 f0 7f 00       	push   $0x7ff000
  800eb0:	6a 00                	push   $0x0
  800eb2:	e8 c5 fc ff ff       	call   800b7c <sys_page_map>
  800eb7:	83 c4 20             	add    $0x20,%esp
  800eba:	85 c0                	test   %eax,%eax
  800ebc:	79 12                	jns    800ed0 <pgfault+0x87>
		panic("sys_page_map: %e", r);
  800ebe:	50                   	push   %eax
  800ebf:	68 6a 29 80 00       	push   $0x80296a
  800ec4:	6a 33                	push   $0x33
  800ec6:	68 7b 29 80 00       	push   $0x80297b
  800ecb:	e8 92 13 00 00       	call   802262 <_panic>

	// Unmap the temp location
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800ed0:	83 ec 08             	sub    $0x8,%esp
  800ed3:	68 00 f0 7f 00       	push   $0x7ff000
  800ed8:	6a 00                	push   $0x0
  800eda:	e8 df fc ff ff       	call   800bbe <sys_page_unmap>
  800edf:	83 c4 10             	add    $0x10,%esp
  800ee2:	85 c0                	test   %eax,%eax
  800ee4:	79 12                	jns    800ef8 <pgfault+0xaf>
		panic("sys_page_unmap: %e", r);
  800ee6:	50                   	push   %eax
  800ee7:	68 99 29 80 00       	push   $0x802999
  800eec:	6a 37                	push   $0x37
  800eee:	68 7b 29 80 00       	push   $0x80297b
  800ef3:	e8 6a 13 00 00       	call   802262 <_panic>
}
  800ef8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800efb:	c9                   	leave  
  800efc:	c3                   	ret    

00800efd <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800efd:	55                   	push   %ebp
  800efe:	89 e5                	mov    %esp,%ebp
  800f00:	56                   	push   %esi
  800f01:	53                   	push   %ebx
  800f02:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
	// Set up page fault handler
	set_pgfault_handler(&pgfault);
  800f05:	68 49 0e 80 00       	push   $0x800e49
  800f0a:	e8 99 13 00 00       	call   8022a8 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f0f:	b8 07 00 00 00       	mov    $0x7,%eax
  800f14:	cd 30                	int    $0x30

	// Create child
	envid_t envid = sys_exofork();
  800f16:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (envid < 0) {
  800f19:	83 c4 10             	add    $0x10,%esp
  800f1c:	85 c0                	test   %eax,%eax
  800f1e:	79 12                	jns    800f32 <fork+0x35>
		panic("sys_exofork: %e", envid);
  800f20:	50                   	push   %eax
  800f21:	68 ac 29 80 00       	push   $0x8029ac
  800f26:	6a 7c                	push   $0x7c
  800f28:	68 7b 29 80 00       	push   $0x80297b
  800f2d:	e8 30 13 00 00       	call   802262 <_panic>
		return envid;
	}
	if (envid == 0) {
  800f32:	85 c0                	test   %eax,%eax
  800f34:	75 1e                	jne    800f54 <fork+0x57>
		// We are the child.
		thisenv = &envs[ENVX(sys_getenvid())]; // Fix thisenv
  800f36:	e8 c0 fb ff ff       	call   800afb <sys_getenvid>
  800f3b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f40:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f43:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f48:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  800f4d:	b8 00 00 00 00       	mov    $0x0,%eax
  800f52:	eb 7d                	jmp    800fd1 <fork+0xd4>

	// Set page fault handler on the child.
	// The parent needs to do it, else the child wouldn't be able to handle
	// the fault when trying to access it's stack (which happens as soon it starts)
	extern void _pgfault_upcall(void);
	sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);
  800f54:	83 ec 04             	sub    $0x4,%esp
  800f57:	6a 07                	push   $0x7
  800f59:	68 00 f0 bf ee       	push   $0xeebff000
  800f5e:	50                   	push   %eax
  800f5f:	e8 d5 fb ff ff       	call   800b39 <sys_page_alloc>
	sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  800f64:	83 c4 08             	add    $0x8,%esp
  800f67:	68 ed 22 80 00       	push   $0x8022ed
  800f6c:	ff 75 f4             	pushl  -0xc(%ebp)
  800f6f:	e8 10 fd ff ff       	call   800c84 <sys_env_set_pgfault_upcall>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  800f74:	be 04 70 80 00       	mov    $0x807004,%esi
  800f79:	c1 ee 0c             	shr    $0xc,%esi
  800f7c:	83 c4 10             	add    $0x10,%esp
  800f7f:	bb 00 08 00 00       	mov    $0x800,%ebx
  800f84:	eb 0d                	jmp    800f93 <fork+0x96>
		duppage(envid, pn);
  800f86:	89 da                	mov    %ebx,%edx
  800f88:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f8b:	e8 b9 fd ff ff       	call   800d49 <duppage>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  800f90:	83 c3 01             	add    $0x1,%ebx
  800f93:	39 f3                	cmp    %esi,%ebx
  800f95:	76 ef                	jbe    800f86 <fork+0x89>
	}

	// Also copy the stack we are currently running on
	// I think it should loop from ustacktop to this page, since the stack
	// can have more than 1 page
	duppage(envid, ((uint32_t) &envid)/PGSIZE);
  800f97:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800f9a:	c1 ea 0c             	shr    $0xc,%edx
  800f9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fa0:	e8 a4 fd ff ff       	call   800d49 <duppage>

	// Start the child environmnet running
	int r;
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  800fa5:	83 ec 08             	sub    $0x8,%esp
  800fa8:	6a 02                	push   $0x2
  800faa:	ff 75 f4             	pushl  -0xc(%ebp)
  800fad:	e8 4e fc ff ff       	call   800c00 <sys_env_set_status>
  800fb2:	83 c4 10             	add    $0x10,%esp
  800fb5:	85 c0                	test   %eax,%eax
  800fb7:	79 15                	jns    800fce <fork+0xd1>
		panic("sys_env_set_status: %e", r);
  800fb9:	50                   	push   %eax
  800fba:	68 bc 29 80 00       	push   $0x8029bc
  800fbf:	68 9c 00 00 00       	push   $0x9c
  800fc4:	68 7b 29 80 00       	push   $0x80297b
  800fc9:	e8 94 12 00 00       	call   802262 <_panic>
		return r;
	}

	return envid;
  800fce:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800fd1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fd4:	5b                   	pop    %ebx
  800fd5:	5e                   	pop    %esi
  800fd6:	5d                   	pop    %ebp
  800fd7:	c3                   	ret    

00800fd8 <sfork>:

// Challenge!
int
sfork(void)
{
  800fd8:	55                   	push   %ebp
  800fd9:	89 e5                	mov    %esp,%ebp
  800fdb:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800fde:	68 d3 29 80 00       	push   $0x8029d3
  800fe3:	68 a7 00 00 00       	push   $0xa7
  800fe8:	68 7b 29 80 00       	push   $0x80297b
  800fed:	e8 70 12 00 00       	call   802262 <_panic>

00800ff2 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800ff2:	55                   	push   %ebp
  800ff3:	89 e5                	mov    %esp,%ebp
  800ff5:	56                   	push   %esi
  800ff6:	53                   	push   %ebx
  800ff7:	8b 75 08             	mov    0x8(%ebp),%esi
  800ffa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ffd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  801000:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801002:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801007:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  80100a:	83 ec 0c             	sub    $0xc,%esp
  80100d:	50                   	push   %eax
  80100e:	e8 d6 fc ff ff       	call   800ce9 <sys_ipc_recv>

	if (r < 0) {
  801013:	83 c4 10             	add    $0x10,%esp
  801016:	85 c0                	test   %eax,%eax
  801018:	79 16                	jns    801030 <ipc_recv+0x3e>
		if (from_env_store)
  80101a:	85 f6                	test   %esi,%esi
  80101c:	74 06                	je     801024 <ipc_recv+0x32>
			*from_env_store = 0;
  80101e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  801024:	85 db                	test   %ebx,%ebx
  801026:	74 2c                	je     801054 <ipc_recv+0x62>
			*perm_store = 0;
  801028:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80102e:	eb 24                	jmp    801054 <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  801030:	85 f6                	test   %esi,%esi
  801032:	74 0a                	je     80103e <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  801034:	a1 08 40 80 00       	mov    0x804008,%eax
  801039:	8b 40 74             	mov    0x74(%eax),%eax
  80103c:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  80103e:	85 db                	test   %ebx,%ebx
  801040:	74 0a                	je     80104c <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  801042:	a1 08 40 80 00       	mov    0x804008,%eax
  801047:	8b 40 78             	mov    0x78(%eax),%eax
  80104a:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  80104c:	a1 08 40 80 00       	mov    0x804008,%eax
  801051:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  801054:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801057:	5b                   	pop    %ebx
  801058:	5e                   	pop    %esi
  801059:	5d                   	pop    %ebp
  80105a:	c3                   	ret    

0080105b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80105b:	55                   	push   %ebp
  80105c:	89 e5                	mov    %esp,%ebp
  80105e:	57                   	push   %edi
  80105f:	56                   	push   %esi
  801060:	53                   	push   %ebx
  801061:	83 ec 0c             	sub    $0xc,%esp
  801064:	8b 7d 08             	mov    0x8(%ebp),%edi
  801067:	8b 75 0c             	mov    0xc(%ebp),%esi
  80106a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  80106d:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  80106f:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801074:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  801077:	ff 75 14             	pushl  0x14(%ebp)
  80107a:	53                   	push   %ebx
  80107b:	56                   	push   %esi
  80107c:	57                   	push   %edi
  80107d:	e8 44 fc ff ff       	call   800cc6 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  801082:	83 c4 10             	add    $0x10,%esp
  801085:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801088:	75 07                	jne    801091 <ipc_send+0x36>
			sys_yield();
  80108a:	e8 8b fa ff ff       	call   800b1a <sys_yield>
  80108f:	eb e6                	jmp    801077 <ipc_send+0x1c>
		} else if (r < 0) {
  801091:	85 c0                	test   %eax,%eax
  801093:	79 12                	jns    8010a7 <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  801095:	50                   	push   %eax
  801096:	68 e9 29 80 00       	push   $0x8029e9
  80109b:	6a 51                	push   $0x51
  80109d:	68 f6 29 80 00       	push   $0x8029f6
  8010a2:	e8 bb 11 00 00       	call   802262 <_panic>
		}
	}
}
  8010a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010aa:	5b                   	pop    %ebx
  8010ab:	5e                   	pop    %esi
  8010ac:	5f                   	pop    %edi
  8010ad:	5d                   	pop    %ebp
  8010ae:	c3                   	ret    

008010af <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8010af:	55                   	push   %ebp
  8010b0:	89 e5                	mov    %esp,%ebp
  8010b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8010b5:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8010ba:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8010bd:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8010c3:	8b 52 50             	mov    0x50(%edx),%edx
  8010c6:	39 ca                	cmp    %ecx,%edx
  8010c8:	75 0d                	jne    8010d7 <ipc_find_env+0x28>
			return envs[i].env_id;
  8010ca:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8010cd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010d2:	8b 40 48             	mov    0x48(%eax),%eax
  8010d5:	eb 0f                	jmp    8010e6 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8010d7:	83 c0 01             	add    $0x1,%eax
  8010da:	3d 00 04 00 00       	cmp    $0x400,%eax
  8010df:	75 d9                	jne    8010ba <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8010e1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8010e6:	5d                   	pop    %ebp
  8010e7:	c3                   	ret    

008010e8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010e8:	55                   	push   %ebp
  8010e9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ee:	05 00 00 00 30       	add    $0x30000000,%eax
  8010f3:	c1 e8 0c             	shr    $0xc,%eax
}
  8010f6:	5d                   	pop    %ebp
  8010f7:	c3                   	ret    

008010f8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010f8:	55                   	push   %ebp
  8010f9:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8010fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8010fe:	05 00 00 00 30       	add    $0x30000000,%eax
  801103:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801108:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80110d:	5d                   	pop    %ebp
  80110e:	c3                   	ret    

0080110f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80110f:	55                   	push   %ebp
  801110:	89 e5                	mov    %esp,%ebp
  801112:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801115:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80111a:	89 c2                	mov    %eax,%edx
  80111c:	c1 ea 16             	shr    $0x16,%edx
  80111f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801126:	f6 c2 01             	test   $0x1,%dl
  801129:	74 11                	je     80113c <fd_alloc+0x2d>
  80112b:	89 c2                	mov    %eax,%edx
  80112d:	c1 ea 0c             	shr    $0xc,%edx
  801130:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801137:	f6 c2 01             	test   $0x1,%dl
  80113a:	75 09                	jne    801145 <fd_alloc+0x36>
			*fd_store = fd;
  80113c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80113e:	b8 00 00 00 00       	mov    $0x0,%eax
  801143:	eb 17                	jmp    80115c <fd_alloc+0x4d>
  801145:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80114a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80114f:	75 c9                	jne    80111a <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801151:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801157:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80115c:	5d                   	pop    %ebp
  80115d:	c3                   	ret    

0080115e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80115e:	55                   	push   %ebp
  80115f:	89 e5                	mov    %esp,%ebp
  801161:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801164:	83 f8 1f             	cmp    $0x1f,%eax
  801167:	77 36                	ja     80119f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801169:	c1 e0 0c             	shl    $0xc,%eax
  80116c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801171:	89 c2                	mov    %eax,%edx
  801173:	c1 ea 16             	shr    $0x16,%edx
  801176:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80117d:	f6 c2 01             	test   $0x1,%dl
  801180:	74 24                	je     8011a6 <fd_lookup+0x48>
  801182:	89 c2                	mov    %eax,%edx
  801184:	c1 ea 0c             	shr    $0xc,%edx
  801187:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80118e:	f6 c2 01             	test   $0x1,%dl
  801191:	74 1a                	je     8011ad <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801193:	8b 55 0c             	mov    0xc(%ebp),%edx
  801196:	89 02                	mov    %eax,(%edx)
	return 0;
  801198:	b8 00 00 00 00       	mov    $0x0,%eax
  80119d:	eb 13                	jmp    8011b2 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80119f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011a4:	eb 0c                	jmp    8011b2 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011a6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011ab:	eb 05                	jmp    8011b2 <fd_lookup+0x54>
  8011ad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8011b2:	5d                   	pop    %ebp
  8011b3:	c3                   	ret    

008011b4 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011b4:	55                   	push   %ebp
  8011b5:	89 e5                	mov    %esp,%ebp
  8011b7:	83 ec 08             	sub    $0x8,%esp
  8011ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011bd:	ba 7c 2a 80 00       	mov    $0x802a7c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8011c2:	eb 13                	jmp    8011d7 <dev_lookup+0x23>
  8011c4:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8011c7:	39 08                	cmp    %ecx,(%eax)
  8011c9:	75 0c                	jne    8011d7 <dev_lookup+0x23>
			*dev = devtab[i];
  8011cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011ce:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8011d5:	eb 2e                	jmp    801205 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011d7:	8b 02                	mov    (%edx),%eax
  8011d9:	85 c0                	test   %eax,%eax
  8011db:	75 e7                	jne    8011c4 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011dd:	a1 08 40 80 00       	mov    0x804008,%eax
  8011e2:	8b 40 48             	mov    0x48(%eax),%eax
  8011e5:	83 ec 04             	sub    $0x4,%esp
  8011e8:	51                   	push   %ecx
  8011e9:	50                   	push   %eax
  8011ea:	68 00 2a 80 00       	push   $0x802a00
  8011ef:	e8 bd ef ff ff       	call   8001b1 <cprintf>
	*dev = 0;
  8011f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011f7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8011fd:	83 c4 10             	add    $0x10,%esp
  801200:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801205:	c9                   	leave  
  801206:	c3                   	ret    

00801207 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801207:	55                   	push   %ebp
  801208:	89 e5                	mov    %esp,%ebp
  80120a:	56                   	push   %esi
  80120b:	53                   	push   %ebx
  80120c:	83 ec 10             	sub    $0x10,%esp
  80120f:	8b 75 08             	mov    0x8(%ebp),%esi
  801212:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801215:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801218:	50                   	push   %eax
  801219:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80121f:	c1 e8 0c             	shr    $0xc,%eax
  801222:	50                   	push   %eax
  801223:	e8 36 ff ff ff       	call   80115e <fd_lookup>
  801228:	83 c4 08             	add    $0x8,%esp
  80122b:	85 c0                	test   %eax,%eax
  80122d:	78 05                	js     801234 <fd_close+0x2d>
	    || fd != fd2)
  80122f:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801232:	74 0c                	je     801240 <fd_close+0x39>
		return (must_exist ? r : 0);
  801234:	84 db                	test   %bl,%bl
  801236:	ba 00 00 00 00       	mov    $0x0,%edx
  80123b:	0f 44 c2             	cmove  %edx,%eax
  80123e:	eb 41                	jmp    801281 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801240:	83 ec 08             	sub    $0x8,%esp
  801243:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801246:	50                   	push   %eax
  801247:	ff 36                	pushl  (%esi)
  801249:	e8 66 ff ff ff       	call   8011b4 <dev_lookup>
  80124e:	89 c3                	mov    %eax,%ebx
  801250:	83 c4 10             	add    $0x10,%esp
  801253:	85 c0                	test   %eax,%eax
  801255:	78 1a                	js     801271 <fd_close+0x6a>
		if (dev->dev_close)
  801257:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80125a:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80125d:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801262:	85 c0                	test   %eax,%eax
  801264:	74 0b                	je     801271 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801266:	83 ec 0c             	sub    $0xc,%esp
  801269:	56                   	push   %esi
  80126a:	ff d0                	call   *%eax
  80126c:	89 c3                	mov    %eax,%ebx
  80126e:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801271:	83 ec 08             	sub    $0x8,%esp
  801274:	56                   	push   %esi
  801275:	6a 00                	push   $0x0
  801277:	e8 42 f9 ff ff       	call   800bbe <sys_page_unmap>
	return r;
  80127c:	83 c4 10             	add    $0x10,%esp
  80127f:	89 d8                	mov    %ebx,%eax
}
  801281:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801284:	5b                   	pop    %ebx
  801285:	5e                   	pop    %esi
  801286:	5d                   	pop    %ebp
  801287:	c3                   	ret    

00801288 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801288:	55                   	push   %ebp
  801289:	89 e5                	mov    %esp,%ebp
  80128b:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80128e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801291:	50                   	push   %eax
  801292:	ff 75 08             	pushl  0x8(%ebp)
  801295:	e8 c4 fe ff ff       	call   80115e <fd_lookup>
  80129a:	83 c4 08             	add    $0x8,%esp
  80129d:	85 c0                	test   %eax,%eax
  80129f:	78 10                	js     8012b1 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8012a1:	83 ec 08             	sub    $0x8,%esp
  8012a4:	6a 01                	push   $0x1
  8012a6:	ff 75 f4             	pushl  -0xc(%ebp)
  8012a9:	e8 59 ff ff ff       	call   801207 <fd_close>
  8012ae:	83 c4 10             	add    $0x10,%esp
}
  8012b1:	c9                   	leave  
  8012b2:	c3                   	ret    

008012b3 <close_all>:

void
close_all(void)
{
  8012b3:	55                   	push   %ebp
  8012b4:	89 e5                	mov    %esp,%ebp
  8012b6:	53                   	push   %ebx
  8012b7:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012ba:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012bf:	83 ec 0c             	sub    $0xc,%esp
  8012c2:	53                   	push   %ebx
  8012c3:	e8 c0 ff ff ff       	call   801288 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8012c8:	83 c3 01             	add    $0x1,%ebx
  8012cb:	83 c4 10             	add    $0x10,%esp
  8012ce:	83 fb 20             	cmp    $0x20,%ebx
  8012d1:	75 ec                	jne    8012bf <close_all+0xc>
		close(i);
}
  8012d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012d6:	c9                   	leave  
  8012d7:	c3                   	ret    

008012d8 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012d8:	55                   	push   %ebp
  8012d9:	89 e5                	mov    %esp,%ebp
  8012db:	57                   	push   %edi
  8012dc:	56                   	push   %esi
  8012dd:	53                   	push   %ebx
  8012de:	83 ec 2c             	sub    $0x2c,%esp
  8012e1:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012e4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012e7:	50                   	push   %eax
  8012e8:	ff 75 08             	pushl  0x8(%ebp)
  8012eb:	e8 6e fe ff ff       	call   80115e <fd_lookup>
  8012f0:	83 c4 08             	add    $0x8,%esp
  8012f3:	85 c0                	test   %eax,%eax
  8012f5:	0f 88 c1 00 00 00    	js     8013bc <dup+0xe4>
		return r;
	close(newfdnum);
  8012fb:	83 ec 0c             	sub    $0xc,%esp
  8012fe:	56                   	push   %esi
  8012ff:	e8 84 ff ff ff       	call   801288 <close>

	newfd = INDEX2FD(newfdnum);
  801304:	89 f3                	mov    %esi,%ebx
  801306:	c1 e3 0c             	shl    $0xc,%ebx
  801309:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80130f:	83 c4 04             	add    $0x4,%esp
  801312:	ff 75 e4             	pushl  -0x1c(%ebp)
  801315:	e8 de fd ff ff       	call   8010f8 <fd2data>
  80131a:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80131c:	89 1c 24             	mov    %ebx,(%esp)
  80131f:	e8 d4 fd ff ff       	call   8010f8 <fd2data>
  801324:	83 c4 10             	add    $0x10,%esp
  801327:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80132a:	89 f8                	mov    %edi,%eax
  80132c:	c1 e8 16             	shr    $0x16,%eax
  80132f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801336:	a8 01                	test   $0x1,%al
  801338:	74 37                	je     801371 <dup+0x99>
  80133a:	89 f8                	mov    %edi,%eax
  80133c:	c1 e8 0c             	shr    $0xc,%eax
  80133f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801346:	f6 c2 01             	test   $0x1,%dl
  801349:	74 26                	je     801371 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80134b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801352:	83 ec 0c             	sub    $0xc,%esp
  801355:	25 07 0e 00 00       	and    $0xe07,%eax
  80135a:	50                   	push   %eax
  80135b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80135e:	6a 00                	push   $0x0
  801360:	57                   	push   %edi
  801361:	6a 00                	push   $0x0
  801363:	e8 14 f8 ff ff       	call   800b7c <sys_page_map>
  801368:	89 c7                	mov    %eax,%edi
  80136a:	83 c4 20             	add    $0x20,%esp
  80136d:	85 c0                	test   %eax,%eax
  80136f:	78 2e                	js     80139f <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801371:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801374:	89 d0                	mov    %edx,%eax
  801376:	c1 e8 0c             	shr    $0xc,%eax
  801379:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801380:	83 ec 0c             	sub    $0xc,%esp
  801383:	25 07 0e 00 00       	and    $0xe07,%eax
  801388:	50                   	push   %eax
  801389:	53                   	push   %ebx
  80138a:	6a 00                	push   $0x0
  80138c:	52                   	push   %edx
  80138d:	6a 00                	push   $0x0
  80138f:	e8 e8 f7 ff ff       	call   800b7c <sys_page_map>
  801394:	89 c7                	mov    %eax,%edi
  801396:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801399:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80139b:	85 ff                	test   %edi,%edi
  80139d:	79 1d                	jns    8013bc <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80139f:	83 ec 08             	sub    $0x8,%esp
  8013a2:	53                   	push   %ebx
  8013a3:	6a 00                	push   $0x0
  8013a5:	e8 14 f8 ff ff       	call   800bbe <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013aa:	83 c4 08             	add    $0x8,%esp
  8013ad:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013b0:	6a 00                	push   $0x0
  8013b2:	e8 07 f8 ff ff       	call   800bbe <sys_page_unmap>
	return r;
  8013b7:	83 c4 10             	add    $0x10,%esp
  8013ba:	89 f8                	mov    %edi,%eax
}
  8013bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013bf:	5b                   	pop    %ebx
  8013c0:	5e                   	pop    %esi
  8013c1:	5f                   	pop    %edi
  8013c2:	5d                   	pop    %ebp
  8013c3:	c3                   	ret    

008013c4 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013c4:	55                   	push   %ebp
  8013c5:	89 e5                	mov    %esp,%ebp
  8013c7:	53                   	push   %ebx
  8013c8:	83 ec 14             	sub    $0x14,%esp
  8013cb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013ce:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013d1:	50                   	push   %eax
  8013d2:	53                   	push   %ebx
  8013d3:	e8 86 fd ff ff       	call   80115e <fd_lookup>
  8013d8:	83 c4 08             	add    $0x8,%esp
  8013db:	89 c2                	mov    %eax,%edx
  8013dd:	85 c0                	test   %eax,%eax
  8013df:	78 6d                	js     80144e <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013e1:	83 ec 08             	sub    $0x8,%esp
  8013e4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013e7:	50                   	push   %eax
  8013e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013eb:	ff 30                	pushl  (%eax)
  8013ed:	e8 c2 fd ff ff       	call   8011b4 <dev_lookup>
  8013f2:	83 c4 10             	add    $0x10,%esp
  8013f5:	85 c0                	test   %eax,%eax
  8013f7:	78 4c                	js     801445 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013f9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013fc:	8b 42 08             	mov    0x8(%edx),%eax
  8013ff:	83 e0 03             	and    $0x3,%eax
  801402:	83 f8 01             	cmp    $0x1,%eax
  801405:	75 21                	jne    801428 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801407:	a1 08 40 80 00       	mov    0x804008,%eax
  80140c:	8b 40 48             	mov    0x48(%eax),%eax
  80140f:	83 ec 04             	sub    $0x4,%esp
  801412:	53                   	push   %ebx
  801413:	50                   	push   %eax
  801414:	68 41 2a 80 00       	push   $0x802a41
  801419:	e8 93 ed ff ff       	call   8001b1 <cprintf>
		return -E_INVAL;
  80141e:	83 c4 10             	add    $0x10,%esp
  801421:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801426:	eb 26                	jmp    80144e <read+0x8a>
	}
	if (!dev->dev_read)
  801428:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80142b:	8b 40 08             	mov    0x8(%eax),%eax
  80142e:	85 c0                	test   %eax,%eax
  801430:	74 17                	je     801449 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801432:	83 ec 04             	sub    $0x4,%esp
  801435:	ff 75 10             	pushl  0x10(%ebp)
  801438:	ff 75 0c             	pushl  0xc(%ebp)
  80143b:	52                   	push   %edx
  80143c:	ff d0                	call   *%eax
  80143e:	89 c2                	mov    %eax,%edx
  801440:	83 c4 10             	add    $0x10,%esp
  801443:	eb 09                	jmp    80144e <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801445:	89 c2                	mov    %eax,%edx
  801447:	eb 05                	jmp    80144e <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801449:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80144e:	89 d0                	mov    %edx,%eax
  801450:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801453:	c9                   	leave  
  801454:	c3                   	ret    

00801455 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801455:	55                   	push   %ebp
  801456:	89 e5                	mov    %esp,%ebp
  801458:	57                   	push   %edi
  801459:	56                   	push   %esi
  80145a:	53                   	push   %ebx
  80145b:	83 ec 0c             	sub    $0xc,%esp
  80145e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801461:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801464:	bb 00 00 00 00       	mov    $0x0,%ebx
  801469:	eb 21                	jmp    80148c <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80146b:	83 ec 04             	sub    $0x4,%esp
  80146e:	89 f0                	mov    %esi,%eax
  801470:	29 d8                	sub    %ebx,%eax
  801472:	50                   	push   %eax
  801473:	89 d8                	mov    %ebx,%eax
  801475:	03 45 0c             	add    0xc(%ebp),%eax
  801478:	50                   	push   %eax
  801479:	57                   	push   %edi
  80147a:	e8 45 ff ff ff       	call   8013c4 <read>
		if (m < 0)
  80147f:	83 c4 10             	add    $0x10,%esp
  801482:	85 c0                	test   %eax,%eax
  801484:	78 10                	js     801496 <readn+0x41>
			return m;
		if (m == 0)
  801486:	85 c0                	test   %eax,%eax
  801488:	74 0a                	je     801494 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80148a:	01 c3                	add    %eax,%ebx
  80148c:	39 f3                	cmp    %esi,%ebx
  80148e:	72 db                	jb     80146b <readn+0x16>
  801490:	89 d8                	mov    %ebx,%eax
  801492:	eb 02                	jmp    801496 <readn+0x41>
  801494:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801496:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801499:	5b                   	pop    %ebx
  80149a:	5e                   	pop    %esi
  80149b:	5f                   	pop    %edi
  80149c:	5d                   	pop    %ebp
  80149d:	c3                   	ret    

0080149e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80149e:	55                   	push   %ebp
  80149f:	89 e5                	mov    %esp,%ebp
  8014a1:	53                   	push   %ebx
  8014a2:	83 ec 14             	sub    $0x14,%esp
  8014a5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014a8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014ab:	50                   	push   %eax
  8014ac:	53                   	push   %ebx
  8014ad:	e8 ac fc ff ff       	call   80115e <fd_lookup>
  8014b2:	83 c4 08             	add    $0x8,%esp
  8014b5:	89 c2                	mov    %eax,%edx
  8014b7:	85 c0                	test   %eax,%eax
  8014b9:	78 68                	js     801523 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014bb:	83 ec 08             	sub    $0x8,%esp
  8014be:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014c1:	50                   	push   %eax
  8014c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014c5:	ff 30                	pushl  (%eax)
  8014c7:	e8 e8 fc ff ff       	call   8011b4 <dev_lookup>
  8014cc:	83 c4 10             	add    $0x10,%esp
  8014cf:	85 c0                	test   %eax,%eax
  8014d1:	78 47                	js     80151a <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014d6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014da:	75 21                	jne    8014fd <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014dc:	a1 08 40 80 00       	mov    0x804008,%eax
  8014e1:	8b 40 48             	mov    0x48(%eax),%eax
  8014e4:	83 ec 04             	sub    $0x4,%esp
  8014e7:	53                   	push   %ebx
  8014e8:	50                   	push   %eax
  8014e9:	68 5d 2a 80 00       	push   $0x802a5d
  8014ee:	e8 be ec ff ff       	call   8001b1 <cprintf>
		return -E_INVAL;
  8014f3:	83 c4 10             	add    $0x10,%esp
  8014f6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014fb:	eb 26                	jmp    801523 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014fd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801500:	8b 52 0c             	mov    0xc(%edx),%edx
  801503:	85 d2                	test   %edx,%edx
  801505:	74 17                	je     80151e <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801507:	83 ec 04             	sub    $0x4,%esp
  80150a:	ff 75 10             	pushl  0x10(%ebp)
  80150d:	ff 75 0c             	pushl  0xc(%ebp)
  801510:	50                   	push   %eax
  801511:	ff d2                	call   *%edx
  801513:	89 c2                	mov    %eax,%edx
  801515:	83 c4 10             	add    $0x10,%esp
  801518:	eb 09                	jmp    801523 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80151a:	89 c2                	mov    %eax,%edx
  80151c:	eb 05                	jmp    801523 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80151e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801523:	89 d0                	mov    %edx,%eax
  801525:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801528:	c9                   	leave  
  801529:	c3                   	ret    

0080152a <seek>:

int
seek(int fdnum, off_t offset)
{
  80152a:	55                   	push   %ebp
  80152b:	89 e5                	mov    %esp,%ebp
  80152d:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801530:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801533:	50                   	push   %eax
  801534:	ff 75 08             	pushl  0x8(%ebp)
  801537:	e8 22 fc ff ff       	call   80115e <fd_lookup>
  80153c:	83 c4 08             	add    $0x8,%esp
  80153f:	85 c0                	test   %eax,%eax
  801541:	78 0e                	js     801551 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801543:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801546:	8b 55 0c             	mov    0xc(%ebp),%edx
  801549:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80154c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801551:	c9                   	leave  
  801552:	c3                   	ret    

00801553 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801553:	55                   	push   %ebp
  801554:	89 e5                	mov    %esp,%ebp
  801556:	53                   	push   %ebx
  801557:	83 ec 14             	sub    $0x14,%esp
  80155a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80155d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801560:	50                   	push   %eax
  801561:	53                   	push   %ebx
  801562:	e8 f7 fb ff ff       	call   80115e <fd_lookup>
  801567:	83 c4 08             	add    $0x8,%esp
  80156a:	89 c2                	mov    %eax,%edx
  80156c:	85 c0                	test   %eax,%eax
  80156e:	78 65                	js     8015d5 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801570:	83 ec 08             	sub    $0x8,%esp
  801573:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801576:	50                   	push   %eax
  801577:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80157a:	ff 30                	pushl  (%eax)
  80157c:	e8 33 fc ff ff       	call   8011b4 <dev_lookup>
  801581:	83 c4 10             	add    $0x10,%esp
  801584:	85 c0                	test   %eax,%eax
  801586:	78 44                	js     8015cc <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801588:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80158b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80158f:	75 21                	jne    8015b2 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801591:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801596:	8b 40 48             	mov    0x48(%eax),%eax
  801599:	83 ec 04             	sub    $0x4,%esp
  80159c:	53                   	push   %ebx
  80159d:	50                   	push   %eax
  80159e:	68 20 2a 80 00       	push   $0x802a20
  8015a3:	e8 09 ec ff ff       	call   8001b1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015a8:	83 c4 10             	add    $0x10,%esp
  8015ab:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015b0:	eb 23                	jmp    8015d5 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8015b2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015b5:	8b 52 18             	mov    0x18(%edx),%edx
  8015b8:	85 d2                	test   %edx,%edx
  8015ba:	74 14                	je     8015d0 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015bc:	83 ec 08             	sub    $0x8,%esp
  8015bf:	ff 75 0c             	pushl  0xc(%ebp)
  8015c2:	50                   	push   %eax
  8015c3:	ff d2                	call   *%edx
  8015c5:	89 c2                	mov    %eax,%edx
  8015c7:	83 c4 10             	add    $0x10,%esp
  8015ca:	eb 09                	jmp    8015d5 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015cc:	89 c2                	mov    %eax,%edx
  8015ce:	eb 05                	jmp    8015d5 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8015d0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8015d5:	89 d0                	mov    %edx,%eax
  8015d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015da:	c9                   	leave  
  8015db:	c3                   	ret    

008015dc <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015dc:	55                   	push   %ebp
  8015dd:	89 e5                	mov    %esp,%ebp
  8015df:	53                   	push   %ebx
  8015e0:	83 ec 14             	sub    $0x14,%esp
  8015e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015e6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015e9:	50                   	push   %eax
  8015ea:	ff 75 08             	pushl  0x8(%ebp)
  8015ed:	e8 6c fb ff ff       	call   80115e <fd_lookup>
  8015f2:	83 c4 08             	add    $0x8,%esp
  8015f5:	89 c2                	mov    %eax,%edx
  8015f7:	85 c0                	test   %eax,%eax
  8015f9:	78 58                	js     801653 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015fb:	83 ec 08             	sub    $0x8,%esp
  8015fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801601:	50                   	push   %eax
  801602:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801605:	ff 30                	pushl  (%eax)
  801607:	e8 a8 fb ff ff       	call   8011b4 <dev_lookup>
  80160c:	83 c4 10             	add    $0x10,%esp
  80160f:	85 c0                	test   %eax,%eax
  801611:	78 37                	js     80164a <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801613:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801616:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80161a:	74 32                	je     80164e <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80161c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80161f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801626:	00 00 00 
	stat->st_isdir = 0;
  801629:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801630:	00 00 00 
	stat->st_dev = dev;
  801633:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801639:	83 ec 08             	sub    $0x8,%esp
  80163c:	53                   	push   %ebx
  80163d:	ff 75 f0             	pushl  -0x10(%ebp)
  801640:	ff 50 14             	call   *0x14(%eax)
  801643:	89 c2                	mov    %eax,%edx
  801645:	83 c4 10             	add    $0x10,%esp
  801648:	eb 09                	jmp    801653 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80164a:	89 c2                	mov    %eax,%edx
  80164c:	eb 05                	jmp    801653 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80164e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801653:	89 d0                	mov    %edx,%eax
  801655:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801658:	c9                   	leave  
  801659:	c3                   	ret    

0080165a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80165a:	55                   	push   %ebp
  80165b:	89 e5                	mov    %esp,%ebp
  80165d:	56                   	push   %esi
  80165e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80165f:	83 ec 08             	sub    $0x8,%esp
  801662:	6a 00                	push   $0x0
  801664:	ff 75 08             	pushl  0x8(%ebp)
  801667:	e8 0c 02 00 00       	call   801878 <open>
  80166c:	89 c3                	mov    %eax,%ebx
  80166e:	83 c4 10             	add    $0x10,%esp
  801671:	85 c0                	test   %eax,%eax
  801673:	78 1b                	js     801690 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801675:	83 ec 08             	sub    $0x8,%esp
  801678:	ff 75 0c             	pushl  0xc(%ebp)
  80167b:	50                   	push   %eax
  80167c:	e8 5b ff ff ff       	call   8015dc <fstat>
  801681:	89 c6                	mov    %eax,%esi
	close(fd);
  801683:	89 1c 24             	mov    %ebx,(%esp)
  801686:	e8 fd fb ff ff       	call   801288 <close>
	return r;
  80168b:	83 c4 10             	add    $0x10,%esp
  80168e:	89 f0                	mov    %esi,%eax
}
  801690:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801693:	5b                   	pop    %ebx
  801694:	5e                   	pop    %esi
  801695:	5d                   	pop    %ebp
  801696:	c3                   	ret    

00801697 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801697:	55                   	push   %ebp
  801698:	89 e5                	mov    %esp,%ebp
  80169a:	56                   	push   %esi
  80169b:	53                   	push   %ebx
  80169c:	89 c6                	mov    %eax,%esi
  80169e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016a0:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016a7:	75 12                	jne    8016bb <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016a9:	83 ec 0c             	sub    $0xc,%esp
  8016ac:	6a 01                	push   $0x1
  8016ae:	e8 fc f9 ff ff       	call   8010af <ipc_find_env>
  8016b3:	a3 00 40 80 00       	mov    %eax,0x804000
  8016b8:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016bb:	6a 07                	push   $0x7
  8016bd:	68 00 50 80 00       	push   $0x805000
  8016c2:	56                   	push   %esi
  8016c3:	ff 35 00 40 80 00    	pushl  0x804000
  8016c9:	e8 8d f9 ff ff       	call   80105b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016ce:	83 c4 0c             	add    $0xc,%esp
  8016d1:	6a 00                	push   $0x0
  8016d3:	53                   	push   %ebx
  8016d4:	6a 00                	push   $0x0
  8016d6:	e8 17 f9 ff ff       	call   800ff2 <ipc_recv>
}
  8016db:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016de:	5b                   	pop    %ebx
  8016df:	5e                   	pop    %esi
  8016e0:	5d                   	pop    %ebp
  8016e1:	c3                   	ret    

008016e2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016e2:	55                   	push   %ebp
  8016e3:	89 e5                	mov    %esp,%ebp
  8016e5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8016eb:	8b 40 0c             	mov    0xc(%eax),%eax
  8016ee:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8016f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016f6:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016fb:	ba 00 00 00 00       	mov    $0x0,%edx
  801700:	b8 02 00 00 00       	mov    $0x2,%eax
  801705:	e8 8d ff ff ff       	call   801697 <fsipc>
}
  80170a:	c9                   	leave  
  80170b:	c3                   	ret    

0080170c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80170c:	55                   	push   %ebp
  80170d:	89 e5                	mov    %esp,%ebp
  80170f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801712:	8b 45 08             	mov    0x8(%ebp),%eax
  801715:	8b 40 0c             	mov    0xc(%eax),%eax
  801718:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80171d:	ba 00 00 00 00       	mov    $0x0,%edx
  801722:	b8 06 00 00 00       	mov    $0x6,%eax
  801727:	e8 6b ff ff ff       	call   801697 <fsipc>
}
  80172c:	c9                   	leave  
  80172d:	c3                   	ret    

0080172e <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80172e:	55                   	push   %ebp
  80172f:	89 e5                	mov    %esp,%ebp
  801731:	53                   	push   %ebx
  801732:	83 ec 04             	sub    $0x4,%esp
  801735:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801738:	8b 45 08             	mov    0x8(%ebp),%eax
  80173b:	8b 40 0c             	mov    0xc(%eax),%eax
  80173e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801743:	ba 00 00 00 00       	mov    $0x0,%edx
  801748:	b8 05 00 00 00       	mov    $0x5,%eax
  80174d:	e8 45 ff ff ff       	call   801697 <fsipc>
  801752:	85 c0                	test   %eax,%eax
  801754:	78 2c                	js     801782 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801756:	83 ec 08             	sub    $0x8,%esp
  801759:	68 00 50 80 00       	push   $0x805000
  80175e:	53                   	push   %ebx
  80175f:	e8 d2 ef ff ff       	call   800736 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801764:	a1 80 50 80 00       	mov    0x805080,%eax
  801769:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80176f:	a1 84 50 80 00       	mov    0x805084,%eax
  801774:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80177a:	83 c4 10             	add    $0x10,%esp
  80177d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801782:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801785:	c9                   	leave  
  801786:	c3                   	ret    

00801787 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801787:	55                   	push   %ebp
  801788:	89 e5                	mov    %esp,%ebp
  80178a:	53                   	push   %ebx
  80178b:	83 ec 08             	sub    $0x8,%esp
  80178e:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801791:	8b 55 08             	mov    0x8(%ebp),%edx
  801794:	8b 52 0c             	mov    0xc(%edx),%edx
  801797:	89 15 00 50 80 00    	mov    %edx,0x805000
  80179d:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8017a2:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  8017a7:	0f 46 d8             	cmovbe %eax,%ebx
	
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  8017aa:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  8017b0:	53                   	push   %ebx
  8017b1:	ff 75 0c             	pushl  0xc(%ebp)
  8017b4:	68 08 50 80 00       	push   $0x805008
  8017b9:	e8 0a f1 ff ff       	call   8008c8 <memmove>

	
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) 
  8017be:	ba 00 00 00 00       	mov    $0x0,%edx
  8017c3:	b8 04 00 00 00       	mov    $0x4,%eax
  8017c8:	e8 ca fe ff ff       	call   801697 <fsipc>
  8017cd:	83 c4 10             	add    $0x10,%esp
  8017d0:	85 c0                	test   %eax,%eax
  8017d2:	78 1d                	js     8017f1 <devfile_write+0x6a>
		return r;
	assert(r <= n_real); 
  8017d4:	39 d8                	cmp    %ebx,%eax
  8017d6:	76 19                	jbe    8017f1 <devfile_write+0x6a>
  8017d8:	68 90 2a 80 00       	push   $0x802a90
  8017dd:	68 9c 2a 80 00       	push   $0x802a9c
  8017e2:	68 a3 00 00 00       	push   $0xa3
  8017e7:	68 b1 2a 80 00       	push   $0x802ab1
  8017ec:	e8 71 0a 00 00       	call   802262 <_panic>
	return r;
}
  8017f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017f4:	c9                   	leave  
  8017f5:	c3                   	ret    

008017f6 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017f6:	55                   	push   %ebp
  8017f7:	89 e5                	mov    %esp,%ebp
  8017f9:	56                   	push   %esi
  8017fa:	53                   	push   %ebx
  8017fb:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801801:	8b 40 0c             	mov    0xc(%eax),%eax
  801804:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801809:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80180f:	ba 00 00 00 00       	mov    $0x0,%edx
  801814:	b8 03 00 00 00       	mov    $0x3,%eax
  801819:	e8 79 fe ff ff       	call   801697 <fsipc>
  80181e:	89 c3                	mov    %eax,%ebx
  801820:	85 c0                	test   %eax,%eax
  801822:	78 4b                	js     80186f <devfile_read+0x79>
		return r;
	assert(r <= n);
  801824:	39 c6                	cmp    %eax,%esi
  801826:	73 16                	jae    80183e <devfile_read+0x48>
  801828:	68 bc 2a 80 00       	push   $0x802abc
  80182d:	68 9c 2a 80 00       	push   $0x802a9c
  801832:	6a 7c                	push   $0x7c
  801834:	68 b1 2a 80 00       	push   $0x802ab1
  801839:	e8 24 0a 00 00       	call   802262 <_panic>
	assert(r <= PGSIZE);
  80183e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801843:	7e 16                	jle    80185b <devfile_read+0x65>
  801845:	68 c3 2a 80 00       	push   $0x802ac3
  80184a:	68 9c 2a 80 00       	push   $0x802a9c
  80184f:	6a 7d                	push   $0x7d
  801851:	68 b1 2a 80 00       	push   $0x802ab1
  801856:	e8 07 0a 00 00       	call   802262 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80185b:	83 ec 04             	sub    $0x4,%esp
  80185e:	50                   	push   %eax
  80185f:	68 00 50 80 00       	push   $0x805000
  801864:	ff 75 0c             	pushl  0xc(%ebp)
  801867:	e8 5c f0 ff ff       	call   8008c8 <memmove>
	return r;
  80186c:	83 c4 10             	add    $0x10,%esp
}
  80186f:	89 d8                	mov    %ebx,%eax
  801871:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801874:	5b                   	pop    %ebx
  801875:	5e                   	pop    %esi
  801876:	5d                   	pop    %ebp
  801877:	c3                   	ret    

00801878 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801878:	55                   	push   %ebp
  801879:	89 e5                	mov    %esp,%ebp
  80187b:	53                   	push   %ebx
  80187c:	83 ec 20             	sub    $0x20,%esp
  80187f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801882:	53                   	push   %ebx
  801883:	e8 75 ee ff ff       	call   8006fd <strlen>
  801888:	83 c4 10             	add    $0x10,%esp
  80188b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801890:	7f 67                	jg     8018f9 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801892:	83 ec 0c             	sub    $0xc,%esp
  801895:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801898:	50                   	push   %eax
  801899:	e8 71 f8 ff ff       	call   80110f <fd_alloc>
  80189e:	83 c4 10             	add    $0x10,%esp
		return r;
  8018a1:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018a3:	85 c0                	test   %eax,%eax
  8018a5:	78 57                	js     8018fe <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018a7:	83 ec 08             	sub    $0x8,%esp
  8018aa:	53                   	push   %ebx
  8018ab:	68 00 50 80 00       	push   $0x805000
  8018b0:	e8 81 ee ff ff       	call   800736 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018b5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018b8:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018bd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018c0:	b8 01 00 00 00       	mov    $0x1,%eax
  8018c5:	e8 cd fd ff ff       	call   801697 <fsipc>
  8018ca:	89 c3                	mov    %eax,%ebx
  8018cc:	83 c4 10             	add    $0x10,%esp
  8018cf:	85 c0                	test   %eax,%eax
  8018d1:	79 14                	jns    8018e7 <open+0x6f>
		fd_close(fd, 0);
  8018d3:	83 ec 08             	sub    $0x8,%esp
  8018d6:	6a 00                	push   $0x0
  8018d8:	ff 75 f4             	pushl  -0xc(%ebp)
  8018db:	e8 27 f9 ff ff       	call   801207 <fd_close>
		return r;
  8018e0:	83 c4 10             	add    $0x10,%esp
  8018e3:	89 da                	mov    %ebx,%edx
  8018e5:	eb 17                	jmp    8018fe <open+0x86>
	}

	return fd2num(fd);
  8018e7:	83 ec 0c             	sub    $0xc,%esp
  8018ea:	ff 75 f4             	pushl  -0xc(%ebp)
  8018ed:	e8 f6 f7 ff ff       	call   8010e8 <fd2num>
  8018f2:	89 c2                	mov    %eax,%edx
  8018f4:	83 c4 10             	add    $0x10,%esp
  8018f7:	eb 05                	jmp    8018fe <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8018f9:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8018fe:	89 d0                	mov    %edx,%eax
  801900:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801903:	c9                   	leave  
  801904:	c3                   	ret    

00801905 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801905:	55                   	push   %ebp
  801906:	89 e5                	mov    %esp,%ebp
  801908:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80190b:	ba 00 00 00 00       	mov    $0x0,%edx
  801910:	b8 08 00 00 00       	mov    $0x8,%eax
  801915:	e8 7d fd ff ff       	call   801697 <fsipc>
}
  80191a:	c9                   	leave  
  80191b:	c3                   	ret    

0080191c <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  80191c:	55                   	push   %ebp
  80191d:	89 e5                	mov    %esp,%ebp
  80191f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801922:	68 cf 2a 80 00       	push   $0x802acf
  801927:	ff 75 0c             	pushl  0xc(%ebp)
  80192a:	e8 07 ee ff ff       	call   800736 <strcpy>
	return 0;
}
  80192f:	b8 00 00 00 00       	mov    $0x0,%eax
  801934:	c9                   	leave  
  801935:	c3                   	ret    

00801936 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801936:	55                   	push   %ebp
  801937:	89 e5                	mov    %esp,%ebp
  801939:	53                   	push   %ebx
  80193a:	83 ec 10             	sub    $0x10,%esp
  80193d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801940:	53                   	push   %ebx
  801941:	e8 d8 09 00 00       	call   80231e <pageref>
  801946:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801949:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  80194e:	83 f8 01             	cmp    $0x1,%eax
  801951:	75 10                	jne    801963 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801953:	83 ec 0c             	sub    $0xc,%esp
  801956:	ff 73 0c             	pushl  0xc(%ebx)
  801959:	e8 c0 02 00 00       	call   801c1e <nsipc_close>
  80195e:	89 c2                	mov    %eax,%edx
  801960:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801963:	89 d0                	mov    %edx,%eax
  801965:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801968:	c9                   	leave  
  801969:	c3                   	ret    

0080196a <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  80196a:	55                   	push   %ebp
  80196b:	89 e5                	mov    %esp,%ebp
  80196d:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801970:	6a 00                	push   $0x0
  801972:	ff 75 10             	pushl  0x10(%ebp)
  801975:	ff 75 0c             	pushl  0xc(%ebp)
  801978:	8b 45 08             	mov    0x8(%ebp),%eax
  80197b:	ff 70 0c             	pushl  0xc(%eax)
  80197e:	e8 78 03 00 00       	call   801cfb <nsipc_send>
}
  801983:	c9                   	leave  
  801984:	c3                   	ret    

00801985 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801985:	55                   	push   %ebp
  801986:	89 e5                	mov    %esp,%ebp
  801988:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  80198b:	6a 00                	push   $0x0
  80198d:	ff 75 10             	pushl  0x10(%ebp)
  801990:	ff 75 0c             	pushl  0xc(%ebp)
  801993:	8b 45 08             	mov    0x8(%ebp),%eax
  801996:	ff 70 0c             	pushl  0xc(%eax)
  801999:	e8 f1 02 00 00       	call   801c8f <nsipc_recv>
}
  80199e:	c9                   	leave  
  80199f:	c3                   	ret    

008019a0 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8019a0:	55                   	push   %ebp
  8019a1:	89 e5                	mov    %esp,%ebp
  8019a3:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8019a6:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8019a9:	52                   	push   %edx
  8019aa:	50                   	push   %eax
  8019ab:	e8 ae f7 ff ff       	call   80115e <fd_lookup>
  8019b0:	83 c4 10             	add    $0x10,%esp
  8019b3:	85 c0                	test   %eax,%eax
  8019b5:	78 17                	js     8019ce <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8019b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019ba:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  8019c0:	39 08                	cmp    %ecx,(%eax)
  8019c2:	75 05                	jne    8019c9 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8019c4:	8b 40 0c             	mov    0xc(%eax),%eax
  8019c7:	eb 05                	jmp    8019ce <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  8019c9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  8019ce:	c9                   	leave  
  8019cf:	c3                   	ret    

008019d0 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  8019d0:	55                   	push   %ebp
  8019d1:	89 e5                	mov    %esp,%ebp
  8019d3:	56                   	push   %esi
  8019d4:	53                   	push   %ebx
  8019d5:	83 ec 1c             	sub    $0x1c,%esp
  8019d8:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8019da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019dd:	50                   	push   %eax
  8019de:	e8 2c f7 ff ff       	call   80110f <fd_alloc>
  8019e3:	89 c3                	mov    %eax,%ebx
  8019e5:	83 c4 10             	add    $0x10,%esp
  8019e8:	85 c0                	test   %eax,%eax
  8019ea:	78 1b                	js     801a07 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8019ec:	83 ec 04             	sub    $0x4,%esp
  8019ef:	68 07 04 00 00       	push   $0x407
  8019f4:	ff 75 f4             	pushl  -0xc(%ebp)
  8019f7:	6a 00                	push   $0x0
  8019f9:	e8 3b f1 ff ff       	call   800b39 <sys_page_alloc>
  8019fe:	89 c3                	mov    %eax,%ebx
  801a00:	83 c4 10             	add    $0x10,%esp
  801a03:	85 c0                	test   %eax,%eax
  801a05:	79 10                	jns    801a17 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801a07:	83 ec 0c             	sub    $0xc,%esp
  801a0a:	56                   	push   %esi
  801a0b:	e8 0e 02 00 00       	call   801c1e <nsipc_close>
		return r;
  801a10:	83 c4 10             	add    $0x10,%esp
  801a13:	89 d8                	mov    %ebx,%eax
  801a15:	eb 24                	jmp    801a3b <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801a17:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a20:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801a22:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a25:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801a2c:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801a2f:	83 ec 0c             	sub    $0xc,%esp
  801a32:	50                   	push   %eax
  801a33:	e8 b0 f6 ff ff       	call   8010e8 <fd2num>
  801a38:	83 c4 10             	add    $0x10,%esp
}
  801a3b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a3e:	5b                   	pop    %ebx
  801a3f:	5e                   	pop    %esi
  801a40:	5d                   	pop    %ebp
  801a41:	c3                   	ret    

00801a42 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801a42:	55                   	push   %ebp
  801a43:	89 e5                	mov    %esp,%ebp
  801a45:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a48:	8b 45 08             	mov    0x8(%ebp),%eax
  801a4b:	e8 50 ff ff ff       	call   8019a0 <fd2sockid>
		return r;
  801a50:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a52:	85 c0                	test   %eax,%eax
  801a54:	78 1f                	js     801a75 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801a56:	83 ec 04             	sub    $0x4,%esp
  801a59:	ff 75 10             	pushl  0x10(%ebp)
  801a5c:	ff 75 0c             	pushl  0xc(%ebp)
  801a5f:	50                   	push   %eax
  801a60:	e8 12 01 00 00       	call   801b77 <nsipc_accept>
  801a65:	83 c4 10             	add    $0x10,%esp
		return r;
  801a68:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801a6a:	85 c0                	test   %eax,%eax
  801a6c:	78 07                	js     801a75 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801a6e:	e8 5d ff ff ff       	call   8019d0 <alloc_sockfd>
  801a73:	89 c1                	mov    %eax,%ecx
}
  801a75:	89 c8                	mov    %ecx,%eax
  801a77:	c9                   	leave  
  801a78:	c3                   	ret    

00801a79 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801a79:	55                   	push   %ebp
  801a7a:	89 e5                	mov    %esp,%ebp
  801a7c:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a7f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a82:	e8 19 ff ff ff       	call   8019a0 <fd2sockid>
  801a87:	85 c0                	test   %eax,%eax
  801a89:	78 12                	js     801a9d <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801a8b:	83 ec 04             	sub    $0x4,%esp
  801a8e:	ff 75 10             	pushl  0x10(%ebp)
  801a91:	ff 75 0c             	pushl  0xc(%ebp)
  801a94:	50                   	push   %eax
  801a95:	e8 2d 01 00 00       	call   801bc7 <nsipc_bind>
  801a9a:	83 c4 10             	add    $0x10,%esp
}
  801a9d:	c9                   	leave  
  801a9e:	c3                   	ret    

00801a9f <shutdown>:

int
shutdown(int s, int how)
{
  801a9f:	55                   	push   %ebp
  801aa0:	89 e5                	mov    %esp,%ebp
  801aa2:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801aa5:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa8:	e8 f3 fe ff ff       	call   8019a0 <fd2sockid>
  801aad:	85 c0                	test   %eax,%eax
  801aaf:	78 0f                	js     801ac0 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801ab1:	83 ec 08             	sub    $0x8,%esp
  801ab4:	ff 75 0c             	pushl  0xc(%ebp)
  801ab7:	50                   	push   %eax
  801ab8:	e8 3f 01 00 00       	call   801bfc <nsipc_shutdown>
  801abd:	83 c4 10             	add    $0x10,%esp
}
  801ac0:	c9                   	leave  
  801ac1:	c3                   	ret    

00801ac2 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801ac2:	55                   	push   %ebp
  801ac3:	89 e5                	mov    %esp,%ebp
  801ac5:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ac8:	8b 45 08             	mov    0x8(%ebp),%eax
  801acb:	e8 d0 fe ff ff       	call   8019a0 <fd2sockid>
  801ad0:	85 c0                	test   %eax,%eax
  801ad2:	78 12                	js     801ae6 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801ad4:	83 ec 04             	sub    $0x4,%esp
  801ad7:	ff 75 10             	pushl  0x10(%ebp)
  801ada:	ff 75 0c             	pushl  0xc(%ebp)
  801add:	50                   	push   %eax
  801ade:	e8 55 01 00 00       	call   801c38 <nsipc_connect>
  801ae3:	83 c4 10             	add    $0x10,%esp
}
  801ae6:	c9                   	leave  
  801ae7:	c3                   	ret    

00801ae8 <listen>:

int
listen(int s, int backlog)
{
  801ae8:	55                   	push   %ebp
  801ae9:	89 e5                	mov    %esp,%ebp
  801aeb:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801aee:	8b 45 08             	mov    0x8(%ebp),%eax
  801af1:	e8 aa fe ff ff       	call   8019a0 <fd2sockid>
  801af6:	85 c0                	test   %eax,%eax
  801af8:	78 0f                	js     801b09 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801afa:	83 ec 08             	sub    $0x8,%esp
  801afd:	ff 75 0c             	pushl  0xc(%ebp)
  801b00:	50                   	push   %eax
  801b01:	e8 67 01 00 00       	call   801c6d <nsipc_listen>
  801b06:	83 c4 10             	add    $0x10,%esp
}
  801b09:	c9                   	leave  
  801b0a:	c3                   	ret    

00801b0b <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801b0b:	55                   	push   %ebp
  801b0c:	89 e5                	mov    %esp,%ebp
  801b0e:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801b11:	ff 75 10             	pushl  0x10(%ebp)
  801b14:	ff 75 0c             	pushl  0xc(%ebp)
  801b17:	ff 75 08             	pushl  0x8(%ebp)
  801b1a:	e8 3a 02 00 00       	call   801d59 <nsipc_socket>
  801b1f:	83 c4 10             	add    $0x10,%esp
  801b22:	85 c0                	test   %eax,%eax
  801b24:	78 05                	js     801b2b <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801b26:	e8 a5 fe ff ff       	call   8019d0 <alloc_sockfd>
}
  801b2b:	c9                   	leave  
  801b2c:	c3                   	ret    

00801b2d <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801b2d:	55                   	push   %ebp
  801b2e:	89 e5                	mov    %esp,%ebp
  801b30:	53                   	push   %ebx
  801b31:	83 ec 04             	sub    $0x4,%esp
  801b34:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801b36:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801b3d:	75 12                	jne    801b51 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801b3f:	83 ec 0c             	sub    $0xc,%esp
  801b42:	6a 02                	push   $0x2
  801b44:	e8 66 f5 ff ff       	call   8010af <ipc_find_env>
  801b49:	a3 04 40 80 00       	mov    %eax,0x804004
  801b4e:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801b51:	6a 07                	push   $0x7
  801b53:	68 00 60 80 00       	push   $0x806000
  801b58:	53                   	push   %ebx
  801b59:	ff 35 04 40 80 00    	pushl  0x804004
  801b5f:	e8 f7 f4 ff ff       	call   80105b <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801b64:	83 c4 0c             	add    $0xc,%esp
  801b67:	6a 00                	push   $0x0
  801b69:	6a 00                	push   $0x0
  801b6b:	6a 00                	push   $0x0
  801b6d:	e8 80 f4 ff ff       	call   800ff2 <ipc_recv>
}
  801b72:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b75:	c9                   	leave  
  801b76:	c3                   	ret    

00801b77 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801b77:	55                   	push   %ebp
  801b78:	89 e5                	mov    %esp,%ebp
  801b7a:	56                   	push   %esi
  801b7b:	53                   	push   %ebx
  801b7c:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801b7f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b82:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801b87:	8b 06                	mov    (%esi),%eax
  801b89:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801b8e:	b8 01 00 00 00       	mov    $0x1,%eax
  801b93:	e8 95 ff ff ff       	call   801b2d <nsipc>
  801b98:	89 c3                	mov    %eax,%ebx
  801b9a:	85 c0                	test   %eax,%eax
  801b9c:	78 20                	js     801bbe <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801b9e:	83 ec 04             	sub    $0x4,%esp
  801ba1:	ff 35 10 60 80 00    	pushl  0x806010
  801ba7:	68 00 60 80 00       	push   $0x806000
  801bac:	ff 75 0c             	pushl  0xc(%ebp)
  801baf:	e8 14 ed ff ff       	call   8008c8 <memmove>
		*addrlen = ret->ret_addrlen;
  801bb4:	a1 10 60 80 00       	mov    0x806010,%eax
  801bb9:	89 06                	mov    %eax,(%esi)
  801bbb:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801bbe:	89 d8                	mov    %ebx,%eax
  801bc0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bc3:	5b                   	pop    %ebx
  801bc4:	5e                   	pop    %esi
  801bc5:	5d                   	pop    %ebp
  801bc6:	c3                   	ret    

00801bc7 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801bc7:	55                   	push   %ebp
  801bc8:	89 e5                	mov    %esp,%ebp
  801bca:	53                   	push   %ebx
  801bcb:	83 ec 08             	sub    $0x8,%esp
  801bce:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801bd1:	8b 45 08             	mov    0x8(%ebp),%eax
  801bd4:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801bd9:	53                   	push   %ebx
  801bda:	ff 75 0c             	pushl  0xc(%ebp)
  801bdd:	68 04 60 80 00       	push   $0x806004
  801be2:	e8 e1 ec ff ff       	call   8008c8 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801be7:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801bed:	b8 02 00 00 00       	mov    $0x2,%eax
  801bf2:	e8 36 ff ff ff       	call   801b2d <nsipc>
}
  801bf7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bfa:	c9                   	leave  
  801bfb:	c3                   	ret    

00801bfc <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801bfc:	55                   	push   %ebp
  801bfd:	89 e5                	mov    %esp,%ebp
  801bff:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801c02:	8b 45 08             	mov    0x8(%ebp),%eax
  801c05:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801c0a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c0d:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801c12:	b8 03 00 00 00       	mov    $0x3,%eax
  801c17:	e8 11 ff ff ff       	call   801b2d <nsipc>
}
  801c1c:	c9                   	leave  
  801c1d:	c3                   	ret    

00801c1e <nsipc_close>:

int
nsipc_close(int s)
{
  801c1e:	55                   	push   %ebp
  801c1f:	89 e5                	mov    %esp,%ebp
  801c21:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801c24:	8b 45 08             	mov    0x8(%ebp),%eax
  801c27:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801c2c:	b8 04 00 00 00       	mov    $0x4,%eax
  801c31:	e8 f7 fe ff ff       	call   801b2d <nsipc>
}
  801c36:	c9                   	leave  
  801c37:	c3                   	ret    

00801c38 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801c38:	55                   	push   %ebp
  801c39:	89 e5                	mov    %esp,%ebp
  801c3b:	53                   	push   %ebx
  801c3c:	83 ec 08             	sub    $0x8,%esp
  801c3f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801c42:	8b 45 08             	mov    0x8(%ebp),%eax
  801c45:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801c4a:	53                   	push   %ebx
  801c4b:	ff 75 0c             	pushl  0xc(%ebp)
  801c4e:	68 04 60 80 00       	push   $0x806004
  801c53:	e8 70 ec ff ff       	call   8008c8 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801c58:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801c5e:	b8 05 00 00 00       	mov    $0x5,%eax
  801c63:	e8 c5 fe ff ff       	call   801b2d <nsipc>
}
  801c68:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c6b:	c9                   	leave  
  801c6c:	c3                   	ret    

00801c6d <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801c6d:	55                   	push   %ebp
  801c6e:	89 e5                	mov    %esp,%ebp
  801c70:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801c73:	8b 45 08             	mov    0x8(%ebp),%eax
  801c76:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801c7b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c7e:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801c83:	b8 06 00 00 00       	mov    $0x6,%eax
  801c88:	e8 a0 fe ff ff       	call   801b2d <nsipc>
}
  801c8d:	c9                   	leave  
  801c8e:	c3                   	ret    

00801c8f <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801c8f:	55                   	push   %ebp
  801c90:	89 e5                	mov    %esp,%ebp
  801c92:	56                   	push   %esi
  801c93:	53                   	push   %ebx
  801c94:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801c97:	8b 45 08             	mov    0x8(%ebp),%eax
  801c9a:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801c9f:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801ca5:	8b 45 14             	mov    0x14(%ebp),%eax
  801ca8:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801cad:	b8 07 00 00 00       	mov    $0x7,%eax
  801cb2:	e8 76 fe ff ff       	call   801b2d <nsipc>
  801cb7:	89 c3                	mov    %eax,%ebx
  801cb9:	85 c0                	test   %eax,%eax
  801cbb:	78 35                	js     801cf2 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801cbd:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801cc2:	7f 04                	jg     801cc8 <nsipc_recv+0x39>
  801cc4:	39 c6                	cmp    %eax,%esi
  801cc6:	7d 16                	jge    801cde <nsipc_recv+0x4f>
  801cc8:	68 db 2a 80 00       	push   $0x802adb
  801ccd:	68 9c 2a 80 00       	push   $0x802a9c
  801cd2:	6a 62                	push   $0x62
  801cd4:	68 f0 2a 80 00       	push   $0x802af0
  801cd9:	e8 84 05 00 00       	call   802262 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801cde:	83 ec 04             	sub    $0x4,%esp
  801ce1:	50                   	push   %eax
  801ce2:	68 00 60 80 00       	push   $0x806000
  801ce7:	ff 75 0c             	pushl  0xc(%ebp)
  801cea:	e8 d9 eb ff ff       	call   8008c8 <memmove>
  801cef:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801cf2:	89 d8                	mov    %ebx,%eax
  801cf4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cf7:	5b                   	pop    %ebx
  801cf8:	5e                   	pop    %esi
  801cf9:	5d                   	pop    %ebp
  801cfa:	c3                   	ret    

00801cfb <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801cfb:	55                   	push   %ebp
  801cfc:	89 e5                	mov    %esp,%ebp
  801cfe:	53                   	push   %ebx
  801cff:	83 ec 04             	sub    $0x4,%esp
  801d02:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801d05:	8b 45 08             	mov    0x8(%ebp),%eax
  801d08:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801d0d:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801d13:	7e 16                	jle    801d2b <nsipc_send+0x30>
  801d15:	68 fc 2a 80 00       	push   $0x802afc
  801d1a:	68 9c 2a 80 00       	push   $0x802a9c
  801d1f:	6a 6d                	push   $0x6d
  801d21:	68 f0 2a 80 00       	push   $0x802af0
  801d26:	e8 37 05 00 00       	call   802262 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801d2b:	83 ec 04             	sub    $0x4,%esp
  801d2e:	53                   	push   %ebx
  801d2f:	ff 75 0c             	pushl  0xc(%ebp)
  801d32:	68 0c 60 80 00       	push   $0x80600c
  801d37:	e8 8c eb ff ff       	call   8008c8 <memmove>
	nsipcbuf.send.req_size = size;
  801d3c:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801d42:	8b 45 14             	mov    0x14(%ebp),%eax
  801d45:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801d4a:	b8 08 00 00 00       	mov    $0x8,%eax
  801d4f:	e8 d9 fd ff ff       	call   801b2d <nsipc>
}
  801d54:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d57:	c9                   	leave  
  801d58:	c3                   	ret    

00801d59 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801d59:	55                   	push   %ebp
  801d5a:	89 e5                	mov    %esp,%ebp
  801d5c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801d5f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d62:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801d67:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d6a:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801d6f:	8b 45 10             	mov    0x10(%ebp),%eax
  801d72:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801d77:	b8 09 00 00 00       	mov    $0x9,%eax
  801d7c:	e8 ac fd ff ff       	call   801b2d <nsipc>
}
  801d81:	c9                   	leave  
  801d82:	c3                   	ret    

00801d83 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801d83:	55                   	push   %ebp
  801d84:	89 e5                	mov    %esp,%ebp
  801d86:	56                   	push   %esi
  801d87:	53                   	push   %ebx
  801d88:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801d8b:	83 ec 0c             	sub    $0xc,%esp
  801d8e:	ff 75 08             	pushl  0x8(%ebp)
  801d91:	e8 62 f3 ff ff       	call   8010f8 <fd2data>
  801d96:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801d98:	83 c4 08             	add    $0x8,%esp
  801d9b:	68 08 2b 80 00       	push   $0x802b08
  801da0:	53                   	push   %ebx
  801da1:	e8 90 e9 ff ff       	call   800736 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801da6:	8b 46 04             	mov    0x4(%esi),%eax
  801da9:	2b 06                	sub    (%esi),%eax
  801dab:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801db1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801db8:	00 00 00 
	stat->st_dev = &devpipe;
  801dbb:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801dc2:	30 80 00 
	return 0;
}
  801dc5:	b8 00 00 00 00       	mov    $0x0,%eax
  801dca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dcd:	5b                   	pop    %ebx
  801dce:	5e                   	pop    %esi
  801dcf:	5d                   	pop    %ebp
  801dd0:	c3                   	ret    

00801dd1 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801dd1:	55                   	push   %ebp
  801dd2:	89 e5                	mov    %esp,%ebp
  801dd4:	53                   	push   %ebx
  801dd5:	83 ec 0c             	sub    $0xc,%esp
  801dd8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ddb:	53                   	push   %ebx
  801ddc:	6a 00                	push   $0x0
  801dde:	e8 db ed ff ff       	call   800bbe <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801de3:	89 1c 24             	mov    %ebx,(%esp)
  801de6:	e8 0d f3 ff ff       	call   8010f8 <fd2data>
  801deb:	83 c4 08             	add    $0x8,%esp
  801dee:	50                   	push   %eax
  801def:	6a 00                	push   $0x0
  801df1:	e8 c8 ed ff ff       	call   800bbe <sys_page_unmap>
}
  801df6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801df9:	c9                   	leave  
  801dfa:	c3                   	ret    

00801dfb <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801dfb:	55                   	push   %ebp
  801dfc:	89 e5                	mov    %esp,%ebp
  801dfe:	57                   	push   %edi
  801dff:	56                   	push   %esi
  801e00:	53                   	push   %ebx
  801e01:	83 ec 1c             	sub    $0x1c,%esp
  801e04:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801e07:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801e09:	a1 08 40 80 00       	mov    0x804008,%eax
  801e0e:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801e11:	83 ec 0c             	sub    $0xc,%esp
  801e14:	ff 75 e0             	pushl  -0x20(%ebp)
  801e17:	e8 02 05 00 00       	call   80231e <pageref>
  801e1c:	89 c3                	mov    %eax,%ebx
  801e1e:	89 3c 24             	mov    %edi,(%esp)
  801e21:	e8 f8 04 00 00       	call   80231e <pageref>
  801e26:	83 c4 10             	add    $0x10,%esp
  801e29:	39 c3                	cmp    %eax,%ebx
  801e2b:	0f 94 c1             	sete   %cl
  801e2e:	0f b6 c9             	movzbl %cl,%ecx
  801e31:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801e34:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801e3a:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801e3d:	39 ce                	cmp    %ecx,%esi
  801e3f:	74 1b                	je     801e5c <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801e41:	39 c3                	cmp    %eax,%ebx
  801e43:	75 c4                	jne    801e09 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801e45:	8b 42 58             	mov    0x58(%edx),%eax
  801e48:	ff 75 e4             	pushl  -0x1c(%ebp)
  801e4b:	50                   	push   %eax
  801e4c:	56                   	push   %esi
  801e4d:	68 0f 2b 80 00       	push   $0x802b0f
  801e52:	e8 5a e3 ff ff       	call   8001b1 <cprintf>
  801e57:	83 c4 10             	add    $0x10,%esp
  801e5a:	eb ad                	jmp    801e09 <_pipeisclosed+0xe>
	}
}
  801e5c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e62:	5b                   	pop    %ebx
  801e63:	5e                   	pop    %esi
  801e64:	5f                   	pop    %edi
  801e65:	5d                   	pop    %ebp
  801e66:	c3                   	ret    

00801e67 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e67:	55                   	push   %ebp
  801e68:	89 e5                	mov    %esp,%ebp
  801e6a:	57                   	push   %edi
  801e6b:	56                   	push   %esi
  801e6c:	53                   	push   %ebx
  801e6d:	83 ec 28             	sub    $0x28,%esp
  801e70:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801e73:	56                   	push   %esi
  801e74:	e8 7f f2 ff ff       	call   8010f8 <fd2data>
  801e79:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e7b:	83 c4 10             	add    $0x10,%esp
  801e7e:	bf 00 00 00 00       	mov    $0x0,%edi
  801e83:	eb 4b                	jmp    801ed0 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801e85:	89 da                	mov    %ebx,%edx
  801e87:	89 f0                	mov    %esi,%eax
  801e89:	e8 6d ff ff ff       	call   801dfb <_pipeisclosed>
  801e8e:	85 c0                	test   %eax,%eax
  801e90:	75 48                	jne    801eda <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801e92:	e8 83 ec ff ff       	call   800b1a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801e97:	8b 43 04             	mov    0x4(%ebx),%eax
  801e9a:	8b 0b                	mov    (%ebx),%ecx
  801e9c:	8d 51 20             	lea    0x20(%ecx),%edx
  801e9f:	39 d0                	cmp    %edx,%eax
  801ea1:	73 e2                	jae    801e85 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ea3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ea6:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801eaa:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801ead:	89 c2                	mov    %eax,%edx
  801eaf:	c1 fa 1f             	sar    $0x1f,%edx
  801eb2:	89 d1                	mov    %edx,%ecx
  801eb4:	c1 e9 1b             	shr    $0x1b,%ecx
  801eb7:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801eba:	83 e2 1f             	and    $0x1f,%edx
  801ebd:	29 ca                	sub    %ecx,%edx
  801ebf:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801ec3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ec7:	83 c0 01             	add    $0x1,%eax
  801eca:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ecd:	83 c7 01             	add    $0x1,%edi
  801ed0:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ed3:	75 c2                	jne    801e97 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801ed5:	8b 45 10             	mov    0x10(%ebp),%eax
  801ed8:	eb 05                	jmp    801edf <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801eda:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801edf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ee2:	5b                   	pop    %ebx
  801ee3:	5e                   	pop    %esi
  801ee4:	5f                   	pop    %edi
  801ee5:	5d                   	pop    %ebp
  801ee6:	c3                   	ret    

00801ee7 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ee7:	55                   	push   %ebp
  801ee8:	89 e5                	mov    %esp,%ebp
  801eea:	57                   	push   %edi
  801eeb:	56                   	push   %esi
  801eec:	53                   	push   %ebx
  801eed:	83 ec 18             	sub    $0x18,%esp
  801ef0:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801ef3:	57                   	push   %edi
  801ef4:	e8 ff f1 ff ff       	call   8010f8 <fd2data>
  801ef9:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801efb:	83 c4 10             	add    $0x10,%esp
  801efe:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f03:	eb 3d                	jmp    801f42 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801f05:	85 db                	test   %ebx,%ebx
  801f07:	74 04                	je     801f0d <devpipe_read+0x26>
				return i;
  801f09:	89 d8                	mov    %ebx,%eax
  801f0b:	eb 44                	jmp    801f51 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801f0d:	89 f2                	mov    %esi,%edx
  801f0f:	89 f8                	mov    %edi,%eax
  801f11:	e8 e5 fe ff ff       	call   801dfb <_pipeisclosed>
  801f16:	85 c0                	test   %eax,%eax
  801f18:	75 32                	jne    801f4c <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801f1a:	e8 fb eb ff ff       	call   800b1a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801f1f:	8b 06                	mov    (%esi),%eax
  801f21:	3b 46 04             	cmp    0x4(%esi),%eax
  801f24:	74 df                	je     801f05 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801f26:	99                   	cltd   
  801f27:	c1 ea 1b             	shr    $0x1b,%edx
  801f2a:	01 d0                	add    %edx,%eax
  801f2c:	83 e0 1f             	and    $0x1f,%eax
  801f2f:	29 d0                	sub    %edx,%eax
  801f31:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801f36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f39:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801f3c:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f3f:	83 c3 01             	add    $0x1,%ebx
  801f42:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801f45:	75 d8                	jne    801f1f <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801f47:	8b 45 10             	mov    0x10(%ebp),%eax
  801f4a:	eb 05                	jmp    801f51 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f4c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801f51:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f54:	5b                   	pop    %ebx
  801f55:	5e                   	pop    %esi
  801f56:	5f                   	pop    %edi
  801f57:	5d                   	pop    %ebp
  801f58:	c3                   	ret    

00801f59 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801f59:	55                   	push   %ebp
  801f5a:	89 e5                	mov    %esp,%ebp
  801f5c:	56                   	push   %esi
  801f5d:	53                   	push   %ebx
  801f5e:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801f61:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f64:	50                   	push   %eax
  801f65:	e8 a5 f1 ff ff       	call   80110f <fd_alloc>
  801f6a:	83 c4 10             	add    $0x10,%esp
  801f6d:	89 c2                	mov    %eax,%edx
  801f6f:	85 c0                	test   %eax,%eax
  801f71:	0f 88 2c 01 00 00    	js     8020a3 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f77:	83 ec 04             	sub    $0x4,%esp
  801f7a:	68 07 04 00 00       	push   $0x407
  801f7f:	ff 75 f4             	pushl  -0xc(%ebp)
  801f82:	6a 00                	push   $0x0
  801f84:	e8 b0 eb ff ff       	call   800b39 <sys_page_alloc>
  801f89:	83 c4 10             	add    $0x10,%esp
  801f8c:	89 c2                	mov    %eax,%edx
  801f8e:	85 c0                	test   %eax,%eax
  801f90:	0f 88 0d 01 00 00    	js     8020a3 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801f96:	83 ec 0c             	sub    $0xc,%esp
  801f99:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f9c:	50                   	push   %eax
  801f9d:	e8 6d f1 ff ff       	call   80110f <fd_alloc>
  801fa2:	89 c3                	mov    %eax,%ebx
  801fa4:	83 c4 10             	add    $0x10,%esp
  801fa7:	85 c0                	test   %eax,%eax
  801fa9:	0f 88 e2 00 00 00    	js     802091 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801faf:	83 ec 04             	sub    $0x4,%esp
  801fb2:	68 07 04 00 00       	push   $0x407
  801fb7:	ff 75 f0             	pushl  -0x10(%ebp)
  801fba:	6a 00                	push   $0x0
  801fbc:	e8 78 eb ff ff       	call   800b39 <sys_page_alloc>
  801fc1:	89 c3                	mov    %eax,%ebx
  801fc3:	83 c4 10             	add    $0x10,%esp
  801fc6:	85 c0                	test   %eax,%eax
  801fc8:	0f 88 c3 00 00 00    	js     802091 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801fce:	83 ec 0c             	sub    $0xc,%esp
  801fd1:	ff 75 f4             	pushl  -0xc(%ebp)
  801fd4:	e8 1f f1 ff ff       	call   8010f8 <fd2data>
  801fd9:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fdb:	83 c4 0c             	add    $0xc,%esp
  801fde:	68 07 04 00 00       	push   $0x407
  801fe3:	50                   	push   %eax
  801fe4:	6a 00                	push   $0x0
  801fe6:	e8 4e eb ff ff       	call   800b39 <sys_page_alloc>
  801feb:	89 c3                	mov    %eax,%ebx
  801fed:	83 c4 10             	add    $0x10,%esp
  801ff0:	85 c0                	test   %eax,%eax
  801ff2:	0f 88 89 00 00 00    	js     802081 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ff8:	83 ec 0c             	sub    $0xc,%esp
  801ffb:	ff 75 f0             	pushl  -0x10(%ebp)
  801ffe:	e8 f5 f0 ff ff       	call   8010f8 <fd2data>
  802003:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80200a:	50                   	push   %eax
  80200b:	6a 00                	push   $0x0
  80200d:	56                   	push   %esi
  80200e:	6a 00                	push   $0x0
  802010:	e8 67 eb ff ff       	call   800b7c <sys_page_map>
  802015:	89 c3                	mov    %eax,%ebx
  802017:	83 c4 20             	add    $0x20,%esp
  80201a:	85 c0                	test   %eax,%eax
  80201c:	78 55                	js     802073 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80201e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802024:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802027:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802029:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80202c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802033:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802039:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80203c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80203e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802041:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802048:	83 ec 0c             	sub    $0xc,%esp
  80204b:	ff 75 f4             	pushl  -0xc(%ebp)
  80204e:	e8 95 f0 ff ff       	call   8010e8 <fd2num>
  802053:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802056:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802058:	83 c4 04             	add    $0x4,%esp
  80205b:	ff 75 f0             	pushl  -0x10(%ebp)
  80205e:	e8 85 f0 ff ff       	call   8010e8 <fd2num>
  802063:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802066:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802069:	83 c4 10             	add    $0x10,%esp
  80206c:	ba 00 00 00 00       	mov    $0x0,%edx
  802071:	eb 30                	jmp    8020a3 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802073:	83 ec 08             	sub    $0x8,%esp
  802076:	56                   	push   %esi
  802077:	6a 00                	push   $0x0
  802079:	e8 40 eb ff ff       	call   800bbe <sys_page_unmap>
  80207e:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802081:	83 ec 08             	sub    $0x8,%esp
  802084:	ff 75 f0             	pushl  -0x10(%ebp)
  802087:	6a 00                	push   $0x0
  802089:	e8 30 eb ff ff       	call   800bbe <sys_page_unmap>
  80208e:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802091:	83 ec 08             	sub    $0x8,%esp
  802094:	ff 75 f4             	pushl  -0xc(%ebp)
  802097:	6a 00                	push   $0x0
  802099:	e8 20 eb ff ff       	call   800bbe <sys_page_unmap>
  80209e:	83 c4 10             	add    $0x10,%esp
  8020a1:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8020a3:	89 d0                	mov    %edx,%eax
  8020a5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020a8:	5b                   	pop    %ebx
  8020a9:	5e                   	pop    %esi
  8020aa:	5d                   	pop    %ebp
  8020ab:	c3                   	ret    

008020ac <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8020ac:	55                   	push   %ebp
  8020ad:	89 e5                	mov    %esp,%ebp
  8020af:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020b5:	50                   	push   %eax
  8020b6:	ff 75 08             	pushl  0x8(%ebp)
  8020b9:	e8 a0 f0 ff ff       	call   80115e <fd_lookup>
  8020be:	83 c4 10             	add    $0x10,%esp
  8020c1:	85 c0                	test   %eax,%eax
  8020c3:	78 18                	js     8020dd <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8020c5:	83 ec 0c             	sub    $0xc,%esp
  8020c8:	ff 75 f4             	pushl  -0xc(%ebp)
  8020cb:	e8 28 f0 ff ff       	call   8010f8 <fd2data>
	return _pipeisclosed(fd, p);
  8020d0:	89 c2                	mov    %eax,%edx
  8020d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020d5:	e8 21 fd ff ff       	call   801dfb <_pipeisclosed>
  8020da:	83 c4 10             	add    $0x10,%esp
}
  8020dd:	c9                   	leave  
  8020de:	c3                   	ret    

008020df <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8020df:	55                   	push   %ebp
  8020e0:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8020e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8020e7:	5d                   	pop    %ebp
  8020e8:	c3                   	ret    

008020e9 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8020e9:	55                   	push   %ebp
  8020ea:	89 e5                	mov    %esp,%ebp
  8020ec:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8020ef:	68 27 2b 80 00       	push   $0x802b27
  8020f4:	ff 75 0c             	pushl  0xc(%ebp)
  8020f7:	e8 3a e6 ff ff       	call   800736 <strcpy>
	return 0;
}
  8020fc:	b8 00 00 00 00       	mov    $0x0,%eax
  802101:	c9                   	leave  
  802102:	c3                   	ret    

00802103 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802103:	55                   	push   %ebp
  802104:	89 e5                	mov    %esp,%ebp
  802106:	57                   	push   %edi
  802107:	56                   	push   %esi
  802108:	53                   	push   %ebx
  802109:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80210f:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802114:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80211a:	eb 2d                	jmp    802149 <devcons_write+0x46>
		m = n - tot;
  80211c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80211f:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802121:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802124:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802129:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80212c:	83 ec 04             	sub    $0x4,%esp
  80212f:	53                   	push   %ebx
  802130:	03 45 0c             	add    0xc(%ebp),%eax
  802133:	50                   	push   %eax
  802134:	57                   	push   %edi
  802135:	e8 8e e7 ff ff       	call   8008c8 <memmove>
		sys_cputs(buf, m);
  80213a:	83 c4 08             	add    $0x8,%esp
  80213d:	53                   	push   %ebx
  80213e:	57                   	push   %edi
  80213f:	e8 39 e9 ff ff       	call   800a7d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802144:	01 de                	add    %ebx,%esi
  802146:	83 c4 10             	add    $0x10,%esp
  802149:	89 f0                	mov    %esi,%eax
  80214b:	3b 75 10             	cmp    0x10(%ebp),%esi
  80214e:	72 cc                	jb     80211c <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802150:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802153:	5b                   	pop    %ebx
  802154:	5e                   	pop    %esi
  802155:	5f                   	pop    %edi
  802156:	5d                   	pop    %ebp
  802157:	c3                   	ret    

00802158 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802158:	55                   	push   %ebp
  802159:	89 e5                	mov    %esp,%ebp
  80215b:	83 ec 08             	sub    $0x8,%esp
  80215e:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802163:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802167:	74 2a                	je     802193 <devcons_read+0x3b>
  802169:	eb 05                	jmp    802170 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80216b:	e8 aa e9 ff ff       	call   800b1a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802170:	e8 26 e9 ff ff       	call   800a9b <sys_cgetc>
  802175:	85 c0                	test   %eax,%eax
  802177:	74 f2                	je     80216b <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802179:	85 c0                	test   %eax,%eax
  80217b:	78 16                	js     802193 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80217d:	83 f8 04             	cmp    $0x4,%eax
  802180:	74 0c                	je     80218e <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802182:	8b 55 0c             	mov    0xc(%ebp),%edx
  802185:	88 02                	mov    %al,(%edx)
	return 1;
  802187:	b8 01 00 00 00       	mov    $0x1,%eax
  80218c:	eb 05                	jmp    802193 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80218e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802193:	c9                   	leave  
  802194:	c3                   	ret    

00802195 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802195:	55                   	push   %ebp
  802196:	89 e5                	mov    %esp,%ebp
  802198:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80219b:	8b 45 08             	mov    0x8(%ebp),%eax
  80219e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8021a1:	6a 01                	push   $0x1
  8021a3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8021a6:	50                   	push   %eax
  8021a7:	e8 d1 e8 ff ff       	call   800a7d <sys_cputs>
}
  8021ac:	83 c4 10             	add    $0x10,%esp
  8021af:	c9                   	leave  
  8021b0:	c3                   	ret    

008021b1 <getchar>:

int
getchar(void)
{
  8021b1:	55                   	push   %ebp
  8021b2:	89 e5                	mov    %esp,%ebp
  8021b4:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8021b7:	6a 01                	push   $0x1
  8021b9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8021bc:	50                   	push   %eax
  8021bd:	6a 00                	push   $0x0
  8021bf:	e8 00 f2 ff ff       	call   8013c4 <read>
	if (r < 0)
  8021c4:	83 c4 10             	add    $0x10,%esp
  8021c7:	85 c0                	test   %eax,%eax
  8021c9:	78 0f                	js     8021da <getchar+0x29>
		return r;
	if (r < 1)
  8021cb:	85 c0                	test   %eax,%eax
  8021cd:	7e 06                	jle    8021d5 <getchar+0x24>
		return -E_EOF;
	return c;
  8021cf:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8021d3:	eb 05                	jmp    8021da <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8021d5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8021da:	c9                   	leave  
  8021db:	c3                   	ret    

008021dc <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8021dc:	55                   	push   %ebp
  8021dd:	89 e5                	mov    %esp,%ebp
  8021df:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021e5:	50                   	push   %eax
  8021e6:	ff 75 08             	pushl  0x8(%ebp)
  8021e9:	e8 70 ef ff ff       	call   80115e <fd_lookup>
  8021ee:	83 c4 10             	add    $0x10,%esp
  8021f1:	85 c0                	test   %eax,%eax
  8021f3:	78 11                	js     802206 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8021f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021f8:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8021fe:	39 10                	cmp    %edx,(%eax)
  802200:	0f 94 c0             	sete   %al
  802203:	0f b6 c0             	movzbl %al,%eax
}
  802206:	c9                   	leave  
  802207:	c3                   	ret    

00802208 <opencons>:

int
opencons(void)
{
  802208:	55                   	push   %ebp
  802209:	89 e5                	mov    %esp,%ebp
  80220b:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80220e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802211:	50                   	push   %eax
  802212:	e8 f8 ee ff ff       	call   80110f <fd_alloc>
  802217:	83 c4 10             	add    $0x10,%esp
		return r;
  80221a:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80221c:	85 c0                	test   %eax,%eax
  80221e:	78 3e                	js     80225e <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802220:	83 ec 04             	sub    $0x4,%esp
  802223:	68 07 04 00 00       	push   $0x407
  802228:	ff 75 f4             	pushl  -0xc(%ebp)
  80222b:	6a 00                	push   $0x0
  80222d:	e8 07 e9 ff ff       	call   800b39 <sys_page_alloc>
  802232:	83 c4 10             	add    $0x10,%esp
		return r;
  802235:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802237:	85 c0                	test   %eax,%eax
  802239:	78 23                	js     80225e <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80223b:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802241:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802244:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802246:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802249:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802250:	83 ec 0c             	sub    $0xc,%esp
  802253:	50                   	push   %eax
  802254:	e8 8f ee ff ff       	call   8010e8 <fd2num>
  802259:	89 c2                	mov    %eax,%edx
  80225b:	83 c4 10             	add    $0x10,%esp
}
  80225e:	89 d0                	mov    %edx,%eax
  802260:	c9                   	leave  
  802261:	c3                   	ret    

00802262 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802262:	55                   	push   %ebp
  802263:	89 e5                	mov    %esp,%ebp
  802265:	56                   	push   %esi
  802266:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  802267:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80226a:	8b 35 00 30 80 00    	mov    0x803000,%esi
  802270:	e8 86 e8 ff ff       	call   800afb <sys_getenvid>
  802275:	83 ec 0c             	sub    $0xc,%esp
  802278:	ff 75 0c             	pushl  0xc(%ebp)
  80227b:	ff 75 08             	pushl  0x8(%ebp)
  80227e:	56                   	push   %esi
  80227f:	50                   	push   %eax
  802280:	68 34 2b 80 00       	push   $0x802b34
  802285:	e8 27 df ff ff       	call   8001b1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80228a:	83 c4 18             	add    $0x18,%esp
  80228d:	53                   	push   %ebx
  80228e:	ff 75 10             	pushl  0x10(%ebp)
  802291:	e8 ca de ff ff       	call   800160 <vcprintf>
	cprintf("\n");
  802296:	c7 04 24 20 2b 80 00 	movl   $0x802b20,(%esp)
  80229d:	e8 0f df ff ff       	call   8001b1 <cprintf>
  8022a2:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8022a5:	cc                   	int3   
  8022a6:	eb fd                	jmp    8022a5 <_panic+0x43>

008022a8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8022a8:	55                   	push   %ebp
  8022a9:	89 e5                	mov    %esp,%ebp
  8022ab:	53                   	push   %ebx
  8022ac:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  8022af:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8022b6:	75 28                	jne    8022e0 <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  8022b8:	e8 3e e8 ff ff       	call   800afb <sys_getenvid>
  8022bd:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_U | PTE_W);
  8022bf:	83 ec 04             	sub    $0x4,%esp
  8022c2:	6a 06                	push   $0x6
  8022c4:	68 00 f0 bf ee       	push   $0xeebff000
  8022c9:	50                   	push   %eax
  8022ca:	e8 6a e8 ff ff       	call   800b39 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  8022cf:	83 c4 08             	add    $0x8,%esp
  8022d2:	68 ed 22 80 00       	push   $0x8022ed
  8022d7:	53                   	push   %ebx
  8022d8:	e8 a7 e9 ff ff       	call   800c84 <sys_env_set_pgfault_upcall>
  8022dd:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8022e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8022e3:	a3 00 70 80 00       	mov    %eax,0x807000
}
  8022e8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8022eb:	c9                   	leave  
  8022ec:	c3                   	ret    

008022ed <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8022ed:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8022ee:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8022f3:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8022f5:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	# My method is different. Copy the values to the other stack
	# in a convinient way, and then pop everything.
	movl %esp, %ebp		# ebp refers to the exception stack
  8022f8:	89 e5                	mov    %esp,%ebp
	movl 48(%ebp), %esp 	# go to other stack
  8022fa:	8b 65 30             	mov    0x30(%ebp),%esp

	pushl 40(%ebp)		# eip - ORDER SWITCHED WITH EFLAGS
  8022fd:	ff 75 28             	pushl  0x28(%ebp)
	pushl 44(%ebp)      	# eflags
  802300:	ff 75 2c             	pushl  0x2c(%ebp)
	pushl 36(%ebp)		# all the 8 remaining regs
  802303:	ff 75 24             	pushl  0x24(%ebp)
	pushl 32(%ebp)
  802306:	ff 75 20             	pushl  0x20(%ebp)
	pushl 28(%ebp)
  802309:	ff 75 1c             	pushl  0x1c(%ebp)
	pushl 24(%ebp)
  80230c:	ff 75 18             	pushl  0x18(%ebp)
	pushl 20(%ebp)
  80230f:	ff 75 14             	pushl  0x14(%ebp)
	pushl 16(%ebp)
  802312:	ff 75 10             	pushl  0x10(%ebp)
	pushl 12(%ebp)
  802315:	ff 75 0c             	pushl  0xc(%ebp)
	pushl 8(%ebp)
  802318:	ff 75 08             	pushl  0x8(%ebp)

	popal			# now just pop everything!
  80231b:	61                   	popa   
	popfl
  80231c:	9d                   	popf   
	ret
  80231d:	c3                   	ret    

0080231e <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80231e:	55                   	push   %ebp
  80231f:	89 e5                	mov    %esp,%ebp
  802321:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802324:	89 d0                	mov    %edx,%eax
  802326:	c1 e8 16             	shr    $0x16,%eax
  802329:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802330:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802335:	f6 c1 01             	test   $0x1,%cl
  802338:	74 1d                	je     802357 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80233a:	c1 ea 0c             	shr    $0xc,%edx
  80233d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802344:	f6 c2 01             	test   $0x1,%dl
  802347:	74 0e                	je     802357 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802349:	c1 ea 0c             	shr    $0xc,%edx
  80234c:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802353:	ef 
  802354:	0f b7 c0             	movzwl %ax,%eax
}
  802357:	5d                   	pop    %ebp
  802358:	c3                   	ret    
  802359:	66 90                	xchg   %ax,%ax
  80235b:	66 90                	xchg   %ax,%ax
  80235d:	66 90                	xchg   %ax,%ax
  80235f:	90                   	nop

00802360 <__udivdi3>:
  802360:	55                   	push   %ebp
  802361:	57                   	push   %edi
  802362:	56                   	push   %esi
  802363:	53                   	push   %ebx
  802364:	83 ec 1c             	sub    $0x1c,%esp
  802367:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80236b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80236f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802373:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802377:	85 f6                	test   %esi,%esi
  802379:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80237d:	89 ca                	mov    %ecx,%edx
  80237f:	89 f8                	mov    %edi,%eax
  802381:	75 3d                	jne    8023c0 <__udivdi3+0x60>
  802383:	39 cf                	cmp    %ecx,%edi
  802385:	0f 87 c5 00 00 00    	ja     802450 <__udivdi3+0xf0>
  80238b:	85 ff                	test   %edi,%edi
  80238d:	89 fd                	mov    %edi,%ebp
  80238f:	75 0b                	jne    80239c <__udivdi3+0x3c>
  802391:	b8 01 00 00 00       	mov    $0x1,%eax
  802396:	31 d2                	xor    %edx,%edx
  802398:	f7 f7                	div    %edi
  80239a:	89 c5                	mov    %eax,%ebp
  80239c:	89 c8                	mov    %ecx,%eax
  80239e:	31 d2                	xor    %edx,%edx
  8023a0:	f7 f5                	div    %ebp
  8023a2:	89 c1                	mov    %eax,%ecx
  8023a4:	89 d8                	mov    %ebx,%eax
  8023a6:	89 cf                	mov    %ecx,%edi
  8023a8:	f7 f5                	div    %ebp
  8023aa:	89 c3                	mov    %eax,%ebx
  8023ac:	89 d8                	mov    %ebx,%eax
  8023ae:	89 fa                	mov    %edi,%edx
  8023b0:	83 c4 1c             	add    $0x1c,%esp
  8023b3:	5b                   	pop    %ebx
  8023b4:	5e                   	pop    %esi
  8023b5:	5f                   	pop    %edi
  8023b6:	5d                   	pop    %ebp
  8023b7:	c3                   	ret    
  8023b8:	90                   	nop
  8023b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023c0:	39 ce                	cmp    %ecx,%esi
  8023c2:	77 74                	ja     802438 <__udivdi3+0xd8>
  8023c4:	0f bd fe             	bsr    %esi,%edi
  8023c7:	83 f7 1f             	xor    $0x1f,%edi
  8023ca:	0f 84 98 00 00 00    	je     802468 <__udivdi3+0x108>
  8023d0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8023d5:	89 f9                	mov    %edi,%ecx
  8023d7:	89 c5                	mov    %eax,%ebp
  8023d9:	29 fb                	sub    %edi,%ebx
  8023db:	d3 e6                	shl    %cl,%esi
  8023dd:	89 d9                	mov    %ebx,%ecx
  8023df:	d3 ed                	shr    %cl,%ebp
  8023e1:	89 f9                	mov    %edi,%ecx
  8023e3:	d3 e0                	shl    %cl,%eax
  8023e5:	09 ee                	or     %ebp,%esi
  8023e7:	89 d9                	mov    %ebx,%ecx
  8023e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023ed:	89 d5                	mov    %edx,%ebp
  8023ef:	8b 44 24 08          	mov    0x8(%esp),%eax
  8023f3:	d3 ed                	shr    %cl,%ebp
  8023f5:	89 f9                	mov    %edi,%ecx
  8023f7:	d3 e2                	shl    %cl,%edx
  8023f9:	89 d9                	mov    %ebx,%ecx
  8023fb:	d3 e8                	shr    %cl,%eax
  8023fd:	09 c2                	or     %eax,%edx
  8023ff:	89 d0                	mov    %edx,%eax
  802401:	89 ea                	mov    %ebp,%edx
  802403:	f7 f6                	div    %esi
  802405:	89 d5                	mov    %edx,%ebp
  802407:	89 c3                	mov    %eax,%ebx
  802409:	f7 64 24 0c          	mull   0xc(%esp)
  80240d:	39 d5                	cmp    %edx,%ebp
  80240f:	72 10                	jb     802421 <__udivdi3+0xc1>
  802411:	8b 74 24 08          	mov    0x8(%esp),%esi
  802415:	89 f9                	mov    %edi,%ecx
  802417:	d3 e6                	shl    %cl,%esi
  802419:	39 c6                	cmp    %eax,%esi
  80241b:	73 07                	jae    802424 <__udivdi3+0xc4>
  80241d:	39 d5                	cmp    %edx,%ebp
  80241f:	75 03                	jne    802424 <__udivdi3+0xc4>
  802421:	83 eb 01             	sub    $0x1,%ebx
  802424:	31 ff                	xor    %edi,%edi
  802426:	89 d8                	mov    %ebx,%eax
  802428:	89 fa                	mov    %edi,%edx
  80242a:	83 c4 1c             	add    $0x1c,%esp
  80242d:	5b                   	pop    %ebx
  80242e:	5e                   	pop    %esi
  80242f:	5f                   	pop    %edi
  802430:	5d                   	pop    %ebp
  802431:	c3                   	ret    
  802432:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802438:	31 ff                	xor    %edi,%edi
  80243a:	31 db                	xor    %ebx,%ebx
  80243c:	89 d8                	mov    %ebx,%eax
  80243e:	89 fa                	mov    %edi,%edx
  802440:	83 c4 1c             	add    $0x1c,%esp
  802443:	5b                   	pop    %ebx
  802444:	5e                   	pop    %esi
  802445:	5f                   	pop    %edi
  802446:	5d                   	pop    %ebp
  802447:	c3                   	ret    
  802448:	90                   	nop
  802449:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802450:	89 d8                	mov    %ebx,%eax
  802452:	f7 f7                	div    %edi
  802454:	31 ff                	xor    %edi,%edi
  802456:	89 c3                	mov    %eax,%ebx
  802458:	89 d8                	mov    %ebx,%eax
  80245a:	89 fa                	mov    %edi,%edx
  80245c:	83 c4 1c             	add    $0x1c,%esp
  80245f:	5b                   	pop    %ebx
  802460:	5e                   	pop    %esi
  802461:	5f                   	pop    %edi
  802462:	5d                   	pop    %ebp
  802463:	c3                   	ret    
  802464:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802468:	39 ce                	cmp    %ecx,%esi
  80246a:	72 0c                	jb     802478 <__udivdi3+0x118>
  80246c:	31 db                	xor    %ebx,%ebx
  80246e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802472:	0f 87 34 ff ff ff    	ja     8023ac <__udivdi3+0x4c>
  802478:	bb 01 00 00 00       	mov    $0x1,%ebx
  80247d:	e9 2a ff ff ff       	jmp    8023ac <__udivdi3+0x4c>
  802482:	66 90                	xchg   %ax,%ax
  802484:	66 90                	xchg   %ax,%ax
  802486:	66 90                	xchg   %ax,%ax
  802488:	66 90                	xchg   %ax,%ax
  80248a:	66 90                	xchg   %ax,%ax
  80248c:	66 90                	xchg   %ax,%ax
  80248e:	66 90                	xchg   %ax,%ax

00802490 <__umoddi3>:
  802490:	55                   	push   %ebp
  802491:	57                   	push   %edi
  802492:	56                   	push   %esi
  802493:	53                   	push   %ebx
  802494:	83 ec 1c             	sub    $0x1c,%esp
  802497:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80249b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80249f:	8b 74 24 34          	mov    0x34(%esp),%esi
  8024a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8024a7:	85 d2                	test   %edx,%edx
  8024a9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8024ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024b1:	89 f3                	mov    %esi,%ebx
  8024b3:	89 3c 24             	mov    %edi,(%esp)
  8024b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024ba:	75 1c                	jne    8024d8 <__umoddi3+0x48>
  8024bc:	39 f7                	cmp    %esi,%edi
  8024be:	76 50                	jbe    802510 <__umoddi3+0x80>
  8024c0:	89 c8                	mov    %ecx,%eax
  8024c2:	89 f2                	mov    %esi,%edx
  8024c4:	f7 f7                	div    %edi
  8024c6:	89 d0                	mov    %edx,%eax
  8024c8:	31 d2                	xor    %edx,%edx
  8024ca:	83 c4 1c             	add    $0x1c,%esp
  8024cd:	5b                   	pop    %ebx
  8024ce:	5e                   	pop    %esi
  8024cf:	5f                   	pop    %edi
  8024d0:	5d                   	pop    %ebp
  8024d1:	c3                   	ret    
  8024d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8024d8:	39 f2                	cmp    %esi,%edx
  8024da:	89 d0                	mov    %edx,%eax
  8024dc:	77 52                	ja     802530 <__umoddi3+0xa0>
  8024de:	0f bd ea             	bsr    %edx,%ebp
  8024e1:	83 f5 1f             	xor    $0x1f,%ebp
  8024e4:	75 5a                	jne    802540 <__umoddi3+0xb0>
  8024e6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8024ea:	0f 82 e0 00 00 00    	jb     8025d0 <__umoddi3+0x140>
  8024f0:	39 0c 24             	cmp    %ecx,(%esp)
  8024f3:	0f 86 d7 00 00 00    	jbe    8025d0 <__umoddi3+0x140>
  8024f9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8024fd:	8b 54 24 04          	mov    0x4(%esp),%edx
  802501:	83 c4 1c             	add    $0x1c,%esp
  802504:	5b                   	pop    %ebx
  802505:	5e                   	pop    %esi
  802506:	5f                   	pop    %edi
  802507:	5d                   	pop    %ebp
  802508:	c3                   	ret    
  802509:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802510:	85 ff                	test   %edi,%edi
  802512:	89 fd                	mov    %edi,%ebp
  802514:	75 0b                	jne    802521 <__umoddi3+0x91>
  802516:	b8 01 00 00 00       	mov    $0x1,%eax
  80251b:	31 d2                	xor    %edx,%edx
  80251d:	f7 f7                	div    %edi
  80251f:	89 c5                	mov    %eax,%ebp
  802521:	89 f0                	mov    %esi,%eax
  802523:	31 d2                	xor    %edx,%edx
  802525:	f7 f5                	div    %ebp
  802527:	89 c8                	mov    %ecx,%eax
  802529:	f7 f5                	div    %ebp
  80252b:	89 d0                	mov    %edx,%eax
  80252d:	eb 99                	jmp    8024c8 <__umoddi3+0x38>
  80252f:	90                   	nop
  802530:	89 c8                	mov    %ecx,%eax
  802532:	89 f2                	mov    %esi,%edx
  802534:	83 c4 1c             	add    $0x1c,%esp
  802537:	5b                   	pop    %ebx
  802538:	5e                   	pop    %esi
  802539:	5f                   	pop    %edi
  80253a:	5d                   	pop    %ebp
  80253b:	c3                   	ret    
  80253c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802540:	8b 34 24             	mov    (%esp),%esi
  802543:	bf 20 00 00 00       	mov    $0x20,%edi
  802548:	89 e9                	mov    %ebp,%ecx
  80254a:	29 ef                	sub    %ebp,%edi
  80254c:	d3 e0                	shl    %cl,%eax
  80254e:	89 f9                	mov    %edi,%ecx
  802550:	89 f2                	mov    %esi,%edx
  802552:	d3 ea                	shr    %cl,%edx
  802554:	89 e9                	mov    %ebp,%ecx
  802556:	09 c2                	or     %eax,%edx
  802558:	89 d8                	mov    %ebx,%eax
  80255a:	89 14 24             	mov    %edx,(%esp)
  80255d:	89 f2                	mov    %esi,%edx
  80255f:	d3 e2                	shl    %cl,%edx
  802561:	89 f9                	mov    %edi,%ecx
  802563:	89 54 24 04          	mov    %edx,0x4(%esp)
  802567:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80256b:	d3 e8                	shr    %cl,%eax
  80256d:	89 e9                	mov    %ebp,%ecx
  80256f:	89 c6                	mov    %eax,%esi
  802571:	d3 e3                	shl    %cl,%ebx
  802573:	89 f9                	mov    %edi,%ecx
  802575:	89 d0                	mov    %edx,%eax
  802577:	d3 e8                	shr    %cl,%eax
  802579:	89 e9                	mov    %ebp,%ecx
  80257b:	09 d8                	or     %ebx,%eax
  80257d:	89 d3                	mov    %edx,%ebx
  80257f:	89 f2                	mov    %esi,%edx
  802581:	f7 34 24             	divl   (%esp)
  802584:	89 d6                	mov    %edx,%esi
  802586:	d3 e3                	shl    %cl,%ebx
  802588:	f7 64 24 04          	mull   0x4(%esp)
  80258c:	39 d6                	cmp    %edx,%esi
  80258e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802592:	89 d1                	mov    %edx,%ecx
  802594:	89 c3                	mov    %eax,%ebx
  802596:	72 08                	jb     8025a0 <__umoddi3+0x110>
  802598:	75 11                	jne    8025ab <__umoddi3+0x11b>
  80259a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80259e:	73 0b                	jae    8025ab <__umoddi3+0x11b>
  8025a0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8025a4:	1b 14 24             	sbb    (%esp),%edx
  8025a7:	89 d1                	mov    %edx,%ecx
  8025a9:	89 c3                	mov    %eax,%ebx
  8025ab:	8b 54 24 08          	mov    0x8(%esp),%edx
  8025af:	29 da                	sub    %ebx,%edx
  8025b1:	19 ce                	sbb    %ecx,%esi
  8025b3:	89 f9                	mov    %edi,%ecx
  8025b5:	89 f0                	mov    %esi,%eax
  8025b7:	d3 e0                	shl    %cl,%eax
  8025b9:	89 e9                	mov    %ebp,%ecx
  8025bb:	d3 ea                	shr    %cl,%edx
  8025bd:	89 e9                	mov    %ebp,%ecx
  8025bf:	d3 ee                	shr    %cl,%esi
  8025c1:	09 d0                	or     %edx,%eax
  8025c3:	89 f2                	mov    %esi,%edx
  8025c5:	83 c4 1c             	add    $0x1c,%esp
  8025c8:	5b                   	pop    %ebx
  8025c9:	5e                   	pop    %esi
  8025ca:	5f                   	pop    %edi
  8025cb:	5d                   	pop    %ebp
  8025cc:	c3                   	ret    
  8025cd:	8d 76 00             	lea    0x0(%esi),%esi
  8025d0:	29 f9                	sub    %edi,%ecx
  8025d2:	19 d6                	sbb    %edx,%esi
  8025d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8025d8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8025dc:	e9 18 ff ff ff       	jmp    8024f9 <__umoddi3+0x69>
