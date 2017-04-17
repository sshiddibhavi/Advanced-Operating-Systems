
obj/user/testpiperace.debug:     file format elf32-i386


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
  80002c:	e8 b3 01 00 00       	call   8001e4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 1c             	sub    $0x1c,%esp
	int p[2], r, pid, i, max;
	void *va;
	struct Fd *fd;
	const volatile struct Env *kid;

	cprintf("testing for dup race...\n");
  80003b:	68 20 27 80 00       	push   $0x802720
  800040:	e8 d8 02 00 00       	call   80031d <cprintf>
	if ((r = pipe(p)) < 0)
  800045:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800048:	89 04 24             	mov    %eax,(%esp)
  80004b:	e8 b0 20 00 00       	call   802100 <pipe>
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	85 c0                	test   %eax,%eax
  800055:	79 12                	jns    800069 <umain+0x36>
		panic("pipe: %e", r);
  800057:	50                   	push   %eax
  800058:	68 39 27 80 00       	push   $0x802739
  80005d:	6a 0d                	push   $0xd
  80005f:	68 42 27 80 00       	push   $0x802742
  800064:	e8 db 01 00 00       	call   800244 <_panic>
	max = 200;
	if ((r = fork()) < 0)
  800069:	e8 fb 0f 00 00       	call   801069 <fork>
  80006e:	89 c6                	mov    %eax,%esi
  800070:	85 c0                	test   %eax,%eax
  800072:	79 12                	jns    800086 <umain+0x53>
		panic("fork: %e", r);
  800074:	50                   	push   %eax
  800075:	68 b3 2b 80 00       	push   $0x802bb3
  80007a:	6a 10                	push   $0x10
  80007c:	68 42 27 80 00       	push   $0x802742
  800081:	e8 be 01 00 00       	call   800244 <_panic>
	if (r == 0) {
  800086:	85 c0                	test   %eax,%eax
  800088:	75 55                	jne    8000df <umain+0xac>
		close(p[1]);
  80008a:	83 ec 0c             	sub    $0xc,%esp
  80008d:	ff 75 f4             	pushl  -0xc(%ebp)
  800090:	e8 5f 13 00 00       	call   8013f4 <close>
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	bb c8 00 00 00       	mov    $0xc8,%ebx
		// If a clock interrupt catches dup between mapping the
		// fd and mapping the pipe structure, we'll have the same
		// ref counts, still a no-no.
		//
		for (i=0; i<max; i++) {
			if(pipeisclosed(p[0])){
  80009d:	83 ec 0c             	sub    $0xc,%esp
  8000a0:	ff 75 f0             	pushl  -0x10(%ebp)
  8000a3:	e8 ab 21 00 00       	call   802253 <pipeisclosed>
  8000a8:	83 c4 10             	add    $0x10,%esp
  8000ab:	85 c0                	test   %eax,%eax
  8000ad:	74 15                	je     8000c4 <umain+0x91>
				cprintf("RACE: pipe appears closed\n");
  8000af:	83 ec 0c             	sub    $0xc,%esp
  8000b2:	68 56 27 80 00       	push   $0x802756
  8000b7:	e8 61 02 00 00       	call   80031d <cprintf>
				exit();
  8000bc:	e8 69 01 00 00       	call   80022a <exit>
  8000c1:	83 c4 10             	add    $0x10,%esp
			}
			sys_yield();
  8000c4:	e8 bd 0b 00 00       	call   800c86 <sys_yield>
		//
		// If a clock interrupt catches dup between mapping the
		// fd and mapping the pipe structure, we'll have the same
		// ref counts, still a no-no.
		//
		for (i=0; i<max; i++) {
  8000c9:	83 eb 01             	sub    $0x1,%ebx
  8000cc:	75 cf                	jne    80009d <umain+0x6a>
				exit();
			}
			sys_yield();
		}
		// do something to be not runnable besides exiting
		ipc_recv(0,0,0);
  8000ce:	83 ec 04             	sub    $0x4,%esp
  8000d1:	6a 00                	push   $0x0
  8000d3:	6a 00                	push   $0x0
  8000d5:	6a 00                	push   $0x0
  8000d7:	e8 82 10 00 00       	call   80115e <ipc_recv>
  8000dc:	83 c4 10             	add    $0x10,%esp
	}
	pid = r;
	cprintf("pid is %d\n", pid);
  8000df:	83 ec 08             	sub    $0x8,%esp
  8000e2:	56                   	push   %esi
  8000e3:	68 71 27 80 00       	push   $0x802771
  8000e8:	e8 30 02 00 00       	call   80031d <cprintf>
	va = 0;
	kid = &envs[ENVX(pid)];
  8000ed:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	cprintf("kid is %d\n", kid-envs);
  8000f3:	83 c4 08             	add    $0x8,%esp
  8000f6:	6b c6 7c             	imul   $0x7c,%esi,%eax
  8000f9:	c1 f8 02             	sar    $0x2,%eax
  8000fc:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
  800102:	50                   	push   %eax
  800103:	68 7c 27 80 00       	push   $0x80277c
  800108:	e8 10 02 00 00       	call   80031d <cprintf>
	dup(p[0], 10);
  80010d:	83 c4 08             	add    $0x8,%esp
  800110:	6a 0a                	push   $0xa
  800112:	ff 75 f0             	pushl  -0x10(%ebp)
  800115:	e8 2a 13 00 00       	call   801444 <dup>
	while (kid->env_status == ENV_RUNNABLE)
  80011a:	83 c4 10             	add    $0x10,%esp
  80011d:	6b de 7c             	imul   $0x7c,%esi,%ebx
  800120:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  800126:	eb 10                	jmp    800138 <umain+0x105>
		dup(p[0], 10);
  800128:	83 ec 08             	sub    $0x8,%esp
  80012b:	6a 0a                	push   $0xa
  80012d:	ff 75 f0             	pushl  -0x10(%ebp)
  800130:	e8 0f 13 00 00       	call   801444 <dup>
  800135:	83 c4 10             	add    $0x10,%esp
	cprintf("pid is %d\n", pid);
	va = 0;
	kid = &envs[ENVX(pid)];
	cprintf("kid is %d\n", kid-envs);
	dup(p[0], 10);
	while (kid->env_status == ENV_RUNNABLE)
  800138:	8b 53 54             	mov    0x54(%ebx),%edx
  80013b:	83 fa 02             	cmp    $0x2,%edx
  80013e:	74 e8                	je     800128 <umain+0xf5>
		dup(p[0], 10);

	cprintf("child done with loop\n");
  800140:	83 ec 0c             	sub    $0xc,%esp
  800143:	68 87 27 80 00       	push   $0x802787
  800148:	e8 d0 01 00 00       	call   80031d <cprintf>
	if (pipeisclosed(p[0]))
  80014d:	83 c4 04             	add    $0x4,%esp
  800150:	ff 75 f0             	pushl  -0x10(%ebp)
  800153:	e8 fb 20 00 00       	call   802253 <pipeisclosed>
  800158:	83 c4 10             	add    $0x10,%esp
  80015b:	85 c0                	test   %eax,%eax
  80015d:	74 14                	je     800173 <umain+0x140>
		panic("somehow the other end of p[0] got closed!");
  80015f:	83 ec 04             	sub    $0x4,%esp
  800162:	68 e0 27 80 00       	push   $0x8027e0
  800167:	6a 3a                	push   $0x3a
  800169:	68 42 27 80 00       	push   $0x802742
  80016e:	e8 d1 00 00 00       	call   800244 <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  800173:	83 ec 08             	sub    $0x8,%esp
  800176:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800179:	50                   	push   %eax
  80017a:	ff 75 f0             	pushl  -0x10(%ebp)
  80017d:	e8 48 11 00 00       	call   8012ca <fd_lookup>
  800182:	83 c4 10             	add    $0x10,%esp
  800185:	85 c0                	test   %eax,%eax
  800187:	79 12                	jns    80019b <umain+0x168>
		panic("cannot look up p[0]: %e", r);
  800189:	50                   	push   %eax
  80018a:	68 9d 27 80 00       	push   $0x80279d
  80018f:	6a 3c                	push   $0x3c
  800191:	68 42 27 80 00       	push   $0x802742
  800196:	e8 a9 00 00 00       	call   800244 <_panic>
	va = fd2data(fd);
  80019b:	83 ec 0c             	sub    $0xc,%esp
  80019e:	ff 75 ec             	pushl  -0x14(%ebp)
  8001a1:	e8 be 10 00 00       	call   801264 <fd2data>
	if (pageref(va) != 3+1)
  8001a6:	89 04 24             	mov    %eax,(%esp)
  8001a9:	e8 da 18 00 00       	call   801a88 <pageref>
  8001ae:	83 c4 10             	add    $0x10,%esp
  8001b1:	83 f8 04             	cmp    $0x4,%eax
  8001b4:	74 12                	je     8001c8 <umain+0x195>
		cprintf("\nchild detected race\n");
  8001b6:	83 ec 0c             	sub    $0xc,%esp
  8001b9:	68 b5 27 80 00       	push   $0x8027b5
  8001be:	e8 5a 01 00 00       	call   80031d <cprintf>
  8001c3:	83 c4 10             	add    $0x10,%esp
  8001c6:	eb 15                	jmp    8001dd <umain+0x1aa>
	else
		cprintf("\nrace didn't happen\n", max);
  8001c8:	83 ec 08             	sub    $0x8,%esp
  8001cb:	68 c8 00 00 00       	push   $0xc8
  8001d0:	68 cb 27 80 00       	push   $0x8027cb
  8001d5:	e8 43 01 00 00       	call   80031d <cprintf>
  8001da:	83 c4 10             	add    $0x10,%esp
}
  8001dd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001e0:	5b                   	pop    %ebx
  8001e1:	5e                   	pop    %esi
  8001e2:	5d                   	pop    %ebp
  8001e3:	c3                   	ret    

008001e4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001e4:	55                   	push   %ebp
  8001e5:	89 e5                	mov    %esp,%ebp
  8001e7:	56                   	push   %esi
  8001e8:	53                   	push   %ebx
  8001e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001ec:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8001ef:	e8 73 0a 00 00       	call   800c67 <sys_getenvid>
  8001f4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001f9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001fc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800201:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800206:	85 db                	test   %ebx,%ebx
  800208:	7e 07                	jle    800211 <libmain+0x2d>
		binaryname = argv[0];
  80020a:	8b 06                	mov    (%esi),%eax
  80020c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800211:	83 ec 08             	sub    $0x8,%esp
  800214:	56                   	push   %esi
  800215:	53                   	push   %ebx
  800216:	e8 18 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80021b:	e8 0a 00 00 00       	call   80022a <exit>
}
  800220:	83 c4 10             	add    $0x10,%esp
  800223:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800226:	5b                   	pop    %ebx
  800227:	5e                   	pop    %esi
  800228:	5d                   	pop    %ebp
  800229:	c3                   	ret    

0080022a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80022a:	55                   	push   %ebp
  80022b:	89 e5                	mov    %esp,%ebp
  80022d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800230:	e8 ea 11 00 00       	call   80141f <close_all>
	sys_env_destroy(0);
  800235:	83 ec 0c             	sub    $0xc,%esp
  800238:	6a 00                	push   $0x0
  80023a:	e8 e7 09 00 00       	call   800c26 <sys_env_destroy>
}
  80023f:	83 c4 10             	add    $0x10,%esp
  800242:	c9                   	leave  
  800243:	c3                   	ret    

00800244 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800244:	55                   	push   %ebp
  800245:	89 e5                	mov    %esp,%ebp
  800247:	56                   	push   %esi
  800248:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800249:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80024c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800252:	e8 10 0a 00 00       	call   800c67 <sys_getenvid>
  800257:	83 ec 0c             	sub    $0xc,%esp
  80025a:	ff 75 0c             	pushl  0xc(%ebp)
  80025d:	ff 75 08             	pushl  0x8(%ebp)
  800260:	56                   	push   %esi
  800261:	50                   	push   %eax
  800262:	68 14 28 80 00       	push   $0x802814
  800267:	e8 b1 00 00 00       	call   80031d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80026c:	83 c4 18             	add    $0x18,%esp
  80026f:	53                   	push   %ebx
  800270:	ff 75 10             	pushl  0x10(%ebp)
  800273:	e8 54 00 00 00       	call   8002cc <vcprintf>
	cprintf("\n");
  800278:	c7 04 24 37 27 80 00 	movl   $0x802737,(%esp)
  80027f:	e8 99 00 00 00       	call   80031d <cprintf>
  800284:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800287:	cc                   	int3   
  800288:	eb fd                	jmp    800287 <_panic+0x43>

0080028a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	53                   	push   %ebx
  80028e:	83 ec 04             	sub    $0x4,%esp
  800291:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800294:	8b 13                	mov    (%ebx),%edx
  800296:	8d 42 01             	lea    0x1(%edx),%eax
  800299:	89 03                	mov    %eax,(%ebx)
  80029b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80029e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002a2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002a7:	75 1a                	jne    8002c3 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8002a9:	83 ec 08             	sub    $0x8,%esp
  8002ac:	68 ff 00 00 00       	push   $0xff
  8002b1:	8d 43 08             	lea    0x8(%ebx),%eax
  8002b4:	50                   	push   %eax
  8002b5:	e8 2f 09 00 00       	call   800be9 <sys_cputs>
		b->idx = 0;
  8002ba:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002c0:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002c3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002ca:	c9                   	leave  
  8002cb:	c3                   	ret    

008002cc <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002d5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002dc:	00 00 00 
	b.cnt = 0;
  8002df:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002e6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002e9:	ff 75 0c             	pushl  0xc(%ebp)
  8002ec:	ff 75 08             	pushl  0x8(%ebp)
  8002ef:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002f5:	50                   	push   %eax
  8002f6:	68 8a 02 80 00       	push   $0x80028a
  8002fb:	e8 54 01 00 00       	call   800454 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800300:	83 c4 08             	add    $0x8,%esp
  800303:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800309:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80030f:	50                   	push   %eax
  800310:	e8 d4 08 00 00       	call   800be9 <sys_cputs>

	return b.cnt;
}
  800315:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80031b:	c9                   	leave  
  80031c:	c3                   	ret    

0080031d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80031d:	55                   	push   %ebp
  80031e:	89 e5                	mov    %esp,%ebp
  800320:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800323:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800326:	50                   	push   %eax
  800327:	ff 75 08             	pushl  0x8(%ebp)
  80032a:	e8 9d ff ff ff       	call   8002cc <vcprintf>
	va_end(ap);

	return cnt;
}
  80032f:	c9                   	leave  
  800330:	c3                   	ret    

00800331 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800331:	55                   	push   %ebp
  800332:	89 e5                	mov    %esp,%ebp
  800334:	57                   	push   %edi
  800335:	56                   	push   %esi
  800336:	53                   	push   %ebx
  800337:	83 ec 1c             	sub    $0x1c,%esp
  80033a:	89 c7                	mov    %eax,%edi
  80033c:	89 d6                	mov    %edx,%esi
  80033e:	8b 45 08             	mov    0x8(%ebp),%eax
  800341:	8b 55 0c             	mov    0xc(%ebp),%edx
  800344:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800347:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80034a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80034d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800352:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800355:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800358:	39 d3                	cmp    %edx,%ebx
  80035a:	72 05                	jb     800361 <printnum+0x30>
  80035c:	39 45 10             	cmp    %eax,0x10(%ebp)
  80035f:	77 45                	ja     8003a6 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800361:	83 ec 0c             	sub    $0xc,%esp
  800364:	ff 75 18             	pushl  0x18(%ebp)
  800367:	8b 45 14             	mov    0x14(%ebp),%eax
  80036a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80036d:	53                   	push   %ebx
  80036e:	ff 75 10             	pushl  0x10(%ebp)
  800371:	83 ec 08             	sub    $0x8,%esp
  800374:	ff 75 e4             	pushl  -0x1c(%ebp)
  800377:	ff 75 e0             	pushl  -0x20(%ebp)
  80037a:	ff 75 dc             	pushl  -0x24(%ebp)
  80037d:	ff 75 d8             	pushl  -0x28(%ebp)
  800380:	e8 fb 20 00 00       	call   802480 <__udivdi3>
  800385:	83 c4 18             	add    $0x18,%esp
  800388:	52                   	push   %edx
  800389:	50                   	push   %eax
  80038a:	89 f2                	mov    %esi,%edx
  80038c:	89 f8                	mov    %edi,%eax
  80038e:	e8 9e ff ff ff       	call   800331 <printnum>
  800393:	83 c4 20             	add    $0x20,%esp
  800396:	eb 18                	jmp    8003b0 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800398:	83 ec 08             	sub    $0x8,%esp
  80039b:	56                   	push   %esi
  80039c:	ff 75 18             	pushl  0x18(%ebp)
  80039f:	ff d7                	call   *%edi
  8003a1:	83 c4 10             	add    $0x10,%esp
  8003a4:	eb 03                	jmp    8003a9 <printnum+0x78>
  8003a6:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003a9:	83 eb 01             	sub    $0x1,%ebx
  8003ac:	85 db                	test   %ebx,%ebx
  8003ae:	7f e8                	jg     800398 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003b0:	83 ec 08             	sub    $0x8,%esp
  8003b3:	56                   	push   %esi
  8003b4:	83 ec 04             	sub    $0x4,%esp
  8003b7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003ba:	ff 75 e0             	pushl  -0x20(%ebp)
  8003bd:	ff 75 dc             	pushl  -0x24(%ebp)
  8003c0:	ff 75 d8             	pushl  -0x28(%ebp)
  8003c3:	e8 e8 21 00 00       	call   8025b0 <__umoddi3>
  8003c8:	83 c4 14             	add    $0x14,%esp
  8003cb:	0f be 80 37 28 80 00 	movsbl 0x802837(%eax),%eax
  8003d2:	50                   	push   %eax
  8003d3:	ff d7                	call   *%edi
}
  8003d5:	83 c4 10             	add    $0x10,%esp
  8003d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003db:	5b                   	pop    %ebx
  8003dc:	5e                   	pop    %esi
  8003dd:	5f                   	pop    %edi
  8003de:	5d                   	pop    %ebp
  8003df:	c3                   	ret    

008003e0 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003e0:	55                   	push   %ebp
  8003e1:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003e3:	83 fa 01             	cmp    $0x1,%edx
  8003e6:	7e 0e                	jle    8003f6 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003e8:	8b 10                	mov    (%eax),%edx
  8003ea:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003ed:	89 08                	mov    %ecx,(%eax)
  8003ef:	8b 02                	mov    (%edx),%eax
  8003f1:	8b 52 04             	mov    0x4(%edx),%edx
  8003f4:	eb 22                	jmp    800418 <getuint+0x38>
	else if (lflag)
  8003f6:	85 d2                	test   %edx,%edx
  8003f8:	74 10                	je     80040a <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003fa:	8b 10                	mov    (%eax),%edx
  8003fc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003ff:	89 08                	mov    %ecx,(%eax)
  800401:	8b 02                	mov    (%edx),%eax
  800403:	ba 00 00 00 00       	mov    $0x0,%edx
  800408:	eb 0e                	jmp    800418 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80040a:	8b 10                	mov    (%eax),%edx
  80040c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80040f:	89 08                	mov    %ecx,(%eax)
  800411:	8b 02                	mov    (%edx),%eax
  800413:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800418:	5d                   	pop    %ebp
  800419:	c3                   	ret    

0080041a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80041a:	55                   	push   %ebp
  80041b:	89 e5                	mov    %esp,%ebp
  80041d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800420:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800424:	8b 10                	mov    (%eax),%edx
  800426:	3b 50 04             	cmp    0x4(%eax),%edx
  800429:	73 0a                	jae    800435 <sprintputch+0x1b>
		*b->buf++ = ch;
  80042b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80042e:	89 08                	mov    %ecx,(%eax)
  800430:	8b 45 08             	mov    0x8(%ebp),%eax
  800433:	88 02                	mov    %al,(%edx)
}
  800435:	5d                   	pop    %ebp
  800436:	c3                   	ret    

00800437 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800437:	55                   	push   %ebp
  800438:	89 e5                	mov    %esp,%ebp
  80043a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80043d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800440:	50                   	push   %eax
  800441:	ff 75 10             	pushl  0x10(%ebp)
  800444:	ff 75 0c             	pushl  0xc(%ebp)
  800447:	ff 75 08             	pushl  0x8(%ebp)
  80044a:	e8 05 00 00 00       	call   800454 <vprintfmt>
	va_end(ap);
}
  80044f:	83 c4 10             	add    $0x10,%esp
  800452:	c9                   	leave  
  800453:	c3                   	ret    

