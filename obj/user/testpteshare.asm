
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
  800039:	ff 35 00 40 80 00    	pushl  0x804000
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
  800081:	68 cc 2c 80 00       	push   $0x802ccc
  800086:	6a 13                	push   $0x13
  800088:	68 df 2c 80 00       	push   $0x802cdf
  80008d:	e8 46 01 00 00       	call   8001d8 <_panic>

	// check fork
	if ((r = fork()) < 0)
  800092:	e8 66 0f 00 00       	call   800ffd <fork>
  800097:	89 c3                	mov    %eax,%ebx
  800099:	85 c0                	test   %eax,%eax
  80009b:	79 12                	jns    8000af <umain+0x5c>
		panic("fork: %e", r);
  80009d:	50                   	push   %eax
  80009e:	68 00 31 80 00       	push   $0x803100
  8000a3:	6a 17                	push   $0x17
  8000a5:	68 df 2c 80 00       	push   $0x802cdf
  8000aa:	e8 29 01 00 00       	call   8001d8 <_panic>
	if (r == 0) {
  8000af:	85 c0                	test   %eax,%eax
  8000b1:	75 1b                	jne    8000ce <umain+0x7b>
		strcpy(VA, msg);
  8000b3:	83 ec 08             	sub    $0x8,%esp
  8000b6:	ff 35 04 40 80 00    	pushl  0x804004
  8000bc:	68 00 00 00 a0       	push   $0xa0000000
  8000c1:	e8 70 07 00 00       	call   800836 <strcpy>
		exit();
  8000c6:	e8 f3 00 00 00       	call   8001be <exit>
  8000cb:	83 c4 10             	add    $0x10,%esp
	}
	wait(r);
  8000ce:	83 ec 0c             	sub    $0xc,%esp
  8000d1:	53                   	push   %ebx
  8000d2:	e8 c6 25 00 00       	call   80269d <wait>
	cprintf("fork handles PTE_SHARE %s\n", strcmp(VA, msg) == 0 ? "right" : "wrong");
  8000d7:	83 c4 08             	add    $0x8,%esp
  8000da:	ff 35 04 40 80 00    	pushl  0x804004
  8000e0:	68 00 00 00 a0       	push   $0xa0000000
  8000e5:	e8 f6 07 00 00       	call   8008e0 <strcmp>
  8000ea:	83 c4 08             	add    $0x8,%esp
  8000ed:	85 c0                	test   %eax,%eax
  8000ef:	ba c6 2c 80 00       	mov    $0x802cc6,%edx
  8000f4:	b8 c0 2c 80 00       	mov    $0x802cc0,%eax
  8000f9:	0f 45 c2             	cmovne %edx,%eax
  8000fc:	50                   	push   %eax
  8000fd:	68 f3 2c 80 00       	push   $0x802cf3
  800102:	e8 aa 01 00 00       	call   8002b1 <cprintf>

	// check spawn
	if ((r = spawnl("/testpteshare", "testpteshare", "arg", 0)) < 0)
  800107:	6a 00                	push   $0x0
  800109:	68 0e 2d 80 00       	push   $0x802d0e
  80010e:	68 13 2d 80 00       	push   $0x802d13
  800113:	68 12 2d 80 00       	push   $0x802d12
  800118:	e8 4a 1d 00 00       	call   801e67 <spawnl>
  80011d:	83 c4 20             	add    $0x20,%esp
  800120:	85 c0                	test   %eax,%eax
  800122:	79 12                	jns    800136 <umain+0xe3>
		panic("spawn: %e", r);
  800124:	50                   	push   %eax
  800125:	68 20 2d 80 00       	push   $0x802d20
  80012a:	6a 21                	push   $0x21
  80012c:	68 df 2c 80 00       	push   $0x802cdf
  800131:	e8 a2 00 00 00       	call   8001d8 <_panic>
	wait(r);
  800136:	83 ec 0c             	sub    $0xc,%esp
  800139:	50                   	push   %eax
  80013a:	e8 5e 25 00 00       	call   80269d <wait>
	cprintf("spawn handles PTE_SHARE %s\n", strcmp(VA, msg2) == 0 ? "right" : "wrong");
  80013f:	83 c4 08             	add    $0x8,%esp
  800142:	ff 35 00 40 80 00    	pushl  0x804000
  800148:	68 00 00 00 a0       	push   $0xa0000000
  80014d:	e8 8e 07 00 00       	call   8008e0 <strcmp>
  800152:	83 c4 08             	add    $0x8,%esp
  800155:	85 c0                	test   %eax,%eax
  800157:	ba c6 2c 80 00       	mov    $0x802cc6,%edx
  80015c:	b8 c0 2c 80 00       	mov    $0x802cc0,%eax
  800161:	0f 45 c2             	cmovne %edx,%eax
  800164:	50                   	push   %eax
  800165:	68 2a 2d 80 00       	push   $0x802d2a
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
  800195:	a3 08 50 80 00       	mov    %eax,0x805008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80019a:	85 db                	test   %ebx,%ebx
  80019c:	7e 07                	jle    8001a5 <libmain+0x2d>
		binaryname = argv[0];
  80019e:	8b 06                	mov    (%esi),%eax
  8001a0:	a3 08 40 80 00       	mov    %eax,0x804008

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
  8001c4:	e8 f4 10 00 00       	call   8012bd <close_all>
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
  8001e0:	8b 35 08 40 80 00    	mov    0x804008,%esi
  8001e6:	e8 10 0a 00 00       	call   800bfb <sys_getenvid>
  8001eb:	83 ec 0c             	sub    $0xc,%esp
  8001ee:	ff 75 0c             	pushl  0xc(%ebp)
  8001f1:	ff 75 08             	pushl  0x8(%ebp)
  8001f4:	56                   	push   %esi
  8001f5:	50                   	push   %eax
  8001f6:	68 70 2d 80 00       	push   $0x802d70
  8001fb:	e8 b1 00 00 00       	call   8002b1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800200:	83 c4 18             	add    $0x18,%esp
  800203:	53                   	push   %ebx
  800204:	ff 75 10             	pushl  0x10(%ebp)
  800207:	e8 54 00 00 00       	call   800260 <vcprintf>
	cprintf("\n");
  80020c:	c7 04 24 dd 32 80 00 	movl   $0x8032dd,(%esp)
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
  800314:	e8 07 27 00 00       	call   802a20 <__udivdi3>
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
  800357:	e8 f4 27 00 00       	call   802b50 <__umoddi3>
  80035c:	83 c4 14             	add    $0x14,%esp
  80035f:	0f be 80 93 2d 80 00 	movsbl 0x802d93(%eax),%eax
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
  80045b:	ff 24 85 e0 2e 80 00 	jmp    *0x802ee0(,%eax,4)
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
  80051f:	8b 14 85 40 30 80 00 	mov    0x803040(,%eax,4),%edx
  800526:	85 d2                	test   %edx,%edx
  800528:	75 18                	jne    800542 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80052a:	50                   	push   %eax
  80052b:	68 ab 2d 80 00       	push   $0x802dab
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
  800543:	68 e6 31 80 00       	push   $0x8031e6
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
  800567:	b8 a4 2d 80 00       	mov    $0x802da4,%eax
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
  800be2:	68 9f 30 80 00       	push   $0x80309f
  800be7:	6a 23                	push   $0x23
  800be9:	68 bc 30 80 00       	push   $0x8030bc
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
  800c63:	68 9f 30 80 00       	push   $0x80309f
  800c68:	6a 23                	push   $0x23
  800c6a:	68 bc 30 80 00       	push   $0x8030bc
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
  800ca5:	68 9f 30 80 00       	push   $0x80309f
  800caa:	6a 23                	push   $0x23
  800cac:	68 bc 30 80 00       	push   $0x8030bc
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
  800ce7:	68 9f 30 80 00       	push   $0x80309f
  800cec:	6a 23                	push   $0x23
  800cee:	68 bc 30 80 00       	push   $0x8030bc
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
  800d29:	68 9f 30 80 00       	push   $0x80309f
  800d2e:	6a 23                	push   $0x23
  800d30:	68 bc 30 80 00       	push   $0x8030bc
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
  800d6b:	68 9f 30 80 00       	push   $0x80309f
  800d70:	6a 23                	push   $0x23
  800d72:	68 bc 30 80 00       	push   $0x8030bc
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
  800dad:	68 9f 30 80 00       	push   $0x80309f
  800db2:	6a 23                	push   $0x23
  800db4:	68 bc 30 80 00       	push   $0x8030bc
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
  800e11:	68 9f 30 80 00       	push   $0x80309f
  800e16:	6a 23                	push   $0x23
  800e18:	68 bc 30 80 00       	push   $0x8030bc
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

00800e2a <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e2a:	55                   	push   %ebp
  800e2b:	89 e5                	mov    %esp,%ebp
  800e2d:	57                   	push   %edi
  800e2e:	56                   	push   %esi
  800e2f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e30:	ba 00 00 00 00       	mov    $0x0,%edx
  800e35:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e3a:	89 d1                	mov    %edx,%ecx
  800e3c:	89 d3                	mov    %edx,%ebx
  800e3e:	89 d7                	mov    %edx,%edi
  800e40:	89 d6                	mov    %edx,%esi
  800e42:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e44:	5b                   	pop    %ebx
  800e45:	5e                   	pop    %esi
  800e46:	5f                   	pop    %edi
  800e47:	5d                   	pop    %ebp
  800e48:	c3                   	ret    

00800e49 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800e49:	55                   	push   %ebp
  800e4a:	89 e5                	mov    %esp,%ebp
  800e4c:	53                   	push   %ebx
  800e4d:	83 ec 04             	sub    $0x4,%esp
	int r;
	void * address = (void *)(pn*PGSIZE);
  800e50:	89 d3                	mov    %edx,%ebx
  800e52:	c1 e3 0c             	shl    $0xc,%ebx
	
	if((uvpt[pn] & PTE_SHARE))
  800e55:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800e5c:	f6 c5 04             	test   $0x4,%ch
  800e5f:	74 38                	je     800e99 <duppage+0x50>
	{
		if ((r = sys_page_map(0, address, envid, address, (uvpt[pn] | PTE_SYSCALL))) < 0)
  800e61:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e68:	83 ec 0c             	sub    $0xc,%esp
  800e6b:	81 ca 07 0e 00 00    	or     $0xe07,%edx
  800e71:	52                   	push   %edx
  800e72:	53                   	push   %ebx
  800e73:	50                   	push   %eax
  800e74:	53                   	push   %ebx
  800e75:	6a 00                	push   $0x0
  800e77:	e8 00 fe ff ff       	call   800c7c <sys_page_map>
  800e7c:	83 c4 20             	add    $0x20,%esp
  800e7f:	85 c0                	test   %eax,%eax
  800e81:	0f 89 b8 00 00 00    	jns    800f3f <duppage+0xf6>
			panic("sys_page_map: %e", r);
  800e87:	50                   	push   %eax
  800e88:	68 ca 30 80 00       	push   $0x8030ca
  800e8d:	6a 4e                	push   $0x4e
  800e8f:	68 db 30 80 00       	push   $0x8030db
  800e94:	e8 3f f3 ff ff       	call   8001d8 <_panic>
	}
	else if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW))
  800e99:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800ea0:	f6 c1 02             	test   $0x2,%cl
  800ea3:	75 0c                	jne    800eb1 <duppage+0x68>
  800ea5:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800eac:	f6 c5 08             	test   $0x8,%ch
  800eaf:	74 57                	je     800f08 <duppage+0xbf>
	{
		int perm = 0;
		perm |= PTE_P|PTE_U|PTE_COW;
	
		if ((r = sys_page_map(0, address, envid, address, perm)) < 0)
  800eb1:	83 ec 0c             	sub    $0xc,%esp
  800eb4:	68 05 08 00 00       	push   $0x805
  800eb9:	53                   	push   %ebx
  800eba:	50                   	push   %eax
  800ebb:	53                   	push   %ebx
  800ebc:	6a 00                	push   $0x0
  800ebe:	e8 b9 fd ff ff       	call   800c7c <sys_page_map>
  800ec3:	83 c4 20             	add    $0x20,%esp
  800ec6:	85 c0                	test   %eax,%eax
  800ec8:	79 12                	jns    800edc <duppage+0x93>
			panic("sys_page_map: %e", r);
  800eca:	50                   	push   %eax
  800ecb:	68 ca 30 80 00       	push   $0x8030ca
  800ed0:	6a 56                	push   $0x56
  800ed2:	68 db 30 80 00       	push   $0x8030db
  800ed7:	e8 fc f2 ff ff       	call   8001d8 <_panic>
		if ((r = sys_page_map(0, address, 0, address, perm)) < 0)
  800edc:	83 ec 0c             	sub    $0xc,%esp
  800edf:	68 05 08 00 00       	push   $0x805
  800ee4:	53                   	push   %ebx
  800ee5:	6a 00                	push   $0x0
  800ee7:	53                   	push   %ebx
  800ee8:	6a 00                	push   $0x0
  800eea:	e8 8d fd ff ff       	call   800c7c <sys_page_map>
  800eef:	83 c4 20             	add    $0x20,%esp
  800ef2:	85 c0                	test   %eax,%eax
  800ef4:	79 49                	jns    800f3f <duppage+0xf6>
			panic("sys_page_map: %e", r);
  800ef6:	50                   	push   %eax
  800ef7:	68 ca 30 80 00       	push   $0x8030ca
  800efc:	6a 58                	push   $0x58
  800efe:	68 db 30 80 00       	push   $0x8030db
  800f03:	e8 d0 f2 ff ff       	call   8001d8 <_panic>
	}
	else if((uvpt[pn] & ~PTE_U) == 0)
  800f08:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f0f:	f7 c2 fb ff ff ff    	test   $0xfffffffb,%edx
  800f15:	75 28                	jne    800f3f <duppage+0xf6>
	{
		//cprintf("im here");
		if ((r = sys_page_map(0, address, envid, address, PTE_P|PTE_U)) < 0)
  800f17:	83 ec 0c             	sub    $0xc,%esp
  800f1a:	6a 05                	push   $0x5
  800f1c:	53                   	push   %ebx
  800f1d:	50                   	push   %eax
  800f1e:	53                   	push   %ebx
  800f1f:	6a 00                	push   $0x0
  800f21:	e8 56 fd ff ff       	call   800c7c <sys_page_map>
  800f26:	83 c4 20             	add    $0x20,%esp
  800f29:	85 c0                	test   %eax,%eax
  800f2b:	79 12                	jns    800f3f <duppage+0xf6>
			panic("sys_page_map: %e", r);	
  800f2d:	50                   	push   %eax
  800f2e:	68 ca 30 80 00       	push   $0x8030ca
  800f33:	6a 5e                	push   $0x5e
  800f35:	68 db 30 80 00       	push   $0x8030db
  800f3a:	e8 99 f2 ff ff       	call   8001d8 <_panic>
	}
	return 0;
}
  800f3f:	b8 00 00 00 00       	mov    $0x0,%eax
  800f44:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f47:	c9                   	leave  
  800f48:	c3                   	ret    

00800f49 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f49:	55                   	push   %ebp
  800f4a:	89 e5                	mov    %esp,%ebp
  800f4c:	53                   	push   %ebx
  800f4d:	83 ec 08             	sub    $0x8,%esp
	void *addr = (void *) utf->utf_fault_va;
  800f50:	8b 45 08             	mov    0x8(%ebp),%eax
  800f53:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	unsigned pn = ((uint32_t)addr)/PGSIZE;
  800f55:	89 d8                	mov    %ebx,%eax
  800f57:	c1 e8 0c             	shr    $0xc,%eax
	pte_t pte = uvpt[pn];
  800f5a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// Allocate a new page, mapped at temp location
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  800f61:	6a 07                	push   $0x7
  800f63:	68 00 f0 7f 00       	push   $0x7ff000
  800f68:	6a 00                	push   $0x0
  800f6a:	e8 ca fc ff ff       	call   800c39 <sys_page_alloc>
  800f6f:	83 c4 10             	add    $0x10,%esp
  800f72:	85 c0                	test   %eax,%eax
  800f74:	79 12                	jns    800f88 <pgfault+0x3f>
		panic("sys_page_alloc: %e", r);
  800f76:	50                   	push   %eax
  800f77:	68 cc 2c 80 00       	push   $0x802ccc
  800f7c:	6a 2b                	push   $0x2b
  800f7e:	68 db 30 80 00       	push   $0x8030db
  800f83:	e8 50 f2 ff ff       	call   8001d8 <_panic>

	// Copy the data from the old page to this new page
	void *addr_pgstart = (void *) ROUNDDOWN(addr, PGSIZE);
  800f88:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr_pgstart, PGSIZE);
  800f8e:	83 ec 04             	sub    $0x4,%esp
  800f91:	68 00 10 00 00       	push   $0x1000
  800f96:	53                   	push   %ebx
  800f97:	68 00 f0 7f 00       	push   $0x7ff000
  800f9c:	e8 27 fa ff ff       	call   8009c8 <memmove>

	// Move the new page to the old page's address
	if ((r = sys_page_map(0, PFTEMP, 0, addr_pgstart, PTE_P|PTE_U|PTE_W)) < 0)
  800fa1:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800fa8:	53                   	push   %ebx
  800fa9:	6a 00                	push   $0x0
  800fab:	68 00 f0 7f 00       	push   $0x7ff000
  800fb0:	6a 00                	push   $0x0
  800fb2:	e8 c5 fc ff ff       	call   800c7c <sys_page_map>
  800fb7:	83 c4 20             	add    $0x20,%esp
  800fba:	85 c0                	test   %eax,%eax
  800fbc:	79 12                	jns    800fd0 <pgfault+0x87>
		panic("sys_page_map: %e", r);
  800fbe:	50                   	push   %eax
  800fbf:	68 ca 30 80 00       	push   $0x8030ca
  800fc4:	6a 33                	push   $0x33
  800fc6:	68 db 30 80 00       	push   $0x8030db
  800fcb:	e8 08 f2 ff ff       	call   8001d8 <_panic>

	// Unmap the temp location
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800fd0:	83 ec 08             	sub    $0x8,%esp
  800fd3:	68 00 f0 7f 00       	push   $0x7ff000
  800fd8:	6a 00                	push   $0x0
  800fda:	e8 df fc ff ff       	call   800cbe <sys_page_unmap>
  800fdf:	83 c4 10             	add    $0x10,%esp
  800fe2:	85 c0                	test   %eax,%eax
  800fe4:	79 12                	jns    800ff8 <pgfault+0xaf>
		panic("sys_page_unmap: %e", r);
  800fe6:	50                   	push   %eax
  800fe7:	68 e6 30 80 00       	push   $0x8030e6
  800fec:	6a 37                	push   $0x37
  800fee:	68 db 30 80 00       	push   $0x8030db
  800ff3:	e8 e0 f1 ff ff       	call   8001d8 <_panic>
}
  800ff8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ffb:	c9                   	leave  
  800ffc:	c3                   	ret    

