
obj/user/fairness.debug:     file format elf32-i386


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
  80002c:	e8 70 00 00 00       	call   8000a1 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 10             	sub    $0x10,%esp
	envid_t who, id;

	id = sys_getenvid();
  80003b:	e8 9e 0a 00 00       	call   800ade <sys_getenvid>
  800040:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800042:	81 3d 08 40 80 00 7c 	cmpl   $0xeec0007c,0x804008
  800049:	00 c0 ee 
  80004c:	75 26                	jne    800074 <umain+0x41>
		while (1) {
			ipc_recv(&who, 0, 0);
  80004e:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800051:	83 ec 04             	sub    $0x4,%esp
  800054:	6a 00                	push   $0x0
  800056:	6a 00                	push   $0x0
  800058:	56                   	push   %esi
  800059:	e8 ce 0c 00 00       	call   800d2c <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80005e:	83 c4 0c             	add    $0xc,%esp
  800061:	ff 75 f4             	pushl  -0xc(%ebp)
  800064:	53                   	push   %ebx
  800065:	68 c0 22 80 00       	push   $0x8022c0
  80006a:	e8 25 01 00 00       	call   800194 <cprintf>
  80006f:	83 c4 10             	add    $0x10,%esp
  800072:	eb dd                	jmp    800051 <umain+0x1e>
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800074:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800079:	83 ec 04             	sub    $0x4,%esp
  80007c:	50                   	push   %eax
  80007d:	53                   	push   %ebx
  80007e:	68 d1 22 80 00       	push   $0x8022d1
  800083:	e8 0c 01 00 00       	call   800194 <cprintf>
  800088:	83 c4 10             	add    $0x10,%esp
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  80008b:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800090:	6a 00                	push   $0x0
  800092:	6a 00                	push   $0x0
  800094:	6a 00                	push   $0x0
  800096:	50                   	push   %eax
  800097:	e8 f9 0c 00 00       	call   800d95 <ipc_send>
  80009c:	83 c4 10             	add    $0x10,%esp
  80009f:	eb ea                	jmp    80008b <umain+0x58>

008000a1 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000a1:	55                   	push   %ebp
  8000a2:	89 e5                	mov    %esp,%ebp
  8000a4:	56                   	push   %esi
  8000a5:	53                   	push   %ebx
  8000a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000a9:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000ac:	e8 2d 0a 00 00       	call   800ade <sys_getenvid>
  8000b1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000b9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000be:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c3:	85 db                	test   %ebx,%ebx
  8000c5:	7e 07                	jle    8000ce <libmain+0x2d>
		binaryname = argv[0];
  8000c7:	8b 06                	mov    (%esi),%eax
  8000c9:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000ce:	83 ec 08             	sub    $0x8,%esp
  8000d1:	56                   	push   %esi
  8000d2:	53                   	push   %ebx
  8000d3:	e8 5b ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000d8:	e8 0a 00 00 00       	call   8000e7 <exit>
}
  8000dd:	83 c4 10             	add    $0x10,%esp
  8000e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e3:	5b                   	pop    %ebx
  8000e4:	5e                   	pop    %esi
  8000e5:	5d                   	pop    %ebp
  8000e6:	c3                   	ret    

008000e7 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000ed:	e8 fb 0e 00 00       	call   800fed <close_all>
	sys_env_destroy(0);
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	6a 00                	push   $0x0
  8000f7:	e8 a1 09 00 00       	call   800a9d <sys_env_destroy>
}
  8000fc:	83 c4 10             	add    $0x10,%esp
  8000ff:	c9                   	leave  
  800100:	c3                   	ret    

00800101 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800101:	55                   	push   %ebp
  800102:	89 e5                	mov    %esp,%ebp
  800104:	53                   	push   %ebx
  800105:	83 ec 04             	sub    $0x4,%esp
  800108:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80010b:	8b 13                	mov    (%ebx),%edx
  80010d:	8d 42 01             	lea    0x1(%edx),%eax
  800110:	89 03                	mov    %eax,(%ebx)
  800112:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800115:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800119:	3d ff 00 00 00       	cmp    $0xff,%eax
  80011e:	75 1a                	jne    80013a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800120:	83 ec 08             	sub    $0x8,%esp
  800123:	68 ff 00 00 00       	push   $0xff
  800128:	8d 43 08             	lea    0x8(%ebx),%eax
  80012b:	50                   	push   %eax
  80012c:	e8 2f 09 00 00       	call   800a60 <sys_cputs>
		b->idx = 0;
  800131:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800137:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80013a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80013e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800141:	c9                   	leave  
  800142:	c3                   	ret    

00800143 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80014c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800153:	00 00 00 
	b.cnt = 0;
  800156:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80015d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800160:	ff 75 0c             	pushl  0xc(%ebp)
  800163:	ff 75 08             	pushl  0x8(%ebp)
  800166:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80016c:	50                   	push   %eax
  80016d:	68 01 01 80 00       	push   $0x800101
  800172:	e8 54 01 00 00       	call   8002cb <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800177:	83 c4 08             	add    $0x8,%esp
  80017a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800180:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800186:	50                   	push   %eax
  800187:	e8 d4 08 00 00       	call   800a60 <sys_cputs>

	return b.cnt;
}
  80018c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800192:	c9                   	leave  
  800193:	c3                   	ret    

00800194 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800194:	55                   	push   %ebp
  800195:	89 e5                	mov    %esp,%ebp
  800197:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80019a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80019d:	50                   	push   %eax
  80019e:	ff 75 08             	pushl  0x8(%ebp)
  8001a1:	e8 9d ff ff ff       	call   800143 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a6:	c9                   	leave  
  8001a7:	c3                   	ret    

008001a8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
  8001ab:	57                   	push   %edi
  8001ac:	56                   	push   %esi
  8001ad:	53                   	push   %ebx
  8001ae:	83 ec 1c             	sub    $0x1c,%esp
  8001b1:	89 c7                	mov    %eax,%edi
  8001b3:	89 d6                	mov    %edx,%esi
  8001b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001bb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001be:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001c1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001c4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001c9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001cc:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001cf:	39 d3                	cmp    %edx,%ebx
  8001d1:	72 05                	jb     8001d8 <printnum+0x30>
  8001d3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001d6:	77 45                	ja     80021d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d8:	83 ec 0c             	sub    $0xc,%esp
  8001db:	ff 75 18             	pushl  0x18(%ebp)
  8001de:	8b 45 14             	mov    0x14(%ebp),%eax
  8001e1:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001e4:	53                   	push   %ebx
  8001e5:	ff 75 10             	pushl  0x10(%ebp)
  8001e8:	83 ec 08             	sub    $0x8,%esp
  8001eb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ee:	ff 75 e0             	pushl  -0x20(%ebp)
  8001f1:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f4:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f7:	e8 24 1e 00 00       	call   802020 <__udivdi3>
  8001fc:	83 c4 18             	add    $0x18,%esp
  8001ff:	52                   	push   %edx
  800200:	50                   	push   %eax
  800201:	89 f2                	mov    %esi,%edx
  800203:	89 f8                	mov    %edi,%eax
  800205:	e8 9e ff ff ff       	call   8001a8 <printnum>
  80020a:	83 c4 20             	add    $0x20,%esp
  80020d:	eb 18                	jmp    800227 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80020f:	83 ec 08             	sub    $0x8,%esp
  800212:	56                   	push   %esi
  800213:	ff 75 18             	pushl  0x18(%ebp)
  800216:	ff d7                	call   *%edi
  800218:	83 c4 10             	add    $0x10,%esp
  80021b:	eb 03                	jmp    800220 <printnum+0x78>
  80021d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800220:	83 eb 01             	sub    $0x1,%ebx
  800223:	85 db                	test   %ebx,%ebx
  800225:	7f e8                	jg     80020f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800227:	83 ec 08             	sub    $0x8,%esp
  80022a:	56                   	push   %esi
  80022b:	83 ec 04             	sub    $0x4,%esp
  80022e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800231:	ff 75 e0             	pushl  -0x20(%ebp)
  800234:	ff 75 dc             	pushl  -0x24(%ebp)
  800237:	ff 75 d8             	pushl  -0x28(%ebp)
  80023a:	e8 11 1f 00 00       	call   802150 <__umoddi3>
  80023f:	83 c4 14             	add    $0x14,%esp
  800242:	0f be 80 f2 22 80 00 	movsbl 0x8022f2(%eax),%eax
  800249:	50                   	push   %eax
  80024a:	ff d7                	call   *%edi
}
  80024c:	83 c4 10             	add    $0x10,%esp
  80024f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800252:	5b                   	pop    %ebx
  800253:	5e                   	pop    %esi
  800254:	5f                   	pop    %edi
  800255:	5d                   	pop    %ebp
  800256:	c3                   	ret    

00800257 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800257:	55                   	push   %ebp
  800258:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80025a:	83 fa 01             	cmp    $0x1,%edx
  80025d:	7e 0e                	jle    80026d <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80025f:	8b 10                	mov    (%eax),%edx
  800261:	8d 4a 08             	lea    0x8(%edx),%ecx
  800264:	89 08                	mov    %ecx,(%eax)
  800266:	8b 02                	mov    (%edx),%eax
  800268:	8b 52 04             	mov    0x4(%edx),%edx
  80026b:	eb 22                	jmp    80028f <getuint+0x38>
	else if (lflag)
  80026d:	85 d2                	test   %edx,%edx
  80026f:	74 10                	je     800281 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800271:	8b 10                	mov    (%eax),%edx
  800273:	8d 4a 04             	lea    0x4(%edx),%ecx
  800276:	89 08                	mov    %ecx,(%eax)
  800278:	8b 02                	mov    (%edx),%eax
  80027a:	ba 00 00 00 00       	mov    $0x0,%edx
  80027f:	eb 0e                	jmp    80028f <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800281:	8b 10                	mov    (%eax),%edx
  800283:	8d 4a 04             	lea    0x4(%edx),%ecx
  800286:	89 08                	mov    %ecx,(%eax)
  800288:	8b 02                	mov    (%edx),%eax
  80028a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80028f:	5d                   	pop    %ebp
  800290:	c3                   	ret    

00800291 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800291:	55                   	push   %ebp
  800292:	89 e5                	mov    %esp,%ebp
  800294:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800297:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80029b:	8b 10                	mov    (%eax),%edx
  80029d:	3b 50 04             	cmp    0x4(%eax),%edx
  8002a0:	73 0a                	jae    8002ac <sprintputch+0x1b>
		*b->buf++ = ch;
  8002a2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002a5:	89 08                	mov    %ecx,(%eax)
  8002a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002aa:	88 02                	mov    %al,(%edx)
}
  8002ac:	5d                   	pop    %ebp
  8002ad:	c3                   	ret    

008002ae <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002ae:	55                   	push   %ebp
  8002af:	89 e5                	mov    %esp,%ebp
  8002b1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002b4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002b7:	50                   	push   %eax
  8002b8:	ff 75 10             	pushl  0x10(%ebp)
  8002bb:	ff 75 0c             	pushl  0xc(%ebp)
  8002be:	ff 75 08             	pushl  0x8(%ebp)
  8002c1:	e8 05 00 00 00       	call   8002cb <vprintfmt>
	va_end(ap);
}
  8002c6:	83 c4 10             	add    $0x10,%esp
  8002c9:	c9                   	leave  
  8002ca:	c3                   	ret    

008002cb <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002cb:	55                   	push   %ebp
  8002cc:	89 e5                	mov    %esp,%ebp
  8002ce:	57                   	push   %edi
  8002cf:	56                   	push   %esi
  8002d0:	53                   	push   %ebx
  8002d1:	83 ec 2c             	sub    $0x2c,%esp
  8002d4:	8b 75 08             	mov    0x8(%ebp),%esi
  8002d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002da:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002dd:	eb 12                	jmp    8002f1 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002df:	85 c0                	test   %eax,%eax
  8002e1:	0f 84 89 03 00 00    	je     800670 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8002e7:	83 ec 08             	sub    $0x8,%esp
  8002ea:	53                   	push   %ebx
  8002eb:	50                   	push   %eax
  8002ec:	ff d6                	call   *%esi
  8002ee:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002f1:	83 c7 01             	add    $0x1,%edi
  8002f4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002f8:	83 f8 25             	cmp    $0x25,%eax
  8002fb:	75 e2                	jne    8002df <vprintfmt+0x14>
  8002fd:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800301:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800308:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80030f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800316:	ba 00 00 00 00       	mov    $0x0,%edx
  80031b:	eb 07                	jmp    800324 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80031d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800320:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800324:	8d 47 01             	lea    0x1(%edi),%eax
  800327:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80032a:	0f b6 07             	movzbl (%edi),%eax
  80032d:	0f b6 c8             	movzbl %al,%ecx
  800330:	83 e8 23             	sub    $0x23,%eax
  800333:	3c 55                	cmp    $0x55,%al
  800335:	0f 87 1a 03 00 00    	ja     800655 <vprintfmt+0x38a>
  80033b:	0f b6 c0             	movzbl %al,%eax
  80033e:	ff 24 85 40 24 80 00 	jmp    *0x802440(,%eax,4)
  800345:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800348:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80034c:	eb d6                	jmp    800324 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80034e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800351:	b8 00 00 00 00       	mov    $0x0,%eax
  800356:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800359:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80035c:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800360:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800363:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800366:	83 fa 09             	cmp    $0x9,%edx
  800369:	77 39                	ja     8003a4 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80036b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80036e:	eb e9                	jmp    800359 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800370:	8b 45 14             	mov    0x14(%ebp),%eax
  800373:	8d 48 04             	lea    0x4(%eax),%ecx
  800376:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800379:	8b 00                	mov    (%eax),%eax
  80037b:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800381:	eb 27                	jmp    8003aa <vprintfmt+0xdf>
  800383:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800386:	85 c0                	test   %eax,%eax
  800388:	b9 00 00 00 00       	mov    $0x0,%ecx
  80038d:	0f 49 c8             	cmovns %eax,%ecx
  800390:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800393:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800396:	eb 8c                	jmp    800324 <vprintfmt+0x59>
  800398:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80039b:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003a2:	eb 80                	jmp    800324 <vprintfmt+0x59>
  8003a4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003a7:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003aa:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003ae:	0f 89 70 ff ff ff    	jns    800324 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003b4:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003b7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003ba:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003c1:	e9 5e ff ff ff       	jmp    800324 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003c6:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003cc:	e9 53 ff ff ff       	jmp    800324 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d4:	8d 50 04             	lea    0x4(%eax),%edx
  8003d7:	89 55 14             	mov    %edx,0x14(%ebp)
  8003da:	83 ec 08             	sub    $0x8,%esp
  8003dd:	53                   	push   %ebx
  8003de:	ff 30                	pushl  (%eax)
  8003e0:	ff d6                	call   *%esi
			break;
  8003e2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003e8:	e9 04 ff ff ff       	jmp    8002f1 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f0:	8d 50 04             	lea    0x4(%eax),%edx
  8003f3:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f6:	8b 00                	mov    (%eax),%eax
  8003f8:	99                   	cltd   
  8003f9:	31 d0                	xor    %edx,%eax
  8003fb:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003fd:	83 f8 0f             	cmp    $0xf,%eax
  800400:	7f 0b                	jg     80040d <vprintfmt+0x142>
  800402:	8b 14 85 a0 25 80 00 	mov    0x8025a0(,%eax,4),%edx
  800409:	85 d2                	test   %edx,%edx
  80040b:	75 18                	jne    800425 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80040d:	50                   	push   %eax
  80040e:	68 0a 23 80 00       	push   $0x80230a
  800413:	53                   	push   %ebx
  800414:	56                   	push   %esi
  800415:	e8 94 fe ff ff       	call   8002ae <printfmt>
  80041a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800420:	e9 cc fe ff ff       	jmp    8002f1 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800425:	52                   	push   %edx
  800426:	68 f2 26 80 00       	push   $0x8026f2
  80042b:	53                   	push   %ebx
  80042c:	56                   	push   %esi
  80042d:	e8 7c fe ff ff       	call   8002ae <printfmt>
  800432:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800435:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800438:	e9 b4 fe ff ff       	jmp    8002f1 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80043d:	8b 45 14             	mov    0x14(%ebp),%eax
  800440:	8d 50 04             	lea    0x4(%eax),%edx
  800443:	89 55 14             	mov    %edx,0x14(%ebp)
  800446:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800448:	85 ff                	test   %edi,%edi
  80044a:	b8 03 23 80 00       	mov    $0x802303,%eax
  80044f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800452:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800456:	0f 8e 94 00 00 00    	jle    8004f0 <vprintfmt+0x225>
  80045c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800460:	0f 84 98 00 00 00    	je     8004fe <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800466:	83 ec 08             	sub    $0x8,%esp
  800469:	ff 75 d0             	pushl  -0x30(%ebp)
  80046c:	57                   	push   %edi
  80046d:	e8 86 02 00 00       	call   8006f8 <strnlen>
  800472:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800475:	29 c1                	sub    %eax,%ecx
  800477:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80047a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80047d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800481:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800484:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800487:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800489:	eb 0f                	jmp    80049a <vprintfmt+0x1cf>
					putch(padc, putdat);
  80048b:	83 ec 08             	sub    $0x8,%esp
  80048e:	53                   	push   %ebx
  80048f:	ff 75 e0             	pushl  -0x20(%ebp)
  800492:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800494:	83 ef 01             	sub    $0x1,%edi
  800497:	83 c4 10             	add    $0x10,%esp
  80049a:	85 ff                	test   %edi,%edi
  80049c:	7f ed                	jg     80048b <vprintfmt+0x1c0>
  80049e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004a1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004a4:	85 c9                	test   %ecx,%ecx
  8004a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ab:	0f 49 c1             	cmovns %ecx,%eax
  8004ae:	29 c1                	sub    %eax,%ecx
  8004b0:	89 75 08             	mov    %esi,0x8(%ebp)
  8004b3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004b6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004b9:	89 cb                	mov    %ecx,%ebx
  8004bb:	eb 4d                	jmp    80050a <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004bd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004c1:	74 1b                	je     8004de <vprintfmt+0x213>
  8004c3:	0f be c0             	movsbl %al,%eax
  8004c6:	83 e8 20             	sub    $0x20,%eax
  8004c9:	83 f8 5e             	cmp    $0x5e,%eax
  8004cc:	76 10                	jbe    8004de <vprintfmt+0x213>
					putch('?', putdat);
  8004ce:	83 ec 08             	sub    $0x8,%esp
  8004d1:	ff 75 0c             	pushl  0xc(%ebp)
  8004d4:	6a 3f                	push   $0x3f
  8004d6:	ff 55 08             	call   *0x8(%ebp)
  8004d9:	83 c4 10             	add    $0x10,%esp
  8004dc:	eb 0d                	jmp    8004eb <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004de:	83 ec 08             	sub    $0x8,%esp
  8004e1:	ff 75 0c             	pushl  0xc(%ebp)
  8004e4:	52                   	push   %edx
  8004e5:	ff 55 08             	call   *0x8(%ebp)
  8004e8:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004eb:	83 eb 01             	sub    $0x1,%ebx
  8004ee:	eb 1a                	jmp    80050a <vprintfmt+0x23f>
  8004f0:	89 75 08             	mov    %esi,0x8(%ebp)
  8004f3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004f6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004f9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004fc:	eb 0c                	jmp    80050a <vprintfmt+0x23f>
  8004fe:	89 75 08             	mov    %esi,0x8(%ebp)
  800501:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800504:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800507:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80050a:	83 c7 01             	add    $0x1,%edi
  80050d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800511:	0f be d0             	movsbl %al,%edx
  800514:	85 d2                	test   %edx,%edx
  800516:	74 23                	je     80053b <vprintfmt+0x270>
  800518:	85 f6                	test   %esi,%esi
  80051a:	78 a1                	js     8004bd <vprintfmt+0x1f2>
  80051c:	83 ee 01             	sub    $0x1,%esi
  80051f:	79 9c                	jns    8004bd <vprintfmt+0x1f2>
  800521:	89 df                	mov    %ebx,%edi
  800523:	8b 75 08             	mov    0x8(%ebp),%esi
  800526:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800529:	eb 18                	jmp    800543 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80052b:	83 ec 08             	sub    $0x8,%esp
  80052e:	53                   	push   %ebx
  80052f:	6a 20                	push   $0x20
  800531:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800533:	83 ef 01             	sub    $0x1,%edi
  800536:	83 c4 10             	add    $0x10,%esp
  800539:	eb 08                	jmp    800543 <vprintfmt+0x278>
  80053b:	89 df                	mov    %ebx,%edi
  80053d:	8b 75 08             	mov    0x8(%ebp),%esi
  800540:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800543:	85 ff                	test   %edi,%edi
  800545:	7f e4                	jg     80052b <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800547:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80054a:	e9 a2 fd ff ff       	jmp    8002f1 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80054f:	83 fa 01             	cmp    $0x1,%edx
  800552:	7e 16                	jle    80056a <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800554:	8b 45 14             	mov    0x14(%ebp),%eax
  800557:	8d 50 08             	lea    0x8(%eax),%edx
  80055a:	89 55 14             	mov    %edx,0x14(%ebp)
  80055d:	8b 50 04             	mov    0x4(%eax),%edx
  800560:	8b 00                	mov    (%eax),%eax
  800562:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800565:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800568:	eb 32                	jmp    80059c <vprintfmt+0x2d1>
	else if (lflag)
  80056a:	85 d2                	test   %edx,%edx
  80056c:	74 18                	je     800586 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80056e:	8b 45 14             	mov    0x14(%ebp),%eax
  800571:	8d 50 04             	lea    0x4(%eax),%edx
  800574:	89 55 14             	mov    %edx,0x14(%ebp)
  800577:	8b 00                	mov    (%eax),%eax
  800579:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80057c:	89 c1                	mov    %eax,%ecx
  80057e:	c1 f9 1f             	sar    $0x1f,%ecx
  800581:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800584:	eb 16                	jmp    80059c <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800586:	8b 45 14             	mov    0x14(%ebp),%eax
  800589:	8d 50 04             	lea    0x4(%eax),%edx
  80058c:	89 55 14             	mov    %edx,0x14(%ebp)
  80058f:	8b 00                	mov    (%eax),%eax
  800591:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800594:	89 c1                	mov    %eax,%ecx
  800596:	c1 f9 1f             	sar    $0x1f,%ecx
  800599:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80059c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80059f:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005a2:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005a7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005ab:	79 74                	jns    800621 <vprintfmt+0x356>
				putch('-', putdat);
  8005ad:	83 ec 08             	sub    $0x8,%esp
  8005b0:	53                   	push   %ebx
  8005b1:	6a 2d                	push   $0x2d
  8005b3:	ff d6                	call   *%esi
				num = -(long long) num;
  8005b5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005b8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005bb:	f7 d8                	neg    %eax
  8005bd:	83 d2 00             	adc    $0x0,%edx
  8005c0:	f7 da                	neg    %edx
  8005c2:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005c5:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005ca:	eb 55                	jmp    800621 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005cc:	8d 45 14             	lea    0x14(%ebp),%eax
  8005cf:	e8 83 fc ff ff       	call   800257 <getuint>
			base = 10;
  8005d4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005d9:	eb 46                	jmp    800621 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005db:	8d 45 14             	lea    0x14(%ebp),%eax
  8005de:	e8 74 fc ff ff       	call   800257 <getuint>
                        base = 8;
  8005e3:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  8005e8:	eb 37                	jmp    800621 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8005ea:	83 ec 08             	sub    $0x8,%esp
  8005ed:	53                   	push   %ebx
  8005ee:	6a 30                	push   $0x30
  8005f0:	ff d6                	call   *%esi
			putch('x', putdat);
  8005f2:	83 c4 08             	add    $0x8,%esp
  8005f5:	53                   	push   %ebx
  8005f6:	6a 78                	push   $0x78
  8005f8:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fd:	8d 50 04             	lea    0x4(%eax),%edx
  800600:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800603:	8b 00                	mov    (%eax),%eax
  800605:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80060a:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80060d:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800612:	eb 0d                	jmp    800621 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800614:	8d 45 14             	lea    0x14(%ebp),%eax
  800617:	e8 3b fc ff ff       	call   800257 <getuint>
			base = 16;
  80061c:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800621:	83 ec 0c             	sub    $0xc,%esp
  800624:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800628:	57                   	push   %edi
  800629:	ff 75 e0             	pushl  -0x20(%ebp)
  80062c:	51                   	push   %ecx
  80062d:	52                   	push   %edx
  80062e:	50                   	push   %eax
  80062f:	89 da                	mov    %ebx,%edx
  800631:	89 f0                	mov    %esi,%eax
  800633:	e8 70 fb ff ff       	call   8001a8 <printnum>
			break;
  800638:	83 c4 20             	add    $0x20,%esp
  80063b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80063e:	e9 ae fc ff ff       	jmp    8002f1 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800643:	83 ec 08             	sub    $0x8,%esp
  800646:	53                   	push   %ebx
  800647:	51                   	push   %ecx
  800648:	ff d6                	call   *%esi
			break;
  80064a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800650:	e9 9c fc ff ff       	jmp    8002f1 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800655:	83 ec 08             	sub    $0x8,%esp
  800658:	53                   	push   %ebx
  800659:	6a 25                	push   $0x25
  80065b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80065d:	83 c4 10             	add    $0x10,%esp
  800660:	eb 03                	jmp    800665 <vprintfmt+0x39a>
  800662:	83 ef 01             	sub    $0x1,%edi
  800665:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800669:	75 f7                	jne    800662 <vprintfmt+0x397>
  80066b:	e9 81 fc ff ff       	jmp    8002f1 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800670:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800673:	5b                   	pop    %ebx
  800674:	5e                   	pop    %esi
  800675:	5f                   	pop    %edi
  800676:	5d                   	pop    %ebp
  800677:	c3                   	ret    

