
obj/user/spin.debug:     file format elf32-i386


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
  80002c:	e8 84 00 00 00       	call   8000b5 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 10             	sub    $0x10,%esp
	envid_t env;

	cprintf("I am the parent.  Forking the child...\n");
  80003a:	68 60 21 80 00       	push   $0x802160
  80003f:	e8 64 01 00 00       	call   8001a8 <cprintf>
	if ((env = fork()) == 0) {
  800044:	e8 8c 0e 00 00       	call   800ed5 <fork>
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	85 c0                	test   %eax,%eax
  80004e:	75 12                	jne    800062 <umain+0x2f>
		cprintf("I am the child.  Spinning...\n");
  800050:	83 ec 0c             	sub    $0xc,%esp
  800053:	68 d8 21 80 00       	push   $0x8021d8
  800058:	e8 4b 01 00 00       	call   8001a8 <cprintf>
  80005d:	83 c4 10             	add    $0x10,%esp
  800060:	eb fe                	jmp    800060 <umain+0x2d>
  800062:	89 c3                	mov    %eax,%ebx
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  800064:	83 ec 0c             	sub    $0xc,%esp
  800067:	68 88 21 80 00       	push   $0x802188
  80006c:	e8 37 01 00 00       	call   8001a8 <cprintf>
	sys_yield();
  800071:	e8 9b 0a 00 00       	call   800b11 <sys_yield>
	sys_yield();
  800076:	e8 96 0a 00 00       	call   800b11 <sys_yield>
	sys_yield();
  80007b:	e8 91 0a 00 00       	call   800b11 <sys_yield>
	sys_yield();
  800080:	e8 8c 0a 00 00       	call   800b11 <sys_yield>
	sys_yield();
  800085:	e8 87 0a 00 00       	call   800b11 <sys_yield>
	sys_yield();
  80008a:	e8 82 0a 00 00       	call   800b11 <sys_yield>
	sys_yield();
  80008f:	e8 7d 0a 00 00       	call   800b11 <sys_yield>
	sys_yield();
  800094:	e8 78 0a 00 00       	call   800b11 <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  800099:	c7 04 24 b0 21 80 00 	movl   $0x8021b0,(%esp)
  8000a0:	e8 03 01 00 00       	call   8001a8 <cprintf>
	sys_env_destroy(env);
  8000a5:	89 1c 24             	mov    %ebx,(%esp)
  8000a8:	e8 04 0a 00 00       	call   800ab1 <sys_env_destroy>
}
  8000ad:	83 c4 10             	add    $0x10,%esp
  8000b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000b3:	c9                   	leave  
  8000b4:	c3                   	ret    

008000b5 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
  8000ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000bd:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000c0:	e8 2d 0a 00 00       	call   800af2 <sys_getenvid>
  8000c5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ca:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000cd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d2:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000d7:	85 db                	test   %ebx,%ebx
  8000d9:	7e 07                	jle    8000e2 <libmain+0x2d>
		binaryname = argv[0];
  8000db:	8b 06                	mov    (%esi),%eax
  8000dd:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000e2:	83 ec 08             	sub    $0x8,%esp
  8000e5:	56                   	push   %esi
  8000e6:	53                   	push   %ebx
  8000e7:	e8 47 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000ec:	e8 0a 00 00 00       	call   8000fb <exit>
}
  8000f1:	83 c4 10             	add    $0x10,%esp
  8000f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000f7:	5b                   	pop    %ebx
  8000f8:	5e                   	pop    %esi
  8000f9:	5d                   	pop    %ebp
  8000fa:	c3                   	ret    

008000fb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000fb:	55                   	push   %ebp
  8000fc:	89 e5                	mov    %esp,%ebp
  8000fe:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800101:	e8 8f 10 00 00       	call   801195 <close_all>
	sys_env_destroy(0);
  800106:	83 ec 0c             	sub    $0xc,%esp
  800109:	6a 00                	push   $0x0
  80010b:	e8 a1 09 00 00       	call   800ab1 <sys_env_destroy>
}
  800110:	83 c4 10             	add    $0x10,%esp
  800113:	c9                   	leave  
  800114:	c3                   	ret    

00800115 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800115:	55                   	push   %ebp
  800116:	89 e5                	mov    %esp,%ebp
  800118:	53                   	push   %ebx
  800119:	83 ec 04             	sub    $0x4,%esp
  80011c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80011f:	8b 13                	mov    (%ebx),%edx
  800121:	8d 42 01             	lea    0x1(%edx),%eax
  800124:	89 03                	mov    %eax,(%ebx)
  800126:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800129:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80012d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800132:	75 1a                	jne    80014e <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800134:	83 ec 08             	sub    $0x8,%esp
  800137:	68 ff 00 00 00       	push   $0xff
  80013c:	8d 43 08             	lea    0x8(%ebx),%eax
  80013f:	50                   	push   %eax
  800140:	e8 2f 09 00 00       	call   800a74 <sys_cputs>
		b->idx = 0;
  800145:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80014b:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80014e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800152:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800155:	c9                   	leave  
  800156:	c3                   	ret    

00800157 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800157:	55                   	push   %ebp
  800158:	89 e5                	mov    %esp,%ebp
  80015a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800160:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800167:	00 00 00 
	b.cnt = 0;
  80016a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800171:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800174:	ff 75 0c             	pushl  0xc(%ebp)
  800177:	ff 75 08             	pushl  0x8(%ebp)
  80017a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800180:	50                   	push   %eax
  800181:	68 15 01 80 00       	push   $0x800115
  800186:	e8 54 01 00 00       	call   8002df <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80018b:	83 c4 08             	add    $0x8,%esp
  80018e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800194:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80019a:	50                   	push   %eax
  80019b:	e8 d4 08 00 00       	call   800a74 <sys_cputs>

	return b.cnt;
}
  8001a0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001a6:	c9                   	leave  
  8001a7:	c3                   	ret    

008001a8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
  8001ab:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ae:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001b1:	50                   	push   %eax
  8001b2:	ff 75 08             	pushl  0x8(%ebp)
  8001b5:	e8 9d ff ff ff       	call   800157 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001ba:	c9                   	leave  
  8001bb:	c3                   	ret    

008001bc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001bc:	55                   	push   %ebp
  8001bd:	89 e5                	mov    %esp,%ebp
  8001bf:	57                   	push   %edi
  8001c0:	56                   	push   %esi
  8001c1:	53                   	push   %ebx
  8001c2:	83 ec 1c             	sub    $0x1c,%esp
  8001c5:	89 c7                	mov    %eax,%edi
  8001c7:	89 d6                	mov    %edx,%esi
  8001c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8001cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001cf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001d2:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001d5:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001d8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001dd:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001e0:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001e3:	39 d3                	cmp    %edx,%ebx
  8001e5:	72 05                	jb     8001ec <printnum+0x30>
  8001e7:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001ea:	77 45                	ja     800231 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001ec:	83 ec 0c             	sub    $0xc,%esp
  8001ef:	ff 75 18             	pushl  0x18(%ebp)
  8001f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8001f5:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001f8:	53                   	push   %ebx
  8001f9:	ff 75 10             	pushl  0x10(%ebp)
  8001fc:	83 ec 08             	sub    $0x8,%esp
  8001ff:	ff 75 e4             	pushl  -0x1c(%ebp)
  800202:	ff 75 e0             	pushl  -0x20(%ebp)
  800205:	ff 75 dc             	pushl  -0x24(%ebp)
  800208:	ff 75 d8             	pushl  -0x28(%ebp)
  80020b:	e8 c0 1c 00 00       	call   801ed0 <__udivdi3>
  800210:	83 c4 18             	add    $0x18,%esp
  800213:	52                   	push   %edx
  800214:	50                   	push   %eax
  800215:	89 f2                	mov    %esi,%edx
  800217:	89 f8                	mov    %edi,%eax
  800219:	e8 9e ff ff ff       	call   8001bc <printnum>
  80021e:	83 c4 20             	add    $0x20,%esp
  800221:	eb 18                	jmp    80023b <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800223:	83 ec 08             	sub    $0x8,%esp
  800226:	56                   	push   %esi
  800227:	ff 75 18             	pushl  0x18(%ebp)
  80022a:	ff d7                	call   *%edi
  80022c:	83 c4 10             	add    $0x10,%esp
  80022f:	eb 03                	jmp    800234 <printnum+0x78>
  800231:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800234:	83 eb 01             	sub    $0x1,%ebx
  800237:	85 db                	test   %ebx,%ebx
  800239:	7f e8                	jg     800223 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80023b:	83 ec 08             	sub    $0x8,%esp
  80023e:	56                   	push   %esi
  80023f:	83 ec 04             	sub    $0x4,%esp
  800242:	ff 75 e4             	pushl  -0x1c(%ebp)
  800245:	ff 75 e0             	pushl  -0x20(%ebp)
  800248:	ff 75 dc             	pushl  -0x24(%ebp)
  80024b:	ff 75 d8             	pushl  -0x28(%ebp)
  80024e:	e8 ad 1d 00 00       	call   802000 <__umoddi3>
  800253:	83 c4 14             	add    $0x14,%esp
  800256:	0f be 80 00 22 80 00 	movsbl 0x802200(%eax),%eax
  80025d:	50                   	push   %eax
  80025e:	ff d7                	call   *%edi
}
  800260:	83 c4 10             	add    $0x10,%esp
  800263:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800266:	5b                   	pop    %ebx
  800267:	5e                   	pop    %esi
  800268:	5f                   	pop    %edi
  800269:	5d                   	pop    %ebp
  80026a:	c3                   	ret    

0080026b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80026b:	55                   	push   %ebp
  80026c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80026e:	83 fa 01             	cmp    $0x1,%edx
  800271:	7e 0e                	jle    800281 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800273:	8b 10                	mov    (%eax),%edx
  800275:	8d 4a 08             	lea    0x8(%edx),%ecx
  800278:	89 08                	mov    %ecx,(%eax)
  80027a:	8b 02                	mov    (%edx),%eax
  80027c:	8b 52 04             	mov    0x4(%edx),%edx
  80027f:	eb 22                	jmp    8002a3 <getuint+0x38>
	else if (lflag)
  800281:	85 d2                	test   %edx,%edx
  800283:	74 10                	je     800295 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800285:	8b 10                	mov    (%eax),%edx
  800287:	8d 4a 04             	lea    0x4(%edx),%ecx
  80028a:	89 08                	mov    %ecx,(%eax)
  80028c:	8b 02                	mov    (%edx),%eax
  80028e:	ba 00 00 00 00       	mov    $0x0,%edx
  800293:	eb 0e                	jmp    8002a3 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800295:	8b 10                	mov    (%eax),%edx
  800297:	8d 4a 04             	lea    0x4(%edx),%ecx
  80029a:	89 08                	mov    %ecx,(%eax)
  80029c:	8b 02                	mov    (%edx),%eax
  80029e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002a3:	5d                   	pop    %ebp
  8002a4:	c3                   	ret    

008002a5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002a5:	55                   	push   %ebp
  8002a6:	89 e5                	mov    %esp,%ebp
  8002a8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002ab:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002af:	8b 10                	mov    (%eax),%edx
  8002b1:	3b 50 04             	cmp    0x4(%eax),%edx
  8002b4:	73 0a                	jae    8002c0 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002b6:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002b9:	89 08                	mov    %ecx,(%eax)
  8002bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8002be:	88 02                	mov    %al,(%edx)
}
  8002c0:	5d                   	pop    %ebp
  8002c1:	c3                   	ret    

008002c2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002c2:	55                   	push   %ebp
  8002c3:	89 e5                	mov    %esp,%ebp
  8002c5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002c8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002cb:	50                   	push   %eax
  8002cc:	ff 75 10             	pushl  0x10(%ebp)
  8002cf:	ff 75 0c             	pushl  0xc(%ebp)
  8002d2:	ff 75 08             	pushl  0x8(%ebp)
  8002d5:	e8 05 00 00 00       	call   8002df <vprintfmt>
	va_end(ap);
}
  8002da:	83 c4 10             	add    $0x10,%esp
  8002dd:	c9                   	leave  
  8002de:	c3                   	ret    

008002df <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002df:	55                   	push   %ebp
  8002e0:	89 e5                	mov    %esp,%ebp
  8002e2:	57                   	push   %edi
  8002e3:	56                   	push   %esi
  8002e4:	53                   	push   %ebx
  8002e5:	83 ec 2c             	sub    $0x2c,%esp
  8002e8:	8b 75 08             	mov    0x8(%ebp),%esi
  8002eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002ee:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002f1:	eb 12                	jmp    800305 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002f3:	85 c0                	test   %eax,%eax
  8002f5:	0f 84 89 03 00 00    	je     800684 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8002fb:	83 ec 08             	sub    $0x8,%esp
  8002fe:	53                   	push   %ebx
  8002ff:	50                   	push   %eax
  800300:	ff d6                	call   *%esi
  800302:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800305:	83 c7 01             	add    $0x1,%edi
  800308:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80030c:	83 f8 25             	cmp    $0x25,%eax
  80030f:	75 e2                	jne    8002f3 <vprintfmt+0x14>
  800311:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800315:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80031c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800323:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80032a:	ba 00 00 00 00       	mov    $0x0,%edx
  80032f:	eb 07                	jmp    800338 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800331:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800334:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800338:	8d 47 01             	lea    0x1(%edi),%eax
  80033b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80033e:	0f b6 07             	movzbl (%edi),%eax
  800341:	0f b6 c8             	movzbl %al,%ecx
  800344:	83 e8 23             	sub    $0x23,%eax
  800347:	3c 55                	cmp    $0x55,%al
  800349:	0f 87 1a 03 00 00    	ja     800669 <vprintfmt+0x38a>
  80034f:	0f b6 c0             	movzbl %al,%eax
  800352:	ff 24 85 40 23 80 00 	jmp    *0x802340(,%eax,4)
  800359:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80035c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800360:	eb d6                	jmp    800338 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800362:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800365:	b8 00 00 00 00       	mov    $0x0,%eax
  80036a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80036d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800370:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800374:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800377:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80037a:	83 fa 09             	cmp    $0x9,%edx
  80037d:	77 39                	ja     8003b8 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80037f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800382:	eb e9                	jmp    80036d <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800384:	8b 45 14             	mov    0x14(%ebp),%eax
  800387:	8d 48 04             	lea    0x4(%eax),%ecx
  80038a:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80038d:	8b 00                	mov    (%eax),%eax
  80038f:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800392:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800395:	eb 27                	jmp    8003be <vprintfmt+0xdf>
  800397:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80039a:	85 c0                	test   %eax,%eax
  80039c:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003a1:	0f 49 c8             	cmovns %eax,%ecx
  8003a4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003aa:	eb 8c                	jmp    800338 <vprintfmt+0x59>
  8003ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003af:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003b6:	eb 80                	jmp    800338 <vprintfmt+0x59>
  8003b8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003bb:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003be:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003c2:	0f 89 70 ff ff ff    	jns    800338 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003c8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003cb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003ce:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003d5:	e9 5e ff ff ff       	jmp    800338 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003da:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003e0:	e9 53 ff ff ff       	jmp    800338 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e8:	8d 50 04             	lea    0x4(%eax),%edx
  8003eb:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ee:	83 ec 08             	sub    $0x8,%esp
  8003f1:	53                   	push   %ebx
  8003f2:	ff 30                	pushl  (%eax)
  8003f4:	ff d6                	call   *%esi
			break;
  8003f6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003fc:	e9 04 ff ff ff       	jmp    800305 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800401:	8b 45 14             	mov    0x14(%ebp),%eax
  800404:	8d 50 04             	lea    0x4(%eax),%edx
  800407:	89 55 14             	mov    %edx,0x14(%ebp)
  80040a:	8b 00                	mov    (%eax),%eax
  80040c:	99                   	cltd   
  80040d:	31 d0                	xor    %edx,%eax
  80040f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800411:	83 f8 0f             	cmp    $0xf,%eax
  800414:	7f 0b                	jg     800421 <vprintfmt+0x142>
  800416:	8b 14 85 a0 24 80 00 	mov    0x8024a0(,%eax,4),%edx
  80041d:	85 d2                	test   %edx,%edx
  80041f:	75 18                	jne    800439 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800421:	50                   	push   %eax
  800422:	68 18 22 80 00       	push   $0x802218
  800427:	53                   	push   %ebx
  800428:	56                   	push   %esi
  800429:	e8 94 fe ff ff       	call   8002c2 <printfmt>
  80042e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800431:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800434:	e9 cc fe ff ff       	jmp    800305 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800439:	52                   	push   %edx
  80043a:	68 56 26 80 00       	push   $0x802656
  80043f:	53                   	push   %ebx
  800440:	56                   	push   %esi
  800441:	e8 7c fe ff ff       	call   8002c2 <printfmt>
  800446:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800449:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80044c:	e9 b4 fe ff ff       	jmp    800305 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800451:	8b 45 14             	mov    0x14(%ebp),%eax
  800454:	8d 50 04             	lea    0x4(%eax),%edx
  800457:	89 55 14             	mov    %edx,0x14(%ebp)
  80045a:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80045c:	85 ff                	test   %edi,%edi
  80045e:	b8 11 22 80 00       	mov    $0x802211,%eax
  800463:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800466:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80046a:	0f 8e 94 00 00 00    	jle    800504 <vprintfmt+0x225>
  800470:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800474:	0f 84 98 00 00 00    	je     800512 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80047a:	83 ec 08             	sub    $0x8,%esp
  80047d:	ff 75 d0             	pushl  -0x30(%ebp)
  800480:	57                   	push   %edi
  800481:	e8 86 02 00 00       	call   80070c <strnlen>
  800486:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800489:	29 c1                	sub    %eax,%ecx
  80048b:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80048e:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800491:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800495:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800498:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80049b:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80049d:	eb 0f                	jmp    8004ae <vprintfmt+0x1cf>
					putch(padc, putdat);
  80049f:	83 ec 08             	sub    $0x8,%esp
  8004a2:	53                   	push   %ebx
  8004a3:	ff 75 e0             	pushl  -0x20(%ebp)
  8004a6:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a8:	83 ef 01             	sub    $0x1,%edi
  8004ab:	83 c4 10             	add    $0x10,%esp
  8004ae:	85 ff                	test   %edi,%edi
  8004b0:	7f ed                	jg     80049f <vprintfmt+0x1c0>
  8004b2:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004b5:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004b8:	85 c9                	test   %ecx,%ecx
  8004ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8004bf:	0f 49 c1             	cmovns %ecx,%eax
  8004c2:	29 c1                	sub    %eax,%ecx
  8004c4:	89 75 08             	mov    %esi,0x8(%ebp)
  8004c7:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004ca:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004cd:	89 cb                	mov    %ecx,%ebx
  8004cf:	eb 4d                	jmp    80051e <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004d1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004d5:	74 1b                	je     8004f2 <vprintfmt+0x213>
  8004d7:	0f be c0             	movsbl %al,%eax
  8004da:	83 e8 20             	sub    $0x20,%eax
  8004dd:	83 f8 5e             	cmp    $0x5e,%eax
  8004e0:	76 10                	jbe    8004f2 <vprintfmt+0x213>
					putch('?', putdat);
  8004e2:	83 ec 08             	sub    $0x8,%esp
  8004e5:	ff 75 0c             	pushl  0xc(%ebp)
  8004e8:	6a 3f                	push   $0x3f
  8004ea:	ff 55 08             	call   *0x8(%ebp)
  8004ed:	83 c4 10             	add    $0x10,%esp
  8004f0:	eb 0d                	jmp    8004ff <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004f2:	83 ec 08             	sub    $0x8,%esp
  8004f5:	ff 75 0c             	pushl  0xc(%ebp)
  8004f8:	52                   	push   %edx
  8004f9:	ff 55 08             	call   *0x8(%ebp)
  8004fc:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ff:	83 eb 01             	sub    $0x1,%ebx
  800502:	eb 1a                	jmp    80051e <vprintfmt+0x23f>
  800504:	89 75 08             	mov    %esi,0x8(%ebp)
  800507:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80050a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80050d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800510:	eb 0c                	jmp    80051e <vprintfmt+0x23f>
  800512:	89 75 08             	mov    %esi,0x8(%ebp)
  800515:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800518:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80051b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80051e:	83 c7 01             	add    $0x1,%edi
  800521:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800525:	0f be d0             	movsbl %al,%edx
  800528:	85 d2                	test   %edx,%edx
  80052a:	74 23                	je     80054f <vprintfmt+0x270>
  80052c:	85 f6                	test   %esi,%esi
  80052e:	78 a1                	js     8004d1 <vprintfmt+0x1f2>
  800530:	83 ee 01             	sub    $0x1,%esi
  800533:	79 9c                	jns    8004d1 <vprintfmt+0x1f2>
  800535:	89 df                	mov    %ebx,%edi
  800537:	8b 75 08             	mov    0x8(%ebp),%esi
  80053a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80053d:	eb 18                	jmp    800557 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80053f:	83 ec 08             	sub    $0x8,%esp
  800542:	53                   	push   %ebx
  800543:	6a 20                	push   $0x20
  800545:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800547:	83 ef 01             	sub    $0x1,%edi
  80054a:	83 c4 10             	add    $0x10,%esp
  80054d:	eb 08                	jmp    800557 <vprintfmt+0x278>
  80054f:	89 df                	mov    %ebx,%edi
  800551:	8b 75 08             	mov    0x8(%ebp),%esi
  800554:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800557:	85 ff                	test   %edi,%edi
  800559:	7f e4                	jg     80053f <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80055e:	e9 a2 fd ff ff       	jmp    800305 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800563:	83 fa 01             	cmp    $0x1,%edx
  800566:	7e 16                	jle    80057e <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800568:	8b 45 14             	mov    0x14(%ebp),%eax
  80056b:	8d 50 08             	lea    0x8(%eax),%edx
  80056e:	89 55 14             	mov    %edx,0x14(%ebp)
  800571:	8b 50 04             	mov    0x4(%eax),%edx
  800574:	8b 00                	mov    (%eax),%eax
  800576:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800579:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80057c:	eb 32                	jmp    8005b0 <vprintfmt+0x2d1>
	else if (lflag)
  80057e:	85 d2                	test   %edx,%edx
  800580:	74 18                	je     80059a <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800582:	8b 45 14             	mov    0x14(%ebp),%eax
  800585:	8d 50 04             	lea    0x4(%eax),%edx
  800588:	89 55 14             	mov    %edx,0x14(%ebp)
  80058b:	8b 00                	mov    (%eax),%eax
  80058d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800590:	89 c1                	mov    %eax,%ecx
  800592:	c1 f9 1f             	sar    $0x1f,%ecx
  800595:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800598:	eb 16                	jmp    8005b0 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80059a:	8b 45 14             	mov    0x14(%ebp),%eax
  80059d:	8d 50 04             	lea    0x4(%eax),%edx
  8005a0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a3:	8b 00                	mov    (%eax),%eax
  8005a5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a8:	89 c1                	mov    %eax,%ecx
  8005aa:	c1 f9 1f             	sar    $0x1f,%ecx
  8005ad:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005b0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005b3:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005b6:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005bb:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005bf:	79 74                	jns    800635 <vprintfmt+0x356>
				putch('-', putdat);
  8005c1:	83 ec 08             	sub    $0x8,%esp
  8005c4:	53                   	push   %ebx
  8005c5:	6a 2d                	push   $0x2d
  8005c7:	ff d6                	call   *%esi
				num = -(long long) num;
  8005c9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005cc:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005cf:	f7 d8                	neg    %eax
  8005d1:	83 d2 00             	adc    $0x0,%edx
  8005d4:	f7 da                	neg    %edx
  8005d6:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005d9:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005de:	eb 55                	jmp    800635 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005e0:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e3:	e8 83 fc ff ff       	call   80026b <getuint>
			base = 10;
  8005e8:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005ed:	eb 46                	jmp    800635 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005ef:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f2:	e8 74 fc ff ff       	call   80026b <getuint>
                        base = 8;
  8005f7:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  8005fc:	eb 37                	jmp    800635 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8005fe:	83 ec 08             	sub    $0x8,%esp
  800601:	53                   	push   %ebx
  800602:	6a 30                	push   $0x30
  800604:	ff d6                	call   *%esi
			putch('x', putdat);
  800606:	83 c4 08             	add    $0x8,%esp
  800609:	53                   	push   %ebx
  80060a:	6a 78                	push   $0x78
  80060c:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80060e:	8b 45 14             	mov    0x14(%ebp),%eax
  800611:	8d 50 04             	lea    0x4(%eax),%edx
  800614:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800617:	8b 00                	mov    (%eax),%eax
  800619:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80061e:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800621:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800626:	eb 0d                	jmp    800635 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800628:	8d 45 14             	lea    0x14(%ebp),%eax
  80062b:	e8 3b fc ff ff       	call   80026b <getuint>
			base = 16;
  800630:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800635:	83 ec 0c             	sub    $0xc,%esp
  800638:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80063c:	57                   	push   %edi
  80063d:	ff 75 e0             	pushl  -0x20(%ebp)
  800640:	51                   	push   %ecx
  800641:	52                   	push   %edx
  800642:	50                   	push   %eax
  800643:	89 da                	mov    %ebx,%edx
  800645:	89 f0                	mov    %esi,%eax
  800647:	e8 70 fb ff ff       	call   8001bc <printnum>
			break;
  80064c:	83 c4 20             	add    $0x20,%esp
  80064f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800652:	e9 ae fc ff ff       	jmp    800305 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800657:	83 ec 08             	sub    $0x8,%esp
  80065a:	53                   	push   %ebx
  80065b:	51                   	push   %ecx
  80065c:	ff d6                	call   *%esi
			break;
  80065e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800661:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800664:	e9 9c fc ff ff       	jmp    800305 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800669:	83 ec 08             	sub    $0x8,%esp
  80066c:	53                   	push   %ebx
  80066d:	6a 25                	push   $0x25
  80066f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800671:	83 c4 10             	add    $0x10,%esp
  800674:	eb 03                	jmp    800679 <vprintfmt+0x39a>
  800676:	83 ef 01             	sub    $0x1,%edi
  800679:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80067d:	75 f7                	jne    800676 <vprintfmt+0x397>
  80067f:	e9 81 fc ff ff       	jmp    800305 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800684:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800687:	5b                   	pop    %ebx
  800688:	5e                   	pop    %esi
  800689:	5f                   	pop    %edi
  80068a:	5d                   	pop    %ebp
  80068b:	c3                   	ret    

