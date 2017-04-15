
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
  80003b:	c7 05 04 30 80 00 c0 	movl   $0x8023c0,0x803004
  800042:	23 80 00 

	if ((i = pipe(p)) < 0)
  800045:	8d 45 8c             	lea    -0x74(%ebp),%eax
  800048:	50                   	push   %eax
  800049:	e8 c9 1b 00 00       	call   801c17 <pipe>
  80004e:	89 c6                	mov    %eax,%esi
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	85 c0                	test   %eax,%eax
  800055:	79 12                	jns    800069 <umain+0x36>
		panic("pipe: %e", i);
  800057:	50                   	push   %eax
  800058:	68 cc 23 80 00       	push   $0x8023cc
  80005d:	6a 0e                	push   $0xe
  80005f:	68 d5 23 80 00       	push   $0x8023d5
  800064:	e8 a9 02 00 00       	call   800312 <_panic>

	if ((pid = fork()) < 0)
  800069:	e8 aa 10 00 00       	call   801118 <fork>
  80006e:	89 c3                	mov    %eax,%ebx
  800070:	85 c0                	test   %eax,%eax
  800072:	79 12                	jns    800086 <umain+0x53>
		panic("fork: %e", i);
  800074:	56                   	push   %esi
  800075:	68 b3 28 80 00       	push   $0x8028b3
  80007a:	6a 11                	push   $0x11
  80007c:	68 d5 23 80 00       	push   $0x8023d5
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
  80009d:	68 e5 23 80 00       	push   $0x8023e5
  8000a2:	e8 44 03 00 00       	call   8003eb <cprintf>
		close(p[1]);
  8000a7:	83 c4 04             	add    $0x4,%esp
  8000aa:	ff 75 90             	pushl  -0x70(%ebp)
  8000ad:	e8 fb 12 00 00       	call   8013ad <close>
		cprintf("[%08x] pipereadeof readn %d\n", thisenv->env_id, p[0]);
  8000b2:	a1 04 40 80 00       	mov    0x804004,%eax
  8000b7:	8b 40 48             	mov    0x48(%eax),%eax
  8000ba:	83 c4 0c             	add    $0xc,%esp
  8000bd:	ff 75 8c             	pushl  -0x74(%ebp)
  8000c0:	50                   	push   %eax
  8000c1:	68 02 24 80 00       	push   $0x802402
  8000c6:	e8 20 03 00 00       	call   8003eb <cprintf>
		i = readn(p[0], buf, sizeof buf-1);
  8000cb:	83 c4 0c             	add    $0xc,%esp
  8000ce:	6a 63                	push   $0x63
  8000d0:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8000d3:	50                   	push   %eax
  8000d4:	ff 75 8c             	pushl  -0x74(%ebp)
  8000d7:	e8 9e 14 00 00       	call   80157a <readn>
  8000dc:	89 c6                	mov    %eax,%esi
		if (i < 0)
  8000de:	83 c4 10             	add    $0x10,%esp
  8000e1:	85 c0                	test   %eax,%eax
  8000e3:	79 12                	jns    8000f7 <umain+0xc4>
			panic("read: %e", i);
  8000e5:	50                   	push   %eax
  8000e6:	68 1f 24 80 00       	push   $0x80241f
  8000eb:	6a 19                	push   $0x19
  8000ed:	68 d5 23 80 00       	push   $0x8023d5
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
  800118:	68 28 24 80 00       	push   $0x802428
  80011d:	e8 c9 02 00 00       	call   8003eb <cprintf>
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	eb 15                	jmp    80013c <umain+0x109>
		else
			cprintf("\ngot %d bytes: %s\n", i, buf);
  800127:	83 ec 04             	sub    $0x4,%esp
  80012a:	8d 45 94             	lea    -0x6c(%ebp),%eax
  80012d:	50                   	push   %eax
  80012e:	56                   	push   %esi
  80012f:	68 44 24 80 00       	push   $0x802444
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
  800155:	68 e5 23 80 00       	push   $0x8023e5
  80015a:	e8 8c 02 00 00       	call   8003eb <cprintf>
		close(p[0]);
  80015f:	83 c4 04             	add    $0x4,%esp
  800162:	ff 75 8c             	pushl  -0x74(%ebp)
  800165:	e8 43 12 00 00       	call   8013ad <close>
		cprintf("[%08x] pipereadeof write %d\n", thisenv->env_id, p[1]);
  80016a:	a1 04 40 80 00       	mov    0x804004,%eax
  80016f:	8b 40 48             	mov    0x48(%eax),%eax
  800172:	83 c4 0c             	add    $0xc,%esp
  800175:	ff 75 90             	pushl  -0x70(%ebp)
  800178:	50                   	push   %eax
  800179:	68 57 24 80 00       	push   $0x802457
  80017e:	e8 68 02 00 00       	call   8003eb <cprintf>
		if ((i = write(p[1], msg, strlen(msg))) != strlen(msg))
  800183:	83 c4 04             	add    $0x4,%esp
  800186:	ff 35 00 30 80 00    	pushl  0x803000
  80018c:	e8 a6 07 00 00       	call   800937 <strlen>
  800191:	83 c4 0c             	add    $0xc,%esp
  800194:	50                   	push   %eax
  800195:	ff 35 00 30 80 00    	pushl  0x803000
  80019b:	ff 75 90             	pushl  -0x70(%ebp)
  80019e:	e8 20 14 00 00       	call   8015c3 <write>
  8001a3:	89 c6                	mov    %eax,%esi
  8001a5:	83 c4 04             	add    $0x4,%esp
  8001a8:	ff 35 00 30 80 00    	pushl  0x803000
  8001ae:	e8 84 07 00 00       	call   800937 <strlen>
  8001b3:	83 c4 10             	add    $0x10,%esp
  8001b6:	39 c6                	cmp    %eax,%esi
  8001b8:	74 12                	je     8001cc <umain+0x199>
			panic("write: %e", i);
  8001ba:	56                   	push   %esi
  8001bb:	68 74 24 80 00       	push   $0x802474
  8001c0:	6a 25                	push   $0x25
  8001c2:	68 d5 23 80 00       	push   $0x8023d5
  8001c7:	e8 46 01 00 00       	call   800312 <_panic>
		close(p[1]);
  8001cc:	83 ec 0c             	sub    $0xc,%esp
  8001cf:	ff 75 90             	pushl  -0x70(%ebp)
  8001d2:	e8 d6 11 00 00       	call   8013ad <close>
  8001d7:	83 c4 10             	add    $0x10,%esp
	}
	wait(pid);
  8001da:	83 ec 0c             	sub    $0xc,%esp
  8001dd:	53                   	push   %ebx
  8001de:	e8 ba 1b 00 00       	call   801d9d <wait>

	binaryname = "pipewriteeof";
  8001e3:	c7 05 04 30 80 00 7e 	movl   $0x80247e,0x803004
  8001ea:	24 80 00 
	if ((i = pipe(p)) < 0)
  8001ed:	8d 45 8c             	lea    -0x74(%ebp),%eax
  8001f0:	89 04 24             	mov    %eax,(%esp)
  8001f3:	e8 1f 1a 00 00       	call   801c17 <pipe>
  8001f8:	89 c6                	mov    %eax,%esi
  8001fa:	83 c4 10             	add    $0x10,%esp
  8001fd:	85 c0                	test   %eax,%eax
  8001ff:	79 12                	jns    800213 <umain+0x1e0>
		panic("pipe: %e", i);
  800201:	50                   	push   %eax
  800202:	68 cc 23 80 00       	push   $0x8023cc
  800207:	6a 2c                	push   $0x2c
  800209:	68 d5 23 80 00       	push   $0x8023d5
  80020e:	e8 ff 00 00 00       	call   800312 <_panic>

	if ((pid = fork()) < 0)
  800213:	e8 00 0f 00 00       	call   801118 <fork>
  800218:	89 c3                	mov    %eax,%ebx
  80021a:	85 c0                	test   %eax,%eax
  80021c:	79 12                	jns    800230 <umain+0x1fd>
		panic("fork: %e", i);
  80021e:	56                   	push   %esi
  80021f:	68 b3 28 80 00       	push   $0x8028b3
  800224:	6a 2f                	push   $0x2f
  800226:	68 d5 23 80 00       	push   $0x8023d5
  80022b:	e8 e2 00 00 00       	call   800312 <_panic>

	if (pid == 0) {
  800230:	85 c0                	test   %eax,%eax
  800232:	75 4a                	jne    80027e <umain+0x24b>
		close(p[0]);
  800234:	83 ec 0c             	sub    $0xc,%esp
  800237:	ff 75 8c             	pushl  -0x74(%ebp)
  80023a:	e8 6e 11 00 00       	call   8013ad <close>
  80023f:	83 c4 10             	add    $0x10,%esp
		while (1) {
			cprintf(".");
  800242:	83 ec 0c             	sub    $0xc,%esp
  800245:	68 8b 24 80 00       	push   $0x80248b
  80024a:	e8 9c 01 00 00       	call   8003eb <cprintf>
			if (write(p[1], "x", 1) != 1)
  80024f:	83 c4 0c             	add    $0xc,%esp
  800252:	6a 01                	push   $0x1
  800254:	68 8d 24 80 00       	push   $0x80248d
  800259:	ff 75 90             	pushl  -0x70(%ebp)
  80025c:	e8 62 13 00 00       	call   8015c3 <write>
  800261:	83 c4 10             	add    $0x10,%esp
  800264:	83 f8 01             	cmp    $0x1,%eax
  800267:	74 d9                	je     800242 <umain+0x20f>
				break;
		}
		cprintf("\npipe write closed properly\n");
  800269:	83 ec 0c             	sub    $0xc,%esp
  80026c:	68 8f 24 80 00       	push   $0x80248f
  800271:	e8 75 01 00 00       	call   8003eb <cprintf>
		exit();
  800276:	e8 7d 00 00 00       	call   8002f8 <exit>
  80027b:	83 c4 10             	add    $0x10,%esp
	}
	close(p[0]);
  80027e:	83 ec 0c             	sub    $0xc,%esp
  800281:	ff 75 8c             	pushl  -0x74(%ebp)
  800284:	e8 24 11 00 00       	call   8013ad <close>
	close(p[1]);
  800289:	83 c4 04             	add    $0x4,%esp
  80028c:	ff 75 90             	pushl  -0x70(%ebp)
  80028f:	e8 19 11 00 00       	call   8013ad <close>
	wait(pid);
  800294:	89 1c 24             	mov    %ebx,(%esp)
  800297:	e8 01 1b 00 00       	call   801d9d <wait>

	cprintf("pipe tests passed\n");
  80029c:	c7 04 24 ac 24 80 00 	movl   $0x8024ac,(%esp)
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
  8002fe:	e8 d5 10 00 00       	call   8013d8 <close_all>
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
  800330:	68 10 25 80 00       	push   $0x802510
  800335:	e8 b1 00 00 00       	call   8003eb <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80033a:	83 c4 18             	add    $0x18,%esp
  80033d:	53                   	push   %ebx
  80033e:	ff 75 10             	pushl  0x10(%ebp)
  800341:	e8 54 00 00 00       	call   80039a <vcprintf>
	cprintf("\n");
  800346:	c7 04 24 00 24 80 00 	movl   $0x802400,(%esp)
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
  80044e:	e8 cd 1c 00 00       	call   802120 <__udivdi3>
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
  800491:	e8 ba 1d 00 00       	call   802250 <__umoddi3>
  800496:	83 c4 14             	add    $0x14,%esp
  800499:	0f be 80 33 25 80 00 	movsbl 0x802533(%eax),%eax
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
  800595:	ff 24 85 80 26 80 00 	jmp    *0x802680(,%eax,4)
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
  800659:	8b 14 85 e0 27 80 00 	mov    0x8027e0(,%eax,4),%edx
  800660:	85 d2                	test   %edx,%edx
  800662:	75 18                	jne    80067c <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800664:	50                   	push   %eax
  800665:	68 4b 25 80 00       	push   $0x80254b
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
  80067d:	68 9a 29 80 00       	push   $0x80299a
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
  8006a1:	b8 44 25 80 00       	mov    $0x802544,%eax
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
  800d1c:	68 3f 28 80 00       	push   $0x80283f
  800d21:	6a 23                	push   $0x23
  800d23:	68 5c 28 80 00       	push   $0x80285c
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
  800d9d:	68 3f 28 80 00       	push   $0x80283f
  800da2:	6a 23                	push   $0x23
  800da4:	68 5c 28 80 00       	push   $0x80285c
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
  800ddf:	68 3f 28 80 00       	push   $0x80283f
  800de4:	6a 23                	push   $0x23
  800de6:	68 5c 28 80 00       	push   $0x80285c
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
  800e21:	68 3f 28 80 00       	push   $0x80283f
  800e26:	6a 23                	push   $0x23
  800e28:	68 5c 28 80 00       	push   $0x80285c
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
  800e63:	68 3f 28 80 00       	push   $0x80283f
  800e68:	6a 23                	push   $0x23
  800e6a:	68 5c 28 80 00       	push   $0x80285c
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
  800ea5:	68 3f 28 80 00       	push   $0x80283f
  800eaa:	6a 23                	push   $0x23
  800eac:	68 5c 28 80 00       	push   $0x80285c
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
  800ee7:	68 3f 28 80 00       	push   $0x80283f
  800eec:	6a 23                	push   $0x23
  800eee:	68 5c 28 80 00       	push   $0x80285c
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
  800f4b:	68 3f 28 80 00       	push   $0x80283f
  800f50:	6a 23                	push   $0x23
  800f52:	68 5c 28 80 00       	push   $0x80285c
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
  800f67:	53                   	push   %ebx
  800f68:	83 ec 04             	sub    $0x4,%esp
	int r;
	void * address = (void *)(pn*PGSIZE);
  800f6b:	89 d3                	mov    %edx,%ebx
  800f6d:	c1 e3 0c             	shl    $0xc,%ebx
	
	if((uvpt[pn] & PTE_SHARE))
  800f70:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800f77:	f6 c5 04             	test   $0x4,%ch
  800f7a:	74 38                	je     800fb4 <duppage+0x50>
	{
		if ((r = sys_page_map(0, address, envid, address, (uvpt[pn] | PTE_SYSCALL))) < 0)
  800f7c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f83:	83 ec 0c             	sub    $0xc,%esp
  800f86:	81 ca 07 0e 00 00    	or     $0xe07,%edx
  800f8c:	52                   	push   %edx
  800f8d:	53                   	push   %ebx
  800f8e:	50                   	push   %eax
  800f8f:	53                   	push   %ebx
  800f90:	6a 00                	push   $0x0
  800f92:	e8 1f fe ff ff       	call   800db6 <sys_page_map>
  800f97:	83 c4 20             	add    $0x20,%esp
  800f9a:	85 c0                	test   %eax,%eax
  800f9c:	0f 89 b8 00 00 00    	jns    80105a <duppage+0xf6>
			panic("sys_page_map: %e", r);
  800fa2:	50                   	push   %eax
  800fa3:	68 6a 28 80 00       	push   $0x80286a
  800fa8:	6a 4e                	push   $0x4e
  800faa:	68 7b 28 80 00       	push   $0x80287b
  800faf:	e8 5e f3 ff ff       	call   800312 <_panic>
	}
	else if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW))
  800fb4:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800fbb:	f6 c1 02             	test   $0x2,%cl
  800fbe:	75 0c                	jne    800fcc <duppage+0x68>
  800fc0:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800fc7:	f6 c5 08             	test   $0x8,%ch
  800fca:	74 57                	je     801023 <duppage+0xbf>
	{
		int perm = 0;
		perm |= PTE_P|PTE_U|PTE_COW;
	
		if ((r = sys_page_map(0, address, envid, address, perm)) < 0)
  800fcc:	83 ec 0c             	sub    $0xc,%esp
  800fcf:	68 05 08 00 00       	push   $0x805
  800fd4:	53                   	push   %ebx
  800fd5:	50                   	push   %eax
  800fd6:	53                   	push   %ebx
  800fd7:	6a 00                	push   $0x0
  800fd9:	e8 d8 fd ff ff       	call   800db6 <sys_page_map>
  800fde:	83 c4 20             	add    $0x20,%esp
  800fe1:	85 c0                	test   %eax,%eax
  800fe3:	79 12                	jns    800ff7 <duppage+0x93>
			panic("sys_page_map: %e", r);
  800fe5:	50                   	push   %eax
  800fe6:	68 6a 28 80 00       	push   $0x80286a
  800feb:	6a 56                	push   $0x56
  800fed:	68 7b 28 80 00       	push   $0x80287b
  800ff2:	e8 1b f3 ff ff       	call   800312 <_panic>
		if ((r = sys_page_map(0, address, 0, address, perm)) < 0)
  800ff7:	83 ec 0c             	sub    $0xc,%esp
  800ffa:	68 05 08 00 00       	push   $0x805
  800fff:	53                   	push   %ebx
  801000:	6a 00                	push   $0x0
  801002:	53                   	push   %ebx
  801003:	6a 00                	push   $0x0
  801005:	e8 ac fd ff ff       	call   800db6 <sys_page_map>
  80100a:	83 c4 20             	add    $0x20,%esp
  80100d:	85 c0                	test   %eax,%eax
  80100f:	79 49                	jns    80105a <duppage+0xf6>
			panic("sys_page_map: %e", r);
  801011:	50                   	push   %eax
  801012:	68 6a 28 80 00       	push   $0x80286a
  801017:	6a 58                	push   $0x58
  801019:	68 7b 28 80 00       	push   $0x80287b
  80101e:	e8 ef f2 ff ff       	call   800312 <_panic>
	}
	else if((uvpt[pn] & ~PTE_U) == 0)
  801023:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80102a:	f7 c2 fb ff ff ff    	test   $0xfffffffb,%edx
  801030:	75 28                	jne    80105a <duppage+0xf6>
	{
		//cprintf("im here");
		if ((r = sys_page_map(0, address, envid, address, PTE_P|PTE_U)) < 0)
  801032:	83 ec 0c             	sub    $0xc,%esp
  801035:	6a 05                	push   $0x5
  801037:	53                   	push   %ebx
  801038:	50                   	push   %eax
  801039:	53                   	push   %ebx
  80103a:	6a 00                	push   $0x0
  80103c:	e8 75 fd ff ff       	call   800db6 <sys_page_map>
  801041:	83 c4 20             	add    $0x20,%esp
  801044:	85 c0                	test   %eax,%eax
  801046:	79 12                	jns    80105a <duppage+0xf6>
			panic("sys_page_map: %e", r);	
  801048:	50                   	push   %eax
  801049:	68 6a 28 80 00       	push   $0x80286a
  80104e:	6a 5e                	push   $0x5e
  801050:	68 7b 28 80 00       	push   $0x80287b
  801055:	e8 b8 f2 ff ff       	call   800312 <_panic>
	}
	return 0;
}
  80105a:	b8 00 00 00 00       	mov    $0x0,%eax
  80105f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801062:	c9                   	leave  
  801063:	c3                   	ret    