00800678 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800678:	55                   	push   %ebp
  800679:	89 e5                	mov    %esp,%ebp
  80067b:	83 ec 18             	sub    $0x18,%esp
  80067e:	8b 45 08             	mov    0x8(%ebp),%eax
  800681:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800684:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800687:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80068b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80068e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800695:	85 c0                	test   %eax,%eax
  800697:	74 26                	je     8006bf <vsnprintf+0x47>
  800699:	85 d2                	test   %edx,%edx
  80069b:	7e 22                	jle    8006bf <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80069d:	ff 75 14             	pushl  0x14(%ebp)
  8006a0:	ff 75 10             	pushl  0x10(%ebp)
  8006a3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006a6:	50                   	push   %eax
  8006a7:	68 91 02 80 00       	push   $0x800291
  8006ac:	e8 1a fc ff ff       	call   8002cb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006b4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006ba:	83 c4 10             	add    $0x10,%esp
  8006bd:	eb 05                	jmp    8006c4 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006bf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006c4:	c9                   	leave  
  8006c5:	c3                   	ret    

008006c6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006c6:	55                   	push   %ebp
  8006c7:	89 e5                	mov    %esp,%ebp
  8006c9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006cc:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006cf:	50                   	push   %eax
  8006d0:	ff 75 10             	pushl  0x10(%ebp)
  8006d3:	ff 75 0c             	pushl  0xc(%ebp)
  8006d6:	ff 75 08             	pushl  0x8(%ebp)
  8006d9:	e8 9a ff ff ff       	call   800678 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006de:	c9                   	leave  
  8006df:	c3                   	ret    

008006e0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006e0:	55                   	push   %ebp
  8006e1:	89 e5                	mov    %esp,%ebp
  8006e3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8006eb:	eb 03                	jmp    8006f0 <strlen+0x10>
		n++;
  8006ed:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006f0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006f4:	75 f7                	jne    8006ed <strlen+0xd>
		n++;
	return n;
}
  8006f6:	5d                   	pop    %ebp
  8006f7:	c3                   	ret    

008006f8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006f8:	55                   	push   %ebp
  8006f9:	89 e5                	mov    %esp,%ebp
  8006fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006fe:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800701:	ba 00 00 00 00       	mov    $0x0,%edx
  800706:	eb 03                	jmp    80070b <strnlen+0x13>
		n++;
  800708:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80070b:	39 c2                	cmp    %eax,%edx
  80070d:	74 08                	je     800717 <strnlen+0x1f>
  80070f:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800713:	75 f3                	jne    800708 <strnlen+0x10>
  800715:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800717:	5d                   	pop    %ebp
  800718:	c3                   	ret    

00800719 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800719:	55                   	push   %ebp
  80071a:	89 e5                	mov    %esp,%ebp
  80071c:	53                   	push   %ebx
  80071d:	8b 45 08             	mov    0x8(%ebp),%eax
  800720:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800723:	89 c2                	mov    %eax,%edx
  800725:	83 c2 01             	add    $0x1,%edx
  800728:	83 c1 01             	add    $0x1,%ecx
  80072b:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80072f:	88 5a ff             	mov    %bl,-0x1(%edx)
  800732:	84 db                	test   %bl,%bl
  800734:	75 ef                	jne    800725 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800736:	5b                   	pop    %ebx
  800737:	5d                   	pop    %ebp
  800738:	c3                   	ret    

00800739 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800739:	55                   	push   %ebp
  80073a:	89 e5                	mov    %esp,%ebp
  80073c:	53                   	push   %ebx
  80073d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800740:	53                   	push   %ebx
  800741:	e8 9a ff ff ff       	call   8006e0 <strlen>
  800746:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800749:	ff 75 0c             	pushl  0xc(%ebp)
  80074c:	01 d8                	add    %ebx,%eax
  80074e:	50                   	push   %eax
  80074f:	e8 c5 ff ff ff       	call   800719 <strcpy>
	return dst;
}
  800754:	89 d8                	mov    %ebx,%eax
  800756:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800759:	c9                   	leave  
  80075a:	c3                   	ret    

0080075b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80075b:	55                   	push   %ebp
  80075c:	89 e5                	mov    %esp,%ebp
  80075e:	56                   	push   %esi
  80075f:	53                   	push   %ebx
  800760:	8b 75 08             	mov    0x8(%ebp),%esi
  800763:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800766:	89 f3                	mov    %esi,%ebx
  800768:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80076b:	89 f2                	mov    %esi,%edx
  80076d:	eb 0f                	jmp    80077e <strncpy+0x23>
		*dst++ = *src;
  80076f:	83 c2 01             	add    $0x1,%edx
  800772:	0f b6 01             	movzbl (%ecx),%eax
  800775:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800778:	80 39 01             	cmpb   $0x1,(%ecx)
  80077b:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80077e:	39 da                	cmp    %ebx,%edx
  800780:	75 ed                	jne    80076f <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800782:	89 f0                	mov    %esi,%eax
  800784:	5b                   	pop    %ebx
  800785:	5e                   	pop    %esi
  800786:	5d                   	pop    %ebp
  800787:	c3                   	ret    

00800788 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800788:	55                   	push   %ebp
  800789:	89 e5                	mov    %esp,%ebp
  80078b:	56                   	push   %esi
  80078c:	53                   	push   %ebx
  80078d:	8b 75 08             	mov    0x8(%ebp),%esi
  800790:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800793:	8b 55 10             	mov    0x10(%ebp),%edx
  800796:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800798:	85 d2                	test   %edx,%edx
  80079a:	74 21                	je     8007bd <strlcpy+0x35>
  80079c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007a0:	89 f2                	mov    %esi,%edx
  8007a2:	eb 09                	jmp    8007ad <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007a4:	83 c2 01             	add    $0x1,%edx
  8007a7:	83 c1 01             	add    $0x1,%ecx
  8007aa:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007ad:	39 c2                	cmp    %eax,%edx
  8007af:	74 09                	je     8007ba <strlcpy+0x32>
  8007b1:	0f b6 19             	movzbl (%ecx),%ebx
  8007b4:	84 db                	test   %bl,%bl
  8007b6:	75 ec                	jne    8007a4 <strlcpy+0x1c>
  8007b8:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007ba:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007bd:	29 f0                	sub    %esi,%eax
}
  8007bf:	5b                   	pop    %ebx
  8007c0:	5e                   	pop    %esi
  8007c1:	5d                   	pop    %ebp
  8007c2:	c3                   	ret    

008007c3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007c3:	55                   	push   %ebp
  8007c4:	89 e5                	mov    %esp,%ebp
  8007c6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007cc:	eb 06                	jmp    8007d4 <strcmp+0x11>
		p++, q++;
  8007ce:	83 c1 01             	add    $0x1,%ecx
  8007d1:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007d4:	0f b6 01             	movzbl (%ecx),%eax
  8007d7:	84 c0                	test   %al,%al
  8007d9:	74 04                	je     8007df <strcmp+0x1c>
  8007db:	3a 02                	cmp    (%edx),%al
  8007dd:	74 ef                	je     8007ce <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007df:	0f b6 c0             	movzbl %al,%eax
  8007e2:	0f b6 12             	movzbl (%edx),%edx
  8007e5:	29 d0                	sub    %edx,%eax
}
  8007e7:	5d                   	pop    %ebp
  8007e8:	c3                   	ret    

008007e9 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007e9:	55                   	push   %ebp
  8007ea:	89 e5                	mov    %esp,%ebp
  8007ec:	53                   	push   %ebx
  8007ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f3:	89 c3                	mov    %eax,%ebx
  8007f5:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007f8:	eb 06                	jmp    800800 <strncmp+0x17>
		n--, p++, q++;
  8007fa:	83 c0 01             	add    $0x1,%eax
  8007fd:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800800:	39 d8                	cmp    %ebx,%eax
  800802:	74 15                	je     800819 <strncmp+0x30>
  800804:	0f b6 08             	movzbl (%eax),%ecx
  800807:	84 c9                	test   %cl,%cl
  800809:	74 04                	je     80080f <strncmp+0x26>
  80080b:	3a 0a                	cmp    (%edx),%cl
  80080d:	74 eb                	je     8007fa <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80080f:	0f b6 00             	movzbl (%eax),%eax
  800812:	0f b6 12             	movzbl (%edx),%edx
  800815:	29 d0                	sub    %edx,%eax
  800817:	eb 05                	jmp    80081e <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800819:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80081e:	5b                   	pop    %ebx
  80081f:	5d                   	pop    %ebp
  800820:	c3                   	ret    

00800821 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800821:	55                   	push   %ebp
  800822:	89 e5                	mov    %esp,%ebp
  800824:	8b 45 08             	mov    0x8(%ebp),%eax
  800827:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80082b:	eb 07                	jmp    800834 <strchr+0x13>
		if (*s == c)
  80082d:	38 ca                	cmp    %cl,%dl
  80082f:	74 0f                	je     800840 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800831:	83 c0 01             	add    $0x1,%eax
  800834:	0f b6 10             	movzbl (%eax),%edx
  800837:	84 d2                	test   %dl,%dl
  800839:	75 f2                	jne    80082d <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80083b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800840:	5d                   	pop    %ebp
  800841:	c3                   	ret    

00800842 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800842:	55                   	push   %ebp
  800843:	89 e5                	mov    %esp,%ebp
  800845:	8b 45 08             	mov    0x8(%ebp),%eax
  800848:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80084c:	eb 03                	jmp    800851 <strfind+0xf>
  80084e:	83 c0 01             	add    $0x1,%eax
  800851:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800854:	38 ca                	cmp    %cl,%dl
  800856:	74 04                	je     80085c <strfind+0x1a>
  800858:	84 d2                	test   %dl,%dl
  80085a:	75 f2                	jne    80084e <strfind+0xc>
			break;
	return (char *) s;
}
  80085c:	5d                   	pop    %ebp
  80085d:	c3                   	ret    

0080085e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80085e:	55                   	push   %ebp
  80085f:	89 e5                	mov    %esp,%ebp
  800861:	57                   	push   %edi
  800862:	56                   	push   %esi
  800863:	53                   	push   %ebx
  800864:	8b 7d 08             	mov    0x8(%ebp),%edi
  800867:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80086a:	85 c9                	test   %ecx,%ecx
  80086c:	74 36                	je     8008a4 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80086e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800874:	75 28                	jne    80089e <memset+0x40>
  800876:	f6 c1 03             	test   $0x3,%cl
  800879:	75 23                	jne    80089e <memset+0x40>
		c &= 0xFF;
  80087b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80087f:	89 d3                	mov    %edx,%ebx
  800881:	c1 e3 08             	shl    $0x8,%ebx
  800884:	89 d6                	mov    %edx,%esi
  800886:	c1 e6 18             	shl    $0x18,%esi
  800889:	89 d0                	mov    %edx,%eax
  80088b:	c1 e0 10             	shl    $0x10,%eax
  80088e:	09 f0                	or     %esi,%eax
  800890:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800892:	89 d8                	mov    %ebx,%eax
  800894:	09 d0                	or     %edx,%eax
  800896:	c1 e9 02             	shr    $0x2,%ecx
  800899:	fc                   	cld    
  80089a:	f3 ab                	rep stos %eax,%es:(%edi)
  80089c:	eb 06                	jmp    8008a4 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80089e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a1:	fc                   	cld    
  8008a2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008a4:	89 f8                	mov    %edi,%eax
  8008a6:	5b                   	pop    %ebx
  8008a7:	5e                   	pop    %esi
  8008a8:	5f                   	pop    %edi
  8008a9:	5d                   	pop    %ebp
  8008aa:	c3                   	ret    

008008ab <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	57                   	push   %edi
  8008af:	56                   	push   %esi
  8008b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008b6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008b9:	39 c6                	cmp    %eax,%esi
  8008bb:	73 35                	jae    8008f2 <memmove+0x47>
  8008bd:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008c0:	39 d0                	cmp    %edx,%eax
  8008c2:	73 2e                	jae    8008f2 <memmove+0x47>
		s += n;
		d += n;
  8008c4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008c7:	89 d6                	mov    %edx,%esi
  8008c9:	09 fe                	or     %edi,%esi
  8008cb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008d1:	75 13                	jne    8008e6 <memmove+0x3b>
  8008d3:	f6 c1 03             	test   $0x3,%cl
  8008d6:	75 0e                	jne    8008e6 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008d8:	83 ef 04             	sub    $0x4,%edi
  8008db:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008de:	c1 e9 02             	shr    $0x2,%ecx
  8008e1:	fd                   	std    
  8008e2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008e4:	eb 09                	jmp    8008ef <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008e6:	83 ef 01             	sub    $0x1,%edi
  8008e9:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008ec:	fd                   	std    
  8008ed:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008ef:	fc                   	cld    
  8008f0:	eb 1d                	jmp    80090f <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008f2:	89 f2                	mov    %esi,%edx
  8008f4:	09 c2                	or     %eax,%edx
  8008f6:	f6 c2 03             	test   $0x3,%dl
  8008f9:	75 0f                	jne    80090a <memmove+0x5f>
  8008fb:	f6 c1 03             	test   $0x3,%cl
  8008fe:	75 0a                	jne    80090a <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800900:	c1 e9 02             	shr    $0x2,%ecx
  800903:	89 c7                	mov    %eax,%edi
  800905:	fc                   	cld    
  800906:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800908:	eb 05                	jmp    80090f <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80090a:	89 c7                	mov    %eax,%edi
  80090c:	fc                   	cld    
  80090d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80090f:	5e                   	pop    %esi
  800910:	5f                   	pop    %edi
  800911:	5d                   	pop    %ebp
  800912:	c3                   	ret    

00800913 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800913:	55                   	push   %ebp
  800914:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800916:	ff 75 10             	pushl  0x10(%ebp)
  800919:	ff 75 0c             	pushl  0xc(%ebp)
  80091c:	ff 75 08             	pushl  0x8(%ebp)
  80091f:	e8 87 ff ff ff       	call   8008ab <memmove>
}
  800924:	c9                   	leave  
  800925:	c3                   	ret    

