
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
  800081:	68 2c 28 80 00       	push   $0x80282c
  800086:	6a 13                	push   $0x13
  800088:	68 3f 28 80 00       	push   $0x80283f
  80008d:	e8 46 01 00 00       	call   8001d8 <_panic>

	// check fork
	if ((r = fork()) < 0)
  800092:	e8 47 0f 00 00       	call   800fde <fork>
  800097:	89 c3                	mov    %eax,%ebx
  800099:	85 c0                	test   %eax,%eax
  80009b:	79 12                	jns    8000af <umain+0x5c>
		panic("fork: %e", r);
  80009d:	50                   	push   %eax
  80009e:	68 60 2c 80 00       	push   $0x802c60
  8000a3:	6a 17                	push   $0x17
  8000a5:	68 3f 28 80 00       	push   $0x80283f
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
  8000d2:	e8 40 21 00 00       	call   802217 <wait>
	cprintf("fork handles PTE_SHARE %s\n", strcmp(VA, msg) == 0 ? "right" : "wrong");
  8000d7:	83 c4 08             	add    $0x8,%esp
  8000da:	ff 35 04 30 80 00    	pushl  0x803004
  8000e0:	68 00 00 00 a0       	push   $0xa0000000
  8000e5:	e8 f6 07 00 00       	call   8008e0 <strcmp>
  8000ea:	83 c4 08             	add    $0x8,%esp
  8000ed:	85 c0                	test   %eax,%eax
  8000ef:	ba 26 28 80 00       	mov    $0x802826,%edx
  8000f4:	b8 20 28 80 00       	mov    $0x802820,%eax
  8000f9:	0f 45 c2             	cmovne %edx,%eax
  8000fc:	50                   	push   %eax
  8000fd:	68 53 28 80 00       	push   $0x802853
  800102:	e8 aa 01 00 00       	call   8002b1 <cprintf>

	// check spawn
	if ((r = spawnl("/testpteshare", "testpteshare", "arg", 0)) < 0)
  800107:	6a 00                	push   $0x0
  800109:	68 6e 28 80 00       	push   $0x80286e
  80010e:	68 73 28 80 00       	push   $0x802873
  800113:	68 72 28 80 00       	push   $0x802872
  800118:	e8 2b 1d 00 00       	call   801e48 <spawnl>
  80011d:	83 c4 20             	add    $0x20,%esp
  800120:	85 c0                	test   %eax,%eax
  800122:	79 12                	jns    800136 <umain+0xe3>
		panic("spawn: %e", r);
  800124:	50                   	push   %eax
  800125:	68 80 28 80 00       	push   $0x802880
  80012a:	6a 21                	push   $0x21
  80012c:	68 3f 28 80 00       	push   $0x80283f
  800131:	e8 a2 00 00 00       	call   8001d8 <_panic>
	wait(r);
  800136:	83 ec 0c             	sub    $0xc,%esp
  800139:	50                   	push   %eax
  80013a:	e8 d8 20 00 00       	call   802217 <wait>
	cprintf("spawn handles PTE_SHARE %s\n", strcmp(VA, msg2) == 0 ? "right" : "wrong");
  80013f:	83 c4 08             	add    $0x8,%esp
  800142:	ff 35 00 30 80 00    	pushl  0x803000
  800148:	68 00 00 00 a0       	push   $0xa0000000
  80014d:	e8 8e 07 00 00       	call   8008e0 <strcmp>
  800152:	83 c4 08             	add    $0x8,%esp
  800155:	85 c0                	test   %eax,%eax
  800157:	ba 26 28 80 00       	mov    $0x802826,%edx
  80015c:	b8 20 28 80 00       	mov    $0x802820,%eax
  800161:	0f 45 c2             	cmovne %edx,%eax
  800164:	50                   	push   %eax
  800165:	68 8a 28 80 00       	push   $0x80288a
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
  8001c4:	e8 d5 10 00 00       	call   80129e <close_all>
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
  8001f6:	68 d0 28 80 00       	push   $0x8028d0
  8001fb:	e8 b1 00 00 00       	call   8002b1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800200:	83 c4 18             	add    $0x18,%esp
  800203:	53                   	push   %ebx
  800204:	ff 75 10             	pushl  0x10(%ebp)
  800207:	e8 54 00 00 00       	call   800260 <vcprintf>
	cprintf("\n");
  80020c:	c7 04 24 00 2e 80 00 	movl   $0x802e00,(%esp)
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
  800314:	e8 77 22 00 00       	call   802590 <__udivdi3>
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
  800357:	e8 64 23 00 00       	call   8026c0 <__umoddi3>
  80035c:	83 c4 14             	add    $0x14,%esp
  80035f:	0f be 80 f3 28 80 00 	movsbl 0x8028f3(%eax),%eax
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
  80045b:	ff 24 85 40 2a 80 00 	jmp    *0x802a40(,%eax,4)
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
  80051f:	8b 14 85 a0 2b 80 00 	mov    0x802ba0(,%eax,4),%edx
  800526:	85 d2                	test   %edx,%edx
  800528:	75 18                	jne    800542 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80052a:	50                   	push   %eax
  80052b:	68 0b 29 80 00       	push   $0x80290b
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
  800543:	68 42 2d 80 00       	push   $0x802d42
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
  800567:	b8 04 29 80 00       	mov    $0x802904,%eax
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
  800be2:	68 ff 2b 80 00       	push   $0x802bff
  800be7:	6a 23                	push   $0x23
  800be9:	68 1c 2c 80 00       	push   $0x802c1c
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
  800c63:	68 ff 2b 80 00       	push   $0x802bff
  800c68:	6a 23                	push   $0x23
  800c6a:	68 1c 2c 80 00       	push   $0x802c1c
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
  800ca5:	68 ff 2b 80 00       	push   $0x802bff
  800caa:	6a 23                	push   $0x23
  800cac:	68 1c 2c 80 00       	push   $0x802c1c
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
  800ce7:	68 ff 2b 80 00       	push   $0x802bff
  800cec:	6a 23                	push   $0x23
  800cee:	68 1c 2c 80 00       	push   $0x802c1c
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
  800d29:	68 ff 2b 80 00       	push   $0x802bff
  800d2e:	6a 23                	push   $0x23
  800d30:	68 1c 2c 80 00       	push   $0x802c1c
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
  800d6b:	68 ff 2b 80 00       	push   $0x802bff
  800d70:	6a 23                	push   $0x23
  800d72:	68 1c 2c 80 00       	push   $0x802c1c
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
  800dad:	68 ff 2b 80 00       	push   $0x802bff
  800db2:	6a 23                	push   $0x23
  800db4:	68 1c 2c 80 00       	push   $0x802c1c
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
  800e11:	68 ff 2b 80 00       	push   $0x802bff
  800e16:	6a 23                	push   $0x23
  800e18:	68 1c 2c 80 00       	push   $0x802c1c
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
  800e2d:	53                   	push   %ebx
  800e2e:	83 ec 04             	sub    $0x4,%esp
	int r;
	void * address = (void *)(pn*PGSIZE);
  800e31:	89 d3                	mov    %edx,%ebx
  800e33:	c1 e3 0c             	shl    $0xc,%ebx
	
	if((uvpt[pn] & PTE_SHARE))
  800e36:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800e3d:	f6 c5 04             	test   $0x4,%ch
  800e40:	74 38                	je     800e7a <duppage+0x50>
	{
		if ((r = sys_page_map(0, address, envid, address, (uvpt[pn] | PTE_SYSCALL))) < 0)
  800e42:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e49:	83 ec 0c             	sub    $0xc,%esp
  800e4c:	81 ca 07 0e 00 00    	or     $0xe07,%edx
  800e52:	52                   	push   %edx
  800e53:	53                   	push   %ebx
  800e54:	50                   	push   %eax
  800e55:	53                   	push   %ebx
  800e56:	6a 00                	push   $0x0
  800e58:	e8 1f fe ff ff       	call   800c7c <sys_page_map>
  800e5d:	83 c4 20             	add    $0x20,%esp
  800e60:	85 c0                	test   %eax,%eax
  800e62:	0f 89 b8 00 00 00    	jns    800f20 <duppage+0xf6>
			panic("sys_page_map: %e", r);
  800e68:	50                   	push   %eax
  800e69:	68 2a 2c 80 00       	push   $0x802c2a
  800e6e:	6a 4e                	push   $0x4e
  800e70:	68 3b 2c 80 00       	push   $0x802c3b
  800e75:	e8 5e f3 ff ff       	call   8001d8 <_panic>
	}
	else if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW))
  800e7a:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800e81:	f6 c1 02             	test   $0x2,%cl
  800e84:	75 0c                	jne    800e92 <duppage+0x68>
  800e86:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800e8d:	f6 c5 08             	test   $0x8,%ch
  800e90:	74 57                	je     800ee9 <duppage+0xbf>
	{
		int perm = 0;
		perm |= PTE_P|PTE_U|PTE_COW;
	
		if ((r = sys_page_map(0, address, envid, address, perm)) < 0)
  800e92:	83 ec 0c             	sub    $0xc,%esp
  800e95:	68 05 08 00 00       	push   $0x805
  800e9a:	53                   	push   %ebx
  800e9b:	50                   	push   %eax
  800e9c:	53                   	push   %ebx
  800e9d:	6a 00                	push   $0x0
  800e9f:	e8 d8 fd ff ff       	call   800c7c <sys_page_map>
  800ea4:	83 c4 20             	add    $0x20,%esp
  800ea7:	85 c0                	test   %eax,%eax
  800ea9:	79 12                	jns    800ebd <duppage+0x93>
			panic("sys_page_map: %e", r);
  800eab:	50                   	push   %eax
  800eac:	68 2a 2c 80 00       	push   $0x802c2a
  800eb1:	6a 56                	push   $0x56
  800eb3:	68 3b 2c 80 00       	push   $0x802c3b
  800eb8:	e8 1b f3 ff ff       	call   8001d8 <_panic>
		if ((r = sys_page_map(0, address, 0, address, perm)) < 0)
  800ebd:	83 ec 0c             	sub    $0xc,%esp
  800ec0:	68 05 08 00 00       	push   $0x805
  800ec5:	53                   	push   %ebx
  800ec6:	6a 00                	push   $0x0
  800ec8:	53                   	push   %ebx
  800ec9:	6a 00                	push   $0x0
  800ecb:	e8 ac fd ff ff       	call   800c7c <sys_page_map>
  800ed0:	83 c4 20             	add    $0x20,%esp
  800ed3:	85 c0                	test   %eax,%eax
  800ed5:	79 49                	jns    800f20 <duppage+0xf6>
			panic("sys_page_map: %e", r);
  800ed7:	50                   	push   %eax
  800ed8:	68 2a 2c 80 00       	push   $0x802c2a
  800edd:	6a 58                	push   $0x58
  800edf:	68 3b 2c 80 00       	push   $0x802c3b
  800ee4:	e8 ef f2 ff ff       	call   8001d8 <_panic>
	}
	else if((uvpt[pn] & ~PTE_U) == 0)
  800ee9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ef0:	f7 c2 fb ff ff ff    	test   $0xfffffffb,%edx
  800ef6:	75 28                	jne    800f20 <duppage+0xf6>
	{
		//cprintf("im here");
		if ((r = sys_page_map(0, address, envid, address, PTE_P|PTE_U)) < 0)
  800ef8:	83 ec 0c             	sub    $0xc,%esp
  800efb:	6a 05                	push   $0x5
  800efd:	53                   	push   %ebx
  800efe:	50                   	push   %eax
  800eff:	53                   	push   %ebx
  800f00:	6a 00                	push   $0x0
  800f02:	e8 75 fd ff ff       	call   800c7c <sys_page_map>
  800f07:	83 c4 20             	add    $0x20,%esp
  800f0a:	85 c0                	test   %eax,%eax
  800f0c:	79 12                	jns    800f20 <duppage+0xf6>
			panic("sys_page_map: %e", r);	
  800f0e:	50                   	push   %eax
  800f0f:	68 2a 2c 80 00       	push   $0x802c2a
  800f14:	6a 5e                	push   $0x5e
  800f16:	68 3b 2c 80 00       	push   $0x802c3b
  800f1b:	e8 b8 f2 ff ff       	call   8001d8 <_panic>
	}
	return 0;
}
  800f20:	b8 00 00 00 00       	mov    $0x0,%eax
  800f25:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f28:	c9                   	leave  
  800f29:	c3                   	ret    

00800f2a <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f2a:	55                   	push   %ebp
  800f2b:	89 e5                	mov    %esp,%ebp
  800f2d:	53                   	push   %ebx
  800f2e:	83 ec 08             	sub    $0x8,%esp
	void *addr = (void *) utf->utf_fault_va;
  800f31:	8b 45 08             	mov    0x8(%ebp),%eax
  800f34:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	unsigned pn = ((uint32_t)addr)/PGSIZE;
  800f36:	89 d8                	mov    %ebx,%eax
  800f38:	c1 e8 0c             	shr    $0xc,%eax
	pte_t pte = uvpt[pn];
  800f3b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// Allocate a new page, mapped at temp location
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  800f42:	6a 07                	push   $0x7
  800f44:	68 00 f0 7f 00       	push   $0x7ff000
  800f49:	6a 00                	push   $0x0
  800f4b:	e8 e9 fc ff ff       	call   800c39 <sys_page_alloc>
  800f50:	83 c4 10             	add    $0x10,%esp
  800f53:	85 c0                	test   %eax,%eax
  800f55:	79 12                	jns    800f69 <pgfault+0x3f>
		panic("sys_page_alloc: %e", r);
  800f57:	50                   	push   %eax
  800f58:	68 2c 28 80 00       	push   $0x80282c
  800f5d:	6a 2b                	push   $0x2b
  800f5f:	68 3b 2c 80 00       	push   $0x802c3b
  800f64:	e8 6f f2 ff ff       	call   8001d8 <_panic>

	// Copy the data from the old page to this new page
	void *addr_pgstart = (void *) ROUNDDOWN(addr, PGSIZE);
  800f69:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr_pgstart, PGSIZE);
  800f6f:	83 ec 04             	sub    $0x4,%esp
  800f72:	68 00 10 00 00       	push   $0x1000
  800f77:	53                   	push   %ebx
  800f78:	68 00 f0 7f 00       	push   $0x7ff000
  800f7d:	e8 46 fa ff ff       	call   8009c8 <memmove>

	// Move the new page to the old page's address
	if ((r = sys_page_map(0, PFTEMP, 0, addr_pgstart, PTE_P|PTE_U|PTE_W)) < 0)
  800f82:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f89:	53                   	push   %ebx
  800f8a:	6a 00                	push   $0x0
  800f8c:	68 00 f0 7f 00       	push   $0x7ff000
  800f91:	6a 00                	push   $0x0
  800f93:	e8 e4 fc ff ff       	call   800c7c <sys_page_map>
  800f98:	83 c4 20             	add    $0x20,%esp
  800f9b:	85 c0                	test   %eax,%eax
  800f9d:	79 12                	jns    800fb1 <pgfault+0x87>
		panic("sys_page_map: %e", r);
  800f9f:	50                   	push   %eax
  800fa0:	68 2a 2c 80 00       	push   $0x802c2a
  800fa5:	6a 33                	push   $0x33
  800fa7:	68 3b 2c 80 00       	push   $0x802c3b
  800fac:	e8 27 f2 ff ff       	call   8001d8 <_panic>

	// Unmap the temp location
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800fb1:	83 ec 08             	sub    $0x8,%esp
  800fb4:	68 00 f0 7f 00       	push   $0x7ff000
  800fb9:	6a 00                	push   $0x0
  800fbb:	e8 fe fc ff ff       	call   800cbe <sys_page_unmap>
  800fc0:	83 c4 10             	add    $0x10,%esp
  800fc3:	85 c0                	test   %eax,%eax
  800fc5:	79 12                	jns    800fd9 <pgfault+0xaf>
		panic("sys_page_unmap: %e", r);
  800fc7:	50                   	push   %eax
  800fc8:	68 46 2c 80 00       	push   $0x802c46
  800fcd:	6a 37                	push   $0x37
  800fcf:	68 3b 2c 80 00       	push   $0x802c3b
  800fd4:	e8 ff f1 ff ff       	call   8001d8 <_panic>
}
  800fd9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fdc:	c9                   	leave  
  800fdd:	c3                   	ret    

