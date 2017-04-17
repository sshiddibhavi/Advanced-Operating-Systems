
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
  80003b:	c7 05 04 30 80 00 40 	movl   $0x802840,0x803004
  800042:	28 80 00 

	if ((i = pipe(p)) < 0)
  800045:	8d 45 8c             	lea    -0x74(%ebp),%eax
  800048:	50                   	push   %eax
  800049:	e8 4f 20 00 00       	call   80209d <pipe>
  80004e:	89 c6                	mov    %eax,%esi
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	85 c0                	test   %eax,%eax
  800055:	79 12                	jns    800069 <umain+0x36>
		panic("pipe: %e", i);
  800057:	50                   	push   %eax
  800058:	68 4c 28 80 00       	push   $0x80284c
  80005d:	6a 0e                	push   $0xe
  80005f:	68 55 28 80 00       	push   $0x802855
  800064:	e8 a9 02 00 00       	call   800312 <_panic>

	if ((pid = fork()) < 0)
  800069:	e8 c9 10 00 00       	call   801137 <fork>
  80006e:	89 c3                	mov    %eax,%ebx
  800070:	85 c0                	test   %eax,%eax
  800072:	79 12                	jns    800086 <umain+0x53>
		panic("fork: %e", i);
  800074:	56                   	push   %esi
  800075:	68 33 2d 80 00       	push   $0x802d33
  80007a:	6a 11                	push   $0x11
  80007c:	68 55 28 80 00       	push   $0x802855
  800081:	e8 8c 02 00 00       	call   800312 <_panic>

	if (pid == 0) {
  800086:	85 c0                	test   %eax,%eax
  800088:	0f 85 b8 00 00 00    	jne    800146 <umain+0x113>
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[1]);
  80008e:	a1 08 40 80 00       	mov    0x804008,%eax
  800093:	8b 40 48             	mov    0x48(%eax),%eax
  800096:	83 ec 04             	sub    $0x4,%esp
  800099:	ff 75 90             	pushl  -0x70(%ebp)
  80009c:	50                   	push   %eax
  80009d:	68 65 28 80 00       	push   $0x802865
  8000a2:	e8 44 03 00 00       	call   8003eb <cprintf>
		close(p[1]);
  8000a7:	83 c4 04             	add    $0x4,%esp
  8000aa:	ff 75 90             	pushl  -0x70(%ebp)
  8000ad:	e8 1a 13 00 00       	call   8013cc <close>
		cprintf("[%08x] pipereadeof readn %d\n", thisenv->env_id, p[0]);
  8000b2:	a1 08 40 80 00       	mov    0x804008,%eax
  8000b7:	8b 40 48             	mov    0x48(%eax),%eax
  8000ba:	83 c4 0c             	add    $0xc,%esp
  8000bd:	ff 75 8c             	pushl  -0x74(%ebp)
  8000c0:	50                   	push   %eax
  8000c1:	68 82 28 80 00       	push   $0x802882
  8000c6:	e8 20 03 00 00       	call   8003eb <cprintf>
		i = readn(p[0], buf, sizeof buf-1);
  8000cb:	83 c4 0c             	add    $0xc,%esp
  8000ce:	6a 63                	push   $0x63
  8000d0:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8000d3:	50                   	push   %eax
  8000d4:	ff 75 8c             	pushl  -0x74(%ebp)
  8000d7:	e8 bd 14 00 00       	call   801599 <readn>
  8000dc:	89 c6                	mov    %eax,%esi
		if (i < 0)
  8000de:	83 c4 10             	add    $0x10,%esp
  8000e1:	85 c0                	test   %eax,%eax
  8000e3:	79 12                	jns    8000f7 <umain+0xc4>
			panic("read: %e", i);
  8000e5:	50                   	push   %eax
  8000e6:	68 9f 28 80 00       	push   $0x80289f
  8000eb:	6a 19                	push   $0x19
  8000ed:	68 55 28 80 00       	push   $0x802855
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
  800118:	68 a8 28 80 00       	push   $0x8028a8
  80011d:	e8 c9 02 00 00       	call   8003eb <cprintf>
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	eb 15                	jmp    80013c <umain+0x109>
		else
			cprintf("\ngot %d bytes: %s\n", i, buf);
  800127:	83 ec 04             	sub    $0x4,%esp
  80012a:	8d 45 94             	lea    -0x6c(%ebp),%eax
  80012d:	50                   	push   %eax
  80012e:	56                   	push   %esi
  80012f:	68 c4 28 80 00       	push   $0x8028c4
  800134:	e8 b2 02 00 00       	call   8003eb <cprintf>
  800139:	83 c4 10             	add    $0x10,%esp
		exit();
  80013c:	e8 b7 01 00 00       	call   8002f8 <exit>
  800141:	e9 94 00 00 00       	jmp    8001da <umain+0x1a7>
	} else {
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[0]);
  800146:	a1 08 40 80 00       	mov    0x804008,%eax
  80014b:	8b 40 48             	mov    0x48(%eax),%eax
  80014e:	83 ec 04             	sub    $0x4,%esp
  800151:	ff 75 8c             	pushl  -0x74(%ebp)
  800154:	50                   	push   %eax
  800155:	68 65 28 80 00       	push   $0x802865
  80015a:	e8 8c 02 00 00       	call   8003eb <cprintf>
		close(p[0]);
  80015f:	83 c4 04             	add    $0x4,%esp
  800162:	ff 75 8c             	pushl  -0x74(%ebp)
  800165:	e8 62 12 00 00       	call   8013cc <close>
		cprintf("[%08x] pipereadeof write %d\n", thisenv->env_id, p[1]);
  80016a:	a1 08 40 80 00       	mov    0x804008,%eax
  80016f:	8b 40 48             	mov    0x48(%eax),%eax
  800172:	83 c4 0c             	add    $0xc,%esp
  800175:	ff 75 90             	pushl  -0x70(%ebp)
  800178:	50                   	push   %eax
  800179:	68 d7 28 80 00       	push   $0x8028d7
  80017e:	e8 68 02 00 00       	call   8003eb <cprintf>
		if ((i = write(p[1], msg, strlen(msg))) != strlen(msg))
  800183:	83 c4 04             	add    $0x4,%esp
  800186:	ff 35 00 30 80 00    	pushl  0x803000
  80018c:	e8 a6 07 00 00       	call   800937 <strlen>
  800191:	83 c4 0c             	add    $0xc,%esp
  800194:	50                   	push   %eax
  800195:	ff 35 00 30 80 00    	pushl  0x803000
  80019b:	ff 75 90             	pushl  -0x70(%ebp)
  80019e:	e8 3f 14 00 00       	call   8015e2 <write>
  8001a3:	89 c6                	mov    %eax,%esi
  8001a5:	83 c4 04             	add    $0x4,%esp
  8001a8:	ff 35 00 30 80 00    	pushl  0x803000
  8001ae:	e8 84 07 00 00       	call   800937 <strlen>
  8001b3:	83 c4 10             	add    $0x10,%esp
  8001b6:	39 c6                	cmp    %eax,%esi
  8001b8:	74 12                	je     8001cc <umain+0x199>
			panic("write: %e", i);
  8001ba:	56                   	push   %esi
  8001bb:	68 f4 28 80 00       	push   $0x8028f4
  8001c0:	6a 25                	push   $0x25
  8001c2:	68 55 28 80 00       	push   $0x802855
  8001c7:	e8 46 01 00 00       	call   800312 <_panic>
		close(p[1]);
  8001cc:	83 ec 0c             	sub    $0xc,%esp
  8001cf:	ff 75 90             	pushl  -0x70(%ebp)
  8001d2:	e8 f5 11 00 00       	call   8013cc <close>
  8001d7:	83 c4 10             	add    $0x10,%esp
	}
	wait(pid);
  8001da:	83 ec 0c             	sub    $0xc,%esp
  8001dd:	53                   	push   %ebx
  8001de:	e8 40 20 00 00       	call   802223 <wait>

	binaryname = "pipewriteeof";
  8001e3:	c7 05 04 30 80 00 fe 	movl   $0x8028fe,0x803004
  8001ea:	28 80 00 
	if ((i = pipe(p)) < 0)
  8001ed:	8d 45 8c             	lea    -0x74(%ebp),%eax
  8001f0:	89 04 24             	mov    %eax,(%esp)
  8001f3:	e8 a5 1e 00 00       	call   80209d <pipe>
  8001f8:	89 c6                	mov    %eax,%esi
  8001fa:	83 c4 10             	add    $0x10,%esp
  8001fd:	85 c0                	test   %eax,%eax
  8001ff:	79 12                	jns    800213 <umain+0x1e0>
		panic("pipe: %e", i);
  800201:	50                   	push   %eax
  800202:	68 4c 28 80 00       	push   $0x80284c
  800207:	6a 2c                	push   $0x2c
  800209:	68 55 28 80 00       	push   $0x802855
  80020e:	e8 ff 00 00 00       	call   800312 <_panic>

	if ((pid = fork()) < 0)
  800213:	e8 1f 0f 00 00       	call   801137 <fork>
  800218:	89 c3                	mov    %eax,%ebx
  80021a:	85 c0                	test   %eax,%eax
  80021c:	79 12                	jns    800230 <umain+0x1fd>
		panic("fork: %e", i);
  80021e:	56                   	push   %esi
  80021f:	68 33 2d 80 00       	push   $0x802d33
  800224:	6a 2f                	push   $0x2f
  800226:	68 55 28 80 00       	push   $0x802855
  80022b:	e8 e2 00 00 00       	call   800312 <_panic>

	if (pid == 0) {
  800230:	85 c0                	test   %eax,%eax
  800232:	75 4a                	jne    80027e <umain+0x24b>
		close(p[0]);
  800234:	83 ec 0c             	sub    $0xc,%esp
  800237:	ff 75 8c             	pushl  -0x74(%ebp)
  80023a:	e8 8d 11 00 00       	call   8013cc <close>
  80023f:	83 c4 10             	add    $0x10,%esp
		while (1) {
			cprintf(".");
  800242:	83 ec 0c             	sub    $0xc,%esp
  800245:	68 0b 29 80 00       	push   $0x80290b
  80024a:	e8 9c 01 00 00       	call   8003eb <cprintf>
			if (write(p[1], "x", 1) != 1)
  80024f:	83 c4 0c             	add    $0xc,%esp
  800252:	6a 01                	push   $0x1
  800254:	68 0d 29 80 00       	push   $0x80290d
  800259:	ff 75 90             	pushl  -0x70(%ebp)
  80025c:	e8 81 13 00 00       	call   8015e2 <write>
  800261:	83 c4 10             	add    $0x10,%esp
  800264:	83 f8 01             	cmp    $0x1,%eax
  800267:	74 d9                	je     800242 <umain+0x20f>
				break;
		}
		cprintf("\npipe write closed properly\n");
  800269:	83 ec 0c             	sub    $0xc,%esp
  80026c:	68 0f 29 80 00       	push   $0x80290f
  800271:	e8 75 01 00 00       	call   8003eb <cprintf>
		exit();
  800276:	e8 7d 00 00 00       	call   8002f8 <exit>
  80027b:	83 c4 10             	add    $0x10,%esp
	}
	close(p[0]);
  80027e:	83 ec 0c             	sub    $0xc,%esp
  800281:	ff 75 8c             	pushl  -0x74(%ebp)
  800284:	e8 43 11 00 00       	call   8013cc <close>
	close(p[1]);
  800289:	83 c4 04             	add    $0x4,%esp
  80028c:	ff 75 90             	pushl  -0x70(%ebp)
  80028f:	e8 38 11 00 00       	call   8013cc <close>
	wait(pid);
  800294:	89 1c 24             	mov    %ebx,(%esp)
  800297:	e8 87 1f 00 00       	call   802223 <wait>

	cprintf("pipe tests passed\n");
  80029c:	c7 04 24 2c 29 80 00 	movl   $0x80292c,(%esp)
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
  8002cf:	a3 08 40 80 00       	mov    %eax,0x804008

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
  8002fe:	e8 f4 10 00 00       	call   8013f7 <close_all>
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
  800330:	68 90 29 80 00       	push   $0x802990
  800335:	e8 b1 00 00 00       	call   8003eb <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80033a:	83 c4 18             	add    $0x18,%esp
  80033d:	53                   	push   %ebx
  80033e:	ff 75 10             	pushl  0x10(%ebp)
  800341:	e8 54 00 00 00       	call   80039a <vcprintf>
	cprintf("\n");
  800346:	c7 04 24 80 28 80 00 	movl   $0x802880,(%esp)
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
  80044e:	e8 4d 21 00 00       	call   8025a0 <__udivdi3>
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
  800491:	e8 3a 22 00 00       	call   8026d0 <__umoddi3>
  800496:	83 c4 14             	add    $0x14,%esp
  800499:	0f be 80 b3 29 80 00 	movsbl 0x8029b3(%eax),%eax
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
  800595:	ff 24 85 00 2b 80 00 	jmp    *0x802b00(,%eax,4)
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
  800659:	8b 14 85 60 2c 80 00 	mov    0x802c60(,%eax,4),%edx
  800660:	85 d2                	test   %edx,%edx
  800662:	75 18                	jne    80067c <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800664:	50                   	push   %eax
  800665:	68 cb 29 80 00       	push   $0x8029cb
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
  80067d:	68 1e 2e 80 00       	push   $0x802e1e
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
  8006a1:	b8 c4 29 80 00       	mov    $0x8029c4,%eax
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
  800d1c:	68 bf 2c 80 00       	push   $0x802cbf
  800d21:	6a 23                	push   $0x23
  800d23:	68 dc 2c 80 00       	push   $0x802cdc
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
  800d9d:	68 bf 2c 80 00       	push   $0x802cbf
  800da2:	6a 23                	push   $0x23
  800da4:	68 dc 2c 80 00       	push   $0x802cdc
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
  800ddf:	68 bf 2c 80 00       	push   $0x802cbf
  800de4:	6a 23                	push   $0x23
  800de6:	68 dc 2c 80 00       	push   $0x802cdc
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
  800e21:	68 bf 2c 80 00       	push   $0x802cbf
  800e26:	6a 23                	push   $0x23
  800e28:	68 dc 2c 80 00       	push   $0x802cdc
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
  800e63:	68 bf 2c 80 00       	push   $0x802cbf
  800e68:	6a 23                	push   $0x23
  800e6a:	68 dc 2c 80 00       	push   $0x802cdc
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
  800ea5:	68 bf 2c 80 00       	push   $0x802cbf
  800eaa:	6a 23                	push   $0x23
  800eac:	68 dc 2c 80 00       	push   $0x802cdc
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
  800ee7:	68 bf 2c 80 00       	push   $0x802cbf
  800eec:	6a 23                	push   $0x23
  800eee:	68 dc 2c 80 00       	push   $0x802cdc
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
  800f4b:	68 bf 2c 80 00       	push   $0x802cbf
  800f50:	6a 23                	push   $0x23
  800f52:	68 dc 2c 80 00       	push   $0x802cdc
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

00800f64 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800f64:	55                   	push   %ebp
  800f65:	89 e5                	mov    %esp,%ebp
  800f67:	57                   	push   %edi
  800f68:	56                   	push   %esi
  800f69:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f6a:	ba 00 00 00 00       	mov    $0x0,%edx
  800f6f:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f74:	89 d1                	mov    %edx,%ecx
  800f76:	89 d3                	mov    %edx,%ebx
  800f78:	89 d7                	mov    %edx,%edi
  800f7a:	89 d6                	mov    %edx,%esi
  800f7c:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800f7e:	5b                   	pop    %ebx
  800f7f:	5e                   	pop    %esi
  800f80:	5f                   	pop    %edi
  800f81:	5d                   	pop    %ebp
  800f82:	c3                   	ret    

