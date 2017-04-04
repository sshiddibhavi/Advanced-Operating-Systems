
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
  80003b:	68 40 22 80 00       	push   $0x802240
  800040:	e8 d8 02 00 00       	call   80031d <cprintf>
	if ((r = pipe(p)) < 0)
  800045:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800048:	89 04 24             	mov    %eax,(%esp)
  80004b:	e8 c9 1b 00 00       	call   801c19 <pipe>
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	85 c0                	test   %eax,%eax
  800055:	79 12                	jns    800069 <umain+0x36>
		panic("pipe: %e", r);
  800057:	50                   	push   %eax
  800058:	68 59 22 80 00       	push   $0x802259
  80005d:	6a 0d                	push   $0xd
  80005f:	68 62 22 80 00       	push   $0x802262
  800064:	e8 db 01 00 00       	call   800244 <_panic>
	max = 200;
	if ((r = fork()) < 0)
  800069:	e8 7b 0f 00 00       	call   800fe9 <fork>
  80006e:	89 c6                	mov    %eax,%esi
  800070:	85 c0                	test   %eax,%eax
  800072:	79 12                	jns    800086 <umain+0x53>
		panic("fork: %e", r);
  800074:	50                   	push   %eax
  800075:	68 d3 26 80 00       	push   $0x8026d3
  80007a:	6a 10                	push   $0x10
  80007c:	68 62 22 80 00       	push   $0x802262
  800081:	e8 be 01 00 00       	call   800244 <_panic>
	if (r == 0) {
  800086:	85 c0                	test   %eax,%eax
  800088:	75 55                	jne    8000df <umain+0xac>
		close(p[1]);
  80008a:	83 ec 0c             	sub    $0xc,%esp
  80008d:	ff 75 f4             	pushl  -0xc(%ebp)
  800090:	e8 df 12 00 00       	call   801374 <close>
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
  8000a3:	e8 c4 1c 00 00       	call   801d6c <pipeisclosed>
  8000a8:	83 c4 10             	add    $0x10,%esp
  8000ab:	85 c0                	test   %eax,%eax
  8000ad:	74 15                	je     8000c4 <umain+0x91>
				cprintf("RACE: pipe appears closed\n");
  8000af:	83 ec 0c             	sub    $0xc,%esp
  8000b2:	68 76 22 80 00       	push   $0x802276
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
  8000d7:	e8 02 10 00 00       	call   8010de <ipc_recv>
  8000dc:	83 c4 10             	add    $0x10,%esp
	}
	pid = r;
	cprintf("pid is %d\n", pid);
  8000df:	83 ec 08             	sub    $0x8,%esp
  8000e2:	56                   	push   %esi
  8000e3:	68 91 22 80 00       	push   $0x802291
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
  800103:	68 9c 22 80 00       	push   $0x80229c
  800108:	e8 10 02 00 00       	call   80031d <cprintf>
	dup(p[0], 10);
  80010d:	83 c4 08             	add    $0x8,%esp
  800110:	6a 0a                	push   $0xa
  800112:	ff 75 f0             	pushl  -0x10(%ebp)
  800115:	e8 aa 12 00 00       	call   8013c4 <dup>
	while (kid->env_status == ENV_RUNNABLE)
  80011a:	83 c4 10             	add    $0x10,%esp
  80011d:	6b de 7c             	imul   $0x7c,%esi,%ebx
  800120:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  800126:	eb 10                	jmp    800138 <umain+0x105>
		dup(p[0], 10);
  800128:	83 ec 08             	sub    $0x8,%esp
  80012b:	6a 0a                	push   $0xa
  80012d:	ff 75 f0             	pushl  -0x10(%ebp)
  800130:	e8 8f 12 00 00       	call   8013c4 <dup>
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
  800143:	68 a7 22 80 00       	push   $0x8022a7
  800148:	e8 d0 01 00 00       	call   80031d <cprintf>
	if (pipeisclosed(p[0]))
  80014d:	83 c4 04             	add    $0x4,%esp
  800150:	ff 75 f0             	pushl  -0x10(%ebp)
  800153:	e8 14 1c 00 00       	call   801d6c <pipeisclosed>
  800158:	83 c4 10             	add    $0x10,%esp
  80015b:	85 c0                	test   %eax,%eax
  80015d:	74 14                	je     800173 <umain+0x140>
		panic("somehow the other end of p[0] got closed!");
  80015f:	83 ec 04             	sub    $0x4,%esp
  800162:	68 00 23 80 00       	push   $0x802300
  800167:	6a 3a                	push   $0x3a
  800169:	68 62 22 80 00       	push   $0x802262
  80016e:	e8 d1 00 00 00       	call   800244 <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  800173:	83 ec 08             	sub    $0x8,%esp
  800176:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800179:	50                   	push   %eax
  80017a:	ff 75 f0             	pushl  -0x10(%ebp)
  80017d:	e8 c8 10 00 00       	call   80124a <fd_lookup>
  800182:	83 c4 10             	add    $0x10,%esp
  800185:	85 c0                	test   %eax,%eax
  800187:	79 12                	jns    80019b <umain+0x168>
		panic("cannot look up p[0]: %e", r);
  800189:	50                   	push   %eax
  80018a:	68 bd 22 80 00       	push   $0x8022bd
  80018f:	6a 3c                	push   $0x3c
  800191:	68 62 22 80 00       	push   $0x802262
  800196:	e8 a9 00 00 00       	call   800244 <_panic>
	va = fd2data(fd);
  80019b:	83 ec 0c             	sub    $0xc,%esp
  80019e:	ff 75 ec             	pushl  -0x14(%ebp)
  8001a1:	e8 3e 10 00 00       	call   8011e4 <fd2data>
	if (pageref(va) != 3+1)
  8001a6:	89 04 24             	mov    %eax,(%esp)
  8001a9:	e8 5a 18 00 00       	call   801a08 <pageref>
  8001ae:	83 c4 10             	add    $0x10,%esp
  8001b1:	83 f8 04             	cmp    $0x4,%eax
  8001b4:	74 12                	je     8001c8 <umain+0x195>
		cprintf("\nchild detected race\n");
  8001b6:	83 ec 0c             	sub    $0xc,%esp
  8001b9:	68 d5 22 80 00       	push   $0x8022d5
  8001be:	e8 5a 01 00 00       	call   80031d <cprintf>
  8001c3:	83 c4 10             	add    $0x10,%esp
  8001c6:	eb 15                	jmp    8001dd <umain+0x1aa>
	else
		cprintf("\nrace didn't happen\n", max);
  8001c8:	83 ec 08             	sub    $0x8,%esp
  8001cb:	68 c8 00 00 00       	push   $0xc8
  8001d0:	68 eb 22 80 00       	push   $0x8022eb
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
  800201:	a3 04 40 80 00       	mov    %eax,0x804004

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
  800230:	e8 6a 11 00 00       	call   80139f <close_all>
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
  800262:	68 34 23 80 00       	push   $0x802334
  800267:	e8 b1 00 00 00       	call   80031d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80026c:	83 c4 18             	add    $0x18,%esp
  80026f:	53                   	push   %ebx
  800270:	ff 75 10             	pushl  0x10(%ebp)
  800273:	e8 54 00 00 00       	call   8002cc <vcprintf>
	cprintf("\n");
  800278:	c7 04 24 57 22 80 00 	movl   $0x802257,(%esp)
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
  800380:	e8 1b 1c 00 00       	call   801fa0 <__udivdi3>
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
  8003c3:	e8 08 1d 00 00       	call   8020d0 <__umoddi3>
  8003c8:	83 c4 14             	add    $0x14,%esp
  8003cb:	0f be 80 57 23 80 00 	movsbl 0x802357(%eax),%eax
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
  8004c7:	ff 24 85 a0 24 80 00 	jmp    *0x8024a0(,%eax,4)
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
  80058b:	8b 14 85 00 26 80 00 	mov    0x802600(,%eax,4),%edx
  800592:	85 d2                	test   %edx,%edx
  800594:	75 18                	jne    8005ae <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800596:	50                   	push   %eax
  800597:	68 6f 23 80 00       	push   $0x80236f
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
  8005af:	68 02 28 80 00       	push   $0x802802
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
  8005d3:	b8 68 23 80 00       	mov    $0x802368,%eax
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
  800c4e:	68 5f 26 80 00       	push   $0x80265f
  800c53:	6a 23                	push   $0x23
  800c55:	68 7c 26 80 00       	push   $0x80267c
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
  800ccf:	68 5f 26 80 00       	push   $0x80265f
  800cd4:	6a 23                	push   $0x23
  800cd6:	68 7c 26 80 00       	push   $0x80267c
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
  800d11:	68 5f 26 80 00       	push   $0x80265f
  800d16:	6a 23                	push   $0x23
  800d18:	68 7c 26 80 00       	push   $0x80267c
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
  800d53:	68 5f 26 80 00       	push   $0x80265f
  800d58:	6a 23                	push   $0x23
  800d5a:	68 7c 26 80 00       	push   $0x80267c
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
  800d95:	68 5f 26 80 00       	push   $0x80265f
  800d9a:	6a 23                	push   $0x23
  800d9c:	68 7c 26 80 00       	push   $0x80267c
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
  800dd7:	68 5f 26 80 00       	push   $0x80265f
  800ddc:	6a 23                	push   $0x23
  800dde:	68 7c 26 80 00       	push   $0x80267c
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
  800e19:	68 5f 26 80 00       	push   $0x80265f
  800e1e:	6a 23                	push   $0x23
  800e20:	68 7c 26 80 00       	push   $0x80267c
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
  800e7d:	68 5f 26 80 00       	push   $0x80265f
  800e82:	6a 23                	push   $0x23
  800e84:	68 7c 26 80 00       	push   $0x80267c
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

00800e96 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800e96:	55                   	push   %ebp
  800e97:	89 e5                	mov    %esp,%ebp
  800e99:	56                   	push   %esi
  800e9a:	53                   	push   %ebx
	int r;

	// LAB 4: Your code here.
	// Check if page is writable or COW
	pte_t pte = uvpt[pn];
  800e9b:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
	uint32_t perm = PTE_P | PTE_U;
	if (pte && (PTE_COW | PTE_W)) {
		perm |= PTE_COW;
  800ea2:	83 f9 01             	cmp    $0x1,%ecx
  800ea5:	19 f6                	sbb    %esi,%esi
  800ea7:	81 e6 00 f8 ff ff    	and    $0xfffff800,%esi
  800ead:	81 c6 05 08 00 00    	add    $0x805,%esi
	}

	// Map page
	void *va = (void *) (pn * PGSIZE);
  800eb3:	c1 e2 0c             	shl    $0xc,%edx
  800eb6:	89 d3                	mov    %edx,%ebx
	// Map on the child
	if ((r = sys_page_map(0, va, envid, va, perm)) < 0) {
  800eb8:	83 ec 0c             	sub    $0xc,%esp
  800ebb:	56                   	push   %esi
  800ebc:	52                   	push   %edx
  800ebd:	50                   	push   %eax
  800ebe:	52                   	push   %edx
  800ebf:	6a 00                	push   $0x0
  800ec1:	e8 22 fe ff ff       	call   800ce8 <sys_page_map>
  800ec6:	83 c4 20             	add    $0x20,%esp
  800ec9:	85 c0                	test   %eax,%eax
  800ecb:	79 12                	jns    800edf <duppage+0x49>
		panic("sys_page_alloc: %e", r);
  800ecd:	50                   	push   %eax
  800ece:	68 8a 26 80 00       	push   $0x80268a
  800ed3:	6a 56                	push   $0x56
  800ed5:	68 9d 26 80 00       	push   $0x80269d
  800eda:	e8 65 f3 ff ff       	call   800244 <_panic>
		return r;
	}

	// Change the permission on the parent
	if ((r = sys_page_map(0, va, 0, va, perm)) < 0) {
  800edf:	83 ec 0c             	sub    $0xc,%esp
  800ee2:	56                   	push   %esi
  800ee3:	53                   	push   %ebx
  800ee4:	6a 00                	push   $0x0
  800ee6:	53                   	push   %ebx
  800ee7:	6a 00                	push   $0x0
  800ee9:	e8 fa fd ff ff       	call   800ce8 <sys_page_map>
  800eee:	83 c4 20             	add    $0x20,%esp
  800ef1:	85 c0                	test   %eax,%eax
  800ef3:	79 12                	jns    800f07 <duppage+0x71>
		panic("sys_page_alloc: %e", r);
  800ef5:	50                   	push   %eax
  800ef6:	68 8a 26 80 00       	push   $0x80268a
  800efb:	6a 5c                	push   $0x5c
  800efd:	68 9d 26 80 00       	push   $0x80269d
  800f02:	e8 3d f3 ff ff       	call   800244 <_panic>
		return r;
	}

	return 0;
}
  800f07:	b8 00 00 00 00       	mov    $0x0,%eax
  800f0c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f0f:	5b                   	pop    %ebx
  800f10:	5e                   	pop    %esi
  800f11:	5d                   	pop    %ebp
  800f12:	c3                   	ret    