00800fde <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fde:	55                   	push   %ebp
  800fdf:	89 e5                	mov    %esp,%ebp
  800fe1:	56                   	push   %esi
  800fe2:	53                   	push   %ebx
  800fe3:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
	// Set up page fault handler
	set_pgfault_handler(&pgfault);
  800fe6:	68 2a 0f 80 00       	push   $0x800f2a
  800feb:	e8 f9 13 00 00       	call   8023e9 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800ff0:	b8 07 00 00 00       	mov    $0x7,%eax
  800ff5:	cd 30                	int    $0x30

	// Create child
	envid_t envid = sys_exofork();
  800ff7:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (envid < 0) {
  800ffa:	83 c4 10             	add    $0x10,%esp
  800ffd:	85 c0                	test   %eax,%eax
  800fff:	79 12                	jns    801013 <fork+0x35>
		panic("sys_exofork: %e", envid);
  801001:	50                   	push   %eax
  801002:	68 59 2c 80 00       	push   $0x802c59
  801007:	6a 7c                	push   $0x7c
  801009:	68 3b 2c 80 00       	push   $0x802c3b
  80100e:	e8 c5 f1 ff ff       	call   8001d8 <_panic>
		return envid;
	}
	if (envid == 0) {
  801013:	85 c0                	test   %eax,%eax
  801015:	75 1e                	jne    801035 <fork+0x57>
		// We are the child.
		thisenv = &envs[ENVX(sys_getenvid())]; // Fix thisenv
  801017:	e8 df fb ff ff       	call   800bfb <sys_getenvid>
  80101c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801021:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801024:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801029:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  80102e:	b8 00 00 00 00       	mov    $0x0,%eax
  801033:	eb 7d                	jmp    8010b2 <fork+0xd4>

	// Set page fault handler on the child.
	// The parent needs to do it, else the child wouldn't be able to handle
	// the fault when trying to access it's stack (which happens as soon it starts)
	extern void _pgfault_upcall(void);
	sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);
  801035:	83 ec 04             	sub    $0x4,%esp
  801038:	6a 07                	push   $0x7
  80103a:	68 00 f0 bf ee       	push   $0xeebff000
  80103f:	50                   	push   %eax
  801040:	e8 f4 fb ff ff       	call   800c39 <sys_page_alloc>
	sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  801045:	83 c4 08             	add    $0x8,%esp
  801048:	68 2e 24 80 00       	push   $0x80242e
  80104d:	ff 75 f4             	pushl  -0xc(%ebp)
  801050:	e8 2f fd ff ff       	call   800d84 <sys_env_set_pgfault_upcall>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  801055:	be 04 60 80 00       	mov    $0x806004,%esi
  80105a:	c1 ee 0c             	shr    $0xc,%esi
  80105d:	83 c4 10             	add    $0x10,%esp
  801060:	bb 00 08 00 00       	mov    $0x800,%ebx
  801065:	eb 0d                	jmp    801074 <fork+0x96>
		duppage(envid, pn);
  801067:	89 da                	mov    %ebx,%edx
  801069:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80106c:	e8 b9 fd ff ff       	call   800e2a <duppage>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  801071:	83 c3 01             	add    $0x1,%ebx
  801074:	39 f3                	cmp    %esi,%ebx
  801076:	76 ef                	jbe    801067 <fork+0x89>
	}

	// Also copy the stack we are currently running on
	// I think it should loop from ustacktop to this page, since the stack
	// can have more than 1 page
	duppage(envid, ((uint32_t) &envid)/PGSIZE);
  801078:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80107b:	c1 ea 0c             	shr    $0xc,%edx
  80107e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801081:	e8 a4 fd ff ff       	call   800e2a <duppage>

	// Start the child environmnet running
	int r;
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  801086:	83 ec 08             	sub    $0x8,%esp
  801089:	6a 02                	push   $0x2
  80108b:	ff 75 f4             	pushl  -0xc(%ebp)
  80108e:	e8 6d fc ff ff       	call   800d00 <sys_env_set_status>
  801093:	83 c4 10             	add    $0x10,%esp
  801096:	85 c0                	test   %eax,%eax
  801098:	79 15                	jns    8010af <fork+0xd1>
		panic("sys_env_set_status: %e", r);
  80109a:	50                   	push   %eax
  80109b:	68 69 2c 80 00       	push   $0x802c69
  8010a0:	68 9c 00 00 00       	push   $0x9c
  8010a5:	68 3b 2c 80 00       	push   $0x802c3b
  8010aa:	e8 29 f1 ff ff       	call   8001d8 <_panic>
		return r;
	}

	return envid;
  8010af:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8010b2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010b5:	5b                   	pop    %ebx
  8010b6:	5e                   	pop    %esi
  8010b7:	5d                   	pop    %ebp
  8010b8:	c3                   	ret    

008010b9 <sfork>:

// Challenge!
int
sfork(void)
{
  8010b9:	55                   	push   %ebp
  8010ba:	89 e5                	mov    %esp,%ebp
  8010bc:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010bf:	68 80 2c 80 00       	push   $0x802c80
  8010c4:	68 a7 00 00 00       	push   $0xa7
  8010c9:	68 3b 2c 80 00       	push   $0x802c3b
  8010ce:	e8 05 f1 ff ff       	call   8001d8 <_panic>

008010d3 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010d3:	55                   	push   %ebp
  8010d4:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d9:	05 00 00 00 30       	add    $0x30000000,%eax
  8010de:	c1 e8 0c             	shr    $0xc,%eax
}
  8010e1:	5d                   	pop    %ebp
  8010e2:	c3                   	ret    

008010e3 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010e3:	55                   	push   %ebp
  8010e4:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8010e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e9:	05 00 00 00 30       	add    $0x30000000,%eax
  8010ee:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010f3:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010f8:	5d                   	pop    %ebp
  8010f9:	c3                   	ret    

008010fa <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010fa:	55                   	push   %ebp
  8010fb:	89 e5                	mov    %esp,%ebp
  8010fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801100:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801105:	89 c2                	mov    %eax,%edx
  801107:	c1 ea 16             	shr    $0x16,%edx
  80110a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801111:	f6 c2 01             	test   $0x1,%dl
  801114:	74 11                	je     801127 <fd_alloc+0x2d>
  801116:	89 c2                	mov    %eax,%edx
  801118:	c1 ea 0c             	shr    $0xc,%edx
  80111b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801122:	f6 c2 01             	test   $0x1,%dl
  801125:	75 09                	jne    801130 <fd_alloc+0x36>
			*fd_store = fd;
  801127:	89 01                	mov    %eax,(%ecx)
			return 0;
  801129:	b8 00 00 00 00       	mov    $0x0,%eax
  80112e:	eb 17                	jmp    801147 <fd_alloc+0x4d>
  801130:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801135:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80113a:	75 c9                	jne    801105 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80113c:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801142:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801147:	5d                   	pop    %ebp
  801148:	c3                   	ret    

00801149 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801149:	55                   	push   %ebp
  80114a:	89 e5                	mov    %esp,%ebp
  80114c:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80114f:	83 f8 1f             	cmp    $0x1f,%eax
  801152:	77 36                	ja     80118a <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801154:	c1 e0 0c             	shl    $0xc,%eax
  801157:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80115c:	89 c2                	mov    %eax,%edx
  80115e:	c1 ea 16             	shr    $0x16,%edx
  801161:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801168:	f6 c2 01             	test   $0x1,%dl
  80116b:	74 24                	je     801191 <fd_lookup+0x48>
  80116d:	89 c2                	mov    %eax,%edx
  80116f:	c1 ea 0c             	shr    $0xc,%edx
  801172:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801179:	f6 c2 01             	test   $0x1,%dl
  80117c:	74 1a                	je     801198 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80117e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801181:	89 02                	mov    %eax,(%edx)
	return 0;
  801183:	b8 00 00 00 00       	mov    $0x0,%eax
  801188:	eb 13                	jmp    80119d <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80118a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80118f:	eb 0c                	jmp    80119d <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801191:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801196:	eb 05                	jmp    80119d <fd_lookup+0x54>
  801198:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80119d:	5d                   	pop    %ebp
  80119e:	c3                   	ret    

0080119f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80119f:	55                   	push   %ebp
  8011a0:	89 e5                	mov    %esp,%ebp
  8011a2:	83 ec 08             	sub    $0x8,%esp
  8011a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011a8:	ba 14 2d 80 00       	mov    $0x802d14,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8011ad:	eb 13                	jmp    8011c2 <dev_lookup+0x23>
  8011af:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8011b2:	39 08                	cmp    %ecx,(%eax)
  8011b4:	75 0c                	jne    8011c2 <dev_lookup+0x23>
			*dev = devtab[i];
  8011b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011b9:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8011c0:	eb 2e                	jmp    8011f0 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011c2:	8b 02                	mov    (%edx),%eax
  8011c4:	85 c0                	test   %eax,%eax
  8011c6:	75 e7                	jne    8011af <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011c8:	a1 04 40 80 00       	mov    0x804004,%eax
  8011cd:	8b 40 48             	mov    0x48(%eax),%eax
  8011d0:	83 ec 04             	sub    $0x4,%esp
  8011d3:	51                   	push   %ecx
  8011d4:	50                   	push   %eax
  8011d5:	68 98 2c 80 00       	push   $0x802c98
  8011da:	e8 d2 f0 ff ff       	call   8002b1 <cprintf>
	*dev = 0;
  8011df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011e2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8011e8:	83 c4 10             	add    $0x10,%esp
  8011eb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011f0:	c9                   	leave  
  8011f1:	c3                   	ret    

008011f2 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8011f2:	55                   	push   %ebp
  8011f3:	89 e5                	mov    %esp,%ebp
  8011f5:	56                   	push   %esi
  8011f6:	53                   	push   %ebx
  8011f7:	83 ec 10             	sub    $0x10,%esp
  8011fa:	8b 75 08             	mov    0x8(%ebp),%esi
  8011fd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801200:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801203:	50                   	push   %eax
  801204:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80120a:	c1 e8 0c             	shr    $0xc,%eax
  80120d:	50                   	push   %eax
  80120e:	e8 36 ff ff ff       	call   801149 <fd_lookup>
  801213:	83 c4 08             	add    $0x8,%esp
  801216:	85 c0                	test   %eax,%eax
  801218:	78 05                	js     80121f <fd_close+0x2d>
	    || fd != fd2)
  80121a:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80121d:	74 0c                	je     80122b <fd_close+0x39>
		return (must_exist ? r : 0);
  80121f:	84 db                	test   %bl,%bl
  801221:	ba 00 00 00 00       	mov    $0x0,%edx
  801226:	0f 44 c2             	cmove  %edx,%eax
  801229:	eb 41                	jmp    80126c <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80122b:	83 ec 08             	sub    $0x8,%esp
  80122e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801231:	50                   	push   %eax
  801232:	ff 36                	pushl  (%esi)
  801234:	e8 66 ff ff ff       	call   80119f <dev_lookup>
  801239:	89 c3                	mov    %eax,%ebx
  80123b:	83 c4 10             	add    $0x10,%esp
  80123e:	85 c0                	test   %eax,%eax
  801240:	78 1a                	js     80125c <fd_close+0x6a>
		if (dev->dev_close)
  801242:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801245:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801248:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80124d:	85 c0                	test   %eax,%eax
  80124f:	74 0b                	je     80125c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801251:	83 ec 0c             	sub    $0xc,%esp
  801254:	56                   	push   %esi
  801255:	ff d0                	call   *%eax
  801257:	89 c3                	mov    %eax,%ebx
  801259:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80125c:	83 ec 08             	sub    $0x8,%esp
  80125f:	56                   	push   %esi
  801260:	6a 00                	push   $0x0
  801262:	e8 57 fa ff ff       	call   800cbe <sys_page_unmap>
	return r;
  801267:	83 c4 10             	add    $0x10,%esp
  80126a:	89 d8                	mov    %ebx,%eax
}
  80126c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80126f:	5b                   	pop    %ebx
  801270:	5e                   	pop    %esi
  801271:	5d                   	pop    %ebp
  801272:	c3                   	ret    

00801273 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801273:	55                   	push   %ebp
  801274:	89 e5                	mov    %esp,%ebp
  801276:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801279:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80127c:	50                   	push   %eax
  80127d:	ff 75 08             	pushl  0x8(%ebp)
  801280:	e8 c4 fe ff ff       	call   801149 <fd_lookup>
  801285:	83 c4 08             	add    $0x8,%esp
  801288:	85 c0                	test   %eax,%eax
  80128a:	78 10                	js     80129c <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80128c:	83 ec 08             	sub    $0x8,%esp
  80128f:	6a 01                	push   $0x1
  801291:	ff 75 f4             	pushl  -0xc(%ebp)
  801294:	e8 59 ff ff ff       	call   8011f2 <fd_close>
  801299:	83 c4 10             	add    $0x10,%esp
}
  80129c:	c9                   	leave  
  80129d:	c3                   	ret    

0080129e <close_all>:

void
close_all(void)
{
  80129e:	55                   	push   %ebp
  80129f:	89 e5                	mov    %esp,%ebp
  8012a1:	53                   	push   %ebx
  8012a2:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012a5:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012aa:	83 ec 0c             	sub    $0xc,%esp
  8012ad:	53                   	push   %ebx
  8012ae:	e8 c0 ff ff ff       	call   801273 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8012b3:	83 c3 01             	add    $0x1,%ebx
  8012b6:	83 c4 10             	add    $0x10,%esp
  8012b9:	83 fb 20             	cmp    $0x20,%ebx
  8012bc:	75 ec                	jne    8012aa <close_all+0xc>
		close(i);
}
  8012be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012c1:	c9                   	leave  
  8012c2:	c3                   	ret    

