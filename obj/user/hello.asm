
obj/user/hello.debug:     file format elf32-i386


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
  80002c:	e8 2d 00 00 00       	call   80005e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	cprintf("hello, world\n");
  800039:	68 00 1e 80 00       	push   $0x801e00
  80003e:	e8 0e 01 00 00       	call   800151 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800043:	a1 04 40 80 00       	mov    0x804004,%eax
  800048:	8b 40 48             	mov    0x48(%eax),%eax
  80004b:	83 c4 08             	add    $0x8,%esp
  80004e:	50                   	push   %eax
  80004f:	68 0e 1e 80 00       	push   $0x801e0e
  800054:	e8 f8 00 00 00       	call   800151 <cprintf>
}
  800059:	83 c4 10             	add    $0x10,%esp
  80005c:	c9                   	leave  
  80005d:	c3                   	ret    

0080005e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80005e:	55                   	push   %ebp
  80005f:	89 e5                	mov    %esp,%ebp
  800061:	56                   	push   %esi
  800062:	53                   	push   %ebx
  800063:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800066:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800069:	e8 2d 0a 00 00       	call   800a9b <sys_getenvid>
  80006e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800073:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800076:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007b:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800080:	85 db                	test   %ebx,%ebx
  800082:	7e 07                	jle    80008b <libmain+0x2d>
		binaryname = argv[0];
  800084:	8b 06                	mov    (%esi),%eax
  800086:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80008b:	83 ec 08             	sub    $0x8,%esp
  80008e:	56                   	push   %esi
  80008f:	53                   	push   %ebx
  800090:	e8 9e ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800095:	e8 0a 00 00 00       	call   8000a4 <exit>
}
  80009a:	83 c4 10             	add    $0x10,%esp
  80009d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a0:	5b                   	pop    %ebx
  8000a1:	5e                   	pop    %esi
  8000a2:	5d                   	pop    %ebp
  8000a3:	c3                   	ret    

008000a4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000aa:	e8 e6 0d 00 00       	call   800e95 <close_all>
	sys_env_destroy(0);
  8000af:	83 ec 0c             	sub    $0xc,%esp
  8000b2:	6a 00                	push   $0x0
  8000b4:	e8 a1 09 00 00       	call   800a5a <sys_env_destroy>
}
  8000b9:	83 c4 10             	add    $0x10,%esp
  8000bc:	c9                   	leave  
  8000bd:	c3                   	ret    

008000be <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000be:	55                   	push   %ebp
  8000bf:	89 e5                	mov    %esp,%ebp
  8000c1:	53                   	push   %ebx
  8000c2:	83 ec 04             	sub    $0x4,%esp
  8000c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000c8:	8b 13                	mov    (%ebx),%edx
  8000ca:	8d 42 01             	lea    0x1(%edx),%eax
  8000cd:	89 03                	mov    %eax,(%ebx)
  8000cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000d2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000d6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000db:	75 1a                	jne    8000f7 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000dd:	83 ec 08             	sub    $0x8,%esp
  8000e0:	68 ff 00 00 00       	push   $0xff
  8000e5:	8d 43 08             	lea    0x8(%ebx),%eax
  8000e8:	50                   	push   %eax
  8000e9:	e8 2f 09 00 00       	call   800a1d <sys_cputs>
		b->idx = 0;
  8000ee:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000f4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000f7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000fe:	c9                   	leave  
  8000ff:	c3                   	ret    

00800100 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800100:	55                   	push   %ebp
  800101:	89 e5                	mov    %esp,%ebp
  800103:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800109:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800110:	00 00 00 
	b.cnt = 0;
  800113:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80011a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80011d:	ff 75 0c             	pushl  0xc(%ebp)
  800120:	ff 75 08             	pushl  0x8(%ebp)
  800123:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800129:	50                   	push   %eax
  80012a:	68 be 00 80 00       	push   $0x8000be
  80012f:	e8 54 01 00 00       	call   800288 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800134:	83 c4 08             	add    $0x8,%esp
  800137:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80013d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800143:	50                   	push   %eax
  800144:	e8 d4 08 00 00       	call   800a1d <sys_cputs>

	return b.cnt;
}
  800149:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80014f:	c9                   	leave  
  800150:	c3                   	ret    

00800151 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800151:	55                   	push   %ebp
  800152:	89 e5                	mov    %esp,%ebp
  800154:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800157:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80015a:	50                   	push   %eax
  80015b:	ff 75 08             	pushl  0x8(%ebp)
  80015e:	e8 9d ff ff ff       	call   800100 <vcprintf>
	va_end(ap);

	return cnt;
}
  800163:	c9                   	leave  
  800164:	c3                   	ret    

00800165 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800165:	55                   	push   %ebp
  800166:	89 e5                	mov    %esp,%ebp
  800168:	57                   	push   %edi
  800169:	56                   	push   %esi
  80016a:	53                   	push   %ebx
  80016b:	83 ec 1c             	sub    $0x1c,%esp
  80016e:	89 c7                	mov    %eax,%edi
  800170:	89 d6                	mov    %edx,%esi
  800172:	8b 45 08             	mov    0x8(%ebp),%eax
  800175:	8b 55 0c             	mov    0xc(%ebp),%edx
  800178:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80017b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80017e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800181:	bb 00 00 00 00       	mov    $0x0,%ebx
  800186:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800189:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80018c:	39 d3                	cmp    %edx,%ebx
  80018e:	72 05                	jb     800195 <printnum+0x30>
  800190:	39 45 10             	cmp    %eax,0x10(%ebp)
  800193:	77 45                	ja     8001da <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800195:	83 ec 0c             	sub    $0xc,%esp
  800198:	ff 75 18             	pushl  0x18(%ebp)
  80019b:	8b 45 14             	mov    0x14(%ebp),%eax
  80019e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001a1:	53                   	push   %ebx
  8001a2:	ff 75 10             	pushl  0x10(%ebp)
  8001a5:	83 ec 08             	sub    $0x8,%esp
  8001a8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ab:	ff 75 e0             	pushl  -0x20(%ebp)
  8001ae:	ff 75 dc             	pushl  -0x24(%ebp)
  8001b1:	ff 75 d8             	pushl  -0x28(%ebp)
  8001b4:	e8 a7 19 00 00       	call   801b60 <__udivdi3>
  8001b9:	83 c4 18             	add    $0x18,%esp
  8001bc:	52                   	push   %edx
  8001bd:	50                   	push   %eax
  8001be:	89 f2                	mov    %esi,%edx
  8001c0:	89 f8                	mov    %edi,%eax
  8001c2:	e8 9e ff ff ff       	call   800165 <printnum>
  8001c7:	83 c4 20             	add    $0x20,%esp
  8001ca:	eb 18                	jmp    8001e4 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001cc:	83 ec 08             	sub    $0x8,%esp
  8001cf:	56                   	push   %esi
  8001d0:	ff 75 18             	pushl  0x18(%ebp)
  8001d3:	ff d7                	call   *%edi
  8001d5:	83 c4 10             	add    $0x10,%esp
  8001d8:	eb 03                	jmp    8001dd <printnum+0x78>
  8001da:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001dd:	83 eb 01             	sub    $0x1,%ebx
  8001e0:	85 db                	test   %ebx,%ebx
  8001e2:	7f e8                	jg     8001cc <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001e4:	83 ec 08             	sub    $0x8,%esp
  8001e7:	56                   	push   %esi
  8001e8:	83 ec 04             	sub    $0x4,%esp
  8001eb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ee:	ff 75 e0             	pushl  -0x20(%ebp)
  8001f1:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f4:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f7:	e8 94 1a 00 00       	call   801c90 <__umoddi3>
  8001fc:	83 c4 14             	add    $0x14,%esp
  8001ff:	0f be 80 2f 1e 80 00 	movsbl 0x801e2f(%eax),%eax
  800206:	50                   	push   %eax
  800207:	ff d7                	call   *%edi
}
  800209:	83 c4 10             	add    $0x10,%esp
  80020c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80020f:	5b                   	pop    %ebx
  800210:	5e                   	pop    %esi
  800211:	5f                   	pop    %edi
  800212:	5d                   	pop    %ebp
  800213:	c3                   	ret    

00800214 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800217:	83 fa 01             	cmp    $0x1,%edx
  80021a:	7e 0e                	jle    80022a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80021c:	8b 10                	mov    (%eax),%edx
  80021e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800221:	89 08                	mov    %ecx,(%eax)
  800223:	8b 02                	mov    (%edx),%eax
  800225:	8b 52 04             	mov    0x4(%edx),%edx
  800228:	eb 22                	jmp    80024c <getuint+0x38>
	else if (lflag)
  80022a:	85 d2                	test   %edx,%edx
  80022c:	74 10                	je     80023e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80022e:	8b 10                	mov    (%eax),%edx
  800230:	8d 4a 04             	lea    0x4(%edx),%ecx
  800233:	89 08                	mov    %ecx,(%eax)
  800235:	8b 02                	mov    (%edx),%eax
  800237:	ba 00 00 00 00       	mov    $0x0,%edx
  80023c:	eb 0e                	jmp    80024c <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80023e:	8b 10                	mov    (%eax),%edx
  800240:	8d 4a 04             	lea    0x4(%edx),%ecx
  800243:	89 08                	mov    %ecx,(%eax)
  800245:	8b 02                	mov    (%edx),%eax
  800247:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80024c:	5d                   	pop    %ebp
  80024d:	c3                   	ret    

0080024e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80024e:	55                   	push   %ebp
  80024f:	89 e5                	mov    %esp,%ebp
  800251:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800254:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800258:	8b 10                	mov    (%eax),%edx
  80025a:	3b 50 04             	cmp    0x4(%eax),%edx
  80025d:	73 0a                	jae    800269 <sprintputch+0x1b>
		*b->buf++ = ch;
  80025f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800262:	89 08                	mov    %ecx,(%eax)
  800264:	8b 45 08             	mov    0x8(%ebp),%eax
  800267:	88 02                	mov    %al,(%edx)
}
  800269:	5d                   	pop    %ebp
  80026a:	c3                   	ret    

0080026b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80026b:	55                   	push   %ebp
  80026c:	89 e5                	mov    %esp,%ebp
  80026e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800271:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800274:	50                   	push   %eax
  800275:	ff 75 10             	pushl  0x10(%ebp)
  800278:	ff 75 0c             	pushl  0xc(%ebp)
  80027b:	ff 75 08             	pushl  0x8(%ebp)
  80027e:	e8 05 00 00 00       	call   800288 <vprintfmt>
	va_end(ap);
}
  800283:	83 c4 10             	add    $0x10,%esp
  800286:	c9                   	leave  
  800287:	c3                   	ret    

