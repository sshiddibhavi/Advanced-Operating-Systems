
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
  80003a:	68 e0 25 80 00       	push   $0x8025e0
  80003f:	e8 64 01 00 00       	call   8001a8 <cprintf>
	if ((env = fork()) == 0) {
  800044:	e8 ab 0e 00 00       	call   800ef4 <fork>
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	85 c0                	test   %eax,%eax
  80004e:	75 12                	jne    800062 <umain+0x2f>
		cprintf("I am the child.  Spinning...\n");
  800050:	83 ec 0c             	sub    $0xc,%esp
  800053:	68 58 26 80 00       	push   $0x802658
  800058:	e8 4b 01 00 00       	call   8001a8 <cprintf>
  80005d:	83 c4 10             	add    $0x10,%esp
  800060:	eb fe                	jmp    800060 <umain+0x2d>
  800062:	89 c3                	mov    %eax,%ebx
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  800064:	83 ec 0c             	sub    $0xc,%esp
  800067:	68 08 26 80 00       	push   $0x802608
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
  800099:	c7 04 24 30 26 80 00 	movl   $0x802630,(%esp)
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
  8000d2:	a3 08 40 80 00       	mov    %eax,0x804008

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
  800101:	e8 ae 10 00 00       	call   8011b4 <close_all>
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
  80020b:	e8 40 21 00 00       	call   802350 <__udivdi3>
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
  80024e:	e8 2d 22 00 00       	call   802480 <__umoddi3>
  800253:	83 c4 14             	add    $0x14,%esp
  800256:	0f be 80 80 26 80 00 	movsbl 0x802680(%eax),%eax
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
  800352:	ff 24 85 c0 27 80 00 	jmp    *0x8027c0(,%eax,4)
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
  800416:	8b 14 85 20 29 80 00 	mov    0x802920(,%eax,4),%edx
  80041d:	85 d2                	test   %edx,%edx
  80041f:	75 18                	jne    800439 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800421:	50                   	push   %eax
  800422:	68 98 26 80 00       	push   $0x802698
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
  80043a:	68 da 2a 80 00       	push   $0x802ada
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
  80045e:	b8 91 26 80 00       	mov    $0x802691,%eax
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
  800ad9:	68 7f 29 80 00       	push   $0x80297f
  800ade:	6a 23                	push   $0x23
  800ae0:	68 9c 29 80 00       	push   $0x80299c
  800ae5:	e8 79 16 00 00       	call   802163 <_panic>

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
  800b5a:	68 7f 29 80 00       	push   $0x80297f
  800b5f:	6a 23                	push   $0x23
  800b61:	68 9c 29 80 00       	push   $0x80299c
  800b66:	e8 f8 15 00 00       	call   802163 <_panic>

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
  800b9c:	68 7f 29 80 00       	push   $0x80297f
  800ba1:	6a 23                	push   $0x23
  800ba3:	68 9c 29 80 00       	push   $0x80299c
  800ba8:	e8 b6 15 00 00       	call   802163 <_panic>

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
  800bde:	68 7f 29 80 00       	push   $0x80297f
  800be3:	6a 23                	push   $0x23
  800be5:	68 9c 29 80 00       	push   $0x80299c
  800bea:	e8 74 15 00 00       	call   802163 <_panic>

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
  800c20:	68 7f 29 80 00       	push   $0x80297f
  800c25:	6a 23                	push   $0x23
  800c27:	68 9c 29 80 00       	push   $0x80299c
  800c2c:	e8 32 15 00 00       	call   802163 <_panic>

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
  800c62:	68 7f 29 80 00       	push   $0x80297f
  800c67:	6a 23                	push   $0x23
  800c69:	68 9c 29 80 00       	push   $0x80299c
  800c6e:	e8 f0 14 00 00       	call   802163 <_panic>

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
  800ca4:	68 7f 29 80 00       	push   $0x80297f
  800ca9:	6a 23                	push   $0x23
  800cab:	68 9c 29 80 00       	push   $0x80299c
  800cb0:	e8 ae 14 00 00       	call   802163 <_panic>

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
  800d08:	68 7f 29 80 00       	push   $0x80297f
  800d0d:	6a 23                	push   $0x23
  800d0f:	68 9c 29 80 00       	push   $0x80299c
  800d14:	e8 4a 14 00 00       	call   802163 <_panic>

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

00800d21 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d21:	55                   	push   %ebp
  800d22:	89 e5                	mov    %esp,%ebp
  800d24:	57                   	push   %edi
  800d25:	56                   	push   %esi
  800d26:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d27:	ba 00 00 00 00       	mov    $0x0,%edx
  800d2c:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d31:	89 d1                	mov    %edx,%ecx
  800d33:	89 d3                	mov    %edx,%ebx
  800d35:	89 d7                	mov    %edx,%edi
  800d37:	89 d6                	mov    %edx,%esi
  800d39:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d3b:	5b                   	pop    %ebx
  800d3c:	5e                   	pop    %esi
  800d3d:	5f                   	pop    %edi
  800d3e:	5d                   	pop    %ebp
  800d3f:	c3                   	ret    

00800d40 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800d40:	55                   	push   %ebp
  800d41:	89 e5                	mov    %esp,%ebp
  800d43:	53                   	push   %ebx
  800d44:	83 ec 04             	sub    $0x4,%esp
	int r;
	void * address = (void *)(pn*PGSIZE);
  800d47:	89 d3                	mov    %edx,%ebx
  800d49:	c1 e3 0c             	shl    $0xc,%ebx
	
	if((uvpt[pn] & PTE_SHARE))
  800d4c:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800d53:	f6 c5 04             	test   $0x4,%ch
  800d56:	74 38                	je     800d90 <duppage+0x50>
	{
		if ((r = sys_page_map(0, address, envid, address, (uvpt[pn] | PTE_SYSCALL))) < 0)
  800d58:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d5f:	83 ec 0c             	sub    $0xc,%esp
  800d62:	81 ca 07 0e 00 00    	or     $0xe07,%edx
  800d68:	52                   	push   %edx
  800d69:	53                   	push   %ebx
  800d6a:	50                   	push   %eax
  800d6b:	53                   	push   %ebx
  800d6c:	6a 00                	push   $0x0
  800d6e:	e8 00 fe ff ff       	call   800b73 <sys_page_map>
  800d73:	83 c4 20             	add    $0x20,%esp
  800d76:	85 c0                	test   %eax,%eax
  800d78:	0f 89 b8 00 00 00    	jns    800e36 <duppage+0xf6>
			panic("sys_page_map: %e", r);
  800d7e:	50                   	push   %eax
  800d7f:	68 aa 29 80 00       	push   $0x8029aa
  800d84:	6a 4e                	push   $0x4e
  800d86:	68 bb 29 80 00       	push   $0x8029bb
  800d8b:	e8 d3 13 00 00       	call   802163 <_panic>
	}
	else if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW))
  800d90:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800d97:	f6 c1 02             	test   $0x2,%cl
  800d9a:	75 0c                	jne    800da8 <duppage+0x68>
  800d9c:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800da3:	f6 c5 08             	test   $0x8,%ch
  800da6:	74 57                	je     800dff <duppage+0xbf>
	{
		int perm = 0;
		perm |= PTE_P|PTE_U|PTE_COW;
	
		if ((r = sys_page_map(0, address, envid, address, perm)) < 0)
  800da8:	83 ec 0c             	sub    $0xc,%esp
  800dab:	68 05 08 00 00       	push   $0x805
  800db0:	53                   	push   %ebx
  800db1:	50                   	push   %eax
  800db2:	53                   	push   %ebx
  800db3:	6a 00                	push   $0x0
  800db5:	e8 b9 fd ff ff       	call   800b73 <sys_page_map>
  800dba:	83 c4 20             	add    $0x20,%esp
  800dbd:	85 c0                	test   %eax,%eax
  800dbf:	79 12                	jns    800dd3 <duppage+0x93>
			panic("sys_page_map: %e", r);
  800dc1:	50                   	push   %eax
  800dc2:	68 aa 29 80 00       	push   $0x8029aa
  800dc7:	6a 56                	push   $0x56
  800dc9:	68 bb 29 80 00       	push   $0x8029bb
  800dce:	e8 90 13 00 00       	call   802163 <_panic>
		if ((r = sys_page_map(0, address, 0, address, perm)) < 0)
  800dd3:	83 ec 0c             	sub    $0xc,%esp
  800dd6:	68 05 08 00 00       	push   $0x805
  800ddb:	53                   	push   %ebx
  800ddc:	6a 00                	push   $0x0
  800dde:	53                   	push   %ebx
  800ddf:	6a 00                	push   $0x0
  800de1:	e8 8d fd ff ff       	call   800b73 <sys_page_map>
  800de6:	83 c4 20             	add    $0x20,%esp
  800de9:	85 c0                	test   %eax,%eax
  800deb:	79 49                	jns    800e36 <duppage+0xf6>
			panic("sys_page_map: %e", r);
  800ded:	50                   	push   %eax
  800dee:	68 aa 29 80 00       	push   $0x8029aa
  800df3:	6a 58                	push   $0x58
  800df5:	68 bb 29 80 00       	push   $0x8029bb
  800dfa:	e8 64 13 00 00       	call   802163 <_panic>
	}
	else if((uvpt[pn] & ~PTE_U) == 0)
  800dff:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e06:	f7 c2 fb ff ff ff    	test   $0xfffffffb,%edx
  800e0c:	75 28                	jne    800e36 <duppage+0xf6>
	{
		//cprintf("im here");
		if ((r = sys_page_map(0, address, envid, address, PTE_P|PTE_U)) < 0)
  800e0e:	83 ec 0c             	sub    $0xc,%esp
  800e11:	6a 05                	push   $0x5
  800e13:	53                   	push   %ebx
  800e14:	50                   	push   %eax
  800e15:	53                   	push   %ebx
  800e16:	6a 00                	push   $0x0
  800e18:	e8 56 fd ff ff       	call   800b73 <sys_page_map>
  800e1d:	83 c4 20             	add    $0x20,%esp
  800e20:	85 c0                	test   %eax,%eax
  800e22:	79 12                	jns    800e36 <duppage+0xf6>
			panic("sys_page_map: %e", r);	
  800e24:	50                   	push   %eax
  800e25:	68 aa 29 80 00       	push   $0x8029aa
  800e2a:	6a 5e                	push   $0x5e
  800e2c:	68 bb 29 80 00       	push   $0x8029bb
  800e31:	e8 2d 13 00 00       	call   802163 <_panic>
	}
	return 0;
}
  800e36:	b8 00 00 00 00       	mov    $0x0,%eax
  800e3b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e3e:	c9                   	leave  
  800e3f:	c3                   	ret    

00800e40 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e40:	55                   	push   %ebp
  800e41:	89 e5                	mov    %esp,%ebp
  800e43:	53                   	push   %ebx
  800e44:	83 ec 08             	sub    $0x8,%esp
	void *addr = (void *) utf->utf_fault_va;
  800e47:	8b 45 08             	mov    0x8(%ebp),%eax
  800e4a:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	unsigned pn = ((uint32_t)addr)/PGSIZE;
  800e4c:	89 d8                	mov    %ebx,%eax
  800e4e:	c1 e8 0c             	shr    $0xc,%eax
	pte_t pte = uvpt[pn];
  800e51:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// Allocate a new page, mapped at temp location
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  800e58:	6a 07                	push   $0x7
  800e5a:	68 00 f0 7f 00       	push   $0x7ff000
  800e5f:	6a 00                	push   $0x0
  800e61:	e8 ca fc ff ff       	call   800b30 <sys_page_alloc>
  800e66:	83 c4 10             	add    $0x10,%esp
  800e69:	85 c0                	test   %eax,%eax
  800e6b:	79 12                	jns    800e7f <pgfault+0x3f>
		panic("sys_page_alloc: %e", r);
  800e6d:	50                   	push   %eax
  800e6e:	68 c6 29 80 00       	push   $0x8029c6
  800e73:	6a 2b                	push   $0x2b
  800e75:	68 bb 29 80 00       	push   $0x8029bb
  800e7a:	e8 e4 12 00 00       	call   802163 <_panic>

	// Copy the data from the old page to this new page
	void *addr_pgstart = (void *) ROUNDDOWN(addr, PGSIZE);
  800e7f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr_pgstart, PGSIZE);
  800e85:	83 ec 04             	sub    $0x4,%esp
  800e88:	68 00 10 00 00       	push   $0x1000
  800e8d:	53                   	push   %ebx
  800e8e:	68 00 f0 7f 00       	push   $0x7ff000
  800e93:	e8 27 fa ff ff       	call   8008bf <memmove>

	// Move the new page to the old page's address
	if ((r = sys_page_map(0, PFTEMP, 0, addr_pgstart, PTE_P|PTE_U|PTE_W)) < 0)
  800e98:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e9f:	53                   	push   %ebx
  800ea0:	6a 00                	push   $0x0
  800ea2:	68 00 f0 7f 00       	push   $0x7ff000
  800ea7:	6a 00                	push   $0x0
  800ea9:	e8 c5 fc ff ff       	call   800b73 <sys_page_map>
  800eae:	83 c4 20             	add    $0x20,%esp
  800eb1:	85 c0                	test   %eax,%eax
  800eb3:	79 12                	jns    800ec7 <pgfault+0x87>
		panic("sys_page_map: %e", r);
  800eb5:	50                   	push   %eax
  800eb6:	68 aa 29 80 00       	push   $0x8029aa
  800ebb:	6a 33                	push   $0x33
  800ebd:	68 bb 29 80 00       	push   $0x8029bb
  800ec2:	e8 9c 12 00 00       	call   802163 <_panic>

	// Unmap the temp location
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800ec7:	83 ec 08             	sub    $0x8,%esp
  800eca:	68 00 f0 7f 00       	push   $0x7ff000
  800ecf:	6a 00                	push   $0x0
  800ed1:	e8 df fc ff ff       	call   800bb5 <sys_page_unmap>
  800ed6:	83 c4 10             	add    $0x10,%esp
  800ed9:	85 c0                	test   %eax,%eax
  800edb:	79 12                	jns    800eef <pgfault+0xaf>
		panic("sys_page_unmap: %e", r);
  800edd:	50                   	push   %eax
  800ede:	68 d9 29 80 00       	push   $0x8029d9
  800ee3:	6a 37                	push   $0x37
  800ee5:	68 bb 29 80 00       	push   $0x8029bb
  800eea:	e8 74 12 00 00       	call   802163 <_panic>
}
  800eef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ef2:	c9                   	leave  
  800ef3:	c3                   	ret    