00800f83 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800f83:	55                   	push   %ebp
  800f84:	89 e5                	mov    %esp,%ebp
  800f86:	53                   	push   %ebx
  800f87:	83 ec 04             	sub    $0x4,%esp
	int r;
	void * address = (void *)(pn*PGSIZE);
  800f8a:	89 d3                	mov    %edx,%ebx
  800f8c:	c1 e3 0c             	shl    $0xc,%ebx
	
	if((uvpt[pn] & PTE_SHARE))
  800f8f:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800f96:	f6 c5 04             	test   $0x4,%ch
  800f99:	74 38                	je     800fd3 <duppage+0x50>
	{
		if ((r = sys_page_map(0, address, envid, address, (uvpt[pn] | PTE_SYSCALL))) < 0)
  800f9b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fa2:	83 ec 0c             	sub    $0xc,%esp
  800fa5:	81 ca 07 0e 00 00    	or     $0xe07,%edx
  800fab:	52                   	push   %edx
  800fac:	53                   	push   %ebx
  800fad:	50                   	push   %eax
  800fae:	53                   	push   %ebx
  800faf:	6a 00                	push   $0x0
  800fb1:	e8 00 fe ff ff       	call   800db6 <sys_page_map>
  800fb6:	83 c4 20             	add    $0x20,%esp
  800fb9:	85 c0                	test   %eax,%eax
  800fbb:	0f 89 b8 00 00 00    	jns    801079 <duppage+0xf6>
			panic("sys_page_map: %e", r);
  800fc1:	50                   	push   %eax
  800fc2:	68 ea 2c 80 00       	push   $0x802cea
  800fc7:	6a 4e                	push   $0x4e
  800fc9:	68 fb 2c 80 00       	push   $0x802cfb
  800fce:	e8 3f f3 ff ff       	call   800312 <_panic>
	}
	else if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW))
  800fd3:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800fda:	f6 c1 02             	test   $0x2,%cl
  800fdd:	75 0c                	jne    800feb <duppage+0x68>
  800fdf:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800fe6:	f6 c5 08             	test   $0x8,%ch
  800fe9:	74 57                	je     801042 <duppage+0xbf>
	{
		int perm = 0;
		perm |= PTE_P|PTE_U|PTE_COW;
	
		if ((r = sys_page_map(0, address, envid, address, perm)) < 0)
  800feb:	83 ec 0c             	sub    $0xc,%esp
  800fee:	68 05 08 00 00       	push   $0x805
  800ff3:	53                   	push   %ebx
  800ff4:	50                   	push   %eax
  800ff5:	53                   	push   %ebx
  800ff6:	6a 00                	push   $0x0
  800ff8:	e8 b9 fd ff ff       	call   800db6 <sys_page_map>
  800ffd:	83 c4 20             	add    $0x20,%esp
  801000:	85 c0                	test   %eax,%eax
  801002:	79 12                	jns    801016 <duppage+0x93>
			panic("sys_page_map: %e", r);
  801004:	50                   	push   %eax
  801005:	68 ea 2c 80 00       	push   $0x802cea
  80100a:	6a 56                	push   $0x56
  80100c:	68 fb 2c 80 00       	push   $0x802cfb
  801011:	e8 fc f2 ff ff       	call   800312 <_panic>
		if ((r = sys_page_map(0, address, 0, address, perm)) < 0)
  801016:	83 ec 0c             	sub    $0xc,%esp
  801019:	68 05 08 00 00       	push   $0x805
  80101e:	53                   	push   %ebx
  80101f:	6a 00                	push   $0x0
  801021:	53                   	push   %ebx
  801022:	6a 00                	push   $0x0
  801024:	e8 8d fd ff ff       	call   800db6 <sys_page_map>
  801029:	83 c4 20             	add    $0x20,%esp
  80102c:	85 c0                	test   %eax,%eax
  80102e:	79 49                	jns    801079 <duppage+0xf6>
			panic("sys_page_map: %e", r);
  801030:	50                   	push   %eax
  801031:	68 ea 2c 80 00       	push   $0x802cea
  801036:	6a 58                	push   $0x58
  801038:	68 fb 2c 80 00       	push   $0x802cfb
  80103d:	e8 d0 f2 ff ff       	call   800312 <_panic>
	}
	else if((uvpt[pn] & ~PTE_U) == 0)
  801042:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801049:	f7 c2 fb ff ff ff    	test   $0xfffffffb,%edx
  80104f:	75 28                	jne    801079 <duppage+0xf6>
	{
		//cprintf("im here");
		if ((r = sys_page_map(0, address, envid, address, PTE_P|PTE_U)) < 0)
  801051:	83 ec 0c             	sub    $0xc,%esp
  801054:	6a 05                	push   $0x5
  801056:	53                   	push   %ebx
  801057:	50                   	push   %eax
  801058:	53                   	push   %ebx
  801059:	6a 00                	push   $0x0
  80105b:	e8 56 fd ff ff       	call   800db6 <sys_page_map>
  801060:	83 c4 20             	add    $0x20,%esp
  801063:	85 c0                	test   %eax,%eax
  801065:	79 12                	jns    801079 <duppage+0xf6>
			panic("sys_page_map: %e", r);	
  801067:	50                   	push   %eax
  801068:	68 ea 2c 80 00       	push   $0x802cea
  80106d:	6a 5e                	push   $0x5e
  80106f:	68 fb 2c 80 00       	push   $0x802cfb
  801074:	e8 99 f2 ff ff       	call   800312 <_panic>
	}
	return 0;
}
  801079:	b8 00 00 00 00       	mov    $0x0,%eax
  80107e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801081:	c9                   	leave  
  801082:	c3                   	ret    

00801083 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801083:	55                   	push   %ebp
  801084:	89 e5                	mov    %esp,%ebp
  801086:	53                   	push   %ebx
  801087:	83 ec 08             	sub    $0x8,%esp
	void *addr = (void *) utf->utf_fault_va;
  80108a:	8b 45 08             	mov    0x8(%ebp),%eax
  80108d:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	unsigned pn = ((uint32_t)addr)/PGSIZE;
  80108f:	89 d8                	mov    %ebx,%eax
  801091:	c1 e8 0c             	shr    $0xc,%eax
	pte_t pte = uvpt[pn];
  801094:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// Allocate a new page, mapped at temp location
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  80109b:	6a 07                	push   $0x7
  80109d:	68 00 f0 7f 00       	push   $0x7ff000
  8010a2:	6a 00                	push   $0x0
  8010a4:	e8 ca fc ff ff       	call   800d73 <sys_page_alloc>
  8010a9:	83 c4 10             	add    $0x10,%esp
  8010ac:	85 c0                	test   %eax,%eax
  8010ae:	79 12                	jns    8010c2 <pgfault+0x3f>
		panic("sys_page_alloc: %e", r);
  8010b0:	50                   	push   %eax
  8010b1:	68 06 2d 80 00       	push   $0x802d06
  8010b6:	6a 2b                	push   $0x2b
  8010b8:	68 fb 2c 80 00       	push   $0x802cfb
  8010bd:	e8 50 f2 ff ff       	call   800312 <_panic>

	// Copy the data from the old page to this new page
	void *addr_pgstart = (void *) ROUNDDOWN(addr, PGSIZE);
  8010c2:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr_pgstart, PGSIZE);
  8010c8:	83 ec 04             	sub    $0x4,%esp
  8010cb:	68 00 10 00 00       	push   $0x1000
  8010d0:	53                   	push   %ebx
  8010d1:	68 00 f0 7f 00       	push   $0x7ff000
  8010d6:	e8 27 fa ff ff       	call   800b02 <memmove>

	// Move the new page to the old page's address
	if ((r = sys_page_map(0, PFTEMP, 0, addr_pgstart, PTE_P|PTE_U|PTE_W)) < 0)
  8010db:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  8010e2:	53                   	push   %ebx
  8010e3:	6a 00                	push   $0x0
  8010e5:	68 00 f0 7f 00       	push   $0x7ff000
  8010ea:	6a 00                	push   $0x0
  8010ec:	e8 c5 fc ff ff       	call   800db6 <sys_page_map>
  8010f1:	83 c4 20             	add    $0x20,%esp
  8010f4:	85 c0                	test   %eax,%eax
  8010f6:	79 12                	jns    80110a <pgfault+0x87>
		panic("sys_page_map: %e", r);
  8010f8:	50                   	push   %eax
  8010f9:	68 ea 2c 80 00       	push   $0x802cea
  8010fe:	6a 33                	push   $0x33
  801100:	68 fb 2c 80 00       	push   $0x802cfb
  801105:	e8 08 f2 ff ff       	call   800312 <_panic>

	// Unmap the temp location
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  80110a:	83 ec 08             	sub    $0x8,%esp
  80110d:	68 00 f0 7f 00       	push   $0x7ff000
  801112:	6a 00                	push   $0x0
  801114:	e8 df fc ff ff       	call   800df8 <sys_page_unmap>
  801119:	83 c4 10             	add    $0x10,%esp
  80111c:	85 c0                	test   %eax,%eax
  80111e:	79 12                	jns    801132 <pgfault+0xaf>
		panic("sys_page_unmap: %e", r);
  801120:	50                   	push   %eax
  801121:	68 19 2d 80 00       	push   $0x802d19
  801126:	6a 37                	push   $0x37
  801128:	68 fb 2c 80 00       	push   $0x802cfb
  80112d:	e8 e0 f1 ff ff       	call   800312 <_panic>
}
  801132:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801135:	c9                   	leave  
  801136:	c3                   	ret    

00801137 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801137:	55                   	push   %ebp
  801138:	89 e5                	mov    %esp,%ebp
  80113a:	56                   	push   %esi
  80113b:	53                   	push   %ebx
  80113c:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
	// Set up page fault handler
	set_pgfault_handler(&pgfault);
  80113f:	68 83 10 80 00       	push   $0x801083
  801144:	e8 ac 12 00 00       	call   8023f5 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801149:	b8 07 00 00 00       	mov    $0x7,%eax
  80114e:	cd 30                	int    $0x30

	// Create child
	envid_t envid = sys_exofork();
  801150:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (envid < 0) {
  801153:	83 c4 10             	add    $0x10,%esp
  801156:	85 c0                	test   %eax,%eax
  801158:	79 12                	jns    80116c <fork+0x35>
		panic("sys_exofork: %e", envid);
  80115a:	50                   	push   %eax
  80115b:	68 2c 2d 80 00       	push   $0x802d2c
  801160:	6a 7c                	push   $0x7c
  801162:	68 fb 2c 80 00       	push   $0x802cfb
  801167:	e8 a6 f1 ff ff       	call   800312 <_panic>
		return envid;
	}
	if (envid == 0) {
  80116c:	85 c0                	test   %eax,%eax
  80116e:	75 1e                	jne    80118e <fork+0x57>
		// We are the child.
		thisenv = &envs[ENVX(sys_getenvid())]; // Fix thisenv
  801170:	e8 c0 fb ff ff       	call   800d35 <sys_getenvid>
  801175:	25 ff 03 00 00       	and    $0x3ff,%eax
  80117a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80117d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801182:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  801187:	b8 00 00 00 00       	mov    $0x0,%eax
  80118c:	eb 7d                	jmp    80120b <fork+0xd4>

	// Set page fault handler on the child.
	// The parent needs to do it, else the child wouldn't be able to handle
	// the fault when trying to access it's stack (which happens as soon it starts)
	extern void _pgfault_upcall(void);
	sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);
  80118e:	83 ec 04             	sub    $0x4,%esp
  801191:	6a 07                	push   $0x7
  801193:	68 00 f0 bf ee       	push   $0xeebff000
  801198:	50                   	push   %eax
  801199:	e8 d5 fb ff ff       	call   800d73 <sys_page_alloc>
	sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  80119e:	83 c4 08             	add    $0x8,%esp
  8011a1:	68 3a 24 80 00       	push   $0x80243a
  8011a6:	ff 75 f4             	pushl  -0xc(%ebp)
  8011a9:	e8 10 fd ff ff       	call   800ebe <sys_env_set_pgfault_upcall>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  8011ae:	be 04 70 80 00       	mov    $0x807004,%esi
  8011b3:	c1 ee 0c             	shr    $0xc,%esi
  8011b6:	83 c4 10             	add    $0x10,%esp
  8011b9:	bb 00 08 00 00       	mov    $0x800,%ebx
  8011be:	eb 0d                	jmp    8011cd <fork+0x96>
		duppage(envid, pn);
  8011c0:	89 da                	mov    %ebx,%edx
  8011c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011c5:	e8 b9 fd ff ff       	call   800f83 <duppage>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  8011ca:	83 c3 01             	add    $0x1,%ebx
  8011cd:	39 f3                	cmp    %esi,%ebx
  8011cf:	76 ef                	jbe    8011c0 <fork+0x89>
	}

	// Also copy the stack we are currently running on
	// I think it should loop from ustacktop to this page, since the stack
	// can have more than 1 page
	duppage(envid, ((uint32_t) &envid)/PGSIZE);
  8011d1:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8011d4:	c1 ea 0c             	shr    $0xc,%edx
  8011d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011da:	e8 a4 fd ff ff       	call   800f83 <duppage>

	// Start the child environmnet running
	int r;
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  8011df:	83 ec 08             	sub    $0x8,%esp
  8011e2:	6a 02                	push   $0x2
  8011e4:	ff 75 f4             	pushl  -0xc(%ebp)
  8011e7:	e8 4e fc ff ff       	call   800e3a <sys_env_set_status>
  8011ec:	83 c4 10             	add    $0x10,%esp
  8011ef:	85 c0                	test   %eax,%eax
  8011f1:	79 15                	jns    801208 <fork+0xd1>
		panic("sys_env_set_status: %e", r);
  8011f3:	50                   	push   %eax
  8011f4:	68 3c 2d 80 00       	push   $0x802d3c
  8011f9:	68 9c 00 00 00       	push   $0x9c
  8011fe:	68 fb 2c 80 00       	push   $0x802cfb
  801203:	e8 0a f1 ff ff       	call   800312 <_panic>
		return r;
	}

	return envid;
  801208:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80120b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80120e:	5b                   	pop    %ebx
  80120f:	5e                   	pop    %esi
  801210:	5d                   	pop    %ebp
  801211:	c3                   	ret    

00801212 <sfork>:

// Challenge!
int
sfork(void)
{
  801212:	55                   	push   %ebp
  801213:	89 e5                	mov    %esp,%ebp
  801215:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801218:	68 53 2d 80 00       	push   $0x802d53
  80121d:	68 a7 00 00 00       	push   $0xa7
  801222:	68 fb 2c 80 00       	push   $0x802cfb
  801227:	e8 e6 f0 ff ff       	call   800312 <_panic>

0080122c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80122c:	55                   	push   %ebp
  80122d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80122f:	8b 45 08             	mov    0x8(%ebp),%eax
  801232:	05 00 00 00 30       	add    $0x30000000,%eax
  801237:	c1 e8 0c             	shr    $0xc,%eax
}
  80123a:	5d                   	pop    %ebp
  80123b:	c3                   	ret    

0080123c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80123c:	55                   	push   %ebp
  80123d:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80123f:	8b 45 08             	mov    0x8(%ebp),%eax
  801242:	05 00 00 00 30       	add    $0x30000000,%eax
  801247:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80124c:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801251:	5d                   	pop    %ebp
  801252:	c3                   	ret    

00801253 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801253:	55                   	push   %ebp
  801254:	89 e5                	mov    %esp,%ebp
  801256:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801259:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80125e:	89 c2                	mov    %eax,%edx
  801260:	c1 ea 16             	shr    $0x16,%edx
  801263:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80126a:	f6 c2 01             	test   $0x1,%dl
  80126d:	74 11                	je     801280 <fd_alloc+0x2d>
  80126f:	89 c2                	mov    %eax,%edx
  801271:	c1 ea 0c             	shr    $0xc,%edx
  801274:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80127b:	f6 c2 01             	test   $0x1,%dl
  80127e:	75 09                	jne    801289 <fd_alloc+0x36>
			*fd_store = fd;
  801280:	89 01                	mov    %eax,(%ecx)
			return 0;
  801282:	b8 00 00 00 00       	mov    $0x0,%eax
  801287:	eb 17                	jmp    8012a0 <fd_alloc+0x4d>
  801289:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80128e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801293:	75 c9                	jne    80125e <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801295:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80129b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012a0:	5d                   	pop    %ebp
  8012a1:	c3                   	ret    

008012a2 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012a2:	55                   	push   %ebp
  8012a3:	89 e5                	mov    %esp,%ebp
  8012a5:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012a8:	83 f8 1f             	cmp    $0x1f,%eax
  8012ab:	77 36                	ja     8012e3 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012ad:	c1 e0 0c             	shl    $0xc,%eax
  8012b0:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012b5:	89 c2                	mov    %eax,%edx
  8012b7:	c1 ea 16             	shr    $0x16,%edx
  8012ba:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012c1:	f6 c2 01             	test   $0x1,%dl
  8012c4:	74 24                	je     8012ea <fd_lookup+0x48>
  8012c6:	89 c2                	mov    %eax,%edx
  8012c8:	c1 ea 0c             	shr    $0xc,%edx
  8012cb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012d2:	f6 c2 01             	test   $0x1,%dl
  8012d5:	74 1a                	je     8012f1 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012d7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012da:	89 02                	mov    %eax,(%edx)
	return 0;
  8012dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8012e1:	eb 13                	jmp    8012f6 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012e3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012e8:	eb 0c                	jmp    8012f6 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012ea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012ef:	eb 05                	jmp    8012f6 <fd_lookup+0x54>
  8012f1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012f6:	5d                   	pop    %ebp
  8012f7:	c3                   	ret    

