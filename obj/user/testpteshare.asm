
obj/user/testpteshare.debug:     file format elf32-i386


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
  80002c:	e8 47 01 00 00       	call   800178 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <childofspawn>:
	breakpoint();
}

void
childofspawn(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	strcpy(VA, msg2);
  800039:	ff 35 00 30 80 00    	pushl  0x803000
  80003f:	68 00 00 00 a0       	push   $0xa0000000
  800044:	e8 ed 07 00 00       	call   800836 <strcpy>
	exit();
  800049:	e8 70 01 00 00       	call   8001be <exit>
}
  80004e:	83 c4 10             	add    $0x10,%esp
  800051:	c9                   	leave  
  800052:	c3                   	ret    

00800053 <umain>:

void childofspawn(void);

void
umain(int argc, char **argv)
{
  800053:	55                   	push   %ebp
  800054:	89 e5                	mov    %esp,%ebp
  800056:	53                   	push   %ebx
  800057:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (argc != 0)
  80005a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80005e:	74 05                	je     800065 <umain+0x12>
		childofspawn();
  800060:	e8 ce ff ff ff       	call   800033 <childofspawn>

	if ((r = sys_page_alloc(0, VA, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800065:	83 ec 04             	sub    $0x4,%esp
  800068:	68 07 04 00 00       	push   $0x407
  80006d:	68 00 00 00 a0       	push   $0xa0000000
  800072:	6a 00                	push   $0x0
  800074:	e8 c0 0b 00 00       	call   800c39 <sys_page_alloc>
  800079:	83 c4 10             	add    $0x10,%esp
  80007c:	85 c0                	test   %eax,%eax
  80007e:	79 12                	jns    800092 <umain+0x3f>
		panic("sys_page_alloc: %e", r);
  800080:	50                   	push   %eax
  800081:	68 cc 27 80 00       	push   $0x8027cc
  800086:	6a 13                	push   $0x13
  800088:	68 df 27 80 00       	push   $0x8027df
  80008d:	e8 46 01 00 00       	call   8001d8 <_panic>

	// check fork
	if ((r = fork()) < 0)
  800092:	e8 e6 0e 00 00       	call   800f7d <fork>
  800097:	89 c3                	mov    %eax,%ebx
  800099:	85 c0                	test   %eax,%eax
  80009b:	79 12                	jns    8000af <umain+0x5c>
		panic("fork: %e", r);
  80009d:	50                   	push   %eax
  80009e:	68 00 2c 80 00       	push   $0x802c00
  8000a3:	6a 17                	push   $0x17
  8000a5:	68 df 27 80 00       	push   $0x8027df
  8000aa:	e8 29 01 00 00       	call   8001d8 <_panic>
	if (r == 0) {
  8000af:	85 c0                	test   %eax,%eax
  8000b1:	75 1b                	jne    8000ce <umain+0x7b>
		strcpy(VA, msg);
  8000b3:	83 ec 08             	sub    $0x8,%esp
  8000b6:	ff 35 04 30 80 00    	pushl  0x803004
  8000bc:	68 00 00 00 a0       	push   $0xa0000000
  8000c1:	e8 70 07 00 00       	call   800836 <strcpy>
		exit();
  8000c6:	e8 f3 00 00 00       	call   8001be <exit>
  8000cb:	83 c4 10             	add    $0x10,%esp
	}
	wait(r);
  8000ce:	83 ec 0c             	sub    $0xc,%esp
  8000d1:	53                   	push   %ebx
  8000d2:	e8 df 20 00 00       	call   8021b6 <wait>
	cprintf("fork handles PTE_SHARE %s\n", strcmp(VA, msg) == 0 ? "right" : "wrong");
  8000d7:	83 c4 08             	add    $0x8,%esp
  8000da:	ff 35 04 30 80 00    	pushl  0x803004
  8000e0:	68 00 00 00 a0       	push   $0xa0000000
  8000e5:	e8 f6 07 00 00       	call   8008e0 <strcmp>
  8000ea:	83 c4 08             	add    $0x8,%esp
  8000ed:	85 c0                	test   %eax,%eax
  8000ef:	ba c6 27 80 00       	mov    $0x8027c6,%edx
  8000f4:	b8 c0 27 80 00       	mov    $0x8027c0,%eax
  8000f9:	0f 45 c2             	cmovne %edx,%eax
  8000fc:	50                   	push   %eax
  8000fd:	68 f3 27 80 00       	push   $0x8027f3
  800102:	e8 aa 01 00 00       	call   8002b1 <cprintf>

	// check spawn
	if ((r = spawnl("/testpteshare", "testpteshare", "arg", 0)) < 0)
  800107:	6a 00                	push   $0x0
  800109:	68 0e 28 80 00       	push   $0x80280e
  80010e:	68 13 28 80 00       	push   $0x802813
  800113:	68 12 28 80 00       	push   $0x802812
  800118:	e8 ca 1c 00 00       	call   801de7 <spawnl>
  80011d:	83 c4 20             	add    $0x20,%esp
  800120:	85 c0                	test   %eax,%eax
  800122:	79 12                	jns    800136 <umain+0xe3>
		panic("spawn: %e", r);
  800124:	50                   	push   %eax
  800125:	68 20 28 80 00       	push   $0x802820
  80012a:	6a 21                	push   $0x21
  80012c:	68 df 27 80 00       	push   $0x8027df
  800131:	e8 a2 00 00 00       	call   8001d8 <_panic>
	wait(r);
  800136:	83 ec 0c             	sub    $0xc,%esp
  800139:	50                   	push   %eax
  80013a:	e8 77 20 00 00       	call   8021b6 <wait>
	cprintf("spawn handles PTE_SHARE %s\n", strcmp(VA, msg2) == 0 ? "right" : "wrong");
  80013f:	83 c4 08             	add    $0x8,%esp
  800142:	ff 35 00 30 80 00    	pushl  0x803000
  800148:	68 00 00 00 a0       	push   $0xa0000000
  80014d:	e8 8e 07 00 00       	call   8008e0 <strcmp>
  800152:	83 c4 08             	add    $0x8,%esp
  800155:	85 c0                	test   %eax,%eax
  800157:	ba c6 27 80 00       	mov    $0x8027c6,%edx
  80015c:	b8 c0 27 80 00       	mov    $0x8027c0,%eax
  800161:	0f 45 c2             	cmovne %edx,%eax
  800164:	50                   	push   %eax
  800165:	68 2a 28 80 00       	push   $0x80282a
  80016a:	e8 42 01 00 00       	call   8002b1 <cprintf>
static __inline uint64_t read_tsc(void) __attribute__((always_inline));

static __inline void
breakpoint(void)
{
	__asm __volatile("int3");
  80016f:	cc                   	int3   

	breakpoint();
}
  800170:	83 c4 10             	add    $0x10,%esp
  800173:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800176:	c9                   	leave  
  800177:	c3                   	ret    

00800178 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800178:	55                   	push   %ebp
  800179:	89 e5                	mov    %esp,%ebp
  80017b:	56                   	push   %esi
  80017c:	53                   	push   %ebx
  80017d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800180:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800183:	e8 73 0a 00 00       	call   800bfb <sys_getenvid>
  800188:	25 ff 03 00 00       	and    $0x3ff,%eax
  80018d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800190:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800195:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80019a:	85 db                	test   %ebx,%ebx
  80019c:	7e 07                	jle    8001a5 <libmain+0x2d>
		binaryname = argv[0];
  80019e:	8b 06                	mov    (%esi),%eax
  8001a0:	a3 08 30 80 00       	mov    %eax,0x803008

	// call user main routine
	umain(argc, argv);
  8001a5:	83 ec 08             	sub    $0x8,%esp
  8001a8:	56                   	push   %esi
  8001a9:	53                   	push   %ebx
  8001aa:	e8 a4 fe ff ff       	call   800053 <umain>

	// exit gracefully
	exit();
  8001af:	e8 0a 00 00 00       	call   8001be <exit>
}
  8001b4:	83 c4 10             	add    $0x10,%esp
  8001b7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001ba:	5b                   	pop    %ebx
  8001bb:	5e                   	pop    %esi
  8001bc:	5d                   	pop    %ebp
  8001bd:	c3                   	ret    

008001be <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001be:	55                   	push   %ebp
  8001bf:	89 e5                	mov    %esp,%ebp
  8001c1:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001c4:	e8 74 10 00 00       	call   80123d <close_all>
	sys_env_destroy(0);
  8001c9:	83 ec 0c             	sub    $0xc,%esp
  8001cc:	6a 00                	push   $0x0
  8001ce:	e8 e7 09 00 00       	call   800bba <sys_env_destroy>
}
  8001d3:	83 c4 10             	add    $0x10,%esp
  8001d6:	c9                   	leave  
  8001d7:	c3                   	ret    

008001d8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001d8:	55                   	push   %ebp
  8001d9:	89 e5                	mov    %esp,%ebp
  8001db:	56                   	push   %esi
  8001dc:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001dd:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001e0:	8b 35 08 30 80 00    	mov    0x803008,%esi
  8001e6:	e8 10 0a 00 00       	call   800bfb <sys_getenvid>
  8001eb:	83 ec 0c             	sub    $0xc,%esp
  8001ee:	ff 75 0c             	pushl  0xc(%ebp)
  8001f1:	ff 75 08             	pushl  0x8(%ebp)
  8001f4:	56                   	push   %esi
  8001f5:	50                   	push   %eax
  8001f6:	68 70 28 80 00       	push   $0x802870
  8001fb:	e8 b1 00 00 00       	call   8002b1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800200:	83 c4 18             	add    $0x18,%esp
  800203:	53                   	push   %ebx
  800204:	ff 75 10             	pushl  0x10(%ebp)
  800207:	e8 54 00 00 00       	call   800260 <vcprintf>
	cprintf("\n");
  80020c:	c7 04 24 d4 2d 80 00 	movl   $0x802dd4,(%esp)
  800213:	e8 99 00 00 00       	call   8002b1 <cprintf>
  800218:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80021b:	cc                   	int3   
  80021c:	eb fd                	jmp    80021b <_panic+0x43>

0080021e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80021e:	55                   	push   %ebp
  80021f:	89 e5                	mov    %esp,%ebp
  800221:	53                   	push   %ebx
  800222:	83 ec 04             	sub    $0x4,%esp
  800225:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800228:	8b 13                	mov    (%ebx),%edx
  80022a:	8d 42 01             	lea    0x1(%edx),%eax
  80022d:	89 03                	mov    %eax,(%ebx)
  80022f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800232:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800236:	3d ff 00 00 00       	cmp    $0xff,%eax
  80023b:	75 1a                	jne    800257 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80023d:	83 ec 08             	sub    $0x8,%esp
  800240:	68 ff 00 00 00       	push   $0xff
  800245:	8d 43 08             	lea    0x8(%ebx),%eax
  800248:	50                   	push   %eax
  800249:	e8 2f 09 00 00       	call   800b7d <sys_cputs>
		b->idx = 0;
  80024e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800254:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800257:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80025b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80025e:	c9                   	leave  
  80025f:	c3                   	ret    

00800260 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800260:	55                   	push   %ebp
  800261:	89 e5                	mov    %esp,%ebp
  800263:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800269:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800270:	00 00 00 
	b.cnt = 0;
  800273:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80027a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80027d:	ff 75 0c             	pushl  0xc(%ebp)
  800280:	ff 75 08             	pushl  0x8(%ebp)
  800283:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800289:	50                   	push   %eax
  80028a:	68 1e 02 80 00       	push   $0x80021e
  80028f:	e8 54 01 00 00       	call   8003e8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800294:	83 c4 08             	add    $0x8,%esp
  800297:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80029d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002a3:	50                   	push   %eax
  8002a4:	e8 d4 08 00 00       	call   800b7d <sys_cputs>

	return b.cnt;
}
  8002a9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002af:	c9                   	leave  
  8002b0:	c3                   	ret    

008002b1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
  8002b4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002b7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002ba:	50                   	push   %eax
  8002bb:	ff 75 08             	pushl  0x8(%ebp)
  8002be:	e8 9d ff ff ff       	call   800260 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002c3:	c9                   	leave  
  8002c4:	c3                   	ret    

008002c5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002c5:	55                   	push   %ebp
  8002c6:	89 e5                	mov    %esp,%ebp
  8002c8:	57                   	push   %edi
  8002c9:	56                   	push   %esi
  8002ca:	53                   	push   %ebx
  8002cb:	83 ec 1c             	sub    $0x1c,%esp
  8002ce:	89 c7                	mov    %eax,%edi
  8002d0:	89 d6                	mov    %edx,%esi
  8002d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002d8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002db:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002de:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002e1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002e6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002e9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002ec:	39 d3                	cmp    %edx,%ebx
  8002ee:	72 05                	jb     8002f5 <printnum+0x30>
  8002f0:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002f3:	77 45                	ja     80033a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002f5:	83 ec 0c             	sub    $0xc,%esp
  8002f8:	ff 75 18             	pushl  0x18(%ebp)
  8002fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8002fe:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800301:	53                   	push   %ebx
  800302:	ff 75 10             	pushl  0x10(%ebp)
  800305:	83 ec 08             	sub    $0x8,%esp
  800308:	ff 75 e4             	pushl  -0x1c(%ebp)
  80030b:	ff 75 e0             	pushl  -0x20(%ebp)
  80030e:	ff 75 dc             	pushl  -0x24(%ebp)
  800311:	ff 75 d8             	pushl  -0x28(%ebp)
  800314:	e8 17 22 00 00       	call   802530 <__udivdi3>
  800319:	83 c4 18             	add    $0x18,%esp
  80031c:	52                   	push   %edx
  80031d:	50                   	push   %eax
  80031e:	89 f2                	mov    %esi,%edx
  800320:	89 f8                	mov    %edi,%eax
  800322:	e8 9e ff ff ff       	call   8002c5 <printnum>
  800327:	83 c4 20             	add    $0x20,%esp
  80032a:	eb 18                	jmp    800344 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80032c:	83 ec 08             	sub    $0x8,%esp
  80032f:	56                   	push   %esi
  800330:	ff 75 18             	pushl  0x18(%ebp)
  800333:	ff d7                	call   *%edi
  800335:	83 c4 10             	add    $0x10,%esp
  800338:	eb 03                	jmp    80033d <printnum+0x78>
  80033a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80033d:	83 eb 01             	sub    $0x1,%ebx
  800340:	85 db                	test   %ebx,%ebx
  800342:	7f e8                	jg     80032c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800344:	83 ec 08             	sub    $0x8,%esp
  800347:	56                   	push   %esi
  800348:	83 ec 04             	sub    $0x4,%esp
  80034b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80034e:	ff 75 e0             	pushl  -0x20(%ebp)
  800351:	ff 75 dc             	pushl  -0x24(%ebp)
  800354:	ff 75 d8             	pushl  -0x28(%ebp)
  800357:	e8 04 23 00 00       	call   802660 <__umoddi3>
  80035c:	83 c4 14             	add    $0x14,%esp
  80035f:	0f be 80 93 28 80 00 	movsbl 0x802893(%eax),%eax
  800366:	50                   	push   %eax
  800367:	ff d7                	call   *%edi
}
  800369:	83 c4 10             	add    $0x10,%esp
  80036c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80036f:	5b                   	pop    %ebx
  800370:	5e                   	pop    %esi
  800371:	5f                   	pop    %edi
  800372:	5d                   	pop    %ebp
  800373:	c3                   	ret    

00800374 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800374:	55                   	push   %ebp
  800375:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800377:	83 fa 01             	cmp    $0x1,%edx
  80037a:	7e 0e                	jle    80038a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80037c:	8b 10                	mov    (%eax),%edx
  80037e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800381:	89 08                	mov    %ecx,(%eax)
  800383:	8b 02                	mov    (%edx),%eax
  800385:	8b 52 04             	mov    0x4(%edx),%edx
  800388:	eb 22                	jmp    8003ac <getuint+0x38>
	else if (lflag)
  80038a:	85 d2                	test   %edx,%edx
  80038c:	74 10                	je     80039e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80038e:	8b 10                	mov    (%eax),%edx
  800390:	8d 4a 04             	lea    0x4(%edx),%ecx
  800393:	89 08                	mov    %ecx,(%eax)
  800395:	8b 02                	mov    (%edx),%eax
  800397:	ba 00 00 00 00       	mov    $0x0,%edx
  80039c:	eb 0e                	jmp    8003ac <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80039e:	8b 10                	mov    (%eax),%edx
  8003a0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003a3:	89 08                	mov    %ecx,(%eax)
  8003a5:	8b 02                	mov    (%edx),%eax
  8003a7:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003ac:	5d                   	pop    %ebp
  8003ad:	c3                   	ret    

008003ae <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003ae:	55                   	push   %ebp
  8003af:	89 e5                	mov    %esp,%ebp
  8003b1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003b4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003b8:	8b 10                	mov    (%eax),%edx
  8003ba:	3b 50 04             	cmp    0x4(%eax),%edx
  8003bd:	73 0a                	jae    8003c9 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003bf:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003c2:	89 08                	mov    %ecx,(%eax)
  8003c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c7:	88 02                	mov    %al,(%edx)
}
  8003c9:	5d                   	pop    %ebp
  8003ca:	c3                   	ret    

008003cb <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003cb:	55                   	push   %ebp
  8003cc:	89 e5                	mov    %esp,%ebp
  8003ce:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003d1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003d4:	50                   	push   %eax
  8003d5:	ff 75 10             	pushl  0x10(%ebp)
  8003d8:	ff 75 0c             	pushl  0xc(%ebp)
  8003db:	ff 75 08             	pushl  0x8(%ebp)
  8003de:	e8 05 00 00 00       	call   8003e8 <vprintfmt>
	va_end(ap);
}
  8003e3:	83 c4 10             	add    $0x10,%esp
  8003e6:	c9                   	leave  
  8003e7:	c3                   	ret    

