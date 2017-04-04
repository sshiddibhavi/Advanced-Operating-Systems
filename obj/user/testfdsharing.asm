
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
  80003e:	68 60 22 80 00       	push   $0x802260
  800043:	e8 fa 17 00 00       	call   801842 <open>
  800048:	89 c3                	mov    %eax,%ebx
  80004a:	83 c4 10             	add    $0x10,%esp
  80004d:	85 c0                	test   %eax,%eax
  80004f:	79 12                	jns    800063 <umain+0x30>
		panic("open motd: %e", fd);
  800051:	50                   	push   %eax
  800052:	68 65 22 80 00       	push   $0x802265
  800057:	6a 0c                	push   $0xc
  800059:	68 73 22 80 00       	push   $0x802273
  80005e:	e8 b5 01 00 00       	call   800218 <_panic>
	seek(fd, 0);
  800063:	83 ec 08             	sub    $0x8,%esp
  800066:	6a 00                	push   $0x0
  800068:	50                   	push   %eax
  800069:	e8 86 14 00 00       	call   8014f4 <seek>
	if ((n = readn(fd, buf, sizeof buf)) <= 0)
  80006e:	83 c4 0c             	add    $0xc,%esp
  800071:	68 00 02 00 00       	push   $0x200
  800076:	68 20 42 80 00       	push   $0x804220
  80007b:	53                   	push   %ebx
  80007c:	e8 9e 13 00 00       	call   80141f <readn>
  800081:	89 c6                	mov    %eax,%esi
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	85 c0                	test   %eax,%eax
  800088:	7f 12                	jg     80009c <umain+0x69>
		panic("readn: %e", n);
  80008a:	50                   	push   %eax
  80008b:	68 88 22 80 00       	push   $0x802288
  800090:	6a 0f                	push   $0xf
  800092:	68 73 22 80 00       	push   $0x802273
  800097:	e8 7c 01 00 00       	call   800218 <_panic>

	if ((r = fork()) < 0)
  80009c:	e8 1c 0f 00 00       	call   800fbd <fork>
  8000a1:	89 c7                	mov    %eax,%edi
  8000a3:	85 c0                	test   %eax,%eax
  8000a5:	79 12                	jns    8000b9 <umain+0x86>
		panic("fork: %e", r);
  8000a7:	50                   	push   %eax
  8000a8:	68 33 27 80 00       	push   $0x802733
  8000ad:	6a 12                	push   $0x12
  8000af:	68 73 22 80 00       	push   $0x802273
  8000b4:	e8 5f 01 00 00       	call   800218 <_panic>
	if (r == 0) {
  8000b9:	85 c0                	test   %eax,%eax
  8000bb:	0f 85 9d 00 00 00    	jne    80015e <umain+0x12b>
		seek(fd, 0);
  8000c1:	83 ec 08             	sub    $0x8,%esp
  8000c4:	6a 00                	push   $0x0
  8000c6:	53                   	push   %ebx
  8000c7:	e8 28 14 00 00       	call   8014f4 <seek>
		cprintf("going to read in child (might page fault if your sharing is buggy)\n");
  8000cc:	c7 04 24 c8 22 80 00 	movl   $0x8022c8,(%esp)
  8000d3:	e8 19 02 00 00       	call   8002f1 <cprintf>
		if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  8000d8:	83 c4 0c             	add    $0xc,%esp
  8000db:	68 00 02 00 00       	push   $0x200
  8000e0:	68 20 40 80 00       	push   $0x804020
  8000e5:	53                   	push   %ebx
  8000e6:	e8 34 13 00 00       	call   80141f <readn>
  8000eb:	83 c4 10             	add    $0x10,%esp
  8000ee:	39 c6                	cmp    %eax,%esi
  8000f0:	74 16                	je     800108 <umain+0xd5>
			panic("read in parent got %d, read in child got %d", n, n2);
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	50                   	push   %eax
  8000f6:	56                   	push   %esi
  8000f7:	68 0c 23 80 00       	push   $0x80230c
  8000fc:	6a 17                	push   $0x17
  8000fe:	68 73 22 80 00       	push   $0x802273
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
  800125:	68 38 23 80 00       	push   $0x802338
  80012a:	6a 19                	push   $0x19
  80012c:	68 73 22 80 00       	push   $0x802273
  800131:	e8 e2 00 00 00       	call   800218 <_panic>
		cprintf("read in child succeeded\n");
  800136:	83 ec 0c             	sub    $0xc,%esp
  800139:	68 92 22 80 00       	push   $0x802292
  80013e:	e8 ae 01 00 00       	call   8002f1 <cprintf>
		seek(fd, 0);
  800143:	83 c4 08             	add    $0x8,%esp
  800146:	6a 00                	push   $0x0
  800148:	53                   	push   %ebx
  800149:	e8 a6 13 00 00       	call   8014f4 <seek>
		close(fd);
  80014e:	89 1c 24             	mov    %ebx,(%esp)
  800151:	e8 fc 10 00 00       	call   801252 <close>
		exit();
  800156:	e8 a3 00 00 00       	call   8001fe <exit>
  80015b:	83 c4 10             	add    $0x10,%esp
	}
	wait(r);
  80015e:	83 ec 0c             	sub    $0xc,%esp
  800161:	57                   	push   %edi
  800162:	e8 db 1a 00 00       	call   801c42 <wait>
	if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  800167:	83 c4 0c             	add    $0xc,%esp
  80016a:	68 00 02 00 00       	push   $0x200
  80016f:	68 20 40 80 00       	push   $0x804020
  800174:	53                   	push   %ebx
  800175:	e8 a5 12 00 00       	call   80141f <readn>
  80017a:	83 c4 10             	add    $0x10,%esp
  80017d:	39 c6                	cmp    %eax,%esi
  80017f:	74 16                	je     800197 <umain+0x164>
		panic("read in parent got %d, then got %d", n, n2);
  800181:	83 ec 0c             	sub    $0xc,%esp
  800184:	50                   	push   %eax
  800185:	56                   	push   %esi
  800186:	68 70 23 80 00       	push   $0x802370
  80018b:	6a 21                	push   $0x21
  80018d:	68 73 22 80 00       	push   $0x802273
  800192:	e8 81 00 00 00       	call   800218 <_panic>
	cprintf("read in parent succeeded\n");
  800197:	83 ec 0c             	sub    $0xc,%esp
  80019a:	68 ab 22 80 00       	push   $0x8022ab
  80019f:	e8 4d 01 00 00       	call   8002f1 <cprintf>
	close(fd);
  8001a4:	89 1c 24             	mov    %ebx,(%esp)
  8001a7:	e8 a6 10 00 00       	call   801252 <close>
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
  800204:	e8 74 10 00 00       	call   80127d <close_all>
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
  800236:	68 a0 23 80 00       	push   $0x8023a0
  80023b:	e8 b1 00 00 00       	call   8002f1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800240:	83 c4 18             	add    $0x18,%esp
  800243:	53                   	push   %ebx
  800244:	ff 75 10             	pushl  0x10(%ebp)
  800247:	e8 54 00 00 00       	call   8002a0 <vcprintf>
	cprintf("\n");
  80024c:	c7 04 24 a9 22 80 00 	movl   $0x8022a9,(%esp)
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
  800354:	e8 67 1c 00 00       	call   801fc0 <__udivdi3>
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
  800397:	e8 54 1d 00 00       	call   8020f0 <__umoddi3>
  80039c:	83 c4 14             	add    $0x14,%esp
  80039f:	0f be 80 c3 23 80 00 	movsbl 0x8023c3(%eax),%eax
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
  80049b:	ff 24 85 00 25 80 00 	jmp    *0x802500(,%eax,4)
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
  80055f:	8b 14 85 60 26 80 00 	mov    0x802660(,%eax,4),%edx
  800566:	85 d2                	test   %edx,%edx
  800568:	75 18                	jne    800582 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80056a:	50                   	push   %eax
  80056b:	68 db 23 80 00       	push   $0x8023db
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
  800583:	68 4e 28 80 00       	push   $0x80284e
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
  8005a7:	b8 d4 23 80 00       	mov    $0x8023d4,%eax
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
  800c22:	68 bf 26 80 00       	push   $0x8026bf
  800c27:	6a 23                	push   $0x23
  800c29:	68 dc 26 80 00       	push   $0x8026dc
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
  800ca3:	68 bf 26 80 00       	push   $0x8026bf
  800ca8:	6a 23                	push   $0x23
  800caa:	68 dc 26 80 00       	push   $0x8026dc
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
  800ce5:	68 bf 26 80 00       	push   $0x8026bf
  800cea:	6a 23                	push   $0x23
  800cec:	68 dc 26 80 00       	push   $0x8026dc
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
  800d27:	68 bf 26 80 00       	push   $0x8026bf
  800d2c:	6a 23                	push   $0x23
  800d2e:	68 dc 26 80 00       	push   $0x8026dc
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
  800d69:	68 bf 26 80 00       	push   $0x8026bf
  800d6e:	6a 23                	push   $0x23
  800d70:	68 dc 26 80 00       	push   $0x8026dc
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
  800dab:	68 bf 26 80 00       	push   $0x8026bf
  800db0:	6a 23                	push   $0x23
  800db2:	68 dc 26 80 00       	push   $0x8026dc
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
  800ded:	68 bf 26 80 00       	push   $0x8026bf
  800df2:	6a 23                	push   $0x23
  800df4:	68 dc 26 80 00       	push   $0x8026dc
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
  800e51:	68 bf 26 80 00       	push   $0x8026bf
  800e56:	6a 23                	push   $0x23
  800e58:	68 dc 26 80 00       	push   $0x8026dc
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

00800e6a <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800e6a:	55                   	push   %ebp
  800e6b:	89 e5                	mov    %esp,%ebp
  800e6d:	56                   	push   %esi
  800e6e:	53                   	push   %ebx
	int r;

	// LAB 4: Your code here.
	// Check if page is writable or COW
	pte_t pte = uvpt[pn];
  800e6f:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
	uint32_t perm = PTE_P | PTE_U;
	if (pte && (PTE_COW | PTE_W)) {
		perm |= PTE_COW;
  800e76:	83 f9 01             	cmp    $0x1,%ecx
  800e79:	19 f6                	sbb    %esi,%esi
  800e7b:	81 e6 00 f8 ff ff    	and    $0xfffff800,%esi
  800e81:	81 c6 05 08 00 00    	add    $0x805,%esi
	}

	// Map page
	void *va = (void *) (pn * PGSIZE);
  800e87:	c1 e2 0c             	shl    $0xc,%edx
  800e8a:	89 d3                	mov    %edx,%ebx
	// Map on the child
	if ((r = sys_page_map(0, va, envid, va, perm)) < 0) {
  800e8c:	83 ec 0c             	sub    $0xc,%esp
  800e8f:	56                   	push   %esi
  800e90:	52                   	push   %edx
  800e91:	50                   	push   %eax
  800e92:	52                   	push   %edx
  800e93:	6a 00                	push   $0x0
  800e95:	e8 22 fe ff ff       	call   800cbc <sys_page_map>
  800e9a:	83 c4 20             	add    $0x20,%esp
  800e9d:	85 c0                	test   %eax,%eax
  800e9f:	79 12                	jns    800eb3 <duppage+0x49>
		panic("sys_page_alloc: %e", r);
  800ea1:	50                   	push   %eax
  800ea2:	68 ea 26 80 00       	push   $0x8026ea
  800ea7:	6a 56                	push   $0x56
  800ea9:	68 fd 26 80 00       	push   $0x8026fd
  800eae:	e8 65 f3 ff ff       	call   800218 <_panic>
		return r;
	}

	// Change the permission on the parent
	if ((r = sys_page_map(0, va, 0, va, perm)) < 0) {
  800eb3:	83 ec 0c             	sub    $0xc,%esp
  800eb6:	56                   	push   %esi
  800eb7:	53                   	push   %ebx
  800eb8:	6a 00                	push   $0x0
  800eba:	53                   	push   %ebx
  800ebb:	6a 00                	push   $0x0
  800ebd:	e8 fa fd ff ff       	call   800cbc <sys_page_map>
  800ec2:	83 c4 20             	add    $0x20,%esp
  800ec5:	85 c0                	test   %eax,%eax
  800ec7:	79 12                	jns    800edb <duppage+0x71>
		panic("sys_page_alloc: %e", r);
  800ec9:	50                   	push   %eax
  800eca:	68 ea 26 80 00       	push   $0x8026ea
  800ecf:	6a 5c                	push   $0x5c
  800ed1:	68 fd 26 80 00       	push   $0x8026fd
  800ed6:	e8 3d f3 ff ff       	call   800218 <_panic>
		return r;
	}

	return 0;
}
  800edb:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ee3:	5b                   	pop    %ebx
  800ee4:	5e                   	pop    %esi
  800ee5:	5d                   	pop    %ebp
  800ee6:	c3                   	ret    

