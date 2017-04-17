
obj/user/cat.debug:     file format elf32-i386


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
  80002c:	e8 02 01 00 00       	call   800133 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <cat>:

char buf[8192];

void
cat(int f, char *s)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 75 08             	mov    0x8(%ebp),%esi
	long n;
	int r;

	while ((n = read(f, buf, (long)sizeof(buf))) > 0)
  80003b:	eb 2f                	jmp    80006c <cat+0x39>
		if ((r = write(1, buf, n)) != n)
  80003d:	83 ec 04             	sub    $0x4,%esp
  800040:	53                   	push   %ebx
  800041:	68 20 40 80 00       	push   $0x804020
  800046:	6a 01                	push   $0x1
  800048:	e8 6d 11 00 00       	call   8011ba <write>
  80004d:	83 c4 10             	add    $0x10,%esp
  800050:	39 c3                	cmp    %eax,%ebx
  800052:	74 18                	je     80006c <cat+0x39>
			panic("write error copying %s: %e", s, r);
  800054:	83 ec 0c             	sub    $0xc,%esp
  800057:	50                   	push   %eax
  800058:	ff 75 0c             	pushl  0xc(%ebp)
  80005b:	68 60 24 80 00       	push   $0x802460
  800060:	6a 0d                	push   $0xd
  800062:	68 7b 24 80 00       	push   $0x80247b
  800067:	e8 27 01 00 00       	call   800193 <_panic>
cat(int f, char *s)
{
	long n;
	int r;

	while ((n = read(f, buf, (long)sizeof(buf))) > 0)
  80006c:	83 ec 04             	sub    $0x4,%esp
  80006f:	68 00 20 00 00       	push   $0x2000
  800074:	68 20 40 80 00       	push   $0x804020
  800079:	56                   	push   %esi
  80007a:	e8 61 10 00 00       	call   8010e0 <read>
  80007f:	89 c3                	mov    %eax,%ebx
  800081:	83 c4 10             	add    $0x10,%esp
  800084:	85 c0                	test   %eax,%eax
  800086:	7f b5                	jg     80003d <cat+0xa>
		if ((r = write(1, buf, n)) != n)
			panic("write error copying %s: %e", s, r);
	if (n < 0)
  800088:	85 c0                	test   %eax,%eax
  80008a:	79 18                	jns    8000a4 <cat+0x71>
		panic("error reading %s: %e", s, n);
  80008c:	83 ec 0c             	sub    $0xc,%esp
  80008f:	50                   	push   %eax
  800090:	ff 75 0c             	pushl  0xc(%ebp)
  800093:	68 86 24 80 00       	push   $0x802486
  800098:	6a 0f                	push   $0xf
  80009a:	68 7b 24 80 00       	push   $0x80247b
  80009f:	e8 ef 00 00 00       	call   800193 <_panic>
}
  8000a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a7:	5b                   	pop    %ebx
  8000a8:	5e                   	pop    %esi
  8000a9:	5d                   	pop    %ebp
  8000aa:	c3                   	ret    

008000ab <umain>:

void
umain(int argc, char **argv)
{
  8000ab:	55                   	push   %ebp
  8000ac:	89 e5                	mov    %esp,%ebp
  8000ae:	57                   	push   %edi
  8000af:	56                   	push   %esi
  8000b0:	53                   	push   %ebx
  8000b1:	83 ec 0c             	sub    $0xc,%esp
  8000b4:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int f, i;

	binaryname = "cat";
  8000b7:	c7 05 00 30 80 00 9b 	movl   $0x80249b,0x803000
  8000be:	24 80 00 
  8000c1:	bb 01 00 00 00       	mov    $0x1,%ebx
	if (argc == 1)
  8000c6:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  8000ca:	75 5a                	jne    800126 <umain+0x7b>
		cat(0, "<stdin>");
  8000cc:	83 ec 08             	sub    $0x8,%esp
  8000cf:	68 9f 24 80 00       	push   $0x80249f
  8000d4:	6a 00                	push   $0x0
  8000d6:	e8 58 ff ff ff       	call   800033 <cat>
  8000db:	83 c4 10             	add    $0x10,%esp
  8000de:	eb 4b                	jmp    80012b <umain+0x80>
	else
		for (i = 1; i < argc; i++) {
			f = open(argv[i], O_RDONLY);
  8000e0:	83 ec 08             	sub    $0x8,%esp
  8000e3:	6a 00                	push   $0x0
  8000e5:	ff 34 9f             	pushl  (%edi,%ebx,4)
  8000e8:	e8 a7 14 00 00       	call   801594 <open>
  8000ed:	89 c6                	mov    %eax,%esi
			if (f < 0)
  8000ef:	83 c4 10             	add    $0x10,%esp
  8000f2:	85 c0                	test   %eax,%eax
  8000f4:	79 16                	jns    80010c <umain+0x61>
				printf("can't open %s: %e\n", argv[i], f);
  8000f6:	83 ec 04             	sub    $0x4,%esp
  8000f9:	50                   	push   %eax
  8000fa:	ff 34 9f             	pushl  (%edi,%ebx,4)
  8000fd:	68 a7 24 80 00       	push   $0x8024a7
  800102:	e8 2b 16 00 00       	call   801732 <printf>
  800107:	83 c4 10             	add    $0x10,%esp
  80010a:	eb 17                	jmp    800123 <umain+0x78>
			else {
				cat(f, argv[i]);
  80010c:	83 ec 08             	sub    $0x8,%esp
  80010f:	ff 34 9f             	pushl  (%edi,%ebx,4)
  800112:	50                   	push   %eax
  800113:	e8 1b ff ff ff       	call   800033 <cat>
				close(f);
  800118:	89 34 24             	mov    %esi,(%esp)
  80011b:	e8 84 0e 00 00       	call   800fa4 <close>
  800120:	83 c4 10             	add    $0x10,%esp

	binaryname = "cat";
	if (argc == 1)
		cat(0, "<stdin>");
	else
		for (i = 1; i < argc; i++) {
  800123:	83 c3 01             	add    $0x1,%ebx
  800126:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  800129:	7c b5                	jl     8000e0 <umain+0x35>
			else {
				cat(f, argv[i]);
				close(f);
			}
		}
}
  80012b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80012e:	5b                   	pop    %ebx
  80012f:	5e                   	pop    %esi
  800130:	5f                   	pop    %edi
  800131:	5d                   	pop    %ebp
  800132:	c3                   	ret    

00800133 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800133:	55                   	push   %ebp
  800134:	89 e5                	mov    %esp,%ebp
  800136:	56                   	push   %esi
  800137:	53                   	push   %ebx
  800138:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80013b:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80013e:	e8 73 0a 00 00       	call   800bb6 <sys_getenvid>
  800143:	25 ff 03 00 00       	and    $0x3ff,%eax
  800148:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80014b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800150:	a3 20 60 80 00       	mov    %eax,0x806020

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800155:	85 db                	test   %ebx,%ebx
  800157:	7e 07                	jle    800160 <libmain+0x2d>
		binaryname = argv[0];
  800159:	8b 06                	mov    (%esi),%eax
  80015b:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800160:	83 ec 08             	sub    $0x8,%esp
  800163:	56                   	push   %esi
  800164:	53                   	push   %ebx
  800165:	e8 41 ff ff ff       	call   8000ab <umain>

	// exit gracefully
	exit();
  80016a:	e8 0a 00 00 00       	call   800179 <exit>
}
  80016f:	83 c4 10             	add    $0x10,%esp
  800172:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800175:	5b                   	pop    %ebx
  800176:	5e                   	pop    %esi
  800177:	5d                   	pop    %ebp
  800178:	c3                   	ret    

00800179 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800179:	55                   	push   %ebp
  80017a:	89 e5                	mov    %esp,%ebp
  80017c:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80017f:	e8 4b 0e 00 00       	call   800fcf <close_all>
	sys_env_destroy(0);
  800184:	83 ec 0c             	sub    $0xc,%esp
  800187:	6a 00                	push   $0x0
  800189:	e8 e7 09 00 00       	call   800b75 <sys_env_destroy>
}
  80018e:	83 c4 10             	add    $0x10,%esp
  800191:	c9                   	leave  
  800192:	c3                   	ret    

00800193 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800193:	55                   	push   %ebp
  800194:	89 e5                	mov    %esp,%ebp
  800196:	56                   	push   %esi
  800197:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800198:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80019b:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8001a1:	e8 10 0a 00 00       	call   800bb6 <sys_getenvid>
  8001a6:	83 ec 0c             	sub    $0xc,%esp
  8001a9:	ff 75 0c             	pushl  0xc(%ebp)
  8001ac:	ff 75 08             	pushl  0x8(%ebp)
  8001af:	56                   	push   %esi
  8001b0:	50                   	push   %eax
  8001b1:	68 c4 24 80 00       	push   $0x8024c4
  8001b6:	e8 b1 00 00 00       	call   80026c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001bb:	83 c4 18             	add    $0x18,%esp
  8001be:	53                   	push   %ebx
  8001bf:	ff 75 10             	pushl  0x10(%ebp)
  8001c2:	e8 54 00 00 00       	call   80021b <vcprintf>
	cprintf("\n");
  8001c7:	c7 04 24 30 29 80 00 	movl   $0x802930,(%esp)
  8001ce:	e8 99 00 00 00       	call   80026c <cprintf>
  8001d3:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001d6:	cc                   	int3   
  8001d7:	eb fd                	jmp    8001d6 <_panic+0x43>

008001d9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001d9:	55                   	push   %ebp
  8001da:	89 e5                	mov    %esp,%ebp
  8001dc:	53                   	push   %ebx
  8001dd:	83 ec 04             	sub    $0x4,%esp
  8001e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001e3:	8b 13                	mov    (%ebx),%edx
  8001e5:	8d 42 01             	lea    0x1(%edx),%eax
  8001e8:	89 03                	mov    %eax,(%ebx)
  8001ea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ed:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001f1:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001f6:	75 1a                	jne    800212 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001f8:	83 ec 08             	sub    $0x8,%esp
  8001fb:	68 ff 00 00 00       	push   $0xff
  800200:	8d 43 08             	lea    0x8(%ebx),%eax
  800203:	50                   	push   %eax
  800204:	e8 2f 09 00 00       	call   800b38 <sys_cputs>
		b->idx = 0;
  800209:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80020f:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800212:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800216:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800219:	c9                   	leave  
  80021a:	c3                   	ret    

0080021b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80021b:	55                   	push   %ebp
  80021c:	89 e5                	mov    %esp,%ebp
  80021e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800224:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80022b:	00 00 00 
	b.cnt = 0;
  80022e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800235:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800238:	ff 75 0c             	pushl  0xc(%ebp)
  80023b:	ff 75 08             	pushl  0x8(%ebp)
  80023e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800244:	50                   	push   %eax
  800245:	68 d9 01 80 00       	push   $0x8001d9
  80024a:	e8 54 01 00 00       	call   8003a3 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80024f:	83 c4 08             	add    $0x8,%esp
  800252:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800258:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80025e:	50                   	push   %eax
  80025f:	e8 d4 08 00 00       	call   800b38 <sys_cputs>

	return b.cnt;
}
  800264:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80026a:	c9                   	leave  
  80026b:	c3                   	ret    

0080026c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  80026f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800272:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800275:	50                   	push   %eax
  800276:	ff 75 08             	pushl  0x8(%ebp)
  800279:	e8 9d ff ff ff       	call   80021b <vcprintf>
	va_end(ap);

	return cnt;
}
  80027e:	c9                   	leave  
  80027f:	c3                   	ret    

00800280 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	57                   	push   %edi
  800284:	56                   	push   %esi
  800285:	53                   	push   %ebx
  800286:	83 ec 1c             	sub    $0x1c,%esp
  800289:	89 c7                	mov    %eax,%edi
  80028b:	89 d6                	mov    %edx,%esi
  80028d:	8b 45 08             	mov    0x8(%ebp),%eax
  800290:	8b 55 0c             	mov    0xc(%ebp),%edx
  800293:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800296:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800299:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80029c:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002a1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002a4:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002a7:	39 d3                	cmp    %edx,%ebx
  8002a9:	72 05                	jb     8002b0 <printnum+0x30>
  8002ab:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002ae:	77 45                	ja     8002f5 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002b0:	83 ec 0c             	sub    $0xc,%esp
  8002b3:	ff 75 18             	pushl  0x18(%ebp)
  8002b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8002b9:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002bc:	53                   	push   %ebx
  8002bd:	ff 75 10             	pushl  0x10(%ebp)
  8002c0:	83 ec 08             	sub    $0x8,%esp
  8002c3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002c6:	ff 75 e0             	pushl  -0x20(%ebp)
  8002c9:	ff 75 dc             	pushl  -0x24(%ebp)
  8002cc:	ff 75 d8             	pushl  -0x28(%ebp)
  8002cf:	e8 ec 1e 00 00       	call   8021c0 <__udivdi3>
  8002d4:	83 c4 18             	add    $0x18,%esp
  8002d7:	52                   	push   %edx
  8002d8:	50                   	push   %eax
  8002d9:	89 f2                	mov    %esi,%edx
  8002db:	89 f8                	mov    %edi,%eax
  8002dd:	e8 9e ff ff ff       	call   800280 <printnum>
  8002e2:	83 c4 20             	add    $0x20,%esp
  8002e5:	eb 18                	jmp    8002ff <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002e7:	83 ec 08             	sub    $0x8,%esp
  8002ea:	56                   	push   %esi
  8002eb:	ff 75 18             	pushl  0x18(%ebp)
  8002ee:	ff d7                	call   *%edi
  8002f0:	83 c4 10             	add    $0x10,%esp
  8002f3:	eb 03                	jmp    8002f8 <printnum+0x78>
  8002f5:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002f8:	83 eb 01             	sub    $0x1,%ebx
  8002fb:	85 db                	test   %ebx,%ebx
  8002fd:	7f e8                	jg     8002e7 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002ff:	83 ec 08             	sub    $0x8,%esp
  800302:	56                   	push   %esi
  800303:	83 ec 04             	sub    $0x4,%esp
  800306:	ff 75 e4             	pushl  -0x1c(%ebp)
  800309:	ff 75 e0             	pushl  -0x20(%ebp)
  80030c:	ff 75 dc             	pushl  -0x24(%ebp)
  80030f:	ff 75 d8             	pushl  -0x28(%ebp)
  800312:	e8 d9 1f 00 00       	call   8022f0 <__umoddi3>
  800317:	83 c4 14             	add    $0x14,%esp
  80031a:	0f be 80 e7 24 80 00 	movsbl 0x8024e7(%eax),%eax
  800321:	50                   	push   %eax
  800322:	ff d7                	call   *%edi
}
  800324:	83 c4 10             	add    $0x10,%esp
  800327:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80032a:	5b                   	pop    %ebx
  80032b:	5e                   	pop    %esi
  80032c:	5f                   	pop    %edi
  80032d:	5d                   	pop    %ebp
  80032e:	c3                   	ret    

0080032f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80032f:	55                   	push   %ebp
  800330:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800332:	83 fa 01             	cmp    $0x1,%edx
  800335:	7e 0e                	jle    800345 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800337:	8b 10                	mov    (%eax),%edx
  800339:	8d 4a 08             	lea    0x8(%edx),%ecx
  80033c:	89 08                	mov    %ecx,(%eax)
  80033e:	8b 02                	mov    (%edx),%eax
  800340:	8b 52 04             	mov    0x4(%edx),%edx
  800343:	eb 22                	jmp    800367 <getuint+0x38>
	else if (lflag)
  800345:	85 d2                	test   %edx,%edx
  800347:	74 10                	je     800359 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800349:	8b 10                	mov    (%eax),%edx
  80034b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80034e:	89 08                	mov    %ecx,(%eax)
  800350:	8b 02                	mov    (%edx),%eax
  800352:	ba 00 00 00 00       	mov    $0x0,%edx
  800357:	eb 0e                	jmp    800367 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800359:	8b 10                	mov    (%eax),%edx
  80035b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80035e:	89 08                	mov    %ecx,(%eax)
  800360:	8b 02                	mov    (%edx),%eax
  800362:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800367:	5d                   	pop    %ebp
  800368:	c3                   	ret    

00800369 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800369:	55                   	push   %ebp
  80036a:	89 e5                	mov    %esp,%ebp
  80036c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80036f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800373:	8b 10                	mov    (%eax),%edx
  800375:	3b 50 04             	cmp    0x4(%eax),%edx
  800378:	73 0a                	jae    800384 <sprintputch+0x1b>
		*b->buf++ = ch;
  80037a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80037d:	89 08                	mov    %ecx,(%eax)
  80037f:	8b 45 08             	mov    0x8(%ebp),%eax
  800382:	88 02                	mov    %al,(%edx)
}
  800384:	5d                   	pop    %ebp
  800385:	c3                   	ret    

00800386 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800386:	55                   	push   %ebp
  800387:	89 e5                	mov    %esp,%ebp
  800389:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80038c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80038f:	50                   	push   %eax
  800390:	ff 75 10             	pushl  0x10(%ebp)
  800393:	ff 75 0c             	pushl  0xc(%ebp)
  800396:	ff 75 08             	pushl  0x8(%ebp)
  800399:	e8 05 00 00 00       	call   8003a3 <vprintfmt>
	va_end(ap);
}
  80039e:	83 c4 10             	add    $0x10,%esp
  8003a1:	c9                   	leave  
  8003a2:	c3                   	ret    