0080068c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80068c:	55                   	push   %ebp
  80068d:	89 e5                	mov    %esp,%ebp
  80068f:	83 ec 18             	sub    $0x18,%esp
  800692:	8b 45 08             	mov    0x8(%ebp),%eax
  800695:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800698:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80069b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80069f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006a2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006a9:	85 c0                	test   %eax,%eax
  8006ab:	74 26                	je     8006d3 <vsnprintf+0x47>
  8006ad:	85 d2                	test   %edx,%edx
  8006af:	7e 22                	jle    8006d3 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006b1:	ff 75 14             	pushl  0x14(%ebp)
  8006b4:	ff 75 10             	pushl  0x10(%ebp)
  8006b7:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006ba:	50                   	push   %eax
  8006bb:	68 a5 02 80 00       	push   $0x8002a5
  8006c0:	e8 1a fc ff ff       	call   8002df <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006c5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006c8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006ce:	83 c4 10             	add    $0x10,%esp
  8006d1:	eb 05                	jmp    8006d8 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006d3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006d8:	c9                   	leave  
  8006d9:	c3                   	ret    

008006da <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006da:	55                   	push   %ebp
  8006db:	89 e5                	mov    %esp,%ebp
  8006dd:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006e0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006e3:	50                   	push   %eax
  8006e4:	ff 75 10             	pushl  0x10(%ebp)
  8006e7:	ff 75 0c             	pushl  0xc(%ebp)
  8006ea:	ff 75 08             	pushl  0x8(%ebp)
  8006ed:	e8 9a ff ff ff       	call   80068c <vsnprintf>
	va_end(ap);

	return rc;
}
  8006f2:	c9                   	leave  
  8006f3:	c3                   	ret    

008006f4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006f4:	55                   	push   %ebp
  8006f5:	89 e5                	mov    %esp,%ebp
  8006f7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8006ff:	eb 03                	jmp    800704 <strlen+0x10>
		n++;
  800701:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800704:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800708:	75 f7                	jne    800701 <strlen+0xd>
		n++;
	return n;
}
  80070a:	5d                   	pop    %ebp
  80070b:	c3                   	ret    

0080070c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80070c:	55                   	push   %ebp
  80070d:	89 e5                	mov    %esp,%ebp
  80070f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800712:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800715:	ba 00 00 00 00       	mov    $0x0,%edx
  80071a:	eb 03                	jmp    80071f <strnlen+0x13>
		n++;
  80071c:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80071f:	39 c2                	cmp    %eax,%edx
  800721:	74 08                	je     80072b <strnlen+0x1f>
  800723:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800727:	75 f3                	jne    80071c <strnlen+0x10>
  800729:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80072b:	5d                   	pop    %ebp
  80072c:	c3                   	ret    

0080072d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80072d:	55                   	push   %ebp
  80072e:	89 e5                	mov    %esp,%ebp
  800730:	53                   	push   %ebx
  800731:	8b 45 08             	mov    0x8(%ebp),%eax
  800734:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800737:	89 c2                	mov    %eax,%edx
  800739:	83 c2 01             	add    $0x1,%edx
  80073c:	83 c1 01             	add    $0x1,%ecx
  80073f:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800743:	88 5a ff             	mov    %bl,-0x1(%edx)
  800746:	84 db                	test   %bl,%bl
  800748:	75 ef                	jne    800739 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80074a:	5b                   	pop    %ebx
  80074b:	5d                   	pop    %ebp
  80074c:	c3                   	ret    

0080074d <strcat>:

char *
strcat(char *dst, const char *src)
{
  80074d:	55                   	push   %ebp
  80074e:	89 e5                	mov    %esp,%ebp
  800750:	53                   	push   %ebx
  800751:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800754:	53                   	push   %ebx
  800755:	e8 9a ff ff ff       	call   8006f4 <strlen>
  80075a:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80075d:	ff 75 0c             	pushl  0xc(%ebp)
  800760:	01 d8                	add    %ebx,%eax
  800762:	50                   	push   %eax
  800763:	e8 c5 ff ff ff       	call   80072d <strcpy>
	return dst;
}
  800768:	89 d8                	mov    %ebx,%eax
  80076a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80076d:	c9                   	leave  
  80076e:	c3                   	ret    

0080076f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80076f:	55                   	push   %ebp
  800770:	89 e5                	mov    %esp,%ebp
  800772:	56                   	push   %esi
  800773:	53                   	push   %ebx
  800774:	8b 75 08             	mov    0x8(%ebp),%esi
  800777:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80077a:	89 f3                	mov    %esi,%ebx
  80077c:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80077f:	89 f2                	mov    %esi,%edx
  800781:	eb 0f                	jmp    800792 <strncpy+0x23>
		*dst++ = *src;
  800783:	83 c2 01             	add    $0x1,%edx
  800786:	0f b6 01             	movzbl (%ecx),%eax
  800789:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80078c:	80 39 01             	cmpb   $0x1,(%ecx)
  80078f:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800792:	39 da                	cmp    %ebx,%edx
  800794:	75 ed                	jne    800783 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800796:	89 f0                	mov    %esi,%eax
  800798:	5b                   	pop    %ebx
  800799:	5e                   	pop    %esi
  80079a:	5d                   	pop    %ebp
  80079b:	c3                   	ret    

0080079c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80079c:	55                   	push   %ebp
  80079d:	89 e5                	mov    %esp,%ebp
  80079f:	56                   	push   %esi
  8007a0:	53                   	push   %ebx
  8007a1:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007a7:	8b 55 10             	mov    0x10(%ebp),%edx
  8007aa:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007ac:	85 d2                	test   %edx,%edx
  8007ae:	74 21                	je     8007d1 <strlcpy+0x35>
  8007b0:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007b4:	89 f2                	mov    %esi,%edx
  8007b6:	eb 09                	jmp    8007c1 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007b8:	83 c2 01             	add    $0x1,%edx
  8007bb:	83 c1 01             	add    $0x1,%ecx
  8007be:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007c1:	39 c2                	cmp    %eax,%edx
  8007c3:	74 09                	je     8007ce <strlcpy+0x32>
  8007c5:	0f b6 19             	movzbl (%ecx),%ebx
  8007c8:	84 db                	test   %bl,%bl
  8007ca:	75 ec                	jne    8007b8 <strlcpy+0x1c>
  8007cc:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007ce:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007d1:	29 f0                	sub    %esi,%eax
}
  8007d3:	5b                   	pop    %ebx
  8007d4:	5e                   	pop    %esi
  8007d5:	5d                   	pop    %ebp
  8007d6:	c3                   	ret    

008007d7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007d7:	55                   	push   %ebp
  8007d8:	89 e5                	mov    %esp,%ebp
  8007da:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007dd:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007e0:	eb 06                	jmp    8007e8 <strcmp+0x11>
		p++, q++;
  8007e2:	83 c1 01             	add    $0x1,%ecx
  8007e5:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007e8:	0f b6 01             	movzbl (%ecx),%eax
  8007eb:	84 c0                	test   %al,%al
  8007ed:	74 04                	je     8007f3 <strcmp+0x1c>
  8007ef:	3a 02                	cmp    (%edx),%al
  8007f1:	74 ef                	je     8007e2 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007f3:	0f b6 c0             	movzbl %al,%eax
  8007f6:	0f b6 12             	movzbl (%edx),%edx
  8007f9:	29 d0                	sub    %edx,%eax
}
  8007fb:	5d                   	pop    %ebp
  8007fc:	c3                   	ret    

008007fd <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007fd:	55                   	push   %ebp
  8007fe:	89 e5                	mov    %esp,%ebp
  800800:	53                   	push   %ebx
  800801:	8b 45 08             	mov    0x8(%ebp),%eax
  800804:	8b 55 0c             	mov    0xc(%ebp),%edx
  800807:	89 c3                	mov    %eax,%ebx
  800809:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80080c:	eb 06                	jmp    800814 <strncmp+0x17>
		n--, p++, q++;
  80080e:	83 c0 01             	add    $0x1,%eax
  800811:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800814:	39 d8                	cmp    %ebx,%eax
  800816:	74 15                	je     80082d <strncmp+0x30>
  800818:	0f b6 08             	movzbl (%eax),%ecx
  80081b:	84 c9                	test   %cl,%cl
  80081d:	74 04                	je     800823 <strncmp+0x26>
  80081f:	3a 0a                	cmp    (%edx),%cl
  800821:	74 eb                	je     80080e <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800823:	0f b6 00             	movzbl (%eax),%eax
  800826:	0f b6 12             	movzbl (%edx),%edx
  800829:	29 d0                	sub    %edx,%eax
  80082b:	eb 05                	jmp    800832 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80082d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800832:	5b                   	pop    %ebx
  800833:	5d                   	pop    %ebp
  800834:	c3                   	ret    

00800835 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800835:	55                   	push   %ebp
  800836:	89 e5                	mov    %esp,%ebp
  800838:	8b 45 08             	mov    0x8(%ebp),%eax
  80083b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80083f:	eb 07                	jmp    800848 <strchr+0x13>
		if (*s == c)
  800841:	38 ca                	cmp    %cl,%dl
  800843:	74 0f                	je     800854 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800845:	83 c0 01             	add    $0x1,%eax
  800848:	0f b6 10             	movzbl (%eax),%edx
  80084b:	84 d2                	test   %dl,%dl
  80084d:	75 f2                	jne    800841 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80084f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800854:	5d                   	pop    %ebp
  800855:	c3                   	ret    

00800856 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800856:	55                   	push   %ebp
  800857:	89 e5                	mov    %esp,%ebp
  800859:	8b 45 08             	mov    0x8(%ebp),%eax
  80085c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800860:	eb 03                	jmp    800865 <strfind+0xf>
  800862:	83 c0 01             	add    $0x1,%eax
  800865:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800868:	38 ca                	cmp    %cl,%dl
  80086a:	74 04                	je     800870 <strfind+0x1a>
  80086c:	84 d2                	test   %dl,%dl
  80086e:	75 f2                	jne    800862 <strfind+0xc>
			break;
	return (char *) s;
}
  800870:	5d                   	pop    %ebp
  800871:	c3                   	ret    

00800872 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800872:	55                   	push   %ebp
  800873:	89 e5                	mov    %esp,%ebp
  800875:	57                   	push   %edi
  800876:	56                   	push   %esi
  800877:	53                   	push   %ebx
  800878:	8b 7d 08             	mov    0x8(%ebp),%edi
  80087b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80087e:	85 c9                	test   %ecx,%ecx
  800880:	74 36                	je     8008b8 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800882:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800888:	75 28                	jne    8008b2 <memset+0x40>
  80088a:	f6 c1 03             	test   $0x3,%cl
  80088d:	75 23                	jne    8008b2 <memset+0x40>
		c &= 0xFF;
  80088f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800893:	89 d3                	mov    %edx,%ebx
  800895:	c1 e3 08             	shl    $0x8,%ebx
  800898:	89 d6                	mov    %edx,%esi
  80089a:	c1 e6 18             	shl    $0x18,%esi
  80089d:	89 d0                	mov    %edx,%eax
  80089f:	c1 e0 10             	shl    $0x10,%eax
  8008a2:	09 f0                	or     %esi,%eax
  8008a4:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008a6:	89 d8                	mov    %ebx,%eax
  8008a8:	09 d0                	or     %edx,%eax
  8008aa:	c1 e9 02             	shr    $0x2,%ecx
  8008ad:	fc                   	cld    
  8008ae:	f3 ab                	rep stos %eax,%es:(%edi)
  8008b0:	eb 06                	jmp    8008b8 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008b5:	fc                   	cld    
  8008b6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008b8:	89 f8                	mov    %edi,%eax
  8008ba:	5b                   	pop    %ebx
  8008bb:	5e                   	pop    %esi
  8008bc:	5f                   	pop    %edi
  8008bd:	5d                   	pop    %ebp
  8008be:	c3                   	ret    

008008bf <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008bf:	55                   	push   %ebp
  8008c0:	89 e5                	mov    %esp,%ebp
  8008c2:	57                   	push   %edi
  8008c3:	56                   	push   %esi
  8008c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008ca:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008cd:	39 c6                	cmp    %eax,%esi
  8008cf:	73 35                	jae    800906 <memmove+0x47>
  8008d1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008d4:	39 d0                	cmp    %edx,%eax
  8008d6:	73 2e                	jae    800906 <memmove+0x47>
		s += n;
		d += n;
  8008d8:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008db:	89 d6                	mov    %edx,%esi
  8008dd:	09 fe                	or     %edi,%esi
  8008df:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008e5:	75 13                	jne    8008fa <memmove+0x3b>
  8008e7:	f6 c1 03             	test   $0x3,%cl
  8008ea:	75 0e                	jne    8008fa <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008ec:	83 ef 04             	sub    $0x4,%edi
  8008ef:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008f2:	c1 e9 02             	shr    $0x2,%ecx
  8008f5:	fd                   	std    
  8008f6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008f8:	eb 09                	jmp    800903 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008fa:	83 ef 01             	sub    $0x1,%edi
  8008fd:	8d 72 ff             	lea    -0x1(%edx),%esi
  800900:	fd                   	std    
  800901:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800903:	fc                   	cld    
  800904:	eb 1d                	jmp    800923 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800906:	89 f2                	mov    %esi,%edx
  800908:	09 c2                	or     %eax,%edx
  80090a:	f6 c2 03             	test   $0x3,%dl
  80090d:	75 0f                	jne    80091e <memmove+0x5f>
  80090f:	f6 c1 03             	test   $0x3,%cl
  800912:	75 0a                	jne    80091e <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800914:	c1 e9 02             	shr    $0x2,%ecx
  800917:	89 c7                	mov    %eax,%edi
  800919:	fc                   	cld    
  80091a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80091c:	eb 05                	jmp    800923 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80091e:	89 c7                	mov    %eax,%edi
  800920:	fc                   	cld    
  800921:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800923:	5e                   	pop    %esi
  800924:	5f                   	pop    %edi
  800925:	5d                   	pop    %ebp
  800926:	c3                   	ret    