00801064 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801064:	55                   	push   %ebp
  801065:	89 e5                	mov    %esp,%ebp
  801067:	53                   	push   %ebx
  801068:	83 ec 08             	sub    $0x8,%esp
	void *addr = (void *) utf->utf_fault_va;
  80106b:	8b 45 08             	mov    0x8(%ebp),%eax
  80106e:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	unsigned pn = ((uint32_t)addr)/PGSIZE;
  801070:	89 d8                	mov    %ebx,%eax
  801072:	c1 e8 0c             	shr    $0xc,%eax
	pte_t pte = uvpt[pn];
  801075:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// Allocate a new page, mapped at temp location
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  80107c:	6a 07                	push   $0x7
  80107e:	68 00 f0 7f 00       	push   $0x7ff000
  801083:	6a 00                	push   $0x0
  801085:	e8 e9 fc ff ff       	call   800d73 <sys_page_alloc>
  80108a:	83 c4 10             	add    $0x10,%esp
  80108d:	85 c0                	test   %eax,%eax
  80108f:	79 12                	jns    8010a3 <pgfault+0x3f>
		panic("sys_page_alloc: %e", r);
  801091:	50                   	push   %eax
  801092:	68 86 28 80 00       	push   $0x802886
  801097:	6a 2b                	push   $0x2b
  801099:	68 7b 28 80 00       	push   $0x80287b
  80109e:	e8 6f f2 ff ff       	call   800312 <_panic>

	// Copy the data from the old page to this new page
	void *addr_pgstart = (void *) ROUNDDOWN(addr, PGSIZE);
  8010a3:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr_pgstart, PGSIZE);
  8010a9:	83 ec 04             	sub    $0x4,%esp
  8010ac:	68 00 10 00 00       	push   $0x1000
  8010b1:	53                   	push   %ebx
  8010b2:	68 00 f0 7f 00       	push   $0x7ff000
  8010b7:	e8 46 fa ff ff       	call   800b02 <memmove>

	// Move the new page to the old page's address
	if ((r = sys_page_map(0, PFTEMP, 0, addr_pgstart, PTE_P|PTE_U|PTE_W)) < 0)
  8010bc:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  8010c3:	53                   	push   %ebx
  8010c4:	6a 00                	push   $0x0
  8010c6:	68 00 f0 7f 00       	push   $0x7ff000
  8010cb:	6a 00                	push   $0x0
  8010cd:	e8 e4 fc ff ff       	call   800db6 <sys_page_map>
  8010d2:	83 c4 20             	add    $0x20,%esp
  8010d5:	85 c0                	test   %eax,%eax
  8010d7:	79 12                	jns    8010eb <pgfault+0x87>
		panic("sys_page_map: %e", r);
  8010d9:	50                   	push   %eax
  8010da:	68 6a 28 80 00       	push   $0x80286a
  8010df:	6a 33                	push   $0x33
  8010e1:	68 7b 28 80 00       	push   $0x80287b
  8010e6:	e8 27 f2 ff ff       	call   800312 <_panic>

	// Unmap the temp location
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  8010eb:	83 ec 08             	sub    $0x8,%esp
  8010ee:	68 00 f0 7f 00       	push   $0x7ff000
  8010f3:	6a 00                	push   $0x0
  8010f5:	e8 fe fc ff ff       	call   800df8 <sys_page_unmap>
  8010fa:	83 c4 10             	add    $0x10,%esp
  8010fd:	85 c0                	test   %eax,%eax
  8010ff:	79 12                	jns    801113 <pgfault+0xaf>
		panic("sys_page_unmap: %e", r);
  801101:	50                   	push   %eax
  801102:	68 99 28 80 00       	push   $0x802899
  801107:	6a 37                	push   $0x37
  801109:	68 7b 28 80 00       	push   $0x80287b
  80110e:	e8 ff f1 ff ff       	call   800312 <_panic>
}
  801113:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801116:	c9                   	leave  
  801117:	c3                   	ret    

00801118 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801118:	55                   	push   %ebp
  801119:	89 e5                	mov    %esp,%ebp
  80111b:	56                   	push   %esi
  80111c:	53                   	push   %ebx
  80111d:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
	// Set up page fault handler
	set_pgfault_handler(&pgfault);
  801120:	68 64 10 80 00       	push   $0x801064
  801125:	e8 45 0e 00 00       	call   801f6f <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  80112a:	b8 07 00 00 00       	mov    $0x7,%eax
  80112f:	cd 30                	int    $0x30

	// Create child
	envid_t envid = sys_exofork();
  801131:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (envid < 0) {
  801134:	83 c4 10             	add    $0x10,%esp
  801137:	85 c0                	test   %eax,%eax
  801139:	79 12                	jns    80114d <fork+0x35>
		panic("sys_exofork: %e", envid);
  80113b:	50                   	push   %eax
  80113c:	68 ac 28 80 00       	push   $0x8028ac
  801141:	6a 7c                	push   $0x7c
  801143:	68 7b 28 80 00       	push   $0x80287b
  801148:	e8 c5 f1 ff ff       	call   800312 <_panic>
		return envid;
	}
	if (envid == 0) {
  80114d:	85 c0                	test   %eax,%eax
  80114f:	75 1e                	jne    80116f <fork+0x57>
		// We are the child.
		thisenv = &envs[ENVX(sys_getenvid())]; // Fix thisenv
  801151:	e8 df fb ff ff       	call   800d35 <sys_getenvid>
  801156:	25 ff 03 00 00       	and    $0x3ff,%eax
  80115b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80115e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801163:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  801168:	b8 00 00 00 00       	mov    $0x0,%eax
  80116d:	eb 7d                	jmp    8011ec <fork+0xd4>

	// Set page fault handler on the child.
	// The parent needs to do it, else the child wouldn't be able to handle
	// the fault when trying to access it's stack (which happens as soon it starts)
	extern void _pgfault_upcall(void);
	sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);
  80116f:	83 ec 04             	sub    $0x4,%esp
  801172:	6a 07                	push   $0x7
  801174:	68 00 f0 bf ee       	push   $0xeebff000
  801179:	50                   	push   %eax
  80117a:	e8 f4 fb ff ff       	call   800d73 <sys_page_alloc>
	sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  80117f:	83 c4 08             	add    $0x8,%esp
  801182:	68 b4 1f 80 00       	push   $0x801fb4
  801187:	ff 75 f4             	pushl  -0xc(%ebp)
  80118a:	e8 2f fd ff ff       	call   800ebe <sys_env_set_pgfault_upcall>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  80118f:	be 04 60 80 00       	mov    $0x806004,%esi
  801194:	c1 ee 0c             	shr    $0xc,%esi
  801197:	83 c4 10             	add    $0x10,%esp
  80119a:	bb 00 08 00 00       	mov    $0x800,%ebx
  80119f:	eb 0d                	jmp    8011ae <fork+0x96>
		duppage(envid, pn);
  8011a1:	89 da                	mov    %ebx,%edx
  8011a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011a6:	e8 b9 fd ff ff       	call   800f64 <duppage>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  8011ab:	83 c3 01             	add    $0x1,%ebx
  8011ae:	39 f3                	cmp    %esi,%ebx
  8011b0:	76 ef                	jbe    8011a1 <fork+0x89>
	}

	// Also copy the stack we are currently running on
	// I think it should loop from ustacktop to this page, since the stack
	// can have more than 1 page
	duppage(envid, ((uint32_t) &envid)/PGSIZE);
  8011b2:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8011b5:	c1 ea 0c             	shr    $0xc,%edx
  8011b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011bb:	e8 a4 fd ff ff       	call   800f64 <duppage>

	// Start the child environmnet running
	int r;
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  8011c0:	83 ec 08             	sub    $0x8,%esp
  8011c3:	6a 02                	push   $0x2
  8011c5:	ff 75 f4             	pushl  -0xc(%ebp)
  8011c8:	e8 6d fc ff ff       	call   800e3a <sys_env_set_status>
  8011cd:	83 c4 10             	add    $0x10,%esp
  8011d0:	85 c0                	test   %eax,%eax
  8011d2:	79 15                	jns    8011e9 <fork+0xd1>
		panic("sys_env_set_status: %e", r);
  8011d4:	50                   	push   %eax
  8011d5:	68 bc 28 80 00       	push   $0x8028bc
  8011da:	68 9c 00 00 00       	push   $0x9c
  8011df:	68 7b 28 80 00       	push   $0x80287b
  8011e4:	e8 29 f1 ff ff       	call   800312 <_panic>
		return r;
	}

	return envid;
  8011e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8011ec:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011ef:	5b                   	pop    %ebx
  8011f0:	5e                   	pop    %esi
  8011f1:	5d                   	pop    %ebp
  8011f2:	c3                   	ret    

008011f3 <sfork>:

// Challenge!
int
sfork(void)
{
  8011f3:	55                   	push   %ebp
  8011f4:	89 e5                	mov    %esp,%ebp
  8011f6:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8011f9:	68 d3 28 80 00       	push   $0x8028d3
  8011fe:	68 a7 00 00 00       	push   $0xa7
  801203:	68 7b 28 80 00       	push   $0x80287b
  801208:	e8 05 f1 ff ff       	call   800312 <_panic>

0080120d <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80120d:	55                   	push   %ebp
  80120e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801210:	8b 45 08             	mov    0x8(%ebp),%eax
  801213:	05 00 00 00 30       	add    $0x30000000,%eax
  801218:	c1 e8 0c             	shr    $0xc,%eax
}
  80121b:	5d                   	pop    %ebp
  80121c:	c3                   	ret    

0080121d <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80121d:	55                   	push   %ebp
  80121e:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801220:	8b 45 08             	mov    0x8(%ebp),%eax
  801223:	05 00 00 00 30       	add    $0x30000000,%eax
  801228:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80122d:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801232:	5d                   	pop    %ebp
  801233:	c3                   	ret    

00801234 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801234:	55                   	push   %ebp
  801235:	89 e5                	mov    %esp,%ebp
  801237:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80123a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80123f:	89 c2                	mov    %eax,%edx
  801241:	c1 ea 16             	shr    $0x16,%edx
  801244:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80124b:	f6 c2 01             	test   $0x1,%dl
  80124e:	74 11                	je     801261 <fd_alloc+0x2d>
  801250:	89 c2                	mov    %eax,%edx
  801252:	c1 ea 0c             	shr    $0xc,%edx
  801255:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80125c:	f6 c2 01             	test   $0x1,%dl
  80125f:	75 09                	jne    80126a <fd_alloc+0x36>
			*fd_store = fd;
  801261:	89 01                	mov    %eax,(%ecx)
			return 0;
  801263:	b8 00 00 00 00       	mov    $0x0,%eax
  801268:	eb 17                	jmp    801281 <fd_alloc+0x4d>
  80126a:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80126f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801274:	75 c9                	jne    80123f <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801276:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80127c:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801281:	5d                   	pop    %ebp
  801282:	c3                   	ret    

00801283 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801283:	55                   	push   %ebp
  801284:	89 e5                	mov    %esp,%ebp
  801286:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801289:	83 f8 1f             	cmp    $0x1f,%eax
  80128c:	77 36                	ja     8012c4 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80128e:	c1 e0 0c             	shl    $0xc,%eax
  801291:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801296:	89 c2                	mov    %eax,%edx
  801298:	c1 ea 16             	shr    $0x16,%edx
  80129b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012a2:	f6 c2 01             	test   $0x1,%dl
  8012a5:	74 24                	je     8012cb <fd_lookup+0x48>
  8012a7:	89 c2                	mov    %eax,%edx
  8012a9:	c1 ea 0c             	shr    $0xc,%edx
  8012ac:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012b3:	f6 c2 01             	test   $0x1,%dl
  8012b6:	74 1a                	je     8012d2 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012bb:	89 02                	mov    %eax,(%edx)
	return 0;
  8012bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8012c2:	eb 13                	jmp    8012d7 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012c4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012c9:	eb 0c                	jmp    8012d7 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012cb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012d0:	eb 05                	jmp    8012d7 <fd_lookup+0x54>
  8012d2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012d7:	5d                   	pop    %ebp
  8012d8:	c3                   	ret    

008012d9 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012d9:	55                   	push   %ebp
  8012da:	89 e5                	mov    %esp,%ebp
  8012dc:	83 ec 08             	sub    $0x8,%esp
  8012df:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012e2:	ba 6c 29 80 00       	mov    $0x80296c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012e7:	eb 13                	jmp    8012fc <dev_lookup+0x23>
  8012e9:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8012ec:	39 08                	cmp    %ecx,(%eax)
  8012ee:	75 0c                	jne    8012fc <dev_lookup+0x23>
			*dev = devtab[i];
  8012f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012f3:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8012fa:	eb 2e                	jmp    80132a <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012fc:	8b 02                	mov    (%edx),%eax
  8012fe:	85 c0                	test   %eax,%eax
  801300:	75 e7                	jne    8012e9 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801302:	a1 04 40 80 00       	mov    0x804004,%eax
  801307:	8b 40 48             	mov    0x48(%eax),%eax
  80130a:	83 ec 04             	sub    $0x4,%esp
  80130d:	51                   	push   %ecx
  80130e:	50                   	push   %eax
  80130f:	68 ec 28 80 00       	push   $0x8028ec
  801314:	e8 d2 f0 ff ff       	call   8003eb <cprintf>
	*dev = 0;
  801319:	8b 45 0c             	mov    0xc(%ebp),%eax
  80131c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801322:	83 c4 10             	add    $0x10,%esp
  801325:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80132a:	c9                   	leave  
  80132b:	c3                   	ret    

0080132c <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80132c:	55                   	push   %ebp
  80132d:	89 e5                	mov    %esp,%ebp
  80132f:	56                   	push   %esi
  801330:	53                   	push   %ebx
  801331:	83 ec 10             	sub    $0x10,%esp
  801334:	8b 75 08             	mov    0x8(%ebp),%esi
  801337:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80133a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80133d:	50                   	push   %eax
  80133e:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801344:	c1 e8 0c             	shr    $0xc,%eax
  801347:	50                   	push   %eax
  801348:	e8 36 ff ff ff       	call   801283 <fd_lookup>
  80134d:	83 c4 08             	add    $0x8,%esp
  801350:	85 c0                	test   %eax,%eax
  801352:	78 05                	js     801359 <fd_close+0x2d>
	    || fd != fd2)
  801354:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801357:	74 0c                	je     801365 <fd_close+0x39>
		return (must_exist ? r : 0);
  801359:	84 db                	test   %bl,%bl
  80135b:	ba 00 00 00 00       	mov    $0x0,%edx
  801360:	0f 44 c2             	cmove  %edx,%eax
  801363:	eb 41                	jmp    8013a6 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801365:	83 ec 08             	sub    $0x8,%esp
  801368:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80136b:	50                   	push   %eax
  80136c:	ff 36                	pushl  (%esi)
  80136e:	e8 66 ff ff ff       	call   8012d9 <dev_lookup>
  801373:	89 c3                	mov    %eax,%ebx
  801375:	83 c4 10             	add    $0x10,%esp
  801378:	85 c0                	test   %eax,%eax
  80137a:	78 1a                	js     801396 <fd_close+0x6a>
		if (dev->dev_close)
  80137c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80137f:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801382:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801387:	85 c0                	test   %eax,%eax
  801389:	74 0b                	je     801396 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80138b:	83 ec 0c             	sub    $0xc,%esp
  80138e:	56                   	push   %esi
  80138f:	ff d0                	call   *%eax
  801391:	89 c3                	mov    %eax,%ebx
  801393:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801396:	83 ec 08             	sub    $0x8,%esp
  801399:	56                   	push   %esi
  80139a:	6a 00                	push   $0x0
  80139c:	e8 57 fa ff ff       	call   800df8 <sys_page_unmap>
	return r;
  8013a1:	83 c4 10             	add    $0x10,%esp
  8013a4:	89 d8                	mov    %ebx,%eax
}
  8013a6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013a9:	5b                   	pop    %ebx
  8013aa:	5e                   	pop    %esi
  8013ab:	5d                   	pop    %ebp
  8013ac:	c3                   	ret    

008013ad <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013ad:	55                   	push   %ebp
  8013ae:	89 e5                	mov    %esp,%ebp
  8013b0:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013b3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013b6:	50                   	push   %eax
  8013b7:	ff 75 08             	pushl  0x8(%ebp)
  8013ba:	e8 c4 fe ff ff       	call   801283 <fd_lookup>
  8013bf:	83 c4 08             	add    $0x8,%esp
  8013c2:	85 c0                	test   %eax,%eax
  8013c4:	78 10                	js     8013d6 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8013c6:	83 ec 08             	sub    $0x8,%esp
  8013c9:	6a 01                	push   $0x1
  8013cb:	ff 75 f4             	pushl  -0xc(%ebp)
  8013ce:	e8 59 ff ff ff       	call   80132c <fd_close>
  8013d3:	83 c4 10             	add    $0x10,%esp
}
  8013d6:	c9                   	leave  
  8013d7:	c3                   	ret    

008013d8 <close_all>:

void
close_all(void)
{
  8013d8:	55                   	push   %ebp
  8013d9:	89 e5                	mov    %esp,%ebp
  8013db:	53                   	push   %ebx
  8013dc:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013df:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013e4:	83 ec 0c             	sub    $0xc,%esp
  8013e7:	53                   	push   %ebx
  8013e8:	e8 c0 ff ff ff       	call   8013ad <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013ed:	83 c3 01             	add    $0x1,%ebx
  8013f0:	83 c4 10             	add    $0x10,%esp
  8013f3:	83 fb 20             	cmp    $0x20,%ebx
  8013f6:	75 ec                	jne    8013e4 <close_all+0xc>
		close(i);
}
  8013f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013fb:	c9                   	leave  
  8013fc:	c3                   	ret    

008013fd <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013fd:	55                   	push   %ebp
  8013fe:	89 e5                	mov    %esp,%ebp
  801400:	57                   	push   %edi
  801401:	56                   	push   %esi
  801402:	53                   	push   %ebx
  801403:	83 ec 2c             	sub    $0x2c,%esp
  801406:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801409:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80140c:	50                   	push   %eax
  80140d:	ff 75 08             	pushl  0x8(%ebp)
  801410:	e8 6e fe ff ff       	call   801283 <fd_lookup>
  801415:	83 c4 08             	add    $0x8,%esp
  801418:	85 c0                	test   %eax,%eax
  80141a:	0f 88 c1 00 00 00    	js     8014e1 <dup+0xe4>
		return r;
	close(newfdnum);
  801420:	83 ec 0c             	sub    $0xc,%esp
  801423:	56                   	push   %esi
  801424:	e8 84 ff ff ff       	call   8013ad <close>

	newfd = INDEX2FD(newfdnum);
  801429:	89 f3                	mov    %esi,%ebx
  80142b:	c1 e3 0c             	shl    $0xc,%ebx
  80142e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801434:	83 c4 04             	add    $0x4,%esp
  801437:	ff 75 e4             	pushl  -0x1c(%ebp)
  80143a:	e8 de fd ff ff       	call   80121d <fd2data>
  80143f:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801441:	89 1c 24             	mov    %ebx,(%esp)
  801444:	e8 d4 fd ff ff       	call   80121d <fd2data>
  801449:	83 c4 10             	add    $0x10,%esp
  80144c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80144f:	89 f8                	mov    %edi,%eax
  801451:	c1 e8 16             	shr    $0x16,%eax
  801454:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80145b:	a8 01                	test   $0x1,%al
  80145d:	74 37                	je     801496 <dup+0x99>
  80145f:	89 f8                	mov    %edi,%eax
  801461:	c1 e8 0c             	shr    $0xc,%eax
  801464:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80146b:	f6 c2 01             	test   $0x1,%dl
  80146e:	74 26                	je     801496 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801470:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801477:	83 ec 0c             	sub    $0xc,%esp
  80147a:	25 07 0e 00 00       	and    $0xe07,%eax
  80147f:	50                   	push   %eax
  801480:	ff 75 d4             	pushl  -0x2c(%ebp)
  801483:	6a 00                	push   $0x0
  801485:	57                   	push   %edi
  801486:	6a 00                	push   $0x0
  801488:	e8 29 f9 ff ff       	call   800db6 <sys_page_map>
  80148d:	89 c7                	mov    %eax,%edi
  80148f:	83 c4 20             	add    $0x20,%esp
  801492:	85 c0                	test   %eax,%eax
  801494:	78 2e                	js     8014c4 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801496:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801499:	89 d0                	mov    %edx,%eax
  80149b:	c1 e8 0c             	shr    $0xc,%eax
  80149e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014a5:	83 ec 0c             	sub    $0xc,%esp
  8014a8:	25 07 0e 00 00       	and    $0xe07,%eax
  8014ad:	50                   	push   %eax
  8014ae:	53                   	push   %ebx
  8014af:	6a 00                	push   $0x0
  8014b1:	52                   	push   %edx
  8014b2:	6a 00                	push   $0x0
  8014b4:	e8 fd f8 ff ff       	call   800db6 <sys_page_map>
  8014b9:	89 c7                	mov    %eax,%edi
  8014bb:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8014be:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014c0:	85 ff                	test   %edi,%edi
  8014c2:	79 1d                	jns    8014e1 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014c4:	83 ec 08             	sub    $0x8,%esp
  8014c7:	53                   	push   %ebx
  8014c8:	6a 00                	push   $0x0
  8014ca:	e8 29 f9 ff ff       	call   800df8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014cf:	83 c4 08             	add    $0x8,%esp
  8014d2:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014d5:	6a 00                	push   $0x0
  8014d7:	e8 1c f9 ff ff       	call   800df8 <sys_page_unmap>
	return r;
  8014dc:	83 c4 10             	add    $0x10,%esp
  8014df:	89 f8                	mov    %edi,%eax
}
  8014e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014e4:	5b                   	pop    %ebx
  8014e5:	5e                   	pop    %esi
  8014e6:	5f                   	pop    %edi
  8014e7:	5d                   	pop    %ebp
  8014e8:	c3                   	ret    