008003a3 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003a3:	55                   	push   %ebp
  8003a4:	89 e5                	mov    %esp,%ebp
  8003a6:	57                   	push   %edi
  8003a7:	56                   	push   %esi
  8003a8:	53                   	push   %ebx
  8003a9:	83 ec 2c             	sub    $0x2c,%esp
  8003ac:	8b 75 08             	mov    0x8(%ebp),%esi
  8003af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003b2:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003b5:	eb 12                	jmp    8003c9 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003b7:	85 c0                	test   %eax,%eax
  8003b9:	0f 84 89 03 00 00    	je     800748 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8003bf:	83 ec 08             	sub    $0x8,%esp
  8003c2:	53                   	push   %ebx
  8003c3:	50                   	push   %eax
  8003c4:	ff d6                	call   *%esi
  8003c6:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003c9:	83 c7 01             	add    $0x1,%edi
  8003cc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003d0:	83 f8 25             	cmp    $0x25,%eax
  8003d3:	75 e2                	jne    8003b7 <vprintfmt+0x14>
  8003d5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003d9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003e0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003e7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8003f3:	eb 07                	jmp    8003fc <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003f8:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fc:	8d 47 01             	lea    0x1(%edi),%eax
  8003ff:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800402:	0f b6 07             	movzbl (%edi),%eax
  800405:	0f b6 c8             	movzbl %al,%ecx
  800408:	83 e8 23             	sub    $0x23,%eax
  80040b:	3c 55                	cmp    $0x55,%al
  80040d:	0f 87 1a 03 00 00    	ja     80072d <vprintfmt+0x38a>
  800413:	0f b6 c0             	movzbl %al,%eax
  800416:	ff 24 85 20 26 80 00 	jmp    *0x802620(,%eax,4)
  80041d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800420:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800424:	eb d6                	jmp    8003fc <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800426:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800429:	b8 00 00 00 00       	mov    $0x0,%eax
  80042e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800431:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800434:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800438:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80043b:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80043e:	83 fa 09             	cmp    $0x9,%edx
  800441:	77 39                	ja     80047c <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800443:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800446:	eb e9                	jmp    800431 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800448:	8b 45 14             	mov    0x14(%ebp),%eax
  80044b:	8d 48 04             	lea    0x4(%eax),%ecx
  80044e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800451:	8b 00                	mov    (%eax),%eax
  800453:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800456:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800459:	eb 27                	jmp    800482 <vprintfmt+0xdf>
  80045b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80045e:	85 c0                	test   %eax,%eax
  800460:	b9 00 00 00 00       	mov    $0x0,%ecx
  800465:	0f 49 c8             	cmovns %eax,%ecx
  800468:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80046e:	eb 8c                	jmp    8003fc <vprintfmt+0x59>
  800470:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800473:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80047a:	eb 80                	jmp    8003fc <vprintfmt+0x59>
  80047c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80047f:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800482:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800486:	0f 89 70 ff ff ff    	jns    8003fc <vprintfmt+0x59>
				width = precision, precision = -1;
  80048c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80048f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800492:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800499:	e9 5e ff ff ff       	jmp    8003fc <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80049e:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004a4:	e9 53 ff ff ff       	jmp    8003fc <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ac:	8d 50 04             	lea    0x4(%eax),%edx
  8004af:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b2:	83 ec 08             	sub    $0x8,%esp
  8004b5:	53                   	push   %ebx
  8004b6:	ff 30                	pushl  (%eax)
  8004b8:	ff d6                	call   *%esi
			break;
  8004ba:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004c0:	e9 04 ff ff ff       	jmp    8003c9 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c8:	8d 50 04             	lea    0x4(%eax),%edx
  8004cb:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ce:	8b 00                	mov    (%eax),%eax
  8004d0:	99                   	cltd   
  8004d1:	31 d0                	xor    %edx,%eax
  8004d3:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004d5:	83 f8 0f             	cmp    $0xf,%eax
  8004d8:	7f 0b                	jg     8004e5 <vprintfmt+0x142>
  8004da:	8b 14 85 80 27 80 00 	mov    0x802780(,%eax,4),%edx
  8004e1:	85 d2                	test   %edx,%edx
  8004e3:	75 18                	jne    8004fd <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004e5:	50                   	push   %eax
  8004e6:	68 ff 24 80 00       	push   $0x8024ff
  8004eb:	53                   	push   %ebx
  8004ec:	56                   	push   %esi
  8004ed:	e8 94 fe ff ff       	call   800386 <printfmt>
  8004f2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004f8:	e9 cc fe ff ff       	jmp    8003c9 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004fd:	52                   	push   %edx
  8004fe:	68 be 28 80 00       	push   $0x8028be
  800503:	53                   	push   %ebx
  800504:	56                   	push   %esi
  800505:	e8 7c fe ff ff       	call   800386 <printfmt>
  80050a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800510:	e9 b4 fe ff ff       	jmp    8003c9 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800515:	8b 45 14             	mov    0x14(%ebp),%eax
  800518:	8d 50 04             	lea    0x4(%eax),%edx
  80051b:	89 55 14             	mov    %edx,0x14(%ebp)
  80051e:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800520:	85 ff                	test   %edi,%edi
  800522:	b8 f8 24 80 00       	mov    $0x8024f8,%eax
  800527:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80052a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80052e:	0f 8e 94 00 00 00    	jle    8005c8 <vprintfmt+0x225>
  800534:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800538:	0f 84 98 00 00 00    	je     8005d6 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80053e:	83 ec 08             	sub    $0x8,%esp
  800541:	ff 75 d0             	pushl  -0x30(%ebp)
  800544:	57                   	push   %edi
  800545:	e8 86 02 00 00       	call   8007d0 <strnlen>
  80054a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80054d:	29 c1                	sub    %eax,%ecx
  80054f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800552:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800555:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800559:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80055c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80055f:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800561:	eb 0f                	jmp    800572 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800563:	83 ec 08             	sub    $0x8,%esp
  800566:	53                   	push   %ebx
  800567:	ff 75 e0             	pushl  -0x20(%ebp)
  80056a:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80056c:	83 ef 01             	sub    $0x1,%edi
  80056f:	83 c4 10             	add    $0x10,%esp
  800572:	85 ff                	test   %edi,%edi
  800574:	7f ed                	jg     800563 <vprintfmt+0x1c0>
  800576:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800579:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80057c:	85 c9                	test   %ecx,%ecx
  80057e:	b8 00 00 00 00       	mov    $0x0,%eax
  800583:	0f 49 c1             	cmovns %ecx,%eax
  800586:	29 c1                	sub    %eax,%ecx
  800588:	89 75 08             	mov    %esi,0x8(%ebp)
  80058b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80058e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800591:	89 cb                	mov    %ecx,%ebx
  800593:	eb 4d                	jmp    8005e2 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800595:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800599:	74 1b                	je     8005b6 <vprintfmt+0x213>
  80059b:	0f be c0             	movsbl %al,%eax
  80059e:	83 e8 20             	sub    $0x20,%eax
  8005a1:	83 f8 5e             	cmp    $0x5e,%eax
  8005a4:	76 10                	jbe    8005b6 <vprintfmt+0x213>
					putch('?', putdat);
  8005a6:	83 ec 08             	sub    $0x8,%esp
  8005a9:	ff 75 0c             	pushl  0xc(%ebp)
  8005ac:	6a 3f                	push   $0x3f
  8005ae:	ff 55 08             	call   *0x8(%ebp)
  8005b1:	83 c4 10             	add    $0x10,%esp
  8005b4:	eb 0d                	jmp    8005c3 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8005b6:	83 ec 08             	sub    $0x8,%esp
  8005b9:	ff 75 0c             	pushl  0xc(%ebp)
  8005bc:	52                   	push   %edx
  8005bd:	ff 55 08             	call   *0x8(%ebp)
  8005c0:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005c3:	83 eb 01             	sub    $0x1,%ebx
  8005c6:	eb 1a                	jmp    8005e2 <vprintfmt+0x23f>
  8005c8:	89 75 08             	mov    %esi,0x8(%ebp)
  8005cb:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005ce:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005d1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005d4:	eb 0c                	jmp    8005e2 <vprintfmt+0x23f>
  8005d6:	89 75 08             	mov    %esi,0x8(%ebp)
  8005d9:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005dc:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005df:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005e2:	83 c7 01             	add    $0x1,%edi
  8005e5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005e9:	0f be d0             	movsbl %al,%edx
  8005ec:	85 d2                	test   %edx,%edx
  8005ee:	74 23                	je     800613 <vprintfmt+0x270>
  8005f0:	85 f6                	test   %esi,%esi
  8005f2:	78 a1                	js     800595 <vprintfmt+0x1f2>
  8005f4:	83 ee 01             	sub    $0x1,%esi
  8005f7:	79 9c                	jns    800595 <vprintfmt+0x1f2>
  8005f9:	89 df                	mov    %ebx,%edi
  8005fb:	8b 75 08             	mov    0x8(%ebp),%esi
  8005fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800601:	eb 18                	jmp    80061b <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800603:	83 ec 08             	sub    $0x8,%esp
  800606:	53                   	push   %ebx
  800607:	6a 20                	push   $0x20
  800609:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80060b:	83 ef 01             	sub    $0x1,%edi
  80060e:	83 c4 10             	add    $0x10,%esp
  800611:	eb 08                	jmp    80061b <vprintfmt+0x278>
  800613:	89 df                	mov    %ebx,%edi
  800615:	8b 75 08             	mov    0x8(%ebp),%esi
  800618:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80061b:	85 ff                	test   %edi,%edi
  80061d:	7f e4                	jg     800603 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80061f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800622:	e9 a2 fd ff ff       	jmp    8003c9 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800627:	83 fa 01             	cmp    $0x1,%edx
  80062a:	7e 16                	jle    800642 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80062c:	8b 45 14             	mov    0x14(%ebp),%eax
  80062f:	8d 50 08             	lea    0x8(%eax),%edx
  800632:	89 55 14             	mov    %edx,0x14(%ebp)
  800635:	8b 50 04             	mov    0x4(%eax),%edx
  800638:	8b 00                	mov    (%eax),%eax
  80063a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80063d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800640:	eb 32                	jmp    800674 <vprintfmt+0x2d1>
	else if (lflag)
  800642:	85 d2                	test   %edx,%edx
  800644:	74 18                	je     80065e <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800646:	8b 45 14             	mov    0x14(%ebp),%eax
  800649:	8d 50 04             	lea    0x4(%eax),%edx
  80064c:	89 55 14             	mov    %edx,0x14(%ebp)
  80064f:	8b 00                	mov    (%eax),%eax
  800651:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800654:	89 c1                	mov    %eax,%ecx
  800656:	c1 f9 1f             	sar    $0x1f,%ecx
  800659:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80065c:	eb 16                	jmp    800674 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80065e:	8b 45 14             	mov    0x14(%ebp),%eax
  800661:	8d 50 04             	lea    0x4(%eax),%edx
  800664:	89 55 14             	mov    %edx,0x14(%ebp)
  800667:	8b 00                	mov    (%eax),%eax
  800669:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80066c:	89 c1                	mov    %eax,%ecx
  80066e:	c1 f9 1f             	sar    $0x1f,%ecx
  800671:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800674:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800677:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80067a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80067f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800683:	79 74                	jns    8006f9 <vprintfmt+0x356>
				putch('-', putdat);
  800685:	83 ec 08             	sub    $0x8,%esp
  800688:	53                   	push   %ebx
  800689:	6a 2d                	push   $0x2d
  80068b:	ff d6                	call   *%esi
				num = -(long long) num;
  80068d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800690:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800693:	f7 d8                	neg    %eax
  800695:	83 d2 00             	adc    $0x0,%edx
  800698:	f7 da                	neg    %edx
  80069a:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80069d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006a2:	eb 55                	jmp    8006f9 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006a4:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a7:	e8 83 fc ff ff       	call   80032f <getuint>
			base = 10;
  8006ac:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006b1:	eb 46                	jmp    8006f9 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8006b3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b6:	e8 74 fc ff ff       	call   80032f <getuint>
                        base = 8;
  8006bb:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  8006c0:	eb 37                	jmp    8006f9 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8006c2:	83 ec 08             	sub    $0x8,%esp
  8006c5:	53                   	push   %ebx
  8006c6:	6a 30                	push   $0x30
  8006c8:	ff d6                	call   *%esi
			putch('x', putdat);
  8006ca:	83 c4 08             	add    $0x8,%esp
  8006cd:	53                   	push   %ebx
  8006ce:	6a 78                	push   $0x78
  8006d0:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d5:	8d 50 04             	lea    0x4(%eax),%edx
  8006d8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006db:	8b 00                	mov    (%eax),%eax
  8006dd:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006e2:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006e5:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006ea:	eb 0d                	jmp    8006f9 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006ec:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ef:	e8 3b fc ff ff       	call   80032f <getuint>
			base = 16;
  8006f4:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006f9:	83 ec 0c             	sub    $0xc,%esp
  8006fc:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800700:	57                   	push   %edi
  800701:	ff 75 e0             	pushl  -0x20(%ebp)
  800704:	51                   	push   %ecx
  800705:	52                   	push   %edx
  800706:	50                   	push   %eax
  800707:	89 da                	mov    %ebx,%edx
  800709:	89 f0                	mov    %esi,%eax
  80070b:	e8 70 fb ff ff       	call   800280 <printnum>
			break;
  800710:	83 c4 20             	add    $0x20,%esp
  800713:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800716:	e9 ae fc ff ff       	jmp    8003c9 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80071b:	83 ec 08             	sub    $0x8,%esp
  80071e:	53                   	push   %ebx
  80071f:	51                   	push   %ecx
  800720:	ff d6                	call   *%esi
			break;
  800722:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800725:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800728:	e9 9c fc ff ff       	jmp    8003c9 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80072d:	83 ec 08             	sub    $0x8,%esp
  800730:	53                   	push   %ebx
  800731:	6a 25                	push   $0x25
  800733:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800735:	83 c4 10             	add    $0x10,%esp
  800738:	eb 03                	jmp    80073d <vprintfmt+0x39a>
  80073a:	83 ef 01             	sub    $0x1,%edi
  80073d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800741:	75 f7                	jne    80073a <vprintfmt+0x397>
  800743:	e9 81 fc ff ff       	jmp    8003c9 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800748:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80074b:	5b                   	pop    %ebx
  80074c:	5e                   	pop    %esi
  80074d:	5f                   	pop    %edi
  80074e:	5d                   	pop    %ebp
  80074f:	c3                   	ret    

00800750 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800750:	55                   	push   %ebp
  800751:	89 e5                	mov    %esp,%ebp
  800753:	83 ec 18             	sub    $0x18,%esp
  800756:	8b 45 08             	mov    0x8(%ebp),%eax
  800759:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80075c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80075f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800763:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800766:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80076d:	85 c0                	test   %eax,%eax
  80076f:	74 26                	je     800797 <vsnprintf+0x47>
  800771:	85 d2                	test   %edx,%edx
  800773:	7e 22                	jle    800797 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800775:	ff 75 14             	pushl  0x14(%ebp)
  800778:	ff 75 10             	pushl  0x10(%ebp)
  80077b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80077e:	50                   	push   %eax
  80077f:	68 69 03 80 00       	push   $0x800369
  800784:	e8 1a fc ff ff       	call   8003a3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800789:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80078c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80078f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800792:	83 c4 10             	add    $0x10,%esp
  800795:	eb 05                	jmp    80079c <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800797:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80079c:	c9                   	leave  
  80079d:	c3                   	ret    

0080079e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80079e:	55                   	push   %ebp
  80079f:	89 e5                	mov    %esp,%ebp
  8007a1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007a4:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007a7:	50                   	push   %eax
  8007a8:	ff 75 10             	pushl  0x10(%ebp)
  8007ab:	ff 75 0c             	pushl  0xc(%ebp)
  8007ae:	ff 75 08             	pushl  0x8(%ebp)
  8007b1:	e8 9a ff ff ff       	call   800750 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007b6:	c9                   	leave  
  8007b7:	c3                   	ret    

008007b8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007b8:	55                   	push   %ebp
  8007b9:	89 e5                	mov    %esp,%ebp
  8007bb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007be:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c3:	eb 03                	jmp    8007c8 <strlen+0x10>
		n++;
  8007c5:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c8:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007cc:	75 f7                	jne    8007c5 <strlen+0xd>
		n++;
	return n;
}
  8007ce:	5d                   	pop    %ebp
  8007cf:	c3                   	ret    

008007d0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007d0:	55                   	push   %ebp
  8007d1:	89 e5                	mov    %esp,%ebp
  8007d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007d6:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8007de:	eb 03                	jmp    8007e3 <strnlen+0x13>
		n++;
  8007e0:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e3:	39 c2                	cmp    %eax,%edx
  8007e5:	74 08                	je     8007ef <strnlen+0x1f>
  8007e7:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007eb:	75 f3                	jne    8007e0 <strnlen+0x10>
  8007ed:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007ef:	5d                   	pop    %ebp
  8007f0:	c3                   	ret    

008007f1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007f1:	55                   	push   %ebp
  8007f2:	89 e5                	mov    %esp,%ebp
  8007f4:	53                   	push   %ebx
  8007f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007fb:	89 c2                	mov    %eax,%edx
  8007fd:	83 c2 01             	add    $0x1,%edx
  800800:	83 c1 01             	add    $0x1,%ecx
  800803:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800807:	88 5a ff             	mov    %bl,-0x1(%edx)
  80080a:	84 db                	test   %bl,%bl
  80080c:	75 ef                	jne    8007fd <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80080e:	5b                   	pop    %ebx
  80080f:	5d                   	pop    %ebp
  800810:	c3                   	ret    

00800811 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800811:	55                   	push   %ebp
  800812:	89 e5                	mov    %esp,%ebp
  800814:	53                   	push   %ebx
  800815:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800818:	53                   	push   %ebx
  800819:	e8 9a ff ff ff       	call   8007b8 <strlen>
  80081e:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800821:	ff 75 0c             	pushl  0xc(%ebp)
  800824:	01 d8                	add    %ebx,%eax
  800826:	50                   	push   %eax
  800827:	e8 c5 ff ff ff       	call   8007f1 <strcpy>
	return dst;
}
  80082c:	89 d8                	mov    %ebx,%eax
  80082e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800831:	c9                   	leave  
  800832:	c3                   	ret    

00800833 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800833:	55                   	push   %ebp
  800834:	89 e5                	mov    %esp,%ebp
  800836:	56                   	push   %esi
  800837:	53                   	push   %ebx
  800838:	8b 75 08             	mov    0x8(%ebp),%esi
  80083b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80083e:	89 f3                	mov    %esi,%ebx
  800840:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800843:	89 f2                	mov    %esi,%edx
  800845:	eb 0f                	jmp    800856 <strncpy+0x23>
		*dst++ = *src;
  800847:	83 c2 01             	add    $0x1,%edx
  80084a:	0f b6 01             	movzbl (%ecx),%eax
  80084d:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800850:	80 39 01             	cmpb   $0x1,(%ecx)
  800853:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800856:	39 da                	cmp    %ebx,%edx
  800858:	75 ed                	jne    800847 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80085a:	89 f0                	mov    %esi,%eax
  80085c:	5b                   	pop    %ebx
  80085d:	5e                   	pop    %esi
  80085e:	5d                   	pop    %ebp
  80085f:	c3                   	ret    

00800860 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	56                   	push   %esi
  800864:	53                   	push   %ebx
  800865:	8b 75 08             	mov    0x8(%ebp),%esi
  800868:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80086b:	8b 55 10             	mov    0x10(%ebp),%edx
  80086e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800870:	85 d2                	test   %edx,%edx
  800872:	74 21                	je     800895 <strlcpy+0x35>
  800874:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800878:	89 f2                	mov    %esi,%edx
  80087a:	eb 09                	jmp    800885 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80087c:	83 c2 01             	add    $0x1,%edx
  80087f:	83 c1 01             	add    $0x1,%ecx
  800882:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800885:	39 c2                	cmp    %eax,%edx
  800887:	74 09                	je     800892 <strlcpy+0x32>
  800889:	0f b6 19             	movzbl (%ecx),%ebx
  80088c:	84 db                	test   %bl,%bl
  80088e:	75 ec                	jne    80087c <strlcpy+0x1c>
  800890:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800892:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800895:	29 f0                	sub    %esi,%eax
}
  800897:	5b                   	pop    %ebx
  800898:	5e                   	pop    %esi
  800899:	5d                   	pop    %ebp
  80089a:	c3                   	ret    

0080089b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80089b:	55                   	push   %ebp
  80089c:	89 e5                	mov    %esp,%ebp
  80089e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008a4:	eb 06                	jmp    8008ac <strcmp+0x11>
		p++, q++;
  8008a6:	83 c1 01             	add    $0x1,%ecx
  8008a9:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008ac:	0f b6 01             	movzbl (%ecx),%eax
  8008af:	84 c0                	test   %al,%al
  8008b1:	74 04                	je     8008b7 <strcmp+0x1c>
  8008b3:	3a 02                	cmp    (%edx),%al
  8008b5:	74 ef                	je     8008a6 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b7:	0f b6 c0             	movzbl %al,%eax
  8008ba:	0f b6 12             	movzbl (%edx),%edx
  8008bd:	29 d0                	sub    %edx,%eax
}
  8008bf:	5d                   	pop    %ebp
  8008c0:	c3                   	ret    

008008c1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008c1:	55                   	push   %ebp
  8008c2:	89 e5                	mov    %esp,%ebp
  8008c4:	53                   	push   %ebx
  8008c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008cb:	89 c3                	mov    %eax,%ebx
  8008cd:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008d0:	eb 06                	jmp    8008d8 <strncmp+0x17>
		n--, p++, q++;
  8008d2:	83 c0 01             	add    $0x1,%eax
  8008d5:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008d8:	39 d8                	cmp    %ebx,%eax
  8008da:	74 15                	je     8008f1 <strncmp+0x30>
  8008dc:	0f b6 08             	movzbl (%eax),%ecx
  8008df:	84 c9                	test   %cl,%cl
  8008e1:	74 04                	je     8008e7 <strncmp+0x26>
  8008e3:	3a 0a                	cmp    (%edx),%cl
  8008e5:	74 eb                	je     8008d2 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e7:	0f b6 00             	movzbl (%eax),%eax
  8008ea:	0f b6 12             	movzbl (%edx),%edx
  8008ed:	29 d0                	sub    %edx,%eax
  8008ef:	eb 05                	jmp    8008f6 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008f1:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008f6:	5b                   	pop    %ebx
  8008f7:	5d                   	pop    %ebp
  8008f8:	c3                   	ret    

008008f9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008f9:	55                   	push   %ebp
  8008fa:	89 e5                	mov    %esp,%ebp
  8008fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ff:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800903:	eb 07                	jmp    80090c <strchr+0x13>
		if (*s == c)
  800905:	38 ca                	cmp    %cl,%dl
  800907:	74 0f                	je     800918 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800909:	83 c0 01             	add    $0x1,%eax
  80090c:	0f b6 10             	movzbl (%eax),%edx
  80090f:	84 d2                	test   %dl,%dl
  800911:	75 f2                	jne    800905 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800913:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800918:	5d                   	pop    %ebp
  800919:	c3                   	ret    

0080091a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80091a:	55                   	push   %ebp
  80091b:	89 e5                	mov    %esp,%ebp
  80091d:	8b 45 08             	mov    0x8(%ebp),%eax
  800920:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800924:	eb 03                	jmp    800929 <strfind+0xf>
  800926:	83 c0 01             	add    $0x1,%eax
  800929:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80092c:	38 ca                	cmp    %cl,%dl
  80092e:	74 04                	je     800934 <strfind+0x1a>
  800930:	84 d2                	test   %dl,%dl
  800932:	75 f2                	jne    800926 <strfind+0xc>
			break;
	return (char *) s;
}
  800934:	5d                   	pop    %ebp
  800935:	c3                   	ret    

00800936 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800936:	55                   	push   %ebp
  800937:	89 e5                	mov    %esp,%ebp
  800939:	57                   	push   %edi
  80093a:	56                   	push   %esi
  80093b:	53                   	push   %ebx
  80093c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80093f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800942:	85 c9                	test   %ecx,%ecx
  800944:	74 36                	je     80097c <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800946:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80094c:	75 28                	jne    800976 <memset+0x40>
  80094e:	f6 c1 03             	test   $0x3,%cl
  800951:	75 23                	jne    800976 <memset+0x40>
		c &= 0xFF;
  800953:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800957:	89 d3                	mov    %edx,%ebx
  800959:	c1 e3 08             	shl    $0x8,%ebx
  80095c:	89 d6                	mov    %edx,%esi
  80095e:	c1 e6 18             	shl    $0x18,%esi
  800961:	89 d0                	mov    %edx,%eax
  800963:	c1 e0 10             	shl    $0x10,%eax
  800966:	09 f0                	or     %esi,%eax
  800968:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80096a:	89 d8                	mov    %ebx,%eax
  80096c:	09 d0                	or     %edx,%eax
  80096e:	c1 e9 02             	shr    $0x2,%ecx
  800971:	fc                   	cld    
  800972:	f3 ab                	rep stos %eax,%es:(%edi)
  800974:	eb 06                	jmp    80097c <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800976:	8b 45 0c             	mov    0xc(%ebp),%eax
  800979:	fc                   	cld    
  80097a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80097c:	89 f8                	mov    %edi,%eax
  80097e:	5b                   	pop    %ebx
  80097f:	5e                   	pop    %esi
  800980:	5f                   	pop    %edi
  800981:	5d                   	pop    %ebp
  800982:	c3                   	ret    

