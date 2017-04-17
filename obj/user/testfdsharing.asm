
obj/user/testfdsharing.debug:     file format elf32-i386


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
  80002c:	e8 87 01 00 00       	call   8001b8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

char buf[512], buf2[512];

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 14             	sub    $0x14,%esp
	int fd, r, n, n2;

	if ((fd = open("motd", O_RDONLY)) < 0)
  80003c:	6a 00                	push   $0x0
  80003e:	68 40 27 80 00       	push   $0x802740
  800043:	e8 7a 18 00 00       	call   8018c2 <open>
  800048:	89 c3                	mov    %eax,%ebx
  80004a:	83 c4 10             	add    $0x10,%esp
  80004d:	85 c0                	test   %eax,%eax
  80004f:	79 12                	jns    800063 <umain+0x30>
		panic("open motd: %e", fd);
  800051:	50                   	push   %eax
  800052:	68 45 27 80 00       	push   $0x802745
  800057:	6a 0c                	push   $0xc
  800059:	68 53 27 80 00       	push   $0x802753
  80005e:	e8 b5 01 00 00       	call   800218 <_panic>
	seek(fd, 0);
  800063:	83 ec 08             	sub    $0x8,%esp
  800066:	6a 00                	push   $0x0
  800068:	50                   	push   %eax
  800069:	e8 06 15 00 00       	call   801574 <seek>
	if ((n = readn(fd, buf, sizeof buf)) <= 0)
  80006e:	83 c4 0c             	add    $0xc,%esp
  800071:	68 00 02 00 00       	push   $0x200
  800076:	68 20 42 80 00       	push   $0x804220
  80007b:	53                   	push   %ebx
  80007c:	e8 1e 14 00 00       	call   80149f <readn>
  800081:	89 c6                	mov    %eax,%esi
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	85 c0                	test   %eax,%eax
  800088:	7f 12                	jg     80009c <umain+0x69>
		panic("readn: %e", n);
  80008a:	50                   	push   %eax
  80008b:	68 68 27 80 00       	push   $0x802768
  800090:	6a 0f                	push   $0xf
  800092:	68 53 27 80 00       	push   $0x802753
  800097:	e8 7c 01 00 00       	call   800218 <_panic>

	if ((r = fork()) < 0)
  80009c:	e8 9c 0f 00 00       	call   80103d <fork>
  8000a1:	89 c7                	mov    %eax,%edi
  8000a3:	85 c0                	test   %eax,%eax
  8000a5:	79 12                	jns    8000b9 <umain+0x86>
		panic("fork: %e", r);
  8000a7:	50                   	push   %eax
  8000a8:	68 13 2c 80 00       	push   $0x802c13
  8000ad:	6a 12                	push   $0x12
  8000af:	68 53 27 80 00       	push   $0x802753
  8000b4:	e8 5f 01 00 00       	call   800218 <_panic>
	if (r == 0) {
  8000b9:	85 c0                	test   %eax,%eax
  8000bb:	0f 85 9d 00 00 00    	jne    80015e <umain+0x12b>
		seek(fd, 0);
  8000c1:	83 ec 08             	sub    $0x8,%esp
  8000c4:	6a 00                	push   $0x0
  8000c6:	53                   	push   %ebx
  8000c7:	e8 a8 14 00 00       	call   801574 <seek>
		cprintf("going to read in child (might page fault if your sharing is buggy)\n");
  8000cc:	c7 04 24 a8 27 80 00 	movl   $0x8027a8,(%esp)
  8000d3:	e8 19 02 00 00       	call   8002f1 <cprintf>
		if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  8000d8:	83 c4 0c             	add    $0xc,%esp
  8000db:	68 00 02 00 00       	push   $0x200
  8000e0:	68 20 40 80 00       	push   $0x804020
  8000e5:	53                   	push   %ebx
  8000e6:	e8 b4 13 00 00       	call   80149f <readn>
  8000eb:	83 c4 10             	add    $0x10,%esp
  8000ee:	39 c6                	cmp    %eax,%esi
  8000f0:	74 16                	je     800108 <umain+0xd5>
			panic("read in parent got %d, read in child got %d", n, n2);
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	50                   	push   %eax
  8000f6:	56                   	push   %esi
  8000f7:	68 ec 27 80 00       	push   $0x8027ec
  8000fc:	6a 17                	push   $0x17
  8000fe:	68 53 27 80 00       	push   $0x802753
  800103:	e8 10 01 00 00       	call   800218 <_panic>
		if (memcmp(buf, buf2, n) != 0)
  800108:	83 ec 04             	sub    $0x4,%esp
  80010b:	56                   	push   %esi
  80010c:	68 20 40 80 00       	push   $0x804020
  800111:	68 20 42 80 00       	push   $0x804220
  800116:	e8 68 09 00 00       	call   800a83 <memcmp>
  80011b:	83 c4 10             	add    $0x10,%esp
  80011e:	85 c0                	test   %eax,%eax
  800120:	74 14                	je     800136 <umain+0x103>
			panic("read in parent got different bytes from read in child");
  800122:	83 ec 04             	sub    $0x4,%esp
  800125:	68 18 28 80 00       	push   $0x802818
  80012a:	6a 19                	push   $0x19
  80012c:	68 53 27 80 00       	push   $0x802753
  800131:	e8 e2 00 00 00       	call   800218 <_panic>
		cprintf("read in child succeeded\n");
  800136:	83 ec 0c             	sub    $0xc,%esp
  800139:	68 72 27 80 00       	push   $0x802772
  80013e:	e8 ae 01 00 00       	call   8002f1 <cprintf>
		seek(fd, 0);
  800143:	83 c4 08             	add    $0x8,%esp
  800146:	6a 00                	push   $0x0
  800148:	53                   	push   %ebx
  800149:	e8 26 14 00 00       	call   801574 <seek>
		close(fd);
  80014e:	89 1c 24             	mov    %ebx,(%esp)
  800151:	e8 7c 11 00 00       	call   8012d2 <close>
		exit();
  800156:	e8 a3 00 00 00       	call   8001fe <exit>
  80015b:	83 c4 10             	add    $0x10,%esp
	}
	wait(r);
  80015e:	83 ec 0c             	sub    $0xc,%esp
  800161:	57                   	push   %edi
  800162:	e8 c2 1f 00 00       	call   802129 <wait>
	if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  800167:	83 c4 0c             	add    $0xc,%esp
  80016a:	68 00 02 00 00       	push   $0x200
  80016f:	68 20 40 80 00       	push   $0x804020
  800174:	53                   	push   %ebx
  800175:	e8 25 13 00 00       	call   80149f <readn>
  80017a:	83 c4 10             	add    $0x10,%esp
  80017d:	39 c6                	cmp    %eax,%esi
  80017f:	74 16                	je     800197 <umain+0x164>
		panic("read in parent got %d, then got %d", n, n2);
  800181:	83 ec 0c             	sub    $0xc,%esp
  800184:	50                   	push   %eax
  800185:	56                   	push   %esi
  800186:	68 50 28 80 00       	push   $0x802850
  80018b:	6a 21                	push   $0x21
  80018d:	68 53 27 80 00       	push   $0x802753
  800192:	e8 81 00 00 00       	call   800218 <_panic>
	cprintf("read in parent succeeded\n");
  800197:	83 ec 0c             	sub    $0xc,%esp
  80019a:	68 8b 27 80 00       	push   $0x80278b
  80019f:	e8 4d 01 00 00       	call   8002f1 <cprintf>
	close(fd);
  8001a4:	89 1c 24             	mov    %ebx,(%esp)
  8001a7:	e8 26 11 00 00       	call   8012d2 <close>
static __inline uint64_t read_tsc(void) __attribute__((always_inline));

static __inline void
breakpoint(void)
{
	__asm __volatile("int3");
  8001ac:	cc                   	int3   

	breakpoint();
}
  8001ad:	83 c4 10             	add    $0x10,%esp
  8001b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001b3:	5b                   	pop    %ebx
  8001b4:	5e                   	pop    %esi
  8001b5:	5f                   	pop    %edi
  8001b6:	5d                   	pop    %ebp
  8001b7:	c3                   	ret    

008001b8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	56                   	push   %esi
  8001bc:	53                   	push   %ebx
  8001bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001c0:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8001c3:	e8 73 0a 00 00       	call   800c3b <sys_getenvid>
  8001c8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001cd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001d0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001d5:	a3 20 44 80 00       	mov    %eax,0x804420

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001da:	85 db                	test   %ebx,%ebx
  8001dc:	7e 07                	jle    8001e5 <libmain+0x2d>
		binaryname = argv[0];
  8001de:	8b 06                	mov    (%esi),%eax
  8001e0:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8001e5:	83 ec 08             	sub    $0x8,%esp
  8001e8:	56                   	push   %esi
  8001e9:	53                   	push   %ebx
  8001ea:	e8 44 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8001ef:	e8 0a 00 00 00       	call   8001fe <exit>
}
  8001f4:	83 c4 10             	add    $0x10,%esp
  8001f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001fa:	5b                   	pop    %ebx
  8001fb:	5e                   	pop    %esi
  8001fc:	5d                   	pop    %ebp
  8001fd:	c3                   	ret    

008001fe <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001fe:	55                   	push   %ebp
  8001ff:	89 e5                	mov    %esp,%ebp
  800201:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800204:	e8 f4 10 00 00       	call   8012fd <close_all>
	sys_env_destroy(0);
  800209:	83 ec 0c             	sub    $0xc,%esp
  80020c:	6a 00                	push   $0x0
  80020e:	e8 e7 09 00 00       	call   800bfa <sys_env_destroy>
}
  800213:	83 c4 10             	add    $0x10,%esp
  800216:	c9                   	leave  
  800217:	c3                   	ret    

00800218 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800218:	55                   	push   %ebp
  800219:	89 e5                	mov    %esp,%ebp
  80021b:	56                   	push   %esi
  80021c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80021d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800220:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800226:	e8 10 0a 00 00       	call   800c3b <sys_getenvid>
  80022b:	83 ec 0c             	sub    $0xc,%esp
  80022e:	ff 75 0c             	pushl  0xc(%ebp)
  800231:	ff 75 08             	pushl  0x8(%ebp)
  800234:	56                   	push   %esi
  800235:	50                   	push   %eax
  800236:	68 80 28 80 00       	push   $0x802880
  80023b:	e8 b1 00 00 00       	call   8002f1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800240:	83 c4 18             	add    $0x18,%esp
  800243:	53                   	push   %ebx
  800244:	ff 75 10             	pushl  0x10(%ebp)
  800247:	e8 54 00 00 00       	call   8002a0 <vcprintf>
	cprintf("\n");
  80024c:	c7 04 24 89 27 80 00 	movl   $0x802789,(%esp)
  800253:	e8 99 00 00 00       	call   8002f1 <cprintf>
  800258:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80025b:	cc                   	int3   
  80025c:	eb fd                	jmp    80025b <_panic+0x43>

0080025e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80025e:	55                   	push   %ebp
  80025f:	89 e5                	mov    %esp,%ebp
  800261:	53                   	push   %ebx
  800262:	83 ec 04             	sub    $0x4,%esp
  800265:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800268:	8b 13                	mov    (%ebx),%edx
  80026a:	8d 42 01             	lea    0x1(%edx),%eax
  80026d:	89 03                	mov    %eax,(%ebx)
  80026f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800272:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800276:	3d ff 00 00 00       	cmp    $0xff,%eax
  80027b:	75 1a                	jne    800297 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80027d:	83 ec 08             	sub    $0x8,%esp
  800280:	68 ff 00 00 00       	push   $0xff
  800285:	8d 43 08             	lea    0x8(%ebx),%eax
  800288:	50                   	push   %eax
  800289:	e8 2f 09 00 00       	call   800bbd <sys_cputs>
		b->idx = 0;
  80028e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800294:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800297:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80029b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80029e:	c9                   	leave  
  80029f:	c3                   	ret    

008002a0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002a9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002b0:	00 00 00 
	b.cnt = 0;
  8002b3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002ba:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002bd:	ff 75 0c             	pushl  0xc(%ebp)
  8002c0:	ff 75 08             	pushl  0x8(%ebp)
  8002c3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002c9:	50                   	push   %eax
  8002ca:	68 5e 02 80 00       	push   $0x80025e
  8002cf:	e8 54 01 00 00       	call   800428 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002d4:	83 c4 08             	add    $0x8,%esp
  8002d7:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002dd:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002e3:	50                   	push   %eax
  8002e4:	e8 d4 08 00 00       	call   800bbd <sys_cputs>

	return b.cnt;
}
  8002e9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002ef:	c9                   	leave  
  8002f0:	c3                   	ret    

008002f1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002f1:	55                   	push   %ebp
  8002f2:	89 e5                	mov    %esp,%ebp
  8002f4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002f7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002fa:	50                   	push   %eax
  8002fb:	ff 75 08             	pushl  0x8(%ebp)
  8002fe:	e8 9d ff ff ff       	call   8002a0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800303:	c9                   	leave  
  800304:	c3                   	ret    

00800305 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800305:	55                   	push   %ebp
  800306:	89 e5                	mov    %esp,%ebp
  800308:	57                   	push   %edi
  800309:	56                   	push   %esi
  80030a:	53                   	push   %ebx
  80030b:	83 ec 1c             	sub    $0x1c,%esp
  80030e:	89 c7                	mov    %eax,%edi
  800310:	89 d6                	mov    %edx,%esi
  800312:	8b 45 08             	mov    0x8(%ebp),%eax
  800315:	8b 55 0c             	mov    0xc(%ebp),%edx
  800318:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80031b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80031e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800321:	bb 00 00 00 00       	mov    $0x0,%ebx
  800326:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800329:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80032c:	39 d3                	cmp    %edx,%ebx
  80032e:	72 05                	jb     800335 <printnum+0x30>
  800330:	39 45 10             	cmp    %eax,0x10(%ebp)
  800333:	77 45                	ja     80037a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800335:	83 ec 0c             	sub    $0xc,%esp
  800338:	ff 75 18             	pushl  0x18(%ebp)
  80033b:	8b 45 14             	mov    0x14(%ebp),%eax
  80033e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800341:	53                   	push   %ebx
  800342:	ff 75 10             	pushl  0x10(%ebp)
  800345:	83 ec 08             	sub    $0x8,%esp
  800348:	ff 75 e4             	pushl  -0x1c(%ebp)
  80034b:	ff 75 e0             	pushl  -0x20(%ebp)
  80034e:	ff 75 dc             	pushl  -0x24(%ebp)
  800351:	ff 75 d8             	pushl  -0x28(%ebp)
  800354:	e8 57 21 00 00       	call   8024b0 <__udivdi3>
  800359:	83 c4 18             	add    $0x18,%esp
  80035c:	52                   	push   %edx
  80035d:	50                   	push   %eax
  80035e:	89 f2                	mov    %esi,%edx
  800360:	89 f8                	mov    %edi,%eax
  800362:	e8 9e ff ff ff       	call   800305 <printnum>
  800367:	83 c4 20             	add    $0x20,%esp
  80036a:	eb 18                	jmp    800384 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80036c:	83 ec 08             	sub    $0x8,%esp
  80036f:	56                   	push   %esi
  800370:	ff 75 18             	pushl  0x18(%ebp)
  800373:	ff d7                	call   *%edi
  800375:	83 c4 10             	add    $0x10,%esp
  800378:	eb 03                	jmp    80037d <printnum+0x78>
  80037a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80037d:	83 eb 01             	sub    $0x1,%ebx
  800380:	85 db                	test   %ebx,%ebx
  800382:	7f e8                	jg     80036c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800384:	83 ec 08             	sub    $0x8,%esp
  800387:	56                   	push   %esi
  800388:	83 ec 04             	sub    $0x4,%esp
  80038b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80038e:	ff 75 e0             	pushl  -0x20(%ebp)
  800391:	ff 75 dc             	pushl  -0x24(%ebp)
  800394:	ff 75 d8             	pushl  -0x28(%ebp)
  800397:	e8 44 22 00 00       	call   8025e0 <__umoddi3>
  80039c:	83 c4 14             	add    $0x14,%esp
  80039f:	0f be 80 a3 28 80 00 	movsbl 0x8028a3(%eax),%eax
  8003a6:	50                   	push   %eax
  8003a7:	ff d7                	call   *%edi
}
  8003a9:	83 c4 10             	add    $0x10,%esp
  8003ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003af:	5b                   	pop    %ebx
  8003b0:	5e                   	pop    %esi
  8003b1:	5f                   	pop    %edi
  8003b2:	5d                   	pop    %ebp
  8003b3:	c3                   	ret    

008003b4 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003b4:	55                   	push   %ebp
  8003b5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003b7:	83 fa 01             	cmp    $0x1,%edx
  8003ba:	7e 0e                	jle    8003ca <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003bc:	8b 10                	mov    (%eax),%edx
  8003be:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003c1:	89 08                	mov    %ecx,(%eax)
  8003c3:	8b 02                	mov    (%edx),%eax
  8003c5:	8b 52 04             	mov    0x4(%edx),%edx
  8003c8:	eb 22                	jmp    8003ec <getuint+0x38>
	else if (lflag)
  8003ca:	85 d2                	test   %edx,%edx
  8003cc:	74 10                	je     8003de <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003ce:	8b 10                	mov    (%eax),%edx
  8003d0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003d3:	89 08                	mov    %ecx,(%eax)
  8003d5:	8b 02                	mov    (%edx),%eax
  8003d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8003dc:	eb 0e                	jmp    8003ec <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003de:	8b 10                	mov    (%eax),%edx
  8003e0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003e3:	89 08                	mov    %ecx,(%eax)
  8003e5:	8b 02                	mov    (%edx),%eax
  8003e7:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003ec:	5d                   	pop    %ebp
  8003ed:	c3                   	ret    

008003ee <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003ee:	55                   	push   %ebp
  8003ef:	89 e5                	mov    %esp,%ebp
  8003f1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003f4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003f8:	8b 10                	mov    (%eax),%edx
  8003fa:	3b 50 04             	cmp    0x4(%eax),%edx
  8003fd:	73 0a                	jae    800409 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003ff:	8d 4a 01             	lea    0x1(%edx),%ecx
  800402:	89 08                	mov    %ecx,(%eax)
  800404:	8b 45 08             	mov    0x8(%ebp),%eax
  800407:	88 02                	mov    %al,(%edx)
}
  800409:	5d                   	pop    %ebp
  80040a:	c3                   	ret    

0080040b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80040b:	55                   	push   %ebp
  80040c:	89 e5                	mov    %esp,%ebp
  80040e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800411:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800414:	50                   	push   %eax
  800415:	ff 75 10             	pushl  0x10(%ebp)
  800418:	ff 75 0c             	pushl  0xc(%ebp)
  80041b:	ff 75 08             	pushl  0x8(%ebp)
  80041e:	e8 05 00 00 00       	call   800428 <vprintfmt>
	va_end(ap);
}
  800423:	83 c4 10             	add    $0x10,%esp
  800426:	c9                   	leave  
  800427:	c3                   	ret    

