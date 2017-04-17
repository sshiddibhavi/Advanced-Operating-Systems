
obj/user/spawnhello.debug:     file format elf32-i386


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
  80002c:	e8 4a 00 00 00       	call   80007b <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	int r;
	cprintf("i am parent environment %08x\n", thisenv->env_id);
  800039:	a1 08 40 80 00       	mov    0x804008,%eax
  80003e:	8b 40 48             	mov    0x48(%eax),%eax
  800041:	50                   	push   %eax
  800042:	68 40 28 80 00       	push   $0x802840
  800047:	e8 68 01 00 00       	call   8001b4 <cprintf>
	if ((r = spawnl("hello", "hello", 0)) < 0)
  80004c:	83 c4 0c             	add    $0xc,%esp
  80004f:	6a 00                	push   $0x0
  800051:	68 5e 28 80 00       	push   $0x80285e
  800056:	68 5e 28 80 00       	push   $0x80285e
  80005b:	e8 61 1a 00 00       	call   801ac1 <spawnl>
  800060:	83 c4 10             	add    $0x10,%esp
  800063:	85 c0                	test   %eax,%eax
  800065:	79 12                	jns    800079 <umain+0x46>
		panic("spawn(hello) failed: %e", r);
  800067:	50                   	push   %eax
  800068:	68 64 28 80 00       	push   $0x802864
  80006d:	6a 09                	push   $0x9
  80006f:	68 7c 28 80 00       	push   $0x80287c
  800074:	e8 62 00 00 00       	call   8000db <_panic>
}
  800079:	c9                   	leave  
  80007a:	c3                   	ret    

0080007b <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80007b:	55                   	push   %ebp
  80007c:	89 e5                	mov    %esp,%ebp
  80007e:	56                   	push   %esi
  80007f:	53                   	push   %ebx
  800080:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800083:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800086:	e8 73 0a 00 00       	call   800afe <sys_getenvid>
  80008b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800090:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800093:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800098:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80009d:	85 db                	test   %ebx,%ebx
  80009f:	7e 07                	jle    8000a8 <libmain+0x2d>
		binaryname = argv[0];
  8000a1:	8b 06                	mov    (%esi),%eax
  8000a3:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000a8:	83 ec 08             	sub    $0x8,%esp
  8000ab:	56                   	push   %esi
  8000ac:	53                   	push   %ebx
  8000ad:	e8 81 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000b2:	e8 0a 00 00 00       	call   8000c1 <exit>
}
  8000b7:	83 c4 10             	add    $0x10,%esp
  8000ba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000bd:	5b                   	pop    %ebx
  8000be:	5e                   	pop    %esi
  8000bf:	5d                   	pop    %ebp
  8000c0:	c3                   	ret    

008000c1 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c1:	55                   	push   %ebp
  8000c2:	89 e5                	mov    %esp,%ebp
  8000c4:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000c7:	e8 4b 0e 00 00       	call   800f17 <close_all>
	sys_env_destroy(0);
  8000cc:	83 ec 0c             	sub    $0xc,%esp
  8000cf:	6a 00                	push   $0x0
  8000d1:	e8 e7 09 00 00       	call   800abd <sys_env_destroy>
}
  8000d6:	83 c4 10             	add    $0x10,%esp
  8000d9:	c9                   	leave  
  8000da:	c3                   	ret    

008000db <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8000db:	55                   	push   %ebp
  8000dc:	89 e5                	mov    %esp,%ebp
  8000de:	56                   	push   %esi
  8000df:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8000e0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8000e3:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8000e9:	e8 10 0a 00 00       	call   800afe <sys_getenvid>
  8000ee:	83 ec 0c             	sub    $0xc,%esp
  8000f1:	ff 75 0c             	pushl  0xc(%ebp)
  8000f4:	ff 75 08             	pushl  0x8(%ebp)
  8000f7:	56                   	push   %esi
  8000f8:	50                   	push   %eax
  8000f9:	68 98 28 80 00       	push   $0x802898
  8000fe:	e8 b1 00 00 00       	call   8001b4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800103:	83 c4 18             	add    $0x18,%esp
  800106:	53                   	push   %ebx
  800107:	ff 75 10             	pushl  0x10(%ebp)
  80010a:	e8 54 00 00 00       	call   800163 <vcprintf>
	cprintf("\n");
  80010f:	c7 04 24 a9 2d 80 00 	movl   $0x802da9,(%esp)
  800116:	e8 99 00 00 00       	call   8001b4 <cprintf>
  80011b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80011e:	cc                   	int3   
  80011f:	eb fd                	jmp    80011e <_panic+0x43>

00800121 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800121:	55                   	push   %ebp
  800122:	89 e5                	mov    %esp,%ebp
  800124:	53                   	push   %ebx
  800125:	83 ec 04             	sub    $0x4,%esp
  800128:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80012b:	8b 13                	mov    (%ebx),%edx
  80012d:	8d 42 01             	lea    0x1(%edx),%eax
  800130:	89 03                	mov    %eax,(%ebx)
  800132:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800135:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800139:	3d ff 00 00 00       	cmp    $0xff,%eax
  80013e:	75 1a                	jne    80015a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800140:	83 ec 08             	sub    $0x8,%esp
  800143:	68 ff 00 00 00       	push   $0xff
  800148:	8d 43 08             	lea    0x8(%ebx),%eax
  80014b:	50                   	push   %eax
  80014c:	e8 2f 09 00 00       	call   800a80 <sys_cputs>
		b->idx = 0;
  800151:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800157:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80015a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80015e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800161:	c9                   	leave  
  800162:	c3                   	ret    

00800163 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800163:	55                   	push   %ebp
  800164:	89 e5                	mov    %esp,%ebp
  800166:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80016c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800173:	00 00 00 
	b.cnt = 0;
  800176:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80017d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800180:	ff 75 0c             	pushl  0xc(%ebp)
  800183:	ff 75 08             	pushl  0x8(%ebp)
  800186:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80018c:	50                   	push   %eax
  80018d:	68 21 01 80 00       	push   $0x800121
  800192:	e8 54 01 00 00       	call   8002eb <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800197:	83 c4 08             	add    $0x8,%esp
  80019a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001a0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001a6:	50                   	push   %eax
  8001a7:	e8 d4 08 00 00       	call   800a80 <sys_cputs>

	return b.cnt;
}
  8001ac:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001b2:	c9                   	leave  
  8001b3:	c3                   	ret    

008001b4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001b4:	55                   	push   %ebp
  8001b5:	89 e5                	mov    %esp,%ebp
  8001b7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ba:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001bd:	50                   	push   %eax
  8001be:	ff 75 08             	pushl  0x8(%ebp)
  8001c1:	e8 9d ff ff ff       	call   800163 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001c6:	c9                   	leave  
  8001c7:	c3                   	ret    

008001c8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c8:	55                   	push   %ebp
  8001c9:	89 e5                	mov    %esp,%ebp
  8001cb:	57                   	push   %edi
  8001cc:	56                   	push   %esi
  8001cd:	53                   	push   %ebx
  8001ce:	83 ec 1c             	sub    $0x1c,%esp
  8001d1:	89 c7                	mov    %eax,%edi
  8001d3:	89 d6                	mov    %edx,%esi
  8001d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001db:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001de:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001e1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001e4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001ec:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001ef:	39 d3                	cmp    %edx,%ebx
  8001f1:	72 05                	jb     8001f8 <printnum+0x30>
  8001f3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001f6:	77 45                	ja     80023d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001f8:	83 ec 0c             	sub    $0xc,%esp
  8001fb:	ff 75 18             	pushl  0x18(%ebp)
  8001fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800201:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800204:	53                   	push   %ebx
  800205:	ff 75 10             	pushl  0x10(%ebp)
  800208:	83 ec 08             	sub    $0x8,%esp
  80020b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80020e:	ff 75 e0             	pushl  -0x20(%ebp)
  800211:	ff 75 dc             	pushl  -0x24(%ebp)
  800214:	ff 75 d8             	pushl  -0x28(%ebp)
  800217:	e8 94 23 00 00       	call   8025b0 <__udivdi3>
  80021c:	83 c4 18             	add    $0x18,%esp
  80021f:	52                   	push   %edx
  800220:	50                   	push   %eax
  800221:	89 f2                	mov    %esi,%edx
  800223:	89 f8                	mov    %edi,%eax
  800225:	e8 9e ff ff ff       	call   8001c8 <printnum>
  80022a:	83 c4 20             	add    $0x20,%esp
  80022d:	eb 18                	jmp    800247 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80022f:	83 ec 08             	sub    $0x8,%esp
  800232:	56                   	push   %esi
  800233:	ff 75 18             	pushl  0x18(%ebp)
  800236:	ff d7                	call   *%edi
  800238:	83 c4 10             	add    $0x10,%esp
  80023b:	eb 03                	jmp    800240 <printnum+0x78>
  80023d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800240:	83 eb 01             	sub    $0x1,%ebx
  800243:	85 db                	test   %ebx,%ebx
  800245:	7f e8                	jg     80022f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800247:	83 ec 08             	sub    $0x8,%esp
  80024a:	56                   	push   %esi
  80024b:	83 ec 04             	sub    $0x4,%esp
  80024e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800251:	ff 75 e0             	pushl  -0x20(%ebp)
  800254:	ff 75 dc             	pushl  -0x24(%ebp)
  800257:	ff 75 d8             	pushl  -0x28(%ebp)
  80025a:	e8 81 24 00 00       	call   8026e0 <__umoddi3>
  80025f:	83 c4 14             	add    $0x14,%esp
  800262:	0f be 80 bb 28 80 00 	movsbl 0x8028bb(%eax),%eax
  800269:	50                   	push   %eax
  80026a:	ff d7                	call   *%edi
}
  80026c:	83 c4 10             	add    $0x10,%esp
  80026f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800272:	5b                   	pop    %ebx
  800273:	5e                   	pop    %esi
  800274:	5f                   	pop    %edi
  800275:	5d                   	pop    %ebp
  800276:	c3                   	ret    

00800277 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800277:	55                   	push   %ebp
  800278:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80027a:	83 fa 01             	cmp    $0x1,%edx
  80027d:	7e 0e                	jle    80028d <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80027f:	8b 10                	mov    (%eax),%edx
  800281:	8d 4a 08             	lea    0x8(%edx),%ecx
  800284:	89 08                	mov    %ecx,(%eax)
  800286:	8b 02                	mov    (%edx),%eax
  800288:	8b 52 04             	mov    0x4(%edx),%edx
  80028b:	eb 22                	jmp    8002af <getuint+0x38>
	else if (lflag)
  80028d:	85 d2                	test   %edx,%edx
  80028f:	74 10                	je     8002a1 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800291:	8b 10                	mov    (%eax),%edx
  800293:	8d 4a 04             	lea    0x4(%edx),%ecx
  800296:	89 08                	mov    %ecx,(%eax)
  800298:	8b 02                	mov    (%edx),%eax
  80029a:	ba 00 00 00 00       	mov    $0x0,%edx
  80029f:	eb 0e                	jmp    8002af <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002a1:	8b 10                	mov    (%eax),%edx
  8002a3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a6:	89 08                	mov    %ecx,(%eax)
  8002a8:	8b 02                	mov    (%edx),%eax
  8002aa:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002af:	5d                   	pop    %ebp
  8002b0:	c3                   	ret    

008002b1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
  8002b4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002b7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002bb:	8b 10                	mov    (%eax),%edx
  8002bd:	3b 50 04             	cmp    0x4(%eax),%edx
  8002c0:	73 0a                	jae    8002cc <sprintputch+0x1b>
		*b->buf++ = ch;
  8002c2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002c5:	89 08                	mov    %ecx,(%eax)
  8002c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ca:	88 02                	mov    %al,(%edx)
}
  8002cc:	5d                   	pop    %ebp
  8002cd:	c3                   	ret    

008002ce <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002ce:	55                   	push   %ebp
  8002cf:	89 e5                	mov    %esp,%ebp
  8002d1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002d4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002d7:	50                   	push   %eax
  8002d8:	ff 75 10             	pushl  0x10(%ebp)
  8002db:	ff 75 0c             	pushl  0xc(%ebp)
  8002de:	ff 75 08             	pushl  0x8(%ebp)
  8002e1:	e8 05 00 00 00       	call   8002eb <vprintfmt>
	va_end(ap);
}
  8002e6:	83 c4 10             	add    $0x10,%esp
  8002e9:	c9                   	leave  
  8002ea:	c3                   	ret    

008002eb <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002eb:	55                   	push   %ebp
  8002ec:	89 e5                	mov    %esp,%ebp
  8002ee:	57                   	push   %edi
  8002ef:	56                   	push   %esi
  8002f0:	53                   	push   %ebx
  8002f1:	83 ec 2c             	sub    $0x2c,%esp
  8002f4:	8b 75 08             	mov    0x8(%ebp),%esi
  8002f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002fa:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002fd:	eb 12                	jmp    800311 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002ff:	85 c0                	test   %eax,%eax
  800301:	0f 84 89 03 00 00    	je     800690 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800307:	83 ec 08             	sub    $0x8,%esp
  80030a:	53                   	push   %ebx
  80030b:	50                   	push   %eax
  80030c:	ff d6                	call   *%esi
  80030e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800311:	83 c7 01             	add    $0x1,%edi
  800314:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800318:	83 f8 25             	cmp    $0x25,%eax
  80031b:	75 e2                	jne    8002ff <vprintfmt+0x14>
  80031d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800321:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800328:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80032f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800336:	ba 00 00 00 00       	mov    $0x0,%edx
  80033b:	eb 07                	jmp    800344 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800340:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800344:	8d 47 01             	lea    0x1(%edi),%eax
  800347:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80034a:	0f b6 07             	movzbl (%edi),%eax
  80034d:	0f b6 c8             	movzbl %al,%ecx
  800350:	83 e8 23             	sub    $0x23,%eax
  800353:	3c 55                	cmp    $0x55,%al
  800355:	0f 87 1a 03 00 00    	ja     800675 <vprintfmt+0x38a>
  80035b:	0f b6 c0             	movzbl %al,%eax
  80035e:	ff 24 85 00 2a 80 00 	jmp    *0x802a00(,%eax,4)
  800365:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800368:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80036c:	eb d6                	jmp    800344 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800371:	b8 00 00 00 00       	mov    $0x0,%eax
  800376:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800379:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80037c:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800380:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800383:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800386:	83 fa 09             	cmp    $0x9,%edx
  800389:	77 39                	ja     8003c4 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80038b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80038e:	eb e9                	jmp    800379 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800390:	8b 45 14             	mov    0x14(%ebp),%eax
  800393:	8d 48 04             	lea    0x4(%eax),%ecx
  800396:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800399:	8b 00                	mov    (%eax),%eax
  80039b:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003a1:	eb 27                	jmp    8003ca <vprintfmt+0xdf>
  8003a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003a6:	85 c0                	test   %eax,%eax
  8003a8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003ad:	0f 49 c8             	cmovns %eax,%ecx
  8003b0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003b6:	eb 8c                	jmp    800344 <vprintfmt+0x59>
  8003b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003bb:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003c2:	eb 80                	jmp    800344 <vprintfmt+0x59>
  8003c4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003c7:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003ca:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003ce:	0f 89 70 ff ff ff    	jns    800344 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003d4:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003d7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003da:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003e1:	e9 5e ff ff ff       	jmp    800344 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003e6:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003ec:	e9 53 ff ff ff       	jmp    800344 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f4:	8d 50 04             	lea    0x4(%eax),%edx
  8003f7:	89 55 14             	mov    %edx,0x14(%ebp)
  8003fa:	83 ec 08             	sub    $0x8,%esp
  8003fd:	53                   	push   %ebx
  8003fe:	ff 30                	pushl  (%eax)
  800400:	ff d6                	call   *%esi
			break;
  800402:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800405:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800408:	e9 04 ff ff ff       	jmp    800311 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80040d:	8b 45 14             	mov    0x14(%ebp),%eax
  800410:	8d 50 04             	lea    0x4(%eax),%edx
  800413:	89 55 14             	mov    %edx,0x14(%ebp)
  800416:	8b 00                	mov    (%eax),%eax
  800418:	99                   	cltd   
  800419:	31 d0                	xor    %edx,%eax
  80041b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80041d:	83 f8 0f             	cmp    $0xf,%eax
  800420:	7f 0b                	jg     80042d <vprintfmt+0x142>
  800422:	8b 14 85 60 2b 80 00 	mov    0x802b60(,%eax,4),%edx
  800429:	85 d2                	test   %edx,%edx
  80042b:	75 18                	jne    800445 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80042d:	50                   	push   %eax
  80042e:	68 d3 28 80 00       	push   $0x8028d3
  800433:	53                   	push   %ebx
  800434:	56                   	push   %esi
  800435:	e8 94 fe ff ff       	call   8002ce <printfmt>
  80043a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800440:	e9 cc fe ff ff       	jmp    800311 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800445:	52                   	push   %edx
  800446:	68 9a 2c 80 00       	push   $0x802c9a
  80044b:	53                   	push   %ebx
  80044c:	56                   	push   %esi
  80044d:	e8 7c fe ff ff       	call   8002ce <printfmt>
  800452:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800455:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800458:	e9 b4 fe ff ff       	jmp    800311 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80045d:	8b 45 14             	mov    0x14(%ebp),%eax
  800460:	8d 50 04             	lea    0x4(%eax),%edx
  800463:	89 55 14             	mov    %edx,0x14(%ebp)
  800466:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800468:	85 ff                	test   %edi,%edi
  80046a:	b8 cc 28 80 00       	mov    $0x8028cc,%eax
  80046f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800472:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800476:	0f 8e 94 00 00 00    	jle    800510 <vprintfmt+0x225>
  80047c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800480:	0f 84 98 00 00 00    	je     80051e <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800486:	83 ec 08             	sub    $0x8,%esp
  800489:	ff 75 d0             	pushl  -0x30(%ebp)
  80048c:	57                   	push   %edi
  80048d:	e8 86 02 00 00       	call   800718 <strnlen>
  800492:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800495:	29 c1                	sub    %eax,%ecx
  800497:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80049a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80049d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004a1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004a4:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004a7:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a9:	eb 0f                	jmp    8004ba <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004ab:	83 ec 08             	sub    $0x8,%esp
  8004ae:	53                   	push   %ebx
  8004af:	ff 75 e0             	pushl  -0x20(%ebp)
  8004b2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b4:	83 ef 01             	sub    $0x1,%edi
  8004b7:	83 c4 10             	add    $0x10,%esp
  8004ba:	85 ff                	test   %edi,%edi
  8004bc:	7f ed                	jg     8004ab <vprintfmt+0x1c0>
  8004be:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004c1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004c4:	85 c9                	test   %ecx,%ecx
  8004c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8004cb:	0f 49 c1             	cmovns %ecx,%eax
  8004ce:	29 c1                	sub    %eax,%ecx
  8004d0:	89 75 08             	mov    %esi,0x8(%ebp)
  8004d3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004d6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004d9:	89 cb                	mov    %ecx,%ebx
  8004db:	eb 4d                	jmp    80052a <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004dd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004e1:	74 1b                	je     8004fe <vprintfmt+0x213>
  8004e3:	0f be c0             	movsbl %al,%eax
  8004e6:	83 e8 20             	sub    $0x20,%eax
  8004e9:	83 f8 5e             	cmp    $0x5e,%eax
  8004ec:	76 10                	jbe    8004fe <vprintfmt+0x213>
					putch('?', putdat);
  8004ee:	83 ec 08             	sub    $0x8,%esp
  8004f1:	ff 75 0c             	pushl  0xc(%ebp)
  8004f4:	6a 3f                	push   $0x3f
  8004f6:	ff 55 08             	call   *0x8(%ebp)
  8004f9:	83 c4 10             	add    $0x10,%esp
  8004fc:	eb 0d                	jmp    80050b <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004fe:	83 ec 08             	sub    $0x8,%esp
  800501:	ff 75 0c             	pushl  0xc(%ebp)
  800504:	52                   	push   %edx
  800505:	ff 55 08             	call   *0x8(%ebp)
  800508:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80050b:	83 eb 01             	sub    $0x1,%ebx
  80050e:	eb 1a                	jmp    80052a <vprintfmt+0x23f>
  800510:	89 75 08             	mov    %esi,0x8(%ebp)
  800513:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800516:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800519:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80051c:	eb 0c                	jmp    80052a <vprintfmt+0x23f>
  80051e:	89 75 08             	mov    %esi,0x8(%ebp)
  800521:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800524:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800527:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80052a:	83 c7 01             	add    $0x1,%edi
  80052d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800531:	0f be d0             	movsbl %al,%edx
  800534:	85 d2                	test   %edx,%edx
  800536:	74 23                	je     80055b <vprintfmt+0x270>
  800538:	85 f6                	test   %esi,%esi
  80053a:	78 a1                	js     8004dd <vprintfmt+0x1f2>
  80053c:	83 ee 01             	sub    $0x1,%esi
  80053f:	79 9c                	jns    8004dd <vprintfmt+0x1f2>
  800541:	89 df                	mov    %ebx,%edi
  800543:	8b 75 08             	mov    0x8(%ebp),%esi
  800546:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800549:	eb 18                	jmp    800563 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80054b:	83 ec 08             	sub    $0x8,%esp
  80054e:	53                   	push   %ebx
  80054f:	6a 20                	push   $0x20
  800551:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800553:	83 ef 01             	sub    $0x1,%edi
  800556:	83 c4 10             	add    $0x10,%esp
  800559:	eb 08                	jmp    800563 <vprintfmt+0x278>
  80055b:	89 df                	mov    %ebx,%edi
  80055d:	8b 75 08             	mov    0x8(%ebp),%esi
  800560:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800563:	85 ff                	test   %edi,%edi
  800565:	7f e4                	jg     80054b <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800567:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80056a:	e9 a2 fd ff ff       	jmp    800311 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80056f:	83 fa 01             	cmp    $0x1,%edx
  800572:	7e 16                	jle    80058a <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800574:	8b 45 14             	mov    0x14(%ebp),%eax
  800577:	8d 50 08             	lea    0x8(%eax),%edx
  80057a:	89 55 14             	mov    %edx,0x14(%ebp)
  80057d:	8b 50 04             	mov    0x4(%eax),%edx
  800580:	8b 00                	mov    (%eax),%eax
  800582:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800585:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800588:	eb 32                	jmp    8005bc <vprintfmt+0x2d1>
	else if (lflag)
  80058a:	85 d2                	test   %edx,%edx
  80058c:	74 18                	je     8005a6 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80058e:	8b 45 14             	mov    0x14(%ebp),%eax
  800591:	8d 50 04             	lea    0x4(%eax),%edx
  800594:	89 55 14             	mov    %edx,0x14(%ebp)
  800597:	8b 00                	mov    (%eax),%eax
  800599:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80059c:	89 c1                	mov    %eax,%ecx
  80059e:	c1 f9 1f             	sar    $0x1f,%ecx
  8005a1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005a4:	eb 16                	jmp    8005bc <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a9:	8d 50 04             	lea    0x4(%eax),%edx
  8005ac:	89 55 14             	mov    %edx,0x14(%ebp)
  8005af:	8b 00                	mov    (%eax),%eax
  8005b1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b4:	89 c1                	mov    %eax,%ecx
  8005b6:	c1 f9 1f             	sar    $0x1f,%ecx
  8005b9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005bc:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005bf:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005c2:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005c7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005cb:	79 74                	jns    800641 <vprintfmt+0x356>
				putch('-', putdat);
  8005cd:	83 ec 08             	sub    $0x8,%esp
  8005d0:	53                   	push   %ebx
  8005d1:	6a 2d                	push   $0x2d
  8005d3:	ff d6                	call   *%esi
				num = -(long long) num;
  8005d5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005d8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005db:	f7 d8                	neg    %eax
  8005dd:	83 d2 00             	adc    $0x0,%edx
  8005e0:	f7 da                	neg    %edx
  8005e2:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005e5:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005ea:	eb 55                	jmp    800641 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005ec:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ef:	e8 83 fc ff ff       	call   800277 <getuint>
			base = 10;
  8005f4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005f9:	eb 46                	jmp    800641 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005fb:	8d 45 14             	lea    0x14(%ebp),%eax
  8005fe:	e8 74 fc ff ff       	call   800277 <getuint>
                        base = 8;
  800603:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800608:	eb 37                	jmp    800641 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80060a:	83 ec 08             	sub    $0x8,%esp
  80060d:	53                   	push   %ebx
  80060e:	6a 30                	push   $0x30
  800610:	ff d6                	call   *%esi
			putch('x', putdat);
  800612:	83 c4 08             	add    $0x8,%esp
  800615:	53                   	push   %ebx
  800616:	6a 78                	push   $0x78
  800618:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80061a:	8b 45 14             	mov    0x14(%ebp),%eax
  80061d:	8d 50 04             	lea    0x4(%eax),%edx
  800620:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800623:	8b 00                	mov    (%eax),%eax
  800625:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80062a:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80062d:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800632:	eb 0d                	jmp    800641 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800634:	8d 45 14             	lea    0x14(%ebp),%eax
  800637:	e8 3b fc ff ff       	call   800277 <getuint>
			base = 16;
  80063c:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800641:	83 ec 0c             	sub    $0xc,%esp
  800644:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800648:	57                   	push   %edi
  800649:	ff 75 e0             	pushl  -0x20(%ebp)
  80064c:	51                   	push   %ecx
  80064d:	52                   	push   %edx
  80064e:	50                   	push   %eax
  80064f:	89 da                	mov    %ebx,%edx
  800651:	89 f0                	mov    %esi,%eax
  800653:	e8 70 fb ff ff       	call   8001c8 <printnum>
			break;
  800658:	83 c4 20             	add    $0x20,%esp
  80065b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80065e:	e9 ae fc ff ff       	jmp    800311 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800663:	83 ec 08             	sub    $0x8,%esp
  800666:	53                   	push   %ebx
  800667:	51                   	push   %ecx
  800668:	ff d6                	call   *%esi
			break;
  80066a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80066d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800670:	e9 9c fc ff ff       	jmp    800311 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800675:	83 ec 08             	sub    $0x8,%esp
  800678:	53                   	push   %ebx
  800679:	6a 25                	push   $0x25
  80067b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80067d:	83 c4 10             	add    $0x10,%esp
  800680:	eb 03                	jmp    800685 <vprintfmt+0x39a>
  800682:	83 ef 01             	sub    $0x1,%edi
  800685:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800689:	75 f7                	jne    800682 <vprintfmt+0x397>
  80068b:	e9 81 fc ff ff       	jmp    800311 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800690:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800693:	5b                   	pop    %ebx
  800694:	5e                   	pop    %esi
  800695:	5f                   	pop    %edi
  800696:	5d                   	pop    %ebp
  800697:	c3                   	ret    

