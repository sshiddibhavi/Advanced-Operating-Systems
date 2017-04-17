
obj/user/testpiperace2.debug:     file format elf32-i386


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
  80002c:	e8 a5 01 00 00       	call   8001d6 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 38             	sub    $0x38,%esp
	int p[2], r, i;
	struct Fd *fd;
	const volatile struct Env *kid;

	cprintf("testing for pipeisclosed race...\n");
  80003c:	68 20 27 80 00       	push   $0x802720
  800041:	e8 c9 02 00 00       	call   80030f <cprintf>
	if ((r = pipe(p)) < 0)
  800046:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800049:	89 04 24             	mov    %eax,(%esp)
  80004c:	e8 70 1f 00 00       	call   801fc1 <pipe>
  800051:	83 c4 10             	add    $0x10,%esp
  800054:	85 c0                	test   %eax,%eax
  800056:	79 12                	jns    80006a <umain+0x37>
		panic("pipe: %e", r);
  800058:	50                   	push   %eax
  800059:	68 6e 27 80 00       	push   $0x80276e
  80005e:	6a 0d                	push   $0xd
  800060:	68 77 27 80 00       	push   $0x802777
  800065:	e8 cc 01 00 00       	call   800236 <_panic>
	if ((r = fork()) < 0)
  80006a:	e8 ec 0f 00 00       	call   80105b <fork>
  80006f:	89 c6                	mov    %eax,%esi
  800071:	85 c0                	test   %eax,%eax
  800073:	79 12                	jns    800087 <umain+0x54>
		panic("fork: %e", r);
  800075:	50                   	push   %eax
  800076:	68 93 2b 80 00       	push   $0x802b93
  80007b:	6a 0f                	push   $0xf
  80007d:	68 77 27 80 00       	push   $0x802777
  800082:	e8 af 01 00 00       	call   800236 <_panic>
	if (r == 0) {
  800087:	85 c0                	test   %eax,%eax
  800089:	75 76                	jne    800101 <umain+0xce>
		// child just dups and closes repeatedly,
		// yielding so the parent can see
		// the fd state between the two.
		close(p[1]);
  80008b:	83 ec 0c             	sub    $0xc,%esp
  80008e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800091:	e8 5a 12 00 00       	call   8012f0 <close>
  800096:	83 c4 10             	add    $0x10,%esp
		for (i = 0; i < 200; i++) {
  800099:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (i % 10 == 0)
  80009e:	bf 67 66 66 66       	mov    $0x66666667,%edi
  8000a3:	89 d8                	mov    %ebx,%eax
  8000a5:	f7 ef                	imul   %edi
  8000a7:	c1 fa 02             	sar    $0x2,%edx
  8000aa:	89 d8                	mov    %ebx,%eax
  8000ac:	c1 f8 1f             	sar    $0x1f,%eax
  8000af:	29 c2                	sub    %eax,%edx
  8000b1:	8d 04 92             	lea    (%edx,%edx,4),%eax
  8000b4:	01 c0                	add    %eax,%eax
  8000b6:	39 c3                	cmp    %eax,%ebx
  8000b8:	75 11                	jne    8000cb <umain+0x98>
				cprintf("%d.", i);
  8000ba:	83 ec 08             	sub    $0x8,%esp
  8000bd:	53                   	push   %ebx
  8000be:	68 8c 27 80 00       	push   $0x80278c
  8000c3:	e8 47 02 00 00       	call   80030f <cprintf>
  8000c8:	83 c4 10             	add    $0x10,%esp
			// dup, then close.  yield so that other guy will
			// see us while we're between them.
			dup(p[0], 10);
  8000cb:	83 ec 08             	sub    $0x8,%esp
  8000ce:	6a 0a                	push   $0xa
  8000d0:	ff 75 e0             	pushl  -0x20(%ebp)
  8000d3:	e8 68 12 00 00       	call   801340 <dup>
			sys_yield();
  8000d8:	e8 9b 0b 00 00       	call   800c78 <sys_yield>
			close(10);
  8000dd:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  8000e4:	e8 07 12 00 00       	call   8012f0 <close>
			sys_yield();
  8000e9:	e8 8a 0b 00 00       	call   800c78 <sys_yield>
	if (r == 0) {
		// child just dups and closes repeatedly,
		// yielding so the parent can see
		// the fd state between the two.
		close(p[1]);
		for (i = 0; i < 200; i++) {
  8000ee:	83 c3 01             	add    $0x1,%ebx
  8000f1:	83 c4 10             	add    $0x10,%esp
  8000f4:	81 fb c8 00 00 00    	cmp    $0xc8,%ebx
  8000fa:	75 a7                	jne    8000a3 <umain+0x70>
			dup(p[0], 10);
			sys_yield();
			close(10);
			sys_yield();
		}
		exit();
  8000fc:	e8 1b 01 00 00       	call   80021c <exit>
	// pageref(p[0]) and gets 3, then it will return true when
	// it shouldn't.
	//
	// So either way, pipeisclosed is going give a wrong answer.
	//
	kid = &envs[ENVX(r)];
  800101:	89 f0                	mov    %esi,%eax
  800103:	25 ff 03 00 00       	and    $0x3ff,%eax
	while (kid->env_status == ENV_RUNNABLE)
  800108:	8d 3c 85 00 00 00 00 	lea    0x0(,%eax,4),%edi
  80010f:	c1 e0 07             	shl    $0x7,%eax
  800112:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800115:	eb 2f                	jmp    800146 <umain+0x113>
		if (pipeisclosed(p[0]) != 0) {
  800117:	83 ec 0c             	sub    $0xc,%esp
  80011a:	ff 75 e0             	pushl  -0x20(%ebp)
  80011d:	e8 f2 1f 00 00       	call   802114 <pipeisclosed>
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	85 c0                	test   %eax,%eax
  800127:	74 28                	je     800151 <umain+0x11e>
			cprintf("\nRACE: pipe appears closed\n");
  800129:	83 ec 0c             	sub    $0xc,%esp
  80012c:	68 90 27 80 00       	push   $0x802790
  800131:	e8 d9 01 00 00       	call   80030f <cprintf>
			sys_env_destroy(r);
  800136:	89 34 24             	mov    %esi,(%esp)
  800139:	e8 da 0a 00 00       	call   800c18 <sys_env_destroy>
			exit();
  80013e:	e8 d9 00 00 00       	call   80021c <exit>
  800143:	83 c4 10             	add    $0x10,%esp
	// it shouldn't.
	//
	// So either way, pipeisclosed is going give a wrong answer.
	//
	kid = &envs[ENVX(r)];
	while (kid->env_status == ENV_RUNNABLE)
  800146:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800149:	29 fb                	sub    %edi,%ebx
  80014b:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  800151:	8b 43 54             	mov    0x54(%ebx),%eax
  800154:	83 f8 02             	cmp    $0x2,%eax
  800157:	74 be                	je     800117 <umain+0xe4>
		if (pipeisclosed(p[0]) != 0) {
			cprintf("\nRACE: pipe appears closed\n");
			sys_env_destroy(r);
			exit();
		}
	cprintf("child done with loop\n");
  800159:	83 ec 0c             	sub    $0xc,%esp
  80015c:	68 ac 27 80 00       	push   $0x8027ac
  800161:	e8 a9 01 00 00       	call   80030f <cprintf>
	if (pipeisclosed(p[0]))
  800166:	83 c4 04             	add    $0x4,%esp
  800169:	ff 75 e0             	pushl  -0x20(%ebp)
  80016c:	e8 a3 1f 00 00       	call   802114 <pipeisclosed>
  800171:	83 c4 10             	add    $0x10,%esp
  800174:	85 c0                	test   %eax,%eax
  800176:	74 14                	je     80018c <umain+0x159>
		panic("somehow the other end of p[0] got closed!");
  800178:	83 ec 04             	sub    $0x4,%esp
  80017b:	68 44 27 80 00       	push   $0x802744
  800180:	6a 40                	push   $0x40
  800182:	68 77 27 80 00       	push   $0x802777
  800187:	e8 aa 00 00 00       	call   800236 <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  80018c:	83 ec 08             	sub    $0x8,%esp
  80018f:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800192:	50                   	push   %eax
  800193:	ff 75 e0             	pushl  -0x20(%ebp)
  800196:	e8 2b 10 00 00       	call   8011c6 <fd_lookup>
  80019b:	83 c4 10             	add    $0x10,%esp
  80019e:	85 c0                	test   %eax,%eax
  8001a0:	79 12                	jns    8001b4 <umain+0x181>
		panic("cannot look up p[0]: %e", r);
  8001a2:	50                   	push   %eax
  8001a3:	68 c2 27 80 00       	push   $0x8027c2
  8001a8:	6a 42                	push   $0x42
  8001aa:	68 77 27 80 00       	push   $0x802777
  8001af:	e8 82 00 00 00       	call   800236 <_panic>
	(void) fd2data(fd);
  8001b4:	83 ec 0c             	sub    $0xc,%esp
  8001b7:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ba:	e8 a1 0f 00 00       	call   801160 <fd2data>
	cprintf("race didn't happen\n");
  8001bf:	c7 04 24 da 27 80 00 	movl   $0x8027da,(%esp)
  8001c6:	e8 44 01 00 00       	call   80030f <cprintf>
}
  8001cb:	83 c4 10             	add    $0x10,%esp
  8001ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d1:	5b                   	pop    %ebx
  8001d2:	5e                   	pop    %esi
  8001d3:	5f                   	pop    %edi
  8001d4:	5d                   	pop    %ebp
  8001d5:	c3                   	ret    

008001d6 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001d6:	55                   	push   %ebp
  8001d7:	89 e5                	mov    %esp,%ebp
  8001d9:	56                   	push   %esi
  8001da:	53                   	push   %ebx
  8001db:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001de:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8001e1:	e8 73 0a 00 00       	call   800c59 <sys_getenvid>
  8001e6:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001eb:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001ee:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001f3:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001f8:	85 db                	test   %ebx,%ebx
  8001fa:	7e 07                	jle    800203 <libmain+0x2d>
		binaryname = argv[0];
  8001fc:	8b 06                	mov    (%esi),%eax
  8001fe:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800203:	83 ec 08             	sub    $0x8,%esp
  800206:	56                   	push   %esi
  800207:	53                   	push   %ebx
  800208:	e8 26 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80020d:	e8 0a 00 00 00       	call   80021c <exit>
}
  800212:	83 c4 10             	add    $0x10,%esp
  800215:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800218:	5b                   	pop    %ebx
  800219:	5e                   	pop    %esi
  80021a:	5d                   	pop    %ebp
  80021b:	c3                   	ret    

0080021c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800222:	e8 f4 10 00 00       	call   80131b <close_all>
	sys_env_destroy(0);
  800227:	83 ec 0c             	sub    $0xc,%esp
  80022a:	6a 00                	push   $0x0
  80022c:	e8 e7 09 00 00       	call   800c18 <sys_env_destroy>
}
  800231:	83 c4 10             	add    $0x10,%esp
  800234:	c9                   	leave  
  800235:	c3                   	ret    

00800236 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800236:	55                   	push   %ebp
  800237:	89 e5                	mov    %esp,%ebp
  800239:	56                   	push   %esi
  80023a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80023b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80023e:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800244:	e8 10 0a 00 00       	call   800c59 <sys_getenvid>
  800249:	83 ec 0c             	sub    $0xc,%esp
  80024c:	ff 75 0c             	pushl  0xc(%ebp)
  80024f:	ff 75 08             	pushl  0x8(%ebp)
  800252:	56                   	push   %esi
  800253:	50                   	push   %eax
  800254:	68 f8 27 80 00       	push   $0x8027f8
  800259:	e8 b1 00 00 00       	call   80030f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80025e:	83 c4 18             	add    $0x18,%esp
  800261:	53                   	push   %ebx
  800262:	ff 75 10             	pushl  0x10(%ebp)
  800265:	e8 54 00 00 00       	call   8002be <vcprintf>
	cprintf("\n");
  80026a:	c7 04 24 f0 2c 80 00 	movl   $0x802cf0,(%esp)
  800271:	e8 99 00 00 00       	call   80030f <cprintf>
  800276:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800279:	cc                   	int3   
  80027a:	eb fd                	jmp    800279 <_panic+0x43>

0080027c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80027c:	55                   	push   %ebp
  80027d:	89 e5                	mov    %esp,%ebp
  80027f:	53                   	push   %ebx
  800280:	83 ec 04             	sub    $0x4,%esp
  800283:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800286:	8b 13                	mov    (%ebx),%edx
  800288:	8d 42 01             	lea    0x1(%edx),%eax
  80028b:	89 03                	mov    %eax,(%ebx)
  80028d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800290:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800294:	3d ff 00 00 00       	cmp    $0xff,%eax
  800299:	75 1a                	jne    8002b5 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80029b:	83 ec 08             	sub    $0x8,%esp
  80029e:	68 ff 00 00 00       	push   $0xff
  8002a3:	8d 43 08             	lea    0x8(%ebx),%eax
  8002a6:	50                   	push   %eax
  8002a7:	e8 2f 09 00 00       	call   800bdb <sys_cputs>
		b->idx = 0;
  8002ac:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002b2:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002b5:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002bc:	c9                   	leave  
  8002bd:	c3                   	ret    

008002be <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002be:	55                   	push   %ebp
  8002bf:	89 e5                	mov    %esp,%ebp
  8002c1:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002c7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002ce:	00 00 00 
	b.cnt = 0;
  8002d1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002d8:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002db:	ff 75 0c             	pushl  0xc(%ebp)
  8002de:	ff 75 08             	pushl  0x8(%ebp)
  8002e1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002e7:	50                   	push   %eax
  8002e8:	68 7c 02 80 00       	push   $0x80027c
  8002ed:	e8 54 01 00 00       	call   800446 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002f2:	83 c4 08             	add    $0x8,%esp
  8002f5:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002fb:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800301:	50                   	push   %eax
  800302:	e8 d4 08 00 00       	call   800bdb <sys_cputs>

	return b.cnt;
}
  800307:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80030d:	c9                   	leave  
  80030e:	c3                   	ret    

0080030f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80030f:	55                   	push   %ebp
  800310:	89 e5                	mov    %esp,%ebp
  800312:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800315:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800318:	50                   	push   %eax
  800319:	ff 75 08             	pushl  0x8(%ebp)
  80031c:	e8 9d ff ff ff       	call   8002be <vcprintf>
	va_end(ap);

	return cnt;
}
  800321:	c9                   	leave  
  800322:	c3                   	ret    

00800323 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800323:	55                   	push   %ebp
  800324:	89 e5                	mov    %esp,%ebp
  800326:	57                   	push   %edi
  800327:	56                   	push   %esi
  800328:	53                   	push   %ebx
  800329:	83 ec 1c             	sub    $0x1c,%esp
  80032c:	89 c7                	mov    %eax,%edi
  80032e:	89 d6                	mov    %edx,%esi
  800330:	8b 45 08             	mov    0x8(%ebp),%eax
  800333:	8b 55 0c             	mov    0xc(%ebp),%edx
  800336:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800339:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80033c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80033f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800344:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800347:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80034a:	39 d3                	cmp    %edx,%ebx
  80034c:	72 05                	jb     800353 <printnum+0x30>
  80034e:	39 45 10             	cmp    %eax,0x10(%ebp)
  800351:	77 45                	ja     800398 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800353:	83 ec 0c             	sub    $0xc,%esp
  800356:	ff 75 18             	pushl  0x18(%ebp)
  800359:	8b 45 14             	mov    0x14(%ebp),%eax
  80035c:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80035f:	53                   	push   %ebx
  800360:	ff 75 10             	pushl  0x10(%ebp)
  800363:	83 ec 08             	sub    $0x8,%esp
  800366:	ff 75 e4             	pushl  -0x1c(%ebp)
  800369:	ff 75 e0             	pushl  -0x20(%ebp)
  80036c:	ff 75 dc             	pushl  -0x24(%ebp)
  80036f:	ff 75 d8             	pushl  -0x28(%ebp)
  800372:	e8 09 21 00 00       	call   802480 <__udivdi3>
  800377:	83 c4 18             	add    $0x18,%esp
  80037a:	52                   	push   %edx
  80037b:	50                   	push   %eax
  80037c:	89 f2                	mov    %esi,%edx
  80037e:	89 f8                	mov    %edi,%eax
  800380:	e8 9e ff ff ff       	call   800323 <printnum>
  800385:	83 c4 20             	add    $0x20,%esp
  800388:	eb 18                	jmp    8003a2 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80038a:	83 ec 08             	sub    $0x8,%esp
  80038d:	56                   	push   %esi
  80038e:	ff 75 18             	pushl  0x18(%ebp)
  800391:	ff d7                	call   *%edi
  800393:	83 c4 10             	add    $0x10,%esp
  800396:	eb 03                	jmp    80039b <printnum+0x78>
  800398:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80039b:	83 eb 01             	sub    $0x1,%ebx
  80039e:	85 db                	test   %ebx,%ebx
  8003a0:	7f e8                	jg     80038a <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003a2:	83 ec 08             	sub    $0x8,%esp
  8003a5:	56                   	push   %esi
  8003a6:	83 ec 04             	sub    $0x4,%esp
  8003a9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003ac:	ff 75 e0             	pushl  -0x20(%ebp)
  8003af:	ff 75 dc             	pushl  -0x24(%ebp)
  8003b2:	ff 75 d8             	pushl  -0x28(%ebp)
  8003b5:	e8 f6 21 00 00       	call   8025b0 <__umoddi3>
  8003ba:	83 c4 14             	add    $0x14,%esp
  8003bd:	0f be 80 1b 28 80 00 	movsbl 0x80281b(%eax),%eax
  8003c4:	50                   	push   %eax
  8003c5:	ff d7                	call   *%edi
}
  8003c7:	83 c4 10             	add    $0x10,%esp
  8003ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003cd:	5b                   	pop    %ebx
  8003ce:	5e                   	pop    %esi
  8003cf:	5f                   	pop    %edi
  8003d0:	5d                   	pop    %ebp
  8003d1:	c3                   	ret    

008003d2 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003d2:	55                   	push   %ebp
  8003d3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003d5:	83 fa 01             	cmp    $0x1,%edx
  8003d8:	7e 0e                	jle    8003e8 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003da:	8b 10                	mov    (%eax),%edx
  8003dc:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003df:	89 08                	mov    %ecx,(%eax)
  8003e1:	8b 02                	mov    (%edx),%eax
  8003e3:	8b 52 04             	mov    0x4(%edx),%edx
  8003e6:	eb 22                	jmp    80040a <getuint+0x38>
	else if (lflag)
  8003e8:	85 d2                	test   %edx,%edx
  8003ea:	74 10                	je     8003fc <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003ec:	8b 10                	mov    (%eax),%edx
  8003ee:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003f1:	89 08                	mov    %ecx,(%eax)
  8003f3:	8b 02                	mov    (%edx),%eax
  8003f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8003fa:	eb 0e                	jmp    80040a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003fc:	8b 10                	mov    (%eax),%edx
  8003fe:	8d 4a 04             	lea    0x4(%edx),%ecx
  800401:	89 08                	mov    %ecx,(%eax)
  800403:	8b 02                	mov    (%edx),%eax
  800405:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80040a:	5d                   	pop    %ebp
  80040b:	c3                   	ret    

0080040c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80040c:	55                   	push   %ebp
  80040d:	89 e5                	mov    %esp,%ebp
  80040f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800412:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800416:	8b 10                	mov    (%eax),%edx
  800418:	3b 50 04             	cmp    0x4(%eax),%edx
  80041b:	73 0a                	jae    800427 <sprintputch+0x1b>
		*b->buf++ = ch;
  80041d:	8d 4a 01             	lea    0x1(%edx),%ecx
  800420:	89 08                	mov    %ecx,(%eax)
  800422:	8b 45 08             	mov    0x8(%ebp),%eax
  800425:	88 02                	mov    %al,(%edx)
}
  800427:	5d                   	pop    %ebp
  800428:	c3                   	ret    

00800429 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800429:	55                   	push   %ebp
  80042a:	89 e5                	mov    %esp,%ebp
  80042c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80042f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800432:	50                   	push   %eax
  800433:	ff 75 10             	pushl  0x10(%ebp)
  800436:	ff 75 0c             	pushl  0xc(%ebp)
  800439:	ff 75 08             	pushl  0x8(%ebp)
  80043c:	e8 05 00 00 00       	call   800446 <vprintfmt>
	va_end(ap);
}
  800441:	83 c4 10             	add    $0x10,%esp
  800444:	c9                   	leave  
  800445:	c3                   	ret    