00800428 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800428:	55                   	push   %ebp
  800429:	89 e5                	mov    %esp,%ebp
  80042b:	57                   	push   %edi
  80042c:	56                   	push   %esi
  80042d:	53                   	push   %ebx
  80042e:	83 ec 2c             	sub    $0x2c,%esp
  800431:	8b 75 08             	mov    0x8(%ebp),%esi
  800434:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800437:	8b 7d 10             	mov    0x10(%ebp),%edi
  80043a:	eb 12                	jmp    80044e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80043c:	85 c0                	test   %eax,%eax
  80043e:	0f 84 89 03 00 00    	je     8007cd <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800444:	83 ec 08             	sub    $0x8,%esp
  800447:	53                   	push   %ebx
  800448:	50                   	push   %eax
  800449:	ff d6                	call   *%esi
  80044b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80044e:	83 c7 01             	add    $0x1,%edi
  800451:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800455:	83 f8 25             	cmp    $0x25,%eax
  800458:	75 e2                	jne    80043c <vprintfmt+0x14>
  80045a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80045e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800465:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80046c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800473:	ba 00 00 00 00       	mov    $0x0,%edx
  800478:	eb 07                	jmp    800481 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80047d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800481:	8d 47 01             	lea    0x1(%edi),%eax
  800484:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800487:	0f b6 07             	movzbl (%edi),%eax
  80048a:	0f b6 c8             	movzbl %al,%ecx
  80048d:	83 e8 23             	sub    $0x23,%eax
  800490:	3c 55                	cmp    $0x55,%al
  800492:	0f 87 1a 03 00 00    	ja     8007b2 <vprintfmt+0x38a>
  800498:	0f b6 c0             	movzbl %al,%eax
  80049b:	ff 24 85 e0 29 80 00 	jmp    *0x8029e0(,%eax,4)
  8004a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004a5:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004a9:	eb d6                	jmp    800481 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8004b3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004b6:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004b9:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8004bd:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8004c0:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8004c3:	83 fa 09             	cmp    $0x9,%edx
  8004c6:	77 39                	ja     800501 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004c8:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004cb:	eb e9                	jmp    8004b6 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d0:	8d 48 04             	lea    0x4(%eax),%ecx
  8004d3:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004d6:	8b 00                	mov    (%eax),%eax
  8004d8:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004de:	eb 27                	jmp    800507 <vprintfmt+0xdf>
  8004e0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004e3:	85 c0                	test   %eax,%eax
  8004e5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004ea:	0f 49 c8             	cmovns %eax,%ecx
  8004ed:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004f3:	eb 8c                	jmp    800481 <vprintfmt+0x59>
  8004f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004f8:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004ff:	eb 80                	jmp    800481 <vprintfmt+0x59>
  800501:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800504:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800507:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80050b:	0f 89 70 ff ff ff    	jns    800481 <vprintfmt+0x59>
				width = precision, precision = -1;
  800511:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800514:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800517:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80051e:	e9 5e ff ff ff       	jmp    800481 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800523:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800526:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800529:	e9 53 ff ff ff       	jmp    800481 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80052e:	8b 45 14             	mov    0x14(%ebp),%eax
  800531:	8d 50 04             	lea    0x4(%eax),%edx
  800534:	89 55 14             	mov    %edx,0x14(%ebp)
  800537:	83 ec 08             	sub    $0x8,%esp
  80053a:	53                   	push   %ebx
  80053b:	ff 30                	pushl  (%eax)
  80053d:	ff d6                	call   *%esi
			break;
  80053f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800542:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800545:	e9 04 ff ff ff       	jmp    80044e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80054a:	8b 45 14             	mov    0x14(%ebp),%eax
  80054d:	8d 50 04             	lea    0x4(%eax),%edx
  800550:	89 55 14             	mov    %edx,0x14(%ebp)
  800553:	8b 00                	mov    (%eax),%eax
  800555:	99                   	cltd   
  800556:	31 d0                	xor    %edx,%eax
  800558:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80055a:	83 f8 0f             	cmp    $0xf,%eax
  80055d:	7f 0b                	jg     80056a <vprintfmt+0x142>
  80055f:	8b 14 85 40 2b 80 00 	mov    0x802b40(,%eax,4),%edx
  800566:	85 d2                	test   %edx,%edx
  800568:	75 18                	jne    800582 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80056a:	50                   	push   %eax
  80056b:	68 bb 28 80 00       	push   $0x8028bb
  800570:	53                   	push   %ebx
  800571:	56                   	push   %esi
  800572:	e8 94 fe ff ff       	call   80040b <printfmt>
  800577:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80057d:	e9 cc fe ff ff       	jmp    80044e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800582:	52                   	push   %edx
  800583:	68 fe 2c 80 00       	push   $0x802cfe
  800588:	53                   	push   %ebx
  800589:	56                   	push   %esi
  80058a:	e8 7c fe ff ff       	call   80040b <printfmt>
  80058f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800592:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800595:	e9 b4 fe ff ff       	jmp    80044e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80059a:	8b 45 14             	mov    0x14(%ebp),%eax
  80059d:	8d 50 04             	lea    0x4(%eax),%edx
  8005a0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a3:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005a5:	85 ff                	test   %edi,%edi
  8005a7:	b8 b4 28 80 00       	mov    $0x8028b4,%eax
  8005ac:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005af:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005b3:	0f 8e 94 00 00 00    	jle    80064d <vprintfmt+0x225>
  8005b9:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005bd:	0f 84 98 00 00 00    	je     80065b <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c3:	83 ec 08             	sub    $0x8,%esp
  8005c6:	ff 75 d0             	pushl  -0x30(%ebp)
  8005c9:	57                   	push   %edi
  8005ca:	e8 86 02 00 00       	call   800855 <strnlen>
  8005cf:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005d2:	29 c1                	sub    %eax,%ecx
  8005d4:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005d7:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005da:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005de:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005e1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005e4:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e6:	eb 0f                	jmp    8005f7 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8005e8:	83 ec 08             	sub    $0x8,%esp
  8005eb:	53                   	push   %ebx
  8005ec:	ff 75 e0             	pushl  -0x20(%ebp)
  8005ef:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f1:	83 ef 01             	sub    $0x1,%edi
  8005f4:	83 c4 10             	add    $0x10,%esp
  8005f7:	85 ff                	test   %edi,%edi
  8005f9:	7f ed                	jg     8005e8 <vprintfmt+0x1c0>
  8005fb:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005fe:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800601:	85 c9                	test   %ecx,%ecx
  800603:	b8 00 00 00 00       	mov    $0x0,%eax
  800608:	0f 49 c1             	cmovns %ecx,%eax
  80060b:	29 c1                	sub    %eax,%ecx
  80060d:	89 75 08             	mov    %esi,0x8(%ebp)
  800610:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800613:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800616:	89 cb                	mov    %ecx,%ebx
  800618:	eb 4d                	jmp    800667 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80061a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80061e:	74 1b                	je     80063b <vprintfmt+0x213>
  800620:	0f be c0             	movsbl %al,%eax
  800623:	83 e8 20             	sub    $0x20,%eax
  800626:	83 f8 5e             	cmp    $0x5e,%eax
  800629:	76 10                	jbe    80063b <vprintfmt+0x213>
					putch('?', putdat);
  80062b:	83 ec 08             	sub    $0x8,%esp
  80062e:	ff 75 0c             	pushl  0xc(%ebp)
  800631:	6a 3f                	push   $0x3f
  800633:	ff 55 08             	call   *0x8(%ebp)
  800636:	83 c4 10             	add    $0x10,%esp
  800639:	eb 0d                	jmp    800648 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80063b:	83 ec 08             	sub    $0x8,%esp
  80063e:	ff 75 0c             	pushl  0xc(%ebp)
  800641:	52                   	push   %edx
  800642:	ff 55 08             	call   *0x8(%ebp)
  800645:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800648:	83 eb 01             	sub    $0x1,%ebx
  80064b:	eb 1a                	jmp    800667 <vprintfmt+0x23f>
  80064d:	89 75 08             	mov    %esi,0x8(%ebp)
  800650:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800653:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800656:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800659:	eb 0c                	jmp    800667 <vprintfmt+0x23f>
  80065b:	89 75 08             	mov    %esi,0x8(%ebp)
  80065e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800661:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800664:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800667:	83 c7 01             	add    $0x1,%edi
  80066a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80066e:	0f be d0             	movsbl %al,%edx
  800671:	85 d2                	test   %edx,%edx
  800673:	74 23                	je     800698 <vprintfmt+0x270>
  800675:	85 f6                	test   %esi,%esi
  800677:	78 a1                	js     80061a <vprintfmt+0x1f2>
  800679:	83 ee 01             	sub    $0x1,%esi
  80067c:	79 9c                	jns    80061a <vprintfmt+0x1f2>
  80067e:	89 df                	mov    %ebx,%edi
  800680:	8b 75 08             	mov    0x8(%ebp),%esi
  800683:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800686:	eb 18                	jmp    8006a0 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800688:	83 ec 08             	sub    $0x8,%esp
  80068b:	53                   	push   %ebx
  80068c:	6a 20                	push   $0x20
  80068e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800690:	83 ef 01             	sub    $0x1,%edi
  800693:	83 c4 10             	add    $0x10,%esp
  800696:	eb 08                	jmp    8006a0 <vprintfmt+0x278>
  800698:	89 df                	mov    %ebx,%edi
  80069a:	8b 75 08             	mov    0x8(%ebp),%esi
  80069d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006a0:	85 ff                	test   %edi,%edi
  8006a2:	7f e4                	jg     800688 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006a7:	e9 a2 fd ff ff       	jmp    80044e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006ac:	83 fa 01             	cmp    $0x1,%edx
  8006af:	7e 16                	jle    8006c7 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8006b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b4:	8d 50 08             	lea    0x8(%eax),%edx
  8006b7:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ba:	8b 50 04             	mov    0x4(%eax),%edx
  8006bd:	8b 00                	mov    (%eax),%eax
  8006bf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006c2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006c5:	eb 32                	jmp    8006f9 <vprintfmt+0x2d1>
	else if (lflag)
  8006c7:	85 d2                	test   %edx,%edx
  8006c9:	74 18                	je     8006e3 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8006cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ce:	8d 50 04             	lea    0x4(%eax),%edx
  8006d1:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d4:	8b 00                	mov    (%eax),%eax
  8006d6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006d9:	89 c1                	mov    %eax,%ecx
  8006db:	c1 f9 1f             	sar    $0x1f,%ecx
  8006de:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006e1:	eb 16                	jmp    8006f9 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8006e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e6:	8d 50 04             	lea    0x4(%eax),%edx
  8006e9:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ec:	8b 00                	mov    (%eax),%eax
  8006ee:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006f1:	89 c1                	mov    %eax,%ecx
  8006f3:	c1 f9 1f             	sar    $0x1f,%ecx
  8006f6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006f9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006fc:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006ff:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800704:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800708:	79 74                	jns    80077e <vprintfmt+0x356>
				putch('-', putdat);
  80070a:	83 ec 08             	sub    $0x8,%esp
  80070d:	53                   	push   %ebx
  80070e:	6a 2d                	push   $0x2d
  800710:	ff d6                	call   *%esi
				num = -(long long) num;
  800712:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800715:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800718:	f7 d8                	neg    %eax
  80071a:	83 d2 00             	adc    $0x0,%edx
  80071d:	f7 da                	neg    %edx
  80071f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800722:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800727:	eb 55                	jmp    80077e <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800729:	8d 45 14             	lea    0x14(%ebp),%eax
  80072c:	e8 83 fc ff ff       	call   8003b4 <getuint>
			base = 10;
  800731:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800736:	eb 46                	jmp    80077e <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800738:	8d 45 14             	lea    0x14(%ebp),%eax
  80073b:	e8 74 fc ff ff       	call   8003b4 <getuint>
                        base = 8;
  800740:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800745:	eb 37                	jmp    80077e <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800747:	83 ec 08             	sub    $0x8,%esp
  80074a:	53                   	push   %ebx
  80074b:	6a 30                	push   $0x30
  80074d:	ff d6                	call   *%esi
			putch('x', putdat);
  80074f:	83 c4 08             	add    $0x8,%esp
  800752:	53                   	push   %ebx
  800753:	6a 78                	push   $0x78
  800755:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800757:	8b 45 14             	mov    0x14(%ebp),%eax
  80075a:	8d 50 04             	lea    0x4(%eax),%edx
  80075d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800760:	8b 00                	mov    (%eax),%eax
  800762:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800767:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80076a:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80076f:	eb 0d                	jmp    80077e <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800771:	8d 45 14             	lea    0x14(%ebp),%eax
  800774:	e8 3b fc ff ff       	call   8003b4 <getuint>
			base = 16;
  800779:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80077e:	83 ec 0c             	sub    $0xc,%esp
  800781:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800785:	57                   	push   %edi
  800786:	ff 75 e0             	pushl  -0x20(%ebp)
  800789:	51                   	push   %ecx
  80078a:	52                   	push   %edx
  80078b:	50                   	push   %eax
  80078c:	89 da                	mov    %ebx,%edx
  80078e:	89 f0                	mov    %esi,%eax
  800790:	e8 70 fb ff ff       	call   800305 <printnum>
			break;
  800795:	83 c4 20             	add    $0x20,%esp
  800798:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80079b:	e9 ae fc ff ff       	jmp    80044e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007a0:	83 ec 08             	sub    $0x8,%esp
  8007a3:	53                   	push   %ebx
  8007a4:	51                   	push   %ecx
  8007a5:	ff d6                	call   *%esi
			break;
  8007a7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007ad:	e9 9c fc ff ff       	jmp    80044e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007b2:	83 ec 08             	sub    $0x8,%esp
  8007b5:	53                   	push   %ebx
  8007b6:	6a 25                	push   $0x25
  8007b8:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007ba:	83 c4 10             	add    $0x10,%esp
  8007bd:	eb 03                	jmp    8007c2 <vprintfmt+0x39a>
  8007bf:	83 ef 01             	sub    $0x1,%edi
  8007c2:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007c6:	75 f7                	jne    8007bf <vprintfmt+0x397>
  8007c8:	e9 81 fc ff ff       	jmp    80044e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007d0:	5b                   	pop    %ebx
  8007d1:	5e                   	pop    %esi
  8007d2:	5f                   	pop    %edi
  8007d3:	5d                   	pop    %ebp
  8007d4:	c3                   	ret    

008007d5 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007d5:	55                   	push   %ebp
  8007d6:	89 e5                	mov    %esp,%ebp
  8007d8:	83 ec 18             	sub    $0x18,%esp
  8007db:	8b 45 08             	mov    0x8(%ebp),%eax
  8007de:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007e1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007e4:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007e8:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007eb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007f2:	85 c0                	test   %eax,%eax
  8007f4:	74 26                	je     80081c <vsnprintf+0x47>
  8007f6:	85 d2                	test   %edx,%edx
  8007f8:	7e 22                	jle    80081c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007fa:	ff 75 14             	pushl  0x14(%ebp)
  8007fd:	ff 75 10             	pushl  0x10(%ebp)
  800800:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800803:	50                   	push   %eax
  800804:	68 ee 03 80 00       	push   $0x8003ee
  800809:	e8 1a fc ff ff       	call   800428 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80080e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800811:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800814:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800817:	83 c4 10             	add    $0x10,%esp
  80081a:	eb 05                	jmp    800821 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80081c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800821:	c9                   	leave  
  800822:	c3                   	ret    

00800823 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800823:	55                   	push   %ebp
  800824:	89 e5                	mov    %esp,%ebp
  800826:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800829:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80082c:	50                   	push   %eax
  80082d:	ff 75 10             	pushl  0x10(%ebp)
  800830:	ff 75 0c             	pushl  0xc(%ebp)
  800833:	ff 75 08             	pushl  0x8(%ebp)
  800836:	e8 9a ff ff ff       	call   8007d5 <vsnprintf>
	va_end(ap);

	return rc;
}
  80083b:	c9                   	leave  
  80083c:	c3                   	ret    

0080083d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80083d:	55                   	push   %ebp
  80083e:	89 e5                	mov    %esp,%ebp
  800840:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800843:	b8 00 00 00 00       	mov    $0x0,%eax
  800848:	eb 03                	jmp    80084d <strlen+0x10>
		n++;
  80084a:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80084d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800851:	75 f7                	jne    80084a <strlen+0xd>
		n++;
	return n;
}
  800853:	5d                   	pop    %ebp
  800854:	c3                   	ret    

00800855 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800855:	55                   	push   %ebp
  800856:	89 e5                	mov    %esp,%ebp
  800858:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80085b:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80085e:	ba 00 00 00 00       	mov    $0x0,%edx
  800863:	eb 03                	jmp    800868 <strnlen+0x13>
		n++;
  800865:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800868:	39 c2                	cmp    %eax,%edx
  80086a:	74 08                	je     800874 <strnlen+0x1f>
  80086c:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800870:	75 f3                	jne    800865 <strnlen+0x10>
  800872:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800874:	5d                   	pop    %ebp
  800875:	c3                   	ret    

00800876 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800876:	55                   	push   %ebp
  800877:	89 e5                	mov    %esp,%ebp
  800879:	53                   	push   %ebx
  80087a:	8b 45 08             	mov    0x8(%ebp),%eax
  80087d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800880:	89 c2                	mov    %eax,%edx
  800882:	83 c2 01             	add    $0x1,%edx
  800885:	83 c1 01             	add    $0x1,%ecx
  800888:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80088c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80088f:	84 db                	test   %bl,%bl
  800891:	75 ef                	jne    800882 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800893:	5b                   	pop    %ebx
  800894:	5d                   	pop    %ebp
  800895:	c3                   	ret    

00800896 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800896:	55                   	push   %ebp
  800897:	89 e5                	mov    %esp,%ebp
  800899:	53                   	push   %ebx
  80089a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80089d:	53                   	push   %ebx
  80089e:	e8 9a ff ff ff       	call   80083d <strlen>
  8008a3:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008a6:	ff 75 0c             	pushl  0xc(%ebp)
  8008a9:	01 d8                	add    %ebx,%eax
  8008ab:	50                   	push   %eax
  8008ac:	e8 c5 ff ff ff       	call   800876 <strcpy>
	return dst;
}
  8008b1:	89 d8                	mov    %ebx,%eax
  8008b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008b6:	c9                   	leave  
  8008b7:	c3                   	ret    

008008b8 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008b8:	55                   	push   %ebp
  8008b9:	89 e5                	mov    %esp,%ebp
  8008bb:	56                   	push   %esi
  8008bc:	53                   	push   %ebx
  8008bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8008c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008c3:	89 f3                	mov    %esi,%ebx
  8008c5:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008c8:	89 f2                	mov    %esi,%edx
  8008ca:	eb 0f                	jmp    8008db <strncpy+0x23>
		*dst++ = *src;
  8008cc:	83 c2 01             	add    $0x1,%edx
  8008cf:	0f b6 01             	movzbl (%ecx),%eax
  8008d2:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008d5:	80 39 01             	cmpb   $0x1,(%ecx)
  8008d8:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008db:	39 da                	cmp    %ebx,%edx
  8008dd:	75 ed                	jne    8008cc <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008df:	89 f0                	mov    %esi,%eax
  8008e1:	5b                   	pop    %ebx
  8008e2:	5e                   	pop    %esi
  8008e3:	5d                   	pop    %ebp
  8008e4:	c3                   	ret    

008008e5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008e5:	55                   	push   %ebp
  8008e6:	89 e5                	mov    %esp,%ebp
  8008e8:	56                   	push   %esi
  8008e9:	53                   	push   %ebx
  8008ea:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008f0:	8b 55 10             	mov    0x10(%ebp),%edx
  8008f3:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008f5:	85 d2                	test   %edx,%edx
  8008f7:	74 21                	je     80091a <strlcpy+0x35>
  8008f9:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008fd:	89 f2                	mov    %esi,%edx
  8008ff:	eb 09                	jmp    80090a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800901:	83 c2 01             	add    $0x1,%edx
  800904:	83 c1 01             	add    $0x1,%ecx
  800907:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80090a:	39 c2                	cmp    %eax,%edx
  80090c:	74 09                	je     800917 <strlcpy+0x32>
  80090e:	0f b6 19             	movzbl (%ecx),%ebx
  800911:	84 db                	test   %bl,%bl
  800913:	75 ec                	jne    800901 <strlcpy+0x1c>
  800915:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800917:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80091a:	29 f0                	sub    %esi,%eax
}
  80091c:	5b                   	pop    %ebx
  80091d:	5e                   	pop    %esi
  80091e:	5d                   	pop    %ebp
  80091f:	c3                   	ret    

00800920 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800920:	55                   	push   %ebp
  800921:	89 e5                	mov    %esp,%ebp
  800923:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800926:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800929:	eb 06                	jmp    800931 <strcmp+0x11>
		p++, q++;
  80092b:	83 c1 01             	add    $0x1,%ecx
  80092e:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800931:	0f b6 01             	movzbl (%ecx),%eax
  800934:	84 c0                	test   %al,%al
  800936:	74 04                	je     80093c <strcmp+0x1c>
  800938:	3a 02                	cmp    (%edx),%al
  80093a:	74 ef                	je     80092b <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80093c:	0f b6 c0             	movzbl %al,%eax
  80093f:	0f b6 12             	movzbl (%edx),%edx
  800942:	29 d0                	sub    %edx,%eax
}
  800944:	5d                   	pop    %ebp
  800945:	c3                   	ret    

00800946 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800946:	55                   	push   %ebp
  800947:	89 e5                	mov    %esp,%ebp
  800949:	53                   	push   %ebx
  80094a:	8b 45 08             	mov    0x8(%ebp),%eax
  80094d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800950:	89 c3                	mov    %eax,%ebx
  800952:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800955:	eb 06                	jmp    80095d <strncmp+0x17>
		n--, p++, q++;
  800957:	83 c0 01             	add    $0x1,%eax
  80095a:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80095d:	39 d8                	cmp    %ebx,%eax
  80095f:	74 15                	je     800976 <strncmp+0x30>
  800961:	0f b6 08             	movzbl (%eax),%ecx
  800964:	84 c9                	test   %cl,%cl
  800966:	74 04                	je     80096c <strncmp+0x26>
  800968:	3a 0a                	cmp    (%edx),%cl
  80096a:	74 eb                	je     800957 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80096c:	0f b6 00             	movzbl (%eax),%eax
  80096f:	0f b6 12             	movzbl (%edx),%edx
  800972:	29 d0                	sub    %edx,%eax
  800974:	eb 05                	jmp    80097b <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800976:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80097b:	5b                   	pop    %ebx
  80097c:	5d                   	pop    %ebp
  80097d:	c3                   	ret    

0080097e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80097e:	55                   	push   %ebp
  80097f:	89 e5                	mov    %esp,%ebp
  800981:	8b 45 08             	mov    0x8(%ebp),%eax
  800984:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800988:	eb 07                	jmp    800991 <strchr+0x13>
		if (*s == c)
  80098a:	38 ca                	cmp    %cl,%dl
  80098c:	74 0f                	je     80099d <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80098e:	83 c0 01             	add    $0x1,%eax
  800991:	0f b6 10             	movzbl (%eax),%edx
  800994:	84 d2                	test   %dl,%dl
  800996:	75 f2                	jne    80098a <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800998:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80099d:	5d                   	pop    %ebp
  80099e:	c3                   	ret    

0080099f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80099f:	55                   	push   %ebp
  8009a0:	89 e5                	mov    %esp,%ebp
  8009a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009a9:	eb 03                	jmp    8009ae <strfind+0xf>
  8009ab:	83 c0 01             	add    $0x1,%eax
  8009ae:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009b1:	38 ca                	cmp    %cl,%dl
  8009b3:	74 04                	je     8009b9 <strfind+0x1a>
  8009b5:	84 d2                	test   %dl,%dl
  8009b7:	75 f2                	jne    8009ab <strfind+0xc>
			break;
	return (char *) s;
}
  8009b9:	5d                   	pop    %ebp
  8009ba:	c3                   	ret    

008009bb <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009bb:	55                   	push   %ebp
  8009bc:	89 e5                	mov    %esp,%ebp
  8009be:	57                   	push   %edi
  8009bf:	56                   	push   %esi
  8009c0:	53                   	push   %ebx
  8009c1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009c4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009c7:	85 c9                	test   %ecx,%ecx
  8009c9:	74 36                	je     800a01 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009cb:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009d1:	75 28                	jne    8009fb <memset+0x40>
  8009d3:	f6 c1 03             	test   $0x3,%cl
  8009d6:	75 23                	jne    8009fb <memset+0x40>
		c &= 0xFF;
  8009d8:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009dc:	89 d3                	mov    %edx,%ebx
  8009de:	c1 e3 08             	shl    $0x8,%ebx
  8009e1:	89 d6                	mov    %edx,%esi
  8009e3:	c1 e6 18             	shl    $0x18,%esi
  8009e6:	89 d0                	mov    %edx,%eax
  8009e8:	c1 e0 10             	shl    $0x10,%eax
  8009eb:	09 f0                	or     %esi,%eax
  8009ed:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8009ef:	89 d8                	mov    %ebx,%eax
  8009f1:	09 d0                	or     %edx,%eax
  8009f3:	c1 e9 02             	shr    $0x2,%ecx
  8009f6:	fc                   	cld    
  8009f7:	f3 ab                	rep stos %eax,%es:(%edi)
  8009f9:	eb 06                	jmp    800a01 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009fe:	fc                   	cld    
  8009ff:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a01:	89 f8                	mov    %edi,%eax
  800a03:	5b                   	pop    %ebx
  800a04:	5e                   	pop    %esi
  800a05:	5f                   	pop    %edi
  800a06:	5d                   	pop    %ebp
  800a07:	c3                   	ret    

00800a08 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a08:	55                   	push   %ebp
  800a09:	89 e5                	mov    %esp,%ebp
  800a0b:	57                   	push   %edi
  800a0c:	56                   	push   %esi
  800a0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a10:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a13:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a16:	39 c6                	cmp    %eax,%esi
  800a18:	73 35                	jae    800a4f <memmove+0x47>
  800a1a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a1d:	39 d0                	cmp    %edx,%eax
  800a1f:	73 2e                	jae    800a4f <memmove+0x47>
		s += n;
		d += n;
  800a21:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a24:	89 d6                	mov    %edx,%esi
  800a26:	09 fe                	or     %edi,%esi
  800a28:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a2e:	75 13                	jne    800a43 <memmove+0x3b>
  800a30:	f6 c1 03             	test   $0x3,%cl
  800a33:	75 0e                	jne    800a43 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a35:	83 ef 04             	sub    $0x4,%edi
  800a38:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a3b:	c1 e9 02             	shr    $0x2,%ecx
  800a3e:	fd                   	std    
  800a3f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a41:	eb 09                	jmp    800a4c <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a43:	83 ef 01             	sub    $0x1,%edi
  800a46:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a49:	fd                   	std    
  800a4a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a4c:	fc                   	cld    
  800a4d:	eb 1d                	jmp    800a6c <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a4f:	89 f2                	mov    %esi,%edx
  800a51:	09 c2                	or     %eax,%edx
  800a53:	f6 c2 03             	test   $0x3,%dl
  800a56:	75 0f                	jne    800a67 <memmove+0x5f>
  800a58:	f6 c1 03             	test   $0x3,%cl
  800a5b:	75 0a                	jne    800a67 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a5d:	c1 e9 02             	shr    $0x2,%ecx
  800a60:	89 c7                	mov    %eax,%edi
  800a62:	fc                   	cld    
  800a63:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a65:	eb 05                	jmp    800a6c <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a67:	89 c7                	mov    %eax,%edi
  800a69:	fc                   	cld    
  800a6a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a6c:	5e                   	pop    %esi
  800a6d:	5f                   	pop    %edi
  800a6e:	5d                   	pop    %ebp
  800a6f:	c3                   	ret    