00800698 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800698:	55                   	push   %ebp
  800699:	89 e5                	mov    %esp,%ebp
  80069b:	83 ec 18             	sub    $0x18,%esp
  80069e:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006a4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006a7:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006ab:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006ae:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006b5:	85 c0                	test   %eax,%eax
  8006b7:	74 26                	je     8006df <vsnprintf+0x47>
  8006b9:	85 d2                	test   %edx,%edx
  8006bb:	7e 22                	jle    8006df <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006bd:	ff 75 14             	pushl  0x14(%ebp)
  8006c0:	ff 75 10             	pushl  0x10(%ebp)
  8006c3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006c6:	50                   	push   %eax
  8006c7:	68 b1 02 80 00       	push   $0x8002b1
  8006cc:	e8 1a fc ff ff       	call   8002eb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006d1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006d4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006da:	83 c4 10             	add    $0x10,%esp
  8006dd:	eb 05                	jmp    8006e4 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006df:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006e4:	c9                   	leave  
  8006e5:	c3                   	ret    

008006e6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006e6:	55                   	push   %ebp
  8006e7:	89 e5                	mov    %esp,%ebp
  8006e9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006ec:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006ef:	50                   	push   %eax
  8006f0:	ff 75 10             	pushl  0x10(%ebp)
  8006f3:	ff 75 0c             	pushl  0xc(%ebp)
  8006f6:	ff 75 08             	pushl  0x8(%ebp)
  8006f9:	e8 9a ff ff ff       	call   800698 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006fe:	c9                   	leave  
  8006ff:	c3                   	ret    

00800700 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800700:	55                   	push   %ebp
  800701:	89 e5                	mov    %esp,%ebp
  800703:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800706:	b8 00 00 00 00       	mov    $0x0,%eax
  80070b:	eb 03                	jmp    800710 <strlen+0x10>
		n++;
  80070d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800710:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800714:	75 f7                	jne    80070d <strlen+0xd>
		n++;
	return n;
}
  800716:	5d                   	pop    %ebp
  800717:	c3                   	ret    

00800718 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800718:	55                   	push   %ebp
  800719:	89 e5                	mov    %esp,%ebp
  80071b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80071e:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800721:	ba 00 00 00 00       	mov    $0x0,%edx
  800726:	eb 03                	jmp    80072b <strnlen+0x13>
		n++;
  800728:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80072b:	39 c2                	cmp    %eax,%edx
  80072d:	74 08                	je     800737 <strnlen+0x1f>
  80072f:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800733:	75 f3                	jne    800728 <strnlen+0x10>
  800735:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800737:	5d                   	pop    %ebp
  800738:	c3                   	ret    

00800739 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800739:	55                   	push   %ebp
  80073a:	89 e5                	mov    %esp,%ebp
  80073c:	53                   	push   %ebx
  80073d:	8b 45 08             	mov    0x8(%ebp),%eax
  800740:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800743:	89 c2                	mov    %eax,%edx
  800745:	83 c2 01             	add    $0x1,%edx
  800748:	83 c1 01             	add    $0x1,%ecx
  80074b:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80074f:	88 5a ff             	mov    %bl,-0x1(%edx)
  800752:	84 db                	test   %bl,%bl
  800754:	75 ef                	jne    800745 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800756:	5b                   	pop    %ebx
  800757:	5d                   	pop    %ebp
  800758:	c3                   	ret    

00800759 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800759:	55                   	push   %ebp
  80075a:	89 e5                	mov    %esp,%ebp
  80075c:	53                   	push   %ebx
  80075d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800760:	53                   	push   %ebx
  800761:	e8 9a ff ff ff       	call   800700 <strlen>
  800766:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800769:	ff 75 0c             	pushl  0xc(%ebp)
  80076c:	01 d8                	add    %ebx,%eax
  80076e:	50                   	push   %eax
  80076f:	e8 c5 ff ff ff       	call   800739 <strcpy>
	return dst;
}
  800774:	89 d8                	mov    %ebx,%eax
  800776:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800779:	c9                   	leave  
  80077a:	c3                   	ret    

0080077b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80077b:	55                   	push   %ebp
  80077c:	89 e5                	mov    %esp,%ebp
  80077e:	56                   	push   %esi
  80077f:	53                   	push   %ebx
  800780:	8b 75 08             	mov    0x8(%ebp),%esi
  800783:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800786:	89 f3                	mov    %esi,%ebx
  800788:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80078b:	89 f2                	mov    %esi,%edx
  80078d:	eb 0f                	jmp    80079e <strncpy+0x23>
		*dst++ = *src;
  80078f:	83 c2 01             	add    $0x1,%edx
  800792:	0f b6 01             	movzbl (%ecx),%eax
  800795:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800798:	80 39 01             	cmpb   $0x1,(%ecx)
  80079b:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80079e:	39 da                	cmp    %ebx,%edx
  8007a0:	75 ed                	jne    80078f <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007a2:	89 f0                	mov    %esi,%eax
  8007a4:	5b                   	pop    %ebx
  8007a5:	5e                   	pop    %esi
  8007a6:	5d                   	pop    %ebp
  8007a7:	c3                   	ret    

008007a8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007a8:	55                   	push   %ebp
  8007a9:	89 e5                	mov    %esp,%ebp
  8007ab:	56                   	push   %esi
  8007ac:	53                   	push   %ebx
  8007ad:	8b 75 08             	mov    0x8(%ebp),%esi
  8007b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007b3:	8b 55 10             	mov    0x10(%ebp),%edx
  8007b6:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007b8:	85 d2                	test   %edx,%edx
  8007ba:	74 21                	je     8007dd <strlcpy+0x35>
  8007bc:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007c0:	89 f2                	mov    %esi,%edx
  8007c2:	eb 09                	jmp    8007cd <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007c4:	83 c2 01             	add    $0x1,%edx
  8007c7:	83 c1 01             	add    $0x1,%ecx
  8007ca:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007cd:	39 c2                	cmp    %eax,%edx
  8007cf:	74 09                	je     8007da <strlcpy+0x32>
  8007d1:	0f b6 19             	movzbl (%ecx),%ebx
  8007d4:	84 db                	test   %bl,%bl
  8007d6:	75 ec                	jne    8007c4 <strlcpy+0x1c>
  8007d8:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007da:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007dd:	29 f0                	sub    %esi,%eax
}
  8007df:	5b                   	pop    %ebx
  8007e0:	5e                   	pop    %esi
  8007e1:	5d                   	pop    %ebp
  8007e2:	c3                   	ret    

008007e3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007e3:	55                   	push   %ebp
  8007e4:	89 e5                	mov    %esp,%ebp
  8007e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007ec:	eb 06                	jmp    8007f4 <strcmp+0x11>
		p++, q++;
  8007ee:	83 c1 01             	add    $0x1,%ecx
  8007f1:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007f4:	0f b6 01             	movzbl (%ecx),%eax
  8007f7:	84 c0                	test   %al,%al
  8007f9:	74 04                	je     8007ff <strcmp+0x1c>
  8007fb:	3a 02                	cmp    (%edx),%al
  8007fd:	74 ef                	je     8007ee <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007ff:	0f b6 c0             	movzbl %al,%eax
  800802:	0f b6 12             	movzbl (%edx),%edx
  800805:	29 d0                	sub    %edx,%eax
}
  800807:	5d                   	pop    %ebp
  800808:	c3                   	ret    

00800809 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800809:	55                   	push   %ebp
  80080a:	89 e5                	mov    %esp,%ebp
  80080c:	53                   	push   %ebx
  80080d:	8b 45 08             	mov    0x8(%ebp),%eax
  800810:	8b 55 0c             	mov    0xc(%ebp),%edx
  800813:	89 c3                	mov    %eax,%ebx
  800815:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800818:	eb 06                	jmp    800820 <strncmp+0x17>
		n--, p++, q++;
  80081a:	83 c0 01             	add    $0x1,%eax
  80081d:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800820:	39 d8                	cmp    %ebx,%eax
  800822:	74 15                	je     800839 <strncmp+0x30>
  800824:	0f b6 08             	movzbl (%eax),%ecx
  800827:	84 c9                	test   %cl,%cl
  800829:	74 04                	je     80082f <strncmp+0x26>
  80082b:	3a 0a                	cmp    (%edx),%cl
  80082d:	74 eb                	je     80081a <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80082f:	0f b6 00             	movzbl (%eax),%eax
  800832:	0f b6 12             	movzbl (%edx),%edx
  800835:	29 d0                	sub    %edx,%eax
  800837:	eb 05                	jmp    80083e <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800839:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80083e:	5b                   	pop    %ebx
  80083f:	5d                   	pop    %ebp
  800840:	c3                   	ret    

00800841 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800841:	55                   	push   %ebp
  800842:	89 e5                	mov    %esp,%ebp
  800844:	8b 45 08             	mov    0x8(%ebp),%eax
  800847:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80084b:	eb 07                	jmp    800854 <strchr+0x13>
		if (*s == c)
  80084d:	38 ca                	cmp    %cl,%dl
  80084f:	74 0f                	je     800860 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800851:	83 c0 01             	add    $0x1,%eax
  800854:	0f b6 10             	movzbl (%eax),%edx
  800857:	84 d2                	test   %dl,%dl
  800859:	75 f2                	jne    80084d <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80085b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800860:	5d                   	pop    %ebp
  800861:	c3                   	ret    

00800862 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800862:	55                   	push   %ebp
  800863:	89 e5                	mov    %esp,%ebp
  800865:	8b 45 08             	mov    0x8(%ebp),%eax
  800868:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80086c:	eb 03                	jmp    800871 <strfind+0xf>
  80086e:	83 c0 01             	add    $0x1,%eax
  800871:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800874:	38 ca                	cmp    %cl,%dl
  800876:	74 04                	je     80087c <strfind+0x1a>
  800878:	84 d2                	test   %dl,%dl
  80087a:	75 f2                	jne    80086e <strfind+0xc>
			break;
	return (char *) s;
}
  80087c:	5d                   	pop    %ebp
  80087d:	c3                   	ret    

0080087e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80087e:	55                   	push   %ebp
  80087f:	89 e5                	mov    %esp,%ebp
  800881:	57                   	push   %edi
  800882:	56                   	push   %esi
  800883:	53                   	push   %ebx
  800884:	8b 7d 08             	mov    0x8(%ebp),%edi
  800887:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80088a:	85 c9                	test   %ecx,%ecx
  80088c:	74 36                	je     8008c4 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80088e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800894:	75 28                	jne    8008be <memset+0x40>
  800896:	f6 c1 03             	test   $0x3,%cl
  800899:	75 23                	jne    8008be <memset+0x40>
		c &= 0xFF;
  80089b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80089f:	89 d3                	mov    %edx,%ebx
  8008a1:	c1 e3 08             	shl    $0x8,%ebx
  8008a4:	89 d6                	mov    %edx,%esi
  8008a6:	c1 e6 18             	shl    $0x18,%esi
  8008a9:	89 d0                	mov    %edx,%eax
  8008ab:	c1 e0 10             	shl    $0x10,%eax
  8008ae:	09 f0                	or     %esi,%eax
  8008b0:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008b2:	89 d8                	mov    %ebx,%eax
  8008b4:	09 d0                	or     %edx,%eax
  8008b6:	c1 e9 02             	shr    $0x2,%ecx
  8008b9:	fc                   	cld    
  8008ba:	f3 ab                	rep stos %eax,%es:(%edi)
  8008bc:	eb 06                	jmp    8008c4 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008c1:	fc                   	cld    
  8008c2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008c4:	89 f8                	mov    %edi,%eax
  8008c6:	5b                   	pop    %ebx
  8008c7:	5e                   	pop    %esi
  8008c8:	5f                   	pop    %edi
  8008c9:	5d                   	pop    %ebp
  8008ca:	c3                   	ret    

008008cb <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008cb:	55                   	push   %ebp
  8008cc:	89 e5                	mov    %esp,%ebp
  8008ce:	57                   	push   %edi
  8008cf:	56                   	push   %esi
  8008d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008d6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008d9:	39 c6                	cmp    %eax,%esi
  8008db:	73 35                	jae    800912 <memmove+0x47>
  8008dd:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008e0:	39 d0                	cmp    %edx,%eax
  8008e2:	73 2e                	jae    800912 <memmove+0x47>
		s += n;
		d += n;
  8008e4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008e7:	89 d6                	mov    %edx,%esi
  8008e9:	09 fe                	or     %edi,%esi
  8008eb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008f1:	75 13                	jne    800906 <memmove+0x3b>
  8008f3:	f6 c1 03             	test   $0x3,%cl
  8008f6:	75 0e                	jne    800906 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008f8:	83 ef 04             	sub    $0x4,%edi
  8008fb:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008fe:	c1 e9 02             	shr    $0x2,%ecx
  800901:	fd                   	std    
  800902:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800904:	eb 09                	jmp    80090f <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800906:	83 ef 01             	sub    $0x1,%edi
  800909:	8d 72 ff             	lea    -0x1(%edx),%esi
  80090c:	fd                   	std    
  80090d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80090f:	fc                   	cld    
  800910:	eb 1d                	jmp    80092f <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800912:	89 f2                	mov    %esi,%edx
  800914:	09 c2                	or     %eax,%edx
  800916:	f6 c2 03             	test   $0x3,%dl
  800919:	75 0f                	jne    80092a <memmove+0x5f>
  80091b:	f6 c1 03             	test   $0x3,%cl
  80091e:	75 0a                	jne    80092a <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800920:	c1 e9 02             	shr    $0x2,%ecx
  800923:	89 c7                	mov    %eax,%edi
  800925:	fc                   	cld    
  800926:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800928:	eb 05                	jmp    80092f <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80092a:	89 c7                	mov    %eax,%edi
  80092c:	fc                   	cld    
  80092d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80092f:	5e                   	pop    %esi
  800930:	5f                   	pop    %edi
  800931:	5d                   	pop    %ebp
  800932:	c3                   	ret    

00800933 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800933:	55                   	push   %ebp
  800934:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800936:	ff 75 10             	pushl  0x10(%ebp)
  800939:	ff 75 0c             	pushl  0xc(%ebp)
  80093c:	ff 75 08             	pushl  0x8(%ebp)
  80093f:	e8 87 ff ff ff       	call   8008cb <memmove>
}
  800944:	c9                   	leave  
  800945:	c3                   	ret    

00800946 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800946:	55                   	push   %ebp
  800947:	89 e5                	mov    %esp,%ebp
  800949:	56                   	push   %esi
  80094a:	53                   	push   %ebx
  80094b:	8b 45 08             	mov    0x8(%ebp),%eax
  80094e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800951:	89 c6                	mov    %eax,%esi
  800953:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800956:	eb 1a                	jmp    800972 <memcmp+0x2c>
		if (*s1 != *s2)
  800958:	0f b6 08             	movzbl (%eax),%ecx
  80095b:	0f b6 1a             	movzbl (%edx),%ebx
  80095e:	38 d9                	cmp    %bl,%cl
  800960:	74 0a                	je     80096c <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800962:	0f b6 c1             	movzbl %cl,%eax
  800965:	0f b6 db             	movzbl %bl,%ebx
  800968:	29 d8                	sub    %ebx,%eax
  80096a:	eb 0f                	jmp    80097b <memcmp+0x35>
		s1++, s2++;
  80096c:	83 c0 01             	add    $0x1,%eax
  80096f:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800972:	39 f0                	cmp    %esi,%eax
  800974:	75 e2                	jne    800958 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800976:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80097b:	5b                   	pop    %ebx
  80097c:	5e                   	pop    %esi
  80097d:	5d                   	pop    %ebp
  80097e:	c3                   	ret    

0080097f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	53                   	push   %ebx
  800983:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800986:	89 c1                	mov    %eax,%ecx
  800988:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80098b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80098f:	eb 0a                	jmp    80099b <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800991:	0f b6 10             	movzbl (%eax),%edx
  800994:	39 da                	cmp    %ebx,%edx
  800996:	74 07                	je     80099f <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800998:	83 c0 01             	add    $0x1,%eax
  80099b:	39 c8                	cmp    %ecx,%eax
  80099d:	72 f2                	jb     800991 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80099f:	5b                   	pop    %ebx
  8009a0:	5d                   	pop    %ebp
  8009a1:	c3                   	ret    

008009a2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009a2:	55                   	push   %ebp
  8009a3:	89 e5                	mov    %esp,%ebp
  8009a5:	57                   	push   %edi
  8009a6:	56                   	push   %esi
  8009a7:	53                   	push   %ebx
  8009a8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009ab:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ae:	eb 03                	jmp    8009b3 <strtol+0x11>
		s++;
  8009b0:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009b3:	0f b6 01             	movzbl (%ecx),%eax
  8009b6:	3c 20                	cmp    $0x20,%al
  8009b8:	74 f6                	je     8009b0 <strtol+0xe>
  8009ba:	3c 09                	cmp    $0x9,%al
  8009bc:	74 f2                	je     8009b0 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009be:	3c 2b                	cmp    $0x2b,%al
  8009c0:	75 0a                	jne    8009cc <strtol+0x2a>
		s++;
  8009c2:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009c5:	bf 00 00 00 00       	mov    $0x0,%edi
  8009ca:	eb 11                	jmp    8009dd <strtol+0x3b>
  8009cc:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009d1:	3c 2d                	cmp    $0x2d,%al
  8009d3:	75 08                	jne    8009dd <strtol+0x3b>
		s++, neg = 1;
  8009d5:	83 c1 01             	add    $0x1,%ecx
  8009d8:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009dd:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009e3:	75 15                	jne    8009fa <strtol+0x58>
  8009e5:	80 39 30             	cmpb   $0x30,(%ecx)
  8009e8:	75 10                	jne    8009fa <strtol+0x58>
  8009ea:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009ee:	75 7c                	jne    800a6c <strtol+0xca>
		s += 2, base = 16;
  8009f0:	83 c1 02             	add    $0x2,%ecx
  8009f3:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009f8:	eb 16                	jmp    800a10 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009fa:	85 db                	test   %ebx,%ebx
  8009fc:	75 12                	jne    800a10 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009fe:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a03:	80 39 30             	cmpb   $0x30,(%ecx)
  800a06:	75 08                	jne    800a10 <strtol+0x6e>
		s++, base = 8;
  800a08:	83 c1 01             	add    $0x1,%ecx
  800a0b:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a10:	b8 00 00 00 00       	mov    $0x0,%eax
  800a15:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a18:	0f b6 11             	movzbl (%ecx),%edx
  800a1b:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a1e:	89 f3                	mov    %esi,%ebx
  800a20:	80 fb 09             	cmp    $0x9,%bl
  800a23:	77 08                	ja     800a2d <strtol+0x8b>
			dig = *s - '0';
  800a25:	0f be d2             	movsbl %dl,%edx
  800a28:	83 ea 30             	sub    $0x30,%edx
  800a2b:	eb 22                	jmp    800a4f <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a2d:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a30:	89 f3                	mov    %esi,%ebx
  800a32:	80 fb 19             	cmp    $0x19,%bl
  800a35:	77 08                	ja     800a3f <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a37:	0f be d2             	movsbl %dl,%edx
  800a3a:	83 ea 57             	sub    $0x57,%edx
  800a3d:	eb 10                	jmp    800a4f <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a3f:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a42:	89 f3                	mov    %esi,%ebx
  800a44:	80 fb 19             	cmp    $0x19,%bl
  800a47:	77 16                	ja     800a5f <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a49:	0f be d2             	movsbl %dl,%edx
  800a4c:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a4f:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a52:	7d 0b                	jge    800a5f <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a54:	83 c1 01             	add    $0x1,%ecx
  800a57:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a5b:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a5d:	eb b9                	jmp    800a18 <strtol+0x76>

	if (endptr)
  800a5f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a63:	74 0d                	je     800a72 <strtol+0xd0>
		*endptr = (char *) s;
  800a65:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a68:	89 0e                	mov    %ecx,(%esi)
  800a6a:	eb 06                	jmp    800a72 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a6c:	85 db                	test   %ebx,%ebx
  800a6e:	74 98                	je     800a08 <strtol+0x66>
  800a70:	eb 9e                	jmp    800a10 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a72:	89 c2                	mov    %eax,%edx
  800a74:	f7 da                	neg    %edx
  800a76:	85 ff                	test   %edi,%edi
  800a78:	0f 45 c2             	cmovne %edx,%eax
}
  800a7b:	5b                   	pop    %ebx
  800a7c:	5e                   	pop    %esi
  800a7d:	5f                   	pop    %edi
  800a7e:	5d                   	pop    %ebp
  800a7f:	c3                   	ret    