008014e9 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014e9:	55                   	push   %ebp
  8014ea:	89 e5                	mov    %esp,%ebp
  8014ec:	53                   	push   %ebx
  8014ed:	83 ec 14             	sub    $0x14,%esp
  8014f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014f3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014f6:	50                   	push   %eax
  8014f7:	53                   	push   %ebx
  8014f8:	e8 86 fd ff ff       	call   801283 <fd_lookup>
  8014fd:	83 c4 08             	add    $0x8,%esp
  801500:	89 c2                	mov    %eax,%edx
  801502:	85 c0                	test   %eax,%eax
  801504:	78 6d                	js     801573 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801506:	83 ec 08             	sub    $0x8,%esp
  801509:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80150c:	50                   	push   %eax
  80150d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801510:	ff 30                	pushl  (%eax)
  801512:	e8 c2 fd ff ff       	call   8012d9 <dev_lookup>
  801517:	83 c4 10             	add    $0x10,%esp
  80151a:	85 c0                	test   %eax,%eax
  80151c:	78 4c                	js     80156a <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80151e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801521:	8b 42 08             	mov    0x8(%edx),%eax
  801524:	83 e0 03             	and    $0x3,%eax
  801527:	83 f8 01             	cmp    $0x1,%eax
  80152a:	75 21                	jne    80154d <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80152c:	a1 04 40 80 00       	mov    0x804004,%eax
  801531:	8b 40 48             	mov    0x48(%eax),%eax
  801534:	83 ec 04             	sub    $0x4,%esp
  801537:	53                   	push   %ebx
  801538:	50                   	push   %eax
  801539:	68 30 29 80 00       	push   $0x802930
  80153e:	e8 a8 ee ff ff       	call   8003eb <cprintf>
		return -E_INVAL;
  801543:	83 c4 10             	add    $0x10,%esp
  801546:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80154b:	eb 26                	jmp    801573 <read+0x8a>
	}
	if (!dev->dev_read)
  80154d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801550:	8b 40 08             	mov    0x8(%eax),%eax
  801553:	85 c0                	test   %eax,%eax
  801555:	74 17                	je     80156e <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801557:	83 ec 04             	sub    $0x4,%esp
  80155a:	ff 75 10             	pushl  0x10(%ebp)
  80155d:	ff 75 0c             	pushl  0xc(%ebp)
  801560:	52                   	push   %edx
  801561:	ff d0                	call   *%eax
  801563:	89 c2                	mov    %eax,%edx
  801565:	83 c4 10             	add    $0x10,%esp
  801568:	eb 09                	jmp    801573 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80156a:	89 c2                	mov    %eax,%edx
  80156c:	eb 05                	jmp    801573 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80156e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801573:	89 d0                	mov    %edx,%eax
  801575:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801578:	c9                   	leave  
  801579:	c3                   	ret    

0080157a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80157a:	55                   	push   %ebp
  80157b:	89 e5                	mov    %esp,%ebp
  80157d:	57                   	push   %edi
  80157e:	56                   	push   %esi
  80157f:	53                   	push   %ebx
  801580:	83 ec 0c             	sub    $0xc,%esp
  801583:	8b 7d 08             	mov    0x8(%ebp),%edi
  801586:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801589:	bb 00 00 00 00       	mov    $0x0,%ebx
  80158e:	eb 21                	jmp    8015b1 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801590:	83 ec 04             	sub    $0x4,%esp
  801593:	89 f0                	mov    %esi,%eax
  801595:	29 d8                	sub    %ebx,%eax
  801597:	50                   	push   %eax
  801598:	89 d8                	mov    %ebx,%eax
  80159a:	03 45 0c             	add    0xc(%ebp),%eax
  80159d:	50                   	push   %eax
  80159e:	57                   	push   %edi
  80159f:	e8 45 ff ff ff       	call   8014e9 <read>
		if (m < 0)
  8015a4:	83 c4 10             	add    $0x10,%esp
  8015a7:	85 c0                	test   %eax,%eax
  8015a9:	78 10                	js     8015bb <readn+0x41>
			return m;
		if (m == 0)
  8015ab:	85 c0                	test   %eax,%eax
  8015ad:	74 0a                	je     8015b9 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015af:	01 c3                	add    %eax,%ebx
  8015b1:	39 f3                	cmp    %esi,%ebx
  8015b3:	72 db                	jb     801590 <readn+0x16>
  8015b5:	89 d8                	mov    %ebx,%eax
  8015b7:	eb 02                	jmp    8015bb <readn+0x41>
  8015b9:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8015bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015be:	5b                   	pop    %ebx
  8015bf:	5e                   	pop    %esi
  8015c0:	5f                   	pop    %edi
  8015c1:	5d                   	pop    %ebp
  8015c2:	c3                   	ret    

008015c3 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015c3:	55                   	push   %ebp
  8015c4:	89 e5                	mov    %esp,%ebp
  8015c6:	53                   	push   %ebx
  8015c7:	83 ec 14             	sub    $0x14,%esp
  8015ca:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015cd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015d0:	50                   	push   %eax
  8015d1:	53                   	push   %ebx
  8015d2:	e8 ac fc ff ff       	call   801283 <fd_lookup>
  8015d7:	83 c4 08             	add    $0x8,%esp
  8015da:	89 c2                	mov    %eax,%edx
  8015dc:	85 c0                	test   %eax,%eax
  8015de:	78 68                	js     801648 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015e0:	83 ec 08             	sub    $0x8,%esp
  8015e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015e6:	50                   	push   %eax
  8015e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ea:	ff 30                	pushl  (%eax)
  8015ec:	e8 e8 fc ff ff       	call   8012d9 <dev_lookup>
  8015f1:	83 c4 10             	add    $0x10,%esp
  8015f4:	85 c0                	test   %eax,%eax
  8015f6:	78 47                	js     80163f <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015fb:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015ff:	75 21                	jne    801622 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801601:	a1 04 40 80 00       	mov    0x804004,%eax
  801606:	8b 40 48             	mov    0x48(%eax),%eax
  801609:	83 ec 04             	sub    $0x4,%esp
  80160c:	53                   	push   %ebx
  80160d:	50                   	push   %eax
  80160e:	68 4c 29 80 00       	push   $0x80294c
  801613:	e8 d3 ed ff ff       	call   8003eb <cprintf>
		return -E_INVAL;
  801618:	83 c4 10             	add    $0x10,%esp
  80161b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801620:	eb 26                	jmp    801648 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801622:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801625:	8b 52 0c             	mov    0xc(%edx),%edx
  801628:	85 d2                	test   %edx,%edx
  80162a:	74 17                	je     801643 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80162c:	83 ec 04             	sub    $0x4,%esp
  80162f:	ff 75 10             	pushl  0x10(%ebp)
  801632:	ff 75 0c             	pushl  0xc(%ebp)
  801635:	50                   	push   %eax
  801636:	ff d2                	call   *%edx
  801638:	89 c2                	mov    %eax,%edx
  80163a:	83 c4 10             	add    $0x10,%esp
  80163d:	eb 09                	jmp    801648 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80163f:	89 c2                	mov    %eax,%edx
  801641:	eb 05                	jmp    801648 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801643:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801648:	89 d0                	mov    %edx,%eax
  80164a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80164d:	c9                   	leave  
  80164e:	c3                   	ret    

0080164f <seek>:

int
seek(int fdnum, off_t offset)
{
  80164f:	55                   	push   %ebp
  801650:	89 e5                	mov    %esp,%ebp
  801652:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801655:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801658:	50                   	push   %eax
  801659:	ff 75 08             	pushl  0x8(%ebp)
  80165c:	e8 22 fc ff ff       	call   801283 <fd_lookup>
  801661:	83 c4 08             	add    $0x8,%esp
  801664:	85 c0                	test   %eax,%eax
  801666:	78 0e                	js     801676 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801668:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80166b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80166e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801671:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801676:	c9                   	leave  
  801677:	c3                   	ret    

00801678 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801678:	55                   	push   %ebp
  801679:	89 e5                	mov    %esp,%ebp
  80167b:	53                   	push   %ebx
  80167c:	83 ec 14             	sub    $0x14,%esp
  80167f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801682:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801685:	50                   	push   %eax
  801686:	53                   	push   %ebx
  801687:	e8 f7 fb ff ff       	call   801283 <fd_lookup>
  80168c:	83 c4 08             	add    $0x8,%esp
  80168f:	89 c2                	mov    %eax,%edx
  801691:	85 c0                	test   %eax,%eax
  801693:	78 65                	js     8016fa <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801695:	83 ec 08             	sub    $0x8,%esp
  801698:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80169b:	50                   	push   %eax
  80169c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80169f:	ff 30                	pushl  (%eax)
  8016a1:	e8 33 fc ff ff       	call   8012d9 <dev_lookup>
  8016a6:	83 c4 10             	add    $0x10,%esp
  8016a9:	85 c0                	test   %eax,%eax
  8016ab:	78 44                	js     8016f1 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016b0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016b4:	75 21                	jne    8016d7 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016b6:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016bb:	8b 40 48             	mov    0x48(%eax),%eax
  8016be:	83 ec 04             	sub    $0x4,%esp
  8016c1:	53                   	push   %ebx
  8016c2:	50                   	push   %eax
  8016c3:	68 0c 29 80 00       	push   $0x80290c
  8016c8:	e8 1e ed ff ff       	call   8003eb <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016cd:	83 c4 10             	add    $0x10,%esp
  8016d0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016d5:	eb 23                	jmp    8016fa <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8016d7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016da:	8b 52 18             	mov    0x18(%edx),%edx
  8016dd:	85 d2                	test   %edx,%edx
  8016df:	74 14                	je     8016f5 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016e1:	83 ec 08             	sub    $0x8,%esp
  8016e4:	ff 75 0c             	pushl  0xc(%ebp)
  8016e7:	50                   	push   %eax
  8016e8:	ff d2                	call   *%edx
  8016ea:	89 c2                	mov    %eax,%edx
  8016ec:	83 c4 10             	add    $0x10,%esp
  8016ef:	eb 09                	jmp    8016fa <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016f1:	89 c2                	mov    %eax,%edx
  8016f3:	eb 05                	jmp    8016fa <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016f5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8016fa:	89 d0                	mov    %edx,%eax
  8016fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ff:	c9                   	leave  
  801700:	c3                   	ret    

00801701 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801701:	55                   	push   %ebp
  801702:	89 e5                	mov    %esp,%ebp
  801704:	53                   	push   %ebx
  801705:	83 ec 14             	sub    $0x14,%esp
  801708:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80170b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80170e:	50                   	push   %eax
  80170f:	ff 75 08             	pushl  0x8(%ebp)
  801712:	e8 6c fb ff ff       	call   801283 <fd_lookup>
  801717:	83 c4 08             	add    $0x8,%esp
  80171a:	89 c2                	mov    %eax,%edx
  80171c:	85 c0                	test   %eax,%eax
  80171e:	78 58                	js     801778 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801720:	83 ec 08             	sub    $0x8,%esp
  801723:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801726:	50                   	push   %eax
  801727:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80172a:	ff 30                	pushl  (%eax)
  80172c:	e8 a8 fb ff ff       	call   8012d9 <dev_lookup>
  801731:	83 c4 10             	add    $0x10,%esp
  801734:	85 c0                	test   %eax,%eax
  801736:	78 37                	js     80176f <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801738:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80173b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80173f:	74 32                	je     801773 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801741:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801744:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80174b:	00 00 00 
	stat->st_isdir = 0;
  80174e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801755:	00 00 00 
	stat->st_dev = dev;
  801758:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80175e:	83 ec 08             	sub    $0x8,%esp
  801761:	53                   	push   %ebx
  801762:	ff 75 f0             	pushl  -0x10(%ebp)
  801765:	ff 50 14             	call   *0x14(%eax)
  801768:	89 c2                	mov    %eax,%edx
  80176a:	83 c4 10             	add    $0x10,%esp
  80176d:	eb 09                	jmp    801778 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80176f:	89 c2                	mov    %eax,%edx
  801771:	eb 05                	jmp    801778 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801773:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801778:	89 d0                	mov    %edx,%eax
  80177a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80177d:	c9                   	leave  
  80177e:	c3                   	ret    

0080177f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80177f:	55                   	push   %ebp
  801780:	89 e5                	mov    %esp,%ebp
  801782:	56                   	push   %esi
  801783:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801784:	83 ec 08             	sub    $0x8,%esp
  801787:	6a 00                	push   $0x0
  801789:	ff 75 08             	pushl  0x8(%ebp)
  80178c:	e8 0c 02 00 00       	call   80199d <open>
  801791:	89 c3                	mov    %eax,%ebx
  801793:	83 c4 10             	add    $0x10,%esp
  801796:	85 c0                	test   %eax,%eax
  801798:	78 1b                	js     8017b5 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80179a:	83 ec 08             	sub    $0x8,%esp
  80179d:	ff 75 0c             	pushl  0xc(%ebp)
  8017a0:	50                   	push   %eax
  8017a1:	e8 5b ff ff ff       	call   801701 <fstat>
  8017a6:	89 c6                	mov    %eax,%esi
	close(fd);
  8017a8:	89 1c 24             	mov    %ebx,(%esp)
  8017ab:	e8 fd fb ff ff       	call   8013ad <close>
	return r;
  8017b0:	83 c4 10             	add    $0x10,%esp
  8017b3:	89 f0                	mov    %esi,%eax
}
  8017b5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017b8:	5b                   	pop    %ebx
  8017b9:	5e                   	pop    %esi
  8017ba:	5d                   	pop    %ebp
  8017bb:	c3                   	ret    

008017bc <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017bc:	55                   	push   %ebp
  8017bd:	89 e5                	mov    %esp,%ebp
  8017bf:	56                   	push   %esi
  8017c0:	53                   	push   %ebx
  8017c1:	89 c6                	mov    %eax,%esi
  8017c3:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017c5:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017cc:	75 12                	jne    8017e0 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017ce:	83 ec 0c             	sub    $0xc,%esp
  8017d1:	6a 01                	push   $0x1
  8017d3:	e8 ca 08 00 00       	call   8020a2 <ipc_find_env>
  8017d8:	a3 00 40 80 00       	mov    %eax,0x804000
  8017dd:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017e0:	6a 07                	push   $0x7
  8017e2:	68 00 50 80 00       	push   $0x805000
  8017e7:	56                   	push   %esi
  8017e8:	ff 35 00 40 80 00    	pushl  0x804000
  8017ee:	e8 5b 08 00 00       	call   80204e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017f3:	83 c4 0c             	add    $0xc,%esp
  8017f6:	6a 00                	push   $0x0
  8017f8:	53                   	push   %ebx
  8017f9:	6a 00                	push   $0x0
  8017fb:	e8 e5 07 00 00       	call   801fe5 <ipc_recv>
}
  801800:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801803:	5b                   	pop    %ebx
  801804:	5e                   	pop    %esi
  801805:	5d                   	pop    %ebp
  801806:	c3                   	ret    