00800a70 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a70:	55                   	push   %ebp
  800a71:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a73:	ff 75 10             	pushl  0x10(%ebp)
  800a76:	ff 75 0c             	pushl  0xc(%ebp)
  800a79:	ff 75 08             	pushl  0x8(%ebp)
  800a7c:	e8 87 ff ff ff       	call   800a08 <memmove>
}
  800a81:	c9                   	leave  
  800a82:	c3                   	ret    

00800a83 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a83:	55                   	push   %ebp
  800a84:	89 e5                	mov    %esp,%ebp
  800a86:	56                   	push   %esi
  800a87:	53                   	push   %ebx
  800a88:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a8e:	89 c6                	mov    %eax,%esi
  800a90:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a93:	eb 1a                	jmp    800aaf <memcmp+0x2c>
		if (*s1 != *s2)
  800a95:	0f b6 08             	movzbl (%eax),%ecx
  800a98:	0f b6 1a             	movzbl (%edx),%ebx
  800a9b:	38 d9                	cmp    %bl,%cl
  800a9d:	74 0a                	je     800aa9 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a9f:	0f b6 c1             	movzbl %cl,%eax
  800aa2:	0f b6 db             	movzbl %bl,%ebx
  800aa5:	29 d8                	sub    %ebx,%eax
  800aa7:	eb 0f                	jmp    800ab8 <memcmp+0x35>
		s1++, s2++;
  800aa9:	83 c0 01             	add    $0x1,%eax
  800aac:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aaf:	39 f0                	cmp    %esi,%eax
  800ab1:	75 e2                	jne    800a95 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ab3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ab8:	5b                   	pop    %ebx
  800ab9:	5e                   	pop    %esi
  800aba:	5d                   	pop    %ebp
  800abb:	c3                   	ret    

00800abc <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800abc:	55                   	push   %ebp
  800abd:	89 e5                	mov    %esp,%ebp
  800abf:	53                   	push   %ebx
  800ac0:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ac3:	89 c1                	mov    %eax,%ecx
  800ac5:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800ac8:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800acc:	eb 0a                	jmp    800ad8 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ace:	0f b6 10             	movzbl (%eax),%edx
  800ad1:	39 da                	cmp    %ebx,%edx
  800ad3:	74 07                	je     800adc <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ad5:	83 c0 01             	add    $0x1,%eax
  800ad8:	39 c8                	cmp    %ecx,%eax
  800ada:	72 f2                	jb     800ace <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800adc:	5b                   	pop    %ebx
  800add:	5d                   	pop    %ebp
  800ade:	c3                   	ret    

00800adf <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800adf:	55                   	push   %ebp
  800ae0:	89 e5                	mov    %esp,%ebp
  800ae2:	57                   	push   %edi
  800ae3:	56                   	push   %esi
  800ae4:	53                   	push   %ebx
  800ae5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ae8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aeb:	eb 03                	jmp    800af0 <strtol+0x11>
		s++;
  800aed:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800af0:	0f b6 01             	movzbl (%ecx),%eax
  800af3:	3c 20                	cmp    $0x20,%al
  800af5:	74 f6                	je     800aed <strtol+0xe>
  800af7:	3c 09                	cmp    $0x9,%al
  800af9:	74 f2                	je     800aed <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800afb:	3c 2b                	cmp    $0x2b,%al
  800afd:	75 0a                	jne    800b09 <strtol+0x2a>
		s++;
  800aff:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b02:	bf 00 00 00 00       	mov    $0x0,%edi
  800b07:	eb 11                	jmp    800b1a <strtol+0x3b>
  800b09:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b0e:	3c 2d                	cmp    $0x2d,%al
  800b10:	75 08                	jne    800b1a <strtol+0x3b>
		s++, neg = 1;
  800b12:	83 c1 01             	add    $0x1,%ecx
  800b15:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b1a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b20:	75 15                	jne    800b37 <strtol+0x58>
  800b22:	80 39 30             	cmpb   $0x30,(%ecx)
  800b25:	75 10                	jne    800b37 <strtol+0x58>
  800b27:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b2b:	75 7c                	jne    800ba9 <strtol+0xca>
		s += 2, base = 16;
  800b2d:	83 c1 02             	add    $0x2,%ecx
  800b30:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b35:	eb 16                	jmp    800b4d <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b37:	85 db                	test   %ebx,%ebx
  800b39:	75 12                	jne    800b4d <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b3b:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b40:	80 39 30             	cmpb   $0x30,(%ecx)
  800b43:	75 08                	jne    800b4d <strtol+0x6e>
		s++, base = 8;
  800b45:	83 c1 01             	add    $0x1,%ecx
  800b48:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b4d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b52:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b55:	0f b6 11             	movzbl (%ecx),%edx
  800b58:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b5b:	89 f3                	mov    %esi,%ebx
  800b5d:	80 fb 09             	cmp    $0x9,%bl
  800b60:	77 08                	ja     800b6a <strtol+0x8b>
			dig = *s - '0';
  800b62:	0f be d2             	movsbl %dl,%edx
  800b65:	83 ea 30             	sub    $0x30,%edx
  800b68:	eb 22                	jmp    800b8c <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b6a:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b6d:	89 f3                	mov    %esi,%ebx
  800b6f:	80 fb 19             	cmp    $0x19,%bl
  800b72:	77 08                	ja     800b7c <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b74:	0f be d2             	movsbl %dl,%edx
  800b77:	83 ea 57             	sub    $0x57,%edx
  800b7a:	eb 10                	jmp    800b8c <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b7c:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b7f:	89 f3                	mov    %esi,%ebx
  800b81:	80 fb 19             	cmp    $0x19,%bl
  800b84:	77 16                	ja     800b9c <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b86:	0f be d2             	movsbl %dl,%edx
  800b89:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b8c:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b8f:	7d 0b                	jge    800b9c <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b91:	83 c1 01             	add    $0x1,%ecx
  800b94:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b98:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b9a:	eb b9                	jmp    800b55 <strtol+0x76>

	if (endptr)
  800b9c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ba0:	74 0d                	je     800baf <strtol+0xd0>
		*endptr = (char *) s;
  800ba2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ba5:	89 0e                	mov    %ecx,(%esi)
  800ba7:	eb 06                	jmp    800baf <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ba9:	85 db                	test   %ebx,%ebx
  800bab:	74 98                	je     800b45 <strtol+0x66>
  800bad:	eb 9e                	jmp    800b4d <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800baf:	89 c2                	mov    %eax,%edx
  800bb1:	f7 da                	neg    %edx
  800bb3:	85 ff                	test   %edi,%edi
  800bb5:	0f 45 c2             	cmovne %edx,%eax
}
  800bb8:	5b                   	pop    %ebx
  800bb9:	5e                   	pop    %esi
  800bba:	5f                   	pop    %edi
  800bbb:	5d                   	pop    %ebp
  800bbc:	c3                   	ret    

00800bbd <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bbd:	55                   	push   %ebp
  800bbe:	89 e5                	mov    %esp,%ebp
  800bc0:	57                   	push   %edi
  800bc1:	56                   	push   %esi
  800bc2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc3:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bcb:	8b 55 08             	mov    0x8(%ebp),%edx
  800bce:	89 c3                	mov    %eax,%ebx
  800bd0:	89 c7                	mov    %eax,%edi
  800bd2:	89 c6                	mov    %eax,%esi
  800bd4:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bd6:	5b                   	pop    %ebx
  800bd7:	5e                   	pop    %esi
  800bd8:	5f                   	pop    %edi
  800bd9:	5d                   	pop    %ebp
  800bda:	c3                   	ret    

00800bdb <sys_cgetc>:

int
sys_cgetc(void)
{
  800bdb:	55                   	push   %ebp
  800bdc:	89 e5                	mov    %esp,%ebp
  800bde:	57                   	push   %edi
  800bdf:	56                   	push   %esi
  800be0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be1:	ba 00 00 00 00       	mov    $0x0,%edx
  800be6:	b8 01 00 00 00       	mov    $0x1,%eax
  800beb:	89 d1                	mov    %edx,%ecx
  800bed:	89 d3                	mov    %edx,%ebx
  800bef:	89 d7                	mov    %edx,%edi
  800bf1:	89 d6                	mov    %edx,%esi
  800bf3:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bf5:	5b                   	pop    %ebx
  800bf6:	5e                   	pop    %esi
  800bf7:	5f                   	pop    %edi
  800bf8:	5d                   	pop    %ebp
  800bf9:	c3                   	ret    

00800bfa <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bfa:	55                   	push   %ebp
  800bfb:	89 e5                	mov    %esp,%ebp
  800bfd:	57                   	push   %edi
  800bfe:	56                   	push   %esi
  800bff:	53                   	push   %ebx
  800c00:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c03:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c08:	b8 03 00 00 00       	mov    $0x3,%eax
  800c0d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c10:	89 cb                	mov    %ecx,%ebx
  800c12:	89 cf                	mov    %ecx,%edi
  800c14:	89 ce                	mov    %ecx,%esi
  800c16:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c18:	85 c0                	test   %eax,%eax
  800c1a:	7e 17                	jle    800c33 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1c:	83 ec 0c             	sub    $0xc,%esp
  800c1f:	50                   	push   %eax
  800c20:	6a 03                	push   $0x3
  800c22:	68 9f 2b 80 00       	push   $0x802b9f
  800c27:	6a 23                	push   $0x23
  800c29:	68 bc 2b 80 00       	push   $0x802bbc
  800c2e:	e8 e5 f5 ff ff       	call   800218 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c36:	5b                   	pop    %ebx
  800c37:	5e                   	pop    %esi
  800c38:	5f                   	pop    %edi
  800c39:	5d                   	pop    %ebp
  800c3a:	c3                   	ret    

00800c3b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c3b:	55                   	push   %ebp
  800c3c:	89 e5                	mov    %esp,%ebp
  800c3e:	57                   	push   %edi
  800c3f:	56                   	push   %esi
  800c40:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c41:	ba 00 00 00 00       	mov    $0x0,%edx
  800c46:	b8 02 00 00 00       	mov    $0x2,%eax
  800c4b:	89 d1                	mov    %edx,%ecx
  800c4d:	89 d3                	mov    %edx,%ebx
  800c4f:	89 d7                	mov    %edx,%edi
  800c51:	89 d6                	mov    %edx,%esi
  800c53:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c55:	5b                   	pop    %ebx
  800c56:	5e                   	pop    %esi
  800c57:	5f                   	pop    %edi
  800c58:	5d                   	pop    %ebp
  800c59:	c3                   	ret    

00800c5a <sys_yield>:

void
sys_yield(void)
{
  800c5a:	55                   	push   %ebp
  800c5b:	89 e5                	mov    %esp,%ebp
  800c5d:	57                   	push   %edi
  800c5e:	56                   	push   %esi
  800c5f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c60:	ba 00 00 00 00       	mov    $0x0,%edx
  800c65:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c6a:	89 d1                	mov    %edx,%ecx
  800c6c:	89 d3                	mov    %edx,%ebx
  800c6e:	89 d7                	mov    %edx,%edi
  800c70:	89 d6                	mov    %edx,%esi
  800c72:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c74:	5b                   	pop    %ebx
  800c75:	5e                   	pop    %esi
  800c76:	5f                   	pop    %edi
  800c77:	5d                   	pop    %ebp
  800c78:	c3                   	ret    

00800c79 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800c82:	be 00 00 00 00       	mov    $0x0,%esi
  800c87:	b8 04 00 00 00       	mov    $0x4,%eax
  800c8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c92:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c95:	89 f7                	mov    %esi,%edi
  800c97:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c99:	85 c0                	test   %eax,%eax
  800c9b:	7e 17                	jle    800cb4 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9d:	83 ec 0c             	sub    $0xc,%esp
  800ca0:	50                   	push   %eax
  800ca1:	6a 04                	push   $0x4
  800ca3:	68 9f 2b 80 00       	push   $0x802b9f
  800ca8:	6a 23                	push   $0x23
  800caa:	68 bc 2b 80 00       	push   $0x802bbc
  800caf:	e8 64 f5 ff ff       	call   800218 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cb4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb7:	5b                   	pop    %ebx
  800cb8:	5e                   	pop    %esi
  800cb9:	5f                   	pop    %edi
  800cba:	5d                   	pop    %ebp
  800cbb:	c3                   	ret    

00800cbc <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cbc:	55                   	push   %ebp
  800cbd:	89 e5                	mov    %esp,%ebp
  800cbf:	57                   	push   %edi
  800cc0:	56                   	push   %esi
  800cc1:	53                   	push   %ebx
  800cc2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc5:	b8 05 00 00 00       	mov    $0x5,%eax
  800cca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccd:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cd3:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cd6:	8b 75 18             	mov    0x18(%ebp),%esi
  800cd9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cdb:	85 c0                	test   %eax,%eax
  800cdd:	7e 17                	jle    800cf6 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cdf:	83 ec 0c             	sub    $0xc,%esp
  800ce2:	50                   	push   %eax
  800ce3:	6a 05                	push   $0x5
  800ce5:	68 9f 2b 80 00       	push   $0x802b9f
  800cea:	6a 23                	push   $0x23
  800cec:	68 bc 2b 80 00       	push   $0x802bbc
  800cf1:	e8 22 f5 ff ff       	call   800218 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cf6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf9:	5b                   	pop    %ebx
  800cfa:	5e                   	pop    %esi
  800cfb:	5f                   	pop    %edi
  800cfc:	5d                   	pop    %ebp
  800cfd:	c3                   	ret    

00800cfe <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cfe:	55                   	push   %ebp
  800cff:	89 e5                	mov    %esp,%ebp
  800d01:	57                   	push   %edi
  800d02:	56                   	push   %esi
  800d03:	53                   	push   %ebx
  800d04:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d07:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d0c:	b8 06 00 00 00       	mov    $0x6,%eax
  800d11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d14:	8b 55 08             	mov    0x8(%ebp),%edx
  800d17:	89 df                	mov    %ebx,%edi
  800d19:	89 de                	mov    %ebx,%esi
  800d1b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d1d:	85 c0                	test   %eax,%eax
  800d1f:	7e 17                	jle    800d38 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d21:	83 ec 0c             	sub    $0xc,%esp
  800d24:	50                   	push   %eax
  800d25:	6a 06                	push   $0x6
  800d27:	68 9f 2b 80 00       	push   $0x802b9f
  800d2c:	6a 23                	push   $0x23
  800d2e:	68 bc 2b 80 00       	push   $0x802bbc
  800d33:	e8 e0 f4 ff ff       	call   800218 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d38:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3b:	5b                   	pop    %ebx
  800d3c:	5e                   	pop    %esi
  800d3d:	5f                   	pop    %edi
  800d3e:	5d                   	pop    %ebp
  800d3f:	c3                   	ret    

00800d40 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d40:	55                   	push   %ebp
  800d41:	89 e5                	mov    %esp,%ebp
  800d43:	57                   	push   %edi
  800d44:	56                   	push   %esi
  800d45:	53                   	push   %ebx
  800d46:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d49:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d4e:	b8 08 00 00 00       	mov    $0x8,%eax
  800d53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d56:	8b 55 08             	mov    0x8(%ebp),%edx
  800d59:	89 df                	mov    %ebx,%edi
  800d5b:	89 de                	mov    %ebx,%esi
  800d5d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d5f:	85 c0                	test   %eax,%eax
  800d61:	7e 17                	jle    800d7a <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d63:	83 ec 0c             	sub    $0xc,%esp
  800d66:	50                   	push   %eax
  800d67:	6a 08                	push   $0x8
  800d69:	68 9f 2b 80 00       	push   $0x802b9f
  800d6e:	6a 23                	push   $0x23
  800d70:	68 bc 2b 80 00       	push   $0x802bbc
  800d75:	e8 9e f4 ff ff       	call   800218 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7d:	5b                   	pop    %ebx
  800d7e:	5e                   	pop    %esi
  800d7f:	5f                   	pop    %edi
  800d80:	5d                   	pop    %ebp
  800d81:	c3                   	ret    

00800d82 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d82:	55                   	push   %ebp
  800d83:	89 e5                	mov    %esp,%ebp
  800d85:	57                   	push   %edi
  800d86:	56                   	push   %esi
  800d87:	53                   	push   %ebx
  800d88:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d90:	b8 09 00 00 00       	mov    $0x9,%eax
  800d95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d98:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9b:	89 df                	mov    %ebx,%edi
  800d9d:	89 de                	mov    %ebx,%esi
  800d9f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800da1:	85 c0                	test   %eax,%eax
  800da3:	7e 17                	jle    800dbc <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da5:	83 ec 0c             	sub    $0xc,%esp
  800da8:	50                   	push   %eax
  800da9:	6a 09                	push   $0x9
  800dab:	68 9f 2b 80 00       	push   $0x802b9f
  800db0:	6a 23                	push   $0x23
  800db2:	68 bc 2b 80 00       	push   $0x802bbc
  800db7:	e8 5c f4 ff ff       	call   800218 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800dbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dbf:	5b                   	pop    %ebx
  800dc0:	5e                   	pop    %esi
  800dc1:	5f                   	pop    %edi
  800dc2:	5d                   	pop    %ebp
  800dc3:	c3                   	ret    

00800dc4 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dc4:	55                   	push   %ebp
  800dc5:	89 e5                	mov    %esp,%ebp
  800dc7:	57                   	push   %edi
  800dc8:	56                   	push   %esi
  800dc9:	53                   	push   %ebx
  800dca:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dcd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dd2:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dda:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddd:	89 df                	mov    %ebx,%edi
  800ddf:	89 de                	mov    %ebx,%esi
  800de1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800de3:	85 c0                	test   %eax,%eax
  800de5:	7e 17                	jle    800dfe <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de7:	83 ec 0c             	sub    $0xc,%esp
  800dea:	50                   	push   %eax
  800deb:	6a 0a                	push   $0xa
  800ded:	68 9f 2b 80 00       	push   $0x802b9f
  800df2:	6a 23                	push   $0x23
  800df4:	68 bc 2b 80 00       	push   $0x802bbc
  800df9:	e8 1a f4 ff ff       	call   800218 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e01:	5b                   	pop    %ebx
  800e02:	5e                   	pop    %esi
  800e03:	5f                   	pop    %edi
  800e04:	5d                   	pop    %ebp
  800e05:	c3                   	ret    

00800e06 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e06:	55                   	push   %ebp
  800e07:	89 e5                	mov    %esp,%ebp
  800e09:	57                   	push   %edi
  800e0a:	56                   	push   %esi
  800e0b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0c:	be 00 00 00 00       	mov    $0x0,%esi
  800e11:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e19:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e1f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e22:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e24:	5b                   	pop    %ebx
  800e25:	5e                   	pop    %esi
  800e26:	5f                   	pop    %edi
  800e27:	5d                   	pop    %ebp
  800e28:	c3                   	ret    

00800e29 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e29:	55                   	push   %ebp
  800e2a:	89 e5                	mov    %esp,%ebp
  800e2c:	57                   	push   %edi
  800e2d:	56                   	push   %esi
  800e2e:	53                   	push   %ebx
  800e2f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e32:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e37:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3f:	89 cb                	mov    %ecx,%ebx
  800e41:	89 cf                	mov    %ecx,%edi
  800e43:	89 ce                	mov    %ecx,%esi
  800e45:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e47:	85 c0                	test   %eax,%eax
  800e49:	7e 17                	jle    800e62 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e4b:	83 ec 0c             	sub    $0xc,%esp
  800e4e:	50                   	push   %eax
  800e4f:	6a 0d                	push   $0xd
  800e51:	68 9f 2b 80 00       	push   $0x802b9f
  800e56:	6a 23                	push   $0x23
  800e58:	68 bc 2b 80 00       	push   $0x802bbc
  800e5d:	e8 b6 f3 ff ff       	call   800218 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e62:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e65:	5b                   	pop    %ebx
  800e66:	5e                   	pop    %esi
  800e67:	5f                   	pop    %edi
  800e68:	5d                   	pop    %ebp
  800e69:	c3                   	ret    

00800e6a <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e6a:	55                   	push   %ebp
  800e6b:	89 e5                	mov    %esp,%ebp
  800e6d:	57                   	push   %edi
  800e6e:	56                   	push   %esi
  800e6f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e70:	ba 00 00 00 00       	mov    $0x0,%edx
  800e75:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e7a:	89 d1                	mov    %edx,%ecx
  800e7c:	89 d3                	mov    %edx,%ebx
  800e7e:	89 d7                	mov    %edx,%edi
  800e80:	89 d6                	mov    %edx,%esi
  800e82:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e84:	5b                   	pop    %ebx
  800e85:	5e                   	pop    %esi
  800e86:	5f                   	pop    %edi
  800e87:	5d                   	pop    %ebp
  800e88:	c3                   	ret    

00800e89 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800e89:	55                   	push   %ebp
  800e8a:	89 e5                	mov    %esp,%ebp
  800e8c:	53                   	push   %ebx
  800e8d:	83 ec 04             	sub    $0x4,%esp
	int r;
	void * address = (void *)(pn*PGSIZE);
  800e90:	89 d3                	mov    %edx,%ebx
  800e92:	c1 e3 0c             	shl    $0xc,%ebx
	
	if((uvpt[pn] & PTE_SHARE))
  800e95:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800e9c:	f6 c5 04             	test   $0x4,%ch
  800e9f:	74 38                	je     800ed9 <duppage+0x50>
	{
		if ((r = sys_page_map(0, address, envid, address, (uvpt[pn] | PTE_SYSCALL))) < 0)
  800ea1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ea8:	83 ec 0c             	sub    $0xc,%esp
  800eab:	81 ca 07 0e 00 00    	or     $0xe07,%edx
  800eb1:	52                   	push   %edx
  800eb2:	53                   	push   %ebx
  800eb3:	50                   	push   %eax
  800eb4:	53                   	push   %ebx
  800eb5:	6a 00                	push   $0x0
  800eb7:	e8 00 fe ff ff       	call   800cbc <sys_page_map>
  800ebc:	83 c4 20             	add    $0x20,%esp
  800ebf:	85 c0                	test   %eax,%eax
  800ec1:	0f 89 b8 00 00 00    	jns    800f7f <duppage+0xf6>
			panic("sys_page_map: %e", r);
  800ec7:	50                   	push   %eax
  800ec8:	68 ca 2b 80 00       	push   $0x802bca
  800ecd:	6a 4e                	push   $0x4e
  800ecf:	68 db 2b 80 00       	push   $0x802bdb
  800ed4:	e8 3f f3 ff ff       	call   800218 <_panic>
	}
	else if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW))
  800ed9:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800ee0:	f6 c1 02             	test   $0x2,%cl
  800ee3:	75 0c                	jne    800ef1 <duppage+0x68>
  800ee5:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800eec:	f6 c5 08             	test   $0x8,%ch
  800eef:	74 57                	je     800f48 <duppage+0xbf>
	{
		int perm = 0;
		perm |= PTE_P|PTE_U|PTE_COW;
	
		if ((r = sys_page_map(0, address, envid, address, perm)) < 0)
  800ef1:	83 ec 0c             	sub    $0xc,%esp
  800ef4:	68 05 08 00 00       	push   $0x805
  800ef9:	53                   	push   %ebx
  800efa:	50                   	push   %eax
  800efb:	53                   	push   %ebx
  800efc:	6a 00                	push   $0x0
  800efe:	e8 b9 fd ff ff       	call   800cbc <sys_page_map>
  800f03:	83 c4 20             	add    $0x20,%esp
  800f06:	85 c0                	test   %eax,%eax
  800f08:	79 12                	jns    800f1c <duppage+0x93>
			panic("sys_page_map: %e", r);
  800f0a:	50                   	push   %eax
  800f0b:	68 ca 2b 80 00       	push   $0x802bca
  800f10:	6a 56                	push   $0x56
  800f12:	68 db 2b 80 00       	push   $0x802bdb
  800f17:	e8 fc f2 ff ff       	call   800218 <_panic>
		if ((r = sys_page_map(0, address, 0, address, perm)) < 0)
  800f1c:	83 ec 0c             	sub    $0xc,%esp
  800f1f:	68 05 08 00 00       	push   $0x805
  800f24:	53                   	push   %ebx
  800f25:	6a 00                	push   $0x0
  800f27:	53                   	push   %ebx
  800f28:	6a 00                	push   $0x0
  800f2a:	e8 8d fd ff ff       	call   800cbc <sys_page_map>
  800f2f:	83 c4 20             	add    $0x20,%esp
  800f32:	85 c0                	test   %eax,%eax
  800f34:	79 49                	jns    800f7f <duppage+0xf6>
			panic("sys_page_map: %e", r);
  800f36:	50                   	push   %eax
  800f37:	68 ca 2b 80 00       	push   $0x802bca
  800f3c:	6a 58                	push   $0x58
  800f3e:	68 db 2b 80 00       	push   $0x802bdb
  800f43:	e8 d0 f2 ff ff       	call   800218 <_panic>
	}
	else if((uvpt[pn] & ~PTE_U) == 0)
  800f48:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f4f:	f7 c2 fb ff ff ff    	test   $0xfffffffb,%edx
  800f55:	75 28                	jne    800f7f <duppage+0xf6>
	{
		//cprintf("im here");
		if ((r = sys_page_map(0, address, envid, address, PTE_P|PTE_U)) < 0)
  800f57:	83 ec 0c             	sub    $0xc,%esp
  800f5a:	6a 05                	push   $0x5
  800f5c:	53                   	push   %ebx
  800f5d:	50                   	push   %eax
  800f5e:	53                   	push   %ebx
  800f5f:	6a 00                	push   $0x0
  800f61:	e8 56 fd ff ff       	call   800cbc <sys_page_map>
  800f66:	83 c4 20             	add    $0x20,%esp
  800f69:	85 c0                	test   %eax,%eax
  800f6b:	79 12                	jns    800f7f <duppage+0xf6>
			panic("sys_page_map: %e", r);	
  800f6d:	50                   	push   %eax
  800f6e:	68 ca 2b 80 00       	push   $0x802bca
  800f73:	6a 5e                	push   $0x5e
  800f75:	68 db 2b 80 00       	push   $0x802bdb
  800f7a:	e8 99 f2 ff ff       	call   800218 <_panic>
	}
	return 0;
}
  800f7f:	b8 00 00 00 00       	mov    $0x0,%eax
  800f84:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f87:	c9                   	leave  
  800f88:	c3                   	ret    

