
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
  80003e:	68 c0 22 80 00       	push   $0x8022c0
  800043:	e8 5b 18 00 00       	call   8018a3 <open>
  800048:	89 c3                	mov    %eax,%ebx
  80004a:	83 c4 10             	add    $0x10,%esp
  80004d:	85 c0                	test   %eax,%eax
  80004f:	79 12                	jns    800063 <umain+0x30>
		panic("open motd: %e", fd);
  800051:	50                   	push   %eax
  800052:	68 c5 22 80 00       	push   $0x8022c5
  800057:	6a 0c                	push   $0xc
  800059:	68 d3 22 80 00       	push   $0x8022d3
  80005e:	e8 b5 01 00 00       	call   800218 <_panic>
	seek(fd, 0);
  800063:	83 ec 08             	sub    $0x8,%esp
  800066:	6a 00                	push   $0x0
  800068:	50                   	push   %eax
  800069:	e8 e7 14 00 00       	call   801555 <seek>
	if ((n = readn(fd, buf, sizeof buf)) <= 0)
  80006e:	83 c4 0c             	add    $0xc,%esp
  800071:	68 00 02 00 00       	push   $0x200
  800076:	68 20 42 80 00       	push   $0x804220
  80007b:	53                   	push   %ebx
  80007c:	e8 ff 13 00 00       	call   801480 <readn>
  800081:	89 c6                	mov    %eax,%esi
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	85 c0                	test   %eax,%eax
  800088:	7f 12                	jg     80009c <umain+0x69>
		panic("readn: %e", n);
  80008a:	50                   	push   %eax
  80008b:	68 e8 22 80 00       	push   $0x8022e8
  800090:	6a 0f                	push   $0xf
  800092:	68 d3 22 80 00       	push   $0x8022d3
  800097:	e8 7c 01 00 00       	call   800218 <_panic>

	if ((r = fork()) < 0)
  80009c:	e8 7d 0f 00 00       	call   80101e <fork>
  8000a1:	89 c7                	mov    %eax,%edi
  8000a3:	85 c0                	test   %eax,%eax
  8000a5:	79 12                	jns    8000b9 <umain+0x86>
		panic("fork: %e", r);
  8000a7:	50                   	push   %eax
  8000a8:	68 93 27 80 00       	push   $0x802793
  8000ad:	6a 12                	push   $0x12
  8000af:	68 d3 22 80 00       	push   $0x8022d3
  8000b4:	e8 5f 01 00 00       	call   800218 <_panic>
	if (r == 0) {
  8000b9:	85 c0                	test   %eax,%eax
  8000bb:	0f 85 9d 00 00 00    	jne    80015e <umain+0x12b>
		seek(fd, 0);
  8000c1:	83 ec 08             	sub    $0x8,%esp
  8000c4:	6a 00                	push   $0x0
  8000c6:	53                   	push   %ebx
  8000c7:	e8 89 14 00 00       	call   801555 <seek>
		cprintf("going to read in child (might page fault if your sharing is buggy)\n");
  8000cc:	c7 04 24 28 23 80 00 	movl   $0x802328,(%esp)
  8000d3:	e8 19 02 00 00       	call   8002f1 <cprintf>
		if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  8000d8:	83 c4 0c             	add    $0xc,%esp
  8000db:	68 00 02 00 00       	push   $0x200
  8000e0:	68 20 40 80 00       	push   $0x804020
  8000e5:	53                   	push   %ebx
  8000e6:	e8 95 13 00 00       	call   801480 <readn>
  8000eb:	83 c4 10             	add    $0x10,%esp
  8000ee:	39 c6                	cmp    %eax,%esi
  8000f0:	74 16                	je     800108 <umain+0xd5>
			panic("read in parent got %d, read in child got %d", n, n2);
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	50                   	push   %eax
  8000f6:	56                   	push   %esi
  8000f7:	68 6c 23 80 00       	push   $0x80236c
  8000fc:	6a 17                	push   $0x17
  8000fe:	68 d3 22 80 00       	push   $0x8022d3
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
  800125:	68 98 23 80 00       	push   $0x802398
  80012a:	6a 19                	push   $0x19
  80012c:	68 d3 22 80 00       	push   $0x8022d3
  800131:	e8 e2 00 00 00       	call   800218 <_panic>
		cprintf("read in child succeeded\n");
  800136:	83 ec 0c             	sub    $0xc,%esp
  800139:	68 f2 22 80 00       	push   $0x8022f2
  80013e:	e8 ae 01 00 00       	call   8002f1 <cprintf>
		seek(fd, 0);
  800143:	83 c4 08             	add    $0x8,%esp
  800146:	6a 00                	push   $0x0
  800148:	53                   	push   %ebx
  800149:	e8 07 14 00 00       	call   801555 <seek>
		close(fd);
  80014e:	89 1c 24             	mov    %ebx,(%esp)
  800151:	e8 5d 11 00 00       	call   8012b3 <close>
		exit();
  800156:	e8 a3 00 00 00       	call   8001fe <exit>
  80015b:	83 c4 10             	add    $0x10,%esp
	}
	wait(r);
  80015e:	83 ec 0c             	sub    $0xc,%esp
  800161:	57                   	push   %edi
  800162:	e8 3c 1b 00 00       	call   801ca3 <wait>
	if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  800167:	83 c4 0c             	add    $0xc,%esp
  80016a:	68 00 02 00 00       	push   $0x200
  80016f:	68 20 40 80 00       	push   $0x804020
  800174:	53                   	push   %ebx
  800175:	e8 06 13 00 00       	call   801480 <readn>
  80017a:	83 c4 10             	add    $0x10,%esp
  80017d:	39 c6                	cmp    %eax,%esi
  80017f:	74 16                	je     800197 <umain+0x164>
		panic("read in parent got %d, then got %d", n, n2);
  800181:	83 ec 0c             	sub    $0xc,%esp
  800184:	50                   	push   %eax
  800185:	56                   	push   %esi
  800186:	68 d0 23 80 00       	push   $0x8023d0
  80018b:	6a 21                	push   $0x21
  80018d:	68 d3 22 80 00       	push   $0x8022d3
  800192:	e8 81 00 00 00       	call   800218 <_panic>
	cprintf("read in parent succeeded\n");
  800197:	83 ec 0c             	sub    $0xc,%esp
  80019a:	68 0b 23 80 00       	push   $0x80230b
  80019f:	e8 4d 01 00 00       	call   8002f1 <cprintf>
	close(fd);
  8001a4:	89 1c 24             	mov    %ebx,(%esp)
  8001a7:	e8 07 11 00 00       	call   8012b3 <close>
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
  800204:	e8 d5 10 00 00       	call   8012de <close_all>
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
  800236:	68 00 24 80 00       	push   $0x802400
  80023b:	e8 b1 00 00 00       	call   8002f1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800240:	83 c4 18             	add    $0x18,%esp
  800243:	53                   	push   %ebx
  800244:	ff 75 10             	pushl  0x10(%ebp)
  800247:	e8 54 00 00 00       	call   8002a0 <vcprintf>
	cprintf("\n");
  80024c:	c7 04 24 09 23 80 00 	movl   $0x802309,(%esp)
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
  800354:	e8 c7 1c 00 00       	call   802020 <__udivdi3>
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
  800397:	e8 b4 1d 00 00       	call   802150 <__umoddi3>
  80039c:	83 c4 14             	add    $0x14,%esp
  80039f:	0f be 80 23 24 80 00 	movsbl 0x802423(%eax),%eax
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
  80049b:	ff 24 85 60 25 80 00 	jmp    *0x802560(,%eax,4)
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
  80055f:	8b 14 85 c0 26 80 00 	mov    0x8026c0(,%eax,4),%edx
  800566:	85 d2                	test   %edx,%edx
  800568:	75 18                	jne    800582 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80056a:	50                   	push   %eax
  80056b:	68 3b 24 80 00       	push   $0x80243b
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
  800583:	68 7a 28 80 00       	push   $0x80287a
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
  8005a7:	b8 34 24 80 00       	mov    $0x802434,%eax
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
  800c22:	68 1f 27 80 00       	push   $0x80271f
  800c27:	6a 23                	push   $0x23
  800c29:	68 3c 27 80 00       	push   $0x80273c
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
  800ca3:	68 1f 27 80 00       	push   $0x80271f
  800ca8:	6a 23                	push   $0x23
  800caa:	68 3c 27 80 00       	push   $0x80273c
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
  800ce5:	68 1f 27 80 00       	push   $0x80271f
  800cea:	6a 23                	push   $0x23
  800cec:	68 3c 27 80 00       	push   $0x80273c
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
  800d27:	68 1f 27 80 00       	push   $0x80271f
  800d2c:	6a 23                	push   $0x23
  800d2e:	68 3c 27 80 00       	push   $0x80273c
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
  800d69:	68 1f 27 80 00       	push   $0x80271f
  800d6e:	6a 23                	push   $0x23
  800d70:	68 3c 27 80 00       	push   $0x80273c
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
  800dab:	68 1f 27 80 00       	push   $0x80271f
  800db0:	6a 23                	push   $0x23
  800db2:	68 3c 27 80 00       	push   $0x80273c
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
  800ded:	68 1f 27 80 00       	push   $0x80271f
  800df2:	6a 23                	push   $0x23
  800df4:	68 3c 27 80 00       	push   $0x80273c
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
  800e51:	68 1f 27 80 00       	push   $0x80271f
  800e56:	6a 23                	push   $0x23
  800e58:	68 3c 27 80 00       	push   $0x80273c
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
  800e6d:	53                   	push   %ebx
  800e6e:	83 ec 04             	sub    $0x4,%esp
	int r;
	void * address = (void *)(pn*PGSIZE);
  800e71:	89 d3                	mov    %edx,%ebx
  800e73:	c1 e3 0c             	shl    $0xc,%ebx
	
	if((uvpt[pn] & PTE_SHARE))
  800e76:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800e7d:	f6 c5 04             	test   $0x4,%ch
  800e80:	74 38                	je     800eba <duppage+0x50>
	{
		if ((r = sys_page_map(0, address, envid, address, (uvpt[pn] | PTE_SYSCALL))) < 0)
  800e82:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e89:	83 ec 0c             	sub    $0xc,%esp
  800e8c:	81 ca 07 0e 00 00    	or     $0xe07,%edx
  800e92:	52                   	push   %edx
  800e93:	53                   	push   %ebx
  800e94:	50                   	push   %eax
  800e95:	53                   	push   %ebx
  800e96:	6a 00                	push   $0x0
  800e98:	e8 1f fe ff ff       	call   800cbc <sys_page_map>
  800e9d:	83 c4 20             	add    $0x20,%esp
  800ea0:	85 c0                	test   %eax,%eax
  800ea2:	0f 89 b8 00 00 00    	jns    800f60 <duppage+0xf6>
			panic("sys_page_map: %e", r);
  800ea8:	50                   	push   %eax
  800ea9:	68 4a 27 80 00       	push   $0x80274a
  800eae:	6a 4e                	push   $0x4e
  800eb0:	68 5b 27 80 00       	push   $0x80275b
  800eb5:	e8 5e f3 ff ff       	call   800218 <_panic>
	}
	else if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW))
  800eba:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800ec1:	f6 c1 02             	test   $0x2,%cl
  800ec4:	75 0c                	jne    800ed2 <duppage+0x68>
  800ec6:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800ecd:	f6 c5 08             	test   $0x8,%ch
  800ed0:	74 57                	je     800f29 <duppage+0xbf>
	{
		int perm = 0;
		perm |= PTE_P|PTE_U|PTE_COW;
	
		if ((r = sys_page_map(0, address, envid, address, perm)) < 0)
  800ed2:	83 ec 0c             	sub    $0xc,%esp
  800ed5:	68 05 08 00 00       	push   $0x805
  800eda:	53                   	push   %ebx
  800edb:	50                   	push   %eax
  800edc:	53                   	push   %ebx
  800edd:	6a 00                	push   $0x0
  800edf:	e8 d8 fd ff ff       	call   800cbc <sys_page_map>
  800ee4:	83 c4 20             	add    $0x20,%esp
  800ee7:	85 c0                	test   %eax,%eax
  800ee9:	79 12                	jns    800efd <duppage+0x93>
			panic("sys_page_map: %e", r);
  800eeb:	50                   	push   %eax
  800eec:	68 4a 27 80 00       	push   $0x80274a
  800ef1:	6a 56                	push   $0x56
  800ef3:	68 5b 27 80 00       	push   $0x80275b
  800ef8:	e8 1b f3 ff ff       	call   800218 <_panic>
		if ((r = sys_page_map(0, address, 0, address, perm)) < 0)
  800efd:	83 ec 0c             	sub    $0xc,%esp
  800f00:	68 05 08 00 00       	push   $0x805
  800f05:	53                   	push   %ebx
  800f06:	6a 00                	push   $0x0
  800f08:	53                   	push   %ebx
  800f09:	6a 00                	push   $0x0
  800f0b:	e8 ac fd ff ff       	call   800cbc <sys_page_map>
  800f10:	83 c4 20             	add    $0x20,%esp
  800f13:	85 c0                	test   %eax,%eax
  800f15:	79 49                	jns    800f60 <duppage+0xf6>
			panic("sys_page_map: %e", r);
  800f17:	50                   	push   %eax
  800f18:	68 4a 27 80 00       	push   $0x80274a
  800f1d:	6a 58                	push   $0x58
  800f1f:	68 5b 27 80 00       	push   $0x80275b
  800f24:	e8 ef f2 ff ff       	call   800218 <_panic>
	}
	else if((uvpt[pn] & ~PTE_U) == 0)
  800f29:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f30:	f7 c2 fb ff ff ff    	test   $0xfffffffb,%edx
  800f36:	75 28                	jne    800f60 <duppage+0xf6>
	{
		//cprintf("im here");
		if ((r = sys_page_map(0, address, envid, address, PTE_P|PTE_U)) < 0)
  800f38:	83 ec 0c             	sub    $0xc,%esp
  800f3b:	6a 05                	push   $0x5
  800f3d:	53                   	push   %ebx
  800f3e:	50                   	push   %eax
  800f3f:	53                   	push   %ebx
  800f40:	6a 00                	push   $0x0
  800f42:	e8 75 fd ff ff       	call   800cbc <sys_page_map>
  800f47:	83 c4 20             	add    $0x20,%esp
  800f4a:	85 c0                	test   %eax,%eax
  800f4c:	79 12                	jns    800f60 <duppage+0xf6>
			panic("sys_page_map: %e", r);	
  800f4e:	50                   	push   %eax
  800f4f:	68 4a 27 80 00       	push   $0x80274a
  800f54:	6a 5e                	push   $0x5e
  800f56:	68 5b 27 80 00       	push   $0x80275b
  800f5b:	e8 b8 f2 ff ff       	call   800218 <_panic>
	}
	return 0;
}
  800f60:	b8 00 00 00 00       	mov    $0x0,%eax
  800f65:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f68:	c9                   	leave  
  800f69:	c3                   	ret    