00800446 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800446:	55                   	push   %ebp
  800447:	89 e5                	mov    %esp,%ebp
  800449:	57                   	push   %edi
  80044a:	56                   	push   %esi
  80044b:	53                   	push   %ebx
  80044c:	83 ec 2c             	sub    $0x2c,%esp
  80044f:	8b 75 08             	mov    0x8(%ebp),%esi
  800452:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800455:	8b 7d 10             	mov    0x10(%ebp),%edi
  800458:	eb 12                	jmp    80046c <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80045a:	85 c0                	test   %eax,%eax
  80045c:	0f 84 89 03 00 00    	je     8007eb <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800462:	83 ec 08             	sub    $0x8,%esp
  800465:	53                   	push   %ebx
  800466:	50                   	push   %eax
  800467:	ff d6                	call   *%esi
  800469:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80046c:	83 c7 01             	add    $0x1,%edi
  80046f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800473:	83 f8 25             	cmp    $0x25,%eax
  800476:	75 e2                	jne    80045a <vprintfmt+0x14>
  800478:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80047c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800483:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80048a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800491:	ba 00 00 00 00       	mov    $0x0,%edx
  800496:	eb 07                	jmp    80049f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800498:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80049b:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049f:	8d 47 01             	lea    0x1(%edi),%eax
  8004a2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004a5:	0f b6 07             	movzbl (%edi),%eax
  8004a8:	0f b6 c8             	movzbl %al,%ecx
  8004ab:	83 e8 23             	sub    $0x23,%eax
  8004ae:	3c 55                	cmp    $0x55,%al
  8004b0:	0f 87 1a 03 00 00    	ja     8007d0 <vprintfmt+0x38a>
  8004b6:	0f b6 c0             	movzbl %al,%eax
  8004b9:	ff 24 85 60 29 80 00 	jmp    *0x802960(,%eax,4)
  8004c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004c3:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004c7:	eb d6                	jmp    80049f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004d4:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004d7:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8004db:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8004de:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8004e1:	83 fa 09             	cmp    $0x9,%edx
  8004e4:	77 39                	ja     80051f <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004e6:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004e9:	eb e9                	jmp    8004d4 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ee:	8d 48 04             	lea    0x4(%eax),%ecx
  8004f1:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004f4:	8b 00                	mov    (%eax),%eax
  8004f6:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004fc:	eb 27                	jmp    800525 <vprintfmt+0xdf>
  8004fe:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800501:	85 c0                	test   %eax,%eax
  800503:	b9 00 00 00 00       	mov    $0x0,%ecx
  800508:	0f 49 c8             	cmovns %eax,%ecx
  80050b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800511:	eb 8c                	jmp    80049f <vprintfmt+0x59>
  800513:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800516:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80051d:	eb 80                	jmp    80049f <vprintfmt+0x59>
  80051f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800522:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800525:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800529:	0f 89 70 ff ff ff    	jns    80049f <vprintfmt+0x59>
				width = precision, precision = -1;
  80052f:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800532:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800535:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80053c:	e9 5e ff ff ff       	jmp    80049f <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800541:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800544:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800547:	e9 53 ff ff ff       	jmp    80049f <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80054c:	8b 45 14             	mov    0x14(%ebp),%eax
  80054f:	8d 50 04             	lea    0x4(%eax),%edx
  800552:	89 55 14             	mov    %edx,0x14(%ebp)
  800555:	83 ec 08             	sub    $0x8,%esp
  800558:	53                   	push   %ebx
  800559:	ff 30                	pushl  (%eax)
  80055b:	ff d6                	call   *%esi
			break;
  80055d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800560:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800563:	e9 04 ff ff ff       	jmp    80046c <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800568:	8b 45 14             	mov    0x14(%ebp),%eax
  80056b:	8d 50 04             	lea    0x4(%eax),%edx
  80056e:	89 55 14             	mov    %edx,0x14(%ebp)
  800571:	8b 00                	mov    (%eax),%eax
  800573:	99                   	cltd   
  800574:	31 d0                	xor    %edx,%eax
  800576:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800578:	83 f8 0f             	cmp    $0xf,%eax
  80057b:	7f 0b                	jg     800588 <vprintfmt+0x142>
  80057d:	8b 14 85 c0 2a 80 00 	mov    0x802ac0(,%eax,4),%edx
  800584:	85 d2                	test   %edx,%edx
  800586:	75 18                	jne    8005a0 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800588:	50                   	push   %eax
  800589:	68 33 28 80 00       	push   $0x802833
  80058e:	53                   	push   %ebx
  80058f:	56                   	push   %esi
  800590:	e8 94 fe ff ff       	call   800429 <printfmt>
  800595:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800598:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80059b:	e9 cc fe ff ff       	jmp    80046c <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8005a0:	52                   	push   %edx
  8005a1:	68 7e 2c 80 00       	push   $0x802c7e
  8005a6:	53                   	push   %ebx
  8005a7:	56                   	push   %esi
  8005a8:	e8 7c fe ff ff       	call   800429 <printfmt>
  8005ad:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005b3:	e9 b4 fe ff ff       	jmp    80046c <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bb:	8d 50 04             	lea    0x4(%eax),%edx
  8005be:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c1:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005c3:	85 ff                	test   %edi,%edi
  8005c5:	b8 2c 28 80 00       	mov    $0x80282c,%eax
  8005ca:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005cd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005d1:	0f 8e 94 00 00 00    	jle    80066b <vprintfmt+0x225>
  8005d7:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005db:	0f 84 98 00 00 00    	je     800679 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e1:	83 ec 08             	sub    $0x8,%esp
  8005e4:	ff 75 d0             	pushl  -0x30(%ebp)
  8005e7:	57                   	push   %edi
  8005e8:	e8 86 02 00 00       	call   800873 <strnlen>
  8005ed:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005f0:	29 c1                	sub    %eax,%ecx
  8005f2:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005f5:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005f8:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005fc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005ff:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800602:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800604:	eb 0f                	jmp    800615 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800606:	83 ec 08             	sub    $0x8,%esp
  800609:	53                   	push   %ebx
  80060a:	ff 75 e0             	pushl  -0x20(%ebp)
  80060d:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80060f:	83 ef 01             	sub    $0x1,%edi
  800612:	83 c4 10             	add    $0x10,%esp
  800615:	85 ff                	test   %edi,%edi
  800617:	7f ed                	jg     800606 <vprintfmt+0x1c0>
  800619:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80061c:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80061f:	85 c9                	test   %ecx,%ecx
  800621:	b8 00 00 00 00       	mov    $0x0,%eax
  800626:	0f 49 c1             	cmovns %ecx,%eax
  800629:	29 c1                	sub    %eax,%ecx
  80062b:	89 75 08             	mov    %esi,0x8(%ebp)
  80062e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800631:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800634:	89 cb                	mov    %ecx,%ebx
  800636:	eb 4d                	jmp    800685 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800638:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80063c:	74 1b                	je     800659 <vprintfmt+0x213>
  80063e:	0f be c0             	movsbl %al,%eax
  800641:	83 e8 20             	sub    $0x20,%eax
  800644:	83 f8 5e             	cmp    $0x5e,%eax
  800647:	76 10                	jbe    800659 <vprintfmt+0x213>
					putch('?', putdat);
  800649:	83 ec 08             	sub    $0x8,%esp
  80064c:	ff 75 0c             	pushl  0xc(%ebp)
  80064f:	6a 3f                	push   $0x3f
  800651:	ff 55 08             	call   *0x8(%ebp)
  800654:	83 c4 10             	add    $0x10,%esp
  800657:	eb 0d                	jmp    800666 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800659:	83 ec 08             	sub    $0x8,%esp
  80065c:	ff 75 0c             	pushl  0xc(%ebp)
  80065f:	52                   	push   %edx
  800660:	ff 55 08             	call   *0x8(%ebp)
  800663:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800666:	83 eb 01             	sub    $0x1,%ebx
  800669:	eb 1a                	jmp    800685 <vprintfmt+0x23f>
  80066b:	89 75 08             	mov    %esi,0x8(%ebp)
  80066e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800671:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800674:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800677:	eb 0c                	jmp    800685 <vprintfmt+0x23f>
  800679:	89 75 08             	mov    %esi,0x8(%ebp)
  80067c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80067f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800682:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800685:	83 c7 01             	add    $0x1,%edi
  800688:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80068c:	0f be d0             	movsbl %al,%edx
  80068f:	85 d2                	test   %edx,%edx
  800691:	74 23                	je     8006b6 <vprintfmt+0x270>
  800693:	85 f6                	test   %esi,%esi
  800695:	78 a1                	js     800638 <vprintfmt+0x1f2>
  800697:	83 ee 01             	sub    $0x1,%esi
  80069a:	79 9c                	jns    800638 <vprintfmt+0x1f2>
  80069c:	89 df                	mov    %ebx,%edi
  80069e:	8b 75 08             	mov    0x8(%ebp),%esi
  8006a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006a4:	eb 18                	jmp    8006be <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006a6:	83 ec 08             	sub    $0x8,%esp
  8006a9:	53                   	push   %ebx
  8006aa:	6a 20                	push   $0x20
  8006ac:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006ae:	83 ef 01             	sub    $0x1,%edi
  8006b1:	83 c4 10             	add    $0x10,%esp
  8006b4:	eb 08                	jmp    8006be <vprintfmt+0x278>
  8006b6:	89 df                	mov    %ebx,%edi
  8006b8:	8b 75 08             	mov    0x8(%ebp),%esi
  8006bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006be:	85 ff                	test   %edi,%edi
  8006c0:	7f e4                	jg     8006a6 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006c5:	e9 a2 fd ff ff       	jmp    80046c <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006ca:	83 fa 01             	cmp    $0x1,%edx
  8006cd:	7e 16                	jle    8006e5 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8006cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d2:	8d 50 08             	lea    0x8(%eax),%edx
  8006d5:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d8:	8b 50 04             	mov    0x4(%eax),%edx
  8006db:	8b 00                	mov    (%eax),%eax
  8006dd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006e0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006e3:	eb 32                	jmp    800717 <vprintfmt+0x2d1>
	else if (lflag)
  8006e5:	85 d2                	test   %edx,%edx
  8006e7:	74 18                	je     800701 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8006e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ec:	8d 50 04             	lea    0x4(%eax),%edx
  8006ef:	89 55 14             	mov    %edx,0x14(%ebp)
  8006f2:	8b 00                	mov    (%eax),%eax
  8006f4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006f7:	89 c1                	mov    %eax,%ecx
  8006f9:	c1 f9 1f             	sar    $0x1f,%ecx
  8006fc:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006ff:	eb 16                	jmp    800717 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800701:	8b 45 14             	mov    0x14(%ebp),%eax
  800704:	8d 50 04             	lea    0x4(%eax),%edx
  800707:	89 55 14             	mov    %edx,0x14(%ebp)
  80070a:	8b 00                	mov    (%eax),%eax
  80070c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80070f:	89 c1                	mov    %eax,%ecx
  800711:	c1 f9 1f             	sar    $0x1f,%ecx
  800714:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800717:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80071a:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80071d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800722:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800726:	79 74                	jns    80079c <vprintfmt+0x356>
				putch('-', putdat);
  800728:	83 ec 08             	sub    $0x8,%esp
  80072b:	53                   	push   %ebx
  80072c:	6a 2d                	push   $0x2d
  80072e:	ff d6                	call   *%esi
				num = -(long long) num;
  800730:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800733:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800736:	f7 d8                	neg    %eax
  800738:	83 d2 00             	adc    $0x0,%edx
  80073b:	f7 da                	neg    %edx
  80073d:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800740:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800745:	eb 55                	jmp    80079c <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800747:	8d 45 14             	lea    0x14(%ebp),%eax
  80074a:	e8 83 fc ff ff       	call   8003d2 <getuint>
			base = 10;
  80074f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800754:	eb 46                	jmp    80079c <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800756:	8d 45 14             	lea    0x14(%ebp),%eax
  800759:	e8 74 fc ff ff       	call   8003d2 <getuint>
                        base = 8;
  80075e:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800763:	eb 37                	jmp    80079c <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800765:	83 ec 08             	sub    $0x8,%esp
  800768:	53                   	push   %ebx
  800769:	6a 30                	push   $0x30
  80076b:	ff d6                	call   *%esi
			putch('x', putdat);
  80076d:	83 c4 08             	add    $0x8,%esp
  800770:	53                   	push   %ebx
  800771:	6a 78                	push   $0x78
  800773:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800775:	8b 45 14             	mov    0x14(%ebp),%eax
  800778:	8d 50 04             	lea    0x4(%eax),%edx
  80077b:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80077e:	8b 00                	mov    (%eax),%eax
  800780:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800785:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800788:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80078d:	eb 0d                	jmp    80079c <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80078f:	8d 45 14             	lea    0x14(%ebp),%eax
  800792:	e8 3b fc ff ff       	call   8003d2 <getuint>
			base = 16;
  800797:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80079c:	83 ec 0c             	sub    $0xc,%esp
  80079f:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8007a3:	57                   	push   %edi
  8007a4:	ff 75 e0             	pushl  -0x20(%ebp)
  8007a7:	51                   	push   %ecx
  8007a8:	52                   	push   %edx
  8007a9:	50                   	push   %eax
  8007aa:	89 da                	mov    %ebx,%edx
  8007ac:	89 f0                	mov    %esi,%eax
  8007ae:	e8 70 fb ff ff       	call   800323 <printnum>
			break;
  8007b3:	83 c4 20             	add    $0x20,%esp
  8007b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007b9:	e9 ae fc ff ff       	jmp    80046c <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007be:	83 ec 08             	sub    $0x8,%esp
  8007c1:	53                   	push   %ebx
  8007c2:	51                   	push   %ecx
  8007c3:	ff d6                	call   *%esi
			break;
  8007c5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007cb:	e9 9c fc ff ff       	jmp    80046c <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007d0:	83 ec 08             	sub    $0x8,%esp
  8007d3:	53                   	push   %ebx
  8007d4:	6a 25                	push   $0x25
  8007d6:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007d8:	83 c4 10             	add    $0x10,%esp
  8007db:	eb 03                	jmp    8007e0 <vprintfmt+0x39a>
  8007dd:	83 ef 01             	sub    $0x1,%edi
  8007e0:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007e4:	75 f7                	jne    8007dd <vprintfmt+0x397>
  8007e6:	e9 81 fc ff ff       	jmp    80046c <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007ee:	5b                   	pop    %ebx
  8007ef:	5e                   	pop    %esi
  8007f0:	5f                   	pop    %edi
  8007f1:	5d                   	pop    %ebp
  8007f2:	c3                   	ret    

008007f3 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007f3:	55                   	push   %ebp
  8007f4:	89 e5                	mov    %esp,%ebp
  8007f6:	83 ec 18             	sub    $0x18,%esp
  8007f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fc:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007ff:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800802:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800806:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800809:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800810:	85 c0                	test   %eax,%eax
  800812:	74 26                	je     80083a <vsnprintf+0x47>
  800814:	85 d2                	test   %edx,%edx
  800816:	7e 22                	jle    80083a <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800818:	ff 75 14             	pushl  0x14(%ebp)
  80081b:	ff 75 10             	pushl  0x10(%ebp)
  80081e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800821:	50                   	push   %eax
  800822:	68 0c 04 80 00       	push   $0x80040c
  800827:	e8 1a fc ff ff       	call   800446 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80082c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80082f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800832:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800835:	83 c4 10             	add    $0x10,%esp
  800838:	eb 05                	jmp    80083f <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80083a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80083f:	c9                   	leave  
  800840:	c3                   	ret    

00800841 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800841:	55                   	push   %ebp
  800842:	89 e5                	mov    %esp,%ebp
  800844:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800847:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80084a:	50                   	push   %eax
  80084b:	ff 75 10             	pushl  0x10(%ebp)
  80084e:	ff 75 0c             	pushl  0xc(%ebp)
  800851:	ff 75 08             	pushl  0x8(%ebp)
  800854:	e8 9a ff ff ff       	call   8007f3 <vsnprintf>
	va_end(ap);

	return rc;
}
  800859:	c9                   	leave  
  80085a:	c3                   	ret    

0080085b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80085b:	55                   	push   %ebp
  80085c:	89 e5                	mov    %esp,%ebp
  80085e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800861:	b8 00 00 00 00       	mov    $0x0,%eax
  800866:	eb 03                	jmp    80086b <strlen+0x10>
		n++;
  800868:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80086b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80086f:	75 f7                	jne    800868 <strlen+0xd>
		n++;
	return n;
}
  800871:	5d                   	pop    %ebp
  800872:	c3                   	ret    

00800873 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800873:	55                   	push   %ebp
  800874:	89 e5                	mov    %esp,%ebp
  800876:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800879:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80087c:	ba 00 00 00 00       	mov    $0x0,%edx
  800881:	eb 03                	jmp    800886 <strnlen+0x13>
		n++;
  800883:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800886:	39 c2                	cmp    %eax,%edx
  800888:	74 08                	je     800892 <strnlen+0x1f>
  80088a:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80088e:	75 f3                	jne    800883 <strnlen+0x10>
  800890:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800892:	5d                   	pop    %ebp
  800893:	c3                   	ret    

00800894 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800894:	55                   	push   %ebp
  800895:	89 e5                	mov    %esp,%ebp
  800897:	53                   	push   %ebx
  800898:	8b 45 08             	mov    0x8(%ebp),%eax
  80089b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80089e:	89 c2                	mov    %eax,%edx
  8008a0:	83 c2 01             	add    $0x1,%edx
  8008a3:	83 c1 01             	add    $0x1,%ecx
  8008a6:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008aa:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008ad:	84 db                	test   %bl,%bl
  8008af:	75 ef                	jne    8008a0 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008b1:	5b                   	pop    %ebx
  8008b2:	5d                   	pop    %ebp
  8008b3:	c3                   	ret    

008008b4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008b4:	55                   	push   %ebp
  8008b5:	89 e5                	mov    %esp,%ebp
  8008b7:	53                   	push   %ebx
  8008b8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008bb:	53                   	push   %ebx
  8008bc:	e8 9a ff ff ff       	call   80085b <strlen>
  8008c1:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008c4:	ff 75 0c             	pushl  0xc(%ebp)
  8008c7:	01 d8                	add    %ebx,%eax
  8008c9:	50                   	push   %eax
  8008ca:	e8 c5 ff ff ff       	call   800894 <strcpy>
	return dst;
}
  8008cf:	89 d8                	mov    %ebx,%eax
  8008d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008d4:	c9                   	leave  
  8008d5:	c3                   	ret    

008008d6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008d6:	55                   	push   %ebp
  8008d7:	89 e5                	mov    %esp,%ebp
  8008d9:	56                   	push   %esi
  8008da:	53                   	push   %ebx
  8008db:	8b 75 08             	mov    0x8(%ebp),%esi
  8008de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008e1:	89 f3                	mov    %esi,%ebx
  8008e3:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008e6:	89 f2                	mov    %esi,%edx
  8008e8:	eb 0f                	jmp    8008f9 <strncpy+0x23>
		*dst++ = *src;
  8008ea:	83 c2 01             	add    $0x1,%edx
  8008ed:	0f b6 01             	movzbl (%ecx),%eax
  8008f0:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008f3:	80 39 01             	cmpb   $0x1,(%ecx)
  8008f6:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008f9:	39 da                	cmp    %ebx,%edx
  8008fb:	75 ed                	jne    8008ea <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008fd:	89 f0                	mov    %esi,%eax
  8008ff:	5b                   	pop    %ebx
  800900:	5e                   	pop    %esi
  800901:	5d                   	pop    %ebp
  800902:	c3                   	ret    

00800903 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
  800906:	56                   	push   %esi
  800907:	53                   	push   %ebx
  800908:	8b 75 08             	mov    0x8(%ebp),%esi
  80090b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80090e:	8b 55 10             	mov    0x10(%ebp),%edx
  800911:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800913:	85 d2                	test   %edx,%edx
  800915:	74 21                	je     800938 <strlcpy+0x35>
  800917:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80091b:	89 f2                	mov    %esi,%edx
  80091d:	eb 09                	jmp    800928 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80091f:	83 c2 01             	add    $0x1,%edx
  800922:	83 c1 01             	add    $0x1,%ecx
  800925:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800928:	39 c2                	cmp    %eax,%edx
  80092a:	74 09                	je     800935 <strlcpy+0x32>
  80092c:	0f b6 19             	movzbl (%ecx),%ebx
  80092f:	84 db                	test   %bl,%bl
  800931:	75 ec                	jne    80091f <strlcpy+0x1c>
  800933:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800935:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800938:	29 f0                	sub    %esi,%eax
}
  80093a:	5b                   	pop    %ebx
  80093b:	5e                   	pop    %esi
  80093c:	5d                   	pop    %ebp
  80093d:	c3                   	ret    

0080093e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80093e:	55                   	push   %ebp
  80093f:	89 e5                	mov    %esp,%ebp
  800941:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800944:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800947:	eb 06                	jmp    80094f <strcmp+0x11>
		p++, q++;
  800949:	83 c1 01             	add    $0x1,%ecx
  80094c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80094f:	0f b6 01             	movzbl (%ecx),%eax
  800952:	84 c0                	test   %al,%al
  800954:	74 04                	je     80095a <strcmp+0x1c>
  800956:	3a 02                	cmp    (%edx),%al
  800958:	74 ef                	je     800949 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80095a:	0f b6 c0             	movzbl %al,%eax
  80095d:	0f b6 12             	movzbl (%edx),%edx
  800960:	29 d0                	sub    %edx,%eax
}
  800962:	5d                   	pop    %ebp
  800963:	c3                   	ret    

00800964 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800964:	55                   	push   %ebp
  800965:	89 e5                	mov    %esp,%ebp
  800967:	53                   	push   %ebx
  800968:	8b 45 08             	mov    0x8(%ebp),%eax
  80096b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80096e:	89 c3                	mov    %eax,%ebx
  800970:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800973:	eb 06                	jmp    80097b <strncmp+0x17>
		n--, p++, q++;
  800975:	83 c0 01             	add    $0x1,%eax
  800978:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80097b:	39 d8                	cmp    %ebx,%eax
  80097d:	74 15                	je     800994 <strncmp+0x30>
  80097f:	0f b6 08             	movzbl (%eax),%ecx
  800982:	84 c9                	test   %cl,%cl
  800984:	74 04                	je     80098a <strncmp+0x26>
  800986:	3a 0a                	cmp    (%edx),%cl
  800988:	74 eb                	je     800975 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80098a:	0f b6 00             	movzbl (%eax),%eax
  80098d:	0f b6 12             	movzbl (%edx),%edx
  800990:	29 d0                	sub    %edx,%eax
  800992:	eb 05                	jmp    800999 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800994:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800999:	5b                   	pop    %ebx
  80099a:	5d                   	pop    %ebp
  80099b:	c3                   	ret    

0080099c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80099c:	55                   	push   %ebp
  80099d:	89 e5                	mov    %esp,%ebp
  80099f:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009a6:	eb 07                	jmp    8009af <strchr+0x13>
		if (*s == c)
  8009a8:	38 ca                	cmp    %cl,%dl
  8009aa:	74 0f                	je     8009bb <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009ac:	83 c0 01             	add    $0x1,%eax
  8009af:	0f b6 10             	movzbl (%eax),%edx
  8009b2:	84 d2                	test   %dl,%dl
  8009b4:	75 f2                	jne    8009a8 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009b6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009bb:	5d                   	pop    %ebp
  8009bc:	c3                   	ret    

008009bd <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009bd:	55                   	push   %ebp
  8009be:	89 e5                	mov    %esp,%ebp
  8009c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009c7:	eb 03                	jmp    8009cc <strfind+0xf>
  8009c9:	83 c0 01             	add    $0x1,%eax
  8009cc:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009cf:	38 ca                	cmp    %cl,%dl
  8009d1:	74 04                	je     8009d7 <strfind+0x1a>
  8009d3:	84 d2                	test   %dl,%dl
  8009d5:	75 f2                	jne    8009c9 <strfind+0xc>
			break;
	return (char *) s;
}
  8009d7:	5d                   	pop    %ebp
  8009d8:	c3                   	ret    

008009d9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009d9:	55                   	push   %ebp
  8009da:	89 e5                	mov    %esp,%ebp
  8009dc:	57                   	push   %edi
  8009dd:	56                   	push   %esi
  8009de:	53                   	push   %ebx
  8009df:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009e2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009e5:	85 c9                	test   %ecx,%ecx
  8009e7:	74 36                	je     800a1f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009e9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009ef:	75 28                	jne    800a19 <memset+0x40>
  8009f1:	f6 c1 03             	test   $0x3,%cl
  8009f4:	75 23                	jne    800a19 <memset+0x40>
		c &= 0xFF;
  8009f6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009fa:	89 d3                	mov    %edx,%ebx
  8009fc:	c1 e3 08             	shl    $0x8,%ebx
  8009ff:	89 d6                	mov    %edx,%esi
  800a01:	c1 e6 18             	shl    $0x18,%esi
  800a04:	89 d0                	mov    %edx,%eax
  800a06:	c1 e0 10             	shl    $0x10,%eax
  800a09:	09 f0                	or     %esi,%eax
  800a0b:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a0d:	89 d8                	mov    %ebx,%eax
  800a0f:	09 d0                	or     %edx,%eax
  800a11:	c1 e9 02             	shr    $0x2,%ecx
  800a14:	fc                   	cld    
  800a15:	f3 ab                	rep stos %eax,%es:(%edi)
  800a17:	eb 06                	jmp    800a1f <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a19:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a1c:	fc                   	cld    
  800a1d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a1f:	89 f8                	mov    %edi,%eax
  800a21:	5b                   	pop    %ebx
  800a22:	5e                   	pop    %esi
  800a23:	5f                   	pop    %edi
  800a24:	5d                   	pop    %ebp
  800a25:	c3                   	ret    

