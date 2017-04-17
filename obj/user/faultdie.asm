
obj/user/faultdie.debug:     file format elf32-i386


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
  80002c:	e8 4f 00 00 00       	call   800080 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 0c             	sub    $0xc,%esp
  800039:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void*)utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	cprintf("i faulted at va %x, err %x\n", addr, err & 7);
  80003c:	8b 42 04             	mov    0x4(%edx),%eax
  80003f:	83 e0 07             	and    $0x7,%eax
  800042:	50                   	push   %eax
  800043:	ff 32                	pushl  (%edx)
  800045:	68 20 23 80 00       	push   $0x802320
  80004a:	e8 24 01 00 00       	call   800173 <cprintf>
	sys_env_destroy(sys_getenvid());
  80004f:	e8 69 0a 00 00       	call   800abd <sys_getenvid>
  800054:	89 04 24             	mov    %eax,(%esp)
  800057:	e8 20 0a 00 00       	call   800a7c <sys_env_destroy>
}
  80005c:	83 c4 10             	add    $0x10,%esp
  80005f:	c9                   	leave  
  800060:	c3                   	ret    

00800061 <umain>:

void
umain(int argc, char **argv)
{
  800061:	55                   	push   %ebp
  800062:	89 e5                	mov    %esp,%ebp
  800064:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800067:	68 33 00 80 00       	push   $0x800033
  80006c:	e8 9a 0c 00 00       	call   800d0b <set_pgfault_handler>
	*(int*)0xDeadBeef = 0;
  800071:	c7 05 ef be ad de 00 	movl   $0x0,0xdeadbeef
  800078:	00 00 00 
}
  80007b:	83 c4 10             	add    $0x10,%esp
  80007e:	c9                   	leave  
  80007f:	c3                   	ret    

00800080 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800080:	55                   	push   %ebp
  800081:	89 e5                	mov    %esp,%ebp
  800083:	56                   	push   %esi
  800084:	53                   	push   %ebx
  800085:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800088:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80008b:	e8 2d 0a 00 00       	call   800abd <sys_getenvid>
  800090:	25 ff 03 00 00       	and    $0x3ff,%eax
  800095:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800098:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80009d:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a2:	85 db                	test   %ebx,%ebx
  8000a4:	7e 07                	jle    8000ad <libmain+0x2d>
		binaryname = argv[0];
  8000a6:	8b 06                	mov    (%esi),%eax
  8000a8:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000ad:	83 ec 08             	sub    $0x8,%esp
  8000b0:	56                   	push   %esi
  8000b1:	53                   	push   %ebx
  8000b2:	e8 aa ff ff ff       	call   800061 <umain>

	// exit gracefully
	exit();
  8000b7:	e8 0a 00 00 00       	call   8000c6 <exit>
}
  8000bc:	83 c4 10             	add    $0x10,%esp
  8000bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000c2:	5b                   	pop    %ebx
  8000c3:	5e                   	pop    %esi
  8000c4:	5d                   	pop    %ebp
  8000c5:	c3                   	ret    

008000c6 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c6:	55                   	push   %ebp
  8000c7:	89 e5                	mov    %esp,%ebp
  8000c9:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000cc:	e8 7b 0e 00 00       	call   800f4c <close_all>
	sys_env_destroy(0);
  8000d1:	83 ec 0c             	sub    $0xc,%esp
  8000d4:	6a 00                	push   $0x0
  8000d6:	e8 a1 09 00 00       	call   800a7c <sys_env_destroy>
}
  8000db:	83 c4 10             	add    $0x10,%esp
  8000de:	c9                   	leave  
  8000df:	c3                   	ret    

008000e0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	53                   	push   %ebx
  8000e4:	83 ec 04             	sub    $0x4,%esp
  8000e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000ea:	8b 13                	mov    (%ebx),%edx
  8000ec:	8d 42 01             	lea    0x1(%edx),%eax
  8000ef:	89 03                	mov    %eax,(%ebx)
  8000f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000f4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000f8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000fd:	75 1a                	jne    800119 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000ff:	83 ec 08             	sub    $0x8,%esp
  800102:	68 ff 00 00 00       	push   $0xff
  800107:	8d 43 08             	lea    0x8(%ebx),%eax
  80010a:	50                   	push   %eax
  80010b:	e8 2f 09 00 00       	call   800a3f <sys_cputs>
		b->idx = 0;
  800110:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800116:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800119:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80011d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800120:	c9                   	leave  
  800121:	c3                   	ret    

00800122 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800122:	55                   	push   %ebp
  800123:	89 e5                	mov    %esp,%ebp
  800125:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80012b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800132:	00 00 00 
	b.cnt = 0;
  800135:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80013c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80013f:	ff 75 0c             	pushl  0xc(%ebp)
  800142:	ff 75 08             	pushl  0x8(%ebp)
  800145:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80014b:	50                   	push   %eax
  80014c:	68 e0 00 80 00       	push   $0x8000e0
  800151:	e8 54 01 00 00       	call   8002aa <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800156:	83 c4 08             	add    $0x8,%esp
  800159:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80015f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800165:	50                   	push   %eax
  800166:	e8 d4 08 00 00       	call   800a3f <sys_cputs>

	return b.cnt;
}
  80016b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800171:	c9                   	leave  
  800172:	c3                   	ret    

00800173 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800173:	55                   	push   %ebp
  800174:	89 e5                	mov    %esp,%ebp
  800176:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800179:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80017c:	50                   	push   %eax
  80017d:	ff 75 08             	pushl  0x8(%ebp)
  800180:	e8 9d ff ff ff       	call   800122 <vcprintf>
	va_end(ap);

	return cnt;
}
  800185:	c9                   	leave  
  800186:	c3                   	ret    

00800187 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800187:	55                   	push   %ebp
  800188:	89 e5                	mov    %esp,%ebp
  80018a:	57                   	push   %edi
  80018b:	56                   	push   %esi
  80018c:	53                   	push   %ebx
  80018d:	83 ec 1c             	sub    $0x1c,%esp
  800190:	89 c7                	mov    %eax,%edi
  800192:	89 d6                	mov    %edx,%esi
  800194:	8b 45 08             	mov    0x8(%ebp),%eax
  800197:	8b 55 0c             	mov    0xc(%ebp),%edx
  80019a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80019d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001a0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001a3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001a8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001ab:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001ae:	39 d3                	cmp    %edx,%ebx
  8001b0:	72 05                	jb     8001b7 <printnum+0x30>
  8001b2:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001b5:	77 45                	ja     8001fc <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001b7:	83 ec 0c             	sub    $0xc,%esp
  8001ba:	ff 75 18             	pushl  0x18(%ebp)
  8001bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8001c0:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001c3:	53                   	push   %ebx
  8001c4:	ff 75 10             	pushl  0x10(%ebp)
  8001c7:	83 ec 08             	sub    $0x8,%esp
  8001ca:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001cd:	ff 75 e0             	pushl  -0x20(%ebp)
  8001d0:	ff 75 dc             	pushl  -0x24(%ebp)
  8001d3:	ff 75 d8             	pushl  -0x28(%ebp)
  8001d6:	e8 a5 1e 00 00       	call   802080 <__udivdi3>
  8001db:	83 c4 18             	add    $0x18,%esp
  8001de:	52                   	push   %edx
  8001df:	50                   	push   %eax
  8001e0:	89 f2                	mov    %esi,%edx
  8001e2:	89 f8                	mov    %edi,%eax
  8001e4:	e8 9e ff ff ff       	call   800187 <printnum>
  8001e9:	83 c4 20             	add    $0x20,%esp
  8001ec:	eb 18                	jmp    800206 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001ee:	83 ec 08             	sub    $0x8,%esp
  8001f1:	56                   	push   %esi
  8001f2:	ff 75 18             	pushl  0x18(%ebp)
  8001f5:	ff d7                	call   *%edi
  8001f7:	83 c4 10             	add    $0x10,%esp
  8001fa:	eb 03                	jmp    8001ff <printnum+0x78>
  8001fc:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001ff:	83 eb 01             	sub    $0x1,%ebx
  800202:	85 db                	test   %ebx,%ebx
  800204:	7f e8                	jg     8001ee <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800206:	83 ec 08             	sub    $0x8,%esp
  800209:	56                   	push   %esi
  80020a:	83 ec 04             	sub    $0x4,%esp
  80020d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800210:	ff 75 e0             	pushl  -0x20(%ebp)
  800213:	ff 75 dc             	pushl  -0x24(%ebp)
  800216:	ff 75 d8             	pushl  -0x28(%ebp)
  800219:	e8 92 1f 00 00       	call   8021b0 <__umoddi3>
  80021e:	83 c4 14             	add    $0x14,%esp
  800221:	0f be 80 46 23 80 00 	movsbl 0x802346(%eax),%eax
  800228:	50                   	push   %eax
  800229:	ff d7                	call   *%edi
}
  80022b:	83 c4 10             	add    $0x10,%esp
  80022e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800231:	5b                   	pop    %ebx
  800232:	5e                   	pop    %esi
  800233:	5f                   	pop    %edi
  800234:	5d                   	pop    %ebp
  800235:	c3                   	ret    

00800236 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800236:	55                   	push   %ebp
  800237:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800239:	83 fa 01             	cmp    $0x1,%edx
  80023c:	7e 0e                	jle    80024c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80023e:	8b 10                	mov    (%eax),%edx
  800240:	8d 4a 08             	lea    0x8(%edx),%ecx
  800243:	89 08                	mov    %ecx,(%eax)
  800245:	8b 02                	mov    (%edx),%eax
  800247:	8b 52 04             	mov    0x4(%edx),%edx
  80024a:	eb 22                	jmp    80026e <getuint+0x38>
	else if (lflag)
  80024c:	85 d2                	test   %edx,%edx
  80024e:	74 10                	je     800260 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800250:	8b 10                	mov    (%eax),%edx
  800252:	8d 4a 04             	lea    0x4(%edx),%ecx
  800255:	89 08                	mov    %ecx,(%eax)
  800257:	8b 02                	mov    (%edx),%eax
  800259:	ba 00 00 00 00       	mov    $0x0,%edx
  80025e:	eb 0e                	jmp    80026e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800260:	8b 10                	mov    (%eax),%edx
  800262:	8d 4a 04             	lea    0x4(%edx),%ecx
  800265:	89 08                	mov    %ecx,(%eax)
  800267:	8b 02                	mov    (%edx),%eax
  800269:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80026e:	5d                   	pop    %ebp
  80026f:	c3                   	ret    

00800270 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800276:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80027a:	8b 10                	mov    (%eax),%edx
  80027c:	3b 50 04             	cmp    0x4(%eax),%edx
  80027f:	73 0a                	jae    80028b <sprintputch+0x1b>
		*b->buf++ = ch;
  800281:	8d 4a 01             	lea    0x1(%edx),%ecx
  800284:	89 08                	mov    %ecx,(%eax)
  800286:	8b 45 08             	mov    0x8(%ebp),%eax
  800289:	88 02                	mov    %al,(%edx)
}
  80028b:	5d                   	pop    %ebp
  80028c:	c3                   	ret    

0080028d <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80028d:	55                   	push   %ebp
  80028e:	89 e5                	mov    %esp,%ebp
  800290:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800293:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800296:	50                   	push   %eax
  800297:	ff 75 10             	pushl  0x10(%ebp)
  80029a:	ff 75 0c             	pushl  0xc(%ebp)
  80029d:	ff 75 08             	pushl  0x8(%ebp)
  8002a0:	e8 05 00 00 00       	call   8002aa <vprintfmt>
	va_end(ap);
}
  8002a5:	83 c4 10             	add    $0x10,%esp
  8002a8:	c9                   	leave  
  8002a9:	c3                   	ret    

008002aa <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002aa:	55                   	push   %ebp
  8002ab:	89 e5                	mov    %esp,%ebp
  8002ad:	57                   	push   %edi
  8002ae:	56                   	push   %esi
  8002af:	53                   	push   %ebx
  8002b0:	83 ec 2c             	sub    $0x2c,%esp
  8002b3:	8b 75 08             	mov    0x8(%ebp),%esi
  8002b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002b9:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002bc:	eb 12                	jmp    8002d0 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002be:	85 c0                	test   %eax,%eax
  8002c0:	0f 84 89 03 00 00    	je     80064f <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8002c6:	83 ec 08             	sub    $0x8,%esp
  8002c9:	53                   	push   %ebx
  8002ca:	50                   	push   %eax
  8002cb:	ff d6                	call   *%esi
  8002cd:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002d0:	83 c7 01             	add    $0x1,%edi
  8002d3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002d7:	83 f8 25             	cmp    $0x25,%eax
  8002da:	75 e2                	jne    8002be <vprintfmt+0x14>
  8002dc:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002e0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002e7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002ee:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8002fa:	eb 07                	jmp    800303 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002ff:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800303:	8d 47 01             	lea    0x1(%edi),%eax
  800306:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800309:	0f b6 07             	movzbl (%edi),%eax
  80030c:	0f b6 c8             	movzbl %al,%ecx
  80030f:	83 e8 23             	sub    $0x23,%eax
  800312:	3c 55                	cmp    $0x55,%al
  800314:	0f 87 1a 03 00 00    	ja     800634 <vprintfmt+0x38a>
  80031a:	0f b6 c0             	movzbl %al,%eax
  80031d:	ff 24 85 80 24 80 00 	jmp    *0x802480(,%eax,4)
  800324:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800327:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80032b:	eb d6                	jmp    800303 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800330:	b8 00 00 00 00       	mov    $0x0,%eax
  800335:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800338:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80033b:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80033f:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800342:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800345:	83 fa 09             	cmp    $0x9,%edx
  800348:	77 39                	ja     800383 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80034a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80034d:	eb e9                	jmp    800338 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80034f:	8b 45 14             	mov    0x14(%ebp),%eax
  800352:	8d 48 04             	lea    0x4(%eax),%ecx
  800355:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800358:	8b 00                	mov    (%eax),%eax
  80035a:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800360:	eb 27                	jmp    800389 <vprintfmt+0xdf>
  800362:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800365:	85 c0                	test   %eax,%eax
  800367:	b9 00 00 00 00       	mov    $0x0,%ecx
  80036c:	0f 49 c8             	cmovns %eax,%ecx
  80036f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800372:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800375:	eb 8c                	jmp    800303 <vprintfmt+0x59>
  800377:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80037a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800381:	eb 80                	jmp    800303 <vprintfmt+0x59>
  800383:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800386:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800389:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80038d:	0f 89 70 ff ff ff    	jns    800303 <vprintfmt+0x59>
				width = precision, precision = -1;
  800393:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800396:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800399:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003a0:	e9 5e ff ff ff       	jmp    800303 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003a5:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003ab:	e9 53 ff ff ff       	jmp    800303 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b3:	8d 50 04             	lea    0x4(%eax),%edx
  8003b6:	89 55 14             	mov    %edx,0x14(%ebp)
  8003b9:	83 ec 08             	sub    $0x8,%esp
  8003bc:	53                   	push   %ebx
  8003bd:	ff 30                	pushl  (%eax)
  8003bf:	ff d6                	call   *%esi
			break;
  8003c1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003c7:	e9 04 ff ff ff       	jmp    8002d0 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cf:	8d 50 04             	lea    0x4(%eax),%edx
  8003d2:	89 55 14             	mov    %edx,0x14(%ebp)
  8003d5:	8b 00                	mov    (%eax),%eax
  8003d7:	99                   	cltd   
  8003d8:	31 d0                	xor    %edx,%eax
  8003da:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003dc:	83 f8 0f             	cmp    $0xf,%eax
  8003df:	7f 0b                	jg     8003ec <vprintfmt+0x142>
  8003e1:	8b 14 85 e0 25 80 00 	mov    0x8025e0(,%eax,4),%edx
  8003e8:	85 d2                	test   %edx,%edx
  8003ea:	75 18                	jne    800404 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003ec:	50                   	push   %eax
  8003ed:	68 5e 23 80 00       	push   $0x80235e
  8003f2:	53                   	push   %ebx
  8003f3:	56                   	push   %esi
  8003f4:	e8 94 fe ff ff       	call   80028d <printfmt>
  8003f9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003ff:	e9 cc fe ff ff       	jmp    8002d0 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800404:	52                   	push   %edx
  800405:	68 1a 27 80 00       	push   $0x80271a
  80040a:	53                   	push   %ebx
  80040b:	56                   	push   %esi
  80040c:	e8 7c fe ff ff       	call   80028d <printfmt>
  800411:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800414:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800417:	e9 b4 fe ff ff       	jmp    8002d0 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80041c:	8b 45 14             	mov    0x14(%ebp),%eax
  80041f:	8d 50 04             	lea    0x4(%eax),%edx
  800422:	89 55 14             	mov    %edx,0x14(%ebp)
  800425:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800427:	85 ff                	test   %edi,%edi
  800429:	b8 57 23 80 00       	mov    $0x802357,%eax
  80042e:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800431:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800435:	0f 8e 94 00 00 00    	jle    8004cf <vprintfmt+0x225>
  80043b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80043f:	0f 84 98 00 00 00    	je     8004dd <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800445:	83 ec 08             	sub    $0x8,%esp
  800448:	ff 75 d0             	pushl  -0x30(%ebp)
  80044b:	57                   	push   %edi
  80044c:	e8 86 02 00 00       	call   8006d7 <strnlen>
  800451:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800454:	29 c1                	sub    %eax,%ecx
  800456:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800459:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80045c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800460:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800463:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800466:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800468:	eb 0f                	jmp    800479 <vprintfmt+0x1cf>
					putch(padc, putdat);
  80046a:	83 ec 08             	sub    $0x8,%esp
  80046d:	53                   	push   %ebx
  80046e:	ff 75 e0             	pushl  -0x20(%ebp)
  800471:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800473:	83 ef 01             	sub    $0x1,%edi
  800476:	83 c4 10             	add    $0x10,%esp
  800479:	85 ff                	test   %edi,%edi
  80047b:	7f ed                	jg     80046a <vprintfmt+0x1c0>
  80047d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800480:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800483:	85 c9                	test   %ecx,%ecx
  800485:	b8 00 00 00 00       	mov    $0x0,%eax
  80048a:	0f 49 c1             	cmovns %ecx,%eax
  80048d:	29 c1                	sub    %eax,%ecx
  80048f:	89 75 08             	mov    %esi,0x8(%ebp)
  800492:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800495:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800498:	89 cb                	mov    %ecx,%ebx
  80049a:	eb 4d                	jmp    8004e9 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80049c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004a0:	74 1b                	je     8004bd <vprintfmt+0x213>
  8004a2:	0f be c0             	movsbl %al,%eax
  8004a5:	83 e8 20             	sub    $0x20,%eax
  8004a8:	83 f8 5e             	cmp    $0x5e,%eax
  8004ab:	76 10                	jbe    8004bd <vprintfmt+0x213>
					putch('?', putdat);
  8004ad:	83 ec 08             	sub    $0x8,%esp
  8004b0:	ff 75 0c             	pushl  0xc(%ebp)
  8004b3:	6a 3f                	push   $0x3f
  8004b5:	ff 55 08             	call   *0x8(%ebp)
  8004b8:	83 c4 10             	add    $0x10,%esp
  8004bb:	eb 0d                	jmp    8004ca <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004bd:	83 ec 08             	sub    $0x8,%esp
  8004c0:	ff 75 0c             	pushl  0xc(%ebp)
  8004c3:	52                   	push   %edx
  8004c4:	ff 55 08             	call   *0x8(%ebp)
  8004c7:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ca:	83 eb 01             	sub    $0x1,%ebx
  8004cd:	eb 1a                	jmp    8004e9 <vprintfmt+0x23f>
  8004cf:	89 75 08             	mov    %esi,0x8(%ebp)
  8004d2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004d5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004d8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004db:	eb 0c                	jmp    8004e9 <vprintfmt+0x23f>
  8004dd:	89 75 08             	mov    %esi,0x8(%ebp)
  8004e0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004e3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004e6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004e9:	83 c7 01             	add    $0x1,%edi
  8004ec:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004f0:	0f be d0             	movsbl %al,%edx
  8004f3:	85 d2                	test   %edx,%edx
  8004f5:	74 23                	je     80051a <vprintfmt+0x270>
  8004f7:	85 f6                	test   %esi,%esi
  8004f9:	78 a1                	js     80049c <vprintfmt+0x1f2>
  8004fb:	83 ee 01             	sub    $0x1,%esi
  8004fe:	79 9c                	jns    80049c <vprintfmt+0x1f2>
  800500:	89 df                	mov    %ebx,%edi
  800502:	8b 75 08             	mov    0x8(%ebp),%esi
  800505:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800508:	eb 18                	jmp    800522 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80050a:	83 ec 08             	sub    $0x8,%esp
  80050d:	53                   	push   %ebx
  80050e:	6a 20                	push   $0x20
  800510:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800512:	83 ef 01             	sub    $0x1,%edi
  800515:	83 c4 10             	add    $0x10,%esp
  800518:	eb 08                	jmp    800522 <vprintfmt+0x278>
  80051a:	89 df                	mov    %ebx,%edi
  80051c:	8b 75 08             	mov    0x8(%ebp),%esi
  80051f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800522:	85 ff                	test   %edi,%edi
  800524:	7f e4                	jg     80050a <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800526:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800529:	e9 a2 fd ff ff       	jmp    8002d0 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80052e:	83 fa 01             	cmp    $0x1,%edx
  800531:	7e 16                	jle    800549 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800533:	8b 45 14             	mov    0x14(%ebp),%eax
  800536:	8d 50 08             	lea    0x8(%eax),%edx
  800539:	89 55 14             	mov    %edx,0x14(%ebp)
  80053c:	8b 50 04             	mov    0x4(%eax),%edx
  80053f:	8b 00                	mov    (%eax),%eax
  800541:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800544:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800547:	eb 32                	jmp    80057b <vprintfmt+0x2d1>
	else if (lflag)
  800549:	85 d2                	test   %edx,%edx
  80054b:	74 18                	je     800565 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80054d:	8b 45 14             	mov    0x14(%ebp),%eax
  800550:	8d 50 04             	lea    0x4(%eax),%edx
  800553:	89 55 14             	mov    %edx,0x14(%ebp)
  800556:	8b 00                	mov    (%eax),%eax
  800558:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80055b:	89 c1                	mov    %eax,%ecx
  80055d:	c1 f9 1f             	sar    $0x1f,%ecx
  800560:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800563:	eb 16                	jmp    80057b <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800565:	8b 45 14             	mov    0x14(%ebp),%eax
  800568:	8d 50 04             	lea    0x4(%eax),%edx
  80056b:	89 55 14             	mov    %edx,0x14(%ebp)
  80056e:	8b 00                	mov    (%eax),%eax
  800570:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800573:	89 c1                	mov    %eax,%ecx
  800575:	c1 f9 1f             	sar    $0x1f,%ecx
  800578:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80057b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80057e:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800581:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800586:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80058a:	79 74                	jns    800600 <vprintfmt+0x356>
				putch('-', putdat);
  80058c:	83 ec 08             	sub    $0x8,%esp
  80058f:	53                   	push   %ebx
  800590:	6a 2d                	push   $0x2d
  800592:	ff d6                	call   *%esi
				num = -(long long) num;
  800594:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800597:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80059a:	f7 d8                	neg    %eax
  80059c:	83 d2 00             	adc    $0x0,%edx
  80059f:	f7 da                	neg    %edx
  8005a1:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005a4:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005a9:	eb 55                	jmp    800600 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005ab:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ae:	e8 83 fc ff ff       	call   800236 <getuint>
			base = 10;
  8005b3:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005b8:	eb 46                	jmp    800600 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005ba:	8d 45 14             	lea    0x14(%ebp),%eax
  8005bd:	e8 74 fc ff ff       	call   800236 <getuint>
                        base = 8;
  8005c2:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  8005c7:	eb 37                	jmp    800600 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8005c9:	83 ec 08             	sub    $0x8,%esp
  8005cc:	53                   	push   %ebx
  8005cd:	6a 30                	push   $0x30
  8005cf:	ff d6                	call   *%esi
			putch('x', putdat);
  8005d1:	83 c4 08             	add    $0x8,%esp
  8005d4:	53                   	push   %ebx
  8005d5:	6a 78                	push   $0x78
  8005d7:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005dc:	8d 50 04             	lea    0x4(%eax),%edx
  8005df:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005e2:	8b 00                	mov    (%eax),%eax
  8005e4:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005e9:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005ec:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8005f1:	eb 0d                	jmp    800600 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005f3:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f6:	e8 3b fc ff ff       	call   800236 <getuint>
			base = 16;
  8005fb:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800600:	83 ec 0c             	sub    $0xc,%esp
  800603:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800607:	57                   	push   %edi
  800608:	ff 75 e0             	pushl  -0x20(%ebp)
  80060b:	51                   	push   %ecx
  80060c:	52                   	push   %edx
  80060d:	50                   	push   %eax
  80060e:	89 da                	mov    %ebx,%edx
  800610:	89 f0                	mov    %esi,%eax
  800612:	e8 70 fb ff ff       	call   800187 <printnum>
			break;
  800617:	83 c4 20             	add    $0x20,%esp
  80061a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80061d:	e9 ae fc ff ff       	jmp    8002d0 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800622:	83 ec 08             	sub    $0x8,%esp
  800625:	53                   	push   %ebx
  800626:	51                   	push   %ecx
  800627:	ff d6                	call   *%esi
			break;
  800629:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80062c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80062f:	e9 9c fc ff ff       	jmp    8002d0 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800634:	83 ec 08             	sub    $0x8,%esp
  800637:	53                   	push   %ebx
  800638:	6a 25                	push   $0x25
  80063a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80063c:	83 c4 10             	add    $0x10,%esp
  80063f:	eb 03                	jmp    800644 <vprintfmt+0x39a>
  800641:	83 ef 01             	sub    $0x1,%edi
  800644:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800648:	75 f7                	jne    800641 <vprintfmt+0x397>
  80064a:	e9 81 fc ff ff       	jmp    8002d0 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80064f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800652:	5b                   	pop    %ebx
  800653:	5e                   	pop    %esi
  800654:	5f                   	pop    %edi
  800655:	5d                   	pop    %ebp
  800656:	c3                   	ret    

