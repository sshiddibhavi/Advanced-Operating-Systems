
obj/user/icode.debug:     file format elf32-i386


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
  80002c:	e8 03 01 00 00       	call   800134 <libmain>
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
  800038:	81 ec 1c 02 00 00    	sub    $0x21c,%esp
	int fd, n, r;
	char buf[512+1];

	binaryname = "icode";
  80003e:	c7 05 00 30 80 00 00 	movl   $0x802900,0x803000
  800045:	29 80 00 

	cprintf("icode startup\n");
  800048:	68 06 29 80 00       	push   $0x802906
  80004d:	e8 1b 02 00 00       	call   80026d <cprintf>

	cprintf("icode: open /motd\n");
  800052:	c7 04 24 15 29 80 00 	movl   $0x802915,(%esp)
  800059:	e8 0f 02 00 00       	call   80026d <cprintf>
	if ((fd = open("/motd", O_RDONLY)) < 0)
  80005e:	83 c4 08             	add    $0x8,%esp
  800061:	6a 00                	push   $0x0
  800063:	68 28 29 80 00       	push   $0x802928
  800068:	e8 28 15 00 00       	call   801595 <open>
  80006d:	89 c6                	mov    %eax,%esi
  80006f:	83 c4 10             	add    $0x10,%esp
  800072:	85 c0                	test   %eax,%eax
  800074:	79 12                	jns    800088 <umain+0x55>
		panic("icode: open /motd: %e", fd);
  800076:	50                   	push   %eax
  800077:	68 2e 29 80 00       	push   $0x80292e
  80007c:	6a 0f                	push   $0xf
  80007e:	68 44 29 80 00       	push   $0x802944
  800083:	e8 0c 01 00 00       	call   800194 <_panic>

	cprintf("icode: read /motd\n");
  800088:	83 ec 0c             	sub    $0xc,%esp
  80008b:	68 51 29 80 00       	push   $0x802951
  800090:	e8 d8 01 00 00       	call   80026d <cprintf>
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	8d 9d f7 fd ff ff    	lea    -0x209(%ebp),%ebx
  80009e:	eb 0d                	jmp    8000ad <umain+0x7a>
		sys_cputs(buf, n);
  8000a0:	83 ec 08             	sub    $0x8,%esp
  8000a3:	50                   	push   %eax
  8000a4:	53                   	push   %ebx
  8000a5:	e8 8f 0a 00 00       	call   800b39 <sys_cputs>
  8000aa:	83 c4 10             	add    $0x10,%esp
	cprintf("icode: open /motd\n");
	if ((fd = open("/motd", O_RDONLY)) < 0)
		panic("icode: open /motd: %e", fd);

	cprintf("icode: read /motd\n");
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  8000ad:	83 ec 04             	sub    $0x4,%esp
  8000b0:	68 00 02 00 00       	push   $0x200
  8000b5:	53                   	push   %ebx
  8000b6:	56                   	push   %esi
  8000b7:	e8 25 10 00 00       	call   8010e1 <read>
  8000bc:	83 c4 10             	add    $0x10,%esp
  8000bf:	85 c0                	test   %eax,%eax
  8000c1:	7f dd                	jg     8000a0 <umain+0x6d>
		sys_cputs(buf, n);

	cprintf("icode: close /motd\n");
  8000c3:	83 ec 0c             	sub    $0xc,%esp
  8000c6:	68 64 29 80 00       	push   $0x802964
  8000cb:	e8 9d 01 00 00       	call   80026d <cprintf>
	close(fd);
  8000d0:	89 34 24             	mov    %esi,(%esp)
  8000d3:	e8 cd 0e 00 00       	call   800fa5 <close>

	cprintf("icode: spawn /init\n");
  8000d8:	c7 04 24 78 29 80 00 	movl   $0x802978,(%esp)
  8000df:	e8 89 01 00 00       	call   80026d <cprintf>
	if ((r = spawnl("/init", "init", "initarg1", "initarg2", (char*)0)) < 0)
  8000e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000eb:	68 8c 29 80 00       	push   $0x80298c
  8000f0:	68 95 29 80 00       	push   $0x802995
  8000f5:	68 9f 29 80 00       	push   $0x80299f
  8000fa:	68 9e 29 80 00       	push   $0x80299e
  8000ff:	e8 76 1a 00 00       	call   801b7a <spawnl>
  800104:	83 c4 20             	add    $0x20,%esp
  800107:	85 c0                	test   %eax,%eax
  800109:	79 12                	jns    80011d <umain+0xea>
		panic("icode: spawn /init: %e", r);
  80010b:	50                   	push   %eax
  80010c:	68 a4 29 80 00       	push   $0x8029a4
  800111:	6a 1a                	push   $0x1a
  800113:	68 44 29 80 00       	push   $0x802944
  800118:	e8 77 00 00 00       	call   800194 <_panic>

	cprintf("icode: exiting\n");
  80011d:	83 ec 0c             	sub    $0xc,%esp
  800120:	68 bb 29 80 00       	push   $0x8029bb
  800125:	e8 43 01 00 00       	call   80026d <cprintf>
}
  80012a:	83 c4 10             	add    $0x10,%esp
  80012d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800130:	5b                   	pop    %ebx
  800131:	5e                   	pop    %esi
  800132:	5d                   	pop    %ebp
  800133:	c3                   	ret    

00800134 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	56                   	push   %esi
  800138:	53                   	push   %ebx
  800139:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80013c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80013f:	e8 73 0a 00 00       	call   800bb7 <sys_getenvid>
  800144:	25 ff 03 00 00       	and    $0x3ff,%eax
  800149:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80014c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800151:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800156:	85 db                	test   %ebx,%ebx
  800158:	7e 07                	jle    800161 <libmain+0x2d>
		binaryname = argv[0];
  80015a:	8b 06                	mov    (%esi),%eax
  80015c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800161:	83 ec 08             	sub    $0x8,%esp
  800164:	56                   	push   %esi
  800165:	53                   	push   %ebx
  800166:	e8 c8 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80016b:	e8 0a 00 00 00       	call   80017a <exit>
}
  800170:	83 c4 10             	add    $0x10,%esp
  800173:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800176:	5b                   	pop    %ebx
  800177:	5e                   	pop    %esi
  800178:	5d                   	pop    %ebp
  800179:	c3                   	ret    

0080017a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80017a:	55                   	push   %ebp
  80017b:	89 e5                	mov    %esp,%ebp
  80017d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800180:	e8 4b 0e 00 00       	call   800fd0 <close_all>
	sys_env_destroy(0);
  800185:	83 ec 0c             	sub    $0xc,%esp
  800188:	6a 00                	push   $0x0
  80018a:	e8 e7 09 00 00       	call   800b76 <sys_env_destroy>
}
  80018f:	83 c4 10             	add    $0x10,%esp
  800192:	c9                   	leave  
  800193:	c3                   	ret    

00800194 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800194:	55                   	push   %ebp
  800195:	89 e5                	mov    %esp,%ebp
  800197:	56                   	push   %esi
  800198:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800199:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80019c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8001a2:	e8 10 0a 00 00       	call   800bb7 <sys_getenvid>
  8001a7:	83 ec 0c             	sub    $0xc,%esp
  8001aa:	ff 75 0c             	pushl  0xc(%ebp)
  8001ad:	ff 75 08             	pushl  0x8(%ebp)
  8001b0:	56                   	push   %esi
  8001b1:	50                   	push   %eax
  8001b2:	68 d8 29 80 00       	push   $0x8029d8
  8001b7:	e8 b1 00 00 00       	call   80026d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001bc:	83 c4 18             	add    $0x18,%esp
  8001bf:	53                   	push   %ebx
  8001c0:	ff 75 10             	pushl  0x10(%ebp)
  8001c3:	e8 54 00 00 00       	call   80021c <vcprintf>
	cprintf("\n");
  8001c8:	c7 04 24 e9 2e 80 00 	movl   $0x802ee9,(%esp)
  8001cf:	e8 99 00 00 00       	call   80026d <cprintf>
  8001d4:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001d7:	cc                   	int3   
  8001d8:	eb fd                	jmp    8001d7 <_panic+0x43>

008001da <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001da:	55                   	push   %ebp
  8001db:	89 e5                	mov    %esp,%ebp
  8001dd:	53                   	push   %ebx
  8001de:	83 ec 04             	sub    $0x4,%esp
  8001e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001e4:	8b 13                	mov    (%ebx),%edx
  8001e6:	8d 42 01             	lea    0x1(%edx),%eax
  8001e9:	89 03                	mov    %eax,(%ebx)
  8001eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ee:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001f2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001f7:	75 1a                	jne    800213 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001f9:	83 ec 08             	sub    $0x8,%esp
  8001fc:	68 ff 00 00 00       	push   $0xff
  800201:	8d 43 08             	lea    0x8(%ebx),%eax
  800204:	50                   	push   %eax
  800205:	e8 2f 09 00 00       	call   800b39 <sys_cputs>
		b->idx = 0;
  80020a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800210:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800213:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800217:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80021a:	c9                   	leave  
  80021b:	c3                   	ret    

0080021c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800225:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80022c:	00 00 00 
	b.cnt = 0;
  80022f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800236:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800239:	ff 75 0c             	pushl  0xc(%ebp)
  80023c:	ff 75 08             	pushl  0x8(%ebp)
  80023f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800245:	50                   	push   %eax
  800246:	68 da 01 80 00       	push   $0x8001da
  80024b:	e8 54 01 00 00       	call   8003a4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800250:	83 c4 08             	add    $0x8,%esp
  800253:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800259:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80025f:	50                   	push   %eax
  800260:	e8 d4 08 00 00       	call   800b39 <sys_cputs>

	return b.cnt;
}
  800265:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80026b:	c9                   	leave  
  80026c:	c3                   	ret    

0080026d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80026d:	55                   	push   %ebp
  80026e:	89 e5                	mov    %esp,%ebp
  800270:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800273:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800276:	50                   	push   %eax
  800277:	ff 75 08             	pushl  0x8(%ebp)
  80027a:	e8 9d ff ff ff       	call   80021c <vcprintf>
	va_end(ap);

	return cnt;
}
  80027f:	c9                   	leave  
  800280:	c3                   	ret    

00800281 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800281:	55                   	push   %ebp
  800282:	89 e5                	mov    %esp,%ebp
  800284:	57                   	push   %edi
  800285:	56                   	push   %esi
  800286:	53                   	push   %ebx
  800287:	83 ec 1c             	sub    $0x1c,%esp
  80028a:	89 c7                	mov    %eax,%edi
  80028c:	89 d6                	mov    %edx,%esi
  80028e:	8b 45 08             	mov    0x8(%ebp),%eax
  800291:	8b 55 0c             	mov    0xc(%ebp),%edx
  800294:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800297:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80029a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80029d:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002a2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002a5:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002a8:	39 d3                	cmp    %edx,%ebx
  8002aa:	72 05                	jb     8002b1 <printnum+0x30>
  8002ac:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002af:	77 45                	ja     8002f6 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002b1:	83 ec 0c             	sub    $0xc,%esp
  8002b4:	ff 75 18             	pushl  0x18(%ebp)
  8002b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8002ba:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002bd:	53                   	push   %ebx
  8002be:	ff 75 10             	pushl  0x10(%ebp)
  8002c1:	83 ec 08             	sub    $0x8,%esp
  8002c4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002c7:	ff 75 e0             	pushl  -0x20(%ebp)
  8002ca:	ff 75 dc             	pushl  -0x24(%ebp)
  8002cd:	ff 75 d8             	pushl  -0x28(%ebp)
  8002d0:	e8 9b 23 00 00       	call   802670 <__udivdi3>
  8002d5:	83 c4 18             	add    $0x18,%esp
  8002d8:	52                   	push   %edx
  8002d9:	50                   	push   %eax
  8002da:	89 f2                	mov    %esi,%edx
  8002dc:	89 f8                	mov    %edi,%eax
  8002de:	e8 9e ff ff ff       	call   800281 <printnum>
  8002e3:	83 c4 20             	add    $0x20,%esp
  8002e6:	eb 18                	jmp    800300 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002e8:	83 ec 08             	sub    $0x8,%esp
  8002eb:	56                   	push   %esi
  8002ec:	ff 75 18             	pushl  0x18(%ebp)
  8002ef:	ff d7                	call   *%edi
  8002f1:	83 c4 10             	add    $0x10,%esp
  8002f4:	eb 03                	jmp    8002f9 <printnum+0x78>
  8002f6:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002f9:	83 eb 01             	sub    $0x1,%ebx
  8002fc:	85 db                	test   %ebx,%ebx
  8002fe:	7f e8                	jg     8002e8 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800300:	83 ec 08             	sub    $0x8,%esp
  800303:	56                   	push   %esi
  800304:	83 ec 04             	sub    $0x4,%esp
  800307:	ff 75 e4             	pushl  -0x1c(%ebp)
  80030a:	ff 75 e0             	pushl  -0x20(%ebp)
  80030d:	ff 75 dc             	pushl  -0x24(%ebp)
  800310:	ff 75 d8             	pushl  -0x28(%ebp)
  800313:	e8 88 24 00 00       	call   8027a0 <__umoddi3>
  800318:	83 c4 14             	add    $0x14,%esp
  80031b:	0f be 80 fb 29 80 00 	movsbl 0x8029fb(%eax),%eax
  800322:	50                   	push   %eax
  800323:	ff d7                	call   *%edi
}
  800325:	83 c4 10             	add    $0x10,%esp
  800328:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80032b:	5b                   	pop    %ebx
  80032c:	5e                   	pop    %esi
  80032d:	5f                   	pop    %edi
  80032e:	5d                   	pop    %ebp
  80032f:	c3                   	ret    

00800330 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800330:	55                   	push   %ebp
  800331:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800333:	83 fa 01             	cmp    $0x1,%edx
  800336:	7e 0e                	jle    800346 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800338:	8b 10                	mov    (%eax),%edx
  80033a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80033d:	89 08                	mov    %ecx,(%eax)
  80033f:	8b 02                	mov    (%edx),%eax
  800341:	8b 52 04             	mov    0x4(%edx),%edx
  800344:	eb 22                	jmp    800368 <getuint+0x38>
	else if (lflag)
  800346:	85 d2                	test   %edx,%edx
  800348:	74 10                	je     80035a <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80034a:	8b 10                	mov    (%eax),%edx
  80034c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80034f:	89 08                	mov    %ecx,(%eax)
  800351:	8b 02                	mov    (%edx),%eax
  800353:	ba 00 00 00 00       	mov    $0x0,%edx
  800358:	eb 0e                	jmp    800368 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80035a:	8b 10                	mov    (%eax),%edx
  80035c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80035f:	89 08                	mov    %ecx,(%eax)
  800361:	8b 02                	mov    (%edx),%eax
  800363:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800368:	5d                   	pop    %ebp
  800369:	c3                   	ret    

0080036a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80036a:	55                   	push   %ebp
  80036b:	89 e5                	mov    %esp,%ebp
  80036d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800370:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800374:	8b 10                	mov    (%eax),%edx
  800376:	3b 50 04             	cmp    0x4(%eax),%edx
  800379:	73 0a                	jae    800385 <sprintputch+0x1b>
		*b->buf++ = ch;
  80037b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80037e:	89 08                	mov    %ecx,(%eax)
  800380:	8b 45 08             	mov    0x8(%ebp),%eax
  800383:	88 02                	mov    %al,(%edx)
}
  800385:	5d                   	pop    %ebp
  800386:	c3                   	ret    

00800387 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800387:	55                   	push   %ebp
  800388:	89 e5                	mov    %esp,%ebp
  80038a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80038d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800390:	50                   	push   %eax
  800391:	ff 75 10             	pushl  0x10(%ebp)
  800394:	ff 75 0c             	pushl  0xc(%ebp)
  800397:	ff 75 08             	pushl  0x8(%ebp)
  80039a:	e8 05 00 00 00       	call   8003a4 <vprintfmt>
	va_end(ap);
}
  80039f:	83 c4 10             	add    $0x10,%esp
  8003a2:	c9                   	leave  
  8003a3:	c3                   	ret    