00800288 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800288:	55                   	push   %ebp
  800289:	89 e5                	mov    %esp,%ebp
  80028b:	57                   	push   %edi
  80028c:	56                   	push   %esi
  80028d:	53                   	push   %ebx
  80028e:	83 ec 2c             	sub    $0x2c,%esp
  800291:	8b 75 08             	mov    0x8(%ebp),%esi
  800294:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800297:	8b 7d 10             	mov    0x10(%ebp),%edi
  80029a:	eb 12                	jmp    8002ae <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80029c:	85 c0                	test   %eax,%eax
  80029e:	0f 84 89 03 00 00    	je     80062d <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8002a4:	83 ec 08             	sub    $0x8,%esp
  8002a7:	53                   	push   %ebx
  8002a8:	50                   	push   %eax
  8002a9:	ff d6                	call   *%esi
  8002ab:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002ae:	83 c7 01             	add    $0x1,%edi
  8002b1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002b5:	83 f8 25             	cmp    $0x25,%eax
  8002b8:	75 e2                	jne    80029c <vprintfmt+0x14>
  8002ba:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002be:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002c5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002cc:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d8:	eb 07                	jmp    8002e1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002da:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002dd:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002e1:	8d 47 01             	lea    0x1(%edi),%eax
  8002e4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002e7:	0f b6 07             	movzbl (%edi),%eax
  8002ea:	0f b6 c8             	movzbl %al,%ecx
  8002ed:	83 e8 23             	sub    $0x23,%eax
  8002f0:	3c 55                	cmp    $0x55,%al
  8002f2:	0f 87 1a 03 00 00    	ja     800612 <vprintfmt+0x38a>
  8002f8:	0f b6 c0             	movzbl %al,%eax
  8002fb:	ff 24 85 80 1f 80 00 	jmp    *0x801f80(,%eax,4)
  800302:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800305:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800309:	eb d6                	jmp    8002e1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80030b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80030e:	b8 00 00 00 00       	mov    $0x0,%eax
  800313:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800316:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800319:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80031d:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800320:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800323:	83 fa 09             	cmp    $0x9,%edx
  800326:	77 39                	ja     800361 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800328:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80032b:	eb e9                	jmp    800316 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80032d:	8b 45 14             	mov    0x14(%ebp),%eax
  800330:	8d 48 04             	lea    0x4(%eax),%ecx
  800333:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800336:	8b 00                	mov    (%eax),%eax
  800338:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80033e:	eb 27                	jmp    800367 <vprintfmt+0xdf>
  800340:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800343:	85 c0                	test   %eax,%eax
  800345:	b9 00 00 00 00       	mov    $0x0,%ecx
  80034a:	0f 49 c8             	cmovns %eax,%ecx
  80034d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800350:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800353:	eb 8c                	jmp    8002e1 <vprintfmt+0x59>
  800355:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800358:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80035f:	eb 80                	jmp    8002e1 <vprintfmt+0x59>
  800361:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800364:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800367:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80036b:	0f 89 70 ff ff ff    	jns    8002e1 <vprintfmt+0x59>
				width = precision, precision = -1;
  800371:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800374:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800377:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80037e:	e9 5e ff ff ff       	jmp    8002e1 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800383:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800386:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800389:	e9 53 ff ff ff       	jmp    8002e1 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80038e:	8b 45 14             	mov    0x14(%ebp),%eax
  800391:	8d 50 04             	lea    0x4(%eax),%edx
  800394:	89 55 14             	mov    %edx,0x14(%ebp)
  800397:	83 ec 08             	sub    $0x8,%esp
  80039a:	53                   	push   %ebx
  80039b:	ff 30                	pushl  (%eax)
  80039d:	ff d6                	call   *%esi
			break;
  80039f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003a5:	e9 04 ff ff ff       	jmp    8002ae <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ad:	8d 50 04             	lea    0x4(%eax),%edx
  8003b0:	89 55 14             	mov    %edx,0x14(%ebp)
  8003b3:	8b 00                	mov    (%eax),%eax
  8003b5:	99                   	cltd   
  8003b6:	31 d0                	xor    %edx,%eax
  8003b8:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003ba:	83 f8 0f             	cmp    $0xf,%eax
  8003bd:	7f 0b                	jg     8003ca <vprintfmt+0x142>
  8003bf:	8b 14 85 e0 20 80 00 	mov    0x8020e0(,%eax,4),%edx
  8003c6:	85 d2                	test   %edx,%edx
  8003c8:	75 18                	jne    8003e2 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003ca:	50                   	push   %eax
  8003cb:	68 47 1e 80 00       	push   $0x801e47
  8003d0:	53                   	push   %ebx
  8003d1:	56                   	push   %esi
  8003d2:	e8 94 fe ff ff       	call   80026b <printfmt>
  8003d7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003dd:	e9 cc fe ff ff       	jmp    8002ae <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003e2:	52                   	push   %edx
  8003e3:	68 16 22 80 00       	push   $0x802216
  8003e8:	53                   	push   %ebx
  8003e9:	56                   	push   %esi
  8003ea:	e8 7c fe ff ff       	call   80026b <printfmt>
  8003ef:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003f5:	e9 b4 fe ff ff       	jmp    8002ae <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fd:	8d 50 04             	lea    0x4(%eax),%edx
  800400:	89 55 14             	mov    %edx,0x14(%ebp)
  800403:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800405:	85 ff                	test   %edi,%edi
  800407:	b8 40 1e 80 00       	mov    $0x801e40,%eax
  80040c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80040f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800413:	0f 8e 94 00 00 00    	jle    8004ad <vprintfmt+0x225>
  800419:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80041d:	0f 84 98 00 00 00    	je     8004bb <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800423:	83 ec 08             	sub    $0x8,%esp
  800426:	ff 75 d0             	pushl  -0x30(%ebp)
  800429:	57                   	push   %edi
  80042a:	e8 86 02 00 00       	call   8006b5 <strnlen>
  80042f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800432:	29 c1                	sub    %eax,%ecx
  800434:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800437:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80043a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80043e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800441:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800444:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800446:	eb 0f                	jmp    800457 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800448:	83 ec 08             	sub    $0x8,%esp
  80044b:	53                   	push   %ebx
  80044c:	ff 75 e0             	pushl  -0x20(%ebp)
  80044f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800451:	83 ef 01             	sub    $0x1,%edi
  800454:	83 c4 10             	add    $0x10,%esp
  800457:	85 ff                	test   %edi,%edi
  800459:	7f ed                	jg     800448 <vprintfmt+0x1c0>
  80045b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80045e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800461:	85 c9                	test   %ecx,%ecx
  800463:	b8 00 00 00 00       	mov    $0x0,%eax
  800468:	0f 49 c1             	cmovns %ecx,%eax
  80046b:	29 c1                	sub    %eax,%ecx
  80046d:	89 75 08             	mov    %esi,0x8(%ebp)
  800470:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800473:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800476:	89 cb                	mov    %ecx,%ebx
  800478:	eb 4d                	jmp    8004c7 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80047a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80047e:	74 1b                	je     80049b <vprintfmt+0x213>
  800480:	0f be c0             	movsbl %al,%eax
  800483:	83 e8 20             	sub    $0x20,%eax
  800486:	83 f8 5e             	cmp    $0x5e,%eax
  800489:	76 10                	jbe    80049b <vprintfmt+0x213>
					putch('?', putdat);
  80048b:	83 ec 08             	sub    $0x8,%esp
  80048e:	ff 75 0c             	pushl  0xc(%ebp)
  800491:	6a 3f                	push   $0x3f
  800493:	ff 55 08             	call   *0x8(%ebp)
  800496:	83 c4 10             	add    $0x10,%esp
  800499:	eb 0d                	jmp    8004a8 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80049b:	83 ec 08             	sub    $0x8,%esp
  80049e:	ff 75 0c             	pushl  0xc(%ebp)
  8004a1:	52                   	push   %edx
  8004a2:	ff 55 08             	call   *0x8(%ebp)
  8004a5:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004a8:	83 eb 01             	sub    $0x1,%ebx
  8004ab:	eb 1a                	jmp    8004c7 <vprintfmt+0x23f>
  8004ad:	89 75 08             	mov    %esi,0x8(%ebp)
  8004b0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004b3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004b6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004b9:	eb 0c                	jmp    8004c7 <vprintfmt+0x23f>
  8004bb:	89 75 08             	mov    %esi,0x8(%ebp)
  8004be:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004c1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004c4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004c7:	83 c7 01             	add    $0x1,%edi
  8004ca:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004ce:	0f be d0             	movsbl %al,%edx
  8004d1:	85 d2                	test   %edx,%edx
  8004d3:	74 23                	je     8004f8 <vprintfmt+0x270>
  8004d5:	85 f6                	test   %esi,%esi
  8004d7:	78 a1                	js     80047a <vprintfmt+0x1f2>
  8004d9:	83 ee 01             	sub    $0x1,%esi
  8004dc:	79 9c                	jns    80047a <vprintfmt+0x1f2>
  8004de:	89 df                	mov    %ebx,%edi
  8004e0:	8b 75 08             	mov    0x8(%ebp),%esi
  8004e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004e6:	eb 18                	jmp    800500 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004e8:	83 ec 08             	sub    $0x8,%esp
  8004eb:	53                   	push   %ebx
  8004ec:	6a 20                	push   $0x20
  8004ee:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004f0:	83 ef 01             	sub    $0x1,%edi
  8004f3:	83 c4 10             	add    $0x10,%esp
  8004f6:	eb 08                	jmp    800500 <vprintfmt+0x278>
  8004f8:	89 df                	mov    %ebx,%edi
  8004fa:	8b 75 08             	mov    0x8(%ebp),%esi
  8004fd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800500:	85 ff                	test   %edi,%edi
  800502:	7f e4                	jg     8004e8 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800504:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800507:	e9 a2 fd ff ff       	jmp    8002ae <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80050c:	83 fa 01             	cmp    $0x1,%edx
  80050f:	7e 16                	jle    800527 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800511:	8b 45 14             	mov    0x14(%ebp),%eax
  800514:	8d 50 08             	lea    0x8(%eax),%edx
  800517:	89 55 14             	mov    %edx,0x14(%ebp)
  80051a:	8b 50 04             	mov    0x4(%eax),%edx
  80051d:	8b 00                	mov    (%eax),%eax
  80051f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800522:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800525:	eb 32                	jmp    800559 <vprintfmt+0x2d1>
	else if (lflag)
  800527:	85 d2                	test   %edx,%edx
  800529:	74 18                	je     800543 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80052b:	8b 45 14             	mov    0x14(%ebp),%eax
  80052e:	8d 50 04             	lea    0x4(%eax),%edx
  800531:	89 55 14             	mov    %edx,0x14(%ebp)
  800534:	8b 00                	mov    (%eax),%eax
  800536:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800539:	89 c1                	mov    %eax,%ecx
  80053b:	c1 f9 1f             	sar    $0x1f,%ecx
  80053e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800541:	eb 16                	jmp    800559 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800543:	8b 45 14             	mov    0x14(%ebp),%eax
  800546:	8d 50 04             	lea    0x4(%eax),%edx
  800549:	89 55 14             	mov    %edx,0x14(%ebp)
  80054c:	8b 00                	mov    (%eax),%eax
  80054e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800551:	89 c1                	mov    %eax,%ecx
  800553:	c1 f9 1f             	sar    $0x1f,%ecx
  800556:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800559:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80055c:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80055f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800564:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800568:	79 74                	jns    8005de <vprintfmt+0x356>
				putch('-', putdat);
  80056a:	83 ec 08             	sub    $0x8,%esp
  80056d:	53                   	push   %ebx
  80056e:	6a 2d                	push   $0x2d
  800570:	ff d6                	call   *%esi
				num = -(long long) num;
  800572:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800575:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800578:	f7 d8                	neg    %eax
  80057a:	83 d2 00             	adc    $0x0,%edx
  80057d:	f7 da                	neg    %edx
  80057f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800582:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800587:	eb 55                	jmp    8005de <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800589:	8d 45 14             	lea    0x14(%ebp),%eax
  80058c:	e8 83 fc ff ff       	call   800214 <getuint>
			base = 10;
  800591:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800596:	eb 46                	jmp    8005de <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800598:	8d 45 14             	lea    0x14(%ebp),%eax
  80059b:	e8 74 fc ff ff       	call   800214 <getuint>
                        base = 8;
  8005a0:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  8005a5:	eb 37                	jmp    8005de <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8005a7:	83 ec 08             	sub    $0x8,%esp
  8005aa:	53                   	push   %ebx
  8005ab:	6a 30                	push   $0x30
  8005ad:	ff d6                	call   *%esi
			putch('x', putdat);
  8005af:	83 c4 08             	add    $0x8,%esp
  8005b2:	53                   	push   %ebx
  8005b3:	6a 78                	push   $0x78
  8005b5:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ba:	8d 50 04             	lea    0x4(%eax),%edx
  8005bd:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005c0:	8b 00                	mov    (%eax),%eax
  8005c2:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005c7:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005ca:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8005cf:	eb 0d                	jmp    8005de <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005d1:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d4:	e8 3b fc ff ff       	call   800214 <getuint>
			base = 16;
  8005d9:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005de:	83 ec 0c             	sub    $0xc,%esp
  8005e1:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8005e5:	57                   	push   %edi
  8005e6:	ff 75 e0             	pushl  -0x20(%ebp)
  8005e9:	51                   	push   %ecx
  8005ea:	52                   	push   %edx
  8005eb:	50                   	push   %eax
  8005ec:	89 da                	mov    %ebx,%edx
  8005ee:	89 f0                	mov    %esi,%eax
  8005f0:	e8 70 fb ff ff       	call   800165 <printnum>
			break;
  8005f5:	83 c4 20             	add    $0x20,%esp
  8005f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005fb:	e9 ae fc ff ff       	jmp    8002ae <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800600:	83 ec 08             	sub    $0x8,%esp
  800603:	53                   	push   %ebx
  800604:	51                   	push   %ecx
  800605:	ff d6                	call   *%esi
			break;
  800607:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80060a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80060d:	e9 9c fc ff ff       	jmp    8002ae <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800612:	83 ec 08             	sub    $0x8,%esp
  800615:	53                   	push   %ebx
  800616:	6a 25                	push   $0x25
  800618:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80061a:	83 c4 10             	add    $0x10,%esp
  80061d:	eb 03                	jmp    800622 <vprintfmt+0x39a>
  80061f:	83 ef 01             	sub    $0x1,%edi
  800622:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800626:	75 f7                	jne    80061f <vprintfmt+0x397>
  800628:	e9 81 fc ff ff       	jmp    8002ae <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80062d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800630:	5b                   	pop    %ebx
  800631:	5e                   	pop    %esi
  800632:	5f                   	pop    %edi
  800633:	5d                   	pop    %ebp
  800634:	c3                   	ret    

00800635 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800635:	55                   	push   %ebp
  800636:	89 e5                	mov    %esp,%ebp
  800638:	83 ec 18             	sub    $0x18,%esp
  80063b:	8b 45 08             	mov    0x8(%ebp),%eax
  80063e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800641:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800644:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800648:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80064b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800652:	85 c0                	test   %eax,%eax
  800654:	74 26                	je     80067c <vsnprintf+0x47>
  800656:	85 d2                	test   %edx,%edx
  800658:	7e 22                	jle    80067c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80065a:	ff 75 14             	pushl  0x14(%ebp)
  80065d:	ff 75 10             	pushl  0x10(%ebp)
  800660:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800663:	50                   	push   %eax
  800664:	68 4e 02 80 00       	push   $0x80024e
  800669:	e8 1a fc ff ff       	call   800288 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80066e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800671:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800674:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800677:	83 c4 10             	add    $0x10,%esp
  80067a:	eb 05                	jmp    800681 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80067c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800681:	c9                   	leave  
  800682:	c3                   	ret    

00800683 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800683:	55                   	push   %ebp
  800684:	89 e5                	mov    %esp,%ebp
  800686:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800689:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80068c:	50                   	push   %eax
  80068d:	ff 75 10             	pushl  0x10(%ebp)
  800690:	ff 75 0c             	pushl  0xc(%ebp)
  800693:	ff 75 08             	pushl  0x8(%ebp)
  800696:	e8 9a ff ff ff       	call   800635 <vsnprintf>
	va_end(ap);

	return rc;
}
  80069b:	c9                   	leave  
  80069c:	c3                   	ret    

0080069d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80069d:	55                   	push   %ebp
  80069e:	89 e5                	mov    %esp,%ebp
  8006a0:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8006a8:	eb 03                	jmp    8006ad <strlen+0x10>
		n++;
  8006aa:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006ad:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006b1:	75 f7                	jne    8006aa <strlen+0xd>
		n++;
	return n;
}
  8006b3:	5d                   	pop    %ebp
  8006b4:	c3                   	ret    

008006b5 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006b5:	55                   	push   %ebp
  8006b6:	89 e5                	mov    %esp,%ebp
  8006b8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006bb:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006be:	ba 00 00 00 00       	mov    $0x0,%edx
  8006c3:	eb 03                	jmp    8006c8 <strnlen+0x13>
		n++;
  8006c5:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006c8:	39 c2                	cmp    %eax,%edx
  8006ca:	74 08                	je     8006d4 <strnlen+0x1f>
  8006cc:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8006d0:	75 f3                	jne    8006c5 <strnlen+0x10>
  8006d2:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8006d4:	5d                   	pop    %ebp
  8006d5:	c3                   	ret    

008006d6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006d6:	55                   	push   %ebp
  8006d7:	89 e5                	mov    %esp,%ebp
  8006d9:	53                   	push   %ebx
  8006da:	8b 45 08             	mov    0x8(%ebp),%eax
  8006dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8006e0:	89 c2                	mov    %eax,%edx
  8006e2:	83 c2 01             	add    $0x1,%edx
  8006e5:	83 c1 01             	add    $0x1,%ecx
  8006e8:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8006ec:	88 5a ff             	mov    %bl,-0x1(%edx)
  8006ef:	84 db                	test   %bl,%bl
  8006f1:	75 ef                	jne    8006e2 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8006f3:	5b                   	pop    %ebx
  8006f4:	5d                   	pop    %ebp
  8006f5:	c3                   	ret    

008006f6 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8006f6:	55                   	push   %ebp
  8006f7:	89 e5                	mov    %esp,%ebp
  8006f9:	53                   	push   %ebx
  8006fa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8006fd:	53                   	push   %ebx
  8006fe:	e8 9a ff ff ff       	call   80069d <strlen>
  800703:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800706:	ff 75 0c             	pushl  0xc(%ebp)
  800709:	01 d8                	add    %ebx,%eax
  80070b:	50                   	push   %eax
  80070c:	e8 c5 ff ff ff       	call   8006d6 <strcpy>
	return dst;
}
  800711:	89 d8                	mov    %ebx,%eax
  800713:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800716:	c9                   	leave  
  800717:	c3                   	ret    

00800718 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800718:	55                   	push   %ebp
  800719:	89 e5                	mov    %esp,%ebp
  80071b:	56                   	push   %esi
  80071c:	53                   	push   %ebx
  80071d:	8b 75 08             	mov    0x8(%ebp),%esi
  800720:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800723:	89 f3                	mov    %esi,%ebx
  800725:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800728:	89 f2                	mov    %esi,%edx
  80072a:	eb 0f                	jmp    80073b <strncpy+0x23>
		*dst++ = *src;
  80072c:	83 c2 01             	add    $0x1,%edx
  80072f:	0f b6 01             	movzbl (%ecx),%eax
  800732:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800735:	80 39 01             	cmpb   $0x1,(%ecx)
  800738:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80073b:	39 da                	cmp    %ebx,%edx
  80073d:	75 ed                	jne    80072c <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80073f:	89 f0                	mov    %esi,%eax
  800741:	5b                   	pop    %ebx
  800742:	5e                   	pop    %esi
  800743:	5d                   	pop    %ebp
  800744:	c3                   	ret    

00800745 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800745:	55                   	push   %ebp
  800746:	89 e5                	mov    %esp,%ebp
  800748:	56                   	push   %esi
  800749:	53                   	push   %ebx
  80074a:	8b 75 08             	mov    0x8(%ebp),%esi
  80074d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800750:	8b 55 10             	mov    0x10(%ebp),%edx
  800753:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800755:	85 d2                	test   %edx,%edx
  800757:	74 21                	je     80077a <strlcpy+0x35>
  800759:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80075d:	89 f2                	mov    %esi,%edx
  80075f:	eb 09                	jmp    80076a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800761:	83 c2 01             	add    $0x1,%edx
  800764:	83 c1 01             	add    $0x1,%ecx
  800767:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80076a:	39 c2                	cmp    %eax,%edx
  80076c:	74 09                	je     800777 <strlcpy+0x32>
  80076e:	0f b6 19             	movzbl (%ecx),%ebx
  800771:	84 db                	test   %bl,%bl
  800773:	75 ec                	jne    800761 <strlcpy+0x1c>
  800775:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800777:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80077a:	29 f0                	sub    %esi,%eax
}
  80077c:	5b                   	pop    %ebx
  80077d:	5e                   	pop    %esi
  80077e:	5d                   	pop    %ebp
  80077f:	c3                   	ret    

00800780 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800780:	55                   	push   %ebp
  800781:	89 e5                	mov    %esp,%ebp
  800783:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800786:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800789:	eb 06                	jmp    800791 <strcmp+0x11>
		p++, q++;
  80078b:	83 c1 01             	add    $0x1,%ecx
  80078e:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800791:	0f b6 01             	movzbl (%ecx),%eax
  800794:	84 c0                	test   %al,%al
  800796:	74 04                	je     80079c <strcmp+0x1c>
  800798:	3a 02                	cmp    (%edx),%al
  80079a:	74 ef                	je     80078b <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80079c:	0f b6 c0             	movzbl %al,%eax
  80079f:	0f b6 12             	movzbl (%edx),%edx
  8007a2:	29 d0                	sub    %edx,%eax
}
  8007a4:	5d                   	pop    %ebp
  8007a5:	c3                   	ret    

008007a6 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007a6:	55                   	push   %ebp
  8007a7:	89 e5                	mov    %esp,%ebp
  8007a9:	53                   	push   %ebx
  8007aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ad:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007b0:	89 c3                	mov    %eax,%ebx
  8007b2:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007b5:	eb 06                	jmp    8007bd <strncmp+0x17>
		n--, p++, q++;
  8007b7:	83 c0 01             	add    $0x1,%eax
  8007ba:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007bd:	39 d8                	cmp    %ebx,%eax
  8007bf:	74 15                	je     8007d6 <strncmp+0x30>
  8007c1:	0f b6 08             	movzbl (%eax),%ecx
  8007c4:	84 c9                	test   %cl,%cl
  8007c6:	74 04                	je     8007cc <strncmp+0x26>
  8007c8:	3a 0a                	cmp    (%edx),%cl
  8007ca:	74 eb                	je     8007b7 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007cc:	0f b6 00             	movzbl (%eax),%eax
  8007cf:	0f b6 12             	movzbl (%edx),%edx
  8007d2:	29 d0                	sub    %edx,%eax
  8007d4:	eb 05                	jmp    8007db <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8007d6:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8007db:	5b                   	pop    %ebx
  8007dc:	5d                   	pop    %ebp
  8007dd:	c3                   	ret    

008007de <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007de:	55                   	push   %ebp
  8007df:	89 e5                	mov    %esp,%ebp
  8007e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8007e8:	eb 07                	jmp    8007f1 <strchr+0x13>
		if (*s == c)
  8007ea:	38 ca                	cmp    %cl,%dl
  8007ec:	74 0f                	je     8007fd <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8007ee:	83 c0 01             	add    $0x1,%eax
  8007f1:	0f b6 10             	movzbl (%eax),%edx
  8007f4:	84 d2                	test   %dl,%dl
  8007f6:	75 f2                	jne    8007ea <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8007f8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007fd:	5d                   	pop    %ebp
  8007fe:	c3                   	ret    

008007ff <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8007ff:	55                   	push   %ebp
  800800:	89 e5                	mov    %esp,%ebp
  800802:	8b 45 08             	mov    0x8(%ebp),%eax
  800805:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800809:	eb 03                	jmp    80080e <strfind+0xf>
  80080b:	83 c0 01             	add    $0x1,%eax
  80080e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800811:	38 ca                	cmp    %cl,%dl
  800813:	74 04                	je     800819 <strfind+0x1a>
  800815:	84 d2                	test   %dl,%dl
  800817:	75 f2                	jne    80080b <strfind+0xc>
			break;
	return (char *) s;
}
  800819:	5d                   	pop    %ebp
  80081a:	c3                   	ret    