00800a26 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a26:	55                   	push   %ebp
  800a27:	89 e5                	mov    %esp,%ebp
  800a29:	57                   	push   %edi
  800a2a:	56                   	push   %esi
  800a2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a31:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a34:	39 c6                	cmp    %eax,%esi
  800a36:	73 35                	jae    800a6d <memmove+0x47>
  800a38:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a3b:	39 d0                	cmp    %edx,%eax
  800a3d:	73 2e                	jae    800a6d <memmove+0x47>
		s += n;
		d += n;
  800a3f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a42:	89 d6                	mov    %edx,%esi
  800a44:	09 fe                	or     %edi,%esi
  800a46:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a4c:	75 13                	jne    800a61 <memmove+0x3b>
  800a4e:	f6 c1 03             	test   $0x3,%cl
  800a51:	75 0e                	jne    800a61 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a53:	83 ef 04             	sub    $0x4,%edi
  800a56:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a59:	c1 e9 02             	shr    $0x2,%ecx
  800a5c:	fd                   	std    
  800a5d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a5f:	eb 09                	jmp    800a6a <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a61:	83 ef 01             	sub    $0x1,%edi
  800a64:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a67:	fd                   	std    
  800a68:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a6a:	fc                   	cld    
  800a6b:	eb 1d                	jmp    800a8a <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a6d:	89 f2                	mov    %esi,%edx
  800a6f:	09 c2                	or     %eax,%edx
  800a71:	f6 c2 03             	test   $0x3,%dl
  800a74:	75 0f                	jne    800a85 <memmove+0x5f>
  800a76:	f6 c1 03             	test   $0x3,%cl
  800a79:	75 0a                	jne    800a85 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a7b:	c1 e9 02             	shr    $0x2,%ecx
  800a7e:	89 c7                	mov    %eax,%edi
  800a80:	fc                   	cld    
  800a81:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a83:	eb 05                	jmp    800a8a <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a85:	89 c7                	mov    %eax,%edi
  800a87:	fc                   	cld    
  800a88:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a8a:	5e                   	pop    %esi
  800a8b:	5f                   	pop    %edi
  800a8c:	5d                   	pop    %ebp
  800a8d:	c3                   	ret    

00800a8e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a8e:	55                   	push   %ebp
  800a8f:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a91:	ff 75 10             	pushl  0x10(%ebp)
  800a94:	ff 75 0c             	pushl  0xc(%ebp)
  800a97:	ff 75 08             	pushl  0x8(%ebp)
  800a9a:	e8 87 ff ff ff       	call   800a26 <memmove>
}
  800a9f:	c9                   	leave  
  800aa0:	c3                   	ret    

00800aa1 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aa1:	55                   	push   %ebp
  800aa2:	89 e5                	mov    %esp,%ebp
  800aa4:	56                   	push   %esi
  800aa5:	53                   	push   %ebx
  800aa6:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aac:	89 c6                	mov    %eax,%esi
  800aae:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ab1:	eb 1a                	jmp    800acd <memcmp+0x2c>
		if (*s1 != *s2)
  800ab3:	0f b6 08             	movzbl (%eax),%ecx
  800ab6:	0f b6 1a             	movzbl (%edx),%ebx
  800ab9:	38 d9                	cmp    %bl,%cl
  800abb:	74 0a                	je     800ac7 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800abd:	0f b6 c1             	movzbl %cl,%eax
  800ac0:	0f b6 db             	movzbl %bl,%ebx
  800ac3:	29 d8                	sub    %ebx,%eax
  800ac5:	eb 0f                	jmp    800ad6 <memcmp+0x35>
		s1++, s2++;
  800ac7:	83 c0 01             	add    $0x1,%eax
  800aca:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800acd:	39 f0                	cmp    %esi,%eax
  800acf:	75 e2                	jne    800ab3 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ad1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ad6:	5b                   	pop    %ebx
  800ad7:	5e                   	pop    %esi
  800ad8:	5d                   	pop    %ebp
  800ad9:	c3                   	ret    

00800ada <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ada:	55                   	push   %ebp
  800adb:	89 e5                	mov    %esp,%ebp
  800add:	53                   	push   %ebx
  800ade:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ae1:	89 c1                	mov    %eax,%ecx
  800ae3:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800ae6:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800aea:	eb 0a                	jmp    800af6 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800aec:	0f b6 10             	movzbl (%eax),%edx
  800aef:	39 da                	cmp    %ebx,%edx
  800af1:	74 07                	je     800afa <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800af3:	83 c0 01             	add    $0x1,%eax
  800af6:	39 c8                	cmp    %ecx,%eax
  800af8:	72 f2                	jb     800aec <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800afa:	5b                   	pop    %ebx
  800afb:	5d                   	pop    %ebp
  800afc:	c3                   	ret    

00800afd <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800afd:	55                   	push   %ebp
  800afe:	89 e5                	mov    %esp,%ebp
  800b00:	57                   	push   %edi
  800b01:	56                   	push   %esi
  800b02:	53                   	push   %ebx
  800b03:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b06:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b09:	eb 03                	jmp    800b0e <strtol+0x11>
		s++;
  800b0b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b0e:	0f b6 01             	movzbl (%ecx),%eax
  800b11:	3c 20                	cmp    $0x20,%al
  800b13:	74 f6                	je     800b0b <strtol+0xe>
  800b15:	3c 09                	cmp    $0x9,%al
  800b17:	74 f2                	je     800b0b <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b19:	3c 2b                	cmp    $0x2b,%al
  800b1b:	75 0a                	jne    800b27 <strtol+0x2a>
		s++;
  800b1d:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b20:	bf 00 00 00 00       	mov    $0x0,%edi
  800b25:	eb 11                	jmp    800b38 <strtol+0x3b>
  800b27:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b2c:	3c 2d                	cmp    $0x2d,%al
  800b2e:	75 08                	jne    800b38 <strtol+0x3b>
		s++, neg = 1;
  800b30:	83 c1 01             	add    $0x1,%ecx
  800b33:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b38:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b3e:	75 15                	jne    800b55 <strtol+0x58>
  800b40:	80 39 30             	cmpb   $0x30,(%ecx)
  800b43:	75 10                	jne    800b55 <strtol+0x58>
  800b45:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b49:	75 7c                	jne    800bc7 <strtol+0xca>
		s += 2, base = 16;
  800b4b:	83 c1 02             	add    $0x2,%ecx
  800b4e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b53:	eb 16                	jmp    800b6b <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b55:	85 db                	test   %ebx,%ebx
  800b57:	75 12                	jne    800b6b <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b59:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b5e:	80 39 30             	cmpb   $0x30,(%ecx)
  800b61:	75 08                	jne    800b6b <strtol+0x6e>
		s++, base = 8;
  800b63:	83 c1 01             	add    $0x1,%ecx
  800b66:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b6b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b70:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b73:	0f b6 11             	movzbl (%ecx),%edx
  800b76:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b79:	89 f3                	mov    %esi,%ebx
  800b7b:	80 fb 09             	cmp    $0x9,%bl
  800b7e:	77 08                	ja     800b88 <strtol+0x8b>
			dig = *s - '0';
  800b80:	0f be d2             	movsbl %dl,%edx
  800b83:	83 ea 30             	sub    $0x30,%edx
  800b86:	eb 22                	jmp    800baa <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b88:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b8b:	89 f3                	mov    %esi,%ebx
  800b8d:	80 fb 19             	cmp    $0x19,%bl
  800b90:	77 08                	ja     800b9a <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b92:	0f be d2             	movsbl %dl,%edx
  800b95:	83 ea 57             	sub    $0x57,%edx
  800b98:	eb 10                	jmp    800baa <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b9a:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b9d:	89 f3                	mov    %esi,%ebx
  800b9f:	80 fb 19             	cmp    $0x19,%bl
  800ba2:	77 16                	ja     800bba <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ba4:	0f be d2             	movsbl %dl,%edx
  800ba7:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800baa:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bad:	7d 0b                	jge    800bba <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800baf:	83 c1 01             	add    $0x1,%ecx
  800bb2:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bb6:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800bb8:	eb b9                	jmp    800b73 <strtol+0x76>

	if (endptr)
  800bba:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bbe:	74 0d                	je     800bcd <strtol+0xd0>
		*endptr = (char *) s;
  800bc0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bc3:	89 0e                	mov    %ecx,(%esi)
  800bc5:	eb 06                	jmp    800bcd <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bc7:	85 db                	test   %ebx,%ebx
  800bc9:	74 98                	je     800b63 <strtol+0x66>
  800bcb:	eb 9e                	jmp    800b6b <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800bcd:	89 c2                	mov    %eax,%edx
  800bcf:	f7 da                	neg    %edx
  800bd1:	85 ff                	test   %edi,%edi
  800bd3:	0f 45 c2             	cmovne %edx,%eax
}
  800bd6:	5b                   	pop    %ebx
  800bd7:	5e                   	pop    %esi
  800bd8:	5f                   	pop    %edi
  800bd9:	5d                   	pop    %ebp
  800bda:	c3                   	ret    

00800bdb <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
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
  800be1:	b8 00 00 00 00       	mov    $0x0,%eax
  800be6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bec:	89 c3                	mov    %eax,%ebx
  800bee:	89 c7                	mov    %eax,%edi
  800bf0:	89 c6                	mov    %eax,%esi
  800bf2:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bf4:	5b                   	pop    %ebx
  800bf5:	5e                   	pop    %esi
  800bf6:	5f                   	pop    %edi
  800bf7:	5d                   	pop    %ebp
  800bf8:	c3                   	ret    

00800bf9 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bf9:	55                   	push   %ebp
  800bfa:	89 e5                	mov    %esp,%ebp
  800bfc:	57                   	push   %edi
  800bfd:	56                   	push   %esi
  800bfe:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bff:	ba 00 00 00 00       	mov    $0x0,%edx
  800c04:	b8 01 00 00 00       	mov    $0x1,%eax
  800c09:	89 d1                	mov    %edx,%ecx
  800c0b:	89 d3                	mov    %edx,%ebx
  800c0d:	89 d7                	mov    %edx,%edi
  800c0f:	89 d6                	mov    %edx,%esi
  800c11:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c13:	5b                   	pop    %ebx
  800c14:	5e                   	pop    %esi
  800c15:	5f                   	pop    %edi
  800c16:	5d                   	pop    %ebp
  800c17:	c3                   	ret    

00800c18 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c18:	55                   	push   %ebp
  800c19:	89 e5                	mov    %esp,%ebp
  800c1b:	57                   	push   %edi
  800c1c:	56                   	push   %esi
  800c1d:	53                   	push   %ebx
  800c1e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c21:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c26:	b8 03 00 00 00       	mov    $0x3,%eax
  800c2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2e:	89 cb                	mov    %ecx,%ebx
  800c30:	89 cf                	mov    %ecx,%edi
  800c32:	89 ce                	mov    %ecx,%esi
  800c34:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c36:	85 c0                	test   %eax,%eax
  800c38:	7e 17                	jle    800c51 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3a:	83 ec 0c             	sub    $0xc,%esp
  800c3d:	50                   	push   %eax
  800c3e:	6a 03                	push   $0x3
  800c40:	68 1f 2b 80 00       	push   $0x802b1f
  800c45:	6a 23                	push   $0x23
  800c47:	68 3c 2b 80 00       	push   $0x802b3c
  800c4c:	e8 e5 f5 ff ff       	call   800236 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c51:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c54:	5b                   	pop    %ebx
  800c55:	5e                   	pop    %esi
  800c56:	5f                   	pop    %edi
  800c57:	5d                   	pop    %ebp
  800c58:	c3                   	ret    

00800c59 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c59:	55                   	push   %ebp
  800c5a:	89 e5                	mov    %esp,%ebp
  800c5c:	57                   	push   %edi
  800c5d:	56                   	push   %esi
  800c5e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5f:	ba 00 00 00 00       	mov    $0x0,%edx
  800c64:	b8 02 00 00 00       	mov    $0x2,%eax
  800c69:	89 d1                	mov    %edx,%ecx
  800c6b:	89 d3                	mov    %edx,%ebx
  800c6d:	89 d7                	mov    %edx,%edi
  800c6f:	89 d6                	mov    %edx,%esi
  800c71:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c73:	5b                   	pop    %ebx
  800c74:	5e                   	pop    %esi
  800c75:	5f                   	pop    %edi
  800c76:	5d                   	pop    %ebp
  800c77:	c3                   	ret    

00800c78 <sys_yield>:

void
sys_yield(void)
{
  800c78:	55                   	push   %ebp
  800c79:	89 e5                	mov    %esp,%ebp
  800c7b:	57                   	push   %edi
  800c7c:	56                   	push   %esi
  800c7d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7e:	ba 00 00 00 00       	mov    $0x0,%edx
  800c83:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c88:	89 d1                	mov    %edx,%ecx
  800c8a:	89 d3                	mov    %edx,%ebx
  800c8c:	89 d7                	mov    %edx,%edi
  800c8e:	89 d6                	mov    %edx,%esi
  800c90:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c92:	5b                   	pop    %ebx
  800c93:	5e                   	pop    %esi
  800c94:	5f                   	pop    %edi
  800c95:	5d                   	pop    %ebp
  800c96:	c3                   	ret    

00800c97 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c97:	55                   	push   %ebp
  800c98:	89 e5                	mov    %esp,%ebp
  800c9a:	57                   	push   %edi
  800c9b:	56                   	push   %esi
  800c9c:	53                   	push   %ebx
  800c9d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca0:	be 00 00 00 00       	mov    $0x0,%esi
  800ca5:	b8 04 00 00 00       	mov    $0x4,%eax
  800caa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cad:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cb3:	89 f7                	mov    %esi,%edi
  800cb5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cb7:	85 c0                	test   %eax,%eax
  800cb9:	7e 17                	jle    800cd2 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbb:	83 ec 0c             	sub    $0xc,%esp
  800cbe:	50                   	push   %eax
  800cbf:	6a 04                	push   $0x4
  800cc1:	68 1f 2b 80 00       	push   $0x802b1f
  800cc6:	6a 23                	push   $0x23
  800cc8:	68 3c 2b 80 00       	push   $0x802b3c
  800ccd:	e8 64 f5 ff ff       	call   800236 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cd2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd5:	5b                   	pop    %ebx
  800cd6:	5e                   	pop    %esi
  800cd7:	5f                   	pop    %edi
  800cd8:	5d                   	pop    %ebp
  800cd9:	c3                   	ret    

00800cda <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cda:	55                   	push   %ebp
  800cdb:	89 e5                	mov    %esp,%ebp
  800cdd:	57                   	push   %edi
  800cde:	56                   	push   %esi
  800cdf:	53                   	push   %ebx
  800ce0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce3:	b8 05 00 00 00       	mov    $0x5,%eax
  800ce8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ceb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cee:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cf1:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cf4:	8b 75 18             	mov    0x18(%ebp),%esi
  800cf7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cf9:	85 c0                	test   %eax,%eax
  800cfb:	7e 17                	jle    800d14 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfd:	83 ec 0c             	sub    $0xc,%esp
  800d00:	50                   	push   %eax
  800d01:	6a 05                	push   $0x5
  800d03:	68 1f 2b 80 00       	push   $0x802b1f
  800d08:	6a 23                	push   $0x23
  800d0a:	68 3c 2b 80 00       	push   $0x802b3c
  800d0f:	e8 22 f5 ff ff       	call   800236 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d14:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d17:	5b                   	pop    %ebx
  800d18:	5e                   	pop    %esi
  800d19:	5f                   	pop    %edi
  800d1a:	5d                   	pop    %ebp
  800d1b:	c3                   	ret    

00800d1c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d1c:	55                   	push   %ebp
  800d1d:	89 e5                	mov    %esp,%ebp
  800d1f:	57                   	push   %edi
  800d20:	56                   	push   %esi
  800d21:	53                   	push   %ebx
  800d22:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d25:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d2a:	b8 06 00 00 00       	mov    $0x6,%eax
  800d2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d32:	8b 55 08             	mov    0x8(%ebp),%edx
  800d35:	89 df                	mov    %ebx,%edi
  800d37:	89 de                	mov    %ebx,%esi
  800d39:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d3b:	85 c0                	test   %eax,%eax
  800d3d:	7e 17                	jle    800d56 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3f:	83 ec 0c             	sub    $0xc,%esp
  800d42:	50                   	push   %eax
  800d43:	6a 06                	push   $0x6
  800d45:	68 1f 2b 80 00       	push   $0x802b1f
  800d4a:	6a 23                	push   $0x23
  800d4c:	68 3c 2b 80 00       	push   $0x802b3c
  800d51:	e8 e0 f4 ff ff       	call   800236 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d59:	5b                   	pop    %ebx
  800d5a:	5e                   	pop    %esi
  800d5b:	5f                   	pop    %edi
  800d5c:	5d                   	pop    %ebp
  800d5d:	c3                   	ret    

00800d5e <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d5e:	55                   	push   %ebp
  800d5f:	89 e5                	mov    %esp,%ebp
  800d61:	57                   	push   %edi
  800d62:	56                   	push   %esi
  800d63:	53                   	push   %ebx
  800d64:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d67:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d6c:	b8 08 00 00 00       	mov    $0x8,%eax
  800d71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d74:	8b 55 08             	mov    0x8(%ebp),%edx
  800d77:	89 df                	mov    %ebx,%edi
  800d79:	89 de                	mov    %ebx,%esi
  800d7b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d7d:	85 c0                	test   %eax,%eax
  800d7f:	7e 17                	jle    800d98 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d81:	83 ec 0c             	sub    $0xc,%esp
  800d84:	50                   	push   %eax
  800d85:	6a 08                	push   $0x8
  800d87:	68 1f 2b 80 00       	push   $0x802b1f
  800d8c:	6a 23                	push   $0x23
  800d8e:	68 3c 2b 80 00       	push   $0x802b3c
  800d93:	e8 9e f4 ff ff       	call   800236 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d98:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d9b:	5b                   	pop    %ebx
  800d9c:	5e                   	pop    %esi
  800d9d:	5f                   	pop    %edi
  800d9e:	5d                   	pop    %ebp
  800d9f:	c3                   	ret    

00800da0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800da0:	55                   	push   %ebp
  800da1:	89 e5                	mov    %esp,%ebp
  800da3:	57                   	push   %edi
  800da4:	56                   	push   %esi
  800da5:	53                   	push   %ebx
  800da6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dae:	b8 09 00 00 00       	mov    $0x9,%eax
  800db3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db6:	8b 55 08             	mov    0x8(%ebp),%edx
  800db9:	89 df                	mov    %ebx,%edi
  800dbb:	89 de                	mov    %ebx,%esi
  800dbd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dbf:	85 c0                	test   %eax,%eax
  800dc1:	7e 17                	jle    800dda <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc3:	83 ec 0c             	sub    $0xc,%esp
  800dc6:	50                   	push   %eax
  800dc7:	6a 09                	push   $0x9
  800dc9:	68 1f 2b 80 00       	push   $0x802b1f
  800dce:	6a 23                	push   $0x23
  800dd0:	68 3c 2b 80 00       	push   $0x802b3c
  800dd5:	e8 5c f4 ff ff       	call   800236 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800dda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ddd:	5b                   	pop    %ebx
  800dde:	5e                   	pop    %esi
  800ddf:	5f                   	pop    %edi
  800de0:	5d                   	pop    %ebp
  800de1:	c3                   	ret    

00800de2 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800de2:	55                   	push   %ebp
  800de3:	89 e5                	mov    %esp,%ebp
  800de5:	57                   	push   %edi
  800de6:	56                   	push   %esi
  800de7:	53                   	push   %ebx
  800de8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800deb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800df0:	b8 0a 00 00 00       	mov    $0xa,%eax
  800df5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfb:	89 df                	mov    %ebx,%edi
  800dfd:	89 de                	mov    %ebx,%esi
  800dff:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e01:	85 c0                	test   %eax,%eax
  800e03:	7e 17                	jle    800e1c <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e05:	83 ec 0c             	sub    $0xc,%esp
  800e08:	50                   	push   %eax
  800e09:	6a 0a                	push   $0xa
  800e0b:	68 1f 2b 80 00       	push   $0x802b1f
  800e10:	6a 23                	push   $0x23
  800e12:	68 3c 2b 80 00       	push   $0x802b3c
  800e17:	e8 1a f4 ff ff       	call   800236 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e1f:	5b                   	pop    %ebx
  800e20:	5e                   	pop    %esi
  800e21:	5f                   	pop    %edi
  800e22:	5d                   	pop    %ebp
  800e23:	c3                   	ret    

00800e24 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e24:	55                   	push   %ebp
  800e25:	89 e5                	mov    %esp,%ebp
  800e27:	57                   	push   %edi
  800e28:	56                   	push   %esi
  800e29:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2a:	be 00 00 00 00       	mov    $0x0,%esi
  800e2f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e37:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e3d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e40:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e42:	5b                   	pop    %ebx
  800e43:	5e                   	pop    %esi
  800e44:	5f                   	pop    %edi
  800e45:	5d                   	pop    %ebp
  800e46:	c3                   	ret    

00800e47 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e47:	55                   	push   %ebp
  800e48:	89 e5                	mov    %esp,%ebp
  800e4a:	57                   	push   %edi
  800e4b:	56                   	push   %esi
  800e4c:	53                   	push   %ebx
  800e4d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e50:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e55:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5d:	89 cb                	mov    %ecx,%ebx
  800e5f:	89 cf                	mov    %ecx,%edi
  800e61:	89 ce                	mov    %ecx,%esi
  800e63:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e65:	85 c0                	test   %eax,%eax
  800e67:	7e 17                	jle    800e80 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e69:	83 ec 0c             	sub    $0xc,%esp
  800e6c:	50                   	push   %eax
  800e6d:	6a 0d                	push   $0xd
  800e6f:	68 1f 2b 80 00       	push   $0x802b1f
  800e74:	6a 23                	push   $0x23
  800e76:	68 3c 2b 80 00       	push   $0x802b3c
  800e7b:	e8 b6 f3 ff ff       	call   800236 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e83:	5b                   	pop    %ebx
  800e84:	5e                   	pop    %esi
  800e85:	5f                   	pop    %edi
  800e86:	5d                   	pop    %ebp
  800e87:	c3                   	ret    

00800e88 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e88:	55                   	push   %ebp
  800e89:	89 e5                	mov    %esp,%ebp
  800e8b:	57                   	push   %edi
  800e8c:	56                   	push   %esi
  800e8d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8e:	ba 00 00 00 00       	mov    $0x0,%edx
  800e93:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e98:	89 d1                	mov    %edx,%ecx
  800e9a:	89 d3                	mov    %edx,%ebx
  800e9c:	89 d7                	mov    %edx,%edi
  800e9e:	89 d6                	mov    %edx,%esi
  800ea0:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800ea2:	5b                   	pop    %ebx
  800ea3:	5e                   	pop    %esi
  800ea4:	5f                   	pop    %edi
  800ea5:	5d                   	pop    %ebp
  800ea6:	c3                   	ret    

00800ea7 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800ea7:	55                   	push   %ebp
  800ea8:	89 e5                	mov    %esp,%ebp
  800eaa:	53                   	push   %ebx
  800eab:	83 ec 04             	sub    $0x4,%esp
	int r;
	void * address = (void *)(pn*PGSIZE);
  800eae:	89 d3                	mov    %edx,%ebx
  800eb0:	c1 e3 0c             	shl    $0xc,%ebx
	
	if((uvpt[pn] & PTE_SHARE))
  800eb3:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800eba:	f6 c5 04             	test   $0x4,%ch
  800ebd:	74 38                	je     800ef7 <duppage+0x50>
	{
		if ((r = sys_page_map(0, address, envid, address, (uvpt[pn] | PTE_SYSCALL))) < 0)
  800ebf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ec6:	83 ec 0c             	sub    $0xc,%esp
  800ec9:	81 ca 07 0e 00 00    	or     $0xe07,%edx
  800ecf:	52                   	push   %edx
  800ed0:	53                   	push   %ebx
  800ed1:	50                   	push   %eax
  800ed2:	53                   	push   %ebx
  800ed3:	6a 00                	push   $0x0
  800ed5:	e8 00 fe ff ff       	call   800cda <sys_page_map>
  800eda:	83 c4 20             	add    $0x20,%esp
  800edd:	85 c0                	test   %eax,%eax
  800edf:	0f 89 b8 00 00 00    	jns    800f9d <duppage+0xf6>
			panic("sys_page_map: %e", r);
  800ee5:	50                   	push   %eax
  800ee6:	68 4a 2b 80 00       	push   $0x802b4a
  800eeb:	6a 4e                	push   $0x4e
  800eed:	68 5b 2b 80 00       	push   $0x802b5b
  800ef2:	e8 3f f3 ff ff       	call   800236 <_panic>
	}
	else if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW))
  800ef7:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800efe:	f6 c1 02             	test   $0x2,%cl
  800f01:	75 0c                	jne    800f0f <duppage+0x68>
  800f03:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800f0a:	f6 c5 08             	test   $0x8,%ch
  800f0d:	74 57                	je     800f66 <duppage+0xbf>
	{
		int perm = 0;
		perm |= PTE_P|PTE_U|PTE_COW;
	
		if ((r = sys_page_map(0, address, envid, address, perm)) < 0)
  800f0f:	83 ec 0c             	sub    $0xc,%esp
  800f12:	68 05 08 00 00       	push   $0x805
  800f17:	53                   	push   %ebx
  800f18:	50                   	push   %eax
  800f19:	53                   	push   %ebx
  800f1a:	6a 00                	push   $0x0
  800f1c:	e8 b9 fd ff ff       	call   800cda <sys_page_map>
  800f21:	83 c4 20             	add    $0x20,%esp
  800f24:	85 c0                	test   %eax,%eax
  800f26:	79 12                	jns    800f3a <duppage+0x93>
			panic("sys_page_map: %e", r);
  800f28:	50                   	push   %eax
  800f29:	68 4a 2b 80 00       	push   $0x802b4a
  800f2e:	6a 56                	push   $0x56
  800f30:	68 5b 2b 80 00       	push   $0x802b5b
  800f35:	e8 fc f2 ff ff       	call   800236 <_panic>
		if ((r = sys_page_map(0, address, 0, address, perm)) < 0)
  800f3a:	83 ec 0c             	sub    $0xc,%esp
  800f3d:	68 05 08 00 00       	push   $0x805
  800f42:	53                   	push   %ebx
  800f43:	6a 00                	push   $0x0
  800f45:	53                   	push   %ebx
  800f46:	6a 00                	push   $0x0
  800f48:	e8 8d fd ff ff       	call   800cda <sys_page_map>
  800f4d:	83 c4 20             	add    $0x20,%esp
  800f50:	85 c0                	test   %eax,%eax
  800f52:	79 49                	jns    800f9d <duppage+0xf6>
			panic("sys_page_map: %e", r);
  800f54:	50                   	push   %eax
  800f55:	68 4a 2b 80 00       	push   $0x802b4a
  800f5a:	6a 58                	push   $0x58
  800f5c:	68 5b 2b 80 00       	push   $0x802b5b
  800f61:	e8 d0 f2 ff ff       	call   800236 <_panic>
	}
	else if((uvpt[pn] & ~PTE_U) == 0)
  800f66:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f6d:	f7 c2 fb ff ff ff    	test   $0xfffffffb,%edx
  800f73:	75 28                	jne    800f9d <duppage+0xf6>
	{
		//cprintf("im here");
		if ((r = sys_page_map(0, address, envid, address, PTE_P|PTE_U)) < 0)
  800f75:	83 ec 0c             	sub    $0xc,%esp
  800f78:	6a 05                	push   $0x5
  800f7a:	53                   	push   %ebx
  800f7b:	50                   	push   %eax
  800f7c:	53                   	push   %ebx
  800f7d:	6a 00                	push   $0x0
  800f7f:	e8 56 fd ff ff       	call   800cda <sys_page_map>
  800f84:	83 c4 20             	add    $0x20,%esp
  800f87:	85 c0                	test   %eax,%eax
  800f89:	79 12                	jns    800f9d <duppage+0xf6>
			panic("sys_page_map: %e", r);	
  800f8b:	50                   	push   %eax
  800f8c:	68 4a 2b 80 00       	push   $0x802b4a
  800f91:	6a 5e                	push   $0x5e
  800f93:	68 5b 2b 80 00       	push   $0x802b5b
  800f98:	e8 99 f2 ff ff       	call   800236 <_panic>
	}
	return 0;
}
  800f9d:	b8 00 00 00 00       	mov    $0x0,%eax
  800fa2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fa5:	c9                   	leave  
  800fa6:	c3                   	ret    

