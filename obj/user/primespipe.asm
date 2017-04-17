
obj/user/primespipe.debug:     file format elf32-i386


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
  80002c:	e8 07 02 00 00       	call   800238 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(int fd)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
  80003c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i, id, p, pfd[2], wfd, r;

	// fetch a prime from our left neighbor
top:
	if ((r = readn(fd, &p, 4)) != 4)
  80003f:	8d 75 e0             	lea    -0x20(%ebp),%esi
		panic("primeproc could not read initial prime: %d, %e", r, r >= 0 ? 0 : r);

	cprintf("%d\n", p);

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  800042:	8d 7d d8             	lea    -0x28(%ebp),%edi
{
	int i, id, p, pfd[2], wfd, r;

	// fetch a prime from our left neighbor
top:
	if ((r = readn(fd, &p, 4)) != 4)
  800045:	83 ec 04             	sub    $0x4,%esp
  800048:	6a 04                	push   $0x4
  80004a:	56                   	push   %esi
  80004b:	53                   	push   %ebx
  80004c:	e8 ce 14 00 00       	call   80151f <readn>
  800051:	83 c4 10             	add    $0x10,%esp
  800054:	83 f8 04             	cmp    $0x4,%eax
  800057:	74 20                	je     800079 <primeproc+0x46>
		panic("primeproc could not read initial prime: %d, %e", r, r >= 0 ? 0 : r);
  800059:	83 ec 0c             	sub    $0xc,%esp
  80005c:	85 c0                	test   %eax,%eax
  80005e:	ba 00 00 00 00       	mov    $0x0,%edx
  800063:	0f 4e d0             	cmovle %eax,%edx
  800066:	52                   	push   %edx
  800067:	50                   	push   %eax
  800068:	68 80 27 80 00       	push   $0x802780
  80006d:	6a 15                	push   $0x15
  80006f:	68 af 27 80 00       	push   $0x8027af
  800074:	e8 1f 02 00 00       	call   800298 <_panic>

	cprintf("%d\n", p);
  800079:	83 ec 08             	sub    $0x8,%esp
  80007c:	ff 75 e0             	pushl  -0x20(%ebp)
  80007f:	68 c1 27 80 00       	push   $0x8027c1
  800084:	e8 e8 02 00 00       	call   800371 <cprintf>

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  800089:	89 3c 24             	mov    %edi,(%esp)
  80008c:	e8 92 1f 00 00       	call   802023 <pipe>
  800091:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800094:	83 c4 10             	add    $0x10,%esp
  800097:	85 c0                	test   %eax,%eax
  800099:	79 12                	jns    8000ad <primeproc+0x7a>
		panic("pipe: %e", i);
  80009b:	50                   	push   %eax
  80009c:	68 c5 27 80 00       	push   $0x8027c5
  8000a1:	6a 1b                	push   $0x1b
  8000a3:	68 af 27 80 00       	push   $0x8027af
  8000a8:	e8 eb 01 00 00       	call   800298 <_panic>
	if ((id = fork()) < 0)
  8000ad:	e8 0b 10 00 00       	call   8010bd <fork>
  8000b2:	85 c0                	test   %eax,%eax
  8000b4:	79 12                	jns    8000c8 <primeproc+0x95>
		panic("fork: %e", id);
  8000b6:	50                   	push   %eax
  8000b7:	68 d3 2b 80 00       	push   $0x802bd3
  8000bc:	6a 1d                	push   $0x1d
  8000be:	68 af 27 80 00       	push   $0x8027af
  8000c3:	e8 d0 01 00 00       	call   800298 <_panic>
	if (id == 0) {
  8000c8:	85 c0                	test   %eax,%eax
  8000ca:	75 1f                	jne    8000eb <primeproc+0xb8>
		close(fd);
  8000cc:	83 ec 0c             	sub    $0xc,%esp
  8000cf:	53                   	push   %ebx
  8000d0:	e8 7d 12 00 00       	call   801352 <close>
		close(pfd[1]);
  8000d5:	83 c4 04             	add    $0x4,%esp
  8000d8:	ff 75 dc             	pushl  -0x24(%ebp)
  8000db:	e8 72 12 00 00       	call   801352 <close>
		fd = pfd[0];
  8000e0:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		goto top;
  8000e3:	83 c4 10             	add    $0x10,%esp
  8000e6:	e9 5a ff ff ff       	jmp    800045 <primeproc+0x12>
	}

	close(pfd[0]);
  8000eb:	83 ec 0c             	sub    $0xc,%esp
  8000ee:	ff 75 d8             	pushl  -0x28(%ebp)
  8000f1:	e8 5c 12 00 00       	call   801352 <close>
	wfd = pfd[1];
  8000f6:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8000f9:	83 c4 10             	add    $0x10,%esp

	// filter out multiples of our prime
	for (;;) {
		if ((r=readn(fd, &i, 4)) != 4)
  8000fc:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  8000ff:	83 ec 04             	sub    $0x4,%esp
  800102:	6a 04                	push   $0x4
  800104:	56                   	push   %esi
  800105:	53                   	push   %ebx
  800106:	e8 14 14 00 00       	call   80151f <readn>
  80010b:	83 c4 10             	add    $0x10,%esp
  80010e:	83 f8 04             	cmp    $0x4,%eax
  800111:	74 24                	je     800137 <primeproc+0x104>
			panic("primeproc %d readn %d %d %e", p, fd, r, r >= 0 ? 0 : r);
  800113:	83 ec 04             	sub    $0x4,%esp
  800116:	85 c0                	test   %eax,%eax
  800118:	ba 00 00 00 00       	mov    $0x0,%edx
  80011d:	0f 4e d0             	cmovle %eax,%edx
  800120:	52                   	push   %edx
  800121:	50                   	push   %eax
  800122:	53                   	push   %ebx
  800123:	ff 75 e0             	pushl  -0x20(%ebp)
  800126:	68 ce 27 80 00       	push   $0x8027ce
  80012b:	6a 2b                	push   $0x2b
  80012d:	68 af 27 80 00       	push   $0x8027af
  800132:	e8 61 01 00 00       	call   800298 <_panic>
		if (i%p)
  800137:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80013a:	99                   	cltd   
  80013b:	f7 7d e0             	idivl  -0x20(%ebp)
  80013e:	85 d2                	test   %edx,%edx
  800140:	74 bd                	je     8000ff <primeproc+0xcc>
			if ((r=write(wfd, &i, 4)) != 4)
  800142:	83 ec 04             	sub    $0x4,%esp
  800145:	6a 04                	push   $0x4
  800147:	56                   	push   %esi
  800148:	57                   	push   %edi
  800149:	e8 1a 14 00 00       	call   801568 <write>
  80014e:	83 c4 10             	add    $0x10,%esp
  800151:	83 f8 04             	cmp    $0x4,%eax
  800154:	74 a9                	je     8000ff <primeproc+0xcc>
				panic("primeproc %d write: %d %e", p, r, r >= 0 ? 0 : r);
  800156:	83 ec 08             	sub    $0x8,%esp
  800159:	85 c0                	test   %eax,%eax
  80015b:	ba 00 00 00 00       	mov    $0x0,%edx
  800160:	0f 4e d0             	cmovle %eax,%edx
  800163:	52                   	push   %edx
  800164:	50                   	push   %eax
  800165:	ff 75 e0             	pushl  -0x20(%ebp)
  800168:	68 ea 27 80 00       	push   $0x8027ea
  80016d:	6a 2e                	push   $0x2e
  80016f:	68 af 27 80 00       	push   $0x8027af
  800174:	e8 1f 01 00 00       	call   800298 <_panic>

00800179 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  800179:	55                   	push   %ebp
  80017a:	89 e5                	mov    %esp,%ebp
  80017c:	53                   	push   %ebx
  80017d:	83 ec 20             	sub    $0x20,%esp
	int i, id, p[2], r;

	binaryname = "primespipe";
  800180:	c7 05 00 30 80 00 04 	movl   $0x802804,0x803000
  800187:	28 80 00 

	if ((i=pipe(p)) < 0)
  80018a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80018d:	50                   	push   %eax
  80018e:	e8 90 1e 00 00       	call   802023 <pipe>
  800193:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800196:	83 c4 10             	add    $0x10,%esp
  800199:	85 c0                	test   %eax,%eax
  80019b:	79 12                	jns    8001af <umain+0x36>
		panic("pipe: %e", i);
  80019d:	50                   	push   %eax
  80019e:	68 c5 27 80 00       	push   $0x8027c5
  8001a3:	6a 3a                	push   $0x3a
  8001a5:	68 af 27 80 00       	push   $0x8027af
  8001aa:	e8 e9 00 00 00       	call   800298 <_panic>

	// fork the first prime process in the chain
	if ((id=fork()) < 0)
  8001af:	e8 09 0f 00 00       	call   8010bd <fork>
  8001b4:	85 c0                	test   %eax,%eax
  8001b6:	79 12                	jns    8001ca <umain+0x51>
		panic("fork: %e", id);
  8001b8:	50                   	push   %eax
  8001b9:	68 d3 2b 80 00       	push   $0x802bd3
  8001be:	6a 3e                	push   $0x3e
  8001c0:	68 af 27 80 00       	push   $0x8027af
  8001c5:	e8 ce 00 00 00       	call   800298 <_panic>

	if (id == 0) {
  8001ca:	85 c0                	test   %eax,%eax
  8001cc:	75 16                	jne    8001e4 <umain+0x6b>
		close(p[1]);
  8001ce:	83 ec 0c             	sub    $0xc,%esp
  8001d1:	ff 75 f0             	pushl  -0x10(%ebp)
  8001d4:	e8 79 11 00 00       	call   801352 <close>
		primeproc(p[0]);
  8001d9:	83 c4 04             	add    $0x4,%esp
  8001dc:	ff 75 ec             	pushl  -0x14(%ebp)
  8001df:	e8 4f fe ff ff       	call   800033 <primeproc>
	}

	close(p[0]);
  8001e4:	83 ec 0c             	sub    $0xc,%esp
  8001e7:	ff 75 ec             	pushl  -0x14(%ebp)
  8001ea:	e8 63 11 00 00       	call   801352 <close>

	// feed all the integers through
	for (i=2;; i++)
  8001ef:	c7 45 f4 02 00 00 00 	movl   $0x2,-0xc(%ebp)
  8001f6:	83 c4 10             	add    $0x10,%esp
		if ((r=write(p[1], &i, 4)) != 4)
  8001f9:	8d 5d f4             	lea    -0xc(%ebp),%ebx
  8001fc:	83 ec 04             	sub    $0x4,%esp
  8001ff:	6a 04                	push   $0x4
  800201:	53                   	push   %ebx
  800202:	ff 75 f0             	pushl  -0x10(%ebp)
  800205:	e8 5e 13 00 00       	call   801568 <write>
  80020a:	83 c4 10             	add    $0x10,%esp
  80020d:	83 f8 04             	cmp    $0x4,%eax
  800210:	74 20                	je     800232 <umain+0xb9>
			panic("generator write: %d, %e", r, r >= 0 ? 0 : r);
  800212:	83 ec 0c             	sub    $0xc,%esp
  800215:	85 c0                	test   %eax,%eax
  800217:	ba 00 00 00 00       	mov    $0x0,%edx
  80021c:	0f 4e d0             	cmovle %eax,%edx
  80021f:	52                   	push   %edx
  800220:	50                   	push   %eax
  800221:	68 0f 28 80 00       	push   $0x80280f
  800226:	6a 4a                	push   $0x4a
  800228:	68 af 27 80 00       	push   $0x8027af
  80022d:	e8 66 00 00 00       	call   800298 <_panic>
	}

	close(p[0]);

	// feed all the integers through
	for (i=2;; i++)
  800232:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
		if ((r=write(p[1], &i, 4)) != 4)
			panic("generator write: %d, %e", r, r >= 0 ? 0 : r);
}
  800236:	eb c4                	jmp    8001fc <umain+0x83>

00800238 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800238:	55                   	push   %ebp
  800239:	89 e5                	mov    %esp,%ebp
  80023b:	56                   	push   %esi
  80023c:	53                   	push   %ebx
  80023d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800240:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800243:	e8 73 0a 00 00       	call   800cbb <sys_getenvid>
  800248:	25 ff 03 00 00       	and    $0x3ff,%eax
  80024d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800250:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800255:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80025a:	85 db                	test   %ebx,%ebx
  80025c:	7e 07                	jle    800265 <libmain+0x2d>
		binaryname = argv[0];
  80025e:	8b 06                	mov    (%esi),%eax
  800260:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800265:	83 ec 08             	sub    $0x8,%esp
  800268:	56                   	push   %esi
  800269:	53                   	push   %ebx
  80026a:	e8 0a ff ff ff       	call   800179 <umain>

	// exit gracefully
	exit();
  80026f:	e8 0a 00 00 00       	call   80027e <exit>
}
  800274:	83 c4 10             	add    $0x10,%esp
  800277:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80027a:	5b                   	pop    %ebx
  80027b:	5e                   	pop    %esi
  80027c:	5d                   	pop    %ebp
  80027d:	c3                   	ret    

0080027e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80027e:	55                   	push   %ebp
  80027f:	89 e5                	mov    %esp,%ebp
  800281:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800284:	e8 f4 10 00 00       	call   80137d <close_all>
	sys_env_destroy(0);
  800289:	83 ec 0c             	sub    $0xc,%esp
  80028c:	6a 00                	push   $0x0
  80028e:	e8 e7 09 00 00       	call   800c7a <sys_env_destroy>
}
  800293:	83 c4 10             	add    $0x10,%esp
  800296:	c9                   	leave  
  800297:	c3                   	ret    

00800298 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800298:	55                   	push   %ebp
  800299:	89 e5                	mov    %esp,%ebp
  80029b:	56                   	push   %esi
  80029c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80029d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002a0:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8002a6:	e8 10 0a 00 00       	call   800cbb <sys_getenvid>
  8002ab:	83 ec 0c             	sub    $0xc,%esp
  8002ae:	ff 75 0c             	pushl  0xc(%ebp)
  8002b1:	ff 75 08             	pushl  0x8(%ebp)
  8002b4:	56                   	push   %esi
  8002b5:	50                   	push   %eax
  8002b6:	68 34 28 80 00       	push   $0x802834
  8002bb:	e8 b1 00 00 00       	call   800371 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002c0:	83 c4 18             	add    $0x18,%esp
  8002c3:	53                   	push   %ebx
  8002c4:	ff 75 10             	pushl  0x10(%ebp)
  8002c7:	e8 54 00 00 00       	call   800320 <vcprintf>
	cprintf("\n");
  8002cc:	c7 04 24 c3 27 80 00 	movl   $0x8027c3,(%esp)
  8002d3:	e8 99 00 00 00       	call   800371 <cprintf>
  8002d8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002db:	cc                   	int3   
  8002dc:	eb fd                	jmp    8002db <_panic+0x43>

008002de <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002de:	55                   	push   %ebp
  8002df:	89 e5                	mov    %esp,%ebp
  8002e1:	53                   	push   %ebx
  8002e2:	83 ec 04             	sub    $0x4,%esp
  8002e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002e8:	8b 13                	mov    (%ebx),%edx
  8002ea:	8d 42 01             	lea    0x1(%edx),%eax
  8002ed:	89 03                	mov    %eax,(%ebx)
  8002ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002f2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002f6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002fb:	75 1a                	jne    800317 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8002fd:	83 ec 08             	sub    $0x8,%esp
  800300:	68 ff 00 00 00       	push   $0xff
  800305:	8d 43 08             	lea    0x8(%ebx),%eax
  800308:	50                   	push   %eax
  800309:	e8 2f 09 00 00       	call   800c3d <sys_cputs>
		b->idx = 0;
  80030e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800314:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800317:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80031b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80031e:	c9                   	leave  
  80031f:	c3                   	ret    

00800320 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800329:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800330:	00 00 00 
	b.cnt = 0;
  800333:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80033a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80033d:	ff 75 0c             	pushl  0xc(%ebp)
  800340:	ff 75 08             	pushl  0x8(%ebp)
  800343:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800349:	50                   	push   %eax
  80034a:	68 de 02 80 00       	push   $0x8002de
  80034f:	e8 54 01 00 00       	call   8004a8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800354:	83 c4 08             	add    $0x8,%esp
  800357:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80035d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800363:	50                   	push   %eax
  800364:	e8 d4 08 00 00       	call   800c3d <sys_cputs>

	return b.cnt;
}
  800369:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80036f:	c9                   	leave  
  800370:	c3                   	ret    

00800371 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800371:	55                   	push   %ebp
  800372:	89 e5                	mov    %esp,%ebp
  800374:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800377:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80037a:	50                   	push   %eax
  80037b:	ff 75 08             	pushl  0x8(%ebp)
  80037e:	e8 9d ff ff ff       	call   800320 <vcprintf>
	va_end(ap);

	return cnt;
}
  800383:	c9                   	leave  
  800384:	c3                   	ret    

00800385 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800385:	55                   	push   %ebp
  800386:	89 e5                	mov    %esp,%ebp
  800388:	57                   	push   %edi
  800389:	56                   	push   %esi
  80038a:	53                   	push   %ebx
  80038b:	83 ec 1c             	sub    $0x1c,%esp
  80038e:	89 c7                	mov    %eax,%edi
  800390:	89 d6                	mov    %edx,%esi
  800392:	8b 45 08             	mov    0x8(%ebp),%eax
  800395:	8b 55 0c             	mov    0xc(%ebp),%edx
  800398:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80039b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80039e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8003a1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003a6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8003a9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8003ac:	39 d3                	cmp    %edx,%ebx
  8003ae:	72 05                	jb     8003b5 <printnum+0x30>
  8003b0:	39 45 10             	cmp    %eax,0x10(%ebp)
  8003b3:	77 45                	ja     8003fa <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003b5:	83 ec 0c             	sub    $0xc,%esp
  8003b8:	ff 75 18             	pushl  0x18(%ebp)
  8003bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8003be:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8003c1:	53                   	push   %ebx
  8003c2:	ff 75 10             	pushl  0x10(%ebp)
  8003c5:	83 ec 08             	sub    $0x8,%esp
  8003c8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003cb:	ff 75 e0             	pushl  -0x20(%ebp)
  8003ce:	ff 75 dc             	pushl  -0x24(%ebp)
  8003d1:	ff 75 d8             	pushl  -0x28(%ebp)
  8003d4:	e8 07 21 00 00       	call   8024e0 <__udivdi3>
  8003d9:	83 c4 18             	add    $0x18,%esp
  8003dc:	52                   	push   %edx
  8003dd:	50                   	push   %eax
  8003de:	89 f2                	mov    %esi,%edx
  8003e0:	89 f8                	mov    %edi,%eax
  8003e2:	e8 9e ff ff ff       	call   800385 <printnum>
  8003e7:	83 c4 20             	add    $0x20,%esp
  8003ea:	eb 18                	jmp    800404 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003ec:	83 ec 08             	sub    $0x8,%esp
  8003ef:	56                   	push   %esi
  8003f0:	ff 75 18             	pushl  0x18(%ebp)
  8003f3:	ff d7                	call   *%edi
  8003f5:	83 c4 10             	add    $0x10,%esp
  8003f8:	eb 03                	jmp    8003fd <printnum+0x78>
  8003fa:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003fd:	83 eb 01             	sub    $0x1,%ebx
  800400:	85 db                	test   %ebx,%ebx
  800402:	7f e8                	jg     8003ec <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800404:	83 ec 08             	sub    $0x8,%esp
  800407:	56                   	push   %esi
  800408:	83 ec 04             	sub    $0x4,%esp
  80040b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80040e:	ff 75 e0             	pushl  -0x20(%ebp)
  800411:	ff 75 dc             	pushl  -0x24(%ebp)
  800414:	ff 75 d8             	pushl  -0x28(%ebp)
  800417:	e8 f4 21 00 00       	call   802610 <__umoddi3>
  80041c:	83 c4 14             	add    $0x14,%esp
  80041f:	0f be 80 57 28 80 00 	movsbl 0x802857(%eax),%eax
  800426:	50                   	push   %eax
  800427:	ff d7                	call   *%edi
}
  800429:	83 c4 10             	add    $0x10,%esp
  80042c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80042f:	5b                   	pop    %ebx
  800430:	5e                   	pop    %esi
  800431:	5f                   	pop    %edi
  800432:	5d                   	pop    %ebp
  800433:	c3                   	ret    

00800434 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800434:	55                   	push   %ebp
  800435:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800437:	83 fa 01             	cmp    $0x1,%edx
  80043a:	7e 0e                	jle    80044a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80043c:	8b 10                	mov    (%eax),%edx
  80043e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800441:	89 08                	mov    %ecx,(%eax)
  800443:	8b 02                	mov    (%edx),%eax
  800445:	8b 52 04             	mov    0x4(%edx),%edx
  800448:	eb 22                	jmp    80046c <getuint+0x38>
	else if (lflag)
  80044a:	85 d2                	test   %edx,%edx
  80044c:	74 10                	je     80045e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80044e:	8b 10                	mov    (%eax),%edx
  800450:	8d 4a 04             	lea    0x4(%edx),%ecx
  800453:	89 08                	mov    %ecx,(%eax)
  800455:	8b 02                	mov    (%edx),%eax
  800457:	ba 00 00 00 00       	mov    $0x0,%edx
  80045c:	eb 0e                	jmp    80046c <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80045e:	8b 10                	mov    (%eax),%edx
  800460:	8d 4a 04             	lea    0x4(%edx),%ecx
  800463:	89 08                	mov    %ecx,(%eax)
  800465:	8b 02                	mov    (%edx),%eax
  800467:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80046c:	5d                   	pop    %ebp
  80046d:	c3                   	ret    

0080046e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80046e:	55                   	push   %ebp
  80046f:	89 e5                	mov    %esp,%ebp
  800471:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800474:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800478:	8b 10                	mov    (%eax),%edx
  80047a:	3b 50 04             	cmp    0x4(%eax),%edx
  80047d:	73 0a                	jae    800489 <sprintputch+0x1b>
		*b->buf++ = ch;
  80047f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800482:	89 08                	mov    %ecx,(%eax)
  800484:	8b 45 08             	mov    0x8(%ebp),%eax
  800487:	88 02                	mov    %al,(%edx)
}
  800489:	5d                   	pop    %ebp
  80048a:	c3                   	ret    

0080048b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80048b:	55                   	push   %ebp
  80048c:	89 e5                	mov    %esp,%ebp
  80048e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800491:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800494:	50                   	push   %eax
  800495:	ff 75 10             	pushl  0x10(%ebp)
  800498:	ff 75 0c             	pushl  0xc(%ebp)
  80049b:	ff 75 08             	pushl  0x8(%ebp)
  80049e:	e8 05 00 00 00       	call   8004a8 <vprintfmt>
	va_end(ap);
}
  8004a3:	83 c4 10             	add    $0x10,%esp
  8004a6:	c9                   	leave  
  8004a7:	c3                   	ret    