00800926 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800926:	55                   	push   %ebp
  800927:	89 e5                	mov    %esp,%ebp
  800929:	56                   	push   %esi
  80092a:	53                   	push   %ebx
  80092b:	8b 45 08             	mov    0x8(%ebp),%eax
  80092e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800931:	89 c6                	mov    %eax,%esi
  800933:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800936:	eb 1a                	jmp    800952 <memcmp+0x2c>
		if (*s1 != *s2)
  800938:	0f b6 08             	movzbl (%eax),%ecx
  80093b:	0f b6 1a             	movzbl (%edx),%ebx
  80093e:	38 d9                	cmp    %bl,%cl
  800940:	74 0a                	je     80094c <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800942:	0f b6 c1             	movzbl %cl,%eax
  800945:	0f b6 db             	movzbl %bl,%ebx
  800948:	29 d8                	sub    %ebx,%eax
  80094a:	eb 0f                	jmp    80095b <memcmp+0x35>
		s1++, s2++;
  80094c:	83 c0 01             	add    $0x1,%eax
  80094f:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800952:	39 f0                	cmp    %esi,%eax
  800954:	75 e2                	jne    800938 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800956:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80095b:	5b                   	pop    %ebx
  80095c:	5e                   	pop    %esi
  80095d:	5d                   	pop    %ebp
  80095e:	c3                   	ret    

0080095f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80095f:	55                   	push   %ebp
  800960:	89 e5                	mov    %esp,%ebp
  800962:	53                   	push   %ebx
  800963:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800966:	89 c1                	mov    %eax,%ecx
  800968:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80096b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80096f:	eb 0a                	jmp    80097b <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800971:	0f b6 10             	movzbl (%eax),%edx
  800974:	39 da                	cmp    %ebx,%edx
  800976:	74 07                	je     80097f <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800978:	83 c0 01             	add    $0x1,%eax
  80097b:	39 c8                	cmp    %ecx,%eax
  80097d:	72 f2                	jb     800971 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80097f:	5b                   	pop    %ebx
  800980:	5d                   	pop    %ebp
  800981:	c3                   	ret    

00800982 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
  800985:	57                   	push   %edi
  800986:	56                   	push   %esi
  800987:	53                   	push   %ebx
  800988:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80098b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80098e:	eb 03                	jmp    800993 <strtol+0x11>
		s++;
  800990:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800993:	0f b6 01             	movzbl (%ecx),%eax
  800996:	3c 20                	cmp    $0x20,%al
  800998:	74 f6                	je     800990 <strtol+0xe>
  80099a:	3c 09                	cmp    $0x9,%al
  80099c:	74 f2                	je     800990 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80099e:	3c 2b                	cmp    $0x2b,%al
  8009a0:	75 0a                	jne    8009ac <strtol+0x2a>
		s++;
  8009a2:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009a5:	bf 00 00 00 00       	mov    $0x0,%edi
  8009aa:	eb 11                	jmp    8009bd <strtol+0x3b>
  8009ac:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009b1:	3c 2d                	cmp    $0x2d,%al
  8009b3:	75 08                	jne    8009bd <strtol+0x3b>
		s++, neg = 1;
  8009b5:	83 c1 01             	add    $0x1,%ecx
  8009b8:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009bd:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009c3:	75 15                	jne    8009da <strtol+0x58>
  8009c5:	80 39 30             	cmpb   $0x30,(%ecx)
  8009c8:	75 10                	jne    8009da <strtol+0x58>
  8009ca:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009ce:	75 7c                	jne    800a4c <strtol+0xca>
		s += 2, base = 16;
  8009d0:	83 c1 02             	add    $0x2,%ecx
  8009d3:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009d8:	eb 16                	jmp    8009f0 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009da:	85 db                	test   %ebx,%ebx
  8009dc:	75 12                	jne    8009f0 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009de:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009e3:	80 39 30             	cmpb   $0x30,(%ecx)
  8009e6:	75 08                	jne    8009f0 <strtol+0x6e>
		s++, base = 8;
  8009e8:	83 c1 01             	add    $0x1,%ecx
  8009eb:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f5:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009f8:	0f b6 11             	movzbl (%ecx),%edx
  8009fb:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009fe:	89 f3                	mov    %esi,%ebx
  800a00:	80 fb 09             	cmp    $0x9,%bl
  800a03:	77 08                	ja     800a0d <strtol+0x8b>
			dig = *s - '0';
  800a05:	0f be d2             	movsbl %dl,%edx
  800a08:	83 ea 30             	sub    $0x30,%edx
  800a0b:	eb 22                	jmp    800a2f <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a0d:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a10:	89 f3                	mov    %esi,%ebx
  800a12:	80 fb 19             	cmp    $0x19,%bl
  800a15:	77 08                	ja     800a1f <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a17:	0f be d2             	movsbl %dl,%edx
  800a1a:	83 ea 57             	sub    $0x57,%edx
  800a1d:	eb 10                	jmp    800a2f <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a1f:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a22:	89 f3                	mov    %esi,%ebx
  800a24:	80 fb 19             	cmp    $0x19,%bl
  800a27:	77 16                	ja     800a3f <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a29:	0f be d2             	movsbl %dl,%edx
  800a2c:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a2f:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a32:	7d 0b                	jge    800a3f <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a34:	83 c1 01             	add    $0x1,%ecx
  800a37:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a3b:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a3d:	eb b9                	jmp    8009f8 <strtol+0x76>

	if (endptr)
  800a3f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a43:	74 0d                	je     800a52 <strtol+0xd0>
		*endptr = (char *) s;
  800a45:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a48:	89 0e                	mov    %ecx,(%esi)
  800a4a:	eb 06                	jmp    800a52 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a4c:	85 db                	test   %ebx,%ebx
  800a4e:	74 98                	je     8009e8 <strtol+0x66>
  800a50:	eb 9e                	jmp    8009f0 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a52:	89 c2                	mov    %eax,%edx
  800a54:	f7 da                	neg    %edx
  800a56:	85 ff                	test   %edi,%edi
  800a58:	0f 45 c2             	cmovne %edx,%eax
}
  800a5b:	5b                   	pop    %ebx
  800a5c:	5e                   	pop    %esi
  800a5d:	5f                   	pop    %edi
  800a5e:	5d                   	pop    %ebp
  800a5f:	c3                   	ret    

00800a60 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a60:	55                   	push   %ebp
  800a61:	89 e5                	mov    %esp,%ebp
  800a63:	57                   	push   %edi
  800a64:	56                   	push   %esi
  800a65:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a66:	b8 00 00 00 00       	mov    $0x0,%eax
  800a6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a71:	89 c3                	mov    %eax,%ebx
  800a73:	89 c7                	mov    %eax,%edi
  800a75:	89 c6                	mov    %eax,%esi
  800a77:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a79:	5b                   	pop    %ebx
  800a7a:	5e                   	pop    %esi
  800a7b:	5f                   	pop    %edi
  800a7c:	5d                   	pop    %ebp
  800a7d:	c3                   	ret    

00800a7e <sys_cgetc>:

int
sys_cgetc(void)
{
  800a7e:	55                   	push   %ebp
  800a7f:	89 e5                	mov    %esp,%ebp
  800a81:	57                   	push   %edi
  800a82:	56                   	push   %esi
  800a83:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a84:	ba 00 00 00 00       	mov    $0x0,%edx
  800a89:	b8 01 00 00 00       	mov    $0x1,%eax
  800a8e:	89 d1                	mov    %edx,%ecx
  800a90:	89 d3                	mov    %edx,%ebx
  800a92:	89 d7                	mov    %edx,%edi
  800a94:	89 d6                	mov    %edx,%esi
  800a96:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a98:	5b                   	pop    %ebx
  800a99:	5e                   	pop    %esi
  800a9a:	5f                   	pop    %edi
  800a9b:	5d                   	pop    %ebp
  800a9c:	c3                   	ret    

00800a9d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a9d:	55                   	push   %ebp
  800a9e:	89 e5                	mov    %esp,%ebp
  800aa0:	57                   	push   %edi
  800aa1:	56                   	push   %esi
  800aa2:	53                   	push   %ebx
  800aa3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aab:	b8 03 00 00 00       	mov    $0x3,%eax
  800ab0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab3:	89 cb                	mov    %ecx,%ebx
  800ab5:	89 cf                	mov    %ecx,%edi
  800ab7:	89 ce                	mov    %ecx,%esi
  800ab9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800abb:	85 c0                	test   %eax,%eax
  800abd:	7e 17                	jle    800ad6 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800abf:	83 ec 0c             	sub    $0xc,%esp
  800ac2:	50                   	push   %eax
  800ac3:	6a 03                	push   $0x3
  800ac5:	68 ff 25 80 00       	push   $0x8025ff
  800aca:	6a 23                	push   $0x23
  800acc:	68 1c 26 80 00       	push   $0x80261c
  800ad1:	e8 c6 14 00 00       	call   801f9c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ad6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ad9:	5b                   	pop    %ebx
  800ada:	5e                   	pop    %esi
  800adb:	5f                   	pop    %edi
  800adc:	5d                   	pop    %ebp
  800add:	c3                   	ret    

00800ade <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ade:	55                   	push   %ebp
  800adf:	89 e5                	mov    %esp,%ebp
  800ae1:	57                   	push   %edi
  800ae2:	56                   	push   %esi
  800ae3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae9:	b8 02 00 00 00       	mov    $0x2,%eax
  800aee:	89 d1                	mov    %edx,%ecx
  800af0:	89 d3                	mov    %edx,%ebx
  800af2:	89 d7                	mov    %edx,%edi
  800af4:	89 d6                	mov    %edx,%esi
  800af6:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800af8:	5b                   	pop    %ebx
  800af9:	5e                   	pop    %esi
  800afa:	5f                   	pop    %edi
  800afb:	5d                   	pop    %ebp
  800afc:	c3                   	ret    

00800afd <sys_yield>:

void
sys_yield(void)
{
  800afd:	55                   	push   %ebp
  800afe:	89 e5                	mov    %esp,%ebp
  800b00:	57                   	push   %edi
  800b01:	56                   	push   %esi
  800b02:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b03:	ba 00 00 00 00       	mov    $0x0,%edx
  800b08:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b0d:	89 d1                	mov    %edx,%ecx
  800b0f:	89 d3                	mov    %edx,%ebx
  800b11:	89 d7                	mov    %edx,%edi
  800b13:	89 d6                	mov    %edx,%esi
  800b15:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b17:	5b                   	pop    %ebx
  800b18:	5e                   	pop    %esi
  800b19:	5f                   	pop    %edi
  800b1a:	5d                   	pop    %ebp
  800b1b:	c3                   	ret    

00800b1c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800b25:	be 00 00 00 00       	mov    $0x0,%esi
  800b2a:	b8 04 00 00 00       	mov    $0x4,%eax
  800b2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b32:	8b 55 08             	mov    0x8(%ebp),%edx
  800b35:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b38:	89 f7                	mov    %esi,%edi
  800b3a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b3c:	85 c0                	test   %eax,%eax
  800b3e:	7e 17                	jle    800b57 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b40:	83 ec 0c             	sub    $0xc,%esp
  800b43:	50                   	push   %eax
  800b44:	6a 04                	push   $0x4
  800b46:	68 ff 25 80 00       	push   $0x8025ff
  800b4b:	6a 23                	push   $0x23
  800b4d:	68 1c 26 80 00       	push   $0x80261c
  800b52:	e8 45 14 00 00       	call   801f9c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b57:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b5a:	5b                   	pop    %ebx
  800b5b:	5e                   	pop    %esi
  800b5c:	5f                   	pop    %edi
  800b5d:	5d                   	pop    %ebp
  800b5e:	c3                   	ret    

00800b5f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b5f:	55                   	push   %ebp
  800b60:	89 e5                	mov    %esp,%ebp
  800b62:	57                   	push   %edi
  800b63:	56                   	push   %esi
  800b64:	53                   	push   %ebx
  800b65:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b68:	b8 05 00 00 00       	mov    $0x5,%eax
  800b6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b70:	8b 55 08             	mov    0x8(%ebp),%edx
  800b73:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b76:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b79:	8b 75 18             	mov    0x18(%ebp),%esi
  800b7c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b7e:	85 c0                	test   %eax,%eax
  800b80:	7e 17                	jle    800b99 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b82:	83 ec 0c             	sub    $0xc,%esp
  800b85:	50                   	push   %eax
  800b86:	6a 05                	push   $0x5
  800b88:	68 ff 25 80 00       	push   $0x8025ff
  800b8d:	6a 23                	push   $0x23
  800b8f:	68 1c 26 80 00       	push   $0x80261c
  800b94:	e8 03 14 00 00       	call   801f9c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b9c:	5b                   	pop    %ebx
  800b9d:	5e                   	pop    %esi
  800b9e:	5f                   	pop    %edi
  800b9f:	5d                   	pop    %ebp
  800ba0:	c3                   	ret    

00800ba1 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ba1:	55                   	push   %ebp
  800ba2:	89 e5                	mov    %esp,%ebp
  800ba4:	57                   	push   %edi
  800ba5:	56                   	push   %esi
  800ba6:	53                   	push   %ebx
  800ba7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800baa:	bb 00 00 00 00       	mov    $0x0,%ebx
  800baf:	b8 06 00 00 00       	mov    $0x6,%eax
  800bb4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb7:	8b 55 08             	mov    0x8(%ebp),%edx
  800bba:	89 df                	mov    %ebx,%edi
  800bbc:	89 de                	mov    %ebx,%esi
  800bbe:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bc0:	85 c0                	test   %eax,%eax
  800bc2:	7e 17                	jle    800bdb <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc4:	83 ec 0c             	sub    $0xc,%esp
  800bc7:	50                   	push   %eax
  800bc8:	6a 06                	push   $0x6
  800bca:	68 ff 25 80 00       	push   $0x8025ff
  800bcf:	6a 23                	push   $0x23
  800bd1:	68 1c 26 80 00       	push   $0x80261c
  800bd6:	e8 c1 13 00 00       	call   801f9c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bdb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bde:	5b                   	pop    %ebx
  800bdf:	5e                   	pop    %esi
  800be0:	5f                   	pop    %edi
  800be1:	5d                   	pop    %ebp
  800be2:	c3                   	ret    

00800be3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800be3:	55                   	push   %ebp
  800be4:	89 e5                	mov    %esp,%ebp
  800be6:	57                   	push   %edi
  800be7:	56                   	push   %esi
  800be8:	53                   	push   %ebx
  800be9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bec:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bf1:	b8 08 00 00 00       	mov    $0x8,%eax
  800bf6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfc:	89 df                	mov    %ebx,%edi
  800bfe:	89 de                	mov    %ebx,%esi
  800c00:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c02:	85 c0                	test   %eax,%eax
  800c04:	7e 17                	jle    800c1d <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c06:	83 ec 0c             	sub    $0xc,%esp
  800c09:	50                   	push   %eax
  800c0a:	6a 08                	push   $0x8
  800c0c:	68 ff 25 80 00       	push   $0x8025ff
  800c11:	6a 23                	push   $0x23
  800c13:	68 1c 26 80 00       	push   $0x80261c
  800c18:	e8 7f 13 00 00       	call   801f9c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c1d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c20:	5b                   	pop    %ebx
  800c21:	5e                   	pop    %esi
  800c22:	5f                   	pop    %edi
  800c23:	5d                   	pop    %ebp
  800c24:	c3                   	ret    

00800c25 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c25:	55                   	push   %ebp
  800c26:	89 e5                	mov    %esp,%ebp
  800c28:	57                   	push   %edi
  800c29:	56                   	push   %esi
  800c2a:	53                   	push   %ebx
  800c2b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c33:	b8 09 00 00 00       	mov    $0x9,%eax
  800c38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3e:	89 df                	mov    %ebx,%edi
  800c40:	89 de                	mov    %ebx,%esi
  800c42:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c44:	85 c0                	test   %eax,%eax
  800c46:	7e 17                	jle    800c5f <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c48:	83 ec 0c             	sub    $0xc,%esp
  800c4b:	50                   	push   %eax
  800c4c:	6a 09                	push   $0x9
  800c4e:	68 ff 25 80 00       	push   $0x8025ff
  800c53:	6a 23                	push   $0x23
  800c55:	68 1c 26 80 00       	push   $0x80261c
  800c5a:	e8 3d 13 00 00       	call   801f9c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c62:	5b                   	pop    %ebx
  800c63:	5e                   	pop    %esi
  800c64:	5f                   	pop    %edi
  800c65:	5d                   	pop    %ebp
  800c66:	c3                   	ret    

00800c67 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c67:	55                   	push   %ebp
  800c68:	89 e5                	mov    %esp,%ebp
  800c6a:	57                   	push   %edi
  800c6b:	56                   	push   %esi
  800c6c:	53                   	push   %ebx
  800c6d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c70:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c75:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c7a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c80:	89 df                	mov    %ebx,%edi
  800c82:	89 de                	mov    %ebx,%esi
  800c84:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c86:	85 c0                	test   %eax,%eax
  800c88:	7e 17                	jle    800ca1 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8a:	83 ec 0c             	sub    $0xc,%esp
  800c8d:	50                   	push   %eax
  800c8e:	6a 0a                	push   $0xa
  800c90:	68 ff 25 80 00       	push   $0x8025ff
  800c95:	6a 23                	push   $0x23
  800c97:	68 1c 26 80 00       	push   $0x80261c
  800c9c:	e8 fb 12 00 00       	call   801f9c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ca1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca4:	5b                   	pop    %ebx
  800ca5:	5e                   	pop    %esi
  800ca6:	5f                   	pop    %edi
  800ca7:	5d                   	pop    %ebp
  800ca8:	c3                   	ret    

00800ca9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ca9:	55                   	push   %ebp
  800caa:	89 e5                	mov    %esp,%ebp
  800cac:	57                   	push   %edi
  800cad:	56                   	push   %esi
  800cae:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800caf:	be 00 00 00 00       	mov    $0x0,%esi
  800cb4:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbc:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cc5:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cc7:	5b                   	pop    %ebx
  800cc8:	5e                   	pop    %esi
  800cc9:	5f                   	pop    %edi
  800cca:	5d                   	pop    %ebp
  800ccb:	c3                   	ret    

00800ccc <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ccc:	55                   	push   %ebp
  800ccd:	89 e5                	mov    %esp,%ebp
  800ccf:	57                   	push   %edi
  800cd0:	56                   	push   %esi
  800cd1:	53                   	push   %ebx
  800cd2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cda:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cdf:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce2:	89 cb                	mov    %ecx,%ebx
  800ce4:	89 cf                	mov    %ecx,%edi
  800ce6:	89 ce                	mov    %ecx,%esi
  800ce8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cea:	85 c0                	test   %eax,%eax
  800cec:	7e 17                	jle    800d05 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cee:	83 ec 0c             	sub    $0xc,%esp
  800cf1:	50                   	push   %eax
  800cf2:	6a 0d                	push   $0xd
  800cf4:	68 ff 25 80 00       	push   $0x8025ff
  800cf9:	6a 23                	push   $0x23
  800cfb:	68 1c 26 80 00       	push   $0x80261c
  800d00:	e8 97 12 00 00       	call   801f9c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d05:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d08:	5b                   	pop    %ebx
  800d09:	5e                   	pop    %esi
  800d0a:	5f                   	pop    %edi
  800d0b:	5d                   	pop    %ebp
  800d0c:	c3                   	ret    

00800d0d <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d0d:	55                   	push   %ebp
  800d0e:	89 e5                	mov    %esp,%ebp
  800d10:	57                   	push   %edi
  800d11:	56                   	push   %esi
  800d12:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d13:	ba 00 00 00 00       	mov    $0x0,%edx
  800d18:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d1d:	89 d1                	mov    %edx,%ecx
  800d1f:	89 d3                	mov    %edx,%ebx
  800d21:	89 d7                	mov    %edx,%edi
  800d23:	89 d6                	mov    %edx,%esi
  800d25:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d27:	5b                   	pop    %ebx
  800d28:	5e                   	pop    %esi
  800d29:	5f                   	pop    %edi
  800d2a:	5d                   	pop    %ebp
  800d2b:	c3                   	ret    

00800d2c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800d2c:	55                   	push   %ebp
  800d2d:	89 e5                	mov    %esp,%ebp
  800d2f:	56                   	push   %esi
  800d30:	53                   	push   %ebx
  800d31:	8b 75 08             	mov    0x8(%ebp),%esi
  800d34:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d37:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  800d3a:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  800d3c:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  800d41:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  800d44:	83 ec 0c             	sub    $0xc,%esp
  800d47:	50                   	push   %eax
  800d48:	e8 7f ff ff ff       	call   800ccc <sys_ipc_recv>

	if (r < 0) {
  800d4d:	83 c4 10             	add    $0x10,%esp
  800d50:	85 c0                	test   %eax,%eax
  800d52:	79 16                	jns    800d6a <ipc_recv+0x3e>
		if (from_env_store)
  800d54:	85 f6                	test   %esi,%esi
  800d56:	74 06                	je     800d5e <ipc_recv+0x32>
			*from_env_store = 0;
  800d58:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  800d5e:	85 db                	test   %ebx,%ebx
  800d60:	74 2c                	je     800d8e <ipc_recv+0x62>
			*perm_store = 0;
  800d62:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800d68:	eb 24                	jmp    800d8e <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  800d6a:	85 f6                	test   %esi,%esi
  800d6c:	74 0a                	je     800d78 <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  800d6e:	a1 08 40 80 00       	mov    0x804008,%eax
  800d73:	8b 40 74             	mov    0x74(%eax),%eax
  800d76:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  800d78:	85 db                	test   %ebx,%ebx
  800d7a:	74 0a                	je     800d86 <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  800d7c:	a1 08 40 80 00       	mov    0x804008,%eax
  800d81:	8b 40 78             	mov    0x78(%eax),%eax
  800d84:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  800d86:	a1 08 40 80 00       	mov    0x804008,%eax
  800d8b:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  800d8e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d91:	5b                   	pop    %ebx
  800d92:	5e                   	pop    %esi
  800d93:	5d                   	pop    %ebp
  800d94:	c3                   	ret    

00800d95 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800d95:	55                   	push   %ebp
  800d96:	89 e5                	mov    %esp,%ebp
  800d98:	57                   	push   %edi
  800d99:	56                   	push   %esi
  800d9a:	53                   	push   %ebx
  800d9b:	83 ec 0c             	sub    $0xc,%esp
  800d9e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800da1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800da4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  800da7:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  800da9:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  800dae:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  800db1:	ff 75 14             	pushl  0x14(%ebp)
  800db4:	53                   	push   %ebx
  800db5:	56                   	push   %esi
  800db6:	57                   	push   %edi
  800db7:	e8 ed fe ff ff       	call   800ca9 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  800dbc:	83 c4 10             	add    $0x10,%esp
  800dbf:	83 f8 f9             	cmp    $0xfffffff9,%eax
  800dc2:	75 07                	jne    800dcb <ipc_send+0x36>
			sys_yield();
  800dc4:	e8 34 fd ff ff       	call   800afd <sys_yield>
  800dc9:	eb e6                	jmp    800db1 <ipc_send+0x1c>
		} else if (r < 0) {
  800dcb:	85 c0                	test   %eax,%eax
  800dcd:	79 12                	jns    800de1 <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  800dcf:	50                   	push   %eax
  800dd0:	68 2a 26 80 00       	push   $0x80262a
  800dd5:	6a 51                	push   $0x51
  800dd7:	68 37 26 80 00       	push   $0x802637
  800ddc:	e8 bb 11 00 00       	call   801f9c <_panic>
		}
	}
}
  800de1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de4:	5b                   	pop    %ebx
  800de5:	5e                   	pop    %esi
  800de6:	5f                   	pop    %edi
  800de7:	5d                   	pop    %ebp
  800de8:	c3                   	ret    