00800983 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800983:	55                   	push   %ebp
  800984:	89 e5                	mov    %esp,%ebp
  800986:	57                   	push   %edi
  800987:	56                   	push   %esi
  800988:	8b 45 08             	mov    0x8(%ebp),%eax
  80098b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80098e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800991:	39 c6                	cmp    %eax,%esi
  800993:	73 35                	jae    8009ca <memmove+0x47>
  800995:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800998:	39 d0                	cmp    %edx,%eax
  80099a:	73 2e                	jae    8009ca <memmove+0x47>
		s += n;
		d += n;
  80099c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80099f:	89 d6                	mov    %edx,%esi
  8009a1:	09 fe                	or     %edi,%esi
  8009a3:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009a9:	75 13                	jne    8009be <memmove+0x3b>
  8009ab:	f6 c1 03             	test   $0x3,%cl
  8009ae:	75 0e                	jne    8009be <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009b0:	83 ef 04             	sub    $0x4,%edi
  8009b3:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009b6:	c1 e9 02             	shr    $0x2,%ecx
  8009b9:	fd                   	std    
  8009ba:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009bc:	eb 09                	jmp    8009c7 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009be:	83 ef 01             	sub    $0x1,%edi
  8009c1:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009c4:	fd                   	std    
  8009c5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009c7:	fc                   	cld    
  8009c8:	eb 1d                	jmp    8009e7 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ca:	89 f2                	mov    %esi,%edx
  8009cc:	09 c2                	or     %eax,%edx
  8009ce:	f6 c2 03             	test   $0x3,%dl
  8009d1:	75 0f                	jne    8009e2 <memmove+0x5f>
  8009d3:	f6 c1 03             	test   $0x3,%cl
  8009d6:	75 0a                	jne    8009e2 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009d8:	c1 e9 02             	shr    $0x2,%ecx
  8009db:	89 c7                	mov    %eax,%edi
  8009dd:	fc                   	cld    
  8009de:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e0:	eb 05                	jmp    8009e7 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009e2:	89 c7                	mov    %eax,%edi
  8009e4:	fc                   	cld    
  8009e5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009e7:	5e                   	pop    %esi
  8009e8:	5f                   	pop    %edi
  8009e9:	5d                   	pop    %ebp
  8009ea:	c3                   	ret    

008009eb <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009eb:	55                   	push   %ebp
  8009ec:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009ee:	ff 75 10             	pushl  0x10(%ebp)
  8009f1:	ff 75 0c             	pushl  0xc(%ebp)
  8009f4:	ff 75 08             	pushl  0x8(%ebp)
  8009f7:	e8 87 ff ff ff       	call   800983 <memmove>
}
  8009fc:	c9                   	leave  
  8009fd:	c3                   	ret    

008009fe <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009fe:	55                   	push   %ebp
  8009ff:	89 e5                	mov    %esp,%ebp
  800a01:	56                   	push   %esi
  800a02:	53                   	push   %ebx
  800a03:	8b 45 08             	mov    0x8(%ebp),%eax
  800a06:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a09:	89 c6                	mov    %eax,%esi
  800a0b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a0e:	eb 1a                	jmp    800a2a <memcmp+0x2c>
		if (*s1 != *s2)
  800a10:	0f b6 08             	movzbl (%eax),%ecx
  800a13:	0f b6 1a             	movzbl (%edx),%ebx
  800a16:	38 d9                	cmp    %bl,%cl
  800a18:	74 0a                	je     800a24 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a1a:	0f b6 c1             	movzbl %cl,%eax
  800a1d:	0f b6 db             	movzbl %bl,%ebx
  800a20:	29 d8                	sub    %ebx,%eax
  800a22:	eb 0f                	jmp    800a33 <memcmp+0x35>
		s1++, s2++;
  800a24:	83 c0 01             	add    $0x1,%eax
  800a27:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a2a:	39 f0                	cmp    %esi,%eax
  800a2c:	75 e2                	jne    800a10 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a2e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a33:	5b                   	pop    %ebx
  800a34:	5e                   	pop    %esi
  800a35:	5d                   	pop    %ebp
  800a36:	c3                   	ret    

00800a37 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a37:	55                   	push   %ebp
  800a38:	89 e5                	mov    %esp,%ebp
  800a3a:	53                   	push   %ebx
  800a3b:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a3e:	89 c1                	mov    %eax,%ecx
  800a40:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a43:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a47:	eb 0a                	jmp    800a53 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a49:	0f b6 10             	movzbl (%eax),%edx
  800a4c:	39 da                	cmp    %ebx,%edx
  800a4e:	74 07                	je     800a57 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a50:	83 c0 01             	add    $0x1,%eax
  800a53:	39 c8                	cmp    %ecx,%eax
  800a55:	72 f2                	jb     800a49 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a57:	5b                   	pop    %ebx
  800a58:	5d                   	pop    %ebp
  800a59:	c3                   	ret    

00800a5a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a5a:	55                   	push   %ebp
  800a5b:	89 e5                	mov    %esp,%ebp
  800a5d:	57                   	push   %edi
  800a5e:	56                   	push   %esi
  800a5f:	53                   	push   %ebx
  800a60:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a63:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a66:	eb 03                	jmp    800a6b <strtol+0x11>
		s++;
  800a68:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a6b:	0f b6 01             	movzbl (%ecx),%eax
  800a6e:	3c 20                	cmp    $0x20,%al
  800a70:	74 f6                	je     800a68 <strtol+0xe>
  800a72:	3c 09                	cmp    $0x9,%al
  800a74:	74 f2                	je     800a68 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a76:	3c 2b                	cmp    $0x2b,%al
  800a78:	75 0a                	jne    800a84 <strtol+0x2a>
		s++;
  800a7a:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a7d:	bf 00 00 00 00       	mov    $0x0,%edi
  800a82:	eb 11                	jmp    800a95 <strtol+0x3b>
  800a84:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a89:	3c 2d                	cmp    $0x2d,%al
  800a8b:	75 08                	jne    800a95 <strtol+0x3b>
		s++, neg = 1;
  800a8d:	83 c1 01             	add    $0x1,%ecx
  800a90:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a95:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a9b:	75 15                	jne    800ab2 <strtol+0x58>
  800a9d:	80 39 30             	cmpb   $0x30,(%ecx)
  800aa0:	75 10                	jne    800ab2 <strtol+0x58>
  800aa2:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800aa6:	75 7c                	jne    800b24 <strtol+0xca>
		s += 2, base = 16;
  800aa8:	83 c1 02             	add    $0x2,%ecx
  800aab:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ab0:	eb 16                	jmp    800ac8 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800ab2:	85 db                	test   %ebx,%ebx
  800ab4:	75 12                	jne    800ac8 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ab6:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800abb:	80 39 30             	cmpb   $0x30,(%ecx)
  800abe:	75 08                	jne    800ac8 <strtol+0x6e>
		s++, base = 8;
  800ac0:	83 c1 01             	add    $0x1,%ecx
  800ac3:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ac8:	b8 00 00 00 00       	mov    $0x0,%eax
  800acd:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ad0:	0f b6 11             	movzbl (%ecx),%edx
  800ad3:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ad6:	89 f3                	mov    %esi,%ebx
  800ad8:	80 fb 09             	cmp    $0x9,%bl
  800adb:	77 08                	ja     800ae5 <strtol+0x8b>
			dig = *s - '0';
  800add:	0f be d2             	movsbl %dl,%edx
  800ae0:	83 ea 30             	sub    $0x30,%edx
  800ae3:	eb 22                	jmp    800b07 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ae5:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ae8:	89 f3                	mov    %esi,%ebx
  800aea:	80 fb 19             	cmp    $0x19,%bl
  800aed:	77 08                	ja     800af7 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800aef:	0f be d2             	movsbl %dl,%edx
  800af2:	83 ea 57             	sub    $0x57,%edx
  800af5:	eb 10                	jmp    800b07 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800af7:	8d 72 bf             	lea    -0x41(%edx),%esi
  800afa:	89 f3                	mov    %esi,%ebx
  800afc:	80 fb 19             	cmp    $0x19,%bl
  800aff:	77 16                	ja     800b17 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b01:	0f be d2             	movsbl %dl,%edx
  800b04:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b07:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b0a:	7d 0b                	jge    800b17 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b0c:	83 c1 01             	add    $0x1,%ecx
  800b0f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b13:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b15:	eb b9                	jmp    800ad0 <strtol+0x76>

	if (endptr)
  800b17:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b1b:	74 0d                	je     800b2a <strtol+0xd0>
		*endptr = (char *) s;
  800b1d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b20:	89 0e                	mov    %ecx,(%esi)
  800b22:	eb 06                	jmp    800b2a <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b24:	85 db                	test   %ebx,%ebx
  800b26:	74 98                	je     800ac0 <strtol+0x66>
  800b28:	eb 9e                	jmp    800ac8 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b2a:	89 c2                	mov    %eax,%edx
  800b2c:	f7 da                	neg    %edx
  800b2e:	85 ff                	test   %edi,%edi
  800b30:	0f 45 c2             	cmovne %edx,%eax
}
  800b33:	5b                   	pop    %ebx
  800b34:	5e                   	pop    %esi
  800b35:	5f                   	pop    %edi
  800b36:	5d                   	pop    %ebp
  800b37:	c3                   	ret    

00800b38 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b38:	55                   	push   %ebp
  800b39:	89 e5                	mov    %esp,%ebp
  800b3b:	57                   	push   %edi
  800b3c:	56                   	push   %esi
  800b3d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b46:	8b 55 08             	mov    0x8(%ebp),%edx
  800b49:	89 c3                	mov    %eax,%ebx
  800b4b:	89 c7                	mov    %eax,%edi
  800b4d:	89 c6                	mov    %eax,%esi
  800b4f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b51:	5b                   	pop    %ebx
  800b52:	5e                   	pop    %esi
  800b53:	5f                   	pop    %edi
  800b54:	5d                   	pop    %ebp
  800b55:	c3                   	ret    

00800b56 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b56:	55                   	push   %ebp
  800b57:	89 e5                	mov    %esp,%ebp
  800b59:	57                   	push   %edi
  800b5a:	56                   	push   %esi
  800b5b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b61:	b8 01 00 00 00       	mov    $0x1,%eax
  800b66:	89 d1                	mov    %edx,%ecx
  800b68:	89 d3                	mov    %edx,%ebx
  800b6a:	89 d7                	mov    %edx,%edi
  800b6c:	89 d6                	mov    %edx,%esi
  800b6e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b70:	5b                   	pop    %ebx
  800b71:	5e                   	pop    %esi
  800b72:	5f                   	pop    %edi
  800b73:	5d                   	pop    %ebp
  800b74:	c3                   	ret    

00800b75 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b75:	55                   	push   %ebp
  800b76:	89 e5                	mov    %esp,%ebp
  800b78:	57                   	push   %edi
  800b79:	56                   	push   %esi
  800b7a:	53                   	push   %ebx
  800b7b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b83:	b8 03 00 00 00       	mov    $0x3,%eax
  800b88:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8b:	89 cb                	mov    %ecx,%ebx
  800b8d:	89 cf                	mov    %ecx,%edi
  800b8f:	89 ce                	mov    %ecx,%esi
  800b91:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b93:	85 c0                	test   %eax,%eax
  800b95:	7e 17                	jle    800bae <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b97:	83 ec 0c             	sub    $0xc,%esp
  800b9a:	50                   	push   %eax
  800b9b:	6a 03                	push   $0x3
  800b9d:	68 df 27 80 00       	push   $0x8027df
  800ba2:	6a 23                	push   $0x23
  800ba4:	68 fc 27 80 00       	push   $0x8027fc
  800ba9:	e8 e5 f5 ff ff       	call   800193 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb1:	5b                   	pop    %ebx
  800bb2:	5e                   	pop    %esi
  800bb3:	5f                   	pop    %edi
  800bb4:	5d                   	pop    %ebp
  800bb5:	c3                   	ret    

00800bb6 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bb6:	55                   	push   %ebp
  800bb7:	89 e5                	mov    %esp,%ebp
  800bb9:	57                   	push   %edi
  800bba:	56                   	push   %esi
  800bbb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bbc:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc1:	b8 02 00 00 00       	mov    $0x2,%eax
  800bc6:	89 d1                	mov    %edx,%ecx
  800bc8:	89 d3                	mov    %edx,%ebx
  800bca:	89 d7                	mov    %edx,%edi
  800bcc:	89 d6                	mov    %edx,%esi
  800bce:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bd0:	5b                   	pop    %ebx
  800bd1:	5e                   	pop    %esi
  800bd2:	5f                   	pop    %edi
  800bd3:	5d                   	pop    %ebp
  800bd4:	c3                   	ret    

00800bd5 <sys_yield>:

void
sys_yield(void)
{
  800bd5:	55                   	push   %ebp
  800bd6:	89 e5                	mov    %esp,%ebp
  800bd8:	57                   	push   %edi
  800bd9:	56                   	push   %esi
  800bda:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bdb:	ba 00 00 00 00       	mov    $0x0,%edx
  800be0:	b8 0b 00 00 00       	mov    $0xb,%eax
  800be5:	89 d1                	mov    %edx,%ecx
  800be7:	89 d3                	mov    %edx,%ebx
  800be9:	89 d7                	mov    %edx,%edi
  800beb:	89 d6                	mov    %edx,%esi
  800bed:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bef:	5b                   	pop    %ebx
  800bf0:	5e                   	pop    %esi
  800bf1:	5f                   	pop    %edi
  800bf2:	5d                   	pop    %ebp
  800bf3:	c3                   	ret    

00800bf4 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bf4:	55                   	push   %ebp
  800bf5:	89 e5                	mov    %esp,%ebp
  800bf7:	57                   	push   %edi
  800bf8:	56                   	push   %esi
  800bf9:	53                   	push   %ebx
  800bfa:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfd:	be 00 00 00 00       	mov    $0x0,%esi
  800c02:	b8 04 00 00 00       	mov    $0x4,%eax
  800c07:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c10:	89 f7                	mov    %esi,%edi
  800c12:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c14:	85 c0                	test   %eax,%eax
  800c16:	7e 17                	jle    800c2f <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c18:	83 ec 0c             	sub    $0xc,%esp
  800c1b:	50                   	push   %eax
  800c1c:	6a 04                	push   $0x4
  800c1e:	68 df 27 80 00       	push   $0x8027df
  800c23:	6a 23                	push   $0x23
  800c25:	68 fc 27 80 00       	push   $0x8027fc
  800c2a:	e8 64 f5 ff ff       	call   800193 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c2f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c32:	5b                   	pop    %ebx
  800c33:	5e                   	pop    %esi
  800c34:	5f                   	pop    %edi
  800c35:	5d                   	pop    %ebp
  800c36:	c3                   	ret    

00800c37 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c37:	55                   	push   %ebp
  800c38:	89 e5                	mov    %esp,%ebp
  800c3a:	57                   	push   %edi
  800c3b:	56                   	push   %esi
  800c3c:	53                   	push   %ebx
  800c3d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c40:	b8 05 00 00 00       	mov    $0x5,%eax
  800c45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c48:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c4e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c51:	8b 75 18             	mov    0x18(%ebp),%esi
  800c54:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c56:	85 c0                	test   %eax,%eax
  800c58:	7e 17                	jle    800c71 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5a:	83 ec 0c             	sub    $0xc,%esp
  800c5d:	50                   	push   %eax
  800c5e:	6a 05                	push   $0x5
  800c60:	68 df 27 80 00       	push   $0x8027df
  800c65:	6a 23                	push   $0x23
  800c67:	68 fc 27 80 00       	push   $0x8027fc
  800c6c:	e8 22 f5 ff ff       	call   800193 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c71:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c74:	5b                   	pop    %ebx
  800c75:	5e                   	pop    %esi
  800c76:	5f                   	pop    %edi
  800c77:	5d                   	pop    %ebp
  800c78:	c3                   	ret    

00800c79 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c79:	55                   	push   %ebp
  800c7a:	89 e5                	mov    %esp,%ebp
  800c7c:	57                   	push   %edi
  800c7d:	56                   	push   %esi
  800c7e:	53                   	push   %ebx
  800c7f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c82:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c87:	b8 06 00 00 00       	mov    $0x6,%eax
  800c8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c92:	89 df                	mov    %ebx,%edi
  800c94:	89 de                	mov    %ebx,%esi
  800c96:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c98:	85 c0                	test   %eax,%eax
  800c9a:	7e 17                	jle    800cb3 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9c:	83 ec 0c             	sub    $0xc,%esp
  800c9f:	50                   	push   %eax
  800ca0:	6a 06                	push   $0x6
  800ca2:	68 df 27 80 00       	push   $0x8027df
  800ca7:	6a 23                	push   $0x23
  800ca9:	68 fc 27 80 00       	push   $0x8027fc
  800cae:	e8 e0 f4 ff ff       	call   800193 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cb3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb6:	5b                   	pop    %ebx
  800cb7:	5e                   	pop    %esi
  800cb8:	5f                   	pop    %edi
  800cb9:	5d                   	pop    %ebp
  800cba:	c3                   	ret    

00800cbb <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cbb:	55                   	push   %ebp
  800cbc:	89 e5                	mov    %esp,%ebp
  800cbe:	57                   	push   %edi
  800cbf:	56                   	push   %esi
  800cc0:	53                   	push   %ebx
  800cc1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc9:	b8 08 00 00 00       	mov    $0x8,%eax
  800cce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd1:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd4:	89 df                	mov    %ebx,%edi
  800cd6:	89 de                	mov    %ebx,%esi
  800cd8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cda:	85 c0                	test   %eax,%eax
  800cdc:	7e 17                	jle    800cf5 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cde:	83 ec 0c             	sub    $0xc,%esp
  800ce1:	50                   	push   %eax
  800ce2:	6a 08                	push   $0x8
  800ce4:	68 df 27 80 00       	push   $0x8027df
  800ce9:	6a 23                	push   $0x23
  800ceb:	68 fc 27 80 00       	push   $0x8027fc
  800cf0:	e8 9e f4 ff ff       	call   800193 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cf5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf8:	5b                   	pop    %ebx
  800cf9:	5e                   	pop    %esi
  800cfa:	5f                   	pop    %edi
  800cfb:	5d                   	pop    %ebp
  800cfc:	c3                   	ret    

00800cfd <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cfd:	55                   	push   %ebp
  800cfe:	89 e5                	mov    %esp,%ebp
  800d00:	57                   	push   %edi
  800d01:	56                   	push   %esi
  800d02:	53                   	push   %ebx
  800d03:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d06:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d0b:	b8 09 00 00 00       	mov    $0x9,%eax
  800d10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d13:	8b 55 08             	mov    0x8(%ebp),%edx
  800d16:	89 df                	mov    %ebx,%edi
  800d18:	89 de                	mov    %ebx,%esi
  800d1a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d1c:	85 c0                	test   %eax,%eax
  800d1e:	7e 17                	jle    800d37 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d20:	83 ec 0c             	sub    $0xc,%esp
  800d23:	50                   	push   %eax
  800d24:	6a 09                	push   $0x9
  800d26:	68 df 27 80 00       	push   $0x8027df
  800d2b:	6a 23                	push   $0x23
  800d2d:	68 fc 27 80 00       	push   $0x8027fc
  800d32:	e8 5c f4 ff ff       	call   800193 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d37:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3a:	5b                   	pop    %ebx
  800d3b:	5e                   	pop    %esi
  800d3c:	5f                   	pop    %edi
  800d3d:	5d                   	pop    %ebp
  800d3e:	c3                   	ret    

00800d3f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d3f:	55                   	push   %ebp
  800d40:	89 e5                	mov    %esp,%ebp
  800d42:	57                   	push   %edi
  800d43:	56                   	push   %esi
  800d44:	53                   	push   %ebx
  800d45:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d48:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d4d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d55:	8b 55 08             	mov    0x8(%ebp),%edx
  800d58:	89 df                	mov    %ebx,%edi
  800d5a:	89 de                	mov    %ebx,%esi
  800d5c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d5e:	85 c0                	test   %eax,%eax
  800d60:	7e 17                	jle    800d79 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d62:	83 ec 0c             	sub    $0xc,%esp
  800d65:	50                   	push   %eax
  800d66:	6a 0a                	push   $0xa
  800d68:	68 df 27 80 00       	push   $0x8027df
  800d6d:	6a 23                	push   $0x23
  800d6f:	68 fc 27 80 00       	push   $0x8027fc
  800d74:	e8 1a f4 ff ff       	call   800193 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d79:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7c:	5b                   	pop    %ebx
  800d7d:	5e                   	pop    %esi
  800d7e:	5f                   	pop    %edi
  800d7f:	5d                   	pop    %ebp
  800d80:	c3                   	ret    

00800d81 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d81:	55                   	push   %ebp
  800d82:	89 e5                	mov    %esp,%ebp
  800d84:	57                   	push   %edi
  800d85:	56                   	push   %esi
  800d86:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d87:	be 00 00 00 00       	mov    $0x0,%esi
  800d8c:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d91:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d94:	8b 55 08             	mov    0x8(%ebp),%edx
  800d97:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d9a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d9d:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d9f:	5b                   	pop    %ebx
  800da0:	5e                   	pop    %esi
  800da1:	5f                   	pop    %edi
  800da2:	5d                   	pop    %ebp
  800da3:	c3                   	ret    

00800da4 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800da4:	55                   	push   %ebp
  800da5:	89 e5                	mov    %esp,%ebp
  800da7:	57                   	push   %edi
  800da8:	56                   	push   %esi
  800da9:	53                   	push   %ebx
  800daa:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dad:	b9 00 00 00 00       	mov    $0x0,%ecx
  800db2:	b8 0d 00 00 00       	mov    $0xd,%eax
  800db7:	8b 55 08             	mov    0x8(%ebp),%edx
  800dba:	89 cb                	mov    %ecx,%ebx
  800dbc:	89 cf                	mov    %ecx,%edi
  800dbe:	89 ce                	mov    %ecx,%esi
  800dc0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dc2:	85 c0                	test   %eax,%eax
  800dc4:	7e 17                	jle    800ddd <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc6:	83 ec 0c             	sub    $0xc,%esp
  800dc9:	50                   	push   %eax
  800dca:	6a 0d                	push   $0xd
  800dcc:	68 df 27 80 00       	push   $0x8027df
  800dd1:	6a 23                	push   $0x23
  800dd3:	68 fc 27 80 00       	push   $0x8027fc
  800dd8:	e8 b6 f3 ff ff       	call   800193 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ddd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de0:	5b                   	pop    %ebx
  800de1:	5e                   	pop    %esi
  800de2:	5f                   	pop    %edi
  800de3:	5d                   	pop    %ebp
  800de4:	c3                   	ret    

00800de5 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800de5:	55                   	push   %ebp
  800de6:	89 e5                	mov    %esp,%ebp
  800de8:	57                   	push   %edi
  800de9:	56                   	push   %esi
  800dea:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800deb:	ba 00 00 00 00       	mov    $0x0,%edx
  800df0:	b8 0e 00 00 00       	mov    $0xe,%eax
  800df5:	89 d1                	mov    %edx,%ecx
  800df7:	89 d3                	mov    %edx,%ebx
  800df9:	89 d7                	mov    %edx,%edi
  800dfb:	89 d6                	mov    %edx,%esi
  800dfd:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800dff:	5b                   	pop    %ebx
  800e00:	5e                   	pop    %esi
  800e01:	5f                   	pop    %edi
  800e02:	5d                   	pop    %ebp
  800e03:	c3                   	ret    

00800e04 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e04:	55                   	push   %ebp
  800e05:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e07:	8b 45 08             	mov    0x8(%ebp),%eax
  800e0a:	05 00 00 00 30       	add    $0x30000000,%eax
  800e0f:	c1 e8 0c             	shr    $0xc,%eax
}
  800e12:	5d                   	pop    %ebp
  800e13:	c3                   	ret    