00800a80 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a80:	55                   	push   %ebp
  800a81:	89 e5                	mov    %esp,%ebp
  800a83:	57                   	push   %edi
  800a84:	56                   	push   %esi
  800a85:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a86:	b8 00 00 00 00       	mov    $0x0,%eax
  800a8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a8e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a91:	89 c3                	mov    %eax,%ebx
  800a93:	89 c7                	mov    %eax,%edi
  800a95:	89 c6                	mov    %eax,%esi
  800a97:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a99:	5b                   	pop    %ebx
  800a9a:	5e                   	pop    %esi
  800a9b:	5f                   	pop    %edi
  800a9c:	5d                   	pop    %ebp
  800a9d:	c3                   	ret    

00800a9e <sys_cgetc>:

int
sys_cgetc(void)
{
  800a9e:	55                   	push   %ebp
  800a9f:	89 e5                	mov    %esp,%ebp
  800aa1:	57                   	push   %edi
  800aa2:	56                   	push   %esi
  800aa3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa4:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa9:	b8 01 00 00 00       	mov    $0x1,%eax
  800aae:	89 d1                	mov    %edx,%ecx
  800ab0:	89 d3                	mov    %edx,%ebx
  800ab2:	89 d7                	mov    %edx,%edi
  800ab4:	89 d6                	mov    %edx,%esi
  800ab6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ab8:	5b                   	pop    %ebx
  800ab9:	5e                   	pop    %esi
  800aba:	5f                   	pop    %edi
  800abb:	5d                   	pop    %ebp
  800abc:	c3                   	ret    

00800abd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800abd:	55                   	push   %ebp
  800abe:	89 e5                	mov    %esp,%ebp
  800ac0:	57                   	push   %edi
  800ac1:	56                   	push   %esi
  800ac2:	53                   	push   %ebx
  800ac3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800acb:	b8 03 00 00 00       	mov    $0x3,%eax
  800ad0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad3:	89 cb                	mov    %ecx,%ebx
  800ad5:	89 cf                	mov    %ecx,%edi
  800ad7:	89 ce                	mov    %ecx,%esi
  800ad9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800adb:	85 c0                	test   %eax,%eax
  800add:	7e 17                	jle    800af6 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800adf:	83 ec 0c             	sub    $0xc,%esp
  800ae2:	50                   	push   %eax
  800ae3:	6a 03                	push   $0x3
  800ae5:	68 bf 2b 80 00       	push   $0x802bbf
  800aea:	6a 23                	push   $0x23
  800aec:	68 dc 2b 80 00       	push   $0x802bdc
  800af1:	e8 e5 f5 ff ff       	call   8000db <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800af6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800af9:	5b                   	pop    %ebx
  800afa:	5e                   	pop    %esi
  800afb:	5f                   	pop    %edi
  800afc:	5d                   	pop    %ebp
  800afd:	c3                   	ret    

00800afe <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800afe:	55                   	push   %ebp
  800aff:	89 e5                	mov    %esp,%ebp
  800b01:	57                   	push   %edi
  800b02:	56                   	push   %esi
  800b03:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b04:	ba 00 00 00 00       	mov    $0x0,%edx
  800b09:	b8 02 00 00 00       	mov    $0x2,%eax
  800b0e:	89 d1                	mov    %edx,%ecx
  800b10:	89 d3                	mov    %edx,%ebx
  800b12:	89 d7                	mov    %edx,%edi
  800b14:	89 d6                	mov    %edx,%esi
  800b16:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b18:	5b                   	pop    %ebx
  800b19:	5e                   	pop    %esi
  800b1a:	5f                   	pop    %edi
  800b1b:	5d                   	pop    %ebp
  800b1c:	c3                   	ret    

00800b1d <sys_yield>:

void
sys_yield(void)
{
  800b1d:	55                   	push   %ebp
  800b1e:	89 e5                	mov    %esp,%ebp
  800b20:	57                   	push   %edi
  800b21:	56                   	push   %esi
  800b22:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b23:	ba 00 00 00 00       	mov    $0x0,%edx
  800b28:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b2d:	89 d1                	mov    %edx,%ecx
  800b2f:	89 d3                	mov    %edx,%ebx
  800b31:	89 d7                	mov    %edx,%edi
  800b33:	89 d6                	mov    %edx,%esi
  800b35:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b37:	5b                   	pop    %ebx
  800b38:	5e                   	pop    %esi
  800b39:	5f                   	pop    %edi
  800b3a:	5d                   	pop    %ebp
  800b3b:	c3                   	ret    

00800b3c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b3c:	55                   	push   %ebp
  800b3d:	89 e5                	mov    %esp,%ebp
  800b3f:	57                   	push   %edi
  800b40:	56                   	push   %esi
  800b41:	53                   	push   %ebx
  800b42:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b45:	be 00 00 00 00       	mov    $0x0,%esi
  800b4a:	b8 04 00 00 00       	mov    $0x4,%eax
  800b4f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b52:	8b 55 08             	mov    0x8(%ebp),%edx
  800b55:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b58:	89 f7                	mov    %esi,%edi
  800b5a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b5c:	85 c0                	test   %eax,%eax
  800b5e:	7e 17                	jle    800b77 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b60:	83 ec 0c             	sub    $0xc,%esp
  800b63:	50                   	push   %eax
  800b64:	6a 04                	push   $0x4
  800b66:	68 bf 2b 80 00       	push   $0x802bbf
  800b6b:	6a 23                	push   $0x23
  800b6d:	68 dc 2b 80 00       	push   $0x802bdc
  800b72:	e8 64 f5 ff ff       	call   8000db <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b77:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b7a:	5b                   	pop    %ebx
  800b7b:	5e                   	pop    %esi
  800b7c:	5f                   	pop    %edi
  800b7d:	5d                   	pop    %ebp
  800b7e:	c3                   	ret    

00800b7f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b7f:	55                   	push   %ebp
  800b80:	89 e5                	mov    %esp,%ebp
  800b82:	57                   	push   %edi
  800b83:	56                   	push   %esi
  800b84:	53                   	push   %ebx
  800b85:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b88:	b8 05 00 00 00       	mov    $0x5,%eax
  800b8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b90:	8b 55 08             	mov    0x8(%ebp),%edx
  800b93:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b96:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b99:	8b 75 18             	mov    0x18(%ebp),%esi
  800b9c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b9e:	85 c0                	test   %eax,%eax
  800ba0:	7e 17                	jle    800bb9 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba2:	83 ec 0c             	sub    $0xc,%esp
  800ba5:	50                   	push   %eax
  800ba6:	6a 05                	push   $0x5
  800ba8:	68 bf 2b 80 00       	push   $0x802bbf
  800bad:	6a 23                	push   $0x23
  800baf:	68 dc 2b 80 00       	push   $0x802bdc
  800bb4:	e8 22 f5 ff ff       	call   8000db <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bb9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bbc:	5b                   	pop    %ebx
  800bbd:	5e                   	pop    %esi
  800bbe:	5f                   	pop    %edi
  800bbf:	5d                   	pop    %ebp
  800bc0:	c3                   	ret    

00800bc1 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bc1:	55                   	push   %ebp
  800bc2:	89 e5                	mov    %esp,%ebp
  800bc4:	57                   	push   %edi
  800bc5:	56                   	push   %esi
  800bc6:	53                   	push   %ebx
  800bc7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bca:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bcf:	b8 06 00 00 00       	mov    $0x6,%eax
  800bd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800bda:	89 df                	mov    %ebx,%edi
  800bdc:	89 de                	mov    %ebx,%esi
  800bde:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800be0:	85 c0                	test   %eax,%eax
  800be2:	7e 17                	jle    800bfb <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be4:	83 ec 0c             	sub    $0xc,%esp
  800be7:	50                   	push   %eax
  800be8:	6a 06                	push   $0x6
  800bea:	68 bf 2b 80 00       	push   $0x802bbf
  800bef:	6a 23                	push   $0x23
  800bf1:	68 dc 2b 80 00       	push   $0x802bdc
  800bf6:	e8 e0 f4 ff ff       	call   8000db <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bfb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bfe:	5b                   	pop    %ebx
  800bff:	5e                   	pop    %esi
  800c00:	5f                   	pop    %edi
  800c01:	5d                   	pop    %ebp
  800c02:	c3                   	ret    

00800c03 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c03:	55                   	push   %ebp
  800c04:	89 e5                	mov    %esp,%ebp
  800c06:	57                   	push   %edi
  800c07:	56                   	push   %esi
  800c08:	53                   	push   %ebx
  800c09:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c11:	b8 08 00 00 00       	mov    $0x8,%eax
  800c16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c19:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1c:	89 df                	mov    %ebx,%edi
  800c1e:	89 de                	mov    %ebx,%esi
  800c20:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c22:	85 c0                	test   %eax,%eax
  800c24:	7e 17                	jle    800c3d <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c26:	83 ec 0c             	sub    $0xc,%esp
  800c29:	50                   	push   %eax
  800c2a:	6a 08                	push   $0x8
  800c2c:	68 bf 2b 80 00       	push   $0x802bbf
  800c31:	6a 23                	push   $0x23
  800c33:	68 dc 2b 80 00       	push   $0x802bdc
  800c38:	e8 9e f4 ff ff       	call   8000db <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c40:	5b                   	pop    %ebx
  800c41:	5e                   	pop    %esi
  800c42:	5f                   	pop    %edi
  800c43:	5d                   	pop    %ebp
  800c44:	c3                   	ret    

00800c45 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c45:	55                   	push   %ebp
  800c46:	89 e5                	mov    %esp,%ebp
  800c48:	57                   	push   %edi
  800c49:	56                   	push   %esi
  800c4a:	53                   	push   %ebx
  800c4b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c53:	b8 09 00 00 00       	mov    $0x9,%eax
  800c58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5e:	89 df                	mov    %ebx,%edi
  800c60:	89 de                	mov    %ebx,%esi
  800c62:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c64:	85 c0                	test   %eax,%eax
  800c66:	7e 17                	jle    800c7f <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c68:	83 ec 0c             	sub    $0xc,%esp
  800c6b:	50                   	push   %eax
  800c6c:	6a 09                	push   $0x9
  800c6e:	68 bf 2b 80 00       	push   $0x802bbf
  800c73:	6a 23                	push   $0x23
  800c75:	68 dc 2b 80 00       	push   $0x802bdc
  800c7a:	e8 5c f4 ff ff       	call   8000db <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c82:	5b                   	pop    %ebx
  800c83:	5e                   	pop    %esi
  800c84:	5f                   	pop    %edi
  800c85:	5d                   	pop    %ebp
  800c86:	c3                   	ret    

00800c87 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c87:	55                   	push   %ebp
  800c88:	89 e5                	mov    %esp,%ebp
  800c8a:	57                   	push   %edi
  800c8b:	56                   	push   %esi
  800c8c:	53                   	push   %ebx
  800c8d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c90:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c95:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c9a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9d:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca0:	89 df                	mov    %ebx,%edi
  800ca2:	89 de                	mov    %ebx,%esi
  800ca4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ca6:	85 c0                	test   %eax,%eax
  800ca8:	7e 17                	jle    800cc1 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800caa:	83 ec 0c             	sub    $0xc,%esp
  800cad:	50                   	push   %eax
  800cae:	6a 0a                	push   $0xa
  800cb0:	68 bf 2b 80 00       	push   $0x802bbf
  800cb5:	6a 23                	push   $0x23
  800cb7:	68 dc 2b 80 00       	push   $0x802bdc
  800cbc:	e8 1a f4 ff ff       	call   8000db <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cc1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc4:	5b                   	pop    %ebx
  800cc5:	5e                   	pop    %esi
  800cc6:	5f                   	pop    %edi
  800cc7:	5d                   	pop    %ebp
  800cc8:	c3                   	ret    

00800cc9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cc9:	55                   	push   %ebp
  800cca:	89 e5                	mov    %esp,%ebp
  800ccc:	57                   	push   %edi
  800ccd:	56                   	push   %esi
  800cce:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccf:	be 00 00 00 00       	mov    $0x0,%esi
  800cd4:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cd9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdc:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ce2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ce5:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ce7:	5b                   	pop    %ebx
  800ce8:	5e                   	pop    %esi
  800ce9:	5f                   	pop    %edi
  800cea:	5d                   	pop    %ebp
  800ceb:	c3                   	ret    

00800cec <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cec:	55                   	push   %ebp
  800ced:	89 e5                	mov    %esp,%ebp
  800cef:	57                   	push   %edi
  800cf0:	56                   	push   %esi
  800cf1:	53                   	push   %ebx
  800cf2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cfa:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cff:	8b 55 08             	mov    0x8(%ebp),%edx
  800d02:	89 cb                	mov    %ecx,%ebx
  800d04:	89 cf                	mov    %ecx,%edi
  800d06:	89 ce                	mov    %ecx,%esi
  800d08:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d0a:	85 c0                	test   %eax,%eax
  800d0c:	7e 17                	jle    800d25 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0e:	83 ec 0c             	sub    $0xc,%esp
  800d11:	50                   	push   %eax
  800d12:	6a 0d                	push   $0xd
  800d14:	68 bf 2b 80 00       	push   $0x802bbf
  800d19:	6a 23                	push   $0x23
  800d1b:	68 dc 2b 80 00       	push   $0x802bdc
  800d20:	e8 b6 f3 ff ff       	call   8000db <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d25:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d28:	5b                   	pop    %ebx
  800d29:	5e                   	pop    %esi
  800d2a:	5f                   	pop    %edi
  800d2b:	5d                   	pop    %ebp
  800d2c:	c3                   	ret    

00800d2d <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d2d:	55                   	push   %ebp
  800d2e:	89 e5                	mov    %esp,%ebp
  800d30:	57                   	push   %edi
  800d31:	56                   	push   %esi
  800d32:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d33:	ba 00 00 00 00       	mov    $0x0,%edx
  800d38:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d3d:	89 d1                	mov    %edx,%ecx
  800d3f:	89 d3                	mov    %edx,%ebx
  800d41:	89 d7                	mov    %edx,%edi
  800d43:	89 d6                	mov    %edx,%esi
  800d45:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d47:	5b                   	pop    %ebx
  800d48:	5e                   	pop    %esi
  800d49:	5f                   	pop    %edi
  800d4a:	5d                   	pop    %ebp
  800d4b:	c3                   	ret    

00800d4c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d4c:	55                   	push   %ebp
  800d4d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d52:	05 00 00 00 30       	add    $0x30000000,%eax
  800d57:	c1 e8 0c             	shr    $0xc,%eax
}
  800d5a:	5d                   	pop    %ebp
  800d5b:	c3                   	ret    

00800d5c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d5c:	55                   	push   %ebp
  800d5d:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d62:	05 00 00 00 30       	add    $0x30000000,%eax
  800d67:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d6c:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d71:	5d                   	pop    %ebp
  800d72:	c3                   	ret    

00800d73 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d73:	55                   	push   %ebp
  800d74:	89 e5                	mov    %esp,%ebp
  800d76:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d79:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d7e:	89 c2                	mov    %eax,%edx
  800d80:	c1 ea 16             	shr    $0x16,%edx
  800d83:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d8a:	f6 c2 01             	test   $0x1,%dl
  800d8d:	74 11                	je     800da0 <fd_alloc+0x2d>
  800d8f:	89 c2                	mov    %eax,%edx
  800d91:	c1 ea 0c             	shr    $0xc,%edx
  800d94:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d9b:	f6 c2 01             	test   $0x1,%dl
  800d9e:	75 09                	jne    800da9 <fd_alloc+0x36>
			*fd_store = fd;
  800da0:	89 01                	mov    %eax,(%ecx)
			return 0;
  800da2:	b8 00 00 00 00       	mov    $0x0,%eax
  800da7:	eb 17                	jmp    800dc0 <fd_alloc+0x4d>
  800da9:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800dae:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800db3:	75 c9                	jne    800d7e <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800db5:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800dbb:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800dc0:	5d                   	pop    %ebp
  800dc1:	c3                   	ret    

00800dc2 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800dc2:	55                   	push   %ebp
  800dc3:	89 e5                	mov    %esp,%ebp
  800dc5:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800dc8:	83 f8 1f             	cmp    $0x1f,%eax
  800dcb:	77 36                	ja     800e03 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800dcd:	c1 e0 0c             	shl    $0xc,%eax
  800dd0:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800dd5:	89 c2                	mov    %eax,%edx
  800dd7:	c1 ea 16             	shr    $0x16,%edx
  800dda:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800de1:	f6 c2 01             	test   $0x1,%dl
  800de4:	74 24                	je     800e0a <fd_lookup+0x48>
  800de6:	89 c2                	mov    %eax,%edx
  800de8:	c1 ea 0c             	shr    $0xc,%edx
  800deb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800df2:	f6 c2 01             	test   $0x1,%dl
  800df5:	74 1a                	je     800e11 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800df7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dfa:	89 02                	mov    %eax,(%edx)
	return 0;
  800dfc:	b8 00 00 00 00       	mov    $0x0,%eax
  800e01:	eb 13                	jmp    800e16 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e03:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e08:	eb 0c                	jmp    800e16 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e0a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e0f:	eb 05                	jmp    800e16 <fd_lookup+0x54>
  800e11:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e16:	5d                   	pop    %ebp
  800e17:	c3                   	ret    

00800e18 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e18:	55                   	push   %ebp
  800e19:	89 e5                	mov    %esp,%ebp
  800e1b:	83 ec 08             	sub    $0x8,%esp
  800e1e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e21:	ba 68 2c 80 00       	mov    $0x802c68,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e26:	eb 13                	jmp    800e3b <dev_lookup+0x23>
  800e28:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800e2b:	39 08                	cmp    %ecx,(%eax)
  800e2d:	75 0c                	jne    800e3b <dev_lookup+0x23>
			*dev = devtab[i];
  800e2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e32:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e34:	b8 00 00 00 00       	mov    $0x0,%eax
  800e39:	eb 2e                	jmp    800e69 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e3b:	8b 02                	mov    (%edx),%eax
  800e3d:	85 c0                	test   %eax,%eax
  800e3f:	75 e7                	jne    800e28 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e41:	a1 08 40 80 00       	mov    0x804008,%eax
  800e46:	8b 40 48             	mov    0x48(%eax),%eax
  800e49:	83 ec 04             	sub    $0x4,%esp
  800e4c:	51                   	push   %ecx
  800e4d:	50                   	push   %eax
  800e4e:	68 ec 2b 80 00       	push   $0x802bec
  800e53:	e8 5c f3 ff ff       	call   8001b4 <cprintf>
	*dev = 0;
  800e58:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e5b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e61:	83 c4 10             	add    $0x10,%esp
  800e64:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e69:	c9                   	leave  
  800e6a:	c3                   	ret    

00800e6b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e6b:	55                   	push   %ebp
  800e6c:	89 e5                	mov    %esp,%ebp
  800e6e:	56                   	push   %esi
  800e6f:	53                   	push   %ebx
  800e70:	83 ec 10             	sub    $0x10,%esp
  800e73:	8b 75 08             	mov    0x8(%ebp),%esi
  800e76:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e79:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e7c:	50                   	push   %eax
  800e7d:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e83:	c1 e8 0c             	shr    $0xc,%eax
  800e86:	50                   	push   %eax
  800e87:	e8 36 ff ff ff       	call   800dc2 <fd_lookup>
  800e8c:	83 c4 08             	add    $0x8,%esp
  800e8f:	85 c0                	test   %eax,%eax
  800e91:	78 05                	js     800e98 <fd_close+0x2d>
	    || fd != fd2)
  800e93:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800e96:	74 0c                	je     800ea4 <fd_close+0x39>
		return (must_exist ? r : 0);
  800e98:	84 db                	test   %bl,%bl
  800e9a:	ba 00 00 00 00       	mov    $0x0,%edx
  800e9f:	0f 44 c2             	cmove  %edx,%eax
  800ea2:	eb 41                	jmp    800ee5 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ea4:	83 ec 08             	sub    $0x8,%esp
  800ea7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800eaa:	50                   	push   %eax
  800eab:	ff 36                	pushl  (%esi)
  800ead:	e8 66 ff ff ff       	call   800e18 <dev_lookup>
  800eb2:	89 c3                	mov    %eax,%ebx
  800eb4:	83 c4 10             	add    $0x10,%esp
  800eb7:	85 c0                	test   %eax,%eax
  800eb9:	78 1a                	js     800ed5 <fd_close+0x6a>
		if (dev->dev_close)
  800ebb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ebe:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800ec1:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800ec6:	85 c0                	test   %eax,%eax
  800ec8:	74 0b                	je     800ed5 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800eca:	83 ec 0c             	sub    $0xc,%esp
  800ecd:	56                   	push   %esi
  800ece:	ff d0                	call   *%eax
  800ed0:	89 c3                	mov    %eax,%ebx
  800ed2:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800ed5:	83 ec 08             	sub    $0x8,%esp
  800ed8:	56                   	push   %esi
  800ed9:	6a 00                	push   $0x0
  800edb:	e8 e1 fc ff ff       	call   800bc1 <sys_page_unmap>
	return r;
  800ee0:	83 c4 10             	add    $0x10,%esp
  800ee3:	89 d8                	mov    %ebx,%eax
}
  800ee5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ee8:	5b                   	pop    %ebx
  800ee9:	5e                   	pop    %esi
  800eea:	5d                   	pop    %ebp
  800eeb:	c3                   	ret    