00801807 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801807:	55                   	push   %ebp
  801808:	89 e5                	mov    %esp,%ebp
  80180a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80180d:	8b 45 08             	mov    0x8(%ebp),%eax
  801810:	8b 40 0c             	mov    0xc(%eax),%eax
  801813:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801818:	8b 45 0c             	mov    0xc(%ebp),%eax
  80181b:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801820:	ba 00 00 00 00       	mov    $0x0,%edx
  801825:	b8 02 00 00 00       	mov    $0x2,%eax
  80182a:	e8 8d ff ff ff       	call   8017bc <fsipc>
}
  80182f:	c9                   	leave  
  801830:	c3                   	ret    

00801831 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801831:	55                   	push   %ebp
  801832:	89 e5                	mov    %esp,%ebp
  801834:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801837:	8b 45 08             	mov    0x8(%ebp),%eax
  80183a:	8b 40 0c             	mov    0xc(%eax),%eax
  80183d:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801842:	ba 00 00 00 00       	mov    $0x0,%edx
  801847:	b8 06 00 00 00       	mov    $0x6,%eax
  80184c:	e8 6b ff ff ff       	call   8017bc <fsipc>
}
  801851:	c9                   	leave  
  801852:	c3                   	ret    

00801853 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801853:	55                   	push   %ebp
  801854:	89 e5                	mov    %esp,%ebp
  801856:	53                   	push   %ebx
  801857:	83 ec 04             	sub    $0x4,%esp
  80185a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80185d:	8b 45 08             	mov    0x8(%ebp),%eax
  801860:	8b 40 0c             	mov    0xc(%eax),%eax
  801863:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801868:	ba 00 00 00 00       	mov    $0x0,%edx
  80186d:	b8 05 00 00 00       	mov    $0x5,%eax
  801872:	e8 45 ff ff ff       	call   8017bc <fsipc>
  801877:	85 c0                	test   %eax,%eax
  801879:	78 2c                	js     8018a7 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80187b:	83 ec 08             	sub    $0x8,%esp
  80187e:	68 00 50 80 00       	push   $0x805000
  801883:	53                   	push   %ebx
  801884:	e8 e7 f0 ff ff       	call   800970 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801889:	a1 80 50 80 00       	mov    0x805080,%eax
  80188e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801894:	a1 84 50 80 00       	mov    0x805084,%eax
  801899:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80189f:	83 c4 10             	add    $0x10,%esp
  8018a2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018aa:	c9                   	leave  
  8018ab:	c3                   	ret    

008018ac <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8018ac:	55                   	push   %ebp
  8018ad:	89 e5                	mov    %esp,%ebp
  8018af:	53                   	push   %ebx
  8018b0:	83 ec 08             	sub    $0x8,%esp
  8018b3:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8018b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8018b9:	8b 52 0c             	mov    0xc(%edx),%edx
  8018bc:	89 15 00 50 80 00    	mov    %edx,0x805000
  8018c2:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8018c7:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  8018cc:	0f 46 d8             	cmovbe %eax,%ebx
	
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  8018cf:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  8018d5:	53                   	push   %ebx
  8018d6:	ff 75 0c             	pushl  0xc(%ebp)
  8018d9:	68 08 50 80 00       	push   $0x805008
  8018de:	e8 1f f2 ff ff       	call   800b02 <memmove>

	
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) 
  8018e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8018e8:	b8 04 00 00 00       	mov    $0x4,%eax
  8018ed:	e8 ca fe ff ff       	call   8017bc <fsipc>
  8018f2:	83 c4 10             	add    $0x10,%esp
  8018f5:	85 c0                	test   %eax,%eax
  8018f7:	78 1d                	js     801916 <devfile_write+0x6a>
		return r;
	assert(r <= n_real); 
  8018f9:	39 d8                	cmp    %ebx,%eax
  8018fb:	76 19                	jbe    801916 <devfile_write+0x6a>
  8018fd:	68 7c 29 80 00       	push   $0x80297c
  801902:	68 88 29 80 00       	push   $0x802988
  801907:	68 a3 00 00 00       	push   $0xa3
  80190c:	68 9d 29 80 00       	push   $0x80299d
  801911:	e8 fc e9 ff ff       	call   800312 <_panic>
	return r;
}
  801916:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801919:	c9                   	leave  
  80191a:	c3                   	ret    

0080191b <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80191b:	55                   	push   %ebp
  80191c:	89 e5                	mov    %esp,%ebp
  80191e:	56                   	push   %esi
  80191f:	53                   	push   %ebx
  801920:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801923:	8b 45 08             	mov    0x8(%ebp),%eax
  801926:	8b 40 0c             	mov    0xc(%eax),%eax
  801929:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80192e:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801934:	ba 00 00 00 00       	mov    $0x0,%edx
  801939:	b8 03 00 00 00       	mov    $0x3,%eax
  80193e:	e8 79 fe ff ff       	call   8017bc <fsipc>
  801943:	89 c3                	mov    %eax,%ebx
  801945:	85 c0                	test   %eax,%eax
  801947:	78 4b                	js     801994 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801949:	39 c6                	cmp    %eax,%esi
  80194b:	73 16                	jae    801963 <devfile_read+0x48>
  80194d:	68 a8 29 80 00       	push   $0x8029a8
  801952:	68 88 29 80 00       	push   $0x802988
  801957:	6a 7c                	push   $0x7c
  801959:	68 9d 29 80 00       	push   $0x80299d
  80195e:	e8 af e9 ff ff       	call   800312 <_panic>
	assert(r <= PGSIZE);
  801963:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801968:	7e 16                	jle    801980 <devfile_read+0x65>
  80196a:	68 af 29 80 00       	push   $0x8029af
  80196f:	68 88 29 80 00       	push   $0x802988
  801974:	6a 7d                	push   $0x7d
  801976:	68 9d 29 80 00       	push   $0x80299d
  80197b:	e8 92 e9 ff ff       	call   800312 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801980:	83 ec 04             	sub    $0x4,%esp
  801983:	50                   	push   %eax
  801984:	68 00 50 80 00       	push   $0x805000
  801989:	ff 75 0c             	pushl  0xc(%ebp)
  80198c:	e8 71 f1 ff ff       	call   800b02 <memmove>
	return r;
  801991:	83 c4 10             	add    $0x10,%esp
}
  801994:	89 d8                	mov    %ebx,%eax
  801996:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801999:	5b                   	pop    %ebx
  80199a:	5e                   	pop    %esi
  80199b:	5d                   	pop    %ebp
  80199c:	c3                   	ret    

0080199d <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80199d:	55                   	push   %ebp
  80199e:	89 e5                	mov    %esp,%ebp
  8019a0:	53                   	push   %ebx
  8019a1:	83 ec 20             	sub    $0x20,%esp
  8019a4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8019a7:	53                   	push   %ebx
  8019a8:	e8 8a ef ff ff       	call   800937 <strlen>
  8019ad:	83 c4 10             	add    $0x10,%esp
  8019b0:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019b5:	7f 67                	jg     801a1e <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019b7:	83 ec 0c             	sub    $0xc,%esp
  8019ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019bd:	50                   	push   %eax
  8019be:	e8 71 f8 ff ff       	call   801234 <fd_alloc>
  8019c3:	83 c4 10             	add    $0x10,%esp
		return r;
  8019c6:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019c8:	85 c0                	test   %eax,%eax
  8019ca:	78 57                	js     801a23 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8019cc:	83 ec 08             	sub    $0x8,%esp
  8019cf:	53                   	push   %ebx
  8019d0:	68 00 50 80 00       	push   $0x805000
  8019d5:	e8 96 ef ff ff       	call   800970 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019dd:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019e2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019e5:	b8 01 00 00 00       	mov    $0x1,%eax
  8019ea:	e8 cd fd ff ff       	call   8017bc <fsipc>
  8019ef:	89 c3                	mov    %eax,%ebx
  8019f1:	83 c4 10             	add    $0x10,%esp
  8019f4:	85 c0                	test   %eax,%eax
  8019f6:	79 14                	jns    801a0c <open+0x6f>
		fd_close(fd, 0);
  8019f8:	83 ec 08             	sub    $0x8,%esp
  8019fb:	6a 00                	push   $0x0
  8019fd:	ff 75 f4             	pushl  -0xc(%ebp)
  801a00:	e8 27 f9 ff ff       	call   80132c <fd_close>
		return r;
  801a05:	83 c4 10             	add    $0x10,%esp
  801a08:	89 da                	mov    %ebx,%edx
  801a0a:	eb 17                	jmp    801a23 <open+0x86>
	}

	return fd2num(fd);
  801a0c:	83 ec 0c             	sub    $0xc,%esp
  801a0f:	ff 75 f4             	pushl  -0xc(%ebp)
  801a12:	e8 f6 f7 ff ff       	call   80120d <fd2num>
  801a17:	89 c2                	mov    %eax,%edx
  801a19:	83 c4 10             	add    $0x10,%esp
  801a1c:	eb 05                	jmp    801a23 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a1e:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a23:	89 d0                	mov    %edx,%eax
  801a25:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a28:	c9                   	leave  
  801a29:	c3                   	ret    

00801a2a <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a2a:	55                   	push   %ebp
  801a2b:	89 e5                	mov    %esp,%ebp
  801a2d:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a30:	ba 00 00 00 00       	mov    $0x0,%edx
  801a35:	b8 08 00 00 00       	mov    $0x8,%eax
  801a3a:	e8 7d fd ff ff       	call   8017bc <fsipc>
}
  801a3f:	c9                   	leave  
  801a40:	c3                   	ret    

00801a41 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a41:	55                   	push   %ebp
  801a42:	89 e5                	mov    %esp,%ebp
  801a44:	56                   	push   %esi
  801a45:	53                   	push   %ebx
  801a46:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a49:	83 ec 0c             	sub    $0xc,%esp
  801a4c:	ff 75 08             	pushl  0x8(%ebp)
  801a4f:	e8 c9 f7 ff ff       	call   80121d <fd2data>
  801a54:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a56:	83 c4 08             	add    $0x8,%esp
  801a59:	68 bb 29 80 00       	push   $0x8029bb
  801a5e:	53                   	push   %ebx
  801a5f:	e8 0c ef ff ff       	call   800970 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a64:	8b 46 04             	mov    0x4(%esi),%eax
  801a67:	2b 06                	sub    (%esi),%eax
  801a69:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a6f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a76:	00 00 00 
	stat->st_dev = &devpipe;
  801a79:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  801a80:	30 80 00 
	return 0;
}
  801a83:	b8 00 00 00 00       	mov    $0x0,%eax
  801a88:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a8b:	5b                   	pop    %ebx
  801a8c:	5e                   	pop    %esi
  801a8d:	5d                   	pop    %ebp
  801a8e:	c3                   	ret    

00801a8f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a8f:	55                   	push   %ebp
  801a90:	89 e5                	mov    %esp,%ebp
  801a92:	53                   	push   %ebx
  801a93:	83 ec 0c             	sub    $0xc,%esp
  801a96:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a99:	53                   	push   %ebx
  801a9a:	6a 00                	push   $0x0
  801a9c:	e8 57 f3 ff ff       	call   800df8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801aa1:	89 1c 24             	mov    %ebx,(%esp)
  801aa4:	e8 74 f7 ff ff       	call   80121d <fd2data>
  801aa9:	83 c4 08             	add    $0x8,%esp
  801aac:	50                   	push   %eax
  801aad:	6a 00                	push   $0x0
  801aaf:	e8 44 f3 ff ff       	call   800df8 <sys_page_unmap>
}
  801ab4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ab7:	c9                   	leave  
  801ab8:	c3                   	ret    

00801ab9 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801ab9:	55                   	push   %ebp
  801aba:	89 e5                	mov    %esp,%ebp
  801abc:	57                   	push   %edi
  801abd:	56                   	push   %esi
  801abe:	53                   	push   %ebx
  801abf:	83 ec 1c             	sub    $0x1c,%esp
  801ac2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ac5:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ac7:	a1 04 40 80 00       	mov    0x804004,%eax
  801acc:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801acf:	83 ec 0c             	sub    $0xc,%esp
  801ad2:	ff 75 e0             	pushl  -0x20(%ebp)
  801ad5:	e8 01 06 00 00       	call   8020db <pageref>
  801ada:	89 c3                	mov    %eax,%ebx
  801adc:	89 3c 24             	mov    %edi,(%esp)
  801adf:	e8 f7 05 00 00       	call   8020db <pageref>
  801ae4:	83 c4 10             	add    $0x10,%esp
  801ae7:	39 c3                	cmp    %eax,%ebx
  801ae9:	0f 94 c1             	sete   %cl
  801aec:	0f b6 c9             	movzbl %cl,%ecx
  801aef:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801af2:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801af8:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801afb:	39 ce                	cmp    %ecx,%esi
  801afd:	74 1b                	je     801b1a <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801aff:	39 c3                	cmp    %eax,%ebx
  801b01:	75 c4                	jne    801ac7 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b03:	8b 42 58             	mov    0x58(%edx),%eax
  801b06:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b09:	50                   	push   %eax
  801b0a:	56                   	push   %esi
  801b0b:	68 c2 29 80 00       	push   $0x8029c2
  801b10:	e8 d6 e8 ff ff       	call   8003eb <cprintf>
  801b15:	83 c4 10             	add    $0x10,%esp
  801b18:	eb ad                	jmp    801ac7 <_pipeisclosed+0xe>
	}
}
  801b1a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b1d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b20:	5b                   	pop    %ebx
  801b21:	5e                   	pop    %esi
  801b22:	5f                   	pop    %edi
  801b23:	5d                   	pop    %ebp
  801b24:	c3                   	ret    