00800454 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800454:	55                   	push   %ebp
  800455:	89 e5                	mov    %esp,%ebp
  800457:	57                   	push   %edi
  800458:	56                   	push   %esi
  800459:	53                   	push   %ebx
  80045a:	83 ec 2c             	sub    $0x2c,%esp
  80045d:	8b 75 08             	mov    0x8(%ebp),%esi
  800460:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800463:	8b 7d 10             	mov    0x10(%ebp),%edi
  800466:	eb 12                	jmp    80047a <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800468:	85 c0                	test   %eax,%eax
  80046a:	0f 84 89 03 00 00    	je     8007f9 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800470:	83 ec 08             	sub    $0x8,%esp
  800473:	53                   	push   %ebx
  800474:	50                   	push   %eax
  800475:	ff d6                	call   *%esi
  800477:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80047a:	83 c7 01             	add    $0x1,%edi
  80047d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800481:	83 f8 25             	cmp    $0x25,%eax
  800484:	75 e2                	jne    800468 <vprintfmt+0x14>
  800486:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80048a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800491:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800498:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80049f:	ba 00 00 00 00       	mov    $0x0,%edx
  8004a4:	eb 07                	jmp    8004ad <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004a9:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ad:	8d 47 01             	lea    0x1(%edi),%eax
  8004b0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004b3:	0f b6 07             	movzbl (%edi),%eax
  8004b6:	0f b6 c8             	movzbl %al,%ecx
  8004b9:	83 e8 23             	sub    $0x23,%eax
  8004bc:	3c 55                	cmp    $0x55,%al
  8004be:	0f 87 1a 03 00 00    	ja     8007de <vprintfmt+0x38a>
  8004c4:	0f b6 c0             	movzbl %al,%eax
  8004c7:	ff 24 85 80 29 80 00 	jmp    *0x802980(,%eax,4)
  8004ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004d1:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004d5:	eb d6                	jmp    8004ad <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004da:	b8 00 00 00 00       	mov    $0x0,%eax
  8004df:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004e2:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004e5:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8004e9:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8004ec:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8004ef:	83 fa 09             	cmp    $0x9,%edx
  8004f2:	77 39                	ja     80052d <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004f4:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004f7:	eb e9                	jmp    8004e2 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fc:	8d 48 04             	lea    0x4(%eax),%ecx
  8004ff:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800502:	8b 00                	mov    (%eax),%eax
  800504:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800507:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80050a:	eb 27                	jmp    800533 <vprintfmt+0xdf>
  80050c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80050f:	85 c0                	test   %eax,%eax
  800511:	b9 00 00 00 00       	mov    $0x0,%ecx
  800516:	0f 49 c8             	cmovns %eax,%ecx
  800519:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80051f:	eb 8c                	jmp    8004ad <vprintfmt+0x59>
  800521:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800524:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80052b:	eb 80                	jmp    8004ad <vprintfmt+0x59>
  80052d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800530:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800533:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800537:	0f 89 70 ff ff ff    	jns    8004ad <vprintfmt+0x59>
				width = precision, precision = -1;
  80053d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800540:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800543:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80054a:	e9 5e ff ff ff       	jmp    8004ad <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80054f:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800552:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800555:	e9 53 ff ff ff       	jmp    8004ad <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80055a:	8b 45 14             	mov    0x14(%ebp),%eax
  80055d:	8d 50 04             	lea    0x4(%eax),%edx
  800560:	89 55 14             	mov    %edx,0x14(%ebp)
  800563:	83 ec 08             	sub    $0x8,%esp
  800566:	53                   	push   %ebx
  800567:	ff 30                	pushl  (%eax)
  800569:	ff d6                	call   *%esi
			break;
  80056b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800571:	e9 04 ff ff ff       	jmp    80047a <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800576:	8b 45 14             	mov    0x14(%ebp),%eax
  800579:	8d 50 04             	lea    0x4(%eax),%edx
  80057c:	89 55 14             	mov    %edx,0x14(%ebp)
  80057f:	8b 00                	mov    (%eax),%eax
  800581:	99                   	cltd   
  800582:	31 d0                	xor    %edx,%eax
  800584:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800586:	83 f8 0f             	cmp    $0xf,%eax
  800589:	7f 0b                	jg     800596 <vprintfmt+0x142>
  80058b:	8b 14 85 e0 2a 80 00 	mov    0x802ae0(,%eax,4),%edx
  800592:	85 d2                	test   %edx,%edx
  800594:	75 18                	jne    8005ae <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800596:	50                   	push   %eax
  800597:	68 4f 28 80 00       	push   $0x80284f
  80059c:	53                   	push   %ebx
  80059d:	56                   	push   %esi
  80059e:	e8 94 fe ff ff       	call   800437 <printfmt>
  8005a3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005a9:	e9 cc fe ff ff       	jmp    80047a <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8005ae:	52                   	push   %edx
  8005af:	68 b2 2c 80 00       	push   $0x802cb2
  8005b4:	53                   	push   %ebx
  8005b5:	56                   	push   %esi
  8005b6:	e8 7c fe ff ff       	call   800437 <printfmt>
  8005bb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005c1:	e9 b4 fe ff ff       	jmp    80047a <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c9:	8d 50 04             	lea    0x4(%eax),%edx
  8005cc:	89 55 14             	mov    %edx,0x14(%ebp)
  8005cf:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005d1:	85 ff                	test   %edi,%edi
  8005d3:	b8 48 28 80 00       	mov    $0x802848,%eax
  8005d8:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005db:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005df:	0f 8e 94 00 00 00    	jle    800679 <vprintfmt+0x225>
  8005e5:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005e9:	0f 84 98 00 00 00    	je     800687 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005ef:	83 ec 08             	sub    $0x8,%esp
  8005f2:	ff 75 d0             	pushl  -0x30(%ebp)
  8005f5:	57                   	push   %edi
  8005f6:	e8 86 02 00 00       	call   800881 <strnlen>
  8005fb:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005fe:	29 c1                	sub    %eax,%ecx
  800600:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800603:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800606:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80060a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80060d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800610:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800612:	eb 0f                	jmp    800623 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800614:	83 ec 08             	sub    $0x8,%esp
  800617:	53                   	push   %ebx
  800618:	ff 75 e0             	pushl  -0x20(%ebp)
  80061b:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80061d:	83 ef 01             	sub    $0x1,%edi
  800620:	83 c4 10             	add    $0x10,%esp
  800623:	85 ff                	test   %edi,%edi
  800625:	7f ed                	jg     800614 <vprintfmt+0x1c0>
  800627:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80062a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80062d:	85 c9                	test   %ecx,%ecx
  80062f:	b8 00 00 00 00       	mov    $0x0,%eax
  800634:	0f 49 c1             	cmovns %ecx,%eax
  800637:	29 c1                	sub    %eax,%ecx
  800639:	89 75 08             	mov    %esi,0x8(%ebp)
  80063c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80063f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800642:	89 cb                	mov    %ecx,%ebx
  800644:	eb 4d                	jmp    800693 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800646:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80064a:	74 1b                	je     800667 <vprintfmt+0x213>
  80064c:	0f be c0             	movsbl %al,%eax
  80064f:	83 e8 20             	sub    $0x20,%eax
  800652:	83 f8 5e             	cmp    $0x5e,%eax
  800655:	76 10                	jbe    800667 <vprintfmt+0x213>
					putch('?', putdat);
  800657:	83 ec 08             	sub    $0x8,%esp
  80065a:	ff 75 0c             	pushl  0xc(%ebp)
  80065d:	6a 3f                	push   $0x3f
  80065f:	ff 55 08             	call   *0x8(%ebp)
  800662:	83 c4 10             	add    $0x10,%esp
  800665:	eb 0d                	jmp    800674 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800667:	83 ec 08             	sub    $0x8,%esp
  80066a:	ff 75 0c             	pushl  0xc(%ebp)
  80066d:	52                   	push   %edx
  80066e:	ff 55 08             	call   *0x8(%ebp)
  800671:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800674:	83 eb 01             	sub    $0x1,%ebx
  800677:	eb 1a                	jmp    800693 <vprintfmt+0x23f>
  800679:	89 75 08             	mov    %esi,0x8(%ebp)
  80067c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80067f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800682:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800685:	eb 0c                	jmp    800693 <vprintfmt+0x23f>
  800687:	89 75 08             	mov    %esi,0x8(%ebp)
  80068a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80068d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800690:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800693:	83 c7 01             	add    $0x1,%edi
  800696:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80069a:	0f be d0             	movsbl %al,%edx
  80069d:	85 d2                	test   %edx,%edx
  80069f:	74 23                	je     8006c4 <vprintfmt+0x270>
  8006a1:	85 f6                	test   %esi,%esi
  8006a3:	78 a1                	js     800646 <vprintfmt+0x1f2>
  8006a5:	83 ee 01             	sub    $0x1,%esi
  8006a8:	79 9c                	jns    800646 <vprintfmt+0x1f2>
  8006aa:	89 df                	mov    %ebx,%edi
  8006ac:	8b 75 08             	mov    0x8(%ebp),%esi
  8006af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006b2:	eb 18                	jmp    8006cc <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006b4:	83 ec 08             	sub    $0x8,%esp
  8006b7:	53                   	push   %ebx
  8006b8:	6a 20                	push   $0x20
  8006ba:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006bc:	83 ef 01             	sub    $0x1,%edi
  8006bf:	83 c4 10             	add    $0x10,%esp
  8006c2:	eb 08                	jmp    8006cc <vprintfmt+0x278>
  8006c4:	89 df                	mov    %ebx,%edi
  8006c6:	8b 75 08             	mov    0x8(%ebp),%esi
  8006c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006cc:	85 ff                	test   %edi,%edi
  8006ce:	7f e4                	jg     8006b4 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006d3:	e9 a2 fd ff ff       	jmp    80047a <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006d8:	83 fa 01             	cmp    $0x1,%edx
  8006db:	7e 16                	jle    8006f3 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8006dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e0:	8d 50 08             	lea    0x8(%eax),%edx
  8006e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e6:	8b 50 04             	mov    0x4(%eax),%edx
  8006e9:	8b 00                	mov    (%eax),%eax
  8006eb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006ee:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006f1:	eb 32                	jmp    800725 <vprintfmt+0x2d1>
	else if (lflag)
  8006f3:	85 d2                	test   %edx,%edx
  8006f5:	74 18                	je     80070f <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8006f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fa:	8d 50 04             	lea    0x4(%eax),%edx
  8006fd:	89 55 14             	mov    %edx,0x14(%ebp)
  800700:	8b 00                	mov    (%eax),%eax
  800702:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800705:	89 c1                	mov    %eax,%ecx
  800707:	c1 f9 1f             	sar    $0x1f,%ecx
  80070a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80070d:	eb 16                	jmp    800725 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80070f:	8b 45 14             	mov    0x14(%ebp),%eax
  800712:	8d 50 04             	lea    0x4(%eax),%edx
  800715:	89 55 14             	mov    %edx,0x14(%ebp)
  800718:	8b 00                	mov    (%eax),%eax
  80071a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80071d:	89 c1                	mov    %eax,%ecx
  80071f:	c1 f9 1f             	sar    $0x1f,%ecx
  800722:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800725:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800728:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80072b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800730:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800734:	79 74                	jns    8007aa <vprintfmt+0x356>
				putch('-', putdat);
  800736:	83 ec 08             	sub    $0x8,%esp
  800739:	53                   	push   %ebx
  80073a:	6a 2d                	push   $0x2d
  80073c:	ff d6                	call   *%esi
				num = -(long long) num;
  80073e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800741:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800744:	f7 d8                	neg    %eax
  800746:	83 d2 00             	adc    $0x0,%edx
  800749:	f7 da                	neg    %edx
  80074b:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80074e:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800753:	eb 55                	jmp    8007aa <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800755:	8d 45 14             	lea    0x14(%ebp),%eax
  800758:	e8 83 fc ff ff       	call   8003e0 <getuint>
			base = 10;
  80075d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800762:	eb 46                	jmp    8007aa <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800764:	8d 45 14             	lea    0x14(%ebp),%eax
  800767:	e8 74 fc ff ff       	call   8003e0 <getuint>
                        base = 8;
  80076c:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800771:	eb 37                	jmp    8007aa <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800773:	83 ec 08             	sub    $0x8,%esp
  800776:	53                   	push   %ebx
  800777:	6a 30                	push   $0x30
  800779:	ff d6                	call   *%esi
			putch('x', putdat);
  80077b:	83 c4 08             	add    $0x8,%esp
  80077e:	53                   	push   %ebx
  80077f:	6a 78                	push   $0x78
  800781:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800783:	8b 45 14             	mov    0x14(%ebp),%eax
  800786:	8d 50 04             	lea    0x4(%eax),%edx
  800789:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80078c:	8b 00                	mov    (%eax),%eax
  80078e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800793:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800796:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80079b:	eb 0d                	jmp    8007aa <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80079d:	8d 45 14             	lea    0x14(%ebp),%eax
  8007a0:	e8 3b fc ff ff       	call   8003e0 <getuint>
			base = 16;
  8007a5:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007aa:	83 ec 0c             	sub    $0xc,%esp
  8007ad:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8007b1:	57                   	push   %edi
  8007b2:	ff 75 e0             	pushl  -0x20(%ebp)
  8007b5:	51                   	push   %ecx
  8007b6:	52                   	push   %edx
  8007b7:	50                   	push   %eax
  8007b8:	89 da                	mov    %ebx,%edx
  8007ba:	89 f0                	mov    %esi,%eax
  8007bc:	e8 70 fb ff ff       	call   800331 <printnum>
			break;
  8007c1:	83 c4 20             	add    $0x20,%esp
  8007c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007c7:	e9 ae fc ff ff       	jmp    80047a <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007cc:	83 ec 08             	sub    $0x8,%esp
  8007cf:	53                   	push   %ebx
  8007d0:	51                   	push   %ecx
  8007d1:	ff d6                	call   *%esi
			break;
  8007d3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007d9:	e9 9c fc ff ff       	jmp    80047a <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007de:	83 ec 08             	sub    $0x8,%esp
  8007e1:	53                   	push   %ebx
  8007e2:	6a 25                	push   $0x25
  8007e4:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007e6:	83 c4 10             	add    $0x10,%esp
  8007e9:	eb 03                	jmp    8007ee <vprintfmt+0x39a>
  8007eb:	83 ef 01             	sub    $0x1,%edi
  8007ee:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007f2:	75 f7                	jne    8007eb <vprintfmt+0x397>
  8007f4:	e9 81 fc ff ff       	jmp    80047a <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007fc:	5b                   	pop    %ebx
  8007fd:	5e                   	pop    %esi
  8007fe:	5f                   	pop    %edi
  8007ff:	5d                   	pop    %ebp
  800800:	c3                   	ret    

00800801 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800801:	55                   	push   %ebp
  800802:	89 e5                	mov    %esp,%ebp
  800804:	83 ec 18             	sub    $0x18,%esp
  800807:	8b 45 08             	mov    0x8(%ebp),%eax
  80080a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80080d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800810:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800814:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800817:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80081e:	85 c0                	test   %eax,%eax
  800820:	74 26                	je     800848 <vsnprintf+0x47>
  800822:	85 d2                	test   %edx,%edx
  800824:	7e 22                	jle    800848 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800826:	ff 75 14             	pushl  0x14(%ebp)
  800829:	ff 75 10             	pushl  0x10(%ebp)
  80082c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80082f:	50                   	push   %eax
  800830:	68 1a 04 80 00       	push   $0x80041a
  800835:	e8 1a fc ff ff       	call   800454 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80083a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80083d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800840:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800843:	83 c4 10             	add    $0x10,%esp
  800846:	eb 05                	jmp    80084d <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800848:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80084d:	c9                   	leave  
  80084e:	c3                   	ret    

0080084f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80084f:	55                   	push   %ebp
  800850:	89 e5                	mov    %esp,%ebp
  800852:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800855:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800858:	50                   	push   %eax
  800859:	ff 75 10             	pushl  0x10(%ebp)
  80085c:	ff 75 0c             	pushl  0xc(%ebp)
  80085f:	ff 75 08             	pushl  0x8(%ebp)
  800862:	e8 9a ff ff ff       	call   800801 <vsnprintf>
	va_end(ap);

	return rc;
}
  800867:	c9                   	leave  
  800868:	c3                   	ret    

00800869 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800869:	55                   	push   %ebp
  80086a:	89 e5                	mov    %esp,%ebp
  80086c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80086f:	b8 00 00 00 00       	mov    $0x0,%eax
  800874:	eb 03                	jmp    800879 <strlen+0x10>
		n++;
  800876:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800879:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80087d:	75 f7                	jne    800876 <strlen+0xd>
		n++;
	return n;
}
  80087f:	5d                   	pop    %ebp
  800880:	c3                   	ret    

00800881 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800881:	55                   	push   %ebp
  800882:	89 e5                	mov    %esp,%ebp
  800884:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800887:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80088a:	ba 00 00 00 00       	mov    $0x0,%edx
  80088f:	eb 03                	jmp    800894 <strnlen+0x13>
		n++;
  800891:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800894:	39 c2                	cmp    %eax,%edx
  800896:	74 08                	je     8008a0 <strnlen+0x1f>
  800898:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80089c:	75 f3                	jne    800891 <strnlen+0x10>
  80089e:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8008a0:	5d                   	pop    %ebp
  8008a1:	c3                   	ret    

008008a2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008a2:	55                   	push   %ebp
  8008a3:	89 e5                	mov    %esp,%ebp
  8008a5:	53                   	push   %ebx
  8008a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008ac:	89 c2                	mov    %eax,%edx
  8008ae:	83 c2 01             	add    $0x1,%edx
  8008b1:	83 c1 01             	add    $0x1,%ecx
  8008b4:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008b8:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008bb:	84 db                	test   %bl,%bl
  8008bd:	75 ef                	jne    8008ae <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008bf:	5b                   	pop    %ebx
  8008c0:	5d                   	pop    %ebp
  8008c1:	c3                   	ret    

008008c2 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	53                   	push   %ebx
  8008c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008c9:	53                   	push   %ebx
  8008ca:	e8 9a ff ff ff       	call   800869 <strlen>
  8008cf:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008d2:	ff 75 0c             	pushl  0xc(%ebp)
  8008d5:	01 d8                	add    %ebx,%eax
  8008d7:	50                   	push   %eax
  8008d8:	e8 c5 ff ff ff       	call   8008a2 <strcpy>
	return dst;
}
  8008dd:	89 d8                	mov    %ebx,%eax
  8008df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008e2:	c9                   	leave  
  8008e3:	c3                   	ret    

008008e4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
  8008e7:	56                   	push   %esi
  8008e8:	53                   	push   %ebx
  8008e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008ef:	89 f3                	mov    %esi,%ebx
  8008f1:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008f4:	89 f2                	mov    %esi,%edx
  8008f6:	eb 0f                	jmp    800907 <strncpy+0x23>
		*dst++ = *src;
  8008f8:	83 c2 01             	add    $0x1,%edx
  8008fb:	0f b6 01             	movzbl (%ecx),%eax
  8008fe:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800901:	80 39 01             	cmpb   $0x1,(%ecx)
  800904:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800907:	39 da                	cmp    %ebx,%edx
  800909:	75 ed                	jne    8008f8 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80090b:	89 f0                	mov    %esi,%eax
  80090d:	5b                   	pop    %ebx
  80090e:	5e                   	pop    %esi
  80090f:	5d                   	pop    %ebp
  800910:	c3                   	ret    

00800911 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800911:	55                   	push   %ebp
  800912:	89 e5                	mov    %esp,%ebp
  800914:	56                   	push   %esi
  800915:	53                   	push   %ebx
  800916:	8b 75 08             	mov    0x8(%ebp),%esi
  800919:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80091c:	8b 55 10             	mov    0x10(%ebp),%edx
  80091f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800921:	85 d2                	test   %edx,%edx
  800923:	74 21                	je     800946 <strlcpy+0x35>
  800925:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800929:	89 f2                	mov    %esi,%edx
  80092b:	eb 09                	jmp    800936 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80092d:	83 c2 01             	add    $0x1,%edx
  800930:	83 c1 01             	add    $0x1,%ecx
  800933:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800936:	39 c2                	cmp    %eax,%edx
  800938:	74 09                	je     800943 <strlcpy+0x32>
  80093a:	0f b6 19             	movzbl (%ecx),%ebx
  80093d:	84 db                	test   %bl,%bl
  80093f:	75 ec                	jne    80092d <strlcpy+0x1c>
  800941:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800943:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800946:	29 f0                	sub    %esi,%eax
}
  800948:	5b                   	pop    %ebx
  800949:	5e                   	pop    %esi
  80094a:	5d                   	pop    %ebp
  80094b:	c3                   	ret    

0080094c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80094c:	55                   	push   %ebp
  80094d:	89 e5                	mov    %esp,%ebp
  80094f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800952:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800955:	eb 06                	jmp    80095d <strcmp+0x11>
		p++, q++;
  800957:	83 c1 01             	add    $0x1,%ecx
  80095a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80095d:	0f b6 01             	movzbl (%ecx),%eax
  800960:	84 c0                	test   %al,%al
  800962:	74 04                	je     800968 <strcmp+0x1c>
  800964:	3a 02                	cmp    (%edx),%al
  800966:	74 ef                	je     800957 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800968:	0f b6 c0             	movzbl %al,%eax
  80096b:	0f b6 12             	movzbl (%edx),%edx
  80096e:	29 d0                	sub    %edx,%eax
}
  800970:	5d                   	pop    %ebp
  800971:	c3                   	ret    

00800972 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800972:	55                   	push   %ebp
  800973:	89 e5                	mov    %esp,%ebp
  800975:	53                   	push   %ebx
  800976:	8b 45 08             	mov    0x8(%ebp),%eax
  800979:	8b 55 0c             	mov    0xc(%ebp),%edx
  80097c:	89 c3                	mov    %eax,%ebx
  80097e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800981:	eb 06                	jmp    800989 <strncmp+0x17>
		n--, p++, q++;
  800983:	83 c0 01             	add    $0x1,%eax
  800986:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800989:	39 d8                	cmp    %ebx,%eax
  80098b:	74 15                	je     8009a2 <strncmp+0x30>
  80098d:	0f b6 08             	movzbl (%eax),%ecx
  800990:	84 c9                	test   %cl,%cl
  800992:	74 04                	je     800998 <strncmp+0x26>
  800994:	3a 0a                	cmp    (%edx),%cl
  800996:	74 eb                	je     800983 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800998:	0f b6 00             	movzbl (%eax),%eax
  80099b:	0f b6 12             	movzbl (%edx),%edx
  80099e:	29 d0                	sub    %edx,%eax
  8009a0:	eb 05                	jmp    8009a7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009a2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009a7:	5b                   	pop    %ebx
  8009a8:	5d                   	pop    %ebp
  8009a9:	c3                   	ret    

