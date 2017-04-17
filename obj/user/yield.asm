
obj/user/yield.debug:     file format elf32-i386


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
  80002c:	e8 69 00 00 00       	call   80009a <libmain>
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
  800037:	83 ec 0c             	sub    $0xc,%esp
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
  80003a:	a1 08 40 80 00       	mov    0x804008,%eax
  80003f:	8b 40 48             	mov    0x48(%eax),%eax
  800042:	50                   	push   %eax
  800043:	68 c0 22 80 00       	push   $0x8022c0
  800048:	e8 40 01 00 00       	call   80018d <cprintf>
  80004d:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 5; i++) {
  800050:	bb 00 00 00 00       	mov    $0x0,%ebx
		sys_yield();
  800055:	e8 9c 0a 00 00       	call   800af6 <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
  80005a:	a1 08 40 80 00       	mov    0x804008,%eax
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
  80005f:	8b 40 48             	mov    0x48(%eax),%eax
  800062:	83 ec 04             	sub    $0x4,%esp
  800065:	53                   	push   %ebx
  800066:	50                   	push   %eax
  800067:	68 e0 22 80 00       	push   $0x8022e0
  80006c:	e8 1c 01 00 00       	call   80018d <cprintf>
umain(int argc, char **argv)
{
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
  800071:	83 c3 01             	add    $0x1,%ebx
  800074:	83 c4 10             	add    $0x10,%esp
  800077:	83 fb 05             	cmp    $0x5,%ebx
  80007a:	75 d9                	jne    800055 <umain+0x22>
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
	}
	cprintf("All done in environment %08x.\n", thisenv->env_id);
  80007c:	a1 08 40 80 00       	mov    0x804008,%eax
  800081:	8b 40 48             	mov    0x48(%eax),%eax
  800084:	83 ec 08             	sub    $0x8,%esp
  800087:	50                   	push   %eax
  800088:	68 0c 23 80 00       	push   $0x80230c
  80008d:	e8 fb 00 00 00       	call   80018d <cprintf>
}
  800092:	83 c4 10             	add    $0x10,%esp
  800095:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800098:	c9                   	leave  
  800099:	c3                   	ret    

0080009a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	56                   	push   %esi
  80009e:	53                   	push   %ebx
  80009f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000a2:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000a5:	e8 2d 0a 00 00       	call   800ad7 <sys_getenvid>
  8000aa:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000af:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000b2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000b7:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000bc:	85 db                	test   %ebx,%ebx
  8000be:	7e 07                	jle    8000c7 <libmain+0x2d>
		binaryname = argv[0];
  8000c0:	8b 06                	mov    (%esi),%eax
  8000c2:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000c7:	83 ec 08             	sub    $0x8,%esp
  8000ca:	56                   	push   %esi
  8000cb:	53                   	push   %ebx
  8000cc:	e8 62 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000d1:	e8 0a 00 00 00       	call   8000e0 <exit>
}
  8000d6:	83 c4 10             	add    $0x10,%esp
  8000d9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000dc:	5b                   	pop    %ebx
  8000dd:	5e                   	pop    %esi
  8000de:	5d                   	pop    %ebp
  8000df:	c3                   	ret    

008000e0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000e6:	e8 05 0e 00 00       	call   800ef0 <close_all>
	sys_env_destroy(0);
  8000eb:	83 ec 0c             	sub    $0xc,%esp
  8000ee:	6a 00                	push   $0x0
  8000f0:	e8 a1 09 00 00       	call   800a96 <sys_env_destroy>
}
  8000f5:	83 c4 10             	add    $0x10,%esp
  8000f8:	c9                   	leave  
  8000f9:	c3                   	ret    

008000fa <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000fa:	55                   	push   %ebp
  8000fb:	89 e5                	mov    %esp,%ebp
  8000fd:	53                   	push   %ebx
  8000fe:	83 ec 04             	sub    $0x4,%esp
  800101:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800104:	8b 13                	mov    (%ebx),%edx
  800106:	8d 42 01             	lea    0x1(%edx),%eax
  800109:	89 03                	mov    %eax,(%ebx)
  80010b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80010e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800112:	3d ff 00 00 00       	cmp    $0xff,%eax
  800117:	75 1a                	jne    800133 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800119:	83 ec 08             	sub    $0x8,%esp
  80011c:	68 ff 00 00 00       	push   $0xff
  800121:	8d 43 08             	lea    0x8(%ebx),%eax
  800124:	50                   	push   %eax
  800125:	e8 2f 09 00 00       	call   800a59 <sys_cputs>
		b->idx = 0;
  80012a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800130:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800133:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800137:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80013a:	c9                   	leave  
  80013b:	c3                   	ret    

0080013c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800145:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80014c:	00 00 00 
	b.cnt = 0;
  80014f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800156:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800159:	ff 75 0c             	pushl  0xc(%ebp)
  80015c:	ff 75 08             	pushl  0x8(%ebp)
  80015f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800165:	50                   	push   %eax
  800166:	68 fa 00 80 00       	push   $0x8000fa
  80016b:	e8 54 01 00 00       	call   8002c4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800170:	83 c4 08             	add    $0x8,%esp
  800173:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800179:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80017f:	50                   	push   %eax
  800180:	e8 d4 08 00 00       	call   800a59 <sys_cputs>

	return b.cnt;
}
  800185:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80018b:	c9                   	leave  
  80018c:	c3                   	ret    

0080018d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80018d:	55                   	push   %ebp
  80018e:	89 e5                	mov    %esp,%ebp
  800190:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800193:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800196:	50                   	push   %eax
  800197:	ff 75 08             	pushl  0x8(%ebp)
  80019a:	e8 9d ff ff ff       	call   80013c <vcprintf>
	va_end(ap);

	return cnt;
}
  80019f:	c9                   	leave  
  8001a0:	c3                   	ret    

008001a1 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a1:	55                   	push   %ebp
  8001a2:	89 e5                	mov    %esp,%ebp
  8001a4:	57                   	push   %edi
  8001a5:	56                   	push   %esi
  8001a6:	53                   	push   %ebx
  8001a7:	83 ec 1c             	sub    $0x1c,%esp
  8001aa:	89 c7                	mov    %eax,%edi
  8001ac:	89 d6                	mov    %edx,%esi
  8001ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001b4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001b7:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001ba:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001bd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001c2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001c5:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001c8:	39 d3                	cmp    %edx,%ebx
  8001ca:	72 05                	jb     8001d1 <printnum+0x30>
  8001cc:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001cf:	77 45                	ja     800216 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d1:	83 ec 0c             	sub    $0xc,%esp
  8001d4:	ff 75 18             	pushl  0x18(%ebp)
  8001d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8001da:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001dd:	53                   	push   %ebx
  8001de:	ff 75 10             	pushl  0x10(%ebp)
  8001e1:	83 ec 08             	sub    $0x8,%esp
  8001e4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001e7:	ff 75 e0             	pushl  -0x20(%ebp)
  8001ea:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ed:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f0:	e8 2b 1e 00 00       	call   802020 <__udivdi3>
  8001f5:	83 c4 18             	add    $0x18,%esp
  8001f8:	52                   	push   %edx
  8001f9:	50                   	push   %eax
  8001fa:	89 f2                	mov    %esi,%edx
  8001fc:	89 f8                	mov    %edi,%eax
  8001fe:	e8 9e ff ff ff       	call   8001a1 <printnum>
  800203:	83 c4 20             	add    $0x20,%esp
  800206:	eb 18                	jmp    800220 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800208:	83 ec 08             	sub    $0x8,%esp
  80020b:	56                   	push   %esi
  80020c:	ff 75 18             	pushl  0x18(%ebp)
  80020f:	ff d7                	call   *%edi
  800211:	83 c4 10             	add    $0x10,%esp
  800214:	eb 03                	jmp    800219 <printnum+0x78>
  800216:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800219:	83 eb 01             	sub    $0x1,%ebx
  80021c:	85 db                	test   %ebx,%ebx
  80021e:	7f e8                	jg     800208 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800220:	83 ec 08             	sub    $0x8,%esp
  800223:	56                   	push   %esi
  800224:	83 ec 04             	sub    $0x4,%esp
  800227:	ff 75 e4             	pushl  -0x1c(%ebp)
  80022a:	ff 75 e0             	pushl  -0x20(%ebp)
  80022d:	ff 75 dc             	pushl  -0x24(%ebp)
  800230:	ff 75 d8             	pushl  -0x28(%ebp)
  800233:	e8 18 1f 00 00       	call   802150 <__umoddi3>
  800238:	83 c4 14             	add    $0x14,%esp
  80023b:	0f be 80 35 23 80 00 	movsbl 0x802335(%eax),%eax
  800242:	50                   	push   %eax
  800243:	ff d7                	call   *%edi
}
  800245:	83 c4 10             	add    $0x10,%esp
  800248:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80024b:	5b                   	pop    %ebx
  80024c:	5e                   	pop    %esi
  80024d:	5f                   	pop    %edi
  80024e:	5d                   	pop    %ebp
  80024f:	c3                   	ret    

00800250 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800250:	55                   	push   %ebp
  800251:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800253:	83 fa 01             	cmp    $0x1,%edx
  800256:	7e 0e                	jle    800266 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800258:	8b 10                	mov    (%eax),%edx
  80025a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80025d:	89 08                	mov    %ecx,(%eax)
  80025f:	8b 02                	mov    (%edx),%eax
  800261:	8b 52 04             	mov    0x4(%edx),%edx
  800264:	eb 22                	jmp    800288 <getuint+0x38>
	else if (lflag)
  800266:	85 d2                	test   %edx,%edx
  800268:	74 10                	je     80027a <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80026a:	8b 10                	mov    (%eax),%edx
  80026c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80026f:	89 08                	mov    %ecx,(%eax)
  800271:	8b 02                	mov    (%edx),%eax
  800273:	ba 00 00 00 00       	mov    $0x0,%edx
  800278:	eb 0e                	jmp    800288 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80027a:	8b 10                	mov    (%eax),%edx
  80027c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80027f:	89 08                	mov    %ecx,(%eax)
  800281:	8b 02                	mov    (%edx),%eax
  800283:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800288:	5d                   	pop    %ebp
  800289:	c3                   	ret    

0080028a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800290:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800294:	8b 10                	mov    (%eax),%edx
  800296:	3b 50 04             	cmp    0x4(%eax),%edx
  800299:	73 0a                	jae    8002a5 <sprintputch+0x1b>
		*b->buf++ = ch;
  80029b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80029e:	89 08                	mov    %ecx,(%eax)
  8002a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a3:	88 02                	mov    %al,(%edx)
}
  8002a5:	5d                   	pop    %ebp
  8002a6:	c3                   	ret    

008002a7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002a7:	55                   	push   %ebp
  8002a8:	89 e5                	mov    %esp,%ebp
  8002aa:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002ad:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002b0:	50                   	push   %eax
  8002b1:	ff 75 10             	pushl  0x10(%ebp)
  8002b4:	ff 75 0c             	pushl  0xc(%ebp)
  8002b7:	ff 75 08             	pushl  0x8(%ebp)
  8002ba:	e8 05 00 00 00       	call   8002c4 <vprintfmt>
	va_end(ap);
}
  8002bf:	83 c4 10             	add    $0x10,%esp
  8002c2:	c9                   	leave  
  8002c3:	c3                   	ret    