00800657 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800657:	55                   	push   %ebp
  800658:	89 e5                	mov    %esp,%ebp
  80065a:	83 ec 18             	sub    $0x18,%esp
  80065d:	8b 45 08             	mov    0x8(%ebp),%eax
  800660:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800663:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800666:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80066a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80066d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800674:	85 c0                	test   %eax,%eax
  800676:	74 26                	je     80069e <vsnprintf+0x47>
  800678:	85 d2                	test   %edx,%edx
  80067a:	7e 22                	jle    80069e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80067c:	ff 75 14             	pushl  0x14(%ebp)
  80067f:	ff 75 10             	pushl  0x10(%ebp)
  800682:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800685:	50                   	push   %eax
  800686:	68 70 02 80 00       	push   $0x800270
  80068b:	e8 1a fc ff ff       	call   8002aa <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800690:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800693:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800696:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800699:	83 c4 10             	add    $0x10,%esp
  80069c:	eb 05                	jmp    8006a3 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80069e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006a3:	c9                   	leave  
  8006a4:	c3                   	ret    

008006a5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006a5:	55                   	push   %ebp
  8006a6:	89 e5                	mov    %esp,%ebp
  8006a8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006ab:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006ae:	50                   	push   %eax
  8006af:	ff 75 10             	pushl  0x10(%ebp)
  8006b2:	ff 75 0c             	pushl  0xc(%ebp)
  8006b5:	ff 75 08             	pushl  0x8(%ebp)
  8006b8:	e8 9a ff ff ff       	call   800657 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006bd:	c9                   	leave  
  8006be:	c3                   	ret    

008006bf <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006bf:	55                   	push   %ebp
  8006c0:	89 e5                	mov    %esp,%ebp
  8006c2:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8006ca:	eb 03                	jmp    8006cf <strlen+0x10>
		n++;
  8006cc:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006cf:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006d3:	75 f7                	jne    8006cc <strlen+0xd>
		n++;
	return n;
}
  8006d5:	5d                   	pop    %ebp
  8006d6:	c3                   	ret    

008006d7 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006d7:	55                   	push   %ebp
  8006d8:	89 e5                	mov    %esp,%ebp
  8006da:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006dd:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8006e5:	eb 03                	jmp    8006ea <strnlen+0x13>
		n++;
  8006e7:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006ea:	39 c2                	cmp    %eax,%edx
  8006ec:	74 08                	je     8006f6 <strnlen+0x1f>
  8006ee:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8006f2:	75 f3                	jne    8006e7 <strnlen+0x10>
  8006f4:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8006f6:	5d                   	pop    %ebp
  8006f7:	c3                   	ret    

008006f8 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006f8:	55                   	push   %ebp
  8006f9:	89 e5                	mov    %esp,%ebp
  8006fb:	53                   	push   %ebx
  8006fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800702:	89 c2                	mov    %eax,%edx
  800704:	83 c2 01             	add    $0x1,%edx
  800707:	83 c1 01             	add    $0x1,%ecx
  80070a:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80070e:	88 5a ff             	mov    %bl,-0x1(%edx)
  800711:	84 db                	test   %bl,%bl
  800713:	75 ef                	jne    800704 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800715:	5b                   	pop    %ebx
  800716:	5d                   	pop    %ebp
  800717:	c3                   	ret    

00800718 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800718:	55                   	push   %ebp
  800719:	89 e5                	mov    %esp,%ebp
  80071b:	53                   	push   %ebx
  80071c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80071f:	53                   	push   %ebx
  800720:	e8 9a ff ff ff       	call   8006bf <strlen>
  800725:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800728:	ff 75 0c             	pushl  0xc(%ebp)
  80072b:	01 d8                	add    %ebx,%eax
  80072d:	50                   	push   %eax
  80072e:	e8 c5 ff ff ff       	call   8006f8 <strcpy>
	return dst;
}
  800733:	89 d8                	mov    %ebx,%eax
  800735:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800738:	c9                   	leave  
  800739:	c3                   	ret    

0080073a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80073a:	55                   	push   %ebp
  80073b:	89 e5                	mov    %esp,%ebp
  80073d:	56                   	push   %esi
  80073e:	53                   	push   %ebx
  80073f:	8b 75 08             	mov    0x8(%ebp),%esi
  800742:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800745:	89 f3                	mov    %esi,%ebx
  800747:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80074a:	89 f2                	mov    %esi,%edx
  80074c:	eb 0f                	jmp    80075d <strncpy+0x23>
		*dst++ = *src;
  80074e:	83 c2 01             	add    $0x1,%edx
  800751:	0f b6 01             	movzbl (%ecx),%eax
  800754:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800757:	80 39 01             	cmpb   $0x1,(%ecx)
  80075a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80075d:	39 da                	cmp    %ebx,%edx
  80075f:	75 ed                	jne    80074e <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800761:	89 f0                	mov    %esi,%eax
  800763:	5b                   	pop    %ebx
  800764:	5e                   	pop    %esi
  800765:	5d                   	pop    %ebp
  800766:	c3                   	ret    

00800767 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800767:	55                   	push   %ebp
  800768:	89 e5                	mov    %esp,%ebp
  80076a:	56                   	push   %esi
  80076b:	53                   	push   %ebx
  80076c:	8b 75 08             	mov    0x8(%ebp),%esi
  80076f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800772:	8b 55 10             	mov    0x10(%ebp),%edx
  800775:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800777:	85 d2                	test   %edx,%edx
  800779:	74 21                	je     80079c <strlcpy+0x35>
  80077b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80077f:	89 f2                	mov    %esi,%edx
  800781:	eb 09                	jmp    80078c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800783:	83 c2 01             	add    $0x1,%edx
  800786:	83 c1 01             	add    $0x1,%ecx
  800789:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80078c:	39 c2                	cmp    %eax,%edx
  80078e:	74 09                	je     800799 <strlcpy+0x32>
  800790:	0f b6 19             	movzbl (%ecx),%ebx
  800793:	84 db                	test   %bl,%bl
  800795:	75 ec                	jne    800783 <strlcpy+0x1c>
  800797:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800799:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80079c:	29 f0                	sub    %esi,%eax
}
  80079e:	5b                   	pop    %ebx
  80079f:	5e                   	pop    %esi
  8007a0:	5d                   	pop    %ebp
  8007a1:	c3                   	ret    

008007a2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007a2:	55                   	push   %ebp
  8007a3:	89 e5                	mov    %esp,%ebp
  8007a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007a8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007ab:	eb 06                	jmp    8007b3 <strcmp+0x11>
		p++, q++;
  8007ad:	83 c1 01             	add    $0x1,%ecx
  8007b0:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007b3:	0f b6 01             	movzbl (%ecx),%eax
  8007b6:	84 c0                	test   %al,%al
  8007b8:	74 04                	je     8007be <strcmp+0x1c>
  8007ba:	3a 02                	cmp    (%edx),%al
  8007bc:	74 ef                	je     8007ad <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007be:	0f b6 c0             	movzbl %al,%eax
  8007c1:	0f b6 12             	movzbl (%edx),%edx
  8007c4:	29 d0                	sub    %edx,%eax
}
  8007c6:	5d                   	pop    %ebp
  8007c7:	c3                   	ret    

008007c8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007c8:	55                   	push   %ebp
  8007c9:	89 e5                	mov    %esp,%ebp
  8007cb:	53                   	push   %ebx
  8007cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007cf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d2:	89 c3                	mov    %eax,%ebx
  8007d4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007d7:	eb 06                	jmp    8007df <strncmp+0x17>
		n--, p++, q++;
  8007d9:	83 c0 01             	add    $0x1,%eax
  8007dc:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007df:	39 d8                	cmp    %ebx,%eax
  8007e1:	74 15                	je     8007f8 <strncmp+0x30>
  8007e3:	0f b6 08             	movzbl (%eax),%ecx
  8007e6:	84 c9                	test   %cl,%cl
  8007e8:	74 04                	je     8007ee <strncmp+0x26>
  8007ea:	3a 0a                	cmp    (%edx),%cl
  8007ec:	74 eb                	je     8007d9 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007ee:	0f b6 00             	movzbl (%eax),%eax
  8007f1:	0f b6 12             	movzbl (%edx),%edx
  8007f4:	29 d0                	sub    %edx,%eax
  8007f6:	eb 05                	jmp    8007fd <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8007f8:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8007fd:	5b                   	pop    %ebx
  8007fe:	5d                   	pop    %ebp
  8007ff:	c3                   	ret    

00800800 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
  800803:	8b 45 08             	mov    0x8(%ebp),%eax
  800806:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80080a:	eb 07                	jmp    800813 <strchr+0x13>
		if (*s == c)
  80080c:	38 ca                	cmp    %cl,%dl
  80080e:	74 0f                	je     80081f <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800810:	83 c0 01             	add    $0x1,%eax
  800813:	0f b6 10             	movzbl (%eax),%edx
  800816:	84 d2                	test   %dl,%dl
  800818:	75 f2                	jne    80080c <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80081a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80081f:	5d                   	pop    %ebp
  800820:	c3                   	ret    

00800821 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800821:	55                   	push   %ebp
  800822:	89 e5                	mov    %esp,%ebp
  800824:	8b 45 08             	mov    0x8(%ebp),%eax
  800827:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80082b:	eb 03                	jmp    800830 <strfind+0xf>
  80082d:	83 c0 01             	add    $0x1,%eax
  800830:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800833:	38 ca                	cmp    %cl,%dl
  800835:	74 04                	je     80083b <strfind+0x1a>
  800837:	84 d2                	test   %dl,%dl
  800839:	75 f2                	jne    80082d <strfind+0xc>
			break;
	return (char *) s;
}
  80083b:	5d                   	pop    %ebp
  80083c:	c3                   	ret    

0080083d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80083d:	55                   	push   %ebp
  80083e:	89 e5                	mov    %esp,%ebp
  800840:	57                   	push   %edi
  800841:	56                   	push   %esi
  800842:	53                   	push   %ebx
  800843:	8b 7d 08             	mov    0x8(%ebp),%edi
  800846:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800849:	85 c9                	test   %ecx,%ecx
  80084b:	74 36                	je     800883 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80084d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800853:	75 28                	jne    80087d <memset+0x40>
  800855:	f6 c1 03             	test   $0x3,%cl
  800858:	75 23                	jne    80087d <memset+0x40>
		c &= 0xFF;
  80085a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80085e:	89 d3                	mov    %edx,%ebx
  800860:	c1 e3 08             	shl    $0x8,%ebx
  800863:	89 d6                	mov    %edx,%esi
  800865:	c1 e6 18             	shl    $0x18,%esi
  800868:	89 d0                	mov    %edx,%eax
  80086a:	c1 e0 10             	shl    $0x10,%eax
  80086d:	09 f0                	or     %esi,%eax
  80086f:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800871:	89 d8                	mov    %ebx,%eax
  800873:	09 d0                	or     %edx,%eax
  800875:	c1 e9 02             	shr    $0x2,%ecx
  800878:	fc                   	cld    
  800879:	f3 ab                	rep stos %eax,%es:(%edi)
  80087b:	eb 06                	jmp    800883 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80087d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800880:	fc                   	cld    
  800881:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800883:	89 f8                	mov    %edi,%eax
  800885:	5b                   	pop    %ebx
  800886:	5e                   	pop    %esi
  800887:	5f                   	pop    %edi
  800888:	5d                   	pop    %ebp
  800889:	c3                   	ret    

0080088a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80088a:	55                   	push   %ebp
  80088b:	89 e5                	mov    %esp,%ebp
  80088d:	57                   	push   %edi
  80088e:	56                   	push   %esi
  80088f:	8b 45 08             	mov    0x8(%ebp),%eax
  800892:	8b 75 0c             	mov    0xc(%ebp),%esi
  800895:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800898:	39 c6                	cmp    %eax,%esi
  80089a:	73 35                	jae    8008d1 <memmove+0x47>
  80089c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80089f:	39 d0                	cmp    %edx,%eax
  8008a1:	73 2e                	jae    8008d1 <memmove+0x47>
		s += n;
		d += n;
  8008a3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008a6:	89 d6                	mov    %edx,%esi
  8008a8:	09 fe                	or     %edi,%esi
  8008aa:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008b0:	75 13                	jne    8008c5 <memmove+0x3b>
  8008b2:	f6 c1 03             	test   $0x3,%cl
  8008b5:	75 0e                	jne    8008c5 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008b7:	83 ef 04             	sub    $0x4,%edi
  8008ba:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008bd:	c1 e9 02             	shr    $0x2,%ecx
  8008c0:	fd                   	std    
  8008c1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008c3:	eb 09                	jmp    8008ce <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008c5:	83 ef 01             	sub    $0x1,%edi
  8008c8:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008cb:	fd                   	std    
  8008cc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008ce:	fc                   	cld    
  8008cf:	eb 1d                	jmp    8008ee <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008d1:	89 f2                	mov    %esi,%edx
  8008d3:	09 c2                	or     %eax,%edx
  8008d5:	f6 c2 03             	test   $0x3,%dl
  8008d8:	75 0f                	jne    8008e9 <memmove+0x5f>
  8008da:	f6 c1 03             	test   $0x3,%cl
  8008dd:	75 0a                	jne    8008e9 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8008df:	c1 e9 02             	shr    $0x2,%ecx
  8008e2:	89 c7                	mov    %eax,%edi
  8008e4:	fc                   	cld    
  8008e5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008e7:	eb 05                	jmp    8008ee <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008e9:	89 c7                	mov    %eax,%edi
  8008eb:	fc                   	cld    
  8008ec:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008ee:	5e                   	pop    %esi
  8008ef:	5f                   	pop    %edi
  8008f0:	5d                   	pop    %ebp
  8008f1:	c3                   	ret    

008008f2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008f2:	55                   	push   %ebp
  8008f3:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008f5:	ff 75 10             	pushl  0x10(%ebp)
  8008f8:	ff 75 0c             	pushl  0xc(%ebp)
  8008fb:	ff 75 08             	pushl  0x8(%ebp)
  8008fe:	e8 87 ff ff ff       	call   80088a <memmove>
}
  800903:	c9                   	leave  
  800904:	c3                   	ret    

00800905 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800905:	55                   	push   %ebp
  800906:	89 e5                	mov    %esp,%ebp
  800908:	56                   	push   %esi
  800909:	53                   	push   %ebx
  80090a:	8b 45 08             	mov    0x8(%ebp),%eax
  80090d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800910:	89 c6                	mov    %eax,%esi
  800912:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800915:	eb 1a                	jmp    800931 <memcmp+0x2c>
		if (*s1 != *s2)
  800917:	0f b6 08             	movzbl (%eax),%ecx
  80091a:	0f b6 1a             	movzbl (%edx),%ebx
  80091d:	38 d9                	cmp    %bl,%cl
  80091f:	74 0a                	je     80092b <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800921:	0f b6 c1             	movzbl %cl,%eax
  800924:	0f b6 db             	movzbl %bl,%ebx
  800927:	29 d8                	sub    %ebx,%eax
  800929:	eb 0f                	jmp    80093a <memcmp+0x35>
		s1++, s2++;
  80092b:	83 c0 01             	add    $0x1,%eax
  80092e:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800931:	39 f0                	cmp    %esi,%eax
  800933:	75 e2                	jne    800917 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800935:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80093a:	5b                   	pop    %ebx
  80093b:	5e                   	pop    %esi
  80093c:	5d                   	pop    %ebp
  80093d:	c3                   	ret    