008009aa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009aa:	55                   	push   %ebp
  8009ab:	89 e5                	mov    %esp,%ebp
  8009ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009b4:	eb 07                	jmp    8009bd <strchr+0x13>
		if (*s == c)
  8009b6:	38 ca                	cmp    %cl,%dl
  8009b8:	74 0f                	je     8009c9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009ba:	83 c0 01             	add    $0x1,%eax
  8009bd:	0f b6 10             	movzbl (%eax),%edx
  8009c0:	84 d2                	test   %dl,%dl
  8009c2:	75 f2                	jne    8009b6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c9:	5d                   	pop    %ebp
  8009ca:	c3                   	ret    

008009cb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009d5:	eb 03                	jmp    8009da <strfind+0xf>
  8009d7:	83 c0 01             	add    $0x1,%eax
  8009da:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009dd:	38 ca                	cmp    %cl,%dl
  8009df:	74 04                	je     8009e5 <strfind+0x1a>
  8009e1:	84 d2                	test   %dl,%dl
  8009e3:	75 f2                	jne    8009d7 <strfind+0xc>
			break;
	return (char *) s;
}
  8009e5:	5d                   	pop    %ebp
  8009e6:	c3                   	ret    

008009e7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009e7:	55                   	push   %ebp
  8009e8:	89 e5                	mov    %esp,%ebp
  8009ea:	57                   	push   %edi
  8009eb:	56                   	push   %esi
  8009ec:	53                   	push   %ebx
  8009ed:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009f0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009f3:	85 c9                	test   %ecx,%ecx
  8009f5:	74 36                	je     800a2d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009f7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009fd:	75 28                	jne    800a27 <memset+0x40>
  8009ff:	f6 c1 03             	test   $0x3,%cl
  800a02:	75 23                	jne    800a27 <memset+0x40>
		c &= 0xFF;
  800a04:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a08:	89 d3                	mov    %edx,%ebx
  800a0a:	c1 e3 08             	shl    $0x8,%ebx
  800a0d:	89 d6                	mov    %edx,%esi
  800a0f:	c1 e6 18             	shl    $0x18,%esi
  800a12:	89 d0                	mov    %edx,%eax
  800a14:	c1 e0 10             	shl    $0x10,%eax
  800a17:	09 f0                	or     %esi,%eax
  800a19:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a1b:	89 d8                	mov    %ebx,%eax
  800a1d:	09 d0                	or     %edx,%eax
  800a1f:	c1 e9 02             	shr    $0x2,%ecx
  800a22:	fc                   	cld    
  800a23:	f3 ab                	rep stos %eax,%es:(%edi)
  800a25:	eb 06                	jmp    800a2d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a27:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a2a:	fc                   	cld    
  800a2b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a2d:	89 f8                	mov    %edi,%eax
  800a2f:	5b                   	pop    %ebx
  800a30:	5e                   	pop    %esi
  800a31:	5f                   	pop    %edi
  800a32:	5d                   	pop    %ebp
  800a33:	c3                   	ret    

00800a34 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a34:	55                   	push   %ebp
  800a35:	89 e5                	mov    %esp,%ebp
  800a37:	57                   	push   %edi
  800a38:	56                   	push   %esi
  800a39:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a3f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a42:	39 c6                	cmp    %eax,%esi
  800a44:	73 35                	jae    800a7b <memmove+0x47>
  800a46:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a49:	39 d0                	cmp    %edx,%eax
  800a4b:	73 2e                	jae    800a7b <memmove+0x47>
		s += n;
		d += n;
  800a4d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a50:	89 d6                	mov    %edx,%esi
  800a52:	09 fe                	or     %edi,%esi
  800a54:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a5a:	75 13                	jne    800a6f <memmove+0x3b>
  800a5c:	f6 c1 03             	test   $0x3,%cl
  800a5f:	75 0e                	jne    800a6f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a61:	83 ef 04             	sub    $0x4,%edi
  800a64:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a67:	c1 e9 02             	shr    $0x2,%ecx
  800a6a:	fd                   	std    
  800a6b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a6d:	eb 09                	jmp    800a78 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a6f:	83 ef 01             	sub    $0x1,%edi
  800a72:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a75:	fd                   	std    
  800a76:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a78:	fc                   	cld    
  800a79:	eb 1d                	jmp    800a98 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a7b:	89 f2                	mov    %esi,%edx
  800a7d:	09 c2                	or     %eax,%edx
  800a7f:	f6 c2 03             	test   $0x3,%dl
  800a82:	75 0f                	jne    800a93 <memmove+0x5f>
  800a84:	f6 c1 03             	test   $0x3,%cl
  800a87:	75 0a                	jne    800a93 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a89:	c1 e9 02             	shr    $0x2,%ecx
  800a8c:	89 c7                	mov    %eax,%edi
  800a8e:	fc                   	cld    
  800a8f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a91:	eb 05                	jmp    800a98 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a93:	89 c7                	mov    %eax,%edi
  800a95:	fc                   	cld    
  800a96:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a98:	5e                   	pop    %esi
  800a99:	5f                   	pop    %edi
  800a9a:	5d                   	pop    %ebp
  800a9b:	c3                   	ret    

00800a9c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a9c:	55                   	push   %ebp
  800a9d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a9f:	ff 75 10             	pushl  0x10(%ebp)
  800aa2:	ff 75 0c             	pushl  0xc(%ebp)
  800aa5:	ff 75 08             	pushl  0x8(%ebp)
  800aa8:	e8 87 ff ff ff       	call   800a34 <memmove>
}
  800aad:	c9                   	leave  
  800aae:	c3                   	ret    

00800aaf <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aaf:	55                   	push   %ebp
  800ab0:	89 e5                	mov    %esp,%ebp
  800ab2:	56                   	push   %esi
  800ab3:	53                   	push   %ebx
  800ab4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aba:	89 c6                	mov    %eax,%esi
  800abc:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800abf:	eb 1a                	jmp    800adb <memcmp+0x2c>
		if (*s1 != *s2)
  800ac1:	0f b6 08             	movzbl (%eax),%ecx
  800ac4:	0f b6 1a             	movzbl (%edx),%ebx
  800ac7:	38 d9                	cmp    %bl,%cl
  800ac9:	74 0a                	je     800ad5 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800acb:	0f b6 c1             	movzbl %cl,%eax
  800ace:	0f b6 db             	movzbl %bl,%ebx
  800ad1:	29 d8                	sub    %ebx,%eax
  800ad3:	eb 0f                	jmp    800ae4 <memcmp+0x35>
		s1++, s2++;
  800ad5:	83 c0 01             	add    $0x1,%eax
  800ad8:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800adb:	39 f0                	cmp    %esi,%eax
  800add:	75 e2                	jne    800ac1 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800adf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ae4:	5b                   	pop    %ebx
  800ae5:	5e                   	pop    %esi
  800ae6:	5d                   	pop    %ebp
  800ae7:	c3                   	ret    

00800ae8 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ae8:	55                   	push   %ebp
  800ae9:	89 e5                	mov    %esp,%ebp
  800aeb:	53                   	push   %ebx
  800aec:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800aef:	89 c1                	mov    %eax,%ecx
  800af1:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800af4:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800af8:	eb 0a                	jmp    800b04 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800afa:	0f b6 10             	movzbl (%eax),%edx
  800afd:	39 da                	cmp    %ebx,%edx
  800aff:	74 07                	je     800b08 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b01:	83 c0 01             	add    $0x1,%eax
  800b04:	39 c8                	cmp    %ecx,%eax
  800b06:	72 f2                	jb     800afa <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b08:	5b                   	pop    %ebx
  800b09:	5d                   	pop    %ebp
  800b0a:	c3                   	ret    

00800b0b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b0b:	55                   	push   %ebp
  800b0c:	89 e5                	mov    %esp,%ebp
  800b0e:	57                   	push   %edi
  800b0f:	56                   	push   %esi
  800b10:	53                   	push   %ebx
  800b11:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b14:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b17:	eb 03                	jmp    800b1c <strtol+0x11>
		s++;
  800b19:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b1c:	0f b6 01             	movzbl (%ecx),%eax
  800b1f:	3c 20                	cmp    $0x20,%al
  800b21:	74 f6                	je     800b19 <strtol+0xe>
  800b23:	3c 09                	cmp    $0x9,%al
  800b25:	74 f2                	je     800b19 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b27:	3c 2b                	cmp    $0x2b,%al
  800b29:	75 0a                	jne    800b35 <strtol+0x2a>
		s++;
  800b2b:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b2e:	bf 00 00 00 00       	mov    $0x0,%edi
  800b33:	eb 11                	jmp    800b46 <strtol+0x3b>
  800b35:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b3a:	3c 2d                	cmp    $0x2d,%al
  800b3c:	75 08                	jne    800b46 <strtol+0x3b>
		s++, neg = 1;
  800b3e:	83 c1 01             	add    $0x1,%ecx
  800b41:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b46:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b4c:	75 15                	jne    800b63 <strtol+0x58>
  800b4e:	80 39 30             	cmpb   $0x30,(%ecx)
  800b51:	75 10                	jne    800b63 <strtol+0x58>
  800b53:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b57:	75 7c                	jne    800bd5 <strtol+0xca>
		s += 2, base = 16;
  800b59:	83 c1 02             	add    $0x2,%ecx
  800b5c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b61:	eb 16                	jmp    800b79 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b63:	85 db                	test   %ebx,%ebx
  800b65:	75 12                	jne    800b79 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b67:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b6c:	80 39 30             	cmpb   $0x30,(%ecx)
  800b6f:	75 08                	jne    800b79 <strtol+0x6e>
		s++, base = 8;
  800b71:	83 c1 01             	add    $0x1,%ecx
  800b74:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b79:	b8 00 00 00 00       	mov    $0x0,%eax
  800b7e:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b81:	0f b6 11             	movzbl (%ecx),%edx
  800b84:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b87:	89 f3                	mov    %esi,%ebx
  800b89:	80 fb 09             	cmp    $0x9,%bl
  800b8c:	77 08                	ja     800b96 <strtol+0x8b>
			dig = *s - '0';
  800b8e:	0f be d2             	movsbl %dl,%edx
  800b91:	83 ea 30             	sub    $0x30,%edx
  800b94:	eb 22                	jmp    800bb8 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b96:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b99:	89 f3                	mov    %esi,%ebx
  800b9b:	80 fb 19             	cmp    $0x19,%bl
  800b9e:	77 08                	ja     800ba8 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ba0:	0f be d2             	movsbl %dl,%edx
  800ba3:	83 ea 57             	sub    $0x57,%edx
  800ba6:	eb 10                	jmp    800bb8 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ba8:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bab:	89 f3                	mov    %esi,%ebx
  800bad:	80 fb 19             	cmp    $0x19,%bl
  800bb0:	77 16                	ja     800bc8 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800bb2:	0f be d2             	movsbl %dl,%edx
  800bb5:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800bb8:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bbb:	7d 0b                	jge    800bc8 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800bbd:	83 c1 01             	add    $0x1,%ecx
  800bc0:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bc4:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800bc6:	eb b9                	jmp    800b81 <strtol+0x76>

	if (endptr)
  800bc8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bcc:	74 0d                	je     800bdb <strtol+0xd0>
		*endptr = (char *) s;
  800bce:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bd1:	89 0e                	mov    %ecx,(%esi)
  800bd3:	eb 06                	jmp    800bdb <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bd5:	85 db                	test   %ebx,%ebx
  800bd7:	74 98                	je     800b71 <strtol+0x66>
  800bd9:	eb 9e                	jmp    800b79 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800bdb:	89 c2                	mov    %eax,%edx
  800bdd:	f7 da                	neg    %edx
  800bdf:	85 ff                	test   %edi,%edi
  800be1:	0f 45 c2             	cmovne %edx,%eax
}
  800be4:	5b                   	pop    %ebx
  800be5:	5e                   	pop    %esi
  800be6:	5f                   	pop    %edi
  800be7:	5d                   	pop    %ebp
  800be8:	c3                   	ret    

00800be9 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800be9:	55                   	push   %ebp
  800bea:	89 e5                	mov    %esp,%ebp
  800bec:	57                   	push   %edi
  800bed:	56                   	push   %esi
  800bee:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bef:	b8 00 00 00 00       	mov    $0x0,%eax
  800bf4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf7:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfa:	89 c3                	mov    %eax,%ebx
  800bfc:	89 c7                	mov    %eax,%edi
  800bfe:	89 c6                	mov    %eax,%esi
  800c00:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c02:	5b                   	pop    %ebx
  800c03:	5e                   	pop    %esi
  800c04:	5f                   	pop    %edi
  800c05:	5d                   	pop    %ebp
  800c06:	c3                   	ret    

00800c07 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c07:	55                   	push   %ebp
  800c08:	89 e5                	mov    %esp,%ebp
  800c0a:	57                   	push   %edi
  800c0b:	56                   	push   %esi
  800c0c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c12:	b8 01 00 00 00       	mov    $0x1,%eax
  800c17:	89 d1                	mov    %edx,%ecx
  800c19:	89 d3                	mov    %edx,%ebx
  800c1b:	89 d7                	mov    %edx,%edi
  800c1d:	89 d6                	mov    %edx,%esi
  800c1f:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c21:	5b                   	pop    %ebx
  800c22:	5e                   	pop    %esi
  800c23:	5f                   	pop    %edi
  800c24:	5d                   	pop    %ebp
  800c25:	c3                   	ret    

00800c26 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c26:	55                   	push   %ebp
  800c27:	89 e5                	mov    %esp,%ebp
  800c29:	57                   	push   %edi
  800c2a:	56                   	push   %esi
  800c2b:	53                   	push   %ebx
  800c2c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c34:	b8 03 00 00 00       	mov    $0x3,%eax
  800c39:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3c:	89 cb                	mov    %ecx,%ebx
  800c3e:	89 cf                	mov    %ecx,%edi
  800c40:	89 ce                	mov    %ecx,%esi
  800c42:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c44:	85 c0                	test   %eax,%eax
  800c46:	7e 17                	jle    800c5f <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c48:	83 ec 0c             	sub    $0xc,%esp
  800c4b:	50                   	push   %eax
  800c4c:	6a 03                	push   $0x3
  800c4e:	68 3f 2b 80 00       	push   $0x802b3f
  800c53:	6a 23                	push   $0x23
  800c55:	68 5c 2b 80 00       	push   $0x802b5c
  800c5a:	e8 e5 f5 ff ff       	call   800244 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c62:	5b                   	pop    %ebx
  800c63:	5e                   	pop    %esi
  800c64:	5f                   	pop    %edi
  800c65:	5d                   	pop    %ebp
  800c66:	c3                   	ret    

00800c67 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c67:	55                   	push   %ebp
  800c68:	89 e5                	mov    %esp,%ebp
  800c6a:	57                   	push   %edi
  800c6b:	56                   	push   %esi
  800c6c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c72:	b8 02 00 00 00       	mov    $0x2,%eax
  800c77:	89 d1                	mov    %edx,%ecx
  800c79:	89 d3                	mov    %edx,%ebx
  800c7b:	89 d7                	mov    %edx,%edi
  800c7d:	89 d6                	mov    %edx,%esi
  800c7f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c81:	5b                   	pop    %ebx
  800c82:	5e                   	pop    %esi
  800c83:	5f                   	pop    %edi
  800c84:	5d                   	pop    %ebp
  800c85:	c3                   	ret    

00800c86 <sys_yield>:

void
sys_yield(void)
{
  800c86:	55                   	push   %ebp
  800c87:	89 e5                	mov    %esp,%ebp
  800c89:	57                   	push   %edi
  800c8a:	56                   	push   %esi
  800c8b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c91:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c96:	89 d1                	mov    %edx,%ecx
  800c98:	89 d3                	mov    %edx,%ebx
  800c9a:	89 d7                	mov    %edx,%edi
  800c9c:	89 d6                	mov    %edx,%esi
  800c9e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ca0:	5b                   	pop    %ebx
  800ca1:	5e                   	pop    %esi
  800ca2:	5f                   	pop    %edi
  800ca3:	5d                   	pop    %ebp
  800ca4:	c3                   	ret    

00800ca5 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ca5:	55                   	push   %ebp
  800ca6:	89 e5                	mov    %esp,%ebp
  800ca8:	57                   	push   %edi
  800ca9:	56                   	push   %esi
  800caa:	53                   	push   %ebx
  800cab:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cae:	be 00 00 00 00       	mov    $0x0,%esi
  800cb3:	b8 04 00 00 00       	mov    $0x4,%eax
  800cb8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbe:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc1:	89 f7                	mov    %esi,%edi
  800cc3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cc5:	85 c0                	test   %eax,%eax
  800cc7:	7e 17                	jle    800ce0 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc9:	83 ec 0c             	sub    $0xc,%esp
  800ccc:	50                   	push   %eax
  800ccd:	6a 04                	push   $0x4
  800ccf:	68 3f 2b 80 00       	push   $0x802b3f
  800cd4:	6a 23                	push   $0x23
  800cd6:	68 5c 2b 80 00       	push   $0x802b5c
  800cdb:	e8 64 f5 ff ff       	call   800244 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ce0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce3:	5b                   	pop    %ebx
  800ce4:	5e                   	pop    %esi
  800ce5:	5f                   	pop    %edi
  800ce6:	5d                   	pop    %ebp
  800ce7:	c3                   	ret    

00800ce8 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ce8:	55                   	push   %ebp
  800ce9:	89 e5                	mov    %esp,%ebp
  800ceb:	57                   	push   %edi
  800cec:	56                   	push   %esi
  800ced:	53                   	push   %ebx
  800cee:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf1:	b8 05 00 00 00       	mov    $0x5,%eax
  800cf6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cff:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d02:	8b 75 18             	mov    0x18(%ebp),%esi
  800d05:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d07:	85 c0                	test   %eax,%eax
  800d09:	7e 17                	jle    800d22 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0b:	83 ec 0c             	sub    $0xc,%esp
  800d0e:	50                   	push   %eax
  800d0f:	6a 05                	push   $0x5
  800d11:	68 3f 2b 80 00       	push   $0x802b3f
  800d16:	6a 23                	push   $0x23
  800d18:	68 5c 2b 80 00       	push   $0x802b5c
  800d1d:	e8 22 f5 ff ff       	call   800244 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d22:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d25:	5b                   	pop    %ebx
  800d26:	5e                   	pop    %esi
  800d27:	5f                   	pop    %edi
  800d28:	5d                   	pop    %ebp
  800d29:	c3                   	ret    

00800d2a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d2a:	55                   	push   %ebp
  800d2b:	89 e5                	mov    %esp,%ebp
  800d2d:	57                   	push   %edi
  800d2e:	56                   	push   %esi
  800d2f:	53                   	push   %ebx
  800d30:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d33:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d38:	b8 06 00 00 00       	mov    $0x6,%eax
  800d3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d40:	8b 55 08             	mov    0x8(%ebp),%edx
  800d43:	89 df                	mov    %ebx,%edi
  800d45:	89 de                	mov    %ebx,%esi
  800d47:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d49:	85 c0                	test   %eax,%eax
  800d4b:	7e 17                	jle    800d64 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4d:	83 ec 0c             	sub    $0xc,%esp
  800d50:	50                   	push   %eax
  800d51:	6a 06                	push   $0x6
  800d53:	68 3f 2b 80 00       	push   $0x802b3f
  800d58:	6a 23                	push   $0x23
  800d5a:	68 5c 2b 80 00       	push   $0x802b5c
  800d5f:	e8 e0 f4 ff ff       	call   800244 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d64:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d67:	5b                   	pop    %ebx
  800d68:	5e                   	pop    %esi
  800d69:	5f                   	pop    %edi
  800d6a:	5d                   	pop    %ebp
  800d6b:	c3                   	ret    

00800d6c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d6c:	55                   	push   %ebp
  800d6d:	89 e5                	mov    %esp,%ebp
  800d6f:	57                   	push   %edi
  800d70:	56                   	push   %esi
  800d71:	53                   	push   %ebx
  800d72:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d75:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d7a:	b8 08 00 00 00       	mov    $0x8,%eax
  800d7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d82:	8b 55 08             	mov    0x8(%ebp),%edx
  800d85:	89 df                	mov    %ebx,%edi
  800d87:	89 de                	mov    %ebx,%esi
  800d89:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d8b:	85 c0                	test   %eax,%eax
  800d8d:	7e 17                	jle    800da6 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8f:	83 ec 0c             	sub    $0xc,%esp
  800d92:	50                   	push   %eax
  800d93:	6a 08                	push   $0x8
  800d95:	68 3f 2b 80 00       	push   $0x802b3f
  800d9a:	6a 23                	push   $0x23
  800d9c:	68 5c 2b 80 00       	push   $0x802b5c
  800da1:	e8 9e f4 ff ff       	call   800244 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800da6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da9:	5b                   	pop    %ebx
  800daa:	5e                   	pop    %esi
  800dab:	5f                   	pop    %edi
  800dac:	5d                   	pop    %ebp
  800dad:	c3                   	ret    

00800dae <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800dae:	55                   	push   %ebp
  800daf:	89 e5                	mov    %esp,%ebp
  800db1:	57                   	push   %edi
  800db2:	56                   	push   %esi
  800db3:	53                   	push   %ebx
  800db4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dbc:	b8 09 00 00 00       	mov    $0x9,%eax
  800dc1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc4:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc7:	89 df                	mov    %ebx,%edi
  800dc9:	89 de                	mov    %ebx,%esi
  800dcb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dcd:	85 c0                	test   %eax,%eax
  800dcf:	7e 17                	jle    800de8 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd1:	83 ec 0c             	sub    $0xc,%esp
  800dd4:	50                   	push   %eax
  800dd5:	6a 09                	push   $0x9
  800dd7:	68 3f 2b 80 00       	push   $0x802b3f
  800ddc:	6a 23                	push   $0x23
  800dde:	68 5c 2b 80 00       	push   $0x802b5c
  800de3:	e8 5c f4 ff ff       	call   800244 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800de8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800deb:	5b                   	pop    %ebx
  800dec:	5e                   	pop    %esi
  800ded:	5f                   	pop    %edi
  800dee:	5d                   	pop    %ebp
  800def:	c3                   	ret    

00800df0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800df0:	55                   	push   %ebp
  800df1:	89 e5                	mov    %esp,%ebp
  800df3:	57                   	push   %edi
  800df4:	56                   	push   %esi
  800df5:	53                   	push   %ebx
  800df6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dfe:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e06:	8b 55 08             	mov    0x8(%ebp),%edx
  800e09:	89 df                	mov    %ebx,%edi
  800e0b:	89 de                	mov    %ebx,%esi
  800e0d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e0f:	85 c0                	test   %eax,%eax
  800e11:	7e 17                	jle    800e2a <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e13:	83 ec 0c             	sub    $0xc,%esp
  800e16:	50                   	push   %eax
  800e17:	6a 0a                	push   $0xa
  800e19:	68 3f 2b 80 00       	push   $0x802b3f
  800e1e:	6a 23                	push   $0x23
  800e20:	68 5c 2b 80 00       	push   $0x802b5c
  800e25:	e8 1a f4 ff ff       	call   800244 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e2d:	5b                   	pop    %ebx
  800e2e:	5e                   	pop    %esi
  800e2f:	5f                   	pop    %edi
  800e30:	5d                   	pop    %ebp
  800e31:	c3                   	ret    

00800e32 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e32:	55                   	push   %ebp
  800e33:	89 e5                	mov    %esp,%ebp
  800e35:	57                   	push   %edi
  800e36:	56                   	push   %esi
  800e37:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e38:	be 00 00 00 00       	mov    $0x0,%esi
  800e3d:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e45:	8b 55 08             	mov    0x8(%ebp),%edx
  800e48:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e4b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e4e:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e50:	5b                   	pop    %ebx
  800e51:	5e                   	pop    %esi
  800e52:	5f                   	pop    %edi
  800e53:	5d                   	pop    %ebp
  800e54:	c3                   	ret    

00800e55 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e55:	55                   	push   %ebp
  800e56:	89 e5                	mov    %esp,%ebp
  800e58:	57                   	push   %edi
  800e59:	56                   	push   %esi
  800e5a:	53                   	push   %ebx
  800e5b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e5e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e63:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e68:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6b:	89 cb                	mov    %ecx,%ebx
  800e6d:	89 cf                	mov    %ecx,%edi
  800e6f:	89 ce                	mov    %ecx,%esi
  800e71:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e73:	85 c0                	test   %eax,%eax
  800e75:	7e 17                	jle    800e8e <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e77:	83 ec 0c             	sub    $0xc,%esp
  800e7a:	50                   	push   %eax
  800e7b:	6a 0d                	push   $0xd
  800e7d:	68 3f 2b 80 00       	push   $0x802b3f
  800e82:	6a 23                	push   $0x23
  800e84:	68 5c 2b 80 00       	push   $0x802b5c
  800e89:	e8 b6 f3 ff ff       	call   800244 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e8e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e91:	5b                   	pop    %ebx
  800e92:	5e                   	pop    %esi
  800e93:	5f                   	pop    %edi
  800e94:	5d                   	pop    %ebp
  800e95:	c3                   	ret    

00800e96 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e96:	55                   	push   %ebp
  800e97:	89 e5                	mov    %esp,%ebp
  800e99:	57                   	push   %edi
  800e9a:	56                   	push   %esi
  800e9b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e9c:	ba 00 00 00 00       	mov    $0x0,%edx
  800ea1:	b8 0e 00 00 00       	mov    $0xe,%eax
  800ea6:	89 d1                	mov    %edx,%ecx
  800ea8:	89 d3                	mov    %edx,%ebx
  800eaa:	89 d7                	mov    %edx,%edi
  800eac:	89 d6                	mov    %edx,%esi
  800eae:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800eb0:	5b                   	pop    %ebx
  800eb1:	5e                   	pop    %esi
  800eb2:	5f                   	pop    %edi
  800eb3:	5d                   	pop    %ebp
  800eb4:	c3                   	ret    

00800eb5 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800eb5:	55                   	push   %ebp
  800eb6:	89 e5                	mov    %esp,%ebp
  800eb8:	53                   	push   %ebx
  800eb9:	83 ec 04             	sub    $0x4,%esp
	int r;
	void * address = (void *)(pn*PGSIZE);
  800ebc:	89 d3                	mov    %edx,%ebx
  800ebe:	c1 e3 0c             	shl    $0xc,%ebx
	
	if((uvpt[pn] & PTE_SHARE))
  800ec1:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800ec8:	f6 c5 04             	test   $0x4,%ch
  800ecb:	74 38                	je     800f05 <duppage+0x50>
	{
		if ((r = sys_page_map(0, address, envid, address, (uvpt[pn] | PTE_SYSCALL))) < 0)
  800ecd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ed4:	83 ec 0c             	sub    $0xc,%esp
  800ed7:	81 ca 07 0e 00 00    	or     $0xe07,%edx
  800edd:	52                   	push   %edx
  800ede:	53                   	push   %ebx
  800edf:	50                   	push   %eax
  800ee0:	53                   	push   %ebx
  800ee1:	6a 00                	push   $0x0
  800ee3:	e8 00 fe ff ff       	call   800ce8 <sys_page_map>
  800ee8:	83 c4 20             	add    $0x20,%esp
  800eeb:	85 c0                	test   %eax,%eax
  800eed:	0f 89 b8 00 00 00    	jns    800fab <duppage+0xf6>
			panic("sys_page_map: %e", r);
  800ef3:	50                   	push   %eax
  800ef4:	68 6a 2b 80 00       	push   $0x802b6a
  800ef9:	6a 4e                	push   $0x4e
  800efb:	68 7b 2b 80 00       	push   $0x802b7b
  800f00:	e8 3f f3 ff ff       	call   800244 <_panic>
	}
	else if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW))
  800f05:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800f0c:	f6 c1 02             	test   $0x2,%cl
  800f0f:	75 0c                	jne    800f1d <duppage+0x68>
  800f11:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800f18:	f6 c5 08             	test   $0x8,%ch
  800f1b:	74 57                	je     800f74 <duppage+0xbf>
	{
		int perm = 0;
		perm |= PTE_P|PTE_U|PTE_COW;
	
		if ((r = sys_page_map(0, address, envid, address, perm)) < 0)
  800f1d:	83 ec 0c             	sub    $0xc,%esp
  800f20:	68 05 08 00 00       	push   $0x805
  800f25:	53                   	push   %ebx
  800f26:	50                   	push   %eax
  800f27:	53                   	push   %ebx
  800f28:	6a 00                	push   $0x0
  800f2a:	e8 b9 fd ff ff       	call   800ce8 <sys_page_map>
  800f2f:	83 c4 20             	add    $0x20,%esp
  800f32:	85 c0                	test   %eax,%eax
  800f34:	79 12                	jns    800f48 <duppage+0x93>
			panic("sys_page_map: %e", r);
  800f36:	50                   	push   %eax
  800f37:	68 6a 2b 80 00       	push   $0x802b6a
  800f3c:	6a 56                	push   $0x56
  800f3e:	68 7b 2b 80 00       	push   $0x802b7b
  800f43:	e8 fc f2 ff ff       	call   800244 <_panic>
		if ((r = sys_page_map(0, address, 0, address, perm)) < 0)
  800f48:	83 ec 0c             	sub    $0xc,%esp
  800f4b:	68 05 08 00 00       	push   $0x805
  800f50:	53                   	push   %ebx
  800f51:	6a 00                	push   $0x0
  800f53:	53                   	push   %ebx
  800f54:	6a 00                	push   $0x0
  800f56:	e8 8d fd ff ff       	call   800ce8 <sys_page_map>
  800f5b:	83 c4 20             	add    $0x20,%esp
  800f5e:	85 c0                	test   %eax,%eax
  800f60:	79 49                	jns    800fab <duppage+0xf6>
			panic("sys_page_map: %e", r);
  800f62:	50                   	push   %eax
  800f63:	68 6a 2b 80 00       	push   $0x802b6a
  800f68:	6a 58                	push   $0x58
  800f6a:	68 7b 2b 80 00       	push   $0x802b7b
  800f6f:	e8 d0 f2 ff ff       	call   800244 <_panic>
	}
	else if((uvpt[pn] & ~PTE_U) == 0)
  800f74:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f7b:	f7 c2 fb ff ff ff    	test   $0xfffffffb,%edx
  800f81:	75 28                	jne    800fab <duppage+0xf6>
	{
		//cprintf("im here");
		if ((r = sys_page_map(0, address, envid, address, PTE_P|PTE_U)) < 0)
  800f83:	83 ec 0c             	sub    $0xc,%esp
  800f86:	6a 05                	push   $0x5
  800f88:	53                   	push   %ebx
  800f89:	50                   	push   %eax
  800f8a:	53                   	push   %ebx
  800f8b:	6a 00                	push   $0x0
  800f8d:	e8 56 fd ff ff       	call   800ce8 <sys_page_map>
  800f92:	83 c4 20             	add    $0x20,%esp
  800f95:	85 c0                	test   %eax,%eax
  800f97:	79 12                	jns    800fab <duppage+0xf6>
			panic("sys_page_map: %e", r);	
  800f99:	50                   	push   %eax
  800f9a:	68 6a 2b 80 00       	push   $0x802b6a
  800f9f:	6a 5e                	push   $0x5e
  800fa1:	68 7b 2b 80 00       	push   $0x802b7b
  800fa6:	e8 99 f2 ff ff       	call   800244 <_panic>
	}
	return 0;
}
  800fab:	b8 00 00 00 00       	mov    $0x0,%eax
  800fb0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fb3:	c9                   	leave  
  800fb4:	c3                   	ret    

00800fb5 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800fb5:	55                   	push   %ebp
  800fb6:	89 e5                	mov    %esp,%ebp
  800fb8:	53                   	push   %ebx
  800fb9:	83 ec 08             	sub    $0x8,%esp
	void *addr = (void *) utf->utf_fault_va;
  800fbc:	8b 45 08             	mov    0x8(%ebp),%eax
  800fbf:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	unsigned pn = ((uint32_t)addr)/PGSIZE;
  800fc1:	89 d8                	mov    %ebx,%eax
  800fc3:	c1 e8 0c             	shr    $0xc,%eax
	pte_t pte = uvpt[pn];
  800fc6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// Allocate a new page, mapped at temp location
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  800fcd:	6a 07                	push   $0x7
  800fcf:	68 00 f0 7f 00       	push   $0x7ff000
  800fd4:	6a 00                	push   $0x0
  800fd6:	e8 ca fc ff ff       	call   800ca5 <sys_page_alloc>
  800fdb:	83 c4 10             	add    $0x10,%esp
  800fde:	85 c0                	test   %eax,%eax
  800fe0:	79 12                	jns    800ff4 <pgfault+0x3f>
		panic("sys_page_alloc: %e", r);
  800fe2:	50                   	push   %eax
  800fe3:	68 86 2b 80 00       	push   $0x802b86
  800fe8:	6a 2b                	push   $0x2b
  800fea:	68 7b 2b 80 00       	push   $0x802b7b
  800fef:	e8 50 f2 ff ff       	call   800244 <_panic>

	// Copy the data from the old page to this new page
	void *addr_pgstart = (void *) ROUNDDOWN(addr, PGSIZE);
  800ff4:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr_pgstart, PGSIZE);
  800ffa:	83 ec 04             	sub    $0x4,%esp
  800ffd:	68 00 10 00 00       	push   $0x1000
  801002:	53                   	push   %ebx
  801003:	68 00 f0 7f 00       	push   $0x7ff000
  801008:	e8 27 fa ff ff       	call   800a34 <memmove>

	// Move the new page to the old page's address
	if ((r = sys_page_map(0, PFTEMP, 0, addr_pgstart, PTE_P|PTE_U|PTE_W)) < 0)
  80100d:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801014:	53                   	push   %ebx
  801015:	6a 00                	push   $0x0
  801017:	68 00 f0 7f 00       	push   $0x7ff000
  80101c:	6a 00                	push   $0x0
  80101e:	e8 c5 fc ff ff       	call   800ce8 <sys_page_map>
  801023:	83 c4 20             	add    $0x20,%esp
  801026:	85 c0                	test   %eax,%eax
  801028:	79 12                	jns    80103c <pgfault+0x87>
		panic("sys_page_map: %e", r);
  80102a:	50                   	push   %eax
  80102b:	68 6a 2b 80 00       	push   $0x802b6a
  801030:	6a 33                	push   $0x33
  801032:	68 7b 2b 80 00       	push   $0x802b7b
  801037:	e8 08 f2 ff ff       	call   800244 <_panic>

	// Unmap the temp location
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  80103c:	83 ec 08             	sub    $0x8,%esp
  80103f:	68 00 f0 7f 00       	push   $0x7ff000
  801044:	6a 00                	push   $0x0
  801046:	e8 df fc ff ff       	call   800d2a <sys_page_unmap>
  80104b:	83 c4 10             	add    $0x10,%esp
  80104e:	85 c0                	test   %eax,%eax
  801050:	79 12                	jns    801064 <pgfault+0xaf>
		panic("sys_page_unmap: %e", r);
  801052:	50                   	push   %eax
  801053:	68 99 2b 80 00       	push   $0x802b99
  801058:	6a 37                	push   $0x37
  80105a:	68 7b 2b 80 00       	push   $0x802b7b
  80105f:	e8 e0 f1 ff ff       	call   800244 <_panic>
}
  801064:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801067:	c9                   	leave  
  801068:	c3                   	ret    

00801069 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801069:	55                   	push   %ebp
  80106a:	89 e5                	mov    %esp,%ebp
  80106c:	56                   	push   %esi
  80106d:	53                   	push   %ebx
  80106e:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
	// Set up page fault handler
	set_pgfault_handler(&pgfault);
  801071:	68 b5 0f 80 00       	push   $0x800fb5
  801076:	e8 8e 13 00 00       	call   802409 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  80107b:	b8 07 00 00 00       	mov    $0x7,%eax
  801080:	cd 30                	int    $0x30

	// Create child
	envid_t envid = sys_exofork();
  801082:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (envid < 0) {
  801085:	83 c4 10             	add    $0x10,%esp
  801088:	85 c0                	test   %eax,%eax
  80108a:	79 12                	jns    80109e <fork+0x35>
		panic("sys_exofork: %e", envid);
  80108c:	50                   	push   %eax
  80108d:	68 ac 2b 80 00       	push   $0x802bac
  801092:	6a 7c                	push   $0x7c
  801094:	68 7b 2b 80 00       	push   $0x802b7b
  801099:	e8 a6 f1 ff ff       	call   800244 <_panic>
		return envid;
	}
	if (envid == 0) {
  80109e:	85 c0                	test   %eax,%eax
  8010a0:	75 1e                	jne    8010c0 <fork+0x57>
		// We are the child.
		thisenv = &envs[ENVX(sys_getenvid())]; // Fix thisenv
  8010a2:	e8 c0 fb ff ff       	call   800c67 <sys_getenvid>
  8010a7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010ac:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8010af:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010b4:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  8010b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8010be:	eb 7d                	jmp    80113d <fork+0xd4>

	// Set page fault handler on the child.
	// The parent needs to do it, else the child wouldn't be able to handle
	// the fault when trying to access it's stack (which happens as soon it starts)
	extern void _pgfault_upcall(void);
	sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);
  8010c0:	83 ec 04             	sub    $0x4,%esp
  8010c3:	6a 07                	push   $0x7
  8010c5:	68 00 f0 bf ee       	push   $0xeebff000
  8010ca:	50                   	push   %eax
  8010cb:	e8 d5 fb ff ff       	call   800ca5 <sys_page_alloc>
	sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  8010d0:	83 c4 08             	add    $0x8,%esp
  8010d3:	68 4e 24 80 00       	push   $0x80244e
  8010d8:	ff 75 f4             	pushl  -0xc(%ebp)
  8010db:	e8 10 fd ff ff       	call   800df0 <sys_env_set_pgfault_upcall>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  8010e0:	be 04 70 80 00       	mov    $0x807004,%esi
  8010e5:	c1 ee 0c             	shr    $0xc,%esi
  8010e8:	83 c4 10             	add    $0x10,%esp
  8010eb:	bb 00 08 00 00       	mov    $0x800,%ebx
  8010f0:	eb 0d                	jmp    8010ff <fork+0x96>
		duppage(envid, pn);
  8010f2:	89 da                	mov    %ebx,%edx
  8010f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010f7:	e8 b9 fd ff ff       	call   800eb5 <duppage>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  8010fc:	83 c3 01             	add    $0x1,%ebx
  8010ff:	39 f3                	cmp    %esi,%ebx
  801101:	76 ef                	jbe    8010f2 <fork+0x89>
	}

	// Also copy the stack we are currently running on
	// I think it should loop from ustacktop to this page, since the stack
	// can have more than 1 page
	duppage(envid, ((uint32_t) &envid)/PGSIZE);
  801103:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801106:	c1 ea 0c             	shr    $0xc,%edx
  801109:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80110c:	e8 a4 fd ff ff       	call   800eb5 <duppage>

	// Start the child environmnet running
	int r;
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  801111:	83 ec 08             	sub    $0x8,%esp
  801114:	6a 02                	push   $0x2
  801116:	ff 75 f4             	pushl  -0xc(%ebp)
  801119:	e8 4e fc ff ff       	call   800d6c <sys_env_set_status>
  80111e:	83 c4 10             	add    $0x10,%esp
  801121:	85 c0                	test   %eax,%eax
  801123:	79 15                	jns    80113a <fork+0xd1>
		panic("sys_env_set_status: %e", r);
  801125:	50                   	push   %eax
  801126:	68 bc 2b 80 00       	push   $0x802bbc
  80112b:	68 9c 00 00 00       	push   $0x9c
  801130:	68 7b 2b 80 00       	push   $0x802b7b
  801135:	e8 0a f1 ff ff       	call   800244 <_panic>
		return r;
	}

	return envid;
  80113a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80113d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801140:	5b                   	pop    %ebx
  801141:	5e                   	pop    %esi
  801142:	5d                   	pop    %ebp
  801143:	c3                   	ret    

00801144 <sfork>:

// Challenge!
int
sfork(void)
{
  801144:	55                   	push   %ebp
  801145:	89 e5                	mov    %esp,%ebp
  801147:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80114a:	68 d3 2b 80 00       	push   $0x802bd3
  80114f:	68 a7 00 00 00       	push   $0xa7
  801154:	68 7b 2b 80 00       	push   $0x802b7b
  801159:	e8 e6 f0 ff ff       	call   800244 <_panic>

0080115e <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80115e:	55                   	push   %ebp
  80115f:	89 e5                	mov    %esp,%ebp
  801161:	56                   	push   %esi
  801162:	53                   	push   %ebx
  801163:	8b 75 08             	mov    0x8(%ebp),%esi
  801166:	8b 45 0c             	mov    0xc(%ebp),%eax
  801169:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  80116c:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  80116e:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801173:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  801176:	83 ec 0c             	sub    $0xc,%esp
  801179:	50                   	push   %eax
  80117a:	e8 d6 fc ff ff       	call   800e55 <sys_ipc_recv>

	if (r < 0) {
  80117f:	83 c4 10             	add    $0x10,%esp
  801182:	85 c0                	test   %eax,%eax
  801184:	79 16                	jns    80119c <ipc_recv+0x3e>
		if (from_env_store)
  801186:	85 f6                	test   %esi,%esi
  801188:	74 06                	je     801190 <ipc_recv+0x32>
			*from_env_store = 0;
  80118a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  801190:	85 db                	test   %ebx,%ebx
  801192:	74 2c                	je     8011c0 <ipc_recv+0x62>
			*perm_store = 0;
  801194:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80119a:	eb 24                	jmp    8011c0 <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  80119c:	85 f6                	test   %esi,%esi
  80119e:	74 0a                	je     8011aa <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  8011a0:	a1 08 40 80 00       	mov    0x804008,%eax
  8011a5:	8b 40 74             	mov    0x74(%eax),%eax
  8011a8:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  8011aa:	85 db                	test   %ebx,%ebx
  8011ac:	74 0a                	je     8011b8 <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  8011ae:	a1 08 40 80 00       	mov    0x804008,%eax
  8011b3:	8b 40 78             	mov    0x78(%eax),%eax
  8011b6:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  8011b8:	a1 08 40 80 00       	mov    0x804008,%eax
  8011bd:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  8011c0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011c3:	5b                   	pop    %ebx
  8011c4:	5e                   	pop    %esi
  8011c5:	5d                   	pop    %ebp
  8011c6:	c3                   	ret    

008011c7 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8011c7:	55                   	push   %ebp
  8011c8:	89 e5                	mov    %esp,%ebp
  8011ca:	57                   	push   %edi
  8011cb:	56                   	push   %esi
  8011cc:	53                   	push   %ebx
  8011cd:	83 ec 0c             	sub    $0xc,%esp
  8011d0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011d3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8011d6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  8011d9:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  8011db:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  8011e0:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  8011e3:	ff 75 14             	pushl  0x14(%ebp)
  8011e6:	53                   	push   %ebx
  8011e7:	56                   	push   %esi
  8011e8:	57                   	push   %edi
  8011e9:	e8 44 fc ff ff       	call   800e32 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  8011ee:	83 c4 10             	add    $0x10,%esp
  8011f1:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8011f4:	75 07                	jne    8011fd <ipc_send+0x36>
			sys_yield();
  8011f6:	e8 8b fa ff ff       	call   800c86 <sys_yield>
  8011fb:	eb e6                	jmp    8011e3 <ipc_send+0x1c>
		} else if (r < 0) {
  8011fd:	85 c0                	test   %eax,%eax
  8011ff:	79 12                	jns    801213 <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  801201:	50                   	push   %eax
  801202:	68 e9 2b 80 00       	push   $0x802be9
  801207:	6a 51                	push   $0x51
  801209:	68 f6 2b 80 00       	push   $0x802bf6
  80120e:	e8 31 f0 ff ff       	call   800244 <_panic>
		}
	}
}
  801213:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801216:	5b                   	pop    %ebx
  801217:	5e                   	pop    %esi
  801218:	5f                   	pop    %edi
  801219:	5d                   	pop    %ebp
  80121a:	c3                   	ret    