008012c3 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012c3:	55                   	push   %ebp
  8012c4:	89 e5                	mov    %esp,%ebp
  8012c6:	57                   	push   %edi
  8012c7:	56                   	push   %esi
  8012c8:	53                   	push   %ebx
  8012c9:	83 ec 2c             	sub    $0x2c,%esp
  8012cc:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012cf:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012d2:	50                   	push   %eax
  8012d3:	ff 75 08             	pushl  0x8(%ebp)
  8012d6:	e8 6e fe ff ff       	call   801149 <fd_lookup>
  8012db:	83 c4 08             	add    $0x8,%esp
  8012de:	85 c0                	test   %eax,%eax
  8012e0:	0f 88 c1 00 00 00    	js     8013a7 <dup+0xe4>
		return r;
	close(newfdnum);
  8012e6:	83 ec 0c             	sub    $0xc,%esp
  8012e9:	56                   	push   %esi
  8012ea:	e8 84 ff ff ff       	call   801273 <close>

	newfd = INDEX2FD(newfdnum);
  8012ef:	89 f3                	mov    %esi,%ebx
  8012f1:	c1 e3 0c             	shl    $0xc,%ebx
  8012f4:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8012fa:	83 c4 04             	add    $0x4,%esp
  8012fd:	ff 75 e4             	pushl  -0x1c(%ebp)
  801300:	e8 de fd ff ff       	call   8010e3 <fd2data>
  801305:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801307:	89 1c 24             	mov    %ebx,(%esp)
  80130a:	e8 d4 fd ff ff       	call   8010e3 <fd2data>
  80130f:	83 c4 10             	add    $0x10,%esp
  801312:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801315:	89 f8                	mov    %edi,%eax
  801317:	c1 e8 16             	shr    $0x16,%eax
  80131a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801321:	a8 01                	test   $0x1,%al
  801323:	74 37                	je     80135c <dup+0x99>
  801325:	89 f8                	mov    %edi,%eax
  801327:	c1 e8 0c             	shr    $0xc,%eax
  80132a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801331:	f6 c2 01             	test   $0x1,%dl
  801334:	74 26                	je     80135c <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801336:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80133d:	83 ec 0c             	sub    $0xc,%esp
  801340:	25 07 0e 00 00       	and    $0xe07,%eax
  801345:	50                   	push   %eax
  801346:	ff 75 d4             	pushl  -0x2c(%ebp)
  801349:	6a 00                	push   $0x0
  80134b:	57                   	push   %edi
  80134c:	6a 00                	push   $0x0
  80134e:	e8 29 f9 ff ff       	call   800c7c <sys_page_map>
  801353:	89 c7                	mov    %eax,%edi
  801355:	83 c4 20             	add    $0x20,%esp
  801358:	85 c0                	test   %eax,%eax
  80135a:	78 2e                	js     80138a <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80135c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80135f:	89 d0                	mov    %edx,%eax
  801361:	c1 e8 0c             	shr    $0xc,%eax
  801364:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80136b:	83 ec 0c             	sub    $0xc,%esp
  80136e:	25 07 0e 00 00       	and    $0xe07,%eax
  801373:	50                   	push   %eax
  801374:	53                   	push   %ebx
  801375:	6a 00                	push   $0x0
  801377:	52                   	push   %edx
  801378:	6a 00                	push   $0x0
  80137a:	e8 fd f8 ff ff       	call   800c7c <sys_page_map>
  80137f:	89 c7                	mov    %eax,%edi
  801381:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801384:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801386:	85 ff                	test   %edi,%edi
  801388:	79 1d                	jns    8013a7 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80138a:	83 ec 08             	sub    $0x8,%esp
  80138d:	53                   	push   %ebx
  80138e:	6a 00                	push   $0x0
  801390:	e8 29 f9 ff ff       	call   800cbe <sys_page_unmap>
	sys_page_unmap(0, nva);
  801395:	83 c4 08             	add    $0x8,%esp
  801398:	ff 75 d4             	pushl  -0x2c(%ebp)
  80139b:	6a 00                	push   $0x0
  80139d:	e8 1c f9 ff ff       	call   800cbe <sys_page_unmap>
	return r;
  8013a2:	83 c4 10             	add    $0x10,%esp
  8013a5:	89 f8                	mov    %edi,%eax
}
  8013a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013aa:	5b                   	pop    %ebx
  8013ab:	5e                   	pop    %esi
  8013ac:	5f                   	pop    %edi
  8013ad:	5d                   	pop    %ebp
  8013ae:	c3                   	ret    

008013af <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013af:	55                   	push   %ebp
  8013b0:	89 e5                	mov    %esp,%ebp
  8013b2:	53                   	push   %ebx
  8013b3:	83 ec 14             	sub    $0x14,%esp
  8013b6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013b9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013bc:	50                   	push   %eax
  8013bd:	53                   	push   %ebx
  8013be:	e8 86 fd ff ff       	call   801149 <fd_lookup>
  8013c3:	83 c4 08             	add    $0x8,%esp
  8013c6:	89 c2                	mov    %eax,%edx
  8013c8:	85 c0                	test   %eax,%eax
  8013ca:	78 6d                	js     801439 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013cc:	83 ec 08             	sub    $0x8,%esp
  8013cf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013d2:	50                   	push   %eax
  8013d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013d6:	ff 30                	pushl  (%eax)
  8013d8:	e8 c2 fd ff ff       	call   80119f <dev_lookup>
  8013dd:	83 c4 10             	add    $0x10,%esp
  8013e0:	85 c0                	test   %eax,%eax
  8013e2:	78 4c                	js     801430 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013e4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013e7:	8b 42 08             	mov    0x8(%edx),%eax
  8013ea:	83 e0 03             	and    $0x3,%eax
  8013ed:	83 f8 01             	cmp    $0x1,%eax
  8013f0:	75 21                	jne    801413 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013f2:	a1 04 40 80 00       	mov    0x804004,%eax
  8013f7:	8b 40 48             	mov    0x48(%eax),%eax
  8013fa:	83 ec 04             	sub    $0x4,%esp
  8013fd:	53                   	push   %ebx
  8013fe:	50                   	push   %eax
  8013ff:	68 d9 2c 80 00       	push   $0x802cd9
  801404:	e8 a8 ee ff ff       	call   8002b1 <cprintf>
		return -E_INVAL;
  801409:	83 c4 10             	add    $0x10,%esp
  80140c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801411:	eb 26                	jmp    801439 <read+0x8a>
	}
	if (!dev->dev_read)
  801413:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801416:	8b 40 08             	mov    0x8(%eax),%eax
  801419:	85 c0                	test   %eax,%eax
  80141b:	74 17                	je     801434 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80141d:	83 ec 04             	sub    $0x4,%esp
  801420:	ff 75 10             	pushl  0x10(%ebp)
  801423:	ff 75 0c             	pushl  0xc(%ebp)
  801426:	52                   	push   %edx
  801427:	ff d0                	call   *%eax
  801429:	89 c2                	mov    %eax,%edx
  80142b:	83 c4 10             	add    $0x10,%esp
  80142e:	eb 09                	jmp    801439 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801430:	89 c2                	mov    %eax,%edx
  801432:	eb 05                	jmp    801439 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801434:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801439:	89 d0                	mov    %edx,%eax
  80143b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80143e:	c9                   	leave  
  80143f:	c3                   	ret    

00801440 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801440:	55                   	push   %ebp
  801441:	89 e5                	mov    %esp,%ebp
  801443:	57                   	push   %edi
  801444:	56                   	push   %esi
  801445:	53                   	push   %ebx
  801446:	83 ec 0c             	sub    $0xc,%esp
  801449:	8b 7d 08             	mov    0x8(%ebp),%edi
  80144c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80144f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801454:	eb 21                	jmp    801477 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801456:	83 ec 04             	sub    $0x4,%esp
  801459:	89 f0                	mov    %esi,%eax
  80145b:	29 d8                	sub    %ebx,%eax
  80145d:	50                   	push   %eax
  80145e:	89 d8                	mov    %ebx,%eax
  801460:	03 45 0c             	add    0xc(%ebp),%eax
  801463:	50                   	push   %eax
  801464:	57                   	push   %edi
  801465:	e8 45 ff ff ff       	call   8013af <read>
		if (m < 0)
  80146a:	83 c4 10             	add    $0x10,%esp
  80146d:	85 c0                	test   %eax,%eax
  80146f:	78 10                	js     801481 <readn+0x41>
			return m;
		if (m == 0)
  801471:	85 c0                	test   %eax,%eax
  801473:	74 0a                	je     80147f <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801475:	01 c3                	add    %eax,%ebx
  801477:	39 f3                	cmp    %esi,%ebx
  801479:	72 db                	jb     801456 <readn+0x16>
  80147b:	89 d8                	mov    %ebx,%eax
  80147d:	eb 02                	jmp    801481 <readn+0x41>
  80147f:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801481:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801484:	5b                   	pop    %ebx
  801485:	5e                   	pop    %esi
  801486:	5f                   	pop    %edi
  801487:	5d                   	pop    %ebp
  801488:	c3                   	ret    

00801489 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801489:	55                   	push   %ebp
  80148a:	89 e5                	mov    %esp,%ebp
  80148c:	53                   	push   %ebx
  80148d:	83 ec 14             	sub    $0x14,%esp
  801490:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801493:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801496:	50                   	push   %eax
  801497:	53                   	push   %ebx
  801498:	e8 ac fc ff ff       	call   801149 <fd_lookup>
  80149d:	83 c4 08             	add    $0x8,%esp
  8014a0:	89 c2                	mov    %eax,%edx
  8014a2:	85 c0                	test   %eax,%eax
  8014a4:	78 68                	js     80150e <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014a6:	83 ec 08             	sub    $0x8,%esp
  8014a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ac:	50                   	push   %eax
  8014ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014b0:	ff 30                	pushl  (%eax)
  8014b2:	e8 e8 fc ff ff       	call   80119f <dev_lookup>
  8014b7:	83 c4 10             	add    $0x10,%esp
  8014ba:	85 c0                	test   %eax,%eax
  8014bc:	78 47                	js     801505 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014c1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014c5:	75 21                	jne    8014e8 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014c7:	a1 04 40 80 00       	mov    0x804004,%eax
  8014cc:	8b 40 48             	mov    0x48(%eax),%eax
  8014cf:	83 ec 04             	sub    $0x4,%esp
  8014d2:	53                   	push   %ebx
  8014d3:	50                   	push   %eax
  8014d4:	68 f5 2c 80 00       	push   $0x802cf5
  8014d9:	e8 d3 ed ff ff       	call   8002b1 <cprintf>
		return -E_INVAL;
  8014de:	83 c4 10             	add    $0x10,%esp
  8014e1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014e6:	eb 26                	jmp    80150e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014e8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014eb:	8b 52 0c             	mov    0xc(%edx),%edx
  8014ee:	85 d2                	test   %edx,%edx
  8014f0:	74 17                	je     801509 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014f2:	83 ec 04             	sub    $0x4,%esp
  8014f5:	ff 75 10             	pushl  0x10(%ebp)
  8014f8:	ff 75 0c             	pushl  0xc(%ebp)
  8014fb:	50                   	push   %eax
  8014fc:	ff d2                	call   *%edx
  8014fe:	89 c2                	mov    %eax,%edx
  801500:	83 c4 10             	add    $0x10,%esp
  801503:	eb 09                	jmp    80150e <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801505:	89 c2                	mov    %eax,%edx
  801507:	eb 05                	jmp    80150e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801509:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80150e:	89 d0                	mov    %edx,%eax
  801510:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801513:	c9                   	leave  
  801514:	c3                   	ret    

00801515 <seek>:

int
seek(int fdnum, off_t offset)
{
  801515:	55                   	push   %ebp
  801516:	89 e5                	mov    %esp,%ebp
  801518:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80151b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80151e:	50                   	push   %eax
  80151f:	ff 75 08             	pushl  0x8(%ebp)
  801522:	e8 22 fc ff ff       	call   801149 <fd_lookup>
  801527:	83 c4 08             	add    $0x8,%esp
  80152a:	85 c0                	test   %eax,%eax
  80152c:	78 0e                	js     80153c <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80152e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801531:	8b 55 0c             	mov    0xc(%ebp),%edx
  801534:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801537:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80153c:	c9                   	leave  
  80153d:	c3                   	ret    

0080153e <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80153e:	55                   	push   %ebp
  80153f:	89 e5                	mov    %esp,%ebp
  801541:	53                   	push   %ebx
  801542:	83 ec 14             	sub    $0x14,%esp
  801545:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801548:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80154b:	50                   	push   %eax
  80154c:	53                   	push   %ebx
  80154d:	e8 f7 fb ff ff       	call   801149 <fd_lookup>
  801552:	83 c4 08             	add    $0x8,%esp
  801555:	89 c2                	mov    %eax,%edx
  801557:	85 c0                	test   %eax,%eax
  801559:	78 65                	js     8015c0 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80155b:	83 ec 08             	sub    $0x8,%esp
  80155e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801561:	50                   	push   %eax
  801562:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801565:	ff 30                	pushl  (%eax)
  801567:	e8 33 fc ff ff       	call   80119f <dev_lookup>
  80156c:	83 c4 10             	add    $0x10,%esp
  80156f:	85 c0                	test   %eax,%eax
  801571:	78 44                	js     8015b7 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801573:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801576:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80157a:	75 21                	jne    80159d <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80157c:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801581:	8b 40 48             	mov    0x48(%eax),%eax
  801584:	83 ec 04             	sub    $0x4,%esp
  801587:	53                   	push   %ebx
  801588:	50                   	push   %eax
  801589:	68 b8 2c 80 00       	push   $0x802cb8
  80158e:	e8 1e ed ff ff       	call   8002b1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801593:	83 c4 10             	add    $0x10,%esp
  801596:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80159b:	eb 23                	jmp    8015c0 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80159d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015a0:	8b 52 18             	mov    0x18(%edx),%edx
  8015a3:	85 d2                	test   %edx,%edx
  8015a5:	74 14                	je     8015bb <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015a7:	83 ec 08             	sub    $0x8,%esp
  8015aa:	ff 75 0c             	pushl  0xc(%ebp)
  8015ad:	50                   	push   %eax
  8015ae:	ff d2                	call   *%edx
  8015b0:	89 c2                	mov    %eax,%edx
  8015b2:	83 c4 10             	add    $0x10,%esp
  8015b5:	eb 09                	jmp    8015c0 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b7:	89 c2                	mov    %eax,%edx
  8015b9:	eb 05                	jmp    8015c0 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8015bb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8015c0:	89 d0                	mov    %edx,%eax
  8015c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015c5:	c9                   	leave  
  8015c6:	c3                   	ret    

008015c7 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015c7:	55                   	push   %ebp
  8015c8:	89 e5                	mov    %esp,%ebp
  8015ca:	53                   	push   %ebx
  8015cb:	83 ec 14             	sub    $0x14,%esp
  8015ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015d1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015d4:	50                   	push   %eax
  8015d5:	ff 75 08             	pushl  0x8(%ebp)
  8015d8:	e8 6c fb ff ff       	call   801149 <fd_lookup>
  8015dd:	83 c4 08             	add    $0x8,%esp
  8015e0:	89 c2                	mov    %eax,%edx
  8015e2:	85 c0                	test   %eax,%eax
  8015e4:	78 58                	js     80163e <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015e6:	83 ec 08             	sub    $0x8,%esp
  8015e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ec:	50                   	push   %eax
  8015ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015f0:	ff 30                	pushl  (%eax)
  8015f2:	e8 a8 fb ff ff       	call   80119f <dev_lookup>
  8015f7:	83 c4 10             	add    $0x10,%esp
  8015fa:	85 c0                	test   %eax,%eax
  8015fc:	78 37                	js     801635 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8015fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801601:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801605:	74 32                	je     801639 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801607:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80160a:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801611:	00 00 00 
	stat->st_isdir = 0;
  801614:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80161b:	00 00 00 
	stat->st_dev = dev;
  80161e:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801624:	83 ec 08             	sub    $0x8,%esp
  801627:	53                   	push   %ebx
  801628:	ff 75 f0             	pushl  -0x10(%ebp)
  80162b:	ff 50 14             	call   *0x14(%eax)
  80162e:	89 c2                	mov    %eax,%edx
  801630:	83 c4 10             	add    $0x10,%esp
  801633:	eb 09                	jmp    80163e <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801635:	89 c2                	mov    %eax,%edx
  801637:	eb 05                	jmp    80163e <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801639:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80163e:	89 d0                	mov    %edx,%eax
  801640:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801643:	c9                   	leave  
  801644:	c3                   	ret    

00801645 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801645:	55                   	push   %ebp
  801646:	89 e5                	mov    %esp,%ebp
  801648:	56                   	push   %esi
  801649:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80164a:	83 ec 08             	sub    $0x8,%esp
  80164d:	6a 00                	push   $0x0
  80164f:	ff 75 08             	pushl  0x8(%ebp)
  801652:	e8 0c 02 00 00       	call   801863 <open>
  801657:	89 c3                	mov    %eax,%ebx
  801659:	83 c4 10             	add    $0x10,%esp
  80165c:	85 c0                	test   %eax,%eax
  80165e:	78 1b                	js     80167b <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801660:	83 ec 08             	sub    $0x8,%esp
  801663:	ff 75 0c             	pushl  0xc(%ebp)
  801666:	50                   	push   %eax
  801667:	e8 5b ff ff ff       	call   8015c7 <fstat>
  80166c:	89 c6                	mov    %eax,%esi
	close(fd);
  80166e:	89 1c 24             	mov    %ebx,(%esp)
  801671:	e8 fd fb ff ff       	call   801273 <close>
	return r;
  801676:	83 c4 10             	add    $0x10,%esp
  801679:	89 f0                	mov    %esi,%eax
}
  80167b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80167e:	5b                   	pop    %ebx
  80167f:	5e                   	pop    %esi
  801680:	5d                   	pop    %ebp
  801681:	c3                   	ret    