008002c4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002c4:	55                   	push   %ebp
  8002c5:	89 e5                	mov    %esp,%ebp
  8002c7:	57                   	push   %edi
  8002c8:	56                   	push   %esi
  8002c9:	53                   	push   %ebx
  8002ca:	83 ec 2c             	sub    $0x2c,%esp
  8002cd:	8b 75 08             	mov    0x8(%ebp),%esi
  8002d0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002d3:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002d6:	eb 12                	jmp    8002ea <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002d8:	85 c0                	test   %eax,%eax
  8002da:	0f 84 89 03 00 00    	je     800669 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8002e0:	83 ec 08             	sub    $0x8,%esp
  8002e3:	53                   	push   %ebx
  8002e4:	50                   	push   %eax
  8002e5:	ff d6                	call   *%esi
  8002e7:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002ea:	83 c7 01             	add    $0x1,%edi
  8002ed:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002f1:	83 f8 25             	cmp    $0x25,%eax
  8002f4:	75 e2                	jne    8002d8 <vprintfmt+0x14>
  8002f6:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002fa:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800301:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800308:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80030f:	ba 00 00 00 00       	mov    $0x0,%edx
  800314:	eb 07                	jmp    80031d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800316:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800319:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80031d:	8d 47 01             	lea    0x1(%edi),%eax
  800320:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800323:	0f b6 07             	movzbl (%edi),%eax
  800326:	0f b6 c8             	movzbl %al,%ecx
  800329:	83 e8 23             	sub    $0x23,%eax
  80032c:	3c 55                	cmp    $0x55,%al
  80032e:	0f 87 1a 03 00 00    	ja     80064e <vprintfmt+0x38a>
  800334:	0f b6 c0             	movzbl %al,%eax
  800337:	ff 24 85 80 24 80 00 	jmp    *0x802480(,%eax,4)
  80033e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800341:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800345:	eb d6                	jmp    80031d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800347:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80034a:	b8 00 00 00 00       	mov    $0x0,%eax
  80034f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800352:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800355:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800359:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80035c:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80035f:	83 fa 09             	cmp    $0x9,%edx
  800362:	77 39                	ja     80039d <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800364:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800367:	eb e9                	jmp    800352 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800369:	8b 45 14             	mov    0x14(%ebp),%eax
  80036c:	8d 48 04             	lea    0x4(%eax),%ecx
  80036f:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800372:	8b 00                	mov    (%eax),%eax
  800374:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800377:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80037a:	eb 27                	jmp    8003a3 <vprintfmt+0xdf>
  80037c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80037f:	85 c0                	test   %eax,%eax
  800381:	b9 00 00 00 00       	mov    $0x0,%ecx
  800386:	0f 49 c8             	cmovns %eax,%ecx
  800389:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80038f:	eb 8c                	jmp    80031d <vprintfmt+0x59>
  800391:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800394:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80039b:	eb 80                	jmp    80031d <vprintfmt+0x59>
  80039d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003a0:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003a3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003a7:	0f 89 70 ff ff ff    	jns    80031d <vprintfmt+0x59>
				width = precision, precision = -1;
  8003ad:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003b0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003b3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003ba:	e9 5e ff ff ff       	jmp    80031d <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003bf:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003c5:	e9 53 ff ff ff       	jmp    80031d <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cd:	8d 50 04             	lea    0x4(%eax),%edx
  8003d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8003d3:	83 ec 08             	sub    $0x8,%esp
  8003d6:	53                   	push   %ebx
  8003d7:	ff 30                	pushl  (%eax)
  8003d9:	ff d6                	call   *%esi
			break;
  8003db:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003e1:	e9 04 ff ff ff       	jmp    8002ea <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e9:	8d 50 04             	lea    0x4(%eax),%edx
  8003ec:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ef:	8b 00                	mov    (%eax),%eax
  8003f1:	99                   	cltd   
  8003f2:	31 d0                	xor    %edx,%eax
  8003f4:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003f6:	83 f8 0f             	cmp    $0xf,%eax
  8003f9:	7f 0b                	jg     800406 <vprintfmt+0x142>
  8003fb:	8b 14 85 e0 25 80 00 	mov    0x8025e0(,%eax,4),%edx
  800402:	85 d2                	test   %edx,%edx
  800404:	75 18                	jne    80041e <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800406:	50                   	push   %eax
  800407:	68 4d 23 80 00       	push   $0x80234d
  80040c:	53                   	push   %ebx
  80040d:	56                   	push   %esi
  80040e:	e8 94 fe ff ff       	call   8002a7 <printfmt>
  800413:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800416:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800419:	e9 cc fe ff ff       	jmp    8002ea <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80041e:	52                   	push   %edx
  80041f:	68 1a 27 80 00       	push   $0x80271a
  800424:	53                   	push   %ebx
  800425:	56                   	push   %esi
  800426:	e8 7c fe ff ff       	call   8002a7 <printfmt>
  80042b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800431:	e9 b4 fe ff ff       	jmp    8002ea <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800436:	8b 45 14             	mov    0x14(%ebp),%eax
  800439:	8d 50 04             	lea    0x4(%eax),%edx
  80043c:	89 55 14             	mov    %edx,0x14(%ebp)
  80043f:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800441:	85 ff                	test   %edi,%edi
  800443:	b8 46 23 80 00       	mov    $0x802346,%eax
  800448:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80044b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80044f:	0f 8e 94 00 00 00    	jle    8004e9 <vprintfmt+0x225>
  800455:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800459:	0f 84 98 00 00 00    	je     8004f7 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80045f:	83 ec 08             	sub    $0x8,%esp
  800462:	ff 75 d0             	pushl  -0x30(%ebp)
  800465:	57                   	push   %edi
  800466:	e8 86 02 00 00       	call   8006f1 <strnlen>
  80046b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80046e:	29 c1                	sub    %eax,%ecx
  800470:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800473:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800476:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80047a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80047d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800480:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800482:	eb 0f                	jmp    800493 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800484:	83 ec 08             	sub    $0x8,%esp
  800487:	53                   	push   %ebx
  800488:	ff 75 e0             	pushl  -0x20(%ebp)
  80048b:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80048d:	83 ef 01             	sub    $0x1,%edi
  800490:	83 c4 10             	add    $0x10,%esp
  800493:	85 ff                	test   %edi,%edi
  800495:	7f ed                	jg     800484 <vprintfmt+0x1c0>
  800497:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80049a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80049d:	85 c9                	test   %ecx,%ecx
  80049f:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a4:	0f 49 c1             	cmovns %ecx,%eax
  8004a7:	29 c1                	sub    %eax,%ecx
  8004a9:	89 75 08             	mov    %esi,0x8(%ebp)
  8004ac:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004af:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004b2:	89 cb                	mov    %ecx,%ebx
  8004b4:	eb 4d                	jmp    800503 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004b6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004ba:	74 1b                	je     8004d7 <vprintfmt+0x213>
  8004bc:	0f be c0             	movsbl %al,%eax
  8004bf:	83 e8 20             	sub    $0x20,%eax
  8004c2:	83 f8 5e             	cmp    $0x5e,%eax
  8004c5:	76 10                	jbe    8004d7 <vprintfmt+0x213>
					putch('?', putdat);
  8004c7:	83 ec 08             	sub    $0x8,%esp
  8004ca:	ff 75 0c             	pushl  0xc(%ebp)
  8004cd:	6a 3f                	push   $0x3f
  8004cf:	ff 55 08             	call   *0x8(%ebp)
  8004d2:	83 c4 10             	add    $0x10,%esp
  8004d5:	eb 0d                	jmp    8004e4 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004d7:	83 ec 08             	sub    $0x8,%esp
  8004da:	ff 75 0c             	pushl  0xc(%ebp)
  8004dd:	52                   	push   %edx
  8004de:	ff 55 08             	call   *0x8(%ebp)
  8004e1:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004e4:	83 eb 01             	sub    $0x1,%ebx
  8004e7:	eb 1a                	jmp    800503 <vprintfmt+0x23f>
  8004e9:	89 75 08             	mov    %esi,0x8(%ebp)
  8004ec:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004ef:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004f2:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004f5:	eb 0c                	jmp    800503 <vprintfmt+0x23f>
  8004f7:	89 75 08             	mov    %esi,0x8(%ebp)
  8004fa:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004fd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800500:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800503:	83 c7 01             	add    $0x1,%edi
  800506:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80050a:	0f be d0             	movsbl %al,%edx
  80050d:	85 d2                	test   %edx,%edx
  80050f:	74 23                	je     800534 <vprintfmt+0x270>
  800511:	85 f6                	test   %esi,%esi
  800513:	78 a1                	js     8004b6 <vprintfmt+0x1f2>
  800515:	83 ee 01             	sub    $0x1,%esi
  800518:	79 9c                	jns    8004b6 <vprintfmt+0x1f2>
  80051a:	89 df                	mov    %ebx,%edi
  80051c:	8b 75 08             	mov    0x8(%ebp),%esi
  80051f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800522:	eb 18                	jmp    80053c <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800524:	83 ec 08             	sub    $0x8,%esp
  800527:	53                   	push   %ebx
  800528:	6a 20                	push   $0x20
  80052a:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80052c:	83 ef 01             	sub    $0x1,%edi
  80052f:	83 c4 10             	add    $0x10,%esp
  800532:	eb 08                	jmp    80053c <vprintfmt+0x278>
  800534:	89 df                	mov    %ebx,%edi
  800536:	8b 75 08             	mov    0x8(%ebp),%esi
  800539:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80053c:	85 ff                	test   %edi,%edi
  80053e:	7f e4                	jg     800524 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800540:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800543:	e9 a2 fd ff ff       	jmp    8002ea <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800548:	83 fa 01             	cmp    $0x1,%edx
  80054b:	7e 16                	jle    800563 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80054d:	8b 45 14             	mov    0x14(%ebp),%eax
  800550:	8d 50 08             	lea    0x8(%eax),%edx
  800553:	89 55 14             	mov    %edx,0x14(%ebp)
  800556:	8b 50 04             	mov    0x4(%eax),%edx
  800559:	8b 00                	mov    (%eax),%eax
  80055b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80055e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800561:	eb 32                	jmp    800595 <vprintfmt+0x2d1>
	else if (lflag)
  800563:	85 d2                	test   %edx,%edx
  800565:	74 18                	je     80057f <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800567:	8b 45 14             	mov    0x14(%ebp),%eax
  80056a:	8d 50 04             	lea    0x4(%eax),%edx
  80056d:	89 55 14             	mov    %edx,0x14(%ebp)
  800570:	8b 00                	mov    (%eax),%eax
  800572:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800575:	89 c1                	mov    %eax,%ecx
  800577:	c1 f9 1f             	sar    $0x1f,%ecx
  80057a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80057d:	eb 16                	jmp    800595 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80057f:	8b 45 14             	mov    0x14(%ebp),%eax
  800582:	8d 50 04             	lea    0x4(%eax),%edx
  800585:	89 55 14             	mov    %edx,0x14(%ebp)
  800588:	8b 00                	mov    (%eax),%eax
  80058a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80058d:	89 c1                	mov    %eax,%ecx
  80058f:	c1 f9 1f             	sar    $0x1f,%ecx
  800592:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800595:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800598:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80059b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005a0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005a4:	79 74                	jns    80061a <vprintfmt+0x356>
				putch('-', putdat);
  8005a6:	83 ec 08             	sub    $0x8,%esp
  8005a9:	53                   	push   %ebx
  8005aa:	6a 2d                	push   $0x2d
  8005ac:	ff d6                	call   *%esi
				num = -(long long) num;
  8005ae:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005b1:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005b4:	f7 d8                	neg    %eax
  8005b6:	83 d2 00             	adc    $0x0,%edx
  8005b9:	f7 da                	neg    %edx
  8005bb:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005be:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005c3:	eb 55                	jmp    80061a <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005c5:	8d 45 14             	lea    0x14(%ebp),%eax
  8005c8:	e8 83 fc ff ff       	call   800250 <getuint>
			base = 10;
  8005cd:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005d2:	eb 46                	jmp    80061a <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005d4:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d7:	e8 74 fc ff ff       	call   800250 <getuint>
                        base = 8;
  8005dc:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  8005e1:	eb 37                	jmp    80061a <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8005e3:	83 ec 08             	sub    $0x8,%esp
  8005e6:	53                   	push   %ebx
  8005e7:	6a 30                	push   $0x30
  8005e9:	ff d6                	call   *%esi
			putch('x', putdat);
  8005eb:	83 c4 08             	add    $0x8,%esp
  8005ee:	53                   	push   %ebx
  8005ef:	6a 78                	push   $0x78
  8005f1:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f6:	8d 50 04             	lea    0x4(%eax),%edx
  8005f9:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005fc:	8b 00                	mov    (%eax),%eax
  8005fe:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800603:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800606:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80060b:	eb 0d                	jmp    80061a <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80060d:	8d 45 14             	lea    0x14(%ebp),%eax
  800610:	e8 3b fc ff ff       	call   800250 <getuint>
			base = 16;
  800615:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80061a:	83 ec 0c             	sub    $0xc,%esp
  80061d:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800621:	57                   	push   %edi
  800622:	ff 75 e0             	pushl  -0x20(%ebp)
  800625:	51                   	push   %ecx
  800626:	52                   	push   %edx
  800627:	50                   	push   %eax
  800628:	89 da                	mov    %ebx,%edx
  80062a:	89 f0                	mov    %esi,%eax
  80062c:	e8 70 fb ff ff       	call   8001a1 <printnum>
			break;
  800631:	83 c4 20             	add    $0x20,%esp
  800634:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800637:	e9 ae fc ff ff       	jmp    8002ea <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80063c:	83 ec 08             	sub    $0x8,%esp
  80063f:	53                   	push   %ebx
  800640:	51                   	push   %ecx
  800641:	ff d6                	call   *%esi
			break;
  800643:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800646:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800649:	e9 9c fc ff ff       	jmp    8002ea <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80064e:	83 ec 08             	sub    $0x8,%esp
  800651:	53                   	push   %ebx
  800652:	6a 25                	push   $0x25
  800654:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800656:	83 c4 10             	add    $0x10,%esp
  800659:	eb 03                	jmp    80065e <vprintfmt+0x39a>
  80065b:	83 ef 01             	sub    $0x1,%edi
  80065e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800662:	75 f7                	jne    80065b <vprintfmt+0x397>
  800664:	e9 81 fc ff ff       	jmp    8002ea <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800669:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80066c:	5b                   	pop    %ebx
  80066d:	5e                   	pop    %esi
  80066e:	5f                   	pop    %edi
  80066f:	5d                   	pop    %ebp
  800670:	c3                   	ret    

00800671 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800671:	55                   	push   %ebp
  800672:	89 e5                	mov    %esp,%ebp
  800674:	83 ec 18             	sub    $0x18,%esp
  800677:	8b 45 08             	mov    0x8(%ebp),%eax
  80067a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80067d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800680:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800684:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800687:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80068e:	85 c0                	test   %eax,%eax
  800690:	74 26                	je     8006b8 <vsnprintf+0x47>
  800692:	85 d2                	test   %edx,%edx
  800694:	7e 22                	jle    8006b8 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800696:	ff 75 14             	pushl  0x14(%ebp)
  800699:	ff 75 10             	pushl  0x10(%ebp)
  80069c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80069f:	50                   	push   %eax
  8006a0:	68 8a 02 80 00       	push   $0x80028a
  8006a5:	e8 1a fc ff ff       	call   8002c4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006aa:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006ad:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006b3:	83 c4 10             	add    $0x10,%esp
  8006b6:	eb 05                	jmp    8006bd <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006b8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006bd:	c9                   	leave  
  8006be:	c3                   	ret    

008006bf <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006bf:	55                   	push   %ebp
  8006c0:	89 e5                	mov    %esp,%ebp
  8006c2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006c5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006c8:	50                   	push   %eax
  8006c9:	ff 75 10             	pushl  0x10(%ebp)
  8006cc:	ff 75 0c             	pushl  0xc(%ebp)
  8006cf:	ff 75 08             	pushl  0x8(%ebp)
  8006d2:	e8 9a ff ff ff       	call   800671 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006d7:	c9                   	leave  
  8006d8:	c3                   	ret    

008006d9 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006d9:	55                   	push   %ebp
  8006da:	89 e5                	mov    %esp,%ebp
  8006dc:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006df:	b8 00 00 00 00       	mov    $0x0,%eax
  8006e4:	eb 03                	jmp    8006e9 <strlen+0x10>
		n++;
  8006e6:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006e9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006ed:	75 f7                	jne    8006e6 <strlen+0xd>
		n++;
	return n;
}
  8006ef:	5d                   	pop    %ebp
  8006f0:	c3                   	ret    

008006f1 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006f1:	55                   	push   %ebp
  8006f2:	89 e5                	mov    %esp,%ebp
  8006f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006f7:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8006ff:	eb 03                	jmp    800704 <strnlen+0x13>
		n++;
  800701:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800704:	39 c2                	cmp    %eax,%edx
  800706:	74 08                	je     800710 <strnlen+0x1f>
  800708:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80070c:	75 f3                	jne    800701 <strnlen+0x10>
  80070e:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800710:	5d                   	pop    %ebp
  800711:	c3                   	ret    

00800712 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800712:	55                   	push   %ebp
  800713:	89 e5                	mov    %esp,%ebp
  800715:	53                   	push   %ebx
  800716:	8b 45 08             	mov    0x8(%ebp),%eax
  800719:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80071c:	89 c2                	mov    %eax,%edx
  80071e:	83 c2 01             	add    $0x1,%edx
  800721:	83 c1 01             	add    $0x1,%ecx
  800724:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800728:	88 5a ff             	mov    %bl,-0x1(%edx)
  80072b:	84 db                	test   %bl,%bl
  80072d:	75 ef                	jne    80071e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80072f:	5b                   	pop    %ebx
  800730:	5d                   	pop    %ebp
  800731:	c3                   	ret    

00800732 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800732:	55                   	push   %ebp
  800733:	89 e5                	mov    %esp,%ebp
  800735:	53                   	push   %ebx
  800736:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800739:	53                   	push   %ebx
  80073a:	e8 9a ff ff ff       	call   8006d9 <strlen>
  80073f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800742:	ff 75 0c             	pushl  0xc(%ebp)
  800745:	01 d8                	add    %ebx,%eax
  800747:	50                   	push   %eax
  800748:	e8 c5 ff ff ff       	call   800712 <strcpy>
	return dst;
}
  80074d:	89 d8                	mov    %ebx,%eax
  80074f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800752:	c9                   	leave  
  800753:	c3                   	ret    

00800754 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800754:	55                   	push   %ebp
  800755:	89 e5                	mov    %esp,%ebp
  800757:	56                   	push   %esi
  800758:	53                   	push   %ebx
  800759:	8b 75 08             	mov    0x8(%ebp),%esi
  80075c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80075f:	89 f3                	mov    %esi,%ebx
  800761:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800764:	89 f2                	mov    %esi,%edx
  800766:	eb 0f                	jmp    800777 <strncpy+0x23>
		*dst++ = *src;
  800768:	83 c2 01             	add    $0x1,%edx
  80076b:	0f b6 01             	movzbl (%ecx),%eax
  80076e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800771:	80 39 01             	cmpb   $0x1,(%ecx)
  800774:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800777:	39 da                	cmp    %ebx,%edx
  800779:	75 ed                	jne    800768 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80077b:	89 f0                	mov    %esi,%eax
  80077d:	5b                   	pop    %ebx
  80077e:	5e                   	pop    %esi
  80077f:	5d                   	pop    %ebp
  800780:	c3                   	ret    

00800781 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800781:	55                   	push   %ebp
  800782:	89 e5                	mov    %esp,%ebp
  800784:	56                   	push   %esi
  800785:	53                   	push   %ebx
  800786:	8b 75 08             	mov    0x8(%ebp),%esi
  800789:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80078c:	8b 55 10             	mov    0x10(%ebp),%edx
  80078f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800791:	85 d2                	test   %edx,%edx
  800793:	74 21                	je     8007b6 <strlcpy+0x35>
  800795:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800799:	89 f2                	mov    %esi,%edx
  80079b:	eb 09                	jmp    8007a6 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80079d:	83 c2 01             	add    $0x1,%edx
  8007a0:	83 c1 01             	add    $0x1,%ecx
  8007a3:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007a6:	39 c2                	cmp    %eax,%edx
  8007a8:	74 09                	je     8007b3 <strlcpy+0x32>
  8007aa:	0f b6 19             	movzbl (%ecx),%ebx
  8007ad:	84 db                	test   %bl,%bl
  8007af:	75 ec                	jne    80079d <strlcpy+0x1c>
  8007b1:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007b3:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007b6:	29 f0                	sub    %esi,%eax
}
  8007b8:	5b                   	pop    %ebx
  8007b9:	5e                   	pop    %esi
  8007ba:	5d                   	pop    %ebp
  8007bb:	c3                   	ret    

008007bc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007bc:	55                   	push   %ebp
  8007bd:	89 e5                	mov    %esp,%ebp
  8007bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007c5:	eb 06                	jmp    8007cd <strcmp+0x11>
		p++, q++;
  8007c7:	83 c1 01             	add    $0x1,%ecx
  8007ca:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007cd:	0f b6 01             	movzbl (%ecx),%eax
  8007d0:	84 c0                	test   %al,%al
  8007d2:	74 04                	je     8007d8 <strcmp+0x1c>
  8007d4:	3a 02                	cmp    (%edx),%al
  8007d6:	74 ef                	je     8007c7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007d8:	0f b6 c0             	movzbl %al,%eax
  8007db:	0f b6 12             	movzbl (%edx),%edx
  8007de:	29 d0                	sub    %edx,%eax
}
  8007e0:	5d                   	pop    %ebp
  8007e1:	c3                   	ret    

008007e2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007e2:	55                   	push   %ebp
  8007e3:	89 e5                	mov    %esp,%ebp
  8007e5:	53                   	push   %ebx
  8007e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ec:	89 c3                	mov    %eax,%ebx
  8007ee:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007f1:	eb 06                	jmp    8007f9 <strncmp+0x17>
		n--, p++, q++;
  8007f3:	83 c0 01             	add    $0x1,%eax
  8007f6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007f9:	39 d8                	cmp    %ebx,%eax
  8007fb:	74 15                	je     800812 <strncmp+0x30>
  8007fd:	0f b6 08             	movzbl (%eax),%ecx
  800800:	84 c9                	test   %cl,%cl
  800802:	74 04                	je     800808 <strncmp+0x26>
  800804:	3a 0a                	cmp    (%edx),%cl
  800806:	74 eb                	je     8007f3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800808:	0f b6 00             	movzbl (%eax),%eax
  80080b:	0f b6 12             	movzbl (%edx),%edx
  80080e:	29 d0                	sub    %edx,%eax
  800810:	eb 05                	jmp    800817 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800812:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800817:	5b                   	pop    %ebx
  800818:	5d                   	pop    %ebp
  800819:	c3                   	ret    

0080081a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80081a:	55                   	push   %ebp
  80081b:	89 e5                	mov    %esp,%ebp
  80081d:	8b 45 08             	mov    0x8(%ebp),%eax
  800820:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800824:	eb 07                	jmp    80082d <strchr+0x13>
		if (*s == c)
  800826:	38 ca                	cmp    %cl,%dl
  800828:	74 0f                	je     800839 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80082a:	83 c0 01             	add    $0x1,%eax
  80082d:	0f b6 10             	movzbl (%eax),%edx
  800830:	84 d2                	test   %dl,%dl
  800832:	75 f2                	jne    800826 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800834:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800839:	5d                   	pop    %ebp
  80083a:	c3                   	ret    

0080083b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80083b:	55                   	push   %ebp
  80083c:	89 e5                	mov    %esp,%ebp
  80083e:	8b 45 08             	mov    0x8(%ebp),%eax
  800841:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800845:	eb 03                	jmp    80084a <strfind+0xf>
  800847:	83 c0 01             	add    $0x1,%eax
  80084a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80084d:	38 ca                	cmp    %cl,%dl
  80084f:	74 04                	je     800855 <strfind+0x1a>
  800851:	84 d2                	test   %dl,%dl
  800853:	75 f2                	jne    800847 <strfind+0xc>
			break;
	return (char *) s;
}
  800855:	5d                   	pop    %ebp
  800856:	c3                   	ret    

00800857 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800857:	55                   	push   %ebp
  800858:	89 e5                	mov    %esp,%ebp
  80085a:	57                   	push   %edi
  80085b:	56                   	push   %esi
  80085c:	53                   	push   %ebx
  80085d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800860:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800863:	85 c9                	test   %ecx,%ecx
  800865:	74 36                	je     80089d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800867:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80086d:	75 28                	jne    800897 <memset+0x40>
  80086f:	f6 c1 03             	test   $0x3,%cl
  800872:	75 23                	jne    800897 <memset+0x40>
		c &= 0xFF;
  800874:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800878:	89 d3                	mov    %edx,%ebx
  80087a:	c1 e3 08             	shl    $0x8,%ebx
  80087d:	89 d6                	mov    %edx,%esi
  80087f:	c1 e6 18             	shl    $0x18,%esi
  800882:	89 d0                	mov    %edx,%eax
  800884:	c1 e0 10             	shl    $0x10,%eax
  800887:	09 f0                	or     %esi,%eax
  800889:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80088b:	89 d8                	mov    %ebx,%eax
  80088d:	09 d0                	or     %edx,%eax
  80088f:	c1 e9 02             	shr    $0x2,%ecx
  800892:	fc                   	cld    
  800893:	f3 ab                	rep stos %eax,%es:(%edi)
  800895:	eb 06                	jmp    80089d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800897:	8b 45 0c             	mov    0xc(%ebp),%eax
  80089a:	fc                   	cld    
  80089b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80089d:	89 f8                	mov    %edi,%eax
  80089f:	5b                   	pop    %ebx
  8008a0:	5e                   	pop    %esi
  8008a1:	5f                   	pop    %edi
  8008a2:	5d                   	pop    %ebp
  8008a3:	c3                   	ret    