00800e14 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e14:	55                   	push   %ebp
  800e15:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e17:	8b 45 08             	mov    0x8(%ebp),%eax
  800e1a:	05 00 00 00 30       	add    $0x30000000,%eax
  800e1f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e24:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e29:	5d                   	pop    %ebp
  800e2a:	c3                   	ret    

00800e2b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e2b:	55                   	push   %ebp
  800e2c:	89 e5                	mov    %esp,%ebp
  800e2e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e31:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e36:	89 c2                	mov    %eax,%edx
  800e38:	c1 ea 16             	shr    $0x16,%edx
  800e3b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e42:	f6 c2 01             	test   $0x1,%dl
  800e45:	74 11                	je     800e58 <fd_alloc+0x2d>
  800e47:	89 c2                	mov    %eax,%edx
  800e49:	c1 ea 0c             	shr    $0xc,%edx
  800e4c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e53:	f6 c2 01             	test   $0x1,%dl
  800e56:	75 09                	jne    800e61 <fd_alloc+0x36>
			*fd_store = fd;
  800e58:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e5a:	b8 00 00 00 00       	mov    $0x0,%eax
  800e5f:	eb 17                	jmp    800e78 <fd_alloc+0x4d>
  800e61:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e66:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e6b:	75 c9                	jne    800e36 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e6d:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e73:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e78:	5d                   	pop    %ebp
  800e79:	c3                   	ret    

00800e7a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e7a:	55                   	push   %ebp
  800e7b:	89 e5                	mov    %esp,%ebp
  800e7d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e80:	83 f8 1f             	cmp    $0x1f,%eax
  800e83:	77 36                	ja     800ebb <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e85:	c1 e0 0c             	shl    $0xc,%eax
  800e88:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e8d:	89 c2                	mov    %eax,%edx
  800e8f:	c1 ea 16             	shr    $0x16,%edx
  800e92:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e99:	f6 c2 01             	test   $0x1,%dl
  800e9c:	74 24                	je     800ec2 <fd_lookup+0x48>
  800e9e:	89 c2                	mov    %eax,%edx
  800ea0:	c1 ea 0c             	shr    $0xc,%edx
  800ea3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800eaa:	f6 c2 01             	test   $0x1,%dl
  800ead:	74 1a                	je     800ec9 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800eaf:	8b 55 0c             	mov    0xc(%ebp),%edx
  800eb2:	89 02                	mov    %eax,(%edx)
	return 0;
  800eb4:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb9:	eb 13                	jmp    800ece <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ebb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ec0:	eb 0c                	jmp    800ece <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ec2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ec7:	eb 05                	jmp    800ece <fd_lookup+0x54>
  800ec9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800ece:	5d                   	pop    %ebp
  800ecf:	c3                   	ret    

00800ed0 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ed0:	55                   	push   %ebp
  800ed1:	89 e5                	mov    %esp,%ebp
  800ed3:	83 ec 08             	sub    $0x8,%esp
  800ed6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ed9:	ba 8c 28 80 00       	mov    $0x80288c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800ede:	eb 13                	jmp    800ef3 <dev_lookup+0x23>
  800ee0:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800ee3:	39 08                	cmp    %ecx,(%eax)
  800ee5:	75 0c                	jne    800ef3 <dev_lookup+0x23>
			*dev = devtab[i];
  800ee7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eea:	89 01                	mov    %eax,(%ecx)
			return 0;
  800eec:	b8 00 00 00 00       	mov    $0x0,%eax
  800ef1:	eb 2e                	jmp    800f21 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800ef3:	8b 02                	mov    (%edx),%eax
  800ef5:	85 c0                	test   %eax,%eax
  800ef7:	75 e7                	jne    800ee0 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ef9:	a1 20 60 80 00       	mov    0x806020,%eax
  800efe:	8b 40 48             	mov    0x48(%eax),%eax
  800f01:	83 ec 04             	sub    $0x4,%esp
  800f04:	51                   	push   %ecx
  800f05:	50                   	push   %eax
  800f06:	68 0c 28 80 00       	push   $0x80280c
  800f0b:	e8 5c f3 ff ff       	call   80026c <cprintf>
	*dev = 0;
  800f10:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f13:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f19:	83 c4 10             	add    $0x10,%esp
  800f1c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f21:	c9                   	leave  
  800f22:	c3                   	ret    

00800f23 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f23:	55                   	push   %ebp
  800f24:	89 e5                	mov    %esp,%ebp
  800f26:	56                   	push   %esi
  800f27:	53                   	push   %ebx
  800f28:	83 ec 10             	sub    $0x10,%esp
  800f2b:	8b 75 08             	mov    0x8(%ebp),%esi
  800f2e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f31:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f34:	50                   	push   %eax
  800f35:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f3b:	c1 e8 0c             	shr    $0xc,%eax
  800f3e:	50                   	push   %eax
  800f3f:	e8 36 ff ff ff       	call   800e7a <fd_lookup>
  800f44:	83 c4 08             	add    $0x8,%esp
  800f47:	85 c0                	test   %eax,%eax
  800f49:	78 05                	js     800f50 <fd_close+0x2d>
	    || fd != fd2)
  800f4b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f4e:	74 0c                	je     800f5c <fd_close+0x39>
		return (must_exist ? r : 0);
  800f50:	84 db                	test   %bl,%bl
  800f52:	ba 00 00 00 00       	mov    $0x0,%edx
  800f57:	0f 44 c2             	cmove  %edx,%eax
  800f5a:	eb 41                	jmp    800f9d <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f5c:	83 ec 08             	sub    $0x8,%esp
  800f5f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f62:	50                   	push   %eax
  800f63:	ff 36                	pushl  (%esi)
  800f65:	e8 66 ff ff ff       	call   800ed0 <dev_lookup>
  800f6a:	89 c3                	mov    %eax,%ebx
  800f6c:	83 c4 10             	add    $0x10,%esp
  800f6f:	85 c0                	test   %eax,%eax
  800f71:	78 1a                	js     800f8d <fd_close+0x6a>
		if (dev->dev_close)
  800f73:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f76:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f79:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f7e:	85 c0                	test   %eax,%eax
  800f80:	74 0b                	je     800f8d <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f82:	83 ec 0c             	sub    $0xc,%esp
  800f85:	56                   	push   %esi
  800f86:	ff d0                	call   *%eax
  800f88:	89 c3                	mov    %eax,%ebx
  800f8a:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f8d:	83 ec 08             	sub    $0x8,%esp
  800f90:	56                   	push   %esi
  800f91:	6a 00                	push   $0x0
  800f93:	e8 e1 fc ff ff       	call   800c79 <sys_page_unmap>
	return r;
  800f98:	83 c4 10             	add    $0x10,%esp
  800f9b:	89 d8                	mov    %ebx,%eax
}
  800f9d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fa0:	5b                   	pop    %ebx
  800fa1:	5e                   	pop    %esi
  800fa2:	5d                   	pop    %ebp
  800fa3:	c3                   	ret    

00800fa4 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800fa4:	55                   	push   %ebp
  800fa5:	89 e5                	mov    %esp,%ebp
  800fa7:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800faa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fad:	50                   	push   %eax
  800fae:	ff 75 08             	pushl  0x8(%ebp)
  800fb1:	e8 c4 fe ff ff       	call   800e7a <fd_lookup>
  800fb6:	83 c4 08             	add    $0x8,%esp
  800fb9:	85 c0                	test   %eax,%eax
  800fbb:	78 10                	js     800fcd <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800fbd:	83 ec 08             	sub    $0x8,%esp
  800fc0:	6a 01                	push   $0x1
  800fc2:	ff 75 f4             	pushl  -0xc(%ebp)
  800fc5:	e8 59 ff ff ff       	call   800f23 <fd_close>
  800fca:	83 c4 10             	add    $0x10,%esp
}
  800fcd:	c9                   	leave  
  800fce:	c3                   	ret    

00800fcf <close_all>:

void
close_all(void)
{
  800fcf:	55                   	push   %ebp
  800fd0:	89 e5                	mov    %esp,%ebp
  800fd2:	53                   	push   %ebx
  800fd3:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fd6:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fdb:	83 ec 0c             	sub    $0xc,%esp
  800fde:	53                   	push   %ebx
  800fdf:	e8 c0 ff ff ff       	call   800fa4 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800fe4:	83 c3 01             	add    $0x1,%ebx
  800fe7:	83 c4 10             	add    $0x10,%esp
  800fea:	83 fb 20             	cmp    $0x20,%ebx
  800fed:	75 ec                	jne    800fdb <close_all+0xc>
		close(i);
}
  800fef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ff2:	c9                   	leave  
  800ff3:	c3                   	ret    

00800ff4 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800ff4:	55                   	push   %ebp
  800ff5:	89 e5                	mov    %esp,%ebp
  800ff7:	57                   	push   %edi
  800ff8:	56                   	push   %esi
  800ff9:	53                   	push   %ebx
  800ffa:	83 ec 2c             	sub    $0x2c,%esp
  800ffd:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801000:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801003:	50                   	push   %eax
  801004:	ff 75 08             	pushl  0x8(%ebp)
  801007:	e8 6e fe ff ff       	call   800e7a <fd_lookup>
  80100c:	83 c4 08             	add    $0x8,%esp
  80100f:	85 c0                	test   %eax,%eax
  801011:	0f 88 c1 00 00 00    	js     8010d8 <dup+0xe4>
		return r;
	close(newfdnum);
  801017:	83 ec 0c             	sub    $0xc,%esp
  80101a:	56                   	push   %esi
  80101b:	e8 84 ff ff ff       	call   800fa4 <close>

	newfd = INDEX2FD(newfdnum);
  801020:	89 f3                	mov    %esi,%ebx
  801022:	c1 e3 0c             	shl    $0xc,%ebx
  801025:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80102b:	83 c4 04             	add    $0x4,%esp
  80102e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801031:	e8 de fd ff ff       	call   800e14 <fd2data>
  801036:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801038:	89 1c 24             	mov    %ebx,(%esp)
  80103b:	e8 d4 fd ff ff       	call   800e14 <fd2data>
  801040:	83 c4 10             	add    $0x10,%esp
  801043:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801046:	89 f8                	mov    %edi,%eax
  801048:	c1 e8 16             	shr    $0x16,%eax
  80104b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801052:	a8 01                	test   $0x1,%al
  801054:	74 37                	je     80108d <dup+0x99>
  801056:	89 f8                	mov    %edi,%eax
  801058:	c1 e8 0c             	shr    $0xc,%eax
  80105b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801062:	f6 c2 01             	test   $0x1,%dl
  801065:	74 26                	je     80108d <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801067:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80106e:	83 ec 0c             	sub    $0xc,%esp
  801071:	25 07 0e 00 00       	and    $0xe07,%eax
  801076:	50                   	push   %eax
  801077:	ff 75 d4             	pushl  -0x2c(%ebp)
  80107a:	6a 00                	push   $0x0
  80107c:	57                   	push   %edi
  80107d:	6a 00                	push   $0x0
  80107f:	e8 b3 fb ff ff       	call   800c37 <sys_page_map>
  801084:	89 c7                	mov    %eax,%edi
  801086:	83 c4 20             	add    $0x20,%esp
  801089:	85 c0                	test   %eax,%eax
  80108b:	78 2e                	js     8010bb <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80108d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801090:	89 d0                	mov    %edx,%eax
  801092:	c1 e8 0c             	shr    $0xc,%eax
  801095:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80109c:	83 ec 0c             	sub    $0xc,%esp
  80109f:	25 07 0e 00 00       	and    $0xe07,%eax
  8010a4:	50                   	push   %eax
  8010a5:	53                   	push   %ebx
  8010a6:	6a 00                	push   $0x0
  8010a8:	52                   	push   %edx
  8010a9:	6a 00                	push   $0x0
  8010ab:	e8 87 fb ff ff       	call   800c37 <sys_page_map>
  8010b0:	89 c7                	mov    %eax,%edi
  8010b2:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8010b5:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010b7:	85 ff                	test   %edi,%edi
  8010b9:	79 1d                	jns    8010d8 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010bb:	83 ec 08             	sub    $0x8,%esp
  8010be:	53                   	push   %ebx
  8010bf:	6a 00                	push   $0x0
  8010c1:	e8 b3 fb ff ff       	call   800c79 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010c6:	83 c4 08             	add    $0x8,%esp
  8010c9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010cc:	6a 00                	push   $0x0
  8010ce:	e8 a6 fb ff ff       	call   800c79 <sys_page_unmap>
	return r;
  8010d3:	83 c4 10             	add    $0x10,%esp
  8010d6:	89 f8                	mov    %edi,%eax
}
  8010d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010db:	5b                   	pop    %ebx
  8010dc:	5e                   	pop    %esi
  8010dd:	5f                   	pop    %edi
  8010de:	5d                   	pop    %ebp
  8010df:	c3                   	ret    

008010e0 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010e0:	55                   	push   %ebp
  8010e1:	89 e5                	mov    %esp,%ebp
  8010e3:	53                   	push   %ebx
  8010e4:	83 ec 14             	sub    $0x14,%esp
  8010e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010ea:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010ed:	50                   	push   %eax
  8010ee:	53                   	push   %ebx
  8010ef:	e8 86 fd ff ff       	call   800e7a <fd_lookup>
  8010f4:	83 c4 08             	add    $0x8,%esp
  8010f7:	89 c2                	mov    %eax,%edx
  8010f9:	85 c0                	test   %eax,%eax
  8010fb:	78 6d                	js     80116a <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010fd:	83 ec 08             	sub    $0x8,%esp
  801100:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801103:	50                   	push   %eax
  801104:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801107:	ff 30                	pushl  (%eax)
  801109:	e8 c2 fd ff ff       	call   800ed0 <dev_lookup>
  80110e:	83 c4 10             	add    $0x10,%esp
  801111:	85 c0                	test   %eax,%eax
  801113:	78 4c                	js     801161 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801115:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801118:	8b 42 08             	mov    0x8(%edx),%eax
  80111b:	83 e0 03             	and    $0x3,%eax
  80111e:	83 f8 01             	cmp    $0x1,%eax
  801121:	75 21                	jne    801144 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801123:	a1 20 60 80 00       	mov    0x806020,%eax
  801128:	8b 40 48             	mov    0x48(%eax),%eax
  80112b:	83 ec 04             	sub    $0x4,%esp
  80112e:	53                   	push   %ebx
  80112f:	50                   	push   %eax
  801130:	68 50 28 80 00       	push   $0x802850
  801135:	e8 32 f1 ff ff       	call   80026c <cprintf>
		return -E_INVAL;
  80113a:	83 c4 10             	add    $0x10,%esp
  80113d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801142:	eb 26                	jmp    80116a <read+0x8a>
	}
	if (!dev->dev_read)
  801144:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801147:	8b 40 08             	mov    0x8(%eax),%eax
  80114a:	85 c0                	test   %eax,%eax
  80114c:	74 17                	je     801165 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80114e:	83 ec 04             	sub    $0x4,%esp
  801151:	ff 75 10             	pushl  0x10(%ebp)
  801154:	ff 75 0c             	pushl  0xc(%ebp)
  801157:	52                   	push   %edx
  801158:	ff d0                	call   *%eax
  80115a:	89 c2                	mov    %eax,%edx
  80115c:	83 c4 10             	add    $0x10,%esp
  80115f:	eb 09                	jmp    80116a <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801161:	89 c2                	mov    %eax,%edx
  801163:	eb 05                	jmp    80116a <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801165:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80116a:	89 d0                	mov    %edx,%eax
  80116c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80116f:	c9                   	leave  
  801170:	c3                   	ret    

00801171 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801171:	55                   	push   %ebp
  801172:	89 e5                	mov    %esp,%ebp
  801174:	57                   	push   %edi
  801175:	56                   	push   %esi
  801176:	53                   	push   %ebx
  801177:	83 ec 0c             	sub    $0xc,%esp
  80117a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80117d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801180:	bb 00 00 00 00       	mov    $0x0,%ebx
  801185:	eb 21                	jmp    8011a8 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801187:	83 ec 04             	sub    $0x4,%esp
  80118a:	89 f0                	mov    %esi,%eax
  80118c:	29 d8                	sub    %ebx,%eax
  80118e:	50                   	push   %eax
  80118f:	89 d8                	mov    %ebx,%eax
  801191:	03 45 0c             	add    0xc(%ebp),%eax
  801194:	50                   	push   %eax
  801195:	57                   	push   %edi
  801196:	e8 45 ff ff ff       	call   8010e0 <read>
		if (m < 0)
  80119b:	83 c4 10             	add    $0x10,%esp
  80119e:	85 c0                	test   %eax,%eax
  8011a0:	78 10                	js     8011b2 <readn+0x41>
			return m;
		if (m == 0)
  8011a2:	85 c0                	test   %eax,%eax
  8011a4:	74 0a                	je     8011b0 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011a6:	01 c3                	add    %eax,%ebx
  8011a8:	39 f3                	cmp    %esi,%ebx
  8011aa:	72 db                	jb     801187 <readn+0x16>
  8011ac:	89 d8                	mov    %ebx,%eax
  8011ae:	eb 02                	jmp    8011b2 <readn+0x41>
  8011b0:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8011b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011b5:	5b                   	pop    %ebx
  8011b6:	5e                   	pop    %esi
  8011b7:	5f                   	pop    %edi
  8011b8:	5d                   	pop    %ebp
  8011b9:	c3                   	ret    

008011ba <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011ba:	55                   	push   %ebp
  8011bb:	89 e5                	mov    %esp,%ebp
  8011bd:	53                   	push   %ebx
  8011be:	83 ec 14             	sub    $0x14,%esp
  8011c1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011c4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011c7:	50                   	push   %eax
  8011c8:	53                   	push   %ebx
  8011c9:	e8 ac fc ff ff       	call   800e7a <fd_lookup>
  8011ce:	83 c4 08             	add    $0x8,%esp
  8011d1:	89 c2                	mov    %eax,%edx
  8011d3:	85 c0                	test   %eax,%eax
  8011d5:	78 68                	js     80123f <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011d7:	83 ec 08             	sub    $0x8,%esp
  8011da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011dd:	50                   	push   %eax
  8011de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011e1:	ff 30                	pushl  (%eax)
  8011e3:	e8 e8 fc ff ff       	call   800ed0 <dev_lookup>
  8011e8:	83 c4 10             	add    $0x10,%esp
  8011eb:	85 c0                	test   %eax,%eax
  8011ed:	78 47                	js     801236 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011f2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011f6:	75 21                	jne    801219 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011f8:	a1 20 60 80 00       	mov    0x806020,%eax
  8011fd:	8b 40 48             	mov    0x48(%eax),%eax
  801200:	83 ec 04             	sub    $0x4,%esp
  801203:	53                   	push   %ebx
  801204:	50                   	push   %eax
  801205:	68 6c 28 80 00       	push   $0x80286c
  80120a:	e8 5d f0 ff ff       	call   80026c <cprintf>
		return -E_INVAL;
  80120f:	83 c4 10             	add    $0x10,%esp
  801212:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801217:	eb 26                	jmp    80123f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801219:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80121c:	8b 52 0c             	mov    0xc(%edx),%edx
  80121f:	85 d2                	test   %edx,%edx
  801221:	74 17                	je     80123a <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801223:	83 ec 04             	sub    $0x4,%esp
  801226:	ff 75 10             	pushl  0x10(%ebp)
  801229:	ff 75 0c             	pushl  0xc(%ebp)
  80122c:	50                   	push   %eax
  80122d:	ff d2                	call   *%edx
  80122f:	89 c2                	mov    %eax,%edx
  801231:	83 c4 10             	add    $0x10,%esp
  801234:	eb 09                	jmp    80123f <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801236:	89 c2                	mov    %eax,%edx
  801238:	eb 05                	jmp    80123f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80123a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80123f:	89 d0                	mov    %edx,%eax
  801241:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801244:	c9                   	leave  
  801245:	c3                   	ret    