00800ffd <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ffd:	55                   	push   %ebp
  800ffe:	89 e5                	mov    %esp,%ebp
  801000:	56                   	push   %esi
  801001:	53                   	push   %ebx
  801002:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
	// Set up page fault handler
	set_pgfault_handler(&pgfault);
  801005:	68 49 0f 80 00       	push   $0x800f49
  80100a:	e8 60 18 00 00       	call   80286f <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  80100f:	b8 07 00 00 00       	mov    $0x7,%eax
  801014:	cd 30                	int    $0x30

	// Create child
	envid_t envid = sys_exofork();
  801016:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (envid < 0) {
  801019:	83 c4 10             	add    $0x10,%esp
  80101c:	85 c0                	test   %eax,%eax
  80101e:	79 12                	jns    801032 <fork+0x35>
		panic("sys_exofork: %e", envid);
  801020:	50                   	push   %eax
  801021:	68 f9 30 80 00       	push   $0x8030f9
  801026:	6a 7c                	push   $0x7c
  801028:	68 db 30 80 00       	push   $0x8030db
  80102d:	e8 a6 f1 ff ff       	call   8001d8 <_panic>
		return envid;
	}
	if (envid == 0) {
  801032:	85 c0                	test   %eax,%eax
  801034:	75 1e                	jne    801054 <fork+0x57>
		// We are the child.
		thisenv = &envs[ENVX(sys_getenvid())]; // Fix thisenv
  801036:	e8 c0 fb ff ff       	call   800bfb <sys_getenvid>
  80103b:	25 ff 03 00 00       	and    $0x3ff,%eax
  801040:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801043:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801048:	a3 08 50 80 00       	mov    %eax,0x805008
		return 0;
  80104d:	b8 00 00 00 00       	mov    $0x0,%eax
  801052:	eb 7d                	jmp    8010d1 <fork+0xd4>

	// Set page fault handler on the child.
	// The parent needs to do it, else the child wouldn't be able to handle
	// the fault when trying to access it's stack (which happens as soon it starts)
	extern void _pgfault_upcall(void);
	sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);
  801054:	83 ec 04             	sub    $0x4,%esp
  801057:	6a 07                	push   $0x7
  801059:	68 00 f0 bf ee       	push   $0xeebff000
  80105e:	50                   	push   %eax
  80105f:	e8 d5 fb ff ff       	call   800c39 <sys_page_alloc>
	sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  801064:	83 c4 08             	add    $0x8,%esp
  801067:	68 b4 28 80 00       	push   $0x8028b4
  80106c:	ff 75 f4             	pushl  -0xc(%ebp)
  80106f:	e8 10 fd ff ff       	call   800d84 <sys_env_set_pgfault_upcall>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  801074:	be 04 80 80 00       	mov    $0x808004,%esi
  801079:	c1 ee 0c             	shr    $0xc,%esi
  80107c:	83 c4 10             	add    $0x10,%esp
  80107f:	bb 00 08 00 00       	mov    $0x800,%ebx
  801084:	eb 0d                	jmp    801093 <fork+0x96>
		duppage(envid, pn);
  801086:	89 da                	mov    %ebx,%edx
  801088:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80108b:	e8 b9 fd ff ff       	call   800e49 <duppage>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  801090:	83 c3 01             	add    $0x1,%ebx
  801093:	39 f3                	cmp    %esi,%ebx
  801095:	76 ef                	jbe    801086 <fork+0x89>
	}

	// Also copy the stack we are currently running on
	// I think it should loop from ustacktop to this page, since the stack
	// can have more than 1 page
	duppage(envid, ((uint32_t) &envid)/PGSIZE);
  801097:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80109a:	c1 ea 0c             	shr    $0xc,%edx
  80109d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010a0:	e8 a4 fd ff ff       	call   800e49 <duppage>

	// Start the child environmnet running
	int r;
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  8010a5:	83 ec 08             	sub    $0x8,%esp
  8010a8:	6a 02                	push   $0x2
  8010aa:	ff 75 f4             	pushl  -0xc(%ebp)
  8010ad:	e8 4e fc ff ff       	call   800d00 <sys_env_set_status>
  8010b2:	83 c4 10             	add    $0x10,%esp
  8010b5:	85 c0                	test   %eax,%eax
  8010b7:	79 15                	jns    8010ce <fork+0xd1>
		panic("sys_env_set_status: %e", r);
  8010b9:	50                   	push   %eax
  8010ba:	68 09 31 80 00       	push   $0x803109
  8010bf:	68 9c 00 00 00       	push   $0x9c
  8010c4:	68 db 30 80 00       	push   $0x8030db
  8010c9:	e8 0a f1 ff ff       	call   8001d8 <_panic>
		return r;
	}

	return envid;
  8010ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8010d1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010d4:	5b                   	pop    %ebx
  8010d5:	5e                   	pop    %esi
  8010d6:	5d                   	pop    %ebp
  8010d7:	c3                   	ret    

008010d8 <sfork>:

// Challenge!
int
sfork(void)
{
  8010d8:	55                   	push   %ebp
  8010d9:	89 e5                	mov    %esp,%ebp
  8010db:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010de:	68 20 31 80 00       	push   $0x803120
  8010e3:	68 a7 00 00 00       	push   $0xa7
  8010e8:	68 db 30 80 00       	push   $0x8030db
  8010ed:	e8 e6 f0 ff ff       	call   8001d8 <_panic>

008010f2 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010f2:	55                   	push   %ebp
  8010f3:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f8:	05 00 00 00 30       	add    $0x30000000,%eax
  8010fd:	c1 e8 0c             	shr    $0xc,%eax
}
  801100:	5d                   	pop    %ebp
  801101:	c3                   	ret    

00801102 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801102:	55                   	push   %ebp
  801103:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801105:	8b 45 08             	mov    0x8(%ebp),%eax
  801108:	05 00 00 00 30       	add    $0x30000000,%eax
  80110d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801112:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801117:	5d                   	pop    %ebp
  801118:	c3                   	ret    

00801119 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801119:	55                   	push   %ebp
  80111a:	89 e5                	mov    %esp,%ebp
  80111c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80111f:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801124:	89 c2                	mov    %eax,%edx
  801126:	c1 ea 16             	shr    $0x16,%edx
  801129:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801130:	f6 c2 01             	test   $0x1,%dl
  801133:	74 11                	je     801146 <fd_alloc+0x2d>
  801135:	89 c2                	mov    %eax,%edx
  801137:	c1 ea 0c             	shr    $0xc,%edx
  80113a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801141:	f6 c2 01             	test   $0x1,%dl
  801144:	75 09                	jne    80114f <fd_alloc+0x36>
			*fd_store = fd;
  801146:	89 01                	mov    %eax,(%ecx)
			return 0;
  801148:	b8 00 00 00 00       	mov    $0x0,%eax
  80114d:	eb 17                	jmp    801166 <fd_alloc+0x4d>
  80114f:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801154:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801159:	75 c9                	jne    801124 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80115b:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801161:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801166:	5d                   	pop    %ebp
  801167:	c3                   	ret    

00801168 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801168:	55                   	push   %ebp
  801169:	89 e5                	mov    %esp,%ebp
  80116b:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80116e:	83 f8 1f             	cmp    $0x1f,%eax
  801171:	77 36                	ja     8011a9 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801173:	c1 e0 0c             	shl    $0xc,%eax
  801176:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80117b:	89 c2                	mov    %eax,%edx
  80117d:	c1 ea 16             	shr    $0x16,%edx
  801180:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801187:	f6 c2 01             	test   $0x1,%dl
  80118a:	74 24                	je     8011b0 <fd_lookup+0x48>
  80118c:	89 c2                	mov    %eax,%edx
  80118e:	c1 ea 0c             	shr    $0xc,%edx
  801191:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801198:	f6 c2 01             	test   $0x1,%dl
  80119b:	74 1a                	je     8011b7 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80119d:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011a0:	89 02                	mov    %eax,(%edx)
	return 0;
  8011a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8011a7:	eb 13                	jmp    8011bc <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011a9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011ae:	eb 0c                	jmp    8011bc <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011b0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011b5:	eb 05                	jmp    8011bc <fd_lookup+0x54>
  8011b7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8011bc:	5d                   	pop    %ebp
  8011bd:	c3                   	ret    

008011be <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011be:	55                   	push   %ebp
  8011bf:	89 e5                	mov    %esp,%ebp
  8011c1:	83 ec 08             	sub    $0x8,%esp
  8011c4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011c7:	ba b4 31 80 00       	mov    $0x8031b4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8011cc:	eb 13                	jmp    8011e1 <dev_lookup+0x23>
  8011ce:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8011d1:	39 08                	cmp    %ecx,(%eax)
  8011d3:	75 0c                	jne    8011e1 <dev_lookup+0x23>
			*dev = devtab[i];
  8011d5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011d8:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011da:	b8 00 00 00 00       	mov    $0x0,%eax
  8011df:	eb 2e                	jmp    80120f <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011e1:	8b 02                	mov    (%edx),%eax
  8011e3:	85 c0                	test   %eax,%eax
  8011e5:	75 e7                	jne    8011ce <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011e7:	a1 08 50 80 00       	mov    0x805008,%eax
  8011ec:	8b 40 48             	mov    0x48(%eax),%eax
  8011ef:	83 ec 04             	sub    $0x4,%esp
  8011f2:	51                   	push   %ecx
  8011f3:	50                   	push   %eax
  8011f4:	68 38 31 80 00       	push   $0x803138
  8011f9:	e8 b3 f0 ff ff       	call   8002b1 <cprintf>
	*dev = 0;
  8011fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  801201:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801207:	83 c4 10             	add    $0x10,%esp
  80120a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80120f:	c9                   	leave  
  801210:	c3                   	ret    

00801211 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801211:	55                   	push   %ebp
  801212:	89 e5                	mov    %esp,%ebp
  801214:	56                   	push   %esi
  801215:	53                   	push   %ebx
  801216:	83 ec 10             	sub    $0x10,%esp
  801219:	8b 75 08             	mov    0x8(%ebp),%esi
  80121c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80121f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801222:	50                   	push   %eax
  801223:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801229:	c1 e8 0c             	shr    $0xc,%eax
  80122c:	50                   	push   %eax
  80122d:	e8 36 ff ff ff       	call   801168 <fd_lookup>
  801232:	83 c4 08             	add    $0x8,%esp
  801235:	85 c0                	test   %eax,%eax
  801237:	78 05                	js     80123e <fd_close+0x2d>
	    || fd != fd2)
  801239:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80123c:	74 0c                	je     80124a <fd_close+0x39>
		return (must_exist ? r : 0);
  80123e:	84 db                	test   %bl,%bl
  801240:	ba 00 00 00 00       	mov    $0x0,%edx
  801245:	0f 44 c2             	cmove  %edx,%eax
  801248:	eb 41                	jmp    80128b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80124a:	83 ec 08             	sub    $0x8,%esp
  80124d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801250:	50                   	push   %eax
  801251:	ff 36                	pushl  (%esi)
  801253:	e8 66 ff ff ff       	call   8011be <dev_lookup>
  801258:	89 c3                	mov    %eax,%ebx
  80125a:	83 c4 10             	add    $0x10,%esp
  80125d:	85 c0                	test   %eax,%eax
  80125f:	78 1a                	js     80127b <fd_close+0x6a>
		if (dev->dev_close)
  801261:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801264:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801267:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80126c:	85 c0                	test   %eax,%eax
  80126e:	74 0b                	je     80127b <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801270:	83 ec 0c             	sub    $0xc,%esp
  801273:	56                   	push   %esi
  801274:	ff d0                	call   *%eax
  801276:	89 c3                	mov    %eax,%ebx
  801278:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80127b:	83 ec 08             	sub    $0x8,%esp
  80127e:	56                   	push   %esi
  80127f:	6a 00                	push   $0x0
  801281:	e8 38 fa ff ff       	call   800cbe <sys_page_unmap>
	return r;
  801286:	83 c4 10             	add    $0x10,%esp
  801289:	89 d8                	mov    %ebx,%eax
}
  80128b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80128e:	5b                   	pop    %ebx
  80128f:	5e                   	pop    %esi
  801290:	5d                   	pop    %ebp
  801291:	c3                   	ret    

00801292 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801292:	55                   	push   %ebp
  801293:	89 e5                	mov    %esp,%ebp
  801295:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801298:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80129b:	50                   	push   %eax
  80129c:	ff 75 08             	pushl  0x8(%ebp)
  80129f:	e8 c4 fe ff ff       	call   801168 <fd_lookup>
  8012a4:	83 c4 08             	add    $0x8,%esp
  8012a7:	85 c0                	test   %eax,%eax
  8012a9:	78 10                	js     8012bb <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8012ab:	83 ec 08             	sub    $0x8,%esp
  8012ae:	6a 01                	push   $0x1
  8012b0:	ff 75 f4             	pushl  -0xc(%ebp)
  8012b3:	e8 59 ff ff ff       	call   801211 <fd_close>
  8012b8:	83 c4 10             	add    $0x10,%esp
}
  8012bb:	c9                   	leave  
  8012bc:	c3                   	ret    

008012bd <close_all>:

void
close_all(void)
{
  8012bd:	55                   	push   %ebp
  8012be:	89 e5                	mov    %esp,%ebp
  8012c0:	53                   	push   %ebx
  8012c1:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012c4:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012c9:	83 ec 0c             	sub    $0xc,%esp
  8012cc:	53                   	push   %ebx
  8012cd:	e8 c0 ff ff ff       	call   801292 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8012d2:	83 c3 01             	add    $0x1,%ebx
  8012d5:	83 c4 10             	add    $0x10,%esp
  8012d8:	83 fb 20             	cmp    $0x20,%ebx
  8012db:	75 ec                	jne    8012c9 <close_all+0xc>
		close(i);
}
  8012dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012e0:	c9                   	leave  
  8012e1:	c3                   	ret    

008012e2 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012e2:	55                   	push   %ebp
  8012e3:	89 e5                	mov    %esp,%ebp
  8012e5:	57                   	push   %edi
  8012e6:	56                   	push   %esi
  8012e7:	53                   	push   %ebx
  8012e8:	83 ec 2c             	sub    $0x2c,%esp
  8012eb:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012ee:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012f1:	50                   	push   %eax
  8012f2:	ff 75 08             	pushl  0x8(%ebp)
  8012f5:	e8 6e fe ff ff       	call   801168 <fd_lookup>
  8012fa:	83 c4 08             	add    $0x8,%esp
  8012fd:	85 c0                	test   %eax,%eax
  8012ff:	0f 88 c1 00 00 00    	js     8013c6 <dup+0xe4>
		return r;
	close(newfdnum);
  801305:	83 ec 0c             	sub    $0xc,%esp
  801308:	56                   	push   %esi
  801309:	e8 84 ff ff ff       	call   801292 <close>

	newfd = INDEX2FD(newfdnum);
  80130e:	89 f3                	mov    %esi,%ebx
  801310:	c1 e3 0c             	shl    $0xc,%ebx
  801313:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801319:	83 c4 04             	add    $0x4,%esp
  80131c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80131f:	e8 de fd ff ff       	call   801102 <fd2data>
  801324:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801326:	89 1c 24             	mov    %ebx,(%esp)
  801329:	e8 d4 fd ff ff       	call   801102 <fd2data>
  80132e:	83 c4 10             	add    $0x10,%esp
  801331:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801334:	89 f8                	mov    %edi,%eax
  801336:	c1 e8 16             	shr    $0x16,%eax
  801339:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801340:	a8 01                	test   $0x1,%al
  801342:	74 37                	je     80137b <dup+0x99>
  801344:	89 f8                	mov    %edi,%eax
  801346:	c1 e8 0c             	shr    $0xc,%eax
  801349:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801350:	f6 c2 01             	test   $0x1,%dl
  801353:	74 26                	je     80137b <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801355:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80135c:	83 ec 0c             	sub    $0xc,%esp
  80135f:	25 07 0e 00 00       	and    $0xe07,%eax
  801364:	50                   	push   %eax
  801365:	ff 75 d4             	pushl  -0x2c(%ebp)
  801368:	6a 00                	push   $0x0
  80136a:	57                   	push   %edi
  80136b:	6a 00                	push   $0x0
  80136d:	e8 0a f9 ff ff       	call   800c7c <sys_page_map>
  801372:	89 c7                	mov    %eax,%edi
  801374:	83 c4 20             	add    $0x20,%esp
  801377:	85 c0                	test   %eax,%eax
  801379:	78 2e                	js     8013a9 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80137b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80137e:	89 d0                	mov    %edx,%eax
  801380:	c1 e8 0c             	shr    $0xc,%eax
  801383:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80138a:	83 ec 0c             	sub    $0xc,%esp
  80138d:	25 07 0e 00 00       	and    $0xe07,%eax
  801392:	50                   	push   %eax
  801393:	53                   	push   %ebx
  801394:	6a 00                	push   $0x0
  801396:	52                   	push   %edx
  801397:	6a 00                	push   $0x0
  801399:	e8 de f8 ff ff       	call   800c7c <sys_page_map>
  80139e:	89 c7                	mov    %eax,%edi
  8013a0:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8013a3:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013a5:	85 ff                	test   %edi,%edi
  8013a7:	79 1d                	jns    8013c6 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013a9:	83 ec 08             	sub    $0x8,%esp
  8013ac:	53                   	push   %ebx
  8013ad:	6a 00                	push   $0x0
  8013af:	e8 0a f9 ff ff       	call   800cbe <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013b4:	83 c4 08             	add    $0x8,%esp
  8013b7:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013ba:	6a 00                	push   $0x0
  8013bc:	e8 fd f8 ff ff       	call   800cbe <sys_page_unmap>
	return r;
  8013c1:	83 c4 10             	add    $0x10,%esp
  8013c4:	89 f8                	mov    %edi,%eax
}
  8013c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013c9:	5b                   	pop    %ebx
  8013ca:	5e                   	pop    %esi
  8013cb:	5f                   	pop    %edi
  8013cc:	5d                   	pop    %ebp
  8013cd:	c3                   	ret    