0080093e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80093e:	55                   	push   %ebp
  80093f:	89 e5                	mov    %esp,%ebp
  800941:	53                   	push   %ebx
  800942:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800945:	89 c1                	mov    %eax,%ecx
  800947:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80094a:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80094e:	eb 0a                	jmp    80095a <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800950:	0f b6 10             	movzbl (%eax),%edx
  800953:	39 da                	cmp    %ebx,%edx
  800955:	74 07                	je     80095e <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800957:	83 c0 01             	add    $0x1,%eax
  80095a:	39 c8                	cmp    %ecx,%eax
  80095c:	72 f2                	jb     800950 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80095e:	5b                   	pop    %ebx
  80095f:	5d                   	pop    %ebp
  800960:	c3                   	ret    

00800961 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800961:	55                   	push   %ebp
  800962:	89 e5                	mov    %esp,%ebp
  800964:	57                   	push   %edi
  800965:	56                   	push   %esi
  800966:	53                   	push   %ebx
  800967:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80096a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80096d:	eb 03                	jmp    800972 <strtol+0x11>
		s++;
  80096f:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800972:	0f b6 01             	movzbl (%ecx),%eax
  800975:	3c 20                	cmp    $0x20,%al
  800977:	74 f6                	je     80096f <strtol+0xe>
  800979:	3c 09                	cmp    $0x9,%al
  80097b:	74 f2                	je     80096f <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80097d:	3c 2b                	cmp    $0x2b,%al
  80097f:	75 0a                	jne    80098b <strtol+0x2a>
		s++;
  800981:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800984:	bf 00 00 00 00       	mov    $0x0,%edi
  800989:	eb 11                	jmp    80099c <strtol+0x3b>
  80098b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800990:	3c 2d                	cmp    $0x2d,%al
  800992:	75 08                	jne    80099c <strtol+0x3b>
		s++, neg = 1;
  800994:	83 c1 01             	add    $0x1,%ecx
  800997:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80099c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009a2:	75 15                	jne    8009b9 <strtol+0x58>
  8009a4:	80 39 30             	cmpb   $0x30,(%ecx)
  8009a7:	75 10                	jne    8009b9 <strtol+0x58>
  8009a9:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009ad:	75 7c                	jne    800a2b <strtol+0xca>
		s += 2, base = 16;
  8009af:	83 c1 02             	add    $0x2,%ecx
  8009b2:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009b7:	eb 16                	jmp    8009cf <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009b9:	85 db                	test   %ebx,%ebx
  8009bb:	75 12                	jne    8009cf <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009bd:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009c2:	80 39 30             	cmpb   $0x30,(%ecx)
  8009c5:	75 08                	jne    8009cf <strtol+0x6e>
		s++, base = 8;
  8009c7:	83 c1 01             	add    $0x1,%ecx
  8009ca:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8009d4:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009d7:	0f b6 11             	movzbl (%ecx),%edx
  8009da:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009dd:	89 f3                	mov    %esi,%ebx
  8009df:	80 fb 09             	cmp    $0x9,%bl
  8009e2:	77 08                	ja     8009ec <strtol+0x8b>
			dig = *s - '0';
  8009e4:	0f be d2             	movsbl %dl,%edx
  8009e7:	83 ea 30             	sub    $0x30,%edx
  8009ea:	eb 22                	jmp    800a0e <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8009ec:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009ef:	89 f3                	mov    %esi,%ebx
  8009f1:	80 fb 19             	cmp    $0x19,%bl
  8009f4:	77 08                	ja     8009fe <strtol+0x9d>
			dig = *s - 'a' + 10;
  8009f6:	0f be d2             	movsbl %dl,%edx
  8009f9:	83 ea 57             	sub    $0x57,%edx
  8009fc:	eb 10                	jmp    800a0e <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8009fe:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a01:	89 f3                	mov    %esi,%ebx
  800a03:	80 fb 19             	cmp    $0x19,%bl
  800a06:	77 16                	ja     800a1e <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a08:	0f be d2             	movsbl %dl,%edx
  800a0b:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a0e:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a11:	7d 0b                	jge    800a1e <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a13:	83 c1 01             	add    $0x1,%ecx
  800a16:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a1a:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a1c:	eb b9                	jmp    8009d7 <strtol+0x76>

	if (endptr)
  800a1e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a22:	74 0d                	je     800a31 <strtol+0xd0>
		*endptr = (char *) s;
  800a24:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a27:	89 0e                	mov    %ecx,(%esi)
  800a29:	eb 06                	jmp    800a31 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a2b:	85 db                	test   %ebx,%ebx
  800a2d:	74 98                	je     8009c7 <strtol+0x66>
  800a2f:	eb 9e                	jmp    8009cf <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a31:	89 c2                	mov    %eax,%edx
  800a33:	f7 da                	neg    %edx
  800a35:	85 ff                	test   %edi,%edi
  800a37:	0f 45 c2             	cmovne %edx,%eax
}
  800a3a:	5b                   	pop    %ebx
  800a3b:	5e                   	pop    %esi
  800a3c:	5f                   	pop    %edi
  800a3d:	5d                   	pop    %ebp
  800a3e:	c3                   	ret    

00800a3f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a3f:	55                   	push   %ebp
  800a40:	89 e5                	mov    %esp,%ebp
  800a42:	57                   	push   %edi
  800a43:	56                   	push   %esi
  800a44:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a45:	b8 00 00 00 00       	mov    $0x0,%eax
  800a4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a4d:	8b 55 08             	mov    0x8(%ebp),%edx
  800a50:	89 c3                	mov    %eax,%ebx
  800a52:	89 c7                	mov    %eax,%edi
  800a54:	89 c6                	mov    %eax,%esi
  800a56:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a58:	5b                   	pop    %ebx
  800a59:	5e                   	pop    %esi
  800a5a:	5f                   	pop    %edi
  800a5b:	5d                   	pop    %ebp
  800a5c:	c3                   	ret    

00800a5d <sys_cgetc>:

int
sys_cgetc(void)
{
  800a5d:	55                   	push   %ebp
  800a5e:	89 e5                	mov    %esp,%ebp
  800a60:	57                   	push   %edi
  800a61:	56                   	push   %esi
  800a62:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a63:	ba 00 00 00 00       	mov    $0x0,%edx
  800a68:	b8 01 00 00 00       	mov    $0x1,%eax
  800a6d:	89 d1                	mov    %edx,%ecx
  800a6f:	89 d3                	mov    %edx,%ebx
  800a71:	89 d7                	mov    %edx,%edi
  800a73:	89 d6                	mov    %edx,%esi
  800a75:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a77:	5b                   	pop    %ebx
  800a78:	5e                   	pop    %esi
  800a79:	5f                   	pop    %edi
  800a7a:	5d                   	pop    %ebp
  800a7b:	c3                   	ret    

00800a7c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a7c:	55                   	push   %ebp
  800a7d:	89 e5                	mov    %esp,%ebp
  800a7f:	57                   	push   %edi
  800a80:	56                   	push   %esi
  800a81:	53                   	push   %ebx
  800a82:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a85:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a8a:	b8 03 00 00 00       	mov    $0x3,%eax
  800a8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800a92:	89 cb                	mov    %ecx,%ebx
  800a94:	89 cf                	mov    %ecx,%edi
  800a96:	89 ce                	mov    %ecx,%esi
  800a98:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800a9a:	85 c0                	test   %eax,%eax
  800a9c:	7e 17                	jle    800ab5 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a9e:	83 ec 0c             	sub    $0xc,%esp
  800aa1:	50                   	push   %eax
  800aa2:	6a 03                	push   $0x3
  800aa4:	68 3f 26 80 00       	push   $0x80263f
  800aa9:	6a 23                	push   $0x23
  800aab:	68 5c 26 80 00       	push   $0x80265c
  800ab0:	e8 46 14 00 00       	call   801efb <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ab5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ab8:	5b                   	pop    %ebx
  800ab9:	5e                   	pop    %esi
  800aba:	5f                   	pop    %edi
  800abb:	5d                   	pop    %ebp
  800abc:	c3                   	ret    

00800abd <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800abd:	55                   	push   %ebp
  800abe:	89 e5                	mov    %esp,%ebp
  800ac0:	57                   	push   %edi
  800ac1:	56                   	push   %esi
  800ac2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac8:	b8 02 00 00 00       	mov    $0x2,%eax
  800acd:	89 d1                	mov    %edx,%ecx
  800acf:	89 d3                	mov    %edx,%ebx
  800ad1:	89 d7                	mov    %edx,%edi
  800ad3:	89 d6                	mov    %edx,%esi
  800ad5:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ad7:	5b                   	pop    %ebx
  800ad8:	5e                   	pop    %esi
  800ad9:	5f                   	pop    %edi
  800ada:	5d                   	pop    %ebp
  800adb:	c3                   	ret    

00800adc <sys_yield>:

void
sys_yield(void)
{
  800adc:	55                   	push   %ebp
  800add:	89 e5                	mov    %esp,%ebp
  800adf:	57                   	push   %edi
  800ae0:	56                   	push   %esi
  800ae1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae7:	b8 0b 00 00 00       	mov    $0xb,%eax
  800aec:	89 d1                	mov    %edx,%ecx
  800aee:	89 d3                	mov    %edx,%ebx
  800af0:	89 d7                	mov    %edx,%edi
  800af2:	89 d6                	mov    %edx,%esi
  800af4:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800af6:	5b                   	pop    %ebx
  800af7:	5e                   	pop    %esi
  800af8:	5f                   	pop    %edi
  800af9:	5d                   	pop    %ebp
  800afa:	c3                   	ret    

00800afb <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800afb:	55                   	push   %ebp
  800afc:	89 e5                	mov    %esp,%ebp
  800afe:	57                   	push   %edi
  800aff:	56                   	push   %esi
  800b00:	53                   	push   %ebx
  800b01:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b04:	be 00 00 00 00       	mov    $0x0,%esi
  800b09:	b8 04 00 00 00       	mov    $0x4,%eax
  800b0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b11:	8b 55 08             	mov    0x8(%ebp),%edx
  800b14:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b17:	89 f7                	mov    %esi,%edi
  800b19:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b1b:	85 c0                	test   %eax,%eax
  800b1d:	7e 17                	jle    800b36 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b1f:	83 ec 0c             	sub    $0xc,%esp
  800b22:	50                   	push   %eax
  800b23:	6a 04                	push   $0x4
  800b25:	68 3f 26 80 00       	push   $0x80263f
  800b2a:	6a 23                	push   $0x23
  800b2c:	68 5c 26 80 00       	push   $0x80265c
  800b31:	e8 c5 13 00 00       	call   801efb <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b39:	5b                   	pop    %ebx
  800b3a:	5e                   	pop    %esi
  800b3b:	5f                   	pop    %edi
  800b3c:	5d                   	pop    %ebp
  800b3d:	c3                   	ret    

00800b3e <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b3e:	55                   	push   %ebp
  800b3f:	89 e5                	mov    %esp,%ebp
  800b41:	57                   	push   %edi
  800b42:	56                   	push   %esi
  800b43:	53                   	push   %ebx
  800b44:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b47:	b8 05 00 00 00       	mov    $0x5,%eax
  800b4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b52:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b55:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b58:	8b 75 18             	mov    0x18(%ebp),%esi
  800b5b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b5d:	85 c0                	test   %eax,%eax
  800b5f:	7e 17                	jle    800b78 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b61:	83 ec 0c             	sub    $0xc,%esp
  800b64:	50                   	push   %eax
  800b65:	6a 05                	push   $0x5
  800b67:	68 3f 26 80 00       	push   $0x80263f
  800b6c:	6a 23                	push   $0x23
  800b6e:	68 5c 26 80 00       	push   $0x80265c
  800b73:	e8 83 13 00 00       	call   801efb <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b78:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b7b:	5b                   	pop    %ebx
  800b7c:	5e                   	pop    %esi
  800b7d:	5f                   	pop    %edi
  800b7e:	5d                   	pop    %ebp
  800b7f:	c3                   	ret    

00800b80 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b80:	55                   	push   %ebp
  800b81:	89 e5                	mov    %esp,%ebp
  800b83:	57                   	push   %edi
  800b84:	56                   	push   %esi
  800b85:	53                   	push   %ebx
  800b86:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b89:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b8e:	b8 06 00 00 00       	mov    $0x6,%eax
  800b93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b96:	8b 55 08             	mov    0x8(%ebp),%edx
  800b99:	89 df                	mov    %ebx,%edi
  800b9b:	89 de                	mov    %ebx,%esi
  800b9d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b9f:	85 c0                	test   %eax,%eax
  800ba1:	7e 17                	jle    800bba <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba3:	83 ec 0c             	sub    $0xc,%esp
  800ba6:	50                   	push   %eax
  800ba7:	6a 06                	push   $0x6
  800ba9:	68 3f 26 80 00       	push   $0x80263f
  800bae:	6a 23                	push   $0x23
  800bb0:	68 5c 26 80 00       	push   $0x80265c
  800bb5:	e8 41 13 00 00       	call   801efb <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bbd:	5b                   	pop    %ebx
  800bbe:	5e                   	pop    %esi
  800bbf:	5f                   	pop    %edi
  800bc0:	5d                   	pop    %ebp
  800bc1:	c3                   	ret    

00800bc2 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bc2:	55                   	push   %ebp
  800bc3:	89 e5                	mov    %esp,%ebp
  800bc5:	57                   	push   %edi
  800bc6:	56                   	push   %esi
  800bc7:	53                   	push   %ebx
  800bc8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bcb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bd0:	b8 08 00 00 00       	mov    $0x8,%eax
  800bd5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bdb:	89 df                	mov    %ebx,%edi
  800bdd:	89 de                	mov    %ebx,%esi
  800bdf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800be1:	85 c0                	test   %eax,%eax
  800be3:	7e 17                	jle    800bfc <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be5:	83 ec 0c             	sub    $0xc,%esp
  800be8:	50                   	push   %eax
  800be9:	6a 08                	push   $0x8
  800beb:	68 3f 26 80 00       	push   $0x80263f
  800bf0:	6a 23                	push   $0x23
  800bf2:	68 5c 26 80 00       	push   $0x80265c
  800bf7:	e8 ff 12 00 00       	call   801efb <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800bfc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bff:	5b                   	pop    %ebx
  800c00:	5e                   	pop    %esi
  800c01:	5f                   	pop    %edi
  800c02:	5d                   	pop    %ebp
  800c03:	c3                   	ret    

00800c04 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c04:	55                   	push   %ebp
  800c05:	89 e5                	mov    %esp,%ebp
  800c07:	57                   	push   %edi
  800c08:	56                   	push   %esi
  800c09:	53                   	push   %ebx
  800c0a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c12:	b8 09 00 00 00       	mov    $0x9,%eax
  800c17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1d:	89 df                	mov    %ebx,%edi
  800c1f:	89 de                	mov    %ebx,%esi
  800c21:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c23:	85 c0                	test   %eax,%eax
  800c25:	7e 17                	jle    800c3e <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c27:	83 ec 0c             	sub    $0xc,%esp
  800c2a:	50                   	push   %eax
  800c2b:	6a 09                	push   $0x9
  800c2d:	68 3f 26 80 00       	push   $0x80263f
  800c32:	6a 23                	push   $0x23
  800c34:	68 5c 26 80 00       	push   $0x80265c
  800c39:	e8 bd 12 00 00       	call   801efb <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c41:	5b                   	pop    %ebx
  800c42:	5e                   	pop    %esi
  800c43:	5f                   	pop    %edi
  800c44:	5d                   	pop    %ebp
  800c45:	c3                   	ret    

00800c46 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c46:	55                   	push   %ebp
  800c47:	89 e5                	mov    %esp,%ebp
  800c49:	57                   	push   %edi
  800c4a:	56                   	push   %esi
  800c4b:	53                   	push   %ebx
  800c4c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c54:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5f:	89 df                	mov    %ebx,%edi
  800c61:	89 de                	mov    %ebx,%esi
  800c63:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c65:	85 c0                	test   %eax,%eax
  800c67:	7e 17                	jle    800c80 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c69:	83 ec 0c             	sub    $0xc,%esp
  800c6c:	50                   	push   %eax
  800c6d:	6a 0a                	push   $0xa
  800c6f:	68 3f 26 80 00       	push   $0x80263f
  800c74:	6a 23                	push   $0x23
  800c76:	68 5c 26 80 00       	push   $0x80265c
  800c7b:	e8 7b 12 00 00       	call   801efb <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c83:	5b                   	pop    %ebx
  800c84:	5e                   	pop    %esi
  800c85:	5f                   	pop    %edi
  800c86:	5d                   	pop    %ebp
  800c87:	c3                   	ret    

00800c88 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c88:	55                   	push   %ebp
  800c89:	89 e5                	mov    %esp,%ebp
  800c8b:	57                   	push   %edi
  800c8c:	56                   	push   %esi
  800c8d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8e:	be 00 00 00 00       	mov    $0x0,%esi
  800c93:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ca1:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ca4:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ca6:	5b                   	pop    %ebx
  800ca7:	5e                   	pop    %esi
  800ca8:	5f                   	pop    %edi
  800ca9:	5d                   	pop    %ebp
  800caa:	c3                   	ret    

00800cab <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cab:	55                   	push   %ebp
  800cac:	89 e5                	mov    %esp,%ebp
  800cae:	57                   	push   %edi
  800caf:	56                   	push   %esi
  800cb0:	53                   	push   %ebx
  800cb1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cb9:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc1:	89 cb                	mov    %ecx,%ebx
  800cc3:	89 cf                	mov    %ecx,%edi
  800cc5:	89 ce                	mov    %ecx,%esi
  800cc7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cc9:	85 c0                	test   %eax,%eax
  800ccb:	7e 17                	jle    800ce4 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ccd:	83 ec 0c             	sub    $0xc,%esp
  800cd0:	50                   	push   %eax
  800cd1:	6a 0d                	push   $0xd
  800cd3:	68 3f 26 80 00       	push   $0x80263f
  800cd8:	6a 23                	push   $0x23
  800cda:	68 5c 26 80 00       	push   $0x80265c
  800cdf:	e8 17 12 00 00       	call   801efb <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ce4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce7:	5b                   	pop    %ebx
  800ce8:	5e                   	pop    %esi
  800ce9:	5f                   	pop    %edi
  800cea:	5d                   	pop    %ebp
  800ceb:	c3                   	ret    

00800cec <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800cec:	55                   	push   %ebp
  800ced:	89 e5                	mov    %esp,%ebp
  800cef:	57                   	push   %edi
  800cf0:	56                   	push   %esi
  800cf1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf2:	ba 00 00 00 00       	mov    $0x0,%edx
  800cf7:	b8 0e 00 00 00       	mov    $0xe,%eax
  800cfc:	89 d1                	mov    %edx,%ecx
  800cfe:	89 d3                	mov    %edx,%ebx
  800d00:	89 d7                	mov    %edx,%edi
  800d02:	89 d6                	mov    %edx,%esi
  800d04:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d06:	5b                   	pop    %ebx
  800d07:	5e                   	pop    %esi
  800d08:	5f                   	pop    %edi
  800d09:	5d                   	pop    %ebp
  800d0a:	c3                   	ret    

00800d0b <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d0b:	55                   	push   %ebp
  800d0c:	89 e5                	mov    %esp,%ebp
  800d0e:	53                   	push   %ebx
  800d0f:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  800d12:	83 3d 0c 40 80 00 00 	cmpl   $0x0,0x80400c
  800d19:	75 28                	jne    800d43 <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  800d1b:	e8 9d fd ff ff       	call   800abd <sys_getenvid>
  800d20:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_U | PTE_W);
  800d22:	83 ec 04             	sub    $0x4,%esp
  800d25:	6a 06                	push   $0x6
  800d27:	68 00 f0 bf ee       	push   $0xeebff000
  800d2c:	50                   	push   %eax
  800d2d:	e8 c9 fd ff ff       	call   800afb <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  800d32:	83 c4 08             	add    $0x8,%esp
  800d35:	68 50 0d 80 00       	push   $0x800d50
  800d3a:	53                   	push   %ebx
  800d3b:	e8 06 ff ff ff       	call   800c46 <sys_env_set_pgfault_upcall>
  800d40:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800d43:	8b 45 08             	mov    0x8(%ebp),%eax
  800d46:	a3 0c 40 80 00       	mov    %eax,0x80400c
}
  800d4b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d4e:	c9                   	leave  
  800d4f:	c3                   	ret    