00801246 <seek>:

int
seek(int fdnum, off_t offset)
{
  801246:	55                   	push   %ebp
  801247:	89 e5                	mov    %esp,%ebp
  801249:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80124c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80124f:	50                   	push   %eax
  801250:	ff 75 08             	pushl  0x8(%ebp)
  801253:	e8 22 fc ff ff       	call   800e7a <fd_lookup>
  801258:	83 c4 08             	add    $0x8,%esp
  80125b:	85 c0                	test   %eax,%eax
  80125d:	78 0e                	js     80126d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80125f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801262:	8b 55 0c             	mov    0xc(%ebp),%edx
  801265:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801268:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80126d:	c9                   	leave  
  80126e:	c3                   	ret    

0080126f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80126f:	55                   	push   %ebp
  801270:	89 e5                	mov    %esp,%ebp
  801272:	53                   	push   %ebx
  801273:	83 ec 14             	sub    $0x14,%esp
  801276:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801279:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80127c:	50                   	push   %eax
  80127d:	53                   	push   %ebx
  80127e:	e8 f7 fb ff ff       	call   800e7a <fd_lookup>
  801283:	83 c4 08             	add    $0x8,%esp
  801286:	89 c2                	mov    %eax,%edx
  801288:	85 c0                	test   %eax,%eax
  80128a:	78 65                	js     8012f1 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80128c:	83 ec 08             	sub    $0x8,%esp
  80128f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801292:	50                   	push   %eax
  801293:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801296:	ff 30                	pushl  (%eax)
  801298:	e8 33 fc ff ff       	call   800ed0 <dev_lookup>
  80129d:	83 c4 10             	add    $0x10,%esp
  8012a0:	85 c0                	test   %eax,%eax
  8012a2:	78 44                	js     8012e8 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012a7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012ab:	75 21                	jne    8012ce <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012ad:	a1 20 60 80 00       	mov    0x806020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012b2:	8b 40 48             	mov    0x48(%eax),%eax
  8012b5:	83 ec 04             	sub    $0x4,%esp
  8012b8:	53                   	push   %ebx
  8012b9:	50                   	push   %eax
  8012ba:	68 2c 28 80 00       	push   $0x80282c
  8012bf:	e8 a8 ef ff ff       	call   80026c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012c4:	83 c4 10             	add    $0x10,%esp
  8012c7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012cc:	eb 23                	jmp    8012f1 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8012ce:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012d1:	8b 52 18             	mov    0x18(%edx),%edx
  8012d4:	85 d2                	test   %edx,%edx
  8012d6:	74 14                	je     8012ec <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012d8:	83 ec 08             	sub    $0x8,%esp
  8012db:	ff 75 0c             	pushl  0xc(%ebp)
  8012de:	50                   	push   %eax
  8012df:	ff d2                	call   *%edx
  8012e1:	89 c2                	mov    %eax,%edx
  8012e3:	83 c4 10             	add    $0x10,%esp
  8012e6:	eb 09                	jmp    8012f1 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012e8:	89 c2                	mov    %eax,%edx
  8012ea:	eb 05                	jmp    8012f1 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012ec:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8012f1:	89 d0                	mov    %edx,%eax
  8012f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012f6:	c9                   	leave  
  8012f7:	c3                   	ret    

008012f8 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012f8:	55                   	push   %ebp
  8012f9:	89 e5                	mov    %esp,%ebp
  8012fb:	53                   	push   %ebx
  8012fc:	83 ec 14             	sub    $0x14,%esp
  8012ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801302:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801305:	50                   	push   %eax
  801306:	ff 75 08             	pushl  0x8(%ebp)
  801309:	e8 6c fb ff ff       	call   800e7a <fd_lookup>
  80130e:	83 c4 08             	add    $0x8,%esp
  801311:	89 c2                	mov    %eax,%edx
  801313:	85 c0                	test   %eax,%eax
  801315:	78 58                	js     80136f <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801317:	83 ec 08             	sub    $0x8,%esp
  80131a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80131d:	50                   	push   %eax
  80131e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801321:	ff 30                	pushl  (%eax)
  801323:	e8 a8 fb ff ff       	call   800ed0 <dev_lookup>
  801328:	83 c4 10             	add    $0x10,%esp
  80132b:	85 c0                	test   %eax,%eax
  80132d:	78 37                	js     801366 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80132f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801332:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801336:	74 32                	je     80136a <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801338:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80133b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801342:	00 00 00 
	stat->st_isdir = 0;
  801345:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80134c:	00 00 00 
	stat->st_dev = dev;
  80134f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801355:	83 ec 08             	sub    $0x8,%esp
  801358:	53                   	push   %ebx
  801359:	ff 75 f0             	pushl  -0x10(%ebp)
  80135c:	ff 50 14             	call   *0x14(%eax)
  80135f:	89 c2                	mov    %eax,%edx
  801361:	83 c4 10             	add    $0x10,%esp
  801364:	eb 09                	jmp    80136f <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801366:	89 c2                	mov    %eax,%edx
  801368:	eb 05                	jmp    80136f <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80136a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80136f:	89 d0                	mov    %edx,%eax
  801371:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801374:	c9                   	leave  
  801375:	c3                   	ret    

00801376 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801376:	55                   	push   %ebp
  801377:	89 e5                	mov    %esp,%ebp
  801379:	56                   	push   %esi
  80137a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80137b:	83 ec 08             	sub    $0x8,%esp
  80137e:	6a 00                	push   $0x0
  801380:	ff 75 08             	pushl  0x8(%ebp)
  801383:	e8 0c 02 00 00       	call   801594 <open>
  801388:	89 c3                	mov    %eax,%ebx
  80138a:	83 c4 10             	add    $0x10,%esp
  80138d:	85 c0                	test   %eax,%eax
  80138f:	78 1b                	js     8013ac <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801391:	83 ec 08             	sub    $0x8,%esp
  801394:	ff 75 0c             	pushl  0xc(%ebp)
  801397:	50                   	push   %eax
  801398:	e8 5b ff ff ff       	call   8012f8 <fstat>
  80139d:	89 c6                	mov    %eax,%esi
	close(fd);
  80139f:	89 1c 24             	mov    %ebx,(%esp)
  8013a2:	e8 fd fb ff ff       	call   800fa4 <close>
	return r;
  8013a7:	83 c4 10             	add    $0x10,%esp
  8013aa:	89 f0                	mov    %esi,%eax
}
  8013ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013af:	5b                   	pop    %ebx
  8013b0:	5e                   	pop    %esi
  8013b1:	5d                   	pop    %ebp
  8013b2:	c3                   	ret    

008013b3 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013b3:	55                   	push   %ebp
  8013b4:	89 e5                	mov    %esp,%ebp
  8013b6:	56                   	push   %esi
  8013b7:	53                   	push   %ebx
  8013b8:	89 c6                	mov    %eax,%esi
  8013ba:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013bc:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013c3:	75 12                	jne    8013d7 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013c5:	83 ec 0c             	sub    $0xc,%esp
  8013c8:	6a 01                	push   $0x1
  8013ca:	e8 7c 0d 00 00       	call   80214b <ipc_find_env>
  8013cf:	a3 00 40 80 00       	mov    %eax,0x804000
  8013d4:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013d7:	6a 07                	push   $0x7
  8013d9:	68 00 70 80 00       	push   $0x807000
  8013de:	56                   	push   %esi
  8013df:	ff 35 00 40 80 00    	pushl  0x804000
  8013e5:	e8 0d 0d 00 00       	call   8020f7 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013ea:	83 c4 0c             	add    $0xc,%esp
  8013ed:	6a 00                	push   $0x0
  8013ef:	53                   	push   %ebx
  8013f0:	6a 00                	push   $0x0
  8013f2:	e8 97 0c 00 00       	call   80208e <ipc_recv>
}
  8013f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013fa:	5b                   	pop    %ebx
  8013fb:	5e                   	pop    %esi
  8013fc:	5d                   	pop    %ebp
  8013fd:	c3                   	ret    

008013fe <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013fe:	55                   	push   %ebp
  8013ff:	89 e5                	mov    %esp,%ebp
  801401:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801404:	8b 45 08             	mov    0x8(%ebp),%eax
  801407:	8b 40 0c             	mov    0xc(%eax),%eax
  80140a:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.set_size.req_size = newsize;
  80140f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801412:	a3 04 70 80 00       	mov    %eax,0x807004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801417:	ba 00 00 00 00       	mov    $0x0,%edx
  80141c:	b8 02 00 00 00       	mov    $0x2,%eax
  801421:	e8 8d ff ff ff       	call   8013b3 <fsipc>
}
  801426:	c9                   	leave  
  801427:	c3                   	ret    

00801428 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801428:	55                   	push   %ebp
  801429:	89 e5                	mov    %esp,%ebp
  80142b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80142e:	8b 45 08             	mov    0x8(%ebp),%eax
  801431:	8b 40 0c             	mov    0xc(%eax),%eax
  801434:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  801439:	ba 00 00 00 00       	mov    $0x0,%edx
  80143e:	b8 06 00 00 00       	mov    $0x6,%eax
  801443:	e8 6b ff ff ff       	call   8013b3 <fsipc>
}
  801448:	c9                   	leave  
  801449:	c3                   	ret    

0080144a <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80144a:	55                   	push   %ebp
  80144b:	89 e5                	mov    %esp,%ebp
  80144d:	53                   	push   %ebx
  80144e:	83 ec 04             	sub    $0x4,%esp
  801451:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801454:	8b 45 08             	mov    0x8(%ebp),%eax
  801457:	8b 40 0c             	mov    0xc(%eax),%eax
  80145a:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80145f:	ba 00 00 00 00       	mov    $0x0,%edx
  801464:	b8 05 00 00 00       	mov    $0x5,%eax
  801469:	e8 45 ff ff ff       	call   8013b3 <fsipc>
  80146e:	85 c0                	test   %eax,%eax
  801470:	78 2c                	js     80149e <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801472:	83 ec 08             	sub    $0x8,%esp
  801475:	68 00 70 80 00       	push   $0x807000
  80147a:	53                   	push   %ebx
  80147b:	e8 71 f3 ff ff       	call   8007f1 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801480:	a1 80 70 80 00       	mov    0x807080,%eax
  801485:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80148b:	a1 84 70 80 00       	mov    0x807084,%eax
  801490:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801496:	83 c4 10             	add    $0x10,%esp
  801499:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80149e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014a1:	c9                   	leave  
  8014a2:	c3                   	ret    

008014a3 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8014a3:	55                   	push   %ebp
  8014a4:	89 e5                	mov    %esp,%ebp
  8014a6:	53                   	push   %ebx
  8014a7:	83 ec 08             	sub    $0x8,%esp
  8014aa:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014ad:	8b 55 08             	mov    0x8(%ebp),%edx
  8014b0:	8b 52 0c             	mov    0xc(%edx),%edx
  8014b3:	89 15 00 70 80 00    	mov    %edx,0x807000
  8014b9:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8014be:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  8014c3:	0f 46 d8             	cmovbe %eax,%ebx
	
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  8014c6:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  8014cc:	53                   	push   %ebx
  8014cd:	ff 75 0c             	pushl  0xc(%ebp)
  8014d0:	68 08 70 80 00       	push   $0x807008
  8014d5:	e8 a9 f4 ff ff       	call   800983 <memmove>

	
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) 
  8014da:	ba 00 00 00 00       	mov    $0x0,%edx
  8014df:	b8 04 00 00 00       	mov    $0x4,%eax
  8014e4:	e8 ca fe ff ff       	call   8013b3 <fsipc>
  8014e9:	83 c4 10             	add    $0x10,%esp
  8014ec:	85 c0                	test   %eax,%eax
  8014ee:	78 1d                	js     80150d <devfile_write+0x6a>
		return r;
	assert(r <= n_real); 
  8014f0:	39 d8                	cmp    %ebx,%eax
  8014f2:	76 19                	jbe    80150d <devfile_write+0x6a>
  8014f4:	68 a0 28 80 00       	push   $0x8028a0
  8014f9:	68 ac 28 80 00       	push   $0x8028ac
  8014fe:	68 a3 00 00 00       	push   $0xa3
  801503:	68 c1 28 80 00       	push   $0x8028c1
  801508:	e8 86 ec ff ff       	call   800193 <_panic>
	return r;
}
  80150d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801510:	c9                   	leave  
  801511:	c3                   	ret    

00801512 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801512:	55                   	push   %ebp
  801513:	89 e5                	mov    %esp,%ebp
  801515:	56                   	push   %esi
  801516:	53                   	push   %ebx
  801517:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80151a:	8b 45 08             	mov    0x8(%ebp),%eax
  80151d:	8b 40 0c             	mov    0xc(%eax),%eax
  801520:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  801525:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80152b:	ba 00 00 00 00       	mov    $0x0,%edx
  801530:	b8 03 00 00 00       	mov    $0x3,%eax
  801535:	e8 79 fe ff ff       	call   8013b3 <fsipc>
  80153a:	89 c3                	mov    %eax,%ebx
  80153c:	85 c0                	test   %eax,%eax
  80153e:	78 4b                	js     80158b <devfile_read+0x79>
		return r;
	assert(r <= n);
  801540:	39 c6                	cmp    %eax,%esi
  801542:	73 16                	jae    80155a <devfile_read+0x48>
  801544:	68 cc 28 80 00       	push   $0x8028cc
  801549:	68 ac 28 80 00       	push   $0x8028ac
  80154e:	6a 7c                	push   $0x7c
  801550:	68 c1 28 80 00       	push   $0x8028c1
  801555:	e8 39 ec ff ff       	call   800193 <_panic>
	assert(r <= PGSIZE);
  80155a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80155f:	7e 16                	jle    801577 <devfile_read+0x65>
  801561:	68 d3 28 80 00       	push   $0x8028d3
  801566:	68 ac 28 80 00       	push   $0x8028ac
  80156b:	6a 7d                	push   $0x7d
  80156d:	68 c1 28 80 00       	push   $0x8028c1
  801572:	e8 1c ec ff ff       	call   800193 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801577:	83 ec 04             	sub    $0x4,%esp
  80157a:	50                   	push   %eax
  80157b:	68 00 70 80 00       	push   $0x807000
  801580:	ff 75 0c             	pushl  0xc(%ebp)
  801583:	e8 fb f3 ff ff       	call   800983 <memmove>
	return r;
  801588:	83 c4 10             	add    $0x10,%esp
}
  80158b:	89 d8                	mov    %ebx,%eax
  80158d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801590:	5b                   	pop    %ebx
  801591:	5e                   	pop    %esi
  801592:	5d                   	pop    %ebp
  801593:	c3                   	ret    

00801594 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801594:	55                   	push   %ebp
  801595:	89 e5                	mov    %esp,%ebp
  801597:	53                   	push   %ebx
  801598:	83 ec 20             	sub    $0x20,%esp
  80159b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80159e:	53                   	push   %ebx
  80159f:	e8 14 f2 ff ff       	call   8007b8 <strlen>
  8015a4:	83 c4 10             	add    $0x10,%esp
  8015a7:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015ac:	7f 67                	jg     801615 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015ae:	83 ec 0c             	sub    $0xc,%esp
  8015b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015b4:	50                   	push   %eax
  8015b5:	e8 71 f8 ff ff       	call   800e2b <fd_alloc>
  8015ba:	83 c4 10             	add    $0x10,%esp
		return r;
  8015bd:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015bf:	85 c0                	test   %eax,%eax
  8015c1:	78 57                	js     80161a <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015c3:	83 ec 08             	sub    $0x8,%esp
  8015c6:	53                   	push   %ebx
  8015c7:	68 00 70 80 00       	push   $0x807000
  8015cc:	e8 20 f2 ff ff       	call   8007f1 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015d4:	a3 00 74 80 00       	mov    %eax,0x807400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015d9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015dc:	b8 01 00 00 00       	mov    $0x1,%eax
  8015e1:	e8 cd fd ff ff       	call   8013b3 <fsipc>
  8015e6:	89 c3                	mov    %eax,%ebx
  8015e8:	83 c4 10             	add    $0x10,%esp
  8015eb:	85 c0                	test   %eax,%eax
  8015ed:	79 14                	jns    801603 <open+0x6f>
		fd_close(fd, 0);
  8015ef:	83 ec 08             	sub    $0x8,%esp
  8015f2:	6a 00                	push   $0x0
  8015f4:	ff 75 f4             	pushl  -0xc(%ebp)
  8015f7:	e8 27 f9 ff ff       	call   800f23 <fd_close>
		return r;
  8015fc:	83 c4 10             	add    $0x10,%esp
  8015ff:	89 da                	mov    %ebx,%edx
  801601:	eb 17                	jmp    80161a <open+0x86>
	}

	return fd2num(fd);
  801603:	83 ec 0c             	sub    $0xc,%esp
  801606:	ff 75 f4             	pushl  -0xc(%ebp)
  801609:	e8 f6 f7 ff ff       	call   800e04 <fd2num>
  80160e:	89 c2                	mov    %eax,%edx
  801610:	83 c4 10             	add    $0x10,%esp
  801613:	eb 05                	jmp    80161a <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801615:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80161a:	89 d0                	mov    %edx,%eax
  80161c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80161f:	c9                   	leave  
  801620:	c3                   	ret    

00801621 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801621:	55                   	push   %ebp
  801622:	89 e5                	mov    %esp,%ebp
  801624:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801627:	ba 00 00 00 00       	mov    $0x0,%edx
  80162c:	b8 08 00 00 00       	mov    $0x8,%eax
  801631:	e8 7d fd ff ff       	call   8013b3 <fsipc>
}
  801636:	c9                   	leave  
  801637:	c3                   	ret    

00801638 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801638:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  80163c:	7e 37                	jle    801675 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  80163e:	55                   	push   %ebp
  80163f:	89 e5                	mov    %esp,%ebp
  801641:	53                   	push   %ebx
  801642:	83 ec 08             	sub    $0x8,%esp
  801645:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  801647:	ff 70 04             	pushl  0x4(%eax)
  80164a:	8d 40 10             	lea    0x10(%eax),%eax
  80164d:	50                   	push   %eax
  80164e:	ff 33                	pushl  (%ebx)
  801650:	e8 65 fb ff ff       	call   8011ba <write>
		if (result > 0)
  801655:	83 c4 10             	add    $0x10,%esp
  801658:	85 c0                	test   %eax,%eax
  80165a:	7e 03                	jle    80165f <writebuf+0x27>
			b->result += result;
  80165c:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  80165f:	3b 43 04             	cmp    0x4(%ebx),%eax
  801662:	74 0d                	je     801671 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  801664:	85 c0                	test   %eax,%eax
  801666:	ba 00 00 00 00       	mov    $0x0,%edx
  80166b:	0f 4f c2             	cmovg  %edx,%eax
  80166e:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801671:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801674:	c9                   	leave  
  801675:	f3 c3                	repz ret 

00801677 <putch>:

static void
putch(int ch, void *thunk)
{
  801677:	55                   	push   %ebp
  801678:	89 e5                	mov    %esp,%ebp
  80167a:	53                   	push   %ebx
  80167b:	83 ec 04             	sub    $0x4,%esp
  80167e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801681:	8b 53 04             	mov    0x4(%ebx),%edx
  801684:	8d 42 01             	lea    0x1(%edx),%eax
  801687:	89 43 04             	mov    %eax,0x4(%ebx)
  80168a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80168d:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  801691:	3d 00 01 00 00       	cmp    $0x100,%eax
  801696:	75 0e                	jne    8016a6 <putch+0x2f>
		writebuf(b);
  801698:	89 d8                	mov    %ebx,%eax
  80169a:	e8 99 ff ff ff       	call   801638 <writebuf>
		b->idx = 0;
  80169f:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8016a6:	83 c4 04             	add    $0x4,%esp
  8016a9:	5b                   	pop    %ebx
  8016aa:	5d                   	pop    %ebp
  8016ab:	c3                   	ret    

008016ac <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8016ac:	55                   	push   %ebp
  8016ad:	89 e5                	mov    %esp,%ebp
  8016af:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  8016b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b8:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8016be:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8016c5:	00 00 00 
	b.result = 0;
  8016c8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8016cf:	00 00 00 
	b.error = 1;
  8016d2:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8016d9:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8016dc:	ff 75 10             	pushl  0x10(%ebp)
  8016df:	ff 75 0c             	pushl  0xc(%ebp)
  8016e2:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8016e8:	50                   	push   %eax
  8016e9:	68 77 16 80 00       	push   $0x801677
  8016ee:	e8 b0 ec ff ff       	call   8003a3 <vprintfmt>
	if (b.idx > 0)
  8016f3:	83 c4 10             	add    $0x10,%esp
  8016f6:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8016fd:	7e 0b                	jle    80170a <vfprintf+0x5e>
		writebuf(&b);
  8016ff:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801705:	e8 2e ff ff ff       	call   801638 <writebuf>

	return (b.result ? b.result : b.error);
  80170a:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801710:	85 c0                	test   %eax,%eax
  801712:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801719:	c9                   	leave  
  80171a:	c3                   	ret    

0080171b <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  80171b:	55                   	push   %ebp
  80171c:	89 e5                	mov    %esp,%ebp
  80171e:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801721:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801724:	50                   	push   %eax
  801725:	ff 75 0c             	pushl  0xc(%ebp)
  801728:	ff 75 08             	pushl  0x8(%ebp)
  80172b:	e8 7c ff ff ff       	call   8016ac <vfprintf>
	va_end(ap);

	return cnt;
}
  801730:	c9                   	leave  
  801731:	c3                   	ret    