008013ce <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013ce:	55                   	push   %ebp
  8013cf:	89 e5                	mov    %esp,%ebp
  8013d1:	53                   	push   %ebx
  8013d2:	83 ec 14             	sub    $0x14,%esp
  8013d5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013d8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013db:	50                   	push   %eax
  8013dc:	53                   	push   %ebx
  8013dd:	e8 86 fd ff ff       	call   801168 <fd_lookup>
  8013e2:	83 c4 08             	add    $0x8,%esp
  8013e5:	89 c2                	mov    %eax,%edx
  8013e7:	85 c0                	test   %eax,%eax
  8013e9:	78 6d                	js     801458 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013eb:	83 ec 08             	sub    $0x8,%esp
  8013ee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013f1:	50                   	push   %eax
  8013f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013f5:	ff 30                	pushl  (%eax)
  8013f7:	e8 c2 fd ff ff       	call   8011be <dev_lookup>
  8013fc:	83 c4 10             	add    $0x10,%esp
  8013ff:	85 c0                	test   %eax,%eax
  801401:	78 4c                	js     80144f <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801403:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801406:	8b 42 08             	mov    0x8(%edx),%eax
  801409:	83 e0 03             	and    $0x3,%eax
  80140c:	83 f8 01             	cmp    $0x1,%eax
  80140f:	75 21                	jne    801432 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801411:	a1 08 50 80 00       	mov    0x805008,%eax
  801416:	8b 40 48             	mov    0x48(%eax),%eax
  801419:	83 ec 04             	sub    $0x4,%esp
  80141c:	53                   	push   %ebx
  80141d:	50                   	push   %eax
  80141e:	68 79 31 80 00       	push   $0x803179
  801423:	e8 89 ee ff ff       	call   8002b1 <cprintf>
		return -E_INVAL;
  801428:	83 c4 10             	add    $0x10,%esp
  80142b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801430:	eb 26                	jmp    801458 <read+0x8a>
	}
	if (!dev->dev_read)
  801432:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801435:	8b 40 08             	mov    0x8(%eax),%eax
  801438:	85 c0                	test   %eax,%eax
  80143a:	74 17                	je     801453 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80143c:	83 ec 04             	sub    $0x4,%esp
  80143f:	ff 75 10             	pushl  0x10(%ebp)
  801442:	ff 75 0c             	pushl  0xc(%ebp)
  801445:	52                   	push   %edx
  801446:	ff d0                	call   *%eax
  801448:	89 c2                	mov    %eax,%edx
  80144a:	83 c4 10             	add    $0x10,%esp
  80144d:	eb 09                	jmp    801458 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80144f:	89 c2                	mov    %eax,%edx
  801451:	eb 05                	jmp    801458 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801453:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801458:	89 d0                	mov    %edx,%eax
  80145a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80145d:	c9                   	leave  
  80145e:	c3                   	ret    

0080145f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80145f:	55                   	push   %ebp
  801460:	89 e5                	mov    %esp,%ebp
  801462:	57                   	push   %edi
  801463:	56                   	push   %esi
  801464:	53                   	push   %ebx
  801465:	83 ec 0c             	sub    $0xc,%esp
  801468:	8b 7d 08             	mov    0x8(%ebp),%edi
  80146b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80146e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801473:	eb 21                	jmp    801496 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801475:	83 ec 04             	sub    $0x4,%esp
  801478:	89 f0                	mov    %esi,%eax
  80147a:	29 d8                	sub    %ebx,%eax
  80147c:	50                   	push   %eax
  80147d:	89 d8                	mov    %ebx,%eax
  80147f:	03 45 0c             	add    0xc(%ebp),%eax
  801482:	50                   	push   %eax
  801483:	57                   	push   %edi
  801484:	e8 45 ff ff ff       	call   8013ce <read>
		if (m < 0)
  801489:	83 c4 10             	add    $0x10,%esp
  80148c:	85 c0                	test   %eax,%eax
  80148e:	78 10                	js     8014a0 <readn+0x41>
			return m;
		if (m == 0)
  801490:	85 c0                	test   %eax,%eax
  801492:	74 0a                	je     80149e <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801494:	01 c3                	add    %eax,%ebx
  801496:	39 f3                	cmp    %esi,%ebx
  801498:	72 db                	jb     801475 <readn+0x16>
  80149a:	89 d8                	mov    %ebx,%eax
  80149c:	eb 02                	jmp    8014a0 <readn+0x41>
  80149e:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8014a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014a3:	5b                   	pop    %ebx
  8014a4:	5e                   	pop    %esi
  8014a5:	5f                   	pop    %edi
  8014a6:	5d                   	pop    %ebp
  8014a7:	c3                   	ret    

008014a8 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014a8:	55                   	push   %ebp
  8014a9:	89 e5                	mov    %esp,%ebp
  8014ab:	53                   	push   %ebx
  8014ac:	83 ec 14             	sub    $0x14,%esp
  8014af:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014b2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014b5:	50                   	push   %eax
  8014b6:	53                   	push   %ebx
  8014b7:	e8 ac fc ff ff       	call   801168 <fd_lookup>
  8014bc:	83 c4 08             	add    $0x8,%esp
  8014bf:	89 c2                	mov    %eax,%edx
  8014c1:	85 c0                	test   %eax,%eax
  8014c3:	78 68                	js     80152d <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014c5:	83 ec 08             	sub    $0x8,%esp
  8014c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014cb:	50                   	push   %eax
  8014cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014cf:	ff 30                	pushl  (%eax)
  8014d1:	e8 e8 fc ff ff       	call   8011be <dev_lookup>
  8014d6:	83 c4 10             	add    $0x10,%esp
  8014d9:	85 c0                	test   %eax,%eax
  8014db:	78 47                	js     801524 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014e0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014e4:	75 21                	jne    801507 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014e6:	a1 08 50 80 00       	mov    0x805008,%eax
  8014eb:	8b 40 48             	mov    0x48(%eax),%eax
  8014ee:	83 ec 04             	sub    $0x4,%esp
  8014f1:	53                   	push   %ebx
  8014f2:	50                   	push   %eax
  8014f3:	68 95 31 80 00       	push   $0x803195
  8014f8:	e8 b4 ed ff ff       	call   8002b1 <cprintf>
		return -E_INVAL;
  8014fd:	83 c4 10             	add    $0x10,%esp
  801500:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801505:	eb 26                	jmp    80152d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801507:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80150a:	8b 52 0c             	mov    0xc(%edx),%edx
  80150d:	85 d2                	test   %edx,%edx
  80150f:	74 17                	je     801528 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801511:	83 ec 04             	sub    $0x4,%esp
  801514:	ff 75 10             	pushl  0x10(%ebp)
  801517:	ff 75 0c             	pushl  0xc(%ebp)
  80151a:	50                   	push   %eax
  80151b:	ff d2                	call   *%edx
  80151d:	89 c2                	mov    %eax,%edx
  80151f:	83 c4 10             	add    $0x10,%esp
  801522:	eb 09                	jmp    80152d <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801524:	89 c2                	mov    %eax,%edx
  801526:	eb 05                	jmp    80152d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801528:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80152d:	89 d0                	mov    %edx,%eax
  80152f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801532:	c9                   	leave  
  801533:	c3                   	ret    

00801534 <seek>:

int
seek(int fdnum, off_t offset)
{
  801534:	55                   	push   %ebp
  801535:	89 e5                	mov    %esp,%ebp
  801537:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80153a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80153d:	50                   	push   %eax
  80153e:	ff 75 08             	pushl  0x8(%ebp)
  801541:	e8 22 fc ff ff       	call   801168 <fd_lookup>
  801546:	83 c4 08             	add    $0x8,%esp
  801549:	85 c0                	test   %eax,%eax
  80154b:	78 0e                	js     80155b <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80154d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801550:	8b 55 0c             	mov    0xc(%ebp),%edx
  801553:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801556:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80155b:	c9                   	leave  
  80155c:	c3                   	ret    

0080155d <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80155d:	55                   	push   %ebp
  80155e:	89 e5                	mov    %esp,%ebp
  801560:	53                   	push   %ebx
  801561:	83 ec 14             	sub    $0x14,%esp
  801564:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801567:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80156a:	50                   	push   %eax
  80156b:	53                   	push   %ebx
  80156c:	e8 f7 fb ff ff       	call   801168 <fd_lookup>
  801571:	83 c4 08             	add    $0x8,%esp
  801574:	89 c2                	mov    %eax,%edx
  801576:	85 c0                	test   %eax,%eax
  801578:	78 65                	js     8015df <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80157a:	83 ec 08             	sub    $0x8,%esp
  80157d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801580:	50                   	push   %eax
  801581:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801584:	ff 30                	pushl  (%eax)
  801586:	e8 33 fc ff ff       	call   8011be <dev_lookup>
  80158b:	83 c4 10             	add    $0x10,%esp
  80158e:	85 c0                	test   %eax,%eax
  801590:	78 44                	js     8015d6 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801592:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801595:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801599:	75 21                	jne    8015bc <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80159b:	a1 08 50 80 00       	mov    0x805008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015a0:	8b 40 48             	mov    0x48(%eax),%eax
  8015a3:	83 ec 04             	sub    $0x4,%esp
  8015a6:	53                   	push   %ebx
  8015a7:	50                   	push   %eax
  8015a8:	68 58 31 80 00       	push   $0x803158
  8015ad:	e8 ff ec ff ff       	call   8002b1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015b2:	83 c4 10             	add    $0x10,%esp
  8015b5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015ba:	eb 23                	jmp    8015df <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8015bc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015bf:	8b 52 18             	mov    0x18(%edx),%edx
  8015c2:	85 d2                	test   %edx,%edx
  8015c4:	74 14                	je     8015da <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015c6:	83 ec 08             	sub    $0x8,%esp
  8015c9:	ff 75 0c             	pushl  0xc(%ebp)
  8015cc:	50                   	push   %eax
  8015cd:	ff d2                	call   *%edx
  8015cf:	89 c2                	mov    %eax,%edx
  8015d1:	83 c4 10             	add    $0x10,%esp
  8015d4:	eb 09                	jmp    8015df <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015d6:	89 c2                	mov    %eax,%edx
  8015d8:	eb 05                	jmp    8015df <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8015da:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8015df:	89 d0                	mov    %edx,%eax
  8015e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015e4:	c9                   	leave  
  8015e5:	c3                   	ret    

008015e6 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015e6:	55                   	push   %ebp
  8015e7:	89 e5                	mov    %esp,%ebp
  8015e9:	53                   	push   %ebx
  8015ea:	83 ec 14             	sub    $0x14,%esp
  8015ed:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015f0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015f3:	50                   	push   %eax
  8015f4:	ff 75 08             	pushl  0x8(%ebp)
  8015f7:	e8 6c fb ff ff       	call   801168 <fd_lookup>
  8015fc:	83 c4 08             	add    $0x8,%esp
  8015ff:	89 c2                	mov    %eax,%edx
  801601:	85 c0                	test   %eax,%eax
  801603:	78 58                	js     80165d <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801605:	83 ec 08             	sub    $0x8,%esp
  801608:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80160b:	50                   	push   %eax
  80160c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80160f:	ff 30                	pushl  (%eax)
  801611:	e8 a8 fb ff ff       	call   8011be <dev_lookup>
  801616:	83 c4 10             	add    $0x10,%esp
  801619:	85 c0                	test   %eax,%eax
  80161b:	78 37                	js     801654 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80161d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801620:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801624:	74 32                	je     801658 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801626:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801629:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801630:	00 00 00 
	stat->st_isdir = 0;
  801633:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80163a:	00 00 00 
	stat->st_dev = dev;
  80163d:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801643:	83 ec 08             	sub    $0x8,%esp
  801646:	53                   	push   %ebx
  801647:	ff 75 f0             	pushl  -0x10(%ebp)
  80164a:	ff 50 14             	call   *0x14(%eax)
  80164d:	89 c2                	mov    %eax,%edx
  80164f:	83 c4 10             	add    $0x10,%esp
  801652:	eb 09                	jmp    80165d <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801654:	89 c2                	mov    %eax,%edx
  801656:	eb 05                	jmp    80165d <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801658:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80165d:	89 d0                	mov    %edx,%eax
  80165f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801662:	c9                   	leave  
  801663:	c3                   	ret    

00801664 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801664:	55                   	push   %ebp
  801665:	89 e5                	mov    %esp,%ebp
  801667:	56                   	push   %esi
  801668:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801669:	83 ec 08             	sub    $0x8,%esp
  80166c:	6a 00                	push   $0x0
  80166e:	ff 75 08             	pushl  0x8(%ebp)
  801671:	e8 0c 02 00 00       	call   801882 <open>
  801676:	89 c3                	mov    %eax,%ebx
  801678:	83 c4 10             	add    $0x10,%esp
  80167b:	85 c0                	test   %eax,%eax
  80167d:	78 1b                	js     80169a <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80167f:	83 ec 08             	sub    $0x8,%esp
  801682:	ff 75 0c             	pushl  0xc(%ebp)
  801685:	50                   	push   %eax
  801686:	e8 5b ff ff ff       	call   8015e6 <fstat>
  80168b:	89 c6                	mov    %eax,%esi
	close(fd);
  80168d:	89 1c 24             	mov    %ebx,(%esp)
  801690:	e8 fd fb ff ff       	call   801292 <close>
	return r;
  801695:	83 c4 10             	add    $0x10,%esp
  801698:	89 f0                	mov    %esi,%eax
}
  80169a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80169d:	5b                   	pop    %ebx
  80169e:	5e                   	pop    %esi
  80169f:	5d                   	pop    %ebp
  8016a0:	c3                   	ret    

008016a1 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016a1:	55                   	push   %ebp
  8016a2:	89 e5                	mov    %esp,%ebp
  8016a4:	56                   	push   %esi
  8016a5:	53                   	push   %ebx
  8016a6:	89 c6                	mov    %eax,%esi
  8016a8:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016aa:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8016b1:	75 12                	jne    8016c5 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016b3:	83 ec 0c             	sub    $0xc,%esp
  8016b6:	6a 01                	push   $0x1
  8016b8:	e8 e5 12 00 00       	call   8029a2 <ipc_find_env>
  8016bd:	a3 00 50 80 00       	mov    %eax,0x805000
  8016c2:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016c5:	6a 07                	push   $0x7
  8016c7:	68 00 60 80 00       	push   $0x806000
  8016cc:	56                   	push   %esi
  8016cd:	ff 35 00 50 80 00    	pushl  0x805000
  8016d3:	e8 76 12 00 00       	call   80294e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016d8:	83 c4 0c             	add    $0xc,%esp
  8016db:	6a 00                	push   $0x0
  8016dd:	53                   	push   %ebx
  8016de:	6a 00                	push   $0x0
  8016e0:	e8 00 12 00 00       	call   8028e5 <ipc_recv>
}
  8016e5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016e8:	5b                   	pop    %ebx
  8016e9:	5e                   	pop    %esi
  8016ea:	5d                   	pop    %ebp
  8016eb:	c3                   	ret    

008016ec <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016ec:	55                   	push   %ebp
  8016ed:	89 e5                	mov    %esp,%ebp
  8016ef:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f5:	8b 40 0c             	mov    0xc(%eax),%eax
  8016f8:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  8016fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801700:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801705:	ba 00 00 00 00       	mov    $0x0,%edx
  80170a:	b8 02 00 00 00       	mov    $0x2,%eax
  80170f:	e8 8d ff ff ff       	call   8016a1 <fsipc>
}
  801714:	c9                   	leave  
  801715:	c3                   	ret    

00801716 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801716:	55                   	push   %ebp
  801717:	89 e5                	mov    %esp,%ebp
  801719:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80171c:	8b 45 08             	mov    0x8(%ebp),%eax
  80171f:	8b 40 0c             	mov    0xc(%eax),%eax
  801722:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801727:	ba 00 00 00 00       	mov    $0x0,%edx
  80172c:	b8 06 00 00 00       	mov    $0x6,%eax
  801731:	e8 6b ff ff ff       	call   8016a1 <fsipc>
}
  801736:	c9                   	leave  
  801737:	c3                   	ret    

00801738 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801738:	55                   	push   %ebp
  801739:	89 e5                	mov    %esp,%ebp
  80173b:	53                   	push   %ebx
  80173c:	83 ec 04             	sub    $0x4,%esp
  80173f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801742:	8b 45 08             	mov    0x8(%ebp),%eax
  801745:	8b 40 0c             	mov    0xc(%eax),%eax
  801748:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80174d:	ba 00 00 00 00       	mov    $0x0,%edx
  801752:	b8 05 00 00 00       	mov    $0x5,%eax
  801757:	e8 45 ff ff ff       	call   8016a1 <fsipc>
  80175c:	85 c0                	test   %eax,%eax
  80175e:	78 2c                	js     80178c <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801760:	83 ec 08             	sub    $0x8,%esp
  801763:	68 00 60 80 00       	push   $0x806000
  801768:	53                   	push   %ebx
  801769:	e8 c8 f0 ff ff       	call   800836 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80176e:	a1 80 60 80 00       	mov    0x806080,%eax
  801773:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801779:	a1 84 60 80 00       	mov    0x806084,%eax
  80177e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801784:	83 c4 10             	add    $0x10,%esp
  801787:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80178c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80178f:	c9                   	leave  
  801790:	c3                   	ret    

00801791 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801791:	55                   	push   %ebp
  801792:	89 e5                	mov    %esp,%ebp
  801794:	53                   	push   %ebx
  801795:	83 ec 08             	sub    $0x8,%esp
  801798:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80179b:	8b 55 08             	mov    0x8(%ebp),%edx
  80179e:	8b 52 0c             	mov    0xc(%edx),%edx
  8017a1:	89 15 00 60 80 00    	mov    %edx,0x806000
  8017a7:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8017ac:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  8017b1:	0f 46 d8             	cmovbe %eax,%ebx
	
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  8017b4:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  8017ba:	53                   	push   %ebx
  8017bb:	ff 75 0c             	pushl  0xc(%ebp)
  8017be:	68 08 60 80 00       	push   $0x806008
  8017c3:	e8 00 f2 ff ff       	call   8009c8 <memmove>

	
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) 
  8017c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8017cd:	b8 04 00 00 00       	mov    $0x4,%eax
  8017d2:	e8 ca fe ff ff       	call   8016a1 <fsipc>
  8017d7:	83 c4 10             	add    $0x10,%esp
  8017da:	85 c0                	test   %eax,%eax
  8017dc:	78 1d                	js     8017fb <devfile_write+0x6a>
		return r;
	assert(r <= n_real); 
  8017de:	39 d8                	cmp    %ebx,%eax
  8017e0:	76 19                	jbe    8017fb <devfile_write+0x6a>
  8017e2:	68 c8 31 80 00       	push   $0x8031c8
  8017e7:	68 d4 31 80 00       	push   $0x8031d4
  8017ec:	68 a3 00 00 00       	push   $0xa3
  8017f1:	68 e9 31 80 00       	push   $0x8031e9
  8017f6:	e8 dd e9 ff ff       	call   8001d8 <_panic>
	return r;
}
  8017fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017fe:	c9                   	leave  
  8017ff:	c3                   	ret    