00800f13 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f13:	55                   	push   %ebp
  800f14:	89 e5                	mov    %esp,%ebp
  800f16:	53                   	push   %ebx
  800f17:	83 ec 04             	sub    $0x4,%esp
  800f1a:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f1d:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	unsigned pn = ((uint32_t)addr)/PGSIZE;
  800f1f:	89 da                	mov    %ebx,%edx
  800f21:	c1 ea 0c             	shr    $0xc,%edx
	pte_t pte = uvpt[pn];
  800f24:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(err & FEC_WR) || !(pte & PTE_COW)) {
  800f2b:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f2f:	74 05                	je     800f36 <pgfault+0x23>
  800f31:	f6 c6 08             	test   $0x8,%dh
  800f34:	75 14                	jne    800f4a <pgfault+0x37>
		panic("fork pgfault handler: does not handle this fault");
  800f36:	83 ec 04             	sub    $0x4,%esp
  800f39:	68 0c 27 80 00       	push   $0x80270c
  800f3e:	6a 1f                	push   $0x1f
  800f40:	68 9d 26 80 00       	push   $0x80269d
  800f45:	e8 fa f2 ff ff       	call   800244 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// Allocate a new page, mapped at temp location
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  800f4a:	83 ec 04             	sub    $0x4,%esp
  800f4d:	6a 07                	push   $0x7
  800f4f:	68 00 f0 7f 00       	push   $0x7ff000
  800f54:	6a 00                	push   $0x0
  800f56:	e8 4a fd ff ff       	call   800ca5 <sys_page_alloc>
  800f5b:	83 c4 10             	add    $0x10,%esp
  800f5e:	85 c0                	test   %eax,%eax
  800f60:	79 12                	jns    800f74 <pgfault+0x61>
		panic("sys_page_alloc: %e", r);
  800f62:	50                   	push   %eax
  800f63:	68 8a 26 80 00       	push   $0x80268a
  800f68:	6a 2b                	push   $0x2b
  800f6a:	68 9d 26 80 00       	push   $0x80269d
  800f6f:	e8 d0 f2 ff ff       	call   800244 <_panic>

	// Copy the data from the old page to this new page
	void *addr_pgstart = (void *) ROUNDDOWN(addr, PGSIZE);
  800f74:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr_pgstart, PGSIZE);
  800f7a:	83 ec 04             	sub    $0x4,%esp
  800f7d:	68 00 10 00 00       	push   $0x1000
  800f82:	53                   	push   %ebx
  800f83:	68 00 f0 7f 00       	push   $0x7ff000
  800f88:	e8 a7 fa ff ff       	call   800a34 <memmove>

	// Move the new page to the old page's address
	if ((r = sys_page_map(0, PFTEMP, 0, addr_pgstart, PTE_P|PTE_U|PTE_W)) < 0)
  800f8d:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f94:	53                   	push   %ebx
  800f95:	6a 00                	push   $0x0
  800f97:	68 00 f0 7f 00       	push   $0x7ff000
  800f9c:	6a 00                	push   $0x0
  800f9e:	e8 45 fd ff ff       	call   800ce8 <sys_page_map>
  800fa3:	83 c4 20             	add    $0x20,%esp
  800fa6:	85 c0                	test   %eax,%eax
  800fa8:	79 12                	jns    800fbc <pgfault+0xa9>
		panic("sys_page_map: %e", r);
  800faa:	50                   	push   %eax
  800fab:	68 a8 26 80 00       	push   $0x8026a8
  800fb0:	6a 33                	push   $0x33
  800fb2:	68 9d 26 80 00       	push   $0x80269d
  800fb7:	e8 88 f2 ff ff       	call   800244 <_panic>

	// Unmap the temp location
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800fbc:	83 ec 08             	sub    $0x8,%esp
  800fbf:	68 00 f0 7f 00       	push   $0x7ff000
  800fc4:	6a 00                	push   $0x0
  800fc6:	e8 5f fd ff ff       	call   800d2a <sys_page_unmap>
  800fcb:	83 c4 10             	add    $0x10,%esp
  800fce:	85 c0                	test   %eax,%eax
  800fd0:	79 12                	jns    800fe4 <pgfault+0xd1>
		panic("sys_page_unmap: %e", r);
  800fd2:	50                   	push   %eax
  800fd3:	68 b9 26 80 00       	push   $0x8026b9
  800fd8:	6a 37                	push   $0x37
  800fda:	68 9d 26 80 00       	push   $0x80269d
  800fdf:	e8 60 f2 ff ff       	call   800244 <_panic>
}
  800fe4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fe7:	c9                   	leave  
  800fe8:	c3                   	ret    

00800fe9 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fe9:	55                   	push   %ebp
  800fea:	89 e5                	mov    %esp,%ebp
  800fec:	56                   	push   %esi
  800fed:	53                   	push   %ebx
  800fee:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
	// Set up page fault handler
	set_pgfault_handler(&pgfault);
  800ff1:	68 13 0f 80 00       	push   $0x800f13
  800ff6:	e8 27 0f 00 00       	call   801f22 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800ffb:	b8 07 00 00 00       	mov    $0x7,%eax
  801000:	cd 30                	int    $0x30

	// Create child
	envid_t envid = sys_exofork();
  801002:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (envid < 0) {
  801005:	83 c4 10             	add    $0x10,%esp
  801008:	85 c0                	test   %eax,%eax
  80100a:	79 12                	jns    80101e <fork+0x35>
		panic("sys_exofork: %e", envid);
  80100c:	50                   	push   %eax
  80100d:	68 cc 26 80 00       	push   $0x8026cc
  801012:	6a 7d                	push   $0x7d
  801014:	68 9d 26 80 00       	push   $0x80269d
  801019:	e8 26 f2 ff ff       	call   800244 <_panic>
		return envid;
	}
	if (envid == 0) {
  80101e:	85 c0                	test   %eax,%eax
  801020:	75 1e                	jne    801040 <fork+0x57>
		// We are the child.
		thisenv = &envs[ENVX(sys_getenvid())]; // Fix thisenv
  801022:	e8 40 fc ff ff       	call   800c67 <sys_getenvid>
  801027:	25 ff 03 00 00       	and    $0x3ff,%eax
  80102c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80102f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801034:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  801039:	b8 00 00 00 00       	mov    $0x0,%eax
  80103e:	eb 7d                	jmp    8010bd <fork+0xd4>

	// Set page fault handler on the child.
	// The parent needs to do it, else the child wouldn't be able to handle
	// the fault when trying to access it's stack (which happens as soon it starts)
	extern void _pgfault_upcall(void);
	sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);
  801040:	83 ec 04             	sub    $0x4,%esp
  801043:	6a 07                	push   $0x7
  801045:	68 00 f0 bf ee       	push   $0xeebff000
  80104a:	50                   	push   %eax
  80104b:	e8 55 fc ff ff       	call   800ca5 <sys_page_alloc>
	sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  801050:	83 c4 08             	add    $0x8,%esp
  801053:	68 67 1f 80 00       	push   $0x801f67
  801058:	ff 75 f4             	pushl  -0xc(%ebp)
  80105b:	e8 90 fd ff ff       	call   800df0 <sys_env_set_pgfault_upcall>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  801060:	be 04 60 80 00       	mov    $0x806004,%esi
  801065:	c1 ee 0c             	shr    $0xc,%esi
  801068:	83 c4 10             	add    $0x10,%esp
  80106b:	bb 00 08 00 00       	mov    $0x800,%ebx
  801070:	eb 0d                	jmp    80107f <fork+0x96>
		duppage(envid, pn);
  801072:	89 da                	mov    %ebx,%edx
  801074:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801077:	e8 1a fe ff ff       	call   800e96 <duppage>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  80107c:	83 c3 01             	add    $0x1,%ebx
  80107f:	39 f3                	cmp    %esi,%ebx
  801081:	76 ef                	jbe    801072 <fork+0x89>
	}

	// Also copy the stack we are currently running on
	// I think it should loop from ustacktop to this page, since the stack
	// can have more than 1 page
	duppage(envid, ((uint32_t) &envid)/PGSIZE);
  801083:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801086:	c1 ea 0c             	shr    $0xc,%edx
  801089:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80108c:	e8 05 fe ff ff       	call   800e96 <duppage>

	// Start the child environmnet running
	int r;
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  801091:	83 ec 08             	sub    $0x8,%esp
  801094:	6a 02                	push   $0x2
  801096:	ff 75 f4             	pushl  -0xc(%ebp)
  801099:	e8 ce fc ff ff       	call   800d6c <sys_env_set_status>
  80109e:	83 c4 10             	add    $0x10,%esp
  8010a1:	85 c0                	test   %eax,%eax
  8010a3:	79 15                	jns    8010ba <fork+0xd1>
		panic("sys_env_set_status: %e", r);
  8010a5:	50                   	push   %eax
  8010a6:	68 dc 26 80 00       	push   $0x8026dc
  8010ab:	68 9d 00 00 00       	push   $0x9d
  8010b0:	68 9d 26 80 00       	push   $0x80269d
  8010b5:	e8 8a f1 ff ff       	call   800244 <_panic>
		return r;
	}

	return envid;
  8010ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8010bd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010c0:	5b                   	pop    %ebx
  8010c1:	5e                   	pop    %esi
  8010c2:	5d                   	pop    %ebp
  8010c3:	c3                   	ret    

008010c4 <sfork>:

// Challenge!
int
sfork(void)
{
  8010c4:	55                   	push   %ebp
  8010c5:	89 e5                	mov    %esp,%ebp
  8010c7:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010ca:	68 f3 26 80 00       	push   $0x8026f3
  8010cf:	68 a8 00 00 00       	push   $0xa8
  8010d4:	68 9d 26 80 00       	push   $0x80269d
  8010d9:	e8 66 f1 ff ff       	call   800244 <_panic>

008010de <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8010de:	55                   	push   %ebp
  8010df:	89 e5                	mov    %esp,%ebp
  8010e1:	56                   	push   %esi
  8010e2:	53                   	push   %ebx
  8010e3:	8b 75 08             	mov    0x8(%ebp),%esi
  8010e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010e9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  8010ec:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  8010ee:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  8010f3:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  8010f6:	83 ec 0c             	sub    $0xc,%esp
  8010f9:	50                   	push   %eax
  8010fa:	e8 56 fd ff ff       	call   800e55 <sys_ipc_recv>

	if (r < 0) {
  8010ff:	83 c4 10             	add    $0x10,%esp
  801102:	85 c0                	test   %eax,%eax
  801104:	79 16                	jns    80111c <ipc_recv+0x3e>
		if (from_env_store)
  801106:	85 f6                	test   %esi,%esi
  801108:	74 06                	je     801110 <ipc_recv+0x32>
			*from_env_store = 0;
  80110a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  801110:	85 db                	test   %ebx,%ebx
  801112:	74 2c                	je     801140 <ipc_recv+0x62>
			*perm_store = 0;
  801114:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80111a:	eb 24                	jmp    801140 <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  80111c:	85 f6                	test   %esi,%esi
  80111e:	74 0a                	je     80112a <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  801120:	a1 04 40 80 00       	mov    0x804004,%eax
  801125:	8b 40 74             	mov    0x74(%eax),%eax
  801128:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  80112a:	85 db                	test   %ebx,%ebx
  80112c:	74 0a                	je     801138 <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  80112e:	a1 04 40 80 00       	mov    0x804004,%eax
  801133:	8b 40 78             	mov    0x78(%eax),%eax
  801136:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  801138:	a1 04 40 80 00       	mov    0x804004,%eax
  80113d:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  801140:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801143:	5b                   	pop    %ebx
  801144:	5e                   	pop    %esi
  801145:	5d                   	pop    %ebp
  801146:	c3                   	ret    

00801147 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801147:	55                   	push   %ebp
  801148:	89 e5                	mov    %esp,%ebp
  80114a:	57                   	push   %edi
  80114b:	56                   	push   %esi
  80114c:	53                   	push   %ebx
  80114d:	83 ec 0c             	sub    $0xc,%esp
  801150:	8b 7d 08             	mov    0x8(%ebp),%edi
  801153:	8b 75 0c             	mov    0xc(%ebp),%esi
  801156:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  801159:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  80115b:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801160:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  801163:	ff 75 14             	pushl  0x14(%ebp)
  801166:	53                   	push   %ebx
  801167:	56                   	push   %esi
  801168:	57                   	push   %edi
  801169:	e8 c4 fc ff ff       	call   800e32 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  80116e:	83 c4 10             	add    $0x10,%esp
  801171:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801174:	75 07                	jne    80117d <ipc_send+0x36>
			sys_yield();
  801176:	e8 0b fb ff ff       	call   800c86 <sys_yield>
  80117b:	eb e6                	jmp    801163 <ipc_send+0x1c>
		} else if (r < 0) {
  80117d:	85 c0                	test   %eax,%eax
  80117f:	79 12                	jns    801193 <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  801181:	50                   	push   %eax
  801182:	68 3d 27 80 00       	push   $0x80273d
  801187:	6a 51                	push   $0x51
  801189:	68 4a 27 80 00       	push   $0x80274a
  80118e:	e8 b1 f0 ff ff       	call   800244 <_panic>
		}
	}
}
  801193:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801196:	5b                   	pop    %ebx
  801197:	5e                   	pop    %esi
  801198:	5f                   	pop    %edi
  801199:	5d                   	pop    %ebp
  80119a:	c3                   	ret    