0080081b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80081b:	55                   	push   %ebp
  80081c:	89 e5                	mov    %esp,%ebp
  80081e:	57                   	push   %edi
  80081f:	56                   	push   %esi
  800820:	53                   	push   %ebx
  800821:	8b 7d 08             	mov    0x8(%ebp),%edi
  800824:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800827:	85 c9                	test   %ecx,%ecx
  800829:	74 36                	je     800861 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80082b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800831:	75 28                	jne    80085b <memset+0x40>
  800833:	f6 c1 03             	test   $0x3,%cl
  800836:	75 23                	jne    80085b <memset+0x40>
		c &= 0xFF;
  800838:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80083c:	89 d3                	mov    %edx,%ebx
  80083e:	c1 e3 08             	shl    $0x8,%ebx
  800841:	89 d6                	mov    %edx,%esi
  800843:	c1 e6 18             	shl    $0x18,%esi
  800846:	89 d0                	mov    %edx,%eax
  800848:	c1 e0 10             	shl    $0x10,%eax
  80084b:	09 f0                	or     %esi,%eax
  80084d:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80084f:	89 d8                	mov    %ebx,%eax
  800851:	09 d0                	or     %edx,%eax
  800853:	c1 e9 02             	shr    $0x2,%ecx
  800856:	fc                   	cld    
  800857:	f3 ab                	rep stos %eax,%es:(%edi)
  800859:	eb 06                	jmp    800861 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80085b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80085e:	fc                   	cld    
  80085f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800861:	89 f8                	mov    %edi,%eax
  800863:	5b                   	pop    %ebx
  800864:	5e                   	pop    %esi
  800865:	5f                   	pop    %edi
  800866:	5d                   	pop    %ebp
  800867:	c3                   	ret    

00800868 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800868:	55                   	push   %ebp
  800869:	89 e5                	mov    %esp,%ebp
  80086b:	57                   	push   %edi
  80086c:	56                   	push   %esi
  80086d:	8b 45 08             	mov    0x8(%ebp),%eax
  800870:	8b 75 0c             	mov    0xc(%ebp),%esi
  800873:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800876:	39 c6                	cmp    %eax,%esi
  800878:	73 35                	jae    8008af <memmove+0x47>
  80087a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80087d:	39 d0                	cmp    %edx,%eax
  80087f:	73 2e                	jae    8008af <memmove+0x47>
		s += n;
		d += n;
  800881:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800884:	89 d6                	mov    %edx,%esi
  800886:	09 fe                	or     %edi,%esi
  800888:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80088e:	75 13                	jne    8008a3 <memmove+0x3b>
  800890:	f6 c1 03             	test   $0x3,%cl
  800893:	75 0e                	jne    8008a3 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800895:	83 ef 04             	sub    $0x4,%edi
  800898:	8d 72 fc             	lea    -0x4(%edx),%esi
  80089b:	c1 e9 02             	shr    $0x2,%ecx
  80089e:	fd                   	std    
  80089f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008a1:	eb 09                	jmp    8008ac <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008a3:	83 ef 01             	sub    $0x1,%edi
  8008a6:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008a9:	fd                   	std    
  8008aa:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008ac:	fc                   	cld    
  8008ad:	eb 1d                	jmp    8008cc <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008af:	89 f2                	mov    %esi,%edx
  8008b1:	09 c2                	or     %eax,%edx
  8008b3:	f6 c2 03             	test   $0x3,%dl
  8008b6:	75 0f                	jne    8008c7 <memmove+0x5f>
  8008b8:	f6 c1 03             	test   $0x3,%cl
  8008bb:	75 0a                	jne    8008c7 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8008bd:	c1 e9 02             	shr    $0x2,%ecx
  8008c0:	89 c7                	mov    %eax,%edi
  8008c2:	fc                   	cld    
  8008c3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008c5:	eb 05                	jmp    8008cc <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008c7:	89 c7                	mov    %eax,%edi
  8008c9:	fc                   	cld    
  8008ca:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008cc:	5e                   	pop    %esi
  8008cd:	5f                   	pop    %edi
  8008ce:	5d                   	pop    %ebp
  8008cf:	c3                   	ret    

008008d0 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008d0:	55                   	push   %ebp
  8008d1:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008d3:	ff 75 10             	pushl  0x10(%ebp)
  8008d6:	ff 75 0c             	pushl  0xc(%ebp)
  8008d9:	ff 75 08             	pushl  0x8(%ebp)
  8008dc:	e8 87 ff ff ff       	call   800868 <memmove>
}
  8008e1:	c9                   	leave  
  8008e2:	c3                   	ret    

008008e3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008e3:	55                   	push   %ebp
  8008e4:	89 e5                	mov    %esp,%ebp
  8008e6:	56                   	push   %esi
  8008e7:	53                   	push   %ebx
  8008e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ee:	89 c6                	mov    %eax,%esi
  8008f0:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8008f3:	eb 1a                	jmp    80090f <memcmp+0x2c>
		if (*s1 != *s2)
  8008f5:	0f b6 08             	movzbl (%eax),%ecx
  8008f8:	0f b6 1a             	movzbl (%edx),%ebx
  8008fb:	38 d9                	cmp    %bl,%cl
  8008fd:	74 0a                	je     800909 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8008ff:	0f b6 c1             	movzbl %cl,%eax
  800902:	0f b6 db             	movzbl %bl,%ebx
  800905:	29 d8                	sub    %ebx,%eax
  800907:	eb 0f                	jmp    800918 <memcmp+0x35>
		s1++, s2++;
  800909:	83 c0 01             	add    $0x1,%eax
  80090c:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80090f:	39 f0                	cmp    %esi,%eax
  800911:	75 e2                	jne    8008f5 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800913:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800918:	5b                   	pop    %ebx
  800919:	5e                   	pop    %esi
  80091a:	5d                   	pop    %ebp
  80091b:	c3                   	ret    

0080091c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80091c:	55                   	push   %ebp
  80091d:	89 e5                	mov    %esp,%ebp
  80091f:	53                   	push   %ebx
  800920:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800923:	89 c1                	mov    %eax,%ecx
  800925:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800928:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80092c:	eb 0a                	jmp    800938 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80092e:	0f b6 10             	movzbl (%eax),%edx
  800931:	39 da                	cmp    %ebx,%edx
  800933:	74 07                	je     80093c <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800935:	83 c0 01             	add    $0x1,%eax
  800938:	39 c8                	cmp    %ecx,%eax
  80093a:	72 f2                	jb     80092e <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80093c:	5b                   	pop    %ebx
  80093d:	5d                   	pop    %ebp
  80093e:	c3                   	ret    

0080093f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80093f:	55                   	push   %ebp
  800940:	89 e5                	mov    %esp,%ebp
  800942:	57                   	push   %edi
  800943:	56                   	push   %esi
  800944:	53                   	push   %ebx
  800945:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800948:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80094b:	eb 03                	jmp    800950 <strtol+0x11>
		s++;
  80094d:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800950:	0f b6 01             	movzbl (%ecx),%eax
  800953:	3c 20                	cmp    $0x20,%al
  800955:	74 f6                	je     80094d <strtol+0xe>
  800957:	3c 09                	cmp    $0x9,%al
  800959:	74 f2                	je     80094d <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80095b:	3c 2b                	cmp    $0x2b,%al
  80095d:	75 0a                	jne    800969 <strtol+0x2a>
		s++;
  80095f:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800962:	bf 00 00 00 00       	mov    $0x0,%edi
  800967:	eb 11                	jmp    80097a <strtol+0x3b>
  800969:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80096e:	3c 2d                	cmp    $0x2d,%al
  800970:	75 08                	jne    80097a <strtol+0x3b>
		s++, neg = 1;
  800972:	83 c1 01             	add    $0x1,%ecx
  800975:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80097a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800980:	75 15                	jne    800997 <strtol+0x58>
  800982:	80 39 30             	cmpb   $0x30,(%ecx)
  800985:	75 10                	jne    800997 <strtol+0x58>
  800987:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80098b:	75 7c                	jne    800a09 <strtol+0xca>
		s += 2, base = 16;
  80098d:	83 c1 02             	add    $0x2,%ecx
  800990:	bb 10 00 00 00       	mov    $0x10,%ebx
  800995:	eb 16                	jmp    8009ad <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800997:	85 db                	test   %ebx,%ebx
  800999:	75 12                	jne    8009ad <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80099b:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009a0:	80 39 30             	cmpb   $0x30,(%ecx)
  8009a3:	75 08                	jne    8009ad <strtol+0x6e>
		s++, base = 8;
  8009a5:	83 c1 01             	add    $0x1,%ecx
  8009a8:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b2:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009b5:	0f b6 11             	movzbl (%ecx),%edx
  8009b8:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009bb:	89 f3                	mov    %esi,%ebx
  8009bd:	80 fb 09             	cmp    $0x9,%bl
  8009c0:	77 08                	ja     8009ca <strtol+0x8b>
			dig = *s - '0';
  8009c2:	0f be d2             	movsbl %dl,%edx
  8009c5:	83 ea 30             	sub    $0x30,%edx
  8009c8:	eb 22                	jmp    8009ec <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8009ca:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009cd:	89 f3                	mov    %esi,%ebx
  8009cf:	80 fb 19             	cmp    $0x19,%bl
  8009d2:	77 08                	ja     8009dc <strtol+0x9d>
			dig = *s - 'a' + 10;
  8009d4:	0f be d2             	movsbl %dl,%edx
  8009d7:	83 ea 57             	sub    $0x57,%edx
  8009da:	eb 10                	jmp    8009ec <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8009dc:	8d 72 bf             	lea    -0x41(%edx),%esi
  8009df:	89 f3                	mov    %esi,%ebx
  8009e1:	80 fb 19             	cmp    $0x19,%bl
  8009e4:	77 16                	ja     8009fc <strtol+0xbd>
			dig = *s - 'A' + 10;
  8009e6:	0f be d2             	movsbl %dl,%edx
  8009e9:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8009ec:	3b 55 10             	cmp    0x10(%ebp),%edx
  8009ef:	7d 0b                	jge    8009fc <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8009f1:	83 c1 01             	add    $0x1,%ecx
  8009f4:	0f af 45 10          	imul   0x10(%ebp),%eax
  8009f8:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8009fa:	eb b9                	jmp    8009b5 <strtol+0x76>

	if (endptr)
  8009fc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a00:	74 0d                	je     800a0f <strtol+0xd0>
		*endptr = (char *) s;
  800a02:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a05:	89 0e                	mov    %ecx,(%esi)
  800a07:	eb 06                	jmp    800a0f <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a09:	85 db                	test   %ebx,%ebx
  800a0b:	74 98                	je     8009a5 <strtol+0x66>
  800a0d:	eb 9e                	jmp    8009ad <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a0f:	89 c2                	mov    %eax,%edx
  800a11:	f7 da                	neg    %edx
  800a13:	85 ff                	test   %edi,%edi
  800a15:	0f 45 c2             	cmovne %edx,%eax
}
  800a18:	5b                   	pop    %ebx
  800a19:	5e                   	pop    %esi
  800a1a:	5f                   	pop    %edi
  800a1b:	5d                   	pop    %ebp
  800a1c:	c3                   	ret    

00800a1d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a1d:	55                   	push   %ebp
  800a1e:	89 e5                	mov    %esp,%ebp
  800a20:	57                   	push   %edi
  800a21:	56                   	push   %esi
  800a22:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a23:	b8 00 00 00 00       	mov    $0x0,%eax
  800a28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800a2e:	89 c3                	mov    %eax,%ebx
  800a30:	89 c7                	mov    %eax,%edi
  800a32:	89 c6                	mov    %eax,%esi
  800a34:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a36:	5b                   	pop    %ebx
  800a37:	5e                   	pop    %esi
  800a38:	5f                   	pop    %edi
  800a39:	5d                   	pop    %ebp
  800a3a:	c3                   	ret    

00800a3b <sys_cgetc>:

int
sys_cgetc(void)
{
  800a3b:	55                   	push   %ebp
  800a3c:	89 e5                	mov    %esp,%ebp
  800a3e:	57                   	push   %edi
  800a3f:	56                   	push   %esi
  800a40:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a41:	ba 00 00 00 00       	mov    $0x0,%edx
  800a46:	b8 01 00 00 00       	mov    $0x1,%eax
  800a4b:	89 d1                	mov    %edx,%ecx
  800a4d:	89 d3                	mov    %edx,%ebx
  800a4f:	89 d7                	mov    %edx,%edi
  800a51:	89 d6                	mov    %edx,%esi
  800a53:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a55:	5b                   	pop    %ebx
  800a56:	5e                   	pop    %esi
  800a57:	5f                   	pop    %edi
  800a58:	5d                   	pop    %ebp
  800a59:	c3                   	ret    

00800a5a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a5a:	55                   	push   %ebp
  800a5b:	89 e5                	mov    %esp,%ebp
  800a5d:	57                   	push   %edi
  800a5e:	56                   	push   %esi
  800a5f:	53                   	push   %ebx
  800a60:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a63:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a68:	b8 03 00 00 00       	mov    $0x3,%eax
  800a6d:	8b 55 08             	mov    0x8(%ebp),%edx
  800a70:	89 cb                	mov    %ecx,%ebx
  800a72:	89 cf                	mov    %ecx,%edi
  800a74:	89 ce                	mov    %ecx,%esi
  800a76:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800a78:	85 c0                	test   %eax,%eax
  800a7a:	7e 17                	jle    800a93 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a7c:	83 ec 0c             	sub    $0xc,%esp
  800a7f:	50                   	push   %eax
  800a80:	6a 03                	push   $0x3
  800a82:	68 3f 21 80 00       	push   $0x80213f
  800a87:	6a 23                	push   $0x23
  800a89:	68 5c 21 80 00       	push   $0x80215c
  800a8e:	e8 4a 0f 00 00       	call   8019dd <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800a93:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a96:	5b                   	pop    %ebx
  800a97:	5e                   	pop    %esi
  800a98:	5f                   	pop    %edi
  800a99:	5d                   	pop    %ebp
  800a9a:	c3                   	ret    

00800a9b <sys_getenvid>:

envid_t
sys_getenvid(void)
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
  800aa6:	b8 02 00 00 00       	mov    $0x2,%eax
  800aab:	89 d1                	mov    %edx,%ecx
  800aad:	89 d3                	mov    %edx,%ebx
  800aaf:	89 d7                	mov    %edx,%edi
  800ab1:	89 d6                	mov    %edx,%esi
  800ab3:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ab5:	5b                   	pop    %ebx
  800ab6:	5e                   	pop    %esi
  800ab7:	5f                   	pop    %edi
  800ab8:	5d                   	pop    %ebp
  800ab9:	c3                   	ret    

00800aba <sys_yield>:

void
sys_yield(void)
{
  800aba:	55                   	push   %ebp
  800abb:	89 e5                	mov    %esp,%ebp
  800abd:	57                   	push   %edi
  800abe:	56                   	push   %esi
  800abf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac5:	b8 0b 00 00 00       	mov    $0xb,%eax
  800aca:	89 d1                	mov    %edx,%ecx
  800acc:	89 d3                	mov    %edx,%ebx
  800ace:	89 d7                	mov    %edx,%edi
  800ad0:	89 d6                	mov    %edx,%esi
  800ad2:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ad4:	5b                   	pop    %ebx
  800ad5:	5e                   	pop    %esi
  800ad6:	5f                   	pop    %edi
  800ad7:	5d                   	pop    %ebp
  800ad8:	c3                   	ret    

00800ad9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ad9:	55                   	push   %ebp
  800ada:	89 e5                	mov    %esp,%ebp
  800adc:	57                   	push   %edi
  800add:	56                   	push   %esi
  800ade:	53                   	push   %ebx
  800adf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae2:	be 00 00 00 00       	mov    $0x0,%esi
  800ae7:	b8 04 00 00 00       	mov    $0x4,%eax
  800aec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aef:	8b 55 08             	mov    0x8(%ebp),%edx
  800af2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800af5:	89 f7                	mov    %esi,%edi
  800af7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800af9:	85 c0                	test   %eax,%eax
  800afb:	7e 17                	jle    800b14 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800afd:	83 ec 0c             	sub    $0xc,%esp
  800b00:	50                   	push   %eax
  800b01:	6a 04                	push   $0x4
  800b03:	68 3f 21 80 00       	push   $0x80213f
  800b08:	6a 23                	push   $0x23
  800b0a:	68 5c 21 80 00       	push   $0x80215c
  800b0f:	e8 c9 0e 00 00       	call   8019dd <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b14:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b17:	5b                   	pop    %ebx
  800b18:	5e                   	pop    %esi
  800b19:	5f                   	pop    %edi
  800b1a:	5d                   	pop    %ebp
  800b1b:	c3                   	ret    

00800b1c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b1c:	55                   	push   %ebp
  800b1d:	89 e5                	mov    %esp,%ebp
  800b1f:	57                   	push   %edi
  800b20:	56                   	push   %esi
  800b21:	53                   	push   %ebx
  800b22:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b25:	b8 05 00 00 00       	mov    $0x5,%eax
  800b2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b30:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b33:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b36:	8b 75 18             	mov    0x18(%ebp),%esi
  800b39:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b3b:	85 c0                	test   %eax,%eax
  800b3d:	7e 17                	jle    800b56 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b3f:	83 ec 0c             	sub    $0xc,%esp
  800b42:	50                   	push   %eax
  800b43:	6a 05                	push   $0x5
  800b45:	68 3f 21 80 00       	push   $0x80213f
  800b4a:	6a 23                	push   $0x23
  800b4c:	68 5c 21 80 00       	push   $0x80215c
  800b51:	e8 87 0e 00 00       	call   8019dd <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b59:	5b                   	pop    %ebx
  800b5a:	5e                   	pop    %esi
  800b5b:	5f                   	pop    %edi
  800b5c:	5d                   	pop    %ebp
  800b5d:	c3                   	ret    

00800b5e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b5e:	55                   	push   %ebp
  800b5f:	89 e5                	mov    %esp,%ebp
  800b61:	57                   	push   %edi
  800b62:	56                   	push   %esi
  800b63:	53                   	push   %ebx
  800b64:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b67:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b6c:	b8 06 00 00 00       	mov    $0x6,%eax
  800b71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b74:	8b 55 08             	mov    0x8(%ebp),%edx
  800b77:	89 df                	mov    %ebx,%edi
  800b79:	89 de                	mov    %ebx,%esi
  800b7b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b7d:	85 c0                	test   %eax,%eax
  800b7f:	7e 17                	jle    800b98 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b81:	83 ec 0c             	sub    $0xc,%esp
  800b84:	50                   	push   %eax
  800b85:	6a 06                	push   $0x6
  800b87:	68 3f 21 80 00       	push   $0x80213f
  800b8c:	6a 23                	push   $0x23
  800b8e:	68 5c 21 80 00       	push   $0x80215c
  800b93:	e8 45 0e 00 00       	call   8019dd <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800b98:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b9b:	5b                   	pop    %ebx
  800b9c:	5e                   	pop    %esi
  800b9d:	5f                   	pop    %edi
  800b9e:	5d                   	pop    %ebp
  800b9f:	c3                   	ret    

00800ba0 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ba0:	55                   	push   %ebp
  800ba1:	89 e5                	mov    %esp,%ebp
  800ba3:	57                   	push   %edi
  800ba4:	56                   	push   %esi
  800ba5:	53                   	push   %ebx
  800ba6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bae:	b8 08 00 00 00       	mov    $0x8,%eax
  800bb3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb9:	89 df                	mov    %ebx,%edi
  800bbb:	89 de                	mov    %ebx,%esi
  800bbd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bbf:	85 c0                	test   %eax,%eax
  800bc1:	7e 17                	jle    800bda <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc3:	83 ec 0c             	sub    $0xc,%esp
  800bc6:	50                   	push   %eax
  800bc7:	6a 08                	push   $0x8
  800bc9:	68 3f 21 80 00       	push   $0x80213f
  800bce:	6a 23                	push   $0x23
  800bd0:	68 5c 21 80 00       	push   $0x80215c
  800bd5:	e8 03 0e 00 00       	call   8019dd <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800bda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bdd:	5b                   	pop    %ebx
  800bde:	5e                   	pop    %esi
  800bdf:	5f                   	pop    %edi
  800be0:	5d                   	pop    %ebp
  800be1:	c3                   	ret    

00800be2 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800be2:	55                   	push   %ebp
  800be3:	89 e5                	mov    %esp,%ebp
  800be5:	57                   	push   %edi
  800be6:	56                   	push   %esi
  800be7:	53                   	push   %ebx
  800be8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800beb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bf0:	b8 09 00 00 00       	mov    $0x9,%eax
  800bf5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfb:	89 df                	mov    %ebx,%edi
  800bfd:	89 de                	mov    %ebx,%esi
  800bff:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c01:	85 c0                	test   %eax,%eax
  800c03:	7e 17                	jle    800c1c <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c05:	83 ec 0c             	sub    $0xc,%esp
  800c08:	50                   	push   %eax
  800c09:	6a 09                	push   $0x9
  800c0b:	68 3f 21 80 00       	push   $0x80213f
  800c10:	6a 23                	push   $0x23
  800c12:	68 5c 21 80 00       	push   $0x80215c
  800c17:	e8 c1 0d 00 00       	call   8019dd <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c1f:	5b                   	pop    %ebx
  800c20:	5e                   	pop    %esi
  800c21:	5f                   	pop    %edi
  800c22:	5d                   	pop    %ebp
  800c23:	c3                   	ret    

00800c24 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c24:	55                   	push   %ebp
  800c25:	89 e5                	mov    %esp,%ebp
  800c27:	57                   	push   %edi
  800c28:	56                   	push   %esi
  800c29:	53                   	push   %ebx
  800c2a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c32:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3d:	89 df                	mov    %ebx,%edi
  800c3f:	89 de                	mov    %ebx,%esi
  800c41:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c43:	85 c0                	test   %eax,%eax
  800c45:	7e 17                	jle    800c5e <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c47:	83 ec 0c             	sub    $0xc,%esp
  800c4a:	50                   	push   %eax
  800c4b:	6a 0a                	push   $0xa
  800c4d:	68 3f 21 80 00       	push   $0x80213f
  800c52:	6a 23                	push   $0x23
  800c54:	68 5c 21 80 00       	push   $0x80215c
  800c59:	e8 7f 0d 00 00       	call   8019dd <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c61:	5b                   	pop    %ebx
  800c62:	5e                   	pop    %esi
  800c63:	5f                   	pop    %edi
  800c64:	5d                   	pop    %ebp
  800c65:	c3                   	ret    

00800c66 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c66:	55                   	push   %ebp
  800c67:	89 e5                	mov    %esp,%ebp
  800c69:	57                   	push   %edi
  800c6a:	56                   	push   %esi
  800c6b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6c:	be 00 00 00 00       	mov    $0x0,%esi
  800c71:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c79:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c7f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c82:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800c84:	5b                   	pop    %ebx
  800c85:	5e                   	pop    %esi
  800c86:	5f                   	pop    %edi
  800c87:	5d                   	pop    %ebp
  800c88:	c3                   	ret    

00800c89 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c89:	55                   	push   %ebp
  800c8a:	89 e5                	mov    %esp,%ebp
  800c8c:	57                   	push   %edi
  800c8d:	56                   	push   %esi
  800c8e:	53                   	push   %ebx
  800c8f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c92:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c97:	b8 0d 00 00 00       	mov    $0xd,%eax
  800c9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9f:	89 cb                	mov    %ecx,%ebx
  800ca1:	89 cf                	mov    %ecx,%edi
  800ca3:	89 ce                	mov    %ecx,%esi
  800ca5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ca7:	85 c0                	test   %eax,%eax
  800ca9:	7e 17                	jle    800cc2 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cab:	83 ec 0c             	sub    $0xc,%esp
  800cae:	50                   	push   %eax
  800caf:	6a 0d                	push   $0xd
  800cb1:	68 3f 21 80 00       	push   $0x80213f
  800cb6:	6a 23                	push   $0x23
  800cb8:	68 5c 21 80 00       	push   $0x80215c
  800cbd:	e8 1b 0d 00 00       	call   8019dd <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cc2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc5:	5b                   	pop    %ebx
  800cc6:	5e                   	pop    %esi
  800cc7:	5f                   	pop    %edi
  800cc8:	5d                   	pop    %ebp
  800cc9:	c3                   	ret    

00800cca <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800cca:	55                   	push   %ebp
  800ccb:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ccd:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd0:	05 00 00 00 30       	add    $0x30000000,%eax
  800cd5:	c1 e8 0c             	shr    $0xc,%eax
}
  800cd8:	5d                   	pop    %ebp
  800cd9:	c3                   	ret    

00800cda <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800cda:	55                   	push   %ebp
  800cdb:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800cdd:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce0:	05 00 00 00 30       	add    $0x30000000,%eax
  800ce5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800cea:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800cef:	5d                   	pop    %ebp
  800cf0:	c3                   	ret    

00800cf1 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800cf1:	55                   	push   %ebp
  800cf2:	89 e5                	mov    %esp,%ebp
  800cf4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cf7:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800cfc:	89 c2                	mov    %eax,%edx
  800cfe:	c1 ea 16             	shr    $0x16,%edx
  800d01:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d08:	f6 c2 01             	test   $0x1,%dl
  800d0b:	74 11                	je     800d1e <fd_alloc+0x2d>
  800d0d:	89 c2                	mov    %eax,%edx
  800d0f:	c1 ea 0c             	shr    $0xc,%edx
  800d12:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d19:	f6 c2 01             	test   $0x1,%dl
  800d1c:	75 09                	jne    800d27 <fd_alloc+0x36>
			*fd_store = fd;
  800d1e:	89 01                	mov    %eax,(%ecx)
			return 0;
  800d20:	b8 00 00 00 00       	mov    $0x0,%eax
  800d25:	eb 17                	jmp    800d3e <fd_alloc+0x4d>
  800d27:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800d2c:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800d31:	75 c9                	jne    800cfc <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800d33:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800d39:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800d3e:	5d                   	pop    %ebp
  800d3f:	c3                   	ret    

00800d40 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800d40:	55                   	push   %ebp
  800d41:	89 e5                	mov    %esp,%ebp
  800d43:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800d46:	83 f8 1f             	cmp    $0x1f,%eax
  800d49:	77 36                	ja     800d81 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800d4b:	c1 e0 0c             	shl    $0xc,%eax
  800d4e:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800d53:	89 c2                	mov    %eax,%edx
  800d55:	c1 ea 16             	shr    $0x16,%edx
  800d58:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d5f:	f6 c2 01             	test   $0x1,%dl
  800d62:	74 24                	je     800d88 <fd_lookup+0x48>
  800d64:	89 c2                	mov    %eax,%edx
  800d66:	c1 ea 0c             	shr    $0xc,%edx
  800d69:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d70:	f6 c2 01             	test   $0x1,%dl
  800d73:	74 1a                	je     800d8f <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800d75:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d78:	89 02                	mov    %eax,(%edx)
	return 0;
  800d7a:	b8 00 00 00 00       	mov    $0x0,%eax
  800d7f:	eb 13                	jmp    800d94 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800d81:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800d86:	eb 0c                	jmp    800d94 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800d88:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800d8d:	eb 05                	jmp    800d94 <fd_lookup+0x54>
  800d8f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800d94:	5d                   	pop    %ebp
  800d95:	c3                   	ret    

00800d96 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800d96:	55                   	push   %ebp
  800d97:	89 e5                	mov    %esp,%ebp
  800d99:	83 ec 08             	sub    $0x8,%esp
  800d9c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d9f:	ba e8 21 80 00       	mov    $0x8021e8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800da4:	eb 13                	jmp    800db9 <dev_lookup+0x23>
  800da6:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800da9:	39 08                	cmp    %ecx,(%eax)
  800dab:	75 0c                	jne    800db9 <dev_lookup+0x23>
			*dev = devtab[i];
  800dad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db0:	89 01                	mov    %eax,(%ecx)
			return 0;
  800db2:	b8 00 00 00 00       	mov    $0x0,%eax
  800db7:	eb 2e                	jmp    800de7 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800db9:	8b 02                	mov    (%edx),%eax
  800dbb:	85 c0                	test   %eax,%eax
  800dbd:	75 e7                	jne    800da6 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800dbf:	a1 04 40 80 00       	mov    0x804004,%eax
  800dc4:	8b 40 48             	mov    0x48(%eax),%eax
  800dc7:	83 ec 04             	sub    $0x4,%esp
  800dca:	51                   	push   %ecx
  800dcb:	50                   	push   %eax
  800dcc:	68 6c 21 80 00       	push   $0x80216c
  800dd1:	e8 7b f3 ff ff       	call   800151 <cprintf>
	*dev = 0;
  800dd6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dd9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800ddf:	83 c4 10             	add    $0x10,%esp
  800de2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800de7:	c9                   	leave  
  800de8:	c3                   	ret    

00800de9 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800de9:	55                   	push   %ebp
  800dea:	89 e5                	mov    %esp,%ebp
  800dec:	56                   	push   %esi
  800ded:	53                   	push   %ebx
  800dee:	83 ec 10             	sub    $0x10,%esp
  800df1:	8b 75 08             	mov    0x8(%ebp),%esi
  800df4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800df7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800dfa:	50                   	push   %eax
  800dfb:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e01:	c1 e8 0c             	shr    $0xc,%eax
  800e04:	50                   	push   %eax
  800e05:	e8 36 ff ff ff       	call   800d40 <fd_lookup>
  800e0a:	83 c4 08             	add    $0x8,%esp
  800e0d:	85 c0                	test   %eax,%eax
  800e0f:	78 05                	js     800e16 <fd_close+0x2d>
	    || fd != fd2)
  800e11:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800e14:	74 0c                	je     800e22 <fd_close+0x39>
		return (must_exist ? r : 0);
  800e16:	84 db                	test   %bl,%bl
  800e18:	ba 00 00 00 00       	mov    $0x0,%edx
  800e1d:	0f 44 c2             	cmove  %edx,%eax
  800e20:	eb 41                	jmp    800e63 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800e22:	83 ec 08             	sub    $0x8,%esp
  800e25:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e28:	50                   	push   %eax
  800e29:	ff 36                	pushl  (%esi)
  800e2b:	e8 66 ff ff ff       	call   800d96 <dev_lookup>
  800e30:	89 c3                	mov    %eax,%ebx
  800e32:	83 c4 10             	add    $0x10,%esp
  800e35:	85 c0                	test   %eax,%eax
  800e37:	78 1a                	js     800e53 <fd_close+0x6a>
		if (dev->dev_close)
  800e39:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e3c:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800e3f:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800e44:	85 c0                	test   %eax,%eax
  800e46:	74 0b                	je     800e53 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800e48:	83 ec 0c             	sub    $0xc,%esp
  800e4b:	56                   	push   %esi
  800e4c:	ff d0                	call   *%eax
  800e4e:	89 c3                	mov    %eax,%ebx
  800e50:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800e53:	83 ec 08             	sub    $0x8,%esp
  800e56:	56                   	push   %esi
  800e57:	6a 00                	push   $0x0
  800e59:	e8 00 fd ff ff       	call   800b5e <sys_page_unmap>
	return r;
  800e5e:	83 c4 10             	add    $0x10,%esp
  800e61:	89 d8                	mov    %ebx,%eax
}
  800e63:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e66:	5b                   	pop    %ebx
  800e67:	5e                   	pop    %esi
  800e68:	5d                   	pop    %ebp
  800e69:	c3                   	ret    

00800e6a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800e6a:	55                   	push   %ebp
  800e6b:	89 e5                	mov    %esp,%ebp
  800e6d:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e70:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e73:	50                   	push   %eax
  800e74:	ff 75 08             	pushl  0x8(%ebp)
  800e77:	e8 c4 fe ff ff       	call   800d40 <fd_lookup>
  800e7c:	83 c4 08             	add    $0x8,%esp
  800e7f:	85 c0                	test   %eax,%eax
  800e81:	78 10                	js     800e93 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800e83:	83 ec 08             	sub    $0x8,%esp
  800e86:	6a 01                	push   $0x1
  800e88:	ff 75 f4             	pushl  -0xc(%ebp)
  800e8b:	e8 59 ff ff ff       	call   800de9 <fd_close>
  800e90:	83 c4 10             	add    $0x10,%esp
}
  800e93:	c9                   	leave  
  800e94:	c3                   	ret    

00800e95 <close_all>:

void
close_all(void)
{
  800e95:	55                   	push   %ebp
  800e96:	89 e5                	mov    %esp,%ebp
  800e98:	53                   	push   %ebx
  800e99:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800e9c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800ea1:	83 ec 0c             	sub    $0xc,%esp
  800ea4:	53                   	push   %ebx
  800ea5:	e8 c0 ff ff ff       	call   800e6a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800eaa:	83 c3 01             	add    $0x1,%ebx
  800ead:	83 c4 10             	add    $0x10,%esp
  800eb0:	83 fb 20             	cmp    $0x20,%ebx
  800eb3:	75 ec                	jne    800ea1 <close_all+0xc>
		close(i);
}
  800eb5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800eb8:	c9                   	leave  
  800eb9:	c3                   	ret    