00800927 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800927:	55                   	push   %ebp
  800928:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80092a:	ff 75 10             	pushl  0x10(%ebp)
  80092d:	ff 75 0c             	pushl  0xc(%ebp)
  800930:	ff 75 08             	pushl  0x8(%ebp)
  800933:	e8 87 ff ff ff       	call   8008bf <memmove>
}
  800938:	c9                   	leave  
  800939:	c3                   	ret    

0080093a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
  80093d:	56                   	push   %esi
  80093e:	53                   	push   %ebx
  80093f:	8b 45 08             	mov    0x8(%ebp),%eax
  800942:	8b 55 0c             	mov    0xc(%ebp),%edx
  800945:	89 c6                	mov    %eax,%esi
  800947:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80094a:	eb 1a                	jmp    800966 <memcmp+0x2c>
		if (*s1 != *s2)
  80094c:	0f b6 08             	movzbl (%eax),%ecx
  80094f:	0f b6 1a             	movzbl (%edx),%ebx
  800952:	38 d9                	cmp    %bl,%cl
  800954:	74 0a                	je     800960 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800956:	0f b6 c1             	movzbl %cl,%eax
  800959:	0f b6 db             	movzbl %bl,%ebx
  80095c:	29 d8                	sub    %ebx,%eax
  80095e:	eb 0f                	jmp    80096f <memcmp+0x35>
		s1++, s2++;
  800960:	83 c0 01             	add    $0x1,%eax
  800963:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800966:	39 f0                	cmp    %esi,%eax
  800968:	75 e2                	jne    80094c <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80096a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80096f:	5b                   	pop    %ebx
  800970:	5e                   	pop    %esi
  800971:	5d                   	pop    %ebp
  800972:	c3                   	ret    

00800973 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800973:	55                   	push   %ebp
  800974:	89 e5                	mov    %esp,%ebp
  800976:	53                   	push   %ebx
  800977:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80097a:	89 c1                	mov    %eax,%ecx
  80097c:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80097f:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800983:	eb 0a                	jmp    80098f <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800985:	0f b6 10             	movzbl (%eax),%edx
  800988:	39 da                	cmp    %ebx,%edx
  80098a:	74 07                	je     800993 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80098c:	83 c0 01             	add    $0x1,%eax
  80098f:	39 c8                	cmp    %ecx,%eax
  800991:	72 f2                	jb     800985 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800993:	5b                   	pop    %ebx
  800994:	5d                   	pop    %ebp
  800995:	c3                   	ret    

00800996 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800996:	55                   	push   %ebp
  800997:	89 e5                	mov    %esp,%ebp
  800999:	57                   	push   %edi
  80099a:	56                   	push   %esi
  80099b:	53                   	push   %ebx
  80099c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80099f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009a2:	eb 03                	jmp    8009a7 <strtol+0x11>
		s++;
  8009a4:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009a7:	0f b6 01             	movzbl (%ecx),%eax
  8009aa:	3c 20                	cmp    $0x20,%al
  8009ac:	74 f6                	je     8009a4 <strtol+0xe>
  8009ae:	3c 09                	cmp    $0x9,%al
  8009b0:	74 f2                	je     8009a4 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009b2:	3c 2b                	cmp    $0x2b,%al
  8009b4:	75 0a                	jne    8009c0 <strtol+0x2a>
		s++;
  8009b6:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009b9:	bf 00 00 00 00       	mov    $0x0,%edi
  8009be:	eb 11                	jmp    8009d1 <strtol+0x3b>
  8009c0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009c5:	3c 2d                	cmp    $0x2d,%al
  8009c7:	75 08                	jne    8009d1 <strtol+0x3b>
		s++, neg = 1;
  8009c9:	83 c1 01             	add    $0x1,%ecx
  8009cc:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009d1:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009d7:	75 15                	jne    8009ee <strtol+0x58>
  8009d9:	80 39 30             	cmpb   $0x30,(%ecx)
  8009dc:	75 10                	jne    8009ee <strtol+0x58>
  8009de:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009e2:	75 7c                	jne    800a60 <strtol+0xca>
		s += 2, base = 16;
  8009e4:	83 c1 02             	add    $0x2,%ecx
  8009e7:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009ec:	eb 16                	jmp    800a04 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009ee:	85 db                	test   %ebx,%ebx
  8009f0:	75 12                	jne    800a04 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009f2:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009f7:	80 39 30             	cmpb   $0x30,(%ecx)
  8009fa:	75 08                	jne    800a04 <strtol+0x6e>
		s++, base = 8;
  8009fc:	83 c1 01             	add    $0x1,%ecx
  8009ff:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a04:	b8 00 00 00 00       	mov    $0x0,%eax
  800a09:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a0c:	0f b6 11             	movzbl (%ecx),%edx
  800a0f:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a12:	89 f3                	mov    %esi,%ebx
  800a14:	80 fb 09             	cmp    $0x9,%bl
  800a17:	77 08                	ja     800a21 <strtol+0x8b>
			dig = *s - '0';
  800a19:	0f be d2             	movsbl %dl,%edx
  800a1c:	83 ea 30             	sub    $0x30,%edx
  800a1f:	eb 22                	jmp    800a43 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a21:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a24:	89 f3                	mov    %esi,%ebx
  800a26:	80 fb 19             	cmp    $0x19,%bl
  800a29:	77 08                	ja     800a33 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a2b:	0f be d2             	movsbl %dl,%edx
  800a2e:	83 ea 57             	sub    $0x57,%edx
  800a31:	eb 10                	jmp    800a43 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a33:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a36:	89 f3                	mov    %esi,%ebx
  800a38:	80 fb 19             	cmp    $0x19,%bl
  800a3b:	77 16                	ja     800a53 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a3d:	0f be d2             	movsbl %dl,%edx
  800a40:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a43:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a46:	7d 0b                	jge    800a53 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a48:	83 c1 01             	add    $0x1,%ecx
  800a4b:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a4f:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a51:	eb b9                	jmp    800a0c <strtol+0x76>

	if (endptr)
  800a53:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a57:	74 0d                	je     800a66 <strtol+0xd0>
		*endptr = (char *) s;
  800a59:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a5c:	89 0e                	mov    %ecx,(%esi)
  800a5e:	eb 06                	jmp    800a66 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a60:	85 db                	test   %ebx,%ebx
  800a62:	74 98                	je     8009fc <strtol+0x66>
  800a64:	eb 9e                	jmp    800a04 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a66:	89 c2                	mov    %eax,%edx
  800a68:	f7 da                	neg    %edx
  800a6a:	85 ff                	test   %edi,%edi
  800a6c:	0f 45 c2             	cmovne %edx,%eax
}
  800a6f:	5b                   	pop    %ebx
  800a70:	5e                   	pop    %esi
  800a71:	5f                   	pop    %edi
  800a72:	5d                   	pop    %ebp
  800a73:	c3                   	ret    

00800a74 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a74:	55                   	push   %ebp
  800a75:	89 e5                	mov    %esp,%ebp
  800a77:	57                   	push   %edi
  800a78:	56                   	push   %esi
  800a79:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a7a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a82:	8b 55 08             	mov    0x8(%ebp),%edx
  800a85:	89 c3                	mov    %eax,%ebx
  800a87:	89 c7                	mov    %eax,%edi
  800a89:	89 c6                	mov    %eax,%esi
  800a8b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a8d:	5b                   	pop    %ebx
  800a8e:	5e                   	pop    %esi
  800a8f:	5f                   	pop    %edi
  800a90:	5d                   	pop    %ebp
  800a91:	c3                   	ret    

00800a92 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a92:	55                   	push   %ebp
  800a93:	89 e5                	mov    %esp,%ebp
  800a95:	57                   	push   %edi
  800a96:	56                   	push   %esi
  800a97:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a98:	ba 00 00 00 00       	mov    $0x0,%edx
  800a9d:	b8 01 00 00 00       	mov    $0x1,%eax
  800aa2:	89 d1                	mov    %edx,%ecx
  800aa4:	89 d3                	mov    %edx,%ebx
  800aa6:	89 d7                	mov    %edx,%edi
  800aa8:	89 d6                	mov    %edx,%esi
  800aaa:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800aac:	5b                   	pop    %ebx
  800aad:	5e                   	pop    %esi
  800aae:	5f                   	pop    %edi
  800aaf:	5d                   	pop    %ebp
  800ab0:	c3                   	ret    

00800ab1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ab1:	55                   	push   %ebp
  800ab2:	89 e5                	mov    %esp,%ebp
  800ab4:	57                   	push   %edi
  800ab5:	56                   	push   %esi
  800ab6:	53                   	push   %ebx
  800ab7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aba:	b9 00 00 00 00       	mov    $0x0,%ecx
  800abf:	b8 03 00 00 00       	mov    $0x3,%eax
  800ac4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ac7:	89 cb                	mov    %ecx,%ebx
  800ac9:	89 cf                	mov    %ecx,%edi
  800acb:	89 ce                	mov    %ecx,%esi
  800acd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800acf:	85 c0                	test   %eax,%eax
  800ad1:	7e 17                	jle    800aea <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ad3:	83 ec 0c             	sub    $0xc,%esp
  800ad6:	50                   	push   %eax
  800ad7:	6a 03                	push   $0x3
  800ad9:	68 ff 24 80 00       	push   $0x8024ff
  800ade:	6a 23                	push   $0x23
  800ae0:	68 1c 25 80 00       	push   $0x80251c
  800ae5:	e8 f3 11 00 00       	call   801cdd <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800aea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800aed:	5b                   	pop    %ebx
  800aee:	5e                   	pop    %esi
  800aef:	5f                   	pop    %edi
  800af0:	5d                   	pop    %ebp
  800af1:	c3                   	ret    

00800af2 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800af2:	55                   	push   %ebp
  800af3:	89 e5                	mov    %esp,%ebp
  800af5:	57                   	push   %edi
  800af6:	56                   	push   %esi
  800af7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af8:	ba 00 00 00 00       	mov    $0x0,%edx
  800afd:	b8 02 00 00 00       	mov    $0x2,%eax
  800b02:	89 d1                	mov    %edx,%ecx
  800b04:	89 d3                	mov    %edx,%ebx
  800b06:	89 d7                	mov    %edx,%edi
  800b08:	89 d6                	mov    %edx,%esi
  800b0a:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b0c:	5b                   	pop    %ebx
  800b0d:	5e                   	pop    %esi
  800b0e:	5f                   	pop    %edi
  800b0f:	5d                   	pop    %ebp
  800b10:	c3                   	ret    

00800b11 <sys_yield>:

void
sys_yield(void)
{
  800b11:	55                   	push   %ebp
  800b12:	89 e5                	mov    %esp,%ebp
  800b14:	57                   	push   %edi
  800b15:	56                   	push   %esi
  800b16:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b17:	ba 00 00 00 00       	mov    $0x0,%edx
  800b1c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b21:	89 d1                	mov    %edx,%ecx
  800b23:	89 d3                	mov    %edx,%ebx
  800b25:	89 d7                	mov    %edx,%edi
  800b27:	89 d6                	mov    %edx,%esi
  800b29:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b2b:	5b                   	pop    %ebx
  800b2c:	5e                   	pop    %esi
  800b2d:	5f                   	pop    %edi
  800b2e:	5d                   	pop    %ebp
  800b2f:	c3                   	ret    

00800b30 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b30:	55                   	push   %ebp
  800b31:	89 e5                	mov    %esp,%ebp
  800b33:	57                   	push   %edi
  800b34:	56                   	push   %esi
  800b35:	53                   	push   %ebx
  800b36:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b39:	be 00 00 00 00       	mov    $0x0,%esi
  800b3e:	b8 04 00 00 00       	mov    $0x4,%eax
  800b43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b46:	8b 55 08             	mov    0x8(%ebp),%edx
  800b49:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b4c:	89 f7                	mov    %esi,%edi
  800b4e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b50:	85 c0                	test   %eax,%eax
  800b52:	7e 17                	jle    800b6b <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b54:	83 ec 0c             	sub    $0xc,%esp
  800b57:	50                   	push   %eax
  800b58:	6a 04                	push   $0x4
  800b5a:	68 ff 24 80 00       	push   $0x8024ff
  800b5f:	6a 23                	push   $0x23
  800b61:	68 1c 25 80 00       	push   $0x80251c
  800b66:	e8 72 11 00 00       	call   801cdd <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b6b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b6e:	5b                   	pop    %ebx
  800b6f:	5e                   	pop    %esi
  800b70:	5f                   	pop    %edi
  800b71:	5d                   	pop    %ebp
  800b72:	c3                   	ret    

00800b73 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b73:	55                   	push   %ebp
  800b74:	89 e5                	mov    %esp,%ebp
  800b76:	57                   	push   %edi
  800b77:	56                   	push   %esi
  800b78:	53                   	push   %ebx
  800b79:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7c:	b8 05 00 00 00       	mov    $0x5,%eax
  800b81:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b84:	8b 55 08             	mov    0x8(%ebp),%edx
  800b87:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b8a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b8d:	8b 75 18             	mov    0x18(%ebp),%esi
  800b90:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b92:	85 c0                	test   %eax,%eax
  800b94:	7e 17                	jle    800bad <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b96:	83 ec 0c             	sub    $0xc,%esp
  800b99:	50                   	push   %eax
  800b9a:	6a 05                	push   $0x5
  800b9c:	68 ff 24 80 00       	push   $0x8024ff
  800ba1:	6a 23                	push   $0x23
  800ba3:	68 1c 25 80 00       	push   $0x80251c
  800ba8:	e8 30 11 00 00       	call   801cdd <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb0:	5b                   	pop    %ebx
  800bb1:	5e                   	pop    %esi
  800bb2:	5f                   	pop    %edi
  800bb3:	5d                   	pop    %ebp
  800bb4:	c3                   	ret    

00800bb5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bb5:	55                   	push   %ebp
  800bb6:	89 e5                	mov    %esp,%ebp
  800bb8:	57                   	push   %edi
  800bb9:	56                   	push   %esi
  800bba:	53                   	push   %ebx
  800bbb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bbe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bc3:	b8 06 00 00 00       	mov    $0x6,%eax
  800bc8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bcb:	8b 55 08             	mov    0x8(%ebp),%edx
  800bce:	89 df                	mov    %ebx,%edi
  800bd0:	89 de                	mov    %ebx,%esi
  800bd2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bd4:	85 c0                	test   %eax,%eax
  800bd6:	7e 17                	jle    800bef <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd8:	83 ec 0c             	sub    $0xc,%esp
  800bdb:	50                   	push   %eax
  800bdc:	6a 06                	push   $0x6
  800bde:	68 ff 24 80 00       	push   $0x8024ff
  800be3:	6a 23                	push   $0x23
  800be5:	68 1c 25 80 00       	push   $0x80251c
  800bea:	e8 ee 10 00 00       	call   801cdd <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf2:	5b                   	pop    %ebx
  800bf3:	5e                   	pop    %esi
  800bf4:	5f                   	pop    %edi
  800bf5:	5d                   	pop    %ebp
  800bf6:	c3                   	ret    

00800bf7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bf7:	55                   	push   %ebp
  800bf8:	89 e5                	mov    %esp,%ebp
  800bfa:	57                   	push   %edi
  800bfb:	56                   	push   %esi
  800bfc:	53                   	push   %ebx
  800bfd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c00:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c05:	b8 08 00 00 00       	mov    $0x8,%eax
  800c0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c10:	89 df                	mov    %ebx,%edi
  800c12:	89 de                	mov    %ebx,%esi
  800c14:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c16:	85 c0                	test   %eax,%eax
  800c18:	7e 17                	jle    800c31 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1a:	83 ec 0c             	sub    $0xc,%esp
  800c1d:	50                   	push   %eax
  800c1e:	6a 08                	push   $0x8
  800c20:	68 ff 24 80 00       	push   $0x8024ff
  800c25:	6a 23                	push   $0x23
  800c27:	68 1c 25 80 00       	push   $0x80251c
  800c2c:	e8 ac 10 00 00       	call   801cdd <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c31:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c34:	5b                   	pop    %ebx
  800c35:	5e                   	pop    %esi
  800c36:	5f                   	pop    %edi
  800c37:	5d                   	pop    %ebp
  800c38:	c3                   	ret    

00800c39 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c39:	55                   	push   %ebp
  800c3a:	89 e5                	mov    %esp,%ebp
  800c3c:	57                   	push   %edi
  800c3d:	56                   	push   %esi
  800c3e:	53                   	push   %ebx
  800c3f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c42:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c47:	b8 09 00 00 00       	mov    $0x9,%eax
  800c4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c52:	89 df                	mov    %ebx,%edi
  800c54:	89 de                	mov    %ebx,%esi
  800c56:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c58:	85 c0                	test   %eax,%eax
  800c5a:	7e 17                	jle    800c73 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5c:	83 ec 0c             	sub    $0xc,%esp
  800c5f:	50                   	push   %eax
  800c60:	6a 09                	push   $0x9
  800c62:	68 ff 24 80 00       	push   $0x8024ff
  800c67:	6a 23                	push   $0x23
  800c69:	68 1c 25 80 00       	push   $0x80251c
  800c6e:	e8 6a 10 00 00       	call   801cdd <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c73:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c76:	5b                   	pop    %ebx
  800c77:	5e                   	pop    %esi
  800c78:	5f                   	pop    %edi
  800c79:	5d                   	pop    %ebp
  800c7a:	c3                   	ret    

00800c7b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c7b:	55                   	push   %ebp
  800c7c:	89 e5                	mov    %esp,%ebp
  800c7e:	57                   	push   %edi
  800c7f:	56                   	push   %esi
  800c80:	53                   	push   %ebx
  800c81:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c84:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c89:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c91:	8b 55 08             	mov    0x8(%ebp),%edx
  800c94:	89 df                	mov    %ebx,%edi
  800c96:	89 de                	mov    %ebx,%esi
  800c98:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c9a:	85 c0                	test   %eax,%eax
  800c9c:	7e 17                	jle    800cb5 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9e:	83 ec 0c             	sub    $0xc,%esp
  800ca1:	50                   	push   %eax
  800ca2:	6a 0a                	push   $0xa
  800ca4:	68 ff 24 80 00       	push   $0x8024ff
  800ca9:	6a 23                	push   $0x23
  800cab:	68 1c 25 80 00       	push   $0x80251c
  800cb0:	e8 28 10 00 00       	call   801cdd <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cb5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb8:	5b                   	pop    %ebx
  800cb9:	5e                   	pop    %esi
  800cba:	5f                   	pop    %edi
  800cbb:	5d                   	pop    %ebp
  800cbc:	c3                   	ret    

00800cbd <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cbd:	55                   	push   %ebp
  800cbe:	89 e5                	mov    %esp,%ebp
  800cc0:	57                   	push   %edi
  800cc1:	56                   	push   %esi
  800cc2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc3:	be 00 00 00 00       	mov    $0x0,%esi
  800cc8:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ccd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cd6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cd9:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cdb:	5b                   	pop    %ebx
  800cdc:	5e                   	pop    %esi
  800cdd:	5f                   	pop    %edi
  800cde:	5d                   	pop    %ebp
  800cdf:	c3                   	ret    

00800ce0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ce0:	55                   	push   %ebp
  800ce1:	89 e5                	mov    %esp,%ebp
  800ce3:	57                   	push   %edi
  800ce4:	56                   	push   %esi
  800ce5:	53                   	push   %ebx
  800ce6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cee:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cf3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf6:	89 cb                	mov    %ecx,%ebx
  800cf8:	89 cf                	mov    %ecx,%edi
  800cfa:	89 ce                	mov    %ecx,%esi
  800cfc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cfe:	85 c0                	test   %eax,%eax
  800d00:	7e 17                	jle    800d19 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d02:	83 ec 0c             	sub    $0xc,%esp
  800d05:	50                   	push   %eax
  800d06:	6a 0d                	push   $0xd
  800d08:	68 ff 24 80 00       	push   $0x8024ff
  800d0d:	6a 23                	push   $0x23
  800d0f:	68 1c 25 80 00       	push   $0x80251c
  800d14:	e8 c4 0f 00 00       	call   801cdd <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d19:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1c:	5b                   	pop    %ebx
  800d1d:	5e                   	pop    %esi
  800d1e:	5f                   	pop    %edi
  800d1f:	5d                   	pop    %ebp
  800d20:	c3                   	ret    

00800d21 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800d21:	55                   	push   %ebp
  800d22:	89 e5                	mov    %esp,%ebp
  800d24:	53                   	push   %ebx
  800d25:	83 ec 04             	sub    $0x4,%esp
	int r;
	void * address = (void *)(pn*PGSIZE);
  800d28:	89 d3                	mov    %edx,%ebx
  800d2a:	c1 e3 0c             	shl    $0xc,%ebx
	
	if((uvpt[pn] & PTE_SHARE))
  800d2d:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800d34:	f6 c5 04             	test   $0x4,%ch
  800d37:	74 38                	je     800d71 <duppage+0x50>
	{
		if ((r = sys_page_map(0, address, envid, address, (uvpt[pn] | PTE_SYSCALL))) < 0)
  800d39:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d40:	83 ec 0c             	sub    $0xc,%esp
  800d43:	81 ca 07 0e 00 00    	or     $0xe07,%edx
  800d49:	52                   	push   %edx
  800d4a:	53                   	push   %ebx
  800d4b:	50                   	push   %eax
  800d4c:	53                   	push   %ebx
  800d4d:	6a 00                	push   $0x0
  800d4f:	e8 1f fe ff ff       	call   800b73 <sys_page_map>
  800d54:	83 c4 20             	add    $0x20,%esp
  800d57:	85 c0                	test   %eax,%eax
  800d59:	0f 89 b8 00 00 00    	jns    800e17 <duppage+0xf6>
			panic("sys_page_map: %e", r);
  800d5f:	50                   	push   %eax
  800d60:	68 2a 25 80 00       	push   $0x80252a
  800d65:	6a 4e                	push   $0x4e
  800d67:	68 3b 25 80 00       	push   $0x80253b
  800d6c:	e8 6c 0f 00 00       	call   801cdd <_panic>
	}
	else if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW))
  800d71:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800d78:	f6 c1 02             	test   $0x2,%cl
  800d7b:	75 0c                	jne    800d89 <duppage+0x68>
  800d7d:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800d84:	f6 c5 08             	test   $0x8,%ch
  800d87:	74 57                	je     800de0 <duppage+0xbf>
	{
		int perm = 0;
		perm |= PTE_P|PTE_U|PTE_COW;
	
		if ((r = sys_page_map(0, address, envid, address, perm)) < 0)
  800d89:	83 ec 0c             	sub    $0xc,%esp
  800d8c:	68 05 08 00 00       	push   $0x805
  800d91:	53                   	push   %ebx
  800d92:	50                   	push   %eax
  800d93:	53                   	push   %ebx
  800d94:	6a 00                	push   $0x0
  800d96:	e8 d8 fd ff ff       	call   800b73 <sys_page_map>
  800d9b:	83 c4 20             	add    $0x20,%esp
  800d9e:	85 c0                	test   %eax,%eax
  800da0:	79 12                	jns    800db4 <duppage+0x93>
			panic("sys_page_map: %e", r);
  800da2:	50                   	push   %eax
  800da3:	68 2a 25 80 00       	push   $0x80252a
  800da8:	6a 56                	push   $0x56
  800daa:	68 3b 25 80 00       	push   $0x80253b
  800daf:	e8 29 0f 00 00       	call   801cdd <_panic>
		if ((r = sys_page_map(0, address, 0, address, perm)) < 0)
  800db4:	83 ec 0c             	sub    $0xc,%esp
  800db7:	68 05 08 00 00       	push   $0x805
  800dbc:	53                   	push   %ebx
  800dbd:	6a 00                	push   $0x0
  800dbf:	53                   	push   %ebx
  800dc0:	6a 00                	push   $0x0
  800dc2:	e8 ac fd ff ff       	call   800b73 <sys_page_map>
  800dc7:	83 c4 20             	add    $0x20,%esp
  800dca:	85 c0                	test   %eax,%eax
  800dcc:	79 49                	jns    800e17 <duppage+0xf6>
			panic("sys_page_map: %e", r);
  800dce:	50                   	push   %eax
  800dcf:	68 2a 25 80 00       	push   $0x80252a
  800dd4:	6a 58                	push   $0x58
  800dd6:	68 3b 25 80 00       	push   $0x80253b
  800ddb:	e8 fd 0e 00 00       	call   801cdd <_panic>
	}
	else if((uvpt[pn] & ~PTE_U) == 0)
  800de0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800de7:	f7 c2 fb ff ff ff    	test   $0xfffffffb,%edx
  800ded:	75 28                	jne    800e17 <duppage+0xf6>
	{
		//cprintf("im here");
		if ((r = sys_page_map(0, address, envid, address, PTE_P|PTE_U)) < 0)
  800def:	83 ec 0c             	sub    $0xc,%esp
  800df2:	6a 05                	push   $0x5
  800df4:	53                   	push   %ebx
  800df5:	50                   	push   %eax
  800df6:	53                   	push   %ebx
  800df7:	6a 00                	push   $0x0
  800df9:	e8 75 fd ff ff       	call   800b73 <sys_page_map>
  800dfe:	83 c4 20             	add    $0x20,%esp
  800e01:	85 c0                	test   %eax,%eax
  800e03:	79 12                	jns    800e17 <duppage+0xf6>
			panic("sys_page_map: %e", r);	
  800e05:	50                   	push   %eax
  800e06:	68 2a 25 80 00       	push   $0x80252a
  800e0b:	6a 5e                	push   $0x5e
  800e0d:	68 3b 25 80 00       	push   $0x80253b
  800e12:	e8 c6 0e 00 00       	call   801cdd <_panic>
	}
	return 0;
}
  800e17:	b8 00 00 00 00       	mov    $0x0,%eax
  800e1c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e1f:	c9                   	leave  
  800e20:	c3                   	ret    