00800f6a <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f6a:	55                   	push   %ebp
  800f6b:	89 e5                	mov    %esp,%ebp
  800f6d:	53                   	push   %ebx
  800f6e:	83 ec 08             	sub    $0x8,%esp
	void *addr = (void *) utf->utf_fault_va;
  800f71:	8b 45 08             	mov    0x8(%ebp),%eax
  800f74:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	unsigned pn = ((uint32_t)addr)/PGSIZE;
  800f76:	89 d8                	mov    %ebx,%eax
  800f78:	c1 e8 0c             	shr    $0xc,%eax
	pte_t pte = uvpt[pn];
  800f7b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// Allocate a new page, mapped at temp location
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  800f82:	6a 07                	push   $0x7
  800f84:	68 00 f0 7f 00       	push   $0x7ff000
  800f89:	6a 00                	push   $0x0
  800f8b:	e8 e9 fc ff ff       	call   800c79 <sys_page_alloc>
  800f90:	83 c4 10             	add    $0x10,%esp
  800f93:	85 c0                	test   %eax,%eax
  800f95:	79 12                	jns    800fa9 <pgfault+0x3f>
		panic("sys_page_alloc: %e", r);
  800f97:	50                   	push   %eax
  800f98:	68 66 27 80 00       	push   $0x802766
  800f9d:	6a 2b                	push   $0x2b
  800f9f:	68 5b 27 80 00       	push   $0x80275b
  800fa4:	e8 6f f2 ff ff       	call   800218 <_panic>

	// Copy the data from the old page to this new page
	void *addr_pgstart = (void *) ROUNDDOWN(addr, PGSIZE);
  800fa9:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr_pgstart, PGSIZE);
  800faf:	83 ec 04             	sub    $0x4,%esp
  800fb2:	68 00 10 00 00       	push   $0x1000
  800fb7:	53                   	push   %ebx
  800fb8:	68 00 f0 7f 00       	push   $0x7ff000
  800fbd:	e8 46 fa ff ff       	call   800a08 <memmove>

	// Move the new page to the old page's address
	if ((r = sys_page_map(0, PFTEMP, 0, addr_pgstart, PTE_P|PTE_U|PTE_W)) < 0)
  800fc2:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800fc9:	53                   	push   %ebx
  800fca:	6a 00                	push   $0x0
  800fcc:	68 00 f0 7f 00       	push   $0x7ff000
  800fd1:	6a 00                	push   $0x0
  800fd3:	e8 e4 fc ff ff       	call   800cbc <sys_page_map>
  800fd8:	83 c4 20             	add    $0x20,%esp
  800fdb:	85 c0                	test   %eax,%eax
  800fdd:	79 12                	jns    800ff1 <pgfault+0x87>
		panic("sys_page_map: %e", r);
  800fdf:	50                   	push   %eax
  800fe0:	68 4a 27 80 00       	push   $0x80274a
  800fe5:	6a 33                	push   $0x33
  800fe7:	68 5b 27 80 00       	push   $0x80275b
  800fec:	e8 27 f2 ff ff       	call   800218 <_panic>

	// Unmap the temp location
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800ff1:	83 ec 08             	sub    $0x8,%esp
  800ff4:	68 00 f0 7f 00       	push   $0x7ff000
  800ff9:	6a 00                	push   $0x0
  800ffb:	e8 fe fc ff ff       	call   800cfe <sys_page_unmap>
  801000:	83 c4 10             	add    $0x10,%esp
  801003:	85 c0                	test   %eax,%eax
  801005:	79 12                	jns    801019 <pgfault+0xaf>
		panic("sys_page_unmap: %e", r);
  801007:	50                   	push   %eax
  801008:	68 79 27 80 00       	push   $0x802779
  80100d:	6a 37                	push   $0x37
  80100f:	68 5b 27 80 00       	push   $0x80275b
  801014:	e8 ff f1 ff ff       	call   800218 <_panic>
}
  801019:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80101c:	c9                   	leave  
  80101d:	c3                   	ret    

0080101e <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80101e:	55                   	push   %ebp
  80101f:	89 e5                	mov    %esp,%ebp
  801021:	56                   	push   %esi
  801022:	53                   	push   %ebx
  801023:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
	// Set up page fault handler
	set_pgfault_handler(&pgfault);
  801026:	68 6a 0f 80 00       	push   $0x800f6a
  80102b:	e8 45 0e 00 00       	call   801e75 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801030:	b8 07 00 00 00       	mov    $0x7,%eax
  801035:	cd 30                	int    $0x30

	// Create child
	envid_t envid = sys_exofork();
  801037:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (envid < 0) {
  80103a:	83 c4 10             	add    $0x10,%esp
  80103d:	85 c0                	test   %eax,%eax
  80103f:	79 12                	jns    801053 <fork+0x35>
		panic("sys_exofork: %e", envid);
  801041:	50                   	push   %eax
  801042:	68 8c 27 80 00       	push   $0x80278c
  801047:	6a 7c                	push   $0x7c
  801049:	68 5b 27 80 00       	push   $0x80275b
  80104e:	e8 c5 f1 ff ff       	call   800218 <_panic>
		return envid;
	}
	if (envid == 0) {
  801053:	85 c0                	test   %eax,%eax
  801055:	75 1e                	jne    801075 <fork+0x57>
		// We are the child.
		thisenv = &envs[ENVX(sys_getenvid())]; // Fix thisenv
  801057:	e8 df fb ff ff       	call   800c3b <sys_getenvid>
  80105c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801061:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801064:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801069:	a3 20 44 80 00       	mov    %eax,0x804420
		return 0;
  80106e:	b8 00 00 00 00       	mov    $0x0,%eax
  801073:	eb 7d                	jmp    8010f2 <fork+0xd4>

	// Set page fault handler on the child.
	// The parent needs to do it, else the child wouldn't be able to handle
	// the fault when trying to access it's stack (which happens as soon it starts)
	extern void _pgfault_upcall(void);
	sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);
  801075:	83 ec 04             	sub    $0x4,%esp
  801078:	6a 07                	push   $0x7
  80107a:	68 00 f0 bf ee       	push   $0xeebff000
  80107f:	50                   	push   %eax
  801080:	e8 f4 fb ff ff       	call   800c79 <sys_page_alloc>
	sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  801085:	83 c4 08             	add    $0x8,%esp
  801088:	68 ba 1e 80 00       	push   $0x801eba
  80108d:	ff 75 f4             	pushl  -0xc(%ebp)
  801090:	e8 2f fd ff ff       	call   800dc4 <sys_env_set_pgfault_upcall>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  801095:	be 04 60 80 00       	mov    $0x806004,%esi
  80109a:	c1 ee 0c             	shr    $0xc,%esi
  80109d:	83 c4 10             	add    $0x10,%esp
  8010a0:	bb 00 08 00 00       	mov    $0x800,%ebx
  8010a5:	eb 0d                	jmp    8010b4 <fork+0x96>
		duppage(envid, pn);
  8010a7:	89 da                	mov    %ebx,%edx
  8010a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010ac:	e8 b9 fd ff ff       	call   800e6a <duppage>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  8010b1:	83 c3 01             	add    $0x1,%ebx
  8010b4:	39 f3                	cmp    %esi,%ebx
  8010b6:	76 ef                	jbe    8010a7 <fork+0x89>
	}

	// Also copy the stack we are currently running on
	// I think it should loop from ustacktop to this page, since the stack
	// can have more than 1 page
	duppage(envid, ((uint32_t) &envid)/PGSIZE);
  8010b8:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8010bb:	c1 ea 0c             	shr    $0xc,%edx
  8010be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010c1:	e8 a4 fd ff ff       	call   800e6a <duppage>

	// Start the child environmnet running
	int r;
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  8010c6:	83 ec 08             	sub    $0x8,%esp
  8010c9:	6a 02                	push   $0x2
  8010cb:	ff 75 f4             	pushl  -0xc(%ebp)
  8010ce:	e8 6d fc ff ff       	call   800d40 <sys_env_set_status>
  8010d3:	83 c4 10             	add    $0x10,%esp
  8010d6:	85 c0                	test   %eax,%eax
  8010d8:	79 15                	jns    8010ef <fork+0xd1>
		panic("sys_env_set_status: %e", r);
  8010da:	50                   	push   %eax
  8010db:	68 9c 27 80 00       	push   $0x80279c
  8010e0:	68 9c 00 00 00       	push   $0x9c
  8010e5:	68 5b 27 80 00       	push   $0x80275b
  8010ea:	e8 29 f1 ff ff       	call   800218 <_panic>
		return r;
	}

	return envid;
  8010ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8010f2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010f5:	5b                   	pop    %ebx
  8010f6:	5e                   	pop    %esi
  8010f7:	5d                   	pop    %ebp
  8010f8:	c3                   	ret    