00801732 <printf>:

int
printf(const char *fmt, ...)
{
  801732:	55                   	push   %ebp
  801733:	89 e5                	mov    %esp,%ebp
  801735:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801738:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  80173b:	50                   	push   %eax
  80173c:	ff 75 08             	pushl  0x8(%ebp)
  80173f:	6a 01                	push   $0x1
  801741:	e8 66 ff ff ff       	call   8016ac <vfprintf>
	va_end(ap);

	return cnt;
}
  801746:	c9                   	leave  
  801747:	c3                   	ret    

00801748 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801748:	55                   	push   %ebp
  801749:	89 e5                	mov    %esp,%ebp
  80174b:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  80174e:	68 df 28 80 00       	push   $0x8028df
  801753:	ff 75 0c             	pushl  0xc(%ebp)
  801756:	e8 96 f0 ff ff       	call   8007f1 <strcpy>
	return 0;
}
  80175b:	b8 00 00 00 00       	mov    $0x0,%eax
  801760:	c9                   	leave  
  801761:	c3                   	ret    

00801762 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801762:	55                   	push   %ebp
  801763:	89 e5                	mov    %esp,%ebp
  801765:	53                   	push   %ebx
  801766:	83 ec 10             	sub    $0x10,%esp
  801769:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80176c:	53                   	push   %ebx
  80176d:	e8 12 0a 00 00       	call   802184 <pageref>
  801772:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801775:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  80177a:	83 f8 01             	cmp    $0x1,%eax
  80177d:	75 10                	jne    80178f <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  80177f:	83 ec 0c             	sub    $0xc,%esp
  801782:	ff 73 0c             	pushl  0xc(%ebx)
  801785:	e8 c0 02 00 00       	call   801a4a <nsipc_close>
  80178a:	89 c2                	mov    %eax,%edx
  80178c:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  80178f:	89 d0                	mov    %edx,%eax
  801791:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801794:	c9                   	leave  
  801795:	c3                   	ret    

00801796 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801796:	55                   	push   %ebp
  801797:	89 e5                	mov    %esp,%ebp
  801799:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  80179c:	6a 00                	push   $0x0
  80179e:	ff 75 10             	pushl  0x10(%ebp)
  8017a1:	ff 75 0c             	pushl  0xc(%ebp)
  8017a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a7:	ff 70 0c             	pushl  0xc(%eax)
  8017aa:	e8 78 03 00 00       	call   801b27 <nsipc_send>
}
  8017af:	c9                   	leave  
  8017b0:	c3                   	ret    

008017b1 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8017b1:	55                   	push   %ebp
  8017b2:	89 e5                	mov    %esp,%ebp
  8017b4:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8017b7:	6a 00                	push   $0x0
  8017b9:	ff 75 10             	pushl  0x10(%ebp)
  8017bc:	ff 75 0c             	pushl  0xc(%ebp)
  8017bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c2:	ff 70 0c             	pushl  0xc(%eax)
  8017c5:	e8 f1 02 00 00       	call   801abb <nsipc_recv>
}
  8017ca:	c9                   	leave  
  8017cb:	c3                   	ret    

008017cc <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8017cc:	55                   	push   %ebp
  8017cd:	89 e5                	mov    %esp,%ebp
  8017cf:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8017d2:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8017d5:	52                   	push   %edx
  8017d6:	50                   	push   %eax
  8017d7:	e8 9e f6 ff ff       	call   800e7a <fd_lookup>
  8017dc:	83 c4 10             	add    $0x10,%esp
  8017df:	85 c0                	test   %eax,%eax
  8017e1:	78 17                	js     8017fa <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8017e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017e6:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  8017ec:	39 08                	cmp    %ecx,(%eax)
  8017ee:	75 05                	jne    8017f5 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8017f0:	8b 40 0c             	mov    0xc(%eax),%eax
  8017f3:	eb 05                	jmp    8017fa <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  8017f5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  8017fa:	c9                   	leave  
  8017fb:	c3                   	ret    

008017fc <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  8017fc:	55                   	push   %ebp
  8017fd:	89 e5                	mov    %esp,%ebp
  8017ff:	56                   	push   %esi
  801800:	53                   	push   %ebx
  801801:	83 ec 1c             	sub    $0x1c,%esp
  801804:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801806:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801809:	50                   	push   %eax
  80180a:	e8 1c f6 ff ff       	call   800e2b <fd_alloc>
  80180f:	89 c3                	mov    %eax,%ebx
  801811:	83 c4 10             	add    $0x10,%esp
  801814:	85 c0                	test   %eax,%eax
  801816:	78 1b                	js     801833 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801818:	83 ec 04             	sub    $0x4,%esp
  80181b:	68 07 04 00 00       	push   $0x407
  801820:	ff 75 f4             	pushl  -0xc(%ebp)
  801823:	6a 00                	push   $0x0
  801825:	e8 ca f3 ff ff       	call   800bf4 <sys_page_alloc>
  80182a:	89 c3                	mov    %eax,%ebx
  80182c:	83 c4 10             	add    $0x10,%esp
  80182f:	85 c0                	test   %eax,%eax
  801831:	79 10                	jns    801843 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801833:	83 ec 0c             	sub    $0xc,%esp
  801836:	56                   	push   %esi
  801837:	e8 0e 02 00 00       	call   801a4a <nsipc_close>
		return r;
  80183c:	83 c4 10             	add    $0x10,%esp
  80183f:	89 d8                	mov    %ebx,%eax
  801841:	eb 24                	jmp    801867 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801843:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801849:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80184c:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  80184e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801851:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801858:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  80185b:	83 ec 0c             	sub    $0xc,%esp
  80185e:	50                   	push   %eax
  80185f:	e8 a0 f5 ff ff       	call   800e04 <fd2num>
  801864:	83 c4 10             	add    $0x10,%esp
}
  801867:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80186a:	5b                   	pop    %ebx
  80186b:	5e                   	pop    %esi
  80186c:	5d                   	pop    %ebp
  80186d:	c3                   	ret    

0080186e <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80186e:	55                   	push   %ebp
  80186f:	89 e5                	mov    %esp,%ebp
  801871:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801874:	8b 45 08             	mov    0x8(%ebp),%eax
  801877:	e8 50 ff ff ff       	call   8017cc <fd2sockid>
		return r;
  80187c:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  80187e:	85 c0                	test   %eax,%eax
  801880:	78 1f                	js     8018a1 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801882:	83 ec 04             	sub    $0x4,%esp
  801885:	ff 75 10             	pushl  0x10(%ebp)
  801888:	ff 75 0c             	pushl  0xc(%ebp)
  80188b:	50                   	push   %eax
  80188c:	e8 12 01 00 00       	call   8019a3 <nsipc_accept>
  801891:	83 c4 10             	add    $0x10,%esp
		return r;
  801894:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801896:	85 c0                	test   %eax,%eax
  801898:	78 07                	js     8018a1 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  80189a:	e8 5d ff ff ff       	call   8017fc <alloc_sockfd>
  80189f:	89 c1                	mov    %eax,%ecx
}
  8018a1:	89 c8                	mov    %ecx,%eax
  8018a3:	c9                   	leave  
  8018a4:	c3                   	ret    

008018a5 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8018a5:	55                   	push   %ebp
  8018a6:	89 e5                	mov    %esp,%ebp
  8018a8:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8018ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ae:	e8 19 ff ff ff       	call   8017cc <fd2sockid>
  8018b3:	85 c0                	test   %eax,%eax
  8018b5:	78 12                	js     8018c9 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  8018b7:	83 ec 04             	sub    $0x4,%esp
  8018ba:	ff 75 10             	pushl  0x10(%ebp)
  8018bd:	ff 75 0c             	pushl  0xc(%ebp)
  8018c0:	50                   	push   %eax
  8018c1:	e8 2d 01 00 00       	call   8019f3 <nsipc_bind>
  8018c6:	83 c4 10             	add    $0x10,%esp
}
  8018c9:	c9                   	leave  
  8018ca:	c3                   	ret    

008018cb <shutdown>:

int
shutdown(int s, int how)
{
  8018cb:	55                   	push   %ebp
  8018cc:	89 e5                	mov    %esp,%ebp
  8018ce:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8018d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d4:	e8 f3 fe ff ff       	call   8017cc <fd2sockid>
  8018d9:	85 c0                	test   %eax,%eax
  8018db:	78 0f                	js     8018ec <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8018dd:	83 ec 08             	sub    $0x8,%esp
  8018e0:	ff 75 0c             	pushl  0xc(%ebp)
  8018e3:	50                   	push   %eax
  8018e4:	e8 3f 01 00 00       	call   801a28 <nsipc_shutdown>
  8018e9:	83 c4 10             	add    $0x10,%esp
}
  8018ec:	c9                   	leave  
  8018ed:	c3                   	ret    

008018ee <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8018ee:	55                   	push   %ebp
  8018ef:	89 e5                	mov    %esp,%ebp
  8018f1:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8018f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f7:	e8 d0 fe ff ff       	call   8017cc <fd2sockid>
  8018fc:	85 c0                	test   %eax,%eax
  8018fe:	78 12                	js     801912 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801900:	83 ec 04             	sub    $0x4,%esp
  801903:	ff 75 10             	pushl  0x10(%ebp)
  801906:	ff 75 0c             	pushl  0xc(%ebp)
  801909:	50                   	push   %eax
  80190a:	e8 55 01 00 00       	call   801a64 <nsipc_connect>
  80190f:	83 c4 10             	add    $0x10,%esp
}
  801912:	c9                   	leave  
  801913:	c3                   	ret    

00801914 <listen>:

int
listen(int s, int backlog)
{
  801914:	55                   	push   %ebp
  801915:	89 e5                	mov    %esp,%ebp
  801917:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80191a:	8b 45 08             	mov    0x8(%ebp),%eax
  80191d:	e8 aa fe ff ff       	call   8017cc <fd2sockid>
  801922:	85 c0                	test   %eax,%eax
  801924:	78 0f                	js     801935 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801926:	83 ec 08             	sub    $0x8,%esp
  801929:	ff 75 0c             	pushl  0xc(%ebp)
  80192c:	50                   	push   %eax
  80192d:	e8 67 01 00 00       	call   801a99 <nsipc_listen>
  801932:	83 c4 10             	add    $0x10,%esp
}
  801935:	c9                   	leave  
  801936:	c3                   	ret    

00801937 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801937:	55                   	push   %ebp
  801938:	89 e5                	mov    %esp,%ebp
  80193a:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  80193d:	ff 75 10             	pushl  0x10(%ebp)
  801940:	ff 75 0c             	pushl  0xc(%ebp)
  801943:	ff 75 08             	pushl  0x8(%ebp)
  801946:	e8 3a 02 00 00       	call   801b85 <nsipc_socket>
  80194b:	83 c4 10             	add    $0x10,%esp
  80194e:	85 c0                	test   %eax,%eax
  801950:	78 05                	js     801957 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801952:	e8 a5 fe ff ff       	call   8017fc <alloc_sockfd>
}
  801957:	c9                   	leave  
  801958:	c3                   	ret    

00801959 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801959:	55                   	push   %ebp
  80195a:	89 e5                	mov    %esp,%ebp
  80195c:	53                   	push   %ebx
  80195d:	83 ec 04             	sub    $0x4,%esp
  801960:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801962:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801969:	75 12                	jne    80197d <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  80196b:	83 ec 0c             	sub    $0xc,%esp
  80196e:	6a 02                	push   $0x2
  801970:	e8 d6 07 00 00       	call   80214b <ipc_find_env>
  801975:	a3 04 40 80 00       	mov    %eax,0x804004
  80197a:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  80197d:	6a 07                	push   $0x7
  80197f:	68 00 80 80 00       	push   $0x808000
  801984:	53                   	push   %ebx
  801985:	ff 35 04 40 80 00    	pushl  0x804004
  80198b:	e8 67 07 00 00       	call   8020f7 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801990:	83 c4 0c             	add    $0xc,%esp
  801993:	6a 00                	push   $0x0
  801995:	6a 00                	push   $0x0
  801997:	6a 00                	push   $0x0
  801999:	e8 f0 06 00 00       	call   80208e <ipc_recv>
}
  80199e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019a1:	c9                   	leave  
  8019a2:	c3                   	ret    

008019a3 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8019a3:	55                   	push   %ebp
  8019a4:	89 e5                	mov    %esp,%ebp
  8019a6:	56                   	push   %esi
  8019a7:	53                   	push   %ebx
  8019a8:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8019ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ae:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8019b3:	8b 06                	mov    (%esi),%eax
  8019b5:	a3 04 80 80 00       	mov    %eax,0x808004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8019ba:	b8 01 00 00 00       	mov    $0x1,%eax
  8019bf:	e8 95 ff ff ff       	call   801959 <nsipc>
  8019c4:	89 c3                	mov    %eax,%ebx
  8019c6:	85 c0                	test   %eax,%eax
  8019c8:	78 20                	js     8019ea <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8019ca:	83 ec 04             	sub    $0x4,%esp
  8019cd:	ff 35 10 80 80 00    	pushl  0x808010
  8019d3:	68 00 80 80 00       	push   $0x808000
  8019d8:	ff 75 0c             	pushl  0xc(%ebp)
  8019db:	e8 a3 ef ff ff       	call   800983 <memmove>
		*addrlen = ret->ret_addrlen;
  8019e0:	a1 10 80 80 00       	mov    0x808010,%eax
  8019e5:	89 06                	mov    %eax,(%esi)
  8019e7:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  8019ea:	89 d8                	mov    %ebx,%eax
  8019ec:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019ef:	5b                   	pop    %ebx
  8019f0:	5e                   	pop    %esi
  8019f1:	5d                   	pop    %ebp
  8019f2:	c3                   	ret    

008019f3 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8019f3:	55                   	push   %ebp
  8019f4:	89 e5                	mov    %esp,%ebp
  8019f6:	53                   	push   %ebx
  8019f7:	83 ec 08             	sub    $0x8,%esp
  8019fa:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8019fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801a00:	a3 00 80 80 00       	mov    %eax,0x808000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801a05:	53                   	push   %ebx
  801a06:	ff 75 0c             	pushl  0xc(%ebp)
  801a09:	68 04 80 80 00       	push   $0x808004
  801a0e:	e8 70 ef ff ff       	call   800983 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801a13:	89 1d 14 80 80 00    	mov    %ebx,0x808014
	return nsipc(NSREQ_BIND);
  801a19:	b8 02 00 00 00       	mov    $0x2,%eax
  801a1e:	e8 36 ff ff ff       	call   801959 <nsipc>
}
  801a23:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a26:	c9                   	leave  
  801a27:	c3                   	ret    

00801a28 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801a28:	55                   	push   %ebp
  801a29:	89 e5                	mov    %esp,%ebp
  801a2b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801a2e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a31:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.shutdown.req_how = how;
  801a36:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a39:	a3 04 80 80 00       	mov    %eax,0x808004
	return nsipc(NSREQ_SHUTDOWN);
  801a3e:	b8 03 00 00 00       	mov    $0x3,%eax
  801a43:	e8 11 ff ff ff       	call   801959 <nsipc>
}
  801a48:	c9                   	leave  
  801a49:	c3                   	ret    

00801a4a <nsipc_close>:

int
nsipc_close(int s)
{
  801a4a:	55                   	push   %ebp
  801a4b:	89 e5                	mov    %esp,%ebp
  801a4d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801a50:	8b 45 08             	mov    0x8(%ebp),%eax
  801a53:	a3 00 80 80 00       	mov    %eax,0x808000
	return nsipc(NSREQ_CLOSE);
  801a58:	b8 04 00 00 00       	mov    $0x4,%eax
  801a5d:	e8 f7 fe ff ff       	call   801959 <nsipc>
}
  801a62:	c9                   	leave  
  801a63:	c3                   	ret    

00801a64 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801a64:	55                   	push   %ebp
  801a65:	89 e5                	mov    %esp,%ebp
  801a67:	53                   	push   %ebx
  801a68:	83 ec 08             	sub    $0x8,%esp
  801a6b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801a6e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a71:	a3 00 80 80 00       	mov    %eax,0x808000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801a76:	53                   	push   %ebx
  801a77:	ff 75 0c             	pushl  0xc(%ebp)
  801a7a:	68 04 80 80 00       	push   $0x808004
  801a7f:	e8 ff ee ff ff       	call   800983 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801a84:	89 1d 14 80 80 00    	mov    %ebx,0x808014
	return nsipc(NSREQ_CONNECT);
  801a8a:	b8 05 00 00 00       	mov    $0x5,%eax
  801a8f:	e8 c5 fe ff ff       	call   801959 <nsipc>
}
  801a94:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a97:	c9                   	leave  
  801a98:	c3                   	ret    

00801a99 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801a99:	55                   	push   %ebp
  801a9a:	89 e5                	mov    %esp,%ebp
  801a9c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801a9f:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa2:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.listen.req_backlog = backlog;
  801aa7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aaa:	a3 04 80 80 00       	mov    %eax,0x808004
	return nsipc(NSREQ_LISTEN);
  801aaf:	b8 06 00 00 00       	mov    $0x6,%eax
  801ab4:	e8 a0 fe ff ff       	call   801959 <nsipc>
}
  801ab9:	c9                   	leave  
  801aba:	c3                   	ret    

00801abb <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801abb:	55                   	push   %ebp
  801abc:	89 e5                	mov    %esp,%ebp
  801abe:	56                   	push   %esi
  801abf:	53                   	push   %ebx
  801ac0:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801ac3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac6:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.recv.req_len = len;
  801acb:	89 35 04 80 80 00    	mov    %esi,0x808004
	nsipcbuf.recv.req_flags = flags;
  801ad1:	8b 45 14             	mov    0x14(%ebp),%eax
  801ad4:	a3 08 80 80 00       	mov    %eax,0x808008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801ad9:	b8 07 00 00 00       	mov    $0x7,%eax
  801ade:	e8 76 fe ff ff       	call   801959 <nsipc>
  801ae3:	89 c3                	mov    %eax,%ebx
  801ae5:	85 c0                	test   %eax,%eax
  801ae7:	78 35                	js     801b1e <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801ae9:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801aee:	7f 04                	jg     801af4 <nsipc_recv+0x39>
  801af0:	39 c6                	cmp    %eax,%esi
  801af2:	7d 16                	jge    801b0a <nsipc_recv+0x4f>
  801af4:	68 eb 28 80 00       	push   $0x8028eb
  801af9:	68 ac 28 80 00       	push   $0x8028ac
  801afe:	6a 62                	push   $0x62
  801b00:	68 00 29 80 00       	push   $0x802900
  801b05:	e8 89 e6 ff ff       	call   800193 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801b0a:	83 ec 04             	sub    $0x4,%esp
  801b0d:	50                   	push   %eax
  801b0e:	68 00 80 80 00       	push   $0x808000
  801b13:	ff 75 0c             	pushl  0xc(%ebp)
  801b16:	e8 68 ee ff ff       	call   800983 <memmove>
  801b1b:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801b1e:	89 d8                	mov    %ebx,%eax
  801b20:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b23:	5b                   	pop    %ebx
  801b24:	5e                   	pop    %esi
  801b25:	5d                   	pop    %ebp
  801b26:	c3                   	ret    

00801b27 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801b27:	55                   	push   %ebp
  801b28:	89 e5                	mov    %esp,%ebp
  801b2a:	53                   	push   %ebx
  801b2b:	83 ec 04             	sub    $0x4,%esp
  801b2e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801b31:	8b 45 08             	mov    0x8(%ebp),%eax
  801b34:	a3 00 80 80 00       	mov    %eax,0x808000
	assert(size < 1600);
  801b39:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801b3f:	7e 16                	jle    801b57 <nsipc_send+0x30>
  801b41:	68 0c 29 80 00       	push   $0x80290c
  801b46:	68 ac 28 80 00       	push   $0x8028ac
  801b4b:	6a 6d                	push   $0x6d
  801b4d:	68 00 29 80 00       	push   $0x802900
  801b52:	e8 3c e6 ff ff       	call   800193 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801b57:	83 ec 04             	sub    $0x4,%esp
  801b5a:	53                   	push   %ebx
  801b5b:	ff 75 0c             	pushl  0xc(%ebp)
  801b5e:	68 0c 80 80 00       	push   $0x80800c
  801b63:	e8 1b ee ff ff       	call   800983 <memmove>
	nsipcbuf.send.req_size = size;
  801b68:	89 1d 04 80 80 00    	mov    %ebx,0x808004
	nsipcbuf.send.req_flags = flags;
  801b6e:	8b 45 14             	mov    0x14(%ebp),%eax
  801b71:	a3 08 80 80 00       	mov    %eax,0x808008
	return nsipc(NSREQ_SEND);
  801b76:	b8 08 00 00 00       	mov    $0x8,%eax
  801b7b:	e8 d9 fd ff ff       	call   801959 <nsipc>
}
  801b80:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b83:	c9                   	leave  
  801b84:	c3                   	ret    