00801800 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801800:	55                   	push   %ebp
  801801:	89 e5                	mov    %esp,%ebp
  801803:	56                   	push   %esi
  801804:	53                   	push   %ebx
  801805:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801808:	8b 45 08             	mov    0x8(%ebp),%eax
  80180b:	8b 40 0c             	mov    0xc(%eax),%eax
  80180e:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801813:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801819:	ba 00 00 00 00       	mov    $0x0,%edx
  80181e:	b8 03 00 00 00       	mov    $0x3,%eax
  801823:	e8 79 fe ff ff       	call   8016a1 <fsipc>
  801828:	89 c3                	mov    %eax,%ebx
  80182a:	85 c0                	test   %eax,%eax
  80182c:	78 4b                	js     801879 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80182e:	39 c6                	cmp    %eax,%esi
  801830:	73 16                	jae    801848 <devfile_read+0x48>
  801832:	68 f4 31 80 00       	push   $0x8031f4
  801837:	68 d4 31 80 00       	push   $0x8031d4
  80183c:	6a 7c                	push   $0x7c
  80183e:	68 e9 31 80 00       	push   $0x8031e9
  801843:	e8 90 e9 ff ff       	call   8001d8 <_panic>
	assert(r <= PGSIZE);
  801848:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80184d:	7e 16                	jle    801865 <devfile_read+0x65>
  80184f:	68 fb 31 80 00       	push   $0x8031fb
  801854:	68 d4 31 80 00       	push   $0x8031d4
  801859:	6a 7d                	push   $0x7d
  80185b:	68 e9 31 80 00       	push   $0x8031e9
  801860:	e8 73 e9 ff ff       	call   8001d8 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801865:	83 ec 04             	sub    $0x4,%esp
  801868:	50                   	push   %eax
  801869:	68 00 60 80 00       	push   $0x806000
  80186e:	ff 75 0c             	pushl  0xc(%ebp)
  801871:	e8 52 f1 ff ff       	call   8009c8 <memmove>
	return r;
  801876:	83 c4 10             	add    $0x10,%esp
}
  801879:	89 d8                	mov    %ebx,%eax
  80187b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80187e:	5b                   	pop    %ebx
  80187f:	5e                   	pop    %esi
  801880:	5d                   	pop    %ebp
  801881:	c3                   	ret    

00801882 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801882:	55                   	push   %ebp
  801883:	89 e5                	mov    %esp,%ebp
  801885:	53                   	push   %ebx
  801886:	83 ec 20             	sub    $0x20,%esp
  801889:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80188c:	53                   	push   %ebx
  80188d:	e8 6b ef ff ff       	call   8007fd <strlen>
  801892:	83 c4 10             	add    $0x10,%esp
  801895:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80189a:	7f 67                	jg     801903 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80189c:	83 ec 0c             	sub    $0xc,%esp
  80189f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018a2:	50                   	push   %eax
  8018a3:	e8 71 f8 ff ff       	call   801119 <fd_alloc>
  8018a8:	83 c4 10             	add    $0x10,%esp
		return r;
  8018ab:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018ad:	85 c0                	test   %eax,%eax
  8018af:	78 57                	js     801908 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018b1:	83 ec 08             	sub    $0x8,%esp
  8018b4:	53                   	push   %ebx
  8018b5:	68 00 60 80 00       	push   $0x806000
  8018ba:	e8 77 ef ff ff       	call   800836 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018c2:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018c7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018ca:	b8 01 00 00 00       	mov    $0x1,%eax
  8018cf:	e8 cd fd ff ff       	call   8016a1 <fsipc>
  8018d4:	89 c3                	mov    %eax,%ebx
  8018d6:	83 c4 10             	add    $0x10,%esp
  8018d9:	85 c0                	test   %eax,%eax
  8018db:	79 14                	jns    8018f1 <open+0x6f>
		fd_close(fd, 0);
  8018dd:	83 ec 08             	sub    $0x8,%esp
  8018e0:	6a 00                	push   $0x0
  8018e2:	ff 75 f4             	pushl  -0xc(%ebp)
  8018e5:	e8 27 f9 ff ff       	call   801211 <fd_close>
		return r;
  8018ea:	83 c4 10             	add    $0x10,%esp
  8018ed:	89 da                	mov    %ebx,%edx
  8018ef:	eb 17                	jmp    801908 <open+0x86>
	}

	return fd2num(fd);
  8018f1:	83 ec 0c             	sub    $0xc,%esp
  8018f4:	ff 75 f4             	pushl  -0xc(%ebp)
  8018f7:	e8 f6 f7 ff ff       	call   8010f2 <fd2num>
  8018fc:	89 c2                	mov    %eax,%edx
  8018fe:	83 c4 10             	add    $0x10,%esp
  801901:	eb 05                	jmp    801908 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801903:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801908:	89 d0                	mov    %edx,%eax
  80190a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80190d:	c9                   	leave  
  80190e:	c3                   	ret    

0080190f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80190f:	55                   	push   %ebp
  801910:	89 e5                	mov    %esp,%ebp
  801912:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801915:	ba 00 00 00 00       	mov    $0x0,%edx
  80191a:	b8 08 00 00 00       	mov    $0x8,%eax
  80191f:	e8 7d fd ff ff       	call   8016a1 <fsipc>
}
  801924:	c9                   	leave  
  801925:	c3                   	ret    

00801926 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801926:	55                   	push   %ebp
  801927:	89 e5                	mov    %esp,%ebp
  801929:	57                   	push   %edi
  80192a:	56                   	push   %esi
  80192b:	53                   	push   %ebx
  80192c:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801932:	6a 00                	push   $0x0
  801934:	ff 75 08             	pushl  0x8(%ebp)
  801937:	e8 46 ff ff ff       	call   801882 <open>
  80193c:	89 c7                	mov    %eax,%edi
  80193e:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801944:	83 c4 10             	add    $0x10,%esp
  801947:	85 c0                	test   %eax,%eax
  801949:	0f 88 ae 04 00 00    	js     801dfd <spawn+0x4d7>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  80194f:	83 ec 04             	sub    $0x4,%esp
  801952:	68 00 02 00 00       	push   $0x200
  801957:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  80195d:	50                   	push   %eax
  80195e:	57                   	push   %edi
  80195f:	e8 fb fa ff ff       	call   80145f <readn>
  801964:	83 c4 10             	add    $0x10,%esp
  801967:	3d 00 02 00 00       	cmp    $0x200,%eax
  80196c:	75 0c                	jne    80197a <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  80196e:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801975:	45 4c 46 
  801978:	74 33                	je     8019ad <spawn+0x87>
		close(fd);
  80197a:	83 ec 0c             	sub    $0xc,%esp
  80197d:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801983:	e8 0a f9 ff ff       	call   801292 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801988:	83 c4 0c             	add    $0xc,%esp
  80198b:	68 7f 45 4c 46       	push   $0x464c457f
  801990:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801996:	68 07 32 80 00       	push   $0x803207
  80199b:	e8 11 e9 ff ff       	call   8002b1 <cprintf>
		return -E_NOT_EXEC;
  8019a0:	83 c4 10             	add    $0x10,%esp
  8019a3:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  8019a8:	e9 b0 04 00 00       	jmp    801e5d <spawn+0x537>
  8019ad:	b8 07 00 00 00       	mov    $0x7,%eax
  8019b2:	cd 30                	int    $0x30
  8019b4:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  8019ba:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  8019c0:	85 c0                	test   %eax,%eax
  8019c2:	0f 88 3d 04 00 00    	js     801e05 <spawn+0x4df>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  8019c8:	89 c6                	mov    %eax,%esi
  8019ca:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  8019d0:	6b f6 7c             	imul   $0x7c,%esi,%esi
  8019d3:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  8019d9:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  8019df:	b9 11 00 00 00       	mov    $0x11,%ecx
  8019e4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  8019e6:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  8019ec:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8019f2:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  8019f7:	be 00 00 00 00       	mov    $0x0,%esi
  8019fc:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8019ff:	eb 13                	jmp    801a14 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801a01:	83 ec 0c             	sub    $0xc,%esp
  801a04:	50                   	push   %eax
  801a05:	e8 f3 ed ff ff       	call   8007fd <strlen>
  801a0a:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801a0e:	83 c3 01             	add    $0x1,%ebx
  801a11:	83 c4 10             	add    $0x10,%esp
  801a14:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801a1b:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801a1e:	85 c0                	test   %eax,%eax
  801a20:	75 df                	jne    801a01 <spawn+0xdb>
  801a22:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801a28:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801a2e:	bf 00 10 40 00       	mov    $0x401000,%edi
  801a33:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801a35:	89 fa                	mov    %edi,%edx
  801a37:	83 e2 fc             	and    $0xfffffffc,%edx
  801a3a:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801a41:	29 c2                	sub    %eax,%edx
  801a43:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801a49:	8d 42 f8             	lea    -0x8(%edx),%eax
  801a4c:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801a51:	0f 86 be 03 00 00    	jbe    801e15 <spawn+0x4ef>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801a57:	83 ec 04             	sub    $0x4,%esp
  801a5a:	6a 07                	push   $0x7
  801a5c:	68 00 00 40 00       	push   $0x400000
  801a61:	6a 00                	push   $0x0
  801a63:	e8 d1 f1 ff ff       	call   800c39 <sys_page_alloc>
  801a68:	83 c4 10             	add    $0x10,%esp
  801a6b:	85 c0                	test   %eax,%eax
  801a6d:	0f 88 a9 03 00 00    	js     801e1c <spawn+0x4f6>
  801a73:	be 00 00 00 00       	mov    $0x0,%esi
  801a78:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801a7e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a81:	eb 30                	jmp    801ab3 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801a83:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801a89:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801a8f:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801a92:	83 ec 08             	sub    $0x8,%esp
  801a95:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801a98:	57                   	push   %edi
  801a99:	e8 98 ed ff ff       	call   800836 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801a9e:	83 c4 04             	add    $0x4,%esp
  801aa1:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801aa4:	e8 54 ed ff ff       	call   8007fd <strlen>
  801aa9:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801aad:	83 c6 01             	add    $0x1,%esi
  801ab0:	83 c4 10             	add    $0x10,%esp
  801ab3:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801ab9:	7f c8                	jg     801a83 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801abb:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801ac1:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801ac7:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801ace:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801ad4:	74 19                	je     801aef <spawn+0x1c9>
  801ad6:	68 64 32 80 00       	push   $0x803264
  801adb:	68 d4 31 80 00       	push   $0x8031d4
  801ae0:	68 f2 00 00 00       	push   $0xf2
  801ae5:	68 21 32 80 00       	push   $0x803221
  801aea:	e8 e9 e6 ff ff       	call   8001d8 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801aef:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801af5:	89 f8                	mov    %edi,%eax
  801af7:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801afc:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801aff:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801b05:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801b08:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801b0e:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801b14:	83 ec 0c             	sub    $0xc,%esp
  801b17:	6a 07                	push   $0x7
  801b19:	68 00 d0 bf ee       	push   $0xeebfd000
  801b1e:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801b24:	68 00 00 40 00       	push   $0x400000
  801b29:	6a 00                	push   $0x0
  801b2b:	e8 4c f1 ff ff       	call   800c7c <sys_page_map>
  801b30:	89 c3                	mov    %eax,%ebx
  801b32:	83 c4 20             	add    $0x20,%esp
  801b35:	85 c0                	test   %eax,%eax
  801b37:	0f 88 0e 03 00 00    	js     801e4b <spawn+0x525>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801b3d:	83 ec 08             	sub    $0x8,%esp
  801b40:	68 00 00 40 00       	push   $0x400000
  801b45:	6a 00                	push   $0x0
  801b47:	e8 72 f1 ff ff       	call   800cbe <sys_page_unmap>
  801b4c:	89 c3                	mov    %eax,%ebx
  801b4e:	83 c4 10             	add    $0x10,%esp
  801b51:	85 c0                	test   %eax,%eax
  801b53:	0f 88 f2 02 00 00    	js     801e4b <spawn+0x525>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801b59:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801b5f:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801b66:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801b6c:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801b73:	00 00 00 
  801b76:	e9 88 01 00 00       	jmp    801d03 <spawn+0x3dd>
		if (ph->p_type != ELF_PROG_LOAD)
  801b7b:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801b81:	83 38 01             	cmpl   $0x1,(%eax)
  801b84:	0f 85 6b 01 00 00    	jne    801cf5 <spawn+0x3cf>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801b8a:	89 c7                	mov    %eax,%edi
  801b8c:	8b 40 18             	mov    0x18(%eax),%eax
  801b8f:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801b95:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801b98:	83 f8 01             	cmp    $0x1,%eax
  801b9b:	19 c0                	sbb    %eax,%eax
  801b9d:	83 e0 fe             	and    $0xfffffffe,%eax
  801ba0:	83 c0 07             	add    $0x7,%eax
  801ba3:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801ba9:	89 f8                	mov    %edi,%eax
  801bab:	8b 7f 04             	mov    0x4(%edi),%edi
  801bae:	89 f9                	mov    %edi,%ecx
  801bb0:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801bb6:	8b 78 10             	mov    0x10(%eax),%edi
  801bb9:	8b 50 14             	mov    0x14(%eax),%edx
  801bbc:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  801bc2:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801bc5:	89 f0                	mov    %esi,%eax
  801bc7:	25 ff 0f 00 00       	and    $0xfff,%eax
  801bcc:	74 14                	je     801be2 <spawn+0x2bc>
		va -= i;
  801bce:	29 c6                	sub    %eax,%esi
		memsz += i;
  801bd0:	01 c2                	add    %eax,%edx
  801bd2:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  801bd8:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801bda:	29 c1                	sub    %eax,%ecx
  801bdc:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801be2:	bb 00 00 00 00       	mov    $0x0,%ebx
  801be7:	e9 f7 00 00 00       	jmp    801ce3 <spawn+0x3bd>
		if (i >= filesz) {
  801bec:	39 df                	cmp    %ebx,%edi
  801bee:	77 27                	ja     801c17 <spawn+0x2f1>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801bf0:	83 ec 04             	sub    $0x4,%esp
  801bf3:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801bf9:	56                   	push   %esi
  801bfa:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801c00:	e8 34 f0 ff ff       	call   800c39 <sys_page_alloc>
  801c05:	83 c4 10             	add    $0x10,%esp
  801c08:	85 c0                	test   %eax,%eax
  801c0a:	0f 89 c7 00 00 00    	jns    801cd7 <spawn+0x3b1>
  801c10:	89 c3                	mov    %eax,%ebx
  801c12:	e9 13 02 00 00       	jmp    801e2a <spawn+0x504>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801c17:	83 ec 04             	sub    $0x4,%esp
  801c1a:	6a 07                	push   $0x7
  801c1c:	68 00 00 40 00       	push   $0x400000
  801c21:	6a 00                	push   $0x0
  801c23:	e8 11 f0 ff ff       	call   800c39 <sys_page_alloc>
  801c28:	83 c4 10             	add    $0x10,%esp
  801c2b:	85 c0                	test   %eax,%eax
  801c2d:	0f 88 ed 01 00 00    	js     801e20 <spawn+0x4fa>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801c33:	83 ec 08             	sub    $0x8,%esp
  801c36:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801c3c:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801c42:	50                   	push   %eax
  801c43:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801c49:	e8 e6 f8 ff ff       	call   801534 <seek>
  801c4e:	83 c4 10             	add    $0x10,%esp
  801c51:	85 c0                	test   %eax,%eax
  801c53:	0f 88 cb 01 00 00    	js     801e24 <spawn+0x4fe>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801c59:	83 ec 04             	sub    $0x4,%esp
  801c5c:	89 f8                	mov    %edi,%eax
  801c5e:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801c64:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801c69:	ba 00 10 00 00       	mov    $0x1000,%edx
  801c6e:	0f 47 c2             	cmova  %edx,%eax
  801c71:	50                   	push   %eax
  801c72:	68 00 00 40 00       	push   $0x400000
  801c77:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801c7d:	e8 dd f7 ff ff       	call   80145f <readn>
  801c82:	83 c4 10             	add    $0x10,%esp
  801c85:	85 c0                	test   %eax,%eax
  801c87:	0f 88 9b 01 00 00    	js     801e28 <spawn+0x502>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801c8d:	83 ec 0c             	sub    $0xc,%esp
  801c90:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801c96:	56                   	push   %esi
  801c97:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801c9d:	68 00 00 40 00       	push   $0x400000
  801ca2:	6a 00                	push   $0x0
  801ca4:	e8 d3 ef ff ff       	call   800c7c <sys_page_map>
  801ca9:	83 c4 20             	add    $0x20,%esp
  801cac:	85 c0                	test   %eax,%eax
  801cae:	79 15                	jns    801cc5 <spawn+0x39f>
				panic("spawn: sys_page_map data: %e", r);
  801cb0:	50                   	push   %eax
  801cb1:	68 2d 32 80 00       	push   $0x80322d
  801cb6:	68 25 01 00 00       	push   $0x125
  801cbb:	68 21 32 80 00       	push   $0x803221
  801cc0:	e8 13 e5 ff ff       	call   8001d8 <_panic>
			sys_page_unmap(0, UTEMP);
  801cc5:	83 ec 08             	sub    $0x8,%esp
  801cc8:	68 00 00 40 00       	push   $0x400000
  801ccd:	6a 00                	push   $0x0
  801ccf:	e8 ea ef ff ff       	call   800cbe <sys_page_unmap>
  801cd4:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801cd7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801cdd:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801ce3:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801ce9:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  801cef:	0f 87 f7 fe ff ff    	ja     801bec <spawn+0x2c6>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801cf5:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801cfc:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801d03:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801d0a:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801d10:	0f 8c 65 fe ff ff    	jl     801b7b <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801d16:	83 ec 0c             	sub    $0xc,%esp
  801d19:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801d1f:	e8 6e f5 ff ff       	call   801292 <close>
  801d24:	83 c4 10             	add    $0x10,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	uintptr_t i;
	for (i = 0; i < USTACKTOP; i += PGSIZE){
  801d27:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d2c:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[PGNUM(i)] & PTE_P) && (uvpt[PGNUM(i)] & PTE_U) && (uvpt[PGNUM(i)] & PTE_SHARE)){
  801d32:	89 d8                	mov    %ebx,%eax
  801d34:	c1 e8 16             	shr    $0x16,%eax
  801d37:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801d3e:	a8 01                	test   $0x1,%al
  801d40:	74 46                	je     801d88 <spawn+0x462>
  801d42:	89 d8                	mov    %ebx,%eax
  801d44:	c1 e8 0c             	shr    $0xc,%eax
  801d47:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801d4e:	f6 c2 01             	test   $0x1,%dl
  801d51:	74 35                	je     801d88 <spawn+0x462>
  801d53:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801d5a:	f6 c2 04             	test   $0x4,%dl
  801d5d:	74 29                	je     801d88 <spawn+0x462>
  801d5f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801d66:	f6 c6 04             	test   $0x4,%dh
  801d69:	74 1d                	je     801d88 <spawn+0x462>
			sys_page_map(0, (void*)i,child, (void*)i,(uvpt[PGNUM(i)] | PTE_SYSCALL));
  801d6b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801d72:	83 ec 0c             	sub    $0xc,%esp
  801d75:	0d 07 0e 00 00       	or     $0xe07,%eax
  801d7a:	50                   	push   %eax
  801d7b:	53                   	push   %ebx
  801d7c:	56                   	push   %esi
  801d7d:	53                   	push   %ebx
  801d7e:	6a 00                	push   $0x0
  801d80:	e8 f7 ee ff ff       	call   800c7c <sys_page_map>
  801d85:	83 c4 20             	add    $0x20,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	uintptr_t i;
	for (i = 0; i < USTACKTOP; i += PGSIZE){
  801d88:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801d8e:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801d94:	75 9c                	jne    801d32 <spawn+0x40c>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801d96:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801d9d:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801da0:	83 ec 08             	sub    $0x8,%esp
  801da3:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801da9:	50                   	push   %eax
  801daa:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801db0:	e8 8d ef ff ff       	call   800d42 <sys_env_set_trapframe>
  801db5:	83 c4 10             	add    $0x10,%esp
  801db8:	85 c0                	test   %eax,%eax
  801dba:	79 15                	jns    801dd1 <spawn+0x4ab>
		panic("sys_env_set_trapframe: %e", r);
  801dbc:	50                   	push   %eax
  801dbd:	68 4a 32 80 00       	push   $0x80324a
  801dc2:	68 86 00 00 00       	push   $0x86
  801dc7:	68 21 32 80 00       	push   $0x803221
  801dcc:	e8 07 e4 ff ff       	call   8001d8 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801dd1:	83 ec 08             	sub    $0x8,%esp
  801dd4:	6a 02                	push   $0x2
  801dd6:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801ddc:	e8 1f ef ff ff       	call   800d00 <sys_env_set_status>
  801de1:	83 c4 10             	add    $0x10,%esp
  801de4:	85 c0                	test   %eax,%eax
  801de6:	79 25                	jns    801e0d <spawn+0x4e7>
		panic("sys_env_set_status: %e", r);
  801de8:	50                   	push   %eax
  801de9:	68 09 31 80 00       	push   $0x803109
  801dee:	68 89 00 00 00       	push   $0x89
  801df3:	68 21 32 80 00       	push   $0x803221
  801df8:	e8 db e3 ff ff       	call   8001d8 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801dfd:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801e03:	eb 58                	jmp    801e5d <spawn+0x537>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801e05:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801e0b:	eb 50                	jmp    801e5d <spawn+0x537>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801e0d:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801e13:	eb 48                	jmp    801e5d <spawn+0x537>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801e15:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801e1a:	eb 41                	jmp    801e5d <spawn+0x537>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801e1c:	89 c3                	mov    %eax,%ebx
  801e1e:	eb 3d                	jmp    801e5d <spawn+0x537>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801e20:	89 c3                	mov    %eax,%ebx
  801e22:	eb 06                	jmp    801e2a <spawn+0x504>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801e24:	89 c3                	mov    %eax,%ebx
  801e26:	eb 02                	jmp    801e2a <spawn+0x504>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801e28:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801e2a:	83 ec 0c             	sub    $0xc,%esp
  801e2d:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e33:	e8 82 ed ff ff       	call   800bba <sys_env_destroy>
	close(fd);
  801e38:	83 c4 04             	add    $0x4,%esp
  801e3b:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801e41:	e8 4c f4 ff ff       	call   801292 <close>
	return r;
  801e46:	83 c4 10             	add    $0x10,%esp
  801e49:	eb 12                	jmp    801e5d <spawn+0x537>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801e4b:	83 ec 08             	sub    $0x8,%esp
  801e4e:	68 00 00 40 00       	push   $0x400000
  801e53:	6a 00                	push   $0x0
  801e55:	e8 64 ee ff ff       	call   800cbe <sys_page_unmap>
  801e5a:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801e5d:	89 d8                	mov    %ebx,%eax
  801e5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e62:	5b                   	pop    %ebx
  801e63:	5e                   	pop    %esi
  801e64:	5f                   	pop    %edi
  801e65:	5d                   	pop    %ebp
  801e66:	c3                   	ret    

00801e67 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801e67:	55                   	push   %ebp
  801e68:	89 e5                	mov    %esp,%ebp
  801e6a:	56                   	push   %esi
  801e6b:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801e6c:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801e6f:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801e74:	eb 03                	jmp    801e79 <spawnl+0x12>
		argc++;
  801e76:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801e79:	83 c2 04             	add    $0x4,%edx
  801e7c:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801e80:	75 f4                	jne    801e76 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801e82:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801e89:	83 e2 f0             	and    $0xfffffff0,%edx
  801e8c:	29 d4                	sub    %edx,%esp
  801e8e:	8d 54 24 03          	lea    0x3(%esp),%edx
  801e92:	c1 ea 02             	shr    $0x2,%edx
  801e95:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801e9c:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801e9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ea1:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801ea8:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801eaf:	00 
  801eb0:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801eb2:	b8 00 00 00 00       	mov    $0x0,%eax
  801eb7:	eb 0a                	jmp    801ec3 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801eb9:	83 c0 01             	add    $0x1,%eax
  801ebc:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801ec0:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801ec3:	39 d0                	cmp    %edx,%eax
  801ec5:	75 f2                	jne    801eb9 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801ec7:	83 ec 08             	sub    $0x8,%esp
  801eca:	56                   	push   %esi
  801ecb:	ff 75 08             	pushl  0x8(%ebp)
  801ece:	e8 53 fa ff ff       	call   801926 <spawn>
}
  801ed3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ed6:	5b                   	pop    %ebx
  801ed7:	5e                   	pop    %esi
  801ed8:	5d                   	pop    %ebp
  801ed9:	c3                   	ret    

00801eda <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801eda:	55                   	push   %ebp
  801edb:	89 e5                	mov    %esp,%ebp
  801edd:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801ee0:	68 8c 32 80 00       	push   $0x80328c
  801ee5:	ff 75 0c             	pushl  0xc(%ebp)
  801ee8:	e8 49 e9 ff ff       	call   800836 <strcpy>
	return 0;
}
  801eed:	b8 00 00 00 00       	mov    $0x0,%eax
  801ef2:	c9                   	leave  
  801ef3:	c3                   	ret    