00800ee7 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ee7:	55                   	push   %ebp
  800ee8:	89 e5                	mov    %esp,%ebp
  800eea:	53                   	push   %ebx
  800eeb:	83 ec 04             	sub    $0x4,%esp
  800eee:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800ef1:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	unsigned pn = ((uint32_t)addr)/PGSIZE;
  800ef3:	89 da                	mov    %ebx,%edx
  800ef5:	c1 ea 0c             	shr    $0xc,%edx
	pte_t pte = uvpt[pn];
  800ef8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(err & FEC_WR) || !(pte & PTE_COW)) {
  800eff:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f03:	74 05                	je     800f0a <pgfault+0x23>
  800f05:	f6 c6 08             	test   $0x8,%dh
  800f08:	75 14                	jne    800f1e <pgfault+0x37>
		panic("fork pgfault handler: does not handle this fault");
  800f0a:	83 ec 04             	sub    $0x4,%esp
  800f0d:	68 6c 27 80 00       	push   $0x80276c
  800f12:	6a 1f                	push   $0x1f
  800f14:	68 fd 26 80 00       	push   $0x8026fd
  800f19:	e8 fa f2 ff ff       	call   800218 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// Allocate a new page, mapped at temp location
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  800f1e:	83 ec 04             	sub    $0x4,%esp
  800f21:	6a 07                	push   $0x7
  800f23:	68 00 f0 7f 00       	push   $0x7ff000
  800f28:	6a 00                	push   $0x0
  800f2a:	e8 4a fd ff ff       	call   800c79 <sys_page_alloc>
  800f2f:	83 c4 10             	add    $0x10,%esp
  800f32:	85 c0                	test   %eax,%eax
  800f34:	79 12                	jns    800f48 <pgfault+0x61>
		panic("sys_page_alloc: %e", r);
  800f36:	50                   	push   %eax
  800f37:	68 ea 26 80 00       	push   $0x8026ea
  800f3c:	6a 2b                	push   $0x2b
  800f3e:	68 fd 26 80 00       	push   $0x8026fd
  800f43:	e8 d0 f2 ff ff       	call   800218 <_panic>

	// Copy the data from the old page to this new page
	void *addr_pgstart = (void *) ROUNDDOWN(addr, PGSIZE);
  800f48:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr_pgstart, PGSIZE);
  800f4e:	83 ec 04             	sub    $0x4,%esp
  800f51:	68 00 10 00 00       	push   $0x1000
  800f56:	53                   	push   %ebx
  800f57:	68 00 f0 7f 00       	push   $0x7ff000
  800f5c:	e8 a7 fa ff ff       	call   800a08 <memmove>

	// Move the new page to the old page's address
	if ((r = sys_page_map(0, PFTEMP, 0, addr_pgstart, PTE_P|PTE_U|PTE_W)) < 0)
  800f61:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f68:	53                   	push   %ebx
  800f69:	6a 00                	push   $0x0
  800f6b:	68 00 f0 7f 00       	push   $0x7ff000
  800f70:	6a 00                	push   $0x0
  800f72:	e8 45 fd ff ff       	call   800cbc <sys_page_map>
  800f77:	83 c4 20             	add    $0x20,%esp
  800f7a:	85 c0                	test   %eax,%eax
  800f7c:	79 12                	jns    800f90 <pgfault+0xa9>
		panic("sys_page_map: %e", r);
  800f7e:	50                   	push   %eax
  800f7f:	68 08 27 80 00       	push   $0x802708
  800f84:	6a 33                	push   $0x33
  800f86:	68 fd 26 80 00       	push   $0x8026fd
  800f8b:	e8 88 f2 ff ff       	call   800218 <_panic>

	// Unmap the temp location
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800f90:	83 ec 08             	sub    $0x8,%esp
  800f93:	68 00 f0 7f 00       	push   $0x7ff000
  800f98:	6a 00                	push   $0x0
  800f9a:	e8 5f fd ff ff       	call   800cfe <sys_page_unmap>
  800f9f:	83 c4 10             	add    $0x10,%esp
  800fa2:	85 c0                	test   %eax,%eax
  800fa4:	79 12                	jns    800fb8 <pgfault+0xd1>
		panic("sys_page_unmap: %e", r);
  800fa6:	50                   	push   %eax
  800fa7:	68 19 27 80 00       	push   $0x802719
  800fac:	6a 37                	push   $0x37
  800fae:	68 fd 26 80 00       	push   $0x8026fd
  800fb3:	e8 60 f2 ff ff       	call   800218 <_panic>
}
  800fb8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fbb:	c9                   	leave  
  800fbc:	c3                   	ret    

00800fbd <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fbd:	55                   	push   %ebp
  800fbe:	89 e5                	mov    %esp,%ebp
  800fc0:	56                   	push   %esi
  800fc1:	53                   	push   %ebx
  800fc2:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
	// Set up page fault handler
	set_pgfault_handler(&pgfault);
  800fc5:	68 e7 0e 80 00       	push   $0x800ee7
  800fca:	e8 45 0e 00 00       	call   801e14 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800fcf:	b8 07 00 00 00       	mov    $0x7,%eax
  800fd4:	cd 30                	int    $0x30

	// Create child
	envid_t envid = sys_exofork();
  800fd6:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (envid < 0) {
  800fd9:	83 c4 10             	add    $0x10,%esp
  800fdc:	85 c0                	test   %eax,%eax
  800fde:	79 12                	jns    800ff2 <fork+0x35>
		panic("sys_exofork: %e", envid);
  800fe0:	50                   	push   %eax
  800fe1:	68 2c 27 80 00       	push   $0x80272c
  800fe6:	6a 7d                	push   $0x7d
  800fe8:	68 fd 26 80 00       	push   $0x8026fd
  800fed:	e8 26 f2 ff ff       	call   800218 <_panic>
		return envid;
	}
	if (envid == 0) {
  800ff2:	85 c0                	test   %eax,%eax
  800ff4:	75 1e                	jne    801014 <fork+0x57>
		// We are the child.
		thisenv = &envs[ENVX(sys_getenvid())]; // Fix thisenv
  800ff6:	e8 40 fc ff ff       	call   800c3b <sys_getenvid>
  800ffb:	25 ff 03 00 00       	and    $0x3ff,%eax
  801000:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801003:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801008:	a3 20 44 80 00       	mov    %eax,0x804420
		return 0;
  80100d:	b8 00 00 00 00       	mov    $0x0,%eax
  801012:	eb 7d                	jmp    801091 <fork+0xd4>

	// Set page fault handler on the child.
	// The parent needs to do it, else the child wouldn't be able to handle
	// the fault when trying to access it's stack (which happens as soon it starts)
	extern void _pgfault_upcall(void);
	sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);
  801014:	83 ec 04             	sub    $0x4,%esp
  801017:	6a 07                	push   $0x7
  801019:	68 00 f0 bf ee       	push   $0xeebff000
  80101e:	50                   	push   %eax
  80101f:	e8 55 fc ff ff       	call   800c79 <sys_page_alloc>
	sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  801024:	83 c4 08             	add    $0x8,%esp
  801027:	68 59 1e 80 00       	push   $0x801e59
  80102c:	ff 75 f4             	pushl  -0xc(%ebp)
  80102f:	e8 90 fd ff ff       	call   800dc4 <sys_env_set_pgfault_upcall>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  801034:	be 04 60 80 00       	mov    $0x806004,%esi
  801039:	c1 ee 0c             	shr    $0xc,%esi
  80103c:	83 c4 10             	add    $0x10,%esp
  80103f:	bb 00 08 00 00       	mov    $0x800,%ebx
  801044:	eb 0d                	jmp    801053 <fork+0x96>
		duppage(envid, pn);
  801046:	89 da                	mov    %ebx,%edx
  801048:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80104b:	e8 1a fe ff ff       	call   800e6a <duppage>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  801050:	83 c3 01             	add    $0x1,%ebx
  801053:	39 f3                	cmp    %esi,%ebx
  801055:	76 ef                	jbe    801046 <fork+0x89>
	}

	// Also copy the stack we are currently running on
	// I think it should loop from ustacktop to this page, since the stack
	// can have more than 1 page
	duppage(envid, ((uint32_t) &envid)/PGSIZE);
  801057:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80105a:	c1 ea 0c             	shr    $0xc,%edx
  80105d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801060:	e8 05 fe ff ff       	call   800e6a <duppage>

	// Start the child environmnet running
	int r;
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  801065:	83 ec 08             	sub    $0x8,%esp
  801068:	6a 02                	push   $0x2
  80106a:	ff 75 f4             	pushl  -0xc(%ebp)
  80106d:	e8 ce fc ff ff       	call   800d40 <sys_env_set_status>
  801072:	83 c4 10             	add    $0x10,%esp
  801075:	85 c0                	test   %eax,%eax
  801077:	79 15                	jns    80108e <fork+0xd1>
		panic("sys_env_set_status: %e", r);
  801079:	50                   	push   %eax
  80107a:	68 3c 27 80 00       	push   $0x80273c
  80107f:	68 9d 00 00 00       	push   $0x9d
  801084:	68 fd 26 80 00       	push   $0x8026fd
  801089:	e8 8a f1 ff ff       	call   800218 <_panic>
		return r;
	}

	return envid;
  80108e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  801091:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801094:	5b                   	pop    %ebx
  801095:	5e                   	pop    %esi
  801096:	5d                   	pop    %ebp
  801097:	c3                   	ret    

00801098 <sfork>:

// Challenge!
int
sfork(void)
{
  801098:	55                   	push   %ebp
  801099:	89 e5                	mov    %esp,%ebp
  80109b:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80109e:	68 53 27 80 00       	push   $0x802753
  8010a3:	68 a8 00 00 00       	push   $0xa8
  8010a8:	68 fd 26 80 00       	push   $0x8026fd
  8010ad:	e8 66 f1 ff ff       	call   800218 <_panic>

008010b2 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010b2:	55                   	push   %ebp
  8010b3:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8010b8:	05 00 00 00 30       	add    $0x30000000,%eax
  8010bd:	c1 e8 0c             	shr    $0xc,%eax
}
  8010c0:	5d                   	pop    %ebp
  8010c1:	c3                   	ret    

008010c2 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010c2:	55                   	push   %ebp
  8010c3:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8010c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c8:	05 00 00 00 30       	add    $0x30000000,%eax
  8010cd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010d2:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010d7:	5d                   	pop    %ebp
  8010d8:	c3                   	ret    

008010d9 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010d9:	55                   	push   %ebp
  8010da:	89 e5                	mov    %esp,%ebp
  8010dc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010df:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010e4:	89 c2                	mov    %eax,%edx
  8010e6:	c1 ea 16             	shr    $0x16,%edx
  8010e9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010f0:	f6 c2 01             	test   $0x1,%dl
  8010f3:	74 11                	je     801106 <fd_alloc+0x2d>
  8010f5:	89 c2                	mov    %eax,%edx
  8010f7:	c1 ea 0c             	shr    $0xc,%edx
  8010fa:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801101:	f6 c2 01             	test   $0x1,%dl
  801104:	75 09                	jne    80110f <fd_alloc+0x36>
			*fd_store = fd;
  801106:	89 01                	mov    %eax,(%ecx)
			return 0;
  801108:	b8 00 00 00 00       	mov    $0x0,%eax
  80110d:	eb 17                	jmp    801126 <fd_alloc+0x4d>
  80110f:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801114:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801119:	75 c9                	jne    8010e4 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80111b:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801121:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801126:	5d                   	pop    %ebp
  801127:	c3                   	ret    

00801128 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801128:	55                   	push   %ebp
  801129:	89 e5                	mov    %esp,%ebp
  80112b:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80112e:	83 f8 1f             	cmp    $0x1f,%eax
  801131:	77 36                	ja     801169 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801133:	c1 e0 0c             	shl    $0xc,%eax
  801136:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80113b:	89 c2                	mov    %eax,%edx
  80113d:	c1 ea 16             	shr    $0x16,%edx
  801140:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801147:	f6 c2 01             	test   $0x1,%dl
  80114a:	74 24                	je     801170 <fd_lookup+0x48>
  80114c:	89 c2                	mov    %eax,%edx
  80114e:	c1 ea 0c             	shr    $0xc,%edx
  801151:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801158:	f6 c2 01             	test   $0x1,%dl
  80115b:	74 1a                	je     801177 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80115d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801160:	89 02                	mov    %eax,(%edx)
	return 0;
  801162:	b8 00 00 00 00       	mov    $0x0,%eax
  801167:	eb 13                	jmp    80117c <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801169:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80116e:	eb 0c                	jmp    80117c <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801170:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801175:	eb 05                	jmp    80117c <fd_lookup+0x54>
  801177:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80117c:	5d                   	pop    %ebp
  80117d:	c3                   	ret    

0080117e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80117e:	55                   	push   %ebp
  80117f:	89 e5                	mov    %esp,%ebp
  801181:	83 ec 08             	sub    $0x8,%esp
  801184:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801187:	ba 20 28 80 00       	mov    $0x802820,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80118c:	eb 13                	jmp    8011a1 <dev_lookup+0x23>
  80118e:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801191:	39 08                	cmp    %ecx,(%eax)
  801193:	75 0c                	jne    8011a1 <dev_lookup+0x23>
			*dev = devtab[i];
  801195:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801198:	89 01                	mov    %eax,(%ecx)
			return 0;
  80119a:	b8 00 00 00 00       	mov    $0x0,%eax
  80119f:	eb 2e                	jmp    8011cf <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011a1:	8b 02                	mov    (%edx),%eax
  8011a3:	85 c0                	test   %eax,%eax
  8011a5:	75 e7                	jne    80118e <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011a7:	a1 20 44 80 00       	mov    0x804420,%eax
  8011ac:	8b 40 48             	mov    0x48(%eax),%eax
  8011af:	83 ec 04             	sub    $0x4,%esp
  8011b2:	51                   	push   %ecx
  8011b3:	50                   	push   %eax
  8011b4:	68 a0 27 80 00       	push   $0x8027a0
  8011b9:	e8 33 f1 ff ff       	call   8002f1 <cprintf>
	*dev = 0;
  8011be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011c1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8011c7:	83 c4 10             	add    $0x10,%esp
  8011ca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011cf:	c9                   	leave  
  8011d0:	c3                   	ret    