008008a4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008a4:	55                   	push   %ebp
  8008a5:	89 e5                	mov    %esp,%ebp
  8008a7:	57                   	push   %edi
  8008a8:	56                   	push   %esi
  8008a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ac:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008af:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008b2:	39 c6                	cmp    %eax,%esi
  8008b4:	73 35                	jae    8008eb <memmove+0x47>
  8008b6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008b9:	39 d0                	cmp    %edx,%eax
  8008bb:	73 2e                	jae    8008eb <memmove+0x47>
		s += n;
		d += n;
  8008bd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008c0:	89 d6                	mov    %edx,%esi
  8008c2:	09 fe                	or     %edi,%esi
  8008c4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008ca:	75 13                	jne    8008df <memmove+0x3b>
  8008cc:	f6 c1 03             	test   $0x3,%cl
  8008cf:	75 0e                	jne    8008df <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008d1:	83 ef 04             	sub    $0x4,%edi
  8008d4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008d7:	c1 e9 02             	shr    $0x2,%ecx
  8008da:	fd                   	std    
  8008db:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008dd:	eb 09                	jmp    8008e8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008df:	83 ef 01             	sub    $0x1,%edi
  8008e2:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008e5:	fd                   	std    
  8008e6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008e8:	fc                   	cld    
  8008e9:	eb 1d                	jmp    800908 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008eb:	89 f2                	mov    %esi,%edx
  8008ed:	09 c2                	or     %eax,%edx
  8008ef:	f6 c2 03             	test   $0x3,%dl
  8008f2:	75 0f                	jne    800903 <memmove+0x5f>
  8008f4:	f6 c1 03             	test   $0x3,%cl
  8008f7:	75 0a                	jne    800903 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8008f9:	c1 e9 02             	shr    $0x2,%ecx
  8008fc:	89 c7                	mov    %eax,%edi
  8008fe:	fc                   	cld    
  8008ff:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800901:	eb 05                	jmp    800908 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800903:	89 c7                	mov    %eax,%edi
  800905:	fc                   	cld    
  800906:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800908:	5e                   	pop    %esi
  800909:	5f                   	pop    %edi
  80090a:	5d                   	pop    %ebp
  80090b:	c3                   	ret    

0080090c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80090c:	55                   	push   %ebp
  80090d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80090f:	ff 75 10             	pushl  0x10(%ebp)
  800912:	ff 75 0c             	pushl  0xc(%ebp)
  800915:	ff 75 08             	pushl  0x8(%ebp)
  800918:	e8 87 ff ff ff       	call   8008a4 <memmove>
}
  80091d:	c9                   	leave  
  80091e:	c3                   	ret    

0080091f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80091f:	55                   	push   %ebp
  800920:	89 e5                	mov    %esp,%ebp
  800922:	56                   	push   %esi
  800923:	53                   	push   %ebx
  800924:	8b 45 08             	mov    0x8(%ebp),%eax
  800927:	8b 55 0c             	mov    0xc(%ebp),%edx
  80092a:	89 c6                	mov    %eax,%esi
  80092c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80092f:	eb 1a                	jmp    80094b <memcmp+0x2c>
		if (*s1 != *s2)
  800931:	0f b6 08             	movzbl (%eax),%ecx
  800934:	0f b6 1a             	movzbl (%edx),%ebx
  800937:	38 d9                	cmp    %bl,%cl
  800939:	74 0a                	je     800945 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80093b:	0f b6 c1             	movzbl %cl,%eax
  80093e:	0f b6 db             	movzbl %bl,%ebx
  800941:	29 d8                	sub    %ebx,%eax
  800943:	eb 0f                	jmp    800954 <memcmp+0x35>
		s1++, s2++;
  800945:	83 c0 01             	add    $0x1,%eax
  800948:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80094b:	39 f0                	cmp    %esi,%eax
  80094d:	75 e2                	jne    800931 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80094f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800954:	5b                   	pop    %ebx
  800955:	5e                   	pop    %esi
  800956:	5d                   	pop    %ebp
  800957:	c3                   	ret    

00800958 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800958:	55                   	push   %ebp
  800959:	89 e5                	mov    %esp,%ebp
  80095b:	53                   	push   %ebx
  80095c:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80095f:	89 c1                	mov    %eax,%ecx
  800961:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800964:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800968:	eb 0a                	jmp    800974 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80096a:	0f b6 10             	movzbl (%eax),%edx
  80096d:	39 da                	cmp    %ebx,%edx
  80096f:	74 07                	je     800978 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800971:	83 c0 01             	add    $0x1,%eax
  800974:	39 c8                	cmp    %ecx,%eax
  800976:	72 f2                	jb     80096a <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800978:	5b                   	pop    %ebx
  800979:	5d                   	pop    %ebp
  80097a:	c3                   	ret    

0080097b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	57                   	push   %edi
  80097f:	56                   	push   %esi
  800980:	53                   	push   %ebx
  800981:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800984:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800987:	eb 03                	jmp    80098c <strtol+0x11>
		s++;
  800989:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80098c:	0f b6 01             	movzbl (%ecx),%eax
  80098f:	3c 20                	cmp    $0x20,%al
  800991:	74 f6                	je     800989 <strtol+0xe>
  800993:	3c 09                	cmp    $0x9,%al
  800995:	74 f2                	je     800989 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800997:	3c 2b                	cmp    $0x2b,%al
  800999:	75 0a                	jne    8009a5 <strtol+0x2a>
		s++;
  80099b:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80099e:	bf 00 00 00 00       	mov    $0x0,%edi
  8009a3:	eb 11                	jmp    8009b6 <strtol+0x3b>
  8009a5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009aa:	3c 2d                	cmp    $0x2d,%al
  8009ac:	75 08                	jne    8009b6 <strtol+0x3b>
		s++, neg = 1;
  8009ae:	83 c1 01             	add    $0x1,%ecx
  8009b1:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009b6:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009bc:	75 15                	jne    8009d3 <strtol+0x58>
  8009be:	80 39 30             	cmpb   $0x30,(%ecx)
  8009c1:	75 10                	jne    8009d3 <strtol+0x58>
  8009c3:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009c7:	75 7c                	jne    800a45 <strtol+0xca>
		s += 2, base = 16;
  8009c9:	83 c1 02             	add    $0x2,%ecx
  8009cc:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009d1:	eb 16                	jmp    8009e9 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009d3:	85 db                	test   %ebx,%ebx
  8009d5:	75 12                	jne    8009e9 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009d7:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009dc:	80 39 30             	cmpb   $0x30,(%ecx)
  8009df:	75 08                	jne    8009e9 <strtol+0x6e>
		s++, base = 8;
  8009e1:	83 c1 01             	add    $0x1,%ecx
  8009e4:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ee:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009f1:	0f b6 11             	movzbl (%ecx),%edx
  8009f4:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009f7:	89 f3                	mov    %esi,%ebx
  8009f9:	80 fb 09             	cmp    $0x9,%bl
  8009fc:	77 08                	ja     800a06 <strtol+0x8b>
			dig = *s - '0';
  8009fe:	0f be d2             	movsbl %dl,%edx
  800a01:	83 ea 30             	sub    $0x30,%edx
  800a04:	eb 22                	jmp    800a28 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a06:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a09:	89 f3                	mov    %esi,%ebx
  800a0b:	80 fb 19             	cmp    $0x19,%bl
  800a0e:	77 08                	ja     800a18 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a10:	0f be d2             	movsbl %dl,%edx
  800a13:	83 ea 57             	sub    $0x57,%edx
  800a16:	eb 10                	jmp    800a28 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a18:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a1b:	89 f3                	mov    %esi,%ebx
  800a1d:	80 fb 19             	cmp    $0x19,%bl
  800a20:	77 16                	ja     800a38 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a22:	0f be d2             	movsbl %dl,%edx
  800a25:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a28:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a2b:	7d 0b                	jge    800a38 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a2d:	83 c1 01             	add    $0x1,%ecx
  800a30:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a34:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a36:	eb b9                	jmp    8009f1 <strtol+0x76>

	if (endptr)
  800a38:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a3c:	74 0d                	je     800a4b <strtol+0xd0>
		*endptr = (char *) s;
  800a3e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a41:	89 0e                	mov    %ecx,(%esi)
  800a43:	eb 06                	jmp    800a4b <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a45:	85 db                	test   %ebx,%ebx
  800a47:	74 98                	je     8009e1 <strtol+0x66>
  800a49:	eb 9e                	jmp    8009e9 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a4b:	89 c2                	mov    %eax,%edx
  800a4d:	f7 da                	neg    %edx
  800a4f:	85 ff                	test   %edi,%edi
  800a51:	0f 45 c2             	cmovne %edx,%eax
}
  800a54:	5b                   	pop    %ebx
  800a55:	5e                   	pop    %esi
  800a56:	5f                   	pop    %edi
  800a57:	5d                   	pop    %ebp
  800a58:	c3                   	ret    

00800a59 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a59:	55                   	push   %ebp
  800a5a:	89 e5                	mov    %esp,%ebp
  800a5c:	57                   	push   %edi
  800a5d:	56                   	push   %esi
  800a5e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a5f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a67:	8b 55 08             	mov    0x8(%ebp),%edx
  800a6a:	89 c3                	mov    %eax,%ebx
  800a6c:	89 c7                	mov    %eax,%edi
  800a6e:	89 c6                	mov    %eax,%esi
  800a70:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a72:	5b                   	pop    %ebx
  800a73:	5e                   	pop    %esi
  800a74:	5f                   	pop    %edi
  800a75:	5d                   	pop    %ebp
  800a76:	c3                   	ret    

00800a77 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a77:	55                   	push   %ebp
  800a78:	89 e5                	mov    %esp,%ebp
  800a7a:	57                   	push   %edi
  800a7b:	56                   	push   %esi
  800a7c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a7d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a82:	b8 01 00 00 00       	mov    $0x1,%eax
  800a87:	89 d1                	mov    %edx,%ecx
  800a89:	89 d3                	mov    %edx,%ebx
  800a8b:	89 d7                	mov    %edx,%edi
  800a8d:	89 d6                	mov    %edx,%esi
  800a8f:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a91:	5b                   	pop    %ebx
  800a92:	5e                   	pop    %esi
  800a93:	5f                   	pop    %edi
  800a94:	5d                   	pop    %ebp
  800a95:	c3                   	ret    

00800a96 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a96:	55                   	push   %ebp
  800a97:	89 e5                	mov    %esp,%ebp
  800a99:	57                   	push   %edi
  800a9a:	56                   	push   %esi
  800a9b:	53                   	push   %ebx
  800a9c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a9f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aa4:	b8 03 00 00 00       	mov    $0x3,%eax
  800aa9:	8b 55 08             	mov    0x8(%ebp),%edx
  800aac:	89 cb                	mov    %ecx,%ebx
  800aae:	89 cf                	mov    %ecx,%edi
  800ab0:	89 ce                	mov    %ecx,%esi
  800ab2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ab4:	85 c0                	test   %eax,%eax
  800ab6:	7e 17                	jle    800acf <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ab8:	83 ec 0c             	sub    $0xc,%esp
  800abb:	50                   	push   %eax
  800abc:	6a 03                	push   $0x3
  800abe:	68 3f 26 80 00       	push   $0x80263f
  800ac3:	6a 23                	push   $0x23
  800ac5:	68 5c 26 80 00       	push   $0x80265c
  800aca:	e8 d0 13 00 00       	call   801e9f <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800acf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ad2:	5b                   	pop    %ebx
  800ad3:	5e                   	pop    %esi
  800ad4:	5f                   	pop    %edi
  800ad5:	5d                   	pop    %ebp
  800ad6:	c3                   	ret    

00800ad7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ad7:	55                   	push   %ebp
  800ad8:	89 e5                	mov    %esp,%ebp
  800ada:	57                   	push   %edi
  800adb:	56                   	push   %esi
  800adc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800add:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae2:	b8 02 00 00 00       	mov    $0x2,%eax
  800ae7:	89 d1                	mov    %edx,%ecx
  800ae9:	89 d3                	mov    %edx,%ebx
  800aeb:	89 d7                	mov    %edx,%edi
  800aed:	89 d6                	mov    %edx,%esi
  800aef:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800af1:	5b                   	pop    %ebx
  800af2:	5e                   	pop    %esi
  800af3:	5f                   	pop    %edi
  800af4:	5d                   	pop    %ebp
  800af5:	c3                   	ret    

00800af6 <sys_yield>:

void
sys_yield(void)
{
  800af6:	55                   	push   %ebp
  800af7:	89 e5                	mov    %esp,%ebp
  800af9:	57                   	push   %edi
  800afa:	56                   	push   %esi
  800afb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800afc:	ba 00 00 00 00       	mov    $0x0,%edx
  800b01:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b06:	89 d1                	mov    %edx,%ecx
  800b08:	89 d3                	mov    %edx,%ebx
  800b0a:	89 d7                	mov    %edx,%edi
  800b0c:	89 d6                	mov    %edx,%esi
  800b0e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b10:	5b                   	pop    %ebx
  800b11:	5e                   	pop    %esi
  800b12:	5f                   	pop    %edi
  800b13:	5d                   	pop    %ebp
  800b14:	c3                   	ret    

00800b15 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b15:	55                   	push   %ebp
  800b16:	89 e5                	mov    %esp,%ebp
  800b18:	57                   	push   %edi
  800b19:	56                   	push   %esi
  800b1a:	53                   	push   %ebx
  800b1b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b1e:	be 00 00 00 00       	mov    $0x0,%esi
  800b23:	b8 04 00 00 00       	mov    $0x4,%eax
  800b28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b2e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b31:	89 f7                	mov    %esi,%edi
  800b33:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b35:	85 c0                	test   %eax,%eax
  800b37:	7e 17                	jle    800b50 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b39:	83 ec 0c             	sub    $0xc,%esp
  800b3c:	50                   	push   %eax
  800b3d:	6a 04                	push   $0x4
  800b3f:	68 3f 26 80 00       	push   $0x80263f
  800b44:	6a 23                	push   $0x23
  800b46:	68 5c 26 80 00       	push   $0x80265c
  800b4b:	e8 4f 13 00 00       	call   801e9f <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b50:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b53:	5b                   	pop    %ebx
  800b54:	5e                   	pop    %esi
  800b55:	5f                   	pop    %edi
  800b56:	5d                   	pop    %ebp
  800b57:	c3                   	ret    

00800b58 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b58:	55                   	push   %ebp
  800b59:	89 e5                	mov    %esp,%ebp
  800b5b:	57                   	push   %edi
  800b5c:	56                   	push   %esi
  800b5d:	53                   	push   %ebx
  800b5e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b61:	b8 05 00 00 00       	mov    $0x5,%eax
  800b66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b69:	8b 55 08             	mov    0x8(%ebp),%edx
  800b6c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b6f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b72:	8b 75 18             	mov    0x18(%ebp),%esi
  800b75:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b77:	85 c0                	test   %eax,%eax
  800b79:	7e 17                	jle    800b92 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b7b:	83 ec 0c             	sub    $0xc,%esp
  800b7e:	50                   	push   %eax
  800b7f:	6a 05                	push   $0x5
  800b81:	68 3f 26 80 00       	push   $0x80263f
  800b86:	6a 23                	push   $0x23
  800b88:	68 5c 26 80 00       	push   $0x80265c
  800b8d:	e8 0d 13 00 00       	call   801e9f <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b92:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b95:	5b                   	pop    %ebx
  800b96:	5e                   	pop    %esi
  800b97:	5f                   	pop    %edi
  800b98:	5d                   	pop    %ebp
  800b99:	c3                   	ret    

00800b9a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b9a:	55                   	push   %ebp
  800b9b:	89 e5                	mov    %esp,%ebp
  800b9d:	57                   	push   %edi
  800b9e:	56                   	push   %esi
  800b9f:	53                   	push   %ebx
  800ba0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ba8:	b8 06 00 00 00       	mov    $0x6,%eax
  800bad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb3:	89 df                	mov    %ebx,%edi
  800bb5:	89 de                	mov    %ebx,%esi
  800bb7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bb9:	85 c0                	test   %eax,%eax
  800bbb:	7e 17                	jle    800bd4 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bbd:	83 ec 0c             	sub    $0xc,%esp
  800bc0:	50                   	push   %eax
  800bc1:	6a 06                	push   $0x6
  800bc3:	68 3f 26 80 00       	push   $0x80263f
  800bc8:	6a 23                	push   $0x23
  800bca:	68 5c 26 80 00       	push   $0x80265c
  800bcf:	e8 cb 12 00 00       	call   801e9f <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bd4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd7:	5b                   	pop    %ebx
  800bd8:	5e                   	pop    %esi
  800bd9:	5f                   	pop    %edi
  800bda:	5d                   	pop    %ebp
  800bdb:	c3                   	ret    

00800bdc <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bdc:	55                   	push   %ebp
  800bdd:	89 e5                	mov    %esp,%ebp
  800bdf:	57                   	push   %edi
  800be0:	56                   	push   %esi
  800be1:	53                   	push   %ebx
  800be2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bea:	b8 08 00 00 00       	mov    $0x8,%eax
  800bef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf5:	89 df                	mov    %ebx,%edi
  800bf7:	89 de                	mov    %ebx,%esi
  800bf9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bfb:	85 c0                	test   %eax,%eax
  800bfd:	7e 17                	jle    800c16 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bff:	83 ec 0c             	sub    $0xc,%esp
  800c02:	50                   	push   %eax
  800c03:	6a 08                	push   $0x8
  800c05:	68 3f 26 80 00       	push   $0x80263f
  800c0a:	6a 23                	push   $0x23
  800c0c:	68 5c 26 80 00       	push   $0x80265c
  800c11:	e8 89 12 00 00       	call   801e9f <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c19:	5b                   	pop    %ebx
  800c1a:	5e                   	pop    %esi
  800c1b:	5f                   	pop    %edi
  800c1c:	5d                   	pop    %ebp
  800c1d:	c3                   	ret    

00800c1e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c1e:	55                   	push   %ebp
  800c1f:	89 e5                	mov    %esp,%ebp
  800c21:	57                   	push   %edi
  800c22:	56                   	push   %esi
  800c23:	53                   	push   %ebx
  800c24:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c27:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c2c:	b8 09 00 00 00       	mov    $0x9,%eax
  800c31:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c34:	8b 55 08             	mov    0x8(%ebp),%edx
  800c37:	89 df                	mov    %ebx,%edi
  800c39:	89 de                	mov    %ebx,%esi
  800c3b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c3d:	85 c0                	test   %eax,%eax
  800c3f:	7e 17                	jle    800c58 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c41:	83 ec 0c             	sub    $0xc,%esp
  800c44:	50                   	push   %eax
  800c45:	6a 09                	push   $0x9
  800c47:	68 3f 26 80 00       	push   $0x80263f
  800c4c:	6a 23                	push   $0x23
  800c4e:	68 5c 26 80 00       	push   $0x80265c
  800c53:	e8 47 12 00 00       	call   801e9f <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5b:	5b                   	pop    %ebx
  800c5c:	5e                   	pop    %esi
  800c5d:	5f                   	pop    %edi
  800c5e:	5d                   	pop    %ebp
  800c5f:	c3                   	ret    

00800c60 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c60:	55                   	push   %ebp
  800c61:	89 e5                	mov    %esp,%ebp
  800c63:	57                   	push   %edi
  800c64:	56                   	push   %esi
  800c65:	53                   	push   %ebx
  800c66:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c69:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c6e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c76:	8b 55 08             	mov    0x8(%ebp),%edx
  800c79:	89 df                	mov    %ebx,%edi
  800c7b:	89 de                	mov    %ebx,%esi
  800c7d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c7f:	85 c0                	test   %eax,%eax
  800c81:	7e 17                	jle    800c9a <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c83:	83 ec 0c             	sub    $0xc,%esp
  800c86:	50                   	push   %eax
  800c87:	6a 0a                	push   $0xa
  800c89:	68 3f 26 80 00       	push   $0x80263f
  800c8e:	6a 23                	push   $0x23
  800c90:	68 5c 26 80 00       	push   $0x80265c
  800c95:	e8 05 12 00 00       	call   801e9f <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9d:	5b                   	pop    %ebx
  800c9e:	5e                   	pop    %esi
  800c9f:	5f                   	pop    %edi
  800ca0:	5d                   	pop    %ebp
  800ca1:	c3                   	ret    

00800ca2 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ca2:	55                   	push   %ebp
  800ca3:	89 e5                	mov    %esp,%ebp
  800ca5:	57                   	push   %edi
  800ca6:	56                   	push   %esi
  800ca7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca8:	be 00 00 00 00       	mov    $0x0,%esi
  800cad:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cb2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cbb:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cbe:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cc0:	5b                   	pop    %ebx
  800cc1:	5e                   	pop    %esi
  800cc2:	5f                   	pop    %edi
  800cc3:	5d                   	pop    %ebp
  800cc4:	c3                   	ret    

00800cc5 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cc5:	55                   	push   %ebp
  800cc6:	89 e5                	mov    %esp,%ebp
  800cc8:	57                   	push   %edi
  800cc9:	56                   	push   %esi
  800cca:	53                   	push   %ebx
  800ccb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cce:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cd3:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdb:	89 cb                	mov    %ecx,%ebx
  800cdd:	89 cf                	mov    %ecx,%edi
  800cdf:	89 ce                	mov    %ecx,%esi
  800ce1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ce3:	85 c0                	test   %eax,%eax
  800ce5:	7e 17                	jle    800cfe <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce7:	83 ec 0c             	sub    $0xc,%esp
  800cea:	50                   	push   %eax
  800ceb:	6a 0d                	push   $0xd
  800ced:	68 3f 26 80 00       	push   $0x80263f
  800cf2:	6a 23                	push   $0x23
  800cf4:	68 5c 26 80 00       	push   $0x80265c
  800cf9:	e8 a1 11 00 00       	call   801e9f <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d01:	5b                   	pop    %ebx
  800d02:	5e                   	pop    %esi
  800d03:	5f                   	pop    %edi
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    

00800d06 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
  800d09:	57                   	push   %edi
  800d0a:	56                   	push   %esi
  800d0b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0c:	ba 00 00 00 00       	mov    $0x0,%edx
  800d11:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d16:	89 d1                	mov    %edx,%ecx
  800d18:	89 d3                	mov    %edx,%ebx
  800d1a:	89 d7                	mov    %edx,%edi
  800d1c:	89 d6                	mov    %edx,%esi
  800d1e:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d20:	5b                   	pop    %ebx
  800d21:	5e                   	pop    %esi
  800d22:	5f                   	pop    %edi
  800d23:	5d                   	pop    %ebp
  800d24:	c3                   	ret    

00800d25 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d25:	55                   	push   %ebp
  800d26:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d28:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2b:	05 00 00 00 30       	add    $0x30000000,%eax
  800d30:	c1 e8 0c             	shr    $0xc,%eax
}
  800d33:	5d                   	pop    %ebp
  800d34:	c3                   	ret    

00800d35 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d35:	55                   	push   %ebp
  800d36:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d38:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3b:	05 00 00 00 30       	add    $0x30000000,%eax
  800d40:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d45:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d4a:	5d                   	pop    %ebp
  800d4b:	c3                   	ret    

00800d4c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d4c:	55                   	push   %ebp
  800d4d:	89 e5                	mov    %esp,%ebp
  800d4f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d52:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d57:	89 c2                	mov    %eax,%edx
  800d59:	c1 ea 16             	shr    $0x16,%edx
  800d5c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d63:	f6 c2 01             	test   $0x1,%dl
  800d66:	74 11                	je     800d79 <fd_alloc+0x2d>
  800d68:	89 c2                	mov    %eax,%edx
  800d6a:	c1 ea 0c             	shr    $0xc,%edx
  800d6d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d74:	f6 c2 01             	test   $0x1,%dl
  800d77:	75 09                	jne    800d82 <fd_alloc+0x36>
			*fd_store = fd;
  800d79:	89 01                	mov    %eax,(%ecx)
			return 0;
  800d7b:	b8 00 00 00 00       	mov    $0x0,%eax
  800d80:	eb 17                	jmp    800d99 <fd_alloc+0x4d>
  800d82:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800d87:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800d8c:	75 c9                	jne    800d57 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800d8e:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800d94:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800d99:	5d                   	pop    %ebp
  800d9a:	c3                   	ret    

00800d9b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800d9b:	55                   	push   %ebp
  800d9c:	89 e5                	mov    %esp,%ebp
  800d9e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800da1:	83 f8 1f             	cmp    $0x1f,%eax
  800da4:	77 36                	ja     800ddc <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800da6:	c1 e0 0c             	shl    $0xc,%eax
  800da9:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800dae:	89 c2                	mov    %eax,%edx
  800db0:	c1 ea 16             	shr    $0x16,%edx
  800db3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800dba:	f6 c2 01             	test   $0x1,%dl
  800dbd:	74 24                	je     800de3 <fd_lookup+0x48>
  800dbf:	89 c2                	mov    %eax,%edx
  800dc1:	c1 ea 0c             	shr    $0xc,%edx
  800dc4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dcb:	f6 c2 01             	test   $0x1,%dl
  800dce:	74 1a                	je     800dea <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800dd0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dd3:	89 02                	mov    %eax,(%edx)
	return 0;
  800dd5:	b8 00 00 00 00       	mov    $0x0,%eax
  800dda:	eb 13                	jmp    800def <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ddc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800de1:	eb 0c                	jmp    800def <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800de3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800de8:	eb 05                	jmp    800def <fd_lookup+0x54>
  800dea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800def:	5d                   	pop    %ebp
  800df0:	c3                   	ret    

00800df1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800df1:	55                   	push   %ebp
  800df2:	89 e5                	mov    %esp,%ebp
  800df4:	83 ec 08             	sub    $0x8,%esp
  800df7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dfa:	ba e8 26 80 00       	mov    $0x8026e8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800dff:	eb 13                	jmp    800e14 <dev_lookup+0x23>
  800e01:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800e04:	39 08                	cmp    %ecx,(%eax)
  800e06:	75 0c                	jne    800e14 <dev_lookup+0x23>
			*dev = devtab[i];
  800e08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e0b:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e0d:	b8 00 00 00 00       	mov    $0x0,%eax
  800e12:	eb 2e                	jmp    800e42 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e14:	8b 02                	mov    (%edx),%eax
  800e16:	85 c0                	test   %eax,%eax
  800e18:	75 e7                	jne    800e01 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e1a:	a1 08 40 80 00       	mov    0x804008,%eax
  800e1f:	8b 40 48             	mov    0x48(%eax),%eax
  800e22:	83 ec 04             	sub    $0x4,%esp
  800e25:	51                   	push   %ecx
  800e26:	50                   	push   %eax
  800e27:	68 6c 26 80 00       	push   $0x80266c
  800e2c:	e8 5c f3 ff ff       	call   80018d <cprintf>
	*dev = 0;
  800e31:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e34:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e3a:	83 c4 10             	add    $0x10,%esp
  800e3d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e42:	c9                   	leave  
  800e43:	c3                   	ret    

00800e44 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e44:	55                   	push   %ebp
  800e45:	89 e5                	mov    %esp,%ebp
  800e47:	56                   	push   %esi
  800e48:	53                   	push   %ebx
  800e49:	83 ec 10             	sub    $0x10,%esp
  800e4c:	8b 75 08             	mov    0x8(%ebp),%esi
  800e4f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e52:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e55:	50                   	push   %eax
  800e56:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e5c:	c1 e8 0c             	shr    $0xc,%eax
  800e5f:	50                   	push   %eax
  800e60:	e8 36 ff ff ff       	call   800d9b <fd_lookup>
  800e65:	83 c4 08             	add    $0x8,%esp
  800e68:	85 c0                	test   %eax,%eax
  800e6a:	78 05                	js     800e71 <fd_close+0x2d>
	    || fd != fd2)
  800e6c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800e6f:	74 0c                	je     800e7d <fd_close+0x39>
		return (must_exist ? r : 0);
  800e71:	84 db                	test   %bl,%bl
  800e73:	ba 00 00 00 00       	mov    $0x0,%edx
  800e78:	0f 44 c2             	cmove  %edx,%eax
  800e7b:	eb 41                	jmp    800ebe <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800e7d:	83 ec 08             	sub    $0x8,%esp
  800e80:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e83:	50                   	push   %eax
  800e84:	ff 36                	pushl  (%esi)
  800e86:	e8 66 ff ff ff       	call   800df1 <dev_lookup>
  800e8b:	89 c3                	mov    %eax,%ebx
  800e8d:	83 c4 10             	add    $0x10,%esp
  800e90:	85 c0                	test   %eax,%eax
  800e92:	78 1a                	js     800eae <fd_close+0x6a>
		if (dev->dev_close)
  800e94:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e97:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800e9a:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800e9f:	85 c0                	test   %eax,%eax
  800ea1:	74 0b                	je     800eae <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800ea3:	83 ec 0c             	sub    $0xc,%esp
  800ea6:	56                   	push   %esi
  800ea7:	ff d0                	call   *%eax
  800ea9:	89 c3                	mov    %eax,%ebx
  800eab:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800eae:	83 ec 08             	sub    $0x8,%esp
  800eb1:	56                   	push   %esi
  800eb2:	6a 00                	push   $0x0
  800eb4:	e8 e1 fc ff ff       	call   800b9a <sys_page_unmap>
	return r;
  800eb9:	83 c4 10             	add    $0x10,%esp
  800ebc:	89 d8                	mov    %ebx,%eax
}
  800ebe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ec1:	5b                   	pop    %ebx
  800ec2:	5e                   	pop    %esi
  800ec3:	5d                   	pop    %ebp
  800ec4:	c3                   	ret    

00800ec5 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800ec5:	55                   	push   %ebp
  800ec6:	89 e5                	mov    %esp,%ebp
  800ec8:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ecb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ece:	50                   	push   %eax
  800ecf:	ff 75 08             	pushl  0x8(%ebp)
  800ed2:	e8 c4 fe ff ff       	call   800d9b <fd_lookup>
  800ed7:	83 c4 08             	add    $0x8,%esp
  800eda:	85 c0                	test   %eax,%eax
  800edc:	78 10                	js     800eee <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800ede:	83 ec 08             	sub    $0x8,%esp
  800ee1:	6a 01                	push   $0x1
  800ee3:	ff 75 f4             	pushl  -0xc(%ebp)
  800ee6:	e8 59 ff ff ff       	call   800e44 <fd_close>
  800eeb:	83 c4 10             	add    $0x10,%esp
}
  800eee:	c9                   	leave  
  800eef:	c3                   	ret    

00800ef0 <close_all>:

void
close_all(void)
{
  800ef0:	55                   	push   %ebp
  800ef1:	89 e5                	mov    %esp,%ebp
  800ef3:	53                   	push   %ebx
  800ef4:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800ef7:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800efc:	83 ec 0c             	sub    $0xc,%esp
  800eff:	53                   	push   %ebx
  800f00:	e8 c0 ff ff ff       	call   800ec5 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f05:	83 c3 01             	add    $0x1,%ebx
  800f08:	83 c4 10             	add    $0x10,%esp
  800f0b:	83 fb 20             	cmp    $0x20,%ebx
  800f0e:	75 ec                	jne    800efc <close_all+0xc>
		close(i);
}
  800f10:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f13:	c9                   	leave  
  800f14:	c3                   	ret    

00800f15 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f15:	55                   	push   %ebp
  800f16:	89 e5                	mov    %esp,%ebp
  800f18:	57                   	push   %edi
  800f19:	56                   	push   %esi
  800f1a:	53                   	push   %ebx
  800f1b:	83 ec 2c             	sub    $0x2c,%esp
  800f1e:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f21:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f24:	50                   	push   %eax
  800f25:	ff 75 08             	pushl  0x8(%ebp)
  800f28:	e8 6e fe ff ff       	call   800d9b <fd_lookup>
  800f2d:	83 c4 08             	add    $0x8,%esp
  800f30:	85 c0                	test   %eax,%eax
  800f32:	0f 88 c1 00 00 00    	js     800ff9 <dup+0xe4>
		return r;
	close(newfdnum);
  800f38:	83 ec 0c             	sub    $0xc,%esp
  800f3b:	56                   	push   %esi
  800f3c:	e8 84 ff ff ff       	call   800ec5 <close>

	newfd = INDEX2FD(newfdnum);
  800f41:	89 f3                	mov    %esi,%ebx
  800f43:	c1 e3 0c             	shl    $0xc,%ebx
  800f46:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800f4c:	83 c4 04             	add    $0x4,%esp
  800f4f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f52:	e8 de fd ff ff       	call   800d35 <fd2data>
  800f57:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800f59:	89 1c 24             	mov    %ebx,(%esp)
  800f5c:	e8 d4 fd ff ff       	call   800d35 <fd2data>
  800f61:	83 c4 10             	add    $0x10,%esp
  800f64:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f67:	89 f8                	mov    %edi,%eax
  800f69:	c1 e8 16             	shr    $0x16,%eax
  800f6c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f73:	a8 01                	test   $0x1,%al
  800f75:	74 37                	je     800fae <dup+0x99>
  800f77:	89 f8                	mov    %edi,%eax
  800f79:	c1 e8 0c             	shr    $0xc,%eax
  800f7c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f83:	f6 c2 01             	test   $0x1,%dl
  800f86:	74 26                	je     800fae <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800f88:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f8f:	83 ec 0c             	sub    $0xc,%esp
  800f92:	25 07 0e 00 00       	and    $0xe07,%eax
  800f97:	50                   	push   %eax
  800f98:	ff 75 d4             	pushl  -0x2c(%ebp)
  800f9b:	6a 00                	push   $0x0
  800f9d:	57                   	push   %edi
  800f9e:	6a 00                	push   $0x0
  800fa0:	e8 b3 fb ff ff       	call   800b58 <sys_page_map>
  800fa5:	89 c7                	mov    %eax,%edi
  800fa7:	83 c4 20             	add    $0x20,%esp
  800faa:	85 c0                	test   %eax,%eax
  800fac:	78 2e                	js     800fdc <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fae:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800fb1:	89 d0                	mov    %edx,%eax
  800fb3:	c1 e8 0c             	shr    $0xc,%eax
  800fb6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fbd:	83 ec 0c             	sub    $0xc,%esp
  800fc0:	25 07 0e 00 00       	and    $0xe07,%eax
  800fc5:	50                   	push   %eax
  800fc6:	53                   	push   %ebx
  800fc7:	6a 00                	push   $0x0
  800fc9:	52                   	push   %edx
  800fca:	6a 00                	push   $0x0
  800fcc:	e8 87 fb ff ff       	call   800b58 <sys_page_map>
  800fd1:	89 c7                	mov    %eax,%edi
  800fd3:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800fd6:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fd8:	85 ff                	test   %edi,%edi
  800fda:	79 1d                	jns    800ff9 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800fdc:	83 ec 08             	sub    $0x8,%esp
  800fdf:	53                   	push   %ebx
  800fe0:	6a 00                	push   $0x0
  800fe2:	e8 b3 fb ff ff       	call   800b9a <sys_page_unmap>
	sys_page_unmap(0, nva);
  800fe7:	83 c4 08             	add    $0x8,%esp
  800fea:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fed:	6a 00                	push   $0x0
  800fef:	e8 a6 fb ff ff       	call   800b9a <sys_page_unmap>
	return r;
  800ff4:	83 c4 10             	add    $0x10,%esp
  800ff7:	89 f8                	mov    %edi,%eax
}
  800ff9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ffc:	5b                   	pop    %ebx
  800ffd:	5e                   	pop    %esi
  800ffe:	5f                   	pop    %edi
  800fff:	5d                   	pop    %ebp
  801000:	c3                   	ret    