00800ef4 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ef4:	55                   	push   %ebp
  800ef5:	89 e5                	mov    %esp,%ebp
  800ef7:	56                   	push   %esi
  800ef8:	53                   	push   %ebx
  800ef9:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
	// Set up page fault handler
	set_pgfault_handler(&pgfault);
  800efc:	68 40 0e 80 00       	push   $0x800e40
  800f01:	e8 a3 12 00 00       	call   8021a9 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f06:	b8 07 00 00 00       	mov    $0x7,%eax
  800f0b:	cd 30                	int    $0x30

	// Create child
	envid_t envid = sys_exofork();
  800f0d:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (envid < 0) {
  800f10:	83 c4 10             	add    $0x10,%esp
  800f13:	85 c0                	test   %eax,%eax
  800f15:	79 12                	jns    800f29 <fork+0x35>
		panic("sys_exofork: %e", envid);
  800f17:	50                   	push   %eax
  800f18:	68 ec 29 80 00       	push   $0x8029ec
  800f1d:	6a 7c                	push   $0x7c
  800f1f:	68 bb 29 80 00       	push   $0x8029bb
  800f24:	e8 3a 12 00 00       	call   802163 <_panic>
		return envid;
	}
	if (envid == 0) {
  800f29:	85 c0                	test   %eax,%eax
  800f2b:	75 1e                	jne    800f4b <fork+0x57>
		// We are the child.
		thisenv = &envs[ENVX(sys_getenvid())]; // Fix thisenv
  800f2d:	e8 c0 fb ff ff       	call   800af2 <sys_getenvid>
  800f32:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f37:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f3a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f3f:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  800f44:	b8 00 00 00 00       	mov    $0x0,%eax
  800f49:	eb 7d                	jmp    800fc8 <fork+0xd4>

	// Set page fault handler on the child.
	// The parent needs to do it, else the child wouldn't be able to handle
	// the fault when trying to access it's stack (which happens as soon it starts)
	extern void _pgfault_upcall(void);
	sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);
  800f4b:	83 ec 04             	sub    $0x4,%esp
  800f4e:	6a 07                	push   $0x7
  800f50:	68 00 f0 bf ee       	push   $0xeebff000
  800f55:	50                   	push   %eax
  800f56:	e8 d5 fb ff ff       	call   800b30 <sys_page_alloc>
	sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  800f5b:	83 c4 08             	add    $0x8,%esp
  800f5e:	68 ee 21 80 00       	push   $0x8021ee
  800f63:	ff 75 f4             	pushl  -0xc(%ebp)
  800f66:	e8 10 fd ff ff       	call   800c7b <sys_env_set_pgfault_upcall>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  800f6b:	be 04 70 80 00       	mov    $0x807004,%esi
  800f70:	c1 ee 0c             	shr    $0xc,%esi
  800f73:	83 c4 10             	add    $0x10,%esp
  800f76:	bb 00 08 00 00       	mov    $0x800,%ebx
  800f7b:	eb 0d                	jmp    800f8a <fork+0x96>
		duppage(envid, pn);
  800f7d:	89 da                	mov    %ebx,%edx
  800f7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f82:	e8 b9 fd ff ff       	call   800d40 <duppage>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  800f87:	83 c3 01             	add    $0x1,%ebx
  800f8a:	39 f3                	cmp    %esi,%ebx
  800f8c:	76 ef                	jbe    800f7d <fork+0x89>
	}

	// Also copy the stack we are currently running on
	// I think it should loop from ustacktop to this page, since the stack
	// can have more than 1 page
	duppage(envid, ((uint32_t) &envid)/PGSIZE);
  800f8e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800f91:	c1 ea 0c             	shr    $0xc,%edx
  800f94:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f97:	e8 a4 fd ff ff       	call   800d40 <duppage>

	// Start the child environmnet running
	int r;
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  800f9c:	83 ec 08             	sub    $0x8,%esp
  800f9f:	6a 02                	push   $0x2
  800fa1:	ff 75 f4             	pushl  -0xc(%ebp)
  800fa4:	e8 4e fc ff ff       	call   800bf7 <sys_env_set_status>
  800fa9:	83 c4 10             	add    $0x10,%esp
  800fac:	85 c0                	test   %eax,%eax
  800fae:	79 15                	jns    800fc5 <fork+0xd1>
		panic("sys_env_set_status: %e", r);
  800fb0:	50                   	push   %eax
  800fb1:	68 fc 29 80 00       	push   $0x8029fc
  800fb6:	68 9c 00 00 00       	push   $0x9c
  800fbb:	68 bb 29 80 00       	push   $0x8029bb
  800fc0:	e8 9e 11 00 00       	call   802163 <_panic>
		return r;
	}

	return envid;
  800fc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800fc8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fcb:	5b                   	pop    %ebx
  800fcc:	5e                   	pop    %esi
  800fcd:	5d                   	pop    %ebp
  800fce:	c3                   	ret    

00800fcf <sfork>:

// Challenge!
int
sfork(void)
{
  800fcf:	55                   	push   %ebp
  800fd0:	89 e5                	mov    %esp,%ebp
  800fd2:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800fd5:	68 13 2a 80 00       	push   $0x802a13
  800fda:	68 a7 00 00 00       	push   $0xa7
  800fdf:	68 bb 29 80 00       	push   $0x8029bb
  800fe4:	e8 7a 11 00 00       	call   802163 <_panic>

00800fe9 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800fe9:	55                   	push   %ebp
  800fea:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800fec:	8b 45 08             	mov    0x8(%ebp),%eax
  800fef:	05 00 00 00 30       	add    $0x30000000,%eax
  800ff4:	c1 e8 0c             	shr    $0xc,%eax
}
  800ff7:	5d                   	pop    %ebp
  800ff8:	c3                   	ret    

00800ff9 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800ff9:	55                   	push   %ebp
  800ffa:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800ffc:	8b 45 08             	mov    0x8(%ebp),%eax
  800fff:	05 00 00 00 30       	add    $0x30000000,%eax
  801004:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801009:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80100e:	5d                   	pop    %ebp
  80100f:	c3                   	ret    

00801010 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801010:	55                   	push   %ebp
  801011:	89 e5                	mov    %esp,%ebp
  801013:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801016:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80101b:	89 c2                	mov    %eax,%edx
  80101d:	c1 ea 16             	shr    $0x16,%edx
  801020:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801027:	f6 c2 01             	test   $0x1,%dl
  80102a:	74 11                	je     80103d <fd_alloc+0x2d>
  80102c:	89 c2                	mov    %eax,%edx
  80102e:	c1 ea 0c             	shr    $0xc,%edx
  801031:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801038:	f6 c2 01             	test   $0x1,%dl
  80103b:	75 09                	jne    801046 <fd_alloc+0x36>
			*fd_store = fd;
  80103d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80103f:	b8 00 00 00 00       	mov    $0x0,%eax
  801044:	eb 17                	jmp    80105d <fd_alloc+0x4d>
  801046:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80104b:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801050:	75 c9                	jne    80101b <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801052:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801058:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80105d:	5d                   	pop    %ebp
  80105e:	c3                   	ret    

0080105f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80105f:	55                   	push   %ebp
  801060:	89 e5                	mov    %esp,%ebp
  801062:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801065:	83 f8 1f             	cmp    $0x1f,%eax
  801068:	77 36                	ja     8010a0 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80106a:	c1 e0 0c             	shl    $0xc,%eax
  80106d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801072:	89 c2                	mov    %eax,%edx
  801074:	c1 ea 16             	shr    $0x16,%edx
  801077:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80107e:	f6 c2 01             	test   $0x1,%dl
  801081:	74 24                	je     8010a7 <fd_lookup+0x48>
  801083:	89 c2                	mov    %eax,%edx
  801085:	c1 ea 0c             	shr    $0xc,%edx
  801088:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80108f:	f6 c2 01             	test   $0x1,%dl
  801092:	74 1a                	je     8010ae <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801094:	8b 55 0c             	mov    0xc(%ebp),%edx
  801097:	89 02                	mov    %eax,(%edx)
	return 0;
  801099:	b8 00 00 00 00       	mov    $0x0,%eax
  80109e:	eb 13                	jmp    8010b3 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010a0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010a5:	eb 0c                	jmp    8010b3 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010ac:	eb 05                	jmp    8010b3 <fd_lookup+0x54>
  8010ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8010b3:	5d                   	pop    %ebp
  8010b4:	c3                   	ret    

008010b5 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8010b5:	55                   	push   %ebp
  8010b6:	89 e5                	mov    %esp,%ebp
  8010b8:	83 ec 08             	sub    $0x8,%esp
  8010bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010be:	ba a8 2a 80 00       	mov    $0x802aa8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8010c3:	eb 13                	jmp    8010d8 <dev_lookup+0x23>
  8010c5:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8010c8:	39 08                	cmp    %ecx,(%eax)
  8010ca:	75 0c                	jne    8010d8 <dev_lookup+0x23>
			*dev = devtab[i];
  8010cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010cf:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8010d6:	eb 2e                	jmp    801106 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8010d8:	8b 02                	mov    (%edx),%eax
  8010da:	85 c0                	test   %eax,%eax
  8010dc:	75 e7                	jne    8010c5 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8010de:	a1 08 40 80 00       	mov    0x804008,%eax
  8010e3:	8b 40 48             	mov    0x48(%eax),%eax
  8010e6:	83 ec 04             	sub    $0x4,%esp
  8010e9:	51                   	push   %ecx
  8010ea:	50                   	push   %eax
  8010eb:	68 2c 2a 80 00       	push   $0x802a2c
  8010f0:	e8 b3 f0 ff ff       	call   8001a8 <cprintf>
	*dev = 0;
  8010f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010f8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8010fe:	83 c4 10             	add    $0x10,%esp
  801101:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801106:	c9                   	leave  
  801107:	c3                   	ret    

00801108 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801108:	55                   	push   %ebp
  801109:	89 e5                	mov    %esp,%ebp
  80110b:	56                   	push   %esi
  80110c:	53                   	push   %ebx
  80110d:	83 ec 10             	sub    $0x10,%esp
  801110:	8b 75 08             	mov    0x8(%ebp),%esi
  801113:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801116:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801119:	50                   	push   %eax
  80111a:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801120:	c1 e8 0c             	shr    $0xc,%eax
  801123:	50                   	push   %eax
  801124:	e8 36 ff ff ff       	call   80105f <fd_lookup>
  801129:	83 c4 08             	add    $0x8,%esp
  80112c:	85 c0                	test   %eax,%eax
  80112e:	78 05                	js     801135 <fd_close+0x2d>
	    || fd != fd2)
  801130:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801133:	74 0c                	je     801141 <fd_close+0x39>
		return (must_exist ? r : 0);
  801135:	84 db                	test   %bl,%bl
  801137:	ba 00 00 00 00       	mov    $0x0,%edx
  80113c:	0f 44 c2             	cmove  %edx,%eax
  80113f:	eb 41                	jmp    801182 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801141:	83 ec 08             	sub    $0x8,%esp
  801144:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801147:	50                   	push   %eax
  801148:	ff 36                	pushl  (%esi)
  80114a:	e8 66 ff ff ff       	call   8010b5 <dev_lookup>
  80114f:	89 c3                	mov    %eax,%ebx
  801151:	83 c4 10             	add    $0x10,%esp
  801154:	85 c0                	test   %eax,%eax
  801156:	78 1a                	js     801172 <fd_close+0x6a>
		if (dev->dev_close)
  801158:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80115b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80115e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801163:	85 c0                	test   %eax,%eax
  801165:	74 0b                	je     801172 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801167:	83 ec 0c             	sub    $0xc,%esp
  80116a:	56                   	push   %esi
  80116b:	ff d0                	call   *%eax
  80116d:	89 c3                	mov    %eax,%ebx
  80116f:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801172:	83 ec 08             	sub    $0x8,%esp
  801175:	56                   	push   %esi
  801176:	6a 00                	push   $0x0
  801178:	e8 38 fa ff ff       	call   800bb5 <sys_page_unmap>
	return r;
  80117d:	83 c4 10             	add    $0x10,%esp
  801180:	89 d8                	mov    %ebx,%eax
}
  801182:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801185:	5b                   	pop    %ebx
  801186:	5e                   	pop    %esi
  801187:	5d                   	pop    %ebp
  801188:	c3                   	ret    

00801189 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801189:	55                   	push   %ebp
  80118a:	89 e5                	mov    %esp,%ebp
  80118c:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80118f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801192:	50                   	push   %eax
  801193:	ff 75 08             	pushl  0x8(%ebp)
  801196:	e8 c4 fe ff ff       	call   80105f <fd_lookup>
  80119b:	83 c4 08             	add    $0x8,%esp
  80119e:	85 c0                	test   %eax,%eax
  8011a0:	78 10                	js     8011b2 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8011a2:	83 ec 08             	sub    $0x8,%esp
  8011a5:	6a 01                	push   $0x1
  8011a7:	ff 75 f4             	pushl  -0xc(%ebp)
  8011aa:	e8 59 ff ff ff       	call   801108 <fd_close>
  8011af:	83 c4 10             	add    $0x10,%esp
}
  8011b2:	c9                   	leave  
  8011b3:	c3                   	ret    

008011b4 <close_all>:

void
close_all(void)
{
  8011b4:	55                   	push   %ebp
  8011b5:	89 e5                	mov    %esp,%ebp
  8011b7:	53                   	push   %ebx
  8011b8:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8011bb:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8011c0:	83 ec 0c             	sub    $0xc,%esp
  8011c3:	53                   	push   %ebx
  8011c4:	e8 c0 ff ff ff       	call   801189 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8011c9:	83 c3 01             	add    $0x1,%ebx
  8011cc:	83 c4 10             	add    $0x10,%esp
  8011cf:	83 fb 20             	cmp    $0x20,%ebx
  8011d2:	75 ec                	jne    8011c0 <close_all+0xc>
		close(i);
}
  8011d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011d7:	c9                   	leave  
  8011d8:	c3                   	ret    

008011d9 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8011d9:	55                   	push   %ebp
  8011da:	89 e5                	mov    %esp,%ebp
  8011dc:	57                   	push   %edi
  8011dd:	56                   	push   %esi
  8011de:	53                   	push   %ebx
  8011df:	83 ec 2c             	sub    $0x2c,%esp
  8011e2:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8011e5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8011e8:	50                   	push   %eax
  8011e9:	ff 75 08             	pushl  0x8(%ebp)
  8011ec:	e8 6e fe ff ff       	call   80105f <fd_lookup>
  8011f1:	83 c4 08             	add    $0x8,%esp
  8011f4:	85 c0                	test   %eax,%eax
  8011f6:	0f 88 c1 00 00 00    	js     8012bd <dup+0xe4>
		return r;
	close(newfdnum);
  8011fc:	83 ec 0c             	sub    $0xc,%esp
  8011ff:	56                   	push   %esi
  801200:	e8 84 ff ff ff       	call   801189 <close>

	newfd = INDEX2FD(newfdnum);
  801205:	89 f3                	mov    %esi,%ebx
  801207:	c1 e3 0c             	shl    $0xc,%ebx
  80120a:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801210:	83 c4 04             	add    $0x4,%esp
  801213:	ff 75 e4             	pushl  -0x1c(%ebp)
  801216:	e8 de fd ff ff       	call   800ff9 <fd2data>
  80121b:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80121d:	89 1c 24             	mov    %ebx,(%esp)
  801220:	e8 d4 fd ff ff       	call   800ff9 <fd2data>
  801225:	83 c4 10             	add    $0x10,%esp
  801228:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80122b:	89 f8                	mov    %edi,%eax
  80122d:	c1 e8 16             	shr    $0x16,%eax
  801230:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801237:	a8 01                	test   $0x1,%al
  801239:	74 37                	je     801272 <dup+0x99>
  80123b:	89 f8                	mov    %edi,%eax
  80123d:	c1 e8 0c             	shr    $0xc,%eax
  801240:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801247:	f6 c2 01             	test   $0x1,%dl
  80124a:	74 26                	je     801272 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80124c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801253:	83 ec 0c             	sub    $0xc,%esp
  801256:	25 07 0e 00 00       	and    $0xe07,%eax
  80125b:	50                   	push   %eax
  80125c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80125f:	6a 00                	push   $0x0
  801261:	57                   	push   %edi
  801262:	6a 00                	push   $0x0
  801264:	e8 0a f9 ff ff       	call   800b73 <sys_page_map>
  801269:	89 c7                	mov    %eax,%edi
  80126b:	83 c4 20             	add    $0x20,%esp
  80126e:	85 c0                	test   %eax,%eax
  801270:	78 2e                	js     8012a0 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801272:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801275:	89 d0                	mov    %edx,%eax
  801277:	c1 e8 0c             	shr    $0xc,%eax
  80127a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801281:	83 ec 0c             	sub    $0xc,%esp
  801284:	25 07 0e 00 00       	and    $0xe07,%eax
  801289:	50                   	push   %eax
  80128a:	53                   	push   %ebx
  80128b:	6a 00                	push   $0x0
  80128d:	52                   	push   %edx
  80128e:	6a 00                	push   $0x0
  801290:	e8 de f8 ff ff       	call   800b73 <sys_page_map>
  801295:	89 c7                	mov    %eax,%edi
  801297:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80129a:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80129c:	85 ff                	test   %edi,%edi
  80129e:	79 1d                	jns    8012bd <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8012a0:	83 ec 08             	sub    $0x8,%esp
  8012a3:	53                   	push   %ebx
  8012a4:	6a 00                	push   $0x0
  8012a6:	e8 0a f9 ff ff       	call   800bb5 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8012ab:	83 c4 08             	add    $0x8,%esp
  8012ae:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012b1:	6a 00                	push   $0x0
  8012b3:	e8 fd f8 ff ff       	call   800bb5 <sys_page_unmap>
	return r;
  8012b8:	83 c4 10             	add    $0x10,%esp
  8012bb:	89 f8                	mov    %edi,%eax
}
  8012bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012c0:	5b                   	pop    %ebx
  8012c1:	5e                   	pop    %esi
  8012c2:	5f                   	pop    %edi
  8012c3:	5d                   	pop    %ebp
  8012c4:	c3                   	ret    