0080119b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80119b:	55                   	push   %ebp
  80119c:	89 e5                	mov    %esp,%ebp
  80119e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8011a1:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8011a6:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8011a9:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8011af:	8b 52 50             	mov    0x50(%edx),%edx
  8011b2:	39 ca                	cmp    %ecx,%edx
  8011b4:	75 0d                	jne    8011c3 <ipc_find_env+0x28>
			return envs[i].env_id;
  8011b6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8011b9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011be:	8b 40 48             	mov    0x48(%eax),%eax
  8011c1:	eb 0f                	jmp    8011d2 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8011c3:	83 c0 01             	add    $0x1,%eax
  8011c6:	3d 00 04 00 00       	cmp    $0x400,%eax
  8011cb:	75 d9                	jne    8011a6 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8011cd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011d2:	5d                   	pop    %ebp
  8011d3:	c3                   	ret    

008011d4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011d4:	55                   	push   %ebp
  8011d5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8011da:	05 00 00 00 30       	add    $0x30000000,%eax
  8011df:	c1 e8 0c             	shr    $0xc,%eax
}
  8011e2:	5d                   	pop    %ebp
  8011e3:	c3                   	ret    

008011e4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011e4:	55                   	push   %ebp
  8011e5:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ea:	05 00 00 00 30       	add    $0x30000000,%eax
  8011ef:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011f4:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011f9:	5d                   	pop    %ebp
  8011fa:	c3                   	ret    

008011fb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011fb:	55                   	push   %ebp
  8011fc:	89 e5                	mov    %esp,%ebp
  8011fe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801201:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801206:	89 c2                	mov    %eax,%edx
  801208:	c1 ea 16             	shr    $0x16,%edx
  80120b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801212:	f6 c2 01             	test   $0x1,%dl
  801215:	74 11                	je     801228 <fd_alloc+0x2d>
  801217:	89 c2                	mov    %eax,%edx
  801219:	c1 ea 0c             	shr    $0xc,%edx
  80121c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801223:	f6 c2 01             	test   $0x1,%dl
  801226:	75 09                	jne    801231 <fd_alloc+0x36>
			*fd_store = fd;
  801228:	89 01                	mov    %eax,(%ecx)
			return 0;
  80122a:	b8 00 00 00 00       	mov    $0x0,%eax
  80122f:	eb 17                	jmp    801248 <fd_alloc+0x4d>
  801231:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801236:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80123b:	75 c9                	jne    801206 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80123d:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801243:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801248:	5d                   	pop    %ebp
  801249:	c3                   	ret    

0080124a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80124a:	55                   	push   %ebp
  80124b:	89 e5                	mov    %esp,%ebp
  80124d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801250:	83 f8 1f             	cmp    $0x1f,%eax
  801253:	77 36                	ja     80128b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801255:	c1 e0 0c             	shl    $0xc,%eax
  801258:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80125d:	89 c2                	mov    %eax,%edx
  80125f:	c1 ea 16             	shr    $0x16,%edx
  801262:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801269:	f6 c2 01             	test   $0x1,%dl
  80126c:	74 24                	je     801292 <fd_lookup+0x48>
  80126e:	89 c2                	mov    %eax,%edx
  801270:	c1 ea 0c             	shr    $0xc,%edx
  801273:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80127a:	f6 c2 01             	test   $0x1,%dl
  80127d:	74 1a                	je     801299 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80127f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801282:	89 02                	mov    %eax,(%edx)
	return 0;
  801284:	b8 00 00 00 00       	mov    $0x0,%eax
  801289:	eb 13                	jmp    80129e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80128b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801290:	eb 0c                	jmp    80129e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801292:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801297:	eb 05                	jmp    80129e <fd_lookup+0x54>
  801299:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80129e:	5d                   	pop    %ebp
  80129f:	c3                   	ret    

008012a0 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012a0:	55                   	push   %ebp
  8012a1:	89 e5                	mov    %esp,%ebp
  8012a3:	83 ec 08             	sub    $0x8,%esp
  8012a6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012a9:	ba d4 27 80 00       	mov    $0x8027d4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012ae:	eb 13                	jmp    8012c3 <dev_lookup+0x23>
  8012b0:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8012b3:	39 08                	cmp    %ecx,(%eax)
  8012b5:	75 0c                	jne    8012c3 <dev_lookup+0x23>
			*dev = devtab[i];
  8012b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012ba:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8012c1:	eb 2e                	jmp    8012f1 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012c3:	8b 02                	mov    (%edx),%eax
  8012c5:	85 c0                	test   %eax,%eax
  8012c7:	75 e7                	jne    8012b0 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012c9:	a1 04 40 80 00       	mov    0x804004,%eax
  8012ce:	8b 40 48             	mov    0x48(%eax),%eax
  8012d1:	83 ec 04             	sub    $0x4,%esp
  8012d4:	51                   	push   %ecx
  8012d5:	50                   	push   %eax
  8012d6:	68 54 27 80 00       	push   $0x802754
  8012db:	e8 3d f0 ff ff       	call   80031d <cprintf>
	*dev = 0;
  8012e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012e3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012e9:	83 c4 10             	add    $0x10,%esp
  8012ec:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012f1:	c9                   	leave  
  8012f2:	c3                   	ret    

008012f3 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012f3:	55                   	push   %ebp
  8012f4:	89 e5                	mov    %esp,%ebp
  8012f6:	56                   	push   %esi
  8012f7:	53                   	push   %ebx
  8012f8:	83 ec 10             	sub    $0x10,%esp
  8012fb:	8b 75 08             	mov    0x8(%ebp),%esi
  8012fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801301:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801304:	50                   	push   %eax
  801305:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80130b:	c1 e8 0c             	shr    $0xc,%eax
  80130e:	50                   	push   %eax
  80130f:	e8 36 ff ff ff       	call   80124a <fd_lookup>
  801314:	83 c4 08             	add    $0x8,%esp
  801317:	85 c0                	test   %eax,%eax
  801319:	78 05                	js     801320 <fd_close+0x2d>
	    || fd != fd2)
  80131b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80131e:	74 0c                	je     80132c <fd_close+0x39>
		return (must_exist ? r : 0);
  801320:	84 db                	test   %bl,%bl
  801322:	ba 00 00 00 00       	mov    $0x0,%edx
  801327:	0f 44 c2             	cmove  %edx,%eax
  80132a:	eb 41                	jmp    80136d <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80132c:	83 ec 08             	sub    $0x8,%esp
  80132f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801332:	50                   	push   %eax
  801333:	ff 36                	pushl  (%esi)
  801335:	e8 66 ff ff ff       	call   8012a0 <dev_lookup>
  80133a:	89 c3                	mov    %eax,%ebx
  80133c:	83 c4 10             	add    $0x10,%esp
  80133f:	85 c0                	test   %eax,%eax
  801341:	78 1a                	js     80135d <fd_close+0x6a>
		if (dev->dev_close)
  801343:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801346:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801349:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80134e:	85 c0                	test   %eax,%eax
  801350:	74 0b                	je     80135d <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801352:	83 ec 0c             	sub    $0xc,%esp
  801355:	56                   	push   %esi
  801356:	ff d0                	call   *%eax
  801358:	89 c3                	mov    %eax,%ebx
  80135a:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80135d:	83 ec 08             	sub    $0x8,%esp
  801360:	56                   	push   %esi
  801361:	6a 00                	push   $0x0
  801363:	e8 c2 f9 ff ff       	call   800d2a <sys_page_unmap>
	return r;
  801368:	83 c4 10             	add    $0x10,%esp
  80136b:	89 d8                	mov    %ebx,%eax
}
  80136d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801370:	5b                   	pop    %ebx
  801371:	5e                   	pop    %esi
  801372:	5d                   	pop    %ebp
  801373:	c3                   	ret    

00801374 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801374:	55                   	push   %ebp
  801375:	89 e5                	mov    %esp,%ebp
  801377:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80137a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80137d:	50                   	push   %eax
  80137e:	ff 75 08             	pushl  0x8(%ebp)
  801381:	e8 c4 fe ff ff       	call   80124a <fd_lookup>
  801386:	83 c4 08             	add    $0x8,%esp
  801389:	85 c0                	test   %eax,%eax
  80138b:	78 10                	js     80139d <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80138d:	83 ec 08             	sub    $0x8,%esp
  801390:	6a 01                	push   $0x1
  801392:	ff 75 f4             	pushl  -0xc(%ebp)
  801395:	e8 59 ff ff ff       	call   8012f3 <fd_close>
  80139a:	83 c4 10             	add    $0x10,%esp
}
  80139d:	c9                   	leave  
  80139e:	c3                   	ret    

0080139f <close_all>:

void
close_all(void)
{
  80139f:	55                   	push   %ebp
  8013a0:	89 e5                	mov    %esp,%ebp
  8013a2:	53                   	push   %ebx
  8013a3:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013a6:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013ab:	83 ec 0c             	sub    $0xc,%esp
  8013ae:	53                   	push   %ebx
  8013af:	e8 c0 ff ff ff       	call   801374 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013b4:	83 c3 01             	add    $0x1,%ebx
  8013b7:	83 c4 10             	add    $0x10,%esp
  8013ba:	83 fb 20             	cmp    $0x20,%ebx
  8013bd:	75 ec                	jne    8013ab <close_all+0xc>
		close(i);
}
  8013bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013c2:	c9                   	leave  
  8013c3:	c3                   	ret    

008013c4 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013c4:	55                   	push   %ebp
  8013c5:	89 e5                	mov    %esp,%ebp
  8013c7:	57                   	push   %edi
  8013c8:	56                   	push   %esi
  8013c9:	53                   	push   %ebx
  8013ca:	83 ec 2c             	sub    $0x2c,%esp
  8013cd:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013d0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013d3:	50                   	push   %eax
  8013d4:	ff 75 08             	pushl  0x8(%ebp)
  8013d7:	e8 6e fe ff ff       	call   80124a <fd_lookup>
  8013dc:	83 c4 08             	add    $0x8,%esp
  8013df:	85 c0                	test   %eax,%eax
  8013e1:	0f 88 c1 00 00 00    	js     8014a8 <dup+0xe4>
		return r;
	close(newfdnum);
  8013e7:	83 ec 0c             	sub    $0xc,%esp
  8013ea:	56                   	push   %esi
  8013eb:	e8 84 ff ff ff       	call   801374 <close>

	newfd = INDEX2FD(newfdnum);
  8013f0:	89 f3                	mov    %esi,%ebx
  8013f2:	c1 e3 0c             	shl    $0xc,%ebx
  8013f5:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013fb:	83 c4 04             	add    $0x4,%esp
  8013fe:	ff 75 e4             	pushl  -0x1c(%ebp)
  801401:	e8 de fd ff ff       	call   8011e4 <fd2data>
  801406:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801408:	89 1c 24             	mov    %ebx,(%esp)
  80140b:	e8 d4 fd ff ff       	call   8011e4 <fd2data>
  801410:	83 c4 10             	add    $0x10,%esp
  801413:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801416:	89 f8                	mov    %edi,%eax
  801418:	c1 e8 16             	shr    $0x16,%eax
  80141b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801422:	a8 01                	test   $0x1,%al
  801424:	74 37                	je     80145d <dup+0x99>
  801426:	89 f8                	mov    %edi,%eax
  801428:	c1 e8 0c             	shr    $0xc,%eax
  80142b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801432:	f6 c2 01             	test   $0x1,%dl
  801435:	74 26                	je     80145d <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801437:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80143e:	83 ec 0c             	sub    $0xc,%esp
  801441:	25 07 0e 00 00       	and    $0xe07,%eax
  801446:	50                   	push   %eax
  801447:	ff 75 d4             	pushl  -0x2c(%ebp)
  80144a:	6a 00                	push   $0x0
  80144c:	57                   	push   %edi
  80144d:	6a 00                	push   $0x0
  80144f:	e8 94 f8 ff ff       	call   800ce8 <sys_page_map>
  801454:	89 c7                	mov    %eax,%edi
  801456:	83 c4 20             	add    $0x20,%esp
  801459:	85 c0                	test   %eax,%eax
  80145b:	78 2e                	js     80148b <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80145d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801460:	89 d0                	mov    %edx,%eax
  801462:	c1 e8 0c             	shr    $0xc,%eax
  801465:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80146c:	83 ec 0c             	sub    $0xc,%esp
  80146f:	25 07 0e 00 00       	and    $0xe07,%eax
  801474:	50                   	push   %eax
  801475:	53                   	push   %ebx
  801476:	6a 00                	push   $0x0
  801478:	52                   	push   %edx
  801479:	6a 00                	push   $0x0
  80147b:	e8 68 f8 ff ff       	call   800ce8 <sys_page_map>
  801480:	89 c7                	mov    %eax,%edi
  801482:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801485:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801487:	85 ff                	test   %edi,%edi
  801489:	79 1d                	jns    8014a8 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80148b:	83 ec 08             	sub    $0x8,%esp
  80148e:	53                   	push   %ebx
  80148f:	6a 00                	push   $0x0
  801491:	e8 94 f8 ff ff       	call   800d2a <sys_page_unmap>
	sys_page_unmap(0, nva);
  801496:	83 c4 08             	add    $0x8,%esp
  801499:	ff 75 d4             	pushl  -0x2c(%ebp)
  80149c:	6a 00                	push   $0x0
  80149e:	e8 87 f8 ff ff       	call   800d2a <sys_page_unmap>
	return r;
  8014a3:	83 c4 10             	add    $0x10,%esp
  8014a6:	89 f8                	mov    %edi,%eax
}
  8014a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014ab:	5b                   	pop    %ebx
  8014ac:	5e                   	pop    %esi
  8014ad:	5f                   	pop    %edi
  8014ae:	5d                   	pop    %ebp
  8014af:	c3                   	ret    