008011d1 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8011d1:	55                   	push   %ebp
  8011d2:	89 e5                	mov    %esp,%ebp
  8011d4:	56                   	push   %esi
  8011d5:	53                   	push   %ebx
  8011d6:	83 ec 10             	sub    $0x10,%esp
  8011d9:	8b 75 08             	mov    0x8(%ebp),%esi
  8011dc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011df:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011e2:	50                   	push   %eax
  8011e3:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8011e9:	c1 e8 0c             	shr    $0xc,%eax
  8011ec:	50                   	push   %eax
  8011ed:	e8 36 ff ff ff       	call   801128 <fd_lookup>
  8011f2:	83 c4 08             	add    $0x8,%esp
  8011f5:	85 c0                	test   %eax,%eax
  8011f7:	78 05                	js     8011fe <fd_close+0x2d>
	    || fd != fd2)
  8011f9:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8011fc:	74 0c                	je     80120a <fd_close+0x39>
		return (must_exist ? r : 0);
  8011fe:	84 db                	test   %bl,%bl
  801200:	ba 00 00 00 00       	mov    $0x0,%edx
  801205:	0f 44 c2             	cmove  %edx,%eax
  801208:	eb 41                	jmp    80124b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80120a:	83 ec 08             	sub    $0x8,%esp
  80120d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801210:	50                   	push   %eax
  801211:	ff 36                	pushl  (%esi)
  801213:	e8 66 ff ff ff       	call   80117e <dev_lookup>
  801218:	89 c3                	mov    %eax,%ebx
  80121a:	83 c4 10             	add    $0x10,%esp
  80121d:	85 c0                	test   %eax,%eax
  80121f:	78 1a                	js     80123b <fd_close+0x6a>
		if (dev->dev_close)
  801221:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801224:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801227:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80122c:	85 c0                	test   %eax,%eax
  80122e:	74 0b                	je     80123b <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801230:	83 ec 0c             	sub    $0xc,%esp
  801233:	56                   	push   %esi
  801234:	ff d0                	call   *%eax
  801236:	89 c3                	mov    %eax,%ebx
  801238:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80123b:	83 ec 08             	sub    $0x8,%esp
  80123e:	56                   	push   %esi
  80123f:	6a 00                	push   $0x0
  801241:	e8 b8 fa ff ff       	call   800cfe <sys_page_unmap>
	return r;
  801246:	83 c4 10             	add    $0x10,%esp
  801249:	89 d8                	mov    %ebx,%eax
}
  80124b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80124e:	5b                   	pop    %ebx
  80124f:	5e                   	pop    %esi
  801250:	5d                   	pop    %ebp
  801251:	c3                   	ret    

00801252 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801252:	55                   	push   %ebp
  801253:	89 e5                	mov    %esp,%ebp
  801255:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801258:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80125b:	50                   	push   %eax
  80125c:	ff 75 08             	pushl  0x8(%ebp)
  80125f:	e8 c4 fe ff ff       	call   801128 <fd_lookup>
  801264:	83 c4 08             	add    $0x8,%esp
  801267:	85 c0                	test   %eax,%eax
  801269:	78 10                	js     80127b <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80126b:	83 ec 08             	sub    $0x8,%esp
  80126e:	6a 01                	push   $0x1
  801270:	ff 75 f4             	pushl  -0xc(%ebp)
  801273:	e8 59 ff ff ff       	call   8011d1 <fd_close>
  801278:	83 c4 10             	add    $0x10,%esp
}
  80127b:	c9                   	leave  
  80127c:	c3                   	ret    

0080127d <close_all>:

void
close_all(void)
{
  80127d:	55                   	push   %ebp
  80127e:	89 e5                	mov    %esp,%ebp
  801280:	53                   	push   %ebx
  801281:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801284:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801289:	83 ec 0c             	sub    $0xc,%esp
  80128c:	53                   	push   %ebx
  80128d:	e8 c0 ff ff ff       	call   801252 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801292:	83 c3 01             	add    $0x1,%ebx
  801295:	83 c4 10             	add    $0x10,%esp
  801298:	83 fb 20             	cmp    $0x20,%ebx
  80129b:	75 ec                	jne    801289 <close_all+0xc>
		close(i);
}
  80129d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012a0:	c9                   	leave  
  8012a1:	c3                   	ret    

008012a2 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012a2:	55                   	push   %ebp
  8012a3:	89 e5                	mov    %esp,%ebp
  8012a5:	57                   	push   %edi
  8012a6:	56                   	push   %esi
  8012a7:	53                   	push   %ebx
  8012a8:	83 ec 2c             	sub    $0x2c,%esp
  8012ab:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012ae:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012b1:	50                   	push   %eax
  8012b2:	ff 75 08             	pushl  0x8(%ebp)
  8012b5:	e8 6e fe ff ff       	call   801128 <fd_lookup>
  8012ba:	83 c4 08             	add    $0x8,%esp
  8012bd:	85 c0                	test   %eax,%eax
  8012bf:	0f 88 c1 00 00 00    	js     801386 <dup+0xe4>
		return r;
	close(newfdnum);
  8012c5:	83 ec 0c             	sub    $0xc,%esp
  8012c8:	56                   	push   %esi
  8012c9:	e8 84 ff ff ff       	call   801252 <close>

	newfd = INDEX2FD(newfdnum);
  8012ce:	89 f3                	mov    %esi,%ebx
  8012d0:	c1 e3 0c             	shl    $0xc,%ebx
  8012d3:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8012d9:	83 c4 04             	add    $0x4,%esp
  8012dc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012df:	e8 de fd ff ff       	call   8010c2 <fd2data>
  8012e4:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8012e6:	89 1c 24             	mov    %ebx,(%esp)
  8012e9:	e8 d4 fd ff ff       	call   8010c2 <fd2data>
  8012ee:	83 c4 10             	add    $0x10,%esp
  8012f1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012f4:	89 f8                	mov    %edi,%eax
  8012f6:	c1 e8 16             	shr    $0x16,%eax
  8012f9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801300:	a8 01                	test   $0x1,%al
  801302:	74 37                	je     80133b <dup+0x99>
  801304:	89 f8                	mov    %edi,%eax
  801306:	c1 e8 0c             	shr    $0xc,%eax
  801309:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801310:	f6 c2 01             	test   $0x1,%dl
  801313:	74 26                	je     80133b <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801315:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80131c:	83 ec 0c             	sub    $0xc,%esp
  80131f:	25 07 0e 00 00       	and    $0xe07,%eax
  801324:	50                   	push   %eax
  801325:	ff 75 d4             	pushl  -0x2c(%ebp)
  801328:	6a 00                	push   $0x0
  80132a:	57                   	push   %edi
  80132b:	6a 00                	push   $0x0
  80132d:	e8 8a f9 ff ff       	call   800cbc <sys_page_map>
  801332:	89 c7                	mov    %eax,%edi
  801334:	83 c4 20             	add    $0x20,%esp
  801337:	85 c0                	test   %eax,%eax
  801339:	78 2e                	js     801369 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80133b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80133e:	89 d0                	mov    %edx,%eax
  801340:	c1 e8 0c             	shr    $0xc,%eax
  801343:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80134a:	83 ec 0c             	sub    $0xc,%esp
  80134d:	25 07 0e 00 00       	and    $0xe07,%eax
  801352:	50                   	push   %eax
  801353:	53                   	push   %ebx
  801354:	6a 00                	push   $0x0
  801356:	52                   	push   %edx
  801357:	6a 00                	push   $0x0
  801359:	e8 5e f9 ff ff       	call   800cbc <sys_page_map>
  80135e:	89 c7                	mov    %eax,%edi
  801360:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801363:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801365:	85 ff                	test   %edi,%edi
  801367:	79 1d                	jns    801386 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801369:	83 ec 08             	sub    $0x8,%esp
  80136c:	53                   	push   %ebx
  80136d:	6a 00                	push   $0x0
  80136f:	e8 8a f9 ff ff       	call   800cfe <sys_page_unmap>
	sys_page_unmap(0, nva);
  801374:	83 c4 08             	add    $0x8,%esp
  801377:	ff 75 d4             	pushl  -0x2c(%ebp)
  80137a:	6a 00                	push   $0x0
  80137c:	e8 7d f9 ff ff       	call   800cfe <sys_page_unmap>
	return r;
  801381:	83 c4 10             	add    $0x10,%esp
  801384:	89 f8                	mov    %edi,%eax
}
  801386:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801389:	5b                   	pop    %ebx
  80138a:	5e                   	pop    %esi
  80138b:	5f                   	pop    %edi
  80138c:	5d                   	pop    %ebp
  80138d:	c3                   	ret    

0080138e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80138e:	55                   	push   %ebp
  80138f:	89 e5                	mov    %esp,%ebp
  801391:	53                   	push   %ebx
  801392:	83 ec 14             	sub    $0x14,%esp
  801395:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801398:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80139b:	50                   	push   %eax
  80139c:	53                   	push   %ebx
  80139d:	e8 86 fd ff ff       	call   801128 <fd_lookup>
  8013a2:	83 c4 08             	add    $0x8,%esp
  8013a5:	89 c2                	mov    %eax,%edx
  8013a7:	85 c0                	test   %eax,%eax
  8013a9:	78 6d                	js     801418 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013ab:	83 ec 08             	sub    $0x8,%esp
  8013ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013b1:	50                   	push   %eax
  8013b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013b5:	ff 30                	pushl  (%eax)
  8013b7:	e8 c2 fd ff ff       	call   80117e <dev_lookup>
  8013bc:	83 c4 10             	add    $0x10,%esp
  8013bf:	85 c0                	test   %eax,%eax
  8013c1:	78 4c                	js     80140f <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013c3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013c6:	8b 42 08             	mov    0x8(%edx),%eax
  8013c9:	83 e0 03             	and    $0x3,%eax
  8013cc:	83 f8 01             	cmp    $0x1,%eax
  8013cf:	75 21                	jne    8013f2 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013d1:	a1 20 44 80 00       	mov    0x804420,%eax
  8013d6:	8b 40 48             	mov    0x48(%eax),%eax
  8013d9:	83 ec 04             	sub    $0x4,%esp
  8013dc:	53                   	push   %ebx
  8013dd:	50                   	push   %eax
  8013de:	68 e4 27 80 00       	push   $0x8027e4
  8013e3:	e8 09 ef ff ff       	call   8002f1 <cprintf>
		return -E_INVAL;
  8013e8:	83 c4 10             	add    $0x10,%esp
  8013eb:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013f0:	eb 26                	jmp    801418 <read+0x8a>
	}
	if (!dev->dev_read)
  8013f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013f5:	8b 40 08             	mov    0x8(%eax),%eax
  8013f8:	85 c0                	test   %eax,%eax
  8013fa:	74 17                	je     801413 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013fc:	83 ec 04             	sub    $0x4,%esp
  8013ff:	ff 75 10             	pushl  0x10(%ebp)
  801402:	ff 75 0c             	pushl  0xc(%ebp)
  801405:	52                   	push   %edx
  801406:	ff d0                	call   *%eax
  801408:	89 c2                	mov    %eax,%edx
  80140a:	83 c4 10             	add    $0x10,%esp
  80140d:	eb 09                	jmp    801418 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80140f:	89 c2                	mov    %eax,%edx
  801411:	eb 05                	jmp    801418 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801413:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801418:	89 d0                	mov    %edx,%eax
  80141a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80141d:	c9                   	leave  
  80141e:	c3                   	ret    

0080141f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80141f:	55                   	push   %ebp
  801420:	89 e5                	mov    %esp,%ebp
  801422:	57                   	push   %edi
  801423:	56                   	push   %esi
  801424:	53                   	push   %ebx
  801425:	83 ec 0c             	sub    $0xc,%esp
  801428:	8b 7d 08             	mov    0x8(%ebp),%edi
  80142b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80142e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801433:	eb 21                	jmp    801456 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801435:	83 ec 04             	sub    $0x4,%esp
  801438:	89 f0                	mov    %esi,%eax
  80143a:	29 d8                	sub    %ebx,%eax
  80143c:	50                   	push   %eax
  80143d:	89 d8                	mov    %ebx,%eax
  80143f:	03 45 0c             	add    0xc(%ebp),%eax
  801442:	50                   	push   %eax
  801443:	57                   	push   %edi
  801444:	e8 45 ff ff ff       	call   80138e <read>
		if (m < 0)
  801449:	83 c4 10             	add    $0x10,%esp
  80144c:	85 c0                	test   %eax,%eax
  80144e:	78 10                	js     801460 <readn+0x41>
			return m;
		if (m == 0)
  801450:	85 c0                	test   %eax,%eax
  801452:	74 0a                	je     80145e <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801454:	01 c3                	add    %eax,%ebx
  801456:	39 f3                	cmp    %esi,%ebx
  801458:	72 db                	jb     801435 <readn+0x16>
  80145a:	89 d8                	mov    %ebx,%eax
  80145c:	eb 02                	jmp    801460 <readn+0x41>
  80145e:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801460:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801463:	5b                   	pop    %ebx
  801464:	5e                   	pop    %esi
  801465:	5f                   	pop    %edi
  801466:	5d                   	pop    %ebp
  801467:	c3                   	ret    