00800e21 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e21:	55                   	push   %ebp
  800e22:	89 e5                	mov    %esp,%ebp
  800e24:	53                   	push   %ebx
  800e25:	83 ec 08             	sub    $0x8,%esp
	void *addr = (void *) utf->utf_fault_va;
  800e28:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2b:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	unsigned pn = ((uint32_t)addr)/PGSIZE;
  800e2d:	89 d8                	mov    %ebx,%eax
  800e2f:	c1 e8 0c             	shr    $0xc,%eax
	pte_t pte = uvpt[pn];
  800e32:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// Allocate a new page, mapped at temp location
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  800e39:	6a 07                	push   $0x7
  800e3b:	68 00 f0 7f 00       	push   $0x7ff000
  800e40:	6a 00                	push   $0x0
  800e42:	e8 e9 fc ff ff       	call   800b30 <sys_page_alloc>
  800e47:	83 c4 10             	add    $0x10,%esp
  800e4a:	85 c0                	test   %eax,%eax
  800e4c:	79 12                	jns    800e60 <pgfault+0x3f>
		panic("sys_page_alloc: %e", r);
  800e4e:	50                   	push   %eax
  800e4f:	68 46 25 80 00       	push   $0x802546
  800e54:	6a 2b                	push   $0x2b
  800e56:	68 3b 25 80 00       	push   $0x80253b
  800e5b:	e8 7d 0e 00 00       	call   801cdd <_panic>

	// Copy the data from the old page to this new page
	void *addr_pgstart = (void *) ROUNDDOWN(addr, PGSIZE);
  800e60:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr_pgstart, PGSIZE);
  800e66:	83 ec 04             	sub    $0x4,%esp
  800e69:	68 00 10 00 00       	push   $0x1000
  800e6e:	53                   	push   %ebx
  800e6f:	68 00 f0 7f 00       	push   $0x7ff000
  800e74:	e8 46 fa ff ff       	call   8008bf <memmove>

	// Move the new page to the old page's address
	if ((r = sys_page_map(0, PFTEMP, 0, addr_pgstart, PTE_P|PTE_U|PTE_W)) < 0)
  800e79:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e80:	53                   	push   %ebx
  800e81:	6a 00                	push   $0x0
  800e83:	68 00 f0 7f 00       	push   $0x7ff000
  800e88:	6a 00                	push   $0x0
  800e8a:	e8 e4 fc ff ff       	call   800b73 <sys_page_map>
  800e8f:	83 c4 20             	add    $0x20,%esp
  800e92:	85 c0                	test   %eax,%eax
  800e94:	79 12                	jns    800ea8 <pgfault+0x87>
		panic("sys_page_map: %e", r);
  800e96:	50                   	push   %eax
  800e97:	68 2a 25 80 00       	push   $0x80252a
  800e9c:	6a 33                	push   $0x33
  800e9e:	68 3b 25 80 00       	push   $0x80253b
  800ea3:	e8 35 0e 00 00       	call   801cdd <_panic>

	// Unmap the temp location
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800ea8:	83 ec 08             	sub    $0x8,%esp
  800eab:	68 00 f0 7f 00       	push   $0x7ff000
  800eb0:	6a 00                	push   $0x0
  800eb2:	e8 fe fc ff ff       	call   800bb5 <sys_page_unmap>
  800eb7:	83 c4 10             	add    $0x10,%esp
  800eba:	85 c0                	test   %eax,%eax
  800ebc:	79 12                	jns    800ed0 <pgfault+0xaf>
		panic("sys_page_unmap: %e", r);
  800ebe:	50                   	push   %eax
  800ebf:	68 59 25 80 00       	push   $0x802559
  800ec4:	6a 37                	push   $0x37
  800ec6:	68 3b 25 80 00       	push   $0x80253b
  800ecb:	e8 0d 0e 00 00       	call   801cdd <_panic>
}
  800ed0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ed3:	c9                   	leave  
  800ed4:	c3                   	ret    

00800ed5 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ed5:	55                   	push   %ebp
  800ed6:	89 e5                	mov    %esp,%ebp
  800ed8:	56                   	push   %esi
  800ed9:	53                   	push   %ebx
  800eda:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
	// Set up page fault handler
	set_pgfault_handler(&pgfault);
  800edd:	68 21 0e 80 00       	push   $0x800e21
  800ee2:	e8 3c 0e 00 00       	call   801d23 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800ee7:	b8 07 00 00 00       	mov    $0x7,%eax
  800eec:	cd 30                	int    $0x30

	// Create child
	envid_t envid = sys_exofork();
  800eee:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (envid < 0) {
  800ef1:	83 c4 10             	add    $0x10,%esp
  800ef4:	85 c0                	test   %eax,%eax
  800ef6:	79 12                	jns    800f0a <fork+0x35>
		panic("sys_exofork: %e", envid);
  800ef8:	50                   	push   %eax
  800ef9:	68 6c 25 80 00       	push   $0x80256c
  800efe:	6a 7c                	push   $0x7c
  800f00:	68 3b 25 80 00       	push   $0x80253b
  800f05:	e8 d3 0d 00 00       	call   801cdd <_panic>
		return envid;
	}
	if (envid == 0) {
  800f0a:	85 c0                	test   %eax,%eax
  800f0c:	75 1e                	jne    800f2c <fork+0x57>
		// We are the child.
		thisenv = &envs[ENVX(sys_getenvid())]; // Fix thisenv
  800f0e:	e8 df fb ff ff       	call   800af2 <sys_getenvid>
  800f13:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f18:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f1b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f20:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800f25:	b8 00 00 00 00       	mov    $0x0,%eax
  800f2a:	eb 7d                	jmp    800fa9 <fork+0xd4>

	// Set page fault handler on the child.
	// The parent needs to do it, else the child wouldn't be able to handle
	// the fault when trying to access it's stack (which happens as soon it starts)
	extern void _pgfault_upcall(void);
	sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);
  800f2c:	83 ec 04             	sub    $0x4,%esp
  800f2f:	6a 07                	push   $0x7
  800f31:	68 00 f0 bf ee       	push   $0xeebff000
  800f36:	50                   	push   %eax
  800f37:	e8 f4 fb ff ff       	call   800b30 <sys_page_alloc>
	sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  800f3c:	83 c4 08             	add    $0x8,%esp
  800f3f:	68 68 1d 80 00       	push   $0x801d68
  800f44:	ff 75 f4             	pushl  -0xc(%ebp)
  800f47:	e8 2f fd ff ff       	call   800c7b <sys_env_set_pgfault_upcall>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  800f4c:	be 04 60 80 00       	mov    $0x806004,%esi
  800f51:	c1 ee 0c             	shr    $0xc,%esi
  800f54:	83 c4 10             	add    $0x10,%esp
  800f57:	bb 00 08 00 00       	mov    $0x800,%ebx
  800f5c:	eb 0d                	jmp    800f6b <fork+0x96>
		duppage(envid, pn);
  800f5e:	89 da                	mov    %ebx,%edx
  800f60:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f63:	e8 b9 fd ff ff       	call   800d21 <duppage>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  800f68:	83 c3 01             	add    $0x1,%ebx
  800f6b:	39 f3                	cmp    %esi,%ebx
  800f6d:	76 ef                	jbe    800f5e <fork+0x89>
	}

	// Also copy the stack we are currently running on
	// I think it should loop from ustacktop to this page, since the stack
	// can have more than 1 page
	duppage(envid, ((uint32_t) &envid)/PGSIZE);
  800f6f:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800f72:	c1 ea 0c             	shr    $0xc,%edx
  800f75:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f78:	e8 a4 fd ff ff       	call   800d21 <duppage>

	// Start the child environmnet running
	int r;
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  800f7d:	83 ec 08             	sub    $0x8,%esp
  800f80:	6a 02                	push   $0x2
  800f82:	ff 75 f4             	pushl  -0xc(%ebp)
  800f85:	e8 6d fc ff ff       	call   800bf7 <sys_env_set_status>
  800f8a:	83 c4 10             	add    $0x10,%esp
  800f8d:	85 c0                	test   %eax,%eax
  800f8f:	79 15                	jns    800fa6 <fork+0xd1>
		panic("sys_env_set_status: %e", r);
  800f91:	50                   	push   %eax
  800f92:	68 7c 25 80 00       	push   $0x80257c
  800f97:	68 9c 00 00 00       	push   $0x9c
  800f9c:	68 3b 25 80 00       	push   $0x80253b
  800fa1:	e8 37 0d 00 00       	call   801cdd <_panic>
		return r;
	}

	return envid;
  800fa6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800fa9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fac:	5b                   	pop    %ebx
  800fad:	5e                   	pop    %esi
  800fae:	5d                   	pop    %ebp
  800faf:	c3                   	ret    

00800fb0 <sfork>:

// Challenge!
int
sfork(void)
{
  800fb0:	55                   	push   %ebp
  800fb1:	89 e5                	mov    %esp,%ebp
  800fb3:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800fb6:	68 93 25 80 00       	push   $0x802593
  800fbb:	68 a7 00 00 00       	push   $0xa7
  800fc0:	68 3b 25 80 00       	push   $0x80253b
  800fc5:	e8 13 0d 00 00       	call   801cdd <_panic>

00800fca <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800fca:	55                   	push   %ebp
  800fcb:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800fcd:	8b 45 08             	mov    0x8(%ebp),%eax
  800fd0:	05 00 00 00 30       	add    $0x30000000,%eax
  800fd5:	c1 e8 0c             	shr    $0xc,%eax
}
  800fd8:	5d                   	pop    %ebp
  800fd9:	c3                   	ret    

00800fda <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800fda:	55                   	push   %ebp
  800fdb:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800fdd:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe0:	05 00 00 00 30       	add    $0x30000000,%eax
  800fe5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800fea:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800fef:	5d                   	pop    %ebp
  800ff0:	c3                   	ret    

00800ff1 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800ff1:	55                   	push   %ebp
  800ff2:	89 e5                	mov    %esp,%ebp
  800ff4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ff7:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ffc:	89 c2                	mov    %eax,%edx
  800ffe:	c1 ea 16             	shr    $0x16,%edx
  801001:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801008:	f6 c2 01             	test   $0x1,%dl
  80100b:	74 11                	je     80101e <fd_alloc+0x2d>
  80100d:	89 c2                	mov    %eax,%edx
  80100f:	c1 ea 0c             	shr    $0xc,%edx
  801012:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801019:	f6 c2 01             	test   $0x1,%dl
  80101c:	75 09                	jne    801027 <fd_alloc+0x36>
			*fd_store = fd;
  80101e:	89 01                	mov    %eax,(%ecx)
			return 0;
  801020:	b8 00 00 00 00       	mov    $0x0,%eax
  801025:	eb 17                	jmp    80103e <fd_alloc+0x4d>
  801027:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80102c:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801031:	75 c9                	jne    800ffc <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801033:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801039:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80103e:	5d                   	pop    %ebp
  80103f:	c3                   	ret    

00801040 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801040:	55                   	push   %ebp
  801041:	89 e5                	mov    %esp,%ebp
  801043:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801046:	83 f8 1f             	cmp    $0x1f,%eax
  801049:	77 36                	ja     801081 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80104b:	c1 e0 0c             	shl    $0xc,%eax
  80104e:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801053:	89 c2                	mov    %eax,%edx
  801055:	c1 ea 16             	shr    $0x16,%edx
  801058:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80105f:	f6 c2 01             	test   $0x1,%dl
  801062:	74 24                	je     801088 <fd_lookup+0x48>
  801064:	89 c2                	mov    %eax,%edx
  801066:	c1 ea 0c             	shr    $0xc,%edx
  801069:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801070:	f6 c2 01             	test   $0x1,%dl
  801073:	74 1a                	je     80108f <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801075:	8b 55 0c             	mov    0xc(%ebp),%edx
  801078:	89 02                	mov    %eax,(%edx)
	return 0;
  80107a:	b8 00 00 00 00       	mov    $0x0,%eax
  80107f:	eb 13                	jmp    801094 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801081:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801086:	eb 0c                	jmp    801094 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801088:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80108d:	eb 05                	jmp    801094 <fd_lookup+0x54>
  80108f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801094:	5d                   	pop    %ebp
  801095:	c3                   	ret    

00801096 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801096:	55                   	push   %ebp
  801097:	89 e5                	mov    %esp,%ebp
  801099:	83 ec 08             	sub    $0x8,%esp
  80109c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80109f:	ba 28 26 80 00       	mov    $0x802628,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8010a4:	eb 13                	jmp    8010b9 <dev_lookup+0x23>
  8010a6:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8010a9:	39 08                	cmp    %ecx,(%eax)
  8010ab:	75 0c                	jne    8010b9 <dev_lookup+0x23>
			*dev = devtab[i];
  8010ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010b0:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8010b7:	eb 2e                	jmp    8010e7 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8010b9:	8b 02                	mov    (%edx),%eax
  8010bb:	85 c0                	test   %eax,%eax
  8010bd:	75 e7                	jne    8010a6 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8010bf:	a1 04 40 80 00       	mov    0x804004,%eax
  8010c4:	8b 40 48             	mov    0x48(%eax),%eax
  8010c7:	83 ec 04             	sub    $0x4,%esp
  8010ca:	51                   	push   %ecx
  8010cb:	50                   	push   %eax
  8010cc:	68 ac 25 80 00       	push   $0x8025ac
  8010d1:	e8 d2 f0 ff ff       	call   8001a8 <cprintf>
	*dev = 0;
  8010d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010d9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8010df:	83 c4 10             	add    $0x10,%esp
  8010e2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8010e7:	c9                   	leave  
  8010e8:	c3                   	ret    