00800d50 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800d50:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800d51:	a1 0c 40 80 00       	mov    0x80400c,%eax
	call *%eax
  800d56:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800d58:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	# My method is different. Copy the values to the other stack
	# in a convinient way, and then pop everything.
	movl %esp, %ebp		# ebp refers to the exception stack
  800d5b:	89 e5                	mov    %esp,%ebp
	movl 48(%ebp), %esp 	# go to other stack
  800d5d:	8b 65 30             	mov    0x30(%ebp),%esp

	pushl 40(%ebp)		# eip - ORDER SWITCHED WITH EFLAGS
  800d60:	ff 75 28             	pushl  0x28(%ebp)
	pushl 44(%ebp)      	# eflags
  800d63:	ff 75 2c             	pushl  0x2c(%ebp)
	pushl 36(%ebp)		# all the 8 remaining regs
  800d66:	ff 75 24             	pushl  0x24(%ebp)
	pushl 32(%ebp)
  800d69:	ff 75 20             	pushl  0x20(%ebp)
	pushl 28(%ebp)
  800d6c:	ff 75 1c             	pushl  0x1c(%ebp)
	pushl 24(%ebp)
  800d6f:	ff 75 18             	pushl  0x18(%ebp)
	pushl 20(%ebp)
  800d72:	ff 75 14             	pushl  0x14(%ebp)
	pushl 16(%ebp)
  800d75:	ff 75 10             	pushl  0x10(%ebp)
	pushl 12(%ebp)
  800d78:	ff 75 0c             	pushl  0xc(%ebp)
	pushl 8(%ebp)
  800d7b:	ff 75 08             	pushl  0x8(%ebp)

	popal			# now just pop everything!
  800d7e:	61                   	popa   
	popfl
  800d7f:	9d                   	popf   
	ret
  800d80:	c3                   	ret    

00800d81 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d81:	55                   	push   %ebp
  800d82:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d84:	8b 45 08             	mov    0x8(%ebp),%eax
  800d87:	05 00 00 00 30       	add    $0x30000000,%eax
  800d8c:	c1 e8 0c             	shr    $0xc,%eax
}
  800d8f:	5d                   	pop    %ebp
  800d90:	c3                   	ret    

00800d91 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d91:	55                   	push   %ebp
  800d92:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d94:	8b 45 08             	mov    0x8(%ebp),%eax
  800d97:	05 00 00 00 30       	add    $0x30000000,%eax
  800d9c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800da1:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800da6:	5d                   	pop    %ebp
  800da7:	c3                   	ret    

00800da8 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800da8:	55                   	push   %ebp
  800da9:	89 e5                	mov    %esp,%ebp
  800dab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dae:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800db3:	89 c2                	mov    %eax,%edx
  800db5:	c1 ea 16             	shr    $0x16,%edx
  800db8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800dbf:	f6 c2 01             	test   $0x1,%dl
  800dc2:	74 11                	je     800dd5 <fd_alloc+0x2d>
  800dc4:	89 c2                	mov    %eax,%edx
  800dc6:	c1 ea 0c             	shr    $0xc,%edx
  800dc9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dd0:	f6 c2 01             	test   $0x1,%dl
  800dd3:	75 09                	jne    800dde <fd_alloc+0x36>
			*fd_store = fd;
  800dd5:	89 01                	mov    %eax,(%ecx)
			return 0;
  800dd7:	b8 00 00 00 00       	mov    $0x0,%eax
  800ddc:	eb 17                	jmp    800df5 <fd_alloc+0x4d>
  800dde:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800de3:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800de8:	75 c9                	jne    800db3 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800dea:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800df0:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800df5:	5d                   	pop    %ebp
  800df6:	c3                   	ret    

00800df7 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800df7:	55                   	push   %ebp
  800df8:	89 e5                	mov    %esp,%ebp
  800dfa:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800dfd:	83 f8 1f             	cmp    $0x1f,%eax
  800e00:	77 36                	ja     800e38 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e02:	c1 e0 0c             	shl    $0xc,%eax
  800e05:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e0a:	89 c2                	mov    %eax,%edx
  800e0c:	c1 ea 16             	shr    $0x16,%edx
  800e0f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e16:	f6 c2 01             	test   $0x1,%dl
  800e19:	74 24                	je     800e3f <fd_lookup+0x48>
  800e1b:	89 c2                	mov    %eax,%edx
  800e1d:	c1 ea 0c             	shr    $0xc,%edx
  800e20:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e27:	f6 c2 01             	test   $0x1,%dl
  800e2a:	74 1a                	je     800e46 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e2c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e2f:	89 02                	mov    %eax,(%edx)
	return 0;
  800e31:	b8 00 00 00 00       	mov    $0x0,%eax
  800e36:	eb 13                	jmp    800e4b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e38:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e3d:	eb 0c                	jmp    800e4b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e3f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e44:	eb 05                	jmp    800e4b <fd_lookup+0x54>
  800e46:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e4b:	5d                   	pop    %ebp
  800e4c:	c3                   	ret    

00800e4d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e4d:	55                   	push   %ebp
  800e4e:	89 e5                	mov    %esp,%ebp
  800e50:	83 ec 08             	sub    $0x8,%esp
  800e53:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e56:	ba e8 26 80 00       	mov    $0x8026e8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e5b:	eb 13                	jmp    800e70 <dev_lookup+0x23>
  800e5d:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800e60:	39 08                	cmp    %ecx,(%eax)
  800e62:	75 0c                	jne    800e70 <dev_lookup+0x23>
			*dev = devtab[i];
  800e64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e67:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e69:	b8 00 00 00 00       	mov    $0x0,%eax
  800e6e:	eb 2e                	jmp    800e9e <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e70:	8b 02                	mov    (%edx),%eax
  800e72:	85 c0                	test   %eax,%eax
  800e74:	75 e7                	jne    800e5d <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e76:	a1 08 40 80 00       	mov    0x804008,%eax
  800e7b:	8b 40 48             	mov    0x48(%eax),%eax
  800e7e:	83 ec 04             	sub    $0x4,%esp
  800e81:	51                   	push   %ecx
  800e82:	50                   	push   %eax
  800e83:	68 6c 26 80 00       	push   $0x80266c
  800e88:	e8 e6 f2 ff ff       	call   800173 <cprintf>
	*dev = 0;
  800e8d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e90:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e96:	83 c4 10             	add    $0x10,%esp
  800e99:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e9e:	c9                   	leave  
  800e9f:	c3                   	ret    

00800ea0 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800ea0:	55                   	push   %ebp
  800ea1:	89 e5                	mov    %esp,%ebp
  800ea3:	56                   	push   %esi
  800ea4:	53                   	push   %ebx
  800ea5:	83 ec 10             	sub    $0x10,%esp
  800ea8:	8b 75 08             	mov    0x8(%ebp),%esi
  800eab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800eae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800eb1:	50                   	push   %eax
  800eb2:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800eb8:	c1 e8 0c             	shr    $0xc,%eax
  800ebb:	50                   	push   %eax
  800ebc:	e8 36 ff ff ff       	call   800df7 <fd_lookup>
  800ec1:	83 c4 08             	add    $0x8,%esp
  800ec4:	85 c0                	test   %eax,%eax
  800ec6:	78 05                	js     800ecd <fd_close+0x2d>
	    || fd != fd2)
  800ec8:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800ecb:	74 0c                	je     800ed9 <fd_close+0x39>
		return (must_exist ? r : 0);
  800ecd:	84 db                	test   %bl,%bl
  800ecf:	ba 00 00 00 00       	mov    $0x0,%edx
  800ed4:	0f 44 c2             	cmove  %edx,%eax
  800ed7:	eb 41                	jmp    800f1a <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ed9:	83 ec 08             	sub    $0x8,%esp
  800edc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800edf:	50                   	push   %eax
  800ee0:	ff 36                	pushl  (%esi)
  800ee2:	e8 66 ff ff ff       	call   800e4d <dev_lookup>
  800ee7:	89 c3                	mov    %eax,%ebx
  800ee9:	83 c4 10             	add    $0x10,%esp
  800eec:	85 c0                	test   %eax,%eax
  800eee:	78 1a                	js     800f0a <fd_close+0x6a>
		if (dev->dev_close)
  800ef0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ef3:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800ef6:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800efb:	85 c0                	test   %eax,%eax
  800efd:	74 0b                	je     800f0a <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800eff:	83 ec 0c             	sub    $0xc,%esp
  800f02:	56                   	push   %esi
  800f03:	ff d0                	call   *%eax
  800f05:	89 c3                	mov    %eax,%ebx
  800f07:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f0a:	83 ec 08             	sub    $0x8,%esp
  800f0d:	56                   	push   %esi
  800f0e:	6a 00                	push   $0x0
  800f10:	e8 6b fc ff ff       	call   800b80 <sys_page_unmap>
	return r;
  800f15:	83 c4 10             	add    $0x10,%esp
  800f18:	89 d8                	mov    %ebx,%eax
}
  800f1a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f1d:	5b                   	pop    %ebx
  800f1e:	5e                   	pop    %esi
  800f1f:	5d                   	pop    %ebp
  800f20:	c3                   	ret    

00800f21 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f21:	55                   	push   %ebp
  800f22:	89 e5                	mov    %esp,%ebp
  800f24:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f27:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f2a:	50                   	push   %eax
  800f2b:	ff 75 08             	pushl  0x8(%ebp)
  800f2e:	e8 c4 fe ff ff       	call   800df7 <fd_lookup>
  800f33:	83 c4 08             	add    $0x8,%esp
  800f36:	85 c0                	test   %eax,%eax
  800f38:	78 10                	js     800f4a <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f3a:	83 ec 08             	sub    $0x8,%esp
  800f3d:	6a 01                	push   $0x1
  800f3f:	ff 75 f4             	pushl  -0xc(%ebp)
  800f42:	e8 59 ff ff ff       	call   800ea0 <fd_close>
  800f47:	83 c4 10             	add    $0x10,%esp
}
  800f4a:	c9                   	leave  
  800f4b:	c3                   	ret    

00800f4c <close_all>:

void
close_all(void)
{
  800f4c:	55                   	push   %ebp
  800f4d:	89 e5                	mov    %esp,%ebp
  800f4f:	53                   	push   %ebx
  800f50:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f53:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f58:	83 ec 0c             	sub    $0xc,%esp
  800f5b:	53                   	push   %ebx
  800f5c:	e8 c0 ff ff ff       	call   800f21 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f61:	83 c3 01             	add    $0x1,%ebx
  800f64:	83 c4 10             	add    $0x10,%esp
  800f67:	83 fb 20             	cmp    $0x20,%ebx
  800f6a:	75 ec                	jne    800f58 <close_all+0xc>
		close(i);
}
  800f6c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f6f:	c9                   	leave  
  800f70:	c3                   	ret    

00800f71 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f71:	55                   	push   %ebp
  800f72:	89 e5                	mov    %esp,%ebp
  800f74:	57                   	push   %edi
  800f75:	56                   	push   %esi
  800f76:	53                   	push   %ebx
  800f77:	83 ec 2c             	sub    $0x2c,%esp
  800f7a:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f7d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f80:	50                   	push   %eax
  800f81:	ff 75 08             	pushl  0x8(%ebp)
  800f84:	e8 6e fe ff ff       	call   800df7 <fd_lookup>
  800f89:	83 c4 08             	add    $0x8,%esp
  800f8c:	85 c0                	test   %eax,%eax
  800f8e:	0f 88 c1 00 00 00    	js     801055 <dup+0xe4>
		return r;
	close(newfdnum);
  800f94:	83 ec 0c             	sub    $0xc,%esp
  800f97:	56                   	push   %esi
  800f98:	e8 84 ff ff ff       	call   800f21 <close>

	newfd = INDEX2FD(newfdnum);
  800f9d:	89 f3                	mov    %esi,%ebx
  800f9f:	c1 e3 0c             	shl    $0xc,%ebx
  800fa2:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800fa8:	83 c4 04             	add    $0x4,%esp
  800fab:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fae:	e8 de fd ff ff       	call   800d91 <fd2data>
  800fb3:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800fb5:	89 1c 24             	mov    %ebx,(%esp)
  800fb8:	e8 d4 fd ff ff       	call   800d91 <fd2data>
  800fbd:	83 c4 10             	add    $0x10,%esp
  800fc0:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800fc3:	89 f8                	mov    %edi,%eax
  800fc5:	c1 e8 16             	shr    $0x16,%eax
  800fc8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fcf:	a8 01                	test   $0x1,%al
  800fd1:	74 37                	je     80100a <dup+0x99>
  800fd3:	89 f8                	mov    %edi,%eax
  800fd5:	c1 e8 0c             	shr    $0xc,%eax
  800fd8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fdf:	f6 c2 01             	test   $0x1,%dl
  800fe2:	74 26                	je     80100a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800fe4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800feb:	83 ec 0c             	sub    $0xc,%esp
  800fee:	25 07 0e 00 00       	and    $0xe07,%eax
  800ff3:	50                   	push   %eax
  800ff4:	ff 75 d4             	pushl  -0x2c(%ebp)
  800ff7:	6a 00                	push   $0x0
  800ff9:	57                   	push   %edi
  800ffa:	6a 00                	push   $0x0
  800ffc:	e8 3d fb ff ff       	call   800b3e <sys_page_map>
  801001:	89 c7                	mov    %eax,%edi
  801003:	83 c4 20             	add    $0x20,%esp
  801006:	85 c0                	test   %eax,%eax
  801008:	78 2e                	js     801038 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80100a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80100d:	89 d0                	mov    %edx,%eax
  80100f:	c1 e8 0c             	shr    $0xc,%eax
  801012:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801019:	83 ec 0c             	sub    $0xc,%esp
  80101c:	25 07 0e 00 00       	and    $0xe07,%eax
  801021:	50                   	push   %eax
  801022:	53                   	push   %ebx
  801023:	6a 00                	push   $0x0
  801025:	52                   	push   %edx
  801026:	6a 00                	push   $0x0
  801028:	e8 11 fb ff ff       	call   800b3e <sys_page_map>
  80102d:	89 c7                	mov    %eax,%edi
  80102f:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801032:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801034:	85 ff                	test   %edi,%edi
  801036:	79 1d                	jns    801055 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801038:	83 ec 08             	sub    $0x8,%esp
  80103b:	53                   	push   %ebx
  80103c:	6a 00                	push   $0x0
  80103e:	e8 3d fb ff ff       	call   800b80 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801043:	83 c4 08             	add    $0x8,%esp
  801046:	ff 75 d4             	pushl  -0x2c(%ebp)
  801049:	6a 00                	push   $0x0
  80104b:	e8 30 fb ff ff       	call   800b80 <sys_page_unmap>
	return r;
  801050:	83 c4 10             	add    $0x10,%esp
  801053:	89 f8                	mov    %edi,%eax
}
  801055:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801058:	5b                   	pop    %ebx
  801059:	5e                   	pop    %esi
  80105a:	5f                   	pop    %edi
  80105b:	5d                   	pop    %ebp
  80105c:	c3                   	ret    

0080105d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80105d:	55                   	push   %ebp
  80105e:	89 e5                	mov    %esp,%ebp
  801060:	53                   	push   %ebx
  801061:	83 ec 14             	sub    $0x14,%esp
  801064:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801067:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80106a:	50                   	push   %eax
  80106b:	53                   	push   %ebx
  80106c:	e8 86 fd ff ff       	call   800df7 <fd_lookup>
  801071:	83 c4 08             	add    $0x8,%esp
  801074:	89 c2                	mov    %eax,%edx
  801076:	85 c0                	test   %eax,%eax
  801078:	78 6d                	js     8010e7 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80107a:	83 ec 08             	sub    $0x8,%esp
  80107d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801080:	50                   	push   %eax
  801081:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801084:	ff 30                	pushl  (%eax)
  801086:	e8 c2 fd ff ff       	call   800e4d <dev_lookup>
  80108b:	83 c4 10             	add    $0x10,%esp
  80108e:	85 c0                	test   %eax,%eax
  801090:	78 4c                	js     8010de <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801092:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801095:	8b 42 08             	mov    0x8(%edx),%eax
  801098:	83 e0 03             	and    $0x3,%eax
  80109b:	83 f8 01             	cmp    $0x1,%eax
  80109e:	75 21                	jne    8010c1 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010a0:	a1 08 40 80 00       	mov    0x804008,%eax
  8010a5:	8b 40 48             	mov    0x48(%eax),%eax
  8010a8:	83 ec 04             	sub    $0x4,%esp
  8010ab:	53                   	push   %ebx
  8010ac:	50                   	push   %eax
  8010ad:	68 ad 26 80 00       	push   $0x8026ad
  8010b2:	e8 bc f0 ff ff       	call   800173 <cprintf>
		return -E_INVAL;
  8010b7:	83 c4 10             	add    $0x10,%esp
  8010ba:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8010bf:	eb 26                	jmp    8010e7 <read+0x8a>
	}
	if (!dev->dev_read)
  8010c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010c4:	8b 40 08             	mov    0x8(%eax),%eax
  8010c7:	85 c0                	test   %eax,%eax
  8010c9:	74 17                	je     8010e2 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8010cb:	83 ec 04             	sub    $0x4,%esp
  8010ce:	ff 75 10             	pushl  0x10(%ebp)
  8010d1:	ff 75 0c             	pushl  0xc(%ebp)
  8010d4:	52                   	push   %edx
  8010d5:	ff d0                	call   *%eax
  8010d7:	89 c2                	mov    %eax,%edx
  8010d9:	83 c4 10             	add    $0x10,%esp
  8010dc:	eb 09                	jmp    8010e7 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010de:	89 c2                	mov    %eax,%edx
  8010e0:	eb 05                	jmp    8010e7 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8010e2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8010e7:	89 d0                	mov    %edx,%eax
  8010e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010ec:	c9                   	leave  
  8010ed:	c3                   	ret    

008010ee <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010ee:	55                   	push   %ebp
  8010ef:	89 e5                	mov    %esp,%ebp
  8010f1:	57                   	push   %edi
  8010f2:	56                   	push   %esi
  8010f3:	53                   	push   %ebx
  8010f4:	83 ec 0c             	sub    $0xc,%esp
  8010f7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010fa:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010fd:	bb 00 00 00 00       	mov    $0x0,%ebx
  801102:	eb 21                	jmp    801125 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801104:	83 ec 04             	sub    $0x4,%esp
  801107:	89 f0                	mov    %esi,%eax
  801109:	29 d8                	sub    %ebx,%eax
  80110b:	50                   	push   %eax
  80110c:	89 d8                	mov    %ebx,%eax
  80110e:	03 45 0c             	add    0xc(%ebp),%eax
  801111:	50                   	push   %eax
  801112:	57                   	push   %edi
  801113:	e8 45 ff ff ff       	call   80105d <read>
		if (m < 0)
  801118:	83 c4 10             	add    $0x10,%esp
  80111b:	85 c0                	test   %eax,%eax
  80111d:	78 10                	js     80112f <readn+0x41>
			return m;
		if (m == 0)
  80111f:	85 c0                	test   %eax,%eax
  801121:	74 0a                	je     80112d <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801123:	01 c3                	add    %eax,%ebx
  801125:	39 f3                	cmp    %esi,%ebx
  801127:	72 db                	jb     801104 <readn+0x16>
  801129:	89 d8                	mov    %ebx,%eax
  80112b:	eb 02                	jmp    80112f <readn+0x41>
  80112d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80112f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801132:	5b                   	pop    %ebx
  801133:	5e                   	pop    %esi
  801134:	5f                   	pop    %edi
  801135:	5d                   	pop    %ebp
  801136:	c3                   	ret    