008012c5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8012c5:	55                   	push   %ebp
  8012c6:	89 e5                	mov    %esp,%ebp
  8012c8:	53                   	push   %ebx
  8012c9:	83 ec 14             	sub    $0x14,%esp
  8012cc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012cf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012d2:	50                   	push   %eax
  8012d3:	53                   	push   %ebx
  8012d4:	e8 86 fd ff ff       	call   80105f <fd_lookup>
  8012d9:	83 c4 08             	add    $0x8,%esp
  8012dc:	89 c2                	mov    %eax,%edx
  8012de:	85 c0                	test   %eax,%eax
  8012e0:	78 6d                	js     80134f <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012e2:	83 ec 08             	sub    $0x8,%esp
  8012e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012e8:	50                   	push   %eax
  8012e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ec:	ff 30                	pushl  (%eax)
  8012ee:	e8 c2 fd ff ff       	call   8010b5 <dev_lookup>
  8012f3:	83 c4 10             	add    $0x10,%esp
  8012f6:	85 c0                	test   %eax,%eax
  8012f8:	78 4c                	js     801346 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8012fa:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8012fd:	8b 42 08             	mov    0x8(%edx),%eax
  801300:	83 e0 03             	and    $0x3,%eax
  801303:	83 f8 01             	cmp    $0x1,%eax
  801306:	75 21                	jne    801329 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801308:	a1 08 40 80 00       	mov    0x804008,%eax
  80130d:	8b 40 48             	mov    0x48(%eax),%eax
  801310:	83 ec 04             	sub    $0x4,%esp
  801313:	53                   	push   %ebx
  801314:	50                   	push   %eax
  801315:	68 6d 2a 80 00       	push   $0x802a6d
  80131a:	e8 89 ee ff ff       	call   8001a8 <cprintf>
		return -E_INVAL;
  80131f:	83 c4 10             	add    $0x10,%esp
  801322:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801327:	eb 26                	jmp    80134f <read+0x8a>
	}
	if (!dev->dev_read)
  801329:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80132c:	8b 40 08             	mov    0x8(%eax),%eax
  80132f:	85 c0                	test   %eax,%eax
  801331:	74 17                	je     80134a <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801333:	83 ec 04             	sub    $0x4,%esp
  801336:	ff 75 10             	pushl  0x10(%ebp)
  801339:	ff 75 0c             	pushl  0xc(%ebp)
  80133c:	52                   	push   %edx
  80133d:	ff d0                	call   *%eax
  80133f:	89 c2                	mov    %eax,%edx
  801341:	83 c4 10             	add    $0x10,%esp
  801344:	eb 09                	jmp    80134f <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801346:	89 c2                	mov    %eax,%edx
  801348:	eb 05                	jmp    80134f <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80134a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80134f:	89 d0                	mov    %edx,%eax
  801351:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801354:	c9                   	leave  
  801355:	c3                   	ret    

00801356 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801356:	55                   	push   %ebp
  801357:	89 e5                	mov    %esp,%ebp
  801359:	57                   	push   %edi
  80135a:	56                   	push   %esi
  80135b:	53                   	push   %ebx
  80135c:	83 ec 0c             	sub    $0xc,%esp
  80135f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801362:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801365:	bb 00 00 00 00       	mov    $0x0,%ebx
  80136a:	eb 21                	jmp    80138d <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80136c:	83 ec 04             	sub    $0x4,%esp
  80136f:	89 f0                	mov    %esi,%eax
  801371:	29 d8                	sub    %ebx,%eax
  801373:	50                   	push   %eax
  801374:	89 d8                	mov    %ebx,%eax
  801376:	03 45 0c             	add    0xc(%ebp),%eax
  801379:	50                   	push   %eax
  80137a:	57                   	push   %edi
  80137b:	e8 45 ff ff ff       	call   8012c5 <read>
		if (m < 0)
  801380:	83 c4 10             	add    $0x10,%esp
  801383:	85 c0                	test   %eax,%eax
  801385:	78 10                	js     801397 <readn+0x41>
			return m;
		if (m == 0)
  801387:	85 c0                	test   %eax,%eax
  801389:	74 0a                	je     801395 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80138b:	01 c3                	add    %eax,%ebx
  80138d:	39 f3                	cmp    %esi,%ebx
  80138f:	72 db                	jb     80136c <readn+0x16>
  801391:	89 d8                	mov    %ebx,%eax
  801393:	eb 02                	jmp    801397 <readn+0x41>
  801395:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801397:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80139a:	5b                   	pop    %ebx
  80139b:	5e                   	pop    %esi
  80139c:	5f                   	pop    %edi
  80139d:	5d                   	pop    %ebp
  80139e:	c3                   	ret    

0080139f <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80139f:	55                   	push   %ebp
  8013a0:	89 e5                	mov    %esp,%ebp
  8013a2:	53                   	push   %ebx
  8013a3:	83 ec 14             	sub    $0x14,%esp
  8013a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013a9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013ac:	50                   	push   %eax
  8013ad:	53                   	push   %ebx
  8013ae:	e8 ac fc ff ff       	call   80105f <fd_lookup>
  8013b3:	83 c4 08             	add    $0x8,%esp
  8013b6:	89 c2                	mov    %eax,%edx
  8013b8:	85 c0                	test   %eax,%eax
  8013ba:	78 68                	js     801424 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013bc:	83 ec 08             	sub    $0x8,%esp
  8013bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013c2:	50                   	push   %eax
  8013c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013c6:	ff 30                	pushl  (%eax)
  8013c8:	e8 e8 fc ff ff       	call   8010b5 <dev_lookup>
  8013cd:	83 c4 10             	add    $0x10,%esp
  8013d0:	85 c0                	test   %eax,%eax
  8013d2:	78 47                	js     80141b <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013d7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013db:	75 21                	jne    8013fe <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8013dd:	a1 08 40 80 00       	mov    0x804008,%eax
  8013e2:	8b 40 48             	mov    0x48(%eax),%eax
  8013e5:	83 ec 04             	sub    $0x4,%esp
  8013e8:	53                   	push   %ebx
  8013e9:	50                   	push   %eax
  8013ea:	68 89 2a 80 00       	push   $0x802a89
  8013ef:	e8 b4 ed ff ff       	call   8001a8 <cprintf>
		return -E_INVAL;
  8013f4:	83 c4 10             	add    $0x10,%esp
  8013f7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013fc:	eb 26                	jmp    801424 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8013fe:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801401:	8b 52 0c             	mov    0xc(%edx),%edx
  801404:	85 d2                	test   %edx,%edx
  801406:	74 17                	je     80141f <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801408:	83 ec 04             	sub    $0x4,%esp
  80140b:	ff 75 10             	pushl  0x10(%ebp)
  80140e:	ff 75 0c             	pushl  0xc(%ebp)
  801411:	50                   	push   %eax
  801412:	ff d2                	call   *%edx
  801414:	89 c2                	mov    %eax,%edx
  801416:	83 c4 10             	add    $0x10,%esp
  801419:	eb 09                	jmp    801424 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80141b:	89 c2                	mov    %eax,%edx
  80141d:	eb 05                	jmp    801424 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80141f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801424:	89 d0                	mov    %edx,%eax
  801426:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801429:	c9                   	leave  
  80142a:	c3                   	ret    

0080142b <seek>:

int
seek(int fdnum, off_t offset)
{
  80142b:	55                   	push   %ebp
  80142c:	89 e5                	mov    %esp,%ebp
  80142e:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801431:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801434:	50                   	push   %eax
  801435:	ff 75 08             	pushl  0x8(%ebp)
  801438:	e8 22 fc ff ff       	call   80105f <fd_lookup>
  80143d:	83 c4 08             	add    $0x8,%esp
  801440:	85 c0                	test   %eax,%eax
  801442:	78 0e                	js     801452 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801444:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801447:	8b 55 0c             	mov    0xc(%ebp),%edx
  80144a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80144d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801452:	c9                   	leave  
  801453:	c3                   	ret    

00801454 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801454:	55                   	push   %ebp
  801455:	89 e5                	mov    %esp,%ebp
  801457:	53                   	push   %ebx
  801458:	83 ec 14             	sub    $0x14,%esp
  80145b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80145e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801461:	50                   	push   %eax
  801462:	53                   	push   %ebx
  801463:	e8 f7 fb ff ff       	call   80105f <fd_lookup>
  801468:	83 c4 08             	add    $0x8,%esp
  80146b:	89 c2                	mov    %eax,%edx
  80146d:	85 c0                	test   %eax,%eax
  80146f:	78 65                	js     8014d6 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801471:	83 ec 08             	sub    $0x8,%esp
  801474:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801477:	50                   	push   %eax
  801478:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80147b:	ff 30                	pushl  (%eax)
  80147d:	e8 33 fc ff ff       	call   8010b5 <dev_lookup>
  801482:	83 c4 10             	add    $0x10,%esp
  801485:	85 c0                	test   %eax,%eax
  801487:	78 44                	js     8014cd <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801489:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80148c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801490:	75 21                	jne    8014b3 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801492:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801497:	8b 40 48             	mov    0x48(%eax),%eax
  80149a:	83 ec 04             	sub    $0x4,%esp
  80149d:	53                   	push   %ebx
  80149e:	50                   	push   %eax
  80149f:	68 4c 2a 80 00       	push   $0x802a4c
  8014a4:	e8 ff ec ff ff       	call   8001a8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8014a9:	83 c4 10             	add    $0x10,%esp
  8014ac:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014b1:	eb 23                	jmp    8014d6 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8014b3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014b6:	8b 52 18             	mov    0x18(%edx),%edx
  8014b9:	85 d2                	test   %edx,%edx
  8014bb:	74 14                	je     8014d1 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8014bd:	83 ec 08             	sub    $0x8,%esp
  8014c0:	ff 75 0c             	pushl  0xc(%ebp)
  8014c3:	50                   	push   %eax
  8014c4:	ff d2                	call   *%edx
  8014c6:	89 c2                	mov    %eax,%edx
  8014c8:	83 c4 10             	add    $0x10,%esp
  8014cb:	eb 09                	jmp    8014d6 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014cd:	89 c2                	mov    %eax,%edx
  8014cf:	eb 05                	jmp    8014d6 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8014d1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8014d6:	89 d0                	mov    %edx,%eax
  8014d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014db:	c9                   	leave  
  8014dc:	c3                   	ret    

008014dd <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8014dd:	55                   	push   %ebp
  8014de:	89 e5                	mov    %esp,%ebp
  8014e0:	53                   	push   %ebx
  8014e1:	83 ec 14             	sub    $0x14,%esp
  8014e4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014e7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014ea:	50                   	push   %eax
  8014eb:	ff 75 08             	pushl  0x8(%ebp)
  8014ee:	e8 6c fb ff ff       	call   80105f <fd_lookup>
  8014f3:	83 c4 08             	add    $0x8,%esp
  8014f6:	89 c2                	mov    %eax,%edx
  8014f8:	85 c0                	test   %eax,%eax
  8014fa:	78 58                	js     801554 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014fc:	83 ec 08             	sub    $0x8,%esp
  8014ff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801502:	50                   	push   %eax
  801503:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801506:	ff 30                	pushl  (%eax)
  801508:	e8 a8 fb ff ff       	call   8010b5 <dev_lookup>
  80150d:	83 c4 10             	add    $0x10,%esp
  801510:	85 c0                	test   %eax,%eax
  801512:	78 37                	js     80154b <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801514:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801517:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80151b:	74 32                	je     80154f <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80151d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801520:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801527:	00 00 00 
	stat->st_isdir = 0;
  80152a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801531:	00 00 00 
	stat->st_dev = dev;
  801534:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80153a:	83 ec 08             	sub    $0x8,%esp
  80153d:	53                   	push   %ebx
  80153e:	ff 75 f0             	pushl  -0x10(%ebp)
  801541:	ff 50 14             	call   *0x14(%eax)
  801544:	89 c2                	mov    %eax,%edx
  801546:	83 c4 10             	add    $0x10,%esp
  801549:	eb 09                	jmp    801554 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80154b:	89 c2                	mov    %eax,%edx
  80154d:	eb 05                	jmp    801554 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80154f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801554:	89 d0                	mov    %edx,%eax
  801556:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801559:	c9                   	leave  
  80155a:	c3                   	ret    

0080155b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80155b:	55                   	push   %ebp
  80155c:	89 e5                	mov    %esp,%ebp
  80155e:	56                   	push   %esi
  80155f:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801560:	83 ec 08             	sub    $0x8,%esp
  801563:	6a 00                	push   $0x0
  801565:	ff 75 08             	pushl  0x8(%ebp)
  801568:	e8 0c 02 00 00       	call   801779 <open>
  80156d:	89 c3                	mov    %eax,%ebx
  80156f:	83 c4 10             	add    $0x10,%esp
  801572:	85 c0                	test   %eax,%eax
  801574:	78 1b                	js     801591 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801576:	83 ec 08             	sub    $0x8,%esp
  801579:	ff 75 0c             	pushl  0xc(%ebp)
  80157c:	50                   	push   %eax
  80157d:	e8 5b ff ff ff       	call   8014dd <fstat>
  801582:	89 c6                	mov    %eax,%esi
	close(fd);
  801584:	89 1c 24             	mov    %ebx,(%esp)
  801587:	e8 fd fb ff ff       	call   801189 <close>
	return r;
  80158c:	83 c4 10             	add    $0x10,%esp
  80158f:	89 f0                	mov    %esi,%eax
}
  801591:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801594:	5b                   	pop    %ebx
  801595:	5e                   	pop    %esi
  801596:	5d                   	pop    %ebp
  801597:	c3                   	ret    