008010e9 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8010e9:	55                   	push   %ebp
  8010ea:	89 e5                	mov    %esp,%ebp
  8010ec:	56                   	push   %esi
  8010ed:	53                   	push   %ebx
  8010ee:	83 ec 10             	sub    $0x10,%esp
  8010f1:	8b 75 08             	mov    0x8(%ebp),%esi
  8010f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8010f7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010fa:	50                   	push   %eax
  8010fb:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801101:	c1 e8 0c             	shr    $0xc,%eax
  801104:	50                   	push   %eax
  801105:	e8 36 ff ff ff       	call   801040 <fd_lookup>
  80110a:	83 c4 08             	add    $0x8,%esp
  80110d:	85 c0                	test   %eax,%eax
  80110f:	78 05                	js     801116 <fd_close+0x2d>
	    || fd != fd2)
  801111:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801114:	74 0c                	je     801122 <fd_close+0x39>
		return (must_exist ? r : 0);
  801116:	84 db                	test   %bl,%bl
  801118:	ba 00 00 00 00       	mov    $0x0,%edx
  80111d:	0f 44 c2             	cmove  %edx,%eax
  801120:	eb 41                	jmp    801163 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801122:	83 ec 08             	sub    $0x8,%esp
  801125:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801128:	50                   	push   %eax
  801129:	ff 36                	pushl  (%esi)
  80112b:	e8 66 ff ff ff       	call   801096 <dev_lookup>
  801130:	89 c3                	mov    %eax,%ebx
  801132:	83 c4 10             	add    $0x10,%esp
  801135:	85 c0                	test   %eax,%eax
  801137:	78 1a                	js     801153 <fd_close+0x6a>
		if (dev->dev_close)
  801139:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80113c:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80113f:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801144:	85 c0                	test   %eax,%eax
  801146:	74 0b                	je     801153 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801148:	83 ec 0c             	sub    $0xc,%esp
  80114b:	56                   	push   %esi
  80114c:	ff d0                	call   *%eax
  80114e:	89 c3                	mov    %eax,%ebx
  801150:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801153:	83 ec 08             	sub    $0x8,%esp
  801156:	56                   	push   %esi
  801157:	6a 00                	push   $0x0
  801159:	e8 57 fa ff ff       	call   800bb5 <sys_page_unmap>
	return r;
  80115e:	83 c4 10             	add    $0x10,%esp
  801161:	89 d8                	mov    %ebx,%eax
}
  801163:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801166:	5b                   	pop    %ebx
  801167:	5e                   	pop    %esi
  801168:	5d                   	pop    %ebp
  801169:	c3                   	ret    

0080116a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80116a:	55                   	push   %ebp
  80116b:	89 e5                	mov    %esp,%ebp
  80116d:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801170:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801173:	50                   	push   %eax
  801174:	ff 75 08             	pushl  0x8(%ebp)
  801177:	e8 c4 fe ff ff       	call   801040 <fd_lookup>
  80117c:	83 c4 08             	add    $0x8,%esp
  80117f:	85 c0                	test   %eax,%eax
  801181:	78 10                	js     801193 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801183:	83 ec 08             	sub    $0x8,%esp
  801186:	6a 01                	push   $0x1
  801188:	ff 75 f4             	pushl  -0xc(%ebp)
  80118b:	e8 59 ff ff ff       	call   8010e9 <fd_close>
  801190:	83 c4 10             	add    $0x10,%esp
}
  801193:	c9                   	leave  
  801194:	c3                   	ret    

00801195 <close_all>:

void
close_all(void)
{
  801195:	55                   	push   %ebp
  801196:	89 e5                	mov    %esp,%ebp
  801198:	53                   	push   %ebx
  801199:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80119c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8011a1:	83 ec 0c             	sub    $0xc,%esp
  8011a4:	53                   	push   %ebx
  8011a5:	e8 c0 ff ff ff       	call   80116a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8011aa:	83 c3 01             	add    $0x1,%ebx
  8011ad:	83 c4 10             	add    $0x10,%esp
  8011b0:	83 fb 20             	cmp    $0x20,%ebx
  8011b3:	75 ec                	jne    8011a1 <close_all+0xc>
		close(i);
}
  8011b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011b8:	c9                   	leave  
  8011b9:	c3                   	ret    

008011ba <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8011ba:	55                   	push   %ebp
  8011bb:	89 e5                	mov    %esp,%ebp
  8011bd:	57                   	push   %edi
  8011be:	56                   	push   %esi
  8011bf:	53                   	push   %ebx
  8011c0:	83 ec 2c             	sub    $0x2c,%esp
  8011c3:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8011c6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8011c9:	50                   	push   %eax
  8011ca:	ff 75 08             	pushl  0x8(%ebp)
  8011cd:	e8 6e fe ff ff       	call   801040 <fd_lookup>
  8011d2:	83 c4 08             	add    $0x8,%esp
  8011d5:	85 c0                	test   %eax,%eax
  8011d7:	0f 88 c1 00 00 00    	js     80129e <dup+0xe4>
		return r;
	close(newfdnum);
  8011dd:	83 ec 0c             	sub    $0xc,%esp
  8011e0:	56                   	push   %esi
  8011e1:	e8 84 ff ff ff       	call   80116a <close>

	newfd = INDEX2FD(newfdnum);
  8011e6:	89 f3                	mov    %esi,%ebx
  8011e8:	c1 e3 0c             	shl    $0xc,%ebx
  8011eb:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8011f1:	83 c4 04             	add    $0x4,%esp
  8011f4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011f7:	e8 de fd ff ff       	call   800fda <fd2data>
  8011fc:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8011fe:	89 1c 24             	mov    %ebx,(%esp)
  801201:	e8 d4 fd ff ff       	call   800fda <fd2data>
  801206:	83 c4 10             	add    $0x10,%esp
  801209:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80120c:	89 f8                	mov    %edi,%eax
  80120e:	c1 e8 16             	shr    $0x16,%eax
  801211:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801218:	a8 01                	test   $0x1,%al
  80121a:	74 37                	je     801253 <dup+0x99>
  80121c:	89 f8                	mov    %edi,%eax
  80121e:	c1 e8 0c             	shr    $0xc,%eax
  801221:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801228:	f6 c2 01             	test   $0x1,%dl
  80122b:	74 26                	je     801253 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80122d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801234:	83 ec 0c             	sub    $0xc,%esp
  801237:	25 07 0e 00 00       	and    $0xe07,%eax
  80123c:	50                   	push   %eax
  80123d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801240:	6a 00                	push   $0x0
  801242:	57                   	push   %edi
  801243:	6a 00                	push   $0x0
  801245:	e8 29 f9 ff ff       	call   800b73 <sys_page_map>
  80124a:	89 c7                	mov    %eax,%edi
  80124c:	83 c4 20             	add    $0x20,%esp
  80124f:	85 c0                	test   %eax,%eax
  801251:	78 2e                	js     801281 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801253:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801256:	89 d0                	mov    %edx,%eax
  801258:	c1 e8 0c             	shr    $0xc,%eax
  80125b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801262:	83 ec 0c             	sub    $0xc,%esp
  801265:	25 07 0e 00 00       	and    $0xe07,%eax
  80126a:	50                   	push   %eax
  80126b:	53                   	push   %ebx
  80126c:	6a 00                	push   $0x0
  80126e:	52                   	push   %edx
  80126f:	6a 00                	push   $0x0
  801271:	e8 fd f8 ff ff       	call   800b73 <sys_page_map>
  801276:	89 c7                	mov    %eax,%edi
  801278:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80127b:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80127d:	85 ff                	test   %edi,%edi
  80127f:	79 1d                	jns    80129e <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801281:	83 ec 08             	sub    $0x8,%esp
  801284:	53                   	push   %ebx
  801285:	6a 00                	push   $0x0
  801287:	e8 29 f9 ff ff       	call   800bb5 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80128c:	83 c4 08             	add    $0x8,%esp
  80128f:	ff 75 d4             	pushl  -0x2c(%ebp)
  801292:	6a 00                	push   $0x0
  801294:	e8 1c f9 ff ff       	call   800bb5 <sys_page_unmap>
	return r;
  801299:	83 c4 10             	add    $0x10,%esp
  80129c:	89 f8                	mov    %edi,%eax
}
  80129e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012a1:	5b                   	pop    %ebx
  8012a2:	5e                   	pop    %esi
  8012a3:	5f                   	pop    %edi
  8012a4:	5d                   	pop    %ebp
  8012a5:	c3                   	ret    

008012a6 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8012a6:	55                   	push   %ebp
  8012a7:	89 e5                	mov    %esp,%ebp
  8012a9:	53                   	push   %ebx
  8012aa:	83 ec 14             	sub    $0x14,%esp
  8012ad:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012b0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012b3:	50                   	push   %eax
  8012b4:	53                   	push   %ebx
  8012b5:	e8 86 fd ff ff       	call   801040 <fd_lookup>
  8012ba:	83 c4 08             	add    $0x8,%esp
  8012bd:	89 c2                	mov    %eax,%edx
  8012bf:	85 c0                	test   %eax,%eax
  8012c1:	78 6d                	js     801330 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012c3:	83 ec 08             	sub    $0x8,%esp
  8012c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012c9:	50                   	push   %eax
  8012ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012cd:	ff 30                	pushl  (%eax)
  8012cf:	e8 c2 fd ff ff       	call   801096 <dev_lookup>
  8012d4:	83 c4 10             	add    $0x10,%esp
  8012d7:	85 c0                	test   %eax,%eax
  8012d9:	78 4c                	js     801327 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8012db:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8012de:	8b 42 08             	mov    0x8(%edx),%eax
  8012e1:	83 e0 03             	and    $0x3,%eax
  8012e4:	83 f8 01             	cmp    $0x1,%eax
  8012e7:	75 21                	jne    80130a <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8012e9:	a1 04 40 80 00       	mov    0x804004,%eax
  8012ee:	8b 40 48             	mov    0x48(%eax),%eax
  8012f1:	83 ec 04             	sub    $0x4,%esp
  8012f4:	53                   	push   %ebx
  8012f5:	50                   	push   %eax
  8012f6:	68 ed 25 80 00       	push   $0x8025ed
  8012fb:	e8 a8 ee ff ff       	call   8001a8 <cprintf>
		return -E_INVAL;
  801300:	83 c4 10             	add    $0x10,%esp
  801303:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801308:	eb 26                	jmp    801330 <read+0x8a>
	}
	if (!dev->dev_read)
  80130a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80130d:	8b 40 08             	mov    0x8(%eax),%eax
  801310:	85 c0                	test   %eax,%eax
  801312:	74 17                	je     80132b <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801314:	83 ec 04             	sub    $0x4,%esp
  801317:	ff 75 10             	pushl  0x10(%ebp)
  80131a:	ff 75 0c             	pushl  0xc(%ebp)
  80131d:	52                   	push   %edx
  80131e:	ff d0                	call   *%eax
  801320:	89 c2                	mov    %eax,%edx
  801322:	83 c4 10             	add    $0x10,%esp
  801325:	eb 09                	jmp    801330 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801327:	89 c2                	mov    %eax,%edx
  801329:	eb 05                	jmp    801330 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80132b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801330:	89 d0                	mov    %edx,%eax
  801332:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801335:	c9                   	leave  
  801336:	c3                   	ret    

00801337 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801337:	55                   	push   %ebp
  801338:	89 e5                	mov    %esp,%ebp
  80133a:	57                   	push   %edi
  80133b:	56                   	push   %esi
  80133c:	53                   	push   %ebx
  80133d:	83 ec 0c             	sub    $0xc,%esp
  801340:	8b 7d 08             	mov    0x8(%ebp),%edi
  801343:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801346:	bb 00 00 00 00       	mov    $0x0,%ebx
  80134b:	eb 21                	jmp    80136e <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80134d:	83 ec 04             	sub    $0x4,%esp
  801350:	89 f0                	mov    %esi,%eax
  801352:	29 d8                	sub    %ebx,%eax
  801354:	50                   	push   %eax
  801355:	89 d8                	mov    %ebx,%eax
  801357:	03 45 0c             	add    0xc(%ebp),%eax
  80135a:	50                   	push   %eax
  80135b:	57                   	push   %edi
  80135c:	e8 45 ff ff ff       	call   8012a6 <read>
		if (m < 0)
  801361:	83 c4 10             	add    $0x10,%esp
  801364:	85 c0                	test   %eax,%eax
  801366:	78 10                	js     801378 <readn+0x41>
			return m;
		if (m == 0)
  801368:	85 c0                	test   %eax,%eax
  80136a:	74 0a                	je     801376 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80136c:	01 c3                	add    %eax,%ebx
  80136e:	39 f3                	cmp    %esi,%ebx
  801370:	72 db                	jb     80134d <readn+0x16>
  801372:	89 d8                	mov    %ebx,%eax
  801374:	eb 02                	jmp    801378 <readn+0x41>
  801376:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801378:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80137b:	5b                   	pop    %ebx
  80137c:	5e                   	pop    %esi
  80137d:	5f                   	pop    %edi
  80137e:	5d                   	pop    %ebp
  80137f:	c3                   	ret    

00801380 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801380:	55                   	push   %ebp
  801381:	89 e5                	mov    %esp,%ebp
  801383:	53                   	push   %ebx
  801384:	83 ec 14             	sub    $0x14,%esp
  801387:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80138a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80138d:	50                   	push   %eax
  80138e:	53                   	push   %ebx
  80138f:	e8 ac fc ff ff       	call   801040 <fd_lookup>
  801394:	83 c4 08             	add    $0x8,%esp
  801397:	89 c2                	mov    %eax,%edx
  801399:	85 c0                	test   %eax,%eax
  80139b:	78 68                	js     801405 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80139d:	83 ec 08             	sub    $0x8,%esp
  8013a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013a3:	50                   	push   %eax
  8013a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013a7:	ff 30                	pushl  (%eax)
  8013a9:	e8 e8 fc ff ff       	call   801096 <dev_lookup>
  8013ae:	83 c4 10             	add    $0x10,%esp
  8013b1:	85 c0                	test   %eax,%eax
  8013b3:	78 47                	js     8013fc <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013b8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013bc:	75 21                	jne    8013df <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8013be:	a1 04 40 80 00       	mov    0x804004,%eax
  8013c3:	8b 40 48             	mov    0x48(%eax),%eax
  8013c6:	83 ec 04             	sub    $0x4,%esp
  8013c9:	53                   	push   %ebx
  8013ca:	50                   	push   %eax
  8013cb:	68 09 26 80 00       	push   $0x802609
  8013d0:	e8 d3 ed ff ff       	call   8001a8 <cprintf>
		return -E_INVAL;
  8013d5:	83 c4 10             	add    $0x10,%esp
  8013d8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013dd:	eb 26                	jmp    801405 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8013df:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013e2:	8b 52 0c             	mov    0xc(%edx),%edx
  8013e5:	85 d2                	test   %edx,%edx
  8013e7:	74 17                	je     801400 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8013e9:	83 ec 04             	sub    $0x4,%esp
  8013ec:	ff 75 10             	pushl  0x10(%ebp)
  8013ef:	ff 75 0c             	pushl  0xc(%ebp)
  8013f2:	50                   	push   %eax
  8013f3:	ff d2                	call   *%edx
  8013f5:	89 c2                	mov    %eax,%edx
  8013f7:	83 c4 10             	add    $0x10,%esp
  8013fa:	eb 09                	jmp    801405 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013fc:	89 c2                	mov    %eax,%edx
  8013fe:	eb 05                	jmp    801405 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801400:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801405:	89 d0                	mov    %edx,%eax
  801407:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80140a:	c9                   	leave  
  80140b:	c3                   	ret    

0080140c <seek>:

int
seek(int fdnum, off_t offset)
{
  80140c:	55                   	push   %ebp
  80140d:	89 e5                	mov    %esp,%ebp
  80140f:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801412:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801415:	50                   	push   %eax
  801416:	ff 75 08             	pushl  0x8(%ebp)
  801419:	e8 22 fc ff ff       	call   801040 <fd_lookup>
  80141e:	83 c4 08             	add    $0x8,%esp
  801421:	85 c0                	test   %eax,%eax
  801423:	78 0e                	js     801433 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801425:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801428:	8b 55 0c             	mov    0xc(%ebp),%edx
  80142b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80142e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801433:	c9                   	leave  
  801434:	c3                   	ret    

00801435 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801435:	55                   	push   %ebp
  801436:	89 e5                	mov    %esp,%ebp
  801438:	53                   	push   %ebx
  801439:	83 ec 14             	sub    $0x14,%esp
  80143c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80143f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801442:	50                   	push   %eax
  801443:	53                   	push   %ebx
  801444:	e8 f7 fb ff ff       	call   801040 <fd_lookup>
  801449:	83 c4 08             	add    $0x8,%esp
  80144c:	89 c2                	mov    %eax,%edx
  80144e:	85 c0                	test   %eax,%eax
  801450:	78 65                	js     8014b7 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801452:	83 ec 08             	sub    $0x8,%esp
  801455:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801458:	50                   	push   %eax
  801459:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80145c:	ff 30                	pushl  (%eax)
  80145e:	e8 33 fc ff ff       	call   801096 <dev_lookup>
  801463:	83 c4 10             	add    $0x10,%esp
  801466:	85 c0                	test   %eax,%eax
  801468:	78 44                	js     8014ae <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80146a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80146d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801471:	75 21                	jne    801494 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801473:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801478:	8b 40 48             	mov    0x48(%eax),%eax
  80147b:	83 ec 04             	sub    $0x4,%esp
  80147e:	53                   	push   %ebx
  80147f:	50                   	push   %eax
  801480:	68 cc 25 80 00       	push   $0x8025cc
  801485:	e8 1e ed ff ff       	call   8001a8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80148a:	83 c4 10             	add    $0x10,%esp
  80148d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801492:	eb 23                	jmp    8014b7 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801494:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801497:	8b 52 18             	mov    0x18(%edx),%edx
  80149a:	85 d2                	test   %edx,%edx
  80149c:	74 14                	je     8014b2 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80149e:	83 ec 08             	sub    $0x8,%esp
  8014a1:	ff 75 0c             	pushl  0xc(%ebp)
  8014a4:	50                   	push   %eax
  8014a5:	ff d2                	call   *%edx
  8014a7:	89 c2                	mov    %eax,%edx
  8014a9:	83 c4 10             	add    $0x10,%esp
  8014ac:	eb 09                	jmp    8014b7 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014ae:	89 c2                	mov    %eax,%edx
  8014b0:	eb 05                	jmp    8014b7 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8014b2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8014b7:	89 d0                	mov    %edx,%eax
  8014b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014bc:	c9                   	leave  
  8014bd:	c3                   	ret    

008014be <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8014be:	55                   	push   %ebp
  8014bf:	89 e5                	mov    %esp,%ebp
  8014c1:	53                   	push   %ebx
  8014c2:	83 ec 14             	sub    $0x14,%esp
  8014c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014c8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014cb:	50                   	push   %eax
  8014cc:	ff 75 08             	pushl  0x8(%ebp)
  8014cf:	e8 6c fb ff ff       	call   801040 <fd_lookup>
  8014d4:	83 c4 08             	add    $0x8,%esp
  8014d7:	89 c2                	mov    %eax,%edx
  8014d9:	85 c0                	test   %eax,%eax
  8014db:	78 58                	js     801535 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014dd:	83 ec 08             	sub    $0x8,%esp
  8014e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014e3:	50                   	push   %eax
  8014e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014e7:	ff 30                	pushl  (%eax)
  8014e9:	e8 a8 fb ff ff       	call   801096 <dev_lookup>
  8014ee:	83 c4 10             	add    $0x10,%esp
  8014f1:	85 c0                	test   %eax,%eax
  8014f3:	78 37                	js     80152c <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8014f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014f8:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8014fc:	74 32                	je     801530 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8014fe:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801501:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801508:	00 00 00 
	stat->st_isdir = 0;
  80150b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801512:	00 00 00 
	stat->st_dev = dev;
  801515:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80151b:	83 ec 08             	sub    $0x8,%esp
  80151e:	53                   	push   %ebx
  80151f:	ff 75 f0             	pushl  -0x10(%ebp)
  801522:	ff 50 14             	call   *0x14(%eax)
  801525:	89 c2                	mov    %eax,%edx
  801527:	83 c4 10             	add    $0x10,%esp
  80152a:	eb 09                	jmp    801535 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80152c:	89 c2                	mov    %eax,%edx
  80152e:	eb 05                	jmp    801535 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801530:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801535:	89 d0                	mov    %edx,%eax
  801537:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80153a:	c9                   	leave  
  80153b:	c3                   	ret    

0080153c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80153c:	55                   	push   %ebp
  80153d:	89 e5                	mov    %esp,%ebp
  80153f:	56                   	push   %esi
  801540:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801541:	83 ec 08             	sub    $0x8,%esp
  801544:	6a 00                	push   $0x0
  801546:	ff 75 08             	pushl  0x8(%ebp)
  801549:	e8 0c 02 00 00       	call   80175a <open>
  80154e:	89 c3                	mov    %eax,%ebx
  801550:	83 c4 10             	add    $0x10,%esp
  801553:	85 c0                	test   %eax,%eax
  801555:	78 1b                	js     801572 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801557:	83 ec 08             	sub    $0x8,%esp
  80155a:	ff 75 0c             	pushl  0xc(%ebp)
  80155d:	50                   	push   %eax
  80155e:	e8 5b ff ff ff       	call   8014be <fstat>
  801563:	89 c6                	mov    %eax,%esi
	close(fd);
  801565:	89 1c 24             	mov    %ebx,(%esp)
  801568:	e8 fd fb ff ff       	call   80116a <close>
	return r;
  80156d:	83 c4 10             	add    $0x10,%esp
  801570:	89 f0                	mov    %esi,%eax
}
  801572:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801575:	5b                   	pop    %ebx
  801576:	5e                   	pop    %esi
  801577:	5d                   	pop    %ebp
  801578:	c3                   	ret    