00801468 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801468:	55                   	push   %ebp
  801469:	89 e5                	mov    %esp,%ebp
  80146b:	53                   	push   %ebx
  80146c:	83 ec 14             	sub    $0x14,%esp
  80146f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801472:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801475:	50                   	push   %eax
  801476:	53                   	push   %ebx
  801477:	e8 ac fc ff ff       	call   801128 <fd_lookup>
  80147c:	83 c4 08             	add    $0x8,%esp
  80147f:	89 c2                	mov    %eax,%edx
  801481:	85 c0                	test   %eax,%eax
  801483:	78 68                	js     8014ed <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801485:	83 ec 08             	sub    $0x8,%esp
  801488:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80148b:	50                   	push   %eax
  80148c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80148f:	ff 30                	pushl  (%eax)
  801491:	e8 e8 fc ff ff       	call   80117e <dev_lookup>
  801496:	83 c4 10             	add    $0x10,%esp
  801499:	85 c0                	test   %eax,%eax
  80149b:	78 47                	js     8014e4 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80149d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014a0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014a4:	75 21                	jne    8014c7 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014a6:	a1 20 44 80 00       	mov    0x804420,%eax
  8014ab:	8b 40 48             	mov    0x48(%eax),%eax
  8014ae:	83 ec 04             	sub    $0x4,%esp
  8014b1:	53                   	push   %ebx
  8014b2:	50                   	push   %eax
  8014b3:	68 00 28 80 00       	push   $0x802800
  8014b8:	e8 34 ee ff ff       	call   8002f1 <cprintf>
		return -E_INVAL;
  8014bd:	83 c4 10             	add    $0x10,%esp
  8014c0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014c5:	eb 26                	jmp    8014ed <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014c7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014ca:	8b 52 0c             	mov    0xc(%edx),%edx
  8014cd:	85 d2                	test   %edx,%edx
  8014cf:	74 17                	je     8014e8 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014d1:	83 ec 04             	sub    $0x4,%esp
  8014d4:	ff 75 10             	pushl  0x10(%ebp)
  8014d7:	ff 75 0c             	pushl  0xc(%ebp)
  8014da:	50                   	push   %eax
  8014db:	ff d2                	call   *%edx
  8014dd:	89 c2                	mov    %eax,%edx
  8014df:	83 c4 10             	add    $0x10,%esp
  8014e2:	eb 09                	jmp    8014ed <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014e4:	89 c2                	mov    %eax,%edx
  8014e6:	eb 05                	jmp    8014ed <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8014e8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8014ed:	89 d0                	mov    %edx,%eax
  8014ef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014f2:	c9                   	leave  
  8014f3:	c3                   	ret    

008014f4 <seek>:

int
seek(int fdnum, off_t offset)
{
  8014f4:	55                   	push   %ebp
  8014f5:	89 e5                	mov    %esp,%ebp
  8014f7:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014fa:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014fd:	50                   	push   %eax
  8014fe:	ff 75 08             	pushl  0x8(%ebp)
  801501:	e8 22 fc ff ff       	call   801128 <fd_lookup>
  801506:	83 c4 08             	add    $0x8,%esp
  801509:	85 c0                	test   %eax,%eax
  80150b:	78 0e                	js     80151b <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80150d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801510:	8b 55 0c             	mov    0xc(%ebp),%edx
  801513:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801516:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80151b:	c9                   	leave  
  80151c:	c3                   	ret    

0080151d <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80151d:	55                   	push   %ebp
  80151e:	89 e5                	mov    %esp,%ebp
  801520:	53                   	push   %ebx
  801521:	83 ec 14             	sub    $0x14,%esp
  801524:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801527:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80152a:	50                   	push   %eax
  80152b:	53                   	push   %ebx
  80152c:	e8 f7 fb ff ff       	call   801128 <fd_lookup>
  801531:	83 c4 08             	add    $0x8,%esp
  801534:	89 c2                	mov    %eax,%edx
  801536:	85 c0                	test   %eax,%eax
  801538:	78 65                	js     80159f <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80153a:	83 ec 08             	sub    $0x8,%esp
  80153d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801540:	50                   	push   %eax
  801541:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801544:	ff 30                	pushl  (%eax)
  801546:	e8 33 fc ff ff       	call   80117e <dev_lookup>
  80154b:	83 c4 10             	add    $0x10,%esp
  80154e:	85 c0                	test   %eax,%eax
  801550:	78 44                	js     801596 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801552:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801555:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801559:	75 21                	jne    80157c <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80155b:	a1 20 44 80 00       	mov    0x804420,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801560:	8b 40 48             	mov    0x48(%eax),%eax
  801563:	83 ec 04             	sub    $0x4,%esp
  801566:	53                   	push   %ebx
  801567:	50                   	push   %eax
  801568:	68 c0 27 80 00       	push   $0x8027c0
  80156d:	e8 7f ed ff ff       	call   8002f1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801572:	83 c4 10             	add    $0x10,%esp
  801575:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80157a:	eb 23                	jmp    80159f <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80157c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80157f:	8b 52 18             	mov    0x18(%edx),%edx
  801582:	85 d2                	test   %edx,%edx
  801584:	74 14                	je     80159a <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801586:	83 ec 08             	sub    $0x8,%esp
  801589:	ff 75 0c             	pushl  0xc(%ebp)
  80158c:	50                   	push   %eax
  80158d:	ff d2                	call   *%edx
  80158f:	89 c2                	mov    %eax,%edx
  801591:	83 c4 10             	add    $0x10,%esp
  801594:	eb 09                	jmp    80159f <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801596:	89 c2                	mov    %eax,%edx
  801598:	eb 05                	jmp    80159f <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80159a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80159f:	89 d0                	mov    %edx,%eax
  8015a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015a4:	c9                   	leave  
  8015a5:	c3                   	ret    

008015a6 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015a6:	55                   	push   %ebp
  8015a7:	89 e5                	mov    %esp,%ebp
  8015a9:	53                   	push   %ebx
  8015aa:	83 ec 14             	sub    $0x14,%esp
  8015ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015b0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015b3:	50                   	push   %eax
  8015b4:	ff 75 08             	pushl  0x8(%ebp)
  8015b7:	e8 6c fb ff ff       	call   801128 <fd_lookup>
  8015bc:	83 c4 08             	add    $0x8,%esp
  8015bf:	89 c2                	mov    %eax,%edx
  8015c1:	85 c0                	test   %eax,%eax
  8015c3:	78 58                	js     80161d <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015c5:	83 ec 08             	sub    $0x8,%esp
  8015c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015cb:	50                   	push   %eax
  8015cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015cf:	ff 30                	pushl  (%eax)
  8015d1:	e8 a8 fb ff ff       	call   80117e <dev_lookup>
  8015d6:	83 c4 10             	add    $0x10,%esp
  8015d9:	85 c0                	test   %eax,%eax
  8015db:	78 37                	js     801614 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8015dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015e0:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015e4:	74 32                	je     801618 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015e6:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015e9:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015f0:	00 00 00 
	stat->st_isdir = 0;
  8015f3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015fa:	00 00 00 
	stat->st_dev = dev;
  8015fd:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801603:	83 ec 08             	sub    $0x8,%esp
  801606:	53                   	push   %ebx
  801607:	ff 75 f0             	pushl  -0x10(%ebp)
  80160a:	ff 50 14             	call   *0x14(%eax)
  80160d:	89 c2                	mov    %eax,%edx
  80160f:	83 c4 10             	add    $0x10,%esp
  801612:	eb 09                	jmp    80161d <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801614:	89 c2                	mov    %eax,%edx
  801616:	eb 05                	jmp    80161d <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801618:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80161d:	89 d0                	mov    %edx,%eax
  80161f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801622:	c9                   	leave  
  801623:	c3                   	ret    

00801624 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801624:	55                   	push   %ebp
  801625:	89 e5                	mov    %esp,%ebp
  801627:	56                   	push   %esi
  801628:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801629:	83 ec 08             	sub    $0x8,%esp
  80162c:	6a 00                	push   $0x0
  80162e:	ff 75 08             	pushl  0x8(%ebp)
  801631:	e8 0c 02 00 00       	call   801842 <open>
  801636:	89 c3                	mov    %eax,%ebx
  801638:	83 c4 10             	add    $0x10,%esp
  80163b:	85 c0                	test   %eax,%eax
  80163d:	78 1b                	js     80165a <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80163f:	83 ec 08             	sub    $0x8,%esp
  801642:	ff 75 0c             	pushl  0xc(%ebp)
  801645:	50                   	push   %eax
  801646:	e8 5b ff ff ff       	call   8015a6 <fstat>
  80164b:	89 c6                	mov    %eax,%esi
	close(fd);
  80164d:	89 1c 24             	mov    %ebx,(%esp)
  801650:	e8 fd fb ff ff       	call   801252 <close>
	return r;
  801655:	83 c4 10             	add    $0x10,%esp
  801658:	89 f0                	mov    %esi,%eax
}
  80165a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80165d:	5b                   	pop    %ebx
  80165e:	5e                   	pop    %esi
  80165f:	5d                   	pop    %ebp
  801660:	c3                   	ret    

00801661 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801661:	55                   	push   %ebp
  801662:	89 e5                	mov    %esp,%ebp
  801664:	56                   	push   %esi
  801665:	53                   	push   %ebx
  801666:	89 c6                	mov    %eax,%esi
  801668:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80166a:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801671:	75 12                	jne    801685 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801673:	83 ec 0c             	sub    $0xc,%esp
  801676:	6a 01                	push   $0x1
  801678:	e8 ca 08 00 00       	call   801f47 <ipc_find_env>
  80167d:	a3 00 40 80 00       	mov    %eax,0x804000
  801682:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801685:	6a 07                	push   $0x7
  801687:	68 00 50 80 00       	push   $0x805000
  80168c:	56                   	push   %esi
  80168d:	ff 35 00 40 80 00    	pushl  0x804000
  801693:	e8 5b 08 00 00       	call   801ef3 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801698:	83 c4 0c             	add    $0xc,%esp
  80169b:	6a 00                	push   $0x0
  80169d:	53                   	push   %ebx
  80169e:	6a 00                	push   $0x0
  8016a0:	e8 e5 07 00 00       	call   801e8a <ipc_recv>
}
  8016a5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016a8:	5b                   	pop    %ebx
  8016a9:	5e                   	pop    %esi
  8016aa:	5d                   	pop    %ebp
  8016ab:	c3                   	ret    

008016ac <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016ac:	55                   	push   %ebp
  8016ad:	89 e5                	mov    %esp,%ebp
  8016af:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b5:	8b 40 0c             	mov    0xc(%eax),%eax
  8016b8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8016bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016c0:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8016ca:	b8 02 00 00 00       	mov    $0x2,%eax
  8016cf:	e8 8d ff ff ff       	call   801661 <fsipc>
}
  8016d4:	c9                   	leave  
  8016d5:	c3                   	ret    

008016d6 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8016d6:	55                   	push   %ebp
  8016d7:	89 e5                	mov    %esp,%ebp
  8016d9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8016df:	8b 40 0c             	mov    0xc(%eax),%eax
  8016e2:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8016ec:	b8 06 00 00 00       	mov    $0x6,%eax
  8016f1:	e8 6b ff ff ff       	call   801661 <fsipc>
}
  8016f6:	c9                   	leave  
  8016f7:	c3                   	ret    

008016f8 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016f8:	55                   	push   %ebp
  8016f9:	89 e5                	mov    %esp,%ebp
  8016fb:	53                   	push   %ebx
  8016fc:	83 ec 04             	sub    $0x4,%esp
  8016ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801702:	8b 45 08             	mov    0x8(%ebp),%eax
  801705:	8b 40 0c             	mov    0xc(%eax),%eax
  801708:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80170d:	ba 00 00 00 00       	mov    $0x0,%edx
  801712:	b8 05 00 00 00       	mov    $0x5,%eax
  801717:	e8 45 ff ff ff       	call   801661 <fsipc>
  80171c:	85 c0                	test   %eax,%eax
  80171e:	78 2c                	js     80174c <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801720:	83 ec 08             	sub    $0x8,%esp
  801723:	68 00 50 80 00       	push   $0x805000
  801728:	53                   	push   %ebx
  801729:	e8 48 f1 ff ff       	call   800876 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80172e:	a1 80 50 80 00       	mov    0x805080,%eax
  801733:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801739:	a1 84 50 80 00       	mov    0x805084,%eax
  80173e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801744:	83 c4 10             	add    $0x10,%esp
  801747:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80174c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80174f:	c9                   	leave  
  801750:	c3                   	ret    

