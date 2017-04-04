
obj/user/testpipe.debug:     file format elf32-i386


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
  80002c:	e8 81 02 00 00       	call   8002b2 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

char *msg = "Now is the time for all good men to come to the aid of their party.";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 7c             	sub    $0x7c,%esp
	char buf[100];
	int i, pid, p[2];

	binaryname = "pipereadeof";
  80003b:	c7 05 04 30 80 00 60 	movl   $0x802360,0x803004
  800042:	23 80 00 

	if ((i = pipe(p)) < 0)
  800045:	8d 45 8c             	lea    -0x74(%ebp),%eax
  800048:	50                   	push   %eax
  800049:	e8 68 1b 00 00       	call   801bb6 <pipe>
  80004e:	89 c6                	mov    %eax,%esi
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	85 c0                	test   %eax,%eax
  800055:	79 12                	jns    800069 <umain+0x36>
		panic("pipe: %e", i);
  800057:	50                   	push   %eax
  800058:	68 6c 23 80 00       	push   $0x80236c
  80005d:	6a 0e                	push   $0xe
  80005f:	68 75 23 80 00       	push   $0x802375
  800064:	e8 a9 02 00 00       	call   800312 <_panic>

	if ((pid = fork()) < 0)
  800069:	e8 49 10 00 00       	call   8010b7 <fork>
  80006e:	89 c3                	mov    %eax,%ebx
  800070:	85 c0                	test   %eax,%eax
  800072:	79 12                	jns    800086 <umain+0x53>
		panic("fork: %e", i);
  800074:	56                   	push   %esi
  800075:	68 53 28 80 00       	push   $0x802853
  80007a:	6a 11                	push   $0x11
  80007c:	68 75 23 80 00       	push   $0x802375
  800081:	e8 8c 02 00 00       	call   800312 <_panic>

	if (pid == 0) {
  800086:	85 c0                	test   %eax,%eax
  800088:	0f 85 b8 00 00 00    	jne    800146 <umain+0x113>
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[1]);
  80008e:	a1 04 40 80 00       	mov    0x804004,%eax
  800093:	8b 40 48             	mov    0x48(%eax),%eax
  800096:	83 ec 04             	sub    $0x4,%esp
  800099:	ff 75 90             	pushl  -0x70(%ebp)
  80009c:	50                   	push   %eax
  80009d:	68 85 23 80 00       	push   $0x802385
  8000a2:	e8 44 03 00 00       	call   8003eb <cprintf>
		close(p[1]);
  8000a7:	83 c4 04             	add    $0x4,%esp
  8000aa:	ff 75 90             	pushl  -0x70(%ebp)
  8000ad:	e8 9a 12 00 00       	call   80134c <close>
		cprintf("[%08x] pipereadeof readn %d\n", thisenv->env_id, p[0]);
  8000b2:	a1 04 40 80 00       	mov    0x804004,%eax
  8000b7:	8b 40 48             	mov    0x48(%eax),%eax
  8000ba:	83 c4 0c             	add    $0xc,%esp
  8000bd:	ff 75 8c             	pushl  -0x74(%ebp)
  8000c0:	50                   	push   %eax
  8000c1:	68 a2 23 80 00       	push   $0x8023a2
  8000c6:	e8 20 03 00 00       	call   8003eb <cprintf>
		i = readn(p[0], buf, sizeof buf-1);
  8000cb:	83 c4 0c             	add    $0xc,%esp
  8000ce:	6a 63                	push   $0x63
  8000d0:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8000d3:	50                   	push   %eax
  8000d4:	ff 75 8c             	pushl  -0x74(%ebp)
  8000d7:	e8 3d 14 00 00       	call   801519 <readn>
  8000dc:	89 c6                	mov    %eax,%esi
		if (i < 0)
  8000de:	83 c4 10             	add    $0x10,%esp
  8000e1:	85 c0                	test   %eax,%eax
  8000e3:	79 12                	jns    8000f7 <umain+0xc4>
			panic("read: %e", i);
  8000e5:	50                   	push   %eax
  8000e6:	68 bf 23 80 00       	push   $0x8023bf
  8000eb:	6a 19                	push   $0x19
  8000ed:	68 75 23 80 00       	push   $0x802375
  8000f2:	e8 1b 02 00 00       	call   800312 <_panic>
		buf[i] = 0;
  8000f7:	c6 44 05 94 00       	movb   $0x0,-0x6c(%ebp,%eax,1)
		if (strcmp(buf, msg) == 0)
  8000fc:	83 ec 08             	sub    $0x8,%esp
  8000ff:	ff 35 00 30 80 00    	pushl  0x803000
  800105:	8d 45 94             	lea    -0x6c(%ebp),%eax
  800108:	50                   	push   %eax
  800109:	e8 0c 09 00 00       	call   800a1a <strcmp>
  80010e:	83 c4 10             	add    $0x10,%esp
  800111:	85 c0                	test   %eax,%eax
  800113:	75 12                	jne    800127 <umain+0xf4>
			cprintf("\npipe read closed properly\n");
  800115:	83 ec 0c             	sub    $0xc,%esp
  800118:	68 c8 23 80 00       	push   $0x8023c8
  80011d:	e8 c9 02 00 00       	call   8003eb <cprintf>
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	eb 15                	jmp    80013c <umain+0x109>
		else
			cprintf("\ngot %d bytes: %s\n", i, buf);
  800127:	83 ec 04             	sub    $0x4,%esp
  80012a:	8d 45 94             	lea    -0x6c(%ebp),%eax
  80012d:	50                   	push   %eax
  80012e:	56                   	push   %esi
  80012f:	68 e4 23 80 00       	push   $0x8023e4
  800134:	e8 b2 02 00 00       	call   8003eb <cprintf>
  800139:	83 c4 10             	add    $0x10,%esp
		exit();
  80013c:	e8 b7 01 00 00       	call   8002f8 <exit>
  800141:	e9 94 00 00 00       	jmp    8001da <umain+0x1a7>
	} else {
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[0]);
  800146:	a1 04 40 80 00       	mov    0x804004,%eax
  80014b:	8b 40 48             	mov    0x48(%eax),%eax
  80014e:	83 ec 04             	sub    $0x4,%esp
  800151:	ff 75 8c             	pushl  -0x74(%ebp)
  800154:	50                   	push   %eax
  800155:	68 85 23 80 00       	push   $0x802385
  80015a:	e8 8c 02 00 00       	call   8003eb <cprintf>
		close(p[0]);
  80015f:	83 c4 04             	add    $0x4,%esp
  800162:	ff 75 8c             	pushl  -0x74(%ebp)
  800165:	e8 e2 11 00 00       	call   80134c <close>
		cprintf("[%08x] pipereadeof write %d\n", thisenv->env_id, p[1]);
  80016a:	a1 04 40 80 00       	mov    0x804004,%eax
  80016f:	8b 40 48             	mov    0x48(%eax),%eax
  800172:	83 c4 0c             	add    $0xc,%esp
  800175:	ff 75 90             	pushl  -0x70(%ebp)
  800178:	50                   	push   %eax
  800179:	68 f7 23 80 00       	push   $0x8023f7
  80017e:	e8 68 02 00 00       	call   8003eb <cprintf>
		if ((i = write(p[1], msg, strlen(msg))) != strlen(msg))
  800183:	83 c4 04             	add    $0x4,%esp
  800186:	ff 35 00 30 80 00    	pushl  0x803000
  80018c:	e8 a6 07 00 00       	call   800937 <strlen>
  800191:	83 c4 0c             	add    $0xc,%esp
  800194:	50                   	push   %eax
  800195:	ff 35 00 30 80 00    	pushl  0x803000
  80019b:	ff 75 90             	pushl  -0x70(%ebp)
  80019e:	e8 bf 13 00 00       	call   801562 <write>
  8001a3:	89 c6                	mov    %eax,%esi
  8001a5:	83 c4 04             	add    $0x4,%esp
  8001a8:	ff 35 00 30 80 00    	pushl  0x803000
  8001ae:	e8 84 07 00 00       	call   800937 <strlen>
  8001b3:	83 c4 10             	add    $0x10,%esp
  8001b6:	39 c6                	cmp    %eax,%esi
  8001b8:	74 12                	je     8001cc <umain+0x199>
			panic("write: %e", i);
  8001ba:	56                   	push   %esi
  8001bb:	68 14 24 80 00       	push   $0x802414
  8001c0:	6a 25                	push   $0x25
  8001c2:	68 75 23 80 00       	push   $0x802375
  8001c7:	e8 46 01 00 00       	call   800312 <_panic>
		close(p[1]);
  8001cc:	83 ec 0c             	sub    $0xc,%esp
  8001cf:	ff 75 90             	pushl  -0x70(%ebp)
  8001d2:	e8 75 11 00 00       	call   80134c <close>
  8001d7:	83 c4 10             	add    $0x10,%esp
	}
	wait(pid);
  8001da:	83 ec 0c             	sub    $0xc,%esp
  8001dd:	53                   	push   %ebx
  8001de:	e8 59 1b 00 00       	call   801d3c <wait>

	binaryname = "pipewriteeof";
  8001e3:	c7 05 04 30 80 00 1e 	movl   $0x80241e,0x803004
  8001ea:	24 80 00 
	if ((i = pipe(p)) < 0)
  8001ed:	8d 45 8c             	lea    -0x74(%ebp),%eax
  8001f0:	89 04 24             	mov    %eax,(%esp)
  8001f3:	e8 be 19 00 00       	call   801bb6 <pipe>
  8001f8:	89 c6                	mov    %eax,%esi
  8001fa:	83 c4 10             	add    $0x10,%esp
  8001fd:	85 c0                	test   %eax,%eax
  8001ff:	79 12                	jns    800213 <umain+0x1e0>
		panic("pipe: %e", i);
  800201:	50                   	push   %eax
  800202:	68 6c 23 80 00       	push   $0x80236c
  800207:	6a 2c                	push   $0x2c
  800209:	68 75 23 80 00       	push   $0x802375
  80020e:	e8 ff 00 00 00       	call   800312 <_panic>

	if ((pid = fork()) < 0)
  800213:	e8 9f 0e 00 00       	call   8010b7 <fork>
  800218:	89 c3                	mov    %eax,%ebx
  80021a:	85 c0                	test   %eax,%eax
  80021c:	79 12                	jns    800230 <umain+0x1fd>
		panic("fork: %e", i);
  80021e:	56                   	push   %esi
  80021f:	68 53 28 80 00       	push   $0x802853
  800224:	6a 2f                	push   $0x2f
  800226:	68 75 23 80 00       	push   $0x802375
  80022b:	e8 e2 00 00 00       	call   800312 <_panic>

	if (pid == 0) {
  800230:	85 c0                	test   %eax,%eax
  800232:	75 4a                	jne    80027e <umain+0x24b>
		close(p[0]);
  800234:	83 ec 0c             	sub    $0xc,%esp
  800237:	ff 75 8c             	pushl  -0x74(%ebp)
  80023a:	e8 0d 11 00 00       	call   80134c <close>
  80023f:	83 c4 10             	add    $0x10,%esp
		while (1) {
			cprintf(".");
  800242:	83 ec 0c             	sub    $0xc,%esp
  800245:	68 2b 24 80 00       	push   $0x80242b
  80024a:	e8 9c 01 00 00       	call   8003eb <cprintf>
			if (write(p[1], "x", 1) != 1)
  80024f:	83 c4 0c             	add    $0xc,%esp
  800252:	6a 01                	push   $0x1
  800254:	68 2d 24 80 00       	push   $0x80242d
  800259:	ff 75 90             	pushl  -0x70(%ebp)
  80025c:	e8 01 13 00 00       	call   801562 <write>
  800261:	83 c4 10             	add    $0x10,%esp
  800264:	83 f8 01             	cmp    $0x1,%eax
  800267:	74 d9                	je     800242 <umain+0x20f>
				break;
		}
		cprintf("\npipe write closed properly\n");
  800269:	83 ec 0c             	sub    $0xc,%esp
  80026c:	68 2f 24 80 00       	push   $0x80242f
  800271:	e8 75 01 00 00       	call   8003eb <cprintf>
		exit();
  800276:	e8 7d 00 00 00       	call   8002f8 <exit>
  80027b:	83 c4 10             	add    $0x10,%esp
	}
	close(p[0]);
  80027e:	83 ec 0c             	sub    $0xc,%esp
  800281:	ff 75 8c             	pushl  -0x74(%ebp)
  800284:	e8 c3 10 00 00       	call   80134c <close>
	close(p[1]);
  800289:	83 c4 04             	add    $0x4,%esp
  80028c:	ff 75 90             	pushl  -0x70(%ebp)
  80028f:	e8 b8 10 00 00       	call   80134c <close>
	wait(pid);
  800294:	89 1c 24             	mov    %ebx,(%esp)
  800297:	e8 a0 1a 00 00       	call   801d3c <wait>

	cprintf("pipe tests passed\n");
  80029c:	c7 04 24 4c 24 80 00 	movl   $0x80244c,(%esp)
  8002a3:	e8 43 01 00 00       	call   8003eb <cprintf>
}
  8002a8:	83 c4 10             	add    $0x10,%esp
  8002ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002ae:	5b                   	pop    %ebx
  8002af:	5e                   	pop    %esi
  8002b0:	5d                   	pop    %ebp
  8002b1:	c3                   	ret    

008002b2 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8002b2:	55                   	push   %ebp
  8002b3:	89 e5                	mov    %esp,%ebp
  8002b5:	56                   	push   %esi
  8002b6:	53                   	push   %ebx
  8002b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002ba:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8002bd:	e8 73 0a 00 00       	call   800d35 <sys_getenvid>
  8002c2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002c7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8002ca:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002cf:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002d4:	85 db                	test   %ebx,%ebx
  8002d6:	7e 07                	jle    8002df <libmain+0x2d>
		binaryname = argv[0];
  8002d8:	8b 06                	mov    (%esi),%eax
  8002da:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  8002df:	83 ec 08             	sub    $0x8,%esp
  8002e2:	56                   	push   %esi
  8002e3:	53                   	push   %ebx
  8002e4:	e8 4a fd ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8002e9:	e8 0a 00 00 00       	call   8002f8 <exit>
}
  8002ee:	83 c4 10             	add    $0x10,%esp
  8002f1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002f4:	5b                   	pop    %ebx
  8002f5:	5e                   	pop    %esi
  8002f6:	5d                   	pop    %ebp
  8002f7:	c3                   	ret    

008002f8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8002f8:	55                   	push   %ebp
  8002f9:	89 e5                	mov    %esp,%ebp
  8002fb:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8002fe:	e8 74 10 00 00       	call   801377 <close_all>
	sys_env_destroy(0);
  800303:	83 ec 0c             	sub    $0xc,%esp
  800306:	6a 00                	push   $0x0
  800308:	e8 e7 09 00 00       	call   800cf4 <sys_env_destroy>
}
  80030d:	83 c4 10             	add    $0x10,%esp
  800310:	c9                   	leave  
  800311:	c3                   	ret    

00800312 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800312:	55                   	push   %ebp
  800313:	89 e5                	mov    %esp,%ebp
  800315:	56                   	push   %esi
  800316:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800317:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80031a:	8b 35 04 30 80 00    	mov    0x803004,%esi
  800320:	e8 10 0a 00 00       	call   800d35 <sys_getenvid>
  800325:	83 ec 0c             	sub    $0xc,%esp
  800328:	ff 75 0c             	pushl  0xc(%ebp)
  80032b:	ff 75 08             	pushl  0x8(%ebp)
  80032e:	56                   	push   %esi
  80032f:	50                   	push   %eax
  800330:	68 b0 24 80 00       	push   $0x8024b0
  800335:	e8 b1 00 00 00       	call   8003eb <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80033a:	83 c4 18             	add    $0x18,%esp
  80033d:	53                   	push   %ebx
  80033e:	ff 75 10             	pushl  0x10(%ebp)
  800341:	e8 54 00 00 00       	call   80039a <vcprintf>
	cprintf("\n");
  800346:	c7 04 24 a0 23 80 00 	movl   $0x8023a0,(%esp)
  80034d:	e8 99 00 00 00       	call   8003eb <cprintf>
  800352:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800355:	cc                   	int3   
  800356:	eb fd                	jmp    800355 <_panic+0x43>

00800358 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800358:	55                   	push   %ebp
  800359:	89 e5                	mov    %esp,%ebp
  80035b:	53                   	push   %ebx
  80035c:	83 ec 04             	sub    $0x4,%esp
  80035f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800362:	8b 13                	mov    (%ebx),%edx
  800364:	8d 42 01             	lea    0x1(%edx),%eax
  800367:	89 03                	mov    %eax,(%ebx)
  800369:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80036c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800370:	3d ff 00 00 00       	cmp    $0xff,%eax
  800375:	75 1a                	jne    800391 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800377:	83 ec 08             	sub    $0x8,%esp
  80037a:	68 ff 00 00 00       	push   $0xff
  80037f:	8d 43 08             	lea    0x8(%ebx),%eax
  800382:	50                   	push   %eax
  800383:	e8 2f 09 00 00       	call   800cb7 <sys_cputs>
		b->idx = 0;
  800388:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80038e:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800391:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800395:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800398:	c9                   	leave  
  800399:	c3                   	ret    

0080039a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80039a:	55                   	push   %ebp
  80039b:	89 e5                	mov    %esp,%ebp
  80039d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003a3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003aa:	00 00 00 
	b.cnt = 0;
  8003ad:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003b4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003b7:	ff 75 0c             	pushl  0xc(%ebp)
  8003ba:	ff 75 08             	pushl  0x8(%ebp)
  8003bd:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003c3:	50                   	push   %eax
  8003c4:	68 58 03 80 00       	push   $0x800358
  8003c9:	e8 54 01 00 00       	call   800522 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003ce:	83 c4 08             	add    $0x8,%esp
  8003d1:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003d7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003dd:	50                   	push   %eax
  8003de:	e8 d4 08 00 00       	call   800cb7 <sys_cputs>

	return b.cnt;
}
  8003e3:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003e9:	c9                   	leave  
  8003ea:	c3                   	ret    

008003eb <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003eb:	55                   	push   %ebp
  8003ec:	89 e5                	mov    %esp,%ebp
  8003ee:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003f1:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003f4:	50                   	push   %eax
  8003f5:	ff 75 08             	pushl  0x8(%ebp)
  8003f8:	e8 9d ff ff ff       	call   80039a <vcprintf>
	va_end(ap);

	return cnt;
}
  8003fd:	c9                   	leave  
  8003fe:	c3                   	ret    

008003ff <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003ff:	55                   	push   %ebp
  800400:	89 e5                	mov    %esp,%ebp
  800402:	57                   	push   %edi
  800403:	56                   	push   %esi
  800404:	53                   	push   %ebx
  800405:	83 ec 1c             	sub    $0x1c,%esp
  800408:	89 c7                	mov    %eax,%edi
  80040a:	89 d6                	mov    %edx,%esi
  80040c:	8b 45 08             	mov    0x8(%ebp),%eax
  80040f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800412:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800415:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800418:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80041b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800420:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800423:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800426:	39 d3                	cmp    %edx,%ebx
  800428:	72 05                	jb     80042f <printnum+0x30>
  80042a:	39 45 10             	cmp    %eax,0x10(%ebp)
  80042d:	77 45                	ja     800474 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80042f:	83 ec 0c             	sub    $0xc,%esp
  800432:	ff 75 18             	pushl  0x18(%ebp)
  800435:	8b 45 14             	mov    0x14(%ebp),%eax
  800438:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80043b:	53                   	push   %ebx
  80043c:	ff 75 10             	pushl  0x10(%ebp)
  80043f:	83 ec 08             	sub    $0x8,%esp
  800442:	ff 75 e4             	pushl  -0x1c(%ebp)
  800445:	ff 75 e0             	pushl  -0x20(%ebp)
  800448:	ff 75 dc             	pushl  -0x24(%ebp)
  80044b:	ff 75 d8             	pushl  -0x28(%ebp)
  80044e:	e8 6d 1c 00 00       	call   8020c0 <__udivdi3>
  800453:	83 c4 18             	add    $0x18,%esp
  800456:	52                   	push   %edx
  800457:	50                   	push   %eax
  800458:	89 f2                	mov    %esi,%edx
  80045a:	89 f8                	mov    %edi,%eax
  80045c:	e8 9e ff ff ff       	call   8003ff <printnum>
  800461:	83 c4 20             	add    $0x20,%esp
  800464:	eb 18                	jmp    80047e <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800466:	83 ec 08             	sub    $0x8,%esp
  800469:	56                   	push   %esi
  80046a:	ff 75 18             	pushl  0x18(%ebp)
  80046d:	ff d7                	call   *%edi
  80046f:	83 c4 10             	add    $0x10,%esp
  800472:	eb 03                	jmp    800477 <printnum+0x78>
  800474:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800477:	83 eb 01             	sub    $0x1,%ebx
  80047a:	85 db                	test   %ebx,%ebx
  80047c:	7f e8                	jg     800466 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80047e:	83 ec 08             	sub    $0x8,%esp
  800481:	56                   	push   %esi
  800482:	83 ec 04             	sub    $0x4,%esp
  800485:	ff 75 e4             	pushl  -0x1c(%ebp)
  800488:	ff 75 e0             	pushl  -0x20(%ebp)
  80048b:	ff 75 dc             	pushl  -0x24(%ebp)
  80048e:	ff 75 d8             	pushl  -0x28(%ebp)
  800491:	e8 5a 1d 00 00       	call   8021f0 <__umoddi3>
  800496:	83 c4 14             	add    $0x14,%esp
  800499:	0f be 80 d3 24 80 00 	movsbl 0x8024d3(%eax),%eax
  8004a0:	50                   	push   %eax
  8004a1:	ff d7                	call   *%edi
}
  8004a3:	83 c4 10             	add    $0x10,%esp
  8004a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004a9:	5b                   	pop    %ebx
  8004aa:	5e                   	pop    %esi
  8004ab:	5f                   	pop    %edi
  8004ac:	5d                   	pop    %ebp
  8004ad:	c3                   	ret    