008014b0 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014b0:	55                   	push   %ebp
  8014b1:	89 e5                	mov    %esp,%ebp
  8014b3:	53                   	push   %ebx
  8014b4:	83 ec 14             	sub    $0x14,%esp
  8014b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014ba:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014bd:	50                   	push   %eax
  8014be:	53                   	push   %ebx
  8014bf:	e8 86 fd ff ff       	call   80124a <fd_lookup>
  8014c4:	83 c4 08             	add    $0x8,%esp
  8014c7:	89 c2                	mov    %eax,%edx
  8014c9:	85 c0                	test   %eax,%eax
  8014cb:	78 6d                	js     80153a <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014cd:	83 ec 08             	sub    $0x8,%esp
  8014d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014d3:	50                   	push   %eax
  8014d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014d7:	ff 30                	pushl  (%eax)
  8014d9:	e8 c2 fd ff ff       	call   8012a0 <dev_lookup>
  8014de:	83 c4 10             	add    $0x10,%esp
  8014e1:	85 c0                	test   %eax,%eax
  8014e3:	78 4c                	js     801531 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014e5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014e8:	8b 42 08             	mov    0x8(%edx),%eax
  8014eb:	83 e0 03             	and    $0x3,%eax
  8014ee:	83 f8 01             	cmp    $0x1,%eax
  8014f1:	75 21                	jne    801514 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014f3:	a1 04 40 80 00       	mov    0x804004,%eax
  8014f8:	8b 40 48             	mov    0x48(%eax),%eax
  8014fb:	83 ec 04             	sub    $0x4,%esp
  8014fe:	53                   	push   %ebx
  8014ff:	50                   	push   %eax
  801500:	68 98 27 80 00       	push   $0x802798
  801505:	e8 13 ee ff ff       	call   80031d <cprintf>
		return -E_INVAL;
  80150a:	83 c4 10             	add    $0x10,%esp
  80150d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801512:	eb 26                	jmp    80153a <read+0x8a>
	}
	if (!dev->dev_read)
  801514:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801517:	8b 40 08             	mov    0x8(%eax),%eax
  80151a:	85 c0                	test   %eax,%eax
  80151c:	74 17                	je     801535 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80151e:	83 ec 04             	sub    $0x4,%esp
  801521:	ff 75 10             	pushl  0x10(%ebp)
  801524:	ff 75 0c             	pushl  0xc(%ebp)
  801527:	52                   	push   %edx
  801528:	ff d0                	call   *%eax
  80152a:	89 c2                	mov    %eax,%edx
  80152c:	83 c4 10             	add    $0x10,%esp
  80152f:	eb 09                	jmp    80153a <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801531:	89 c2                	mov    %eax,%edx
  801533:	eb 05                	jmp    80153a <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801535:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80153a:	89 d0                	mov    %edx,%eax
  80153c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80153f:	c9                   	leave  
  801540:	c3                   	ret    

00801541 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801541:	55                   	push   %ebp
  801542:	89 e5                	mov    %esp,%ebp
  801544:	57                   	push   %edi
  801545:	56                   	push   %esi
  801546:	53                   	push   %ebx
  801547:	83 ec 0c             	sub    $0xc,%esp
  80154a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80154d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801550:	bb 00 00 00 00       	mov    $0x0,%ebx
  801555:	eb 21                	jmp    801578 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801557:	83 ec 04             	sub    $0x4,%esp
  80155a:	89 f0                	mov    %esi,%eax
  80155c:	29 d8                	sub    %ebx,%eax
  80155e:	50                   	push   %eax
  80155f:	89 d8                	mov    %ebx,%eax
  801561:	03 45 0c             	add    0xc(%ebp),%eax
  801564:	50                   	push   %eax
  801565:	57                   	push   %edi
  801566:	e8 45 ff ff ff       	call   8014b0 <read>
		if (m < 0)
  80156b:	83 c4 10             	add    $0x10,%esp
  80156e:	85 c0                	test   %eax,%eax
  801570:	78 10                	js     801582 <readn+0x41>
			return m;
		if (m == 0)
  801572:	85 c0                	test   %eax,%eax
  801574:	74 0a                	je     801580 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801576:	01 c3                	add    %eax,%ebx
  801578:	39 f3                	cmp    %esi,%ebx
  80157a:	72 db                	jb     801557 <readn+0x16>
  80157c:	89 d8                	mov    %ebx,%eax
  80157e:	eb 02                	jmp    801582 <readn+0x41>
  801580:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801582:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801585:	5b                   	pop    %ebx
  801586:	5e                   	pop    %esi
  801587:	5f                   	pop    %edi
  801588:	5d                   	pop    %ebp
  801589:	c3                   	ret    

0080158a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80158a:	55                   	push   %ebp
  80158b:	89 e5                	mov    %esp,%ebp
  80158d:	53                   	push   %ebx
  80158e:	83 ec 14             	sub    $0x14,%esp
  801591:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801594:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801597:	50                   	push   %eax
  801598:	53                   	push   %ebx
  801599:	e8 ac fc ff ff       	call   80124a <fd_lookup>
  80159e:	83 c4 08             	add    $0x8,%esp
  8015a1:	89 c2                	mov    %eax,%edx
  8015a3:	85 c0                	test   %eax,%eax
  8015a5:	78 68                	js     80160f <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015a7:	83 ec 08             	sub    $0x8,%esp
  8015aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ad:	50                   	push   %eax
  8015ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015b1:	ff 30                	pushl  (%eax)
  8015b3:	e8 e8 fc ff ff       	call   8012a0 <dev_lookup>
  8015b8:	83 c4 10             	add    $0x10,%esp
  8015bb:	85 c0                	test   %eax,%eax
  8015bd:	78 47                	js     801606 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015c2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015c6:	75 21                	jne    8015e9 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015c8:	a1 04 40 80 00       	mov    0x804004,%eax
  8015cd:	8b 40 48             	mov    0x48(%eax),%eax
  8015d0:	83 ec 04             	sub    $0x4,%esp
  8015d3:	53                   	push   %ebx
  8015d4:	50                   	push   %eax
  8015d5:	68 b4 27 80 00       	push   $0x8027b4
  8015da:	e8 3e ed ff ff       	call   80031d <cprintf>
		return -E_INVAL;
  8015df:	83 c4 10             	add    $0x10,%esp
  8015e2:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015e7:	eb 26                	jmp    80160f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015e9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015ec:	8b 52 0c             	mov    0xc(%edx),%edx
  8015ef:	85 d2                	test   %edx,%edx
  8015f1:	74 17                	je     80160a <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015f3:	83 ec 04             	sub    $0x4,%esp
  8015f6:	ff 75 10             	pushl  0x10(%ebp)
  8015f9:	ff 75 0c             	pushl  0xc(%ebp)
  8015fc:	50                   	push   %eax
  8015fd:	ff d2                	call   *%edx
  8015ff:	89 c2                	mov    %eax,%edx
  801601:	83 c4 10             	add    $0x10,%esp
  801604:	eb 09                	jmp    80160f <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801606:	89 c2                	mov    %eax,%edx
  801608:	eb 05                	jmp    80160f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80160a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80160f:	89 d0                	mov    %edx,%eax
  801611:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801614:	c9                   	leave  
  801615:	c3                   	ret    

00801616 <seek>:

int
seek(int fdnum, off_t offset)
{
  801616:	55                   	push   %ebp
  801617:	89 e5                	mov    %esp,%ebp
  801619:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80161c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80161f:	50                   	push   %eax
  801620:	ff 75 08             	pushl  0x8(%ebp)
  801623:	e8 22 fc ff ff       	call   80124a <fd_lookup>
  801628:	83 c4 08             	add    $0x8,%esp
  80162b:	85 c0                	test   %eax,%eax
  80162d:	78 0e                	js     80163d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80162f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801632:	8b 55 0c             	mov    0xc(%ebp),%edx
  801635:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801638:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80163d:	c9                   	leave  
  80163e:	c3                   	ret    

0080163f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80163f:	55                   	push   %ebp
  801640:	89 e5                	mov    %esp,%ebp
  801642:	53                   	push   %ebx
  801643:	83 ec 14             	sub    $0x14,%esp
  801646:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801649:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80164c:	50                   	push   %eax
  80164d:	53                   	push   %ebx
  80164e:	e8 f7 fb ff ff       	call   80124a <fd_lookup>
  801653:	83 c4 08             	add    $0x8,%esp
  801656:	89 c2                	mov    %eax,%edx
  801658:	85 c0                	test   %eax,%eax
  80165a:	78 65                	js     8016c1 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80165c:	83 ec 08             	sub    $0x8,%esp
  80165f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801662:	50                   	push   %eax
  801663:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801666:	ff 30                	pushl  (%eax)
  801668:	e8 33 fc ff ff       	call   8012a0 <dev_lookup>
  80166d:	83 c4 10             	add    $0x10,%esp
  801670:	85 c0                	test   %eax,%eax
  801672:	78 44                	js     8016b8 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801674:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801677:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80167b:	75 21                	jne    80169e <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80167d:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801682:	8b 40 48             	mov    0x48(%eax),%eax
  801685:	83 ec 04             	sub    $0x4,%esp
  801688:	53                   	push   %ebx
  801689:	50                   	push   %eax
  80168a:	68 74 27 80 00       	push   $0x802774
  80168f:	e8 89 ec ff ff       	call   80031d <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801694:	83 c4 10             	add    $0x10,%esp
  801697:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80169c:	eb 23                	jmp    8016c1 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80169e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016a1:	8b 52 18             	mov    0x18(%edx),%edx
  8016a4:	85 d2                	test   %edx,%edx
  8016a6:	74 14                	je     8016bc <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016a8:	83 ec 08             	sub    $0x8,%esp
  8016ab:	ff 75 0c             	pushl  0xc(%ebp)
  8016ae:	50                   	push   %eax
  8016af:	ff d2                	call   *%edx
  8016b1:	89 c2                	mov    %eax,%edx
  8016b3:	83 c4 10             	add    $0x10,%esp
  8016b6:	eb 09                	jmp    8016c1 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016b8:	89 c2                	mov    %eax,%edx
  8016ba:	eb 05                	jmp    8016c1 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016bc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8016c1:	89 d0                	mov    %edx,%eax
  8016c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016c6:	c9                   	leave  
  8016c7:	c3                   	ret    

008016c8 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016c8:	55                   	push   %ebp
  8016c9:	89 e5                	mov    %esp,%ebp
  8016cb:	53                   	push   %ebx
  8016cc:	83 ec 14             	sub    $0x14,%esp
  8016cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016d2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016d5:	50                   	push   %eax
  8016d6:	ff 75 08             	pushl  0x8(%ebp)
  8016d9:	e8 6c fb ff ff       	call   80124a <fd_lookup>
  8016de:	83 c4 08             	add    $0x8,%esp
  8016e1:	89 c2                	mov    %eax,%edx
  8016e3:	85 c0                	test   %eax,%eax
  8016e5:	78 58                	js     80173f <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016e7:	83 ec 08             	sub    $0x8,%esp
  8016ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016ed:	50                   	push   %eax
  8016ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016f1:	ff 30                	pushl  (%eax)
  8016f3:	e8 a8 fb ff ff       	call   8012a0 <dev_lookup>
  8016f8:	83 c4 10             	add    $0x10,%esp
  8016fb:	85 c0                	test   %eax,%eax
  8016fd:	78 37                	js     801736 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801702:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801706:	74 32                	je     80173a <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801708:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80170b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801712:	00 00 00 
	stat->st_isdir = 0;
  801715:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80171c:	00 00 00 
	stat->st_dev = dev;
  80171f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801725:	83 ec 08             	sub    $0x8,%esp
  801728:	53                   	push   %ebx
  801729:	ff 75 f0             	pushl  -0x10(%ebp)
  80172c:	ff 50 14             	call   *0x14(%eax)
  80172f:	89 c2                	mov    %eax,%edx
  801731:	83 c4 10             	add    $0x10,%esp
  801734:	eb 09                	jmp    80173f <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801736:	89 c2                	mov    %eax,%edx
  801738:	eb 05                	jmp    80173f <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80173a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80173f:	89 d0                	mov    %edx,%eax
  801741:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801744:	c9                   	leave  
  801745:	c3                   	ret    

00801746 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801746:	55                   	push   %ebp
  801747:	89 e5                	mov    %esp,%ebp
  801749:	56                   	push   %esi
  80174a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80174b:	83 ec 08             	sub    $0x8,%esp
  80174e:	6a 00                	push   $0x0
  801750:	ff 75 08             	pushl  0x8(%ebp)
  801753:	e8 0c 02 00 00       	call   801964 <open>
  801758:	89 c3                	mov    %eax,%ebx
  80175a:	83 c4 10             	add    $0x10,%esp
  80175d:	85 c0                	test   %eax,%eax
  80175f:	78 1b                	js     80177c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801761:	83 ec 08             	sub    $0x8,%esp
  801764:	ff 75 0c             	pushl  0xc(%ebp)
  801767:	50                   	push   %eax
  801768:	e8 5b ff ff ff       	call   8016c8 <fstat>
  80176d:	89 c6                	mov    %eax,%esi
	close(fd);
  80176f:	89 1c 24             	mov    %ebx,(%esp)
  801772:	e8 fd fb ff ff       	call   801374 <close>
	return r;
  801777:	83 c4 10             	add    $0x10,%esp
  80177a:	89 f0                	mov    %esi,%eax
}
  80177c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80177f:	5b                   	pop    %ebx
  801780:	5e                   	pop    %esi
  801781:	5d                   	pop    %ebp
  801782:	c3                   	ret    