00801751 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801751:	55                   	push   %ebp
  801752:	89 e5                	mov    %esp,%ebp
  801754:	53                   	push   %ebx
  801755:	83 ec 08             	sub    $0x8,%esp
  801758:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80175b:	8b 55 08             	mov    0x8(%ebp),%edx
  80175e:	8b 52 0c             	mov    0xc(%edx),%edx
  801761:	89 15 00 50 80 00    	mov    %edx,0x805000
  801767:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80176c:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  801771:	0f 46 d8             	cmovbe %eax,%ebx
	
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  801774:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  80177a:	53                   	push   %ebx
  80177b:	ff 75 0c             	pushl  0xc(%ebp)
  80177e:	68 08 50 80 00       	push   $0x805008
  801783:	e8 80 f2 ff ff       	call   800a08 <memmove>

	
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) 
  801788:	ba 00 00 00 00       	mov    $0x0,%edx
  80178d:	b8 04 00 00 00       	mov    $0x4,%eax
  801792:	e8 ca fe ff ff       	call   801661 <fsipc>
  801797:	83 c4 10             	add    $0x10,%esp
  80179a:	85 c0                	test   %eax,%eax
  80179c:	78 1d                	js     8017bb <devfile_write+0x6a>
		return r;
	assert(r <= n_real); 
  80179e:	39 d8                	cmp    %ebx,%eax
  8017a0:	76 19                	jbe    8017bb <devfile_write+0x6a>
  8017a2:	68 30 28 80 00       	push   $0x802830
  8017a7:	68 3c 28 80 00       	push   $0x80283c
  8017ac:	68 a3 00 00 00       	push   $0xa3
  8017b1:	68 51 28 80 00       	push   $0x802851
  8017b6:	e8 5d ea ff ff       	call   800218 <_panic>
	return r;
}
  8017bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017be:	c9                   	leave  
  8017bf:	c3                   	ret    

008017c0 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017c0:	55                   	push   %ebp
  8017c1:	89 e5                	mov    %esp,%ebp
  8017c3:	56                   	push   %esi
  8017c4:	53                   	push   %ebx
  8017c5:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017cb:	8b 40 0c             	mov    0xc(%eax),%eax
  8017ce:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8017d3:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8017de:	b8 03 00 00 00       	mov    $0x3,%eax
  8017e3:	e8 79 fe ff ff       	call   801661 <fsipc>
  8017e8:	89 c3                	mov    %eax,%ebx
  8017ea:	85 c0                	test   %eax,%eax
  8017ec:	78 4b                	js     801839 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8017ee:	39 c6                	cmp    %eax,%esi
  8017f0:	73 16                	jae    801808 <devfile_read+0x48>
  8017f2:	68 5c 28 80 00       	push   $0x80285c
  8017f7:	68 3c 28 80 00       	push   $0x80283c
  8017fc:	6a 7c                	push   $0x7c
  8017fe:	68 51 28 80 00       	push   $0x802851
  801803:	e8 10 ea ff ff       	call   800218 <_panic>
	assert(r <= PGSIZE);
  801808:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80180d:	7e 16                	jle    801825 <devfile_read+0x65>
  80180f:	68 63 28 80 00       	push   $0x802863
  801814:	68 3c 28 80 00       	push   $0x80283c
  801819:	6a 7d                	push   $0x7d
  80181b:	68 51 28 80 00       	push   $0x802851
  801820:	e8 f3 e9 ff ff       	call   800218 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801825:	83 ec 04             	sub    $0x4,%esp
  801828:	50                   	push   %eax
  801829:	68 00 50 80 00       	push   $0x805000
  80182e:	ff 75 0c             	pushl  0xc(%ebp)
  801831:	e8 d2 f1 ff ff       	call   800a08 <memmove>
	return r;
  801836:	83 c4 10             	add    $0x10,%esp
}
  801839:	89 d8                	mov    %ebx,%eax
  80183b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80183e:	5b                   	pop    %ebx
  80183f:	5e                   	pop    %esi
  801840:	5d                   	pop    %ebp
  801841:	c3                   	ret    

00801842 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801842:	55                   	push   %ebp
  801843:	89 e5                	mov    %esp,%ebp
  801845:	53                   	push   %ebx
  801846:	83 ec 20             	sub    $0x20,%esp
  801849:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80184c:	53                   	push   %ebx
  80184d:	e8 eb ef ff ff       	call   80083d <strlen>
  801852:	83 c4 10             	add    $0x10,%esp
  801855:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80185a:	7f 67                	jg     8018c3 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80185c:	83 ec 0c             	sub    $0xc,%esp
  80185f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801862:	50                   	push   %eax
  801863:	e8 71 f8 ff ff       	call   8010d9 <fd_alloc>
  801868:	83 c4 10             	add    $0x10,%esp
		return r;
  80186b:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80186d:	85 c0                	test   %eax,%eax
  80186f:	78 57                	js     8018c8 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801871:	83 ec 08             	sub    $0x8,%esp
  801874:	53                   	push   %ebx
  801875:	68 00 50 80 00       	push   $0x805000
  80187a:	e8 f7 ef ff ff       	call   800876 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80187f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801882:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801887:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80188a:	b8 01 00 00 00       	mov    $0x1,%eax
  80188f:	e8 cd fd ff ff       	call   801661 <fsipc>
  801894:	89 c3                	mov    %eax,%ebx
  801896:	83 c4 10             	add    $0x10,%esp
  801899:	85 c0                	test   %eax,%eax
  80189b:	79 14                	jns    8018b1 <open+0x6f>
		fd_close(fd, 0);
  80189d:	83 ec 08             	sub    $0x8,%esp
  8018a0:	6a 00                	push   $0x0
  8018a2:	ff 75 f4             	pushl  -0xc(%ebp)
  8018a5:	e8 27 f9 ff ff       	call   8011d1 <fd_close>
		return r;
  8018aa:	83 c4 10             	add    $0x10,%esp
  8018ad:	89 da                	mov    %ebx,%edx
  8018af:	eb 17                	jmp    8018c8 <open+0x86>
	}

	return fd2num(fd);
  8018b1:	83 ec 0c             	sub    $0xc,%esp
  8018b4:	ff 75 f4             	pushl  -0xc(%ebp)
  8018b7:	e8 f6 f7 ff ff       	call   8010b2 <fd2num>
  8018bc:	89 c2                	mov    %eax,%edx
  8018be:	83 c4 10             	add    $0x10,%esp
  8018c1:	eb 05                	jmp    8018c8 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8018c3:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8018c8:	89 d0                	mov    %edx,%eax
  8018ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018cd:	c9                   	leave  
  8018ce:	c3                   	ret    

008018cf <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8018cf:	55                   	push   %ebp
  8018d0:	89 e5                	mov    %esp,%ebp
  8018d2:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8018da:	b8 08 00 00 00       	mov    $0x8,%eax
  8018df:	e8 7d fd ff ff       	call   801661 <fsipc>
}
  8018e4:	c9                   	leave  
  8018e5:	c3                   	ret    

008018e6 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8018e6:	55                   	push   %ebp
  8018e7:	89 e5                	mov    %esp,%ebp
  8018e9:	56                   	push   %esi
  8018ea:	53                   	push   %ebx
  8018eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8018ee:	83 ec 0c             	sub    $0xc,%esp
  8018f1:	ff 75 08             	pushl  0x8(%ebp)
  8018f4:	e8 c9 f7 ff ff       	call   8010c2 <fd2data>
  8018f9:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8018fb:	83 c4 08             	add    $0x8,%esp
  8018fe:	68 6f 28 80 00       	push   $0x80286f
  801903:	53                   	push   %ebx
  801904:	e8 6d ef ff ff       	call   800876 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801909:	8b 46 04             	mov    0x4(%esi),%eax
  80190c:	2b 06                	sub    (%esi),%eax
  80190e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801914:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80191b:	00 00 00 
	stat->st_dev = &devpipe;
  80191e:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801925:	30 80 00 
	return 0;
}
  801928:	b8 00 00 00 00       	mov    $0x0,%eax
  80192d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801930:	5b                   	pop    %ebx
  801931:	5e                   	pop    %esi
  801932:	5d                   	pop    %ebp
  801933:	c3                   	ret    

00801934 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801934:	55                   	push   %ebp
  801935:	89 e5                	mov    %esp,%ebp
  801937:	53                   	push   %ebx
  801938:	83 ec 0c             	sub    $0xc,%esp
  80193b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80193e:	53                   	push   %ebx
  80193f:	6a 00                	push   $0x0
  801941:	e8 b8 f3 ff ff       	call   800cfe <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801946:	89 1c 24             	mov    %ebx,(%esp)
  801949:	e8 74 f7 ff ff       	call   8010c2 <fd2data>
  80194e:	83 c4 08             	add    $0x8,%esp
  801951:	50                   	push   %eax
  801952:	6a 00                	push   $0x0
  801954:	e8 a5 f3 ff ff       	call   800cfe <sys_page_unmap>
}
  801959:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80195c:	c9                   	leave  
  80195d:	c3                   	ret    

0080195e <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80195e:	55                   	push   %ebp
  80195f:	89 e5                	mov    %esp,%ebp
  801961:	57                   	push   %edi
  801962:	56                   	push   %esi
  801963:	53                   	push   %ebx
  801964:	83 ec 1c             	sub    $0x1c,%esp
  801967:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80196a:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80196c:	a1 20 44 80 00       	mov    0x804420,%eax
  801971:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801974:	83 ec 0c             	sub    $0xc,%esp
  801977:	ff 75 e0             	pushl  -0x20(%ebp)
  80197a:	e8 01 06 00 00       	call   801f80 <pageref>
  80197f:	89 c3                	mov    %eax,%ebx
  801981:	89 3c 24             	mov    %edi,(%esp)
  801984:	e8 f7 05 00 00       	call   801f80 <pageref>
  801989:	83 c4 10             	add    $0x10,%esp
  80198c:	39 c3                	cmp    %eax,%ebx
  80198e:	0f 94 c1             	sete   %cl
  801991:	0f b6 c9             	movzbl %cl,%ecx
  801994:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801997:	8b 15 20 44 80 00    	mov    0x804420,%edx
  80199d:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8019a0:	39 ce                	cmp    %ecx,%esi
  8019a2:	74 1b                	je     8019bf <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8019a4:	39 c3                	cmp    %eax,%ebx
  8019a6:	75 c4                	jne    80196c <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8019a8:	8b 42 58             	mov    0x58(%edx),%eax
  8019ab:	ff 75 e4             	pushl  -0x1c(%ebp)
  8019ae:	50                   	push   %eax
  8019af:	56                   	push   %esi
  8019b0:	68 76 28 80 00       	push   $0x802876
  8019b5:	e8 37 e9 ff ff       	call   8002f1 <cprintf>
  8019ba:	83 c4 10             	add    $0x10,%esp
  8019bd:	eb ad                	jmp    80196c <_pipeisclosed+0xe>
	}
}
  8019bf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019c5:	5b                   	pop    %ebx
  8019c6:	5e                   	pop    %esi
  8019c7:	5f                   	pop    %edi
  8019c8:	5d                   	pop    %ebp
  8019c9:	c3                   	ret    

008019ca <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019ca:	55                   	push   %ebp
  8019cb:	89 e5                	mov    %esp,%ebp
  8019cd:	57                   	push   %edi
  8019ce:	56                   	push   %esi
  8019cf:	53                   	push   %ebx
  8019d0:	83 ec 28             	sub    $0x28,%esp
  8019d3:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8019d6:	56                   	push   %esi
  8019d7:	e8 e6 f6 ff ff       	call   8010c2 <fd2data>
  8019dc:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019de:	83 c4 10             	add    $0x10,%esp
  8019e1:	bf 00 00 00 00       	mov    $0x0,%edi
  8019e6:	eb 4b                	jmp    801a33 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8019e8:	89 da                	mov    %ebx,%edx
  8019ea:	89 f0                	mov    %esi,%eax
  8019ec:	e8 6d ff ff ff       	call   80195e <_pipeisclosed>
  8019f1:	85 c0                	test   %eax,%eax
  8019f3:	75 48                	jne    801a3d <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8019f5:	e8 60 f2 ff ff       	call   800c5a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8019fa:	8b 43 04             	mov    0x4(%ebx),%eax
  8019fd:	8b 0b                	mov    (%ebx),%ecx
  8019ff:	8d 51 20             	lea    0x20(%ecx),%edx
  801a02:	39 d0                	cmp    %edx,%eax
  801a04:	73 e2                	jae    8019e8 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a09:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a0d:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a10:	89 c2                	mov    %eax,%edx
  801a12:	c1 fa 1f             	sar    $0x1f,%edx
  801a15:	89 d1                	mov    %edx,%ecx
  801a17:	c1 e9 1b             	shr    $0x1b,%ecx
  801a1a:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801a1d:	83 e2 1f             	and    $0x1f,%edx
  801a20:	29 ca                	sub    %ecx,%edx
  801a22:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801a26:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a2a:	83 c0 01             	add    $0x1,%eax
  801a2d:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a30:	83 c7 01             	add    $0x1,%edi
  801a33:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a36:	75 c2                	jne    8019fa <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a38:	8b 45 10             	mov    0x10(%ebp),%eax
  801a3b:	eb 05                	jmp    801a42 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a3d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801a42:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a45:	5b                   	pop    %ebx
  801a46:	5e                   	pop    %esi
  801a47:	5f                   	pop    %edi
  801a48:	5d                   	pop    %ebp
  801a49:	c3                   	ret    