008010f9 <sfork>:

// Challenge!
int
sfork(void)
{
  8010f9:	55                   	push   %ebp
  8010fa:	89 e5                	mov    %esp,%ebp
  8010fc:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010ff:	68 b3 27 80 00       	push   $0x8027b3
  801104:	68 a7 00 00 00       	push   $0xa7
  801109:	68 5b 27 80 00       	push   $0x80275b
  80110e:	e8 05 f1 ff ff       	call   800218 <_panic>

00801113 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801113:	55                   	push   %ebp
  801114:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801116:	8b 45 08             	mov    0x8(%ebp),%eax
  801119:	05 00 00 00 30       	add    $0x30000000,%eax
  80111e:	c1 e8 0c             	shr    $0xc,%eax
}
  801121:	5d                   	pop    %ebp
  801122:	c3                   	ret    

00801123 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801123:	55                   	push   %ebp
  801124:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801126:	8b 45 08             	mov    0x8(%ebp),%eax
  801129:	05 00 00 00 30       	add    $0x30000000,%eax
  80112e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801133:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801138:	5d                   	pop    %ebp
  801139:	c3                   	ret    

0080113a <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80113a:	55                   	push   %ebp
  80113b:	89 e5                	mov    %esp,%ebp
  80113d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801140:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801145:	89 c2                	mov    %eax,%edx
  801147:	c1 ea 16             	shr    $0x16,%edx
  80114a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801151:	f6 c2 01             	test   $0x1,%dl
  801154:	74 11                	je     801167 <fd_alloc+0x2d>
  801156:	89 c2                	mov    %eax,%edx
  801158:	c1 ea 0c             	shr    $0xc,%edx
  80115b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801162:	f6 c2 01             	test   $0x1,%dl
  801165:	75 09                	jne    801170 <fd_alloc+0x36>
			*fd_store = fd;
  801167:	89 01                	mov    %eax,(%ecx)
			return 0;
  801169:	b8 00 00 00 00       	mov    $0x0,%eax
  80116e:	eb 17                	jmp    801187 <fd_alloc+0x4d>
  801170:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801175:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80117a:	75 c9                	jne    801145 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80117c:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801182:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801187:	5d                   	pop    %ebp
  801188:	c3                   	ret    

00801189 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801189:	55                   	push   %ebp
  80118a:	89 e5                	mov    %esp,%ebp
  80118c:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80118f:	83 f8 1f             	cmp    $0x1f,%eax
  801192:	77 36                	ja     8011ca <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801194:	c1 e0 0c             	shl    $0xc,%eax
  801197:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80119c:	89 c2                	mov    %eax,%edx
  80119e:	c1 ea 16             	shr    $0x16,%edx
  8011a1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011a8:	f6 c2 01             	test   $0x1,%dl
  8011ab:	74 24                	je     8011d1 <fd_lookup+0x48>
  8011ad:	89 c2                	mov    %eax,%edx
  8011af:	c1 ea 0c             	shr    $0xc,%edx
  8011b2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011b9:	f6 c2 01             	test   $0x1,%dl
  8011bc:	74 1a                	je     8011d8 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011be:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011c1:	89 02                	mov    %eax,(%edx)
	return 0;
  8011c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8011c8:	eb 13                	jmp    8011dd <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011ca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011cf:	eb 0c                	jmp    8011dd <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011d1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011d6:	eb 05                	jmp    8011dd <fd_lookup+0x54>
  8011d8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8011dd:	5d                   	pop    %ebp
  8011de:	c3                   	ret    

008011df <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011df:	55                   	push   %ebp
  8011e0:	89 e5                	mov    %esp,%ebp
  8011e2:	83 ec 08             	sub    $0x8,%esp
  8011e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011e8:	ba 4c 28 80 00       	mov    $0x80284c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8011ed:	eb 13                	jmp    801202 <dev_lookup+0x23>
  8011ef:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8011f2:	39 08                	cmp    %ecx,(%eax)
  8011f4:	75 0c                	jne    801202 <dev_lookup+0x23>
			*dev = devtab[i];
  8011f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011f9:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011fb:	b8 00 00 00 00       	mov    $0x0,%eax
  801200:	eb 2e                	jmp    801230 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801202:	8b 02                	mov    (%edx),%eax
  801204:	85 c0                	test   %eax,%eax
  801206:	75 e7                	jne    8011ef <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801208:	a1 20 44 80 00       	mov    0x804420,%eax
  80120d:	8b 40 48             	mov    0x48(%eax),%eax
  801210:	83 ec 04             	sub    $0x4,%esp
  801213:	51                   	push   %ecx
  801214:	50                   	push   %eax
  801215:	68 cc 27 80 00       	push   $0x8027cc
  80121a:	e8 d2 f0 ff ff       	call   8002f1 <cprintf>
	*dev = 0;
  80121f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801222:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801228:	83 c4 10             	add    $0x10,%esp
  80122b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801230:	c9                   	leave  
  801231:	c3                   	ret    

00801232 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801232:	55                   	push   %ebp
  801233:	89 e5                	mov    %esp,%ebp
  801235:	56                   	push   %esi
  801236:	53                   	push   %ebx
  801237:	83 ec 10             	sub    $0x10,%esp
  80123a:	8b 75 08             	mov    0x8(%ebp),%esi
  80123d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801240:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801243:	50                   	push   %eax
  801244:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80124a:	c1 e8 0c             	shr    $0xc,%eax
  80124d:	50                   	push   %eax
  80124e:	e8 36 ff ff ff       	call   801189 <fd_lookup>
  801253:	83 c4 08             	add    $0x8,%esp
  801256:	85 c0                	test   %eax,%eax
  801258:	78 05                	js     80125f <fd_close+0x2d>
	    || fd != fd2)
  80125a:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80125d:	74 0c                	je     80126b <fd_close+0x39>
		return (must_exist ? r : 0);
  80125f:	84 db                	test   %bl,%bl
  801261:	ba 00 00 00 00       	mov    $0x0,%edx
  801266:	0f 44 c2             	cmove  %edx,%eax
  801269:	eb 41                	jmp    8012ac <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80126b:	83 ec 08             	sub    $0x8,%esp
  80126e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801271:	50                   	push   %eax
  801272:	ff 36                	pushl  (%esi)
  801274:	e8 66 ff ff ff       	call   8011df <dev_lookup>
  801279:	89 c3                	mov    %eax,%ebx
  80127b:	83 c4 10             	add    $0x10,%esp
  80127e:	85 c0                	test   %eax,%eax
  801280:	78 1a                	js     80129c <fd_close+0x6a>
		if (dev->dev_close)
  801282:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801285:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801288:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80128d:	85 c0                	test   %eax,%eax
  80128f:	74 0b                	je     80129c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801291:	83 ec 0c             	sub    $0xc,%esp
  801294:	56                   	push   %esi
  801295:	ff d0                	call   *%eax
  801297:	89 c3                	mov    %eax,%ebx
  801299:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80129c:	83 ec 08             	sub    $0x8,%esp
  80129f:	56                   	push   %esi
  8012a0:	6a 00                	push   $0x0
  8012a2:	e8 57 fa ff ff       	call   800cfe <sys_page_unmap>
	return r;
  8012a7:	83 c4 10             	add    $0x10,%esp
  8012aa:	89 d8                	mov    %ebx,%eax
}
  8012ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012af:	5b                   	pop    %ebx
  8012b0:	5e                   	pop    %esi
  8012b1:	5d                   	pop    %ebp
  8012b2:	c3                   	ret    

008012b3 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012b3:	55                   	push   %ebp
  8012b4:	89 e5                	mov    %esp,%ebp
  8012b6:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012bc:	50                   	push   %eax
  8012bd:	ff 75 08             	pushl  0x8(%ebp)
  8012c0:	e8 c4 fe ff ff       	call   801189 <fd_lookup>
  8012c5:	83 c4 08             	add    $0x8,%esp
  8012c8:	85 c0                	test   %eax,%eax
  8012ca:	78 10                	js     8012dc <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8012cc:	83 ec 08             	sub    $0x8,%esp
  8012cf:	6a 01                	push   $0x1
  8012d1:	ff 75 f4             	pushl  -0xc(%ebp)
  8012d4:	e8 59 ff ff ff       	call   801232 <fd_close>
  8012d9:	83 c4 10             	add    $0x10,%esp
}
  8012dc:	c9                   	leave  
  8012dd:	c3                   	ret    

008012de <close_all>:

void
close_all(void)
{
  8012de:	55                   	push   %ebp
  8012df:	89 e5                	mov    %esp,%ebp
  8012e1:	53                   	push   %ebx
  8012e2:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012e5:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012ea:	83 ec 0c             	sub    $0xc,%esp
  8012ed:	53                   	push   %ebx
  8012ee:	e8 c0 ff ff ff       	call   8012b3 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8012f3:	83 c3 01             	add    $0x1,%ebx
  8012f6:	83 c4 10             	add    $0x10,%esp
  8012f9:	83 fb 20             	cmp    $0x20,%ebx
  8012fc:	75 ec                	jne    8012ea <close_all+0xc>
		close(i);
}
  8012fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801301:	c9                   	leave  
  801302:	c3                   	ret    

00801303 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801303:	55                   	push   %ebp
  801304:	89 e5                	mov    %esp,%ebp
  801306:	57                   	push   %edi
  801307:	56                   	push   %esi
  801308:	53                   	push   %ebx
  801309:	83 ec 2c             	sub    $0x2c,%esp
  80130c:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80130f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801312:	50                   	push   %eax
  801313:	ff 75 08             	pushl  0x8(%ebp)
  801316:	e8 6e fe ff ff       	call   801189 <fd_lookup>
  80131b:	83 c4 08             	add    $0x8,%esp
  80131e:	85 c0                	test   %eax,%eax
  801320:	0f 88 c1 00 00 00    	js     8013e7 <dup+0xe4>
		return r;
	close(newfdnum);
  801326:	83 ec 0c             	sub    $0xc,%esp
  801329:	56                   	push   %esi
  80132a:	e8 84 ff ff ff       	call   8012b3 <close>

	newfd = INDEX2FD(newfdnum);
  80132f:	89 f3                	mov    %esi,%ebx
  801331:	c1 e3 0c             	shl    $0xc,%ebx
  801334:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80133a:	83 c4 04             	add    $0x4,%esp
  80133d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801340:	e8 de fd ff ff       	call   801123 <fd2data>
  801345:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801347:	89 1c 24             	mov    %ebx,(%esp)
  80134a:	e8 d4 fd ff ff       	call   801123 <fd2data>
  80134f:	83 c4 10             	add    $0x10,%esp
  801352:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801355:	89 f8                	mov    %edi,%eax
  801357:	c1 e8 16             	shr    $0x16,%eax
  80135a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801361:	a8 01                	test   $0x1,%al
  801363:	74 37                	je     80139c <dup+0x99>
  801365:	89 f8                	mov    %edi,%eax
  801367:	c1 e8 0c             	shr    $0xc,%eax
  80136a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801371:	f6 c2 01             	test   $0x1,%dl
  801374:	74 26                	je     80139c <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801376:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80137d:	83 ec 0c             	sub    $0xc,%esp
  801380:	25 07 0e 00 00       	and    $0xe07,%eax
  801385:	50                   	push   %eax
  801386:	ff 75 d4             	pushl  -0x2c(%ebp)
  801389:	6a 00                	push   $0x0
  80138b:	57                   	push   %edi
  80138c:	6a 00                	push   $0x0
  80138e:	e8 29 f9 ff ff       	call   800cbc <sys_page_map>
  801393:	89 c7                	mov    %eax,%edi
  801395:	83 c4 20             	add    $0x20,%esp
  801398:	85 c0                	test   %eax,%eax
  80139a:	78 2e                	js     8013ca <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80139c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80139f:	89 d0                	mov    %edx,%eax
  8013a1:	c1 e8 0c             	shr    $0xc,%eax
  8013a4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013ab:	83 ec 0c             	sub    $0xc,%esp
  8013ae:	25 07 0e 00 00       	and    $0xe07,%eax
  8013b3:	50                   	push   %eax
  8013b4:	53                   	push   %ebx
  8013b5:	6a 00                	push   $0x0
  8013b7:	52                   	push   %edx
  8013b8:	6a 00                	push   $0x0
  8013ba:	e8 fd f8 ff ff       	call   800cbc <sys_page_map>
  8013bf:	89 c7                	mov    %eax,%edi
  8013c1:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8013c4:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013c6:	85 ff                	test   %edi,%edi
  8013c8:	79 1d                	jns    8013e7 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013ca:	83 ec 08             	sub    $0x8,%esp
  8013cd:	53                   	push   %ebx
  8013ce:	6a 00                	push   $0x0
  8013d0:	e8 29 f9 ff ff       	call   800cfe <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013d5:	83 c4 08             	add    $0x8,%esp
  8013d8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013db:	6a 00                	push   $0x0
  8013dd:	e8 1c f9 ff ff       	call   800cfe <sys_page_unmap>
	return r;
  8013e2:	83 c4 10             	add    $0x10,%esp
  8013e5:	89 f8                	mov    %edi,%eax
}
  8013e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013ea:	5b                   	pop    %ebx
  8013eb:	5e                   	pop    %esi
  8013ec:	5f                   	pop    %edi
  8013ed:	5d                   	pop    %ebp
  8013ee:	c3                   	ret    