00801137 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801137:	55                   	push   %ebp
  801138:	89 e5                	mov    %esp,%ebp
  80113a:	53                   	push   %ebx
  80113b:	83 ec 14             	sub    $0x14,%esp
  80113e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801141:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801144:	50                   	push   %eax
  801145:	53                   	push   %ebx
  801146:	e8 ac fc ff ff       	call   800df7 <fd_lookup>
  80114b:	83 c4 08             	add    $0x8,%esp
  80114e:	89 c2                	mov    %eax,%edx
  801150:	85 c0                	test   %eax,%eax
  801152:	78 68                	js     8011bc <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801154:	83 ec 08             	sub    $0x8,%esp
  801157:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80115a:	50                   	push   %eax
  80115b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80115e:	ff 30                	pushl  (%eax)
  801160:	e8 e8 fc ff ff       	call   800e4d <dev_lookup>
  801165:	83 c4 10             	add    $0x10,%esp
  801168:	85 c0                	test   %eax,%eax
  80116a:	78 47                	js     8011b3 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80116c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80116f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801173:	75 21                	jne    801196 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801175:	a1 08 40 80 00       	mov    0x804008,%eax
  80117a:	8b 40 48             	mov    0x48(%eax),%eax
  80117d:	83 ec 04             	sub    $0x4,%esp
  801180:	53                   	push   %ebx
  801181:	50                   	push   %eax
  801182:	68 c9 26 80 00       	push   $0x8026c9
  801187:	e8 e7 ef ff ff       	call   800173 <cprintf>
		return -E_INVAL;
  80118c:	83 c4 10             	add    $0x10,%esp
  80118f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801194:	eb 26                	jmp    8011bc <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801196:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801199:	8b 52 0c             	mov    0xc(%edx),%edx
  80119c:	85 d2                	test   %edx,%edx
  80119e:	74 17                	je     8011b7 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8011a0:	83 ec 04             	sub    $0x4,%esp
  8011a3:	ff 75 10             	pushl  0x10(%ebp)
  8011a6:	ff 75 0c             	pushl  0xc(%ebp)
  8011a9:	50                   	push   %eax
  8011aa:	ff d2                	call   *%edx
  8011ac:	89 c2                	mov    %eax,%edx
  8011ae:	83 c4 10             	add    $0x10,%esp
  8011b1:	eb 09                	jmp    8011bc <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011b3:	89 c2                	mov    %eax,%edx
  8011b5:	eb 05                	jmp    8011bc <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8011b7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8011bc:	89 d0                	mov    %edx,%eax
  8011be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011c1:	c9                   	leave  
  8011c2:	c3                   	ret    

008011c3 <seek>:

int
seek(int fdnum, off_t offset)
{
  8011c3:	55                   	push   %ebp
  8011c4:	89 e5                	mov    %esp,%ebp
  8011c6:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011c9:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8011cc:	50                   	push   %eax
  8011cd:	ff 75 08             	pushl  0x8(%ebp)
  8011d0:	e8 22 fc ff ff       	call   800df7 <fd_lookup>
  8011d5:	83 c4 08             	add    $0x8,%esp
  8011d8:	85 c0                	test   %eax,%eax
  8011da:	78 0e                	js     8011ea <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8011dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8011df:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011e2:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8011e5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011ea:	c9                   	leave  
  8011eb:	c3                   	ret    

008011ec <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8011ec:	55                   	push   %ebp
  8011ed:	89 e5                	mov    %esp,%ebp
  8011ef:	53                   	push   %ebx
  8011f0:	83 ec 14             	sub    $0x14,%esp
  8011f3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011f6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011f9:	50                   	push   %eax
  8011fa:	53                   	push   %ebx
  8011fb:	e8 f7 fb ff ff       	call   800df7 <fd_lookup>
  801200:	83 c4 08             	add    $0x8,%esp
  801203:	89 c2                	mov    %eax,%edx
  801205:	85 c0                	test   %eax,%eax
  801207:	78 65                	js     80126e <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801209:	83 ec 08             	sub    $0x8,%esp
  80120c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80120f:	50                   	push   %eax
  801210:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801213:	ff 30                	pushl  (%eax)
  801215:	e8 33 fc ff ff       	call   800e4d <dev_lookup>
  80121a:	83 c4 10             	add    $0x10,%esp
  80121d:	85 c0                	test   %eax,%eax
  80121f:	78 44                	js     801265 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801221:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801224:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801228:	75 21                	jne    80124b <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80122a:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80122f:	8b 40 48             	mov    0x48(%eax),%eax
  801232:	83 ec 04             	sub    $0x4,%esp
  801235:	53                   	push   %ebx
  801236:	50                   	push   %eax
  801237:	68 8c 26 80 00       	push   $0x80268c
  80123c:	e8 32 ef ff ff       	call   800173 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801241:	83 c4 10             	add    $0x10,%esp
  801244:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801249:	eb 23                	jmp    80126e <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80124b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80124e:	8b 52 18             	mov    0x18(%edx),%edx
  801251:	85 d2                	test   %edx,%edx
  801253:	74 14                	je     801269 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801255:	83 ec 08             	sub    $0x8,%esp
  801258:	ff 75 0c             	pushl  0xc(%ebp)
  80125b:	50                   	push   %eax
  80125c:	ff d2                	call   *%edx
  80125e:	89 c2                	mov    %eax,%edx
  801260:	83 c4 10             	add    $0x10,%esp
  801263:	eb 09                	jmp    80126e <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801265:	89 c2                	mov    %eax,%edx
  801267:	eb 05                	jmp    80126e <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801269:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80126e:	89 d0                	mov    %edx,%eax
  801270:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801273:	c9                   	leave  
  801274:	c3                   	ret    

00801275 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801275:	55                   	push   %ebp
  801276:	89 e5                	mov    %esp,%ebp
  801278:	53                   	push   %ebx
  801279:	83 ec 14             	sub    $0x14,%esp
  80127c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80127f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801282:	50                   	push   %eax
  801283:	ff 75 08             	pushl  0x8(%ebp)
  801286:	e8 6c fb ff ff       	call   800df7 <fd_lookup>
  80128b:	83 c4 08             	add    $0x8,%esp
  80128e:	89 c2                	mov    %eax,%edx
  801290:	85 c0                	test   %eax,%eax
  801292:	78 58                	js     8012ec <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801294:	83 ec 08             	sub    $0x8,%esp
  801297:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80129a:	50                   	push   %eax
  80129b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80129e:	ff 30                	pushl  (%eax)
  8012a0:	e8 a8 fb ff ff       	call   800e4d <dev_lookup>
  8012a5:	83 c4 10             	add    $0x10,%esp
  8012a8:	85 c0                	test   %eax,%eax
  8012aa:	78 37                	js     8012e3 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8012ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012af:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8012b3:	74 32                	je     8012e7 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012b5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8012b8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8012bf:	00 00 00 
	stat->st_isdir = 0;
  8012c2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012c9:	00 00 00 
	stat->st_dev = dev;
  8012cc:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012d2:	83 ec 08             	sub    $0x8,%esp
  8012d5:	53                   	push   %ebx
  8012d6:	ff 75 f0             	pushl  -0x10(%ebp)
  8012d9:	ff 50 14             	call   *0x14(%eax)
  8012dc:	89 c2                	mov    %eax,%edx
  8012de:	83 c4 10             	add    $0x10,%esp
  8012e1:	eb 09                	jmp    8012ec <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012e3:	89 c2                	mov    %eax,%edx
  8012e5:	eb 05                	jmp    8012ec <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8012e7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8012ec:	89 d0                	mov    %edx,%eax
  8012ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012f1:	c9                   	leave  
  8012f2:	c3                   	ret    

008012f3 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8012f3:	55                   	push   %ebp
  8012f4:	89 e5                	mov    %esp,%ebp
  8012f6:	56                   	push   %esi
  8012f7:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012f8:	83 ec 08             	sub    $0x8,%esp
  8012fb:	6a 00                	push   $0x0
  8012fd:	ff 75 08             	pushl  0x8(%ebp)
  801300:	e8 0c 02 00 00       	call   801511 <open>
  801305:	89 c3                	mov    %eax,%ebx
  801307:	83 c4 10             	add    $0x10,%esp
  80130a:	85 c0                	test   %eax,%eax
  80130c:	78 1b                	js     801329 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80130e:	83 ec 08             	sub    $0x8,%esp
  801311:	ff 75 0c             	pushl  0xc(%ebp)
  801314:	50                   	push   %eax
  801315:	e8 5b ff ff ff       	call   801275 <fstat>
  80131a:	89 c6                	mov    %eax,%esi
	close(fd);
  80131c:	89 1c 24             	mov    %ebx,(%esp)
  80131f:	e8 fd fb ff ff       	call   800f21 <close>
	return r;
  801324:	83 c4 10             	add    $0x10,%esp
  801327:	89 f0                	mov    %esi,%eax
}
  801329:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80132c:	5b                   	pop    %ebx
  80132d:	5e                   	pop    %esi
  80132e:	5d                   	pop    %ebp
  80132f:	c3                   	ret    

00801330 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801330:	55                   	push   %ebp
  801331:	89 e5                	mov    %esp,%ebp
  801333:	56                   	push   %esi
  801334:	53                   	push   %ebx
  801335:	89 c6                	mov    %eax,%esi
  801337:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801339:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801340:	75 12                	jne    801354 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801342:	83 ec 0c             	sub    $0xc,%esp
  801345:	6a 01                	push   $0x1
  801347:	e8 b2 0c 00 00       	call   801ffe <ipc_find_env>
  80134c:	a3 00 40 80 00       	mov    %eax,0x804000
  801351:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801354:	6a 07                	push   $0x7
  801356:	68 00 50 80 00       	push   $0x805000
  80135b:	56                   	push   %esi
  80135c:	ff 35 00 40 80 00    	pushl  0x804000
  801362:	e8 43 0c 00 00       	call   801faa <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801367:	83 c4 0c             	add    $0xc,%esp
  80136a:	6a 00                	push   $0x0
  80136c:	53                   	push   %ebx
  80136d:	6a 00                	push   $0x0
  80136f:	e8 cd 0b 00 00       	call   801f41 <ipc_recv>
}
  801374:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801377:	5b                   	pop    %ebx
  801378:	5e                   	pop    %esi
  801379:	5d                   	pop    %ebp
  80137a:	c3                   	ret    

0080137b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80137b:	55                   	push   %ebp
  80137c:	89 e5                	mov    %esp,%ebp
  80137e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801381:	8b 45 08             	mov    0x8(%ebp),%eax
  801384:	8b 40 0c             	mov    0xc(%eax),%eax
  801387:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80138c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80138f:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801394:	ba 00 00 00 00       	mov    $0x0,%edx
  801399:	b8 02 00 00 00       	mov    $0x2,%eax
  80139e:	e8 8d ff ff ff       	call   801330 <fsipc>
}
  8013a3:	c9                   	leave  
  8013a4:	c3                   	ret    

008013a5 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8013a5:	55                   	push   %ebp
  8013a6:	89 e5                	mov    %esp,%ebp
  8013a8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8013ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ae:	8b 40 0c             	mov    0xc(%eax),%eax
  8013b1:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8013b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8013bb:	b8 06 00 00 00       	mov    $0x6,%eax
  8013c0:	e8 6b ff ff ff       	call   801330 <fsipc>
}
  8013c5:	c9                   	leave  
  8013c6:	c3                   	ret    

008013c7 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8013c7:	55                   	push   %ebp
  8013c8:	89 e5                	mov    %esp,%ebp
  8013ca:	53                   	push   %ebx
  8013cb:	83 ec 04             	sub    $0x4,%esp
  8013ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8013d4:	8b 40 0c             	mov    0xc(%eax),%eax
  8013d7:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8013dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8013e1:	b8 05 00 00 00       	mov    $0x5,%eax
  8013e6:	e8 45 ff ff ff       	call   801330 <fsipc>
  8013eb:	85 c0                	test   %eax,%eax
  8013ed:	78 2c                	js     80141b <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013ef:	83 ec 08             	sub    $0x8,%esp
  8013f2:	68 00 50 80 00       	push   $0x805000
  8013f7:	53                   	push   %ebx
  8013f8:	e8 fb f2 ff ff       	call   8006f8 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8013fd:	a1 80 50 80 00       	mov    0x805080,%eax
  801402:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801408:	a1 84 50 80 00       	mov    0x805084,%eax
  80140d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801413:	83 c4 10             	add    $0x10,%esp
  801416:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80141b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80141e:	c9                   	leave  
  80141f:	c3                   	ret    

00801420 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801420:	55                   	push   %ebp
  801421:	89 e5                	mov    %esp,%ebp
  801423:	53                   	push   %ebx
  801424:	83 ec 08             	sub    $0x8,%esp
  801427:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80142a:	8b 55 08             	mov    0x8(%ebp),%edx
  80142d:	8b 52 0c             	mov    0xc(%edx),%edx
  801430:	89 15 00 50 80 00    	mov    %edx,0x805000
  801436:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80143b:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  801440:	0f 46 d8             	cmovbe %eax,%ebx
	
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  801443:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  801449:	53                   	push   %ebx
  80144a:	ff 75 0c             	pushl  0xc(%ebp)
  80144d:	68 08 50 80 00       	push   $0x805008
  801452:	e8 33 f4 ff ff       	call   80088a <memmove>

	
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) 
  801457:	ba 00 00 00 00       	mov    $0x0,%edx
  80145c:	b8 04 00 00 00       	mov    $0x4,%eax
  801461:	e8 ca fe ff ff       	call   801330 <fsipc>
  801466:	83 c4 10             	add    $0x10,%esp
  801469:	85 c0                	test   %eax,%eax
  80146b:	78 1d                	js     80148a <devfile_write+0x6a>
		return r;
	assert(r <= n_real); 
  80146d:	39 d8                	cmp    %ebx,%eax
  80146f:	76 19                	jbe    80148a <devfile_write+0x6a>
  801471:	68 fc 26 80 00       	push   $0x8026fc
  801476:	68 08 27 80 00       	push   $0x802708
  80147b:	68 a3 00 00 00       	push   $0xa3
  801480:	68 1d 27 80 00       	push   $0x80271d
  801485:	e8 71 0a 00 00       	call   801efb <_panic>
	return r;
}
  80148a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80148d:	c9                   	leave  
  80148e:	c3                   	ret    

0080148f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80148f:	55                   	push   %ebp
  801490:	89 e5                	mov    %esp,%ebp
  801492:	56                   	push   %esi
  801493:	53                   	push   %ebx
  801494:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801497:	8b 45 08             	mov    0x8(%ebp),%eax
  80149a:	8b 40 0c             	mov    0xc(%eax),%eax
  80149d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8014a2:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ad:	b8 03 00 00 00       	mov    $0x3,%eax
  8014b2:	e8 79 fe ff ff       	call   801330 <fsipc>
  8014b7:	89 c3                	mov    %eax,%ebx
  8014b9:	85 c0                	test   %eax,%eax
  8014bb:	78 4b                	js     801508 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8014bd:	39 c6                	cmp    %eax,%esi
  8014bf:	73 16                	jae    8014d7 <devfile_read+0x48>
  8014c1:	68 28 27 80 00       	push   $0x802728
  8014c6:	68 08 27 80 00       	push   $0x802708
  8014cb:	6a 7c                	push   $0x7c
  8014cd:	68 1d 27 80 00       	push   $0x80271d
  8014d2:	e8 24 0a 00 00       	call   801efb <_panic>
	assert(r <= PGSIZE);
  8014d7:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014dc:	7e 16                	jle    8014f4 <devfile_read+0x65>
  8014de:	68 2f 27 80 00       	push   $0x80272f
  8014e3:	68 08 27 80 00       	push   $0x802708
  8014e8:	6a 7d                	push   $0x7d
  8014ea:	68 1d 27 80 00       	push   $0x80271d
  8014ef:	e8 07 0a 00 00       	call   801efb <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8014f4:	83 ec 04             	sub    $0x4,%esp
  8014f7:	50                   	push   %eax
  8014f8:	68 00 50 80 00       	push   $0x805000
  8014fd:	ff 75 0c             	pushl  0xc(%ebp)
  801500:	e8 85 f3 ff ff       	call   80088a <memmove>
	return r;
  801505:	83 c4 10             	add    $0x10,%esp
}
  801508:	89 d8                	mov    %ebx,%eax
  80150a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80150d:	5b                   	pop    %ebx
  80150e:	5e                   	pop    %esi
  80150f:	5d                   	pop    %ebp
  801510:	c3                   	ret    

00801511 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801511:	55                   	push   %ebp
  801512:	89 e5                	mov    %esp,%ebp
  801514:	53                   	push   %ebx
  801515:	83 ec 20             	sub    $0x20,%esp
  801518:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80151b:	53                   	push   %ebx
  80151c:	e8 9e f1 ff ff       	call   8006bf <strlen>
  801521:	83 c4 10             	add    $0x10,%esp
  801524:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801529:	7f 67                	jg     801592 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80152b:	83 ec 0c             	sub    $0xc,%esp
  80152e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801531:	50                   	push   %eax
  801532:	e8 71 f8 ff ff       	call   800da8 <fd_alloc>
  801537:	83 c4 10             	add    $0x10,%esp
		return r;
  80153a:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80153c:	85 c0                	test   %eax,%eax
  80153e:	78 57                	js     801597 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801540:	83 ec 08             	sub    $0x8,%esp
  801543:	53                   	push   %ebx
  801544:	68 00 50 80 00       	push   $0x805000
  801549:	e8 aa f1 ff ff       	call   8006f8 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80154e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801551:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801556:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801559:	b8 01 00 00 00       	mov    $0x1,%eax
  80155e:	e8 cd fd ff ff       	call   801330 <fsipc>
  801563:	89 c3                	mov    %eax,%ebx
  801565:	83 c4 10             	add    $0x10,%esp
  801568:	85 c0                	test   %eax,%eax
  80156a:	79 14                	jns    801580 <open+0x6f>
		fd_close(fd, 0);
  80156c:	83 ec 08             	sub    $0x8,%esp
  80156f:	6a 00                	push   $0x0
  801571:	ff 75 f4             	pushl  -0xc(%ebp)
  801574:	e8 27 f9 ff ff       	call   800ea0 <fd_close>
		return r;
  801579:	83 c4 10             	add    $0x10,%esp
  80157c:	89 da                	mov    %ebx,%edx
  80157e:	eb 17                	jmp    801597 <open+0x86>
	}

	return fd2num(fd);
  801580:	83 ec 0c             	sub    $0xc,%esp
  801583:	ff 75 f4             	pushl  -0xc(%ebp)
  801586:	e8 f6 f7 ff ff       	call   800d81 <fd2num>
  80158b:	89 c2                	mov    %eax,%edx
  80158d:	83 c4 10             	add    $0x10,%esp
  801590:	eb 05                	jmp    801597 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801592:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801597:	89 d0                	mov    %edx,%eax
  801599:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80159c:	c9                   	leave  
  80159d:	c3                   	ret    

0080159e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80159e:	55                   	push   %ebp
  80159f:	89 e5                	mov    %esp,%ebp
  8015a1:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8015a4:	ba 00 00 00 00       	mov    $0x0,%edx
  8015a9:	b8 08 00 00 00       	mov    $0x8,%eax
  8015ae:	e8 7d fd ff ff       	call   801330 <fsipc>
}
  8015b3:	c9                   	leave  
  8015b4:	c3                   	ret    

008015b5 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8015b5:	55                   	push   %ebp
  8015b6:	89 e5                	mov    %esp,%ebp
  8015b8:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8015bb:	68 3b 27 80 00       	push   $0x80273b
  8015c0:	ff 75 0c             	pushl  0xc(%ebp)
  8015c3:	e8 30 f1 ff ff       	call   8006f8 <strcpy>
	return 0;
}
  8015c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8015cd:	c9                   	leave  
  8015ce:	c3                   	ret    

008015cf <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8015cf:	55                   	push   %ebp
  8015d0:	89 e5                	mov    %esp,%ebp
  8015d2:	53                   	push   %ebx
  8015d3:	83 ec 10             	sub    $0x10,%esp
  8015d6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8015d9:	53                   	push   %ebx
  8015da:	e8 58 0a 00 00       	call   802037 <pageref>
  8015df:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  8015e2:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  8015e7:	83 f8 01             	cmp    $0x1,%eax
  8015ea:	75 10                	jne    8015fc <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  8015ec:	83 ec 0c             	sub    $0xc,%esp
  8015ef:	ff 73 0c             	pushl  0xc(%ebx)
  8015f2:	e8 c0 02 00 00       	call   8018b7 <nsipc_close>
  8015f7:	89 c2                	mov    %eax,%edx
  8015f9:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8015fc:	89 d0                	mov    %edx,%eax
  8015fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801601:	c9                   	leave  
  801602:	c3                   	ret    