00800eec <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800eec:	55                   	push   %ebp
  800eed:	89 e5                	mov    %esp,%ebp
  800eef:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ef2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ef5:	50                   	push   %eax
  800ef6:	ff 75 08             	pushl  0x8(%ebp)
  800ef9:	e8 c4 fe ff ff       	call   800dc2 <fd_lookup>
  800efe:	83 c4 08             	add    $0x8,%esp
  800f01:	85 c0                	test   %eax,%eax
  800f03:	78 10                	js     800f15 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f05:	83 ec 08             	sub    $0x8,%esp
  800f08:	6a 01                	push   $0x1
  800f0a:	ff 75 f4             	pushl  -0xc(%ebp)
  800f0d:	e8 59 ff ff ff       	call   800e6b <fd_close>
  800f12:	83 c4 10             	add    $0x10,%esp
}
  800f15:	c9                   	leave  
  800f16:	c3                   	ret    

00800f17 <close_all>:

void
close_all(void)
{
  800f17:	55                   	push   %ebp
  800f18:	89 e5                	mov    %esp,%ebp
  800f1a:	53                   	push   %ebx
  800f1b:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f1e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f23:	83 ec 0c             	sub    $0xc,%esp
  800f26:	53                   	push   %ebx
  800f27:	e8 c0 ff ff ff       	call   800eec <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f2c:	83 c3 01             	add    $0x1,%ebx
  800f2f:	83 c4 10             	add    $0x10,%esp
  800f32:	83 fb 20             	cmp    $0x20,%ebx
  800f35:	75 ec                	jne    800f23 <close_all+0xc>
		close(i);
}
  800f37:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f3a:	c9                   	leave  
  800f3b:	c3                   	ret    

00800f3c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f3c:	55                   	push   %ebp
  800f3d:	89 e5                	mov    %esp,%ebp
  800f3f:	57                   	push   %edi
  800f40:	56                   	push   %esi
  800f41:	53                   	push   %ebx
  800f42:	83 ec 2c             	sub    $0x2c,%esp
  800f45:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f48:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f4b:	50                   	push   %eax
  800f4c:	ff 75 08             	pushl  0x8(%ebp)
  800f4f:	e8 6e fe ff ff       	call   800dc2 <fd_lookup>
  800f54:	83 c4 08             	add    $0x8,%esp
  800f57:	85 c0                	test   %eax,%eax
  800f59:	0f 88 c1 00 00 00    	js     801020 <dup+0xe4>
		return r;
	close(newfdnum);
  800f5f:	83 ec 0c             	sub    $0xc,%esp
  800f62:	56                   	push   %esi
  800f63:	e8 84 ff ff ff       	call   800eec <close>

	newfd = INDEX2FD(newfdnum);
  800f68:	89 f3                	mov    %esi,%ebx
  800f6a:	c1 e3 0c             	shl    $0xc,%ebx
  800f6d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800f73:	83 c4 04             	add    $0x4,%esp
  800f76:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f79:	e8 de fd ff ff       	call   800d5c <fd2data>
  800f7e:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800f80:	89 1c 24             	mov    %ebx,(%esp)
  800f83:	e8 d4 fd ff ff       	call   800d5c <fd2data>
  800f88:	83 c4 10             	add    $0x10,%esp
  800f8b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f8e:	89 f8                	mov    %edi,%eax
  800f90:	c1 e8 16             	shr    $0x16,%eax
  800f93:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f9a:	a8 01                	test   $0x1,%al
  800f9c:	74 37                	je     800fd5 <dup+0x99>
  800f9e:	89 f8                	mov    %edi,%eax
  800fa0:	c1 e8 0c             	shr    $0xc,%eax
  800fa3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800faa:	f6 c2 01             	test   $0x1,%dl
  800fad:	74 26                	je     800fd5 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800faf:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fb6:	83 ec 0c             	sub    $0xc,%esp
  800fb9:	25 07 0e 00 00       	and    $0xe07,%eax
  800fbe:	50                   	push   %eax
  800fbf:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fc2:	6a 00                	push   $0x0
  800fc4:	57                   	push   %edi
  800fc5:	6a 00                	push   $0x0
  800fc7:	e8 b3 fb ff ff       	call   800b7f <sys_page_map>
  800fcc:	89 c7                	mov    %eax,%edi
  800fce:	83 c4 20             	add    $0x20,%esp
  800fd1:	85 c0                	test   %eax,%eax
  800fd3:	78 2e                	js     801003 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fd5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800fd8:	89 d0                	mov    %edx,%eax
  800fda:	c1 e8 0c             	shr    $0xc,%eax
  800fdd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fe4:	83 ec 0c             	sub    $0xc,%esp
  800fe7:	25 07 0e 00 00       	and    $0xe07,%eax
  800fec:	50                   	push   %eax
  800fed:	53                   	push   %ebx
  800fee:	6a 00                	push   $0x0
  800ff0:	52                   	push   %edx
  800ff1:	6a 00                	push   $0x0
  800ff3:	e8 87 fb ff ff       	call   800b7f <sys_page_map>
  800ff8:	89 c7                	mov    %eax,%edi
  800ffa:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800ffd:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fff:	85 ff                	test   %edi,%edi
  801001:	79 1d                	jns    801020 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801003:	83 ec 08             	sub    $0x8,%esp
  801006:	53                   	push   %ebx
  801007:	6a 00                	push   $0x0
  801009:	e8 b3 fb ff ff       	call   800bc1 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80100e:	83 c4 08             	add    $0x8,%esp
  801011:	ff 75 d4             	pushl  -0x2c(%ebp)
  801014:	6a 00                	push   $0x0
  801016:	e8 a6 fb ff ff       	call   800bc1 <sys_page_unmap>
	return r;
  80101b:	83 c4 10             	add    $0x10,%esp
  80101e:	89 f8                	mov    %edi,%eax
}
  801020:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801023:	5b                   	pop    %ebx
  801024:	5e                   	pop    %esi
  801025:	5f                   	pop    %edi
  801026:	5d                   	pop    %ebp
  801027:	c3                   	ret    

00801028 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801028:	55                   	push   %ebp
  801029:	89 e5                	mov    %esp,%ebp
  80102b:	53                   	push   %ebx
  80102c:	83 ec 14             	sub    $0x14,%esp
  80102f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801032:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801035:	50                   	push   %eax
  801036:	53                   	push   %ebx
  801037:	e8 86 fd ff ff       	call   800dc2 <fd_lookup>
  80103c:	83 c4 08             	add    $0x8,%esp
  80103f:	89 c2                	mov    %eax,%edx
  801041:	85 c0                	test   %eax,%eax
  801043:	78 6d                	js     8010b2 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801045:	83 ec 08             	sub    $0x8,%esp
  801048:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80104b:	50                   	push   %eax
  80104c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80104f:	ff 30                	pushl  (%eax)
  801051:	e8 c2 fd ff ff       	call   800e18 <dev_lookup>
  801056:	83 c4 10             	add    $0x10,%esp
  801059:	85 c0                	test   %eax,%eax
  80105b:	78 4c                	js     8010a9 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80105d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801060:	8b 42 08             	mov    0x8(%edx),%eax
  801063:	83 e0 03             	and    $0x3,%eax
  801066:	83 f8 01             	cmp    $0x1,%eax
  801069:	75 21                	jne    80108c <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80106b:	a1 08 40 80 00       	mov    0x804008,%eax
  801070:	8b 40 48             	mov    0x48(%eax),%eax
  801073:	83 ec 04             	sub    $0x4,%esp
  801076:	53                   	push   %ebx
  801077:	50                   	push   %eax
  801078:	68 2d 2c 80 00       	push   $0x802c2d
  80107d:	e8 32 f1 ff ff       	call   8001b4 <cprintf>
		return -E_INVAL;
  801082:	83 c4 10             	add    $0x10,%esp
  801085:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80108a:	eb 26                	jmp    8010b2 <read+0x8a>
	}
	if (!dev->dev_read)
  80108c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80108f:	8b 40 08             	mov    0x8(%eax),%eax
  801092:	85 c0                	test   %eax,%eax
  801094:	74 17                	je     8010ad <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801096:	83 ec 04             	sub    $0x4,%esp
  801099:	ff 75 10             	pushl  0x10(%ebp)
  80109c:	ff 75 0c             	pushl  0xc(%ebp)
  80109f:	52                   	push   %edx
  8010a0:	ff d0                	call   *%eax
  8010a2:	89 c2                	mov    %eax,%edx
  8010a4:	83 c4 10             	add    $0x10,%esp
  8010a7:	eb 09                	jmp    8010b2 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010a9:	89 c2                	mov    %eax,%edx
  8010ab:	eb 05                	jmp    8010b2 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8010ad:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8010b2:	89 d0                	mov    %edx,%eax
  8010b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010b7:	c9                   	leave  
  8010b8:	c3                   	ret    

008010b9 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010b9:	55                   	push   %ebp
  8010ba:	89 e5                	mov    %esp,%ebp
  8010bc:	57                   	push   %edi
  8010bd:	56                   	push   %esi
  8010be:	53                   	push   %ebx
  8010bf:	83 ec 0c             	sub    $0xc,%esp
  8010c2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010c5:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010c8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010cd:	eb 21                	jmp    8010f0 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010cf:	83 ec 04             	sub    $0x4,%esp
  8010d2:	89 f0                	mov    %esi,%eax
  8010d4:	29 d8                	sub    %ebx,%eax
  8010d6:	50                   	push   %eax
  8010d7:	89 d8                	mov    %ebx,%eax
  8010d9:	03 45 0c             	add    0xc(%ebp),%eax
  8010dc:	50                   	push   %eax
  8010dd:	57                   	push   %edi
  8010de:	e8 45 ff ff ff       	call   801028 <read>
		if (m < 0)
  8010e3:	83 c4 10             	add    $0x10,%esp
  8010e6:	85 c0                	test   %eax,%eax
  8010e8:	78 10                	js     8010fa <readn+0x41>
			return m;
		if (m == 0)
  8010ea:	85 c0                	test   %eax,%eax
  8010ec:	74 0a                	je     8010f8 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010ee:	01 c3                	add    %eax,%ebx
  8010f0:	39 f3                	cmp    %esi,%ebx
  8010f2:	72 db                	jb     8010cf <readn+0x16>
  8010f4:	89 d8                	mov    %ebx,%eax
  8010f6:	eb 02                	jmp    8010fa <readn+0x41>
  8010f8:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8010fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010fd:	5b                   	pop    %ebx
  8010fe:	5e                   	pop    %esi
  8010ff:	5f                   	pop    %edi
  801100:	5d                   	pop    %ebp
  801101:	c3                   	ret    

00801102 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801102:	55                   	push   %ebp
  801103:	89 e5                	mov    %esp,%ebp
  801105:	53                   	push   %ebx
  801106:	83 ec 14             	sub    $0x14,%esp
  801109:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80110c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80110f:	50                   	push   %eax
  801110:	53                   	push   %ebx
  801111:	e8 ac fc ff ff       	call   800dc2 <fd_lookup>
  801116:	83 c4 08             	add    $0x8,%esp
  801119:	89 c2                	mov    %eax,%edx
  80111b:	85 c0                	test   %eax,%eax
  80111d:	78 68                	js     801187 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80111f:	83 ec 08             	sub    $0x8,%esp
  801122:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801125:	50                   	push   %eax
  801126:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801129:	ff 30                	pushl  (%eax)
  80112b:	e8 e8 fc ff ff       	call   800e18 <dev_lookup>
  801130:	83 c4 10             	add    $0x10,%esp
  801133:	85 c0                	test   %eax,%eax
  801135:	78 47                	js     80117e <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801137:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80113a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80113e:	75 21                	jne    801161 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801140:	a1 08 40 80 00       	mov    0x804008,%eax
  801145:	8b 40 48             	mov    0x48(%eax),%eax
  801148:	83 ec 04             	sub    $0x4,%esp
  80114b:	53                   	push   %ebx
  80114c:	50                   	push   %eax
  80114d:	68 49 2c 80 00       	push   $0x802c49
  801152:	e8 5d f0 ff ff       	call   8001b4 <cprintf>
		return -E_INVAL;
  801157:	83 c4 10             	add    $0x10,%esp
  80115a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80115f:	eb 26                	jmp    801187 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801161:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801164:	8b 52 0c             	mov    0xc(%edx),%edx
  801167:	85 d2                	test   %edx,%edx
  801169:	74 17                	je     801182 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80116b:	83 ec 04             	sub    $0x4,%esp
  80116e:	ff 75 10             	pushl  0x10(%ebp)
  801171:	ff 75 0c             	pushl  0xc(%ebp)
  801174:	50                   	push   %eax
  801175:	ff d2                	call   *%edx
  801177:	89 c2                	mov    %eax,%edx
  801179:	83 c4 10             	add    $0x10,%esp
  80117c:	eb 09                	jmp    801187 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80117e:	89 c2                	mov    %eax,%edx
  801180:	eb 05                	jmp    801187 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801182:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801187:	89 d0                	mov    %edx,%eax
  801189:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80118c:	c9                   	leave  
  80118d:	c3                   	ret    

0080118e <seek>:

int
seek(int fdnum, off_t offset)
{
  80118e:	55                   	push   %ebp
  80118f:	89 e5                	mov    %esp,%ebp
  801191:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801194:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801197:	50                   	push   %eax
  801198:	ff 75 08             	pushl  0x8(%ebp)
  80119b:	e8 22 fc ff ff       	call   800dc2 <fd_lookup>
  8011a0:	83 c4 08             	add    $0x8,%esp
  8011a3:	85 c0                	test   %eax,%eax
  8011a5:	78 0e                	js     8011b5 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8011a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8011aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011ad:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8011b0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011b5:	c9                   	leave  
  8011b6:	c3                   	ret    

008011b7 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8011b7:	55                   	push   %ebp
  8011b8:	89 e5                	mov    %esp,%ebp
  8011ba:	53                   	push   %ebx
  8011bb:	83 ec 14             	sub    $0x14,%esp
  8011be:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011c1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011c4:	50                   	push   %eax
  8011c5:	53                   	push   %ebx
  8011c6:	e8 f7 fb ff ff       	call   800dc2 <fd_lookup>
  8011cb:	83 c4 08             	add    $0x8,%esp
  8011ce:	89 c2                	mov    %eax,%edx
  8011d0:	85 c0                	test   %eax,%eax
  8011d2:	78 65                	js     801239 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011d4:	83 ec 08             	sub    $0x8,%esp
  8011d7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011da:	50                   	push   %eax
  8011db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011de:	ff 30                	pushl  (%eax)
  8011e0:	e8 33 fc ff ff       	call   800e18 <dev_lookup>
  8011e5:	83 c4 10             	add    $0x10,%esp
  8011e8:	85 c0                	test   %eax,%eax
  8011ea:	78 44                	js     801230 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011ef:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011f3:	75 21                	jne    801216 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8011f5:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8011fa:	8b 40 48             	mov    0x48(%eax),%eax
  8011fd:	83 ec 04             	sub    $0x4,%esp
  801200:	53                   	push   %ebx
  801201:	50                   	push   %eax
  801202:	68 0c 2c 80 00       	push   $0x802c0c
  801207:	e8 a8 ef ff ff       	call   8001b4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80120c:	83 c4 10             	add    $0x10,%esp
  80120f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801214:	eb 23                	jmp    801239 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801216:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801219:	8b 52 18             	mov    0x18(%edx),%edx
  80121c:	85 d2                	test   %edx,%edx
  80121e:	74 14                	je     801234 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801220:	83 ec 08             	sub    $0x8,%esp
  801223:	ff 75 0c             	pushl  0xc(%ebp)
  801226:	50                   	push   %eax
  801227:	ff d2                	call   *%edx
  801229:	89 c2                	mov    %eax,%edx
  80122b:	83 c4 10             	add    $0x10,%esp
  80122e:	eb 09                	jmp    801239 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801230:	89 c2                	mov    %eax,%edx
  801232:	eb 05                	jmp    801239 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801234:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801239:	89 d0                	mov    %edx,%eax
  80123b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80123e:	c9                   	leave  
  80123f:	c3                   	ret    

00801240 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801240:	55                   	push   %ebp
  801241:	89 e5                	mov    %esp,%ebp
  801243:	53                   	push   %ebx
  801244:	83 ec 14             	sub    $0x14,%esp
  801247:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80124a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80124d:	50                   	push   %eax
  80124e:	ff 75 08             	pushl  0x8(%ebp)
  801251:	e8 6c fb ff ff       	call   800dc2 <fd_lookup>
  801256:	83 c4 08             	add    $0x8,%esp
  801259:	89 c2                	mov    %eax,%edx
  80125b:	85 c0                	test   %eax,%eax
  80125d:	78 58                	js     8012b7 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80125f:	83 ec 08             	sub    $0x8,%esp
  801262:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801265:	50                   	push   %eax
  801266:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801269:	ff 30                	pushl  (%eax)
  80126b:	e8 a8 fb ff ff       	call   800e18 <dev_lookup>
  801270:	83 c4 10             	add    $0x10,%esp
  801273:	85 c0                	test   %eax,%eax
  801275:	78 37                	js     8012ae <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801277:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80127a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80127e:	74 32                	je     8012b2 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801280:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801283:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80128a:	00 00 00 
	stat->st_isdir = 0;
  80128d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801294:	00 00 00 
	stat->st_dev = dev;
  801297:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80129d:	83 ec 08             	sub    $0x8,%esp
  8012a0:	53                   	push   %ebx
  8012a1:	ff 75 f0             	pushl  -0x10(%ebp)
  8012a4:	ff 50 14             	call   *0x14(%eax)
  8012a7:	89 c2                	mov    %eax,%edx
  8012a9:	83 c4 10             	add    $0x10,%esp
  8012ac:	eb 09                	jmp    8012b7 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ae:	89 c2                	mov    %eax,%edx
  8012b0:	eb 05                	jmp    8012b7 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8012b2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8012b7:	89 d0                	mov    %edx,%eax
  8012b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012bc:	c9                   	leave  
  8012bd:	c3                   	ret    

008012be <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8012be:	55                   	push   %ebp
  8012bf:	89 e5                	mov    %esp,%ebp
  8012c1:	56                   	push   %esi
  8012c2:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012c3:	83 ec 08             	sub    $0x8,%esp
  8012c6:	6a 00                	push   $0x0
  8012c8:	ff 75 08             	pushl  0x8(%ebp)
  8012cb:	e8 0c 02 00 00       	call   8014dc <open>
  8012d0:	89 c3                	mov    %eax,%ebx
  8012d2:	83 c4 10             	add    $0x10,%esp
  8012d5:	85 c0                	test   %eax,%eax
  8012d7:	78 1b                	js     8012f4 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8012d9:	83 ec 08             	sub    $0x8,%esp
  8012dc:	ff 75 0c             	pushl  0xc(%ebp)
  8012df:	50                   	push   %eax
  8012e0:	e8 5b ff ff ff       	call   801240 <fstat>
  8012e5:	89 c6                	mov    %eax,%esi
	close(fd);
  8012e7:	89 1c 24             	mov    %ebx,(%esp)
  8012ea:	e8 fd fb ff ff       	call   800eec <close>
	return r;
  8012ef:	83 c4 10             	add    $0x10,%esp
  8012f2:	89 f0                	mov    %esi,%eax
}
  8012f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012f7:	5b                   	pop    %ebx
  8012f8:	5e                   	pop    %esi
  8012f9:	5d                   	pop    %ebp
  8012fa:	c3                   	ret    

008012fb <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8012fb:	55                   	push   %ebp
  8012fc:	89 e5                	mov    %esp,%ebp
  8012fe:	56                   	push   %esi
  8012ff:	53                   	push   %ebx
  801300:	89 c6                	mov    %eax,%esi
  801302:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801304:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80130b:	75 12                	jne    80131f <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80130d:	83 ec 0c             	sub    $0xc,%esp
  801310:	6a 01                	push   $0x1
  801312:	e8 20 12 00 00       	call   802537 <ipc_find_env>
  801317:	a3 00 40 80 00       	mov    %eax,0x804000
  80131c:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80131f:	6a 07                	push   $0x7
  801321:	68 00 50 80 00       	push   $0x805000
  801326:	56                   	push   %esi
  801327:	ff 35 00 40 80 00    	pushl  0x804000
  80132d:	e8 b1 11 00 00       	call   8024e3 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801332:	83 c4 0c             	add    $0xc,%esp
  801335:	6a 00                	push   $0x0
  801337:	53                   	push   %ebx
  801338:	6a 00                	push   $0x0
  80133a:	e8 3b 11 00 00       	call   80247a <ipc_recv>
}
  80133f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801342:	5b                   	pop    %ebx
  801343:	5e                   	pop    %esi
  801344:	5d                   	pop    %ebp
  801345:	c3                   	ret    

00801346 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801346:	55                   	push   %ebp
  801347:	89 e5                	mov    %esp,%ebp
  801349:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80134c:	8b 45 08             	mov    0x8(%ebp),%eax
  80134f:	8b 40 0c             	mov    0xc(%eax),%eax
  801352:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801357:	8b 45 0c             	mov    0xc(%ebp),%eax
  80135a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80135f:	ba 00 00 00 00       	mov    $0x0,%edx
  801364:	b8 02 00 00 00       	mov    $0x2,%eax
  801369:	e8 8d ff ff ff       	call   8012fb <fsipc>
}
  80136e:	c9                   	leave  
  80136f:	c3                   	ret    

00801370 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801370:	55                   	push   %ebp
  801371:	89 e5                	mov    %esp,%ebp
  801373:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801376:	8b 45 08             	mov    0x8(%ebp),%eax
  801379:	8b 40 0c             	mov    0xc(%eax),%eax
  80137c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801381:	ba 00 00 00 00       	mov    $0x0,%edx
  801386:	b8 06 00 00 00       	mov    $0x6,%eax
  80138b:	e8 6b ff ff ff       	call   8012fb <fsipc>
}
  801390:	c9                   	leave  
  801391:	c3                   	ret    