008003e8 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003e8:	55                   	push   %ebp
  8003e9:	89 e5                	mov    %esp,%ebp
  8003eb:	57                   	push   %edi
  8003ec:	56                   	push   %esi
  8003ed:	53                   	push   %ebx
  8003ee:	83 ec 2c             	sub    $0x2c,%esp
  8003f1:	8b 75 08             	mov    0x8(%ebp),%esi
  8003f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003f7:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003fa:	eb 12                	jmp    80040e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003fc:	85 c0                	test   %eax,%eax
  8003fe:	0f 84 89 03 00 00    	je     80078d <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800404:	83 ec 08             	sub    $0x8,%esp
  800407:	53                   	push   %ebx
  800408:	50                   	push   %eax
  800409:	ff d6                	call   *%esi
  80040b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80040e:	83 c7 01             	add    $0x1,%edi
  800411:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800415:	83 f8 25             	cmp    $0x25,%eax
  800418:	75 e2                	jne    8003fc <vprintfmt+0x14>
  80041a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80041e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800425:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80042c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800433:	ba 00 00 00 00       	mov    $0x0,%edx
  800438:	eb 07                	jmp    800441 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80043d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800441:	8d 47 01             	lea    0x1(%edi),%eax
  800444:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800447:	0f b6 07             	movzbl (%edi),%eax
  80044a:	0f b6 c8             	movzbl %al,%ecx
  80044d:	83 e8 23             	sub    $0x23,%eax
  800450:	3c 55                	cmp    $0x55,%al
  800452:	0f 87 1a 03 00 00    	ja     800772 <vprintfmt+0x38a>
  800458:	0f b6 c0             	movzbl %al,%eax
  80045b:	ff 24 85 e0 29 80 00 	jmp    *0x8029e0(,%eax,4)
  800462:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800465:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800469:	eb d6                	jmp    800441 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80046e:	b8 00 00 00 00       	mov    $0x0,%eax
  800473:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800476:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800479:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80047d:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800480:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800483:	83 fa 09             	cmp    $0x9,%edx
  800486:	77 39                	ja     8004c1 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800488:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80048b:	eb e9                	jmp    800476 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80048d:	8b 45 14             	mov    0x14(%ebp),%eax
  800490:	8d 48 04             	lea    0x4(%eax),%ecx
  800493:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800496:	8b 00                	mov    (%eax),%eax
  800498:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80049e:	eb 27                	jmp    8004c7 <vprintfmt+0xdf>
  8004a0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004a3:	85 c0                	test   %eax,%eax
  8004a5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004aa:	0f 49 c8             	cmovns %eax,%ecx
  8004ad:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004b3:	eb 8c                	jmp    800441 <vprintfmt+0x59>
  8004b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004b8:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004bf:	eb 80                	jmp    800441 <vprintfmt+0x59>
  8004c1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004c4:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004c7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004cb:	0f 89 70 ff ff ff    	jns    800441 <vprintfmt+0x59>
				width = precision, precision = -1;
  8004d1:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004d4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004d7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004de:	e9 5e ff ff ff       	jmp    800441 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004e3:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004e9:	e9 53 ff ff ff       	jmp    800441 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f1:	8d 50 04             	lea    0x4(%eax),%edx
  8004f4:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f7:	83 ec 08             	sub    $0x8,%esp
  8004fa:	53                   	push   %ebx
  8004fb:	ff 30                	pushl  (%eax)
  8004fd:	ff d6                	call   *%esi
			break;
  8004ff:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800502:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800505:	e9 04 ff ff ff       	jmp    80040e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80050a:	8b 45 14             	mov    0x14(%ebp),%eax
  80050d:	8d 50 04             	lea    0x4(%eax),%edx
  800510:	89 55 14             	mov    %edx,0x14(%ebp)
  800513:	8b 00                	mov    (%eax),%eax
  800515:	99                   	cltd   
  800516:	31 d0                	xor    %edx,%eax
  800518:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80051a:	83 f8 0f             	cmp    $0xf,%eax
  80051d:	7f 0b                	jg     80052a <vprintfmt+0x142>
  80051f:	8b 14 85 40 2b 80 00 	mov    0x802b40(,%eax,4),%edx
  800526:	85 d2                	test   %edx,%edx
  800528:	75 18                	jne    800542 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80052a:	50                   	push   %eax
  80052b:	68 ab 28 80 00       	push   $0x8028ab
  800530:	53                   	push   %ebx
  800531:	56                   	push   %esi
  800532:	e8 94 fe ff ff       	call   8003cb <printfmt>
  800537:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80053d:	e9 cc fe ff ff       	jmp    80040e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800542:	52                   	push   %edx
  800543:	68 16 2d 80 00       	push   $0x802d16
  800548:	53                   	push   %ebx
  800549:	56                   	push   %esi
  80054a:	e8 7c fe ff ff       	call   8003cb <printfmt>
  80054f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800552:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800555:	e9 b4 fe ff ff       	jmp    80040e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80055a:	8b 45 14             	mov    0x14(%ebp),%eax
  80055d:	8d 50 04             	lea    0x4(%eax),%edx
  800560:	89 55 14             	mov    %edx,0x14(%ebp)
  800563:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800565:	85 ff                	test   %edi,%edi
  800567:	b8 a4 28 80 00       	mov    $0x8028a4,%eax
  80056c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80056f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800573:	0f 8e 94 00 00 00    	jle    80060d <vprintfmt+0x225>
  800579:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80057d:	0f 84 98 00 00 00    	je     80061b <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800583:	83 ec 08             	sub    $0x8,%esp
  800586:	ff 75 d0             	pushl  -0x30(%ebp)
  800589:	57                   	push   %edi
  80058a:	e8 86 02 00 00       	call   800815 <strnlen>
  80058f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800592:	29 c1                	sub    %eax,%ecx
  800594:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800597:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80059a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80059e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005a1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005a4:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005a6:	eb 0f                	jmp    8005b7 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8005a8:	83 ec 08             	sub    $0x8,%esp
  8005ab:	53                   	push   %ebx
  8005ac:	ff 75 e0             	pushl  -0x20(%ebp)
  8005af:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b1:	83 ef 01             	sub    $0x1,%edi
  8005b4:	83 c4 10             	add    $0x10,%esp
  8005b7:	85 ff                	test   %edi,%edi
  8005b9:	7f ed                	jg     8005a8 <vprintfmt+0x1c0>
  8005bb:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005be:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8005c1:	85 c9                	test   %ecx,%ecx
  8005c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8005c8:	0f 49 c1             	cmovns %ecx,%eax
  8005cb:	29 c1                	sub    %eax,%ecx
  8005cd:	89 75 08             	mov    %esi,0x8(%ebp)
  8005d0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005d3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005d6:	89 cb                	mov    %ecx,%ebx
  8005d8:	eb 4d                	jmp    800627 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005da:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005de:	74 1b                	je     8005fb <vprintfmt+0x213>
  8005e0:	0f be c0             	movsbl %al,%eax
  8005e3:	83 e8 20             	sub    $0x20,%eax
  8005e6:	83 f8 5e             	cmp    $0x5e,%eax
  8005e9:	76 10                	jbe    8005fb <vprintfmt+0x213>
					putch('?', putdat);
  8005eb:	83 ec 08             	sub    $0x8,%esp
  8005ee:	ff 75 0c             	pushl  0xc(%ebp)
  8005f1:	6a 3f                	push   $0x3f
  8005f3:	ff 55 08             	call   *0x8(%ebp)
  8005f6:	83 c4 10             	add    $0x10,%esp
  8005f9:	eb 0d                	jmp    800608 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8005fb:	83 ec 08             	sub    $0x8,%esp
  8005fe:	ff 75 0c             	pushl  0xc(%ebp)
  800601:	52                   	push   %edx
  800602:	ff 55 08             	call   *0x8(%ebp)
  800605:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800608:	83 eb 01             	sub    $0x1,%ebx
  80060b:	eb 1a                	jmp    800627 <vprintfmt+0x23f>
  80060d:	89 75 08             	mov    %esi,0x8(%ebp)
  800610:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800613:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800616:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800619:	eb 0c                	jmp    800627 <vprintfmt+0x23f>
  80061b:	89 75 08             	mov    %esi,0x8(%ebp)
  80061e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800621:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800624:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800627:	83 c7 01             	add    $0x1,%edi
  80062a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80062e:	0f be d0             	movsbl %al,%edx
  800631:	85 d2                	test   %edx,%edx
  800633:	74 23                	je     800658 <vprintfmt+0x270>
  800635:	85 f6                	test   %esi,%esi
  800637:	78 a1                	js     8005da <vprintfmt+0x1f2>
  800639:	83 ee 01             	sub    $0x1,%esi
  80063c:	79 9c                	jns    8005da <vprintfmt+0x1f2>
  80063e:	89 df                	mov    %ebx,%edi
  800640:	8b 75 08             	mov    0x8(%ebp),%esi
  800643:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800646:	eb 18                	jmp    800660 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800648:	83 ec 08             	sub    $0x8,%esp
  80064b:	53                   	push   %ebx
  80064c:	6a 20                	push   $0x20
  80064e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800650:	83 ef 01             	sub    $0x1,%edi
  800653:	83 c4 10             	add    $0x10,%esp
  800656:	eb 08                	jmp    800660 <vprintfmt+0x278>
  800658:	89 df                	mov    %ebx,%edi
  80065a:	8b 75 08             	mov    0x8(%ebp),%esi
  80065d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800660:	85 ff                	test   %edi,%edi
  800662:	7f e4                	jg     800648 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800664:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800667:	e9 a2 fd ff ff       	jmp    80040e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80066c:	83 fa 01             	cmp    $0x1,%edx
  80066f:	7e 16                	jle    800687 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800671:	8b 45 14             	mov    0x14(%ebp),%eax
  800674:	8d 50 08             	lea    0x8(%eax),%edx
  800677:	89 55 14             	mov    %edx,0x14(%ebp)
  80067a:	8b 50 04             	mov    0x4(%eax),%edx
  80067d:	8b 00                	mov    (%eax),%eax
  80067f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800682:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800685:	eb 32                	jmp    8006b9 <vprintfmt+0x2d1>
	else if (lflag)
  800687:	85 d2                	test   %edx,%edx
  800689:	74 18                	je     8006a3 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80068b:	8b 45 14             	mov    0x14(%ebp),%eax
  80068e:	8d 50 04             	lea    0x4(%eax),%edx
  800691:	89 55 14             	mov    %edx,0x14(%ebp)
  800694:	8b 00                	mov    (%eax),%eax
  800696:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800699:	89 c1                	mov    %eax,%ecx
  80069b:	c1 f9 1f             	sar    $0x1f,%ecx
  80069e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006a1:	eb 16                	jmp    8006b9 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8006a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a6:	8d 50 04             	lea    0x4(%eax),%edx
  8006a9:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ac:	8b 00                	mov    (%eax),%eax
  8006ae:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006b1:	89 c1                	mov    %eax,%ecx
  8006b3:	c1 f9 1f             	sar    $0x1f,%ecx
  8006b6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006b9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006bc:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006bf:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006c4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006c8:	79 74                	jns    80073e <vprintfmt+0x356>
				putch('-', putdat);
  8006ca:	83 ec 08             	sub    $0x8,%esp
  8006cd:	53                   	push   %ebx
  8006ce:	6a 2d                	push   $0x2d
  8006d0:	ff d6                	call   *%esi
				num = -(long long) num;
  8006d2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006d5:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006d8:	f7 d8                	neg    %eax
  8006da:	83 d2 00             	adc    $0x0,%edx
  8006dd:	f7 da                	neg    %edx
  8006df:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006e2:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006e7:	eb 55                	jmp    80073e <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006e9:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ec:	e8 83 fc ff ff       	call   800374 <getuint>
			base = 10;
  8006f1:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006f6:	eb 46                	jmp    80073e <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8006f8:	8d 45 14             	lea    0x14(%ebp),%eax
  8006fb:	e8 74 fc ff ff       	call   800374 <getuint>
                        base = 8;
  800700:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800705:	eb 37                	jmp    80073e <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800707:	83 ec 08             	sub    $0x8,%esp
  80070a:	53                   	push   %ebx
  80070b:	6a 30                	push   $0x30
  80070d:	ff d6                	call   *%esi
			putch('x', putdat);
  80070f:	83 c4 08             	add    $0x8,%esp
  800712:	53                   	push   %ebx
  800713:	6a 78                	push   $0x78
  800715:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800717:	8b 45 14             	mov    0x14(%ebp),%eax
  80071a:	8d 50 04             	lea    0x4(%eax),%edx
  80071d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800720:	8b 00                	mov    (%eax),%eax
  800722:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800727:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80072a:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80072f:	eb 0d                	jmp    80073e <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800731:	8d 45 14             	lea    0x14(%ebp),%eax
  800734:	e8 3b fc ff ff       	call   800374 <getuint>
			base = 16;
  800739:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80073e:	83 ec 0c             	sub    $0xc,%esp
  800741:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800745:	57                   	push   %edi
  800746:	ff 75 e0             	pushl  -0x20(%ebp)
  800749:	51                   	push   %ecx
  80074a:	52                   	push   %edx
  80074b:	50                   	push   %eax
  80074c:	89 da                	mov    %ebx,%edx
  80074e:	89 f0                	mov    %esi,%eax
  800750:	e8 70 fb ff ff       	call   8002c5 <printnum>
			break;
  800755:	83 c4 20             	add    $0x20,%esp
  800758:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80075b:	e9 ae fc ff ff       	jmp    80040e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800760:	83 ec 08             	sub    $0x8,%esp
  800763:	53                   	push   %ebx
  800764:	51                   	push   %ecx
  800765:	ff d6                	call   *%esi
			break;
  800767:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80076a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80076d:	e9 9c fc ff ff       	jmp    80040e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800772:	83 ec 08             	sub    $0x8,%esp
  800775:	53                   	push   %ebx
  800776:	6a 25                	push   $0x25
  800778:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80077a:	83 c4 10             	add    $0x10,%esp
  80077d:	eb 03                	jmp    800782 <vprintfmt+0x39a>
  80077f:	83 ef 01             	sub    $0x1,%edi
  800782:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800786:	75 f7                	jne    80077f <vprintfmt+0x397>
  800788:	e9 81 fc ff ff       	jmp    80040e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80078d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800790:	5b                   	pop    %ebx
  800791:	5e                   	pop    %esi
  800792:	5f                   	pop    %edi
  800793:	5d                   	pop    %ebp
  800794:	c3                   	ret    

00800795 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800795:	55                   	push   %ebp
  800796:	89 e5                	mov    %esp,%ebp
  800798:	83 ec 18             	sub    $0x18,%esp
  80079b:	8b 45 08             	mov    0x8(%ebp),%eax
  80079e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007a1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007a4:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007a8:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007ab:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007b2:	85 c0                	test   %eax,%eax
  8007b4:	74 26                	je     8007dc <vsnprintf+0x47>
  8007b6:	85 d2                	test   %edx,%edx
  8007b8:	7e 22                	jle    8007dc <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007ba:	ff 75 14             	pushl  0x14(%ebp)
  8007bd:	ff 75 10             	pushl  0x10(%ebp)
  8007c0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007c3:	50                   	push   %eax
  8007c4:	68 ae 03 80 00       	push   $0x8003ae
  8007c9:	e8 1a fc ff ff       	call   8003e8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007d1:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007d7:	83 c4 10             	add    $0x10,%esp
  8007da:	eb 05                	jmp    8007e1 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007dc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007e1:	c9                   	leave  
  8007e2:	c3                   	ret    

008007e3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007e3:	55                   	push   %ebp
  8007e4:	89 e5                	mov    %esp,%ebp
  8007e6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007e9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007ec:	50                   	push   %eax
  8007ed:	ff 75 10             	pushl  0x10(%ebp)
  8007f0:	ff 75 0c             	pushl  0xc(%ebp)
  8007f3:	ff 75 08             	pushl  0x8(%ebp)
  8007f6:	e8 9a ff ff ff       	call   800795 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007fb:	c9                   	leave  
  8007fc:	c3                   	ret    

008007fd <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007fd:	55                   	push   %ebp
  8007fe:	89 e5                	mov    %esp,%ebp
  800800:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800803:	b8 00 00 00 00       	mov    $0x0,%eax
  800808:	eb 03                	jmp    80080d <strlen+0x10>
		n++;
  80080a:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80080d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800811:	75 f7                	jne    80080a <strlen+0xd>
		n++;
	return n;
}
  800813:	5d                   	pop    %ebp
  800814:	c3                   	ret    

00800815 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800815:	55                   	push   %ebp
  800816:	89 e5                	mov    %esp,%ebp
  800818:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80081b:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80081e:	ba 00 00 00 00       	mov    $0x0,%edx
  800823:	eb 03                	jmp    800828 <strnlen+0x13>
		n++;
  800825:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800828:	39 c2                	cmp    %eax,%edx
  80082a:	74 08                	je     800834 <strnlen+0x1f>
  80082c:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800830:	75 f3                	jne    800825 <strnlen+0x10>
  800832:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800834:	5d                   	pop    %ebp
  800835:	c3                   	ret    

00800836 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800836:	55                   	push   %ebp
  800837:	89 e5                	mov    %esp,%ebp
  800839:	53                   	push   %ebx
  80083a:	8b 45 08             	mov    0x8(%ebp),%eax
  80083d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800840:	89 c2                	mov    %eax,%edx
  800842:	83 c2 01             	add    $0x1,%edx
  800845:	83 c1 01             	add    $0x1,%ecx
  800848:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80084c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80084f:	84 db                	test   %bl,%bl
  800851:	75 ef                	jne    800842 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800853:	5b                   	pop    %ebx
  800854:	5d                   	pop    %ebp
  800855:	c3                   	ret    

00800856 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800856:	55                   	push   %ebp
  800857:	89 e5                	mov    %esp,%ebp
  800859:	53                   	push   %ebx
  80085a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80085d:	53                   	push   %ebx
  80085e:	e8 9a ff ff ff       	call   8007fd <strlen>
  800863:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800866:	ff 75 0c             	pushl  0xc(%ebp)
  800869:	01 d8                	add    %ebx,%eax
  80086b:	50                   	push   %eax
  80086c:	e8 c5 ff ff ff       	call   800836 <strcpy>
	return dst;
}
  800871:	89 d8                	mov    %ebx,%eax
  800873:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800876:	c9                   	leave  
  800877:	c3                   	ret    

00800878 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800878:	55                   	push   %ebp
  800879:	89 e5                	mov    %esp,%ebp
  80087b:	56                   	push   %esi
  80087c:	53                   	push   %ebx
  80087d:	8b 75 08             	mov    0x8(%ebp),%esi
  800880:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800883:	89 f3                	mov    %esi,%ebx
  800885:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800888:	89 f2                	mov    %esi,%edx
  80088a:	eb 0f                	jmp    80089b <strncpy+0x23>
		*dst++ = *src;
  80088c:	83 c2 01             	add    $0x1,%edx
  80088f:	0f b6 01             	movzbl (%ecx),%eax
  800892:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800895:	80 39 01             	cmpb   $0x1,(%ecx)
  800898:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80089b:	39 da                	cmp    %ebx,%edx
  80089d:	75 ed                	jne    80088c <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80089f:	89 f0                	mov    %esi,%eax
  8008a1:	5b                   	pop    %ebx
  8008a2:	5e                   	pop    %esi
  8008a3:	5d                   	pop    %ebp
  8008a4:	c3                   	ret    

008008a5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008a5:	55                   	push   %ebp
  8008a6:	89 e5                	mov    %esp,%ebp
  8008a8:	56                   	push   %esi
  8008a9:	53                   	push   %ebx
  8008aa:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008b0:	8b 55 10             	mov    0x10(%ebp),%edx
  8008b3:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008b5:	85 d2                	test   %edx,%edx
  8008b7:	74 21                	je     8008da <strlcpy+0x35>
  8008b9:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008bd:	89 f2                	mov    %esi,%edx
  8008bf:	eb 09                	jmp    8008ca <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008c1:	83 c2 01             	add    $0x1,%edx
  8008c4:	83 c1 01             	add    $0x1,%ecx
  8008c7:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008ca:	39 c2                	cmp    %eax,%edx
  8008cc:	74 09                	je     8008d7 <strlcpy+0x32>
  8008ce:	0f b6 19             	movzbl (%ecx),%ebx
  8008d1:	84 db                	test   %bl,%bl
  8008d3:	75 ec                	jne    8008c1 <strlcpy+0x1c>
  8008d5:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008d7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008da:	29 f0                	sub    %esi,%eax
}
  8008dc:	5b                   	pop    %ebx
  8008dd:	5e                   	pop    %esi
  8008de:	5d                   	pop    %ebp
  8008df:	c3                   	ret    

008008e0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008e0:	55                   	push   %ebp
  8008e1:	89 e5                	mov    %esp,%ebp
  8008e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008e6:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008e9:	eb 06                	jmp    8008f1 <strcmp+0x11>
		p++, q++;
  8008eb:	83 c1 01             	add    $0x1,%ecx
  8008ee:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008f1:	0f b6 01             	movzbl (%ecx),%eax
  8008f4:	84 c0                	test   %al,%al
  8008f6:	74 04                	je     8008fc <strcmp+0x1c>
  8008f8:	3a 02                	cmp    (%edx),%al
  8008fa:	74 ef                	je     8008eb <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008fc:	0f b6 c0             	movzbl %al,%eax
  8008ff:	0f b6 12             	movzbl (%edx),%edx
  800902:	29 d0                	sub    %edx,%eax
}
  800904:	5d                   	pop    %ebp
  800905:	c3                   	ret    

00800906 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800906:	55                   	push   %ebp
  800907:	89 e5                	mov    %esp,%ebp
  800909:	53                   	push   %ebx
  80090a:	8b 45 08             	mov    0x8(%ebp),%eax
  80090d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800910:	89 c3                	mov    %eax,%ebx
  800912:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800915:	eb 06                	jmp    80091d <strncmp+0x17>
		n--, p++, q++;
  800917:	83 c0 01             	add    $0x1,%eax
  80091a:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80091d:	39 d8                	cmp    %ebx,%eax
  80091f:	74 15                	je     800936 <strncmp+0x30>
  800921:	0f b6 08             	movzbl (%eax),%ecx
  800924:	84 c9                	test   %cl,%cl
  800926:	74 04                	je     80092c <strncmp+0x26>
  800928:	3a 0a                	cmp    (%edx),%cl
  80092a:	74 eb                	je     800917 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80092c:	0f b6 00             	movzbl (%eax),%eax
  80092f:	0f b6 12             	movzbl (%edx),%edx
  800932:	29 d0                	sub    %edx,%eax
  800934:	eb 05                	jmp    80093b <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800936:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80093b:	5b                   	pop    %ebx
  80093c:	5d                   	pop    %ebp
  80093d:	c3                   	ret    

0080093e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80093e:	55                   	push   %ebp
  80093f:	89 e5                	mov    %esp,%ebp
  800941:	8b 45 08             	mov    0x8(%ebp),%eax
  800944:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800948:	eb 07                	jmp    800951 <strchr+0x13>
		if (*s == c)
  80094a:	38 ca                	cmp    %cl,%dl
  80094c:	74 0f                	je     80095d <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80094e:	83 c0 01             	add    $0x1,%eax
  800951:	0f b6 10             	movzbl (%eax),%edx
  800954:	84 d2                	test   %dl,%dl
  800956:	75 f2                	jne    80094a <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800958:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80095d:	5d                   	pop    %ebp
  80095e:	c3                   	ret    

0080095f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80095f:	55                   	push   %ebp
  800960:	89 e5                	mov    %esp,%ebp
  800962:	8b 45 08             	mov    0x8(%ebp),%eax
  800965:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800969:	eb 03                	jmp    80096e <strfind+0xf>
  80096b:	83 c0 01             	add    $0x1,%eax
  80096e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800971:	38 ca                	cmp    %cl,%dl
  800973:	74 04                	je     800979 <strfind+0x1a>
  800975:	84 d2                	test   %dl,%dl
  800977:	75 f2                	jne    80096b <strfind+0xc>
			break;
	return (char *) s;
}
  800979:	5d                   	pop    %ebp
  80097a:	c3                   	ret    

0080097b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	57                   	push   %edi
  80097f:	56                   	push   %esi
  800980:	53                   	push   %ebx
  800981:	8b 7d 08             	mov    0x8(%ebp),%edi
  800984:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800987:	85 c9                	test   %ecx,%ecx
  800989:	74 36                	je     8009c1 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80098b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800991:	75 28                	jne    8009bb <memset+0x40>
  800993:	f6 c1 03             	test   $0x3,%cl
  800996:	75 23                	jne    8009bb <memset+0x40>
		c &= 0xFF;
  800998:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80099c:	89 d3                	mov    %edx,%ebx
  80099e:	c1 e3 08             	shl    $0x8,%ebx
  8009a1:	89 d6                	mov    %edx,%esi
  8009a3:	c1 e6 18             	shl    $0x18,%esi
  8009a6:	89 d0                	mov    %edx,%eax
  8009a8:	c1 e0 10             	shl    $0x10,%eax
  8009ab:	09 f0                	or     %esi,%eax
  8009ad:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8009af:	89 d8                	mov    %ebx,%eax
  8009b1:	09 d0                	or     %edx,%eax
  8009b3:	c1 e9 02             	shr    $0x2,%ecx
  8009b6:	fc                   	cld    
  8009b7:	f3 ab                	rep stos %eax,%es:(%edi)
  8009b9:	eb 06                	jmp    8009c1 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009be:	fc                   	cld    
  8009bf:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009c1:	89 f8                	mov    %edi,%eax
  8009c3:	5b                   	pop    %ebx
  8009c4:	5e                   	pop    %esi
  8009c5:	5f                   	pop    %edi
  8009c6:	5d                   	pop    %ebp
  8009c7:	c3                   	ret    

008009c8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009c8:	55                   	push   %ebp
  8009c9:	89 e5                	mov    %esp,%ebp
  8009cb:	57                   	push   %edi
  8009cc:	56                   	push   %esi
  8009cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009d3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009d6:	39 c6                	cmp    %eax,%esi
  8009d8:	73 35                	jae    800a0f <memmove+0x47>
  8009da:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009dd:	39 d0                	cmp    %edx,%eax
  8009df:	73 2e                	jae    800a0f <memmove+0x47>
		s += n;
		d += n;
  8009e1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e4:	89 d6                	mov    %edx,%esi
  8009e6:	09 fe                	or     %edi,%esi
  8009e8:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009ee:	75 13                	jne    800a03 <memmove+0x3b>
  8009f0:	f6 c1 03             	test   $0x3,%cl
  8009f3:	75 0e                	jne    800a03 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009f5:	83 ef 04             	sub    $0x4,%edi
  8009f8:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009fb:	c1 e9 02             	shr    $0x2,%ecx
  8009fe:	fd                   	std    
  8009ff:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a01:	eb 09                	jmp    800a0c <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a03:	83 ef 01             	sub    $0x1,%edi
  800a06:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a09:	fd                   	std    
  800a0a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a0c:	fc                   	cld    
  800a0d:	eb 1d                	jmp    800a2c <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a0f:	89 f2                	mov    %esi,%edx
  800a11:	09 c2                	or     %eax,%edx
  800a13:	f6 c2 03             	test   $0x3,%dl
  800a16:	75 0f                	jne    800a27 <memmove+0x5f>
  800a18:	f6 c1 03             	test   $0x3,%cl
  800a1b:	75 0a                	jne    800a27 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a1d:	c1 e9 02             	shr    $0x2,%ecx
  800a20:	89 c7                	mov    %eax,%edi
  800a22:	fc                   	cld    
  800a23:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a25:	eb 05                	jmp    800a2c <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a27:	89 c7                	mov    %eax,%edi
  800a29:	fc                   	cld    
  800a2a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a2c:	5e                   	pop    %esi
  800a2d:	5f                   	pop    %edi
  800a2e:	5d                   	pop    %ebp
  800a2f:	c3                   	ret    