00801b25 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b25:	55                   	push   %ebp
  801b26:	89 e5                	mov    %esp,%ebp
  801b28:	57                   	push   %edi
  801b29:	56                   	push   %esi
  801b2a:	53                   	push   %ebx
  801b2b:	83 ec 28             	sub    $0x28,%esp
  801b2e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b31:	56                   	push   %esi
  801b32:	e8 e6 f6 ff ff       	call   80121d <fd2data>
  801b37:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b39:	83 c4 10             	add    $0x10,%esp
  801b3c:	bf 00 00 00 00       	mov    $0x0,%edi
  801b41:	eb 4b                	jmp    801b8e <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b43:	89 da                	mov    %ebx,%edx
  801b45:	89 f0                	mov    %esi,%eax
  801b47:	e8 6d ff ff ff       	call   801ab9 <_pipeisclosed>
  801b4c:	85 c0                	test   %eax,%eax
  801b4e:	75 48                	jne    801b98 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b50:	e8 ff f1 ff ff       	call   800d54 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b55:	8b 43 04             	mov    0x4(%ebx),%eax
  801b58:	8b 0b                	mov    (%ebx),%ecx
  801b5a:	8d 51 20             	lea    0x20(%ecx),%edx
  801b5d:	39 d0                	cmp    %edx,%eax
  801b5f:	73 e2                	jae    801b43 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b61:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b64:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b68:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b6b:	89 c2                	mov    %eax,%edx
  801b6d:	c1 fa 1f             	sar    $0x1f,%edx
  801b70:	89 d1                	mov    %edx,%ecx
  801b72:	c1 e9 1b             	shr    $0x1b,%ecx
  801b75:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b78:	83 e2 1f             	and    $0x1f,%edx
  801b7b:	29 ca                	sub    %ecx,%edx
  801b7d:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b81:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b85:	83 c0 01             	add    $0x1,%eax
  801b88:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b8b:	83 c7 01             	add    $0x1,%edi
  801b8e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b91:	75 c2                	jne    801b55 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b93:	8b 45 10             	mov    0x10(%ebp),%eax
  801b96:	eb 05                	jmp    801b9d <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b98:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b9d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ba0:	5b                   	pop    %ebx
  801ba1:	5e                   	pop    %esi
  801ba2:	5f                   	pop    %edi
  801ba3:	5d                   	pop    %ebp
  801ba4:	c3                   	ret    

00801ba5 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ba5:	55                   	push   %ebp
  801ba6:	89 e5                	mov    %esp,%ebp
  801ba8:	57                   	push   %edi
  801ba9:	56                   	push   %esi
  801baa:	53                   	push   %ebx
  801bab:	83 ec 18             	sub    $0x18,%esp
  801bae:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801bb1:	57                   	push   %edi
  801bb2:	e8 66 f6 ff ff       	call   80121d <fd2data>
  801bb7:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bb9:	83 c4 10             	add    $0x10,%esp
  801bbc:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bc1:	eb 3d                	jmp    801c00 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801bc3:	85 db                	test   %ebx,%ebx
  801bc5:	74 04                	je     801bcb <devpipe_read+0x26>
				return i;
  801bc7:	89 d8                	mov    %ebx,%eax
  801bc9:	eb 44                	jmp    801c0f <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801bcb:	89 f2                	mov    %esi,%edx
  801bcd:	89 f8                	mov    %edi,%eax
  801bcf:	e8 e5 fe ff ff       	call   801ab9 <_pipeisclosed>
  801bd4:	85 c0                	test   %eax,%eax
  801bd6:	75 32                	jne    801c0a <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801bd8:	e8 77 f1 ff ff       	call   800d54 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801bdd:	8b 06                	mov    (%esi),%eax
  801bdf:	3b 46 04             	cmp    0x4(%esi),%eax
  801be2:	74 df                	je     801bc3 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801be4:	99                   	cltd   
  801be5:	c1 ea 1b             	shr    $0x1b,%edx
  801be8:	01 d0                	add    %edx,%eax
  801bea:	83 e0 1f             	and    $0x1f,%eax
  801bed:	29 d0                	sub    %edx,%eax
  801bef:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801bf4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bf7:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801bfa:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bfd:	83 c3 01             	add    $0x1,%ebx
  801c00:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c03:	75 d8                	jne    801bdd <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c05:	8b 45 10             	mov    0x10(%ebp),%eax
  801c08:	eb 05                	jmp    801c0f <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c0a:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c0f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c12:	5b                   	pop    %ebx
  801c13:	5e                   	pop    %esi
  801c14:	5f                   	pop    %edi
  801c15:	5d                   	pop    %ebp
  801c16:	c3                   	ret    

00801c17 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c17:	55                   	push   %ebp
  801c18:	89 e5                	mov    %esp,%ebp
  801c1a:	56                   	push   %esi
  801c1b:	53                   	push   %ebx
  801c1c:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c1f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c22:	50                   	push   %eax
  801c23:	e8 0c f6 ff ff       	call   801234 <fd_alloc>
  801c28:	83 c4 10             	add    $0x10,%esp
  801c2b:	89 c2                	mov    %eax,%edx
  801c2d:	85 c0                	test   %eax,%eax
  801c2f:	0f 88 2c 01 00 00    	js     801d61 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c35:	83 ec 04             	sub    $0x4,%esp
  801c38:	68 07 04 00 00       	push   $0x407
  801c3d:	ff 75 f4             	pushl  -0xc(%ebp)
  801c40:	6a 00                	push   $0x0
  801c42:	e8 2c f1 ff ff       	call   800d73 <sys_page_alloc>
  801c47:	83 c4 10             	add    $0x10,%esp
  801c4a:	89 c2                	mov    %eax,%edx
  801c4c:	85 c0                	test   %eax,%eax
  801c4e:	0f 88 0d 01 00 00    	js     801d61 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c54:	83 ec 0c             	sub    $0xc,%esp
  801c57:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c5a:	50                   	push   %eax
  801c5b:	e8 d4 f5 ff ff       	call   801234 <fd_alloc>
  801c60:	89 c3                	mov    %eax,%ebx
  801c62:	83 c4 10             	add    $0x10,%esp
  801c65:	85 c0                	test   %eax,%eax
  801c67:	0f 88 e2 00 00 00    	js     801d4f <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c6d:	83 ec 04             	sub    $0x4,%esp
  801c70:	68 07 04 00 00       	push   $0x407
  801c75:	ff 75 f0             	pushl  -0x10(%ebp)
  801c78:	6a 00                	push   $0x0
  801c7a:	e8 f4 f0 ff ff       	call   800d73 <sys_page_alloc>
  801c7f:	89 c3                	mov    %eax,%ebx
  801c81:	83 c4 10             	add    $0x10,%esp
  801c84:	85 c0                	test   %eax,%eax
  801c86:	0f 88 c3 00 00 00    	js     801d4f <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c8c:	83 ec 0c             	sub    $0xc,%esp
  801c8f:	ff 75 f4             	pushl  -0xc(%ebp)
  801c92:	e8 86 f5 ff ff       	call   80121d <fd2data>
  801c97:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c99:	83 c4 0c             	add    $0xc,%esp
  801c9c:	68 07 04 00 00       	push   $0x407
  801ca1:	50                   	push   %eax
  801ca2:	6a 00                	push   $0x0
  801ca4:	e8 ca f0 ff ff       	call   800d73 <sys_page_alloc>
  801ca9:	89 c3                	mov    %eax,%ebx
  801cab:	83 c4 10             	add    $0x10,%esp
  801cae:	85 c0                	test   %eax,%eax
  801cb0:	0f 88 89 00 00 00    	js     801d3f <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cb6:	83 ec 0c             	sub    $0xc,%esp
  801cb9:	ff 75 f0             	pushl  -0x10(%ebp)
  801cbc:	e8 5c f5 ff ff       	call   80121d <fd2data>
  801cc1:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801cc8:	50                   	push   %eax
  801cc9:	6a 00                	push   $0x0
  801ccb:	56                   	push   %esi
  801ccc:	6a 00                	push   $0x0
  801cce:	e8 e3 f0 ff ff       	call   800db6 <sys_page_map>
  801cd3:	89 c3                	mov    %eax,%ebx
  801cd5:	83 c4 20             	add    $0x20,%esp
  801cd8:	85 c0                	test   %eax,%eax
  801cda:	78 55                	js     801d31 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801cdc:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801ce2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ce5:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ce7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cea:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801cf1:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801cf7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cfa:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801cfc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cff:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d06:	83 ec 0c             	sub    $0xc,%esp
  801d09:	ff 75 f4             	pushl  -0xc(%ebp)
  801d0c:	e8 fc f4 ff ff       	call   80120d <fd2num>
  801d11:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d14:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d16:	83 c4 04             	add    $0x4,%esp
  801d19:	ff 75 f0             	pushl  -0x10(%ebp)
  801d1c:	e8 ec f4 ff ff       	call   80120d <fd2num>
  801d21:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d24:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d27:	83 c4 10             	add    $0x10,%esp
  801d2a:	ba 00 00 00 00       	mov    $0x0,%edx
  801d2f:	eb 30                	jmp    801d61 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d31:	83 ec 08             	sub    $0x8,%esp
  801d34:	56                   	push   %esi
  801d35:	6a 00                	push   $0x0
  801d37:	e8 bc f0 ff ff       	call   800df8 <sys_page_unmap>
  801d3c:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d3f:	83 ec 08             	sub    $0x8,%esp
  801d42:	ff 75 f0             	pushl  -0x10(%ebp)
  801d45:	6a 00                	push   $0x0
  801d47:	e8 ac f0 ff ff       	call   800df8 <sys_page_unmap>
  801d4c:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d4f:	83 ec 08             	sub    $0x8,%esp
  801d52:	ff 75 f4             	pushl  -0xc(%ebp)
  801d55:	6a 00                	push   $0x0
  801d57:	e8 9c f0 ff ff       	call   800df8 <sys_page_unmap>
  801d5c:	83 c4 10             	add    $0x10,%esp
  801d5f:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d61:	89 d0                	mov    %edx,%eax
  801d63:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d66:	5b                   	pop    %ebx
  801d67:	5e                   	pop    %esi
  801d68:	5d                   	pop    %ebp
  801d69:	c3                   	ret    

00801d6a <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d6a:	55                   	push   %ebp
  801d6b:	89 e5                	mov    %esp,%ebp
  801d6d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d70:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d73:	50                   	push   %eax
  801d74:	ff 75 08             	pushl  0x8(%ebp)
  801d77:	e8 07 f5 ff ff       	call   801283 <fd_lookup>
  801d7c:	83 c4 10             	add    $0x10,%esp
  801d7f:	85 c0                	test   %eax,%eax
  801d81:	78 18                	js     801d9b <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d83:	83 ec 0c             	sub    $0xc,%esp
  801d86:	ff 75 f4             	pushl  -0xc(%ebp)
  801d89:	e8 8f f4 ff ff       	call   80121d <fd2data>
	return _pipeisclosed(fd, p);
  801d8e:	89 c2                	mov    %eax,%edx
  801d90:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d93:	e8 21 fd ff ff       	call   801ab9 <_pipeisclosed>
  801d98:	83 c4 10             	add    $0x10,%esp
}
  801d9b:	c9                   	leave  
  801d9c:	c3                   	ret    

00801d9d <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  801d9d:	55                   	push   %ebp
  801d9e:	89 e5                	mov    %esp,%ebp
  801da0:	56                   	push   %esi
  801da1:	53                   	push   %ebx
  801da2:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  801da5:	85 f6                	test   %esi,%esi
  801da7:	75 16                	jne    801dbf <wait+0x22>
  801da9:	68 da 29 80 00       	push   $0x8029da
  801dae:	68 88 29 80 00       	push   $0x802988
  801db3:	6a 09                	push   $0x9
  801db5:	68 e5 29 80 00       	push   $0x8029e5
  801dba:	e8 53 e5 ff ff       	call   800312 <_panic>
	e = &envs[ENVX(envid)];
  801dbf:	89 f3                	mov    %esi,%ebx
  801dc1:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801dc7:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  801dca:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  801dd0:	eb 05                	jmp    801dd7 <wait+0x3a>
		sys_yield();
  801dd2:	e8 7d ef ff ff       	call   800d54 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801dd7:	8b 43 48             	mov    0x48(%ebx),%eax
  801dda:	39 c6                	cmp    %eax,%esi
  801ddc:	75 07                	jne    801de5 <wait+0x48>
  801dde:	8b 43 54             	mov    0x54(%ebx),%eax
  801de1:	85 c0                	test   %eax,%eax
  801de3:	75 ed                	jne    801dd2 <wait+0x35>
		sys_yield();
}
  801de5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801de8:	5b                   	pop    %ebx
  801de9:	5e                   	pop    %esi
  801dea:	5d                   	pop    %ebp
  801deb:	c3                   	ret    

00801dec <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801dec:	55                   	push   %ebp
  801ded:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801def:	b8 00 00 00 00       	mov    $0x0,%eax
  801df4:	5d                   	pop    %ebp
  801df5:	c3                   	ret    

00801df6 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801df6:	55                   	push   %ebp
  801df7:	89 e5                	mov    %esp,%ebp
  801df9:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801dfc:	68 f0 29 80 00       	push   $0x8029f0
  801e01:	ff 75 0c             	pushl  0xc(%ebp)
  801e04:	e8 67 eb ff ff       	call   800970 <strcpy>
	return 0;
}
  801e09:	b8 00 00 00 00       	mov    $0x0,%eax
  801e0e:	c9                   	leave  
  801e0f:	c3                   	ret    

00801e10 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e10:	55                   	push   %ebp
  801e11:	89 e5                	mov    %esp,%ebp
  801e13:	57                   	push   %edi
  801e14:	56                   	push   %esi
  801e15:	53                   	push   %ebx
  801e16:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e1c:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e21:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e27:	eb 2d                	jmp    801e56 <devcons_write+0x46>
		m = n - tot;
  801e29:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e2c:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801e2e:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e31:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e36:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e39:	83 ec 04             	sub    $0x4,%esp
  801e3c:	53                   	push   %ebx
  801e3d:	03 45 0c             	add    0xc(%ebp),%eax
  801e40:	50                   	push   %eax
  801e41:	57                   	push   %edi
  801e42:	e8 bb ec ff ff       	call   800b02 <memmove>
		sys_cputs(buf, m);
  801e47:	83 c4 08             	add    $0x8,%esp
  801e4a:	53                   	push   %ebx
  801e4b:	57                   	push   %edi
  801e4c:	e8 66 ee ff ff       	call   800cb7 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e51:	01 de                	add    %ebx,%esi
  801e53:	83 c4 10             	add    $0x10,%esp
  801e56:	89 f0                	mov    %esi,%eax
  801e58:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e5b:	72 cc                	jb     801e29 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e5d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e60:	5b                   	pop    %ebx
  801e61:	5e                   	pop    %esi
  801e62:	5f                   	pop    %edi
  801e63:	5d                   	pop    %ebp
  801e64:	c3                   	ret    