00801598 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801598:	55                   	push   %ebp
  801599:	89 e5                	mov    %esp,%ebp
  80159b:	56                   	push   %esi
  80159c:	53                   	push   %ebx
  80159d:	89 c6                	mov    %eax,%esi
  80159f:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8015a1:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8015a8:	75 12                	jne    8015bc <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8015aa:	83 ec 0c             	sub    $0xc,%esp
  8015ad:	6a 01                	push   $0x1
  8015af:	e8 28 0d 00 00       	call   8022dc <ipc_find_env>
  8015b4:	a3 00 40 80 00       	mov    %eax,0x804000
  8015b9:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8015bc:	6a 07                	push   $0x7
  8015be:	68 00 50 80 00       	push   $0x805000
  8015c3:	56                   	push   %esi
  8015c4:	ff 35 00 40 80 00    	pushl  0x804000
  8015ca:	e8 b9 0c 00 00       	call   802288 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8015cf:	83 c4 0c             	add    $0xc,%esp
  8015d2:	6a 00                	push   $0x0
  8015d4:	53                   	push   %ebx
  8015d5:	6a 00                	push   $0x0
  8015d7:	e8 43 0c 00 00       	call   80221f <ipc_recv>
}
  8015dc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015df:	5b                   	pop    %ebx
  8015e0:	5e                   	pop    %esi
  8015e1:	5d                   	pop    %ebp
  8015e2:	c3                   	ret    

008015e3 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8015e3:	55                   	push   %ebp
  8015e4:	89 e5                	mov    %esp,%ebp
  8015e6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8015e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8015ec:	8b 40 0c             	mov    0xc(%eax),%eax
  8015ef:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8015f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015f7:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8015fc:	ba 00 00 00 00       	mov    $0x0,%edx
  801601:	b8 02 00 00 00       	mov    $0x2,%eax
  801606:	e8 8d ff ff ff       	call   801598 <fsipc>
}
  80160b:	c9                   	leave  
  80160c:	c3                   	ret    

0080160d <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80160d:	55                   	push   %ebp
  80160e:	89 e5                	mov    %esp,%ebp
  801610:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801613:	8b 45 08             	mov    0x8(%ebp),%eax
  801616:	8b 40 0c             	mov    0xc(%eax),%eax
  801619:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80161e:	ba 00 00 00 00       	mov    $0x0,%edx
  801623:	b8 06 00 00 00       	mov    $0x6,%eax
  801628:	e8 6b ff ff ff       	call   801598 <fsipc>
}
  80162d:	c9                   	leave  
  80162e:	c3                   	ret    

0080162f <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80162f:	55                   	push   %ebp
  801630:	89 e5                	mov    %esp,%ebp
  801632:	53                   	push   %ebx
  801633:	83 ec 04             	sub    $0x4,%esp
  801636:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801639:	8b 45 08             	mov    0x8(%ebp),%eax
  80163c:	8b 40 0c             	mov    0xc(%eax),%eax
  80163f:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801644:	ba 00 00 00 00       	mov    $0x0,%edx
  801649:	b8 05 00 00 00       	mov    $0x5,%eax
  80164e:	e8 45 ff ff ff       	call   801598 <fsipc>
  801653:	85 c0                	test   %eax,%eax
  801655:	78 2c                	js     801683 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801657:	83 ec 08             	sub    $0x8,%esp
  80165a:	68 00 50 80 00       	push   $0x805000
  80165f:	53                   	push   %ebx
  801660:	e8 c8 f0 ff ff       	call   80072d <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801665:	a1 80 50 80 00       	mov    0x805080,%eax
  80166a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801670:	a1 84 50 80 00       	mov    0x805084,%eax
  801675:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80167b:	83 c4 10             	add    $0x10,%esp
  80167e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801683:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801686:	c9                   	leave  
  801687:	c3                   	ret    

00801688 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801688:	55                   	push   %ebp
  801689:	89 e5                	mov    %esp,%ebp
  80168b:	53                   	push   %ebx
  80168c:	83 ec 08             	sub    $0x8,%esp
  80168f:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801692:	8b 55 08             	mov    0x8(%ebp),%edx
  801695:	8b 52 0c             	mov    0xc(%edx),%edx
  801698:	89 15 00 50 80 00    	mov    %edx,0x805000
  80169e:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8016a3:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  8016a8:	0f 46 d8             	cmovbe %eax,%ebx
	
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  8016ab:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  8016b1:	53                   	push   %ebx
  8016b2:	ff 75 0c             	pushl  0xc(%ebp)
  8016b5:	68 08 50 80 00       	push   $0x805008
  8016ba:	e8 00 f2 ff ff       	call   8008bf <memmove>

	
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) 
  8016bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8016c4:	b8 04 00 00 00       	mov    $0x4,%eax
  8016c9:	e8 ca fe ff ff       	call   801598 <fsipc>
  8016ce:	83 c4 10             	add    $0x10,%esp
  8016d1:	85 c0                	test   %eax,%eax
  8016d3:	78 1d                	js     8016f2 <devfile_write+0x6a>
		return r;
	assert(r <= n_real); 
  8016d5:	39 d8                	cmp    %ebx,%eax
  8016d7:	76 19                	jbe    8016f2 <devfile_write+0x6a>
  8016d9:	68 bc 2a 80 00       	push   $0x802abc
  8016de:	68 c8 2a 80 00       	push   $0x802ac8
  8016e3:	68 a3 00 00 00       	push   $0xa3
  8016e8:	68 dd 2a 80 00       	push   $0x802add
  8016ed:	e8 71 0a 00 00       	call   802163 <_panic>
	return r;
}
  8016f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016f5:	c9                   	leave  
  8016f6:	c3                   	ret    

008016f7 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8016f7:	55                   	push   %ebp
  8016f8:	89 e5                	mov    %esp,%ebp
  8016fa:	56                   	push   %esi
  8016fb:	53                   	push   %ebx
  8016fc:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8016ff:	8b 45 08             	mov    0x8(%ebp),%eax
  801702:	8b 40 0c             	mov    0xc(%eax),%eax
  801705:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80170a:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801710:	ba 00 00 00 00       	mov    $0x0,%edx
  801715:	b8 03 00 00 00       	mov    $0x3,%eax
  80171a:	e8 79 fe ff ff       	call   801598 <fsipc>
  80171f:	89 c3                	mov    %eax,%ebx
  801721:	85 c0                	test   %eax,%eax
  801723:	78 4b                	js     801770 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801725:	39 c6                	cmp    %eax,%esi
  801727:	73 16                	jae    80173f <devfile_read+0x48>
  801729:	68 e8 2a 80 00       	push   $0x802ae8
  80172e:	68 c8 2a 80 00       	push   $0x802ac8
  801733:	6a 7c                	push   $0x7c
  801735:	68 dd 2a 80 00       	push   $0x802add
  80173a:	e8 24 0a 00 00       	call   802163 <_panic>
	assert(r <= PGSIZE);
  80173f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801744:	7e 16                	jle    80175c <devfile_read+0x65>
  801746:	68 ef 2a 80 00       	push   $0x802aef
  80174b:	68 c8 2a 80 00       	push   $0x802ac8
  801750:	6a 7d                	push   $0x7d
  801752:	68 dd 2a 80 00       	push   $0x802add
  801757:	e8 07 0a 00 00       	call   802163 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80175c:	83 ec 04             	sub    $0x4,%esp
  80175f:	50                   	push   %eax
  801760:	68 00 50 80 00       	push   $0x805000
  801765:	ff 75 0c             	pushl  0xc(%ebp)
  801768:	e8 52 f1 ff ff       	call   8008bf <memmove>
	return r;
  80176d:	83 c4 10             	add    $0x10,%esp
}
  801770:	89 d8                	mov    %ebx,%eax
  801772:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801775:	5b                   	pop    %ebx
  801776:	5e                   	pop    %esi
  801777:	5d                   	pop    %ebp
  801778:	c3                   	ret    

00801779 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801779:	55                   	push   %ebp
  80177a:	89 e5                	mov    %esp,%ebp
  80177c:	53                   	push   %ebx
  80177d:	83 ec 20             	sub    $0x20,%esp
  801780:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801783:	53                   	push   %ebx
  801784:	e8 6b ef ff ff       	call   8006f4 <strlen>
  801789:	83 c4 10             	add    $0x10,%esp
  80178c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801791:	7f 67                	jg     8017fa <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801793:	83 ec 0c             	sub    $0xc,%esp
  801796:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801799:	50                   	push   %eax
  80179a:	e8 71 f8 ff ff       	call   801010 <fd_alloc>
  80179f:	83 c4 10             	add    $0x10,%esp
		return r;
  8017a2:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017a4:	85 c0                	test   %eax,%eax
  8017a6:	78 57                	js     8017ff <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8017a8:	83 ec 08             	sub    $0x8,%esp
  8017ab:	53                   	push   %ebx
  8017ac:	68 00 50 80 00       	push   $0x805000
  8017b1:	e8 77 ef ff ff       	call   80072d <strcpy>
	fsipcbuf.open.req_omode = mode;
  8017b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017b9:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8017be:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017c1:	b8 01 00 00 00       	mov    $0x1,%eax
  8017c6:	e8 cd fd ff ff       	call   801598 <fsipc>
  8017cb:	89 c3                	mov    %eax,%ebx
  8017cd:	83 c4 10             	add    $0x10,%esp
  8017d0:	85 c0                	test   %eax,%eax
  8017d2:	79 14                	jns    8017e8 <open+0x6f>
		fd_close(fd, 0);
  8017d4:	83 ec 08             	sub    $0x8,%esp
  8017d7:	6a 00                	push   $0x0
  8017d9:	ff 75 f4             	pushl  -0xc(%ebp)
  8017dc:	e8 27 f9 ff ff       	call   801108 <fd_close>
		return r;
  8017e1:	83 c4 10             	add    $0x10,%esp
  8017e4:	89 da                	mov    %ebx,%edx
  8017e6:	eb 17                	jmp    8017ff <open+0x86>
	}

	return fd2num(fd);
  8017e8:	83 ec 0c             	sub    $0xc,%esp
  8017eb:	ff 75 f4             	pushl  -0xc(%ebp)
  8017ee:	e8 f6 f7 ff ff       	call   800fe9 <fd2num>
  8017f3:	89 c2                	mov    %eax,%edx
  8017f5:	83 c4 10             	add    $0x10,%esp
  8017f8:	eb 05                	jmp    8017ff <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8017fa:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8017ff:	89 d0                	mov    %edx,%eax
  801801:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801804:	c9                   	leave  
  801805:	c3                   	ret    

00801806 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801806:	55                   	push   %ebp
  801807:	89 e5                	mov    %esp,%ebp
  801809:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80180c:	ba 00 00 00 00       	mov    $0x0,%edx
  801811:	b8 08 00 00 00       	mov    $0x8,%eax
  801816:	e8 7d fd ff ff       	call   801598 <fsipc>
}
  80181b:	c9                   	leave  
  80181c:	c3                   	ret    

0080181d <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  80181d:	55                   	push   %ebp
  80181e:	89 e5                	mov    %esp,%ebp
  801820:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801823:	68 fb 2a 80 00       	push   $0x802afb
  801828:	ff 75 0c             	pushl  0xc(%ebp)
  80182b:	e8 fd ee ff ff       	call   80072d <strcpy>
	return 0;
}
  801830:	b8 00 00 00 00       	mov    $0x0,%eax
  801835:	c9                   	leave  
  801836:	c3                   	ret    

00801837 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801837:	55                   	push   %ebp
  801838:	89 e5                	mov    %esp,%ebp
  80183a:	53                   	push   %ebx
  80183b:	83 ec 10             	sub    $0x10,%esp
  80183e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801841:	53                   	push   %ebx
  801842:	e8 ce 0a 00 00       	call   802315 <pageref>
  801847:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  80184a:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  80184f:	83 f8 01             	cmp    $0x1,%eax
  801852:	75 10                	jne    801864 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801854:	83 ec 0c             	sub    $0xc,%esp
  801857:	ff 73 0c             	pushl  0xc(%ebx)
  80185a:	e8 c0 02 00 00       	call   801b1f <nsipc_close>
  80185f:	89 c2                	mov    %eax,%edx
  801861:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801864:	89 d0                	mov    %edx,%eax
  801866:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801869:	c9                   	leave  
  80186a:	c3                   	ret    

0080186b <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  80186b:	55                   	push   %ebp
  80186c:	89 e5                	mov    %esp,%ebp
  80186e:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801871:	6a 00                	push   $0x0
  801873:	ff 75 10             	pushl  0x10(%ebp)
  801876:	ff 75 0c             	pushl  0xc(%ebp)
  801879:	8b 45 08             	mov    0x8(%ebp),%eax
  80187c:	ff 70 0c             	pushl  0xc(%eax)
  80187f:	e8 78 03 00 00       	call   801bfc <nsipc_send>
}
  801884:	c9                   	leave  
  801885:	c3                   	ret    

00801886 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801886:	55                   	push   %ebp
  801887:	89 e5                	mov    %esp,%ebp
  801889:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  80188c:	6a 00                	push   $0x0
  80188e:	ff 75 10             	pushl  0x10(%ebp)
  801891:	ff 75 0c             	pushl  0xc(%ebp)
  801894:	8b 45 08             	mov    0x8(%ebp),%eax
  801897:	ff 70 0c             	pushl  0xc(%eax)
  80189a:	e8 f1 02 00 00       	call   801b90 <nsipc_recv>
}
  80189f:	c9                   	leave  
  8018a0:	c3                   	ret    

008018a1 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8018a1:	55                   	push   %ebp
  8018a2:	89 e5                	mov    %esp,%ebp
  8018a4:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8018a7:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8018aa:	52                   	push   %edx
  8018ab:	50                   	push   %eax
  8018ac:	e8 ae f7 ff ff       	call   80105f <fd_lookup>
  8018b1:	83 c4 10             	add    $0x10,%esp
  8018b4:	85 c0                	test   %eax,%eax
  8018b6:	78 17                	js     8018cf <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8018b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018bb:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  8018c1:	39 08                	cmp    %ecx,(%eax)
  8018c3:	75 05                	jne    8018ca <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8018c5:	8b 40 0c             	mov    0xc(%eax),%eax
  8018c8:	eb 05                	jmp    8018cf <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  8018ca:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  8018cf:	c9                   	leave  
  8018d0:	c3                   	ret    

008018d1 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  8018d1:	55                   	push   %ebp
  8018d2:	89 e5                	mov    %esp,%ebp
  8018d4:	56                   	push   %esi
  8018d5:	53                   	push   %ebx
  8018d6:	83 ec 1c             	sub    $0x1c,%esp
  8018d9:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8018db:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018de:	50                   	push   %eax
  8018df:	e8 2c f7 ff ff       	call   801010 <fd_alloc>
  8018e4:	89 c3                	mov    %eax,%ebx
  8018e6:	83 c4 10             	add    $0x10,%esp
  8018e9:	85 c0                	test   %eax,%eax
  8018eb:	78 1b                	js     801908 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8018ed:	83 ec 04             	sub    $0x4,%esp
  8018f0:	68 07 04 00 00       	push   $0x407
  8018f5:	ff 75 f4             	pushl  -0xc(%ebp)
  8018f8:	6a 00                	push   $0x0
  8018fa:	e8 31 f2 ff ff       	call   800b30 <sys_page_alloc>
  8018ff:	89 c3                	mov    %eax,%ebx
  801901:	83 c4 10             	add    $0x10,%esp
  801904:	85 c0                	test   %eax,%eax
  801906:	79 10                	jns    801918 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801908:	83 ec 0c             	sub    $0xc,%esp
  80190b:	56                   	push   %esi
  80190c:	e8 0e 02 00 00       	call   801b1f <nsipc_close>
		return r;
  801911:	83 c4 10             	add    $0x10,%esp
  801914:	89 d8                	mov    %ebx,%eax
  801916:	eb 24                	jmp    80193c <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801918:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80191e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801921:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801923:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801926:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  80192d:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801930:	83 ec 0c             	sub    $0xc,%esp
  801933:	50                   	push   %eax
  801934:	e8 b0 f6 ff ff       	call   800fe9 <fd2num>
  801939:	83 c4 10             	add    $0x10,%esp
}
  80193c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80193f:	5b                   	pop    %ebx
  801940:	5e                   	pop    %esi
  801941:	5d                   	pop    %ebp
  801942:	c3                   	ret    