00800a30 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a30:	55                   	push   %ebp
  800a31:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a33:	ff 75 10             	pushl  0x10(%ebp)
  800a36:	ff 75 0c             	pushl  0xc(%ebp)
  800a39:	ff 75 08             	pushl  0x8(%ebp)
  800a3c:	e8 87 ff ff ff       	call   8009c8 <memmove>
}
  800a41:	c9                   	leave  
  800a42:	c3                   	ret    

00800a43 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a43:	55                   	push   %ebp
  800a44:	89 e5                	mov    %esp,%ebp
  800a46:	56                   	push   %esi
  800a47:	53                   	push   %ebx
  800a48:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a4e:	89 c6                	mov    %eax,%esi
  800a50:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a53:	eb 1a                	jmp    800a6f <memcmp+0x2c>
		if (*s1 != *s2)
  800a55:	0f b6 08             	movzbl (%eax),%ecx
  800a58:	0f b6 1a             	movzbl (%edx),%ebx
  800a5b:	38 d9                	cmp    %bl,%cl
  800a5d:	74 0a                	je     800a69 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a5f:	0f b6 c1             	movzbl %cl,%eax
  800a62:	0f b6 db             	movzbl %bl,%ebx
  800a65:	29 d8                	sub    %ebx,%eax
  800a67:	eb 0f                	jmp    800a78 <memcmp+0x35>
		s1++, s2++;
  800a69:	83 c0 01             	add    $0x1,%eax
  800a6c:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a6f:	39 f0                	cmp    %esi,%eax
  800a71:	75 e2                	jne    800a55 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a73:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a78:	5b                   	pop    %ebx
  800a79:	5e                   	pop    %esi
  800a7a:	5d                   	pop    %ebp
  800a7b:	c3                   	ret    

00800a7c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a7c:	55                   	push   %ebp
  800a7d:	89 e5                	mov    %esp,%ebp
  800a7f:	53                   	push   %ebx
  800a80:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a83:	89 c1                	mov    %eax,%ecx
  800a85:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a88:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a8c:	eb 0a                	jmp    800a98 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a8e:	0f b6 10             	movzbl (%eax),%edx
  800a91:	39 da                	cmp    %ebx,%edx
  800a93:	74 07                	je     800a9c <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a95:	83 c0 01             	add    $0x1,%eax
  800a98:	39 c8                	cmp    %ecx,%eax
  800a9a:	72 f2                	jb     800a8e <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a9c:	5b                   	pop    %ebx
  800a9d:	5d                   	pop    %ebp
  800a9e:	c3                   	ret    

00800a9f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a9f:	55                   	push   %ebp
  800aa0:	89 e5                	mov    %esp,%ebp
  800aa2:	57                   	push   %edi
  800aa3:	56                   	push   %esi
  800aa4:	53                   	push   %ebx
  800aa5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aa8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aab:	eb 03                	jmp    800ab0 <strtol+0x11>
		s++;
  800aad:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ab0:	0f b6 01             	movzbl (%ecx),%eax
  800ab3:	3c 20                	cmp    $0x20,%al
  800ab5:	74 f6                	je     800aad <strtol+0xe>
  800ab7:	3c 09                	cmp    $0x9,%al
  800ab9:	74 f2                	je     800aad <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800abb:	3c 2b                	cmp    $0x2b,%al
  800abd:	75 0a                	jne    800ac9 <strtol+0x2a>
		s++;
  800abf:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ac2:	bf 00 00 00 00       	mov    $0x0,%edi
  800ac7:	eb 11                	jmp    800ada <strtol+0x3b>
  800ac9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ace:	3c 2d                	cmp    $0x2d,%al
  800ad0:	75 08                	jne    800ada <strtol+0x3b>
		s++, neg = 1;
  800ad2:	83 c1 01             	add    $0x1,%ecx
  800ad5:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ada:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ae0:	75 15                	jne    800af7 <strtol+0x58>
  800ae2:	80 39 30             	cmpb   $0x30,(%ecx)
  800ae5:	75 10                	jne    800af7 <strtol+0x58>
  800ae7:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800aeb:	75 7c                	jne    800b69 <strtol+0xca>
		s += 2, base = 16;
  800aed:	83 c1 02             	add    $0x2,%ecx
  800af0:	bb 10 00 00 00       	mov    $0x10,%ebx
  800af5:	eb 16                	jmp    800b0d <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800af7:	85 db                	test   %ebx,%ebx
  800af9:	75 12                	jne    800b0d <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800afb:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b00:	80 39 30             	cmpb   $0x30,(%ecx)
  800b03:	75 08                	jne    800b0d <strtol+0x6e>
		s++, base = 8;
  800b05:	83 c1 01             	add    $0x1,%ecx
  800b08:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b0d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b12:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b15:	0f b6 11             	movzbl (%ecx),%edx
  800b18:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b1b:	89 f3                	mov    %esi,%ebx
  800b1d:	80 fb 09             	cmp    $0x9,%bl
  800b20:	77 08                	ja     800b2a <strtol+0x8b>
			dig = *s - '0';
  800b22:	0f be d2             	movsbl %dl,%edx
  800b25:	83 ea 30             	sub    $0x30,%edx
  800b28:	eb 22                	jmp    800b4c <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b2a:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b2d:	89 f3                	mov    %esi,%ebx
  800b2f:	80 fb 19             	cmp    $0x19,%bl
  800b32:	77 08                	ja     800b3c <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b34:	0f be d2             	movsbl %dl,%edx
  800b37:	83 ea 57             	sub    $0x57,%edx
  800b3a:	eb 10                	jmp    800b4c <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b3c:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b3f:	89 f3                	mov    %esi,%ebx
  800b41:	80 fb 19             	cmp    $0x19,%bl
  800b44:	77 16                	ja     800b5c <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b46:	0f be d2             	movsbl %dl,%edx
  800b49:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b4c:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b4f:	7d 0b                	jge    800b5c <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b51:	83 c1 01             	add    $0x1,%ecx
  800b54:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b58:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b5a:	eb b9                	jmp    800b15 <strtol+0x76>

	if (endptr)
  800b5c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b60:	74 0d                	je     800b6f <strtol+0xd0>
		*endptr = (char *) s;
  800b62:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b65:	89 0e                	mov    %ecx,(%esi)
  800b67:	eb 06                	jmp    800b6f <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b69:	85 db                	test   %ebx,%ebx
  800b6b:	74 98                	je     800b05 <strtol+0x66>
  800b6d:	eb 9e                	jmp    800b0d <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b6f:	89 c2                	mov    %eax,%edx
  800b71:	f7 da                	neg    %edx
  800b73:	85 ff                	test   %edi,%edi
  800b75:	0f 45 c2             	cmovne %edx,%eax
}
  800b78:	5b                   	pop    %ebx
  800b79:	5e                   	pop    %esi
  800b7a:	5f                   	pop    %edi
  800b7b:	5d                   	pop    %ebp
  800b7c:	c3                   	ret    

00800b7d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b7d:	55                   	push   %ebp
  800b7e:	89 e5                	mov    %esp,%ebp
  800b80:	57                   	push   %edi
  800b81:	56                   	push   %esi
  800b82:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b83:	b8 00 00 00 00       	mov    $0x0,%eax
  800b88:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8e:	89 c3                	mov    %eax,%ebx
  800b90:	89 c7                	mov    %eax,%edi
  800b92:	89 c6                	mov    %eax,%esi
  800b94:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b96:	5b                   	pop    %ebx
  800b97:	5e                   	pop    %esi
  800b98:	5f                   	pop    %edi
  800b99:	5d                   	pop    %ebp
  800b9a:	c3                   	ret    

00800b9b <sys_cgetc>:

int
sys_cgetc(void)
{
  800b9b:	55                   	push   %ebp
  800b9c:	89 e5                	mov    %esp,%ebp
  800b9e:	57                   	push   %edi
  800b9f:	56                   	push   %esi
  800ba0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba6:	b8 01 00 00 00       	mov    $0x1,%eax
  800bab:	89 d1                	mov    %edx,%ecx
  800bad:	89 d3                	mov    %edx,%ebx
  800baf:	89 d7                	mov    %edx,%edi
  800bb1:	89 d6                	mov    %edx,%esi
  800bb3:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bb5:	5b                   	pop    %ebx
  800bb6:	5e                   	pop    %esi
  800bb7:	5f                   	pop    %edi
  800bb8:	5d                   	pop    %ebp
  800bb9:	c3                   	ret    

00800bba <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bba:	55                   	push   %ebp
  800bbb:	89 e5                	mov    %esp,%ebp
  800bbd:	57                   	push   %edi
  800bbe:	56                   	push   %esi
  800bbf:	53                   	push   %ebx
  800bc0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bc8:	b8 03 00 00 00       	mov    $0x3,%eax
  800bcd:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd0:	89 cb                	mov    %ecx,%ebx
  800bd2:	89 cf                	mov    %ecx,%edi
  800bd4:	89 ce                	mov    %ecx,%esi
  800bd6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bd8:	85 c0                	test   %eax,%eax
  800bda:	7e 17                	jle    800bf3 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bdc:	83 ec 0c             	sub    $0xc,%esp
  800bdf:	50                   	push   %eax
  800be0:	6a 03                	push   $0x3
  800be2:	68 9f 2b 80 00       	push   $0x802b9f
  800be7:	6a 23                	push   $0x23
  800be9:	68 bc 2b 80 00       	push   $0x802bbc
  800bee:	e8 e5 f5 ff ff       	call   8001d8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bf3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf6:	5b                   	pop    %ebx
  800bf7:	5e                   	pop    %esi
  800bf8:	5f                   	pop    %edi
  800bf9:	5d                   	pop    %ebp
  800bfa:	c3                   	ret    

00800bfb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bfb:	55                   	push   %ebp
  800bfc:	89 e5                	mov    %esp,%ebp
  800bfe:	57                   	push   %edi
  800bff:	56                   	push   %esi
  800c00:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c01:	ba 00 00 00 00       	mov    $0x0,%edx
  800c06:	b8 02 00 00 00       	mov    $0x2,%eax
  800c0b:	89 d1                	mov    %edx,%ecx
  800c0d:	89 d3                	mov    %edx,%ebx
  800c0f:	89 d7                	mov    %edx,%edi
  800c11:	89 d6                	mov    %edx,%esi
  800c13:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c15:	5b                   	pop    %ebx
  800c16:	5e                   	pop    %esi
  800c17:	5f                   	pop    %edi
  800c18:	5d                   	pop    %ebp
  800c19:	c3                   	ret    

00800c1a <sys_yield>:

void
sys_yield(void)
{
  800c1a:	55                   	push   %ebp
  800c1b:	89 e5                	mov    %esp,%ebp
  800c1d:	57                   	push   %edi
  800c1e:	56                   	push   %esi
  800c1f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c20:	ba 00 00 00 00       	mov    $0x0,%edx
  800c25:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c2a:	89 d1                	mov    %edx,%ecx
  800c2c:	89 d3                	mov    %edx,%ebx
  800c2e:	89 d7                	mov    %edx,%edi
  800c30:	89 d6                	mov    %edx,%esi
  800c32:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c34:	5b                   	pop    %ebx
  800c35:	5e                   	pop    %esi
  800c36:	5f                   	pop    %edi
  800c37:	5d                   	pop    %ebp
  800c38:	c3                   	ret    

00800c39 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800c42:	be 00 00 00 00       	mov    $0x0,%esi
  800c47:	b8 04 00 00 00       	mov    $0x4,%eax
  800c4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c52:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c55:	89 f7                	mov    %esi,%edi
  800c57:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c59:	85 c0                	test   %eax,%eax
  800c5b:	7e 17                	jle    800c74 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5d:	83 ec 0c             	sub    $0xc,%esp
  800c60:	50                   	push   %eax
  800c61:	6a 04                	push   $0x4
  800c63:	68 9f 2b 80 00       	push   $0x802b9f
  800c68:	6a 23                	push   $0x23
  800c6a:	68 bc 2b 80 00       	push   $0x802bbc
  800c6f:	e8 64 f5 ff ff       	call   8001d8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c74:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c77:	5b                   	pop    %ebx
  800c78:	5e                   	pop    %esi
  800c79:	5f                   	pop    %edi
  800c7a:	5d                   	pop    %ebp
  800c7b:	c3                   	ret    

00800c7c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c7c:	55                   	push   %ebp
  800c7d:	89 e5                	mov    %esp,%ebp
  800c7f:	57                   	push   %edi
  800c80:	56                   	push   %esi
  800c81:	53                   	push   %ebx
  800c82:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c85:	b8 05 00 00 00       	mov    $0x5,%eax
  800c8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c90:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c93:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c96:	8b 75 18             	mov    0x18(%ebp),%esi
  800c99:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c9b:	85 c0                	test   %eax,%eax
  800c9d:	7e 17                	jle    800cb6 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9f:	83 ec 0c             	sub    $0xc,%esp
  800ca2:	50                   	push   %eax
  800ca3:	6a 05                	push   $0x5
  800ca5:	68 9f 2b 80 00       	push   $0x802b9f
  800caa:	6a 23                	push   $0x23
  800cac:	68 bc 2b 80 00       	push   $0x802bbc
  800cb1:	e8 22 f5 ff ff       	call   8001d8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cb6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb9:	5b                   	pop    %ebx
  800cba:	5e                   	pop    %esi
  800cbb:	5f                   	pop    %edi
  800cbc:	5d                   	pop    %ebp
  800cbd:	c3                   	ret    

00800cbe <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cbe:	55                   	push   %ebp
  800cbf:	89 e5                	mov    %esp,%ebp
  800cc1:	57                   	push   %edi
  800cc2:	56                   	push   %esi
  800cc3:	53                   	push   %ebx
  800cc4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ccc:	b8 06 00 00 00       	mov    $0x6,%eax
  800cd1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd7:	89 df                	mov    %ebx,%edi
  800cd9:	89 de                	mov    %ebx,%esi
  800cdb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cdd:	85 c0                	test   %eax,%eax
  800cdf:	7e 17                	jle    800cf8 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce1:	83 ec 0c             	sub    $0xc,%esp
  800ce4:	50                   	push   %eax
  800ce5:	6a 06                	push   $0x6
  800ce7:	68 9f 2b 80 00       	push   $0x802b9f
  800cec:	6a 23                	push   $0x23
  800cee:	68 bc 2b 80 00       	push   $0x802bbc
  800cf3:	e8 e0 f4 ff ff       	call   8001d8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cf8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfb:	5b                   	pop    %ebx
  800cfc:	5e                   	pop    %esi
  800cfd:	5f                   	pop    %edi
  800cfe:	5d                   	pop    %ebp
  800cff:	c3                   	ret    

00800d00 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d00:	55                   	push   %ebp
  800d01:	89 e5                	mov    %esp,%ebp
  800d03:	57                   	push   %edi
  800d04:	56                   	push   %esi
  800d05:	53                   	push   %ebx
  800d06:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d09:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d0e:	b8 08 00 00 00       	mov    $0x8,%eax
  800d13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d16:	8b 55 08             	mov    0x8(%ebp),%edx
  800d19:	89 df                	mov    %ebx,%edi
  800d1b:	89 de                	mov    %ebx,%esi
  800d1d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d1f:	85 c0                	test   %eax,%eax
  800d21:	7e 17                	jle    800d3a <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d23:	83 ec 0c             	sub    $0xc,%esp
  800d26:	50                   	push   %eax
  800d27:	6a 08                	push   $0x8
  800d29:	68 9f 2b 80 00       	push   $0x802b9f
  800d2e:	6a 23                	push   $0x23
  800d30:	68 bc 2b 80 00       	push   $0x802bbc
  800d35:	e8 9e f4 ff ff       	call   8001d8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3d:	5b                   	pop    %ebx
  800d3e:	5e                   	pop    %esi
  800d3f:	5f                   	pop    %edi
  800d40:	5d                   	pop    %ebp
  800d41:	c3                   	ret    

00800d42 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d42:	55                   	push   %ebp
  800d43:	89 e5                	mov    %esp,%ebp
  800d45:	57                   	push   %edi
  800d46:	56                   	push   %esi
  800d47:	53                   	push   %ebx
  800d48:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d50:	b8 09 00 00 00       	mov    $0x9,%eax
  800d55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d58:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5b:	89 df                	mov    %ebx,%edi
  800d5d:	89 de                	mov    %ebx,%esi
  800d5f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d61:	85 c0                	test   %eax,%eax
  800d63:	7e 17                	jle    800d7c <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d65:	83 ec 0c             	sub    $0xc,%esp
  800d68:	50                   	push   %eax
  800d69:	6a 09                	push   $0x9
  800d6b:	68 9f 2b 80 00       	push   $0x802b9f
  800d70:	6a 23                	push   $0x23
  800d72:	68 bc 2b 80 00       	push   $0x802bbc
  800d77:	e8 5c f4 ff ff       	call   8001d8 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7f:	5b                   	pop    %ebx
  800d80:	5e                   	pop    %esi
  800d81:	5f                   	pop    %edi
  800d82:	5d                   	pop    %ebp
  800d83:	c3                   	ret    

00800d84 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d84:	55                   	push   %ebp
  800d85:	89 e5                	mov    %esp,%ebp
  800d87:	57                   	push   %edi
  800d88:	56                   	push   %esi
  800d89:	53                   	push   %ebx
  800d8a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d92:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9d:	89 df                	mov    %ebx,%edi
  800d9f:	89 de                	mov    %ebx,%esi
  800da1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800da3:	85 c0                	test   %eax,%eax
  800da5:	7e 17                	jle    800dbe <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da7:	83 ec 0c             	sub    $0xc,%esp
  800daa:	50                   	push   %eax
  800dab:	6a 0a                	push   $0xa
  800dad:	68 9f 2b 80 00       	push   $0x802b9f
  800db2:	6a 23                	push   $0x23
  800db4:	68 bc 2b 80 00       	push   $0x802bbc
  800db9:	e8 1a f4 ff ff       	call   8001d8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dbe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc1:	5b                   	pop    %ebx
  800dc2:	5e                   	pop    %esi
  800dc3:	5f                   	pop    %edi
  800dc4:	5d                   	pop    %ebp
  800dc5:	c3                   	ret    

00800dc6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dc6:	55                   	push   %ebp
  800dc7:	89 e5                	mov    %esp,%ebp
  800dc9:	57                   	push   %edi
  800dca:	56                   	push   %esi
  800dcb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dcc:	be 00 00 00 00       	mov    $0x0,%esi
  800dd1:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dd6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ddf:	8b 7d 14             	mov    0x14(%ebp),%edi
  800de2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800de4:	5b                   	pop    %ebx
  800de5:	5e                   	pop    %esi
  800de6:	5f                   	pop    %edi
  800de7:	5d                   	pop    %ebp
  800de8:	c3                   	ret    

00800de9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800de9:	55                   	push   %ebp
  800dea:	89 e5                	mov    %esp,%ebp
  800dec:	57                   	push   %edi
  800ded:	56                   	push   %esi
  800dee:	53                   	push   %ebx
  800def:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800df7:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dfc:	8b 55 08             	mov    0x8(%ebp),%edx
  800dff:	89 cb                	mov    %ecx,%ebx
  800e01:	89 cf                	mov    %ecx,%edi
  800e03:	89 ce                	mov    %ecx,%esi
  800e05:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e07:	85 c0                	test   %eax,%eax
  800e09:	7e 17                	jle    800e22 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e0b:	83 ec 0c             	sub    $0xc,%esp
  800e0e:	50                   	push   %eax
  800e0f:	6a 0d                	push   $0xd
  800e11:	68 9f 2b 80 00       	push   $0x802b9f
  800e16:	6a 23                	push   $0x23
  800e18:	68 bc 2b 80 00       	push   $0x802bbc
  800e1d:	e8 b6 f3 ff ff       	call   8001d8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e22:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e25:	5b                   	pop    %ebx
  800e26:	5e                   	pop    %esi
  800e27:	5f                   	pop    %edi
  800e28:	5d                   	pop    %ebp
  800e29:	c3                   	ret    

00800e2a <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800e2a:	55                   	push   %ebp
  800e2b:	89 e5                	mov    %esp,%ebp
  800e2d:	56                   	push   %esi
  800e2e:	53                   	push   %ebx
	int r;

	// LAB 4: Your code here.
	// Check if page is writable or COW
	pte_t pte = uvpt[pn];
  800e2f:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
	uint32_t perm = PTE_P | PTE_U;
	if (pte && (PTE_COW | PTE_W)) {
		perm |= PTE_COW;
  800e36:	83 f9 01             	cmp    $0x1,%ecx
  800e39:	19 f6                	sbb    %esi,%esi
  800e3b:	81 e6 00 f8 ff ff    	and    $0xfffff800,%esi
  800e41:	81 c6 05 08 00 00    	add    $0x805,%esi
	}

	// Map page
	void *va = (void *) (pn * PGSIZE);
  800e47:	c1 e2 0c             	shl    $0xc,%edx
  800e4a:	89 d3                	mov    %edx,%ebx
	// Map on the child
	if ((r = sys_page_map(0, va, envid, va, perm)) < 0) {
  800e4c:	83 ec 0c             	sub    $0xc,%esp
  800e4f:	56                   	push   %esi
  800e50:	52                   	push   %edx
  800e51:	50                   	push   %eax
  800e52:	52                   	push   %edx
  800e53:	6a 00                	push   $0x0
  800e55:	e8 22 fe ff ff       	call   800c7c <sys_page_map>
  800e5a:	83 c4 20             	add    $0x20,%esp
  800e5d:	85 c0                	test   %eax,%eax
  800e5f:	79 12                	jns    800e73 <duppage+0x49>
		panic("sys_page_alloc: %e", r);
  800e61:	50                   	push   %eax
  800e62:	68 cc 27 80 00       	push   $0x8027cc
  800e67:	6a 56                	push   $0x56
  800e69:	68 ca 2b 80 00       	push   $0x802bca
  800e6e:	e8 65 f3 ff ff       	call   8001d8 <_panic>
		return r;
	}

	// Change the permission on the parent
	if ((r = sys_page_map(0, va, 0, va, perm)) < 0) {
  800e73:	83 ec 0c             	sub    $0xc,%esp
  800e76:	56                   	push   %esi
  800e77:	53                   	push   %ebx
  800e78:	6a 00                	push   $0x0
  800e7a:	53                   	push   %ebx
  800e7b:	6a 00                	push   $0x0
  800e7d:	e8 fa fd ff ff       	call   800c7c <sys_page_map>
  800e82:	83 c4 20             	add    $0x20,%esp
  800e85:	85 c0                	test   %eax,%eax
  800e87:	79 12                	jns    800e9b <duppage+0x71>
		panic("sys_page_alloc: %e", r);
  800e89:	50                   	push   %eax
  800e8a:	68 cc 27 80 00       	push   $0x8027cc
  800e8f:	6a 5c                	push   $0x5c
  800e91:	68 ca 2b 80 00       	push   $0x802bca
  800e96:	e8 3d f3 ff ff       	call   8001d8 <_panic>
		return r;
	}

	return 0;
}
  800e9b:	b8 00 00 00 00       	mov    $0x0,%eax
  800ea0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ea3:	5b                   	pop    %ebx
  800ea4:	5e                   	pop    %esi
  800ea5:	5d                   	pop    %ebp
  800ea6:	c3                   	ret    

00800ea7 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ea7:	55                   	push   %ebp
  800ea8:	89 e5                	mov    %esp,%ebp
  800eaa:	53                   	push   %ebx
  800eab:	83 ec 04             	sub    $0x4,%esp
  800eae:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800eb1:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	unsigned pn = ((uint32_t)addr)/PGSIZE;
  800eb3:	89 da                	mov    %ebx,%edx
  800eb5:	c1 ea 0c             	shr    $0xc,%edx
	pte_t pte = uvpt[pn];
  800eb8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(err & FEC_WR) || !(pte & PTE_COW)) {
  800ebf:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800ec3:	74 05                	je     800eca <pgfault+0x23>
  800ec5:	f6 c6 08             	test   $0x8,%dh
  800ec8:	75 14                	jne    800ede <pgfault+0x37>
		panic("fork pgfault handler: does not handle this fault");
  800eca:	83 ec 04             	sub    $0x4,%esp
  800ecd:	68 38 2c 80 00       	push   $0x802c38
  800ed2:	6a 1f                	push   $0x1f
  800ed4:	68 ca 2b 80 00       	push   $0x802bca
  800ed9:	e8 fa f2 ff ff       	call   8001d8 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// Allocate a new page, mapped at temp location
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  800ede:	83 ec 04             	sub    $0x4,%esp
  800ee1:	6a 07                	push   $0x7
  800ee3:	68 00 f0 7f 00       	push   $0x7ff000
  800ee8:	6a 00                	push   $0x0
  800eea:	e8 4a fd ff ff       	call   800c39 <sys_page_alloc>
  800eef:	83 c4 10             	add    $0x10,%esp
  800ef2:	85 c0                	test   %eax,%eax
  800ef4:	79 12                	jns    800f08 <pgfault+0x61>
		panic("sys_page_alloc: %e", r);
  800ef6:	50                   	push   %eax
  800ef7:	68 cc 27 80 00       	push   $0x8027cc
  800efc:	6a 2b                	push   $0x2b
  800efe:	68 ca 2b 80 00       	push   $0x802bca
  800f03:	e8 d0 f2 ff ff       	call   8001d8 <_panic>

	// Copy the data from the old page to this new page
	void *addr_pgstart = (void *) ROUNDDOWN(addr, PGSIZE);
  800f08:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr_pgstart, PGSIZE);
  800f0e:	83 ec 04             	sub    $0x4,%esp
  800f11:	68 00 10 00 00       	push   $0x1000
  800f16:	53                   	push   %ebx
  800f17:	68 00 f0 7f 00       	push   $0x7ff000
  800f1c:	e8 a7 fa ff ff       	call   8009c8 <memmove>

	// Move the new page to the old page's address
	if ((r = sys_page_map(0, PFTEMP, 0, addr_pgstart, PTE_P|PTE_U|PTE_W)) < 0)
  800f21:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f28:	53                   	push   %ebx
  800f29:	6a 00                	push   $0x0
  800f2b:	68 00 f0 7f 00       	push   $0x7ff000
  800f30:	6a 00                	push   $0x0
  800f32:	e8 45 fd ff ff       	call   800c7c <sys_page_map>
  800f37:	83 c4 20             	add    $0x20,%esp
  800f3a:	85 c0                	test   %eax,%eax
  800f3c:	79 12                	jns    800f50 <pgfault+0xa9>
		panic("sys_page_map: %e", r);
  800f3e:	50                   	push   %eax
  800f3f:	68 d5 2b 80 00       	push   $0x802bd5
  800f44:	6a 33                	push   $0x33
  800f46:	68 ca 2b 80 00       	push   $0x802bca
  800f4b:	e8 88 f2 ff ff       	call   8001d8 <_panic>

	// Unmap the temp location
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800f50:	83 ec 08             	sub    $0x8,%esp
  800f53:	68 00 f0 7f 00       	push   $0x7ff000
  800f58:	6a 00                	push   $0x0
  800f5a:	e8 5f fd ff ff       	call   800cbe <sys_page_unmap>
  800f5f:	83 c4 10             	add    $0x10,%esp
  800f62:	85 c0                	test   %eax,%eax
  800f64:	79 12                	jns    800f78 <pgfault+0xd1>
		panic("sys_page_unmap: %e", r);
  800f66:	50                   	push   %eax
  800f67:	68 e6 2b 80 00       	push   $0x802be6
  800f6c:	6a 37                	push   $0x37
  800f6e:	68 ca 2b 80 00       	push   $0x802bca
  800f73:	e8 60 f2 ff ff       	call   8001d8 <_panic>
}
  800f78:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f7b:	c9                   	leave  
  800f7c:	c3                   	ret    