0080121b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80121b:	55                   	push   %ebp
  80121c:	89 e5                	mov    %esp,%ebp
  80121e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801221:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801226:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801229:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80122f:	8b 52 50             	mov    0x50(%edx),%edx
  801232:	39 ca                	cmp    %ecx,%edx
  801234:	75 0d                	jne    801243 <ipc_find_env+0x28>
			return envs[i].env_id;
  801236:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801239:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80123e:	8b 40 48             	mov    0x48(%eax),%eax
  801241:	eb 0f                	jmp    801252 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801243:	83 c0 01             	add    $0x1,%eax
  801246:	3d 00 04 00 00       	cmp    $0x400,%eax
  80124b:	75 d9                	jne    801226 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80124d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801252:	5d                   	pop    %ebp
  801253:	c3                   	ret    

00801254 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801254:	55                   	push   %ebp
  801255:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801257:	8b 45 08             	mov    0x8(%ebp),%eax
  80125a:	05 00 00 00 30       	add    $0x30000000,%eax
  80125f:	c1 e8 0c             	shr    $0xc,%eax
}
  801262:	5d                   	pop    %ebp
  801263:	c3                   	ret    

00801264 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801264:	55                   	push   %ebp
  801265:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801267:	8b 45 08             	mov    0x8(%ebp),%eax
  80126a:	05 00 00 00 30       	add    $0x30000000,%eax
  80126f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801274:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801279:	5d                   	pop    %ebp
  80127a:	c3                   	ret    

0080127b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80127b:	55                   	push   %ebp
  80127c:	89 e5                	mov    %esp,%ebp
  80127e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801281:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801286:	89 c2                	mov    %eax,%edx
  801288:	c1 ea 16             	shr    $0x16,%edx
  80128b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801292:	f6 c2 01             	test   $0x1,%dl
  801295:	74 11                	je     8012a8 <fd_alloc+0x2d>
  801297:	89 c2                	mov    %eax,%edx
  801299:	c1 ea 0c             	shr    $0xc,%edx
  80129c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012a3:	f6 c2 01             	test   $0x1,%dl
  8012a6:	75 09                	jne    8012b1 <fd_alloc+0x36>
			*fd_store = fd;
  8012a8:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8012af:	eb 17                	jmp    8012c8 <fd_alloc+0x4d>
  8012b1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8012b6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012bb:	75 c9                	jne    801286 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012bd:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8012c3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012c8:	5d                   	pop    %ebp
  8012c9:	c3                   	ret    

008012ca <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012ca:	55                   	push   %ebp
  8012cb:	89 e5                	mov    %esp,%ebp
  8012cd:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012d0:	83 f8 1f             	cmp    $0x1f,%eax
  8012d3:	77 36                	ja     80130b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012d5:	c1 e0 0c             	shl    $0xc,%eax
  8012d8:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012dd:	89 c2                	mov    %eax,%edx
  8012df:	c1 ea 16             	shr    $0x16,%edx
  8012e2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012e9:	f6 c2 01             	test   $0x1,%dl
  8012ec:	74 24                	je     801312 <fd_lookup+0x48>
  8012ee:	89 c2                	mov    %eax,%edx
  8012f0:	c1 ea 0c             	shr    $0xc,%edx
  8012f3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012fa:	f6 c2 01             	test   $0x1,%dl
  8012fd:	74 1a                	je     801319 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  801302:	89 02                	mov    %eax,(%edx)
	return 0;
  801304:	b8 00 00 00 00       	mov    $0x0,%eax
  801309:	eb 13                	jmp    80131e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80130b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801310:	eb 0c                	jmp    80131e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801312:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801317:	eb 05                	jmp    80131e <fd_lookup+0x54>
  801319:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80131e:	5d                   	pop    %ebp
  80131f:	c3                   	ret    

00801320 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801320:	55                   	push   %ebp
  801321:	89 e5                	mov    %esp,%ebp
  801323:	83 ec 08             	sub    $0x8,%esp
  801326:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801329:	ba 80 2c 80 00       	mov    $0x802c80,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80132e:	eb 13                	jmp    801343 <dev_lookup+0x23>
  801330:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801333:	39 08                	cmp    %ecx,(%eax)
  801335:	75 0c                	jne    801343 <dev_lookup+0x23>
			*dev = devtab[i];
  801337:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80133a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80133c:	b8 00 00 00 00       	mov    $0x0,%eax
  801341:	eb 2e                	jmp    801371 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801343:	8b 02                	mov    (%edx),%eax
  801345:	85 c0                	test   %eax,%eax
  801347:	75 e7                	jne    801330 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801349:	a1 08 40 80 00       	mov    0x804008,%eax
  80134e:	8b 40 48             	mov    0x48(%eax),%eax
  801351:	83 ec 04             	sub    $0x4,%esp
  801354:	51                   	push   %ecx
  801355:	50                   	push   %eax
  801356:	68 00 2c 80 00       	push   $0x802c00
  80135b:	e8 bd ef ff ff       	call   80031d <cprintf>
	*dev = 0;
  801360:	8b 45 0c             	mov    0xc(%ebp),%eax
  801363:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801369:	83 c4 10             	add    $0x10,%esp
  80136c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801371:	c9                   	leave  
  801372:	c3                   	ret    

00801373 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801373:	55                   	push   %ebp
  801374:	89 e5                	mov    %esp,%ebp
  801376:	56                   	push   %esi
  801377:	53                   	push   %ebx
  801378:	83 ec 10             	sub    $0x10,%esp
  80137b:	8b 75 08             	mov    0x8(%ebp),%esi
  80137e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801381:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801384:	50                   	push   %eax
  801385:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80138b:	c1 e8 0c             	shr    $0xc,%eax
  80138e:	50                   	push   %eax
  80138f:	e8 36 ff ff ff       	call   8012ca <fd_lookup>
  801394:	83 c4 08             	add    $0x8,%esp
  801397:	85 c0                	test   %eax,%eax
  801399:	78 05                	js     8013a0 <fd_close+0x2d>
	    || fd != fd2)
  80139b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80139e:	74 0c                	je     8013ac <fd_close+0x39>
		return (must_exist ? r : 0);
  8013a0:	84 db                	test   %bl,%bl
  8013a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8013a7:	0f 44 c2             	cmove  %edx,%eax
  8013aa:	eb 41                	jmp    8013ed <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013ac:	83 ec 08             	sub    $0x8,%esp
  8013af:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013b2:	50                   	push   %eax
  8013b3:	ff 36                	pushl  (%esi)
  8013b5:	e8 66 ff ff ff       	call   801320 <dev_lookup>
  8013ba:	89 c3                	mov    %eax,%ebx
  8013bc:	83 c4 10             	add    $0x10,%esp
  8013bf:	85 c0                	test   %eax,%eax
  8013c1:	78 1a                	js     8013dd <fd_close+0x6a>
		if (dev->dev_close)
  8013c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013c6:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8013c9:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8013ce:	85 c0                	test   %eax,%eax
  8013d0:	74 0b                	je     8013dd <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8013d2:	83 ec 0c             	sub    $0xc,%esp
  8013d5:	56                   	push   %esi
  8013d6:	ff d0                	call   *%eax
  8013d8:	89 c3                	mov    %eax,%ebx
  8013da:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013dd:	83 ec 08             	sub    $0x8,%esp
  8013e0:	56                   	push   %esi
  8013e1:	6a 00                	push   $0x0
  8013e3:	e8 42 f9 ff ff       	call   800d2a <sys_page_unmap>
	return r;
  8013e8:	83 c4 10             	add    $0x10,%esp
  8013eb:	89 d8                	mov    %ebx,%eax
}
  8013ed:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013f0:	5b                   	pop    %ebx
  8013f1:	5e                   	pop    %esi
  8013f2:	5d                   	pop    %ebp
  8013f3:	c3                   	ret    

008013f4 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013f4:	55                   	push   %ebp
  8013f5:	89 e5                	mov    %esp,%ebp
  8013f7:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013fd:	50                   	push   %eax
  8013fe:	ff 75 08             	pushl  0x8(%ebp)
  801401:	e8 c4 fe ff ff       	call   8012ca <fd_lookup>
  801406:	83 c4 08             	add    $0x8,%esp
  801409:	85 c0                	test   %eax,%eax
  80140b:	78 10                	js     80141d <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80140d:	83 ec 08             	sub    $0x8,%esp
  801410:	6a 01                	push   $0x1
  801412:	ff 75 f4             	pushl  -0xc(%ebp)
  801415:	e8 59 ff ff ff       	call   801373 <fd_close>
  80141a:	83 c4 10             	add    $0x10,%esp
}
  80141d:	c9                   	leave  
  80141e:	c3                   	ret    

0080141f <close_all>:

void
close_all(void)
{
  80141f:	55                   	push   %ebp
  801420:	89 e5                	mov    %esp,%ebp
  801422:	53                   	push   %ebx
  801423:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801426:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80142b:	83 ec 0c             	sub    $0xc,%esp
  80142e:	53                   	push   %ebx
  80142f:	e8 c0 ff ff ff       	call   8013f4 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801434:	83 c3 01             	add    $0x1,%ebx
  801437:	83 c4 10             	add    $0x10,%esp
  80143a:	83 fb 20             	cmp    $0x20,%ebx
  80143d:	75 ec                	jne    80142b <close_all+0xc>
		close(i);
}
  80143f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801442:	c9                   	leave  
  801443:	c3                   	ret    

00801444 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801444:	55                   	push   %ebp
  801445:	89 e5                	mov    %esp,%ebp
  801447:	57                   	push   %edi
  801448:	56                   	push   %esi
  801449:	53                   	push   %ebx
  80144a:	83 ec 2c             	sub    $0x2c,%esp
  80144d:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801450:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801453:	50                   	push   %eax
  801454:	ff 75 08             	pushl  0x8(%ebp)
  801457:	e8 6e fe ff ff       	call   8012ca <fd_lookup>
  80145c:	83 c4 08             	add    $0x8,%esp
  80145f:	85 c0                	test   %eax,%eax
  801461:	0f 88 c1 00 00 00    	js     801528 <dup+0xe4>
		return r;
	close(newfdnum);
  801467:	83 ec 0c             	sub    $0xc,%esp
  80146a:	56                   	push   %esi
  80146b:	e8 84 ff ff ff       	call   8013f4 <close>

	newfd = INDEX2FD(newfdnum);
  801470:	89 f3                	mov    %esi,%ebx
  801472:	c1 e3 0c             	shl    $0xc,%ebx
  801475:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80147b:	83 c4 04             	add    $0x4,%esp
  80147e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801481:	e8 de fd ff ff       	call   801264 <fd2data>
  801486:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801488:	89 1c 24             	mov    %ebx,(%esp)
  80148b:	e8 d4 fd ff ff       	call   801264 <fd2data>
  801490:	83 c4 10             	add    $0x10,%esp
  801493:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801496:	89 f8                	mov    %edi,%eax
  801498:	c1 e8 16             	shr    $0x16,%eax
  80149b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014a2:	a8 01                	test   $0x1,%al
  8014a4:	74 37                	je     8014dd <dup+0x99>
  8014a6:	89 f8                	mov    %edi,%eax
  8014a8:	c1 e8 0c             	shr    $0xc,%eax
  8014ab:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014b2:	f6 c2 01             	test   $0x1,%dl
  8014b5:	74 26                	je     8014dd <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014b7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014be:	83 ec 0c             	sub    $0xc,%esp
  8014c1:	25 07 0e 00 00       	and    $0xe07,%eax
  8014c6:	50                   	push   %eax
  8014c7:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014ca:	6a 00                	push   $0x0
  8014cc:	57                   	push   %edi
  8014cd:	6a 00                	push   $0x0
  8014cf:	e8 14 f8 ff ff       	call   800ce8 <sys_page_map>
  8014d4:	89 c7                	mov    %eax,%edi
  8014d6:	83 c4 20             	add    $0x20,%esp
  8014d9:	85 c0                	test   %eax,%eax
  8014db:	78 2e                	js     80150b <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014dd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014e0:	89 d0                	mov    %edx,%eax
  8014e2:	c1 e8 0c             	shr    $0xc,%eax
  8014e5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014ec:	83 ec 0c             	sub    $0xc,%esp
  8014ef:	25 07 0e 00 00       	and    $0xe07,%eax
  8014f4:	50                   	push   %eax
  8014f5:	53                   	push   %ebx
  8014f6:	6a 00                	push   $0x0
  8014f8:	52                   	push   %edx
  8014f9:	6a 00                	push   $0x0
  8014fb:	e8 e8 f7 ff ff       	call   800ce8 <sys_page_map>
  801500:	89 c7                	mov    %eax,%edi
  801502:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801505:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801507:	85 ff                	test   %edi,%edi
  801509:	79 1d                	jns    801528 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80150b:	83 ec 08             	sub    $0x8,%esp
  80150e:	53                   	push   %ebx
  80150f:	6a 00                	push   $0x0
  801511:	e8 14 f8 ff ff       	call   800d2a <sys_page_unmap>
	sys_page_unmap(0, nva);
  801516:	83 c4 08             	add    $0x8,%esp
  801519:	ff 75 d4             	pushl  -0x2c(%ebp)
  80151c:	6a 00                	push   $0x0
  80151e:	e8 07 f8 ff ff       	call   800d2a <sys_page_unmap>
	return r;
  801523:	83 c4 10             	add    $0x10,%esp
  801526:	89 f8                	mov    %edi,%eax
}
  801528:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80152b:	5b                   	pop    %ebx
  80152c:	5e                   	pop    %esi
  80152d:	5f                   	pop    %edi
  80152e:	5d                   	pop    %ebp
  80152f:	c3                   	ret    

00801530 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801530:	55                   	push   %ebp
  801531:	89 e5                	mov    %esp,%ebp
  801533:	53                   	push   %ebx
  801534:	83 ec 14             	sub    $0x14,%esp
  801537:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80153a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80153d:	50                   	push   %eax
  80153e:	53                   	push   %ebx
  80153f:	e8 86 fd ff ff       	call   8012ca <fd_lookup>
  801544:	83 c4 08             	add    $0x8,%esp
  801547:	89 c2                	mov    %eax,%edx
  801549:	85 c0                	test   %eax,%eax
  80154b:	78 6d                	js     8015ba <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80154d:	83 ec 08             	sub    $0x8,%esp
  801550:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801553:	50                   	push   %eax
  801554:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801557:	ff 30                	pushl  (%eax)
  801559:	e8 c2 fd ff ff       	call   801320 <dev_lookup>
  80155e:	83 c4 10             	add    $0x10,%esp
  801561:	85 c0                	test   %eax,%eax
  801563:	78 4c                	js     8015b1 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801565:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801568:	8b 42 08             	mov    0x8(%edx),%eax
  80156b:	83 e0 03             	and    $0x3,%eax
  80156e:	83 f8 01             	cmp    $0x1,%eax
  801571:	75 21                	jne    801594 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801573:	a1 08 40 80 00       	mov    0x804008,%eax
  801578:	8b 40 48             	mov    0x48(%eax),%eax
  80157b:	83 ec 04             	sub    $0x4,%esp
  80157e:	53                   	push   %ebx
  80157f:	50                   	push   %eax
  801580:	68 44 2c 80 00       	push   $0x802c44
  801585:	e8 93 ed ff ff       	call   80031d <cprintf>
		return -E_INVAL;
  80158a:	83 c4 10             	add    $0x10,%esp
  80158d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801592:	eb 26                	jmp    8015ba <read+0x8a>
	}
	if (!dev->dev_read)
  801594:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801597:	8b 40 08             	mov    0x8(%eax),%eax
  80159a:	85 c0                	test   %eax,%eax
  80159c:	74 17                	je     8015b5 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80159e:	83 ec 04             	sub    $0x4,%esp
  8015a1:	ff 75 10             	pushl  0x10(%ebp)
  8015a4:	ff 75 0c             	pushl  0xc(%ebp)
  8015a7:	52                   	push   %edx
  8015a8:	ff d0                	call   *%eax
  8015aa:	89 c2                	mov    %eax,%edx
  8015ac:	83 c4 10             	add    $0x10,%esp
  8015af:	eb 09                	jmp    8015ba <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b1:	89 c2                	mov    %eax,%edx
  8015b3:	eb 05                	jmp    8015ba <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8015b5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8015ba:	89 d0                	mov    %edx,%eax
  8015bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015bf:	c9                   	leave  
  8015c0:	c3                   	ret    

008015c1 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015c1:	55                   	push   %ebp
  8015c2:	89 e5                	mov    %esp,%ebp
  8015c4:	57                   	push   %edi
  8015c5:	56                   	push   %esi
  8015c6:	53                   	push   %ebx
  8015c7:	83 ec 0c             	sub    $0xc,%esp
  8015ca:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015cd:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015d0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015d5:	eb 21                	jmp    8015f8 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015d7:	83 ec 04             	sub    $0x4,%esp
  8015da:	89 f0                	mov    %esi,%eax
  8015dc:	29 d8                	sub    %ebx,%eax
  8015de:	50                   	push   %eax
  8015df:	89 d8                	mov    %ebx,%eax
  8015e1:	03 45 0c             	add    0xc(%ebp),%eax
  8015e4:	50                   	push   %eax
  8015e5:	57                   	push   %edi
  8015e6:	e8 45 ff ff ff       	call   801530 <read>
		if (m < 0)
  8015eb:	83 c4 10             	add    $0x10,%esp
  8015ee:	85 c0                	test   %eax,%eax
  8015f0:	78 10                	js     801602 <readn+0x41>
			return m;
		if (m == 0)
  8015f2:	85 c0                	test   %eax,%eax
  8015f4:	74 0a                	je     801600 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015f6:	01 c3                	add    %eax,%ebx
  8015f8:	39 f3                	cmp    %esi,%ebx
  8015fa:	72 db                	jb     8015d7 <readn+0x16>
  8015fc:	89 d8                	mov    %ebx,%eax
  8015fe:	eb 02                	jmp    801602 <readn+0x41>
  801600:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801602:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801605:	5b                   	pop    %ebx
  801606:	5e                   	pop    %esi
  801607:	5f                   	pop    %edi
  801608:	5d                   	pop    %ebp
  801609:	c3                   	ret    

0080160a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80160a:	55                   	push   %ebp
  80160b:	89 e5                	mov    %esp,%ebp
  80160d:	53                   	push   %ebx
  80160e:	83 ec 14             	sub    $0x14,%esp
  801611:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801614:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801617:	50                   	push   %eax
  801618:	53                   	push   %ebx
  801619:	e8 ac fc ff ff       	call   8012ca <fd_lookup>
  80161e:	83 c4 08             	add    $0x8,%esp
  801621:	89 c2                	mov    %eax,%edx
  801623:	85 c0                	test   %eax,%eax
  801625:	78 68                	js     80168f <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801627:	83 ec 08             	sub    $0x8,%esp
  80162a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80162d:	50                   	push   %eax
  80162e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801631:	ff 30                	pushl  (%eax)
  801633:	e8 e8 fc ff ff       	call   801320 <dev_lookup>
  801638:	83 c4 10             	add    $0x10,%esp
  80163b:	85 c0                	test   %eax,%eax
  80163d:	78 47                	js     801686 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80163f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801642:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801646:	75 21                	jne    801669 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801648:	a1 08 40 80 00       	mov    0x804008,%eax
  80164d:	8b 40 48             	mov    0x48(%eax),%eax
  801650:	83 ec 04             	sub    $0x4,%esp
  801653:	53                   	push   %ebx
  801654:	50                   	push   %eax
  801655:	68 60 2c 80 00       	push   $0x802c60
  80165a:	e8 be ec ff ff       	call   80031d <cprintf>
		return -E_INVAL;
  80165f:	83 c4 10             	add    $0x10,%esp
  801662:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801667:	eb 26                	jmp    80168f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801669:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80166c:	8b 52 0c             	mov    0xc(%edx),%edx
  80166f:	85 d2                	test   %edx,%edx
  801671:	74 17                	je     80168a <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801673:	83 ec 04             	sub    $0x4,%esp
  801676:	ff 75 10             	pushl  0x10(%ebp)
  801679:	ff 75 0c             	pushl  0xc(%ebp)
  80167c:	50                   	push   %eax
  80167d:	ff d2                	call   *%edx
  80167f:	89 c2                	mov    %eax,%edx
  801681:	83 c4 10             	add    $0x10,%esp
  801684:	eb 09                	jmp    80168f <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801686:	89 c2                	mov    %eax,%edx
  801688:	eb 05                	jmp    80168f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80168a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80168f:	89 d0                	mov    %edx,%eax
  801691:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801694:	c9                   	leave  
  801695:	c3                   	ret    