00800f89 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f89:	55                   	push   %ebp
  800f8a:	89 e5                	mov    %esp,%ebp
  800f8c:	53                   	push   %ebx
  800f8d:	83 ec 08             	sub    $0x8,%esp
	void *addr = (void *) utf->utf_fault_va;
  800f90:	8b 45 08             	mov    0x8(%ebp),%eax
  800f93:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	unsigned pn = ((uint32_t)addr)/PGSIZE;
  800f95:	89 d8                	mov    %ebx,%eax
  800f97:	c1 e8 0c             	shr    $0xc,%eax
	pte_t pte = uvpt[pn];
  800f9a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// Allocate a new page, mapped at temp location
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  800fa1:	6a 07                	push   $0x7
  800fa3:	68 00 f0 7f 00       	push   $0x7ff000
  800fa8:	6a 00                	push   $0x0
  800faa:	e8 ca fc ff ff       	call   800c79 <sys_page_alloc>
  800faf:	83 c4 10             	add    $0x10,%esp
  800fb2:	85 c0                	test   %eax,%eax
  800fb4:	79 12                	jns    800fc8 <pgfault+0x3f>
		panic("sys_page_alloc: %e", r);
  800fb6:	50                   	push   %eax
  800fb7:	68 e6 2b 80 00       	push   $0x802be6
  800fbc:	6a 2b                	push   $0x2b
  800fbe:	68 db 2b 80 00       	push   $0x802bdb
  800fc3:	e8 50 f2 ff ff       	call   800218 <_panic>

	// Copy the data from the old page to this new page
	void *addr_pgstart = (void *) ROUNDDOWN(addr, PGSIZE);
  800fc8:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr_pgstart, PGSIZE);
  800fce:	83 ec 04             	sub    $0x4,%esp
  800fd1:	68 00 10 00 00       	push   $0x1000
  800fd6:	53                   	push   %ebx
  800fd7:	68 00 f0 7f 00       	push   $0x7ff000
  800fdc:	e8 27 fa ff ff       	call   800a08 <memmove>

	// Move the new page to the old page's address
	if ((r = sys_page_map(0, PFTEMP, 0, addr_pgstart, PTE_P|PTE_U|PTE_W)) < 0)
  800fe1:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800fe8:	53                   	push   %ebx
  800fe9:	6a 00                	push   $0x0
  800feb:	68 00 f0 7f 00       	push   $0x7ff000
  800ff0:	6a 00                	push   $0x0
  800ff2:	e8 c5 fc ff ff       	call   800cbc <sys_page_map>
  800ff7:	83 c4 20             	add    $0x20,%esp
  800ffa:	85 c0                	test   %eax,%eax
  800ffc:	79 12                	jns    801010 <pgfault+0x87>
		panic("sys_page_map: %e", r);
  800ffe:	50                   	push   %eax
  800fff:	68 ca 2b 80 00       	push   $0x802bca
  801004:	6a 33                	push   $0x33
  801006:	68 db 2b 80 00       	push   $0x802bdb
  80100b:	e8 08 f2 ff ff       	call   800218 <_panic>

	// Unmap the temp location
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  801010:	83 ec 08             	sub    $0x8,%esp
  801013:	68 00 f0 7f 00       	push   $0x7ff000
  801018:	6a 00                	push   $0x0
  80101a:	e8 df fc ff ff       	call   800cfe <sys_page_unmap>
  80101f:	83 c4 10             	add    $0x10,%esp
  801022:	85 c0                	test   %eax,%eax
  801024:	79 12                	jns    801038 <pgfault+0xaf>
		panic("sys_page_unmap: %e", r);
  801026:	50                   	push   %eax
  801027:	68 f9 2b 80 00       	push   $0x802bf9
  80102c:	6a 37                	push   $0x37
  80102e:	68 db 2b 80 00       	push   $0x802bdb
  801033:	e8 e0 f1 ff ff       	call   800218 <_panic>
}
  801038:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80103b:	c9                   	leave  
  80103c:	c3                   	ret    

0080103d <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80103d:	55                   	push   %ebp
  80103e:	89 e5                	mov    %esp,%ebp
  801040:	56                   	push   %esi
  801041:	53                   	push   %ebx
  801042:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
	// Set up page fault handler
	set_pgfault_handler(&pgfault);
  801045:	68 89 0f 80 00       	push   $0x800f89
  80104a:	e8 ac 12 00 00       	call   8022fb <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  80104f:	b8 07 00 00 00       	mov    $0x7,%eax
  801054:	cd 30                	int    $0x30

	// Create child
	envid_t envid = sys_exofork();
  801056:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (envid < 0) {
  801059:	83 c4 10             	add    $0x10,%esp
  80105c:	85 c0                	test   %eax,%eax
  80105e:	79 12                	jns    801072 <fork+0x35>
		panic("sys_exofork: %e", envid);
  801060:	50                   	push   %eax
  801061:	68 0c 2c 80 00       	push   $0x802c0c
  801066:	6a 7c                	push   $0x7c
  801068:	68 db 2b 80 00       	push   $0x802bdb
  80106d:	e8 a6 f1 ff ff       	call   800218 <_panic>
		return envid;
	}
	if (envid == 0) {
  801072:	85 c0                	test   %eax,%eax
  801074:	75 1e                	jne    801094 <fork+0x57>
		// We are the child.
		thisenv = &envs[ENVX(sys_getenvid())]; // Fix thisenv
  801076:	e8 c0 fb ff ff       	call   800c3b <sys_getenvid>
  80107b:	25 ff 03 00 00       	and    $0x3ff,%eax
  801080:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801083:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801088:	a3 20 44 80 00       	mov    %eax,0x804420
		return 0;
  80108d:	b8 00 00 00 00       	mov    $0x0,%eax
  801092:	eb 7d                	jmp    801111 <fork+0xd4>

	// Set page fault handler on the child.
	// The parent needs to do it, else the child wouldn't be able to handle
	// the fault when trying to access it's stack (which happens as soon it starts)
	extern void _pgfault_upcall(void);
	sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);
  801094:	83 ec 04             	sub    $0x4,%esp
  801097:	6a 07                	push   $0x7
  801099:	68 00 f0 bf ee       	push   $0xeebff000
  80109e:	50                   	push   %eax
  80109f:	e8 d5 fb ff ff       	call   800c79 <sys_page_alloc>
	sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  8010a4:	83 c4 08             	add    $0x8,%esp
  8010a7:	68 40 23 80 00       	push   $0x802340
  8010ac:	ff 75 f4             	pushl  -0xc(%ebp)
  8010af:	e8 10 fd ff ff       	call   800dc4 <sys_env_set_pgfault_upcall>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  8010b4:	be 04 70 80 00       	mov    $0x807004,%esi
  8010b9:	c1 ee 0c             	shr    $0xc,%esi
  8010bc:	83 c4 10             	add    $0x10,%esp
  8010bf:	bb 00 08 00 00       	mov    $0x800,%ebx
  8010c4:	eb 0d                	jmp    8010d3 <fork+0x96>
		duppage(envid, pn);
  8010c6:	89 da                	mov    %ebx,%edx
  8010c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010cb:	e8 b9 fd ff ff       	call   800e89 <duppage>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  8010d0:	83 c3 01             	add    $0x1,%ebx
  8010d3:	39 f3                	cmp    %esi,%ebx
  8010d5:	76 ef                	jbe    8010c6 <fork+0x89>
	}

	// Also copy the stack we are currently running on
	// I think it should loop from ustacktop to this page, since the stack
	// can have more than 1 page
	duppage(envid, ((uint32_t) &envid)/PGSIZE);
  8010d7:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8010da:	c1 ea 0c             	shr    $0xc,%edx
  8010dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010e0:	e8 a4 fd ff ff       	call   800e89 <duppage>

	// Start the child environmnet running
	int r;
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  8010e5:	83 ec 08             	sub    $0x8,%esp
  8010e8:	6a 02                	push   $0x2
  8010ea:	ff 75 f4             	pushl  -0xc(%ebp)
  8010ed:	e8 4e fc ff ff       	call   800d40 <sys_env_set_status>
  8010f2:	83 c4 10             	add    $0x10,%esp
  8010f5:	85 c0                	test   %eax,%eax
  8010f7:	79 15                	jns    80110e <fork+0xd1>
		panic("sys_env_set_status: %e", r);
  8010f9:	50                   	push   %eax
  8010fa:	68 1c 2c 80 00       	push   $0x802c1c
  8010ff:	68 9c 00 00 00       	push   $0x9c
  801104:	68 db 2b 80 00       	push   $0x802bdb
  801109:	e8 0a f1 ff ff       	call   800218 <_panic>
		return r;
	}

	return envid;
  80110e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  801111:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801114:	5b                   	pop    %ebx
  801115:	5e                   	pop    %esi
  801116:	5d                   	pop    %ebp
  801117:	c3                   	ret    

00801118 <sfork>:

// Challenge!
int
sfork(void)
{
  801118:	55                   	push   %ebp
  801119:	89 e5                	mov    %esp,%ebp
  80111b:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80111e:	68 33 2c 80 00       	push   $0x802c33
  801123:	68 a7 00 00 00       	push   $0xa7
  801128:	68 db 2b 80 00       	push   $0x802bdb
  80112d:	e8 e6 f0 ff ff       	call   800218 <_panic>

00801132 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801132:	55                   	push   %ebp
  801133:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801135:	8b 45 08             	mov    0x8(%ebp),%eax
  801138:	05 00 00 00 30       	add    $0x30000000,%eax
  80113d:	c1 e8 0c             	shr    $0xc,%eax
}
  801140:	5d                   	pop    %ebp
  801141:	c3                   	ret    

00801142 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801142:	55                   	push   %ebp
  801143:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801145:	8b 45 08             	mov    0x8(%ebp),%eax
  801148:	05 00 00 00 30       	add    $0x30000000,%eax
  80114d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801152:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801157:	5d                   	pop    %ebp
  801158:	c3                   	ret    

00801159 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801159:	55                   	push   %ebp
  80115a:	89 e5                	mov    %esp,%ebp
  80115c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80115f:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801164:	89 c2                	mov    %eax,%edx
  801166:	c1 ea 16             	shr    $0x16,%edx
  801169:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801170:	f6 c2 01             	test   $0x1,%dl
  801173:	74 11                	je     801186 <fd_alloc+0x2d>
  801175:	89 c2                	mov    %eax,%edx
  801177:	c1 ea 0c             	shr    $0xc,%edx
  80117a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801181:	f6 c2 01             	test   $0x1,%dl
  801184:	75 09                	jne    80118f <fd_alloc+0x36>
			*fd_store = fd;
  801186:	89 01                	mov    %eax,(%ecx)
			return 0;
  801188:	b8 00 00 00 00       	mov    $0x0,%eax
  80118d:	eb 17                	jmp    8011a6 <fd_alloc+0x4d>
  80118f:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801194:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801199:	75 c9                	jne    801164 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80119b:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011a1:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011a6:	5d                   	pop    %ebp
  8011a7:	c3                   	ret    

008011a8 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011a8:	55                   	push   %ebp
  8011a9:	89 e5                	mov    %esp,%ebp
  8011ab:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011ae:	83 f8 1f             	cmp    $0x1f,%eax
  8011b1:	77 36                	ja     8011e9 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011b3:	c1 e0 0c             	shl    $0xc,%eax
  8011b6:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011bb:	89 c2                	mov    %eax,%edx
  8011bd:	c1 ea 16             	shr    $0x16,%edx
  8011c0:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011c7:	f6 c2 01             	test   $0x1,%dl
  8011ca:	74 24                	je     8011f0 <fd_lookup+0x48>
  8011cc:	89 c2                	mov    %eax,%edx
  8011ce:	c1 ea 0c             	shr    $0xc,%edx
  8011d1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011d8:	f6 c2 01             	test   $0x1,%dl
  8011db:	74 1a                	je     8011f7 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011dd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011e0:	89 02                	mov    %eax,(%edx)
	return 0;
  8011e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8011e7:	eb 13                	jmp    8011fc <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011e9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011ee:	eb 0c                	jmp    8011fc <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011f0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011f5:	eb 05                	jmp    8011fc <fd_lookup+0x54>
  8011f7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8011fc:	5d                   	pop    %ebp
  8011fd:	c3                   	ret    

008011fe <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011fe:	55                   	push   %ebp
  8011ff:	89 e5                	mov    %esp,%ebp
  801201:	83 ec 08             	sub    $0x8,%esp
  801204:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801207:	ba cc 2c 80 00       	mov    $0x802ccc,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80120c:	eb 13                	jmp    801221 <dev_lookup+0x23>
  80120e:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801211:	39 08                	cmp    %ecx,(%eax)
  801213:	75 0c                	jne    801221 <dev_lookup+0x23>
			*dev = devtab[i];
  801215:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801218:	89 01                	mov    %eax,(%ecx)
			return 0;
  80121a:	b8 00 00 00 00       	mov    $0x0,%eax
  80121f:	eb 2e                	jmp    80124f <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801221:	8b 02                	mov    (%edx),%eax
  801223:	85 c0                	test   %eax,%eax
  801225:	75 e7                	jne    80120e <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801227:	a1 20 44 80 00       	mov    0x804420,%eax
  80122c:	8b 40 48             	mov    0x48(%eax),%eax
  80122f:	83 ec 04             	sub    $0x4,%esp
  801232:	51                   	push   %ecx
  801233:	50                   	push   %eax
  801234:	68 4c 2c 80 00       	push   $0x802c4c
  801239:	e8 b3 f0 ff ff       	call   8002f1 <cprintf>
	*dev = 0;
  80123e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801241:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801247:	83 c4 10             	add    $0x10,%esp
  80124a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80124f:	c9                   	leave  
  801250:	c3                   	ret    

00801251 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801251:	55                   	push   %ebp
  801252:	89 e5                	mov    %esp,%ebp
  801254:	56                   	push   %esi
  801255:	53                   	push   %ebx
  801256:	83 ec 10             	sub    $0x10,%esp
  801259:	8b 75 08             	mov    0x8(%ebp),%esi
  80125c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80125f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801262:	50                   	push   %eax
  801263:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801269:	c1 e8 0c             	shr    $0xc,%eax
  80126c:	50                   	push   %eax
  80126d:	e8 36 ff ff ff       	call   8011a8 <fd_lookup>
  801272:	83 c4 08             	add    $0x8,%esp
  801275:	85 c0                	test   %eax,%eax
  801277:	78 05                	js     80127e <fd_close+0x2d>
	    || fd != fd2)
  801279:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80127c:	74 0c                	je     80128a <fd_close+0x39>
		return (must_exist ? r : 0);
  80127e:	84 db                	test   %bl,%bl
  801280:	ba 00 00 00 00       	mov    $0x0,%edx
  801285:	0f 44 c2             	cmove  %edx,%eax
  801288:	eb 41                	jmp    8012cb <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80128a:	83 ec 08             	sub    $0x8,%esp
  80128d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801290:	50                   	push   %eax
  801291:	ff 36                	pushl  (%esi)
  801293:	e8 66 ff ff ff       	call   8011fe <dev_lookup>
  801298:	89 c3                	mov    %eax,%ebx
  80129a:	83 c4 10             	add    $0x10,%esp
  80129d:	85 c0                	test   %eax,%eax
  80129f:	78 1a                	js     8012bb <fd_close+0x6a>
		if (dev->dev_close)
  8012a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012a4:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012a7:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012ac:	85 c0                	test   %eax,%eax
  8012ae:	74 0b                	je     8012bb <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012b0:	83 ec 0c             	sub    $0xc,%esp
  8012b3:	56                   	push   %esi
  8012b4:	ff d0                	call   *%eax
  8012b6:	89 c3                	mov    %eax,%ebx
  8012b8:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012bb:	83 ec 08             	sub    $0x8,%esp
  8012be:	56                   	push   %esi
  8012bf:	6a 00                	push   $0x0
  8012c1:	e8 38 fa ff ff       	call   800cfe <sys_page_unmap>
	return r;
  8012c6:	83 c4 10             	add    $0x10,%esp
  8012c9:	89 d8                	mov    %ebx,%eax
}
  8012cb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012ce:	5b                   	pop    %ebx
  8012cf:	5e                   	pop    %esi
  8012d0:	5d                   	pop    %ebp
  8012d1:	c3                   	ret    

008012d2 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012d2:	55                   	push   %ebp
  8012d3:	89 e5                	mov    %esp,%ebp
  8012d5:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012d8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012db:	50                   	push   %eax
  8012dc:	ff 75 08             	pushl  0x8(%ebp)
  8012df:	e8 c4 fe ff ff       	call   8011a8 <fd_lookup>
  8012e4:	83 c4 08             	add    $0x8,%esp
  8012e7:	85 c0                	test   %eax,%eax
  8012e9:	78 10                	js     8012fb <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8012eb:	83 ec 08             	sub    $0x8,%esp
  8012ee:	6a 01                	push   $0x1
  8012f0:	ff 75 f4             	pushl  -0xc(%ebp)
  8012f3:	e8 59 ff ff ff       	call   801251 <fd_close>
  8012f8:	83 c4 10             	add    $0x10,%esp
}
  8012fb:	c9                   	leave  
  8012fc:	c3                   	ret    

008012fd <close_all>:

void
close_all(void)
{
  8012fd:	55                   	push   %ebp
  8012fe:	89 e5                	mov    %esp,%ebp
  801300:	53                   	push   %ebx
  801301:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801304:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801309:	83 ec 0c             	sub    $0xc,%esp
  80130c:	53                   	push   %ebx
  80130d:	e8 c0 ff ff ff       	call   8012d2 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801312:	83 c3 01             	add    $0x1,%ebx
  801315:	83 c4 10             	add    $0x10,%esp
  801318:	83 fb 20             	cmp    $0x20,%ebx
  80131b:	75 ec                	jne    801309 <close_all+0xc>
		close(i);
}
  80131d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801320:	c9                   	leave  
  801321:	c3                   	ret    

00801322 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801322:	55                   	push   %ebp
  801323:	89 e5                	mov    %esp,%ebp
  801325:	57                   	push   %edi
  801326:	56                   	push   %esi
  801327:	53                   	push   %ebx
  801328:	83 ec 2c             	sub    $0x2c,%esp
  80132b:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80132e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801331:	50                   	push   %eax
  801332:	ff 75 08             	pushl  0x8(%ebp)
  801335:	e8 6e fe ff ff       	call   8011a8 <fd_lookup>
  80133a:	83 c4 08             	add    $0x8,%esp
  80133d:	85 c0                	test   %eax,%eax
  80133f:	0f 88 c1 00 00 00    	js     801406 <dup+0xe4>
		return r;
	close(newfdnum);
  801345:	83 ec 0c             	sub    $0xc,%esp
  801348:	56                   	push   %esi
  801349:	e8 84 ff ff ff       	call   8012d2 <close>

	newfd = INDEX2FD(newfdnum);
  80134e:	89 f3                	mov    %esi,%ebx
  801350:	c1 e3 0c             	shl    $0xc,%ebx
  801353:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801359:	83 c4 04             	add    $0x4,%esp
  80135c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80135f:	e8 de fd ff ff       	call   801142 <fd2data>
  801364:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801366:	89 1c 24             	mov    %ebx,(%esp)
  801369:	e8 d4 fd ff ff       	call   801142 <fd2data>
  80136e:	83 c4 10             	add    $0x10,%esp
  801371:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801374:	89 f8                	mov    %edi,%eax
  801376:	c1 e8 16             	shr    $0x16,%eax
  801379:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801380:	a8 01                	test   $0x1,%al
  801382:	74 37                	je     8013bb <dup+0x99>
  801384:	89 f8                	mov    %edi,%eax
  801386:	c1 e8 0c             	shr    $0xc,%eax
  801389:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801390:	f6 c2 01             	test   $0x1,%dl
  801393:	74 26                	je     8013bb <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801395:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80139c:	83 ec 0c             	sub    $0xc,%esp
  80139f:	25 07 0e 00 00       	and    $0xe07,%eax
  8013a4:	50                   	push   %eax
  8013a5:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013a8:	6a 00                	push   $0x0
  8013aa:	57                   	push   %edi
  8013ab:	6a 00                	push   $0x0
  8013ad:	e8 0a f9 ff ff       	call   800cbc <sys_page_map>
  8013b2:	89 c7                	mov    %eax,%edi
  8013b4:	83 c4 20             	add    $0x20,%esp
  8013b7:	85 c0                	test   %eax,%eax
  8013b9:	78 2e                	js     8013e9 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013bb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013be:	89 d0                	mov    %edx,%eax
  8013c0:	c1 e8 0c             	shr    $0xc,%eax
  8013c3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013ca:	83 ec 0c             	sub    $0xc,%esp
  8013cd:	25 07 0e 00 00       	and    $0xe07,%eax
  8013d2:	50                   	push   %eax
  8013d3:	53                   	push   %ebx
  8013d4:	6a 00                	push   $0x0
  8013d6:	52                   	push   %edx
  8013d7:	6a 00                	push   $0x0
  8013d9:	e8 de f8 ff ff       	call   800cbc <sys_page_map>
  8013de:	89 c7                	mov    %eax,%edi
  8013e0:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8013e3:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013e5:	85 ff                	test   %edi,%edi
  8013e7:	79 1d                	jns    801406 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013e9:	83 ec 08             	sub    $0x8,%esp
  8013ec:	53                   	push   %ebx
  8013ed:	6a 00                	push   $0x0
  8013ef:	e8 0a f9 ff ff       	call   800cfe <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013f4:	83 c4 08             	add    $0x8,%esp
  8013f7:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013fa:	6a 00                	push   $0x0
  8013fc:	e8 fd f8 ff ff       	call   800cfe <sys_page_unmap>
	return r;
  801401:	83 c4 10             	add    $0x10,%esp
  801404:	89 f8                	mov    %edi,%eax
}
  801406:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801409:	5b                   	pop    %ebx
  80140a:	5e                   	pop    %esi
  80140b:	5f                   	pop    %edi
  80140c:	5d                   	pop    %ebp
  80140d:	c3                   	ret    