00801e65 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e65:	55                   	push   %ebp
  801e66:	89 e5                	mov    %esp,%ebp
  801e68:	83 ec 08             	sub    $0x8,%esp
  801e6b:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801e70:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e74:	74 2a                	je     801ea0 <devcons_read+0x3b>
  801e76:	eb 05                	jmp    801e7d <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e78:	e8 d7 ee ff ff       	call   800d54 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e7d:	e8 53 ee ff ff       	call   800cd5 <sys_cgetc>
  801e82:	85 c0                	test   %eax,%eax
  801e84:	74 f2                	je     801e78 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e86:	85 c0                	test   %eax,%eax
  801e88:	78 16                	js     801ea0 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e8a:	83 f8 04             	cmp    $0x4,%eax
  801e8d:	74 0c                	je     801e9b <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e8f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e92:	88 02                	mov    %al,(%edx)
	return 1;
  801e94:	b8 01 00 00 00       	mov    $0x1,%eax
  801e99:	eb 05                	jmp    801ea0 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e9b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801ea0:	c9                   	leave  
  801ea1:	c3                   	ret    

00801ea2 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801ea2:	55                   	push   %ebp
  801ea3:	89 e5                	mov    %esp,%ebp
  801ea5:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801ea8:	8b 45 08             	mov    0x8(%ebp),%eax
  801eab:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801eae:	6a 01                	push   $0x1
  801eb0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801eb3:	50                   	push   %eax
  801eb4:	e8 fe ed ff ff       	call   800cb7 <sys_cputs>
}
  801eb9:	83 c4 10             	add    $0x10,%esp
  801ebc:	c9                   	leave  
  801ebd:	c3                   	ret    

00801ebe <getchar>:

int
getchar(void)
{
  801ebe:	55                   	push   %ebp
  801ebf:	89 e5                	mov    %esp,%ebp
  801ec1:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801ec4:	6a 01                	push   $0x1
  801ec6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ec9:	50                   	push   %eax
  801eca:	6a 00                	push   $0x0
  801ecc:	e8 18 f6 ff ff       	call   8014e9 <read>
	if (r < 0)
  801ed1:	83 c4 10             	add    $0x10,%esp
  801ed4:	85 c0                	test   %eax,%eax
  801ed6:	78 0f                	js     801ee7 <getchar+0x29>
		return r;
	if (r < 1)
  801ed8:	85 c0                	test   %eax,%eax
  801eda:	7e 06                	jle    801ee2 <getchar+0x24>
		return -E_EOF;
	return c;
  801edc:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801ee0:	eb 05                	jmp    801ee7 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801ee2:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801ee7:	c9                   	leave  
  801ee8:	c3                   	ret    

00801ee9 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801ee9:	55                   	push   %ebp
  801eea:	89 e5                	mov    %esp,%ebp
  801eec:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801eef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ef2:	50                   	push   %eax
  801ef3:	ff 75 08             	pushl  0x8(%ebp)
  801ef6:	e8 88 f3 ff ff       	call   801283 <fd_lookup>
  801efb:	83 c4 10             	add    $0x10,%esp
  801efe:	85 c0                	test   %eax,%eax
  801f00:	78 11                	js     801f13 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f02:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f05:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801f0b:	39 10                	cmp    %edx,(%eax)
  801f0d:	0f 94 c0             	sete   %al
  801f10:	0f b6 c0             	movzbl %al,%eax
}
  801f13:	c9                   	leave  
  801f14:	c3                   	ret    

00801f15 <opencons>:

int
opencons(void)
{
  801f15:	55                   	push   %ebp
  801f16:	89 e5                	mov    %esp,%ebp
  801f18:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f1b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f1e:	50                   	push   %eax
  801f1f:	e8 10 f3 ff ff       	call   801234 <fd_alloc>
  801f24:	83 c4 10             	add    $0x10,%esp
		return r;
  801f27:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f29:	85 c0                	test   %eax,%eax
  801f2b:	78 3e                	js     801f6b <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f2d:	83 ec 04             	sub    $0x4,%esp
  801f30:	68 07 04 00 00       	push   $0x407
  801f35:	ff 75 f4             	pushl  -0xc(%ebp)
  801f38:	6a 00                	push   $0x0
  801f3a:	e8 34 ee ff ff       	call   800d73 <sys_page_alloc>
  801f3f:	83 c4 10             	add    $0x10,%esp
		return r;
  801f42:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f44:	85 c0                	test   %eax,%eax
  801f46:	78 23                	js     801f6b <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f48:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801f4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f51:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f53:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f56:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f5d:	83 ec 0c             	sub    $0xc,%esp
  801f60:	50                   	push   %eax
  801f61:	e8 a7 f2 ff ff       	call   80120d <fd2num>
  801f66:	89 c2                	mov    %eax,%edx
  801f68:	83 c4 10             	add    $0x10,%esp
}
  801f6b:	89 d0                	mov    %edx,%eax
  801f6d:	c9                   	leave  
  801f6e:	c3                   	ret    

00801f6f <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f6f:	55                   	push   %ebp
  801f70:	89 e5                	mov    %esp,%ebp
  801f72:	53                   	push   %ebx
  801f73:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f76:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f7d:	75 28                	jne    801fa7 <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  801f7f:	e8 b1 ed ff ff       	call   800d35 <sys_getenvid>
  801f84:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_U | PTE_W);
  801f86:	83 ec 04             	sub    $0x4,%esp
  801f89:	6a 06                	push   $0x6
  801f8b:	68 00 f0 bf ee       	push   $0xeebff000
  801f90:	50                   	push   %eax
  801f91:	e8 dd ed ff ff       	call   800d73 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  801f96:	83 c4 08             	add    $0x8,%esp
  801f99:	68 b4 1f 80 00       	push   $0x801fb4
  801f9e:	53                   	push   %ebx
  801f9f:	e8 1a ef ff ff       	call   800ebe <sys_env_set_pgfault_upcall>
  801fa4:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801fa7:	8b 45 08             	mov    0x8(%ebp),%eax
  801faa:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801faf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fb2:	c9                   	leave  
  801fb3:	c3                   	ret    

00801fb4 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801fb4:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801fb5:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801fba:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801fbc:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	# My method is different. Copy the values to the other stack
	# in a convinient way, and then pop everything.
	movl %esp, %ebp		# ebp refers to the exception stack
  801fbf:	89 e5                	mov    %esp,%ebp
	movl 48(%ebp), %esp 	# go to other stack
  801fc1:	8b 65 30             	mov    0x30(%ebp),%esp

	pushl 40(%ebp)		# eip - ORDER SWITCHED WITH EFLAGS
  801fc4:	ff 75 28             	pushl  0x28(%ebp)
	pushl 44(%ebp)      	# eflags
  801fc7:	ff 75 2c             	pushl  0x2c(%ebp)
	pushl 36(%ebp)		# all the 8 remaining regs
  801fca:	ff 75 24             	pushl  0x24(%ebp)
	pushl 32(%ebp)
  801fcd:	ff 75 20             	pushl  0x20(%ebp)
	pushl 28(%ebp)
  801fd0:	ff 75 1c             	pushl  0x1c(%ebp)
	pushl 24(%ebp)
  801fd3:	ff 75 18             	pushl  0x18(%ebp)
	pushl 20(%ebp)
  801fd6:	ff 75 14             	pushl  0x14(%ebp)
	pushl 16(%ebp)
  801fd9:	ff 75 10             	pushl  0x10(%ebp)
	pushl 12(%ebp)
  801fdc:	ff 75 0c             	pushl  0xc(%ebp)
	pushl 8(%ebp)
  801fdf:	ff 75 08             	pushl  0x8(%ebp)

	popal			# now just pop everything!
  801fe2:	61                   	popa   
	popfl
  801fe3:	9d                   	popf   
	ret
  801fe4:	c3                   	ret    

00801fe5 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801fe5:	55                   	push   %ebp
  801fe6:	89 e5                	mov    %esp,%ebp
  801fe8:	56                   	push   %esi
  801fe9:	53                   	push   %ebx
  801fea:	8b 75 08             	mov    0x8(%ebp),%esi
  801fed:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ff0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  801ff3:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801ff5:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801ffa:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  801ffd:	83 ec 0c             	sub    $0xc,%esp
  802000:	50                   	push   %eax
  802001:	e8 1d ef ff ff       	call   800f23 <sys_ipc_recv>

	if (r < 0) {
  802006:	83 c4 10             	add    $0x10,%esp
  802009:	85 c0                	test   %eax,%eax
  80200b:	79 16                	jns    802023 <ipc_recv+0x3e>
		if (from_env_store)
  80200d:	85 f6                	test   %esi,%esi
  80200f:	74 06                	je     802017 <ipc_recv+0x32>
			*from_env_store = 0;
  802011:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  802017:	85 db                	test   %ebx,%ebx
  802019:	74 2c                	je     802047 <ipc_recv+0x62>
			*perm_store = 0;
  80201b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802021:	eb 24                	jmp    802047 <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  802023:	85 f6                	test   %esi,%esi
  802025:	74 0a                	je     802031 <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  802027:	a1 04 40 80 00       	mov    0x804004,%eax
  80202c:	8b 40 74             	mov    0x74(%eax),%eax
  80202f:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  802031:	85 db                	test   %ebx,%ebx
  802033:	74 0a                	je     80203f <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  802035:	a1 04 40 80 00       	mov    0x804004,%eax
  80203a:	8b 40 78             	mov    0x78(%eax),%eax
  80203d:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  80203f:	a1 04 40 80 00       	mov    0x804004,%eax
  802044:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  802047:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80204a:	5b                   	pop    %ebx
  80204b:	5e                   	pop    %esi
  80204c:	5d                   	pop    %ebp
  80204d:	c3                   	ret    

0080204e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80204e:	55                   	push   %ebp
  80204f:	89 e5                	mov    %esp,%ebp
  802051:	57                   	push   %edi
  802052:	56                   	push   %esi
  802053:	53                   	push   %ebx
  802054:	83 ec 0c             	sub    $0xc,%esp
  802057:	8b 7d 08             	mov    0x8(%ebp),%edi
  80205a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80205d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  802060:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  802062:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  802067:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  80206a:	ff 75 14             	pushl  0x14(%ebp)
  80206d:	53                   	push   %ebx
  80206e:	56                   	push   %esi
  80206f:	57                   	push   %edi
  802070:	e8 8b ee ff ff       	call   800f00 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  802075:	83 c4 10             	add    $0x10,%esp
  802078:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80207b:	75 07                	jne    802084 <ipc_send+0x36>
			sys_yield();
  80207d:	e8 d2 ec ff ff       	call   800d54 <sys_yield>
  802082:	eb e6                	jmp    80206a <ipc_send+0x1c>
		} else if (r < 0) {
  802084:	85 c0                	test   %eax,%eax
  802086:	79 12                	jns    80209a <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  802088:	50                   	push   %eax
  802089:	68 fc 29 80 00       	push   $0x8029fc
  80208e:	6a 51                	push   $0x51
  802090:	68 09 2a 80 00       	push   $0x802a09
  802095:	e8 78 e2 ff ff       	call   800312 <_panic>
		}
	}
}
  80209a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80209d:	5b                   	pop    %ebx
  80209e:	5e                   	pop    %esi
  80209f:	5f                   	pop    %edi
  8020a0:	5d                   	pop    %ebp
  8020a1:	c3                   	ret    

008020a2 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8020a2:	55                   	push   %ebp
  8020a3:	89 e5                	mov    %esp,%ebp
  8020a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8020a8:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8020ad:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8020b0:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8020b6:	8b 52 50             	mov    0x50(%edx),%edx
  8020b9:	39 ca                	cmp    %ecx,%edx
  8020bb:	75 0d                	jne    8020ca <ipc_find_env+0x28>
			return envs[i].env_id;
  8020bd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8020c0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8020c5:	8b 40 48             	mov    0x48(%eax),%eax
  8020c8:	eb 0f                	jmp    8020d9 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8020ca:	83 c0 01             	add    $0x1,%eax
  8020cd:	3d 00 04 00 00       	cmp    $0x400,%eax
  8020d2:	75 d9                	jne    8020ad <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8020d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8020d9:	5d                   	pop    %ebp
  8020da:	c3                   	ret    

008020db <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020db:	55                   	push   %ebp
  8020dc:	89 e5                	mov    %esp,%ebp
  8020de:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020e1:	89 d0                	mov    %edx,%eax
  8020e3:	c1 e8 16             	shr    $0x16,%eax
  8020e6:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8020ed:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020f2:	f6 c1 01             	test   $0x1,%cl
  8020f5:	74 1d                	je     802114 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8020f7:	c1 ea 0c             	shr    $0xc,%edx
  8020fa:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802101:	f6 c2 01             	test   $0x1,%dl
  802104:	74 0e                	je     802114 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802106:	c1 ea 0c             	shr    $0xc,%edx
  802109:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802110:	ef 
  802111:	0f b7 c0             	movzwl %ax,%eax
}
  802114:	5d                   	pop    %ebp
  802115:	c3                   	ret    
  802116:	66 90                	xchg   %ax,%ax
  802118:	66 90                	xchg   %ax,%ax
  80211a:	66 90                	xchg   %ax,%ax
  80211c:	66 90                	xchg   %ax,%ax
  80211e:	66 90                	xchg   %ax,%ax