00801392 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801392:	55                   	push   %ebp
  801393:	89 e5                	mov    %esp,%ebp
  801395:	53                   	push   %ebx
  801396:	83 ec 04             	sub    $0x4,%esp
  801399:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80139c:	8b 45 08             	mov    0x8(%ebp),%eax
  80139f:	8b 40 0c             	mov    0xc(%eax),%eax
  8013a2:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8013a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8013ac:	b8 05 00 00 00       	mov    $0x5,%eax
  8013b1:	e8 45 ff ff ff       	call   8012fb <fsipc>
  8013b6:	85 c0                	test   %eax,%eax
  8013b8:	78 2c                	js     8013e6 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013ba:	83 ec 08             	sub    $0x8,%esp
  8013bd:	68 00 50 80 00       	push   $0x805000
  8013c2:	53                   	push   %ebx
  8013c3:	e8 71 f3 ff ff       	call   800739 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8013c8:	a1 80 50 80 00       	mov    0x805080,%eax
  8013cd:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8013d3:	a1 84 50 80 00       	mov    0x805084,%eax
  8013d8:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8013de:	83 c4 10             	add    $0x10,%esp
  8013e1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013e9:	c9                   	leave  
  8013ea:	c3                   	ret    

008013eb <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8013eb:	55                   	push   %ebp
  8013ec:	89 e5                	mov    %esp,%ebp
  8013ee:	53                   	push   %ebx
  8013ef:	83 ec 08             	sub    $0x8,%esp
  8013f2:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8013f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8013f8:	8b 52 0c             	mov    0xc(%edx),%edx
  8013fb:	89 15 00 50 80 00    	mov    %edx,0x805000
  801401:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801406:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  80140b:	0f 46 d8             	cmovbe %eax,%ebx
	
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  80140e:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  801414:	53                   	push   %ebx
  801415:	ff 75 0c             	pushl  0xc(%ebp)
  801418:	68 08 50 80 00       	push   $0x805008
  80141d:	e8 a9 f4 ff ff       	call   8008cb <memmove>

	
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) 
  801422:	ba 00 00 00 00       	mov    $0x0,%edx
  801427:	b8 04 00 00 00       	mov    $0x4,%eax
  80142c:	e8 ca fe ff ff       	call   8012fb <fsipc>
  801431:	83 c4 10             	add    $0x10,%esp
  801434:	85 c0                	test   %eax,%eax
  801436:	78 1d                	js     801455 <devfile_write+0x6a>
		return r;
	assert(r <= n_real); 
  801438:	39 d8                	cmp    %ebx,%eax
  80143a:	76 19                	jbe    801455 <devfile_write+0x6a>
  80143c:	68 7c 2c 80 00       	push   $0x802c7c
  801441:	68 88 2c 80 00       	push   $0x802c88
  801446:	68 a3 00 00 00       	push   $0xa3
  80144b:	68 9d 2c 80 00       	push   $0x802c9d
  801450:	e8 86 ec ff ff       	call   8000db <_panic>
	return r;
}
  801455:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801458:	c9                   	leave  
  801459:	c3                   	ret    

0080145a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80145a:	55                   	push   %ebp
  80145b:	89 e5                	mov    %esp,%ebp
  80145d:	56                   	push   %esi
  80145e:	53                   	push   %ebx
  80145f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801462:	8b 45 08             	mov    0x8(%ebp),%eax
  801465:	8b 40 0c             	mov    0xc(%eax),%eax
  801468:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80146d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801473:	ba 00 00 00 00       	mov    $0x0,%edx
  801478:	b8 03 00 00 00       	mov    $0x3,%eax
  80147d:	e8 79 fe ff ff       	call   8012fb <fsipc>
  801482:	89 c3                	mov    %eax,%ebx
  801484:	85 c0                	test   %eax,%eax
  801486:	78 4b                	js     8014d3 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801488:	39 c6                	cmp    %eax,%esi
  80148a:	73 16                	jae    8014a2 <devfile_read+0x48>
  80148c:	68 a8 2c 80 00       	push   $0x802ca8
  801491:	68 88 2c 80 00       	push   $0x802c88
  801496:	6a 7c                	push   $0x7c
  801498:	68 9d 2c 80 00       	push   $0x802c9d
  80149d:	e8 39 ec ff ff       	call   8000db <_panic>
	assert(r <= PGSIZE);
  8014a2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014a7:	7e 16                	jle    8014bf <devfile_read+0x65>
  8014a9:	68 af 2c 80 00       	push   $0x802caf
  8014ae:	68 88 2c 80 00       	push   $0x802c88
  8014b3:	6a 7d                	push   $0x7d
  8014b5:	68 9d 2c 80 00       	push   $0x802c9d
  8014ba:	e8 1c ec ff ff       	call   8000db <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8014bf:	83 ec 04             	sub    $0x4,%esp
  8014c2:	50                   	push   %eax
  8014c3:	68 00 50 80 00       	push   $0x805000
  8014c8:	ff 75 0c             	pushl  0xc(%ebp)
  8014cb:	e8 fb f3 ff ff       	call   8008cb <memmove>
	return r;
  8014d0:	83 c4 10             	add    $0x10,%esp
}
  8014d3:	89 d8                	mov    %ebx,%eax
  8014d5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014d8:	5b                   	pop    %ebx
  8014d9:	5e                   	pop    %esi
  8014da:	5d                   	pop    %ebp
  8014db:	c3                   	ret    

008014dc <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8014dc:	55                   	push   %ebp
  8014dd:	89 e5                	mov    %esp,%ebp
  8014df:	53                   	push   %ebx
  8014e0:	83 ec 20             	sub    $0x20,%esp
  8014e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8014e6:	53                   	push   %ebx
  8014e7:	e8 14 f2 ff ff       	call   800700 <strlen>
  8014ec:	83 c4 10             	add    $0x10,%esp
  8014ef:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8014f4:	7f 67                	jg     80155d <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014f6:	83 ec 0c             	sub    $0xc,%esp
  8014f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014fc:	50                   	push   %eax
  8014fd:	e8 71 f8 ff ff       	call   800d73 <fd_alloc>
  801502:	83 c4 10             	add    $0x10,%esp
		return r;
  801505:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801507:	85 c0                	test   %eax,%eax
  801509:	78 57                	js     801562 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80150b:	83 ec 08             	sub    $0x8,%esp
  80150e:	53                   	push   %ebx
  80150f:	68 00 50 80 00       	push   $0x805000
  801514:	e8 20 f2 ff ff       	call   800739 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801519:	8b 45 0c             	mov    0xc(%ebp),%eax
  80151c:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801521:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801524:	b8 01 00 00 00       	mov    $0x1,%eax
  801529:	e8 cd fd ff ff       	call   8012fb <fsipc>
  80152e:	89 c3                	mov    %eax,%ebx
  801530:	83 c4 10             	add    $0x10,%esp
  801533:	85 c0                	test   %eax,%eax
  801535:	79 14                	jns    80154b <open+0x6f>
		fd_close(fd, 0);
  801537:	83 ec 08             	sub    $0x8,%esp
  80153a:	6a 00                	push   $0x0
  80153c:	ff 75 f4             	pushl  -0xc(%ebp)
  80153f:	e8 27 f9 ff ff       	call   800e6b <fd_close>
		return r;
  801544:	83 c4 10             	add    $0x10,%esp
  801547:	89 da                	mov    %ebx,%edx
  801549:	eb 17                	jmp    801562 <open+0x86>
	}

	return fd2num(fd);
  80154b:	83 ec 0c             	sub    $0xc,%esp
  80154e:	ff 75 f4             	pushl  -0xc(%ebp)
  801551:	e8 f6 f7 ff ff       	call   800d4c <fd2num>
  801556:	89 c2                	mov    %eax,%edx
  801558:	83 c4 10             	add    $0x10,%esp
  80155b:	eb 05                	jmp    801562 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80155d:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801562:	89 d0                	mov    %edx,%eax
  801564:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801567:	c9                   	leave  
  801568:	c3                   	ret    

00801569 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801569:	55                   	push   %ebp
  80156a:	89 e5                	mov    %esp,%ebp
  80156c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80156f:	ba 00 00 00 00       	mov    $0x0,%edx
  801574:	b8 08 00 00 00       	mov    $0x8,%eax
  801579:	e8 7d fd ff ff       	call   8012fb <fsipc>
}
  80157e:	c9                   	leave  
  80157f:	c3                   	ret    

00801580 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801580:	55                   	push   %ebp
  801581:	89 e5                	mov    %esp,%ebp
  801583:	57                   	push   %edi
  801584:	56                   	push   %esi
  801585:	53                   	push   %ebx
  801586:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  80158c:	6a 00                	push   $0x0
  80158e:	ff 75 08             	pushl  0x8(%ebp)
  801591:	e8 46 ff ff ff       	call   8014dc <open>
  801596:	89 c7                	mov    %eax,%edi
  801598:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  80159e:	83 c4 10             	add    $0x10,%esp
  8015a1:	85 c0                	test   %eax,%eax
  8015a3:	0f 88 ae 04 00 00    	js     801a57 <spawn+0x4d7>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8015a9:	83 ec 04             	sub    $0x4,%esp
  8015ac:	68 00 02 00 00       	push   $0x200
  8015b1:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8015b7:	50                   	push   %eax
  8015b8:	57                   	push   %edi
  8015b9:	e8 fb fa ff ff       	call   8010b9 <readn>
  8015be:	83 c4 10             	add    $0x10,%esp
  8015c1:	3d 00 02 00 00       	cmp    $0x200,%eax
  8015c6:	75 0c                	jne    8015d4 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  8015c8:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8015cf:	45 4c 46 
  8015d2:	74 33                	je     801607 <spawn+0x87>
		close(fd);
  8015d4:	83 ec 0c             	sub    $0xc,%esp
  8015d7:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8015dd:	e8 0a f9 ff ff       	call   800eec <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  8015e2:	83 c4 0c             	add    $0xc,%esp
  8015e5:	68 7f 45 4c 46       	push   $0x464c457f
  8015ea:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  8015f0:	68 bb 2c 80 00       	push   $0x802cbb
  8015f5:	e8 ba eb ff ff       	call   8001b4 <cprintf>
		return -E_NOT_EXEC;
  8015fa:	83 c4 10             	add    $0x10,%esp
  8015fd:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801602:	e9 b0 04 00 00       	jmp    801ab7 <spawn+0x537>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801607:	b8 07 00 00 00       	mov    $0x7,%eax
  80160c:	cd 30                	int    $0x30
  80160e:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801614:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  80161a:	85 c0                	test   %eax,%eax
  80161c:	0f 88 3d 04 00 00    	js     801a5f <spawn+0x4df>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801622:	89 c6                	mov    %eax,%esi
  801624:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  80162a:	6b f6 7c             	imul   $0x7c,%esi,%esi
  80162d:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801633:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801639:	b9 11 00 00 00       	mov    $0x11,%ecx
  80163e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801640:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801646:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80164c:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801651:	be 00 00 00 00       	mov    $0x0,%esi
  801656:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801659:	eb 13                	jmp    80166e <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  80165b:	83 ec 0c             	sub    $0xc,%esp
  80165e:	50                   	push   %eax
  80165f:	e8 9c f0 ff ff       	call   800700 <strlen>
  801664:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801668:	83 c3 01             	add    $0x1,%ebx
  80166b:	83 c4 10             	add    $0x10,%esp
  80166e:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801675:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801678:	85 c0                	test   %eax,%eax
  80167a:	75 df                	jne    80165b <spawn+0xdb>
  80167c:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801682:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801688:	bf 00 10 40 00       	mov    $0x401000,%edi
  80168d:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  80168f:	89 fa                	mov    %edi,%edx
  801691:	83 e2 fc             	and    $0xfffffffc,%edx
  801694:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  80169b:	29 c2                	sub    %eax,%edx
  80169d:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8016a3:	8d 42 f8             	lea    -0x8(%edx),%eax
  8016a6:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8016ab:	0f 86 be 03 00 00    	jbe    801a6f <spawn+0x4ef>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8016b1:	83 ec 04             	sub    $0x4,%esp
  8016b4:	6a 07                	push   $0x7
  8016b6:	68 00 00 40 00       	push   $0x400000
  8016bb:	6a 00                	push   $0x0
  8016bd:	e8 7a f4 ff ff       	call   800b3c <sys_page_alloc>
  8016c2:	83 c4 10             	add    $0x10,%esp
  8016c5:	85 c0                	test   %eax,%eax
  8016c7:	0f 88 a9 03 00 00    	js     801a76 <spawn+0x4f6>
  8016cd:	be 00 00 00 00       	mov    $0x0,%esi
  8016d2:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  8016d8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016db:	eb 30                	jmp    80170d <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  8016dd:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  8016e3:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  8016e9:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  8016ec:	83 ec 08             	sub    $0x8,%esp
  8016ef:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8016f2:	57                   	push   %edi
  8016f3:	e8 41 f0 ff ff       	call   800739 <strcpy>
		string_store += strlen(argv[i]) + 1;
  8016f8:	83 c4 04             	add    $0x4,%esp
  8016fb:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8016fe:	e8 fd ef ff ff       	call   800700 <strlen>
  801703:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801707:	83 c6 01             	add    $0x1,%esi
  80170a:	83 c4 10             	add    $0x10,%esp
  80170d:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801713:	7f c8                	jg     8016dd <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801715:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  80171b:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801721:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801728:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  80172e:	74 19                	je     801749 <spawn+0x1c9>
  801730:	68 30 2d 80 00       	push   $0x802d30
  801735:	68 88 2c 80 00       	push   $0x802c88
  80173a:	68 f2 00 00 00       	push   $0xf2
  80173f:	68 d5 2c 80 00       	push   $0x802cd5
  801744:	e8 92 e9 ff ff       	call   8000db <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801749:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  80174f:	89 f8                	mov    %edi,%eax
  801751:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801756:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801759:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  80175f:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801762:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801768:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  80176e:	83 ec 0c             	sub    $0xc,%esp
  801771:	6a 07                	push   $0x7
  801773:	68 00 d0 bf ee       	push   $0xeebfd000
  801778:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  80177e:	68 00 00 40 00       	push   $0x400000
  801783:	6a 00                	push   $0x0
  801785:	e8 f5 f3 ff ff       	call   800b7f <sys_page_map>
  80178a:	89 c3                	mov    %eax,%ebx
  80178c:	83 c4 20             	add    $0x20,%esp
  80178f:	85 c0                	test   %eax,%eax
  801791:	0f 88 0e 03 00 00    	js     801aa5 <spawn+0x525>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801797:	83 ec 08             	sub    $0x8,%esp
  80179a:	68 00 00 40 00       	push   $0x400000
  80179f:	6a 00                	push   $0x0
  8017a1:	e8 1b f4 ff ff       	call   800bc1 <sys_page_unmap>
  8017a6:	89 c3                	mov    %eax,%ebx
  8017a8:	83 c4 10             	add    $0x10,%esp
  8017ab:	85 c0                	test   %eax,%eax
  8017ad:	0f 88 f2 02 00 00    	js     801aa5 <spawn+0x525>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  8017b3:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  8017b9:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  8017c0:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8017c6:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  8017cd:	00 00 00 
  8017d0:	e9 88 01 00 00       	jmp    80195d <spawn+0x3dd>
		if (ph->p_type != ELF_PROG_LOAD)
  8017d5:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  8017db:	83 38 01             	cmpl   $0x1,(%eax)
  8017de:	0f 85 6b 01 00 00    	jne    80194f <spawn+0x3cf>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  8017e4:	89 c7                	mov    %eax,%edi
  8017e6:	8b 40 18             	mov    0x18(%eax),%eax
  8017e9:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  8017ef:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  8017f2:	83 f8 01             	cmp    $0x1,%eax
  8017f5:	19 c0                	sbb    %eax,%eax
  8017f7:	83 e0 fe             	and    $0xfffffffe,%eax
  8017fa:	83 c0 07             	add    $0x7,%eax
  8017fd:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801803:	89 f8                	mov    %edi,%eax
  801805:	8b 7f 04             	mov    0x4(%edi),%edi
  801808:	89 f9                	mov    %edi,%ecx
  80180a:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801810:	8b 78 10             	mov    0x10(%eax),%edi
  801813:	8b 50 14             	mov    0x14(%eax),%edx
  801816:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  80181c:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  80181f:	89 f0                	mov    %esi,%eax
  801821:	25 ff 0f 00 00       	and    $0xfff,%eax
  801826:	74 14                	je     80183c <spawn+0x2bc>
		va -= i;
  801828:	29 c6                	sub    %eax,%esi
		memsz += i;
  80182a:	01 c2                	add    %eax,%edx
  80182c:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  801832:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801834:	29 c1                	sub    %eax,%ecx
  801836:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  80183c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801841:	e9 f7 00 00 00       	jmp    80193d <spawn+0x3bd>
		if (i >= filesz) {
  801846:	39 df                	cmp    %ebx,%edi
  801848:	77 27                	ja     801871 <spawn+0x2f1>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  80184a:	83 ec 04             	sub    $0x4,%esp
  80184d:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801853:	56                   	push   %esi
  801854:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  80185a:	e8 dd f2 ff ff       	call   800b3c <sys_page_alloc>
  80185f:	83 c4 10             	add    $0x10,%esp
  801862:	85 c0                	test   %eax,%eax
  801864:	0f 89 c7 00 00 00    	jns    801931 <spawn+0x3b1>
  80186a:	89 c3                	mov    %eax,%ebx
  80186c:	e9 13 02 00 00       	jmp    801a84 <spawn+0x504>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801871:	83 ec 04             	sub    $0x4,%esp
  801874:	6a 07                	push   $0x7
  801876:	68 00 00 40 00       	push   $0x400000
  80187b:	6a 00                	push   $0x0
  80187d:	e8 ba f2 ff ff       	call   800b3c <sys_page_alloc>
  801882:	83 c4 10             	add    $0x10,%esp
  801885:	85 c0                	test   %eax,%eax
  801887:	0f 88 ed 01 00 00    	js     801a7a <spawn+0x4fa>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  80188d:	83 ec 08             	sub    $0x8,%esp
  801890:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801896:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  80189c:	50                   	push   %eax
  80189d:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8018a3:	e8 e6 f8 ff ff       	call   80118e <seek>
  8018a8:	83 c4 10             	add    $0x10,%esp
  8018ab:	85 c0                	test   %eax,%eax
  8018ad:	0f 88 cb 01 00 00    	js     801a7e <spawn+0x4fe>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  8018b3:	83 ec 04             	sub    $0x4,%esp
  8018b6:	89 f8                	mov    %edi,%eax
  8018b8:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  8018be:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018c3:	ba 00 10 00 00       	mov    $0x1000,%edx
  8018c8:	0f 47 c2             	cmova  %edx,%eax
  8018cb:	50                   	push   %eax
  8018cc:	68 00 00 40 00       	push   $0x400000
  8018d1:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8018d7:	e8 dd f7 ff ff       	call   8010b9 <readn>
  8018dc:	83 c4 10             	add    $0x10,%esp
  8018df:	85 c0                	test   %eax,%eax
  8018e1:	0f 88 9b 01 00 00    	js     801a82 <spawn+0x502>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  8018e7:	83 ec 0c             	sub    $0xc,%esp
  8018ea:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  8018f0:	56                   	push   %esi
  8018f1:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  8018f7:	68 00 00 40 00       	push   $0x400000
  8018fc:	6a 00                	push   $0x0
  8018fe:	e8 7c f2 ff ff       	call   800b7f <sys_page_map>
  801903:	83 c4 20             	add    $0x20,%esp
  801906:	85 c0                	test   %eax,%eax
  801908:	79 15                	jns    80191f <spawn+0x39f>
				panic("spawn: sys_page_map data: %e", r);
  80190a:	50                   	push   %eax
  80190b:	68 e1 2c 80 00       	push   $0x802ce1
  801910:	68 25 01 00 00       	push   $0x125
  801915:	68 d5 2c 80 00       	push   $0x802cd5
  80191a:	e8 bc e7 ff ff       	call   8000db <_panic>
			sys_page_unmap(0, UTEMP);
  80191f:	83 ec 08             	sub    $0x8,%esp
  801922:	68 00 00 40 00       	push   $0x400000
  801927:	6a 00                	push   $0x0
  801929:	e8 93 f2 ff ff       	call   800bc1 <sys_page_unmap>
  80192e:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801931:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801937:	81 c6 00 10 00 00    	add    $0x1000,%esi
  80193d:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801943:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  801949:	0f 87 f7 fe ff ff    	ja     801846 <spawn+0x2c6>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  80194f:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801956:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  80195d:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801964:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  80196a:	0f 8c 65 fe ff ff    	jl     8017d5 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801970:	83 ec 0c             	sub    $0xc,%esp
  801973:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801979:	e8 6e f5 ff ff       	call   800eec <close>
  80197e:	83 c4 10             	add    $0x10,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	uintptr_t i;
	for (i = 0; i < USTACKTOP; i += PGSIZE){
  801981:	bb 00 00 00 00       	mov    $0x0,%ebx
  801986:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[PGNUM(i)] & PTE_P) && (uvpt[PGNUM(i)] & PTE_U) && (uvpt[PGNUM(i)] & PTE_SHARE)){
  80198c:	89 d8                	mov    %ebx,%eax
  80198e:	c1 e8 16             	shr    $0x16,%eax
  801991:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801998:	a8 01                	test   $0x1,%al
  80199a:	74 46                	je     8019e2 <spawn+0x462>
  80199c:	89 d8                	mov    %ebx,%eax
  80199e:	c1 e8 0c             	shr    $0xc,%eax
  8019a1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8019a8:	f6 c2 01             	test   $0x1,%dl
  8019ab:	74 35                	je     8019e2 <spawn+0x462>
  8019ad:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8019b4:	f6 c2 04             	test   $0x4,%dl
  8019b7:	74 29                	je     8019e2 <spawn+0x462>
  8019b9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8019c0:	f6 c6 04             	test   $0x4,%dh
  8019c3:	74 1d                	je     8019e2 <spawn+0x462>
			sys_page_map(0, (void*)i,child, (void*)i,(uvpt[PGNUM(i)] | PTE_SYSCALL));
  8019c5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8019cc:	83 ec 0c             	sub    $0xc,%esp
  8019cf:	0d 07 0e 00 00       	or     $0xe07,%eax
  8019d4:	50                   	push   %eax
  8019d5:	53                   	push   %ebx
  8019d6:	56                   	push   %esi
  8019d7:	53                   	push   %ebx
  8019d8:	6a 00                	push   $0x0
  8019da:	e8 a0 f1 ff ff       	call   800b7f <sys_page_map>
  8019df:	83 c4 20             	add    $0x20,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	uintptr_t i;
	for (i = 0; i < USTACKTOP; i += PGSIZE){
  8019e2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8019e8:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8019ee:	75 9c                	jne    80198c <spawn+0x40c>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  8019f0:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  8019f7:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  8019fa:	83 ec 08             	sub    $0x8,%esp
  8019fd:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801a03:	50                   	push   %eax
  801a04:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801a0a:	e8 36 f2 ff ff       	call   800c45 <sys_env_set_trapframe>
  801a0f:	83 c4 10             	add    $0x10,%esp
  801a12:	85 c0                	test   %eax,%eax
  801a14:	79 15                	jns    801a2b <spawn+0x4ab>
		panic("sys_env_set_trapframe: %e", r);
  801a16:	50                   	push   %eax
  801a17:	68 fe 2c 80 00       	push   $0x802cfe
  801a1c:	68 86 00 00 00       	push   $0x86
  801a21:	68 d5 2c 80 00       	push   $0x802cd5
  801a26:	e8 b0 e6 ff ff       	call   8000db <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801a2b:	83 ec 08             	sub    $0x8,%esp
  801a2e:	6a 02                	push   $0x2
  801a30:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801a36:	e8 c8 f1 ff ff       	call   800c03 <sys_env_set_status>
  801a3b:	83 c4 10             	add    $0x10,%esp
  801a3e:	85 c0                	test   %eax,%eax
  801a40:	79 25                	jns    801a67 <spawn+0x4e7>
		panic("sys_env_set_status: %e", r);
  801a42:	50                   	push   %eax
  801a43:	68 18 2d 80 00       	push   $0x802d18
  801a48:	68 89 00 00 00       	push   $0x89
  801a4d:	68 d5 2c 80 00       	push   $0x802cd5
  801a52:	e8 84 e6 ff ff       	call   8000db <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801a57:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801a5d:	eb 58                	jmp    801ab7 <spawn+0x537>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801a5f:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801a65:	eb 50                	jmp    801ab7 <spawn+0x537>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801a67:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801a6d:	eb 48                	jmp    801ab7 <spawn+0x537>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801a6f:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801a74:	eb 41                	jmp    801ab7 <spawn+0x537>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801a76:	89 c3                	mov    %eax,%ebx
  801a78:	eb 3d                	jmp    801ab7 <spawn+0x537>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801a7a:	89 c3                	mov    %eax,%ebx
  801a7c:	eb 06                	jmp    801a84 <spawn+0x504>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801a7e:	89 c3                	mov    %eax,%ebx
  801a80:	eb 02                	jmp    801a84 <spawn+0x504>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801a82:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801a84:	83 ec 0c             	sub    $0xc,%esp
  801a87:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801a8d:	e8 2b f0 ff ff       	call   800abd <sys_env_destroy>
	close(fd);
  801a92:	83 c4 04             	add    $0x4,%esp
  801a95:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801a9b:	e8 4c f4 ff ff       	call   800eec <close>
	return r;
  801aa0:	83 c4 10             	add    $0x10,%esp
  801aa3:	eb 12                	jmp    801ab7 <spawn+0x537>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801aa5:	83 ec 08             	sub    $0x8,%esp
  801aa8:	68 00 00 40 00       	push   $0x400000
  801aad:	6a 00                	push   $0x0
  801aaf:	e8 0d f1 ff ff       	call   800bc1 <sys_page_unmap>
  801ab4:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801ab7:	89 d8                	mov    %ebx,%eax
  801ab9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801abc:	5b                   	pop    %ebx
  801abd:	5e                   	pop    %esi
  801abe:	5f                   	pop    %edi
  801abf:	5d                   	pop    %ebp
  801ac0:	c3                   	ret    

00801ac1 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801ac1:	55                   	push   %ebp
  801ac2:	89 e5                	mov    %esp,%ebp
  801ac4:	56                   	push   %esi
  801ac5:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801ac6:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801ac9:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801ace:	eb 03                	jmp    801ad3 <spawnl+0x12>
		argc++;
  801ad0:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801ad3:	83 c2 04             	add    $0x4,%edx
  801ad6:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801ada:	75 f4                	jne    801ad0 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801adc:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801ae3:	83 e2 f0             	and    $0xfffffff0,%edx
  801ae6:	29 d4                	sub    %edx,%esp
  801ae8:	8d 54 24 03          	lea    0x3(%esp),%edx
  801aec:	c1 ea 02             	shr    $0x2,%edx
  801aef:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801af6:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801af8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801afb:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801b02:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801b09:	00 
  801b0a:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801b0c:	b8 00 00 00 00       	mov    $0x0,%eax
  801b11:	eb 0a                	jmp    801b1d <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801b13:	83 c0 01             	add    $0x1,%eax
  801b16:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801b1a:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801b1d:	39 d0                	cmp    %edx,%eax
  801b1f:	75 f2                	jne    801b13 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801b21:	83 ec 08             	sub    $0x8,%esp
  801b24:	56                   	push   %esi
  801b25:	ff 75 08             	pushl  0x8(%ebp)
  801b28:	e8 53 fa ff ff       	call   801580 <spawn>
}
  801b2d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b30:	5b                   	pop    %ebx
  801b31:	5e                   	pop    %esi
  801b32:	5d                   	pop    %ebp
  801b33:	c3                   	ret    

00801b34 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801b34:	55                   	push   %ebp
  801b35:	89 e5                	mov    %esp,%ebp
  801b37:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801b3a:	68 58 2d 80 00       	push   $0x802d58
  801b3f:	ff 75 0c             	pushl  0xc(%ebp)
  801b42:	e8 f2 eb ff ff       	call   800739 <strcpy>
	return 0;
}
  801b47:	b8 00 00 00 00       	mov    $0x0,%eax
  801b4c:	c9                   	leave  
  801b4d:	c3                   	ret    