00800eba <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800eba:	55                   	push   %ebp
  800ebb:	89 e5                	mov    %esp,%ebp
  800ebd:	57                   	push   %edi
  800ebe:	56                   	push   %esi
  800ebf:	53                   	push   %ebx
  800ec0:	83 ec 2c             	sub    $0x2c,%esp
  800ec3:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800ec6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ec9:	50                   	push   %eax
  800eca:	ff 75 08             	pushl  0x8(%ebp)
  800ecd:	e8 6e fe ff ff       	call   800d40 <fd_lookup>
  800ed2:	83 c4 08             	add    $0x8,%esp
  800ed5:	85 c0                	test   %eax,%eax
  800ed7:	0f 88 c1 00 00 00    	js     800f9e <dup+0xe4>
		return r;
	close(newfdnum);
  800edd:	83 ec 0c             	sub    $0xc,%esp
  800ee0:	56                   	push   %esi
  800ee1:	e8 84 ff ff ff       	call   800e6a <close>

	newfd = INDEX2FD(newfdnum);
  800ee6:	89 f3                	mov    %esi,%ebx
  800ee8:	c1 e3 0c             	shl    $0xc,%ebx
  800eeb:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800ef1:	83 c4 04             	add    $0x4,%esp
  800ef4:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ef7:	e8 de fd ff ff       	call   800cda <fd2data>
  800efc:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800efe:	89 1c 24             	mov    %ebx,(%esp)
  800f01:	e8 d4 fd ff ff       	call   800cda <fd2data>
  800f06:	83 c4 10             	add    $0x10,%esp
  800f09:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f0c:	89 f8                	mov    %edi,%eax
  800f0e:	c1 e8 16             	shr    $0x16,%eax
  800f11:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f18:	a8 01                	test   $0x1,%al
  800f1a:	74 37                	je     800f53 <dup+0x99>
  800f1c:	89 f8                	mov    %edi,%eax
  800f1e:	c1 e8 0c             	shr    $0xc,%eax
  800f21:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f28:	f6 c2 01             	test   $0x1,%dl
  800f2b:	74 26                	je     800f53 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800f2d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f34:	83 ec 0c             	sub    $0xc,%esp
  800f37:	25 07 0e 00 00       	and    $0xe07,%eax
  800f3c:	50                   	push   %eax
  800f3d:	ff 75 d4             	pushl  -0x2c(%ebp)
  800f40:	6a 00                	push   $0x0
  800f42:	57                   	push   %edi
  800f43:	6a 00                	push   $0x0
  800f45:	e8 d2 fb ff ff       	call   800b1c <sys_page_map>
  800f4a:	89 c7                	mov    %eax,%edi
  800f4c:	83 c4 20             	add    $0x20,%esp
  800f4f:	85 c0                	test   %eax,%eax
  800f51:	78 2e                	js     800f81 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800f53:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800f56:	89 d0                	mov    %edx,%eax
  800f58:	c1 e8 0c             	shr    $0xc,%eax
  800f5b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f62:	83 ec 0c             	sub    $0xc,%esp
  800f65:	25 07 0e 00 00       	and    $0xe07,%eax
  800f6a:	50                   	push   %eax
  800f6b:	53                   	push   %ebx
  800f6c:	6a 00                	push   $0x0
  800f6e:	52                   	push   %edx
  800f6f:	6a 00                	push   $0x0
  800f71:	e8 a6 fb ff ff       	call   800b1c <sys_page_map>
  800f76:	89 c7                	mov    %eax,%edi
  800f78:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800f7b:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800f7d:	85 ff                	test   %edi,%edi
  800f7f:	79 1d                	jns    800f9e <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800f81:	83 ec 08             	sub    $0x8,%esp
  800f84:	53                   	push   %ebx
  800f85:	6a 00                	push   $0x0
  800f87:	e8 d2 fb ff ff       	call   800b5e <sys_page_unmap>
	sys_page_unmap(0, nva);
  800f8c:	83 c4 08             	add    $0x8,%esp
  800f8f:	ff 75 d4             	pushl  -0x2c(%ebp)
  800f92:	6a 00                	push   $0x0
  800f94:	e8 c5 fb ff ff       	call   800b5e <sys_page_unmap>
	return r;
  800f99:	83 c4 10             	add    $0x10,%esp
  800f9c:	89 f8                	mov    %edi,%eax
}
  800f9e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fa1:	5b                   	pop    %ebx
  800fa2:	5e                   	pop    %esi
  800fa3:	5f                   	pop    %edi
  800fa4:	5d                   	pop    %ebp
  800fa5:	c3                   	ret    

00800fa6 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800fa6:	55                   	push   %ebp
  800fa7:	89 e5                	mov    %esp,%ebp
  800fa9:	53                   	push   %ebx
  800faa:	83 ec 14             	sub    $0x14,%esp
  800fad:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800fb0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fb3:	50                   	push   %eax
  800fb4:	53                   	push   %ebx
  800fb5:	e8 86 fd ff ff       	call   800d40 <fd_lookup>
  800fba:	83 c4 08             	add    $0x8,%esp
  800fbd:	89 c2                	mov    %eax,%edx
  800fbf:	85 c0                	test   %eax,%eax
  800fc1:	78 6d                	js     801030 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800fc3:	83 ec 08             	sub    $0x8,%esp
  800fc6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fc9:	50                   	push   %eax
  800fca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fcd:	ff 30                	pushl  (%eax)
  800fcf:	e8 c2 fd ff ff       	call   800d96 <dev_lookup>
  800fd4:	83 c4 10             	add    $0x10,%esp
  800fd7:	85 c0                	test   %eax,%eax
  800fd9:	78 4c                	js     801027 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800fdb:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800fde:	8b 42 08             	mov    0x8(%edx),%eax
  800fe1:	83 e0 03             	and    $0x3,%eax
  800fe4:	83 f8 01             	cmp    $0x1,%eax
  800fe7:	75 21                	jne    80100a <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800fe9:	a1 04 40 80 00       	mov    0x804004,%eax
  800fee:	8b 40 48             	mov    0x48(%eax),%eax
  800ff1:	83 ec 04             	sub    $0x4,%esp
  800ff4:	53                   	push   %ebx
  800ff5:	50                   	push   %eax
  800ff6:	68 ad 21 80 00       	push   $0x8021ad
  800ffb:	e8 51 f1 ff ff       	call   800151 <cprintf>
		return -E_INVAL;
  801000:	83 c4 10             	add    $0x10,%esp
  801003:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801008:	eb 26                	jmp    801030 <read+0x8a>
	}
	if (!dev->dev_read)
  80100a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80100d:	8b 40 08             	mov    0x8(%eax),%eax
  801010:	85 c0                	test   %eax,%eax
  801012:	74 17                	je     80102b <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801014:	83 ec 04             	sub    $0x4,%esp
  801017:	ff 75 10             	pushl  0x10(%ebp)
  80101a:	ff 75 0c             	pushl  0xc(%ebp)
  80101d:	52                   	push   %edx
  80101e:	ff d0                	call   *%eax
  801020:	89 c2                	mov    %eax,%edx
  801022:	83 c4 10             	add    $0x10,%esp
  801025:	eb 09                	jmp    801030 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801027:	89 c2                	mov    %eax,%edx
  801029:	eb 05                	jmp    801030 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80102b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801030:	89 d0                	mov    %edx,%eax
  801032:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801035:	c9                   	leave  
  801036:	c3                   	ret    

00801037 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801037:	55                   	push   %ebp
  801038:	89 e5                	mov    %esp,%ebp
  80103a:	57                   	push   %edi
  80103b:	56                   	push   %esi
  80103c:	53                   	push   %ebx
  80103d:	83 ec 0c             	sub    $0xc,%esp
  801040:	8b 7d 08             	mov    0x8(%ebp),%edi
  801043:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801046:	bb 00 00 00 00       	mov    $0x0,%ebx
  80104b:	eb 21                	jmp    80106e <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80104d:	83 ec 04             	sub    $0x4,%esp
  801050:	89 f0                	mov    %esi,%eax
  801052:	29 d8                	sub    %ebx,%eax
  801054:	50                   	push   %eax
  801055:	89 d8                	mov    %ebx,%eax
  801057:	03 45 0c             	add    0xc(%ebp),%eax
  80105a:	50                   	push   %eax
  80105b:	57                   	push   %edi
  80105c:	e8 45 ff ff ff       	call   800fa6 <read>
		if (m < 0)
  801061:	83 c4 10             	add    $0x10,%esp
  801064:	85 c0                	test   %eax,%eax
  801066:	78 10                	js     801078 <readn+0x41>
			return m;
		if (m == 0)
  801068:	85 c0                	test   %eax,%eax
  80106a:	74 0a                	je     801076 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80106c:	01 c3                	add    %eax,%ebx
  80106e:	39 f3                	cmp    %esi,%ebx
  801070:	72 db                	jb     80104d <readn+0x16>
  801072:	89 d8                	mov    %ebx,%eax
  801074:	eb 02                	jmp    801078 <readn+0x41>
  801076:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801078:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80107b:	5b                   	pop    %ebx
  80107c:	5e                   	pop    %esi
  80107d:	5f                   	pop    %edi
  80107e:	5d                   	pop    %ebp
  80107f:	c3                   	ret    

00801080 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801080:	55                   	push   %ebp
  801081:	89 e5                	mov    %esp,%ebp
  801083:	53                   	push   %ebx
  801084:	83 ec 14             	sub    $0x14,%esp
  801087:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80108a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80108d:	50                   	push   %eax
  80108e:	53                   	push   %ebx
  80108f:	e8 ac fc ff ff       	call   800d40 <fd_lookup>
  801094:	83 c4 08             	add    $0x8,%esp
  801097:	89 c2                	mov    %eax,%edx
  801099:	85 c0                	test   %eax,%eax
  80109b:	78 68                	js     801105 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80109d:	83 ec 08             	sub    $0x8,%esp
  8010a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010a3:	50                   	push   %eax
  8010a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010a7:	ff 30                	pushl  (%eax)
  8010a9:	e8 e8 fc ff ff       	call   800d96 <dev_lookup>
  8010ae:	83 c4 10             	add    $0x10,%esp
  8010b1:	85 c0                	test   %eax,%eax
  8010b3:	78 47                	js     8010fc <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8010b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010b8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8010bc:	75 21                	jne    8010df <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8010be:	a1 04 40 80 00       	mov    0x804004,%eax
  8010c3:	8b 40 48             	mov    0x48(%eax),%eax
  8010c6:	83 ec 04             	sub    $0x4,%esp
  8010c9:	53                   	push   %ebx
  8010ca:	50                   	push   %eax
  8010cb:	68 c9 21 80 00       	push   $0x8021c9
  8010d0:	e8 7c f0 ff ff       	call   800151 <cprintf>
		return -E_INVAL;
  8010d5:	83 c4 10             	add    $0x10,%esp
  8010d8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8010dd:	eb 26                	jmp    801105 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8010df:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8010e2:	8b 52 0c             	mov    0xc(%edx),%edx
  8010e5:	85 d2                	test   %edx,%edx
  8010e7:	74 17                	je     801100 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8010e9:	83 ec 04             	sub    $0x4,%esp
  8010ec:	ff 75 10             	pushl  0x10(%ebp)
  8010ef:	ff 75 0c             	pushl  0xc(%ebp)
  8010f2:	50                   	push   %eax
  8010f3:	ff d2                	call   *%edx
  8010f5:	89 c2                	mov    %eax,%edx
  8010f7:	83 c4 10             	add    $0x10,%esp
  8010fa:	eb 09                	jmp    801105 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010fc:	89 c2                	mov    %eax,%edx
  8010fe:	eb 05                	jmp    801105 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801100:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801105:	89 d0                	mov    %edx,%eax
  801107:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80110a:	c9                   	leave  
  80110b:	c3                   	ret    

0080110c <seek>:

int
seek(int fdnum, off_t offset)
{
  80110c:	55                   	push   %ebp
  80110d:	89 e5                	mov    %esp,%ebp
  80110f:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801112:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801115:	50                   	push   %eax
  801116:	ff 75 08             	pushl  0x8(%ebp)
  801119:	e8 22 fc ff ff       	call   800d40 <fd_lookup>
  80111e:	83 c4 08             	add    $0x8,%esp
  801121:	85 c0                	test   %eax,%eax
  801123:	78 0e                	js     801133 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801125:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801128:	8b 55 0c             	mov    0xc(%ebp),%edx
  80112b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80112e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801133:	c9                   	leave  
  801134:	c3                   	ret    

00801135 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801135:	55                   	push   %ebp
  801136:	89 e5                	mov    %esp,%ebp
  801138:	53                   	push   %ebx
  801139:	83 ec 14             	sub    $0x14,%esp
  80113c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80113f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801142:	50                   	push   %eax
  801143:	53                   	push   %ebx
  801144:	e8 f7 fb ff ff       	call   800d40 <fd_lookup>
  801149:	83 c4 08             	add    $0x8,%esp
  80114c:	89 c2                	mov    %eax,%edx
  80114e:	85 c0                	test   %eax,%eax
  801150:	78 65                	js     8011b7 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801152:	83 ec 08             	sub    $0x8,%esp
  801155:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801158:	50                   	push   %eax
  801159:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80115c:	ff 30                	pushl  (%eax)
  80115e:	e8 33 fc ff ff       	call   800d96 <dev_lookup>
  801163:	83 c4 10             	add    $0x10,%esp
  801166:	85 c0                	test   %eax,%eax
  801168:	78 44                	js     8011ae <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80116a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80116d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801171:	75 21                	jne    801194 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801173:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801178:	8b 40 48             	mov    0x48(%eax),%eax
  80117b:	83 ec 04             	sub    $0x4,%esp
  80117e:	53                   	push   %ebx
  80117f:	50                   	push   %eax
  801180:	68 8c 21 80 00       	push   $0x80218c
  801185:	e8 c7 ef ff ff       	call   800151 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80118a:	83 c4 10             	add    $0x10,%esp
  80118d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801192:	eb 23                	jmp    8011b7 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801194:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801197:	8b 52 18             	mov    0x18(%edx),%edx
  80119a:	85 d2                	test   %edx,%edx
  80119c:	74 14                	je     8011b2 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80119e:	83 ec 08             	sub    $0x8,%esp
  8011a1:	ff 75 0c             	pushl  0xc(%ebp)
  8011a4:	50                   	push   %eax
  8011a5:	ff d2                	call   *%edx
  8011a7:	89 c2                	mov    %eax,%edx
  8011a9:	83 c4 10             	add    $0x10,%esp
  8011ac:	eb 09                	jmp    8011b7 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011ae:	89 c2                	mov    %eax,%edx
  8011b0:	eb 05                	jmp    8011b7 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8011b2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8011b7:	89 d0                	mov    %edx,%eax
  8011b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011bc:	c9                   	leave  
  8011bd:	c3                   	ret    

008011be <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8011be:	55                   	push   %ebp
  8011bf:	89 e5                	mov    %esp,%ebp
  8011c1:	53                   	push   %ebx
  8011c2:	83 ec 14             	sub    $0x14,%esp
  8011c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011c8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011cb:	50                   	push   %eax
  8011cc:	ff 75 08             	pushl  0x8(%ebp)
  8011cf:	e8 6c fb ff ff       	call   800d40 <fd_lookup>
  8011d4:	83 c4 08             	add    $0x8,%esp
  8011d7:	89 c2                	mov    %eax,%edx
  8011d9:	85 c0                	test   %eax,%eax
  8011db:	78 58                	js     801235 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011dd:	83 ec 08             	sub    $0x8,%esp
  8011e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011e3:	50                   	push   %eax
  8011e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011e7:	ff 30                	pushl  (%eax)
  8011e9:	e8 a8 fb ff ff       	call   800d96 <dev_lookup>
  8011ee:	83 c4 10             	add    $0x10,%esp
  8011f1:	85 c0                	test   %eax,%eax
  8011f3:	78 37                	js     80122c <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8011f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011f8:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8011fc:	74 32                	je     801230 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8011fe:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801201:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801208:	00 00 00 
	stat->st_isdir = 0;
  80120b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801212:	00 00 00 
	stat->st_dev = dev;
  801215:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80121b:	83 ec 08             	sub    $0x8,%esp
  80121e:	53                   	push   %ebx
  80121f:	ff 75 f0             	pushl  -0x10(%ebp)
  801222:	ff 50 14             	call   *0x14(%eax)
  801225:	89 c2                	mov    %eax,%edx
  801227:	83 c4 10             	add    $0x10,%esp
  80122a:	eb 09                	jmp    801235 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80122c:	89 c2                	mov    %eax,%edx
  80122e:	eb 05                	jmp    801235 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801230:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801235:	89 d0                	mov    %edx,%eax
  801237:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80123a:	c9                   	leave  
  80123b:	c3                   	ret    

0080123c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80123c:	55                   	push   %ebp
  80123d:	89 e5                	mov    %esp,%ebp
  80123f:	56                   	push   %esi
  801240:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801241:	83 ec 08             	sub    $0x8,%esp
  801244:	6a 00                	push   $0x0
  801246:	ff 75 08             	pushl  0x8(%ebp)
  801249:	e8 0c 02 00 00       	call   80145a <open>
  80124e:	89 c3                	mov    %eax,%ebx
  801250:	83 c4 10             	add    $0x10,%esp
  801253:	85 c0                	test   %eax,%eax
  801255:	78 1b                	js     801272 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801257:	83 ec 08             	sub    $0x8,%esp
  80125a:	ff 75 0c             	pushl  0xc(%ebp)
  80125d:	50                   	push   %eax
  80125e:	e8 5b ff ff ff       	call   8011be <fstat>
  801263:	89 c6                	mov    %eax,%esi
	close(fd);
  801265:	89 1c 24             	mov    %ebx,(%esp)
  801268:	e8 fd fb ff ff       	call   800e6a <close>
	return r;
  80126d:	83 c4 10             	add    $0x10,%esp
  801270:	89 f0                	mov    %esi,%eax
}
  801272:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801275:	5b                   	pop    %ebx
  801276:	5e                   	pop    %esi
  801277:	5d                   	pop    %ebp
  801278:	c3                   	ret    

00801279 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801279:	55                   	push   %ebp
  80127a:	89 e5                	mov    %esp,%ebp
  80127c:	56                   	push   %esi
  80127d:	53                   	push   %ebx
  80127e:	89 c6                	mov    %eax,%esi
  801280:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801282:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801289:	75 12                	jne    80129d <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80128b:	83 ec 0c             	sub    $0xc,%esp
  80128e:	6a 01                	push   $0x1
  801290:	e8 4b 08 00 00       	call   801ae0 <ipc_find_env>
  801295:	a3 00 40 80 00       	mov    %eax,0x804000
  80129a:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80129d:	6a 07                	push   $0x7
  80129f:	68 00 50 80 00       	push   $0x805000
  8012a4:	56                   	push   %esi
  8012a5:	ff 35 00 40 80 00    	pushl  0x804000
  8012ab:	e8 dc 07 00 00       	call   801a8c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8012b0:	83 c4 0c             	add    $0xc,%esp
  8012b3:	6a 00                	push   $0x0
  8012b5:	53                   	push   %ebx
  8012b6:	6a 00                	push   $0x0
  8012b8:	e8 66 07 00 00       	call   801a23 <ipc_recv>
}
  8012bd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012c0:	5b                   	pop    %ebx
  8012c1:	5e                   	pop    %esi
  8012c2:	5d                   	pop    %ebp
  8012c3:	c3                   	ret    