00800fa7 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800fa7:	55                   	push   %ebp
  800fa8:	89 e5                	mov    %esp,%ebp
  800faa:	53                   	push   %ebx
  800fab:	83 ec 08             	sub    $0x8,%esp
	void *addr = (void *) utf->utf_fault_va;
  800fae:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb1:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	unsigned pn = ((uint32_t)addr)/PGSIZE;
  800fb3:	89 d8                	mov    %ebx,%eax
  800fb5:	c1 e8 0c             	shr    $0xc,%eax
	pte_t pte = uvpt[pn];
  800fb8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// Allocate a new page, mapped at temp location
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  800fbf:	6a 07                	push   $0x7
  800fc1:	68 00 f0 7f 00       	push   $0x7ff000
  800fc6:	6a 00                	push   $0x0
  800fc8:	e8 ca fc ff ff       	call   800c97 <sys_page_alloc>
  800fcd:	83 c4 10             	add    $0x10,%esp
  800fd0:	85 c0                	test   %eax,%eax
  800fd2:	79 12                	jns    800fe6 <pgfault+0x3f>
		panic("sys_page_alloc: %e", r);
  800fd4:	50                   	push   %eax
  800fd5:	68 66 2b 80 00       	push   $0x802b66
  800fda:	6a 2b                	push   $0x2b
  800fdc:	68 5b 2b 80 00       	push   $0x802b5b
  800fe1:	e8 50 f2 ff ff       	call   800236 <_panic>

	// Copy the data from the old page to this new page
	void *addr_pgstart = (void *) ROUNDDOWN(addr, PGSIZE);
  800fe6:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr_pgstart, PGSIZE);
  800fec:	83 ec 04             	sub    $0x4,%esp
  800fef:	68 00 10 00 00       	push   $0x1000
  800ff4:	53                   	push   %ebx
  800ff5:	68 00 f0 7f 00       	push   $0x7ff000
  800ffa:	e8 27 fa ff ff       	call   800a26 <memmove>

	// Move the new page to the old page's address
	if ((r = sys_page_map(0, PFTEMP, 0, addr_pgstart, PTE_P|PTE_U|PTE_W)) < 0)
  800fff:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801006:	53                   	push   %ebx
  801007:	6a 00                	push   $0x0
  801009:	68 00 f0 7f 00       	push   $0x7ff000
  80100e:	6a 00                	push   $0x0
  801010:	e8 c5 fc ff ff       	call   800cda <sys_page_map>
  801015:	83 c4 20             	add    $0x20,%esp
  801018:	85 c0                	test   %eax,%eax
  80101a:	79 12                	jns    80102e <pgfault+0x87>
		panic("sys_page_map: %e", r);
  80101c:	50                   	push   %eax
  80101d:	68 4a 2b 80 00       	push   $0x802b4a
  801022:	6a 33                	push   $0x33
  801024:	68 5b 2b 80 00       	push   $0x802b5b
  801029:	e8 08 f2 ff ff       	call   800236 <_panic>

	// Unmap the temp location
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  80102e:	83 ec 08             	sub    $0x8,%esp
  801031:	68 00 f0 7f 00       	push   $0x7ff000
  801036:	6a 00                	push   $0x0
  801038:	e8 df fc ff ff       	call   800d1c <sys_page_unmap>
  80103d:	83 c4 10             	add    $0x10,%esp
  801040:	85 c0                	test   %eax,%eax
  801042:	79 12                	jns    801056 <pgfault+0xaf>
		panic("sys_page_unmap: %e", r);
  801044:	50                   	push   %eax
  801045:	68 79 2b 80 00       	push   $0x802b79
  80104a:	6a 37                	push   $0x37
  80104c:	68 5b 2b 80 00       	push   $0x802b5b
  801051:	e8 e0 f1 ff ff       	call   800236 <_panic>
}
  801056:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801059:	c9                   	leave  
  80105a:	c3                   	ret    

0080105b <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80105b:	55                   	push   %ebp
  80105c:	89 e5                	mov    %esp,%ebp
  80105e:	56                   	push   %esi
  80105f:	53                   	push   %ebx
  801060:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
	// Set up page fault handler
	set_pgfault_handler(&pgfault);
  801063:	68 a7 0f 80 00       	push   $0x800fa7
  801068:	e8 5d 12 00 00       	call   8022ca <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  80106d:	b8 07 00 00 00       	mov    $0x7,%eax
  801072:	cd 30                	int    $0x30

	// Create child
	envid_t envid = sys_exofork();
  801074:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (envid < 0) {
  801077:	83 c4 10             	add    $0x10,%esp
  80107a:	85 c0                	test   %eax,%eax
  80107c:	79 12                	jns    801090 <fork+0x35>
		panic("sys_exofork: %e", envid);
  80107e:	50                   	push   %eax
  80107f:	68 8c 2b 80 00       	push   $0x802b8c
  801084:	6a 7c                	push   $0x7c
  801086:	68 5b 2b 80 00       	push   $0x802b5b
  80108b:	e8 a6 f1 ff ff       	call   800236 <_panic>
		return envid;
	}
	if (envid == 0) {
  801090:	85 c0                	test   %eax,%eax
  801092:	75 1e                	jne    8010b2 <fork+0x57>
		// We are the child.
		thisenv = &envs[ENVX(sys_getenvid())]; // Fix thisenv
  801094:	e8 c0 fb ff ff       	call   800c59 <sys_getenvid>
  801099:	25 ff 03 00 00       	and    $0x3ff,%eax
  80109e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8010a1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010a6:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  8010ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8010b0:	eb 7d                	jmp    80112f <fork+0xd4>

	// Set page fault handler on the child.
	// The parent needs to do it, else the child wouldn't be able to handle
	// the fault when trying to access it's stack (which happens as soon it starts)
	extern void _pgfault_upcall(void);
	sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);
  8010b2:	83 ec 04             	sub    $0x4,%esp
  8010b5:	6a 07                	push   $0x7
  8010b7:	68 00 f0 bf ee       	push   $0xeebff000
  8010bc:	50                   	push   %eax
  8010bd:	e8 d5 fb ff ff       	call   800c97 <sys_page_alloc>
	sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  8010c2:	83 c4 08             	add    $0x8,%esp
  8010c5:	68 0f 23 80 00       	push   $0x80230f
  8010ca:	ff 75 f4             	pushl  -0xc(%ebp)
  8010cd:	e8 10 fd ff ff       	call   800de2 <sys_env_set_pgfault_upcall>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  8010d2:	be 04 70 80 00       	mov    $0x807004,%esi
  8010d7:	c1 ee 0c             	shr    $0xc,%esi
  8010da:	83 c4 10             	add    $0x10,%esp
  8010dd:	bb 00 08 00 00       	mov    $0x800,%ebx
  8010e2:	eb 0d                	jmp    8010f1 <fork+0x96>
		duppage(envid, pn);
  8010e4:	89 da                	mov    %ebx,%edx
  8010e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010e9:	e8 b9 fd ff ff       	call   800ea7 <duppage>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  8010ee:	83 c3 01             	add    $0x1,%ebx
  8010f1:	39 f3                	cmp    %esi,%ebx
  8010f3:	76 ef                	jbe    8010e4 <fork+0x89>
	}

	// Also copy the stack we are currently running on
	// I think it should loop from ustacktop to this page, since the stack
	// can have more than 1 page
	duppage(envid, ((uint32_t) &envid)/PGSIZE);
  8010f5:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8010f8:	c1 ea 0c             	shr    $0xc,%edx
  8010fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010fe:	e8 a4 fd ff ff       	call   800ea7 <duppage>

	// Start the child environmnet running
	int r;
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  801103:	83 ec 08             	sub    $0x8,%esp
  801106:	6a 02                	push   $0x2
  801108:	ff 75 f4             	pushl  -0xc(%ebp)
  80110b:	e8 4e fc ff ff       	call   800d5e <sys_env_set_status>
  801110:	83 c4 10             	add    $0x10,%esp
  801113:	85 c0                	test   %eax,%eax
  801115:	79 15                	jns    80112c <fork+0xd1>
		panic("sys_env_set_status: %e", r);
  801117:	50                   	push   %eax
  801118:	68 9c 2b 80 00       	push   $0x802b9c
  80111d:	68 9c 00 00 00       	push   $0x9c
  801122:	68 5b 2b 80 00       	push   $0x802b5b
  801127:	e8 0a f1 ff ff       	call   800236 <_panic>
		return r;
	}

	return envid;
  80112c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80112f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801132:	5b                   	pop    %ebx
  801133:	5e                   	pop    %esi
  801134:	5d                   	pop    %ebp
  801135:	c3                   	ret    

00801136 <sfork>:

// Challenge!
int
sfork(void)
{
  801136:	55                   	push   %ebp
  801137:	89 e5                	mov    %esp,%ebp
  801139:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80113c:	68 b3 2b 80 00       	push   $0x802bb3
  801141:	68 a7 00 00 00       	push   $0xa7
  801146:	68 5b 2b 80 00       	push   $0x802b5b
  80114b:	e8 e6 f0 ff ff       	call   800236 <_panic>

00801150 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801150:	55                   	push   %ebp
  801151:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801153:	8b 45 08             	mov    0x8(%ebp),%eax
  801156:	05 00 00 00 30       	add    $0x30000000,%eax
  80115b:	c1 e8 0c             	shr    $0xc,%eax
}
  80115e:	5d                   	pop    %ebp
  80115f:	c3                   	ret    

00801160 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801160:	55                   	push   %ebp
  801161:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801163:	8b 45 08             	mov    0x8(%ebp),%eax
  801166:	05 00 00 00 30       	add    $0x30000000,%eax
  80116b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801170:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801175:	5d                   	pop    %ebp
  801176:	c3                   	ret    

00801177 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801177:	55                   	push   %ebp
  801178:	89 e5                	mov    %esp,%ebp
  80117a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80117d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801182:	89 c2                	mov    %eax,%edx
  801184:	c1 ea 16             	shr    $0x16,%edx
  801187:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80118e:	f6 c2 01             	test   $0x1,%dl
  801191:	74 11                	je     8011a4 <fd_alloc+0x2d>
  801193:	89 c2                	mov    %eax,%edx
  801195:	c1 ea 0c             	shr    $0xc,%edx
  801198:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80119f:	f6 c2 01             	test   $0x1,%dl
  8011a2:	75 09                	jne    8011ad <fd_alloc+0x36>
			*fd_store = fd;
  8011a4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ab:	eb 17                	jmp    8011c4 <fd_alloc+0x4d>
  8011ad:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011b2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011b7:	75 c9                	jne    801182 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011b9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011bf:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011c4:	5d                   	pop    %ebp
  8011c5:	c3                   	ret    

008011c6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011c6:	55                   	push   %ebp
  8011c7:	89 e5                	mov    %esp,%ebp
  8011c9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011cc:	83 f8 1f             	cmp    $0x1f,%eax
  8011cf:	77 36                	ja     801207 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011d1:	c1 e0 0c             	shl    $0xc,%eax
  8011d4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011d9:	89 c2                	mov    %eax,%edx
  8011db:	c1 ea 16             	shr    $0x16,%edx
  8011de:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011e5:	f6 c2 01             	test   $0x1,%dl
  8011e8:	74 24                	je     80120e <fd_lookup+0x48>
  8011ea:	89 c2                	mov    %eax,%edx
  8011ec:	c1 ea 0c             	shr    $0xc,%edx
  8011ef:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011f6:	f6 c2 01             	test   $0x1,%dl
  8011f9:	74 1a                	je     801215 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011fb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011fe:	89 02                	mov    %eax,(%edx)
	return 0;
  801200:	b8 00 00 00 00       	mov    $0x0,%eax
  801205:	eb 13                	jmp    80121a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801207:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80120c:	eb 0c                	jmp    80121a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80120e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801213:	eb 05                	jmp    80121a <fd_lookup+0x54>
  801215:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80121a:	5d                   	pop    %ebp
  80121b:	c3                   	ret    

0080121c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80121c:	55                   	push   %ebp
  80121d:	89 e5                	mov    %esp,%ebp
  80121f:	83 ec 08             	sub    $0x8,%esp
  801222:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801225:	ba 4c 2c 80 00       	mov    $0x802c4c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80122a:	eb 13                	jmp    80123f <dev_lookup+0x23>
  80122c:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80122f:	39 08                	cmp    %ecx,(%eax)
  801231:	75 0c                	jne    80123f <dev_lookup+0x23>
			*dev = devtab[i];
  801233:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801236:	89 01                	mov    %eax,(%ecx)
			return 0;
  801238:	b8 00 00 00 00       	mov    $0x0,%eax
  80123d:	eb 2e                	jmp    80126d <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80123f:	8b 02                	mov    (%edx),%eax
  801241:	85 c0                	test   %eax,%eax
  801243:	75 e7                	jne    80122c <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801245:	a1 08 40 80 00       	mov    0x804008,%eax
  80124a:	8b 40 48             	mov    0x48(%eax),%eax
  80124d:	83 ec 04             	sub    $0x4,%esp
  801250:	51                   	push   %ecx
  801251:	50                   	push   %eax
  801252:	68 cc 2b 80 00       	push   $0x802bcc
  801257:	e8 b3 f0 ff ff       	call   80030f <cprintf>
	*dev = 0;
  80125c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80125f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801265:	83 c4 10             	add    $0x10,%esp
  801268:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80126d:	c9                   	leave  
  80126e:	c3                   	ret    

0080126f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80126f:	55                   	push   %ebp
  801270:	89 e5                	mov    %esp,%ebp
  801272:	56                   	push   %esi
  801273:	53                   	push   %ebx
  801274:	83 ec 10             	sub    $0x10,%esp
  801277:	8b 75 08             	mov    0x8(%ebp),%esi
  80127a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80127d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801280:	50                   	push   %eax
  801281:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801287:	c1 e8 0c             	shr    $0xc,%eax
  80128a:	50                   	push   %eax
  80128b:	e8 36 ff ff ff       	call   8011c6 <fd_lookup>
  801290:	83 c4 08             	add    $0x8,%esp
  801293:	85 c0                	test   %eax,%eax
  801295:	78 05                	js     80129c <fd_close+0x2d>
	    || fd != fd2)
  801297:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80129a:	74 0c                	je     8012a8 <fd_close+0x39>
		return (must_exist ? r : 0);
  80129c:	84 db                	test   %bl,%bl
  80129e:	ba 00 00 00 00       	mov    $0x0,%edx
  8012a3:	0f 44 c2             	cmove  %edx,%eax
  8012a6:	eb 41                	jmp    8012e9 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012a8:	83 ec 08             	sub    $0x8,%esp
  8012ab:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012ae:	50                   	push   %eax
  8012af:	ff 36                	pushl  (%esi)
  8012b1:	e8 66 ff ff ff       	call   80121c <dev_lookup>
  8012b6:	89 c3                	mov    %eax,%ebx
  8012b8:	83 c4 10             	add    $0x10,%esp
  8012bb:	85 c0                	test   %eax,%eax
  8012bd:	78 1a                	js     8012d9 <fd_close+0x6a>
		if (dev->dev_close)
  8012bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c2:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012c5:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012ca:	85 c0                	test   %eax,%eax
  8012cc:	74 0b                	je     8012d9 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012ce:	83 ec 0c             	sub    $0xc,%esp
  8012d1:	56                   	push   %esi
  8012d2:	ff d0                	call   *%eax
  8012d4:	89 c3                	mov    %eax,%ebx
  8012d6:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012d9:	83 ec 08             	sub    $0x8,%esp
  8012dc:	56                   	push   %esi
  8012dd:	6a 00                	push   $0x0
  8012df:	e8 38 fa ff ff       	call   800d1c <sys_page_unmap>
	return r;
  8012e4:	83 c4 10             	add    $0x10,%esp
  8012e7:	89 d8                	mov    %ebx,%eax
}
  8012e9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012ec:	5b                   	pop    %ebx
  8012ed:	5e                   	pop    %esi
  8012ee:	5d                   	pop    %ebp
  8012ef:	c3                   	ret    

008012f0 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012f0:	55                   	push   %ebp
  8012f1:	89 e5                	mov    %esp,%ebp
  8012f3:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f9:	50                   	push   %eax
  8012fa:	ff 75 08             	pushl  0x8(%ebp)
  8012fd:	e8 c4 fe ff ff       	call   8011c6 <fd_lookup>
  801302:	83 c4 08             	add    $0x8,%esp
  801305:	85 c0                	test   %eax,%eax
  801307:	78 10                	js     801319 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801309:	83 ec 08             	sub    $0x8,%esp
  80130c:	6a 01                	push   $0x1
  80130e:	ff 75 f4             	pushl  -0xc(%ebp)
  801311:	e8 59 ff ff ff       	call   80126f <fd_close>
  801316:	83 c4 10             	add    $0x10,%esp
}
  801319:	c9                   	leave  
  80131a:	c3                   	ret    

0080131b <close_all>:

void
close_all(void)
{
  80131b:	55                   	push   %ebp
  80131c:	89 e5                	mov    %esp,%ebp
  80131e:	53                   	push   %ebx
  80131f:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801322:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801327:	83 ec 0c             	sub    $0xc,%esp
  80132a:	53                   	push   %ebx
  80132b:	e8 c0 ff ff ff       	call   8012f0 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801330:	83 c3 01             	add    $0x1,%ebx
  801333:	83 c4 10             	add    $0x10,%esp
  801336:	83 fb 20             	cmp    $0x20,%ebx
  801339:	75 ec                	jne    801327 <close_all+0xc>
		close(i);
}
  80133b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80133e:	c9                   	leave  
  80133f:	c3                   	ret    