00801696 <seek>:

int
seek(int fdnum, off_t offset)
{
  801696:	55                   	push   %ebp
  801697:	89 e5                	mov    %esp,%ebp
  801699:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80169c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80169f:	50                   	push   %eax
  8016a0:	ff 75 08             	pushl  0x8(%ebp)
  8016a3:	e8 22 fc ff ff       	call   8012ca <fd_lookup>
  8016a8:	83 c4 08             	add    $0x8,%esp
  8016ab:	85 c0                	test   %eax,%eax
  8016ad:	78 0e                	js     8016bd <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8016af:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016b5:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016bd:	c9                   	leave  
  8016be:	c3                   	ret    

008016bf <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016bf:	55                   	push   %ebp
  8016c0:	89 e5                	mov    %esp,%ebp
  8016c2:	53                   	push   %ebx
  8016c3:	83 ec 14             	sub    $0x14,%esp
  8016c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016c9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016cc:	50                   	push   %eax
  8016cd:	53                   	push   %ebx
  8016ce:	e8 f7 fb ff ff       	call   8012ca <fd_lookup>
  8016d3:	83 c4 08             	add    $0x8,%esp
  8016d6:	89 c2                	mov    %eax,%edx
  8016d8:	85 c0                	test   %eax,%eax
  8016da:	78 65                	js     801741 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016dc:	83 ec 08             	sub    $0x8,%esp
  8016df:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016e2:	50                   	push   %eax
  8016e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016e6:	ff 30                	pushl  (%eax)
  8016e8:	e8 33 fc ff ff       	call   801320 <dev_lookup>
  8016ed:	83 c4 10             	add    $0x10,%esp
  8016f0:	85 c0                	test   %eax,%eax
  8016f2:	78 44                	js     801738 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016f7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016fb:	75 21                	jne    80171e <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016fd:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801702:	8b 40 48             	mov    0x48(%eax),%eax
  801705:	83 ec 04             	sub    $0x4,%esp
  801708:	53                   	push   %ebx
  801709:	50                   	push   %eax
  80170a:	68 20 2c 80 00       	push   $0x802c20
  80170f:	e8 09 ec ff ff       	call   80031d <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801714:	83 c4 10             	add    $0x10,%esp
  801717:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80171c:	eb 23                	jmp    801741 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80171e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801721:	8b 52 18             	mov    0x18(%edx),%edx
  801724:	85 d2                	test   %edx,%edx
  801726:	74 14                	je     80173c <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801728:	83 ec 08             	sub    $0x8,%esp
  80172b:	ff 75 0c             	pushl  0xc(%ebp)
  80172e:	50                   	push   %eax
  80172f:	ff d2                	call   *%edx
  801731:	89 c2                	mov    %eax,%edx
  801733:	83 c4 10             	add    $0x10,%esp
  801736:	eb 09                	jmp    801741 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801738:	89 c2                	mov    %eax,%edx
  80173a:	eb 05                	jmp    801741 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80173c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801741:	89 d0                	mov    %edx,%eax
  801743:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801746:	c9                   	leave  
  801747:	c3                   	ret    

00801748 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801748:	55                   	push   %ebp
  801749:	89 e5                	mov    %esp,%ebp
  80174b:	53                   	push   %ebx
  80174c:	83 ec 14             	sub    $0x14,%esp
  80174f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801752:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801755:	50                   	push   %eax
  801756:	ff 75 08             	pushl  0x8(%ebp)
  801759:	e8 6c fb ff ff       	call   8012ca <fd_lookup>
  80175e:	83 c4 08             	add    $0x8,%esp
  801761:	89 c2                	mov    %eax,%edx
  801763:	85 c0                	test   %eax,%eax
  801765:	78 58                	js     8017bf <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801767:	83 ec 08             	sub    $0x8,%esp
  80176a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80176d:	50                   	push   %eax
  80176e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801771:	ff 30                	pushl  (%eax)
  801773:	e8 a8 fb ff ff       	call   801320 <dev_lookup>
  801778:	83 c4 10             	add    $0x10,%esp
  80177b:	85 c0                	test   %eax,%eax
  80177d:	78 37                	js     8017b6 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80177f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801782:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801786:	74 32                	je     8017ba <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801788:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80178b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801792:	00 00 00 
	stat->st_isdir = 0;
  801795:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80179c:	00 00 00 
	stat->st_dev = dev;
  80179f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017a5:	83 ec 08             	sub    $0x8,%esp
  8017a8:	53                   	push   %ebx
  8017a9:	ff 75 f0             	pushl  -0x10(%ebp)
  8017ac:	ff 50 14             	call   *0x14(%eax)
  8017af:	89 c2                	mov    %eax,%edx
  8017b1:	83 c4 10             	add    $0x10,%esp
  8017b4:	eb 09                	jmp    8017bf <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017b6:	89 c2                	mov    %eax,%edx
  8017b8:	eb 05                	jmp    8017bf <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8017ba:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8017bf:	89 d0                	mov    %edx,%eax
  8017c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017c4:	c9                   	leave  
  8017c5:	c3                   	ret    

008017c6 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017c6:	55                   	push   %ebp
  8017c7:	89 e5                	mov    %esp,%ebp
  8017c9:	56                   	push   %esi
  8017ca:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017cb:	83 ec 08             	sub    $0x8,%esp
  8017ce:	6a 00                	push   $0x0
  8017d0:	ff 75 08             	pushl  0x8(%ebp)
  8017d3:	e8 0c 02 00 00       	call   8019e4 <open>
  8017d8:	89 c3                	mov    %eax,%ebx
  8017da:	83 c4 10             	add    $0x10,%esp
  8017dd:	85 c0                	test   %eax,%eax
  8017df:	78 1b                	js     8017fc <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017e1:	83 ec 08             	sub    $0x8,%esp
  8017e4:	ff 75 0c             	pushl  0xc(%ebp)
  8017e7:	50                   	push   %eax
  8017e8:	e8 5b ff ff ff       	call   801748 <fstat>
  8017ed:	89 c6                	mov    %eax,%esi
	close(fd);
  8017ef:	89 1c 24             	mov    %ebx,(%esp)
  8017f2:	e8 fd fb ff ff       	call   8013f4 <close>
	return r;
  8017f7:	83 c4 10             	add    $0x10,%esp
  8017fa:	89 f0                	mov    %esi,%eax
}
  8017fc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017ff:	5b                   	pop    %ebx
  801800:	5e                   	pop    %esi
  801801:	5d                   	pop    %ebp
  801802:	c3                   	ret    

00801803 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801803:	55                   	push   %ebp
  801804:	89 e5                	mov    %esp,%ebp
  801806:	56                   	push   %esi
  801807:	53                   	push   %ebx
  801808:	89 c6                	mov    %eax,%esi
  80180a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80180c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801813:	75 12                	jne    801827 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801815:	83 ec 0c             	sub    $0xc,%esp
  801818:	6a 01                	push   $0x1
  80181a:	e8 fc f9 ff ff       	call   80121b <ipc_find_env>
  80181f:	a3 00 40 80 00       	mov    %eax,0x804000
  801824:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801827:	6a 07                	push   $0x7
  801829:	68 00 50 80 00       	push   $0x805000
  80182e:	56                   	push   %esi
  80182f:	ff 35 00 40 80 00    	pushl  0x804000
  801835:	e8 8d f9 ff ff       	call   8011c7 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80183a:	83 c4 0c             	add    $0xc,%esp
  80183d:	6a 00                	push   $0x0
  80183f:	53                   	push   %ebx
  801840:	6a 00                	push   $0x0
  801842:	e8 17 f9 ff ff       	call   80115e <ipc_recv>
}
  801847:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80184a:	5b                   	pop    %ebx
  80184b:	5e                   	pop    %esi
  80184c:	5d                   	pop    %ebp
  80184d:	c3                   	ret    

0080184e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80184e:	55                   	push   %ebp
  80184f:	89 e5                	mov    %esp,%ebp
  801851:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801854:	8b 45 08             	mov    0x8(%ebp),%eax
  801857:	8b 40 0c             	mov    0xc(%eax),%eax
  80185a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80185f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801862:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801867:	ba 00 00 00 00       	mov    $0x0,%edx
  80186c:	b8 02 00 00 00       	mov    $0x2,%eax
  801871:	e8 8d ff ff ff       	call   801803 <fsipc>
}
  801876:	c9                   	leave  
  801877:	c3                   	ret    

00801878 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801878:	55                   	push   %ebp
  801879:	89 e5                	mov    %esp,%ebp
  80187b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80187e:	8b 45 08             	mov    0x8(%ebp),%eax
  801881:	8b 40 0c             	mov    0xc(%eax),%eax
  801884:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801889:	ba 00 00 00 00       	mov    $0x0,%edx
  80188e:	b8 06 00 00 00       	mov    $0x6,%eax
  801893:	e8 6b ff ff ff       	call   801803 <fsipc>
}
  801898:	c9                   	leave  
  801899:	c3                   	ret    

0080189a <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80189a:	55                   	push   %ebp
  80189b:	89 e5                	mov    %esp,%ebp
  80189d:	53                   	push   %ebx
  80189e:	83 ec 04             	sub    $0x4,%esp
  8018a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a7:	8b 40 0c             	mov    0xc(%eax),%eax
  8018aa:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018af:	ba 00 00 00 00       	mov    $0x0,%edx
  8018b4:	b8 05 00 00 00       	mov    $0x5,%eax
  8018b9:	e8 45 ff ff ff       	call   801803 <fsipc>
  8018be:	85 c0                	test   %eax,%eax
  8018c0:	78 2c                	js     8018ee <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018c2:	83 ec 08             	sub    $0x8,%esp
  8018c5:	68 00 50 80 00       	push   $0x805000
  8018ca:	53                   	push   %ebx
  8018cb:	e8 d2 ef ff ff       	call   8008a2 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018d0:	a1 80 50 80 00       	mov    0x805080,%eax
  8018d5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018db:	a1 84 50 80 00       	mov    0x805084,%eax
  8018e0:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018e6:	83 c4 10             	add    $0x10,%esp
  8018e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018f1:	c9                   	leave  
  8018f2:	c3                   	ret    

008018f3 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8018f3:	55                   	push   %ebp
  8018f4:	89 e5                	mov    %esp,%ebp
  8018f6:	53                   	push   %ebx
  8018f7:	83 ec 08             	sub    $0x8,%esp
  8018fa:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8018fd:	8b 55 08             	mov    0x8(%ebp),%edx
  801900:	8b 52 0c             	mov    0xc(%edx),%edx
  801903:	89 15 00 50 80 00    	mov    %edx,0x805000
  801909:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80190e:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  801913:	0f 46 d8             	cmovbe %eax,%ebx
	
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  801916:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  80191c:	53                   	push   %ebx
  80191d:	ff 75 0c             	pushl  0xc(%ebp)
  801920:	68 08 50 80 00       	push   $0x805008
  801925:	e8 0a f1 ff ff       	call   800a34 <memmove>

	
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) 
  80192a:	ba 00 00 00 00       	mov    $0x0,%edx
  80192f:	b8 04 00 00 00       	mov    $0x4,%eax
  801934:	e8 ca fe ff ff       	call   801803 <fsipc>
  801939:	83 c4 10             	add    $0x10,%esp
  80193c:	85 c0                	test   %eax,%eax
  80193e:	78 1d                	js     80195d <devfile_write+0x6a>
		return r;
	assert(r <= n_real); 
  801940:	39 d8                	cmp    %ebx,%eax
  801942:	76 19                	jbe    80195d <devfile_write+0x6a>
  801944:	68 94 2c 80 00       	push   $0x802c94
  801949:	68 a0 2c 80 00       	push   $0x802ca0
  80194e:	68 a3 00 00 00       	push   $0xa3
  801953:	68 b5 2c 80 00       	push   $0x802cb5
  801958:	e8 e7 e8 ff ff       	call   800244 <_panic>
	return r;
}
  80195d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801960:	c9                   	leave  
  801961:	c3                   	ret    

00801962 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801962:	55                   	push   %ebp
  801963:	89 e5                	mov    %esp,%ebp
  801965:	56                   	push   %esi
  801966:	53                   	push   %ebx
  801967:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80196a:	8b 45 08             	mov    0x8(%ebp),%eax
  80196d:	8b 40 0c             	mov    0xc(%eax),%eax
  801970:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801975:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80197b:	ba 00 00 00 00       	mov    $0x0,%edx
  801980:	b8 03 00 00 00       	mov    $0x3,%eax
  801985:	e8 79 fe ff ff       	call   801803 <fsipc>
  80198a:	89 c3                	mov    %eax,%ebx
  80198c:	85 c0                	test   %eax,%eax
  80198e:	78 4b                	js     8019db <devfile_read+0x79>
		return r;
	assert(r <= n);
  801990:	39 c6                	cmp    %eax,%esi
  801992:	73 16                	jae    8019aa <devfile_read+0x48>
  801994:	68 c0 2c 80 00       	push   $0x802cc0
  801999:	68 a0 2c 80 00       	push   $0x802ca0
  80199e:	6a 7c                	push   $0x7c
  8019a0:	68 b5 2c 80 00       	push   $0x802cb5
  8019a5:	e8 9a e8 ff ff       	call   800244 <_panic>
	assert(r <= PGSIZE);
  8019aa:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019af:	7e 16                	jle    8019c7 <devfile_read+0x65>
  8019b1:	68 c7 2c 80 00       	push   $0x802cc7
  8019b6:	68 a0 2c 80 00       	push   $0x802ca0
  8019bb:	6a 7d                	push   $0x7d
  8019bd:	68 b5 2c 80 00       	push   $0x802cb5
  8019c2:	e8 7d e8 ff ff       	call   800244 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8019c7:	83 ec 04             	sub    $0x4,%esp
  8019ca:	50                   	push   %eax
  8019cb:	68 00 50 80 00       	push   $0x805000
  8019d0:	ff 75 0c             	pushl  0xc(%ebp)
  8019d3:	e8 5c f0 ff ff       	call   800a34 <memmove>
	return r;
  8019d8:	83 c4 10             	add    $0x10,%esp
}
  8019db:	89 d8                	mov    %ebx,%eax
  8019dd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019e0:	5b                   	pop    %ebx
  8019e1:	5e                   	pop    %esi
  8019e2:	5d                   	pop    %ebp
  8019e3:	c3                   	ret    

008019e4 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8019e4:	55                   	push   %ebp
  8019e5:	89 e5                	mov    %esp,%ebp
  8019e7:	53                   	push   %ebx
  8019e8:	83 ec 20             	sub    $0x20,%esp
  8019eb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8019ee:	53                   	push   %ebx
  8019ef:	e8 75 ee ff ff       	call   800869 <strlen>
  8019f4:	83 c4 10             	add    $0x10,%esp
  8019f7:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019fc:	7f 67                	jg     801a65 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019fe:	83 ec 0c             	sub    $0xc,%esp
  801a01:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a04:	50                   	push   %eax
  801a05:	e8 71 f8 ff ff       	call   80127b <fd_alloc>
  801a0a:	83 c4 10             	add    $0x10,%esp
		return r;
  801a0d:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a0f:	85 c0                	test   %eax,%eax
  801a11:	78 57                	js     801a6a <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a13:	83 ec 08             	sub    $0x8,%esp
  801a16:	53                   	push   %ebx
  801a17:	68 00 50 80 00       	push   $0x805000
  801a1c:	e8 81 ee ff ff       	call   8008a2 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a21:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a24:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a29:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a2c:	b8 01 00 00 00       	mov    $0x1,%eax
  801a31:	e8 cd fd ff ff       	call   801803 <fsipc>
  801a36:	89 c3                	mov    %eax,%ebx
  801a38:	83 c4 10             	add    $0x10,%esp
  801a3b:	85 c0                	test   %eax,%eax
  801a3d:	79 14                	jns    801a53 <open+0x6f>
		fd_close(fd, 0);
  801a3f:	83 ec 08             	sub    $0x8,%esp
  801a42:	6a 00                	push   $0x0
  801a44:	ff 75 f4             	pushl  -0xc(%ebp)
  801a47:	e8 27 f9 ff ff       	call   801373 <fd_close>
		return r;
  801a4c:	83 c4 10             	add    $0x10,%esp
  801a4f:	89 da                	mov    %ebx,%edx
  801a51:	eb 17                	jmp    801a6a <open+0x86>
	}

	return fd2num(fd);
  801a53:	83 ec 0c             	sub    $0xc,%esp
  801a56:	ff 75 f4             	pushl  -0xc(%ebp)
  801a59:	e8 f6 f7 ff ff       	call   801254 <fd2num>
  801a5e:	89 c2                	mov    %eax,%edx
  801a60:	83 c4 10             	add    $0x10,%esp
  801a63:	eb 05                	jmp    801a6a <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a65:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a6a:	89 d0                	mov    %edx,%eax
  801a6c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a6f:	c9                   	leave  
  801a70:	c3                   	ret    

00801a71 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a71:	55                   	push   %ebp
  801a72:	89 e5                	mov    %esp,%ebp
  801a74:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a77:	ba 00 00 00 00       	mov    $0x0,%edx
  801a7c:	b8 08 00 00 00       	mov    $0x8,%eax
  801a81:	e8 7d fd ff ff       	call   801803 <fsipc>
}
  801a86:	c9                   	leave  
  801a87:	c3                   	ret    

00801a88 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801a88:	55                   	push   %ebp
  801a89:	89 e5                	mov    %esp,%ebp
  801a8b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801a8e:	89 d0                	mov    %edx,%eax
  801a90:	c1 e8 16             	shr    $0x16,%eax
  801a93:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801a9a:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801a9f:	f6 c1 01             	test   $0x1,%cl
  801aa2:	74 1d                	je     801ac1 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801aa4:	c1 ea 0c             	shr    $0xc,%edx
  801aa7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801aae:	f6 c2 01             	test   $0x1,%dl
  801ab1:	74 0e                	je     801ac1 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ab3:	c1 ea 0c             	shr    $0xc,%edx
  801ab6:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801abd:	ef 
  801abe:	0f b7 c0             	movzwl %ax,%eax
}
  801ac1:	5d                   	pop    %ebp
  801ac2:	c3                   	ret    

00801ac3 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801ac3:	55                   	push   %ebp
  801ac4:	89 e5                	mov    %esp,%ebp
  801ac6:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801ac9:	68 d3 2c 80 00       	push   $0x802cd3
  801ace:	ff 75 0c             	pushl  0xc(%ebp)
  801ad1:	e8 cc ed ff ff       	call   8008a2 <strcpy>
	return 0;
}
  801ad6:	b8 00 00 00 00       	mov    $0x0,%eax
  801adb:	c9                   	leave  
  801adc:	c3                   	ret    

00801add <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801add:	55                   	push   %ebp
  801ade:	89 e5                	mov    %esp,%ebp
  801ae0:	53                   	push   %ebx
  801ae1:	83 ec 10             	sub    $0x10,%esp
  801ae4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801ae7:	53                   	push   %ebx
  801ae8:	e8 9b ff ff ff       	call   801a88 <pageref>
  801aed:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801af0:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801af5:	83 f8 01             	cmp    $0x1,%eax
  801af8:	75 10                	jne    801b0a <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801afa:	83 ec 0c             	sub    $0xc,%esp
  801afd:	ff 73 0c             	pushl  0xc(%ebx)
  801b00:	e8 c0 02 00 00       	call   801dc5 <nsipc_close>
  801b05:	89 c2                	mov    %eax,%edx
  801b07:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801b0a:	89 d0                	mov    %edx,%eax
  801b0c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b0f:	c9                   	leave  
  801b10:	c3                   	ret    

00801b11 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801b11:	55                   	push   %ebp
  801b12:	89 e5                	mov    %esp,%ebp
  801b14:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801b17:	6a 00                	push   $0x0
  801b19:	ff 75 10             	pushl  0x10(%ebp)
  801b1c:	ff 75 0c             	pushl  0xc(%ebp)
  801b1f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b22:	ff 70 0c             	pushl  0xc(%eax)
  801b25:	e8 78 03 00 00       	call   801ea2 <nsipc_send>
}
  801b2a:	c9                   	leave  
  801b2b:	c3                   	ret    

00801b2c <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801b2c:	55                   	push   %ebp
  801b2d:	89 e5                	mov    %esp,%ebp
  801b2f:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801b32:	6a 00                	push   $0x0
  801b34:	ff 75 10             	pushl  0x10(%ebp)
  801b37:	ff 75 0c             	pushl  0xc(%ebp)
  801b3a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b3d:	ff 70 0c             	pushl  0xc(%eax)
  801b40:	e8 f1 02 00 00       	call   801e36 <nsipc_recv>
}
  801b45:	c9                   	leave  
  801b46:	c3                   	ret    