00801a4a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a4a:	55                   	push   %ebp
  801a4b:	89 e5                	mov    %esp,%ebp
  801a4d:	57                   	push   %edi
  801a4e:	56                   	push   %esi
  801a4f:	53                   	push   %ebx
  801a50:	83 ec 18             	sub    $0x18,%esp
  801a53:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a56:	57                   	push   %edi
  801a57:	e8 66 f6 ff ff       	call   8010c2 <fd2data>
  801a5c:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a5e:	83 c4 10             	add    $0x10,%esp
  801a61:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a66:	eb 3d                	jmp    801aa5 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801a68:	85 db                	test   %ebx,%ebx
  801a6a:	74 04                	je     801a70 <devpipe_read+0x26>
				return i;
  801a6c:	89 d8                	mov    %ebx,%eax
  801a6e:	eb 44                	jmp    801ab4 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801a70:	89 f2                	mov    %esi,%edx
  801a72:	89 f8                	mov    %edi,%eax
  801a74:	e8 e5 fe ff ff       	call   80195e <_pipeisclosed>
  801a79:	85 c0                	test   %eax,%eax
  801a7b:	75 32                	jne    801aaf <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801a7d:	e8 d8 f1 ff ff       	call   800c5a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801a82:	8b 06                	mov    (%esi),%eax
  801a84:	3b 46 04             	cmp    0x4(%esi),%eax
  801a87:	74 df                	je     801a68 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a89:	99                   	cltd   
  801a8a:	c1 ea 1b             	shr    $0x1b,%edx
  801a8d:	01 d0                	add    %edx,%eax
  801a8f:	83 e0 1f             	and    $0x1f,%eax
  801a92:	29 d0                	sub    %edx,%eax
  801a94:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801a99:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a9c:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801a9f:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801aa2:	83 c3 01             	add    $0x1,%ebx
  801aa5:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801aa8:	75 d8                	jne    801a82 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801aaa:	8b 45 10             	mov    0x10(%ebp),%eax
  801aad:	eb 05                	jmp    801ab4 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801aaf:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801ab4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ab7:	5b                   	pop    %ebx
  801ab8:	5e                   	pop    %esi
  801ab9:	5f                   	pop    %edi
  801aba:	5d                   	pop    %ebp
  801abb:	c3                   	ret    

00801abc <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801abc:	55                   	push   %ebp
  801abd:	89 e5                	mov    %esp,%ebp
  801abf:	56                   	push   %esi
  801ac0:	53                   	push   %ebx
  801ac1:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ac4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ac7:	50                   	push   %eax
  801ac8:	e8 0c f6 ff ff       	call   8010d9 <fd_alloc>
  801acd:	83 c4 10             	add    $0x10,%esp
  801ad0:	89 c2                	mov    %eax,%edx
  801ad2:	85 c0                	test   %eax,%eax
  801ad4:	0f 88 2c 01 00 00    	js     801c06 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ada:	83 ec 04             	sub    $0x4,%esp
  801add:	68 07 04 00 00       	push   $0x407
  801ae2:	ff 75 f4             	pushl  -0xc(%ebp)
  801ae5:	6a 00                	push   $0x0
  801ae7:	e8 8d f1 ff ff       	call   800c79 <sys_page_alloc>
  801aec:	83 c4 10             	add    $0x10,%esp
  801aef:	89 c2                	mov    %eax,%edx
  801af1:	85 c0                	test   %eax,%eax
  801af3:	0f 88 0d 01 00 00    	js     801c06 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801af9:	83 ec 0c             	sub    $0xc,%esp
  801afc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801aff:	50                   	push   %eax
  801b00:	e8 d4 f5 ff ff       	call   8010d9 <fd_alloc>
  801b05:	89 c3                	mov    %eax,%ebx
  801b07:	83 c4 10             	add    $0x10,%esp
  801b0a:	85 c0                	test   %eax,%eax
  801b0c:	0f 88 e2 00 00 00    	js     801bf4 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b12:	83 ec 04             	sub    $0x4,%esp
  801b15:	68 07 04 00 00       	push   $0x407
  801b1a:	ff 75 f0             	pushl  -0x10(%ebp)
  801b1d:	6a 00                	push   $0x0
  801b1f:	e8 55 f1 ff ff       	call   800c79 <sys_page_alloc>
  801b24:	89 c3                	mov    %eax,%ebx
  801b26:	83 c4 10             	add    $0x10,%esp
  801b29:	85 c0                	test   %eax,%eax
  801b2b:	0f 88 c3 00 00 00    	js     801bf4 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b31:	83 ec 0c             	sub    $0xc,%esp
  801b34:	ff 75 f4             	pushl  -0xc(%ebp)
  801b37:	e8 86 f5 ff ff       	call   8010c2 <fd2data>
  801b3c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b3e:	83 c4 0c             	add    $0xc,%esp
  801b41:	68 07 04 00 00       	push   $0x407
  801b46:	50                   	push   %eax
  801b47:	6a 00                	push   $0x0
  801b49:	e8 2b f1 ff ff       	call   800c79 <sys_page_alloc>
  801b4e:	89 c3                	mov    %eax,%ebx
  801b50:	83 c4 10             	add    $0x10,%esp
  801b53:	85 c0                	test   %eax,%eax
  801b55:	0f 88 89 00 00 00    	js     801be4 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b5b:	83 ec 0c             	sub    $0xc,%esp
  801b5e:	ff 75 f0             	pushl  -0x10(%ebp)
  801b61:	e8 5c f5 ff ff       	call   8010c2 <fd2data>
  801b66:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b6d:	50                   	push   %eax
  801b6e:	6a 00                	push   $0x0
  801b70:	56                   	push   %esi
  801b71:	6a 00                	push   $0x0
  801b73:	e8 44 f1 ff ff       	call   800cbc <sys_page_map>
  801b78:	89 c3                	mov    %eax,%ebx
  801b7a:	83 c4 20             	add    $0x20,%esp
  801b7d:	85 c0                	test   %eax,%eax
  801b7f:	78 55                	js     801bd6 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801b81:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b87:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b8a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b8f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b96:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b9c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b9f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ba1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ba4:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801bab:	83 ec 0c             	sub    $0xc,%esp
  801bae:	ff 75 f4             	pushl  -0xc(%ebp)
  801bb1:	e8 fc f4 ff ff       	call   8010b2 <fd2num>
  801bb6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bb9:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801bbb:	83 c4 04             	add    $0x4,%esp
  801bbe:	ff 75 f0             	pushl  -0x10(%ebp)
  801bc1:	e8 ec f4 ff ff       	call   8010b2 <fd2num>
  801bc6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bc9:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801bcc:	83 c4 10             	add    $0x10,%esp
  801bcf:	ba 00 00 00 00       	mov    $0x0,%edx
  801bd4:	eb 30                	jmp    801c06 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801bd6:	83 ec 08             	sub    $0x8,%esp
  801bd9:	56                   	push   %esi
  801bda:	6a 00                	push   $0x0
  801bdc:	e8 1d f1 ff ff       	call   800cfe <sys_page_unmap>
  801be1:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801be4:	83 ec 08             	sub    $0x8,%esp
  801be7:	ff 75 f0             	pushl  -0x10(%ebp)
  801bea:	6a 00                	push   $0x0
  801bec:	e8 0d f1 ff ff       	call   800cfe <sys_page_unmap>
  801bf1:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801bf4:	83 ec 08             	sub    $0x8,%esp
  801bf7:	ff 75 f4             	pushl  -0xc(%ebp)
  801bfa:	6a 00                	push   $0x0
  801bfc:	e8 fd f0 ff ff       	call   800cfe <sys_page_unmap>
  801c01:	83 c4 10             	add    $0x10,%esp
  801c04:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801c06:	89 d0                	mov    %edx,%eax
  801c08:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c0b:	5b                   	pop    %ebx
  801c0c:	5e                   	pop    %esi
  801c0d:	5d                   	pop    %ebp
  801c0e:	c3                   	ret    

00801c0f <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c0f:	55                   	push   %ebp
  801c10:	89 e5                	mov    %esp,%ebp
  801c12:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c15:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c18:	50                   	push   %eax
  801c19:	ff 75 08             	pushl  0x8(%ebp)
  801c1c:	e8 07 f5 ff ff       	call   801128 <fd_lookup>
  801c21:	83 c4 10             	add    $0x10,%esp
  801c24:	85 c0                	test   %eax,%eax
  801c26:	78 18                	js     801c40 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c28:	83 ec 0c             	sub    $0xc,%esp
  801c2b:	ff 75 f4             	pushl  -0xc(%ebp)
  801c2e:	e8 8f f4 ff ff       	call   8010c2 <fd2data>
	return _pipeisclosed(fd, p);
  801c33:	89 c2                	mov    %eax,%edx
  801c35:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c38:	e8 21 fd ff ff       	call   80195e <_pipeisclosed>
  801c3d:	83 c4 10             	add    $0x10,%esp
}
  801c40:	c9                   	leave  
  801c41:	c3                   	ret    

00801c42 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  801c42:	55                   	push   %ebp
  801c43:	89 e5                	mov    %esp,%ebp
  801c45:	56                   	push   %esi
  801c46:	53                   	push   %ebx
  801c47:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  801c4a:	85 f6                	test   %esi,%esi
  801c4c:	75 16                	jne    801c64 <wait+0x22>
  801c4e:	68 8e 28 80 00       	push   $0x80288e
  801c53:	68 3c 28 80 00       	push   $0x80283c
  801c58:	6a 09                	push   $0x9
  801c5a:	68 99 28 80 00       	push   $0x802899
  801c5f:	e8 b4 e5 ff ff       	call   800218 <_panic>
	e = &envs[ENVX(envid)];
  801c64:	89 f3                	mov    %esi,%ebx
  801c66:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801c6c:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  801c6f:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  801c75:	eb 05                	jmp    801c7c <wait+0x3a>
		sys_yield();
  801c77:	e8 de ef ff ff       	call   800c5a <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801c7c:	8b 43 48             	mov    0x48(%ebx),%eax
  801c7f:	39 c6                	cmp    %eax,%esi
  801c81:	75 07                	jne    801c8a <wait+0x48>
  801c83:	8b 43 54             	mov    0x54(%ebx),%eax
  801c86:	85 c0                	test   %eax,%eax
  801c88:	75 ed                	jne    801c77 <wait+0x35>
		sys_yield();
}
  801c8a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c8d:	5b                   	pop    %ebx
  801c8e:	5e                   	pop    %esi
  801c8f:	5d                   	pop    %ebp
  801c90:	c3                   	ret    

00801c91 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c91:	55                   	push   %ebp
  801c92:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801c94:	b8 00 00 00 00       	mov    $0x0,%eax
  801c99:	5d                   	pop    %ebp
  801c9a:	c3                   	ret    

00801c9b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c9b:	55                   	push   %ebp
  801c9c:	89 e5                	mov    %esp,%ebp
  801c9e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801ca1:	68 a4 28 80 00       	push   $0x8028a4
  801ca6:	ff 75 0c             	pushl  0xc(%ebp)
  801ca9:	e8 c8 eb ff ff       	call   800876 <strcpy>
	return 0;
}
  801cae:	b8 00 00 00 00       	mov    $0x0,%eax
  801cb3:	c9                   	leave  
  801cb4:	c3                   	ret    

00801cb5 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801cb5:	55                   	push   %ebp
  801cb6:	89 e5                	mov    %esp,%ebp
  801cb8:	57                   	push   %edi
  801cb9:	56                   	push   %esi
  801cba:	53                   	push   %ebx
  801cbb:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cc1:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801cc6:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ccc:	eb 2d                	jmp    801cfb <devcons_write+0x46>
		m = n - tot;
  801cce:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801cd1:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801cd3:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801cd6:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801cdb:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801cde:	83 ec 04             	sub    $0x4,%esp
  801ce1:	53                   	push   %ebx
  801ce2:	03 45 0c             	add    0xc(%ebp),%eax
  801ce5:	50                   	push   %eax
  801ce6:	57                   	push   %edi
  801ce7:	e8 1c ed ff ff       	call   800a08 <memmove>
		sys_cputs(buf, m);
  801cec:	83 c4 08             	add    $0x8,%esp
  801cef:	53                   	push   %ebx
  801cf0:	57                   	push   %edi
  801cf1:	e8 c7 ee ff ff       	call   800bbd <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cf6:	01 de                	add    %ebx,%esi
  801cf8:	83 c4 10             	add    $0x10,%esp
  801cfb:	89 f0                	mov    %esi,%eax
  801cfd:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d00:	72 cc                	jb     801cce <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d02:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d05:	5b                   	pop    %ebx
  801d06:	5e                   	pop    %esi
  801d07:	5f                   	pop    %edi
  801d08:	5d                   	pop    %ebp
  801d09:	c3                   	ret    

00801d0a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d0a:	55                   	push   %ebp
  801d0b:	89 e5                	mov    %esp,%ebp
  801d0d:	83 ec 08             	sub    $0x8,%esp
  801d10:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801d15:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d19:	74 2a                	je     801d45 <devcons_read+0x3b>
  801d1b:	eb 05                	jmp    801d22 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d1d:	e8 38 ef ff ff       	call   800c5a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d22:	e8 b4 ee ff ff       	call   800bdb <sys_cgetc>
  801d27:	85 c0                	test   %eax,%eax
  801d29:	74 f2                	je     801d1d <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801d2b:	85 c0                	test   %eax,%eax
  801d2d:	78 16                	js     801d45 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d2f:	83 f8 04             	cmp    $0x4,%eax
  801d32:	74 0c                	je     801d40 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801d34:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d37:	88 02                	mov    %al,(%edx)
	return 1;
  801d39:	b8 01 00 00 00       	mov    $0x1,%eax
  801d3e:	eb 05                	jmp    801d45 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801d40:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801d45:	c9                   	leave  
  801d46:	c3                   	ret    