00801b85 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801b85:	55                   	push   %ebp
  801b86:	89 e5                	mov    %esp,%ebp
  801b88:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801b8b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b8e:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.socket.req_type = type;
  801b93:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b96:	a3 04 80 80 00       	mov    %eax,0x808004
	nsipcbuf.socket.req_protocol = protocol;
  801b9b:	8b 45 10             	mov    0x10(%ebp),%eax
  801b9e:	a3 08 80 80 00       	mov    %eax,0x808008
	return nsipc(NSREQ_SOCKET);
  801ba3:	b8 09 00 00 00       	mov    $0x9,%eax
  801ba8:	e8 ac fd ff ff       	call   801959 <nsipc>
}
  801bad:	c9                   	leave  
  801bae:	c3                   	ret    

00801baf <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801baf:	55                   	push   %ebp
  801bb0:	89 e5                	mov    %esp,%ebp
  801bb2:	56                   	push   %esi
  801bb3:	53                   	push   %ebx
  801bb4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801bb7:	83 ec 0c             	sub    $0xc,%esp
  801bba:	ff 75 08             	pushl  0x8(%ebp)
  801bbd:	e8 52 f2 ff ff       	call   800e14 <fd2data>
  801bc2:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801bc4:	83 c4 08             	add    $0x8,%esp
  801bc7:	68 18 29 80 00       	push   $0x802918
  801bcc:	53                   	push   %ebx
  801bcd:	e8 1f ec ff ff       	call   8007f1 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801bd2:	8b 46 04             	mov    0x4(%esi),%eax
  801bd5:	2b 06                	sub    (%esi),%eax
  801bd7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801bdd:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801be4:	00 00 00 
	stat->st_dev = &devpipe;
  801be7:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801bee:	30 80 00 
	return 0;
}
  801bf1:	b8 00 00 00 00       	mov    $0x0,%eax
  801bf6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bf9:	5b                   	pop    %ebx
  801bfa:	5e                   	pop    %esi
  801bfb:	5d                   	pop    %ebp
  801bfc:	c3                   	ret    

00801bfd <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801bfd:	55                   	push   %ebp
  801bfe:	89 e5                	mov    %esp,%ebp
  801c00:	53                   	push   %ebx
  801c01:	83 ec 0c             	sub    $0xc,%esp
  801c04:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c07:	53                   	push   %ebx
  801c08:	6a 00                	push   $0x0
  801c0a:	e8 6a f0 ff ff       	call   800c79 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c0f:	89 1c 24             	mov    %ebx,(%esp)
  801c12:	e8 fd f1 ff ff       	call   800e14 <fd2data>
  801c17:	83 c4 08             	add    $0x8,%esp
  801c1a:	50                   	push   %eax
  801c1b:	6a 00                	push   $0x0
  801c1d:	e8 57 f0 ff ff       	call   800c79 <sys_page_unmap>
}
  801c22:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c25:	c9                   	leave  
  801c26:	c3                   	ret    

00801c27 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801c27:	55                   	push   %ebp
  801c28:	89 e5                	mov    %esp,%ebp
  801c2a:	57                   	push   %edi
  801c2b:	56                   	push   %esi
  801c2c:	53                   	push   %ebx
  801c2d:	83 ec 1c             	sub    $0x1c,%esp
  801c30:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801c33:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801c35:	a1 20 60 80 00       	mov    0x806020,%eax
  801c3a:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801c3d:	83 ec 0c             	sub    $0xc,%esp
  801c40:	ff 75 e0             	pushl  -0x20(%ebp)
  801c43:	e8 3c 05 00 00       	call   802184 <pageref>
  801c48:	89 c3                	mov    %eax,%ebx
  801c4a:	89 3c 24             	mov    %edi,(%esp)
  801c4d:	e8 32 05 00 00       	call   802184 <pageref>
  801c52:	83 c4 10             	add    $0x10,%esp
  801c55:	39 c3                	cmp    %eax,%ebx
  801c57:	0f 94 c1             	sete   %cl
  801c5a:	0f b6 c9             	movzbl %cl,%ecx
  801c5d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801c60:	8b 15 20 60 80 00    	mov    0x806020,%edx
  801c66:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801c69:	39 ce                	cmp    %ecx,%esi
  801c6b:	74 1b                	je     801c88 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801c6d:	39 c3                	cmp    %eax,%ebx
  801c6f:	75 c4                	jne    801c35 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c71:	8b 42 58             	mov    0x58(%edx),%eax
  801c74:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c77:	50                   	push   %eax
  801c78:	56                   	push   %esi
  801c79:	68 1f 29 80 00       	push   $0x80291f
  801c7e:	e8 e9 e5 ff ff       	call   80026c <cprintf>
  801c83:	83 c4 10             	add    $0x10,%esp
  801c86:	eb ad                	jmp    801c35 <_pipeisclosed+0xe>
	}
}
  801c88:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c8b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c8e:	5b                   	pop    %ebx
  801c8f:	5e                   	pop    %esi
  801c90:	5f                   	pop    %edi
  801c91:	5d                   	pop    %ebp
  801c92:	c3                   	ret    

00801c93 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c93:	55                   	push   %ebp
  801c94:	89 e5                	mov    %esp,%ebp
  801c96:	57                   	push   %edi
  801c97:	56                   	push   %esi
  801c98:	53                   	push   %ebx
  801c99:	83 ec 28             	sub    $0x28,%esp
  801c9c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801c9f:	56                   	push   %esi
  801ca0:	e8 6f f1 ff ff       	call   800e14 <fd2data>
  801ca5:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ca7:	83 c4 10             	add    $0x10,%esp
  801caa:	bf 00 00 00 00       	mov    $0x0,%edi
  801caf:	eb 4b                	jmp    801cfc <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801cb1:	89 da                	mov    %ebx,%edx
  801cb3:	89 f0                	mov    %esi,%eax
  801cb5:	e8 6d ff ff ff       	call   801c27 <_pipeisclosed>
  801cba:	85 c0                	test   %eax,%eax
  801cbc:	75 48                	jne    801d06 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801cbe:	e8 12 ef ff ff       	call   800bd5 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801cc3:	8b 43 04             	mov    0x4(%ebx),%eax
  801cc6:	8b 0b                	mov    (%ebx),%ecx
  801cc8:	8d 51 20             	lea    0x20(%ecx),%edx
  801ccb:	39 d0                	cmp    %edx,%eax
  801ccd:	73 e2                	jae    801cb1 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ccf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cd2:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801cd6:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801cd9:	89 c2                	mov    %eax,%edx
  801cdb:	c1 fa 1f             	sar    $0x1f,%edx
  801cde:	89 d1                	mov    %edx,%ecx
  801ce0:	c1 e9 1b             	shr    $0x1b,%ecx
  801ce3:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801ce6:	83 e2 1f             	and    $0x1f,%edx
  801ce9:	29 ca                	sub    %ecx,%edx
  801ceb:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801cef:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801cf3:	83 c0 01             	add    $0x1,%eax
  801cf6:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cf9:	83 c7 01             	add    $0x1,%edi
  801cfc:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801cff:	75 c2                	jne    801cc3 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801d01:	8b 45 10             	mov    0x10(%ebp),%eax
  801d04:	eb 05                	jmp    801d0b <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d06:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801d0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d0e:	5b                   	pop    %ebx
  801d0f:	5e                   	pop    %esi
  801d10:	5f                   	pop    %edi
  801d11:	5d                   	pop    %ebp
  801d12:	c3                   	ret    

00801d13 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d13:	55                   	push   %ebp
  801d14:	89 e5                	mov    %esp,%ebp
  801d16:	57                   	push   %edi
  801d17:	56                   	push   %esi
  801d18:	53                   	push   %ebx
  801d19:	83 ec 18             	sub    $0x18,%esp
  801d1c:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801d1f:	57                   	push   %edi
  801d20:	e8 ef f0 ff ff       	call   800e14 <fd2data>
  801d25:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d27:	83 c4 10             	add    $0x10,%esp
  801d2a:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d2f:	eb 3d                	jmp    801d6e <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801d31:	85 db                	test   %ebx,%ebx
  801d33:	74 04                	je     801d39 <devpipe_read+0x26>
				return i;
  801d35:	89 d8                	mov    %ebx,%eax
  801d37:	eb 44                	jmp    801d7d <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801d39:	89 f2                	mov    %esi,%edx
  801d3b:	89 f8                	mov    %edi,%eax
  801d3d:	e8 e5 fe ff ff       	call   801c27 <_pipeisclosed>
  801d42:	85 c0                	test   %eax,%eax
  801d44:	75 32                	jne    801d78 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801d46:	e8 8a ee ff ff       	call   800bd5 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801d4b:	8b 06                	mov    (%esi),%eax
  801d4d:	3b 46 04             	cmp    0x4(%esi),%eax
  801d50:	74 df                	je     801d31 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d52:	99                   	cltd   
  801d53:	c1 ea 1b             	shr    $0x1b,%edx
  801d56:	01 d0                	add    %edx,%eax
  801d58:	83 e0 1f             	and    $0x1f,%eax
  801d5b:	29 d0                	sub    %edx,%eax
  801d5d:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801d62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d65:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801d68:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d6b:	83 c3 01             	add    $0x1,%ebx
  801d6e:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801d71:	75 d8                	jne    801d4b <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d73:	8b 45 10             	mov    0x10(%ebp),%eax
  801d76:	eb 05                	jmp    801d7d <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d78:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801d7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d80:	5b                   	pop    %ebx
  801d81:	5e                   	pop    %esi
  801d82:	5f                   	pop    %edi
  801d83:	5d                   	pop    %ebp
  801d84:	c3                   	ret    

00801d85 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d85:	55                   	push   %ebp
  801d86:	89 e5                	mov    %esp,%ebp
  801d88:	56                   	push   %esi
  801d89:	53                   	push   %ebx
  801d8a:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d8d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d90:	50                   	push   %eax
  801d91:	e8 95 f0 ff ff       	call   800e2b <fd_alloc>
  801d96:	83 c4 10             	add    $0x10,%esp
  801d99:	89 c2                	mov    %eax,%edx
  801d9b:	85 c0                	test   %eax,%eax
  801d9d:	0f 88 2c 01 00 00    	js     801ecf <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801da3:	83 ec 04             	sub    $0x4,%esp
  801da6:	68 07 04 00 00       	push   $0x407
  801dab:	ff 75 f4             	pushl  -0xc(%ebp)
  801dae:	6a 00                	push   $0x0
  801db0:	e8 3f ee ff ff       	call   800bf4 <sys_page_alloc>
  801db5:	83 c4 10             	add    $0x10,%esp
  801db8:	89 c2                	mov    %eax,%edx
  801dba:	85 c0                	test   %eax,%eax
  801dbc:	0f 88 0d 01 00 00    	js     801ecf <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801dc2:	83 ec 0c             	sub    $0xc,%esp
  801dc5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801dc8:	50                   	push   %eax
  801dc9:	e8 5d f0 ff ff       	call   800e2b <fd_alloc>
  801dce:	89 c3                	mov    %eax,%ebx
  801dd0:	83 c4 10             	add    $0x10,%esp
  801dd3:	85 c0                	test   %eax,%eax
  801dd5:	0f 88 e2 00 00 00    	js     801ebd <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ddb:	83 ec 04             	sub    $0x4,%esp
  801dde:	68 07 04 00 00       	push   $0x407
  801de3:	ff 75 f0             	pushl  -0x10(%ebp)
  801de6:	6a 00                	push   $0x0
  801de8:	e8 07 ee ff ff       	call   800bf4 <sys_page_alloc>
  801ded:	89 c3                	mov    %eax,%ebx
  801def:	83 c4 10             	add    $0x10,%esp
  801df2:	85 c0                	test   %eax,%eax
  801df4:	0f 88 c3 00 00 00    	js     801ebd <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801dfa:	83 ec 0c             	sub    $0xc,%esp
  801dfd:	ff 75 f4             	pushl  -0xc(%ebp)
  801e00:	e8 0f f0 ff ff       	call   800e14 <fd2data>
  801e05:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e07:	83 c4 0c             	add    $0xc,%esp
  801e0a:	68 07 04 00 00       	push   $0x407
  801e0f:	50                   	push   %eax
  801e10:	6a 00                	push   $0x0
  801e12:	e8 dd ed ff ff       	call   800bf4 <sys_page_alloc>
  801e17:	89 c3                	mov    %eax,%ebx
  801e19:	83 c4 10             	add    $0x10,%esp
  801e1c:	85 c0                	test   %eax,%eax
  801e1e:	0f 88 89 00 00 00    	js     801ead <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e24:	83 ec 0c             	sub    $0xc,%esp
  801e27:	ff 75 f0             	pushl  -0x10(%ebp)
  801e2a:	e8 e5 ef ff ff       	call   800e14 <fd2data>
  801e2f:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801e36:	50                   	push   %eax
  801e37:	6a 00                	push   $0x0
  801e39:	56                   	push   %esi
  801e3a:	6a 00                	push   $0x0
  801e3c:	e8 f6 ed ff ff       	call   800c37 <sys_page_map>
  801e41:	89 c3                	mov    %eax,%ebx
  801e43:	83 c4 20             	add    $0x20,%esp
  801e46:	85 c0                	test   %eax,%eax
  801e48:	78 55                	js     801e9f <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801e4a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e50:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e53:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e55:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e58:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801e5f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e65:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e68:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e6d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801e74:	83 ec 0c             	sub    $0xc,%esp
  801e77:	ff 75 f4             	pushl  -0xc(%ebp)
  801e7a:	e8 85 ef ff ff       	call   800e04 <fd2num>
  801e7f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e82:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e84:	83 c4 04             	add    $0x4,%esp
  801e87:	ff 75 f0             	pushl  -0x10(%ebp)
  801e8a:	e8 75 ef ff ff       	call   800e04 <fd2num>
  801e8f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e92:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801e95:	83 c4 10             	add    $0x10,%esp
  801e98:	ba 00 00 00 00       	mov    $0x0,%edx
  801e9d:	eb 30                	jmp    801ecf <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801e9f:	83 ec 08             	sub    $0x8,%esp
  801ea2:	56                   	push   %esi
  801ea3:	6a 00                	push   $0x0
  801ea5:	e8 cf ed ff ff       	call   800c79 <sys_page_unmap>
  801eaa:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801ead:	83 ec 08             	sub    $0x8,%esp
  801eb0:	ff 75 f0             	pushl  -0x10(%ebp)
  801eb3:	6a 00                	push   $0x0
  801eb5:	e8 bf ed ff ff       	call   800c79 <sys_page_unmap>
  801eba:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801ebd:	83 ec 08             	sub    $0x8,%esp
  801ec0:	ff 75 f4             	pushl  -0xc(%ebp)
  801ec3:	6a 00                	push   $0x0
  801ec5:	e8 af ed ff ff       	call   800c79 <sys_page_unmap>
  801eca:	83 c4 10             	add    $0x10,%esp
  801ecd:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801ecf:	89 d0                	mov    %edx,%eax
  801ed1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ed4:	5b                   	pop    %ebx
  801ed5:	5e                   	pop    %esi
  801ed6:	5d                   	pop    %ebp
  801ed7:	c3                   	ret    

00801ed8 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801ed8:	55                   	push   %ebp
  801ed9:	89 e5                	mov    %esp,%ebp
  801edb:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ede:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ee1:	50                   	push   %eax
  801ee2:	ff 75 08             	pushl  0x8(%ebp)
  801ee5:	e8 90 ef ff ff       	call   800e7a <fd_lookup>
  801eea:	83 c4 10             	add    $0x10,%esp
  801eed:	85 c0                	test   %eax,%eax
  801eef:	78 18                	js     801f09 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801ef1:	83 ec 0c             	sub    $0xc,%esp
  801ef4:	ff 75 f4             	pushl  -0xc(%ebp)
  801ef7:	e8 18 ef ff ff       	call   800e14 <fd2data>
	return _pipeisclosed(fd, p);
  801efc:	89 c2                	mov    %eax,%edx
  801efe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f01:	e8 21 fd ff ff       	call   801c27 <_pipeisclosed>
  801f06:	83 c4 10             	add    $0x10,%esp
}
  801f09:	c9                   	leave  
  801f0a:	c3                   	ret    

00801f0b <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f0b:	55                   	push   %ebp
  801f0c:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801f0e:	b8 00 00 00 00       	mov    $0x0,%eax
  801f13:	5d                   	pop    %ebp
  801f14:	c3                   	ret    

00801f15 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f15:	55                   	push   %ebp
  801f16:	89 e5                	mov    %esp,%ebp
  801f18:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801f1b:	68 37 29 80 00       	push   $0x802937
  801f20:	ff 75 0c             	pushl  0xc(%ebp)
  801f23:	e8 c9 e8 ff ff       	call   8007f1 <strcpy>
	return 0;
}
  801f28:	b8 00 00 00 00       	mov    $0x0,%eax
  801f2d:	c9                   	leave  
  801f2e:	c3                   	ret    

00801f2f <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f2f:	55                   	push   %ebp
  801f30:	89 e5                	mov    %esp,%ebp
  801f32:	57                   	push   %edi
  801f33:	56                   	push   %esi
  801f34:	53                   	push   %ebx
  801f35:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f3b:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f40:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f46:	eb 2d                	jmp    801f75 <devcons_write+0x46>
		m = n - tot;
  801f48:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f4b:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801f4d:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801f50:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801f55:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f58:	83 ec 04             	sub    $0x4,%esp
  801f5b:	53                   	push   %ebx
  801f5c:	03 45 0c             	add    0xc(%ebp),%eax
  801f5f:	50                   	push   %eax
  801f60:	57                   	push   %edi
  801f61:	e8 1d ea ff ff       	call   800983 <memmove>
		sys_cputs(buf, m);
  801f66:	83 c4 08             	add    $0x8,%esp
  801f69:	53                   	push   %ebx
  801f6a:	57                   	push   %edi
  801f6b:	e8 c8 eb ff ff       	call   800b38 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f70:	01 de                	add    %ebx,%esi
  801f72:	83 c4 10             	add    $0x10,%esp
  801f75:	89 f0                	mov    %esi,%eax
  801f77:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f7a:	72 cc                	jb     801f48 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f7f:	5b                   	pop    %ebx
  801f80:	5e                   	pop    %esi
  801f81:	5f                   	pop    %edi
  801f82:	5d                   	pop    %ebp
  801f83:	c3                   	ret    

00801f84 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f84:	55                   	push   %ebp
  801f85:	89 e5                	mov    %esp,%ebp
  801f87:	83 ec 08             	sub    $0x8,%esp
  801f8a:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801f8f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f93:	74 2a                	je     801fbf <devcons_read+0x3b>
  801f95:	eb 05                	jmp    801f9c <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f97:	e8 39 ec ff ff       	call   800bd5 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f9c:	e8 b5 eb ff ff       	call   800b56 <sys_cgetc>
  801fa1:	85 c0                	test   %eax,%eax
  801fa3:	74 f2                	je     801f97 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801fa5:	85 c0                	test   %eax,%eax
  801fa7:	78 16                	js     801fbf <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801fa9:	83 f8 04             	cmp    $0x4,%eax
  801fac:	74 0c                	je     801fba <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801fae:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fb1:	88 02                	mov    %al,(%edx)
	return 1;
  801fb3:	b8 01 00 00 00       	mov    $0x1,%eax
  801fb8:	eb 05                	jmp    801fbf <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801fba:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801fbf:	c9                   	leave  
  801fc0:	c3                   	ret    

00801fc1 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801fc1:	55                   	push   %ebp
  801fc2:	89 e5                	mov    %esp,%ebp
  801fc4:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801fc7:	8b 45 08             	mov    0x8(%ebp),%eax
  801fca:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801fcd:	6a 01                	push   $0x1
  801fcf:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fd2:	50                   	push   %eax
  801fd3:	e8 60 eb ff ff       	call   800b38 <sys_cputs>
}
  801fd8:	83 c4 10             	add    $0x10,%esp
  801fdb:	c9                   	leave  
  801fdc:	c3                   	ret    

00801fdd <getchar>:

int
getchar(void)
{
  801fdd:	55                   	push   %ebp
  801fde:	89 e5                	mov    %esp,%ebp
  801fe0:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801fe3:	6a 01                	push   $0x1
  801fe5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fe8:	50                   	push   %eax
  801fe9:	6a 00                	push   $0x0
  801feb:	e8 f0 f0 ff ff       	call   8010e0 <read>
	if (r < 0)
  801ff0:	83 c4 10             	add    $0x10,%esp
  801ff3:	85 c0                	test   %eax,%eax
  801ff5:	78 0f                	js     802006 <getchar+0x29>
		return r;
	if (r < 1)
  801ff7:	85 c0                	test   %eax,%eax
  801ff9:	7e 06                	jle    802001 <getchar+0x24>
		return -E_EOF;
	return c;
  801ffb:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801fff:	eb 05                	jmp    802006 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802001:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802006:	c9                   	leave  
  802007:	c3                   	ret    

00802008 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802008:	55                   	push   %ebp
  802009:	89 e5                	mov    %esp,%ebp
  80200b:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80200e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802011:	50                   	push   %eax
  802012:	ff 75 08             	pushl  0x8(%ebp)
  802015:	e8 60 ee ff ff       	call   800e7a <fd_lookup>
  80201a:	83 c4 10             	add    $0x10,%esp
  80201d:	85 c0                	test   %eax,%eax
  80201f:	78 11                	js     802032 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802021:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802024:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80202a:	39 10                	cmp    %edx,(%eax)
  80202c:	0f 94 c0             	sete   %al
  80202f:	0f b6 c0             	movzbl %al,%eax
}
  802032:	c9                   	leave  
  802033:	c3                   	ret    