008003a4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003a4:	55                   	push   %ebp
  8003a5:	89 e5                	mov    %esp,%ebp
  8003a7:	57                   	push   %edi
  8003a8:	56                   	push   %esi
  8003a9:	53                   	push   %ebx
  8003aa:	83 ec 2c             	sub    $0x2c,%esp
  8003ad:	8b 75 08             	mov    0x8(%ebp),%esi
  8003b0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003b3:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003b6:	eb 12                	jmp    8003ca <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003b8:	85 c0                	test   %eax,%eax
  8003ba:	0f 84 89 03 00 00    	je     800749 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8003c0:	83 ec 08             	sub    $0x8,%esp
  8003c3:	53                   	push   %ebx
  8003c4:	50                   	push   %eax
  8003c5:	ff d6                	call   *%esi
  8003c7:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003ca:	83 c7 01             	add    $0x1,%edi
  8003cd:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003d1:	83 f8 25             	cmp    $0x25,%eax
  8003d4:	75 e2                	jne    8003b8 <vprintfmt+0x14>
  8003d6:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003da:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003e1:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003e8:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8003f4:	eb 07                	jmp    8003fd <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003f9:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fd:	8d 47 01             	lea    0x1(%edi),%eax
  800400:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800403:	0f b6 07             	movzbl (%edi),%eax
  800406:	0f b6 c8             	movzbl %al,%ecx
  800409:	83 e8 23             	sub    $0x23,%eax
  80040c:	3c 55                	cmp    $0x55,%al
  80040e:	0f 87 1a 03 00 00    	ja     80072e <vprintfmt+0x38a>
  800414:	0f b6 c0             	movzbl %al,%eax
  800417:	ff 24 85 40 2b 80 00 	jmp    *0x802b40(,%eax,4)
  80041e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800421:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800425:	eb d6                	jmp    8003fd <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800427:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80042a:	b8 00 00 00 00       	mov    $0x0,%eax
  80042f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800432:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800435:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800439:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80043c:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80043f:	83 fa 09             	cmp    $0x9,%edx
  800442:	77 39                	ja     80047d <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800444:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800447:	eb e9                	jmp    800432 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800449:	8b 45 14             	mov    0x14(%ebp),%eax
  80044c:	8d 48 04             	lea    0x4(%eax),%ecx
  80044f:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800452:	8b 00                	mov    (%eax),%eax
  800454:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800457:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80045a:	eb 27                	jmp    800483 <vprintfmt+0xdf>
  80045c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80045f:	85 c0                	test   %eax,%eax
  800461:	b9 00 00 00 00       	mov    $0x0,%ecx
  800466:	0f 49 c8             	cmovns %eax,%ecx
  800469:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80046f:	eb 8c                	jmp    8003fd <vprintfmt+0x59>
  800471:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800474:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80047b:	eb 80                	jmp    8003fd <vprintfmt+0x59>
  80047d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800480:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800483:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800487:	0f 89 70 ff ff ff    	jns    8003fd <vprintfmt+0x59>
				width = precision, precision = -1;
  80048d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800490:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800493:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80049a:	e9 5e ff ff ff       	jmp    8003fd <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80049f:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004a5:	e9 53 ff ff ff       	jmp    8003fd <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ad:	8d 50 04             	lea    0x4(%eax),%edx
  8004b0:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b3:	83 ec 08             	sub    $0x8,%esp
  8004b6:	53                   	push   %ebx
  8004b7:	ff 30                	pushl  (%eax)
  8004b9:	ff d6                	call   *%esi
			break;
  8004bb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004c1:	e9 04 ff ff ff       	jmp    8003ca <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c9:	8d 50 04             	lea    0x4(%eax),%edx
  8004cc:	89 55 14             	mov    %edx,0x14(%ebp)
  8004cf:	8b 00                	mov    (%eax),%eax
  8004d1:	99                   	cltd   
  8004d2:	31 d0                	xor    %edx,%eax
  8004d4:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004d6:	83 f8 0f             	cmp    $0xf,%eax
  8004d9:	7f 0b                	jg     8004e6 <vprintfmt+0x142>
  8004db:	8b 14 85 a0 2c 80 00 	mov    0x802ca0(,%eax,4),%edx
  8004e2:	85 d2                	test   %edx,%edx
  8004e4:	75 18                	jne    8004fe <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004e6:	50                   	push   %eax
  8004e7:	68 13 2a 80 00       	push   $0x802a13
  8004ec:	53                   	push   %ebx
  8004ed:	56                   	push   %esi
  8004ee:	e8 94 fe ff ff       	call   800387 <printfmt>
  8004f3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004f9:	e9 cc fe ff ff       	jmp    8003ca <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004fe:	52                   	push   %edx
  8004ff:	68 da 2d 80 00       	push   $0x802dda
  800504:	53                   	push   %ebx
  800505:	56                   	push   %esi
  800506:	e8 7c fe ff ff       	call   800387 <printfmt>
  80050b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800511:	e9 b4 fe ff ff       	jmp    8003ca <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800516:	8b 45 14             	mov    0x14(%ebp),%eax
  800519:	8d 50 04             	lea    0x4(%eax),%edx
  80051c:	89 55 14             	mov    %edx,0x14(%ebp)
  80051f:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800521:	85 ff                	test   %edi,%edi
  800523:	b8 0c 2a 80 00       	mov    $0x802a0c,%eax
  800528:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80052b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80052f:	0f 8e 94 00 00 00    	jle    8005c9 <vprintfmt+0x225>
  800535:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800539:	0f 84 98 00 00 00    	je     8005d7 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80053f:	83 ec 08             	sub    $0x8,%esp
  800542:	ff 75 d0             	pushl  -0x30(%ebp)
  800545:	57                   	push   %edi
  800546:	e8 86 02 00 00       	call   8007d1 <strnlen>
  80054b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80054e:	29 c1                	sub    %eax,%ecx
  800550:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800553:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800556:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80055a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80055d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800560:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800562:	eb 0f                	jmp    800573 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800564:	83 ec 08             	sub    $0x8,%esp
  800567:	53                   	push   %ebx
  800568:	ff 75 e0             	pushl  -0x20(%ebp)
  80056b:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80056d:	83 ef 01             	sub    $0x1,%edi
  800570:	83 c4 10             	add    $0x10,%esp
  800573:	85 ff                	test   %edi,%edi
  800575:	7f ed                	jg     800564 <vprintfmt+0x1c0>
  800577:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80057a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80057d:	85 c9                	test   %ecx,%ecx
  80057f:	b8 00 00 00 00       	mov    $0x0,%eax
  800584:	0f 49 c1             	cmovns %ecx,%eax
  800587:	29 c1                	sub    %eax,%ecx
  800589:	89 75 08             	mov    %esi,0x8(%ebp)
  80058c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80058f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800592:	89 cb                	mov    %ecx,%ebx
  800594:	eb 4d                	jmp    8005e3 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800596:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80059a:	74 1b                	je     8005b7 <vprintfmt+0x213>
  80059c:	0f be c0             	movsbl %al,%eax
  80059f:	83 e8 20             	sub    $0x20,%eax
  8005a2:	83 f8 5e             	cmp    $0x5e,%eax
  8005a5:	76 10                	jbe    8005b7 <vprintfmt+0x213>
					putch('?', putdat);
  8005a7:	83 ec 08             	sub    $0x8,%esp
  8005aa:	ff 75 0c             	pushl  0xc(%ebp)
  8005ad:	6a 3f                	push   $0x3f
  8005af:	ff 55 08             	call   *0x8(%ebp)
  8005b2:	83 c4 10             	add    $0x10,%esp
  8005b5:	eb 0d                	jmp    8005c4 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8005b7:	83 ec 08             	sub    $0x8,%esp
  8005ba:	ff 75 0c             	pushl  0xc(%ebp)
  8005bd:	52                   	push   %edx
  8005be:	ff 55 08             	call   *0x8(%ebp)
  8005c1:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005c4:	83 eb 01             	sub    $0x1,%ebx
  8005c7:	eb 1a                	jmp    8005e3 <vprintfmt+0x23f>
  8005c9:	89 75 08             	mov    %esi,0x8(%ebp)
  8005cc:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005cf:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005d2:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005d5:	eb 0c                	jmp    8005e3 <vprintfmt+0x23f>
  8005d7:	89 75 08             	mov    %esi,0x8(%ebp)
  8005da:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005dd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005e0:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005e3:	83 c7 01             	add    $0x1,%edi
  8005e6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005ea:	0f be d0             	movsbl %al,%edx
  8005ed:	85 d2                	test   %edx,%edx
  8005ef:	74 23                	je     800614 <vprintfmt+0x270>
  8005f1:	85 f6                	test   %esi,%esi
  8005f3:	78 a1                	js     800596 <vprintfmt+0x1f2>
  8005f5:	83 ee 01             	sub    $0x1,%esi
  8005f8:	79 9c                	jns    800596 <vprintfmt+0x1f2>
  8005fa:	89 df                	mov    %ebx,%edi
  8005fc:	8b 75 08             	mov    0x8(%ebp),%esi
  8005ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800602:	eb 18                	jmp    80061c <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800604:	83 ec 08             	sub    $0x8,%esp
  800607:	53                   	push   %ebx
  800608:	6a 20                	push   $0x20
  80060a:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80060c:	83 ef 01             	sub    $0x1,%edi
  80060f:	83 c4 10             	add    $0x10,%esp
  800612:	eb 08                	jmp    80061c <vprintfmt+0x278>
  800614:	89 df                	mov    %ebx,%edi
  800616:	8b 75 08             	mov    0x8(%ebp),%esi
  800619:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80061c:	85 ff                	test   %edi,%edi
  80061e:	7f e4                	jg     800604 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800620:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800623:	e9 a2 fd ff ff       	jmp    8003ca <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800628:	83 fa 01             	cmp    $0x1,%edx
  80062b:	7e 16                	jle    800643 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80062d:	8b 45 14             	mov    0x14(%ebp),%eax
  800630:	8d 50 08             	lea    0x8(%eax),%edx
  800633:	89 55 14             	mov    %edx,0x14(%ebp)
  800636:	8b 50 04             	mov    0x4(%eax),%edx
  800639:	8b 00                	mov    (%eax),%eax
  80063b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80063e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800641:	eb 32                	jmp    800675 <vprintfmt+0x2d1>
	else if (lflag)
  800643:	85 d2                	test   %edx,%edx
  800645:	74 18                	je     80065f <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800647:	8b 45 14             	mov    0x14(%ebp),%eax
  80064a:	8d 50 04             	lea    0x4(%eax),%edx
  80064d:	89 55 14             	mov    %edx,0x14(%ebp)
  800650:	8b 00                	mov    (%eax),%eax
  800652:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800655:	89 c1                	mov    %eax,%ecx
  800657:	c1 f9 1f             	sar    $0x1f,%ecx
  80065a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80065d:	eb 16                	jmp    800675 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80065f:	8b 45 14             	mov    0x14(%ebp),%eax
  800662:	8d 50 04             	lea    0x4(%eax),%edx
  800665:	89 55 14             	mov    %edx,0x14(%ebp)
  800668:	8b 00                	mov    (%eax),%eax
  80066a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80066d:	89 c1                	mov    %eax,%ecx
  80066f:	c1 f9 1f             	sar    $0x1f,%ecx
  800672:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800675:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800678:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80067b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800680:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800684:	79 74                	jns    8006fa <vprintfmt+0x356>
				putch('-', putdat);
  800686:	83 ec 08             	sub    $0x8,%esp
  800689:	53                   	push   %ebx
  80068a:	6a 2d                	push   $0x2d
  80068c:	ff d6                	call   *%esi
				num = -(long long) num;
  80068e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800691:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800694:	f7 d8                	neg    %eax
  800696:	83 d2 00             	adc    $0x0,%edx
  800699:	f7 da                	neg    %edx
  80069b:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80069e:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006a3:	eb 55                	jmp    8006fa <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006a5:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a8:	e8 83 fc ff ff       	call   800330 <getuint>
			base = 10;
  8006ad:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006b2:	eb 46                	jmp    8006fa <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8006b4:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b7:	e8 74 fc ff ff       	call   800330 <getuint>
                        base = 8;
  8006bc:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  8006c1:	eb 37                	jmp    8006fa <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8006c3:	83 ec 08             	sub    $0x8,%esp
  8006c6:	53                   	push   %ebx
  8006c7:	6a 30                	push   $0x30
  8006c9:	ff d6                	call   *%esi
			putch('x', putdat);
  8006cb:	83 c4 08             	add    $0x8,%esp
  8006ce:	53                   	push   %ebx
  8006cf:	6a 78                	push   $0x78
  8006d1:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d6:	8d 50 04             	lea    0x4(%eax),%edx
  8006d9:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006dc:	8b 00                	mov    (%eax),%eax
  8006de:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006e3:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006e6:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006eb:	eb 0d                	jmp    8006fa <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006ed:	8d 45 14             	lea    0x14(%ebp),%eax
  8006f0:	e8 3b fc ff ff       	call   800330 <getuint>
			base = 16;
  8006f5:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006fa:	83 ec 0c             	sub    $0xc,%esp
  8006fd:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800701:	57                   	push   %edi
  800702:	ff 75 e0             	pushl  -0x20(%ebp)
  800705:	51                   	push   %ecx
  800706:	52                   	push   %edx
  800707:	50                   	push   %eax
  800708:	89 da                	mov    %ebx,%edx
  80070a:	89 f0                	mov    %esi,%eax
  80070c:	e8 70 fb ff ff       	call   800281 <printnum>
			break;
  800711:	83 c4 20             	add    $0x20,%esp
  800714:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800717:	e9 ae fc ff ff       	jmp    8003ca <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80071c:	83 ec 08             	sub    $0x8,%esp
  80071f:	53                   	push   %ebx
  800720:	51                   	push   %ecx
  800721:	ff d6                	call   *%esi
			break;
  800723:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800726:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800729:	e9 9c fc ff ff       	jmp    8003ca <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80072e:	83 ec 08             	sub    $0x8,%esp
  800731:	53                   	push   %ebx
  800732:	6a 25                	push   $0x25
  800734:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800736:	83 c4 10             	add    $0x10,%esp
  800739:	eb 03                	jmp    80073e <vprintfmt+0x39a>
  80073b:	83 ef 01             	sub    $0x1,%edi
  80073e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800742:	75 f7                	jne    80073b <vprintfmt+0x397>
  800744:	e9 81 fc ff ff       	jmp    8003ca <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800749:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80074c:	5b                   	pop    %ebx
  80074d:	5e                   	pop    %esi
  80074e:	5f                   	pop    %edi
  80074f:	5d                   	pop    %ebp
  800750:	c3                   	ret    

00800751 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800751:	55                   	push   %ebp
  800752:	89 e5                	mov    %esp,%ebp
  800754:	83 ec 18             	sub    $0x18,%esp
  800757:	8b 45 08             	mov    0x8(%ebp),%eax
  80075a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80075d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800760:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800764:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800767:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80076e:	85 c0                	test   %eax,%eax
  800770:	74 26                	je     800798 <vsnprintf+0x47>
  800772:	85 d2                	test   %edx,%edx
  800774:	7e 22                	jle    800798 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800776:	ff 75 14             	pushl  0x14(%ebp)
  800779:	ff 75 10             	pushl  0x10(%ebp)
  80077c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80077f:	50                   	push   %eax
  800780:	68 6a 03 80 00       	push   $0x80036a
  800785:	e8 1a fc ff ff       	call   8003a4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80078a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80078d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800790:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800793:	83 c4 10             	add    $0x10,%esp
  800796:	eb 05                	jmp    80079d <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800798:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80079d:	c9                   	leave  
  80079e:	c3                   	ret    

0080079f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80079f:	55                   	push   %ebp
  8007a0:	89 e5                	mov    %esp,%ebp
  8007a2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007a5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007a8:	50                   	push   %eax
  8007a9:	ff 75 10             	pushl  0x10(%ebp)
  8007ac:	ff 75 0c             	pushl  0xc(%ebp)
  8007af:	ff 75 08             	pushl  0x8(%ebp)
  8007b2:	e8 9a ff ff ff       	call   800751 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007b7:	c9                   	leave  
  8007b8:	c3                   	ret    

008007b9 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007b9:	55                   	push   %ebp
  8007ba:	89 e5                	mov    %esp,%ebp
  8007bc:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c4:	eb 03                	jmp    8007c9 <strlen+0x10>
		n++;
  8007c6:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007cd:	75 f7                	jne    8007c6 <strlen+0xd>
		n++;
	return n;
}
  8007cf:	5d                   	pop    %ebp
  8007d0:	c3                   	ret    

008007d1 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007d1:	55                   	push   %ebp
  8007d2:	89 e5                	mov    %esp,%ebp
  8007d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007d7:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007da:	ba 00 00 00 00       	mov    $0x0,%edx
  8007df:	eb 03                	jmp    8007e4 <strnlen+0x13>
		n++;
  8007e1:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e4:	39 c2                	cmp    %eax,%edx
  8007e6:	74 08                	je     8007f0 <strnlen+0x1f>
  8007e8:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007ec:	75 f3                	jne    8007e1 <strnlen+0x10>
  8007ee:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007f0:	5d                   	pop    %ebp
  8007f1:	c3                   	ret    

008007f2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007f2:	55                   	push   %ebp
  8007f3:	89 e5                	mov    %esp,%ebp
  8007f5:	53                   	push   %ebx
  8007f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007fc:	89 c2                	mov    %eax,%edx
  8007fe:	83 c2 01             	add    $0x1,%edx
  800801:	83 c1 01             	add    $0x1,%ecx
  800804:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800808:	88 5a ff             	mov    %bl,-0x1(%edx)
  80080b:	84 db                	test   %bl,%bl
  80080d:	75 ef                	jne    8007fe <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80080f:	5b                   	pop    %ebx
  800810:	5d                   	pop    %ebp
  800811:	c3                   	ret    

00800812 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800812:	55                   	push   %ebp
  800813:	89 e5                	mov    %esp,%ebp
  800815:	53                   	push   %ebx
  800816:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800819:	53                   	push   %ebx
  80081a:	e8 9a ff ff ff       	call   8007b9 <strlen>
  80081f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800822:	ff 75 0c             	pushl  0xc(%ebp)
  800825:	01 d8                	add    %ebx,%eax
  800827:	50                   	push   %eax
  800828:	e8 c5 ff ff ff       	call   8007f2 <strcpy>
	return dst;
}
  80082d:	89 d8                	mov    %ebx,%eax
  80082f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800832:	c9                   	leave  
  800833:	c3                   	ret    

00800834 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800834:	55                   	push   %ebp
  800835:	89 e5                	mov    %esp,%ebp
  800837:	56                   	push   %esi
  800838:	53                   	push   %ebx
  800839:	8b 75 08             	mov    0x8(%ebp),%esi
  80083c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80083f:	89 f3                	mov    %esi,%ebx
  800841:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800844:	89 f2                	mov    %esi,%edx
  800846:	eb 0f                	jmp    800857 <strncpy+0x23>
		*dst++ = *src;
  800848:	83 c2 01             	add    $0x1,%edx
  80084b:	0f b6 01             	movzbl (%ecx),%eax
  80084e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800851:	80 39 01             	cmpb   $0x1,(%ecx)
  800854:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800857:	39 da                	cmp    %ebx,%edx
  800859:	75 ed                	jne    800848 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80085b:	89 f0                	mov    %esi,%eax
  80085d:	5b                   	pop    %ebx
  80085e:	5e                   	pop    %esi
  80085f:	5d                   	pop    %ebp
  800860:	c3                   	ret    

00800861 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800861:	55                   	push   %ebp
  800862:	89 e5                	mov    %esp,%ebp
  800864:	56                   	push   %esi
  800865:	53                   	push   %ebx
  800866:	8b 75 08             	mov    0x8(%ebp),%esi
  800869:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80086c:	8b 55 10             	mov    0x10(%ebp),%edx
  80086f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800871:	85 d2                	test   %edx,%edx
  800873:	74 21                	je     800896 <strlcpy+0x35>
  800875:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800879:	89 f2                	mov    %esi,%edx
  80087b:	eb 09                	jmp    800886 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80087d:	83 c2 01             	add    $0x1,%edx
  800880:	83 c1 01             	add    $0x1,%ecx
  800883:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800886:	39 c2                	cmp    %eax,%edx
  800888:	74 09                	je     800893 <strlcpy+0x32>
  80088a:	0f b6 19             	movzbl (%ecx),%ebx
  80088d:	84 db                	test   %bl,%bl
  80088f:	75 ec                	jne    80087d <strlcpy+0x1c>
  800891:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800893:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800896:	29 f0                	sub    %esi,%eax
}
  800898:	5b                   	pop    %ebx
  800899:	5e                   	pop    %esi
  80089a:	5d                   	pop    %ebp
  80089b:	c3                   	ret    

0080089c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80089c:	55                   	push   %ebp
  80089d:	89 e5                	mov    %esp,%ebp
  80089f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008a5:	eb 06                	jmp    8008ad <strcmp+0x11>
		p++, q++;
  8008a7:	83 c1 01             	add    $0x1,%ecx
  8008aa:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008ad:	0f b6 01             	movzbl (%ecx),%eax
  8008b0:	84 c0                	test   %al,%al
  8008b2:	74 04                	je     8008b8 <strcmp+0x1c>
  8008b4:	3a 02                	cmp    (%edx),%al
  8008b6:	74 ef                	je     8008a7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b8:	0f b6 c0             	movzbl %al,%eax
  8008bb:	0f b6 12             	movzbl (%edx),%edx
  8008be:	29 d0                	sub    %edx,%eax
}
  8008c0:	5d                   	pop    %ebp
  8008c1:	c3                   	ret    

008008c2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	53                   	push   %ebx
  8008c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008cc:	89 c3                	mov    %eax,%ebx
  8008ce:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008d1:	eb 06                	jmp    8008d9 <strncmp+0x17>
		n--, p++, q++;
  8008d3:	83 c0 01             	add    $0x1,%eax
  8008d6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008d9:	39 d8                	cmp    %ebx,%eax
  8008db:	74 15                	je     8008f2 <strncmp+0x30>
  8008dd:	0f b6 08             	movzbl (%eax),%ecx
  8008e0:	84 c9                	test   %cl,%cl
  8008e2:	74 04                	je     8008e8 <strncmp+0x26>
  8008e4:	3a 0a                	cmp    (%edx),%cl
  8008e6:	74 eb                	je     8008d3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e8:	0f b6 00             	movzbl (%eax),%eax
  8008eb:	0f b6 12             	movzbl (%edx),%edx
  8008ee:	29 d0                	sub    %edx,%eax
  8008f0:	eb 05                	jmp    8008f7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008f2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008f7:	5b                   	pop    %ebx
  8008f8:	5d                   	pop    %ebp
  8008f9:	c3                   	ret    

008008fa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800900:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800904:	eb 07                	jmp    80090d <strchr+0x13>
		if (*s == c)
  800906:	38 ca                	cmp    %cl,%dl
  800908:	74 0f                	je     800919 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80090a:	83 c0 01             	add    $0x1,%eax
  80090d:	0f b6 10             	movzbl (%eax),%edx
  800910:	84 d2                	test   %dl,%dl
  800912:	75 f2                	jne    800906 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800914:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800919:	5d                   	pop    %ebp
  80091a:	c3                   	ret    

0080091b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80091b:	55                   	push   %ebp
  80091c:	89 e5                	mov    %esp,%ebp
  80091e:	8b 45 08             	mov    0x8(%ebp),%eax
  800921:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800925:	eb 03                	jmp    80092a <strfind+0xf>
  800927:	83 c0 01             	add    $0x1,%eax
  80092a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80092d:	38 ca                	cmp    %cl,%dl
  80092f:	74 04                	je     800935 <strfind+0x1a>
  800931:	84 d2                	test   %dl,%dl
  800933:	75 f2                	jne    800927 <strfind+0xc>
			break;
	return (char *) s;
}
  800935:	5d                   	pop    %ebp
  800936:	c3                   	ret    

00800937 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800937:	55                   	push   %ebp
  800938:	89 e5                	mov    %esp,%ebp
  80093a:	57                   	push   %edi
  80093b:	56                   	push   %esi
  80093c:	53                   	push   %ebx
  80093d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800940:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800943:	85 c9                	test   %ecx,%ecx
  800945:	74 36                	je     80097d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800947:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80094d:	75 28                	jne    800977 <memset+0x40>
  80094f:	f6 c1 03             	test   $0x3,%cl
  800952:	75 23                	jne    800977 <memset+0x40>
		c &= 0xFF;
  800954:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800958:	89 d3                	mov    %edx,%ebx
  80095a:	c1 e3 08             	shl    $0x8,%ebx
  80095d:	89 d6                	mov    %edx,%esi
  80095f:	c1 e6 18             	shl    $0x18,%esi
  800962:	89 d0                	mov    %edx,%eax
  800964:	c1 e0 10             	shl    $0x10,%eax
  800967:	09 f0                	or     %esi,%eax
  800969:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80096b:	89 d8                	mov    %ebx,%eax
  80096d:	09 d0                	or     %edx,%eax
  80096f:	c1 e9 02             	shr    $0x2,%ecx
  800972:	fc                   	cld    
  800973:	f3 ab                	rep stos %eax,%es:(%edi)
  800975:	eb 06                	jmp    80097d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800977:	8b 45 0c             	mov    0xc(%ebp),%eax
  80097a:	fc                   	cld    
  80097b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80097d:	89 f8                	mov    %edi,%eax
  80097f:	5b                   	pop    %ebx
  800980:	5e                   	pop    %esi
  800981:	5f                   	pop    %edi
  800982:	5d                   	pop    %ebp
  800983:	c3                   	ret    

00800984 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800984:	55                   	push   %ebp
  800985:	89 e5                	mov    %esp,%ebp
  800987:	57                   	push   %edi
  800988:	56                   	push   %esi
  800989:	8b 45 08             	mov    0x8(%ebp),%eax
  80098c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80098f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800992:	39 c6                	cmp    %eax,%esi
  800994:	73 35                	jae    8009cb <memmove+0x47>
  800996:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800999:	39 d0                	cmp    %edx,%eax
  80099b:	73 2e                	jae    8009cb <memmove+0x47>
		s += n;
		d += n;
  80099d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a0:	89 d6                	mov    %edx,%esi
  8009a2:	09 fe                	or     %edi,%esi
  8009a4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009aa:	75 13                	jne    8009bf <memmove+0x3b>
  8009ac:	f6 c1 03             	test   $0x3,%cl
  8009af:	75 0e                	jne    8009bf <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009b1:	83 ef 04             	sub    $0x4,%edi
  8009b4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009b7:	c1 e9 02             	shr    $0x2,%ecx
  8009ba:	fd                   	std    
  8009bb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009bd:	eb 09                	jmp    8009c8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009bf:	83 ef 01             	sub    $0x1,%edi
  8009c2:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009c5:	fd                   	std    
  8009c6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009c8:	fc                   	cld    
  8009c9:	eb 1d                	jmp    8009e8 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009cb:	89 f2                	mov    %esi,%edx
  8009cd:	09 c2                	or     %eax,%edx
  8009cf:	f6 c2 03             	test   $0x3,%dl
  8009d2:	75 0f                	jne    8009e3 <memmove+0x5f>
  8009d4:	f6 c1 03             	test   $0x3,%cl
  8009d7:	75 0a                	jne    8009e3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009d9:	c1 e9 02             	shr    $0x2,%ecx
  8009dc:	89 c7                	mov    %eax,%edi
  8009de:	fc                   	cld    
  8009df:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e1:	eb 05                	jmp    8009e8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009e3:	89 c7                	mov    %eax,%edi
  8009e5:	fc                   	cld    
  8009e6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009e8:	5e                   	pop    %esi
  8009e9:	5f                   	pop    %edi
  8009ea:	5d                   	pop    %ebp
  8009eb:	c3                   	ret    

008009ec <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ec:	55                   	push   %ebp
  8009ed:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009ef:	ff 75 10             	pushl  0x10(%ebp)
  8009f2:	ff 75 0c             	pushl  0xc(%ebp)
  8009f5:	ff 75 08             	pushl  0x8(%ebp)
  8009f8:	e8 87 ff ff ff       	call   800984 <memmove>
}
  8009fd:	c9                   	leave  
  8009fe:	c3                   	ret    

008009ff <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009ff:	55                   	push   %ebp
  800a00:	89 e5                	mov    %esp,%ebp
  800a02:	56                   	push   %esi
  800a03:	53                   	push   %ebx
  800a04:	8b 45 08             	mov    0x8(%ebp),%eax
  800a07:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a0a:	89 c6                	mov    %eax,%esi
  800a0c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a0f:	eb 1a                	jmp    800a2b <memcmp+0x2c>
		if (*s1 != *s2)
  800a11:	0f b6 08             	movzbl (%eax),%ecx
  800a14:	0f b6 1a             	movzbl (%edx),%ebx
  800a17:	38 d9                	cmp    %bl,%cl
  800a19:	74 0a                	je     800a25 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a1b:	0f b6 c1             	movzbl %cl,%eax
  800a1e:	0f b6 db             	movzbl %bl,%ebx
  800a21:	29 d8                	sub    %ebx,%eax
  800a23:	eb 0f                	jmp    800a34 <memcmp+0x35>
		s1++, s2++;
  800a25:	83 c0 01             	add    $0x1,%eax
  800a28:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a2b:	39 f0                	cmp    %esi,%eax
  800a2d:	75 e2                	jne    800a11 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a2f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a34:	5b                   	pop    %ebx
  800a35:	5e                   	pop    %esi
  800a36:	5d                   	pop    %ebp
  800a37:	c3                   	ret    