008012c4 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8012c4:	55                   	push   %ebp
  8012c5:	89 e5                	mov    %esp,%ebp
  8012c7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8012ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8012cd:	8b 40 0c             	mov    0xc(%eax),%eax
  8012d0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8012d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012d8:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8012dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8012e2:	b8 02 00 00 00       	mov    $0x2,%eax
  8012e7:	e8 8d ff ff ff       	call   801279 <fsipc>
}
  8012ec:	c9                   	leave  
  8012ed:	c3                   	ret    

008012ee <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8012ee:	55                   	push   %ebp
  8012ef:	89 e5                	mov    %esp,%ebp
  8012f1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8012f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8012f7:	8b 40 0c             	mov    0xc(%eax),%eax
  8012fa:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8012ff:	ba 00 00 00 00       	mov    $0x0,%edx
  801304:	b8 06 00 00 00       	mov    $0x6,%eax
  801309:	e8 6b ff ff ff       	call   801279 <fsipc>
}
  80130e:	c9                   	leave  
  80130f:	c3                   	ret    

00801310 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801310:	55                   	push   %ebp
  801311:	89 e5                	mov    %esp,%ebp
  801313:	53                   	push   %ebx
  801314:	83 ec 04             	sub    $0x4,%esp
  801317:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80131a:	8b 45 08             	mov    0x8(%ebp),%eax
  80131d:	8b 40 0c             	mov    0xc(%eax),%eax
  801320:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801325:	ba 00 00 00 00       	mov    $0x0,%edx
  80132a:	b8 05 00 00 00       	mov    $0x5,%eax
  80132f:	e8 45 ff ff ff       	call   801279 <fsipc>
  801334:	85 c0                	test   %eax,%eax
  801336:	78 2c                	js     801364 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801338:	83 ec 08             	sub    $0x8,%esp
  80133b:	68 00 50 80 00       	push   $0x805000
  801340:	53                   	push   %ebx
  801341:	e8 90 f3 ff ff       	call   8006d6 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801346:	a1 80 50 80 00       	mov    0x805080,%eax
  80134b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801351:	a1 84 50 80 00       	mov    0x805084,%eax
  801356:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80135c:	83 c4 10             	add    $0x10,%esp
  80135f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801364:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801367:	c9                   	leave  
  801368:	c3                   	ret    

00801369 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801369:	55                   	push   %ebp
  80136a:	89 e5                	mov    %esp,%ebp
  80136c:	53                   	push   %ebx
  80136d:	83 ec 08             	sub    $0x8,%esp
  801370:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801373:	8b 55 08             	mov    0x8(%ebp),%edx
  801376:	8b 52 0c             	mov    0xc(%edx),%edx
  801379:	89 15 00 50 80 00    	mov    %edx,0x805000
  80137f:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801384:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  801389:	0f 46 d8             	cmovbe %eax,%ebx
	
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  80138c:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  801392:	53                   	push   %ebx
  801393:	ff 75 0c             	pushl  0xc(%ebp)
  801396:	68 08 50 80 00       	push   $0x805008
  80139b:	e8 c8 f4 ff ff       	call   800868 <memmove>

	
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) 
  8013a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8013a5:	b8 04 00 00 00       	mov    $0x4,%eax
  8013aa:	e8 ca fe ff ff       	call   801279 <fsipc>
  8013af:	83 c4 10             	add    $0x10,%esp
  8013b2:	85 c0                	test   %eax,%eax
  8013b4:	78 1d                	js     8013d3 <devfile_write+0x6a>
		return r;
	assert(r <= n_real); 
  8013b6:	39 d8                	cmp    %ebx,%eax
  8013b8:	76 19                	jbe    8013d3 <devfile_write+0x6a>
  8013ba:	68 f8 21 80 00       	push   $0x8021f8
  8013bf:	68 04 22 80 00       	push   $0x802204
  8013c4:	68 a3 00 00 00       	push   $0xa3
  8013c9:	68 19 22 80 00       	push   $0x802219
  8013ce:	e8 0a 06 00 00       	call   8019dd <_panic>
	return r;
}
  8013d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013d6:	c9                   	leave  
  8013d7:	c3                   	ret    

008013d8 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8013d8:	55                   	push   %ebp
  8013d9:	89 e5                	mov    %esp,%ebp
  8013db:	56                   	push   %esi
  8013dc:	53                   	push   %ebx
  8013dd:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8013e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8013e3:	8b 40 0c             	mov    0xc(%eax),%eax
  8013e6:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8013eb:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8013f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8013f6:	b8 03 00 00 00       	mov    $0x3,%eax
  8013fb:	e8 79 fe ff ff       	call   801279 <fsipc>
  801400:	89 c3                	mov    %eax,%ebx
  801402:	85 c0                	test   %eax,%eax
  801404:	78 4b                	js     801451 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801406:	39 c6                	cmp    %eax,%esi
  801408:	73 16                	jae    801420 <devfile_read+0x48>
  80140a:	68 24 22 80 00       	push   $0x802224
  80140f:	68 04 22 80 00       	push   $0x802204
  801414:	6a 7c                	push   $0x7c
  801416:	68 19 22 80 00       	push   $0x802219
  80141b:	e8 bd 05 00 00       	call   8019dd <_panic>
	assert(r <= PGSIZE);
  801420:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801425:	7e 16                	jle    80143d <devfile_read+0x65>
  801427:	68 2b 22 80 00       	push   $0x80222b
  80142c:	68 04 22 80 00       	push   $0x802204
  801431:	6a 7d                	push   $0x7d
  801433:	68 19 22 80 00       	push   $0x802219
  801438:	e8 a0 05 00 00       	call   8019dd <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80143d:	83 ec 04             	sub    $0x4,%esp
  801440:	50                   	push   %eax
  801441:	68 00 50 80 00       	push   $0x805000
  801446:	ff 75 0c             	pushl  0xc(%ebp)
  801449:	e8 1a f4 ff ff       	call   800868 <memmove>
	return r;
  80144e:	83 c4 10             	add    $0x10,%esp
}
  801451:	89 d8                	mov    %ebx,%eax
  801453:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801456:	5b                   	pop    %ebx
  801457:	5e                   	pop    %esi
  801458:	5d                   	pop    %ebp
  801459:	c3                   	ret    

0080145a <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80145a:	55                   	push   %ebp
  80145b:	89 e5                	mov    %esp,%ebp
  80145d:	53                   	push   %ebx
  80145e:	83 ec 20             	sub    $0x20,%esp
  801461:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801464:	53                   	push   %ebx
  801465:	e8 33 f2 ff ff       	call   80069d <strlen>
  80146a:	83 c4 10             	add    $0x10,%esp
  80146d:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801472:	7f 67                	jg     8014db <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801474:	83 ec 0c             	sub    $0xc,%esp
  801477:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80147a:	50                   	push   %eax
  80147b:	e8 71 f8 ff ff       	call   800cf1 <fd_alloc>
  801480:	83 c4 10             	add    $0x10,%esp
		return r;
  801483:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801485:	85 c0                	test   %eax,%eax
  801487:	78 57                	js     8014e0 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801489:	83 ec 08             	sub    $0x8,%esp
  80148c:	53                   	push   %ebx
  80148d:	68 00 50 80 00       	push   $0x805000
  801492:	e8 3f f2 ff ff       	call   8006d6 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801497:	8b 45 0c             	mov    0xc(%ebp),%eax
  80149a:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80149f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014a2:	b8 01 00 00 00       	mov    $0x1,%eax
  8014a7:	e8 cd fd ff ff       	call   801279 <fsipc>
  8014ac:	89 c3                	mov    %eax,%ebx
  8014ae:	83 c4 10             	add    $0x10,%esp
  8014b1:	85 c0                	test   %eax,%eax
  8014b3:	79 14                	jns    8014c9 <open+0x6f>
		fd_close(fd, 0);
  8014b5:	83 ec 08             	sub    $0x8,%esp
  8014b8:	6a 00                	push   $0x0
  8014ba:	ff 75 f4             	pushl  -0xc(%ebp)
  8014bd:	e8 27 f9 ff ff       	call   800de9 <fd_close>
		return r;
  8014c2:	83 c4 10             	add    $0x10,%esp
  8014c5:	89 da                	mov    %ebx,%edx
  8014c7:	eb 17                	jmp    8014e0 <open+0x86>
	}

	return fd2num(fd);
  8014c9:	83 ec 0c             	sub    $0xc,%esp
  8014cc:	ff 75 f4             	pushl  -0xc(%ebp)
  8014cf:	e8 f6 f7 ff ff       	call   800cca <fd2num>
  8014d4:	89 c2                	mov    %eax,%edx
  8014d6:	83 c4 10             	add    $0x10,%esp
  8014d9:	eb 05                	jmp    8014e0 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8014db:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8014e0:	89 d0                	mov    %edx,%eax
  8014e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014e5:	c9                   	leave  
  8014e6:	c3                   	ret    

008014e7 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8014e7:	55                   	push   %ebp
  8014e8:	89 e5                	mov    %esp,%ebp
  8014ea:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8014ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8014f2:	b8 08 00 00 00       	mov    $0x8,%eax
  8014f7:	e8 7d fd ff ff       	call   801279 <fsipc>
}
  8014fc:	c9                   	leave  
  8014fd:	c3                   	ret    

008014fe <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8014fe:	55                   	push   %ebp
  8014ff:	89 e5                	mov    %esp,%ebp
  801501:	56                   	push   %esi
  801502:	53                   	push   %ebx
  801503:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801506:	83 ec 0c             	sub    $0xc,%esp
  801509:	ff 75 08             	pushl  0x8(%ebp)
  80150c:	e8 c9 f7 ff ff       	call   800cda <fd2data>
  801511:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801513:	83 c4 08             	add    $0x8,%esp
  801516:	68 37 22 80 00       	push   $0x802237
  80151b:	53                   	push   %ebx
  80151c:	e8 b5 f1 ff ff       	call   8006d6 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801521:	8b 46 04             	mov    0x4(%esi),%eax
  801524:	2b 06                	sub    (%esi),%eax
  801526:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80152c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801533:	00 00 00 
	stat->st_dev = &devpipe;
  801536:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80153d:	30 80 00 
	return 0;
}
  801540:	b8 00 00 00 00       	mov    $0x0,%eax
  801545:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801548:	5b                   	pop    %ebx
  801549:	5e                   	pop    %esi
  80154a:	5d                   	pop    %ebp
  80154b:	c3                   	ret    

0080154c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80154c:	55                   	push   %ebp
  80154d:	89 e5                	mov    %esp,%ebp
  80154f:	53                   	push   %ebx
  801550:	83 ec 0c             	sub    $0xc,%esp
  801553:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801556:	53                   	push   %ebx
  801557:	6a 00                	push   $0x0
  801559:	e8 00 f6 ff ff       	call   800b5e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80155e:	89 1c 24             	mov    %ebx,(%esp)
  801561:	e8 74 f7 ff ff       	call   800cda <fd2data>
  801566:	83 c4 08             	add    $0x8,%esp
  801569:	50                   	push   %eax
  80156a:	6a 00                	push   $0x0
  80156c:	e8 ed f5 ff ff       	call   800b5e <sys_page_unmap>
}
  801571:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801574:	c9                   	leave  
  801575:	c3                   	ret    

00801576 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801576:	55                   	push   %ebp
  801577:	89 e5                	mov    %esp,%ebp
  801579:	57                   	push   %edi
  80157a:	56                   	push   %esi
  80157b:	53                   	push   %ebx
  80157c:	83 ec 1c             	sub    $0x1c,%esp
  80157f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801582:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801584:	a1 04 40 80 00       	mov    0x804004,%eax
  801589:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80158c:	83 ec 0c             	sub    $0xc,%esp
  80158f:	ff 75 e0             	pushl  -0x20(%ebp)
  801592:	e8 82 05 00 00       	call   801b19 <pageref>
  801597:	89 c3                	mov    %eax,%ebx
  801599:	89 3c 24             	mov    %edi,(%esp)
  80159c:	e8 78 05 00 00       	call   801b19 <pageref>
  8015a1:	83 c4 10             	add    $0x10,%esp
  8015a4:	39 c3                	cmp    %eax,%ebx
  8015a6:	0f 94 c1             	sete   %cl
  8015a9:	0f b6 c9             	movzbl %cl,%ecx
  8015ac:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8015af:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8015b5:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8015b8:	39 ce                	cmp    %ecx,%esi
  8015ba:	74 1b                	je     8015d7 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8015bc:	39 c3                	cmp    %eax,%ebx
  8015be:	75 c4                	jne    801584 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8015c0:	8b 42 58             	mov    0x58(%edx),%eax
  8015c3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015c6:	50                   	push   %eax
  8015c7:	56                   	push   %esi
  8015c8:	68 3e 22 80 00       	push   $0x80223e
  8015cd:	e8 7f eb ff ff       	call   800151 <cprintf>
  8015d2:	83 c4 10             	add    $0x10,%esp
  8015d5:	eb ad                	jmp    801584 <_pipeisclosed+0xe>
	}
}
  8015d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015dd:	5b                   	pop    %ebx
  8015de:	5e                   	pop    %esi
  8015df:	5f                   	pop    %edi
  8015e0:	5d                   	pop    %ebp
  8015e1:	c3                   	ret    

008015e2 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8015e2:	55                   	push   %ebp
  8015e3:	89 e5                	mov    %esp,%ebp
  8015e5:	57                   	push   %edi
  8015e6:	56                   	push   %esi
  8015e7:	53                   	push   %ebx
  8015e8:	83 ec 28             	sub    $0x28,%esp
  8015eb:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8015ee:	56                   	push   %esi
  8015ef:	e8 e6 f6 ff ff       	call   800cda <fd2data>
  8015f4:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8015f6:	83 c4 10             	add    $0x10,%esp
  8015f9:	bf 00 00 00 00       	mov    $0x0,%edi
  8015fe:	eb 4b                	jmp    80164b <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801600:	89 da                	mov    %ebx,%edx
  801602:	89 f0                	mov    %esi,%eax
  801604:	e8 6d ff ff ff       	call   801576 <_pipeisclosed>
  801609:	85 c0                	test   %eax,%eax
  80160b:	75 48                	jne    801655 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80160d:	e8 a8 f4 ff ff       	call   800aba <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801612:	8b 43 04             	mov    0x4(%ebx),%eax
  801615:	8b 0b                	mov    (%ebx),%ecx
  801617:	8d 51 20             	lea    0x20(%ecx),%edx
  80161a:	39 d0                	cmp    %edx,%eax
  80161c:	73 e2                	jae    801600 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80161e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801621:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801625:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801628:	89 c2                	mov    %eax,%edx
  80162a:	c1 fa 1f             	sar    $0x1f,%edx
  80162d:	89 d1                	mov    %edx,%ecx
  80162f:	c1 e9 1b             	shr    $0x1b,%ecx
  801632:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801635:	83 e2 1f             	and    $0x1f,%edx
  801638:	29 ca                	sub    %ecx,%edx
  80163a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80163e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801642:	83 c0 01             	add    $0x1,%eax
  801645:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801648:	83 c7 01             	add    $0x1,%edi
  80164b:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80164e:	75 c2                	jne    801612 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801650:	8b 45 10             	mov    0x10(%ebp),%eax
  801653:	eb 05                	jmp    80165a <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801655:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80165a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80165d:	5b                   	pop    %ebx
  80165e:	5e                   	pop    %esi
  80165f:	5f                   	pop    %edi
  801660:	5d                   	pop    %ebp
  801661:	c3                   	ret    

00801662 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801662:	55                   	push   %ebp
  801663:	89 e5                	mov    %esp,%ebp
  801665:	57                   	push   %edi
  801666:	56                   	push   %esi
  801667:	53                   	push   %ebx
  801668:	83 ec 18             	sub    $0x18,%esp
  80166b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80166e:	57                   	push   %edi
  80166f:	e8 66 f6 ff ff       	call   800cda <fd2data>
  801674:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801676:	83 c4 10             	add    $0x10,%esp
  801679:	bb 00 00 00 00       	mov    $0x0,%ebx
  80167e:	eb 3d                	jmp    8016bd <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801680:	85 db                	test   %ebx,%ebx
  801682:	74 04                	je     801688 <devpipe_read+0x26>
				return i;
  801684:	89 d8                	mov    %ebx,%eax
  801686:	eb 44                	jmp    8016cc <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801688:	89 f2                	mov    %esi,%edx
  80168a:	89 f8                	mov    %edi,%eax
  80168c:	e8 e5 fe ff ff       	call   801576 <_pipeisclosed>
  801691:	85 c0                	test   %eax,%eax
  801693:	75 32                	jne    8016c7 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801695:	e8 20 f4 ff ff       	call   800aba <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80169a:	8b 06                	mov    (%esi),%eax
  80169c:	3b 46 04             	cmp    0x4(%esi),%eax
  80169f:	74 df                	je     801680 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8016a1:	99                   	cltd   
  8016a2:	c1 ea 1b             	shr    $0x1b,%edx
  8016a5:	01 d0                	add    %edx,%eax
  8016a7:	83 e0 1f             	and    $0x1f,%eax
  8016aa:	29 d0                	sub    %edx,%eax
  8016ac:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8016b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016b4:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8016b7:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016ba:	83 c3 01             	add    $0x1,%ebx
  8016bd:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8016c0:	75 d8                	jne    80169a <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8016c2:	8b 45 10             	mov    0x10(%ebp),%eax
  8016c5:	eb 05                	jmp    8016cc <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8016c7:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8016cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016cf:	5b                   	pop    %ebx
  8016d0:	5e                   	pop    %esi
  8016d1:	5f                   	pop    %edi
  8016d2:	5d                   	pop    %ebp
  8016d3:	c3                   	ret    