008013ef <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013ef:	55                   	push   %ebp
  8013f0:	89 e5                	mov    %esp,%ebp
  8013f2:	53                   	push   %ebx
  8013f3:	83 ec 14             	sub    $0x14,%esp
  8013f6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013f9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013fc:	50                   	push   %eax
  8013fd:	53                   	push   %ebx
  8013fe:	e8 86 fd ff ff       	call   801189 <fd_lookup>
  801403:	83 c4 08             	add    $0x8,%esp
  801406:	89 c2                	mov    %eax,%edx
  801408:	85 c0                	test   %eax,%eax
  80140a:	78 6d                	js     801479 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80140c:	83 ec 08             	sub    $0x8,%esp
  80140f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801412:	50                   	push   %eax
  801413:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801416:	ff 30                	pushl  (%eax)
  801418:	e8 c2 fd ff ff       	call   8011df <dev_lookup>
  80141d:	83 c4 10             	add    $0x10,%esp
  801420:	85 c0                	test   %eax,%eax
  801422:	78 4c                	js     801470 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801424:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801427:	8b 42 08             	mov    0x8(%edx),%eax
  80142a:	83 e0 03             	and    $0x3,%eax
  80142d:	83 f8 01             	cmp    $0x1,%eax
  801430:	75 21                	jne    801453 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801432:	a1 20 44 80 00       	mov    0x804420,%eax
  801437:	8b 40 48             	mov    0x48(%eax),%eax
  80143a:	83 ec 04             	sub    $0x4,%esp
  80143d:	53                   	push   %ebx
  80143e:	50                   	push   %eax
  80143f:	68 10 28 80 00       	push   $0x802810
  801444:	e8 a8 ee ff ff       	call   8002f1 <cprintf>
		return -E_INVAL;
  801449:	83 c4 10             	add    $0x10,%esp
  80144c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801451:	eb 26                	jmp    801479 <read+0x8a>
	}
	if (!dev->dev_read)
  801453:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801456:	8b 40 08             	mov    0x8(%eax),%eax
  801459:	85 c0                	test   %eax,%eax
  80145b:	74 17                	je     801474 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80145d:	83 ec 04             	sub    $0x4,%esp
  801460:	ff 75 10             	pushl  0x10(%ebp)
  801463:	ff 75 0c             	pushl  0xc(%ebp)
  801466:	52                   	push   %edx
  801467:	ff d0                	call   *%eax
  801469:	89 c2                	mov    %eax,%edx
  80146b:	83 c4 10             	add    $0x10,%esp
  80146e:	eb 09                	jmp    801479 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801470:	89 c2                	mov    %eax,%edx
  801472:	eb 05                	jmp    801479 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801474:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801479:	89 d0                	mov    %edx,%eax
  80147b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80147e:	c9                   	leave  
  80147f:	c3                   	ret    

00801480 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801480:	55                   	push   %ebp
  801481:	89 e5                	mov    %esp,%ebp
  801483:	57                   	push   %edi
  801484:	56                   	push   %esi
  801485:	53                   	push   %ebx
  801486:	83 ec 0c             	sub    $0xc,%esp
  801489:	8b 7d 08             	mov    0x8(%ebp),%edi
  80148c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80148f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801494:	eb 21                	jmp    8014b7 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801496:	83 ec 04             	sub    $0x4,%esp
  801499:	89 f0                	mov    %esi,%eax
  80149b:	29 d8                	sub    %ebx,%eax
  80149d:	50                   	push   %eax
  80149e:	89 d8                	mov    %ebx,%eax
  8014a0:	03 45 0c             	add    0xc(%ebp),%eax
  8014a3:	50                   	push   %eax
  8014a4:	57                   	push   %edi
  8014a5:	e8 45 ff ff ff       	call   8013ef <read>
		if (m < 0)
  8014aa:	83 c4 10             	add    $0x10,%esp
  8014ad:	85 c0                	test   %eax,%eax
  8014af:	78 10                	js     8014c1 <readn+0x41>
			return m;
		if (m == 0)
  8014b1:	85 c0                	test   %eax,%eax
  8014b3:	74 0a                	je     8014bf <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014b5:	01 c3                	add    %eax,%ebx
  8014b7:	39 f3                	cmp    %esi,%ebx
  8014b9:	72 db                	jb     801496 <readn+0x16>
  8014bb:	89 d8                	mov    %ebx,%eax
  8014bd:	eb 02                	jmp    8014c1 <readn+0x41>
  8014bf:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8014c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014c4:	5b                   	pop    %ebx
  8014c5:	5e                   	pop    %esi
  8014c6:	5f                   	pop    %edi
  8014c7:	5d                   	pop    %ebp
  8014c8:	c3                   	ret    

008014c9 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014c9:	55                   	push   %ebp
  8014ca:	89 e5                	mov    %esp,%ebp
  8014cc:	53                   	push   %ebx
  8014cd:	83 ec 14             	sub    $0x14,%esp
  8014d0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014d3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014d6:	50                   	push   %eax
  8014d7:	53                   	push   %ebx
  8014d8:	e8 ac fc ff ff       	call   801189 <fd_lookup>
  8014dd:	83 c4 08             	add    $0x8,%esp
  8014e0:	89 c2                	mov    %eax,%edx
  8014e2:	85 c0                	test   %eax,%eax
  8014e4:	78 68                	js     80154e <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014e6:	83 ec 08             	sub    $0x8,%esp
  8014e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ec:	50                   	push   %eax
  8014ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014f0:	ff 30                	pushl  (%eax)
  8014f2:	e8 e8 fc ff ff       	call   8011df <dev_lookup>
  8014f7:	83 c4 10             	add    $0x10,%esp
  8014fa:	85 c0                	test   %eax,%eax
  8014fc:	78 47                	js     801545 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801501:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801505:	75 21                	jne    801528 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801507:	a1 20 44 80 00       	mov    0x804420,%eax
  80150c:	8b 40 48             	mov    0x48(%eax),%eax
  80150f:	83 ec 04             	sub    $0x4,%esp
  801512:	53                   	push   %ebx
  801513:	50                   	push   %eax
  801514:	68 2c 28 80 00       	push   $0x80282c
  801519:	e8 d3 ed ff ff       	call   8002f1 <cprintf>
		return -E_INVAL;
  80151e:	83 c4 10             	add    $0x10,%esp
  801521:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801526:	eb 26                	jmp    80154e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801528:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80152b:	8b 52 0c             	mov    0xc(%edx),%edx
  80152e:	85 d2                	test   %edx,%edx
  801530:	74 17                	je     801549 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801532:	83 ec 04             	sub    $0x4,%esp
  801535:	ff 75 10             	pushl  0x10(%ebp)
  801538:	ff 75 0c             	pushl  0xc(%ebp)
  80153b:	50                   	push   %eax
  80153c:	ff d2                	call   *%edx
  80153e:	89 c2                	mov    %eax,%edx
  801540:	83 c4 10             	add    $0x10,%esp
  801543:	eb 09                	jmp    80154e <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801545:	89 c2                	mov    %eax,%edx
  801547:	eb 05                	jmp    80154e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801549:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80154e:	89 d0                	mov    %edx,%eax
  801550:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801553:	c9                   	leave  
  801554:	c3                   	ret    

00801555 <seek>:

int
seek(int fdnum, off_t offset)
{
  801555:	55                   	push   %ebp
  801556:	89 e5                	mov    %esp,%ebp
  801558:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80155b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80155e:	50                   	push   %eax
  80155f:	ff 75 08             	pushl  0x8(%ebp)
  801562:	e8 22 fc ff ff       	call   801189 <fd_lookup>
  801567:	83 c4 08             	add    $0x8,%esp
  80156a:	85 c0                	test   %eax,%eax
  80156c:	78 0e                	js     80157c <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80156e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801571:	8b 55 0c             	mov    0xc(%ebp),%edx
  801574:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801577:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80157c:	c9                   	leave  
  80157d:	c3                   	ret    

0080157e <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80157e:	55                   	push   %ebp
  80157f:	89 e5                	mov    %esp,%ebp
  801581:	53                   	push   %ebx
  801582:	83 ec 14             	sub    $0x14,%esp
  801585:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801588:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80158b:	50                   	push   %eax
  80158c:	53                   	push   %ebx
  80158d:	e8 f7 fb ff ff       	call   801189 <fd_lookup>
  801592:	83 c4 08             	add    $0x8,%esp
  801595:	89 c2                	mov    %eax,%edx
  801597:	85 c0                	test   %eax,%eax
  801599:	78 65                	js     801600 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80159b:	83 ec 08             	sub    $0x8,%esp
  80159e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015a1:	50                   	push   %eax
  8015a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015a5:	ff 30                	pushl  (%eax)
  8015a7:	e8 33 fc ff ff       	call   8011df <dev_lookup>
  8015ac:	83 c4 10             	add    $0x10,%esp
  8015af:	85 c0                	test   %eax,%eax
  8015b1:	78 44                	js     8015f7 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015b6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015ba:	75 21                	jne    8015dd <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015bc:	a1 20 44 80 00       	mov    0x804420,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015c1:	8b 40 48             	mov    0x48(%eax),%eax
  8015c4:	83 ec 04             	sub    $0x4,%esp
  8015c7:	53                   	push   %ebx
  8015c8:	50                   	push   %eax
  8015c9:	68 ec 27 80 00       	push   $0x8027ec
  8015ce:	e8 1e ed ff ff       	call   8002f1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015d3:	83 c4 10             	add    $0x10,%esp
  8015d6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015db:	eb 23                	jmp    801600 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8015dd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015e0:	8b 52 18             	mov    0x18(%edx),%edx
  8015e3:	85 d2                	test   %edx,%edx
  8015e5:	74 14                	je     8015fb <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015e7:	83 ec 08             	sub    $0x8,%esp
  8015ea:	ff 75 0c             	pushl  0xc(%ebp)
  8015ed:	50                   	push   %eax
  8015ee:	ff d2                	call   *%edx
  8015f0:	89 c2                	mov    %eax,%edx
  8015f2:	83 c4 10             	add    $0x10,%esp
  8015f5:	eb 09                	jmp    801600 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015f7:	89 c2                	mov    %eax,%edx
  8015f9:	eb 05                	jmp    801600 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8015fb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801600:	89 d0                	mov    %edx,%eax
  801602:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801605:	c9                   	leave  
  801606:	c3                   	ret    

00801607 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801607:	55                   	push   %ebp
  801608:	89 e5                	mov    %esp,%ebp
  80160a:	53                   	push   %ebx
  80160b:	83 ec 14             	sub    $0x14,%esp
  80160e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801611:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801614:	50                   	push   %eax
  801615:	ff 75 08             	pushl  0x8(%ebp)
  801618:	e8 6c fb ff ff       	call   801189 <fd_lookup>
  80161d:	83 c4 08             	add    $0x8,%esp
  801620:	89 c2                	mov    %eax,%edx
  801622:	85 c0                	test   %eax,%eax
  801624:	78 58                	js     80167e <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801626:	83 ec 08             	sub    $0x8,%esp
  801629:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80162c:	50                   	push   %eax
  80162d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801630:	ff 30                	pushl  (%eax)
  801632:	e8 a8 fb ff ff       	call   8011df <dev_lookup>
  801637:	83 c4 10             	add    $0x10,%esp
  80163a:	85 c0                	test   %eax,%eax
  80163c:	78 37                	js     801675 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80163e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801641:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801645:	74 32                	je     801679 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801647:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80164a:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801651:	00 00 00 
	stat->st_isdir = 0;
  801654:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80165b:	00 00 00 
	stat->st_dev = dev;
  80165e:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801664:	83 ec 08             	sub    $0x8,%esp
  801667:	53                   	push   %ebx
  801668:	ff 75 f0             	pushl  -0x10(%ebp)
  80166b:	ff 50 14             	call   *0x14(%eax)
  80166e:	89 c2                	mov    %eax,%edx
  801670:	83 c4 10             	add    $0x10,%esp
  801673:	eb 09                	jmp    80167e <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801675:	89 c2                	mov    %eax,%edx
  801677:	eb 05                	jmp    80167e <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801679:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80167e:	89 d0                	mov    %edx,%eax
  801680:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801683:	c9                   	leave  
  801684:	c3                   	ret    

00801685 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801685:	55                   	push   %ebp
  801686:	89 e5                	mov    %esp,%ebp
  801688:	56                   	push   %esi
  801689:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80168a:	83 ec 08             	sub    $0x8,%esp
  80168d:	6a 00                	push   $0x0
  80168f:	ff 75 08             	pushl  0x8(%ebp)
  801692:	e8 0c 02 00 00       	call   8018a3 <open>
  801697:	89 c3                	mov    %eax,%ebx
  801699:	83 c4 10             	add    $0x10,%esp
  80169c:	85 c0                	test   %eax,%eax
  80169e:	78 1b                	js     8016bb <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016a0:	83 ec 08             	sub    $0x8,%esp
  8016a3:	ff 75 0c             	pushl  0xc(%ebp)
  8016a6:	50                   	push   %eax
  8016a7:	e8 5b ff ff ff       	call   801607 <fstat>
  8016ac:	89 c6                	mov    %eax,%esi
	close(fd);
  8016ae:	89 1c 24             	mov    %ebx,(%esp)
  8016b1:	e8 fd fb ff ff       	call   8012b3 <close>
	return r;
  8016b6:	83 c4 10             	add    $0x10,%esp
  8016b9:	89 f0                	mov    %esi,%eax
}
  8016bb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016be:	5b                   	pop    %ebx
  8016bf:	5e                   	pop    %esi
  8016c0:	5d                   	pop    %ebp
  8016c1:	c3                   	ret    

008016c2 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016c2:	55                   	push   %ebp
  8016c3:	89 e5                	mov    %esp,%ebp
  8016c5:	56                   	push   %esi
  8016c6:	53                   	push   %ebx
  8016c7:	89 c6                	mov    %eax,%esi
  8016c9:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016cb:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016d2:	75 12                	jne    8016e6 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016d4:	83 ec 0c             	sub    $0xc,%esp
  8016d7:	6a 01                	push   $0x1
  8016d9:	e8 ca 08 00 00       	call   801fa8 <ipc_find_env>
  8016de:	a3 00 40 80 00       	mov    %eax,0x804000
  8016e3:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016e6:	6a 07                	push   $0x7
  8016e8:	68 00 50 80 00       	push   $0x805000
  8016ed:	56                   	push   %esi
  8016ee:	ff 35 00 40 80 00    	pushl  0x804000
  8016f4:	e8 5b 08 00 00       	call   801f54 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016f9:	83 c4 0c             	add    $0xc,%esp
  8016fc:	6a 00                	push   $0x0
  8016fe:	53                   	push   %ebx
  8016ff:	6a 00                	push   $0x0
  801701:	e8 e5 07 00 00       	call   801eeb <ipc_recv>
}
  801706:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801709:	5b                   	pop    %ebx
  80170a:	5e                   	pop    %esi
  80170b:	5d                   	pop    %ebp
  80170c:	c3                   	ret    

0080170d <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80170d:	55                   	push   %ebp
  80170e:	89 e5                	mov    %esp,%ebp
  801710:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801713:	8b 45 08             	mov    0x8(%ebp),%eax
  801716:	8b 40 0c             	mov    0xc(%eax),%eax
  801719:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80171e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801721:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801726:	ba 00 00 00 00       	mov    $0x0,%edx
  80172b:	b8 02 00 00 00       	mov    $0x2,%eax
  801730:	e8 8d ff ff ff       	call   8016c2 <fsipc>
}
  801735:	c9                   	leave  
  801736:	c3                   	ret    

00801737 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801737:	55                   	push   %ebp
  801738:	89 e5                	mov    %esp,%ebp
  80173a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80173d:	8b 45 08             	mov    0x8(%ebp),%eax
  801740:	8b 40 0c             	mov    0xc(%eax),%eax
  801743:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801748:	ba 00 00 00 00       	mov    $0x0,%edx
  80174d:	b8 06 00 00 00       	mov    $0x6,%eax
  801752:	e8 6b ff ff ff       	call   8016c2 <fsipc>
}
  801757:	c9                   	leave  
  801758:	c3                   	ret    

00801759 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801759:	55                   	push   %ebp
  80175a:	89 e5                	mov    %esp,%ebp
  80175c:	53                   	push   %ebx
  80175d:	83 ec 04             	sub    $0x4,%esp
  801760:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801763:	8b 45 08             	mov    0x8(%ebp),%eax
  801766:	8b 40 0c             	mov    0xc(%eax),%eax
  801769:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80176e:	ba 00 00 00 00       	mov    $0x0,%edx
  801773:	b8 05 00 00 00       	mov    $0x5,%eax
  801778:	e8 45 ff ff ff       	call   8016c2 <fsipc>
  80177d:	85 c0                	test   %eax,%eax
  80177f:	78 2c                	js     8017ad <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801781:	83 ec 08             	sub    $0x8,%esp
  801784:	68 00 50 80 00       	push   $0x805000
  801789:	53                   	push   %ebx
  80178a:	e8 e7 f0 ff ff       	call   800876 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80178f:	a1 80 50 80 00       	mov    0x805080,%eax
  801794:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80179a:	a1 84 50 80 00       	mov    0x805084,%eax
  80179f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017a5:	83 c4 10             	add    $0x10,%esp
  8017a8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017b0:	c9                   	leave  
  8017b1:	c3                   	ret    

008017b2 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017b2:	55                   	push   %ebp
  8017b3:	89 e5                	mov    %esp,%ebp
  8017b5:	53                   	push   %ebx
  8017b6:	83 ec 08             	sub    $0x8,%esp
  8017b9:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8017bf:	8b 52 0c             	mov    0xc(%edx),%edx
  8017c2:	89 15 00 50 80 00    	mov    %edx,0x805000
  8017c8:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8017cd:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  8017d2:	0f 46 d8             	cmovbe %eax,%ebx
	
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  8017d5:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  8017db:	53                   	push   %ebx
  8017dc:	ff 75 0c             	pushl  0xc(%ebp)
  8017df:	68 08 50 80 00       	push   $0x805008
  8017e4:	e8 1f f2 ff ff       	call   800a08 <memmove>

	
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) 
  8017e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ee:	b8 04 00 00 00       	mov    $0x4,%eax
  8017f3:	e8 ca fe ff ff       	call   8016c2 <fsipc>
  8017f8:	83 c4 10             	add    $0x10,%esp
  8017fb:	85 c0                	test   %eax,%eax
  8017fd:	78 1d                	js     80181c <devfile_write+0x6a>
		return r;
	assert(r <= n_real); 
  8017ff:	39 d8                	cmp    %ebx,%eax
  801801:	76 19                	jbe    80181c <devfile_write+0x6a>
  801803:	68 5c 28 80 00       	push   $0x80285c
  801808:	68 68 28 80 00       	push   $0x802868
  80180d:	68 a3 00 00 00       	push   $0xa3
  801812:	68 7d 28 80 00       	push   $0x80287d
  801817:	e8 fc e9 ff ff       	call   800218 <_panic>
	return r;
}
  80181c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80181f:	c9                   	leave  
  801820:	c3                   	ret    

00801821 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801821:	55                   	push   %ebp
  801822:	89 e5                	mov    %esp,%ebp
  801824:	56                   	push   %esi
  801825:	53                   	push   %ebx
  801826:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801829:	8b 45 08             	mov    0x8(%ebp),%eax
  80182c:	8b 40 0c             	mov    0xc(%eax),%eax
  80182f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801834:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80183a:	ba 00 00 00 00       	mov    $0x0,%edx
  80183f:	b8 03 00 00 00       	mov    $0x3,%eax
  801844:	e8 79 fe ff ff       	call   8016c2 <fsipc>
  801849:	89 c3                	mov    %eax,%ebx
  80184b:	85 c0                	test   %eax,%eax
  80184d:	78 4b                	js     80189a <devfile_read+0x79>
		return r;
	assert(r <= n);
  80184f:	39 c6                	cmp    %eax,%esi
  801851:	73 16                	jae    801869 <devfile_read+0x48>
  801853:	68 88 28 80 00       	push   $0x802888
  801858:	68 68 28 80 00       	push   $0x802868
  80185d:	6a 7c                	push   $0x7c
  80185f:	68 7d 28 80 00       	push   $0x80287d
  801864:	e8 af e9 ff ff       	call   800218 <_panic>
	assert(r <= PGSIZE);
  801869:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80186e:	7e 16                	jle    801886 <devfile_read+0x65>
  801870:	68 8f 28 80 00       	push   $0x80288f
  801875:	68 68 28 80 00       	push   $0x802868
  80187a:	6a 7d                	push   $0x7d
  80187c:	68 7d 28 80 00       	push   $0x80287d
  801881:	e8 92 e9 ff ff       	call   800218 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801886:	83 ec 04             	sub    $0x4,%esp
  801889:	50                   	push   %eax
  80188a:	68 00 50 80 00       	push   $0x805000
  80188f:	ff 75 0c             	pushl  0xc(%ebp)
  801892:	e8 71 f1 ff ff       	call   800a08 <memmove>
	return r;
  801897:	83 c4 10             	add    $0x10,%esp
}
  80189a:	89 d8                	mov    %ebx,%eax
  80189c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80189f:	5b                   	pop    %ebx
  8018a0:	5e                   	pop    %esi
  8018a1:	5d                   	pop    %ebp
  8018a2:	c3                   	ret    