00801943 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801943:	55                   	push   %ebp
  801944:	89 e5                	mov    %esp,%ebp
  801946:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801949:	8b 45 08             	mov    0x8(%ebp),%eax
  80194c:	e8 50 ff ff ff       	call   8018a1 <fd2sockid>
		return r;
  801951:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801953:	85 c0                	test   %eax,%eax
  801955:	78 1f                	js     801976 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801957:	83 ec 04             	sub    $0x4,%esp
  80195a:	ff 75 10             	pushl  0x10(%ebp)
  80195d:	ff 75 0c             	pushl  0xc(%ebp)
  801960:	50                   	push   %eax
  801961:	e8 12 01 00 00       	call   801a78 <nsipc_accept>
  801966:	83 c4 10             	add    $0x10,%esp
		return r;
  801969:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80196b:	85 c0                	test   %eax,%eax
  80196d:	78 07                	js     801976 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  80196f:	e8 5d ff ff ff       	call   8018d1 <alloc_sockfd>
  801974:	89 c1                	mov    %eax,%ecx
}
  801976:	89 c8                	mov    %ecx,%eax
  801978:	c9                   	leave  
  801979:	c3                   	ret    

0080197a <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80197a:	55                   	push   %ebp
  80197b:	89 e5                	mov    %esp,%ebp
  80197d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801980:	8b 45 08             	mov    0x8(%ebp),%eax
  801983:	e8 19 ff ff ff       	call   8018a1 <fd2sockid>
  801988:	85 c0                	test   %eax,%eax
  80198a:	78 12                	js     80199e <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  80198c:	83 ec 04             	sub    $0x4,%esp
  80198f:	ff 75 10             	pushl  0x10(%ebp)
  801992:	ff 75 0c             	pushl  0xc(%ebp)
  801995:	50                   	push   %eax
  801996:	e8 2d 01 00 00       	call   801ac8 <nsipc_bind>
  80199b:	83 c4 10             	add    $0x10,%esp
}
  80199e:	c9                   	leave  
  80199f:	c3                   	ret    

008019a0 <shutdown>:

int
shutdown(int s, int how)
{
  8019a0:	55                   	push   %ebp
  8019a1:	89 e5                	mov    %esp,%ebp
  8019a3:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a9:	e8 f3 fe ff ff       	call   8018a1 <fd2sockid>
  8019ae:	85 c0                	test   %eax,%eax
  8019b0:	78 0f                	js     8019c1 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8019b2:	83 ec 08             	sub    $0x8,%esp
  8019b5:	ff 75 0c             	pushl  0xc(%ebp)
  8019b8:	50                   	push   %eax
  8019b9:	e8 3f 01 00 00       	call   801afd <nsipc_shutdown>
  8019be:	83 c4 10             	add    $0x10,%esp
}
  8019c1:	c9                   	leave  
  8019c2:	c3                   	ret    

008019c3 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8019c3:	55                   	push   %ebp
  8019c4:	89 e5                	mov    %esp,%ebp
  8019c6:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8019cc:	e8 d0 fe ff ff       	call   8018a1 <fd2sockid>
  8019d1:	85 c0                	test   %eax,%eax
  8019d3:	78 12                	js     8019e7 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  8019d5:	83 ec 04             	sub    $0x4,%esp
  8019d8:	ff 75 10             	pushl  0x10(%ebp)
  8019db:	ff 75 0c             	pushl  0xc(%ebp)
  8019de:	50                   	push   %eax
  8019df:	e8 55 01 00 00       	call   801b39 <nsipc_connect>
  8019e4:	83 c4 10             	add    $0x10,%esp
}
  8019e7:	c9                   	leave  
  8019e8:	c3                   	ret    

008019e9 <listen>:

int
listen(int s, int backlog)
{
  8019e9:	55                   	push   %ebp
  8019ea:	89 e5                	mov    %esp,%ebp
  8019ec:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f2:	e8 aa fe ff ff       	call   8018a1 <fd2sockid>
  8019f7:	85 c0                	test   %eax,%eax
  8019f9:	78 0f                	js     801a0a <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8019fb:	83 ec 08             	sub    $0x8,%esp
  8019fe:	ff 75 0c             	pushl  0xc(%ebp)
  801a01:	50                   	push   %eax
  801a02:	e8 67 01 00 00       	call   801b6e <nsipc_listen>
  801a07:	83 c4 10             	add    $0x10,%esp
}
  801a0a:	c9                   	leave  
  801a0b:	c3                   	ret    

00801a0c <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801a0c:	55                   	push   %ebp
  801a0d:	89 e5                	mov    %esp,%ebp
  801a0f:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801a12:	ff 75 10             	pushl  0x10(%ebp)
  801a15:	ff 75 0c             	pushl  0xc(%ebp)
  801a18:	ff 75 08             	pushl  0x8(%ebp)
  801a1b:	e8 3a 02 00 00       	call   801c5a <nsipc_socket>
  801a20:	83 c4 10             	add    $0x10,%esp
  801a23:	85 c0                	test   %eax,%eax
  801a25:	78 05                	js     801a2c <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801a27:	e8 a5 fe ff ff       	call   8018d1 <alloc_sockfd>
}
  801a2c:	c9                   	leave  
  801a2d:	c3                   	ret    

00801a2e <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801a2e:	55                   	push   %ebp
  801a2f:	89 e5                	mov    %esp,%ebp
  801a31:	53                   	push   %ebx
  801a32:	83 ec 04             	sub    $0x4,%esp
  801a35:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801a37:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801a3e:	75 12                	jne    801a52 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801a40:	83 ec 0c             	sub    $0xc,%esp
  801a43:	6a 02                	push   $0x2
  801a45:	e8 92 08 00 00       	call   8022dc <ipc_find_env>
  801a4a:	a3 04 40 80 00       	mov    %eax,0x804004
  801a4f:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801a52:	6a 07                	push   $0x7
  801a54:	68 00 60 80 00       	push   $0x806000
  801a59:	53                   	push   %ebx
  801a5a:	ff 35 04 40 80 00    	pushl  0x804004
  801a60:	e8 23 08 00 00       	call   802288 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801a65:	83 c4 0c             	add    $0xc,%esp
  801a68:	6a 00                	push   $0x0
  801a6a:	6a 00                	push   $0x0
  801a6c:	6a 00                	push   $0x0
  801a6e:	e8 ac 07 00 00       	call   80221f <ipc_recv>
}
  801a73:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a76:	c9                   	leave  
  801a77:	c3                   	ret    

00801a78 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801a78:	55                   	push   %ebp
  801a79:	89 e5                	mov    %esp,%ebp
  801a7b:	56                   	push   %esi
  801a7c:	53                   	push   %ebx
  801a7d:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801a80:	8b 45 08             	mov    0x8(%ebp),%eax
  801a83:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801a88:	8b 06                	mov    (%esi),%eax
  801a8a:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801a8f:	b8 01 00 00 00       	mov    $0x1,%eax
  801a94:	e8 95 ff ff ff       	call   801a2e <nsipc>
  801a99:	89 c3                	mov    %eax,%ebx
  801a9b:	85 c0                	test   %eax,%eax
  801a9d:	78 20                	js     801abf <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801a9f:	83 ec 04             	sub    $0x4,%esp
  801aa2:	ff 35 10 60 80 00    	pushl  0x806010
  801aa8:	68 00 60 80 00       	push   $0x806000
  801aad:	ff 75 0c             	pushl  0xc(%ebp)
  801ab0:	e8 0a ee ff ff       	call   8008bf <memmove>
		*addrlen = ret->ret_addrlen;
  801ab5:	a1 10 60 80 00       	mov    0x806010,%eax
  801aba:	89 06                	mov    %eax,(%esi)
  801abc:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801abf:	89 d8                	mov    %ebx,%eax
  801ac1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ac4:	5b                   	pop    %ebx
  801ac5:	5e                   	pop    %esi
  801ac6:	5d                   	pop    %ebp
  801ac7:	c3                   	ret    

00801ac8 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801ac8:	55                   	push   %ebp
  801ac9:	89 e5                	mov    %esp,%ebp
  801acb:	53                   	push   %ebx
  801acc:	83 ec 08             	sub    $0x8,%esp
  801acf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801ad2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ad5:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801ada:	53                   	push   %ebx
  801adb:	ff 75 0c             	pushl  0xc(%ebp)
  801ade:	68 04 60 80 00       	push   $0x806004
  801ae3:	e8 d7 ed ff ff       	call   8008bf <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801ae8:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801aee:	b8 02 00 00 00       	mov    $0x2,%eax
  801af3:	e8 36 ff ff ff       	call   801a2e <nsipc>
}
  801af8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801afb:	c9                   	leave  
  801afc:	c3                   	ret    

00801afd <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801afd:	55                   	push   %ebp
  801afe:	89 e5                	mov    %esp,%ebp
  801b00:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801b03:	8b 45 08             	mov    0x8(%ebp),%eax
  801b06:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801b0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b0e:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801b13:	b8 03 00 00 00       	mov    $0x3,%eax
  801b18:	e8 11 ff ff ff       	call   801a2e <nsipc>
}
  801b1d:	c9                   	leave  
  801b1e:	c3                   	ret    

00801b1f <nsipc_close>:

int
nsipc_close(int s)
{
  801b1f:	55                   	push   %ebp
  801b20:	89 e5                	mov    %esp,%ebp
  801b22:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801b25:	8b 45 08             	mov    0x8(%ebp),%eax
  801b28:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801b2d:	b8 04 00 00 00       	mov    $0x4,%eax
  801b32:	e8 f7 fe ff ff       	call   801a2e <nsipc>
}
  801b37:	c9                   	leave  
  801b38:	c3                   	ret    

00801b39 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801b39:	55                   	push   %ebp
  801b3a:	89 e5                	mov    %esp,%ebp
  801b3c:	53                   	push   %ebx
  801b3d:	83 ec 08             	sub    $0x8,%esp
  801b40:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801b43:	8b 45 08             	mov    0x8(%ebp),%eax
  801b46:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801b4b:	53                   	push   %ebx
  801b4c:	ff 75 0c             	pushl  0xc(%ebp)
  801b4f:	68 04 60 80 00       	push   $0x806004
  801b54:	e8 66 ed ff ff       	call   8008bf <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801b59:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801b5f:	b8 05 00 00 00       	mov    $0x5,%eax
  801b64:	e8 c5 fe ff ff       	call   801a2e <nsipc>
}
  801b69:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b6c:	c9                   	leave  
  801b6d:	c3                   	ret    

00801b6e <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801b6e:	55                   	push   %ebp
  801b6f:	89 e5                	mov    %esp,%ebp
  801b71:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801b74:	8b 45 08             	mov    0x8(%ebp),%eax
  801b77:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801b7c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b7f:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801b84:	b8 06 00 00 00       	mov    $0x6,%eax
  801b89:	e8 a0 fe ff ff       	call   801a2e <nsipc>
}
  801b8e:	c9                   	leave  
  801b8f:	c3                   	ret    

00801b90 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801b90:	55                   	push   %ebp
  801b91:	89 e5                	mov    %esp,%ebp
  801b93:	56                   	push   %esi
  801b94:	53                   	push   %ebx
  801b95:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801b98:	8b 45 08             	mov    0x8(%ebp),%eax
  801b9b:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801ba0:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801ba6:	8b 45 14             	mov    0x14(%ebp),%eax
  801ba9:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801bae:	b8 07 00 00 00       	mov    $0x7,%eax
  801bb3:	e8 76 fe ff ff       	call   801a2e <nsipc>
  801bb8:	89 c3                	mov    %eax,%ebx
  801bba:	85 c0                	test   %eax,%eax
  801bbc:	78 35                	js     801bf3 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801bbe:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801bc3:	7f 04                	jg     801bc9 <nsipc_recv+0x39>
  801bc5:	39 c6                	cmp    %eax,%esi
  801bc7:	7d 16                	jge    801bdf <nsipc_recv+0x4f>
  801bc9:	68 07 2b 80 00       	push   $0x802b07
  801bce:	68 c8 2a 80 00       	push   $0x802ac8
  801bd3:	6a 62                	push   $0x62
  801bd5:	68 1c 2b 80 00       	push   $0x802b1c
  801bda:	e8 84 05 00 00       	call   802163 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801bdf:	83 ec 04             	sub    $0x4,%esp
  801be2:	50                   	push   %eax
  801be3:	68 00 60 80 00       	push   $0x806000
  801be8:	ff 75 0c             	pushl  0xc(%ebp)
  801beb:	e8 cf ec ff ff       	call   8008bf <memmove>
  801bf0:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801bf3:	89 d8                	mov    %ebx,%eax
  801bf5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bf8:	5b                   	pop    %ebx
  801bf9:	5e                   	pop    %esi
  801bfa:	5d                   	pop    %ebp
  801bfb:	c3                   	ret    

00801bfc <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801bfc:	55                   	push   %ebp
  801bfd:	89 e5                	mov    %esp,%ebp
  801bff:	53                   	push   %ebx
  801c00:	83 ec 04             	sub    $0x4,%esp
  801c03:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801c06:	8b 45 08             	mov    0x8(%ebp),%eax
  801c09:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801c0e:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801c14:	7e 16                	jle    801c2c <nsipc_send+0x30>
  801c16:	68 28 2b 80 00       	push   $0x802b28
  801c1b:	68 c8 2a 80 00       	push   $0x802ac8
  801c20:	6a 6d                	push   $0x6d
  801c22:	68 1c 2b 80 00       	push   $0x802b1c
  801c27:	e8 37 05 00 00       	call   802163 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801c2c:	83 ec 04             	sub    $0x4,%esp
  801c2f:	53                   	push   %ebx
  801c30:	ff 75 0c             	pushl  0xc(%ebp)
  801c33:	68 0c 60 80 00       	push   $0x80600c
  801c38:	e8 82 ec ff ff       	call   8008bf <memmove>
	nsipcbuf.send.req_size = size;
  801c3d:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801c43:	8b 45 14             	mov    0x14(%ebp),%eax
  801c46:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801c4b:	b8 08 00 00 00       	mov    $0x8,%eax
  801c50:	e8 d9 fd ff ff       	call   801a2e <nsipc>
}
  801c55:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c58:	c9                   	leave  
  801c59:	c3                   	ret    

00801c5a <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801c5a:	55                   	push   %ebp
  801c5b:	89 e5                	mov    %esp,%ebp
  801c5d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801c60:	8b 45 08             	mov    0x8(%ebp),%eax
  801c63:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801c68:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c6b:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801c70:	8b 45 10             	mov    0x10(%ebp),%eax
  801c73:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801c78:	b8 09 00 00 00       	mov    $0x9,%eax
  801c7d:	e8 ac fd ff ff       	call   801a2e <nsipc>
}
  801c82:	c9                   	leave  
  801c83:	c3                   	ret    