00801b4e <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801b4e:	55                   	push   %ebp
  801b4f:	89 e5                	mov    %esp,%ebp
  801b51:	53                   	push   %ebx
  801b52:	83 ec 10             	sub    $0x10,%esp
  801b55:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801b58:	53                   	push   %ebx
  801b59:	e8 12 0a 00 00       	call   802570 <pageref>
  801b5e:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801b61:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801b66:	83 f8 01             	cmp    $0x1,%eax
  801b69:	75 10                	jne    801b7b <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801b6b:	83 ec 0c             	sub    $0xc,%esp
  801b6e:	ff 73 0c             	pushl  0xc(%ebx)
  801b71:	e8 c0 02 00 00       	call   801e36 <nsipc_close>
  801b76:	89 c2                	mov    %eax,%edx
  801b78:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801b7b:	89 d0                	mov    %edx,%eax
  801b7d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b80:	c9                   	leave  
  801b81:	c3                   	ret    

00801b82 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801b82:	55                   	push   %ebp
  801b83:	89 e5                	mov    %esp,%ebp
  801b85:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801b88:	6a 00                	push   $0x0
  801b8a:	ff 75 10             	pushl  0x10(%ebp)
  801b8d:	ff 75 0c             	pushl  0xc(%ebp)
  801b90:	8b 45 08             	mov    0x8(%ebp),%eax
  801b93:	ff 70 0c             	pushl  0xc(%eax)
  801b96:	e8 78 03 00 00       	call   801f13 <nsipc_send>
}
  801b9b:	c9                   	leave  
  801b9c:	c3                   	ret    

00801b9d <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801b9d:	55                   	push   %ebp
  801b9e:	89 e5                	mov    %esp,%ebp
  801ba0:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801ba3:	6a 00                	push   $0x0
  801ba5:	ff 75 10             	pushl  0x10(%ebp)
  801ba8:	ff 75 0c             	pushl  0xc(%ebp)
  801bab:	8b 45 08             	mov    0x8(%ebp),%eax
  801bae:	ff 70 0c             	pushl  0xc(%eax)
  801bb1:	e8 f1 02 00 00       	call   801ea7 <nsipc_recv>
}
  801bb6:	c9                   	leave  
  801bb7:	c3                   	ret    

00801bb8 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801bb8:	55                   	push   %ebp
  801bb9:	89 e5                	mov    %esp,%ebp
  801bbb:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801bbe:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801bc1:	52                   	push   %edx
  801bc2:	50                   	push   %eax
  801bc3:	e8 fa f1 ff ff       	call   800dc2 <fd_lookup>
  801bc8:	83 c4 10             	add    $0x10,%esp
  801bcb:	85 c0                	test   %eax,%eax
  801bcd:	78 17                	js     801be6 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801bcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bd2:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801bd8:	39 08                	cmp    %ecx,(%eax)
  801bda:	75 05                	jne    801be1 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801bdc:	8b 40 0c             	mov    0xc(%eax),%eax
  801bdf:	eb 05                	jmp    801be6 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801be1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801be6:	c9                   	leave  
  801be7:	c3                   	ret    

00801be8 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801be8:	55                   	push   %ebp
  801be9:	89 e5                	mov    %esp,%ebp
  801beb:	56                   	push   %esi
  801bec:	53                   	push   %ebx
  801bed:	83 ec 1c             	sub    $0x1c,%esp
  801bf0:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801bf2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bf5:	50                   	push   %eax
  801bf6:	e8 78 f1 ff ff       	call   800d73 <fd_alloc>
  801bfb:	89 c3                	mov    %eax,%ebx
  801bfd:	83 c4 10             	add    $0x10,%esp
  801c00:	85 c0                	test   %eax,%eax
  801c02:	78 1b                	js     801c1f <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801c04:	83 ec 04             	sub    $0x4,%esp
  801c07:	68 07 04 00 00       	push   $0x407
  801c0c:	ff 75 f4             	pushl  -0xc(%ebp)
  801c0f:	6a 00                	push   $0x0
  801c11:	e8 26 ef ff ff       	call   800b3c <sys_page_alloc>
  801c16:	89 c3                	mov    %eax,%ebx
  801c18:	83 c4 10             	add    $0x10,%esp
  801c1b:	85 c0                	test   %eax,%eax
  801c1d:	79 10                	jns    801c2f <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801c1f:	83 ec 0c             	sub    $0xc,%esp
  801c22:	56                   	push   %esi
  801c23:	e8 0e 02 00 00       	call   801e36 <nsipc_close>
		return r;
  801c28:	83 c4 10             	add    $0x10,%esp
  801c2b:	89 d8                	mov    %ebx,%eax
  801c2d:	eb 24                	jmp    801c53 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801c2f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c35:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c38:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801c3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c3d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801c44:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801c47:	83 ec 0c             	sub    $0xc,%esp
  801c4a:	50                   	push   %eax
  801c4b:	e8 fc f0 ff ff       	call   800d4c <fd2num>
  801c50:	83 c4 10             	add    $0x10,%esp
}
  801c53:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c56:	5b                   	pop    %ebx
  801c57:	5e                   	pop    %esi
  801c58:	5d                   	pop    %ebp
  801c59:	c3                   	ret    

00801c5a <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c5a:	55                   	push   %ebp
  801c5b:	89 e5                	mov    %esp,%ebp
  801c5d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c60:	8b 45 08             	mov    0x8(%ebp),%eax
  801c63:	e8 50 ff ff ff       	call   801bb8 <fd2sockid>
		return r;
  801c68:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c6a:	85 c0                	test   %eax,%eax
  801c6c:	78 1f                	js     801c8d <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801c6e:	83 ec 04             	sub    $0x4,%esp
  801c71:	ff 75 10             	pushl  0x10(%ebp)
  801c74:	ff 75 0c             	pushl  0xc(%ebp)
  801c77:	50                   	push   %eax
  801c78:	e8 12 01 00 00       	call   801d8f <nsipc_accept>
  801c7d:	83 c4 10             	add    $0x10,%esp
		return r;
  801c80:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801c82:	85 c0                	test   %eax,%eax
  801c84:	78 07                	js     801c8d <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801c86:	e8 5d ff ff ff       	call   801be8 <alloc_sockfd>
  801c8b:	89 c1                	mov    %eax,%ecx
}
  801c8d:	89 c8                	mov    %ecx,%eax
  801c8f:	c9                   	leave  
  801c90:	c3                   	ret    

00801c91 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c91:	55                   	push   %ebp
  801c92:	89 e5                	mov    %esp,%ebp
  801c94:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c97:	8b 45 08             	mov    0x8(%ebp),%eax
  801c9a:	e8 19 ff ff ff       	call   801bb8 <fd2sockid>
  801c9f:	85 c0                	test   %eax,%eax
  801ca1:	78 12                	js     801cb5 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801ca3:	83 ec 04             	sub    $0x4,%esp
  801ca6:	ff 75 10             	pushl  0x10(%ebp)
  801ca9:	ff 75 0c             	pushl  0xc(%ebp)
  801cac:	50                   	push   %eax
  801cad:	e8 2d 01 00 00       	call   801ddf <nsipc_bind>
  801cb2:	83 c4 10             	add    $0x10,%esp
}
  801cb5:	c9                   	leave  
  801cb6:	c3                   	ret    

00801cb7 <shutdown>:

int
shutdown(int s, int how)
{
  801cb7:	55                   	push   %ebp
  801cb8:	89 e5                	mov    %esp,%ebp
  801cba:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801cbd:	8b 45 08             	mov    0x8(%ebp),%eax
  801cc0:	e8 f3 fe ff ff       	call   801bb8 <fd2sockid>
  801cc5:	85 c0                	test   %eax,%eax
  801cc7:	78 0f                	js     801cd8 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801cc9:	83 ec 08             	sub    $0x8,%esp
  801ccc:	ff 75 0c             	pushl  0xc(%ebp)
  801ccf:	50                   	push   %eax
  801cd0:	e8 3f 01 00 00       	call   801e14 <nsipc_shutdown>
  801cd5:	83 c4 10             	add    $0x10,%esp
}
  801cd8:	c9                   	leave  
  801cd9:	c3                   	ret    

00801cda <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801cda:	55                   	push   %ebp
  801cdb:	89 e5                	mov    %esp,%ebp
  801cdd:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ce0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce3:	e8 d0 fe ff ff       	call   801bb8 <fd2sockid>
  801ce8:	85 c0                	test   %eax,%eax
  801cea:	78 12                	js     801cfe <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801cec:	83 ec 04             	sub    $0x4,%esp
  801cef:	ff 75 10             	pushl  0x10(%ebp)
  801cf2:	ff 75 0c             	pushl  0xc(%ebp)
  801cf5:	50                   	push   %eax
  801cf6:	e8 55 01 00 00       	call   801e50 <nsipc_connect>
  801cfb:	83 c4 10             	add    $0x10,%esp
}
  801cfe:	c9                   	leave  
  801cff:	c3                   	ret    

00801d00 <listen>:

int
listen(int s, int backlog)
{
  801d00:	55                   	push   %ebp
  801d01:	89 e5                	mov    %esp,%ebp
  801d03:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d06:	8b 45 08             	mov    0x8(%ebp),%eax
  801d09:	e8 aa fe ff ff       	call   801bb8 <fd2sockid>
  801d0e:	85 c0                	test   %eax,%eax
  801d10:	78 0f                	js     801d21 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801d12:	83 ec 08             	sub    $0x8,%esp
  801d15:	ff 75 0c             	pushl  0xc(%ebp)
  801d18:	50                   	push   %eax
  801d19:	e8 67 01 00 00       	call   801e85 <nsipc_listen>
  801d1e:	83 c4 10             	add    $0x10,%esp
}
  801d21:	c9                   	leave  
  801d22:	c3                   	ret    

00801d23 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801d23:	55                   	push   %ebp
  801d24:	89 e5                	mov    %esp,%ebp
  801d26:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801d29:	ff 75 10             	pushl  0x10(%ebp)
  801d2c:	ff 75 0c             	pushl  0xc(%ebp)
  801d2f:	ff 75 08             	pushl  0x8(%ebp)
  801d32:	e8 3a 02 00 00       	call   801f71 <nsipc_socket>
  801d37:	83 c4 10             	add    $0x10,%esp
  801d3a:	85 c0                	test   %eax,%eax
  801d3c:	78 05                	js     801d43 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801d3e:	e8 a5 fe ff ff       	call   801be8 <alloc_sockfd>
}
  801d43:	c9                   	leave  
  801d44:	c3                   	ret    

00801d45 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801d45:	55                   	push   %ebp
  801d46:	89 e5                	mov    %esp,%ebp
  801d48:	53                   	push   %ebx
  801d49:	83 ec 04             	sub    $0x4,%esp
  801d4c:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801d4e:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801d55:	75 12                	jne    801d69 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801d57:	83 ec 0c             	sub    $0xc,%esp
  801d5a:	6a 02                	push   $0x2
  801d5c:	e8 d6 07 00 00       	call   802537 <ipc_find_env>
  801d61:	a3 04 40 80 00       	mov    %eax,0x804004
  801d66:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801d69:	6a 07                	push   $0x7
  801d6b:	68 00 60 80 00       	push   $0x806000
  801d70:	53                   	push   %ebx
  801d71:	ff 35 04 40 80 00    	pushl  0x804004
  801d77:	e8 67 07 00 00       	call   8024e3 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801d7c:	83 c4 0c             	add    $0xc,%esp
  801d7f:	6a 00                	push   $0x0
  801d81:	6a 00                	push   $0x0
  801d83:	6a 00                	push   $0x0
  801d85:	e8 f0 06 00 00       	call   80247a <ipc_recv>
}
  801d8a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d8d:	c9                   	leave  
  801d8e:	c3                   	ret    

00801d8f <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801d8f:	55                   	push   %ebp
  801d90:	89 e5                	mov    %esp,%ebp
  801d92:	56                   	push   %esi
  801d93:	53                   	push   %ebx
  801d94:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801d97:	8b 45 08             	mov    0x8(%ebp),%eax
  801d9a:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801d9f:	8b 06                	mov    (%esi),%eax
  801da1:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801da6:	b8 01 00 00 00       	mov    $0x1,%eax
  801dab:	e8 95 ff ff ff       	call   801d45 <nsipc>
  801db0:	89 c3                	mov    %eax,%ebx
  801db2:	85 c0                	test   %eax,%eax
  801db4:	78 20                	js     801dd6 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801db6:	83 ec 04             	sub    $0x4,%esp
  801db9:	ff 35 10 60 80 00    	pushl  0x806010
  801dbf:	68 00 60 80 00       	push   $0x806000
  801dc4:	ff 75 0c             	pushl  0xc(%ebp)
  801dc7:	e8 ff ea ff ff       	call   8008cb <memmove>
		*addrlen = ret->ret_addrlen;
  801dcc:	a1 10 60 80 00       	mov    0x806010,%eax
  801dd1:	89 06                	mov    %eax,(%esi)
  801dd3:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801dd6:	89 d8                	mov    %ebx,%eax
  801dd8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ddb:	5b                   	pop    %ebx
  801ddc:	5e                   	pop    %esi
  801ddd:	5d                   	pop    %ebp
  801dde:	c3                   	ret    

00801ddf <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801ddf:	55                   	push   %ebp
  801de0:	89 e5                	mov    %esp,%ebp
  801de2:	53                   	push   %ebx
  801de3:	83 ec 08             	sub    $0x8,%esp
  801de6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801de9:	8b 45 08             	mov    0x8(%ebp),%eax
  801dec:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801df1:	53                   	push   %ebx
  801df2:	ff 75 0c             	pushl  0xc(%ebp)
  801df5:	68 04 60 80 00       	push   $0x806004
  801dfa:	e8 cc ea ff ff       	call   8008cb <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801dff:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801e05:	b8 02 00 00 00       	mov    $0x2,%eax
  801e0a:	e8 36 ff ff ff       	call   801d45 <nsipc>
}
  801e0f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e12:	c9                   	leave  
  801e13:	c3                   	ret    

00801e14 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801e14:	55                   	push   %ebp
  801e15:	89 e5                	mov    %esp,%ebp
  801e17:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801e1a:	8b 45 08             	mov    0x8(%ebp),%eax
  801e1d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801e22:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e25:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801e2a:	b8 03 00 00 00       	mov    $0x3,%eax
  801e2f:	e8 11 ff ff ff       	call   801d45 <nsipc>
}
  801e34:	c9                   	leave  
  801e35:	c3                   	ret    

00801e36 <nsipc_close>:

int
nsipc_close(int s)
{
  801e36:	55                   	push   %ebp
  801e37:	89 e5                	mov    %esp,%ebp
  801e39:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801e3c:	8b 45 08             	mov    0x8(%ebp),%eax
  801e3f:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801e44:	b8 04 00 00 00       	mov    $0x4,%eax
  801e49:	e8 f7 fe ff ff       	call   801d45 <nsipc>
}
  801e4e:	c9                   	leave  
  801e4f:	c3                   	ret    

00801e50 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801e50:	55                   	push   %ebp
  801e51:	89 e5                	mov    %esp,%ebp
  801e53:	53                   	push   %ebx
  801e54:	83 ec 08             	sub    $0x8,%esp
  801e57:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801e5a:	8b 45 08             	mov    0x8(%ebp),%eax
  801e5d:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801e62:	53                   	push   %ebx
  801e63:	ff 75 0c             	pushl  0xc(%ebp)
  801e66:	68 04 60 80 00       	push   $0x806004
  801e6b:	e8 5b ea ff ff       	call   8008cb <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801e70:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801e76:	b8 05 00 00 00       	mov    $0x5,%eax
  801e7b:	e8 c5 fe ff ff       	call   801d45 <nsipc>
}
  801e80:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e83:	c9                   	leave  
  801e84:	c3                   	ret    

00801e85 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801e85:	55                   	push   %ebp
  801e86:	89 e5                	mov    %esp,%ebp
  801e88:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801e8b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e8e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801e93:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e96:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801e9b:	b8 06 00 00 00       	mov    $0x6,%eax
  801ea0:	e8 a0 fe ff ff       	call   801d45 <nsipc>
}
  801ea5:	c9                   	leave  
  801ea6:	c3                   	ret    