008018a3 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018a3:	55                   	push   %ebp
  8018a4:	89 e5                	mov    %esp,%ebp
  8018a6:	53                   	push   %ebx
  8018a7:	83 ec 20             	sub    $0x20,%esp
  8018aa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018ad:	53                   	push   %ebx
  8018ae:	e8 8a ef ff ff       	call   80083d <strlen>
  8018b3:	83 c4 10             	add    $0x10,%esp
  8018b6:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018bb:	7f 67                	jg     801924 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018bd:	83 ec 0c             	sub    $0xc,%esp
  8018c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018c3:	50                   	push   %eax
  8018c4:	e8 71 f8 ff ff       	call   80113a <fd_alloc>
  8018c9:	83 c4 10             	add    $0x10,%esp
		return r;
  8018cc:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018ce:	85 c0                	test   %eax,%eax
  8018d0:	78 57                	js     801929 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018d2:	83 ec 08             	sub    $0x8,%esp
  8018d5:	53                   	push   %ebx
  8018d6:	68 00 50 80 00       	push   $0x805000
  8018db:	e8 96 ef ff ff       	call   800876 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018e3:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018e8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018eb:	b8 01 00 00 00       	mov    $0x1,%eax
  8018f0:	e8 cd fd ff ff       	call   8016c2 <fsipc>
  8018f5:	89 c3                	mov    %eax,%ebx
  8018f7:	83 c4 10             	add    $0x10,%esp
  8018fa:	85 c0                	test   %eax,%eax
  8018fc:	79 14                	jns    801912 <open+0x6f>
		fd_close(fd, 0);
  8018fe:	83 ec 08             	sub    $0x8,%esp
  801901:	6a 00                	push   $0x0
  801903:	ff 75 f4             	pushl  -0xc(%ebp)
  801906:	e8 27 f9 ff ff       	call   801232 <fd_close>
		return r;
  80190b:	83 c4 10             	add    $0x10,%esp
  80190e:	89 da                	mov    %ebx,%edx
  801910:	eb 17                	jmp    801929 <open+0x86>
	}

	return fd2num(fd);
  801912:	83 ec 0c             	sub    $0xc,%esp
  801915:	ff 75 f4             	pushl  -0xc(%ebp)
  801918:	e8 f6 f7 ff ff       	call   801113 <fd2num>
  80191d:	89 c2                	mov    %eax,%edx
  80191f:	83 c4 10             	add    $0x10,%esp
  801922:	eb 05                	jmp    801929 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801924:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801929:	89 d0                	mov    %edx,%eax
  80192b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80192e:	c9                   	leave  
  80192f:	c3                   	ret    

00801930 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801930:	55                   	push   %ebp
  801931:	89 e5                	mov    %esp,%ebp
  801933:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801936:	ba 00 00 00 00       	mov    $0x0,%edx
  80193b:	b8 08 00 00 00       	mov    $0x8,%eax
  801940:	e8 7d fd ff ff       	call   8016c2 <fsipc>
}
  801945:	c9                   	leave  
  801946:	c3                   	ret    

00801947 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801947:	55                   	push   %ebp
  801948:	89 e5                	mov    %esp,%ebp
  80194a:	56                   	push   %esi
  80194b:	53                   	push   %ebx
  80194c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80194f:	83 ec 0c             	sub    $0xc,%esp
  801952:	ff 75 08             	pushl  0x8(%ebp)
  801955:	e8 c9 f7 ff ff       	call   801123 <fd2data>
  80195a:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80195c:	83 c4 08             	add    $0x8,%esp
  80195f:	68 9b 28 80 00       	push   $0x80289b
  801964:	53                   	push   %ebx
  801965:	e8 0c ef ff ff       	call   800876 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80196a:	8b 46 04             	mov    0x4(%esi),%eax
  80196d:	2b 06                	sub    (%esi),%eax
  80196f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801975:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80197c:	00 00 00 
	stat->st_dev = &devpipe;
  80197f:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801986:	30 80 00 
	return 0;
}
  801989:	b8 00 00 00 00       	mov    $0x0,%eax
  80198e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801991:	5b                   	pop    %ebx
  801992:	5e                   	pop    %esi
  801993:	5d                   	pop    %ebp
  801994:	c3                   	ret    

00801995 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801995:	55                   	push   %ebp
  801996:	89 e5                	mov    %esp,%ebp
  801998:	53                   	push   %ebx
  801999:	83 ec 0c             	sub    $0xc,%esp
  80199c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80199f:	53                   	push   %ebx
  8019a0:	6a 00                	push   $0x0
  8019a2:	e8 57 f3 ff ff       	call   800cfe <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019a7:	89 1c 24             	mov    %ebx,(%esp)
  8019aa:	e8 74 f7 ff ff       	call   801123 <fd2data>
  8019af:	83 c4 08             	add    $0x8,%esp
  8019b2:	50                   	push   %eax
  8019b3:	6a 00                	push   $0x0
  8019b5:	e8 44 f3 ff ff       	call   800cfe <sys_page_unmap>
}
  8019ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019bd:	c9                   	leave  
  8019be:	c3                   	ret    

008019bf <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8019bf:	55                   	push   %ebp
  8019c0:	89 e5                	mov    %esp,%ebp
  8019c2:	57                   	push   %edi
  8019c3:	56                   	push   %esi
  8019c4:	53                   	push   %ebx
  8019c5:	83 ec 1c             	sub    $0x1c,%esp
  8019c8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8019cb:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8019cd:	a1 20 44 80 00       	mov    0x804420,%eax
  8019d2:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8019d5:	83 ec 0c             	sub    $0xc,%esp
  8019d8:	ff 75 e0             	pushl  -0x20(%ebp)
  8019db:	e8 01 06 00 00       	call   801fe1 <pageref>
  8019e0:	89 c3                	mov    %eax,%ebx
  8019e2:	89 3c 24             	mov    %edi,(%esp)
  8019e5:	e8 f7 05 00 00       	call   801fe1 <pageref>
  8019ea:	83 c4 10             	add    $0x10,%esp
  8019ed:	39 c3                	cmp    %eax,%ebx
  8019ef:	0f 94 c1             	sete   %cl
  8019f2:	0f b6 c9             	movzbl %cl,%ecx
  8019f5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8019f8:	8b 15 20 44 80 00    	mov    0x804420,%edx
  8019fe:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a01:	39 ce                	cmp    %ecx,%esi
  801a03:	74 1b                	je     801a20 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a05:	39 c3                	cmp    %eax,%ebx
  801a07:	75 c4                	jne    8019cd <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a09:	8b 42 58             	mov    0x58(%edx),%eax
  801a0c:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a0f:	50                   	push   %eax
  801a10:	56                   	push   %esi
  801a11:	68 a2 28 80 00       	push   $0x8028a2
  801a16:	e8 d6 e8 ff ff       	call   8002f1 <cprintf>
  801a1b:	83 c4 10             	add    $0x10,%esp
  801a1e:	eb ad                	jmp    8019cd <_pipeisclosed+0xe>
	}
}
  801a20:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a23:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a26:	5b                   	pop    %ebx
  801a27:	5e                   	pop    %esi
  801a28:	5f                   	pop    %edi
  801a29:	5d                   	pop    %ebp
  801a2a:	c3                   	ret    

00801a2b <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a2b:	55                   	push   %ebp
  801a2c:	89 e5                	mov    %esp,%ebp
  801a2e:	57                   	push   %edi
  801a2f:	56                   	push   %esi
  801a30:	53                   	push   %ebx
  801a31:	83 ec 28             	sub    $0x28,%esp
  801a34:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a37:	56                   	push   %esi
  801a38:	e8 e6 f6 ff ff       	call   801123 <fd2data>
  801a3d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a3f:	83 c4 10             	add    $0x10,%esp
  801a42:	bf 00 00 00 00       	mov    $0x0,%edi
  801a47:	eb 4b                	jmp    801a94 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a49:	89 da                	mov    %ebx,%edx
  801a4b:	89 f0                	mov    %esi,%eax
  801a4d:	e8 6d ff ff ff       	call   8019bf <_pipeisclosed>
  801a52:	85 c0                	test   %eax,%eax
  801a54:	75 48                	jne    801a9e <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a56:	e8 ff f1 ff ff       	call   800c5a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a5b:	8b 43 04             	mov    0x4(%ebx),%eax
  801a5e:	8b 0b                	mov    (%ebx),%ecx
  801a60:	8d 51 20             	lea    0x20(%ecx),%edx
  801a63:	39 d0                	cmp    %edx,%eax
  801a65:	73 e2                	jae    801a49 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a67:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a6a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a6e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a71:	89 c2                	mov    %eax,%edx
  801a73:	c1 fa 1f             	sar    $0x1f,%edx
  801a76:	89 d1                	mov    %edx,%ecx
  801a78:	c1 e9 1b             	shr    $0x1b,%ecx
  801a7b:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801a7e:	83 e2 1f             	and    $0x1f,%edx
  801a81:	29 ca                	sub    %ecx,%edx
  801a83:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801a87:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a8b:	83 c0 01             	add    $0x1,%eax
  801a8e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a91:	83 c7 01             	add    $0x1,%edi
  801a94:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a97:	75 c2                	jne    801a5b <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a99:	8b 45 10             	mov    0x10(%ebp),%eax
  801a9c:	eb 05                	jmp    801aa3 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a9e:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801aa3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aa6:	5b                   	pop    %ebx
  801aa7:	5e                   	pop    %esi
  801aa8:	5f                   	pop    %edi
  801aa9:	5d                   	pop    %ebp
  801aaa:	c3                   	ret    

00801aab <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801aab:	55                   	push   %ebp
  801aac:	89 e5                	mov    %esp,%ebp
  801aae:	57                   	push   %edi
  801aaf:	56                   	push   %esi
  801ab0:	53                   	push   %ebx
  801ab1:	83 ec 18             	sub    $0x18,%esp
  801ab4:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801ab7:	57                   	push   %edi
  801ab8:	e8 66 f6 ff ff       	call   801123 <fd2data>
  801abd:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801abf:	83 c4 10             	add    $0x10,%esp
  801ac2:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ac7:	eb 3d                	jmp    801b06 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ac9:	85 db                	test   %ebx,%ebx
  801acb:	74 04                	je     801ad1 <devpipe_read+0x26>
				return i;
  801acd:	89 d8                	mov    %ebx,%eax
  801acf:	eb 44                	jmp    801b15 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ad1:	89 f2                	mov    %esi,%edx
  801ad3:	89 f8                	mov    %edi,%eax
  801ad5:	e8 e5 fe ff ff       	call   8019bf <_pipeisclosed>
  801ada:	85 c0                	test   %eax,%eax
  801adc:	75 32                	jne    801b10 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801ade:	e8 77 f1 ff ff       	call   800c5a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ae3:	8b 06                	mov    (%esi),%eax
  801ae5:	3b 46 04             	cmp    0x4(%esi),%eax
  801ae8:	74 df                	je     801ac9 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801aea:	99                   	cltd   
  801aeb:	c1 ea 1b             	shr    $0x1b,%edx
  801aee:	01 d0                	add    %edx,%eax
  801af0:	83 e0 1f             	and    $0x1f,%eax
  801af3:	29 d0                	sub    %edx,%eax
  801af5:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801afa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801afd:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b00:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b03:	83 c3 01             	add    $0x1,%ebx
  801b06:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b09:	75 d8                	jne    801ae3 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b0b:	8b 45 10             	mov    0x10(%ebp),%eax
  801b0e:	eb 05                	jmp    801b15 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b10:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b15:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b18:	5b                   	pop    %ebx
  801b19:	5e                   	pop    %esi
  801b1a:	5f                   	pop    %edi
  801b1b:	5d                   	pop    %ebp
  801b1c:	c3                   	ret    