00800f7d <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f7d:	55                   	push   %ebp
  800f7e:	89 e5                	mov    %esp,%ebp
  800f80:	56                   	push   %esi
  800f81:	53                   	push   %ebx
  800f82:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
	// Set up page fault handler
	set_pgfault_handler(&pgfault);
  800f85:	68 a7 0e 80 00       	push   $0x800ea7
  800f8a:	e8 f9 13 00 00       	call   802388 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f8f:	b8 07 00 00 00       	mov    $0x7,%eax
  800f94:	cd 30                	int    $0x30

	// Create child
	envid_t envid = sys_exofork();
  800f96:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (envid < 0) {
  800f99:	83 c4 10             	add    $0x10,%esp
  800f9c:	85 c0                	test   %eax,%eax
  800f9e:	79 12                	jns    800fb2 <fork+0x35>
		panic("sys_exofork: %e", envid);
  800fa0:	50                   	push   %eax
  800fa1:	68 f9 2b 80 00       	push   $0x802bf9
  800fa6:	6a 7d                	push   $0x7d
  800fa8:	68 ca 2b 80 00       	push   $0x802bca
  800fad:	e8 26 f2 ff ff       	call   8001d8 <_panic>
		return envid;
	}
	if (envid == 0) {
  800fb2:	85 c0                	test   %eax,%eax
  800fb4:	75 1e                	jne    800fd4 <fork+0x57>
		// We are the child.
		thisenv = &envs[ENVX(sys_getenvid())]; // Fix thisenv
  800fb6:	e8 40 fc ff ff       	call   800bfb <sys_getenvid>
  800fbb:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fc0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800fc3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fc8:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800fcd:	b8 00 00 00 00       	mov    $0x0,%eax
  800fd2:	eb 7d                	jmp    801051 <fork+0xd4>

	// Set page fault handler on the child.
	// The parent needs to do it, else the child wouldn't be able to handle
	// the fault when trying to access it's stack (which happens as soon it starts)
	extern void _pgfault_upcall(void);
	sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);
  800fd4:	83 ec 04             	sub    $0x4,%esp
  800fd7:	6a 07                	push   $0x7
  800fd9:	68 00 f0 bf ee       	push   $0xeebff000
  800fde:	50                   	push   %eax
  800fdf:	e8 55 fc ff ff       	call   800c39 <sys_page_alloc>
	sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  800fe4:	83 c4 08             	add    $0x8,%esp
  800fe7:	68 cd 23 80 00       	push   $0x8023cd
  800fec:	ff 75 f4             	pushl  -0xc(%ebp)
  800fef:	e8 90 fd ff ff       	call   800d84 <sys_env_set_pgfault_upcall>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  800ff4:	be 04 60 80 00       	mov    $0x806004,%esi
  800ff9:	c1 ee 0c             	shr    $0xc,%esi
  800ffc:	83 c4 10             	add    $0x10,%esp
  800fff:	bb 00 08 00 00       	mov    $0x800,%ebx
  801004:	eb 0d                	jmp    801013 <fork+0x96>
		duppage(envid, pn);
  801006:	89 da                	mov    %ebx,%edx
  801008:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80100b:	e8 1a fe ff ff       	call   800e2a <duppage>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  801010:	83 c3 01             	add    $0x1,%ebx
  801013:	39 f3                	cmp    %esi,%ebx
  801015:	76 ef                	jbe    801006 <fork+0x89>
	}

	// Also copy the stack we are currently running on
	// I think it should loop from ustacktop to this page, since the stack
	// can have more than 1 page
	duppage(envid, ((uint32_t) &envid)/PGSIZE);
  801017:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80101a:	c1 ea 0c             	shr    $0xc,%edx
  80101d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801020:	e8 05 fe ff ff       	call   800e2a <duppage>

	// Start the child environmnet running
	int r;
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  801025:	83 ec 08             	sub    $0x8,%esp
  801028:	6a 02                	push   $0x2
  80102a:	ff 75 f4             	pushl  -0xc(%ebp)
  80102d:	e8 ce fc ff ff       	call   800d00 <sys_env_set_status>
  801032:	83 c4 10             	add    $0x10,%esp
  801035:	85 c0                	test   %eax,%eax
  801037:	79 15                	jns    80104e <fork+0xd1>
		panic("sys_env_set_status: %e", r);
  801039:	50                   	push   %eax
  80103a:	68 09 2c 80 00       	push   $0x802c09
  80103f:	68 9d 00 00 00       	push   $0x9d
  801044:	68 ca 2b 80 00       	push   $0x802bca
  801049:	e8 8a f1 ff ff       	call   8001d8 <_panic>
		return r;
	}

	return envid;
  80104e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  801051:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801054:	5b                   	pop    %ebx
  801055:	5e                   	pop    %esi
  801056:	5d                   	pop    %ebp
  801057:	c3                   	ret    

00801058 <sfork>:

// Challenge!
int
sfork(void)
{
  801058:	55                   	push   %ebp
  801059:	89 e5                	mov    %esp,%ebp
  80105b:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80105e:	68 20 2c 80 00       	push   $0x802c20
  801063:	68 a8 00 00 00       	push   $0xa8
  801068:	68 ca 2b 80 00       	push   $0x802bca
  80106d:	e8 66 f1 ff ff       	call   8001d8 <_panic>

00801072 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801072:	55                   	push   %ebp
  801073:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801075:	8b 45 08             	mov    0x8(%ebp),%eax
  801078:	05 00 00 00 30       	add    $0x30000000,%eax
  80107d:	c1 e8 0c             	shr    $0xc,%eax
}
  801080:	5d                   	pop    %ebp
  801081:	c3                   	ret    

00801082 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801082:	55                   	push   %ebp
  801083:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801085:	8b 45 08             	mov    0x8(%ebp),%eax
  801088:	05 00 00 00 30       	add    $0x30000000,%eax
  80108d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801092:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801097:	5d                   	pop    %ebp
  801098:	c3                   	ret    

00801099 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801099:	55                   	push   %ebp
  80109a:	89 e5                	mov    %esp,%ebp
  80109c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80109f:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010a4:	89 c2                	mov    %eax,%edx
  8010a6:	c1 ea 16             	shr    $0x16,%edx
  8010a9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010b0:	f6 c2 01             	test   $0x1,%dl
  8010b3:	74 11                	je     8010c6 <fd_alloc+0x2d>
  8010b5:	89 c2                	mov    %eax,%edx
  8010b7:	c1 ea 0c             	shr    $0xc,%edx
  8010ba:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010c1:	f6 c2 01             	test   $0x1,%dl
  8010c4:	75 09                	jne    8010cf <fd_alloc+0x36>
			*fd_store = fd;
  8010c6:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8010cd:	eb 17                	jmp    8010e6 <fd_alloc+0x4d>
  8010cf:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010d4:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010d9:	75 c9                	jne    8010a4 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8010db:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8010e1:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8010e6:	5d                   	pop    %ebp
  8010e7:	c3                   	ret    

008010e8 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010e8:	55                   	push   %ebp
  8010e9:	89 e5                	mov    %esp,%ebp
  8010eb:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010ee:	83 f8 1f             	cmp    $0x1f,%eax
  8010f1:	77 36                	ja     801129 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010f3:	c1 e0 0c             	shl    $0xc,%eax
  8010f6:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8010fb:	89 c2                	mov    %eax,%edx
  8010fd:	c1 ea 16             	shr    $0x16,%edx
  801100:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801107:	f6 c2 01             	test   $0x1,%dl
  80110a:	74 24                	je     801130 <fd_lookup+0x48>
  80110c:	89 c2                	mov    %eax,%edx
  80110e:	c1 ea 0c             	shr    $0xc,%edx
  801111:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801118:	f6 c2 01             	test   $0x1,%dl
  80111b:	74 1a                	je     801137 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80111d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801120:	89 02                	mov    %eax,(%edx)
	return 0;
  801122:	b8 00 00 00 00       	mov    $0x0,%eax
  801127:	eb 13                	jmp    80113c <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801129:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80112e:	eb 0c                	jmp    80113c <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801130:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801135:	eb 05                	jmp    80113c <fd_lookup+0x54>
  801137:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80113c:	5d                   	pop    %ebp
  80113d:	c3                   	ret    

0080113e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80113e:	55                   	push   %ebp
  80113f:	89 e5                	mov    %esp,%ebp
  801141:	83 ec 08             	sub    $0x8,%esp
  801144:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801147:	ba e8 2c 80 00       	mov    $0x802ce8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80114c:	eb 13                	jmp    801161 <dev_lookup+0x23>
  80114e:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801151:	39 08                	cmp    %ecx,(%eax)
  801153:	75 0c                	jne    801161 <dev_lookup+0x23>
			*dev = devtab[i];
  801155:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801158:	89 01                	mov    %eax,(%ecx)
			return 0;
  80115a:	b8 00 00 00 00       	mov    $0x0,%eax
  80115f:	eb 2e                	jmp    80118f <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801161:	8b 02                	mov    (%edx),%eax
  801163:	85 c0                	test   %eax,%eax
  801165:	75 e7                	jne    80114e <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801167:	a1 04 40 80 00       	mov    0x804004,%eax
  80116c:	8b 40 48             	mov    0x48(%eax),%eax
  80116f:	83 ec 04             	sub    $0x4,%esp
  801172:	51                   	push   %ecx
  801173:	50                   	push   %eax
  801174:	68 6c 2c 80 00       	push   $0x802c6c
  801179:	e8 33 f1 ff ff       	call   8002b1 <cprintf>
	*dev = 0;
  80117e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801181:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801187:	83 c4 10             	add    $0x10,%esp
  80118a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80118f:	c9                   	leave  
  801190:	c3                   	ret    

00801191 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801191:	55                   	push   %ebp
  801192:	89 e5                	mov    %esp,%ebp
  801194:	56                   	push   %esi
  801195:	53                   	push   %ebx
  801196:	83 ec 10             	sub    $0x10,%esp
  801199:	8b 75 08             	mov    0x8(%ebp),%esi
  80119c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80119f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011a2:	50                   	push   %eax
  8011a3:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8011a9:	c1 e8 0c             	shr    $0xc,%eax
  8011ac:	50                   	push   %eax
  8011ad:	e8 36 ff ff ff       	call   8010e8 <fd_lookup>
  8011b2:	83 c4 08             	add    $0x8,%esp
  8011b5:	85 c0                	test   %eax,%eax
  8011b7:	78 05                	js     8011be <fd_close+0x2d>
	    || fd != fd2)
  8011b9:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8011bc:	74 0c                	je     8011ca <fd_close+0x39>
		return (must_exist ? r : 0);
  8011be:	84 db                	test   %bl,%bl
  8011c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8011c5:	0f 44 c2             	cmove  %edx,%eax
  8011c8:	eb 41                	jmp    80120b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011ca:	83 ec 08             	sub    $0x8,%esp
  8011cd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011d0:	50                   	push   %eax
  8011d1:	ff 36                	pushl  (%esi)
  8011d3:	e8 66 ff ff ff       	call   80113e <dev_lookup>
  8011d8:	89 c3                	mov    %eax,%ebx
  8011da:	83 c4 10             	add    $0x10,%esp
  8011dd:	85 c0                	test   %eax,%eax
  8011df:	78 1a                	js     8011fb <fd_close+0x6a>
		if (dev->dev_close)
  8011e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011e4:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8011e7:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8011ec:	85 c0                	test   %eax,%eax
  8011ee:	74 0b                	je     8011fb <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8011f0:	83 ec 0c             	sub    $0xc,%esp
  8011f3:	56                   	push   %esi
  8011f4:	ff d0                	call   *%eax
  8011f6:	89 c3                	mov    %eax,%ebx
  8011f8:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8011fb:	83 ec 08             	sub    $0x8,%esp
  8011fe:	56                   	push   %esi
  8011ff:	6a 00                	push   $0x0
  801201:	e8 b8 fa ff ff       	call   800cbe <sys_page_unmap>
	return r;
  801206:	83 c4 10             	add    $0x10,%esp
  801209:	89 d8                	mov    %ebx,%eax
}
  80120b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80120e:	5b                   	pop    %ebx
  80120f:	5e                   	pop    %esi
  801210:	5d                   	pop    %ebp
  801211:	c3                   	ret    

00801212 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801212:	55                   	push   %ebp
  801213:	89 e5                	mov    %esp,%ebp
  801215:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801218:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80121b:	50                   	push   %eax
  80121c:	ff 75 08             	pushl  0x8(%ebp)
  80121f:	e8 c4 fe ff ff       	call   8010e8 <fd_lookup>
  801224:	83 c4 08             	add    $0x8,%esp
  801227:	85 c0                	test   %eax,%eax
  801229:	78 10                	js     80123b <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80122b:	83 ec 08             	sub    $0x8,%esp
  80122e:	6a 01                	push   $0x1
  801230:	ff 75 f4             	pushl  -0xc(%ebp)
  801233:	e8 59 ff ff ff       	call   801191 <fd_close>
  801238:	83 c4 10             	add    $0x10,%esp
}
  80123b:	c9                   	leave  
  80123c:	c3                   	ret    

0080123d <close_all>:

void
close_all(void)
{
  80123d:	55                   	push   %ebp
  80123e:	89 e5                	mov    %esp,%ebp
  801240:	53                   	push   %ebx
  801241:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801244:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801249:	83 ec 0c             	sub    $0xc,%esp
  80124c:	53                   	push   %ebx
  80124d:	e8 c0 ff ff ff       	call   801212 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801252:	83 c3 01             	add    $0x1,%ebx
  801255:	83 c4 10             	add    $0x10,%esp
  801258:	83 fb 20             	cmp    $0x20,%ebx
  80125b:	75 ec                	jne    801249 <close_all+0xc>
		close(i);
}
  80125d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801260:	c9                   	leave  
  801261:	c3                   	ret    

00801262 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801262:	55                   	push   %ebp
  801263:	89 e5                	mov    %esp,%ebp
  801265:	57                   	push   %edi
  801266:	56                   	push   %esi
  801267:	53                   	push   %ebx
  801268:	83 ec 2c             	sub    $0x2c,%esp
  80126b:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80126e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801271:	50                   	push   %eax
  801272:	ff 75 08             	pushl  0x8(%ebp)
  801275:	e8 6e fe ff ff       	call   8010e8 <fd_lookup>
  80127a:	83 c4 08             	add    $0x8,%esp
  80127d:	85 c0                	test   %eax,%eax
  80127f:	0f 88 c1 00 00 00    	js     801346 <dup+0xe4>
		return r;
	close(newfdnum);
  801285:	83 ec 0c             	sub    $0xc,%esp
  801288:	56                   	push   %esi
  801289:	e8 84 ff ff ff       	call   801212 <close>

	newfd = INDEX2FD(newfdnum);
  80128e:	89 f3                	mov    %esi,%ebx
  801290:	c1 e3 0c             	shl    $0xc,%ebx
  801293:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801299:	83 c4 04             	add    $0x4,%esp
  80129c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80129f:	e8 de fd ff ff       	call   801082 <fd2data>
  8012a4:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8012a6:	89 1c 24             	mov    %ebx,(%esp)
  8012a9:	e8 d4 fd ff ff       	call   801082 <fd2data>
  8012ae:	83 c4 10             	add    $0x10,%esp
  8012b1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012b4:	89 f8                	mov    %edi,%eax
  8012b6:	c1 e8 16             	shr    $0x16,%eax
  8012b9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012c0:	a8 01                	test   $0x1,%al
  8012c2:	74 37                	je     8012fb <dup+0x99>
  8012c4:	89 f8                	mov    %edi,%eax
  8012c6:	c1 e8 0c             	shr    $0xc,%eax
  8012c9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012d0:	f6 c2 01             	test   $0x1,%dl
  8012d3:	74 26                	je     8012fb <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012d5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012dc:	83 ec 0c             	sub    $0xc,%esp
  8012df:	25 07 0e 00 00       	and    $0xe07,%eax
  8012e4:	50                   	push   %eax
  8012e5:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012e8:	6a 00                	push   $0x0
  8012ea:	57                   	push   %edi
  8012eb:	6a 00                	push   $0x0
  8012ed:	e8 8a f9 ff ff       	call   800c7c <sys_page_map>
  8012f2:	89 c7                	mov    %eax,%edi
  8012f4:	83 c4 20             	add    $0x20,%esp
  8012f7:	85 c0                	test   %eax,%eax
  8012f9:	78 2e                	js     801329 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012fb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8012fe:	89 d0                	mov    %edx,%eax
  801300:	c1 e8 0c             	shr    $0xc,%eax
  801303:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80130a:	83 ec 0c             	sub    $0xc,%esp
  80130d:	25 07 0e 00 00       	and    $0xe07,%eax
  801312:	50                   	push   %eax
  801313:	53                   	push   %ebx
  801314:	6a 00                	push   $0x0
  801316:	52                   	push   %edx
  801317:	6a 00                	push   $0x0
  801319:	e8 5e f9 ff ff       	call   800c7c <sys_page_map>
  80131e:	89 c7                	mov    %eax,%edi
  801320:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801323:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801325:	85 ff                	test   %edi,%edi
  801327:	79 1d                	jns    801346 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801329:	83 ec 08             	sub    $0x8,%esp
  80132c:	53                   	push   %ebx
  80132d:	6a 00                	push   $0x0
  80132f:	e8 8a f9 ff ff       	call   800cbe <sys_page_unmap>
	sys_page_unmap(0, nva);
  801334:	83 c4 08             	add    $0x8,%esp
  801337:	ff 75 d4             	pushl  -0x2c(%ebp)
  80133a:	6a 00                	push   $0x0
  80133c:	e8 7d f9 ff ff       	call   800cbe <sys_page_unmap>
	return r;
  801341:	83 c4 10             	add    $0x10,%esp
  801344:	89 f8                	mov    %edi,%eax
}
  801346:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801349:	5b                   	pop    %ebx
  80134a:	5e                   	pop    %esi
  80134b:	5f                   	pop    %edi
  80134c:	5d                   	pop    %ebp
  80134d:	c3                   	ret    