00801001 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801001:	55                   	push   %ebp
  801002:	89 e5                	mov    %esp,%ebp
  801004:	53                   	push   %ebx
  801005:	83 ec 14             	sub    $0x14,%esp
  801008:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80100b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80100e:	50                   	push   %eax
  80100f:	53                   	push   %ebx
  801010:	e8 86 fd ff ff       	call   800d9b <fd_lookup>
  801015:	83 c4 08             	add    $0x8,%esp
  801018:	89 c2                	mov    %eax,%edx
  80101a:	85 c0                	test   %eax,%eax
  80101c:	78 6d                	js     80108b <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80101e:	83 ec 08             	sub    $0x8,%esp
  801021:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801024:	50                   	push   %eax
  801025:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801028:	ff 30                	pushl  (%eax)
  80102a:	e8 c2 fd ff ff       	call   800df1 <dev_lookup>
  80102f:	83 c4 10             	add    $0x10,%esp
  801032:	85 c0                	test   %eax,%eax
  801034:	78 4c                	js     801082 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801036:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801039:	8b 42 08             	mov    0x8(%edx),%eax
  80103c:	83 e0 03             	and    $0x3,%eax
  80103f:	83 f8 01             	cmp    $0x1,%eax
  801042:	75 21                	jne    801065 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801044:	a1 08 40 80 00       	mov    0x804008,%eax
  801049:	8b 40 48             	mov    0x48(%eax),%eax
  80104c:	83 ec 04             	sub    $0x4,%esp
  80104f:	53                   	push   %ebx
  801050:	50                   	push   %eax
  801051:	68 ad 26 80 00       	push   $0x8026ad
  801056:	e8 32 f1 ff ff       	call   80018d <cprintf>
		return -E_INVAL;
  80105b:	83 c4 10             	add    $0x10,%esp
  80105e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801063:	eb 26                	jmp    80108b <read+0x8a>
	}
	if (!dev->dev_read)
  801065:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801068:	8b 40 08             	mov    0x8(%eax),%eax
  80106b:	85 c0                	test   %eax,%eax
  80106d:	74 17                	je     801086 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80106f:	83 ec 04             	sub    $0x4,%esp
  801072:	ff 75 10             	pushl  0x10(%ebp)
  801075:	ff 75 0c             	pushl  0xc(%ebp)
  801078:	52                   	push   %edx
  801079:	ff d0                	call   *%eax
  80107b:	89 c2                	mov    %eax,%edx
  80107d:	83 c4 10             	add    $0x10,%esp
  801080:	eb 09                	jmp    80108b <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801082:	89 c2                	mov    %eax,%edx
  801084:	eb 05                	jmp    80108b <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801086:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80108b:	89 d0                	mov    %edx,%eax
  80108d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801090:	c9                   	leave  
  801091:	c3                   	ret    

00801092 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801092:	55                   	push   %ebp
  801093:	89 e5                	mov    %esp,%ebp
  801095:	57                   	push   %edi
  801096:	56                   	push   %esi
  801097:	53                   	push   %ebx
  801098:	83 ec 0c             	sub    $0xc,%esp
  80109b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80109e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010a1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010a6:	eb 21                	jmp    8010c9 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010a8:	83 ec 04             	sub    $0x4,%esp
  8010ab:	89 f0                	mov    %esi,%eax
  8010ad:	29 d8                	sub    %ebx,%eax
  8010af:	50                   	push   %eax
  8010b0:	89 d8                	mov    %ebx,%eax
  8010b2:	03 45 0c             	add    0xc(%ebp),%eax
  8010b5:	50                   	push   %eax
  8010b6:	57                   	push   %edi
  8010b7:	e8 45 ff ff ff       	call   801001 <read>
		if (m < 0)
  8010bc:	83 c4 10             	add    $0x10,%esp
  8010bf:	85 c0                	test   %eax,%eax
  8010c1:	78 10                	js     8010d3 <readn+0x41>
			return m;
		if (m == 0)
  8010c3:	85 c0                	test   %eax,%eax
  8010c5:	74 0a                	je     8010d1 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010c7:	01 c3                	add    %eax,%ebx
  8010c9:	39 f3                	cmp    %esi,%ebx
  8010cb:	72 db                	jb     8010a8 <readn+0x16>
  8010cd:	89 d8                	mov    %ebx,%eax
  8010cf:	eb 02                	jmp    8010d3 <readn+0x41>
  8010d1:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8010d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010d6:	5b                   	pop    %ebx
  8010d7:	5e                   	pop    %esi
  8010d8:	5f                   	pop    %edi
  8010d9:	5d                   	pop    %ebp
  8010da:	c3                   	ret    

008010db <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8010db:	55                   	push   %ebp
  8010dc:	89 e5                	mov    %esp,%ebp
  8010de:	53                   	push   %ebx
  8010df:	83 ec 14             	sub    $0x14,%esp
  8010e2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010e5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010e8:	50                   	push   %eax
  8010e9:	53                   	push   %ebx
  8010ea:	e8 ac fc ff ff       	call   800d9b <fd_lookup>
  8010ef:	83 c4 08             	add    $0x8,%esp
  8010f2:	89 c2                	mov    %eax,%edx
  8010f4:	85 c0                	test   %eax,%eax
  8010f6:	78 68                	js     801160 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010f8:	83 ec 08             	sub    $0x8,%esp
  8010fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010fe:	50                   	push   %eax
  8010ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801102:	ff 30                	pushl  (%eax)
  801104:	e8 e8 fc ff ff       	call   800df1 <dev_lookup>
  801109:	83 c4 10             	add    $0x10,%esp
  80110c:	85 c0                	test   %eax,%eax
  80110e:	78 47                	js     801157 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801110:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801113:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801117:	75 21                	jne    80113a <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801119:	a1 08 40 80 00       	mov    0x804008,%eax
  80111e:	8b 40 48             	mov    0x48(%eax),%eax
  801121:	83 ec 04             	sub    $0x4,%esp
  801124:	53                   	push   %ebx
  801125:	50                   	push   %eax
  801126:	68 c9 26 80 00       	push   $0x8026c9
  80112b:	e8 5d f0 ff ff       	call   80018d <cprintf>
		return -E_INVAL;
  801130:	83 c4 10             	add    $0x10,%esp
  801133:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801138:	eb 26                	jmp    801160 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80113a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80113d:	8b 52 0c             	mov    0xc(%edx),%edx
  801140:	85 d2                	test   %edx,%edx
  801142:	74 17                	je     80115b <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801144:	83 ec 04             	sub    $0x4,%esp
  801147:	ff 75 10             	pushl  0x10(%ebp)
  80114a:	ff 75 0c             	pushl  0xc(%ebp)
  80114d:	50                   	push   %eax
  80114e:	ff d2                	call   *%edx
  801150:	89 c2                	mov    %eax,%edx
  801152:	83 c4 10             	add    $0x10,%esp
  801155:	eb 09                	jmp    801160 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801157:	89 c2                	mov    %eax,%edx
  801159:	eb 05                	jmp    801160 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80115b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801160:	89 d0                	mov    %edx,%eax
  801162:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801165:	c9                   	leave  
  801166:	c3                   	ret    

00801167 <seek>:

int
seek(int fdnum, off_t offset)
{
  801167:	55                   	push   %ebp
  801168:	89 e5                	mov    %esp,%ebp
  80116a:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80116d:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801170:	50                   	push   %eax
  801171:	ff 75 08             	pushl  0x8(%ebp)
  801174:	e8 22 fc ff ff       	call   800d9b <fd_lookup>
  801179:	83 c4 08             	add    $0x8,%esp
  80117c:	85 c0                	test   %eax,%eax
  80117e:	78 0e                	js     80118e <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801180:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801183:	8b 55 0c             	mov    0xc(%ebp),%edx
  801186:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801189:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80118e:	c9                   	leave  
  80118f:	c3                   	ret    

00801190 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801190:	55                   	push   %ebp
  801191:	89 e5                	mov    %esp,%ebp
  801193:	53                   	push   %ebx
  801194:	83 ec 14             	sub    $0x14,%esp
  801197:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80119a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80119d:	50                   	push   %eax
  80119e:	53                   	push   %ebx
  80119f:	e8 f7 fb ff ff       	call   800d9b <fd_lookup>
  8011a4:	83 c4 08             	add    $0x8,%esp
  8011a7:	89 c2                	mov    %eax,%edx
  8011a9:	85 c0                	test   %eax,%eax
  8011ab:	78 65                	js     801212 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011ad:	83 ec 08             	sub    $0x8,%esp
  8011b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011b3:	50                   	push   %eax
  8011b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011b7:	ff 30                	pushl  (%eax)
  8011b9:	e8 33 fc ff ff       	call   800df1 <dev_lookup>
  8011be:	83 c4 10             	add    $0x10,%esp
  8011c1:	85 c0                	test   %eax,%eax
  8011c3:	78 44                	js     801209 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011c8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011cc:	75 21                	jne    8011ef <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8011ce:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8011d3:	8b 40 48             	mov    0x48(%eax),%eax
  8011d6:	83 ec 04             	sub    $0x4,%esp
  8011d9:	53                   	push   %ebx
  8011da:	50                   	push   %eax
  8011db:	68 8c 26 80 00       	push   $0x80268c
  8011e0:	e8 a8 ef ff ff       	call   80018d <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8011e5:	83 c4 10             	add    $0x10,%esp
  8011e8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011ed:	eb 23                	jmp    801212 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8011ef:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011f2:	8b 52 18             	mov    0x18(%edx),%edx
  8011f5:	85 d2                	test   %edx,%edx
  8011f7:	74 14                	je     80120d <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8011f9:	83 ec 08             	sub    $0x8,%esp
  8011fc:	ff 75 0c             	pushl  0xc(%ebp)
  8011ff:	50                   	push   %eax
  801200:	ff d2                	call   *%edx
  801202:	89 c2                	mov    %eax,%edx
  801204:	83 c4 10             	add    $0x10,%esp
  801207:	eb 09                	jmp    801212 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801209:	89 c2                	mov    %eax,%edx
  80120b:	eb 05                	jmp    801212 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80120d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801212:	89 d0                	mov    %edx,%eax
  801214:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801217:	c9                   	leave  
  801218:	c3                   	ret    

00801219 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801219:	55                   	push   %ebp
  80121a:	89 e5                	mov    %esp,%ebp
  80121c:	53                   	push   %ebx
  80121d:	83 ec 14             	sub    $0x14,%esp
  801220:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801223:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801226:	50                   	push   %eax
  801227:	ff 75 08             	pushl  0x8(%ebp)
  80122a:	e8 6c fb ff ff       	call   800d9b <fd_lookup>
  80122f:	83 c4 08             	add    $0x8,%esp
  801232:	89 c2                	mov    %eax,%edx
  801234:	85 c0                	test   %eax,%eax
  801236:	78 58                	js     801290 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801238:	83 ec 08             	sub    $0x8,%esp
  80123b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80123e:	50                   	push   %eax
  80123f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801242:	ff 30                	pushl  (%eax)
  801244:	e8 a8 fb ff ff       	call   800df1 <dev_lookup>
  801249:	83 c4 10             	add    $0x10,%esp
  80124c:	85 c0                	test   %eax,%eax
  80124e:	78 37                	js     801287 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801250:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801253:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801257:	74 32                	je     80128b <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801259:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80125c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801263:	00 00 00 
	stat->st_isdir = 0;
  801266:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80126d:	00 00 00 
	stat->st_dev = dev;
  801270:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801276:	83 ec 08             	sub    $0x8,%esp
  801279:	53                   	push   %ebx
  80127a:	ff 75 f0             	pushl  -0x10(%ebp)
  80127d:	ff 50 14             	call   *0x14(%eax)
  801280:	89 c2                	mov    %eax,%edx
  801282:	83 c4 10             	add    $0x10,%esp
  801285:	eb 09                	jmp    801290 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801287:	89 c2                	mov    %eax,%edx
  801289:	eb 05                	jmp    801290 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80128b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801290:	89 d0                	mov    %edx,%eax
  801292:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801295:	c9                   	leave  
  801296:	c3                   	ret    

00801297 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801297:	55                   	push   %ebp
  801298:	89 e5                	mov    %esp,%ebp
  80129a:	56                   	push   %esi
  80129b:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80129c:	83 ec 08             	sub    $0x8,%esp
  80129f:	6a 00                	push   $0x0
  8012a1:	ff 75 08             	pushl  0x8(%ebp)
  8012a4:	e8 0c 02 00 00       	call   8014b5 <open>
  8012a9:	89 c3                	mov    %eax,%ebx
  8012ab:	83 c4 10             	add    $0x10,%esp
  8012ae:	85 c0                	test   %eax,%eax
  8012b0:	78 1b                	js     8012cd <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8012b2:	83 ec 08             	sub    $0x8,%esp
  8012b5:	ff 75 0c             	pushl  0xc(%ebp)
  8012b8:	50                   	push   %eax
  8012b9:	e8 5b ff ff ff       	call   801219 <fstat>
  8012be:	89 c6                	mov    %eax,%esi
	close(fd);
  8012c0:	89 1c 24             	mov    %ebx,(%esp)
  8012c3:	e8 fd fb ff ff       	call   800ec5 <close>
	return r;
  8012c8:	83 c4 10             	add    $0x10,%esp
  8012cb:	89 f0                	mov    %esi,%eax
}
  8012cd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012d0:	5b                   	pop    %ebx
  8012d1:	5e                   	pop    %esi
  8012d2:	5d                   	pop    %ebp
  8012d3:	c3                   	ret    

008012d4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8012d4:	55                   	push   %ebp
  8012d5:	89 e5                	mov    %esp,%ebp
  8012d7:	56                   	push   %esi
  8012d8:	53                   	push   %ebx
  8012d9:	89 c6                	mov    %eax,%esi
  8012db:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8012dd:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8012e4:	75 12                	jne    8012f8 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8012e6:	83 ec 0c             	sub    $0xc,%esp
  8012e9:	6a 01                	push   $0x1
  8012eb:	e8 b2 0c 00 00       	call   801fa2 <ipc_find_env>
  8012f0:	a3 00 40 80 00       	mov    %eax,0x804000
  8012f5:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8012f8:	6a 07                	push   $0x7
  8012fa:	68 00 50 80 00       	push   $0x805000
  8012ff:	56                   	push   %esi
  801300:	ff 35 00 40 80 00    	pushl  0x804000
  801306:	e8 43 0c 00 00       	call   801f4e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80130b:	83 c4 0c             	add    $0xc,%esp
  80130e:	6a 00                	push   $0x0
  801310:	53                   	push   %ebx
  801311:	6a 00                	push   $0x0
  801313:	e8 cd 0b 00 00       	call   801ee5 <ipc_recv>
}
  801318:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80131b:	5b                   	pop    %ebx
  80131c:	5e                   	pop    %esi
  80131d:	5d                   	pop    %ebp
  80131e:	c3                   	ret    

0080131f <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80131f:	55                   	push   %ebp
  801320:	89 e5                	mov    %esp,%ebp
  801322:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801325:	8b 45 08             	mov    0x8(%ebp),%eax
  801328:	8b 40 0c             	mov    0xc(%eax),%eax
  80132b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801330:	8b 45 0c             	mov    0xc(%ebp),%eax
  801333:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801338:	ba 00 00 00 00       	mov    $0x0,%edx
  80133d:	b8 02 00 00 00       	mov    $0x2,%eax
  801342:	e8 8d ff ff ff       	call   8012d4 <fsipc>
}
  801347:	c9                   	leave  
  801348:	c3                   	ret    

00801349 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801349:	55                   	push   %ebp
  80134a:	89 e5                	mov    %esp,%ebp
  80134c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80134f:	8b 45 08             	mov    0x8(%ebp),%eax
  801352:	8b 40 0c             	mov    0xc(%eax),%eax
  801355:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80135a:	ba 00 00 00 00       	mov    $0x0,%edx
  80135f:	b8 06 00 00 00       	mov    $0x6,%eax
  801364:	e8 6b ff ff ff       	call   8012d4 <fsipc>
}
  801369:	c9                   	leave  
  80136a:	c3                   	ret    

0080136b <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80136b:	55                   	push   %ebp
  80136c:	89 e5                	mov    %esp,%ebp
  80136e:	53                   	push   %ebx
  80136f:	83 ec 04             	sub    $0x4,%esp
  801372:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801375:	8b 45 08             	mov    0x8(%ebp),%eax
  801378:	8b 40 0c             	mov    0xc(%eax),%eax
  80137b:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801380:	ba 00 00 00 00       	mov    $0x0,%edx
  801385:	b8 05 00 00 00       	mov    $0x5,%eax
  80138a:	e8 45 ff ff ff       	call   8012d4 <fsipc>
  80138f:	85 c0                	test   %eax,%eax
  801391:	78 2c                	js     8013bf <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801393:	83 ec 08             	sub    $0x8,%esp
  801396:	68 00 50 80 00       	push   $0x805000
  80139b:	53                   	push   %ebx
  80139c:	e8 71 f3 ff ff       	call   800712 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8013a1:	a1 80 50 80 00       	mov    0x805080,%eax
  8013a6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8013ac:	a1 84 50 80 00       	mov    0x805084,%eax
  8013b1:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8013b7:	83 c4 10             	add    $0x10,%esp
  8013ba:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013c2:	c9                   	leave  
  8013c3:	c3                   	ret    

008013c4 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8013c4:	55                   	push   %ebp
  8013c5:	89 e5                	mov    %esp,%ebp
  8013c7:	53                   	push   %ebx
  8013c8:	83 ec 08             	sub    $0x8,%esp
  8013cb:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8013ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8013d1:	8b 52 0c             	mov    0xc(%edx),%edx
  8013d4:	89 15 00 50 80 00    	mov    %edx,0x805000
  8013da:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8013df:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  8013e4:	0f 46 d8             	cmovbe %eax,%ebx
	
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  8013e7:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  8013ed:	53                   	push   %ebx
  8013ee:	ff 75 0c             	pushl  0xc(%ebp)
  8013f1:	68 08 50 80 00       	push   $0x805008
  8013f6:	e8 a9 f4 ff ff       	call   8008a4 <memmove>

	
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) 
  8013fb:	ba 00 00 00 00       	mov    $0x0,%edx
  801400:	b8 04 00 00 00       	mov    $0x4,%eax
  801405:	e8 ca fe ff ff       	call   8012d4 <fsipc>
  80140a:	83 c4 10             	add    $0x10,%esp
  80140d:	85 c0                	test   %eax,%eax
  80140f:	78 1d                	js     80142e <devfile_write+0x6a>
		return r;
	assert(r <= n_real); 
  801411:	39 d8                	cmp    %ebx,%eax
  801413:	76 19                	jbe    80142e <devfile_write+0x6a>
  801415:	68 fc 26 80 00       	push   $0x8026fc
  80141a:	68 08 27 80 00       	push   $0x802708
  80141f:	68 a3 00 00 00       	push   $0xa3
  801424:	68 1d 27 80 00       	push   $0x80271d
  801429:	e8 71 0a 00 00       	call   801e9f <_panic>
	return r;
}
  80142e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801431:	c9                   	leave  
  801432:	c3                   	ret    