00801682 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801682:	55                   	push   %ebp
  801683:	89 e5                	mov    %esp,%ebp
  801685:	56                   	push   %esi
  801686:	53                   	push   %ebx
  801687:	89 c6                	mov    %eax,%esi
  801689:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80168b:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801692:	75 12                	jne    8016a6 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801694:	83 ec 0c             	sub    $0xc,%esp
  801697:	6a 01                	push   $0x1
  801699:	e8 7e 0e 00 00       	call   80251c <ipc_find_env>
  80169e:	a3 00 40 80 00       	mov    %eax,0x804000
  8016a3:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016a6:	6a 07                	push   $0x7
  8016a8:	68 00 50 80 00       	push   $0x805000
  8016ad:	56                   	push   %esi
  8016ae:	ff 35 00 40 80 00    	pushl  0x804000
  8016b4:	e8 0f 0e 00 00       	call   8024c8 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016b9:	83 c4 0c             	add    $0xc,%esp
  8016bc:	6a 00                	push   $0x0
  8016be:	53                   	push   %ebx
  8016bf:	6a 00                	push   $0x0
  8016c1:	e8 99 0d 00 00       	call   80245f <ipc_recv>
}
  8016c6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016c9:	5b                   	pop    %ebx
  8016ca:	5e                   	pop    %esi
  8016cb:	5d                   	pop    %ebp
  8016cc:	c3                   	ret    

008016cd <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016cd:	55                   	push   %ebp
  8016ce:	89 e5                	mov    %esp,%ebp
  8016d0:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d6:	8b 40 0c             	mov    0xc(%eax),%eax
  8016d9:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8016de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016e1:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8016eb:	b8 02 00 00 00       	mov    $0x2,%eax
  8016f0:	e8 8d ff ff ff       	call   801682 <fsipc>
}
  8016f5:	c9                   	leave  
  8016f6:	c3                   	ret    

008016f7 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8016f7:	55                   	push   %ebp
  8016f8:	89 e5                	mov    %esp,%ebp
  8016fa:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801700:	8b 40 0c             	mov    0xc(%eax),%eax
  801703:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801708:	ba 00 00 00 00       	mov    $0x0,%edx
  80170d:	b8 06 00 00 00       	mov    $0x6,%eax
  801712:	e8 6b ff ff ff       	call   801682 <fsipc>
}
  801717:	c9                   	leave  
  801718:	c3                   	ret    

00801719 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801719:	55                   	push   %ebp
  80171a:	89 e5                	mov    %esp,%ebp
  80171c:	53                   	push   %ebx
  80171d:	83 ec 04             	sub    $0x4,%esp
  801720:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801723:	8b 45 08             	mov    0x8(%ebp),%eax
  801726:	8b 40 0c             	mov    0xc(%eax),%eax
  801729:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80172e:	ba 00 00 00 00       	mov    $0x0,%edx
  801733:	b8 05 00 00 00       	mov    $0x5,%eax
  801738:	e8 45 ff ff ff       	call   801682 <fsipc>
  80173d:	85 c0                	test   %eax,%eax
  80173f:	78 2c                	js     80176d <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801741:	83 ec 08             	sub    $0x8,%esp
  801744:	68 00 50 80 00       	push   $0x805000
  801749:	53                   	push   %ebx
  80174a:	e8 e7 f0 ff ff       	call   800836 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80174f:	a1 80 50 80 00       	mov    0x805080,%eax
  801754:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80175a:	a1 84 50 80 00       	mov    0x805084,%eax
  80175f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801765:	83 c4 10             	add    $0x10,%esp
  801768:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80176d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801770:	c9                   	leave  
  801771:	c3                   	ret    

00801772 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801772:	55                   	push   %ebp
  801773:	89 e5                	mov    %esp,%ebp
  801775:	53                   	push   %ebx
  801776:	83 ec 08             	sub    $0x8,%esp
  801779:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80177c:	8b 55 08             	mov    0x8(%ebp),%edx
  80177f:	8b 52 0c             	mov    0xc(%edx),%edx
  801782:	89 15 00 50 80 00    	mov    %edx,0x805000
  801788:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80178d:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  801792:	0f 46 d8             	cmovbe %eax,%ebx
	
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  801795:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  80179b:	53                   	push   %ebx
  80179c:	ff 75 0c             	pushl  0xc(%ebp)
  80179f:	68 08 50 80 00       	push   $0x805008
  8017a4:	e8 1f f2 ff ff       	call   8009c8 <memmove>

	
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) 
  8017a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ae:	b8 04 00 00 00       	mov    $0x4,%eax
  8017b3:	e8 ca fe ff ff       	call   801682 <fsipc>
  8017b8:	83 c4 10             	add    $0x10,%esp
  8017bb:	85 c0                	test   %eax,%eax
  8017bd:	78 1d                	js     8017dc <devfile_write+0x6a>
		return r;
	assert(r <= n_real); 
  8017bf:	39 d8                	cmp    %ebx,%eax
  8017c1:	76 19                	jbe    8017dc <devfile_write+0x6a>
  8017c3:	68 24 2d 80 00       	push   $0x802d24
  8017c8:	68 30 2d 80 00       	push   $0x802d30
  8017cd:	68 a3 00 00 00       	push   $0xa3
  8017d2:	68 45 2d 80 00       	push   $0x802d45
  8017d7:	e8 fc e9 ff ff       	call   8001d8 <_panic>
	return r;
}
  8017dc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017df:	c9                   	leave  
  8017e0:	c3                   	ret    

008017e1 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017e1:	55                   	push   %ebp
  8017e2:	89 e5                	mov    %esp,%ebp
  8017e4:	56                   	push   %esi
  8017e5:	53                   	push   %ebx
  8017e6:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ec:	8b 40 0c             	mov    0xc(%eax),%eax
  8017ef:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8017f4:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ff:	b8 03 00 00 00       	mov    $0x3,%eax
  801804:	e8 79 fe ff ff       	call   801682 <fsipc>
  801809:	89 c3                	mov    %eax,%ebx
  80180b:	85 c0                	test   %eax,%eax
  80180d:	78 4b                	js     80185a <devfile_read+0x79>
		return r;
	assert(r <= n);
  80180f:	39 c6                	cmp    %eax,%esi
  801811:	73 16                	jae    801829 <devfile_read+0x48>
  801813:	68 50 2d 80 00       	push   $0x802d50
  801818:	68 30 2d 80 00       	push   $0x802d30
  80181d:	6a 7c                	push   $0x7c
  80181f:	68 45 2d 80 00       	push   $0x802d45
  801824:	e8 af e9 ff ff       	call   8001d8 <_panic>
	assert(r <= PGSIZE);
  801829:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80182e:	7e 16                	jle    801846 <devfile_read+0x65>
  801830:	68 57 2d 80 00       	push   $0x802d57
  801835:	68 30 2d 80 00       	push   $0x802d30
  80183a:	6a 7d                	push   $0x7d
  80183c:	68 45 2d 80 00       	push   $0x802d45
  801841:	e8 92 e9 ff ff       	call   8001d8 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801846:	83 ec 04             	sub    $0x4,%esp
  801849:	50                   	push   %eax
  80184a:	68 00 50 80 00       	push   $0x805000
  80184f:	ff 75 0c             	pushl  0xc(%ebp)
  801852:	e8 71 f1 ff ff       	call   8009c8 <memmove>
	return r;
  801857:	83 c4 10             	add    $0x10,%esp
}
  80185a:	89 d8                	mov    %ebx,%eax
  80185c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80185f:	5b                   	pop    %ebx
  801860:	5e                   	pop    %esi
  801861:	5d                   	pop    %ebp
  801862:	c3                   	ret    

00801863 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801863:	55                   	push   %ebp
  801864:	89 e5                	mov    %esp,%ebp
  801866:	53                   	push   %ebx
  801867:	83 ec 20             	sub    $0x20,%esp
  80186a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80186d:	53                   	push   %ebx
  80186e:	e8 8a ef ff ff       	call   8007fd <strlen>
  801873:	83 c4 10             	add    $0x10,%esp
  801876:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80187b:	7f 67                	jg     8018e4 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80187d:	83 ec 0c             	sub    $0xc,%esp
  801880:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801883:	50                   	push   %eax
  801884:	e8 71 f8 ff ff       	call   8010fa <fd_alloc>
  801889:	83 c4 10             	add    $0x10,%esp
		return r;
  80188c:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80188e:	85 c0                	test   %eax,%eax
  801890:	78 57                	js     8018e9 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801892:	83 ec 08             	sub    $0x8,%esp
  801895:	53                   	push   %ebx
  801896:	68 00 50 80 00       	push   $0x805000
  80189b:	e8 96 ef ff ff       	call   800836 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018a3:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018a8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018ab:	b8 01 00 00 00       	mov    $0x1,%eax
  8018b0:	e8 cd fd ff ff       	call   801682 <fsipc>
  8018b5:	89 c3                	mov    %eax,%ebx
  8018b7:	83 c4 10             	add    $0x10,%esp
  8018ba:	85 c0                	test   %eax,%eax
  8018bc:	79 14                	jns    8018d2 <open+0x6f>
		fd_close(fd, 0);
  8018be:	83 ec 08             	sub    $0x8,%esp
  8018c1:	6a 00                	push   $0x0
  8018c3:	ff 75 f4             	pushl  -0xc(%ebp)
  8018c6:	e8 27 f9 ff ff       	call   8011f2 <fd_close>
		return r;
  8018cb:	83 c4 10             	add    $0x10,%esp
  8018ce:	89 da                	mov    %ebx,%edx
  8018d0:	eb 17                	jmp    8018e9 <open+0x86>
	}

	return fd2num(fd);
  8018d2:	83 ec 0c             	sub    $0xc,%esp
  8018d5:	ff 75 f4             	pushl  -0xc(%ebp)
  8018d8:	e8 f6 f7 ff ff       	call   8010d3 <fd2num>
  8018dd:	89 c2                	mov    %eax,%edx
  8018df:	83 c4 10             	add    $0x10,%esp
  8018e2:	eb 05                	jmp    8018e9 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8018e4:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8018e9:	89 d0                	mov    %edx,%eax
  8018eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018ee:	c9                   	leave  
  8018ef:	c3                   	ret    

008018f0 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8018f0:	55                   	push   %ebp
  8018f1:	89 e5                	mov    %esp,%ebp
  8018f3:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8018fb:	b8 08 00 00 00       	mov    $0x8,%eax
  801900:	e8 7d fd ff ff       	call   801682 <fsipc>
}
  801905:	c9                   	leave  
  801906:	c3                   	ret    