0080140e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80140e:	55                   	push   %ebp
  80140f:	89 e5                	mov    %esp,%ebp
  801411:	53                   	push   %ebx
  801412:	83 ec 14             	sub    $0x14,%esp
  801415:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801418:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80141b:	50                   	push   %eax
  80141c:	53                   	push   %ebx
  80141d:	e8 86 fd ff ff       	call   8011a8 <fd_lookup>
  801422:	83 c4 08             	add    $0x8,%esp
  801425:	89 c2                	mov    %eax,%edx
  801427:	85 c0                	test   %eax,%eax
  801429:	78 6d                	js     801498 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80142b:	83 ec 08             	sub    $0x8,%esp
  80142e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801431:	50                   	push   %eax
  801432:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801435:	ff 30                	pushl  (%eax)
  801437:	e8 c2 fd ff ff       	call   8011fe <dev_lookup>
  80143c:	83 c4 10             	add    $0x10,%esp
  80143f:	85 c0                	test   %eax,%eax
  801441:	78 4c                	js     80148f <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801443:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801446:	8b 42 08             	mov    0x8(%edx),%eax
  801449:	83 e0 03             	and    $0x3,%eax
  80144c:	83 f8 01             	cmp    $0x1,%eax
  80144f:	75 21                	jne    801472 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801451:	a1 20 44 80 00       	mov    0x804420,%eax
  801456:	8b 40 48             	mov    0x48(%eax),%eax
  801459:	83 ec 04             	sub    $0x4,%esp
  80145c:	53                   	push   %ebx
  80145d:	50                   	push   %eax
  80145e:	68 90 2c 80 00       	push   $0x802c90
  801463:	e8 89 ee ff ff       	call   8002f1 <cprintf>
		return -E_INVAL;
  801468:	83 c4 10             	add    $0x10,%esp
  80146b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801470:	eb 26                	jmp    801498 <read+0x8a>
	}
	if (!dev->dev_read)
  801472:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801475:	8b 40 08             	mov    0x8(%eax),%eax
  801478:	85 c0                	test   %eax,%eax
  80147a:	74 17                	je     801493 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80147c:	83 ec 04             	sub    $0x4,%esp
  80147f:	ff 75 10             	pushl  0x10(%ebp)
  801482:	ff 75 0c             	pushl  0xc(%ebp)
  801485:	52                   	push   %edx
  801486:	ff d0                	call   *%eax
  801488:	89 c2                	mov    %eax,%edx
  80148a:	83 c4 10             	add    $0x10,%esp
  80148d:	eb 09                	jmp    801498 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80148f:	89 c2                	mov    %eax,%edx
  801491:	eb 05                	jmp    801498 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801493:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801498:	89 d0                	mov    %edx,%eax
  80149a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80149d:	c9                   	leave  
  80149e:	c3                   	ret    

0080149f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80149f:	55                   	push   %ebp
  8014a0:	89 e5                	mov    %esp,%ebp
  8014a2:	57                   	push   %edi
  8014a3:	56                   	push   %esi
  8014a4:	53                   	push   %ebx
  8014a5:	83 ec 0c             	sub    $0xc,%esp
  8014a8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014ab:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014ae:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014b3:	eb 21                	jmp    8014d6 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014b5:	83 ec 04             	sub    $0x4,%esp
  8014b8:	89 f0                	mov    %esi,%eax
  8014ba:	29 d8                	sub    %ebx,%eax
  8014bc:	50                   	push   %eax
  8014bd:	89 d8                	mov    %ebx,%eax
  8014bf:	03 45 0c             	add    0xc(%ebp),%eax
  8014c2:	50                   	push   %eax
  8014c3:	57                   	push   %edi
  8014c4:	e8 45 ff ff ff       	call   80140e <read>
		if (m < 0)
  8014c9:	83 c4 10             	add    $0x10,%esp
  8014cc:	85 c0                	test   %eax,%eax
  8014ce:	78 10                	js     8014e0 <readn+0x41>
			return m;
		if (m == 0)
  8014d0:	85 c0                	test   %eax,%eax
  8014d2:	74 0a                	je     8014de <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014d4:	01 c3                	add    %eax,%ebx
  8014d6:	39 f3                	cmp    %esi,%ebx
  8014d8:	72 db                	jb     8014b5 <readn+0x16>
  8014da:	89 d8                	mov    %ebx,%eax
  8014dc:	eb 02                	jmp    8014e0 <readn+0x41>
  8014de:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8014e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014e3:	5b                   	pop    %ebx
  8014e4:	5e                   	pop    %esi
  8014e5:	5f                   	pop    %edi
  8014e6:	5d                   	pop    %ebp
  8014e7:	c3                   	ret    

008014e8 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014e8:	55                   	push   %ebp
  8014e9:	89 e5                	mov    %esp,%ebp
  8014eb:	53                   	push   %ebx
  8014ec:	83 ec 14             	sub    $0x14,%esp
  8014ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014f2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014f5:	50                   	push   %eax
  8014f6:	53                   	push   %ebx
  8014f7:	e8 ac fc ff ff       	call   8011a8 <fd_lookup>
  8014fc:	83 c4 08             	add    $0x8,%esp
  8014ff:	89 c2                	mov    %eax,%edx
  801501:	85 c0                	test   %eax,%eax
  801503:	78 68                	js     80156d <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801505:	83 ec 08             	sub    $0x8,%esp
  801508:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80150b:	50                   	push   %eax
  80150c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80150f:	ff 30                	pushl  (%eax)
  801511:	e8 e8 fc ff ff       	call   8011fe <dev_lookup>
  801516:	83 c4 10             	add    $0x10,%esp
  801519:	85 c0                	test   %eax,%eax
  80151b:	78 47                	js     801564 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80151d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801520:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801524:	75 21                	jne    801547 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801526:	a1 20 44 80 00       	mov    0x804420,%eax
  80152b:	8b 40 48             	mov    0x48(%eax),%eax
  80152e:	83 ec 04             	sub    $0x4,%esp
  801531:	53                   	push   %ebx
  801532:	50                   	push   %eax
  801533:	68 ac 2c 80 00       	push   $0x802cac
  801538:	e8 b4 ed ff ff       	call   8002f1 <cprintf>
		return -E_INVAL;
  80153d:	83 c4 10             	add    $0x10,%esp
  801540:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801545:	eb 26                	jmp    80156d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801547:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80154a:	8b 52 0c             	mov    0xc(%edx),%edx
  80154d:	85 d2                	test   %edx,%edx
  80154f:	74 17                	je     801568 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801551:	83 ec 04             	sub    $0x4,%esp
  801554:	ff 75 10             	pushl  0x10(%ebp)
  801557:	ff 75 0c             	pushl  0xc(%ebp)
  80155a:	50                   	push   %eax
  80155b:	ff d2                	call   *%edx
  80155d:	89 c2                	mov    %eax,%edx
  80155f:	83 c4 10             	add    $0x10,%esp
  801562:	eb 09                	jmp    80156d <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801564:	89 c2                	mov    %eax,%edx
  801566:	eb 05                	jmp    80156d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801568:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80156d:	89 d0                	mov    %edx,%eax
  80156f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801572:	c9                   	leave  
  801573:	c3                   	ret    

00801574 <seek>:

int
seek(int fdnum, off_t offset)
{
  801574:	55                   	push   %ebp
  801575:	89 e5                	mov    %esp,%ebp
  801577:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80157a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80157d:	50                   	push   %eax
  80157e:	ff 75 08             	pushl  0x8(%ebp)
  801581:	e8 22 fc ff ff       	call   8011a8 <fd_lookup>
  801586:	83 c4 08             	add    $0x8,%esp
  801589:	85 c0                	test   %eax,%eax
  80158b:	78 0e                	js     80159b <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80158d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801590:	8b 55 0c             	mov    0xc(%ebp),%edx
  801593:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801596:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80159b:	c9                   	leave  
  80159c:	c3                   	ret    

0080159d <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80159d:	55                   	push   %ebp
  80159e:	89 e5                	mov    %esp,%ebp
  8015a0:	53                   	push   %ebx
  8015a1:	83 ec 14             	sub    $0x14,%esp
  8015a4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015a7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015aa:	50                   	push   %eax
  8015ab:	53                   	push   %ebx
  8015ac:	e8 f7 fb ff ff       	call   8011a8 <fd_lookup>
  8015b1:	83 c4 08             	add    $0x8,%esp
  8015b4:	89 c2                	mov    %eax,%edx
  8015b6:	85 c0                	test   %eax,%eax
  8015b8:	78 65                	js     80161f <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ba:	83 ec 08             	sub    $0x8,%esp
  8015bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015c0:	50                   	push   %eax
  8015c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015c4:	ff 30                	pushl  (%eax)
  8015c6:	e8 33 fc ff ff       	call   8011fe <dev_lookup>
  8015cb:	83 c4 10             	add    $0x10,%esp
  8015ce:	85 c0                	test   %eax,%eax
  8015d0:	78 44                	js     801616 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015d5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015d9:	75 21                	jne    8015fc <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015db:	a1 20 44 80 00       	mov    0x804420,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015e0:	8b 40 48             	mov    0x48(%eax),%eax
  8015e3:	83 ec 04             	sub    $0x4,%esp
  8015e6:	53                   	push   %ebx
  8015e7:	50                   	push   %eax
  8015e8:	68 6c 2c 80 00       	push   $0x802c6c
  8015ed:	e8 ff ec ff ff       	call   8002f1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015f2:	83 c4 10             	add    $0x10,%esp
  8015f5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015fa:	eb 23                	jmp    80161f <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8015fc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015ff:	8b 52 18             	mov    0x18(%edx),%edx
  801602:	85 d2                	test   %edx,%edx
  801604:	74 14                	je     80161a <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801606:	83 ec 08             	sub    $0x8,%esp
  801609:	ff 75 0c             	pushl  0xc(%ebp)
  80160c:	50                   	push   %eax
  80160d:	ff d2                	call   *%edx
  80160f:	89 c2                	mov    %eax,%edx
  801611:	83 c4 10             	add    $0x10,%esp
  801614:	eb 09                	jmp    80161f <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801616:	89 c2                	mov    %eax,%edx
  801618:	eb 05                	jmp    80161f <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80161a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80161f:	89 d0                	mov    %edx,%eax
  801621:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801624:	c9                   	leave  
  801625:	c3                   	ret    

00801626 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801626:	55                   	push   %ebp
  801627:	89 e5                	mov    %esp,%ebp
  801629:	53                   	push   %ebx
  80162a:	83 ec 14             	sub    $0x14,%esp
  80162d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801630:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801633:	50                   	push   %eax
  801634:	ff 75 08             	pushl  0x8(%ebp)
  801637:	e8 6c fb ff ff       	call   8011a8 <fd_lookup>
  80163c:	83 c4 08             	add    $0x8,%esp
  80163f:	89 c2                	mov    %eax,%edx
  801641:	85 c0                	test   %eax,%eax
  801643:	78 58                	js     80169d <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801645:	83 ec 08             	sub    $0x8,%esp
  801648:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80164b:	50                   	push   %eax
  80164c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80164f:	ff 30                	pushl  (%eax)
  801651:	e8 a8 fb ff ff       	call   8011fe <dev_lookup>
  801656:	83 c4 10             	add    $0x10,%esp
  801659:	85 c0                	test   %eax,%eax
  80165b:	78 37                	js     801694 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80165d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801660:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801664:	74 32                	je     801698 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801666:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801669:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801670:	00 00 00 
	stat->st_isdir = 0;
  801673:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80167a:	00 00 00 
	stat->st_dev = dev;
  80167d:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801683:	83 ec 08             	sub    $0x8,%esp
  801686:	53                   	push   %ebx
  801687:	ff 75 f0             	pushl  -0x10(%ebp)
  80168a:	ff 50 14             	call   *0x14(%eax)
  80168d:	89 c2                	mov    %eax,%edx
  80168f:	83 c4 10             	add    $0x10,%esp
  801692:	eb 09                	jmp    80169d <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801694:	89 c2                	mov    %eax,%edx
  801696:	eb 05                	jmp    80169d <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801698:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80169d:	89 d0                	mov    %edx,%eax
  80169f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016a2:	c9                   	leave  
  8016a3:	c3                   	ret    

008016a4 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016a4:	55                   	push   %ebp
  8016a5:	89 e5                	mov    %esp,%ebp
  8016a7:	56                   	push   %esi
  8016a8:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016a9:	83 ec 08             	sub    $0x8,%esp
  8016ac:	6a 00                	push   $0x0
  8016ae:	ff 75 08             	pushl  0x8(%ebp)
  8016b1:	e8 0c 02 00 00       	call   8018c2 <open>
  8016b6:	89 c3                	mov    %eax,%ebx
  8016b8:	83 c4 10             	add    $0x10,%esp
  8016bb:	85 c0                	test   %eax,%eax
  8016bd:	78 1b                	js     8016da <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016bf:	83 ec 08             	sub    $0x8,%esp
  8016c2:	ff 75 0c             	pushl  0xc(%ebp)
  8016c5:	50                   	push   %eax
  8016c6:	e8 5b ff ff ff       	call   801626 <fstat>
  8016cb:	89 c6                	mov    %eax,%esi
	close(fd);
  8016cd:	89 1c 24             	mov    %ebx,(%esp)
  8016d0:	e8 fd fb ff ff       	call   8012d2 <close>
	return r;
  8016d5:	83 c4 10             	add    $0x10,%esp
  8016d8:	89 f0                	mov    %esi,%eax
}
  8016da:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016dd:	5b                   	pop    %ebx
  8016de:	5e                   	pop    %esi
  8016df:	5d                   	pop    %ebp
  8016e0:	c3                   	ret    

008016e1 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016e1:	55                   	push   %ebp
  8016e2:	89 e5                	mov    %esp,%ebp
  8016e4:	56                   	push   %esi
  8016e5:	53                   	push   %ebx
  8016e6:	89 c6                	mov    %eax,%esi
  8016e8:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016ea:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016f1:	75 12                	jne    801705 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016f3:	83 ec 0c             	sub    $0xc,%esp
  8016f6:	6a 01                	push   $0x1
  8016f8:	e8 31 0d 00 00       	call   80242e <ipc_find_env>
  8016fd:	a3 00 40 80 00       	mov    %eax,0x804000
  801702:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801705:	6a 07                	push   $0x7
  801707:	68 00 50 80 00       	push   $0x805000
  80170c:	56                   	push   %esi
  80170d:	ff 35 00 40 80 00    	pushl  0x804000
  801713:	e8 c2 0c 00 00       	call   8023da <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801718:	83 c4 0c             	add    $0xc,%esp
  80171b:	6a 00                	push   $0x0
  80171d:	53                   	push   %ebx
  80171e:	6a 00                	push   $0x0
  801720:	e8 4c 0c 00 00       	call   802371 <ipc_recv>
}
  801725:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801728:	5b                   	pop    %ebx
  801729:	5e                   	pop    %esi
  80172a:	5d                   	pop    %ebp
  80172b:	c3                   	ret    

0080172c <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80172c:	55                   	push   %ebp
  80172d:	89 e5                	mov    %esp,%ebp
  80172f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801732:	8b 45 08             	mov    0x8(%ebp),%eax
  801735:	8b 40 0c             	mov    0xc(%eax),%eax
  801738:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80173d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801740:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801745:	ba 00 00 00 00       	mov    $0x0,%edx
  80174a:	b8 02 00 00 00       	mov    $0x2,%eax
  80174f:	e8 8d ff ff ff       	call   8016e1 <fsipc>
}
  801754:	c9                   	leave  
  801755:	c3                   	ret    

00801756 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801756:	55                   	push   %ebp
  801757:	89 e5                	mov    %esp,%ebp
  801759:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80175c:	8b 45 08             	mov    0x8(%ebp),%eax
  80175f:	8b 40 0c             	mov    0xc(%eax),%eax
  801762:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801767:	ba 00 00 00 00       	mov    $0x0,%edx
  80176c:	b8 06 00 00 00       	mov    $0x6,%eax
  801771:	e8 6b ff ff ff       	call   8016e1 <fsipc>
}
  801776:	c9                   	leave  
  801777:	c3                   	ret    

00801778 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801778:	55                   	push   %ebp
  801779:	89 e5                	mov    %esp,%ebp
  80177b:	53                   	push   %ebx
  80177c:	83 ec 04             	sub    $0x4,%esp
  80177f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801782:	8b 45 08             	mov    0x8(%ebp),%eax
  801785:	8b 40 0c             	mov    0xc(%eax),%eax
  801788:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80178d:	ba 00 00 00 00       	mov    $0x0,%edx
  801792:	b8 05 00 00 00       	mov    $0x5,%eax
  801797:	e8 45 ff ff ff       	call   8016e1 <fsipc>
  80179c:	85 c0                	test   %eax,%eax
  80179e:	78 2c                	js     8017cc <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017a0:	83 ec 08             	sub    $0x8,%esp
  8017a3:	68 00 50 80 00       	push   $0x805000
  8017a8:	53                   	push   %ebx
  8017a9:	e8 c8 f0 ff ff       	call   800876 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017ae:	a1 80 50 80 00       	mov    0x805080,%eax
  8017b3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017b9:	a1 84 50 80 00       	mov    0x805084,%eax
  8017be:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017c4:	83 c4 10             	add    $0x10,%esp
  8017c7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017cf:	c9                   	leave  
  8017d0:	c3                   	ret    

008017d1 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017d1:	55                   	push   %ebp
  8017d2:	89 e5                	mov    %esp,%ebp
  8017d4:	53                   	push   %ebx
  8017d5:	83 ec 08             	sub    $0x8,%esp
  8017d8:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017db:	8b 55 08             	mov    0x8(%ebp),%edx
  8017de:	8b 52 0c             	mov    0xc(%edx),%edx
  8017e1:	89 15 00 50 80 00    	mov    %edx,0x805000
  8017e7:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8017ec:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  8017f1:	0f 46 d8             	cmovbe %eax,%ebx
	
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  8017f4:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  8017fa:	53                   	push   %ebx
  8017fb:	ff 75 0c             	pushl  0xc(%ebp)
  8017fe:	68 08 50 80 00       	push   $0x805008
  801803:	e8 00 f2 ff ff       	call   800a08 <memmove>

	
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) 
  801808:	ba 00 00 00 00       	mov    $0x0,%edx
  80180d:	b8 04 00 00 00       	mov    $0x4,%eax
  801812:	e8 ca fe ff ff       	call   8016e1 <fsipc>
  801817:	83 c4 10             	add    $0x10,%esp
  80181a:	85 c0                	test   %eax,%eax
  80181c:	78 1d                	js     80183b <devfile_write+0x6a>
		return r;
	assert(r <= n_real); 
  80181e:	39 d8                	cmp    %ebx,%eax
  801820:	76 19                	jbe    80183b <devfile_write+0x6a>
  801822:	68 e0 2c 80 00       	push   $0x802ce0
  801827:	68 ec 2c 80 00       	push   $0x802cec
  80182c:	68 a3 00 00 00       	push   $0xa3
  801831:	68 01 2d 80 00       	push   $0x802d01
  801836:	e8 dd e9 ff ff       	call   800218 <_panic>
	return r;
}
  80183b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80183e:	c9                   	leave  
  80183f:	c3                   	ret    

00801840 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801840:	55                   	push   %ebp
  801841:	89 e5                	mov    %esp,%ebp
  801843:	56                   	push   %esi
  801844:	53                   	push   %ebx
  801845:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801848:	8b 45 08             	mov    0x8(%ebp),%eax
  80184b:	8b 40 0c             	mov    0xc(%eax),%eax
  80184e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801853:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801859:	ba 00 00 00 00       	mov    $0x0,%edx
  80185e:	b8 03 00 00 00       	mov    $0x3,%eax
  801863:	e8 79 fe ff ff       	call   8016e1 <fsipc>
  801868:	89 c3                	mov    %eax,%ebx
  80186a:	85 c0                	test   %eax,%eax
  80186c:	78 4b                	js     8018b9 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80186e:	39 c6                	cmp    %eax,%esi
  801870:	73 16                	jae    801888 <devfile_read+0x48>
  801872:	68 0c 2d 80 00       	push   $0x802d0c
  801877:	68 ec 2c 80 00       	push   $0x802cec
  80187c:	6a 7c                	push   $0x7c
  80187e:	68 01 2d 80 00       	push   $0x802d01
  801883:	e8 90 e9 ff ff       	call   800218 <_panic>
	assert(r <= PGSIZE);
  801888:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80188d:	7e 16                	jle    8018a5 <devfile_read+0x65>
  80188f:	68 13 2d 80 00       	push   $0x802d13
  801894:	68 ec 2c 80 00       	push   $0x802cec
  801899:	6a 7d                	push   $0x7d
  80189b:	68 01 2d 80 00       	push   $0x802d01
  8018a0:	e8 73 e9 ff ff       	call   800218 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018a5:	83 ec 04             	sub    $0x4,%esp
  8018a8:	50                   	push   %eax
  8018a9:	68 00 50 80 00       	push   $0x805000
  8018ae:	ff 75 0c             	pushl  0xc(%ebp)
  8018b1:	e8 52 f1 ff ff       	call   800a08 <memmove>
	return r;
  8018b6:	83 c4 10             	add    $0x10,%esp
}
  8018b9:	89 d8                	mov    %ebx,%eax
  8018bb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018be:	5b                   	pop    %ebx
  8018bf:	5e                   	pop    %esi
  8018c0:	5d                   	pop    %ebp
  8018c1:	c3                   	ret    