00801340 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801340:	55                   	push   %ebp
  801341:	89 e5                	mov    %esp,%ebp
  801343:	57                   	push   %edi
  801344:	56                   	push   %esi
  801345:	53                   	push   %ebx
  801346:	83 ec 2c             	sub    $0x2c,%esp
  801349:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80134c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80134f:	50                   	push   %eax
  801350:	ff 75 08             	pushl  0x8(%ebp)
  801353:	e8 6e fe ff ff       	call   8011c6 <fd_lookup>
  801358:	83 c4 08             	add    $0x8,%esp
  80135b:	85 c0                	test   %eax,%eax
  80135d:	0f 88 c1 00 00 00    	js     801424 <dup+0xe4>
		return r;
	close(newfdnum);
  801363:	83 ec 0c             	sub    $0xc,%esp
  801366:	56                   	push   %esi
  801367:	e8 84 ff ff ff       	call   8012f0 <close>

	newfd = INDEX2FD(newfdnum);
  80136c:	89 f3                	mov    %esi,%ebx
  80136e:	c1 e3 0c             	shl    $0xc,%ebx
  801371:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801377:	83 c4 04             	add    $0x4,%esp
  80137a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80137d:	e8 de fd ff ff       	call   801160 <fd2data>
  801382:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801384:	89 1c 24             	mov    %ebx,(%esp)
  801387:	e8 d4 fd ff ff       	call   801160 <fd2data>
  80138c:	83 c4 10             	add    $0x10,%esp
  80138f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801392:	89 f8                	mov    %edi,%eax
  801394:	c1 e8 16             	shr    $0x16,%eax
  801397:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80139e:	a8 01                	test   $0x1,%al
  8013a0:	74 37                	je     8013d9 <dup+0x99>
  8013a2:	89 f8                	mov    %edi,%eax
  8013a4:	c1 e8 0c             	shr    $0xc,%eax
  8013a7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013ae:	f6 c2 01             	test   $0x1,%dl
  8013b1:	74 26                	je     8013d9 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013b3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013ba:	83 ec 0c             	sub    $0xc,%esp
  8013bd:	25 07 0e 00 00       	and    $0xe07,%eax
  8013c2:	50                   	push   %eax
  8013c3:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013c6:	6a 00                	push   $0x0
  8013c8:	57                   	push   %edi
  8013c9:	6a 00                	push   $0x0
  8013cb:	e8 0a f9 ff ff       	call   800cda <sys_page_map>
  8013d0:	89 c7                	mov    %eax,%edi
  8013d2:	83 c4 20             	add    $0x20,%esp
  8013d5:	85 c0                	test   %eax,%eax
  8013d7:	78 2e                	js     801407 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013d9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013dc:	89 d0                	mov    %edx,%eax
  8013de:	c1 e8 0c             	shr    $0xc,%eax
  8013e1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013e8:	83 ec 0c             	sub    $0xc,%esp
  8013eb:	25 07 0e 00 00       	and    $0xe07,%eax
  8013f0:	50                   	push   %eax
  8013f1:	53                   	push   %ebx
  8013f2:	6a 00                	push   $0x0
  8013f4:	52                   	push   %edx
  8013f5:	6a 00                	push   $0x0
  8013f7:	e8 de f8 ff ff       	call   800cda <sys_page_map>
  8013fc:	89 c7                	mov    %eax,%edi
  8013fe:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801401:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801403:	85 ff                	test   %edi,%edi
  801405:	79 1d                	jns    801424 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801407:	83 ec 08             	sub    $0x8,%esp
  80140a:	53                   	push   %ebx
  80140b:	6a 00                	push   $0x0
  80140d:	e8 0a f9 ff ff       	call   800d1c <sys_page_unmap>
	sys_page_unmap(0, nva);
  801412:	83 c4 08             	add    $0x8,%esp
  801415:	ff 75 d4             	pushl  -0x2c(%ebp)
  801418:	6a 00                	push   $0x0
  80141a:	e8 fd f8 ff ff       	call   800d1c <sys_page_unmap>
	return r;
  80141f:	83 c4 10             	add    $0x10,%esp
  801422:	89 f8                	mov    %edi,%eax
}
  801424:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801427:	5b                   	pop    %ebx
  801428:	5e                   	pop    %esi
  801429:	5f                   	pop    %edi
  80142a:	5d                   	pop    %ebp
  80142b:	c3                   	ret    

0080142c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80142c:	55                   	push   %ebp
  80142d:	89 e5                	mov    %esp,%ebp
  80142f:	53                   	push   %ebx
  801430:	83 ec 14             	sub    $0x14,%esp
  801433:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801436:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801439:	50                   	push   %eax
  80143a:	53                   	push   %ebx
  80143b:	e8 86 fd ff ff       	call   8011c6 <fd_lookup>
  801440:	83 c4 08             	add    $0x8,%esp
  801443:	89 c2                	mov    %eax,%edx
  801445:	85 c0                	test   %eax,%eax
  801447:	78 6d                	js     8014b6 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801449:	83 ec 08             	sub    $0x8,%esp
  80144c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80144f:	50                   	push   %eax
  801450:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801453:	ff 30                	pushl  (%eax)
  801455:	e8 c2 fd ff ff       	call   80121c <dev_lookup>
  80145a:	83 c4 10             	add    $0x10,%esp
  80145d:	85 c0                	test   %eax,%eax
  80145f:	78 4c                	js     8014ad <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801461:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801464:	8b 42 08             	mov    0x8(%edx),%eax
  801467:	83 e0 03             	and    $0x3,%eax
  80146a:	83 f8 01             	cmp    $0x1,%eax
  80146d:	75 21                	jne    801490 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80146f:	a1 08 40 80 00       	mov    0x804008,%eax
  801474:	8b 40 48             	mov    0x48(%eax),%eax
  801477:	83 ec 04             	sub    $0x4,%esp
  80147a:	53                   	push   %ebx
  80147b:	50                   	push   %eax
  80147c:	68 10 2c 80 00       	push   $0x802c10
  801481:	e8 89 ee ff ff       	call   80030f <cprintf>
		return -E_INVAL;
  801486:	83 c4 10             	add    $0x10,%esp
  801489:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80148e:	eb 26                	jmp    8014b6 <read+0x8a>
	}
	if (!dev->dev_read)
  801490:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801493:	8b 40 08             	mov    0x8(%eax),%eax
  801496:	85 c0                	test   %eax,%eax
  801498:	74 17                	je     8014b1 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80149a:	83 ec 04             	sub    $0x4,%esp
  80149d:	ff 75 10             	pushl  0x10(%ebp)
  8014a0:	ff 75 0c             	pushl  0xc(%ebp)
  8014a3:	52                   	push   %edx
  8014a4:	ff d0                	call   *%eax
  8014a6:	89 c2                	mov    %eax,%edx
  8014a8:	83 c4 10             	add    $0x10,%esp
  8014ab:	eb 09                	jmp    8014b6 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014ad:	89 c2                	mov    %eax,%edx
  8014af:	eb 05                	jmp    8014b6 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014b1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8014b6:	89 d0                	mov    %edx,%eax
  8014b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014bb:	c9                   	leave  
  8014bc:	c3                   	ret    

008014bd <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014bd:	55                   	push   %ebp
  8014be:	89 e5                	mov    %esp,%ebp
  8014c0:	57                   	push   %edi
  8014c1:	56                   	push   %esi
  8014c2:	53                   	push   %ebx
  8014c3:	83 ec 0c             	sub    $0xc,%esp
  8014c6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014c9:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014cc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014d1:	eb 21                	jmp    8014f4 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014d3:	83 ec 04             	sub    $0x4,%esp
  8014d6:	89 f0                	mov    %esi,%eax
  8014d8:	29 d8                	sub    %ebx,%eax
  8014da:	50                   	push   %eax
  8014db:	89 d8                	mov    %ebx,%eax
  8014dd:	03 45 0c             	add    0xc(%ebp),%eax
  8014e0:	50                   	push   %eax
  8014e1:	57                   	push   %edi
  8014e2:	e8 45 ff ff ff       	call   80142c <read>
		if (m < 0)
  8014e7:	83 c4 10             	add    $0x10,%esp
  8014ea:	85 c0                	test   %eax,%eax
  8014ec:	78 10                	js     8014fe <readn+0x41>
			return m;
		if (m == 0)
  8014ee:	85 c0                	test   %eax,%eax
  8014f0:	74 0a                	je     8014fc <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014f2:	01 c3                	add    %eax,%ebx
  8014f4:	39 f3                	cmp    %esi,%ebx
  8014f6:	72 db                	jb     8014d3 <readn+0x16>
  8014f8:	89 d8                	mov    %ebx,%eax
  8014fa:	eb 02                	jmp    8014fe <readn+0x41>
  8014fc:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8014fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801501:	5b                   	pop    %ebx
  801502:	5e                   	pop    %esi
  801503:	5f                   	pop    %edi
  801504:	5d                   	pop    %ebp
  801505:	c3                   	ret    

00801506 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801506:	55                   	push   %ebp
  801507:	89 e5                	mov    %esp,%ebp
  801509:	53                   	push   %ebx
  80150a:	83 ec 14             	sub    $0x14,%esp
  80150d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801510:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801513:	50                   	push   %eax
  801514:	53                   	push   %ebx
  801515:	e8 ac fc ff ff       	call   8011c6 <fd_lookup>
  80151a:	83 c4 08             	add    $0x8,%esp
  80151d:	89 c2                	mov    %eax,%edx
  80151f:	85 c0                	test   %eax,%eax
  801521:	78 68                	js     80158b <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801523:	83 ec 08             	sub    $0x8,%esp
  801526:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801529:	50                   	push   %eax
  80152a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80152d:	ff 30                	pushl  (%eax)
  80152f:	e8 e8 fc ff ff       	call   80121c <dev_lookup>
  801534:	83 c4 10             	add    $0x10,%esp
  801537:	85 c0                	test   %eax,%eax
  801539:	78 47                	js     801582 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80153b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80153e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801542:	75 21                	jne    801565 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801544:	a1 08 40 80 00       	mov    0x804008,%eax
  801549:	8b 40 48             	mov    0x48(%eax),%eax
  80154c:	83 ec 04             	sub    $0x4,%esp
  80154f:	53                   	push   %ebx
  801550:	50                   	push   %eax
  801551:	68 2c 2c 80 00       	push   $0x802c2c
  801556:	e8 b4 ed ff ff       	call   80030f <cprintf>
		return -E_INVAL;
  80155b:	83 c4 10             	add    $0x10,%esp
  80155e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801563:	eb 26                	jmp    80158b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801565:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801568:	8b 52 0c             	mov    0xc(%edx),%edx
  80156b:	85 d2                	test   %edx,%edx
  80156d:	74 17                	je     801586 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80156f:	83 ec 04             	sub    $0x4,%esp
  801572:	ff 75 10             	pushl  0x10(%ebp)
  801575:	ff 75 0c             	pushl  0xc(%ebp)
  801578:	50                   	push   %eax
  801579:	ff d2                	call   *%edx
  80157b:	89 c2                	mov    %eax,%edx
  80157d:	83 c4 10             	add    $0x10,%esp
  801580:	eb 09                	jmp    80158b <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801582:	89 c2                	mov    %eax,%edx
  801584:	eb 05                	jmp    80158b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801586:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80158b:	89 d0                	mov    %edx,%eax
  80158d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801590:	c9                   	leave  
  801591:	c3                   	ret    

00801592 <seek>:

int
seek(int fdnum, off_t offset)
{
  801592:	55                   	push   %ebp
  801593:	89 e5                	mov    %esp,%ebp
  801595:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801598:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80159b:	50                   	push   %eax
  80159c:	ff 75 08             	pushl  0x8(%ebp)
  80159f:	e8 22 fc ff ff       	call   8011c6 <fd_lookup>
  8015a4:	83 c4 08             	add    $0x8,%esp
  8015a7:	85 c0                	test   %eax,%eax
  8015a9:	78 0e                	js     8015b9 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015b1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015b9:	c9                   	leave  
  8015ba:	c3                   	ret    

008015bb <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015bb:	55                   	push   %ebp
  8015bc:	89 e5                	mov    %esp,%ebp
  8015be:	53                   	push   %ebx
  8015bf:	83 ec 14             	sub    $0x14,%esp
  8015c2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015c5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015c8:	50                   	push   %eax
  8015c9:	53                   	push   %ebx
  8015ca:	e8 f7 fb ff ff       	call   8011c6 <fd_lookup>
  8015cf:	83 c4 08             	add    $0x8,%esp
  8015d2:	89 c2                	mov    %eax,%edx
  8015d4:	85 c0                	test   %eax,%eax
  8015d6:	78 65                	js     80163d <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015d8:	83 ec 08             	sub    $0x8,%esp
  8015db:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015de:	50                   	push   %eax
  8015df:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015e2:	ff 30                	pushl  (%eax)
  8015e4:	e8 33 fc ff ff       	call   80121c <dev_lookup>
  8015e9:	83 c4 10             	add    $0x10,%esp
  8015ec:	85 c0                	test   %eax,%eax
  8015ee:	78 44                	js     801634 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015f3:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015f7:	75 21                	jne    80161a <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015f9:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015fe:	8b 40 48             	mov    0x48(%eax),%eax
  801601:	83 ec 04             	sub    $0x4,%esp
  801604:	53                   	push   %ebx
  801605:	50                   	push   %eax
  801606:	68 ec 2b 80 00       	push   $0x802bec
  80160b:	e8 ff ec ff ff       	call   80030f <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801610:	83 c4 10             	add    $0x10,%esp
  801613:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801618:	eb 23                	jmp    80163d <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80161a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80161d:	8b 52 18             	mov    0x18(%edx),%edx
  801620:	85 d2                	test   %edx,%edx
  801622:	74 14                	je     801638 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801624:	83 ec 08             	sub    $0x8,%esp
  801627:	ff 75 0c             	pushl  0xc(%ebp)
  80162a:	50                   	push   %eax
  80162b:	ff d2                	call   *%edx
  80162d:	89 c2                	mov    %eax,%edx
  80162f:	83 c4 10             	add    $0x10,%esp
  801632:	eb 09                	jmp    80163d <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801634:	89 c2                	mov    %eax,%edx
  801636:	eb 05                	jmp    80163d <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801638:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80163d:	89 d0                	mov    %edx,%eax
  80163f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801642:	c9                   	leave  
  801643:	c3                   	ret    

00801644 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801644:	55                   	push   %ebp
  801645:	89 e5                	mov    %esp,%ebp
  801647:	53                   	push   %ebx
  801648:	83 ec 14             	sub    $0x14,%esp
  80164b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80164e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801651:	50                   	push   %eax
  801652:	ff 75 08             	pushl  0x8(%ebp)
  801655:	e8 6c fb ff ff       	call   8011c6 <fd_lookup>
  80165a:	83 c4 08             	add    $0x8,%esp
  80165d:	89 c2                	mov    %eax,%edx
  80165f:	85 c0                	test   %eax,%eax
  801661:	78 58                	js     8016bb <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801663:	83 ec 08             	sub    $0x8,%esp
  801666:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801669:	50                   	push   %eax
  80166a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80166d:	ff 30                	pushl  (%eax)
  80166f:	e8 a8 fb ff ff       	call   80121c <dev_lookup>
  801674:	83 c4 10             	add    $0x10,%esp
  801677:	85 c0                	test   %eax,%eax
  801679:	78 37                	js     8016b2 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80167b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80167e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801682:	74 32                	je     8016b6 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801684:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801687:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80168e:	00 00 00 
	stat->st_isdir = 0;
  801691:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801698:	00 00 00 
	stat->st_dev = dev;
  80169b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016a1:	83 ec 08             	sub    $0x8,%esp
  8016a4:	53                   	push   %ebx
  8016a5:	ff 75 f0             	pushl  -0x10(%ebp)
  8016a8:	ff 50 14             	call   *0x14(%eax)
  8016ab:	89 c2                	mov    %eax,%edx
  8016ad:	83 c4 10             	add    $0x10,%esp
  8016b0:	eb 09                	jmp    8016bb <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016b2:	89 c2                	mov    %eax,%edx
  8016b4:	eb 05                	jmp    8016bb <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016b6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016bb:	89 d0                	mov    %edx,%eax
  8016bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016c0:	c9                   	leave  
  8016c1:	c3                   	ret    

008016c2 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016c2:	55                   	push   %ebp
  8016c3:	89 e5                	mov    %esp,%ebp
  8016c5:	56                   	push   %esi
  8016c6:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016c7:	83 ec 08             	sub    $0x8,%esp
  8016ca:	6a 00                	push   $0x0
  8016cc:	ff 75 08             	pushl  0x8(%ebp)
  8016cf:	e8 0c 02 00 00       	call   8018e0 <open>
  8016d4:	89 c3                	mov    %eax,%ebx
  8016d6:	83 c4 10             	add    $0x10,%esp
  8016d9:	85 c0                	test   %eax,%eax
  8016db:	78 1b                	js     8016f8 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016dd:	83 ec 08             	sub    $0x8,%esp
  8016e0:	ff 75 0c             	pushl  0xc(%ebp)
  8016e3:	50                   	push   %eax
  8016e4:	e8 5b ff ff ff       	call   801644 <fstat>
  8016e9:	89 c6                	mov    %eax,%esi
	close(fd);
  8016eb:	89 1c 24             	mov    %ebx,(%esp)
  8016ee:	e8 fd fb ff ff       	call   8012f0 <close>
	return r;
  8016f3:	83 c4 10             	add    $0x10,%esp
  8016f6:	89 f0                	mov    %esi,%eax
}
  8016f8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016fb:	5b                   	pop    %ebx
  8016fc:	5e                   	pop    %esi
  8016fd:	5d                   	pop    %ebp
  8016fe:	c3                   	ret    

008016ff <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016ff:	55                   	push   %ebp
  801700:	89 e5                	mov    %esp,%ebp
  801702:	56                   	push   %esi
  801703:	53                   	push   %ebx
  801704:	89 c6                	mov    %eax,%esi
  801706:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801708:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80170f:	75 12                	jne    801723 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801711:	83 ec 0c             	sub    $0xc,%esp
  801714:	6a 01                	push   $0x1
  801716:	e8 e2 0c 00 00       	call   8023fd <ipc_find_env>
  80171b:	a3 00 40 80 00       	mov    %eax,0x804000
  801720:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801723:	6a 07                	push   $0x7
  801725:	68 00 50 80 00       	push   $0x805000
  80172a:	56                   	push   %esi
  80172b:	ff 35 00 40 80 00    	pushl  0x804000
  801731:	e8 73 0c 00 00       	call   8023a9 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801736:	83 c4 0c             	add    $0xc,%esp
  801739:	6a 00                	push   $0x0
  80173b:	53                   	push   %ebx
  80173c:	6a 00                	push   $0x0
  80173e:	e8 fd 0b 00 00       	call   802340 <ipc_recv>
}
  801743:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801746:	5b                   	pop    %ebx
  801747:	5e                   	pop    %esi
  801748:	5d                   	pop    %ebp
  801749:	c3                   	ret    

0080174a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80174a:	55                   	push   %ebp
  80174b:	89 e5                	mov    %esp,%ebp
  80174d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801750:	8b 45 08             	mov    0x8(%ebp),%eax
  801753:	8b 40 0c             	mov    0xc(%eax),%eax
  801756:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80175b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80175e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801763:	ba 00 00 00 00       	mov    $0x0,%edx
  801768:	b8 02 00 00 00       	mov    $0x2,%eax
  80176d:	e8 8d ff ff ff       	call   8016ff <fsipc>
}
  801772:	c9                   	leave  
  801773:	c3                   	ret    

00801774 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801774:	55                   	push   %ebp
  801775:	89 e5                	mov    %esp,%ebp
  801777:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80177a:	8b 45 08             	mov    0x8(%ebp),%eax
  80177d:	8b 40 0c             	mov    0xc(%eax),%eax
  801780:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801785:	ba 00 00 00 00       	mov    $0x0,%edx
  80178a:	b8 06 00 00 00       	mov    $0x6,%eax
  80178f:	e8 6b ff ff ff       	call   8016ff <fsipc>
}
  801794:	c9                   	leave  
  801795:	c3                   	ret    

00801796 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801796:	55                   	push   %ebp
  801797:	89 e5                	mov    %esp,%ebp
  801799:	53                   	push   %ebx
  80179a:	83 ec 04             	sub    $0x4,%esp
  80179d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a3:	8b 40 0c             	mov    0xc(%eax),%eax
  8017a6:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8017b0:	b8 05 00 00 00       	mov    $0x5,%eax
  8017b5:	e8 45 ff ff ff       	call   8016ff <fsipc>
  8017ba:	85 c0                	test   %eax,%eax
  8017bc:	78 2c                	js     8017ea <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017be:	83 ec 08             	sub    $0x8,%esp
  8017c1:	68 00 50 80 00       	push   $0x805000
  8017c6:	53                   	push   %ebx
  8017c7:	e8 c8 f0 ff ff       	call   800894 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017cc:	a1 80 50 80 00       	mov    0x805080,%eax
  8017d1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017d7:	a1 84 50 80 00       	mov    0x805084,%eax
  8017dc:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017e2:	83 c4 10             	add    $0x10,%esp
  8017e5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017ed:	c9                   	leave  
  8017ee:	c3                   	ret    

008017ef <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017ef:	55                   	push   %ebp
  8017f0:	89 e5                	mov    %esp,%ebp
  8017f2:	53                   	push   %ebx
  8017f3:	83 ec 08             	sub    $0x8,%esp
  8017f6:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8017fc:	8b 52 0c             	mov    0xc(%edx),%edx
  8017ff:	89 15 00 50 80 00    	mov    %edx,0x805000
  801805:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80180a:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  80180f:	0f 46 d8             	cmovbe %eax,%ebx
	
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  801812:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  801818:	53                   	push   %ebx
  801819:	ff 75 0c             	pushl  0xc(%ebp)
  80181c:	68 08 50 80 00       	push   $0x805008
  801821:	e8 00 f2 ff ff       	call   800a26 <memmove>

	
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) 
  801826:	ba 00 00 00 00       	mov    $0x0,%edx
  80182b:	b8 04 00 00 00       	mov    $0x4,%eax
  801830:	e8 ca fe ff ff       	call   8016ff <fsipc>
  801835:	83 c4 10             	add    $0x10,%esp
  801838:	85 c0                	test   %eax,%eax
  80183a:	78 1d                	js     801859 <devfile_write+0x6a>
		return r;
	assert(r <= n_real); 
  80183c:	39 d8                	cmp    %ebx,%eax
  80183e:	76 19                	jbe    801859 <devfile_write+0x6a>
  801840:	68 60 2c 80 00       	push   $0x802c60
  801845:	68 6c 2c 80 00       	push   $0x802c6c
  80184a:	68 a3 00 00 00       	push   $0xa3
  80184f:	68 81 2c 80 00       	push   $0x802c81
  801854:	e8 dd e9 ff ff       	call   800236 <_panic>
	return r;
}
  801859:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80185c:	c9                   	leave  
  80185d:	c3                   	ret    