008012f8 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012f8:	55                   	push   %ebp
  8012f9:	89 e5                	mov    %esp,%ebp
  8012fb:	83 ec 08             	sub    $0x8,%esp
  8012fe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801301:	ba ec 2d 80 00       	mov    $0x802dec,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801306:	eb 13                	jmp    80131b <dev_lookup+0x23>
  801308:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80130b:	39 08                	cmp    %ecx,(%eax)
  80130d:	75 0c                	jne    80131b <dev_lookup+0x23>
			*dev = devtab[i];
  80130f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801312:	89 01                	mov    %eax,(%ecx)
			return 0;
  801314:	b8 00 00 00 00       	mov    $0x0,%eax
  801319:	eb 2e                	jmp    801349 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80131b:	8b 02                	mov    (%edx),%eax
  80131d:	85 c0                	test   %eax,%eax
  80131f:	75 e7                	jne    801308 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801321:	a1 08 40 80 00       	mov    0x804008,%eax
  801326:	8b 40 48             	mov    0x48(%eax),%eax
  801329:	83 ec 04             	sub    $0x4,%esp
  80132c:	51                   	push   %ecx
  80132d:	50                   	push   %eax
  80132e:	68 6c 2d 80 00       	push   $0x802d6c
  801333:	e8 b3 f0 ff ff       	call   8003eb <cprintf>
	*dev = 0;
  801338:	8b 45 0c             	mov    0xc(%ebp),%eax
  80133b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801341:	83 c4 10             	add    $0x10,%esp
  801344:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801349:	c9                   	leave  
  80134a:	c3                   	ret    

0080134b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80134b:	55                   	push   %ebp
  80134c:	89 e5                	mov    %esp,%ebp
  80134e:	56                   	push   %esi
  80134f:	53                   	push   %ebx
  801350:	83 ec 10             	sub    $0x10,%esp
  801353:	8b 75 08             	mov    0x8(%ebp),%esi
  801356:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801359:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80135c:	50                   	push   %eax
  80135d:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801363:	c1 e8 0c             	shr    $0xc,%eax
  801366:	50                   	push   %eax
  801367:	e8 36 ff ff ff       	call   8012a2 <fd_lookup>
  80136c:	83 c4 08             	add    $0x8,%esp
  80136f:	85 c0                	test   %eax,%eax
  801371:	78 05                	js     801378 <fd_close+0x2d>
	    || fd != fd2)
  801373:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801376:	74 0c                	je     801384 <fd_close+0x39>
		return (must_exist ? r : 0);
  801378:	84 db                	test   %bl,%bl
  80137a:	ba 00 00 00 00       	mov    $0x0,%edx
  80137f:	0f 44 c2             	cmove  %edx,%eax
  801382:	eb 41                	jmp    8013c5 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801384:	83 ec 08             	sub    $0x8,%esp
  801387:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80138a:	50                   	push   %eax
  80138b:	ff 36                	pushl  (%esi)
  80138d:	e8 66 ff ff ff       	call   8012f8 <dev_lookup>
  801392:	89 c3                	mov    %eax,%ebx
  801394:	83 c4 10             	add    $0x10,%esp
  801397:	85 c0                	test   %eax,%eax
  801399:	78 1a                	js     8013b5 <fd_close+0x6a>
		if (dev->dev_close)
  80139b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80139e:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8013a1:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8013a6:	85 c0                	test   %eax,%eax
  8013a8:	74 0b                	je     8013b5 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8013aa:	83 ec 0c             	sub    $0xc,%esp
  8013ad:	56                   	push   %esi
  8013ae:	ff d0                	call   *%eax
  8013b0:	89 c3                	mov    %eax,%ebx
  8013b2:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013b5:	83 ec 08             	sub    $0x8,%esp
  8013b8:	56                   	push   %esi
  8013b9:	6a 00                	push   $0x0
  8013bb:	e8 38 fa ff ff       	call   800df8 <sys_page_unmap>
	return r;
  8013c0:	83 c4 10             	add    $0x10,%esp
  8013c3:	89 d8                	mov    %ebx,%eax
}
  8013c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013c8:	5b                   	pop    %ebx
  8013c9:	5e                   	pop    %esi
  8013ca:	5d                   	pop    %ebp
  8013cb:	c3                   	ret    

008013cc <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013cc:	55                   	push   %ebp
  8013cd:	89 e5                	mov    %esp,%ebp
  8013cf:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013d5:	50                   	push   %eax
  8013d6:	ff 75 08             	pushl  0x8(%ebp)
  8013d9:	e8 c4 fe ff ff       	call   8012a2 <fd_lookup>
  8013de:	83 c4 08             	add    $0x8,%esp
  8013e1:	85 c0                	test   %eax,%eax
  8013e3:	78 10                	js     8013f5 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8013e5:	83 ec 08             	sub    $0x8,%esp
  8013e8:	6a 01                	push   $0x1
  8013ea:	ff 75 f4             	pushl  -0xc(%ebp)
  8013ed:	e8 59 ff ff ff       	call   80134b <fd_close>
  8013f2:	83 c4 10             	add    $0x10,%esp
}
  8013f5:	c9                   	leave  
  8013f6:	c3                   	ret    

008013f7 <close_all>:

void
close_all(void)
{
  8013f7:	55                   	push   %ebp
  8013f8:	89 e5                	mov    %esp,%ebp
  8013fa:	53                   	push   %ebx
  8013fb:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013fe:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801403:	83 ec 0c             	sub    $0xc,%esp
  801406:	53                   	push   %ebx
  801407:	e8 c0 ff ff ff       	call   8013cc <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80140c:	83 c3 01             	add    $0x1,%ebx
  80140f:	83 c4 10             	add    $0x10,%esp
  801412:	83 fb 20             	cmp    $0x20,%ebx
  801415:	75 ec                	jne    801403 <close_all+0xc>
		close(i);
}
  801417:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80141a:	c9                   	leave  
  80141b:	c3                   	ret    

0080141c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80141c:	55                   	push   %ebp
  80141d:	89 e5                	mov    %esp,%ebp
  80141f:	57                   	push   %edi
  801420:	56                   	push   %esi
  801421:	53                   	push   %ebx
  801422:	83 ec 2c             	sub    $0x2c,%esp
  801425:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801428:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80142b:	50                   	push   %eax
  80142c:	ff 75 08             	pushl  0x8(%ebp)
  80142f:	e8 6e fe ff ff       	call   8012a2 <fd_lookup>
  801434:	83 c4 08             	add    $0x8,%esp
  801437:	85 c0                	test   %eax,%eax
  801439:	0f 88 c1 00 00 00    	js     801500 <dup+0xe4>
		return r;
	close(newfdnum);
  80143f:	83 ec 0c             	sub    $0xc,%esp
  801442:	56                   	push   %esi
  801443:	e8 84 ff ff ff       	call   8013cc <close>

	newfd = INDEX2FD(newfdnum);
  801448:	89 f3                	mov    %esi,%ebx
  80144a:	c1 e3 0c             	shl    $0xc,%ebx
  80144d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801453:	83 c4 04             	add    $0x4,%esp
  801456:	ff 75 e4             	pushl  -0x1c(%ebp)
  801459:	e8 de fd ff ff       	call   80123c <fd2data>
  80145e:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801460:	89 1c 24             	mov    %ebx,(%esp)
  801463:	e8 d4 fd ff ff       	call   80123c <fd2data>
  801468:	83 c4 10             	add    $0x10,%esp
  80146b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80146e:	89 f8                	mov    %edi,%eax
  801470:	c1 e8 16             	shr    $0x16,%eax
  801473:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80147a:	a8 01                	test   $0x1,%al
  80147c:	74 37                	je     8014b5 <dup+0x99>
  80147e:	89 f8                	mov    %edi,%eax
  801480:	c1 e8 0c             	shr    $0xc,%eax
  801483:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80148a:	f6 c2 01             	test   $0x1,%dl
  80148d:	74 26                	je     8014b5 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80148f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801496:	83 ec 0c             	sub    $0xc,%esp
  801499:	25 07 0e 00 00       	and    $0xe07,%eax
  80149e:	50                   	push   %eax
  80149f:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014a2:	6a 00                	push   $0x0
  8014a4:	57                   	push   %edi
  8014a5:	6a 00                	push   $0x0
  8014a7:	e8 0a f9 ff ff       	call   800db6 <sys_page_map>
  8014ac:	89 c7                	mov    %eax,%edi
  8014ae:	83 c4 20             	add    $0x20,%esp
  8014b1:	85 c0                	test   %eax,%eax
  8014b3:	78 2e                	js     8014e3 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014b5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014b8:	89 d0                	mov    %edx,%eax
  8014ba:	c1 e8 0c             	shr    $0xc,%eax
  8014bd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014c4:	83 ec 0c             	sub    $0xc,%esp
  8014c7:	25 07 0e 00 00       	and    $0xe07,%eax
  8014cc:	50                   	push   %eax
  8014cd:	53                   	push   %ebx
  8014ce:	6a 00                	push   $0x0
  8014d0:	52                   	push   %edx
  8014d1:	6a 00                	push   $0x0
  8014d3:	e8 de f8 ff ff       	call   800db6 <sys_page_map>
  8014d8:	89 c7                	mov    %eax,%edi
  8014da:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8014dd:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014df:	85 ff                	test   %edi,%edi
  8014e1:	79 1d                	jns    801500 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014e3:	83 ec 08             	sub    $0x8,%esp
  8014e6:	53                   	push   %ebx
  8014e7:	6a 00                	push   $0x0
  8014e9:	e8 0a f9 ff ff       	call   800df8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014ee:	83 c4 08             	add    $0x8,%esp
  8014f1:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014f4:	6a 00                	push   $0x0
  8014f6:	e8 fd f8 ff ff       	call   800df8 <sys_page_unmap>
	return r;
  8014fb:	83 c4 10             	add    $0x10,%esp
  8014fe:	89 f8                	mov    %edi,%eax
}
  801500:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801503:	5b                   	pop    %ebx
  801504:	5e                   	pop    %esi
  801505:	5f                   	pop    %edi
  801506:	5d                   	pop    %ebp
  801507:	c3                   	ret    

00801508 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801508:	55                   	push   %ebp
  801509:	89 e5                	mov    %esp,%ebp
  80150b:	53                   	push   %ebx
  80150c:	83 ec 14             	sub    $0x14,%esp
  80150f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801512:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801515:	50                   	push   %eax
  801516:	53                   	push   %ebx
  801517:	e8 86 fd ff ff       	call   8012a2 <fd_lookup>
  80151c:	83 c4 08             	add    $0x8,%esp
  80151f:	89 c2                	mov    %eax,%edx
  801521:	85 c0                	test   %eax,%eax
  801523:	78 6d                	js     801592 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801525:	83 ec 08             	sub    $0x8,%esp
  801528:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80152b:	50                   	push   %eax
  80152c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80152f:	ff 30                	pushl  (%eax)
  801531:	e8 c2 fd ff ff       	call   8012f8 <dev_lookup>
  801536:	83 c4 10             	add    $0x10,%esp
  801539:	85 c0                	test   %eax,%eax
  80153b:	78 4c                	js     801589 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80153d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801540:	8b 42 08             	mov    0x8(%edx),%eax
  801543:	83 e0 03             	and    $0x3,%eax
  801546:	83 f8 01             	cmp    $0x1,%eax
  801549:	75 21                	jne    80156c <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80154b:	a1 08 40 80 00       	mov    0x804008,%eax
  801550:	8b 40 48             	mov    0x48(%eax),%eax
  801553:	83 ec 04             	sub    $0x4,%esp
  801556:	53                   	push   %ebx
  801557:	50                   	push   %eax
  801558:	68 b0 2d 80 00       	push   $0x802db0
  80155d:	e8 89 ee ff ff       	call   8003eb <cprintf>
		return -E_INVAL;
  801562:	83 c4 10             	add    $0x10,%esp
  801565:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80156a:	eb 26                	jmp    801592 <read+0x8a>
	}
	if (!dev->dev_read)
  80156c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80156f:	8b 40 08             	mov    0x8(%eax),%eax
  801572:	85 c0                	test   %eax,%eax
  801574:	74 17                	je     80158d <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801576:	83 ec 04             	sub    $0x4,%esp
  801579:	ff 75 10             	pushl  0x10(%ebp)
  80157c:	ff 75 0c             	pushl  0xc(%ebp)
  80157f:	52                   	push   %edx
  801580:	ff d0                	call   *%eax
  801582:	89 c2                	mov    %eax,%edx
  801584:	83 c4 10             	add    $0x10,%esp
  801587:	eb 09                	jmp    801592 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801589:	89 c2                	mov    %eax,%edx
  80158b:	eb 05                	jmp    801592 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80158d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801592:	89 d0                	mov    %edx,%eax
  801594:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801597:	c9                   	leave  
  801598:	c3                   	ret    

00801599 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801599:	55                   	push   %ebp
  80159a:	89 e5                	mov    %esp,%ebp
  80159c:	57                   	push   %edi
  80159d:	56                   	push   %esi
  80159e:	53                   	push   %ebx
  80159f:	83 ec 0c             	sub    $0xc,%esp
  8015a2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015a5:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015a8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015ad:	eb 21                	jmp    8015d0 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015af:	83 ec 04             	sub    $0x4,%esp
  8015b2:	89 f0                	mov    %esi,%eax
  8015b4:	29 d8                	sub    %ebx,%eax
  8015b6:	50                   	push   %eax
  8015b7:	89 d8                	mov    %ebx,%eax
  8015b9:	03 45 0c             	add    0xc(%ebp),%eax
  8015bc:	50                   	push   %eax
  8015bd:	57                   	push   %edi
  8015be:	e8 45 ff ff ff       	call   801508 <read>
		if (m < 0)
  8015c3:	83 c4 10             	add    $0x10,%esp
  8015c6:	85 c0                	test   %eax,%eax
  8015c8:	78 10                	js     8015da <readn+0x41>
			return m;
		if (m == 0)
  8015ca:	85 c0                	test   %eax,%eax
  8015cc:	74 0a                	je     8015d8 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015ce:	01 c3                	add    %eax,%ebx
  8015d0:	39 f3                	cmp    %esi,%ebx
  8015d2:	72 db                	jb     8015af <readn+0x16>
  8015d4:	89 d8                	mov    %ebx,%eax
  8015d6:	eb 02                	jmp    8015da <readn+0x41>
  8015d8:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8015da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015dd:	5b                   	pop    %ebx
  8015de:	5e                   	pop    %esi
  8015df:	5f                   	pop    %edi
  8015e0:	5d                   	pop    %ebp
  8015e1:	c3                   	ret    

008015e2 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015e2:	55                   	push   %ebp
  8015e3:	89 e5                	mov    %esp,%ebp
  8015e5:	53                   	push   %ebx
  8015e6:	83 ec 14             	sub    $0x14,%esp
  8015e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015ec:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015ef:	50                   	push   %eax
  8015f0:	53                   	push   %ebx
  8015f1:	e8 ac fc ff ff       	call   8012a2 <fd_lookup>
  8015f6:	83 c4 08             	add    $0x8,%esp
  8015f9:	89 c2                	mov    %eax,%edx
  8015fb:	85 c0                	test   %eax,%eax
  8015fd:	78 68                	js     801667 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ff:	83 ec 08             	sub    $0x8,%esp
  801602:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801605:	50                   	push   %eax
  801606:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801609:	ff 30                	pushl  (%eax)
  80160b:	e8 e8 fc ff ff       	call   8012f8 <dev_lookup>
  801610:	83 c4 10             	add    $0x10,%esp
  801613:	85 c0                	test   %eax,%eax
  801615:	78 47                	js     80165e <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801617:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80161a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80161e:	75 21                	jne    801641 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801620:	a1 08 40 80 00       	mov    0x804008,%eax
  801625:	8b 40 48             	mov    0x48(%eax),%eax
  801628:	83 ec 04             	sub    $0x4,%esp
  80162b:	53                   	push   %ebx
  80162c:	50                   	push   %eax
  80162d:	68 cc 2d 80 00       	push   $0x802dcc
  801632:	e8 b4 ed ff ff       	call   8003eb <cprintf>
		return -E_INVAL;
  801637:	83 c4 10             	add    $0x10,%esp
  80163a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80163f:	eb 26                	jmp    801667 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801641:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801644:	8b 52 0c             	mov    0xc(%edx),%edx
  801647:	85 d2                	test   %edx,%edx
  801649:	74 17                	je     801662 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80164b:	83 ec 04             	sub    $0x4,%esp
  80164e:	ff 75 10             	pushl  0x10(%ebp)
  801651:	ff 75 0c             	pushl  0xc(%ebp)
  801654:	50                   	push   %eax
  801655:	ff d2                	call   *%edx
  801657:	89 c2                	mov    %eax,%edx
  801659:	83 c4 10             	add    $0x10,%esp
  80165c:	eb 09                	jmp    801667 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80165e:	89 c2                	mov    %eax,%edx
  801660:	eb 05                	jmp    801667 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801662:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801667:	89 d0                	mov    %edx,%eax
  801669:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80166c:	c9                   	leave  
  80166d:	c3                   	ret    

0080166e <seek>:

int
seek(int fdnum, off_t offset)
{
  80166e:	55                   	push   %ebp
  80166f:	89 e5                	mov    %esp,%ebp
  801671:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801674:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801677:	50                   	push   %eax
  801678:	ff 75 08             	pushl  0x8(%ebp)
  80167b:	e8 22 fc ff ff       	call   8012a2 <fd_lookup>
  801680:	83 c4 08             	add    $0x8,%esp
  801683:	85 c0                	test   %eax,%eax
  801685:	78 0e                	js     801695 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801687:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80168a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80168d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801690:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801695:	c9                   	leave  
  801696:	c3                   	ret    

00801697 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801697:	55                   	push   %ebp
  801698:	89 e5                	mov    %esp,%ebp
  80169a:	53                   	push   %ebx
  80169b:	83 ec 14             	sub    $0x14,%esp
  80169e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016a1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016a4:	50                   	push   %eax
  8016a5:	53                   	push   %ebx
  8016a6:	e8 f7 fb ff ff       	call   8012a2 <fd_lookup>
  8016ab:	83 c4 08             	add    $0x8,%esp
  8016ae:	89 c2                	mov    %eax,%edx
  8016b0:	85 c0                	test   %eax,%eax
  8016b2:	78 65                	js     801719 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016b4:	83 ec 08             	sub    $0x8,%esp
  8016b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016ba:	50                   	push   %eax
  8016bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016be:	ff 30                	pushl  (%eax)
  8016c0:	e8 33 fc ff ff       	call   8012f8 <dev_lookup>
  8016c5:	83 c4 10             	add    $0x10,%esp
  8016c8:	85 c0                	test   %eax,%eax
  8016ca:	78 44                	js     801710 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016cf:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016d3:	75 21                	jne    8016f6 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016d5:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016da:	8b 40 48             	mov    0x48(%eax),%eax
  8016dd:	83 ec 04             	sub    $0x4,%esp
  8016e0:	53                   	push   %ebx
  8016e1:	50                   	push   %eax
  8016e2:	68 8c 2d 80 00       	push   $0x802d8c
  8016e7:	e8 ff ec ff ff       	call   8003eb <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016ec:	83 c4 10             	add    $0x10,%esp
  8016ef:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016f4:	eb 23                	jmp    801719 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8016f6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016f9:	8b 52 18             	mov    0x18(%edx),%edx
  8016fc:	85 d2                	test   %edx,%edx
  8016fe:	74 14                	je     801714 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801700:	83 ec 08             	sub    $0x8,%esp
  801703:	ff 75 0c             	pushl  0xc(%ebp)
  801706:	50                   	push   %eax
  801707:	ff d2                	call   *%edx
  801709:	89 c2                	mov    %eax,%edx
  80170b:	83 c4 10             	add    $0x10,%esp
  80170e:	eb 09                	jmp    801719 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801710:	89 c2                	mov    %eax,%edx
  801712:	eb 05                	jmp    801719 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801714:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801719:	89 d0                	mov    %edx,%eax
  80171b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80171e:	c9                   	leave  
  80171f:	c3                   	ret    

00801720 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801720:	55                   	push   %ebp
  801721:	89 e5                	mov    %esp,%ebp
  801723:	53                   	push   %ebx
  801724:	83 ec 14             	sub    $0x14,%esp
  801727:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80172a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80172d:	50                   	push   %eax
  80172e:	ff 75 08             	pushl  0x8(%ebp)
  801731:	e8 6c fb ff ff       	call   8012a2 <fd_lookup>
  801736:	83 c4 08             	add    $0x8,%esp
  801739:	89 c2                	mov    %eax,%edx
  80173b:	85 c0                	test   %eax,%eax
  80173d:	78 58                	js     801797 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80173f:	83 ec 08             	sub    $0x8,%esp
  801742:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801745:	50                   	push   %eax
  801746:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801749:	ff 30                	pushl  (%eax)
  80174b:	e8 a8 fb ff ff       	call   8012f8 <dev_lookup>
  801750:	83 c4 10             	add    $0x10,%esp
  801753:	85 c0                	test   %eax,%eax
  801755:	78 37                	js     80178e <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801757:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80175a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80175e:	74 32                	je     801792 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801760:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801763:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80176a:	00 00 00 
	stat->st_isdir = 0;
  80176d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801774:	00 00 00 
	stat->st_dev = dev;
  801777:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80177d:	83 ec 08             	sub    $0x8,%esp
  801780:	53                   	push   %ebx
  801781:	ff 75 f0             	pushl  -0x10(%ebp)
  801784:	ff 50 14             	call   *0x14(%eax)
  801787:	89 c2                	mov    %eax,%edx
  801789:	83 c4 10             	add    $0x10,%esp
  80178c:	eb 09                	jmp    801797 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80178e:	89 c2                	mov    %eax,%edx
  801790:	eb 05                	jmp    801797 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801792:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801797:	89 d0                	mov    %edx,%eax
  801799:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80179c:	c9                   	leave  
  80179d:	c3                   	ret    

0080179e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80179e:	55                   	push   %ebp
  80179f:	89 e5                	mov    %esp,%ebp
  8017a1:	56                   	push   %esi
  8017a2:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017a3:	83 ec 08             	sub    $0x8,%esp
  8017a6:	6a 00                	push   $0x0
  8017a8:	ff 75 08             	pushl  0x8(%ebp)
  8017ab:	e8 0c 02 00 00       	call   8019bc <open>
  8017b0:	89 c3                	mov    %eax,%ebx
  8017b2:	83 c4 10             	add    $0x10,%esp
  8017b5:	85 c0                	test   %eax,%eax
  8017b7:	78 1b                	js     8017d4 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017b9:	83 ec 08             	sub    $0x8,%esp
  8017bc:	ff 75 0c             	pushl  0xc(%ebp)
  8017bf:	50                   	push   %eax
  8017c0:	e8 5b ff ff ff       	call   801720 <fstat>
  8017c5:	89 c6                	mov    %eax,%esi
	close(fd);
  8017c7:	89 1c 24             	mov    %ebx,(%esp)
  8017ca:	e8 fd fb ff ff       	call   8013cc <close>
	return r;
  8017cf:	83 c4 10             	add    $0x10,%esp
  8017d2:	89 f0                	mov    %esi,%eax
}
  8017d4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017d7:	5b                   	pop    %ebx
  8017d8:	5e                   	pop    %esi
  8017d9:	5d                   	pop    %ebp
  8017da:	c3                   	ret    

008017db <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017db:	55                   	push   %ebp
  8017dc:	89 e5                	mov    %esp,%ebp
  8017de:	56                   	push   %esi
  8017df:	53                   	push   %ebx
  8017e0:	89 c6                	mov    %eax,%esi
  8017e2:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017e4:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017eb:	75 12                	jne    8017ff <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017ed:	83 ec 0c             	sub    $0xc,%esp
  8017f0:	6a 01                	push   $0x1
  8017f2:	e8 31 0d 00 00       	call   802528 <ipc_find_env>
  8017f7:	a3 00 40 80 00       	mov    %eax,0x804000
  8017fc:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017ff:	6a 07                	push   $0x7
  801801:	68 00 50 80 00       	push   $0x805000
  801806:	56                   	push   %esi
  801807:	ff 35 00 40 80 00    	pushl  0x804000
  80180d:	e8 c2 0c 00 00       	call   8024d4 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801812:	83 c4 0c             	add    $0xc,%esp
  801815:	6a 00                	push   $0x0
  801817:	53                   	push   %ebx
  801818:	6a 00                	push   $0x0
  80181a:	e8 4c 0c 00 00       	call   80246b <ipc_recv>
}
  80181f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801822:	5b                   	pop    %ebx
  801823:	5e                   	pop    %esi
  801824:	5d                   	pop    %ebp
  801825:	c3                   	ret    

00801826 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801826:	55                   	push   %ebp
  801827:	89 e5                	mov    %esp,%ebp
  801829:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80182c:	8b 45 08             	mov    0x8(%ebp),%eax
  80182f:	8b 40 0c             	mov    0xc(%eax),%eax
  801832:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801837:	8b 45 0c             	mov    0xc(%ebp),%eax
  80183a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80183f:	ba 00 00 00 00       	mov    $0x0,%edx
  801844:	b8 02 00 00 00       	mov    $0x2,%eax
  801849:	e8 8d ff ff ff       	call   8017db <fsipc>
}
  80184e:	c9                   	leave  
  80184f:	c3                   	ret    

00801850 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801850:	55                   	push   %ebp
  801851:	89 e5                	mov    %esp,%ebp
  801853:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801856:	8b 45 08             	mov    0x8(%ebp),%eax
  801859:	8b 40 0c             	mov    0xc(%eax),%eax
  80185c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801861:	ba 00 00 00 00       	mov    $0x0,%edx
  801866:	b8 06 00 00 00       	mov    $0x6,%eax
  80186b:	e8 6b ff ff ff       	call   8017db <fsipc>
}
  801870:	c9                   	leave  
  801871:	c3                   	ret    

00801872 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801872:	55                   	push   %ebp
  801873:	89 e5                	mov    %esp,%ebp
  801875:	53                   	push   %ebx
  801876:	83 ec 04             	sub    $0x4,%esp
  801879:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80187c:	8b 45 08             	mov    0x8(%ebp),%eax
  80187f:	8b 40 0c             	mov    0xc(%eax),%eax
  801882:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801887:	ba 00 00 00 00       	mov    $0x0,%edx
  80188c:	b8 05 00 00 00       	mov    $0x5,%eax
  801891:	e8 45 ff ff ff       	call   8017db <fsipc>
  801896:	85 c0                	test   %eax,%eax
  801898:	78 2c                	js     8018c6 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80189a:	83 ec 08             	sub    $0x8,%esp
  80189d:	68 00 50 80 00       	push   $0x805000
  8018a2:	53                   	push   %ebx
  8018a3:	e8 c8 f0 ff ff       	call   800970 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018a8:	a1 80 50 80 00       	mov    0x805080,%eax
  8018ad:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018b3:	a1 84 50 80 00       	mov    0x805084,%eax
  8018b8:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018be:	83 c4 10             	add    $0x10,%esp
  8018c1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018c9:	c9                   	leave  
  8018ca:	c3                   	ret    

008018cb <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8018cb:	55                   	push   %ebp
  8018cc:	89 e5                	mov    %esp,%ebp
  8018ce:	53                   	push   %ebx
  8018cf:	83 ec 08             	sub    $0x8,%esp
  8018d2:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8018d5:	8b 55 08             	mov    0x8(%ebp),%edx
  8018d8:	8b 52 0c             	mov    0xc(%edx),%edx
  8018db:	89 15 00 50 80 00    	mov    %edx,0x805000
  8018e1:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8018e6:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  8018eb:	0f 46 d8             	cmovbe %eax,%ebx
	
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  8018ee:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  8018f4:	53                   	push   %ebx
  8018f5:	ff 75 0c             	pushl  0xc(%ebp)
  8018f8:	68 08 50 80 00       	push   $0x805008
  8018fd:	e8 00 f2 ff ff       	call   800b02 <memmove>

	
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) 
  801902:	ba 00 00 00 00       	mov    $0x0,%edx
  801907:	b8 04 00 00 00       	mov    $0x4,%eax
  80190c:	e8 ca fe ff ff       	call   8017db <fsipc>
  801911:	83 c4 10             	add    $0x10,%esp
  801914:	85 c0                	test   %eax,%eax
  801916:	78 1d                	js     801935 <devfile_write+0x6a>
		return r;
	assert(r <= n_real); 
  801918:	39 d8                	cmp    %ebx,%eax
  80191a:	76 19                	jbe    801935 <devfile_write+0x6a>
  80191c:	68 00 2e 80 00       	push   $0x802e00
  801921:	68 0c 2e 80 00       	push   $0x802e0c
  801926:	68 a3 00 00 00       	push   $0xa3
  80192b:	68 21 2e 80 00       	push   $0x802e21
  801930:	e8 dd e9 ff ff       	call   800312 <_panic>
	return r;
}
  801935:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801938:	c9                   	leave  
  801939:	c3                   	ret    

0080193a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80193a:	55                   	push   %ebp
  80193b:	89 e5                	mov    %esp,%ebp
  80193d:	56                   	push   %esi
  80193e:	53                   	push   %ebx
  80193f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801942:	8b 45 08             	mov    0x8(%ebp),%eax
  801945:	8b 40 0c             	mov    0xc(%eax),%eax
  801948:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80194d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801953:	ba 00 00 00 00       	mov    $0x0,%edx
  801958:	b8 03 00 00 00       	mov    $0x3,%eax
  80195d:	e8 79 fe ff ff       	call   8017db <fsipc>
  801962:	89 c3                	mov    %eax,%ebx
  801964:	85 c0                	test   %eax,%eax
  801966:	78 4b                	js     8019b3 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801968:	39 c6                	cmp    %eax,%esi
  80196a:	73 16                	jae    801982 <devfile_read+0x48>
  80196c:	68 2c 2e 80 00       	push   $0x802e2c
  801971:	68 0c 2e 80 00       	push   $0x802e0c
  801976:	6a 7c                	push   $0x7c
  801978:	68 21 2e 80 00       	push   $0x802e21
  80197d:	e8 90 e9 ff ff       	call   800312 <_panic>
	assert(r <= PGSIZE);
  801982:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801987:	7e 16                	jle    80199f <devfile_read+0x65>
  801989:	68 33 2e 80 00       	push   $0x802e33
  80198e:	68 0c 2e 80 00       	push   $0x802e0c
  801993:	6a 7d                	push   $0x7d
  801995:	68 21 2e 80 00       	push   $0x802e21
  80199a:	e8 73 e9 ff ff       	call   800312 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80199f:	83 ec 04             	sub    $0x4,%esp
  8019a2:	50                   	push   %eax
  8019a3:	68 00 50 80 00       	push   $0x805000
  8019a8:	ff 75 0c             	pushl  0xc(%ebp)
  8019ab:	e8 52 f1 ff ff       	call   800b02 <memmove>
	return r;
  8019b0:	83 c4 10             	add    $0x10,%esp
}
  8019b3:	89 d8                	mov    %ebx,%eax
  8019b5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019b8:	5b                   	pop    %ebx
  8019b9:	5e                   	pop    %esi
  8019ba:	5d                   	pop    %ebp
  8019bb:	c3                   	ret    

008019bc <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8019bc:	55                   	push   %ebp
  8019bd:	89 e5                	mov    %esp,%ebp
  8019bf:	53                   	push   %ebx
  8019c0:	83 ec 20             	sub    $0x20,%esp
  8019c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8019c6:	53                   	push   %ebx
  8019c7:	e8 6b ef ff ff       	call   800937 <strlen>
  8019cc:	83 c4 10             	add    $0x10,%esp
  8019cf:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019d4:	7f 67                	jg     801a3d <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019d6:	83 ec 0c             	sub    $0xc,%esp
  8019d9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019dc:	50                   	push   %eax
  8019dd:	e8 71 f8 ff ff       	call   801253 <fd_alloc>
  8019e2:	83 c4 10             	add    $0x10,%esp
		return r;
  8019e5:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019e7:	85 c0                	test   %eax,%eax
  8019e9:	78 57                	js     801a42 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8019eb:	83 ec 08             	sub    $0x8,%esp
  8019ee:	53                   	push   %ebx
  8019ef:	68 00 50 80 00       	push   $0x805000
  8019f4:	e8 77 ef ff ff       	call   800970 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019fc:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a01:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a04:	b8 01 00 00 00       	mov    $0x1,%eax
  801a09:	e8 cd fd ff ff       	call   8017db <fsipc>
  801a0e:	89 c3                	mov    %eax,%ebx
  801a10:	83 c4 10             	add    $0x10,%esp
  801a13:	85 c0                	test   %eax,%eax
  801a15:	79 14                	jns    801a2b <open+0x6f>
		fd_close(fd, 0);
  801a17:	83 ec 08             	sub    $0x8,%esp
  801a1a:	6a 00                	push   $0x0
  801a1c:	ff 75 f4             	pushl  -0xc(%ebp)
  801a1f:	e8 27 f9 ff ff       	call   80134b <fd_close>
		return r;
  801a24:	83 c4 10             	add    $0x10,%esp
  801a27:	89 da                	mov    %ebx,%edx
  801a29:	eb 17                	jmp    801a42 <open+0x86>
	}

	return fd2num(fd);
  801a2b:	83 ec 0c             	sub    $0xc,%esp
  801a2e:	ff 75 f4             	pushl  -0xc(%ebp)
  801a31:	e8 f6 f7 ff ff       	call   80122c <fd2num>
  801a36:	89 c2                	mov    %eax,%edx
  801a38:	83 c4 10             	add    $0x10,%esp
  801a3b:	eb 05                	jmp    801a42 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a3d:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a42:	89 d0                	mov    %edx,%eax
  801a44:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a47:	c9                   	leave  
  801a48:	c3                   	ret    