008018c2 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018c2:	55                   	push   %ebp
  8018c3:	89 e5                	mov    %esp,%ebp
  8018c5:	53                   	push   %ebx
  8018c6:	83 ec 20             	sub    $0x20,%esp
  8018c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018cc:	53                   	push   %ebx
  8018cd:	e8 6b ef ff ff       	call   80083d <strlen>
  8018d2:	83 c4 10             	add    $0x10,%esp
  8018d5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018da:	7f 67                	jg     801943 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018dc:	83 ec 0c             	sub    $0xc,%esp
  8018df:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018e2:	50                   	push   %eax
  8018e3:	e8 71 f8 ff ff       	call   801159 <fd_alloc>
  8018e8:	83 c4 10             	add    $0x10,%esp
		return r;
  8018eb:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018ed:	85 c0                	test   %eax,%eax
  8018ef:	78 57                	js     801948 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018f1:	83 ec 08             	sub    $0x8,%esp
  8018f4:	53                   	push   %ebx
  8018f5:	68 00 50 80 00       	push   $0x805000
  8018fa:	e8 77 ef ff ff       	call   800876 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  801902:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801907:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80190a:	b8 01 00 00 00       	mov    $0x1,%eax
  80190f:	e8 cd fd ff ff       	call   8016e1 <fsipc>
  801914:	89 c3                	mov    %eax,%ebx
  801916:	83 c4 10             	add    $0x10,%esp
  801919:	85 c0                	test   %eax,%eax
  80191b:	79 14                	jns    801931 <open+0x6f>
		fd_close(fd, 0);
  80191d:	83 ec 08             	sub    $0x8,%esp
  801920:	6a 00                	push   $0x0
  801922:	ff 75 f4             	pushl  -0xc(%ebp)
  801925:	e8 27 f9 ff ff       	call   801251 <fd_close>
		return r;
  80192a:	83 c4 10             	add    $0x10,%esp
  80192d:	89 da                	mov    %ebx,%edx
  80192f:	eb 17                	jmp    801948 <open+0x86>
	}

	return fd2num(fd);
  801931:	83 ec 0c             	sub    $0xc,%esp
  801934:	ff 75 f4             	pushl  -0xc(%ebp)
  801937:	e8 f6 f7 ff ff       	call   801132 <fd2num>
  80193c:	89 c2                	mov    %eax,%edx
  80193e:	83 c4 10             	add    $0x10,%esp
  801941:	eb 05                	jmp    801948 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801943:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801948:	89 d0                	mov    %edx,%eax
  80194a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80194d:	c9                   	leave  
  80194e:	c3                   	ret    

0080194f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80194f:	55                   	push   %ebp
  801950:	89 e5                	mov    %esp,%ebp
  801952:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801955:	ba 00 00 00 00       	mov    $0x0,%edx
  80195a:	b8 08 00 00 00       	mov    $0x8,%eax
  80195f:	e8 7d fd ff ff       	call   8016e1 <fsipc>
}
  801964:	c9                   	leave  
  801965:	c3                   	ret    

00801966 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801966:	55                   	push   %ebp
  801967:	89 e5                	mov    %esp,%ebp
  801969:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  80196c:	68 1f 2d 80 00       	push   $0x802d1f
  801971:	ff 75 0c             	pushl  0xc(%ebp)
  801974:	e8 fd ee ff ff       	call   800876 <strcpy>
	return 0;
}
  801979:	b8 00 00 00 00       	mov    $0x0,%eax
  80197e:	c9                   	leave  
  80197f:	c3                   	ret    

00801980 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801980:	55                   	push   %ebp
  801981:	89 e5                	mov    %esp,%ebp
  801983:	53                   	push   %ebx
  801984:	83 ec 10             	sub    $0x10,%esp
  801987:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80198a:	53                   	push   %ebx
  80198b:	e8 d7 0a 00 00       	call   802467 <pageref>
  801990:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801993:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801998:	83 f8 01             	cmp    $0x1,%eax
  80199b:	75 10                	jne    8019ad <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  80199d:	83 ec 0c             	sub    $0xc,%esp
  8019a0:	ff 73 0c             	pushl  0xc(%ebx)
  8019a3:	e8 c0 02 00 00       	call   801c68 <nsipc_close>
  8019a8:	89 c2                	mov    %eax,%edx
  8019aa:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8019ad:	89 d0                	mov    %edx,%eax
  8019af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019b2:	c9                   	leave  
  8019b3:	c3                   	ret    

008019b4 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8019b4:	55                   	push   %ebp
  8019b5:	89 e5                	mov    %esp,%ebp
  8019b7:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8019ba:	6a 00                	push   $0x0
  8019bc:	ff 75 10             	pushl  0x10(%ebp)
  8019bf:	ff 75 0c             	pushl  0xc(%ebp)
  8019c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c5:	ff 70 0c             	pushl  0xc(%eax)
  8019c8:	e8 78 03 00 00       	call   801d45 <nsipc_send>
}
  8019cd:	c9                   	leave  
  8019ce:	c3                   	ret    

008019cf <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8019cf:	55                   	push   %ebp
  8019d0:	89 e5                	mov    %esp,%ebp
  8019d2:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8019d5:	6a 00                	push   $0x0
  8019d7:	ff 75 10             	pushl  0x10(%ebp)
  8019da:	ff 75 0c             	pushl  0xc(%ebp)
  8019dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e0:	ff 70 0c             	pushl  0xc(%eax)
  8019e3:	e8 f1 02 00 00       	call   801cd9 <nsipc_recv>
}
  8019e8:	c9                   	leave  
  8019e9:	c3                   	ret    

008019ea <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8019ea:	55                   	push   %ebp
  8019eb:	89 e5                	mov    %esp,%ebp
  8019ed:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8019f0:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8019f3:	52                   	push   %edx
  8019f4:	50                   	push   %eax
  8019f5:	e8 ae f7 ff ff       	call   8011a8 <fd_lookup>
  8019fa:	83 c4 10             	add    $0x10,%esp
  8019fd:	85 c0                	test   %eax,%eax
  8019ff:	78 17                	js     801a18 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801a01:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a04:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801a0a:	39 08                	cmp    %ecx,(%eax)
  801a0c:	75 05                	jne    801a13 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801a0e:	8b 40 0c             	mov    0xc(%eax),%eax
  801a11:	eb 05                	jmp    801a18 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801a13:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801a18:	c9                   	leave  
  801a19:	c3                   	ret    

00801a1a <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801a1a:	55                   	push   %ebp
  801a1b:	89 e5                	mov    %esp,%ebp
  801a1d:	56                   	push   %esi
  801a1e:	53                   	push   %ebx
  801a1f:	83 ec 1c             	sub    $0x1c,%esp
  801a22:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801a24:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a27:	50                   	push   %eax
  801a28:	e8 2c f7 ff ff       	call   801159 <fd_alloc>
  801a2d:	89 c3                	mov    %eax,%ebx
  801a2f:	83 c4 10             	add    $0x10,%esp
  801a32:	85 c0                	test   %eax,%eax
  801a34:	78 1b                	js     801a51 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801a36:	83 ec 04             	sub    $0x4,%esp
  801a39:	68 07 04 00 00       	push   $0x407
  801a3e:	ff 75 f4             	pushl  -0xc(%ebp)
  801a41:	6a 00                	push   $0x0
  801a43:	e8 31 f2 ff ff       	call   800c79 <sys_page_alloc>
  801a48:	89 c3                	mov    %eax,%ebx
  801a4a:	83 c4 10             	add    $0x10,%esp
  801a4d:	85 c0                	test   %eax,%eax
  801a4f:	79 10                	jns    801a61 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801a51:	83 ec 0c             	sub    $0xc,%esp
  801a54:	56                   	push   %esi
  801a55:	e8 0e 02 00 00       	call   801c68 <nsipc_close>
		return r;
  801a5a:	83 c4 10             	add    $0x10,%esp
  801a5d:	89 d8                	mov    %ebx,%eax
  801a5f:	eb 24                	jmp    801a85 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801a61:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a67:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a6a:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801a6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a6f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801a76:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801a79:	83 ec 0c             	sub    $0xc,%esp
  801a7c:	50                   	push   %eax
  801a7d:	e8 b0 f6 ff ff       	call   801132 <fd2num>
  801a82:	83 c4 10             	add    $0x10,%esp
}
  801a85:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a88:	5b                   	pop    %ebx
  801a89:	5e                   	pop    %esi
  801a8a:	5d                   	pop    %ebp
  801a8b:	c3                   	ret    

00801a8c <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801a8c:	55                   	push   %ebp
  801a8d:	89 e5                	mov    %esp,%ebp
  801a8f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a92:	8b 45 08             	mov    0x8(%ebp),%eax
  801a95:	e8 50 ff ff ff       	call   8019ea <fd2sockid>
		return r;
  801a9a:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a9c:	85 c0                	test   %eax,%eax
  801a9e:	78 1f                	js     801abf <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801aa0:	83 ec 04             	sub    $0x4,%esp
  801aa3:	ff 75 10             	pushl  0x10(%ebp)
  801aa6:	ff 75 0c             	pushl  0xc(%ebp)
  801aa9:	50                   	push   %eax
  801aaa:	e8 12 01 00 00       	call   801bc1 <nsipc_accept>
  801aaf:	83 c4 10             	add    $0x10,%esp
		return r;
  801ab2:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801ab4:	85 c0                	test   %eax,%eax
  801ab6:	78 07                	js     801abf <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801ab8:	e8 5d ff ff ff       	call   801a1a <alloc_sockfd>
  801abd:	89 c1                	mov    %eax,%ecx
}
  801abf:	89 c8                	mov    %ecx,%eax
  801ac1:	c9                   	leave  
  801ac2:	c3                   	ret    

00801ac3 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801ac3:	55                   	push   %ebp
  801ac4:	89 e5                	mov    %esp,%ebp
  801ac6:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ac9:	8b 45 08             	mov    0x8(%ebp),%eax
  801acc:	e8 19 ff ff ff       	call   8019ea <fd2sockid>
  801ad1:	85 c0                	test   %eax,%eax
  801ad3:	78 12                	js     801ae7 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801ad5:	83 ec 04             	sub    $0x4,%esp
  801ad8:	ff 75 10             	pushl  0x10(%ebp)
  801adb:	ff 75 0c             	pushl  0xc(%ebp)
  801ade:	50                   	push   %eax
  801adf:	e8 2d 01 00 00       	call   801c11 <nsipc_bind>
  801ae4:	83 c4 10             	add    $0x10,%esp
}
  801ae7:	c9                   	leave  
  801ae8:	c3                   	ret    

00801ae9 <shutdown>:

int
shutdown(int s, int how)
{
  801ae9:	55                   	push   %ebp
  801aea:	89 e5                	mov    %esp,%ebp
  801aec:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801aef:	8b 45 08             	mov    0x8(%ebp),%eax
  801af2:	e8 f3 fe ff ff       	call   8019ea <fd2sockid>
  801af7:	85 c0                	test   %eax,%eax
  801af9:	78 0f                	js     801b0a <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801afb:	83 ec 08             	sub    $0x8,%esp
  801afe:	ff 75 0c             	pushl  0xc(%ebp)
  801b01:	50                   	push   %eax
  801b02:	e8 3f 01 00 00       	call   801c46 <nsipc_shutdown>
  801b07:	83 c4 10             	add    $0x10,%esp
}
  801b0a:	c9                   	leave  
  801b0b:	c3                   	ret    

00801b0c <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801b0c:	55                   	push   %ebp
  801b0d:	89 e5                	mov    %esp,%ebp
  801b0f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b12:	8b 45 08             	mov    0x8(%ebp),%eax
  801b15:	e8 d0 fe ff ff       	call   8019ea <fd2sockid>
  801b1a:	85 c0                	test   %eax,%eax
  801b1c:	78 12                	js     801b30 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801b1e:	83 ec 04             	sub    $0x4,%esp
  801b21:	ff 75 10             	pushl  0x10(%ebp)
  801b24:	ff 75 0c             	pushl  0xc(%ebp)
  801b27:	50                   	push   %eax
  801b28:	e8 55 01 00 00       	call   801c82 <nsipc_connect>
  801b2d:	83 c4 10             	add    $0x10,%esp
}
  801b30:	c9                   	leave  
  801b31:	c3                   	ret    

00801b32 <listen>:

int
listen(int s, int backlog)
{
  801b32:	55                   	push   %ebp
  801b33:	89 e5                	mov    %esp,%ebp
  801b35:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b38:	8b 45 08             	mov    0x8(%ebp),%eax
  801b3b:	e8 aa fe ff ff       	call   8019ea <fd2sockid>
  801b40:	85 c0                	test   %eax,%eax
  801b42:	78 0f                	js     801b53 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801b44:	83 ec 08             	sub    $0x8,%esp
  801b47:	ff 75 0c             	pushl  0xc(%ebp)
  801b4a:	50                   	push   %eax
  801b4b:	e8 67 01 00 00       	call   801cb7 <nsipc_listen>
  801b50:	83 c4 10             	add    $0x10,%esp
}
  801b53:	c9                   	leave  
  801b54:	c3                   	ret    

00801b55 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801b55:	55                   	push   %ebp
  801b56:	89 e5                	mov    %esp,%ebp
  801b58:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801b5b:	ff 75 10             	pushl  0x10(%ebp)
  801b5e:	ff 75 0c             	pushl  0xc(%ebp)
  801b61:	ff 75 08             	pushl  0x8(%ebp)
  801b64:	e8 3a 02 00 00       	call   801da3 <nsipc_socket>
  801b69:	83 c4 10             	add    $0x10,%esp
  801b6c:	85 c0                	test   %eax,%eax
  801b6e:	78 05                	js     801b75 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801b70:	e8 a5 fe ff ff       	call   801a1a <alloc_sockfd>
}
  801b75:	c9                   	leave  
  801b76:	c3                   	ret    

00801b77 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801b77:	55                   	push   %ebp
  801b78:	89 e5                	mov    %esp,%ebp
  801b7a:	53                   	push   %ebx
  801b7b:	83 ec 04             	sub    $0x4,%esp
  801b7e:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801b80:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801b87:	75 12                	jne    801b9b <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801b89:	83 ec 0c             	sub    $0xc,%esp
  801b8c:	6a 02                	push   $0x2
  801b8e:	e8 9b 08 00 00       	call   80242e <ipc_find_env>
  801b93:	a3 04 40 80 00       	mov    %eax,0x804004
  801b98:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801b9b:	6a 07                	push   $0x7
  801b9d:	68 00 60 80 00       	push   $0x806000
  801ba2:	53                   	push   %ebx
  801ba3:	ff 35 04 40 80 00    	pushl  0x804004
  801ba9:	e8 2c 08 00 00       	call   8023da <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801bae:	83 c4 0c             	add    $0xc,%esp
  801bb1:	6a 00                	push   $0x0
  801bb3:	6a 00                	push   $0x0
  801bb5:	6a 00                	push   $0x0
  801bb7:	e8 b5 07 00 00       	call   802371 <ipc_recv>
}
  801bbc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bbf:	c9                   	leave  
  801bc0:	c3                   	ret    

00801bc1 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801bc1:	55                   	push   %ebp
  801bc2:	89 e5                	mov    %esp,%ebp
  801bc4:	56                   	push   %esi
  801bc5:	53                   	push   %ebx
  801bc6:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801bc9:	8b 45 08             	mov    0x8(%ebp),%eax
  801bcc:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801bd1:	8b 06                	mov    (%esi),%eax
  801bd3:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801bd8:	b8 01 00 00 00       	mov    $0x1,%eax
  801bdd:	e8 95 ff ff ff       	call   801b77 <nsipc>
  801be2:	89 c3                	mov    %eax,%ebx
  801be4:	85 c0                	test   %eax,%eax
  801be6:	78 20                	js     801c08 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801be8:	83 ec 04             	sub    $0x4,%esp
  801beb:	ff 35 10 60 80 00    	pushl  0x806010
  801bf1:	68 00 60 80 00       	push   $0x806000
  801bf6:	ff 75 0c             	pushl  0xc(%ebp)
  801bf9:	e8 0a ee ff ff       	call   800a08 <memmove>
		*addrlen = ret->ret_addrlen;
  801bfe:	a1 10 60 80 00       	mov    0x806010,%eax
  801c03:	89 06                	mov    %eax,(%esi)
  801c05:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801c08:	89 d8                	mov    %ebx,%eax
  801c0a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c0d:	5b                   	pop    %ebx
  801c0e:	5e                   	pop    %esi
  801c0f:	5d                   	pop    %ebp
  801c10:	c3                   	ret    

00801c11 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c11:	55                   	push   %ebp
  801c12:	89 e5                	mov    %esp,%ebp
  801c14:	53                   	push   %ebx
  801c15:	83 ec 08             	sub    $0x8,%esp
  801c18:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801c1b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c1e:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801c23:	53                   	push   %ebx
  801c24:	ff 75 0c             	pushl  0xc(%ebp)
  801c27:	68 04 60 80 00       	push   $0x806004
  801c2c:	e8 d7 ed ff ff       	call   800a08 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801c31:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801c37:	b8 02 00 00 00       	mov    $0x2,%eax
  801c3c:	e8 36 ff ff ff       	call   801b77 <nsipc>
}
  801c41:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c44:	c9                   	leave  
  801c45:	c3                   	ret    

00801c46 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801c46:	55                   	push   %ebp
  801c47:	89 e5                	mov    %esp,%ebp
  801c49:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801c4c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c4f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801c54:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c57:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801c5c:	b8 03 00 00 00       	mov    $0x3,%eax
  801c61:	e8 11 ff ff ff       	call   801b77 <nsipc>
}
  801c66:	c9                   	leave  
  801c67:	c3                   	ret    

00801c68 <nsipc_close>:

int
nsipc_close(int s)
{
  801c68:	55                   	push   %ebp
  801c69:	89 e5                	mov    %esp,%ebp
  801c6b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801c6e:	8b 45 08             	mov    0x8(%ebp),%eax
  801c71:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801c76:	b8 04 00 00 00       	mov    $0x4,%eax
  801c7b:	e8 f7 fe ff ff       	call   801b77 <nsipc>
}
  801c80:	c9                   	leave  
  801c81:	c3                   	ret    

00801c82 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801c82:	55                   	push   %ebp
  801c83:	89 e5                	mov    %esp,%ebp
  801c85:	53                   	push   %ebx
  801c86:	83 ec 08             	sub    $0x8,%esp
  801c89:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801c8c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c8f:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801c94:	53                   	push   %ebx
  801c95:	ff 75 0c             	pushl  0xc(%ebp)
  801c98:	68 04 60 80 00       	push   $0x806004
  801c9d:	e8 66 ed ff ff       	call   800a08 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801ca2:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801ca8:	b8 05 00 00 00       	mov    $0x5,%eax
  801cad:	e8 c5 fe ff ff       	call   801b77 <nsipc>
}
  801cb2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cb5:	c9                   	leave  
  801cb6:	c3                   	ret    

00801cb7 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801cb7:	55                   	push   %ebp
  801cb8:	89 e5                	mov    %esp,%ebp
  801cba:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801cbd:	8b 45 08             	mov    0x8(%ebp),%eax
  801cc0:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801cc5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cc8:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801ccd:	b8 06 00 00 00       	mov    $0x6,%eax
  801cd2:	e8 a0 fe ff ff       	call   801b77 <nsipc>
}
  801cd7:	c9                   	leave  
  801cd8:	c3                   	ret    

00801cd9 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801cd9:	55                   	push   %ebp
  801cda:	89 e5                	mov    %esp,%ebp
  801cdc:	56                   	push   %esi
  801cdd:	53                   	push   %ebx
  801cde:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801ce1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce4:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801ce9:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801cef:	8b 45 14             	mov    0x14(%ebp),%eax
  801cf2:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801cf7:	b8 07 00 00 00       	mov    $0x7,%eax
  801cfc:	e8 76 fe ff ff       	call   801b77 <nsipc>
  801d01:	89 c3                	mov    %eax,%ebx
  801d03:	85 c0                	test   %eax,%eax
  801d05:	78 35                	js     801d3c <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801d07:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801d0c:	7f 04                	jg     801d12 <nsipc_recv+0x39>
  801d0e:	39 c6                	cmp    %eax,%esi
  801d10:	7d 16                	jge    801d28 <nsipc_recv+0x4f>
  801d12:	68 2b 2d 80 00       	push   $0x802d2b
  801d17:	68 ec 2c 80 00       	push   $0x802cec
  801d1c:	6a 62                	push   $0x62
  801d1e:	68 40 2d 80 00       	push   $0x802d40
  801d23:	e8 f0 e4 ff ff       	call   800218 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801d28:	83 ec 04             	sub    $0x4,%esp
  801d2b:	50                   	push   %eax
  801d2c:	68 00 60 80 00       	push   $0x806000
  801d31:	ff 75 0c             	pushl  0xc(%ebp)
  801d34:	e8 cf ec ff ff       	call   800a08 <memmove>
  801d39:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801d3c:	89 d8                	mov    %ebx,%eax
  801d3e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d41:	5b                   	pop    %ebx
  801d42:	5e                   	pop    %esi
  801d43:	5d                   	pop    %ebp
  801d44:	c3                   	ret    

00801d45 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801d45:	55                   	push   %ebp
  801d46:	89 e5                	mov    %esp,%ebp
  801d48:	53                   	push   %ebx
  801d49:	83 ec 04             	sub    $0x4,%esp
  801d4c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801d4f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d52:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801d57:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801d5d:	7e 16                	jle    801d75 <nsipc_send+0x30>
  801d5f:	68 4c 2d 80 00       	push   $0x802d4c
  801d64:	68 ec 2c 80 00       	push   $0x802cec
  801d69:	6a 6d                	push   $0x6d
  801d6b:	68 40 2d 80 00       	push   $0x802d40
  801d70:	e8 a3 e4 ff ff       	call   800218 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801d75:	83 ec 04             	sub    $0x4,%esp
  801d78:	53                   	push   %ebx
  801d79:	ff 75 0c             	pushl  0xc(%ebp)
  801d7c:	68 0c 60 80 00       	push   $0x80600c
  801d81:	e8 82 ec ff ff       	call   800a08 <memmove>
	nsipcbuf.send.req_size = size;
  801d86:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801d8c:	8b 45 14             	mov    0x14(%ebp),%eax
  801d8f:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801d94:	b8 08 00 00 00       	mov    $0x8,%eax
  801d99:	e8 d9 fd ff ff       	call   801b77 <nsipc>
}
  801d9e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801da1:	c9                   	leave  
  801da2:	c3                   	ret    

00801da3 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801da3:	55                   	push   %ebp
  801da4:	89 e5                	mov    %esp,%ebp
  801da6:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801da9:	8b 45 08             	mov    0x8(%ebp),%eax
  801dac:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801db1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801db4:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801db9:	8b 45 10             	mov    0x10(%ebp),%eax
  801dbc:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801dc1:	b8 09 00 00 00       	mov    $0x9,%eax
  801dc6:	e8 ac fd ff ff       	call   801b77 <nsipc>
}
  801dcb:	c9                   	leave  
  801dcc:	c3                   	ret    