0080185e <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80185e:	55                   	push   %ebp
  80185f:	89 e5                	mov    %esp,%ebp
  801861:	56                   	push   %esi
  801862:	53                   	push   %ebx
  801863:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801866:	8b 45 08             	mov    0x8(%ebp),%eax
  801869:	8b 40 0c             	mov    0xc(%eax),%eax
  80186c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801871:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801877:	ba 00 00 00 00       	mov    $0x0,%edx
  80187c:	b8 03 00 00 00       	mov    $0x3,%eax
  801881:	e8 79 fe ff ff       	call   8016ff <fsipc>
  801886:	89 c3                	mov    %eax,%ebx
  801888:	85 c0                	test   %eax,%eax
  80188a:	78 4b                	js     8018d7 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80188c:	39 c6                	cmp    %eax,%esi
  80188e:	73 16                	jae    8018a6 <devfile_read+0x48>
  801890:	68 8c 2c 80 00       	push   $0x802c8c
  801895:	68 6c 2c 80 00       	push   $0x802c6c
  80189a:	6a 7c                	push   $0x7c
  80189c:	68 81 2c 80 00       	push   $0x802c81
  8018a1:	e8 90 e9 ff ff       	call   800236 <_panic>
	assert(r <= PGSIZE);
  8018a6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018ab:	7e 16                	jle    8018c3 <devfile_read+0x65>
  8018ad:	68 93 2c 80 00       	push   $0x802c93
  8018b2:	68 6c 2c 80 00       	push   $0x802c6c
  8018b7:	6a 7d                	push   $0x7d
  8018b9:	68 81 2c 80 00       	push   $0x802c81
  8018be:	e8 73 e9 ff ff       	call   800236 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018c3:	83 ec 04             	sub    $0x4,%esp
  8018c6:	50                   	push   %eax
  8018c7:	68 00 50 80 00       	push   $0x805000
  8018cc:	ff 75 0c             	pushl  0xc(%ebp)
  8018cf:	e8 52 f1 ff ff       	call   800a26 <memmove>
	return r;
  8018d4:	83 c4 10             	add    $0x10,%esp
}
  8018d7:	89 d8                	mov    %ebx,%eax
  8018d9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018dc:	5b                   	pop    %ebx
  8018dd:	5e                   	pop    %esi
  8018de:	5d                   	pop    %ebp
  8018df:	c3                   	ret    

008018e0 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018e0:	55                   	push   %ebp
  8018e1:	89 e5                	mov    %esp,%ebp
  8018e3:	53                   	push   %ebx
  8018e4:	83 ec 20             	sub    $0x20,%esp
  8018e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018ea:	53                   	push   %ebx
  8018eb:	e8 6b ef ff ff       	call   80085b <strlen>
  8018f0:	83 c4 10             	add    $0x10,%esp
  8018f3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018f8:	7f 67                	jg     801961 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018fa:	83 ec 0c             	sub    $0xc,%esp
  8018fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801900:	50                   	push   %eax
  801901:	e8 71 f8 ff ff       	call   801177 <fd_alloc>
  801906:	83 c4 10             	add    $0x10,%esp
		return r;
  801909:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80190b:	85 c0                	test   %eax,%eax
  80190d:	78 57                	js     801966 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80190f:	83 ec 08             	sub    $0x8,%esp
  801912:	53                   	push   %ebx
  801913:	68 00 50 80 00       	push   $0x805000
  801918:	e8 77 ef ff ff       	call   800894 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80191d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801920:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801925:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801928:	b8 01 00 00 00       	mov    $0x1,%eax
  80192d:	e8 cd fd ff ff       	call   8016ff <fsipc>
  801932:	89 c3                	mov    %eax,%ebx
  801934:	83 c4 10             	add    $0x10,%esp
  801937:	85 c0                	test   %eax,%eax
  801939:	79 14                	jns    80194f <open+0x6f>
		fd_close(fd, 0);
  80193b:	83 ec 08             	sub    $0x8,%esp
  80193e:	6a 00                	push   $0x0
  801940:	ff 75 f4             	pushl  -0xc(%ebp)
  801943:	e8 27 f9 ff ff       	call   80126f <fd_close>
		return r;
  801948:	83 c4 10             	add    $0x10,%esp
  80194b:	89 da                	mov    %ebx,%edx
  80194d:	eb 17                	jmp    801966 <open+0x86>
	}

	return fd2num(fd);
  80194f:	83 ec 0c             	sub    $0xc,%esp
  801952:	ff 75 f4             	pushl  -0xc(%ebp)
  801955:	e8 f6 f7 ff ff       	call   801150 <fd2num>
  80195a:	89 c2                	mov    %eax,%edx
  80195c:	83 c4 10             	add    $0x10,%esp
  80195f:	eb 05                	jmp    801966 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801961:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801966:	89 d0                	mov    %edx,%eax
  801968:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80196b:	c9                   	leave  
  80196c:	c3                   	ret    

0080196d <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80196d:	55                   	push   %ebp
  80196e:	89 e5                	mov    %esp,%ebp
  801970:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801973:	ba 00 00 00 00       	mov    $0x0,%edx
  801978:	b8 08 00 00 00       	mov    $0x8,%eax
  80197d:	e8 7d fd ff ff       	call   8016ff <fsipc>
}
  801982:	c9                   	leave  
  801983:	c3                   	ret    

00801984 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801984:	55                   	push   %ebp
  801985:	89 e5                	mov    %esp,%ebp
  801987:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  80198a:	68 9f 2c 80 00       	push   $0x802c9f
  80198f:	ff 75 0c             	pushl  0xc(%ebp)
  801992:	e8 fd ee ff ff       	call   800894 <strcpy>
	return 0;
}
  801997:	b8 00 00 00 00       	mov    $0x0,%eax
  80199c:	c9                   	leave  
  80199d:	c3                   	ret    

0080199e <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  80199e:	55                   	push   %ebp
  80199f:	89 e5                	mov    %esp,%ebp
  8019a1:	53                   	push   %ebx
  8019a2:	83 ec 10             	sub    $0x10,%esp
  8019a5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8019a8:	53                   	push   %ebx
  8019a9:	e8 88 0a 00 00       	call   802436 <pageref>
  8019ae:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  8019b1:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  8019b6:	83 f8 01             	cmp    $0x1,%eax
  8019b9:	75 10                	jne    8019cb <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  8019bb:	83 ec 0c             	sub    $0xc,%esp
  8019be:	ff 73 0c             	pushl  0xc(%ebx)
  8019c1:	e8 c0 02 00 00       	call   801c86 <nsipc_close>
  8019c6:	89 c2                	mov    %eax,%edx
  8019c8:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8019cb:	89 d0                	mov    %edx,%eax
  8019cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019d0:	c9                   	leave  
  8019d1:	c3                   	ret    

008019d2 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8019d2:	55                   	push   %ebp
  8019d3:	89 e5                	mov    %esp,%ebp
  8019d5:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8019d8:	6a 00                	push   $0x0
  8019da:	ff 75 10             	pushl  0x10(%ebp)
  8019dd:	ff 75 0c             	pushl  0xc(%ebp)
  8019e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e3:	ff 70 0c             	pushl  0xc(%eax)
  8019e6:	e8 78 03 00 00       	call   801d63 <nsipc_send>
}
  8019eb:	c9                   	leave  
  8019ec:	c3                   	ret    

008019ed <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8019ed:	55                   	push   %ebp
  8019ee:	89 e5                	mov    %esp,%ebp
  8019f0:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8019f3:	6a 00                	push   $0x0
  8019f5:	ff 75 10             	pushl  0x10(%ebp)
  8019f8:	ff 75 0c             	pushl  0xc(%ebp)
  8019fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8019fe:	ff 70 0c             	pushl  0xc(%eax)
  801a01:	e8 f1 02 00 00       	call   801cf7 <nsipc_recv>
}
  801a06:	c9                   	leave  
  801a07:	c3                   	ret    

00801a08 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801a08:	55                   	push   %ebp
  801a09:	89 e5                	mov    %esp,%ebp
  801a0b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801a0e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801a11:	52                   	push   %edx
  801a12:	50                   	push   %eax
  801a13:	e8 ae f7 ff ff       	call   8011c6 <fd_lookup>
  801a18:	83 c4 10             	add    $0x10,%esp
  801a1b:	85 c0                	test   %eax,%eax
  801a1d:	78 17                	js     801a36 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801a1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a22:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801a28:	39 08                	cmp    %ecx,(%eax)
  801a2a:	75 05                	jne    801a31 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801a2c:	8b 40 0c             	mov    0xc(%eax),%eax
  801a2f:	eb 05                	jmp    801a36 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801a31:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801a36:	c9                   	leave  
  801a37:	c3                   	ret    

00801a38 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801a38:	55                   	push   %ebp
  801a39:	89 e5                	mov    %esp,%ebp
  801a3b:	56                   	push   %esi
  801a3c:	53                   	push   %ebx
  801a3d:	83 ec 1c             	sub    $0x1c,%esp
  801a40:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801a42:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a45:	50                   	push   %eax
  801a46:	e8 2c f7 ff ff       	call   801177 <fd_alloc>
  801a4b:	89 c3                	mov    %eax,%ebx
  801a4d:	83 c4 10             	add    $0x10,%esp
  801a50:	85 c0                	test   %eax,%eax
  801a52:	78 1b                	js     801a6f <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801a54:	83 ec 04             	sub    $0x4,%esp
  801a57:	68 07 04 00 00       	push   $0x407
  801a5c:	ff 75 f4             	pushl  -0xc(%ebp)
  801a5f:	6a 00                	push   $0x0
  801a61:	e8 31 f2 ff ff       	call   800c97 <sys_page_alloc>
  801a66:	89 c3                	mov    %eax,%ebx
  801a68:	83 c4 10             	add    $0x10,%esp
  801a6b:	85 c0                	test   %eax,%eax
  801a6d:	79 10                	jns    801a7f <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801a6f:	83 ec 0c             	sub    $0xc,%esp
  801a72:	56                   	push   %esi
  801a73:	e8 0e 02 00 00       	call   801c86 <nsipc_close>
		return r;
  801a78:	83 c4 10             	add    $0x10,%esp
  801a7b:	89 d8                	mov    %ebx,%eax
  801a7d:	eb 24                	jmp    801aa3 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801a7f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a85:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a88:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801a8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a8d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801a94:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801a97:	83 ec 0c             	sub    $0xc,%esp
  801a9a:	50                   	push   %eax
  801a9b:	e8 b0 f6 ff ff       	call   801150 <fd2num>
  801aa0:	83 c4 10             	add    $0x10,%esp
}
  801aa3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aa6:	5b                   	pop    %ebx
  801aa7:	5e                   	pop    %esi
  801aa8:	5d                   	pop    %ebp
  801aa9:	c3                   	ret    

00801aaa <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801aaa:	55                   	push   %ebp
  801aab:	89 e5                	mov    %esp,%ebp
  801aad:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ab0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab3:	e8 50 ff ff ff       	call   801a08 <fd2sockid>
		return r;
  801ab8:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801aba:	85 c0                	test   %eax,%eax
  801abc:	78 1f                	js     801add <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801abe:	83 ec 04             	sub    $0x4,%esp
  801ac1:	ff 75 10             	pushl  0x10(%ebp)
  801ac4:	ff 75 0c             	pushl  0xc(%ebp)
  801ac7:	50                   	push   %eax
  801ac8:	e8 12 01 00 00       	call   801bdf <nsipc_accept>
  801acd:	83 c4 10             	add    $0x10,%esp
		return r;
  801ad0:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801ad2:	85 c0                	test   %eax,%eax
  801ad4:	78 07                	js     801add <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801ad6:	e8 5d ff ff ff       	call   801a38 <alloc_sockfd>
  801adb:	89 c1                	mov    %eax,%ecx
}
  801add:	89 c8                	mov    %ecx,%eax
  801adf:	c9                   	leave  
  801ae0:	c3                   	ret    

00801ae1 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801ae1:	55                   	push   %ebp
  801ae2:	89 e5                	mov    %esp,%ebp
  801ae4:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ae7:	8b 45 08             	mov    0x8(%ebp),%eax
  801aea:	e8 19 ff ff ff       	call   801a08 <fd2sockid>
  801aef:	85 c0                	test   %eax,%eax
  801af1:	78 12                	js     801b05 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801af3:	83 ec 04             	sub    $0x4,%esp
  801af6:	ff 75 10             	pushl  0x10(%ebp)
  801af9:	ff 75 0c             	pushl  0xc(%ebp)
  801afc:	50                   	push   %eax
  801afd:	e8 2d 01 00 00       	call   801c2f <nsipc_bind>
  801b02:	83 c4 10             	add    $0x10,%esp
}
  801b05:	c9                   	leave  
  801b06:	c3                   	ret    

00801b07 <shutdown>:

int
shutdown(int s, int how)
{
  801b07:	55                   	push   %ebp
  801b08:	89 e5                	mov    %esp,%ebp
  801b0a:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b0d:	8b 45 08             	mov    0x8(%ebp),%eax
  801b10:	e8 f3 fe ff ff       	call   801a08 <fd2sockid>
  801b15:	85 c0                	test   %eax,%eax
  801b17:	78 0f                	js     801b28 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801b19:	83 ec 08             	sub    $0x8,%esp
  801b1c:	ff 75 0c             	pushl  0xc(%ebp)
  801b1f:	50                   	push   %eax
  801b20:	e8 3f 01 00 00       	call   801c64 <nsipc_shutdown>
  801b25:	83 c4 10             	add    $0x10,%esp
}
  801b28:	c9                   	leave  
  801b29:	c3                   	ret    

00801b2a <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801b2a:	55                   	push   %ebp
  801b2b:	89 e5                	mov    %esp,%ebp
  801b2d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b30:	8b 45 08             	mov    0x8(%ebp),%eax
  801b33:	e8 d0 fe ff ff       	call   801a08 <fd2sockid>
  801b38:	85 c0                	test   %eax,%eax
  801b3a:	78 12                	js     801b4e <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801b3c:	83 ec 04             	sub    $0x4,%esp
  801b3f:	ff 75 10             	pushl  0x10(%ebp)
  801b42:	ff 75 0c             	pushl  0xc(%ebp)
  801b45:	50                   	push   %eax
  801b46:	e8 55 01 00 00       	call   801ca0 <nsipc_connect>
  801b4b:	83 c4 10             	add    $0x10,%esp
}
  801b4e:	c9                   	leave  
  801b4f:	c3                   	ret    

00801b50 <listen>:

int
listen(int s, int backlog)
{
  801b50:	55                   	push   %ebp
  801b51:	89 e5                	mov    %esp,%ebp
  801b53:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b56:	8b 45 08             	mov    0x8(%ebp),%eax
  801b59:	e8 aa fe ff ff       	call   801a08 <fd2sockid>
  801b5e:	85 c0                	test   %eax,%eax
  801b60:	78 0f                	js     801b71 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801b62:	83 ec 08             	sub    $0x8,%esp
  801b65:	ff 75 0c             	pushl  0xc(%ebp)
  801b68:	50                   	push   %eax
  801b69:	e8 67 01 00 00       	call   801cd5 <nsipc_listen>
  801b6e:	83 c4 10             	add    $0x10,%esp
}
  801b71:	c9                   	leave  
  801b72:	c3                   	ret    

00801b73 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801b73:	55                   	push   %ebp
  801b74:	89 e5                	mov    %esp,%ebp
  801b76:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801b79:	ff 75 10             	pushl  0x10(%ebp)
  801b7c:	ff 75 0c             	pushl  0xc(%ebp)
  801b7f:	ff 75 08             	pushl  0x8(%ebp)
  801b82:	e8 3a 02 00 00       	call   801dc1 <nsipc_socket>
  801b87:	83 c4 10             	add    $0x10,%esp
  801b8a:	85 c0                	test   %eax,%eax
  801b8c:	78 05                	js     801b93 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801b8e:	e8 a5 fe ff ff       	call   801a38 <alloc_sockfd>
}
  801b93:	c9                   	leave  
  801b94:	c3                   	ret    

00801b95 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801b95:	55                   	push   %ebp
  801b96:	89 e5                	mov    %esp,%ebp
  801b98:	53                   	push   %ebx
  801b99:	83 ec 04             	sub    $0x4,%esp
  801b9c:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801b9e:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801ba5:	75 12                	jne    801bb9 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801ba7:	83 ec 0c             	sub    $0xc,%esp
  801baa:	6a 02                	push   $0x2
  801bac:	e8 4c 08 00 00       	call   8023fd <ipc_find_env>
  801bb1:	a3 04 40 80 00       	mov    %eax,0x804004
  801bb6:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801bb9:	6a 07                	push   $0x7
  801bbb:	68 00 60 80 00       	push   $0x806000
  801bc0:	53                   	push   %ebx
  801bc1:	ff 35 04 40 80 00    	pushl  0x804004
  801bc7:	e8 dd 07 00 00       	call   8023a9 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801bcc:	83 c4 0c             	add    $0xc,%esp
  801bcf:	6a 00                	push   $0x0
  801bd1:	6a 00                	push   $0x0
  801bd3:	6a 00                	push   $0x0
  801bd5:	e8 66 07 00 00       	call   802340 <ipc_recv>
}
  801bda:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bdd:	c9                   	leave  
  801bde:	c3                   	ret    

00801bdf <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801bdf:	55                   	push   %ebp
  801be0:	89 e5                	mov    %esp,%ebp
  801be2:	56                   	push   %esi
  801be3:	53                   	push   %ebx
  801be4:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801be7:	8b 45 08             	mov    0x8(%ebp),%eax
  801bea:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801bef:	8b 06                	mov    (%esi),%eax
  801bf1:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801bf6:	b8 01 00 00 00       	mov    $0x1,%eax
  801bfb:	e8 95 ff ff ff       	call   801b95 <nsipc>
  801c00:	89 c3                	mov    %eax,%ebx
  801c02:	85 c0                	test   %eax,%eax
  801c04:	78 20                	js     801c26 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801c06:	83 ec 04             	sub    $0x4,%esp
  801c09:	ff 35 10 60 80 00    	pushl  0x806010
  801c0f:	68 00 60 80 00       	push   $0x806000
  801c14:	ff 75 0c             	pushl  0xc(%ebp)
  801c17:	e8 0a ee ff ff       	call   800a26 <memmove>
		*addrlen = ret->ret_addrlen;
  801c1c:	a1 10 60 80 00       	mov    0x806010,%eax
  801c21:	89 06                	mov    %eax,(%esi)
  801c23:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801c26:	89 d8                	mov    %ebx,%eax
  801c28:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c2b:	5b                   	pop    %ebx
  801c2c:	5e                   	pop    %esi
  801c2d:	5d                   	pop    %ebp
  801c2e:	c3                   	ret    

00801c2f <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c2f:	55                   	push   %ebp
  801c30:	89 e5                	mov    %esp,%ebp
  801c32:	53                   	push   %ebx
  801c33:	83 ec 08             	sub    $0x8,%esp
  801c36:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801c39:	8b 45 08             	mov    0x8(%ebp),%eax
  801c3c:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801c41:	53                   	push   %ebx
  801c42:	ff 75 0c             	pushl  0xc(%ebp)
  801c45:	68 04 60 80 00       	push   $0x806004
  801c4a:	e8 d7 ed ff ff       	call   800a26 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801c4f:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801c55:	b8 02 00 00 00       	mov    $0x2,%eax
  801c5a:	e8 36 ff ff ff       	call   801b95 <nsipc>
}
  801c5f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c62:	c9                   	leave  
  801c63:	c3                   	ret    

00801c64 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801c64:	55                   	push   %ebp
  801c65:	89 e5                	mov    %esp,%ebp
  801c67:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801c6a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c6d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801c72:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c75:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801c7a:	b8 03 00 00 00       	mov    $0x3,%eax
  801c7f:	e8 11 ff ff ff       	call   801b95 <nsipc>
}
  801c84:	c9                   	leave  
  801c85:	c3                   	ret    

00801c86 <nsipc_close>:

int
nsipc_close(int s)
{
  801c86:	55                   	push   %ebp
  801c87:	89 e5                	mov    %esp,%ebp
  801c89:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801c8c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c8f:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801c94:	b8 04 00 00 00       	mov    $0x4,%eax
  801c99:	e8 f7 fe ff ff       	call   801b95 <nsipc>
}
  801c9e:	c9                   	leave  
  801c9f:	c3                   	ret    

00801ca0 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801ca0:	55                   	push   %ebp
  801ca1:	89 e5                	mov    %esp,%ebp
  801ca3:	53                   	push   %ebx
  801ca4:	83 ec 08             	sub    $0x8,%esp
  801ca7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801caa:	8b 45 08             	mov    0x8(%ebp),%eax
  801cad:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801cb2:	53                   	push   %ebx
  801cb3:	ff 75 0c             	pushl  0xc(%ebp)
  801cb6:	68 04 60 80 00       	push   $0x806004
  801cbb:	e8 66 ed ff ff       	call   800a26 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801cc0:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801cc6:	b8 05 00 00 00       	mov    $0x5,%eax
  801ccb:	e8 c5 fe ff ff       	call   801b95 <nsipc>
}
  801cd0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cd3:	c9                   	leave  
  801cd4:	c3                   	ret    

00801cd5 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801cd5:	55                   	push   %ebp
  801cd6:	89 e5                	mov    %esp,%ebp
  801cd8:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801cdb:	8b 45 08             	mov    0x8(%ebp),%eax
  801cde:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801ce3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ce6:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801ceb:	b8 06 00 00 00       	mov    $0x6,%eax
  801cf0:	e8 a0 fe ff ff       	call   801b95 <nsipc>
}
  801cf5:	c9                   	leave  
  801cf6:	c3                   	ret    

00801cf7 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801cf7:	55                   	push   %ebp
  801cf8:	89 e5                	mov    %esp,%ebp
  801cfa:	56                   	push   %esi
  801cfb:	53                   	push   %ebx
  801cfc:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801cff:	8b 45 08             	mov    0x8(%ebp),%eax
  801d02:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801d07:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801d0d:	8b 45 14             	mov    0x14(%ebp),%eax
  801d10:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801d15:	b8 07 00 00 00       	mov    $0x7,%eax
  801d1a:	e8 76 fe ff ff       	call   801b95 <nsipc>
  801d1f:	89 c3                	mov    %eax,%ebx
  801d21:	85 c0                	test   %eax,%eax
  801d23:	78 35                	js     801d5a <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801d25:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801d2a:	7f 04                	jg     801d30 <nsipc_recv+0x39>
  801d2c:	39 c6                	cmp    %eax,%esi
  801d2e:	7d 16                	jge    801d46 <nsipc_recv+0x4f>
  801d30:	68 ab 2c 80 00       	push   $0x802cab
  801d35:	68 6c 2c 80 00       	push   $0x802c6c
  801d3a:	6a 62                	push   $0x62
  801d3c:	68 c0 2c 80 00       	push   $0x802cc0
  801d41:	e8 f0 e4 ff ff       	call   800236 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801d46:	83 ec 04             	sub    $0x4,%esp
  801d49:	50                   	push   %eax
  801d4a:	68 00 60 80 00       	push   $0x806000
  801d4f:	ff 75 0c             	pushl  0xc(%ebp)
  801d52:	e8 cf ec ff ff       	call   800a26 <memmove>
  801d57:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801d5a:	89 d8                	mov    %ebx,%eax
  801d5c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d5f:	5b                   	pop    %ebx
  801d60:	5e                   	pop    %esi
  801d61:	5d                   	pop    %ebp
  801d62:	c3                   	ret    