008004ae <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004ae:	55                   	push   %ebp
  8004af:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004b1:	83 fa 01             	cmp    $0x1,%edx
  8004b4:	7e 0e                	jle    8004c4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004b6:	8b 10                	mov    (%eax),%edx
  8004b8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004bb:	89 08                	mov    %ecx,(%eax)
  8004bd:	8b 02                	mov    (%edx),%eax
  8004bf:	8b 52 04             	mov    0x4(%edx),%edx
  8004c2:	eb 22                	jmp    8004e6 <getuint+0x38>
	else if (lflag)
  8004c4:	85 d2                	test   %edx,%edx
  8004c6:	74 10                	je     8004d8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004c8:	8b 10                	mov    (%eax),%edx
  8004ca:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004cd:	89 08                	mov    %ecx,(%eax)
  8004cf:	8b 02                	mov    (%edx),%eax
  8004d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8004d6:	eb 0e                	jmp    8004e6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004d8:	8b 10                	mov    (%eax),%edx
  8004da:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004dd:	89 08                	mov    %ecx,(%eax)
  8004df:	8b 02                	mov    (%edx),%eax
  8004e1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004e6:	5d                   	pop    %ebp
  8004e7:	c3                   	ret    

008004e8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004e8:	55                   	push   %ebp
  8004e9:	89 e5                	mov    %esp,%ebp
  8004eb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004ee:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004f2:	8b 10                	mov    (%eax),%edx
  8004f4:	3b 50 04             	cmp    0x4(%eax),%edx
  8004f7:	73 0a                	jae    800503 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004f9:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004fc:	89 08                	mov    %ecx,(%eax)
  8004fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800501:	88 02                	mov    %al,(%edx)
}
  800503:	5d                   	pop    %ebp
  800504:	c3                   	ret    

00800505 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800505:	55                   	push   %ebp
  800506:	89 e5                	mov    %esp,%ebp
  800508:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80050b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80050e:	50                   	push   %eax
  80050f:	ff 75 10             	pushl  0x10(%ebp)
  800512:	ff 75 0c             	pushl  0xc(%ebp)
  800515:	ff 75 08             	pushl  0x8(%ebp)
  800518:	e8 05 00 00 00       	call   800522 <vprintfmt>
	va_end(ap);
}
  80051d:	83 c4 10             	add    $0x10,%esp
  800520:	c9                   	leave  
  800521:	c3                   	ret    

00800522 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800522:	55                   	push   %ebp
  800523:	89 e5                	mov    %esp,%ebp
  800525:	57                   	push   %edi
  800526:	56                   	push   %esi
  800527:	53                   	push   %ebx
  800528:	83 ec 2c             	sub    $0x2c,%esp
  80052b:	8b 75 08             	mov    0x8(%ebp),%esi
  80052e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800531:	8b 7d 10             	mov    0x10(%ebp),%edi
  800534:	eb 12                	jmp    800548 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800536:	85 c0                	test   %eax,%eax
  800538:	0f 84 89 03 00 00    	je     8008c7 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80053e:	83 ec 08             	sub    $0x8,%esp
  800541:	53                   	push   %ebx
  800542:	50                   	push   %eax
  800543:	ff d6                	call   *%esi
  800545:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800548:	83 c7 01             	add    $0x1,%edi
  80054b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80054f:	83 f8 25             	cmp    $0x25,%eax
  800552:	75 e2                	jne    800536 <vprintfmt+0x14>
  800554:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800558:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80055f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800566:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80056d:	ba 00 00 00 00       	mov    $0x0,%edx
  800572:	eb 07                	jmp    80057b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800574:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800577:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057b:	8d 47 01             	lea    0x1(%edi),%eax
  80057e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800581:	0f b6 07             	movzbl (%edi),%eax
  800584:	0f b6 c8             	movzbl %al,%ecx
  800587:	83 e8 23             	sub    $0x23,%eax
  80058a:	3c 55                	cmp    $0x55,%al
  80058c:	0f 87 1a 03 00 00    	ja     8008ac <vprintfmt+0x38a>
  800592:	0f b6 c0             	movzbl %al,%eax
  800595:	ff 24 85 20 26 80 00 	jmp    *0x802620(,%eax,4)
  80059c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80059f:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005a3:	eb d6                	jmp    80057b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8005ad:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005b0:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005b3:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005b7:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005ba:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005bd:	83 fa 09             	cmp    $0x9,%edx
  8005c0:	77 39                	ja     8005fb <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005c2:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005c5:	eb e9                	jmp    8005b0 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ca:	8d 48 04             	lea    0x4(%eax),%ecx
  8005cd:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005d0:	8b 00                	mov    (%eax),%eax
  8005d2:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005d8:	eb 27                	jmp    800601 <vprintfmt+0xdf>
  8005da:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005dd:	85 c0                	test   %eax,%eax
  8005df:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005e4:	0f 49 c8             	cmovns %eax,%ecx
  8005e7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ed:	eb 8c                	jmp    80057b <vprintfmt+0x59>
  8005ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005f2:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005f9:	eb 80                	jmp    80057b <vprintfmt+0x59>
  8005fb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005fe:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800601:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800605:	0f 89 70 ff ff ff    	jns    80057b <vprintfmt+0x59>
				width = precision, precision = -1;
  80060b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80060e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800611:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800618:	e9 5e ff ff ff       	jmp    80057b <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80061d:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800620:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800623:	e9 53 ff ff ff       	jmp    80057b <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800628:	8b 45 14             	mov    0x14(%ebp),%eax
  80062b:	8d 50 04             	lea    0x4(%eax),%edx
  80062e:	89 55 14             	mov    %edx,0x14(%ebp)
  800631:	83 ec 08             	sub    $0x8,%esp
  800634:	53                   	push   %ebx
  800635:	ff 30                	pushl  (%eax)
  800637:	ff d6                	call   *%esi
			break;
  800639:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80063f:	e9 04 ff ff ff       	jmp    800548 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800644:	8b 45 14             	mov    0x14(%ebp),%eax
  800647:	8d 50 04             	lea    0x4(%eax),%edx
  80064a:	89 55 14             	mov    %edx,0x14(%ebp)
  80064d:	8b 00                	mov    (%eax),%eax
  80064f:	99                   	cltd   
  800650:	31 d0                	xor    %edx,%eax
  800652:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800654:	83 f8 0f             	cmp    $0xf,%eax
  800657:	7f 0b                	jg     800664 <vprintfmt+0x142>
  800659:	8b 14 85 80 27 80 00 	mov    0x802780(,%eax,4),%edx
  800660:	85 d2                	test   %edx,%edx
  800662:	75 18                	jne    80067c <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800664:	50                   	push   %eax
  800665:	68 eb 24 80 00       	push   $0x8024eb
  80066a:	53                   	push   %ebx
  80066b:	56                   	push   %esi
  80066c:	e8 94 fe ff ff       	call   800505 <printfmt>
  800671:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800674:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800677:	e9 cc fe ff ff       	jmp    800548 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80067c:	52                   	push   %edx
  80067d:	68 6e 29 80 00       	push   $0x80296e
  800682:	53                   	push   %ebx
  800683:	56                   	push   %esi
  800684:	e8 7c fe ff ff       	call   800505 <printfmt>
  800689:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80068f:	e9 b4 fe ff ff       	jmp    800548 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800694:	8b 45 14             	mov    0x14(%ebp),%eax
  800697:	8d 50 04             	lea    0x4(%eax),%edx
  80069a:	89 55 14             	mov    %edx,0x14(%ebp)
  80069d:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80069f:	85 ff                	test   %edi,%edi
  8006a1:	b8 e4 24 80 00       	mov    $0x8024e4,%eax
  8006a6:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8006a9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006ad:	0f 8e 94 00 00 00    	jle    800747 <vprintfmt+0x225>
  8006b3:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006b7:	0f 84 98 00 00 00    	je     800755 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006bd:	83 ec 08             	sub    $0x8,%esp
  8006c0:	ff 75 d0             	pushl  -0x30(%ebp)
  8006c3:	57                   	push   %edi
  8006c4:	e8 86 02 00 00       	call   80094f <strnlen>
  8006c9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006cc:	29 c1                	sub    %eax,%ecx
  8006ce:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006d1:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006d4:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006d8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006db:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006de:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006e0:	eb 0f                	jmp    8006f1 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8006e2:	83 ec 08             	sub    $0x8,%esp
  8006e5:	53                   	push   %ebx
  8006e6:	ff 75 e0             	pushl  -0x20(%ebp)
  8006e9:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006eb:	83 ef 01             	sub    $0x1,%edi
  8006ee:	83 c4 10             	add    $0x10,%esp
  8006f1:	85 ff                	test   %edi,%edi
  8006f3:	7f ed                	jg     8006e2 <vprintfmt+0x1c0>
  8006f5:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006f8:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006fb:	85 c9                	test   %ecx,%ecx
  8006fd:	b8 00 00 00 00       	mov    $0x0,%eax
  800702:	0f 49 c1             	cmovns %ecx,%eax
  800705:	29 c1                	sub    %eax,%ecx
  800707:	89 75 08             	mov    %esi,0x8(%ebp)
  80070a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80070d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800710:	89 cb                	mov    %ecx,%ebx
  800712:	eb 4d                	jmp    800761 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800714:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800718:	74 1b                	je     800735 <vprintfmt+0x213>
  80071a:	0f be c0             	movsbl %al,%eax
  80071d:	83 e8 20             	sub    $0x20,%eax
  800720:	83 f8 5e             	cmp    $0x5e,%eax
  800723:	76 10                	jbe    800735 <vprintfmt+0x213>
					putch('?', putdat);
  800725:	83 ec 08             	sub    $0x8,%esp
  800728:	ff 75 0c             	pushl  0xc(%ebp)
  80072b:	6a 3f                	push   $0x3f
  80072d:	ff 55 08             	call   *0x8(%ebp)
  800730:	83 c4 10             	add    $0x10,%esp
  800733:	eb 0d                	jmp    800742 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800735:	83 ec 08             	sub    $0x8,%esp
  800738:	ff 75 0c             	pushl  0xc(%ebp)
  80073b:	52                   	push   %edx
  80073c:	ff 55 08             	call   *0x8(%ebp)
  80073f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800742:	83 eb 01             	sub    $0x1,%ebx
  800745:	eb 1a                	jmp    800761 <vprintfmt+0x23f>
  800747:	89 75 08             	mov    %esi,0x8(%ebp)
  80074a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80074d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800750:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800753:	eb 0c                	jmp    800761 <vprintfmt+0x23f>
  800755:	89 75 08             	mov    %esi,0x8(%ebp)
  800758:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80075b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80075e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800761:	83 c7 01             	add    $0x1,%edi
  800764:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800768:	0f be d0             	movsbl %al,%edx
  80076b:	85 d2                	test   %edx,%edx
  80076d:	74 23                	je     800792 <vprintfmt+0x270>
  80076f:	85 f6                	test   %esi,%esi
  800771:	78 a1                	js     800714 <vprintfmt+0x1f2>
  800773:	83 ee 01             	sub    $0x1,%esi
  800776:	79 9c                	jns    800714 <vprintfmt+0x1f2>
  800778:	89 df                	mov    %ebx,%edi
  80077a:	8b 75 08             	mov    0x8(%ebp),%esi
  80077d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800780:	eb 18                	jmp    80079a <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800782:	83 ec 08             	sub    $0x8,%esp
  800785:	53                   	push   %ebx
  800786:	6a 20                	push   $0x20
  800788:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80078a:	83 ef 01             	sub    $0x1,%edi
  80078d:	83 c4 10             	add    $0x10,%esp
  800790:	eb 08                	jmp    80079a <vprintfmt+0x278>
  800792:	89 df                	mov    %ebx,%edi
  800794:	8b 75 08             	mov    0x8(%ebp),%esi
  800797:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80079a:	85 ff                	test   %edi,%edi
  80079c:	7f e4                	jg     800782 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80079e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007a1:	e9 a2 fd ff ff       	jmp    800548 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007a6:	83 fa 01             	cmp    $0x1,%edx
  8007a9:	7e 16                	jle    8007c1 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8007ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ae:	8d 50 08             	lea    0x8(%eax),%edx
  8007b1:	89 55 14             	mov    %edx,0x14(%ebp)
  8007b4:	8b 50 04             	mov    0x4(%eax),%edx
  8007b7:	8b 00                	mov    (%eax),%eax
  8007b9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007bc:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007bf:	eb 32                	jmp    8007f3 <vprintfmt+0x2d1>
	else if (lflag)
  8007c1:	85 d2                	test   %edx,%edx
  8007c3:	74 18                	je     8007dd <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8007c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c8:	8d 50 04             	lea    0x4(%eax),%edx
  8007cb:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ce:	8b 00                	mov    (%eax),%eax
  8007d0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007d3:	89 c1                	mov    %eax,%ecx
  8007d5:	c1 f9 1f             	sar    $0x1f,%ecx
  8007d8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007db:	eb 16                	jmp    8007f3 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8007dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e0:	8d 50 04             	lea    0x4(%eax),%edx
  8007e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e6:	8b 00                	mov    (%eax),%eax
  8007e8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007eb:	89 c1                	mov    %eax,%ecx
  8007ed:	c1 f9 1f             	sar    $0x1f,%ecx
  8007f0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007f3:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007f6:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007f9:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007fe:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800802:	79 74                	jns    800878 <vprintfmt+0x356>
				putch('-', putdat);
  800804:	83 ec 08             	sub    $0x8,%esp
  800807:	53                   	push   %ebx
  800808:	6a 2d                	push   $0x2d
  80080a:	ff d6                	call   *%esi
				num = -(long long) num;
  80080c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80080f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800812:	f7 d8                	neg    %eax
  800814:	83 d2 00             	adc    $0x0,%edx
  800817:	f7 da                	neg    %edx
  800819:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80081c:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800821:	eb 55                	jmp    800878 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800823:	8d 45 14             	lea    0x14(%ebp),%eax
  800826:	e8 83 fc ff ff       	call   8004ae <getuint>
			base = 10;
  80082b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800830:	eb 46                	jmp    800878 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800832:	8d 45 14             	lea    0x14(%ebp),%eax
  800835:	e8 74 fc ff ff       	call   8004ae <getuint>
                        base = 8;
  80083a:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  80083f:	eb 37                	jmp    800878 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800841:	83 ec 08             	sub    $0x8,%esp
  800844:	53                   	push   %ebx
  800845:	6a 30                	push   $0x30
  800847:	ff d6                	call   *%esi
			putch('x', putdat);
  800849:	83 c4 08             	add    $0x8,%esp
  80084c:	53                   	push   %ebx
  80084d:	6a 78                	push   $0x78
  80084f:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800851:	8b 45 14             	mov    0x14(%ebp),%eax
  800854:	8d 50 04             	lea    0x4(%eax),%edx
  800857:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80085a:	8b 00                	mov    (%eax),%eax
  80085c:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800861:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800864:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800869:	eb 0d                	jmp    800878 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80086b:	8d 45 14             	lea    0x14(%ebp),%eax
  80086e:	e8 3b fc ff ff       	call   8004ae <getuint>
			base = 16;
  800873:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800878:	83 ec 0c             	sub    $0xc,%esp
  80087b:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80087f:	57                   	push   %edi
  800880:	ff 75 e0             	pushl  -0x20(%ebp)
  800883:	51                   	push   %ecx
  800884:	52                   	push   %edx
  800885:	50                   	push   %eax
  800886:	89 da                	mov    %ebx,%edx
  800888:	89 f0                	mov    %esi,%eax
  80088a:	e8 70 fb ff ff       	call   8003ff <printnum>
			break;
  80088f:	83 c4 20             	add    $0x20,%esp
  800892:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800895:	e9 ae fc ff ff       	jmp    800548 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80089a:	83 ec 08             	sub    $0x8,%esp
  80089d:	53                   	push   %ebx
  80089e:	51                   	push   %ecx
  80089f:	ff d6                	call   *%esi
			break;
  8008a1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008a7:	e9 9c fc ff ff       	jmp    800548 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008ac:	83 ec 08             	sub    $0x8,%esp
  8008af:	53                   	push   %ebx
  8008b0:	6a 25                	push   $0x25
  8008b2:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008b4:	83 c4 10             	add    $0x10,%esp
  8008b7:	eb 03                	jmp    8008bc <vprintfmt+0x39a>
  8008b9:	83 ef 01             	sub    $0x1,%edi
  8008bc:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8008c0:	75 f7                	jne    8008b9 <vprintfmt+0x397>
  8008c2:	e9 81 fc ff ff       	jmp    800548 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8008c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008ca:	5b                   	pop    %ebx
  8008cb:	5e                   	pop    %esi
  8008cc:	5f                   	pop    %edi
  8008cd:	5d                   	pop    %ebp
  8008ce:	c3                   	ret    

008008cf <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008cf:	55                   	push   %ebp
  8008d0:	89 e5                	mov    %esp,%ebp
  8008d2:	83 ec 18             	sub    $0x18,%esp
  8008d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008db:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008de:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008e2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008e5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008ec:	85 c0                	test   %eax,%eax
  8008ee:	74 26                	je     800916 <vsnprintf+0x47>
  8008f0:	85 d2                	test   %edx,%edx
  8008f2:	7e 22                	jle    800916 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008f4:	ff 75 14             	pushl  0x14(%ebp)
  8008f7:	ff 75 10             	pushl  0x10(%ebp)
  8008fa:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008fd:	50                   	push   %eax
  8008fe:	68 e8 04 80 00       	push   $0x8004e8
  800903:	e8 1a fc ff ff       	call   800522 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800908:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80090b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80090e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800911:	83 c4 10             	add    $0x10,%esp
  800914:	eb 05                	jmp    80091b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800916:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80091b:	c9                   	leave  
  80091c:	c3                   	ret    

0080091d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80091d:	55                   	push   %ebp
  80091e:	89 e5                	mov    %esp,%ebp
  800920:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800923:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800926:	50                   	push   %eax
  800927:	ff 75 10             	pushl  0x10(%ebp)
  80092a:	ff 75 0c             	pushl  0xc(%ebp)
  80092d:	ff 75 08             	pushl  0x8(%ebp)
  800930:	e8 9a ff ff ff       	call   8008cf <vsnprintf>
	va_end(ap);

	return rc;
}
  800935:	c9                   	leave  
  800936:	c3                   	ret    

00800937 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800937:	55                   	push   %ebp
  800938:	89 e5                	mov    %esp,%ebp
  80093a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80093d:	b8 00 00 00 00       	mov    $0x0,%eax
  800942:	eb 03                	jmp    800947 <strlen+0x10>
		n++;
  800944:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800947:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80094b:	75 f7                	jne    800944 <strlen+0xd>
		n++;
	return n;
}
  80094d:	5d                   	pop    %ebp
  80094e:	c3                   	ret    

0080094f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80094f:	55                   	push   %ebp
  800950:	89 e5                	mov    %esp,%ebp
  800952:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800955:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800958:	ba 00 00 00 00       	mov    $0x0,%edx
  80095d:	eb 03                	jmp    800962 <strnlen+0x13>
		n++;
  80095f:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800962:	39 c2                	cmp    %eax,%edx
  800964:	74 08                	je     80096e <strnlen+0x1f>
  800966:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80096a:	75 f3                	jne    80095f <strnlen+0x10>
  80096c:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80096e:	5d                   	pop    %ebp
  80096f:	c3                   	ret    

00800970 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800970:	55                   	push   %ebp
  800971:	89 e5                	mov    %esp,%ebp
  800973:	53                   	push   %ebx
  800974:	8b 45 08             	mov    0x8(%ebp),%eax
  800977:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80097a:	89 c2                	mov    %eax,%edx
  80097c:	83 c2 01             	add    $0x1,%edx
  80097f:	83 c1 01             	add    $0x1,%ecx
  800982:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800986:	88 5a ff             	mov    %bl,-0x1(%edx)
  800989:	84 db                	test   %bl,%bl
  80098b:	75 ef                	jne    80097c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80098d:	5b                   	pop    %ebx
  80098e:	5d                   	pop    %ebp
  80098f:	c3                   	ret    