00801579 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801579:	55                   	push   %ebp
  80157a:	89 e5                	mov    %esp,%ebp
  80157c:	56                   	push   %esi
  80157d:	53                   	push   %ebx
  80157e:	89 c6                	mov    %eax,%esi
  801580:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801582:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801589:	75 12                	jne    80159d <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80158b:	83 ec 0c             	sub    $0xc,%esp
  80158e:	6a 01                	push   $0x1
  801590:	e8 c1 08 00 00       	call   801e56 <ipc_find_env>
  801595:	a3 00 40 80 00       	mov    %eax,0x804000
  80159a:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80159d:	6a 07                	push   $0x7
  80159f:	68 00 50 80 00       	push   $0x805000
  8015a4:	56                   	push   %esi
  8015a5:	ff 35 00 40 80 00    	pushl  0x804000
  8015ab:	e8 52 08 00 00       	call   801e02 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8015b0:	83 c4 0c             	add    $0xc,%esp
  8015b3:	6a 00                	push   $0x0
  8015b5:	53                   	push   %ebx
  8015b6:	6a 00                	push   $0x0
  8015b8:	e8 dc 07 00 00       	call   801d99 <ipc_recv>
}
  8015bd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015c0:	5b                   	pop    %ebx
  8015c1:	5e                   	pop    %esi
  8015c2:	5d                   	pop    %ebp
  8015c3:	c3                   	ret    

008015c4 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8015c4:	55                   	push   %ebp
  8015c5:	89 e5                	mov    %esp,%ebp
  8015c7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8015ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8015cd:	8b 40 0c             	mov    0xc(%eax),%eax
  8015d0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8015d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015d8:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8015dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8015e2:	b8 02 00 00 00       	mov    $0x2,%eax
  8015e7:	e8 8d ff ff ff       	call   801579 <fsipc>
}
  8015ec:	c9                   	leave  
  8015ed:	c3                   	ret    

008015ee <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8015ee:	55                   	push   %ebp
  8015ef:	89 e5                	mov    %esp,%ebp
  8015f1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8015f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8015f7:	8b 40 0c             	mov    0xc(%eax),%eax
  8015fa:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8015ff:	ba 00 00 00 00       	mov    $0x0,%edx
  801604:	b8 06 00 00 00       	mov    $0x6,%eax
  801609:	e8 6b ff ff ff       	call   801579 <fsipc>
}
  80160e:	c9                   	leave  
  80160f:	c3                   	ret    

00801610 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801610:	55                   	push   %ebp
  801611:	89 e5                	mov    %esp,%ebp
  801613:	53                   	push   %ebx
  801614:	83 ec 04             	sub    $0x4,%esp
  801617:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80161a:	8b 45 08             	mov    0x8(%ebp),%eax
  80161d:	8b 40 0c             	mov    0xc(%eax),%eax
  801620:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801625:	ba 00 00 00 00       	mov    $0x0,%edx
  80162a:	b8 05 00 00 00       	mov    $0x5,%eax
  80162f:	e8 45 ff ff ff       	call   801579 <fsipc>
  801634:	85 c0                	test   %eax,%eax
  801636:	78 2c                	js     801664 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801638:	83 ec 08             	sub    $0x8,%esp
  80163b:	68 00 50 80 00       	push   $0x805000
  801640:	53                   	push   %ebx
  801641:	e8 e7 f0 ff ff       	call   80072d <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801646:	a1 80 50 80 00       	mov    0x805080,%eax
  80164b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801651:	a1 84 50 80 00       	mov    0x805084,%eax
  801656:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80165c:	83 c4 10             	add    $0x10,%esp
  80165f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801664:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801667:	c9                   	leave  
  801668:	c3                   	ret    

00801669 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801669:	55                   	push   %ebp
  80166a:	89 e5                	mov    %esp,%ebp
  80166c:	53                   	push   %ebx
  80166d:	83 ec 08             	sub    $0x8,%esp
  801670:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801673:	8b 55 08             	mov    0x8(%ebp),%edx
  801676:	8b 52 0c             	mov    0xc(%edx),%edx
  801679:	89 15 00 50 80 00    	mov    %edx,0x805000
  80167f:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801684:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  801689:	0f 46 d8             	cmovbe %eax,%ebx
	
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  80168c:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  801692:	53                   	push   %ebx
  801693:	ff 75 0c             	pushl  0xc(%ebp)
  801696:	68 08 50 80 00       	push   $0x805008
  80169b:	e8 1f f2 ff ff       	call   8008bf <memmove>

	
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) 
  8016a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8016a5:	b8 04 00 00 00       	mov    $0x4,%eax
  8016aa:	e8 ca fe ff ff       	call   801579 <fsipc>
  8016af:	83 c4 10             	add    $0x10,%esp
  8016b2:	85 c0                	test   %eax,%eax
  8016b4:	78 1d                	js     8016d3 <devfile_write+0x6a>
		return r;
	assert(r <= n_real); 
  8016b6:	39 d8                	cmp    %ebx,%eax
  8016b8:	76 19                	jbe    8016d3 <devfile_write+0x6a>
  8016ba:	68 38 26 80 00       	push   $0x802638
  8016bf:	68 44 26 80 00       	push   $0x802644
  8016c4:	68 a3 00 00 00       	push   $0xa3
  8016c9:	68 59 26 80 00       	push   $0x802659
  8016ce:	e8 0a 06 00 00       	call   801cdd <_panic>
	return r;
}
  8016d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016d6:	c9                   	leave  
  8016d7:	c3                   	ret    

008016d8 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8016d8:	55                   	push   %ebp
  8016d9:	89 e5                	mov    %esp,%ebp
  8016db:	56                   	push   %esi
  8016dc:	53                   	push   %ebx
  8016dd:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8016e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e3:	8b 40 0c             	mov    0xc(%eax),%eax
  8016e6:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8016eb:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8016f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8016f6:	b8 03 00 00 00       	mov    $0x3,%eax
  8016fb:	e8 79 fe ff ff       	call   801579 <fsipc>
  801700:	89 c3                	mov    %eax,%ebx
  801702:	85 c0                	test   %eax,%eax
  801704:	78 4b                	js     801751 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801706:	39 c6                	cmp    %eax,%esi
  801708:	73 16                	jae    801720 <devfile_read+0x48>
  80170a:	68 64 26 80 00       	push   $0x802664
  80170f:	68 44 26 80 00       	push   $0x802644
  801714:	6a 7c                	push   $0x7c
  801716:	68 59 26 80 00       	push   $0x802659
  80171b:	e8 bd 05 00 00       	call   801cdd <_panic>
	assert(r <= PGSIZE);
  801720:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801725:	7e 16                	jle    80173d <devfile_read+0x65>
  801727:	68 6b 26 80 00       	push   $0x80266b
  80172c:	68 44 26 80 00       	push   $0x802644
  801731:	6a 7d                	push   $0x7d
  801733:	68 59 26 80 00       	push   $0x802659
  801738:	e8 a0 05 00 00       	call   801cdd <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80173d:	83 ec 04             	sub    $0x4,%esp
  801740:	50                   	push   %eax
  801741:	68 00 50 80 00       	push   $0x805000
  801746:	ff 75 0c             	pushl  0xc(%ebp)
  801749:	e8 71 f1 ff ff       	call   8008bf <memmove>
	return r;
  80174e:	83 c4 10             	add    $0x10,%esp
}
  801751:	89 d8                	mov    %ebx,%eax
  801753:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801756:	5b                   	pop    %ebx
  801757:	5e                   	pop    %esi
  801758:	5d                   	pop    %ebp
  801759:	c3                   	ret    

0080175a <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80175a:	55                   	push   %ebp
  80175b:	89 e5                	mov    %esp,%ebp
  80175d:	53                   	push   %ebx
  80175e:	83 ec 20             	sub    $0x20,%esp
  801761:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801764:	53                   	push   %ebx
  801765:	e8 8a ef ff ff       	call   8006f4 <strlen>
  80176a:	83 c4 10             	add    $0x10,%esp
  80176d:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801772:	7f 67                	jg     8017db <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801774:	83 ec 0c             	sub    $0xc,%esp
  801777:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80177a:	50                   	push   %eax
  80177b:	e8 71 f8 ff ff       	call   800ff1 <fd_alloc>
  801780:	83 c4 10             	add    $0x10,%esp
		return r;
  801783:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801785:	85 c0                	test   %eax,%eax
  801787:	78 57                	js     8017e0 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801789:	83 ec 08             	sub    $0x8,%esp
  80178c:	53                   	push   %ebx
  80178d:	68 00 50 80 00       	push   $0x805000
  801792:	e8 96 ef ff ff       	call   80072d <strcpy>
	fsipcbuf.open.req_omode = mode;
  801797:	8b 45 0c             	mov    0xc(%ebp),%eax
  80179a:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80179f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017a2:	b8 01 00 00 00       	mov    $0x1,%eax
  8017a7:	e8 cd fd ff ff       	call   801579 <fsipc>
  8017ac:	89 c3                	mov    %eax,%ebx
  8017ae:	83 c4 10             	add    $0x10,%esp
  8017b1:	85 c0                	test   %eax,%eax
  8017b3:	79 14                	jns    8017c9 <open+0x6f>
		fd_close(fd, 0);
  8017b5:	83 ec 08             	sub    $0x8,%esp
  8017b8:	6a 00                	push   $0x0
  8017ba:	ff 75 f4             	pushl  -0xc(%ebp)
  8017bd:	e8 27 f9 ff ff       	call   8010e9 <fd_close>
		return r;
  8017c2:	83 c4 10             	add    $0x10,%esp
  8017c5:	89 da                	mov    %ebx,%edx
  8017c7:	eb 17                	jmp    8017e0 <open+0x86>
	}

	return fd2num(fd);
  8017c9:	83 ec 0c             	sub    $0xc,%esp
  8017cc:	ff 75 f4             	pushl  -0xc(%ebp)
  8017cf:	e8 f6 f7 ff ff       	call   800fca <fd2num>
  8017d4:	89 c2                	mov    %eax,%edx
  8017d6:	83 c4 10             	add    $0x10,%esp
  8017d9:	eb 05                	jmp    8017e0 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8017db:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8017e0:	89 d0                	mov    %edx,%eax
  8017e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017e5:	c9                   	leave  
  8017e6:	c3                   	ret    

008017e7 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8017e7:	55                   	push   %ebp
  8017e8:	89 e5                	mov    %esp,%ebp
  8017ea:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8017ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f2:	b8 08 00 00 00       	mov    $0x8,%eax
  8017f7:	e8 7d fd ff ff       	call   801579 <fsipc>
}
  8017fc:	c9                   	leave  
  8017fd:	c3                   	ret    

008017fe <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8017fe:	55                   	push   %ebp
  8017ff:	89 e5                	mov    %esp,%ebp
  801801:	56                   	push   %esi
  801802:	53                   	push   %ebx
  801803:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801806:	83 ec 0c             	sub    $0xc,%esp
  801809:	ff 75 08             	pushl  0x8(%ebp)
  80180c:	e8 c9 f7 ff ff       	call   800fda <fd2data>
  801811:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801813:	83 c4 08             	add    $0x8,%esp
  801816:	68 77 26 80 00       	push   $0x802677
  80181b:	53                   	push   %ebx
  80181c:	e8 0c ef ff ff       	call   80072d <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801821:	8b 46 04             	mov    0x4(%esi),%eax
  801824:	2b 06                	sub    (%esi),%eax
  801826:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80182c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801833:	00 00 00 
	stat->st_dev = &devpipe;
  801836:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80183d:	30 80 00 
	return 0;
}
  801840:	b8 00 00 00 00       	mov    $0x0,%eax
  801845:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801848:	5b                   	pop    %ebx
  801849:	5e                   	pop    %esi
  80184a:	5d                   	pop    %ebp
  80184b:	c3                   	ret    

0080184c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80184c:	55                   	push   %ebp
  80184d:	89 e5                	mov    %esp,%ebp
  80184f:	53                   	push   %ebx
  801850:	83 ec 0c             	sub    $0xc,%esp
  801853:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801856:	53                   	push   %ebx
  801857:	6a 00                	push   $0x0
  801859:	e8 57 f3 ff ff       	call   800bb5 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80185e:	89 1c 24             	mov    %ebx,(%esp)
  801861:	e8 74 f7 ff ff       	call   800fda <fd2data>
  801866:	83 c4 08             	add    $0x8,%esp
  801869:	50                   	push   %eax
  80186a:	6a 00                	push   $0x0
  80186c:	e8 44 f3 ff ff       	call   800bb5 <sys_page_unmap>
}
  801871:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801874:	c9                   	leave  
  801875:	c3                   	ret    

00801876 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801876:	55                   	push   %ebp
  801877:	89 e5                	mov    %esp,%ebp
  801879:	57                   	push   %edi
  80187a:	56                   	push   %esi
  80187b:	53                   	push   %ebx
  80187c:	83 ec 1c             	sub    $0x1c,%esp
  80187f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801882:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801884:	a1 04 40 80 00       	mov    0x804004,%eax
  801889:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80188c:	83 ec 0c             	sub    $0xc,%esp
  80188f:	ff 75 e0             	pushl  -0x20(%ebp)
  801892:	e8 f8 05 00 00       	call   801e8f <pageref>
  801897:	89 c3                	mov    %eax,%ebx
  801899:	89 3c 24             	mov    %edi,(%esp)
  80189c:	e8 ee 05 00 00       	call   801e8f <pageref>
  8018a1:	83 c4 10             	add    $0x10,%esp
  8018a4:	39 c3                	cmp    %eax,%ebx
  8018a6:	0f 94 c1             	sete   %cl
  8018a9:	0f b6 c9             	movzbl %cl,%ecx
  8018ac:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8018af:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8018b5:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8018b8:	39 ce                	cmp    %ecx,%esi
  8018ba:	74 1b                	je     8018d7 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8018bc:	39 c3                	cmp    %eax,%ebx
  8018be:	75 c4                	jne    801884 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8018c0:	8b 42 58             	mov    0x58(%edx),%eax
  8018c3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8018c6:	50                   	push   %eax
  8018c7:	56                   	push   %esi
  8018c8:	68 7e 26 80 00       	push   $0x80267e
  8018cd:	e8 d6 e8 ff ff       	call   8001a8 <cprintf>
  8018d2:	83 c4 10             	add    $0x10,%esp
  8018d5:	eb ad                	jmp    801884 <_pipeisclosed+0xe>
	}
}
  8018d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018dd:	5b                   	pop    %ebx
  8018de:	5e                   	pop    %esi
  8018df:	5f                   	pop    %edi
  8018e0:	5d                   	pop    %ebp
  8018e1:	c3                   	ret    

008018e2 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8018e2:	55                   	push   %ebp
  8018e3:	89 e5                	mov    %esp,%ebp
  8018e5:	57                   	push   %edi
  8018e6:	56                   	push   %esi
  8018e7:	53                   	push   %ebx
  8018e8:	83 ec 28             	sub    $0x28,%esp
  8018eb:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8018ee:	56                   	push   %esi
  8018ef:	e8 e6 f6 ff ff       	call   800fda <fd2data>
  8018f4:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018f6:	83 c4 10             	add    $0x10,%esp
  8018f9:	bf 00 00 00 00       	mov    $0x0,%edi
  8018fe:	eb 4b                	jmp    80194b <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801900:	89 da                	mov    %ebx,%edx
  801902:	89 f0                	mov    %esi,%eax
  801904:	e8 6d ff ff ff       	call   801876 <_pipeisclosed>
  801909:	85 c0                	test   %eax,%eax
  80190b:	75 48                	jne    801955 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80190d:	e8 ff f1 ff ff       	call   800b11 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801912:	8b 43 04             	mov    0x4(%ebx),%eax
  801915:	8b 0b                	mov    (%ebx),%ecx
  801917:	8d 51 20             	lea    0x20(%ecx),%edx
  80191a:	39 d0                	cmp    %edx,%eax
  80191c:	73 e2                	jae    801900 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80191e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801921:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801925:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801928:	89 c2                	mov    %eax,%edx
  80192a:	c1 fa 1f             	sar    $0x1f,%edx
  80192d:	89 d1                	mov    %edx,%ecx
  80192f:	c1 e9 1b             	shr    $0x1b,%ecx
  801932:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801935:	83 e2 1f             	and    $0x1f,%edx
  801938:	29 ca                	sub    %ecx,%edx
  80193a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80193e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801942:	83 c0 01             	add    $0x1,%eax
  801945:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801948:	83 c7 01             	add    $0x1,%edi
  80194b:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80194e:	75 c2                	jne    801912 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801950:	8b 45 10             	mov    0x10(%ebp),%eax
  801953:	eb 05                	jmp    80195a <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801955:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80195a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80195d:	5b                   	pop    %ebx
  80195e:	5e                   	pop    %esi
  80195f:	5f                   	pop    %edi
  801960:	5d                   	pop    %ebp
  801961:	c3                   	ret    