00801b1d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b1d:	55                   	push   %ebp
  801b1e:	89 e5                	mov    %esp,%ebp
  801b20:	56                   	push   %esi
  801b21:	53                   	push   %ebx
  801b22:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b25:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b28:	50                   	push   %eax
  801b29:	e8 0c f6 ff ff       	call   80113a <fd_alloc>
  801b2e:	83 c4 10             	add    $0x10,%esp
  801b31:	89 c2                	mov    %eax,%edx
  801b33:	85 c0                	test   %eax,%eax
  801b35:	0f 88 2c 01 00 00    	js     801c67 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b3b:	83 ec 04             	sub    $0x4,%esp
  801b3e:	68 07 04 00 00       	push   $0x407
  801b43:	ff 75 f4             	pushl  -0xc(%ebp)
  801b46:	6a 00                	push   $0x0
  801b48:	e8 2c f1 ff ff       	call   800c79 <sys_page_alloc>
  801b4d:	83 c4 10             	add    $0x10,%esp
  801b50:	89 c2                	mov    %eax,%edx
  801b52:	85 c0                	test   %eax,%eax
  801b54:	0f 88 0d 01 00 00    	js     801c67 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b5a:	83 ec 0c             	sub    $0xc,%esp
  801b5d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b60:	50                   	push   %eax
  801b61:	e8 d4 f5 ff ff       	call   80113a <fd_alloc>
  801b66:	89 c3                	mov    %eax,%ebx
  801b68:	83 c4 10             	add    $0x10,%esp
  801b6b:	85 c0                	test   %eax,%eax
  801b6d:	0f 88 e2 00 00 00    	js     801c55 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b73:	83 ec 04             	sub    $0x4,%esp
  801b76:	68 07 04 00 00       	push   $0x407
  801b7b:	ff 75 f0             	pushl  -0x10(%ebp)
  801b7e:	6a 00                	push   $0x0
  801b80:	e8 f4 f0 ff ff       	call   800c79 <sys_page_alloc>
  801b85:	89 c3                	mov    %eax,%ebx
  801b87:	83 c4 10             	add    $0x10,%esp
  801b8a:	85 c0                	test   %eax,%eax
  801b8c:	0f 88 c3 00 00 00    	js     801c55 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b92:	83 ec 0c             	sub    $0xc,%esp
  801b95:	ff 75 f4             	pushl  -0xc(%ebp)
  801b98:	e8 86 f5 ff ff       	call   801123 <fd2data>
  801b9d:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b9f:	83 c4 0c             	add    $0xc,%esp
  801ba2:	68 07 04 00 00       	push   $0x407
  801ba7:	50                   	push   %eax
  801ba8:	6a 00                	push   $0x0
  801baa:	e8 ca f0 ff ff       	call   800c79 <sys_page_alloc>
  801baf:	89 c3                	mov    %eax,%ebx
  801bb1:	83 c4 10             	add    $0x10,%esp
  801bb4:	85 c0                	test   %eax,%eax
  801bb6:	0f 88 89 00 00 00    	js     801c45 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bbc:	83 ec 0c             	sub    $0xc,%esp
  801bbf:	ff 75 f0             	pushl  -0x10(%ebp)
  801bc2:	e8 5c f5 ff ff       	call   801123 <fd2data>
  801bc7:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801bce:	50                   	push   %eax
  801bcf:	6a 00                	push   $0x0
  801bd1:	56                   	push   %esi
  801bd2:	6a 00                	push   $0x0
  801bd4:	e8 e3 f0 ff ff       	call   800cbc <sys_page_map>
  801bd9:	89 c3                	mov    %eax,%ebx
  801bdb:	83 c4 20             	add    $0x20,%esp
  801bde:	85 c0                	test   %eax,%eax
  801be0:	78 55                	js     801c37 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801be2:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801be8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801beb:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801bed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bf0:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801bf7:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bfd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c00:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c02:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c05:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c0c:	83 ec 0c             	sub    $0xc,%esp
  801c0f:	ff 75 f4             	pushl  -0xc(%ebp)
  801c12:	e8 fc f4 ff ff       	call   801113 <fd2num>
  801c17:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c1a:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c1c:	83 c4 04             	add    $0x4,%esp
  801c1f:	ff 75 f0             	pushl  -0x10(%ebp)
  801c22:	e8 ec f4 ff ff       	call   801113 <fd2num>
  801c27:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c2a:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c2d:	83 c4 10             	add    $0x10,%esp
  801c30:	ba 00 00 00 00       	mov    $0x0,%edx
  801c35:	eb 30                	jmp    801c67 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c37:	83 ec 08             	sub    $0x8,%esp
  801c3a:	56                   	push   %esi
  801c3b:	6a 00                	push   $0x0
  801c3d:	e8 bc f0 ff ff       	call   800cfe <sys_page_unmap>
  801c42:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c45:	83 ec 08             	sub    $0x8,%esp
  801c48:	ff 75 f0             	pushl  -0x10(%ebp)
  801c4b:	6a 00                	push   $0x0
  801c4d:	e8 ac f0 ff ff       	call   800cfe <sys_page_unmap>
  801c52:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c55:	83 ec 08             	sub    $0x8,%esp
  801c58:	ff 75 f4             	pushl  -0xc(%ebp)
  801c5b:	6a 00                	push   $0x0
  801c5d:	e8 9c f0 ff ff       	call   800cfe <sys_page_unmap>
  801c62:	83 c4 10             	add    $0x10,%esp
  801c65:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801c67:	89 d0                	mov    %edx,%eax
  801c69:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c6c:	5b                   	pop    %ebx
  801c6d:	5e                   	pop    %esi
  801c6e:	5d                   	pop    %ebp
  801c6f:	c3                   	ret    

00801c70 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c70:	55                   	push   %ebp
  801c71:	89 e5                	mov    %esp,%ebp
  801c73:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c76:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c79:	50                   	push   %eax
  801c7a:	ff 75 08             	pushl  0x8(%ebp)
  801c7d:	e8 07 f5 ff ff       	call   801189 <fd_lookup>
  801c82:	83 c4 10             	add    $0x10,%esp
  801c85:	85 c0                	test   %eax,%eax
  801c87:	78 18                	js     801ca1 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c89:	83 ec 0c             	sub    $0xc,%esp
  801c8c:	ff 75 f4             	pushl  -0xc(%ebp)
  801c8f:	e8 8f f4 ff ff       	call   801123 <fd2data>
	return _pipeisclosed(fd, p);
  801c94:	89 c2                	mov    %eax,%edx
  801c96:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c99:	e8 21 fd ff ff       	call   8019bf <_pipeisclosed>
  801c9e:	83 c4 10             	add    $0x10,%esp
}
  801ca1:	c9                   	leave  
  801ca2:	c3                   	ret    

00801ca3 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  801ca3:	55                   	push   %ebp
  801ca4:	89 e5                	mov    %esp,%ebp
  801ca6:	56                   	push   %esi
  801ca7:	53                   	push   %ebx
  801ca8:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  801cab:	85 f6                	test   %esi,%esi
  801cad:	75 16                	jne    801cc5 <wait+0x22>
  801caf:	68 ba 28 80 00       	push   $0x8028ba
  801cb4:	68 68 28 80 00       	push   $0x802868
  801cb9:	6a 09                	push   $0x9
  801cbb:	68 c5 28 80 00       	push   $0x8028c5
  801cc0:	e8 53 e5 ff ff       	call   800218 <_panic>
	e = &envs[ENVX(envid)];
  801cc5:	89 f3                	mov    %esi,%ebx
  801cc7:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801ccd:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  801cd0:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  801cd6:	eb 05                	jmp    801cdd <wait+0x3a>
		sys_yield();
  801cd8:	e8 7d ef ff ff       	call   800c5a <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801cdd:	8b 43 48             	mov    0x48(%ebx),%eax
  801ce0:	39 c6                	cmp    %eax,%esi
  801ce2:	75 07                	jne    801ceb <wait+0x48>
  801ce4:	8b 43 54             	mov    0x54(%ebx),%eax
  801ce7:	85 c0                	test   %eax,%eax
  801ce9:	75 ed                	jne    801cd8 <wait+0x35>
		sys_yield();
}
  801ceb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cee:	5b                   	pop    %ebx
  801cef:	5e                   	pop    %esi
  801cf0:	5d                   	pop    %ebp
  801cf1:	c3                   	ret    

00801cf2 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801cf2:	55                   	push   %ebp
  801cf3:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801cf5:	b8 00 00 00 00       	mov    $0x0,%eax
  801cfa:	5d                   	pop    %ebp
  801cfb:	c3                   	ret    

00801cfc <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801cfc:	55                   	push   %ebp
  801cfd:	89 e5                	mov    %esp,%ebp
  801cff:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d02:	68 d0 28 80 00       	push   $0x8028d0
  801d07:	ff 75 0c             	pushl  0xc(%ebp)
  801d0a:	e8 67 eb ff ff       	call   800876 <strcpy>
	return 0;
}
  801d0f:	b8 00 00 00 00       	mov    $0x0,%eax
  801d14:	c9                   	leave  
  801d15:	c3                   	ret    

00801d16 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d16:	55                   	push   %ebp
  801d17:	89 e5                	mov    %esp,%ebp
  801d19:	57                   	push   %edi
  801d1a:	56                   	push   %esi
  801d1b:	53                   	push   %ebx
  801d1c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d22:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d27:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d2d:	eb 2d                	jmp    801d5c <devcons_write+0x46>
		m = n - tot;
  801d2f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d32:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d34:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d37:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d3c:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d3f:	83 ec 04             	sub    $0x4,%esp
  801d42:	53                   	push   %ebx
  801d43:	03 45 0c             	add    0xc(%ebp),%eax
  801d46:	50                   	push   %eax
  801d47:	57                   	push   %edi
  801d48:	e8 bb ec ff ff       	call   800a08 <memmove>
		sys_cputs(buf, m);
  801d4d:	83 c4 08             	add    $0x8,%esp
  801d50:	53                   	push   %ebx
  801d51:	57                   	push   %edi
  801d52:	e8 66 ee ff ff       	call   800bbd <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d57:	01 de                	add    %ebx,%esi
  801d59:	83 c4 10             	add    $0x10,%esp
  801d5c:	89 f0                	mov    %esi,%eax
  801d5e:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d61:	72 cc                	jb     801d2f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d63:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d66:	5b                   	pop    %ebx
  801d67:	5e                   	pop    %esi
  801d68:	5f                   	pop    %edi
  801d69:	5d                   	pop    %ebp
  801d6a:	c3                   	ret    

00801d6b <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d6b:	55                   	push   %ebp
  801d6c:	89 e5                	mov    %esp,%ebp
  801d6e:	83 ec 08             	sub    $0x8,%esp
  801d71:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801d76:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d7a:	74 2a                	je     801da6 <devcons_read+0x3b>
  801d7c:	eb 05                	jmp    801d83 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d7e:	e8 d7 ee ff ff       	call   800c5a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d83:	e8 53 ee ff ff       	call   800bdb <sys_cgetc>
  801d88:	85 c0                	test   %eax,%eax
  801d8a:	74 f2                	je     801d7e <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801d8c:	85 c0                	test   %eax,%eax
  801d8e:	78 16                	js     801da6 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d90:	83 f8 04             	cmp    $0x4,%eax
  801d93:	74 0c                	je     801da1 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801d95:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d98:	88 02                	mov    %al,(%edx)
	return 1;
  801d9a:	b8 01 00 00 00       	mov    $0x1,%eax
  801d9f:	eb 05                	jmp    801da6 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801da1:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801da6:	c9                   	leave  
  801da7:	c3                   	ret    