00801603 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801603:	55                   	push   %ebp
  801604:	89 e5                	mov    %esp,%ebp
  801606:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801609:	6a 00                	push   $0x0
  80160b:	ff 75 10             	pushl  0x10(%ebp)
  80160e:	ff 75 0c             	pushl  0xc(%ebp)
  801611:	8b 45 08             	mov    0x8(%ebp),%eax
  801614:	ff 70 0c             	pushl  0xc(%eax)
  801617:	e8 78 03 00 00       	call   801994 <nsipc_send>
}
  80161c:	c9                   	leave  
  80161d:	c3                   	ret    

0080161e <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  80161e:	55                   	push   %ebp
  80161f:	89 e5                	mov    %esp,%ebp
  801621:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801624:	6a 00                	push   $0x0
  801626:	ff 75 10             	pushl  0x10(%ebp)
  801629:	ff 75 0c             	pushl  0xc(%ebp)
  80162c:	8b 45 08             	mov    0x8(%ebp),%eax
  80162f:	ff 70 0c             	pushl  0xc(%eax)
  801632:	e8 f1 02 00 00       	call   801928 <nsipc_recv>
}
  801637:	c9                   	leave  
  801638:	c3                   	ret    

00801639 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801639:	55                   	push   %ebp
  80163a:	89 e5                	mov    %esp,%ebp
  80163c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  80163f:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801642:	52                   	push   %edx
  801643:	50                   	push   %eax
  801644:	e8 ae f7 ff ff       	call   800df7 <fd_lookup>
  801649:	83 c4 10             	add    $0x10,%esp
  80164c:	85 c0                	test   %eax,%eax
  80164e:	78 17                	js     801667 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801650:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801653:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801659:	39 08                	cmp    %ecx,(%eax)
  80165b:	75 05                	jne    801662 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  80165d:	8b 40 0c             	mov    0xc(%eax),%eax
  801660:	eb 05                	jmp    801667 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801662:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801667:	c9                   	leave  
  801668:	c3                   	ret    

00801669 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801669:	55                   	push   %ebp
  80166a:	89 e5                	mov    %esp,%ebp
  80166c:	56                   	push   %esi
  80166d:	53                   	push   %ebx
  80166e:	83 ec 1c             	sub    $0x1c,%esp
  801671:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801673:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801676:	50                   	push   %eax
  801677:	e8 2c f7 ff ff       	call   800da8 <fd_alloc>
  80167c:	89 c3                	mov    %eax,%ebx
  80167e:	83 c4 10             	add    $0x10,%esp
  801681:	85 c0                	test   %eax,%eax
  801683:	78 1b                	js     8016a0 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801685:	83 ec 04             	sub    $0x4,%esp
  801688:	68 07 04 00 00       	push   $0x407
  80168d:	ff 75 f4             	pushl  -0xc(%ebp)
  801690:	6a 00                	push   $0x0
  801692:	e8 64 f4 ff ff       	call   800afb <sys_page_alloc>
  801697:	89 c3                	mov    %eax,%ebx
  801699:	83 c4 10             	add    $0x10,%esp
  80169c:	85 c0                	test   %eax,%eax
  80169e:	79 10                	jns    8016b0 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  8016a0:	83 ec 0c             	sub    $0xc,%esp
  8016a3:	56                   	push   %esi
  8016a4:	e8 0e 02 00 00       	call   8018b7 <nsipc_close>
		return r;
  8016a9:	83 c4 10             	add    $0x10,%esp
  8016ac:	89 d8                	mov    %ebx,%eax
  8016ae:	eb 24                	jmp    8016d4 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  8016b0:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8016b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016b9:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8016bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016be:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8016c5:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8016c8:	83 ec 0c             	sub    $0xc,%esp
  8016cb:	50                   	push   %eax
  8016cc:	e8 b0 f6 ff ff       	call   800d81 <fd2num>
  8016d1:	83 c4 10             	add    $0x10,%esp
}
  8016d4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016d7:	5b                   	pop    %ebx
  8016d8:	5e                   	pop    %esi
  8016d9:	5d                   	pop    %ebp
  8016da:	c3                   	ret    

008016db <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8016db:	55                   	push   %ebp
  8016dc:	89 e5                	mov    %esp,%ebp
  8016de:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8016e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e4:	e8 50 ff ff ff       	call   801639 <fd2sockid>
		return r;
  8016e9:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  8016eb:	85 c0                	test   %eax,%eax
  8016ed:	78 1f                	js     80170e <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8016ef:	83 ec 04             	sub    $0x4,%esp
  8016f2:	ff 75 10             	pushl  0x10(%ebp)
  8016f5:	ff 75 0c             	pushl  0xc(%ebp)
  8016f8:	50                   	push   %eax
  8016f9:	e8 12 01 00 00       	call   801810 <nsipc_accept>
  8016fe:	83 c4 10             	add    $0x10,%esp
		return r;
  801701:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801703:	85 c0                	test   %eax,%eax
  801705:	78 07                	js     80170e <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801707:	e8 5d ff ff ff       	call   801669 <alloc_sockfd>
  80170c:	89 c1                	mov    %eax,%ecx
}
  80170e:	89 c8                	mov    %ecx,%eax
  801710:	c9                   	leave  
  801711:	c3                   	ret    

00801712 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801712:	55                   	push   %ebp
  801713:	89 e5                	mov    %esp,%ebp
  801715:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801718:	8b 45 08             	mov    0x8(%ebp),%eax
  80171b:	e8 19 ff ff ff       	call   801639 <fd2sockid>
  801720:	85 c0                	test   %eax,%eax
  801722:	78 12                	js     801736 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801724:	83 ec 04             	sub    $0x4,%esp
  801727:	ff 75 10             	pushl  0x10(%ebp)
  80172a:	ff 75 0c             	pushl  0xc(%ebp)
  80172d:	50                   	push   %eax
  80172e:	e8 2d 01 00 00       	call   801860 <nsipc_bind>
  801733:	83 c4 10             	add    $0x10,%esp
}
  801736:	c9                   	leave  
  801737:	c3                   	ret    

00801738 <shutdown>:

int
shutdown(int s, int how)
{
  801738:	55                   	push   %ebp
  801739:	89 e5                	mov    %esp,%ebp
  80173b:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80173e:	8b 45 08             	mov    0x8(%ebp),%eax
  801741:	e8 f3 fe ff ff       	call   801639 <fd2sockid>
  801746:	85 c0                	test   %eax,%eax
  801748:	78 0f                	js     801759 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  80174a:	83 ec 08             	sub    $0x8,%esp
  80174d:	ff 75 0c             	pushl  0xc(%ebp)
  801750:	50                   	push   %eax
  801751:	e8 3f 01 00 00       	call   801895 <nsipc_shutdown>
  801756:	83 c4 10             	add    $0x10,%esp
}
  801759:	c9                   	leave  
  80175a:	c3                   	ret    

0080175b <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80175b:	55                   	push   %ebp
  80175c:	89 e5                	mov    %esp,%ebp
  80175e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801761:	8b 45 08             	mov    0x8(%ebp),%eax
  801764:	e8 d0 fe ff ff       	call   801639 <fd2sockid>
  801769:	85 c0                	test   %eax,%eax
  80176b:	78 12                	js     80177f <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  80176d:	83 ec 04             	sub    $0x4,%esp
  801770:	ff 75 10             	pushl  0x10(%ebp)
  801773:	ff 75 0c             	pushl  0xc(%ebp)
  801776:	50                   	push   %eax
  801777:	e8 55 01 00 00       	call   8018d1 <nsipc_connect>
  80177c:	83 c4 10             	add    $0x10,%esp
}
  80177f:	c9                   	leave  
  801780:	c3                   	ret    

00801781 <listen>:

int
listen(int s, int backlog)
{
  801781:	55                   	push   %ebp
  801782:	89 e5                	mov    %esp,%ebp
  801784:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801787:	8b 45 08             	mov    0x8(%ebp),%eax
  80178a:	e8 aa fe ff ff       	call   801639 <fd2sockid>
  80178f:	85 c0                	test   %eax,%eax
  801791:	78 0f                	js     8017a2 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801793:	83 ec 08             	sub    $0x8,%esp
  801796:	ff 75 0c             	pushl  0xc(%ebp)
  801799:	50                   	push   %eax
  80179a:	e8 67 01 00 00       	call   801906 <nsipc_listen>
  80179f:	83 c4 10             	add    $0x10,%esp
}
  8017a2:	c9                   	leave  
  8017a3:	c3                   	ret    

008017a4 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8017a4:	55                   	push   %ebp
  8017a5:	89 e5                	mov    %esp,%ebp
  8017a7:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8017aa:	ff 75 10             	pushl  0x10(%ebp)
  8017ad:	ff 75 0c             	pushl  0xc(%ebp)
  8017b0:	ff 75 08             	pushl  0x8(%ebp)
  8017b3:	e8 3a 02 00 00       	call   8019f2 <nsipc_socket>
  8017b8:	83 c4 10             	add    $0x10,%esp
  8017bb:	85 c0                	test   %eax,%eax
  8017bd:	78 05                	js     8017c4 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  8017bf:	e8 a5 fe ff ff       	call   801669 <alloc_sockfd>
}
  8017c4:	c9                   	leave  
  8017c5:	c3                   	ret    

008017c6 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8017c6:	55                   	push   %ebp
  8017c7:	89 e5                	mov    %esp,%ebp
  8017c9:	53                   	push   %ebx
  8017ca:	83 ec 04             	sub    $0x4,%esp
  8017cd:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8017cf:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8017d6:	75 12                	jne    8017ea <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8017d8:	83 ec 0c             	sub    $0xc,%esp
  8017db:	6a 02                	push   $0x2
  8017dd:	e8 1c 08 00 00       	call   801ffe <ipc_find_env>
  8017e2:	a3 04 40 80 00       	mov    %eax,0x804004
  8017e7:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8017ea:	6a 07                	push   $0x7
  8017ec:	68 00 60 80 00       	push   $0x806000
  8017f1:	53                   	push   %ebx
  8017f2:	ff 35 04 40 80 00    	pushl  0x804004
  8017f8:	e8 ad 07 00 00       	call   801faa <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8017fd:	83 c4 0c             	add    $0xc,%esp
  801800:	6a 00                	push   $0x0
  801802:	6a 00                	push   $0x0
  801804:	6a 00                	push   $0x0
  801806:	e8 36 07 00 00       	call   801f41 <ipc_recv>
}
  80180b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80180e:	c9                   	leave  
  80180f:	c3                   	ret    

00801810 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801810:	55                   	push   %ebp
  801811:	89 e5                	mov    %esp,%ebp
  801813:	56                   	push   %esi
  801814:	53                   	push   %ebx
  801815:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801818:	8b 45 08             	mov    0x8(%ebp),%eax
  80181b:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801820:	8b 06                	mov    (%esi),%eax
  801822:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801827:	b8 01 00 00 00       	mov    $0x1,%eax
  80182c:	e8 95 ff ff ff       	call   8017c6 <nsipc>
  801831:	89 c3                	mov    %eax,%ebx
  801833:	85 c0                	test   %eax,%eax
  801835:	78 20                	js     801857 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801837:	83 ec 04             	sub    $0x4,%esp
  80183a:	ff 35 10 60 80 00    	pushl  0x806010
  801840:	68 00 60 80 00       	push   $0x806000
  801845:	ff 75 0c             	pushl  0xc(%ebp)
  801848:	e8 3d f0 ff ff       	call   80088a <memmove>
		*addrlen = ret->ret_addrlen;
  80184d:	a1 10 60 80 00       	mov    0x806010,%eax
  801852:	89 06                	mov    %eax,(%esi)
  801854:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801857:	89 d8                	mov    %ebx,%eax
  801859:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80185c:	5b                   	pop    %ebx
  80185d:	5e                   	pop    %esi
  80185e:	5d                   	pop    %ebp
  80185f:	c3                   	ret    

00801860 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801860:	55                   	push   %ebp
  801861:	89 e5                	mov    %esp,%ebp
  801863:	53                   	push   %ebx
  801864:	83 ec 08             	sub    $0x8,%esp
  801867:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80186a:	8b 45 08             	mov    0x8(%ebp),%eax
  80186d:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801872:	53                   	push   %ebx
  801873:	ff 75 0c             	pushl  0xc(%ebp)
  801876:	68 04 60 80 00       	push   $0x806004
  80187b:	e8 0a f0 ff ff       	call   80088a <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801880:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801886:	b8 02 00 00 00       	mov    $0x2,%eax
  80188b:	e8 36 ff ff ff       	call   8017c6 <nsipc>
}
  801890:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801893:	c9                   	leave  
  801894:	c3                   	ret    

00801895 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801895:	55                   	push   %ebp
  801896:	89 e5                	mov    %esp,%ebp
  801898:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  80189b:	8b 45 08             	mov    0x8(%ebp),%eax
  80189e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  8018a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018a6:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  8018ab:	b8 03 00 00 00       	mov    $0x3,%eax
  8018b0:	e8 11 ff ff ff       	call   8017c6 <nsipc>
}
  8018b5:	c9                   	leave  
  8018b6:	c3                   	ret    

008018b7 <nsipc_close>:

int
nsipc_close(int s)
{
  8018b7:	55                   	push   %ebp
  8018b8:	89 e5                	mov    %esp,%ebp
  8018ba:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8018bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c0:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  8018c5:	b8 04 00 00 00       	mov    $0x4,%eax
  8018ca:	e8 f7 fe ff ff       	call   8017c6 <nsipc>
}
  8018cf:	c9                   	leave  
  8018d0:	c3                   	ret    

008018d1 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8018d1:	55                   	push   %ebp
  8018d2:	89 e5                	mov    %esp,%ebp
  8018d4:	53                   	push   %ebx
  8018d5:	83 ec 08             	sub    $0x8,%esp
  8018d8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8018db:	8b 45 08             	mov    0x8(%ebp),%eax
  8018de:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8018e3:	53                   	push   %ebx
  8018e4:	ff 75 0c             	pushl  0xc(%ebp)
  8018e7:	68 04 60 80 00       	push   $0x806004
  8018ec:	e8 99 ef ff ff       	call   80088a <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8018f1:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  8018f7:	b8 05 00 00 00       	mov    $0x5,%eax
  8018fc:	e8 c5 fe ff ff       	call   8017c6 <nsipc>
}
  801901:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801904:	c9                   	leave  
  801905:	c3                   	ret    

00801906 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801906:	55                   	push   %ebp
  801907:	89 e5                	mov    %esp,%ebp
  801909:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80190c:	8b 45 08             	mov    0x8(%ebp),%eax
  80190f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801914:	8b 45 0c             	mov    0xc(%ebp),%eax
  801917:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  80191c:	b8 06 00 00 00       	mov    $0x6,%eax
  801921:	e8 a0 fe ff ff       	call   8017c6 <nsipc>
}
  801926:	c9                   	leave  
  801927:	c3                   	ret    

00801928 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801928:	55                   	push   %ebp
  801929:	89 e5                	mov    %esp,%ebp
  80192b:	56                   	push   %esi
  80192c:	53                   	push   %ebx
  80192d:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801930:	8b 45 08             	mov    0x8(%ebp),%eax
  801933:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801938:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  80193e:	8b 45 14             	mov    0x14(%ebp),%eax
  801941:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801946:	b8 07 00 00 00       	mov    $0x7,%eax
  80194b:	e8 76 fe ff ff       	call   8017c6 <nsipc>
  801950:	89 c3                	mov    %eax,%ebx
  801952:	85 c0                	test   %eax,%eax
  801954:	78 35                	js     80198b <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801956:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  80195b:	7f 04                	jg     801961 <nsipc_recv+0x39>
  80195d:	39 c6                	cmp    %eax,%esi
  80195f:	7d 16                	jge    801977 <nsipc_recv+0x4f>
  801961:	68 47 27 80 00       	push   $0x802747
  801966:	68 08 27 80 00       	push   $0x802708
  80196b:	6a 62                	push   $0x62
  80196d:	68 5c 27 80 00       	push   $0x80275c
  801972:	e8 84 05 00 00       	call   801efb <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801977:	83 ec 04             	sub    $0x4,%esp
  80197a:	50                   	push   %eax
  80197b:	68 00 60 80 00       	push   $0x806000
  801980:	ff 75 0c             	pushl  0xc(%ebp)
  801983:	e8 02 ef ff ff       	call   80088a <memmove>
  801988:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  80198b:	89 d8                	mov    %ebx,%eax
  80198d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801990:	5b                   	pop    %ebx
  801991:	5e                   	pop    %esi
  801992:	5d                   	pop    %ebp
  801993:	c3                   	ret    

00801994 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801994:	55                   	push   %ebp
  801995:	89 e5                	mov    %esp,%ebp
  801997:	53                   	push   %ebx
  801998:	83 ec 04             	sub    $0x4,%esp
  80199b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  80199e:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a1:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  8019a6:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8019ac:	7e 16                	jle    8019c4 <nsipc_send+0x30>
  8019ae:	68 68 27 80 00       	push   $0x802768
  8019b3:	68 08 27 80 00       	push   $0x802708
  8019b8:	6a 6d                	push   $0x6d
  8019ba:	68 5c 27 80 00       	push   $0x80275c
  8019bf:	e8 37 05 00 00       	call   801efb <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8019c4:	83 ec 04             	sub    $0x4,%esp
  8019c7:	53                   	push   %ebx
  8019c8:	ff 75 0c             	pushl  0xc(%ebp)
  8019cb:	68 0c 60 80 00       	push   $0x80600c
  8019d0:	e8 b5 ee ff ff       	call   80088a <memmove>
	nsipcbuf.send.req_size = size;
  8019d5:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  8019db:	8b 45 14             	mov    0x14(%ebp),%eax
  8019de:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  8019e3:	b8 08 00 00 00       	mov    $0x8,%eax
  8019e8:	e8 d9 fd ff ff       	call   8017c6 <nsipc>
}
  8019ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019f0:	c9                   	leave  
  8019f1:	c3                   	ret    

008019f2 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8019f2:	55                   	push   %ebp
  8019f3:	89 e5                	mov    %esp,%ebp
  8019f5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8019f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8019fb:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801a00:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a03:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801a08:	8b 45 10             	mov    0x10(%ebp),%eax
  801a0b:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801a10:	b8 09 00 00 00       	mov    $0x9,%eax
  801a15:	e8 ac fd ff ff       	call   8017c6 <nsipc>
}
  801a1a:	c9                   	leave  
  801a1b:	c3                   	ret    

00801a1c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a1c:	55                   	push   %ebp
  801a1d:	89 e5                	mov    %esp,%ebp
  801a1f:	56                   	push   %esi
  801a20:	53                   	push   %ebx
  801a21:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a24:	83 ec 0c             	sub    $0xc,%esp
  801a27:	ff 75 08             	pushl  0x8(%ebp)
  801a2a:	e8 62 f3 ff ff       	call   800d91 <fd2data>
  801a2f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a31:	83 c4 08             	add    $0x8,%esp
  801a34:	68 74 27 80 00       	push   $0x802774
  801a39:	53                   	push   %ebx
  801a3a:	e8 b9 ec ff ff       	call   8006f8 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a3f:	8b 46 04             	mov    0x4(%esi),%eax
  801a42:	2b 06                	sub    (%esi),%eax
  801a44:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a4a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a51:	00 00 00 
	stat->st_dev = &devpipe;
  801a54:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801a5b:	30 80 00 
	return 0;
}
  801a5e:	b8 00 00 00 00       	mov    $0x0,%eax
  801a63:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a66:	5b                   	pop    %ebx
  801a67:	5e                   	pop    %esi
  801a68:	5d                   	pop    %ebp
  801a69:	c3                   	ret    

00801a6a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a6a:	55                   	push   %ebp
  801a6b:	89 e5                	mov    %esp,%ebp
  801a6d:	53                   	push   %ebx
  801a6e:	83 ec 0c             	sub    $0xc,%esp
  801a71:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a74:	53                   	push   %ebx
  801a75:	6a 00                	push   $0x0
  801a77:	e8 04 f1 ff ff       	call   800b80 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a7c:	89 1c 24             	mov    %ebx,(%esp)
  801a7f:	e8 0d f3 ff ff       	call   800d91 <fd2data>
  801a84:	83 c4 08             	add    $0x8,%esp
  801a87:	50                   	push   %eax
  801a88:	6a 00                	push   $0x0
  801a8a:	e8 f1 f0 ff ff       	call   800b80 <sys_page_unmap>
}
  801a8f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a92:	c9                   	leave  
  801a93:	c3                   	ret    