00800de9 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800de9:	55                   	push   %ebp
  800dea:	89 e5                	mov    %esp,%ebp
  800dec:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800def:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800df4:	6b d0 7c             	imul   $0x7c,%eax,%edx
  800df7:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800dfd:	8b 52 50             	mov    0x50(%edx),%edx
  800e00:	39 ca                	cmp    %ecx,%edx
  800e02:	75 0d                	jne    800e11 <ipc_find_env+0x28>
			return envs[i].env_id;
  800e04:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800e07:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e0c:	8b 40 48             	mov    0x48(%eax),%eax
  800e0f:	eb 0f                	jmp    800e20 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800e11:	83 c0 01             	add    $0x1,%eax
  800e14:	3d 00 04 00 00       	cmp    $0x400,%eax
  800e19:	75 d9                	jne    800df4 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  800e1b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e20:	5d                   	pop    %ebp
  800e21:	c3                   	ret    

00800e22 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e22:	55                   	push   %ebp
  800e23:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e25:	8b 45 08             	mov    0x8(%ebp),%eax
  800e28:	05 00 00 00 30       	add    $0x30000000,%eax
  800e2d:	c1 e8 0c             	shr    $0xc,%eax
}
  800e30:	5d                   	pop    %ebp
  800e31:	c3                   	ret    

00800e32 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e32:	55                   	push   %ebp
  800e33:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e35:	8b 45 08             	mov    0x8(%ebp),%eax
  800e38:	05 00 00 00 30       	add    $0x30000000,%eax
  800e3d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e42:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e47:	5d                   	pop    %ebp
  800e48:	c3                   	ret    

00800e49 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e49:	55                   	push   %ebp
  800e4a:	89 e5                	mov    %esp,%ebp
  800e4c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e4f:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e54:	89 c2                	mov    %eax,%edx
  800e56:	c1 ea 16             	shr    $0x16,%edx
  800e59:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e60:	f6 c2 01             	test   $0x1,%dl
  800e63:	74 11                	je     800e76 <fd_alloc+0x2d>
  800e65:	89 c2                	mov    %eax,%edx
  800e67:	c1 ea 0c             	shr    $0xc,%edx
  800e6a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e71:	f6 c2 01             	test   $0x1,%dl
  800e74:	75 09                	jne    800e7f <fd_alloc+0x36>
			*fd_store = fd;
  800e76:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e78:	b8 00 00 00 00       	mov    $0x0,%eax
  800e7d:	eb 17                	jmp    800e96 <fd_alloc+0x4d>
  800e7f:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e84:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e89:	75 c9                	jne    800e54 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e8b:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e91:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e96:	5d                   	pop    %ebp
  800e97:	c3                   	ret    

00800e98 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e98:	55                   	push   %ebp
  800e99:	89 e5                	mov    %esp,%ebp
  800e9b:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e9e:	83 f8 1f             	cmp    $0x1f,%eax
  800ea1:	77 36                	ja     800ed9 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800ea3:	c1 e0 0c             	shl    $0xc,%eax
  800ea6:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800eab:	89 c2                	mov    %eax,%edx
  800ead:	c1 ea 16             	shr    $0x16,%edx
  800eb0:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800eb7:	f6 c2 01             	test   $0x1,%dl
  800eba:	74 24                	je     800ee0 <fd_lookup+0x48>
  800ebc:	89 c2                	mov    %eax,%edx
  800ebe:	c1 ea 0c             	shr    $0xc,%edx
  800ec1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ec8:	f6 c2 01             	test   $0x1,%dl
  800ecb:	74 1a                	je     800ee7 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800ecd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ed0:	89 02                	mov    %eax,(%edx)
	return 0;
  800ed2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed7:	eb 13                	jmp    800eec <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ed9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ede:	eb 0c                	jmp    800eec <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ee0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ee5:	eb 05                	jmp    800eec <fd_lookup+0x54>
  800ee7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800eec:	5d                   	pop    %ebp
  800eed:	c3                   	ret    

00800eee <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800eee:	55                   	push   %ebp
  800eef:	89 e5                	mov    %esp,%ebp
  800ef1:	83 ec 08             	sub    $0x8,%esp
  800ef4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ef7:	ba c0 26 80 00       	mov    $0x8026c0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800efc:	eb 13                	jmp    800f11 <dev_lookup+0x23>
  800efe:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f01:	39 08                	cmp    %ecx,(%eax)
  800f03:	75 0c                	jne    800f11 <dev_lookup+0x23>
			*dev = devtab[i];
  800f05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f08:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f0a:	b8 00 00 00 00       	mov    $0x0,%eax
  800f0f:	eb 2e                	jmp    800f3f <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f11:	8b 02                	mov    (%edx),%eax
  800f13:	85 c0                	test   %eax,%eax
  800f15:	75 e7                	jne    800efe <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f17:	a1 08 40 80 00       	mov    0x804008,%eax
  800f1c:	8b 40 48             	mov    0x48(%eax),%eax
  800f1f:	83 ec 04             	sub    $0x4,%esp
  800f22:	51                   	push   %ecx
  800f23:	50                   	push   %eax
  800f24:	68 44 26 80 00       	push   $0x802644
  800f29:	e8 66 f2 ff ff       	call   800194 <cprintf>
	*dev = 0;
  800f2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f31:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f37:	83 c4 10             	add    $0x10,%esp
  800f3a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f3f:	c9                   	leave  
  800f40:	c3                   	ret    

00800f41 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f41:	55                   	push   %ebp
  800f42:	89 e5                	mov    %esp,%ebp
  800f44:	56                   	push   %esi
  800f45:	53                   	push   %ebx
  800f46:	83 ec 10             	sub    $0x10,%esp
  800f49:	8b 75 08             	mov    0x8(%ebp),%esi
  800f4c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f4f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f52:	50                   	push   %eax
  800f53:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f59:	c1 e8 0c             	shr    $0xc,%eax
  800f5c:	50                   	push   %eax
  800f5d:	e8 36 ff ff ff       	call   800e98 <fd_lookup>
  800f62:	83 c4 08             	add    $0x8,%esp
  800f65:	85 c0                	test   %eax,%eax
  800f67:	78 05                	js     800f6e <fd_close+0x2d>
	    || fd != fd2)
  800f69:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f6c:	74 0c                	je     800f7a <fd_close+0x39>
		return (must_exist ? r : 0);
  800f6e:	84 db                	test   %bl,%bl
  800f70:	ba 00 00 00 00       	mov    $0x0,%edx
  800f75:	0f 44 c2             	cmove  %edx,%eax
  800f78:	eb 41                	jmp    800fbb <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f7a:	83 ec 08             	sub    $0x8,%esp
  800f7d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f80:	50                   	push   %eax
  800f81:	ff 36                	pushl  (%esi)
  800f83:	e8 66 ff ff ff       	call   800eee <dev_lookup>
  800f88:	89 c3                	mov    %eax,%ebx
  800f8a:	83 c4 10             	add    $0x10,%esp
  800f8d:	85 c0                	test   %eax,%eax
  800f8f:	78 1a                	js     800fab <fd_close+0x6a>
		if (dev->dev_close)
  800f91:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f94:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f97:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f9c:	85 c0                	test   %eax,%eax
  800f9e:	74 0b                	je     800fab <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800fa0:	83 ec 0c             	sub    $0xc,%esp
  800fa3:	56                   	push   %esi
  800fa4:	ff d0                	call   *%eax
  800fa6:	89 c3                	mov    %eax,%ebx
  800fa8:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800fab:	83 ec 08             	sub    $0x8,%esp
  800fae:	56                   	push   %esi
  800faf:	6a 00                	push   $0x0
  800fb1:	e8 eb fb ff ff       	call   800ba1 <sys_page_unmap>
	return r;
  800fb6:	83 c4 10             	add    $0x10,%esp
  800fb9:	89 d8                	mov    %ebx,%eax
}
  800fbb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fbe:	5b                   	pop    %ebx
  800fbf:	5e                   	pop    %esi
  800fc0:	5d                   	pop    %ebp
  800fc1:	c3                   	ret    

00800fc2 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800fc2:	55                   	push   %ebp
  800fc3:	89 e5                	mov    %esp,%ebp
  800fc5:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fc8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fcb:	50                   	push   %eax
  800fcc:	ff 75 08             	pushl  0x8(%ebp)
  800fcf:	e8 c4 fe ff ff       	call   800e98 <fd_lookup>
  800fd4:	83 c4 08             	add    $0x8,%esp
  800fd7:	85 c0                	test   %eax,%eax
  800fd9:	78 10                	js     800feb <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800fdb:	83 ec 08             	sub    $0x8,%esp
  800fde:	6a 01                	push   $0x1
  800fe0:	ff 75 f4             	pushl  -0xc(%ebp)
  800fe3:	e8 59 ff ff ff       	call   800f41 <fd_close>
  800fe8:	83 c4 10             	add    $0x10,%esp
}
  800feb:	c9                   	leave  
  800fec:	c3                   	ret    

00800fed <close_all>:

void
close_all(void)
{
  800fed:	55                   	push   %ebp
  800fee:	89 e5                	mov    %esp,%ebp
  800ff0:	53                   	push   %ebx
  800ff1:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800ff4:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800ff9:	83 ec 0c             	sub    $0xc,%esp
  800ffc:	53                   	push   %ebx
  800ffd:	e8 c0 ff ff ff       	call   800fc2 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801002:	83 c3 01             	add    $0x1,%ebx
  801005:	83 c4 10             	add    $0x10,%esp
  801008:	83 fb 20             	cmp    $0x20,%ebx
  80100b:	75 ec                	jne    800ff9 <close_all+0xc>
		close(i);
}
  80100d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801010:	c9                   	leave  
  801011:	c3                   	ret    

00801012 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801012:	55                   	push   %ebp
  801013:	89 e5                	mov    %esp,%ebp
  801015:	57                   	push   %edi
  801016:	56                   	push   %esi
  801017:	53                   	push   %ebx
  801018:	83 ec 2c             	sub    $0x2c,%esp
  80101b:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80101e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801021:	50                   	push   %eax
  801022:	ff 75 08             	pushl  0x8(%ebp)
  801025:	e8 6e fe ff ff       	call   800e98 <fd_lookup>
  80102a:	83 c4 08             	add    $0x8,%esp
  80102d:	85 c0                	test   %eax,%eax
  80102f:	0f 88 c1 00 00 00    	js     8010f6 <dup+0xe4>
		return r;
	close(newfdnum);
  801035:	83 ec 0c             	sub    $0xc,%esp
  801038:	56                   	push   %esi
  801039:	e8 84 ff ff ff       	call   800fc2 <close>

	newfd = INDEX2FD(newfdnum);
  80103e:	89 f3                	mov    %esi,%ebx
  801040:	c1 e3 0c             	shl    $0xc,%ebx
  801043:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801049:	83 c4 04             	add    $0x4,%esp
  80104c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80104f:	e8 de fd ff ff       	call   800e32 <fd2data>
  801054:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801056:	89 1c 24             	mov    %ebx,(%esp)
  801059:	e8 d4 fd ff ff       	call   800e32 <fd2data>
  80105e:	83 c4 10             	add    $0x10,%esp
  801061:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801064:	89 f8                	mov    %edi,%eax
  801066:	c1 e8 16             	shr    $0x16,%eax
  801069:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801070:	a8 01                	test   $0x1,%al
  801072:	74 37                	je     8010ab <dup+0x99>
  801074:	89 f8                	mov    %edi,%eax
  801076:	c1 e8 0c             	shr    $0xc,%eax
  801079:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801080:	f6 c2 01             	test   $0x1,%dl
  801083:	74 26                	je     8010ab <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801085:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80108c:	83 ec 0c             	sub    $0xc,%esp
  80108f:	25 07 0e 00 00       	and    $0xe07,%eax
  801094:	50                   	push   %eax
  801095:	ff 75 d4             	pushl  -0x2c(%ebp)
  801098:	6a 00                	push   $0x0
  80109a:	57                   	push   %edi
  80109b:	6a 00                	push   $0x0
  80109d:	e8 bd fa ff ff       	call   800b5f <sys_page_map>
  8010a2:	89 c7                	mov    %eax,%edi
  8010a4:	83 c4 20             	add    $0x20,%esp
  8010a7:	85 c0                	test   %eax,%eax
  8010a9:	78 2e                	js     8010d9 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010ab:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8010ae:	89 d0                	mov    %edx,%eax
  8010b0:	c1 e8 0c             	shr    $0xc,%eax
  8010b3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010ba:	83 ec 0c             	sub    $0xc,%esp
  8010bd:	25 07 0e 00 00       	and    $0xe07,%eax
  8010c2:	50                   	push   %eax
  8010c3:	53                   	push   %ebx
  8010c4:	6a 00                	push   $0x0
  8010c6:	52                   	push   %edx
  8010c7:	6a 00                	push   $0x0
  8010c9:	e8 91 fa ff ff       	call   800b5f <sys_page_map>
  8010ce:	89 c7                	mov    %eax,%edi
  8010d0:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8010d3:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010d5:	85 ff                	test   %edi,%edi
  8010d7:	79 1d                	jns    8010f6 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010d9:	83 ec 08             	sub    $0x8,%esp
  8010dc:	53                   	push   %ebx
  8010dd:	6a 00                	push   $0x0
  8010df:	e8 bd fa ff ff       	call   800ba1 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010e4:	83 c4 08             	add    $0x8,%esp
  8010e7:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010ea:	6a 00                	push   $0x0
  8010ec:	e8 b0 fa ff ff       	call   800ba1 <sys_page_unmap>
	return r;
  8010f1:	83 c4 10             	add    $0x10,%esp
  8010f4:	89 f8                	mov    %edi,%eax
}
  8010f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010f9:	5b                   	pop    %ebx
  8010fa:	5e                   	pop    %esi
  8010fb:	5f                   	pop    %edi
  8010fc:	5d                   	pop    %ebp
  8010fd:	c3                   	ret    

008010fe <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010fe:	55                   	push   %ebp
  8010ff:	89 e5                	mov    %esp,%ebp
  801101:	53                   	push   %ebx
  801102:	83 ec 14             	sub    $0x14,%esp
  801105:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801108:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80110b:	50                   	push   %eax
  80110c:	53                   	push   %ebx
  80110d:	e8 86 fd ff ff       	call   800e98 <fd_lookup>
  801112:	83 c4 08             	add    $0x8,%esp
  801115:	89 c2                	mov    %eax,%edx
  801117:	85 c0                	test   %eax,%eax
  801119:	78 6d                	js     801188 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80111b:	83 ec 08             	sub    $0x8,%esp
  80111e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801121:	50                   	push   %eax
  801122:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801125:	ff 30                	pushl  (%eax)
  801127:	e8 c2 fd ff ff       	call   800eee <dev_lookup>
  80112c:	83 c4 10             	add    $0x10,%esp
  80112f:	85 c0                	test   %eax,%eax
  801131:	78 4c                	js     80117f <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801133:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801136:	8b 42 08             	mov    0x8(%edx),%eax
  801139:	83 e0 03             	and    $0x3,%eax
  80113c:	83 f8 01             	cmp    $0x1,%eax
  80113f:	75 21                	jne    801162 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801141:	a1 08 40 80 00       	mov    0x804008,%eax
  801146:	8b 40 48             	mov    0x48(%eax),%eax
  801149:	83 ec 04             	sub    $0x4,%esp
  80114c:	53                   	push   %ebx
  80114d:	50                   	push   %eax
  80114e:	68 85 26 80 00       	push   $0x802685
  801153:	e8 3c f0 ff ff       	call   800194 <cprintf>
		return -E_INVAL;
  801158:	83 c4 10             	add    $0x10,%esp
  80115b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801160:	eb 26                	jmp    801188 <read+0x8a>
	}
	if (!dev->dev_read)
  801162:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801165:	8b 40 08             	mov    0x8(%eax),%eax
  801168:	85 c0                	test   %eax,%eax
  80116a:	74 17                	je     801183 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80116c:	83 ec 04             	sub    $0x4,%esp
  80116f:	ff 75 10             	pushl  0x10(%ebp)
  801172:	ff 75 0c             	pushl  0xc(%ebp)
  801175:	52                   	push   %edx
  801176:	ff d0                	call   *%eax
  801178:	89 c2                	mov    %eax,%edx
  80117a:	83 c4 10             	add    $0x10,%esp
  80117d:	eb 09                	jmp    801188 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80117f:	89 c2                	mov    %eax,%edx
  801181:	eb 05                	jmp    801188 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801183:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801188:	89 d0                	mov    %edx,%eax
  80118a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80118d:	c9                   	leave  
  80118e:	c3                   	ret    