008004a8 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004a8:	55                   	push   %ebp
  8004a9:	89 e5                	mov    %esp,%ebp
  8004ab:	57                   	push   %edi
  8004ac:	56                   	push   %esi
  8004ad:	53                   	push   %ebx
  8004ae:	83 ec 2c             	sub    $0x2c,%esp
  8004b1:	8b 75 08             	mov    0x8(%ebp),%esi
  8004b4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004b7:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004ba:	eb 12                	jmp    8004ce <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004bc:	85 c0                	test   %eax,%eax
  8004be:	0f 84 89 03 00 00    	je     80084d <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8004c4:	83 ec 08             	sub    $0x8,%esp
  8004c7:	53                   	push   %ebx
  8004c8:	50                   	push   %eax
  8004c9:	ff d6                	call   *%esi
  8004cb:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004ce:	83 c7 01             	add    $0x1,%edi
  8004d1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004d5:	83 f8 25             	cmp    $0x25,%eax
  8004d8:	75 e2                	jne    8004bc <vprintfmt+0x14>
  8004da:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8004de:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8004e5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004ec:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8004f3:	ba 00 00 00 00       	mov    $0x0,%edx
  8004f8:	eb 07                	jmp    800501 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004fd:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800501:	8d 47 01             	lea    0x1(%edi),%eax
  800504:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800507:	0f b6 07             	movzbl (%edi),%eax
  80050a:	0f b6 c8             	movzbl %al,%ecx
  80050d:	83 e8 23             	sub    $0x23,%eax
  800510:	3c 55                	cmp    $0x55,%al
  800512:	0f 87 1a 03 00 00    	ja     800832 <vprintfmt+0x38a>
  800518:	0f b6 c0             	movzbl %al,%eax
  80051b:	ff 24 85 a0 29 80 00 	jmp    *0x8029a0(,%eax,4)
  800522:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800525:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800529:	eb d6                	jmp    800501 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80052e:	b8 00 00 00 00       	mov    $0x0,%eax
  800533:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800536:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800539:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80053d:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800540:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800543:	83 fa 09             	cmp    $0x9,%edx
  800546:	77 39                	ja     800581 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800548:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80054b:	eb e9                	jmp    800536 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80054d:	8b 45 14             	mov    0x14(%ebp),%eax
  800550:	8d 48 04             	lea    0x4(%eax),%ecx
  800553:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800556:	8b 00                	mov    (%eax),%eax
  800558:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80055e:	eb 27                	jmp    800587 <vprintfmt+0xdf>
  800560:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800563:	85 c0                	test   %eax,%eax
  800565:	b9 00 00 00 00       	mov    $0x0,%ecx
  80056a:	0f 49 c8             	cmovns %eax,%ecx
  80056d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800570:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800573:	eb 8c                	jmp    800501 <vprintfmt+0x59>
  800575:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800578:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80057f:	eb 80                	jmp    800501 <vprintfmt+0x59>
  800581:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800584:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800587:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80058b:	0f 89 70 ff ff ff    	jns    800501 <vprintfmt+0x59>
				width = precision, precision = -1;
  800591:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800594:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800597:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80059e:	e9 5e ff ff ff       	jmp    800501 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005a3:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005a9:	e9 53 ff ff ff       	jmp    800501 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b1:	8d 50 04             	lea    0x4(%eax),%edx
  8005b4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b7:	83 ec 08             	sub    $0x8,%esp
  8005ba:	53                   	push   %ebx
  8005bb:	ff 30                	pushl  (%eax)
  8005bd:	ff d6                	call   *%esi
			break;
  8005bf:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005c5:	e9 04 ff ff ff       	jmp    8004ce <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cd:	8d 50 04             	lea    0x4(%eax),%edx
  8005d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d3:	8b 00                	mov    (%eax),%eax
  8005d5:	99                   	cltd   
  8005d6:	31 d0                	xor    %edx,%eax
  8005d8:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005da:	83 f8 0f             	cmp    $0xf,%eax
  8005dd:	7f 0b                	jg     8005ea <vprintfmt+0x142>
  8005df:	8b 14 85 00 2b 80 00 	mov    0x802b00(,%eax,4),%edx
  8005e6:	85 d2                	test   %edx,%edx
  8005e8:	75 18                	jne    800602 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8005ea:	50                   	push   %eax
  8005eb:	68 6f 28 80 00       	push   $0x80286f
  8005f0:	53                   	push   %ebx
  8005f1:	56                   	push   %esi
  8005f2:	e8 94 fe ff ff       	call   80048b <printfmt>
  8005f7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005fd:	e9 cc fe ff ff       	jmp    8004ce <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800602:	52                   	push   %edx
  800603:	68 be 2c 80 00       	push   $0x802cbe
  800608:	53                   	push   %ebx
  800609:	56                   	push   %esi
  80060a:	e8 7c fe ff ff       	call   80048b <printfmt>
  80060f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800612:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800615:	e9 b4 fe ff ff       	jmp    8004ce <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80061a:	8b 45 14             	mov    0x14(%ebp),%eax
  80061d:	8d 50 04             	lea    0x4(%eax),%edx
  800620:	89 55 14             	mov    %edx,0x14(%ebp)
  800623:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800625:	85 ff                	test   %edi,%edi
  800627:	b8 68 28 80 00       	mov    $0x802868,%eax
  80062c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80062f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800633:	0f 8e 94 00 00 00    	jle    8006cd <vprintfmt+0x225>
  800639:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80063d:	0f 84 98 00 00 00    	je     8006db <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800643:	83 ec 08             	sub    $0x8,%esp
  800646:	ff 75 d0             	pushl  -0x30(%ebp)
  800649:	57                   	push   %edi
  80064a:	e8 86 02 00 00       	call   8008d5 <strnlen>
  80064f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800652:	29 c1                	sub    %eax,%ecx
  800654:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800657:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80065a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80065e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800661:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800664:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800666:	eb 0f                	jmp    800677 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800668:	83 ec 08             	sub    $0x8,%esp
  80066b:	53                   	push   %ebx
  80066c:	ff 75 e0             	pushl  -0x20(%ebp)
  80066f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800671:	83 ef 01             	sub    $0x1,%edi
  800674:	83 c4 10             	add    $0x10,%esp
  800677:	85 ff                	test   %edi,%edi
  800679:	7f ed                	jg     800668 <vprintfmt+0x1c0>
  80067b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80067e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800681:	85 c9                	test   %ecx,%ecx
  800683:	b8 00 00 00 00       	mov    $0x0,%eax
  800688:	0f 49 c1             	cmovns %ecx,%eax
  80068b:	29 c1                	sub    %eax,%ecx
  80068d:	89 75 08             	mov    %esi,0x8(%ebp)
  800690:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800693:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800696:	89 cb                	mov    %ecx,%ebx
  800698:	eb 4d                	jmp    8006e7 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80069a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80069e:	74 1b                	je     8006bb <vprintfmt+0x213>
  8006a0:	0f be c0             	movsbl %al,%eax
  8006a3:	83 e8 20             	sub    $0x20,%eax
  8006a6:	83 f8 5e             	cmp    $0x5e,%eax
  8006a9:	76 10                	jbe    8006bb <vprintfmt+0x213>
					putch('?', putdat);
  8006ab:	83 ec 08             	sub    $0x8,%esp
  8006ae:	ff 75 0c             	pushl  0xc(%ebp)
  8006b1:	6a 3f                	push   $0x3f
  8006b3:	ff 55 08             	call   *0x8(%ebp)
  8006b6:	83 c4 10             	add    $0x10,%esp
  8006b9:	eb 0d                	jmp    8006c8 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8006bb:	83 ec 08             	sub    $0x8,%esp
  8006be:	ff 75 0c             	pushl  0xc(%ebp)
  8006c1:	52                   	push   %edx
  8006c2:	ff 55 08             	call   *0x8(%ebp)
  8006c5:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006c8:	83 eb 01             	sub    $0x1,%ebx
  8006cb:	eb 1a                	jmp    8006e7 <vprintfmt+0x23f>
  8006cd:	89 75 08             	mov    %esi,0x8(%ebp)
  8006d0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006d3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006d6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006d9:	eb 0c                	jmp    8006e7 <vprintfmt+0x23f>
  8006db:	89 75 08             	mov    %esi,0x8(%ebp)
  8006de:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006e1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006e4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006e7:	83 c7 01             	add    $0x1,%edi
  8006ea:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006ee:	0f be d0             	movsbl %al,%edx
  8006f1:	85 d2                	test   %edx,%edx
  8006f3:	74 23                	je     800718 <vprintfmt+0x270>
  8006f5:	85 f6                	test   %esi,%esi
  8006f7:	78 a1                	js     80069a <vprintfmt+0x1f2>
  8006f9:	83 ee 01             	sub    $0x1,%esi
  8006fc:	79 9c                	jns    80069a <vprintfmt+0x1f2>
  8006fe:	89 df                	mov    %ebx,%edi
  800700:	8b 75 08             	mov    0x8(%ebp),%esi
  800703:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800706:	eb 18                	jmp    800720 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800708:	83 ec 08             	sub    $0x8,%esp
  80070b:	53                   	push   %ebx
  80070c:	6a 20                	push   $0x20
  80070e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800710:	83 ef 01             	sub    $0x1,%edi
  800713:	83 c4 10             	add    $0x10,%esp
  800716:	eb 08                	jmp    800720 <vprintfmt+0x278>
  800718:	89 df                	mov    %ebx,%edi
  80071a:	8b 75 08             	mov    0x8(%ebp),%esi
  80071d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800720:	85 ff                	test   %edi,%edi
  800722:	7f e4                	jg     800708 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800724:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800727:	e9 a2 fd ff ff       	jmp    8004ce <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80072c:	83 fa 01             	cmp    $0x1,%edx
  80072f:	7e 16                	jle    800747 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800731:	8b 45 14             	mov    0x14(%ebp),%eax
  800734:	8d 50 08             	lea    0x8(%eax),%edx
  800737:	89 55 14             	mov    %edx,0x14(%ebp)
  80073a:	8b 50 04             	mov    0x4(%eax),%edx
  80073d:	8b 00                	mov    (%eax),%eax
  80073f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800742:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800745:	eb 32                	jmp    800779 <vprintfmt+0x2d1>
	else if (lflag)
  800747:	85 d2                	test   %edx,%edx
  800749:	74 18                	je     800763 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80074b:	8b 45 14             	mov    0x14(%ebp),%eax
  80074e:	8d 50 04             	lea    0x4(%eax),%edx
  800751:	89 55 14             	mov    %edx,0x14(%ebp)
  800754:	8b 00                	mov    (%eax),%eax
  800756:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800759:	89 c1                	mov    %eax,%ecx
  80075b:	c1 f9 1f             	sar    $0x1f,%ecx
  80075e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800761:	eb 16                	jmp    800779 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800763:	8b 45 14             	mov    0x14(%ebp),%eax
  800766:	8d 50 04             	lea    0x4(%eax),%edx
  800769:	89 55 14             	mov    %edx,0x14(%ebp)
  80076c:	8b 00                	mov    (%eax),%eax
  80076e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800771:	89 c1                	mov    %eax,%ecx
  800773:	c1 f9 1f             	sar    $0x1f,%ecx
  800776:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800779:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80077c:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80077f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800784:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800788:	79 74                	jns    8007fe <vprintfmt+0x356>
				putch('-', putdat);
  80078a:	83 ec 08             	sub    $0x8,%esp
  80078d:	53                   	push   %ebx
  80078e:	6a 2d                	push   $0x2d
  800790:	ff d6                	call   *%esi
				num = -(long long) num;
  800792:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800795:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800798:	f7 d8                	neg    %eax
  80079a:	83 d2 00             	adc    $0x0,%edx
  80079d:	f7 da                	neg    %edx
  80079f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8007a2:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007a7:	eb 55                	jmp    8007fe <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007a9:	8d 45 14             	lea    0x14(%ebp),%eax
  8007ac:	e8 83 fc ff ff       	call   800434 <getuint>
			base = 10;
  8007b1:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8007b6:	eb 46                	jmp    8007fe <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8007b8:	8d 45 14             	lea    0x14(%ebp),%eax
  8007bb:	e8 74 fc ff ff       	call   800434 <getuint>
                        base = 8;
  8007c0:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  8007c5:	eb 37                	jmp    8007fe <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8007c7:	83 ec 08             	sub    $0x8,%esp
  8007ca:	53                   	push   %ebx
  8007cb:	6a 30                	push   $0x30
  8007cd:	ff d6                	call   *%esi
			putch('x', putdat);
  8007cf:	83 c4 08             	add    $0x8,%esp
  8007d2:	53                   	push   %ebx
  8007d3:	6a 78                	push   $0x78
  8007d5:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007da:	8d 50 04             	lea    0x4(%eax),%edx
  8007dd:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007e0:	8b 00                	mov    (%eax),%eax
  8007e2:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007e7:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007ea:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8007ef:	eb 0d                	jmp    8007fe <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007f1:	8d 45 14             	lea    0x14(%ebp),%eax
  8007f4:	e8 3b fc ff ff       	call   800434 <getuint>
			base = 16;
  8007f9:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007fe:	83 ec 0c             	sub    $0xc,%esp
  800801:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800805:	57                   	push   %edi
  800806:	ff 75 e0             	pushl  -0x20(%ebp)
  800809:	51                   	push   %ecx
  80080a:	52                   	push   %edx
  80080b:	50                   	push   %eax
  80080c:	89 da                	mov    %ebx,%edx
  80080e:	89 f0                	mov    %esi,%eax
  800810:	e8 70 fb ff ff       	call   800385 <printnum>
			break;
  800815:	83 c4 20             	add    $0x20,%esp
  800818:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80081b:	e9 ae fc ff ff       	jmp    8004ce <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800820:	83 ec 08             	sub    $0x8,%esp
  800823:	53                   	push   %ebx
  800824:	51                   	push   %ecx
  800825:	ff d6                	call   *%esi
			break;
  800827:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80082a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80082d:	e9 9c fc ff ff       	jmp    8004ce <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800832:	83 ec 08             	sub    $0x8,%esp
  800835:	53                   	push   %ebx
  800836:	6a 25                	push   $0x25
  800838:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80083a:	83 c4 10             	add    $0x10,%esp
  80083d:	eb 03                	jmp    800842 <vprintfmt+0x39a>
  80083f:	83 ef 01             	sub    $0x1,%edi
  800842:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800846:	75 f7                	jne    80083f <vprintfmt+0x397>
  800848:	e9 81 fc ff ff       	jmp    8004ce <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80084d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800850:	5b                   	pop    %ebx
  800851:	5e                   	pop    %esi
  800852:	5f                   	pop    %edi
  800853:	5d                   	pop    %ebp
  800854:	c3                   	ret    

00800855 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800855:	55                   	push   %ebp
  800856:	89 e5                	mov    %esp,%ebp
  800858:	83 ec 18             	sub    $0x18,%esp
  80085b:	8b 45 08             	mov    0x8(%ebp),%eax
  80085e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800861:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800864:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800868:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80086b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800872:	85 c0                	test   %eax,%eax
  800874:	74 26                	je     80089c <vsnprintf+0x47>
  800876:	85 d2                	test   %edx,%edx
  800878:	7e 22                	jle    80089c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80087a:	ff 75 14             	pushl  0x14(%ebp)
  80087d:	ff 75 10             	pushl  0x10(%ebp)
  800880:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800883:	50                   	push   %eax
  800884:	68 6e 04 80 00       	push   $0x80046e
  800889:	e8 1a fc ff ff       	call   8004a8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80088e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800891:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800894:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800897:	83 c4 10             	add    $0x10,%esp
  80089a:	eb 05                	jmp    8008a1 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80089c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008a1:	c9                   	leave  
  8008a2:	c3                   	ret    

008008a3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008a3:	55                   	push   %ebp
  8008a4:	89 e5                	mov    %esp,%ebp
  8008a6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008a9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008ac:	50                   	push   %eax
  8008ad:	ff 75 10             	pushl  0x10(%ebp)
  8008b0:	ff 75 0c             	pushl  0xc(%ebp)
  8008b3:	ff 75 08             	pushl  0x8(%ebp)
  8008b6:	e8 9a ff ff ff       	call   800855 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008bb:	c9                   	leave  
  8008bc:	c3                   	ret    

008008bd <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008bd:	55                   	push   %ebp
  8008be:	89 e5                	mov    %esp,%ebp
  8008c0:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c8:	eb 03                	jmp    8008cd <strlen+0x10>
		n++;
  8008ca:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008cd:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008d1:	75 f7                	jne    8008ca <strlen+0xd>
		n++;
	return n;
}
  8008d3:	5d                   	pop    %ebp
  8008d4:	c3                   	ret    

008008d5 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008d5:	55                   	push   %ebp
  8008d6:	89 e5                	mov    %esp,%ebp
  8008d8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008db:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008de:	ba 00 00 00 00       	mov    $0x0,%edx
  8008e3:	eb 03                	jmp    8008e8 <strnlen+0x13>
		n++;
  8008e5:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008e8:	39 c2                	cmp    %eax,%edx
  8008ea:	74 08                	je     8008f4 <strnlen+0x1f>
  8008ec:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8008f0:	75 f3                	jne    8008e5 <strnlen+0x10>
  8008f2:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8008f4:	5d                   	pop    %ebp
  8008f5:	c3                   	ret    

008008f6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008f6:	55                   	push   %ebp
  8008f7:	89 e5                	mov    %esp,%ebp
  8008f9:	53                   	push   %ebx
  8008fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800900:	89 c2                	mov    %eax,%edx
  800902:	83 c2 01             	add    $0x1,%edx
  800905:	83 c1 01             	add    $0x1,%ecx
  800908:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80090c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80090f:	84 db                	test   %bl,%bl
  800911:	75 ef                	jne    800902 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800913:	5b                   	pop    %ebx
  800914:	5d                   	pop    %ebp
  800915:	c3                   	ret    

00800916 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800916:	55                   	push   %ebp
  800917:	89 e5                	mov    %esp,%ebp
  800919:	53                   	push   %ebx
  80091a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80091d:	53                   	push   %ebx
  80091e:	e8 9a ff ff ff       	call   8008bd <strlen>
  800923:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800926:	ff 75 0c             	pushl  0xc(%ebp)
  800929:	01 d8                	add    %ebx,%eax
  80092b:	50                   	push   %eax
  80092c:	e8 c5 ff ff ff       	call   8008f6 <strcpy>
	return dst;
}
  800931:	89 d8                	mov    %ebx,%eax
  800933:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800936:	c9                   	leave  
  800937:	c3                   	ret    

00800938 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800938:	55                   	push   %ebp
  800939:	89 e5                	mov    %esp,%ebp
  80093b:	56                   	push   %esi
  80093c:	53                   	push   %ebx
  80093d:	8b 75 08             	mov    0x8(%ebp),%esi
  800940:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800943:	89 f3                	mov    %esi,%ebx
  800945:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800948:	89 f2                	mov    %esi,%edx
  80094a:	eb 0f                	jmp    80095b <strncpy+0x23>
		*dst++ = *src;
  80094c:	83 c2 01             	add    $0x1,%edx
  80094f:	0f b6 01             	movzbl (%ecx),%eax
  800952:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800955:	80 39 01             	cmpb   $0x1,(%ecx)
  800958:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80095b:	39 da                	cmp    %ebx,%edx
  80095d:	75 ed                	jne    80094c <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80095f:	89 f0                	mov    %esi,%eax
  800961:	5b                   	pop    %ebx
  800962:	5e                   	pop    %esi
  800963:	5d                   	pop    %ebp
  800964:	c3                   	ret    

00800965 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800965:	55                   	push   %ebp
  800966:	89 e5                	mov    %esp,%ebp
  800968:	56                   	push   %esi
  800969:	53                   	push   %ebx
  80096a:	8b 75 08             	mov    0x8(%ebp),%esi
  80096d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800970:	8b 55 10             	mov    0x10(%ebp),%edx
  800973:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800975:	85 d2                	test   %edx,%edx
  800977:	74 21                	je     80099a <strlcpy+0x35>
  800979:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80097d:	89 f2                	mov    %esi,%edx
  80097f:	eb 09                	jmp    80098a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800981:	83 c2 01             	add    $0x1,%edx
  800984:	83 c1 01             	add    $0x1,%ecx
  800987:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80098a:	39 c2                	cmp    %eax,%edx
  80098c:	74 09                	je     800997 <strlcpy+0x32>
  80098e:	0f b6 19             	movzbl (%ecx),%ebx
  800991:	84 db                	test   %bl,%bl
  800993:	75 ec                	jne    800981 <strlcpy+0x1c>
  800995:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800997:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80099a:	29 f0                	sub    %esi,%eax
}
  80099c:	5b                   	pop    %ebx
  80099d:	5e                   	pop    %esi
  80099e:	5d                   	pop    %ebp
  80099f:	c3                   	ret    

008009a0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009a0:	55                   	push   %ebp
  8009a1:	89 e5                	mov    %esp,%ebp
  8009a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009a6:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009a9:	eb 06                	jmp    8009b1 <strcmp+0x11>
		p++, q++;
  8009ab:	83 c1 01             	add    $0x1,%ecx
  8009ae:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009b1:	0f b6 01             	movzbl (%ecx),%eax
  8009b4:	84 c0                	test   %al,%al
  8009b6:	74 04                	je     8009bc <strcmp+0x1c>
  8009b8:	3a 02                	cmp    (%edx),%al
  8009ba:	74 ef                	je     8009ab <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009bc:	0f b6 c0             	movzbl %al,%eax
  8009bf:	0f b6 12             	movzbl (%edx),%edx
  8009c2:	29 d0                	sub    %edx,%eax
}
  8009c4:	5d                   	pop    %ebp
  8009c5:	c3                   	ret    

008009c6 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009c6:	55                   	push   %ebp
  8009c7:	89 e5                	mov    %esp,%ebp
  8009c9:	53                   	push   %ebx
  8009ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009d0:	89 c3                	mov    %eax,%ebx
  8009d2:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009d5:	eb 06                	jmp    8009dd <strncmp+0x17>
		n--, p++, q++;
  8009d7:	83 c0 01             	add    $0x1,%eax
  8009da:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009dd:	39 d8                	cmp    %ebx,%eax
  8009df:	74 15                	je     8009f6 <strncmp+0x30>
  8009e1:	0f b6 08             	movzbl (%eax),%ecx
  8009e4:	84 c9                	test   %cl,%cl
  8009e6:	74 04                	je     8009ec <strncmp+0x26>
  8009e8:	3a 0a                	cmp    (%edx),%cl
  8009ea:	74 eb                	je     8009d7 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009ec:	0f b6 00             	movzbl (%eax),%eax
  8009ef:	0f b6 12             	movzbl (%edx),%edx
  8009f2:	29 d0                	sub    %edx,%eax
  8009f4:	eb 05                	jmp    8009fb <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009f6:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009fb:	5b                   	pop    %ebx
  8009fc:	5d                   	pop    %ebp
  8009fd:	c3                   	ret    

008009fe <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009fe:	55                   	push   %ebp
  8009ff:	89 e5                	mov    %esp,%ebp
  800a01:	8b 45 08             	mov    0x8(%ebp),%eax
  800a04:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a08:	eb 07                	jmp    800a11 <strchr+0x13>
		if (*s == c)
  800a0a:	38 ca                	cmp    %cl,%dl
  800a0c:	74 0f                	je     800a1d <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a0e:	83 c0 01             	add    $0x1,%eax
  800a11:	0f b6 10             	movzbl (%eax),%edx
  800a14:	84 d2                	test   %dl,%dl
  800a16:	75 f2                	jne    800a0a <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a18:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a1d:	5d                   	pop    %ebp
  800a1e:	c3                   	ret    

00800a1f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a1f:	55                   	push   %ebp
  800a20:	89 e5                	mov    %esp,%ebp
  800a22:	8b 45 08             	mov    0x8(%ebp),%eax
  800a25:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a29:	eb 03                	jmp    800a2e <strfind+0xf>
  800a2b:	83 c0 01             	add    $0x1,%eax
  800a2e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a31:	38 ca                	cmp    %cl,%dl
  800a33:	74 04                	je     800a39 <strfind+0x1a>
  800a35:	84 d2                	test   %dl,%dl
  800a37:	75 f2                	jne    800a2b <strfind+0xc>
			break;
	return (char *) s;
}
  800a39:	5d                   	pop    %ebp
  800a3a:	c3                   	ret    