00801907 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801907:	55                   	push   %ebp
  801908:	89 e5                	mov    %esp,%ebp
  80190a:	57                   	push   %edi
  80190b:	56                   	push   %esi
  80190c:	53                   	push   %ebx
  80190d:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801913:	6a 00                	push   $0x0
  801915:	ff 75 08             	pushl  0x8(%ebp)
  801918:	e8 46 ff ff ff       	call   801863 <open>
  80191d:	89 c7                	mov    %eax,%edi
  80191f:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801925:	83 c4 10             	add    $0x10,%esp
  801928:	85 c0                	test   %eax,%eax
  80192a:	0f 88 ae 04 00 00    	js     801dde <spawn+0x4d7>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801930:	83 ec 04             	sub    $0x4,%esp
  801933:	68 00 02 00 00       	push   $0x200
  801938:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  80193e:	50                   	push   %eax
  80193f:	57                   	push   %edi
  801940:	e8 fb fa ff ff       	call   801440 <readn>
  801945:	83 c4 10             	add    $0x10,%esp
  801948:	3d 00 02 00 00       	cmp    $0x200,%eax
  80194d:	75 0c                	jne    80195b <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  80194f:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801956:	45 4c 46 
  801959:	74 33                	je     80198e <spawn+0x87>
		close(fd);
  80195b:	83 ec 0c             	sub    $0xc,%esp
  80195e:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801964:	e8 0a f9 ff ff       	call   801273 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801969:	83 c4 0c             	add    $0xc,%esp
  80196c:	68 7f 45 4c 46       	push   $0x464c457f
  801971:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801977:	68 63 2d 80 00       	push   $0x802d63
  80197c:	e8 30 e9 ff ff       	call   8002b1 <cprintf>
		return -E_NOT_EXEC;
  801981:	83 c4 10             	add    $0x10,%esp
  801984:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801989:	e9 b0 04 00 00       	jmp    801e3e <spawn+0x537>
  80198e:	b8 07 00 00 00       	mov    $0x7,%eax
  801993:	cd 30                	int    $0x30
  801995:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  80199b:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  8019a1:	85 c0                	test   %eax,%eax
  8019a3:	0f 88 3d 04 00 00    	js     801de6 <spawn+0x4df>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  8019a9:	89 c6                	mov    %eax,%esi
  8019ab:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  8019b1:	6b f6 7c             	imul   $0x7c,%esi,%esi
  8019b4:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  8019ba:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  8019c0:	b9 11 00 00 00       	mov    $0x11,%ecx
  8019c5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  8019c7:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  8019cd:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8019d3:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  8019d8:	be 00 00 00 00       	mov    $0x0,%esi
  8019dd:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8019e0:	eb 13                	jmp    8019f5 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  8019e2:	83 ec 0c             	sub    $0xc,%esp
  8019e5:	50                   	push   %eax
  8019e6:	e8 12 ee ff ff       	call   8007fd <strlen>
  8019eb:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8019ef:	83 c3 01             	add    $0x1,%ebx
  8019f2:	83 c4 10             	add    $0x10,%esp
  8019f5:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  8019fc:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  8019ff:	85 c0                	test   %eax,%eax
  801a01:	75 df                	jne    8019e2 <spawn+0xdb>
  801a03:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801a09:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801a0f:	bf 00 10 40 00       	mov    $0x401000,%edi
  801a14:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801a16:	89 fa                	mov    %edi,%edx
  801a18:	83 e2 fc             	and    $0xfffffffc,%edx
  801a1b:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801a22:	29 c2                	sub    %eax,%edx
  801a24:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801a2a:	8d 42 f8             	lea    -0x8(%edx),%eax
  801a2d:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801a32:	0f 86 be 03 00 00    	jbe    801df6 <spawn+0x4ef>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801a38:	83 ec 04             	sub    $0x4,%esp
  801a3b:	6a 07                	push   $0x7
  801a3d:	68 00 00 40 00       	push   $0x400000
  801a42:	6a 00                	push   $0x0
  801a44:	e8 f0 f1 ff ff       	call   800c39 <sys_page_alloc>
  801a49:	83 c4 10             	add    $0x10,%esp
  801a4c:	85 c0                	test   %eax,%eax
  801a4e:	0f 88 a9 03 00 00    	js     801dfd <spawn+0x4f6>
  801a54:	be 00 00 00 00       	mov    $0x0,%esi
  801a59:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801a5f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a62:	eb 30                	jmp    801a94 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801a64:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801a6a:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801a70:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801a73:	83 ec 08             	sub    $0x8,%esp
  801a76:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801a79:	57                   	push   %edi
  801a7a:	e8 b7 ed ff ff       	call   800836 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801a7f:	83 c4 04             	add    $0x4,%esp
  801a82:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801a85:	e8 73 ed ff ff       	call   8007fd <strlen>
  801a8a:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801a8e:	83 c6 01             	add    $0x1,%esi
  801a91:	83 c4 10             	add    $0x10,%esp
  801a94:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801a9a:	7f c8                	jg     801a64 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801a9c:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801aa2:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801aa8:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801aaf:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801ab5:	74 19                	je     801ad0 <spawn+0x1c9>
  801ab7:	68 c0 2d 80 00       	push   $0x802dc0
  801abc:	68 30 2d 80 00       	push   $0x802d30
  801ac1:	68 f2 00 00 00       	push   $0xf2
  801ac6:	68 7d 2d 80 00       	push   $0x802d7d
  801acb:	e8 08 e7 ff ff       	call   8001d8 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801ad0:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801ad6:	89 f8                	mov    %edi,%eax
  801ad8:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801add:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801ae0:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801ae6:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801ae9:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801aef:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801af5:	83 ec 0c             	sub    $0xc,%esp
  801af8:	6a 07                	push   $0x7
  801afa:	68 00 d0 bf ee       	push   $0xeebfd000
  801aff:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801b05:	68 00 00 40 00       	push   $0x400000
  801b0a:	6a 00                	push   $0x0
  801b0c:	e8 6b f1 ff ff       	call   800c7c <sys_page_map>
  801b11:	89 c3                	mov    %eax,%ebx
  801b13:	83 c4 20             	add    $0x20,%esp
  801b16:	85 c0                	test   %eax,%eax
  801b18:	0f 88 0e 03 00 00    	js     801e2c <spawn+0x525>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801b1e:	83 ec 08             	sub    $0x8,%esp
  801b21:	68 00 00 40 00       	push   $0x400000
  801b26:	6a 00                	push   $0x0
  801b28:	e8 91 f1 ff ff       	call   800cbe <sys_page_unmap>
  801b2d:	89 c3                	mov    %eax,%ebx
  801b2f:	83 c4 10             	add    $0x10,%esp
  801b32:	85 c0                	test   %eax,%eax
  801b34:	0f 88 f2 02 00 00    	js     801e2c <spawn+0x525>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801b3a:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801b40:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801b47:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801b4d:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801b54:	00 00 00 
  801b57:	e9 88 01 00 00       	jmp    801ce4 <spawn+0x3dd>
		if (ph->p_type != ELF_PROG_LOAD)
  801b5c:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801b62:	83 38 01             	cmpl   $0x1,(%eax)
  801b65:	0f 85 6b 01 00 00    	jne    801cd6 <spawn+0x3cf>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801b6b:	89 c7                	mov    %eax,%edi
  801b6d:	8b 40 18             	mov    0x18(%eax),%eax
  801b70:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801b76:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801b79:	83 f8 01             	cmp    $0x1,%eax
  801b7c:	19 c0                	sbb    %eax,%eax
  801b7e:	83 e0 fe             	and    $0xfffffffe,%eax
  801b81:	83 c0 07             	add    $0x7,%eax
  801b84:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801b8a:	89 f8                	mov    %edi,%eax
  801b8c:	8b 7f 04             	mov    0x4(%edi),%edi
  801b8f:	89 f9                	mov    %edi,%ecx
  801b91:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801b97:	8b 78 10             	mov    0x10(%eax),%edi
  801b9a:	8b 50 14             	mov    0x14(%eax),%edx
  801b9d:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  801ba3:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801ba6:	89 f0                	mov    %esi,%eax
  801ba8:	25 ff 0f 00 00       	and    $0xfff,%eax
  801bad:	74 14                	je     801bc3 <spawn+0x2bc>
		va -= i;
  801baf:	29 c6                	sub    %eax,%esi
		memsz += i;
  801bb1:	01 c2                	add    %eax,%edx
  801bb3:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  801bb9:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801bbb:	29 c1                	sub    %eax,%ecx
  801bbd:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801bc3:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bc8:	e9 f7 00 00 00       	jmp    801cc4 <spawn+0x3bd>
		if (i >= filesz) {
  801bcd:	39 df                	cmp    %ebx,%edi
  801bcf:	77 27                	ja     801bf8 <spawn+0x2f1>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801bd1:	83 ec 04             	sub    $0x4,%esp
  801bd4:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801bda:	56                   	push   %esi
  801bdb:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801be1:	e8 53 f0 ff ff       	call   800c39 <sys_page_alloc>
  801be6:	83 c4 10             	add    $0x10,%esp
  801be9:	85 c0                	test   %eax,%eax
  801beb:	0f 89 c7 00 00 00    	jns    801cb8 <spawn+0x3b1>
  801bf1:	89 c3                	mov    %eax,%ebx
  801bf3:	e9 13 02 00 00       	jmp    801e0b <spawn+0x504>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801bf8:	83 ec 04             	sub    $0x4,%esp
  801bfb:	6a 07                	push   $0x7
  801bfd:	68 00 00 40 00       	push   $0x400000
  801c02:	6a 00                	push   $0x0
  801c04:	e8 30 f0 ff ff       	call   800c39 <sys_page_alloc>
  801c09:	83 c4 10             	add    $0x10,%esp
  801c0c:	85 c0                	test   %eax,%eax
  801c0e:	0f 88 ed 01 00 00    	js     801e01 <spawn+0x4fa>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801c14:	83 ec 08             	sub    $0x8,%esp
  801c17:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801c1d:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801c23:	50                   	push   %eax
  801c24:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801c2a:	e8 e6 f8 ff ff       	call   801515 <seek>
  801c2f:	83 c4 10             	add    $0x10,%esp
  801c32:	85 c0                	test   %eax,%eax
  801c34:	0f 88 cb 01 00 00    	js     801e05 <spawn+0x4fe>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801c3a:	83 ec 04             	sub    $0x4,%esp
  801c3d:	89 f8                	mov    %edi,%eax
  801c3f:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801c45:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801c4a:	ba 00 10 00 00       	mov    $0x1000,%edx
  801c4f:	0f 47 c2             	cmova  %edx,%eax
  801c52:	50                   	push   %eax
  801c53:	68 00 00 40 00       	push   $0x400000
  801c58:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801c5e:	e8 dd f7 ff ff       	call   801440 <readn>
  801c63:	83 c4 10             	add    $0x10,%esp
  801c66:	85 c0                	test   %eax,%eax
  801c68:	0f 88 9b 01 00 00    	js     801e09 <spawn+0x502>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801c6e:	83 ec 0c             	sub    $0xc,%esp
  801c71:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801c77:	56                   	push   %esi
  801c78:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801c7e:	68 00 00 40 00       	push   $0x400000
  801c83:	6a 00                	push   $0x0
  801c85:	e8 f2 ef ff ff       	call   800c7c <sys_page_map>
  801c8a:	83 c4 20             	add    $0x20,%esp
  801c8d:	85 c0                	test   %eax,%eax
  801c8f:	79 15                	jns    801ca6 <spawn+0x39f>
				panic("spawn: sys_page_map data: %e", r);
  801c91:	50                   	push   %eax
  801c92:	68 89 2d 80 00       	push   $0x802d89
  801c97:	68 25 01 00 00       	push   $0x125
  801c9c:	68 7d 2d 80 00       	push   $0x802d7d
  801ca1:	e8 32 e5 ff ff       	call   8001d8 <_panic>
			sys_page_unmap(0, UTEMP);
  801ca6:	83 ec 08             	sub    $0x8,%esp
  801ca9:	68 00 00 40 00       	push   $0x400000
  801cae:	6a 00                	push   $0x0
  801cb0:	e8 09 f0 ff ff       	call   800cbe <sys_page_unmap>
  801cb5:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801cb8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801cbe:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801cc4:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801cca:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  801cd0:	0f 87 f7 fe ff ff    	ja     801bcd <spawn+0x2c6>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801cd6:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801cdd:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801ce4:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801ceb:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801cf1:	0f 8c 65 fe ff ff    	jl     801b5c <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801cf7:	83 ec 0c             	sub    $0xc,%esp
  801cfa:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801d00:	e8 6e f5 ff ff       	call   801273 <close>
  801d05:	83 c4 10             	add    $0x10,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	uintptr_t i;
	for (i = 0; i < USTACKTOP; i += PGSIZE){
  801d08:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d0d:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[PGNUM(i)] & PTE_P) && (uvpt[PGNUM(i)] & PTE_U) && (uvpt[PGNUM(i)] & PTE_SHARE)){
  801d13:	89 d8                	mov    %ebx,%eax
  801d15:	c1 e8 16             	shr    $0x16,%eax
  801d18:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801d1f:	a8 01                	test   $0x1,%al
  801d21:	74 46                	je     801d69 <spawn+0x462>
  801d23:	89 d8                	mov    %ebx,%eax
  801d25:	c1 e8 0c             	shr    $0xc,%eax
  801d28:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801d2f:	f6 c2 01             	test   $0x1,%dl
  801d32:	74 35                	je     801d69 <spawn+0x462>
  801d34:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801d3b:	f6 c2 04             	test   $0x4,%dl
  801d3e:	74 29                	je     801d69 <spawn+0x462>
  801d40:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801d47:	f6 c6 04             	test   $0x4,%dh
  801d4a:	74 1d                	je     801d69 <spawn+0x462>
			sys_page_map(0, (void*)i,child, (void*)i,(uvpt[PGNUM(i)] | PTE_SYSCALL));
  801d4c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801d53:	83 ec 0c             	sub    $0xc,%esp
  801d56:	0d 07 0e 00 00       	or     $0xe07,%eax
  801d5b:	50                   	push   %eax
  801d5c:	53                   	push   %ebx
  801d5d:	56                   	push   %esi
  801d5e:	53                   	push   %ebx
  801d5f:	6a 00                	push   $0x0
  801d61:	e8 16 ef ff ff       	call   800c7c <sys_page_map>
  801d66:	83 c4 20             	add    $0x20,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	uintptr_t i;
	for (i = 0; i < USTACKTOP; i += PGSIZE){
  801d69:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801d6f:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801d75:	75 9c                	jne    801d13 <spawn+0x40c>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801d77:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801d7e:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801d81:	83 ec 08             	sub    $0x8,%esp
  801d84:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801d8a:	50                   	push   %eax
  801d8b:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801d91:	e8 ac ef ff ff       	call   800d42 <sys_env_set_trapframe>
  801d96:	83 c4 10             	add    $0x10,%esp
  801d99:	85 c0                	test   %eax,%eax
  801d9b:	79 15                	jns    801db2 <spawn+0x4ab>
		panic("sys_env_set_trapframe: %e", r);
  801d9d:	50                   	push   %eax
  801d9e:	68 a6 2d 80 00       	push   $0x802da6
  801da3:	68 86 00 00 00       	push   $0x86
  801da8:	68 7d 2d 80 00       	push   $0x802d7d
  801dad:	e8 26 e4 ff ff       	call   8001d8 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801db2:	83 ec 08             	sub    $0x8,%esp
  801db5:	6a 02                	push   $0x2
  801db7:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801dbd:	e8 3e ef ff ff       	call   800d00 <sys_env_set_status>
  801dc2:	83 c4 10             	add    $0x10,%esp
  801dc5:	85 c0                	test   %eax,%eax
  801dc7:	79 25                	jns    801dee <spawn+0x4e7>
		panic("sys_env_set_status: %e", r);
  801dc9:	50                   	push   %eax
  801dca:	68 69 2c 80 00       	push   $0x802c69
  801dcf:	68 89 00 00 00       	push   $0x89
  801dd4:	68 7d 2d 80 00       	push   $0x802d7d
  801dd9:	e8 fa e3 ff ff       	call   8001d8 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801dde:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801de4:	eb 58                	jmp    801e3e <spawn+0x537>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801de6:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801dec:	eb 50                	jmp    801e3e <spawn+0x537>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801dee:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801df4:	eb 48                	jmp    801e3e <spawn+0x537>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801df6:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801dfb:	eb 41                	jmp    801e3e <spawn+0x537>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801dfd:	89 c3                	mov    %eax,%ebx
  801dff:	eb 3d                	jmp    801e3e <spawn+0x537>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801e01:	89 c3                	mov    %eax,%ebx
  801e03:	eb 06                	jmp    801e0b <spawn+0x504>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801e05:	89 c3                	mov    %eax,%ebx
  801e07:	eb 02                	jmp    801e0b <spawn+0x504>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801e09:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801e0b:	83 ec 0c             	sub    $0xc,%esp
  801e0e:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e14:	e8 a1 ed ff ff       	call   800bba <sys_env_destroy>
	close(fd);
  801e19:	83 c4 04             	add    $0x4,%esp
  801e1c:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801e22:	e8 4c f4 ff ff       	call   801273 <close>
	return r;
  801e27:	83 c4 10             	add    $0x10,%esp
  801e2a:	eb 12                	jmp    801e3e <spawn+0x537>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801e2c:	83 ec 08             	sub    $0x8,%esp
  801e2f:	68 00 00 40 00       	push   $0x400000
  801e34:	6a 00                	push   $0x0
  801e36:	e8 83 ee ff ff       	call   800cbe <sys_page_unmap>
  801e3b:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801e3e:	89 d8                	mov    %ebx,%eax
  801e40:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e43:	5b                   	pop    %ebx
  801e44:	5e                   	pop    %esi
  801e45:	5f                   	pop    %edi
  801e46:	5d                   	pop    %ebp
  801e47:	c3                   	ret    

00801e48 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801e48:	55                   	push   %ebp
  801e49:	89 e5                	mov    %esp,%ebp
  801e4b:	56                   	push   %esi
  801e4c:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801e4d:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801e50:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801e55:	eb 03                	jmp    801e5a <spawnl+0x12>
		argc++;
  801e57:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801e5a:	83 c2 04             	add    $0x4,%edx
  801e5d:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801e61:	75 f4                	jne    801e57 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801e63:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801e6a:	83 e2 f0             	and    $0xfffffff0,%edx
  801e6d:	29 d4                	sub    %edx,%esp
  801e6f:	8d 54 24 03          	lea    0x3(%esp),%edx
  801e73:	c1 ea 02             	shr    $0x2,%edx
  801e76:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801e7d:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801e7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e82:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801e89:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801e90:	00 
  801e91:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801e93:	b8 00 00 00 00       	mov    $0x0,%eax
  801e98:	eb 0a                	jmp    801ea4 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801e9a:	83 c0 01             	add    $0x1,%eax
  801e9d:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801ea1:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801ea4:	39 d0                	cmp    %edx,%eax
  801ea6:	75 f2                	jne    801e9a <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801ea8:	83 ec 08             	sub    $0x8,%esp
  801eab:	56                   	push   %esi
  801eac:	ff 75 08             	pushl  0x8(%ebp)
  801eaf:	e8 53 fa ff ff       	call   801907 <spawn>
}
  801eb4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801eb7:	5b                   	pop    %ebx
  801eb8:	5e                   	pop    %esi
  801eb9:	5d                   	pop    %ebp
  801eba:	c3                   	ret    

00801ebb <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801ebb:	55                   	push   %ebp
  801ebc:	89 e5                	mov    %esp,%ebp
  801ebe:	56                   	push   %esi
  801ebf:	53                   	push   %ebx
  801ec0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ec3:	83 ec 0c             	sub    $0xc,%esp
  801ec6:	ff 75 08             	pushl  0x8(%ebp)
  801ec9:	e8 15 f2 ff ff       	call   8010e3 <fd2data>
  801ece:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801ed0:	83 c4 08             	add    $0x8,%esp
  801ed3:	68 e8 2d 80 00       	push   $0x802de8
  801ed8:	53                   	push   %ebx
  801ed9:	e8 58 e9 ff ff       	call   800836 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ede:	8b 46 04             	mov    0x4(%esi),%eax
  801ee1:	2b 06                	sub    (%esi),%eax
  801ee3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ee9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ef0:	00 00 00 
	stat->st_dev = &devpipe;
  801ef3:	c7 83 88 00 00 00 28 	movl   $0x803028,0x88(%ebx)
  801efa:	30 80 00 
	return 0;
}
  801efd:	b8 00 00 00 00       	mov    $0x0,%eax
  801f02:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f05:	5b                   	pop    %ebx
  801f06:	5e                   	pop    %esi
  801f07:	5d                   	pop    %ebp
  801f08:	c3                   	ret    