00801433 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801433:	55                   	push   %ebp
  801434:	89 e5                	mov    %esp,%ebp
  801436:	56                   	push   %esi
  801437:	53                   	push   %ebx
  801438:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80143b:	8b 45 08             	mov    0x8(%ebp),%eax
  80143e:	8b 40 0c             	mov    0xc(%eax),%eax
  801441:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801446:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80144c:	ba 00 00 00 00       	mov    $0x0,%edx
  801451:	b8 03 00 00 00       	mov    $0x3,%eax
  801456:	e8 79 fe ff ff       	call   8012d4 <fsipc>
  80145b:	89 c3                	mov    %eax,%ebx
  80145d:	85 c0                	test   %eax,%eax
  80145f:	78 4b                	js     8014ac <devfile_read+0x79>
		return r;
	assert(r <= n);
  801461:	39 c6                	cmp    %eax,%esi
  801463:	73 16                	jae    80147b <devfile_read+0x48>
  801465:	68 28 27 80 00       	push   $0x802728
  80146a:	68 08 27 80 00       	push   $0x802708
  80146f:	6a 7c                	push   $0x7c
  801471:	68 1d 27 80 00       	push   $0x80271d
  801476:	e8 24 0a 00 00       	call   801e9f <_panic>
	assert(r <= PGSIZE);
  80147b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801480:	7e 16                	jle    801498 <devfile_read+0x65>
  801482:	68 2f 27 80 00       	push   $0x80272f
  801487:	68 08 27 80 00       	push   $0x802708
  80148c:	6a 7d                	push   $0x7d
  80148e:	68 1d 27 80 00       	push   $0x80271d
  801493:	e8 07 0a 00 00       	call   801e9f <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801498:	83 ec 04             	sub    $0x4,%esp
  80149b:	50                   	push   %eax
  80149c:	68 00 50 80 00       	push   $0x805000
  8014a1:	ff 75 0c             	pushl  0xc(%ebp)
  8014a4:	e8 fb f3 ff ff       	call   8008a4 <memmove>
	return r;
  8014a9:	83 c4 10             	add    $0x10,%esp
}
  8014ac:	89 d8                	mov    %ebx,%eax
  8014ae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014b1:	5b                   	pop    %ebx
  8014b2:	5e                   	pop    %esi
  8014b3:	5d                   	pop    %ebp
  8014b4:	c3                   	ret    

008014b5 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8014b5:	55                   	push   %ebp
  8014b6:	89 e5                	mov    %esp,%ebp
  8014b8:	53                   	push   %ebx
  8014b9:	83 ec 20             	sub    $0x20,%esp
  8014bc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8014bf:	53                   	push   %ebx
  8014c0:	e8 14 f2 ff ff       	call   8006d9 <strlen>
  8014c5:	83 c4 10             	add    $0x10,%esp
  8014c8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8014cd:	7f 67                	jg     801536 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014cf:	83 ec 0c             	sub    $0xc,%esp
  8014d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014d5:	50                   	push   %eax
  8014d6:	e8 71 f8 ff ff       	call   800d4c <fd_alloc>
  8014db:	83 c4 10             	add    $0x10,%esp
		return r;
  8014de:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014e0:	85 c0                	test   %eax,%eax
  8014e2:	78 57                	js     80153b <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8014e4:	83 ec 08             	sub    $0x8,%esp
  8014e7:	53                   	push   %ebx
  8014e8:	68 00 50 80 00       	push   $0x805000
  8014ed:	e8 20 f2 ff ff       	call   800712 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8014f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014f5:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8014fa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014fd:	b8 01 00 00 00       	mov    $0x1,%eax
  801502:	e8 cd fd ff ff       	call   8012d4 <fsipc>
  801507:	89 c3                	mov    %eax,%ebx
  801509:	83 c4 10             	add    $0x10,%esp
  80150c:	85 c0                	test   %eax,%eax
  80150e:	79 14                	jns    801524 <open+0x6f>
		fd_close(fd, 0);
  801510:	83 ec 08             	sub    $0x8,%esp
  801513:	6a 00                	push   $0x0
  801515:	ff 75 f4             	pushl  -0xc(%ebp)
  801518:	e8 27 f9 ff ff       	call   800e44 <fd_close>
		return r;
  80151d:	83 c4 10             	add    $0x10,%esp
  801520:	89 da                	mov    %ebx,%edx
  801522:	eb 17                	jmp    80153b <open+0x86>
	}

	return fd2num(fd);
  801524:	83 ec 0c             	sub    $0xc,%esp
  801527:	ff 75 f4             	pushl  -0xc(%ebp)
  80152a:	e8 f6 f7 ff ff       	call   800d25 <fd2num>
  80152f:	89 c2                	mov    %eax,%edx
  801531:	83 c4 10             	add    $0x10,%esp
  801534:	eb 05                	jmp    80153b <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801536:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80153b:	89 d0                	mov    %edx,%eax
  80153d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801540:	c9                   	leave  
  801541:	c3                   	ret    

00801542 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801542:	55                   	push   %ebp
  801543:	89 e5                	mov    %esp,%ebp
  801545:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801548:	ba 00 00 00 00       	mov    $0x0,%edx
  80154d:	b8 08 00 00 00       	mov    $0x8,%eax
  801552:	e8 7d fd ff ff       	call   8012d4 <fsipc>
}
  801557:	c9                   	leave  
  801558:	c3                   	ret    

00801559 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801559:	55                   	push   %ebp
  80155a:	89 e5                	mov    %esp,%ebp
  80155c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  80155f:	68 3b 27 80 00       	push   $0x80273b
  801564:	ff 75 0c             	pushl  0xc(%ebp)
  801567:	e8 a6 f1 ff ff       	call   800712 <strcpy>
	return 0;
}
  80156c:	b8 00 00 00 00       	mov    $0x0,%eax
  801571:	c9                   	leave  
  801572:	c3                   	ret    

00801573 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801573:	55                   	push   %ebp
  801574:	89 e5                	mov    %esp,%ebp
  801576:	53                   	push   %ebx
  801577:	83 ec 10             	sub    $0x10,%esp
  80157a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80157d:	53                   	push   %ebx
  80157e:	e8 58 0a 00 00       	call   801fdb <pageref>
  801583:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801586:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  80158b:	83 f8 01             	cmp    $0x1,%eax
  80158e:	75 10                	jne    8015a0 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801590:	83 ec 0c             	sub    $0xc,%esp
  801593:	ff 73 0c             	pushl  0xc(%ebx)
  801596:	e8 c0 02 00 00       	call   80185b <nsipc_close>
  80159b:	89 c2                	mov    %eax,%edx
  80159d:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8015a0:	89 d0                	mov    %edx,%eax
  8015a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015a5:	c9                   	leave  
  8015a6:	c3                   	ret    

008015a7 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8015a7:	55                   	push   %ebp
  8015a8:	89 e5                	mov    %esp,%ebp
  8015aa:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8015ad:	6a 00                	push   $0x0
  8015af:	ff 75 10             	pushl  0x10(%ebp)
  8015b2:	ff 75 0c             	pushl  0xc(%ebp)
  8015b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8015b8:	ff 70 0c             	pushl  0xc(%eax)
  8015bb:	e8 78 03 00 00       	call   801938 <nsipc_send>
}
  8015c0:	c9                   	leave  
  8015c1:	c3                   	ret    

008015c2 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8015c2:	55                   	push   %ebp
  8015c3:	89 e5                	mov    %esp,%ebp
  8015c5:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8015c8:	6a 00                	push   $0x0
  8015ca:	ff 75 10             	pushl  0x10(%ebp)
  8015cd:	ff 75 0c             	pushl  0xc(%ebp)
  8015d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8015d3:	ff 70 0c             	pushl  0xc(%eax)
  8015d6:	e8 f1 02 00 00       	call   8018cc <nsipc_recv>
}
  8015db:	c9                   	leave  
  8015dc:	c3                   	ret    

008015dd <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8015dd:	55                   	push   %ebp
  8015de:	89 e5                	mov    %esp,%ebp
  8015e0:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8015e3:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8015e6:	52                   	push   %edx
  8015e7:	50                   	push   %eax
  8015e8:	e8 ae f7 ff ff       	call   800d9b <fd_lookup>
  8015ed:	83 c4 10             	add    $0x10,%esp
  8015f0:	85 c0                	test   %eax,%eax
  8015f2:	78 17                	js     80160b <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8015f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015f7:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  8015fd:	39 08                	cmp    %ecx,(%eax)
  8015ff:	75 05                	jne    801606 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801601:	8b 40 0c             	mov    0xc(%eax),%eax
  801604:	eb 05                	jmp    80160b <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801606:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  80160b:	c9                   	leave  
  80160c:	c3                   	ret    

0080160d <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  80160d:	55                   	push   %ebp
  80160e:	89 e5                	mov    %esp,%ebp
  801610:	56                   	push   %esi
  801611:	53                   	push   %ebx
  801612:	83 ec 1c             	sub    $0x1c,%esp
  801615:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801617:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80161a:	50                   	push   %eax
  80161b:	e8 2c f7 ff ff       	call   800d4c <fd_alloc>
  801620:	89 c3                	mov    %eax,%ebx
  801622:	83 c4 10             	add    $0x10,%esp
  801625:	85 c0                	test   %eax,%eax
  801627:	78 1b                	js     801644 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801629:	83 ec 04             	sub    $0x4,%esp
  80162c:	68 07 04 00 00       	push   $0x407
  801631:	ff 75 f4             	pushl  -0xc(%ebp)
  801634:	6a 00                	push   $0x0
  801636:	e8 da f4 ff ff       	call   800b15 <sys_page_alloc>
  80163b:	89 c3                	mov    %eax,%ebx
  80163d:	83 c4 10             	add    $0x10,%esp
  801640:	85 c0                	test   %eax,%eax
  801642:	79 10                	jns    801654 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801644:	83 ec 0c             	sub    $0xc,%esp
  801647:	56                   	push   %esi
  801648:	e8 0e 02 00 00       	call   80185b <nsipc_close>
		return r;
  80164d:	83 c4 10             	add    $0x10,%esp
  801650:	89 d8                	mov    %ebx,%eax
  801652:	eb 24                	jmp    801678 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801654:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80165a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80165d:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  80165f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801662:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801669:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  80166c:	83 ec 0c             	sub    $0xc,%esp
  80166f:	50                   	push   %eax
  801670:	e8 b0 f6 ff ff       	call   800d25 <fd2num>
  801675:	83 c4 10             	add    $0x10,%esp
}
  801678:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80167b:	5b                   	pop    %ebx
  80167c:	5e                   	pop    %esi
  80167d:	5d                   	pop    %ebp
  80167e:	c3                   	ret    

0080167f <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80167f:	55                   	push   %ebp
  801680:	89 e5                	mov    %esp,%ebp
  801682:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801685:	8b 45 08             	mov    0x8(%ebp),%eax
  801688:	e8 50 ff ff ff       	call   8015dd <fd2sockid>
		return r;
  80168d:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  80168f:	85 c0                	test   %eax,%eax
  801691:	78 1f                	js     8016b2 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801693:	83 ec 04             	sub    $0x4,%esp
  801696:	ff 75 10             	pushl  0x10(%ebp)
  801699:	ff 75 0c             	pushl  0xc(%ebp)
  80169c:	50                   	push   %eax
  80169d:	e8 12 01 00 00       	call   8017b4 <nsipc_accept>
  8016a2:	83 c4 10             	add    $0x10,%esp
		return r;
  8016a5:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8016a7:	85 c0                	test   %eax,%eax
  8016a9:	78 07                	js     8016b2 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  8016ab:	e8 5d ff ff ff       	call   80160d <alloc_sockfd>
  8016b0:	89 c1                	mov    %eax,%ecx
}
  8016b2:	89 c8                	mov    %ecx,%eax
  8016b4:	c9                   	leave  
  8016b5:	c3                   	ret    

008016b6 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8016b6:	55                   	push   %ebp
  8016b7:	89 e5                	mov    %esp,%ebp
  8016b9:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8016bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8016bf:	e8 19 ff ff ff       	call   8015dd <fd2sockid>
  8016c4:	85 c0                	test   %eax,%eax
  8016c6:	78 12                	js     8016da <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  8016c8:	83 ec 04             	sub    $0x4,%esp
  8016cb:	ff 75 10             	pushl  0x10(%ebp)
  8016ce:	ff 75 0c             	pushl  0xc(%ebp)
  8016d1:	50                   	push   %eax
  8016d2:	e8 2d 01 00 00       	call   801804 <nsipc_bind>
  8016d7:	83 c4 10             	add    $0x10,%esp
}
  8016da:	c9                   	leave  
  8016db:	c3                   	ret    

008016dc <shutdown>:

int
shutdown(int s, int how)
{
  8016dc:	55                   	push   %ebp
  8016dd:	89 e5                	mov    %esp,%ebp
  8016df:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8016e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e5:	e8 f3 fe ff ff       	call   8015dd <fd2sockid>
  8016ea:	85 c0                	test   %eax,%eax
  8016ec:	78 0f                	js     8016fd <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8016ee:	83 ec 08             	sub    $0x8,%esp
  8016f1:	ff 75 0c             	pushl  0xc(%ebp)
  8016f4:	50                   	push   %eax
  8016f5:	e8 3f 01 00 00       	call   801839 <nsipc_shutdown>
  8016fa:	83 c4 10             	add    $0x10,%esp
}
  8016fd:	c9                   	leave  
  8016fe:	c3                   	ret    

008016ff <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8016ff:	55                   	push   %ebp
  801700:	89 e5                	mov    %esp,%ebp
  801702:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801705:	8b 45 08             	mov    0x8(%ebp),%eax
  801708:	e8 d0 fe ff ff       	call   8015dd <fd2sockid>
  80170d:	85 c0                	test   %eax,%eax
  80170f:	78 12                	js     801723 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801711:	83 ec 04             	sub    $0x4,%esp
  801714:	ff 75 10             	pushl  0x10(%ebp)
  801717:	ff 75 0c             	pushl  0xc(%ebp)
  80171a:	50                   	push   %eax
  80171b:	e8 55 01 00 00       	call   801875 <nsipc_connect>
  801720:	83 c4 10             	add    $0x10,%esp
}
  801723:	c9                   	leave  
  801724:	c3                   	ret    

00801725 <listen>:

int
listen(int s, int backlog)
{
  801725:	55                   	push   %ebp
  801726:	89 e5                	mov    %esp,%ebp
  801728:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80172b:	8b 45 08             	mov    0x8(%ebp),%eax
  80172e:	e8 aa fe ff ff       	call   8015dd <fd2sockid>
  801733:	85 c0                	test   %eax,%eax
  801735:	78 0f                	js     801746 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801737:	83 ec 08             	sub    $0x8,%esp
  80173a:	ff 75 0c             	pushl  0xc(%ebp)
  80173d:	50                   	push   %eax
  80173e:	e8 67 01 00 00       	call   8018aa <nsipc_listen>
  801743:	83 c4 10             	add    $0x10,%esp
}
  801746:	c9                   	leave  
  801747:	c3                   	ret    

00801748 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801748:	55                   	push   %ebp
  801749:	89 e5                	mov    %esp,%ebp
  80174b:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  80174e:	ff 75 10             	pushl  0x10(%ebp)
  801751:	ff 75 0c             	pushl  0xc(%ebp)
  801754:	ff 75 08             	pushl  0x8(%ebp)
  801757:	e8 3a 02 00 00       	call   801996 <nsipc_socket>
  80175c:	83 c4 10             	add    $0x10,%esp
  80175f:	85 c0                	test   %eax,%eax
  801761:	78 05                	js     801768 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801763:	e8 a5 fe ff ff       	call   80160d <alloc_sockfd>
}
  801768:	c9                   	leave  
  801769:	c3                   	ret    

0080176a <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  80176a:	55                   	push   %ebp
  80176b:	89 e5                	mov    %esp,%ebp
  80176d:	53                   	push   %ebx
  80176e:	83 ec 04             	sub    $0x4,%esp
  801771:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801773:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  80177a:	75 12                	jne    80178e <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  80177c:	83 ec 0c             	sub    $0xc,%esp
  80177f:	6a 02                	push   $0x2
  801781:	e8 1c 08 00 00       	call   801fa2 <ipc_find_env>
  801786:	a3 04 40 80 00       	mov    %eax,0x804004
  80178b:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  80178e:	6a 07                	push   $0x7
  801790:	68 00 60 80 00       	push   $0x806000
  801795:	53                   	push   %ebx
  801796:	ff 35 04 40 80 00    	pushl  0x804004
  80179c:	e8 ad 07 00 00       	call   801f4e <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8017a1:	83 c4 0c             	add    $0xc,%esp
  8017a4:	6a 00                	push   $0x0
  8017a6:	6a 00                	push   $0x0
  8017a8:	6a 00                	push   $0x0
  8017aa:	e8 36 07 00 00       	call   801ee5 <ipc_recv>
}
  8017af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017b2:	c9                   	leave  
  8017b3:	c3                   	ret    