0080134e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80134e:	55                   	push   %ebp
  80134f:	89 e5                	mov    %esp,%ebp
  801351:	53                   	push   %ebx
  801352:	83 ec 14             	sub    $0x14,%esp
  801355:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801358:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80135b:	50                   	push   %eax
  80135c:	53                   	push   %ebx
  80135d:	e8 86 fd ff ff       	call   8010e8 <fd_lookup>
  801362:	83 c4 08             	add    $0x8,%esp
  801365:	89 c2                	mov    %eax,%edx
  801367:	85 c0                	test   %eax,%eax
  801369:	78 6d                	js     8013d8 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80136b:	83 ec 08             	sub    $0x8,%esp
  80136e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801371:	50                   	push   %eax
  801372:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801375:	ff 30                	pushl  (%eax)
  801377:	e8 c2 fd ff ff       	call   80113e <dev_lookup>
  80137c:	83 c4 10             	add    $0x10,%esp
  80137f:	85 c0                	test   %eax,%eax
  801381:	78 4c                	js     8013cf <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801383:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801386:	8b 42 08             	mov    0x8(%edx),%eax
  801389:	83 e0 03             	and    $0x3,%eax
  80138c:	83 f8 01             	cmp    $0x1,%eax
  80138f:	75 21                	jne    8013b2 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801391:	a1 04 40 80 00       	mov    0x804004,%eax
  801396:	8b 40 48             	mov    0x48(%eax),%eax
  801399:	83 ec 04             	sub    $0x4,%esp
  80139c:	53                   	push   %ebx
  80139d:	50                   	push   %eax
  80139e:	68 ad 2c 80 00       	push   $0x802cad
  8013a3:	e8 09 ef ff ff       	call   8002b1 <cprintf>
		return -E_INVAL;
  8013a8:	83 c4 10             	add    $0x10,%esp
  8013ab:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013b0:	eb 26                	jmp    8013d8 <read+0x8a>
	}
	if (!dev->dev_read)
  8013b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013b5:	8b 40 08             	mov    0x8(%eax),%eax
  8013b8:	85 c0                	test   %eax,%eax
  8013ba:	74 17                	je     8013d3 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013bc:	83 ec 04             	sub    $0x4,%esp
  8013bf:	ff 75 10             	pushl  0x10(%ebp)
  8013c2:	ff 75 0c             	pushl  0xc(%ebp)
  8013c5:	52                   	push   %edx
  8013c6:	ff d0                	call   *%eax
  8013c8:	89 c2                	mov    %eax,%edx
  8013ca:	83 c4 10             	add    $0x10,%esp
  8013cd:	eb 09                	jmp    8013d8 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013cf:	89 c2                	mov    %eax,%edx
  8013d1:	eb 05                	jmp    8013d8 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8013d3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8013d8:	89 d0                	mov    %edx,%eax
  8013da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013dd:	c9                   	leave  
  8013de:	c3                   	ret    

008013df <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013df:	55                   	push   %ebp
  8013e0:	89 e5                	mov    %esp,%ebp
  8013e2:	57                   	push   %edi
  8013e3:	56                   	push   %esi
  8013e4:	53                   	push   %ebx
  8013e5:	83 ec 0c             	sub    $0xc,%esp
  8013e8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013eb:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013ee:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013f3:	eb 21                	jmp    801416 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013f5:	83 ec 04             	sub    $0x4,%esp
  8013f8:	89 f0                	mov    %esi,%eax
  8013fa:	29 d8                	sub    %ebx,%eax
  8013fc:	50                   	push   %eax
  8013fd:	89 d8                	mov    %ebx,%eax
  8013ff:	03 45 0c             	add    0xc(%ebp),%eax
  801402:	50                   	push   %eax
  801403:	57                   	push   %edi
  801404:	e8 45 ff ff ff       	call   80134e <read>
		if (m < 0)
  801409:	83 c4 10             	add    $0x10,%esp
  80140c:	85 c0                	test   %eax,%eax
  80140e:	78 10                	js     801420 <readn+0x41>
			return m;
		if (m == 0)
  801410:	85 c0                	test   %eax,%eax
  801412:	74 0a                	je     80141e <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801414:	01 c3                	add    %eax,%ebx
  801416:	39 f3                	cmp    %esi,%ebx
  801418:	72 db                	jb     8013f5 <readn+0x16>
  80141a:	89 d8                	mov    %ebx,%eax
  80141c:	eb 02                	jmp    801420 <readn+0x41>
  80141e:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801420:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801423:	5b                   	pop    %ebx
  801424:	5e                   	pop    %esi
  801425:	5f                   	pop    %edi
  801426:	5d                   	pop    %ebp
  801427:	c3                   	ret    

00801428 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801428:	55                   	push   %ebp
  801429:	89 e5                	mov    %esp,%ebp
  80142b:	53                   	push   %ebx
  80142c:	83 ec 14             	sub    $0x14,%esp
  80142f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801432:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801435:	50                   	push   %eax
  801436:	53                   	push   %ebx
  801437:	e8 ac fc ff ff       	call   8010e8 <fd_lookup>
  80143c:	83 c4 08             	add    $0x8,%esp
  80143f:	89 c2                	mov    %eax,%edx
  801441:	85 c0                	test   %eax,%eax
  801443:	78 68                	js     8014ad <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801445:	83 ec 08             	sub    $0x8,%esp
  801448:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80144b:	50                   	push   %eax
  80144c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80144f:	ff 30                	pushl  (%eax)
  801451:	e8 e8 fc ff ff       	call   80113e <dev_lookup>
  801456:	83 c4 10             	add    $0x10,%esp
  801459:	85 c0                	test   %eax,%eax
  80145b:	78 47                	js     8014a4 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80145d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801460:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801464:	75 21                	jne    801487 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801466:	a1 04 40 80 00       	mov    0x804004,%eax
  80146b:	8b 40 48             	mov    0x48(%eax),%eax
  80146e:	83 ec 04             	sub    $0x4,%esp
  801471:	53                   	push   %ebx
  801472:	50                   	push   %eax
  801473:	68 c9 2c 80 00       	push   $0x802cc9
  801478:	e8 34 ee ff ff       	call   8002b1 <cprintf>
		return -E_INVAL;
  80147d:	83 c4 10             	add    $0x10,%esp
  801480:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801485:	eb 26                	jmp    8014ad <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801487:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80148a:	8b 52 0c             	mov    0xc(%edx),%edx
  80148d:	85 d2                	test   %edx,%edx
  80148f:	74 17                	je     8014a8 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801491:	83 ec 04             	sub    $0x4,%esp
  801494:	ff 75 10             	pushl  0x10(%ebp)
  801497:	ff 75 0c             	pushl  0xc(%ebp)
  80149a:	50                   	push   %eax
  80149b:	ff d2                	call   *%edx
  80149d:	89 c2                	mov    %eax,%edx
  80149f:	83 c4 10             	add    $0x10,%esp
  8014a2:	eb 09                	jmp    8014ad <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014a4:	89 c2                	mov    %eax,%edx
  8014a6:	eb 05                	jmp    8014ad <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8014a8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8014ad:	89 d0                	mov    %edx,%eax
  8014af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014b2:	c9                   	leave  
  8014b3:	c3                   	ret    

008014b4 <seek>:

int
seek(int fdnum, off_t offset)
{
  8014b4:	55                   	push   %ebp
  8014b5:	89 e5                	mov    %esp,%ebp
  8014b7:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014ba:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014bd:	50                   	push   %eax
  8014be:	ff 75 08             	pushl  0x8(%ebp)
  8014c1:	e8 22 fc ff ff       	call   8010e8 <fd_lookup>
  8014c6:	83 c4 08             	add    $0x8,%esp
  8014c9:	85 c0                	test   %eax,%eax
  8014cb:	78 0e                	js     8014db <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8014cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014d0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014d3:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014d6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014db:	c9                   	leave  
  8014dc:	c3                   	ret    

008014dd <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8014dd:	55                   	push   %ebp
  8014de:	89 e5                	mov    %esp,%ebp
  8014e0:	53                   	push   %ebx
  8014e1:	83 ec 14             	sub    $0x14,%esp
  8014e4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014e7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014ea:	50                   	push   %eax
  8014eb:	53                   	push   %ebx
  8014ec:	e8 f7 fb ff ff       	call   8010e8 <fd_lookup>
  8014f1:	83 c4 08             	add    $0x8,%esp
  8014f4:	89 c2                	mov    %eax,%edx
  8014f6:	85 c0                	test   %eax,%eax
  8014f8:	78 65                	js     80155f <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014fa:	83 ec 08             	sub    $0x8,%esp
  8014fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801500:	50                   	push   %eax
  801501:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801504:	ff 30                	pushl  (%eax)
  801506:	e8 33 fc ff ff       	call   80113e <dev_lookup>
  80150b:	83 c4 10             	add    $0x10,%esp
  80150e:	85 c0                	test   %eax,%eax
  801510:	78 44                	js     801556 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801512:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801515:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801519:	75 21                	jne    80153c <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80151b:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801520:	8b 40 48             	mov    0x48(%eax),%eax
  801523:	83 ec 04             	sub    $0x4,%esp
  801526:	53                   	push   %ebx
  801527:	50                   	push   %eax
  801528:	68 8c 2c 80 00       	push   $0x802c8c
  80152d:	e8 7f ed ff ff       	call   8002b1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801532:	83 c4 10             	add    $0x10,%esp
  801535:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80153a:	eb 23                	jmp    80155f <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80153c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80153f:	8b 52 18             	mov    0x18(%edx),%edx
  801542:	85 d2                	test   %edx,%edx
  801544:	74 14                	je     80155a <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801546:	83 ec 08             	sub    $0x8,%esp
  801549:	ff 75 0c             	pushl  0xc(%ebp)
  80154c:	50                   	push   %eax
  80154d:	ff d2                	call   *%edx
  80154f:	89 c2                	mov    %eax,%edx
  801551:	83 c4 10             	add    $0x10,%esp
  801554:	eb 09                	jmp    80155f <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801556:	89 c2                	mov    %eax,%edx
  801558:	eb 05                	jmp    80155f <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80155a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80155f:	89 d0                	mov    %edx,%eax
  801561:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801564:	c9                   	leave  
  801565:	c3                   	ret    

00801566 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801566:	55                   	push   %ebp
  801567:	89 e5                	mov    %esp,%ebp
  801569:	53                   	push   %ebx
  80156a:	83 ec 14             	sub    $0x14,%esp
  80156d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801570:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801573:	50                   	push   %eax
  801574:	ff 75 08             	pushl  0x8(%ebp)
  801577:	e8 6c fb ff ff       	call   8010e8 <fd_lookup>
  80157c:	83 c4 08             	add    $0x8,%esp
  80157f:	89 c2                	mov    %eax,%edx
  801581:	85 c0                	test   %eax,%eax
  801583:	78 58                	js     8015dd <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801585:	83 ec 08             	sub    $0x8,%esp
  801588:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80158b:	50                   	push   %eax
  80158c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80158f:	ff 30                	pushl  (%eax)
  801591:	e8 a8 fb ff ff       	call   80113e <dev_lookup>
  801596:	83 c4 10             	add    $0x10,%esp
  801599:	85 c0                	test   %eax,%eax
  80159b:	78 37                	js     8015d4 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80159d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015a0:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015a4:	74 32                	je     8015d8 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015a6:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015a9:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015b0:	00 00 00 
	stat->st_isdir = 0;
  8015b3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015ba:	00 00 00 
	stat->st_dev = dev;
  8015bd:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015c3:	83 ec 08             	sub    $0x8,%esp
  8015c6:	53                   	push   %ebx
  8015c7:	ff 75 f0             	pushl  -0x10(%ebp)
  8015ca:	ff 50 14             	call   *0x14(%eax)
  8015cd:	89 c2                	mov    %eax,%edx
  8015cf:	83 c4 10             	add    $0x10,%esp
  8015d2:	eb 09                	jmp    8015dd <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015d4:	89 c2                	mov    %eax,%edx
  8015d6:	eb 05                	jmp    8015dd <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8015d8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8015dd:	89 d0                	mov    %edx,%eax
  8015df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015e2:	c9                   	leave  
  8015e3:	c3                   	ret    

008015e4 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015e4:	55                   	push   %ebp
  8015e5:	89 e5                	mov    %esp,%ebp
  8015e7:	56                   	push   %esi
  8015e8:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015e9:	83 ec 08             	sub    $0x8,%esp
  8015ec:	6a 00                	push   $0x0
  8015ee:	ff 75 08             	pushl  0x8(%ebp)
  8015f1:	e8 0c 02 00 00       	call   801802 <open>
  8015f6:	89 c3                	mov    %eax,%ebx
  8015f8:	83 c4 10             	add    $0x10,%esp
  8015fb:	85 c0                	test   %eax,%eax
  8015fd:	78 1b                	js     80161a <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8015ff:	83 ec 08             	sub    $0x8,%esp
  801602:	ff 75 0c             	pushl  0xc(%ebp)
  801605:	50                   	push   %eax
  801606:	e8 5b ff ff ff       	call   801566 <fstat>
  80160b:	89 c6                	mov    %eax,%esi
	close(fd);
  80160d:	89 1c 24             	mov    %ebx,(%esp)
  801610:	e8 fd fb ff ff       	call   801212 <close>
	return r;
  801615:	83 c4 10             	add    $0x10,%esp
  801618:	89 f0                	mov    %esi,%eax
}
  80161a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80161d:	5b                   	pop    %ebx
  80161e:	5e                   	pop    %esi
  80161f:	5d                   	pop    %ebp
  801620:	c3                   	ret    

00801621 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801621:	55                   	push   %ebp
  801622:	89 e5                	mov    %esp,%ebp
  801624:	56                   	push   %esi
  801625:	53                   	push   %ebx
  801626:	89 c6                	mov    %eax,%esi
  801628:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80162a:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801631:	75 12                	jne    801645 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801633:	83 ec 0c             	sub    $0xc,%esp
  801636:	6a 01                	push   $0x1
  801638:	e8 7e 0e 00 00       	call   8024bb <ipc_find_env>
  80163d:	a3 00 40 80 00       	mov    %eax,0x804000
  801642:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801645:	6a 07                	push   $0x7
  801647:	68 00 50 80 00       	push   $0x805000
  80164c:	56                   	push   %esi
  80164d:	ff 35 00 40 80 00    	pushl  0x804000
  801653:	e8 0f 0e 00 00       	call   802467 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801658:	83 c4 0c             	add    $0xc,%esp
  80165b:	6a 00                	push   $0x0
  80165d:	53                   	push   %ebx
  80165e:	6a 00                	push   $0x0
  801660:	e8 99 0d 00 00       	call   8023fe <ipc_recv>
}
  801665:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801668:	5b                   	pop    %ebx
  801669:	5e                   	pop    %esi
  80166a:	5d                   	pop    %ebp
  80166b:	c3                   	ret    

0080166c <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80166c:	55                   	push   %ebp
  80166d:	89 e5                	mov    %esp,%ebp
  80166f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801672:	8b 45 08             	mov    0x8(%ebp),%eax
  801675:	8b 40 0c             	mov    0xc(%eax),%eax
  801678:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80167d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801680:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801685:	ba 00 00 00 00       	mov    $0x0,%edx
  80168a:	b8 02 00 00 00       	mov    $0x2,%eax
  80168f:	e8 8d ff ff ff       	call   801621 <fsipc>
}
  801694:	c9                   	leave  
  801695:	c3                   	ret    

00801696 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801696:	55                   	push   %ebp
  801697:	89 e5                	mov    %esp,%ebp
  801699:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80169c:	8b 45 08             	mov    0x8(%ebp),%eax
  80169f:	8b 40 0c             	mov    0xc(%eax),%eax
  8016a2:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8016ac:	b8 06 00 00 00       	mov    $0x6,%eax
  8016b1:	e8 6b ff ff ff       	call   801621 <fsipc>
}
  8016b6:	c9                   	leave  
  8016b7:	c3                   	ret    

008016b8 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016b8:	55                   	push   %ebp
  8016b9:	89 e5                	mov    %esp,%ebp
  8016bb:	53                   	push   %ebx
  8016bc:	83 ec 04             	sub    $0x4,%esp
  8016bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c5:	8b 40 0c             	mov    0xc(%eax),%eax
  8016c8:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8016d2:	b8 05 00 00 00       	mov    $0x5,%eax
  8016d7:	e8 45 ff ff ff       	call   801621 <fsipc>
  8016dc:	85 c0                	test   %eax,%eax
  8016de:	78 2c                	js     80170c <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016e0:	83 ec 08             	sub    $0x8,%esp
  8016e3:	68 00 50 80 00       	push   $0x805000
  8016e8:	53                   	push   %ebx
  8016e9:	e8 48 f1 ff ff       	call   800836 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016ee:	a1 80 50 80 00       	mov    0x805080,%eax
  8016f3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016f9:	a1 84 50 80 00       	mov    0x805084,%eax
  8016fe:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801704:	83 c4 10             	add    $0x10,%esp
  801707:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80170c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80170f:	c9                   	leave  
  801710:	c3                   	ret    

00801711 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801711:	55                   	push   %ebp
  801712:	89 e5                	mov    %esp,%ebp
  801714:	53                   	push   %ebx
  801715:	83 ec 08             	sub    $0x8,%esp
  801718:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80171b:	8b 55 08             	mov    0x8(%ebp),%edx
  80171e:	8b 52 0c             	mov    0xc(%edx),%edx
  801721:	89 15 00 50 80 00    	mov    %edx,0x805000
  801727:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80172c:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  801731:	0f 46 d8             	cmovbe %eax,%ebx
	
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  801734:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  80173a:	53                   	push   %ebx
  80173b:	ff 75 0c             	pushl  0xc(%ebp)
  80173e:	68 08 50 80 00       	push   $0x805008
  801743:	e8 80 f2 ff ff       	call   8009c8 <memmove>

	
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) 
  801748:	ba 00 00 00 00       	mov    $0x0,%edx
  80174d:	b8 04 00 00 00       	mov    $0x4,%eax
  801752:	e8 ca fe ff ff       	call   801621 <fsipc>
  801757:	83 c4 10             	add    $0x10,%esp
  80175a:	85 c0                	test   %eax,%eax
  80175c:	78 1d                	js     80177b <devfile_write+0x6a>
		return r;
	assert(r <= n_real); 
  80175e:	39 d8                	cmp    %ebx,%eax
  801760:	76 19                	jbe    80177b <devfile_write+0x6a>
  801762:	68 f8 2c 80 00       	push   $0x802cf8
  801767:	68 04 2d 80 00       	push   $0x802d04
  80176c:	68 a3 00 00 00       	push   $0xa3
  801771:	68 19 2d 80 00       	push   $0x802d19
  801776:	e8 5d ea ff ff       	call   8001d8 <_panic>
	return r;
}
  80177b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80177e:	c9                   	leave  
  80177f:	c3                   	ret    

00801780 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801780:	55                   	push   %ebp
  801781:	89 e5                	mov    %esp,%ebp
  801783:	56                   	push   %esi
  801784:	53                   	push   %ebx
  801785:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801788:	8b 45 08             	mov    0x8(%ebp),%eax
  80178b:	8b 40 0c             	mov    0xc(%eax),%eax
  80178e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801793:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801799:	ba 00 00 00 00       	mov    $0x0,%edx
  80179e:	b8 03 00 00 00       	mov    $0x3,%eax
  8017a3:	e8 79 fe ff ff       	call   801621 <fsipc>
  8017a8:	89 c3                	mov    %eax,%ebx
  8017aa:	85 c0                	test   %eax,%eax
  8017ac:	78 4b                	js     8017f9 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8017ae:	39 c6                	cmp    %eax,%esi
  8017b0:	73 16                	jae    8017c8 <devfile_read+0x48>
  8017b2:	68 24 2d 80 00       	push   $0x802d24
  8017b7:	68 04 2d 80 00       	push   $0x802d04
  8017bc:	6a 7c                	push   $0x7c
  8017be:	68 19 2d 80 00       	push   $0x802d19
  8017c3:	e8 10 ea ff ff       	call   8001d8 <_panic>
	assert(r <= PGSIZE);
  8017c8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017cd:	7e 16                	jle    8017e5 <devfile_read+0x65>
  8017cf:	68 2b 2d 80 00       	push   $0x802d2b
  8017d4:	68 04 2d 80 00       	push   $0x802d04
  8017d9:	6a 7d                	push   $0x7d
  8017db:	68 19 2d 80 00       	push   $0x802d19
  8017e0:	e8 f3 e9 ff ff       	call   8001d8 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017e5:	83 ec 04             	sub    $0x4,%esp
  8017e8:	50                   	push   %eax
  8017e9:	68 00 50 80 00       	push   $0x805000
  8017ee:	ff 75 0c             	pushl  0xc(%ebp)
  8017f1:	e8 d2 f1 ff ff       	call   8009c8 <memmove>
	return r;
  8017f6:	83 c4 10             	add    $0x10,%esp
}
  8017f9:	89 d8                	mov    %ebx,%eax
  8017fb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017fe:	5b                   	pop    %ebx
  8017ff:	5e                   	pop    %esi
  801800:	5d                   	pop    %ebp
  801801:	c3                   	ret    