00801f09 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801f09:	55                   	push   %ebp
  801f0a:	89 e5                	mov    %esp,%ebp
  801f0c:	53                   	push   %ebx
  801f0d:	83 ec 0c             	sub    $0xc,%esp
  801f10:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801f13:	53                   	push   %ebx
  801f14:	6a 00                	push   $0x0
  801f16:	e8 a3 ed ff ff       	call   800cbe <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801f1b:	89 1c 24             	mov    %ebx,(%esp)
  801f1e:	e8 c0 f1 ff ff       	call   8010e3 <fd2data>
  801f23:	83 c4 08             	add    $0x8,%esp
  801f26:	50                   	push   %eax
  801f27:	6a 00                	push   $0x0
  801f29:	e8 90 ed ff ff       	call   800cbe <sys_page_unmap>
}
  801f2e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f31:	c9                   	leave  
  801f32:	c3                   	ret    

00801f33 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801f33:	55                   	push   %ebp
  801f34:	89 e5                	mov    %esp,%ebp
  801f36:	57                   	push   %edi
  801f37:	56                   	push   %esi
  801f38:	53                   	push   %ebx
  801f39:	83 ec 1c             	sub    $0x1c,%esp
  801f3c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801f3f:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801f41:	a1 04 40 80 00       	mov    0x804004,%eax
  801f46:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801f49:	83 ec 0c             	sub    $0xc,%esp
  801f4c:	ff 75 e0             	pushl  -0x20(%ebp)
  801f4f:	e8 01 06 00 00       	call   802555 <pageref>
  801f54:	89 c3                	mov    %eax,%ebx
  801f56:	89 3c 24             	mov    %edi,(%esp)
  801f59:	e8 f7 05 00 00       	call   802555 <pageref>
  801f5e:	83 c4 10             	add    $0x10,%esp
  801f61:	39 c3                	cmp    %eax,%ebx
  801f63:	0f 94 c1             	sete   %cl
  801f66:	0f b6 c9             	movzbl %cl,%ecx
  801f69:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801f6c:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801f72:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801f75:	39 ce                	cmp    %ecx,%esi
  801f77:	74 1b                	je     801f94 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801f79:	39 c3                	cmp    %eax,%ebx
  801f7b:	75 c4                	jne    801f41 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801f7d:	8b 42 58             	mov    0x58(%edx),%eax
  801f80:	ff 75 e4             	pushl  -0x1c(%ebp)
  801f83:	50                   	push   %eax
  801f84:	56                   	push   %esi
  801f85:	68 ef 2d 80 00       	push   $0x802def
  801f8a:	e8 22 e3 ff ff       	call   8002b1 <cprintf>
  801f8f:	83 c4 10             	add    $0x10,%esp
  801f92:	eb ad                	jmp    801f41 <_pipeisclosed+0xe>
	}
}
  801f94:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f97:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f9a:	5b                   	pop    %ebx
  801f9b:	5e                   	pop    %esi
  801f9c:	5f                   	pop    %edi
  801f9d:	5d                   	pop    %ebp
  801f9e:	c3                   	ret    

00801f9f <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f9f:	55                   	push   %ebp
  801fa0:	89 e5                	mov    %esp,%ebp
  801fa2:	57                   	push   %edi
  801fa3:	56                   	push   %esi
  801fa4:	53                   	push   %ebx
  801fa5:	83 ec 28             	sub    $0x28,%esp
  801fa8:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801fab:	56                   	push   %esi
  801fac:	e8 32 f1 ff ff       	call   8010e3 <fd2data>
  801fb1:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fb3:	83 c4 10             	add    $0x10,%esp
  801fb6:	bf 00 00 00 00       	mov    $0x0,%edi
  801fbb:	eb 4b                	jmp    802008 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801fbd:	89 da                	mov    %ebx,%edx
  801fbf:	89 f0                	mov    %esi,%eax
  801fc1:	e8 6d ff ff ff       	call   801f33 <_pipeisclosed>
  801fc6:	85 c0                	test   %eax,%eax
  801fc8:	75 48                	jne    802012 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801fca:	e8 4b ec ff ff       	call   800c1a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801fcf:	8b 43 04             	mov    0x4(%ebx),%eax
  801fd2:	8b 0b                	mov    (%ebx),%ecx
  801fd4:	8d 51 20             	lea    0x20(%ecx),%edx
  801fd7:	39 d0                	cmp    %edx,%eax
  801fd9:	73 e2                	jae    801fbd <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801fdb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801fde:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801fe2:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801fe5:	89 c2                	mov    %eax,%edx
  801fe7:	c1 fa 1f             	sar    $0x1f,%edx
  801fea:	89 d1                	mov    %edx,%ecx
  801fec:	c1 e9 1b             	shr    $0x1b,%ecx
  801fef:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801ff2:	83 e2 1f             	and    $0x1f,%edx
  801ff5:	29 ca                	sub    %ecx,%edx
  801ff7:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801ffb:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801fff:	83 c0 01             	add    $0x1,%eax
  802002:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802005:	83 c7 01             	add    $0x1,%edi
  802008:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80200b:	75 c2                	jne    801fcf <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80200d:	8b 45 10             	mov    0x10(%ebp),%eax
  802010:	eb 05                	jmp    802017 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802012:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802017:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80201a:	5b                   	pop    %ebx
  80201b:	5e                   	pop    %esi
  80201c:	5f                   	pop    %edi
  80201d:	5d                   	pop    %ebp
  80201e:	c3                   	ret    

0080201f <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80201f:	55                   	push   %ebp
  802020:	89 e5                	mov    %esp,%ebp
  802022:	57                   	push   %edi
  802023:	56                   	push   %esi
  802024:	53                   	push   %ebx
  802025:	83 ec 18             	sub    $0x18,%esp
  802028:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80202b:	57                   	push   %edi
  80202c:	e8 b2 f0 ff ff       	call   8010e3 <fd2data>
  802031:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802033:	83 c4 10             	add    $0x10,%esp
  802036:	bb 00 00 00 00       	mov    $0x0,%ebx
  80203b:	eb 3d                	jmp    80207a <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80203d:	85 db                	test   %ebx,%ebx
  80203f:	74 04                	je     802045 <devpipe_read+0x26>
				return i;
  802041:	89 d8                	mov    %ebx,%eax
  802043:	eb 44                	jmp    802089 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802045:	89 f2                	mov    %esi,%edx
  802047:	89 f8                	mov    %edi,%eax
  802049:	e8 e5 fe ff ff       	call   801f33 <_pipeisclosed>
  80204e:	85 c0                	test   %eax,%eax
  802050:	75 32                	jne    802084 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802052:	e8 c3 eb ff ff       	call   800c1a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802057:	8b 06                	mov    (%esi),%eax
  802059:	3b 46 04             	cmp    0x4(%esi),%eax
  80205c:	74 df                	je     80203d <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80205e:	99                   	cltd   
  80205f:	c1 ea 1b             	shr    $0x1b,%edx
  802062:	01 d0                	add    %edx,%eax
  802064:	83 e0 1f             	and    $0x1f,%eax
  802067:	29 d0                	sub    %edx,%eax
  802069:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80206e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802071:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802074:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802077:	83 c3 01             	add    $0x1,%ebx
  80207a:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80207d:	75 d8                	jne    802057 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80207f:	8b 45 10             	mov    0x10(%ebp),%eax
  802082:	eb 05                	jmp    802089 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802084:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802089:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80208c:	5b                   	pop    %ebx
  80208d:	5e                   	pop    %esi
  80208e:	5f                   	pop    %edi
  80208f:	5d                   	pop    %ebp
  802090:	c3                   	ret    

00802091 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802091:	55                   	push   %ebp
  802092:	89 e5                	mov    %esp,%ebp
  802094:	56                   	push   %esi
  802095:	53                   	push   %ebx
  802096:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802099:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80209c:	50                   	push   %eax
  80209d:	e8 58 f0 ff ff       	call   8010fa <fd_alloc>
  8020a2:	83 c4 10             	add    $0x10,%esp
  8020a5:	89 c2                	mov    %eax,%edx
  8020a7:	85 c0                	test   %eax,%eax
  8020a9:	0f 88 2c 01 00 00    	js     8021db <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020af:	83 ec 04             	sub    $0x4,%esp
  8020b2:	68 07 04 00 00       	push   $0x407
  8020b7:	ff 75 f4             	pushl  -0xc(%ebp)
  8020ba:	6a 00                	push   $0x0
  8020bc:	e8 78 eb ff ff       	call   800c39 <sys_page_alloc>
  8020c1:	83 c4 10             	add    $0x10,%esp
  8020c4:	89 c2                	mov    %eax,%edx
  8020c6:	85 c0                	test   %eax,%eax
  8020c8:	0f 88 0d 01 00 00    	js     8021db <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8020ce:	83 ec 0c             	sub    $0xc,%esp
  8020d1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8020d4:	50                   	push   %eax
  8020d5:	e8 20 f0 ff ff       	call   8010fa <fd_alloc>
  8020da:	89 c3                	mov    %eax,%ebx
  8020dc:	83 c4 10             	add    $0x10,%esp
  8020df:	85 c0                	test   %eax,%eax
  8020e1:	0f 88 e2 00 00 00    	js     8021c9 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020e7:	83 ec 04             	sub    $0x4,%esp
  8020ea:	68 07 04 00 00       	push   $0x407
  8020ef:	ff 75 f0             	pushl  -0x10(%ebp)
  8020f2:	6a 00                	push   $0x0
  8020f4:	e8 40 eb ff ff       	call   800c39 <sys_page_alloc>
  8020f9:	89 c3                	mov    %eax,%ebx
  8020fb:	83 c4 10             	add    $0x10,%esp
  8020fe:	85 c0                	test   %eax,%eax
  802100:	0f 88 c3 00 00 00    	js     8021c9 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802106:	83 ec 0c             	sub    $0xc,%esp
  802109:	ff 75 f4             	pushl  -0xc(%ebp)
  80210c:	e8 d2 ef ff ff       	call   8010e3 <fd2data>
  802111:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802113:	83 c4 0c             	add    $0xc,%esp
  802116:	68 07 04 00 00       	push   $0x407
  80211b:	50                   	push   %eax
  80211c:	6a 00                	push   $0x0
  80211e:	e8 16 eb ff ff       	call   800c39 <sys_page_alloc>
  802123:	89 c3                	mov    %eax,%ebx
  802125:	83 c4 10             	add    $0x10,%esp
  802128:	85 c0                	test   %eax,%eax
  80212a:	0f 88 89 00 00 00    	js     8021b9 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802130:	83 ec 0c             	sub    $0xc,%esp
  802133:	ff 75 f0             	pushl  -0x10(%ebp)
  802136:	e8 a8 ef ff ff       	call   8010e3 <fd2data>
  80213b:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802142:	50                   	push   %eax
  802143:	6a 00                	push   $0x0
  802145:	56                   	push   %esi
  802146:	6a 00                	push   $0x0
  802148:	e8 2f eb ff ff       	call   800c7c <sys_page_map>
  80214d:	89 c3                	mov    %eax,%ebx
  80214f:	83 c4 20             	add    $0x20,%esp
  802152:	85 c0                	test   %eax,%eax
  802154:	78 55                	js     8021ab <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802156:	8b 15 28 30 80 00    	mov    0x803028,%edx
  80215c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80215f:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802161:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802164:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80216b:	8b 15 28 30 80 00    	mov    0x803028,%edx
  802171:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802174:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802176:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802179:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802180:	83 ec 0c             	sub    $0xc,%esp
  802183:	ff 75 f4             	pushl  -0xc(%ebp)
  802186:	e8 48 ef ff ff       	call   8010d3 <fd2num>
  80218b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80218e:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802190:	83 c4 04             	add    $0x4,%esp
  802193:	ff 75 f0             	pushl  -0x10(%ebp)
  802196:	e8 38 ef ff ff       	call   8010d3 <fd2num>
  80219b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80219e:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8021a1:	83 c4 10             	add    $0x10,%esp
  8021a4:	ba 00 00 00 00       	mov    $0x0,%edx
  8021a9:	eb 30                	jmp    8021db <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8021ab:	83 ec 08             	sub    $0x8,%esp
  8021ae:	56                   	push   %esi
  8021af:	6a 00                	push   $0x0
  8021b1:	e8 08 eb ff ff       	call   800cbe <sys_page_unmap>
  8021b6:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8021b9:	83 ec 08             	sub    $0x8,%esp
  8021bc:	ff 75 f0             	pushl  -0x10(%ebp)
  8021bf:	6a 00                	push   $0x0
  8021c1:	e8 f8 ea ff ff       	call   800cbe <sys_page_unmap>
  8021c6:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8021c9:	83 ec 08             	sub    $0x8,%esp
  8021cc:	ff 75 f4             	pushl  -0xc(%ebp)
  8021cf:	6a 00                	push   $0x0
  8021d1:	e8 e8 ea ff ff       	call   800cbe <sys_page_unmap>
  8021d6:	83 c4 10             	add    $0x10,%esp
  8021d9:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8021db:	89 d0                	mov    %edx,%eax
  8021dd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021e0:	5b                   	pop    %ebx
  8021e1:	5e                   	pop    %esi
  8021e2:	5d                   	pop    %ebp
  8021e3:	c3                   	ret    

008021e4 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8021e4:	55                   	push   %ebp
  8021e5:	89 e5                	mov    %esp,%ebp
  8021e7:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021ed:	50                   	push   %eax
  8021ee:	ff 75 08             	pushl  0x8(%ebp)
  8021f1:	e8 53 ef ff ff       	call   801149 <fd_lookup>
  8021f6:	83 c4 10             	add    $0x10,%esp
  8021f9:	85 c0                	test   %eax,%eax
  8021fb:	78 18                	js     802215 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8021fd:	83 ec 0c             	sub    $0xc,%esp
  802200:	ff 75 f4             	pushl  -0xc(%ebp)
  802203:	e8 db ee ff ff       	call   8010e3 <fd2data>
	return _pipeisclosed(fd, p);
  802208:	89 c2                	mov    %eax,%edx
  80220a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80220d:	e8 21 fd ff ff       	call   801f33 <_pipeisclosed>
  802212:	83 c4 10             	add    $0x10,%esp
}
  802215:	c9                   	leave  
  802216:	c3                   	ret    