00801da8 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801da8:	55                   	push   %ebp
  801da9:	89 e5                	mov    %esp,%ebp
  801dab:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801dae:	8b 45 08             	mov    0x8(%ebp),%eax
  801db1:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801db4:	6a 01                	push   $0x1
  801db6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801db9:	50                   	push   %eax
  801dba:	e8 fe ed ff ff       	call   800bbd <sys_cputs>
}
  801dbf:	83 c4 10             	add    $0x10,%esp
  801dc2:	c9                   	leave  
  801dc3:	c3                   	ret    

00801dc4 <getchar>:

int
getchar(void)
{
  801dc4:	55                   	push   %ebp
  801dc5:	89 e5                	mov    %esp,%ebp
  801dc7:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801dca:	6a 01                	push   $0x1
  801dcc:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dcf:	50                   	push   %eax
  801dd0:	6a 00                	push   $0x0
  801dd2:	e8 18 f6 ff ff       	call   8013ef <read>
	if (r < 0)
  801dd7:	83 c4 10             	add    $0x10,%esp
  801dda:	85 c0                	test   %eax,%eax
  801ddc:	78 0f                	js     801ded <getchar+0x29>
		return r;
	if (r < 1)
  801dde:	85 c0                	test   %eax,%eax
  801de0:	7e 06                	jle    801de8 <getchar+0x24>
		return -E_EOF;
	return c;
  801de2:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801de6:	eb 05                	jmp    801ded <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801de8:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801ded:	c9                   	leave  
  801dee:	c3                   	ret    

00801def <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801def:	55                   	push   %ebp
  801df0:	89 e5                	mov    %esp,%ebp
  801df2:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801df5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801df8:	50                   	push   %eax
  801df9:	ff 75 08             	pushl  0x8(%ebp)
  801dfc:	e8 88 f3 ff ff       	call   801189 <fd_lookup>
  801e01:	83 c4 10             	add    $0x10,%esp
  801e04:	85 c0                	test   %eax,%eax
  801e06:	78 11                	js     801e19 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e08:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e0b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e11:	39 10                	cmp    %edx,(%eax)
  801e13:	0f 94 c0             	sete   %al
  801e16:	0f b6 c0             	movzbl %al,%eax
}
  801e19:	c9                   	leave  
  801e1a:	c3                   	ret    

00801e1b <opencons>:

int
opencons(void)
{
  801e1b:	55                   	push   %ebp
  801e1c:	89 e5                	mov    %esp,%ebp
  801e1e:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e21:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e24:	50                   	push   %eax
  801e25:	e8 10 f3 ff ff       	call   80113a <fd_alloc>
  801e2a:	83 c4 10             	add    $0x10,%esp
		return r;
  801e2d:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e2f:	85 c0                	test   %eax,%eax
  801e31:	78 3e                	js     801e71 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e33:	83 ec 04             	sub    $0x4,%esp
  801e36:	68 07 04 00 00       	push   $0x407
  801e3b:	ff 75 f4             	pushl  -0xc(%ebp)
  801e3e:	6a 00                	push   $0x0
  801e40:	e8 34 ee ff ff       	call   800c79 <sys_page_alloc>
  801e45:	83 c4 10             	add    $0x10,%esp
		return r;
  801e48:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e4a:	85 c0                	test   %eax,%eax
  801e4c:	78 23                	js     801e71 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e4e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e54:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e57:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e59:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e5c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e63:	83 ec 0c             	sub    $0xc,%esp
  801e66:	50                   	push   %eax
  801e67:	e8 a7 f2 ff ff       	call   801113 <fd2num>
  801e6c:	89 c2                	mov    %eax,%edx
  801e6e:	83 c4 10             	add    $0x10,%esp
}
  801e71:	89 d0                	mov    %edx,%eax
  801e73:	c9                   	leave  
  801e74:	c3                   	ret    

00801e75 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801e75:	55                   	push   %ebp
  801e76:	89 e5                	mov    %esp,%ebp
  801e78:	53                   	push   %ebx
  801e79:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  801e7c:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801e83:	75 28                	jne    801ead <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  801e85:	e8 b1 ed ff ff       	call   800c3b <sys_getenvid>
  801e8a:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_U | PTE_W);
  801e8c:	83 ec 04             	sub    $0x4,%esp
  801e8f:	6a 06                	push   $0x6
  801e91:	68 00 f0 bf ee       	push   $0xeebff000
  801e96:	50                   	push   %eax
  801e97:	e8 dd ed ff ff       	call   800c79 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  801e9c:	83 c4 08             	add    $0x8,%esp
  801e9f:	68 ba 1e 80 00       	push   $0x801eba
  801ea4:	53                   	push   %ebx
  801ea5:	e8 1a ef ff ff       	call   800dc4 <sys_env_set_pgfault_upcall>
  801eaa:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801ead:	8b 45 08             	mov    0x8(%ebp),%eax
  801eb0:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801eb5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801eb8:	c9                   	leave  
  801eb9:	c3                   	ret    

00801eba <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801eba:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801ebb:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801ec0:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801ec2:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	# My method is different. Copy the values to the other stack
	# in a convinient way, and then pop everything.
	movl %esp, %ebp		# ebp refers to the exception stack
  801ec5:	89 e5                	mov    %esp,%ebp
	movl 48(%ebp), %esp 	# go to other stack
  801ec7:	8b 65 30             	mov    0x30(%ebp),%esp

	pushl 40(%ebp)		# eip - ORDER SWITCHED WITH EFLAGS
  801eca:	ff 75 28             	pushl  0x28(%ebp)
	pushl 44(%ebp)      	# eflags
  801ecd:	ff 75 2c             	pushl  0x2c(%ebp)
	pushl 36(%ebp)		# all the 8 remaining regs
  801ed0:	ff 75 24             	pushl  0x24(%ebp)
	pushl 32(%ebp)
  801ed3:	ff 75 20             	pushl  0x20(%ebp)
	pushl 28(%ebp)
  801ed6:	ff 75 1c             	pushl  0x1c(%ebp)
	pushl 24(%ebp)
  801ed9:	ff 75 18             	pushl  0x18(%ebp)
	pushl 20(%ebp)
  801edc:	ff 75 14             	pushl  0x14(%ebp)
	pushl 16(%ebp)
  801edf:	ff 75 10             	pushl  0x10(%ebp)
	pushl 12(%ebp)
  801ee2:	ff 75 0c             	pushl  0xc(%ebp)
	pushl 8(%ebp)
  801ee5:	ff 75 08             	pushl  0x8(%ebp)

	popal			# now just pop everything!
  801ee8:	61                   	popa   
	popfl
  801ee9:	9d                   	popf   
	ret
  801eea:	c3                   	ret    

00801eeb <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801eeb:	55                   	push   %ebp
  801eec:	89 e5                	mov    %esp,%ebp
  801eee:	56                   	push   %esi
  801eef:	53                   	push   %ebx
  801ef0:	8b 75 08             	mov    0x8(%ebp),%esi
  801ef3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ef6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  801ef9:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801efb:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801f00:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  801f03:	83 ec 0c             	sub    $0xc,%esp
  801f06:	50                   	push   %eax
  801f07:	e8 1d ef ff ff       	call   800e29 <sys_ipc_recv>

	if (r < 0) {
  801f0c:	83 c4 10             	add    $0x10,%esp
  801f0f:	85 c0                	test   %eax,%eax
  801f11:	79 16                	jns    801f29 <ipc_recv+0x3e>
		if (from_env_store)
  801f13:	85 f6                	test   %esi,%esi
  801f15:	74 06                	je     801f1d <ipc_recv+0x32>
			*from_env_store = 0;
  801f17:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  801f1d:	85 db                	test   %ebx,%ebx
  801f1f:	74 2c                	je     801f4d <ipc_recv+0x62>
			*perm_store = 0;
  801f21:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801f27:	eb 24                	jmp    801f4d <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  801f29:	85 f6                	test   %esi,%esi
  801f2b:	74 0a                	je     801f37 <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  801f2d:	a1 20 44 80 00       	mov    0x804420,%eax
  801f32:	8b 40 74             	mov    0x74(%eax),%eax
  801f35:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  801f37:	85 db                	test   %ebx,%ebx
  801f39:	74 0a                	je     801f45 <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  801f3b:	a1 20 44 80 00       	mov    0x804420,%eax
  801f40:	8b 40 78             	mov    0x78(%eax),%eax
  801f43:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  801f45:	a1 20 44 80 00       	mov    0x804420,%eax
  801f4a:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  801f4d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f50:	5b                   	pop    %ebx
  801f51:	5e                   	pop    %esi
  801f52:	5d                   	pop    %ebp
  801f53:	c3                   	ret    

00801f54 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f54:	55                   	push   %ebp
  801f55:	89 e5                	mov    %esp,%ebp
  801f57:	57                   	push   %edi
  801f58:	56                   	push   %esi
  801f59:	53                   	push   %ebx
  801f5a:	83 ec 0c             	sub    $0xc,%esp
  801f5d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f60:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f63:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  801f66:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801f68:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801f6d:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  801f70:	ff 75 14             	pushl  0x14(%ebp)
  801f73:	53                   	push   %ebx
  801f74:	56                   	push   %esi
  801f75:	57                   	push   %edi
  801f76:	e8 8b ee ff ff       	call   800e06 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  801f7b:	83 c4 10             	add    $0x10,%esp
  801f7e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f81:	75 07                	jne    801f8a <ipc_send+0x36>
			sys_yield();
  801f83:	e8 d2 ec ff ff       	call   800c5a <sys_yield>
  801f88:	eb e6                	jmp    801f70 <ipc_send+0x1c>
		} else if (r < 0) {
  801f8a:	85 c0                	test   %eax,%eax
  801f8c:	79 12                	jns    801fa0 <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  801f8e:	50                   	push   %eax
  801f8f:	68 dc 28 80 00       	push   $0x8028dc
  801f94:	6a 51                	push   $0x51
  801f96:	68 e9 28 80 00       	push   $0x8028e9
  801f9b:	e8 78 e2 ff ff       	call   800218 <_panic>
		}
	}
}
  801fa0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fa3:	5b                   	pop    %ebx
  801fa4:	5e                   	pop    %esi
  801fa5:	5f                   	pop    %edi
  801fa6:	5d                   	pop    %ebp
  801fa7:	c3                   	ret    

00801fa8 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801fa8:	55                   	push   %ebp
  801fa9:	89 e5                	mov    %esp,%ebp
  801fab:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801fae:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801fb3:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801fb6:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801fbc:	8b 52 50             	mov    0x50(%edx),%edx
  801fbf:	39 ca                	cmp    %ecx,%edx
  801fc1:	75 0d                	jne    801fd0 <ipc_find_env+0x28>
			return envs[i].env_id;
  801fc3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801fc6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801fcb:	8b 40 48             	mov    0x48(%eax),%eax
  801fce:	eb 0f                	jmp    801fdf <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801fd0:	83 c0 01             	add    $0x1,%eax
  801fd3:	3d 00 04 00 00       	cmp    $0x400,%eax
  801fd8:	75 d9                	jne    801fb3 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801fda:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801fdf:	5d                   	pop    %ebp
  801fe0:	c3                   	ret    

00801fe1 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fe1:	55                   	push   %ebp
  801fe2:	89 e5                	mov    %esp,%ebp
  801fe4:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fe7:	89 d0                	mov    %edx,%eax
  801fe9:	c1 e8 16             	shr    $0x16,%eax
  801fec:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801ff3:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ff8:	f6 c1 01             	test   $0x1,%cl
  801ffb:	74 1d                	je     80201a <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801ffd:	c1 ea 0c             	shr    $0xc,%edx
  802000:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802007:	f6 c2 01             	test   $0x1,%dl
  80200a:	74 0e                	je     80201a <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80200c:	c1 ea 0c             	shr    $0xc,%edx
  80200f:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802016:	ef 
  802017:	0f b7 c0             	movzwl %ax,%eax
}
  80201a:	5d                   	pop    %ebp
  80201b:	c3                   	ret    
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