00801d63 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801d63:	55                   	push   %ebp
  801d64:	89 e5                	mov    %esp,%ebp
  801d66:	53                   	push   %ebx
  801d67:	83 ec 04             	sub    $0x4,%esp
  801d6a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801d6d:	8b 45 08             	mov    0x8(%ebp),%eax
  801d70:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801d75:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801d7b:	7e 16                	jle    801d93 <nsipc_send+0x30>
  801d7d:	68 cc 2c 80 00       	push   $0x802ccc
  801d82:	68 6c 2c 80 00       	push   $0x802c6c
  801d87:	6a 6d                	push   $0x6d
  801d89:	68 c0 2c 80 00       	push   $0x802cc0
  801d8e:	e8 a3 e4 ff ff       	call   800236 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801d93:	83 ec 04             	sub    $0x4,%esp
  801d96:	53                   	push   %ebx
  801d97:	ff 75 0c             	pushl  0xc(%ebp)
  801d9a:	68 0c 60 80 00       	push   $0x80600c
  801d9f:	e8 82 ec ff ff       	call   800a26 <memmove>
	nsipcbuf.send.req_size = size;
  801da4:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801daa:	8b 45 14             	mov    0x14(%ebp),%eax
  801dad:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801db2:	b8 08 00 00 00       	mov    $0x8,%eax
  801db7:	e8 d9 fd ff ff       	call   801b95 <nsipc>
}
  801dbc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801dbf:	c9                   	leave  
  801dc0:	c3                   	ret    

00801dc1 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801dc1:	55                   	push   %ebp
  801dc2:	89 e5                	mov    %esp,%ebp
  801dc4:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801dc7:	8b 45 08             	mov    0x8(%ebp),%eax
  801dca:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801dcf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dd2:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801dd7:	8b 45 10             	mov    0x10(%ebp),%eax
  801dda:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801ddf:	b8 09 00 00 00       	mov    $0x9,%eax
  801de4:	e8 ac fd ff ff       	call   801b95 <nsipc>
}
  801de9:	c9                   	leave  
  801dea:	c3                   	ret    

00801deb <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801deb:	55                   	push   %ebp
  801dec:	89 e5                	mov    %esp,%ebp
  801dee:	56                   	push   %esi
  801def:	53                   	push   %ebx
  801df0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801df3:	83 ec 0c             	sub    $0xc,%esp
  801df6:	ff 75 08             	pushl  0x8(%ebp)
  801df9:	e8 62 f3 ff ff       	call   801160 <fd2data>
  801dfe:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801e00:	83 c4 08             	add    $0x8,%esp
  801e03:	68 d8 2c 80 00       	push   $0x802cd8
  801e08:	53                   	push   %ebx
  801e09:	e8 86 ea ff ff       	call   800894 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e0e:	8b 46 04             	mov    0x4(%esi),%eax
  801e11:	2b 06                	sub    (%esi),%eax
  801e13:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801e19:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801e20:	00 00 00 
	stat->st_dev = &devpipe;
  801e23:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801e2a:	30 80 00 
	return 0;
}
  801e2d:	b8 00 00 00 00       	mov    $0x0,%eax
  801e32:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e35:	5b                   	pop    %ebx
  801e36:	5e                   	pop    %esi
  801e37:	5d                   	pop    %ebp
  801e38:	c3                   	ret    

00801e39 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801e39:	55                   	push   %ebp
  801e3a:	89 e5                	mov    %esp,%ebp
  801e3c:	53                   	push   %ebx
  801e3d:	83 ec 0c             	sub    $0xc,%esp
  801e40:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801e43:	53                   	push   %ebx
  801e44:	6a 00                	push   $0x0
  801e46:	e8 d1 ee ff ff       	call   800d1c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801e4b:	89 1c 24             	mov    %ebx,(%esp)
  801e4e:	e8 0d f3 ff ff       	call   801160 <fd2data>
  801e53:	83 c4 08             	add    $0x8,%esp
  801e56:	50                   	push   %eax
  801e57:	6a 00                	push   $0x0
  801e59:	e8 be ee ff ff       	call   800d1c <sys_page_unmap>
}
  801e5e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e61:	c9                   	leave  
  801e62:	c3                   	ret    

00801e63 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801e63:	55                   	push   %ebp
  801e64:	89 e5                	mov    %esp,%ebp
  801e66:	57                   	push   %edi
  801e67:	56                   	push   %esi
  801e68:	53                   	push   %ebx
  801e69:	83 ec 1c             	sub    $0x1c,%esp
  801e6c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801e6f:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801e71:	a1 08 40 80 00       	mov    0x804008,%eax
  801e76:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801e79:	83 ec 0c             	sub    $0xc,%esp
  801e7c:	ff 75 e0             	pushl  -0x20(%ebp)
  801e7f:	e8 b2 05 00 00       	call   802436 <pageref>
  801e84:	89 c3                	mov    %eax,%ebx
  801e86:	89 3c 24             	mov    %edi,(%esp)
  801e89:	e8 a8 05 00 00       	call   802436 <pageref>
  801e8e:	83 c4 10             	add    $0x10,%esp
  801e91:	39 c3                	cmp    %eax,%ebx
  801e93:	0f 94 c1             	sete   %cl
  801e96:	0f b6 c9             	movzbl %cl,%ecx
  801e99:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801e9c:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801ea2:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ea5:	39 ce                	cmp    %ecx,%esi
  801ea7:	74 1b                	je     801ec4 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801ea9:	39 c3                	cmp    %eax,%ebx
  801eab:	75 c4                	jne    801e71 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ead:	8b 42 58             	mov    0x58(%edx),%eax
  801eb0:	ff 75 e4             	pushl  -0x1c(%ebp)
  801eb3:	50                   	push   %eax
  801eb4:	56                   	push   %esi
  801eb5:	68 df 2c 80 00       	push   $0x802cdf
  801eba:	e8 50 e4 ff ff       	call   80030f <cprintf>
  801ebf:	83 c4 10             	add    $0x10,%esp
  801ec2:	eb ad                	jmp    801e71 <_pipeisclosed+0xe>
	}
}
  801ec4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ec7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801eca:	5b                   	pop    %ebx
  801ecb:	5e                   	pop    %esi
  801ecc:	5f                   	pop    %edi
  801ecd:	5d                   	pop    %ebp
  801ece:	c3                   	ret    

00801ecf <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ecf:	55                   	push   %ebp
  801ed0:	89 e5                	mov    %esp,%ebp
  801ed2:	57                   	push   %edi
  801ed3:	56                   	push   %esi
  801ed4:	53                   	push   %ebx
  801ed5:	83 ec 28             	sub    $0x28,%esp
  801ed8:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801edb:	56                   	push   %esi
  801edc:	e8 7f f2 ff ff       	call   801160 <fd2data>
  801ee1:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ee3:	83 c4 10             	add    $0x10,%esp
  801ee6:	bf 00 00 00 00       	mov    $0x0,%edi
  801eeb:	eb 4b                	jmp    801f38 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801eed:	89 da                	mov    %ebx,%edx
  801eef:	89 f0                	mov    %esi,%eax
  801ef1:	e8 6d ff ff ff       	call   801e63 <_pipeisclosed>
  801ef6:	85 c0                	test   %eax,%eax
  801ef8:	75 48                	jne    801f42 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801efa:	e8 79 ed ff ff       	call   800c78 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801eff:	8b 43 04             	mov    0x4(%ebx),%eax
  801f02:	8b 0b                	mov    (%ebx),%ecx
  801f04:	8d 51 20             	lea    0x20(%ecx),%edx
  801f07:	39 d0                	cmp    %edx,%eax
  801f09:	73 e2                	jae    801eed <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f0e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801f12:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801f15:	89 c2                	mov    %eax,%edx
  801f17:	c1 fa 1f             	sar    $0x1f,%edx
  801f1a:	89 d1                	mov    %edx,%ecx
  801f1c:	c1 e9 1b             	shr    $0x1b,%ecx
  801f1f:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801f22:	83 e2 1f             	and    $0x1f,%edx
  801f25:	29 ca                	sub    %ecx,%edx
  801f27:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801f2b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801f2f:	83 c0 01             	add    $0x1,%eax
  801f32:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f35:	83 c7 01             	add    $0x1,%edi
  801f38:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801f3b:	75 c2                	jne    801eff <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801f3d:	8b 45 10             	mov    0x10(%ebp),%eax
  801f40:	eb 05                	jmp    801f47 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f42:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801f47:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f4a:	5b                   	pop    %ebx
  801f4b:	5e                   	pop    %esi
  801f4c:	5f                   	pop    %edi
  801f4d:	5d                   	pop    %ebp
  801f4e:	c3                   	ret    

00801f4f <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f4f:	55                   	push   %ebp
  801f50:	89 e5                	mov    %esp,%ebp
  801f52:	57                   	push   %edi
  801f53:	56                   	push   %esi
  801f54:	53                   	push   %ebx
  801f55:	83 ec 18             	sub    $0x18,%esp
  801f58:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801f5b:	57                   	push   %edi
  801f5c:	e8 ff f1 ff ff       	call   801160 <fd2data>
  801f61:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f63:	83 c4 10             	add    $0x10,%esp
  801f66:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f6b:	eb 3d                	jmp    801faa <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801f6d:	85 db                	test   %ebx,%ebx
  801f6f:	74 04                	je     801f75 <devpipe_read+0x26>
				return i;
  801f71:	89 d8                	mov    %ebx,%eax
  801f73:	eb 44                	jmp    801fb9 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801f75:	89 f2                	mov    %esi,%edx
  801f77:	89 f8                	mov    %edi,%eax
  801f79:	e8 e5 fe ff ff       	call   801e63 <_pipeisclosed>
  801f7e:	85 c0                	test   %eax,%eax
  801f80:	75 32                	jne    801fb4 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801f82:	e8 f1 ec ff ff       	call   800c78 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801f87:	8b 06                	mov    (%esi),%eax
  801f89:	3b 46 04             	cmp    0x4(%esi),%eax
  801f8c:	74 df                	je     801f6d <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801f8e:	99                   	cltd   
  801f8f:	c1 ea 1b             	shr    $0x1b,%edx
  801f92:	01 d0                	add    %edx,%eax
  801f94:	83 e0 1f             	and    $0x1f,%eax
  801f97:	29 d0                	sub    %edx,%eax
  801f99:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801f9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801fa1:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801fa4:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fa7:	83 c3 01             	add    $0x1,%ebx
  801faa:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801fad:	75 d8                	jne    801f87 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801faf:	8b 45 10             	mov    0x10(%ebp),%eax
  801fb2:	eb 05                	jmp    801fb9 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801fb4:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801fb9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fbc:	5b                   	pop    %ebx
  801fbd:	5e                   	pop    %esi
  801fbe:	5f                   	pop    %edi
  801fbf:	5d                   	pop    %ebp
  801fc0:	c3                   	ret    

00801fc1 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801fc1:	55                   	push   %ebp
  801fc2:	89 e5                	mov    %esp,%ebp
  801fc4:	56                   	push   %esi
  801fc5:	53                   	push   %ebx
  801fc6:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801fc9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fcc:	50                   	push   %eax
  801fcd:	e8 a5 f1 ff ff       	call   801177 <fd_alloc>
  801fd2:	83 c4 10             	add    $0x10,%esp
  801fd5:	89 c2                	mov    %eax,%edx
  801fd7:	85 c0                	test   %eax,%eax
  801fd9:	0f 88 2c 01 00 00    	js     80210b <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fdf:	83 ec 04             	sub    $0x4,%esp
  801fe2:	68 07 04 00 00       	push   $0x407
  801fe7:	ff 75 f4             	pushl  -0xc(%ebp)
  801fea:	6a 00                	push   $0x0
  801fec:	e8 a6 ec ff ff       	call   800c97 <sys_page_alloc>
  801ff1:	83 c4 10             	add    $0x10,%esp
  801ff4:	89 c2                	mov    %eax,%edx
  801ff6:	85 c0                	test   %eax,%eax
  801ff8:	0f 88 0d 01 00 00    	js     80210b <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801ffe:	83 ec 0c             	sub    $0xc,%esp
  802001:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802004:	50                   	push   %eax
  802005:	e8 6d f1 ff ff       	call   801177 <fd_alloc>
  80200a:	89 c3                	mov    %eax,%ebx
  80200c:	83 c4 10             	add    $0x10,%esp
  80200f:	85 c0                	test   %eax,%eax
  802011:	0f 88 e2 00 00 00    	js     8020f9 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802017:	83 ec 04             	sub    $0x4,%esp
  80201a:	68 07 04 00 00       	push   $0x407
  80201f:	ff 75 f0             	pushl  -0x10(%ebp)
  802022:	6a 00                	push   $0x0
  802024:	e8 6e ec ff ff       	call   800c97 <sys_page_alloc>
  802029:	89 c3                	mov    %eax,%ebx
  80202b:	83 c4 10             	add    $0x10,%esp
  80202e:	85 c0                	test   %eax,%eax
  802030:	0f 88 c3 00 00 00    	js     8020f9 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802036:	83 ec 0c             	sub    $0xc,%esp
  802039:	ff 75 f4             	pushl  -0xc(%ebp)
  80203c:	e8 1f f1 ff ff       	call   801160 <fd2data>
  802041:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802043:	83 c4 0c             	add    $0xc,%esp
  802046:	68 07 04 00 00       	push   $0x407
  80204b:	50                   	push   %eax
  80204c:	6a 00                	push   $0x0
  80204e:	e8 44 ec ff ff       	call   800c97 <sys_page_alloc>
  802053:	89 c3                	mov    %eax,%ebx
  802055:	83 c4 10             	add    $0x10,%esp
  802058:	85 c0                	test   %eax,%eax
  80205a:	0f 88 89 00 00 00    	js     8020e9 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802060:	83 ec 0c             	sub    $0xc,%esp
  802063:	ff 75 f0             	pushl  -0x10(%ebp)
  802066:	e8 f5 f0 ff ff       	call   801160 <fd2data>
  80206b:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802072:	50                   	push   %eax
  802073:	6a 00                	push   $0x0
  802075:	56                   	push   %esi
  802076:	6a 00                	push   $0x0
  802078:	e8 5d ec ff ff       	call   800cda <sys_page_map>
  80207d:	89 c3                	mov    %eax,%ebx
  80207f:	83 c4 20             	add    $0x20,%esp
  802082:	85 c0                	test   %eax,%eax
  802084:	78 55                	js     8020db <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802086:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80208c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80208f:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802091:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802094:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80209b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020a4:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8020a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020a9:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8020b0:	83 ec 0c             	sub    $0xc,%esp
  8020b3:	ff 75 f4             	pushl  -0xc(%ebp)
  8020b6:	e8 95 f0 ff ff       	call   801150 <fd2num>
  8020bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020be:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8020c0:	83 c4 04             	add    $0x4,%esp
  8020c3:	ff 75 f0             	pushl  -0x10(%ebp)
  8020c6:	e8 85 f0 ff ff       	call   801150 <fd2num>
  8020cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020ce:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8020d1:	83 c4 10             	add    $0x10,%esp
  8020d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8020d9:	eb 30                	jmp    80210b <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8020db:	83 ec 08             	sub    $0x8,%esp
  8020de:	56                   	push   %esi
  8020df:	6a 00                	push   $0x0
  8020e1:	e8 36 ec ff ff       	call   800d1c <sys_page_unmap>
  8020e6:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8020e9:	83 ec 08             	sub    $0x8,%esp
  8020ec:	ff 75 f0             	pushl  -0x10(%ebp)
  8020ef:	6a 00                	push   $0x0
  8020f1:	e8 26 ec ff ff       	call   800d1c <sys_page_unmap>
  8020f6:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8020f9:	83 ec 08             	sub    $0x8,%esp
  8020fc:	ff 75 f4             	pushl  -0xc(%ebp)
  8020ff:	6a 00                	push   $0x0
  802101:	e8 16 ec ff ff       	call   800d1c <sys_page_unmap>
  802106:	83 c4 10             	add    $0x10,%esp
  802109:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80210b:	89 d0                	mov    %edx,%eax
  80210d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802110:	5b                   	pop    %ebx
  802111:	5e                   	pop    %esi
  802112:	5d                   	pop    %ebp
  802113:	c3                   	ret    

00802114 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802114:	55                   	push   %ebp
  802115:	89 e5                	mov    %esp,%ebp
  802117:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80211a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80211d:	50                   	push   %eax
  80211e:	ff 75 08             	pushl  0x8(%ebp)
  802121:	e8 a0 f0 ff ff       	call   8011c6 <fd_lookup>
  802126:	83 c4 10             	add    $0x10,%esp
  802129:	85 c0                	test   %eax,%eax
  80212b:	78 18                	js     802145 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80212d:	83 ec 0c             	sub    $0xc,%esp
  802130:	ff 75 f4             	pushl  -0xc(%ebp)
  802133:	e8 28 f0 ff ff       	call   801160 <fd2data>
	return _pipeisclosed(fd, p);
  802138:	89 c2                	mov    %eax,%edx
  80213a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80213d:	e8 21 fd ff ff       	call   801e63 <_pipeisclosed>
  802142:	83 c4 10             	add    $0x10,%esp
}
  802145:	c9                   	leave  
  802146:	c3                   	ret    

00802147 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802147:	55                   	push   %ebp
  802148:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80214a:	b8 00 00 00 00       	mov    $0x0,%eax
  80214f:	5d                   	pop    %ebp
  802150:	c3                   	ret    

00802151 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802151:	55                   	push   %ebp
  802152:	89 e5                	mov    %esp,%ebp
  802154:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802157:	68 f7 2c 80 00       	push   $0x802cf7
  80215c:	ff 75 0c             	pushl  0xc(%ebp)
  80215f:	e8 30 e7 ff ff       	call   800894 <strcpy>
	return 0;
}
  802164:	b8 00 00 00 00       	mov    $0x0,%eax
  802169:	c9                   	leave  
  80216a:	c3                   	ret    

0080216b <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80216b:	55                   	push   %ebp
  80216c:	89 e5                	mov    %esp,%ebp
  80216e:	57                   	push   %edi
  80216f:	56                   	push   %esi
  802170:	53                   	push   %ebx
  802171:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802177:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80217c:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802182:	eb 2d                	jmp    8021b1 <devcons_write+0x46>
		m = n - tot;
  802184:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802187:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802189:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80218c:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802191:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802194:	83 ec 04             	sub    $0x4,%esp
  802197:	53                   	push   %ebx
  802198:	03 45 0c             	add    0xc(%ebp),%eax
  80219b:	50                   	push   %eax
  80219c:	57                   	push   %edi
  80219d:	e8 84 e8 ff ff       	call   800a26 <memmove>
		sys_cputs(buf, m);
  8021a2:	83 c4 08             	add    $0x8,%esp
  8021a5:	53                   	push   %ebx
  8021a6:	57                   	push   %edi
  8021a7:	e8 2f ea ff ff       	call   800bdb <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021ac:	01 de                	add    %ebx,%esi
  8021ae:	83 c4 10             	add    $0x10,%esp
  8021b1:	89 f0                	mov    %esi,%eax
  8021b3:	3b 75 10             	cmp    0x10(%ebp),%esi
  8021b6:	72 cc                	jb     802184 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8021b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021bb:	5b                   	pop    %ebx
  8021bc:	5e                   	pop    %esi
  8021bd:	5f                   	pop    %edi
  8021be:	5d                   	pop    %ebp
  8021bf:	c3                   	ret    

008021c0 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8021c0:	55                   	push   %ebp
  8021c1:	89 e5                	mov    %esp,%ebp
  8021c3:	83 ec 08             	sub    $0x8,%esp
  8021c6:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8021cb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8021cf:	74 2a                	je     8021fb <devcons_read+0x3b>
  8021d1:	eb 05                	jmp    8021d8 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8021d3:	e8 a0 ea ff ff       	call   800c78 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8021d8:	e8 1c ea ff ff       	call   800bf9 <sys_cgetc>
  8021dd:	85 c0                	test   %eax,%eax
  8021df:	74 f2                	je     8021d3 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8021e1:	85 c0                	test   %eax,%eax
  8021e3:	78 16                	js     8021fb <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8021e5:	83 f8 04             	cmp    $0x4,%eax
  8021e8:	74 0c                	je     8021f6 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8021ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021ed:	88 02                	mov    %al,(%edx)
	return 1;
  8021ef:	b8 01 00 00 00       	mov    $0x1,%eax
  8021f4:	eb 05                	jmp    8021fb <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8021f6:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8021fb:	c9                   	leave  
  8021fc:	c3                   	ret    

008021fd <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8021fd:	55                   	push   %ebp
  8021fe:	89 e5                	mov    %esp,%ebp
  802200:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802203:	8b 45 08             	mov    0x8(%ebp),%eax
  802206:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802209:	6a 01                	push   $0x1
  80220b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80220e:	50                   	push   %eax
  80220f:	e8 c7 e9 ff ff       	call   800bdb <sys_cputs>
}
  802214:	83 c4 10             	add    $0x10,%esp
  802217:	c9                   	leave  
  802218:	c3                   	ret    

00802219 <getchar>:

int
getchar(void)
{
  802219:	55                   	push   %ebp
  80221a:	89 e5                	mov    %esp,%ebp
  80221c:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80221f:	6a 01                	push   $0x1
  802221:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802224:	50                   	push   %eax
  802225:	6a 00                	push   $0x0
  802227:	e8 00 f2 ff ff       	call   80142c <read>
	if (r < 0)
  80222c:	83 c4 10             	add    $0x10,%esp
  80222f:	85 c0                	test   %eax,%eax
  802231:	78 0f                	js     802242 <getchar+0x29>
		return r;
	if (r < 1)
  802233:	85 c0                	test   %eax,%eax
  802235:	7e 06                	jle    80223d <getchar+0x24>
		return -E_EOF;
	return c;
  802237:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80223b:	eb 05                	jmp    802242 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80223d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802242:	c9                   	leave  
  802243:	c3                   	ret    

00802244 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802244:	55                   	push   %ebp
  802245:	89 e5                	mov    %esp,%ebp
  802247:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80224a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80224d:	50                   	push   %eax
  80224e:	ff 75 08             	pushl  0x8(%ebp)
  802251:	e8 70 ef ff ff       	call   8011c6 <fd_lookup>
  802256:	83 c4 10             	add    $0x10,%esp
  802259:	85 c0                	test   %eax,%eax
  80225b:	78 11                	js     80226e <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80225d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802260:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802266:	39 10                	cmp    %edx,(%eax)
  802268:	0f 94 c0             	sete   %al
  80226b:	0f b6 c0             	movzbl %al,%eax
}
  80226e:	c9                   	leave  
  80226f:	c3                   	ret    

00802270 <opencons>:

int
opencons(void)
{
  802270:	55                   	push   %ebp
  802271:	89 e5                	mov    %esp,%ebp
  802273:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802276:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802279:	50                   	push   %eax
  80227a:	e8 f8 ee ff ff       	call   801177 <fd_alloc>
  80227f:	83 c4 10             	add    $0x10,%esp
		return r;
  802282:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802284:	85 c0                	test   %eax,%eax
  802286:	78 3e                	js     8022c6 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802288:	83 ec 04             	sub    $0x4,%esp
  80228b:	68 07 04 00 00       	push   $0x407
  802290:	ff 75 f4             	pushl  -0xc(%ebp)
  802293:	6a 00                	push   $0x0
  802295:	e8 fd e9 ff ff       	call   800c97 <sys_page_alloc>
  80229a:	83 c4 10             	add    $0x10,%esp
		return r;
  80229d:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80229f:	85 c0                	test   %eax,%eax
  8022a1:	78 23                	js     8022c6 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8022a3:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8022a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022ac:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8022ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022b1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8022b8:	83 ec 0c             	sub    $0xc,%esp
  8022bb:	50                   	push   %eax
  8022bc:	e8 8f ee ff ff       	call   801150 <fd2num>
  8022c1:	89 c2                	mov    %eax,%edx
  8022c3:	83 c4 10             	add    $0x10,%esp
}
  8022c6:	89 d0                	mov    %edx,%eax
  8022c8:	c9                   	leave  
  8022c9:	c3                   	ret    