00800a38 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a38:	55                   	push   %ebp
  800a39:	89 e5                	mov    %esp,%ebp
  800a3b:	53                   	push   %ebx
  800a3c:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a3f:	89 c1                	mov    %eax,%ecx
  800a41:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a44:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a48:	eb 0a                	jmp    800a54 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a4a:	0f b6 10             	movzbl (%eax),%edx
  800a4d:	39 da                	cmp    %ebx,%edx
  800a4f:	74 07                	je     800a58 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a51:	83 c0 01             	add    $0x1,%eax
  800a54:	39 c8                	cmp    %ecx,%eax
  800a56:	72 f2                	jb     800a4a <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a58:	5b                   	pop    %ebx
  800a59:	5d                   	pop    %ebp
  800a5a:	c3                   	ret    

00800a5b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a5b:	55                   	push   %ebp
  800a5c:	89 e5                	mov    %esp,%ebp
  800a5e:	57                   	push   %edi
  800a5f:	56                   	push   %esi
  800a60:	53                   	push   %ebx
  800a61:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a64:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a67:	eb 03                	jmp    800a6c <strtol+0x11>
		s++;
  800a69:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a6c:	0f b6 01             	movzbl (%ecx),%eax
  800a6f:	3c 20                	cmp    $0x20,%al
  800a71:	74 f6                	je     800a69 <strtol+0xe>
  800a73:	3c 09                	cmp    $0x9,%al
  800a75:	74 f2                	je     800a69 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a77:	3c 2b                	cmp    $0x2b,%al
  800a79:	75 0a                	jne    800a85 <strtol+0x2a>
		s++;
  800a7b:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a7e:	bf 00 00 00 00       	mov    $0x0,%edi
  800a83:	eb 11                	jmp    800a96 <strtol+0x3b>
  800a85:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a8a:	3c 2d                	cmp    $0x2d,%al
  800a8c:	75 08                	jne    800a96 <strtol+0x3b>
		s++, neg = 1;
  800a8e:	83 c1 01             	add    $0x1,%ecx
  800a91:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a96:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a9c:	75 15                	jne    800ab3 <strtol+0x58>
  800a9e:	80 39 30             	cmpb   $0x30,(%ecx)
  800aa1:	75 10                	jne    800ab3 <strtol+0x58>
  800aa3:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800aa7:	75 7c                	jne    800b25 <strtol+0xca>
		s += 2, base = 16;
  800aa9:	83 c1 02             	add    $0x2,%ecx
  800aac:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ab1:	eb 16                	jmp    800ac9 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800ab3:	85 db                	test   %ebx,%ebx
  800ab5:	75 12                	jne    800ac9 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ab7:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800abc:	80 39 30             	cmpb   $0x30,(%ecx)
  800abf:	75 08                	jne    800ac9 <strtol+0x6e>
		s++, base = 8;
  800ac1:	83 c1 01             	add    $0x1,%ecx
  800ac4:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ac9:	b8 00 00 00 00       	mov    $0x0,%eax
  800ace:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ad1:	0f b6 11             	movzbl (%ecx),%edx
  800ad4:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ad7:	89 f3                	mov    %esi,%ebx
  800ad9:	80 fb 09             	cmp    $0x9,%bl
  800adc:	77 08                	ja     800ae6 <strtol+0x8b>
			dig = *s - '0';
  800ade:	0f be d2             	movsbl %dl,%edx
  800ae1:	83 ea 30             	sub    $0x30,%edx
  800ae4:	eb 22                	jmp    800b08 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ae6:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ae9:	89 f3                	mov    %esi,%ebx
  800aeb:	80 fb 19             	cmp    $0x19,%bl
  800aee:	77 08                	ja     800af8 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800af0:	0f be d2             	movsbl %dl,%edx
  800af3:	83 ea 57             	sub    $0x57,%edx
  800af6:	eb 10                	jmp    800b08 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800af8:	8d 72 bf             	lea    -0x41(%edx),%esi
  800afb:	89 f3                	mov    %esi,%ebx
  800afd:	80 fb 19             	cmp    $0x19,%bl
  800b00:	77 16                	ja     800b18 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b02:	0f be d2             	movsbl %dl,%edx
  800b05:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b08:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b0b:	7d 0b                	jge    800b18 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b0d:	83 c1 01             	add    $0x1,%ecx
  800b10:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b14:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b16:	eb b9                	jmp    800ad1 <strtol+0x76>

	if (endptr)
  800b18:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b1c:	74 0d                	je     800b2b <strtol+0xd0>
		*endptr = (char *) s;
  800b1e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b21:	89 0e                	mov    %ecx,(%esi)
  800b23:	eb 06                	jmp    800b2b <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b25:	85 db                	test   %ebx,%ebx
  800b27:	74 98                	je     800ac1 <strtol+0x66>
  800b29:	eb 9e                	jmp    800ac9 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b2b:	89 c2                	mov    %eax,%edx
  800b2d:	f7 da                	neg    %edx
  800b2f:	85 ff                	test   %edi,%edi
  800b31:	0f 45 c2             	cmovne %edx,%eax
}
  800b34:	5b                   	pop    %ebx
  800b35:	5e                   	pop    %esi
  800b36:	5f                   	pop    %edi
  800b37:	5d                   	pop    %ebp
  800b38:	c3                   	ret    

00800b39 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b39:	55                   	push   %ebp
  800b3a:	89 e5                	mov    %esp,%ebp
  800b3c:	57                   	push   %edi
  800b3d:	56                   	push   %esi
  800b3e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3f:	b8 00 00 00 00       	mov    $0x0,%eax
  800b44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b47:	8b 55 08             	mov    0x8(%ebp),%edx
  800b4a:	89 c3                	mov    %eax,%ebx
  800b4c:	89 c7                	mov    %eax,%edi
  800b4e:	89 c6                	mov    %eax,%esi
  800b50:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b52:	5b                   	pop    %ebx
  800b53:	5e                   	pop    %esi
  800b54:	5f                   	pop    %edi
  800b55:	5d                   	pop    %ebp
  800b56:	c3                   	ret    

00800b57 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b57:	55                   	push   %ebp
  800b58:	89 e5                	mov    %esp,%ebp
  800b5a:	57                   	push   %edi
  800b5b:	56                   	push   %esi
  800b5c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b62:	b8 01 00 00 00       	mov    $0x1,%eax
  800b67:	89 d1                	mov    %edx,%ecx
  800b69:	89 d3                	mov    %edx,%ebx
  800b6b:	89 d7                	mov    %edx,%edi
  800b6d:	89 d6                	mov    %edx,%esi
  800b6f:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b71:	5b                   	pop    %ebx
  800b72:	5e                   	pop    %esi
  800b73:	5f                   	pop    %edi
  800b74:	5d                   	pop    %ebp
  800b75:	c3                   	ret    

00800b76 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b76:	55                   	push   %ebp
  800b77:	89 e5                	mov    %esp,%ebp
  800b79:	57                   	push   %edi
  800b7a:	56                   	push   %esi
  800b7b:	53                   	push   %ebx
  800b7c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b84:	b8 03 00 00 00       	mov    $0x3,%eax
  800b89:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8c:	89 cb                	mov    %ecx,%ebx
  800b8e:	89 cf                	mov    %ecx,%edi
  800b90:	89 ce                	mov    %ecx,%esi
  800b92:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b94:	85 c0                	test   %eax,%eax
  800b96:	7e 17                	jle    800baf <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b98:	83 ec 0c             	sub    $0xc,%esp
  800b9b:	50                   	push   %eax
  800b9c:	6a 03                	push   $0x3
  800b9e:	68 ff 2c 80 00       	push   $0x802cff
  800ba3:	6a 23                	push   $0x23
  800ba5:	68 1c 2d 80 00       	push   $0x802d1c
  800baa:	e8 e5 f5 ff ff       	call   800194 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800baf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb2:	5b                   	pop    %ebx
  800bb3:	5e                   	pop    %esi
  800bb4:	5f                   	pop    %edi
  800bb5:	5d                   	pop    %ebp
  800bb6:	c3                   	ret    

00800bb7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bb7:	55                   	push   %ebp
  800bb8:	89 e5                	mov    %esp,%ebp
  800bba:	57                   	push   %edi
  800bbb:	56                   	push   %esi
  800bbc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bbd:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc2:	b8 02 00 00 00       	mov    $0x2,%eax
  800bc7:	89 d1                	mov    %edx,%ecx
  800bc9:	89 d3                	mov    %edx,%ebx
  800bcb:	89 d7                	mov    %edx,%edi
  800bcd:	89 d6                	mov    %edx,%esi
  800bcf:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bd1:	5b                   	pop    %ebx
  800bd2:	5e                   	pop    %esi
  800bd3:	5f                   	pop    %edi
  800bd4:	5d                   	pop    %ebp
  800bd5:	c3                   	ret    

00800bd6 <sys_yield>:

void
sys_yield(void)
{
  800bd6:	55                   	push   %ebp
  800bd7:	89 e5                	mov    %esp,%ebp
  800bd9:	57                   	push   %edi
  800bda:	56                   	push   %esi
  800bdb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bdc:	ba 00 00 00 00       	mov    $0x0,%edx
  800be1:	b8 0b 00 00 00       	mov    $0xb,%eax
  800be6:	89 d1                	mov    %edx,%ecx
  800be8:	89 d3                	mov    %edx,%ebx
  800bea:	89 d7                	mov    %edx,%edi
  800bec:	89 d6                	mov    %edx,%esi
  800bee:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bf0:	5b                   	pop    %ebx
  800bf1:	5e                   	pop    %esi
  800bf2:	5f                   	pop    %edi
  800bf3:	5d                   	pop    %ebp
  800bf4:	c3                   	ret    

00800bf5 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	57                   	push   %edi
  800bf9:	56                   	push   %esi
  800bfa:	53                   	push   %ebx
  800bfb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfe:	be 00 00 00 00       	mov    $0x0,%esi
  800c03:	b8 04 00 00 00       	mov    $0x4,%eax
  800c08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c11:	89 f7                	mov    %esi,%edi
  800c13:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c15:	85 c0                	test   %eax,%eax
  800c17:	7e 17                	jle    800c30 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c19:	83 ec 0c             	sub    $0xc,%esp
  800c1c:	50                   	push   %eax
  800c1d:	6a 04                	push   $0x4
  800c1f:	68 ff 2c 80 00       	push   $0x802cff
  800c24:	6a 23                	push   $0x23
  800c26:	68 1c 2d 80 00       	push   $0x802d1c
  800c2b:	e8 64 f5 ff ff       	call   800194 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c30:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c33:	5b                   	pop    %ebx
  800c34:	5e                   	pop    %esi
  800c35:	5f                   	pop    %edi
  800c36:	5d                   	pop    %ebp
  800c37:	c3                   	ret    

00800c38 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c38:	55                   	push   %ebp
  800c39:	89 e5                	mov    %esp,%ebp
  800c3b:	57                   	push   %edi
  800c3c:	56                   	push   %esi
  800c3d:	53                   	push   %ebx
  800c3e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c41:	b8 05 00 00 00       	mov    $0x5,%eax
  800c46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c49:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c4f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c52:	8b 75 18             	mov    0x18(%ebp),%esi
  800c55:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c57:	85 c0                	test   %eax,%eax
  800c59:	7e 17                	jle    800c72 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5b:	83 ec 0c             	sub    $0xc,%esp
  800c5e:	50                   	push   %eax
  800c5f:	6a 05                	push   $0x5
  800c61:	68 ff 2c 80 00       	push   $0x802cff
  800c66:	6a 23                	push   $0x23
  800c68:	68 1c 2d 80 00       	push   $0x802d1c
  800c6d:	e8 22 f5 ff ff       	call   800194 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c72:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c75:	5b                   	pop    %ebx
  800c76:	5e                   	pop    %esi
  800c77:	5f                   	pop    %edi
  800c78:	5d                   	pop    %ebp
  800c79:	c3                   	ret    

00800c7a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
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
  800c83:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c88:	b8 06 00 00 00       	mov    $0x6,%eax
  800c8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c90:	8b 55 08             	mov    0x8(%ebp),%edx
  800c93:	89 df                	mov    %ebx,%edi
  800c95:	89 de                	mov    %ebx,%esi
  800c97:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c99:	85 c0                	test   %eax,%eax
  800c9b:	7e 17                	jle    800cb4 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9d:	83 ec 0c             	sub    $0xc,%esp
  800ca0:	50                   	push   %eax
  800ca1:	6a 06                	push   $0x6
  800ca3:	68 ff 2c 80 00       	push   $0x802cff
  800ca8:	6a 23                	push   $0x23
  800caa:	68 1c 2d 80 00       	push   $0x802d1c
  800caf:	e8 e0 f4 ff ff       	call   800194 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cb4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb7:	5b                   	pop    %ebx
  800cb8:	5e                   	pop    %esi
  800cb9:	5f                   	pop    %edi
  800cba:	5d                   	pop    %ebp
  800cbb:	c3                   	ret    

00800cbc <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  800cc5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cca:	b8 08 00 00 00       	mov    $0x8,%eax
  800ccf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd5:	89 df                	mov    %ebx,%edi
  800cd7:	89 de                	mov    %ebx,%esi
  800cd9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cdb:	85 c0                	test   %eax,%eax
  800cdd:	7e 17                	jle    800cf6 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cdf:	83 ec 0c             	sub    $0xc,%esp
  800ce2:	50                   	push   %eax
  800ce3:	6a 08                	push   $0x8
  800ce5:	68 ff 2c 80 00       	push   $0x802cff
  800cea:	6a 23                	push   $0x23
  800cec:	68 1c 2d 80 00       	push   $0x802d1c
  800cf1:	e8 9e f4 ff ff       	call   800194 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cf6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf9:	5b                   	pop    %ebx
  800cfa:	5e                   	pop    %esi
  800cfb:	5f                   	pop    %edi
  800cfc:	5d                   	pop    %ebp
  800cfd:	c3                   	ret    

00800cfe <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
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
  800d0c:	b8 09 00 00 00       	mov    $0x9,%eax
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
  800d1f:	7e 17                	jle    800d38 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d21:	83 ec 0c             	sub    $0xc,%esp
  800d24:	50                   	push   %eax
  800d25:	6a 09                	push   $0x9
  800d27:	68 ff 2c 80 00       	push   $0x802cff
  800d2c:	6a 23                	push   $0x23
  800d2e:	68 1c 2d 80 00       	push   $0x802d1c
  800d33:	e8 5c f4 ff ff       	call   800194 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d38:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3b:	5b                   	pop    %ebx
  800d3c:	5e                   	pop    %esi
  800d3d:	5f                   	pop    %edi
  800d3e:	5d                   	pop    %ebp
  800d3f:	c3                   	ret    

00800d40 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
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
  800d4e:	b8 0a 00 00 00       	mov    $0xa,%eax
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
  800d61:	7e 17                	jle    800d7a <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d63:	83 ec 0c             	sub    $0xc,%esp
  800d66:	50                   	push   %eax
  800d67:	6a 0a                	push   $0xa
  800d69:	68 ff 2c 80 00       	push   $0x802cff
  800d6e:	6a 23                	push   $0x23
  800d70:	68 1c 2d 80 00       	push   $0x802d1c
  800d75:	e8 1a f4 ff ff       	call   800194 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7d:	5b                   	pop    %ebx
  800d7e:	5e                   	pop    %esi
  800d7f:	5f                   	pop    %edi
  800d80:	5d                   	pop    %ebp
  800d81:	c3                   	ret    

00800d82 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d82:	55                   	push   %ebp
  800d83:	89 e5                	mov    %esp,%ebp
  800d85:	57                   	push   %edi
  800d86:	56                   	push   %esi
  800d87:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d88:	be 00 00 00 00       	mov    $0x0,%esi
  800d8d:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d95:	8b 55 08             	mov    0x8(%ebp),%edx
  800d98:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d9b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d9e:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800da0:	5b                   	pop    %ebx
  800da1:	5e                   	pop    %esi
  800da2:	5f                   	pop    %edi
  800da3:	5d                   	pop    %ebp
  800da4:	c3                   	ret    

00800da5 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800da5:	55                   	push   %ebp
  800da6:	89 e5                	mov    %esp,%ebp
  800da8:	57                   	push   %edi
  800da9:	56                   	push   %esi
  800daa:	53                   	push   %ebx
  800dab:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dae:	b9 00 00 00 00       	mov    $0x0,%ecx
  800db3:	b8 0d 00 00 00       	mov    $0xd,%eax
  800db8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbb:	89 cb                	mov    %ecx,%ebx
  800dbd:	89 cf                	mov    %ecx,%edi
  800dbf:	89 ce                	mov    %ecx,%esi
  800dc1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dc3:	85 c0                	test   %eax,%eax
  800dc5:	7e 17                	jle    800dde <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc7:	83 ec 0c             	sub    $0xc,%esp
  800dca:	50                   	push   %eax
  800dcb:	6a 0d                	push   $0xd
  800dcd:	68 ff 2c 80 00       	push   $0x802cff
  800dd2:	6a 23                	push   $0x23
  800dd4:	68 1c 2d 80 00       	push   $0x802d1c
  800dd9:	e8 b6 f3 ff ff       	call   800194 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dde:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de1:	5b                   	pop    %ebx
  800de2:	5e                   	pop    %esi
  800de3:	5f                   	pop    %edi
  800de4:	5d                   	pop    %ebp
  800de5:	c3                   	ret    

00800de6 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800de6:	55                   	push   %ebp
  800de7:	89 e5                	mov    %esp,%ebp
  800de9:	57                   	push   %edi
  800dea:	56                   	push   %esi
  800deb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dec:	ba 00 00 00 00       	mov    $0x0,%edx
  800df1:	b8 0e 00 00 00       	mov    $0xe,%eax
  800df6:	89 d1                	mov    %edx,%ecx
  800df8:	89 d3                	mov    %edx,%ebx
  800dfa:	89 d7                	mov    %edx,%edi
  800dfc:	89 d6                	mov    %edx,%esi
  800dfe:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e00:	5b                   	pop    %ebx
  800e01:	5e                   	pop    %esi
  800e02:	5f                   	pop    %edi
  800e03:	5d                   	pop    %ebp
  800e04:	c3                   	ret    

00800e05 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e05:	55                   	push   %ebp
  800e06:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e08:	8b 45 08             	mov    0x8(%ebp),%eax
  800e0b:	05 00 00 00 30       	add    $0x30000000,%eax
  800e10:	c1 e8 0c             	shr    $0xc,%eax
}
  800e13:	5d                   	pop    %ebp
  800e14:	c3                   	ret    

00800e15 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e15:	55                   	push   %ebp
  800e16:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e18:	8b 45 08             	mov    0x8(%ebp),%eax
  800e1b:	05 00 00 00 30       	add    $0x30000000,%eax
  800e20:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e25:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e2a:	5d                   	pop    %ebp
  800e2b:	c3                   	ret    

00800e2c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e2c:	55                   	push   %ebp
  800e2d:	89 e5                	mov    %esp,%ebp
  800e2f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e32:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e37:	89 c2                	mov    %eax,%edx
  800e39:	c1 ea 16             	shr    $0x16,%edx
  800e3c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e43:	f6 c2 01             	test   $0x1,%dl
  800e46:	74 11                	je     800e59 <fd_alloc+0x2d>
  800e48:	89 c2                	mov    %eax,%edx
  800e4a:	c1 ea 0c             	shr    $0xc,%edx
  800e4d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e54:	f6 c2 01             	test   $0x1,%dl
  800e57:	75 09                	jne    800e62 <fd_alloc+0x36>
			*fd_store = fd;
  800e59:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e5b:	b8 00 00 00 00       	mov    $0x0,%eax
  800e60:	eb 17                	jmp    800e79 <fd_alloc+0x4d>
  800e62:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e67:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e6c:	75 c9                	jne    800e37 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e6e:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e74:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e79:	5d                   	pop    %ebp
  800e7a:	c3                   	ret    

00800e7b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e7b:	55                   	push   %ebp
  800e7c:	89 e5                	mov    %esp,%ebp
  800e7e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e81:	83 f8 1f             	cmp    $0x1f,%eax
  800e84:	77 36                	ja     800ebc <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e86:	c1 e0 0c             	shl    $0xc,%eax
  800e89:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e8e:	89 c2                	mov    %eax,%edx
  800e90:	c1 ea 16             	shr    $0x16,%edx
  800e93:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e9a:	f6 c2 01             	test   $0x1,%dl
  800e9d:	74 24                	je     800ec3 <fd_lookup+0x48>
  800e9f:	89 c2                	mov    %eax,%edx
  800ea1:	c1 ea 0c             	shr    $0xc,%edx
  800ea4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800eab:	f6 c2 01             	test   $0x1,%dl
  800eae:	74 1a                	je     800eca <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800eb0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800eb3:	89 02                	mov    %eax,(%edx)
	return 0;
  800eb5:	b8 00 00 00 00       	mov    $0x0,%eax
  800eba:	eb 13                	jmp    800ecf <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ebc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ec1:	eb 0c                	jmp    800ecf <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ec3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ec8:	eb 05                	jmp    800ecf <fd_lookup+0x54>
  800eca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800ecf:	5d                   	pop    %ebp
  800ed0:	c3                   	ret    

00800ed1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ed1:	55                   	push   %ebp
  800ed2:	89 e5                	mov    %esp,%ebp
  800ed4:	83 ec 08             	sub    $0x8,%esp
  800ed7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eda:	ba a8 2d 80 00       	mov    $0x802da8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800edf:	eb 13                	jmp    800ef4 <dev_lookup+0x23>
  800ee1:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800ee4:	39 08                	cmp    %ecx,(%eax)
  800ee6:	75 0c                	jne    800ef4 <dev_lookup+0x23>
			*dev = devtab[i];
  800ee8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eeb:	89 01                	mov    %eax,(%ecx)
			return 0;
  800eed:	b8 00 00 00 00       	mov    $0x0,%eax
  800ef2:	eb 2e                	jmp    800f22 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800ef4:	8b 02                	mov    (%edx),%eax
  800ef6:	85 c0                	test   %eax,%eax
  800ef8:	75 e7                	jne    800ee1 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800efa:	a1 08 40 80 00       	mov    0x804008,%eax
  800eff:	8b 40 48             	mov    0x48(%eax),%eax
  800f02:	83 ec 04             	sub    $0x4,%esp
  800f05:	51                   	push   %ecx
  800f06:	50                   	push   %eax
  800f07:	68 2c 2d 80 00       	push   $0x802d2c
  800f0c:	e8 5c f3 ff ff       	call   80026d <cprintf>
	*dev = 0;
  800f11:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f14:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f1a:	83 c4 10             	add    $0x10,%esp
  800f1d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f22:	c9                   	leave  
  800f23:	c3                   	ret    