00801d47 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801d47:	55                   	push   %ebp
  801d48:	89 e5                	mov    %esp,%ebp
  801d4a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801d4d:	8b 45 08             	mov    0x8(%ebp),%eax
  801d50:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801d53:	6a 01                	push   $0x1
  801d55:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d58:	50                   	push   %eax
  801d59:	e8 5f ee ff ff       	call   800bbd <sys_cputs>
}
  801d5e:	83 c4 10             	add    $0x10,%esp
  801d61:	c9                   	leave  
  801d62:	c3                   	ret    

00801d63 <getchar>:

int
getchar(void)
{
  801d63:	55                   	push   %ebp
  801d64:	89 e5                	mov    %esp,%ebp
  801d66:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801d69:	6a 01                	push   $0x1
  801d6b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d6e:	50                   	push   %eax
  801d6f:	6a 00                	push   $0x0
  801d71:	e8 18 f6 ff ff       	call   80138e <read>
	if (r < 0)
  801d76:	83 c4 10             	add    $0x10,%esp
  801d79:	85 c0                	test   %eax,%eax
  801d7b:	78 0f                	js     801d8c <getchar+0x29>
		return r;
	if (r < 1)
  801d7d:	85 c0                	test   %eax,%eax
  801d7f:	7e 06                	jle    801d87 <getchar+0x24>
		return -E_EOF;
	return c;
  801d81:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801d85:	eb 05                	jmp    801d8c <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801d87:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801d8c:	c9                   	leave  
  801d8d:	c3                   	ret    

00801d8e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801d8e:	55                   	push   %ebp
  801d8f:	89 e5                	mov    %esp,%ebp
  801d91:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d94:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d97:	50                   	push   %eax
  801d98:	ff 75 08             	pushl  0x8(%ebp)
  801d9b:	e8 88 f3 ff ff       	call   801128 <fd_lookup>
  801da0:	83 c4 10             	add    $0x10,%esp
  801da3:	85 c0                	test   %eax,%eax
  801da5:	78 11                	js     801db8 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801da7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801daa:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801db0:	39 10                	cmp    %edx,(%eax)
  801db2:	0f 94 c0             	sete   %al
  801db5:	0f b6 c0             	movzbl %al,%eax
}
  801db8:	c9                   	leave  
  801db9:	c3                   	ret    

00801dba <opencons>:

int
opencons(void)
{
  801dba:	55                   	push   %ebp
  801dbb:	89 e5                	mov    %esp,%ebp
  801dbd:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801dc0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dc3:	50                   	push   %eax
  801dc4:	e8 10 f3 ff ff       	call   8010d9 <fd_alloc>
  801dc9:	83 c4 10             	add    $0x10,%esp
		return r;
  801dcc:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801dce:	85 c0                	test   %eax,%eax
  801dd0:	78 3e                	js     801e10 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801dd2:	83 ec 04             	sub    $0x4,%esp
  801dd5:	68 07 04 00 00       	push   $0x407
  801dda:	ff 75 f4             	pushl  -0xc(%ebp)
  801ddd:	6a 00                	push   $0x0
  801ddf:	e8 95 ee ff ff       	call   800c79 <sys_page_alloc>
  801de4:	83 c4 10             	add    $0x10,%esp
		return r;
  801de7:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801de9:	85 c0                	test   %eax,%eax
  801deb:	78 23                	js     801e10 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ded:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801df3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801df6:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801df8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dfb:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e02:	83 ec 0c             	sub    $0xc,%esp
  801e05:	50                   	push   %eax
  801e06:	e8 a7 f2 ff ff       	call   8010b2 <fd2num>
  801e0b:	89 c2                	mov    %eax,%edx
  801e0d:	83 c4 10             	add    $0x10,%esp
}
  801e10:	89 d0                	mov    %edx,%eax
  801e12:	c9                   	leave  
  801e13:	c3                   	ret    

00801e14 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801e14:	55                   	push   %ebp
  801e15:	89 e5                	mov    %esp,%ebp
  801e17:	53                   	push   %ebx
  801e18:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  801e1b:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801e22:	75 28                	jne    801e4c <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  801e24:	e8 12 ee ff ff       	call   800c3b <sys_getenvid>
  801e29:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_U | PTE_W);
  801e2b:	83 ec 04             	sub    $0x4,%esp
  801e2e:	6a 06                	push   $0x6
  801e30:	68 00 f0 bf ee       	push   $0xeebff000
  801e35:	50                   	push   %eax
  801e36:	e8 3e ee ff ff       	call   800c79 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  801e3b:	83 c4 08             	add    $0x8,%esp
  801e3e:	68 59 1e 80 00       	push   $0x801e59
  801e43:	53                   	push   %ebx
  801e44:	e8 7b ef ff ff       	call   800dc4 <sys_env_set_pgfault_upcall>
  801e49:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801e4c:	8b 45 08             	mov    0x8(%ebp),%eax
  801e4f:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801e54:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e57:	c9                   	leave  
  801e58:	c3                   	ret    

00801e59 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e59:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e5a:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e5f:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e61:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	# My method is different. Copy the values to the other stack
	# in a convinient way, and then pop everything.
	movl %esp, %ebp		# ebp refers to the exception stack
  801e64:	89 e5                	mov    %esp,%ebp
	movl 48(%ebp), %esp 	# go to other stack
  801e66:	8b 65 30             	mov    0x30(%ebp),%esp

	pushl 40(%ebp)		# eip - ORDER SWITCHED WITH EFLAGS
  801e69:	ff 75 28             	pushl  0x28(%ebp)
	pushl 44(%ebp)      	# eflags
  801e6c:	ff 75 2c             	pushl  0x2c(%ebp)
	pushl 36(%ebp)		# all the 8 remaining regs
  801e6f:	ff 75 24             	pushl  0x24(%ebp)
	pushl 32(%ebp)
  801e72:	ff 75 20             	pushl  0x20(%ebp)
	pushl 28(%ebp)
  801e75:	ff 75 1c             	pushl  0x1c(%ebp)
	pushl 24(%ebp)
  801e78:	ff 75 18             	pushl  0x18(%ebp)
	pushl 20(%ebp)
  801e7b:	ff 75 14             	pushl  0x14(%ebp)
	pushl 16(%ebp)
  801e7e:	ff 75 10             	pushl  0x10(%ebp)
	pushl 12(%ebp)
  801e81:	ff 75 0c             	pushl  0xc(%ebp)
	pushl 8(%ebp)
  801e84:	ff 75 08             	pushl  0x8(%ebp)

	popal			# now just pop everything!
  801e87:	61                   	popa   
	popfl
  801e88:	9d                   	popf   
	ret
  801e89:	c3                   	ret    

00801e8a <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e8a:	55                   	push   %ebp
  801e8b:	89 e5                	mov    %esp,%ebp
  801e8d:	56                   	push   %esi
  801e8e:	53                   	push   %ebx
  801e8f:	8b 75 08             	mov    0x8(%ebp),%esi
  801e92:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e95:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  801e98:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801e9a:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801e9f:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  801ea2:	83 ec 0c             	sub    $0xc,%esp
  801ea5:	50                   	push   %eax
  801ea6:	e8 7e ef ff ff       	call   800e29 <sys_ipc_recv>

	if (r < 0) {
  801eab:	83 c4 10             	add    $0x10,%esp
  801eae:	85 c0                	test   %eax,%eax
  801eb0:	79 16                	jns    801ec8 <ipc_recv+0x3e>
		if (from_env_store)
  801eb2:	85 f6                	test   %esi,%esi
  801eb4:	74 06                	je     801ebc <ipc_recv+0x32>
			*from_env_store = 0;
  801eb6:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  801ebc:	85 db                	test   %ebx,%ebx
  801ebe:	74 2c                	je     801eec <ipc_recv+0x62>
			*perm_store = 0;
  801ec0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801ec6:	eb 24                	jmp    801eec <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  801ec8:	85 f6                	test   %esi,%esi
  801eca:	74 0a                	je     801ed6 <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  801ecc:	a1 20 44 80 00       	mov    0x804420,%eax
  801ed1:	8b 40 74             	mov    0x74(%eax),%eax
  801ed4:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  801ed6:	85 db                	test   %ebx,%ebx
  801ed8:	74 0a                	je     801ee4 <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  801eda:	a1 20 44 80 00       	mov    0x804420,%eax
  801edf:	8b 40 78             	mov    0x78(%eax),%eax
  801ee2:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  801ee4:	a1 20 44 80 00       	mov    0x804420,%eax
  801ee9:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  801eec:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801eef:	5b                   	pop    %ebx
  801ef0:	5e                   	pop    %esi
  801ef1:	5d                   	pop    %ebp
  801ef2:	c3                   	ret    

00801ef3 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ef3:	55                   	push   %ebp
  801ef4:	89 e5                	mov    %esp,%ebp
  801ef6:	57                   	push   %edi
  801ef7:	56                   	push   %esi
  801ef8:	53                   	push   %ebx
  801ef9:	83 ec 0c             	sub    $0xc,%esp
  801efc:	8b 7d 08             	mov    0x8(%ebp),%edi
  801eff:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f02:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  801f05:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801f07:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801f0c:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  801f0f:	ff 75 14             	pushl  0x14(%ebp)
  801f12:	53                   	push   %ebx
  801f13:	56                   	push   %esi
  801f14:	57                   	push   %edi
  801f15:	e8 ec ee ff ff       	call   800e06 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  801f1a:	83 c4 10             	add    $0x10,%esp
  801f1d:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f20:	75 07                	jne    801f29 <ipc_send+0x36>
			sys_yield();
  801f22:	e8 33 ed ff ff       	call   800c5a <sys_yield>
  801f27:	eb e6                	jmp    801f0f <ipc_send+0x1c>
		} else if (r < 0) {
  801f29:	85 c0                	test   %eax,%eax
  801f2b:	79 12                	jns    801f3f <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  801f2d:	50                   	push   %eax
  801f2e:	68 b0 28 80 00       	push   $0x8028b0
  801f33:	6a 51                	push   $0x51
  801f35:	68 bd 28 80 00       	push   $0x8028bd
  801f3a:	e8 d9 e2 ff ff       	call   800218 <_panic>
		}
	}
}
  801f3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f42:	5b                   	pop    %ebx
  801f43:	5e                   	pop    %esi
  801f44:	5f                   	pop    %edi
  801f45:	5d                   	pop    %ebp
  801f46:	c3                   	ret    

00801f47 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f47:	55                   	push   %ebp
  801f48:	89 e5                	mov    %esp,%ebp
  801f4a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f4d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f52:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f55:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f5b:	8b 52 50             	mov    0x50(%edx),%edx
  801f5e:	39 ca                	cmp    %ecx,%edx
  801f60:	75 0d                	jne    801f6f <ipc_find_env+0x28>
			return envs[i].env_id;
  801f62:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f65:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f6a:	8b 40 48             	mov    0x48(%eax),%eax
  801f6d:	eb 0f                	jmp    801f7e <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f6f:	83 c0 01             	add    $0x1,%eax
  801f72:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f77:	75 d9                	jne    801f52 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f79:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f7e:	5d                   	pop    %ebp
  801f7f:	c3                   	ret    

00801f80 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f80:	55                   	push   %ebp
  801f81:	89 e5                	mov    %esp,%ebp
  801f83:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f86:	89 d0                	mov    %edx,%eax
  801f88:	c1 e8 16             	shr    $0x16,%eax
  801f8b:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f92:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f97:	f6 c1 01             	test   $0x1,%cl
  801f9a:	74 1d                	je     801fb9 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f9c:	c1 ea 0c             	shr    $0xc,%edx
  801f9f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fa6:	f6 c2 01             	test   $0x1,%dl
  801fa9:	74 0e                	je     801fb9 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fab:	c1 ea 0c             	shr    $0xc,%edx
  801fae:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fb5:	ef 
  801fb6:	0f b7 c0             	movzwl %ax,%eax
}
  801fb9:	5d                   	pop    %ebp
  801fba:	c3                   	ret    
  801fbb:	66 90                	xchg   %ax,%ax
  801fbd:	66 90                	xchg   %ax,%ax
  801fbf:	90                   	nop