00801962 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801962:	55                   	push   %ebp
  801963:	89 e5                	mov    %esp,%ebp
  801965:	57                   	push   %edi
  801966:	56                   	push   %esi
  801967:	53                   	push   %ebx
  801968:	83 ec 18             	sub    $0x18,%esp
  80196b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80196e:	57                   	push   %edi
  80196f:	e8 66 f6 ff ff       	call   800fda <fd2data>
  801974:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801976:	83 c4 10             	add    $0x10,%esp
  801979:	bb 00 00 00 00       	mov    $0x0,%ebx
  80197e:	eb 3d                	jmp    8019bd <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801980:	85 db                	test   %ebx,%ebx
  801982:	74 04                	je     801988 <devpipe_read+0x26>
				return i;
  801984:	89 d8                	mov    %ebx,%eax
  801986:	eb 44                	jmp    8019cc <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801988:	89 f2                	mov    %esi,%edx
  80198a:	89 f8                	mov    %edi,%eax
  80198c:	e8 e5 fe ff ff       	call   801876 <_pipeisclosed>
  801991:	85 c0                	test   %eax,%eax
  801993:	75 32                	jne    8019c7 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801995:	e8 77 f1 ff ff       	call   800b11 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80199a:	8b 06                	mov    (%esi),%eax
  80199c:	3b 46 04             	cmp    0x4(%esi),%eax
  80199f:	74 df                	je     801980 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8019a1:	99                   	cltd   
  8019a2:	c1 ea 1b             	shr    $0x1b,%edx
  8019a5:	01 d0                	add    %edx,%eax
  8019a7:	83 e0 1f             	and    $0x1f,%eax
  8019aa:	29 d0                	sub    %edx,%eax
  8019ac:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8019b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019b4:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8019b7:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019ba:	83 c3 01             	add    $0x1,%ebx
  8019bd:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8019c0:	75 d8                	jne    80199a <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8019c2:	8b 45 10             	mov    0x10(%ebp),%eax
  8019c5:	eb 05                	jmp    8019cc <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019c7:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8019cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019cf:	5b                   	pop    %ebx
  8019d0:	5e                   	pop    %esi
  8019d1:	5f                   	pop    %edi
  8019d2:	5d                   	pop    %ebp
  8019d3:	c3                   	ret    

008019d4 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8019d4:	55                   	push   %ebp
  8019d5:	89 e5                	mov    %esp,%ebp
  8019d7:	56                   	push   %esi
  8019d8:	53                   	push   %ebx
  8019d9:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8019dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019df:	50                   	push   %eax
  8019e0:	e8 0c f6 ff ff       	call   800ff1 <fd_alloc>
  8019e5:	83 c4 10             	add    $0x10,%esp
  8019e8:	89 c2                	mov    %eax,%edx
  8019ea:	85 c0                	test   %eax,%eax
  8019ec:	0f 88 2c 01 00 00    	js     801b1e <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019f2:	83 ec 04             	sub    $0x4,%esp
  8019f5:	68 07 04 00 00       	push   $0x407
  8019fa:	ff 75 f4             	pushl  -0xc(%ebp)
  8019fd:	6a 00                	push   $0x0
  8019ff:	e8 2c f1 ff ff       	call   800b30 <sys_page_alloc>
  801a04:	83 c4 10             	add    $0x10,%esp
  801a07:	89 c2                	mov    %eax,%edx
  801a09:	85 c0                	test   %eax,%eax
  801a0b:	0f 88 0d 01 00 00    	js     801b1e <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801a11:	83 ec 0c             	sub    $0xc,%esp
  801a14:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a17:	50                   	push   %eax
  801a18:	e8 d4 f5 ff ff       	call   800ff1 <fd_alloc>
  801a1d:	89 c3                	mov    %eax,%ebx
  801a1f:	83 c4 10             	add    $0x10,%esp
  801a22:	85 c0                	test   %eax,%eax
  801a24:	0f 88 e2 00 00 00    	js     801b0c <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a2a:	83 ec 04             	sub    $0x4,%esp
  801a2d:	68 07 04 00 00       	push   $0x407
  801a32:	ff 75 f0             	pushl  -0x10(%ebp)
  801a35:	6a 00                	push   $0x0
  801a37:	e8 f4 f0 ff ff       	call   800b30 <sys_page_alloc>
  801a3c:	89 c3                	mov    %eax,%ebx
  801a3e:	83 c4 10             	add    $0x10,%esp
  801a41:	85 c0                	test   %eax,%eax
  801a43:	0f 88 c3 00 00 00    	js     801b0c <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801a49:	83 ec 0c             	sub    $0xc,%esp
  801a4c:	ff 75 f4             	pushl  -0xc(%ebp)
  801a4f:	e8 86 f5 ff ff       	call   800fda <fd2data>
  801a54:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a56:	83 c4 0c             	add    $0xc,%esp
  801a59:	68 07 04 00 00       	push   $0x407
  801a5e:	50                   	push   %eax
  801a5f:	6a 00                	push   $0x0
  801a61:	e8 ca f0 ff ff       	call   800b30 <sys_page_alloc>
  801a66:	89 c3                	mov    %eax,%ebx
  801a68:	83 c4 10             	add    $0x10,%esp
  801a6b:	85 c0                	test   %eax,%eax
  801a6d:	0f 88 89 00 00 00    	js     801afc <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a73:	83 ec 0c             	sub    $0xc,%esp
  801a76:	ff 75 f0             	pushl  -0x10(%ebp)
  801a79:	e8 5c f5 ff ff       	call   800fda <fd2data>
  801a7e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801a85:	50                   	push   %eax
  801a86:	6a 00                	push   $0x0
  801a88:	56                   	push   %esi
  801a89:	6a 00                	push   $0x0
  801a8b:	e8 e3 f0 ff ff       	call   800b73 <sys_page_map>
  801a90:	89 c3                	mov    %eax,%ebx
  801a92:	83 c4 20             	add    $0x20,%esp
  801a95:	85 c0                	test   %eax,%eax
  801a97:	78 55                	js     801aee <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801a99:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aa2:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801aa4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aa7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801aae:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ab4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ab7:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ab9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801abc:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801ac3:	83 ec 0c             	sub    $0xc,%esp
  801ac6:	ff 75 f4             	pushl  -0xc(%ebp)
  801ac9:	e8 fc f4 ff ff       	call   800fca <fd2num>
  801ace:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ad1:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ad3:	83 c4 04             	add    $0x4,%esp
  801ad6:	ff 75 f0             	pushl  -0x10(%ebp)
  801ad9:	e8 ec f4 ff ff       	call   800fca <fd2num>
  801ade:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ae1:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801ae4:	83 c4 10             	add    $0x10,%esp
  801ae7:	ba 00 00 00 00       	mov    $0x0,%edx
  801aec:	eb 30                	jmp    801b1e <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801aee:	83 ec 08             	sub    $0x8,%esp
  801af1:	56                   	push   %esi
  801af2:	6a 00                	push   $0x0
  801af4:	e8 bc f0 ff ff       	call   800bb5 <sys_page_unmap>
  801af9:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801afc:	83 ec 08             	sub    $0x8,%esp
  801aff:	ff 75 f0             	pushl  -0x10(%ebp)
  801b02:	6a 00                	push   $0x0
  801b04:	e8 ac f0 ff ff       	call   800bb5 <sys_page_unmap>
  801b09:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801b0c:	83 ec 08             	sub    $0x8,%esp
  801b0f:	ff 75 f4             	pushl  -0xc(%ebp)
  801b12:	6a 00                	push   $0x0
  801b14:	e8 9c f0 ff ff       	call   800bb5 <sys_page_unmap>
  801b19:	83 c4 10             	add    $0x10,%esp
  801b1c:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801b1e:	89 d0                	mov    %edx,%eax
  801b20:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b23:	5b                   	pop    %ebx
  801b24:	5e                   	pop    %esi
  801b25:	5d                   	pop    %ebp
  801b26:	c3                   	ret    

00801b27 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801b27:	55                   	push   %ebp
  801b28:	89 e5                	mov    %esp,%ebp
  801b2a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b2d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b30:	50                   	push   %eax
  801b31:	ff 75 08             	pushl  0x8(%ebp)
  801b34:	e8 07 f5 ff ff       	call   801040 <fd_lookup>
  801b39:	83 c4 10             	add    $0x10,%esp
  801b3c:	85 c0                	test   %eax,%eax
  801b3e:	78 18                	js     801b58 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801b40:	83 ec 0c             	sub    $0xc,%esp
  801b43:	ff 75 f4             	pushl  -0xc(%ebp)
  801b46:	e8 8f f4 ff ff       	call   800fda <fd2data>
	return _pipeisclosed(fd, p);
  801b4b:	89 c2                	mov    %eax,%edx
  801b4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b50:	e8 21 fd ff ff       	call   801876 <_pipeisclosed>
  801b55:	83 c4 10             	add    $0x10,%esp
}
  801b58:	c9                   	leave  
  801b59:	c3                   	ret    

00801b5a <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801b5a:	55                   	push   %ebp
  801b5b:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801b5d:	b8 00 00 00 00       	mov    $0x0,%eax
  801b62:	5d                   	pop    %ebp
  801b63:	c3                   	ret    

00801b64 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801b64:	55                   	push   %ebp
  801b65:	89 e5                	mov    %esp,%ebp
  801b67:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801b6a:	68 96 26 80 00       	push   $0x802696
  801b6f:	ff 75 0c             	pushl  0xc(%ebp)
  801b72:	e8 b6 eb ff ff       	call   80072d <strcpy>
	return 0;
}
  801b77:	b8 00 00 00 00       	mov    $0x0,%eax
  801b7c:	c9                   	leave  
  801b7d:	c3                   	ret    

00801b7e <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b7e:	55                   	push   %ebp
  801b7f:	89 e5                	mov    %esp,%ebp
  801b81:	57                   	push   %edi
  801b82:	56                   	push   %esi
  801b83:	53                   	push   %ebx
  801b84:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b8a:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801b8f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b95:	eb 2d                	jmp    801bc4 <devcons_write+0x46>
		m = n - tot;
  801b97:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801b9a:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801b9c:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801b9f:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801ba4:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ba7:	83 ec 04             	sub    $0x4,%esp
  801baa:	53                   	push   %ebx
  801bab:	03 45 0c             	add    0xc(%ebp),%eax
  801bae:	50                   	push   %eax
  801baf:	57                   	push   %edi
  801bb0:	e8 0a ed ff ff       	call   8008bf <memmove>
		sys_cputs(buf, m);
  801bb5:	83 c4 08             	add    $0x8,%esp
  801bb8:	53                   	push   %ebx
  801bb9:	57                   	push   %edi
  801bba:	e8 b5 ee ff ff       	call   800a74 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bbf:	01 de                	add    %ebx,%esi
  801bc1:	83 c4 10             	add    $0x10,%esp
  801bc4:	89 f0                	mov    %esi,%eax
  801bc6:	3b 75 10             	cmp    0x10(%ebp),%esi
  801bc9:	72 cc                	jb     801b97 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801bcb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bce:	5b                   	pop    %ebx
  801bcf:	5e                   	pop    %esi
  801bd0:	5f                   	pop    %edi
  801bd1:	5d                   	pop    %ebp
  801bd2:	c3                   	ret    

00801bd3 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801bd3:	55                   	push   %ebp
  801bd4:	89 e5                	mov    %esp,%ebp
  801bd6:	83 ec 08             	sub    $0x8,%esp
  801bd9:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801bde:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801be2:	74 2a                	je     801c0e <devcons_read+0x3b>
  801be4:	eb 05                	jmp    801beb <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801be6:	e8 26 ef ff ff       	call   800b11 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801beb:	e8 a2 ee ff ff       	call   800a92 <sys_cgetc>
  801bf0:	85 c0                	test   %eax,%eax
  801bf2:	74 f2                	je     801be6 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801bf4:	85 c0                	test   %eax,%eax
  801bf6:	78 16                	js     801c0e <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801bf8:	83 f8 04             	cmp    $0x4,%eax
  801bfb:	74 0c                	je     801c09 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801bfd:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c00:	88 02                	mov    %al,(%edx)
	return 1;
  801c02:	b8 01 00 00 00       	mov    $0x1,%eax
  801c07:	eb 05                	jmp    801c0e <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801c09:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801c0e:	c9                   	leave  
  801c0f:	c3                   	ret    

00801c10 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801c10:	55                   	push   %ebp
  801c11:	89 e5                	mov    %esp,%ebp
  801c13:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801c16:	8b 45 08             	mov    0x8(%ebp),%eax
  801c19:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801c1c:	6a 01                	push   $0x1
  801c1e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c21:	50                   	push   %eax
  801c22:	e8 4d ee ff ff       	call   800a74 <sys_cputs>
}
  801c27:	83 c4 10             	add    $0x10,%esp
  801c2a:	c9                   	leave  
  801c2b:	c3                   	ret    

00801c2c <getchar>:

int
getchar(void)
{
  801c2c:	55                   	push   %ebp
  801c2d:	89 e5                	mov    %esp,%ebp
  801c2f:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801c32:	6a 01                	push   $0x1
  801c34:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c37:	50                   	push   %eax
  801c38:	6a 00                	push   $0x0
  801c3a:	e8 67 f6 ff ff       	call   8012a6 <read>
	if (r < 0)
  801c3f:	83 c4 10             	add    $0x10,%esp
  801c42:	85 c0                	test   %eax,%eax
  801c44:	78 0f                	js     801c55 <getchar+0x29>
		return r;
	if (r < 1)
  801c46:	85 c0                	test   %eax,%eax
  801c48:	7e 06                	jle    801c50 <getchar+0x24>
		return -E_EOF;
	return c;
  801c4a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801c4e:	eb 05                	jmp    801c55 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801c50:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801c55:	c9                   	leave  
  801c56:	c3                   	ret    

00801c57 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801c57:	55                   	push   %ebp
  801c58:	89 e5                	mov    %esp,%ebp
  801c5a:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c5d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c60:	50                   	push   %eax
  801c61:	ff 75 08             	pushl  0x8(%ebp)
  801c64:	e8 d7 f3 ff ff       	call   801040 <fd_lookup>
  801c69:	83 c4 10             	add    $0x10,%esp
  801c6c:	85 c0                	test   %eax,%eax
  801c6e:	78 11                	js     801c81 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801c70:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c73:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c79:	39 10                	cmp    %edx,(%eax)
  801c7b:	0f 94 c0             	sete   %al
  801c7e:	0f b6 c0             	movzbl %al,%eax
}
  801c81:	c9                   	leave  
  801c82:	c3                   	ret    

00801c83 <opencons>:

int
opencons(void)
{
  801c83:	55                   	push   %ebp
  801c84:	89 e5                	mov    %esp,%ebp
  801c86:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801c89:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c8c:	50                   	push   %eax
  801c8d:	e8 5f f3 ff ff       	call   800ff1 <fd_alloc>
  801c92:	83 c4 10             	add    $0x10,%esp
		return r;
  801c95:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801c97:	85 c0                	test   %eax,%eax
  801c99:	78 3e                	js     801cd9 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801c9b:	83 ec 04             	sub    $0x4,%esp
  801c9e:	68 07 04 00 00       	push   $0x407
  801ca3:	ff 75 f4             	pushl  -0xc(%ebp)
  801ca6:	6a 00                	push   $0x0
  801ca8:	e8 83 ee ff ff       	call   800b30 <sys_page_alloc>
  801cad:	83 c4 10             	add    $0x10,%esp
		return r;
  801cb0:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801cb2:	85 c0                	test   %eax,%eax
  801cb4:	78 23                	js     801cd9 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801cb6:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cbf:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801cc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cc4:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ccb:	83 ec 0c             	sub    $0xc,%esp
  801cce:	50                   	push   %eax
  801ccf:	e8 f6 f2 ff ff       	call   800fca <fd2num>
  801cd4:	89 c2                	mov    %eax,%edx
  801cd6:	83 c4 10             	add    $0x10,%esp
}
  801cd9:	89 d0                	mov    %edx,%eax
  801cdb:	c9                   	leave  
  801cdc:	c3                   	ret    

00801cdd <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801cdd:	55                   	push   %ebp
  801cde:	89 e5                	mov    %esp,%ebp
  801ce0:	56                   	push   %esi
  801ce1:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801ce2:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801ce5:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801ceb:	e8 02 ee ff ff       	call   800af2 <sys_getenvid>
  801cf0:	83 ec 0c             	sub    $0xc,%esp
  801cf3:	ff 75 0c             	pushl  0xc(%ebp)
  801cf6:	ff 75 08             	pushl  0x8(%ebp)
  801cf9:	56                   	push   %esi
  801cfa:	50                   	push   %eax
  801cfb:	68 a4 26 80 00       	push   $0x8026a4
  801d00:	e8 a3 e4 ff ff       	call   8001a8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801d05:	83 c4 18             	add    $0x18,%esp
  801d08:	53                   	push   %ebx
  801d09:	ff 75 10             	pushl  0x10(%ebp)
  801d0c:	e8 46 e4 ff ff       	call   800157 <vcprintf>
	cprintf("\n");
  801d11:	c7 04 24 f4 21 80 00 	movl   $0x8021f4,(%esp)
  801d18:	e8 8b e4 ff ff       	call   8001a8 <cprintf>
  801d1d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801d20:	cc                   	int3   
  801d21:	eb fd                	jmp    801d20 <_panic+0x43>

00801d23 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801d23:	55                   	push   %ebp
  801d24:	89 e5                	mov    %esp,%ebp
  801d26:	53                   	push   %ebx
  801d27:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  801d2a:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801d31:	75 28                	jne    801d5b <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  801d33:	e8 ba ed ff ff       	call   800af2 <sys_getenvid>
  801d38:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_U | PTE_W);
  801d3a:	83 ec 04             	sub    $0x4,%esp
  801d3d:	6a 06                	push   $0x6
  801d3f:	68 00 f0 bf ee       	push   $0xeebff000
  801d44:	50                   	push   %eax
  801d45:	e8 e6 ed ff ff       	call   800b30 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  801d4a:	83 c4 08             	add    $0x8,%esp
  801d4d:	68 68 1d 80 00       	push   $0x801d68
  801d52:	53                   	push   %ebx
  801d53:	e8 23 ef ff ff       	call   800c7b <sys_env_set_pgfault_upcall>
  801d58:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801d5b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d5e:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801d63:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d66:	c9                   	leave  
  801d67:	c3                   	ret    

00801d68 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801d68:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801d69:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801d6e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801d70:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	# My method is different. Copy the values to the other stack
	# in a convinient way, and then pop everything.
	movl %esp, %ebp		# ebp refers to the exception stack
  801d73:	89 e5                	mov    %esp,%ebp
	movl 48(%ebp), %esp 	# go to other stack
  801d75:	8b 65 30             	mov    0x30(%ebp),%esp

	pushl 40(%ebp)		# eip - ORDER SWITCHED WITH EFLAGS
  801d78:	ff 75 28             	pushl  0x28(%ebp)
	pushl 44(%ebp)      	# eflags
  801d7b:	ff 75 2c             	pushl  0x2c(%ebp)
	pushl 36(%ebp)		# all the 8 remaining regs
  801d7e:	ff 75 24             	pushl  0x24(%ebp)
	pushl 32(%ebp)
  801d81:	ff 75 20             	pushl  0x20(%ebp)
	pushl 28(%ebp)
  801d84:	ff 75 1c             	pushl  0x1c(%ebp)
	pushl 24(%ebp)
  801d87:	ff 75 18             	pushl  0x18(%ebp)
	pushl 20(%ebp)
  801d8a:	ff 75 14             	pushl  0x14(%ebp)
	pushl 16(%ebp)
  801d8d:	ff 75 10             	pushl  0x10(%ebp)
	pushl 12(%ebp)
  801d90:	ff 75 0c             	pushl  0xc(%ebp)
	pushl 8(%ebp)
  801d93:	ff 75 08             	pushl  0x8(%ebp)

	popal			# now just pop everything!
  801d96:	61                   	popa   
	popfl
  801d97:	9d                   	popf   
	ret
  801d98:	c3                   	ret    