00801ef4 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801ef4:	55                   	push   %ebp
  801ef5:	89 e5                	mov    %esp,%ebp
  801ef7:	53                   	push   %ebx
  801ef8:	83 ec 10             	sub    $0x10,%esp
  801efb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801efe:	53                   	push   %ebx
  801eff:	e8 d7 0a 00 00       	call   8029db <pageref>
  801f04:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801f07:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801f0c:	83 f8 01             	cmp    $0x1,%eax
  801f0f:	75 10                	jne    801f21 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801f11:	83 ec 0c             	sub    $0xc,%esp
  801f14:	ff 73 0c             	pushl  0xc(%ebx)
  801f17:	e8 c0 02 00 00       	call   8021dc <nsipc_close>
  801f1c:	89 c2                	mov    %eax,%edx
  801f1e:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801f21:	89 d0                	mov    %edx,%eax
  801f23:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f26:	c9                   	leave  
  801f27:	c3                   	ret    

00801f28 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801f28:	55                   	push   %ebp
  801f29:	89 e5                	mov    %esp,%ebp
  801f2b:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801f2e:	6a 00                	push   $0x0
  801f30:	ff 75 10             	pushl  0x10(%ebp)
  801f33:	ff 75 0c             	pushl  0xc(%ebp)
  801f36:	8b 45 08             	mov    0x8(%ebp),%eax
  801f39:	ff 70 0c             	pushl  0xc(%eax)
  801f3c:	e8 78 03 00 00       	call   8022b9 <nsipc_send>
}
  801f41:	c9                   	leave  
  801f42:	c3                   	ret    

00801f43 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801f43:	55                   	push   %ebp
  801f44:	89 e5                	mov    %esp,%ebp
  801f46:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801f49:	6a 00                	push   $0x0
  801f4b:	ff 75 10             	pushl  0x10(%ebp)
  801f4e:	ff 75 0c             	pushl  0xc(%ebp)
  801f51:	8b 45 08             	mov    0x8(%ebp),%eax
  801f54:	ff 70 0c             	pushl  0xc(%eax)
  801f57:	e8 f1 02 00 00       	call   80224d <nsipc_recv>
}
  801f5c:	c9                   	leave  
  801f5d:	c3                   	ret    

00801f5e <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801f5e:	55                   	push   %ebp
  801f5f:	89 e5                	mov    %esp,%ebp
  801f61:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801f64:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801f67:	52                   	push   %edx
  801f68:	50                   	push   %eax
  801f69:	e8 fa f1 ff ff       	call   801168 <fd_lookup>
  801f6e:	83 c4 10             	add    $0x10,%esp
  801f71:	85 c0                	test   %eax,%eax
  801f73:	78 17                	js     801f8c <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801f75:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f78:	8b 0d 28 40 80 00    	mov    0x804028,%ecx
  801f7e:	39 08                	cmp    %ecx,(%eax)
  801f80:	75 05                	jne    801f87 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801f82:	8b 40 0c             	mov    0xc(%eax),%eax
  801f85:	eb 05                	jmp    801f8c <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801f87:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801f8c:	c9                   	leave  
  801f8d:	c3                   	ret    

00801f8e <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801f8e:	55                   	push   %ebp
  801f8f:	89 e5                	mov    %esp,%ebp
  801f91:	56                   	push   %esi
  801f92:	53                   	push   %ebx
  801f93:	83 ec 1c             	sub    $0x1c,%esp
  801f96:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801f98:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f9b:	50                   	push   %eax
  801f9c:	e8 78 f1 ff ff       	call   801119 <fd_alloc>
  801fa1:	89 c3                	mov    %eax,%ebx
  801fa3:	83 c4 10             	add    $0x10,%esp
  801fa6:	85 c0                	test   %eax,%eax
  801fa8:	78 1b                	js     801fc5 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801faa:	83 ec 04             	sub    $0x4,%esp
  801fad:	68 07 04 00 00       	push   $0x407
  801fb2:	ff 75 f4             	pushl  -0xc(%ebp)
  801fb5:	6a 00                	push   $0x0
  801fb7:	e8 7d ec ff ff       	call   800c39 <sys_page_alloc>
  801fbc:	89 c3                	mov    %eax,%ebx
  801fbe:	83 c4 10             	add    $0x10,%esp
  801fc1:	85 c0                	test   %eax,%eax
  801fc3:	79 10                	jns    801fd5 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801fc5:	83 ec 0c             	sub    $0xc,%esp
  801fc8:	56                   	push   %esi
  801fc9:	e8 0e 02 00 00       	call   8021dc <nsipc_close>
		return r;
  801fce:	83 c4 10             	add    $0x10,%esp
  801fd1:	89 d8                	mov    %ebx,%eax
  801fd3:	eb 24                	jmp    801ff9 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801fd5:	8b 15 28 40 80 00    	mov    0x804028,%edx
  801fdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fde:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801fe0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fe3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801fea:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801fed:	83 ec 0c             	sub    $0xc,%esp
  801ff0:	50                   	push   %eax
  801ff1:	e8 fc f0 ff ff       	call   8010f2 <fd2num>
  801ff6:	83 c4 10             	add    $0x10,%esp
}
  801ff9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ffc:	5b                   	pop    %ebx
  801ffd:	5e                   	pop    %esi
  801ffe:	5d                   	pop    %ebp
  801fff:	c3                   	ret    

00802000 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802000:	55                   	push   %ebp
  802001:	89 e5                	mov    %esp,%ebp
  802003:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802006:	8b 45 08             	mov    0x8(%ebp),%eax
  802009:	e8 50 ff ff ff       	call   801f5e <fd2sockid>
		return r;
  80200e:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  802010:	85 c0                	test   %eax,%eax
  802012:	78 1f                	js     802033 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802014:	83 ec 04             	sub    $0x4,%esp
  802017:	ff 75 10             	pushl  0x10(%ebp)
  80201a:	ff 75 0c             	pushl  0xc(%ebp)
  80201d:	50                   	push   %eax
  80201e:	e8 12 01 00 00       	call   802135 <nsipc_accept>
  802023:	83 c4 10             	add    $0x10,%esp
		return r;
  802026:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802028:	85 c0                	test   %eax,%eax
  80202a:	78 07                	js     802033 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  80202c:	e8 5d ff ff ff       	call   801f8e <alloc_sockfd>
  802031:	89 c1                	mov    %eax,%ecx
}
  802033:	89 c8                	mov    %ecx,%eax
  802035:	c9                   	leave  
  802036:	c3                   	ret    

00802037 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802037:	55                   	push   %ebp
  802038:	89 e5                	mov    %esp,%ebp
  80203a:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80203d:	8b 45 08             	mov    0x8(%ebp),%eax
  802040:	e8 19 ff ff ff       	call   801f5e <fd2sockid>
  802045:	85 c0                	test   %eax,%eax
  802047:	78 12                	js     80205b <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  802049:	83 ec 04             	sub    $0x4,%esp
  80204c:	ff 75 10             	pushl  0x10(%ebp)
  80204f:	ff 75 0c             	pushl  0xc(%ebp)
  802052:	50                   	push   %eax
  802053:	e8 2d 01 00 00       	call   802185 <nsipc_bind>
  802058:	83 c4 10             	add    $0x10,%esp
}
  80205b:	c9                   	leave  
  80205c:	c3                   	ret    

0080205d <shutdown>:

int
shutdown(int s, int how)
{
  80205d:	55                   	push   %ebp
  80205e:	89 e5                	mov    %esp,%ebp
  802060:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802063:	8b 45 08             	mov    0x8(%ebp),%eax
  802066:	e8 f3 fe ff ff       	call   801f5e <fd2sockid>
  80206b:	85 c0                	test   %eax,%eax
  80206d:	78 0f                	js     80207e <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  80206f:	83 ec 08             	sub    $0x8,%esp
  802072:	ff 75 0c             	pushl  0xc(%ebp)
  802075:	50                   	push   %eax
  802076:	e8 3f 01 00 00       	call   8021ba <nsipc_shutdown>
  80207b:	83 c4 10             	add    $0x10,%esp
}
  80207e:	c9                   	leave  
  80207f:	c3                   	ret    

00802080 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802080:	55                   	push   %ebp
  802081:	89 e5                	mov    %esp,%ebp
  802083:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802086:	8b 45 08             	mov    0x8(%ebp),%eax
  802089:	e8 d0 fe ff ff       	call   801f5e <fd2sockid>
  80208e:	85 c0                	test   %eax,%eax
  802090:	78 12                	js     8020a4 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  802092:	83 ec 04             	sub    $0x4,%esp
  802095:	ff 75 10             	pushl  0x10(%ebp)
  802098:	ff 75 0c             	pushl  0xc(%ebp)
  80209b:	50                   	push   %eax
  80209c:	e8 55 01 00 00       	call   8021f6 <nsipc_connect>
  8020a1:	83 c4 10             	add    $0x10,%esp
}
  8020a4:	c9                   	leave  
  8020a5:	c3                   	ret    

008020a6 <listen>:

int
listen(int s, int backlog)
{
  8020a6:	55                   	push   %ebp
  8020a7:	89 e5                	mov    %esp,%ebp
  8020a9:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8020ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8020af:	e8 aa fe ff ff       	call   801f5e <fd2sockid>
  8020b4:	85 c0                	test   %eax,%eax
  8020b6:	78 0f                	js     8020c7 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8020b8:	83 ec 08             	sub    $0x8,%esp
  8020bb:	ff 75 0c             	pushl  0xc(%ebp)
  8020be:	50                   	push   %eax
  8020bf:	e8 67 01 00 00       	call   80222b <nsipc_listen>
  8020c4:	83 c4 10             	add    $0x10,%esp
}
  8020c7:	c9                   	leave  
  8020c8:	c3                   	ret    

008020c9 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8020c9:	55                   	push   %ebp
  8020ca:	89 e5                	mov    %esp,%ebp
  8020cc:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8020cf:	ff 75 10             	pushl  0x10(%ebp)
  8020d2:	ff 75 0c             	pushl  0xc(%ebp)
  8020d5:	ff 75 08             	pushl  0x8(%ebp)
  8020d8:	e8 3a 02 00 00       	call   802317 <nsipc_socket>
  8020dd:	83 c4 10             	add    $0x10,%esp
  8020e0:	85 c0                	test   %eax,%eax
  8020e2:	78 05                	js     8020e9 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  8020e4:	e8 a5 fe ff ff       	call   801f8e <alloc_sockfd>
}
  8020e9:	c9                   	leave  
  8020ea:	c3                   	ret    

008020eb <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8020eb:	55                   	push   %ebp
  8020ec:	89 e5                	mov    %esp,%ebp
  8020ee:	53                   	push   %ebx
  8020ef:	83 ec 04             	sub    $0x4,%esp
  8020f2:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8020f4:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  8020fb:	75 12                	jne    80210f <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8020fd:	83 ec 0c             	sub    $0xc,%esp
  802100:	6a 02                	push   $0x2
  802102:	e8 9b 08 00 00       	call   8029a2 <ipc_find_env>
  802107:	a3 04 50 80 00       	mov    %eax,0x805004
  80210c:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  80210f:	6a 07                	push   $0x7
  802111:	68 00 70 80 00       	push   $0x807000
  802116:	53                   	push   %ebx
  802117:	ff 35 04 50 80 00    	pushl  0x805004
  80211d:	e8 2c 08 00 00       	call   80294e <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802122:	83 c4 0c             	add    $0xc,%esp
  802125:	6a 00                	push   $0x0
  802127:	6a 00                	push   $0x0
  802129:	6a 00                	push   $0x0
  80212b:	e8 b5 07 00 00       	call   8028e5 <ipc_recv>
}
  802130:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802133:	c9                   	leave  
  802134:	c3                   	ret    