0080118f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80118f:	55                   	push   %ebp
  801190:	89 e5                	mov    %esp,%ebp
  801192:	57                   	push   %edi
  801193:	56                   	push   %esi
  801194:	53                   	push   %ebx
  801195:	83 ec 0c             	sub    $0xc,%esp
  801198:	8b 7d 08             	mov    0x8(%ebp),%edi
  80119b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80119e:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011a3:	eb 21                	jmp    8011c6 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011a5:	83 ec 04             	sub    $0x4,%esp
  8011a8:	89 f0                	mov    %esi,%eax
  8011aa:	29 d8                	sub    %ebx,%eax
  8011ac:	50                   	push   %eax
  8011ad:	89 d8                	mov    %ebx,%eax
  8011af:	03 45 0c             	add    0xc(%ebp),%eax
  8011b2:	50                   	push   %eax
  8011b3:	57                   	push   %edi
  8011b4:	e8 45 ff ff ff       	call   8010fe <read>
		if (m < 0)
  8011b9:	83 c4 10             	add    $0x10,%esp
  8011bc:	85 c0                	test   %eax,%eax
  8011be:	78 10                	js     8011d0 <readn+0x41>
			return m;
		if (m == 0)
  8011c0:	85 c0                	test   %eax,%eax
  8011c2:	74 0a                	je     8011ce <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011c4:	01 c3                	add    %eax,%ebx
  8011c6:	39 f3                	cmp    %esi,%ebx
  8011c8:	72 db                	jb     8011a5 <readn+0x16>
  8011ca:	89 d8                	mov    %ebx,%eax
  8011cc:	eb 02                	jmp    8011d0 <readn+0x41>
  8011ce:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8011d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011d3:	5b                   	pop    %ebx
  8011d4:	5e                   	pop    %esi
  8011d5:	5f                   	pop    %edi
  8011d6:	5d                   	pop    %ebp
  8011d7:	c3                   	ret    

008011d8 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011d8:	55                   	push   %ebp
  8011d9:	89 e5                	mov    %esp,%ebp
  8011db:	53                   	push   %ebx
  8011dc:	83 ec 14             	sub    $0x14,%esp
  8011df:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011e2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011e5:	50                   	push   %eax
  8011e6:	53                   	push   %ebx
  8011e7:	e8 ac fc ff ff       	call   800e98 <fd_lookup>
  8011ec:	83 c4 08             	add    $0x8,%esp
  8011ef:	89 c2                	mov    %eax,%edx
  8011f1:	85 c0                	test   %eax,%eax
  8011f3:	78 68                	js     80125d <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011f5:	83 ec 08             	sub    $0x8,%esp
  8011f8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011fb:	50                   	push   %eax
  8011fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011ff:	ff 30                	pushl  (%eax)
  801201:	e8 e8 fc ff ff       	call   800eee <dev_lookup>
  801206:	83 c4 10             	add    $0x10,%esp
  801209:	85 c0                	test   %eax,%eax
  80120b:	78 47                	js     801254 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80120d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801210:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801214:	75 21                	jne    801237 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801216:	a1 08 40 80 00       	mov    0x804008,%eax
  80121b:	8b 40 48             	mov    0x48(%eax),%eax
  80121e:	83 ec 04             	sub    $0x4,%esp
  801221:	53                   	push   %ebx
  801222:	50                   	push   %eax
  801223:	68 a1 26 80 00       	push   $0x8026a1
  801228:	e8 67 ef ff ff       	call   800194 <cprintf>
		return -E_INVAL;
  80122d:	83 c4 10             	add    $0x10,%esp
  801230:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801235:	eb 26                	jmp    80125d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801237:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80123a:	8b 52 0c             	mov    0xc(%edx),%edx
  80123d:	85 d2                	test   %edx,%edx
  80123f:	74 17                	je     801258 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801241:	83 ec 04             	sub    $0x4,%esp
  801244:	ff 75 10             	pushl  0x10(%ebp)
  801247:	ff 75 0c             	pushl  0xc(%ebp)
  80124a:	50                   	push   %eax
  80124b:	ff d2                	call   *%edx
  80124d:	89 c2                	mov    %eax,%edx
  80124f:	83 c4 10             	add    $0x10,%esp
  801252:	eb 09                	jmp    80125d <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801254:	89 c2                	mov    %eax,%edx
  801256:	eb 05                	jmp    80125d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801258:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80125d:	89 d0                	mov    %edx,%eax
  80125f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801262:	c9                   	leave  
  801263:	c3                   	ret    

00801264 <seek>:

int
seek(int fdnum, off_t offset)
{
  801264:	55                   	push   %ebp
  801265:	89 e5                	mov    %esp,%ebp
  801267:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80126a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80126d:	50                   	push   %eax
  80126e:	ff 75 08             	pushl  0x8(%ebp)
  801271:	e8 22 fc ff ff       	call   800e98 <fd_lookup>
  801276:	83 c4 08             	add    $0x8,%esp
  801279:	85 c0                	test   %eax,%eax
  80127b:	78 0e                	js     80128b <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80127d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801280:	8b 55 0c             	mov    0xc(%ebp),%edx
  801283:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801286:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80128b:	c9                   	leave  
  80128c:	c3                   	ret    

0080128d <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80128d:	55                   	push   %ebp
  80128e:	89 e5                	mov    %esp,%ebp
  801290:	53                   	push   %ebx
  801291:	83 ec 14             	sub    $0x14,%esp
  801294:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801297:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80129a:	50                   	push   %eax
  80129b:	53                   	push   %ebx
  80129c:	e8 f7 fb ff ff       	call   800e98 <fd_lookup>
  8012a1:	83 c4 08             	add    $0x8,%esp
  8012a4:	89 c2                	mov    %eax,%edx
  8012a6:	85 c0                	test   %eax,%eax
  8012a8:	78 65                	js     80130f <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012aa:	83 ec 08             	sub    $0x8,%esp
  8012ad:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012b0:	50                   	push   %eax
  8012b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012b4:	ff 30                	pushl  (%eax)
  8012b6:	e8 33 fc ff ff       	call   800eee <dev_lookup>
  8012bb:	83 c4 10             	add    $0x10,%esp
  8012be:	85 c0                	test   %eax,%eax
  8012c0:	78 44                	js     801306 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012c9:	75 21                	jne    8012ec <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012cb:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012d0:	8b 40 48             	mov    0x48(%eax),%eax
  8012d3:	83 ec 04             	sub    $0x4,%esp
  8012d6:	53                   	push   %ebx
  8012d7:	50                   	push   %eax
  8012d8:	68 64 26 80 00       	push   $0x802664
  8012dd:	e8 b2 ee ff ff       	call   800194 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012e2:	83 c4 10             	add    $0x10,%esp
  8012e5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012ea:	eb 23                	jmp    80130f <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8012ec:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012ef:	8b 52 18             	mov    0x18(%edx),%edx
  8012f2:	85 d2                	test   %edx,%edx
  8012f4:	74 14                	je     80130a <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012f6:	83 ec 08             	sub    $0x8,%esp
  8012f9:	ff 75 0c             	pushl  0xc(%ebp)
  8012fc:	50                   	push   %eax
  8012fd:	ff d2                	call   *%edx
  8012ff:	89 c2                	mov    %eax,%edx
  801301:	83 c4 10             	add    $0x10,%esp
  801304:	eb 09                	jmp    80130f <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801306:	89 c2                	mov    %eax,%edx
  801308:	eb 05                	jmp    80130f <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80130a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80130f:	89 d0                	mov    %edx,%eax
  801311:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801314:	c9                   	leave  
  801315:	c3                   	ret    

00801316 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801316:	55                   	push   %ebp
  801317:	89 e5                	mov    %esp,%ebp
  801319:	53                   	push   %ebx
  80131a:	83 ec 14             	sub    $0x14,%esp
  80131d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801320:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801323:	50                   	push   %eax
  801324:	ff 75 08             	pushl  0x8(%ebp)
  801327:	e8 6c fb ff ff       	call   800e98 <fd_lookup>
  80132c:	83 c4 08             	add    $0x8,%esp
  80132f:	89 c2                	mov    %eax,%edx
  801331:	85 c0                	test   %eax,%eax
  801333:	78 58                	js     80138d <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801335:	83 ec 08             	sub    $0x8,%esp
  801338:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80133b:	50                   	push   %eax
  80133c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80133f:	ff 30                	pushl  (%eax)
  801341:	e8 a8 fb ff ff       	call   800eee <dev_lookup>
  801346:	83 c4 10             	add    $0x10,%esp
  801349:	85 c0                	test   %eax,%eax
  80134b:	78 37                	js     801384 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80134d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801350:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801354:	74 32                	je     801388 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801356:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801359:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801360:	00 00 00 
	stat->st_isdir = 0;
  801363:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80136a:	00 00 00 
	stat->st_dev = dev;
  80136d:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801373:	83 ec 08             	sub    $0x8,%esp
  801376:	53                   	push   %ebx
  801377:	ff 75 f0             	pushl  -0x10(%ebp)
  80137a:	ff 50 14             	call   *0x14(%eax)
  80137d:	89 c2                	mov    %eax,%edx
  80137f:	83 c4 10             	add    $0x10,%esp
  801382:	eb 09                	jmp    80138d <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801384:	89 c2                	mov    %eax,%edx
  801386:	eb 05                	jmp    80138d <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801388:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80138d:	89 d0                	mov    %edx,%eax
  80138f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801392:	c9                   	leave  
  801393:	c3                   	ret    

00801394 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801394:	55                   	push   %ebp
  801395:	89 e5                	mov    %esp,%ebp
  801397:	56                   	push   %esi
  801398:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801399:	83 ec 08             	sub    $0x8,%esp
  80139c:	6a 00                	push   $0x0
  80139e:	ff 75 08             	pushl  0x8(%ebp)
  8013a1:	e8 0c 02 00 00       	call   8015b2 <open>
  8013a6:	89 c3                	mov    %eax,%ebx
  8013a8:	83 c4 10             	add    $0x10,%esp
  8013ab:	85 c0                	test   %eax,%eax
  8013ad:	78 1b                	js     8013ca <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013af:	83 ec 08             	sub    $0x8,%esp
  8013b2:	ff 75 0c             	pushl  0xc(%ebp)
  8013b5:	50                   	push   %eax
  8013b6:	e8 5b ff ff ff       	call   801316 <fstat>
  8013bb:	89 c6                	mov    %eax,%esi
	close(fd);
  8013bd:	89 1c 24             	mov    %ebx,(%esp)
  8013c0:	e8 fd fb ff ff       	call   800fc2 <close>
	return r;
  8013c5:	83 c4 10             	add    $0x10,%esp
  8013c8:	89 f0                	mov    %esi,%eax
}
  8013ca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013cd:	5b                   	pop    %ebx
  8013ce:	5e                   	pop    %esi
  8013cf:	5d                   	pop    %ebp
  8013d0:	c3                   	ret    

008013d1 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013d1:	55                   	push   %ebp
  8013d2:	89 e5                	mov    %esp,%ebp
  8013d4:	56                   	push   %esi
  8013d5:	53                   	push   %ebx
  8013d6:	89 c6                	mov    %eax,%esi
  8013d8:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013da:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013e1:	75 12                	jne    8013f5 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013e3:	83 ec 0c             	sub    $0xc,%esp
  8013e6:	6a 01                	push   $0x1
  8013e8:	e8 fc f9 ff ff       	call   800de9 <ipc_find_env>
  8013ed:	a3 00 40 80 00       	mov    %eax,0x804000
  8013f2:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013f5:	6a 07                	push   $0x7
  8013f7:	68 00 50 80 00       	push   $0x805000
  8013fc:	56                   	push   %esi
  8013fd:	ff 35 00 40 80 00    	pushl  0x804000
  801403:	e8 8d f9 ff ff       	call   800d95 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801408:	83 c4 0c             	add    $0xc,%esp
  80140b:	6a 00                	push   $0x0
  80140d:	53                   	push   %ebx
  80140e:	6a 00                	push   $0x0
  801410:	e8 17 f9 ff ff       	call   800d2c <ipc_recv>
}
  801415:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801418:	5b                   	pop    %ebx
  801419:	5e                   	pop    %esi
  80141a:	5d                   	pop    %ebp
  80141b:	c3                   	ret    

0080141c <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80141c:	55                   	push   %ebp
  80141d:	89 e5                	mov    %esp,%ebp
  80141f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801422:	8b 45 08             	mov    0x8(%ebp),%eax
  801425:	8b 40 0c             	mov    0xc(%eax),%eax
  801428:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80142d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801430:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801435:	ba 00 00 00 00       	mov    $0x0,%edx
  80143a:	b8 02 00 00 00       	mov    $0x2,%eax
  80143f:	e8 8d ff ff ff       	call   8013d1 <fsipc>
}
  801444:	c9                   	leave  
  801445:	c3                   	ret    

00801446 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801446:	55                   	push   %ebp
  801447:	89 e5                	mov    %esp,%ebp
  801449:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80144c:	8b 45 08             	mov    0x8(%ebp),%eax
  80144f:	8b 40 0c             	mov    0xc(%eax),%eax
  801452:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801457:	ba 00 00 00 00       	mov    $0x0,%edx
  80145c:	b8 06 00 00 00       	mov    $0x6,%eax
  801461:	e8 6b ff ff ff       	call   8013d1 <fsipc>
}
  801466:	c9                   	leave  
  801467:	c3                   	ret    

00801468 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801468:	55                   	push   %ebp
  801469:	89 e5                	mov    %esp,%ebp
  80146b:	53                   	push   %ebx
  80146c:	83 ec 04             	sub    $0x4,%esp
  80146f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801472:	8b 45 08             	mov    0x8(%ebp),%eax
  801475:	8b 40 0c             	mov    0xc(%eax),%eax
  801478:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80147d:	ba 00 00 00 00       	mov    $0x0,%edx
  801482:	b8 05 00 00 00       	mov    $0x5,%eax
  801487:	e8 45 ff ff ff       	call   8013d1 <fsipc>
  80148c:	85 c0                	test   %eax,%eax
  80148e:	78 2c                	js     8014bc <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801490:	83 ec 08             	sub    $0x8,%esp
  801493:	68 00 50 80 00       	push   $0x805000
  801498:	53                   	push   %ebx
  801499:	e8 7b f2 ff ff       	call   800719 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80149e:	a1 80 50 80 00       	mov    0x805080,%eax
  8014a3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014a9:	a1 84 50 80 00       	mov    0x805084,%eax
  8014ae:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014b4:	83 c4 10             	add    $0x10,%esp
  8014b7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014bf:	c9                   	leave  
  8014c0:	c3                   	ret    

008014c1 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8014c1:	55                   	push   %ebp
  8014c2:	89 e5                	mov    %esp,%ebp
  8014c4:	53                   	push   %ebx
  8014c5:	83 ec 08             	sub    $0x8,%esp
  8014c8:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8014ce:	8b 52 0c             	mov    0xc(%edx),%edx
  8014d1:	89 15 00 50 80 00    	mov    %edx,0x805000
  8014d7:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8014dc:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  8014e1:	0f 46 d8             	cmovbe %eax,%ebx
	
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  8014e4:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  8014ea:	53                   	push   %ebx
  8014eb:	ff 75 0c             	pushl  0xc(%ebp)
  8014ee:	68 08 50 80 00       	push   $0x805008
  8014f3:	e8 b3 f3 ff ff       	call   8008ab <memmove>

	
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) 
  8014f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8014fd:	b8 04 00 00 00       	mov    $0x4,%eax
  801502:	e8 ca fe ff ff       	call   8013d1 <fsipc>
  801507:	83 c4 10             	add    $0x10,%esp
  80150a:	85 c0                	test   %eax,%eax
  80150c:	78 1d                	js     80152b <devfile_write+0x6a>
		return r;
	assert(r <= n_real); 
  80150e:	39 d8                	cmp    %ebx,%eax
  801510:	76 19                	jbe    80152b <devfile_write+0x6a>
  801512:	68 d4 26 80 00       	push   $0x8026d4
  801517:	68 e0 26 80 00       	push   $0x8026e0
  80151c:	68 a3 00 00 00       	push   $0xa3
  801521:	68 f5 26 80 00       	push   $0x8026f5
  801526:	e8 71 0a 00 00       	call   801f9c <_panic>
	return r;
}
  80152b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80152e:	c9                   	leave  
  80152f:	c3                   	ret    

00801530 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801530:	55                   	push   %ebp
  801531:	89 e5                	mov    %esp,%ebp
  801533:	56                   	push   %esi
  801534:	53                   	push   %ebx
  801535:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801538:	8b 45 08             	mov    0x8(%ebp),%eax
  80153b:	8b 40 0c             	mov    0xc(%eax),%eax
  80153e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801543:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801549:	ba 00 00 00 00       	mov    $0x0,%edx
  80154e:	b8 03 00 00 00       	mov    $0x3,%eax
  801553:	e8 79 fe ff ff       	call   8013d1 <fsipc>
  801558:	89 c3                	mov    %eax,%ebx
  80155a:	85 c0                	test   %eax,%eax
  80155c:	78 4b                	js     8015a9 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80155e:	39 c6                	cmp    %eax,%esi
  801560:	73 16                	jae    801578 <devfile_read+0x48>
  801562:	68 00 27 80 00       	push   $0x802700
  801567:	68 e0 26 80 00       	push   $0x8026e0
  80156c:	6a 7c                	push   $0x7c
  80156e:	68 f5 26 80 00       	push   $0x8026f5
  801573:	e8 24 0a 00 00       	call   801f9c <_panic>
	assert(r <= PGSIZE);
  801578:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80157d:	7e 16                	jle    801595 <devfile_read+0x65>
  80157f:	68 07 27 80 00       	push   $0x802707
  801584:	68 e0 26 80 00       	push   $0x8026e0
  801589:	6a 7d                	push   $0x7d
  80158b:	68 f5 26 80 00       	push   $0x8026f5
  801590:	e8 07 0a 00 00       	call   801f9c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801595:	83 ec 04             	sub    $0x4,%esp
  801598:	50                   	push   %eax
  801599:	68 00 50 80 00       	push   $0x805000
  80159e:	ff 75 0c             	pushl  0xc(%ebp)
  8015a1:	e8 05 f3 ff ff       	call   8008ab <memmove>
	return r;
  8015a6:	83 c4 10             	add    $0x10,%esp
}
  8015a9:	89 d8                	mov    %ebx,%eax
  8015ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015ae:	5b                   	pop    %ebx
  8015af:	5e                   	pop    %esi
  8015b0:	5d                   	pop    %ebp
  8015b1:	c3                   	ret    

008015b2 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8015b2:	55                   	push   %ebp
  8015b3:	89 e5                	mov    %esp,%ebp
  8015b5:	53                   	push   %ebx
  8015b6:	83 ec 20             	sub    $0x20,%esp
  8015b9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015bc:	53                   	push   %ebx
  8015bd:	e8 1e f1 ff ff       	call   8006e0 <strlen>
  8015c2:	83 c4 10             	add    $0x10,%esp
  8015c5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015ca:	7f 67                	jg     801633 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015cc:	83 ec 0c             	sub    $0xc,%esp
  8015cf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015d2:	50                   	push   %eax
  8015d3:	e8 71 f8 ff ff       	call   800e49 <fd_alloc>
  8015d8:	83 c4 10             	add    $0x10,%esp
		return r;
  8015db:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015dd:	85 c0                	test   %eax,%eax
  8015df:	78 57                	js     801638 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015e1:	83 ec 08             	sub    $0x8,%esp
  8015e4:	53                   	push   %ebx
  8015e5:	68 00 50 80 00       	push   $0x805000
  8015ea:	e8 2a f1 ff ff       	call   800719 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015f2:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015f7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015fa:	b8 01 00 00 00       	mov    $0x1,%eax
  8015ff:	e8 cd fd ff ff       	call   8013d1 <fsipc>
  801604:	89 c3                	mov    %eax,%ebx
  801606:	83 c4 10             	add    $0x10,%esp
  801609:	85 c0                	test   %eax,%eax
  80160b:	79 14                	jns    801621 <open+0x6f>
		fd_close(fd, 0);
  80160d:	83 ec 08             	sub    $0x8,%esp
  801610:	6a 00                	push   $0x0
  801612:	ff 75 f4             	pushl  -0xc(%ebp)
  801615:	e8 27 f9 ff ff       	call   800f41 <fd_close>
		return r;
  80161a:	83 c4 10             	add    $0x10,%esp
  80161d:	89 da                	mov    %ebx,%edx
  80161f:	eb 17                	jmp    801638 <open+0x86>
	}

	return fd2num(fd);
  801621:	83 ec 0c             	sub    $0xc,%esp
  801624:	ff 75 f4             	pushl  -0xc(%ebp)
  801627:	e8 f6 f7 ff ff       	call   800e22 <fd2num>
  80162c:	89 c2                	mov    %eax,%edx
  80162e:	83 c4 10             	add    $0x10,%esp
  801631:	eb 05                	jmp    801638 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801633:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801638:	89 d0                	mov    %edx,%eax
  80163a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80163d:	c9                   	leave  
  80163e:	c3                   	ret    