00800f24 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f24:	55                   	push   %ebp
  800f25:	89 e5                	mov    %esp,%ebp
  800f27:	56                   	push   %esi
  800f28:	53                   	push   %ebx
  800f29:	83 ec 10             	sub    $0x10,%esp
  800f2c:	8b 75 08             	mov    0x8(%ebp),%esi
  800f2f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f32:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f35:	50                   	push   %eax
  800f36:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f3c:	c1 e8 0c             	shr    $0xc,%eax
  800f3f:	50                   	push   %eax
  800f40:	e8 36 ff ff ff       	call   800e7b <fd_lookup>
  800f45:	83 c4 08             	add    $0x8,%esp
  800f48:	85 c0                	test   %eax,%eax
  800f4a:	78 05                	js     800f51 <fd_close+0x2d>
	    || fd != fd2)
  800f4c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f4f:	74 0c                	je     800f5d <fd_close+0x39>
		return (must_exist ? r : 0);
  800f51:	84 db                	test   %bl,%bl
  800f53:	ba 00 00 00 00       	mov    $0x0,%edx
  800f58:	0f 44 c2             	cmove  %edx,%eax
  800f5b:	eb 41                	jmp    800f9e <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f5d:	83 ec 08             	sub    $0x8,%esp
  800f60:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f63:	50                   	push   %eax
  800f64:	ff 36                	pushl  (%esi)
  800f66:	e8 66 ff ff ff       	call   800ed1 <dev_lookup>
  800f6b:	89 c3                	mov    %eax,%ebx
  800f6d:	83 c4 10             	add    $0x10,%esp
  800f70:	85 c0                	test   %eax,%eax
  800f72:	78 1a                	js     800f8e <fd_close+0x6a>
		if (dev->dev_close)
  800f74:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f77:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f7a:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f7f:	85 c0                	test   %eax,%eax
  800f81:	74 0b                	je     800f8e <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f83:	83 ec 0c             	sub    $0xc,%esp
  800f86:	56                   	push   %esi
  800f87:	ff d0                	call   *%eax
  800f89:	89 c3                	mov    %eax,%ebx
  800f8b:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f8e:	83 ec 08             	sub    $0x8,%esp
  800f91:	56                   	push   %esi
  800f92:	6a 00                	push   $0x0
  800f94:	e8 e1 fc ff ff       	call   800c7a <sys_page_unmap>
	return r;
  800f99:	83 c4 10             	add    $0x10,%esp
  800f9c:	89 d8                	mov    %ebx,%eax
}
  800f9e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fa1:	5b                   	pop    %ebx
  800fa2:	5e                   	pop    %esi
  800fa3:	5d                   	pop    %ebp
  800fa4:	c3                   	ret    

00800fa5 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800fa5:	55                   	push   %ebp
  800fa6:	89 e5                	mov    %esp,%ebp
  800fa8:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fae:	50                   	push   %eax
  800faf:	ff 75 08             	pushl  0x8(%ebp)
  800fb2:	e8 c4 fe ff ff       	call   800e7b <fd_lookup>
  800fb7:	83 c4 08             	add    $0x8,%esp
  800fba:	85 c0                	test   %eax,%eax
  800fbc:	78 10                	js     800fce <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800fbe:	83 ec 08             	sub    $0x8,%esp
  800fc1:	6a 01                	push   $0x1
  800fc3:	ff 75 f4             	pushl  -0xc(%ebp)
  800fc6:	e8 59 ff ff ff       	call   800f24 <fd_close>
  800fcb:	83 c4 10             	add    $0x10,%esp
}
  800fce:	c9                   	leave  
  800fcf:	c3                   	ret    

00800fd0 <close_all>:

void
close_all(void)
{
  800fd0:	55                   	push   %ebp
  800fd1:	89 e5                	mov    %esp,%ebp
  800fd3:	53                   	push   %ebx
  800fd4:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fd7:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fdc:	83 ec 0c             	sub    $0xc,%esp
  800fdf:	53                   	push   %ebx
  800fe0:	e8 c0 ff ff ff       	call   800fa5 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800fe5:	83 c3 01             	add    $0x1,%ebx
  800fe8:	83 c4 10             	add    $0x10,%esp
  800feb:	83 fb 20             	cmp    $0x20,%ebx
  800fee:	75 ec                	jne    800fdc <close_all+0xc>
		close(i);
}
  800ff0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ff3:	c9                   	leave  
  800ff4:	c3                   	ret    

00800ff5 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800ff5:	55                   	push   %ebp
  800ff6:	89 e5                	mov    %esp,%ebp
  800ff8:	57                   	push   %edi
  800ff9:	56                   	push   %esi
  800ffa:	53                   	push   %ebx
  800ffb:	83 ec 2c             	sub    $0x2c,%esp
  800ffe:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801001:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801004:	50                   	push   %eax
  801005:	ff 75 08             	pushl  0x8(%ebp)
  801008:	e8 6e fe ff ff       	call   800e7b <fd_lookup>
  80100d:	83 c4 08             	add    $0x8,%esp
  801010:	85 c0                	test   %eax,%eax
  801012:	0f 88 c1 00 00 00    	js     8010d9 <dup+0xe4>
		return r;
	close(newfdnum);
  801018:	83 ec 0c             	sub    $0xc,%esp
  80101b:	56                   	push   %esi
  80101c:	e8 84 ff ff ff       	call   800fa5 <close>

	newfd = INDEX2FD(newfdnum);
  801021:	89 f3                	mov    %esi,%ebx
  801023:	c1 e3 0c             	shl    $0xc,%ebx
  801026:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80102c:	83 c4 04             	add    $0x4,%esp
  80102f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801032:	e8 de fd ff ff       	call   800e15 <fd2data>
  801037:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801039:	89 1c 24             	mov    %ebx,(%esp)
  80103c:	e8 d4 fd ff ff       	call   800e15 <fd2data>
  801041:	83 c4 10             	add    $0x10,%esp
  801044:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801047:	89 f8                	mov    %edi,%eax
  801049:	c1 e8 16             	shr    $0x16,%eax
  80104c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801053:	a8 01                	test   $0x1,%al
  801055:	74 37                	je     80108e <dup+0x99>
  801057:	89 f8                	mov    %edi,%eax
  801059:	c1 e8 0c             	shr    $0xc,%eax
  80105c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801063:	f6 c2 01             	test   $0x1,%dl
  801066:	74 26                	je     80108e <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801068:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80106f:	83 ec 0c             	sub    $0xc,%esp
  801072:	25 07 0e 00 00       	and    $0xe07,%eax
  801077:	50                   	push   %eax
  801078:	ff 75 d4             	pushl  -0x2c(%ebp)
  80107b:	6a 00                	push   $0x0
  80107d:	57                   	push   %edi
  80107e:	6a 00                	push   $0x0
  801080:	e8 b3 fb ff ff       	call   800c38 <sys_page_map>
  801085:	89 c7                	mov    %eax,%edi
  801087:	83 c4 20             	add    $0x20,%esp
  80108a:	85 c0                	test   %eax,%eax
  80108c:	78 2e                	js     8010bc <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80108e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801091:	89 d0                	mov    %edx,%eax
  801093:	c1 e8 0c             	shr    $0xc,%eax
  801096:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80109d:	83 ec 0c             	sub    $0xc,%esp
  8010a0:	25 07 0e 00 00       	and    $0xe07,%eax
  8010a5:	50                   	push   %eax
  8010a6:	53                   	push   %ebx
  8010a7:	6a 00                	push   $0x0
  8010a9:	52                   	push   %edx
  8010aa:	6a 00                	push   $0x0
  8010ac:	e8 87 fb ff ff       	call   800c38 <sys_page_map>
  8010b1:	89 c7                	mov    %eax,%edi
  8010b3:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8010b6:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010b8:	85 ff                	test   %edi,%edi
  8010ba:	79 1d                	jns    8010d9 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010bc:	83 ec 08             	sub    $0x8,%esp
  8010bf:	53                   	push   %ebx
  8010c0:	6a 00                	push   $0x0
  8010c2:	e8 b3 fb ff ff       	call   800c7a <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010c7:	83 c4 08             	add    $0x8,%esp
  8010ca:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010cd:	6a 00                	push   $0x0
  8010cf:	e8 a6 fb ff ff       	call   800c7a <sys_page_unmap>
	return r;
  8010d4:	83 c4 10             	add    $0x10,%esp
  8010d7:	89 f8                	mov    %edi,%eax
}
  8010d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010dc:	5b                   	pop    %ebx
  8010dd:	5e                   	pop    %esi
  8010de:	5f                   	pop    %edi
  8010df:	5d                   	pop    %ebp
  8010e0:	c3                   	ret    

008010e1 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010e1:	55                   	push   %ebp
  8010e2:	89 e5                	mov    %esp,%ebp
  8010e4:	53                   	push   %ebx
  8010e5:	83 ec 14             	sub    $0x14,%esp
  8010e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010eb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010ee:	50                   	push   %eax
  8010ef:	53                   	push   %ebx
  8010f0:	e8 86 fd ff ff       	call   800e7b <fd_lookup>
  8010f5:	83 c4 08             	add    $0x8,%esp
  8010f8:	89 c2                	mov    %eax,%edx
  8010fa:	85 c0                	test   %eax,%eax
  8010fc:	78 6d                	js     80116b <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010fe:	83 ec 08             	sub    $0x8,%esp
  801101:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801104:	50                   	push   %eax
  801105:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801108:	ff 30                	pushl  (%eax)
  80110a:	e8 c2 fd ff ff       	call   800ed1 <dev_lookup>
  80110f:	83 c4 10             	add    $0x10,%esp
  801112:	85 c0                	test   %eax,%eax
  801114:	78 4c                	js     801162 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801116:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801119:	8b 42 08             	mov    0x8(%edx),%eax
  80111c:	83 e0 03             	and    $0x3,%eax
  80111f:	83 f8 01             	cmp    $0x1,%eax
  801122:	75 21                	jne    801145 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801124:	a1 08 40 80 00       	mov    0x804008,%eax
  801129:	8b 40 48             	mov    0x48(%eax),%eax
  80112c:	83 ec 04             	sub    $0x4,%esp
  80112f:	53                   	push   %ebx
  801130:	50                   	push   %eax
  801131:	68 6d 2d 80 00       	push   $0x802d6d
  801136:	e8 32 f1 ff ff       	call   80026d <cprintf>
		return -E_INVAL;
  80113b:	83 c4 10             	add    $0x10,%esp
  80113e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801143:	eb 26                	jmp    80116b <read+0x8a>
	}
	if (!dev->dev_read)
  801145:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801148:	8b 40 08             	mov    0x8(%eax),%eax
  80114b:	85 c0                	test   %eax,%eax
  80114d:	74 17                	je     801166 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80114f:	83 ec 04             	sub    $0x4,%esp
  801152:	ff 75 10             	pushl  0x10(%ebp)
  801155:	ff 75 0c             	pushl  0xc(%ebp)
  801158:	52                   	push   %edx
  801159:	ff d0                	call   *%eax
  80115b:	89 c2                	mov    %eax,%edx
  80115d:	83 c4 10             	add    $0x10,%esp
  801160:	eb 09                	jmp    80116b <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801162:	89 c2                	mov    %eax,%edx
  801164:	eb 05                	jmp    80116b <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801166:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80116b:	89 d0                	mov    %edx,%eax
  80116d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801170:	c9                   	leave  
  801171:	c3                   	ret    

00801172 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801172:	55                   	push   %ebp
  801173:	89 e5                	mov    %esp,%ebp
  801175:	57                   	push   %edi
  801176:	56                   	push   %esi
  801177:	53                   	push   %ebx
  801178:	83 ec 0c             	sub    $0xc,%esp
  80117b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80117e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801181:	bb 00 00 00 00       	mov    $0x0,%ebx
  801186:	eb 21                	jmp    8011a9 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801188:	83 ec 04             	sub    $0x4,%esp
  80118b:	89 f0                	mov    %esi,%eax
  80118d:	29 d8                	sub    %ebx,%eax
  80118f:	50                   	push   %eax
  801190:	89 d8                	mov    %ebx,%eax
  801192:	03 45 0c             	add    0xc(%ebp),%eax
  801195:	50                   	push   %eax
  801196:	57                   	push   %edi
  801197:	e8 45 ff ff ff       	call   8010e1 <read>
		if (m < 0)
  80119c:	83 c4 10             	add    $0x10,%esp
  80119f:	85 c0                	test   %eax,%eax
  8011a1:	78 10                	js     8011b3 <readn+0x41>
			return m;
		if (m == 0)
  8011a3:	85 c0                	test   %eax,%eax
  8011a5:	74 0a                	je     8011b1 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011a7:	01 c3                	add    %eax,%ebx
  8011a9:	39 f3                	cmp    %esi,%ebx
  8011ab:	72 db                	jb     801188 <readn+0x16>
  8011ad:	89 d8                	mov    %ebx,%eax
  8011af:	eb 02                	jmp    8011b3 <readn+0x41>
  8011b1:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8011b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011b6:	5b                   	pop    %ebx
  8011b7:	5e                   	pop    %esi
  8011b8:	5f                   	pop    %edi
  8011b9:	5d                   	pop    %ebp
  8011ba:	c3                   	ret    

008011bb <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011bb:	55                   	push   %ebp
  8011bc:	89 e5                	mov    %esp,%ebp
  8011be:	53                   	push   %ebx
  8011bf:	83 ec 14             	sub    $0x14,%esp
  8011c2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011c5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011c8:	50                   	push   %eax
  8011c9:	53                   	push   %ebx
  8011ca:	e8 ac fc ff ff       	call   800e7b <fd_lookup>
  8011cf:	83 c4 08             	add    $0x8,%esp
  8011d2:	89 c2                	mov    %eax,%edx
  8011d4:	85 c0                	test   %eax,%eax
  8011d6:	78 68                	js     801240 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011d8:	83 ec 08             	sub    $0x8,%esp
  8011db:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011de:	50                   	push   %eax
  8011df:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011e2:	ff 30                	pushl  (%eax)
  8011e4:	e8 e8 fc ff ff       	call   800ed1 <dev_lookup>
  8011e9:	83 c4 10             	add    $0x10,%esp
  8011ec:	85 c0                	test   %eax,%eax
  8011ee:	78 47                	js     801237 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011f3:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011f7:	75 21                	jne    80121a <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011f9:	a1 08 40 80 00       	mov    0x804008,%eax
  8011fe:	8b 40 48             	mov    0x48(%eax),%eax
  801201:	83 ec 04             	sub    $0x4,%esp
  801204:	53                   	push   %ebx
  801205:	50                   	push   %eax
  801206:	68 89 2d 80 00       	push   $0x802d89
  80120b:	e8 5d f0 ff ff       	call   80026d <cprintf>
		return -E_INVAL;
  801210:	83 c4 10             	add    $0x10,%esp
  801213:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801218:	eb 26                	jmp    801240 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80121a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80121d:	8b 52 0c             	mov    0xc(%edx),%edx
  801220:	85 d2                	test   %edx,%edx
  801222:	74 17                	je     80123b <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801224:	83 ec 04             	sub    $0x4,%esp
  801227:	ff 75 10             	pushl  0x10(%ebp)
  80122a:	ff 75 0c             	pushl  0xc(%ebp)
  80122d:	50                   	push   %eax
  80122e:	ff d2                	call   *%edx
  801230:	89 c2                	mov    %eax,%edx
  801232:	83 c4 10             	add    $0x10,%esp
  801235:	eb 09                	jmp    801240 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801237:	89 c2                	mov    %eax,%edx
  801239:	eb 05                	jmp    801240 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80123b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801240:	89 d0                	mov    %edx,%eax
  801242:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801245:	c9                   	leave  
  801246:	c3                   	ret    

00801247 <seek>:

int
seek(int fdnum, off_t offset)
{
  801247:	55                   	push   %ebp
  801248:	89 e5                	mov    %esp,%ebp
  80124a:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80124d:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801250:	50                   	push   %eax
  801251:	ff 75 08             	pushl  0x8(%ebp)
  801254:	e8 22 fc ff ff       	call   800e7b <fd_lookup>
  801259:	83 c4 08             	add    $0x8,%esp
  80125c:	85 c0                	test   %eax,%eax
  80125e:	78 0e                	js     80126e <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801260:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801263:	8b 55 0c             	mov    0xc(%ebp),%edx
  801266:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801269:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80126e:	c9                   	leave  
  80126f:	c3                   	ret    

00801270 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801270:	55                   	push   %ebp
  801271:	89 e5                	mov    %esp,%ebp
  801273:	53                   	push   %ebx
  801274:	83 ec 14             	sub    $0x14,%esp
  801277:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80127a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80127d:	50                   	push   %eax
  80127e:	53                   	push   %ebx
  80127f:	e8 f7 fb ff ff       	call   800e7b <fd_lookup>
  801284:	83 c4 08             	add    $0x8,%esp
  801287:	89 c2                	mov    %eax,%edx
  801289:	85 c0                	test   %eax,%eax
  80128b:	78 65                	js     8012f2 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80128d:	83 ec 08             	sub    $0x8,%esp
  801290:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801293:	50                   	push   %eax
  801294:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801297:	ff 30                	pushl  (%eax)
  801299:	e8 33 fc ff ff       	call   800ed1 <dev_lookup>
  80129e:	83 c4 10             	add    $0x10,%esp
  8012a1:	85 c0                	test   %eax,%eax
  8012a3:	78 44                	js     8012e9 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012a8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012ac:	75 21                	jne    8012cf <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012ae:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012b3:	8b 40 48             	mov    0x48(%eax),%eax
  8012b6:	83 ec 04             	sub    $0x4,%esp
  8012b9:	53                   	push   %ebx
  8012ba:	50                   	push   %eax
  8012bb:	68 4c 2d 80 00       	push   $0x802d4c
  8012c0:	e8 a8 ef ff ff       	call   80026d <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012c5:	83 c4 10             	add    $0x10,%esp
  8012c8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012cd:	eb 23                	jmp    8012f2 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8012cf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012d2:	8b 52 18             	mov    0x18(%edx),%edx
  8012d5:	85 d2                	test   %edx,%edx
  8012d7:	74 14                	je     8012ed <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012d9:	83 ec 08             	sub    $0x8,%esp
  8012dc:	ff 75 0c             	pushl  0xc(%ebp)
  8012df:	50                   	push   %eax
  8012e0:	ff d2                	call   *%edx
  8012e2:	89 c2                	mov    %eax,%edx
  8012e4:	83 c4 10             	add    $0x10,%esp
  8012e7:	eb 09                	jmp    8012f2 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012e9:	89 c2                	mov    %eax,%edx
  8012eb:	eb 05                	jmp    8012f2 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012ed:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8012f2:	89 d0                	mov    %edx,%eax
  8012f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012f7:	c9                   	leave  
  8012f8:	c3                   	ret    

008012f9 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012f9:	55                   	push   %ebp
  8012fa:	89 e5                	mov    %esp,%ebp
  8012fc:	53                   	push   %ebx
  8012fd:	83 ec 14             	sub    $0x14,%esp
  801300:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801303:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801306:	50                   	push   %eax
  801307:	ff 75 08             	pushl  0x8(%ebp)
  80130a:	e8 6c fb ff ff       	call   800e7b <fd_lookup>
  80130f:	83 c4 08             	add    $0x8,%esp
  801312:	89 c2                	mov    %eax,%edx
  801314:	85 c0                	test   %eax,%eax
  801316:	78 58                	js     801370 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801318:	83 ec 08             	sub    $0x8,%esp
  80131b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80131e:	50                   	push   %eax
  80131f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801322:	ff 30                	pushl  (%eax)
  801324:	e8 a8 fb ff ff       	call   800ed1 <dev_lookup>
  801329:	83 c4 10             	add    $0x10,%esp
  80132c:	85 c0                	test   %eax,%eax
  80132e:	78 37                	js     801367 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801330:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801333:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801337:	74 32                	je     80136b <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801339:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80133c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801343:	00 00 00 
	stat->st_isdir = 0;
  801346:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80134d:	00 00 00 
	stat->st_dev = dev;
  801350:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801356:	83 ec 08             	sub    $0x8,%esp
  801359:	53                   	push   %ebx
  80135a:	ff 75 f0             	pushl  -0x10(%ebp)
  80135d:	ff 50 14             	call   *0x14(%eax)
  801360:	89 c2                	mov    %eax,%edx
  801362:	83 c4 10             	add    $0x10,%esp
  801365:	eb 09                	jmp    801370 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801367:	89 c2                	mov    %eax,%edx
  801369:	eb 05                	jmp    801370 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80136b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801370:	89 d0                	mov    %edx,%eax
  801372:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801375:	c9                   	leave  
  801376:	c3                   	ret    

00801377 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801377:	55                   	push   %ebp
  801378:	89 e5                	mov    %esp,%ebp
  80137a:	56                   	push   %esi
  80137b:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80137c:	83 ec 08             	sub    $0x8,%esp
  80137f:	6a 00                	push   $0x0
  801381:	ff 75 08             	pushl  0x8(%ebp)
  801384:	e8 0c 02 00 00       	call   801595 <open>
  801389:	89 c3                	mov    %eax,%ebx
  80138b:	83 c4 10             	add    $0x10,%esp
  80138e:	85 c0                	test   %eax,%eax
  801390:	78 1b                	js     8013ad <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801392:	83 ec 08             	sub    $0x8,%esp
  801395:	ff 75 0c             	pushl  0xc(%ebp)
  801398:	50                   	push   %eax
  801399:	e8 5b ff ff ff       	call   8012f9 <fstat>
  80139e:	89 c6                	mov    %eax,%esi
	close(fd);
  8013a0:	89 1c 24             	mov    %ebx,(%esp)
  8013a3:	e8 fd fb ff ff       	call   800fa5 <close>
	return r;
  8013a8:	83 c4 10             	add    $0x10,%esp
  8013ab:	89 f0                	mov    %esi,%eax
}
  8013ad:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013b0:	5b                   	pop    %ebx
  8013b1:	5e                   	pop    %esi
  8013b2:	5d                   	pop    %ebp
  8013b3:	c3                   	ret    

008013b4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013b4:	55                   	push   %ebp
  8013b5:	89 e5                	mov    %esp,%ebp
  8013b7:	56                   	push   %esi
  8013b8:	53                   	push   %ebx
  8013b9:	89 c6                	mov    %eax,%esi
  8013bb:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013bd:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013c4:	75 12                	jne    8013d8 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013c6:	83 ec 0c             	sub    $0xc,%esp
  8013c9:	6a 01                	push   $0x1
  8013cb:	e8 20 12 00 00       	call   8025f0 <ipc_find_env>
  8013d0:	a3 00 40 80 00       	mov    %eax,0x804000
  8013d5:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013d8:	6a 07                	push   $0x7
  8013da:	68 00 50 80 00       	push   $0x805000
  8013df:	56                   	push   %esi
  8013e0:	ff 35 00 40 80 00    	pushl  0x804000
  8013e6:	e8 b1 11 00 00       	call   80259c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013eb:	83 c4 0c             	add    $0xc,%esp
  8013ee:	6a 00                	push   $0x0
  8013f0:	53                   	push   %ebx
  8013f1:	6a 00                	push   $0x0
  8013f3:	e8 3b 11 00 00       	call   802533 <ipc_recv>
}
  8013f8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013fb:	5b                   	pop    %ebx
  8013fc:	5e                   	pop    %esi
  8013fd:	5d                   	pop    %ebp
  8013fe:	c3                   	ret    