00800990 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800990:	55                   	push   %ebp
  800991:	89 e5                	mov    %esp,%ebp
  800993:	53                   	push   %ebx
  800994:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800997:	53                   	push   %ebx
  800998:	e8 9a ff ff ff       	call   800937 <strlen>
  80099d:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009a0:	ff 75 0c             	pushl  0xc(%ebp)
  8009a3:	01 d8                	add    %ebx,%eax
  8009a5:	50                   	push   %eax
  8009a6:	e8 c5 ff ff ff       	call   800970 <strcpy>
	return dst;
}
  8009ab:	89 d8                	mov    %ebx,%eax
  8009ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009b0:	c9                   	leave  
  8009b1:	c3                   	ret    

008009b2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009b2:	55                   	push   %ebp
  8009b3:	89 e5                	mov    %esp,%ebp
  8009b5:	56                   	push   %esi
  8009b6:	53                   	push   %ebx
  8009b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8009ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009bd:	89 f3                	mov    %esi,%ebx
  8009bf:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009c2:	89 f2                	mov    %esi,%edx
  8009c4:	eb 0f                	jmp    8009d5 <strncpy+0x23>
		*dst++ = *src;
  8009c6:	83 c2 01             	add    $0x1,%edx
  8009c9:	0f b6 01             	movzbl (%ecx),%eax
  8009cc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009cf:	80 39 01             	cmpb   $0x1,(%ecx)
  8009d2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009d5:	39 da                	cmp    %ebx,%edx
  8009d7:	75 ed                	jne    8009c6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009d9:	89 f0                	mov    %esi,%eax
  8009db:	5b                   	pop    %ebx
  8009dc:	5e                   	pop    %esi
  8009dd:	5d                   	pop    %ebp
  8009de:	c3                   	ret    

008009df <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009df:	55                   	push   %ebp
  8009e0:	89 e5                	mov    %esp,%ebp
  8009e2:	56                   	push   %esi
  8009e3:	53                   	push   %ebx
  8009e4:	8b 75 08             	mov    0x8(%ebp),%esi
  8009e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009ea:	8b 55 10             	mov    0x10(%ebp),%edx
  8009ed:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009ef:	85 d2                	test   %edx,%edx
  8009f1:	74 21                	je     800a14 <strlcpy+0x35>
  8009f3:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8009f7:	89 f2                	mov    %esi,%edx
  8009f9:	eb 09                	jmp    800a04 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009fb:	83 c2 01             	add    $0x1,%edx
  8009fe:	83 c1 01             	add    $0x1,%ecx
  800a01:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a04:	39 c2                	cmp    %eax,%edx
  800a06:	74 09                	je     800a11 <strlcpy+0x32>
  800a08:	0f b6 19             	movzbl (%ecx),%ebx
  800a0b:	84 db                	test   %bl,%bl
  800a0d:	75 ec                	jne    8009fb <strlcpy+0x1c>
  800a0f:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a11:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a14:	29 f0                	sub    %esi,%eax
}
  800a16:	5b                   	pop    %ebx
  800a17:	5e                   	pop    %esi
  800a18:	5d                   	pop    %ebp
  800a19:	c3                   	ret    

00800a1a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a1a:	55                   	push   %ebp
  800a1b:	89 e5                	mov    %esp,%ebp
  800a1d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a20:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a23:	eb 06                	jmp    800a2b <strcmp+0x11>
		p++, q++;
  800a25:	83 c1 01             	add    $0x1,%ecx
  800a28:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a2b:	0f b6 01             	movzbl (%ecx),%eax
  800a2e:	84 c0                	test   %al,%al
  800a30:	74 04                	je     800a36 <strcmp+0x1c>
  800a32:	3a 02                	cmp    (%edx),%al
  800a34:	74 ef                	je     800a25 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a36:	0f b6 c0             	movzbl %al,%eax
  800a39:	0f b6 12             	movzbl (%edx),%edx
  800a3c:	29 d0                	sub    %edx,%eax
}
  800a3e:	5d                   	pop    %ebp
  800a3f:	c3                   	ret    

00800a40 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a40:	55                   	push   %ebp
  800a41:	89 e5                	mov    %esp,%ebp
  800a43:	53                   	push   %ebx
  800a44:	8b 45 08             	mov    0x8(%ebp),%eax
  800a47:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a4a:	89 c3                	mov    %eax,%ebx
  800a4c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a4f:	eb 06                	jmp    800a57 <strncmp+0x17>
		n--, p++, q++;
  800a51:	83 c0 01             	add    $0x1,%eax
  800a54:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a57:	39 d8                	cmp    %ebx,%eax
  800a59:	74 15                	je     800a70 <strncmp+0x30>
  800a5b:	0f b6 08             	movzbl (%eax),%ecx
  800a5e:	84 c9                	test   %cl,%cl
  800a60:	74 04                	je     800a66 <strncmp+0x26>
  800a62:	3a 0a                	cmp    (%edx),%cl
  800a64:	74 eb                	je     800a51 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a66:	0f b6 00             	movzbl (%eax),%eax
  800a69:	0f b6 12             	movzbl (%edx),%edx
  800a6c:	29 d0                	sub    %edx,%eax
  800a6e:	eb 05                	jmp    800a75 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a70:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a75:	5b                   	pop    %ebx
  800a76:	5d                   	pop    %ebp
  800a77:	c3                   	ret    

00800a78 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a78:	55                   	push   %ebp
  800a79:	89 e5                	mov    %esp,%ebp
  800a7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a82:	eb 07                	jmp    800a8b <strchr+0x13>
		if (*s == c)
  800a84:	38 ca                	cmp    %cl,%dl
  800a86:	74 0f                	je     800a97 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a88:	83 c0 01             	add    $0x1,%eax
  800a8b:	0f b6 10             	movzbl (%eax),%edx
  800a8e:	84 d2                	test   %dl,%dl
  800a90:	75 f2                	jne    800a84 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a92:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a97:	5d                   	pop    %ebp
  800a98:	c3                   	ret    

00800a99 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a99:	55                   	push   %ebp
  800a9a:	89 e5                	mov    %esp,%ebp
  800a9c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800aa3:	eb 03                	jmp    800aa8 <strfind+0xf>
  800aa5:	83 c0 01             	add    $0x1,%eax
  800aa8:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800aab:	38 ca                	cmp    %cl,%dl
  800aad:	74 04                	je     800ab3 <strfind+0x1a>
  800aaf:	84 d2                	test   %dl,%dl
  800ab1:	75 f2                	jne    800aa5 <strfind+0xc>
			break;
	return (char *) s;
}
  800ab3:	5d                   	pop    %ebp
  800ab4:	c3                   	ret    

00800ab5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ab5:	55                   	push   %ebp
  800ab6:	89 e5                	mov    %esp,%ebp
  800ab8:	57                   	push   %edi
  800ab9:	56                   	push   %esi
  800aba:	53                   	push   %ebx
  800abb:	8b 7d 08             	mov    0x8(%ebp),%edi
  800abe:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ac1:	85 c9                	test   %ecx,%ecx
  800ac3:	74 36                	je     800afb <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ac5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800acb:	75 28                	jne    800af5 <memset+0x40>
  800acd:	f6 c1 03             	test   $0x3,%cl
  800ad0:	75 23                	jne    800af5 <memset+0x40>
		c &= 0xFF;
  800ad2:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ad6:	89 d3                	mov    %edx,%ebx
  800ad8:	c1 e3 08             	shl    $0x8,%ebx
  800adb:	89 d6                	mov    %edx,%esi
  800add:	c1 e6 18             	shl    $0x18,%esi
  800ae0:	89 d0                	mov    %edx,%eax
  800ae2:	c1 e0 10             	shl    $0x10,%eax
  800ae5:	09 f0                	or     %esi,%eax
  800ae7:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800ae9:	89 d8                	mov    %ebx,%eax
  800aeb:	09 d0                	or     %edx,%eax
  800aed:	c1 e9 02             	shr    $0x2,%ecx
  800af0:	fc                   	cld    
  800af1:	f3 ab                	rep stos %eax,%es:(%edi)
  800af3:	eb 06                	jmp    800afb <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800af5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af8:	fc                   	cld    
  800af9:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800afb:	89 f8                	mov    %edi,%eax
  800afd:	5b                   	pop    %ebx
  800afe:	5e                   	pop    %esi
  800aff:	5f                   	pop    %edi
  800b00:	5d                   	pop    %ebp
  800b01:	c3                   	ret    

00800b02 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b02:	55                   	push   %ebp
  800b03:	89 e5                	mov    %esp,%ebp
  800b05:	57                   	push   %edi
  800b06:	56                   	push   %esi
  800b07:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b0d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b10:	39 c6                	cmp    %eax,%esi
  800b12:	73 35                	jae    800b49 <memmove+0x47>
  800b14:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b17:	39 d0                	cmp    %edx,%eax
  800b19:	73 2e                	jae    800b49 <memmove+0x47>
		s += n;
		d += n;
  800b1b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b1e:	89 d6                	mov    %edx,%esi
  800b20:	09 fe                	or     %edi,%esi
  800b22:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b28:	75 13                	jne    800b3d <memmove+0x3b>
  800b2a:	f6 c1 03             	test   $0x3,%cl
  800b2d:	75 0e                	jne    800b3d <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b2f:	83 ef 04             	sub    $0x4,%edi
  800b32:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b35:	c1 e9 02             	shr    $0x2,%ecx
  800b38:	fd                   	std    
  800b39:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b3b:	eb 09                	jmp    800b46 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b3d:	83 ef 01             	sub    $0x1,%edi
  800b40:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b43:	fd                   	std    
  800b44:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b46:	fc                   	cld    
  800b47:	eb 1d                	jmp    800b66 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b49:	89 f2                	mov    %esi,%edx
  800b4b:	09 c2                	or     %eax,%edx
  800b4d:	f6 c2 03             	test   $0x3,%dl
  800b50:	75 0f                	jne    800b61 <memmove+0x5f>
  800b52:	f6 c1 03             	test   $0x3,%cl
  800b55:	75 0a                	jne    800b61 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b57:	c1 e9 02             	shr    $0x2,%ecx
  800b5a:	89 c7                	mov    %eax,%edi
  800b5c:	fc                   	cld    
  800b5d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b5f:	eb 05                	jmp    800b66 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b61:	89 c7                	mov    %eax,%edi
  800b63:	fc                   	cld    
  800b64:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b66:	5e                   	pop    %esi
  800b67:	5f                   	pop    %edi
  800b68:	5d                   	pop    %ebp
  800b69:	c3                   	ret    

00800b6a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b6a:	55                   	push   %ebp
  800b6b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b6d:	ff 75 10             	pushl  0x10(%ebp)
  800b70:	ff 75 0c             	pushl  0xc(%ebp)
  800b73:	ff 75 08             	pushl  0x8(%ebp)
  800b76:	e8 87 ff ff ff       	call   800b02 <memmove>
}
  800b7b:	c9                   	leave  
  800b7c:	c3                   	ret    

00800b7d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b7d:	55                   	push   %ebp
  800b7e:	89 e5                	mov    %esp,%ebp
  800b80:	56                   	push   %esi
  800b81:	53                   	push   %ebx
  800b82:	8b 45 08             	mov    0x8(%ebp),%eax
  800b85:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b88:	89 c6                	mov    %eax,%esi
  800b8a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b8d:	eb 1a                	jmp    800ba9 <memcmp+0x2c>
		if (*s1 != *s2)
  800b8f:	0f b6 08             	movzbl (%eax),%ecx
  800b92:	0f b6 1a             	movzbl (%edx),%ebx
  800b95:	38 d9                	cmp    %bl,%cl
  800b97:	74 0a                	je     800ba3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b99:	0f b6 c1             	movzbl %cl,%eax
  800b9c:	0f b6 db             	movzbl %bl,%ebx
  800b9f:	29 d8                	sub    %ebx,%eax
  800ba1:	eb 0f                	jmp    800bb2 <memcmp+0x35>
		s1++, s2++;
  800ba3:	83 c0 01             	add    $0x1,%eax
  800ba6:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ba9:	39 f0                	cmp    %esi,%eax
  800bab:	75 e2                	jne    800b8f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bad:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bb2:	5b                   	pop    %ebx
  800bb3:	5e                   	pop    %esi
  800bb4:	5d                   	pop    %ebp
  800bb5:	c3                   	ret    

00800bb6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bb6:	55                   	push   %ebp
  800bb7:	89 e5                	mov    %esp,%ebp
  800bb9:	53                   	push   %ebx
  800bba:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800bbd:	89 c1                	mov    %eax,%ecx
  800bbf:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800bc2:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bc6:	eb 0a                	jmp    800bd2 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bc8:	0f b6 10             	movzbl (%eax),%edx
  800bcb:	39 da                	cmp    %ebx,%edx
  800bcd:	74 07                	je     800bd6 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bcf:	83 c0 01             	add    $0x1,%eax
  800bd2:	39 c8                	cmp    %ecx,%eax
  800bd4:	72 f2                	jb     800bc8 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bd6:	5b                   	pop    %ebx
  800bd7:	5d                   	pop    %ebp
  800bd8:	c3                   	ret    

00800bd9 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bd9:	55                   	push   %ebp
  800bda:	89 e5                	mov    %esp,%ebp
  800bdc:	57                   	push   %edi
  800bdd:	56                   	push   %esi
  800bde:	53                   	push   %ebx
  800bdf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800be2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800be5:	eb 03                	jmp    800bea <strtol+0x11>
		s++;
  800be7:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bea:	0f b6 01             	movzbl (%ecx),%eax
  800bed:	3c 20                	cmp    $0x20,%al
  800bef:	74 f6                	je     800be7 <strtol+0xe>
  800bf1:	3c 09                	cmp    $0x9,%al
  800bf3:	74 f2                	je     800be7 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bf5:	3c 2b                	cmp    $0x2b,%al
  800bf7:	75 0a                	jne    800c03 <strtol+0x2a>
		s++;
  800bf9:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bfc:	bf 00 00 00 00       	mov    $0x0,%edi
  800c01:	eb 11                	jmp    800c14 <strtol+0x3b>
  800c03:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c08:	3c 2d                	cmp    $0x2d,%al
  800c0a:	75 08                	jne    800c14 <strtol+0x3b>
		s++, neg = 1;
  800c0c:	83 c1 01             	add    $0x1,%ecx
  800c0f:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c14:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c1a:	75 15                	jne    800c31 <strtol+0x58>
  800c1c:	80 39 30             	cmpb   $0x30,(%ecx)
  800c1f:	75 10                	jne    800c31 <strtol+0x58>
  800c21:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c25:	75 7c                	jne    800ca3 <strtol+0xca>
		s += 2, base = 16;
  800c27:	83 c1 02             	add    $0x2,%ecx
  800c2a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c2f:	eb 16                	jmp    800c47 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c31:	85 db                	test   %ebx,%ebx
  800c33:	75 12                	jne    800c47 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c35:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c3a:	80 39 30             	cmpb   $0x30,(%ecx)
  800c3d:	75 08                	jne    800c47 <strtol+0x6e>
		s++, base = 8;
  800c3f:	83 c1 01             	add    $0x1,%ecx
  800c42:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c47:	b8 00 00 00 00       	mov    $0x0,%eax
  800c4c:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c4f:	0f b6 11             	movzbl (%ecx),%edx
  800c52:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c55:	89 f3                	mov    %esi,%ebx
  800c57:	80 fb 09             	cmp    $0x9,%bl
  800c5a:	77 08                	ja     800c64 <strtol+0x8b>
			dig = *s - '0';
  800c5c:	0f be d2             	movsbl %dl,%edx
  800c5f:	83 ea 30             	sub    $0x30,%edx
  800c62:	eb 22                	jmp    800c86 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c64:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c67:	89 f3                	mov    %esi,%ebx
  800c69:	80 fb 19             	cmp    $0x19,%bl
  800c6c:	77 08                	ja     800c76 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800c6e:	0f be d2             	movsbl %dl,%edx
  800c71:	83 ea 57             	sub    $0x57,%edx
  800c74:	eb 10                	jmp    800c86 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c76:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c79:	89 f3                	mov    %esi,%ebx
  800c7b:	80 fb 19             	cmp    $0x19,%bl
  800c7e:	77 16                	ja     800c96 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c80:	0f be d2             	movsbl %dl,%edx
  800c83:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c86:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c89:	7d 0b                	jge    800c96 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800c8b:	83 c1 01             	add    $0x1,%ecx
  800c8e:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c92:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c94:	eb b9                	jmp    800c4f <strtol+0x76>

	if (endptr)
  800c96:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c9a:	74 0d                	je     800ca9 <strtol+0xd0>
		*endptr = (char *) s;
  800c9c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c9f:	89 0e                	mov    %ecx,(%esi)
  800ca1:	eb 06                	jmp    800ca9 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ca3:	85 db                	test   %ebx,%ebx
  800ca5:	74 98                	je     800c3f <strtol+0x66>
  800ca7:	eb 9e                	jmp    800c47 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ca9:	89 c2                	mov    %eax,%edx
  800cab:	f7 da                	neg    %edx
  800cad:	85 ff                	test   %edi,%edi
  800caf:	0f 45 c2             	cmovne %edx,%eax
}
  800cb2:	5b                   	pop    %ebx
  800cb3:	5e                   	pop    %esi
  800cb4:	5f                   	pop    %edi
  800cb5:	5d                   	pop    %ebp
  800cb6:	c3                   	ret    

00800cb7 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800cb7:	55                   	push   %ebp
  800cb8:	89 e5                	mov    %esp,%ebp
  800cba:	57                   	push   %edi
  800cbb:	56                   	push   %esi
  800cbc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbd:	b8 00 00 00 00       	mov    $0x0,%eax
  800cc2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc8:	89 c3                	mov    %eax,%ebx
  800cca:	89 c7                	mov    %eax,%edi
  800ccc:	89 c6                	mov    %eax,%esi
  800cce:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800cd0:	5b                   	pop    %ebx
  800cd1:	5e                   	pop    %esi
  800cd2:	5f                   	pop    %edi
  800cd3:	5d                   	pop    %ebp
  800cd4:	c3                   	ret    

00800cd5 <sys_cgetc>:

int
sys_cgetc(void)
{
  800cd5:	55                   	push   %ebp
  800cd6:	89 e5                	mov    %esp,%ebp
  800cd8:	57                   	push   %edi
  800cd9:	56                   	push   %esi
  800cda:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cdb:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce0:	b8 01 00 00 00       	mov    $0x1,%eax
  800ce5:	89 d1                	mov    %edx,%ecx
  800ce7:	89 d3                	mov    %edx,%ebx
  800ce9:	89 d7                	mov    %edx,%edi
  800ceb:	89 d6                	mov    %edx,%esi
  800ced:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cef:	5b                   	pop    %ebx
  800cf0:	5e                   	pop    %esi
  800cf1:	5f                   	pop    %edi
  800cf2:	5d                   	pop    %ebp
  800cf3:	c3                   	ret    

00800cf4 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cf4:	55                   	push   %ebp
  800cf5:	89 e5                	mov    %esp,%ebp
  800cf7:	57                   	push   %edi
  800cf8:	56                   	push   %esi
  800cf9:	53                   	push   %ebx
  800cfa:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d02:	b8 03 00 00 00       	mov    $0x3,%eax
  800d07:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0a:	89 cb                	mov    %ecx,%ebx
  800d0c:	89 cf                	mov    %ecx,%edi
  800d0e:	89 ce                	mov    %ecx,%esi
  800d10:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d12:	85 c0                	test   %eax,%eax
  800d14:	7e 17                	jle    800d2d <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d16:	83 ec 0c             	sub    $0xc,%esp
  800d19:	50                   	push   %eax
  800d1a:	6a 03                	push   $0x3
  800d1c:	68 df 27 80 00       	push   $0x8027df
  800d21:	6a 23                	push   $0x23
  800d23:	68 fc 27 80 00       	push   $0x8027fc
  800d28:	e8 e5 f5 ff ff       	call   800312 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d2d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d30:	5b                   	pop    %ebx
  800d31:	5e                   	pop    %esi
  800d32:	5f                   	pop    %edi
  800d33:	5d                   	pop    %ebp
  800d34:	c3                   	ret    

00800d35 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d35:	55                   	push   %ebp
  800d36:	89 e5                	mov    %esp,%ebp
  800d38:	57                   	push   %edi
  800d39:	56                   	push   %esi
  800d3a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d40:	b8 02 00 00 00       	mov    $0x2,%eax
  800d45:	89 d1                	mov    %edx,%ecx
  800d47:	89 d3                	mov    %edx,%ebx
  800d49:	89 d7                	mov    %edx,%edi
  800d4b:	89 d6                	mov    %edx,%esi
  800d4d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d4f:	5b                   	pop    %ebx
  800d50:	5e                   	pop    %esi
  800d51:	5f                   	pop    %edi
  800d52:	5d                   	pop    %ebp
  800d53:	c3                   	ret    

00800d54 <sys_yield>:

void
sys_yield(void)
{
  800d54:	55                   	push   %ebp
  800d55:	89 e5                	mov    %esp,%ebp
  800d57:	57                   	push   %edi
  800d58:	56                   	push   %esi
  800d59:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d5f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d64:	89 d1                	mov    %edx,%ecx
  800d66:	89 d3                	mov    %edx,%ebx
  800d68:	89 d7                	mov    %edx,%edi
  800d6a:	89 d6                	mov    %edx,%esi
  800d6c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d6e:	5b                   	pop    %ebx
  800d6f:	5e                   	pop    %esi
  800d70:	5f                   	pop    %edi
  800d71:	5d                   	pop    %ebp
  800d72:	c3                   	ret    

00800d73 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d73:	55                   	push   %ebp
  800d74:	89 e5                	mov    %esp,%ebp
  800d76:	57                   	push   %edi
  800d77:	56                   	push   %esi
  800d78:	53                   	push   %ebx
  800d79:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7c:	be 00 00 00 00       	mov    $0x0,%esi
  800d81:	b8 04 00 00 00       	mov    $0x4,%eax
  800d86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d89:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d8f:	89 f7                	mov    %esi,%edi
  800d91:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d93:	85 c0                	test   %eax,%eax
  800d95:	7e 17                	jle    800dae <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d97:	83 ec 0c             	sub    $0xc,%esp
  800d9a:	50                   	push   %eax
  800d9b:	6a 04                	push   $0x4
  800d9d:	68 df 27 80 00       	push   $0x8027df
  800da2:	6a 23                	push   $0x23
  800da4:	68 fc 27 80 00       	push   $0x8027fc
  800da9:	e8 64 f5 ff ff       	call   800312 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800dae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800db1:	5b                   	pop    %ebx
  800db2:	5e                   	pop    %esi
  800db3:	5f                   	pop    %edi
  800db4:	5d                   	pop    %ebp
  800db5:	c3                   	ret    

00800db6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800db6:	55                   	push   %ebp
  800db7:	89 e5                	mov    %esp,%ebp
  800db9:	57                   	push   %edi
  800dba:	56                   	push   %esi
  800dbb:	53                   	push   %ebx
  800dbc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dbf:	b8 05 00 00 00       	mov    $0x5,%eax
  800dc4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc7:	8b 55 08             	mov    0x8(%ebp),%edx
  800dca:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dcd:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dd0:	8b 75 18             	mov    0x18(%ebp),%esi
  800dd3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dd5:	85 c0                	test   %eax,%eax
  800dd7:	7e 17                	jle    800df0 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd9:	83 ec 0c             	sub    $0xc,%esp
  800ddc:	50                   	push   %eax
  800ddd:	6a 05                	push   $0x5
  800ddf:	68 df 27 80 00       	push   $0x8027df
  800de4:	6a 23                	push   $0x23
  800de6:	68 fc 27 80 00       	push   $0x8027fc
  800deb:	e8 22 f5 ff ff       	call   800312 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800df0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800df3:	5b                   	pop    %ebx
  800df4:	5e                   	pop    %esi
  800df5:	5f                   	pop    %edi
  800df6:	5d                   	pop    %ebp
  800df7:	c3                   	ret    

00800df8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800df8:	55                   	push   %ebp
  800df9:	89 e5                	mov    %esp,%ebp
  800dfb:	57                   	push   %edi
  800dfc:	56                   	push   %esi
  800dfd:	53                   	push   %ebx
  800dfe:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e01:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e06:	b8 06 00 00 00       	mov    $0x6,%eax
  800e0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e11:	89 df                	mov    %ebx,%edi
  800e13:	89 de                	mov    %ebx,%esi
  800e15:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e17:	85 c0                	test   %eax,%eax
  800e19:	7e 17                	jle    800e32 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e1b:	83 ec 0c             	sub    $0xc,%esp
  800e1e:	50                   	push   %eax
  800e1f:	6a 06                	push   $0x6
  800e21:	68 df 27 80 00       	push   $0x8027df
  800e26:	6a 23                	push   $0x23
  800e28:	68 fc 27 80 00       	push   $0x8027fc
  800e2d:	e8 e0 f4 ff ff       	call   800312 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e32:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e35:	5b                   	pop    %ebx
  800e36:	5e                   	pop    %esi
  800e37:	5f                   	pop    %edi
  800e38:	5d                   	pop    %ebp
  800e39:	c3                   	ret    

00800e3a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e3a:	55                   	push   %ebp
  800e3b:	89 e5                	mov    %esp,%ebp
  800e3d:	57                   	push   %edi
  800e3e:	56                   	push   %esi
  800e3f:	53                   	push   %ebx
  800e40:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e43:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e48:	b8 08 00 00 00       	mov    $0x8,%eax
  800e4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e50:	8b 55 08             	mov    0x8(%ebp),%edx
  800e53:	89 df                	mov    %ebx,%edi
  800e55:	89 de                	mov    %ebx,%esi
  800e57:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e59:	85 c0                	test   %eax,%eax
  800e5b:	7e 17                	jle    800e74 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e5d:	83 ec 0c             	sub    $0xc,%esp
  800e60:	50                   	push   %eax
  800e61:	6a 08                	push   $0x8
  800e63:	68 df 27 80 00       	push   $0x8027df
  800e68:	6a 23                	push   $0x23
  800e6a:	68 fc 27 80 00       	push   $0x8027fc
  800e6f:	e8 9e f4 ff ff       	call   800312 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e74:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e77:	5b                   	pop    %ebx
  800e78:	5e                   	pop    %esi
  800e79:	5f                   	pop    %edi
  800e7a:	5d                   	pop    %ebp
  800e7b:	c3                   	ret    

00800e7c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e7c:	55                   	push   %ebp
  800e7d:	89 e5                	mov    %esp,%ebp
  800e7f:	57                   	push   %edi
  800e80:	56                   	push   %esi
  800e81:	53                   	push   %ebx
  800e82:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e85:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e8a:	b8 09 00 00 00       	mov    $0x9,%eax
  800e8f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e92:	8b 55 08             	mov    0x8(%ebp),%edx
  800e95:	89 df                	mov    %ebx,%edi
  800e97:	89 de                	mov    %ebx,%esi
  800e99:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e9b:	85 c0                	test   %eax,%eax
  800e9d:	7e 17                	jle    800eb6 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e9f:	83 ec 0c             	sub    $0xc,%esp
  800ea2:	50                   	push   %eax
  800ea3:	6a 09                	push   $0x9
  800ea5:	68 df 27 80 00       	push   $0x8027df
  800eaa:	6a 23                	push   $0x23
  800eac:	68 fc 27 80 00       	push   $0x8027fc
  800eb1:	e8 5c f4 ff ff       	call   800312 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800eb6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eb9:	5b                   	pop    %ebx
  800eba:	5e                   	pop    %esi
  800ebb:	5f                   	pop    %edi
  800ebc:	5d                   	pop    %ebp
  800ebd:	c3                   	ret    

00800ebe <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ebe:	55                   	push   %ebp
  800ebf:	89 e5                	mov    %esp,%ebp
  800ec1:	57                   	push   %edi
  800ec2:	56                   	push   %esi
  800ec3:	53                   	push   %ebx
  800ec4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ec7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ecc:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ed1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ed4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed7:	89 df                	mov    %ebx,%edi
  800ed9:	89 de                	mov    %ebx,%esi
  800edb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800edd:	85 c0                	test   %eax,%eax
  800edf:	7e 17                	jle    800ef8 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee1:	83 ec 0c             	sub    $0xc,%esp
  800ee4:	50                   	push   %eax
  800ee5:	6a 0a                	push   $0xa
  800ee7:	68 df 27 80 00       	push   $0x8027df
  800eec:	6a 23                	push   $0x23
  800eee:	68 fc 27 80 00       	push   $0x8027fc
  800ef3:	e8 1a f4 ff ff       	call   800312 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ef8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800efb:	5b                   	pop    %ebx
  800efc:	5e                   	pop    %esi
  800efd:	5f                   	pop    %edi
  800efe:	5d                   	pop    %ebp
  800eff:	c3                   	ret    

00800f00 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f00:	55                   	push   %ebp
  800f01:	89 e5                	mov    %esp,%ebp
  800f03:	57                   	push   %edi
  800f04:	56                   	push   %esi
  800f05:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f06:	be 00 00 00 00       	mov    $0x0,%esi
  800f0b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f13:	8b 55 08             	mov    0x8(%ebp),%edx
  800f16:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f19:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f1c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f1e:	5b                   	pop    %ebx
  800f1f:	5e                   	pop    %esi
  800f20:	5f                   	pop    %edi
  800f21:	5d                   	pop    %ebp
  800f22:	c3                   	ret    

00800f23 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f23:	55                   	push   %ebp
  800f24:	89 e5                	mov    %esp,%ebp
  800f26:	57                   	push   %edi
  800f27:	56                   	push   %esi
  800f28:	53                   	push   %ebx
  800f29:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f2c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f31:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f36:	8b 55 08             	mov    0x8(%ebp),%edx
  800f39:	89 cb                	mov    %ecx,%ebx
  800f3b:	89 cf                	mov    %ecx,%edi
  800f3d:	89 ce                	mov    %ecx,%esi
  800f3f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f41:	85 c0                	test   %eax,%eax
  800f43:	7e 17                	jle    800f5c <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f45:	83 ec 0c             	sub    $0xc,%esp
  800f48:	50                   	push   %eax
  800f49:	6a 0d                	push   $0xd
  800f4b:	68 df 27 80 00       	push   $0x8027df
  800f50:	6a 23                	push   $0x23
  800f52:	68 fc 27 80 00       	push   $0x8027fc
  800f57:	e8 b6 f3 ff ff       	call   800312 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f5f:	5b                   	pop    %ebx
  800f60:	5e                   	pop    %esi
  800f61:	5f                   	pop    %edi
  800f62:	5d                   	pop    %ebp
  800f63:	c3                   	ret    

00800f64 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800f64:	55                   	push   %ebp
  800f65:	89 e5                	mov    %esp,%ebp
  800f67:	56                   	push   %esi
  800f68:	53                   	push   %ebx
	int r;

	// LAB 4: Your code here.
	// Check if page is writable or COW
	pte_t pte = uvpt[pn];
  800f69:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
	uint32_t perm = PTE_P | PTE_U;
	if (pte && (PTE_COW | PTE_W)) {
		perm |= PTE_COW;
  800f70:	83 f9 01             	cmp    $0x1,%ecx
  800f73:	19 f6                	sbb    %esi,%esi
  800f75:	81 e6 00 f8 ff ff    	and    $0xfffff800,%esi
  800f7b:	81 c6 05 08 00 00    	add    $0x805,%esi
	}

	// Map page
	void *va = (void *) (pn * PGSIZE);
  800f81:	c1 e2 0c             	shl    $0xc,%edx
  800f84:	89 d3                	mov    %edx,%ebx
	// Map on the child
	if ((r = sys_page_map(0, va, envid, va, perm)) < 0) {
  800f86:	83 ec 0c             	sub    $0xc,%esp
  800f89:	56                   	push   %esi
  800f8a:	52                   	push   %edx
  800f8b:	50                   	push   %eax
  800f8c:	52                   	push   %edx
  800f8d:	6a 00                	push   $0x0
  800f8f:	e8 22 fe ff ff       	call   800db6 <sys_page_map>
  800f94:	83 c4 20             	add    $0x20,%esp
  800f97:	85 c0                	test   %eax,%eax
  800f99:	79 12                	jns    800fad <duppage+0x49>
		panic("sys_page_alloc: %e", r);
  800f9b:	50                   	push   %eax
  800f9c:	68 0a 28 80 00       	push   $0x80280a
  800fa1:	6a 56                	push   $0x56
  800fa3:	68 1d 28 80 00       	push   $0x80281d
  800fa8:	e8 65 f3 ff ff       	call   800312 <_panic>
		return r;
	}

	// Change the permission on the parent
	if ((r = sys_page_map(0, va, 0, va, perm)) < 0) {
  800fad:	83 ec 0c             	sub    $0xc,%esp
  800fb0:	56                   	push   %esi
  800fb1:	53                   	push   %ebx
  800fb2:	6a 00                	push   $0x0
  800fb4:	53                   	push   %ebx
  800fb5:	6a 00                	push   $0x0
  800fb7:	e8 fa fd ff ff       	call   800db6 <sys_page_map>
  800fbc:	83 c4 20             	add    $0x20,%esp
  800fbf:	85 c0                	test   %eax,%eax
  800fc1:	79 12                	jns    800fd5 <duppage+0x71>
		panic("sys_page_alloc: %e", r);
  800fc3:	50                   	push   %eax
  800fc4:	68 0a 28 80 00       	push   $0x80280a
  800fc9:	6a 5c                	push   $0x5c
  800fcb:	68 1d 28 80 00       	push   $0x80281d
  800fd0:	e8 3d f3 ff ff       	call   800312 <_panic>
		return r;
	}

	return 0;
}
  800fd5:	b8 00 00 00 00       	mov    $0x0,%eax
  800fda:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fdd:	5b                   	pop    %ebx
  800fde:	5e                   	pop    %esi
  800fdf:	5d                   	pop    %ebp
  800fe0:	c3                   	ret    

00800fe1 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800fe1:	55                   	push   %ebp
  800fe2:	89 e5                	mov    %esp,%ebp
  800fe4:	53                   	push   %ebx
  800fe5:	83 ec 04             	sub    $0x4,%esp
  800fe8:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800feb:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	unsigned pn = ((uint32_t)addr)/PGSIZE;
  800fed:	89 da                	mov    %ebx,%edx
  800fef:	c1 ea 0c             	shr    $0xc,%edx
	pte_t pte = uvpt[pn];
  800ff2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(err & FEC_WR) || !(pte & PTE_COW)) {
  800ff9:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800ffd:	74 05                	je     801004 <pgfault+0x23>
  800fff:	f6 c6 08             	test   $0x8,%dh
  801002:	75 14                	jne    801018 <pgfault+0x37>
		panic("fork pgfault handler: does not handle this fault");
  801004:	83 ec 04             	sub    $0x4,%esp
  801007:	68 8c 28 80 00       	push   $0x80288c
  80100c:	6a 1f                	push   $0x1f
  80100e:	68 1d 28 80 00       	push   $0x80281d
  801013:	e8 fa f2 ff ff       	call   800312 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// Allocate a new page, mapped at temp location
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  801018:	83 ec 04             	sub    $0x4,%esp
  80101b:	6a 07                	push   $0x7
  80101d:	68 00 f0 7f 00       	push   $0x7ff000
  801022:	6a 00                	push   $0x0
  801024:	e8 4a fd ff ff       	call   800d73 <sys_page_alloc>
  801029:	83 c4 10             	add    $0x10,%esp
  80102c:	85 c0                	test   %eax,%eax
  80102e:	79 12                	jns    801042 <pgfault+0x61>
		panic("sys_page_alloc: %e", r);
  801030:	50                   	push   %eax
  801031:	68 0a 28 80 00       	push   $0x80280a
  801036:	6a 2b                	push   $0x2b
  801038:	68 1d 28 80 00       	push   $0x80281d
  80103d:	e8 d0 f2 ff ff       	call   800312 <_panic>

	// Copy the data from the old page to this new page
	void *addr_pgstart = (void *) ROUNDDOWN(addr, PGSIZE);
  801042:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr_pgstart, PGSIZE);
  801048:	83 ec 04             	sub    $0x4,%esp
  80104b:	68 00 10 00 00       	push   $0x1000
  801050:	53                   	push   %ebx
  801051:	68 00 f0 7f 00       	push   $0x7ff000
  801056:	e8 a7 fa ff ff       	call   800b02 <memmove>

	// Move the new page to the old page's address
	if ((r = sys_page_map(0, PFTEMP, 0, addr_pgstart, PTE_P|PTE_U|PTE_W)) < 0)
  80105b:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801062:	53                   	push   %ebx
  801063:	6a 00                	push   $0x0
  801065:	68 00 f0 7f 00       	push   $0x7ff000
  80106a:	6a 00                	push   $0x0
  80106c:	e8 45 fd ff ff       	call   800db6 <sys_page_map>
  801071:	83 c4 20             	add    $0x20,%esp
  801074:	85 c0                	test   %eax,%eax
  801076:	79 12                	jns    80108a <pgfault+0xa9>
		panic("sys_page_map: %e", r);
  801078:	50                   	push   %eax
  801079:	68 28 28 80 00       	push   $0x802828
  80107e:	6a 33                	push   $0x33
  801080:	68 1d 28 80 00       	push   $0x80281d
  801085:	e8 88 f2 ff ff       	call   800312 <_panic>

	// Unmap the temp location
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  80108a:	83 ec 08             	sub    $0x8,%esp
  80108d:	68 00 f0 7f 00       	push   $0x7ff000
  801092:	6a 00                	push   $0x0
  801094:	e8 5f fd ff ff       	call   800df8 <sys_page_unmap>
  801099:	83 c4 10             	add    $0x10,%esp
  80109c:	85 c0                	test   %eax,%eax
  80109e:	79 12                	jns    8010b2 <pgfault+0xd1>
		panic("sys_page_unmap: %e", r);
  8010a0:	50                   	push   %eax
  8010a1:	68 39 28 80 00       	push   $0x802839
  8010a6:	6a 37                	push   $0x37
  8010a8:	68 1d 28 80 00       	push   $0x80281d
  8010ad:	e8 60 f2 ff ff       	call   800312 <_panic>
}
  8010b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010b5:	c9                   	leave  
  8010b6:	c3                   	ret    

008010b7 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8010b7:	55                   	push   %ebp
  8010b8:	89 e5                	mov    %esp,%ebp
  8010ba:	56                   	push   %esi
  8010bb:	53                   	push   %ebx
  8010bc:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
	// Set up page fault handler
	set_pgfault_handler(&pgfault);
  8010bf:	68 e1 0f 80 00       	push   $0x800fe1
  8010c4:	e8 45 0e 00 00       	call   801f0e <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8010c9:	b8 07 00 00 00       	mov    $0x7,%eax
  8010ce:	cd 30                	int    $0x30

	// Create child
	envid_t envid = sys_exofork();
  8010d0:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (envid < 0) {
  8010d3:	83 c4 10             	add    $0x10,%esp
  8010d6:	85 c0                	test   %eax,%eax
  8010d8:	79 12                	jns    8010ec <fork+0x35>
		panic("sys_exofork: %e", envid);
  8010da:	50                   	push   %eax
  8010db:	68 4c 28 80 00       	push   $0x80284c
  8010e0:	6a 7d                	push   $0x7d
  8010e2:	68 1d 28 80 00       	push   $0x80281d
  8010e7:	e8 26 f2 ff ff       	call   800312 <_panic>
		return envid;
	}
	if (envid == 0) {
  8010ec:	85 c0                	test   %eax,%eax
  8010ee:	75 1e                	jne    80110e <fork+0x57>
		// We are the child.
		thisenv = &envs[ENVX(sys_getenvid())]; // Fix thisenv
  8010f0:	e8 40 fc ff ff       	call   800d35 <sys_getenvid>
  8010f5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010fa:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8010fd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801102:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  801107:	b8 00 00 00 00       	mov    $0x0,%eax
  80110c:	eb 7d                	jmp    80118b <fork+0xd4>

	// Set page fault handler on the child.
	// The parent needs to do it, else the child wouldn't be able to handle
	// the fault when trying to access it's stack (which happens as soon it starts)
	extern void _pgfault_upcall(void);
	sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);
  80110e:	83 ec 04             	sub    $0x4,%esp
  801111:	6a 07                	push   $0x7
  801113:	68 00 f0 bf ee       	push   $0xeebff000
  801118:	50                   	push   %eax
  801119:	e8 55 fc ff ff       	call   800d73 <sys_page_alloc>
	sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  80111e:	83 c4 08             	add    $0x8,%esp
  801121:	68 53 1f 80 00       	push   $0x801f53
  801126:	ff 75 f4             	pushl  -0xc(%ebp)
  801129:	e8 90 fd ff ff       	call   800ebe <sys_env_set_pgfault_upcall>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  80112e:	be 04 60 80 00       	mov    $0x806004,%esi
  801133:	c1 ee 0c             	shr    $0xc,%esi
  801136:	83 c4 10             	add    $0x10,%esp
  801139:	bb 00 08 00 00       	mov    $0x800,%ebx
  80113e:	eb 0d                	jmp    80114d <fork+0x96>
		duppage(envid, pn);
  801140:	89 da                	mov    %ebx,%edx
  801142:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801145:	e8 1a fe ff ff       	call   800f64 <duppage>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  80114a:	83 c3 01             	add    $0x1,%ebx
  80114d:	39 f3                	cmp    %esi,%ebx
  80114f:	76 ef                	jbe    801140 <fork+0x89>
	}

	// Also copy the stack we are currently running on
	// I think it should loop from ustacktop to this page, since the stack
	// can have more than 1 page
	duppage(envid, ((uint32_t) &envid)/PGSIZE);
  801151:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801154:	c1 ea 0c             	shr    $0xc,%edx
  801157:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80115a:	e8 05 fe ff ff       	call   800f64 <duppage>

	// Start the child environmnet running
	int r;
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  80115f:	83 ec 08             	sub    $0x8,%esp
  801162:	6a 02                	push   $0x2
  801164:	ff 75 f4             	pushl  -0xc(%ebp)
  801167:	e8 ce fc ff ff       	call   800e3a <sys_env_set_status>
  80116c:	83 c4 10             	add    $0x10,%esp
  80116f:	85 c0                	test   %eax,%eax
  801171:	79 15                	jns    801188 <fork+0xd1>
		panic("sys_env_set_status: %e", r);
  801173:	50                   	push   %eax
  801174:	68 5c 28 80 00       	push   $0x80285c
  801179:	68 9d 00 00 00       	push   $0x9d
  80117e:	68 1d 28 80 00       	push   $0x80281d
  801183:	e8 8a f1 ff ff       	call   800312 <_panic>
		return r;
	}

	return envid;
  801188:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80118b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80118e:	5b                   	pop    %ebx
  80118f:	5e                   	pop    %esi
  801190:	5d                   	pop    %ebp
  801191:	c3                   	ret    