00801b47 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801b47:	55                   	push   %ebp
  801b48:	89 e5                	mov    %esp,%ebp
  801b4a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801b4d:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801b50:	52                   	push   %edx
  801b51:	50                   	push   %eax
  801b52:	e8 73 f7 ff ff       	call   8012ca <fd_lookup>
  801b57:	83 c4 10             	add    $0x10,%esp
  801b5a:	85 c0                	test   %eax,%eax
  801b5c:	78 17                	js     801b75 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801b5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b61:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801b67:	39 08                	cmp    %ecx,(%eax)
  801b69:	75 05                	jne    801b70 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801b6b:	8b 40 0c             	mov    0xc(%eax),%eax
  801b6e:	eb 05                	jmp    801b75 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801b70:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801b75:	c9                   	leave  
  801b76:	c3                   	ret    

00801b77 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801b77:	55                   	push   %ebp
  801b78:	89 e5                	mov    %esp,%ebp
  801b7a:	56                   	push   %esi
  801b7b:	53                   	push   %ebx
  801b7c:	83 ec 1c             	sub    $0x1c,%esp
  801b7f:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801b81:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b84:	50                   	push   %eax
  801b85:	e8 f1 f6 ff ff       	call   80127b <fd_alloc>
  801b8a:	89 c3                	mov    %eax,%ebx
  801b8c:	83 c4 10             	add    $0x10,%esp
  801b8f:	85 c0                	test   %eax,%eax
  801b91:	78 1b                	js     801bae <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801b93:	83 ec 04             	sub    $0x4,%esp
  801b96:	68 07 04 00 00       	push   $0x407
  801b9b:	ff 75 f4             	pushl  -0xc(%ebp)
  801b9e:	6a 00                	push   $0x0
  801ba0:	e8 00 f1 ff ff       	call   800ca5 <sys_page_alloc>
  801ba5:	89 c3                	mov    %eax,%ebx
  801ba7:	83 c4 10             	add    $0x10,%esp
  801baa:	85 c0                	test   %eax,%eax
  801bac:	79 10                	jns    801bbe <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801bae:	83 ec 0c             	sub    $0xc,%esp
  801bb1:	56                   	push   %esi
  801bb2:	e8 0e 02 00 00       	call   801dc5 <nsipc_close>
		return r;
  801bb7:	83 c4 10             	add    $0x10,%esp
  801bba:	89 d8                	mov    %ebx,%eax
  801bbc:	eb 24                	jmp    801be2 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801bbe:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bc7:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801bc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bcc:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801bd3:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801bd6:	83 ec 0c             	sub    $0xc,%esp
  801bd9:	50                   	push   %eax
  801bda:	e8 75 f6 ff ff       	call   801254 <fd2num>
  801bdf:	83 c4 10             	add    $0x10,%esp
}
  801be2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801be5:	5b                   	pop    %ebx
  801be6:	5e                   	pop    %esi
  801be7:	5d                   	pop    %ebp
  801be8:	c3                   	ret    

00801be9 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801be9:	55                   	push   %ebp
  801bea:	89 e5                	mov    %esp,%ebp
  801bec:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bef:	8b 45 08             	mov    0x8(%ebp),%eax
  801bf2:	e8 50 ff ff ff       	call   801b47 <fd2sockid>
		return r;
  801bf7:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bf9:	85 c0                	test   %eax,%eax
  801bfb:	78 1f                	js     801c1c <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801bfd:	83 ec 04             	sub    $0x4,%esp
  801c00:	ff 75 10             	pushl  0x10(%ebp)
  801c03:	ff 75 0c             	pushl  0xc(%ebp)
  801c06:	50                   	push   %eax
  801c07:	e8 12 01 00 00       	call   801d1e <nsipc_accept>
  801c0c:	83 c4 10             	add    $0x10,%esp
		return r;
  801c0f:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801c11:	85 c0                	test   %eax,%eax
  801c13:	78 07                	js     801c1c <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801c15:	e8 5d ff ff ff       	call   801b77 <alloc_sockfd>
  801c1a:	89 c1                	mov    %eax,%ecx
}
  801c1c:	89 c8                	mov    %ecx,%eax
  801c1e:	c9                   	leave  
  801c1f:	c3                   	ret    

00801c20 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c20:	55                   	push   %ebp
  801c21:	89 e5                	mov    %esp,%ebp
  801c23:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c26:	8b 45 08             	mov    0x8(%ebp),%eax
  801c29:	e8 19 ff ff ff       	call   801b47 <fd2sockid>
  801c2e:	85 c0                	test   %eax,%eax
  801c30:	78 12                	js     801c44 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801c32:	83 ec 04             	sub    $0x4,%esp
  801c35:	ff 75 10             	pushl  0x10(%ebp)
  801c38:	ff 75 0c             	pushl  0xc(%ebp)
  801c3b:	50                   	push   %eax
  801c3c:	e8 2d 01 00 00       	call   801d6e <nsipc_bind>
  801c41:	83 c4 10             	add    $0x10,%esp
}
  801c44:	c9                   	leave  
  801c45:	c3                   	ret    

00801c46 <shutdown>:

int
shutdown(int s, int how)
{
  801c46:	55                   	push   %ebp
  801c47:	89 e5                	mov    %esp,%ebp
  801c49:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c4c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c4f:	e8 f3 fe ff ff       	call   801b47 <fd2sockid>
  801c54:	85 c0                	test   %eax,%eax
  801c56:	78 0f                	js     801c67 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801c58:	83 ec 08             	sub    $0x8,%esp
  801c5b:	ff 75 0c             	pushl  0xc(%ebp)
  801c5e:	50                   	push   %eax
  801c5f:	e8 3f 01 00 00       	call   801da3 <nsipc_shutdown>
  801c64:	83 c4 10             	add    $0x10,%esp
}
  801c67:	c9                   	leave  
  801c68:	c3                   	ret    

00801c69 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801c69:	55                   	push   %ebp
  801c6a:	89 e5                	mov    %esp,%ebp
  801c6c:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c6f:	8b 45 08             	mov    0x8(%ebp),%eax
  801c72:	e8 d0 fe ff ff       	call   801b47 <fd2sockid>
  801c77:	85 c0                	test   %eax,%eax
  801c79:	78 12                	js     801c8d <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801c7b:	83 ec 04             	sub    $0x4,%esp
  801c7e:	ff 75 10             	pushl  0x10(%ebp)
  801c81:	ff 75 0c             	pushl  0xc(%ebp)
  801c84:	50                   	push   %eax
  801c85:	e8 55 01 00 00       	call   801ddf <nsipc_connect>
  801c8a:	83 c4 10             	add    $0x10,%esp
}
  801c8d:	c9                   	leave  
  801c8e:	c3                   	ret    

00801c8f <listen>:

int
listen(int s, int backlog)
{
  801c8f:	55                   	push   %ebp
  801c90:	89 e5                	mov    %esp,%ebp
  801c92:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c95:	8b 45 08             	mov    0x8(%ebp),%eax
  801c98:	e8 aa fe ff ff       	call   801b47 <fd2sockid>
  801c9d:	85 c0                	test   %eax,%eax
  801c9f:	78 0f                	js     801cb0 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801ca1:	83 ec 08             	sub    $0x8,%esp
  801ca4:	ff 75 0c             	pushl  0xc(%ebp)
  801ca7:	50                   	push   %eax
  801ca8:	e8 67 01 00 00       	call   801e14 <nsipc_listen>
  801cad:	83 c4 10             	add    $0x10,%esp
}
  801cb0:	c9                   	leave  
  801cb1:	c3                   	ret    

00801cb2 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801cb2:	55                   	push   %ebp
  801cb3:	89 e5                	mov    %esp,%ebp
  801cb5:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801cb8:	ff 75 10             	pushl  0x10(%ebp)
  801cbb:	ff 75 0c             	pushl  0xc(%ebp)
  801cbe:	ff 75 08             	pushl  0x8(%ebp)
  801cc1:	e8 3a 02 00 00       	call   801f00 <nsipc_socket>
  801cc6:	83 c4 10             	add    $0x10,%esp
  801cc9:	85 c0                	test   %eax,%eax
  801ccb:	78 05                	js     801cd2 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801ccd:	e8 a5 fe ff ff       	call   801b77 <alloc_sockfd>
}
  801cd2:	c9                   	leave  
  801cd3:	c3                   	ret    

00801cd4 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801cd4:	55                   	push   %ebp
  801cd5:	89 e5                	mov    %esp,%ebp
  801cd7:	53                   	push   %ebx
  801cd8:	83 ec 04             	sub    $0x4,%esp
  801cdb:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801cdd:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801ce4:	75 12                	jne    801cf8 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801ce6:	83 ec 0c             	sub    $0xc,%esp
  801ce9:	6a 02                	push   $0x2
  801ceb:	e8 2b f5 ff ff       	call   80121b <ipc_find_env>
  801cf0:	a3 04 40 80 00       	mov    %eax,0x804004
  801cf5:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801cf8:	6a 07                	push   $0x7
  801cfa:	68 00 60 80 00       	push   $0x806000
  801cff:	53                   	push   %ebx
  801d00:	ff 35 04 40 80 00    	pushl  0x804004
  801d06:	e8 bc f4 ff ff       	call   8011c7 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801d0b:	83 c4 0c             	add    $0xc,%esp
  801d0e:	6a 00                	push   $0x0
  801d10:	6a 00                	push   $0x0
  801d12:	6a 00                	push   $0x0
  801d14:	e8 45 f4 ff ff       	call   80115e <ipc_recv>
}
  801d19:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d1c:	c9                   	leave  
  801d1d:	c3                   	ret    

00801d1e <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801d1e:	55                   	push   %ebp
  801d1f:	89 e5                	mov    %esp,%ebp
  801d21:	56                   	push   %esi
  801d22:	53                   	push   %ebx
  801d23:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801d26:	8b 45 08             	mov    0x8(%ebp),%eax
  801d29:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801d2e:	8b 06                	mov    (%esi),%eax
  801d30:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801d35:	b8 01 00 00 00       	mov    $0x1,%eax
  801d3a:	e8 95 ff ff ff       	call   801cd4 <nsipc>
  801d3f:	89 c3                	mov    %eax,%ebx
  801d41:	85 c0                	test   %eax,%eax
  801d43:	78 20                	js     801d65 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801d45:	83 ec 04             	sub    $0x4,%esp
  801d48:	ff 35 10 60 80 00    	pushl  0x806010
  801d4e:	68 00 60 80 00       	push   $0x806000
  801d53:	ff 75 0c             	pushl  0xc(%ebp)
  801d56:	e8 d9 ec ff ff       	call   800a34 <memmove>
		*addrlen = ret->ret_addrlen;
  801d5b:	a1 10 60 80 00       	mov    0x806010,%eax
  801d60:	89 06                	mov    %eax,(%esi)
  801d62:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801d65:	89 d8                	mov    %ebx,%eax
  801d67:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d6a:	5b                   	pop    %ebx
  801d6b:	5e                   	pop    %esi
  801d6c:	5d                   	pop    %ebp
  801d6d:	c3                   	ret    

00801d6e <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801d6e:	55                   	push   %ebp
  801d6f:	89 e5                	mov    %esp,%ebp
  801d71:	53                   	push   %ebx
  801d72:	83 ec 08             	sub    $0x8,%esp
  801d75:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801d78:	8b 45 08             	mov    0x8(%ebp),%eax
  801d7b:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801d80:	53                   	push   %ebx
  801d81:	ff 75 0c             	pushl  0xc(%ebp)
  801d84:	68 04 60 80 00       	push   $0x806004
  801d89:	e8 a6 ec ff ff       	call   800a34 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801d8e:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801d94:	b8 02 00 00 00       	mov    $0x2,%eax
  801d99:	e8 36 ff ff ff       	call   801cd4 <nsipc>
}
  801d9e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801da1:	c9                   	leave  
  801da2:	c3                   	ret    

00801da3 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801da3:	55                   	push   %ebp
  801da4:	89 e5                	mov    %esp,%ebp
  801da6:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801da9:	8b 45 08             	mov    0x8(%ebp),%eax
  801dac:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801db1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801db4:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801db9:	b8 03 00 00 00       	mov    $0x3,%eax
  801dbe:	e8 11 ff ff ff       	call   801cd4 <nsipc>
}
  801dc3:	c9                   	leave  
  801dc4:	c3                   	ret    

00801dc5 <nsipc_close>:

int
nsipc_close(int s)
{
  801dc5:	55                   	push   %ebp
  801dc6:	89 e5                	mov    %esp,%ebp
  801dc8:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801dcb:	8b 45 08             	mov    0x8(%ebp),%eax
  801dce:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801dd3:	b8 04 00 00 00       	mov    $0x4,%eax
  801dd8:	e8 f7 fe ff ff       	call   801cd4 <nsipc>
}
  801ddd:	c9                   	leave  
  801dde:	c3                   	ret    

00801ddf <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801ddf:	55                   	push   %ebp
  801de0:	89 e5                	mov    %esp,%ebp
  801de2:	53                   	push   %ebx
  801de3:	83 ec 08             	sub    $0x8,%esp
  801de6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801de9:	8b 45 08             	mov    0x8(%ebp),%eax
  801dec:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801df1:	53                   	push   %ebx
  801df2:	ff 75 0c             	pushl  0xc(%ebp)
  801df5:	68 04 60 80 00       	push   $0x806004
  801dfa:	e8 35 ec ff ff       	call   800a34 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801dff:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801e05:	b8 05 00 00 00       	mov    $0x5,%eax
  801e0a:	e8 c5 fe ff ff       	call   801cd4 <nsipc>
}
  801e0f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e12:	c9                   	leave  
  801e13:	c3                   	ret    

00801e14 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801e14:	55                   	push   %ebp
  801e15:	89 e5                	mov    %esp,%ebp
  801e17:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801e1a:	8b 45 08             	mov    0x8(%ebp),%eax
  801e1d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801e22:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e25:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801e2a:	b8 06 00 00 00       	mov    $0x6,%eax
  801e2f:	e8 a0 fe ff ff       	call   801cd4 <nsipc>
}
  801e34:	c9                   	leave  
  801e35:	c3                   	ret    

00801e36 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801e36:	55                   	push   %ebp
  801e37:	89 e5                	mov    %esp,%ebp
  801e39:	56                   	push   %esi
  801e3a:	53                   	push   %ebx
  801e3b:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801e3e:	8b 45 08             	mov    0x8(%ebp),%eax
  801e41:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801e46:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801e4c:	8b 45 14             	mov    0x14(%ebp),%eax
  801e4f:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801e54:	b8 07 00 00 00       	mov    $0x7,%eax
  801e59:	e8 76 fe ff ff       	call   801cd4 <nsipc>
  801e5e:	89 c3                	mov    %eax,%ebx
  801e60:	85 c0                	test   %eax,%eax
  801e62:	78 35                	js     801e99 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801e64:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801e69:	7f 04                	jg     801e6f <nsipc_recv+0x39>
  801e6b:	39 c6                	cmp    %eax,%esi
  801e6d:	7d 16                	jge    801e85 <nsipc_recv+0x4f>
  801e6f:	68 df 2c 80 00       	push   $0x802cdf
  801e74:	68 a0 2c 80 00       	push   $0x802ca0
  801e79:	6a 62                	push   $0x62
  801e7b:	68 f4 2c 80 00       	push   $0x802cf4
  801e80:	e8 bf e3 ff ff       	call   800244 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801e85:	83 ec 04             	sub    $0x4,%esp
  801e88:	50                   	push   %eax
  801e89:	68 00 60 80 00       	push   $0x806000
  801e8e:	ff 75 0c             	pushl  0xc(%ebp)
  801e91:	e8 9e eb ff ff       	call   800a34 <memmove>
  801e96:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801e99:	89 d8                	mov    %ebx,%eax
  801e9b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e9e:	5b                   	pop    %ebx
  801e9f:	5e                   	pop    %esi
  801ea0:	5d                   	pop    %ebp
  801ea1:	c3                   	ret    

00801ea2 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801ea2:	55                   	push   %ebp
  801ea3:	89 e5                	mov    %esp,%ebp
  801ea5:	53                   	push   %ebx
  801ea6:	83 ec 04             	sub    $0x4,%esp
  801ea9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801eac:	8b 45 08             	mov    0x8(%ebp),%eax
  801eaf:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801eb4:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801eba:	7e 16                	jle    801ed2 <nsipc_send+0x30>
  801ebc:	68 00 2d 80 00       	push   $0x802d00
  801ec1:	68 a0 2c 80 00       	push   $0x802ca0
  801ec6:	6a 6d                	push   $0x6d
  801ec8:	68 f4 2c 80 00       	push   $0x802cf4
  801ecd:	e8 72 e3 ff ff       	call   800244 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801ed2:	83 ec 04             	sub    $0x4,%esp
  801ed5:	53                   	push   %ebx
  801ed6:	ff 75 0c             	pushl  0xc(%ebp)
  801ed9:	68 0c 60 80 00       	push   $0x80600c
  801ede:	e8 51 eb ff ff       	call   800a34 <memmove>
	nsipcbuf.send.req_size = size;
  801ee3:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801ee9:	8b 45 14             	mov    0x14(%ebp),%eax
  801eec:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801ef1:	b8 08 00 00 00       	mov    $0x8,%eax
  801ef6:	e8 d9 fd ff ff       	call   801cd4 <nsipc>
}
  801efb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801efe:	c9                   	leave  
  801eff:	c3                   	ret    

00801f00 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801f00:	55                   	push   %ebp
  801f01:	89 e5                	mov    %esp,%ebp
  801f03:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801f06:	8b 45 08             	mov    0x8(%ebp),%eax
  801f09:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801f0e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f11:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801f16:	8b 45 10             	mov    0x10(%ebp),%eax
  801f19:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801f1e:	b8 09 00 00 00       	mov    $0x9,%eax
  801f23:	e8 ac fd ff ff       	call   801cd4 <nsipc>
}
  801f28:	c9                   	leave  
  801f29:	c3                   	ret    

00801f2a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801f2a:	55                   	push   %ebp
  801f2b:	89 e5                	mov    %esp,%ebp
  801f2d:	56                   	push   %esi
  801f2e:	53                   	push   %ebx
  801f2f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801f32:	83 ec 0c             	sub    $0xc,%esp
  801f35:	ff 75 08             	pushl  0x8(%ebp)
  801f38:	e8 27 f3 ff ff       	call   801264 <fd2data>
  801f3d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801f3f:	83 c4 08             	add    $0x8,%esp
  801f42:	68 0c 2d 80 00       	push   $0x802d0c
  801f47:	53                   	push   %ebx
  801f48:	e8 55 e9 ff ff       	call   8008a2 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801f4d:	8b 46 04             	mov    0x4(%esi),%eax
  801f50:	2b 06                	sub    (%esi),%eax
  801f52:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801f58:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801f5f:	00 00 00 
	stat->st_dev = &devpipe;
  801f62:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801f69:	30 80 00 
	return 0;
}
  801f6c:	b8 00 00 00 00       	mov    $0x0,%eax
  801f71:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f74:	5b                   	pop    %ebx
  801f75:	5e                   	pop    %esi
  801f76:	5d                   	pop    %ebp
  801f77:	c3                   	ret    

00801f78 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801f78:	55                   	push   %ebp
  801f79:	89 e5                	mov    %esp,%ebp
  801f7b:	53                   	push   %ebx
  801f7c:	83 ec 0c             	sub    $0xc,%esp
  801f7f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801f82:	53                   	push   %ebx
  801f83:	6a 00                	push   $0x0
  801f85:	e8 a0 ed ff ff       	call   800d2a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801f8a:	89 1c 24             	mov    %ebx,(%esp)
  801f8d:	e8 d2 f2 ff ff       	call   801264 <fd2data>
  801f92:	83 c4 08             	add    $0x8,%esp
  801f95:	50                   	push   %eax
  801f96:	6a 00                	push   $0x0
  801f98:	e8 8d ed ff ff       	call   800d2a <sys_page_unmap>
}
  801f9d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fa0:	c9                   	leave  
  801fa1:	c3                   	ret    

00801fa2 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801fa2:	55                   	push   %ebp
  801fa3:	89 e5                	mov    %esp,%ebp
  801fa5:	57                   	push   %edi
  801fa6:	56                   	push   %esi
  801fa7:	53                   	push   %ebx
  801fa8:	83 ec 1c             	sub    $0x1c,%esp
  801fab:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801fae:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801fb0:	a1 08 40 80 00       	mov    0x804008,%eax
  801fb5:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801fb8:	83 ec 0c             	sub    $0xc,%esp
  801fbb:	ff 75 e0             	pushl  -0x20(%ebp)
  801fbe:	e8 c5 fa ff ff       	call   801a88 <pageref>
  801fc3:	89 c3                	mov    %eax,%ebx
  801fc5:	89 3c 24             	mov    %edi,(%esp)
  801fc8:	e8 bb fa ff ff       	call   801a88 <pageref>
  801fcd:	83 c4 10             	add    $0x10,%esp
  801fd0:	39 c3                	cmp    %eax,%ebx
  801fd2:	0f 94 c1             	sete   %cl
  801fd5:	0f b6 c9             	movzbl %cl,%ecx
  801fd8:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801fdb:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801fe1:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801fe4:	39 ce                	cmp    %ecx,%esi
  801fe6:	74 1b                	je     802003 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801fe8:	39 c3                	cmp    %eax,%ebx
  801fea:	75 c4                	jne    801fb0 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801fec:	8b 42 58             	mov    0x58(%edx),%eax
  801fef:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ff2:	50                   	push   %eax
  801ff3:	56                   	push   %esi
  801ff4:	68 13 2d 80 00       	push   $0x802d13
  801ff9:	e8 1f e3 ff ff       	call   80031d <cprintf>
  801ffe:	83 c4 10             	add    $0x10,%esp
  802001:	eb ad                	jmp    801fb0 <_pipeisclosed+0xe>
	}
}
  802003:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802006:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802009:	5b                   	pop    %ebx
  80200a:	5e                   	pop    %esi
  80200b:	5f                   	pop    %edi
  80200c:	5d                   	pop    %ebp
  80200d:	c3                   	ret    