008016d4 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8016d4:	55                   	push   %ebp
  8016d5:	89 e5                	mov    %esp,%ebp
  8016d7:	56                   	push   %esi
  8016d8:	53                   	push   %ebx
  8016d9:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8016dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016df:	50                   	push   %eax
  8016e0:	e8 0c f6 ff ff       	call   800cf1 <fd_alloc>
  8016e5:	83 c4 10             	add    $0x10,%esp
  8016e8:	89 c2                	mov    %eax,%edx
  8016ea:	85 c0                	test   %eax,%eax
  8016ec:	0f 88 2c 01 00 00    	js     80181e <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8016f2:	83 ec 04             	sub    $0x4,%esp
  8016f5:	68 07 04 00 00       	push   $0x407
  8016fa:	ff 75 f4             	pushl  -0xc(%ebp)
  8016fd:	6a 00                	push   $0x0
  8016ff:	e8 d5 f3 ff ff       	call   800ad9 <sys_page_alloc>
  801704:	83 c4 10             	add    $0x10,%esp
  801707:	89 c2                	mov    %eax,%edx
  801709:	85 c0                	test   %eax,%eax
  80170b:	0f 88 0d 01 00 00    	js     80181e <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801711:	83 ec 0c             	sub    $0xc,%esp
  801714:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801717:	50                   	push   %eax
  801718:	e8 d4 f5 ff ff       	call   800cf1 <fd_alloc>
  80171d:	89 c3                	mov    %eax,%ebx
  80171f:	83 c4 10             	add    $0x10,%esp
  801722:	85 c0                	test   %eax,%eax
  801724:	0f 88 e2 00 00 00    	js     80180c <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80172a:	83 ec 04             	sub    $0x4,%esp
  80172d:	68 07 04 00 00       	push   $0x407
  801732:	ff 75 f0             	pushl  -0x10(%ebp)
  801735:	6a 00                	push   $0x0
  801737:	e8 9d f3 ff ff       	call   800ad9 <sys_page_alloc>
  80173c:	89 c3                	mov    %eax,%ebx
  80173e:	83 c4 10             	add    $0x10,%esp
  801741:	85 c0                	test   %eax,%eax
  801743:	0f 88 c3 00 00 00    	js     80180c <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801749:	83 ec 0c             	sub    $0xc,%esp
  80174c:	ff 75 f4             	pushl  -0xc(%ebp)
  80174f:	e8 86 f5 ff ff       	call   800cda <fd2data>
  801754:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801756:	83 c4 0c             	add    $0xc,%esp
  801759:	68 07 04 00 00       	push   $0x407
  80175e:	50                   	push   %eax
  80175f:	6a 00                	push   $0x0
  801761:	e8 73 f3 ff ff       	call   800ad9 <sys_page_alloc>
  801766:	89 c3                	mov    %eax,%ebx
  801768:	83 c4 10             	add    $0x10,%esp
  80176b:	85 c0                	test   %eax,%eax
  80176d:	0f 88 89 00 00 00    	js     8017fc <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801773:	83 ec 0c             	sub    $0xc,%esp
  801776:	ff 75 f0             	pushl  -0x10(%ebp)
  801779:	e8 5c f5 ff ff       	call   800cda <fd2data>
  80177e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801785:	50                   	push   %eax
  801786:	6a 00                	push   $0x0
  801788:	56                   	push   %esi
  801789:	6a 00                	push   $0x0
  80178b:	e8 8c f3 ff ff       	call   800b1c <sys_page_map>
  801790:	89 c3                	mov    %eax,%ebx
  801792:	83 c4 20             	add    $0x20,%esp
  801795:	85 c0                	test   %eax,%eax
  801797:	78 55                	js     8017ee <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801799:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80179f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017a2:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8017a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017a7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8017ae:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017b7:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8017b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017bc:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8017c3:	83 ec 0c             	sub    $0xc,%esp
  8017c6:	ff 75 f4             	pushl  -0xc(%ebp)
  8017c9:	e8 fc f4 ff ff       	call   800cca <fd2num>
  8017ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017d1:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8017d3:	83 c4 04             	add    $0x4,%esp
  8017d6:	ff 75 f0             	pushl  -0x10(%ebp)
  8017d9:	e8 ec f4 ff ff       	call   800cca <fd2num>
  8017de:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017e1:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8017e4:	83 c4 10             	add    $0x10,%esp
  8017e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ec:	eb 30                	jmp    80181e <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8017ee:	83 ec 08             	sub    $0x8,%esp
  8017f1:	56                   	push   %esi
  8017f2:	6a 00                	push   $0x0
  8017f4:	e8 65 f3 ff ff       	call   800b5e <sys_page_unmap>
  8017f9:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8017fc:	83 ec 08             	sub    $0x8,%esp
  8017ff:	ff 75 f0             	pushl  -0x10(%ebp)
  801802:	6a 00                	push   $0x0
  801804:	e8 55 f3 ff ff       	call   800b5e <sys_page_unmap>
  801809:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80180c:	83 ec 08             	sub    $0x8,%esp
  80180f:	ff 75 f4             	pushl  -0xc(%ebp)
  801812:	6a 00                	push   $0x0
  801814:	e8 45 f3 ff ff       	call   800b5e <sys_page_unmap>
  801819:	83 c4 10             	add    $0x10,%esp
  80181c:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80181e:	89 d0                	mov    %edx,%eax
  801820:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801823:	5b                   	pop    %ebx
  801824:	5e                   	pop    %esi
  801825:	5d                   	pop    %ebp
  801826:	c3                   	ret    

00801827 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801827:	55                   	push   %ebp
  801828:	89 e5                	mov    %esp,%ebp
  80182a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80182d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801830:	50                   	push   %eax
  801831:	ff 75 08             	pushl  0x8(%ebp)
  801834:	e8 07 f5 ff ff       	call   800d40 <fd_lookup>
  801839:	83 c4 10             	add    $0x10,%esp
  80183c:	85 c0                	test   %eax,%eax
  80183e:	78 18                	js     801858 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801840:	83 ec 0c             	sub    $0xc,%esp
  801843:	ff 75 f4             	pushl  -0xc(%ebp)
  801846:	e8 8f f4 ff ff       	call   800cda <fd2data>
	return _pipeisclosed(fd, p);
  80184b:	89 c2                	mov    %eax,%edx
  80184d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801850:	e8 21 fd ff ff       	call   801576 <_pipeisclosed>
  801855:	83 c4 10             	add    $0x10,%esp
}
  801858:	c9                   	leave  
  801859:	c3                   	ret    

0080185a <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80185a:	55                   	push   %ebp
  80185b:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80185d:	b8 00 00 00 00       	mov    $0x0,%eax
  801862:	5d                   	pop    %ebp
  801863:	c3                   	ret    

00801864 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801864:	55                   	push   %ebp
  801865:	89 e5                	mov    %esp,%ebp
  801867:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80186a:	68 56 22 80 00       	push   $0x802256
  80186f:	ff 75 0c             	pushl  0xc(%ebp)
  801872:	e8 5f ee ff ff       	call   8006d6 <strcpy>
	return 0;
}
  801877:	b8 00 00 00 00       	mov    $0x0,%eax
  80187c:	c9                   	leave  
  80187d:	c3                   	ret    

0080187e <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80187e:	55                   	push   %ebp
  80187f:	89 e5                	mov    %esp,%ebp
  801881:	57                   	push   %edi
  801882:	56                   	push   %esi
  801883:	53                   	push   %ebx
  801884:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80188a:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80188f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801895:	eb 2d                	jmp    8018c4 <devcons_write+0x46>
		m = n - tot;
  801897:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80189a:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80189c:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80189f:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8018a4:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8018a7:	83 ec 04             	sub    $0x4,%esp
  8018aa:	53                   	push   %ebx
  8018ab:	03 45 0c             	add    0xc(%ebp),%eax
  8018ae:	50                   	push   %eax
  8018af:	57                   	push   %edi
  8018b0:	e8 b3 ef ff ff       	call   800868 <memmove>
		sys_cputs(buf, m);
  8018b5:	83 c4 08             	add    $0x8,%esp
  8018b8:	53                   	push   %ebx
  8018b9:	57                   	push   %edi
  8018ba:	e8 5e f1 ff ff       	call   800a1d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018bf:	01 de                	add    %ebx,%esi
  8018c1:	83 c4 10             	add    $0x10,%esp
  8018c4:	89 f0                	mov    %esi,%eax
  8018c6:	3b 75 10             	cmp    0x10(%ebp),%esi
  8018c9:	72 cc                	jb     801897 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8018cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018ce:	5b                   	pop    %ebx
  8018cf:	5e                   	pop    %esi
  8018d0:	5f                   	pop    %edi
  8018d1:	5d                   	pop    %ebp
  8018d2:	c3                   	ret    

008018d3 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8018d3:	55                   	push   %ebp
  8018d4:	89 e5                	mov    %esp,%ebp
  8018d6:	83 ec 08             	sub    $0x8,%esp
  8018d9:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8018de:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8018e2:	74 2a                	je     80190e <devcons_read+0x3b>
  8018e4:	eb 05                	jmp    8018eb <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8018e6:	e8 cf f1 ff ff       	call   800aba <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8018eb:	e8 4b f1 ff ff       	call   800a3b <sys_cgetc>
  8018f0:	85 c0                	test   %eax,%eax
  8018f2:	74 f2                	je     8018e6 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8018f4:	85 c0                	test   %eax,%eax
  8018f6:	78 16                	js     80190e <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8018f8:	83 f8 04             	cmp    $0x4,%eax
  8018fb:	74 0c                	je     801909 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8018fd:	8b 55 0c             	mov    0xc(%ebp),%edx
  801900:	88 02                	mov    %al,(%edx)
	return 1;
  801902:	b8 01 00 00 00       	mov    $0x1,%eax
  801907:	eb 05                	jmp    80190e <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801909:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80190e:	c9                   	leave  
  80190f:	c3                   	ret    

00801910 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801910:	55                   	push   %ebp
  801911:	89 e5                	mov    %esp,%ebp
  801913:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801916:	8b 45 08             	mov    0x8(%ebp),%eax
  801919:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80191c:	6a 01                	push   $0x1
  80191e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801921:	50                   	push   %eax
  801922:	e8 f6 f0 ff ff       	call   800a1d <sys_cputs>
}
  801927:	83 c4 10             	add    $0x10,%esp
  80192a:	c9                   	leave  
  80192b:	c3                   	ret    

0080192c <getchar>:

int
getchar(void)
{
  80192c:	55                   	push   %ebp
  80192d:	89 e5                	mov    %esp,%ebp
  80192f:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801932:	6a 01                	push   $0x1
  801934:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801937:	50                   	push   %eax
  801938:	6a 00                	push   $0x0
  80193a:	e8 67 f6 ff ff       	call   800fa6 <read>
	if (r < 0)
  80193f:	83 c4 10             	add    $0x10,%esp
  801942:	85 c0                	test   %eax,%eax
  801944:	78 0f                	js     801955 <getchar+0x29>
		return r;
	if (r < 1)
  801946:	85 c0                	test   %eax,%eax
  801948:	7e 06                	jle    801950 <getchar+0x24>
		return -E_EOF;
	return c;
  80194a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80194e:	eb 05                	jmp    801955 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801950:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801955:	c9                   	leave  
  801956:	c3                   	ret    

00801957 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801957:	55                   	push   %ebp
  801958:	89 e5                	mov    %esp,%ebp
  80195a:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80195d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801960:	50                   	push   %eax
  801961:	ff 75 08             	pushl  0x8(%ebp)
  801964:	e8 d7 f3 ff ff       	call   800d40 <fd_lookup>
  801969:	83 c4 10             	add    $0x10,%esp
  80196c:	85 c0                	test   %eax,%eax
  80196e:	78 11                	js     801981 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801970:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801973:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801979:	39 10                	cmp    %edx,(%eax)
  80197b:	0f 94 c0             	sete   %al
  80197e:	0f b6 c0             	movzbl %al,%eax
}
  801981:	c9                   	leave  
  801982:	c3                   	ret    

00801983 <opencons>:

int
opencons(void)
{
  801983:	55                   	push   %ebp
  801984:	89 e5                	mov    %esp,%ebp
  801986:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801989:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80198c:	50                   	push   %eax
  80198d:	e8 5f f3 ff ff       	call   800cf1 <fd_alloc>
  801992:	83 c4 10             	add    $0x10,%esp
		return r;
  801995:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801997:	85 c0                	test   %eax,%eax
  801999:	78 3e                	js     8019d9 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80199b:	83 ec 04             	sub    $0x4,%esp
  80199e:	68 07 04 00 00       	push   $0x407
  8019a3:	ff 75 f4             	pushl  -0xc(%ebp)
  8019a6:	6a 00                	push   $0x0
  8019a8:	e8 2c f1 ff ff       	call   800ad9 <sys_page_alloc>
  8019ad:	83 c4 10             	add    $0x10,%esp
		return r;
  8019b0:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019b2:	85 c0                	test   %eax,%eax
  8019b4:	78 23                	js     8019d9 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8019b6:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019bf:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8019c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019c4:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8019cb:	83 ec 0c             	sub    $0xc,%esp
  8019ce:	50                   	push   %eax
  8019cf:	e8 f6 f2 ff ff       	call   800cca <fd2num>
  8019d4:	89 c2                	mov    %eax,%edx
  8019d6:	83 c4 10             	add    $0x10,%esp
}
  8019d9:	89 d0                	mov    %edx,%eax
  8019db:	c9                   	leave  
  8019dc:	c3                   	ret    

008019dd <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8019dd:	55                   	push   %ebp
  8019de:	89 e5                	mov    %esp,%ebp
  8019e0:	56                   	push   %esi
  8019e1:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8019e2:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8019e5:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8019eb:	e8 ab f0 ff ff       	call   800a9b <sys_getenvid>
  8019f0:	83 ec 0c             	sub    $0xc,%esp
  8019f3:	ff 75 0c             	pushl  0xc(%ebp)
  8019f6:	ff 75 08             	pushl  0x8(%ebp)
  8019f9:	56                   	push   %esi
  8019fa:	50                   	push   %eax
  8019fb:	68 64 22 80 00       	push   $0x802264
  801a00:	e8 4c e7 ff ff       	call   800151 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801a05:	83 c4 18             	add    $0x18,%esp
  801a08:	53                   	push   %ebx
  801a09:	ff 75 10             	pushl  0x10(%ebp)
  801a0c:	e8 ef e6 ff ff       	call   800100 <vcprintf>
	cprintf("\n");
  801a11:	c7 04 24 4f 22 80 00 	movl   $0x80224f,(%esp)
  801a18:	e8 34 e7 ff ff       	call   800151 <cprintf>
  801a1d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801a20:	cc                   	int3   
  801a21:	eb fd                	jmp    801a20 <_panic+0x43>

00801a23 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a23:	55                   	push   %ebp
  801a24:	89 e5                	mov    %esp,%ebp
  801a26:	56                   	push   %esi
  801a27:	53                   	push   %ebx
  801a28:	8b 75 08             	mov    0x8(%ebp),%esi
  801a2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a2e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  801a31:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801a33:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801a38:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  801a3b:	83 ec 0c             	sub    $0xc,%esp
  801a3e:	50                   	push   %eax
  801a3f:	e8 45 f2 ff ff       	call   800c89 <sys_ipc_recv>

	if (r < 0) {
  801a44:	83 c4 10             	add    $0x10,%esp
  801a47:	85 c0                	test   %eax,%eax
  801a49:	79 16                	jns    801a61 <ipc_recv+0x3e>
		if (from_env_store)
  801a4b:	85 f6                	test   %esi,%esi
  801a4d:	74 06                	je     801a55 <ipc_recv+0x32>
			*from_env_store = 0;
  801a4f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  801a55:	85 db                	test   %ebx,%ebx
  801a57:	74 2c                	je     801a85 <ipc_recv+0x62>
			*perm_store = 0;
  801a59:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801a5f:	eb 24                	jmp    801a85 <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  801a61:	85 f6                	test   %esi,%esi
  801a63:	74 0a                	je     801a6f <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  801a65:	a1 04 40 80 00       	mov    0x804004,%eax
  801a6a:	8b 40 74             	mov    0x74(%eax),%eax
  801a6d:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  801a6f:	85 db                	test   %ebx,%ebx
  801a71:	74 0a                	je     801a7d <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  801a73:	a1 04 40 80 00       	mov    0x804004,%eax
  801a78:	8b 40 78             	mov    0x78(%eax),%eax
  801a7b:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  801a7d:	a1 04 40 80 00       	mov    0x804004,%eax
  801a82:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  801a85:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a88:	5b                   	pop    %ebx
  801a89:	5e                   	pop    %esi
  801a8a:	5d                   	pop    %ebp
  801a8b:	c3                   	ret    

00801a8c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a8c:	55                   	push   %ebp
  801a8d:	89 e5                	mov    %esp,%ebp
  801a8f:	57                   	push   %edi
  801a90:	56                   	push   %esi
  801a91:	53                   	push   %ebx
  801a92:	83 ec 0c             	sub    $0xc,%esp
  801a95:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a98:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a9b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  801a9e:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801aa0:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801aa5:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  801aa8:	ff 75 14             	pushl  0x14(%ebp)
  801aab:	53                   	push   %ebx
  801aac:	56                   	push   %esi
  801aad:	57                   	push   %edi
  801aae:	e8 b3 f1 ff ff       	call   800c66 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  801ab3:	83 c4 10             	add    $0x10,%esp
  801ab6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ab9:	75 07                	jne    801ac2 <ipc_send+0x36>
			sys_yield();
  801abb:	e8 fa ef ff ff       	call   800aba <sys_yield>
  801ac0:	eb e6                	jmp    801aa8 <ipc_send+0x1c>
		} else if (r < 0) {
  801ac2:	85 c0                	test   %eax,%eax
  801ac4:	79 12                	jns    801ad8 <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  801ac6:	50                   	push   %eax
  801ac7:	68 88 22 80 00       	push   $0x802288
  801acc:	6a 51                	push   $0x51
  801ace:	68 95 22 80 00       	push   $0x802295
  801ad3:	e8 05 ff ff ff       	call   8019dd <_panic>
		}
	}
}
  801ad8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801adb:	5b                   	pop    %ebx
  801adc:	5e                   	pop    %esi
  801add:	5f                   	pop    %edi
  801ade:	5d                   	pop    %ebp
  801adf:	c3                   	ret    