00801192 <sfork>:

// Challenge!
int
sfork(void)
{
  801192:	55                   	push   %ebp
  801193:	89 e5                	mov    %esp,%ebp
  801195:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801198:	68 73 28 80 00       	push   $0x802873
  80119d:	68 a8 00 00 00       	push   $0xa8
  8011a2:	68 1d 28 80 00       	push   $0x80281d
  8011a7:	e8 66 f1 ff ff       	call   800312 <_panic>

008011ac <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011ac:	55                   	push   %ebp
  8011ad:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011af:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b2:	05 00 00 00 30       	add    $0x30000000,%eax
  8011b7:	c1 e8 0c             	shr    $0xc,%eax
}
  8011ba:	5d                   	pop    %ebp
  8011bb:	c3                   	ret    

008011bc <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011bc:	55                   	push   %ebp
  8011bd:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c2:	05 00 00 00 30       	add    $0x30000000,%eax
  8011c7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011cc:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011d1:	5d                   	pop    %ebp
  8011d2:	c3                   	ret    

008011d3 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011d3:	55                   	push   %ebp
  8011d4:	89 e5                	mov    %esp,%ebp
  8011d6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011d9:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011de:	89 c2                	mov    %eax,%edx
  8011e0:	c1 ea 16             	shr    $0x16,%edx
  8011e3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011ea:	f6 c2 01             	test   $0x1,%dl
  8011ed:	74 11                	je     801200 <fd_alloc+0x2d>
  8011ef:	89 c2                	mov    %eax,%edx
  8011f1:	c1 ea 0c             	shr    $0xc,%edx
  8011f4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011fb:	f6 c2 01             	test   $0x1,%dl
  8011fe:	75 09                	jne    801209 <fd_alloc+0x36>
			*fd_store = fd;
  801200:	89 01                	mov    %eax,(%ecx)
			return 0;
  801202:	b8 00 00 00 00       	mov    $0x0,%eax
  801207:	eb 17                	jmp    801220 <fd_alloc+0x4d>
  801209:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80120e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801213:	75 c9                	jne    8011de <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801215:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80121b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801220:	5d                   	pop    %ebp
  801221:	c3                   	ret    

00801222 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801222:	55                   	push   %ebp
  801223:	89 e5                	mov    %esp,%ebp
  801225:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801228:	83 f8 1f             	cmp    $0x1f,%eax
  80122b:	77 36                	ja     801263 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80122d:	c1 e0 0c             	shl    $0xc,%eax
  801230:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801235:	89 c2                	mov    %eax,%edx
  801237:	c1 ea 16             	shr    $0x16,%edx
  80123a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801241:	f6 c2 01             	test   $0x1,%dl
  801244:	74 24                	je     80126a <fd_lookup+0x48>
  801246:	89 c2                	mov    %eax,%edx
  801248:	c1 ea 0c             	shr    $0xc,%edx
  80124b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801252:	f6 c2 01             	test   $0x1,%dl
  801255:	74 1a                	je     801271 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801257:	8b 55 0c             	mov    0xc(%ebp),%edx
  80125a:	89 02                	mov    %eax,(%edx)
	return 0;
  80125c:	b8 00 00 00 00       	mov    $0x0,%eax
  801261:	eb 13                	jmp    801276 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801263:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801268:	eb 0c                	jmp    801276 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80126a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80126f:	eb 05                	jmp    801276 <fd_lookup+0x54>
  801271:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801276:	5d                   	pop    %ebp
  801277:	c3                   	ret    

00801278 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801278:	55                   	push   %ebp
  801279:	89 e5                	mov    %esp,%ebp
  80127b:	83 ec 08             	sub    $0x8,%esp
  80127e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801281:	ba 40 29 80 00       	mov    $0x802940,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801286:	eb 13                	jmp    80129b <dev_lookup+0x23>
  801288:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80128b:	39 08                	cmp    %ecx,(%eax)
  80128d:	75 0c                	jne    80129b <dev_lookup+0x23>
			*dev = devtab[i];
  80128f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801292:	89 01                	mov    %eax,(%ecx)
			return 0;
  801294:	b8 00 00 00 00       	mov    $0x0,%eax
  801299:	eb 2e                	jmp    8012c9 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80129b:	8b 02                	mov    (%edx),%eax
  80129d:	85 c0                	test   %eax,%eax
  80129f:	75 e7                	jne    801288 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012a1:	a1 04 40 80 00       	mov    0x804004,%eax
  8012a6:	8b 40 48             	mov    0x48(%eax),%eax
  8012a9:	83 ec 04             	sub    $0x4,%esp
  8012ac:	51                   	push   %ecx
  8012ad:	50                   	push   %eax
  8012ae:	68 c0 28 80 00       	push   $0x8028c0
  8012b3:	e8 33 f1 ff ff       	call   8003eb <cprintf>
	*dev = 0;
  8012b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012bb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012c1:	83 c4 10             	add    $0x10,%esp
  8012c4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012c9:	c9                   	leave  
  8012ca:	c3                   	ret    

008012cb <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012cb:	55                   	push   %ebp
  8012cc:	89 e5                	mov    %esp,%ebp
  8012ce:	56                   	push   %esi
  8012cf:	53                   	push   %ebx
  8012d0:	83 ec 10             	sub    $0x10,%esp
  8012d3:	8b 75 08             	mov    0x8(%ebp),%esi
  8012d6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012d9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012dc:	50                   	push   %eax
  8012dd:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012e3:	c1 e8 0c             	shr    $0xc,%eax
  8012e6:	50                   	push   %eax
  8012e7:	e8 36 ff ff ff       	call   801222 <fd_lookup>
  8012ec:	83 c4 08             	add    $0x8,%esp
  8012ef:	85 c0                	test   %eax,%eax
  8012f1:	78 05                	js     8012f8 <fd_close+0x2d>
	    || fd != fd2)
  8012f3:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012f6:	74 0c                	je     801304 <fd_close+0x39>
		return (must_exist ? r : 0);
  8012f8:	84 db                	test   %bl,%bl
  8012fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8012ff:	0f 44 c2             	cmove  %edx,%eax
  801302:	eb 41                	jmp    801345 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801304:	83 ec 08             	sub    $0x8,%esp
  801307:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80130a:	50                   	push   %eax
  80130b:	ff 36                	pushl  (%esi)
  80130d:	e8 66 ff ff ff       	call   801278 <dev_lookup>
  801312:	89 c3                	mov    %eax,%ebx
  801314:	83 c4 10             	add    $0x10,%esp
  801317:	85 c0                	test   %eax,%eax
  801319:	78 1a                	js     801335 <fd_close+0x6a>
		if (dev->dev_close)
  80131b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80131e:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801321:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801326:	85 c0                	test   %eax,%eax
  801328:	74 0b                	je     801335 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80132a:	83 ec 0c             	sub    $0xc,%esp
  80132d:	56                   	push   %esi
  80132e:	ff d0                	call   *%eax
  801330:	89 c3                	mov    %eax,%ebx
  801332:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801335:	83 ec 08             	sub    $0x8,%esp
  801338:	56                   	push   %esi
  801339:	6a 00                	push   $0x0
  80133b:	e8 b8 fa ff ff       	call   800df8 <sys_page_unmap>
	return r;
  801340:	83 c4 10             	add    $0x10,%esp
  801343:	89 d8                	mov    %ebx,%eax
}
  801345:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801348:	5b                   	pop    %ebx
  801349:	5e                   	pop    %esi
  80134a:	5d                   	pop    %ebp
  80134b:	c3                   	ret    

0080134c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80134c:	55                   	push   %ebp
  80134d:	89 e5                	mov    %esp,%ebp
  80134f:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801352:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801355:	50                   	push   %eax
  801356:	ff 75 08             	pushl  0x8(%ebp)
  801359:	e8 c4 fe ff ff       	call   801222 <fd_lookup>
  80135e:	83 c4 08             	add    $0x8,%esp
  801361:	85 c0                	test   %eax,%eax
  801363:	78 10                	js     801375 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801365:	83 ec 08             	sub    $0x8,%esp
  801368:	6a 01                	push   $0x1
  80136a:	ff 75 f4             	pushl  -0xc(%ebp)
  80136d:	e8 59 ff ff ff       	call   8012cb <fd_close>
  801372:	83 c4 10             	add    $0x10,%esp
}
  801375:	c9                   	leave  
  801376:	c3                   	ret    

00801377 <close_all>:

void
close_all(void)
{
  801377:	55                   	push   %ebp
  801378:	89 e5                	mov    %esp,%ebp
  80137a:	53                   	push   %ebx
  80137b:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80137e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801383:	83 ec 0c             	sub    $0xc,%esp
  801386:	53                   	push   %ebx
  801387:	e8 c0 ff ff ff       	call   80134c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80138c:	83 c3 01             	add    $0x1,%ebx
  80138f:	83 c4 10             	add    $0x10,%esp
  801392:	83 fb 20             	cmp    $0x20,%ebx
  801395:	75 ec                	jne    801383 <close_all+0xc>
		close(i);
}
  801397:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80139a:	c9                   	leave  
  80139b:	c3                   	ret    

0080139c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80139c:	55                   	push   %ebp
  80139d:	89 e5                	mov    %esp,%ebp
  80139f:	57                   	push   %edi
  8013a0:	56                   	push   %esi
  8013a1:	53                   	push   %ebx
  8013a2:	83 ec 2c             	sub    $0x2c,%esp
  8013a5:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013a8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013ab:	50                   	push   %eax
  8013ac:	ff 75 08             	pushl  0x8(%ebp)
  8013af:	e8 6e fe ff ff       	call   801222 <fd_lookup>
  8013b4:	83 c4 08             	add    $0x8,%esp
  8013b7:	85 c0                	test   %eax,%eax
  8013b9:	0f 88 c1 00 00 00    	js     801480 <dup+0xe4>
		return r;
	close(newfdnum);
  8013bf:	83 ec 0c             	sub    $0xc,%esp
  8013c2:	56                   	push   %esi
  8013c3:	e8 84 ff ff ff       	call   80134c <close>

	newfd = INDEX2FD(newfdnum);
  8013c8:	89 f3                	mov    %esi,%ebx
  8013ca:	c1 e3 0c             	shl    $0xc,%ebx
  8013cd:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013d3:	83 c4 04             	add    $0x4,%esp
  8013d6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013d9:	e8 de fd ff ff       	call   8011bc <fd2data>
  8013de:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013e0:	89 1c 24             	mov    %ebx,(%esp)
  8013e3:	e8 d4 fd ff ff       	call   8011bc <fd2data>
  8013e8:	83 c4 10             	add    $0x10,%esp
  8013eb:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013ee:	89 f8                	mov    %edi,%eax
  8013f0:	c1 e8 16             	shr    $0x16,%eax
  8013f3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013fa:	a8 01                	test   $0x1,%al
  8013fc:	74 37                	je     801435 <dup+0x99>
  8013fe:	89 f8                	mov    %edi,%eax
  801400:	c1 e8 0c             	shr    $0xc,%eax
  801403:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80140a:	f6 c2 01             	test   $0x1,%dl
  80140d:	74 26                	je     801435 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80140f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801416:	83 ec 0c             	sub    $0xc,%esp
  801419:	25 07 0e 00 00       	and    $0xe07,%eax
  80141e:	50                   	push   %eax
  80141f:	ff 75 d4             	pushl  -0x2c(%ebp)
  801422:	6a 00                	push   $0x0
  801424:	57                   	push   %edi
  801425:	6a 00                	push   $0x0
  801427:	e8 8a f9 ff ff       	call   800db6 <sys_page_map>
  80142c:	89 c7                	mov    %eax,%edi
  80142e:	83 c4 20             	add    $0x20,%esp
  801431:	85 c0                	test   %eax,%eax
  801433:	78 2e                	js     801463 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801435:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801438:	89 d0                	mov    %edx,%eax
  80143a:	c1 e8 0c             	shr    $0xc,%eax
  80143d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801444:	83 ec 0c             	sub    $0xc,%esp
  801447:	25 07 0e 00 00       	and    $0xe07,%eax
  80144c:	50                   	push   %eax
  80144d:	53                   	push   %ebx
  80144e:	6a 00                	push   $0x0
  801450:	52                   	push   %edx
  801451:	6a 00                	push   $0x0
  801453:	e8 5e f9 ff ff       	call   800db6 <sys_page_map>
  801458:	89 c7                	mov    %eax,%edi
  80145a:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80145d:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80145f:	85 ff                	test   %edi,%edi
  801461:	79 1d                	jns    801480 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801463:	83 ec 08             	sub    $0x8,%esp
  801466:	53                   	push   %ebx
  801467:	6a 00                	push   $0x0
  801469:	e8 8a f9 ff ff       	call   800df8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80146e:	83 c4 08             	add    $0x8,%esp
  801471:	ff 75 d4             	pushl  -0x2c(%ebp)
  801474:	6a 00                	push   $0x0
  801476:	e8 7d f9 ff ff       	call   800df8 <sys_page_unmap>
	return r;
  80147b:	83 c4 10             	add    $0x10,%esp
  80147e:	89 f8                	mov    %edi,%eax
}
  801480:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801483:	5b                   	pop    %ebx
  801484:	5e                   	pop    %esi
  801485:	5f                   	pop    %edi
  801486:	5d                   	pop    %ebp
  801487:	c3                   	ret    

00801488 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801488:	55                   	push   %ebp
  801489:	89 e5                	mov    %esp,%ebp
  80148b:	53                   	push   %ebx
  80148c:	83 ec 14             	sub    $0x14,%esp
  80148f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801492:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801495:	50                   	push   %eax
  801496:	53                   	push   %ebx
  801497:	e8 86 fd ff ff       	call   801222 <fd_lookup>
  80149c:	83 c4 08             	add    $0x8,%esp
  80149f:	89 c2                	mov    %eax,%edx
  8014a1:	85 c0                	test   %eax,%eax
  8014a3:	78 6d                	js     801512 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014a5:	83 ec 08             	sub    $0x8,%esp
  8014a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ab:	50                   	push   %eax
  8014ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014af:	ff 30                	pushl  (%eax)
  8014b1:	e8 c2 fd ff ff       	call   801278 <dev_lookup>
  8014b6:	83 c4 10             	add    $0x10,%esp
  8014b9:	85 c0                	test   %eax,%eax
  8014bb:	78 4c                	js     801509 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014bd:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014c0:	8b 42 08             	mov    0x8(%edx),%eax
  8014c3:	83 e0 03             	and    $0x3,%eax
  8014c6:	83 f8 01             	cmp    $0x1,%eax
  8014c9:	75 21                	jne    8014ec <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014cb:	a1 04 40 80 00       	mov    0x804004,%eax
  8014d0:	8b 40 48             	mov    0x48(%eax),%eax
  8014d3:	83 ec 04             	sub    $0x4,%esp
  8014d6:	53                   	push   %ebx
  8014d7:	50                   	push   %eax
  8014d8:	68 04 29 80 00       	push   $0x802904
  8014dd:	e8 09 ef ff ff       	call   8003eb <cprintf>
		return -E_INVAL;
  8014e2:	83 c4 10             	add    $0x10,%esp
  8014e5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014ea:	eb 26                	jmp    801512 <read+0x8a>
	}
	if (!dev->dev_read)
  8014ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014ef:	8b 40 08             	mov    0x8(%eax),%eax
  8014f2:	85 c0                	test   %eax,%eax
  8014f4:	74 17                	je     80150d <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014f6:	83 ec 04             	sub    $0x4,%esp
  8014f9:	ff 75 10             	pushl  0x10(%ebp)
  8014fc:	ff 75 0c             	pushl  0xc(%ebp)
  8014ff:	52                   	push   %edx
  801500:	ff d0                	call   *%eax
  801502:	89 c2                	mov    %eax,%edx
  801504:	83 c4 10             	add    $0x10,%esp
  801507:	eb 09                	jmp    801512 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801509:	89 c2                	mov    %eax,%edx
  80150b:	eb 05                	jmp    801512 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80150d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801512:	89 d0                	mov    %edx,%eax
  801514:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801517:	c9                   	leave  
  801518:	c3                   	ret    

00801519 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801519:	55                   	push   %ebp
  80151a:	89 e5                	mov    %esp,%ebp
  80151c:	57                   	push   %edi
  80151d:	56                   	push   %esi
  80151e:	53                   	push   %ebx
  80151f:	83 ec 0c             	sub    $0xc,%esp
  801522:	8b 7d 08             	mov    0x8(%ebp),%edi
  801525:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801528:	bb 00 00 00 00       	mov    $0x0,%ebx
  80152d:	eb 21                	jmp    801550 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80152f:	83 ec 04             	sub    $0x4,%esp
  801532:	89 f0                	mov    %esi,%eax
  801534:	29 d8                	sub    %ebx,%eax
  801536:	50                   	push   %eax
  801537:	89 d8                	mov    %ebx,%eax
  801539:	03 45 0c             	add    0xc(%ebp),%eax
  80153c:	50                   	push   %eax
  80153d:	57                   	push   %edi
  80153e:	e8 45 ff ff ff       	call   801488 <read>
		if (m < 0)
  801543:	83 c4 10             	add    $0x10,%esp
  801546:	85 c0                	test   %eax,%eax
  801548:	78 10                	js     80155a <readn+0x41>
			return m;
		if (m == 0)
  80154a:	85 c0                	test   %eax,%eax
  80154c:	74 0a                	je     801558 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80154e:	01 c3                	add    %eax,%ebx
  801550:	39 f3                	cmp    %esi,%ebx
  801552:	72 db                	jb     80152f <readn+0x16>
  801554:	89 d8                	mov    %ebx,%eax
  801556:	eb 02                	jmp    80155a <readn+0x41>
  801558:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80155a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80155d:	5b                   	pop    %ebx
  80155e:	5e                   	pop    %esi
  80155f:	5f                   	pop    %edi
  801560:	5d                   	pop    %ebp
  801561:	c3                   	ret    

00801562 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801562:	55                   	push   %ebp
  801563:	89 e5                	mov    %esp,%ebp
  801565:	53                   	push   %ebx
  801566:	83 ec 14             	sub    $0x14,%esp
  801569:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80156c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80156f:	50                   	push   %eax
  801570:	53                   	push   %ebx
  801571:	e8 ac fc ff ff       	call   801222 <fd_lookup>
  801576:	83 c4 08             	add    $0x8,%esp
  801579:	89 c2                	mov    %eax,%edx
  80157b:	85 c0                	test   %eax,%eax
  80157d:	78 68                	js     8015e7 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80157f:	83 ec 08             	sub    $0x8,%esp
  801582:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801585:	50                   	push   %eax
  801586:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801589:	ff 30                	pushl  (%eax)
  80158b:	e8 e8 fc ff ff       	call   801278 <dev_lookup>
  801590:	83 c4 10             	add    $0x10,%esp
  801593:	85 c0                	test   %eax,%eax
  801595:	78 47                	js     8015de <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801597:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80159a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80159e:	75 21                	jne    8015c1 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015a0:	a1 04 40 80 00       	mov    0x804004,%eax
  8015a5:	8b 40 48             	mov    0x48(%eax),%eax
  8015a8:	83 ec 04             	sub    $0x4,%esp
  8015ab:	53                   	push   %ebx
  8015ac:	50                   	push   %eax
  8015ad:	68 20 29 80 00       	push   $0x802920
  8015b2:	e8 34 ee ff ff       	call   8003eb <cprintf>
		return -E_INVAL;
  8015b7:	83 c4 10             	add    $0x10,%esp
  8015ba:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015bf:	eb 26                	jmp    8015e7 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015c4:	8b 52 0c             	mov    0xc(%edx),%edx
  8015c7:	85 d2                	test   %edx,%edx
  8015c9:	74 17                	je     8015e2 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015cb:	83 ec 04             	sub    $0x4,%esp
  8015ce:	ff 75 10             	pushl  0x10(%ebp)
  8015d1:	ff 75 0c             	pushl  0xc(%ebp)
  8015d4:	50                   	push   %eax
  8015d5:	ff d2                	call   *%edx
  8015d7:	89 c2                	mov    %eax,%edx
  8015d9:	83 c4 10             	add    $0x10,%esp
  8015dc:	eb 09                	jmp    8015e7 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015de:	89 c2                	mov    %eax,%edx
  8015e0:	eb 05                	jmp    8015e7 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015e2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8015e7:	89 d0                	mov    %edx,%eax
  8015e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015ec:	c9                   	leave  
  8015ed:	c3                   	ret    