008013ff <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013ff:	55                   	push   %ebp
  801400:	89 e5                	mov    %esp,%ebp
  801402:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801405:	8b 45 08             	mov    0x8(%ebp),%eax
  801408:	8b 40 0c             	mov    0xc(%eax),%eax
  80140b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801410:	8b 45 0c             	mov    0xc(%ebp),%eax
  801413:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801418:	ba 00 00 00 00       	mov    $0x0,%edx
  80141d:	b8 02 00 00 00       	mov    $0x2,%eax
  801422:	e8 8d ff ff ff       	call   8013b4 <fsipc>
}
  801427:	c9                   	leave  
  801428:	c3                   	ret    

00801429 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801429:	55                   	push   %ebp
  80142a:	89 e5                	mov    %esp,%ebp
  80142c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80142f:	8b 45 08             	mov    0x8(%ebp),%eax
  801432:	8b 40 0c             	mov    0xc(%eax),%eax
  801435:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80143a:	ba 00 00 00 00       	mov    $0x0,%edx
  80143f:	b8 06 00 00 00       	mov    $0x6,%eax
  801444:	e8 6b ff ff ff       	call   8013b4 <fsipc>
}
  801449:	c9                   	leave  
  80144a:	c3                   	ret    

0080144b <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80144b:	55                   	push   %ebp
  80144c:	89 e5                	mov    %esp,%ebp
  80144e:	53                   	push   %ebx
  80144f:	83 ec 04             	sub    $0x4,%esp
  801452:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801455:	8b 45 08             	mov    0x8(%ebp),%eax
  801458:	8b 40 0c             	mov    0xc(%eax),%eax
  80145b:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801460:	ba 00 00 00 00       	mov    $0x0,%edx
  801465:	b8 05 00 00 00       	mov    $0x5,%eax
  80146a:	e8 45 ff ff ff       	call   8013b4 <fsipc>
  80146f:	85 c0                	test   %eax,%eax
  801471:	78 2c                	js     80149f <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801473:	83 ec 08             	sub    $0x8,%esp
  801476:	68 00 50 80 00       	push   $0x805000
  80147b:	53                   	push   %ebx
  80147c:	e8 71 f3 ff ff       	call   8007f2 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801481:	a1 80 50 80 00       	mov    0x805080,%eax
  801486:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80148c:	a1 84 50 80 00       	mov    0x805084,%eax
  801491:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801497:	83 c4 10             	add    $0x10,%esp
  80149a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80149f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014a2:	c9                   	leave  
  8014a3:	c3                   	ret    

008014a4 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8014a4:	55                   	push   %ebp
  8014a5:	89 e5                	mov    %esp,%ebp
  8014a7:	53                   	push   %ebx
  8014a8:	83 ec 08             	sub    $0x8,%esp
  8014ab:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8014b1:	8b 52 0c             	mov    0xc(%edx),%edx
  8014b4:	89 15 00 50 80 00    	mov    %edx,0x805000
  8014ba:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8014bf:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  8014c4:	0f 46 d8             	cmovbe %eax,%ebx
	
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  8014c7:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  8014cd:	53                   	push   %ebx
  8014ce:	ff 75 0c             	pushl  0xc(%ebp)
  8014d1:	68 08 50 80 00       	push   $0x805008
  8014d6:	e8 a9 f4 ff ff       	call   800984 <memmove>

	
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) 
  8014db:	ba 00 00 00 00       	mov    $0x0,%edx
  8014e0:	b8 04 00 00 00       	mov    $0x4,%eax
  8014e5:	e8 ca fe ff ff       	call   8013b4 <fsipc>
  8014ea:	83 c4 10             	add    $0x10,%esp
  8014ed:	85 c0                	test   %eax,%eax
  8014ef:	78 1d                	js     80150e <devfile_write+0x6a>
		return r;
	assert(r <= n_real); 
  8014f1:	39 d8                	cmp    %ebx,%eax
  8014f3:	76 19                	jbe    80150e <devfile_write+0x6a>
  8014f5:	68 bc 2d 80 00       	push   $0x802dbc
  8014fa:	68 c8 2d 80 00       	push   $0x802dc8
  8014ff:	68 a3 00 00 00       	push   $0xa3
  801504:	68 dd 2d 80 00       	push   $0x802ddd
  801509:	e8 86 ec ff ff       	call   800194 <_panic>
	return r;
}
  80150e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801511:	c9                   	leave  
  801512:	c3                   	ret    

00801513 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801513:	55                   	push   %ebp
  801514:	89 e5                	mov    %esp,%ebp
  801516:	56                   	push   %esi
  801517:	53                   	push   %ebx
  801518:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80151b:	8b 45 08             	mov    0x8(%ebp),%eax
  80151e:	8b 40 0c             	mov    0xc(%eax),%eax
  801521:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801526:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80152c:	ba 00 00 00 00       	mov    $0x0,%edx
  801531:	b8 03 00 00 00       	mov    $0x3,%eax
  801536:	e8 79 fe ff ff       	call   8013b4 <fsipc>
  80153b:	89 c3                	mov    %eax,%ebx
  80153d:	85 c0                	test   %eax,%eax
  80153f:	78 4b                	js     80158c <devfile_read+0x79>
		return r;
	assert(r <= n);
  801541:	39 c6                	cmp    %eax,%esi
  801543:	73 16                	jae    80155b <devfile_read+0x48>
  801545:	68 e8 2d 80 00       	push   $0x802de8
  80154a:	68 c8 2d 80 00       	push   $0x802dc8
  80154f:	6a 7c                	push   $0x7c
  801551:	68 dd 2d 80 00       	push   $0x802ddd
  801556:	e8 39 ec ff ff       	call   800194 <_panic>
	assert(r <= PGSIZE);
  80155b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801560:	7e 16                	jle    801578 <devfile_read+0x65>
  801562:	68 ef 2d 80 00       	push   $0x802def
  801567:	68 c8 2d 80 00       	push   $0x802dc8
  80156c:	6a 7d                	push   $0x7d
  80156e:	68 dd 2d 80 00       	push   $0x802ddd
  801573:	e8 1c ec ff ff       	call   800194 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801578:	83 ec 04             	sub    $0x4,%esp
  80157b:	50                   	push   %eax
  80157c:	68 00 50 80 00       	push   $0x805000
  801581:	ff 75 0c             	pushl  0xc(%ebp)
  801584:	e8 fb f3 ff ff       	call   800984 <memmove>
	return r;
  801589:	83 c4 10             	add    $0x10,%esp
}
  80158c:	89 d8                	mov    %ebx,%eax
  80158e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801591:	5b                   	pop    %ebx
  801592:	5e                   	pop    %esi
  801593:	5d                   	pop    %ebp
  801594:	c3                   	ret    

00801595 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801595:	55                   	push   %ebp
  801596:	89 e5                	mov    %esp,%ebp
  801598:	53                   	push   %ebx
  801599:	83 ec 20             	sub    $0x20,%esp
  80159c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80159f:	53                   	push   %ebx
  8015a0:	e8 14 f2 ff ff       	call   8007b9 <strlen>
  8015a5:	83 c4 10             	add    $0x10,%esp
  8015a8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015ad:	7f 67                	jg     801616 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015af:	83 ec 0c             	sub    $0xc,%esp
  8015b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015b5:	50                   	push   %eax
  8015b6:	e8 71 f8 ff ff       	call   800e2c <fd_alloc>
  8015bb:	83 c4 10             	add    $0x10,%esp
		return r;
  8015be:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015c0:	85 c0                	test   %eax,%eax
  8015c2:	78 57                	js     80161b <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015c4:	83 ec 08             	sub    $0x8,%esp
  8015c7:	53                   	push   %ebx
  8015c8:	68 00 50 80 00       	push   $0x805000
  8015cd:	e8 20 f2 ff ff       	call   8007f2 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015d5:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015da:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015dd:	b8 01 00 00 00       	mov    $0x1,%eax
  8015e2:	e8 cd fd ff ff       	call   8013b4 <fsipc>
  8015e7:	89 c3                	mov    %eax,%ebx
  8015e9:	83 c4 10             	add    $0x10,%esp
  8015ec:	85 c0                	test   %eax,%eax
  8015ee:	79 14                	jns    801604 <open+0x6f>
		fd_close(fd, 0);
  8015f0:	83 ec 08             	sub    $0x8,%esp
  8015f3:	6a 00                	push   $0x0
  8015f5:	ff 75 f4             	pushl  -0xc(%ebp)
  8015f8:	e8 27 f9 ff ff       	call   800f24 <fd_close>
		return r;
  8015fd:	83 c4 10             	add    $0x10,%esp
  801600:	89 da                	mov    %ebx,%edx
  801602:	eb 17                	jmp    80161b <open+0x86>
	}

	return fd2num(fd);
  801604:	83 ec 0c             	sub    $0xc,%esp
  801607:	ff 75 f4             	pushl  -0xc(%ebp)
  80160a:	e8 f6 f7 ff ff       	call   800e05 <fd2num>
  80160f:	89 c2                	mov    %eax,%edx
  801611:	83 c4 10             	add    $0x10,%esp
  801614:	eb 05                	jmp    80161b <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801616:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80161b:	89 d0                	mov    %edx,%eax
  80161d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801620:	c9                   	leave  
  801621:	c3                   	ret    

00801622 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801622:	55                   	push   %ebp
  801623:	89 e5                	mov    %esp,%ebp
  801625:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801628:	ba 00 00 00 00       	mov    $0x0,%edx
  80162d:	b8 08 00 00 00       	mov    $0x8,%eax
  801632:	e8 7d fd ff ff       	call   8013b4 <fsipc>
}
  801637:	c9                   	leave  
  801638:	c3                   	ret    

00801639 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801639:	55                   	push   %ebp
  80163a:	89 e5                	mov    %esp,%ebp
  80163c:	57                   	push   %edi
  80163d:	56                   	push   %esi
  80163e:	53                   	push   %ebx
  80163f:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801645:	6a 00                	push   $0x0
  801647:	ff 75 08             	pushl  0x8(%ebp)
  80164a:	e8 46 ff ff ff       	call   801595 <open>
  80164f:	89 c7                	mov    %eax,%edi
  801651:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801657:	83 c4 10             	add    $0x10,%esp
  80165a:	85 c0                	test   %eax,%eax
  80165c:	0f 88 ae 04 00 00    	js     801b10 <spawn+0x4d7>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801662:	83 ec 04             	sub    $0x4,%esp
  801665:	68 00 02 00 00       	push   $0x200
  80166a:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801670:	50                   	push   %eax
  801671:	57                   	push   %edi
  801672:	e8 fb fa ff ff       	call   801172 <readn>
  801677:	83 c4 10             	add    $0x10,%esp
  80167a:	3d 00 02 00 00       	cmp    $0x200,%eax
  80167f:	75 0c                	jne    80168d <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  801681:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801688:	45 4c 46 
  80168b:	74 33                	je     8016c0 <spawn+0x87>
		close(fd);
  80168d:	83 ec 0c             	sub    $0xc,%esp
  801690:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801696:	e8 0a f9 ff ff       	call   800fa5 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  80169b:	83 c4 0c             	add    $0xc,%esp
  80169e:	68 7f 45 4c 46       	push   $0x464c457f
  8016a3:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  8016a9:	68 fb 2d 80 00       	push   $0x802dfb
  8016ae:	e8 ba eb ff ff       	call   80026d <cprintf>
		return -E_NOT_EXEC;
  8016b3:	83 c4 10             	add    $0x10,%esp
  8016b6:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  8016bb:	e9 b0 04 00 00       	jmp    801b70 <spawn+0x537>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8016c0:	b8 07 00 00 00       	mov    $0x7,%eax
  8016c5:	cd 30                	int    $0x30
  8016c7:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  8016cd:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  8016d3:	85 c0                	test   %eax,%eax
  8016d5:	0f 88 3d 04 00 00    	js     801b18 <spawn+0x4df>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  8016db:	89 c6                	mov    %eax,%esi
  8016dd:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  8016e3:	6b f6 7c             	imul   $0x7c,%esi,%esi
  8016e6:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  8016ec:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  8016f2:	b9 11 00 00 00       	mov    $0x11,%ecx
  8016f7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  8016f9:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  8016ff:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801705:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  80170a:	be 00 00 00 00       	mov    $0x0,%esi
  80170f:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801712:	eb 13                	jmp    801727 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801714:	83 ec 0c             	sub    $0xc,%esp
  801717:	50                   	push   %eax
  801718:	e8 9c f0 ff ff       	call   8007b9 <strlen>
  80171d:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801721:	83 c3 01             	add    $0x1,%ebx
  801724:	83 c4 10             	add    $0x10,%esp
  801727:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  80172e:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801731:	85 c0                	test   %eax,%eax
  801733:	75 df                	jne    801714 <spawn+0xdb>
  801735:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  80173b:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801741:	bf 00 10 40 00       	mov    $0x401000,%edi
  801746:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801748:	89 fa                	mov    %edi,%edx
  80174a:	83 e2 fc             	and    $0xfffffffc,%edx
  80174d:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801754:	29 c2                	sub    %eax,%edx
  801756:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  80175c:	8d 42 f8             	lea    -0x8(%edx),%eax
  80175f:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801764:	0f 86 be 03 00 00    	jbe    801b28 <spawn+0x4ef>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80176a:	83 ec 04             	sub    $0x4,%esp
  80176d:	6a 07                	push   $0x7
  80176f:	68 00 00 40 00       	push   $0x400000
  801774:	6a 00                	push   $0x0
  801776:	e8 7a f4 ff ff       	call   800bf5 <sys_page_alloc>
  80177b:	83 c4 10             	add    $0x10,%esp
  80177e:	85 c0                	test   %eax,%eax
  801780:	0f 88 a9 03 00 00    	js     801b2f <spawn+0x4f6>
  801786:	be 00 00 00 00       	mov    $0x0,%esi
  80178b:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801791:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801794:	eb 30                	jmp    8017c6 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801796:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  80179c:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  8017a2:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  8017a5:	83 ec 08             	sub    $0x8,%esp
  8017a8:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8017ab:	57                   	push   %edi
  8017ac:	e8 41 f0 ff ff       	call   8007f2 <strcpy>
		string_store += strlen(argv[i]) + 1;
  8017b1:	83 c4 04             	add    $0x4,%esp
  8017b4:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8017b7:	e8 fd ef ff ff       	call   8007b9 <strlen>
  8017bc:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  8017c0:	83 c6 01             	add    $0x1,%esi
  8017c3:	83 c4 10             	add    $0x10,%esp
  8017c6:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  8017cc:	7f c8                	jg     801796 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  8017ce:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  8017d4:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  8017da:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  8017e1:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  8017e7:	74 19                	je     801802 <spawn+0x1c9>
  8017e9:	68 70 2e 80 00       	push   $0x802e70
  8017ee:	68 c8 2d 80 00       	push   $0x802dc8
  8017f3:	68 f2 00 00 00       	push   $0xf2
  8017f8:	68 15 2e 80 00       	push   $0x802e15
  8017fd:	e8 92 e9 ff ff       	call   800194 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801802:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801808:	89 f8                	mov    %edi,%eax
  80180a:	2d 00 30 80 11       	sub    $0x11803000,%eax
  80180f:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801812:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801818:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  80181b:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801821:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801827:	83 ec 0c             	sub    $0xc,%esp
  80182a:	6a 07                	push   $0x7
  80182c:	68 00 d0 bf ee       	push   $0xeebfd000
  801831:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801837:	68 00 00 40 00       	push   $0x400000
  80183c:	6a 00                	push   $0x0
  80183e:	e8 f5 f3 ff ff       	call   800c38 <sys_page_map>
  801843:	89 c3                	mov    %eax,%ebx
  801845:	83 c4 20             	add    $0x20,%esp
  801848:	85 c0                	test   %eax,%eax
  80184a:	0f 88 0e 03 00 00    	js     801b5e <spawn+0x525>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801850:	83 ec 08             	sub    $0x8,%esp
  801853:	68 00 00 40 00       	push   $0x400000
  801858:	6a 00                	push   $0x0
  80185a:	e8 1b f4 ff ff       	call   800c7a <sys_page_unmap>
  80185f:	89 c3                	mov    %eax,%ebx
  801861:	83 c4 10             	add    $0x10,%esp
  801864:	85 c0                	test   %eax,%eax
  801866:	0f 88 f2 02 00 00    	js     801b5e <spawn+0x525>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  80186c:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801872:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801879:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  80187f:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801886:	00 00 00 
  801889:	e9 88 01 00 00       	jmp    801a16 <spawn+0x3dd>
		if (ph->p_type != ELF_PROG_LOAD)
  80188e:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801894:	83 38 01             	cmpl   $0x1,(%eax)
  801897:	0f 85 6b 01 00 00    	jne    801a08 <spawn+0x3cf>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  80189d:	89 c7                	mov    %eax,%edi
  80189f:	8b 40 18             	mov    0x18(%eax),%eax
  8018a2:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  8018a8:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  8018ab:	83 f8 01             	cmp    $0x1,%eax
  8018ae:	19 c0                	sbb    %eax,%eax
  8018b0:	83 e0 fe             	and    $0xfffffffe,%eax
  8018b3:	83 c0 07             	add    $0x7,%eax
  8018b6:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  8018bc:	89 f8                	mov    %edi,%eax
  8018be:	8b 7f 04             	mov    0x4(%edi),%edi
  8018c1:	89 f9                	mov    %edi,%ecx
  8018c3:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  8018c9:	8b 78 10             	mov    0x10(%eax),%edi
  8018cc:	8b 50 14             	mov    0x14(%eax),%edx
  8018cf:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  8018d5:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  8018d8:	89 f0                	mov    %esi,%eax
  8018da:	25 ff 0f 00 00       	and    $0xfff,%eax
  8018df:	74 14                	je     8018f5 <spawn+0x2bc>
		va -= i;
  8018e1:	29 c6                	sub    %eax,%esi
		memsz += i;
  8018e3:	01 c2                	add    %eax,%edx
  8018e5:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  8018eb:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  8018ed:	29 c1                	sub    %eax,%ecx
  8018ef:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8018f5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018fa:	e9 f7 00 00 00       	jmp    8019f6 <spawn+0x3bd>
		if (i >= filesz) {
  8018ff:	39 df                	cmp    %ebx,%edi
  801901:	77 27                	ja     80192a <spawn+0x2f1>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801903:	83 ec 04             	sub    $0x4,%esp
  801906:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  80190c:	56                   	push   %esi
  80190d:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801913:	e8 dd f2 ff ff       	call   800bf5 <sys_page_alloc>
  801918:	83 c4 10             	add    $0x10,%esp
  80191b:	85 c0                	test   %eax,%eax
  80191d:	0f 89 c7 00 00 00    	jns    8019ea <spawn+0x3b1>
  801923:	89 c3                	mov    %eax,%ebx
  801925:	e9 13 02 00 00       	jmp    801b3d <spawn+0x504>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80192a:	83 ec 04             	sub    $0x4,%esp
  80192d:	6a 07                	push   $0x7
  80192f:	68 00 00 40 00       	push   $0x400000
  801934:	6a 00                	push   $0x0
  801936:	e8 ba f2 ff ff       	call   800bf5 <sys_page_alloc>
  80193b:	83 c4 10             	add    $0x10,%esp
  80193e:	85 c0                	test   %eax,%eax
  801940:	0f 88 ed 01 00 00    	js     801b33 <spawn+0x4fa>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801946:	83 ec 08             	sub    $0x8,%esp
  801949:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  80194f:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801955:	50                   	push   %eax
  801956:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80195c:	e8 e6 f8 ff ff       	call   801247 <seek>
  801961:	83 c4 10             	add    $0x10,%esp
  801964:	85 c0                	test   %eax,%eax
  801966:	0f 88 cb 01 00 00    	js     801b37 <spawn+0x4fe>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  80196c:	83 ec 04             	sub    $0x4,%esp
  80196f:	89 f8                	mov    %edi,%eax
  801971:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801977:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80197c:	ba 00 10 00 00       	mov    $0x1000,%edx
  801981:	0f 47 c2             	cmova  %edx,%eax
  801984:	50                   	push   %eax
  801985:	68 00 00 40 00       	push   $0x400000
  80198a:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801990:	e8 dd f7 ff ff       	call   801172 <readn>
  801995:	83 c4 10             	add    $0x10,%esp
  801998:	85 c0                	test   %eax,%eax
  80199a:	0f 88 9b 01 00 00    	js     801b3b <spawn+0x502>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  8019a0:	83 ec 0c             	sub    $0xc,%esp
  8019a3:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  8019a9:	56                   	push   %esi
  8019aa:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  8019b0:	68 00 00 40 00       	push   $0x400000
  8019b5:	6a 00                	push   $0x0
  8019b7:	e8 7c f2 ff ff       	call   800c38 <sys_page_map>
  8019bc:	83 c4 20             	add    $0x20,%esp
  8019bf:	85 c0                	test   %eax,%eax
  8019c1:	79 15                	jns    8019d8 <spawn+0x39f>
				panic("spawn: sys_page_map data: %e", r);
  8019c3:	50                   	push   %eax
  8019c4:	68 21 2e 80 00       	push   $0x802e21
  8019c9:	68 25 01 00 00       	push   $0x125
  8019ce:	68 15 2e 80 00       	push   $0x802e15
  8019d3:	e8 bc e7 ff ff       	call   800194 <_panic>
			sys_page_unmap(0, UTEMP);
  8019d8:	83 ec 08             	sub    $0x8,%esp
  8019db:	68 00 00 40 00       	push   $0x400000
  8019e0:	6a 00                	push   $0x0
  8019e2:	e8 93 f2 ff ff       	call   800c7a <sys_page_unmap>
  8019e7:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8019ea:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8019f0:	81 c6 00 10 00 00    	add    $0x1000,%esi
  8019f6:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  8019fc:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  801a02:	0f 87 f7 fe ff ff    	ja     8018ff <spawn+0x2c6>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801a08:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801a0f:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801a16:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801a1d:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801a23:	0f 8c 65 fe ff ff    	jl     80188e <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801a29:	83 ec 0c             	sub    $0xc,%esp
  801a2c:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801a32:	e8 6e f5 ff ff       	call   800fa5 <close>
  801a37:	83 c4 10             	add    $0x10,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	uintptr_t i;
	for (i = 0; i < USTACKTOP; i += PGSIZE){
  801a3a:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a3f:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[PGNUM(i)] & PTE_P) && (uvpt[PGNUM(i)] & PTE_U) && (uvpt[PGNUM(i)] & PTE_SHARE)){
  801a45:	89 d8                	mov    %ebx,%eax
  801a47:	c1 e8 16             	shr    $0x16,%eax
  801a4a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801a51:	a8 01                	test   $0x1,%al
  801a53:	74 46                	je     801a9b <spawn+0x462>
  801a55:	89 d8                	mov    %ebx,%eax
  801a57:	c1 e8 0c             	shr    $0xc,%eax
  801a5a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801a61:	f6 c2 01             	test   $0x1,%dl
  801a64:	74 35                	je     801a9b <spawn+0x462>
  801a66:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801a6d:	f6 c2 04             	test   $0x4,%dl
  801a70:	74 29                	je     801a9b <spawn+0x462>
  801a72:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801a79:	f6 c6 04             	test   $0x4,%dh
  801a7c:	74 1d                	je     801a9b <spawn+0x462>
			sys_page_map(0, (void*)i,child, (void*)i,(uvpt[PGNUM(i)] | PTE_SYSCALL));
  801a7e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801a85:	83 ec 0c             	sub    $0xc,%esp
  801a88:	0d 07 0e 00 00       	or     $0xe07,%eax
  801a8d:	50                   	push   %eax
  801a8e:	53                   	push   %ebx
  801a8f:	56                   	push   %esi
  801a90:	53                   	push   %ebx
  801a91:	6a 00                	push   $0x0
  801a93:	e8 a0 f1 ff ff       	call   800c38 <sys_page_map>
  801a98:	83 c4 20             	add    $0x20,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	uintptr_t i;
	for (i = 0; i < USTACKTOP; i += PGSIZE){
  801a9b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801aa1:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801aa7:	75 9c                	jne    801a45 <spawn+0x40c>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801aa9:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801ab0:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801ab3:	83 ec 08             	sub    $0x8,%esp
  801ab6:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801abc:	50                   	push   %eax
  801abd:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801ac3:	e8 36 f2 ff ff       	call   800cfe <sys_env_set_trapframe>
  801ac8:	83 c4 10             	add    $0x10,%esp
  801acb:	85 c0                	test   %eax,%eax
  801acd:	79 15                	jns    801ae4 <spawn+0x4ab>
		panic("sys_env_set_trapframe: %e", r);
  801acf:	50                   	push   %eax
  801ad0:	68 3e 2e 80 00       	push   $0x802e3e
  801ad5:	68 86 00 00 00       	push   $0x86
  801ada:	68 15 2e 80 00       	push   $0x802e15
  801adf:	e8 b0 e6 ff ff       	call   800194 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801ae4:	83 ec 08             	sub    $0x8,%esp
  801ae7:	6a 02                	push   $0x2
  801ae9:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801aef:	e8 c8 f1 ff ff       	call   800cbc <sys_env_set_status>
  801af4:	83 c4 10             	add    $0x10,%esp
  801af7:	85 c0                	test   %eax,%eax
  801af9:	79 25                	jns    801b20 <spawn+0x4e7>
		panic("sys_env_set_status: %e", r);
  801afb:	50                   	push   %eax
  801afc:	68 58 2e 80 00       	push   $0x802e58
  801b01:	68 89 00 00 00       	push   $0x89
  801b06:	68 15 2e 80 00       	push   $0x802e15
  801b0b:	e8 84 e6 ff ff       	call   800194 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801b10:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801b16:	eb 58                	jmp    801b70 <spawn+0x537>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801b18:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801b1e:	eb 50                	jmp    801b70 <spawn+0x537>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801b20:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801b26:	eb 48                	jmp    801b70 <spawn+0x537>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801b28:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801b2d:	eb 41                	jmp    801b70 <spawn+0x537>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801b2f:	89 c3                	mov    %eax,%ebx
  801b31:	eb 3d                	jmp    801b70 <spawn+0x537>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801b33:	89 c3                	mov    %eax,%ebx
  801b35:	eb 06                	jmp    801b3d <spawn+0x504>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801b37:	89 c3                	mov    %eax,%ebx
  801b39:	eb 02                	jmp    801b3d <spawn+0x504>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801b3b:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801b3d:	83 ec 0c             	sub    $0xc,%esp
  801b40:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801b46:	e8 2b f0 ff ff       	call   800b76 <sys_env_destroy>
	close(fd);
  801b4b:	83 c4 04             	add    $0x4,%esp
  801b4e:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801b54:	e8 4c f4 ff ff       	call   800fa5 <close>
	return r;
  801b59:	83 c4 10             	add    $0x10,%esp
  801b5c:	eb 12                	jmp    801b70 <spawn+0x537>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801b5e:	83 ec 08             	sub    $0x8,%esp
  801b61:	68 00 00 40 00       	push   $0x400000
  801b66:	6a 00                	push   $0x0
  801b68:	e8 0d f1 ff ff       	call   800c7a <sys_page_unmap>
  801b6d:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801b70:	89 d8                	mov    %ebx,%eax
  801b72:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b75:	5b                   	pop    %ebx
  801b76:	5e                   	pop    %esi
  801b77:	5f                   	pop    %edi
  801b78:	5d                   	pop    %ebp
  801b79:	c3                   	ret    

00801b7a <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801b7a:	55                   	push   %ebp
  801b7b:	89 e5                	mov    %esp,%ebp
  801b7d:	56                   	push   %esi
  801b7e:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801b7f:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801b82:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801b87:	eb 03                	jmp    801b8c <spawnl+0x12>
		argc++;
  801b89:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801b8c:	83 c2 04             	add    $0x4,%edx
  801b8f:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801b93:	75 f4                	jne    801b89 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801b95:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801b9c:	83 e2 f0             	and    $0xfffffff0,%edx
  801b9f:	29 d4                	sub    %edx,%esp
  801ba1:	8d 54 24 03          	lea    0x3(%esp),%edx
  801ba5:	c1 ea 02             	shr    $0x2,%edx
  801ba8:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801baf:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801bb1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bb4:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801bbb:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801bc2:	00 
  801bc3:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801bc5:	b8 00 00 00 00       	mov    $0x0,%eax
  801bca:	eb 0a                	jmp    801bd6 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801bcc:	83 c0 01             	add    $0x1,%eax
  801bcf:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801bd3:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801bd6:	39 d0                	cmp    %edx,%eax
  801bd8:	75 f2                	jne    801bcc <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801bda:	83 ec 08             	sub    $0x8,%esp
  801bdd:	56                   	push   %esi
  801bde:	ff 75 08             	pushl  0x8(%ebp)
  801be1:	e8 53 fa ff ff       	call   801639 <spawn>
}
  801be6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801be9:	5b                   	pop    %ebx
  801bea:	5e                   	pop    %esi
  801beb:	5d                   	pop    %ebp
  801bec:	c3                   	ret    

00801bed <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801bed:	55                   	push   %ebp
  801bee:	89 e5                	mov    %esp,%ebp
  801bf0:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801bf3:	68 98 2e 80 00       	push   $0x802e98
  801bf8:	ff 75 0c             	pushl  0xc(%ebp)
  801bfb:	e8 f2 eb ff ff       	call   8007f2 <strcpy>
	return 0;
}
  801c00:	b8 00 00 00 00       	mov    $0x0,%eax
  801c05:	c9                   	leave  
  801c06:	c3                   	ret    