00801ae0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ae0:	55                   	push   %ebp
  801ae1:	89 e5                	mov    %esp,%ebp
  801ae3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ae6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801aeb:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801aee:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801af4:	8b 52 50             	mov    0x50(%edx),%edx
  801af7:	39 ca                	cmp    %ecx,%edx
  801af9:	75 0d                	jne    801b08 <ipc_find_env+0x28>
			return envs[i].env_id;
  801afb:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801afe:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b03:	8b 40 48             	mov    0x48(%eax),%eax
  801b06:	eb 0f                	jmp    801b17 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b08:	83 c0 01             	add    $0x1,%eax
  801b0b:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b10:	75 d9                	jne    801aeb <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b12:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b17:	5d                   	pop    %ebp
  801b18:	c3                   	ret    

00801b19 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b19:	55                   	push   %ebp
  801b1a:	89 e5                	mov    %esp,%ebp
  801b1c:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b1f:	89 d0                	mov    %edx,%eax
  801b21:	c1 e8 16             	shr    $0x16,%eax
  801b24:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b2b:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b30:	f6 c1 01             	test   $0x1,%cl
  801b33:	74 1d                	je     801b52 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b35:	c1 ea 0c             	shr    $0xc,%edx
  801b38:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b3f:	f6 c2 01             	test   $0x1,%dl
  801b42:	74 0e                	je     801b52 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b44:	c1 ea 0c             	shr    $0xc,%edx
  801b47:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b4e:	ef 
  801b4f:	0f b7 c0             	movzwl %ax,%eax
}
  801b52:	5d                   	pop    %ebp
  801b53:	c3                   	ret    
  801b54:	66 90                	xchg   %ax,%ax
  801b56:	66 90                	xchg   %ax,%ax
  801b58:	66 90                	xchg   %ax,%ax
  801b5a:	66 90                	xchg   %ax,%ax
  801b5c:	66 90                	xchg   %ax,%ax
  801b5e:	66 90                	xchg   %ax,%ax

00801b60 <__udivdi3>:
  801b60:	55                   	push   %ebp
  801b61:	57                   	push   %edi
  801b62:	56                   	push   %esi
  801b63:	53                   	push   %ebx
  801b64:	83 ec 1c             	sub    $0x1c,%esp
  801b67:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801b6b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801b6f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801b73:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801b77:	85 f6                	test   %esi,%esi
  801b79:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b7d:	89 ca                	mov    %ecx,%edx
  801b7f:	89 f8                	mov    %edi,%eax
  801b81:	75 3d                	jne    801bc0 <__udivdi3+0x60>
  801b83:	39 cf                	cmp    %ecx,%edi
  801b85:	0f 87 c5 00 00 00    	ja     801c50 <__udivdi3+0xf0>
  801b8b:	85 ff                	test   %edi,%edi
  801b8d:	89 fd                	mov    %edi,%ebp
  801b8f:	75 0b                	jne    801b9c <__udivdi3+0x3c>
  801b91:	b8 01 00 00 00       	mov    $0x1,%eax
  801b96:	31 d2                	xor    %edx,%edx
  801b98:	f7 f7                	div    %edi
  801b9a:	89 c5                	mov    %eax,%ebp
  801b9c:	89 c8                	mov    %ecx,%eax
  801b9e:	31 d2                	xor    %edx,%edx
  801ba0:	f7 f5                	div    %ebp
  801ba2:	89 c1                	mov    %eax,%ecx
  801ba4:	89 d8                	mov    %ebx,%eax
  801ba6:	89 cf                	mov    %ecx,%edi
  801ba8:	f7 f5                	div    %ebp
  801baa:	89 c3                	mov    %eax,%ebx
  801bac:	89 d8                	mov    %ebx,%eax
  801bae:	89 fa                	mov    %edi,%edx
  801bb0:	83 c4 1c             	add    $0x1c,%esp
  801bb3:	5b                   	pop    %ebx
  801bb4:	5e                   	pop    %esi
  801bb5:	5f                   	pop    %edi
  801bb6:	5d                   	pop    %ebp
  801bb7:	c3                   	ret    
  801bb8:	90                   	nop
  801bb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801bc0:	39 ce                	cmp    %ecx,%esi
  801bc2:	77 74                	ja     801c38 <__udivdi3+0xd8>
  801bc4:	0f bd fe             	bsr    %esi,%edi
  801bc7:	83 f7 1f             	xor    $0x1f,%edi
  801bca:	0f 84 98 00 00 00    	je     801c68 <__udivdi3+0x108>
  801bd0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801bd5:	89 f9                	mov    %edi,%ecx
  801bd7:	89 c5                	mov    %eax,%ebp
  801bd9:	29 fb                	sub    %edi,%ebx
  801bdb:	d3 e6                	shl    %cl,%esi
  801bdd:	89 d9                	mov    %ebx,%ecx
  801bdf:	d3 ed                	shr    %cl,%ebp
  801be1:	89 f9                	mov    %edi,%ecx
  801be3:	d3 e0                	shl    %cl,%eax
  801be5:	09 ee                	or     %ebp,%esi
  801be7:	89 d9                	mov    %ebx,%ecx
  801be9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bed:	89 d5                	mov    %edx,%ebp
  801bef:	8b 44 24 08          	mov    0x8(%esp),%eax
  801bf3:	d3 ed                	shr    %cl,%ebp
  801bf5:	89 f9                	mov    %edi,%ecx
  801bf7:	d3 e2                	shl    %cl,%edx
  801bf9:	89 d9                	mov    %ebx,%ecx
  801bfb:	d3 e8                	shr    %cl,%eax
  801bfd:	09 c2                	or     %eax,%edx
  801bff:	89 d0                	mov    %edx,%eax
  801c01:	89 ea                	mov    %ebp,%edx
  801c03:	f7 f6                	div    %esi
  801c05:	89 d5                	mov    %edx,%ebp
  801c07:	89 c3                	mov    %eax,%ebx
  801c09:	f7 64 24 0c          	mull   0xc(%esp)
  801c0d:	39 d5                	cmp    %edx,%ebp
  801c0f:	72 10                	jb     801c21 <__udivdi3+0xc1>
  801c11:	8b 74 24 08          	mov    0x8(%esp),%esi
  801c15:	89 f9                	mov    %edi,%ecx
  801c17:	d3 e6                	shl    %cl,%esi
  801c19:	39 c6                	cmp    %eax,%esi
  801c1b:	73 07                	jae    801c24 <__udivdi3+0xc4>
  801c1d:	39 d5                	cmp    %edx,%ebp
  801c1f:	75 03                	jne    801c24 <__udivdi3+0xc4>
  801c21:	83 eb 01             	sub    $0x1,%ebx
  801c24:	31 ff                	xor    %edi,%edi
  801c26:	89 d8                	mov    %ebx,%eax
  801c28:	89 fa                	mov    %edi,%edx
  801c2a:	83 c4 1c             	add    $0x1c,%esp
  801c2d:	5b                   	pop    %ebx
  801c2e:	5e                   	pop    %esi
  801c2f:	5f                   	pop    %edi
  801c30:	5d                   	pop    %ebp
  801c31:	c3                   	ret    
  801c32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c38:	31 ff                	xor    %edi,%edi
  801c3a:	31 db                	xor    %ebx,%ebx
  801c3c:	89 d8                	mov    %ebx,%eax
  801c3e:	89 fa                	mov    %edi,%edx
  801c40:	83 c4 1c             	add    $0x1c,%esp
  801c43:	5b                   	pop    %ebx
  801c44:	5e                   	pop    %esi
  801c45:	5f                   	pop    %edi
  801c46:	5d                   	pop    %ebp
  801c47:	c3                   	ret    
  801c48:	90                   	nop
  801c49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c50:	89 d8                	mov    %ebx,%eax
  801c52:	f7 f7                	div    %edi
  801c54:	31 ff                	xor    %edi,%edi
  801c56:	89 c3                	mov    %eax,%ebx
  801c58:	89 d8                	mov    %ebx,%eax
  801c5a:	89 fa                	mov    %edi,%edx
  801c5c:	83 c4 1c             	add    $0x1c,%esp
  801c5f:	5b                   	pop    %ebx
  801c60:	5e                   	pop    %esi
  801c61:	5f                   	pop    %edi
  801c62:	5d                   	pop    %ebp
  801c63:	c3                   	ret    
  801c64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c68:	39 ce                	cmp    %ecx,%esi
  801c6a:	72 0c                	jb     801c78 <__udivdi3+0x118>
  801c6c:	31 db                	xor    %ebx,%ebx
  801c6e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801c72:	0f 87 34 ff ff ff    	ja     801bac <__udivdi3+0x4c>
  801c78:	bb 01 00 00 00       	mov    $0x1,%ebx
  801c7d:	e9 2a ff ff ff       	jmp    801bac <__udivdi3+0x4c>
  801c82:	66 90                	xchg   %ax,%ax
  801c84:	66 90                	xchg   %ax,%ax
  801c86:	66 90                	xchg   %ax,%ax
  801c88:	66 90                	xchg   %ax,%ax
  801c8a:	66 90                	xchg   %ax,%ax
  801c8c:	66 90                	xchg   %ax,%ax
  801c8e:	66 90                	xchg   %ax,%ax

00801c90 <__umoddi3>:
  801c90:	55                   	push   %ebp
  801c91:	57                   	push   %edi
  801c92:	56                   	push   %esi
  801c93:	53                   	push   %ebx
  801c94:	83 ec 1c             	sub    $0x1c,%esp
  801c97:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801c9b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801c9f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801ca3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ca7:	85 d2                	test   %edx,%edx
  801ca9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801cad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801cb1:	89 f3                	mov    %esi,%ebx
  801cb3:	89 3c 24             	mov    %edi,(%esp)
  801cb6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cba:	75 1c                	jne    801cd8 <__umoddi3+0x48>
  801cbc:	39 f7                	cmp    %esi,%edi
  801cbe:	76 50                	jbe    801d10 <__umoddi3+0x80>
  801cc0:	89 c8                	mov    %ecx,%eax
  801cc2:	89 f2                	mov    %esi,%edx
  801cc4:	f7 f7                	div    %edi
  801cc6:	89 d0                	mov    %edx,%eax
  801cc8:	31 d2                	xor    %edx,%edx
  801cca:	83 c4 1c             	add    $0x1c,%esp
  801ccd:	5b                   	pop    %ebx
  801cce:	5e                   	pop    %esi
  801ccf:	5f                   	pop    %edi
  801cd0:	5d                   	pop    %ebp
  801cd1:	c3                   	ret    
  801cd2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cd8:	39 f2                	cmp    %esi,%edx
  801cda:	89 d0                	mov    %edx,%eax
  801cdc:	77 52                	ja     801d30 <__umoddi3+0xa0>
  801cde:	0f bd ea             	bsr    %edx,%ebp
  801ce1:	83 f5 1f             	xor    $0x1f,%ebp
  801ce4:	75 5a                	jne    801d40 <__umoddi3+0xb0>
  801ce6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801cea:	0f 82 e0 00 00 00    	jb     801dd0 <__umoddi3+0x140>
  801cf0:	39 0c 24             	cmp    %ecx,(%esp)
  801cf3:	0f 86 d7 00 00 00    	jbe    801dd0 <__umoddi3+0x140>
  801cf9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801cfd:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d01:	83 c4 1c             	add    $0x1c,%esp
  801d04:	5b                   	pop    %ebx
  801d05:	5e                   	pop    %esi
  801d06:	5f                   	pop    %edi
  801d07:	5d                   	pop    %ebp
  801d08:	c3                   	ret    
  801d09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d10:	85 ff                	test   %edi,%edi
  801d12:	89 fd                	mov    %edi,%ebp
  801d14:	75 0b                	jne    801d21 <__umoddi3+0x91>
  801d16:	b8 01 00 00 00       	mov    $0x1,%eax
  801d1b:	31 d2                	xor    %edx,%edx
  801d1d:	f7 f7                	div    %edi
  801d1f:	89 c5                	mov    %eax,%ebp
  801d21:	89 f0                	mov    %esi,%eax
  801d23:	31 d2                	xor    %edx,%edx
  801d25:	f7 f5                	div    %ebp
  801d27:	89 c8                	mov    %ecx,%eax
  801d29:	f7 f5                	div    %ebp
  801d2b:	89 d0                	mov    %edx,%eax
  801d2d:	eb 99                	jmp    801cc8 <__umoddi3+0x38>
  801d2f:	90                   	nop
  801d30:	89 c8                	mov    %ecx,%eax
  801d32:	89 f2                	mov    %esi,%edx
  801d34:	83 c4 1c             	add    $0x1c,%esp
  801d37:	5b                   	pop    %ebx
  801d38:	5e                   	pop    %esi
  801d39:	5f                   	pop    %edi
  801d3a:	5d                   	pop    %ebp
  801d3b:	c3                   	ret    
  801d3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d40:	8b 34 24             	mov    (%esp),%esi
  801d43:	bf 20 00 00 00       	mov    $0x20,%edi
  801d48:	89 e9                	mov    %ebp,%ecx
  801d4a:	29 ef                	sub    %ebp,%edi
  801d4c:	d3 e0                	shl    %cl,%eax
  801d4e:	89 f9                	mov    %edi,%ecx
  801d50:	89 f2                	mov    %esi,%edx
  801d52:	d3 ea                	shr    %cl,%edx
  801d54:	89 e9                	mov    %ebp,%ecx
  801d56:	09 c2                	or     %eax,%edx
  801d58:	89 d8                	mov    %ebx,%eax
  801d5a:	89 14 24             	mov    %edx,(%esp)
  801d5d:	89 f2                	mov    %esi,%edx
  801d5f:	d3 e2                	shl    %cl,%edx
  801d61:	89 f9                	mov    %edi,%ecx
  801d63:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d67:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801d6b:	d3 e8                	shr    %cl,%eax
  801d6d:	89 e9                	mov    %ebp,%ecx
  801d6f:	89 c6                	mov    %eax,%esi
  801d71:	d3 e3                	shl    %cl,%ebx
  801d73:	89 f9                	mov    %edi,%ecx
  801d75:	89 d0                	mov    %edx,%eax
  801d77:	d3 e8                	shr    %cl,%eax
  801d79:	89 e9                	mov    %ebp,%ecx
  801d7b:	09 d8                	or     %ebx,%eax
  801d7d:	89 d3                	mov    %edx,%ebx
  801d7f:	89 f2                	mov    %esi,%edx
  801d81:	f7 34 24             	divl   (%esp)
  801d84:	89 d6                	mov    %edx,%esi
  801d86:	d3 e3                	shl    %cl,%ebx
  801d88:	f7 64 24 04          	mull   0x4(%esp)
  801d8c:	39 d6                	cmp    %edx,%esi
  801d8e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d92:	89 d1                	mov    %edx,%ecx
  801d94:	89 c3                	mov    %eax,%ebx
  801d96:	72 08                	jb     801da0 <__umoddi3+0x110>
  801d98:	75 11                	jne    801dab <__umoddi3+0x11b>
  801d9a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801d9e:	73 0b                	jae    801dab <__umoddi3+0x11b>
  801da0:	2b 44 24 04          	sub    0x4(%esp),%eax
  801da4:	1b 14 24             	sbb    (%esp),%edx
  801da7:	89 d1                	mov    %edx,%ecx
  801da9:	89 c3                	mov    %eax,%ebx
  801dab:	8b 54 24 08          	mov    0x8(%esp),%edx
  801daf:	29 da                	sub    %ebx,%edx
  801db1:	19 ce                	sbb    %ecx,%esi
  801db3:	89 f9                	mov    %edi,%ecx
  801db5:	89 f0                	mov    %esi,%eax
  801db7:	d3 e0                	shl    %cl,%eax
  801db9:	89 e9                	mov    %ebp,%ecx
  801dbb:	d3 ea                	shr    %cl,%edx
  801dbd:	89 e9                	mov    %ebp,%ecx
  801dbf:	d3 ee                	shr    %cl,%esi
  801dc1:	09 d0                	or     %edx,%eax
  801dc3:	89 f2                	mov    %esi,%edx
  801dc5:	83 c4 1c             	add    $0x1c,%esp
  801dc8:	5b                   	pop    %ebx
  801dc9:	5e                   	pop    %esi
  801dca:	5f                   	pop    %edi
  801dcb:	5d                   	pop    %ebp
  801dcc:	c3                   	ret    
  801dcd:	8d 76 00             	lea    0x0(%esi),%esi
  801dd0:	29 f9                	sub    %edi,%ecx
  801dd2:	19 d6                	sbb    %edx,%esi
  801dd4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801dd8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ddc:	e9 18 ff ff ff       	jmp    801cf9 <__umoddi3+0x69>