00801a49 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a49:	55                   	push   %ebp
  801a4a:	89 e5                	mov    %esp,%ebp
  801a4c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a4f:	ba 00 00 00 00       	mov    $0x0,%edx
  801a54:	b8 08 00 00 00       	mov    $0x8,%eax
  801a59:	e8 7d fd ff ff       	call   8017db <fsipc>
}
  801a5e:	c9                   	leave  
  801a5f:	c3                   	ret    

00801a60 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801a60:	55                   	push   %ebp
  801a61:	89 e5                	mov    %esp,%ebp
  801a63:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801a66:	68 3f 2e 80 00       	push   $0x802e3f
  801a6b:	ff 75 0c             	pushl  0xc(%ebp)
  801a6e:	e8 fd ee ff ff       	call   800970 <strcpy>
	return 0;
}
  801a73:	b8 00 00 00 00       	mov    $0x0,%eax
  801a78:	c9                   	leave  
  801a79:	c3                   	ret    

00801a7a <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801a7a:	55                   	push   %ebp
  801a7b:	89 e5                	mov    %esp,%ebp
  801a7d:	53                   	push   %ebx
  801a7e:	83 ec 10             	sub    $0x10,%esp
  801a81:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801a84:	53                   	push   %ebx
  801a85:	e8 d7 0a 00 00       	call   802561 <pageref>
  801a8a:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801a8d:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801a92:	83 f8 01             	cmp    $0x1,%eax
  801a95:	75 10                	jne    801aa7 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801a97:	83 ec 0c             	sub    $0xc,%esp
  801a9a:	ff 73 0c             	pushl  0xc(%ebx)
  801a9d:	e8 c0 02 00 00       	call   801d62 <nsipc_close>
  801aa2:	89 c2                	mov    %eax,%edx
  801aa4:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801aa7:	89 d0                	mov    %edx,%eax
  801aa9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801aac:	c9                   	leave  
  801aad:	c3                   	ret    

00801aae <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801aae:	55                   	push   %ebp
  801aaf:	89 e5                	mov    %esp,%ebp
  801ab1:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801ab4:	6a 00                	push   $0x0
  801ab6:	ff 75 10             	pushl  0x10(%ebp)
  801ab9:	ff 75 0c             	pushl  0xc(%ebp)
  801abc:	8b 45 08             	mov    0x8(%ebp),%eax
  801abf:	ff 70 0c             	pushl  0xc(%eax)
  801ac2:	e8 78 03 00 00       	call   801e3f <nsipc_send>
}
  801ac7:	c9                   	leave  
  801ac8:	c3                   	ret    

00801ac9 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801ac9:	55                   	push   %ebp
  801aca:	89 e5                	mov    %esp,%ebp
  801acc:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801acf:	6a 00                	push   $0x0
  801ad1:	ff 75 10             	pushl  0x10(%ebp)
  801ad4:	ff 75 0c             	pushl  0xc(%ebp)
  801ad7:	8b 45 08             	mov    0x8(%ebp),%eax
  801ada:	ff 70 0c             	pushl  0xc(%eax)
  801add:	e8 f1 02 00 00       	call   801dd3 <nsipc_recv>
}
  801ae2:	c9                   	leave  
  801ae3:	c3                   	ret    

00801ae4 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801ae4:	55                   	push   %ebp
  801ae5:	89 e5                	mov    %esp,%ebp
  801ae7:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801aea:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801aed:	52                   	push   %edx
  801aee:	50                   	push   %eax
  801aef:	e8 ae f7 ff ff       	call   8012a2 <fd_lookup>
  801af4:	83 c4 10             	add    $0x10,%esp
  801af7:	85 c0                	test   %eax,%eax
  801af9:	78 17                	js     801b12 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801afb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801afe:	8b 0d 24 30 80 00    	mov    0x803024,%ecx
  801b04:	39 08                	cmp    %ecx,(%eax)
  801b06:	75 05                	jne    801b0d <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801b08:	8b 40 0c             	mov    0xc(%eax),%eax
  801b0b:	eb 05                	jmp    801b12 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801b0d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801b12:	c9                   	leave  
  801b13:	c3                   	ret    

00801b14 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801b14:	55                   	push   %ebp
  801b15:	89 e5                	mov    %esp,%ebp
  801b17:	56                   	push   %esi
  801b18:	53                   	push   %ebx
  801b19:	83 ec 1c             	sub    $0x1c,%esp
  801b1c:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801b1e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b21:	50                   	push   %eax
  801b22:	e8 2c f7 ff ff       	call   801253 <fd_alloc>
  801b27:	89 c3                	mov    %eax,%ebx
  801b29:	83 c4 10             	add    $0x10,%esp
  801b2c:	85 c0                	test   %eax,%eax
  801b2e:	78 1b                	js     801b4b <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801b30:	83 ec 04             	sub    $0x4,%esp
  801b33:	68 07 04 00 00       	push   $0x407
  801b38:	ff 75 f4             	pushl  -0xc(%ebp)
  801b3b:	6a 00                	push   $0x0
  801b3d:	e8 31 f2 ff ff       	call   800d73 <sys_page_alloc>
  801b42:	89 c3                	mov    %eax,%ebx
  801b44:	83 c4 10             	add    $0x10,%esp
  801b47:	85 c0                	test   %eax,%eax
  801b49:	79 10                	jns    801b5b <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801b4b:	83 ec 0c             	sub    $0xc,%esp
  801b4e:	56                   	push   %esi
  801b4f:	e8 0e 02 00 00       	call   801d62 <nsipc_close>
		return r;
  801b54:	83 c4 10             	add    $0x10,%esp
  801b57:	89 d8                	mov    %ebx,%eax
  801b59:	eb 24                	jmp    801b7f <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801b5b:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801b61:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b64:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801b66:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b69:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801b70:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801b73:	83 ec 0c             	sub    $0xc,%esp
  801b76:	50                   	push   %eax
  801b77:	e8 b0 f6 ff ff       	call   80122c <fd2num>
  801b7c:	83 c4 10             	add    $0x10,%esp
}
  801b7f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b82:	5b                   	pop    %ebx
  801b83:	5e                   	pop    %esi
  801b84:	5d                   	pop    %ebp
  801b85:	c3                   	ret    

00801b86 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801b86:	55                   	push   %ebp
  801b87:	89 e5                	mov    %esp,%ebp
  801b89:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b8c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b8f:	e8 50 ff ff ff       	call   801ae4 <fd2sockid>
		return r;
  801b94:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b96:	85 c0                	test   %eax,%eax
  801b98:	78 1f                	js     801bb9 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b9a:	83 ec 04             	sub    $0x4,%esp
  801b9d:	ff 75 10             	pushl  0x10(%ebp)
  801ba0:	ff 75 0c             	pushl  0xc(%ebp)
  801ba3:	50                   	push   %eax
  801ba4:	e8 12 01 00 00       	call   801cbb <nsipc_accept>
  801ba9:	83 c4 10             	add    $0x10,%esp
		return r;
  801bac:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801bae:	85 c0                	test   %eax,%eax
  801bb0:	78 07                	js     801bb9 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801bb2:	e8 5d ff ff ff       	call   801b14 <alloc_sockfd>
  801bb7:	89 c1                	mov    %eax,%ecx
}
  801bb9:	89 c8                	mov    %ecx,%eax
  801bbb:	c9                   	leave  
  801bbc:	c3                   	ret    

00801bbd <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801bbd:	55                   	push   %ebp
  801bbe:	89 e5                	mov    %esp,%ebp
  801bc0:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bc3:	8b 45 08             	mov    0x8(%ebp),%eax
  801bc6:	e8 19 ff ff ff       	call   801ae4 <fd2sockid>
  801bcb:	85 c0                	test   %eax,%eax
  801bcd:	78 12                	js     801be1 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801bcf:	83 ec 04             	sub    $0x4,%esp
  801bd2:	ff 75 10             	pushl  0x10(%ebp)
  801bd5:	ff 75 0c             	pushl  0xc(%ebp)
  801bd8:	50                   	push   %eax
  801bd9:	e8 2d 01 00 00       	call   801d0b <nsipc_bind>
  801bde:	83 c4 10             	add    $0x10,%esp
}
  801be1:	c9                   	leave  
  801be2:	c3                   	ret    

00801be3 <shutdown>:

int
shutdown(int s, int how)
{
  801be3:	55                   	push   %ebp
  801be4:	89 e5                	mov    %esp,%ebp
  801be6:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801be9:	8b 45 08             	mov    0x8(%ebp),%eax
  801bec:	e8 f3 fe ff ff       	call   801ae4 <fd2sockid>
  801bf1:	85 c0                	test   %eax,%eax
  801bf3:	78 0f                	js     801c04 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801bf5:	83 ec 08             	sub    $0x8,%esp
  801bf8:	ff 75 0c             	pushl  0xc(%ebp)
  801bfb:	50                   	push   %eax
  801bfc:	e8 3f 01 00 00       	call   801d40 <nsipc_shutdown>
  801c01:	83 c4 10             	add    $0x10,%esp
}
  801c04:	c9                   	leave  
  801c05:	c3                   	ret    

00801c06 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801c06:	55                   	push   %ebp
  801c07:	89 e5                	mov    %esp,%ebp
  801c09:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c0c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c0f:	e8 d0 fe ff ff       	call   801ae4 <fd2sockid>
  801c14:	85 c0                	test   %eax,%eax
  801c16:	78 12                	js     801c2a <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801c18:	83 ec 04             	sub    $0x4,%esp
  801c1b:	ff 75 10             	pushl  0x10(%ebp)
  801c1e:	ff 75 0c             	pushl  0xc(%ebp)
  801c21:	50                   	push   %eax
  801c22:	e8 55 01 00 00       	call   801d7c <nsipc_connect>
  801c27:	83 c4 10             	add    $0x10,%esp
}
  801c2a:	c9                   	leave  
  801c2b:	c3                   	ret    

00801c2c <listen>:

int
listen(int s, int backlog)
{
  801c2c:	55                   	push   %ebp
  801c2d:	89 e5                	mov    %esp,%ebp
  801c2f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c32:	8b 45 08             	mov    0x8(%ebp),%eax
  801c35:	e8 aa fe ff ff       	call   801ae4 <fd2sockid>
  801c3a:	85 c0                	test   %eax,%eax
  801c3c:	78 0f                	js     801c4d <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801c3e:	83 ec 08             	sub    $0x8,%esp
  801c41:	ff 75 0c             	pushl  0xc(%ebp)
  801c44:	50                   	push   %eax
  801c45:	e8 67 01 00 00       	call   801db1 <nsipc_listen>
  801c4a:	83 c4 10             	add    $0x10,%esp
}
  801c4d:	c9                   	leave  
  801c4e:	c3                   	ret    

00801c4f <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801c4f:	55                   	push   %ebp
  801c50:	89 e5                	mov    %esp,%ebp
  801c52:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801c55:	ff 75 10             	pushl  0x10(%ebp)
  801c58:	ff 75 0c             	pushl  0xc(%ebp)
  801c5b:	ff 75 08             	pushl  0x8(%ebp)
  801c5e:	e8 3a 02 00 00       	call   801e9d <nsipc_socket>
  801c63:	83 c4 10             	add    $0x10,%esp
  801c66:	85 c0                	test   %eax,%eax
  801c68:	78 05                	js     801c6f <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801c6a:	e8 a5 fe ff ff       	call   801b14 <alloc_sockfd>
}
  801c6f:	c9                   	leave  
  801c70:	c3                   	ret    

00801c71 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801c71:	55                   	push   %ebp
  801c72:	89 e5                	mov    %esp,%ebp
  801c74:	53                   	push   %ebx
  801c75:	83 ec 04             	sub    $0x4,%esp
  801c78:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801c7a:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801c81:	75 12                	jne    801c95 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801c83:	83 ec 0c             	sub    $0xc,%esp
  801c86:	6a 02                	push   $0x2
  801c88:	e8 9b 08 00 00       	call   802528 <ipc_find_env>
  801c8d:	a3 04 40 80 00       	mov    %eax,0x804004
  801c92:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801c95:	6a 07                	push   $0x7
  801c97:	68 00 60 80 00       	push   $0x806000
  801c9c:	53                   	push   %ebx
  801c9d:	ff 35 04 40 80 00    	pushl  0x804004
  801ca3:	e8 2c 08 00 00       	call   8024d4 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801ca8:	83 c4 0c             	add    $0xc,%esp
  801cab:	6a 00                	push   $0x0
  801cad:	6a 00                	push   $0x0
  801caf:	6a 00                	push   $0x0
  801cb1:	e8 b5 07 00 00       	call   80246b <ipc_recv>
}
  801cb6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cb9:	c9                   	leave  
  801cba:	c3                   	ret    

00801cbb <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801cbb:	55                   	push   %ebp
  801cbc:	89 e5                	mov    %esp,%ebp
  801cbe:	56                   	push   %esi
  801cbf:	53                   	push   %ebx
  801cc0:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801cc3:	8b 45 08             	mov    0x8(%ebp),%eax
  801cc6:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801ccb:	8b 06                	mov    (%esi),%eax
  801ccd:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801cd2:	b8 01 00 00 00       	mov    $0x1,%eax
  801cd7:	e8 95 ff ff ff       	call   801c71 <nsipc>
  801cdc:	89 c3                	mov    %eax,%ebx
  801cde:	85 c0                	test   %eax,%eax
  801ce0:	78 20                	js     801d02 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801ce2:	83 ec 04             	sub    $0x4,%esp
  801ce5:	ff 35 10 60 80 00    	pushl  0x806010
  801ceb:	68 00 60 80 00       	push   $0x806000
  801cf0:	ff 75 0c             	pushl  0xc(%ebp)
  801cf3:	e8 0a ee ff ff       	call   800b02 <memmove>
		*addrlen = ret->ret_addrlen;
  801cf8:	a1 10 60 80 00       	mov    0x806010,%eax
  801cfd:	89 06                	mov    %eax,(%esi)
  801cff:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801d02:	89 d8                	mov    %ebx,%eax
  801d04:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d07:	5b                   	pop    %ebx
  801d08:	5e                   	pop    %esi
  801d09:	5d                   	pop    %ebp
  801d0a:	c3                   	ret    

00801d0b <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801d0b:	55                   	push   %ebp
  801d0c:	89 e5                	mov    %esp,%ebp
  801d0e:	53                   	push   %ebx
  801d0f:	83 ec 08             	sub    $0x8,%esp
  801d12:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801d15:	8b 45 08             	mov    0x8(%ebp),%eax
  801d18:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801d1d:	53                   	push   %ebx
  801d1e:	ff 75 0c             	pushl  0xc(%ebp)
  801d21:	68 04 60 80 00       	push   $0x806004
  801d26:	e8 d7 ed ff ff       	call   800b02 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801d2b:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801d31:	b8 02 00 00 00       	mov    $0x2,%eax
  801d36:	e8 36 ff ff ff       	call   801c71 <nsipc>
}
  801d3b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d3e:	c9                   	leave  
  801d3f:	c3                   	ret    

00801d40 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801d40:	55                   	push   %ebp
  801d41:	89 e5                	mov    %esp,%ebp
  801d43:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801d46:	8b 45 08             	mov    0x8(%ebp),%eax
  801d49:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801d4e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d51:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801d56:	b8 03 00 00 00       	mov    $0x3,%eax
  801d5b:	e8 11 ff ff ff       	call   801c71 <nsipc>
}
  801d60:	c9                   	leave  
  801d61:	c3                   	ret    

00801d62 <nsipc_close>:

int
nsipc_close(int s)
{
  801d62:	55                   	push   %ebp
  801d63:	89 e5                	mov    %esp,%ebp
  801d65:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801d68:	8b 45 08             	mov    0x8(%ebp),%eax
  801d6b:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801d70:	b8 04 00 00 00       	mov    $0x4,%eax
  801d75:	e8 f7 fe ff ff       	call   801c71 <nsipc>
}
  801d7a:	c9                   	leave  
  801d7b:	c3                   	ret    

00801d7c <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801d7c:	55                   	push   %ebp
  801d7d:	89 e5                	mov    %esp,%ebp
  801d7f:	53                   	push   %ebx
  801d80:	83 ec 08             	sub    $0x8,%esp
  801d83:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801d86:	8b 45 08             	mov    0x8(%ebp),%eax
  801d89:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801d8e:	53                   	push   %ebx
  801d8f:	ff 75 0c             	pushl  0xc(%ebp)
  801d92:	68 04 60 80 00       	push   $0x806004
  801d97:	e8 66 ed ff ff       	call   800b02 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801d9c:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801da2:	b8 05 00 00 00       	mov    $0x5,%eax
  801da7:	e8 c5 fe ff ff       	call   801c71 <nsipc>
}
  801dac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801daf:	c9                   	leave  
  801db0:	c3                   	ret    

00801db1 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801db1:	55                   	push   %ebp
  801db2:	89 e5                	mov    %esp,%ebp
  801db4:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801db7:	8b 45 08             	mov    0x8(%ebp),%eax
  801dba:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801dbf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dc2:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801dc7:	b8 06 00 00 00       	mov    $0x6,%eax
  801dcc:	e8 a0 fe ff ff       	call   801c71 <nsipc>
}
  801dd1:	c9                   	leave  
  801dd2:	c3                   	ret    