00801c84 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c84:	55                   	push   %ebp
  801c85:	89 e5                	mov    %esp,%ebp
  801c87:	56                   	push   %esi
  801c88:	53                   	push   %ebx
  801c89:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c8c:	83 ec 0c             	sub    $0xc,%esp
  801c8f:	ff 75 08             	pushl  0x8(%ebp)
  801c92:	e8 62 f3 ff ff       	call   800ff9 <fd2data>
  801c97:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801c99:	83 c4 08             	add    $0x8,%esp
  801c9c:	68 34 2b 80 00       	push   $0x802b34
  801ca1:	53                   	push   %ebx
  801ca2:	e8 86 ea ff ff       	call   80072d <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ca7:	8b 46 04             	mov    0x4(%esi),%eax
  801caa:	2b 06                	sub    (%esi),%eax
  801cac:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801cb2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801cb9:	00 00 00 
	stat->st_dev = &devpipe;
  801cbc:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801cc3:	30 80 00 
	return 0;
}
  801cc6:	b8 00 00 00 00       	mov    $0x0,%eax
  801ccb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cce:	5b                   	pop    %ebx
  801ccf:	5e                   	pop    %esi
  801cd0:	5d                   	pop    %ebp
  801cd1:	c3                   	ret    

00801cd2 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801cd2:	55                   	push   %ebp
  801cd3:	89 e5                	mov    %esp,%ebp
  801cd5:	53                   	push   %ebx
  801cd6:	83 ec 0c             	sub    $0xc,%esp
  801cd9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801cdc:	53                   	push   %ebx
  801cdd:	6a 00                	push   $0x0
  801cdf:	e8 d1 ee ff ff       	call   800bb5 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ce4:	89 1c 24             	mov    %ebx,(%esp)
  801ce7:	e8 0d f3 ff ff       	call   800ff9 <fd2data>
  801cec:	83 c4 08             	add    $0x8,%esp
  801cef:	50                   	push   %eax
  801cf0:	6a 00                	push   $0x0
  801cf2:	e8 be ee ff ff       	call   800bb5 <sys_page_unmap>
}
  801cf7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cfa:	c9                   	leave  
  801cfb:	c3                   	ret    

00801cfc <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801cfc:	55                   	push   %ebp
  801cfd:	89 e5                	mov    %esp,%ebp
  801cff:	57                   	push   %edi
  801d00:	56                   	push   %esi
  801d01:	53                   	push   %ebx
  801d02:	83 ec 1c             	sub    $0x1c,%esp
  801d05:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801d08:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801d0a:	a1 08 40 80 00       	mov    0x804008,%eax
  801d0f:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801d12:	83 ec 0c             	sub    $0xc,%esp
  801d15:	ff 75 e0             	pushl  -0x20(%ebp)
  801d18:	e8 f8 05 00 00       	call   802315 <pageref>
  801d1d:	89 c3                	mov    %eax,%ebx
  801d1f:	89 3c 24             	mov    %edi,(%esp)
  801d22:	e8 ee 05 00 00       	call   802315 <pageref>
  801d27:	83 c4 10             	add    $0x10,%esp
  801d2a:	39 c3                	cmp    %eax,%ebx
  801d2c:	0f 94 c1             	sete   %cl
  801d2f:	0f b6 c9             	movzbl %cl,%ecx
  801d32:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801d35:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801d3b:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801d3e:	39 ce                	cmp    %ecx,%esi
  801d40:	74 1b                	je     801d5d <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801d42:	39 c3                	cmp    %eax,%ebx
  801d44:	75 c4                	jne    801d0a <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d46:	8b 42 58             	mov    0x58(%edx),%eax
  801d49:	ff 75 e4             	pushl  -0x1c(%ebp)
  801d4c:	50                   	push   %eax
  801d4d:	56                   	push   %esi
  801d4e:	68 3b 2b 80 00       	push   $0x802b3b
  801d53:	e8 50 e4 ff ff       	call   8001a8 <cprintf>
  801d58:	83 c4 10             	add    $0x10,%esp
  801d5b:	eb ad                	jmp    801d0a <_pipeisclosed+0xe>
	}
}
  801d5d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d60:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d63:	5b                   	pop    %ebx
  801d64:	5e                   	pop    %esi
  801d65:	5f                   	pop    %edi
  801d66:	5d                   	pop    %ebp
  801d67:	c3                   	ret    

00801d68 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d68:	55                   	push   %ebp
  801d69:	89 e5                	mov    %esp,%ebp
  801d6b:	57                   	push   %edi
  801d6c:	56                   	push   %esi
  801d6d:	53                   	push   %ebx
  801d6e:	83 ec 28             	sub    $0x28,%esp
  801d71:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801d74:	56                   	push   %esi
  801d75:	e8 7f f2 ff ff       	call   800ff9 <fd2data>
  801d7a:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d7c:	83 c4 10             	add    $0x10,%esp
  801d7f:	bf 00 00 00 00       	mov    $0x0,%edi
  801d84:	eb 4b                	jmp    801dd1 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801d86:	89 da                	mov    %ebx,%edx
  801d88:	89 f0                	mov    %esi,%eax
  801d8a:	e8 6d ff ff ff       	call   801cfc <_pipeisclosed>
  801d8f:	85 c0                	test   %eax,%eax
  801d91:	75 48                	jne    801ddb <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801d93:	e8 79 ed ff ff       	call   800b11 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d98:	8b 43 04             	mov    0x4(%ebx),%eax
  801d9b:	8b 0b                	mov    (%ebx),%ecx
  801d9d:	8d 51 20             	lea    0x20(%ecx),%edx
  801da0:	39 d0                	cmp    %edx,%eax
  801da2:	73 e2                	jae    801d86 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801da4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801da7:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801dab:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801dae:	89 c2                	mov    %eax,%edx
  801db0:	c1 fa 1f             	sar    $0x1f,%edx
  801db3:	89 d1                	mov    %edx,%ecx
  801db5:	c1 e9 1b             	shr    $0x1b,%ecx
  801db8:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801dbb:	83 e2 1f             	and    $0x1f,%edx
  801dbe:	29 ca                	sub    %ecx,%edx
  801dc0:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801dc4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801dc8:	83 c0 01             	add    $0x1,%eax
  801dcb:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801dce:	83 c7 01             	add    $0x1,%edi
  801dd1:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801dd4:	75 c2                	jne    801d98 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801dd6:	8b 45 10             	mov    0x10(%ebp),%eax
  801dd9:	eb 05                	jmp    801de0 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ddb:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801de0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801de3:	5b                   	pop    %ebx
  801de4:	5e                   	pop    %esi
  801de5:	5f                   	pop    %edi
  801de6:	5d                   	pop    %ebp
  801de7:	c3                   	ret    

00801de8 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801de8:	55                   	push   %ebp
  801de9:	89 e5                	mov    %esp,%ebp
  801deb:	57                   	push   %edi
  801dec:	56                   	push   %esi
  801ded:	53                   	push   %ebx
  801dee:	83 ec 18             	sub    $0x18,%esp
  801df1:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801df4:	57                   	push   %edi
  801df5:	e8 ff f1 ff ff       	call   800ff9 <fd2data>
  801dfa:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801dfc:	83 c4 10             	add    $0x10,%esp
  801dff:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e04:	eb 3d                	jmp    801e43 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801e06:	85 db                	test   %ebx,%ebx
  801e08:	74 04                	je     801e0e <devpipe_read+0x26>
				return i;
  801e0a:	89 d8                	mov    %ebx,%eax
  801e0c:	eb 44                	jmp    801e52 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801e0e:	89 f2                	mov    %esi,%edx
  801e10:	89 f8                	mov    %edi,%eax
  801e12:	e8 e5 fe ff ff       	call   801cfc <_pipeisclosed>
  801e17:	85 c0                	test   %eax,%eax
  801e19:	75 32                	jne    801e4d <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801e1b:	e8 f1 ec ff ff       	call   800b11 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801e20:	8b 06                	mov    (%esi),%eax
  801e22:	3b 46 04             	cmp    0x4(%esi),%eax
  801e25:	74 df                	je     801e06 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e27:	99                   	cltd   
  801e28:	c1 ea 1b             	shr    $0x1b,%edx
  801e2b:	01 d0                	add    %edx,%eax
  801e2d:	83 e0 1f             	and    $0x1f,%eax
  801e30:	29 d0                	sub    %edx,%eax
  801e32:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801e37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e3a:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801e3d:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e40:	83 c3 01             	add    $0x1,%ebx
  801e43:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801e46:	75 d8                	jne    801e20 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801e48:	8b 45 10             	mov    0x10(%ebp),%eax
  801e4b:	eb 05                	jmp    801e52 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e4d:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801e52:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e55:	5b                   	pop    %ebx
  801e56:	5e                   	pop    %esi
  801e57:	5f                   	pop    %edi
  801e58:	5d                   	pop    %ebp
  801e59:	c3                   	ret    

00801e5a <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801e5a:	55                   	push   %ebp
  801e5b:	89 e5                	mov    %esp,%ebp
  801e5d:	56                   	push   %esi
  801e5e:	53                   	push   %ebx
  801e5f:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801e62:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e65:	50                   	push   %eax
  801e66:	e8 a5 f1 ff ff       	call   801010 <fd_alloc>
  801e6b:	83 c4 10             	add    $0x10,%esp
  801e6e:	89 c2                	mov    %eax,%edx
  801e70:	85 c0                	test   %eax,%eax
  801e72:	0f 88 2c 01 00 00    	js     801fa4 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e78:	83 ec 04             	sub    $0x4,%esp
  801e7b:	68 07 04 00 00       	push   $0x407
  801e80:	ff 75 f4             	pushl  -0xc(%ebp)
  801e83:	6a 00                	push   $0x0
  801e85:	e8 a6 ec ff ff       	call   800b30 <sys_page_alloc>
  801e8a:	83 c4 10             	add    $0x10,%esp
  801e8d:	89 c2                	mov    %eax,%edx
  801e8f:	85 c0                	test   %eax,%eax
  801e91:	0f 88 0d 01 00 00    	js     801fa4 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801e97:	83 ec 0c             	sub    $0xc,%esp
  801e9a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e9d:	50                   	push   %eax
  801e9e:	e8 6d f1 ff ff       	call   801010 <fd_alloc>
  801ea3:	89 c3                	mov    %eax,%ebx
  801ea5:	83 c4 10             	add    $0x10,%esp
  801ea8:	85 c0                	test   %eax,%eax
  801eaa:	0f 88 e2 00 00 00    	js     801f92 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801eb0:	83 ec 04             	sub    $0x4,%esp
  801eb3:	68 07 04 00 00       	push   $0x407
  801eb8:	ff 75 f0             	pushl  -0x10(%ebp)
  801ebb:	6a 00                	push   $0x0
  801ebd:	e8 6e ec ff ff       	call   800b30 <sys_page_alloc>
  801ec2:	89 c3                	mov    %eax,%ebx
  801ec4:	83 c4 10             	add    $0x10,%esp
  801ec7:	85 c0                	test   %eax,%eax
  801ec9:	0f 88 c3 00 00 00    	js     801f92 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801ecf:	83 ec 0c             	sub    $0xc,%esp
  801ed2:	ff 75 f4             	pushl  -0xc(%ebp)
  801ed5:	e8 1f f1 ff ff       	call   800ff9 <fd2data>
  801eda:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801edc:	83 c4 0c             	add    $0xc,%esp
  801edf:	68 07 04 00 00       	push   $0x407
  801ee4:	50                   	push   %eax
  801ee5:	6a 00                	push   $0x0
  801ee7:	e8 44 ec ff ff       	call   800b30 <sys_page_alloc>
  801eec:	89 c3                	mov    %eax,%ebx
  801eee:	83 c4 10             	add    $0x10,%esp
  801ef1:	85 c0                	test   %eax,%eax
  801ef3:	0f 88 89 00 00 00    	js     801f82 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ef9:	83 ec 0c             	sub    $0xc,%esp
  801efc:	ff 75 f0             	pushl  -0x10(%ebp)
  801eff:	e8 f5 f0 ff ff       	call   800ff9 <fd2data>
  801f04:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801f0b:	50                   	push   %eax
  801f0c:	6a 00                	push   $0x0
  801f0e:	56                   	push   %esi
  801f0f:	6a 00                	push   $0x0
  801f11:	e8 5d ec ff ff       	call   800b73 <sys_page_map>
  801f16:	89 c3                	mov    %eax,%ebx
  801f18:	83 c4 20             	add    $0x20,%esp
  801f1b:	85 c0                	test   %eax,%eax
  801f1d:	78 55                	js     801f74 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801f1f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f25:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f28:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801f2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f2d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801f34:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f3d:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801f3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f42:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801f49:	83 ec 0c             	sub    $0xc,%esp
  801f4c:	ff 75 f4             	pushl  -0xc(%ebp)
  801f4f:	e8 95 f0 ff ff       	call   800fe9 <fd2num>
  801f54:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f57:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801f59:	83 c4 04             	add    $0x4,%esp
  801f5c:	ff 75 f0             	pushl  -0x10(%ebp)
  801f5f:	e8 85 f0 ff ff       	call   800fe9 <fd2num>
  801f64:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f67:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801f6a:	83 c4 10             	add    $0x10,%esp
  801f6d:	ba 00 00 00 00       	mov    $0x0,%edx
  801f72:	eb 30                	jmp    801fa4 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801f74:	83 ec 08             	sub    $0x8,%esp
  801f77:	56                   	push   %esi
  801f78:	6a 00                	push   $0x0
  801f7a:	e8 36 ec ff ff       	call   800bb5 <sys_page_unmap>
  801f7f:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801f82:	83 ec 08             	sub    $0x8,%esp
  801f85:	ff 75 f0             	pushl  -0x10(%ebp)
  801f88:	6a 00                	push   $0x0
  801f8a:	e8 26 ec ff ff       	call   800bb5 <sys_page_unmap>
  801f8f:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801f92:	83 ec 08             	sub    $0x8,%esp
  801f95:	ff 75 f4             	pushl  -0xc(%ebp)
  801f98:	6a 00                	push   $0x0
  801f9a:	e8 16 ec ff ff       	call   800bb5 <sys_page_unmap>
  801f9f:	83 c4 10             	add    $0x10,%esp
  801fa2:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801fa4:	89 d0                	mov    %edx,%eax
  801fa6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fa9:	5b                   	pop    %ebx
  801faa:	5e                   	pop    %esi
  801fab:	5d                   	pop    %ebp
  801fac:	c3                   	ret    

00801fad <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801fad:	55                   	push   %ebp
  801fae:	89 e5                	mov    %esp,%ebp
  801fb0:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fb3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fb6:	50                   	push   %eax
  801fb7:	ff 75 08             	pushl  0x8(%ebp)
  801fba:	e8 a0 f0 ff ff       	call   80105f <fd_lookup>
  801fbf:	83 c4 10             	add    $0x10,%esp
  801fc2:	85 c0                	test   %eax,%eax
  801fc4:	78 18                	js     801fde <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801fc6:	83 ec 0c             	sub    $0xc,%esp
  801fc9:	ff 75 f4             	pushl  -0xc(%ebp)
  801fcc:	e8 28 f0 ff ff       	call   800ff9 <fd2data>
	return _pipeisclosed(fd, p);
  801fd1:	89 c2                	mov    %eax,%edx
  801fd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fd6:	e8 21 fd ff ff       	call   801cfc <_pipeisclosed>
  801fdb:	83 c4 10             	add    $0x10,%esp
}
  801fde:	c9                   	leave  
  801fdf:	c3                   	ret    