00801fc0 <__udivdi3>:
  801fc0:	55                   	push   %ebp
  801fc1:	57                   	push   %edi
  801fc2:	56                   	push   %esi
  801fc3:	53                   	push   %ebx
  801fc4:	83 ec 1c             	sub    $0x1c,%esp
  801fc7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801fcb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801fcf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801fd3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801fd7:	85 f6                	test   %esi,%esi
  801fd9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fdd:	89 ca                	mov    %ecx,%edx
  801fdf:	89 f8                	mov    %edi,%eax
  801fe1:	75 3d                	jne    802020 <__udivdi3+0x60>
  801fe3:	39 cf                	cmp    %ecx,%edi
  801fe5:	0f 87 c5 00 00 00    	ja     8020b0 <__udivdi3+0xf0>
  801feb:	85 ff                	test   %edi,%edi
  801fed:	89 fd                	mov    %edi,%ebp
  801fef:	75 0b                	jne    801ffc <__udivdi3+0x3c>
  801ff1:	b8 01 00 00 00       	mov    $0x1,%eax
  801ff6:	31 d2                	xor    %edx,%edx
  801ff8:	f7 f7                	div    %edi
  801ffa:	89 c5                	mov    %eax,%ebp
  801ffc:	89 c8                	mov    %ecx,%eax
  801ffe:	31 d2                	xor    %edx,%edx
  802000:	f7 f5                	div    %ebp
  802002:	89 c1                	mov    %eax,%ecx
  802004:	89 d8                	mov    %ebx,%eax
  802006:	89 cf                	mov    %ecx,%edi
  802008:	f7 f5                	div    %ebp
  80200a:	89 c3                	mov    %eax,%ebx
  80200c:	89 d8                	mov    %ebx,%eax
  80200e:	89 fa                	mov    %edi,%edx
  802010:	83 c4 1c             	add    $0x1c,%esp
  802013:	5b                   	pop    %ebx
  802014:	5e                   	pop    %esi
  802015:	5f                   	pop    %edi
  802016:	5d                   	pop    %ebp
  802017:	c3                   	ret    
  802018:	90                   	nop
  802019:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802020:	39 ce                	cmp    %ecx,%esi
  802022:	77 74                	ja     802098 <__udivdi3+0xd8>
  802024:	0f bd fe             	bsr    %esi,%edi
  802027:	83 f7 1f             	xor    $0x1f,%edi
  80202a:	0f 84 98 00 00 00    	je     8020c8 <__udivdi3+0x108>
  802030:	bb 20 00 00 00       	mov    $0x20,%ebx
  802035:	89 f9                	mov    %edi,%ecx
  802037:	89 c5                	mov    %eax,%ebp
  802039:	29 fb                	sub    %edi,%ebx
  80203b:	d3 e6                	shl    %cl,%esi
  80203d:	89 d9                	mov    %ebx,%ecx
  80203f:	d3 ed                	shr    %cl,%ebp
  802041:	89 f9                	mov    %edi,%ecx
  802043:	d3 e0                	shl    %cl,%eax
  802045:	09 ee                	or     %ebp,%esi
  802047:	89 d9                	mov    %ebx,%ecx
  802049:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80204d:	89 d5                	mov    %edx,%ebp
  80204f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802053:	d3 ed                	shr    %cl,%ebp
  802055:	89 f9                	mov    %edi,%ecx
  802057:	d3 e2                	shl    %cl,%edx
  802059:	89 d9                	mov    %ebx,%ecx
  80205b:	d3 e8                	shr    %cl,%eax
  80205d:	09 c2                	or     %eax,%edx
  80205f:	89 d0                	mov    %edx,%eax
  802061:	89 ea                	mov    %ebp,%edx
  802063:	f7 f6                	div    %esi
  802065:	89 d5                	mov    %edx,%ebp
  802067:	89 c3                	mov    %eax,%ebx
  802069:	f7 64 24 0c          	mull   0xc(%esp)
  80206d:	39 d5                	cmp    %edx,%ebp
  80206f:	72 10                	jb     802081 <__udivdi3+0xc1>
  802071:	8b 74 24 08          	mov    0x8(%esp),%esi
  802075:	89 f9                	mov    %edi,%ecx
  802077:	d3 e6                	shl    %cl,%esi
  802079:	39 c6                	cmp    %eax,%esi
  80207b:	73 07                	jae    802084 <__udivdi3+0xc4>
  80207d:	39 d5                	cmp    %edx,%ebp
  80207f:	75 03                	jne    802084 <__udivdi3+0xc4>
  802081:	83 eb 01             	sub    $0x1,%ebx
  802084:	31 ff                	xor    %edi,%edi
  802086:	89 d8                	mov    %ebx,%eax
  802088:	89 fa                	mov    %edi,%edx
  80208a:	83 c4 1c             	add    $0x1c,%esp
  80208d:	5b                   	pop    %ebx
  80208e:	5e                   	pop    %esi
  80208f:	5f                   	pop    %edi
  802090:	5d                   	pop    %ebp
  802091:	c3                   	ret    
  802092:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802098:	31 ff                	xor    %edi,%edi
  80209a:	31 db                	xor    %ebx,%ebx
  80209c:	89 d8                	mov    %ebx,%eax
  80209e:	89 fa                	mov    %edi,%edx
  8020a0:	83 c4 1c             	add    $0x1c,%esp
  8020a3:	5b                   	pop    %ebx
  8020a4:	5e                   	pop    %esi
  8020a5:	5f                   	pop    %edi
  8020a6:	5d                   	pop    %ebp
  8020a7:	c3                   	ret    
  8020a8:	90                   	nop
  8020a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020b0:	89 d8                	mov    %ebx,%eax
  8020b2:	f7 f7                	div    %edi
  8020b4:	31 ff                	xor    %edi,%edi
  8020b6:	89 c3                	mov    %eax,%ebx
  8020b8:	89 d8                	mov    %ebx,%eax
  8020ba:	89 fa                	mov    %edi,%edx
  8020bc:	83 c4 1c             	add    $0x1c,%esp
  8020bf:	5b                   	pop    %ebx
  8020c0:	5e                   	pop    %esi
  8020c1:	5f                   	pop    %edi
  8020c2:	5d                   	pop    %ebp
  8020c3:	c3                   	ret    
  8020c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020c8:	39 ce                	cmp    %ecx,%esi
  8020ca:	72 0c                	jb     8020d8 <__udivdi3+0x118>
  8020cc:	31 db                	xor    %ebx,%ebx
  8020ce:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8020d2:	0f 87 34 ff ff ff    	ja     80200c <__udivdi3+0x4c>
  8020d8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8020dd:	e9 2a ff ff ff       	jmp    80200c <__udivdi3+0x4c>
  8020e2:	66 90                	xchg   %ax,%ax
  8020e4:	66 90                	xchg   %ax,%ax
  8020e6:	66 90                	xchg   %ax,%ax
  8020e8:	66 90                	xchg   %ax,%ax
  8020ea:	66 90                	xchg   %ax,%ax
  8020ec:	66 90                	xchg   %ax,%ax
  8020ee:	66 90                	xchg   %ax,%ax

008020f0 <__umoddi3>:
  8020f0:	55                   	push   %ebp
  8020f1:	57                   	push   %edi
  8020f2:	56                   	push   %esi
  8020f3:	53                   	push   %ebx
  8020f4:	83 ec 1c             	sub    $0x1c,%esp
  8020f7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8020fb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8020ff:	8b 74 24 34          	mov    0x34(%esp),%esi
  802103:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802107:	85 d2                	test   %edx,%edx
  802109:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80210d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802111:	89 f3                	mov    %esi,%ebx
  802113:	89 3c 24             	mov    %edi,(%esp)
  802116:	89 74 24 04          	mov    %esi,0x4(%esp)
  80211a:	75 1c                	jne    802138 <__umoddi3+0x48>
  80211c:	39 f7                	cmp    %esi,%edi
  80211e:	76 50                	jbe    802170 <__umoddi3+0x80>
  802120:	89 c8                	mov    %ecx,%eax
  802122:	89 f2                	mov    %esi,%edx
  802124:	f7 f7                	div    %edi
  802126:	89 d0                	mov    %edx,%eax
  802128:	31 d2                	xor    %edx,%edx
  80212a:	83 c4 1c             	add    $0x1c,%esp
  80212d:	5b                   	pop    %ebx
  80212e:	5e                   	pop    %esi
  80212f:	5f                   	pop    %edi
  802130:	5d                   	pop    %ebp
  802131:	c3                   	ret    
  802132:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802138:	39 f2                	cmp    %esi,%edx
  80213a:	89 d0                	mov    %edx,%eax
  80213c:	77 52                	ja     802190 <__umoddi3+0xa0>
  80213e:	0f bd ea             	bsr    %edx,%ebp
  802141:	83 f5 1f             	xor    $0x1f,%ebp
  802144:	75 5a                	jne    8021a0 <__umoddi3+0xb0>
  802146:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80214a:	0f 82 e0 00 00 00    	jb     802230 <__umoddi3+0x140>
  802150:	39 0c 24             	cmp    %ecx,(%esp)
  802153:	0f 86 d7 00 00 00    	jbe    802230 <__umoddi3+0x140>
  802159:	8b 44 24 08          	mov    0x8(%esp),%eax
  80215d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802161:	83 c4 1c             	add    $0x1c,%esp
  802164:	5b                   	pop    %ebx
  802165:	5e                   	pop    %esi
  802166:	5f                   	pop    %edi
  802167:	5d                   	pop    %ebp
  802168:	c3                   	ret    
  802169:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802170:	85 ff                	test   %edi,%edi
  802172:	89 fd                	mov    %edi,%ebp
  802174:	75 0b                	jne    802181 <__umoddi3+0x91>
  802176:	b8 01 00 00 00       	mov    $0x1,%eax
  80217b:	31 d2                	xor    %edx,%edx
  80217d:	f7 f7                	div    %edi
  80217f:	89 c5                	mov    %eax,%ebp
  802181:	89 f0                	mov    %esi,%eax
  802183:	31 d2                	xor    %edx,%edx
  802185:	f7 f5                	div    %ebp
  802187:	89 c8                	mov    %ecx,%eax
  802189:	f7 f5                	div    %ebp
  80218b:	89 d0                	mov    %edx,%eax
  80218d:	eb 99                	jmp    802128 <__umoddi3+0x38>
  80218f:	90                   	nop
  802190:	89 c8                	mov    %ecx,%eax
  802192:	89 f2                	mov    %esi,%edx
  802194:	83 c4 1c             	add    $0x1c,%esp
  802197:	5b                   	pop    %ebx
  802198:	5e                   	pop    %esi
  802199:	5f                   	pop    %edi
  80219a:	5d                   	pop    %ebp
  80219b:	c3                   	ret    
  80219c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021a0:	8b 34 24             	mov    (%esp),%esi
  8021a3:	bf 20 00 00 00       	mov    $0x20,%edi
  8021a8:	89 e9                	mov    %ebp,%ecx
  8021aa:	29 ef                	sub    %ebp,%edi
  8021ac:	d3 e0                	shl    %cl,%eax
  8021ae:	89 f9                	mov    %edi,%ecx
  8021b0:	89 f2                	mov    %esi,%edx
  8021b2:	d3 ea                	shr    %cl,%edx
  8021b4:	89 e9                	mov    %ebp,%ecx
  8021b6:	09 c2                	or     %eax,%edx
  8021b8:	89 d8                	mov    %ebx,%eax
  8021ba:	89 14 24             	mov    %edx,(%esp)
  8021bd:	89 f2                	mov    %esi,%edx
  8021bf:	d3 e2                	shl    %cl,%edx
  8021c1:	89 f9                	mov    %edi,%ecx
  8021c3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021c7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8021cb:	d3 e8                	shr    %cl,%eax
  8021cd:	89 e9                	mov    %ebp,%ecx
  8021cf:	89 c6                	mov    %eax,%esi
  8021d1:	d3 e3                	shl    %cl,%ebx
  8021d3:	89 f9                	mov    %edi,%ecx
  8021d5:	89 d0                	mov    %edx,%eax
  8021d7:	d3 e8                	shr    %cl,%eax
  8021d9:	89 e9                	mov    %ebp,%ecx
  8021db:	09 d8                	or     %ebx,%eax
  8021dd:	89 d3                	mov    %edx,%ebx
  8021df:	89 f2                	mov    %esi,%edx
  8021e1:	f7 34 24             	divl   (%esp)
  8021e4:	89 d6                	mov    %edx,%esi
  8021e6:	d3 e3                	shl    %cl,%ebx
  8021e8:	f7 64 24 04          	mull   0x4(%esp)
  8021ec:	39 d6                	cmp    %edx,%esi
  8021ee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021f2:	89 d1                	mov    %edx,%ecx
  8021f4:	89 c3                	mov    %eax,%ebx
  8021f6:	72 08                	jb     802200 <__umoddi3+0x110>
  8021f8:	75 11                	jne    80220b <__umoddi3+0x11b>
  8021fa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8021fe:	73 0b                	jae    80220b <__umoddi3+0x11b>
  802200:	2b 44 24 04          	sub    0x4(%esp),%eax
  802204:	1b 14 24             	sbb    (%esp),%edx
  802207:	89 d1                	mov    %edx,%ecx
  802209:	89 c3                	mov    %eax,%ebx
  80220b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80220f:	29 da                	sub    %ebx,%edx
  802211:	19 ce                	sbb    %ecx,%esi
  802213:	89 f9                	mov    %edi,%ecx
  802215:	89 f0                	mov    %esi,%eax
  802217:	d3 e0                	shl    %cl,%eax
  802219:	89 e9                	mov    %ebp,%ecx
  80221b:	d3 ea                	shr    %cl,%edx
  80221d:	89 e9                	mov    %ebp,%ecx
  80221f:	d3 ee                	shr    %cl,%esi
  802221:	09 d0                	or     %edx,%eax
  802223:	89 f2                	mov    %esi,%edx
  802225:	83 c4 1c             	add    $0x1c,%esp
  802228:	5b                   	pop    %ebx
  802229:	5e                   	pop    %esi
  80222a:	5f                   	pop    %edi
  80222b:	5d                   	pop    %ebp
  80222c:	c3                   	ret    
  80222d:	8d 76 00             	lea    0x0(%esi),%esi
  802230:	29 f9                	sub    %edi,%ecx
  802232:	19 d6                	sbb    %edx,%esi
  802234:	89 74 24 04          	mov    %esi,0x4(%esp)
  802238:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80223c:	e9 18 ff ff ff       	jmp    802159 <__umoddi3+0x69>