00802135 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802135:	55                   	push   %ebp
  802136:	89 e5                	mov    %esp,%ebp
  802138:	56                   	push   %esi
  802139:	53                   	push   %ebx
  80213a:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  80213d:	8b 45 08             	mov    0x8(%ebp),%eax
  802140:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  802145:	8b 06                	mov    (%esi),%eax
  802147:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  80214c:	b8 01 00 00 00       	mov    $0x1,%eax
  802151:	e8 95 ff ff ff       	call   8020eb <nsipc>
  802156:	89 c3                	mov    %eax,%ebx
  802158:	85 c0                	test   %eax,%eax
  80215a:	78 20                	js     80217c <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  80215c:	83 ec 04             	sub    $0x4,%esp
  80215f:	ff 35 10 70 80 00    	pushl  0x807010
  802165:	68 00 70 80 00       	push   $0x807000
  80216a:	ff 75 0c             	pushl  0xc(%ebp)
  80216d:	e8 56 e8 ff ff       	call   8009c8 <memmove>
		*addrlen = ret->ret_addrlen;
  802172:	a1 10 70 80 00       	mov    0x807010,%eax
  802177:	89 06                	mov    %eax,(%esi)
  802179:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  80217c:	89 d8                	mov    %ebx,%eax
  80217e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802181:	5b                   	pop    %ebx
  802182:	5e                   	pop    %esi
  802183:	5d                   	pop    %ebp
  802184:	c3                   	ret    

00802185 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802185:	55                   	push   %ebp
  802186:	89 e5                	mov    %esp,%ebp
  802188:	53                   	push   %ebx
  802189:	83 ec 08             	sub    $0x8,%esp
  80218c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80218f:	8b 45 08             	mov    0x8(%ebp),%eax
  802192:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802197:	53                   	push   %ebx
  802198:	ff 75 0c             	pushl  0xc(%ebp)
  80219b:	68 04 70 80 00       	push   $0x807004
  8021a0:	e8 23 e8 ff ff       	call   8009c8 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8021a5:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  8021ab:	b8 02 00 00 00       	mov    $0x2,%eax
  8021b0:	e8 36 ff ff ff       	call   8020eb <nsipc>
}
  8021b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8021b8:	c9                   	leave  
  8021b9:	c3                   	ret    

008021ba <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8021ba:	55                   	push   %ebp
  8021bb:	89 e5                	mov    %esp,%ebp
  8021bd:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8021c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8021c3:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  8021c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021cb:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  8021d0:	b8 03 00 00 00       	mov    $0x3,%eax
  8021d5:	e8 11 ff ff ff       	call   8020eb <nsipc>
}
  8021da:	c9                   	leave  
  8021db:	c3                   	ret    

008021dc <nsipc_close>:

int
nsipc_close(int s)
{
  8021dc:	55                   	push   %ebp
  8021dd:	89 e5                	mov    %esp,%ebp
  8021df:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8021e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8021e5:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  8021ea:	b8 04 00 00 00       	mov    $0x4,%eax
  8021ef:	e8 f7 fe ff ff       	call   8020eb <nsipc>
}
  8021f4:	c9                   	leave  
  8021f5:	c3                   	ret    

008021f6 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8021f6:	55                   	push   %ebp
  8021f7:	89 e5                	mov    %esp,%ebp
  8021f9:	53                   	push   %ebx
  8021fa:	83 ec 08             	sub    $0x8,%esp
  8021fd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  802200:	8b 45 08             	mov    0x8(%ebp),%eax
  802203:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802208:	53                   	push   %ebx
  802209:	ff 75 0c             	pushl  0xc(%ebp)
  80220c:	68 04 70 80 00       	push   $0x807004
  802211:	e8 b2 e7 ff ff       	call   8009c8 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  802216:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  80221c:	b8 05 00 00 00       	mov    $0x5,%eax
  802221:	e8 c5 fe ff ff       	call   8020eb <nsipc>
}
  802226:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802229:	c9                   	leave  
  80222a:	c3                   	ret    

0080222b <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  80222b:	55                   	push   %ebp
  80222c:	89 e5                	mov    %esp,%ebp
  80222e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802231:	8b 45 08             	mov    0x8(%ebp),%eax
  802234:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  802239:	8b 45 0c             	mov    0xc(%ebp),%eax
  80223c:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  802241:	b8 06 00 00 00       	mov    $0x6,%eax
  802246:	e8 a0 fe ff ff       	call   8020eb <nsipc>
}
  80224b:	c9                   	leave  
  80224c:	c3                   	ret    

0080224d <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  80224d:	55                   	push   %ebp
  80224e:	89 e5                	mov    %esp,%ebp
  802250:	56                   	push   %esi
  802251:	53                   	push   %ebx
  802252:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  802255:	8b 45 08             	mov    0x8(%ebp),%eax
  802258:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  80225d:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  802263:	8b 45 14             	mov    0x14(%ebp),%eax
  802266:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  80226b:	b8 07 00 00 00       	mov    $0x7,%eax
  802270:	e8 76 fe ff ff       	call   8020eb <nsipc>
  802275:	89 c3                	mov    %eax,%ebx
  802277:	85 c0                	test   %eax,%eax
  802279:	78 35                	js     8022b0 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  80227b:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802280:	7f 04                	jg     802286 <nsipc_recv+0x39>
  802282:	39 c6                	cmp    %eax,%esi
  802284:	7d 16                	jge    80229c <nsipc_recv+0x4f>
  802286:	68 98 32 80 00       	push   $0x803298
  80228b:	68 d4 31 80 00       	push   $0x8031d4
  802290:	6a 62                	push   $0x62
  802292:	68 ad 32 80 00       	push   $0x8032ad
  802297:	e8 3c df ff ff       	call   8001d8 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  80229c:	83 ec 04             	sub    $0x4,%esp
  80229f:	50                   	push   %eax
  8022a0:	68 00 70 80 00       	push   $0x807000
  8022a5:	ff 75 0c             	pushl  0xc(%ebp)
  8022a8:	e8 1b e7 ff ff       	call   8009c8 <memmove>
  8022ad:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  8022b0:	89 d8                	mov    %ebx,%eax
  8022b2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022b5:	5b                   	pop    %ebx
  8022b6:	5e                   	pop    %esi
  8022b7:	5d                   	pop    %ebp
  8022b8:	c3                   	ret    

008022b9 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8022b9:	55                   	push   %ebp
  8022ba:	89 e5                	mov    %esp,%ebp
  8022bc:	53                   	push   %ebx
  8022bd:	83 ec 04             	sub    $0x4,%esp
  8022c0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8022c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8022c6:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  8022cb:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8022d1:	7e 16                	jle    8022e9 <nsipc_send+0x30>
  8022d3:	68 b9 32 80 00       	push   $0x8032b9
  8022d8:	68 d4 31 80 00       	push   $0x8031d4
  8022dd:	6a 6d                	push   $0x6d
  8022df:	68 ad 32 80 00       	push   $0x8032ad
  8022e4:	e8 ef de ff ff       	call   8001d8 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8022e9:	83 ec 04             	sub    $0x4,%esp
  8022ec:	53                   	push   %ebx
  8022ed:	ff 75 0c             	pushl  0xc(%ebp)
  8022f0:	68 0c 70 80 00       	push   $0x80700c
  8022f5:	e8 ce e6 ff ff       	call   8009c8 <memmove>
	nsipcbuf.send.req_size = size;
  8022fa:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  802300:	8b 45 14             	mov    0x14(%ebp),%eax
  802303:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  802308:	b8 08 00 00 00       	mov    $0x8,%eax
  80230d:	e8 d9 fd ff ff       	call   8020eb <nsipc>
}
  802312:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802315:	c9                   	leave  
  802316:	c3                   	ret    

00802317 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  802317:	55                   	push   %ebp
  802318:	89 e5                	mov    %esp,%ebp
  80231a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80231d:	8b 45 08             	mov    0x8(%ebp),%eax
  802320:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  802325:	8b 45 0c             	mov    0xc(%ebp),%eax
  802328:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  80232d:	8b 45 10             	mov    0x10(%ebp),%eax
  802330:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  802335:	b8 09 00 00 00       	mov    $0x9,%eax
  80233a:	e8 ac fd ff ff       	call   8020eb <nsipc>
}
  80233f:	c9                   	leave  
  802340:	c3                   	ret    

00802341 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802341:	55                   	push   %ebp
  802342:	89 e5                	mov    %esp,%ebp
  802344:	56                   	push   %esi
  802345:	53                   	push   %ebx
  802346:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802349:	83 ec 0c             	sub    $0xc,%esp
  80234c:	ff 75 08             	pushl  0x8(%ebp)
  80234f:	e8 ae ed ff ff       	call   801102 <fd2data>
  802354:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802356:	83 c4 08             	add    $0x8,%esp
  802359:	68 c5 32 80 00       	push   $0x8032c5
  80235e:	53                   	push   %ebx
  80235f:	e8 d2 e4 ff ff       	call   800836 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802364:	8b 46 04             	mov    0x4(%esi),%eax
  802367:	2b 06                	sub    (%esi),%eax
  802369:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80236f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802376:	00 00 00 
	stat->st_dev = &devpipe;
  802379:	c7 83 88 00 00 00 44 	movl   $0x804044,0x88(%ebx)
  802380:	40 80 00 
	return 0;
}
  802383:	b8 00 00 00 00       	mov    $0x0,%eax
  802388:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80238b:	5b                   	pop    %ebx
  80238c:	5e                   	pop    %esi
  80238d:	5d                   	pop    %ebp
  80238e:	c3                   	ret    

0080238f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80238f:	55                   	push   %ebp
  802390:	89 e5                	mov    %esp,%ebp
  802392:	53                   	push   %ebx
  802393:	83 ec 0c             	sub    $0xc,%esp
  802396:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802399:	53                   	push   %ebx
  80239a:	6a 00                	push   $0x0
  80239c:	e8 1d e9 ff ff       	call   800cbe <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8023a1:	89 1c 24             	mov    %ebx,(%esp)
  8023a4:	e8 59 ed ff ff       	call   801102 <fd2data>
  8023a9:	83 c4 08             	add    $0x8,%esp
  8023ac:	50                   	push   %eax
  8023ad:	6a 00                	push   $0x0
  8023af:	e8 0a e9 ff ff       	call   800cbe <sys_page_unmap>
}
  8023b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8023b7:	c9                   	leave  
  8023b8:	c3                   	ret    

008023b9 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8023b9:	55                   	push   %ebp
  8023ba:	89 e5                	mov    %esp,%ebp
  8023bc:	57                   	push   %edi
  8023bd:	56                   	push   %esi
  8023be:	53                   	push   %ebx
  8023bf:	83 ec 1c             	sub    $0x1c,%esp
  8023c2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8023c5:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8023c7:	a1 08 50 80 00       	mov    0x805008,%eax
  8023cc:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8023cf:	83 ec 0c             	sub    $0xc,%esp
  8023d2:	ff 75 e0             	pushl  -0x20(%ebp)
  8023d5:	e8 01 06 00 00       	call   8029db <pageref>
  8023da:	89 c3                	mov    %eax,%ebx
  8023dc:	89 3c 24             	mov    %edi,(%esp)
  8023df:	e8 f7 05 00 00       	call   8029db <pageref>
  8023e4:	83 c4 10             	add    $0x10,%esp
  8023e7:	39 c3                	cmp    %eax,%ebx
  8023e9:	0f 94 c1             	sete   %cl
  8023ec:	0f b6 c9             	movzbl %cl,%ecx
  8023ef:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8023f2:	8b 15 08 50 80 00    	mov    0x805008,%edx
  8023f8:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8023fb:	39 ce                	cmp    %ecx,%esi
  8023fd:	74 1b                	je     80241a <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8023ff:	39 c3                	cmp    %eax,%ebx
  802401:	75 c4                	jne    8023c7 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802403:	8b 42 58             	mov    0x58(%edx),%eax
  802406:	ff 75 e4             	pushl  -0x1c(%ebp)
  802409:	50                   	push   %eax
  80240a:	56                   	push   %esi
  80240b:	68 cc 32 80 00       	push   $0x8032cc
  802410:	e8 9c de ff ff       	call   8002b1 <cprintf>
  802415:	83 c4 10             	add    $0x10,%esp
  802418:	eb ad                	jmp    8023c7 <_pipeisclosed+0xe>
	}
}
  80241a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80241d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802420:	5b                   	pop    %ebx
  802421:	5e                   	pop    %esi
  802422:	5f                   	pop    %edi
  802423:	5d                   	pop    %ebp
  802424:	c3                   	ret    

00802425 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802425:	55                   	push   %ebp
  802426:	89 e5                	mov    %esp,%ebp
  802428:	57                   	push   %edi
  802429:	56                   	push   %esi
  80242a:	53                   	push   %ebx
  80242b:	83 ec 28             	sub    $0x28,%esp
  80242e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802431:	56                   	push   %esi
  802432:	e8 cb ec ff ff       	call   801102 <fd2data>
  802437:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802439:	83 c4 10             	add    $0x10,%esp
  80243c:	bf 00 00 00 00       	mov    $0x0,%edi
  802441:	eb 4b                	jmp    80248e <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802443:	89 da                	mov    %ebx,%edx
  802445:	89 f0                	mov    %esi,%eax
  802447:	e8 6d ff ff ff       	call   8023b9 <_pipeisclosed>
  80244c:	85 c0                	test   %eax,%eax
  80244e:	75 48                	jne    802498 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802450:	e8 c5 e7 ff ff       	call   800c1a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802455:	8b 43 04             	mov    0x4(%ebx),%eax
  802458:	8b 0b                	mov    (%ebx),%ecx
  80245a:	8d 51 20             	lea    0x20(%ecx),%edx
  80245d:	39 d0                	cmp    %edx,%eax
  80245f:	73 e2                	jae    802443 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802461:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802464:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802468:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80246b:	89 c2                	mov    %eax,%edx
  80246d:	c1 fa 1f             	sar    $0x1f,%edx
  802470:	89 d1                	mov    %edx,%ecx
  802472:	c1 e9 1b             	shr    $0x1b,%ecx
  802475:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802478:	83 e2 1f             	and    $0x1f,%edx
  80247b:	29 ca                	sub    %ecx,%edx
  80247d:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802481:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802485:	83 c0 01             	add    $0x1,%eax
  802488:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80248b:	83 c7 01             	add    $0x1,%edi
  80248e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802491:	75 c2                	jne    802455 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802493:	8b 45 10             	mov    0x10(%ebp),%eax
  802496:	eb 05                	jmp    80249d <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802498:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80249d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024a0:	5b                   	pop    %ebx
  8024a1:	5e                   	pop    %esi
  8024a2:	5f                   	pop    %edi
  8024a3:	5d                   	pop    %ebp
  8024a4:	c3                   	ret    

008024a5 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8024a5:	55                   	push   %ebp
  8024a6:	89 e5                	mov    %esp,%ebp
  8024a8:	57                   	push   %edi
  8024a9:	56                   	push   %esi
  8024aa:	53                   	push   %ebx
  8024ab:	83 ec 18             	sub    $0x18,%esp
  8024ae:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8024b1:	57                   	push   %edi
  8024b2:	e8 4b ec ff ff       	call   801102 <fd2data>
  8024b7:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8024b9:	83 c4 10             	add    $0x10,%esp
  8024bc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8024c1:	eb 3d                	jmp    802500 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8024c3:	85 db                	test   %ebx,%ebx
  8024c5:	74 04                	je     8024cb <devpipe_read+0x26>
				return i;
  8024c7:	89 d8                	mov    %ebx,%eax
  8024c9:	eb 44                	jmp    80250f <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8024cb:	89 f2                	mov    %esi,%edx
  8024cd:	89 f8                	mov    %edi,%eax
  8024cf:	e8 e5 fe ff ff       	call   8023b9 <_pipeisclosed>
  8024d4:	85 c0                	test   %eax,%eax
  8024d6:	75 32                	jne    80250a <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8024d8:	e8 3d e7 ff ff       	call   800c1a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8024dd:	8b 06                	mov    (%esi),%eax
  8024df:	3b 46 04             	cmp    0x4(%esi),%eax
  8024e2:	74 df                	je     8024c3 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8024e4:	99                   	cltd   
  8024e5:	c1 ea 1b             	shr    $0x1b,%edx
  8024e8:	01 d0                	add    %edx,%eax
  8024ea:	83 e0 1f             	and    $0x1f,%eax
  8024ed:	29 d0                	sub    %edx,%eax
  8024ef:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8024f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8024f7:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8024fa:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8024fd:	83 c3 01             	add    $0x1,%ebx
  802500:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802503:	75 d8                	jne    8024dd <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802505:	8b 45 10             	mov    0x10(%ebp),%eax
  802508:	eb 05                	jmp    80250f <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80250a:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80250f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802512:	5b                   	pop    %ebx
  802513:	5e                   	pop    %esi
  802514:	5f                   	pop    %edi
  802515:	5d                   	pop    %ebp
  802516:	c3                   	ret    