00801fe0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801fe0:	55                   	push   %ebp
  801fe1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801fe3:	b8 00 00 00 00       	mov    $0x0,%eax
  801fe8:	5d                   	pop    %ebp
  801fe9:	c3                   	ret    

00801fea <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801fea:	55                   	push   %ebp
  801feb:	89 e5                	mov    %esp,%ebp
  801fed:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801ff0:	68 53 2b 80 00       	push   $0x802b53
  801ff5:	ff 75 0c             	pushl  0xc(%ebp)
  801ff8:	e8 30 e7 ff ff       	call   80072d <strcpy>
	return 0;
}
  801ffd:	b8 00 00 00 00       	mov    $0x0,%eax
  802002:	c9                   	leave  
  802003:	c3                   	ret    

00802004 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802004:	55                   	push   %ebp
  802005:	89 e5                	mov    %esp,%ebp
  802007:	57                   	push   %edi
  802008:	56                   	push   %esi
  802009:	53                   	push   %ebx
  80200a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802010:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802015:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80201b:	eb 2d                	jmp    80204a <devcons_write+0x46>
		m = n - tot;
  80201d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802020:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802022:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802025:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80202a:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80202d:	83 ec 04             	sub    $0x4,%esp
  802030:	53                   	push   %ebx
  802031:	03 45 0c             	add    0xc(%ebp),%eax
  802034:	50                   	push   %eax
  802035:	57                   	push   %edi
  802036:	e8 84 e8 ff ff       	call   8008bf <memmove>
		sys_cputs(buf, m);
  80203b:	83 c4 08             	add    $0x8,%esp
  80203e:	53                   	push   %ebx
  80203f:	57                   	push   %edi
  802040:	e8 2f ea ff ff       	call   800a74 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802045:	01 de                	add    %ebx,%esi
  802047:	83 c4 10             	add    $0x10,%esp
  80204a:	89 f0                	mov    %esi,%eax
  80204c:	3b 75 10             	cmp    0x10(%ebp),%esi
  80204f:	72 cc                	jb     80201d <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802051:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802054:	5b                   	pop    %ebx
  802055:	5e                   	pop    %esi
  802056:	5f                   	pop    %edi
  802057:	5d                   	pop    %ebp
  802058:	c3                   	ret    

00802059 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802059:	55                   	push   %ebp
  80205a:	89 e5                	mov    %esp,%ebp
  80205c:	83 ec 08             	sub    $0x8,%esp
  80205f:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802064:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802068:	74 2a                	je     802094 <devcons_read+0x3b>
  80206a:	eb 05                	jmp    802071 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80206c:	e8 a0 ea ff ff       	call   800b11 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802071:	e8 1c ea ff ff       	call   800a92 <sys_cgetc>
  802076:	85 c0                	test   %eax,%eax
  802078:	74 f2                	je     80206c <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80207a:	85 c0                	test   %eax,%eax
  80207c:	78 16                	js     802094 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80207e:	83 f8 04             	cmp    $0x4,%eax
  802081:	74 0c                	je     80208f <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802083:	8b 55 0c             	mov    0xc(%ebp),%edx
  802086:	88 02                	mov    %al,(%edx)
	return 1;
  802088:	b8 01 00 00 00       	mov    $0x1,%eax
  80208d:	eb 05                	jmp    802094 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80208f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802094:	c9                   	leave  
  802095:	c3                   	ret    

00802096 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802096:	55                   	push   %ebp
  802097:	89 e5                	mov    %esp,%ebp
  802099:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80209c:	8b 45 08             	mov    0x8(%ebp),%eax
  80209f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8020a2:	6a 01                	push   $0x1
  8020a4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020a7:	50                   	push   %eax
  8020a8:	e8 c7 e9 ff ff       	call   800a74 <sys_cputs>
}
  8020ad:	83 c4 10             	add    $0x10,%esp
  8020b0:	c9                   	leave  
  8020b1:	c3                   	ret    

008020b2 <getchar>:

int
getchar(void)
{
  8020b2:	55                   	push   %ebp
  8020b3:	89 e5                	mov    %esp,%ebp
  8020b5:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8020b8:	6a 01                	push   $0x1
  8020ba:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020bd:	50                   	push   %eax
  8020be:	6a 00                	push   $0x0
  8020c0:	e8 00 f2 ff ff       	call   8012c5 <read>
	if (r < 0)
  8020c5:	83 c4 10             	add    $0x10,%esp
  8020c8:	85 c0                	test   %eax,%eax
  8020ca:	78 0f                	js     8020db <getchar+0x29>
		return r;
	if (r < 1)
  8020cc:	85 c0                	test   %eax,%eax
  8020ce:	7e 06                	jle    8020d6 <getchar+0x24>
		return -E_EOF;
	return c;
  8020d0:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8020d4:	eb 05                	jmp    8020db <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8020d6:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8020db:	c9                   	leave  
  8020dc:	c3                   	ret    

008020dd <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8020dd:	55                   	push   %ebp
  8020de:	89 e5                	mov    %esp,%ebp
  8020e0:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020e6:	50                   	push   %eax
  8020e7:	ff 75 08             	pushl  0x8(%ebp)
  8020ea:	e8 70 ef ff ff       	call   80105f <fd_lookup>
  8020ef:	83 c4 10             	add    $0x10,%esp
  8020f2:	85 c0                	test   %eax,%eax
  8020f4:	78 11                	js     802107 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8020f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020f9:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8020ff:	39 10                	cmp    %edx,(%eax)
  802101:	0f 94 c0             	sete   %al
  802104:	0f b6 c0             	movzbl %al,%eax
}
  802107:	c9                   	leave  
  802108:	c3                   	ret    

00802109 <opencons>:

int
opencons(void)
{
  802109:	55                   	push   %ebp
  80210a:	89 e5                	mov    %esp,%ebp
  80210c:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80210f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802112:	50                   	push   %eax
  802113:	e8 f8 ee ff ff       	call   801010 <fd_alloc>
  802118:	83 c4 10             	add    $0x10,%esp
		return r;
  80211b:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80211d:	85 c0                	test   %eax,%eax
  80211f:	78 3e                	js     80215f <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802121:	83 ec 04             	sub    $0x4,%esp
  802124:	68 07 04 00 00       	push   $0x407
  802129:	ff 75 f4             	pushl  -0xc(%ebp)
  80212c:	6a 00                	push   $0x0
  80212e:	e8 fd e9 ff ff       	call   800b30 <sys_page_alloc>
  802133:	83 c4 10             	add    $0x10,%esp
		return r;
  802136:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802138:	85 c0                	test   %eax,%eax
  80213a:	78 23                	js     80215f <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80213c:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802142:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802145:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802147:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80214a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802151:	83 ec 0c             	sub    $0xc,%esp
  802154:	50                   	push   %eax
  802155:	e8 8f ee ff ff       	call   800fe9 <fd2num>
  80215a:	89 c2                	mov    %eax,%edx
  80215c:	83 c4 10             	add    $0x10,%esp
}
  80215f:	89 d0                	mov    %edx,%eax
  802161:	c9                   	leave  
  802162:	c3                   	ret    

00802163 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802163:	55                   	push   %ebp
  802164:	89 e5                	mov    %esp,%ebp
  802166:	56                   	push   %esi
  802167:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  802168:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80216b:	8b 35 00 30 80 00    	mov    0x803000,%esi
  802171:	e8 7c e9 ff ff       	call   800af2 <sys_getenvid>
  802176:	83 ec 0c             	sub    $0xc,%esp
  802179:	ff 75 0c             	pushl  0xc(%ebp)
  80217c:	ff 75 08             	pushl  0x8(%ebp)
  80217f:	56                   	push   %esi
  802180:	50                   	push   %eax
  802181:	68 60 2b 80 00       	push   $0x802b60
  802186:	e8 1d e0 ff ff       	call   8001a8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80218b:	83 c4 18             	add    $0x18,%esp
  80218e:	53                   	push   %ebx
  80218f:	ff 75 10             	pushl  0x10(%ebp)
  802192:	e8 c0 df ff ff       	call   800157 <vcprintf>
	cprintf("\n");
  802197:	c7 04 24 74 26 80 00 	movl   $0x802674,(%esp)
  80219e:	e8 05 e0 ff ff       	call   8001a8 <cprintf>
  8021a3:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8021a6:	cc                   	int3   
  8021a7:	eb fd                	jmp    8021a6 <_panic+0x43>

008021a9 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8021a9:	55                   	push   %ebp
  8021aa:	89 e5                	mov    %esp,%ebp
  8021ac:	53                   	push   %ebx
  8021ad:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  8021b0:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8021b7:	75 28                	jne    8021e1 <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  8021b9:	e8 34 e9 ff ff       	call   800af2 <sys_getenvid>
  8021be:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_U | PTE_W);
  8021c0:	83 ec 04             	sub    $0x4,%esp
  8021c3:	6a 06                	push   $0x6
  8021c5:	68 00 f0 bf ee       	push   $0xeebff000
  8021ca:	50                   	push   %eax
  8021cb:	e8 60 e9 ff ff       	call   800b30 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  8021d0:	83 c4 08             	add    $0x8,%esp
  8021d3:	68 ee 21 80 00       	push   $0x8021ee
  8021d8:	53                   	push   %ebx
  8021d9:	e8 9d ea ff ff       	call   800c7b <sys_env_set_pgfault_upcall>
  8021de:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8021e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8021e4:	a3 00 70 80 00       	mov    %eax,0x807000
}
  8021e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8021ec:	c9                   	leave  
  8021ed:	c3                   	ret    

008021ee <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8021ee:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8021ef:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8021f4:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8021f6:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	# My method is different. Copy the values to the other stack
	# in a convinient way, and then pop everything.
	movl %esp, %ebp		# ebp refers to the exception stack
  8021f9:	89 e5                	mov    %esp,%ebp
	movl 48(%ebp), %esp 	# go to other stack
  8021fb:	8b 65 30             	mov    0x30(%ebp),%esp

	pushl 40(%ebp)		# eip - ORDER SWITCHED WITH EFLAGS
  8021fe:	ff 75 28             	pushl  0x28(%ebp)
	pushl 44(%ebp)      	# eflags
  802201:	ff 75 2c             	pushl  0x2c(%ebp)
	pushl 36(%ebp)		# all the 8 remaining regs
  802204:	ff 75 24             	pushl  0x24(%ebp)
	pushl 32(%ebp)
  802207:	ff 75 20             	pushl  0x20(%ebp)
	pushl 28(%ebp)
  80220a:	ff 75 1c             	pushl  0x1c(%ebp)
	pushl 24(%ebp)
  80220d:	ff 75 18             	pushl  0x18(%ebp)
	pushl 20(%ebp)
  802210:	ff 75 14             	pushl  0x14(%ebp)
	pushl 16(%ebp)
  802213:	ff 75 10             	pushl  0x10(%ebp)
	pushl 12(%ebp)
  802216:	ff 75 0c             	pushl  0xc(%ebp)
	pushl 8(%ebp)
  802219:	ff 75 08             	pushl  0x8(%ebp)

	popal			# now just pop everything!
  80221c:	61                   	popa   
	popfl
  80221d:	9d                   	popf   
	ret
  80221e:	c3                   	ret    

0080221f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80221f:	55                   	push   %ebp
  802220:	89 e5                	mov    %esp,%ebp
  802222:	56                   	push   %esi
  802223:	53                   	push   %ebx
  802224:	8b 75 08             	mov    0x8(%ebp),%esi
  802227:	8b 45 0c             	mov    0xc(%ebp),%eax
  80222a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  80222d:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  80222f:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  802234:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  802237:	83 ec 0c             	sub    $0xc,%esp
  80223a:	50                   	push   %eax
  80223b:	e8 a0 ea ff ff       	call   800ce0 <sys_ipc_recv>

	if (r < 0) {
  802240:	83 c4 10             	add    $0x10,%esp
  802243:	85 c0                	test   %eax,%eax
  802245:	79 16                	jns    80225d <ipc_recv+0x3e>
		if (from_env_store)
  802247:	85 f6                	test   %esi,%esi
  802249:	74 06                	je     802251 <ipc_recv+0x32>
			*from_env_store = 0;
  80224b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  802251:	85 db                	test   %ebx,%ebx
  802253:	74 2c                	je     802281 <ipc_recv+0x62>
			*perm_store = 0;
  802255:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80225b:	eb 24                	jmp    802281 <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  80225d:	85 f6                	test   %esi,%esi
  80225f:	74 0a                	je     80226b <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  802261:	a1 08 40 80 00       	mov    0x804008,%eax
  802266:	8b 40 74             	mov    0x74(%eax),%eax
  802269:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  80226b:	85 db                	test   %ebx,%ebx
  80226d:	74 0a                	je     802279 <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  80226f:	a1 08 40 80 00       	mov    0x804008,%eax
  802274:	8b 40 78             	mov    0x78(%eax),%eax
  802277:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  802279:	a1 08 40 80 00       	mov    0x804008,%eax
  80227e:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  802281:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802284:	5b                   	pop    %ebx
  802285:	5e                   	pop    %esi
  802286:	5d                   	pop    %ebp
  802287:	c3                   	ret    

00802288 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802288:	55                   	push   %ebp
  802289:	89 e5                	mov    %esp,%ebp
  80228b:	57                   	push   %edi
  80228c:	56                   	push   %esi
  80228d:	53                   	push   %ebx
  80228e:	83 ec 0c             	sub    $0xc,%esp
  802291:	8b 7d 08             	mov    0x8(%ebp),%edi
  802294:	8b 75 0c             	mov    0xc(%ebp),%esi
  802297:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  80229a:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  80229c:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  8022a1:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  8022a4:	ff 75 14             	pushl  0x14(%ebp)
  8022a7:	53                   	push   %ebx
  8022a8:	56                   	push   %esi
  8022a9:	57                   	push   %edi
  8022aa:	e8 0e ea ff ff       	call   800cbd <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  8022af:	83 c4 10             	add    $0x10,%esp
  8022b2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8022b5:	75 07                	jne    8022be <ipc_send+0x36>
			sys_yield();
  8022b7:	e8 55 e8 ff ff       	call   800b11 <sys_yield>
  8022bc:	eb e6                	jmp    8022a4 <ipc_send+0x1c>
		} else if (r < 0) {
  8022be:	85 c0                	test   %eax,%eax
  8022c0:	79 12                	jns    8022d4 <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  8022c2:	50                   	push   %eax
  8022c3:	68 84 2b 80 00       	push   $0x802b84
  8022c8:	6a 51                	push   $0x51
  8022ca:	68 91 2b 80 00       	push   $0x802b91
  8022cf:	e8 8f fe ff ff       	call   802163 <_panic>
		}
	}
}
  8022d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022d7:	5b                   	pop    %ebx
  8022d8:	5e                   	pop    %esi
  8022d9:	5f                   	pop    %edi
  8022da:	5d                   	pop    %ebp
  8022db:	c3                   	ret    

008022dc <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8022dc:	55                   	push   %ebp
  8022dd:	89 e5                	mov    %esp,%ebp
  8022df:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8022e2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8022e7:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8022ea:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8022f0:	8b 52 50             	mov    0x50(%edx),%edx
  8022f3:	39 ca                	cmp    %ecx,%edx
  8022f5:	75 0d                	jne    802304 <ipc_find_env+0x28>
			return envs[i].env_id;
  8022f7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8022fa:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8022ff:	8b 40 48             	mov    0x48(%eax),%eax
  802302:	eb 0f                	jmp    802313 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802304:	83 c0 01             	add    $0x1,%eax
  802307:	3d 00 04 00 00       	cmp    $0x400,%eax
  80230c:	75 d9                	jne    8022e7 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80230e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802313:	5d                   	pop    %ebp
  802314:	c3                   	ret    