00800a3b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a3b:	55                   	push   %ebp
  800a3c:	89 e5                	mov    %esp,%ebp
  800a3e:	57                   	push   %edi
  800a3f:	56                   	push   %esi
  800a40:	53                   	push   %ebx
  800a41:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a44:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a47:	85 c9                	test   %ecx,%ecx
  800a49:	74 36                	je     800a81 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a4b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a51:	75 28                	jne    800a7b <memset+0x40>
  800a53:	f6 c1 03             	test   $0x3,%cl
  800a56:	75 23                	jne    800a7b <memset+0x40>
		c &= 0xFF;
  800a58:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a5c:	89 d3                	mov    %edx,%ebx
  800a5e:	c1 e3 08             	shl    $0x8,%ebx
  800a61:	89 d6                	mov    %edx,%esi
  800a63:	c1 e6 18             	shl    $0x18,%esi
  800a66:	89 d0                	mov    %edx,%eax
  800a68:	c1 e0 10             	shl    $0x10,%eax
  800a6b:	09 f0                	or     %esi,%eax
  800a6d:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a6f:	89 d8                	mov    %ebx,%eax
  800a71:	09 d0                	or     %edx,%eax
  800a73:	c1 e9 02             	shr    $0x2,%ecx
  800a76:	fc                   	cld    
  800a77:	f3 ab                	rep stos %eax,%es:(%edi)
  800a79:	eb 06                	jmp    800a81 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a7b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a7e:	fc                   	cld    
  800a7f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a81:	89 f8                	mov    %edi,%eax
  800a83:	5b                   	pop    %ebx
  800a84:	5e                   	pop    %esi
  800a85:	5f                   	pop    %edi
  800a86:	5d                   	pop    %ebp
  800a87:	c3                   	ret    

00800a88 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a88:	55                   	push   %ebp
  800a89:	89 e5                	mov    %esp,%ebp
  800a8b:	57                   	push   %edi
  800a8c:	56                   	push   %esi
  800a8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a90:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a93:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a96:	39 c6                	cmp    %eax,%esi
  800a98:	73 35                	jae    800acf <memmove+0x47>
  800a9a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a9d:	39 d0                	cmp    %edx,%eax
  800a9f:	73 2e                	jae    800acf <memmove+0x47>
		s += n;
		d += n;
  800aa1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aa4:	89 d6                	mov    %edx,%esi
  800aa6:	09 fe                	or     %edi,%esi
  800aa8:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800aae:	75 13                	jne    800ac3 <memmove+0x3b>
  800ab0:	f6 c1 03             	test   $0x3,%cl
  800ab3:	75 0e                	jne    800ac3 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800ab5:	83 ef 04             	sub    $0x4,%edi
  800ab8:	8d 72 fc             	lea    -0x4(%edx),%esi
  800abb:	c1 e9 02             	shr    $0x2,%ecx
  800abe:	fd                   	std    
  800abf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ac1:	eb 09                	jmp    800acc <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ac3:	83 ef 01             	sub    $0x1,%edi
  800ac6:	8d 72 ff             	lea    -0x1(%edx),%esi
  800ac9:	fd                   	std    
  800aca:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800acc:	fc                   	cld    
  800acd:	eb 1d                	jmp    800aec <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800acf:	89 f2                	mov    %esi,%edx
  800ad1:	09 c2                	or     %eax,%edx
  800ad3:	f6 c2 03             	test   $0x3,%dl
  800ad6:	75 0f                	jne    800ae7 <memmove+0x5f>
  800ad8:	f6 c1 03             	test   $0x3,%cl
  800adb:	75 0a                	jne    800ae7 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800add:	c1 e9 02             	shr    $0x2,%ecx
  800ae0:	89 c7                	mov    %eax,%edi
  800ae2:	fc                   	cld    
  800ae3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ae5:	eb 05                	jmp    800aec <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ae7:	89 c7                	mov    %eax,%edi
  800ae9:	fc                   	cld    
  800aea:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800aec:	5e                   	pop    %esi
  800aed:	5f                   	pop    %edi
  800aee:	5d                   	pop    %ebp
  800aef:	c3                   	ret    

00800af0 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800af0:	55                   	push   %ebp
  800af1:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800af3:	ff 75 10             	pushl  0x10(%ebp)
  800af6:	ff 75 0c             	pushl  0xc(%ebp)
  800af9:	ff 75 08             	pushl  0x8(%ebp)
  800afc:	e8 87 ff ff ff       	call   800a88 <memmove>
}
  800b01:	c9                   	leave  
  800b02:	c3                   	ret    

00800b03 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b03:	55                   	push   %ebp
  800b04:	89 e5                	mov    %esp,%ebp
  800b06:	56                   	push   %esi
  800b07:	53                   	push   %ebx
  800b08:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b0e:	89 c6                	mov    %eax,%esi
  800b10:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b13:	eb 1a                	jmp    800b2f <memcmp+0x2c>
		if (*s1 != *s2)
  800b15:	0f b6 08             	movzbl (%eax),%ecx
  800b18:	0f b6 1a             	movzbl (%edx),%ebx
  800b1b:	38 d9                	cmp    %bl,%cl
  800b1d:	74 0a                	je     800b29 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b1f:	0f b6 c1             	movzbl %cl,%eax
  800b22:	0f b6 db             	movzbl %bl,%ebx
  800b25:	29 d8                	sub    %ebx,%eax
  800b27:	eb 0f                	jmp    800b38 <memcmp+0x35>
		s1++, s2++;
  800b29:	83 c0 01             	add    $0x1,%eax
  800b2c:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b2f:	39 f0                	cmp    %esi,%eax
  800b31:	75 e2                	jne    800b15 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b33:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b38:	5b                   	pop    %ebx
  800b39:	5e                   	pop    %esi
  800b3a:	5d                   	pop    %ebp
  800b3b:	c3                   	ret    

00800b3c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b3c:	55                   	push   %ebp
  800b3d:	89 e5                	mov    %esp,%ebp
  800b3f:	53                   	push   %ebx
  800b40:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b43:	89 c1                	mov    %eax,%ecx
  800b45:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b48:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b4c:	eb 0a                	jmp    800b58 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b4e:	0f b6 10             	movzbl (%eax),%edx
  800b51:	39 da                	cmp    %ebx,%edx
  800b53:	74 07                	je     800b5c <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b55:	83 c0 01             	add    $0x1,%eax
  800b58:	39 c8                	cmp    %ecx,%eax
  800b5a:	72 f2                	jb     800b4e <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b5c:	5b                   	pop    %ebx
  800b5d:	5d                   	pop    %ebp
  800b5e:	c3                   	ret    

00800b5f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b5f:	55                   	push   %ebp
  800b60:	89 e5                	mov    %esp,%ebp
  800b62:	57                   	push   %edi
  800b63:	56                   	push   %esi
  800b64:	53                   	push   %ebx
  800b65:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b68:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b6b:	eb 03                	jmp    800b70 <strtol+0x11>
		s++;
  800b6d:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b70:	0f b6 01             	movzbl (%ecx),%eax
  800b73:	3c 20                	cmp    $0x20,%al
  800b75:	74 f6                	je     800b6d <strtol+0xe>
  800b77:	3c 09                	cmp    $0x9,%al
  800b79:	74 f2                	je     800b6d <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b7b:	3c 2b                	cmp    $0x2b,%al
  800b7d:	75 0a                	jne    800b89 <strtol+0x2a>
		s++;
  800b7f:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b82:	bf 00 00 00 00       	mov    $0x0,%edi
  800b87:	eb 11                	jmp    800b9a <strtol+0x3b>
  800b89:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b8e:	3c 2d                	cmp    $0x2d,%al
  800b90:	75 08                	jne    800b9a <strtol+0x3b>
		s++, neg = 1;
  800b92:	83 c1 01             	add    $0x1,%ecx
  800b95:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b9a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ba0:	75 15                	jne    800bb7 <strtol+0x58>
  800ba2:	80 39 30             	cmpb   $0x30,(%ecx)
  800ba5:	75 10                	jne    800bb7 <strtol+0x58>
  800ba7:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bab:	75 7c                	jne    800c29 <strtol+0xca>
		s += 2, base = 16;
  800bad:	83 c1 02             	add    $0x2,%ecx
  800bb0:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bb5:	eb 16                	jmp    800bcd <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800bb7:	85 db                	test   %ebx,%ebx
  800bb9:	75 12                	jne    800bcd <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bbb:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bc0:	80 39 30             	cmpb   $0x30,(%ecx)
  800bc3:	75 08                	jne    800bcd <strtol+0x6e>
		s++, base = 8;
  800bc5:	83 c1 01             	add    $0x1,%ecx
  800bc8:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800bcd:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd2:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bd5:	0f b6 11             	movzbl (%ecx),%edx
  800bd8:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bdb:	89 f3                	mov    %esi,%ebx
  800bdd:	80 fb 09             	cmp    $0x9,%bl
  800be0:	77 08                	ja     800bea <strtol+0x8b>
			dig = *s - '0';
  800be2:	0f be d2             	movsbl %dl,%edx
  800be5:	83 ea 30             	sub    $0x30,%edx
  800be8:	eb 22                	jmp    800c0c <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800bea:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bed:	89 f3                	mov    %esi,%ebx
  800bef:	80 fb 19             	cmp    $0x19,%bl
  800bf2:	77 08                	ja     800bfc <strtol+0x9d>
			dig = *s - 'a' + 10;
  800bf4:	0f be d2             	movsbl %dl,%edx
  800bf7:	83 ea 57             	sub    $0x57,%edx
  800bfa:	eb 10                	jmp    800c0c <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800bfc:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bff:	89 f3                	mov    %esi,%ebx
  800c01:	80 fb 19             	cmp    $0x19,%bl
  800c04:	77 16                	ja     800c1c <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c06:	0f be d2             	movsbl %dl,%edx
  800c09:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c0c:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c0f:	7d 0b                	jge    800c1c <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800c11:	83 c1 01             	add    $0x1,%ecx
  800c14:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c18:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c1a:	eb b9                	jmp    800bd5 <strtol+0x76>

	if (endptr)
  800c1c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c20:	74 0d                	je     800c2f <strtol+0xd0>
		*endptr = (char *) s;
  800c22:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c25:	89 0e                	mov    %ecx,(%esi)
  800c27:	eb 06                	jmp    800c2f <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c29:	85 db                	test   %ebx,%ebx
  800c2b:	74 98                	je     800bc5 <strtol+0x66>
  800c2d:	eb 9e                	jmp    800bcd <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800c2f:	89 c2                	mov    %eax,%edx
  800c31:	f7 da                	neg    %edx
  800c33:	85 ff                	test   %edi,%edi
  800c35:	0f 45 c2             	cmovne %edx,%eax
}
  800c38:	5b                   	pop    %ebx
  800c39:	5e                   	pop    %esi
  800c3a:	5f                   	pop    %edi
  800c3b:	5d                   	pop    %ebp
  800c3c:	c3                   	ret    

00800c3d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c3d:	55                   	push   %ebp
  800c3e:	89 e5                	mov    %esp,%ebp
  800c40:	57                   	push   %edi
  800c41:	56                   	push   %esi
  800c42:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c43:	b8 00 00 00 00       	mov    $0x0,%eax
  800c48:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4e:	89 c3                	mov    %eax,%ebx
  800c50:	89 c7                	mov    %eax,%edi
  800c52:	89 c6                	mov    %eax,%esi
  800c54:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c56:	5b                   	pop    %ebx
  800c57:	5e                   	pop    %esi
  800c58:	5f                   	pop    %edi
  800c59:	5d                   	pop    %ebp
  800c5a:	c3                   	ret    

00800c5b <sys_cgetc>:

int
sys_cgetc(void)
{
  800c5b:	55                   	push   %ebp
  800c5c:	89 e5                	mov    %esp,%ebp
  800c5e:	57                   	push   %edi
  800c5f:	56                   	push   %esi
  800c60:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c61:	ba 00 00 00 00       	mov    $0x0,%edx
  800c66:	b8 01 00 00 00       	mov    $0x1,%eax
  800c6b:	89 d1                	mov    %edx,%ecx
  800c6d:	89 d3                	mov    %edx,%ebx
  800c6f:	89 d7                	mov    %edx,%edi
  800c71:	89 d6                	mov    %edx,%esi
  800c73:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c75:	5b                   	pop    %ebx
  800c76:	5e                   	pop    %esi
  800c77:	5f                   	pop    %edi
  800c78:	5d                   	pop    %ebp
  800c79:	c3                   	ret    

00800c7a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c7a:	55                   	push   %ebp
  800c7b:	89 e5                	mov    %esp,%ebp
  800c7d:	57                   	push   %edi
  800c7e:	56                   	push   %esi
  800c7f:	53                   	push   %ebx
  800c80:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c83:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c88:	b8 03 00 00 00       	mov    $0x3,%eax
  800c8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c90:	89 cb                	mov    %ecx,%ebx
  800c92:	89 cf                	mov    %ecx,%edi
  800c94:	89 ce                	mov    %ecx,%esi
  800c96:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c98:	85 c0                	test   %eax,%eax
  800c9a:	7e 17                	jle    800cb3 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9c:	83 ec 0c             	sub    $0xc,%esp
  800c9f:	50                   	push   %eax
  800ca0:	6a 03                	push   $0x3
  800ca2:	68 5f 2b 80 00       	push   $0x802b5f
  800ca7:	6a 23                	push   $0x23
  800ca9:	68 7c 2b 80 00       	push   $0x802b7c
  800cae:	e8 e5 f5 ff ff       	call   800298 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cb3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb6:	5b                   	pop    %ebx
  800cb7:	5e                   	pop    %esi
  800cb8:	5f                   	pop    %edi
  800cb9:	5d                   	pop    %ebp
  800cba:	c3                   	ret    

00800cbb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cbb:	55                   	push   %ebp
  800cbc:	89 e5                	mov    %esp,%ebp
  800cbe:	57                   	push   %edi
  800cbf:	56                   	push   %esi
  800cc0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc1:	ba 00 00 00 00       	mov    $0x0,%edx
  800cc6:	b8 02 00 00 00       	mov    $0x2,%eax
  800ccb:	89 d1                	mov    %edx,%ecx
  800ccd:	89 d3                	mov    %edx,%ebx
  800ccf:	89 d7                	mov    %edx,%edi
  800cd1:	89 d6                	mov    %edx,%esi
  800cd3:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cd5:	5b                   	pop    %ebx
  800cd6:	5e                   	pop    %esi
  800cd7:	5f                   	pop    %edi
  800cd8:	5d                   	pop    %ebp
  800cd9:	c3                   	ret    

00800cda <sys_yield>:

void
sys_yield(void)
{
  800cda:	55                   	push   %ebp
  800cdb:	89 e5                	mov    %esp,%ebp
  800cdd:	57                   	push   %edi
  800cde:	56                   	push   %esi
  800cdf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce5:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cea:	89 d1                	mov    %edx,%ecx
  800cec:	89 d3                	mov    %edx,%ebx
  800cee:	89 d7                	mov    %edx,%edi
  800cf0:	89 d6                	mov    %edx,%esi
  800cf2:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cf4:	5b                   	pop    %ebx
  800cf5:	5e                   	pop    %esi
  800cf6:	5f                   	pop    %edi
  800cf7:	5d                   	pop    %ebp
  800cf8:	c3                   	ret    

00800cf9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cf9:	55                   	push   %ebp
  800cfa:	89 e5                	mov    %esp,%ebp
  800cfc:	57                   	push   %edi
  800cfd:	56                   	push   %esi
  800cfe:	53                   	push   %ebx
  800cff:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d02:	be 00 00 00 00       	mov    $0x0,%esi
  800d07:	b8 04 00 00 00       	mov    $0x4,%eax
  800d0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d12:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d15:	89 f7                	mov    %esi,%edi
  800d17:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d19:	85 c0                	test   %eax,%eax
  800d1b:	7e 17                	jle    800d34 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1d:	83 ec 0c             	sub    $0xc,%esp
  800d20:	50                   	push   %eax
  800d21:	6a 04                	push   $0x4
  800d23:	68 5f 2b 80 00       	push   $0x802b5f
  800d28:	6a 23                	push   $0x23
  800d2a:	68 7c 2b 80 00       	push   $0x802b7c
  800d2f:	e8 64 f5 ff ff       	call   800298 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d34:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d37:	5b                   	pop    %ebx
  800d38:	5e                   	pop    %esi
  800d39:	5f                   	pop    %edi
  800d3a:	5d                   	pop    %ebp
  800d3b:	c3                   	ret    

00800d3c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d3c:	55                   	push   %ebp
  800d3d:	89 e5                	mov    %esp,%ebp
  800d3f:	57                   	push   %edi
  800d40:	56                   	push   %esi
  800d41:	53                   	push   %ebx
  800d42:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d45:	b8 05 00 00 00       	mov    $0x5,%eax
  800d4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d50:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d53:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d56:	8b 75 18             	mov    0x18(%ebp),%esi
  800d59:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d5b:	85 c0                	test   %eax,%eax
  800d5d:	7e 17                	jle    800d76 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5f:	83 ec 0c             	sub    $0xc,%esp
  800d62:	50                   	push   %eax
  800d63:	6a 05                	push   $0x5
  800d65:	68 5f 2b 80 00       	push   $0x802b5f
  800d6a:	6a 23                	push   $0x23
  800d6c:	68 7c 2b 80 00       	push   $0x802b7c
  800d71:	e8 22 f5 ff ff       	call   800298 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d76:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d79:	5b                   	pop    %ebx
  800d7a:	5e                   	pop    %esi
  800d7b:	5f                   	pop    %edi
  800d7c:	5d                   	pop    %ebp
  800d7d:	c3                   	ret    

00800d7e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d7e:	55                   	push   %ebp
  800d7f:	89 e5                	mov    %esp,%ebp
  800d81:	57                   	push   %edi
  800d82:	56                   	push   %esi
  800d83:	53                   	push   %ebx
  800d84:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d87:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d8c:	b8 06 00 00 00       	mov    $0x6,%eax
  800d91:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d94:	8b 55 08             	mov    0x8(%ebp),%edx
  800d97:	89 df                	mov    %ebx,%edi
  800d99:	89 de                	mov    %ebx,%esi
  800d9b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d9d:	85 c0                	test   %eax,%eax
  800d9f:	7e 17                	jle    800db8 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da1:	83 ec 0c             	sub    $0xc,%esp
  800da4:	50                   	push   %eax
  800da5:	6a 06                	push   $0x6
  800da7:	68 5f 2b 80 00       	push   $0x802b5f
  800dac:	6a 23                	push   $0x23
  800dae:	68 7c 2b 80 00       	push   $0x802b7c
  800db3:	e8 e0 f4 ff ff       	call   800298 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800db8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dbb:	5b                   	pop    %ebx
  800dbc:	5e                   	pop    %esi
  800dbd:	5f                   	pop    %edi
  800dbe:	5d                   	pop    %ebp
  800dbf:	c3                   	ret    

00800dc0 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800dc0:	55                   	push   %ebp
  800dc1:	89 e5                	mov    %esp,%ebp
  800dc3:	57                   	push   %edi
  800dc4:	56                   	push   %esi
  800dc5:	53                   	push   %ebx
  800dc6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dce:	b8 08 00 00 00       	mov    $0x8,%eax
  800dd3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd6:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd9:	89 df                	mov    %ebx,%edi
  800ddb:	89 de                	mov    %ebx,%esi
  800ddd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ddf:	85 c0                	test   %eax,%eax
  800de1:	7e 17                	jle    800dfa <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de3:	83 ec 0c             	sub    $0xc,%esp
  800de6:	50                   	push   %eax
  800de7:	6a 08                	push   $0x8
  800de9:	68 5f 2b 80 00       	push   $0x802b5f
  800dee:	6a 23                	push   $0x23
  800df0:	68 7c 2b 80 00       	push   $0x802b7c
  800df5:	e8 9e f4 ff ff       	call   800298 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dfa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dfd:	5b                   	pop    %ebx
  800dfe:	5e                   	pop    %esi
  800dff:	5f                   	pop    %edi
  800e00:	5d                   	pop    %ebp
  800e01:	c3                   	ret    

00800e02 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e02:	55                   	push   %ebp
  800e03:	89 e5                	mov    %esp,%ebp
  800e05:	57                   	push   %edi
  800e06:	56                   	push   %esi
  800e07:	53                   	push   %ebx
  800e08:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e10:	b8 09 00 00 00       	mov    $0x9,%eax
  800e15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e18:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1b:	89 df                	mov    %ebx,%edi
  800e1d:	89 de                	mov    %ebx,%esi
  800e1f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e21:	85 c0                	test   %eax,%eax
  800e23:	7e 17                	jle    800e3c <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e25:	83 ec 0c             	sub    $0xc,%esp
  800e28:	50                   	push   %eax
  800e29:	6a 09                	push   $0x9
  800e2b:	68 5f 2b 80 00       	push   $0x802b5f
  800e30:	6a 23                	push   $0x23
  800e32:	68 7c 2b 80 00       	push   $0x802b7c
  800e37:	e8 5c f4 ff ff       	call   800298 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e3f:	5b                   	pop    %ebx
  800e40:	5e                   	pop    %esi
  800e41:	5f                   	pop    %edi
  800e42:	5d                   	pop    %ebp
  800e43:	c3                   	ret    

00800e44 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e44:	55                   	push   %ebp
  800e45:	89 e5                	mov    %esp,%ebp
  800e47:	57                   	push   %edi
  800e48:	56                   	push   %esi
  800e49:	53                   	push   %ebx
  800e4a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e4d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e52:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e57:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5d:	89 df                	mov    %ebx,%edi
  800e5f:	89 de                	mov    %ebx,%esi
  800e61:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e63:	85 c0                	test   %eax,%eax
  800e65:	7e 17                	jle    800e7e <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e67:	83 ec 0c             	sub    $0xc,%esp
  800e6a:	50                   	push   %eax
  800e6b:	6a 0a                	push   $0xa
  800e6d:	68 5f 2b 80 00       	push   $0x802b5f
  800e72:	6a 23                	push   $0x23
  800e74:	68 7c 2b 80 00       	push   $0x802b7c
  800e79:	e8 1a f4 ff ff       	call   800298 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e81:	5b                   	pop    %ebx
  800e82:	5e                   	pop    %esi
  800e83:	5f                   	pop    %edi
  800e84:	5d                   	pop    %ebp
  800e85:	c3                   	ret    

00800e86 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e86:	55                   	push   %ebp
  800e87:	89 e5                	mov    %esp,%ebp
  800e89:	57                   	push   %edi
  800e8a:	56                   	push   %esi
  800e8b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8c:	be 00 00 00 00       	mov    $0x0,%esi
  800e91:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e99:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e9f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ea2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ea4:	5b                   	pop    %ebx
  800ea5:	5e                   	pop    %esi
  800ea6:	5f                   	pop    %edi
  800ea7:	5d                   	pop    %ebp
  800ea8:	c3                   	ret    

00800ea9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ea9:	55                   	push   %ebp
  800eaa:	89 e5                	mov    %esp,%ebp
  800eac:	57                   	push   %edi
  800ead:	56                   	push   %esi
  800eae:	53                   	push   %ebx
  800eaf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800eb7:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ebc:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebf:	89 cb                	mov    %ecx,%ebx
  800ec1:	89 cf                	mov    %ecx,%edi
  800ec3:	89 ce                	mov    %ecx,%esi
  800ec5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ec7:	85 c0                	test   %eax,%eax
  800ec9:	7e 17                	jle    800ee2 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ecb:	83 ec 0c             	sub    $0xc,%esp
  800ece:	50                   	push   %eax
  800ecf:	6a 0d                	push   $0xd
  800ed1:	68 5f 2b 80 00       	push   $0x802b5f
  800ed6:	6a 23                	push   $0x23
  800ed8:	68 7c 2b 80 00       	push   $0x802b7c
  800edd:	e8 b6 f3 ff ff       	call   800298 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ee2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ee5:	5b                   	pop    %ebx
  800ee6:	5e                   	pop    %esi
  800ee7:	5f                   	pop    %edi
  800ee8:	5d                   	pop    %ebp
  800ee9:	c3                   	ret    

00800eea <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800eea:	55                   	push   %ebp
  800eeb:	89 e5                	mov    %esp,%ebp
  800eed:	57                   	push   %edi
  800eee:	56                   	push   %esi
  800eef:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ef0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ef5:	b8 0e 00 00 00       	mov    $0xe,%eax
  800efa:	89 d1                	mov    %edx,%ecx
  800efc:	89 d3                	mov    %edx,%ebx
  800efe:	89 d7                	mov    %edx,%edi
  800f00:	89 d6                	mov    %edx,%esi
  800f02:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800f04:	5b                   	pop    %ebx
  800f05:	5e                   	pop    %esi
  800f06:	5f                   	pop    %edi
  800f07:	5d                   	pop    %ebp
  800f08:	c3                   	ret    

00800f09 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800f09:	55                   	push   %ebp
  800f0a:	89 e5                	mov    %esp,%ebp
  800f0c:	53                   	push   %ebx
  800f0d:	83 ec 04             	sub    $0x4,%esp
	int r;
	void * address = (void *)(pn*PGSIZE);
  800f10:	89 d3                	mov    %edx,%ebx
  800f12:	c1 e3 0c             	shl    $0xc,%ebx
	
	if((uvpt[pn] & PTE_SHARE))
  800f15:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800f1c:	f6 c5 04             	test   $0x4,%ch
  800f1f:	74 38                	je     800f59 <duppage+0x50>
	{
		if ((r = sys_page_map(0, address, envid, address, (uvpt[pn] | PTE_SYSCALL))) < 0)
  800f21:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f28:	83 ec 0c             	sub    $0xc,%esp
  800f2b:	81 ca 07 0e 00 00    	or     $0xe07,%edx
  800f31:	52                   	push   %edx
  800f32:	53                   	push   %ebx
  800f33:	50                   	push   %eax
  800f34:	53                   	push   %ebx
  800f35:	6a 00                	push   $0x0
  800f37:	e8 00 fe ff ff       	call   800d3c <sys_page_map>
  800f3c:	83 c4 20             	add    $0x20,%esp
  800f3f:	85 c0                	test   %eax,%eax
  800f41:	0f 89 b8 00 00 00    	jns    800fff <duppage+0xf6>
			panic("sys_page_map: %e", r);
  800f47:	50                   	push   %eax
  800f48:	68 8a 2b 80 00       	push   $0x802b8a
  800f4d:	6a 4e                	push   $0x4e
  800f4f:	68 9b 2b 80 00       	push   $0x802b9b
  800f54:	e8 3f f3 ff ff       	call   800298 <_panic>
	}
	else if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW))
  800f59:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800f60:	f6 c1 02             	test   $0x2,%cl
  800f63:	75 0c                	jne    800f71 <duppage+0x68>
  800f65:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800f6c:	f6 c5 08             	test   $0x8,%ch
  800f6f:	74 57                	je     800fc8 <duppage+0xbf>
	{
		int perm = 0;
		perm |= PTE_P|PTE_U|PTE_COW;
	
		if ((r = sys_page_map(0, address, envid, address, perm)) < 0)
  800f71:	83 ec 0c             	sub    $0xc,%esp
  800f74:	68 05 08 00 00       	push   $0x805
  800f79:	53                   	push   %ebx
  800f7a:	50                   	push   %eax
  800f7b:	53                   	push   %ebx
  800f7c:	6a 00                	push   $0x0
  800f7e:	e8 b9 fd ff ff       	call   800d3c <sys_page_map>
  800f83:	83 c4 20             	add    $0x20,%esp
  800f86:	85 c0                	test   %eax,%eax
  800f88:	79 12                	jns    800f9c <duppage+0x93>
			panic("sys_page_map: %e", r);
  800f8a:	50                   	push   %eax
  800f8b:	68 8a 2b 80 00       	push   $0x802b8a
  800f90:	6a 56                	push   $0x56
  800f92:	68 9b 2b 80 00       	push   $0x802b9b
  800f97:	e8 fc f2 ff ff       	call   800298 <_panic>
		if ((r = sys_page_map(0, address, 0, address, perm)) < 0)
  800f9c:	83 ec 0c             	sub    $0xc,%esp
  800f9f:	68 05 08 00 00       	push   $0x805
  800fa4:	53                   	push   %ebx
  800fa5:	6a 00                	push   $0x0
  800fa7:	53                   	push   %ebx
  800fa8:	6a 00                	push   $0x0
  800faa:	e8 8d fd ff ff       	call   800d3c <sys_page_map>
  800faf:	83 c4 20             	add    $0x20,%esp
  800fb2:	85 c0                	test   %eax,%eax
  800fb4:	79 49                	jns    800fff <duppage+0xf6>
			panic("sys_page_map: %e", r);
  800fb6:	50                   	push   %eax
  800fb7:	68 8a 2b 80 00       	push   $0x802b8a
  800fbc:	6a 58                	push   $0x58
  800fbe:	68 9b 2b 80 00       	push   $0x802b9b
  800fc3:	e8 d0 f2 ff ff       	call   800298 <_panic>
	}
	else if((uvpt[pn] & ~PTE_U) == 0)
  800fc8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fcf:	f7 c2 fb ff ff ff    	test   $0xfffffffb,%edx
  800fd5:	75 28                	jne    800fff <duppage+0xf6>
	{
		//cprintf("im here");
		if ((r = sys_page_map(0, address, envid, address, PTE_P|PTE_U)) < 0)
  800fd7:	83 ec 0c             	sub    $0xc,%esp
  800fda:	6a 05                	push   $0x5
  800fdc:	53                   	push   %ebx
  800fdd:	50                   	push   %eax
  800fde:	53                   	push   %ebx
  800fdf:	6a 00                	push   $0x0
  800fe1:	e8 56 fd ff ff       	call   800d3c <sys_page_map>
  800fe6:	83 c4 20             	add    $0x20,%esp
  800fe9:	85 c0                	test   %eax,%eax
  800feb:	79 12                	jns    800fff <duppage+0xf6>
			panic("sys_page_map: %e", r);	
  800fed:	50                   	push   %eax
  800fee:	68 8a 2b 80 00       	push   $0x802b8a
  800ff3:	6a 5e                	push   $0x5e
  800ff5:	68 9b 2b 80 00       	push   $0x802b9b
  800ffa:	e8 99 f2 ff ff       	call   800298 <_panic>
	}
	return 0;
}
  800fff:	b8 00 00 00 00       	mov    $0x0,%eax
  801004:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801007:	c9                   	leave  
  801008:	c3                   	ret    