00802517 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802517:	55                   	push   %ebp
  802518:	89 e5                	mov    %esp,%ebp
  80251a:	56                   	push   %esi
  80251b:	53                   	push   %ebx
  80251c:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80251f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802522:	50                   	push   %eax
  802523:	e8 f1 eb ff ff       	call   801119 <fd_alloc>
  802528:	83 c4 10             	add    $0x10,%esp
  80252b:	89 c2                	mov    %eax,%edx
  80252d:	85 c0                	test   %eax,%eax
  80252f:	0f 88 2c 01 00 00    	js     802661 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802535:	83 ec 04             	sub    $0x4,%esp
  802538:	68 07 04 00 00       	push   $0x407
  80253d:	ff 75 f4             	pushl  -0xc(%ebp)
  802540:	6a 00                	push   $0x0
  802542:	e8 f2 e6 ff ff       	call   800c39 <sys_page_alloc>
  802547:	83 c4 10             	add    $0x10,%esp
  80254a:	89 c2                	mov    %eax,%edx
  80254c:	85 c0                	test   %eax,%eax
  80254e:	0f 88 0d 01 00 00    	js     802661 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802554:	83 ec 0c             	sub    $0xc,%esp
  802557:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80255a:	50                   	push   %eax
  80255b:	e8 b9 eb ff ff       	call   801119 <fd_alloc>
  802560:	89 c3                	mov    %eax,%ebx
  802562:	83 c4 10             	add    $0x10,%esp
  802565:	85 c0                	test   %eax,%eax
  802567:	0f 88 e2 00 00 00    	js     80264f <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80256d:	83 ec 04             	sub    $0x4,%esp
  802570:	68 07 04 00 00       	push   $0x407
  802575:	ff 75 f0             	pushl  -0x10(%ebp)
  802578:	6a 00                	push   $0x0
  80257a:	e8 ba e6 ff ff       	call   800c39 <sys_page_alloc>
  80257f:	89 c3                	mov    %eax,%ebx
  802581:	83 c4 10             	add    $0x10,%esp
  802584:	85 c0                	test   %eax,%eax
  802586:	0f 88 c3 00 00 00    	js     80264f <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80258c:	83 ec 0c             	sub    $0xc,%esp
  80258f:	ff 75 f4             	pushl  -0xc(%ebp)
  802592:	e8 6b eb ff ff       	call   801102 <fd2data>
  802597:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802599:	83 c4 0c             	add    $0xc,%esp
  80259c:	68 07 04 00 00       	push   $0x407
  8025a1:	50                   	push   %eax
  8025a2:	6a 00                	push   $0x0
  8025a4:	e8 90 e6 ff ff       	call   800c39 <sys_page_alloc>
  8025a9:	89 c3                	mov    %eax,%ebx
  8025ab:	83 c4 10             	add    $0x10,%esp
  8025ae:	85 c0                	test   %eax,%eax
  8025b0:	0f 88 89 00 00 00    	js     80263f <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8025b6:	83 ec 0c             	sub    $0xc,%esp
  8025b9:	ff 75 f0             	pushl  -0x10(%ebp)
  8025bc:	e8 41 eb ff ff       	call   801102 <fd2data>
  8025c1:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8025c8:	50                   	push   %eax
  8025c9:	6a 00                	push   $0x0
  8025cb:	56                   	push   %esi
  8025cc:	6a 00                	push   $0x0
  8025ce:	e8 a9 e6 ff ff       	call   800c7c <sys_page_map>
  8025d3:	89 c3                	mov    %eax,%ebx
  8025d5:	83 c4 20             	add    $0x20,%esp
  8025d8:	85 c0                	test   %eax,%eax
  8025da:	78 55                	js     802631 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8025dc:	8b 15 44 40 80 00    	mov    0x804044,%edx
  8025e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025e5:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8025e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025ea:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8025f1:	8b 15 44 40 80 00    	mov    0x804044,%edx
  8025f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8025fa:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8025fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8025ff:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802606:	83 ec 0c             	sub    $0xc,%esp
  802609:	ff 75 f4             	pushl  -0xc(%ebp)
  80260c:	e8 e1 ea ff ff       	call   8010f2 <fd2num>
  802611:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802614:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802616:	83 c4 04             	add    $0x4,%esp
  802619:	ff 75 f0             	pushl  -0x10(%ebp)
  80261c:	e8 d1 ea ff ff       	call   8010f2 <fd2num>
  802621:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802624:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802627:	83 c4 10             	add    $0x10,%esp
  80262a:	ba 00 00 00 00       	mov    $0x0,%edx
  80262f:	eb 30                	jmp    802661 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802631:	83 ec 08             	sub    $0x8,%esp
  802634:	56                   	push   %esi
  802635:	6a 00                	push   $0x0
  802637:	e8 82 e6 ff ff       	call   800cbe <sys_page_unmap>
  80263c:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80263f:	83 ec 08             	sub    $0x8,%esp
  802642:	ff 75 f0             	pushl  -0x10(%ebp)
  802645:	6a 00                	push   $0x0
  802647:	e8 72 e6 ff ff       	call   800cbe <sys_page_unmap>
  80264c:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80264f:	83 ec 08             	sub    $0x8,%esp
  802652:	ff 75 f4             	pushl  -0xc(%ebp)
  802655:	6a 00                	push   $0x0
  802657:	e8 62 e6 ff ff       	call   800cbe <sys_page_unmap>
  80265c:	83 c4 10             	add    $0x10,%esp
  80265f:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802661:	89 d0                	mov    %edx,%eax
  802663:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802666:	5b                   	pop    %ebx
  802667:	5e                   	pop    %esi
  802668:	5d                   	pop    %ebp
  802669:	c3                   	ret    

0080266a <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80266a:	55                   	push   %ebp
  80266b:	89 e5                	mov    %esp,%ebp
  80266d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802670:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802673:	50                   	push   %eax
  802674:	ff 75 08             	pushl  0x8(%ebp)
  802677:	e8 ec ea ff ff       	call   801168 <fd_lookup>
  80267c:	83 c4 10             	add    $0x10,%esp
  80267f:	85 c0                	test   %eax,%eax
  802681:	78 18                	js     80269b <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802683:	83 ec 0c             	sub    $0xc,%esp
  802686:	ff 75 f4             	pushl  -0xc(%ebp)
  802689:	e8 74 ea ff ff       	call   801102 <fd2data>
	return _pipeisclosed(fd, p);
  80268e:	89 c2                	mov    %eax,%edx
  802690:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802693:	e8 21 fd ff ff       	call   8023b9 <_pipeisclosed>
  802698:	83 c4 10             	add    $0x10,%esp
}
  80269b:	c9                   	leave  
  80269c:	c3                   	ret    

0080269d <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  80269d:	55                   	push   %ebp
  80269e:	89 e5                	mov    %esp,%ebp
  8026a0:	56                   	push   %esi
  8026a1:	53                   	push   %ebx
  8026a2:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  8026a5:	85 f6                	test   %esi,%esi
  8026a7:	75 16                	jne    8026bf <wait+0x22>
  8026a9:	68 e4 32 80 00       	push   $0x8032e4
  8026ae:	68 d4 31 80 00       	push   $0x8031d4
  8026b3:	6a 09                	push   $0x9
  8026b5:	68 ef 32 80 00       	push   $0x8032ef
  8026ba:	e8 19 db ff ff       	call   8001d8 <_panic>
	e = &envs[ENVX(envid)];
  8026bf:	89 f3                	mov    %esi,%ebx
  8026c1:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8026c7:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  8026ca:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  8026d0:	eb 05                	jmp    8026d7 <wait+0x3a>
		sys_yield();
  8026d2:	e8 43 e5 ff ff       	call   800c1a <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8026d7:	8b 43 48             	mov    0x48(%ebx),%eax
  8026da:	39 c6                	cmp    %eax,%esi
  8026dc:	75 07                	jne    8026e5 <wait+0x48>
  8026de:	8b 43 54             	mov    0x54(%ebx),%eax
  8026e1:	85 c0                	test   %eax,%eax
  8026e3:	75 ed                	jne    8026d2 <wait+0x35>
		sys_yield();
}
  8026e5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8026e8:	5b                   	pop    %ebx
  8026e9:	5e                   	pop    %esi
  8026ea:	5d                   	pop    %ebp
  8026eb:	c3                   	ret    

008026ec <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8026ec:	55                   	push   %ebp
  8026ed:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8026ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8026f4:	5d                   	pop    %ebp
  8026f5:	c3                   	ret    

008026f6 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8026f6:	55                   	push   %ebp
  8026f7:	89 e5                	mov    %esp,%ebp
  8026f9:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8026fc:	68 fa 32 80 00       	push   $0x8032fa
  802701:	ff 75 0c             	pushl  0xc(%ebp)
  802704:	e8 2d e1 ff ff       	call   800836 <strcpy>
	return 0;
}
  802709:	b8 00 00 00 00       	mov    $0x0,%eax
  80270e:	c9                   	leave  
  80270f:	c3                   	ret    

00802710 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802710:	55                   	push   %ebp
  802711:	89 e5                	mov    %esp,%ebp
  802713:	57                   	push   %edi
  802714:	56                   	push   %esi
  802715:	53                   	push   %ebx
  802716:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80271c:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802721:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802727:	eb 2d                	jmp    802756 <devcons_write+0x46>
		m = n - tot;
  802729:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80272c:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80272e:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802731:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802736:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802739:	83 ec 04             	sub    $0x4,%esp
  80273c:	53                   	push   %ebx
  80273d:	03 45 0c             	add    0xc(%ebp),%eax
  802740:	50                   	push   %eax
  802741:	57                   	push   %edi
  802742:	e8 81 e2 ff ff       	call   8009c8 <memmove>
		sys_cputs(buf, m);
  802747:	83 c4 08             	add    $0x8,%esp
  80274a:	53                   	push   %ebx
  80274b:	57                   	push   %edi
  80274c:	e8 2c e4 ff ff       	call   800b7d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802751:	01 de                	add    %ebx,%esi
  802753:	83 c4 10             	add    $0x10,%esp
  802756:	89 f0                	mov    %esi,%eax
  802758:	3b 75 10             	cmp    0x10(%ebp),%esi
  80275b:	72 cc                	jb     802729 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80275d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802760:	5b                   	pop    %ebx
  802761:	5e                   	pop    %esi
  802762:	5f                   	pop    %edi
  802763:	5d                   	pop    %ebp
  802764:	c3                   	ret    

00802765 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802765:	55                   	push   %ebp
  802766:	89 e5                	mov    %esp,%ebp
  802768:	83 ec 08             	sub    $0x8,%esp
  80276b:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802770:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802774:	74 2a                	je     8027a0 <devcons_read+0x3b>
  802776:	eb 05                	jmp    80277d <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802778:	e8 9d e4 ff ff       	call   800c1a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80277d:	e8 19 e4 ff ff       	call   800b9b <sys_cgetc>
  802782:	85 c0                	test   %eax,%eax
  802784:	74 f2                	je     802778 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802786:	85 c0                	test   %eax,%eax
  802788:	78 16                	js     8027a0 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80278a:	83 f8 04             	cmp    $0x4,%eax
  80278d:	74 0c                	je     80279b <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80278f:	8b 55 0c             	mov    0xc(%ebp),%edx
  802792:	88 02                	mov    %al,(%edx)
	return 1;
  802794:	b8 01 00 00 00       	mov    $0x1,%eax
  802799:	eb 05                	jmp    8027a0 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80279b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8027a0:	c9                   	leave  
  8027a1:	c3                   	ret    

008027a2 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8027a2:	55                   	push   %ebp
  8027a3:	89 e5                	mov    %esp,%ebp
  8027a5:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8027a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8027ab:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8027ae:	6a 01                	push   $0x1
  8027b0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8027b3:	50                   	push   %eax
  8027b4:	e8 c4 e3 ff ff       	call   800b7d <sys_cputs>
}
  8027b9:	83 c4 10             	add    $0x10,%esp
  8027bc:	c9                   	leave  
  8027bd:	c3                   	ret    

008027be <getchar>:

int
getchar(void)
{
  8027be:	55                   	push   %ebp
  8027bf:	89 e5                	mov    %esp,%ebp
  8027c1:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8027c4:	6a 01                	push   $0x1
  8027c6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8027c9:	50                   	push   %eax
  8027ca:	6a 00                	push   $0x0
  8027cc:	e8 fd eb ff ff       	call   8013ce <read>
	if (r < 0)
  8027d1:	83 c4 10             	add    $0x10,%esp
  8027d4:	85 c0                	test   %eax,%eax
  8027d6:	78 0f                	js     8027e7 <getchar+0x29>
		return r;
	if (r < 1)
  8027d8:	85 c0                	test   %eax,%eax
  8027da:	7e 06                	jle    8027e2 <getchar+0x24>
		return -E_EOF;
	return c;
  8027dc:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8027e0:	eb 05                	jmp    8027e7 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8027e2:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8027e7:	c9                   	leave  
  8027e8:	c3                   	ret    

008027e9 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8027e9:	55                   	push   %ebp
  8027ea:	89 e5                	mov    %esp,%ebp
  8027ec:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8027ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8027f2:	50                   	push   %eax
  8027f3:	ff 75 08             	pushl  0x8(%ebp)
  8027f6:	e8 6d e9 ff ff       	call   801168 <fd_lookup>
  8027fb:	83 c4 10             	add    $0x10,%esp
  8027fe:	85 c0                	test   %eax,%eax
  802800:	78 11                	js     802813 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802802:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802805:	8b 15 60 40 80 00    	mov    0x804060,%edx
  80280b:	39 10                	cmp    %edx,(%eax)
  80280d:	0f 94 c0             	sete   %al
  802810:	0f b6 c0             	movzbl %al,%eax
}
  802813:	c9                   	leave  
  802814:	c3                   	ret    

00802815 <opencons>:

int
opencons(void)
{
  802815:	55                   	push   %ebp
  802816:	89 e5                	mov    %esp,%ebp
  802818:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80281b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80281e:	50                   	push   %eax
  80281f:	e8 f5 e8 ff ff       	call   801119 <fd_alloc>
  802824:	83 c4 10             	add    $0x10,%esp
		return r;
  802827:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802829:	85 c0                	test   %eax,%eax
  80282b:	78 3e                	js     80286b <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80282d:	83 ec 04             	sub    $0x4,%esp
  802830:	68 07 04 00 00       	push   $0x407
  802835:	ff 75 f4             	pushl  -0xc(%ebp)
  802838:	6a 00                	push   $0x0
  80283a:	e8 fa e3 ff ff       	call   800c39 <sys_page_alloc>
  80283f:	83 c4 10             	add    $0x10,%esp
		return r;
  802842:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802844:	85 c0                	test   %eax,%eax
  802846:	78 23                	js     80286b <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802848:	8b 15 60 40 80 00    	mov    0x804060,%edx
  80284e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802851:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802853:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802856:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80285d:	83 ec 0c             	sub    $0xc,%esp
  802860:	50                   	push   %eax
  802861:	e8 8c e8 ff ff       	call   8010f2 <fd2num>
  802866:	89 c2                	mov    %eax,%edx
  802868:	83 c4 10             	add    $0x10,%esp
}
  80286b:	89 d0                	mov    %edx,%eax
  80286d:	c9                   	leave  
  80286e:	c3                   	ret    

0080286f <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80286f:	55                   	push   %ebp
  802870:	89 e5                	mov    %esp,%ebp
  802872:	53                   	push   %ebx
  802873:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  802876:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  80287d:	75 28                	jne    8028a7 <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  80287f:	e8 77 e3 ff ff       	call   800bfb <sys_getenvid>
  802884:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_U | PTE_W);
  802886:	83 ec 04             	sub    $0x4,%esp
  802889:	6a 06                	push   $0x6
  80288b:	68 00 f0 bf ee       	push   $0xeebff000
  802890:	50                   	push   %eax
  802891:	e8 a3 e3 ff ff       	call   800c39 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  802896:	83 c4 08             	add    $0x8,%esp
  802899:	68 b4 28 80 00       	push   $0x8028b4
  80289e:	53                   	push   %ebx
  80289f:	e8 e0 e4 ff ff       	call   800d84 <sys_env_set_pgfault_upcall>
  8028a4:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8028a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8028aa:	a3 00 80 80 00       	mov    %eax,0x808000
}
  8028af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8028b2:	c9                   	leave  
  8028b3:	c3                   	ret    

008028b4 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8028b4:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8028b5:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  8028ba:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8028bc:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	# My method is different. Copy the values to the other stack
	# in a convinient way, and then pop everything.
	movl %esp, %ebp		# ebp refers to the exception stack
  8028bf:	89 e5                	mov    %esp,%ebp
	movl 48(%ebp), %esp 	# go to other stack
  8028c1:	8b 65 30             	mov    0x30(%ebp),%esp

	pushl 40(%ebp)		# eip - ORDER SWITCHED WITH EFLAGS
  8028c4:	ff 75 28             	pushl  0x28(%ebp)
	pushl 44(%ebp)      	# eflags
  8028c7:	ff 75 2c             	pushl  0x2c(%ebp)
	pushl 36(%ebp)		# all the 8 remaining regs
  8028ca:	ff 75 24             	pushl  0x24(%ebp)
	pushl 32(%ebp)
  8028cd:	ff 75 20             	pushl  0x20(%ebp)
	pushl 28(%ebp)
  8028d0:	ff 75 1c             	pushl  0x1c(%ebp)
	pushl 24(%ebp)
  8028d3:	ff 75 18             	pushl  0x18(%ebp)
	pushl 20(%ebp)
  8028d6:	ff 75 14             	pushl  0x14(%ebp)
	pushl 16(%ebp)
  8028d9:	ff 75 10             	pushl  0x10(%ebp)
	pushl 12(%ebp)
  8028dc:	ff 75 0c             	pushl  0xc(%ebp)
	pushl 8(%ebp)
  8028df:	ff 75 08             	pushl  0x8(%ebp)

	popal			# now just pop everything!
  8028e2:	61                   	popa   
	popfl
  8028e3:	9d                   	popf   
	ret
  8028e4:	c3                   	ret    

008028e5 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8028e5:	55                   	push   %ebp
  8028e6:	89 e5                	mov    %esp,%ebp
  8028e8:	56                   	push   %esi
  8028e9:	53                   	push   %ebx
  8028ea:	8b 75 08             	mov    0x8(%ebp),%esi
  8028ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  8028f0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  8028f3:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  8028f5:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  8028fa:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  8028fd:	83 ec 0c             	sub    $0xc,%esp
  802900:	50                   	push   %eax
  802901:	e8 e3 e4 ff ff       	call   800de9 <sys_ipc_recv>

	if (r < 0) {
  802906:	83 c4 10             	add    $0x10,%esp
  802909:	85 c0                	test   %eax,%eax
  80290b:	79 16                	jns    802923 <ipc_recv+0x3e>
		if (from_env_store)
  80290d:	85 f6                	test   %esi,%esi
  80290f:	74 06                	je     802917 <ipc_recv+0x32>
			*from_env_store = 0;
  802911:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  802917:	85 db                	test   %ebx,%ebx
  802919:	74 2c                	je     802947 <ipc_recv+0x62>
			*perm_store = 0;
  80291b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802921:	eb 24                	jmp    802947 <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  802923:	85 f6                	test   %esi,%esi
  802925:	74 0a                	je     802931 <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  802927:	a1 08 50 80 00       	mov    0x805008,%eax
  80292c:	8b 40 74             	mov    0x74(%eax),%eax
  80292f:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  802931:	85 db                	test   %ebx,%ebx
  802933:	74 0a                	je     80293f <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  802935:	a1 08 50 80 00       	mov    0x805008,%eax
  80293a:	8b 40 78             	mov    0x78(%eax),%eax
  80293d:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  80293f:	a1 08 50 80 00       	mov    0x805008,%eax
  802944:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  802947:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80294a:	5b                   	pop    %ebx
  80294b:	5e                   	pop    %esi
  80294c:	5d                   	pop    %ebp
  80294d:	c3                   	ret    

0080294e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80294e:	55                   	push   %ebp
  80294f:	89 e5                	mov    %esp,%ebp
  802951:	57                   	push   %edi
  802952:	56                   	push   %esi
  802953:	53                   	push   %ebx
  802954:	83 ec 0c             	sub    $0xc,%esp
  802957:	8b 7d 08             	mov    0x8(%ebp),%edi
  80295a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80295d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  802960:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  802962:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  802967:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  80296a:	ff 75 14             	pushl  0x14(%ebp)
  80296d:	53                   	push   %ebx
  80296e:	56                   	push   %esi
  80296f:	57                   	push   %edi
  802970:	e8 51 e4 ff ff       	call   800dc6 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  802975:	83 c4 10             	add    $0x10,%esp
  802978:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80297b:	75 07                	jne    802984 <ipc_send+0x36>
			sys_yield();
  80297d:	e8 98 e2 ff ff       	call   800c1a <sys_yield>
  802982:	eb e6                	jmp    80296a <ipc_send+0x1c>
		} else if (r < 0) {
  802984:	85 c0                	test   %eax,%eax
  802986:	79 12                	jns    80299a <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  802988:	50                   	push   %eax
  802989:	68 06 33 80 00       	push   $0x803306
  80298e:	6a 51                	push   $0x51
  802990:	68 13 33 80 00       	push   $0x803313
  802995:	e8 3e d8 ff ff       	call   8001d8 <_panic>
		}
	}
}
  80299a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80299d:	5b                   	pop    %ebx
  80299e:	5e                   	pop    %esi
  80299f:	5f                   	pop    %edi
  8029a0:	5d                   	pop    %ebp
  8029a1:	c3                   	ret    