00802217 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802217:	55                   	push   %ebp
  802218:	89 e5                	mov    %esp,%ebp
  80221a:	56                   	push   %esi
  80221b:	53                   	push   %ebx
  80221c:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  80221f:	85 f6                	test   %esi,%esi
  802221:	75 16                	jne    802239 <wait+0x22>
  802223:	68 07 2e 80 00       	push   $0x802e07
  802228:	68 30 2d 80 00       	push   $0x802d30
  80222d:	6a 09                	push   $0x9
  80222f:	68 12 2e 80 00       	push   $0x802e12
  802234:	e8 9f df ff ff       	call   8001d8 <_panic>
	e = &envs[ENVX(envid)];
  802239:	89 f3                	mov    %esi,%ebx
  80223b:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802241:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  802244:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  80224a:	eb 05                	jmp    802251 <wait+0x3a>
		sys_yield();
  80224c:	e8 c9 e9 ff ff       	call   800c1a <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802251:	8b 43 48             	mov    0x48(%ebx),%eax
  802254:	39 c6                	cmp    %eax,%esi
  802256:	75 07                	jne    80225f <wait+0x48>
  802258:	8b 43 54             	mov    0x54(%ebx),%eax
  80225b:	85 c0                	test   %eax,%eax
  80225d:	75 ed                	jne    80224c <wait+0x35>
		sys_yield();
}
  80225f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802262:	5b                   	pop    %ebx
  802263:	5e                   	pop    %esi
  802264:	5d                   	pop    %ebp
  802265:	c3                   	ret    

00802266 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802266:	55                   	push   %ebp
  802267:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802269:	b8 00 00 00 00       	mov    $0x0,%eax
  80226e:	5d                   	pop    %ebp
  80226f:	c3                   	ret    

00802270 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802270:	55                   	push   %ebp
  802271:	89 e5                	mov    %esp,%ebp
  802273:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802276:	68 1d 2e 80 00       	push   $0x802e1d
  80227b:	ff 75 0c             	pushl  0xc(%ebp)
  80227e:	e8 b3 e5 ff ff       	call   800836 <strcpy>
	return 0;
}
  802283:	b8 00 00 00 00       	mov    $0x0,%eax
  802288:	c9                   	leave  
  802289:	c3                   	ret    

0080228a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80228a:	55                   	push   %ebp
  80228b:	89 e5                	mov    %esp,%ebp
  80228d:	57                   	push   %edi
  80228e:	56                   	push   %esi
  80228f:	53                   	push   %ebx
  802290:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802296:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80229b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022a1:	eb 2d                	jmp    8022d0 <devcons_write+0x46>
		m = n - tot;
  8022a3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8022a6:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8022a8:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8022ab:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8022b0:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8022b3:	83 ec 04             	sub    $0x4,%esp
  8022b6:	53                   	push   %ebx
  8022b7:	03 45 0c             	add    0xc(%ebp),%eax
  8022ba:	50                   	push   %eax
  8022bb:	57                   	push   %edi
  8022bc:	e8 07 e7 ff ff       	call   8009c8 <memmove>
		sys_cputs(buf, m);
  8022c1:	83 c4 08             	add    $0x8,%esp
  8022c4:	53                   	push   %ebx
  8022c5:	57                   	push   %edi
  8022c6:	e8 b2 e8 ff ff       	call   800b7d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022cb:	01 de                	add    %ebx,%esi
  8022cd:	83 c4 10             	add    $0x10,%esp
  8022d0:	89 f0                	mov    %esi,%eax
  8022d2:	3b 75 10             	cmp    0x10(%ebp),%esi
  8022d5:	72 cc                	jb     8022a3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8022d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022da:	5b                   	pop    %ebx
  8022db:	5e                   	pop    %esi
  8022dc:	5f                   	pop    %edi
  8022dd:	5d                   	pop    %ebp
  8022de:	c3                   	ret    

008022df <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8022df:	55                   	push   %ebp
  8022e0:	89 e5                	mov    %esp,%ebp
  8022e2:	83 ec 08             	sub    $0x8,%esp
  8022e5:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8022ea:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8022ee:	74 2a                	je     80231a <devcons_read+0x3b>
  8022f0:	eb 05                	jmp    8022f7 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8022f2:	e8 23 e9 ff ff       	call   800c1a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8022f7:	e8 9f e8 ff ff       	call   800b9b <sys_cgetc>
  8022fc:	85 c0                	test   %eax,%eax
  8022fe:	74 f2                	je     8022f2 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802300:	85 c0                	test   %eax,%eax
  802302:	78 16                	js     80231a <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802304:	83 f8 04             	cmp    $0x4,%eax
  802307:	74 0c                	je     802315 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802309:	8b 55 0c             	mov    0xc(%ebp),%edx
  80230c:	88 02                	mov    %al,(%edx)
	return 1;
  80230e:	b8 01 00 00 00       	mov    $0x1,%eax
  802313:	eb 05                	jmp    80231a <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802315:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80231a:	c9                   	leave  
  80231b:	c3                   	ret    

0080231c <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80231c:	55                   	push   %ebp
  80231d:	89 e5                	mov    %esp,%ebp
  80231f:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802322:	8b 45 08             	mov    0x8(%ebp),%eax
  802325:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802328:	6a 01                	push   $0x1
  80232a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80232d:	50                   	push   %eax
  80232e:	e8 4a e8 ff ff       	call   800b7d <sys_cputs>
}
  802333:	83 c4 10             	add    $0x10,%esp
  802336:	c9                   	leave  
  802337:	c3                   	ret    

00802338 <getchar>:

int
getchar(void)
{
  802338:	55                   	push   %ebp
  802339:	89 e5                	mov    %esp,%ebp
  80233b:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80233e:	6a 01                	push   $0x1
  802340:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802343:	50                   	push   %eax
  802344:	6a 00                	push   $0x0
  802346:	e8 64 f0 ff ff       	call   8013af <read>
	if (r < 0)
  80234b:	83 c4 10             	add    $0x10,%esp
  80234e:	85 c0                	test   %eax,%eax
  802350:	78 0f                	js     802361 <getchar+0x29>
		return r;
	if (r < 1)
  802352:	85 c0                	test   %eax,%eax
  802354:	7e 06                	jle    80235c <getchar+0x24>
		return -E_EOF;
	return c;
  802356:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80235a:	eb 05                	jmp    802361 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80235c:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802361:	c9                   	leave  
  802362:	c3                   	ret    

00802363 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802363:	55                   	push   %ebp
  802364:	89 e5                	mov    %esp,%ebp
  802366:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802369:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80236c:	50                   	push   %eax
  80236d:	ff 75 08             	pushl  0x8(%ebp)
  802370:	e8 d4 ed ff ff       	call   801149 <fd_lookup>
  802375:	83 c4 10             	add    $0x10,%esp
  802378:	85 c0                	test   %eax,%eax
  80237a:	78 11                	js     80238d <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80237c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80237f:	8b 15 44 30 80 00    	mov    0x803044,%edx
  802385:	39 10                	cmp    %edx,(%eax)
  802387:	0f 94 c0             	sete   %al
  80238a:	0f b6 c0             	movzbl %al,%eax
}
  80238d:	c9                   	leave  
  80238e:	c3                   	ret    

0080238f <opencons>:

int
opencons(void)
{
  80238f:	55                   	push   %ebp
  802390:	89 e5                	mov    %esp,%ebp
  802392:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802395:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802398:	50                   	push   %eax
  802399:	e8 5c ed ff ff       	call   8010fa <fd_alloc>
  80239e:	83 c4 10             	add    $0x10,%esp
		return r;
  8023a1:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8023a3:	85 c0                	test   %eax,%eax
  8023a5:	78 3e                	js     8023e5 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8023a7:	83 ec 04             	sub    $0x4,%esp
  8023aa:	68 07 04 00 00       	push   $0x407
  8023af:	ff 75 f4             	pushl  -0xc(%ebp)
  8023b2:	6a 00                	push   $0x0
  8023b4:	e8 80 e8 ff ff       	call   800c39 <sys_page_alloc>
  8023b9:	83 c4 10             	add    $0x10,%esp
		return r;
  8023bc:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8023be:	85 c0                	test   %eax,%eax
  8023c0:	78 23                	js     8023e5 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8023c2:	8b 15 44 30 80 00    	mov    0x803044,%edx
  8023c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023cb:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8023cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023d0:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8023d7:	83 ec 0c             	sub    $0xc,%esp
  8023da:	50                   	push   %eax
  8023db:	e8 f3 ec ff ff       	call   8010d3 <fd2num>
  8023e0:	89 c2                	mov    %eax,%edx
  8023e2:	83 c4 10             	add    $0x10,%esp
}
  8023e5:	89 d0                	mov    %edx,%eax
  8023e7:	c9                   	leave  
  8023e8:	c3                   	ret    

008023e9 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8023e9:	55                   	push   %ebp
  8023ea:	89 e5                	mov    %esp,%ebp
  8023ec:	53                   	push   %ebx
  8023ed:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  8023f0:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8023f7:	75 28                	jne    802421 <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  8023f9:	e8 fd e7 ff ff       	call   800bfb <sys_getenvid>
  8023fe:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_U | PTE_W);
  802400:	83 ec 04             	sub    $0x4,%esp
  802403:	6a 06                	push   $0x6
  802405:	68 00 f0 bf ee       	push   $0xeebff000
  80240a:	50                   	push   %eax
  80240b:	e8 29 e8 ff ff       	call   800c39 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  802410:	83 c4 08             	add    $0x8,%esp
  802413:	68 2e 24 80 00       	push   $0x80242e
  802418:	53                   	push   %ebx
  802419:	e8 66 e9 ff ff       	call   800d84 <sys_env_set_pgfault_upcall>
  80241e:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802421:	8b 45 08             	mov    0x8(%ebp),%eax
  802424:	a3 00 60 80 00       	mov    %eax,0x806000
}
  802429:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80242c:	c9                   	leave  
  80242d:	c3                   	ret    

0080242e <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80242e:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80242f:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802434:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802436:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	# My method is different. Copy the values to the other stack
	# in a convinient way, and then pop everything.
	movl %esp, %ebp		# ebp refers to the exception stack
  802439:	89 e5                	mov    %esp,%ebp
	movl 48(%ebp), %esp 	# go to other stack
  80243b:	8b 65 30             	mov    0x30(%ebp),%esp

	pushl 40(%ebp)		# eip - ORDER SWITCHED WITH EFLAGS
  80243e:	ff 75 28             	pushl  0x28(%ebp)
	pushl 44(%ebp)      	# eflags
  802441:	ff 75 2c             	pushl  0x2c(%ebp)
	pushl 36(%ebp)		# all the 8 remaining regs
  802444:	ff 75 24             	pushl  0x24(%ebp)
	pushl 32(%ebp)
  802447:	ff 75 20             	pushl  0x20(%ebp)
	pushl 28(%ebp)
  80244a:	ff 75 1c             	pushl  0x1c(%ebp)
	pushl 24(%ebp)
  80244d:	ff 75 18             	pushl  0x18(%ebp)
	pushl 20(%ebp)
  802450:	ff 75 14             	pushl  0x14(%ebp)
	pushl 16(%ebp)
  802453:	ff 75 10             	pushl  0x10(%ebp)
	pushl 12(%ebp)
  802456:	ff 75 0c             	pushl  0xc(%ebp)
	pushl 8(%ebp)
  802459:	ff 75 08             	pushl  0x8(%ebp)

	popal			# now just pop everything!
  80245c:	61                   	popa   
	popfl
  80245d:	9d                   	popf   
	ret
  80245e:	c3                   	ret    

0080245f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80245f:	55                   	push   %ebp
  802460:	89 e5                	mov    %esp,%ebp
  802462:	56                   	push   %esi
  802463:	53                   	push   %ebx
  802464:	8b 75 08             	mov    0x8(%ebp),%esi
  802467:	8b 45 0c             	mov    0xc(%ebp),%eax
  80246a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  80246d:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  80246f:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  802474:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  802477:	83 ec 0c             	sub    $0xc,%esp
  80247a:	50                   	push   %eax
  80247b:	e8 69 e9 ff ff       	call   800de9 <sys_ipc_recv>

	if (r < 0) {
  802480:	83 c4 10             	add    $0x10,%esp
  802483:	85 c0                	test   %eax,%eax
  802485:	79 16                	jns    80249d <ipc_recv+0x3e>
		if (from_env_store)
  802487:	85 f6                	test   %esi,%esi
  802489:	74 06                	je     802491 <ipc_recv+0x32>
			*from_env_store = 0;
  80248b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  802491:	85 db                	test   %ebx,%ebx
  802493:	74 2c                	je     8024c1 <ipc_recv+0x62>
			*perm_store = 0;
  802495:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80249b:	eb 24                	jmp    8024c1 <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  80249d:	85 f6                	test   %esi,%esi
  80249f:	74 0a                	je     8024ab <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  8024a1:	a1 04 40 80 00       	mov    0x804004,%eax
  8024a6:	8b 40 74             	mov    0x74(%eax),%eax
  8024a9:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  8024ab:	85 db                	test   %ebx,%ebx
  8024ad:	74 0a                	je     8024b9 <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  8024af:	a1 04 40 80 00       	mov    0x804004,%eax
  8024b4:	8b 40 78             	mov    0x78(%eax),%eax
  8024b7:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  8024b9:	a1 04 40 80 00       	mov    0x804004,%eax
  8024be:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  8024c1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8024c4:	5b                   	pop    %ebx
  8024c5:	5e                   	pop    %esi
  8024c6:	5d                   	pop    %ebp
  8024c7:	c3                   	ret    

008024c8 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8024c8:	55                   	push   %ebp
  8024c9:	89 e5                	mov    %esp,%ebp
  8024cb:	57                   	push   %edi
  8024cc:	56                   	push   %esi
  8024cd:	53                   	push   %ebx
  8024ce:	83 ec 0c             	sub    $0xc,%esp
  8024d1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8024d4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8024d7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  8024da:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  8024dc:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  8024e1:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  8024e4:	ff 75 14             	pushl  0x14(%ebp)
  8024e7:	53                   	push   %ebx
  8024e8:	56                   	push   %esi
  8024e9:	57                   	push   %edi
  8024ea:	e8 d7 e8 ff ff       	call   800dc6 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  8024ef:	83 c4 10             	add    $0x10,%esp
  8024f2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8024f5:	75 07                	jne    8024fe <ipc_send+0x36>
			sys_yield();
  8024f7:	e8 1e e7 ff ff       	call   800c1a <sys_yield>
  8024fc:	eb e6                	jmp    8024e4 <ipc_send+0x1c>
		} else if (r < 0) {
  8024fe:	85 c0                	test   %eax,%eax
  802500:	79 12                	jns    802514 <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  802502:	50                   	push   %eax
  802503:	68 29 2e 80 00       	push   $0x802e29
  802508:	6a 51                	push   $0x51
  80250a:	68 36 2e 80 00       	push   $0x802e36
  80250f:	e8 c4 dc ff ff       	call   8001d8 <_panic>
		}
	}
}
  802514:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802517:	5b                   	pop    %ebx
  802518:	5e                   	pop    %esi
  802519:	5f                   	pop    %edi
  80251a:	5d                   	pop    %ebp
  80251b:	c3                   	ret    

0080251c <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80251c:	55                   	push   %ebp
  80251d:	89 e5                	mov    %esp,%ebp
  80251f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802522:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802527:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80252a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802530:	8b 52 50             	mov    0x50(%edx),%edx
  802533:	39 ca                	cmp    %ecx,%edx
  802535:	75 0d                	jne    802544 <ipc_find_env+0x28>
			return envs[i].env_id;
  802537:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80253a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80253f:	8b 40 48             	mov    0x48(%eax),%eax
  802542:	eb 0f                	jmp    802553 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802544:	83 c0 01             	add    $0x1,%eax
  802547:	3d 00 04 00 00       	cmp    $0x400,%eax
  80254c:	75 d9                	jne    802527 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80254e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802553:	5d                   	pop    %ebp
  802554:	c3                   	ret    