00801009 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801009:	55                   	push   %ebp
  80100a:	89 e5                	mov    %esp,%ebp
  80100c:	53                   	push   %ebx
  80100d:	83 ec 08             	sub    $0x8,%esp
	void *addr = (void *) utf->utf_fault_va;
  801010:	8b 45 08             	mov    0x8(%ebp),%eax
  801013:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	unsigned pn = ((uint32_t)addr)/PGSIZE;
  801015:	89 d8                	mov    %ebx,%eax
  801017:	c1 e8 0c             	shr    $0xc,%eax
	pte_t pte = uvpt[pn];
  80101a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// Allocate a new page, mapped at temp location
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  801021:	6a 07                	push   $0x7
  801023:	68 00 f0 7f 00       	push   $0x7ff000
  801028:	6a 00                	push   $0x0
  80102a:	e8 ca fc ff ff       	call   800cf9 <sys_page_alloc>
  80102f:	83 c4 10             	add    $0x10,%esp
  801032:	85 c0                	test   %eax,%eax
  801034:	79 12                	jns    801048 <pgfault+0x3f>
		panic("sys_page_alloc: %e", r);
  801036:	50                   	push   %eax
  801037:	68 a6 2b 80 00       	push   $0x802ba6
  80103c:	6a 2b                	push   $0x2b
  80103e:	68 9b 2b 80 00       	push   $0x802b9b
  801043:	e8 50 f2 ff ff       	call   800298 <_panic>

	// Copy the data from the old page to this new page
	void *addr_pgstart = (void *) ROUNDDOWN(addr, PGSIZE);
  801048:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr_pgstart, PGSIZE);
  80104e:	83 ec 04             	sub    $0x4,%esp
  801051:	68 00 10 00 00       	push   $0x1000
  801056:	53                   	push   %ebx
  801057:	68 00 f0 7f 00       	push   $0x7ff000
  80105c:	e8 27 fa ff ff       	call   800a88 <memmove>

	// Move the new page to the old page's address
	if ((r = sys_page_map(0, PFTEMP, 0, addr_pgstart, PTE_P|PTE_U|PTE_W)) < 0)
  801061:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801068:	53                   	push   %ebx
  801069:	6a 00                	push   $0x0
  80106b:	68 00 f0 7f 00       	push   $0x7ff000
  801070:	6a 00                	push   $0x0
  801072:	e8 c5 fc ff ff       	call   800d3c <sys_page_map>
  801077:	83 c4 20             	add    $0x20,%esp
  80107a:	85 c0                	test   %eax,%eax
  80107c:	79 12                	jns    801090 <pgfault+0x87>
		panic("sys_page_map: %e", r);
  80107e:	50                   	push   %eax
  80107f:	68 8a 2b 80 00       	push   $0x802b8a
  801084:	6a 33                	push   $0x33
  801086:	68 9b 2b 80 00       	push   $0x802b9b
  80108b:	e8 08 f2 ff ff       	call   800298 <_panic>

	// Unmap the temp location
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  801090:	83 ec 08             	sub    $0x8,%esp
  801093:	68 00 f0 7f 00       	push   $0x7ff000
  801098:	6a 00                	push   $0x0
  80109a:	e8 df fc ff ff       	call   800d7e <sys_page_unmap>
  80109f:	83 c4 10             	add    $0x10,%esp
  8010a2:	85 c0                	test   %eax,%eax
  8010a4:	79 12                	jns    8010b8 <pgfault+0xaf>
		panic("sys_page_unmap: %e", r);
  8010a6:	50                   	push   %eax
  8010a7:	68 b9 2b 80 00       	push   $0x802bb9
  8010ac:	6a 37                	push   $0x37
  8010ae:	68 9b 2b 80 00       	push   $0x802b9b
  8010b3:	e8 e0 f1 ff ff       	call   800298 <_panic>
}
  8010b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010bb:	c9                   	leave  
  8010bc:	c3                   	ret    

008010bd <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8010bd:	55                   	push   %ebp
  8010be:	89 e5                	mov    %esp,%ebp
  8010c0:	56                   	push   %esi
  8010c1:	53                   	push   %ebx
  8010c2:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
	// Set up page fault handler
	set_pgfault_handler(&pgfault);
  8010c5:	68 09 10 80 00       	push   $0x801009
  8010ca:	e8 5d 12 00 00       	call   80232c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8010cf:	b8 07 00 00 00       	mov    $0x7,%eax
  8010d4:	cd 30                	int    $0x30

	// Create child
	envid_t envid = sys_exofork();
  8010d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (envid < 0) {
  8010d9:	83 c4 10             	add    $0x10,%esp
  8010dc:	85 c0                	test   %eax,%eax
  8010de:	79 12                	jns    8010f2 <fork+0x35>
		panic("sys_exofork: %e", envid);
  8010e0:	50                   	push   %eax
  8010e1:	68 cc 2b 80 00       	push   $0x802bcc
  8010e6:	6a 7c                	push   $0x7c
  8010e8:	68 9b 2b 80 00       	push   $0x802b9b
  8010ed:	e8 a6 f1 ff ff       	call   800298 <_panic>
		return envid;
	}
	if (envid == 0) {
  8010f2:	85 c0                	test   %eax,%eax
  8010f4:	75 1e                	jne    801114 <fork+0x57>
		// We are the child.
		thisenv = &envs[ENVX(sys_getenvid())]; // Fix thisenv
  8010f6:	e8 c0 fb ff ff       	call   800cbb <sys_getenvid>
  8010fb:	25 ff 03 00 00       	and    $0x3ff,%eax
  801100:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801103:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801108:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  80110d:	b8 00 00 00 00       	mov    $0x0,%eax
  801112:	eb 7d                	jmp    801191 <fork+0xd4>

	// Set page fault handler on the child.
	// The parent needs to do it, else the child wouldn't be able to handle
	// the fault when trying to access it's stack (which happens as soon it starts)
	extern void _pgfault_upcall(void);
	sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);
  801114:	83 ec 04             	sub    $0x4,%esp
  801117:	6a 07                	push   $0x7
  801119:	68 00 f0 bf ee       	push   $0xeebff000
  80111e:	50                   	push   %eax
  80111f:	e8 d5 fb ff ff       	call   800cf9 <sys_page_alloc>
	sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  801124:	83 c4 08             	add    $0x8,%esp
  801127:	68 71 23 80 00       	push   $0x802371
  80112c:	ff 75 f4             	pushl  -0xc(%ebp)
  80112f:	e8 10 fd ff ff       	call   800e44 <sys_env_set_pgfault_upcall>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  801134:	be 04 70 80 00       	mov    $0x807004,%esi
  801139:	c1 ee 0c             	shr    $0xc,%esi
  80113c:	83 c4 10             	add    $0x10,%esp
  80113f:	bb 00 08 00 00       	mov    $0x800,%ebx
  801144:	eb 0d                	jmp    801153 <fork+0x96>
		duppage(envid, pn);
  801146:	89 da                	mov    %ebx,%edx
  801148:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80114b:	e8 b9 fd ff ff       	call   800f09 <duppage>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  801150:	83 c3 01             	add    $0x1,%ebx
  801153:	39 f3                	cmp    %esi,%ebx
  801155:	76 ef                	jbe    801146 <fork+0x89>
	}

	// Also copy the stack we are currently running on
	// I think it should loop from ustacktop to this page, since the stack
	// can have more than 1 page
	duppage(envid, ((uint32_t) &envid)/PGSIZE);
  801157:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80115a:	c1 ea 0c             	shr    $0xc,%edx
  80115d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801160:	e8 a4 fd ff ff       	call   800f09 <duppage>

	// Start the child environmnet running
	int r;
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  801165:	83 ec 08             	sub    $0x8,%esp
  801168:	6a 02                	push   $0x2
  80116a:	ff 75 f4             	pushl  -0xc(%ebp)
  80116d:	e8 4e fc ff ff       	call   800dc0 <sys_env_set_status>
  801172:	83 c4 10             	add    $0x10,%esp
  801175:	85 c0                	test   %eax,%eax
  801177:	79 15                	jns    80118e <fork+0xd1>
		panic("sys_env_set_status: %e", r);
  801179:	50                   	push   %eax
  80117a:	68 dc 2b 80 00       	push   $0x802bdc
  80117f:	68 9c 00 00 00       	push   $0x9c
  801184:	68 9b 2b 80 00       	push   $0x802b9b
  801189:	e8 0a f1 ff ff       	call   800298 <_panic>
		return r;
	}

	return envid;
  80118e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  801191:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801194:	5b                   	pop    %ebx
  801195:	5e                   	pop    %esi
  801196:	5d                   	pop    %ebp
  801197:	c3                   	ret    

00801198 <sfork>:

// Challenge!
int
sfork(void)
{
  801198:	55                   	push   %ebp
  801199:	89 e5                	mov    %esp,%ebp
  80119b:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80119e:	68 f3 2b 80 00       	push   $0x802bf3
  8011a3:	68 a7 00 00 00       	push   $0xa7
  8011a8:	68 9b 2b 80 00       	push   $0x802b9b
  8011ad:	e8 e6 f0 ff ff       	call   800298 <_panic>

008011b2 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011b2:	55                   	push   %ebp
  8011b3:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b8:	05 00 00 00 30       	add    $0x30000000,%eax
  8011bd:	c1 e8 0c             	shr    $0xc,%eax
}
  8011c0:	5d                   	pop    %ebp
  8011c1:	c3                   	ret    

008011c2 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011c2:	55                   	push   %ebp
  8011c3:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c8:	05 00 00 00 30       	add    $0x30000000,%eax
  8011cd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011d2:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011d7:	5d                   	pop    %ebp
  8011d8:	c3                   	ret    

008011d9 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011d9:	55                   	push   %ebp
  8011da:	89 e5                	mov    %esp,%ebp
  8011dc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011df:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011e4:	89 c2                	mov    %eax,%edx
  8011e6:	c1 ea 16             	shr    $0x16,%edx
  8011e9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011f0:	f6 c2 01             	test   $0x1,%dl
  8011f3:	74 11                	je     801206 <fd_alloc+0x2d>
  8011f5:	89 c2                	mov    %eax,%edx
  8011f7:	c1 ea 0c             	shr    $0xc,%edx
  8011fa:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801201:	f6 c2 01             	test   $0x1,%dl
  801204:	75 09                	jne    80120f <fd_alloc+0x36>
			*fd_store = fd;
  801206:	89 01                	mov    %eax,(%ecx)
			return 0;
  801208:	b8 00 00 00 00       	mov    $0x0,%eax
  80120d:	eb 17                	jmp    801226 <fd_alloc+0x4d>
  80120f:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801214:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801219:	75 c9                	jne    8011e4 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80121b:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801221:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801226:	5d                   	pop    %ebp
  801227:	c3                   	ret    

00801228 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801228:	55                   	push   %ebp
  801229:	89 e5                	mov    %esp,%ebp
  80122b:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80122e:	83 f8 1f             	cmp    $0x1f,%eax
  801231:	77 36                	ja     801269 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801233:	c1 e0 0c             	shl    $0xc,%eax
  801236:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80123b:	89 c2                	mov    %eax,%edx
  80123d:	c1 ea 16             	shr    $0x16,%edx
  801240:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801247:	f6 c2 01             	test   $0x1,%dl
  80124a:	74 24                	je     801270 <fd_lookup+0x48>
  80124c:	89 c2                	mov    %eax,%edx
  80124e:	c1 ea 0c             	shr    $0xc,%edx
  801251:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801258:	f6 c2 01             	test   $0x1,%dl
  80125b:	74 1a                	je     801277 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80125d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801260:	89 02                	mov    %eax,(%edx)
	return 0;
  801262:	b8 00 00 00 00       	mov    $0x0,%eax
  801267:	eb 13                	jmp    80127c <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801269:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80126e:	eb 0c                	jmp    80127c <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801270:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801275:	eb 05                	jmp    80127c <fd_lookup+0x54>
  801277:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80127c:	5d                   	pop    %ebp
  80127d:	c3                   	ret    

0080127e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80127e:	55                   	push   %ebp
  80127f:	89 e5                	mov    %esp,%ebp
  801281:	83 ec 08             	sub    $0x8,%esp
  801284:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801287:	ba 8c 2c 80 00       	mov    $0x802c8c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80128c:	eb 13                	jmp    8012a1 <dev_lookup+0x23>
  80128e:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801291:	39 08                	cmp    %ecx,(%eax)
  801293:	75 0c                	jne    8012a1 <dev_lookup+0x23>
			*dev = devtab[i];
  801295:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801298:	89 01                	mov    %eax,(%ecx)
			return 0;
  80129a:	b8 00 00 00 00       	mov    $0x0,%eax
  80129f:	eb 2e                	jmp    8012cf <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012a1:	8b 02                	mov    (%edx),%eax
  8012a3:	85 c0                	test   %eax,%eax
  8012a5:	75 e7                	jne    80128e <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012a7:	a1 08 40 80 00       	mov    0x804008,%eax
  8012ac:	8b 40 48             	mov    0x48(%eax),%eax
  8012af:	83 ec 04             	sub    $0x4,%esp
  8012b2:	51                   	push   %ecx
  8012b3:	50                   	push   %eax
  8012b4:	68 0c 2c 80 00       	push   $0x802c0c
  8012b9:	e8 b3 f0 ff ff       	call   800371 <cprintf>
	*dev = 0;
  8012be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012c1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012c7:	83 c4 10             	add    $0x10,%esp
  8012ca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012cf:	c9                   	leave  
  8012d0:	c3                   	ret    

008012d1 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012d1:	55                   	push   %ebp
  8012d2:	89 e5                	mov    %esp,%ebp
  8012d4:	56                   	push   %esi
  8012d5:	53                   	push   %ebx
  8012d6:	83 ec 10             	sub    $0x10,%esp
  8012d9:	8b 75 08             	mov    0x8(%ebp),%esi
  8012dc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012df:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012e2:	50                   	push   %eax
  8012e3:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012e9:	c1 e8 0c             	shr    $0xc,%eax
  8012ec:	50                   	push   %eax
  8012ed:	e8 36 ff ff ff       	call   801228 <fd_lookup>
  8012f2:	83 c4 08             	add    $0x8,%esp
  8012f5:	85 c0                	test   %eax,%eax
  8012f7:	78 05                	js     8012fe <fd_close+0x2d>
	    || fd != fd2)
  8012f9:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012fc:	74 0c                	je     80130a <fd_close+0x39>
		return (must_exist ? r : 0);
  8012fe:	84 db                	test   %bl,%bl
  801300:	ba 00 00 00 00       	mov    $0x0,%edx
  801305:	0f 44 c2             	cmove  %edx,%eax
  801308:	eb 41                	jmp    80134b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80130a:	83 ec 08             	sub    $0x8,%esp
  80130d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801310:	50                   	push   %eax
  801311:	ff 36                	pushl  (%esi)
  801313:	e8 66 ff ff ff       	call   80127e <dev_lookup>
  801318:	89 c3                	mov    %eax,%ebx
  80131a:	83 c4 10             	add    $0x10,%esp
  80131d:	85 c0                	test   %eax,%eax
  80131f:	78 1a                	js     80133b <fd_close+0x6a>
		if (dev->dev_close)
  801321:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801324:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801327:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80132c:	85 c0                	test   %eax,%eax
  80132e:	74 0b                	je     80133b <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801330:	83 ec 0c             	sub    $0xc,%esp
  801333:	56                   	push   %esi
  801334:	ff d0                	call   *%eax
  801336:	89 c3                	mov    %eax,%ebx
  801338:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80133b:	83 ec 08             	sub    $0x8,%esp
  80133e:	56                   	push   %esi
  80133f:	6a 00                	push   $0x0
  801341:	e8 38 fa ff ff       	call   800d7e <sys_page_unmap>
	return r;
  801346:	83 c4 10             	add    $0x10,%esp
  801349:	89 d8                	mov    %ebx,%eax
}
  80134b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80134e:	5b                   	pop    %ebx
  80134f:	5e                   	pop    %esi
  801350:	5d                   	pop    %ebp
  801351:	c3                   	ret    

00801352 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801352:	55                   	push   %ebp
  801353:	89 e5                	mov    %esp,%ebp
  801355:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801358:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80135b:	50                   	push   %eax
  80135c:	ff 75 08             	pushl  0x8(%ebp)
  80135f:	e8 c4 fe ff ff       	call   801228 <fd_lookup>
  801364:	83 c4 08             	add    $0x8,%esp
  801367:	85 c0                	test   %eax,%eax
  801369:	78 10                	js     80137b <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80136b:	83 ec 08             	sub    $0x8,%esp
  80136e:	6a 01                	push   $0x1
  801370:	ff 75 f4             	pushl  -0xc(%ebp)
  801373:	e8 59 ff ff ff       	call   8012d1 <fd_close>
  801378:	83 c4 10             	add    $0x10,%esp
}
  80137b:	c9                   	leave  
  80137c:	c3                   	ret    