008029a2 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8029a2:	55                   	push   %ebp
  8029a3:	89 e5                	mov    %esp,%ebp
  8029a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8029a8:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8029ad:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8029b0:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8029b6:	8b 52 50             	mov    0x50(%edx),%edx
  8029b9:	39 ca                	cmp    %ecx,%edx
  8029bb:	75 0d                	jne    8029ca <ipc_find_env+0x28>
			return envs[i].env_id;
  8029bd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8029c0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8029c5:	8b 40 48             	mov    0x48(%eax),%eax
  8029c8:	eb 0f                	jmp    8029d9 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8029ca:	83 c0 01             	add    $0x1,%eax
  8029cd:	3d 00 04 00 00       	cmp    $0x400,%eax
  8029d2:	75 d9                	jne    8029ad <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8029d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8029d9:	5d                   	pop    %ebp
  8029da:	c3                   	ret    

008029db <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8029db:	55                   	push   %ebp
  8029dc:	89 e5                	mov    %esp,%ebp
  8029de:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8029e1:	89 d0                	mov    %edx,%eax
  8029e3:	c1 e8 16             	shr    $0x16,%eax
  8029e6:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8029ed:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8029f2:	f6 c1 01             	test   $0x1,%cl
  8029f5:	74 1d                	je     802a14 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8029f7:	c1 ea 0c             	shr    $0xc,%edx
  8029fa:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802a01:	f6 c2 01             	test   $0x1,%dl
  802a04:	74 0e                	je     802a14 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802a06:	c1 ea 0c             	shr    $0xc,%edx
  802a09:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802a10:	ef 
  802a11:	0f b7 c0             	movzwl %ax,%eax
}
  802a14:	5d                   	pop    %ebp
  802a15:	c3                   	ret    
  802a16:	66 90                	xchg   %ax,%ax
  802a18:	66 90                	xchg   %ax,%ax
  802a1a:	66 90                	xchg   %ax,%ax
  802a1c:	66 90                	xchg   %ax,%ax
  802a1e:	66 90                	xchg   %ax,%ax

00802a20 <__udivdi3>:
  802a20:	55                   	push   %ebp
  802a21:	57                   	push   %edi
  802a22:	56                   	push   %esi
  802a23:	53                   	push   %ebx
  802a24:	83 ec 1c             	sub    $0x1c,%esp
  802a27:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  802a2b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  802a2f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802a33:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802a37:	85 f6                	test   %esi,%esi
  802a39:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802a3d:	89 ca                	mov    %ecx,%edx
  802a3f:	89 f8                	mov    %edi,%eax
  802a41:	75 3d                	jne    802a80 <__udivdi3+0x60>
  802a43:	39 cf                	cmp    %ecx,%edi
  802a45:	0f 87 c5 00 00 00    	ja     802b10 <__udivdi3+0xf0>
  802a4b:	85 ff                	test   %edi,%edi
  802a4d:	89 fd                	mov    %edi,%ebp
  802a4f:	75 0b                	jne    802a5c <__udivdi3+0x3c>
  802a51:	b8 01 00 00 00       	mov    $0x1,%eax
  802a56:	31 d2                	xor    %edx,%edx
  802a58:	f7 f7                	div    %edi
  802a5a:	89 c5                	mov    %eax,%ebp
  802a5c:	89 c8                	mov    %ecx,%eax
  802a5e:	31 d2                	xor    %edx,%edx
  802a60:	f7 f5                	div    %ebp
  802a62:	89 c1                	mov    %eax,%ecx
  802a64:	89 d8                	mov    %ebx,%eax
  802a66:	89 cf                	mov    %ecx,%edi
  802a68:	f7 f5                	div    %ebp
  802a6a:	89 c3                	mov    %eax,%ebx
  802a6c:	89 d8                	mov    %ebx,%eax
  802a6e:	89 fa                	mov    %edi,%edx
  802a70:	83 c4 1c             	add    $0x1c,%esp
  802a73:	5b                   	pop    %ebx
  802a74:	5e                   	pop    %esi
  802a75:	5f                   	pop    %edi
  802a76:	5d                   	pop    %ebp
  802a77:	c3                   	ret    
  802a78:	90                   	nop
  802a79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802a80:	39 ce                	cmp    %ecx,%esi
  802a82:	77 74                	ja     802af8 <__udivdi3+0xd8>
  802a84:	0f bd fe             	bsr    %esi,%edi
  802a87:	83 f7 1f             	xor    $0x1f,%edi
  802a8a:	0f 84 98 00 00 00    	je     802b28 <__udivdi3+0x108>
  802a90:	bb 20 00 00 00       	mov    $0x20,%ebx
  802a95:	89 f9                	mov    %edi,%ecx
  802a97:	89 c5                	mov    %eax,%ebp
  802a99:	29 fb                	sub    %edi,%ebx
  802a9b:	d3 e6                	shl    %cl,%esi
  802a9d:	89 d9                	mov    %ebx,%ecx
  802a9f:	d3 ed                	shr    %cl,%ebp
  802aa1:	89 f9                	mov    %edi,%ecx
  802aa3:	d3 e0                	shl    %cl,%eax
  802aa5:	09 ee                	or     %ebp,%esi
  802aa7:	89 d9                	mov    %ebx,%ecx
  802aa9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802aad:	89 d5                	mov    %edx,%ebp
  802aaf:	8b 44 24 08          	mov    0x8(%esp),%eax
  802ab3:	d3 ed                	shr    %cl,%ebp
  802ab5:	89 f9                	mov    %edi,%ecx
  802ab7:	d3 e2                	shl    %cl,%edx
  802ab9:	89 d9                	mov    %ebx,%ecx
  802abb:	d3 e8                	shr    %cl,%eax
  802abd:	09 c2                	or     %eax,%edx
  802abf:	89 d0                	mov    %edx,%eax
  802ac1:	89 ea                	mov    %ebp,%edx
  802ac3:	f7 f6                	div    %esi
  802ac5:	89 d5                	mov    %edx,%ebp
  802ac7:	89 c3                	mov    %eax,%ebx
  802ac9:	f7 64 24 0c          	mull   0xc(%esp)
  802acd:	39 d5                	cmp    %edx,%ebp
  802acf:	72 10                	jb     802ae1 <__udivdi3+0xc1>
  802ad1:	8b 74 24 08          	mov    0x8(%esp),%esi
  802ad5:	89 f9                	mov    %edi,%ecx
  802ad7:	d3 e6                	shl    %cl,%esi
  802ad9:	39 c6                	cmp    %eax,%esi
  802adb:	73 07                	jae    802ae4 <__udivdi3+0xc4>
  802add:	39 d5                	cmp    %edx,%ebp
  802adf:	75 03                	jne    802ae4 <__udivdi3+0xc4>
  802ae1:	83 eb 01             	sub    $0x1,%ebx
  802ae4:	31 ff                	xor    %edi,%edi
  802ae6:	89 d8                	mov    %ebx,%eax
  802ae8:	89 fa                	mov    %edi,%edx
  802aea:	83 c4 1c             	add    $0x1c,%esp
  802aed:	5b                   	pop    %ebx
  802aee:	5e                   	pop    %esi
  802aef:	5f                   	pop    %edi
  802af0:	5d                   	pop    %ebp
  802af1:	c3                   	ret    
  802af2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802af8:	31 ff                	xor    %edi,%edi
  802afa:	31 db                	xor    %ebx,%ebx
  802afc:	89 d8                	mov    %ebx,%eax
  802afe:	89 fa                	mov    %edi,%edx
  802b00:	83 c4 1c             	add    $0x1c,%esp
  802b03:	5b                   	pop    %ebx
  802b04:	5e                   	pop    %esi
  802b05:	5f                   	pop    %edi
  802b06:	5d                   	pop    %ebp
  802b07:	c3                   	ret    
  802b08:	90                   	nop
  802b09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802b10:	89 d8                	mov    %ebx,%eax
  802b12:	f7 f7                	div    %edi
  802b14:	31 ff                	xor    %edi,%edi
  802b16:	89 c3                	mov    %eax,%ebx
  802b18:	89 d8                	mov    %ebx,%eax
  802b1a:	89 fa                	mov    %edi,%edx
  802b1c:	83 c4 1c             	add    $0x1c,%esp
  802b1f:	5b                   	pop    %ebx
  802b20:	5e                   	pop    %esi
  802b21:	5f                   	pop    %edi
  802b22:	5d                   	pop    %ebp
  802b23:	c3                   	ret    
  802b24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802b28:	39 ce                	cmp    %ecx,%esi
  802b2a:	72 0c                	jb     802b38 <__udivdi3+0x118>
  802b2c:	31 db                	xor    %ebx,%ebx
  802b2e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802b32:	0f 87 34 ff ff ff    	ja     802a6c <__udivdi3+0x4c>
  802b38:	bb 01 00 00 00       	mov    $0x1,%ebx
  802b3d:	e9 2a ff ff ff       	jmp    802a6c <__udivdi3+0x4c>
  802b42:	66 90                	xchg   %ax,%ax
  802b44:	66 90                	xchg   %ax,%ax
  802b46:	66 90                	xchg   %ax,%ax
  802b48:	66 90                	xchg   %ax,%ax
  802b4a:	66 90                	xchg   %ax,%ax
  802b4c:	66 90                	xchg   %ax,%ax
  802b4e:	66 90                	xchg   %ax,%ax

00802b50 <__umoddi3>:
  802b50:	55                   	push   %ebp
  802b51:	57                   	push   %edi
  802b52:	56                   	push   %esi
  802b53:	53                   	push   %ebx
  802b54:	83 ec 1c             	sub    $0x1c,%esp
  802b57:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  802b5b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  802b5f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802b63:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802b67:	85 d2                	test   %edx,%edx
  802b69:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802b6d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802b71:	89 f3                	mov    %esi,%ebx
  802b73:	89 3c 24             	mov    %edi,(%esp)
  802b76:	89 74 24 04          	mov    %esi,0x4(%esp)
  802b7a:	75 1c                	jne    802b98 <__umoddi3+0x48>
  802b7c:	39 f7                	cmp    %esi,%edi
  802b7e:	76 50                	jbe    802bd0 <__umoddi3+0x80>
  802b80:	89 c8                	mov    %ecx,%eax
  802b82:	89 f2                	mov    %esi,%edx
  802b84:	f7 f7                	div    %edi
  802b86:	89 d0                	mov    %edx,%eax
  802b88:	31 d2                	xor    %edx,%edx
  802b8a:	83 c4 1c             	add    $0x1c,%esp
  802b8d:	5b                   	pop    %ebx
  802b8e:	5e                   	pop    %esi
  802b8f:	5f                   	pop    %edi
  802b90:	5d                   	pop    %ebp
  802b91:	c3                   	ret    
  802b92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802b98:	39 f2                	cmp    %esi,%edx
  802b9a:	89 d0                	mov    %edx,%eax
  802b9c:	77 52                	ja     802bf0 <__umoddi3+0xa0>
  802b9e:	0f bd ea             	bsr    %edx,%ebp
  802ba1:	83 f5 1f             	xor    $0x1f,%ebp
  802ba4:	75 5a                	jne    802c00 <__umoddi3+0xb0>
  802ba6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  802baa:	0f 82 e0 00 00 00    	jb     802c90 <__umoddi3+0x140>
  802bb0:	39 0c 24             	cmp    %ecx,(%esp)
  802bb3:	0f 86 d7 00 00 00    	jbe    802c90 <__umoddi3+0x140>
  802bb9:	8b 44 24 08          	mov    0x8(%esp),%eax
  802bbd:	8b 54 24 04          	mov    0x4(%esp),%edx
  802bc1:	83 c4 1c             	add    $0x1c,%esp
  802bc4:	5b                   	pop    %ebx
  802bc5:	5e                   	pop    %esi
  802bc6:	5f                   	pop    %edi
  802bc7:	5d                   	pop    %ebp
  802bc8:	c3                   	ret    
  802bc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802bd0:	85 ff                	test   %edi,%edi
  802bd2:	89 fd                	mov    %edi,%ebp
  802bd4:	75 0b                	jne    802be1 <__umoddi3+0x91>
  802bd6:	b8 01 00 00 00       	mov    $0x1,%eax
  802bdb:	31 d2                	xor    %edx,%edx
  802bdd:	f7 f7                	div    %edi
  802bdf:	89 c5                	mov    %eax,%ebp
  802be1:	89 f0                	mov    %esi,%eax
  802be3:	31 d2                	xor    %edx,%edx
  802be5:	f7 f5                	div    %ebp
  802be7:	89 c8                	mov    %ecx,%eax
  802be9:	f7 f5                	div    %ebp
  802beb:	89 d0                	mov    %edx,%eax
  802bed:	eb 99                	jmp    802b88 <__umoddi3+0x38>
  802bef:	90                   	nop
  802bf0:	89 c8                	mov    %ecx,%eax
  802bf2:	89 f2                	mov    %esi,%edx
  802bf4:	83 c4 1c             	add    $0x1c,%esp
  802bf7:	5b                   	pop    %ebx
  802bf8:	5e                   	pop    %esi
  802bf9:	5f                   	pop    %edi
  802bfa:	5d                   	pop    %ebp
  802bfb:	c3                   	ret    
  802bfc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802c00:	8b 34 24             	mov    (%esp),%esi
  802c03:	bf 20 00 00 00       	mov    $0x20,%edi
  802c08:	89 e9                	mov    %ebp,%ecx
  802c0a:	29 ef                	sub    %ebp,%edi
  802c0c:	d3 e0                	shl    %cl,%eax
  802c0e:	89 f9                	mov    %edi,%ecx
  802c10:	89 f2                	mov    %esi,%edx
  802c12:	d3 ea                	shr    %cl,%edx
  802c14:	89 e9                	mov    %ebp,%ecx
  802c16:	09 c2                	or     %eax,%edx
  802c18:	89 d8                	mov    %ebx,%eax
  802c1a:	89 14 24             	mov    %edx,(%esp)
  802c1d:	89 f2                	mov    %esi,%edx
  802c1f:	d3 e2                	shl    %cl,%edx
  802c21:	89 f9                	mov    %edi,%ecx
  802c23:	89 54 24 04          	mov    %edx,0x4(%esp)
  802c27:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802c2b:	d3 e8                	shr    %cl,%eax
  802c2d:	89 e9                	mov    %ebp,%ecx
  802c2f:	89 c6                	mov    %eax,%esi
  802c31:	d3 e3                	shl    %cl,%ebx
  802c33:	89 f9                	mov    %edi,%ecx
  802c35:	89 d0                	mov    %edx,%eax
  802c37:	d3 e8                	shr    %cl,%eax
  802c39:	89 e9                	mov    %ebp,%ecx
  802c3b:	09 d8                	or     %ebx,%eax
  802c3d:	89 d3                	mov    %edx,%ebx
  802c3f:	89 f2                	mov    %esi,%edx
  802c41:	f7 34 24             	divl   (%esp)
  802c44:	89 d6                	mov    %edx,%esi
  802c46:	d3 e3                	shl    %cl,%ebx
  802c48:	f7 64 24 04          	mull   0x4(%esp)
  802c4c:	39 d6                	cmp    %edx,%esi
  802c4e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802c52:	89 d1                	mov    %edx,%ecx
  802c54:	89 c3                	mov    %eax,%ebx
  802c56:	72 08                	jb     802c60 <__umoddi3+0x110>
  802c58:	75 11                	jne    802c6b <__umoddi3+0x11b>
  802c5a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  802c5e:	73 0b                	jae    802c6b <__umoddi3+0x11b>
  802c60:	2b 44 24 04          	sub    0x4(%esp),%eax
  802c64:	1b 14 24             	sbb    (%esp),%edx
  802c67:	89 d1                	mov    %edx,%ecx
  802c69:	89 c3                	mov    %eax,%ebx
  802c6b:	8b 54 24 08          	mov    0x8(%esp),%edx
  802c6f:	29 da                	sub    %ebx,%edx
  802c71:	19 ce                	sbb    %ecx,%esi
  802c73:	89 f9                	mov    %edi,%ecx
  802c75:	89 f0                	mov    %esi,%eax
  802c77:	d3 e0                	shl    %cl,%eax
  802c79:	89 e9                	mov    %ebp,%ecx
  802c7b:	d3 ea                	shr    %cl,%edx
  802c7d:	89 e9                	mov    %ebp,%ecx
  802c7f:	d3 ee                	shr    %cl,%esi
  802c81:	09 d0                	or     %edx,%eax
  802c83:	89 f2                	mov    %esi,%edx
  802c85:	83 c4 1c             	add    $0x1c,%esp
  802c88:	5b                   	pop    %ebx
  802c89:	5e                   	pop    %esi
  802c8a:	5f                   	pop    %edi
  802c8b:	5d                   	pop    %ebp
  802c8c:	c3                   	ret    
  802c8d:	8d 76 00             	lea    0x0(%esi),%esi
  802c90:	29 f9                	sub    %edi,%ecx
  802c92:	19 d6                	sbb    %edx,%esi
  802c94:	89 74 24 04          	mov    %esi,0x4(%esp)
  802c98:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802c9c:	e9 18 ff ff ff       	jmp    802bb9 <__umoddi3+0x69>