00801dd3 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801dd3:	55                   	push   %ebp
  801dd4:	89 e5                	mov    %esp,%ebp
  801dd6:	56                   	push   %esi
  801dd7:	53                   	push   %ebx
  801dd8:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801ddb:	8b 45 08             	mov    0x8(%ebp),%eax
  801dde:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801de3:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801de9:	8b 45 14             	mov    0x14(%ebp),%eax
  801dec:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801df1:	b8 07 00 00 00       	mov    $0x7,%eax
  801df6:	e8 76 fe ff ff       	call   801c71 <nsipc>
  801dfb:	89 c3                	mov    %eax,%ebx
  801dfd:	85 c0                	test   %eax,%eax
  801dff:	78 35                	js     801e36 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801e01:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801e06:	7f 04                	jg     801e0c <nsipc_recv+0x39>
  801e08:	39 c6                	cmp    %eax,%esi
  801e0a:	7d 16                	jge    801e22 <nsipc_recv+0x4f>
  801e0c:	68 4b 2e 80 00       	push   $0x802e4b
  801e11:	68 0c 2e 80 00       	push   $0x802e0c
  801e16:	6a 62                	push   $0x62
  801e18:	68 60 2e 80 00       	push   $0x802e60
  801e1d:	e8 f0 e4 ff ff       	call   800312 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801e22:	83 ec 04             	sub    $0x4,%esp
  801e25:	50                   	push   %eax
  801e26:	68 00 60 80 00       	push   $0x806000
  801e2b:	ff 75 0c             	pushl  0xc(%ebp)
  801e2e:	e8 cf ec ff ff       	call   800b02 <memmove>
  801e33:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801e36:	89 d8                	mov    %ebx,%eax
  801e38:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e3b:	5b                   	pop    %ebx
  801e3c:	5e                   	pop    %esi
  801e3d:	5d                   	pop    %ebp
  801e3e:	c3                   	ret    

00801e3f <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801e3f:	55                   	push   %ebp
  801e40:	89 e5                	mov    %esp,%ebp
  801e42:	53                   	push   %ebx
  801e43:	83 ec 04             	sub    $0x4,%esp
  801e46:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801e49:	8b 45 08             	mov    0x8(%ebp),%eax
  801e4c:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801e51:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801e57:	7e 16                	jle    801e6f <nsipc_send+0x30>
  801e59:	68 6c 2e 80 00       	push   $0x802e6c
  801e5e:	68 0c 2e 80 00       	push   $0x802e0c
  801e63:	6a 6d                	push   $0x6d
  801e65:	68 60 2e 80 00       	push   $0x802e60
  801e6a:	e8 a3 e4 ff ff       	call   800312 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801e6f:	83 ec 04             	sub    $0x4,%esp
  801e72:	53                   	push   %ebx
  801e73:	ff 75 0c             	pushl  0xc(%ebp)
  801e76:	68 0c 60 80 00       	push   $0x80600c
  801e7b:	e8 82 ec ff ff       	call   800b02 <memmove>
	nsipcbuf.send.req_size = size;
  801e80:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801e86:	8b 45 14             	mov    0x14(%ebp),%eax
  801e89:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801e8e:	b8 08 00 00 00       	mov    $0x8,%eax
  801e93:	e8 d9 fd ff ff       	call   801c71 <nsipc>
}
  801e98:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e9b:	c9                   	leave  
  801e9c:	c3                   	ret    

00801e9d <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801e9d:	55                   	push   %ebp
  801e9e:	89 e5                	mov    %esp,%ebp
  801ea0:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801ea3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ea6:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801eab:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eae:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801eb3:	8b 45 10             	mov    0x10(%ebp),%eax
  801eb6:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801ebb:	b8 09 00 00 00       	mov    $0x9,%eax
  801ec0:	e8 ac fd ff ff       	call   801c71 <nsipc>
}
  801ec5:	c9                   	leave  
  801ec6:	c3                   	ret    

00801ec7 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801ec7:	55                   	push   %ebp
  801ec8:	89 e5                	mov    %esp,%ebp
  801eca:	56                   	push   %esi
  801ecb:	53                   	push   %ebx
  801ecc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ecf:	83 ec 0c             	sub    $0xc,%esp
  801ed2:	ff 75 08             	pushl  0x8(%ebp)
  801ed5:	e8 62 f3 ff ff       	call   80123c <fd2data>
  801eda:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801edc:	83 c4 08             	add    $0x8,%esp
  801edf:	68 78 2e 80 00       	push   $0x802e78
  801ee4:	53                   	push   %ebx
  801ee5:	e8 86 ea ff ff       	call   800970 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801eea:	8b 46 04             	mov    0x4(%esi),%eax
  801eed:	2b 06                	sub    (%esi),%eax
  801eef:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ef5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801efc:	00 00 00 
	stat->st_dev = &devpipe;
  801eff:	c7 83 88 00 00 00 40 	movl   $0x803040,0x88(%ebx)
  801f06:	30 80 00 
	return 0;
}
  801f09:	b8 00 00 00 00       	mov    $0x0,%eax
  801f0e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f11:	5b                   	pop    %ebx
  801f12:	5e                   	pop    %esi
  801f13:	5d                   	pop    %ebp
  801f14:	c3                   	ret    

00801f15 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801f15:	55                   	push   %ebp
  801f16:	89 e5                	mov    %esp,%ebp
  801f18:	53                   	push   %ebx
  801f19:	83 ec 0c             	sub    $0xc,%esp
  801f1c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801f1f:	53                   	push   %ebx
  801f20:	6a 00                	push   $0x0
  801f22:	e8 d1 ee ff ff       	call   800df8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801f27:	89 1c 24             	mov    %ebx,(%esp)
  801f2a:	e8 0d f3 ff ff       	call   80123c <fd2data>
  801f2f:	83 c4 08             	add    $0x8,%esp
  801f32:	50                   	push   %eax
  801f33:	6a 00                	push   $0x0
  801f35:	e8 be ee ff ff       	call   800df8 <sys_page_unmap>
}
  801f3a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f3d:	c9                   	leave  
  801f3e:	c3                   	ret    

00801f3f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801f3f:	55                   	push   %ebp
  801f40:	89 e5                	mov    %esp,%ebp
  801f42:	57                   	push   %edi
  801f43:	56                   	push   %esi
  801f44:	53                   	push   %ebx
  801f45:	83 ec 1c             	sub    $0x1c,%esp
  801f48:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801f4b:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801f4d:	a1 08 40 80 00       	mov    0x804008,%eax
  801f52:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801f55:	83 ec 0c             	sub    $0xc,%esp
  801f58:	ff 75 e0             	pushl  -0x20(%ebp)
  801f5b:	e8 01 06 00 00       	call   802561 <pageref>
  801f60:	89 c3                	mov    %eax,%ebx
  801f62:	89 3c 24             	mov    %edi,(%esp)
  801f65:	e8 f7 05 00 00       	call   802561 <pageref>
  801f6a:	83 c4 10             	add    $0x10,%esp
  801f6d:	39 c3                	cmp    %eax,%ebx
  801f6f:	0f 94 c1             	sete   %cl
  801f72:	0f b6 c9             	movzbl %cl,%ecx
  801f75:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801f78:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801f7e:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801f81:	39 ce                	cmp    %ecx,%esi
  801f83:	74 1b                	je     801fa0 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801f85:	39 c3                	cmp    %eax,%ebx
  801f87:	75 c4                	jne    801f4d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801f89:	8b 42 58             	mov    0x58(%edx),%eax
  801f8c:	ff 75 e4             	pushl  -0x1c(%ebp)
  801f8f:	50                   	push   %eax
  801f90:	56                   	push   %esi
  801f91:	68 7f 2e 80 00       	push   $0x802e7f
  801f96:	e8 50 e4 ff ff       	call   8003eb <cprintf>
  801f9b:	83 c4 10             	add    $0x10,%esp
  801f9e:	eb ad                	jmp    801f4d <_pipeisclosed+0xe>
	}
}
  801fa0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801fa3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fa6:	5b                   	pop    %ebx
  801fa7:	5e                   	pop    %esi
  801fa8:	5f                   	pop    %edi
  801fa9:	5d                   	pop    %ebp
  801faa:	c3                   	ret    

00801fab <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801fab:	55                   	push   %ebp
  801fac:	89 e5                	mov    %esp,%ebp
  801fae:	57                   	push   %edi
  801faf:	56                   	push   %esi
  801fb0:	53                   	push   %ebx
  801fb1:	83 ec 28             	sub    $0x28,%esp
  801fb4:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801fb7:	56                   	push   %esi
  801fb8:	e8 7f f2 ff ff       	call   80123c <fd2data>
  801fbd:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fbf:	83 c4 10             	add    $0x10,%esp
  801fc2:	bf 00 00 00 00       	mov    $0x0,%edi
  801fc7:	eb 4b                	jmp    802014 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801fc9:	89 da                	mov    %ebx,%edx
  801fcb:	89 f0                	mov    %esi,%eax
  801fcd:	e8 6d ff ff ff       	call   801f3f <_pipeisclosed>
  801fd2:	85 c0                	test   %eax,%eax
  801fd4:	75 48                	jne    80201e <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801fd6:	e8 79 ed ff ff       	call   800d54 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801fdb:	8b 43 04             	mov    0x4(%ebx),%eax
  801fde:	8b 0b                	mov    (%ebx),%ecx
  801fe0:	8d 51 20             	lea    0x20(%ecx),%edx
  801fe3:	39 d0                	cmp    %edx,%eax
  801fe5:	73 e2                	jae    801fc9 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801fe7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801fea:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801fee:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801ff1:	89 c2                	mov    %eax,%edx
  801ff3:	c1 fa 1f             	sar    $0x1f,%edx
  801ff6:	89 d1                	mov    %edx,%ecx
  801ff8:	c1 e9 1b             	shr    $0x1b,%ecx
  801ffb:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801ffe:	83 e2 1f             	and    $0x1f,%edx
  802001:	29 ca                	sub    %ecx,%edx
  802003:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802007:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80200b:	83 c0 01             	add    $0x1,%eax
  80200e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802011:	83 c7 01             	add    $0x1,%edi
  802014:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802017:	75 c2                	jne    801fdb <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802019:	8b 45 10             	mov    0x10(%ebp),%eax
  80201c:	eb 05                	jmp    802023 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80201e:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802023:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802026:	5b                   	pop    %ebx
  802027:	5e                   	pop    %esi
  802028:	5f                   	pop    %edi
  802029:	5d                   	pop    %ebp
  80202a:	c3                   	ret    

0080202b <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80202b:	55                   	push   %ebp
  80202c:	89 e5                	mov    %esp,%ebp
  80202e:	57                   	push   %edi
  80202f:	56                   	push   %esi
  802030:	53                   	push   %ebx
  802031:	83 ec 18             	sub    $0x18,%esp
  802034:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802037:	57                   	push   %edi
  802038:	e8 ff f1 ff ff       	call   80123c <fd2data>
  80203d:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80203f:	83 c4 10             	add    $0x10,%esp
  802042:	bb 00 00 00 00       	mov    $0x0,%ebx
  802047:	eb 3d                	jmp    802086 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802049:	85 db                	test   %ebx,%ebx
  80204b:	74 04                	je     802051 <devpipe_read+0x26>
				return i;
  80204d:	89 d8                	mov    %ebx,%eax
  80204f:	eb 44                	jmp    802095 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802051:	89 f2                	mov    %esi,%edx
  802053:	89 f8                	mov    %edi,%eax
  802055:	e8 e5 fe ff ff       	call   801f3f <_pipeisclosed>
  80205a:	85 c0                	test   %eax,%eax
  80205c:	75 32                	jne    802090 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80205e:	e8 f1 ec ff ff       	call   800d54 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802063:	8b 06                	mov    (%esi),%eax
  802065:	3b 46 04             	cmp    0x4(%esi),%eax
  802068:	74 df                	je     802049 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80206a:	99                   	cltd   
  80206b:	c1 ea 1b             	shr    $0x1b,%edx
  80206e:	01 d0                	add    %edx,%eax
  802070:	83 e0 1f             	and    $0x1f,%eax
  802073:	29 d0                	sub    %edx,%eax
  802075:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80207a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80207d:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802080:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802083:	83 c3 01             	add    $0x1,%ebx
  802086:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802089:	75 d8                	jne    802063 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80208b:	8b 45 10             	mov    0x10(%ebp),%eax
  80208e:	eb 05                	jmp    802095 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802090:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802095:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802098:	5b                   	pop    %ebx
  802099:	5e                   	pop    %esi
  80209a:	5f                   	pop    %edi
  80209b:	5d                   	pop    %ebp
  80209c:	c3                   	ret    

0080209d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80209d:	55                   	push   %ebp
  80209e:	89 e5                	mov    %esp,%ebp
  8020a0:	56                   	push   %esi
  8020a1:	53                   	push   %ebx
  8020a2:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8020a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020a8:	50                   	push   %eax
  8020a9:	e8 a5 f1 ff ff       	call   801253 <fd_alloc>
  8020ae:	83 c4 10             	add    $0x10,%esp
  8020b1:	89 c2                	mov    %eax,%edx
  8020b3:	85 c0                	test   %eax,%eax
  8020b5:	0f 88 2c 01 00 00    	js     8021e7 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020bb:	83 ec 04             	sub    $0x4,%esp
  8020be:	68 07 04 00 00       	push   $0x407
  8020c3:	ff 75 f4             	pushl  -0xc(%ebp)
  8020c6:	6a 00                	push   $0x0
  8020c8:	e8 a6 ec ff ff       	call   800d73 <sys_page_alloc>
  8020cd:	83 c4 10             	add    $0x10,%esp
  8020d0:	89 c2                	mov    %eax,%edx
  8020d2:	85 c0                	test   %eax,%eax
  8020d4:	0f 88 0d 01 00 00    	js     8021e7 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8020da:	83 ec 0c             	sub    $0xc,%esp
  8020dd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8020e0:	50                   	push   %eax
  8020e1:	e8 6d f1 ff ff       	call   801253 <fd_alloc>
  8020e6:	89 c3                	mov    %eax,%ebx
  8020e8:	83 c4 10             	add    $0x10,%esp
  8020eb:	85 c0                	test   %eax,%eax
  8020ed:	0f 88 e2 00 00 00    	js     8021d5 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020f3:	83 ec 04             	sub    $0x4,%esp
  8020f6:	68 07 04 00 00       	push   $0x407
  8020fb:	ff 75 f0             	pushl  -0x10(%ebp)
  8020fe:	6a 00                	push   $0x0
  802100:	e8 6e ec ff ff       	call   800d73 <sys_page_alloc>
  802105:	89 c3                	mov    %eax,%ebx
  802107:	83 c4 10             	add    $0x10,%esp
  80210a:	85 c0                	test   %eax,%eax
  80210c:	0f 88 c3 00 00 00    	js     8021d5 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802112:	83 ec 0c             	sub    $0xc,%esp
  802115:	ff 75 f4             	pushl  -0xc(%ebp)
  802118:	e8 1f f1 ff ff       	call   80123c <fd2data>
  80211d:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80211f:	83 c4 0c             	add    $0xc,%esp
  802122:	68 07 04 00 00       	push   $0x407
  802127:	50                   	push   %eax
  802128:	6a 00                	push   $0x0
  80212a:	e8 44 ec ff ff       	call   800d73 <sys_page_alloc>
  80212f:	89 c3                	mov    %eax,%ebx
  802131:	83 c4 10             	add    $0x10,%esp
  802134:	85 c0                	test   %eax,%eax
  802136:	0f 88 89 00 00 00    	js     8021c5 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80213c:	83 ec 0c             	sub    $0xc,%esp
  80213f:	ff 75 f0             	pushl  -0x10(%ebp)
  802142:	e8 f5 f0 ff ff       	call   80123c <fd2data>
  802147:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80214e:	50                   	push   %eax
  80214f:	6a 00                	push   $0x0
  802151:	56                   	push   %esi
  802152:	6a 00                	push   $0x0
  802154:	e8 5d ec ff ff       	call   800db6 <sys_page_map>
  802159:	89 c3                	mov    %eax,%ebx
  80215b:	83 c4 20             	add    $0x20,%esp
  80215e:	85 c0                	test   %eax,%eax
  802160:	78 55                	js     8021b7 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802162:	8b 15 40 30 80 00    	mov    0x803040,%edx
  802168:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80216b:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80216d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802170:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802177:	8b 15 40 30 80 00    	mov    0x803040,%edx
  80217d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802180:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802182:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802185:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80218c:	83 ec 0c             	sub    $0xc,%esp
  80218f:	ff 75 f4             	pushl  -0xc(%ebp)
  802192:	e8 95 f0 ff ff       	call   80122c <fd2num>
  802197:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80219a:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80219c:	83 c4 04             	add    $0x4,%esp
  80219f:	ff 75 f0             	pushl  -0x10(%ebp)
  8021a2:	e8 85 f0 ff ff       	call   80122c <fd2num>
  8021a7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021aa:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8021ad:	83 c4 10             	add    $0x10,%esp
  8021b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8021b5:	eb 30                	jmp    8021e7 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8021b7:	83 ec 08             	sub    $0x8,%esp
  8021ba:	56                   	push   %esi
  8021bb:	6a 00                	push   $0x0
  8021bd:	e8 36 ec ff ff       	call   800df8 <sys_page_unmap>
  8021c2:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8021c5:	83 ec 08             	sub    $0x8,%esp
  8021c8:	ff 75 f0             	pushl  -0x10(%ebp)
  8021cb:	6a 00                	push   $0x0
  8021cd:	e8 26 ec ff ff       	call   800df8 <sys_page_unmap>
  8021d2:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8021d5:	83 ec 08             	sub    $0x8,%esp
  8021d8:	ff 75 f4             	pushl  -0xc(%ebp)
  8021db:	6a 00                	push   $0x0
  8021dd:	e8 16 ec ff ff       	call   800df8 <sys_page_unmap>
  8021e2:	83 c4 10             	add    $0x10,%esp
  8021e5:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8021e7:	89 d0                	mov    %edx,%eax
  8021e9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021ec:	5b                   	pop    %ebx
  8021ed:	5e                   	pop    %esi
  8021ee:	5d                   	pop    %ebp
  8021ef:	c3                   	ret    