00801783 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801783:	55                   	push   %ebp
  801784:	89 e5                	mov    %esp,%ebp
  801786:	56                   	push   %esi
  801787:	53                   	push   %ebx
  801788:	89 c6                	mov    %eax,%esi
  80178a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80178c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801793:	75 12                	jne    8017a7 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801795:	83 ec 0c             	sub    $0xc,%esp
  801798:	6a 01                	push   $0x1
  80179a:	e8 fc f9 ff ff       	call   80119b <ipc_find_env>
  80179f:	a3 00 40 80 00       	mov    %eax,0x804000
  8017a4:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017a7:	6a 07                	push   $0x7
  8017a9:	68 00 50 80 00       	push   $0x805000
  8017ae:	56                   	push   %esi
  8017af:	ff 35 00 40 80 00    	pushl  0x804000
  8017b5:	e8 8d f9 ff ff       	call   801147 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017ba:	83 c4 0c             	add    $0xc,%esp
  8017bd:	6a 00                	push   $0x0
  8017bf:	53                   	push   %ebx
  8017c0:	6a 00                	push   $0x0
  8017c2:	e8 17 f9 ff ff       	call   8010de <ipc_recv>
}
  8017c7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017ca:	5b                   	pop    %ebx
  8017cb:	5e                   	pop    %esi
  8017cc:	5d                   	pop    %ebp
  8017cd:	c3                   	ret    

008017ce <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017ce:	55                   	push   %ebp
  8017cf:	89 e5                	mov    %esp,%ebp
  8017d1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d7:	8b 40 0c             	mov    0xc(%eax),%eax
  8017da:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017e2:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ec:	b8 02 00 00 00       	mov    $0x2,%eax
  8017f1:	e8 8d ff ff ff       	call   801783 <fsipc>
}
  8017f6:	c9                   	leave  
  8017f7:	c3                   	ret    

008017f8 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017f8:	55                   	push   %ebp
  8017f9:	89 e5                	mov    %esp,%ebp
  8017fb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801801:	8b 40 0c             	mov    0xc(%eax),%eax
  801804:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801809:	ba 00 00 00 00       	mov    $0x0,%edx
  80180e:	b8 06 00 00 00       	mov    $0x6,%eax
  801813:	e8 6b ff ff ff       	call   801783 <fsipc>
}
  801818:	c9                   	leave  
  801819:	c3                   	ret    

0080181a <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80181a:	55                   	push   %ebp
  80181b:	89 e5                	mov    %esp,%ebp
  80181d:	53                   	push   %ebx
  80181e:	83 ec 04             	sub    $0x4,%esp
  801821:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801824:	8b 45 08             	mov    0x8(%ebp),%eax
  801827:	8b 40 0c             	mov    0xc(%eax),%eax
  80182a:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80182f:	ba 00 00 00 00       	mov    $0x0,%edx
  801834:	b8 05 00 00 00       	mov    $0x5,%eax
  801839:	e8 45 ff ff ff       	call   801783 <fsipc>
  80183e:	85 c0                	test   %eax,%eax
  801840:	78 2c                	js     80186e <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801842:	83 ec 08             	sub    $0x8,%esp
  801845:	68 00 50 80 00       	push   $0x805000
  80184a:	53                   	push   %ebx
  80184b:	e8 52 f0 ff ff       	call   8008a2 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801850:	a1 80 50 80 00       	mov    0x805080,%eax
  801855:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80185b:	a1 84 50 80 00       	mov    0x805084,%eax
  801860:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801866:	83 c4 10             	add    $0x10,%esp
  801869:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80186e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801871:	c9                   	leave  
  801872:	c3                   	ret    

00801873 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801873:	55                   	push   %ebp
  801874:	89 e5                	mov    %esp,%ebp
  801876:	53                   	push   %ebx
  801877:	83 ec 08             	sub    $0x8,%esp
  80187a:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80187d:	8b 55 08             	mov    0x8(%ebp),%edx
  801880:	8b 52 0c             	mov    0xc(%edx),%edx
  801883:	89 15 00 50 80 00    	mov    %edx,0x805000
  801889:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80188e:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  801893:	0f 46 d8             	cmovbe %eax,%ebx
	
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  801896:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  80189c:	53                   	push   %ebx
  80189d:	ff 75 0c             	pushl  0xc(%ebp)
  8018a0:	68 08 50 80 00       	push   $0x805008
  8018a5:	e8 8a f1 ff ff       	call   800a34 <memmove>

	
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) 
  8018aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8018af:	b8 04 00 00 00       	mov    $0x4,%eax
  8018b4:	e8 ca fe ff ff       	call   801783 <fsipc>
  8018b9:	83 c4 10             	add    $0x10,%esp
  8018bc:	85 c0                	test   %eax,%eax
  8018be:	78 1d                	js     8018dd <devfile_write+0x6a>
		return r;
	assert(r <= n_real); 
  8018c0:	39 d8                	cmp    %ebx,%eax
  8018c2:	76 19                	jbe    8018dd <devfile_write+0x6a>
  8018c4:	68 e4 27 80 00       	push   $0x8027e4
  8018c9:	68 f0 27 80 00       	push   $0x8027f0
  8018ce:	68 a3 00 00 00       	push   $0xa3
  8018d3:	68 05 28 80 00       	push   $0x802805
  8018d8:	e8 67 e9 ff ff       	call   800244 <_panic>
	return r;
}
  8018dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018e0:	c9                   	leave  
  8018e1:	c3                   	ret    

008018e2 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018e2:	55                   	push   %ebp
  8018e3:	89 e5                	mov    %esp,%ebp
  8018e5:	56                   	push   %esi
  8018e6:	53                   	push   %ebx
  8018e7:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ed:	8b 40 0c             	mov    0xc(%eax),%eax
  8018f0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018f5:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018fb:	ba 00 00 00 00       	mov    $0x0,%edx
  801900:	b8 03 00 00 00       	mov    $0x3,%eax
  801905:	e8 79 fe ff ff       	call   801783 <fsipc>
  80190a:	89 c3                	mov    %eax,%ebx
  80190c:	85 c0                	test   %eax,%eax
  80190e:	78 4b                	js     80195b <devfile_read+0x79>
		return r;
	assert(r <= n);
  801910:	39 c6                	cmp    %eax,%esi
  801912:	73 16                	jae    80192a <devfile_read+0x48>
  801914:	68 10 28 80 00       	push   $0x802810
  801919:	68 f0 27 80 00       	push   $0x8027f0
  80191e:	6a 7c                	push   $0x7c
  801920:	68 05 28 80 00       	push   $0x802805
  801925:	e8 1a e9 ff ff       	call   800244 <_panic>
	assert(r <= PGSIZE);
  80192a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80192f:	7e 16                	jle    801947 <devfile_read+0x65>
  801931:	68 17 28 80 00       	push   $0x802817
  801936:	68 f0 27 80 00       	push   $0x8027f0
  80193b:	6a 7d                	push   $0x7d
  80193d:	68 05 28 80 00       	push   $0x802805
  801942:	e8 fd e8 ff ff       	call   800244 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801947:	83 ec 04             	sub    $0x4,%esp
  80194a:	50                   	push   %eax
  80194b:	68 00 50 80 00       	push   $0x805000
  801950:	ff 75 0c             	pushl  0xc(%ebp)
  801953:	e8 dc f0 ff ff       	call   800a34 <memmove>
	return r;
  801958:	83 c4 10             	add    $0x10,%esp
}
  80195b:	89 d8                	mov    %ebx,%eax
  80195d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801960:	5b                   	pop    %ebx
  801961:	5e                   	pop    %esi
  801962:	5d                   	pop    %ebp
  801963:	c3                   	ret    

00801964 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801964:	55                   	push   %ebp
  801965:	89 e5                	mov    %esp,%ebp
  801967:	53                   	push   %ebx
  801968:	83 ec 20             	sub    $0x20,%esp
  80196b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80196e:	53                   	push   %ebx
  80196f:	e8 f5 ee ff ff       	call   800869 <strlen>
  801974:	83 c4 10             	add    $0x10,%esp
  801977:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80197c:	7f 67                	jg     8019e5 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80197e:	83 ec 0c             	sub    $0xc,%esp
  801981:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801984:	50                   	push   %eax
  801985:	e8 71 f8 ff ff       	call   8011fb <fd_alloc>
  80198a:	83 c4 10             	add    $0x10,%esp
		return r;
  80198d:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80198f:	85 c0                	test   %eax,%eax
  801991:	78 57                	js     8019ea <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801993:	83 ec 08             	sub    $0x8,%esp
  801996:	53                   	push   %ebx
  801997:	68 00 50 80 00       	push   $0x805000
  80199c:	e8 01 ef ff ff       	call   8008a2 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019a4:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019a9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019ac:	b8 01 00 00 00       	mov    $0x1,%eax
  8019b1:	e8 cd fd ff ff       	call   801783 <fsipc>
  8019b6:	89 c3                	mov    %eax,%ebx
  8019b8:	83 c4 10             	add    $0x10,%esp
  8019bb:	85 c0                	test   %eax,%eax
  8019bd:	79 14                	jns    8019d3 <open+0x6f>
		fd_close(fd, 0);
  8019bf:	83 ec 08             	sub    $0x8,%esp
  8019c2:	6a 00                	push   $0x0
  8019c4:	ff 75 f4             	pushl  -0xc(%ebp)
  8019c7:	e8 27 f9 ff ff       	call   8012f3 <fd_close>
		return r;
  8019cc:	83 c4 10             	add    $0x10,%esp
  8019cf:	89 da                	mov    %ebx,%edx
  8019d1:	eb 17                	jmp    8019ea <open+0x86>
	}

	return fd2num(fd);
  8019d3:	83 ec 0c             	sub    $0xc,%esp
  8019d6:	ff 75 f4             	pushl  -0xc(%ebp)
  8019d9:	e8 f6 f7 ff ff       	call   8011d4 <fd2num>
  8019de:	89 c2                	mov    %eax,%edx
  8019e0:	83 c4 10             	add    $0x10,%esp
  8019e3:	eb 05                	jmp    8019ea <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019e5:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019ea:	89 d0                	mov    %edx,%eax
  8019ec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019ef:	c9                   	leave  
  8019f0:	c3                   	ret    

008019f1 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019f1:	55                   	push   %ebp
  8019f2:	89 e5                	mov    %esp,%ebp
  8019f4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8019fc:	b8 08 00 00 00       	mov    $0x8,%eax
  801a01:	e8 7d fd ff ff       	call   801783 <fsipc>
}
  801a06:	c9                   	leave  
  801a07:	c3                   	ret    

00801a08 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801a08:	55                   	push   %ebp
  801a09:	89 e5                	mov    %esp,%ebp
  801a0b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801a0e:	89 d0                	mov    %edx,%eax
  801a10:	c1 e8 16             	shr    $0x16,%eax
  801a13:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801a1a:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801a1f:	f6 c1 01             	test   $0x1,%cl
  801a22:	74 1d                	je     801a41 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801a24:	c1 ea 0c             	shr    $0xc,%edx
  801a27:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801a2e:	f6 c2 01             	test   $0x1,%dl
  801a31:	74 0e                	je     801a41 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801a33:	c1 ea 0c             	shr    $0xc,%edx
  801a36:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801a3d:	ef 
  801a3e:	0f b7 c0             	movzwl %ax,%eax
}
  801a41:	5d                   	pop    %ebp
  801a42:	c3                   	ret    