00801a94 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a94:	55                   	push   %ebp
  801a95:	89 e5                	mov    %esp,%ebp
  801a97:	57                   	push   %edi
  801a98:	56                   	push   %esi
  801a99:	53                   	push   %ebx
  801a9a:	83 ec 1c             	sub    $0x1c,%esp
  801a9d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801aa0:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801aa2:	a1 08 40 80 00       	mov    0x804008,%eax
  801aa7:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801aaa:	83 ec 0c             	sub    $0xc,%esp
  801aad:	ff 75 e0             	pushl  -0x20(%ebp)
  801ab0:	e8 82 05 00 00       	call   802037 <pageref>
  801ab5:	89 c3                	mov    %eax,%ebx
  801ab7:	89 3c 24             	mov    %edi,(%esp)
  801aba:	e8 78 05 00 00       	call   802037 <pageref>
  801abf:	83 c4 10             	add    $0x10,%esp
  801ac2:	39 c3                	cmp    %eax,%ebx
  801ac4:	0f 94 c1             	sete   %cl
  801ac7:	0f b6 c9             	movzbl %cl,%ecx
  801aca:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801acd:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801ad3:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ad6:	39 ce                	cmp    %ecx,%esi
  801ad8:	74 1b                	je     801af5 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801ada:	39 c3                	cmp    %eax,%ebx
  801adc:	75 c4                	jne    801aa2 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ade:	8b 42 58             	mov    0x58(%edx),%eax
  801ae1:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ae4:	50                   	push   %eax
  801ae5:	56                   	push   %esi
  801ae6:	68 7b 27 80 00       	push   $0x80277b
  801aeb:	e8 83 e6 ff ff       	call   800173 <cprintf>
  801af0:	83 c4 10             	add    $0x10,%esp
  801af3:	eb ad                	jmp    801aa2 <_pipeisclosed+0xe>
	}
}
  801af5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801af8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801afb:	5b                   	pop    %ebx
  801afc:	5e                   	pop    %esi
  801afd:	5f                   	pop    %edi
  801afe:	5d                   	pop    %ebp
  801aff:	c3                   	ret    

00801b00 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b00:	55                   	push   %ebp
  801b01:	89 e5                	mov    %esp,%ebp
  801b03:	57                   	push   %edi
  801b04:	56                   	push   %esi
  801b05:	53                   	push   %ebx
  801b06:	83 ec 28             	sub    $0x28,%esp
  801b09:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b0c:	56                   	push   %esi
  801b0d:	e8 7f f2 ff ff       	call   800d91 <fd2data>
  801b12:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b14:	83 c4 10             	add    $0x10,%esp
  801b17:	bf 00 00 00 00       	mov    $0x0,%edi
  801b1c:	eb 4b                	jmp    801b69 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b1e:	89 da                	mov    %ebx,%edx
  801b20:	89 f0                	mov    %esi,%eax
  801b22:	e8 6d ff ff ff       	call   801a94 <_pipeisclosed>
  801b27:	85 c0                	test   %eax,%eax
  801b29:	75 48                	jne    801b73 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b2b:	e8 ac ef ff ff       	call   800adc <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b30:	8b 43 04             	mov    0x4(%ebx),%eax
  801b33:	8b 0b                	mov    (%ebx),%ecx
  801b35:	8d 51 20             	lea    0x20(%ecx),%edx
  801b38:	39 d0                	cmp    %edx,%eax
  801b3a:	73 e2                	jae    801b1e <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b3f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b43:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b46:	89 c2                	mov    %eax,%edx
  801b48:	c1 fa 1f             	sar    $0x1f,%edx
  801b4b:	89 d1                	mov    %edx,%ecx
  801b4d:	c1 e9 1b             	shr    $0x1b,%ecx
  801b50:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b53:	83 e2 1f             	and    $0x1f,%edx
  801b56:	29 ca                	sub    %ecx,%edx
  801b58:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b5c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b60:	83 c0 01             	add    $0x1,%eax
  801b63:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b66:	83 c7 01             	add    $0x1,%edi
  801b69:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b6c:	75 c2                	jne    801b30 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b6e:	8b 45 10             	mov    0x10(%ebp),%eax
  801b71:	eb 05                	jmp    801b78 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b73:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b78:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b7b:	5b                   	pop    %ebx
  801b7c:	5e                   	pop    %esi
  801b7d:	5f                   	pop    %edi
  801b7e:	5d                   	pop    %ebp
  801b7f:	c3                   	ret    

00801b80 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b80:	55                   	push   %ebp
  801b81:	89 e5                	mov    %esp,%ebp
  801b83:	57                   	push   %edi
  801b84:	56                   	push   %esi
  801b85:	53                   	push   %ebx
  801b86:	83 ec 18             	sub    $0x18,%esp
  801b89:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b8c:	57                   	push   %edi
  801b8d:	e8 ff f1 ff ff       	call   800d91 <fd2data>
  801b92:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b94:	83 c4 10             	add    $0x10,%esp
  801b97:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b9c:	eb 3d                	jmp    801bdb <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b9e:	85 db                	test   %ebx,%ebx
  801ba0:	74 04                	je     801ba6 <devpipe_read+0x26>
				return i;
  801ba2:	89 d8                	mov    %ebx,%eax
  801ba4:	eb 44                	jmp    801bea <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ba6:	89 f2                	mov    %esi,%edx
  801ba8:	89 f8                	mov    %edi,%eax
  801baa:	e8 e5 fe ff ff       	call   801a94 <_pipeisclosed>
  801baf:	85 c0                	test   %eax,%eax
  801bb1:	75 32                	jne    801be5 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801bb3:	e8 24 ef ff ff       	call   800adc <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801bb8:	8b 06                	mov    (%esi),%eax
  801bba:	3b 46 04             	cmp    0x4(%esi),%eax
  801bbd:	74 df                	je     801b9e <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801bbf:	99                   	cltd   
  801bc0:	c1 ea 1b             	shr    $0x1b,%edx
  801bc3:	01 d0                	add    %edx,%eax
  801bc5:	83 e0 1f             	and    $0x1f,%eax
  801bc8:	29 d0                	sub    %edx,%eax
  801bca:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801bcf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bd2:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801bd5:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bd8:	83 c3 01             	add    $0x1,%ebx
  801bdb:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801bde:	75 d8                	jne    801bb8 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801be0:	8b 45 10             	mov    0x10(%ebp),%eax
  801be3:	eb 05                	jmp    801bea <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801be5:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801bea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bed:	5b                   	pop    %ebx
  801bee:	5e                   	pop    %esi
  801bef:	5f                   	pop    %edi
  801bf0:	5d                   	pop    %ebp
  801bf1:	c3                   	ret    

00801bf2 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801bf2:	55                   	push   %ebp
  801bf3:	89 e5                	mov    %esp,%ebp
  801bf5:	56                   	push   %esi
  801bf6:	53                   	push   %ebx
  801bf7:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801bfa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bfd:	50                   	push   %eax
  801bfe:	e8 a5 f1 ff ff       	call   800da8 <fd_alloc>
  801c03:	83 c4 10             	add    $0x10,%esp
  801c06:	89 c2                	mov    %eax,%edx
  801c08:	85 c0                	test   %eax,%eax
  801c0a:	0f 88 2c 01 00 00    	js     801d3c <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c10:	83 ec 04             	sub    $0x4,%esp
  801c13:	68 07 04 00 00       	push   $0x407
  801c18:	ff 75 f4             	pushl  -0xc(%ebp)
  801c1b:	6a 00                	push   $0x0
  801c1d:	e8 d9 ee ff ff       	call   800afb <sys_page_alloc>
  801c22:	83 c4 10             	add    $0x10,%esp
  801c25:	89 c2                	mov    %eax,%edx
  801c27:	85 c0                	test   %eax,%eax
  801c29:	0f 88 0d 01 00 00    	js     801d3c <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c2f:	83 ec 0c             	sub    $0xc,%esp
  801c32:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c35:	50                   	push   %eax
  801c36:	e8 6d f1 ff ff       	call   800da8 <fd_alloc>
  801c3b:	89 c3                	mov    %eax,%ebx
  801c3d:	83 c4 10             	add    $0x10,%esp
  801c40:	85 c0                	test   %eax,%eax
  801c42:	0f 88 e2 00 00 00    	js     801d2a <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c48:	83 ec 04             	sub    $0x4,%esp
  801c4b:	68 07 04 00 00       	push   $0x407
  801c50:	ff 75 f0             	pushl  -0x10(%ebp)
  801c53:	6a 00                	push   $0x0
  801c55:	e8 a1 ee ff ff       	call   800afb <sys_page_alloc>
  801c5a:	89 c3                	mov    %eax,%ebx
  801c5c:	83 c4 10             	add    $0x10,%esp
  801c5f:	85 c0                	test   %eax,%eax
  801c61:	0f 88 c3 00 00 00    	js     801d2a <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c67:	83 ec 0c             	sub    $0xc,%esp
  801c6a:	ff 75 f4             	pushl  -0xc(%ebp)
  801c6d:	e8 1f f1 ff ff       	call   800d91 <fd2data>
  801c72:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c74:	83 c4 0c             	add    $0xc,%esp
  801c77:	68 07 04 00 00       	push   $0x407
  801c7c:	50                   	push   %eax
  801c7d:	6a 00                	push   $0x0
  801c7f:	e8 77 ee ff ff       	call   800afb <sys_page_alloc>
  801c84:	89 c3                	mov    %eax,%ebx
  801c86:	83 c4 10             	add    $0x10,%esp
  801c89:	85 c0                	test   %eax,%eax
  801c8b:	0f 88 89 00 00 00    	js     801d1a <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c91:	83 ec 0c             	sub    $0xc,%esp
  801c94:	ff 75 f0             	pushl  -0x10(%ebp)
  801c97:	e8 f5 f0 ff ff       	call   800d91 <fd2data>
  801c9c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ca3:	50                   	push   %eax
  801ca4:	6a 00                	push   $0x0
  801ca6:	56                   	push   %esi
  801ca7:	6a 00                	push   $0x0
  801ca9:	e8 90 ee ff ff       	call   800b3e <sys_page_map>
  801cae:	89 c3                	mov    %eax,%ebx
  801cb0:	83 c4 20             	add    $0x20,%esp
  801cb3:	85 c0                	test   %eax,%eax
  801cb5:	78 55                	js     801d0c <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801cb7:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cc0:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801cc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cc5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801ccc:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cd2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cd5:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801cd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cda:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801ce1:	83 ec 0c             	sub    $0xc,%esp
  801ce4:	ff 75 f4             	pushl  -0xc(%ebp)
  801ce7:	e8 95 f0 ff ff       	call   800d81 <fd2num>
  801cec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cef:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801cf1:	83 c4 04             	add    $0x4,%esp
  801cf4:	ff 75 f0             	pushl  -0x10(%ebp)
  801cf7:	e8 85 f0 ff ff       	call   800d81 <fd2num>
  801cfc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cff:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d02:	83 c4 10             	add    $0x10,%esp
  801d05:	ba 00 00 00 00       	mov    $0x0,%edx
  801d0a:	eb 30                	jmp    801d3c <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d0c:	83 ec 08             	sub    $0x8,%esp
  801d0f:	56                   	push   %esi
  801d10:	6a 00                	push   $0x0
  801d12:	e8 69 ee ff ff       	call   800b80 <sys_page_unmap>
  801d17:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d1a:	83 ec 08             	sub    $0x8,%esp
  801d1d:	ff 75 f0             	pushl  -0x10(%ebp)
  801d20:	6a 00                	push   $0x0
  801d22:	e8 59 ee ff ff       	call   800b80 <sys_page_unmap>
  801d27:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d2a:	83 ec 08             	sub    $0x8,%esp
  801d2d:	ff 75 f4             	pushl  -0xc(%ebp)
  801d30:	6a 00                	push   $0x0
  801d32:	e8 49 ee ff ff       	call   800b80 <sys_page_unmap>
  801d37:	83 c4 10             	add    $0x10,%esp
  801d3a:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d3c:	89 d0                	mov    %edx,%eax
  801d3e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d41:	5b                   	pop    %ebx
  801d42:	5e                   	pop    %esi
  801d43:	5d                   	pop    %ebp
  801d44:	c3                   	ret    

00801d45 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d45:	55                   	push   %ebp
  801d46:	89 e5                	mov    %esp,%ebp
  801d48:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d4b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d4e:	50                   	push   %eax
  801d4f:	ff 75 08             	pushl  0x8(%ebp)
  801d52:	e8 a0 f0 ff ff       	call   800df7 <fd_lookup>
  801d57:	83 c4 10             	add    $0x10,%esp
  801d5a:	85 c0                	test   %eax,%eax
  801d5c:	78 18                	js     801d76 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d5e:	83 ec 0c             	sub    $0xc,%esp
  801d61:	ff 75 f4             	pushl  -0xc(%ebp)
  801d64:	e8 28 f0 ff ff       	call   800d91 <fd2data>
	return _pipeisclosed(fd, p);
  801d69:	89 c2                	mov    %eax,%edx
  801d6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d6e:	e8 21 fd ff ff       	call   801a94 <_pipeisclosed>
  801d73:	83 c4 10             	add    $0x10,%esp
}
  801d76:	c9                   	leave  
  801d77:	c3                   	ret    

00801d78 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d78:	55                   	push   %ebp
  801d79:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d7b:	b8 00 00 00 00       	mov    $0x0,%eax
  801d80:	5d                   	pop    %ebp
  801d81:	c3                   	ret    

00801d82 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d82:	55                   	push   %ebp
  801d83:	89 e5                	mov    %esp,%ebp
  801d85:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d88:	68 93 27 80 00       	push   $0x802793
  801d8d:	ff 75 0c             	pushl  0xc(%ebp)
  801d90:	e8 63 e9 ff ff       	call   8006f8 <strcpy>
	return 0;
}
  801d95:	b8 00 00 00 00       	mov    $0x0,%eax
  801d9a:	c9                   	leave  
  801d9b:	c3                   	ret    

00801d9c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d9c:	55                   	push   %ebp
  801d9d:	89 e5                	mov    %esp,%ebp
  801d9f:	57                   	push   %edi
  801da0:	56                   	push   %esi
  801da1:	53                   	push   %ebx
  801da2:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801da8:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801dad:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801db3:	eb 2d                	jmp    801de2 <devcons_write+0x46>
		m = n - tot;
  801db5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801db8:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801dba:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801dbd:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801dc2:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801dc5:	83 ec 04             	sub    $0x4,%esp
  801dc8:	53                   	push   %ebx
  801dc9:	03 45 0c             	add    0xc(%ebp),%eax
  801dcc:	50                   	push   %eax
  801dcd:	57                   	push   %edi
  801dce:	e8 b7 ea ff ff       	call   80088a <memmove>
		sys_cputs(buf, m);
  801dd3:	83 c4 08             	add    $0x8,%esp
  801dd6:	53                   	push   %ebx
  801dd7:	57                   	push   %edi
  801dd8:	e8 62 ec ff ff       	call   800a3f <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ddd:	01 de                	add    %ebx,%esi
  801ddf:	83 c4 10             	add    $0x10,%esp
  801de2:	89 f0                	mov    %esi,%eax
  801de4:	3b 75 10             	cmp    0x10(%ebp),%esi
  801de7:	72 cc                	jb     801db5 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801de9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dec:	5b                   	pop    %ebx
  801ded:	5e                   	pop    %esi
  801dee:	5f                   	pop    %edi
  801def:	5d                   	pop    %ebp
  801df0:	c3                   	ret    

00801df1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801df1:	55                   	push   %ebp
  801df2:	89 e5                	mov    %esp,%ebp
  801df4:	83 ec 08             	sub    $0x8,%esp
  801df7:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801dfc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e00:	74 2a                	je     801e2c <devcons_read+0x3b>
  801e02:	eb 05                	jmp    801e09 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e04:	e8 d3 ec ff ff       	call   800adc <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e09:	e8 4f ec ff ff       	call   800a5d <sys_cgetc>
  801e0e:	85 c0                	test   %eax,%eax
  801e10:	74 f2                	je     801e04 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e12:	85 c0                	test   %eax,%eax
  801e14:	78 16                	js     801e2c <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e16:	83 f8 04             	cmp    $0x4,%eax
  801e19:	74 0c                	je     801e27 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e1b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e1e:	88 02                	mov    %al,(%edx)
	return 1;
  801e20:	b8 01 00 00 00       	mov    $0x1,%eax
  801e25:	eb 05                	jmp    801e2c <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e27:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e2c:	c9                   	leave  
  801e2d:	c3                   	ret    

00801e2e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e2e:	55                   	push   %ebp
  801e2f:	89 e5                	mov    %esp,%ebp
  801e31:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e34:	8b 45 08             	mov    0x8(%ebp),%eax
  801e37:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e3a:	6a 01                	push   $0x1
  801e3c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e3f:	50                   	push   %eax
  801e40:	e8 fa eb ff ff       	call   800a3f <sys_cputs>
}
  801e45:	83 c4 10             	add    $0x10,%esp
  801e48:	c9                   	leave  
  801e49:	c3                   	ret    

00801e4a <getchar>:

int
getchar(void)
{
  801e4a:	55                   	push   %ebp
  801e4b:	89 e5                	mov    %esp,%ebp
  801e4d:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e50:	6a 01                	push   $0x1
  801e52:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e55:	50                   	push   %eax
  801e56:	6a 00                	push   $0x0
  801e58:	e8 00 f2 ff ff       	call   80105d <read>
	if (r < 0)
  801e5d:	83 c4 10             	add    $0x10,%esp
  801e60:	85 c0                	test   %eax,%eax
  801e62:	78 0f                	js     801e73 <getchar+0x29>
		return r;
	if (r < 1)
  801e64:	85 c0                	test   %eax,%eax
  801e66:	7e 06                	jle    801e6e <getchar+0x24>
		return -E_EOF;
	return c;
  801e68:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e6c:	eb 05                	jmp    801e73 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e6e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e73:	c9                   	leave  
  801e74:	c3                   	ret    

00801e75 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e75:	55                   	push   %ebp
  801e76:	89 e5                	mov    %esp,%ebp
  801e78:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e7b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e7e:	50                   	push   %eax
  801e7f:	ff 75 08             	pushl  0x8(%ebp)
  801e82:	e8 70 ef ff ff       	call   800df7 <fd_lookup>
  801e87:	83 c4 10             	add    $0x10,%esp
  801e8a:	85 c0                	test   %eax,%eax
  801e8c:	78 11                	js     801e9f <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e91:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801e97:	39 10                	cmp    %edx,(%eax)
  801e99:	0f 94 c0             	sete   %al
  801e9c:	0f b6 c0             	movzbl %al,%eax
}
  801e9f:	c9                   	leave  
  801ea0:	c3                   	ret    

00801ea1 <opencons>:

int
opencons(void)
{
  801ea1:	55                   	push   %ebp
  801ea2:	89 e5                	mov    %esp,%ebp
  801ea4:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ea7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eaa:	50                   	push   %eax
  801eab:	e8 f8 ee ff ff       	call   800da8 <fd_alloc>
  801eb0:	83 c4 10             	add    $0x10,%esp
		return r;
  801eb3:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801eb5:	85 c0                	test   %eax,%eax
  801eb7:	78 3e                	js     801ef7 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801eb9:	83 ec 04             	sub    $0x4,%esp
  801ebc:	68 07 04 00 00       	push   $0x407
  801ec1:	ff 75 f4             	pushl  -0xc(%ebp)
  801ec4:	6a 00                	push   $0x0
  801ec6:	e8 30 ec ff ff       	call   800afb <sys_page_alloc>
  801ecb:	83 c4 10             	add    $0x10,%esp
		return r;
  801ece:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ed0:	85 c0                	test   %eax,%eax
  801ed2:	78 23                	js     801ef7 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ed4:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801eda:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801edd:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801edf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ee2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ee9:	83 ec 0c             	sub    $0xc,%esp
  801eec:	50                   	push   %eax
  801eed:	e8 8f ee ff ff       	call   800d81 <fd2num>
  801ef2:	89 c2                	mov    %eax,%edx
  801ef4:	83 c4 10             	add    $0x10,%esp
}
  801ef7:	89 d0                	mov    %edx,%eax
  801ef9:	c9                   	leave  
  801efa:	c3                   	ret    