008021f0 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8021f0:	55                   	push   %ebp
  8021f1:	89 e5                	mov    %esp,%ebp
  8021f3:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021f9:	50                   	push   %eax
  8021fa:	ff 75 08             	pushl  0x8(%ebp)
  8021fd:	e8 a0 f0 ff ff       	call   8012a2 <fd_lookup>
  802202:	83 c4 10             	add    $0x10,%esp
  802205:	85 c0                	test   %eax,%eax
  802207:	78 18                	js     802221 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802209:	83 ec 0c             	sub    $0xc,%esp
  80220c:	ff 75 f4             	pushl  -0xc(%ebp)
  80220f:	e8 28 f0 ff ff       	call   80123c <fd2data>
	return _pipeisclosed(fd, p);
  802214:	89 c2                	mov    %eax,%edx
  802216:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802219:	e8 21 fd ff ff       	call   801f3f <_pipeisclosed>
  80221e:	83 c4 10             	add    $0x10,%esp
}
  802221:	c9                   	leave  
  802222:	c3                   	ret    

00802223 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802223:	55                   	push   %ebp
  802224:	89 e5                	mov    %esp,%ebp
  802226:	56                   	push   %esi
  802227:	53                   	push   %ebx
  802228:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  80222b:	85 f6                	test   %esi,%esi
  80222d:	75 16                	jne    802245 <wait+0x22>
  80222f:	68 97 2e 80 00       	push   $0x802e97
  802234:	68 0c 2e 80 00       	push   $0x802e0c
  802239:	6a 09                	push   $0x9
  80223b:	68 a2 2e 80 00       	push   $0x802ea2
  802240:	e8 cd e0 ff ff       	call   800312 <_panic>
	e = &envs[ENVX(envid)];
  802245:	89 f3                	mov    %esi,%ebx
  802247:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80224d:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  802250:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  802256:	eb 05                	jmp    80225d <wait+0x3a>
		sys_yield();
  802258:	e8 f7 ea ff ff       	call   800d54 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80225d:	8b 43 48             	mov    0x48(%ebx),%eax
  802260:	39 c6                	cmp    %eax,%esi
  802262:	75 07                	jne    80226b <wait+0x48>
  802264:	8b 43 54             	mov    0x54(%ebx),%eax
  802267:	85 c0                	test   %eax,%eax
  802269:	75 ed                	jne    802258 <wait+0x35>
		sys_yield();
}
  80226b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80226e:	5b                   	pop    %ebx
  80226f:	5e                   	pop    %esi
  802270:	5d                   	pop    %ebp
  802271:	c3                   	ret    

00802272 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802272:	55                   	push   %ebp
  802273:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802275:	b8 00 00 00 00       	mov    $0x0,%eax
  80227a:	5d                   	pop    %ebp
  80227b:	c3                   	ret    

0080227c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80227c:	55                   	push   %ebp
  80227d:	89 e5                	mov    %esp,%ebp
  80227f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802282:	68 ad 2e 80 00       	push   $0x802ead
  802287:	ff 75 0c             	pushl  0xc(%ebp)
  80228a:	e8 e1 e6 ff ff       	call   800970 <strcpy>
	return 0;
}
  80228f:	b8 00 00 00 00       	mov    $0x0,%eax
  802294:	c9                   	leave  
  802295:	c3                   	ret    

00802296 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802296:	55                   	push   %ebp
  802297:	89 e5                	mov    %esp,%ebp
  802299:	57                   	push   %edi
  80229a:	56                   	push   %esi
  80229b:	53                   	push   %ebx
  80229c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022a2:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8022a7:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022ad:	eb 2d                	jmp    8022dc <devcons_write+0x46>
		m = n - tot;
  8022af:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8022b2:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8022b4:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8022b7:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8022bc:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8022bf:	83 ec 04             	sub    $0x4,%esp
  8022c2:	53                   	push   %ebx
  8022c3:	03 45 0c             	add    0xc(%ebp),%eax
  8022c6:	50                   	push   %eax
  8022c7:	57                   	push   %edi
  8022c8:	e8 35 e8 ff ff       	call   800b02 <memmove>
		sys_cputs(buf, m);
  8022cd:	83 c4 08             	add    $0x8,%esp
  8022d0:	53                   	push   %ebx
  8022d1:	57                   	push   %edi
  8022d2:	e8 e0 e9 ff ff       	call   800cb7 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022d7:	01 de                	add    %ebx,%esi
  8022d9:	83 c4 10             	add    $0x10,%esp
  8022dc:	89 f0                	mov    %esi,%eax
  8022de:	3b 75 10             	cmp    0x10(%ebp),%esi
  8022e1:	72 cc                	jb     8022af <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8022e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022e6:	5b                   	pop    %ebx
  8022e7:	5e                   	pop    %esi
  8022e8:	5f                   	pop    %edi
  8022e9:	5d                   	pop    %ebp
  8022ea:	c3                   	ret    

008022eb <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8022eb:	55                   	push   %ebp
  8022ec:	89 e5                	mov    %esp,%ebp
  8022ee:	83 ec 08             	sub    $0x8,%esp
  8022f1:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8022f6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8022fa:	74 2a                	je     802326 <devcons_read+0x3b>
  8022fc:	eb 05                	jmp    802303 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8022fe:	e8 51 ea ff ff       	call   800d54 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802303:	e8 cd e9 ff ff       	call   800cd5 <sys_cgetc>
  802308:	85 c0                	test   %eax,%eax
  80230a:	74 f2                	je     8022fe <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80230c:	85 c0                	test   %eax,%eax
  80230e:	78 16                	js     802326 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802310:	83 f8 04             	cmp    $0x4,%eax
  802313:	74 0c                	je     802321 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802315:	8b 55 0c             	mov    0xc(%ebp),%edx
  802318:	88 02                	mov    %al,(%edx)
	return 1;
  80231a:	b8 01 00 00 00       	mov    $0x1,%eax
  80231f:	eb 05                	jmp    802326 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802321:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802326:	c9                   	leave  
  802327:	c3                   	ret    

00802328 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802328:	55                   	push   %ebp
  802329:	89 e5                	mov    %esp,%ebp
  80232b:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80232e:	8b 45 08             	mov    0x8(%ebp),%eax
  802331:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802334:	6a 01                	push   $0x1
  802336:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802339:	50                   	push   %eax
  80233a:	e8 78 e9 ff ff       	call   800cb7 <sys_cputs>
}
  80233f:	83 c4 10             	add    $0x10,%esp
  802342:	c9                   	leave  
  802343:	c3                   	ret    

00802344 <getchar>:

int
getchar(void)
{
  802344:	55                   	push   %ebp
  802345:	89 e5                	mov    %esp,%ebp
  802347:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80234a:	6a 01                	push   $0x1
  80234c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80234f:	50                   	push   %eax
  802350:	6a 00                	push   $0x0
  802352:	e8 b1 f1 ff ff       	call   801508 <read>
	if (r < 0)
  802357:	83 c4 10             	add    $0x10,%esp
  80235a:	85 c0                	test   %eax,%eax
  80235c:	78 0f                	js     80236d <getchar+0x29>
		return r;
	if (r < 1)
  80235e:	85 c0                	test   %eax,%eax
  802360:	7e 06                	jle    802368 <getchar+0x24>
		return -E_EOF;
	return c;
  802362:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802366:	eb 05                	jmp    80236d <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802368:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80236d:	c9                   	leave  
  80236e:	c3                   	ret    

0080236f <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80236f:	55                   	push   %ebp
  802370:	89 e5                	mov    %esp,%ebp
  802372:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802375:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802378:	50                   	push   %eax
  802379:	ff 75 08             	pushl  0x8(%ebp)
  80237c:	e8 21 ef ff ff       	call   8012a2 <fd_lookup>
  802381:	83 c4 10             	add    $0x10,%esp
  802384:	85 c0                	test   %eax,%eax
  802386:	78 11                	js     802399 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802388:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80238b:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  802391:	39 10                	cmp    %edx,(%eax)
  802393:	0f 94 c0             	sete   %al
  802396:	0f b6 c0             	movzbl %al,%eax
}
  802399:	c9                   	leave  
  80239a:	c3                   	ret    

0080239b <opencons>:

int
opencons(void)
{
  80239b:	55                   	push   %ebp
  80239c:	89 e5                	mov    %esp,%ebp
  80239e:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8023a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023a4:	50                   	push   %eax
  8023a5:	e8 a9 ee ff ff       	call   801253 <fd_alloc>
  8023aa:	83 c4 10             	add    $0x10,%esp
		return r;
  8023ad:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8023af:	85 c0                	test   %eax,%eax
  8023b1:	78 3e                	js     8023f1 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8023b3:	83 ec 04             	sub    $0x4,%esp
  8023b6:	68 07 04 00 00       	push   $0x407
  8023bb:	ff 75 f4             	pushl  -0xc(%ebp)
  8023be:	6a 00                	push   $0x0
  8023c0:	e8 ae e9 ff ff       	call   800d73 <sys_page_alloc>
  8023c5:	83 c4 10             	add    $0x10,%esp
		return r;
  8023c8:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8023ca:	85 c0                	test   %eax,%eax
  8023cc:	78 23                	js     8023f1 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8023ce:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  8023d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023d7:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8023d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023dc:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8023e3:	83 ec 0c             	sub    $0xc,%esp
  8023e6:	50                   	push   %eax
  8023e7:	e8 40 ee ff ff       	call   80122c <fd2num>
  8023ec:	89 c2                	mov    %eax,%edx
  8023ee:	83 c4 10             	add    $0x10,%esp
}
  8023f1:	89 d0                	mov    %edx,%eax
  8023f3:	c9                   	leave  
  8023f4:	c3                   	ret    

008023f5 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8023f5:	55                   	push   %ebp
  8023f6:	89 e5                	mov    %esp,%ebp
  8023f8:	53                   	push   %ebx
  8023f9:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  8023fc:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802403:	75 28                	jne    80242d <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  802405:	e8 2b e9 ff ff       	call   800d35 <sys_getenvid>
  80240a:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_U | PTE_W);
  80240c:	83 ec 04             	sub    $0x4,%esp
  80240f:	6a 06                	push   $0x6
  802411:	68 00 f0 bf ee       	push   $0xeebff000
  802416:	50                   	push   %eax
  802417:	e8 57 e9 ff ff       	call   800d73 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  80241c:	83 c4 08             	add    $0x8,%esp
  80241f:	68 3a 24 80 00       	push   $0x80243a
  802424:	53                   	push   %ebx
  802425:	e8 94 ea ff ff       	call   800ebe <sys_env_set_pgfault_upcall>
  80242a:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80242d:	8b 45 08             	mov    0x8(%ebp),%eax
  802430:	a3 00 70 80 00       	mov    %eax,0x807000
}
  802435:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802438:	c9                   	leave  
  802439:	c3                   	ret    

0080243a <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80243a:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80243b:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802440:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802442:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	# My method is different. Copy the values to the other stack
	# in a convinient way, and then pop everything.
	movl %esp, %ebp		# ebp refers to the exception stack
  802445:	89 e5                	mov    %esp,%ebp
	movl 48(%ebp), %esp 	# go to other stack
  802447:	8b 65 30             	mov    0x30(%ebp),%esp

	pushl 40(%ebp)		# eip - ORDER SWITCHED WITH EFLAGS
  80244a:	ff 75 28             	pushl  0x28(%ebp)
	pushl 44(%ebp)      	# eflags
  80244d:	ff 75 2c             	pushl  0x2c(%ebp)
	pushl 36(%ebp)		# all the 8 remaining regs
  802450:	ff 75 24             	pushl  0x24(%ebp)
	pushl 32(%ebp)
  802453:	ff 75 20             	pushl  0x20(%ebp)
	pushl 28(%ebp)
  802456:	ff 75 1c             	pushl  0x1c(%ebp)
	pushl 24(%ebp)
  802459:	ff 75 18             	pushl  0x18(%ebp)
	pushl 20(%ebp)
  80245c:	ff 75 14             	pushl  0x14(%ebp)
	pushl 16(%ebp)
  80245f:	ff 75 10             	pushl  0x10(%ebp)
	pushl 12(%ebp)
  802462:	ff 75 0c             	pushl  0xc(%ebp)
	pushl 8(%ebp)
  802465:	ff 75 08             	pushl  0x8(%ebp)

	popal			# now just pop everything!
  802468:	61                   	popa   
	popfl
  802469:	9d                   	popf   
	ret
  80246a:	c3                   	ret    

0080246b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80246b:	55                   	push   %ebp
  80246c:	89 e5                	mov    %esp,%ebp
  80246e:	56                   	push   %esi
  80246f:	53                   	push   %ebx
  802470:	8b 75 08             	mov    0x8(%ebp),%esi
  802473:	8b 45 0c             	mov    0xc(%ebp),%eax
  802476:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  802479:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  80247b:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  802480:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  802483:	83 ec 0c             	sub    $0xc,%esp
  802486:	50                   	push   %eax
  802487:	e8 97 ea ff ff       	call   800f23 <sys_ipc_recv>

	if (r < 0) {
  80248c:	83 c4 10             	add    $0x10,%esp
  80248f:	85 c0                	test   %eax,%eax
  802491:	79 16                	jns    8024a9 <ipc_recv+0x3e>
		if (from_env_store)
  802493:	85 f6                	test   %esi,%esi
  802495:	74 06                	je     80249d <ipc_recv+0x32>
			*from_env_store = 0;
  802497:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  80249d:	85 db                	test   %ebx,%ebx
  80249f:	74 2c                	je     8024cd <ipc_recv+0x62>
			*perm_store = 0;
  8024a1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8024a7:	eb 24                	jmp    8024cd <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  8024a9:	85 f6                	test   %esi,%esi
  8024ab:	74 0a                	je     8024b7 <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  8024ad:	a1 08 40 80 00       	mov    0x804008,%eax
  8024b2:	8b 40 74             	mov    0x74(%eax),%eax
  8024b5:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  8024b7:	85 db                	test   %ebx,%ebx
  8024b9:	74 0a                	je     8024c5 <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  8024bb:	a1 08 40 80 00       	mov    0x804008,%eax
  8024c0:	8b 40 78             	mov    0x78(%eax),%eax
  8024c3:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  8024c5:	a1 08 40 80 00       	mov    0x804008,%eax
  8024ca:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  8024cd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8024d0:	5b                   	pop    %ebx
  8024d1:	5e                   	pop    %esi
  8024d2:	5d                   	pop    %ebp
  8024d3:	c3                   	ret    

008024d4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8024d4:	55                   	push   %ebp
  8024d5:	89 e5                	mov    %esp,%ebp
  8024d7:	57                   	push   %edi
  8024d8:	56                   	push   %esi
  8024d9:	53                   	push   %ebx
  8024da:	83 ec 0c             	sub    $0xc,%esp
  8024dd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8024e0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8024e3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  8024e6:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  8024e8:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  8024ed:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  8024f0:	ff 75 14             	pushl  0x14(%ebp)
  8024f3:	53                   	push   %ebx
  8024f4:	56                   	push   %esi
  8024f5:	57                   	push   %edi
  8024f6:	e8 05 ea ff ff       	call   800f00 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  8024fb:	83 c4 10             	add    $0x10,%esp
  8024fe:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802501:	75 07                	jne    80250a <ipc_send+0x36>
			sys_yield();
  802503:	e8 4c e8 ff ff       	call   800d54 <sys_yield>
  802508:	eb e6                	jmp    8024f0 <ipc_send+0x1c>
		} else if (r < 0) {
  80250a:	85 c0                	test   %eax,%eax
  80250c:	79 12                	jns    802520 <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  80250e:	50                   	push   %eax
  80250f:	68 b9 2e 80 00       	push   $0x802eb9
  802514:	6a 51                	push   $0x51
  802516:	68 c6 2e 80 00       	push   $0x802ec6
  80251b:	e8 f2 dd ff ff       	call   800312 <_panic>
		}
	}
}
  802520:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802523:	5b                   	pop    %ebx
  802524:	5e                   	pop    %esi
  802525:	5f                   	pop    %edi
  802526:	5d                   	pop    %ebp
  802527:	c3                   	ret    