00801d99 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801d99:	55                   	push   %ebp
  801d9a:	89 e5                	mov    %esp,%ebp
  801d9c:	56                   	push   %esi
  801d9d:	53                   	push   %ebx
  801d9e:	8b 75 08             	mov    0x8(%ebp),%esi
  801da1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801da4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  801da7:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801da9:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801dae:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  801db1:	83 ec 0c             	sub    $0xc,%esp
  801db4:	50                   	push   %eax
  801db5:	e8 26 ef ff ff       	call   800ce0 <sys_ipc_recv>

	if (r < 0) {
  801dba:	83 c4 10             	add    $0x10,%esp
  801dbd:	85 c0                	test   %eax,%eax
  801dbf:	79 16                	jns    801dd7 <ipc_recv+0x3e>
		if (from_env_store)
  801dc1:	85 f6                	test   %esi,%esi
  801dc3:	74 06                	je     801dcb <ipc_recv+0x32>
			*from_env_store = 0;
  801dc5:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  801dcb:	85 db                	test   %ebx,%ebx
  801dcd:	74 2c                	je     801dfb <ipc_recv+0x62>
			*perm_store = 0;
  801dcf:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801dd5:	eb 24                	jmp    801dfb <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  801dd7:	85 f6                	test   %esi,%esi
  801dd9:	74 0a                	je     801de5 <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  801ddb:	a1 04 40 80 00       	mov    0x804004,%eax
  801de0:	8b 40 74             	mov    0x74(%eax),%eax
  801de3:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  801de5:	85 db                	test   %ebx,%ebx
  801de7:	74 0a                	je     801df3 <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  801de9:	a1 04 40 80 00       	mov    0x804004,%eax
  801dee:	8b 40 78             	mov    0x78(%eax),%eax
  801df1:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  801df3:	a1 04 40 80 00       	mov    0x804004,%eax
  801df8:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  801dfb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dfe:	5b                   	pop    %ebx
  801dff:	5e                   	pop    %esi
  801e00:	5d                   	pop    %ebp
  801e01:	c3                   	ret    

00801e02 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e02:	55                   	push   %ebp
  801e03:	89 e5                	mov    %esp,%ebp
  801e05:	57                   	push   %edi
  801e06:	56                   	push   %esi
  801e07:	53                   	push   %ebx
  801e08:	83 ec 0c             	sub    $0xc,%esp
  801e0b:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e0e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e11:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  801e14:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801e16:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801e1b:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  801e1e:	ff 75 14             	pushl  0x14(%ebp)
  801e21:	53                   	push   %ebx
  801e22:	56                   	push   %esi
  801e23:	57                   	push   %edi
  801e24:	e8 94 ee ff ff       	call   800cbd <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  801e29:	83 c4 10             	add    $0x10,%esp
  801e2c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e2f:	75 07                	jne    801e38 <ipc_send+0x36>
			sys_yield();
  801e31:	e8 db ec ff ff       	call   800b11 <sys_yield>
  801e36:	eb e6                	jmp    801e1e <ipc_send+0x1c>
		} else if (r < 0) {
  801e38:	85 c0                	test   %eax,%eax
  801e3a:	79 12                	jns    801e4e <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  801e3c:	50                   	push   %eax
  801e3d:	68 c8 26 80 00       	push   $0x8026c8
  801e42:	6a 51                	push   $0x51
  801e44:	68 d5 26 80 00       	push   $0x8026d5
  801e49:	e8 8f fe ff ff       	call   801cdd <_panic>
		}
	}
}
  801e4e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e51:	5b                   	pop    %ebx
  801e52:	5e                   	pop    %esi
  801e53:	5f                   	pop    %edi
  801e54:	5d                   	pop    %ebp
  801e55:	c3                   	ret    

00801e56 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801e56:	55                   	push   %ebp
  801e57:	89 e5                	mov    %esp,%ebp
  801e59:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801e5c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801e61:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801e64:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801e6a:	8b 52 50             	mov    0x50(%edx),%edx
  801e6d:	39 ca                	cmp    %ecx,%edx
  801e6f:	75 0d                	jne    801e7e <ipc_find_env+0x28>
			return envs[i].env_id;
  801e71:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801e74:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801e79:	8b 40 48             	mov    0x48(%eax),%eax
  801e7c:	eb 0f                	jmp    801e8d <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801e7e:	83 c0 01             	add    $0x1,%eax
  801e81:	3d 00 04 00 00       	cmp    $0x400,%eax
  801e86:	75 d9                	jne    801e61 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801e88:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e8d:	5d                   	pop    %ebp
  801e8e:	c3                   	ret    

00801e8f <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801e8f:	55                   	push   %ebp
  801e90:	89 e5                	mov    %esp,%ebp
  801e92:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e95:	89 d0                	mov    %edx,%eax
  801e97:	c1 e8 16             	shr    $0x16,%eax
  801e9a:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801ea1:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ea6:	f6 c1 01             	test   $0x1,%cl
  801ea9:	74 1d                	je     801ec8 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801eab:	c1 ea 0c             	shr    $0xc,%edx
  801eae:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801eb5:	f6 c2 01             	test   $0x1,%dl
  801eb8:	74 0e                	je     801ec8 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801eba:	c1 ea 0c             	shr    $0xc,%edx
  801ebd:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801ec4:	ef 
  801ec5:	0f b7 c0             	movzwl %ax,%eax
}
  801ec8:	5d                   	pop    %ebp
  801ec9:	c3                   	ret    
  801eca:	66 90                	xchg   %ax,%ax
  801ecc:	66 90                	xchg   %ax,%ax
  801ece:	66 90                	xchg   %ax,%ax

00801ed0 <__udivdi3>:
  801ed0:	55                   	push   %ebp
  801ed1:	57                   	push   %edi
  801ed2:	56                   	push   %esi
  801ed3:	53                   	push   %ebx
  801ed4:	83 ec 1c             	sub    $0x1c,%esp
  801ed7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801edb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801edf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801ee3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ee7:	85 f6                	test   %esi,%esi
  801ee9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801eed:	89 ca                	mov    %ecx,%edx
  801eef:	89 f8                	mov    %edi,%eax
  801ef1:	75 3d                	jne    801f30 <__udivdi3+0x60>
  801ef3:	39 cf                	cmp    %ecx,%edi
  801ef5:	0f 87 c5 00 00 00    	ja     801fc0 <__udivdi3+0xf0>
  801efb:	85 ff                	test   %edi,%edi
  801efd:	89 fd                	mov    %edi,%ebp
  801eff:	75 0b                	jne    801f0c <__udivdi3+0x3c>
  801f01:	b8 01 00 00 00       	mov    $0x1,%eax
  801f06:	31 d2                	xor    %edx,%edx
  801f08:	f7 f7                	div    %edi
  801f0a:	89 c5                	mov    %eax,%ebp
  801f0c:	89 c8                	mov    %ecx,%eax
  801f0e:	31 d2                	xor    %edx,%edx
  801f10:	f7 f5                	div    %ebp
  801f12:	89 c1                	mov    %eax,%ecx
  801f14:	89 d8                	mov    %ebx,%eax
  801f16:	89 cf                	mov    %ecx,%edi
  801f18:	f7 f5                	div    %ebp
  801f1a:	89 c3                	mov    %eax,%ebx
  801f1c:	89 d8                	mov    %ebx,%eax
  801f1e:	89 fa                	mov    %edi,%edx
  801f20:	83 c4 1c             	add    $0x1c,%esp
  801f23:	5b                   	pop    %ebx
  801f24:	5e                   	pop    %esi
  801f25:	5f                   	pop    %edi
  801f26:	5d                   	pop    %ebp
  801f27:	c3                   	ret    
  801f28:	90                   	nop
  801f29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f30:	39 ce                	cmp    %ecx,%esi
  801f32:	77 74                	ja     801fa8 <__udivdi3+0xd8>
  801f34:	0f bd fe             	bsr    %esi,%edi
  801f37:	83 f7 1f             	xor    $0x1f,%edi
  801f3a:	0f 84 98 00 00 00    	je     801fd8 <__udivdi3+0x108>
  801f40:	bb 20 00 00 00       	mov    $0x20,%ebx
  801f45:	89 f9                	mov    %edi,%ecx
  801f47:	89 c5                	mov    %eax,%ebp
  801f49:	29 fb                	sub    %edi,%ebx
  801f4b:	d3 e6                	shl    %cl,%esi
  801f4d:	89 d9                	mov    %ebx,%ecx
  801f4f:	d3 ed                	shr    %cl,%ebp
  801f51:	89 f9                	mov    %edi,%ecx
  801f53:	d3 e0                	shl    %cl,%eax
  801f55:	09 ee                	or     %ebp,%esi
  801f57:	89 d9                	mov    %ebx,%ecx
  801f59:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f5d:	89 d5                	mov    %edx,%ebp
  801f5f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801f63:	d3 ed                	shr    %cl,%ebp
  801f65:	89 f9                	mov    %edi,%ecx
  801f67:	d3 e2                	shl    %cl,%edx
  801f69:	89 d9                	mov    %ebx,%ecx
  801f6b:	d3 e8                	shr    %cl,%eax
  801f6d:	09 c2                	or     %eax,%edx
  801f6f:	89 d0                	mov    %edx,%eax
  801f71:	89 ea                	mov    %ebp,%edx
  801f73:	f7 f6                	div    %esi
  801f75:	89 d5                	mov    %edx,%ebp
  801f77:	89 c3                	mov    %eax,%ebx
  801f79:	f7 64 24 0c          	mull   0xc(%esp)
  801f7d:	39 d5                	cmp    %edx,%ebp
  801f7f:	72 10                	jb     801f91 <__udivdi3+0xc1>
  801f81:	8b 74 24 08          	mov    0x8(%esp),%esi
  801f85:	89 f9                	mov    %edi,%ecx
  801f87:	d3 e6                	shl    %cl,%esi
  801f89:	39 c6                	cmp    %eax,%esi
  801f8b:	73 07                	jae    801f94 <__udivdi3+0xc4>
  801f8d:	39 d5                	cmp    %edx,%ebp
  801f8f:	75 03                	jne    801f94 <__udivdi3+0xc4>
  801f91:	83 eb 01             	sub    $0x1,%ebx
  801f94:	31 ff                	xor    %edi,%edi
  801f96:	89 d8                	mov    %ebx,%eax
  801f98:	89 fa                	mov    %edi,%edx
  801f9a:	83 c4 1c             	add    $0x1c,%esp
  801f9d:	5b                   	pop    %ebx
  801f9e:	5e                   	pop    %esi
  801f9f:	5f                   	pop    %edi
  801fa0:	5d                   	pop    %ebp
  801fa1:	c3                   	ret    
  801fa2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801fa8:	31 ff                	xor    %edi,%edi
  801faa:	31 db                	xor    %ebx,%ebx
  801fac:	89 d8                	mov    %ebx,%eax
  801fae:	89 fa                	mov    %edi,%edx
  801fb0:	83 c4 1c             	add    $0x1c,%esp
  801fb3:	5b                   	pop    %ebx
  801fb4:	5e                   	pop    %esi
  801fb5:	5f                   	pop    %edi
  801fb6:	5d                   	pop    %ebp
  801fb7:	c3                   	ret    
  801fb8:	90                   	nop
  801fb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fc0:	89 d8                	mov    %ebx,%eax
  801fc2:	f7 f7                	div    %edi
  801fc4:	31 ff                	xor    %edi,%edi
  801fc6:	89 c3                	mov    %eax,%ebx
  801fc8:	89 d8                	mov    %ebx,%eax
  801fca:	89 fa                	mov    %edi,%edx
  801fcc:	83 c4 1c             	add    $0x1c,%esp
  801fcf:	5b                   	pop    %ebx
  801fd0:	5e                   	pop    %esi
  801fd1:	5f                   	pop    %edi
  801fd2:	5d                   	pop    %ebp
  801fd3:	c3                   	ret    
  801fd4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801fd8:	39 ce                	cmp    %ecx,%esi
  801fda:	72 0c                	jb     801fe8 <__udivdi3+0x118>
  801fdc:	31 db                	xor    %ebx,%ebx
  801fde:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801fe2:	0f 87 34 ff ff ff    	ja     801f1c <__udivdi3+0x4c>
  801fe8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801fed:	e9 2a ff ff ff       	jmp    801f1c <__udivdi3+0x4c>
  801ff2:	66 90                	xchg   %ax,%ax
  801ff4:	66 90                	xchg   %ax,%ax
  801ff6:	66 90                	xchg   %ax,%ax
  801ff8:	66 90                	xchg   %ax,%ax
  801ffa:	66 90                	xchg   %ax,%ax
  801ffc:	66 90                	xchg   %ax,%ax
  801ffe:	66 90                	xchg   %ax,%ax

00802000 <__umoddi3>:
  802000:	55                   	push   %ebp
  802001:	57                   	push   %edi
  802002:	56                   	push   %esi
  802003:	53                   	push   %ebx
  802004:	83 ec 1c             	sub    $0x1c,%esp
  802007:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80200b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80200f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802013:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802017:	85 d2                	test   %edx,%edx
  802019:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80201d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802021:	89 f3                	mov    %esi,%ebx
  802023:	89 3c 24             	mov    %edi,(%esp)
  802026:	89 74 24 04          	mov    %esi,0x4(%esp)
  80202a:	75 1c                	jne    802048 <__umoddi3+0x48>
  80202c:	39 f7                	cmp    %esi,%edi
  80202e:	76 50                	jbe    802080 <__umoddi3+0x80>
  802030:	89 c8                	mov    %ecx,%eax
  802032:	89 f2                	mov    %esi,%edx
  802034:	f7 f7                	div    %edi
  802036:	89 d0                	mov    %edx,%eax
  802038:	31 d2                	xor    %edx,%edx
  80203a:	83 c4 1c             	add    $0x1c,%esp
  80203d:	5b                   	pop    %ebx
  80203e:	5e                   	pop    %esi
  80203f:	5f                   	pop    %edi
  802040:	5d                   	pop    %ebp
  802041:	c3                   	ret    
  802042:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802048:	39 f2                	cmp    %esi,%edx
  80204a:	89 d0                	mov    %edx,%eax
  80204c:	77 52                	ja     8020a0 <__umoddi3+0xa0>
  80204e:	0f bd ea             	bsr    %edx,%ebp
  802051:	83 f5 1f             	xor    $0x1f,%ebp
  802054:	75 5a                	jne    8020b0 <__umoddi3+0xb0>
  802056:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80205a:	0f 82 e0 00 00 00    	jb     802140 <__umoddi3+0x140>
  802060:	39 0c 24             	cmp    %ecx,(%esp)
  802063:	0f 86 d7 00 00 00    	jbe    802140 <__umoddi3+0x140>
  802069:	8b 44 24 08          	mov    0x8(%esp),%eax
  80206d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802071:	83 c4 1c             	add    $0x1c,%esp
  802074:	5b                   	pop    %ebx
  802075:	5e                   	pop    %esi
  802076:	5f                   	pop    %edi
  802077:	5d                   	pop    %ebp
  802078:	c3                   	ret    
  802079:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802080:	85 ff                	test   %edi,%edi
  802082:	89 fd                	mov    %edi,%ebp
  802084:	75 0b                	jne    802091 <__umoddi3+0x91>
  802086:	b8 01 00 00 00       	mov    $0x1,%eax
  80208b:	31 d2                	xor    %edx,%edx
  80208d:	f7 f7                	div    %edi
  80208f:	89 c5                	mov    %eax,%ebp
  802091:	89 f0                	mov    %esi,%eax
  802093:	31 d2                	xor    %edx,%edx
  802095:	f7 f5                	div    %ebp
  802097:	89 c8                	mov    %ecx,%eax
  802099:	f7 f5                	div    %ebp
  80209b:	89 d0                	mov    %edx,%eax
  80209d:	eb 99                	jmp    802038 <__umoddi3+0x38>
  80209f:	90                   	nop
  8020a0:	89 c8                	mov    %ecx,%eax
  8020a2:	89 f2                	mov    %esi,%edx
  8020a4:	83 c4 1c             	add    $0x1c,%esp
  8020a7:	5b                   	pop    %ebx
  8020a8:	5e                   	pop    %esi
  8020a9:	5f                   	pop    %edi
  8020aa:	5d                   	pop    %ebp
  8020ab:	c3                   	ret    
  8020ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020b0:	8b 34 24             	mov    (%esp),%esi
  8020b3:	bf 20 00 00 00       	mov    $0x20,%edi
  8020b8:	89 e9                	mov    %ebp,%ecx
  8020ba:	29 ef                	sub    %ebp,%edi
  8020bc:	d3 e0                	shl    %cl,%eax
  8020be:	89 f9                	mov    %edi,%ecx
  8020c0:	89 f2                	mov    %esi,%edx
  8020c2:	d3 ea                	shr    %cl,%edx
  8020c4:	89 e9                	mov    %ebp,%ecx
  8020c6:	09 c2                	or     %eax,%edx
  8020c8:	89 d8                	mov    %ebx,%eax
  8020ca:	89 14 24             	mov    %edx,(%esp)
  8020cd:	89 f2                	mov    %esi,%edx
  8020cf:	d3 e2                	shl    %cl,%edx
  8020d1:	89 f9                	mov    %edi,%ecx
  8020d3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8020d7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8020db:	d3 e8                	shr    %cl,%eax
  8020dd:	89 e9                	mov    %ebp,%ecx
  8020df:	89 c6                	mov    %eax,%esi
  8020e1:	d3 e3                	shl    %cl,%ebx
  8020e3:	89 f9                	mov    %edi,%ecx
  8020e5:	89 d0                	mov    %edx,%eax
  8020e7:	d3 e8                	shr    %cl,%eax
  8020e9:	89 e9                	mov    %ebp,%ecx
  8020eb:	09 d8                	or     %ebx,%eax
  8020ed:	89 d3                	mov    %edx,%ebx
  8020ef:	89 f2                	mov    %esi,%edx
  8020f1:	f7 34 24             	divl   (%esp)
  8020f4:	89 d6                	mov    %edx,%esi
  8020f6:	d3 e3                	shl    %cl,%ebx
  8020f8:	f7 64 24 04          	mull   0x4(%esp)
  8020fc:	39 d6                	cmp    %edx,%esi
  8020fe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802102:	89 d1                	mov    %edx,%ecx
  802104:	89 c3                	mov    %eax,%ebx
  802106:	72 08                	jb     802110 <__umoddi3+0x110>
  802108:	75 11                	jne    80211b <__umoddi3+0x11b>
  80210a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80210e:	73 0b                	jae    80211b <__umoddi3+0x11b>
  802110:	2b 44 24 04          	sub    0x4(%esp),%eax
  802114:	1b 14 24             	sbb    (%esp),%edx
  802117:	89 d1                	mov    %edx,%ecx
  802119:	89 c3                	mov    %eax,%ebx
  80211b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80211f:	29 da                	sub    %ebx,%edx
  802121:	19 ce                	sbb    %ecx,%esi
  802123:	89 f9                	mov    %edi,%ecx
  802125:	89 f0                	mov    %esi,%eax
  802127:	d3 e0                	shl    %cl,%eax
  802129:	89 e9                	mov    %ebp,%ecx
  80212b:	d3 ea                	shr    %cl,%edx
  80212d:	89 e9                	mov    %ebp,%ecx
  80212f:	d3 ee                	shr    %cl,%esi
  802131:	09 d0                	or     %edx,%eax
  802133:	89 f2                	mov    %esi,%edx
  802135:	83 c4 1c             	add    $0x1c,%esp
  802138:	5b                   	pop    %ebx
  802139:	5e                   	pop    %esi
  80213a:	5f                   	pop    %edi
  80213b:	5d                   	pop    %ebp
  80213c:	c3                   	ret    
  80213d:	8d 76 00             	lea    0x0(%esi),%esi
  802140:	29 f9                	sub    %edi,%ecx
  802142:	19 d6                	sbb    %edx,%esi
  802144:	89 74 24 04          	mov    %esi,0x4(%esp)
  802148:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80214c:	e9 18 ff ff ff       	jmp    802069 <__umoddi3+0x69>