0080137d <close_all>:

void
close_all(void)
{
  80137d:	55                   	push   %ebp
  80137e:	89 e5                	mov    %esp,%ebp
  801380:	53                   	push   %ebx
  801381:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801384:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801389:	83 ec 0c             	sub    $0xc,%esp
  80138c:	53                   	push   %ebx
  80138d:	e8 c0 ff ff ff       	call   801352 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801392:	83 c3 01             	add    $0x1,%ebx
  801395:	83 c4 10             	add    $0x10,%esp
  801398:	83 fb 20             	cmp    $0x20,%ebx
  80139b:	75 ec                	jne    801389 <close_all+0xc>
		close(i);
}
  80139d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013a0:	c9                   	leave  
  8013a1:	c3                   	ret    

008013a2 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013a2:	55                   	push   %ebp
  8013a3:	89 e5                	mov    %esp,%ebp
  8013a5:	57                   	push   %edi
  8013a6:	56                   	push   %esi
  8013a7:	53                   	push   %ebx
  8013a8:	83 ec 2c             	sub    $0x2c,%esp
  8013ab:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013ae:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013b1:	50                   	push   %eax
  8013b2:	ff 75 08             	pushl  0x8(%ebp)
  8013b5:	e8 6e fe ff ff       	call   801228 <fd_lookup>
  8013ba:	83 c4 08             	add    $0x8,%esp
  8013bd:	85 c0                	test   %eax,%eax
  8013bf:	0f 88 c1 00 00 00    	js     801486 <dup+0xe4>
		return r;
	close(newfdnum);
  8013c5:	83 ec 0c             	sub    $0xc,%esp
  8013c8:	56                   	push   %esi
  8013c9:	e8 84 ff ff ff       	call   801352 <close>

	newfd = INDEX2FD(newfdnum);
  8013ce:	89 f3                	mov    %esi,%ebx
  8013d0:	c1 e3 0c             	shl    $0xc,%ebx
  8013d3:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013d9:	83 c4 04             	add    $0x4,%esp
  8013dc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013df:	e8 de fd ff ff       	call   8011c2 <fd2data>
  8013e4:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013e6:	89 1c 24             	mov    %ebx,(%esp)
  8013e9:	e8 d4 fd ff ff       	call   8011c2 <fd2data>
  8013ee:	83 c4 10             	add    $0x10,%esp
  8013f1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013f4:	89 f8                	mov    %edi,%eax
  8013f6:	c1 e8 16             	shr    $0x16,%eax
  8013f9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801400:	a8 01                	test   $0x1,%al
  801402:	74 37                	je     80143b <dup+0x99>
  801404:	89 f8                	mov    %edi,%eax
  801406:	c1 e8 0c             	shr    $0xc,%eax
  801409:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801410:	f6 c2 01             	test   $0x1,%dl
  801413:	74 26                	je     80143b <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801415:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80141c:	83 ec 0c             	sub    $0xc,%esp
  80141f:	25 07 0e 00 00       	and    $0xe07,%eax
  801424:	50                   	push   %eax
  801425:	ff 75 d4             	pushl  -0x2c(%ebp)
  801428:	6a 00                	push   $0x0
  80142a:	57                   	push   %edi
  80142b:	6a 00                	push   $0x0
  80142d:	e8 0a f9 ff ff       	call   800d3c <sys_page_map>
  801432:	89 c7                	mov    %eax,%edi
  801434:	83 c4 20             	add    $0x20,%esp
  801437:	85 c0                	test   %eax,%eax
  801439:	78 2e                	js     801469 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80143b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80143e:	89 d0                	mov    %edx,%eax
  801440:	c1 e8 0c             	shr    $0xc,%eax
  801443:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80144a:	83 ec 0c             	sub    $0xc,%esp
  80144d:	25 07 0e 00 00       	and    $0xe07,%eax
  801452:	50                   	push   %eax
  801453:	53                   	push   %ebx
  801454:	6a 00                	push   $0x0
  801456:	52                   	push   %edx
  801457:	6a 00                	push   $0x0
  801459:	e8 de f8 ff ff       	call   800d3c <sys_page_map>
  80145e:	89 c7                	mov    %eax,%edi
  801460:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801463:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801465:	85 ff                	test   %edi,%edi
  801467:	79 1d                	jns    801486 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801469:	83 ec 08             	sub    $0x8,%esp
  80146c:	53                   	push   %ebx
  80146d:	6a 00                	push   $0x0
  80146f:	e8 0a f9 ff ff       	call   800d7e <sys_page_unmap>
	sys_page_unmap(0, nva);
  801474:	83 c4 08             	add    $0x8,%esp
  801477:	ff 75 d4             	pushl  -0x2c(%ebp)
  80147a:	6a 00                	push   $0x0
  80147c:	e8 fd f8 ff ff       	call   800d7e <sys_page_unmap>
	return r;
  801481:	83 c4 10             	add    $0x10,%esp
  801484:	89 f8                	mov    %edi,%eax
}
  801486:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801489:	5b                   	pop    %ebx
  80148a:	5e                   	pop    %esi
  80148b:	5f                   	pop    %edi
  80148c:	5d                   	pop    %ebp
  80148d:	c3                   	ret    

0080148e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80148e:	55                   	push   %ebp
  80148f:	89 e5                	mov    %esp,%ebp
  801491:	53                   	push   %ebx
  801492:	83 ec 14             	sub    $0x14,%esp
  801495:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801498:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80149b:	50                   	push   %eax
  80149c:	53                   	push   %ebx
  80149d:	e8 86 fd ff ff       	call   801228 <fd_lookup>
  8014a2:	83 c4 08             	add    $0x8,%esp
  8014a5:	89 c2                	mov    %eax,%edx
  8014a7:	85 c0                	test   %eax,%eax
  8014a9:	78 6d                	js     801518 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014ab:	83 ec 08             	sub    $0x8,%esp
  8014ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014b1:	50                   	push   %eax
  8014b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014b5:	ff 30                	pushl  (%eax)
  8014b7:	e8 c2 fd ff ff       	call   80127e <dev_lookup>
  8014bc:	83 c4 10             	add    $0x10,%esp
  8014bf:	85 c0                	test   %eax,%eax
  8014c1:	78 4c                	js     80150f <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014c3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014c6:	8b 42 08             	mov    0x8(%edx),%eax
  8014c9:	83 e0 03             	and    $0x3,%eax
  8014cc:	83 f8 01             	cmp    $0x1,%eax
  8014cf:	75 21                	jne    8014f2 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014d1:	a1 08 40 80 00       	mov    0x804008,%eax
  8014d6:	8b 40 48             	mov    0x48(%eax),%eax
  8014d9:	83 ec 04             	sub    $0x4,%esp
  8014dc:	53                   	push   %ebx
  8014dd:	50                   	push   %eax
  8014de:	68 50 2c 80 00       	push   $0x802c50
  8014e3:	e8 89 ee ff ff       	call   800371 <cprintf>
		return -E_INVAL;
  8014e8:	83 c4 10             	add    $0x10,%esp
  8014eb:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014f0:	eb 26                	jmp    801518 <read+0x8a>
	}
	if (!dev->dev_read)
  8014f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014f5:	8b 40 08             	mov    0x8(%eax),%eax
  8014f8:	85 c0                	test   %eax,%eax
  8014fa:	74 17                	je     801513 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014fc:	83 ec 04             	sub    $0x4,%esp
  8014ff:	ff 75 10             	pushl  0x10(%ebp)
  801502:	ff 75 0c             	pushl  0xc(%ebp)
  801505:	52                   	push   %edx
  801506:	ff d0                	call   *%eax
  801508:	89 c2                	mov    %eax,%edx
  80150a:	83 c4 10             	add    $0x10,%esp
  80150d:	eb 09                	jmp    801518 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80150f:	89 c2                	mov    %eax,%edx
  801511:	eb 05                	jmp    801518 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801513:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801518:	89 d0                	mov    %edx,%eax
  80151a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80151d:	c9                   	leave  
  80151e:	c3                   	ret    

0080151f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80151f:	55                   	push   %ebp
  801520:	89 e5                	mov    %esp,%ebp
  801522:	57                   	push   %edi
  801523:	56                   	push   %esi
  801524:	53                   	push   %ebx
  801525:	83 ec 0c             	sub    $0xc,%esp
  801528:	8b 7d 08             	mov    0x8(%ebp),%edi
  80152b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80152e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801533:	eb 21                	jmp    801556 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801535:	83 ec 04             	sub    $0x4,%esp
  801538:	89 f0                	mov    %esi,%eax
  80153a:	29 d8                	sub    %ebx,%eax
  80153c:	50                   	push   %eax
  80153d:	89 d8                	mov    %ebx,%eax
  80153f:	03 45 0c             	add    0xc(%ebp),%eax
  801542:	50                   	push   %eax
  801543:	57                   	push   %edi
  801544:	e8 45 ff ff ff       	call   80148e <read>
		if (m < 0)
  801549:	83 c4 10             	add    $0x10,%esp
  80154c:	85 c0                	test   %eax,%eax
  80154e:	78 10                	js     801560 <readn+0x41>
			return m;
		if (m == 0)
  801550:	85 c0                	test   %eax,%eax
  801552:	74 0a                	je     80155e <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801554:	01 c3                	add    %eax,%ebx
  801556:	39 f3                	cmp    %esi,%ebx
  801558:	72 db                	jb     801535 <readn+0x16>
  80155a:	89 d8                	mov    %ebx,%eax
  80155c:	eb 02                	jmp    801560 <readn+0x41>
  80155e:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801560:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801563:	5b                   	pop    %ebx
  801564:	5e                   	pop    %esi
  801565:	5f                   	pop    %edi
  801566:	5d                   	pop    %ebp
  801567:	c3                   	ret    

00801568 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801568:	55                   	push   %ebp
  801569:	89 e5                	mov    %esp,%ebp
  80156b:	53                   	push   %ebx
  80156c:	83 ec 14             	sub    $0x14,%esp
  80156f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801572:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801575:	50                   	push   %eax
  801576:	53                   	push   %ebx
  801577:	e8 ac fc ff ff       	call   801228 <fd_lookup>
  80157c:	83 c4 08             	add    $0x8,%esp
  80157f:	89 c2                	mov    %eax,%edx
  801581:	85 c0                	test   %eax,%eax
  801583:	78 68                	js     8015ed <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801585:	83 ec 08             	sub    $0x8,%esp
  801588:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80158b:	50                   	push   %eax
  80158c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80158f:	ff 30                	pushl  (%eax)
  801591:	e8 e8 fc ff ff       	call   80127e <dev_lookup>
  801596:	83 c4 10             	add    $0x10,%esp
  801599:	85 c0                	test   %eax,%eax
  80159b:	78 47                	js     8015e4 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80159d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015a0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015a4:	75 21                	jne    8015c7 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015a6:	a1 08 40 80 00       	mov    0x804008,%eax
  8015ab:	8b 40 48             	mov    0x48(%eax),%eax
  8015ae:	83 ec 04             	sub    $0x4,%esp
  8015b1:	53                   	push   %ebx
  8015b2:	50                   	push   %eax
  8015b3:	68 6c 2c 80 00       	push   $0x802c6c
  8015b8:	e8 b4 ed ff ff       	call   800371 <cprintf>
		return -E_INVAL;
  8015bd:	83 c4 10             	add    $0x10,%esp
  8015c0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015c5:	eb 26                	jmp    8015ed <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015c7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015ca:	8b 52 0c             	mov    0xc(%edx),%edx
  8015cd:	85 d2                	test   %edx,%edx
  8015cf:	74 17                	je     8015e8 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015d1:	83 ec 04             	sub    $0x4,%esp
  8015d4:	ff 75 10             	pushl  0x10(%ebp)
  8015d7:	ff 75 0c             	pushl  0xc(%ebp)
  8015da:	50                   	push   %eax
  8015db:	ff d2                	call   *%edx
  8015dd:	89 c2                	mov    %eax,%edx
  8015df:	83 c4 10             	add    $0x10,%esp
  8015e2:	eb 09                	jmp    8015ed <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015e4:	89 c2                	mov    %eax,%edx
  8015e6:	eb 05                	jmp    8015ed <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015e8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8015ed:	89 d0                	mov    %edx,%eax
  8015ef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015f2:	c9                   	leave  
  8015f3:	c3                   	ret    

008015f4 <seek>:

int
seek(int fdnum, off_t offset)
{
  8015f4:	55                   	push   %ebp
  8015f5:	89 e5                	mov    %esp,%ebp
  8015f7:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015fa:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015fd:	50                   	push   %eax
  8015fe:	ff 75 08             	pushl  0x8(%ebp)
  801601:	e8 22 fc ff ff       	call   801228 <fd_lookup>
  801606:	83 c4 08             	add    $0x8,%esp
  801609:	85 c0                	test   %eax,%eax
  80160b:	78 0e                	js     80161b <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80160d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801610:	8b 55 0c             	mov    0xc(%ebp),%edx
  801613:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801616:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80161b:	c9                   	leave  
  80161c:	c3                   	ret    

0080161d <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80161d:	55                   	push   %ebp
  80161e:	89 e5                	mov    %esp,%ebp
  801620:	53                   	push   %ebx
  801621:	83 ec 14             	sub    $0x14,%esp
  801624:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801627:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80162a:	50                   	push   %eax
  80162b:	53                   	push   %ebx
  80162c:	e8 f7 fb ff ff       	call   801228 <fd_lookup>
  801631:	83 c4 08             	add    $0x8,%esp
  801634:	89 c2                	mov    %eax,%edx
  801636:	85 c0                	test   %eax,%eax
  801638:	78 65                	js     80169f <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80163a:	83 ec 08             	sub    $0x8,%esp
  80163d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801640:	50                   	push   %eax
  801641:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801644:	ff 30                	pushl  (%eax)
  801646:	e8 33 fc ff ff       	call   80127e <dev_lookup>
  80164b:	83 c4 10             	add    $0x10,%esp
  80164e:	85 c0                	test   %eax,%eax
  801650:	78 44                	js     801696 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801652:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801655:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801659:	75 21                	jne    80167c <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80165b:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801660:	8b 40 48             	mov    0x48(%eax),%eax
  801663:	83 ec 04             	sub    $0x4,%esp
  801666:	53                   	push   %ebx
  801667:	50                   	push   %eax
  801668:	68 2c 2c 80 00       	push   $0x802c2c
  80166d:	e8 ff ec ff ff       	call   800371 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801672:	83 c4 10             	add    $0x10,%esp
  801675:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80167a:	eb 23                	jmp    80169f <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80167c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80167f:	8b 52 18             	mov    0x18(%edx),%edx
  801682:	85 d2                	test   %edx,%edx
  801684:	74 14                	je     80169a <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801686:	83 ec 08             	sub    $0x8,%esp
  801689:	ff 75 0c             	pushl  0xc(%ebp)
  80168c:	50                   	push   %eax
  80168d:	ff d2                	call   *%edx
  80168f:	89 c2                	mov    %eax,%edx
  801691:	83 c4 10             	add    $0x10,%esp
  801694:	eb 09                	jmp    80169f <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801696:	89 c2                	mov    %eax,%edx
  801698:	eb 05                	jmp    80169f <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80169a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80169f:	89 d0                	mov    %edx,%eax
  8016a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016a4:	c9                   	leave  
  8016a5:	c3                   	ret    

008016a6 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016a6:	55                   	push   %ebp
  8016a7:	89 e5                	mov    %esp,%ebp
  8016a9:	53                   	push   %ebx
  8016aa:	83 ec 14             	sub    $0x14,%esp
  8016ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016b0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016b3:	50                   	push   %eax
  8016b4:	ff 75 08             	pushl  0x8(%ebp)
  8016b7:	e8 6c fb ff ff       	call   801228 <fd_lookup>
  8016bc:	83 c4 08             	add    $0x8,%esp
  8016bf:	89 c2                	mov    %eax,%edx
  8016c1:	85 c0                	test   %eax,%eax
  8016c3:	78 58                	js     80171d <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016c5:	83 ec 08             	sub    $0x8,%esp
  8016c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016cb:	50                   	push   %eax
  8016cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016cf:	ff 30                	pushl  (%eax)
  8016d1:	e8 a8 fb ff ff       	call   80127e <dev_lookup>
  8016d6:	83 c4 10             	add    $0x10,%esp
  8016d9:	85 c0                	test   %eax,%eax
  8016db:	78 37                	js     801714 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016e0:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016e4:	74 32                	je     801718 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016e6:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016e9:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016f0:	00 00 00 
	stat->st_isdir = 0;
  8016f3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016fa:	00 00 00 
	stat->st_dev = dev;
  8016fd:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801703:	83 ec 08             	sub    $0x8,%esp
  801706:	53                   	push   %ebx
  801707:	ff 75 f0             	pushl  -0x10(%ebp)
  80170a:	ff 50 14             	call   *0x14(%eax)
  80170d:	89 c2                	mov    %eax,%edx
  80170f:	83 c4 10             	add    $0x10,%esp
  801712:	eb 09                	jmp    80171d <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801714:	89 c2                	mov    %eax,%edx
  801716:	eb 05                	jmp    80171d <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801718:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80171d:	89 d0                	mov    %edx,%eax
  80171f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801722:	c9                   	leave  
  801723:	c3                   	ret    

00801724 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801724:	55                   	push   %ebp
  801725:	89 e5                	mov    %esp,%ebp
  801727:	56                   	push   %esi
  801728:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801729:	83 ec 08             	sub    $0x8,%esp
  80172c:	6a 00                	push   $0x0
  80172e:	ff 75 08             	pushl  0x8(%ebp)
  801731:	e8 0c 02 00 00       	call   801942 <open>
  801736:	89 c3                	mov    %eax,%ebx
  801738:	83 c4 10             	add    $0x10,%esp
  80173b:	85 c0                	test   %eax,%eax
  80173d:	78 1b                	js     80175a <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80173f:	83 ec 08             	sub    $0x8,%esp
  801742:	ff 75 0c             	pushl  0xc(%ebp)
  801745:	50                   	push   %eax
  801746:	e8 5b ff ff ff       	call   8016a6 <fstat>
  80174b:	89 c6                	mov    %eax,%esi
	close(fd);
  80174d:	89 1c 24             	mov    %ebx,(%esp)
  801750:	e8 fd fb ff ff       	call   801352 <close>
	return r;
  801755:	83 c4 10             	add    $0x10,%esp
  801758:	89 f0                	mov    %esi,%eax
}
  80175a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80175d:	5b                   	pop    %ebx
  80175e:	5e                   	pop    %esi
  80175f:	5d                   	pop    %ebp
  801760:	c3                   	ret    

00801761 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801761:	55                   	push   %ebp
  801762:	89 e5                	mov    %esp,%ebp
  801764:	56                   	push   %esi
  801765:	53                   	push   %ebx
  801766:	89 c6                	mov    %eax,%esi
  801768:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80176a:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801771:	75 12                	jne    801785 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801773:	83 ec 0c             	sub    $0xc,%esp
  801776:	6a 01                	push   $0x1
  801778:	e8 e2 0c 00 00       	call   80245f <ipc_find_env>
  80177d:	a3 00 40 80 00       	mov    %eax,0x804000
  801782:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801785:	6a 07                	push   $0x7
  801787:	68 00 50 80 00       	push   $0x805000
  80178c:	56                   	push   %esi
  80178d:	ff 35 00 40 80 00    	pushl  0x804000
  801793:	e8 73 0c 00 00       	call   80240b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801798:	83 c4 0c             	add    $0xc,%esp
  80179b:	6a 00                	push   $0x0
  80179d:	53                   	push   %ebx
  80179e:	6a 00                	push   $0x0
  8017a0:	e8 fd 0b 00 00       	call   8023a2 <ipc_recv>
}
  8017a5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017a8:	5b                   	pop    %ebx
  8017a9:	5e                   	pop    %esi
  8017aa:	5d                   	pop    %ebp
  8017ab:	c3                   	ret    

008017ac <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017ac:	55                   	push   %ebp
  8017ad:	89 e5                	mov    %esp,%ebp
  8017af:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b5:	8b 40 0c             	mov    0xc(%eax),%eax
  8017b8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017c0:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ca:	b8 02 00 00 00       	mov    $0x2,%eax
  8017cf:	e8 8d ff ff ff       	call   801761 <fsipc>
}
  8017d4:	c9                   	leave  
  8017d5:	c3                   	ret    

008017d6 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017d6:	55                   	push   %ebp
  8017d7:	89 e5                	mov    %esp,%ebp
  8017d9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8017df:	8b 40 0c             	mov    0xc(%eax),%eax
  8017e2:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ec:	b8 06 00 00 00       	mov    $0x6,%eax
  8017f1:	e8 6b ff ff ff       	call   801761 <fsipc>
}
  8017f6:	c9                   	leave  
  8017f7:	c3                   	ret    

008017f8 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017f8:	55                   	push   %ebp
  8017f9:	89 e5                	mov    %esp,%ebp
  8017fb:	53                   	push   %ebx
  8017fc:	83 ec 04             	sub    $0x4,%esp
  8017ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801802:	8b 45 08             	mov    0x8(%ebp),%eax
  801805:	8b 40 0c             	mov    0xc(%eax),%eax
  801808:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80180d:	ba 00 00 00 00       	mov    $0x0,%edx
  801812:	b8 05 00 00 00       	mov    $0x5,%eax
  801817:	e8 45 ff ff ff       	call   801761 <fsipc>
  80181c:	85 c0                	test   %eax,%eax
  80181e:	78 2c                	js     80184c <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801820:	83 ec 08             	sub    $0x8,%esp
  801823:	68 00 50 80 00       	push   $0x805000
  801828:	53                   	push   %ebx
  801829:	e8 c8 f0 ff ff       	call   8008f6 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80182e:	a1 80 50 80 00       	mov    0x805080,%eax
  801833:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801839:	a1 84 50 80 00       	mov    0x805084,%eax
  80183e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801844:	83 c4 10             	add    $0x10,%esp
  801847:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80184c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80184f:	c9                   	leave  
  801850:	c3                   	ret    

00801851 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801851:	55                   	push   %ebp
  801852:	89 e5                	mov    %esp,%ebp
  801854:	53                   	push   %ebx
  801855:	83 ec 08             	sub    $0x8,%esp
  801858:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80185b:	8b 55 08             	mov    0x8(%ebp),%edx
  80185e:	8b 52 0c             	mov    0xc(%edx),%edx
  801861:	89 15 00 50 80 00    	mov    %edx,0x805000
  801867:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80186c:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  801871:	0f 46 d8             	cmovbe %eax,%ebx
	
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  801874:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  80187a:	53                   	push   %ebx
  80187b:	ff 75 0c             	pushl  0xc(%ebp)
  80187e:	68 08 50 80 00       	push   $0x805008
  801883:	e8 00 f2 ff ff       	call   800a88 <memmove>

	
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) 
  801888:	ba 00 00 00 00       	mov    $0x0,%edx
  80188d:	b8 04 00 00 00       	mov    $0x4,%eax
  801892:	e8 ca fe ff ff       	call   801761 <fsipc>
  801897:	83 c4 10             	add    $0x10,%esp
  80189a:	85 c0                	test   %eax,%eax
  80189c:	78 1d                	js     8018bb <devfile_write+0x6a>
		return r;
	assert(r <= n_real); 
  80189e:	39 d8                	cmp    %ebx,%eax
  8018a0:	76 19                	jbe    8018bb <devfile_write+0x6a>
  8018a2:	68 a0 2c 80 00       	push   $0x802ca0
  8018a7:	68 ac 2c 80 00       	push   $0x802cac
  8018ac:	68 a3 00 00 00       	push   $0xa3
  8018b1:	68 c1 2c 80 00       	push   $0x802cc1
  8018b6:	e8 dd e9 ff ff       	call   800298 <_panic>
	return r;
}
  8018bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018be:	c9                   	leave  
  8018bf:	c3                   	ret    