008015ee <seek>:

int
seek(int fdnum, off_t offset)
{
  8015ee:	55                   	push   %ebp
  8015ef:	89 e5                	mov    %esp,%ebp
  8015f1:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015f4:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015f7:	50                   	push   %eax
  8015f8:	ff 75 08             	pushl  0x8(%ebp)
  8015fb:	e8 22 fc ff ff       	call   801222 <fd_lookup>
  801600:	83 c4 08             	add    $0x8,%esp
  801603:	85 c0                	test   %eax,%eax
  801605:	78 0e                	js     801615 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801607:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80160a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80160d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801610:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801615:	c9                   	leave  
  801616:	c3                   	ret    

00801617 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801617:	55                   	push   %ebp
  801618:	89 e5                	mov    %esp,%ebp
  80161a:	53                   	push   %ebx
  80161b:	83 ec 14             	sub    $0x14,%esp
  80161e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801621:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801624:	50                   	push   %eax
  801625:	53                   	push   %ebx
  801626:	e8 f7 fb ff ff       	call   801222 <fd_lookup>
  80162b:	83 c4 08             	add    $0x8,%esp
  80162e:	89 c2                	mov    %eax,%edx
  801630:	85 c0                	test   %eax,%eax
  801632:	78 65                	js     801699 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801634:	83 ec 08             	sub    $0x8,%esp
  801637:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80163a:	50                   	push   %eax
  80163b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80163e:	ff 30                	pushl  (%eax)
  801640:	e8 33 fc ff ff       	call   801278 <dev_lookup>
  801645:	83 c4 10             	add    $0x10,%esp
  801648:	85 c0                	test   %eax,%eax
  80164a:	78 44                	js     801690 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80164c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80164f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801653:	75 21                	jne    801676 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801655:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80165a:	8b 40 48             	mov    0x48(%eax),%eax
  80165d:	83 ec 04             	sub    $0x4,%esp
  801660:	53                   	push   %ebx
  801661:	50                   	push   %eax
  801662:	68 e0 28 80 00       	push   $0x8028e0
  801667:	e8 7f ed ff ff       	call   8003eb <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80166c:	83 c4 10             	add    $0x10,%esp
  80166f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801674:	eb 23                	jmp    801699 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801676:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801679:	8b 52 18             	mov    0x18(%edx),%edx
  80167c:	85 d2                	test   %edx,%edx
  80167e:	74 14                	je     801694 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801680:	83 ec 08             	sub    $0x8,%esp
  801683:	ff 75 0c             	pushl  0xc(%ebp)
  801686:	50                   	push   %eax
  801687:	ff d2                	call   *%edx
  801689:	89 c2                	mov    %eax,%edx
  80168b:	83 c4 10             	add    $0x10,%esp
  80168e:	eb 09                	jmp    801699 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801690:	89 c2                	mov    %eax,%edx
  801692:	eb 05                	jmp    801699 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801694:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801699:	89 d0                	mov    %edx,%eax
  80169b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80169e:	c9                   	leave  
  80169f:	c3                   	ret    

008016a0 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016a0:	55                   	push   %ebp
  8016a1:	89 e5                	mov    %esp,%ebp
  8016a3:	53                   	push   %ebx
  8016a4:	83 ec 14             	sub    $0x14,%esp
  8016a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016aa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016ad:	50                   	push   %eax
  8016ae:	ff 75 08             	pushl  0x8(%ebp)
  8016b1:	e8 6c fb ff ff       	call   801222 <fd_lookup>
  8016b6:	83 c4 08             	add    $0x8,%esp
  8016b9:	89 c2                	mov    %eax,%edx
  8016bb:	85 c0                	test   %eax,%eax
  8016bd:	78 58                	js     801717 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016bf:	83 ec 08             	sub    $0x8,%esp
  8016c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016c5:	50                   	push   %eax
  8016c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016c9:	ff 30                	pushl  (%eax)
  8016cb:	e8 a8 fb ff ff       	call   801278 <dev_lookup>
  8016d0:	83 c4 10             	add    $0x10,%esp
  8016d3:	85 c0                	test   %eax,%eax
  8016d5:	78 37                	js     80170e <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016da:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016de:	74 32                	je     801712 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016e0:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016e3:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016ea:	00 00 00 
	stat->st_isdir = 0;
  8016ed:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016f4:	00 00 00 
	stat->st_dev = dev;
  8016f7:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016fd:	83 ec 08             	sub    $0x8,%esp
  801700:	53                   	push   %ebx
  801701:	ff 75 f0             	pushl  -0x10(%ebp)
  801704:	ff 50 14             	call   *0x14(%eax)
  801707:	89 c2                	mov    %eax,%edx
  801709:	83 c4 10             	add    $0x10,%esp
  80170c:	eb 09                	jmp    801717 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80170e:	89 c2                	mov    %eax,%edx
  801710:	eb 05                	jmp    801717 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801712:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801717:	89 d0                	mov    %edx,%eax
  801719:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80171c:	c9                   	leave  
  80171d:	c3                   	ret    

0080171e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80171e:	55                   	push   %ebp
  80171f:	89 e5                	mov    %esp,%ebp
  801721:	56                   	push   %esi
  801722:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801723:	83 ec 08             	sub    $0x8,%esp
  801726:	6a 00                	push   $0x0
  801728:	ff 75 08             	pushl  0x8(%ebp)
  80172b:	e8 0c 02 00 00       	call   80193c <open>
  801730:	89 c3                	mov    %eax,%ebx
  801732:	83 c4 10             	add    $0x10,%esp
  801735:	85 c0                	test   %eax,%eax
  801737:	78 1b                	js     801754 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801739:	83 ec 08             	sub    $0x8,%esp
  80173c:	ff 75 0c             	pushl  0xc(%ebp)
  80173f:	50                   	push   %eax
  801740:	e8 5b ff ff ff       	call   8016a0 <fstat>
  801745:	89 c6                	mov    %eax,%esi
	close(fd);
  801747:	89 1c 24             	mov    %ebx,(%esp)
  80174a:	e8 fd fb ff ff       	call   80134c <close>
	return r;
  80174f:	83 c4 10             	add    $0x10,%esp
  801752:	89 f0                	mov    %esi,%eax
}
  801754:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801757:	5b                   	pop    %ebx
  801758:	5e                   	pop    %esi
  801759:	5d                   	pop    %ebp
  80175a:	c3                   	ret    

0080175b <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80175b:	55                   	push   %ebp
  80175c:	89 e5                	mov    %esp,%ebp
  80175e:	56                   	push   %esi
  80175f:	53                   	push   %ebx
  801760:	89 c6                	mov    %eax,%esi
  801762:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801764:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80176b:	75 12                	jne    80177f <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80176d:	83 ec 0c             	sub    $0xc,%esp
  801770:	6a 01                	push   $0x1
  801772:	e8 ca 08 00 00       	call   802041 <ipc_find_env>
  801777:	a3 00 40 80 00       	mov    %eax,0x804000
  80177c:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80177f:	6a 07                	push   $0x7
  801781:	68 00 50 80 00       	push   $0x805000
  801786:	56                   	push   %esi
  801787:	ff 35 00 40 80 00    	pushl  0x804000
  80178d:	e8 5b 08 00 00       	call   801fed <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801792:	83 c4 0c             	add    $0xc,%esp
  801795:	6a 00                	push   $0x0
  801797:	53                   	push   %ebx
  801798:	6a 00                	push   $0x0
  80179a:	e8 e5 07 00 00       	call   801f84 <ipc_recv>
}
  80179f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017a2:	5b                   	pop    %ebx
  8017a3:	5e                   	pop    %esi
  8017a4:	5d                   	pop    %ebp
  8017a5:	c3                   	ret    

008017a6 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017a6:	55                   	push   %ebp
  8017a7:	89 e5                	mov    %esp,%ebp
  8017a9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8017af:	8b 40 0c             	mov    0xc(%eax),%eax
  8017b2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017ba:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8017c4:	b8 02 00 00 00       	mov    $0x2,%eax
  8017c9:	e8 8d ff ff ff       	call   80175b <fsipc>
}
  8017ce:	c9                   	leave  
  8017cf:	c3                   	ret    

008017d0 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017d0:	55                   	push   %ebp
  8017d1:	89 e5                	mov    %esp,%ebp
  8017d3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d9:	8b 40 0c             	mov    0xc(%eax),%eax
  8017dc:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8017e6:	b8 06 00 00 00       	mov    $0x6,%eax
  8017eb:	e8 6b ff ff ff       	call   80175b <fsipc>
}
  8017f0:	c9                   	leave  
  8017f1:	c3                   	ret    

008017f2 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017f2:	55                   	push   %ebp
  8017f3:	89 e5                	mov    %esp,%ebp
  8017f5:	53                   	push   %ebx
  8017f6:	83 ec 04             	sub    $0x4,%esp
  8017f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ff:	8b 40 0c             	mov    0xc(%eax),%eax
  801802:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801807:	ba 00 00 00 00       	mov    $0x0,%edx
  80180c:	b8 05 00 00 00       	mov    $0x5,%eax
  801811:	e8 45 ff ff ff       	call   80175b <fsipc>
  801816:	85 c0                	test   %eax,%eax
  801818:	78 2c                	js     801846 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80181a:	83 ec 08             	sub    $0x8,%esp
  80181d:	68 00 50 80 00       	push   $0x805000
  801822:	53                   	push   %ebx
  801823:	e8 48 f1 ff ff       	call   800970 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801828:	a1 80 50 80 00       	mov    0x805080,%eax
  80182d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801833:	a1 84 50 80 00       	mov    0x805084,%eax
  801838:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80183e:	83 c4 10             	add    $0x10,%esp
  801841:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801846:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801849:	c9                   	leave  
  80184a:	c3                   	ret    

0080184b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80184b:	55                   	push   %ebp
  80184c:	89 e5                	mov    %esp,%ebp
  80184e:	53                   	push   %ebx
  80184f:	83 ec 08             	sub    $0x8,%esp
  801852:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801855:	8b 55 08             	mov    0x8(%ebp),%edx
  801858:	8b 52 0c             	mov    0xc(%edx),%edx
  80185b:	89 15 00 50 80 00    	mov    %edx,0x805000
  801861:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801866:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  80186b:	0f 46 d8             	cmovbe %eax,%ebx
	
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  80186e:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  801874:	53                   	push   %ebx
  801875:	ff 75 0c             	pushl  0xc(%ebp)
  801878:	68 08 50 80 00       	push   $0x805008
  80187d:	e8 80 f2 ff ff       	call   800b02 <memmove>

	
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) 
  801882:	ba 00 00 00 00       	mov    $0x0,%edx
  801887:	b8 04 00 00 00       	mov    $0x4,%eax
  80188c:	e8 ca fe ff ff       	call   80175b <fsipc>
  801891:	83 c4 10             	add    $0x10,%esp
  801894:	85 c0                	test   %eax,%eax
  801896:	78 1d                	js     8018b5 <devfile_write+0x6a>
		return r;
	assert(r <= n_real); 
  801898:	39 d8                	cmp    %ebx,%eax
  80189a:	76 19                	jbe    8018b5 <devfile_write+0x6a>
  80189c:	68 50 29 80 00       	push   $0x802950
  8018a1:	68 5c 29 80 00       	push   $0x80295c
  8018a6:	68 a3 00 00 00       	push   $0xa3
  8018ab:	68 71 29 80 00       	push   $0x802971
  8018b0:	e8 5d ea ff ff       	call   800312 <_panic>
	return r;
}
  8018b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018b8:	c9                   	leave  
  8018b9:	c3                   	ret    

008018ba <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018ba:	55                   	push   %ebp
  8018bb:	89 e5                	mov    %esp,%ebp
  8018bd:	56                   	push   %esi
  8018be:	53                   	push   %ebx
  8018bf:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c5:	8b 40 0c             	mov    0xc(%eax),%eax
  8018c8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018cd:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8018d8:	b8 03 00 00 00       	mov    $0x3,%eax
  8018dd:	e8 79 fe ff ff       	call   80175b <fsipc>
  8018e2:	89 c3                	mov    %eax,%ebx
  8018e4:	85 c0                	test   %eax,%eax
  8018e6:	78 4b                	js     801933 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018e8:	39 c6                	cmp    %eax,%esi
  8018ea:	73 16                	jae    801902 <devfile_read+0x48>
  8018ec:	68 7c 29 80 00       	push   $0x80297c
  8018f1:	68 5c 29 80 00       	push   $0x80295c
  8018f6:	6a 7c                	push   $0x7c
  8018f8:	68 71 29 80 00       	push   $0x802971
  8018fd:	e8 10 ea ff ff       	call   800312 <_panic>
	assert(r <= PGSIZE);
  801902:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801907:	7e 16                	jle    80191f <devfile_read+0x65>
  801909:	68 83 29 80 00       	push   $0x802983
  80190e:	68 5c 29 80 00       	push   $0x80295c
  801913:	6a 7d                	push   $0x7d
  801915:	68 71 29 80 00       	push   $0x802971
  80191a:	e8 f3 e9 ff ff       	call   800312 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80191f:	83 ec 04             	sub    $0x4,%esp
  801922:	50                   	push   %eax
  801923:	68 00 50 80 00       	push   $0x805000
  801928:	ff 75 0c             	pushl  0xc(%ebp)
  80192b:	e8 d2 f1 ff ff       	call   800b02 <memmove>
	return r;
  801930:	83 c4 10             	add    $0x10,%esp
}
  801933:	89 d8                	mov    %ebx,%eax
  801935:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801938:	5b                   	pop    %ebx
  801939:	5e                   	pop    %esi
  80193a:	5d                   	pop    %ebp
  80193b:	c3                   	ret    

0080193c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80193c:	55                   	push   %ebp
  80193d:	89 e5                	mov    %esp,%ebp
  80193f:	53                   	push   %ebx
  801940:	83 ec 20             	sub    $0x20,%esp
  801943:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801946:	53                   	push   %ebx
  801947:	e8 eb ef ff ff       	call   800937 <strlen>
  80194c:	83 c4 10             	add    $0x10,%esp
  80194f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801954:	7f 67                	jg     8019bd <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801956:	83 ec 0c             	sub    $0xc,%esp
  801959:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80195c:	50                   	push   %eax
  80195d:	e8 71 f8 ff ff       	call   8011d3 <fd_alloc>
  801962:	83 c4 10             	add    $0x10,%esp
		return r;
  801965:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801967:	85 c0                	test   %eax,%eax
  801969:	78 57                	js     8019c2 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80196b:	83 ec 08             	sub    $0x8,%esp
  80196e:	53                   	push   %ebx
  80196f:	68 00 50 80 00       	push   $0x805000
  801974:	e8 f7 ef ff ff       	call   800970 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801979:	8b 45 0c             	mov    0xc(%ebp),%eax
  80197c:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801981:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801984:	b8 01 00 00 00       	mov    $0x1,%eax
  801989:	e8 cd fd ff ff       	call   80175b <fsipc>
  80198e:	89 c3                	mov    %eax,%ebx
  801990:	83 c4 10             	add    $0x10,%esp
  801993:	85 c0                	test   %eax,%eax
  801995:	79 14                	jns    8019ab <open+0x6f>
		fd_close(fd, 0);
  801997:	83 ec 08             	sub    $0x8,%esp
  80199a:	6a 00                	push   $0x0
  80199c:	ff 75 f4             	pushl  -0xc(%ebp)
  80199f:	e8 27 f9 ff ff       	call   8012cb <fd_close>
		return r;
  8019a4:	83 c4 10             	add    $0x10,%esp
  8019a7:	89 da                	mov    %ebx,%edx
  8019a9:	eb 17                	jmp    8019c2 <open+0x86>
	}

	return fd2num(fd);
  8019ab:	83 ec 0c             	sub    $0xc,%esp
  8019ae:	ff 75 f4             	pushl  -0xc(%ebp)
  8019b1:	e8 f6 f7 ff ff       	call   8011ac <fd2num>
  8019b6:	89 c2                	mov    %eax,%edx
  8019b8:	83 c4 10             	add    $0x10,%esp
  8019bb:	eb 05                	jmp    8019c2 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019bd:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019c2:	89 d0                	mov    %edx,%eax
  8019c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019c7:	c9                   	leave  
  8019c8:	c3                   	ret    

008019c9 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019c9:	55                   	push   %ebp
  8019ca:	89 e5                	mov    %esp,%ebp
  8019cc:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8019d4:	b8 08 00 00 00       	mov    $0x8,%eax
  8019d9:	e8 7d fd ff ff       	call   80175b <fsipc>
}
  8019de:	c9                   	leave  
  8019df:	c3                   	ret    

008019e0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019e0:	55                   	push   %ebp
  8019e1:	89 e5                	mov    %esp,%ebp
  8019e3:	56                   	push   %esi
  8019e4:	53                   	push   %ebx
  8019e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019e8:	83 ec 0c             	sub    $0xc,%esp
  8019eb:	ff 75 08             	pushl  0x8(%ebp)
  8019ee:	e8 c9 f7 ff ff       	call   8011bc <fd2data>
  8019f3:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019f5:	83 c4 08             	add    $0x8,%esp
  8019f8:	68 8f 29 80 00       	push   $0x80298f
  8019fd:	53                   	push   %ebx
  8019fe:	e8 6d ef ff ff       	call   800970 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a03:	8b 46 04             	mov    0x4(%esi),%eax
  801a06:	2b 06                	sub    (%esi),%eax
  801a08:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a0e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a15:	00 00 00 
	stat->st_dev = &devpipe;
  801a18:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  801a1f:	30 80 00 
	return 0;
}
  801a22:	b8 00 00 00 00       	mov    $0x0,%eax
  801a27:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a2a:	5b                   	pop    %ebx
  801a2b:	5e                   	pop    %esi
  801a2c:	5d                   	pop    %ebp
  801a2d:	c3                   	ret    

00801a2e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a2e:	55                   	push   %ebp
  801a2f:	89 e5                	mov    %esp,%ebp
  801a31:	53                   	push   %ebx
  801a32:	83 ec 0c             	sub    $0xc,%esp
  801a35:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a38:	53                   	push   %ebx
  801a39:	6a 00                	push   $0x0
  801a3b:	e8 b8 f3 ff ff       	call   800df8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a40:	89 1c 24             	mov    %ebx,(%esp)
  801a43:	e8 74 f7 ff ff       	call   8011bc <fd2data>
  801a48:	83 c4 08             	add    $0x8,%esp
  801a4b:	50                   	push   %eax
  801a4c:	6a 00                	push   $0x0
  801a4e:	e8 a5 f3 ff ff       	call   800df8 <sys_page_unmap>
}
  801a53:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a56:	c9                   	leave  
  801a57:	c3                   	ret    

00801a58 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a58:	55                   	push   %ebp
  801a59:	89 e5                	mov    %esp,%ebp
  801a5b:	57                   	push   %edi
  801a5c:	56                   	push   %esi
  801a5d:	53                   	push   %ebx
  801a5e:	83 ec 1c             	sub    $0x1c,%esp
  801a61:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a64:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a66:	a1 04 40 80 00       	mov    0x804004,%eax
  801a6b:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a6e:	83 ec 0c             	sub    $0xc,%esp
  801a71:	ff 75 e0             	pushl  -0x20(%ebp)
  801a74:	e8 01 06 00 00       	call   80207a <pageref>
  801a79:	89 c3                	mov    %eax,%ebx
  801a7b:	89 3c 24             	mov    %edi,(%esp)
  801a7e:	e8 f7 05 00 00       	call   80207a <pageref>
  801a83:	83 c4 10             	add    $0x10,%esp
  801a86:	39 c3                	cmp    %eax,%ebx
  801a88:	0f 94 c1             	sete   %cl
  801a8b:	0f b6 c9             	movzbl %cl,%ecx
  801a8e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a91:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a97:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a9a:	39 ce                	cmp    %ecx,%esi
  801a9c:	74 1b                	je     801ab9 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a9e:	39 c3                	cmp    %eax,%ebx
  801aa0:	75 c4                	jne    801a66 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801aa2:	8b 42 58             	mov    0x58(%edx),%eax
  801aa5:	ff 75 e4             	pushl  -0x1c(%ebp)
  801aa8:	50                   	push   %eax
  801aa9:	56                   	push   %esi
  801aaa:	68 96 29 80 00       	push   $0x802996
  801aaf:	e8 37 e9 ff ff       	call   8003eb <cprintf>
  801ab4:	83 c4 10             	add    $0x10,%esp
  801ab7:	eb ad                	jmp    801a66 <_pipeisclosed+0xe>
	}
}
  801ab9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801abc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801abf:	5b                   	pop    %ebx
  801ac0:	5e                   	pop    %esi
  801ac1:	5f                   	pop    %edi
  801ac2:	5d                   	pop    %ebp
  801ac3:	c3                   	ret    