00802034 <opencons>:

int
opencons(void)
{
  802034:	55                   	push   %ebp
  802035:	89 e5                	mov    %esp,%ebp
  802037:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80203a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80203d:	50                   	push   %eax
  80203e:	e8 e8 ed ff ff       	call   800e2b <fd_alloc>
  802043:	83 c4 10             	add    $0x10,%esp
		return r;
  802046:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802048:	85 c0                	test   %eax,%eax
  80204a:	78 3e                	js     80208a <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80204c:	83 ec 04             	sub    $0x4,%esp
  80204f:	68 07 04 00 00       	push   $0x407
  802054:	ff 75 f4             	pushl  -0xc(%ebp)
  802057:	6a 00                	push   $0x0
  802059:	e8 96 eb ff ff       	call   800bf4 <sys_page_alloc>
  80205e:	83 c4 10             	add    $0x10,%esp
		return r;
  802061:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802063:	85 c0                	test   %eax,%eax
  802065:	78 23                	js     80208a <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802067:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80206d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802070:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802072:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802075:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80207c:	83 ec 0c             	sub    $0xc,%esp
  80207f:	50                   	push   %eax
  802080:	e8 7f ed ff ff       	call   800e04 <fd2num>
  802085:	89 c2                	mov    %eax,%edx
  802087:	83 c4 10             	add    $0x10,%esp
}
  80208a:	89 d0                	mov    %edx,%eax
  80208c:	c9                   	leave  
  80208d:	c3                   	ret    

0080208e <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80208e:	55                   	push   %ebp
  80208f:	89 e5                	mov    %esp,%ebp
  802091:	56                   	push   %esi
  802092:	53                   	push   %ebx
  802093:	8b 75 08             	mov    0x8(%ebp),%esi
  802096:	8b 45 0c             	mov    0xc(%ebp),%eax
  802099:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  80209c:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  80209e:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  8020a3:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  8020a6:	83 ec 0c             	sub    $0xc,%esp
  8020a9:	50                   	push   %eax
  8020aa:	e8 f5 ec ff ff       	call   800da4 <sys_ipc_recv>

	if (r < 0) {
  8020af:	83 c4 10             	add    $0x10,%esp
  8020b2:	85 c0                	test   %eax,%eax
  8020b4:	79 16                	jns    8020cc <ipc_recv+0x3e>
		if (from_env_store)
  8020b6:	85 f6                	test   %esi,%esi
  8020b8:	74 06                	je     8020c0 <ipc_recv+0x32>
			*from_env_store = 0;
  8020ba:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  8020c0:	85 db                	test   %ebx,%ebx
  8020c2:	74 2c                	je     8020f0 <ipc_recv+0x62>
			*perm_store = 0;
  8020c4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8020ca:	eb 24                	jmp    8020f0 <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  8020cc:	85 f6                	test   %esi,%esi
  8020ce:	74 0a                	je     8020da <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  8020d0:	a1 20 60 80 00       	mov    0x806020,%eax
  8020d5:	8b 40 74             	mov    0x74(%eax),%eax
  8020d8:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  8020da:	85 db                	test   %ebx,%ebx
  8020dc:	74 0a                	je     8020e8 <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  8020de:	a1 20 60 80 00       	mov    0x806020,%eax
  8020e3:	8b 40 78             	mov    0x78(%eax),%eax
  8020e6:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  8020e8:	a1 20 60 80 00       	mov    0x806020,%eax
  8020ed:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  8020f0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020f3:	5b                   	pop    %ebx
  8020f4:	5e                   	pop    %esi
  8020f5:	5d                   	pop    %ebp
  8020f6:	c3                   	ret    

008020f7 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8020f7:	55                   	push   %ebp
  8020f8:	89 e5                	mov    %esp,%ebp
  8020fa:	57                   	push   %edi
  8020fb:	56                   	push   %esi
  8020fc:	53                   	push   %ebx
  8020fd:	83 ec 0c             	sub    $0xc,%esp
  802100:	8b 7d 08             	mov    0x8(%ebp),%edi
  802103:	8b 75 0c             	mov    0xc(%ebp),%esi
  802106:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  802109:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  80210b:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  802110:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  802113:	ff 75 14             	pushl  0x14(%ebp)
  802116:	53                   	push   %ebx
  802117:	56                   	push   %esi
  802118:	57                   	push   %edi
  802119:	e8 63 ec ff ff       	call   800d81 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  80211e:	83 c4 10             	add    $0x10,%esp
  802121:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802124:	75 07                	jne    80212d <ipc_send+0x36>
			sys_yield();
  802126:	e8 aa ea ff ff       	call   800bd5 <sys_yield>
  80212b:	eb e6                	jmp    802113 <ipc_send+0x1c>
		} else if (r < 0) {
  80212d:	85 c0                	test   %eax,%eax
  80212f:	79 12                	jns    802143 <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  802131:	50                   	push   %eax
  802132:	68 43 29 80 00       	push   $0x802943
  802137:	6a 51                	push   $0x51
  802139:	68 50 29 80 00       	push   $0x802950
  80213e:	e8 50 e0 ff ff       	call   800193 <_panic>
		}
	}
}
  802143:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802146:	5b                   	pop    %ebx
  802147:	5e                   	pop    %esi
  802148:	5f                   	pop    %edi
  802149:	5d                   	pop    %ebp
  80214a:	c3                   	ret    

0080214b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80214b:	55                   	push   %ebp
  80214c:	89 e5                	mov    %esp,%ebp
  80214e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802151:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802156:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802159:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80215f:	8b 52 50             	mov    0x50(%edx),%edx
  802162:	39 ca                	cmp    %ecx,%edx
  802164:	75 0d                	jne    802173 <ipc_find_env+0x28>
			return envs[i].env_id;
  802166:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802169:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80216e:	8b 40 48             	mov    0x48(%eax),%eax
  802171:	eb 0f                	jmp    802182 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802173:	83 c0 01             	add    $0x1,%eax
  802176:	3d 00 04 00 00       	cmp    $0x400,%eax
  80217b:	75 d9                	jne    802156 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80217d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802182:	5d                   	pop    %ebp
  802183:	c3                   	ret    

00802184 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802184:	55                   	push   %ebp
  802185:	89 e5                	mov    %esp,%ebp
  802187:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80218a:	89 d0                	mov    %edx,%eax
  80218c:	c1 e8 16             	shr    $0x16,%eax
  80218f:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802196:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80219b:	f6 c1 01             	test   $0x1,%cl
  80219e:	74 1d                	je     8021bd <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8021a0:	c1 ea 0c             	shr    $0xc,%edx
  8021a3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8021aa:	f6 c2 01             	test   $0x1,%dl
  8021ad:	74 0e                	je     8021bd <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8021af:	c1 ea 0c             	shr    $0xc,%edx
  8021b2:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8021b9:	ef 
  8021ba:	0f b7 c0             	movzwl %ax,%eax
}
  8021bd:	5d                   	pop    %ebp
  8021be:	c3                   	ret    
  8021bf:	90                   	nop

008021c0 <__udivdi3>:
  8021c0:	55                   	push   %ebp
  8021c1:	57                   	push   %edi
  8021c2:	56                   	push   %esi
  8021c3:	53                   	push   %ebx
  8021c4:	83 ec 1c             	sub    $0x1c,%esp
  8021c7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8021cb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8021cf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8021d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021d7:	85 f6                	test   %esi,%esi
  8021d9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021dd:	89 ca                	mov    %ecx,%edx
  8021df:	89 f8                	mov    %edi,%eax
  8021e1:	75 3d                	jne    802220 <__udivdi3+0x60>
  8021e3:	39 cf                	cmp    %ecx,%edi
  8021e5:	0f 87 c5 00 00 00    	ja     8022b0 <__udivdi3+0xf0>
  8021eb:	85 ff                	test   %edi,%edi
  8021ed:	89 fd                	mov    %edi,%ebp
  8021ef:	75 0b                	jne    8021fc <__udivdi3+0x3c>
  8021f1:	b8 01 00 00 00       	mov    $0x1,%eax
  8021f6:	31 d2                	xor    %edx,%edx
  8021f8:	f7 f7                	div    %edi
  8021fa:	89 c5                	mov    %eax,%ebp
  8021fc:	89 c8                	mov    %ecx,%eax
  8021fe:	31 d2                	xor    %edx,%edx
  802200:	f7 f5                	div    %ebp
  802202:	89 c1                	mov    %eax,%ecx
  802204:	89 d8                	mov    %ebx,%eax
  802206:	89 cf                	mov    %ecx,%edi
  802208:	f7 f5                	div    %ebp
  80220a:	89 c3                	mov    %eax,%ebx
  80220c:	89 d8                	mov    %ebx,%eax
  80220e:	89 fa                	mov    %edi,%edx
  802210:	83 c4 1c             	add    $0x1c,%esp
  802213:	5b                   	pop    %ebx
  802214:	5e                   	pop    %esi
  802215:	5f                   	pop    %edi
  802216:	5d                   	pop    %ebp
  802217:	c3                   	ret    
  802218:	90                   	nop
  802219:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802220:	39 ce                	cmp    %ecx,%esi
  802222:	77 74                	ja     802298 <__udivdi3+0xd8>
  802224:	0f bd fe             	bsr    %esi,%edi
  802227:	83 f7 1f             	xor    $0x1f,%edi
  80222a:	0f 84 98 00 00 00    	je     8022c8 <__udivdi3+0x108>
  802230:	bb 20 00 00 00       	mov    $0x20,%ebx
  802235:	89 f9                	mov    %edi,%ecx
  802237:	89 c5                	mov    %eax,%ebp
  802239:	29 fb                	sub    %edi,%ebx
  80223b:	d3 e6                	shl    %cl,%esi
  80223d:	89 d9                	mov    %ebx,%ecx
  80223f:	d3 ed                	shr    %cl,%ebp
  802241:	89 f9                	mov    %edi,%ecx
  802243:	d3 e0                	shl    %cl,%eax
  802245:	09 ee                	or     %ebp,%esi
  802247:	89 d9                	mov    %ebx,%ecx
  802249:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80224d:	89 d5                	mov    %edx,%ebp
  80224f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802253:	d3 ed                	shr    %cl,%ebp
  802255:	89 f9                	mov    %edi,%ecx
  802257:	d3 e2                	shl    %cl,%edx
  802259:	89 d9                	mov    %ebx,%ecx
  80225b:	d3 e8                	shr    %cl,%eax
  80225d:	09 c2                	or     %eax,%edx
  80225f:	89 d0                	mov    %edx,%eax
  802261:	89 ea                	mov    %ebp,%edx
  802263:	f7 f6                	div    %esi
  802265:	89 d5                	mov    %edx,%ebp
  802267:	89 c3                	mov    %eax,%ebx
  802269:	f7 64 24 0c          	mull   0xc(%esp)
  80226d:	39 d5                	cmp    %edx,%ebp
  80226f:	72 10                	jb     802281 <__udivdi3+0xc1>
  802271:	8b 74 24 08          	mov    0x8(%esp),%esi
  802275:	89 f9                	mov    %edi,%ecx
  802277:	d3 e6                	shl    %cl,%esi
  802279:	39 c6                	cmp    %eax,%esi
  80227b:	73 07                	jae    802284 <__udivdi3+0xc4>
  80227d:	39 d5                	cmp    %edx,%ebp
  80227f:	75 03                	jne    802284 <__udivdi3+0xc4>
  802281:	83 eb 01             	sub    $0x1,%ebx
  802284:	31 ff                	xor    %edi,%edi
  802286:	89 d8                	mov    %ebx,%eax
  802288:	89 fa                	mov    %edi,%edx
  80228a:	83 c4 1c             	add    $0x1c,%esp
  80228d:	5b                   	pop    %ebx
  80228e:	5e                   	pop    %esi
  80228f:	5f                   	pop    %edi
  802290:	5d                   	pop    %ebp
  802291:	c3                   	ret    
  802292:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802298:	31 ff                	xor    %edi,%edi
  80229a:	31 db                	xor    %ebx,%ebx
  80229c:	89 d8                	mov    %ebx,%eax
  80229e:	89 fa                	mov    %edi,%edx
  8022a0:	83 c4 1c             	add    $0x1c,%esp
  8022a3:	5b                   	pop    %ebx
  8022a4:	5e                   	pop    %esi
  8022a5:	5f                   	pop    %edi
  8022a6:	5d                   	pop    %ebp
  8022a7:	c3                   	ret    
  8022a8:	90                   	nop
  8022a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022b0:	89 d8                	mov    %ebx,%eax
  8022b2:	f7 f7                	div    %edi
  8022b4:	31 ff                	xor    %edi,%edi
  8022b6:	89 c3                	mov    %eax,%ebx
  8022b8:	89 d8                	mov    %ebx,%eax
  8022ba:	89 fa                	mov    %edi,%edx
  8022bc:	83 c4 1c             	add    $0x1c,%esp
  8022bf:	5b                   	pop    %ebx
  8022c0:	5e                   	pop    %esi
  8022c1:	5f                   	pop    %edi
  8022c2:	5d                   	pop    %ebp
  8022c3:	c3                   	ret    
  8022c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022c8:	39 ce                	cmp    %ecx,%esi
  8022ca:	72 0c                	jb     8022d8 <__udivdi3+0x118>
  8022cc:	31 db                	xor    %ebx,%ebx
  8022ce:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8022d2:	0f 87 34 ff ff ff    	ja     80220c <__udivdi3+0x4c>
  8022d8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8022dd:	e9 2a ff ff ff       	jmp    80220c <__udivdi3+0x4c>
  8022e2:	66 90                	xchg   %ax,%ax
  8022e4:	66 90                	xchg   %ax,%ax
  8022e6:	66 90                	xchg   %ax,%ax
  8022e8:	66 90                	xchg   %ax,%ax
  8022ea:	66 90                	xchg   %ax,%ax
  8022ec:	66 90                	xchg   %ax,%ax
  8022ee:	66 90                	xchg   %ax,%ax

008022f0 <__umoddi3>:
  8022f0:	55                   	push   %ebp
  8022f1:	57                   	push   %edi
  8022f2:	56                   	push   %esi
  8022f3:	53                   	push   %ebx
  8022f4:	83 ec 1c             	sub    $0x1c,%esp
  8022f7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8022fb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8022ff:	8b 74 24 34          	mov    0x34(%esp),%esi
  802303:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802307:	85 d2                	test   %edx,%edx
  802309:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80230d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802311:	89 f3                	mov    %esi,%ebx
  802313:	89 3c 24             	mov    %edi,(%esp)
  802316:	89 74 24 04          	mov    %esi,0x4(%esp)
  80231a:	75 1c                	jne    802338 <__umoddi3+0x48>
  80231c:	39 f7                	cmp    %esi,%edi
  80231e:	76 50                	jbe    802370 <__umoddi3+0x80>
  802320:	89 c8                	mov    %ecx,%eax
  802322:	89 f2                	mov    %esi,%edx
  802324:	f7 f7                	div    %edi
  802326:	89 d0                	mov    %edx,%eax
  802328:	31 d2                	xor    %edx,%edx
  80232a:	83 c4 1c             	add    $0x1c,%esp
  80232d:	5b                   	pop    %ebx
  80232e:	5e                   	pop    %esi
  80232f:	5f                   	pop    %edi
  802330:	5d                   	pop    %ebp
  802331:	c3                   	ret    
  802332:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802338:	39 f2                	cmp    %esi,%edx
  80233a:	89 d0                	mov    %edx,%eax
  80233c:	77 52                	ja     802390 <__umoddi3+0xa0>
  80233e:	0f bd ea             	bsr    %edx,%ebp
  802341:	83 f5 1f             	xor    $0x1f,%ebp
  802344:	75 5a                	jne    8023a0 <__umoddi3+0xb0>
  802346:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80234a:	0f 82 e0 00 00 00    	jb     802430 <__umoddi3+0x140>
  802350:	39 0c 24             	cmp    %ecx,(%esp)
  802353:	0f 86 d7 00 00 00    	jbe    802430 <__umoddi3+0x140>
  802359:	8b 44 24 08          	mov    0x8(%esp),%eax
  80235d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802361:	83 c4 1c             	add    $0x1c,%esp
  802364:	5b                   	pop    %ebx
  802365:	5e                   	pop    %esi
  802366:	5f                   	pop    %edi
  802367:	5d                   	pop    %ebp
  802368:	c3                   	ret    
  802369:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802370:	85 ff                	test   %edi,%edi
  802372:	89 fd                	mov    %edi,%ebp
  802374:	75 0b                	jne    802381 <__umoddi3+0x91>
  802376:	b8 01 00 00 00       	mov    $0x1,%eax
  80237b:	31 d2                	xor    %edx,%edx
  80237d:	f7 f7                	div    %edi
  80237f:	89 c5                	mov    %eax,%ebp
  802381:	89 f0                	mov    %esi,%eax
  802383:	31 d2                	xor    %edx,%edx
  802385:	f7 f5                	div    %ebp
  802387:	89 c8                	mov    %ecx,%eax
  802389:	f7 f5                	div    %ebp
  80238b:	89 d0                	mov    %edx,%eax
  80238d:	eb 99                	jmp    802328 <__umoddi3+0x38>
  80238f:	90                   	nop
  802390:	89 c8                	mov    %ecx,%eax
  802392:	89 f2                	mov    %esi,%edx
  802394:	83 c4 1c             	add    $0x1c,%esp
  802397:	5b                   	pop    %ebx
  802398:	5e                   	pop    %esi
  802399:	5f                   	pop    %edi
  80239a:	5d                   	pop    %ebp
  80239b:	c3                   	ret    
  80239c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023a0:	8b 34 24             	mov    (%esp),%esi
  8023a3:	bf 20 00 00 00       	mov    $0x20,%edi
  8023a8:	89 e9                	mov    %ebp,%ecx
  8023aa:	29 ef                	sub    %ebp,%edi
  8023ac:	d3 e0                	shl    %cl,%eax
  8023ae:	89 f9                	mov    %edi,%ecx
  8023b0:	89 f2                	mov    %esi,%edx
  8023b2:	d3 ea                	shr    %cl,%edx
  8023b4:	89 e9                	mov    %ebp,%ecx
  8023b6:	09 c2                	or     %eax,%edx
  8023b8:	89 d8                	mov    %ebx,%eax
  8023ba:	89 14 24             	mov    %edx,(%esp)
  8023bd:	89 f2                	mov    %esi,%edx
  8023bf:	d3 e2                	shl    %cl,%edx
  8023c1:	89 f9                	mov    %edi,%ecx
  8023c3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8023c7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8023cb:	d3 e8                	shr    %cl,%eax
  8023cd:	89 e9                	mov    %ebp,%ecx
  8023cf:	89 c6                	mov    %eax,%esi
  8023d1:	d3 e3                	shl    %cl,%ebx
  8023d3:	89 f9                	mov    %edi,%ecx
  8023d5:	89 d0                	mov    %edx,%eax
  8023d7:	d3 e8                	shr    %cl,%eax
  8023d9:	89 e9                	mov    %ebp,%ecx
  8023db:	09 d8                	or     %ebx,%eax
  8023dd:	89 d3                	mov    %edx,%ebx
  8023df:	89 f2                	mov    %esi,%edx
  8023e1:	f7 34 24             	divl   (%esp)
  8023e4:	89 d6                	mov    %edx,%esi
  8023e6:	d3 e3                	shl    %cl,%ebx
  8023e8:	f7 64 24 04          	mull   0x4(%esp)
  8023ec:	39 d6                	cmp    %edx,%esi
  8023ee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023f2:	89 d1                	mov    %edx,%ecx
  8023f4:	89 c3                	mov    %eax,%ebx
  8023f6:	72 08                	jb     802400 <__umoddi3+0x110>
  8023f8:	75 11                	jne    80240b <__umoddi3+0x11b>
  8023fa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8023fe:	73 0b                	jae    80240b <__umoddi3+0x11b>
  802400:	2b 44 24 04          	sub    0x4(%esp),%eax
  802404:	1b 14 24             	sbb    (%esp),%edx
  802407:	89 d1                	mov    %edx,%ecx
  802409:	89 c3                	mov    %eax,%ebx
  80240b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80240f:	29 da                	sub    %ebx,%edx
  802411:	19 ce                	sbb    %ecx,%esi
  802413:	89 f9                	mov    %edi,%ecx
  802415:	89 f0                	mov    %esi,%eax
  802417:	d3 e0                	shl    %cl,%eax
  802419:	89 e9                	mov    %ebp,%ecx
  80241b:	d3 ea                	shr    %cl,%edx
  80241d:	89 e9                	mov    %ebp,%ecx
  80241f:	d3 ee                	shr    %cl,%esi
  802421:	09 d0                	or     %edx,%eax
  802423:	89 f2                	mov    %esi,%edx
  802425:	83 c4 1c             	add    $0x1c,%esp
  802428:	5b                   	pop    %ebx
  802429:	5e                   	pop    %esi
  80242a:	5f                   	pop    %edi
  80242b:	5d                   	pop    %ebp
  80242c:	c3                   	ret    
  80242d:	8d 76 00             	lea    0x0(%esi),%esi
  802430:	29 f9                	sub    %edi,%ecx
  802432:	19 d6                	sbb    %edx,%esi
  802434:	89 74 24 04          	mov    %esi,0x4(%esp)
  802438:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80243c:	e9 18 ff ff ff       	jmp    802359 <__umoddi3+0x69>