0080163f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80163f:	55                   	push   %ebp
  801640:	89 e5                	mov    %esp,%ebp
  801642:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801645:	ba 00 00 00 00       	mov    $0x0,%edx
  80164a:	b8 08 00 00 00       	mov    $0x8,%eax
  80164f:	e8 7d fd ff ff       	call   8013d1 <fsipc>
}
  801654:	c9                   	leave  
  801655:	c3                   	ret    

00801656 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801656:	55                   	push   %ebp
  801657:	89 e5                	mov    %esp,%ebp
  801659:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  80165c:	68 13 27 80 00       	push   $0x802713
  801661:	ff 75 0c             	pushl  0xc(%ebp)
  801664:	e8 b0 f0 ff ff       	call   800719 <strcpy>
	return 0;
}
  801669:	b8 00 00 00 00       	mov    $0x0,%eax
  80166e:	c9                   	leave  
  80166f:	c3                   	ret    

00801670 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801670:	55                   	push   %ebp
  801671:	89 e5                	mov    %esp,%ebp
  801673:	53                   	push   %ebx
  801674:	83 ec 10             	sub    $0x10,%esp
  801677:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80167a:	53                   	push   %ebx
  80167b:	e8 62 09 00 00       	call   801fe2 <pageref>
  801680:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801683:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801688:	83 f8 01             	cmp    $0x1,%eax
  80168b:	75 10                	jne    80169d <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  80168d:	83 ec 0c             	sub    $0xc,%esp
  801690:	ff 73 0c             	pushl  0xc(%ebx)
  801693:	e8 c0 02 00 00       	call   801958 <nsipc_close>
  801698:	89 c2                	mov    %eax,%edx
  80169a:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  80169d:	89 d0                	mov    %edx,%eax
  80169f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016a2:	c9                   	leave  
  8016a3:	c3                   	ret    

008016a4 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8016a4:	55                   	push   %ebp
  8016a5:	89 e5                	mov    %esp,%ebp
  8016a7:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8016aa:	6a 00                	push   $0x0
  8016ac:	ff 75 10             	pushl  0x10(%ebp)
  8016af:	ff 75 0c             	pushl  0xc(%ebp)
  8016b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b5:	ff 70 0c             	pushl  0xc(%eax)
  8016b8:	e8 78 03 00 00       	call   801a35 <nsipc_send>
}
  8016bd:	c9                   	leave  
  8016be:	c3                   	ret    

008016bf <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8016bf:	55                   	push   %ebp
  8016c0:	89 e5                	mov    %esp,%ebp
  8016c2:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8016c5:	6a 00                	push   $0x0
  8016c7:	ff 75 10             	pushl  0x10(%ebp)
  8016ca:	ff 75 0c             	pushl  0xc(%ebp)
  8016cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d0:	ff 70 0c             	pushl  0xc(%eax)
  8016d3:	e8 f1 02 00 00       	call   8019c9 <nsipc_recv>
}
  8016d8:	c9                   	leave  
  8016d9:	c3                   	ret    

008016da <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8016da:	55                   	push   %ebp
  8016db:	89 e5                	mov    %esp,%ebp
  8016dd:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8016e0:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8016e3:	52                   	push   %edx
  8016e4:	50                   	push   %eax
  8016e5:	e8 ae f7 ff ff       	call   800e98 <fd_lookup>
  8016ea:	83 c4 10             	add    $0x10,%esp
  8016ed:	85 c0                	test   %eax,%eax
  8016ef:	78 17                	js     801708 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8016f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016f4:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  8016fa:	39 08                	cmp    %ecx,(%eax)
  8016fc:	75 05                	jne    801703 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8016fe:	8b 40 0c             	mov    0xc(%eax),%eax
  801701:	eb 05                	jmp    801708 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801703:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801708:	c9                   	leave  
  801709:	c3                   	ret    

0080170a <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  80170a:	55                   	push   %ebp
  80170b:	89 e5                	mov    %esp,%ebp
  80170d:	56                   	push   %esi
  80170e:	53                   	push   %ebx
  80170f:	83 ec 1c             	sub    $0x1c,%esp
  801712:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801714:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801717:	50                   	push   %eax
  801718:	e8 2c f7 ff ff       	call   800e49 <fd_alloc>
  80171d:	89 c3                	mov    %eax,%ebx
  80171f:	83 c4 10             	add    $0x10,%esp
  801722:	85 c0                	test   %eax,%eax
  801724:	78 1b                	js     801741 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801726:	83 ec 04             	sub    $0x4,%esp
  801729:	68 07 04 00 00       	push   $0x407
  80172e:	ff 75 f4             	pushl  -0xc(%ebp)
  801731:	6a 00                	push   $0x0
  801733:	e8 e4 f3 ff ff       	call   800b1c <sys_page_alloc>
  801738:	89 c3                	mov    %eax,%ebx
  80173a:	83 c4 10             	add    $0x10,%esp
  80173d:	85 c0                	test   %eax,%eax
  80173f:	79 10                	jns    801751 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801741:	83 ec 0c             	sub    $0xc,%esp
  801744:	56                   	push   %esi
  801745:	e8 0e 02 00 00       	call   801958 <nsipc_close>
		return r;
  80174a:	83 c4 10             	add    $0x10,%esp
  80174d:	89 d8                	mov    %ebx,%eax
  80174f:	eb 24                	jmp    801775 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801751:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801757:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80175a:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  80175c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80175f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801766:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801769:	83 ec 0c             	sub    $0xc,%esp
  80176c:	50                   	push   %eax
  80176d:	e8 b0 f6 ff ff       	call   800e22 <fd2num>
  801772:	83 c4 10             	add    $0x10,%esp
}
  801775:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801778:	5b                   	pop    %ebx
  801779:	5e                   	pop    %esi
  80177a:	5d                   	pop    %ebp
  80177b:	c3                   	ret    

0080177c <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80177c:	55                   	push   %ebp
  80177d:	89 e5                	mov    %esp,%ebp
  80177f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801782:	8b 45 08             	mov    0x8(%ebp),%eax
  801785:	e8 50 ff ff ff       	call   8016da <fd2sockid>
		return r;
  80178a:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  80178c:	85 c0                	test   %eax,%eax
  80178e:	78 1f                	js     8017af <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801790:	83 ec 04             	sub    $0x4,%esp
  801793:	ff 75 10             	pushl  0x10(%ebp)
  801796:	ff 75 0c             	pushl  0xc(%ebp)
  801799:	50                   	push   %eax
  80179a:	e8 12 01 00 00       	call   8018b1 <nsipc_accept>
  80179f:	83 c4 10             	add    $0x10,%esp
		return r;
  8017a2:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8017a4:	85 c0                	test   %eax,%eax
  8017a6:	78 07                	js     8017af <accept+0x33>
		return r;
	return alloc_sockfd(r);
  8017a8:	e8 5d ff ff ff       	call   80170a <alloc_sockfd>
  8017ad:	89 c1                	mov    %eax,%ecx
}
  8017af:	89 c8                	mov    %ecx,%eax
  8017b1:	c9                   	leave  
  8017b2:	c3                   	ret    

008017b3 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8017b3:	55                   	push   %ebp
  8017b4:	89 e5                	mov    %esp,%ebp
  8017b6:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8017b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8017bc:	e8 19 ff ff ff       	call   8016da <fd2sockid>
  8017c1:	85 c0                	test   %eax,%eax
  8017c3:	78 12                	js     8017d7 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  8017c5:	83 ec 04             	sub    $0x4,%esp
  8017c8:	ff 75 10             	pushl  0x10(%ebp)
  8017cb:	ff 75 0c             	pushl  0xc(%ebp)
  8017ce:	50                   	push   %eax
  8017cf:	e8 2d 01 00 00       	call   801901 <nsipc_bind>
  8017d4:	83 c4 10             	add    $0x10,%esp
}
  8017d7:	c9                   	leave  
  8017d8:	c3                   	ret    

008017d9 <shutdown>:

int
shutdown(int s, int how)
{
  8017d9:	55                   	push   %ebp
  8017da:	89 e5                	mov    %esp,%ebp
  8017dc:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8017df:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e2:	e8 f3 fe ff ff       	call   8016da <fd2sockid>
  8017e7:	85 c0                	test   %eax,%eax
  8017e9:	78 0f                	js     8017fa <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8017eb:	83 ec 08             	sub    $0x8,%esp
  8017ee:	ff 75 0c             	pushl  0xc(%ebp)
  8017f1:	50                   	push   %eax
  8017f2:	e8 3f 01 00 00       	call   801936 <nsipc_shutdown>
  8017f7:	83 c4 10             	add    $0x10,%esp
}
  8017fa:	c9                   	leave  
  8017fb:	c3                   	ret    

008017fc <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8017fc:	55                   	push   %ebp
  8017fd:	89 e5                	mov    %esp,%ebp
  8017ff:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801802:	8b 45 08             	mov    0x8(%ebp),%eax
  801805:	e8 d0 fe ff ff       	call   8016da <fd2sockid>
  80180a:	85 c0                	test   %eax,%eax
  80180c:	78 12                	js     801820 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  80180e:	83 ec 04             	sub    $0x4,%esp
  801811:	ff 75 10             	pushl  0x10(%ebp)
  801814:	ff 75 0c             	pushl  0xc(%ebp)
  801817:	50                   	push   %eax
  801818:	e8 55 01 00 00       	call   801972 <nsipc_connect>
  80181d:	83 c4 10             	add    $0x10,%esp
}
  801820:	c9                   	leave  
  801821:	c3                   	ret    

00801822 <listen>:

int
listen(int s, int backlog)
{
  801822:	55                   	push   %ebp
  801823:	89 e5                	mov    %esp,%ebp
  801825:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801828:	8b 45 08             	mov    0x8(%ebp),%eax
  80182b:	e8 aa fe ff ff       	call   8016da <fd2sockid>
  801830:	85 c0                	test   %eax,%eax
  801832:	78 0f                	js     801843 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801834:	83 ec 08             	sub    $0x8,%esp
  801837:	ff 75 0c             	pushl  0xc(%ebp)
  80183a:	50                   	push   %eax
  80183b:	e8 67 01 00 00       	call   8019a7 <nsipc_listen>
  801840:	83 c4 10             	add    $0x10,%esp
}
  801843:	c9                   	leave  
  801844:	c3                   	ret    

00801845 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801845:	55                   	push   %ebp
  801846:	89 e5                	mov    %esp,%ebp
  801848:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  80184b:	ff 75 10             	pushl  0x10(%ebp)
  80184e:	ff 75 0c             	pushl  0xc(%ebp)
  801851:	ff 75 08             	pushl  0x8(%ebp)
  801854:	e8 3a 02 00 00       	call   801a93 <nsipc_socket>
  801859:	83 c4 10             	add    $0x10,%esp
  80185c:	85 c0                	test   %eax,%eax
  80185e:	78 05                	js     801865 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801860:	e8 a5 fe ff ff       	call   80170a <alloc_sockfd>
}
  801865:	c9                   	leave  
  801866:	c3                   	ret    

00801867 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801867:	55                   	push   %ebp
  801868:	89 e5                	mov    %esp,%ebp
  80186a:	53                   	push   %ebx
  80186b:	83 ec 04             	sub    $0x4,%esp
  80186e:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801870:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801877:	75 12                	jne    80188b <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801879:	83 ec 0c             	sub    $0xc,%esp
  80187c:	6a 02                	push   $0x2
  80187e:	e8 66 f5 ff ff       	call   800de9 <ipc_find_env>
  801883:	a3 04 40 80 00       	mov    %eax,0x804004
  801888:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  80188b:	6a 07                	push   $0x7
  80188d:	68 00 60 80 00       	push   $0x806000
  801892:	53                   	push   %ebx
  801893:	ff 35 04 40 80 00    	pushl  0x804004
  801899:	e8 f7 f4 ff ff       	call   800d95 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  80189e:	83 c4 0c             	add    $0xc,%esp
  8018a1:	6a 00                	push   $0x0
  8018a3:	6a 00                	push   $0x0
  8018a5:	6a 00                	push   $0x0
  8018a7:	e8 80 f4 ff ff       	call   800d2c <ipc_recv>
}
  8018ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018af:	c9                   	leave  
  8018b0:	c3                   	ret    

008018b1 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8018b1:	55                   	push   %ebp
  8018b2:	89 e5                	mov    %esp,%ebp
  8018b4:	56                   	push   %esi
  8018b5:	53                   	push   %ebx
  8018b6:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8018b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8018bc:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8018c1:	8b 06                	mov    (%esi),%eax
  8018c3:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8018c8:	b8 01 00 00 00       	mov    $0x1,%eax
  8018cd:	e8 95 ff ff ff       	call   801867 <nsipc>
  8018d2:	89 c3                	mov    %eax,%ebx
  8018d4:	85 c0                	test   %eax,%eax
  8018d6:	78 20                	js     8018f8 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8018d8:	83 ec 04             	sub    $0x4,%esp
  8018db:	ff 35 10 60 80 00    	pushl  0x806010
  8018e1:	68 00 60 80 00       	push   $0x806000
  8018e6:	ff 75 0c             	pushl  0xc(%ebp)
  8018e9:	e8 bd ef ff ff       	call   8008ab <memmove>
		*addrlen = ret->ret_addrlen;
  8018ee:	a1 10 60 80 00       	mov    0x806010,%eax
  8018f3:	89 06                	mov    %eax,(%esi)
  8018f5:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  8018f8:	89 d8                	mov    %ebx,%eax
  8018fa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018fd:	5b                   	pop    %ebx
  8018fe:	5e                   	pop    %esi
  8018ff:	5d                   	pop    %ebp
  801900:	c3                   	ret    

00801901 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801901:	55                   	push   %ebp
  801902:	89 e5                	mov    %esp,%ebp
  801904:	53                   	push   %ebx
  801905:	83 ec 08             	sub    $0x8,%esp
  801908:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80190b:	8b 45 08             	mov    0x8(%ebp),%eax
  80190e:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801913:	53                   	push   %ebx
  801914:	ff 75 0c             	pushl  0xc(%ebp)
  801917:	68 04 60 80 00       	push   $0x806004
  80191c:	e8 8a ef ff ff       	call   8008ab <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801921:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801927:	b8 02 00 00 00       	mov    $0x2,%eax
  80192c:	e8 36 ff ff ff       	call   801867 <nsipc>
}
  801931:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801934:	c9                   	leave  
  801935:	c3                   	ret    

00801936 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801936:	55                   	push   %ebp
  801937:	89 e5                	mov    %esp,%ebp
  801939:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  80193c:	8b 45 08             	mov    0x8(%ebp),%eax
  80193f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801944:	8b 45 0c             	mov    0xc(%ebp),%eax
  801947:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  80194c:	b8 03 00 00 00       	mov    $0x3,%eax
  801951:	e8 11 ff ff ff       	call   801867 <nsipc>
}
  801956:	c9                   	leave  
  801957:	c3                   	ret    

00801958 <nsipc_close>:

int
nsipc_close(int s)
{
  801958:	55                   	push   %ebp
  801959:	89 e5                	mov    %esp,%ebp
  80195b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  80195e:	8b 45 08             	mov    0x8(%ebp),%eax
  801961:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801966:	b8 04 00 00 00       	mov    $0x4,%eax
  80196b:	e8 f7 fe ff ff       	call   801867 <nsipc>
}
  801970:	c9                   	leave  
  801971:	c3                   	ret    

00801972 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801972:	55                   	push   %ebp
  801973:	89 e5                	mov    %esp,%ebp
  801975:	53                   	push   %ebx
  801976:	83 ec 08             	sub    $0x8,%esp
  801979:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80197c:	8b 45 08             	mov    0x8(%ebp),%eax
  80197f:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801984:	53                   	push   %ebx
  801985:	ff 75 0c             	pushl  0xc(%ebp)
  801988:	68 04 60 80 00       	push   $0x806004
  80198d:	e8 19 ef ff ff       	call   8008ab <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801992:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801998:	b8 05 00 00 00       	mov    $0x5,%eax
  80199d:	e8 c5 fe ff ff       	call   801867 <nsipc>
}
  8019a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019a5:	c9                   	leave  
  8019a6:	c3                   	ret    

008019a7 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8019a7:	55                   	push   %ebp
  8019a8:	89 e5                	mov    %esp,%ebp
  8019aa:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8019ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b0:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  8019b5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019b8:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  8019bd:	b8 06 00 00 00       	mov    $0x6,%eax
  8019c2:	e8 a0 fe ff ff       	call   801867 <nsipc>
}
  8019c7:	c9                   	leave  
  8019c8:	c3                   	ret    

008019c9 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8019c9:	55                   	push   %ebp
  8019ca:	89 e5                	mov    %esp,%ebp
  8019cc:	56                   	push   %esi
  8019cd:	53                   	push   %ebx
  8019ce:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8019d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d4:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  8019d9:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  8019df:	8b 45 14             	mov    0x14(%ebp),%eax
  8019e2:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8019e7:	b8 07 00 00 00       	mov    $0x7,%eax
  8019ec:	e8 76 fe ff ff       	call   801867 <nsipc>
  8019f1:	89 c3                	mov    %eax,%ebx
  8019f3:	85 c0                	test   %eax,%eax
  8019f5:	78 35                	js     801a2c <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  8019f7:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8019fc:	7f 04                	jg     801a02 <nsipc_recv+0x39>
  8019fe:	39 c6                	cmp    %eax,%esi
  801a00:	7d 16                	jge    801a18 <nsipc_recv+0x4f>
  801a02:	68 1f 27 80 00       	push   $0x80271f
  801a07:	68 e0 26 80 00       	push   $0x8026e0
  801a0c:	6a 62                	push   $0x62
  801a0e:	68 34 27 80 00       	push   $0x802734
  801a13:	e8 84 05 00 00       	call   801f9c <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801a18:	83 ec 04             	sub    $0x4,%esp
  801a1b:	50                   	push   %eax
  801a1c:	68 00 60 80 00       	push   $0x806000
  801a21:	ff 75 0c             	pushl  0xc(%ebp)
  801a24:	e8 82 ee ff ff       	call   8008ab <memmove>
  801a29:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801a2c:	89 d8                	mov    %ebx,%eax
  801a2e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a31:	5b                   	pop    %ebx
  801a32:	5e                   	pop    %esi
  801a33:	5d                   	pop    %ebp
  801a34:	c3                   	ret    