00801ea7 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801ea7:	55                   	push   %ebp
  801ea8:	89 e5                	mov    %esp,%ebp
  801eaa:	56                   	push   %esi
  801eab:	53                   	push   %ebx
  801eac:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801eaf:	8b 45 08             	mov    0x8(%ebp),%eax
  801eb2:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801eb7:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801ebd:	8b 45 14             	mov    0x14(%ebp),%eax
  801ec0:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801ec5:	b8 07 00 00 00       	mov    $0x7,%eax
  801eca:	e8 76 fe ff ff       	call   801d45 <nsipc>
  801ecf:	89 c3                	mov    %eax,%ebx
  801ed1:	85 c0                	test   %eax,%eax
  801ed3:	78 35                	js     801f0a <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801ed5:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801eda:	7f 04                	jg     801ee0 <nsipc_recv+0x39>
  801edc:	39 c6                	cmp    %eax,%esi
  801ede:	7d 16                	jge    801ef6 <nsipc_recv+0x4f>
  801ee0:	68 64 2d 80 00       	push   $0x802d64
  801ee5:	68 88 2c 80 00       	push   $0x802c88
  801eea:	6a 62                	push   $0x62
  801eec:	68 79 2d 80 00       	push   $0x802d79
  801ef1:	e8 e5 e1 ff ff       	call   8000db <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801ef6:	83 ec 04             	sub    $0x4,%esp
  801ef9:	50                   	push   %eax
  801efa:	68 00 60 80 00       	push   $0x806000
  801eff:	ff 75 0c             	pushl  0xc(%ebp)
  801f02:	e8 c4 e9 ff ff       	call   8008cb <memmove>
  801f07:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801f0a:	89 d8                	mov    %ebx,%eax
  801f0c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f0f:	5b                   	pop    %ebx
  801f10:	5e                   	pop    %esi
  801f11:	5d                   	pop    %ebp
  801f12:	c3                   	ret    

00801f13 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801f13:	55                   	push   %ebp
  801f14:	89 e5                	mov    %esp,%ebp
  801f16:	53                   	push   %ebx
  801f17:	83 ec 04             	sub    $0x4,%esp
  801f1a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801f1d:	8b 45 08             	mov    0x8(%ebp),%eax
  801f20:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801f25:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801f2b:	7e 16                	jle    801f43 <nsipc_send+0x30>
  801f2d:	68 85 2d 80 00       	push   $0x802d85
  801f32:	68 88 2c 80 00       	push   $0x802c88
  801f37:	6a 6d                	push   $0x6d
  801f39:	68 79 2d 80 00       	push   $0x802d79
  801f3e:	e8 98 e1 ff ff       	call   8000db <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801f43:	83 ec 04             	sub    $0x4,%esp
  801f46:	53                   	push   %ebx
  801f47:	ff 75 0c             	pushl  0xc(%ebp)
  801f4a:	68 0c 60 80 00       	push   $0x80600c
  801f4f:	e8 77 e9 ff ff       	call   8008cb <memmove>
	nsipcbuf.send.req_size = size;
  801f54:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801f5a:	8b 45 14             	mov    0x14(%ebp),%eax
  801f5d:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801f62:	b8 08 00 00 00       	mov    $0x8,%eax
  801f67:	e8 d9 fd ff ff       	call   801d45 <nsipc>
}
  801f6c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f6f:	c9                   	leave  
  801f70:	c3                   	ret    

00801f71 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801f71:	55                   	push   %ebp
  801f72:	89 e5                	mov    %esp,%ebp
  801f74:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801f77:	8b 45 08             	mov    0x8(%ebp),%eax
  801f7a:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801f7f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f82:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801f87:	8b 45 10             	mov    0x10(%ebp),%eax
  801f8a:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801f8f:	b8 09 00 00 00       	mov    $0x9,%eax
  801f94:	e8 ac fd ff ff       	call   801d45 <nsipc>
}
  801f99:	c9                   	leave  
  801f9a:	c3                   	ret    

00801f9b <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801f9b:	55                   	push   %ebp
  801f9c:	89 e5                	mov    %esp,%ebp
  801f9e:	56                   	push   %esi
  801f9f:	53                   	push   %ebx
  801fa0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801fa3:	83 ec 0c             	sub    $0xc,%esp
  801fa6:	ff 75 08             	pushl  0x8(%ebp)
  801fa9:	e8 ae ed ff ff       	call   800d5c <fd2data>
  801fae:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801fb0:	83 c4 08             	add    $0x8,%esp
  801fb3:	68 91 2d 80 00       	push   $0x802d91
  801fb8:	53                   	push   %ebx
  801fb9:	e8 7b e7 ff ff       	call   800739 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801fbe:	8b 46 04             	mov    0x4(%esi),%eax
  801fc1:	2b 06                	sub    (%esi),%eax
  801fc3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801fc9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801fd0:	00 00 00 
	stat->st_dev = &devpipe;
  801fd3:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801fda:	30 80 00 
	return 0;
}
  801fdd:	b8 00 00 00 00       	mov    $0x0,%eax
  801fe2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fe5:	5b                   	pop    %ebx
  801fe6:	5e                   	pop    %esi
  801fe7:	5d                   	pop    %ebp
  801fe8:	c3                   	ret    

00801fe9 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801fe9:	55                   	push   %ebp
  801fea:	89 e5                	mov    %esp,%ebp
  801fec:	53                   	push   %ebx
  801fed:	83 ec 0c             	sub    $0xc,%esp
  801ff0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ff3:	53                   	push   %ebx
  801ff4:	6a 00                	push   $0x0
  801ff6:	e8 c6 eb ff ff       	call   800bc1 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ffb:	89 1c 24             	mov    %ebx,(%esp)
  801ffe:	e8 59 ed ff ff       	call   800d5c <fd2data>
  802003:	83 c4 08             	add    $0x8,%esp
  802006:	50                   	push   %eax
  802007:	6a 00                	push   $0x0
  802009:	e8 b3 eb ff ff       	call   800bc1 <sys_page_unmap>
}
  80200e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802011:	c9                   	leave  
  802012:	c3                   	ret    

00802013 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802013:	55                   	push   %ebp
  802014:	89 e5                	mov    %esp,%ebp
  802016:	57                   	push   %edi
  802017:	56                   	push   %esi
  802018:	53                   	push   %ebx
  802019:	83 ec 1c             	sub    $0x1c,%esp
  80201c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80201f:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802021:	a1 08 40 80 00       	mov    0x804008,%eax
  802026:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  802029:	83 ec 0c             	sub    $0xc,%esp
  80202c:	ff 75 e0             	pushl  -0x20(%ebp)
  80202f:	e8 3c 05 00 00       	call   802570 <pageref>
  802034:	89 c3                	mov    %eax,%ebx
  802036:	89 3c 24             	mov    %edi,(%esp)
  802039:	e8 32 05 00 00       	call   802570 <pageref>
  80203e:	83 c4 10             	add    $0x10,%esp
  802041:	39 c3                	cmp    %eax,%ebx
  802043:	0f 94 c1             	sete   %cl
  802046:	0f b6 c9             	movzbl %cl,%ecx
  802049:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80204c:	8b 15 08 40 80 00    	mov    0x804008,%edx
  802052:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802055:	39 ce                	cmp    %ecx,%esi
  802057:	74 1b                	je     802074 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802059:	39 c3                	cmp    %eax,%ebx
  80205b:	75 c4                	jne    802021 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80205d:	8b 42 58             	mov    0x58(%edx),%eax
  802060:	ff 75 e4             	pushl  -0x1c(%ebp)
  802063:	50                   	push   %eax
  802064:	56                   	push   %esi
  802065:	68 98 2d 80 00       	push   $0x802d98
  80206a:	e8 45 e1 ff ff       	call   8001b4 <cprintf>
  80206f:	83 c4 10             	add    $0x10,%esp
  802072:	eb ad                	jmp    802021 <_pipeisclosed+0xe>
	}
}
  802074:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802077:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80207a:	5b                   	pop    %ebx
  80207b:	5e                   	pop    %esi
  80207c:	5f                   	pop    %edi
  80207d:	5d                   	pop    %ebp
  80207e:	c3                   	ret    

0080207f <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80207f:	55                   	push   %ebp
  802080:	89 e5                	mov    %esp,%ebp
  802082:	57                   	push   %edi
  802083:	56                   	push   %esi
  802084:	53                   	push   %ebx
  802085:	83 ec 28             	sub    $0x28,%esp
  802088:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80208b:	56                   	push   %esi
  80208c:	e8 cb ec ff ff       	call   800d5c <fd2data>
  802091:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802093:	83 c4 10             	add    $0x10,%esp
  802096:	bf 00 00 00 00       	mov    $0x0,%edi
  80209b:	eb 4b                	jmp    8020e8 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80209d:	89 da                	mov    %ebx,%edx
  80209f:	89 f0                	mov    %esi,%eax
  8020a1:	e8 6d ff ff ff       	call   802013 <_pipeisclosed>
  8020a6:	85 c0                	test   %eax,%eax
  8020a8:	75 48                	jne    8020f2 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8020aa:	e8 6e ea ff ff       	call   800b1d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8020af:	8b 43 04             	mov    0x4(%ebx),%eax
  8020b2:	8b 0b                	mov    (%ebx),%ecx
  8020b4:	8d 51 20             	lea    0x20(%ecx),%edx
  8020b7:	39 d0                	cmp    %edx,%eax
  8020b9:	73 e2                	jae    80209d <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8020bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8020be:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8020c2:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8020c5:	89 c2                	mov    %eax,%edx
  8020c7:	c1 fa 1f             	sar    $0x1f,%edx
  8020ca:	89 d1                	mov    %edx,%ecx
  8020cc:	c1 e9 1b             	shr    $0x1b,%ecx
  8020cf:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8020d2:	83 e2 1f             	and    $0x1f,%edx
  8020d5:	29 ca                	sub    %ecx,%edx
  8020d7:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8020db:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8020df:	83 c0 01             	add    $0x1,%eax
  8020e2:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020e5:	83 c7 01             	add    $0x1,%edi
  8020e8:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8020eb:	75 c2                	jne    8020af <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8020ed:	8b 45 10             	mov    0x10(%ebp),%eax
  8020f0:	eb 05                	jmp    8020f7 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8020f2:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8020f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020fa:	5b                   	pop    %ebx
  8020fb:	5e                   	pop    %esi
  8020fc:	5f                   	pop    %edi
  8020fd:	5d                   	pop    %ebp
  8020fe:	c3                   	ret    

008020ff <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8020ff:	55                   	push   %ebp
  802100:	89 e5                	mov    %esp,%ebp
  802102:	57                   	push   %edi
  802103:	56                   	push   %esi
  802104:	53                   	push   %ebx
  802105:	83 ec 18             	sub    $0x18,%esp
  802108:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80210b:	57                   	push   %edi
  80210c:	e8 4b ec ff ff       	call   800d5c <fd2data>
  802111:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802113:	83 c4 10             	add    $0x10,%esp
  802116:	bb 00 00 00 00       	mov    $0x0,%ebx
  80211b:	eb 3d                	jmp    80215a <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80211d:	85 db                	test   %ebx,%ebx
  80211f:	74 04                	je     802125 <devpipe_read+0x26>
				return i;
  802121:	89 d8                	mov    %ebx,%eax
  802123:	eb 44                	jmp    802169 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802125:	89 f2                	mov    %esi,%edx
  802127:	89 f8                	mov    %edi,%eax
  802129:	e8 e5 fe ff ff       	call   802013 <_pipeisclosed>
  80212e:	85 c0                	test   %eax,%eax
  802130:	75 32                	jne    802164 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802132:	e8 e6 e9 ff ff       	call   800b1d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802137:	8b 06                	mov    (%esi),%eax
  802139:	3b 46 04             	cmp    0x4(%esi),%eax
  80213c:	74 df                	je     80211d <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80213e:	99                   	cltd   
  80213f:	c1 ea 1b             	shr    $0x1b,%edx
  802142:	01 d0                	add    %edx,%eax
  802144:	83 e0 1f             	and    $0x1f,%eax
  802147:	29 d0                	sub    %edx,%eax
  802149:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80214e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802151:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802154:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802157:	83 c3 01             	add    $0x1,%ebx
  80215a:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80215d:	75 d8                	jne    802137 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80215f:	8b 45 10             	mov    0x10(%ebp),%eax
  802162:	eb 05                	jmp    802169 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802164:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802169:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80216c:	5b                   	pop    %ebx
  80216d:	5e                   	pop    %esi
  80216e:	5f                   	pop    %edi
  80216f:	5d                   	pop    %ebp
  802170:	c3                   	ret    

00802171 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802171:	55                   	push   %ebp
  802172:	89 e5                	mov    %esp,%ebp
  802174:	56                   	push   %esi
  802175:	53                   	push   %ebx
  802176:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802179:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80217c:	50                   	push   %eax
  80217d:	e8 f1 eb ff ff       	call   800d73 <fd_alloc>
  802182:	83 c4 10             	add    $0x10,%esp
  802185:	89 c2                	mov    %eax,%edx
  802187:	85 c0                	test   %eax,%eax
  802189:	0f 88 2c 01 00 00    	js     8022bb <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80218f:	83 ec 04             	sub    $0x4,%esp
  802192:	68 07 04 00 00       	push   $0x407
  802197:	ff 75 f4             	pushl  -0xc(%ebp)
  80219a:	6a 00                	push   $0x0
  80219c:	e8 9b e9 ff ff       	call   800b3c <sys_page_alloc>
  8021a1:	83 c4 10             	add    $0x10,%esp
  8021a4:	89 c2                	mov    %eax,%edx
  8021a6:	85 c0                	test   %eax,%eax
  8021a8:	0f 88 0d 01 00 00    	js     8022bb <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8021ae:	83 ec 0c             	sub    $0xc,%esp
  8021b1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8021b4:	50                   	push   %eax
  8021b5:	e8 b9 eb ff ff       	call   800d73 <fd_alloc>
  8021ba:	89 c3                	mov    %eax,%ebx
  8021bc:	83 c4 10             	add    $0x10,%esp
  8021bf:	85 c0                	test   %eax,%eax
  8021c1:	0f 88 e2 00 00 00    	js     8022a9 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021c7:	83 ec 04             	sub    $0x4,%esp
  8021ca:	68 07 04 00 00       	push   $0x407
  8021cf:	ff 75 f0             	pushl  -0x10(%ebp)
  8021d2:	6a 00                	push   $0x0
  8021d4:	e8 63 e9 ff ff       	call   800b3c <sys_page_alloc>
  8021d9:	89 c3                	mov    %eax,%ebx
  8021db:	83 c4 10             	add    $0x10,%esp
  8021de:	85 c0                	test   %eax,%eax
  8021e0:	0f 88 c3 00 00 00    	js     8022a9 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8021e6:	83 ec 0c             	sub    $0xc,%esp
  8021e9:	ff 75 f4             	pushl  -0xc(%ebp)
  8021ec:	e8 6b eb ff ff       	call   800d5c <fd2data>
  8021f1:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021f3:	83 c4 0c             	add    $0xc,%esp
  8021f6:	68 07 04 00 00       	push   $0x407
  8021fb:	50                   	push   %eax
  8021fc:	6a 00                	push   $0x0
  8021fe:	e8 39 e9 ff ff       	call   800b3c <sys_page_alloc>
  802203:	89 c3                	mov    %eax,%ebx
  802205:	83 c4 10             	add    $0x10,%esp
  802208:	85 c0                	test   %eax,%eax
  80220a:	0f 88 89 00 00 00    	js     802299 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802210:	83 ec 0c             	sub    $0xc,%esp
  802213:	ff 75 f0             	pushl  -0x10(%ebp)
  802216:	e8 41 eb ff ff       	call   800d5c <fd2data>
  80221b:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802222:	50                   	push   %eax
  802223:	6a 00                	push   $0x0
  802225:	56                   	push   %esi
  802226:	6a 00                	push   $0x0
  802228:	e8 52 e9 ff ff       	call   800b7f <sys_page_map>
  80222d:	89 c3                	mov    %eax,%ebx
  80222f:	83 c4 20             	add    $0x20,%esp
  802232:	85 c0                	test   %eax,%eax
  802234:	78 55                	js     80228b <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802236:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80223c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80223f:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802241:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802244:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80224b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802251:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802254:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802256:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802259:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802260:	83 ec 0c             	sub    $0xc,%esp
  802263:	ff 75 f4             	pushl  -0xc(%ebp)
  802266:	e8 e1 ea ff ff       	call   800d4c <fd2num>
  80226b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80226e:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802270:	83 c4 04             	add    $0x4,%esp
  802273:	ff 75 f0             	pushl  -0x10(%ebp)
  802276:	e8 d1 ea ff ff       	call   800d4c <fd2num>
  80227b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80227e:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802281:	83 c4 10             	add    $0x10,%esp
  802284:	ba 00 00 00 00       	mov    $0x0,%edx
  802289:	eb 30                	jmp    8022bb <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80228b:	83 ec 08             	sub    $0x8,%esp
  80228e:	56                   	push   %esi
  80228f:	6a 00                	push   $0x0
  802291:	e8 2b e9 ff ff       	call   800bc1 <sys_page_unmap>
  802296:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802299:	83 ec 08             	sub    $0x8,%esp
  80229c:	ff 75 f0             	pushl  -0x10(%ebp)
  80229f:	6a 00                	push   $0x0
  8022a1:	e8 1b e9 ff ff       	call   800bc1 <sys_page_unmap>
  8022a6:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8022a9:	83 ec 08             	sub    $0x8,%esp
  8022ac:	ff 75 f4             	pushl  -0xc(%ebp)
  8022af:	6a 00                	push   $0x0
  8022b1:	e8 0b e9 ff ff       	call   800bc1 <sys_page_unmap>
  8022b6:	83 c4 10             	add    $0x10,%esp
  8022b9:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8022bb:	89 d0                	mov    %edx,%eax
  8022bd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022c0:	5b                   	pop    %ebx
  8022c1:	5e                   	pop    %esi
  8022c2:	5d                   	pop    %ebp
  8022c3:	c3                   	ret    

008022c4 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8022c4:	55                   	push   %ebp
  8022c5:	89 e5                	mov    %esp,%ebp
  8022c7:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8022ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022cd:	50                   	push   %eax
  8022ce:	ff 75 08             	pushl  0x8(%ebp)
  8022d1:	e8 ec ea ff ff       	call   800dc2 <fd_lookup>
  8022d6:	83 c4 10             	add    $0x10,%esp
  8022d9:	85 c0                	test   %eax,%eax
  8022db:	78 18                	js     8022f5 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8022dd:	83 ec 0c             	sub    $0xc,%esp
  8022e0:	ff 75 f4             	pushl  -0xc(%ebp)
  8022e3:	e8 74 ea ff ff       	call   800d5c <fd2data>
	return _pipeisclosed(fd, p);
  8022e8:	89 c2                	mov    %eax,%edx
  8022ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022ed:	e8 21 fd ff ff       	call   802013 <_pipeisclosed>
  8022f2:	83 c4 10             	add    $0x10,%esp
}
  8022f5:	c9                   	leave  
  8022f6:	c3                   	ret    

008022f7 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8022f7:	55                   	push   %ebp
  8022f8:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8022fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8022ff:	5d                   	pop    %ebp
  802300:	c3                   	ret    

00802301 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802301:	55                   	push   %ebp
  802302:	89 e5                	mov    %esp,%ebp
  802304:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802307:	68 b0 2d 80 00       	push   $0x802db0
  80230c:	ff 75 0c             	pushl  0xc(%ebp)
  80230f:	e8 25 e4 ff ff       	call   800739 <strcpy>
	return 0;
}
  802314:	b8 00 00 00 00       	mov    $0x0,%eax
  802319:	c9                   	leave  
  80231a:	c3                   	ret    

0080231b <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80231b:	55                   	push   %ebp
  80231c:	89 e5                	mov    %esp,%ebp
  80231e:	57                   	push   %edi
  80231f:	56                   	push   %esi
  802320:	53                   	push   %ebx
  802321:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802327:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80232c:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802332:	eb 2d                	jmp    802361 <devcons_write+0x46>
		m = n - tot;
  802334:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802337:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802339:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80233c:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802341:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802344:	83 ec 04             	sub    $0x4,%esp
  802347:	53                   	push   %ebx
  802348:	03 45 0c             	add    0xc(%ebp),%eax
  80234b:	50                   	push   %eax
  80234c:	57                   	push   %edi
  80234d:	e8 79 e5 ff ff       	call   8008cb <memmove>
		sys_cputs(buf, m);
  802352:	83 c4 08             	add    $0x8,%esp
  802355:	53                   	push   %ebx
  802356:	57                   	push   %edi
  802357:	e8 24 e7 ff ff       	call   800a80 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80235c:	01 de                	add    %ebx,%esi
  80235e:	83 c4 10             	add    $0x10,%esp
  802361:	89 f0                	mov    %esi,%eax
  802363:	3b 75 10             	cmp    0x10(%ebp),%esi
  802366:	72 cc                	jb     802334 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802368:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80236b:	5b                   	pop    %ebx
  80236c:	5e                   	pop    %esi
  80236d:	5f                   	pop    %edi
  80236e:	5d                   	pop    %ebp
  80236f:	c3                   	ret    

00802370 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802370:	55                   	push   %ebp
  802371:	89 e5                	mov    %esp,%ebp
  802373:	83 ec 08             	sub    $0x8,%esp
  802376:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80237b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80237f:	74 2a                	je     8023ab <devcons_read+0x3b>
  802381:	eb 05                	jmp    802388 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802383:	e8 95 e7 ff ff       	call   800b1d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802388:	e8 11 e7 ff ff       	call   800a9e <sys_cgetc>
  80238d:	85 c0                	test   %eax,%eax
  80238f:	74 f2                	je     802383 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802391:	85 c0                	test   %eax,%eax
  802393:	78 16                	js     8023ab <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802395:	83 f8 04             	cmp    $0x4,%eax
  802398:	74 0c                	je     8023a6 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80239a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80239d:	88 02                	mov    %al,(%edx)
	return 1;
  80239f:	b8 01 00 00 00       	mov    $0x1,%eax
  8023a4:	eb 05                	jmp    8023ab <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8023a6:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8023ab:	c9                   	leave  
  8023ac:	c3                   	ret    

008023ad <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8023ad:	55                   	push   %ebp
  8023ae:	89 e5                	mov    %esp,%ebp
  8023b0:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8023b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8023b6:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8023b9:	6a 01                	push   $0x1
  8023bb:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8023be:	50                   	push   %eax
  8023bf:	e8 bc e6 ff ff       	call   800a80 <sys_cputs>
}
  8023c4:	83 c4 10             	add    $0x10,%esp
  8023c7:	c9                   	leave  
  8023c8:	c3                   	ret    

008023c9 <getchar>:

int
getchar(void)
{
  8023c9:	55                   	push   %ebp
  8023ca:	89 e5                	mov    %esp,%ebp
  8023cc:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8023cf:	6a 01                	push   $0x1
  8023d1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8023d4:	50                   	push   %eax
  8023d5:	6a 00                	push   $0x0
  8023d7:	e8 4c ec ff ff       	call   801028 <read>
	if (r < 0)
  8023dc:	83 c4 10             	add    $0x10,%esp
  8023df:	85 c0                	test   %eax,%eax
  8023e1:	78 0f                	js     8023f2 <getchar+0x29>
		return r;
	if (r < 1)
  8023e3:	85 c0                	test   %eax,%eax
  8023e5:	7e 06                	jle    8023ed <getchar+0x24>
		return -E_EOF;
	return c;
  8023e7:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8023eb:	eb 05                	jmp    8023f2 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8023ed:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8023f2:	c9                   	leave  
  8023f3:	c3                   	ret    

008023f4 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8023f4:	55                   	push   %ebp
  8023f5:	89 e5                	mov    %esp,%ebp
  8023f7:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8023fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023fd:	50                   	push   %eax
  8023fe:	ff 75 08             	pushl  0x8(%ebp)
  802401:	e8 bc e9 ff ff       	call   800dc2 <fd_lookup>
  802406:	83 c4 10             	add    $0x10,%esp
  802409:	85 c0                	test   %eax,%eax
  80240b:	78 11                	js     80241e <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80240d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802410:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802416:	39 10                	cmp    %edx,(%eax)
  802418:	0f 94 c0             	sete   %al
  80241b:	0f b6 c0             	movzbl %al,%eax
}
  80241e:	c9                   	leave  
  80241f:	c3                   	ret    

00802420 <opencons>:

int
opencons(void)
{
  802420:	55                   	push   %ebp
  802421:	89 e5                	mov    %esp,%ebp
  802423:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802426:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802429:	50                   	push   %eax
  80242a:	e8 44 e9 ff ff       	call   800d73 <fd_alloc>
  80242f:	83 c4 10             	add    $0x10,%esp
		return r;
  802432:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802434:	85 c0                	test   %eax,%eax
  802436:	78 3e                	js     802476 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802438:	83 ec 04             	sub    $0x4,%esp
  80243b:	68 07 04 00 00       	push   $0x407
  802440:	ff 75 f4             	pushl  -0xc(%ebp)
  802443:	6a 00                	push   $0x0
  802445:	e8 f2 e6 ff ff       	call   800b3c <sys_page_alloc>
  80244a:	83 c4 10             	add    $0x10,%esp
		return r;
  80244d:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80244f:	85 c0                	test   %eax,%eax
  802451:	78 23                	js     802476 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802453:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802459:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80245c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80245e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802461:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802468:	83 ec 0c             	sub    $0xc,%esp
  80246b:	50                   	push   %eax
  80246c:	e8 db e8 ff ff       	call   800d4c <fd2num>
  802471:	89 c2                	mov    %eax,%edx
  802473:	83 c4 10             	add    $0x10,%esp
}
  802476:	89 d0                	mov    %edx,%eax
  802478:	c9                   	leave  
  802479:	c3                   	ret    

0080247a <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80247a:	55                   	push   %ebp
  80247b:	89 e5                	mov    %esp,%ebp
  80247d:	56                   	push   %esi
  80247e:	53                   	push   %ebx
  80247f:	8b 75 08             	mov    0x8(%ebp),%esi
  802482:	8b 45 0c             	mov    0xc(%ebp),%eax
  802485:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  802488:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  80248a:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  80248f:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  802492:	83 ec 0c             	sub    $0xc,%esp
  802495:	50                   	push   %eax
  802496:	e8 51 e8 ff ff       	call   800cec <sys_ipc_recv>

	if (r < 0) {
  80249b:	83 c4 10             	add    $0x10,%esp
  80249e:	85 c0                	test   %eax,%eax
  8024a0:	79 16                	jns    8024b8 <ipc_recv+0x3e>
		if (from_env_store)
  8024a2:	85 f6                	test   %esi,%esi
  8024a4:	74 06                	je     8024ac <ipc_recv+0x32>
			*from_env_store = 0;
  8024a6:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  8024ac:	85 db                	test   %ebx,%ebx
  8024ae:	74 2c                	je     8024dc <ipc_recv+0x62>
			*perm_store = 0;
  8024b0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8024b6:	eb 24                	jmp    8024dc <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  8024b8:	85 f6                	test   %esi,%esi
  8024ba:	74 0a                	je     8024c6 <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  8024bc:	a1 08 40 80 00       	mov    0x804008,%eax
  8024c1:	8b 40 74             	mov    0x74(%eax),%eax
  8024c4:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  8024c6:	85 db                	test   %ebx,%ebx
  8024c8:	74 0a                	je     8024d4 <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  8024ca:	a1 08 40 80 00       	mov    0x804008,%eax
  8024cf:	8b 40 78             	mov    0x78(%eax),%eax
  8024d2:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  8024d4:	a1 08 40 80 00       	mov    0x804008,%eax
  8024d9:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  8024dc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8024df:	5b                   	pop    %ebx
  8024e0:	5e                   	pop    %esi
  8024e1:	5d                   	pop    %ebp
  8024e2:	c3                   	ret    

008024e3 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8024e3:	55                   	push   %ebp
  8024e4:	89 e5                	mov    %esp,%ebp
  8024e6:	57                   	push   %edi
  8024e7:	56                   	push   %esi
  8024e8:	53                   	push   %ebx
  8024e9:	83 ec 0c             	sub    $0xc,%esp
  8024ec:	8b 7d 08             	mov    0x8(%ebp),%edi
  8024ef:	8b 75 0c             	mov    0xc(%ebp),%esi
  8024f2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  8024f5:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  8024f7:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  8024fc:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  8024ff:	ff 75 14             	pushl  0x14(%ebp)
  802502:	53                   	push   %ebx
  802503:	56                   	push   %esi
  802504:	57                   	push   %edi
  802505:	e8 bf e7 ff ff       	call   800cc9 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  80250a:	83 c4 10             	add    $0x10,%esp
  80250d:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802510:	75 07                	jne    802519 <ipc_send+0x36>
			sys_yield();
  802512:	e8 06 e6 ff ff       	call   800b1d <sys_yield>
  802517:	eb e6                	jmp    8024ff <ipc_send+0x1c>
		} else if (r < 0) {
  802519:	85 c0                	test   %eax,%eax
  80251b:	79 12                	jns    80252f <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  80251d:	50                   	push   %eax
  80251e:	68 bc 2d 80 00       	push   $0x802dbc
  802523:	6a 51                	push   $0x51
  802525:	68 c9 2d 80 00       	push   $0x802dc9
  80252a:	e8 ac db ff ff       	call   8000db <_panic>
		}
	}
}
  80252f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802532:	5b                   	pop    %ebx
  802533:	5e                   	pop    %esi
  802534:	5f                   	pop    %edi
  802535:	5d                   	pop    %ebp
  802536:	c3                   	ret    

00802537 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802537:	55                   	push   %ebp
  802538:	89 e5                	mov    %esp,%ebp
  80253a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80253d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802542:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802545:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80254b:	8b 52 50             	mov    0x50(%edx),%edx
  80254e:	39 ca                	cmp    %ecx,%edx
  802550:	75 0d                	jne    80255f <ipc_find_env+0x28>
			return envs[i].env_id;
  802552:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802555:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80255a:	8b 40 48             	mov    0x48(%eax),%eax
  80255d:	eb 0f                	jmp    80256e <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80255f:	83 c0 01             	add    $0x1,%eax
  802562:	3d 00 04 00 00       	cmp    $0x400,%eax
  802567:	75 d9                	jne    802542 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802569:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80256e:	5d                   	pop    %ebp
  80256f:	c3                   	ret    

00802570 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802570:	55                   	push   %ebp
  802571:	89 e5                	mov    %esp,%ebp
  802573:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802576:	89 d0                	mov    %edx,%eax
  802578:	c1 e8 16             	shr    $0x16,%eax
  80257b:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802582:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802587:	f6 c1 01             	test   $0x1,%cl
  80258a:	74 1d                	je     8025a9 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80258c:	c1 ea 0c             	shr    $0xc,%edx
  80258f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802596:	f6 c2 01             	test   $0x1,%dl
  802599:	74 0e                	je     8025a9 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80259b:	c1 ea 0c             	shr    $0xc,%edx
  80259e:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8025a5:	ef 
  8025a6:	0f b7 c0             	movzwl %ax,%eax
}
  8025a9:	5d                   	pop    %ebp
  8025aa:	c3                   	ret    
  8025ab:	66 90                	xchg   %ax,%ax
  8025ad:	66 90                	xchg   %ax,%ax
  8025af:	90                   	nop

008025b0 <__udivdi3>:
  8025b0:	55                   	push   %ebp
  8025b1:	57                   	push   %edi
  8025b2:	56                   	push   %esi
  8025b3:	53                   	push   %ebx
  8025b4:	83 ec 1c             	sub    $0x1c,%esp
  8025b7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8025bb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8025bf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8025c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8025c7:	85 f6                	test   %esi,%esi
  8025c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8025cd:	89 ca                	mov    %ecx,%edx
  8025cf:	89 f8                	mov    %edi,%eax
  8025d1:	75 3d                	jne    802610 <__udivdi3+0x60>
  8025d3:	39 cf                	cmp    %ecx,%edi
  8025d5:	0f 87 c5 00 00 00    	ja     8026a0 <__udivdi3+0xf0>
  8025db:	85 ff                	test   %edi,%edi
  8025dd:	89 fd                	mov    %edi,%ebp
  8025df:	75 0b                	jne    8025ec <__udivdi3+0x3c>
  8025e1:	b8 01 00 00 00       	mov    $0x1,%eax
  8025e6:	31 d2                	xor    %edx,%edx
  8025e8:	f7 f7                	div    %edi
  8025ea:	89 c5                	mov    %eax,%ebp
  8025ec:	89 c8                	mov    %ecx,%eax
  8025ee:	31 d2                	xor    %edx,%edx
  8025f0:	f7 f5                	div    %ebp
  8025f2:	89 c1                	mov    %eax,%ecx
  8025f4:	89 d8                	mov    %ebx,%eax
  8025f6:	89 cf                	mov    %ecx,%edi
  8025f8:	f7 f5                	div    %ebp
  8025fa:	89 c3                	mov    %eax,%ebx
  8025fc:	89 d8                	mov    %ebx,%eax
  8025fe:	89 fa                	mov    %edi,%edx
  802600:	83 c4 1c             	add    $0x1c,%esp
  802603:	5b                   	pop    %ebx
  802604:	5e                   	pop    %esi
  802605:	5f                   	pop    %edi
  802606:	5d                   	pop    %ebp
  802607:	c3                   	ret    
  802608:	90                   	nop
  802609:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802610:	39 ce                	cmp    %ecx,%esi
  802612:	77 74                	ja     802688 <__udivdi3+0xd8>
  802614:	0f bd fe             	bsr    %esi,%edi
  802617:	83 f7 1f             	xor    $0x1f,%edi
  80261a:	0f 84 98 00 00 00    	je     8026b8 <__udivdi3+0x108>
  802620:	bb 20 00 00 00       	mov    $0x20,%ebx
  802625:	89 f9                	mov    %edi,%ecx
  802627:	89 c5                	mov    %eax,%ebp
  802629:	29 fb                	sub    %edi,%ebx
  80262b:	d3 e6                	shl    %cl,%esi
  80262d:	89 d9                	mov    %ebx,%ecx
  80262f:	d3 ed                	shr    %cl,%ebp
  802631:	89 f9                	mov    %edi,%ecx
  802633:	d3 e0                	shl    %cl,%eax
  802635:	09 ee                	or     %ebp,%esi
  802637:	89 d9                	mov    %ebx,%ecx
  802639:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80263d:	89 d5                	mov    %edx,%ebp
  80263f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802643:	d3 ed                	shr    %cl,%ebp
  802645:	89 f9                	mov    %edi,%ecx
  802647:	d3 e2                	shl    %cl,%edx
  802649:	89 d9                	mov    %ebx,%ecx
  80264b:	d3 e8                	shr    %cl,%eax
  80264d:	09 c2                	or     %eax,%edx
  80264f:	89 d0                	mov    %edx,%eax
  802651:	89 ea                	mov    %ebp,%edx
  802653:	f7 f6                	div    %esi
  802655:	89 d5                	mov    %edx,%ebp
  802657:	89 c3                	mov    %eax,%ebx
  802659:	f7 64 24 0c          	mull   0xc(%esp)
  80265d:	39 d5                	cmp    %edx,%ebp
  80265f:	72 10                	jb     802671 <__udivdi3+0xc1>
  802661:	8b 74 24 08          	mov    0x8(%esp),%esi
  802665:	89 f9                	mov    %edi,%ecx
  802667:	d3 e6                	shl    %cl,%esi
  802669:	39 c6                	cmp    %eax,%esi
  80266b:	73 07                	jae    802674 <__udivdi3+0xc4>
  80266d:	39 d5                	cmp    %edx,%ebp
  80266f:	75 03                	jne    802674 <__udivdi3+0xc4>
  802671:	83 eb 01             	sub    $0x1,%ebx
  802674:	31 ff                	xor    %edi,%edi
  802676:	89 d8                	mov    %ebx,%eax
  802678:	89 fa                	mov    %edi,%edx
  80267a:	83 c4 1c             	add    $0x1c,%esp
  80267d:	5b                   	pop    %ebx
  80267e:	5e                   	pop    %esi
  80267f:	5f                   	pop    %edi
  802680:	5d                   	pop    %ebp
  802681:	c3                   	ret    
  802682:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802688:	31 ff                	xor    %edi,%edi
  80268a:	31 db                	xor    %ebx,%ebx
  80268c:	89 d8                	mov    %ebx,%eax
  80268e:	89 fa                	mov    %edi,%edx
  802690:	83 c4 1c             	add    $0x1c,%esp
  802693:	5b                   	pop    %ebx
  802694:	5e                   	pop    %esi
  802695:	5f                   	pop    %edi
  802696:	5d                   	pop    %ebp
  802697:	c3                   	ret    
  802698:	90                   	nop
  802699:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8026a0:	89 d8                	mov    %ebx,%eax
  8026a2:	f7 f7                	div    %edi
  8026a4:	31 ff                	xor    %edi,%edi
  8026a6:	89 c3                	mov    %eax,%ebx
  8026a8:	89 d8                	mov    %ebx,%eax
  8026aa:	89 fa                	mov    %edi,%edx
  8026ac:	83 c4 1c             	add    $0x1c,%esp
  8026af:	5b                   	pop    %ebx
  8026b0:	5e                   	pop    %esi
  8026b1:	5f                   	pop    %edi
  8026b2:	5d                   	pop    %ebp
  8026b3:	c3                   	ret    
  8026b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8026b8:	39 ce                	cmp    %ecx,%esi
  8026ba:	72 0c                	jb     8026c8 <__udivdi3+0x118>
  8026bc:	31 db                	xor    %ebx,%ebx
  8026be:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8026c2:	0f 87 34 ff ff ff    	ja     8025fc <__udivdi3+0x4c>
  8026c8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8026cd:	e9 2a ff ff ff       	jmp    8025fc <__udivdi3+0x4c>
  8026d2:	66 90                	xchg   %ax,%ax
  8026d4:	66 90                	xchg   %ax,%ax
  8026d6:	66 90                	xchg   %ax,%ax
  8026d8:	66 90                	xchg   %ax,%ax
  8026da:	66 90                	xchg   %ax,%ax
  8026dc:	66 90                	xchg   %ax,%ax
  8026de:	66 90                	xchg   %ax,%ax

008026e0 <__umoddi3>:
  8026e0:	55                   	push   %ebp
  8026e1:	57                   	push   %edi
  8026e2:	56                   	push   %esi
  8026e3:	53                   	push   %ebx
  8026e4:	83 ec 1c             	sub    $0x1c,%esp
  8026e7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8026eb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8026ef:	8b 74 24 34          	mov    0x34(%esp),%esi
  8026f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8026f7:	85 d2                	test   %edx,%edx
  8026f9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8026fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802701:	89 f3                	mov    %esi,%ebx
  802703:	89 3c 24             	mov    %edi,(%esp)
  802706:	89 74 24 04          	mov    %esi,0x4(%esp)
  80270a:	75 1c                	jne    802728 <__umoddi3+0x48>
  80270c:	39 f7                	cmp    %esi,%edi
  80270e:	76 50                	jbe    802760 <__umoddi3+0x80>
  802710:	89 c8                	mov    %ecx,%eax
  802712:	89 f2                	mov    %esi,%edx
  802714:	f7 f7                	div    %edi
  802716:	89 d0                	mov    %edx,%eax
  802718:	31 d2                	xor    %edx,%edx
  80271a:	83 c4 1c             	add    $0x1c,%esp
  80271d:	5b                   	pop    %ebx
  80271e:	5e                   	pop    %esi
  80271f:	5f                   	pop    %edi
  802720:	5d                   	pop    %ebp
  802721:	c3                   	ret    
  802722:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802728:	39 f2                	cmp    %esi,%edx
  80272a:	89 d0                	mov    %edx,%eax
  80272c:	77 52                	ja     802780 <__umoddi3+0xa0>
  80272e:	0f bd ea             	bsr    %edx,%ebp
  802731:	83 f5 1f             	xor    $0x1f,%ebp
  802734:	75 5a                	jne    802790 <__umoddi3+0xb0>
  802736:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80273a:	0f 82 e0 00 00 00    	jb     802820 <__umoddi3+0x140>
  802740:	39 0c 24             	cmp    %ecx,(%esp)
  802743:	0f 86 d7 00 00 00    	jbe    802820 <__umoddi3+0x140>
  802749:	8b 44 24 08          	mov    0x8(%esp),%eax
  80274d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802751:	83 c4 1c             	add    $0x1c,%esp
  802754:	5b                   	pop    %ebx
  802755:	5e                   	pop    %esi
  802756:	5f                   	pop    %edi
  802757:	5d                   	pop    %ebp
  802758:	c3                   	ret    
  802759:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802760:	85 ff                	test   %edi,%edi
  802762:	89 fd                	mov    %edi,%ebp
  802764:	75 0b                	jne    802771 <__umoddi3+0x91>
  802766:	b8 01 00 00 00       	mov    $0x1,%eax
  80276b:	31 d2                	xor    %edx,%edx
  80276d:	f7 f7                	div    %edi
  80276f:	89 c5                	mov    %eax,%ebp
  802771:	89 f0                	mov    %esi,%eax
  802773:	31 d2                	xor    %edx,%edx
  802775:	f7 f5                	div    %ebp
  802777:	89 c8                	mov    %ecx,%eax
  802779:	f7 f5                	div    %ebp
  80277b:	89 d0                	mov    %edx,%eax
  80277d:	eb 99                	jmp    802718 <__umoddi3+0x38>
  80277f:	90                   	nop
  802780:	89 c8                	mov    %ecx,%eax
  802782:	89 f2                	mov    %esi,%edx
  802784:	83 c4 1c             	add    $0x1c,%esp
  802787:	5b                   	pop    %ebx
  802788:	5e                   	pop    %esi
  802789:	5f                   	pop    %edi
  80278a:	5d                   	pop    %ebp
  80278b:	c3                   	ret    
  80278c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802790:	8b 34 24             	mov    (%esp),%esi
  802793:	bf 20 00 00 00       	mov    $0x20,%edi
  802798:	89 e9                	mov    %ebp,%ecx
  80279a:	29 ef                	sub    %ebp,%edi
  80279c:	d3 e0                	shl    %cl,%eax
  80279e:	89 f9                	mov    %edi,%ecx
  8027a0:	89 f2                	mov    %esi,%edx
  8027a2:	d3 ea                	shr    %cl,%edx
  8027a4:	89 e9                	mov    %ebp,%ecx
  8027a6:	09 c2                	or     %eax,%edx
  8027a8:	89 d8                	mov    %ebx,%eax
  8027aa:	89 14 24             	mov    %edx,(%esp)
  8027ad:	89 f2                	mov    %esi,%edx
  8027af:	d3 e2                	shl    %cl,%edx
  8027b1:	89 f9                	mov    %edi,%ecx
  8027b3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8027b7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8027bb:	d3 e8                	shr    %cl,%eax
  8027bd:	89 e9                	mov    %ebp,%ecx
  8027bf:	89 c6                	mov    %eax,%esi
  8027c1:	d3 e3                	shl    %cl,%ebx
  8027c3:	89 f9                	mov    %edi,%ecx
  8027c5:	89 d0                	mov    %edx,%eax
  8027c7:	d3 e8                	shr    %cl,%eax
  8027c9:	89 e9                	mov    %ebp,%ecx
  8027cb:	09 d8                	or     %ebx,%eax
  8027cd:	89 d3                	mov    %edx,%ebx
  8027cf:	89 f2                	mov    %esi,%edx
  8027d1:	f7 34 24             	divl   (%esp)
  8027d4:	89 d6                	mov    %edx,%esi
  8027d6:	d3 e3                	shl    %cl,%ebx
  8027d8:	f7 64 24 04          	mull   0x4(%esp)
  8027dc:	39 d6                	cmp    %edx,%esi
  8027de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8027e2:	89 d1                	mov    %edx,%ecx
  8027e4:	89 c3                	mov    %eax,%ebx
  8027e6:	72 08                	jb     8027f0 <__umoddi3+0x110>
  8027e8:	75 11                	jne    8027fb <__umoddi3+0x11b>
  8027ea:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8027ee:	73 0b                	jae    8027fb <__umoddi3+0x11b>
  8027f0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8027f4:	1b 14 24             	sbb    (%esp),%edx
  8027f7:	89 d1                	mov    %edx,%ecx
  8027f9:	89 c3                	mov    %eax,%ebx
  8027fb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8027ff:	29 da                	sub    %ebx,%edx
  802801:	19 ce                	sbb    %ecx,%esi
  802803:	89 f9                	mov    %edi,%ecx
  802805:	89 f0                	mov    %esi,%eax
  802807:	d3 e0                	shl    %cl,%eax
  802809:	89 e9                	mov    %ebp,%ecx
  80280b:	d3 ea                	shr    %cl,%edx
  80280d:	89 e9                	mov    %ebp,%ecx
  80280f:	d3 ee                	shr    %cl,%esi
  802811:	09 d0                	or     %edx,%eax
  802813:	89 f2                	mov    %esi,%edx
  802815:	83 c4 1c             	add    $0x1c,%esp
  802818:	5b                   	pop    %ebx
  802819:	5e                   	pop    %esi
  80281a:	5f                   	pop    %edi
  80281b:	5d                   	pop    %ebp
  80281c:	c3                   	ret    
  80281d:	8d 76 00             	lea    0x0(%esi),%esi
  802820:	29 f9                	sub    %edi,%ecx
  802822:	19 d6                	sbb    %edx,%esi
  802824:	89 74 24 04          	mov    %esi,0x4(%esp)
  802828:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80282c:	e9 18 ff ff ff       	jmp    802749 <__umoddi3+0x69>