008018c0 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018c0:	55                   	push   %ebp
  8018c1:	89 e5                	mov    %esp,%ebp
  8018c3:	56                   	push   %esi
  8018c4:	53                   	push   %ebx
  8018c5:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8018cb:	8b 40 0c             	mov    0xc(%eax),%eax
  8018ce:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018d3:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8018de:	b8 03 00 00 00       	mov    $0x3,%eax
  8018e3:	e8 79 fe ff ff       	call   801761 <fsipc>
  8018e8:	89 c3                	mov    %eax,%ebx
  8018ea:	85 c0                	test   %eax,%eax
  8018ec:	78 4b                	js     801939 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018ee:	39 c6                	cmp    %eax,%esi
  8018f0:	73 16                	jae    801908 <devfile_read+0x48>
  8018f2:	68 cc 2c 80 00       	push   $0x802ccc
  8018f7:	68 ac 2c 80 00       	push   $0x802cac
  8018fc:	6a 7c                	push   $0x7c
  8018fe:	68 c1 2c 80 00       	push   $0x802cc1
  801903:	e8 90 e9 ff ff       	call   800298 <_panic>
	assert(r <= PGSIZE);
  801908:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80190d:	7e 16                	jle    801925 <devfile_read+0x65>
  80190f:	68 d3 2c 80 00       	push   $0x802cd3
  801914:	68 ac 2c 80 00       	push   $0x802cac
  801919:	6a 7d                	push   $0x7d
  80191b:	68 c1 2c 80 00       	push   $0x802cc1
  801920:	e8 73 e9 ff ff       	call   800298 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801925:	83 ec 04             	sub    $0x4,%esp
  801928:	50                   	push   %eax
  801929:	68 00 50 80 00       	push   $0x805000
  80192e:	ff 75 0c             	pushl  0xc(%ebp)
  801931:	e8 52 f1 ff ff       	call   800a88 <memmove>
	return r;
  801936:	83 c4 10             	add    $0x10,%esp
}
  801939:	89 d8                	mov    %ebx,%eax
  80193b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80193e:	5b                   	pop    %ebx
  80193f:	5e                   	pop    %esi
  801940:	5d                   	pop    %ebp
  801941:	c3                   	ret    

00801942 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801942:	55                   	push   %ebp
  801943:	89 e5                	mov    %esp,%ebp
  801945:	53                   	push   %ebx
  801946:	83 ec 20             	sub    $0x20,%esp
  801949:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80194c:	53                   	push   %ebx
  80194d:	e8 6b ef ff ff       	call   8008bd <strlen>
  801952:	83 c4 10             	add    $0x10,%esp
  801955:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80195a:	7f 67                	jg     8019c3 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80195c:	83 ec 0c             	sub    $0xc,%esp
  80195f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801962:	50                   	push   %eax
  801963:	e8 71 f8 ff ff       	call   8011d9 <fd_alloc>
  801968:	83 c4 10             	add    $0x10,%esp
		return r;
  80196b:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80196d:	85 c0                	test   %eax,%eax
  80196f:	78 57                	js     8019c8 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801971:	83 ec 08             	sub    $0x8,%esp
  801974:	53                   	push   %ebx
  801975:	68 00 50 80 00       	push   $0x805000
  80197a:	e8 77 ef ff ff       	call   8008f6 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80197f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801982:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801987:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80198a:	b8 01 00 00 00       	mov    $0x1,%eax
  80198f:	e8 cd fd ff ff       	call   801761 <fsipc>
  801994:	89 c3                	mov    %eax,%ebx
  801996:	83 c4 10             	add    $0x10,%esp
  801999:	85 c0                	test   %eax,%eax
  80199b:	79 14                	jns    8019b1 <open+0x6f>
		fd_close(fd, 0);
  80199d:	83 ec 08             	sub    $0x8,%esp
  8019a0:	6a 00                	push   $0x0
  8019a2:	ff 75 f4             	pushl  -0xc(%ebp)
  8019a5:	e8 27 f9 ff ff       	call   8012d1 <fd_close>
		return r;
  8019aa:	83 c4 10             	add    $0x10,%esp
  8019ad:	89 da                	mov    %ebx,%edx
  8019af:	eb 17                	jmp    8019c8 <open+0x86>
	}

	return fd2num(fd);
  8019b1:	83 ec 0c             	sub    $0xc,%esp
  8019b4:	ff 75 f4             	pushl  -0xc(%ebp)
  8019b7:	e8 f6 f7 ff ff       	call   8011b2 <fd2num>
  8019bc:	89 c2                	mov    %eax,%edx
  8019be:	83 c4 10             	add    $0x10,%esp
  8019c1:	eb 05                	jmp    8019c8 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019c3:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019c8:	89 d0                	mov    %edx,%eax
  8019ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019cd:	c9                   	leave  
  8019ce:	c3                   	ret    

008019cf <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019cf:	55                   	push   %ebp
  8019d0:	89 e5                	mov    %esp,%ebp
  8019d2:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8019da:	b8 08 00 00 00       	mov    $0x8,%eax
  8019df:	e8 7d fd ff ff       	call   801761 <fsipc>
}
  8019e4:	c9                   	leave  
  8019e5:	c3                   	ret    

008019e6 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8019e6:	55                   	push   %ebp
  8019e7:	89 e5                	mov    %esp,%ebp
  8019e9:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8019ec:	68 df 2c 80 00       	push   $0x802cdf
  8019f1:	ff 75 0c             	pushl  0xc(%ebp)
  8019f4:	e8 fd ee ff ff       	call   8008f6 <strcpy>
	return 0;
}
  8019f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8019fe:	c9                   	leave  
  8019ff:	c3                   	ret    

00801a00 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801a00:	55                   	push   %ebp
  801a01:	89 e5                	mov    %esp,%ebp
  801a03:	53                   	push   %ebx
  801a04:	83 ec 10             	sub    $0x10,%esp
  801a07:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801a0a:	53                   	push   %ebx
  801a0b:	e8 88 0a 00 00       	call   802498 <pageref>
  801a10:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801a13:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801a18:	83 f8 01             	cmp    $0x1,%eax
  801a1b:	75 10                	jne    801a2d <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801a1d:	83 ec 0c             	sub    $0xc,%esp
  801a20:	ff 73 0c             	pushl  0xc(%ebx)
  801a23:	e8 c0 02 00 00       	call   801ce8 <nsipc_close>
  801a28:	89 c2                	mov    %eax,%edx
  801a2a:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801a2d:	89 d0                	mov    %edx,%eax
  801a2f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a32:	c9                   	leave  
  801a33:	c3                   	ret    

00801a34 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801a34:	55                   	push   %ebp
  801a35:	89 e5                	mov    %esp,%ebp
  801a37:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801a3a:	6a 00                	push   $0x0
  801a3c:	ff 75 10             	pushl  0x10(%ebp)
  801a3f:	ff 75 0c             	pushl  0xc(%ebp)
  801a42:	8b 45 08             	mov    0x8(%ebp),%eax
  801a45:	ff 70 0c             	pushl  0xc(%eax)
  801a48:	e8 78 03 00 00       	call   801dc5 <nsipc_send>
}
  801a4d:	c9                   	leave  
  801a4e:	c3                   	ret    

00801a4f <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801a4f:	55                   	push   %ebp
  801a50:	89 e5                	mov    %esp,%ebp
  801a52:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801a55:	6a 00                	push   $0x0
  801a57:	ff 75 10             	pushl  0x10(%ebp)
  801a5a:	ff 75 0c             	pushl  0xc(%ebp)
  801a5d:	8b 45 08             	mov    0x8(%ebp),%eax
  801a60:	ff 70 0c             	pushl  0xc(%eax)
  801a63:	e8 f1 02 00 00       	call   801d59 <nsipc_recv>
}
  801a68:	c9                   	leave  
  801a69:	c3                   	ret    

00801a6a <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801a6a:	55                   	push   %ebp
  801a6b:	89 e5                	mov    %esp,%ebp
  801a6d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801a70:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801a73:	52                   	push   %edx
  801a74:	50                   	push   %eax
  801a75:	e8 ae f7 ff ff       	call   801228 <fd_lookup>
  801a7a:	83 c4 10             	add    $0x10,%esp
  801a7d:	85 c0                	test   %eax,%eax
  801a7f:	78 17                	js     801a98 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801a81:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a84:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801a8a:	39 08                	cmp    %ecx,(%eax)
  801a8c:	75 05                	jne    801a93 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801a8e:	8b 40 0c             	mov    0xc(%eax),%eax
  801a91:	eb 05                	jmp    801a98 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801a93:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801a98:	c9                   	leave  
  801a99:	c3                   	ret    

00801a9a <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801a9a:	55                   	push   %ebp
  801a9b:	89 e5                	mov    %esp,%ebp
  801a9d:	56                   	push   %esi
  801a9e:	53                   	push   %ebx
  801a9f:	83 ec 1c             	sub    $0x1c,%esp
  801aa2:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801aa4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aa7:	50                   	push   %eax
  801aa8:	e8 2c f7 ff ff       	call   8011d9 <fd_alloc>
  801aad:	89 c3                	mov    %eax,%ebx
  801aaf:	83 c4 10             	add    $0x10,%esp
  801ab2:	85 c0                	test   %eax,%eax
  801ab4:	78 1b                	js     801ad1 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801ab6:	83 ec 04             	sub    $0x4,%esp
  801ab9:	68 07 04 00 00       	push   $0x407
  801abe:	ff 75 f4             	pushl  -0xc(%ebp)
  801ac1:	6a 00                	push   $0x0
  801ac3:	e8 31 f2 ff ff       	call   800cf9 <sys_page_alloc>
  801ac8:	89 c3                	mov    %eax,%ebx
  801aca:	83 c4 10             	add    $0x10,%esp
  801acd:	85 c0                	test   %eax,%eax
  801acf:	79 10                	jns    801ae1 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801ad1:	83 ec 0c             	sub    $0xc,%esp
  801ad4:	56                   	push   %esi
  801ad5:	e8 0e 02 00 00       	call   801ce8 <nsipc_close>
		return r;
  801ada:	83 c4 10             	add    $0x10,%esp
  801add:	89 d8                	mov    %ebx,%eax
  801adf:	eb 24                	jmp    801b05 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801ae1:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ae7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aea:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801aec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aef:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801af6:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801af9:	83 ec 0c             	sub    $0xc,%esp
  801afc:	50                   	push   %eax
  801afd:	e8 b0 f6 ff ff       	call   8011b2 <fd2num>
  801b02:	83 c4 10             	add    $0x10,%esp
}
  801b05:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b08:	5b                   	pop    %ebx
  801b09:	5e                   	pop    %esi
  801b0a:	5d                   	pop    %ebp
  801b0b:	c3                   	ret    

00801b0c <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801b0c:	55                   	push   %ebp
  801b0d:	89 e5                	mov    %esp,%ebp
  801b0f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b12:	8b 45 08             	mov    0x8(%ebp),%eax
  801b15:	e8 50 ff ff ff       	call   801a6a <fd2sockid>
		return r;
  801b1a:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b1c:	85 c0                	test   %eax,%eax
  801b1e:	78 1f                	js     801b3f <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b20:	83 ec 04             	sub    $0x4,%esp
  801b23:	ff 75 10             	pushl  0x10(%ebp)
  801b26:	ff 75 0c             	pushl  0xc(%ebp)
  801b29:	50                   	push   %eax
  801b2a:	e8 12 01 00 00       	call   801c41 <nsipc_accept>
  801b2f:	83 c4 10             	add    $0x10,%esp
		return r;
  801b32:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b34:	85 c0                	test   %eax,%eax
  801b36:	78 07                	js     801b3f <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801b38:	e8 5d ff ff ff       	call   801a9a <alloc_sockfd>
  801b3d:	89 c1                	mov    %eax,%ecx
}
  801b3f:	89 c8                	mov    %ecx,%eax
  801b41:	c9                   	leave  
  801b42:	c3                   	ret    

00801b43 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801b43:	55                   	push   %ebp
  801b44:	89 e5                	mov    %esp,%ebp
  801b46:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b49:	8b 45 08             	mov    0x8(%ebp),%eax
  801b4c:	e8 19 ff ff ff       	call   801a6a <fd2sockid>
  801b51:	85 c0                	test   %eax,%eax
  801b53:	78 12                	js     801b67 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801b55:	83 ec 04             	sub    $0x4,%esp
  801b58:	ff 75 10             	pushl  0x10(%ebp)
  801b5b:	ff 75 0c             	pushl  0xc(%ebp)
  801b5e:	50                   	push   %eax
  801b5f:	e8 2d 01 00 00       	call   801c91 <nsipc_bind>
  801b64:	83 c4 10             	add    $0x10,%esp
}
  801b67:	c9                   	leave  
  801b68:	c3                   	ret    

00801b69 <shutdown>:

int
shutdown(int s, int how)
{
  801b69:	55                   	push   %ebp
  801b6a:	89 e5                	mov    %esp,%ebp
  801b6c:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b6f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b72:	e8 f3 fe ff ff       	call   801a6a <fd2sockid>
  801b77:	85 c0                	test   %eax,%eax
  801b79:	78 0f                	js     801b8a <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801b7b:	83 ec 08             	sub    $0x8,%esp
  801b7e:	ff 75 0c             	pushl  0xc(%ebp)
  801b81:	50                   	push   %eax
  801b82:	e8 3f 01 00 00       	call   801cc6 <nsipc_shutdown>
  801b87:	83 c4 10             	add    $0x10,%esp
}
  801b8a:	c9                   	leave  
  801b8b:	c3                   	ret    

00801b8c <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801b8c:	55                   	push   %ebp
  801b8d:	89 e5                	mov    %esp,%ebp
  801b8f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b92:	8b 45 08             	mov    0x8(%ebp),%eax
  801b95:	e8 d0 fe ff ff       	call   801a6a <fd2sockid>
  801b9a:	85 c0                	test   %eax,%eax
  801b9c:	78 12                	js     801bb0 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801b9e:	83 ec 04             	sub    $0x4,%esp
  801ba1:	ff 75 10             	pushl  0x10(%ebp)
  801ba4:	ff 75 0c             	pushl  0xc(%ebp)
  801ba7:	50                   	push   %eax
  801ba8:	e8 55 01 00 00       	call   801d02 <nsipc_connect>
  801bad:	83 c4 10             	add    $0x10,%esp
}
  801bb0:	c9                   	leave  
  801bb1:	c3                   	ret    

00801bb2 <listen>:

int
listen(int s, int backlog)
{
  801bb2:	55                   	push   %ebp
  801bb3:	89 e5                	mov    %esp,%ebp
  801bb5:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bb8:	8b 45 08             	mov    0x8(%ebp),%eax
  801bbb:	e8 aa fe ff ff       	call   801a6a <fd2sockid>
  801bc0:	85 c0                	test   %eax,%eax
  801bc2:	78 0f                	js     801bd3 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801bc4:	83 ec 08             	sub    $0x8,%esp
  801bc7:	ff 75 0c             	pushl  0xc(%ebp)
  801bca:	50                   	push   %eax
  801bcb:	e8 67 01 00 00       	call   801d37 <nsipc_listen>
  801bd0:	83 c4 10             	add    $0x10,%esp
}
  801bd3:	c9                   	leave  
  801bd4:	c3                   	ret    

00801bd5 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801bd5:	55                   	push   %ebp
  801bd6:	89 e5                	mov    %esp,%ebp
  801bd8:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801bdb:	ff 75 10             	pushl  0x10(%ebp)
  801bde:	ff 75 0c             	pushl  0xc(%ebp)
  801be1:	ff 75 08             	pushl  0x8(%ebp)
  801be4:	e8 3a 02 00 00       	call   801e23 <nsipc_socket>
  801be9:	83 c4 10             	add    $0x10,%esp
  801bec:	85 c0                	test   %eax,%eax
  801bee:	78 05                	js     801bf5 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801bf0:	e8 a5 fe ff ff       	call   801a9a <alloc_sockfd>
}
  801bf5:	c9                   	leave  
  801bf6:	c3                   	ret    

00801bf7 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801bf7:	55                   	push   %ebp
  801bf8:	89 e5                	mov    %esp,%ebp
  801bfa:	53                   	push   %ebx
  801bfb:	83 ec 04             	sub    $0x4,%esp
  801bfe:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801c00:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801c07:	75 12                	jne    801c1b <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801c09:	83 ec 0c             	sub    $0xc,%esp
  801c0c:	6a 02                	push   $0x2
  801c0e:	e8 4c 08 00 00       	call   80245f <ipc_find_env>
  801c13:	a3 04 40 80 00       	mov    %eax,0x804004
  801c18:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801c1b:	6a 07                	push   $0x7
  801c1d:	68 00 60 80 00       	push   $0x806000
  801c22:	53                   	push   %ebx
  801c23:	ff 35 04 40 80 00    	pushl  0x804004
  801c29:	e8 dd 07 00 00       	call   80240b <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801c2e:	83 c4 0c             	add    $0xc,%esp
  801c31:	6a 00                	push   $0x0
  801c33:	6a 00                	push   $0x0
  801c35:	6a 00                	push   $0x0
  801c37:	e8 66 07 00 00       	call   8023a2 <ipc_recv>
}
  801c3c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c3f:	c9                   	leave  
  801c40:	c3                   	ret    

00801c41 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c41:	55                   	push   %ebp
  801c42:	89 e5                	mov    %esp,%ebp
  801c44:	56                   	push   %esi
  801c45:	53                   	push   %ebx
  801c46:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801c49:	8b 45 08             	mov    0x8(%ebp),%eax
  801c4c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801c51:	8b 06                	mov    (%esi),%eax
  801c53:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801c58:	b8 01 00 00 00       	mov    $0x1,%eax
  801c5d:	e8 95 ff ff ff       	call   801bf7 <nsipc>
  801c62:	89 c3                	mov    %eax,%ebx
  801c64:	85 c0                	test   %eax,%eax
  801c66:	78 20                	js     801c88 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801c68:	83 ec 04             	sub    $0x4,%esp
  801c6b:	ff 35 10 60 80 00    	pushl  0x806010
  801c71:	68 00 60 80 00       	push   $0x806000
  801c76:	ff 75 0c             	pushl  0xc(%ebp)
  801c79:	e8 0a ee ff ff       	call   800a88 <memmove>
		*addrlen = ret->ret_addrlen;
  801c7e:	a1 10 60 80 00       	mov    0x806010,%eax
  801c83:	89 06                	mov    %eax,(%esi)
  801c85:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801c88:	89 d8                	mov    %ebx,%eax
  801c8a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c8d:	5b                   	pop    %ebx
  801c8e:	5e                   	pop    %esi
  801c8f:	5d                   	pop    %ebp
  801c90:	c3                   	ret    

00801c91 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c91:	55                   	push   %ebp
  801c92:	89 e5                	mov    %esp,%ebp
  801c94:	53                   	push   %ebx
  801c95:	83 ec 08             	sub    $0x8,%esp
  801c98:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801c9b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c9e:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801ca3:	53                   	push   %ebx
  801ca4:	ff 75 0c             	pushl  0xc(%ebp)
  801ca7:	68 04 60 80 00       	push   $0x806004
  801cac:	e8 d7 ed ff ff       	call   800a88 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801cb1:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801cb7:	b8 02 00 00 00       	mov    $0x2,%eax
  801cbc:	e8 36 ff ff ff       	call   801bf7 <nsipc>
}
  801cc1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cc4:	c9                   	leave  
  801cc5:	c3                   	ret    

00801cc6 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801cc6:	55                   	push   %ebp
  801cc7:	89 e5                	mov    %esp,%ebp
  801cc9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801ccc:	8b 45 08             	mov    0x8(%ebp),%eax
  801ccf:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801cd4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cd7:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801cdc:	b8 03 00 00 00       	mov    $0x3,%eax
  801ce1:	e8 11 ff ff ff       	call   801bf7 <nsipc>
}
  801ce6:	c9                   	leave  
  801ce7:	c3                   	ret    

00801ce8 <nsipc_close>:

int
nsipc_close(int s)
{
  801ce8:	55                   	push   %ebp
  801ce9:	89 e5                	mov    %esp,%ebp
  801ceb:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801cee:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf1:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801cf6:	b8 04 00 00 00       	mov    $0x4,%eax
  801cfb:	e8 f7 fe ff ff       	call   801bf7 <nsipc>
}
  801d00:	c9                   	leave  
  801d01:	c3                   	ret    

00801d02 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801d02:	55                   	push   %ebp
  801d03:	89 e5                	mov    %esp,%ebp
  801d05:	53                   	push   %ebx
  801d06:	83 ec 08             	sub    $0x8,%esp
  801d09:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801d0c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d0f:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801d14:	53                   	push   %ebx
  801d15:	ff 75 0c             	pushl  0xc(%ebp)
  801d18:	68 04 60 80 00       	push   $0x806004
  801d1d:	e8 66 ed ff ff       	call   800a88 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801d22:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801d28:	b8 05 00 00 00       	mov    $0x5,%eax
  801d2d:	e8 c5 fe ff ff       	call   801bf7 <nsipc>
}
  801d32:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d35:	c9                   	leave  
  801d36:	c3                   	ret    

00801d37 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801d37:	55                   	push   %ebp
  801d38:	89 e5                	mov    %esp,%ebp
  801d3a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801d3d:	8b 45 08             	mov    0x8(%ebp),%eax
  801d40:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801d45:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d48:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801d4d:	b8 06 00 00 00       	mov    $0x6,%eax
  801d52:	e8 a0 fe ff ff       	call   801bf7 <nsipc>
}
  801d57:	c9                   	leave  
  801d58:	c3                   	ret    

00801d59 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801d59:	55                   	push   %ebp
  801d5a:	89 e5                	mov    %esp,%ebp
  801d5c:	56                   	push   %esi
  801d5d:	53                   	push   %ebx
  801d5e:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801d61:	8b 45 08             	mov    0x8(%ebp),%eax
  801d64:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801d69:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801d6f:	8b 45 14             	mov    0x14(%ebp),%eax
  801d72:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801d77:	b8 07 00 00 00       	mov    $0x7,%eax
  801d7c:	e8 76 fe ff ff       	call   801bf7 <nsipc>
  801d81:	89 c3                	mov    %eax,%ebx
  801d83:	85 c0                	test   %eax,%eax
  801d85:	78 35                	js     801dbc <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801d87:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801d8c:	7f 04                	jg     801d92 <nsipc_recv+0x39>
  801d8e:	39 c6                	cmp    %eax,%esi
  801d90:	7d 16                	jge    801da8 <nsipc_recv+0x4f>
  801d92:	68 eb 2c 80 00       	push   $0x802ceb
  801d97:	68 ac 2c 80 00       	push   $0x802cac
  801d9c:	6a 62                	push   $0x62
  801d9e:	68 00 2d 80 00       	push   $0x802d00
  801da3:	e8 f0 e4 ff ff       	call   800298 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801da8:	83 ec 04             	sub    $0x4,%esp
  801dab:	50                   	push   %eax
  801dac:	68 00 60 80 00       	push   $0x806000
  801db1:	ff 75 0c             	pushl  0xc(%ebp)
  801db4:	e8 cf ec ff ff       	call   800a88 <memmove>
  801db9:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801dbc:	89 d8                	mov    %ebx,%eax
  801dbe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dc1:	5b                   	pop    %ebx
  801dc2:	5e                   	pop    %esi
  801dc3:	5d                   	pop    %ebp
  801dc4:	c3                   	ret    