00801c07 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801c07:	55                   	push   %ebp
  801c08:	89 e5                	mov    %esp,%ebp
  801c0a:	53                   	push   %ebx
  801c0b:	83 ec 10             	sub    $0x10,%esp
  801c0e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801c11:	53                   	push   %ebx
  801c12:	e8 12 0a 00 00       	call   802629 <pageref>
  801c17:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801c1a:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801c1f:	83 f8 01             	cmp    $0x1,%eax
  801c22:	75 10                	jne    801c34 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801c24:	83 ec 0c             	sub    $0xc,%esp
  801c27:	ff 73 0c             	pushl  0xc(%ebx)
  801c2a:	e8 c0 02 00 00       	call   801eef <nsipc_close>
  801c2f:	89 c2                	mov    %eax,%edx
  801c31:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801c34:	89 d0                	mov    %edx,%eax
  801c36:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c39:	c9                   	leave  
  801c3a:	c3                   	ret    

00801c3b <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801c3b:	55                   	push   %ebp
  801c3c:	89 e5                	mov    %esp,%ebp
  801c3e:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801c41:	6a 00                	push   $0x0
  801c43:	ff 75 10             	pushl  0x10(%ebp)
  801c46:	ff 75 0c             	pushl  0xc(%ebp)
  801c49:	8b 45 08             	mov    0x8(%ebp),%eax
  801c4c:	ff 70 0c             	pushl  0xc(%eax)
  801c4f:	e8 78 03 00 00       	call   801fcc <nsipc_send>
}
  801c54:	c9                   	leave  
  801c55:	c3                   	ret    

00801c56 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801c56:	55                   	push   %ebp
  801c57:	89 e5                	mov    %esp,%ebp
  801c59:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801c5c:	6a 00                	push   $0x0
  801c5e:	ff 75 10             	pushl  0x10(%ebp)
  801c61:	ff 75 0c             	pushl  0xc(%ebp)
  801c64:	8b 45 08             	mov    0x8(%ebp),%eax
  801c67:	ff 70 0c             	pushl  0xc(%eax)
  801c6a:	e8 f1 02 00 00       	call   801f60 <nsipc_recv>
}
  801c6f:	c9                   	leave  
  801c70:	c3                   	ret    

00801c71 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801c71:	55                   	push   %ebp
  801c72:	89 e5                	mov    %esp,%ebp
  801c74:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801c77:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801c7a:	52                   	push   %edx
  801c7b:	50                   	push   %eax
  801c7c:	e8 fa f1 ff ff       	call   800e7b <fd_lookup>
  801c81:	83 c4 10             	add    $0x10,%esp
  801c84:	85 c0                	test   %eax,%eax
  801c86:	78 17                	js     801c9f <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801c88:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c8b:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801c91:	39 08                	cmp    %ecx,(%eax)
  801c93:	75 05                	jne    801c9a <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801c95:	8b 40 0c             	mov    0xc(%eax),%eax
  801c98:	eb 05                	jmp    801c9f <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801c9a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801c9f:	c9                   	leave  
  801ca0:	c3                   	ret    

00801ca1 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801ca1:	55                   	push   %ebp
  801ca2:	89 e5                	mov    %esp,%ebp
  801ca4:	56                   	push   %esi
  801ca5:	53                   	push   %ebx
  801ca6:	83 ec 1c             	sub    $0x1c,%esp
  801ca9:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801cab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cae:	50                   	push   %eax
  801caf:	e8 78 f1 ff ff       	call   800e2c <fd_alloc>
  801cb4:	89 c3                	mov    %eax,%ebx
  801cb6:	83 c4 10             	add    $0x10,%esp
  801cb9:	85 c0                	test   %eax,%eax
  801cbb:	78 1b                	js     801cd8 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801cbd:	83 ec 04             	sub    $0x4,%esp
  801cc0:	68 07 04 00 00       	push   $0x407
  801cc5:	ff 75 f4             	pushl  -0xc(%ebp)
  801cc8:	6a 00                	push   $0x0
  801cca:	e8 26 ef ff ff       	call   800bf5 <sys_page_alloc>
  801ccf:	89 c3                	mov    %eax,%ebx
  801cd1:	83 c4 10             	add    $0x10,%esp
  801cd4:	85 c0                	test   %eax,%eax
  801cd6:	79 10                	jns    801ce8 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801cd8:	83 ec 0c             	sub    $0xc,%esp
  801cdb:	56                   	push   %esi
  801cdc:	e8 0e 02 00 00       	call   801eef <nsipc_close>
		return r;
  801ce1:	83 c4 10             	add    $0x10,%esp
  801ce4:	89 d8                	mov    %ebx,%eax
  801ce6:	eb 24                	jmp    801d0c <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801ce8:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cf1:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801cf3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cf6:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801cfd:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801d00:	83 ec 0c             	sub    $0xc,%esp
  801d03:	50                   	push   %eax
  801d04:	e8 fc f0 ff ff       	call   800e05 <fd2num>
  801d09:	83 c4 10             	add    $0x10,%esp
}
  801d0c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d0f:	5b                   	pop    %ebx
  801d10:	5e                   	pop    %esi
  801d11:	5d                   	pop    %ebp
  801d12:	c3                   	ret    

00801d13 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801d13:	55                   	push   %ebp
  801d14:	89 e5                	mov    %esp,%ebp
  801d16:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d19:	8b 45 08             	mov    0x8(%ebp),%eax
  801d1c:	e8 50 ff ff ff       	call   801c71 <fd2sockid>
		return r;
  801d21:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d23:	85 c0                	test   %eax,%eax
  801d25:	78 1f                	js     801d46 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801d27:	83 ec 04             	sub    $0x4,%esp
  801d2a:	ff 75 10             	pushl  0x10(%ebp)
  801d2d:	ff 75 0c             	pushl  0xc(%ebp)
  801d30:	50                   	push   %eax
  801d31:	e8 12 01 00 00       	call   801e48 <nsipc_accept>
  801d36:	83 c4 10             	add    $0x10,%esp
		return r;
  801d39:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801d3b:	85 c0                	test   %eax,%eax
  801d3d:	78 07                	js     801d46 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801d3f:	e8 5d ff ff ff       	call   801ca1 <alloc_sockfd>
  801d44:	89 c1                	mov    %eax,%ecx
}
  801d46:	89 c8                	mov    %ecx,%eax
  801d48:	c9                   	leave  
  801d49:	c3                   	ret    

00801d4a <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801d4a:	55                   	push   %ebp
  801d4b:	89 e5                	mov    %esp,%ebp
  801d4d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d50:	8b 45 08             	mov    0x8(%ebp),%eax
  801d53:	e8 19 ff ff ff       	call   801c71 <fd2sockid>
  801d58:	85 c0                	test   %eax,%eax
  801d5a:	78 12                	js     801d6e <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801d5c:	83 ec 04             	sub    $0x4,%esp
  801d5f:	ff 75 10             	pushl  0x10(%ebp)
  801d62:	ff 75 0c             	pushl  0xc(%ebp)
  801d65:	50                   	push   %eax
  801d66:	e8 2d 01 00 00       	call   801e98 <nsipc_bind>
  801d6b:	83 c4 10             	add    $0x10,%esp
}
  801d6e:	c9                   	leave  
  801d6f:	c3                   	ret    

00801d70 <shutdown>:

int
shutdown(int s, int how)
{
  801d70:	55                   	push   %ebp
  801d71:	89 e5                	mov    %esp,%ebp
  801d73:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d76:	8b 45 08             	mov    0x8(%ebp),%eax
  801d79:	e8 f3 fe ff ff       	call   801c71 <fd2sockid>
  801d7e:	85 c0                	test   %eax,%eax
  801d80:	78 0f                	js     801d91 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801d82:	83 ec 08             	sub    $0x8,%esp
  801d85:	ff 75 0c             	pushl  0xc(%ebp)
  801d88:	50                   	push   %eax
  801d89:	e8 3f 01 00 00       	call   801ecd <nsipc_shutdown>
  801d8e:	83 c4 10             	add    $0x10,%esp
}
  801d91:	c9                   	leave  
  801d92:	c3                   	ret    

00801d93 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801d93:	55                   	push   %ebp
  801d94:	89 e5                	mov    %esp,%ebp
  801d96:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d99:	8b 45 08             	mov    0x8(%ebp),%eax
  801d9c:	e8 d0 fe ff ff       	call   801c71 <fd2sockid>
  801da1:	85 c0                	test   %eax,%eax
  801da3:	78 12                	js     801db7 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801da5:	83 ec 04             	sub    $0x4,%esp
  801da8:	ff 75 10             	pushl  0x10(%ebp)
  801dab:	ff 75 0c             	pushl  0xc(%ebp)
  801dae:	50                   	push   %eax
  801daf:	e8 55 01 00 00       	call   801f09 <nsipc_connect>
  801db4:	83 c4 10             	add    $0x10,%esp
}
  801db7:	c9                   	leave  
  801db8:	c3                   	ret    

00801db9 <listen>:

int
listen(int s, int backlog)
{
  801db9:	55                   	push   %ebp
  801dba:	89 e5                	mov    %esp,%ebp
  801dbc:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801dbf:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc2:	e8 aa fe ff ff       	call   801c71 <fd2sockid>
  801dc7:	85 c0                	test   %eax,%eax
  801dc9:	78 0f                	js     801dda <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801dcb:	83 ec 08             	sub    $0x8,%esp
  801dce:	ff 75 0c             	pushl  0xc(%ebp)
  801dd1:	50                   	push   %eax
  801dd2:	e8 67 01 00 00       	call   801f3e <nsipc_listen>
  801dd7:	83 c4 10             	add    $0x10,%esp
}
  801dda:	c9                   	leave  
  801ddb:	c3                   	ret    

00801ddc <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801ddc:	55                   	push   %ebp
  801ddd:	89 e5                	mov    %esp,%ebp
  801ddf:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801de2:	ff 75 10             	pushl  0x10(%ebp)
  801de5:	ff 75 0c             	pushl  0xc(%ebp)
  801de8:	ff 75 08             	pushl  0x8(%ebp)
  801deb:	e8 3a 02 00 00       	call   80202a <nsipc_socket>
  801df0:	83 c4 10             	add    $0x10,%esp
  801df3:	85 c0                	test   %eax,%eax
  801df5:	78 05                	js     801dfc <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801df7:	e8 a5 fe ff ff       	call   801ca1 <alloc_sockfd>
}
  801dfc:	c9                   	leave  
  801dfd:	c3                   	ret    

00801dfe <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801dfe:	55                   	push   %ebp
  801dff:	89 e5                	mov    %esp,%ebp
  801e01:	53                   	push   %ebx
  801e02:	83 ec 04             	sub    $0x4,%esp
  801e05:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801e07:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801e0e:	75 12                	jne    801e22 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801e10:	83 ec 0c             	sub    $0xc,%esp
  801e13:	6a 02                	push   $0x2
  801e15:	e8 d6 07 00 00       	call   8025f0 <ipc_find_env>
  801e1a:	a3 04 40 80 00       	mov    %eax,0x804004
  801e1f:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801e22:	6a 07                	push   $0x7
  801e24:	68 00 60 80 00       	push   $0x806000
  801e29:	53                   	push   %ebx
  801e2a:	ff 35 04 40 80 00    	pushl  0x804004
  801e30:	e8 67 07 00 00       	call   80259c <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801e35:	83 c4 0c             	add    $0xc,%esp
  801e38:	6a 00                	push   $0x0
  801e3a:	6a 00                	push   $0x0
  801e3c:	6a 00                	push   $0x0
  801e3e:	e8 f0 06 00 00       	call   802533 <ipc_recv>
}
  801e43:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e46:	c9                   	leave  
  801e47:	c3                   	ret    

00801e48 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801e48:	55                   	push   %ebp
  801e49:	89 e5                	mov    %esp,%ebp
  801e4b:	56                   	push   %esi
  801e4c:	53                   	push   %ebx
  801e4d:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801e50:	8b 45 08             	mov    0x8(%ebp),%eax
  801e53:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801e58:	8b 06                	mov    (%esi),%eax
  801e5a:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801e5f:	b8 01 00 00 00       	mov    $0x1,%eax
  801e64:	e8 95 ff ff ff       	call   801dfe <nsipc>
  801e69:	89 c3                	mov    %eax,%ebx
  801e6b:	85 c0                	test   %eax,%eax
  801e6d:	78 20                	js     801e8f <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801e6f:	83 ec 04             	sub    $0x4,%esp
  801e72:	ff 35 10 60 80 00    	pushl  0x806010
  801e78:	68 00 60 80 00       	push   $0x806000
  801e7d:	ff 75 0c             	pushl  0xc(%ebp)
  801e80:	e8 ff ea ff ff       	call   800984 <memmove>
		*addrlen = ret->ret_addrlen;
  801e85:	a1 10 60 80 00       	mov    0x806010,%eax
  801e8a:	89 06                	mov    %eax,(%esi)
  801e8c:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801e8f:	89 d8                	mov    %ebx,%eax
  801e91:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e94:	5b                   	pop    %ebx
  801e95:	5e                   	pop    %esi
  801e96:	5d                   	pop    %ebp
  801e97:	c3                   	ret    

00801e98 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801e98:	55                   	push   %ebp
  801e99:	89 e5                	mov    %esp,%ebp
  801e9b:	53                   	push   %ebx
  801e9c:	83 ec 08             	sub    $0x8,%esp
  801e9f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801ea2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ea5:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801eaa:	53                   	push   %ebx
  801eab:	ff 75 0c             	pushl  0xc(%ebp)
  801eae:	68 04 60 80 00       	push   $0x806004
  801eb3:	e8 cc ea ff ff       	call   800984 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801eb8:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801ebe:	b8 02 00 00 00       	mov    $0x2,%eax
  801ec3:	e8 36 ff ff ff       	call   801dfe <nsipc>
}
  801ec8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ecb:	c9                   	leave  
  801ecc:	c3                   	ret    

00801ecd <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801ecd:	55                   	push   %ebp
  801ece:	89 e5                	mov    %esp,%ebp
  801ed0:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801ed3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ed6:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801edb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ede:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801ee3:	b8 03 00 00 00       	mov    $0x3,%eax
  801ee8:	e8 11 ff ff ff       	call   801dfe <nsipc>
}
  801eed:	c9                   	leave  
  801eee:	c3                   	ret    

00801eef <nsipc_close>:

int
nsipc_close(int s)
{
  801eef:	55                   	push   %ebp
  801ef0:	89 e5                	mov    %esp,%ebp
  801ef2:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801ef5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ef8:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801efd:	b8 04 00 00 00       	mov    $0x4,%eax
  801f02:	e8 f7 fe ff ff       	call   801dfe <nsipc>
}
  801f07:	c9                   	leave  
  801f08:	c3                   	ret    

00801f09 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801f09:	55                   	push   %ebp
  801f0a:	89 e5                	mov    %esp,%ebp
  801f0c:	53                   	push   %ebx
  801f0d:	83 ec 08             	sub    $0x8,%esp
  801f10:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801f13:	8b 45 08             	mov    0x8(%ebp),%eax
  801f16:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801f1b:	53                   	push   %ebx
  801f1c:	ff 75 0c             	pushl  0xc(%ebp)
  801f1f:	68 04 60 80 00       	push   $0x806004
  801f24:	e8 5b ea ff ff       	call   800984 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801f29:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801f2f:	b8 05 00 00 00       	mov    $0x5,%eax
  801f34:	e8 c5 fe ff ff       	call   801dfe <nsipc>
}
  801f39:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f3c:	c9                   	leave  
  801f3d:	c3                   	ret    

00801f3e <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801f3e:	55                   	push   %ebp
  801f3f:	89 e5                	mov    %esp,%ebp
  801f41:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801f44:	8b 45 08             	mov    0x8(%ebp),%eax
  801f47:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801f4c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f4f:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801f54:	b8 06 00 00 00       	mov    $0x6,%eax
  801f59:	e8 a0 fe ff ff       	call   801dfe <nsipc>
}
  801f5e:	c9                   	leave  
  801f5f:	c3                   	ret    