00801a35 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801a35:	55                   	push   %ebp
  801a36:	89 e5                	mov    %esp,%ebp
  801a38:	53                   	push   %ebx
  801a39:	83 ec 04             	sub    $0x4,%esp
  801a3c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801a3f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a42:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801a47:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801a4d:	7e 16                	jle    801a65 <nsipc_send+0x30>
  801a4f:	68 40 27 80 00       	push   $0x802740
  801a54:	68 e0 26 80 00       	push   $0x8026e0
  801a59:	6a 6d                	push   $0x6d
  801a5b:	68 34 27 80 00       	push   $0x802734
  801a60:	e8 37 05 00 00       	call   801f9c <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801a65:	83 ec 04             	sub    $0x4,%esp
  801a68:	53                   	push   %ebx
  801a69:	ff 75 0c             	pushl  0xc(%ebp)
  801a6c:	68 0c 60 80 00       	push   $0x80600c
  801a71:	e8 35 ee ff ff       	call   8008ab <memmove>
	nsipcbuf.send.req_size = size;
  801a76:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801a7c:	8b 45 14             	mov    0x14(%ebp),%eax
  801a7f:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801a84:	b8 08 00 00 00       	mov    $0x8,%eax
  801a89:	e8 d9 fd ff ff       	call   801867 <nsipc>
}
  801a8e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a91:	c9                   	leave  
  801a92:	c3                   	ret    

00801a93 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801a93:	55                   	push   %ebp
  801a94:	89 e5                	mov    %esp,%ebp
  801a96:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801a99:	8b 45 08             	mov    0x8(%ebp),%eax
  801a9c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801aa1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aa4:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801aa9:	8b 45 10             	mov    0x10(%ebp),%eax
  801aac:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801ab1:	b8 09 00 00 00       	mov    $0x9,%eax
  801ab6:	e8 ac fd ff ff       	call   801867 <nsipc>
}
  801abb:	c9                   	leave  
  801abc:	c3                   	ret    

00801abd <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801abd:	55                   	push   %ebp
  801abe:	89 e5                	mov    %esp,%ebp
  801ac0:	56                   	push   %esi
  801ac1:	53                   	push   %ebx
  801ac2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ac5:	83 ec 0c             	sub    $0xc,%esp
  801ac8:	ff 75 08             	pushl  0x8(%ebp)
  801acb:	e8 62 f3 ff ff       	call   800e32 <fd2data>
  801ad0:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801ad2:	83 c4 08             	add    $0x8,%esp
  801ad5:	68 4c 27 80 00       	push   $0x80274c
  801ada:	53                   	push   %ebx
  801adb:	e8 39 ec ff ff       	call   800719 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ae0:	8b 46 04             	mov    0x4(%esi),%eax
  801ae3:	2b 06                	sub    (%esi),%eax
  801ae5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801aeb:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801af2:	00 00 00 
	stat->st_dev = &devpipe;
  801af5:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801afc:	30 80 00 
	return 0;
}
  801aff:	b8 00 00 00 00       	mov    $0x0,%eax
  801b04:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b07:	5b                   	pop    %ebx
  801b08:	5e                   	pop    %esi
  801b09:	5d                   	pop    %ebp
  801b0a:	c3                   	ret    

00801b0b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b0b:	55                   	push   %ebp
  801b0c:	89 e5                	mov    %esp,%ebp
  801b0e:	53                   	push   %ebx
  801b0f:	83 ec 0c             	sub    $0xc,%esp
  801b12:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b15:	53                   	push   %ebx
  801b16:	6a 00                	push   $0x0
  801b18:	e8 84 f0 ff ff       	call   800ba1 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b1d:	89 1c 24             	mov    %ebx,(%esp)
  801b20:	e8 0d f3 ff ff       	call   800e32 <fd2data>
  801b25:	83 c4 08             	add    $0x8,%esp
  801b28:	50                   	push   %eax
  801b29:	6a 00                	push   $0x0
  801b2b:	e8 71 f0 ff ff       	call   800ba1 <sys_page_unmap>
}
  801b30:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b33:	c9                   	leave  
  801b34:	c3                   	ret    

00801b35 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b35:	55                   	push   %ebp
  801b36:	89 e5                	mov    %esp,%ebp
  801b38:	57                   	push   %edi
  801b39:	56                   	push   %esi
  801b3a:	53                   	push   %ebx
  801b3b:	83 ec 1c             	sub    $0x1c,%esp
  801b3e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b41:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b43:	a1 08 40 80 00       	mov    0x804008,%eax
  801b48:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801b4b:	83 ec 0c             	sub    $0xc,%esp
  801b4e:	ff 75 e0             	pushl  -0x20(%ebp)
  801b51:	e8 8c 04 00 00       	call   801fe2 <pageref>
  801b56:	89 c3                	mov    %eax,%ebx
  801b58:	89 3c 24             	mov    %edi,(%esp)
  801b5b:	e8 82 04 00 00       	call   801fe2 <pageref>
  801b60:	83 c4 10             	add    $0x10,%esp
  801b63:	39 c3                	cmp    %eax,%ebx
  801b65:	0f 94 c1             	sete   %cl
  801b68:	0f b6 c9             	movzbl %cl,%ecx
  801b6b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801b6e:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801b74:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b77:	39 ce                	cmp    %ecx,%esi
  801b79:	74 1b                	je     801b96 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801b7b:	39 c3                	cmp    %eax,%ebx
  801b7d:	75 c4                	jne    801b43 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b7f:	8b 42 58             	mov    0x58(%edx),%eax
  801b82:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b85:	50                   	push   %eax
  801b86:	56                   	push   %esi
  801b87:	68 53 27 80 00       	push   $0x802753
  801b8c:	e8 03 e6 ff ff       	call   800194 <cprintf>
  801b91:	83 c4 10             	add    $0x10,%esp
  801b94:	eb ad                	jmp    801b43 <_pipeisclosed+0xe>
	}
}
  801b96:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b9c:	5b                   	pop    %ebx
  801b9d:	5e                   	pop    %esi
  801b9e:	5f                   	pop    %edi
  801b9f:	5d                   	pop    %ebp
  801ba0:	c3                   	ret    

00801ba1 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ba1:	55                   	push   %ebp
  801ba2:	89 e5                	mov    %esp,%ebp
  801ba4:	57                   	push   %edi
  801ba5:	56                   	push   %esi
  801ba6:	53                   	push   %ebx
  801ba7:	83 ec 28             	sub    $0x28,%esp
  801baa:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801bad:	56                   	push   %esi
  801bae:	e8 7f f2 ff ff       	call   800e32 <fd2data>
  801bb3:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bb5:	83 c4 10             	add    $0x10,%esp
  801bb8:	bf 00 00 00 00       	mov    $0x0,%edi
  801bbd:	eb 4b                	jmp    801c0a <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801bbf:	89 da                	mov    %ebx,%edx
  801bc1:	89 f0                	mov    %esi,%eax
  801bc3:	e8 6d ff ff ff       	call   801b35 <_pipeisclosed>
  801bc8:	85 c0                	test   %eax,%eax
  801bca:	75 48                	jne    801c14 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801bcc:	e8 2c ef ff ff       	call   800afd <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801bd1:	8b 43 04             	mov    0x4(%ebx),%eax
  801bd4:	8b 0b                	mov    (%ebx),%ecx
  801bd6:	8d 51 20             	lea    0x20(%ecx),%edx
  801bd9:	39 d0                	cmp    %edx,%eax
  801bdb:	73 e2                	jae    801bbf <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801bdd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801be0:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801be4:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801be7:	89 c2                	mov    %eax,%edx
  801be9:	c1 fa 1f             	sar    $0x1f,%edx
  801bec:	89 d1                	mov    %edx,%ecx
  801bee:	c1 e9 1b             	shr    $0x1b,%ecx
  801bf1:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801bf4:	83 e2 1f             	and    $0x1f,%edx
  801bf7:	29 ca                	sub    %ecx,%edx
  801bf9:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801bfd:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c01:	83 c0 01             	add    $0x1,%eax
  801c04:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c07:	83 c7 01             	add    $0x1,%edi
  801c0a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c0d:	75 c2                	jne    801bd1 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c0f:	8b 45 10             	mov    0x10(%ebp),%eax
  801c12:	eb 05                	jmp    801c19 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c14:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c19:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c1c:	5b                   	pop    %ebx
  801c1d:	5e                   	pop    %esi
  801c1e:	5f                   	pop    %edi
  801c1f:	5d                   	pop    %ebp
  801c20:	c3                   	ret    

00801c21 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c21:	55                   	push   %ebp
  801c22:	89 e5                	mov    %esp,%ebp
  801c24:	57                   	push   %edi
  801c25:	56                   	push   %esi
  801c26:	53                   	push   %ebx
  801c27:	83 ec 18             	sub    $0x18,%esp
  801c2a:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c2d:	57                   	push   %edi
  801c2e:	e8 ff f1 ff ff       	call   800e32 <fd2data>
  801c33:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c35:	83 c4 10             	add    $0x10,%esp
  801c38:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c3d:	eb 3d                	jmp    801c7c <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c3f:	85 db                	test   %ebx,%ebx
  801c41:	74 04                	je     801c47 <devpipe_read+0x26>
				return i;
  801c43:	89 d8                	mov    %ebx,%eax
  801c45:	eb 44                	jmp    801c8b <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c47:	89 f2                	mov    %esi,%edx
  801c49:	89 f8                	mov    %edi,%eax
  801c4b:	e8 e5 fe ff ff       	call   801b35 <_pipeisclosed>
  801c50:	85 c0                	test   %eax,%eax
  801c52:	75 32                	jne    801c86 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c54:	e8 a4 ee ff ff       	call   800afd <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c59:	8b 06                	mov    (%esi),%eax
  801c5b:	3b 46 04             	cmp    0x4(%esi),%eax
  801c5e:	74 df                	je     801c3f <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c60:	99                   	cltd   
  801c61:	c1 ea 1b             	shr    $0x1b,%edx
  801c64:	01 d0                	add    %edx,%eax
  801c66:	83 e0 1f             	and    $0x1f,%eax
  801c69:	29 d0                	sub    %edx,%eax
  801c6b:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c73:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801c76:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c79:	83 c3 01             	add    $0x1,%ebx
  801c7c:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c7f:	75 d8                	jne    801c59 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c81:	8b 45 10             	mov    0x10(%ebp),%eax
  801c84:	eb 05                	jmp    801c8b <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c86:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c8b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c8e:	5b                   	pop    %ebx
  801c8f:	5e                   	pop    %esi
  801c90:	5f                   	pop    %edi
  801c91:	5d                   	pop    %ebp
  801c92:	c3                   	ret    

00801c93 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c93:	55                   	push   %ebp
  801c94:	89 e5                	mov    %esp,%ebp
  801c96:	56                   	push   %esi
  801c97:	53                   	push   %ebx
  801c98:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c9b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c9e:	50                   	push   %eax
  801c9f:	e8 a5 f1 ff ff       	call   800e49 <fd_alloc>
  801ca4:	83 c4 10             	add    $0x10,%esp
  801ca7:	89 c2                	mov    %eax,%edx
  801ca9:	85 c0                	test   %eax,%eax
  801cab:	0f 88 2c 01 00 00    	js     801ddd <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cb1:	83 ec 04             	sub    $0x4,%esp
  801cb4:	68 07 04 00 00       	push   $0x407
  801cb9:	ff 75 f4             	pushl  -0xc(%ebp)
  801cbc:	6a 00                	push   $0x0
  801cbe:	e8 59 ee ff ff       	call   800b1c <sys_page_alloc>
  801cc3:	83 c4 10             	add    $0x10,%esp
  801cc6:	89 c2                	mov    %eax,%edx
  801cc8:	85 c0                	test   %eax,%eax
  801cca:	0f 88 0d 01 00 00    	js     801ddd <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801cd0:	83 ec 0c             	sub    $0xc,%esp
  801cd3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801cd6:	50                   	push   %eax
  801cd7:	e8 6d f1 ff ff       	call   800e49 <fd_alloc>
  801cdc:	89 c3                	mov    %eax,%ebx
  801cde:	83 c4 10             	add    $0x10,%esp
  801ce1:	85 c0                	test   %eax,%eax
  801ce3:	0f 88 e2 00 00 00    	js     801dcb <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ce9:	83 ec 04             	sub    $0x4,%esp
  801cec:	68 07 04 00 00       	push   $0x407
  801cf1:	ff 75 f0             	pushl  -0x10(%ebp)
  801cf4:	6a 00                	push   $0x0
  801cf6:	e8 21 ee ff ff       	call   800b1c <sys_page_alloc>
  801cfb:	89 c3                	mov    %eax,%ebx
  801cfd:	83 c4 10             	add    $0x10,%esp
  801d00:	85 c0                	test   %eax,%eax
  801d02:	0f 88 c3 00 00 00    	js     801dcb <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d08:	83 ec 0c             	sub    $0xc,%esp
  801d0b:	ff 75 f4             	pushl  -0xc(%ebp)
  801d0e:	e8 1f f1 ff ff       	call   800e32 <fd2data>
  801d13:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d15:	83 c4 0c             	add    $0xc,%esp
  801d18:	68 07 04 00 00       	push   $0x407
  801d1d:	50                   	push   %eax
  801d1e:	6a 00                	push   $0x0
  801d20:	e8 f7 ed ff ff       	call   800b1c <sys_page_alloc>
  801d25:	89 c3                	mov    %eax,%ebx
  801d27:	83 c4 10             	add    $0x10,%esp
  801d2a:	85 c0                	test   %eax,%eax
  801d2c:	0f 88 89 00 00 00    	js     801dbb <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d32:	83 ec 0c             	sub    $0xc,%esp
  801d35:	ff 75 f0             	pushl  -0x10(%ebp)
  801d38:	e8 f5 f0 ff ff       	call   800e32 <fd2data>
  801d3d:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d44:	50                   	push   %eax
  801d45:	6a 00                	push   $0x0
  801d47:	56                   	push   %esi
  801d48:	6a 00                	push   $0x0
  801d4a:	e8 10 ee ff ff       	call   800b5f <sys_page_map>
  801d4f:	89 c3                	mov    %eax,%ebx
  801d51:	83 c4 20             	add    $0x20,%esp
  801d54:	85 c0                	test   %eax,%eax
  801d56:	78 55                	js     801dad <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d58:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d61:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d63:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d66:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d6d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d73:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d76:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d78:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d7b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d82:	83 ec 0c             	sub    $0xc,%esp
  801d85:	ff 75 f4             	pushl  -0xc(%ebp)
  801d88:	e8 95 f0 ff ff       	call   800e22 <fd2num>
  801d8d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d90:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d92:	83 c4 04             	add    $0x4,%esp
  801d95:	ff 75 f0             	pushl  -0x10(%ebp)
  801d98:	e8 85 f0 ff ff       	call   800e22 <fd2num>
  801d9d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801da0:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801da3:	83 c4 10             	add    $0x10,%esp
  801da6:	ba 00 00 00 00       	mov    $0x0,%edx
  801dab:	eb 30                	jmp    801ddd <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801dad:	83 ec 08             	sub    $0x8,%esp
  801db0:	56                   	push   %esi
  801db1:	6a 00                	push   $0x0
  801db3:	e8 e9 ed ff ff       	call   800ba1 <sys_page_unmap>
  801db8:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801dbb:	83 ec 08             	sub    $0x8,%esp
  801dbe:	ff 75 f0             	pushl  -0x10(%ebp)
  801dc1:	6a 00                	push   $0x0
  801dc3:	e8 d9 ed ff ff       	call   800ba1 <sys_page_unmap>
  801dc8:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801dcb:	83 ec 08             	sub    $0x8,%esp
  801dce:	ff 75 f4             	pushl  -0xc(%ebp)
  801dd1:	6a 00                	push   $0x0
  801dd3:	e8 c9 ed ff ff       	call   800ba1 <sys_page_unmap>
  801dd8:	83 c4 10             	add    $0x10,%esp
  801ddb:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801ddd:	89 d0                	mov    %edx,%eax
  801ddf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801de2:	5b                   	pop    %ebx
  801de3:	5e                   	pop    %esi
  801de4:	5d                   	pop    %ebp
  801de5:	c3                   	ret    

00801de6 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801de6:	55                   	push   %ebp
  801de7:	89 e5                	mov    %esp,%ebp
  801de9:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801dec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801def:	50                   	push   %eax
  801df0:	ff 75 08             	pushl  0x8(%ebp)
  801df3:	e8 a0 f0 ff ff       	call   800e98 <fd_lookup>
  801df8:	83 c4 10             	add    $0x10,%esp
  801dfb:	85 c0                	test   %eax,%eax
  801dfd:	78 18                	js     801e17 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801dff:	83 ec 0c             	sub    $0xc,%esp
  801e02:	ff 75 f4             	pushl  -0xc(%ebp)
  801e05:	e8 28 f0 ff ff       	call   800e32 <fd2data>
	return _pipeisclosed(fd, p);
  801e0a:	89 c2                	mov    %eax,%edx
  801e0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e0f:	e8 21 fd ff ff       	call   801b35 <_pipeisclosed>
  801e14:	83 c4 10             	add    $0x10,%esp
}
  801e17:	c9                   	leave  
  801e18:	c3                   	ret    

00801e19 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e19:	55                   	push   %ebp
  801e1a:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e1c:	b8 00 00 00 00       	mov    $0x0,%eax
  801e21:	5d                   	pop    %ebp
  801e22:	c3                   	ret    

00801e23 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e23:	55                   	push   %ebp
  801e24:	89 e5                	mov    %esp,%ebp
  801e26:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e29:	68 6b 27 80 00       	push   $0x80276b
  801e2e:	ff 75 0c             	pushl  0xc(%ebp)
  801e31:	e8 e3 e8 ff ff       	call   800719 <strcpy>
	return 0;
}
  801e36:	b8 00 00 00 00       	mov    $0x0,%eax
  801e3b:	c9                   	leave  
  801e3c:	c3                   	ret    

00801e3d <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e3d:	55                   	push   %ebp
  801e3e:	89 e5                	mov    %esp,%ebp
  801e40:	57                   	push   %edi
  801e41:	56                   	push   %esi
  801e42:	53                   	push   %ebx
  801e43:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e49:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e4e:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e54:	eb 2d                	jmp    801e83 <devcons_write+0x46>
		m = n - tot;
  801e56:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e59:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801e5b:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e5e:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e63:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e66:	83 ec 04             	sub    $0x4,%esp
  801e69:	53                   	push   %ebx
  801e6a:	03 45 0c             	add    0xc(%ebp),%eax
  801e6d:	50                   	push   %eax
  801e6e:	57                   	push   %edi
  801e6f:	e8 37 ea ff ff       	call   8008ab <memmove>
		sys_cputs(buf, m);
  801e74:	83 c4 08             	add    $0x8,%esp
  801e77:	53                   	push   %ebx
  801e78:	57                   	push   %edi
  801e79:	e8 e2 eb ff ff       	call   800a60 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e7e:	01 de                	add    %ebx,%esi
  801e80:	83 c4 10             	add    $0x10,%esp
  801e83:	89 f0                	mov    %esi,%eax
  801e85:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e88:	72 cc                	jb     801e56 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e8a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e8d:	5b                   	pop    %ebx
  801e8e:	5e                   	pop    %esi
  801e8f:	5f                   	pop    %edi
  801e90:	5d                   	pop    %ebp
  801e91:	c3                   	ret    

00801e92 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e92:	55                   	push   %ebp
  801e93:	89 e5                	mov    %esp,%ebp
  801e95:	83 ec 08             	sub    $0x8,%esp
  801e98:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801e9d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ea1:	74 2a                	je     801ecd <devcons_read+0x3b>
  801ea3:	eb 05                	jmp    801eaa <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801ea5:	e8 53 ec ff ff       	call   800afd <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801eaa:	e8 cf eb ff ff       	call   800a7e <sys_cgetc>
  801eaf:	85 c0                	test   %eax,%eax
  801eb1:	74 f2                	je     801ea5 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801eb3:	85 c0                	test   %eax,%eax
  801eb5:	78 16                	js     801ecd <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801eb7:	83 f8 04             	cmp    $0x4,%eax
  801eba:	74 0c                	je     801ec8 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801ebc:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ebf:	88 02                	mov    %al,(%edx)
	return 1;
  801ec1:	b8 01 00 00 00       	mov    $0x1,%eax
  801ec6:	eb 05                	jmp    801ecd <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ec8:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801ecd:	c9                   	leave  
  801ece:	c3                   	ret    