00801efb <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801efb:	55                   	push   %ebp
  801efc:	89 e5                	mov    %esp,%ebp
  801efe:	56                   	push   %esi
  801eff:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801f00:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801f03:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801f09:	e8 af eb ff ff       	call   800abd <sys_getenvid>
  801f0e:	83 ec 0c             	sub    $0xc,%esp
  801f11:	ff 75 0c             	pushl  0xc(%ebp)
  801f14:	ff 75 08             	pushl  0x8(%ebp)
  801f17:	56                   	push   %esi
  801f18:	50                   	push   %eax
  801f19:	68 a0 27 80 00       	push   $0x8027a0
  801f1e:	e8 50 e2 ff ff       	call   800173 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801f23:	83 c4 18             	add    $0x18,%esp
  801f26:	53                   	push   %ebx
  801f27:	ff 75 10             	pushl  0x10(%ebp)
  801f2a:	e8 f3 e1 ff ff       	call   800122 <vcprintf>
	cprintf("\n");
  801f2f:	c7 04 24 8c 27 80 00 	movl   $0x80278c,(%esp)
  801f36:	e8 38 e2 ff ff       	call   800173 <cprintf>
  801f3b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801f3e:	cc                   	int3   
  801f3f:	eb fd                	jmp    801f3e <_panic+0x43>

00801f41 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f41:	55                   	push   %ebp
  801f42:	89 e5                	mov    %esp,%ebp
  801f44:	56                   	push   %esi
  801f45:	53                   	push   %ebx
  801f46:	8b 75 08             	mov    0x8(%ebp),%esi
  801f49:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f4c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  801f4f:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801f51:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801f56:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  801f59:	83 ec 0c             	sub    $0xc,%esp
  801f5c:	50                   	push   %eax
  801f5d:	e8 49 ed ff ff       	call   800cab <sys_ipc_recv>

	if (r < 0) {
  801f62:	83 c4 10             	add    $0x10,%esp
  801f65:	85 c0                	test   %eax,%eax
  801f67:	79 16                	jns    801f7f <ipc_recv+0x3e>
		if (from_env_store)
  801f69:	85 f6                	test   %esi,%esi
  801f6b:	74 06                	je     801f73 <ipc_recv+0x32>
			*from_env_store = 0;
  801f6d:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  801f73:	85 db                	test   %ebx,%ebx
  801f75:	74 2c                	je     801fa3 <ipc_recv+0x62>
			*perm_store = 0;
  801f77:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801f7d:	eb 24                	jmp    801fa3 <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  801f7f:	85 f6                	test   %esi,%esi
  801f81:	74 0a                	je     801f8d <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  801f83:	a1 08 40 80 00       	mov    0x804008,%eax
  801f88:	8b 40 74             	mov    0x74(%eax),%eax
  801f8b:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  801f8d:	85 db                	test   %ebx,%ebx
  801f8f:	74 0a                	je     801f9b <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  801f91:	a1 08 40 80 00       	mov    0x804008,%eax
  801f96:	8b 40 78             	mov    0x78(%eax),%eax
  801f99:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  801f9b:	a1 08 40 80 00       	mov    0x804008,%eax
  801fa0:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  801fa3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fa6:	5b                   	pop    %ebx
  801fa7:	5e                   	pop    %esi
  801fa8:	5d                   	pop    %ebp
  801fa9:	c3                   	ret    

00801faa <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801faa:	55                   	push   %ebp
  801fab:	89 e5                	mov    %esp,%ebp
  801fad:	57                   	push   %edi
  801fae:	56                   	push   %esi
  801faf:	53                   	push   %ebx
  801fb0:	83 ec 0c             	sub    $0xc,%esp
  801fb3:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fb6:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fb9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  801fbc:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801fbe:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801fc3:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  801fc6:	ff 75 14             	pushl  0x14(%ebp)
  801fc9:	53                   	push   %ebx
  801fca:	56                   	push   %esi
  801fcb:	57                   	push   %edi
  801fcc:	e8 b7 ec ff ff       	call   800c88 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  801fd1:	83 c4 10             	add    $0x10,%esp
  801fd4:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fd7:	75 07                	jne    801fe0 <ipc_send+0x36>
			sys_yield();
  801fd9:	e8 fe ea ff ff       	call   800adc <sys_yield>
  801fde:	eb e6                	jmp    801fc6 <ipc_send+0x1c>
		} else if (r < 0) {
  801fe0:	85 c0                	test   %eax,%eax
  801fe2:	79 12                	jns    801ff6 <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  801fe4:	50                   	push   %eax
  801fe5:	68 c4 27 80 00       	push   $0x8027c4
  801fea:	6a 51                	push   $0x51
  801fec:	68 d1 27 80 00       	push   $0x8027d1
  801ff1:	e8 05 ff ff ff       	call   801efb <_panic>
		}
	}
}
  801ff6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ff9:	5b                   	pop    %ebx
  801ffa:	5e                   	pop    %esi
  801ffb:	5f                   	pop    %edi
  801ffc:	5d                   	pop    %ebp
  801ffd:	c3                   	ret    

00801ffe <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ffe:	55                   	push   %ebp
  801fff:	89 e5                	mov    %esp,%ebp
  802001:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802004:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802009:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80200c:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802012:	8b 52 50             	mov    0x50(%edx),%edx
  802015:	39 ca                	cmp    %ecx,%edx
  802017:	75 0d                	jne    802026 <ipc_find_env+0x28>
			return envs[i].env_id;
  802019:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80201c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802021:	8b 40 48             	mov    0x48(%eax),%eax
  802024:	eb 0f                	jmp    802035 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802026:	83 c0 01             	add    $0x1,%eax
  802029:	3d 00 04 00 00       	cmp    $0x400,%eax
  80202e:	75 d9                	jne    802009 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802030:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802035:	5d                   	pop    %ebp
  802036:	c3                   	ret    

00802037 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802037:	55                   	push   %ebp
  802038:	89 e5                	mov    %esp,%ebp
  80203a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80203d:	89 d0                	mov    %edx,%eax
  80203f:	c1 e8 16             	shr    $0x16,%eax
  802042:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802049:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80204e:	f6 c1 01             	test   $0x1,%cl
  802051:	74 1d                	je     802070 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802053:	c1 ea 0c             	shr    $0xc,%edx
  802056:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80205d:	f6 c2 01             	test   $0x1,%dl
  802060:	74 0e                	je     802070 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802062:	c1 ea 0c             	shr    $0xc,%edx
  802065:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80206c:	ef 
  80206d:	0f b7 c0             	movzwl %ax,%eax
}
  802070:	5d                   	pop    %ebp
  802071:	c3                   	ret    
  802072:	66 90                	xchg   %ax,%ax
  802074:	66 90                	xchg   %ax,%ax
  802076:	66 90                	xchg   %ax,%ax
  802078:	66 90                	xchg   %ax,%ax
  80207a:	66 90                	xchg   %ax,%ax
  80207c:	66 90                	xchg   %ax,%ax
  80207e:	66 90                	xchg   %ax,%ax

00802080 <__udivdi3>:
  802080:	55                   	push   %ebp
  802081:	57                   	push   %edi
  802082:	56                   	push   %esi
  802083:	53                   	push   %ebx
  802084:	83 ec 1c             	sub    $0x1c,%esp
  802087:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80208b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80208f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802093:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802097:	85 f6                	test   %esi,%esi
  802099:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80209d:	89 ca                	mov    %ecx,%edx
  80209f:	89 f8                	mov    %edi,%eax
  8020a1:	75 3d                	jne    8020e0 <__udivdi3+0x60>
  8020a3:	39 cf                	cmp    %ecx,%edi
  8020a5:	0f 87 c5 00 00 00    	ja     802170 <__udivdi3+0xf0>
  8020ab:	85 ff                	test   %edi,%edi
  8020ad:	89 fd                	mov    %edi,%ebp
  8020af:	75 0b                	jne    8020bc <__udivdi3+0x3c>
  8020b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8020b6:	31 d2                	xor    %edx,%edx
  8020b8:	f7 f7                	div    %edi
  8020ba:	89 c5                	mov    %eax,%ebp
  8020bc:	89 c8                	mov    %ecx,%eax
  8020be:	31 d2                	xor    %edx,%edx
  8020c0:	f7 f5                	div    %ebp
  8020c2:	89 c1                	mov    %eax,%ecx
  8020c4:	89 d8                	mov    %ebx,%eax
  8020c6:	89 cf                	mov    %ecx,%edi
  8020c8:	f7 f5                	div    %ebp
  8020ca:	89 c3                	mov    %eax,%ebx
  8020cc:	89 d8                	mov    %ebx,%eax
  8020ce:	89 fa                	mov    %edi,%edx
  8020d0:	83 c4 1c             	add    $0x1c,%esp
  8020d3:	5b                   	pop    %ebx
  8020d4:	5e                   	pop    %esi
  8020d5:	5f                   	pop    %edi
  8020d6:	5d                   	pop    %ebp
  8020d7:	c3                   	ret    
  8020d8:	90                   	nop
  8020d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020e0:	39 ce                	cmp    %ecx,%esi
  8020e2:	77 74                	ja     802158 <__udivdi3+0xd8>
  8020e4:	0f bd fe             	bsr    %esi,%edi
  8020e7:	83 f7 1f             	xor    $0x1f,%edi
  8020ea:	0f 84 98 00 00 00    	je     802188 <__udivdi3+0x108>
  8020f0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8020f5:	89 f9                	mov    %edi,%ecx
  8020f7:	89 c5                	mov    %eax,%ebp
  8020f9:	29 fb                	sub    %edi,%ebx
  8020fb:	d3 e6                	shl    %cl,%esi
  8020fd:	89 d9                	mov    %ebx,%ecx
  8020ff:	d3 ed                	shr    %cl,%ebp
  802101:	89 f9                	mov    %edi,%ecx
  802103:	d3 e0                	shl    %cl,%eax
  802105:	09 ee                	or     %ebp,%esi
  802107:	89 d9                	mov    %ebx,%ecx
  802109:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80210d:	89 d5                	mov    %edx,%ebp
  80210f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802113:	d3 ed                	shr    %cl,%ebp
  802115:	89 f9                	mov    %edi,%ecx
  802117:	d3 e2                	shl    %cl,%edx
  802119:	89 d9                	mov    %ebx,%ecx
  80211b:	d3 e8                	shr    %cl,%eax
  80211d:	09 c2                	or     %eax,%edx
  80211f:	89 d0                	mov    %edx,%eax
  802121:	89 ea                	mov    %ebp,%edx
  802123:	f7 f6                	div    %esi
  802125:	89 d5                	mov    %edx,%ebp
  802127:	89 c3                	mov    %eax,%ebx
  802129:	f7 64 24 0c          	mull   0xc(%esp)
  80212d:	39 d5                	cmp    %edx,%ebp
  80212f:	72 10                	jb     802141 <__udivdi3+0xc1>
  802131:	8b 74 24 08          	mov    0x8(%esp),%esi
  802135:	89 f9                	mov    %edi,%ecx
  802137:	d3 e6                	shl    %cl,%esi
  802139:	39 c6                	cmp    %eax,%esi
  80213b:	73 07                	jae    802144 <__udivdi3+0xc4>
  80213d:	39 d5                	cmp    %edx,%ebp
  80213f:	75 03                	jne    802144 <__udivdi3+0xc4>
  802141:	83 eb 01             	sub    $0x1,%ebx
  802144:	31 ff                	xor    %edi,%edi
  802146:	89 d8                	mov    %ebx,%eax
  802148:	89 fa                	mov    %edi,%edx
  80214a:	83 c4 1c             	add    $0x1c,%esp
  80214d:	5b                   	pop    %ebx
  80214e:	5e                   	pop    %esi
  80214f:	5f                   	pop    %edi
  802150:	5d                   	pop    %ebp
  802151:	c3                   	ret    
  802152:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802158:	31 ff                	xor    %edi,%edi
  80215a:	31 db                	xor    %ebx,%ebx
  80215c:	89 d8                	mov    %ebx,%eax
  80215e:	89 fa                	mov    %edi,%edx
  802160:	83 c4 1c             	add    $0x1c,%esp
  802163:	5b                   	pop    %ebx
  802164:	5e                   	pop    %esi
  802165:	5f                   	pop    %edi
  802166:	5d                   	pop    %ebp
  802167:	c3                   	ret    
  802168:	90                   	nop
  802169:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802170:	89 d8                	mov    %ebx,%eax
  802172:	f7 f7                	div    %edi
  802174:	31 ff                	xor    %edi,%edi
  802176:	89 c3                	mov    %eax,%ebx
  802178:	89 d8                	mov    %ebx,%eax
  80217a:	89 fa                	mov    %edi,%edx
  80217c:	83 c4 1c             	add    $0x1c,%esp
  80217f:	5b                   	pop    %ebx
  802180:	5e                   	pop    %esi
  802181:	5f                   	pop    %edi
  802182:	5d                   	pop    %ebp
  802183:	c3                   	ret    
  802184:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802188:	39 ce                	cmp    %ecx,%esi
  80218a:	72 0c                	jb     802198 <__udivdi3+0x118>
  80218c:	31 db                	xor    %ebx,%ebx
  80218e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802192:	0f 87 34 ff ff ff    	ja     8020cc <__udivdi3+0x4c>
  802198:	bb 01 00 00 00       	mov    $0x1,%ebx
  80219d:	e9 2a ff ff ff       	jmp    8020cc <__udivdi3+0x4c>
  8021a2:	66 90                	xchg   %ax,%ax
  8021a4:	66 90                	xchg   %ax,%ax
  8021a6:	66 90                	xchg   %ax,%ax
  8021a8:	66 90                	xchg   %ax,%ax
  8021aa:	66 90                	xchg   %ax,%ax
  8021ac:	66 90                	xchg   %ax,%ax
  8021ae:	66 90                	xchg   %ax,%ax

008021b0 <__umoddi3>:
  8021b0:	55                   	push   %ebp
  8021b1:	57                   	push   %edi
  8021b2:	56                   	push   %esi
  8021b3:	53                   	push   %ebx
  8021b4:	83 ec 1c             	sub    $0x1c,%esp
  8021b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021bb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8021bf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021c7:	85 d2                	test   %edx,%edx
  8021c9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8021cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021d1:	89 f3                	mov    %esi,%ebx
  8021d3:	89 3c 24             	mov    %edi,(%esp)
  8021d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021da:	75 1c                	jne    8021f8 <__umoddi3+0x48>
  8021dc:	39 f7                	cmp    %esi,%edi
  8021de:	76 50                	jbe    802230 <__umoddi3+0x80>
  8021e0:	89 c8                	mov    %ecx,%eax
  8021e2:	89 f2                	mov    %esi,%edx
  8021e4:	f7 f7                	div    %edi
  8021e6:	89 d0                	mov    %edx,%eax
  8021e8:	31 d2                	xor    %edx,%edx
  8021ea:	83 c4 1c             	add    $0x1c,%esp
  8021ed:	5b                   	pop    %ebx
  8021ee:	5e                   	pop    %esi
  8021ef:	5f                   	pop    %edi
  8021f0:	5d                   	pop    %ebp
  8021f1:	c3                   	ret    
  8021f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021f8:	39 f2                	cmp    %esi,%edx
  8021fa:	89 d0                	mov    %edx,%eax
  8021fc:	77 52                	ja     802250 <__umoddi3+0xa0>
  8021fe:	0f bd ea             	bsr    %edx,%ebp
  802201:	83 f5 1f             	xor    $0x1f,%ebp
  802204:	75 5a                	jne    802260 <__umoddi3+0xb0>
  802206:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80220a:	0f 82 e0 00 00 00    	jb     8022f0 <__umoddi3+0x140>
  802210:	39 0c 24             	cmp    %ecx,(%esp)
  802213:	0f 86 d7 00 00 00    	jbe    8022f0 <__umoddi3+0x140>
  802219:	8b 44 24 08          	mov    0x8(%esp),%eax
  80221d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802221:	83 c4 1c             	add    $0x1c,%esp
  802224:	5b                   	pop    %ebx
  802225:	5e                   	pop    %esi
  802226:	5f                   	pop    %edi
  802227:	5d                   	pop    %ebp
  802228:	c3                   	ret    
  802229:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802230:	85 ff                	test   %edi,%edi
  802232:	89 fd                	mov    %edi,%ebp
  802234:	75 0b                	jne    802241 <__umoddi3+0x91>
  802236:	b8 01 00 00 00       	mov    $0x1,%eax
  80223b:	31 d2                	xor    %edx,%edx
  80223d:	f7 f7                	div    %edi
  80223f:	89 c5                	mov    %eax,%ebp
  802241:	89 f0                	mov    %esi,%eax
  802243:	31 d2                	xor    %edx,%edx
  802245:	f7 f5                	div    %ebp
  802247:	89 c8                	mov    %ecx,%eax
  802249:	f7 f5                	div    %ebp
  80224b:	89 d0                	mov    %edx,%eax
  80224d:	eb 99                	jmp    8021e8 <__umoddi3+0x38>
  80224f:	90                   	nop
  802250:	89 c8                	mov    %ecx,%eax
  802252:	89 f2                	mov    %esi,%edx
  802254:	83 c4 1c             	add    $0x1c,%esp
  802257:	5b                   	pop    %ebx
  802258:	5e                   	pop    %esi
  802259:	5f                   	pop    %edi
  80225a:	5d                   	pop    %ebp
  80225b:	c3                   	ret    
  80225c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802260:	8b 34 24             	mov    (%esp),%esi
  802263:	bf 20 00 00 00       	mov    $0x20,%edi
  802268:	89 e9                	mov    %ebp,%ecx
  80226a:	29 ef                	sub    %ebp,%edi
  80226c:	d3 e0                	shl    %cl,%eax
  80226e:	89 f9                	mov    %edi,%ecx
  802270:	89 f2                	mov    %esi,%edx
  802272:	d3 ea                	shr    %cl,%edx
  802274:	89 e9                	mov    %ebp,%ecx
  802276:	09 c2                	or     %eax,%edx
  802278:	89 d8                	mov    %ebx,%eax
  80227a:	89 14 24             	mov    %edx,(%esp)
  80227d:	89 f2                	mov    %esi,%edx
  80227f:	d3 e2                	shl    %cl,%edx
  802281:	89 f9                	mov    %edi,%ecx
  802283:	89 54 24 04          	mov    %edx,0x4(%esp)
  802287:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80228b:	d3 e8                	shr    %cl,%eax
  80228d:	89 e9                	mov    %ebp,%ecx
  80228f:	89 c6                	mov    %eax,%esi
  802291:	d3 e3                	shl    %cl,%ebx
  802293:	89 f9                	mov    %edi,%ecx
  802295:	89 d0                	mov    %edx,%eax
  802297:	d3 e8                	shr    %cl,%eax
  802299:	89 e9                	mov    %ebp,%ecx
  80229b:	09 d8                	or     %ebx,%eax
  80229d:	89 d3                	mov    %edx,%ebx
  80229f:	89 f2                	mov    %esi,%edx
  8022a1:	f7 34 24             	divl   (%esp)
  8022a4:	89 d6                	mov    %edx,%esi
  8022a6:	d3 e3                	shl    %cl,%ebx
  8022a8:	f7 64 24 04          	mull   0x4(%esp)
  8022ac:	39 d6                	cmp    %edx,%esi
  8022ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022b2:	89 d1                	mov    %edx,%ecx
  8022b4:	89 c3                	mov    %eax,%ebx
  8022b6:	72 08                	jb     8022c0 <__umoddi3+0x110>
  8022b8:	75 11                	jne    8022cb <__umoddi3+0x11b>
  8022ba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8022be:	73 0b                	jae    8022cb <__umoddi3+0x11b>
  8022c0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8022c4:	1b 14 24             	sbb    (%esp),%edx
  8022c7:	89 d1                	mov    %edx,%ecx
  8022c9:	89 c3                	mov    %eax,%ebx
  8022cb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8022cf:	29 da                	sub    %ebx,%edx
  8022d1:	19 ce                	sbb    %ecx,%esi
  8022d3:	89 f9                	mov    %edi,%ecx
  8022d5:	89 f0                	mov    %esi,%eax
  8022d7:	d3 e0                	shl    %cl,%eax
  8022d9:	89 e9                	mov    %ebp,%ecx
  8022db:	d3 ea                	shr    %cl,%edx
  8022dd:	89 e9                	mov    %ebp,%ecx
  8022df:	d3 ee                	shr    %cl,%esi
  8022e1:	09 d0                	or     %edx,%eax
  8022e3:	89 f2                	mov    %esi,%edx
  8022e5:	83 c4 1c             	add    $0x1c,%esp
  8022e8:	5b                   	pop    %ebx
  8022e9:	5e                   	pop    %esi
  8022ea:	5f                   	pop    %edi
  8022eb:	5d                   	pop    %ebp
  8022ec:	c3                   	ret    
  8022ed:	8d 76 00             	lea    0x0(%esi),%esi
  8022f0:	29 f9                	sub    %edi,%ecx
  8022f2:	19 d6                	sbb    %edx,%esi
  8022f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022fc:	e9 18 ff ff ff       	jmp    802219 <__umoddi3+0x69>