00801802 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801802:	55                   	push   %ebp
  801803:	89 e5                	mov    %esp,%ebp
  801805:	53                   	push   %ebx
  801806:	83 ec 20             	sub    $0x20,%esp
  801809:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80180c:	53                   	push   %ebx
  80180d:	e8 eb ef ff ff       	call   8007fd <strlen>
  801812:	83 c4 10             	add    $0x10,%esp
  801815:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80181a:	7f 67                	jg     801883 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80181c:	83 ec 0c             	sub    $0xc,%esp
  80181f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801822:	50                   	push   %eax
  801823:	e8 71 f8 ff ff       	call   801099 <fd_alloc>
  801828:	83 c4 10             	add    $0x10,%esp
		return r;
  80182b:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80182d:	85 c0                	test   %eax,%eax
  80182f:	78 57                	js     801888 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801831:	83 ec 08             	sub    $0x8,%esp
  801834:	53                   	push   %ebx
  801835:	68 00 50 80 00       	push   $0x805000
  80183a:	e8 f7 ef ff ff       	call   800836 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80183f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801842:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801847:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80184a:	b8 01 00 00 00       	mov    $0x1,%eax
  80184f:	e8 cd fd ff ff       	call   801621 <fsipc>
  801854:	89 c3                	mov    %eax,%ebx
  801856:	83 c4 10             	add    $0x10,%esp
  801859:	85 c0                	test   %eax,%eax
  80185b:	79 14                	jns    801871 <open+0x6f>
		fd_close(fd, 0);
  80185d:	83 ec 08             	sub    $0x8,%esp
  801860:	6a 00                	push   $0x0
  801862:	ff 75 f4             	pushl  -0xc(%ebp)
  801865:	e8 27 f9 ff ff       	call   801191 <fd_close>
		return r;
  80186a:	83 c4 10             	add    $0x10,%esp
  80186d:	89 da                	mov    %ebx,%edx
  80186f:	eb 17                	jmp    801888 <open+0x86>
	}

	return fd2num(fd);
  801871:	83 ec 0c             	sub    $0xc,%esp
  801874:	ff 75 f4             	pushl  -0xc(%ebp)
  801877:	e8 f6 f7 ff ff       	call   801072 <fd2num>
  80187c:	89 c2                	mov    %eax,%edx
  80187e:	83 c4 10             	add    $0x10,%esp
  801881:	eb 05                	jmp    801888 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801883:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801888:	89 d0                	mov    %edx,%eax
  80188a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80188d:	c9                   	leave  
  80188e:	c3                   	ret    

0080188f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80188f:	55                   	push   %ebp
  801890:	89 e5                	mov    %esp,%ebp
  801892:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801895:	ba 00 00 00 00       	mov    $0x0,%edx
  80189a:	b8 08 00 00 00       	mov    $0x8,%eax
  80189f:	e8 7d fd ff ff       	call   801621 <fsipc>
}
  8018a4:	c9                   	leave  
  8018a5:	c3                   	ret    

008018a6 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8018a6:	55                   	push   %ebp
  8018a7:	89 e5                	mov    %esp,%ebp
  8018a9:	57                   	push   %edi
  8018aa:	56                   	push   %esi
  8018ab:	53                   	push   %ebx
  8018ac:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8018b2:	6a 00                	push   $0x0
  8018b4:	ff 75 08             	pushl  0x8(%ebp)
  8018b7:	e8 46 ff ff ff       	call   801802 <open>
  8018bc:	89 c7                	mov    %eax,%edi
  8018be:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  8018c4:	83 c4 10             	add    $0x10,%esp
  8018c7:	85 c0                	test   %eax,%eax
  8018c9:	0f 88 ae 04 00 00    	js     801d7d <spawn+0x4d7>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8018cf:	83 ec 04             	sub    $0x4,%esp
  8018d2:	68 00 02 00 00       	push   $0x200
  8018d7:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8018dd:	50                   	push   %eax
  8018de:	57                   	push   %edi
  8018df:	e8 fb fa ff ff       	call   8013df <readn>
  8018e4:	83 c4 10             	add    $0x10,%esp
  8018e7:	3d 00 02 00 00       	cmp    $0x200,%eax
  8018ec:	75 0c                	jne    8018fa <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  8018ee:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8018f5:	45 4c 46 
  8018f8:	74 33                	je     80192d <spawn+0x87>
		close(fd);
  8018fa:	83 ec 0c             	sub    $0xc,%esp
  8018fd:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801903:	e8 0a f9 ff ff       	call   801212 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801908:	83 c4 0c             	add    $0xc,%esp
  80190b:	68 7f 45 4c 46       	push   $0x464c457f
  801910:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801916:	68 37 2d 80 00       	push   $0x802d37
  80191b:	e8 91 e9 ff ff       	call   8002b1 <cprintf>
		return -E_NOT_EXEC;
  801920:	83 c4 10             	add    $0x10,%esp
  801923:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801928:	e9 b0 04 00 00       	jmp    801ddd <spawn+0x537>
  80192d:	b8 07 00 00 00       	mov    $0x7,%eax
  801932:	cd 30                	int    $0x30
  801934:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  80193a:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801940:	85 c0                	test   %eax,%eax
  801942:	0f 88 3d 04 00 00    	js     801d85 <spawn+0x4df>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801948:	89 c6                	mov    %eax,%esi
  80194a:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801950:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801953:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801959:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  80195f:	b9 11 00 00 00       	mov    $0x11,%ecx
  801964:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801966:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  80196c:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801972:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801977:	be 00 00 00 00       	mov    $0x0,%esi
  80197c:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80197f:	eb 13                	jmp    801994 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801981:	83 ec 0c             	sub    $0xc,%esp
  801984:	50                   	push   %eax
  801985:	e8 73 ee ff ff       	call   8007fd <strlen>
  80198a:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80198e:	83 c3 01             	add    $0x1,%ebx
  801991:	83 c4 10             	add    $0x10,%esp
  801994:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  80199b:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  80199e:	85 c0                	test   %eax,%eax
  8019a0:	75 df                	jne    801981 <spawn+0xdb>
  8019a2:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  8019a8:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8019ae:	bf 00 10 40 00       	mov    $0x401000,%edi
  8019b3:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  8019b5:	89 fa                	mov    %edi,%edx
  8019b7:	83 e2 fc             	and    $0xfffffffc,%edx
  8019ba:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  8019c1:	29 c2                	sub    %eax,%edx
  8019c3:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8019c9:	8d 42 f8             	lea    -0x8(%edx),%eax
  8019cc:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8019d1:	0f 86 be 03 00 00    	jbe    801d95 <spawn+0x4ef>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8019d7:	83 ec 04             	sub    $0x4,%esp
  8019da:	6a 07                	push   $0x7
  8019dc:	68 00 00 40 00       	push   $0x400000
  8019e1:	6a 00                	push   $0x0
  8019e3:	e8 51 f2 ff ff       	call   800c39 <sys_page_alloc>
  8019e8:	83 c4 10             	add    $0x10,%esp
  8019eb:	85 c0                	test   %eax,%eax
  8019ed:	0f 88 a9 03 00 00    	js     801d9c <spawn+0x4f6>
  8019f3:	be 00 00 00 00       	mov    $0x0,%esi
  8019f8:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  8019fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a01:	eb 30                	jmp    801a33 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801a03:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801a09:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801a0f:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801a12:	83 ec 08             	sub    $0x8,%esp
  801a15:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801a18:	57                   	push   %edi
  801a19:	e8 18 ee ff ff       	call   800836 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801a1e:	83 c4 04             	add    $0x4,%esp
  801a21:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801a24:	e8 d4 ed ff ff       	call   8007fd <strlen>
  801a29:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801a2d:	83 c6 01             	add    $0x1,%esi
  801a30:	83 c4 10             	add    $0x10,%esp
  801a33:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801a39:	7f c8                	jg     801a03 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801a3b:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801a41:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801a47:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801a4e:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801a54:	74 19                	je     801a6f <spawn+0x1c9>
  801a56:	68 94 2d 80 00       	push   $0x802d94
  801a5b:	68 04 2d 80 00       	push   $0x802d04
  801a60:	68 f2 00 00 00       	push   $0xf2
  801a65:	68 51 2d 80 00       	push   $0x802d51
  801a6a:	e8 69 e7 ff ff       	call   8001d8 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801a6f:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801a75:	89 f8                	mov    %edi,%eax
  801a77:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801a7c:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801a7f:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801a85:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801a88:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801a8e:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801a94:	83 ec 0c             	sub    $0xc,%esp
  801a97:	6a 07                	push   $0x7
  801a99:	68 00 d0 bf ee       	push   $0xeebfd000
  801a9e:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801aa4:	68 00 00 40 00       	push   $0x400000
  801aa9:	6a 00                	push   $0x0
  801aab:	e8 cc f1 ff ff       	call   800c7c <sys_page_map>
  801ab0:	89 c3                	mov    %eax,%ebx
  801ab2:	83 c4 20             	add    $0x20,%esp
  801ab5:	85 c0                	test   %eax,%eax
  801ab7:	0f 88 0e 03 00 00    	js     801dcb <spawn+0x525>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801abd:	83 ec 08             	sub    $0x8,%esp
  801ac0:	68 00 00 40 00       	push   $0x400000
  801ac5:	6a 00                	push   $0x0
  801ac7:	e8 f2 f1 ff ff       	call   800cbe <sys_page_unmap>
  801acc:	89 c3                	mov    %eax,%ebx
  801ace:	83 c4 10             	add    $0x10,%esp
  801ad1:	85 c0                	test   %eax,%eax
  801ad3:	0f 88 f2 02 00 00    	js     801dcb <spawn+0x525>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801ad9:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801adf:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801ae6:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801aec:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801af3:	00 00 00 
  801af6:	e9 88 01 00 00       	jmp    801c83 <spawn+0x3dd>
		if (ph->p_type != ELF_PROG_LOAD)
  801afb:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801b01:	83 38 01             	cmpl   $0x1,(%eax)
  801b04:	0f 85 6b 01 00 00    	jne    801c75 <spawn+0x3cf>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801b0a:	89 c7                	mov    %eax,%edi
  801b0c:	8b 40 18             	mov    0x18(%eax),%eax
  801b0f:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801b15:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801b18:	83 f8 01             	cmp    $0x1,%eax
  801b1b:	19 c0                	sbb    %eax,%eax
  801b1d:	83 e0 fe             	and    $0xfffffffe,%eax
  801b20:	83 c0 07             	add    $0x7,%eax
  801b23:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801b29:	89 f8                	mov    %edi,%eax
  801b2b:	8b 7f 04             	mov    0x4(%edi),%edi
  801b2e:	89 f9                	mov    %edi,%ecx
  801b30:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801b36:	8b 78 10             	mov    0x10(%eax),%edi
  801b39:	8b 50 14             	mov    0x14(%eax),%edx
  801b3c:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  801b42:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801b45:	89 f0                	mov    %esi,%eax
  801b47:	25 ff 0f 00 00       	and    $0xfff,%eax
  801b4c:	74 14                	je     801b62 <spawn+0x2bc>
		va -= i;
  801b4e:	29 c6                	sub    %eax,%esi
		memsz += i;
  801b50:	01 c2                	add    %eax,%edx
  801b52:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  801b58:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801b5a:	29 c1                	sub    %eax,%ecx
  801b5c:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801b62:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b67:	e9 f7 00 00 00       	jmp    801c63 <spawn+0x3bd>
		if (i >= filesz) {
  801b6c:	39 df                	cmp    %ebx,%edi
  801b6e:	77 27                	ja     801b97 <spawn+0x2f1>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801b70:	83 ec 04             	sub    $0x4,%esp
  801b73:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801b79:	56                   	push   %esi
  801b7a:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801b80:	e8 b4 f0 ff ff       	call   800c39 <sys_page_alloc>
  801b85:	83 c4 10             	add    $0x10,%esp
  801b88:	85 c0                	test   %eax,%eax
  801b8a:	0f 89 c7 00 00 00    	jns    801c57 <spawn+0x3b1>
  801b90:	89 c3                	mov    %eax,%ebx
  801b92:	e9 13 02 00 00       	jmp    801daa <spawn+0x504>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801b97:	83 ec 04             	sub    $0x4,%esp
  801b9a:	6a 07                	push   $0x7
  801b9c:	68 00 00 40 00       	push   $0x400000
  801ba1:	6a 00                	push   $0x0
  801ba3:	e8 91 f0 ff ff       	call   800c39 <sys_page_alloc>
  801ba8:	83 c4 10             	add    $0x10,%esp
  801bab:	85 c0                	test   %eax,%eax
  801bad:	0f 88 ed 01 00 00    	js     801da0 <spawn+0x4fa>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801bb3:	83 ec 08             	sub    $0x8,%esp
  801bb6:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801bbc:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801bc2:	50                   	push   %eax
  801bc3:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801bc9:	e8 e6 f8 ff ff       	call   8014b4 <seek>
  801bce:	83 c4 10             	add    $0x10,%esp
  801bd1:	85 c0                	test   %eax,%eax
  801bd3:	0f 88 cb 01 00 00    	js     801da4 <spawn+0x4fe>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801bd9:	83 ec 04             	sub    $0x4,%esp
  801bdc:	89 f8                	mov    %edi,%eax
  801bde:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801be4:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801be9:	ba 00 10 00 00       	mov    $0x1000,%edx
  801bee:	0f 47 c2             	cmova  %edx,%eax
  801bf1:	50                   	push   %eax
  801bf2:	68 00 00 40 00       	push   $0x400000
  801bf7:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801bfd:	e8 dd f7 ff ff       	call   8013df <readn>
  801c02:	83 c4 10             	add    $0x10,%esp
  801c05:	85 c0                	test   %eax,%eax
  801c07:	0f 88 9b 01 00 00    	js     801da8 <spawn+0x502>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801c0d:	83 ec 0c             	sub    $0xc,%esp
  801c10:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801c16:	56                   	push   %esi
  801c17:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801c1d:	68 00 00 40 00       	push   $0x400000
  801c22:	6a 00                	push   $0x0
  801c24:	e8 53 f0 ff ff       	call   800c7c <sys_page_map>
  801c29:	83 c4 20             	add    $0x20,%esp
  801c2c:	85 c0                	test   %eax,%eax
  801c2e:	79 15                	jns    801c45 <spawn+0x39f>
				panic("spawn: sys_page_map data: %e", r);
  801c30:	50                   	push   %eax
  801c31:	68 5d 2d 80 00       	push   $0x802d5d
  801c36:	68 25 01 00 00       	push   $0x125
  801c3b:	68 51 2d 80 00       	push   $0x802d51
  801c40:	e8 93 e5 ff ff       	call   8001d8 <_panic>
			sys_page_unmap(0, UTEMP);
  801c45:	83 ec 08             	sub    $0x8,%esp
  801c48:	68 00 00 40 00       	push   $0x400000
  801c4d:	6a 00                	push   $0x0
  801c4f:	e8 6a f0 ff ff       	call   800cbe <sys_page_unmap>
  801c54:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801c57:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801c5d:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801c63:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801c69:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  801c6f:	0f 87 f7 fe ff ff    	ja     801b6c <spawn+0x2c6>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801c75:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801c7c:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801c83:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801c8a:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801c90:	0f 8c 65 fe ff ff    	jl     801afb <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801c96:	83 ec 0c             	sub    $0xc,%esp
  801c99:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801c9f:	e8 6e f5 ff ff       	call   801212 <close>
  801ca4:	83 c4 10             	add    $0x10,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	uintptr_t i;
	for (i = 0; i < USTACKTOP; i += PGSIZE){
  801ca7:	bb 00 00 00 00       	mov    $0x0,%ebx
  801cac:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[PGNUM(i)] & PTE_P) && (uvpt[PGNUM(i)] & PTE_U) && (uvpt[PGNUM(i)] & PTE_SHARE)){
  801cb2:	89 d8                	mov    %ebx,%eax
  801cb4:	c1 e8 16             	shr    $0x16,%eax
  801cb7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801cbe:	a8 01                	test   $0x1,%al
  801cc0:	74 46                	je     801d08 <spawn+0x462>
  801cc2:	89 d8                	mov    %ebx,%eax
  801cc4:	c1 e8 0c             	shr    $0xc,%eax
  801cc7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801cce:	f6 c2 01             	test   $0x1,%dl
  801cd1:	74 35                	je     801d08 <spawn+0x462>
  801cd3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801cda:	f6 c2 04             	test   $0x4,%dl
  801cdd:	74 29                	je     801d08 <spawn+0x462>
  801cdf:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801ce6:	f6 c6 04             	test   $0x4,%dh
  801ce9:	74 1d                	je     801d08 <spawn+0x462>
			sys_page_map(0, (void*)i,child, (void*)i,(uvpt[PGNUM(i)] & PTE_SYSCALL));
  801ceb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801cf2:	83 ec 0c             	sub    $0xc,%esp
  801cf5:	25 07 0e 00 00       	and    $0xe07,%eax
  801cfa:	50                   	push   %eax
  801cfb:	53                   	push   %ebx
  801cfc:	56                   	push   %esi
  801cfd:	53                   	push   %ebx
  801cfe:	6a 00                	push   $0x0
  801d00:	e8 77 ef ff ff       	call   800c7c <sys_page_map>
  801d05:	83 c4 20             	add    $0x20,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	uintptr_t i;
	for (i = 0; i < USTACKTOP; i += PGSIZE){
  801d08:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801d0e:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801d14:	75 9c                	jne    801cb2 <spawn+0x40c>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801d16:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801d1d:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801d20:	83 ec 08             	sub    $0x8,%esp
  801d23:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801d29:	50                   	push   %eax
  801d2a:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801d30:	e8 0d f0 ff ff       	call   800d42 <sys_env_set_trapframe>
  801d35:	83 c4 10             	add    $0x10,%esp
  801d38:	85 c0                	test   %eax,%eax
  801d3a:	79 15                	jns    801d51 <spawn+0x4ab>
		panic("sys_env_set_trapframe: %e", r);
  801d3c:	50                   	push   %eax
  801d3d:	68 7a 2d 80 00       	push   $0x802d7a
  801d42:	68 86 00 00 00       	push   $0x86
  801d47:	68 51 2d 80 00       	push   $0x802d51
  801d4c:	e8 87 e4 ff ff       	call   8001d8 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801d51:	83 ec 08             	sub    $0x8,%esp
  801d54:	6a 02                	push   $0x2
  801d56:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801d5c:	e8 9f ef ff ff       	call   800d00 <sys_env_set_status>
  801d61:	83 c4 10             	add    $0x10,%esp
  801d64:	85 c0                	test   %eax,%eax
  801d66:	79 25                	jns    801d8d <spawn+0x4e7>
		panic("sys_env_set_status: %e", r);
  801d68:	50                   	push   %eax
  801d69:	68 09 2c 80 00       	push   $0x802c09
  801d6e:	68 89 00 00 00       	push   $0x89
  801d73:	68 51 2d 80 00       	push   $0x802d51
  801d78:	e8 5b e4 ff ff       	call   8001d8 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801d7d:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801d83:	eb 58                	jmp    801ddd <spawn+0x537>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801d85:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801d8b:	eb 50                	jmp    801ddd <spawn+0x537>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801d8d:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801d93:	eb 48                	jmp    801ddd <spawn+0x537>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801d95:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801d9a:	eb 41                	jmp    801ddd <spawn+0x537>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801d9c:	89 c3                	mov    %eax,%ebx
  801d9e:	eb 3d                	jmp    801ddd <spawn+0x537>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801da0:	89 c3                	mov    %eax,%ebx
  801da2:	eb 06                	jmp    801daa <spawn+0x504>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801da4:	89 c3                	mov    %eax,%ebx
  801da6:	eb 02                	jmp    801daa <spawn+0x504>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801da8:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801daa:	83 ec 0c             	sub    $0xc,%esp
  801dad:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801db3:	e8 02 ee ff ff       	call   800bba <sys_env_destroy>
	close(fd);
  801db8:	83 c4 04             	add    $0x4,%esp
  801dbb:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801dc1:	e8 4c f4 ff ff       	call   801212 <close>
	return r;
  801dc6:	83 c4 10             	add    $0x10,%esp
  801dc9:	eb 12                	jmp    801ddd <spawn+0x537>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801dcb:	83 ec 08             	sub    $0x8,%esp
  801dce:	68 00 00 40 00       	push   $0x400000
  801dd3:	6a 00                	push   $0x0
  801dd5:	e8 e4 ee ff ff       	call   800cbe <sys_page_unmap>
  801dda:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801ddd:	89 d8                	mov    %ebx,%eax
  801ddf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801de2:	5b                   	pop    %ebx
  801de3:	5e                   	pop    %esi
  801de4:	5f                   	pop    %edi
  801de5:	5d                   	pop    %ebp
  801de6:	c3                   	ret    

00801de7 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801de7:	55                   	push   %ebp
  801de8:	89 e5                	mov    %esp,%ebp
  801dea:	56                   	push   %esi
  801deb:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801dec:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801def:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801df4:	eb 03                	jmp    801df9 <spawnl+0x12>
		argc++;
  801df6:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801df9:	83 c2 04             	add    $0x4,%edx
  801dfc:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801e00:	75 f4                	jne    801df6 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801e02:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801e09:	83 e2 f0             	and    $0xfffffff0,%edx
  801e0c:	29 d4                	sub    %edx,%esp
  801e0e:	8d 54 24 03          	lea    0x3(%esp),%edx
  801e12:	c1 ea 02             	shr    $0x2,%edx
  801e15:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801e1c:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801e1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e21:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801e28:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801e2f:	00 
  801e30:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801e32:	b8 00 00 00 00       	mov    $0x0,%eax
  801e37:	eb 0a                	jmp    801e43 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801e39:	83 c0 01             	add    $0x1,%eax
  801e3c:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801e40:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801e43:	39 d0                	cmp    %edx,%eax
  801e45:	75 f2                	jne    801e39 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801e47:	83 ec 08             	sub    $0x8,%esp
  801e4a:	56                   	push   %esi
  801e4b:	ff 75 08             	pushl  0x8(%ebp)
  801e4e:	e8 53 fa ff ff       	call   8018a6 <spawn>
}
  801e53:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e56:	5b                   	pop    %ebx
  801e57:	5e                   	pop    %esi
  801e58:	5d                   	pop    %ebp
  801e59:	c3                   	ret    

00801e5a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e5a:	55                   	push   %ebp
  801e5b:	89 e5                	mov    %esp,%ebp
  801e5d:	56                   	push   %esi
  801e5e:	53                   	push   %ebx
  801e5f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e62:	83 ec 0c             	sub    $0xc,%esp
  801e65:	ff 75 08             	pushl  0x8(%ebp)
  801e68:	e8 15 f2 ff ff       	call   801082 <fd2data>
  801e6d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801e6f:	83 c4 08             	add    $0x8,%esp
  801e72:	68 bc 2d 80 00       	push   $0x802dbc
  801e77:	53                   	push   %ebx
  801e78:	e8 b9 e9 ff ff       	call   800836 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e7d:	8b 46 04             	mov    0x4(%esi),%eax
  801e80:	2b 06                	sub    (%esi),%eax
  801e82:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801e88:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801e8f:	00 00 00 
	stat->st_dev = &devpipe;
  801e92:	c7 83 88 00 00 00 28 	movl   $0x803028,0x88(%ebx)
  801e99:	30 80 00 
	return 0;
}
  801e9c:	b8 00 00 00 00       	mov    $0x0,%eax
  801ea1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ea4:	5b                   	pop    %ebx
  801ea5:	5e                   	pop    %esi
  801ea6:	5d                   	pop    %ebp
  801ea7:	c3                   	ret    