00801ac4 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ac4:	55                   	push   %ebp
  801ac5:	89 e5                	mov    %esp,%ebp
  801ac7:	57                   	push   %edi
  801ac8:	56                   	push   %esi
  801ac9:	53                   	push   %ebx
  801aca:	83 ec 28             	sub    $0x28,%esp
  801acd:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801ad0:	56                   	push   %esi
  801ad1:	e8 e6 f6 ff ff       	call   8011bc <fd2data>
  801ad6:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ad8:	83 c4 10             	add    $0x10,%esp
  801adb:	bf 00 00 00 00       	mov    $0x0,%edi
  801ae0:	eb 4b                	jmp    801b2d <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ae2:	89 da                	mov    %ebx,%edx
  801ae4:	89 f0                	mov    %esi,%eax
  801ae6:	e8 6d ff ff ff       	call   801a58 <_pipeisclosed>
  801aeb:	85 c0                	test   %eax,%eax
  801aed:	75 48                	jne    801b37 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801aef:	e8 60 f2 ff ff       	call   800d54 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801af4:	8b 43 04             	mov    0x4(%ebx),%eax
  801af7:	8b 0b                	mov    (%ebx),%ecx
  801af9:	8d 51 20             	lea    0x20(%ecx),%edx
  801afc:	39 d0                	cmp    %edx,%eax
  801afe:	73 e2                	jae    801ae2 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b03:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b07:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b0a:	89 c2                	mov    %eax,%edx
  801b0c:	c1 fa 1f             	sar    $0x1f,%edx
  801b0f:	89 d1                	mov    %edx,%ecx
  801b11:	c1 e9 1b             	shr    $0x1b,%ecx
  801b14:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b17:	83 e2 1f             	and    $0x1f,%edx
  801b1a:	29 ca                	sub    %ecx,%edx
  801b1c:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b20:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b24:	83 c0 01             	add    $0x1,%eax
  801b27:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b2a:	83 c7 01             	add    $0x1,%edi
  801b2d:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b30:	75 c2                	jne    801af4 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b32:	8b 45 10             	mov    0x10(%ebp),%eax
  801b35:	eb 05                	jmp    801b3c <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b37:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b3f:	5b                   	pop    %ebx
  801b40:	5e                   	pop    %esi
  801b41:	5f                   	pop    %edi
  801b42:	5d                   	pop    %ebp
  801b43:	c3                   	ret    

00801b44 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b44:	55                   	push   %ebp
  801b45:	89 e5                	mov    %esp,%ebp
  801b47:	57                   	push   %edi
  801b48:	56                   	push   %esi
  801b49:	53                   	push   %ebx
  801b4a:	83 ec 18             	sub    $0x18,%esp
  801b4d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b50:	57                   	push   %edi
  801b51:	e8 66 f6 ff ff       	call   8011bc <fd2data>
  801b56:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b58:	83 c4 10             	add    $0x10,%esp
  801b5b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b60:	eb 3d                	jmp    801b9f <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b62:	85 db                	test   %ebx,%ebx
  801b64:	74 04                	je     801b6a <devpipe_read+0x26>
				return i;
  801b66:	89 d8                	mov    %ebx,%eax
  801b68:	eb 44                	jmp    801bae <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b6a:	89 f2                	mov    %esi,%edx
  801b6c:	89 f8                	mov    %edi,%eax
  801b6e:	e8 e5 fe ff ff       	call   801a58 <_pipeisclosed>
  801b73:	85 c0                	test   %eax,%eax
  801b75:	75 32                	jne    801ba9 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b77:	e8 d8 f1 ff ff       	call   800d54 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b7c:	8b 06                	mov    (%esi),%eax
  801b7e:	3b 46 04             	cmp    0x4(%esi),%eax
  801b81:	74 df                	je     801b62 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b83:	99                   	cltd   
  801b84:	c1 ea 1b             	shr    $0x1b,%edx
  801b87:	01 d0                	add    %edx,%eax
  801b89:	83 e0 1f             	and    $0x1f,%eax
  801b8c:	29 d0                	sub    %edx,%eax
  801b8e:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b96:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b99:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b9c:	83 c3 01             	add    $0x1,%ebx
  801b9f:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801ba2:	75 d8                	jne    801b7c <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801ba4:	8b 45 10             	mov    0x10(%ebp),%eax
  801ba7:	eb 05                	jmp    801bae <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ba9:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801bae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bb1:	5b                   	pop    %ebx
  801bb2:	5e                   	pop    %esi
  801bb3:	5f                   	pop    %edi
  801bb4:	5d                   	pop    %ebp
  801bb5:	c3                   	ret    

00801bb6 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801bb6:	55                   	push   %ebp
  801bb7:	89 e5                	mov    %esp,%ebp
  801bb9:	56                   	push   %esi
  801bba:	53                   	push   %ebx
  801bbb:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801bbe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bc1:	50                   	push   %eax
  801bc2:	e8 0c f6 ff ff       	call   8011d3 <fd_alloc>
  801bc7:	83 c4 10             	add    $0x10,%esp
  801bca:	89 c2                	mov    %eax,%edx
  801bcc:	85 c0                	test   %eax,%eax
  801bce:	0f 88 2c 01 00 00    	js     801d00 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bd4:	83 ec 04             	sub    $0x4,%esp
  801bd7:	68 07 04 00 00       	push   $0x407
  801bdc:	ff 75 f4             	pushl  -0xc(%ebp)
  801bdf:	6a 00                	push   $0x0
  801be1:	e8 8d f1 ff ff       	call   800d73 <sys_page_alloc>
  801be6:	83 c4 10             	add    $0x10,%esp
  801be9:	89 c2                	mov    %eax,%edx
  801beb:	85 c0                	test   %eax,%eax
  801bed:	0f 88 0d 01 00 00    	js     801d00 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801bf3:	83 ec 0c             	sub    $0xc,%esp
  801bf6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bf9:	50                   	push   %eax
  801bfa:	e8 d4 f5 ff ff       	call   8011d3 <fd_alloc>
  801bff:	89 c3                	mov    %eax,%ebx
  801c01:	83 c4 10             	add    $0x10,%esp
  801c04:	85 c0                	test   %eax,%eax
  801c06:	0f 88 e2 00 00 00    	js     801cee <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c0c:	83 ec 04             	sub    $0x4,%esp
  801c0f:	68 07 04 00 00       	push   $0x407
  801c14:	ff 75 f0             	pushl  -0x10(%ebp)
  801c17:	6a 00                	push   $0x0
  801c19:	e8 55 f1 ff ff       	call   800d73 <sys_page_alloc>
  801c1e:	89 c3                	mov    %eax,%ebx
  801c20:	83 c4 10             	add    $0x10,%esp
  801c23:	85 c0                	test   %eax,%eax
  801c25:	0f 88 c3 00 00 00    	js     801cee <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c2b:	83 ec 0c             	sub    $0xc,%esp
  801c2e:	ff 75 f4             	pushl  -0xc(%ebp)
  801c31:	e8 86 f5 ff ff       	call   8011bc <fd2data>
  801c36:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c38:	83 c4 0c             	add    $0xc,%esp
  801c3b:	68 07 04 00 00       	push   $0x407
  801c40:	50                   	push   %eax
  801c41:	6a 00                	push   $0x0
  801c43:	e8 2b f1 ff ff       	call   800d73 <sys_page_alloc>
  801c48:	89 c3                	mov    %eax,%ebx
  801c4a:	83 c4 10             	add    $0x10,%esp
  801c4d:	85 c0                	test   %eax,%eax
  801c4f:	0f 88 89 00 00 00    	js     801cde <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c55:	83 ec 0c             	sub    $0xc,%esp
  801c58:	ff 75 f0             	pushl  -0x10(%ebp)
  801c5b:	e8 5c f5 ff ff       	call   8011bc <fd2data>
  801c60:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c67:	50                   	push   %eax
  801c68:	6a 00                	push   $0x0
  801c6a:	56                   	push   %esi
  801c6b:	6a 00                	push   $0x0
  801c6d:	e8 44 f1 ff ff       	call   800db6 <sys_page_map>
  801c72:	89 c3                	mov    %eax,%ebx
  801c74:	83 c4 20             	add    $0x20,%esp
  801c77:	85 c0                	test   %eax,%eax
  801c79:	78 55                	js     801cd0 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c7b:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801c81:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c84:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c86:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c89:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c90:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801c96:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c99:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c9e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801ca5:	83 ec 0c             	sub    $0xc,%esp
  801ca8:	ff 75 f4             	pushl  -0xc(%ebp)
  801cab:	e8 fc f4 ff ff       	call   8011ac <fd2num>
  801cb0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cb3:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801cb5:	83 c4 04             	add    $0x4,%esp
  801cb8:	ff 75 f0             	pushl  -0x10(%ebp)
  801cbb:	e8 ec f4 ff ff       	call   8011ac <fd2num>
  801cc0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cc3:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801cc6:	83 c4 10             	add    $0x10,%esp
  801cc9:	ba 00 00 00 00       	mov    $0x0,%edx
  801cce:	eb 30                	jmp    801d00 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801cd0:	83 ec 08             	sub    $0x8,%esp
  801cd3:	56                   	push   %esi
  801cd4:	6a 00                	push   $0x0
  801cd6:	e8 1d f1 ff ff       	call   800df8 <sys_page_unmap>
  801cdb:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801cde:	83 ec 08             	sub    $0x8,%esp
  801ce1:	ff 75 f0             	pushl  -0x10(%ebp)
  801ce4:	6a 00                	push   $0x0
  801ce6:	e8 0d f1 ff ff       	call   800df8 <sys_page_unmap>
  801ceb:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801cee:	83 ec 08             	sub    $0x8,%esp
  801cf1:	ff 75 f4             	pushl  -0xc(%ebp)
  801cf4:	6a 00                	push   $0x0
  801cf6:	e8 fd f0 ff ff       	call   800df8 <sys_page_unmap>
  801cfb:	83 c4 10             	add    $0x10,%esp
  801cfe:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d00:	89 d0                	mov    %edx,%eax
  801d02:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d05:	5b                   	pop    %ebx
  801d06:	5e                   	pop    %esi
  801d07:	5d                   	pop    %ebp
  801d08:	c3                   	ret    

00801d09 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d09:	55                   	push   %ebp
  801d0a:	89 e5                	mov    %esp,%ebp
  801d0c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d0f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d12:	50                   	push   %eax
  801d13:	ff 75 08             	pushl  0x8(%ebp)
  801d16:	e8 07 f5 ff ff       	call   801222 <fd_lookup>
  801d1b:	83 c4 10             	add    $0x10,%esp
  801d1e:	85 c0                	test   %eax,%eax
  801d20:	78 18                	js     801d3a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d22:	83 ec 0c             	sub    $0xc,%esp
  801d25:	ff 75 f4             	pushl  -0xc(%ebp)
  801d28:	e8 8f f4 ff ff       	call   8011bc <fd2data>
	return _pipeisclosed(fd, p);
  801d2d:	89 c2                	mov    %eax,%edx
  801d2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d32:	e8 21 fd ff ff       	call   801a58 <_pipeisclosed>
  801d37:	83 c4 10             	add    $0x10,%esp
}
  801d3a:	c9                   	leave  
  801d3b:	c3                   	ret    

00801d3c <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  801d3c:	55                   	push   %ebp
  801d3d:	89 e5                	mov    %esp,%ebp
  801d3f:	56                   	push   %esi
  801d40:	53                   	push   %ebx
  801d41:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  801d44:	85 f6                	test   %esi,%esi
  801d46:	75 16                	jne    801d5e <wait+0x22>
  801d48:	68 ae 29 80 00       	push   $0x8029ae
  801d4d:	68 5c 29 80 00       	push   $0x80295c
  801d52:	6a 09                	push   $0x9
  801d54:	68 b9 29 80 00       	push   $0x8029b9
  801d59:	e8 b4 e5 ff ff       	call   800312 <_panic>
	e = &envs[ENVX(envid)];
  801d5e:	89 f3                	mov    %esi,%ebx
  801d60:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801d66:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  801d69:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  801d6f:	eb 05                	jmp    801d76 <wait+0x3a>
		sys_yield();
  801d71:	e8 de ef ff ff       	call   800d54 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801d76:	8b 43 48             	mov    0x48(%ebx),%eax
  801d79:	39 c6                	cmp    %eax,%esi
  801d7b:	75 07                	jne    801d84 <wait+0x48>
  801d7d:	8b 43 54             	mov    0x54(%ebx),%eax
  801d80:	85 c0                	test   %eax,%eax
  801d82:	75 ed                	jne    801d71 <wait+0x35>
		sys_yield();
}
  801d84:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d87:	5b                   	pop    %ebx
  801d88:	5e                   	pop    %esi
  801d89:	5d                   	pop    %ebp
  801d8a:	c3                   	ret    

00801d8b <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d8b:	55                   	push   %ebp
  801d8c:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d8e:	b8 00 00 00 00       	mov    $0x0,%eax
  801d93:	5d                   	pop    %ebp
  801d94:	c3                   	ret    

00801d95 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d95:	55                   	push   %ebp
  801d96:	89 e5                	mov    %esp,%ebp
  801d98:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d9b:	68 c4 29 80 00       	push   $0x8029c4
  801da0:	ff 75 0c             	pushl  0xc(%ebp)
  801da3:	e8 c8 eb ff ff       	call   800970 <strcpy>
	return 0;
}
  801da8:	b8 00 00 00 00       	mov    $0x0,%eax
  801dad:	c9                   	leave  
  801dae:	c3                   	ret    

00801daf <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801daf:	55                   	push   %ebp
  801db0:	89 e5                	mov    %esp,%ebp
  801db2:	57                   	push   %edi
  801db3:	56                   	push   %esi
  801db4:	53                   	push   %ebx
  801db5:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dbb:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801dc0:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dc6:	eb 2d                	jmp    801df5 <devcons_write+0x46>
		m = n - tot;
  801dc8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801dcb:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801dcd:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801dd0:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801dd5:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801dd8:	83 ec 04             	sub    $0x4,%esp
  801ddb:	53                   	push   %ebx
  801ddc:	03 45 0c             	add    0xc(%ebp),%eax
  801ddf:	50                   	push   %eax
  801de0:	57                   	push   %edi
  801de1:	e8 1c ed ff ff       	call   800b02 <memmove>
		sys_cputs(buf, m);
  801de6:	83 c4 08             	add    $0x8,%esp
  801de9:	53                   	push   %ebx
  801dea:	57                   	push   %edi
  801deb:	e8 c7 ee ff ff       	call   800cb7 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801df0:	01 de                	add    %ebx,%esi
  801df2:	83 c4 10             	add    $0x10,%esp
  801df5:	89 f0                	mov    %esi,%eax
  801df7:	3b 75 10             	cmp    0x10(%ebp),%esi
  801dfa:	72 cc                	jb     801dc8 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801dfc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dff:	5b                   	pop    %ebx
  801e00:	5e                   	pop    %esi
  801e01:	5f                   	pop    %edi
  801e02:	5d                   	pop    %ebp
  801e03:	c3                   	ret    

00801e04 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e04:	55                   	push   %ebp
  801e05:	89 e5                	mov    %esp,%ebp
  801e07:	83 ec 08             	sub    $0x8,%esp
  801e0a:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801e0f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e13:	74 2a                	je     801e3f <devcons_read+0x3b>
  801e15:	eb 05                	jmp    801e1c <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e17:	e8 38 ef ff ff       	call   800d54 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e1c:	e8 b4 ee ff ff       	call   800cd5 <sys_cgetc>
  801e21:	85 c0                	test   %eax,%eax
  801e23:	74 f2                	je     801e17 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e25:	85 c0                	test   %eax,%eax
  801e27:	78 16                	js     801e3f <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e29:	83 f8 04             	cmp    $0x4,%eax
  801e2c:	74 0c                	je     801e3a <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e2e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e31:	88 02                	mov    %al,(%edx)
	return 1;
  801e33:	b8 01 00 00 00       	mov    $0x1,%eax
  801e38:	eb 05                	jmp    801e3f <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e3a:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e3f:	c9                   	leave  
  801e40:	c3                   	ret    

00801e41 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e41:	55                   	push   %ebp
  801e42:	89 e5                	mov    %esp,%ebp
  801e44:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e47:	8b 45 08             	mov    0x8(%ebp),%eax
  801e4a:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e4d:	6a 01                	push   $0x1
  801e4f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e52:	50                   	push   %eax
  801e53:	e8 5f ee ff ff       	call   800cb7 <sys_cputs>
}
  801e58:	83 c4 10             	add    $0x10,%esp
  801e5b:	c9                   	leave  
  801e5c:	c3                   	ret    

00801e5d <getchar>:

int
getchar(void)
{
  801e5d:	55                   	push   %ebp
  801e5e:	89 e5                	mov    %esp,%ebp
  801e60:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e63:	6a 01                	push   $0x1
  801e65:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e68:	50                   	push   %eax
  801e69:	6a 00                	push   $0x0
  801e6b:	e8 18 f6 ff ff       	call   801488 <read>
	if (r < 0)
  801e70:	83 c4 10             	add    $0x10,%esp
  801e73:	85 c0                	test   %eax,%eax
  801e75:	78 0f                	js     801e86 <getchar+0x29>
		return r;
	if (r < 1)
  801e77:	85 c0                	test   %eax,%eax
  801e79:	7e 06                	jle    801e81 <getchar+0x24>
		return -E_EOF;
	return c;
  801e7b:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e7f:	eb 05                	jmp    801e86 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e81:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e86:	c9                   	leave  
  801e87:	c3                   	ret    

00801e88 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e88:	55                   	push   %ebp
  801e89:	89 e5                	mov    %esp,%ebp
  801e8b:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e8e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e91:	50                   	push   %eax
  801e92:	ff 75 08             	pushl  0x8(%ebp)
  801e95:	e8 88 f3 ff ff       	call   801222 <fd_lookup>
  801e9a:	83 c4 10             	add    $0x10,%esp
  801e9d:	85 c0                	test   %eax,%eax
  801e9f:	78 11                	js     801eb2 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ea1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ea4:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801eaa:	39 10                	cmp    %edx,(%eax)
  801eac:	0f 94 c0             	sete   %al
  801eaf:	0f b6 c0             	movzbl %al,%eax
}
  801eb2:	c9                   	leave  
  801eb3:	c3                   	ret    

00801eb4 <opencons>:

int
opencons(void)
{
  801eb4:	55                   	push   %ebp
  801eb5:	89 e5                	mov    %esp,%ebp
  801eb7:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801eba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ebd:	50                   	push   %eax
  801ebe:	e8 10 f3 ff ff       	call   8011d3 <fd_alloc>
  801ec3:	83 c4 10             	add    $0x10,%esp
		return r;
  801ec6:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ec8:	85 c0                	test   %eax,%eax
  801eca:	78 3e                	js     801f0a <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ecc:	83 ec 04             	sub    $0x4,%esp
  801ecf:	68 07 04 00 00       	push   $0x407
  801ed4:	ff 75 f4             	pushl  -0xc(%ebp)
  801ed7:	6a 00                	push   $0x0
  801ed9:	e8 95 ee ff ff       	call   800d73 <sys_page_alloc>
  801ede:	83 c4 10             	add    $0x10,%esp
		return r;
  801ee1:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ee3:	85 c0                	test   %eax,%eax
  801ee5:	78 23                	js     801f0a <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ee7:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801eed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ef0:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ef2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ef5:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801efc:	83 ec 0c             	sub    $0xc,%esp
  801eff:	50                   	push   %eax
  801f00:	e8 a7 f2 ff ff       	call   8011ac <fd2num>
  801f05:	89 c2                	mov    %eax,%edx
  801f07:	83 c4 10             	add    $0x10,%esp
}
  801f0a:	89 d0                	mov    %edx,%eax
  801f0c:	c9                   	leave  
  801f0d:	c3                   	ret    

00801f0e <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f0e:	55                   	push   %ebp
  801f0f:	89 e5                	mov    %esp,%ebp
  801f11:	53                   	push   %ebx
  801f12:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f15:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f1c:	75 28                	jne    801f46 <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  801f1e:	e8 12 ee ff ff       	call   800d35 <sys_getenvid>
  801f23:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_U | PTE_W);
  801f25:	83 ec 04             	sub    $0x4,%esp
  801f28:	6a 06                	push   $0x6
  801f2a:	68 00 f0 bf ee       	push   $0xeebff000
  801f2f:	50                   	push   %eax
  801f30:	e8 3e ee ff ff       	call   800d73 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  801f35:	83 c4 08             	add    $0x8,%esp
  801f38:	68 53 1f 80 00       	push   $0x801f53
  801f3d:	53                   	push   %ebx
  801f3e:	e8 7b ef ff ff       	call   800ebe <sys_env_set_pgfault_upcall>
  801f43:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f46:	8b 45 08             	mov    0x8(%ebp),%eax
  801f49:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801f4e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f51:	c9                   	leave  
  801f52:	c3                   	ret    