008022ca <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8022ca:	55                   	push   %ebp
  8022cb:	89 e5                	mov    %esp,%ebp
  8022cd:	53                   	push   %ebx
  8022ce:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  8022d1:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8022d8:	75 28                	jne    802302 <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  8022da:	e8 7a e9 ff ff       	call   800c59 <sys_getenvid>
  8022df:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_U | PTE_W);
  8022e1:	83 ec 04             	sub    $0x4,%esp
  8022e4:	6a 06                	push   $0x6
  8022e6:	68 00 f0 bf ee       	push   $0xeebff000
  8022eb:	50                   	push   %eax
  8022ec:	e8 a6 e9 ff ff       	call   800c97 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  8022f1:	83 c4 08             	add    $0x8,%esp
  8022f4:	68 0f 23 80 00       	push   $0x80230f
  8022f9:	53                   	push   %ebx
  8022fa:	e8 e3 ea ff ff       	call   800de2 <sys_env_set_pgfault_upcall>
  8022ff:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802302:	8b 45 08             	mov    0x8(%ebp),%eax
  802305:	a3 00 70 80 00       	mov    %eax,0x807000
}
  80230a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80230d:	c9                   	leave  
  80230e:	c3                   	ret    

0080230f <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80230f:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802310:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802315:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802317:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	# My method is different. Copy the values to the other stack
	# in a convinient way, and then pop everything.
	movl %esp, %ebp		# ebp refers to the exception stack
  80231a:	89 e5                	mov    %esp,%ebp
	movl 48(%ebp), %esp 	# go to other stack
  80231c:	8b 65 30             	mov    0x30(%ebp),%esp

	pushl 40(%ebp)		# eip - ORDER SWITCHED WITH EFLAGS
  80231f:	ff 75 28             	pushl  0x28(%ebp)
	pushl 44(%ebp)      	# eflags
  802322:	ff 75 2c             	pushl  0x2c(%ebp)
	pushl 36(%ebp)		# all the 8 remaining regs
  802325:	ff 75 24             	pushl  0x24(%ebp)
	pushl 32(%ebp)
  802328:	ff 75 20             	pushl  0x20(%ebp)
	pushl 28(%ebp)
  80232b:	ff 75 1c             	pushl  0x1c(%ebp)
	pushl 24(%ebp)
  80232e:	ff 75 18             	pushl  0x18(%ebp)
	pushl 20(%ebp)
  802331:	ff 75 14             	pushl  0x14(%ebp)
	pushl 16(%ebp)
  802334:	ff 75 10             	pushl  0x10(%ebp)
	pushl 12(%ebp)
  802337:	ff 75 0c             	pushl  0xc(%ebp)
	pushl 8(%ebp)
  80233a:	ff 75 08             	pushl  0x8(%ebp)

	popal			# now just pop everything!
  80233d:	61                   	popa   
	popfl
  80233e:	9d                   	popf   
	ret
  80233f:	c3                   	ret    

00802340 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802340:	55                   	push   %ebp
  802341:	89 e5                	mov    %esp,%ebp
  802343:	56                   	push   %esi
  802344:	53                   	push   %ebx
  802345:	8b 75 08             	mov    0x8(%ebp),%esi
  802348:	8b 45 0c             	mov    0xc(%ebp),%eax
  80234b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  80234e:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  802350:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  802355:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  802358:	83 ec 0c             	sub    $0xc,%esp
  80235b:	50                   	push   %eax
  80235c:	e8 e6 ea ff ff       	call   800e47 <sys_ipc_recv>

	if (r < 0) {
  802361:	83 c4 10             	add    $0x10,%esp
  802364:	85 c0                	test   %eax,%eax
  802366:	79 16                	jns    80237e <ipc_recv+0x3e>
		if (from_env_store)
  802368:	85 f6                	test   %esi,%esi
  80236a:	74 06                	je     802372 <ipc_recv+0x32>
			*from_env_store = 0;
  80236c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  802372:	85 db                	test   %ebx,%ebx
  802374:	74 2c                	je     8023a2 <ipc_recv+0x62>
			*perm_store = 0;
  802376:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80237c:	eb 24                	jmp    8023a2 <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  80237e:	85 f6                	test   %esi,%esi
  802380:	74 0a                	je     80238c <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  802382:	a1 08 40 80 00       	mov    0x804008,%eax
  802387:	8b 40 74             	mov    0x74(%eax),%eax
  80238a:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  80238c:	85 db                	test   %ebx,%ebx
  80238e:	74 0a                	je     80239a <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  802390:	a1 08 40 80 00       	mov    0x804008,%eax
  802395:	8b 40 78             	mov    0x78(%eax),%eax
  802398:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  80239a:	a1 08 40 80 00       	mov    0x804008,%eax
  80239f:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  8023a2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8023a5:	5b                   	pop    %ebx
  8023a6:	5e                   	pop    %esi
  8023a7:	5d                   	pop    %ebp
  8023a8:	c3                   	ret    

008023a9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8023a9:	55                   	push   %ebp
  8023aa:	89 e5                	mov    %esp,%ebp
  8023ac:	57                   	push   %edi
  8023ad:	56                   	push   %esi
  8023ae:	53                   	push   %ebx
  8023af:	83 ec 0c             	sub    $0xc,%esp
  8023b2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8023b5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8023b8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  8023bb:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  8023bd:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  8023c2:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  8023c5:	ff 75 14             	pushl  0x14(%ebp)
  8023c8:	53                   	push   %ebx
  8023c9:	56                   	push   %esi
  8023ca:	57                   	push   %edi
  8023cb:	e8 54 ea ff ff       	call   800e24 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  8023d0:	83 c4 10             	add    $0x10,%esp
  8023d3:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8023d6:	75 07                	jne    8023df <ipc_send+0x36>
			sys_yield();
  8023d8:	e8 9b e8 ff ff       	call   800c78 <sys_yield>
  8023dd:	eb e6                	jmp    8023c5 <ipc_send+0x1c>
		} else if (r < 0) {
  8023df:	85 c0                	test   %eax,%eax
  8023e1:	79 12                	jns    8023f5 <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  8023e3:	50                   	push   %eax
  8023e4:	68 03 2d 80 00       	push   $0x802d03
  8023e9:	6a 51                	push   $0x51
  8023eb:	68 10 2d 80 00       	push   $0x802d10
  8023f0:	e8 41 de ff ff       	call   800236 <_panic>
		}
	}
}
  8023f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023f8:	5b                   	pop    %ebx
  8023f9:	5e                   	pop    %esi
  8023fa:	5f                   	pop    %edi
  8023fb:	5d                   	pop    %ebp
  8023fc:	c3                   	ret    

008023fd <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8023fd:	55                   	push   %ebp
  8023fe:	89 e5                	mov    %esp,%ebp
  802400:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802403:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802408:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80240b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802411:	8b 52 50             	mov    0x50(%edx),%edx
  802414:	39 ca                	cmp    %ecx,%edx
  802416:	75 0d                	jne    802425 <ipc_find_env+0x28>
			return envs[i].env_id;
  802418:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80241b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802420:	8b 40 48             	mov    0x48(%eax),%eax
  802423:	eb 0f                	jmp    802434 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802425:	83 c0 01             	add    $0x1,%eax
  802428:	3d 00 04 00 00       	cmp    $0x400,%eax
  80242d:	75 d9                	jne    802408 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80242f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802434:	5d                   	pop    %ebp
  802435:	c3                   	ret    

00802436 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802436:	55                   	push   %ebp
  802437:	89 e5                	mov    %esp,%ebp
  802439:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80243c:	89 d0                	mov    %edx,%eax
  80243e:	c1 e8 16             	shr    $0x16,%eax
  802441:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802448:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80244d:	f6 c1 01             	test   $0x1,%cl
  802450:	74 1d                	je     80246f <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802452:	c1 ea 0c             	shr    $0xc,%edx
  802455:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80245c:	f6 c2 01             	test   $0x1,%dl
  80245f:	74 0e                	je     80246f <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802461:	c1 ea 0c             	shr    $0xc,%edx
  802464:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80246b:	ef 
  80246c:	0f b7 c0             	movzwl %ax,%eax
}
  80246f:	5d                   	pop    %ebp
  802470:	c3                   	ret    
  802471:	66 90                	xchg   %ax,%ax
  802473:	66 90                	xchg   %ax,%ax
  802475:	66 90                	xchg   %ax,%ax
  802477:	66 90                	xchg   %ax,%ax
  802479:	66 90                	xchg   %ax,%ax
  80247b:	66 90                	xchg   %ax,%ax
  80247d:	66 90                	xchg   %ax,%ax
  80247f:	90                   	nop

00802480 <__udivdi3>:
  802480:	55                   	push   %ebp
  802481:	57                   	push   %edi
  802482:	56                   	push   %esi
  802483:	53                   	push   %ebx
  802484:	83 ec 1c             	sub    $0x1c,%esp
  802487:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80248b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80248f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802493:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802497:	85 f6                	test   %esi,%esi
  802499:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80249d:	89 ca                	mov    %ecx,%edx
  80249f:	89 f8                	mov    %edi,%eax
  8024a1:	75 3d                	jne    8024e0 <__udivdi3+0x60>
  8024a3:	39 cf                	cmp    %ecx,%edi
  8024a5:	0f 87 c5 00 00 00    	ja     802570 <__udivdi3+0xf0>
  8024ab:	85 ff                	test   %edi,%edi
  8024ad:	89 fd                	mov    %edi,%ebp
  8024af:	75 0b                	jne    8024bc <__udivdi3+0x3c>
  8024b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8024b6:	31 d2                	xor    %edx,%edx
  8024b8:	f7 f7                	div    %edi
  8024ba:	89 c5                	mov    %eax,%ebp
  8024bc:	89 c8                	mov    %ecx,%eax
  8024be:	31 d2                	xor    %edx,%edx
  8024c0:	f7 f5                	div    %ebp
  8024c2:	89 c1                	mov    %eax,%ecx
  8024c4:	89 d8                	mov    %ebx,%eax
  8024c6:	89 cf                	mov    %ecx,%edi
  8024c8:	f7 f5                	div    %ebp
  8024ca:	89 c3                	mov    %eax,%ebx
  8024cc:	89 d8                	mov    %ebx,%eax
  8024ce:	89 fa                	mov    %edi,%edx
  8024d0:	83 c4 1c             	add    $0x1c,%esp
  8024d3:	5b                   	pop    %ebx
  8024d4:	5e                   	pop    %esi
  8024d5:	5f                   	pop    %edi
  8024d6:	5d                   	pop    %ebp
  8024d7:	c3                   	ret    
  8024d8:	90                   	nop
  8024d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024e0:	39 ce                	cmp    %ecx,%esi
  8024e2:	77 74                	ja     802558 <__udivdi3+0xd8>
  8024e4:	0f bd fe             	bsr    %esi,%edi
  8024e7:	83 f7 1f             	xor    $0x1f,%edi
  8024ea:	0f 84 98 00 00 00    	je     802588 <__udivdi3+0x108>
  8024f0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8024f5:	89 f9                	mov    %edi,%ecx
  8024f7:	89 c5                	mov    %eax,%ebp
  8024f9:	29 fb                	sub    %edi,%ebx
  8024fb:	d3 e6                	shl    %cl,%esi
  8024fd:	89 d9                	mov    %ebx,%ecx
  8024ff:	d3 ed                	shr    %cl,%ebp
  802501:	89 f9                	mov    %edi,%ecx
  802503:	d3 e0                	shl    %cl,%eax
  802505:	09 ee                	or     %ebp,%esi
  802507:	89 d9                	mov    %ebx,%ecx
  802509:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80250d:	89 d5                	mov    %edx,%ebp
  80250f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802513:	d3 ed                	shr    %cl,%ebp
  802515:	89 f9                	mov    %edi,%ecx
  802517:	d3 e2                	shl    %cl,%edx
  802519:	89 d9                	mov    %ebx,%ecx
  80251b:	d3 e8                	shr    %cl,%eax
  80251d:	09 c2                	or     %eax,%edx
  80251f:	89 d0                	mov    %edx,%eax
  802521:	89 ea                	mov    %ebp,%edx
  802523:	f7 f6                	div    %esi
  802525:	89 d5                	mov    %edx,%ebp
  802527:	89 c3                	mov    %eax,%ebx
  802529:	f7 64 24 0c          	mull   0xc(%esp)
  80252d:	39 d5                	cmp    %edx,%ebp
  80252f:	72 10                	jb     802541 <__udivdi3+0xc1>
  802531:	8b 74 24 08          	mov    0x8(%esp),%esi
  802535:	89 f9                	mov    %edi,%ecx
  802537:	d3 e6                	shl    %cl,%esi
  802539:	39 c6                	cmp    %eax,%esi
  80253b:	73 07                	jae    802544 <__udivdi3+0xc4>
  80253d:	39 d5                	cmp    %edx,%ebp
  80253f:	75 03                	jne    802544 <__udivdi3+0xc4>
  802541:	83 eb 01             	sub    $0x1,%ebx
  802544:	31 ff                	xor    %edi,%edi
  802546:	89 d8                	mov    %ebx,%eax
  802548:	89 fa                	mov    %edi,%edx
  80254a:	83 c4 1c             	add    $0x1c,%esp
  80254d:	5b                   	pop    %ebx
  80254e:	5e                   	pop    %esi
  80254f:	5f                   	pop    %edi
  802550:	5d                   	pop    %ebp
  802551:	c3                   	ret    
  802552:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802558:	31 ff                	xor    %edi,%edi
  80255a:	31 db                	xor    %ebx,%ebx
  80255c:	89 d8                	mov    %ebx,%eax
  80255e:	89 fa                	mov    %edi,%edx
  802560:	83 c4 1c             	add    $0x1c,%esp
  802563:	5b                   	pop    %ebx
  802564:	5e                   	pop    %esi
  802565:	5f                   	pop    %edi
  802566:	5d                   	pop    %ebp
  802567:	c3                   	ret    
  802568:	90                   	nop
  802569:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802570:	89 d8                	mov    %ebx,%eax
  802572:	f7 f7                	div    %edi
  802574:	31 ff                	xor    %edi,%edi
  802576:	89 c3                	mov    %eax,%ebx
  802578:	89 d8                	mov    %ebx,%eax
  80257a:	89 fa                	mov    %edi,%edx
  80257c:	83 c4 1c             	add    $0x1c,%esp
  80257f:	5b                   	pop    %ebx
  802580:	5e                   	pop    %esi
  802581:	5f                   	pop    %edi
  802582:	5d                   	pop    %ebp
  802583:	c3                   	ret    
  802584:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802588:	39 ce                	cmp    %ecx,%esi
  80258a:	72 0c                	jb     802598 <__udivdi3+0x118>
  80258c:	31 db                	xor    %ebx,%ebx
  80258e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802592:	0f 87 34 ff ff ff    	ja     8024cc <__udivdi3+0x4c>
  802598:	bb 01 00 00 00       	mov    $0x1,%ebx
  80259d:	e9 2a ff ff ff       	jmp    8024cc <__udivdi3+0x4c>
  8025a2:	66 90                	xchg   %ax,%ax
  8025a4:	66 90                	xchg   %ax,%ax
  8025a6:	66 90                	xchg   %ax,%ax
  8025a8:	66 90                	xchg   %ax,%ax
  8025aa:	66 90                	xchg   %ax,%ax
  8025ac:	66 90                	xchg   %ax,%ax
  8025ae:	66 90                	xchg   %ax,%ax

008025b0 <__umoddi3>:
  8025b0:	55                   	push   %ebp
  8025b1:	57                   	push   %edi
  8025b2:	56                   	push   %esi
  8025b3:	53                   	push   %ebx
  8025b4:	83 ec 1c             	sub    $0x1c,%esp
  8025b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8025bb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8025bf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8025c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8025c7:	85 d2                	test   %edx,%edx
  8025c9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8025cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8025d1:	89 f3                	mov    %esi,%ebx
  8025d3:	89 3c 24             	mov    %edi,(%esp)
  8025d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8025da:	75 1c                	jne    8025f8 <__umoddi3+0x48>
  8025dc:	39 f7                	cmp    %esi,%edi
  8025de:	76 50                	jbe    802630 <__umoddi3+0x80>
  8025e0:	89 c8                	mov    %ecx,%eax
  8025e2:	89 f2                	mov    %esi,%edx
  8025e4:	f7 f7                	div    %edi
  8025e6:	89 d0                	mov    %edx,%eax
  8025e8:	31 d2                	xor    %edx,%edx
  8025ea:	83 c4 1c             	add    $0x1c,%esp
  8025ed:	5b                   	pop    %ebx
  8025ee:	5e                   	pop    %esi
  8025ef:	5f                   	pop    %edi
  8025f0:	5d                   	pop    %ebp
  8025f1:	c3                   	ret    
  8025f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8025f8:	39 f2                	cmp    %esi,%edx
  8025fa:	89 d0                	mov    %edx,%eax
  8025fc:	77 52                	ja     802650 <__umoddi3+0xa0>
  8025fe:	0f bd ea             	bsr    %edx,%ebp
  802601:	83 f5 1f             	xor    $0x1f,%ebp
  802604:	75 5a                	jne    802660 <__umoddi3+0xb0>
  802606:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80260a:	0f 82 e0 00 00 00    	jb     8026f0 <__umoddi3+0x140>
  802610:	39 0c 24             	cmp    %ecx,(%esp)
  802613:	0f 86 d7 00 00 00    	jbe    8026f0 <__umoddi3+0x140>
  802619:	8b 44 24 08          	mov    0x8(%esp),%eax
  80261d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802621:	83 c4 1c             	add    $0x1c,%esp
  802624:	5b                   	pop    %ebx
  802625:	5e                   	pop    %esi
  802626:	5f                   	pop    %edi
  802627:	5d                   	pop    %ebp
  802628:	c3                   	ret    
  802629:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802630:	85 ff                	test   %edi,%edi
  802632:	89 fd                	mov    %edi,%ebp
  802634:	75 0b                	jne    802641 <__umoddi3+0x91>
  802636:	b8 01 00 00 00       	mov    $0x1,%eax
  80263b:	31 d2                	xor    %edx,%edx
  80263d:	f7 f7                	div    %edi
  80263f:	89 c5                	mov    %eax,%ebp
  802641:	89 f0                	mov    %esi,%eax
  802643:	31 d2                	xor    %edx,%edx
  802645:	f7 f5                	div    %ebp
  802647:	89 c8                	mov    %ecx,%eax
  802649:	f7 f5                	div    %ebp
  80264b:	89 d0                	mov    %edx,%eax
  80264d:	eb 99                	jmp    8025e8 <__umoddi3+0x38>
  80264f:	90                   	nop
  802650:	89 c8                	mov    %ecx,%eax
  802652:	89 f2                	mov    %esi,%edx
  802654:	83 c4 1c             	add    $0x1c,%esp
  802657:	5b                   	pop    %ebx
  802658:	5e                   	pop    %esi
  802659:	5f                   	pop    %edi
  80265a:	5d                   	pop    %ebp
  80265b:	c3                   	ret    
  80265c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802660:	8b 34 24             	mov    (%esp),%esi
  802663:	bf 20 00 00 00       	mov    $0x20,%edi
  802668:	89 e9                	mov    %ebp,%ecx
  80266a:	29 ef                	sub    %ebp,%edi
  80266c:	d3 e0                	shl    %cl,%eax
  80266e:	89 f9                	mov    %edi,%ecx
  802670:	89 f2                	mov    %esi,%edx
  802672:	d3 ea                	shr    %cl,%edx
  802674:	89 e9                	mov    %ebp,%ecx
  802676:	09 c2                	or     %eax,%edx
  802678:	89 d8                	mov    %ebx,%eax
  80267a:	89 14 24             	mov    %edx,(%esp)
  80267d:	89 f2                	mov    %esi,%edx
  80267f:	d3 e2                	shl    %cl,%edx
  802681:	89 f9                	mov    %edi,%ecx
  802683:	89 54 24 04          	mov    %edx,0x4(%esp)
  802687:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80268b:	d3 e8                	shr    %cl,%eax
  80268d:	89 e9                	mov    %ebp,%ecx
  80268f:	89 c6                	mov    %eax,%esi
  802691:	d3 e3                	shl    %cl,%ebx
  802693:	89 f9                	mov    %edi,%ecx
  802695:	89 d0                	mov    %edx,%eax
  802697:	d3 e8                	shr    %cl,%eax
  802699:	89 e9                	mov    %ebp,%ecx
  80269b:	09 d8                	or     %ebx,%eax
  80269d:	89 d3                	mov    %edx,%ebx
  80269f:	89 f2                	mov    %esi,%edx
  8026a1:	f7 34 24             	divl   (%esp)
  8026a4:	89 d6                	mov    %edx,%esi
  8026a6:	d3 e3                	shl    %cl,%ebx
  8026a8:	f7 64 24 04          	mull   0x4(%esp)
  8026ac:	39 d6                	cmp    %edx,%esi
  8026ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8026b2:	89 d1                	mov    %edx,%ecx
  8026b4:	89 c3                	mov    %eax,%ebx
  8026b6:	72 08                	jb     8026c0 <__umoddi3+0x110>
  8026b8:	75 11                	jne    8026cb <__umoddi3+0x11b>
  8026ba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8026be:	73 0b                	jae    8026cb <__umoddi3+0x11b>
  8026c0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8026c4:	1b 14 24             	sbb    (%esp),%edx
  8026c7:	89 d1                	mov    %edx,%ecx
  8026c9:	89 c3                	mov    %eax,%ebx
  8026cb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8026cf:	29 da                	sub    %ebx,%edx
  8026d1:	19 ce                	sbb    %ecx,%esi
  8026d3:	89 f9                	mov    %edi,%ecx
  8026d5:	89 f0                	mov    %esi,%eax
  8026d7:	d3 e0                	shl    %cl,%eax
  8026d9:	89 e9                	mov    %ebp,%ecx
  8026db:	d3 ea                	shr    %cl,%edx
  8026dd:	89 e9                	mov    %ebp,%ecx
  8026df:	d3 ee                	shr    %cl,%esi
  8026e1:	09 d0                	or     %edx,%eax
  8026e3:	89 f2                	mov    %esi,%edx
  8026e5:	83 c4 1c             	add    $0x1c,%esp
  8026e8:	5b                   	pop    %ebx
  8026e9:	5e                   	pop    %esi
  8026ea:	5f                   	pop    %edi
  8026eb:	5d                   	pop    %ebp
  8026ec:	c3                   	ret    
  8026ed:	8d 76 00             	lea    0x0(%esi),%esi
  8026f0:	29 f9                	sub    %edi,%ecx
  8026f2:	19 d6                	sbb    %edx,%esi
  8026f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8026f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8026fc:	e9 18 ff ff ff       	jmp    802619 <__umoddi3+0x69>