00801ea8 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ea8:	55                   	push   %ebp
  801ea9:	89 e5                	mov    %esp,%ebp
  801eab:	53                   	push   %ebx
  801eac:	83 ec 0c             	sub    $0xc,%esp
  801eaf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801eb2:	53                   	push   %ebx
  801eb3:	6a 00                	push   $0x0
  801eb5:	e8 04 ee ff ff       	call   800cbe <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801eba:	89 1c 24             	mov    %ebx,(%esp)
  801ebd:	e8 c0 f1 ff ff       	call   801082 <fd2data>
  801ec2:	83 c4 08             	add    $0x8,%esp
  801ec5:	50                   	push   %eax
  801ec6:	6a 00                	push   $0x0
  801ec8:	e8 f1 ed ff ff       	call   800cbe <sys_page_unmap>
}
  801ecd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ed0:	c9                   	leave  
  801ed1:	c3                   	ret    

00801ed2 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801ed2:	55                   	push   %ebp
  801ed3:	89 e5                	mov    %esp,%ebp
  801ed5:	57                   	push   %edi
  801ed6:	56                   	push   %esi
  801ed7:	53                   	push   %ebx
  801ed8:	83 ec 1c             	sub    $0x1c,%esp
  801edb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ede:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ee0:	a1 04 40 80 00       	mov    0x804004,%eax
  801ee5:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801ee8:	83 ec 0c             	sub    $0xc,%esp
  801eeb:	ff 75 e0             	pushl  -0x20(%ebp)
  801eee:	e8 01 06 00 00       	call   8024f4 <pageref>
  801ef3:	89 c3                	mov    %eax,%ebx
  801ef5:	89 3c 24             	mov    %edi,(%esp)
  801ef8:	e8 f7 05 00 00       	call   8024f4 <pageref>
  801efd:	83 c4 10             	add    $0x10,%esp
  801f00:	39 c3                	cmp    %eax,%ebx
  801f02:	0f 94 c1             	sete   %cl
  801f05:	0f b6 c9             	movzbl %cl,%ecx
  801f08:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801f0b:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801f11:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801f14:	39 ce                	cmp    %ecx,%esi
  801f16:	74 1b                	je     801f33 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801f18:	39 c3                	cmp    %eax,%ebx
  801f1a:	75 c4                	jne    801ee0 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801f1c:	8b 42 58             	mov    0x58(%edx),%eax
  801f1f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801f22:	50                   	push   %eax
  801f23:	56                   	push   %esi
  801f24:	68 c3 2d 80 00       	push   $0x802dc3
  801f29:	e8 83 e3 ff ff       	call   8002b1 <cprintf>
  801f2e:	83 c4 10             	add    $0x10,%esp
  801f31:	eb ad                	jmp    801ee0 <_pipeisclosed+0xe>
	}
}
  801f33:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f39:	5b                   	pop    %ebx
  801f3a:	5e                   	pop    %esi
  801f3b:	5f                   	pop    %edi
  801f3c:	5d                   	pop    %ebp
  801f3d:	c3                   	ret    

00801f3e <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f3e:	55                   	push   %ebp
  801f3f:	89 e5                	mov    %esp,%ebp
  801f41:	57                   	push   %edi
  801f42:	56                   	push   %esi
  801f43:	53                   	push   %ebx
  801f44:	83 ec 28             	sub    $0x28,%esp
  801f47:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801f4a:	56                   	push   %esi
  801f4b:	e8 32 f1 ff ff       	call   801082 <fd2data>
  801f50:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f52:	83 c4 10             	add    $0x10,%esp
  801f55:	bf 00 00 00 00       	mov    $0x0,%edi
  801f5a:	eb 4b                	jmp    801fa7 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801f5c:	89 da                	mov    %ebx,%edx
  801f5e:	89 f0                	mov    %esi,%eax
  801f60:	e8 6d ff ff ff       	call   801ed2 <_pipeisclosed>
  801f65:	85 c0                	test   %eax,%eax
  801f67:	75 48                	jne    801fb1 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801f69:	e8 ac ec ff ff       	call   800c1a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f6e:	8b 43 04             	mov    0x4(%ebx),%eax
  801f71:	8b 0b                	mov    (%ebx),%ecx
  801f73:	8d 51 20             	lea    0x20(%ecx),%edx
  801f76:	39 d0                	cmp    %edx,%eax
  801f78:	73 e2                	jae    801f5c <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f7a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f7d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801f81:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801f84:	89 c2                	mov    %eax,%edx
  801f86:	c1 fa 1f             	sar    $0x1f,%edx
  801f89:	89 d1                	mov    %edx,%ecx
  801f8b:	c1 e9 1b             	shr    $0x1b,%ecx
  801f8e:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801f91:	83 e2 1f             	and    $0x1f,%edx
  801f94:	29 ca                	sub    %ecx,%edx
  801f96:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801f9a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801f9e:	83 c0 01             	add    $0x1,%eax
  801fa1:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fa4:	83 c7 01             	add    $0x1,%edi
  801fa7:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801faa:	75 c2                	jne    801f6e <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801fac:	8b 45 10             	mov    0x10(%ebp),%eax
  801faf:	eb 05                	jmp    801fb6 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801fb1:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801fb6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fb9:	5b                   	pop    %ebx
  801fba:	5e                   	pop    %esi
  801fbb:	5f                   	pop    %edi
  801fbc:	5d                   	pop    %ebp
  801fbd:	c3                   	ret    

00801fbe <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801fbe:	55                   	push   %ebp
  801fbf:	89 e5                	mov    %esp,%ebp
  801fc1:	57                   	push   %edi
  801fc2:	56                   	push   %esi
  801fc3:	53                   	push   %ebx
  801fc4:	83 ec 18             	sub    $0x18,%esp
  801fc7:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801fca:	57                   	push   %edi
  801fcb:	e8 b2 f0 ff ff       	call   801082 <fd2data>
  801fd0:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fd2:	83 c4 10             	add    $0x10,%esp
  801fd5:	bb 00 00 00 00       	mov    $0x0,%ebx
  801fda:	eb 3d                	jmp    802019 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801fdc:	85 db                	test   %ebx,%ebx
  801fde:	74 04                	je     801fe4 <devpipe_read+0x26>
				return i;
  801fe0:	89 d8                	mov    %ebx,%eax
  801fe2:	eb 44                	jmp    802028 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801fe4:	89 f2                	mov    %esi,%edx
  801fe6:	89 f8                	mov    %edi,%eax
  801fe8:	e8 e5 fe ff ff       	call   801ed2 <_pipeisclosed>
  801fed:	85 c0                	test   %eax,%eax
  801fef:	75 32                	jne    802023 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801ff1:	e8 24 ec ff ff       	call   800c1a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ff6:	8b 06                	mov    (%esi),%eax
  801ff8:	3b 46 04             	cmp    0x4(%esi),%eax
  801ffb:	74 df                	je     801fdc <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801ffd:	99                   	cltd   
  801ffe:	c1 ea 1b             	shr    $0x1b,%edx
  802001:	01 d0                	add    %edx,%eax
  802003:	83 e0 1f             	and    $0x1f,%eax
  802006:	29 d0                	sub    %edx,%eax
  802008:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80200d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802010:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802013:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802016:	83 c3 01             	add    $0x1,%ebx
  802019:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80201c:	75 d8                	jne    801ff6 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80201e:	8b 45 10             	mov    0x10(%ebp),%eax
  802021:	eb 05                	jmp    802028 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802023:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802028:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80202b:	5b                   	pop    %ebx
  80202c:	5e                   	pop    %esi
  80202d:	5f                   	pop    %edi
  80202e:	5d                   	pop    %ebp
  80202f:	c3                   	ret    

00802030 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802030:	55                   	push   %ebp
  802031:	89 e5                	mov    %esp,%ebp
  802033:	56                   	push   %esi
  802034:	53                   	push   %ebx
  802035:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802038:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80203b:	50                   	push   %eax
  80203c:	e8 58 f0 ff ff       	call   801099 <fd_alloc>
  802041:	83 c4 10             	add    $0x10,%esp
  802044:	89 c2                	mov    %eax,%edx
  802046:	85 c0                	test   %eax,%eax
  802048:	0f 88 2c 01 00 00    	js     80217a <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80204e:	83 ec 04             	sub    $0x4,%esp
  802051:	68 07 04 00 00       	push   $0x407
  802056:	ff 75 f4             	pushl  -0xc(%ebp)
  802059:	6a 00                	push   $0x0
  80205b:	e8 d9 eb ff ff       	call   800c39 <sys_page_alloc>
  802060:	83 c4 10             	add    $0x10,%esp
  802063:	89 c2                	mov    %eax,%edx
  802065:	85 c0                	test   %eax,%eax
  802067:	0f 88 0d 01 00 00    	js     80217a <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80206d:	83 ec 0c             	sub    $0xc,%esp
  802070:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802073:	50                   	push   %eax
  802074:	e8 20 f0 ff ff       	call   801099 <fd_alloc>
  802079:	89 c3                	mov    %eax,%ebx
  80207b:	83 c4 10             	add    $0x10,%esp
  80207e:	85 c0                	test   %eax,%eax
  802080:	0f 88 e2 00 00 00    	js     802168 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802086:	83 ec 04             	sub    $0x4,%esp
  802089:	68 07 04 00 00       	push   $0x407
  80208e:	ff 75 f0             	pushl  -0x10(%ebp)
  802091:	6a 00                	push   $0x0
  802093:	e8 a1 eb ff ff       	call   800c39 <sys_page_alloc>
  802098:	89 c3                	mov    %eax,%ebx
  80209a:	83 c4 10             	add    $0x10,%esp
  80209d:	85 c0                	test   %eax,%eax
  80209f:	0f 88 c3 00 00 00    	js     802168 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8020a5:	83 ec 0c             	sub    $0xc,%esp
  8020a8:	ff 75 f4             	pushl  -0xc(%ebp)
  8020ab:	e8 d2 ef ff ff       	call   801082 <fd2data>
  8020b0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020b2:	83 c4 0c             	add    $0xc,%esp
  8020b5:	68 07 04 00 00       	push   $0x407
  8020ba:	50                   	push   %eax
  8020bb:	6a 00                	push   $0x0
  8020bd:	e8 77 eb ff ff       	call   800c39 <sys_page_alloc>
  8020c2:	89 c3                	mov    %eax,%ebx
  8020c4:	83 c4 10             	add    $0x10,%esp
  8020c7:	85 c0                	test   %eax,%eax
  8020c9:	0f 88 89 00 00 00    	js     802158 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020cf:	83 ec 0c             	sub    $0xc,%esp
  8020d2:	ff 75 f0             	pushl  -0x10(%ebp)
  8020d5:	e8 a8 ef ff ff       	call   801082 <fd2data>
  8020da:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8020e1:	50                   	push   %eax
  8020e2:	6a 00                	push   $0x0
  8020e4:	56                   	push   %esi
  8020e5:	6a 00                	push   $0x0
  8020e7:	e8 90 eb ff ff       	call   800c7c <sys_page_map>
  8020ec:	89 c3                	mov    %eax,%ebx
  8020ee:	83 c4 20             	add    $0x20,%esp
  8020f1:	85 c0                	test   %eax,%eax
  8020f3:	78 55                	js     80214a <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8020f5:	8b 15 28 30 80 00    	mov    0x803028,%edx
  8020fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020fe:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802100:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802103:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80210a:	8b 15 28 30 80 00    	mov    0x803028,%edx
  802110:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802113:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802115:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802118:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80211f:	83 ec 0c             	sub    $0xc,%esp
  802122:	ff 75 f4             	pushl  -0xc(%ebp)
  802125:	e8 48 ef ff ff       	call   801072 <fd2num>
  80212a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80212d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80212f:	83 c4 04             	add    $0x4,%esp
  802132:	ff 75 f0             	pushl  -0x10(%ebp)
  802135:	e8 38 ef ff ff       	call   801072 <fd2num>
  80213a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80213d:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802140:	83 c4 10             	add    $0x10,%esp
  802143:	ba 00 00 00 00       	mov    $0x0,%edx
  802148:	eb 30                	jmp    80217a <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80214a:	83 ec 08             	sub    $0x8,%esp
  80214d:	56                   	push   %esi
  80214e:	6a 00                	push   $0x0
  802150:	e8 69 eb ff ff       	call   800cbe <sys_page_unmap>
  802155:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802158:	83 ec 08             	sub    $0x8,%esp
  80215b:	ff 75 f0             	pushl  -0x10(%ebp)
  80215e:	6a 00                	push   $0x0
  802160:	e8 59 eb ff ff       	call   800cbe <sys_page_unmap>
  802165:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802168:	83 ec 08             	sub    $0x8,%esp
  80216b:	ff 75 f4             	pushl  -0xc(%ebp)
  80216e:	6a 00                	push   $0x0
  802170:	e8 49 eb ff ff       	call   800cbe <sys_page_unmap>
  802175:	83 c4 10             	add    $0x10,%esp
  802178:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80217a:	89 d0                	mov    %edx,%eax
  80217c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80217f:	5b                   	pop    %ebx
  802180:	5e                   	pop    %esi
  802181:	5d                   	pop    %ebp
  802182:	c3                   	ret    

00802183 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802183:	55                   	push   %ebp
  802184:	89 e5                	mov    %esp,%ebp
  802186:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802189:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80218c:	50                   	push   %eax
  80218d:	ff 75 08             	pushl  0x8(%ebp)
  802190:	e8 53 ef ff ff       	call   8010e8 <fd_lookup>
  802195:	83 c4 10             	add    $0x10,%esp
  802198:	85 c0                	test   %eax,%eax
  80219a:	78 18                	js     8021b4 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80219c:	83 ec 0c             	sub    $0xc,%esp
  80219f:	ff 75 f4             	pushl  -0xc(%ebp)
  8021a2:	e8 db ee ff ff       	call   801082 <fd2data>
	return _pipeisclosed(fd, p);
  8021a7:	89 c2                	mov    %eax,%edx
  8021a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021ac:	e8 21 fd ff ff       	call   801ed2 <_pipeisclosed>
  8021b1:	83 c4 10             	add    $0x10,%esp
}
  8021b4:	c9                   	leave  
  8021b5:	c3                   	ret    

008021b6 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  8021b6:	55                   	push   %ebp
  8021b7:	89 e5                	mov    %esp,%ebp
  8021b9:	56                   	push   %esi
  8021ba:	53                   	push   %ebx
  8021bb:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  8021be:	85 f6                	test   %esi,%esi
  8021c0:	75 16                	jne    8021d8 <wait+0x22>
  8021c2:	68 db 2d 80 00       	push   $0x802ddb
  8021c7:	68 04 2d 80 00       	push   $0x802d04
  8021cc:	6a 09                	push   $0x9
  8021ce:	68 e6 2d 80 00       	push   $0x802de6
  8021d3:	e8 00 e0 ff ff       	call   8001d8 <_panic>
	e = &envs[ENVX(envid)];
  8021d8:	89 f3                	mov    %esi,%ebx
  8021da:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8021e0:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  8021e3:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  8021e9:	eb 05                	jmp    8021f0 <wait+0x3a>
		sys_yield();
  8021eb:	e8 2a ea ff ff       	call   800c1a <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8021f0:	8b 43 48             	mov    0x48(%ebx),%eax
  8021f3:	39 c6                	cmp    %eax,%esi
  8021f5:	75 07                	jne    8021fe <wait+0x48>
  8021f7:	8b 43 54             	mov    0x54(%ebx),%eax
  8021fa:	85 c0                	test   %eax,%eax
  8021fc:	75 ed                	jne    8021eb <wait+0x35>
		sys_yield();
}
  8021fe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802201:	5b                   	pop    %ebx
  802202:	5e                   	pop    %esi
  802203:	5d                   	pop    %ebp
  802204:	c3                   	ret    

00802205 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802205:	55                   	push   %ebp
  802206:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802208:	b8 00 00 00 00       	mov    $0x0,%eax
  80220d:	5d                   	pop    %ebp
  80220e:	c3                   	ret    

0080220f <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80220f:	55                   	push   %ebp
  802210:	89 e5                	mov    %esp,%ebp
  802212:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802215:	68 f1 2d 80 00       	push   $0x802df1
  80221a:	ff 75 0c             	pushl  0xc(%ebp)
  80221d:	e8 14 e6 ff ff       	call   800836 <strcpy>
	return 0;
}
  802222:	b8 00 00 00 00       	mov    $0x0,%eax
  802227:	c9                   	leave  
  802228:	c3                   	ret    

00802229 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802229:	55                   	push   %ebp
  80222a:	89 e5                	mov    %esp,%ebp
  80222c:	57                   	push   %edi
  80222d:	56                   	push   %esi
  80222e:	53                   	push   %ebx
  80222f:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802235:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80223a:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802240:	eb 2d                	jmp    80226f <devcons_write+0x46>
		m = n - tot;
  802242:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802245:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802247:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80224a:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80224f:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802252:	83 ec 04             	sub    $0x4,%esp
  802255:	53                   	push   %ebx
  802256:	03 45 0c             	add    0xc(%ebp),%eax
  802259:	50                   	push   %eax
  80225a:	57                   	push   %edi
  80225b:	e8 68 e7 ff ff       	call   8009c8 <memmove>
		sys_cputs(buf, m);
  802260:	83 c4 08             	add    $0x8,%esp
  802263:	53                   	push   %ebx
  802264:	57                   	push   %edi
  802265:	e8 13 e9 ff ff       	call   800b7d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80226a:	01 de                	add    %ebx,%esi
  80226c:	83 c4 10             	add    $0x10,%esp
  80226f:	89 f0                	mov    %esi,%eax
  802271:	3b 75 10             	cmp    0x10(%ebp),%esi
  802274:	72 cc                	jb     802242 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802276:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802279:	5b                   	pop    %ebx
  80227a:	5e                   	pop    %esi
  80227b:	5f                   	pop    %edi
  80227c:	5d                   	pop    %ebp
  80227d:	c3                   	ret    

0080227e <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80227e:	55                   	push   %ebp
  80227f:	89 e5                	mov    %esp,%ebp
  802281:	83 ec 08             	sub    $0x8,%esp
  802284:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802289:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80228d:	74 2a                	je     8022b9 <devcons_read+0x3b>
  80228f:	eb 05                	jmp    802296 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802291:	e8 84 e9 ff ff       	call   800c1a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802296:	e8 00 e9 ff ff       	call   800b9b <sys_cgetc>
  80229b:	85 c0                	test   %eax,%eax
  80229d:	74 f2                	je     802291 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80229f:	85 c0                	test   %eax,%eax
  8022a1:	78 16                	js     8022b9 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8022a3:	83 f8 04             	cmp    $0x4,%eax
  8022a6:	74 0c                	je     8022b4 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8022a8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8022ab:	88 02                	mov    %al,(%edx)
	return 1;
  8022ad:	b8 01 00 00 00       	mov    $0x1,%eax
  8022b2:	eb 05                	jmp    8022b9 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8022b4:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8022b9:	c9                   	leave  
  8022ba:	c3                   	ret    

008022bb <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8022bb:	55                   	push   %ebp
  8022bc:	89 e5                	mov    %esp,%ebp
  8022be:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8022c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8022c4:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8022c7:	6a 01                	push   $0x1
  8022c9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8022cc:	50                   	push   %eax
  8022cd:	e8 ab e8 ff ff       	call   800b7d <sys_cputs>
}
  8022d2:	83 c4 10             	add    $0x10,%esp
  8022d5:	c9                   	leave  
  8022d6:	c3                   	ret    

008022d7 <getchar>:

int
getchar(void)
{
  8022d7:	55                   	push   %ebp
  8022d8:	89 e5                	mov    %esp,%ebp
  8022da:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8022dd:	6a 01                	push   $0x1
  8022df:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8022e2:	50                   	push   %eax
  8022e3:	6a 00                	push   $0x0
  8022e5:	e8 64 f0 ff ff       	call   80134e <read>
	if (r < 0)
  8022ea:	83 c4 10             	add    $0x10,%esp
  8022ed:	85 c0                	test   %eax,%eax
  8022ef:	78 0f                	js     802300 <getchar+0x29>
		return r;
	if (r < 1)
  8022f1:	85 c0                	test   %eax,%eax
  8022f3:	7e 06                	jle    8022fb <getchar+0x24>
		return -E_EOF;
	return c;
  8022f5:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8022f9:	eb 05                	jmp    802300 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8022fb:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802300:	c9                   	leave  
  802301:	c3                   	ret    

00802302 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802302:	55                   	push   %ebp
  802303:	89 e5                	mov    %esp,%ebp
  802305:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802308:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80230b:	50                   	push   %eax
  80230c:	ff 75 08             	pushl  0x8(%ebp)
  80230f:	e8 d4 ed ff ff       	call   8010e8 <fd_lookup>
  802314:	83 c4 10             	add    $0x10,%esp
  802317:	85 c0                	test   %eax,%eax
  802319:	78 11                	js     80232c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80231b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80231e:	8b 15 44 30 80 00    	mov    0x803044,%edx
  802324:	39 10                	cmp    %edx,(%eax)
  802326:	0f 94 c0             	sete   %al
  802329:	0f b6 c0             	movzbl %al,%eax
}
  80232c:	c9                   	leave  
  80232d:	c3                   	ret    

0080232e <opencons>:

int
opencons(void)
{
  80232e:	55                   	push   %ebp
  80232f:	89 e5                	mov    %esp,%ebp
  802331:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802334:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802337:	50                   	push   %eax
  802338:	e8 5c ed ff ff       	call   801099 <fd_alloc>
  80233d:	83 c4 10             	add    $0x10,%esp
		return r;
  802340:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802342:	85 c0                	test   %eax,%eax
  802344:	78 3e                	js     802384 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802346:	83 ec 04             	sub    $0x4,%esp
  802349:	68 07 04 00 00       	push   $0x407
  80234e:	ff 75 f4             	pushl  -0xc(%ebp)
  802351:	6a 00                	push   $0x0
  802353:	e8 e1 e8 ff ff       	call   800c39 <sys_page_alloc>
  802358:	83 c4 10             	add    $0x10,%esp
		return r;
  80235b:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80235d:	85 c0                	test   %eax,%eax
  80235f:	78 23                	js     802384 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802361:	8b 15 44 30 80 00    	mov    0x803044,%edx
  802367:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80236a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80236c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80236f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802376:	83 ec 0c             	sub    $0xc,%esp
  802379:	50                   	push   %eax
  80237a:	e8 f3 ec ff ff       	call   801072 <fd2num>
  80237f:	89 c2                	mov    %eax,%edx
  802381:	83 c4 10             	add    $0x10,%esp
}
  802384:	89 d0                	mov    %edx,%eax
  802386:	c9                   	leave  
  802387:	c3                   	ret    