00802528 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802528:	55                   	push   %ebp
  802529:	89 e5                	mov    %esp,%ebp
  80252b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80252e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802533:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802536:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80253c:	8b 52 50             	mov    0x50(%edx),%edx
  80253f:	39 ca                	cmp    %ecx,%edx
  802541:	75 0d                	jne    802550 <ipc_find_env+0x28>
			return envs[i].env_id;
  802543:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802546:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80254b:	8b 40 48             	mov    0x48(%eax),%eax
  80254e:	eb 0f                	jmp    80255f <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802550:	83 c0 01             	add    $0x1,%eax
  802553:	3d 00 04 00 00       	cmp    $0x400,%eax
  802558:	75 d9                	jne    802533 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80255a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80255f:	5d                   	pop    %ebp
  802560:	c3                   	ret    

00802561 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802561:	55                   	push   %ebp
  802562:	89 e5                	mov    %esp,%ebp
  802564:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802567:	89 d0                	mov    %edx,%eax
  802569:	c1 e8 16             	shr    $0x16,%eax
  80256c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802573:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802578:	f6 c1 01             	test   $0x1,%cl
  80257b:	74 1d                	je     80259a <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80257d:	c1 ea 0c             	shr    $0xc,%edx
  802580:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802587:	f6 c2 01             	test   $0x1,%dl
  80258a:	74 0e                	je     80259a <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80258c:	c1 ea 0c             	shr    $0xc,%edx
  80258f:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802596:	ef 
  802597:	0f b7 c0             	movzwl %ax,%eax
}
  80259a:	5d                   	pop    %ebp
  80259b:	c3                   	ret    
  80259c:	66 90                	xchg   %ax,%ax
  80259e:	66 90                	xchg   %ax,%ax

008025a0 <__udivdi3>:
  8025a0:	55                   	push   %ebp
  8025a1:	57                   	push   %edi
  8025a2:	56                   	push   %esi
  8025a3:	53                   	push   %ebx
  8025a4:	83 ec 1c             	sub    $0x1c,%esp
  8025a7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8025ab:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8025af:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8025b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8025b7:	85 f6                	test   %esi,%esi
  8025b9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8025bd:	89 ca                	mov    %ecx,%edx
  8025bf:	89 f8                	mov    %edi,%eax
  8025c1:	75 3d                	jne    802600 <__udivdi3+0x60>
  8025c3:	39 cf                	cmp    %ecx,%edi
  8025c5:	0f 87 c5 00 00 00    	ja     802690 <__udivdi3+0xf0>
  8025cb:	85 ff                	test   %edi,%edi
  8025cd:	89 fd                	mov    %edi,%ebp
  8025cf:	75 0b                	jne    8025dc <__udivdi3+0x3c>
  8025d1:	b8 01 00 00 00       	mov    $0x1,%eax
  8025d6:	31 d2                	xor    %edx,%edx
  8025d8:	f7 f7                	div    %edi
  8025da:	89 c5                	mov    %eax,%ebp
  8025dc:	89 c8                	mov    %ecx,%eax
  8025de:	31 d2                	xor    %edx,%edx
  8025e0:	f7 f5                	div    %ebp
  8025e2:	89 c1                	mov    %eax,%ecx
  8025e4:	89 d8                	mov    %ebx,%eax
  8025e6:	89 cf                	mov    %ecx,%edi
  8025e8:	f7 f5                	div    %ebp
  8025ea:	89 c3                	mov    %eax,%ebx
  8025ec:	89 d8                	mov    %ebx,%eax
  8025ee:	89 fa                	mov    %edi,%edx
  8025f0:	83 c4 1c             	add    $0x1c,%esp
  8025f3:	5b                   	pop    %ebx
  8025f4:	5e                   	pop    %esi
  8025f5:	5f                   	pop    %edi
  8025f6:	5d                   	pop    %ebp
  8025f7:	c3                   	ret    
  8025f8:	90                   	nop
  8025f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802600:	39 ce                	cmp    %ecx,%esi
  802602:	77 74                	ja     802678 <__udivdi3+0xd8>
  802604:	0f bd fe             	bsr    %esi,%edi
  802607:	83 f7 1f             	xor    $0x1f,%edi
  80260a:	0f 84 98 00 00 00    	je     8026a8 <__udivdi3+0x108>
  802610:	bb 20 00 00 00       	mov    $0x20,%ebx
  802615:	89 f9                	mov    %edi,%ecx
  802617:	89 c5                	mov    %eax,%ebp
  802619:	29 fb                	sub    %edi,%ebx
  80261b:	d3 e6                	shl    %cl,%esi
  80261d:	89 d9                	mov    %ebx,%ecx
  80261f:	d3 ed                	shr    %cl,%ebp
  802621:	89 f9                	mov    %edi,%ecx
  802623:	d3 e0                	shl    %cl,%eax
  802625:	09 ee                	or     %ebp,%esi
  802627:	89 d9                	mov    %ebx,%ecx
  802629:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80262d:	89 d5                	mov    %edx,%ebp
  80262f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802633:	d3 ed                	shr    %cl,%ebp
  802635:	89 f9                	mov    %edi,%ecx
  802637:	d3 e2                	shl    %cl,%edx
  802639:	89 d9                	mov    %ebx,%ecx
  80263b:	d3 e8                	shr    %cl,%eax
  80263d:	09 c2                	or     %eax,%edx
  80263f:	89 d0                	mov    %edx,%eax
  802641:	89 ea                	mov    %ebp,%edx
  802643:	f7 f6                	div    %esi
  802645:	89 d5                	mov    %edx,%ebp
  802647:	89 c3                	mov    %eax,%ebx
  802649:	f7 64 24 0c          	mull   0xc(%esp)
  80264d:	39 d5                	cmp    %edx,%ebp
  80264f:	72 10                	jb     802661 <__udivdi3+0xc1>
  802651:	8b 74 24 08          	mov    0x8(%esp),%esi
  802655:	89 f9                	mov    %edi,%ecx
  802657:	d3 e6                	shl    %cl,%esi
  802659:	39 c6                	cmp    %eax,%esi
  80265b:	73 07                	jae    802664 <__udivdi3+0xc4>
  80265d:	39 d5                	cmp    %edx,%ebp
  80265f:	75 03                	jne    802664 <__udivdi3+0xc4>
  802661:	83 eb 01             	sub    $0x1,%ebx
  802664:	31 ff                	xor    %edi,%edi
  802666:	89 d8                	mov    %ebx,%eax
  802668:	89 fa                	mov    %edi,%edx
  80266a:	83 c4 1c             	add    $0x1c,%esp
  80266d:	5b                   	pop    %ebx
  80266e:	5e                   	pop    %esi
  80266f:	5f                   	pop    %edi
  802670:	5d                   	pop    %ebp
  802671:	c3                   	ret    
  802672:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802678:	31 ff                	xor    %edi,%edi
  80267a:	31 db                	xor    %ebx,%ebx
  80267c:	89 d8                	mov    %ebx,%eax
  80267e:	89 fa                	mov    %edi,%edx
  802680:	83 c4 1c             	add    $0x1c,%esp
  802683:	5b                   	pop    %ebx
  802684:	5e                   	pop    %esi
  802685:	5f                   	pop    %edi
  802686:	5d                   	pop    %ebp
  802687:	c3                   	ret    
  802688:	90                   	nop
  802689:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802690:	89 d8                	mov    %ebx,%eax
  802692:	f7 f7                	div    %edi
  802694:	31 ff                	xor    %edi,%edi
  802696:	89 c3                	mov    %eax,%ebx
  802698:	89 d8                	mov    %ebx,%eax
  80269a:	89 fa                	mov    %edi,%edx
  80269c:	83 c4 1c             	add    $0x1c,%esp
  80269f:	5b                   	pop    %ebx
  8026a0:	5e                   	pop    %esi
  8026a1:	5f                   	pop    %edi
  8026a2:	5d                   	pop    %ebp
  8026a3:	c3                   	ret    
  8026a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8026a8:	39 ce                	cmp    %ecx,%esi
  8026aa:	72 0c                	jb     8026b8 <__udivdi3+0x118>
  8026ac:	31 db                	xor    %ebx,%ebx
  8026ae:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8026b2:	0f 87 34 ff ff ff    	ja     8025ec <__udivdi3+0x4c>
  8026b8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8026bd:	e9 2a ff ff ff       	jmp    8025ec <__udivdi3+0x4c>
  8026c2:	66 90                	xchg   %ax,%ax
  8026c4:	66 90                	xchg   %ax,%ax
  8026c6:	66 90                	xchg   %ax,%ax
  8026c8:	66 90                	xchg   %ax,%ax
  8026ca:	66 90                	xchg   %ax,%ax
  8026cc:	66 90                	xchg   %ax,%ax
  8026ce:	66 90                	xchg   %ax,%ax

008026d0 <__umoddi3>:
  8026d0:	55                   	push   %ebp
  8026d1:	57                   	push   %edi
  8026d2:	56                   	push   %esi
  8026d3:	53                   	push   %ebx
  8026d4:	83 ec 1c             	sub    $0x1c,%esp
  8026d7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8026db:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8026df:	8b 74 24 34          	mov    0x34(%esp),%esi
  8026e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8026e7:	85 d2                	test   %edx,%edx
  8026e9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8026ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8026f1:	89 f3                	mov    %esi,%ebx
  8026f3:	89 3c 24             	mov    %edi,(%esp)
  8026f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8026fa:	75 1c                	jne    802718 <__umoddi3+0x48>
  8026fc:	39 f7                	cmp    %esi,%edi
  8026fe:	76 50                	jbe    802750 <__umoddi3+0x80>
  802700:	89 c8                	mov    %ecx,%eax
  802702:	89 f2                	mov    %esi,%edx
  802704:	f7 f7                	div    %edi
  802706:	89 d0                	mov    %edx,%eax
  802708:	31 d2                	xor    %edx,%edx
  80270a:	83 c4 1c             	add    $0x1c,%esp
  80270d:	5b                   	pop    %ebx
  80270e:	5e                   	pop    %esi
  80270f:	5f                   	pop    %edi
  802710:	5d                   	pop    %ebp
  802711:	c3                   	ret    
  802712:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802718:	39 f2                	cmp    %esi,%edx
  80271a:	89 d0                	mov    %edx,%eax
  80271c:	77 52                	ja     802770 <__umoddi3+0xa0>
  80271e:	0f bd ea             	bsr    %edx,%ebp
  802721:	83 f5 1f             	xor    $0x1f,%ebp
  802724:	75 5a                	jne    802780 <__umoddi3+0xb0>
  802726:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80272a:	0f 82 e0 00 00 00    	jb     802810 <__umoddi3+0x140>
  802730:	39 0c 24             	cmp    %ecx,(%esp)
  802733:	0f 86 d7 00 00 00    	jbe    802810 <__umoddi3+0x140>
  802739:	8b 44 24 08          	mov    0x8(%esp),%eax
  80273d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802741:	83 c4 1c             	add    $0x1c,%esp
  802744:	5b                   	pop    %ebx
  802745:	5e                   	pop    %esi
  802746:	5f                   	pop    %edi
  802747:	5d                   	pop    %ebp
  802748:	c3                   	ret    
  802749:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802750:	85 ff                	test   %edi,%edi
  802752:	89 fd                	mov    %edi,%ebp
  802754:	75 0b                	jne    802761 <__umoddi3+0x91>
  802756:	b8 01 00 00 00       	mov    $0x1,%eax
  80275b:	31 d2                	xor    %edx,%edx
  80275d:	f7 f7                	div    %edi
  80275f:	89 c5                	mov    %eax,%ebp
  802761:	89 f0                	mov    %esi,%eax
  802763:	31 d2                	xor    %edx,%edx
  802765:	f7 f5                	div    %ebp
  802767:	89 c8                	mov    %ecx,%eax
  802769:	f7 f5                	div    %ebp
  80276b:	89 d0                	mov    %edx,%eax
  80276d:	eb 99                	jmp    802708 <__umoddi3+0x38>
  80276f:	90                   	nop
  802770:	89 c8                	mov    %ecx,%eax
  802772:	89 f2                	mov    %esi,%edx
  802774:	83 c4 1c             	add    $0x1c,%esp
  802777:	5b                   	pop    %ebx
  802778:	5e                   	pop    %esi
  802779:	5f                   	pop    %edi
  80277a:	5d                   	pop    %ebp
  80277b:	c3                   	ret    
  80277c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802780:	8b 34 24             	mov    (%esp),%esi
  802783:	bf 20 00 00 00       	mov    $0x20,%edi
  802788:	89 e9                	mov    %ebp,%ecx
  80278a:	29 ef                	sub    %ebp,%edi
  80278c:	d3 e0                	shl    %cl,%eax
  80278e:	89 f9                	mov    %edi,%ecx
  802790:	89 f2                	mov    %esi,%edx
  802792:	d3 ea                	shr    %cl,%edx
  802794:	89 e9                	mov    %ebp,%ecx
  802796:	09 c2                	or     %eax,%edx
  802798:	89 d8                	mov    %ebx,%eax
  80279a:	89 14 24             	mov    %edx,(%esp)
  80279d:	89 f2                	mov    %esi,%edx
  80279f:	d3 e2                	shl    %cl,%edx
  8027a1:	89 f9                	mov    %edi,%ecx
  8027a3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8027a7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8027ab:	d3 e8                	shr    %cl,%eax
  8027ad:	89 e9                	mov    %ebp,%ecx
  8027af:	89 c6                	mov    %eax,%esi
  8027b1:	d3 e3                	shl    %cl,%ebx
  8027b3:	89 f9                	mov    %edi,%ecx
  8027b5:	89 d0                	mov    %edx,%eax
  8027b7:	d3 e8                	shr    %cl,%eax
  8027b9:	89 e9                	mov    %ebp,%ecx
  8027bb:	09 d8                	or     %ebx,%eax
  8027bd:	89 d3                	mov    %edx,%ebx
  8027bf:	89 f2                	mov    %esi,%edx
  8027c1:	f7 34 24             	divl   (%esp)
  8027c4:	89 d6                	mov    %edx,%esi
  8027c6:	d3 e3                	shl    %cl,%ebx
  8027c8:	f7 64 24 04          	mull   0x4(%esp)
  8027cc:	39 d6                	cmp    %edx,%esi
  8027ce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8027d2:	89 d1                	mov    %edx,%ecx
  8027d4:	89 c3                	mov    %eax,%ebx
  8027d6:	72 08                	jb     8027e0 <__umoddi3+0x110>
  8027d8:	75 11                	jne    8027eb <__umoddi3+0x11b>
  8027da:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8027de:	73 0b                	jae    8027eb <__umoddi3+0x11b>
  8027e0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8027e4:	1b 14 24             	sbb    (%esp),%edx
  8027e7:	89 d1                	mov    %edx,%ecx
  8027e9:	89 c3                	mov    %eax,%ebx
  8027eb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8027ef:	29 da                	sub    %ebx,%edx
  8027f1:	19 ce                	sbb    %ecx,%esi
  8027f3:	89 f9                	mov    %edi,%ecx
  8027f5:	89 f0                	mov    %esi,%eax
  8027f7:	d3 e0                	shl    %cl,%eax
  8027f9:	89 e9                	mov    %ebp,%ecx
  8027fb:	d3 ea                	shr    %cl,%edx
  8027fd:	89 e9                	mov    %ebp,%ecx
  8027ff:	d3 ee                	shr    %cl,%esi
  802801:	09 d0                	or     %edx,%eax
  802803:	89 f2                	mov    %esi,%edx
  802805:	83 c4 1c             	add    $0x1c,%esp
  802808:	5b                   	pop    %ebx
  802809:	5e                   	pop    %esi
  80280a:	5f                   	pop    %edi
  80280b:	5d                   	pop    %ebp
  80280c:	c3                   	ret    
  80280d:	8d 76 00             	lea    0x0(%esi),%esi
  802810:	29 f9                	sub    %edi,%ecx
  802812:	19 d6                	sbb    %edx,%esi
  802814:	89 74 24 04          	mov    %esi,0x4(%esp)
  802818:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80281c:	e9 18 ff ff ff       	jmp    802739 <__umoddi3+0x69>