00801a43 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a43:	55                   	push   %ebp
  801a44:	89 e5                	mov    %esp,%ebp
  801a46:	56                   	push   %esi
  801a47:	53                   	push   %ebx
  801a48:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a4b:	83 ec 0c             	sub    $0xc,%esp
  801a4e:	ff 75 08             	pushl  0x8(%ebp)
  801a51:	e8 8e f7 ff ff       	call   8011e4 <fd2data>
  801a56:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a58:	83 c4 08             	add    $0x8,%esp
  801a5b:	68 23 28 80 00       	push   $0x802823
  801a60:	53                   	push   %ebx
  801a61:	e8 3c ee ff ff       	call   8008a2 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a66:	8b 46 04             	mov    0x4(%esi),%eax
  801a69:	2b 06                	sub    (%esi),%eax
  801a6b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a71:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a78:	00 00 00 
	stat->st_dev = &devpipe;
  801a7b:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a82:	30 80 00 
	return 0;
}
  801a85:	b8 00 00 00 00       	mov    $0x0,%eax
  801a8a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a8d:	5b                   	pop    %ebx
  801a8e:	5e                   	pop    %esi
  801a8f:	5d                   	pop    %ebp
  801a90:	c3                   	ret    

00801a91 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a91:	55                   	push   %ebp
  801a92:	89 e5                	mov    %esp,%ebp
  801a94:	53                   	push   %ebx
  801a95:	83 ec 0c             	sub    $0xc,%esp
  801a98:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a9b:	53                   	push   %ebx
  801a9c:	6a 00                	push   $0x0
  801a9e:	e8 87 f2 ff ff       	call   800d2a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801aa3:	89 1c 24             	mov    %ebx,(%esp)
  801aa6:	e8 39 f7 ff ff       	call   8011e4 <fd2data>
  801aab:	83 c4 08             	add    $0x8,%esp
  801aae:	50                   	push   %eax
  801aaf:	6a 00                	push   $0x0
  801ab1:	e8 74 f2 ff ff       	call   800d2a <sys_page_unmap>
}
  801ab6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ab9:	c9                   	leave  
  801aba:	c3                   	ret    

00801abb <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801abb:	55                   	push   %ebp
  801abc:	89 e5                	mov    %esp,%ebp
  801abe:	57                   	push   %edi
  801abf:	56                   	push   %esi
  801ac0:	53                   	push   %ebx
  801ac1:	83 ec 1c             	sub    $0x1c,%esp
  801ac4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ac7:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ac9:	a1 04 40 80 00       	mov    0x804004,%eax
  801ace:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801ad1:	83 ec 0c             	sub    $0xc,%esp
  801ad4:	ff 75 e0             	pushl  -0x20(%ebp)
  801ad7:	e8 2c ff ff ff       	call   801a08 <pageref>
  801adc:	89 c3                	mov    %eax,%ebx
  801ade:	89 3c 24             	mov    %edi,(%esp)
  801ae1:	e8 22 ff ff ff       	call   801a08 <pageref>
  801ae6:	83 c4 10             	add    $0x10,%esp
  801ae9:	39 c3                	cmp    %eax,%ebx
  801aeb:	0f 94 c1             	sete   %cl
  801aee:	0f b6 c9             	movzbl %cl,%ecx
  801af1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801af4:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801afa:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801afd:	39 ce                	cmp    %ecx,%esi
  801aff:	74 1b                	je     801b1c <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801b01:	39 c3                	cmp    %eax,%ebx
  801b03:	75 c4                	jne    801ac9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b05:	8b 42 58             	mov    0x58(%edx),%eax
  801b08:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b0b:	50                   	push   %eax
  801b0c:	56                   	push   %esi
  801b0d:	68 2a 28 80 00       	push   $0x80282a
  801b12:	e8 06 e8 ff ff       	call   80031d <cprintf>
  801b17:	83 c4 10             	add    $0x10,%esp
  801b1a:	eb ad                	jmp    801ac9 <_pipeisclosed+0xe>
	}
}
  801b1c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b1f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b22:	5b                   	pop    %ebx
  801b23:	5e                   	pop    %esi
  801b24:	5f                   	pop    %edi
  801b25:	5d                   	pop    %ebp
  801b26:	c3                   	ret    

00801b27 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b27:	55                   	push   %ebp
  801b28:	89 e5                	mov    %esp,%ebp
  801b2a:	57                   	push   %edi
  801b2b:	56                   	push   %esi
  801b2c:	53                   	push   %ebx
  801b2d:	83 ec 28             	sub    $0x28,%esp
  801b30:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b33:	56                   	push   %esi
  801b34:	e8 ab f6 ff ff       	call   8011e4 <fd2data>
  801b39:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b3b:	83 c4 10             	add    $0x10,%esp
  801b3e:	bf 00 00 00 00       	mov    $0x0,%edi
  801b43:	eb 4b                	jmp    801b90 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b45:	89 da                	mov    %ebx,%edx
  801b47:	89 f0                	mov    %esi,%eax
  801b49:	e8 6d ff ff ff       	call   801abb <_pipeisclosed>
  801b4e:	85 c0                	test   %eax,%eax
  801b50:	75 48                	jne    801b9a <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b52:	e8 2f f1 ff ff       	call   800c86 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b57:	8b 43 04             	mov    0x4(%ebx),%eax
  801b5a:	8b 0b                	mov    (%ebx),%ecx
  801b5c:	8d 51 20             	lea    0x20(%ecx),%edx
  801b5f:	39 d0                	cmp    %edx,%eax
  801b61:	73 e2                	jae    801b45 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b66:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b6a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b6d:	89 c2                	mov    %eax,%edx
  801b6f:	c1 fa 1f             	sar    $0x1f,%edx
  801b72:	89 d1                	mov    %edx,%ecx
  801b74:	c1 e9 1b             	shr    $0x1b,%ecx
  801b77:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b7a:	83 e2 1f             	and    $0x1f,%edx
  801b7d:	29 ca                	sub    %ecx,%edx
  801b7f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b83:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b87:	83 c0 01             	add    $0x1,%eax
  801b8a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b8d:	83 c7 01             	add    $0x1,%edi
  801b90:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b93:	75 c2                	jne    801b57 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b95:	8b 45 10             	mov    0x10(%ebp),%eax
  801b98:	eb 05                	jmp    801b9f <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b9a:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b9f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ba2:	5b                   	pop    %ebx
  801ba3:	5e                   	pop    %esi
  801ba4:	5f                   	pop    %edi
  801ba5:	5d                   	pop    %ebp
  801ba6:	c3                   	ret    

00801ba7 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ba7:	55                   	push   %ebp
  801ba8:	89 e5                	mov    %esp,%ebp
  801baa:	57                   	push   %edi
  801bab:	56                   	push   %esi
  801bac:	53                   	push   %ebx
  801bad:	83 ec 18             	sub    $0x18,%esp
  801bb0:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801bb3:	57                   	push   %edi
  801bb4:	e8 2b f6 ff ff       	call   8011e4 <fd2data>
  801bb9:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bbb:	83 c4 10             	add    $0x10,%esp
  801bbe:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bc3:	eb 3d                	jmp    801c02 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801bc5:	85 db                	test   %ebx,%ebx
  801bc7:	74 04                	je     801bcd <devpipe_read+0x26>
				return i;
  801bc9:	89 d8                	mov    %ebx,%eax
  801bcb:	eb 44                	jmp    801c11 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801bcd:	89 f2                	mov    %esi,%edx
  801bcf:	89 f8                	mov    %edi,%eax
  801bd1:	e8 e5 fe ff ff       	call   801abb <_pipeisclosed>
  801bd6:	85 c0                	test   %eax,%eax
  801bd8:	75 32                	jne    801c0c <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801bda:	e8 a7 f0 ff ff       	call   800c86 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801bdf:	8b 06                	mov    (%esi),%eax
  801be1:	3b 46 04             	cmp    0x4(%esi),%eax
  801be4:	74 df                	je     801bc5 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801be6:	99                   	cltd   
  801be7:	c1 ea 1b             	shr    $0x1b,%edx
  801bea:	01 d0                	add    %edx,%eax
  801bec:	83 e0 1f             	and    $0x1f,%eax
  801bef:	29 d0                	sub    %edx,%eax
  801bf1:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801bf6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bf9:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801bfc:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bff:	83 c3 01             	add    $0x1,%ebx
  801c02:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c05:	75 d8                	jne    801bdf <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c07:	8b 45 10             	mov    0x10(%ebp),%eax
  801c0a:	eb 05                	jmp    801c11 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c0c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c11:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c14:	5b                   	pop    %ebx
  801c15:	5e                   	pop    %esi
  801c16:	5f                   	pop    %edi
  801c17:	5d                   	pop    %ebp
  801c18:	c3                   	ret    

00801c19 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c19:	55                   	push   %ebp
  801c1a:	89 e5                	mov    %esp,%ebp
  801c1c:	56                   	push   %esi
  801c1d:	53                   	push   %ebx
  801c1e:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c21:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c24:	50                   	push   %eax
  801c25:	e8 d1 f5 ff ff       	call   8011fb <fd_alloc>
  801c2a:	83 c4 10             	add    $0x10,%esp
  801c2d:	89 c2                	mov    %eax,%edx
  801c2f:	85 c0                	test   %eax,%eax
  801c31:	0f 88 2c 01 00 00    	js     801d63 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c37:	83 ec 04             	sub    $0x4,%esp
  801c3a:	68 07 04 00 00       	push   $0x407
  801c3f:	ff 75 f4             	pushl  -0xc(%ebp)
  801c42:	6a 00                	push   $0x0
  801c44:	e8 5c f0 ff ff       	call   800ca5 <sys_page_alloc>
  801c49:	83 c4 10             	add    $0x10,%esp
  801c4c:	89 c2                	mov    %eax,%edx
  801c4e:	85 c0                	test   %eax,%eax
  801c50:	0f 88 0d 01 00 00    	js     801d63 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c56:	83 ec 0c             	sub    $0xc,%esp
  801c59:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c5c:	50                   	push   %eax
  801c5d:	e8 99 f5 ff ff       	call   8011fb <fd_alloc>
  801c62:	89 c3                	mov    %eax,%ebx
  801c64:	83 c4 10             	add    $0x10,%esp
  801c67:	85 c0                	test   %eax,%eax
  801c69:	0f 88 e2 00 00 00    	js     801d51 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c6f:	83 ec 04             	sub    $0x4,%esp
  801c72:	68 07 04 00 00       	push   $0x407
  801c77:	ff 75 f0             	pushl  -0x10(%ebp)
  801c7a:	6a 00                	push   $0x0
  801c7c:	e8 24 f0 ff ff       	call   800ca5 <sys_page_alloc>
  801c81:	89 c3                	mov    %eax,%ebx
  801c83:	83 c4 10             	add    $0x10,%esp
  801c86:	85 c0                	test   %eax,%eax
  801c88:	0f 88 c3 00 00 00    	js     801d51 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c8e:	83 ec 0c             	sub    $0xc,%esp
  801c91:	ff 75 f4             	pushl  -0xc(%ebp)
  801c94:	e8 4b f5 ff ff       	call   8011e4 <fd2data>
  801c99:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c9b:	83 c4 0c             	add    $0xc,%esp
  801c9e:	68 07 04 00 00       	push   $0x407
  801ca3:	50                   	push   %eax
  801ca4:	6a 00                	push   $0x0
  801ca6:	e8 fa ef ff ff       	call   800ca5 <sys_page_alloc>
  801cab:	89 c3                	mov    %eax,%ebx
  801cad:	83 c4 10             	add    $0x10,%esp
  801cb0:	85 c0                	test   %eax,%eax
  801cb2:	0f 88 89 00 00 00    	js     801d41 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cb8:	83 ec 0c             	sub    $0xc,%esp
  801cbb:	ff 75 f0             	pushl  -0x10(%ebp)
  801cbe:	e8 21 f5 ff ff       	call   8011e4 <fd2data>
  801cc3:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801cca:	50                   	push   %eax
  801ccb:	6a 00                	push   $0x0
  801ccd:	56                   	push   %esi
  801cce:	6a 00                	push   $0x0
  801cd0:	e8 13 f0 ff ff       	call   800ce8 <sys_page_map>
  801cd5:	89 c3                	mov    %eax,%ebx
  801cd7:	83 c4 20             	add    $0x20,%esp
  801cda:	85 c0                	test   %eax,%eax
  801cdc:	78 55                	js     801d33 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801cde:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ce4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ce7:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ce9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cec:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801cf3:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cf9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cfc:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801cfe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d01:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d08:	83 ec 0c             	sub    $0xc,%esp
  801d0b:	ff 75 f4             	pushl  -0xc(%ebp)
  801d0e:	e8 c1 f4 ff ff       	call   8011d4 <fd2num>
  801d13:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d16:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d18:	83 c4 04             	add    $0x4,%esp
  801d1b:	ff 75 f0             	pushl  -0x10(%ebp)
  801d1e:	e8 b1 f4 ff ff       	call   8011d4 <fd2num>
  801d23:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d26:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d29:	83 c4 10             	add    $0x10,%esp
  801d2c:	ba 00 00 00 00       	mov    $0x0,%edx
  801d31:	eb 30                	jmp    801d63 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d33:	83 ec 08             	sub    $0x8,%esp
  801d36:	56                   	push   %esi
  801d37:	6a 00                	push   $0x0
  801d39:	e8 ec ef ff ff       	call   800d2a <sys_page_unmap>
  801d3e:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d41:	83 ec 08             	sub    $0x8,%esp
  801d44:	ff 75 f0             	pushl  -0x10(%ebp)
  801d47:	6a 00                	push   $0x0
  801d49:	e8 dc ef ff ff       	call   800d2a <sys_page_unmap>
  801d4e:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d51:	83 ec 08             	sub    $0x8,%esp
  801d54:	ff 75 f4             	pushl  -0xc(%ebp)
  801d57:	6a 00                	push   $0x0
  801d59:	e8 cc ef ff ff       	call   800d2a <sys_page_unmap>
  801d5e:	83 c4 10             	add    $0x10,%esp
  801d61:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d63:	89 d0                	mov    %edx,%eax
  801d65:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d68:	5b                   	pop    %ebx
  801d69:	5e                   	pop    %esi
  801d6a:	5d                   	pop    %ebp
  801d6b:	c3                   	ret    