00801dc5 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801dc5:	55                   	push   %ebp
  801dc6:	89 e5                	mov    %esp,%ebp
  801dc8:	53                   	push   %ebx
  801dc9:	83 ec 04             	sub    $0x4,%esp
  801dcc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801dcf:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd2:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801dd7:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801ddd:	7e 16                	jle    801df5 <nsipc_send+0x30>
  801ddf:	68 0c 2d 80 00       	push   $0x802d0c
  801de4:	68 ac 2c 80 00       	push   $0x802cac
  801de9:	6a 6d                	push   $0x6d
  801deb:	68 00 2d 80 00       	push   $0x802d00
  801df0:	e8 a3 e4 ff ff       	call   800298 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801df5:	83 ec 04             	sub    $0x4,%esp
  801df8:	53                   	push   %ebx
  801df9:	ff 75 0c             	pushl  0xc(%ebp)
  801dfc:	68 0c 60 80 00       	push   $0x80600c
  801e01:	e8 82 ec ff ff       	call   800a88 <memmove>
	nsipcbuf.send.req_size = size;
  801e06:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801e0c:	8b 45 14             	mov    0x14(%ebp),%eax
  801e0f:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801e14:	b8 08 00 00 00       	mov    $0x8,%eax
  801e19:	e8 d9 fd ff ff       	call   801bf7 <nsipc>
}
  801e1e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e21:	c9                   	leave  
  801e22:	c3                   	ret    

00801e23 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801e23:	55                   	push   %ebp
  801e24:	89 e5                	mov    %esp,%ebp
  801e26:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801e29:	8b 45 08             	mov    0x8(%ebp),%eax
  801e2c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801e31:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e34:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801e39:	8b 45 10             	mov    0x10(%ebp),%eax
  801e3c:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801e41:	b8 09 00 00 00       	mov    $0x9,%eax
  801e46:	e8 ac fd ff ff       	call   801bf7 <nsipc>
}
  801e4b:	c9                   	leave  
  801e4c:	c3                   	ret    

00801e4d <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e4d:	55                   	push   %ebp
  801e4e:	89 e5                	mov    %esp,%ebp
  801e50:	56                   	push   %esi
  801e51:	53                   	push   %ebx
  801e52:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e55:	83 ec 0c             	sub    $0xc,%esp
  801e58:	ff 75 08             	pushl  0x8(%ebp)
  801e5b:	e8 62 f3 ff ff       	call   8011c2 <fd2data>
  801e60:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801e62:	83 c4 08             	add    $0x8,%esp
  801e65:	68 18 2d 80 00       	push   $0x802d18
  801e6a:	53                   	push   %ebx
  801e6b:	e8 86 ea ff ff       	call   8008f6 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e70:	8b 46 04             	mov    0x4(%esi),%eax
  801e73:	2b 06                	sub    (%esi),%eax
  801e75:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801e7b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801e82:	00 00 00 
	stat->st_dev = &devpipe;
  801e85:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801e8c:	30 80 00 
	return 0;
}
  801e8f:	b8 00 00 00 00       	mov    $0x0,%eax
  801e94:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e97:	5b                   	pop    %ebx
  801e98:	5e                   	pop    %esi
  801e99:	5d                   	pop    %ebp
  801e9a:	c3                   	ret    

00801e9b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801e9b:	55                   	push   %ebp
  801e9c:	89 e5                	mov    %esp,%ebp
  801e9e:	53                   	push   %ebx
  801e9f:	83 ec 0c             	sub    $0xc,%esp
  801ea2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ea5:	53                   	push   %ebx
  801ea6:	6a 00                	push   $0x0
  801ea8:	e8 d1 ee ff ff       	call   800d7e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ead:	89 1c 24             	mov    %ebx,(%esp)
  801eb0:	e8 0d f3 ff ff       	call   8011c2 <fd2data>
  801eb5:	83 c4 08             	add    $0x8,%esp
  801eb8:	50                   	push   %eax
  801eb9:	6a 00                	push   $0x0
  801ebb:	e8 be ee ff ff       	call   800d7e <sys_page_unmap>
}
  801ec0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ec3:	c9                   	leave  
  801ec4:	c3                   	ret    

00801ec5 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801ec5:	55                   	push   %ebp
  801ec6:	89 e5                	mov    %esp,%ebp
  801ec8:	57                   	push   %edi
  801ec9:	56                   	push   %esi
  801eca:	53                   	push   %ebx
  801ecb:	83 ec 1c             	sub    $0x1c,%esp
  801ece:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ed1:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ed3:	a1 08 40 80 00       	mov    0x804008,%eax
  801ed8:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801edb:	83 ec 0c             	sub    $0xc,%esp
  801ede:	ff 75 e0             	pushl  -0x20(%ebp)
  801ee1:	e8 b2 05 00 00       	call   802498 <pageref>
  801ee6:	89 c3                	mov    %eax,%ebx
  801ee8:	89 3c 24             	mov    %edi,(%esp)
  801eeb:	e8 a8 05 00 00       	call   802498 <pageref>
  801ef0:	83 c4 10             	add    $0x10,%esp
  801ef3:	39 c3                	cmp    %eax,%ebx
  801ef5:	0f 94 c1             	sete   %cl
  801ef8:	0f b6 c9             	movzbl %cl,%ecx
  801efb:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801efe:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801f04:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801f07:	39 ce                	cmp    %ecx,%esi
  801f09:	74 1b                	je     801f26 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801f0b:	39 c3                	cmp    %eax,%ebx
  801f0d:	75 c4                	jne    801ed3 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801f0f:	8b 42 58             	mov    0x58(%edx),%eax
  801f12:	ff 75 e4             	pushl  -0x1c(%ebp)
  801f15:	50                   	push   %eax
  801f16:	56                   	push   %esi
  801f17:	68 1f 2d 80 00       	push   $0x802d1f
  801f1c:	e8 50 e4 ff ff       	call   800371 <cprintf>
  801f21:	83 c4 10             	add    $0x10,%esp
  801f24:	eb ad                	jmp    801ed3 <_pipeisclosed+0xe>
	}
}
  801f26:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f29:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f2c:	5b                   	pop    %ebx
  801f2d:	5e                   	pop    %esi
  801f2e:	5f                   	pop    %edi
  801f2f:	5d                   	pop    %ebp
  801f30:	c3                   	ret    

00801f31 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f31:	55                   	push   %ebp
  801f32:	89 e5                	mov    %esp,%ebp
  801f34:	57                   	push   %edi
  801f35:	56                   	push   %esi
  801f36:	53                   	push   %ebx
  801f37:	83 ec 28             	sub    $0x28,%esp
  801f3a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801f3d:	56                   	push   %esi
  801f3e:	e8 7f f2 ff ff       	call   8011c2 <fd2data>
  801f43:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f45:	83 c4 10             	add    $0x10,%esp
  801f48:	bf 00 00 00 00       	mov    $0x0,%edi
  801f4d:	eb 4b                	jmp    801f9a <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801f4f:	89 da                	mov    %ebx,%edx
  801f51:	89 f0                	mov    %esi,%eax
  801f53:	e8 6d ff ff ff       	call   801ec5 <_pipeisclosed>
  801f58:	85 c0                	test   %eax,%eax
  801f5a:	75 48                	jne    801fa4 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801f5c:	e8 79 ed ff ff       	call   800cda <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f61:	8b 43 04             	mov    0x4(%ebx),%eax
  801f64:	8b 0b                	mov    (%ebx),%ecx
  801f66:	8d 51 20             	lea    0x20(%ecx),%edx
  801f69:	39 d0                	cmp    %edx,%eax
  801f6b:	73 e2                	jae    801f4f <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f70:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801f74:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801f77:	89 c2                	mov    %eax,%edx
  801f79:	c1 fa 1f             	sar    $0x1f,%edx
  801f7c:	89 d1                	mov    %edx,%ecx
  801f7e:	c1 e9 1b             	shr    $0x1b,%ecx
  801f81:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801f84:	83 e2 1f             	and    $0x1f,%edx
  801f87:	29 ca                	sub    %ecx,%edx
  801f89:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801f8d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801f91:	83 c0 01             	add    $0x1,%eax
  801f94:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f97:	83 c7 01             	add    $0x1,%edi
  801f9a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801f9d:	75 c2                	jne    801f61 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801f9f:	8b 45 10             	mov    0x10(%ebp),%eax
  801fa2:	eb 05                	jmp    801fa9 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801fa4:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801fa9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fac:	5b                   	pop    %ebx
  801fad:	5e                   	pop    %esi
  801fae:	5f                   	pop    %edi
  801faf:	5d                   	pop    %ebp
  801fb0:	c3                   	ret    

00801fb1 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801fb1:	55                   	push   %ebp
  801fb2:	89 e5                	mov    %esp,%ebp
  801fb4:	57                   	push   %edi
  801fb5:	56                   	push   %esi
  801fb6:	53                   	push   %ebx
  801fb7:	83 ec 18             	sub    $0x18,%esp
  801fba:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801fbd:	57                   	push   %edi
  801fbe:	e8 ff f1 ff ff       	call   8011c2 <fd2data>
  801fc3:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fc5:	83 c4 10             	add    $0x10,%esp
  801fc8:	bb 00 00 00 00       	mov    $0x0,%ebx
  801fcd:	eb 3d                	jmp    80200c <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801fcf:	85 db                	test   %ebx,%ebx
  801fd1:	74 04                	je     801fd7 <devpipe_read+0x26>
				return i;
  801fd3:	89 d8                	mov    %ebx,%eax
  801fd5:	eb 44                	jmp    80201b <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801fd7:	89 f2                	mov    %esi,%edx
  801fd9:	89 f8                	mov    %edi,%eax
  801fdb:	e8 e5 fe ff ff       	call   801ec5 <_pipeisclosed>
  801fe0:	85 c0                	test   %eax,%eax
  801fe2:	75 32                	jne    802016 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801fe4:	e8 f1 ec ff ff       	call   800cda <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801fe9:	8b 06                	mov    (%esi),%eax
  801feb:	3b 46 04             	cmp    0x4(%esi),%eax
  801fee:	74 df                	je     801fcf <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801ff0:	99                   	cltd   
  801ff1:	c1 ea 1b             	shr    $0x1b,%edx
  801ff4:	01 d0                	add    %edx,%eax
  801ff6:	83 e0 1f             	and    $0x1f,%eax
  801ff9:	29 d0                	sub    %edx,%eax
  801ffb:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802000:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802003:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802006:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802009:	83 c3 01             	add    $0x1,%ebx
  80200c:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80200f:	75 d8                	jne    801fe9 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802011:	8b 45 10             	mov    0x10(%ebp),%eax
  802014:	eb 05                	jmp    80201b <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802016:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80201b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80201e:	5b                   	pop    %ebx
  80201f:	5e                   	pop    %esi
  802020:	5f                   	pop    %edi
  802021:	5d                   	pop    %ebp
  802022:	c3                   	ret    

00802023 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802023:	55                   	push   %ebp
  802024:	89 e5                	mov    %esp,%ebp
  802026:	56                   	push   %esi
  802027:	53                   	push   %ebx
  802028:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80202b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80202e:	50                   	push   %eax
  80202f:	e8 a5 f1 ff ff       	call   8011d9 <fd_alloc>
  802034:	83 c4 10             	add    $0x10,%esp
  802037:	89 c2                	mov    %eax,%edx
  802039:	85 c0                	test   %eax,%eax
  80203b:	0f 88 2c 01 00 00    	js     80216d <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802041:	83 ec 04             	sub    $0x4,%esp
  802044:	68 07 04 00 00       	push   $0x407
  802049:	ff 75 f4             	pushl  -0xc(%ebp)
  80204c:	6a 00                	push   $0x0
  80204e:	e8 a6 ec ff ff       	call   800cf9 <sys_page_alloc>
  802053:	83 c4 10             	add    $0x10,%esp
  802056:	89 c2                	mov    %eax,%edx
  802058:	85 c0                	test   %eax,%eax
  80205a:	0f 88 0d 01 00 00    	js     80216d <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802060:	83 ec 0c             	sub    $0xc,%esp
  802063:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802066:	50                   	push   %eax
  802067:	e8 6d f1 ff ff       	call   8011d9 <fd_alloc>
  80206c:	89 c3                	mov    %eax,%ebx
  80206e:	83 c4 10             	add    $0x10,%esp
  802071:	85 c0                	test   %eax,%eax
  802073:	0f 88 e2 00 00 00    	js     80215b <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802079:	83 ec 04             	sub    $0x4,%esp
  80207c:	68 07 04 00 00       	push   $0x407
  802081:	ff 75 f0             	pushl  -0x10(%ebp)
  802084:	6a 00                	push   $0x0
  802086:	e8 6e ec ff ff       	call   800cf9 <sys_page_alloc>
  80208b:	89 c3                	mov    %eax,%ebx
  80208d:	83 c4 10             	add    $0x10,%esp
  802090:	85 c0                	test   %eax,%eax
  802092:	0f 88 c3 00 00 00    	js     80215b <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802098:	83 ec 0c             	sub    $0xc,%esp
  80209b:	ff 75 f4             	pushl  -0xc(%ebp)
  80209e:	e8 1f f1 ff ff       	call   8011c2 <fd2data>
  8020a3:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020a5:	83 c4 0c             	add    $0xc,%esp
  8020a8:	68 07 04 00 00       	push   $0x407
  8020ad:	50                   	push   %eax
  8020ae:	6a 00                	push   $0x0
  8020b0:	e8 44 ec ff ff       	call   800cf9 <sys_page_alloc>
  8020b5:	89 c3                	mov    %eax,%ebx
  8020b7:	83 c4 10             	add    $0x10,%esp
  8020ba:	85 c0                	test   %eax,%eax
  8020bc:	0f 88 89 00 00 00    	js     80214b <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020c2:	83 ec 0c             	sub    $0xc,%esp
  8020c5:	ff 75 f0             	pushl  -0x10(%ebp)
  8020c8:	e8 f5 f0 ff ff       	call   8011c2 <fd2data>
  8020cd:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8020d4:	50                   	push   %eax
  8020d5:	6a 00                	push   $0x0
  8020d7:	56                   	push   %esi
  8020d8:	6a 00                	push   $0x0
  8020da:	e8 5d ec ff ff       	call   800d3c <sys_page_map>
  8020df:	89 c3                	mov    %eax,%ebx
  8020e1:	83 c4 20             	add    $0x20,%esp
  8020e4:	85 c0                	test   %eax,%eax
  8020e6:	78 55                	js     80213d <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8020e8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020f1:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8020f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020f6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8020fd:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802103:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802106:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802108:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80210b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802112:	83 ec 0c             	sub    $0xc,%esp
  802115:	ff 75 f4             	pushl  -0xc(%ebp)
  802118:	e8 95 f0 ff ff       	call   8011b2 <fd2num>
  80211d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802120:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802122:	83 c4 04             	add    $0x4,%esp
  802125:	ff 75 f0             	pushl  -0x10(%ebp)
  802128:	e8 85 f0 ff ff       	call   8011b2 <fd2num>
  80212d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802130:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802133:	83 c4 10             	add    $0x10,%esp
  802136:	ba 00 00 00 00       	mov    $0x0,%edx
  80213b:	eb 30                	jmp    80216d <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80213d:	83 ec 08             	sub    $0x8,%esp
  802140:	56                   	push   %esi
  802141:	6a 00                	push   $0x0
  802143:	e8 36 ec ff ff       	call   800d7e <sys_page_unmap>
  802148:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80214b:	83 ec 08             	sub    $0x8,%esp
  80214e:	ff 75 f0             	pushl  -0x10(%ebp)
  802151:	6a 00                	push   $0x0
  802153:	e8 26 ec ff ff       	call   800d7e <sys_page_unmap>
  802158:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80215b:	83 ec 08             	sub    $0x8,%esp
  80215e:	ff 75 f4             	pushl  -0xc(%ebp)
  802161:	6a 00                	push   $0x0
  802163:	e8 16 ec ff ff       	call   800d7e <sys_page_unmap>
  802168:	83 c4 10             	add    $0x10,%esp
  80216b:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80216d:	89 d0                	mov    %edx,%eax
  80216f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802172:	5b                   	pop    %ebx
  802173:	5e                   	pop    %esi
  802174:	5d                   	pop    %ebp
  802175:	c3                   	ret    

00802176 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802176:	55                   	push   %ebp
  802177:	89 e5                	mov    %esp,%ebp
  802179:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80217c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80217f:	50                   	push   %eax
  802180:	ff 75 08             	pushl  0x8(%ebp)
  802183:	e8 a0 f0 ff ff       	call   801228 <fd_lookup>
  802188:	83 c4 10             	add    $0x10,%esp
  80218b:	85 c0                	test   %eax,%eax
  80218d:	78 18                	js     8021a7 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80218f:	83 ec 0c             	sub    $0xc,%esp
  802192:	ff 75 f4             	pushl  -0xc(%ebp)
  802195:	e8 28 f0 ff ff       	call   8011c2 <fd2data>
	return _pipeisclosed(fd, p);
  80219a:	89 c2                	mov    %eax,%edx
  80219c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80219f:	e8 21 fd ff ff       	call   801ec5 <_pipeisclosed>
  8021a4:	83 c4 10             	add    $0x10,%esp
}
  8021a7:	c9                   	leave  
  8021a8:	c3                   	ret    

008021a9 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8021a9:	55                   	push   %ebp
  8021aa:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8021ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8021b1:	5d                   	pop    %ebp
  8021b2:	c3                   	ret    

008021b3 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8021b3:	55                   	push   %ebp
  8021b4:	89 e5                	mov    %esp,%ebp
  8021b6:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8021b9:	68 32 2d 80 00       	push   $0x802d32
  8021be:	ff 75 0c             	pushl  0xc(%ebp)
  8021c1:	e8 30 e7 ff ff       	call   8008f6 <strcpy>
	return 0;
}
  8021c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8021cb:	c9                   	leave  
  8021cc:	c3                   	ret    

008021cd <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8021cd:	55                   	push   %ebp
  8021ce:	89 e5                	mov    %esp,%ebp
  8021d0:	57                   	push   %edi
  8021d1:	56                   	push   %esi
  8021d2:	53                   	push   %ebx
  8021d3:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021d9:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8021de:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021e4:	eb 2d                	jmp    802213 <devcons_write+0x46>
		m = n - tot;
  8021e6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8021e9:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8021eb:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8021ee:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8021f3:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8021f6:	83 ec 04             	sub    $0x4,%esp
  8021f9:	53                   	push   %ebx
  8021fa:	03 45 0c             	add    0xc(%ebp),%eax
  8021fd:	50                   	push   %eax
  8021fe:	57                   	push   %edi
  8021ff:	e8 84 e8 ff ff       	call   800a88 <memmove>
		sys_cputs(buf, m);
  802204:	83 c4 08             	add    $0x8,%esp
  802207:	53                   	push   %ebx
  802208:	57                   	push   %edi
  802209:	e8 2f ea ff ff       	call   800c3d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80220e:	01 de                	add    %ebx,%esi
  802210:	83 c4 10             	add    $0x10,%esp
  802213:	89 f0                	mov    %esi,%eax
  802215:	3b 75 10             	cmp    0x10(%ebp),%esi
  802218:	72 cc                	jb     8021e6 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80221a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80221d:	5b                   	pop    %ebx
  80221e:	5e                   	pop    %esi
  80221f:	5f                   	pop    %edi
  802220:	5d                   	pop    %ebp
  802221:	c3                   	ret    

00802222 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802222:	55                   	push   %ebp
  802223:	89 e5                	mov    %esp,%ebp
  802225:	83 ec 08             	sub    $0x8,%esp
  802228:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80222d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802231:	74 2a                	je     80225d <devcons_read+0x3b>
  802233:	eb 05                	jmp    80223a <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802235:	e8 a0 ea ff ff       	call   800cda <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80223a:	e8 1c ea ff ff       	call   800c5b <sys_cgetc>
  80223f:	85 c0                	test   %eax,%eax
  802241:	74 f2                	je     802235 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802243:	85 c0                	test   %eax,%eax
  802245:	78 16                	js     80225d <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802247:	83 f8 04             	cmp    $0x4,%eax
  80224a:	74 0c                	je     802258 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80224c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80224f:	88 02                	mov    %al,(%edx)
	return 1;
  802251:	b8 01 00 00 00       	mov    $0x1,%eax
  802256:	eb 05                	jmp    80225d <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802258:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80225d:	c9                   	leave  
  80225e:	c3                   	ret    

0080225f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80225f:	55                   	push   %ebp
  802260:	89 e5                	mov    %esp,%ebp
  802262:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802265:	8b 45 08             	mov    0x8(%ebp),%eax
  802268:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80226b:	6a 01                	push   $0x1
  80226d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802270:	50                   	push   %eax
  802271:	e8 c7 e9 ff ff       	call   800c3d <sys_cputs>
}
  802276:	83 c4 10             	add    $0x10,%esp
  802279:	c9                   	leave  
  80227a:	c3                   	ret    

0080227b <getchar>:

int
getchar(void)
{
  80227b:	55                   	push   %ebp
  80227c:	89 e5                	mov    %esp,%ebp
  80227e:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802281:	6a 01                	push   $0x1
  802283:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802286:	50                   	push   %eax
  802287:	6a 00                	push   $0x0
  802289:	e8 00 f2 ff ff       	call   80148e <read>
	if (r < 0)
  80228e:	83 c4 10             	add    $0x10,%esp
  802291:	85 c0                	test   %eax,%eax
  802293:	78 0f                	js     8022a4 <getchar+0x29>
		return r;
	if (r < 1)
  802295:	85 c0                	test   %eax,%eax
  802297:	7e 06                	jle    80229f <getchar+0x24>
		return -E_EOF;
	return c;
  802299:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80229d:	eb 05                	jmp    8022a4 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80229f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8022a4:	c9                   	leave  
  8022a5:	c3                   	ret    

008022a6 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8022a6:	55                   	push   %ebp
  8022a7:	89 e5                	mov    %esp,%ebp
  8022a9:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8022ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022af:	50                   	push   %eax
  8022b0:	ff 75 08             	pushl  0x8(%ebp)
  8022b3:	e8 70 ef ff ff       	call   801228 <fd_lookup>
  8022b8:	83 c4 10             	add    $0x10,%esp
  8022bb:	85 c0                	test   %eax,%eax
  8022bd:	78 11                	js     8022d0 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8022bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022c2:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8022c8:	39 10                	cmp    %edx,(%eax)
  8022ca:	0f 94 c0             	sete   %al
  8022cd:	0f b6 c0             	movzbl %al,%eax
}
  8022d0:	c9                   	leave  
  8022d1:	c3                   	ret    

008022d2 <opencons>:

int
opencons(void)
{
  8022d2:	55                   	push   %ebp
  8022d3:	89 e5                	mov    %esp,%ebp
  8022d5:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8022d8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022db:	50                   	push   %eax
  8022dc:	e8 f8 ee ff ff       	call   8011d9 <fd_alloc>
  8022e1:	83 c4 10             	add    $0x10,%esp
		return r;
  8022e4:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8022e6:	85 c0                	test   %eax,%eax
  8022e8:	78 3e                	js     802328 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8022ea:	83 ec 04             	sub    $0x4,%esp
  8022ed:	68 07 04 00 00       	push   $0x407
  8022f2:	ff 75 f4             	pushl  -0xc(%ebp)
  8022f5:	6a 00                	push   $0x0
  8022f7:	e8 fd e9 ff ff       	call   800cf9 <sys_page_alloc>
  8022fc:	83 c4 10             	add    $0x10,%esp
		return r;
  8022ff:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802301:	85 c0                	test   %eax,%eax
  802303:	78 23                	js     802328 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802305:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80230b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80230e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802310:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802313:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80231a:	83 ec 0c             	sub    $0xc,%esp
  80231d:	50                   	push   %eax
  80231e:	e8 8f ee ff ff       	call   8011b2 <fd2num>
  802323:	89 c2                	mov    %eax,%edx
  802325:	83 c4 10             	add    $0x10,%esp
}
  802328:	89 d0                	mov    %edx,%eax
  80232a:	c9                   	leave  
  80232b:	c3                   	ret    

0080232c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80232c:	55                   	push   %ebp
  80232d:	89 e5                	mov    %esp,%ebp
  80232f:	53                   	push   %ebx
  802330:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  802333:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  80233a:	75 28                	jne    802364 <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  80233c:	e8 7a e9 ff ff       	call   800cbb <sys_getenvid>
  802341:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_U | PTE_W);
  802343:	83 ec 04             	sub    $0x4,%esp
  802346:	6a 06                	push   $0x6
  802348:	68 00 f0 bf ee       	push   $0xeebff000
  80234d:	50                   	push   %eax
  80234e:	e8 a6 e9 ff ff       	call   800cf9 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  802353:	83 c4 08             	add    $0x8,%esp
  802356:	68 71 23 80 00       	push   $0x802371
  80235b:	53                   	push   %ebx
  80235c:	e8 e3 ea ff ff       	call   800e44 <sys_env_set_pgfault_upcall>
  802361:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802364:	8b 45 08             	mov    0x8(%ebp),%eax
  802367:	a3 00 70 80 00       	mov    %eax,0x807000
}
  80236c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80236f:	c9                   	leave  
  802370:	c3                   	ret    

00802371 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802371:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802372:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802377:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802379:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	# My method is different. Copy the values to the other stack
	# in a convinient way, and then pop everything.
	movl %esp, %ebp		# ebp refers to the exception stack
  80237c:	89 e5                	mov    %esp,%ebp
	movl 48(%ebp), %esp 	# go to other stack
  80237e:	8b 65 30             	mov    0x30(%ebp),%esp

	pushl 40(%ebp)		# eip - ORDER SWITCHED WITH EFLAGS
  802381:	ff 75 28             	pushl  0x28(%ebp)
	pushl 44(%ebp)      	# eflags
  802384:	ff 75 2c             	pushl  0x2c(%ebp)
	pushl 36(%ebp)		# all the 8 remaining regs
  802387:	ff 75 24             	pushl  0x24(%ebp)
	pushl 32(%ebp)
  80238a:	ff 75 20             	pushl  0x20(%ebp)
	pushl 28(%ebp)
  80238d:	ff 75 1c             	pushl  0x1c(%ebp)
	pushl 24(%ebp)
  802390:	ff 75 18             	pushl  0x18(%ebp)
	pushl 20(%ebp)
  802393:	ff 75 14             	pushl  0x14(%ebp)
	pushl 16(%ebp)
  802396:	ff 75 10             	pushl  0x10(%ebp)
	pushl 12(%ebp)
  802399:	ff 75 0c             	pushl  0xc(%ebp)
	pushl 8(%ebp)
  80239c:	ff 75 08             	pushl  0x8(%ebp)

	popal			# now just pop everything!
  80239f:	61                   	popa   
	popfl
  8023a0:	9d                   	popf   
	ret
  8023a1:	c3                   	ret    

008023a2 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8023a2:	55                   	push   %ebp
  8023a3:	89 e5                	mov    %esp,%ebp
  8023a5:	56                   	push   %esi
  8023a6:	53                   	push   %ebx
  8023a7:	8b 75 08             	mov    0x8(%ebp),%esi
  8023aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023ad:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  8023b0:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  8023b2:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  8023b7:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  8023ba:	83 ec 0c             	sub    $0xc,%esp
  8023bd:	50                   	push   %eax
  8023be:	e8 e6 ea ff ff       	call   800ea9 <sys_ipc_recv>

	if (r < 0) {
  8023c3:	83 c4 10             	add    $0x10,%esp
  8023c6:	85 c0                	test   %eax,%eax
  8023c8:	79 16                	jns    8023e0 <ipc_recv+0x3e>
		if (from_env_store)
  8023ca:	85 f6                	test   %esi,%esi
  8023cc:	74 06                	je     8023d4 <ipc_recv+0x32>
			*from_env_store = 0;
  8023ce:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  8023d4:	85 db                	test   %ebx,%ebx
  8023d6:	74 2c                	je     802404 <ipc_recv+0x62>
			*perm_store = 0;
  8023d8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8023de:	eb 24                	jmp    802404 <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  8023e0:	85 f6                	test   %esi,%esi
  8023e2:	74 0a                	je     8023ee <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  8023e4:	a1 08 40 80 00       	mov    0x804008,%eax
  8023e9:	8b 40 74             	mov    0x74(%eax),%eax
  8023ec:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  8023ee:	85 db                	test   %ebx,%ebx
  8023f0:	74 0a                	je     8023fc <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  8023f2:	a1 08 40 80 00       	mov    0x804008,%eax
  8023f7:	8b 40 78             	mov    0x78(%eax),%eax
  8023fa:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  8023fc:	a1 08 40 80 00       	mov    0x804008,%eax
  802401:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  802404:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802407:	5b                   	pop    %ebx
  802408:	5e                   	pop    %esi
  802409:	5d                   	pop    %ebp
  80240a:	c3                   	ret    

0080240b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80240b:	55                   	push   %ebp
  80240c:	89 e5                	mov    %esp,%ebp
  80240e:	57                   	push   %edi
  80240f:	56                   	push   %esi
  802410:	53                   	push   %ebx
  802411:	83 ec 0c             	sub    $0xc,%esp
  802414:	8b 7d 08             	mov    0x8(%ebp),%edi
  802417:	8b 75 0c             	mov    0xc(%ebp),%esi
  80241a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  80241d:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  80241f:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  802424:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  802427:	ff 75 14             	pushl  0x14(%ebp)
  80242a:	53                   	push   %ebx
  80242b:	56                   	push   %esi
  80242c:	57                   	push   %edi
  80242d:	e8 54 ea ff ff       	call   800e86 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  802432:	83 c4 10             	add    $0x10,%esp
  802435:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802438:	75 07                	jne    802441 <ipc_send+0x36>
			sys_yield();
  80243a:	e8 9b e8 ff ff       	call   800cda <sys_yield>
  80243f:	eb e6                	jmp    802427 <ipc_send+0x1c>
		} else if (r < 0) {
  802441:	85 c0                	test   %eax,%eax
  802443:	79 12                	jns    802457 <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  802445:	50                   	push   %eax
  802446:	68 3e 2d 80 00       	push   $0x802d3e
  80244b:	6a 51                	push   $0x51
  80244d:	68 4b 2d 80 00       	push   $0x802d4b
  802452:	e8 41 de ff ff       	call   800298 <_panic>
		}
	}
}
  802457:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80245a:	5b                   	pop    %ebx
  80245b:	5e                   	pop    %esi
  80245c:	5f                   	pop    %edi
  80245d:	5d                   	pop    %ebp
  80245e:	c3                   	ret    

0080245f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80245f:	55                   	push   %ebp
  802460:	89 e5                	mov    %esp,%ebp
  802462:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802465:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80246a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80246d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802473:	8b 52 50             	mov    0x50(%edx),%edx
  802476:	39 ca                	cmp    %ecx,%edx
  802478:	75 0d                	jne    802487 <ipc_find_env+0x28>
			return envs[i].env_id;
  80247a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80247d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802482:	8b 40 48             	mov    0x48(%eax),%eax
  802485:	eb 0f                	jmp    802496 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802487:	83 c0 01             	add    $0x1,%eax
  80248a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80248f:	75 d9                	jne    80246a <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802491:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802496:	5d                   	pop    %ebp
  802497:	c3                   	ret    

00802498 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802498:	55                   	push   %ebp
  802499:	89 e5                	mov    %esp,%ebp
  80249b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80249e:	89 d0                	mov    %edx,%eax
  8024a0:	c1 e8 16             	shr    $0x16,%eax
  8024a3:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8024aa:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8024af:	f6 c1 01             	test   $0x1,%cl
  8024b2:	74 1d                	je     8024d1 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8024b4:	c1 ea 0c             	shr    $0xc,%edx
  8024b7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8024be:	f6 c2 01             	test   $0x1,%dl
  8024c1:	74 0e                	je     8024d1 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8024c3:	c1 ea 0c             	shr    $0xc,%edx
  8024c6:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8024cd:	ef 
  8024ce:	0f b7 c0             	movzwl %ax,%eax
}
  8024d1:	5d                   	pop    %ebp
  8024d2:	c3                   	ret    
  8024d3:	66 90                	xchg   %ax,%ax
  8024d5:	66 90                	xchg   %ax,%ax
  8024d7:	66 90                	xchg   %ax,%ax
  8024d9:	66 90                	xchg   %ax,%ax
  8024db:	66 90                	xchg   %ax,%ax
  8024dd:	66 90                	xchg   %ax,%ax
  8024df:	90                   	nop

008024e0 <__udivdi3>:
  8024e0:	55                   	push   %ebp
  8024e1:	57                   	push   %edi
  8024e2:	56                   	push   %esi
  8024e3:	53                   	push   %ebx
  8024e4:	83 ec 1c             	sub    $0x1c,%esp
  8024e7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8024eb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8024ef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8024f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8024f7:	85 f6                	test   %esi,%esi
  8024f9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8024fd:	89 ca                	mov    %ecx,%edx
  8024ff:	89 f8                	mov    %edi,%eax
  802501:	75 3d                	jne    802540 <__udivdi3+0x60>
  802503:	39 cf                	cmp    %ecx,%edi
  802505:	0f 87 c5 00 00 00    	ja     8025d0 <__udivdi3+0xf0>
  80250b:	85 ff                	test   %edi,%edi
  80250d:	89 fd                	mov    %edi,%ebp
  80250f:	75 0b                	jne    80251c <__udivdi3+0x3c>
  802511:	b8 01 00 00 00       	mov    $0x1,%eax
  802516:	31 d2                	xor    %edx,%edx
  802518:	f7 f7                	div    %edi
  80251a:	89 c5                	mov    %eax,%ebp
  80251c:	89 c8                	mov    %ecx,%eax
  80251e:	31 d2                	xor    %edx,%edx
  802520:	f7 f5                	div    %ebp
  802522:	89 c1                	mov    %eax,%ecx
  802524:	89 d8                	mov    %ebx,%eax
  802526:	89 cf                	mov    %ecx,%edi
  802528:	f7 f5                	div    %ebp
  80252a:	89 c3                	mov    %eax,%ebx
  80252c:	89 d8                	mov    %ebx,%eax
  80252e:	89 fa                	mov    %edi,%edx
  802530:	83 c4 1c             	add    $0x1c,%esp
  802533:	5b                   	pop    %ebx
  802534:	5e                   	pop    %esi
  802535:	5f                   	pop    %edi
  802536:	5d                   	pop    %ebp
  802537:	c3                   	ret    
  802538:	90                   	nop
  802539:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802540:	39 ce                	cmp    %ecx,%esi
  802542:	77 74                	ja     8025b8 <__udivdi3+0xd8>
  802544:	0f bd fe             	bsr    %esi,%edi
  802547:	83 f7 1f             	xor    $0x1f,%edi
  80254a:	0f 84 98 00 00 00    	je     8025e8 <__udivdi3+0x108>
  802550:	bb 20 00 00 00       	mov    $0x20,%ebx
  802555:	89 f9                	mov    %edi,%ecx
  802557:	89 c5                	mov    %eax,%ebp
  802559:	29 fb                	sub    %edi,%ebx
  80255b:	d3 e6                	shl    %cl,%esi
  80255d:	89 d9                	mov    %ebx,%ecx
  80255f:	d3 ed                	shr    %cl,%ebp
  802561:	89 f9                	mov    %edi,%ecx
  802563:	d3 e0                	shl    %cl,%eax
  802565:	09 ee                	or     %ebp,%esi
  802567:	89 d9                	mov    %ebx,%ecx
  802569:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80256d:	89 d5                	mov    %edx,%ebp
  80256f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802573:	d3 ed                	shr    %cl,%ebp
  802575:	89 f9                	mov    %edi,%ecx
  802577:	d3 e2                	shl    %cl,%edx
  802579:	89 d9                	mov    %ebx,%ecx
  80257b:	d3 e8                	shr    %cl,%eax
  80257d:	09 c2                	or     %eax,%edx
  80257f:	89 d0                	mov    %edx,%eax
  802581:	89 ea                	mov    %ebp,%edx
  802583:	f7 f6                	div    %esi
  802585:	89 d5                	mov    %edx,%ebp
  802587:	89 c3                	mov    %eax,%ebx
  802589:	f7 64 24 0c          	mull   0xc(%esp)
  80258d:	39 d5                	cmp    %edx,%ebp
  80258f:	72 10                	jb     8025a1 <__udivdi3+0xc1>
  802591:	8b 74 24 08          	mov    0x8(%esp),%esi
  802595:	89 f9                	mov    %edi,%ecx
  802597:	d3 e6                	shl    %cl,%esi
  802599:	39 c6                	cmp    %eax,%esi
  80259b:	73 07                	jae    8025a4 <__udivdi3+0xc4>
  80259d:	39 d5                	cmp    %edx,%ebp
  80259f:	75 03                	jne    8025a4 <__udivdi3+0xc4>
  8025a1:	83 eb 01             	sub    $0x1,%ebx
  8025a4:	31 ff                	xor    %edi,%edi
  8025a6:	89 d8                	mov    %ebx,%eax
  8025a8:	89 fa                	mov    %edi,%edx
  8025aa:	83 c4 1c             	add    $0x1c,%esp
  8025ad:	5b                   	pop    %ebx
  8025ae:	5e                   	pop    %esi
  8025af:	5f                   	pop    %edi
  8025b0:	5d                   	pop    %ebp
  8025b1:	c3                   	ret    
  8025b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8025b8:	31 ff                	xor    %edi,%edi
  8025ba:	31 db                	xor    %ebx,%ebx
  8025bc:	89 d8                	mov    %ebx,%eax
  8025be:	89 fa                	mov    %edi,%edx
  8025c0:	83 c4 1c             	add    $0x1c,%esp
  8025c3:	5b                   	pop    %ebx
  8025c4:	5e                   	pop    %esi
  8025c5:	5f                   	pop    %edi
  8025c6:	5d                   	pop    %ebp
  8025c7:	c3                   	ret    
  8025c8:	90                   	nop
  8025c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025d0:	89 d8                	mov    %ebx,%eax
  8025d2:	f7 f7                	div    %edi
  8025d4:	31 ff                	xor    %edi,%edi
  8025d6:	89 c3                	mov    %eax,%ebx
  8025d8:	89 d8                	mov    %ebx,%eax
  8025da:	89 fa                	mov    %edi,%edx
  8025dc:	83 c4 1c             	add    $0x1c,%esp
  8025df:	5b                   	pop    %ebx
  8025e0:	5e                   	pop    %esi
  8025e1:	5f                   	pop    %edi
  8025e2:	5d                   	pop    %ebp
  8025e3:	c3                   	ret    
  8025e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025e8:	39 ce                	cmp    %ecx,%esi
  8025ea:	72 0c                	jb     8025f8 <__udivdi3+0x118>
  8025ec:	31 db                	xor    %ebx,%ebx
  8025ee:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8025f2:	0f 87 34 ff ff ff    	ja     80252c <__udivdi3+0x4c>
  8025f8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8025fd:	e9 2a ff ff ff       	jmp    80252c <__udivdi3+0x4c>
  802602:	66 90                	xchg   %ax,%ax
  802604:	66 90                	xchg   %ax,%ax
  802606:	66 90                	xchg   %ax,%ax
  802608:	66 90                	xchg   %ax,%ax
  80260a:	66 90                	xchg   %ax,%ax
  80260c:	66 90                	xchg   %ax,%ax
  80260e:	66 90                	xchg   %ax,%ax

00802610 <__umoddi3>:
  802610:	55                   	push   %ebp
  802611:	57                   	push   %edi
  802612:	56                   	push   %esi
  802613:	53                   	push   %ebx
  802614:	83 ec 1c             	sub    $0x1c,%esp
  802617:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80261b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80261f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802623:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802627:	85 d2                	test   %edx,%edx
  802629:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80262d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802631:	89 f3                	mov    %esi,%ebx
  802633:	89 3c 24             	mov    %edi,(%esp)
  802636:	89 74 24 04          	mov    %esi,0x4(%esp)
  80263a:	75 1c                	jne    802658 <__umoddi3+0x48>
  80263c:	39 f7                	cmp    %esi,%edi
  80263e:	76 50                	jbe    802690 <__umoddi3+0x80>
  802640:	89 c8                	mov    %ecx,%eax
  802642:	89 f2                	mov    %esi,%edx
  802644:	f7 f7                	div    %edi
  802646:	89 d0                	mov    %edx,%eax
  802648:	31 d2                	xor    %edx,%edx
  80264a:	83 c4 1c             	add    $0x1c,%esp
  80264d:	5b                   	pop    %ebx
  80264e:	5e                   	pop    %esi
  80264f:	5f                   	pop    %edi
  802650:	5d                   	pop    %ebp
  802651:	c3                   	ret    
  802652:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802658:	39 f2                	cmp    %esi,%edx
  80265a:	89 d0                	mov    %edx,%eax
  80265c:	77 52                	ja     8026b0 <__umoddi3+0xa0>
  80265e:	0f bd ea             	bsr    %edx,%ebp
  802661:	83 f5 1f             	xor    $0x1f,%ebp
  802664:	75 5a                	jne    8026c0 <__umoddi3+0xb0>
  802666:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80266a:	0f 82 e0 00 00 00    	jb     802750 <__umoddi3+0x140>
  802670:	39 0c 24             	cmp    %ecx,(%esp)
  802673:	0f 86 d7 00 00 00    	jbe    802750 <__umoddi3+0x140>
  802679:	8b 44 24 08          	mov    0x8(%esp),%eax
  80267d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802681:	83 c4 1c             	add    $0x1c,%esp
  802684:	5b                   	pop    %ebx
  802685:	5e                   	pop    %esi
  802686:	5f                   	pop    %edi
  802687:	5d                   	pop    %ebp
  802688:	c3                   	ret    
  802689:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802690:	85 ff                	test   %edi,%edi
  802692:	89 fd                	mov    %edi,%ebp
  802694:	75 0b                	jne    8026a1 <__umoddi3+0x91>
  802696:	b8 01 00 00 00       	mov    $0x1,%eax
  80269b:	31 d2                	xor    %edx,%edx
  80269d:	f7 f7                	div    %edi
  80269f:	89 c5                	mov    %eax,%ebp
  8026a1:	89 f0                	mov    %esi,%eax
  8026a3:	31 d2                	xor    %edx,%edx
  8026a5:	f7 f5                	div    %ebp
  8026a7:	89 c8                	mov    %ecx,%eax
  8026a9:	f7 f5                	div    %ebp
  8026ab:	89 d0                	mov    %edx,%eax
  8026ad:	eb 99                	jmp    802648 <__umoddi3+0x38>
  8026af:	90                   	nop
  8026b0:	89 c8                	mov    %ecx,%eax
  8026b2:	89 f2                	mov    %esi,%edx
  8026b4:	83 c4 1c             	add    $0x1c,%esp
  8026b7:	5b                   	pop    %ebx
  8026b8:	5e                   	pop    %esi
  8026b9:	5f                   	pop    %edi
  8026ba:	5d                   	pop    %ebp
  8026bb:	c3                   	ret    
  8026bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8026c0:	8b 34 24             	mov    (%esp),%esi
  8026c3:	bf 20 00 00 00       	mov    $0x20,%edi
  8026c8:	89 e9                	mov    %ebp,%ecx
  8026ca:	29 ef                	sub    %ebp,%edi
  8026cc:	d3 e0                	shl    %cl,%eax
  8026ce:	89 f9                	mov    %edi,%ecx
  8026d0:	89 f2                	mov    %esi,%edx
  8026d2:	d3 ea                	shr    %cl,%edx
  8026d4:	89 e9                	mov    %ebp,%ecx
  8026d6:	09 c2                	or     %eax,%edx
  8026d8:	89 d8                	mov    %ebx,%eax
  8026da:	89 14 24             	mov    %edx,(%esp)
  8026dd:	89 f2                	mov    %esi,%edx
  8026df:	d3 e2                	shl    %cl,%edx
  8026e1:	89 f9                	mov    %edi,%ecx
  8026e3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8026e7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8026eb:	d3 e8                	shr    %cl,%eax
  8026ed:	89 e9                	mov    %ebp,%ecx
  8026ef:	89 c6                	mov    %eax,%esi
  8026f1:	d3 e3                	shl    %cl,%ebx
  8026f3:	89 f9                	mov    %edi,%ecx
  8026f5:	89 d0                	mov    %edx,%eax
  8026f7:	d3 e8                	shr    %cl,%eax
  8026f9:	89 e9                	mov    %ebp,%ecx
  8026fb:	09 d8                	or     %ebx,%eax
  8026fd:	89 d3                	mov    %edx,%ebx
  8026ff:	89 f2                	mov    %esi,%edx
  802701:	f7 34 24             	divl   (%esp)
  802704:	89 d6                	mov    %edx,%esi
  802706:	d3 e3                	shl    %cl,%ebx
  802708:	f7 64 24 04          	mull   0x4(%esp)
  80270c:	39 d6                	cmp    %edx,%esi
  80270e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802712:	89 d1                	mov    %edx,%ecx
  802714:	89 c3                	mov    %eax,%ebx
  802716:	72 08                	jb     802720 <__umoddi3+0x110>
  802718:	75 11                	jne    80272b <__umoddi3+0x11b>
  80271a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80271e:	73 0b                	jae    80272b <__umoddi3+0x11b>
  802720:	2b 44 24 04          	sub    0x4(%esp),%eax
  802724:	1b 14 24             	sbb    (%esp),%edx
  802727:	89 d1                	mov    %edx,%ecx
  802729:	89 c3                	mov    %eax,%ebx
  80272b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80272f:	29 da                	sub    %ebx,%edx
  802731:	19 ce                	sbb    %ecx,%esi
  802733:	89 f9                	mov    %edi,%ecx
  802735:	89 f0                	mov    %esi,%eax
  802737:	d3 e0                	shl    %cl,%eax
  802739:	89 e9                	mov    %ebp,%ecx
  80273b:	d3 ea                	shr    %cl,%edx
  80273d:	89 e9                	mov    %ebp,%ecx
  80273f:	d3 ee                	shr    %cl,%esi
  802741:	09 d0                	or     %edx,%eax
  802743:	89 f2                	mov    %esi,%edx
  802745:	83 c4 1c             	add    $0x1c,%esp
  802748:	5b                   	pop    %ebx
  802749:	5e                   	pop    %esi
  80274a:	5f                   	pop    %edi
  80274b:	5d                   	pop    %ebp
  80274c:	c3                   	ret    
  80274d:	8d 76 00             	lea    0x0(%esi),%esi
  802750:	29 f9                	sub    %edi,%ecx
  802752:	19 d6                	sbb    %edx,%esi
  802754:	89 74 24 04          	mov    %esi,0x4(%esp)
  802758:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80275c:	e9 18 ff ff ff       	jmp    802679 <__umoddi3+0x69>