008017b4 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8017b4:	55                   	push   %ebp
  8017b5:	89 e5                	mov    %esp,%ebp
  8017b7:	56                   	push   %esi
  8017b8:	53                   	push   %ebx
  8017b9:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8017bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8017bf:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8017c4:	8b 06                	mov    (%esi),%eax
  8017c6:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8017cb:	b8 01 00 00 00       	mov    $0x1,%eax
  8017d0:	e8 95 ff ff ff       	call   80176a <nsipc>
  8017d5:	89 c3                	mov    %eax,%ebx
  8017d7:	85 c0                	test   %eax,%eax
  8017d9:	78 20                	js     8017fb <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8017db:	83 ec 04             	sub    $0x4,%esp
  8017de:	ff 35 10 60 80 00    	pushl  0x806010
  8017e4:	68 00 60 80 00       	push   $0x806000
  8017e9:	ff 75 0c             	pushl  0xc(%ebp)
  8017ec:	e8 b3 f0 ff ff       	call   8008a4 <memmove>
		*addrlen = ret->ret_addrlen;
  8017f1:	a1 10 60 80 00       	mov    0x806010,%eax
  8017f6:	89 06                	mov    %eax,(%esi)
  8017f8:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  8017fb:	89 d8                	mov    %ebx,%eax
  8017fd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801800:	5b                   	pop    %ebx
  801801:	5e                   	pop    %esi
  801802:	5d                   	pop    %ebp
  801803:	c3                   	ret    

00801804 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801804:	55                   	push   %ebp
  801805:	89 e5                	mov    %esp,%ebp
  801807:	53                   	push   %ebx
  801808:	83 ec 08             	sub    $0x8,%esp
  80180b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80180e:	8b 45 08             	mov    0x8(%ebp),%eax
  801811:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801816:	53                   	push   %ebx
  801817:	ff 75 0c             	pushl  0xc(%ebp)
  80181a:	68 04 60 80 00       	push   $0x806004
  80181f:	e8 80 f0 ff ff       	call   8008a4 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801824:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  80182a:	b8 02 00 00 00       	mov    $0x2,%eax
  80182f:	e8 36 ff ff ff       	call   80176a <nsipc>
}
  801834:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801837:	c9                   	leave  
  801838:	c3                   	ret    

00801839 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801839:	55                   	push   %ebp
  80183a:	89 e5                	mov    %esp,%ebp
  80183c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  80183f:	8b 45 08             	mov    0x8(%ebp),%eax
  801842:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801847:	8b 45 0c             	mov    0xc(%ebp),%eax
  80184a:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  80184f:	b8 03 00 00 00       	mov    $0x3,%eax
  801854:	e8 11 ff ff ff       	call   80176a <nsipc>
}
  801859:	c9                   	leave  
  80185a:	c3                   	ret    

0080185b <nsipc_close>:

int
nsipc_close(int s)
{
  80185b:	55                   	push   %ebp
  80185c:	89 e5                	mov    %esp,%ebp
  80185e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801861:	8b 45 08             	mov    0x8(%ebp),%eax
  801864:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801869:	b8 04 00 00 00       	mov    $0x4,%eax
  80186e:	e8 f7 fe ff ff       	call   80176a <nsipc>
}
  801873:	c9                   	leave  
  801874:	c3                   	ret    

00801875 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801875:	55                   	push   %ebp
  801876:	89 e5                	mov    %esp,%ebp
  801878:	53                   	push   %ebx
  801879:	83 ec 08             	sub    $0x8,%esp
  80187c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80187f:	8b 45 08             	mov    0x8(%ebp),%eax
  801882:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801887:	53                   	push   %ebx
  801888:	ff 75 0c             	pushl  0xc(%ebp)
  80188b:	68 04 60 80 00       	push   $0x806004
  801890:	e8 0f f0 ff ff       	call   8008a4 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801895:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  80189b:	b8 05 00 00 00       	mov    $0x5,%eax
  8018a0:	e8 c5 fe ff ff       	call   80176a <nsipc>
}
  8018a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018a8:	c9                   	leave  
  8018a9:	c3                   	ret    

008018aa <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8018aa:	55                   	push   %ebp
  8018ab:	89 e5                	mov    %esp,%ebp
  8018ad:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8018b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b3:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  8018b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018bb:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  8018c0:	b8 06 00 00 00       	mov    $0x6,%eax
  8018c5:	e8 a0 fe ff ff       	call   80176a <nsipc>
}
  8018ca:	c9                   	leave  
  8018cb:	c3                   	ret    

008018cc <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8018cc:	55                   	push   %ebp
  8018cd:	89 e5                	mov    %esp,%ebp
  8018cf:	56                   	push   %esi
  8018d0:	53                   	push   %ebx
  8018d1:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8018d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d7:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  8018dc:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  8018e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8018e5:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8018ea:	b8 07 00 00 00       	mov    $0x7,%eax
  8018ef:	e8 76 fe ff ff       	call   80176a <nsipc>
  8018f4:	89 c3                	mov    %eax,%ebx
  8018f6:	85 c0                	test   %eax,%eax
  8018f8:	78 35                	js     80192f <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  8018fa:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8018ff:	7f 04                	jg     801905 <nsipc_recv+0x39>
  801901:	39 c6                	cmp    %eax,%esi
  801903:	7d 16                	jge    80191b <nsipc_recv+0x4f>
  801905:	68 47 27 80 00       	push   $0x802747
  80190a:	68 08 27 80 00       	push   $0x802708
  80190f:	6a 62                	push   $0x62
  801911:	68 5c 27 80 00       	push   $0x80275c
  801916:	e8 84 05 00 00       	call   801e9f <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  80191b:	83 ec 04             	sub    $0x4,%esp
  80191e:	50                   	push   %eax
  80191f:	68 00 60 80 00       	push   $0x806000
  801924:	ff 75 0c             	pushl  0xc(%ebp)
  801927:	e8 78 ef ff ff       	call   8008a4 <memmove>
  80192c:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  80192f:	89 d8                	mov    %ebx,%eax
  801931:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801934:	5b                   	pop    %ebx
  801935:	5e                   	pop    %esi
  801936:	5d                   	pop    %ebp
  801937:	c3                   	ret    

00801938 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801938:	55                   	push   %ebp
  801939:	89 e5                	mov    %esp,%ebp
  80193b:	53                   	push   %ebx
  80193c:	83 ec 04             	sub    $0x4,%esp
  80193f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801942:	8b 45 08             	mov    0x8(%ebp),%eax
  801945:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  80194a:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801950:	7e 16                	jle    801968 <nsipc_send+0x30>
  801952:	68 68 27 80 00       	push   $0x802768
  801957:	68 08 27 80 00       	push   $0x802708
  80195c:	6a 6d                	push   $0x6d
  80195e:	68 5c 27 80 00       	push   $0x80275c
  801963:	e8 37 05 00 00       	call   801e9f <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801968:	83 ec 04             	sub    $0x4,%esp
  80196b:	53                   	push   %ebx
  80196c:	ff 75 0c             	pushl  0xc(%ebp)
  80196f:	68 0c 60 80 00       	push   $0x80600c
  801974:	e8 2b ef ff ff       	call   8008a4 <memmove>
	nsipcbuf.send.req_size = size;
  801979:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  80197f:	8b 45 14             	mov    0x14(%ebp),%eax
  801982:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801987:	b8 08 00 00 00       	mov    $0x8,%eax
  80198c:	e8 d9 fd ff ff       	call   80176a <nsipc>
}
  801991:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801994:	c9                   	leave  
  801995:	c3                   	ret    

00801996 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801996:	55                   	push   %ebp
  801997:	89 e5                	mov    %esp,%ebp
  801999:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80199c:	8b 45 08             	mov    0x8(%ebp),%eax
  80199f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  8019a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019a7:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  8019ac:	8b 45 10             	mov    0x10(%ebp),%eax
  8019af:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  8019b4:	b8 09 00 00 00       	mov    $0x9,%eax
  8019b9:	e8 ac fd ff ff       	call   80176a <nsipc>
}
  8019be:	c9                   	leave  
  8019bf:	c3                   	ret    

008019c0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019c0:	55                   	push   %ebp
  8019c1:	89 e5                	mov    %esp,%ebp
  8019c3:	56                   	push   %esi
  8019c4:	53                   	push   %ebx
  8019c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019c8:	83 ec 0c             	sub    $0xc,%esp
  8019cb:	ff 75 08             	pushl  0x8(%ebp)
  8019ce:	e8 62 f3 ff ff       	call   800d35 <fd2data>
  8019d3:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019d5:	83 c4 08             	add    $0x8,%esp
  8019d8:	68 74 27 80 00       	push   $0x802774
  8019dd:	53                   	push   %ebx
  8019de:	e8 2f ed ff ff       	call   800712 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019e3:	8b 46 04             	mov    0x4(%esi),%eax
  8019e6:	2b 06                	sub    (%esi),%eax
  8019e8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019ee:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019f5:	00 00 00 
	stat->st_dev = &devpipe;
  8019f8:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  8019ff:	30 80 00 
	return 0;
}
  801a02:	b8 00 00 00 00       	mov    $0x0,%eax
  801a07:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a0a:	5b                   	pop    %ebx
  801a0b:	5e                   	pop    %esi
  801a0c:	5d                   	pop    %ebp
  801a0d:	c3                   	ret    

00801a0e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a0e:	55                   	push   %ebp
  801a0f:	89 e5                	mov    %esp,%ebp
  801a11:	53                   	push   %ebx
  801a12:	83 ec 0c             	sub    $0xc,%esp
  801a15:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a18:	53                   	push   %ebx
  801a19:	6a 00                	push   $0x0
  801a1b:	e8 7a f1 ff ff       	call   800b9a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a20:	89 1c 24             	mov    %ebx,(%esp)
  801a23:	e8 0d f3 ff ff       	call   800d35 <fd2data>
  801a28:	83 c4 08             	add    $0x8,%esp
  801a2b:	50                   	push   %eax
  801a2c:	6a 00                	push   $0x0
  801a2e:	e8 67 f1 ff ff       	call   800b9a <sys_page_unmap>
}
  801a33:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a36:	c9                   	leave  
  801a37:	c3                   	ret    

00801a38 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a38:	55                   	push   %ebp
  801a39:	89 e5                	mov    %esp,%ebp
  801a3b:	57                   	push   %edi
  801a3c:	56                   	push   %esi
  801a3d:	53                   	push   %ebx
  801a3e:	83 ec 1c             	sub    $0x1c,%esp
  801a41:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a44:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a46:	a1 08 40 80 00       	mov    0x804008,%eax
  801a4b:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a4e:	83 ec 0c             	sub    $0xc,%esp
  801a51:	ff 75 e0             	pushl  -0x20(%ebp)
  801a54:	e8 82 05 00 00       	call   801fdb <pageref>
  801a59:	89 c3                	mov    %eax,%ebx
  801a5b:	89 3c 24             	mov    %edi,(%esp)
  801a5e:	e8 78 05 00 00       	call   801fdb <pageref>
  801a63:	83 c4 10             	add    $0x10,%esp
  801a66:	39 c3                	cmp    %eax,%ebx
  801a68:	0f 94 c1             	sete   %cl
  801a6b:	0f b6 c9             	movzbl %cl,%ecx
  801a6e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a71:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801a77:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a7a:	39 ce                	cmp    %ecx,%esi
  801a7c:	74 1b                	je     801a99 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a7e:	39 c3                	cmp    %eax,%ebx
  801a80:	75 c4                	jne    801a46 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a82:	8b 42 58             	mov    0x58(%edx),%eax
  801a85:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a88:	50                   	push   %eax
  801a89:	56                   	push   %esi
  801a8a:	68 7b 27 80 00       	push   $0x80277b
  801a8f:	e8 f9 e6 ff ff       	call   80018d <cprintf>
  801a94:	83 c4 10             	add    $0x10,%esp
  801a97:	eb ad                	jmp    801a46 <_pipeisclosed+0xe>
	}
}
  801a99:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a9c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a9f:	5b                   	pop    %ebx
  801aa0:	5e                   	pop    %esi
  801aa1:	5f                   	pop    %edi
  801aa2:	5d                   	pop    %ebp
  801aa3:	c3                   	ret    

00801aa4 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801aa4:	55                   	push   %ebp
  801aa5:	89 e5                	mov    %esp,%ebp
  801aa7:	57                   	push   %edi
  801aa8:	56                   	push   %esi
  801aa9:	53                   	push   %ebx
  801aaa:	83 ec 28             	sub    $0x28,%esp
  801aad:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801ab0:	56                   	push   %esi
  801ab1:	e8 7f f2 ff ff       	call   800d35 <fd2data>
  801ab6:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ab8:	83 c4 10             	add    $0x10,%esp
  801abb:	bf 00 00 00 00       	mov    $0x0,%edi
  801ac0:	eb 4b                	jmp    801b0d <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ac2:	89 da                	mov    %ebx,%edx
  801ac4:	89 f0                	mov    %esi,%eax
  801ac6:	e8 6d ff ff ff       	call   801a38 <_pipeisclosed>
  801acb:	85 c0                	test   %eax,%eax
  801acd:	75 48                	jne    801b17 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801acf:	e8 22 f0 ff ff       	call   800af6 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ad4:	8b 43 04             	mov    0x4(%ebx),%eax
  801ad7:	8b 0b                	mov    (%ebx),%ecx
  801ad9:	8d 51 20             	lea    0x20(%ecx),%edx
  801adc:	39 d0                	cmp    %edx,%eax
  801ade:	73 e2                	jae    801ac2 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ae0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ae3:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801ae7:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801aea:	89 c2                	mov    %eax,%edx
  801aec:	c1 fa 1f             	sar    $0x1f,%edx
  801aef:	89 d1                	mov    %edx,%ecx
  801af1:	c1 e9 1b             	shr    $0x1b,%ecx
  801af4:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801af7:	83 e2 1f             	and    $0x1f,%edx
  801afa:	29 ca                	sub    %ecx,%edx
  801afc:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b00:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b04:	83 c0 01             	add    $0x1,%eax
  801b07:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b0a:	83 c7 01             	add    $0x1,%edi
  801b0d:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b10:	75 c2                	jne    801ad4 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b12:	8b 45 10             	mov    0x10(%ebp),%eax
  801b15:	eb 05                	jmp    801b1c <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b17:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b1f:	5b                   	pop    %ebx
  801b20:	5e                   	pop    %esi
  801b21:	5f                   	pop    %edi
  801b22:	5d                   	pop    %ebp
  801b23:	c3                   	ret    

00801b24 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b24:	55                   	push   %ebp
  801b25:	89 e5                	mov    %esp,%ebp
  801b27:	57                   	push   %edi
  801b28:	56                   	push   %esi
  801b29:	53                   	push   %ebx
  801b2a:	83 ec 18             	sub    $0x18,%esp
  801b2d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b30:	57                   	push   %edi
  801b31:	e8 ff f1 ff ff       	call   800d35 <fd2data>
  801b36:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b38:	83 c4 10             	add    $0x10,%esp
  801b3b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b40:	eb 3d                	jmp    801b7f <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b42:	85 db                	test   %ebx,%ebx
  801b44:	74 04                	je     801b4a <devpipe_read+0x26>
				return i;
  801b46:	89 d8                	mov    %ebx,%eax
  801b48:	eb 44                	jmp    801b8e <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b4a:	89 f2                	mov    %esi,%edx
  801b4c:	89 f8                	mov    %edi,%eax
  801b4e:	e8 e5 fe ff ff       	call   801a38 <_pipeisclosed>
  801b53:	85 c0                	test   %eax,%eax
  801b55:	75 32                	jne    801b89 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b57:	e8 9a ef ff ff       	call   800af6 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b5c:	8b 06                	mov    (%esi),%eax
  801b5e:	3b 46 04             	cmp    0x4(%esi),%eax
  801b61:	74 df                	je     801b42 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b63:	99                   	cltd   
  801b64:	c1 ea 1b             	shr    $0x1b,%edx
  801b67:	01 d0                	add    %edx,%eax
  801b69:	83 e0 1f             	and    $0x1f,%eax
  801b6c:	29 d0                	sub    %edx,%eax
  801b6e:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b76:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b79:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b7c:	83 c3 01             	add    $0x1,%ebx
  801b7f:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b82:	75 d8                	jne    801b5c <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b84:	8b 45 10             	mov    0x10(%ebp),%eax
  801b87:	eb 05                	jmp    801b8e <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b89:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b8e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b91:	5b                   	pop    %ebx
  801b92:	5e                   	pop    %esi
  801b93:	5f                   	pop    %edi
  801b94:	5d                   	pop    %ebp
  801b95:	c3                   	ret    