0080200e <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80200e:	55                   	push   %ebp
  80200f:	89 e5                	mov    %esp,%ebp
  802011:	57                   	push   %edi
  802012:	56                   	push   %esi
  802013:	53                   	push   %ebx
  802014:	83 ec 28             	sub    $0x28,%esp
  802017:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80201a:	56                   	push   %esi
  80201b:	e8 44 f2 ff ff       	call   801264 <fd2data>
  802020:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802022:	83 c4 10             	add    $0x10,%esp
  802025:	bf 00 00 00 00       	mov    $0x0,%edi
  80202a:	eb 4b                	jmp    802077 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80202c:	89 da                	mov    %ebx,%edx
  80202e:	89 f0                	mov    %esi,%eax
  802030:	e8 6d ff ff ff       	call   801fa2 <_pipeisclosed>
  802035:	85 c0                	test   %eax,%eax
  802037:	75 48                	jne    802081 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802039:	e8 48 ec ff ff       	call   800c86 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80203e:	8b 43 04             	mov    0x4(%ebx),%eax
  802041:	8b 0b                	mov    (%ebx),%ecx
  802043:	8d 51 20             	lea    0x20(%ecx),%edx
  802046:	39 d0                	cmp    %edx,%eax
  802048:	73 e2                	jae    80202c <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80204a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80204d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802051:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802054:	89 c2                	mov    %eax,%edx
  802056:	c1 fa 1f             	sar    $0x1f,%edx
  802059:	89 d1                	mov    %edx,%ecx
  80205b:	c1 e9 1b             	shr    $0x1b,%ecx
  80205e:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802061:	83 e2 1f             	and    $0x1f,%edx
  802064:	29 ca                	sub    %ecx,%edx
  802066:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80206a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80206e:	83 c0 01             	add    $0x1,%eax
  802071:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802074:	83 c7 01             	add    $0x1,%edi
  802077:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80207a:	75 c2                	jne    80203e <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80207c:	8b 45 10             	mov    0x10(%ebp),%eax
  80207f:	eb 05                	jmp    802086 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802081:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802086:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802089:	5b                   	pop    %ebx
  80208a:	5e                   	pop    %esi
  80208b:	5f                   	pop    %edi
  80208c:	5d                   	pop    %ebp
  80208d:	c3                   	ret    

0080208e <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80208e:	55                   	push   %ebp
  80208f:	89 e5                	mov    %esp,%ebp
  802091:	57                   	push   %edi
  802092:	56                   	push   %esi
  802093:	53                   	push   %ebx
  802094:	83 ec 18             	sub    $0x18,%esp
  802097:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80209a:	57                   	push   %edi
  80209b:	e8 c4 f1 ff ff       	call   801264 <fd2data>
  8020a0:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020a2:	83 c4 10             	add    $0x10,%esp
  8020a5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8020aa:	eb 3d                	jmp    8020e9 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8020ac:	85 db                	test   %ebx,%ebx
  8020ae:	74 04                	je     8020b4 <devpipe_read+0x26>
				return i;
  8020b0:	89 d8                	mov    %ebx,%eax
  8020b2:	eb 44                	jmp    8020f8 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8020b4:	89 f2                	mov    %esi,%edx
  8020b6:	89 f8                	mov    %edi,%eax
  8020b8:	e8 e5 fe ff ff       	call   801fa2 <_pipeisclosed>
  8020bd:	85 c0                	test   %eax,%eax
  8020bf:	75 32                	jne    8020f3 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8020c1:	e8 c0 eb ff ff       	call   800c86 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8020c6:	8b 06                	mov    (%esi),%eax
  8020c8:	3b 46 04             	cmp    0x4(%esi),%eax
  8020cb:	74 df                	je     8020ac <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8020cd:	99                   	cltd   
  8020ce:	c1 ea 1b             	shr    $0x1b,%edx
  8020d1:	01 d0                	add    %edx,%eax
  8020d3:	83 e0 1f             	and    $0x1f,%eax
  8020d6:	29 d0                	sub    %edx,%eax
  8020d8:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8020dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8020e0:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8020e3:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020e6:	83 c3 01             	add    $0x1,%ebx
  8020e9:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8020ec:	75 d8                	jne    8020c6 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8020ee:	8b 45 10             	mov    0x10(%ebp),%eax
  8020f1:	eb 05                	jmp    8020f8 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8020f3:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8020f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020fb:	5b                   	pop    %ebx
  8020fc:	5e                   	pop    %esi
  8020fd:	5f                   	pop    %edi
  8020fe:	5d                   	pop    %ebp
  8020ff:	c3                   	ret    

00802100 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802100:	55                   	push   %ebp
  802101:	89 e5                	mov    %esp,%ebp
  802103:	56                   	push   %esi
  802104:	53                   	push   %ebx
  802105:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802108:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80210b:	50                   	push   %eax
  80210c:	e8 6a f1 ff ff       	call   80127b <fd_alloc>
  802111:	83 c4 10             	add    $0x10,%esp
  802114:	89 c2                	mov    %eax,%edx
  802116:	85 c0                	test   %eax,%eax
  802118:	0f 88 2c 01 00 00    	js     80224a <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80211e:	83 ec 04             	sub    $0x4,%esp
  802121:	68 07 04 00 00       	push   $0x407
  802126:	ff 75 f4             	pushl  -0xc(%ebp)
  802129:	6a 00                	push   $0x0
  80212b:	e8 75 eb ff ff       	call   800ca5 <sys_page_alloc>
  802130:	83 c4 10             	add    $0x10,%esp
  802133:	89 c2                	mov    %eax,%edx
  802135:	85 c0                	test   %eax,%eax
  802137:	0f 88 0d 01 00 00    	js     80224a <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80213d:	83 ec 0c             	sub    $0xc,%esp
  802140:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802143:	50                   	push   %eax
  802144:	e8 32 f1 ff ff       	call   80127b <fd_alloc>
  802149:	89 c3                	mov    %eax,%ebx
  80214b:	83 c4 10             	add    $0x10,%esp
  80214e:	85 c0                	test   %eax,%eax
  802150:	0f 88 e2 00 00 00    	js     802238 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802156:	83 ec 04             	sub    $0x4,%esp
  802159:	68 07 04 00 00       	push   $0x407
  80215e:	ff 75 f0             	pushl  -0x10(%ebp)
  802161:	6a 00                	push   $0x0
  802163:	e8 3d eb ff ff       	call   800ca5 <sys_page_alloc>
  802168:	89 c3                	mov    %eax,%ebx
  80216a:	83 c4 10             	add    $0x10,%esp
  80216d:	85 c0                	test   %eax,%eax
  80216f:	0f 88 c3 00 00 00    	js     802238 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802175:	83 ec 0c             	sub    $0xc,%esp
  802178:	ff 75 f4             	pushl  -0xc(%ebp)
  80217b:	e8 e4 f0 ff ff       	call   801264 <fd2data>
  802180:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802182:	83 c4 0c             	add    $0xc,%esp
  802185:	68 07 04 00 00       	push   $0x407
  80218a:	50                   	push   %eax
  80218b:	6a 00                	push   $0x0
  80218d:	e8 13 eb ff ff       	call   800ca5 <sys_page_alloc>
  802192:	89 c3                	mov    %eax,%ebx
  802194:	83 c4 10             	add    $0x10,%esp
  802197:	85 c0                	test   %eax,%eax
  802199:	0f 88 89 00 00 00    	js     802228 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80219f:	83 ec 0c             	sub    $0xc,%esp
  8021a2:	ff 75 f0             	pushl  -0x10(%ebp)
  8021a5:	e8 ba f0 ff ff       	call   801264 <fd2data>
  8021aa:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8021b1:	50                   	push   %eax
  8021b2:	6a 00                	push   $0x0
  8021b4:	56                   	push   %esi
  8021b5:	6a 00                	push   $0x0
  8021b7:	e8 2c eb ff ff       	call   800ce8 <sys_page_map>
  8021bc:	89 c3                	mov    %eax,%ebx
  8021be:	83 c4 20             	add    $0x20,%esp
  8021c1:	85 c0                	test   %eax,%eax
  8021c3:	78 55                	js     80221a <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8021c5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8021cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021ce:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8021d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021d3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8021da:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8021e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021e3:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8021e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021e8:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8021ef:	83 ec 0c             	sub    $0xc,%esp
  8021f2:	ff 75 f4             	pushl  -0xc(%ebp)
  8021f5:	e8 5a f0 ff ff       	call   801254 <fd2num>
  8021fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021fd:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8021ff:	83 c4 04             	add    $0x4,%esp
  802202:	ff 75 f0             	pushl  -0x10(%ebp)
  802205:	e8 4a f0 ff ff       	call   801254 <fd2num>
  80220a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80220d:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802210:	83 c4 10             	add    $0x10,%esp
  802213:	ba 00 00 00 00       	mov    $0x0,%edx
  802218:	eb 30                	jmp    80224a <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80221a:	83 ec 08             	sub    $0x8,%esp
  80221d:	56                   	push   %esi
  80221e:	6a 00                	push   $0x0
  802220:	e8 05 eb ff ff       	call   800d2a <sys_page_unmap>
  802225:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802228:	83 ec 08             	sub    $0x8,%esp
  80222b:	ff 75 f0             	pushl  -0x10(%ebp)
  80222e:	6a 00                	push   $0x0
  802230:	e8 f5 ea ff ff       	call   800d2a <sys_page_unmap>
  802235:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802238:	83 ec 08             	sub    $0x8,%esp
  80223b:	ff 75 f4             	pushl  -0xc(%ebp)
  80223e:	6a 00                	push   $0x0
  802240:	e8 e5 ea ff ff       	call   800d2a <sys_page_unmap>
  802245:	83 c4 10             	add    $0x10,%esp
  802248:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80224a:	89 d0                	mov    %edx,%eax
  80224c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80224f:	5b                   	pop    %ebx
  802250:	5e                   	pop    %esi
  802251:	5d                   	pop    %ebp
  802252:	c3                   	ret    

00802253 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802253:	55                   	push   %ebp
  802254:	89 e5                	mov    %esp,%ebp
  802256:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802259:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80225c:	50                   	push   %eax
  80225d:	ff 75 08             	pushl  0x8(%ebp)
  802260:	e8 65 f0 ff ff       	call   8012ca <fd_lookup>
  802265:	83 c4 10             	add    $0x10,%esp
  802268:	85 c0                	test   %eax,%eax
  80226a:	78 18                	js     802284 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80226c:	83 ec 0c             	sub    $0xc,%esp
  80226f:	ff 75 f4             	pushl  -0xc(%ebp)
  802272:	e8 ed ef ff ff       	call   801264 <fd2data>
	return _pipeisclosed(fd, p);
  802277:	89 c2                	mov    %eax,%edx
  802279:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80227c:	e8 21 fd ff ff       	call   801fa2 <_pipeisclosed>
  802281:	83 c4 10             	add    $0x10,%esp
}
  802284:	c9                   	leave  
  802285:	c3                   	ret    

00802286 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802286:	55                   	push   %ebp
  802287:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802289:	b8 00 00 00 00       	mov    $0x0,%eax
  80228e:	5d                   	pop    %ebp
  80228f:	c3                   	ret    

00802290 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802290:	55                   	push   %ebp
  802291:	89 e5                	mov    %esp,%ebp
  802293:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802296:	68 2b 2d 80 00       	push   $0x802d2b
  80229b:	ff 75 0c             	pushl  0xc(%ebp)
  80229e:	e8 ff e5 ff ff       	call   8008a2 <strcpy>
	return 0;
}
  8022a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8022a8:	c9                   	leave  
  8022a9:	c3                   	ret    

008022aa <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8022aa:	55                   	push   %ebp
  8022ab:	89 e5                	mov    %esp,%ebp
  8022ad:	57                   	push   %edi
  8022ae:	56                   	push   %esi
  8022af:	53                   	push   %ebx
  8022b0:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022b6:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8022bb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022c1:	eb 2d                	jmp    8022f0 <devcons_write+0x46>
		m = n - tot;
  8022c3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8022c6:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8022c8:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8022cb:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8022d0:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8022d3:	83 ec 04             	sub    $0x4,%esp
  8022d6:	53                   	push   %ebx
  8022d7:	03 45 0c             	add    0xc(%ebp),%eax
  8022da:	50                   	push   %eax
  8022db:	57                   	push   %edi
  8022dc:	e8 53 e7 ff ff       	call   800a34 <memmove>
		sys_cputs(buf, m);
  8022e1:	83 c4 08             	add    $0x8,%esp
  8022e4:	53                   	push   %ebx
  8022e5:	57                   	push   %edi
  8022e6:	e8 fe e8 ff ff       	call   800be9 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022eb:	01 de                	add    %ebx,%esi
  8022ed:	83 c4 10             	add    $0x10,%esp
  8022f0:	89 f0                	mov    %esi,%eax
  8022f2:	3b 75 10             	cmp    0x10(%ebp),%esi
  8022f5:	72 cc                	jb     8022c3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8022f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022fa:	5b                   	pop    %ebx
  8022fb:	5e                   	pop    %esi
  8022fc:	5f                   	pop    %edi
  8022fd:	5d                   	pop    %ebp
  8022fe:	c3                   	ret    

008022ff <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8022ff:	55                   	push   %ebp
  802300:	89 e5                	mov    %esp,%ebp
  802302:	83 ec 08             	sub    $0x8,%esp
  802305:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80230a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80230e:	74 2a                	je     80233a <devcons_read+0x3b>
  802310:	eb 05                	jmp    802317 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802312:	e8 6f e9 ff ff       	call   800c86 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802317:	e8 eb e8 ff ff       	call   800c07 <sys_cgetc>
  80231c:	85 c0                	test   %eax,%eax
  80231e:	74 f2                	je     802312 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802320:	85 c0                	test   %eax,%eax
  802322:	78 16                	js     80233a <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802324:	83 f8 04             	cmp    $0x4,%eax
  802327:	74 0c                	je     802335 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802329:	8b 55 0c             	mov    0xc(%ebp),%edx
  80232c:	88 02                	mov    %al,(%edx)
	return 1;
  80232e:	b8 01 00 00 00       	mov    $0x1,%eax
  802333:	eb 05                	jmp    80233a <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802335:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80233a:	c9                   	leave  
  80233b:	c3                   	ret    

0080233c <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80233c:	55                   	push   %ebp
  80233d:	89 e5                	mov    %esp,%ebp
  80233f:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802342:	8b 45 08             	mov    0x8(%ebp),%eax
  802345:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802348:	6a 01                	push   $0x1
  80234a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80234d:	50                   	push   %eax
  80234e:	e8 96 e8 ff ff       	call   800be9 <sys_cputs>
}
  802353:	83 c4 10             	add    $0x10,%esp
  802356:	c9                   	leave  
  802357:	c3                   	ret    

00802358 <getchar>:

int
getchar(void)
{
  802358:	55                   	push   %ebp
  802359:	89 e5                	mov    %esp,%ebp
  80235b:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80235e:	6a 01                	push   $0x1
  802360:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802363:	50                   	push   %eax
  802364:	6a 00                	push   $0x0
  802366:	e8 c5 f1 ff ff       	call   801530 <read>
	if (r < 0)
  80236b:	83 c4 10             	add    $0x10,%esp
  80236e:	85 c0                	test   %eax,%eax
  802370:	78 0f                	js     802381 <getchar+0x29>
		return r;
	if (r < 1)
  802372:	85 c0                	test   %eax,%eax
  802374:	7e 06                	jle    80237c <getchar+0x24>
		return -E_EOF;
	return c;
  802376:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80237a:	eb 05                	jmp    802381 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80237c:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802381:	c9                   	leave  
  802382:	c3                   	ret    

00802383 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802383:	55                   	push   %ebp
  802384:	89 e5                	mov    %esp,%ebp
  802386:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802389:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80238c:	50                   	push   %eax
  80238d:	ff 75 08             	pushl  0x8(%ebp)
  802390:	e8 35 ef ff ff       	call   8012ca <fd_lookup>
  802395:	83 c4 10             	add    $0x10,%esp
  802398:	85 c0                	test   %eax,%eax
  80239a:	78 11                	js     8023ad <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80239c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80239f:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8023a5:	39 10                	cmp    %edx,(%eax)
  8023a7:	0f 94 c0             	sete   %al
  8023aa:	0f b6 c0             	movzbl %al,%eax
}
  8023ad:	c9                   	leave  
  8023ae:	c3                   	ret    

008023af <opencons>:

int
opencons(void)
{
  8023af:	55                   	push   %ebp
  8023b0:	89 e5                	mov    %esp,%ebp
  8023b2:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8023b5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023b8:	50                   	push   %eax
  8023b9:	e8 bd ee ff ff       	call   80127b <fd_alloc>
  8023be:	83 c4 10             	add    $0x10,%esp
		return r;
  8023c1:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8023c3:	85 c0                	test   %eax,%eax
  8023c5:	78 3e                	js     802405 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8023c7:	83 ec 04             	sub    $0x4,%esp
  8023ca:	68 07 04 00 00       	push   $0x407
  8023cf:	ff 75 f4             	pushl  -0xc(%ebp)
  8023d2:	6a 00                	push   $0x0
  8023d4:	e8 cc e8 ff ff       	call   800ca5 <sys_page_alloc>
  8023d9:	83 c4 10             	add    $0x10,%esp
		return r;
  8023dc:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8023de:	85 c0                	test   %eax,%eax
  8023e0:	78 23                	js     802405 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8023e2:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8023e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023eb:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8023ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023f0:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8023f7:	83 ec 0c             	sub    $0xc,%esp
  8023fa:	50                   	push   %eax
  8023fb:	e8 54 ee ff ff       	call   801254 <fd2num>
  802400:	89 c2                	mov    %eax,%edx
  802402:	83 c4 10             	add    $0x10,%esp
}
  802405:	89 d0                	mov    %edx,%eax
  802407:	c9                   	leave  
  802408:	c3                   	ret    

00802409 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802409:	55                   	push   %ebp
  80240a:	89 e5                	mov    %esp,%ebp
  80240c:	53                   	push   %ebx
  80240d:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  802410:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802417:	75 28                	jne    802441 <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  802419:	e8 49 e8 ff ff       	call   800c67 <sys_getenvid>
  80241e:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_U | PTE_W);
  802420:	83 ec 04             	sub    $0x4,%esp
  802423:	6a 06                	push   $0x6
  802425:	68 00 f0 bf ee       	push   $0xeebff000
  80242a:	50                   	push   %eax
  80242b:	e8 75 e8 ff ff       	call   800ca5 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  802430:	83 c4 08             	add    $0x8,%esp
  802433:	68 4e 24 80 00       	push   $0x80244e
  802438:	53                   	push   %ebx
  802439:	e8 b2 e9 ff ff       	call   800df0 <sys_env_set_pgfault_upcall>
  80243e:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802441:	8b 45 08             	mov    0x8(%ebp),%eax
  802444:	a3 00 70 80 00       	mov    %eax,0x807000
}
  802449:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80244c:	c9                   	leave  
  80244d:	c3                   	ret    

0080244e <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80244e:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80244f:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802454:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802456:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	# My method is different. Copy the values to the other stack
	# in a convinient way, and then pop everything.
	movl %esp, %ebp		# ebp refers to the exception stack
  802459:	89 e5                	mov    %esp,%ebp
	movl 48(%ebp), %esp 	# go to other stack
  80245b:	8b 65 30             	mov    0x30(%ebp),%esp

	pushl 40(%ebp)		# eip - ORDER SWITCHED WITH EFLAGS
  80245e:	ff 75 28             	pushl  0x28(%ebp)
	pushl 44(%ebp)      	# eflags
  802461:	ff 75 2c             	pushl  0x2c(%ebp)
	pushl 36(%ebp)		# all the 8 remaining regs
  802464:	ff 75 24             	pushl  0x24(%ebp)
	pushl 32(%ebp)
  802467:	ff 75 20             	pushl  0x20(%ebp)
	pushl 28(%ebp)
  80246a:	ff 75 1c             	pushl  0x1c(%ebp)
	pushl 24(%ebp)
  80246d:	ff 75 18             	pushl  0x18(%ebp)
	pushl 20(%ebp)
  802470:	ff 75 14             	pushl  0x14(%ebp)
	pushl 16(%ebp)
  802473:	ff 75 10             	pushl  0x10(%ebp)
	pushl 12(%ebp)
  802476:	ff 75 0c             	pushl  0xc(%ebp)
	pushl 8(%ebp)
  802479:	ff 75 08             	pushl  0x8(%ebp)

	popal			# now just pop everything!
  80247c:	61                   	popa   
	popfl
  80247d:	9d                   	popf   
	ret
  80247e:	c3                   	ret    
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