00801dcd <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801dcd:	55                   	push   %ebp
  801dce:	89 e5                	mov    %esp,%ebp
  801dd0:	56                   	push   %esi
  801dd1:	53                   	push   %ebx
  801dd2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801dd5:	83 ec 0c             	sub    $0xc,%esp
  801dd8:	ff 75 08             	pushl  0x8(%ebp)
  801ddb:	e8 62 f3 ff ff       	call   801142 <fd2data>
  801de0:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801de2:	83 c4 08             	add    $0x8,%esp
  801de5:	68 58 2d 80 00       	push   $0x802d58
  801dea:	53                   	push   %ebx
  801deb:	e8 86 ea ff ff       	call   800876 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801df0:	8b 46 04             	mov    0x4(%esi),%eax
  801df3:	2b 06                	sub    (%esi),%eax
  801df5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801dfb:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801e02:	00 00 00 
	stat->st_dev = &devpipe;
  801e05:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801e0c:	30 80 00 
	return 0;
}
  801e0f:	b8 00 00 00 00       	mov    $0x0,%eax
  801e14:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e17:	5b                   	pop    %ebx
  801e18:	5e                   	pop    %esi
  801e19:	5d                   	pop    %ebp
  801e1a:	c3                   	ret    

00801e1b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801e1b:	55                   	push   %ebp
  801e1c:	89 e5                	mov    %esp,%ebp
  801e1e:	53                   	push   %ebx
  801e1f:	83 ec 0c             	sub    $0xc,%esp
  801e22:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801e25:	53                   	push   %ebx
  801e26:	6a 00                	push   $0x0
  801e28:	e8 d1 ee ff ff       	call   800cfe <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801e2d:	89 1c 24             	mov    %ebx,(%esp)
  801e30:	e8 0d f3 ff ff       	call   801142 <fd2data>
  801e35:	83 c4 08             	add    $0x8,%esp
  801e38:	50                   	push   %eax
  801e39:	6a 00                	push   $0x0
  801e3b:	e8 be ee ff ff       	call   800cfe <sys_page_unmap>
}
  801e40:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e43:	c9                   	leave  
  801e44:	c3                   	ret    

00801e45 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801e45:	55                   	push   %ebp
  801e46:	89 e5                	mov    %esp,%ebp
  801e48:	57                   	push   %edi
  801e49:	56                   	push   %esi
  801e4a:	53                   	push   %ebx
  801e4b:	83 ec 1c             	sub    $0x1c,%esp
  801e4e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801e51:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801e53:	a1 20 44 80 00       	mov    0x804420,%eax
  801e58:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801e5b:	83 ec 0c             	sub    $0xc,%esp
  801e5e:	ff 75 e0             	pushl  -0x20(%ebp)
  801e61:	e8 01 06 00 00       	call   802467 <pageref>
  801e66:	89 c3                	mov    %eax,%ebx
  801e68:	89 3c 24             	mov    %edi,(%esp)
  801e6b:	e8 f7 05 00 00       	call   802467 <pageref>
  801e70:	83 c4 10             	add    $0x10,%esp
  801e73:	39 c3                	cmp    %eax,%ebx
  801e75:	0f 94 c1             	sete   %cl
  801e78:	0f b6 c9             	movzbl %cl,%ecx
  801e7b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801e7e:	8b 15 20 44 80 00    	mov    0x804420,%edx
  801e84:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801e87:	39 ce                	cmp    %ecx,%esi
  801e89:	74 1b                	je     801ea6 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801e8b:	39 c3                	cmp    %eax,%ebx
  801e8d:	75 c4                	jne    801e53 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801e8f:	8b 42 58             	mov    0x58(%edx),%eax
  801e92:	ff 75 e4             	pushl  -0x1c(%ebp)
  801e95:	50                   	push   %eax
  801e96:	56                   	push   %esi
  801e97:	68 5f 2d 80 00       	push   $0x802d5f
  801e9c:	e8 50 e4 ff ff       	call   8002f1 <cprintf>
  801ea1:	83 c4 10             	add    $0x10,%esp
  801ea4:	eb ad                	jmp    801e53 <_pipeisclosed+0xe>
	}
}
  801ea6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ea9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801eac:	5b                   	pop    %ebx
  801ead:	5e                   	pop    %esi
  801eae:	5f                   	pop    %edi
  801eaf:	5d                   	pop    %ebp
  801eb0:	c3                   	ret    

00801eb1 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801eb1:	55                   	push   %ebp
  801eb2:	89 e5                	mov    %esp,%ebp
  801eb4:	57                   	push   %edi
  801eb5:	56                   	push   %esi
  801eb6:	53                   	push   %ebx
  801eb7:	83 ec 28             	sub    $0x28,%esp
  801eba:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801ebd:	56                   	push   %esi
  801ebe:	e8 7f f2 ff ff       	call   801142 <fd2data>
  801ec3:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ec5:	83 c4 10             	add    $0x10,%esp
  801ec8:	bf 00 00 00 00       	mov    $0x0,%edi
  801ecd:	eb 4b                	jmp    801f1a <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ecf:	89 da                	mov    %ebx,%edx
  801ed1:	89 f0                	mov    %esi,%eax
  801ed3:	e8 6d ff ff ff       	call   801e45 <_pipeisclosed>
  801ed8:	85 c0                	test   %eax,%eax
  801eda:	75 48                	jne    801f24 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801edc:	e8 79 ed ff ff       	call   800c5a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ee1:	8b 43 04             	mov    0x4(%ebx),%eax
  801ee4:	8b 0b                	mov    (%ebx),%ecx
  801ee6:	8d 51 20             	lea    0x20(%ecx),%edx
  801ee9:	39 d0                	cmp    %edx,%eax
  801eeb:	73 e2                	jae    801ecf <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801eed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ef0:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801ef4:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801ef7:	89 c2                	mov    %eax,%edx
  801ef9:	c1 fa 1f             	sar    $0x1f,%edx
  801efc:	89 d1                	mov    %edx,%ecx
  801efe:	c1 e9 1b             	shr    $0x1b,%ecx
  801f01:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801f04:	83 e2 1f             	and    $0x1f,%edx
  801f07:	29 ca                	sub    %ecx,%edx
  801f09:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801f0d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801f11:	83 c0 01             	add    $0x1,%eax
  801f14:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f17:	83 c7 01             	add    $0x1,%edi
  801f1a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801f1d:	75 c2                	jne    801ee1 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801f1f:	8b 45 10             	mov    0x10(%ebp),%eax
  801f22:	eb 05                	jmp    801f29 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f24:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801f29:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f2c:	5b                   	pop    %ebx
  801f2d:	5e                   	pop    %esi
  801f2e:	5f                   	pop    %edi
  801f2f:	5d                   	pop    %ebp
  801f30:	c3                   	ret    

00801f31 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f31:	55                   	push   %ebp
  801f32:	89 e5                	mov    %esp,%ebp
  801f34:	57                   	push   %edi
  801f35:	56                   	push   %esi
  801f36:	53                   	push   %ebx
  801f37:	83 ec 18             	sub    $0x18,%esp
  801f3a:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801f3d:	57                   	push   %edi
  801f3e:	e8 ff f1 ff ff       	call   801142 <fd2data>
  801f43:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f45:	83 c4 10             	add    $0x10,%esp
  801f48:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f4d:	eb 3d                	jmp    801f8c <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801f4f:	85 db                	test   %ebx,%ebx
  801f51:	74 04                	je     801f57 <devpipe_read+0x26>
				return i;
  801f53:	89 d8                	mov    %ebx,%eax
  801f55:	eb 44                	jmp    801f9b <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801f57:	89 f2                	mov    %esi,%edx
  801f59:	89 f8                	mov    %edi,%eax
  801f5b:	e8 e5 fe ff ff       	call   801e45 <_pipeisclosed>
  801f60:	85 c0                	test   %eax,%eax
  801f62:	75 32                	jne    801f96 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801f64:	e8 f1 ec ff ff       	call   800c5a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801f69:	8b 06                	mov    (%esi),%eax
  801f6b:	3b 46 04             	cmp    0x4(%esi),%eax
  801f6e:	74 df                	je     801f4f <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801f70:	99                   	cltd   
  801f71:	c1 ea 1b             	shr    $0x1b,%edx
  801f74:	01 d0                	add    %edx,%eax
  801f76:	83 e0 1f             	and    $0x1f,%eax
  801f79:	29 d0                	sub    %edx,%eax
  801f7b:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801f80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f83:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801f86:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f89:	83 c3 01             	add    $0x1,%ebx
  801f8c:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801f8f:	75 d8                	jne    801f69 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801f91:	8b 45 10             	mov    0x10(%ebp),%eax
  801f94:	eb 05                	jmp    801f9b <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f96:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801f9b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f9e:	5b                   	pop    %ebx
  801f9f:	5e                   	pop    %esi
  801fa0:	5f                   	pop    %edi
  801fa1:	5d                   	pop    %ebp
  801fa2:	c3                   	ret    

00801fa3 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801fa3:	55                   	push   %ebp
  801fa4:	89 e5                	mov    %esp,%ebp
  801fa6:	56                   	push   %esi
  801fa7:	53                   	push   %ebx
  801fa8:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801fab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fae:	50                   	push   %eax
  801faf:	e8 a5 f1 ff ff       	call   801159 <fd_alloc>
  801fb4:	83 c4 10             	add    $0x10,%esp
  801fb7:	89 c2                	mov    %eax,%edx
  801fb9:	85 c0                	test   %eax,%eax
  801fbb:	0f 88 2c 01 00 00    	js     8020ed <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fc1:	83 ec 04             	sub    $0x4,%esp
  801fc4:	68 07 04 00 00       	push   $0x407
  801fc9:	ff 75 f4             	pushl  -0xc(%ebp)
  801fcc:	6a 00                	push   $0x0
  801fce:	e8 a6 ec ff ff       	call   800c79 <sys_page_alloc>
  801fd3:	83 c4 10             	add    $0x10,%esp
  801fd6:	89 c2                	mov    %eax,%edx
  801fd8:	85 c0                	test   %eax,%eax
  801fda:	0f 88 0d 01 00 00    	js     8020ed <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801fe0:	83 ec 0c             	sub    $0xc,%esp
  801fe3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801fe6:	50                   	push   %eax
  801fe7:	e8 6d f1 ff ff       	call   801159 <fd_alloc>
  801fec:	89 c3                	mov    %eax,%ebx
  801fee:	83 c4 10             	add    $0x10,%esp
  801ff1:	85 c0                	test   %eax,%eax
  801ff3:	0f 88 e2 00 00 00    	js     8020db <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ff9:	83 ec 04             	sub    $0x4,%esp
  801ffc:	68 07 04 00 00       	push   $0x407
  802001:	ff 75 f0             	pushl  -0x10(%ebp)
  802004:	6a 00                	push   $0x0
  802006:	e8 6e ec ff ff       	call   800c79 <sys_page_alloc>
  80200b:	89 c3                	mov    %eax,%ebx
  80200d:	83 c4 10             	add    $0x10,%esp
  802010:	85 c0                	test   %eax,%eax
  802012:	0f 88 c3 00 00 00    	js     8020db <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802018:	83 ec 0c             	sub    $0xc,%esp
  80201b:	ff 75 f4             	pushl  -0xc(%ebp)
  80201e:	e8 1f f1 ff ff       	call   801142 <fd2data>
  802023:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802025:	83 c4 0c             	add    $0xc,%esp
  802028:	68 07 04 00 00       	push   $0x407
  80202d:	50                   	push   %eax
  80202e:	6a 00                	push   $0x0
  802030:	e8 44 ec ff ff       	call   800c79 <sys_page_alloc>
  802035:	89 c3                	mov    %eax,%ebx
  802037:	83 c4 10             	add    $0x10,%esp
  80203a:	85 c0                	test   %eax,%eax
  80203c:	0f 88 89 00 00 00    	js     8020cb <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802042:	83 ec 0c             	sub    $0xc,%esp
  802045:	ff 75 f0             	pushl  -0x10(%ebp)
  802048:	e8 f5 f0 ff ff       	call   801142 <fd2data>
  80204d:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802054:	50                   	push   %eax
  802055:	6a 00                	push   $0x0
  802057:	56                   	push   %esi
  802058:	6a 00                	push   $0x0
  80205a:	e8 5d ec ff ff       	call   800cbc <sys_page_map>
  80205f:	89 c3                	mov    %eax,%ebx
  802061:	83 c4 20             	add    $0x20,%esp
  802064:	85 c0                	test   %eax,%eax
  802066:	78 55                	js     8020bd <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802068:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80206e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802071:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802073:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802076:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80207d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802083:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802086:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802088:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80208b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802092:	83 ec 0c             	sub    $0xc,%esp
  802095:	ff 75 f4             	pushl  -0xc(%ebp)
  802098:	e8 95 f0 ff ff       	call   801132 <fd2num>
  80209d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020a0:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8020a2:	83 c4 04             	add    $0x4,%esp
  8020a5:	ff 75 f0             	pushl  -0x10(%ebp)
  8020a8:	e8 85 f0 ff ff       	call   801132 <fd2num>
  8020ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020b0:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8020b3:	83 c4 10             	add    $0x10,%esp
  8020b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8020bb:	eb 30                	jmp    8020ed <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8020bd:	83 ec 08             	sub    $0x8,%esp
  8020c0:	56                   	push   %esi
  8020c1:	6a 00                	push   $0x0
  8020c3:	e8 36 ec ff ff       	call   800cfe <sys_page_unmap>
  8020c8:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8020cb:	83 ec 08             	sub    $0x8,%esp
  8020ce:	ff 75 f0             	pushl  -0x10(%ebp)
  8020d1:	6a 00                	push   $0x0
  8020d3:	e8 26 ec ff ff       	call   800cfe <sys_page_unmap>
  8020d8:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8020db:	83 ec 08             	sub    $0x8,%esp
  8020de:	ff 75 f4             	pushl  -0xc(%ebp)
  8020e1:	6a 00                	push   $0x0
  8020e3:	e8 16 ec ff ff       	call   800cfe <sys_page_unmap>
  8020e8:	83 c4 10             	add    $0x10,%esp
  8020eb:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8020ed:	89 d0                	mov    %edx,%eax
  8020ef:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020f2:	5b                   	pop    %ebx
  8020f3:	5e                   	pop    %esi
  8020f4:	5d                   	pop    %ebp
  8020f5:	c3                   	ret    

008020f6 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8020f6:	55                   	push   %ebp
  8020f7:	89 e5                	mov    %esp,%ebp
  8020f9:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020fc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020ff:	50                   	push   %eax
  802100:	ff 75 08             	pushl  0x8(%ebp)
  802103:	e8 a0 f0 ff ff       	call   8011a8 <fd_lookup>
  802108:	83 c4 10             	add    $0x10,%esp
  80210b:	85 c0                	test   %eax,%eax
  80210d:	78 18                	js     802127 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80210f:	83 ec 0c             	sub    $0xc,%esp
  802112:	ff 75 f4             	pushl  -0xc(%ebp)
  802115:	e8 28 f0 ff ff       	call   801142 <fd2data>
	return _pipeisclosed(fd, p);
  80211a:	89 c2                	mov    %eax,%edx
  80211c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80211f:	e8 21 fd ff ff       	call   801e45 <_pipeisclosed>
  802124:	83 c4 10             	add    $0x10,%esp
}
  802127:	c9                   	leave  
  802128:	c3                   	ret    

00802129 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802129:	55                   	push   %ebp
  80212a:	89 e5                	mov    %esp,%ebp
  80212c:	56                   	push   %esi
  80212d:	53                   	push   %ebx
  80212e:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802131:	85 f6                	test   %esi,%esi
  802133:	75 16                	jne    80214b <wait+0x22>
  802135:	68 77 2d 80 00       	push   $0x802d77
  80213a:	68 ec 2c 80 00       	push   $0x802cec
  80213f:	6a 09                	push   $0x9
  802141:	68 82 2d 80 00       	push   $0x802d82
  802146:	e8 cd e0 ff ff       	call   800218 <_panic>
	e = &envs[ENVX(envid)];
  80214b:	89 f3                	mov    %esi,%ebx
  80214d:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802153:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  802156:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  80215c:	eb 05                	jmp    802163 <wait+0x3a>
		sys_yield();
  80215e:	e8 f7 ea ff ff       	call   800c5a <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802163:	8b 43 48             	mov    0x48(%ebx),%eax
  802166:	39 c6                	cmp    %eax,%esi
  802168:	75 07                	jne    802171 <wait+0x48>
  80216a:	8b 43 54             	mov    0x54(%ebx),%eax
  80216d:	85 c0                	test   %eax,%eax
  80216f:	75 ed                	jne    80215e <wait+0x35>
		sys_yield();
}
  802171:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802174:	5b                   	pop    %ebx
  802175:	5e                   	pop    %esi
  802176:	5d                   	pop    %ebp
  802177:	c3                   	ret    

00802178 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802178:	55                   	push   %ebp
  802179:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80217b:	b8 00 00 00 00       	mov    $0x0,%eax
  802180:	5d                   	pop    %ebp
  802181:	c3                   	ret    

00802182 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802182:	55                   	push   %ebp
  802183:	89 e5                	mov    %esp,%ebp
  802185:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802188:	68 8d 2d 80 00       	push   $0x802d8d
  80218d:	ff 75 0c             	pushl  0xc(%ebp)
  802190:	e8 e1 e6 ff ff       	call   800876 <strcpy>
	return 0;
}
  802195:	b8 00 00 00 00       	mov    $0x0,%eax
  80219a:	c9                   	leave  
  80219b:	c3                   	ret    

0080219c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80219c:	55                   	push   %ebp
  80219d:	89 e5                	mov    %esp,%ebp
  80219f:	57                   	push   %edi
  8021a0:	56                   	push   %esi
  8021a1:	53                   	push   %ebx
  8021a2:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021a8:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8021ad:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021b3:	eb 2d                	jmp    8021e2 <devcons_write+0x46>
		m = n - tot;
  8021b5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8021b8:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8021ba:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8021bd:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8021c2:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8021c5:	83 ec 04             	sub    $0x4,%esp
  8021c8:	53                   	push   %ebx
  8021c9:	03 45 0c             	add    0xc(%ebp),%eax
  8021cc:	50                   	push   %eax
  8021cd:	57                   	push   %edi
  8021ce:	e8 35 e8 ff ff       	call   800a08 <memmove>
		sys_cputs(buf, m);
  8021d3:	83 c4 08             	add    $0x8,%esp
  8021d6:	53                   	push   %ebx
  8021d7:	57                   	push   %edi
  8021d8:	e8 e0 e9 ff ff       	call   800bbd <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021dd:	01 de                	add    %ebx,%esi
  8021df:	83 c4 10             	add    $0x10,%esp
  8021e2:	89 f0                	mov    %esi,%eax
  8021e4:	3b 75 10             	cmp    0x10(%ebp),%esi
  8021e7:	72 cc                	jb     8021b5 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8021e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021ec:	5b                   	pop    %ebx
  8021ed:	5e                   	pop    %esi
  8021ee:	5f                   	pop    %edi
  8021ef:	5d                   	pop    %ebp
  8021f0:	c3                   	ret    

008021f1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8021f1:	55                   	push   %ebp
  8021f2:	89 e5                	mov    %esp,%ebp
  8021f4:	83 ec 08             	sub    $0x8,%esp
  8021f7:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8021fc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802200:	74 2a                	je     80222c <devcons_read+0x3b>
  802202:	eb 05                	jmp    802209 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802204:	e8 51 ea ff ff       	call   800c5a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802209:	e8 cd e9 ff ff       	call   800bdb <sys_cgetc>
  80220e:	85 c0                	test   %eax,%eax
  802210:	74 f2                	je     802204 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802212:	85 c0                	test   %eax,%eax
  802214:	78 16                	js     80222c <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802216:	83 f8 04             	cmp    $0x4,%eax
  802219:	74 0c                	je     802227 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80221b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80221e:	88 02                	mov    %al,(%edx)
	return 1;
  802220:	b8 01 00 00 00       	mov    $0x1,%eax
  802225:	eb 05                	jmp    80222c <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802227:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80222c:	c9                   	leave  
  80222d:	c3                   	ret    

0080222e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80222e:	55                   	push   %ebp
  80222f:	89 e5                	mov    %esp,%ebp
  802231:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802234:	8b 45 08             	mov    0x8(%ebp),%eax
  802237:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80223a:	6a 01                	push   $0x1
  80223c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80223f:	50                   	push   %eax
  802240:	e8 78 e9 ff ff       	call   800bbd <sys_cputs>
}
  802245:	83 c4 10             	add    $0x10,%esp
  802248:	c9                   	leave  
  802249:	c3                   	ret    

0080224a <getchar>:

int
getchar(void)
{
  80224a:	55                   	push   %ebp
  80224b:	89 e5                	mov    %esp,%ebp
  80224d:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802250:	6a 01                	push   $0x1
  802252:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802255:	50                   	push   %eax
  802256:	6a 00                	push   $0x0
  802258:	e8 b1 f1 ff ff       	call   80140e <read>
	if (r < 0)
  80225d:	83 c4 10             	add    $0x10,%esp
  802260:	85 c0                	test   %eax,%eax
  802262:	78 0f                	js     802273 <getchar+0x29>
		return r;
	if (r < 1)
  802264:	85 c0                	test   %eax,%eax
  802266:	7e 06                	jle    80226e <getchar+0x24>
		return -E_EOF;
	return c;
  802268:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80226c:	eb 05                	jmp    802273 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80226e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802273:	c9                   	leave  
  802274:	c3                   	ret    

00802275 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802275:	55                   	push   %ebp
  802276:	89 e5                	mov    %esp,%ebp
  802278:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80227b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80227e:	50                   	push   %eax
  80227f:	ff 75 08             	pushl  0x8(%ebp)
  802282:	e8 21 ef ff ff       	call   8011a8 <fd_lookup>
  802287:	83 c4 10             	add    $0x10,%esp
  80228a:	85 c0                	test   %eax,%eax
  80228c:	78 11                	js     80229f <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80228e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802291:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802297:	39 10                	cmp    %edx,(%eax)
  802299:	0f 94 c0             	sete   %al
  80229c:	0f b6 c0             	movzbl %al,%eax
}
  80229f:	c9                   	leave  
  8022a0:	c3                   	ret    

008022a1 <opencons>:

int
opencons(void)
{
  8022a1:	55                   	push   %ebp
  8022a2:	89 e5                	mov    %esp,%ebp
  8022a4:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8022a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022aa:	50                   	push   %eax
  8022ab:	e8 a9 ee ff ff       	call   801159 <fd_alloc>
  8022b0:	83 c4 10             	add    $0x10,%esp
		return r;
  8022b3:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8022b5:	85 c0                	test   %eax,%eax
  8022b7:	78 3e                	js     8022f7 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8022b9:	83 ec 04             	sub    $0x4,%esp
  8022bc:	68 07 04 00 00       	push   $0x407
  8022c1:	ff 75 f4             	pushl  -0xc(%ebp)
  8022c4:	6a 00                	push   $0x0
  8022c6:	e8 ae e9 ff ff       	call   800c79 <sys_page_alloc>
  8022cb:	83 c4 10             	add    $0x10,%esp
		return r;
  8022ce:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8022d0:	85 c0                	test   %eax,%eax
  8022d2:	78 23                	js     8022f7 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8022d4:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8022da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022dd:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8022df:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022e2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8022e9:	83 ec 0c             	sub    $0xc,%esp
  8022ec:	50                   	push   %eax
  8022ed:	e8 40 ee ff ff       	call   801132 <fd2num>
  8022f2:	89 c2                	mov    %eax,%edx
  8022f4:	83 c4 10             	add    $0x10,%esp
}
  8022f7:	89 d0                	mov    %edx,%eax
  8022f9:	c9                   	leave  
  8022fa:	c3                   	ret    