00802120 <__udivdi3>:
  802120:	55                   	push   %ebp
  802121:	57                   	push   %edi
  802122:	56                   	push   %esi
  802123:	53                   	push   %ebx
  802124:	83 ec 1c             	sub    $0x1c,%esp
  802127:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80212b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80212f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802133:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802137:	85 f6                	test   %esi,%esi
  802139:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80213d:	89 ca                	mov    %ecx,%edx
  80213f:	89 f8                	mov    %edi,%eax
  802141:	75 3d                	jne    802180 <__udivdi3+0x60>
  802143:	39 cf                	cmp    %ecx,%edi
  802145:	0f 87 c5 00 00 00    	ja     802210 <__udivdi3+0xf0>
  80214b:	85 ff                	test   %edi,%edi
  80214d:	89 fd                	mov    %edi,%ebp
  80214f:	75 0b                	jne    80215c <__udivdi3+0x3c>
  802151:	b8 01 00 00 00       	mov    $0x1,%eax
  802156:	31 d2                	xor    %edx,%edx
  802158:	f7 f7                	div    %edi
  80215a:	89 c5                	mov    %eax,%ebp
  80215c:	89 c8                	mov    %ecx,%eax
  80215e:	31 d2                	xor    %edx,%edx
  802160:	f7 f5                	div    %ebp
  802162:	89 c1                	mov    %eax,%ecx
  802164:	89 d8                	mov    %ebx,%eax
  802166:	89 cf                	mov    %ecx,%edi
  802168:	f7 f5                	div    %ebp
  80216a:	89 c3                	mov    %eax,%ebx
  80216c:	89 d8                	mov    %ebx,%eax
  80216e:	89 fa                	mov    %edi,%edx
  802170:	83 c4 1c             	add    $0x1c,%esp
  802173:	5b                   	pop    %ebx
  802174:	5e                   	pop    %esi
  802175:	5f                   	pop    %edi
  802176:	5d                   	pop    %ebp
  802177:	c3                   	ret    
  802178:	90                   	nop
  802179:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802180:	39 ce                	cmp    %ecx,%esi
  802182:	77 74                	ja     8021f8 <__udivdi3+0xd8>
  802184:	0f bd fe             	bsr    %esi,%edi
  802187:	83 f7 1f             	xor    $0x1f,%edi
  80218a:	0f 84 98 00 00 00    	je     802228 <__udivdi3+0x108>
  802190:	bb 20 00 00 00       	mov    $0x20,%ebx
  802195:	89 f9                	mov    %edi,%ecx
  802197:	89 c5                	mov    %eax,%ebp
  802199:	29 fb                	sub    %edi,%ebx
  80219b:	d3 e6                	shl    %cl,%esi
  80219d:	89 d9                	mov    %ebx,%ecx
  80219f:	d3 ed                	shr    %cl,%ebp
  8021a1:	89 f9                	mov    %edi,%ecx
  8021a3:	d3 e0                	shl    %cl,%eax
  8021a5:	09 ee                	or     %ebp,%esi
  8021a7:	89 d9                	mov    %ebx,%ecx
  8021a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021ad:	89 d5                	mov    %edx,%ebp
  8021af:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021b3:	d3 ed                	shr    %cl,%ebp
  8021b5:	89 f9                	mov    %edi,%ecx
  8021b7:	d3 e2                	shl    %cl,%edx
  8021b9:	89 d9                	mov    %ebx,%ecx
  8021bb:	d3 e8                	shr    %cl,%eax
  8021bd:	09 c2                	or     %eax,%edx
  8021bf:	89 d0                	mov    %edx,%eax
  8021c1:	89 ea                	mov    %ebp,%edx
  8021c3:	f7 f6                	div    %esi
  8021c5:	89 d5                	mov    %edx,%ebp
  8021c7:	89 c3                	mov    %eax,%ebx
  8021c9:	f7 64 24 0c          	mull   0xc(%esp)
  8021cd:	39 d5                	cmp    %edx,%ebp
  8021cf:	72 10                	jb     8021e1 <__udivdi3+0xc1>
  8021d1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8021d5:	89 f9                	mov    %edi,%ecx
  8021d7:	d3 e6                	shl    %cl,%esi
  8021d9:	39 c6                	cmp    %eax,%esi
  8021db:	73 07                	jae    8021e4 <__udivdi3+0xc4>
  8021dd:	39 d5                	cmp    %edx,%ebp
  8021df:	75 03                	jne    8021e4 <__udivdi3+0xc4>
  8021e1:	83 eb 01             	sub    $0x1,%ebx
  8021e4:	31 ff                	xor    %edi,%edi
  8021e6:	89 d8                	mov    %ebx,%eax
  8021e8:	89 fa                	mov    %edi,%edx
  8021ea:	83 c4 1c             	add    $0x1c,%esp
  8021ed:	5b                   	pop    %ebx
  8021ee:	5e                   	pop    %esi
  8021ef:	5f                   	pop    %edi
  8021f0:	5d                   	pop    %ebp
  8021f1:	c3                   	ret    
  8021f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021f8:	31 ff                	xor    %edi,%edi
  8021fa:	31 db                	xor    %ebx,%ebx
  8021fc:	89 d8                	mov    %ebx,%eax
  8021fe:	89 fa                	mov    %edi,%edx
  802200:	83 c4 1c             	add    $0x1c,%esp
  802203:	5b                   	pop    %ebx
  802204:	5e                   	pop    %esi
  802205:	5f                   	pop    %edi
  802206:	5d                   	pop    %ebp
  802207:	c3                   	ret    
  802208:	90                   	nop
  802209:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802210:	89 d8                	mov    %ebx,%eax
  802212:	f7 f7                	div    %edi
  802214:	31 ff                	xor    %edi,%edi
  802216:	89 c3                	mov    %eax,%ebx
  802218:	89 d8                	mov    %ebx,%eax
  80221a:	89 fa                	mov    %edi,%edx
  80221c:	83 c4 1c             	add    $0x1c,%esp
  80221f:	5b                   	pop    %ebx
  802220:	5e                   	pop    %esi
  802221:	5f                   	pop    %edi
  802222:	5d                   	pop    %ebp
  802223:	c3                   	ret    
  802224:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802228:	39 ce                	cmp    %ecx,%esi
  80222a:	72 0c                	jb     802238 <__udivdi3+0x118>
  80222c:	31 db                	xor    %ebx,%ebx
  80222e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802232:	0f 87 34 ff ff ff    	ja     80216c <__udivdi3+0x4c>
  802238:	bb 01 00 00 00       	mov    $0x1,%ebx
  80223d:	e9 2a ff ff ff       	jmp    80216c <__udivdi3+0x4c>
  802242:	66 90                	xchg   %ax,%ax
  802244:	66 90                	xchg   %ax,%ax
  802246:	66 90                	xchg   %ax,%ax
  802248:	66 90                	xchg   %ax,%ax
  80224a:	66 90                	xchg   %ax,%ax
  80224c:	66 90                	xchg   %ax,%ax
  80224e:	66 90                	xchg   %ax,%ax

00802250 <__umoddi3>:
  802250:	55                   	push   %ebp
  802251:	57                   	push   %edi
  802252:	56                   	push   %esi
  802253:	53                   	push   %ebx
  802254:	83 ec 1c             	sub    $0x1c,%esp
  802257:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80225b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80225f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802263:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802267:	85 d2                	test   %edx,%edx
  802269:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80226d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802271:	89 f3                	mov    %esi,%ebx
  802273:	89 3c 24             	mov    %edi,(%esp)
  802276:	89 74 24 04          	mov    %esi,0x4(%esp)
  80227a:	75 1c                	jne    802298 <__umoddi3+0x48>
  80227c:	39 f7                	cmp    %esi,%edi
  80227e:	76 50                	jbe    8022d0 <__umoddi3+0x80>
  802280:	89 c8                	mov    %ecx,%eax
  802282:	89 f2                	mov    %esi,%edx
  802284:	f7 f7                	div    %edi
  802286:	89 d0                	mov    %edx,%eax
  802288:	31 d2                	xor    %edx,%edx
  80228a:	83 c4 1c             	add    $0x1c,%esp
  80228d:	5b                   	pop    %ebx
  80228e:	5e                   	pop    %esi
  80228f:	5f                   	pop    %edi
  802290:	5d                   	pop    %ebp
  802291:	c3                   	ret    
  802292:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802298:	39 f2                	cmp    %esi,%edx
  80229a:	89 d0                	mov    %edx,%eax
  80229c:	77 52                	ja     8022f0 <__umoddi3+0xa0>
  80229e:	0f bd ea             	bsr    %edx,%ebp
  8022a1:	83 f5 1f             	xor    $0x1f,%ebp
  8022a4:	75 5a                	jne    802300 <__umoddi3+0xb0>
  8022a6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8022aa:	0f 82 e0 00 00 00    	jb     802390 <__umoddi3+0x140>
  8022b0:	39 0c 24             	cmp    %ecx,(%esp)
  8022b3:	0f 86 d7 00 00 00    	jbe    802390 <__umoddi3+0x140>
  8022b9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8022bd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8022c1:	83 c4 1c             	add    $0x1c,%esp
  8022c4:	5b                   	pop    %ebx
  8022c5:	5e                   	pop    %esi
  8022c6:	5f                   	pop    %edi
  8022c7:	5d                   	pop    %ebp
  8022c8:	c3                   	ret    
  8022c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022d0:	85 ff                	test   %edi,%edi
  8022d2:	89 fd                	mov    %edi,%ebp
  8022d4:	75 0b                	jne    8022e1 <__umoddi3+0x91>
  8022d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8022db:	31 d2                	xor    %edx,%edx
  8022dd:	f7 f7                	div    %edi
  8022df:	89 c5                	mov    %eax,%ebp
  8022e1:	89 f0                	mov    %esi,%eax
  8022e3:	31 d2                	xor    %edx,%edx
  8022e5:	f7 f5                	div    %ebp
  8022e7:	89 c8                	mov    %ecx,%eax
  8022e9:	f7 f5                	div    %ebp
  8022eb:	89 d0                	mov    %edx,%eax
  8022ed:	eb 99                	jmp    802288 <__umoddi3+0x38>
  8022ef:	90                   	nop
  8022f0:	89 c8                	mov    %ecx,%eax
  8022f2:	89 f2                	mov    %esi,%edx
  8022f4:	83 c4 1c             	add    $0x1c,%esp
  8022f7:	5b                   	pop    %ebx
  8022f8:	5e                   	pop    %esi
  8022f9:	5f                   	pop    %edi
  8022fa:	5d                   	pop    %ebp
  8022fb:	c3                   	ret    
  8022fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802300:	8b 34 24             	mov    (%esp),%esi
  802303:	bf 20 00 00 00       	mov    $0x20,%edi
  802308:	89 e9                	mov    %ebp,%ecx
  80230a:	29 ef                	sub    %ebp,%edi
  80230c:	d3 e0                	shl    %cl,%eax
  80230e:	89 f9                	mov    %edi,%ecx
  802310:	89 f2                	mov    %esi,%edx
  802312:	d3 ea                	shr    %cl,%edx
  802314:	89 e9                	mov    %ebp,%ecx
  802316:	09 c2                	or     %eax,%edx
  802318:	89 d8                	mov    %ebx,%eax
  80231a:	89 14 24             	mov    %edx,(%esp)
  80231d:	89 f2                	mov    %esi,%edx
  80231f:	d3 e2                	shl    %cl,%edx
  802321:	89 f9                	mov    %edi,%ecx
  802323:	89 54 24 04          	mov    %edx,0x4(%esp)
  802327:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80232b:	d3 e8                	shr    %cl,%eax
  80232d:	89 e9                	mov    %ebp,%ecx
  80232f:	89 c6                	mov    %eax,%esi
  802331:	d3 e3                	shl    %cl,%ebx
  802333:	89 f9                	mov    %edi,%ecx
  802335:	89 d0                	mov    %edx,%eax
  802337:	d3 e8                	shr    %cl,%eax
  802339:	89 e9                	mov    %ebp,%ecx
  80233b:	09 d8                	or     %ebx,%eax
  80233d:	89 d3                	mov    %edx,%ebx
  80233f:	89 f2                	mov    %esi,%edx
  802341:	f7 34 24             	divl   (%esp)
  802344:	89 d6                	mov    %edx,%esi
  802346:	d3 e3                	shl    %cl,%ebx
  802348:	f7 64 24 04          	mull   0x4(%esp)
  80234c:	39 d6                	cmp    %edx,%esi
  80234e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802352:	89 d1                	mov    %edx,%ecx
  802354:	89 c3                	mov    %eax,%ebx
  802356:	72 08                	jb     802360 <__umoddi3+0x110>
  802358:	75 11                	jne    80236b <__umoddi3+0x11b>
  80235a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80235e:	73 0b                	jae    80236b <__umoddi3+0x11b>
  802360:	2b 44 24 04          	sub    0x4(%esp),%eax
  802364:	1b 14 24             	sbb    (%esp),%edx
  802367:	89 d1                	mov    %edx,%ecx
  802369:	89 c3                	mov    %eax,%ebx
  80236b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80236f:	29 da                	sub    %ebx,%edx
  802371:	19 ce                	sbb    %ecx,%esi
  802373:	89 f9                	mov    %edi,%ecx
  802375:	89 f0                	mov    %esi,%eax
  802377:	d3 e0                	shl    %cl,%eax
  802379:	89 e9                	mov    %ebp,%ecx
  80237b:	d3 ea                	shr    %cl,%edx
  80237d:	89 e9                	mov    %ebp,%ecx
  80237f:	d3 ee                	shr    %cl,%esi
  802381:	09 d0                	or     %edx,%eax
  802383:	89 f2                	mov    %esi,%edx
  802385:	83 c4 1c             	add    $0x1c,%esp
  802388:	5b                   	pop    %ebx
  802389:	5e                   	pop    %esi
  80238a:	5f                   	pop    %edi
  80238b:	5d                   	pop    %ebp
  80238c:	c3                   	ret    
  80238d:	8d 76 00             	lea    0x0(%esi),%esi
  802390:	29 f9                	sub    %edi,%ecx
  802392:	19 d6                	sbb    %edx,%esi
  802394:	89 74 24 04          	mov    %esi,0x4(%esp)
  802398:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80239c:	e9 18 ff ff ff       	jmp    8022b9 <__umoddi3+0x69>