00801d6c <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d6c:	55                   	push   %ebp
  801d6d:	89 e5                	mov    %esp,%ebp
  801d6f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d72:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d75:	50                   	push   %eax
  801d76:	ff 75 08             	pushl  0x8(%ebp)
  801d79:	e8 cc f4 ff ff       	call   80124a <fd_lookup>
  801d7e:	83 c4 10             	add    $0x10,%esp
  801d81:	85 c0                	test   %eax,%eax
  801d83:	78 18                	js     801d9d <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d85:	83 ec 0c             	sub    $0xc,%esp
  801d88:	ff 75 f4             	pushl  -0xc(%ebp)
  801d8b:	e8 54 f4 ff ff       	call   8011e4 <fd2data>
	return _pipeisclosed(fd, p);
  801d90:	89 c2                	mov    %eax,%edx
  801d92:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d95:	e8 21 fd ff ff       	call   801abb <_pipeisclosed>
  801d9a:	83 c4 10             	add    $0x10,%esp
}
  801d9d:	c9                   	leave  
  801d9e:	c3                   	ret    

00801d9f <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d9f:	55                   	push   %ebp
  801da0:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801da2:	b8 00 00 00 00       	mov    $0x0,%eax
  801da7:	5d                   	pop    %ebp
  801da8:	c3                   	ret    

00801da9 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801da9:	55                   	push   %ebp
  801daa:	89 e5                	mov    %esp,%ebp
  801dac:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801daf:	68 42 28 80 00       	push   $0x802842
  801db4:	ff 75 0c             	pushl  0xc(%ebp)
  801db7:	e8 e6 ea ff ff       	call   8008a2 <strcpy>
	return 0;
}
  801dbc:	b8 00 00 00 00       	mov    $0x0,%eax
  801dc1:	c9                   	leave  
  801dc2:	c3                   	ret    

00801dc3 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801dc3:	55                   	push   %ebp
  801dc4:	89 e5                	mov    %esp,%ebp
  801dc6:	57                   	push   %edi
  801dc7:	56                   	push   %esi
  801dc8:	53                   	push   %ebx
  801dc9:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dcf:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801dd4:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dda:	eb 2d                	jmp    801e09 <devcons_write+0x46>
		m = n - tot;
  801ddc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ddf:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801de1:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801de4:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801de9:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801dec:	83 ec 04             	sub    $0x4,%esp
  801def:	53                   	push   %ebx
  801df0:	03 45 0c             	add    0xc(%ebp),%eax
  801df3:	50                   	push   %eax
  801df4:	57                   	push   %edi
  801df5:	e8 3a ec ff ff       	call   800a34 <memmove>
		sys_cputs(buf, m);
  801dfa:	83 c4 08             	add    $0x8,%esp
  801dfd:	53                   	push   %ebx
  801dfe:	57                   	push   %edi
  801dff:	e8 e5 ed ff ff       	call   800be9 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e04:	01 de                	add    %ebx,%esi
  801e06:	83 c4 10             	add    $0x10,%esp
  801e09:	89 f0                	mov    %esi,%eax
  801e0b:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e0e:	72 cc                	jb     801ddc <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e10:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e13:	5b                   	pop    %ebx
  801e14:	5e                   	pop    %esi
  801e15:	5f                   	pop    %edi
  801e16:	5d                   	pop    %ebp
  801e17:	c3                   	ret    

00801e18 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e18:	55                   	push   %ebp
  801e19:	89 e5                	mov    %esp,%ebp
  801e1b:	83 ec 08             	sub    $0x8,%esp
  801e1e:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801e23:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e27:	74 2a                	je     801e53 <devcons_read+0x3b>
  801e29:	eb 05                	jmp    801e30 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e2b:	e8 56 ee ff ff       	call   800c86 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e30:	e8 d2 ed ff ff       	call   800c07 <sys_cgetc>
  801e35:	85 c0                	test   %eax,%eax
  801e37:	74 f2                	je     801e2b <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e39:	85 c0                	test   %eax,%eax
  801e3b:	78 16                	js     801e53 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e3d:	83 f8 04             	cmp    $0x4,%eax
  801e40:	74 0c                	je     801e4e <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e42:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e45:	88 02                	mov    %al,(%edx)
	return 1;
  801e47:	b8 01 00 00 00       	mov    $0x1,%eax
  801e4c:	eb 05                	jmp    801e53 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e4e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e53:	c9                   	leave  
  801e54:	c3                   	ret    

00801e55 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e55:	55                   	push   %ebp
  801e56:	89 e5                	mov    %esp,%ebp
  801e58:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e5b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e5e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e61:	6a 01                	push   $0x1
  801e63:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e66:	50                   	push   %eax
  801e67:	e8 7d ed ff ff       	call   800be9 <sys_cputs>
}
  801e6c:	83 c4 10             	add    $0x10,%esp
  801e6f:	c9                   	leave  
  801e70:	c3                   	ret    

00801e71 <getchar>:

int
getchar(void)
{
  801e71:	55                   	push   %ebp
  801e72:	89 e5                	mov    %esp,%ebp
  801e74:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e77:	6a 01                	push   $0x1
  801e79:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e7c:	50                   	push   %eax
  801e7d:	6a 00                	push   $0x0
  801e7f:	e8 2c f6 ff ff       	call   8014b0 <read>
	if (r < 0)
  801e84:	83 c4 10             	add    $0x10,%esp
  801e87:	85 c0                	test   %eax,%eax
  801e89:	78 0f                	js     801e9a <getchar+0x29>
		return r;
	if (r < 1)
  801e8b:	85 c0                	test   %eax,%eax
  801e8d:	7e 06                	jle    801e95 <getchar+0x24>
		return -E_EOF;
	return c;
  801e8f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e93:	eb 05                	jmp    801e9a <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e95:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e9a:	c9                   	leave  
  801e9b:	c3                   	ret    

00801e9c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e9c:	55                   	push   %ebp
  801e9d:	89 e5                	mov    %esp,%ebp
  801e9f:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ea2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ea5:	50                   	push   %eax
  801ea6:	ff 75 08             	pushl  0x8(%ebp)
  801ea9:	e8 9c f3 ff ff       	call   80124a <fd_lookup>
  801eae:	83 c4 10             	add    $0x10,%esp
  801eb1:	85 c0                	test   %eax,%eax
  801eb3:	78 11                	js     801ec6 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801eb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eb8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ebe:	39 10                	cmp    %edx,(%eax)
  801ec0:	0f 94 c0             	sete   %al
  801ec3:	0f b6 c0             	movzbl %al,%eax
}
  801ec6:	c9                   	leave  
  801ec7:	c3                   	ret    

00801ec8 <opencons>:

int
opencons(void)
{
  801ec8:	55                   	push   %ebp
  801ec9:	89 e5                	mov    %esp,%ebp
  801ecb:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ece:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ed1:	50                   	push   %eax
  801ed2:	e8 24 f3 ff ff       	call   8011fb <fd_alloc>
  801ed7:	83 c4 10             	add    $0x10,%esp
		return r;
  801eda:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801edc:	85 c0                	test   %eax,%eax
  801ede:	78 3e                	js     801f1e <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ee0:	83 ec 04             	sub    $0x4,%esp
  801ee3:	68 07 04 00 00       	push   $0x407
  801ee8:	ff 75 f4             	pushl  -0xc(%ebp)
  801eeb:	6a 00                	push   $0x0
  801eed:	e8 b3 ed ff ff       	call   800ca5 <sys_page_alloc>
  801ef2:	83 c4 10             	add    $0x10,%esp
		return r;
  801ef5:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ef7:	85 c0                	test   %eax,%eax
  801ef9:	78 23                	js     801f1e <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801efb:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f01:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f04:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f06:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f09:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f10:	83 ec 0c             	sub    $0xc,%esp
  801f13:	50                   	push   %eax
  801f14:	e8 bb f2 ff ff       	call   8011d4 <fd2num>
  801f19:	89 c2                	mov    %eax,%edx
  801f1b:	83 c4 10             	add    $0x10,%esp
}
  801f1e:	89 d0                	mov    %edx,%eax
  801f20:	c9                   	leave  
  801f21:	c3                   	ret    

00801f22 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f22:	55                   	push   %ebp
  801f23:	89 e5                	mov    %esp,%ebp
  801f25:	53                   	push   %ebx
  801f26:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f29:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f30:	75 28                	jne    801f5a <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  801f32:	e8 30 ed ff ff       	call   800c67 <sys_getenvid>
  801f37:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_U | PTE_W);
  801f39:	83 ec 04             	sub    $0x4,%esp
  801f3c:	6a 06                	push   $0x6
  801f3e:	68 00 f0 bf ee       	push   $0xeebff000
  801f43:	50                   	push   %eax
  801f44:	e8 5c ed ff ff       	call   800ca5 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  801f49:	83 c4 08             	add    $0x8,%esp
  801f4c:	68 67 1f 80 00       	push   $0x801f67
  801f51:	53                   	push   %ebx
  801f52:	e8 99 ee ff ff       	call   800df0 <sys_env_set_pgfault_upcall>
  801f57:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f5a:	8b 45 08             	mov    0x8(%ebp),%eax
  801f5d:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801f62:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f65:	c9                   	leave  
  801f66:	c3                   	ret    

00801f67 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f67:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f68:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f6d:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f6f:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	# My method is different. Copy the values to the other stack
	# in a convinient way, and then pop everything.
	movl %esp, %ebp		# ebp refers to the exception stack
  801f72:	89 e5                	mov    %esp,%ebp
	movl 48(%ebp), %esp 	# go to other stack
  801f74:	8b 65 30             	mov    0x30(%ebp),%esp

	pushl 40(%ebp)		# eip - ORDER SWITCHED WITH EFLAGS
  801f77:	ff 75 28             	pushl  0x28(%ebp)
	pushl 44(%ebp)      	# eflags
  801f7a:	ff 75 2c             	pushl  0x2c(%ebp)
	pushl 36(%ebp)		# all the 8 remaining regs
  801f7d:	ff 75 24             	pushl  0x24(%ebp)
	pushl 32(%ebp)
  801f80:	ff 75 20             	pushl  0x20(%ebp)
	pushl 28(%ebp)
  801f83:	ff 75 1c             	pushl  0x1c(%ebp)
	pushl 24(%ebp)
  801f86:	ff 75 18             	pushl  0x18(%ebp)
	pushl 20(%ebp)
  801f89:	ff 75 14             	pushl  0x14(%ebp)
	pushl 16(%ebp)
  801f8c:	ff 75 10             	pushl  0x10(%ebp)
	pushl 12(%ebp)
  801f8f:	ff 75 0c             	pushl  0xc(%ebp)
	pushl 8(%ebp)
  801f92:	ff 75 08             	pushl  0x8(%ebp)

	popal			# now just pop everything!
  801f95:	61                   	popa   
	popfl
  801f96:	9d                   	popf   
	ret
  801f97:	c3                   	ret    
  801f98:	66 90                	xchg   %ax,%ax
  801f9a:	66 90                	xchg   %ax,%ax
  801f9c:	66 90                	xchg   %ax,%ax
  801f9e:	66 90                	xchg   %ax,%ax