00801ecf <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801ecf:	55                   	push   %ebp
  801ed0:	89 e5                	mov    %esp,%ebp
  801ed2:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801ed5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ed8:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801edb:	6a 01                	push   $0x1
  801edd:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ee0:	50                   	push   %eax
  801ee1:	e8 7a eb ff ff       	call   800a60 <sys_cputs>
}
  801ee6:	83 c4 10             	add    $0x10,%esp
  801ee9:	c9                   	leave  
  801eea:	c3                   	ret    

00801eeb <getchar>:

int
getchar(void)
{
  801eeb:	55                   	push   %ebp
  801eec:	89 e5                	mov    %esp,%ebp
  801eee:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801ef1:	6a 01                	push   $0x1
  801ef3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ef6:	50                   	push   %eax
  801ef7:	6a 00                	push   $0x0
  801ef9:	e8 00 f2 ff ff       	call   8010fe <read>
	if (r < 0)
  801efe:	83 c4 10             	add    $0x10,%esp
  801f01:	85 c0                	test   %eax,%eax
  801f03:	78 0f                	js     801f14 <getchar+0x29>
		return r;
	if (r < 1)
  801f05:	85 c0                	test   %eax,%eax
  801f07:	7e 06                	jle    801f0f <getchar+0x24>
		return -E_EOF;
	return c;
  801f09:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f0d:	eb 05                	jmp    801f14 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f0f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f14:	c9                   	leave  
  801f15:	c3                   	ret    

00801f16 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f16:	55                   	push   %ebp
  801f17:	89 e5                	mov    %esp,%ebp
  801f19:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f1c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f1f:	50                   	push   %eax
  801f20:	ff 75 08             	pushl  0x8(%ebp)
  801f23:	e8 70 ef ff ff       	call   800e98 <fd_lookup>
  801f28:	83 c4 10             	add    $0x10,%esp
  801f2b:	85 c0                	test   %eax,%eax
  801f2d:	78 11                	js     801f40 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f32:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801f38:	39 10                	cmp    %edx,(%eax)
  801f3a:	0f 94 c0             	sete   %al
  801f3d:	0f b6 c0             	movzbl %al,%eax
}
  801f40:	c9                   	leave  
  801f41:	c3                   	ret    

00801f42 <opencons>:

int
opencons(void)
{
  801f42:	55                   	push   %ebp
  801f43:	89 e5                	mov    %esp,%ebp
  801f45:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f48:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f4b:	50                   	push   %eax
  801f4c:	e8 f8 ee ff ff       	call   800e49 <fd_alloc>
  801f51:	83 c4 10             	add    $0x10,%esp
		return r;
  801f54:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f56:	85 c0                	test   %eax,%eax
  801f58:	78 3e                	js     801f98 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f5a:	83 ec 04             	sub    $0x4,%esp
  801f5d:	68 07 04 00 00       	push   $0x407
  801f62:	ff 75 f4             	pushl  -0xc(%ebp)
  801f65:	6a 00                	push   $0x0
  801f67:	e8 b0 eb ff ff       	call   800b1c <sys_page_alloc>
  801f6c:	83 c4 10             	add    $0x10,%esp
		return r;
  801f6f:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f71:	85 c0                	test   %eax,%eax
  801f73:	78 23                	js     801f98 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f75:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801f7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f7e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f80:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f83:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f8a:	83 ec 0c             	sub    $0xc,%esp
  801f8d:	50                   	push   %eax
  801f8e:	e8 8f ee ff ff       	call   800e22 <fd2num>
  801f93:	89 c2                	mov    %eax,%edx
  801f95:	83 c4 10             	add    $0x10,%esp
}
  801f98:	89 d0                	mov    %edx,%eax
  801f9a:	c9                   	leave  
  801f9b:	c3                   	ret    

00801f9c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801f9c:	55                   	push   %ebp
  801f9d:	89 e5                	mov    %esp,%ebp
  801f9f:	56                   	push   %esi
  801fa0:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801fa1:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801fa4:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801faa:	e8 2f eb ff ff       	call   800ade <sys_getenvid>
  801faf:	83 ec 0c             	sub    $0xc,%esp
  801fb2:	ff 75 0c             	pushl  0xc(%ebp)
  801fb5:	ff 75 08             	pushl  0x8(%ebp)
  801fb8:	56                   	push   %esi
  801fb9:	50                   	push   %eax
  801fba:	68 78 27 80 00       	push   $0x802778
  801fbf:	e8 d0 e1 ff ff       	call   800194 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801fc4:	83 c4 18             	add    $0x18,%esp
  801fc7:	53                   	push   %ebx
  801fc8:	ff 75 10             	pushl  0x10(%ebp)
  801fcb:	e8 73 e1 ff ff       	call   800143 <vcprintf>
	cprintf("\n");
  801fd0:	c7 04 24 64 27 80 00 	movl   $0x802764,(%esp)
  801fd7:	e8 b8 e1 ff ff       	call   800194 <cprintf>
  801fdc:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801fdf:	cc                   	int3   
  801fe0:	eb fd                	jmp    801fdf <_panic+0x43>

00801fe2 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fe2:	55                   	push   %ebp
  801fe3:	89 e5                	mov    %esp,%ebp
  801fe5:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fe8:	89 d0                	mov    %edx,%eax
  801fea:	c1 e8 16             	shr    $0x16,%eax
  801fed:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801ff4:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ff9:	f6 c1 01             	test   $0x1,%cl
  801ffc:	74 1d                	je     80201b <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801ffe:	c1 ea 0c             	shr    $0xc,%edx
  802001:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802008:	f6 c2 01             	test   $0x1,%dl
  80200b:	74 0e                	je     80201b <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80200d:	c1 ea 0c             	shr    $0xc,%edx
  802010:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802017:	ef 
  802018:	0f b7 c0             	movzwl %ax,%eax
}
  80201b:	5d                   	pop    %ebp
  80201c:	c3                   	ret    
  80201d:	66 90                	xchg   %ax,%ax
  80201f:	90                   	nop

00802020 <__udivdi3>:
  802020:	55                   	push   %ebp
  802021:	57                   	push   %edi
  802022:	56                   	push   %esi
  802023:	53                   	push   %ebx
  802024:	83 ec 1c             	sub    $0x1c,%esp
  802027:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80202b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80202f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802033:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802037:	85 f6                	test   %esi,%esi
  802039:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80203d:	89 ca                	mov    %ecx,%edx
  80203f:	89 f8                	mov    %edi,%eax
  802041:	75 3d                	jne    802080 <__udivdi3+0x60>
  802043:	39 cf                	cmp    %ecx,%edi
  802045:	0f 87 c5 00 00 00    	ja     802110 <__udivdi3+0xf0>
  80204b:	85 ff                	test   %edi,%edi
  80204d:	89 fd                	mov    %edi,%ebp
  80204f:	75 0b                	jne    80205c <__udivdi3+0x3c>
  802051:	b8 01 00 00 00       	mov    $0x1,%eax
  802056:	31 d2                	xor    %edx,%edx
  802058:	f7 f7                	div    %edi
  80205a:	89 c5                	mov    %eax,%ebp
  80205c:	89 c8                	mov    %ecx,%eax
  80205e:	31 d2                	xor    %edx,%edx
  802060:	f7 f5                	div    %ebp
  802062:	89 c1                	mov    %eax,%ecx
  802064:	89 d8                	mov    %ebx,%eax
  802066:	89 cf                	mov    %ecx,%edi
  802068:	f7 f5                	div    %ebp
  80206a:	89 c3                	mov    %eax,%ebx
  80206c:	89 d8                	mov    %ebx,%eax
  80206e:	89 fa                	mov    %edi,%edx
  802070:	83 c4 1c             	add    $0x1c,%esp
  802073:	5b                   	pop    %ebx
  802074:	5e                   	pop    %esi
  802075:	5f                   	pop    %edi
  802076:	5d                   	pop    %ebp
  802077:	c3                   	ret    
  802078:	90                   	nop
  802079:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802080:	39 ce                	cmp    %ecx,%esi
  802082:	77 74                	ja     8020f8 <__udivdi3+0xd8>
  802084:	0f bd fe             	bsr    %esi,%edi
  802087:	83 f7 1f             	xor    $0x1f,%edi
  80208a:	0f 84 98 00 00 00    	je     802128 <__udivdi3+0x108>
  802090:	bb 20 00 00 00       	mov    $0x20,%ebx
  802095:	89 f9                	mov    %edi,%ecx
  802097:	89 c5                	mov    %eax,%ebp
  802099:	29 fb                	sub    %edi,%ebx
  80209b:	d3 e6                	shl    %cl,%esi
  80209d:	89 d9                	mov    %ebx,%ecx
  80209f:	d3 ed                	shr    %cl,%ebp
  8020a1:	89 f9                	mov    %edi,%ecx
  8020a3:	d3 e0                	shl    %cl,%eax
  8020a5:	09 ee                	or     %ebp,%esi
  8020a7:	89 d9                	mov    %ebx,%ecx
  8020a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020ad:	89 d5                	mov    %edx,%ebp
  8020af:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020b3:	d3 ed                	shr    %cl,%ebp
  8020b5:	89 f9                	mov    %edi,%ecx
  8020b7:	d3 e2                	shl    %cl,%edx
  8020b9:	89 d9                	mov    %ebx,%ecx
  8020bb:	d3 e8                	shr    %cl,%eax
  8020bd:	09 c2                	or     %eax,%edx
  8020bf:	89 d0                	mov    %edx,%eax
  8020c1:	89 ea                	mov    %ebp,%edx
  8020c3:	f7 f6                	div    %esi
  8020c5:	89 d5                	mov    %edx,%ebp
  8020c7:	89 c3                	mov    %eax,%ebx
  8020c9:	f7 64 24 0c          	mull   0xc(%esp)
  8020cd:	39 d5                	cmp    %edx,%ebp
  8020cf:	72 10                	jb     8020e1 <__udivdi3+0xc1>
  8020d1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8020d5:	89 f9                	mov    %edi,%ecx
  8020d7:	d3 e6                	shl    %cl,%esi
  8020d9:	39 c6                	cmp    %eax,%esi
  8020db:	73 07                	jae    8020e4 <__udivdi3+0xc4>
  8020dd:	39 d5                	cmp    %edx,%ebp
  8020df:	75 03                	jne    8020e4 <__udivdi3+0xc4>
  8020e1:	83 eb 01             	sub    $0x1,%ebx
  8020e4:	31 ff                	xor    %edi,%edi
  8020e6:	89 d8                	mov    %ebx,%eax
  8020e8:	89 fa                	mov    %edi,%edx
  8020ea:	83 c4 1c             	add    $0x1c,%esp
  8020ed:	5b                   	pop    %ebx
  8020ee:	5e                   	pop    %esi
  8020ef:	5f                   	pop    %edi
  8020f0:	5d                   	pop    %ebp
  8020f1:	c3                   	ret    
  8020f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020f8:	31 ff                	xor    %edi,%edi
  8020fa:	31 db                	xor    %ebx,%ebx
  8020fc:	89 d8                	mov    %ebx,%eax
  8020fe:	89 fa                	mov    %edi,%edx
  802100:	83 c4 1c             	add    $0x1c,%esp
  802103:	5b                   	pop    %ebx
  802104:	5e                   	pop    %esi
  802105:	5f                   	pop    %edi
  802106:	5d                   	pop    %ebp
  802107:	c3                   	ret    
  802108:	90                   	nop
  802109:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802110:	89 d8                	mov    %ebx,%eax
  802112:	f7 f7                	div    %edi
  802114:	31 ff                	xor    %edi,%edi
  802116:	89 c3                	mov    %eax,%ebx
  802118:	89 d8                	mov    %ebx,%eax
  80211a:	89 fa                	mov    %edi,%edx
  80211c:	83 c4 1c             	add    $0x1c,%esp
  80211f:	5b                   	pop    %ebx
  802120:	5e                   	pop    %esi
  802121:	5f                   	pop    %edi
  802122:	5d                   	pop    %ebp
  802123:	c3                   	ret    
  802124:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802128:	39 ce                	cmp    %ecx,%esi
  80212a:	72 0c                	jb     802138 <__udivdi3+0x118>
  80212c:	31 db                	xor    %ebx,%ebx
  80212e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802132:	0f 87 34 ff ff ff    	ja     80206c <__udivdi3+0x4c>
  802138:	bb 01 00 00 00       	mov    $0x1,%ebx
  80213d:	e9 2a ff ff ff       	jmp    80206c <__udivdi3+0x4c>
  802142:	66 90                	xchg   %ax,%ax
  802144:	66 90                	xchg   %ax,%ax
  802146:	66 90                	xchg   %ax,%ax
  802148:	66 90                	xchg   %ax,%ax
  80214a:	66 90                	xchg   %ax,%ax
  80214c:	66 90                	xchg   %ax,%ax
  80214e:	66 90                	xchg   %ax,%ax

00802150 <__umoddi3>:
  802150:	55                   	push   %ebp
  802151:	57                   	push   %edi
  802152:	56                   	push   %esi
  802153:	53                   	push   %ebx
  802154:	83 ec 1c             	sub    $0x1c,%esp
  802157:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80215b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80215f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802163:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802167:	85 d2                	test   %edx,%edx
  802169:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80216d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802171:	89 f3                	mov    %esi,%ebx
  802173:	89 3c 24             	mov    %edi,(%esp)
  802176:	89 74 24 04          	mov    %esi,0x4(%esp)
  80217a:	75 1c                	jne    802198 <__umoddi3+0x48>
  80217c:	39 f7                	cmp    %esi,%edi
  80217e:	76 50                	jbe    8021d0 <__umoddi3+0x80>
  802180:	89 c8                	mov    %ecx,%eax
  802182:	89 f2                	mov    %esi,%edx
  802184:	f7 f7                	div    %edi
  802186:	89 d0                	mov    %edx,%eax
  802188:	31 d2                	xor    %edx,%edx
  80218a:	83 c4 1c             	add    $0x1c,%esp
  80218d:	5b                   	pop    %ebx
  80218e:	5e                   	pop    %esi
  80218f:	5f                   	pop    %edi
  802190:	5d                   	pop    %ebp
  802191:	c3                   	ret    
  802192:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802198:	39 f2                	cmp    %esi,%edx
  80219a:	89 d0                	mov    %edx,%eax
  80219c:	77 52                	ja     8021f0 <__umoddi3+0xa0>
  80219e:	0f bd ea             	bsr    %edx,%ebp
  8021a1:	83 f5 1f             	xor    $0x1f,%ebp
  8021a4:	75 5a                	jne    802200 <__umoddi3+0xb0>
  8021a6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8021aa:	0f 82 e0 00 00 00    	jb     802290 <__umoddi3+0x140>
  8021b0:	39 0c 24             	cmp    %ecx,(%esp)
  8021b3:	0f 86 d7 00 00 00    	jbe    802290 <__umoddi3+0x140>
  8021b9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021bd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8021c1:	83 c4 1c             	add    $0x1c,%esp
  8021c4:	5b                   	pop    %ebx
  8021c5:	5e                   	pop    %esi
  8021c6:	5f                   	pop    %edi
  8021c7:	5d                   	pop    %ebp
  8021c8:	c3                   	ret    
  8021c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021d0:	85 ff                	test   %edi,%edi
  8021d2:	89 fd                	mov    %edi,%ebp
  8021d4:	75 0b                	jne    8021e1 <__umoddi3+0x91>
  8021d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021db:	31 d2                	xor    %edx,%edx
  8021dd:	f7 f7                	div    %edi
  8021df:	89 c5                	mov    %eax,%ebp
  8021e1:	89 f0                	mov    %esi,%eax
  8021e3:	31 d2                	xor    %edx,%edx
  8021e5:	f7 f5                	div    %ebp
  8021e7:	89 c8                	mov    %ecx,%eax
  8021e9:	f7 f5                	div    %ebp
  8021eb:	89 d0                	mov    %edx,%eax
  8021ed:	eb 99                	jmp    802188 <__umoddi3+0x38>
  8021ef:	90                   	nop
  8021f0:	89 c8                	mov    %ecx,%eax
  8021f2:	89 f2                	mov    %esi,%edx
  8021f4:	83 c4 1c             	add    $0x1c,%esp
  8021f7:	5b                   	pop    %ebx
  8021f8:	5e                   	pop    %esi
  8021f9:	5f                   	pop    %edi
  8021fa:	5d                   	pop    %ebp
  8021fb:	c3                   	ret    
  8021fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802200:	8b 34 24             	mov    (%esp),%esi
  802203:	bf 20 00 00 00       	mov    $0x20,%edi
  802208:	89 e9                	mov    %ebp,%ecx
  80220a:	29 ef                	sub    %ebp,%edi
  80220c:	d3 e0                	shl    %cl,%eax
  80220e:	89 f9                	mov    %edi,%ecx
  802210:	89 f2                	mov    %esi,%edx
  802212:	d3 ea                	shr    %cl,%edx
  802214:	89 e9                	mov    %ebp,%ecx
  802216:	09 c2                	or     %eax,%edx
  802218:	89 d8                	mov    %ebx,%eax
  80221a:	89 14 24             	mov    %edx,(%esp)
  80221d:	89 f2                	mov    %esi,%edx
  80221f:	d3 e2                	shl    %cl,%edx
  802221:	89 f9                	mov    %edi,%ecx
  802223:	89 54 24 04          	mov    %edx,0x4(%esp)
  802227:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80222b:	d3 e8                	shr    %cl,%eax
  80222d:	89 e9                	mov    %ebp,%ecx
  80222f:	89 c6                	mov    %eax,%esi
  802231:	d3 e3                	shl    %cl,%ebx
  802233:	89 f9                	mov    %edi,%ecx
  802235:	89 d0                	mov    %edx,%eax
  802237:	d3 e8                	shr    %cl,%eax
  802239:	89 e9                	mov    %ebp,%ecx
  80223b:	09 d8                	or     %ebx,%eax
  80223d:	89 d3                	mov    %edx,%ebx
  80223f:	89 f2                	mov    %esi,%edx
  802241:	f7 34 24             	divl   (%esp)
  802244:	89 d6                	mov    %edx,%esi
  802246:	d3 e3                	shl    %cl,%ebx
  802248:	f7 64 24 04          	mull   0x4(%esp)
  80224c:	39 d6                	cmp    %edx,%esi
  80224e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802252:	89 d1                	mov    %edx,%ecx
  802254:	89 c3                	mov    %eax,%ebx
  802256:	72 08                	jb     802260 <__umoddi3+0x110>
  802258:	75 11                	jne    80226b <__umoddi3+0x11b>
  80225a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80225e:	73 0b                	jae    80226b <__umoddi3+0x11b>
  802260:	2b 44 24 04          	sub    0x4(%esp),%eax
  802264:	1b 14 24             	sbb    (%esp),%edx
  802267:	89 d1                	mov    %edx,%ecx
  802269:	89 c3                	mov    %eax,%ebx
  80226b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80226f:	29 da                	sub    %ebx,%edx
  802271:	19 ce                	sbb    %ecx,%esi
  802273:	89 f9                	mov    %edi,%ecx
  802275:	89 f0                	mov    %esi,%eax
  802277:	d3 e0                	shl    %cl,%eax
  802279:	89 e9                	mov    %ebp,%ecx
  80227b:	d3 ea                	shr    %cl,%edx
  80227d:	89 e9                	mov    %ebp,%ecx
  80227f:	d3 ee                	shr    %cl,%esi
  802281:	09 d0                	or     %edx,%eax
  802283:	89 f2                	mov    %esi,%edx
  802285:	83 c4 1c             	add    $0x1c,%esp
  802288:	5b                   	pop    %ebx
  802289:	5e                   	pop    %esi
  80228a:	5f                   	pop    %edi
  80228b:	5d                   	pop    %ebp
  80228c:	c3                   	ret    
  80228d:	8d 76 00             	lea    0x0(%esi),%esi
  802290:	29 f9                	sub    %edi,%ecx
  802292:	19 d6                	sbb    %edx,%esi
  802294:	89 74 24 04          	mov    %esi,0x4(%esp)
  802298:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80229c:	e9 18 ff ff ff       	jmp    8021b9 <__umoddi3+0x69>