00802555 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802555:	55                   	push   %ebp
  802556:	89 e5                	mov    %esp,%ebp
  802558:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80255b:	89 d0                	mov    %edx,%eax
  80255d:	c1 e8 16             	shr    $0x16,%eax
  802560:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802567:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80256c:	f6 c1 01             	test   $0x1,%cl
  80256f:	74 1d                	je     80258e <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802571:	c1 ea 0c             	shr    $0xc,%edx
  802574:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80257b:	f6 c2 01             	test   $0x1,%dl
  80257e:	74 0e                	je     80258e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802580:	c1 ea 0c             	shr    $0xc,%edx
  802583:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80258a:	ef 
  80258b:	0f b7 c0             	movzwl %ax,%eax
}
  80258e:	5d                   	pop    %ebp
  80258f:	c3                   	ret    

00802590 <__udivdi3>:
  802590:	55                   	push   %ebp
  802591:	57                   	push   %edi
  802592:	56                   	push   %esi
  802593:	53                   	push   %ebx
  802594:	83 ec 1c             	sub    $0x1c,%esp
  802597:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80259b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80259f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8025a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8025a7:	85 f6                	test   %esi,%esi
  8025a9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8025ad:	89 ca                	mov    %ecx,%edx
  8025af:	89 f8                	mov    %edi,%eax
  8025b1:	75 3d                	jne    8025f0 <__udivdi3+0x60>
  8025b3:	39 cf                	cmp    %ecx,%edi
  8025b5:	0f 87 c5 00 00 00    	ja     802680 <__udivdi3+0xf0>
  8025bb:	85 ff                	test   %edi,%edi
  8025bd:	89 fd                	mov    %edi,%ebp
  8025bf:	75 0b                	jne    8025cc <__udivdi3+0x3c>
  8025c1:	b8 01 00 00 00       	mov    $0x1,%eax
  8025c6:	31 d2                	xor    %edx,%edx
  8025c8:	f7 f7                	div    %edi
  8025ca:	89 c5                	mov    %eax,%ebp
  8025cc:	89 c8                	mov    %ecx,%eax
  8025ce:	31 d2                	xor    %edx,%edx
  8025d0:	f7 f5                	div    %ebp
  8025d2:	89 c1                	mov    %eax,%ecx
  8025d4:	89 d8                	mov    %ebx,%eax
  8025d6:	89 cf                	mov    %ecx,%edi
  8025d8:	f7 f5                	div    %ebp
  8025da:	89 c3                	mov    %eax,%ebx
  8025dc:	89 d8                	mov    %ebx,%eax
  8025de:	89 fa                	mov    %edi,%edx
  8025e0:	83 c4 1c             	add    $0x1c,%esp
  8025e3:	5b                   	pop    %ebx
  8025e4:	5e                   	pop    %esi
  8025e5:	5f                   	pop    %edi
  8025e6:	5d                   	pop    %ebp
  8025e7:	c3                   	ret    
  8025e8:	90                   	nop
  8025e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025f0:	39 ce                	cmp    %ecx,%esi
  8025f2:	77 74                	ja     802668 <__udivdi3+0xd8>
  8025f4:	0f bd fe             	bsr    %esi,%edi
  8025f7:	83 f7 1f             	xor    $0x1f,%edi
  8025fa:	0f 84 98 00 00 00    	je     802698 <__udivdi3+0x108>
  802600:	bb 20 00 00 00       	mov    $0x20,%ebx
  802605:	89 f9                	mov    %edi,%ecx
  802607:	89 c5                	mov    %eax,%ebp
  802609:	29 fb                	sub    %edi,%ebx
  80260b:	d3 e6                	shl    %cl,%esi
  80260d:	89 d9                	mov    %ebx,%ecx
  80260f:	d3 ed                	shr    %cl,%ebp
  802611:	89 f9                	mov    %edi,%ecx
  802613:	d3 e0                	shl    %cl,%eax
  802615:	09 ee                	or     %ebp,%esi
  802617:	89 d9                	mov    %ebx,%ecx
  802619:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80261d:	89 d5                	mov    %edx,%ebp
  80261f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802623:	d3 ed                	shr    %cl,%ebp
  802625:	89 f9                	mov    %edi,%ecx
  802627:	d3 e2                	shl    %cl,%edx
  802629:	89 d9                	mov    %ebx,%ecx
  80262b:	d3 e8                	shr    %cl,%eax
  80262d:	09 c2                	or     %eax,%edx
  80262f:	89 d0                	mov    %edx,%eax
  802631:	89 ea                	mov    %ebp,%edx
  802633:	f7 f6                	div    %esi
  802635:	89 d5                	mov    %edx,%ebp
  802637:	89 c3                	mov    %eax,%ebx
  802639:	f7 64 24 0c          	mull   0xc(%esp)
  80263d:	39 d5                	cmp    %edx,%ebp
  80263f:	72 10                	jb     802651 <__udivdi3+0xc1>
  802641:	8b 74 24 08          	mov    0x8(%esp),%esi
  802645:	89 f9                	mov    %edi,%ecx
  802647:	d3 e6                	shl    %cl,%esi
  802649:	39 c6                	cmp    %eax,%esi
  80264b:	73 07                	jae    802654 <__udivdi3+0xc4>
  80264d:	39 d5                	cmp    %edx,%ebp
  80264f:	75 03                	jne    802654 <__udivdi3+0xc4>
  802651:	83 eb 01             	sub    $0x1,%ebx
  802654:	31 ff                	xor    %edi,%edi
  802656:	89 d8                	mov    %ebx,%eax
  802658:	89 fa                	mov    %edi,%edx
  80265a:	83 c4 1c             	add    $0x1c,%esp
  80265d:	5b                   	pop    %ebx
  80265e:	5e                   	pop    %esi
  80265f:	5f                   	pop    %edi
  802660:	5d                   	pop    %ebp
  802661:	c3                   	ret    
  802662:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802668:	31 ff                	xor    %edi,%edi
  80266a:	31 db                	xor    %ebx,%ebx
  80266c:	89 d8                	mov    %ebx,%eax
  80266e:	89 fa                	mov    %edi,%edx
  802670:	83 c4 1c             	add    $0x1c,%esp
  802673:	5b                   	pop    %ebx
  802674:	5e                   	pop    %esi
  802675:	5f                   	pop    %edi
  802676:	5d                   	pop    %ebp
  802677:	c3                   	ret    
  802678:	90                   	nop
  802679:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802680:	89 d8                	mov    %ebx,%eax
  802682:	f7 f7                	div    %edi
  802684:	31 ff                	xor    %edi,%edi
  802686:	89 c3                	mov    %eax,%ebx
  802688:	89 d8                	mov    %ebx,%eax
  80268a:	89 fa                	mov    %edi,%edx
  80268c:	83 c4 1c             	add    $0x1c,%esp
  80268f:	5b                   	pop    %ebx
  802690:	5e                   	pop    %esi
  802691:	5f                   	pop    %edi
  802692:	5d                   	pop    %ebp
  802693:	c3                   	ret    
  802694:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802698:	39 ce                	cmp    %ecx,%esi
  80269a:	72 0c                	jb     8026a8 <__udivdi3+0x118>
  80269c:	31 db                	xor    %ebx,%ebx
  80269e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8026a2:	0f 87 34 ff ff ff    	ja     8025dc <__udivdi3+0x4c>
  8026a8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8026ad:	e9 2a ff ff ff       	jmp    8025dc <__udivdi3+0x4c>
  8026b2:	66 90                	xchg   %ax,%ax
  8026b4:	66 90                	xchg   %ax,%ax
  8026b6:	66 90                	xchg   %ax,%ax
  8026b8:	66 90                	xchg   %ax,%ax
  8026ba:	66 90                	xchg   %ax,%ax
  8026bc:	66 90                	xchg   %ax,%ax
  8026be:	66 90                	xchg   %ax,%ax

008026c0 <__umoddi3>:
  8026c0:	55                   	push   %ebp
  8026c1:	57                   	push   %edi
  8026c2:	56                   	push   %esi
  8026c3:	53                   	push   %ebx
  8026c4:	83 ec 1c             	sub    $0x1c,%esp
  8026c7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8026cb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8026cf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8026d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8026d7:	85 d2                	test   %edx,%edx
  8026d9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8026dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8026e1:	89 f3                	mov    %esi,%ebx
  8026e3:	89 3c 24             	mov    %edi,(%esp)
  8026e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8026ea:	75 1c                	jne    802708 <__umoddi3+0x48>
  8026ec:	39 f7                	cmp    %esi,%edi
  8026ee:	76 50                	jbe    802740 <__umoddi3+0x80>
  8026f0:	89 c8                	mov    %ecx,%eax
  8026f2:	89 f2                	mov    %esi,%edx
  8026f4:	f7 f7                	div    %edi
  8026f6:	89 d0                	mov    %edx,%eax
  8026f8:	31 d2                	xor    %edx,%edx
  8026fa:	83 c4 1c             	add    $0x1c,%esp
  8026fd:	5b                   	pop    %ebx
  8026fe:	5e                   	pop    %esi
  8026ff:	5f                   	pop    %edi
  802700:	5d                   	pop    %ebp
  802701:	c3                   	ret    
  802702:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802708:	39 f2                	cmp    %esi,%edx
  80270a:	89 d0                	mov    %edx,%eax
  80270c:	77 52                	ja     802760 <__umoddi3+0xa0>
  80270e:	0f bd ea             	bsr    %edx,%ebp
  802711:	83 f5 1f             	xor    $0x1f,%ebp
  802714:	75 5a                	jne    802770 <__umoddi3+0xb0>
  802716:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80271a:	0f 82 e0 00 00 00    	jb     802800 <__umoddi3+0x140>
  802720:	39 0c 24             	cmp    %ecx,(%esp)
  802723:	0f 86 d7 00 00 00    	jbe    802800 <__umoddi3+0x140>
  802729:	8b 44 24 08          	mov    0x8(%esp),%eax
  80272d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802731:	83 c4 1c             	add    $0x1c,%esp
  802734:	5b                   	pop    %ebx
  802735:	5e                   	pop    %esi
  802736:	5f                   	pop    %edi
  802737:	5d                   	pop    %ebp
  802738:	c3                   	ret    
  802739:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802740:	85 ff                	test   %edi,%edi
  802742:	89 fd                	mov    %edi,%ebp
  802744:	75 0b                	jne    802751 <__umoddi3+0x91>
  802746:	b8 01 00 00 00       	mov    $0x1,%eax
  80274b:	31 d2                	xor    %edx,%edx
  80274d:	f7 f7                	div    %edi
  80274f:	89 c5                	mov    %eax,%ebp
  802751:	89 f0                	mov    %esi,%eax
  802753:	31 d2                	xor    %edx,%edx
  802755:	f7 f5                	div    %ebp
  802757:	89 c8                	mov    %ecx,%eax
  802759:	f7 f5                	div    %ebp
  80275b:	89 d0                	mov    %edx,%eax
  80275d:	eb 99                	jmp    8026f8 <__umoddi3+0x38>
  80275f:	90                   	nop
  802760:	89 c8                	mov    %ecx,%eax
  802762:	89 f2                	mov    %esi,%edx
  802764:	83 c4 1c             	add    $0x1c,%esp
  802767:	5b                   	pop    %ebx
  802768:	5e                   	pop    %esi
  802769:	5f                   	pop    %edi
  80276a:	5d                   	pop    %ebp
  80276b:	c3                   	ret    
  80276c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802770:	8b 34 24             	mov    (%esp),%esi
  802773:	bf 20 00 00 00       	mov    $0x20,%edi
  802778:	89 e9                	mov    %ebp,%ecx
  80277a:	29 ef                	sub    %ebp,%edi
  80277c:	d3 e0                	shl    %cl,%eax
  80277e:	89 f9                	mov    %edi,%ecx
  802780:	89 f2                	mov    %esi,%edx
  802782:	d3 ea                	shr    %cl,%edx
  802784:	89 e9                	mov    %ebp,%ecx
  802786:	09 c2                	or     %eax,%edx
  802788:	89 d8                	mov    %ebx,%eax
  80278a:	89 14 24             	mov    %edx,(%esp)
  80278d:	89 f2                	mov    %esi,%edx
  80278f:	d3 e2                	shl    %cl,%edx
  802791:	89 f9                	mov    %edi,%ecx
  802793:	89 54 24 04          	mov    %edx,0x4(%esp)
  802797:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80279b:	d3 e8                	shr    %cl,%eax
  80279d:	89 e9                	mov    %ebp,%ecx
  80279f:	89 c6                	mov    %eax,%esi
  8027a1:	d3 e3                	shl    %cl,%ebx
  8027a3:	89 f9                	mov    %edi,%ecx
  8027a5:	89 d0                	mov    %edx,%eax
  8027a7:	d3 e8                	shr    %cl,%eax
  8027a9:	89 e9                	mov    %ebp,%ecx
  8027ab:	09 d8                	or     %ebx,%eax
  8027ad:	89 d3                	mov    %edx,%ebx
  8027af:	89 f2                	mov    %esi,%edx
  8027b1:	f7 34 24             	divl   (%esp)
  8027b4:	89 d6                	mov    %edx,%esi
  8027b6:	d3 e3                	shl    %cl,%ebx
  8027b8:	f7 64 24 04          	mull   0x4(%esp)
  8027bc:	39 d6                	cmp    %edx,%esi
  8027be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8027c2:	89 d1                	mov    %edx,%ecx
  8027c4:	89 c3                	mov    %eax,%ebx
  8027c6:	72 08                	jb     8027d0 <__umoddi3+0x110>
  8027c8:	75 11                	jne    8027db <__umoddi3+0x11b>
  8027ca:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8027ce:	73 0b                	jae    8027db <__umoddi3+0x11b>
  8027d0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8027d4:	1b 14 24             	sbb    (%esp),%edx
  8027d7:	89 d1                	mov    %edx,%ecx
  8027d9:	89 c3                	mov    %eax,%ebx
  8027db:	8b 54 24 08          	mov    0x8(%esp),%edx
  8027df:	29 da                	sub    %ebx,%edx
  8027e1:	19 ce                	sbb    %ecx,%esi
  8027e3:	89 f9                	mov    %edi,%ecx
  8027e5:	89 f0                	mov    %esi,%eax
  8027e7:	d3 e0                	shl    %cl,%eax
  8027e9:	89 e9                	mov    %ebp,%ecx
  8027eb:	d3 ea                	shr    %cl,%edx
  8027ed:	89 e9                	mov    %ebp,%ecx
  8027ef:	d3 ee                	shr    %cl,%esi
  8027f1:	09 d0                	or     %edx,%eax
  8027f3:	89 f2                	mov    %esi,%edx
  8027f5:	83 c4 1c             	add    $0x1c,%esp
  8027f8:	5b                   	pop    %ebx
  8027f9:	5e                   	pop    %esi
  8027fa:	5f                   	pop    %edi
  8027fb:	5d                   	pop    %ebp
  8027fc:	c3                   	ret    
  8027fd:	8d 76 00             	lea    0x0(%esi),%esi
  802800:	29 f9                	sub    %edi,%ecx
  802802:	19 d6                	sbb    %edx,%esi
  802804:	89 74 24 04          	mov    %esi,0x4(%esp)
  802808:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80280c:	e9 18 ff ff ff       	jmp    802729 <__umoddi3+0x69>