00801fa0 <__udivdi3>:
  801fa0:	55                   	push   %ebp
  801fa1:	57                   	push   %edi
  801fa2:	56                   	push   %esi
  801fa3:	53                   	push   %ebx
  801fa4:	83 ec 1c             	sub    $0x1c,%esp
  801fa7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801fab:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801faf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801fb3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801fb7:	85 f6                	test   %esi,%esi
  801fb9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fbd:	89 ca                	mov    %ecx,%edx
  801fbf:	89 f8                	mov    %edi,%eax
  801fc1:	75 3d                	jne    802000 <__udivdi3+0x60>
  801fc3:	39 cf                	cmp    %ecx,%edi
  801fc5:	0f 87 c5 00 00 00    	ja     802090 <__udivdi3+0xf0>
  801fcb:	85 ff                	test   %edi,%edi
  801fcd:	89 fd                	mov    %edi,%ebp
  801fcf:	75 0b                	jne    801fdc <__udivdi3+0x3c>
  801fd1:	b8 01 00 00 00       	mov    $0x1,%eax
  801fd6:	31 d2                	xor    %edx,%edx
  801fd8:	f7 f7                	div    %edi
  801fda:	89 c5                	mov    %eax,%ebp
  801fdc:	89 c8                	mov    %ecx,%eax
  801fde:	31 d2                	xor    %edx,%edx
  801fe0:	f7 f5                	div    %ebp
  801fe2:	89 c1                	mov    %eax,%ecx
  801fe4:	89 d8                	mov    %ebx,%eax
  801fe6:	89 cf                	mov    %ecx,%edi
  801fe8:	f7 f5                	div    %ebp
  801fea:	89 c3                	mov    %eax,%ebx
  801fec:	89 d8                	mov    %ebx,%eax
  801fee:	89 fa                	mov    %edi,%edx
  801ff0:	83 c4 1c             	add    $0x1c,%esp
  801ff3:	5b                   	pop    %ebx
  801ff4:	5e                   	pop    %esi
  801ff5:	5f                   	pop    %edi
  801ff6:	5d                   	pop    %ebp
  801ff7:	c3                   	ret    
  801ff8:	90                   	nop
  801ff9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802000:	39 ce                	cmp    %ecx,%esi
  802002:	77 74                	ja     802078 <__udivdi3+0xd8>
  802004:	0f bd fe             	bsr    %esi,%edi
  802007:	83 f7 1f             	xor    $0x1f,%edi
  80200a:	0f 84 98 00 00 00    	je     8020a8 <__udivdi3+0x108>
  802010:	bb 20 00 00 00       	mov    $0x20,%ebx
  802015:	89 f9                	mov    %edi,%ecx
  802017:	89 c5                	mov    %eax,%ebp
  802019:	29 fb                	sub    %edi,%ebx
  80201b:	d3 e6                	shl    %cl,%esi
  80201d:	89 d9                	mov    %ebx,%ecx
  80201f:	d3 ed                	shr    %cl,%ebp
  802021:	89 f9                	mov    %edi,%ecx
  802023:	d3 e0                	shl    %cl,%eax
  802025:	09 ee                	or     %ebp,%esi
  802027:	89 d9                	mov    %ebx,%ecx
  802029:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80202d:	89 d5                	mov    %edx,%ebp
  80202f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802033:	d3 ed                	shr    %cl,%ebp
  802035:	89 f9                	mov    %edi,%ecx
  802037:	d3 e2                	shl    %cl,%edx
  802039:	89 d9                	mov    %ebx,%ecx
  80203b:	d3 e8                	shr    %cl,%eax
  80203d:	09 c2                	or     %eax,%edx
  80203f:	89 d0                	mov    %edx,%eax
  802041:	89 ea                	mov    %ebp,%edx
  802043:	f7 f6                	div    %esi
  802045:	89 d5                	mov    %edx,%ebp
  802047:	89 c3                	mov    %eax,%ebx
  802049:	f7 64 24 0c          	mull   0xc(%esp)
  80204d:	39 d5                	cmp    %edx,%ebp
  80204f:	72 10                	jb     802061 <__udivdi3+0xc1>
  802051:	8b 74 24 08          	mov    0x8(%esp),%esi
  802055:	89 f9                	mov    %edi,%ecx
  802057:	d3 e6                	shl    %cl,%esi
  802059:	39 c6                	cmp    %eax,%esi
  80205b:	73 07                	jae    802064 <__udivdi3+0xc4>
  80205d:	39 d5                	cmp    %edx,%ebp
  80205f:	75 03                	jne    802064 <__udivdi3+0xc4>
  802061:	83 eb 01             	sub    $0x1,%ebx
  802064:	31 ff                	xor    %edi,%edi
  802066:	89 d8                	mov    %ebx,%eax
  802068:	89 fa                	mov    %edi,%edx
  80206a:	83 c4 1c             	add    $0x1c,%esp
  80206d:	5b                   	pop    %ebx
  80206e:	5e                   	pop    %esi
  80206f:	5f                   	pop    %edi
  802070:	5d                   	pop    %ebp
  802071:	c3                   	ret    
  802072:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802078:	31 ff                	xor    %edi,%edi
  80207a:	31 db                	xor    %ebx,%ebx
  80207c:	89 d8                	mov    %ebx,%eax
  80207e:	89 fa                	mov    %edi,%edx
  802080:	83 c4 1c             	add    $0x1c,%esp
  802083:	5b                   	pop    %ebx
  802084:	5e                   	pop    %esi
  802085:	5f                   	pop    %edi
  802086:	5d                   	pop    %ebp
  802087:	c3                   	ret    
  802088:	90                   	nop
  802089:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802090:	89 d8                	mov    %ebx,%eax
  802092:	f7 f7                	div    %edi
  802094:	31 ff                	xor    %edi,%edi
  802096:	89 c3                	mov    %eax,%ebx
  802098:	89 d8                	mov    %ebx,%eax
  80209a:	89 fa                	mov    %edi,%edx
  80209c:	83 c4 1c             	add    $0x1c,%esp
  80209f:	5b                   	pop    %ebx
  8020a0:	5e                   	pop    %esi
  8020a1:	5f                   	pop    %edi
  8020a2:	5d                   	pop    %ebp
  8020a3:	c3                   	ret    
  8020a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020a8:	39 ce                	cmp    %ecx,%esi
  8020aa:	72 0c                	jb     8020b8 <__udivdi3+0x118>
  8020ac:	31 db                	xor    %ebx,%ebx
  8020ae:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8020b2:	0f 87 34 ff ff ff    	ja     801fec <__udivdi3+0x4c>
  8020b8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8020bd:	e9 2a ff ff ff       	jmp    801fec <__udivdi3+0x4c>
  8020c2:	66 90                	xchg   %ax,%ax
  8020c4:	66 90                	xchg   %ax,%ax
  8020c6:	66 90                	xchg   %ax,%ax
  8020c8:	66 90                	xchg   %ax,%ax
  8020ca:	66 90                	xchg   %ax,%ax
  8020cc:	66 90                	xchg   %ax,%ax
  8020ce:	66 90                	xchg   %ax,%ax

008020d0 <__umoddi3>:
  8020d0:	55                   	push   %ebp
  8020d1:	57                   	push   %edi
  8020d2:	56                   	push   %esi
  8020d3:	53                   	push   %ebx
  8020d4:	83 ec 1c             	sub    $0x1c,%esp
  8020d7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8020db:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8020df:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020e7:	85 d2                	test   %edx,%edx
  8020e9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8020ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020f1:	89 f3                	mov    %esi,%ebx
  8020f3:	89 3c 24             	mov    %edi,(%esp)
  8020f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020fa:	75 1c                	jne    802118 <__umoddi3+0x48>
  8020fc:	39 f7                	cmp    %esi,%edi
  8020fe:	76 50                	jbe    802150 <__umoddi3+0x80>
  802100:	89 c8                	mov    %ecx,%eax
  802102:	89 f2                	mov    %esi,%edx
  802104:	f7 f7                	div    %edi
  802106:	89 d0                	mov    %edx,%eax
  802108:	31 d2                	xor    %edx,%edx
  80210a:	83 c4 1c             	add    $0x1c,%esp
  80210d:	5b                   	pop    %ebx
  80210e:	5e                   	pop    %esi
  80210f:	5f                   	pop    %edi
  802110:	5d                   	pop    %ebp
  802111:	c3                   	ret    
  802112:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802118:	39 f2                	cmp    %esi,%edx
  80211a:	89 d0                	mov    %edx,%eax
  80211c:	77 52                	ja     802170 <__umoddi3+0xa0>
  80211e:	0f bd ea             	bsr    %edx,%ebp
  802121:	83 f5 1f             	xor    $0x1f,%ebp
  802124:	75 5a                	jne    802180 <__umoddi3+0xb0>
  802126:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80212a:	0f 82 e0 00 00 00    	jb     802210 <__umoddi3+0x140>
  802130:	39 0c 24             	cmp    %ecx,(%esp)
  802133:	0f 86 d7 00 00 00    	jbe    802210 <__umoddi3+0x140>
  802139:	8b 44 24 08          	mov    0x8(%esp),%eax
  80213d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802141:	83 c4 1c             	add    $0x1c,%esp
  802144:	5b                   	pop    %ebx
  802145:	5e                   	pop    %esi
  802146:	5f                   	pop    %edi
  802147:	5d                   	pop    %ebp
  802148:	c3                   	ret    
  802149:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802150:	85 ff                	test   %edi,%edi
  802152:	89 fd                	mov    %edi,%ebp
  802154:	75 0b                	jne    802161 <__umoddi3+0x91>
  802156:	b8 01 00 00 00       	mov    $0x1,%eax
  80215b:	31 d2                	xor    %edx,%edx
  80215d:	f7 f7                	div    %edi
  80215f:	89 c5                	mov    %eax,%ebp
  802161:	89 f0                	mov    %esi,%eax
  802163:	31 d2                	xor    %edx,%edx
  802165:	f7 f5                	div    %ebp
  802167:	89 c8                	mov    %ecx,%eax
  802169:	f7 f5                	div    %ebp
  80216b:	89 d0                	mov    %edx,%eax
  80216d:	eb 99                	jmp    802108 <__umoddi3+0x38>
  80216f:	90                   	nop
  802170:	89 c8                	mov    %ecx,%eax
  802172:	89 f2                	mov    %esi,%edx
  802174:	83 c4 1c             	add    $0x1c,%esp
  802177:	5b                   	pop    %ebx
  802178:	5e                   	pop    %esi
  802179:	5f                   	pop    %edi
  80217a:	5d                   	pop    %ebp
  80217b:	c3                   	ret    
  80217c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802180:	8b 34 24             	mov    (%esp),%esi
  802183:	bf 20 00 00 00       	mov    $0x20,%edi
  802188:	89 e9                	mov    %ebp,%ecx
  80218a:	29 ef                	sub    %ebp,%edi
  80218c:	d3 e0                	shl    %cl,%eax
  80218e:	89 f9                	mov    %edi,%ecx
  802190:	89 f2                	mov    %esi,%edx
  802192:	d3 ea                	shr    %cl,%edx
  802194:	89 e9                	mov    %ebp,%ecx
  802196:	09 c2                	or     %eax,%edx
  802198:	89 d8                	mov    %ebx,%eax
  80219a:	89 14 24             	mov    %edx,(%esp)
  80219d:	89 f2                	mov    %esi,%edx
  80219f:	d3 e2                	shl    %cl,%edx
  8021a1:	89 f9                	mov    %edi,%ecx
  8021a3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021a7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8021ab:	d3 e8                	shr    %cl,%eax
  8021ad:	89 e9                	mov    %ebp,%ecx
  8021af:	89 c6                	mov    %eax,%esi
  8021b1:	d3 e3                	shl    %cl,%ebx
  8021b3:	89 f9                	mov    %edi,%ecx
  8021b5:	89 d0                	mov    %edx,%eax
  8021b7:	d3 e8                	shr    %cl,%eax
  8021b9:	89 e9                	mov    %ebp,%ecx
  8021bb:	09 d8                	or     %ebx,%eax
  8021bd:	89 d3                	mov    %edx,%ebx
  8021bf:	89 f2                	mov    %esi,%edx
  8021c1:	f7 34 24             	divl   (%esp)
  8021c4:	89 d6                	mov    %edx,%esi
  8021c6:	d3 e3                	shl    %cl,%ebx
  8021c8:	f7 64 24 04          	mull   0x4(%esp)
  8021cc:	39 d6                	cmp    %edx,%esi
  8021ce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021d2:	89 d1                	mov    %edx,%ecx
  8021d4:	89 c3                	mov    %eax,%ebx
  8021d6:	72 08                	jb     8021e0 <__umoddi3+0x110>
  8021d8:	75 11                	jne    8021eb <__umoddi3+0x11b>
  8021da:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8021de:	73 0b                	jae    8021eb <__umoddi3+0x11b>
  8021e0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8021e4:	1b 14 24             	sbb    (%esp),%edx
  8021e7:	89 d1                	mov    %edx,%ecx
  8021e9:	89 c3                	mov    %eax,%ebx
  8021eb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8021ef:	29 da                	sub    %ebx,%edx
  8021f1:	19 ce                	sbb    %ecx,%esi
  8021f3:	89 f9                	mov    %edi,%ecx
  8021f5:	89 f0                	mov    %esi,%eax
  8021f7:	d3 e0                	shl    %cl,%eax
  8021f9:	89 e9                	mov    %ebp,%ecx
  8021fb:	d3 ea                	shr    %cl,%edx
  8021fd:	89 e9                	mov    %ebp,%ecx
  8021ff:	d3 ee                	shr    %cl,%esi
  802201:	09 d0                	or     %edx,%eax
  802203:	89 f2                	mov    %esi,%edx
  802205:	83 c4 1c             	add    $0x1c,%esp
  802208:	5b                   	pop    %ebx
  802209:	5e                   	pop    %esi
  80220a:	5f                   	pop    %edi
  80220b:	5d                   	pop    %ebp
  80220c:	c3                   	ret    
  80220d:	8d 76 00             	lea    0x0(%esi),%esi
  802210:	29 f9                	sub    %edi,%ecx
  802212:	19 d6                	sbb    %edx,%esi
  802214:	89 74 24 04          	mov    %esi,0x4(%esp)
  802218:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80221c:	e9 18 ff ff ff       	jmp    802139 <__umoddi3+0x69>