00801f60 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801f60:	55                   	push   %ebp
  801f61:	89 e5                	mov    %esp,%ebp
  801f63:	56                   	push   %esi
  801f64:	53                   	push   %ebx
  801f65:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801f68:	8b 45 08             	mov    0x8(%ebp),%eax
  801f6b:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801f70:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801f76:	8b 45 14             	mov    0x14(%ebp),%eax
  801f79:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801f7e:	b8 07 00 00 00       	mov    $0x7,%eax
  801f83:	e8 76 fe ff ff       	call   801dfe <nsipc>
  801f88:	89 c3                	mov    %eax,%ebx
  801f8a:	85 c0                	test   %eax,%eax
  801f8c:	78 35                	js     801fc3 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801f8e:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801f93:	7f 04                	jg     801f99 <nsipc_recv+0x39>
  801f95:	39 c6                	cmp    %eax,%esi
  801f97:	7d 16                	jge    801faf <nsipc_recv+0x4f>
  801f99:	68 a4 2e 80 00       	push   $0x802ea4
  801f9e:	68 c8 2d 80 00       	push   $0x802dc8
  801fa3:	6a 62                	push   $0x62
  801fa5:	68 b9 2e 80 00       	push   $0x802eb9
  801faa:	e8 e5 e1 ff ff       	call   800194 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801faf:	83 ec 04             	sub    $0x4,%esp
  801fb2:	50                   	push   %eax
  801fb3:	68 00 60 80 00       	push   $0x806000
  801fb8:	ff 75 0c             	pushl  0xc(%ebp)
  801fbb:	e8 c4 e9 ff ff       	call   800984 <memmove>
  801fc0:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801fc3:	89 d8                	mov    %ebx,%eax
  801fc5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fc8:	5b                   	pop    %ebx
  801fc9:	5e                   	pop    %esi
  801fca:	5d                   	pop    %ebp
  801fcb:	c3                   	ret    

00801fcc <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801fcc:	55                   	push   %ebp
  801fcd:	89 e5                	mov    %esp,%ebp
  801fcf:	53                   	push   %ebx
  801fd0:	83 ec 04             	sub    $0x4,%esp
  801fd3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801fd6:	8b 45 08             	mov    0x8(%ebp),%eax
  801fd9:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801fde:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801fe4:	7e 16                	jle    801ffc <nsipc_send+0x30>
  801fe6:	68 c5 2e 80 00       	push   $0x802ec5
  801feb:	68 c8 2d 80 00       	push   $0x802dc8
  801ff0:	6a 6d                	push   $0x6d
  801ff2:	68 b9 2e 80 00       	push   $0x802eb9
  801ff7:	e8 98 e1 ff ff       	call   800194 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801ffc:	83 ec 04             	sub    $0x4,%esp
  801fff:	53                   	push   %ebx
  802000:	ff 75 0c             	pushl  0xc(%ebp)
  802003:	68 0c 60 80 00       	push   $0x80600c
  802008:	e8 77 e9 ff ff       	call   800984 <memmove>
	nsipcbuf.send.req_size = size;
  80200d:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  802013:	8b 45 14             	mov    0x14(%ebp),%eax
  802016:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  80201b:	b8 08 00 00 00       	mov    $0x8,%eax
  802020:	e8 d9 fd ff ff       	call   801dfe <nsipc>
}
  802025:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802028:	c9                   	leave  
  802029:	c3                   	ret    

0080202a <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  80202a:	55                   	push   %ebp
  80202b:	89 e5                	mov    %esp,%ebp
  80202d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802030:	8b 45 08             	mov    0x8(%ebp),%eax
  802033:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  802038:	8b 45 0c             	mov    0xc(%ebp),%eax
  80203b:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  802040:	8b 45 10             	mov    0x10(%ebp),%eax
  802043:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  802048:	b8 09 00 00 00       	mov    $0x9,%eax
  80204d:	e8 ac fd ff ff       	call   801dfe <nsipc>
}
  802052:	c9                   	leave  
  802053:	c3                   	ret    

00802054 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802054:	55                   	push   %ebp
  802055:	89 e5                	mov    %esp,%ebp
  802057:	56                   	push   %esi
  802058:	53                   	push   %ebx
  802059:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80205c:	83 ec 0c             	sub    $0xc,%esp
  80205f:	ff 75 08             	pushl  0x8(%ebp)
  802062:	e8 ae ed ff ff       	call   800e15 <fd2data>
  802067:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802069:	83 c4 08             	add    $0x8,%esp
  80206c:	68 d1 2e 80 00       	push   $0x802ed1
  802071:	53                   	push   %ebx
  802072:	e8 7b e7 ff ff       	call   8007f2 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802077:	8b 46 04             	mov    0x4(%esi),%eax
  80207a:	2b 06                	sub    (%esi),%eax
  80207c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802082:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802089:	00 00 00 
	stat->st_dev = &devpipe;
  80208c:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  802093:	30 80 00 
	return 0;
}
  802096:	b8 00 00 00 00       	mov    $0x0,%eax
  80209b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80209e:	5b                   	pop    %ebx
  80209f:	5e                   	pop    %esi
  8020a0:	5d                   	pop    %ebp
  8020a1:	c3                   	ret    

008020a2 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8020a2:	55                   	push   %ebp
  8020a3:	89 e5                	mov    %esp,%ebp
  8020a5:	53                   	push   %ebx
  8020a6:	83 ec 0c             	sub    $0xc,%esp
  8020a9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8020ac:	53                   	push   %ebx
  8020ad:	6a 00                	push   $0x0
  8020af:	e8 c6 eb ff ff       	call   800c7a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8020b4:	89 1c 24             	mov    %ebx,(%esp)
  8020b7:	e8 59 ed ff ff       	call   800e15 <fd2data>
  8020bc:	83 c4 08             	add    $0x8,%esp
  8020bf:	50                   	push   %eax
  8020c0:	6a 00                	push   $0x0
  8020c2:	e8 b3 eb ff ff       	call   800c7a <sys_page_unmap>
}
  8020c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020ca:	c9                   	leave  
  8020cb:	c3                   	ret    

008020cc <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8020cc:	55                   	push   %ebp
  8020cd:	89 e5                	mov    %esp,%ebp
  8020cf:	57                   	push   %edi
  8020d0:	56                   	push   %esi
  8020d1:	53                   	push   %ebx
  8020d2:	83 ec 1c             	sub    $0x1c,%esp
  8020d5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8020d8:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8020da:	a1 08 40 80 00       	mov    0x804008,%eax
  8020df:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8020e2:	83 ec 0c             	sub    $0xc,%esp
  8020e5:	ff 75 e0             	pushl  -0x20(%ebp)
  8020e8:	e8 3c 05 00 00       	call   802629 <pageref>
  8020ed:	89 c3                	mov    %eax,%ebx
  8020ef:	89 3c 24             	mov    %edi,(%esp)
  8020f2:	e8 32 05 00 00       	call   802629 <pageref>
  8020f7:	83 c4 10             	add    $0x10,%esp
  8020fa:	39 c3                	cmp    %eax,%ebx
  8020fc:	0f 94 c1             	sete   %cl
  8020ff:	0f b6 c9             	movzbl %cl,%ecx
  802102:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  802105:	8b 15 08 40 80 00    	mov    0x804008,%edx
  80210b:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80210e:	39 ce                	cmp    %ecx,%esi
  802110:	74 1b                	je     80212d <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802112:	39 c3                	cmp    %eax,%ebx
  802114:	75 c4                	jne    8020da <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802116:	8b 42 58             	mov    0x58(%edx),%eax
  802119:	ff 75 e4             	pushl  -0x1c(%ebp)
  80211c:	50                   	push   %eax
  80211d:	56                   	push   %esi
  80211e:	68 d8 2e 80 00       	push   $0x802ed8
  802123:	e8 45 e1 ff ff       	call   80026d <cprintf>
  802128:	83 c4 10             	add    $0x10,%esp
  80212b:	eb ad                	jmp    8020da <_pipeisclosed+0xe>
	}
}
  80212d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802130:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802133:	5b                   	pop    %ebx
  802134:	5e                   	pop    %esi
  802135:	5f                   	pop    %edi
  802136:	5d                   	pop    %ebp
  802137:	c3                   	ret    

00802138 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802138:	55                   	push   %ebp
  802139:	89 e5                	mov    %esp,%ebp
  80213b:	57                   	push   %edi
  80213c:	56                   	push   %esi
  80213d:	53                   	push   %ebx
  80213e:	83 ec 28             	sub    $0x28,%esp
  802141:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802144:	56                   	push   %esi
  802145:	e8 cb ec ff ff       	call   800e15 <fd2data>
  80214a:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80214c:	83 c4 10             	add    $0x10,%esp
  80214f:	bf 00 00 00 00       	mov    $0x0,%edi
  802154:	eb 4b                	jmp    8021a1 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802156:	89 da                	mov    %ebx,%edx
  802158:	89 f0                	mov    %esi,%eax
  80215a:	e8 6d ff ff ff       	call   8020cc <_pipeisclosed>
  80215f:	85 c0                	test   %eax,%eax
  802161:	75 48                	jne    8021ab <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802163:	e8 6e ea ff ff       	call   800bd6 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802168:	8b 43 04             	mov    0x4(%ebx),%eax
  80216b:	8b 0b                	mov    (%ebx),%ecx
  80216d:	8d 51 20             	lea    0x20(%ecx),%edx
  802170:	39 d0                	cmp    %edx,%eax
  802172:	73 e2                	jae    802156 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802174:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802177:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80217b:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80217e:	89 c2                	mov    %eax,%edx
  802180:	c1 fa 1f             	sar    $0x1f,%edx
  802183:	89 d1                	mov    %edx,%ecx
  802185:	c1 e9 1b             	shr    $0x1b,%ecx
  802188:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80218b:	83 e2 1f             	and    $0x1f,%edx
  80218e:	29 ca                	sub    %ecx,%edx
  802190:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802194:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802198:	83 c0 01             	add    $0x1,%eax
  80219b:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80219e:	83 c7 01             	add    $0x1,%edi
  8021a1:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8021a4:	75 c2                	jne    802168 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8021a6:	8b 45 10             	mov    0x10(%ebp),%eax
  8021a9:	eb 05                	jmp    8021b0 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8021ab:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8021b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021b3:	5b                   	pop    %ebx
  8021b4:	5e                   	pop    %esi
  8021b5:	5f                   	pop    %edi
  8021b6:	5d                   	pop    %ebp
  8021b7:	c3                   	ret    

008021b8 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8021b8:	55                   	push   %ebp
  8021b9:	89 e5                	mov    %esp,%ebp
  8021bb:	57                   	push   %edi
  8021bc:	56                   	push   %esi
  8021bd:	53                   	push   %ebx
  8021be:	83 ec 18             	sub    $0x18,%esp
  8021c1:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8021c4:	57                   	push   %edi
  8021c5:	e8 4b ec ff ff       	call   800e15 <fd2data>
  8021ca:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8021cc:	83 c4 10             	add    $0x10,%esp
  8021cf:	bb 00 00 00 00       	mov    $0x0,%ebx
  8021d4:	eb 3d                	jmp    802213 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8021d6:	85 db                	test   %ebx,%ebx
  8021d8:	74 04                	je     8021de <devpipe_read+0x26>
				return i;
  8021da:	89 d8                	mov    %ebx,%eax
  8021dc:	eb 44                	jmp    802222 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8021de:	89 f2                	mov    %esi,%edx
  8021e0:	89 f8                	mov    %edi,%eax
  8021e2:	e8 e5 fe ff ff       	call   8020cc <_pipeisclosed>
  8021e7:	85 c0                	test   %eax,%eax
  8021e9:	75 32                	jne    80221d <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8021eb:	e8 e6 e9 ff ff       	call   800bd6 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8021f0:	8b 06                	mov    (%esi),%eax
  8021f2:	3b 46 04             	cmp    0x4(%esi),%eax
  8021f5:	74 df                	je     8021d6 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8021f7:	99                   	cltd   
  8021f8:	c1 ea 1b             	shr    $0x1b,%edx
  8021fb:	01 d0                	add    %edx,%eax
  8021fd:	83 e0 1f             	and    $0x1f,%eax
  802200:	29 d0                	sub    %edx,%eax
  802202:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802207:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80220a:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80220d:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802210:	83 c3 01             	add    $0x1,%ebx
  802213:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802216:	75 d8                	jne    8021f0 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802218:	8b 45 10             	mov    0x10(%ebp),%eax
  80221b:	eb 05                	jmp    802222 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80221d:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802222:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802225:	5b                   	pop    %ebx
  802226:	5e                   	pop    %esi
  802227:	5f                   	pop    %edi
  802228:	5d                   	pop    %ebp
  802229:	c3                   	ret    

0080222a <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80222a:	55                   	push   %ebp
  80222b:	89 e5                	mov    %esp,%ebp
  80222d:	56                   	push   %esi
  80222e:	53                   	push   %ebx
  80222f:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802232:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802235:	50                   	push   %eax
  802236:	e8 f1 eb ff ff       	call   800e2c <fd_alloc>
  80223b:	83 c4 10             	add    $0x10,%esp
  80223e:	89 c2                	mov    %eax,%edx
  802240:	85 c0                	test   %eax,%eax
  802242:	0f 88 2c 01 00 00    	js     802374 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802248:	83 ec 04             	sub    $0x4,%esp
  80224b:	68 07 04 00 00       	push   $0x407
  802250:	ff 75 f4             	pushl  -0xc(%ebp)
  802253:	6a 00                	push   $0x0
  802255:	e8 9b e9 ff ff       	call   800bf5 <sys_page_alloc>
  80225a:	83 c4 10             	add    $0x10,%esp
  80225d:	89 c2                	mov    %eax,%edx
  80225f:	85 c0                	test   %eax,%eax
  802261:	0f 88 0d 01 00 00    	js     802374 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802267:	83 ec 0c             	sub    $0xc,%esp
  80226a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80226d:	50                   	push   %eax
  80226e:	e8 b9 eb ff ff       	call   800e2c <fd_alloc>
  802273:	89 c3                	mov    %eax,%ebx
  802275:	83 c4 10             	add    $0x10,%esp
  802278:	85 c0                	test   %eax,%eax
  80227a:	0f 88 e2 00 00 00    	js     802362 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802280:	83 ec 04             	sub    $0x4,%esp
  802283:	68 07 04 00 00       	push   $0x407
  802288:	ff 75 f0             	pushl  -0x10(%ebp)
  80228b:	6a 00                	push   $0x0
  80228d:	e8 63 e9 ff ff       	call   800bf5 <sys_page_alloc>
  802292:	89 c3                	mov    %eax,%ebx
  802294:	83 c4 10             	add    $0x10,%esp
  802297:	85 c0                	test   %eax,%eax
  802299:	0f 88 c3 00 00 00    	js     802362 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80229f:	83 ec 0c             	sub    $0xc,%esp
  8022a2:	ff 75 f4             	pushl  -0xc(%ebp)
  8022a5:	e8 6b eb ff ff       	call   800e15 <fd2data>
  8022aa:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022ac:	83 c4 0c             	add    $0xc,%esp
  8022af:	68 07 04 00 00       	push   $0x407
  8022b4:	50                   	push   %eax
  8022b5:	6a 00                	push   $0x0
  8022b7:	e8 39 e9 ff ff       	call   800bf5 <sys_page_alloc>
  8022bc:	89 c3                	mov    %eax,%ebx
  8022be:	83 c4 10             	add    $0x10,%esp
  8022c1:	85 c0                	test   %eax,%eax
  8022c3:	0f 88 89 00 00 00    	js     802352 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022c9:	83 ec 0c             	sub    $0xc,%esp
  8022cc:	ff 75 f0             	pushl  -0x10(%ebp)
  8022cf:	e8 41 eb ff ff       	call   800e15 <fd2data>
  8022d4:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8022db:	50                   	push   %eax
  8022dc:	6a 00                	push   $0x0
  8022de:	56                   	push   %esi
  8022df:	6a 00                	push   $0x0
  8022e1:	e8 52 e9 ff ff       	call   800c38 <sys_page_map>
  8022e6:	89 c3                	mov    %eax,%ebx
  8022e8:	83 c4 20             	add    $0x20,%esp
  8022eb:	85 c0                	test   %eax,%eax
  8022ed:	78 55                	js     802344 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8022ef:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8022f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022f8:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8022fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022fd:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802304:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80230a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80230d:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80230f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802312:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802319:	83 ec 0c             	sub    $0xc,%esp
  80231c:	ff 75 f4             	pushl  -0xc(%ebp)
  80231f:	e8 e1 ea ff ff       	call   800e05 <fd2num>
  802324:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802327:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802329:	83 c4 04             	add    $0x4,%esp
  80232c:	ff 75 f0             	pushl  -0x10(%ebp)
  80232f:	e8 d1 ea ff ff       	call   800e05 <fd2num>
  802334:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802337:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80233a:	83 c4 10             	add    $0x10,%esp
  80233d:	ba 00 00 00 00       	mov    $0x0,%edx
  802342:	eb 30                	jmp    802374 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802344:	83 ec 08             	sub    $0x8,%esp
  802347:	56                   	push   %esi
  802348:	6a 00                	push   $0x0
  80234a:	e8 2b e9 ff ff       	call   800c7a <sys_page_unmap>
  80234f:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802352:	83 ec 08             	sub    $0x8,%esp
  802355:	ff 75 f0             	pushl  -0x10(%ebp)
  802358:	6a 00                	push   $0x0
  80235a:	e8 1b e9 ff ff       	call   800c7a <sys_page_unmap>
  80235f:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802362:	83 ec 08             	sub    $0x8,%esp
  802365:	ff 75 f4             	pushl  -0xc(%ebp)
  802368:	6a 00                	push   $0x0
  80236a:	e8 0b e9 ff ff       	call   800c7a <sys_page_unmap>
  80236f:	83 c4 10             	add    $0x10,%esp
  802372:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802374:	89 d0                	mov    %edx,%eax
  802376:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802379:	5b                   	pop    %ebx
  80237a:	5e                   	pop    %esi
  80237b:	5d                   	pop    %ebp
  80237c:	c3                   	ret    

0080237d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80237d:	55                   	push   %ebp
  80237e:	89 e5                	mov    %esp,%ebp
  802380:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802383:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802386:	50                   	push   %eax
  802387:	ff 75 08             	pushl  0x8(%ebp)
  80238a:	e8 ec ea ff ff       	call   800e7b <fd_lookup>
  80238f:	83 c4 10             	add    $0x10,%esp
  802392:	85 c0                	test   %eax,%eax
  802394:	78 18                	js     8023ae <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802396:	83 ec 0c             	sub    $0xc,%esp
  802399:	ff 75 f4             	pushl  -0xc(%ebp)
  80239c:	e8 74 ea ff ff       	call   800e15 <fd2data>
	return _pipeisclosed(fd, p);
  8023a1:	89 c2                	mov    %eax,%edx
  8023a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023a6:	e8 21 fd ff ff       	call   8020cc <_pipeisclosed>
  8023ab:	83 c4 10             	add    $0x10,%esp
}
  8023ae:	c9                   	leave  
  8023af:	c3                   	ret    

008023b0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8023b0:	55                   	push   %ebp
  8023b1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8023b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8023b8:	5d                   	pop    %ebp
  8023b9:	c3                   	ret    

008023ba <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8023ba:	55                   	push   %ebp
  8023bb:	89 e5                	mov    %esp,%ebp
  8023bd:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8023c0:	68 f0 2e 80 00       	push   $0x802ef0
  8023c5:	ff 75 0c             	pushl  0xc(%ebp)
  8023c8:	e8 25 e4 ff ff       	call   8007f2 <strcpy>
	return 0;
}
  8023cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8023d2:	c9                   	leave  
  8023d3:	c3                   	ret    

008023d4 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8023d4:	55                   	push   %ebp
  8023d5:	89 e5                	mov    %esp,%ebp
  8023d7:	57                   	push   %edi
  8023d8:	56                   	push   %esi
  8023d9:	53                   	push   %ebx
  8023da:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8023e0:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8023e5:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8023eb:	eb 2d                	jmp    80241a <devcons_write+0x46>
		m = n - tot;
  8023ed:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8023f0:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8023f2:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8023f5:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8023fa:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8023fd:	83 ec 04             	sub    $0x4,%esp
  802400:	53                   	push   %ebx
  802401:	03 45 0c             	add    0xc(%ebp),%eax
  802404:	50                   	push   %eax
  802405:	57                   	push   %edi
  802406:	e8 79 e5 ff ff       	call   800984 <memmove>
		sys_cputs(buf, m);
  80240b:	83 c4 08             	add    $0x8,%esp
  80240e:	53                   	push   %ebx
  80240f:	57                   	push   %edi
  802410:	e8 24 e7 ff ff       	call   800b39 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802415:	01 de                	add    %ebx,%esi
  802417:	83 c4 10             	add    $0x10,%esp
  80241a:	89 f0                	mov    %esi,%eax
  80241c:	3b 75 10             	cmp    0x10(%ebp),%esi
  80241f:	72 cc                	jb     8023ed <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802421:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802424:	5b                   	pop    %ebx
  802425:	5e                   	pop    %esi
  802426:	5f                   	pop    %edi
  802427:	5d                   	pop    %ebp
  802428:	c3                   	ret    

00802429 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802429:	55                   	push   %ebp
  80242a:	89 e5                	mov    %esp,%ebp
  80242c:	83 ec 08             	sub    $0x8,%esp
  80242f:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802434:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802438:	74 2a                	je     802464 <devcons_read+0x3b>
  80243a:	eb 05                	jmp    802441 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80243c:	e8 95 e7 ff ff       	call   800bd6 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802441:	e8 11 e7 ff ff       	call   800b57 <sys_cgetc>
  802446:	85 c0                	test   %eax,%eax
  802448:	74 f2                	je     80243c <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80244a:	85 c0                	test   %eax,%eax
  80244c:	78 16                	js     802464 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80244e:	83 f8 04             	cmp    $0x4,%eax
  802451:	74 0c                	je     80245f <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802453:	8b 55 0c             	mov    0xc(%ebp),%edx
  802456:	88 02                	mov    %al,(%edx)
	return 1;
  802458:	b8 01 00 00 00       	mov    $0x1,%eax
  80245d:	eb 05                	jmp    802464 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80245f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802464:	c9                   	leave  
  802465:	c3                   	ret    

00802466 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802466:	55                   	push   %ebp
  802467:	89 e5                	mov    %esp,%ebp
  802469:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80246c:	8b 45 08             	mov    0x8(%ebp),%eax
  80246f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802472:	6a 01                	push   $0x1
  802474:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802477:	50                   	push   %eax
  802478:	e8 bc e6 ff ff       	call   800b39 <sys_cputs>
}
  80247d:	83 c4 10             	add    $0x10,%esp
  802480:	c9                   	leave  
  802481:	c3                   	ret    

00802482 <getchar>:

int
getchar(void)
{
  802482:	55                   	push   %ebp
  802483:	89 e5                	mov    %esp,%ebp
  802485:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802488:	6a 01                	push   $0x1
  80248a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80248d:	50                   	push   %eax
  80248e:	6a 00                	push   $0x0
  802490:	e8 4c ec ff ff       	call   8010e1 <read>
	if (r < 0)
  802495:	83 c4 10             	add    $0x10,%esp
  802498:	85 c0                	test   %eax,%eax
  80249a:	78 0f                	js     8024ab <getchar+0x29>
		return r;
	if (r < 1)
  80249c:	85 c0                	test   %eax,%eax
  80249e:	7e 06                	jle    8024a6 <getchar+0x24>
		return -E_EOF;
	return c;
  8024a0:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8024a4:	eb 05                	jmp    8024ab <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8024a6:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8024ab:	c9                   	leave  
  8024ac:	c3                   	ret    

008024ad <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8024ad:	55                   	push   %ebp
  8024ae:	89 e5                	mov    %esp,%ebp
  8024b0:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8024b3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024b6:	50                   	push   %eax
  8024b7:	ff 75 08             	pushl  0x8(%ebp)
  8024ba:	e8 bc e9 ff ff       	call   800e7b <fd_lookup>
  8024bf:	83 c4 10             	add    $0x10,%esp
  8024c2:	85 c0                	test   %eax,%eax
  8024c4:	78 11                	js     8024d7 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8024c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024c9:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8024cf:	39 10                	cmp    %edx,(%eax)
  8024d1:	0f 94 c0             	sete   %al
  8024d4:	0f b6 c0             	movzbl %al,%eax
}
  8024d7:	c9                   	leave  
  8024d8:	c3                   	ret    

008024d9 <opencons>:

int
opencons(void)
{
  8024d9:	55                   	push   %ebp
  8024da:	89 e5                	mov    %esp,%ebp
  8024dc:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8024df:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024e2:	50                   	push   %eax
  8024e3:	e8 44 e9 ff ff       	call   800e2c <fd_alloc>
  8024e8:	83 c4 10             	add    $0x10,%esp
		return r;
  8024eb:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8024ed:	85 c0                	test   %eax,%eax
  8024ef:	78 3e                	js     80252f <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8024f1:	83 ec 04             	sub    $0x4,%esp
  8024f4:	68 07 04 00 00       	push   $0x407
  8024f9:	ff 75 f4             	pushl  -0xc(%ebp)
  8024fc:	6a 00                	push   $0x0
  8024fe:	e8 f2 e6 ff ff       	call   800bf5 <sys_page_alloc>
  802503:	83 c4 10             	add    $0x10,%esp
		return r;
  802506:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802508:	85 c0                	test   %eax,%eax
  80250a:	78 23                	js     80252f <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80250c:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802512:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802515:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802517:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80251a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802521:	83 ec 0c             	sub    $0xc,%esp
  802524:	50                   	push   %eax
  802525:	e8 db e8 ff ff       	call   800e05 <fd2num>
  80252a:	89 c2                	mov    %eax,%edx
  80252c:	83 c4 10             	add    $0x10,%esp
}
  80252f:	89 d0                	mov    %edx,%eax
  802531:	c9                   	leave  
  802532:	c3                   	ret    

00802533 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802533:	55                   	push   %ebp
  802534:	89 e5                	mov    %esp,%ebp
  802536:	56                   	push   %esi
  802537:	53                   	push   %ebx
  802538:	8b 75 08             	mov    0x8(%ebp),%esi
  80253b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80253e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  802541:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  802543:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  802548:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  80254b:	83 ec 0c             	sub    $0xc,%esp
  80254e:	50                   	push   %eax
  80254f:	e8 51 e8 ff ff       	call   800da5 <sys_ipc_recv>

	if (r < 0) {
  802554:	83 c4 10             	add    $0x10,%esp
  802557:	85 c0                	test   %eax,%eax
  802559:	79 16                	jns    802571 <ipc_recv+0x3e>
		if (from_env_store)
  80255b:	85 f6                	test   %esi,%esi
  80255d:	74 06                	je     802565 <ipc_recv+0x32>
			*from_env_store = 0;
  80255f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  802565:	85 db                	test   %ebx,%ebx
  802567:	74 2c                	je     802595 <ipc_recv+0x62>
			*perm_store = 0;
  802569:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80256f:	eb 24                	jmp    802595 <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  802571:	85 f6                	test   %esi,%esi
  802573:	74 0a                	je     80257f <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  802575:	a1 08 40 80 00       	mov    0x804008,%eax
  80257a:	8b 40 74             	mov    0x74(%eax),%eax
  80257d:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  80257f:	85 db                	test   %ebx,%ebx
  802581:	74 0a                	je     80258d <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  802583:	a1 08 40 80 00       	mov    0x804008,%eax
  802588:	8b 40 78             	mov    0x78(%eax),%eax
  80258b:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  80258d:	a1 08 40 80 00       	mov    0x804008,%eax
  802592:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  802595:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802598:	5b                   	pop    %ebx
  802599:	5e                   	pop    %esi
  80259a:	5d                   	pop    %ebp
  80259b:	c3                   	ret    

0080259c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80259c:	55                   	push   %ebp
  80259d:	89 e5                	mov    %esp,%ebp
  80259f:	57                   	push   %edi
  8025a0:	56                   	push   %esi
  8025a1:	53                   	push   %ebx
  8025a2:	83 ec 0c             	sub    $0xc,%esp
  8025a5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8025a8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8025ab:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  8025ae:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  8025b0:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  8025b5:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  8025b8:	ff 75 14             	pushl  0x14(%ebp)
  8025bb:	53                   	push   %ebx
  8025bc:	56                   	push   %esi
  8025bd:	57                   	push   %edi
  8025be:	e8 bf e7 ff ff       	call   800d82 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  8025c3:	83 c4 10             	add    $0x10,%esp
  8025c6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8025c9:	75 07                	jne    8025d2 <ipc_send+0x36>
			sys_yield();
  8025cb:	e8 06 e6 ff ff       	call   800bd6 <sys_yield>
  8025d0:	eb e6                	jmp    8025b8 <ipc_send+0x1c>
		} else if (r < 0) {
  8025d2:	85 c0                	test   %eax,%eax
  8025d4:	79 12                	jns    8025e8 <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  8025d6:	50                   	push   %eax
  8025d7:	68 fc 2e 80 00       	push   $0x802efc
  8025dc:	6a 51                	push   $0x51
  8025de:	68 09 2f 80 00       	push   $0x802f09
  8025e3:	e8 ac db ff ff       	call   800194 <_panic>
		}
	}
}
  8025e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025eb:	5b                   	pop    %ebx
  8025ec:	5e                   	pop    %esi
  8025ed:	5f                   	pop    %edi
  8025ee:	5d                   	pop    %ebp
  8025ef:	c3                   	ret    

008025f0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8025f0:	55                   	push   %ebp
  8025f1:	89 e5                	mov    %esp,%ebp
  8025f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8025f6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8025fb:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8025fe:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802604:	8b 52 50             	mov    0x50(%edx),%edx
  802607:	39 ca                	cmp    %ecx,%edx
  802609:	75 0d                	jne    802618 <ipc_find_env+0x28>
			return envs[i].env_id;
  80260b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80260e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802613:	8b 40 48             	mov    0x48(%eax),%eax
  802616:	eb 0f                	jmp    802627 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802618:	83 c0 01             	add    $0x1,%eax
  80261b:	3d 00 04 00 00       	cmp    $0x400,%eax
  802620:	75 d9                	jne    8025fb <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802622:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802627:	5d                   	pop    %ebp
  802628:	c3                   	ret    

00802629 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802629:	55                   	push   %ebp
  80262a:	89 e5                	mov    %esp,%ebp
  80262c:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80262f:	89 d0                	mov    %edx,%eax
  802631:	c1 e8 16             	shr    $0x16,%eax
  802634:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80263b:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802640:	f6 c1 01             	test   $0x1,%cl
  802643:	74 1d                	je     802662 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802645:	c1 ea 0c             	shr    $0xc,%edx
  802648:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80264f:	f6 c2 01             	test   $0x1,%dl
  802652:	74 0e                	je     802662 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802654:	c1 ea 0c             	shr    $0xc,%edx
  802657:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80265e:	ef 
  80265f:	0f b7 c0             	movzwl %ax,%eax
}
  802662:	5d                   	pop    %ebp
  802663:	c3                   	ret    
  802664:	66 90                	xchg   %ax,%ax
  802666:	66 90                	xchg   %ax,%ax
  802668:	66 90                	xchg   %ax,%ax
  80266a:	66 90                	xchg   %ax,%ax
  80266c:	66 90                	xchg   %ax,%ax
  80266e:	66 90                	xchg   %ax,%ax

00802670 <__udivdi3>:
  802670:	55                   	push   %ebp
  802671:	57                   	push   %edi
  802672:	56                   	push   %esi
  802673:	53                   	push   %ebx
  802674:	83 ec 1c             	sub    $0x1c,%esp
  802677:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80267b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80267f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802683:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802687:	85 f6                	test   %esi,%esi
  802689:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80268d:	89 ca                	mov    %ecx,%edx
  80268f:	89 f8                	mov    %edi,%eax
  802691:	75 3d                	jne    8026d0 <__udivdi3+0x60>
  802693:	39 cf                	cmp    %ecx,%edi
  802695:	0f 87 c5 00 00 00    	ja     802760 <__udivdi3+0xf0>
  80269b:	85 ff                	test   %edi,%edi
  80269d:	89 fd                	mov    %edi,%ebp
  80269f:	75 0b                	jne    8026ac <__udivdi3+0x3c>
  8026a1:	b8 01 00 00 00       	mov    $0x1,%eax
  8026a6:	31 d2                	xor    %edx,%edx
  8026a8:	f7 f7                	div    %edi
  8026aa:	89 c5                	mov    %eax,%ebp
  8026ac:	89 c8                	mov    %ecx,%eax
  8026ae:	31 d2                	xor    %edx,%edx
  8026b0:	f7 f5                	div    %ebp
  8026b2:	89 c1                	mov    %eax,%ecx
  8026b4:	89 d8                	mov    %ebx,%eax
  8026b6:	89 cf                	mov    %ecx,%edi
  8026b8:	f7 f5                	div    %ebp
  8026ba:	89 c3                	mov    %eax,%ebx
  8026bc:	89 d8                	mov    %ebx,%eax
  8026be:	89 fa                	mov    %edi,%edx
  8026c0:	83 c4 1c             	add    $0x1c,%esp
  8026c3:	5b                   	pop    %ebx
  8026c4:	5e                   	pop    %esi
  8026c5:	5f                   	pop    %edi
  8026c6:	5d                   	pop    %ebp
  8026c7:	c3                   	ret    
  8026c8:	90                   	nop
  8026c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8026d0:	39 ce                	cmp    %ecx,%esi
  8026d2:	77 74                	ja     802748 <__udivdi3+0xd8>
  8026d4:	0f bd fe             	bsr    %esi,%edi
  8026d7:	83 f7 1f             	xor    $0x1f,%edi
  8026da:	0f 84 98 00 00 00    	je     802778 <__udivdi3+0x108>
  8026e0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8026e5:	89 f9                	mov    %edi,%ecx
  8026e7:	89 c5                	mov    %eax,%ebp
  8026e9:	29 fb                	sub    %edi,%ebx
  8026eb:	d3 e6                	shl    %cl,%esi
  8026ed:	89 d9                	mov    %ebx,%ecx
  8026ef:	d3 ed                	shr    %cl,%ebp
  8026f1:	89 f9                	mov    %edi,%ecx
  8026f3:	d3 e0                	shl    %cl,%eax
  8026f5:	09 ee                	or     %ebp,%esi
  8026f7:	89 d9                	mov    %ebx,%ecx
  8026f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8026fd:	89 d5                	mov    %edx,%ebp
  8026ff:	8b 44 24 08          	mov    0x8(%esp),%eax
  802703:	d3 ed                	shr    %cl,%ebp
  802705:	89 f9                	mov    %edi,%ecx
  802707:	d3 e2                	shl    %cl,%edx
  802709:	89 d9                	mov    %ebx,%ecx
  80270b:	d3 e8                	shr    %cl,%eax
  80270d:	09 c2                	or     %eax,%edx
  80270f:	89 d0                	mov    %edx,%eax
  802711:	89 ea                	mov    %ebp,%edx
  802713:	f7 f6                	div    %esi
  802715:	89 d5                	mov    %edx,%ebp
  802717:	89 c3                	mov    %eax,%ebx
  802719:	f7 64 24 0c          	mull   0xc(%esp)
  80271d:	39 d5                	cmp    %edx,%ebp
  80271f:	72 10                	jb     802731 <__udivdi3+0xc1>
  802721:	8b 74 24 08          	mov    0x8(%esp),%esi
  802725:	89 f9                	mov    %edi,%ecx
  802727:	d3 e6                	shl    %cl,%esi
  802729:	39 c6                	cmp    %eax,%esi
  80272b:	73 07                	jae    802734 <__udivdi3+0xc4>
  80272d:	39 d5                	cmp    %edx,%ebp
  80272f:	75 03                	jne    802734 <__udivdi3+0xc4>
  802731:	83 eb 01             	sub    $0x1,%ebx
  802734:	31 ff                	xor    %edi,%edi
  802736:	89 d8                	mov    %ebx,%eax
  802738:	89 fa                	mov    %edi,%edx
  80273a:	83 c4 1c             	add    $0x1c,%esp
  80273d:	5b                   	pop    %ebx
  80273e:	5e                   	pop    %esi
  80273f:	5f                   	pop    %edi
  802740:	5d                   	pop    %ebp
  802741:	c3                   	ret    
  802742:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802748:	31 ff                	xor    %edi,%edi
  80274a:	31 db                	xor    %ebx,%ebx
  80274c:	89 d8                	mov    %ebx,%eax
  80274e:	89 fa                	mov    %edi,%edx
  802750:	83 c4 1c             	add    $0x1c,%esp
  802753:	5b                   	pop    %ebx
  802754:	5e                   	pop    %esi
  802755:	5f                   	pop    %edi
  802756:	5d                   	pop    %ebp
  802757:	c3                   	ret    
  802758:	90                   	nop
  802759:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802760:	89 d8                	mov    %ebx,%eax
  802762:	f7 f7                	div    %edi
  802764:	31 ff                	xor    %edi,%edi
  802766:	89 c3                	mov    %eax,%ebx
  802768:	89 d8                	mov    %ebx,%eax
  80276a:	89 fa                	mov    %edi,%edx
  80276c:	83 c4 1c             	add    $0x1c,%esp
  80276f:	5b                   	pop    %ebx
  802770:	5e                   	pop    %esi
  802771:	5f                   	pop    %edi
  802772:	5d                   	pop    %ebp
  802773:	c3                   	ret    
  802774:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802778:	39 ce                	cmp    %ecx,%esi
  80277a:	72 0c                	jb     802788 <__udivdi3+0x118>
  80277c:	31 db                	xor    %ebx,%ebx
  80277e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802782:	0f 87 34 ff ff ff    	ja     8026bc <__udivdi3+0x4c>
  802788:	bb 01 00 00 00       	mov    $0x1,%ebx
  80278d:	e9 2a ff ff ff       	jmp    8026bc <__udivdi3+0x4c>
  802792:	66 90                	xchg   %ax,%ax
  802794:	66 90                	xchg   %ax,%ax
  802796:	66 90                	xchg   %ax,%ax
  802798:	66 90                	xchg   %ax,%ax
  80279a:	66 90                	xchg   %ax,%ax
  80279c:	66 90                	xchg   %ax,%ax
  80279e:	66 90                	xchg   %ax,%ax

008027a0 <__umoddi3>:
  8027a0:	55                   	push   %ebp
  8027a1:	57                   	push   %edi
  8027a2:	56                   	push   %esi
  8027a3:	53                   	push   %ebx
  8027a4:	83 ec 1c             	sub    $0x1c,%esp
  8027a7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8027ab:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8027af:	8b 74 24 34          	mov    0x34(%esp),%esi
  8027b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8027b7:	85 d2                	test   %edx,%edx
  8027b9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8027bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8027c1:	89 f3                	mov    %esi,%ebx
  8027c3:	89 3c 24             	mov    %edi,(%esp)
  8027c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8027ca:	75 1c                	jne    8027e8 <__umoddi3+0x48>
  8027cc:	39 f7                	cmp    %esi,%edi
  8027ce:	76 50                	jbe    802820 <__umoddi3+0x80>
  8027d0:	89 c8                	mov    %ecx,%eax
  8027d2:	89 f2                	mov    %esi,%edx
  8027d4:	f7 f7                	div    %edi
  8027d6:	89 d0                	mov    %edx,%eax
  8027d8:	31 d2                	xor    %edx,%edx
  8027da:	83 c4 1c             	add    $0x1c,%esp
  8027dd:	5b                   	pop    %ebx
  8027de:	5e                   	pop    %esi
  8027df:	5f                   	pop    %edi
  8027e0:	5d                   	pop    %ebp
  8027e1:	c3                   	ret    
  8027e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8027e8:	39 f2                	cmp    %esi,%edx
  8027ea:	89 d0                	mov    %edx,%eax
  8027ec:	77 52                	ja     802840 <__umoddi3+0xa0>
  8027ee:	0f bd ea             	bsr    %edx,%ebp
  8027f1:	83 f5 1f             	xor    $0x1f,%ebp
  8027f4:	75 5a                	jne    802850 <__umoddi3+0xb0>
  8027f6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8027fa:	0f 82 e0 00 00 00    	jb     8028e0 <__umoddi3+0x140>
  802800:	39 0c 24             	cmp    %ecx,(%esp)
  802803:	0f 86 d7 00 00 00    	jbe    8028e0 <__umoddi3+0x140>
  802809:	8b 44 24 08          	mov    0x8(%esp),%eax
  80280d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802811:	83 c4 1c             	add    $0x1c,%esp
  802814:	5b                   	pop    %ebx
  802815:	5e                   	pop    %esi
  802816:	5f                   	pop    %edi
  802817:	5d                   	pop    %ebp
  802818:	c3                   	ret    
  802819:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802820:	85 ff                	test   %edi,%edi
  802822:	89 fd                	mov    %edi,%ebp
  802824:	75 0b                	jne    802831 <__umoddi3+0x91>
  802826:	b8 01 00 00 00       	mov    $0x1,%eax
  80282b:	31 d2                	xor    %edx,%edx
  80282d:	f7 f7                	div    %edi
  80282f:	89 c5                	mov    %eax,%ebp
  802831:	89 f0                	mov    %esi,%eax
  802833:	31 d2                	xor    %edx,%edx
  802835:	f7 f5                	div    %ebp
  802837:	89 c8                	mov    %ecx,%eax
  802839:	f7 f5                	div    %ebp
  80283b:	89 d0                	mov    %edx,%eax
  80283d:	eb 99                	jmp    8027d8 <__umoddi3+0x38>
  80283f:	90                   	nop
  802840:	89 c8                	mov    %ecx,%eax
  802842:	89 f2                	mov    %esi,%edx
  802844:	83 c4 1c             	add    $0x1c,%esp
  802847:	5b                   	pop    %ebx
  802848:	5e                   	pop    %esi
  802849:	5f                   	pop    %edi
  80284a:	5d                   	pop    %ebp
  80284b:	c3                   	ret    
  80284c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802850:	8b 34 24             	mov    (%esp),%esi
  802853:	bf 20 00 00 00       	mov    $0x20,%edi
  802858:	89 e9                	mov    %ebp,%ecx
  80285a:	29 ef                	sub    %ebp,%edi
  80285c:	d3 e0                	shl    %cl,%eax
  80285e:	89 f9                	mov    %edi,%ecx
  802860:	89 f2                	mov    %esi,%edx
  802862:	d3 ea                	shr    %cl,%edx
  802864:	89 e9                	mov    %ebp,%ecx
  802866:	09 c2                	or     %eax,%edx
  802868:	89 d8                	mov    %ebx,%eax
  80286a:	89 14 24             	mov    %edx,(%esp)
  80286d:	89 f2                	mov    %esi,%edx
  80286f:	d3 e2                	shl    %cl,%edx
  802871:	89 f9                	mov    %edi,%ecx
  802873:	89 54 24 04          	mov    %edx,0x4(%esp)
  802877:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80287b:	d3 e8                	shr    %cl,%eax
  80287d:	89 e9                	mov    %ebp,%ecx
  80287f:	89 c6                	mov    %eax,%esi
  802881:	d3 e3                	shl    %cl,%ebx
  802883:	89 f9                	mov    %edi,%ecx
  802885:	89 d0                	mov    %edx,%eax
  802887:	d3 e8                	shr    %cl,%eax
  802889:	89 e9                	mov    %ebp,%ecx
  80288b:	09 d8                	or     %ebx,%eax
  80288d:	89 d3                	mov    %edx,%ebx
  80288f:	89 f2                	mov    %esi,%edx
  802891:	f7 34 24             	divl   (%esp)
  802894:	89 d6                	mov    %edx,%esi
  802896:	d3 e3                	shl    %cl,%ebx
  802898:	f7 64 24 04          	mull   0x4(%esp)
  80289c:	39 d6                	cmp    %edx,%esi
  80289e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8028a2:	89 d1                	mov    %edx,%ecx
  8028a4:	89 c3                	mov    %eax,%ebx
  8028a6:	72 08                	jb     8028b0 <__umoddi3+0x110>
  8028a8:	75 11                	jne    8028bb <__umoddi3+0x11b>
  8028aa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8028ae:	73 0b                	jae    8028bb <__umoddi3+0x11b>
  8028b0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8028b4:	1b 14 24             	sbb    (%esp),%edx
  8028b7:	89 d1                	mov    %edx,%ecx
  8028b9:	89 c3                	mov    %eax,%ebx
  8028bb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8028bf:	29 da                	sub    %ebx,%edx
  8028c1:	19 ce                	sbb    %ecx,%esi
  8028c3:	89 f9                	mov    %edi,%ecx
  8028c5:	89 f0                	mov    %esi,%eax
  8028c7:	d3 e0                	shl    %cl,%eax
  8028c9:	89 e9                	mov    %ebp,%ecx
  8028cb:	d3 ea                	shr    %cl,%edx
  8028cd:	89 e9                	mov    %ebp,%ecx
  8028cf:	d3 ee                	shr    %cl,%esi
  8028d1:	09 d0                	or     %edx,%eax
  8028d3:	89 f2                	mov    %esi,%edx
  8028d5:	83 c4 1c             	add    $0x1c,%esp
  8028d8:	5b                   	pop    %ebx
  8028d9:	5e                   	pop    %esi
  8028da:	5f                   	pop    %edi
  8028db:	5d                   	pop    %ebp
  8028dc:	c3                   	ret    
  8028dd:	8d 76 00             	lea    0x0(%esi),%esi
  8028e0:	29 f9                	sub    %edi,%ecx
  8028e2:	19 d6                	sbb    %edx,%esi
  8028e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8028e8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8028ec:	e9 18 ff ff ff       	jmp    802809 <__umoddi3+0x69>