00801f53 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f53:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f54:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f59:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f5b:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	# My method is different. Copy the values to the other stack
	# in a convinient way, and then pop everything.
	movl %esp, %ebp		# ebp refers to the exception stack
  801f5e:	89 e5                	mov    %esp,%ebp
	movl 48(%ebp), %esp 	# go to other stack
  801f60:	8b 65 30             	mov    0x30(%ebp),%esp

	pushl 40(%ebp)		# eip - ORDER SWITCHED WITH EFLAGS
  801f63:	ff 75 28             	pushl  0x28(%ebp)
	pushl 44(%ebp)      	# eflags
  801f66:	ff 75 2c             	pushl  0x2c(%ebp)
	pushl 36(%ebp)		# all the 8 remaining regs
  801f69:	ff 75 24             	pushl  0x24(%ebp)
	pushl 32(%ebp)
  801f6c:	ff 75 20             	pushl  0x20(%ebp)
	pushl 28(%ebp)
  801f6f:	ff 75 1c             	pushl  0x1c(%ebp)
	pushl 24(%ebp)
  801f72:	ff 75 18             	pushl  0x18(%ebp)
	pushl 20(%ebp)
  801f75:	ff 75 14             	pushl  0x14(%ebp)
	pushl 16(%ebp)
  801f78:	ff 75 10             	pushl  0x10(%ebp)
	pushl 12(%ebp)
  801f7b:	ff 75 0c             	pushl  0xc(%ebp)
	pushl 8(%ebp)
  801f7e:	ff 75 08             	pushl  0x8(%ebp)

	popal			# now just pop everything!
  801f81:	61                   	popa   
	popfl
  801f82:	9d                   	popf   
	ret
  801f83:	c3                   	ret    

00801f84 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f84:	55                   	push   %ebp
  801f85:	89 e5                	mov    %esp,%ebp
  801f87:	56                   	push   %esi
  801f88:	53                   	push   %ebx
  801f89:	8b 75 08             	mov    0x8(%ebp),%esi
  801f8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f8f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  801f92:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801f94:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801f99:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  801f9c:	83 ec 0c             	sub    $0xc,%esp
  801f9f:	50                   	push   %eax
  801fa0:	e8 7e ef ff ff       	call   800f23 <sys_ipc_recv>

	if (r < 0) {
  801fa5:	83 c4 10             	add    $0x10,%esp
  801fa8:	85 c0                	test   %eax,%eax
  801faa:	79 16                	jns    801fc2 <ipc_recv+0x3e>
		if (from_env_store)
  801fac:	85 f6                	test   %esi,%esi
  801fae:	74 06                	je     801fb6 <ipc_recv+0x32>
			*from_env_store = 0;
  801fb0:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  801fb6:	85 db                	test   %ebx,%ebx
  801fb8:	74 2c                	je     801fe6 <ipc_recv+0x62>
			*perm_store = 0;
  801fba:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801fc0:	eb 24                	jmp    801fe6 <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  801fc2:	85 f6                	test   %esi,%esi
  801fc4:	74 0a                	je     801fd0 <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  801fc6:	a1 04 40 80 00       	mov    0x804004,%eax
  801fcb:	8b 40 74             	mov    0x74(%eax),%eax
  801fce:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  801fd0:	85 db                	test   %ebx,%ebx
  801fd2:	74 0a                	je     801fde <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  801fd4:	a1 04 40 80 00       	mov    0x804004,%eax
  801fd9:	8b 40 78             	mov    0x78(%eax),%eax
  801fdc:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  801fde:	a1 04 40 80 00       	mov    0x804004,%eax
  801fe3:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  801fe6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fe9:	5b                   	pop    %ebx
  801fea:	5e                   	pop    %esi
  801feb:	5d                   	pop    %ebp
  801fec:	c3                   	ret    

00801fed <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fed:	55                   	push   %ebp
  801fee:	89 e5                	mov    %esp,%ebp
  801ff0:	57                   	push   %edi
  801ff1:	56                   	push   %esi
  801ff2:	53                   	push   %ebx
  801ff3:	83 ec 0c             	sub    $0xc,%esp
  801ff6:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ff9:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ffc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  801fff:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  802001:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  802006:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  802009:	ff 75 14             	pushl  0x14(%ebp)
  80200c:	53                   	push   %ebx
  80200d:	56                   	push   %esi
  80200e:	57                   	push   %edi
  80200f:	e8 ec ee ff ff       	call   800f00 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  802014:	83 c4 10             	add    $0x10,%esp
  802017:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80201a:	75 07                	jne    802023 <ipc_send+0x36>
			sys_yield();
  80201c:	e8 33 ed ff ff       	call   800d54 <sys_yield>
  802021:	eb e6                	jmp    802009 <ipc_send+0x1c>
		} else if (r < 0) {
  802023:	85 c0                	test   %eax,%eax
  802025:	79 12                	jns    802039 <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  802027:	50                   	push   %eax
  802028:	68 d0 29 80 00       	push   $0x8029d0
  80202d:	6a 51                	push   $0x51
  80202f:	68 dd 29 80 00       	push   $0x8029dd
  802034:	e8 d9 e2 ff ff       	call   800312 <_panic>
		}
	}
}
  802039:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80203c:	5b                   	pop    %ebx
  80203d:	5e                   	pop    %esi
  80203e:	5f                   	pop    %edi
  80203f:	5d                   	pop    %ebp
  802040:	c3                   	ret    

00802041 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802041:	55                   	push   %ebp
  802042:	89 e5                	mov    %esp,%ebp
  802044:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802047:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80204c:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80204f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802055:	8b 52 50             	mov    0x50(%edx),%edx
  802058:	39 ca                	cmp    %ecx,%edx
  80205a:	75 0d                	jne    802069 <ipc_find_env+0x28>
			return envs[i].env_id;
  80205c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80205f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802064:	8b 40 48             	mov    0x48(%eax),%eax
  802067:	eb 0f                	jmp    802078 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802069:	83 c0 01             	add    $0x1,%eax
  80206c:	3d 00 04 00 00       	cmp    $0x400,%eax
  802071:	75 d9                	jne    80204c <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802073:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802078:	5d                   	pop    %ebp
  802079:	c3                   	ret    

0080207a <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80207a:	55                   	push   %ebp
  80207b:	89 e5                	mov    %esp,%ebp
  80207d:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802080:	89 d0                	mov    %edx,%eax
  802082:	c1 e8 16             	shr    $0x16,%eax
  802085:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80208c:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802091:	f6 c1 01             	test   $0x1,%cl
  802094:	74 1d                	je     8020b3 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802096:	c1 ea 0c             	shr    $0xc,%edx
  802099:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8020a0:	f6 c2 01             	test   $0x1,%dl
  8020a3:	74 0e                	je     8020b3 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020a5:	c1 ea 0c             	shr    $0xc,%edx
  8020a8:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8020af:	ef 
  8020b0:	0f b7 c0             	movzwl %ax,%eax
}
  8020b3:	5d                   	pop    %ebp
  8020b4:	c3                   	ret    
  8020b5:	66 90                	xchg   %ax,%ax
  8020b7:	66 90                	xchg   %ax,%ax
  8020b9:	66 90                	xchg   %ax,%ax
  8020bb:	66 90                	xchg   %ax,%ax
  8020bd:	66 90                	xchg   %ax,%ax
  8020bf:	90                   	nop

008020c0 <__udivdi3>:
  8020c0:	55                   	push   %ebp
  8020c1:	57                   	push   %edi
  8020c2:	56                   	push   %esi
  8020c3:	53                   	push   %ebx
  8020c4:	83 ec 1c             	sub    $0x1c,%esp
  8020c7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8020cb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8020cf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8020d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020d7:	85 f6                	test   %esi,%esi
  8020d9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020dd:	89 ca                	mov    %ecx,%edx
  8020df:	89 f8                	mov    %edi,%eax
  8020e1:	75 3d                	jne    802120 <__udivdi3+0x60>
  8020e3:	39 cf                	cmp    %ecx,%edi
  8020e5:	0f 87 c5 00 00 00    	ja     8021b0 <__udivdi3+0xf0>
  8020eb:	85 ff                	test   %edi,%edi
  8020ed:	89 fd                	mov    %edi,%ebp
  8020ef:	75 0b                	jne    8020fc <__udivdi3+0x3c>
  8020f1:	b8 01 00 00 00       	mov    $0x1,%eax
  8020f6:	31 d2                	xor    %edx,%edx
  8020f8:	f7 f7                	div    %edi
  8020fa:	89 c5                	mov    %eax,%ebp
  8020fc:	89 c8                	mov    %ecx,%eax
  8020fe:	31 d2                	xor    %edx,%edx
  802100:	f7 f5                	div    %ebp
  802102:	89 c1                	mov    %eax,%ecx
  802104:	89 d8                	mov    %ebx,%eax
  802106:	89 cf                	mov    %ecx,%edi
  802108:	f7 f5                	div    %ebp
  80210a:	89 c3                	mov    %eax,%ebx
  80210c:	89 d8                	mov    %ebx,%eax
  80210e:	89 fa                	mov    %edi,%edx
  802110:	83 c4 1c             	add    $0x1c,%esp
  802113:	5b                   	pop    %ebx
  802114:	5e                   	pop    %esi
  802115:	5f                   	pop    %edi
  802116:	5d                   	pop    %ebp
  802117:	c3                   	ret    
  802118:	90                   	nop
  802119:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802120:	39 ce                	cmp    %ecx,%esi
  802122:	77 74                	ja     802198 <__udivdi3+0xd8>
  802124:	0f bd fe             	bsr    %esi,%edi
  802127:	83 f7 1f             	xor    $0x1f,%edi
  80212a:	0f 84 98 00 00 00    	je     8021c8 <__udivdi3+0x108>
  802130:	bb 20 00 00 00       	mov    $0x20,%ebx
  802135:	89 f9                	mov    %edi,%ecx
  802137:	89 c5                	mov    %eax,%ebp
  802139:	29 fb                	sub    %edi,%ebx
  80213b:	d3 e6                	shl    %cl,%esi
  80213d:	89 d9                	mov    %ebx,%ecx
  80213f:	d3 ed                	shr    %cl,%ebp
  802141:	89 f9                	mov    %edi,%ecx
  802143:	d3 e0                	shl    %cl,%eax
  802145:	09 ee                	or     %ebp,%esi
  802147:	89 d9                	mov    %ebx,%ecx
  802149:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80214d:	89 d5                	mov    %edx,%ebp
  80214f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802153:	d3 ed                	shr    %cl,%ebp
  802155:	89 f9                	mov    %edi,%ecx
  802157:	d3 e2                	shl    %cl,%edx
  802159:	89 d9                	mov    %ebx,%ecx
  80215b:	d3 e8                	shr    %cl,%eax
  80215d:	09 c2                	or     %eax,%edx
  80215f:	89 d0                	mov    %edx,%eax
  802161:	89 ea                	mov    %ebp,%edx
  802163:	f7 f6                	div    %esi
  802165:	89 d5                	mov    %edx,%ebp
  802167:	89 c3                	mov    %eax,%ebx
  802169:	f7 64 24 0c          	mull   0xc(%esp)
  80216d:	39 d5                	cmp    %edx,%ebp
  80216f:	72 10                	jb     802181 <__udivdi3+0xc1>
  802171:	8b 74 24 08          	mov    0x8(%esp),%esi
  802175:	89 f9                	mov    %edi,%ecx
  802177:	d3 e6                	shl    %cl,%esi
  802179:	39 c6                	cmp    %eax,%esi
  80217b:	73 07                	jae    802184 <__udivdi3+0xc4>
  80217d:	39 d5                	cmp    %edx,%ebp
  80217f:	75 03                	jne    802184 <__udivdi3+0xc4>
  802181:	83 eb 01             	sub    $0x1,%ebx
  802184:	31 ff                	xor    %edi,%edi
  802186:	89 d8                	mov    %ebx,%eax
  802188:	89 fa                	mov    %edi,%edx
  80218a:	83 c4 1c             	add    $0x1c,%esp
  80218d:	5b                   	pop    %ebx
  80218e:	5e                   	pop    %esi
  80218f:	5f                   	pop    %edi
  802190:	5d                   	pop    %ebp
  802191:	c3                   	ret    
  802192:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802198:	31 ff                	xor    %edi,%edi
  80219a:	31 db                	xor    %ebx,%ebx
  80219c:	89 d8                	mov    %ebx,%eax
  80219e:	89 fa                	mov    %edi,%edx
  8021a0:	83 c4 1c             	add    $0x1c,%esp
  8021a3:	5b                   	pop    %ebx
  8021a4:	5e                   	pop    %esi
  8021a5:	5f                   	pop    %edi
  8021a6:	5d                   	pop    %ebp
  8021a7:	c3                   	ret    
  8021a8:	90                   	nop
  8021a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021b0:	89 d8                	mov    %ebx,%eax
  8021b2:	f7 f7                	div    %edi
  8021b4:	31 ff                	xor    %edi,%edi
  8021b6:	89 c3                	mov    %eax,%ebx
  8021b8:	89 d8                	mov    %ebx,%eax
  8021ba:	89 fa                	mov    %edi,%edx
  8021bc:	83 c4 1c             	add    $0x1c,%esp
  8021bf:	5b                   	pop    %ebx
  8021c0:	5e                   	pop    %esi
  8021c1:	5f                   	pop    %edi
  8021c2:	5d                   	pop    %ebp
  8021c3:	c3                   	ret    
  8021c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021c8:	39 ce                	cmp    %ecx,%esi
  8021ca:	72 0c                	jb     8021d8 <__udivdi3+0x118>
  8021cc:	31 db                	xor    %ebx,%ebx
  8021ce:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8021d2:	0f 87 34 ff ff ff    	ja     80210c <__udivdi3+0x4c>
  8021d8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8021dd:	e9 2a ff ff ff       	jmp    80210c <__udivdi3+0x4c>
  8021e2:	66 90                	xchg   %ax,%ax
  8021e4:	66 90                	xchg   %ax,%ax
  8021e6:	66 90                	xchg   %ax,%ax
  8021e8:	66 90                	xchg   %ax,%ax
  8021ea:	66 90                	xchg   %ax,%ax
  8021ec:	66 90                	xchg   %ax,%ax
  8021ee:	66 90                	xchg   %ax,%ax

008021f0 <__umoddi3>:
  8021f0:	55                   	push   %ebp
  8021f1:	57                   	push   %edi
  8021f2:	56                   	push   %esi
  8021f3:	53                   	push   %ebx
  8021f4:	83 ec 1c             	sub    $0x1c,%esp
  8021f7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021fb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8021ff:	8b 74 24 34          	mov    0x34(%esp),%esi
  802203:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802207:	85 d2                	test   %edx,%edx
  802209:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80220d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802211:	89 f3                	mov    %esi,%ebx
  802213:	89 3c 24             	mov    %edi,(%esp)
  802216:	89 74 24 04          	mov    %esi,0x4(%esp)
  80221a:	75 1c                	jne    802238 <__umoddi3+0x48>
  80221c:	39 f7                	cmp    %esi,%edi
  80221e:	76 50                	jbe    802270 <__umoddi3+0x80>
  802220:	89 c8                	mov    %ecx,%eax
  802222:	89 f2                	mov    %esi,%edx
  802224:	f7 f7                	div    %edi
  802226:	89 d0                	mov    %edx,%eax
  802228:	31 d2                	xor    %edx,%edx
  80222a:	83 c4 1c             	add    $0x1c,%esp
  80222d:	5b                   	pop    %ebx
  80222e:	5e                   	pop    %esi
  80222f:	5f                   	pop    %edi
  802230:	5d                   	pop    %ebp
  802231:	c3                   	ret    
  802232:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802238:	39 f2                	cmp    %esi,%edx
  80223a:	89 d0                	mov    %edx,%eax
  80223c:	77 52                	ja     802290 <__umoddi3+0xa0>
  80223e:	0f bd ea             	bsr    %edx,%ebp
  802241:	83 f5 1f             	xor    $0x1f,%ebp
  802244:	75 5a                	jne    8022a0 <__umoddi3+0xb0>
  802246:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80224a:	0f 82 e0 00 00 00    	jb     802330 <__umoddi3+0x140>
  802250:	39 0c 24             	cmp    %ecx,(%esp)
  802253:	0f 86 d7 00 00 00    	jbe    802330 <__umoddi3+0x140>
  802259:	8b 44 24 08          	mov    0x8(%esp),%eax
  80225d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802261:	83 c4 1c             	add    $0x1c,%esp
  802264:	5b                   	pop    %ebx
  802265:	5e                   	pop    %esi
  802266:	5f                   	pop    %edi
  802267:	5d                   	pop    %ebp
  802268:	c3                   	ret    
  802269:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802270:	85 ff                	test   %edi,%edi
  802272:	89 fd                	mov    %edi,%ebp
  802274:	75 0b                	jne    802281 <__umoddi3+0x91>
  802276:	b8 01 00 00 00       	mov    $0x1,%eax
  80227b:	31 d2                	xor    %edx,%edx
  80227d:	f7 f7                	div    %edi
  80227f:	89 c5                	mov    %eax,%ebp
  802281:	89 f0                	mov    %esi,%eax
  802283:	31 d2                	xor    %edx,%edx
  802285:	f7 f5                	div    %ebp
  802287:	89 c8                	mov    %ecx,%eax
  802289:	f7 f5                	div    %ebp
  80228b:	89 d0                	mov    %edx,%eax
  80228d:	eb 99                	jmp    802228 <__umoddi3+0x38>
  80228f:	90                   	nop
  802290:	89 c8                	mov    %ecx,%eax
  802292:	89 f2                	mov    %esi,%edx
  802294:	83 c4 1c             	add    $0x1c,%esp
  802297:	5b                   	pop    %ebx
  802298:	5e                   	pop    %esi
  802299:	5f                   	pop    %edi
  80229a:	5d                   	pop    %ebp
  80229b:	c3                   	ret    
  80229c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022a0:	8b 34 24             	mov    (%esp),%esi
  8022a3:	bf 20 00 00 00       	mov    $0x20,%edi
  8022a8:	89 e9                	mov    %ebp,%ecx
  8022aa:	29 ef                	sub    %ebp,%edi
  8022ac:	d3 e0                	shl    %cl,%eax
  8022ae:	89 f9                	mov    %edi,%ecx
  8022b0:	89 f2                	mov    %esi,%edx
  8022b2:	d3 ea                	shr    %cl,%edx
  8022b4:	89 e9                	mov    %ebp,%ecx
  8022b6:	09 c2                	or     %eax,%edx
  8022b8:	89 d8                	mov    %ebx,%eax
  8022ba:	89 14 24             	mov    %edx,(%esp)
  8022bd:	89 f2                	mov    %esi,%edx
  8022bf:	d3 e2                	shl    %cl,%edx
  8022c1:	89 f9                	mov    %edi,%ecx
  8022c3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8022c7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8022cb:	d3 e8                	shr    %cl,%eax
  8022cd:	89 e9                	mov    %ebp,%ecx
  8022cf:	89 c6                	mov    %eax,%esi
  8022d1:	d3 e3                	shl    %cl,%ebx
  8022d3:	89 f9                	mov    %edi,%ecx
  8022d5:	89 d0                	mov    %edx,%eax
  8022d7:	d3 e8                	shr    %cl,%eax
  8022d9:	89 e9                	mov    %ebp,%ecx
  8022db:	09 d8                	or     %ebx,%eax
  8022dd:	89 d3                	mov    %edx,%ebx
  8022df:	89 f2                	mov    %esi,%edx
  8022e1:	f7 34 24             	divl   (%esp)
  8022e4:	89 d6                	mov    %edx,%esi
  8022e6:	d3 e3                	shl    %cl,%ebx
  8022e8:	f7 64 24 04          	mull   0x4(%esp)
  8022ec:	39 d6                	cmp    %edx,%esi
  8022ee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022f2:	89 d1                	mov    %edx,%ecx
  8022f4:	89 c3                	mov    %eax,%ebx
  8022f6:	72 08                	jb     802300 <__umoddi3+0x110>
  8022f8:	75 11                	jne    80230b <__umoddi3+0x11b>
  8022fa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8022fe:	73 0b                	jae    80230b <__umoddi3+0x11b>
  802300:	2b 44 24 04          	sub    0x4(%esp),%eax
  802304:	1b 14 24             	sbb    (%esp),%edx
  802307:	89 d1                	mov    %edx,%ecx
  802309:	89 c3                	mov    %eax,%ebx
  80230b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80230f:	29 da                	sub    %ebx,%edx
  802311:	19 ce                	sbb    %ecx,%esi
  802313:	89 f9                	mov    %edi,%ecx
  802315:	89 f0                	mov    %esi,%eax
  802317:	d3 e0                	shl    %cl,%eax
  802319:	89 e9                	mov    %ebp,%ecx
  80231b:	d3 ea                	shr    %cl,%edx
  80231d:	89 e9                	mov    %ebp,%ecx
  80231f:	d3 ee                	shr    %cl,%esi
  802321:	09 d0                	or     %edx,%eax
  802323:	89 f2                	mov    %esi,%edx
  802325:	83 c4 1c             	add    $0x1c,%esp
  802328:	5b                   	pop    %ebx
  802329:	5e                   	pop    %esi
  80232a:	5f                   	pop    %edi
  80232b:	5d                   	pop    %ebp
  80232c:	c3                   	ret    
  80232d:	8d 76 00             	lea    0x0(%esi),%esi
  802330:	29 f9                	sub    %edi,%ecx
  802332:	19 d6                	sbb    %edx,%esi
  802334:	89 74 24 04          	mov    %esi,0x4(%esp)
  802338:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80233c:	e9 18 ff ff ff       	jmp    802259 <__umoddi3+0x69>