008022fb <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8022fb:	55                   	push   %ebp
  8022fc:	89 e5                	mov    %esp,%ebp
  8022fe:	53                   	push   %ebx
  8022ff:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  802302:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802309:	75 28                	jne    802333 <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  80230b:	e8 2b e9 ff ff       	call   800c3b <sys_getenvid>
  802310:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_U | PTE_W);
  802312:	83 ec 04             	sub    $0x4,%esp
  802315:	6a 06                	push   $0x6
  802317:	68 00 f0 bf ee       	push   $0xeebff000
  80231c:	50                   	push   %eax
  80231d:	e8 57 e9 ff ff       	call   800c79 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  802322:	83 c4 08             	add    $0x8,%esp
  802325:	68 40 23 80 00       	push   $0x802340
  80232a:	53                   	push   %ebx
  80232b:	e8 94 ea ff ff       	call   800dc4 <sys_env_set_pgfault_upcall>
  802330:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802333:	8b 45 08             	mov    0x8(%ebp),%eax
  802336:	a3 00 70 80 00       	mov    %eax,0x807000
}
  80233b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80233e:	c9                   	leave  
  80233f:	c3                   	ret    

00802340 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802340:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802341:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802346:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802348:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	# My method is different. Copy the values to the other stack
	# in a convinient way, and then pop everything.
	movl %esp, %ebp		# ebp refers to the exception stack
  80234b:	89 e5                	mov    %esp,%ebp
	movl 48(%ebp), %esp 	# go to other stack
  80234d:	8b 65 30             	mov    0x30(%ebp),%esp

	pushl 40(%ebp)		# eip - ORDER SWITCHED WITH EFLAGS
  802350:	ff 75 28             	pushl  0x28(%ebp)
	pushl 44(%ebp)      	# eflags
  802353:	ff 75 2c             	pushl  0x2c(%ebp)
	pushl 36(%ebp)		# all the 8 remaining regs
  802356:	ff 75 24             	pushl  0x24(%ebp)
	pushl 32(%ebp)
  802359:	ff 75 20             	pushl  0x20(%ebp)
	pushl 28(%ebp)
  80235c:	ff 75 1c             	pushl  0x1c(%ebp)
	pushl 24(%ebp)
  80235f:	ff 75 18             	pushl  0x18(%ebp)
	pushl 20(%ebp)
  802362:	ff 75 14             	pushl  0x14(%ebp)
	pushl 16(%ebp)
  802365:	ff 75 10             	pushl  0x10(%ebp)
	pushl 12(%ebp)
  802368:	ff 75 0c             	pushl  0xc(%ebp)
	pushl 8(%ebp)
  80236b:	ff 75 08             	pushl  0x8(%ebp)

	popal			# now just pop everything!
  80236e:	61                   	popa   
	popfl
  80236f:	9d                   	popf   
	ret
  802370:	c3                   	ret    

00802371 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802371:	55                   	push   %ebp
  802372:	89 e5                	mov    %esp,%ebp
  802374:	56                   	push   %esi
  802375:	53                   	push   %ebx
  802376:	8b 75 08             	mov    0x8(%ebp),%esi
  802379:	8b 45 0c             	mov    0xc(%ebp),%eax
  80237c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  80237f:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  802381:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  802386:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  802389:	83 ec 0c             	sub    $0xc,%esp
  80238c:	50                   	push   %eax
  80238d:	e8 97 ea ff ff       	call   800e29 <sys_ipc_recv>

	if (r < 0) {
  802392:	83 c4 10             	add    $0x10,%esp
  802395:	85 c0                	test   %eax,%eax
  802397:	79 16                	jns    8023af <ipc_recv+0x3e>
		if (from_env_store)
  802399:	85 f6                	test   %esi,%esi
  80239b:	74 06                	je     8023a3 <ipc_recv+0x32>
			*from_env_store = 0;
  80239d:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  8023a3:	85 db                	test   %ebx,%ebx
  8023a5:	74 2c                	je     8023d3 <ipc_recv+0x62>
			*perm_store = 0;
  8023a7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8023ad:	eb 24                	jmp    8023d3 <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  8023af:	85 f6                	test   %esi,%esi
  8023b1:	74 0a                	je     8023bd <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  8023b3:	a1 20 44 80 00       	mov    0x804420,%eax
  8023b8:	8b 40 74             	mov    0x74(%eax),%eax
  8023bb:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  8023bd:	85 db                	test   %ebx,%ebx
  8023bf:	74 0a                	je     8023cb <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  8023c1:	a1 20 44 80 00       	mov    0x804420,%eax
  8023c6:	8b 40 78             	mov    0x78(%eax),%eax
  8023c9:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  8023cb:	a1 20 44 80 00       	mov    0x804420,%eax
  8023d0:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  8023d3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8023d6:	5b                   	pop    %ebx
  8023d7:	5e                   	pop    %esi
  8023d8:	5d                   	pop    %ebp
  8023d9:	c3                   	ret    

008023da <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8023da:	55                   	push   %ebp
  8023db:	89 e5                	mov    %esp,%ebp
  8023dd:	57                   	push   %edi
  8023de:	56                   	push   %esi
  8023df:	53                   	push   %ebx
  8023e0:	83 ec 0c             	sub    $0xc,%esp
  8023e3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8023e6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8023e9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  8023ec:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  8023ee:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  8023f3:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  8023f6:	ff 75 14             	pushl  0x14(%ebp)
  8023f9:	53                   	push   %ebx
  8023fa:	56                   	push   %esi
  8023fb:	57                   	push   %edi
  8023fc:	e8 05 ea ff ff       	call   800e06 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  802401:	83 c4 10             	add    $0x10,%esp
  802404:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802407:	75 07                	jne    802410 <ipc_send+0x36>
			sys_yield();
  802409:	e8 4c e8 ff ff       	call   800c5a <sys_yield>
  80240e:	eb e6                	jmp    8023f6 <ipc_send+0x1c>
		} else if (r < 0) {
  802410:	85 c0                	test   %eax,%eax
  802412:	79 12                	jns    802426 <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  802414:	50                   	push   %eax
  802415:	68 99 2d 80 00       	push   $0x802d99
  80241a:	6a 51                	push   $0x51
  80241c:	68 a6 2d 80 00       	push   $0x802da6
  802421:	e8 f2 dd ff ff       	call   800218 <_panic>
		}
	}
}
  802426:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802429:	5b                   	pop    %ebx
  80242a:	5e                   	pop    %esi
  80242b:	5f                   	pop    %edi
  80242c:	5d                   	pop    %ebp
  80242d:	c3                   	ret    

0080242e <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80242e:	55                   	push   %ebp
  80242f:	89 e5                	mov    %esp,%ebp
  802431:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802434:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802439:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80243c:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802442:	8b 52 50             	mov    0x50(%edx),%edx
  802445:	39 ca                	cmp    %ecx,%edx
  802447:	75 0d                	jne    802456 <ipc_find_env+0x28>
			return envs[i].env_id;
  802449:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80244c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802451:	8b 40 48             	mov    0x48(%eax),%eax
  802454:	eb 0f                	jmp    802465 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802456:	83 c0 01             	add    $0x1,%eax
  802459:	3d 00 04 00 00       	cmp    $0x400,%eax
  80245e:	75 d9                	jne    802439 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802460:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802465:	5d                   	pop    %ebp
  802466:	c3                   	ret    

00802467 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802467:	55                   	push   %ebp
  802468:	89 e5                	mov    %esp,%ebp
  80246a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80246d:	89 d0                	mov    %edx,%eax
  80246f:	c1 e8 16             	shr    $0x16,%eax
  802472:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802479:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80247e:	f6 c1 01             	test   $0x1,%cl
  802481:	74 1d                	je     8024a0 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802483:	c1 ea 0c             	shr    $0xc,%edx
  802486:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80248d:	f6 c2 01             	test   $0x1,%dl
  802490:	74 0e                	je     8024a0 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802492:	c1 ea 0c             	shr    $0xc,%edx
  802495:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80249c:	ef 
  80249d:	0f b7 c0             	movzwl %ax,%eax
}
  8024a0:	5d                   	pop    %ebp
  8024a1:	c3                   	ret    
  8024a2:	66 90                	xchg   %ax,%ax
  8024a4:	66 90                	xchg   %ax,%ax
  8024a6:	66 90                	xchg   %ax,%ax
  8024a8:	66 90                	xchg   %ax,%ax
  8024aa:	66 90                	xchg   %ax,%ax
  8024ac:	66 90                	xchg   %ax,%ax
  8024ae:	66 90                	xchg   %ax,%ax

008024b0 <__udivdi3>:
  8024b0:	55                   	push   %ebp
  8024b1:	57                   	push   %edi
  8024b2:	56                   	push   %esi
  8024b3:	53                   	push   %ebx
  8024b4:	83 ec 1c             	sub    $0x1c,%esp
  8024b7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8024bb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8024bf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8024c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8024c7:	85 f6                	test   %esi,%esi
  8024c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8024cd:	89 ca                	mov    %ecx,%edx
  8024cf:	89 f8                	mov    %edi,%eax
  8024d1:	75 3d                	jne    802510 <__udivdi3+0x60>
  8024d3:	39 cf                	cmp    %ecx,%edi
  8024d5:	0f 87 c5 00 00 00    	ja     8025a0 <__udivdi3+0xf0>
  8024db:	85 ff                	test   %edi,%edi
  8024dd:	89 fd                	mov    %edi,%ebp
  8024df:	75 0b                	jne    8024ec <__udivdi3+0x3c>
  8024e1:	b8 01 00 00 00       	mov    $0x1,%eax
  8024e6:	31 d2                	xor    %edx,%edx
  8024e8:	f7 f7                	div    %edi
  8024ea:	89 c5                	mov    %eax,%ebp
  8024ec:	89 c8                	mov    %ecx,%eax
  8024ee:	31 d2                	xor    %edx,%edx
  8024f0:	f7 f5                	div    %ebp
  8024f2:	89 c1                	mov    %eax,%ecx
  8024f4:	89 d8                	mov    %ebx,%eax
  8024f6:	89 cf                	mov    %ecx,%edi
  8024f8:	f7 f5                	div    %ebp
  8024fa:	89 c3                	mov    %eax,%ebx
  8024fc:	89 d8                	mov    %ebx,%eax
  8024fe:	89 fa                	mov    %edi,%edx
  802500:	83 c4 1c             	add    $0x1c,%esp
  802503:	5b                   	pop    %ebx
  802504:	5e                   	pop    %esi
  802505:	5f                   	pop    %edi
  802506:	5d                   	pop    %ebp
  802507:	c3                   	ret    
  802508:	90                   	nop
  802509:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802510:	39 ce                	cmp    %ecx,%esi
  802512:	77 74                	ja     802588 <__udivdi3+0xd8>
  802514:	0f bd fe             	bsr    %esi,%edi
  802517:	83 f7 1f             	xor    $0x1f,%edi
  80251a:	0f 84 98 00 00 00    	je     8025b8 <__udivdi3+0x108>
  802520:	bb 20 00 00 00       	mov    $0x20,%ebx
  802525:	89 f9                	mov    %edi,%ecx
  802527:	89 c5                	mov    %eax,%ebp
  802529:	29 fb                	sub    %edi,%ebx
  80252b:	d3 e6                	shl    %cl,%esi
  80252d:	89 d9                	mov    %ebx,%ecx
  80252f:	d3 ed                	shr    %cl,%ebp
  802531:	89 f9                	mov    %edi,%ecx
  802533:	d3 e0                	shl    %cl,%eax
  802535:	09 ee                	or     %ebp,%esi
  802537:	89 d9                	mov    %ebx,%ecx
  802539:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80253d:	89 d5                	mov    %edx,%ebp
  80253f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802543:	d3 ed                	shr    %cl,%ebp
  802545:	89 f9                	mov    %edi,%ecx
  802547:	d3 e2                	shl    %cl,%edx
  802549:	89 d9                	mov    %ebx,%ecx
  80254b:	d3 e8                	shr    %cl,%eax
  80254d:	09 c2                	or     %eax,%edx
  80254f:	89 d0                	mov    %edx,%eax
  802551:	89 ea                	mov    %ebp,%edx
  802553:	f7 f6                	div    %esi
  802555:	89 d5                	mov    %edx,%ebp
  802557:	89 c3                	mov    %eax,%ebx
  802559:	f7 64 24 0c          	mull   0xc(%esp)
  80255d:	39 d5                	cmp    %edx,%ebp
  80255f:	72 10                	jb     802571 <__udivdi3+0xc1>
  802561:	8b 74 24 08          	mov    0x8(%esp),%esi
  802565:	89 f9                	mov    %edi,%ecx
  802567:	d3 e6                	shl    %cl,%esi
  802569:	39 c6                	cmp    %eax,%esi
  80256b:	73 07                	jae    802574 <__udivdi3+0xc4>
  80256d:	39 d5                	cmp    %edx,%ebp
  80256f:	75 03                	jne    802574 <__udivdi3+0xc4>
  802571:	83 eb 01             	sub    $0x1,%ebx
  802574:	31 ff                	xor    %edi,%edi
  802576:	89 d8                	mov    %ebx,%eax
  802578:	89 fa                	mov    %edi,%edx
  80257a:	83 c4 1c             	add    $0x1c,%esp
  80257d:	5b                   	pop    %ebx
  80257e:	5e                   	pop    %esi
  80257f:	5f                   	pop    %edi
  802580:	5d                   	pop    %ebp
  802581:	c3                   	ret    
  802582:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802588:	31 ff                	xor    %edi,%edi
  80258a:	31 db                	xor    %ebx,%ebx
  80258c:	89 d8                	mov    %ebx,%eax
  80258e:	89 fa                	mov    %edi,%edx
  802590:	83 c4 1c             	add    $0x1c,%esp
  802593:	5b                   	pop    %ebx
  802594:	5e                   	pop    %esi
  802595:	5f                   	pop    %edi
  802596:	5d                   	pop    %ebp
  802597:	c3                   	ret    
  802598:	90                   	nop
  802599:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025a0:	89 d8                	mov    %ebx,%eax
  8025a2:	f7 f7                	div    %edi
  8025a4:	31 ff                	xor    %edi,%edi
  8025a6:	89 c3                	mov    %eax,%ebx
  8025a8:	89 d8                	mov    %ebx,%eax
  8025aa:	89 fa                	mov    %edi,%edx
  8025ac:	83 c4 1c             	add    $0x1c,%esp
  8025af:	5b                   	pop    %ebx
  8025b0:	5e                   	pop    %esi
  8025b1:	5f                   	pop    %edi
  8025b2:	5d                   	pop    %ebp
  8025b3:	c3                   	ret    
  8025b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025b8:	39 ce                	cmp    %ecx,%esi
  8025ba:	72 0c                	jb     8025c8 <__udivdi3+0x118>
  8025bc:	31 db                	xor    %ebx,%ebx
  8025be:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8025c2:	0f 87 34 ff ff ff    	ja     8024fc <__udivdi3+0x4c>
  8025c8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8025cd:	e9 2a ff ff ff       	jmp    8024fc <__udivdi3+0x4c>
  8025d2:	66 90                	xchg   %ax,%ax
  8025d4:	66 90                	xchg   %ax,%ax
  8025d6:	66 90                	xchg   %ax,%ax
  8025d8:	66 90                	xchg   %ax,%ax
  8025da:	66 90                	xchg   %ax,%ax
  8025dc:	66 90                	xchg   %ax,%ax
  8025de:	66 90                	xchg   %ax,%ax

008025e0 <__umoddi3>:
  8025e0:	55                   	push   %ebp
  8025e1:	57                   	push   %edi
  8025e2:	56                   	push   %esi
  8025e3:	53                   	push   %ebx
  8025e4:	83 ec 1c             	sub    $0x1c,%esp
  8025e7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8025eb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8025ef:	8b 74 24 34          	mov    0x34(%esp),%esi
  8025f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8025f7:	85 d2                	test   %edx,%edx
  8025f9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8025fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802601:	89 f3                	mov    %esi,%ebx
  802603:	89 3c 24             	mov    %edi,(%esp)
  802606:	89 74 24 04          	mov    %esi,0x4(%esp)
  80260a:	75 1c                	jne    802628 <__umoddi3+0x48>
  80260c:	39 f7                	cmp    %esi,%edi
  80260e:	76 50                	jbe    802660 <__umoddi3+0x80>
  802610:	89 c8                	mov    %ecx,%eax
  802612:	89 f2                	mov    %esi,%edx
  802614:	f7 f7                	div    %edi
  802616:	89 d0                	mov    %edx,%eax
  802618:	31 d2                	xor    %edx,%edx
  80261a:	83 c4 1c             	add    $0x1c,%esp
  80261d:	5b                   	pop    %ebx
  80261e:	5e                   	pop    %esi
  80261f:	5f                   	pop    %edi
  802620:	5d                   	pop    %ebp
  802621:	c3                   	ret    
  802622:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802628:	39 f2                	cmp    %esi,%edx
  80262a:	89 d0                	mov    %edx,%eax
  80262c:	77 52                	ja     802680 <__umoddi3+0xa0>
  80262e:	0f bd ea             	bsr    %edx,%ebp
  802631:	83 f5 1f             	xor    $0x1f,%ebp
  802634:	75 5a                	jne    802690 <__umoddi3+0xb0>
  802636:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80263a:	0f 82 e0 00 00 00    	jb     802720 <__umoddi3+0x140>
  802640:	39 0c 24             	cmp    %ecx,(%esp)
  802643:	0f 86 d7 00 00 00    	jbe    802720 <__umoddi3+0x140>
  802649:	8b 44 24 08          	mov    0x8(%esp),%eax
  80264d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802651:	83 c4 1c             	add    $0x1c,%esp
  802654:	5b                   	pop    %ebx
  802655:	5e                   	pop    %esi
  802656:	5f                   	pop    %edi
  802657:	5d                   	pop    %ebp
  802658:	c3                   	ret    
  802659:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802660:	85 ff                	test   %edi,%edi
  802662:	89 fd                	mov    %edi,%ebp
  802664:	75 0b                	jne    802671 <__umoddi3+0x91>
  802666:	b8 01 00 00 00       	mov    $0x1,%eax
  80266b:	31 d2                	xor    %edx,%edx
  80266d:	f7 f7                	div    %edi
  80266f:	89 c5                	mov    %eax,%ebp
  802671:	89 f0                	mov    %esi,%eax
  802673:	31 d2                	xor    %edx,%edx
  802675:	f7 f5                	div    %ebp
  802677:	89 c8                	mov    %ecx,%eax
  802679:	f7 f5                	div    %ebp
  80267b:	89 d0                	mov    %edx,%eax
  80267d:	eb 99                	jmp    802618 <__umoddi3+0x38>
  80267f:	90                   	nop
  802680:	89 c8                	mov    %ecx,%eax
  802682:	89 f2                	mov    %esi,%edx
  802684:	83 c4 1c             	add    $0x1c,%esp
  802687:	5b                   	pop    %ebx
  802688:	5e                   	pop    %esi
  802689:	5f                   	pop    %edi
  80268a:	5d                   	pop    %ebp
  80268b:	c3                   	ret    
  80268c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802690:	8b 34 24             	mov    (%esp),%esi
  802693:	bf 20 00 00 00       	mov    $0x20,%edi
  802698:	89 e9                	mov    %ebp,%ecx
  80269a:	29 ef                	sub    %ebp,%edi
  80269c:	d3 e0                	shl    %cl,%eax
  80269e:	89 f9                	mov    %edi,%ecx
  8026a0:	89 f2                	mov    %esi,%edx
  8026a2:	d3 ea                	shr    %cl,%edx
  8026a4:	89 e9                	mov    %ebp,%ecx
  8026a6:	09 c2                	or     %eax,%edx
  8026a8:	89 d8                	mov    %ebx,%eax
  8026aa:	89 14 24             	mov    %edx,(%esp)
  8026ad:	89 f2                	mov    %esi,%edx
  8026af:	d3 e2                	shl    %cl,%edx
  8026b1:	89 f9                	mov    %edi,%ecx
  8026b3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8026b7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8026bb:	d3 e8                	shr    %cl,%eax
  8026bd:	89 e9                	mov    %ebp,%ecx
  8026bf:	89 c6                	mov    %eax,%esi
  8026c1:	d3 e3                	shl    %cl,%ebx
  8026c3:	89 f9                	mov    %edi,%ecx
  8026c5:	89 d0                	mov    %edx,%eax
  8026c7:	d3 e8                	shr    %cl,%eax
  8026c9:	89 e9                	mov    %ebp,%ecx
  8026cb:	09 d8                	or     %ebx,%eax
  8026cd:	89 d3                	mov    %edx,%ebx
  8026cf:	89 f2                	mov    %esi,%edx
  8026d1:	f7 34 24             	divl   (%esp)
  8026d4:	89 d6                	mov    %edx,%esi
  8026d6:	d3 e3                	shl    %cl,%ebx
  8026d8:	f7 64 24 04          	mull   0x4(%esp)
  8026dc:	39 d6                	cmp    %edx,%esi
  8026de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8026e2:	89 d1                	mov    %edx,%ecx
  8026e4:	89 c3                	mov    %eax,%ebx
  8026e6:	72 08                	jb     8026f0 <__umoddi3+0x110>
  8026e8:	75 11                	jne    8026fb <__umoddi3+0x11b>
  8026ea:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8026ee:	73 0b                	jae    8026fb <__umoddi3+0x11b>
  8026f0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8026f4:	1b 14 24             	sbb    (%esp),%edx
  8026f7:	89 d1                	mov    %edx,%ecx
  8026f9:	89 c3                	mov    %eax,%ebx
  8026fb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8026ff:	29 da                	sub    %ebx,%edx
  802701:	19 ce                	sbb    %ecx,%esi
  802703:	89 f9                	mov    %edi,%ecx
  802705:	89 f0                	mov    %esi,%eax
  802707:	d3 e0                	shl    %cl,%eax
  802709:	89 e9                	mov    %ebp,%ecx
  80270b:	d3 ea                	shr    %cl,%edx
  80270d:	89 e9                	mov    %ebp,%ecx
  80270f:	d3 ee                	shr    %cl,%esi
  802711:	09 d0                	or     %edx,%eax
  802713:	89 f2                	mov    %esi,%edx
  802715:	83 c4 1c             	add    $0x1c,%esp
  802718:	5b                   	pop    %ebx
  802719:	5e                   	pop    %esi
  80271a:	5f                   	pop    %edi
  80271b:	5d                   	pop    %ebp
  80271c:	c3                   	ret    
  80271d:	8d 76 00             	lea    0x0(%esi),%esi
  802720:	29 f9                	sub    %edi,%ecx
  802722:	19 d6                	sbb    %edx,%esi
  802724:	89 74 24 04          	mov    %esi,0x4(%esp)
  802728:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80272c:	e9 18 ff ff ff       	jmp    802649 <__umoddi3+0x69>