00801b96 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b96:	55                   	push   %ebp
  801b97:	89 e5                	mov    %esp,%ebp
  801b99:	56                   	push   %esi
  801b9a:	53                   	push   %ebx
  801b9b:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b9e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ba1:	50                   	push   %eax
  801ba2:	e8 a5 f1 ff ff       	call   800d4c <fd_alloc>
  801ba7:	83 c4 10             	add    $0x10,%esp
  801baa:	89 c2                	mov    %eax,%edx
  801bac:	85 c0                	test   %eax,%eax
  801bae:	0f 88 2c 01 00 00    	js     801ce0 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bb4:	83 ec 04             	sub    $0x4,%esp
  801bb7:	68 07 04 00 00       	push   $0x407
  801bbc:	ff 75 f4             	pushl  -0xc(%ebp)
  801bbf:	6a 00                	push   $0x0
  801bc1:	e8 4f ef ff ff       	call   800b15 <sys_page_alloc>
  801bc6:	83 c4 10             	add    $0x10,%esp
  801bc9:	89 c2                	mov    %eax,%edx
  801bcb:	85 c0                	test   %eax,%eax
  801bcd:	0f 88 0d 01 00 00    	js     801ce0 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801bd3:	83 ec 0c             	sub    $0xc,%esp
  801bd6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bd9:	50                   	push   %eax
  801bda:	e8 6d f1 ff ff       	call   800d4c <fd_alloc>
  801bdf:	89 c3                	mov    %eax,%ebx
  801be1:	83 c4 10             	add    $0x10,%esp
  801be4:	85 c0                	test   %eax,%eax
  801be6:	0f 88 e2 00 00 00    	js     801cce <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bec:	83 ec 04             	sub    $0x4,%esp
  801bef:	68 07 04 00 00       	push   $0x407
  801bf4:	ff 75 f0             	pushl  -0x10(%ebp)
  801bf7:	6a 00                	push   $0x0
  801bf9:	e8 17 ef ff ff       	call   800b15 <sys_page_alloc>
  801bfe:	89 c3                	mov    %eax,%ebx
  801c00:	83 c4 10             	add    $0x10,%esp
  801c03:	85 c0                	test   %eax,%eax
  801c05:	0f 88 c3 00 00 00    	js     801cce <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c0b:	83 ec 0c             	sub    $0xc,%esp
  801c0e:	ff 75 f4             	pushl  -0xc(%ebp)
  801c11:	e8 1f f1 ff ff       	call   800d35 <fd2data>
  801c16:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c18:	83 c4 0c             	add    $0xc,%esp
  801c1b:	68 07 04 00 00       	push   $0x407
  801c20:	50                   	push   %eax
  801c21:	6a 00                	push   $0x0
  801c23:	e8 ed ee ff ff       	call   800b15 <sys_page_alloc>
  801c28:	89 c3                	mov    %eax,%ebx
  801c2a:	83 c4 10             	add    $0x10,%esp
  801c2d:	85 c0                	test   %eax,%eax
  801c2f:	0f 88 89 00 00 00    	js     801cbe <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c35:	83 ec 0c             	sub    $0xc,%esp
  801c38:	ff 75 f0             	pushl  -0x10(%ebp)
  801c3b:	e8 f5 f0 ff ff       	call   800d35 <fd2data>
  801c40:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c47:	50                   	push   %eax
  801c48:	6a 00                	push   $0x0
  801c4a:	56                   	push   %esi
  801c4b:	6a 00                	push   $0x0
  801c4d:	e8 06 ef ff ff       	call   800b58 <sys_page_map>
  801c52:	89 c3                	mov    %eax,%ebx
  801c54:	83 c4 20             	add    $0x20,%esp
  801c57:	85 c0                	test   %eax,%eax
  801c59:	78 55                	js     801cb0 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c5b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c61:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c64:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c66:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c69:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c70:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c76:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c79:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c7e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c85:	83 ec 0c             	sub    $0xc,%esp
  801c88:	ff 75 f4             	pushl  -0xc(%ebp)
  801c8b:	e8 95 f0 ff ff       	call   800d25 <fd2num>
  801c90:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c93:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c95:	83 c4 04             	add    $0x4,%esp
  801c98:	ff 75 f0             	pushl  -0x10(%ebp)
  801c9b:	e8 85 f0 ff ff       	call   800d25 <fd2num>
  801ca0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ca3:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801ca6:	83 c4 10             	add    $0x10,%esp
  801ca9:	ba 00 00 00 00       	mov    $0x0,%edx
  801cae:	eb 30                	jmp    801ce0 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801cb0:	83 ec 08             	sub    $0x8,%esp
  801cb3:	56                   	push   %esi
  801cb4:	6a 00                	push   $0x0
  801cb6:	e8 df ee ff ff       	call   800b9a <sys_page_unmap>
  801cbb:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801cbe:	83 ec 08             	sub    $0x8,%esp
  801cc1:	ff 75 f0             	pushl  -0x10(%ebp)
  801cc4:	6a 00                	push   $0x0
  801cc6:	e8 cf ee ff ff       	call   800b9a <sys_page_unmap>
  801ccb:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801cce:	83 ec 08             	sub    $0x8,%esp
  801cd1:	ff 75 f4             	pushl  -0xc(%ebp)
  801cd4:	6a 00                	push   $0x0
  801cd6:	e8 bf ee ff ff       	call   800b9a <sys_page_unmap>
  801cdb:	83 c4 10             	add    $0x10,%esp
  801cde:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801ce0:	89 d0                	mov    %edx,%eax
  801ce2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ce5:	5b                   	pop    %ebx
  801ce6:	5e                   	pop    %esi
  801ce7:	5d                   	pop    %ebp
  801ce8:	c3                   	ret    

00801ce9 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801ce9:	55                   	push   %ebp
  801cea:	89 e5                	mov    %esp,%ebp
  801cec:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cf2:	50                   	push   %eax
  801cf3:	ff 75 08             	pushl  0x8(%ebp)
  801cf6:	e8 a0 f0 ff ff       	call   800d9b <fd_lookup>
  801cfb:	83 c4 10             	add    $0x10,%esp
  801cfe:	85 c0                	test   %eax,%eax
  801d00:	78 18                	js     801d1a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d02:	83 ec 0c             	sub    $0xc,%esp
  801d05:	ff 75 f4             	pushl  -0xc(%ebp)
  801d08:	e8 28 f0 ff ff       	call   800d35 <fd2data>
	return _pipeisclosed(fd, p);
  801d0d:	89 c2                	mov    %eax,%edx
  801d0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d12:	e8 21 fd ff ff       	call   801a38 <_pipeisclosed>
  801d17:	83 c4 10             	add    $0x10,%esp
}
  801d1a:	c9                   	leave  
  801d1b:	c3                   	ret    

00801d1c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d1c:	55                   	push   %ebp
  801d1d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d1f:	b8 00 00 00 00       	mov    $0x0,%eax
  801d24:	5d                   	pop    %ebp
  801d25:	c3                   	ret    

00801d26 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d26:	55                   	push   %ebp
  801d27:	89 e5                	mov    %esp,%ebp
  801d29:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d2c:	68 93 27 80 00       	push   $0x802793
  801d31:	ff 75 0c             	pushl  0xc(%ebp)
  801d34:	e8 d9 e9 ff ff       	call   800712 <strcpy>
	return 0;
}
  801d39:	b8 00 00 00 00       	mov    $0x0,%eax
  801d3e:	c9                   	leave  
  801d3f:	c3                   	ret    

00801d40 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d40:	55                   	push   %ebp
  801d41:	89 e5                	mov    %esp,%ebp
  801d43:	57                   	push   %edi
  801d44:	56                   	push   %esi
  801d45:	53                   	push   %ebx
  801d46:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d4c:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d51:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d57:	eb 2d                	jmp    801d86 <devcons_write+0x46>
		m = n - tot;
  801d59:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d5c:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d5e:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d61:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d66:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d69:	83 ec 04             	sub    $0x4,%esp
  801d6c:	53                   	push   %ebx
  801d6d:	03 45 0c             	add    0xc(%ebp),%eax
  801d70:	50                   	push   %eax
  801d71:	57                   	push   %edi
  801d72:	e8 2d eb ff ff       	call   8008a4 <memmove>
		sys_cputs(buf, m);
  801d77:	83 c4 08             	add    $0x8,%esp
  801d7a:	53                   	push   %ebx
  801d7b:	57                   	push   %edi
  801d7c:	e8 d8 ec ff ff       	call   800a59 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d81:	01 de                	add    %ebx,%esi
  801d83:	83 c4 10             	add    $0x10,%esp
  801d86:	89 f0                	mov    %esi,%eax
  801d88:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d8b:	72 cc                	jb     801d59 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d8d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d90:	5b                   	pop    %ebx
  801d91:	5e                   	pop    %esi
  801d92:	5f                   	pop    %edi
  801d93:	5d                   	pop    %ebp
  801d94:	c3                   	ret    

00801d95 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d95:	55                   	push   %ebp
  801d96:	89 e5                	mov    %esp,%ebp
  801d98:	83 ec 08             	sub    $0x8,%esp
  801d9b:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801da0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801da4:	74 2a                	je     801dd0 <devcons_read+0x3b>
  801da6:	eb 05                	jmp    801dad <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801da8:	e8 49 ed ff ff       	call   800af6 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801dad:	e8 c5 ec ff ff       	call   800a77 <sys_cgetc>
  801db2:	85 c0                	test   %eax,%eax
  801db4:	74 f2                	je     801da8 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801db6:	85 c0                	test   %eax,%eax
  801db8:	78 16                	js     801dd0 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801dba:	83 f8 04             	cmp    $0x4,%eax
  801dbd:	74 0c                	je     801dcb <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801dbf:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dc2:	88 02                	mov    %al,(%edx)
	return 1;
  801dc4:	b8 01 00 00 00       	mov    $0x1,%eax
  801dc9:	eb 05                	jmp    801dd0 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801dcb:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801dd0:	c9                   	leave  
  801dd1:	c3                   	ret    

00801dd2 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801dd2:	55                   	push   %ebp
  801dd3:	89 e5                	mov    %esp,%ebp
  801dd5:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801dd8:	8b 45 08             	mov    0x8(%ebp),%eax
  801ddb:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801dde:	6a 01                	push   $0x1
  801de0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801de3:	50                   	push   %eax
  801de4:	e8 70 ec ff ff       	call   800a59 <sys_cputs>
}
  801de9:	83 c4 10             	add    $0x10,%esp
  801dec:	c9                   	leave  
  801ded:	c3                   	ret    

00801dee <getchar>:

int
getchar(void)
{
  801dee:	55                   	push   %ebp
  801def:	89 e5                	mov    %esp,%ebp
  801df1:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801df4:	6a 01                	push   $0x1
  801df6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801df9:	50                   	push   %eax
  801dfa:	6a 00                	push   $0x0
  801dfc:	e8 00 f2 ff ff       	call   801001 <read>
	if (r < 0)
  801e01:	83 c4 10             	add    $0x10,%esp
  801e04:	85 c0                	test   %eax,%eax
  801e06:	78 0f                	js     801e17 <getchar+0x29>
		return r;
	if (r < 1)
  801e08:	85 c0                	test   %eax,%eax
  801e0a:	7e 06                	jle    801e12 <getchar+0x24>
		return -E_EOF;
	return c;
  801e0c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e10:	eb 05                	jmp    801e17 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e12:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e17:	c9                   	leave  
  801e18:	c3                   	ret    

00801e19 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e19:	55                   	push   %ebp
  801e1a:	89 e5                	mov    %esp,%ebp
  801e1c:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e1f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e22:	50                   	push   %eax
  801e23:	ff 75 08             	pushl  0x8(%ebp)
  801e26:	e8 70 ef ff ff       	call   800d9b <fd_lookup>
  801e2b:	83 c4 10             	add    $0x10,%esp
  801e2e:	85 c0                	test   %eax,%eax
  801e30:	78 11                	js     801e43 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e32:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e35:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801e3b:	39 10                	cmp    %edx,(%eax)
  801e3d:	0f 94 c0             	sete   %al
  801e40:	0f b6 c0             	movzbl %al,%eax
}
  801e43:	c9                   	leave  
  801e44:	c3                   	ret    

00801e45 <opencons>:

int
opencons(void)
{
  801e45:	55                   	push   %ebp
  801e46:	89 e5                	mov    %esp,%ebp
  801e48:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e4b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e4e:	50                   	push   %eax
  801e4f:	e8 f8 ee ff ff       	call   800d4c <fd_alloc>
  801e54:	83 c4 10             	add    $0x10,%esp
		return r;
  801e57:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e59:	85 c0                	test   %eax,%eax
  801e5b:	78 3e                	js     801e9b <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e5d:	83 ec 04             	sub    $0x4,%esp
  801e60:	68 07 04 00 00       	push   $0x407
  801e65:	ff 75 f4             	pushl  -0xc(%ebp)
  801e68:	6a 00                	push   $0x0
  801e6a:	e8 a6 ec ff ff       	call   800b15 <sys_page_alloc>
  801e6f:	83 c4 10             	add    $0x10,%esp
		return r;
  801e72:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e74:	85 c0                	test   %eax,%eax
  801e76:	78 23                	js     801e9b <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e78:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801e7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e81:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e83:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e86:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e8d:	83 ec 0c             	sub    $0xc,%esp
  801e90:	50                   	push   %eax
  801e91:	e8 8f ee ff ff       	call   800d25 <fd2num>
  801e96:	89 c2                	mov    %eax,%edx
  801e98:	83 c4 10             	add    $0x10,%esp
}
  801e9b:	89 d0                	mov    %edx,%eax
  801e9d:	c9                   	leave  
  801e9e:	c3                   	ret    

00801e9f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801e9f:	55                   	push   %ebp
  801ea0:	89 e5                	mov    %esp,%ebp
  801ea2:	56                   	push   %esi
  801ea3:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801ea4:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801ea7:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801ead:	e8 25 ec ff ff       	call   800ad7 <sys_getenvid>
  801eb2:	83 ec 0c             	sub    $0xc,%esp
  801eb5:	ff 75 0c             	pushl  0xc(%ebp)
  801eb8:	ff 75 08             	pushl  0x8(%ebp)
  801ebb:	56                   	push   %esi
  801ebc:	50                   	push   %eax
  801ebd:	68 a0 27 80 00       	push   $0x8027a0
  801ec2:	e8 c6 e2 ff ff       	call   80018d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801ec7:	83 c4 18             	add    $0x18,%esp
  801eca:	53                   	push   %ebx
  801ecb:	ff 75 10             	pushl  0x10(%ebp)
  801ece:	e8 69 e2 ff ff       	call   80013c <vcprintf>
	cprintf("\n");
  801ed3:	c7 04 24 8c 27 80 00 	movl   $0x80278c,(%esp)
  801eda:	e8 ae e2 ff ff       	call   80018d <cprintf>
  801edf:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801ee2:	cc                   	int3   
  801ee3:	eb fd                	jmp    801ee2 <_panic+0x43>

00801ee5 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ee5:	55                   	push   %ebp
  801ee6:	89 e5                	mov    %esp,%ebp
  801ee8:	56                   	push   %esi
  801ee9:	53                   	push   %ebx
  801eea:	8b 75 08             	mov    0x8(%ebp),%esi
  801eed:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ef0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  801ef3:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801ef5:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801efa:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  801efd:	83 ec 0c             	sub    $0xc,%esp
  801f00:	50                   	push   %eax
  801f01:	e8 bf ed ff ff       	call   800cc5 <sys_ipc_recv>

	if (r < 0) {
  801f06:	83 c4 10             	add    $0x10,%esp
  801f09:	85 c0                	test   %eax,%eax
  801f0b:	79 16                	jns    801f23 <ipc_recv+0x3e>
		if (from_env_store)
  801f0d:	85 f6                	test   %esi,%esi
  801f0f:	74 06                	je     801f17 <ipc_recv+0x32>
			*from_env_store = 0;
  801f11:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  801f17:	85 db                	test   %ebx,%ebx
  801f19:	74 2c                	je     801f47 <ipc_recv+0x62>
			*perm_store = 0;
  801f1b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801f21:	eb 24                	jmp    801f47 <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  801f23:	85 f6                	test   %esi,%esi
  801f25:	74 0a                	je     801f31 <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  801f27:	a1 08 40 80 00       	mov    0x804008,%eax
  801f2c:	8b 40 74             	mov    0x74(%eax),%eax
  801f2f:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  801f31:	85 db                	test   %ebx,%ebx
  801f33:	74 0a                	je     801f3f <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  801f35:	a1 08 40 80 00       	mov    0x804008,%eax
  801f3a:	8b 40 78             	mov    0x78(%eax),%eax
  801f3d:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  801f3f:	a1 08 40 80 00       	mov    0x804008,%eax
  801f44:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  801f47:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f4a:	5b                   	pop    %ebx
  801f4b:	5e                   	pop    %esi
  801f4c:	5d                   	pop    %ebp
  801f4d:	c3                   	ret    

00801f4e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f4e:	55                   	push   %ebp
  801f4f:	89 e5                	mov    %esp,%ebp
  801f51:	57                   	push   %edi
  801f52:	56                   	push   %esi
  801f53:	53                   	push   %ebx
  801f54:	83 ec 0c             	sub    $0xc,%esp
  801f57:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f5a:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f5d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  801f60:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801f62:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801f67:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  801f6a:	ff 75 14             	pushl  0x14(%ebp)
  801f6d:	53                   	push   %ebx
  801f6e:	56                   	push   %esi
  801f6f:	57                   	push   %edi
  801f70:	e8 2d ed ff ff       	call   800ca2 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  801f75:	83 c4 10             	add    $0x10,%esp
  801f78:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f7b:	75 07                	jne    801f84 <ipc_send+0x36>
			sys_yield();
  801f7d:	e8 74 eb ff ff       	call   800af6 <sys_yield>
  801f82:	eb e6                	jmp    801f6a <ipc_send+0x1c>
		} else if (r < 0) {
  801f84:	85 c0                	test   %eax,%eax
  801f86:	79 12                	jns    801f9a <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  801f88:	50                   	push   %eax
  801f89:	68 c4 27 80 00       	push   $0x8027c4
  801f8e:	6a 51                	push   $0x51
  801f90:	68 d1 27 80 00       	push   $0x8027d1
  801f95:	e8 05 ff ff ff       	call   801e9f <_panic>
		}
	}
}
  801f9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f9d:	5b                   	pop    %ebx
  801f9e:	5e                   	pop    %esi
  801f9f:	5f                   	pop    %edi
  801fa0:	5d                   	pop    %ebp
  801fa1:	c3                   	ret    

00801fa2 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801fa2:	55                   	push   %ebp
  801fa3:	89 e5                	mov    %esp,%ebp
  801fa5:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801fa8:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801fad:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801fb0:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801fb6:	8b 52 50             	mov    0x50(%edx),%edx
  801fb9:	39 ca                	cmp    %ecx,%edx
  801fbb:	75 0d                	jne    801fca <ipc_find_env+0x28>
			return envs[i].env_id;
  801fbd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801fc0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801fc5:	8b 40 48             	mov    0x48(%eax),%eax
  801fc8:	eb 0f                	jmp    801fd9 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801fca:	83 c0 01             	add    $0x1,%eax
  801fcd:	3d 00 04 00 00       	cmp    $0x400,%eax
  801fd2:	75 d9                	jne    801fad <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801fd4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801fd9:	5d                   	pop    %ebp
  801fda:	c3                   	ret    

00801fdb <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fdb:	55                   	push   %ebp
  801fdc:	89 e5                	mov    %esp,%ebp
  801fde:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fe1:	89 d0                	mov    %edx,%eax
  801fe3:	c1 e8 16             	shr    $0x16,%eax
  801fe6:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801fed:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ff2:	f6 c1 01             	test   $0x1,%cl
  801ff5:	74 1d                	je     802014 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801ff7:	c1 ea 0c             	shr    $0xc,%edx
  801ffa:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802001:	f6 c2 01             	test   $0x1,%dl
  802004:	74 0e                	je     802014 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802006:	c1 ea 0c             	shr    $0xc,%edx
  802009:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802010:	ef 
  802011:	0f b7 c0             	movzwl %ax,%eax
}
  802014:	5d                   	pop    %ebp
  802015:	c3                   	ret    
  802016:	66 90                	xchg   %ax,%ax
  802018:	66 90                	xchg   %ax,%ax
  80201a:	66 90                	xchg   %ax,%ax
  80201c:	66 90                	xchg   %ax,%ax
  80201e:	66 90                	xchg   %ax,%ax

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