00802388 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802388:	55                   	push   %ebp
  802389:	89 e5                	mov    %esp,%ebp
  80238b:	53                   	push   %ebx
  80238c:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  80238f:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802396:	75 28                	jne    8023c0 <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  802398:	e8 5e e8 ff ff       	call   800bfb <sys_getenvid>
  80239d:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_U | PTE_W);
  80239f:	83 ec 04             	sub    $0x4,%esp
  8023a2:	6a 06                	push   $0x6
  8023a4:	68 00 f0 bf ee       	push   $0xeebff000
  8023a9:	50                   	push   %eax
  8023aa:	e8 8a e8 ff ff       	call   800c39 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  8023af:	83 c4 08             	add    $0x8,%esp
  8023b2:	68 cd 23 80 00       	push   $0x8023cd
  8023b7:	53                   	push   %ebx
  8023b8:	e8 c7 e9 ff ff       	call   800d84 <sys_env_set_pgfault_upcall>
  8023bd:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8023c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8023c3:	a3 00 60 80 00       	mov    %eax,0x806000
}
  8023c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8023cb:	c9                   	leave  
  8023cc:	c3                   	ret    

008023cd <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8023cd:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8023ce:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8023d3:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8023d5:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	# My method is different. Copy the values to the other stack
	# in a convinient way, and then pop everything.
	movl %esp, %ebp		# ebp refers to the exception stack
  8023d8:	89 e5                	mov    %esp,%ebp
	movl 48(%ebp), %esp 	# go to other stack
  8023da:	8b 65 30             	mov    0x30(%ebp),%esp

	pushl 40(%ebp)		# eip - ORDER SWITCHED WITH EFLAGS
  8023dd:	ff 75 28             	pushl  0x28(%ebp)
	pushl 44(%ebp)      	# eflags
  8023e0:	ff 75 2c             	pushl  0x2c(%ebp)
	pushl 36(%ebp)		# all the 8 remaining regs
  8023e3:	ff 75 24             	pushl  0x24(%ebp)
	pushl 32(%ebp)
  8023e6:	ff 75 20             	pushl  0x20(%ebp)
	pushl 28(%ebp)
  8023e9:	ff 75 1c             	pushl  0x1c(%ebp)
	pushl 24(%ebp)
  8023ec:	ff 75 18             	pushl  0x18(%ebp)
	pushl 20(%ebp)
  8023ef:	ff 75 14             	pushl  0x14(%ebp)
	pushl 16(%ebp)
  8023f2:	ff 75 10             	pushl  0x10(%ebp)
	pushl 12(%ebp)
  8023f5:	ff 75 0c             	pushl  0xc(%ebp)
	pushl 8(%ebp)
  8023f8:	ff 75 08             	pushl  0x8(%ebp)

	popal			# now just pop everything!
  8023fb:	61                   	popa   
	popfl
  8023fc:	9d                   	popf   
	ret
  8023fd:	c3                   	ret    

008023fe <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8023fe:	55                   	push   %ebp
  8023ff:	89 e5                	mov    %esp,%ebp
  802401:	56                   	push   %esi
  802402:	53                   	push   %ebx
  802403:	8b 75 08             	mov    0x8(%ebp),%esi
  802406:	8b 45 0c             	mov    0xc(%ebp),%eax
  802409:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  80240c:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  80240e:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  802413:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  802416:	83 ec 0c             	sub    $0xc,%esp
  802419:	50                   	push   %eax
  80241a:	e8 ca e9 ff ff       	call   800de9 <sys_ipc_recv>

	if (r < 0) {
  80241f:	83 c4 10             	add    $0x10,%esp
  802422:	85 c0                	test   %eax,%eax
  802424:	79 16                	jns    80243c <ipc_recv+0x3e>
		if (from_env_store)
  802426:	85 f6                	test   %esi,%esi
  802428:	74 06                	je     802430 <ipc_recv+0x32>
			*from_env_store = 0;
  80242a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  802430:	85 db                	test   %ebx,%ebx
  802432:	74 2c                	je     802460 <ipc_recv+0x62>
			*perm_store = 0;
  802434:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80243a:	eb 24                	jmp    802460 <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  80243c:	85 f6                	test   %esi,%esi
  80243e:	74 0a                	je     80244a <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  802440:	a1 04 40 80 00       	mov    0x804004,%eax
  802445:	8b 40 74             	mov    0x74(%eax),%eax
  802448:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  80244a:	85 db                	test   %ebx,%ebx
  80244c:	74 0a                	je     802458 <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  80244e:	a1 04 40 80 00       	mov    0x804004,%eax
  802453:	8b 40 78             	mov    0x78(%eax),%eax
  802456:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  802458:	a1 04 40 80 00       	mov    0x804004,%eax
  80245d:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  802460:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802463:	5b                   	pop    %ebx
  802464:	5e                   	pop    %esi
  802465:	5d                   	pop    %ebp
  802466:	c3                   	ret    

00802467 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802467:	55                   	push   %ebp
  802468:	89 e5                	mov    %esp,%ebp
  80246a:	57                   	push   %edi
  80246b:	56                   	push   %esi
  80246c:	53                   	push   %ebx
  80246d:	83 ec 0c             	sub    $0xc,%esp
  802470:	8b 7d 08             	mov    0x8(%ebp),%edi
  802473:	8b 75 0c             	mov    0xc(%ebp),%esi
  802476:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  802479:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  80247b:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  802480:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  802483:	ff 75 14             	pushl  0x14(%ebp)
  802486:	53                   	push   %ebx
  802487:	56                   	push   %esi
  802488:	57                   	push   %edi
  802489:	e8 38 e9 ff ff       	call   800dc6 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  80248e:	83 c4 10             	add    $0x10,%esp
  802491:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802494:	75 07                	jne    80249d <ipc_send+0x36>
			sys_yield();
  802496:	e8 7f e7 ff ff       	call   800c1a <sys_yield>
  80249b:	eb e6                	jmp    802483 <ipc_send+0x1c>
		} else if (r < 0) {
  80249d:	85 c0                	test   %eax,%eax
  80249f:	79 12                	jns    8024b3 <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  8024a1:	50                   	push   %eax
  8024a2:	68 fd 2d 80 00       	push   $0x802dfd
  8024a7:	6a 51                	push   $0x51
  8024a9:	68 0a 2e 80 00       	push   $0x802e0a
  8024ae:	e8 25 dd ff ff       	call   8001d8 <_panic>
		}
	}
}
  8024b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024b6:	5b                   	pop    %ebx
  8024b7:	5e                   	pop    %esi
  8024b8:	5f                   	pop    %edi
  8024b9:	5d                   	pop    %ebp
  8024ba:	c3                   	ret    

008024bb <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8024bb:	55                   	push   %ebp
  8024bc:	89 e5                	mov    %esp,%ebp
  8024be:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8024c1:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8024c6:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8024c9:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8024cf:	8b 52 50             	mov    0x50(%edx),%edx
  8024d2:	39 ca                	cmp    %ecx,%edx
  8024d4:	75 0d                	jne    8024e3 <ipc_find_env+0x28>
			return envs[i].env_id;
  8024d6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8024d9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8024de:	8b 40 48             	mov    0x48(%eax),%eax
  8024e1:	eb 0f                	jmp    8024f2 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8024e3:	83 c0 01             	add    $0x1,%eax
  8024e6:	3d 00 04 00 00       	cmp    $0x400,%eax
  8024eb:	75 d9                	jne    8024c6 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8024ed:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8024f2:	5d                   	pop    %ebp
  8024f3:	c3                   	ret    

008024f4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8024f4:	55                   	push   %ebp
  8024f5:	89 e5                	mov    %esp,%ebp
  8024f7:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8024fa:	89 d0                	mov    %edx,%eax
  8024fc:	c1 e8 16             	shr    $0x16,%eax
  8024ff:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802506:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80250b:	f6 c1 01             	test   $0x1,%cl
  80250e:	74 1d                	je     80252d <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802510:	c1 ea 0c             	shr    $0xc,%edx
  802513:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80251a:	f6 c2 01             	test   $0x1,%dl
  80251d:	74 0e                	je     80252d <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80251f:	c1 ea 0c             	shr    $0xc,%edx
  802522:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802529:	ef 
  80252a:	0f b7 c0             	movzwl %ax,%eax
}
  80252d:	5d                   	pop    %ebp
  80252e:	c3                   	ret    
  80252f:	90                   	nop

00802530 <__udivdi3>:
  802530:	55                   	push   %ebp
  802531:	57                   	push   %edi
  802532:	56                   	push   %esi
  802533:	53                   	push   %ebx
  802534:	83 ec 1c             	sub    $0x1c,%esp
  802537:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80253b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80253f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802543:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802547:	85 f6                	test   %esi,%esi
  802549:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80254d:	89 ca                	mov    %ecx,%edx
  80254f:	89 f8                	mov    %edi,%eax
  802551:	75 3d                	jne    802590 <__udivdi3+0x60>
  802553:	39 cf                	cmp    %ecx,%edi
  802555:	0f 87 c5 00 00 00    	ja     802620 <__udivdi3+0xf0>
  80255b:	85 ff                	test   %edi,%edi
  80255d:	89 fd                	mov    %edi,%ebp
  80255f:	75 0b                	jne    80256c <__udivdi3+0x3c>
  802561:	b8 01 00 00 00       	mov    $0x1,%eax
  802566:	31 d2                	xor    %edx,%edx
  802568:	f7 f7                	div    %edi
  80256a:	89 c5                	mov    %eax,%ebp
  80256c:	89 c8                	mov    %ecx,%eax
  80256e:	31 d2                	xor    %edx,%edx
  802570:	f7 f5                	div    %ebp
  802572:	89 c1                	mov    %eax,%ecx
  802574:	89 d8                	mov    %ebx,%eax
  802576:	89 cf                	mov    %ecx,%edi
  802578:	f7 f5                	div    %ebp
  80257a:	89 c3                	mov    %eax,%ebx
  80257c:	89 d8                	mov    %ebx,%eax
  80257e:	89 fa                	mov    %edi,%edx
  802580:	83 c4 1c             	add    $0x1c,%esp
  802583:	5b                   	pop    %ebx
  802584:	5e                   	pop    %esi
  802585:	5f                   	pop    %edi
  802586:	5d                   	pop    %ebp
  802587:	c3                   	ret    
  802588:	90                   	nop
  802589:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802590:	39 ce                	cmp    %ecx,%esi
  802592:	77 74                	ja     802608 <__udivdi3+0xd8>
  802594:	0f bd fe             	bsr    %esi,%edi
  802597:	83 f7 1f             	xor    $0x1f,%edi
  80259a:	0f 84 98 00 00 00    	je     802638 <__udivdi3+0x108>
  8025a0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8025a5:	89 f9                	mov    %edi,%ecx
  8025a7:	89 c5                	mov    %eax,%ebp
  8025a9:	29 fb                	sub    %edi,%ebx
  8025ab:	d3 e6                	shl    %cl,%esi
  8025ad:	89 d9                	mov    %ebx,%ecx
  8025af:	d3 ed                	shr    %cl,%ebp
  8025b1:	89 f9                	mov    %edi,%ecx
  8025b3:	d3 e0                	shl    %cl,%eax
  8025b5:	09 ee                	or     %ebp,%esi
  8025b7:	89 d9                	mov    %ebx,%ecx
  8025b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8025bd:	89 d5                	mov    %edx,%ebp
  8025bf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8025c3:	d3 ed                	shr    %cl,%ebp
  8025c5:	89 f9                	mov    %edi,%ecx
  8025c7:	d3 e2                	shl    %cl,%edx
  8025c9:	89 d9                	mov    %ebx,%ecx
  8025cb:	d3 e8                	shr    %cl,%eax
  8025cd:	09 c2                	or     %eax,%edx
  8025cf:	89 d0                	mov    %edx,%eax
  8025d1:	89 ea                	mov    %ebp,%edx
  8025d3:	f7 f6                	div    %esi
  8025d5:	89 d5                	mov    %edx,%ebp
  8025d7:	89 c3                	mov    %eax,%ebx
  8025d9:	f7 64 24 0c          	mull   0xc(%esp)
  8025dd:	39 d5                	cmp    %edx,%ebp
  8025df:	72 10                	jb     8025f1 <__udivdi3+0xc1>
  8025e1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8025e5:	89 f9                	mov    %edi,%ecx
  8025e7:	d3 e6                	shl    %cl,%esi
  8025e9:	39 c6                	cmp    %eax,%esi
  8025eb:	73 07                	jae    8025f4 <__udivdi3+0xc4>
  8025ed:	39 d5                	cmp    %edx,%ebp
  8025ef:	75 03                	jne    8025f4 <__udivdi3+0xc4>
  8025f1:	83 eb 01             	sub    $0x1,%ebx
  8025f4:	31 ff                	xor    %edi,%edi
  8025f6:	89 d8                	mov    %ebx,%eax
  8025f8:	89 fa                	mov    %edi,%edx
  8025fa:	83 c4 1c             	add    $0x1c,%esp
  8025fd:	5b                   	pop    %ebx
  8025fe:	5e                   	pop    %esi
  8025ff:	5f                   	pop    %edi
  802600:	5d                   	pop    %ebp
  802601:	c3                   	ret    
  802602:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802608:	31 ff                	xor    %edi,%edi
  80260a:	31 db                	xor    %ebx,%ebx
  80260c:	89 d8                	mov    %ebx,%eax
  80260e:	89 fa                	mov    %edi,%edx
  802610:	83 c4 1c             	add    $0x1c,%esp
  802613:	5b                   	pop    %ebx
  802614:	5e                   	pop    %esi
  802615:	5f                   	pop    %edi
  802616:	5d                   	pop    %ebp
  802617:	c3                   	ret    
  802618:	90                   	nop
  802619:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802620:	89 d8                	mov    %ebx,%eax
  802622:	f7 f7                	div    %edi
  802624:	31 ff                	xor    %edi,%edi
  802626:	89 c3                	mov    %eax,%ebx
  802628:	89 d8                	mov    %ebx,%eax
  80262a:	89 fa                	mov    %edi,%edx
  80262c:	83 c4 1c             	add    $0x1c,%esp
  80262f:	5b                   	pop    %ebx
  802630:	5e                   	pop    %esi
  802631:	5f                   	pop    %edi
  802632:	5d                   	pop    %ebp
  802633:	c3                   	ret    
  802634:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802638:	39 ce                	cmp    %ecx,%esi
  80263a:	72 0c                	jb     802648 <__udivdi3+0x118>
  80263c:	31 db                	xor    %ebx,%ebx
  80263e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802642:	0f 87 34 ff ff ff    	ja     80257c <__udivdi3+0x4c>
  802648:	bb 01 00 00 00       	mov    $0x1,%ebx
  80264d:	e9 2a ff ff ff       	jmp    80257c <__udivdi3+0x4c>
  802652:	66 90                	xchg   %ax,%ax
  802654:	66 90                	xchg   %ax,%ax
  802656:	66 90                	xchg   %ax,%ax
  802658:	66 90                	xchg   %ax,%ax
  80265a:	66 90                	xchg   %ax,%ax
  80265c:	66 90                	xchg   %ax,%ax
  80265e:	66 90                	xchg   %ax,%ax

00802660 <__umoddi3>:
  802660:	55                   	push   %ebp
  802661:	57                   	push   %edi
  802662:	56                   	push   %esi
  802663:	53                   	push   %ebx
  802664:	83 ec 1c             	sub    $0x1c,%esp
  802667:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80266b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80266f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802673:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802677:	85 d2                	test   %edx,%edx
  802679:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80267d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802681:	89 f3                	mov    %esi,%ebx
  802683:	89 3c 24             	mov    %edi,(%esp)
  802686:	89 74 24 04          	mov    %esi,0x4(%esp)
  80268a:	75 1c                	jne    8026a8 <__umoddi3+0x48>
  80268c:	39 f7                	cmp    %esi,%edi
  80268e:	76 50                	jbe    8026e0 <__umoddi3+0x80>
  802690:	89 c8                	mov    %ecx,%eax
  802692:	89 f2                	mov    %esi,%edx
  802694:	f7 f7                	div    %edi
  802696:	89 d0                	mov    %edx,%eax
  802698:	31 d2                	xor    %edx,%edx
  80269a:	83 c4 1c             	add    $0x1c,%esp
  80269d:	5b                   	pop    %ebx
  80269e:	5e                   	pop    %esi
  80269f:	5f                   	pop    %edi
  8026a0:	5d                   	pop    %ebp
  8026a1:	c3                   	ret    
  8026a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8026a8:	39 f2                	cmp    %esi,%edx
  8026aa:	89 d0                	mov    %edx,%eax
  8026ac:	77 52                	ja     802700 <__umoddi3+0xa0>
  8026ae:	0f bd ea             	bsr    %edx,%ebp
  8026b1:	83 f5 1f             	xor    $0x1f,%ebp
  8026b4:	75 5a                	jne    802710 <__umoddi3+0xb0>
  8026b6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8026ba:	0f 82 e0 00 00 00    	jb     8027a0 <__umoddi3+0x140>
  8026c0:	39 0c 24             	cmp    %ecx,(%esp)
  8026c3:	0f 86 d7 00 00 00    	jbe    8027a0 <__umoddi3+0x140>
  8026c9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8026cd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8026d1:	83 c4 1c             	add    $0x1c,%esp
  8026d4:	5b                   	pop    %ebx
  8026d5:	5e                   	pop    %esi
  8026d6:	5f                   	pop    %edi
  8026d7:	5d                   	pop    %ebp
  8026d8:	c3                   	ret    
  8026d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8026e0:	85 ff                	test   %edi,%edi
  8026e2:	89 fd                	mov    %edi,%ebp
  8026e4:	75 0b                	jne    8026f1 <__umoddi3+0x91>
  8026e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8026eb:	31 d2                	xor    %edx,%edx
  8026ed:	f7 f7                	div    %edi
  8026ef:	89 c5                	mov    %eax,%ebp
  8026f1:	89 f0                	mov    %esi,%eax
  8026f3:	31 d2                	xor    %edx,%edx
  8026f5:	f7 f5                	div    %ebp
  8026f7:	89 c8                	mov    %ecx,%eax
  8026f9:	f7 f5                	div    %ebp
  8026fb:	89 d0                	mov    %edx,%eax
  8026fd:	eb 99                	jmp    802698 <__umoddi3+0x38>
  8026ff:	90                   	nop
  802700:	89 c8                	mov    %ecx,%eax
  802702:	89 f2                	mov    %esi,%edx
  802704:	83 c4 1c             	add    $0x1c,%esp
  802707:	5b                   	pop    %ebx
  802708:	5e                   	pop    %esi
  802709:	5f                   	pop    %edi
  80270a:	5d                   	pop    %ebp
  80270b:	c3                   	ret    
  80270c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802710:	8b 34 24             	mov    (%esp),%esi
  802713:	bf 20 00 00 00       	mov    $0x20,%edi
  802718:	89 e9                	mov    %ebp,%ecx
  80271a:	29 ef                	sub    %ebp,%edi
  80271c:	d3 e0                	shl    %cl,%eax
  80271e:	89 f9                	mov    %edi,%ecx
  802720:	89 f2                	mov    %esi,%edx
  802722:	d3 ea                	shr    %cl,%edx
  802724:	89 e9                	mov    %ebp,%ecx
  802726:	09 c2                	or     %eax,%edx
  802728:	89 d8                	mov    %ebx,%eax
  80272a:	89 14 24             	mov    %edx,(%esp)
  80272d:	89 f2                	mov    %esi,%edx
  80272f:	d3 e2                	shl    %cl,%edx
  802731:	89 f9                	mov    %edi,%ecx
  802733:	89 54 24 04          	mov    %edx,0x4(%esp)
  802737:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80273b:	d3 e8                	shr    %cl,%eax
  80273d:	89 e9                	mov    %ebp,%ecx
  80273f:	89 c6                	mov    %eax,%esi
  802741:	d3 e3                	shl    %cl,%ebx
  802743:	89 f9                	mov    %edi,%ecx
  802745:	89 d0                	mov    %edx,%eax
  802747:	d3 e8                	shr    %cl,%eax
  802749:	89 e9                	mov    %ebp,%ecx
  80274b:	09 d8                	or     %ebx,%eax
  80274d:	89 d3                	mov    %edx,%ebx
  80274f:	89 f2                	mov    %esi,%edx
  802751:	f7 34 24             	divl   (%esp)
  802754:	89 d6                	mov    %edx,%esi
  802756:	d3 e3                	shl    %cl,%ebx
  802758:	f7 64 24 04          	mull   0x4(%esp)
  80275c:	39 d6                	cmp    %edx,%esi
  80275e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802762:	89 d1                	mov    %edx,%ecx
  802764:	89 c3                	mov    %eax,%ebx
  802766:	72 08                	jb     802770 <__umoddi3+0x110>
  802768:	75 11                	jne    80277b <__umoddi3+0x11b>
  80276a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80276e:	73 0b                	jae    80277b <__umoddi3+0x11b>
  802770:	2b 44 24 04          	sub    0x4(%esp),%eax
  802774:	1b 14 24             	sbb    (%esp),%edx
  802777:	89 d1                	mov    %edx,%ecx
  802779:	89 c3                	mov    %eax,%ebx
  80277b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80277f:	29 da                	sub    %ebx,%edx
  802781:	19 ce                	sbb    %ecx,%esi
  802783:	89 f9                	mov    %edi,%ecx
  802785:	89 f0                	mov    %esi,%eax
  802787:	d3 e0                	shl    %cl,%eax
  802789:	89 e9                	mov    %ebp,%ecx
  80278b:	d3 ea                	shr    %cl,%edx
  80278d:	89 e9                	mov    %ebp,%ecx
  80278f:	d3 ee                	shr    %cl,%esi
  802791:	09 d0                	or     %edx,%eax
  802793:	89 f2                	mov    %esi,%edx
  802795:	83 c4 1c             	add    $0x1c,%esp
  802798:	5b                   	pop    %ebx
  802799:	5e                   	pop    %esi
  80279a:	5f                   	pop    %edi
  80279b:	5d                   	pop    %ebp
  80279c:	c3                   	ret    
  80279d:	8d 76 00             	lea    0x0(%esi),%esi
  8027a0:	29 f9                	sub    %edi,%ecx
  8027a2:	19 d6                	sbb    %edx,%esi
  8027a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8027a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8027ac:	e9 18 ff ff ff       	jmp    8026c9 <__umoddi3+0x69>