00802315 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802315:	55                   	push   %ebp
  802316:	89 e5                	mov    %esp,%ebp
  802318:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80231b:	89 d0                	mov    %edx,%eax
  80231d:	c1 e8 16             	shr    $0x16,%eax
  802320:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802327:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80232c:	f6 c1 01             	test   $0x1,%cl
  80232f:	74 1d                	je     80234e <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802331:	c1 ea 0c             	shr    $0xc,%edx
  802334:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80233b:	f6 c2 01             	test   $0x1,%dl
  80233e:	74 0e                	je     80234e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802340:	c1 ea 0c             	shr    $0xc,%edx
  802343:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80234a:	ef 
  80234b:	0f b7 c0             	movzwl %ax,%eax
}
  80234e:	5d                   	pop    %ebp
  80234f:	c3                   	ret    

00802350 <__udivdi3>:
  802350:	55                   	push   %ebp
  802351:	57                   	push   %edi
  802352:	56                   	push   %esi
  802353:	53                   	push   %ebx
  802354:	83 ec 1c             	sub    $0x1c,%esp
  802357:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80235b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80235f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802363:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802367:	85 f6                	test   %esi,%esi
  802369:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80236d:	89 ca                	mov    %ecx,%edx
  80236f:	89 f8                	mov    %edi,%eax
  802371:	75 3d                	jne    8023b0 <__udivdi3+0x60>
  802373:	39 cf                	cmp    %ecx,%edi
  802375:	0f 87 c5 00 00 00    	ja     802440 <__udivdi3+0xf0>
  80237b:	85 ff                	test   %edi,%edi
  80237d:	89 fd                	mov    %edi,%ebp
  80237f:	75 0b                	jne    80238c <__udivdi3+0x3c>
  802381:	b8 01 00 00 00       	mov    $0x1,%eax
  802386:	31 d2                	xor    %edx,%edx
  802388:	f7 f7                	div    %edi
  80238a:	89 c5                	mov    %eax,%ebp
  80238c:	89 c8                	mov    %ecx,%eax
  80238e:	31 d2                	xor    %edx,%edx
  802390:	f7 f5                	div    %ebp
  802392:	89 c1                	mov    %eax,%ecx
  802394:	89 d8                	mov    %ebx,%eax
  802396:	89 cf                	mov    %ecx,%edi
  802398:	f7 f5                	div    %ebp
  80239a:	89 c3                	mov    %eax,%ebx
  80239c:	89 d8                	mov    %ebx,%eax
  80239e:	89 fa                	mov    %edi,%edx
  8023a0:	83 c4 1c             	add    $0x1c,%esp
  8023a3:	5b                   	pop    %ebx
  8023a4:	5e                   	pop    %esi
  8023a5:	5f                   	pop    %edi
  8023a6:	5d                   	pop    %ebp
  8023a7:	c3                   	ret    
  8023a8:	90                   	nop
  8023a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023b0:	39 ce                	cmp    %ecx,%esi
  8023b2:	77 74                	ja     802428 <__udivdi3+0xd8>
  8023b4:	0f bd fe             	bsr    %esi,%edi
  8023b7:	83 f7 1f             	xor    $0x1f,%edi
  8023ba:	0f 84 98 00 00 00    	je     802458 <__udivdi3+0x108>
  8023c0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8023c5:	89 f9                	mov    %edi,%ecx
  8023c7:	89 c5                	mov    %eax,%ebp
  8023c9:	29 fb                	sub    %edi,%ebx
  8023cb:	d3 e6                	shl    %cl,%esi
  8023cd:	89 d9                	mov    %ebx,%ecx
  8023cf:	d3 ed                	shr    %cl,%ebp
  8023d1:	89 f9                	mov    %edi,%ecx
  8023d3:	d3 e0                	shl    %cl,%eax
  8023d5:	09 ee                	or     %ebp,%esi
  8023d7:	89 d9                	mov    %ebx,%ecx
  8023d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023dd:	89 d5                	mov    %edx,%ebp
  8023df:	8b 44 24 08          	mov    0x8(%esp),%eax
  8023e3:	d3 ed                	shr    %cl,%ebp
  8023e5:	89 f9                	mov    %edi,%ecx
  8023e7:	d3 e2                	shl    %cl,%edx
  8023e9:	89 d9                	mov    %ebx,%ecx
  8023eb:	d3 e8                	shr    %cl,%eax
  8023ed:	09 c2                	or     %eax,%edx
  8023ef:	89 d0                	mov    %edx,%eax
  8023f1:	89 ea                	mov    %ebp,%edx
  8023f3:	f7 f6                	div    %esi
  8023f5:	89 d5                	mov    %edx,%ebp
  8023f7:	89 c3                	mov    %eax,%ebx
  8023f9:	f7 64 24 0c          	mull   0xc(%esp)
  8023fd:	39 d5                	cmp    %edx,%ebp
  8023ff:	72 10                	jb     802411 <__udivdi3+0xc1>
  802401:	8b 74 24 08          	mov    0x8(%esp),%esi
  802405:	89 f9                	mov    %edi,%ecx
  802407:	d3 e6                	shl    %cl,%esi
  802409:	39 c6                	cmp    %eax,%esi
  80240b:	73 07                	jae    802414 <__udivdi3+0xc4>
  80240d:	39 d5                	cmp    %edx,%ebp
  80240f:	75 03                	jne    802414 <__udivdi3+0xc4>
  802411:	83 eb 01             	sub    $0x1,%ebx
  802414:	31 ff                	xor    %edi,%edi
  802416:	89 d8                	mov    %ebx,%eax
  802418:	89 fa                	mov    %edi,%edx
  80241a:	83 c4 1c             	add    $0x1c,%esp
  80241d:	5b                   	pop    %ebx
  80241e:	5e                   	pop    %esi
  80241f:	5f                   	pop    %edi
  802420:	5d                   	pop    %ebp
  802421:	c3                   	ret    
  802422:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802428:	31 ff                	xor    %edi,%edi
  80242a:	31 db                	xor    %ebx,%ebx
  80242c:	89 d8                	mov    %ebx,%eax
  80242e:	89 fa                	mov    %edi,%edx
  802430:	83 c4 1c             	add    $0x1c,%esp
  802433:	5b                   	pop    %ebx
  802434:	5e                   	pop    %esi
  802435:	5f                   	pop    %edi
  802436:	5d                   	pop    %ebp
  802437:	c3                   	ret    
  802438:	90                   	nop
  802439:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802440:	89 d8                	mov    %ebx,%eax
  802442:	f7 f7                	div    %edi
  802444:	31 ff                	xor    %edi,%edi
  802446:	89 c3                	mov    %eax,%ebx
  802448:	89 d8                	mov    %ebx,%eax
  80244a:	89 fa                	mov    %edi,%edx
  80244c:	83 c4 1c             	add    $0x1c,%esp
  80244f:	5b                   	pop    %ebx
  802450:	5e                   	pop    %esi
  802451:	5f                   	pop    %edi
  802452:	5d                   	pop    %ebp
  802453:	c3                   	ret    
  802454:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802458:	39 ce                	cmp    %ecx,%esi
  80245a:	72 0c                	jb     802468 <__udivdi3+0x118>
  80245c:	31 db                	xor    %ebx,%ebx
  80245e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802462:	0f 87 34 ff ff ff    	ja     80239c <__udivdi3+0x4c>
  802468:	bb 01 00 00 00       	mov    $0x1,%ebx
  80246d:	e9 2a ff ff ff       	jmp    80239c <__udivdi3+0x4c>
  802472:	66 90                	xchg   %ax,%ax
  802474:	66 90                	xchg   %ax,%ax
  802476:	66 90                	xchg   %ax,%ax
  802478:	66 90                	xchg   %ax,%ax
  80247a:	66 90                	xchg   %ax,%ax
  80247c:	66 90                	xchg   %ax,%ax
  80247e:	66 90                	xchg   %ax,%ax

00802480 <__umoddi3>:
  802480:	55                   	push   %ebp
  802481:	57                   	push   %edi
  802482:	56                   	push   %esi
  802483:	53                   	push   %ebx
  802484:	83 ec 1c             	sub    $0x1c,%esp
  802487:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80248b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80248f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802493:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802497:	85 d2                	test   %edx,%edx
  802499:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80249d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024a1:	89 f3                	mov    %esi,%ebx
  8024a3:	89 3c 24             	mov    %edi,(%esp)
  8024a6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024aa:	75 1c                	jne    8024c8 <__umoddi3+0x48>
  8024ac:	39 f7                	cmp    %esi,%edi
  8024ae:	76 50                	jbe    802500 <__umoddi3+0x80>
  8024b0:	89 c8                	mov    %ecx,%eax
  8024b2:	89 f2                	mov    %esi,%edx
  8024b4:	f7 f7                	div    %edi
  8024b6:	89 d0                	mov    %edx,%eax
  8024b8:	31 d2                	xor    %edx,%edx
  8024ba:	83 c4 1c             	add    $0x1c,%esp
  8024bd:	5b                   	pop    %ebx
  8024be:	5e                   	pop    %esi
  8024bf:	5f                   	pop    %edi
  8024c0:	5d                   	pop    %ebp
  8024c1:	c3                   	ret    
  8024c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8024c8:	39 f2                	cmp    %esi,%edx
  8024ca:	89 d0                	mov    %edx,%eax
  8024cc:	77 52                	ja     802520 <__umoddi3+0xa0>
  8024ce:	0f bd ea             	bsr    %edx,%ebp
  8024d1:	83 f5 1f             	xor    $0x1f,%ebp
  8024d4:	75 5a                	jne    802530 <__umoddi3+0xb0>
  8024d6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8024da:	0f 82 e0 00 00 00    	jb     8025c0 <__umoddi3+0x140>
  8024e0:	39 0c 24             	cmp    %ecx,(%esp)
  8024e3:	0f 86 d7 00 00 00    	jbe    8025c0 <__umoddi3+0x140>
  8024e9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8024ed:	8b 54 24 04          	mov    0x4(%esp),%edx
  8024f1:	83 c4 1c             	add    $0x1c,%esp
  8024f4:	5b                   	pop    %ebx
  8024f5:	5e                   	pop    %esi
  8024f6:	5f                   	pop    %edi
  8024f7:	5d                   	pop    %ebp
  8024f8:	c3                   	ret    
  8024f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802500:	85 ff                	test   %edi,%edi
  802502:	89 fd                	mov    %edi,%ebp
  802504:	75 0b                	jne    802511 <__umoddi3+0x91>
  802506:	b8 01 00 00 00       	mov    $0x1,%eax
  80250b:	31 d2                	xor    %edx,%edx
  80250d:	f7 f7                	div    %edi
  80250f:	89 c5                	mov    %eax,%ebp
  802511:	89 f0                	mov    %esi,%eax
  802513:	31 d2                	xor    %edx,%edx
  802515:	f7 f5                	div    %ebp
  802517:	89 c8                	mov    %ecx,%eax
  802519:	f7 f5                	div    %ebp
  80251b:	89 d0                	mov    %edx,%eax
  80251d:	eb 99                	jmp    8024b8 <__umoddi3+0x38>
  80251f:	90                   	nop
  802520:	89 c8                	mov    %ecx,%eax
  802522:	89 f2                	mov    %esi,%edx
  802524:	83 c4 1c             	add    $0x1c,%esp
  802527:	5b                   	pop    %ebx
  802528:	5e                   	pop    %esi
  802529:	5f                   	pop    %edi
  80252a:	5d                   	pop    %ebp
  80252b:	c3                   	ret    
  80252c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802530:	8b 34 24             	mov    (%esp),%esi
  802533:	bf 20 00 00 00       	mov    $0x20,%edi
  802538:	89 e9                	mov    %ebp,%ecx
  80253a:	29 ef                	sub    %ebp,%edi
  80253c:	d3 e0                	shl    %cl,%eax
  80253e:	89 f9                	mov    %edi,%ecx
  802540:	89 f2                	mov    %esi,%edx
  802542:	d3 ea                	shr    %cl,%edx
  802544:	89 e9                	mov    %ebp,%ecx
  802546:	09 c2                	or     %eax,%edx
  802548:	89 d8                	mov    %ebx,%eax
  80254a:	89 14 24             	mov    %edx,(%esp)
  80254d:	89 f2                	mov    %esi,%edx
  80254f:	d3 e2                	shl    %cl,%edx
  802551:	89 f9                	mov    %edi,%ecx
  802553:	89 54 24 04          	mov    %edx,0x4(%esp)
  802557:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80255b:	d3 e8                	shr    %cl,%eax
  80255d:	89 e9                	mov    %ebp,%ecx
  80255f:	89 c6                	mov    %eax,%esi
  802561:	d3 e3                	shl    %cl,%ebx
  802563:	89 f9                	mov    %edi,%ecx
  802565:	89 d0                	mov    %edx,%eax
  802567:	d3 e8                	shr    %cl,%eax
  802569:	89 e9                	mov    %ebp,%ecx
  80256b:	09 d8                	or     %ebx,%eax
  80256d:	89 d3                	mov    %edx,%ebx
  80256f:	89 f2                	mov    %esi,%edx
  802571:	f7 34 24             	divl   (%esp)
  802574:	89 d6                	mov    %edx,%esi
  802576:	d3 e3                	shl    %cl,%ebx
  802578:	f7 64 24 04          	mull   0x4(%esp)
  80257c:	39 d6                	cmp    %edx,%esi
  80257e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802582:	89 d1                	mov    %edx,%ecx
  802584:	89 c3                	mov    %eax,%ebx
  802586:	72 08                	jb     802590 <__umoddi3+0x110>
  802588:	75 11                	jne    80259b <__umoddi3+0x11b>
  80258a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80258e:	73 0b                	jae    80259b <__umoddi3+0x11b>
  802590:	2b 44 24 04          	sub    0x4(%esp),%eax
  802594:	1b 14 24             	sbb    (%esp),%edx
  802597:	89 d1                	mov    %edx,%ecx
  802599:	89 c3                	mov    %eax,%ebx
  80259b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80259f:	29 da                	sub    %ebx,%edx
  8025a1:	19 ce                	sbb    %ecx,%esi
  8025a3:	89 f9                	mov    %edi,%ecx
  8025a5:	89 f0                	mov    %esi,%eax
  8025a7:	d3 e0                	shl    %cl,%eax
  8025a9:	89 e9                	mov    %ebp,%ecx
  8025ab:	d3 ea                	shr    %cl,%edx
  8025ad:	89 e9                	mov    %ebp,%ecx
  8025af:	d3 ee                	shr    %cl,%esi
  8025b1:	09 d0                	or     %edx,%eax
  8025b3:	89 f2                	mov    %esi,%edx
  8025b5:	83 c4 1c             	add    $0x1c,%esp
  8025b8:	5b                   	pop    %ebx
  8025b9:	5e                   	pop    %esi
  8025ba:	5f                   	pop    %edi
  8025bb:	5d                   	pop    %ebp
  8025bc:	c3                   	ret    
  8025bd:	8d 76 00             	lea    0x0(%esi),%esi
  8025c0:	29 f9                	sub    %edi,%ecx
  8025c2:	19 d6                	sbb    %edx,%esi
  8025c4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8025c8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8025cc:	e9 18 ff ff ff       	jmp    8024e9 <__umoddi3+0x69>
