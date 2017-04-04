
obj/user/primes.debug:     file format elf32-i386


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
  80002c:	e8 c7 00 00 00       	call   8000f8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
	int i, id, p;
	envid_t envid;

	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  80003c:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80003f:	83 ec 04             	sub    $0x4,%esp
  800042:	6a 00                	push   $0x0
  800044:	6a 00                	push   $0x0
  800046:	56                   	push   %esi
  800047:	e8 a6 0f 00 00       	call   800ff2 <ipc_recv>
  80004c:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80004e:	a1 04 40 80 00       	mov    0x804004,%eax
  800053:	8b 40 5c             	mov    0x5c(%eax),%eax
  800056:	83 c4 0c             	add    $0xc,%esp
  800059:	53                   	push   %ebx
  80005a:	50                   	push   %eax
  80005b:	68 40 21 80 00       	push   $0x802140
  800060:	e8 cc 01 00 00       	call   800231 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800065:	e8 93 0e 00 00       	call   800efd <fork>
  80006a:	89 c7                	mov    %eax,%edi
  80006c:	83 c4 10             	add    $0x10,%esp
  80006f:	85 c0                	test   %eax,%eax
  800071:	79 12                	jns    800085 <primeproc+0x52>
		panic("fork: %e", id);
  800073:	50                   	push   %eax
  800074:	68 f3 24 80 00       	push   $0x8024f3
  800079:	6a 1a                	push   $0x1a
  80007b:	68 4c 21 80 00       	push   $0x80214c
  800080:	e8 d3 00 00 00       	call   800158 <_panic>
	if (id == 0)
  800085:	85 c0                	test   %eax,%eax
  800087:	74 b6                	je     80003f <primeproc+0xc>
		goto top;

	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  800089:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80008c:	83 ec 04             	sub    $0x4,%esp
  80008f:	6a 00                	push   $0x0
  800091:	6a 00                	push   $0x0
  800093:	56                   	push   %esi
  800094:	e8 59 0f 00 00       	call   800ff2 <ipc_recv>
  800099:	89 c1                	mov    %eax,%ecx
		if (i % p)
  80009b:	99                   	cltd   
  80009c:	f7 fb                	idiv   %ebx
  80009e:	83 c4 10             	add    $0x10,%esp
  8000a1:	85 d2                	test   %edx,%edx
  8000a3:	74 e7                	je     80008c <primeproc+0x59>
			ipc_send(id, i, 0, 0);
  8000a5:	6a 00                	push   $0x0
  8000a7:	6a 00                	push   $0x0
  8000a9:	51                   	push   %ecx
  8000aa:	57                   	push   %edi
  8000ab:	e8 ab 0f 00 00       	call   80105b <ipc_send>
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	eb d7                	jmp    80008c <primeproc+0x59>

008000b5 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  8000ba:	e8 3e 0e 00 00       	call   800efd <fork>
  8000bf:	89 c6                	mov    %eax,%esi
  8000c1:	85 c0                	test   %eax,%eax
  8000c3:	79 12                	jns    8000d7 <umain+0x22>
		panic("fork: %e", id);
  8000c5:	50                   	push   %eax
  8000c6:	68 f3 24 80 00       	push   $0x8024f3
  8000cb:	6a 2d                	push   $0x2d
  8000cd:	68 4c 21 80 00       	push   $0x80214c
  8000d2:	e8 81 00 00 00       	call   800158 <_panic>
  8000d7:	bb 02 00 00 00       	mov    $0x2,%ebx
	if (id == 0)
  8000dc:	85 c0                	test   %eax,%eax
  8000de:	75 05                	jne    8000e5 <umain+0x30>
		primeproc();
  8000e0:	e8 4e ff ff ff       	call   800033 <primeproc>

	// feed all the integers through
	for (i = 2; ; i++)
		ipc_send(id, i, 0, 0);
  8000e5:	6a 00                	push   $0x0
  8000e7:	6a 00                	push   $0x0
  8000e9:	53                   	push   %ebx
  8000ea:	56                   	push   %esi
  8000eb:	e8 6b 0f 00 00       	call   80105b <ipc_send>
		panic("fork: %e", id);
	if (id == 0)
		primeproc();

	// feed all the integers through
	for (i = 2; ; i++)
  8000f0:	83 c3 01             	add    $0x1,%ebx
  8000f3:	83 c4 10             	add    $0x10,%esp
  8000f6:	eb ed                	jmp    8000e5 <umain+0x30>

008000f8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	56                   	push   %esi
  8000fc:	53                   	push   %ebx
  8000fd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800100:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800103:	e8 73 0a 00 00       	call   800b7b <sys_getenvid>
  800108:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800110:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800115:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80011a:	85 db                	test   %ebx,%ebx
  80011c:	7e 07                	jle    800125 <libmain+0x2d>
		binaryname = argv[0];
  80011e:	8b 06                	mov    (%esi),%eax
  800120:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800125:	83 ec 08             	sub    $0x8,%esp
  800128:	56                   	push   %esi
  800129:	53                   	push   %ebx
  80012a:	e8 86 ff ff ff       	call   8000b5 <umain>

	// exit gracefully
	exit();
  80012f:	e8 0a 00 00 00       	call   80013e <exit>
}
  800134:	83 c4 10             	add    $0x10,%esp
  800137:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80013a:	5b                   	pop    %ebx
  80013b:	5e                   	pop    %esi
  80013c:	5d                   	pop    %ebp
  80013d:	c3                   	ret    

0080013e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80013e:	55                   	push   %ebp
  80013f:	89 e5                	mov    %esp,%ebp
  800141:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800144:	e8 6a 11 00 00       	call   8012b3 <close_all>
	sys_env_destroy(0);
  800149:	83 ec 0c             	sub    $0xc,%esp
  80014c:	6a 00                	push   $0x0
  80014e:	e8 e7 09 00 00       	call   800b3a <sys_env_destroy>
}
  800153:	83 c4 10             	add    $0x10,%esp
  800156:	c9                   	leave  
  800157:	c3                   	ret    

00800158 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800158:	55                   	push   %ebp
  800159:	89 e5                	mov    %esp,%ebp
  80015b:	56                   	push   %esi
  80015c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80015d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800160:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800166:	e8 10 0a 00 00       	call   800b7b <sys_getenvid>
  80016b:	83 ec 0c             	sub    $0xc,%esp
  80016e:	ff 75 0c             	pushl  0xc(%ebp)
  800171:	ff 75 08             	pushl  0x8(%ebp)
  800174:	56                   	push   %esi
  800175:	50                   	push   %eax
  800176:	68 64 21 80 00       	push   $0x802164
  80017b:	e8 b1 00 00 00       	call   800231 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800180:	83 c4 18             	add    $0x18,%esp
  800183:	53                   	push   %ebx
  800184:	ff 75 10             	pushl  0x10(%ebp)
  800187:	e8 54 00 00 00       	call   8001e0 <vcprintf>
	cprintf("\n");
  80018c:	c7 04 24 5b 26 80 00 	movl   $0x80265b,(%esp)
  800193:	e8 99 00 00 00       	call   800231 <cprintf>
  800198:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80019b:	cc                   	int3   
  80019c:	eb fd                	jmp    80019b <_panic+0x43>

0080019e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80019e:	55                   	push   %ebp
  80019f:	89 e5                	mov    %esp,%ebp
  8001a1:	53                   	push   %ebx
  8001a2:	83 ec 04             	sub    $0x4,%esp
  8001a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001a8:	8b 13                	mov    (%ebx),%edx
  8001aa:	8d 42 01             	lea    0x1(%edx),%eax
  8001ad:	89 03                	mov    %eax,(%ebx)
  8001af:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001b2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001b6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001bb:	75 1a                	jne    8001d7 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001bd:	83 ec 08             	sub    $0x8,%esp
  8001c0:	68 ff 00 00 00       	push   $0xff
  8001c5:	8d 43 08             	lea    0x8(%ebx),%eax
  8001c8:	50                   	push   %eax
  8001c9:	e8 2f 09 00 00       	call   800afd <sys_cputs>
		b->idx = 0;
  8001ce:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001d4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001d7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001de:	c9                   	leave  
  8001df:	c3                   	ret    

008001e0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001e0:	55                   	push   %ebp
  8001e1:	89 e5                	mov    %esp,%ebp
  8001e3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001e9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f0:	00 00 00 
	b.cnt = 0;
  8001f3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001fa:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001fd:	ff 75 0c             	pushl  0xc(%ebp)
  800200:	ff 75 08             	pushl  0x8(%ebp)
  800203:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800209:	50                   	push   %eax
  80020a:	68 9e 01 80 00       	push   $0x80019e
  80020f:	e8 54 01 00 00       	call   800368 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800214:	83 c4 08             	add    $0x8,%esp
  800217:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80021d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800223:	50                   	push   %eax
  800224:	e8 d4 08 00 00       	call   800afd <sys_cputs>

	return b.cnt;
}
  800229:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80022f:	c9                   	leave  
  800230:	c3                   	ret    

00800231 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800231:	55                   	push   %ebp
  800232:	89 e5                	mov    %esp,%ebp
  800234:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800237:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80023a:	50                   	push   %eax
  80023b:	ff 75 08             	pushl  0x8(%ebp)
  80023e:	e8 9d ff ff ff       	call   8001e0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800243:	c9                   	leave  
  800244:	c3                   	ret    

00800245 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800245:	55                   	push   %ebp
  800246:	89 e5                	mov    %esp,%ebp
  800248:	57                   	push   %edi
  800249:	56                   	push   %esi
  80024a:	53                   	push   %ebx
  80024b:	83 ec 1c             	sub    $0x1c,%esp
  80024e:	89 c7                	mov    %eax,%edi
  800250:	89 d6                	mov    %edx,%esi
  800252:	8b 45 08             	mov    0x8(%ebp),%eax
  800255:	8b 55 0c             	mov    0xc(%ebp),%edx
  800258:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80025b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80025e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800261:	bb 00 00 00 00       	mov    $0x0,%ebx
  800266:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800269:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80026c:	39 d3                	cmp    %edx,%ebx
  80026e:	72 05                	jb     800275 <printnum+0x30>
  800270:	39 45 10             	cmp    %eax,0x10(%ebp)
  800273:	77 45                	ja     8002ba <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800275:	83 ec 0c             	sub    $0xc,%esp
  800278:	ff 75 18             	pushl  0x18(%ebp)
  80027b:	8b 45 14             	mov    0x14(%ebp),%eax
  80027e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800281:	53                   	push   %ebx
  800282:	ff 75 10             	pushl  0x10(%ebp)
  800285:	83 ec 08             	sub    $0x8,%esp
  800288:	ff 75 e4             	pushl  -0x1c(%ebp)
  80028b:	ff 75 e0             	pushl  -0x20(%ebp)
  80028e:	ff 75 dc             	pushl  -0x24(%ebp)
  800291:	ff 75 d8             	pushl  -0x28(%ebp)
  800294:	e8 17 1c 00 00       	call   801eb0 <__udivdi3>
  800299:	83 c4 18             	add    $0x18,%esp
  80029c:	52                   	push   %edx
  80029d:	50                   	push   %eax
  80029e:	89 f2                	mov    %esi,%edx
  8002a0:	89 f8                	mov    %edi,%eax
  8002a2:	e8 9e ff ff ff       	call   800245 <printnum>
  8002a7:	83 c4 20             	add    $0x20,%esp
  8002aa:	eb 18                	jmp    8002c4 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002ac:	83 ec 08             	sub    $0x8,%esp
  8002af:	56                   	push   %esi
  8002b0:	ff 75 18             	pushl  0x18(%ebp)
  8002b3:	ff d7                	call   *%edi
  8002b5:	83 c4 10             	add    $0x10,%esp
  8002b8:	eb 03                	jmp    8002bd <printnum+0x78>
  8002ba:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002bd:	83 eb 01             	sub    $0x1,%ebx
  8002c0:	85 db                	test   %ebx,%ebx
  8002c2:	7f e8                	jg     8002ac <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002c4:	83 ec 08             	sub    $0x8,%esp
  8002c7:	56                   	push   %esi
  8002c8:	83 ec 04             	sub    $0x4,%esp
  8002cb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002ce:	ff 75 e0             	pushl  -0x20(%ebp)
  8002d1:	ff 75 dc             	pushl  -0x24(%ebp)
  8002d4:	ff 75 d8             	pushl  -0x28(%ebp)
  8002d7:	e8 04 1d 00 00       	call   801fe0 <__umoddi3>
  8002dc:	83 c4 14             	add    $0x14,%esp
  8002df:	0f be 80 87 21 80 00 	movsbl 0x802187(%eax),%eax
  8002e6:	50                   	push   %eax
  8002e7:	ff d7                	call   *%edi
}
  8002e9:	83 c4 10             	add    $0x10,%esp
  8002ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ef:	5b                   	pop    %ebx
  8002f0:	5e                   	pop    %esi
  8002f1:	5f                   	pop    %edi
  8002f2:	5d                   	pop    %ebp
  8002f3:	c3                   	ret    

008002f4 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002f4:	55                   	push   %ebp
  8002f5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002f7:	83 fa 01             	cmp    $0x1,%edx
  8002fa:	7e 0e                	jle    80030a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002fc:	8b 10                	mov    (%eax),%edx
  8002fe:	8d 4a 08             	lea    0x8(%edx),%ecx
  800301:	89 08                	mov    %ecx,(%eax)
  800303:	8b 02                	mov    (%edx),%eax
  800305:	8b 52 04             	mov    0x4(%edx),%edx
  800308:	eb 22                	jmp    80032c <getuint+0x38>
	else if (lflag)
  80030a:	85 d2                	test   %edx,%edx
  80030c:	74 10                	je     80031e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80030e:	8b 10                	mov    (%eax),%edx
  800310:	8d 4a 04             	lea    0x4(%edx),%ecx
  800313:	89 08                	mov    %ecx,(%eax)
  800315:	8b 02                	mov    (%edx),%eax
  800317:	ba 00 00 00 00       	mov    $0x0,%edx
  80031c:	eb 0e                	jmp    80032c <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80031e:	8b 10                	mov    (%eax),%edx
  800320:	8d 4a 04             	lea    0x4(%edx),%ecx
  800323:	89 08                	mov    %ecx,(%eax)
  800325:	8b 02                	mov    (%edx),%eax
  800327:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80032c:	5d                   	pop    %ebp
  80032d:	c3                   	ret    

0080032e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80032e:	55                   	push   %ebp
  80032f:	89 e5                	mov    %esp,%ebp
  800331:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800334:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800338:	8b 10                	mov    (%eax),%edx
  80033a:	3b 50 04             	cmp    0x4(%eax),%edx
  80033d:	73 0a                	jae    800349 <sprintputch+0x1b>
		*b->buf++ = ch;
  80033f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800342:	89 08                	mov    %ecx,(%eax)
  800344:	8b 45 08             	mov    0x8(%ebp),%eax
  800347:	88 02                	mov    %al,(%edx)
}
  800349:	5d                   	pop    %ebp
  80034a:	c3                   	ret    

0080034b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80034b:	55                   	push   %ebp
  80034c:	89 e5                	mov    %esp,%ebp
  80034e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800351:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800354:	50                   	push   %eax
  800355:	ff 75 10             	pushl  0x10(%ebp)
  800358:	ff 75 0c             	pushl  0xc(%ebp)
  80035b:	ff 75 08             	pushl  0x8(%ebp)
  80035e:	e8 05 00 00 00       	call   800368 <vprintfmt>
	va_end(ap);
}
  800363:	83 c4 10             	add    $0x10,%esp
  800366:	c9                   	leave  
  800367:	c3                   	ret    

00800368 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800368:	55                   	push   %ebp
  800369:	89 e5                	mov    %esp,%ebp
  80036b:	57                   	push   %edi
  80036c:	56                   	push   %esi
  80036d:	53                   	push   %ebx
  80036e:	83 ec 2c             	sub    $0x2c,%esp
  800371:	8b 75 08             	mov    0x8(%ebp),%esi
  800374:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800377:	8b 7d 10             	mov    0x10(%ebp),%edi
  80037a:	eb 12                	jmp    80038e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80037c:	85 c0                	test   %eax,%eax
  80037e:	0f 84 89 03 00 00    	je     80070d <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800384:	83 ec 08             	sub    $0x8,%esp
  800387:	53                   	push   %ebx
  800388:	50                   	push   %eax
  800389:	ff d6                	call   *%esi
  80038b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80038e:	83 c7 01             	add    $0x1,%edi
  800391:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800395:	83 f8 25             	cmp    $0x25,%eax
  800398:	75 e2                	jne    80037c <vprintfmt+0x14>
  80039a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80039e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003a5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003ac:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b8:	eb 07                	jmp    8003c1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003bd:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c1:	8d 47 01             	lea    0x1(%edi),%eax
  8003c4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003c7:	0f b6 07             	movzbl (%edi),%eax
  8003ca:	0f b6 c8             	movzbl %al,%ecx
  8003cd:	83 e8 23             	sub    $0x23,%eax
  8003d0:	3c 55                	cmp    $0x55,%al
  8003d2:	0f 87 1a 03 00 00    	ja     8006f2 <vprintfmt+0x38a>
  8003d8:	0f b6 c0             	movzbl %al,%eax
  8003db:	ff 24 85 c0 22 80 00 	jmp    *0x8022c0(,%eax,4)
  8003e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003e5:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003e9:	eb d6                	jmp    8003c1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8003f3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003f6:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003f9:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003fd:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800400:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800403:	83 fa 09             	cmp    $0x9,%edx
  800406:	77 39                	ja     800441 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800408:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80040b:	eb e9                	jmp    8003f6 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80040d:	8b 45 14             	mov    0x14(%ebp),%eax
  800410:	8d 48 04             	lea    0x4(%eax),%ecx
  800413:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800416:	8b 00                	mov    (%eax),%eax
  800418:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80041e:	eb 27                	jmp    800447 <vprintfmt+0xdf>
  800420:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800423:	85 c0                	test   %eax,%eax
  800425:	b9 00 00 00 00       	mov    $0x0,%ecx
  80042a:	0f 49 c8             	cmovns %eax,%ecx
  80042d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800430:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800433:	eb 8c                	jmp    8003c1 <vprintfmt+0x59>
  800435:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800438:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80043f:	eb 80                	jmp    8003c1 <vprintfmt+0x59>
  800441:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800444:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800447:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80044b:	0f 89 70 ff ff ff    	jns    8003c1 <vprintfmt+0x59>
				width = precision, precision = -1;
  800451:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800454:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800457:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80045e:	e9 5e ff ff ff       	jmp    8003c1 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800463:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800466:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800469:	e9 53 ff ff ff       	jmp    8003c1 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80046e:	8b 45 14             	mov    0x14(%ebp),%eax
  800471:	8d 50 04             	lea    0x4(%eax),%edx
  800474:	89 55 14             	mov    %edx,0x14(%ebp)
  800477:	83 ec 08             	sub    $0x8,%esp
  80047a:	53                   	push   %ebx
  80047b:	ff 30                	pushl  (%eax)
  80047d:	ff d6                	call   *%esi
			break;
  80047f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800482:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800485:	e9 04 ff ff ff       	jmp    80038e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80048a:	8b 45 14             	mov    0x14(%ebp),%eax
  80048d:	8d 50 04             	lea    0x4(%eax),%edx
  800490:	89 55 14             	mov    %edx,0x14(%ebp)
  800493:	8b 00                	mov    (%eax),%eax
  800495:	99                   	cltd   
  800496:	31 d0                	xor    %edx,%eax
  800498:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80049a:	83 f8 0f             	cmp    $0xf,%eax
  80049d:	7f 0b                	jg     8004aa <vprintfmt+0x142>
  80049f:	8b 14 85 20 24 80 00 	mov    0x802420(,%eax,4),%edx
  8004a6:	85 d2                	test   %edx,%edx
  8004a8:	75 18                	jne    8004c2 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004aa:	50                   	push   %eax
  8004ab:	68 9f 21 80 00       	push   $0x80219f
  8004b0:	53                   	push   %ebx
  8004b1:	56                   	push   %esi
  8004b2:	e8 94 fe ff ff       	call   80034b <printfmt>
  8004b7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004bd:	e9 cc fe ff ff       	jmp    80038e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004c2:	52                   	push   %edx
  8004c3:	68 22 26 80 00       	push   $0x802622
  8004c8:	53                   	push   %ebx
  8004c9:	56                   	push   %esi
  8004ca:	e8 7c fe ff ff       	call   80034b <printfmt>
  8004cf:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004d5:	e9 b4 fe ff ff       	jmp    80038e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004da:	8b 45 14             	mov    0x14(%ebp),%eax
  8004dd:	8d 50 04             	lea    0x4(%eax),%edx
  8004e0:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e3:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004e5:	85 ff                	test   %edi,%edi
  8004e7:	b8 98 21 80 00       	mov    $0x802198,%eax
  8004ec:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004ef:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004f3:	0f 8e 94 00 00 00    	jle    80058d <vprintfmt+0x225>
  8004f9:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004fd:	0f 84 98 00 00 00    	je     80059b <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800503:	83 ec 08             	sub    $0x8,%esp
  800506:	ff 75 d0             	pushl  -0x30(%ebp)
  800509:	57                   	push   %edi
  80050a:	e8 86 02 00 00       	call   800795 <strnlen>
  80050f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800512:	29 c1                	sub    %eax,%ecx
  800514:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800517:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80051a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80051e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800521:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800524:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800526:	eb 0f                	jmp    800537 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800528:	83 ec 08             	sub    $0x8,%esp
  80052b:	53                   	push   %ebx
  80052c:	ff 75 e0             	pushl  -0x20(%ebp)
  80052f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800531:	83 ef 01             	sub    $0x1,%edi
  800534:	83 c4 10             	add    $0x10,%esp
  800537:	85 ff                	test   %edi,%edi
  800539:	7f ed                	jg     800528 <vprintfmt+0x1c0>
  80053b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80053e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800541:	85 c9                	test   %ecx,%ecx
  800543:	b8 00 00 00 00       	mov    $0x0,%eax
  800548:	0f 49 c1             	cmovns %ecx,%eax
  80054b:	29 c1                	sub    %eax,%ecx
  80054d:	89 75 08             	mov    %esi,0x8(%ebp)
  800550:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800553:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800556:	89 cb                	mov    %ecx,%ebx
  800558:	eb 4d                	jmp    8005a7 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80055a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80055e:	74 1b                	je     80057b <vprintfmt+0x213>
  800560:	0f be c0             	movsbl %al,%eax
  800563:	83 e8 20             	sub    $0x20,%eax
  800566:	83 f8 5e             	cmp    $0x5e,%eax
  800569:	76 10                	jbe    80057b <vprintfmt+0x213>
					putch('?', putdat);
  80056b:	83 ec 08             	sub    $0x8,%esp
  80056e:	ff 75 0c             	pushl  0xc(%ebp)
  800571:	6a 3f                	push   $0x3f
  800573:	ff 55 08             	call   *0x8(%ebp)
  800576:	83 c4 10             	add    $0x10,%esp
  800579:	eb 0d                	jmp    800588 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80057b:	83 ec 08             	sub    $0x8,%esp
  80057e:	ff 75 0c             	pushl  0xc(%ebp)
  800581:	52                   	push   %edx
  800582:	ff 55 08             	call   *0x8(%ebp)
  800585:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800588:	83 eb 01             	sub    $0x1,%ebx
  80058b:	eb 1a                	jmp    8005a7 <vprintfmt+0x23f>
  80058d:	89 75 08             	mov    %esi,0x8(%ebp)
  800590:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800593:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800596:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800599:	eb 0c                	jmp    8005a7 <vprintfmt+0x23f>
  80059b:	89 75 08             	mov    %esi,0x8(%ebp)
  80059e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005a1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005a4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005a7:	83 c7 01             	add    $0x1,%edi
  8005aa:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005ae:	0f be d0             	movsbl %al,%edx
  8005b1:	85 d2                	test   %edx,%edx
  8005b3:	74 23                	je     8005d8 <vprintfmt+0x270>
  8005b5:	85 f6                	test   %esi,%esi
  8005b7:	78 a1                	js     80055a <vprintfmt+0x1f2>
  8005b9:	83 ee 01             	sub    $0x1,%esi
  8005bc:	79 9c                	jns    80055a <vprintfmt+0x1f2>
  8005be:	89 df                	mov    %ebx,%edi
  8005c0:	8b 75 08             	mov    0x8(%ebp),%esi
  8005c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005c6:	eb 18                	jmp    8005e0 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005c8:	83 ec 08             	sub    $0x8,%esp
  8005cb:	53                   	push   %ebx
  8005cc:	6a 20                	push   $0x20
  8005ce:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005d0:	83 ef 01             	sub    $0x1,%edi
  8005d3:	83 c4 10             	add    $0x10,%esp
  8005d6:	eb 08                	jmp    8005e0 <vprintfmt+0x278>
  8005d8:	89 df                	mov    %ebx,%edi
  8005da:	8b 75 08             	mov    0x8(%ebp),%esi
  8005dd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005e0:	85 ff                	test   %edi,%edi
  8005e2:	7f e4                	jg     8005c8 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005e7:	e9 a2 fd ff ff       	jmp    80038e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005ec:	83 fa 01             	cmp    $0x1,%edx
  8005ef:	7e 16                	jle    800607 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f4:	8d 50 08             	lea    0x8(%eax),%edx
  8005f7:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fa:	8b 50 04             	mov    0x4(%eax),%edx
  8005fd:	8b 00                	mov    (%eax),%eax
  8005ff:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800602:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800605:	eb 32                	jmp    800639 <vprintfmt+0x2d1>
	else if (lflag)
  800607:	85 d2                	test   %edx,%edx
  800609:	74 18                	je     800623 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80060b:	8b 45 14             	mov    0x14(%ebp),%eax
  80060e:	8d 50 04             	lea    0x4(%eax),%edx
  800611:	89 55 14             	mov    %edx,0x14(%ebp)
  800614:	8b 00                	mov    (%eax),%eax
  800616:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800619:	89 c1                	mov    %eax,%ecx
  80061b:	c1 f9 1f             	sar    $0x1f,%ecx
  80061e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800621:	eb 16                	jmp    800639 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800623:	8b 45 14             	mov    0x14(%ebp),%eax
  800626:	8d 50 04             	lea    0x4(%eax),%edx
  800629:	89 55 14             	mov    %edx,0x14(%ebp)
  80062c:	8b 00                	mov    (%eax),%eax
  80062e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800631:	89 c1                	mov    %eax,%ecx
  800633:	c1 f9 1f             	sar    $0x1f,%ecx
  800636:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800639:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80063c:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80063f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800644:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800648:	79 74                	jns    8006be <vprintfmt+0x356>
				putch('-', putdat);
  80064a:	83 ec 08             	sub    $0x8,%esp
  80064d:	53                   	push   %ebx
  80064e:	6a 2d                	push   $0x2d
  800650:	ff d6                	call   *%esi
				num = -(long long) num;
  800652:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800655:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800658:	f7 d8                	neg    %eax
  80065a:	83 d2 00             	adc    $0x0,%edx
  80065d:	f7 da                	neg    %edx
  80065f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800662:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800667:	eb 55                	jmp    8006be <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800669:	8d 45 14             	lea    0x14(%ebp),%eax
  80066c:	e8 83 fc ff ff       	call   8002f4 <getuint>
			base = 10;
  800671:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800676:	eb 46                	jmp    8006be <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800678:	8d 45 14             	lea    0x14(%ebp),%eax
  80067b:	e8 74 fc ff ff       	call   8002f4 <getuint>
                        base = 8;
  800680:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800685:	eb 37                	jmp    8006be <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800687:	83 ec 08             	sub    $0x8,%esp
  80068a:	53                   	push   %ebx
  80068b:	6a 30                	push   $0x30
  80068d:	ff d6                	call   *%esi
			putch('x', putdat);
  80068f:	83 c4 08             	add    $0x8,%esp
  800692:	53                   	push   %ebx
  800693:	6a 78                	push   $0x78
  800695:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800697:	8b 45 14             	mov    0x14(%ebp),%eax
  80069a:	8d 50 04             	lea    0x4(%eax),%edx
  80069d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006a0:	8b 00                	mov    (%eax),%eax
  8006a2:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006a7:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006aa:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006af:	eb 0d                	jmp    8006be <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006b1:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b4:	e8 3b fc ff ff       	call   8002f4 <getuint>
			base = 16;
  8006b9:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006be:	83 ec 0c             	sub    $0xc,%esp
  8006c1:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006c5:	57                   	push   %edi
  8006c6:	ff 75 e0             	pushl  -0x20(%ebp)
  8006c9:	51                   	push   %ecx
  8006ca:	52                   	push   %edx
  8006cb:	50                   	push   %eax
  8006cc:	89 da                	mov    %ebx,%edx
  8006ce:	89 f0                	mov    %esi,%eax
  8006d0:	e8 70 fb ff ff       	call   800245 <printnum>
			break;
  8006d5:	83 c4 20             	add    $0x20,%esp
  8006d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006db:	e9 ae fc ff ff       	jmp    80038e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006e0:	83 ec 08             	sub    $0x8,%esp
  8006e3:	53                   	push   %ebx
  8006e4:	51                   	push   %ecx
  8006e5:	ff d6                	call   *%esi
			break;
  8006e7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006ed:	e9 9c fc ff ff       	jmp    80038e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006f2:	83 ec 08             	sub    $0x8,%esp
  8006f5:	53                   	push   %ebx
  8006f6:	6a 25                	push   $0x25
  8006f8:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006fa:	83 c4 10             	add    $0x10,%esp
  8006fd:	eb 03                	jmp    800702 <vprintfmt+0x39a>
  8006ff:	83 ef 01             	sub    $0x1,%edi
  800702:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800706:	75 f7                	jne    8006ff <vprintfmt+0x397>
  800708:	e9 81 fc ff ff       	jmp    80038e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80070d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800710:	5b                   	pop    %ebx
  800711:	5e                   	pop    %esi
  800712:	5f                   	pop    %edi
  800713:	5d                   	pop    %ebp
  800714:	c3                   	ret    

00800715 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800715:	55                   	push   %ebp
  800716:	89 e5                	mov    %esp,%ebp
  800718:	83 ec 18             	sub    $0x18,%esp
  80071b:	8b 45 08             	mov    0x8(%ebp),%eax
  80071e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800721:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800724:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800728:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80072b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800732:	85 c0                	test   %eax,%eax
  800734:	74 26                	je     80075c <vsnprintf+0x47>
  800736:	85 d2                	test   %edx,%edx
  800738:	7e 22                	jle    80075c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80073a:	ff 75 14             	pushl  0x14(%ebp)
  80073d:	ff 75 10             	pushl  0x10(%ebp)
  800740:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800743:	50                   	push   %eax
  800744:	68 2e 03 80 00       	push   $0x80032e
  800749:	e8 1a fc ff ff       	call   800368 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80074e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800751:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800754:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800757:	83 c4 10             	add    $0x10,%esp
  80075a:	eb 05                	jmp    800761 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80075c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800761:	c9                   	leave  
  800762:	c3                   	ret    

00800763 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800763:	55                   	push   %ebp
  800764:	89 e5                	mov    %esp,%ebp
  800766:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800769:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80076c:	50                   	push   %eax
  80076d:	ff 75 10             	pushl  0x10(%ebp)
  800770:	ff 75 0c             	pushl  0xc(%ebp)
  800773:	ff 75 08             	pushl  0x8(%ebp)
  800776:	e8 9a ff ff ff       	call   800715 <vsnprintf>
	va_end(ap);

	return rc;
}
  80077b:	c9                   	leave  
  80077c:	c3                   	ret    

0080077d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80077d:	55                   	push   %ebp
  80077e:	89 e5                	mov    %esp,%ebp
  800780:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800783:	b8 00 00 00 00       	mov    $0x0,%eax
  800788:	eb 03                	jmp    80078d <strlen+0x10>
		n++;
  80078a:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80078d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800791:	75 f7                	jne    80078a <strlen+0xd>
		n++;
	return n;
}
  800793:	5d                   	pop    %ebp
  800794:	c3                   	ret    

00800795 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800795:	55                   	push   %ebp
  800796:	89 e5                	mov    %esp,%ebp
  800798:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80079b:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80079e:	ba 00 00 00 00       	mov    $0x0,%edx
  8007a3:	eb 03                	jmp    8007a8 <strnlen+0x13>
		n++;
  8007a5:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a8:	39 c2                	cmp    %eax,%edx
  8007aa:	74 08                	je     8007b4 <strnlen+0x1f>
  8007ac:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007b0:	75 f3                	jne    8007a5 <strnlen+0x10>
  8007b2:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007b4:	5d                   	pop    %ebp
  8007b5:	c3                   	ret    

008007b6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007b6:	55                   	push   %ebp
  8007b7:	89 e5                	mov    %esp,%ebp
  8007b9:	53                   	push   %ebx
  8007ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007c0:	89 c2                	mov    %eax,%edx
  8007c2:	83 c2 01             	add    $0x1,%edx
  8007c5:	83 c1 01             	add    $0x1,%ecx
  8007c8:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007cc:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007cf:	84 db                	test   %bl,%bl
  8007d1:	75 ef                	jne    8007c2 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007d3:	5b                   	pop    %ebx
  8007d4:	5d                   	pop    %ebp
  8007d5:	c3                   	ret    

008007d6 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007d6:	55                   	push   %ebp
  8007d7:	89 e5                	mov    %esp,%ebp
  8007d9:	53                   	push   %ebx
  8007da:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007dd:	53                   	push   %ebx
  8007de:	e8 9a ff ff ff       	call   80077d <strlen>
  8007e3:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007e6:	ff 75 0c             	pushl  0xc(%ebp)
  8007e9:	01 d8                	add    %ebx,%eax
  8007eb:	50                   	push   %eax
  8007ec:	e8 c5 ff ff ff       	call   8007b6 <strcpy>
	return dst;
}
  8007f1:	89 d8                	mov    %ebx,%eax
  8007f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007f6:	c9                   	leave  
  8007f7:	c3                   	ret    

008007f8 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007f8:	55                   	push   %ebp
  8007f9:	89 e5                	mov    %esp,%ebp
  8007fb:	56                   	push   %esi
  8007fc:	53                   	push   %ebx
  8007fd:	8b 75 08             	mov    0x8(%ebp),%esi
  800800:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800803:	89 f3                	mov    %esi,%ebx
  800805:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800808:	89 f2                	mov    %esi,%edx
  80080a:	eb 0f                	jmp    80081b <strncpy+0x23>
		*dst++ = *src;
  80080c:	83 c2 01             	add    $0x1,%edx
  80080f:	0f b6 01             	movzbl (%ecx),%eax
  800812:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800815:	80 39 01             	cmpb   $0x1,(%ecx)
  800818:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80081b:	39 da                	cmp    %ebx,%edx
  80081d:	75 ed                	jne    80080c <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80081f:	89 f0                	mov    %esi,%eax
  800821:	5b                   	pop    %ebx
  800822:	5e                   	pop    %esi
  800823:	5d                   	pop    %ebp
  800824:	c3                   	ret    

00800825 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800825:	55                   	push   %ebp
  800826:	89 e5                	mov    %esp,%ebp
  800828:	56                   	push   %esi
  800829:	53                   	push   %ebx
  80082a:	8b 75 08             	mov    0x8(%ebp),%esi
  80082d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800830:	8b 55 10             	mov    0x10(%ebp),%edx
  800833:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800835:	85 d2                	test   %edx,%edx
  800837:	74 21                	je     80085a <strlcpy+0x35>
  800839:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80083d:	89 f2                	mov    %esi,%edx
  80083f:	eb 09                	jmp    80084a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800841:	83 c2 01             	add    $0x1,%edx
  800844:	83 c1 01             	add    $0x1,%ecx
  800847:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80084a:	39 c2                	cmp    %eax,%edx
  80084c:	74 09                	je     800857 <strlcpy+0x32>
  80084e:	0f b6 19             	movzbl (%ecx),%ebx
  800851:	84 db                	test   %bl,%bl
  800853:	75 ec                	jne    800841 <strlcpy+0x1c>
  800855:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800857:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80085a:	29 f0                	sub    %esi,%eax
}
  80085c:	5b                   	pop    %ebx
  80085d:	5e                   	pop    %esi
  80085e:	5d                   	pop    %ebp
  80085f:	c3                   	ret    

00800860 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800866:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800869:	eb 06                	jmp    800871 <strcmp+0x11>
		p++, q++;
  80086b:	83 c1 01             	add    $0x1,%ecx
  80086e:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800871:	0f b6 01             	movzbl (%ecx),%eax
  800874:	84 c0                	test   %al,%al
  800876:	74 04                	je     80087c <strcmp+0x1c>
  800878:	3a 02                	cmp    (%edx),%al
  80087a:	74 ef                	je     80086b <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80087c:	0f b6 c0             	movzbl %al,%eax
  80087f:	0f b6 12             	movzbl (%edx),%edx
  800882:	29 d0                	sub    %edx,%eax
}
  800884:	5d                   	pop    %ebp
  800885:	c3                   	ret    

00800886 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800886:	55                   	push   %ebp
  800887:	89 e5                	mov    %esp,%ebp
  800889:	53                   	push   %ebx
  80088a:	8b 45 08             	mov    0x8(%ebp),%eax
  80088d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800890:	89 c3                	mov    %eax,%ebx
  800892:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800895:	eb 06                	jmp    80089d <strncmp+0x17>
		n--, p++, q++;
  800897:	83 c0 01             	add    $0x1,%eax
  80089a:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80089d:	39 d8                	cmp    %ebx,%eax
  80089f:	74 15                	je     8008b6 <strncmp+0x30>
  8008a1:	0f b6 08             	movzbl (%eax),%ecx
  8008a4:	84 c9                	test   %cl,%cl
  8008a6:	74 04                	je     8008ac <strncmp+0x26>
  8008a8:	3a 0a                	cmp    (%edx),%cl
  8008aa:	74 eb                	je     800897 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ac:	0f b6 00             	movzbl (%eax),%eax
  8008af:	0f b6 12             	movzbl (%edx),%edx
  8008b2:	29 d0                	sub    %edx,%eax
  8008b4:	eb 05                	jmp    8008bb <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008b6:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008bb:	5b                   	pop    %ebx
  8008bc:	5d                   	pop    %ebp
  8008bd:	c3                   	ret    

008008be <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008be:	55                   	push   %ebp
  8008bf:	89 e5                	mov    %esp,%ebp
  8008c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008c8:	eb 07                	jmp    8008d1 <strchr+0x13>
		if (*s == c)
  8008ca:	38 ca                	cmp    %cl,%dl
  8008cc:	74 0f                	je     8008dd <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008ce:	83 c0 01             	add    $0x1,%eax
  8008d1:	0f b6 10             	movzbl (%eax),%edx
  8008d4:	84 d2                	test   %dl,%dl
  8008d6:	75 f2                	jne    8008ca <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008d8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008dd:	5d                   	pop    %ebp
  8008de:	c3                   	ret    

008008df <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008df:	55                   	push   %ebp
  8008e0:	89 e5                	mov    %esp,%ebp
  8008e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008e9:	eb 03                	jmp    8008ee <strfind+0xf>
  8008eb:	83 c0 01             	add    $0x1,%eax
  8008ee:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008f1:	38 ca                	cmp    %cl,%dl
  8008f3:	74 04                	je     8008f9 <strfind+0x1a>
  8008f5:	84 d2                	test   %dl,%dl
  8008f7:	75 f2                	jne    8008eb <strfind+0xc>
			break;
	return (char *) s;
}
  8008f9:	5d                   	pop    %ebp
  8008fa:	c3                   	ret    

008008fb <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008fb:	55                   	push   %ebp
  8008fc:	89 e5                	mov    %esp,%ebp
  8008fe:	57                   	push   %edi
  8008ff:	56                   	push   %esi
  800900:	53                   	push   %ebx
  800901:	8b 7d 08             	mov    0x8(%ebp),%edi
  800904:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800907:	85 c9                	test   %ecx,%ecx
  800909:	74 36                	je     800941 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80090b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800911:	75 28                	jne    80093b <memset+0x40>
  800913:	f6 c1 03             	test   $0x3,%cl
  800916:	75 23                	jne    80093b <memset+0x40>
		c &= 0xFF;
  800918:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80091c:	89 d3                	mov    %edx,%ebx
  80091e:	c1 e3 08             	shl    $0x8,%ebx
  800921:	89 d6                	mov    %edx,%esi
  800923:	c1 e6 18             	shl    $0x18,%esi
  800926:	89 d0                	mov    %edx,%eax
  800928:	c1 e0 10             	shl    $0x10,%eax
  80092b:	09 f0                	or     %esi,%eax
  80092d:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80092f:	89 d8                	mov    %ebx,%eax
  800931:	09 d0                	or     %edx,%eax
  800933:	c1 e9 02             	shr    $0x2,%ecx
  800936:	fc                   	cld    
  800937:	f3 ab                	rep stos %eax,%es:(%edi)
  800939:	eb 06                	jmp    800941 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80093b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80093e:	fc                   	cld    
  80093f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800941:	89 f8                	mov    %edi,%eax
  800943:	5b                   	pop    %ebx
  800944:	5e                   	pop    %esi
  800945:	5f                   	pop    %edi
  800946:	5d                   	pop    %ebp
  800947:	c3                   	ret    

00800948 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800948:	55                   	push   %ebp
  800949:	89 e5                	mov    %esp,%ebp
  80094b:	57                   	push   %edi
  80094c:	56                   	push   %esi
  80094d:	8b 45 08             	mov    0x8(%ebp),%eax
  800950:	8b 75 0c             	mov    0xc(%ebp),%esi
  800953:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800956:	39 c6                	cmp    %eax,%esi
  800958:	73 35                	jae    80098f <memmove+0x47>
  80095a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80095d:	39 d0                	cmp    %edx,%eax
  80095f:	73 2e                	jae    80098f <memmove+0x47>
		s += n;
		d += n;
  800961:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800964:	89 d6                	mov    %edx,%esi
  800966:	09 fe                	or     %edi,%esi
  800968:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80096e:	75 13                	jne    800983 <memmove+0x3b>
  800970:	f6 c1 03             	test   $0x3,%cl
  800973:	75 0e                	jne    800983 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800975:	83 ef 04             	sub    $0x4,%edi
  800978:	8d 72 fc             	lea    -0x4(%edx),%esi
  80097b:	c1 e9 02             	shr    $0x2,%ecx
  80097e:	fd                   	std    
  80097f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800981:	eb 09                	jmp    80098c <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800983:	83 ef 01             	sub    $0x1,%edi
  800986:	8d 72 ff             	lea    -0x1(%edx),%esi
  800989:	fd                   	std    
  80098a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80098c:	fc                   	cld    
  80098d:	eb 1d                	jmp    8009ac <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80098f:	89 f2                	mov    %esi,%edx
  800991:	09 c2                	or     %eax,%edx
  800993:	f6 c2 03             	test   $0x3,%dl
  800996:	75 0f                	jne    8009a7 <memmove+0x5f>
  800998:	f6 c1 03             	test   $0x3,%cl
  80099b:	75 0a                	jne    8009a7 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80099d:	c1 e9 02             	shr    $0x2,%ecx
  8009a0:	89 c7                	mov    %eax,%edi
  8009a2:	fc                   	cld    
  8009a3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a5:	eb 05                	jmp    8009ac <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009a7:	89 c7                	mov    %eax,%edi
  8009a9:	fc                   	cld    
  8009aa:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009ac:	5e                   	pop    %esi
  8009ad:	5f                   	pop    %edi
  8009ae:	5d                   	pop    %ebp
  8009af:	c3                   	ret    

008009b0 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009b0:	55                   	push   %ebp
  8009b1:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009b3:	ff 75 10             	pushl  0x10(%ebp)
  8009b6:	ff 75 0c             	pushl  0xc(%ebp)
  8009b9:	ff 75 08             	pushl  0x8(%ebp)
  8009bc:	e8 87 ff ff ff       	call   800948 <memmove>
}
  8009c1:	c9                   	leave  
  8009c2:	c3                   	ret    

008009c3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009c3:	55                   	push   %ebp
  8009c4:	89 e5                	mov    %esp,%ebp
  8009c6:	56                   	push   %esi
  8009c7:	53                   	push   %ebx
  8009c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ce:	89 c6                	mov    %eax,%esi
  8009d0:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d3:	eb 1a                	jmp    8009ef <memcmp+0x2c>
		if (*s1 != *s2)
  8009d5:	0f b6 08             	movzbl (%eax),%ecx
  8009d8:	0f b6 1a             	movzbl (%edx),%ebx
  8009db:	38 d9                	cmp    %bl,%cl
  8009dd:	74 0a                	je     8009e9 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009df:	0f b6 c1             	movzbl %cl,%eax
  8009e2:	0f b6 db             	movzbl %bl,%ebx
  8009e5:	29 d8                	sub    %ebx,%eax
  8009e7:	eb 0f                	jmp    8009f8 <memcmp+0x35>
		s1++, s2++;
  8009e9:	83 c0 01             	add    $0x1,%eax
  8009ec:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ef:	39 f0                	cmp    %esi,%eax
  8009f1:	75 e2                	jne    8009d5 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f8:	5b                   	pop    %ebx
  8009f9:	5e                   	pop    %esi
  8009fa:	5d                   	pop    %ebp
  8009fb:	c3                   	ret    

008009fc <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009fc:	55                   	push   %ebp
  8009fd:	89 e5                	mov    %esp,%ebp
  8009ff:	53                   	push   %ebx
  800a00:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a03:	89 c1                	mov    %eax,%ecx
  800a05:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a08:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a0c:	eb 0a                	jmp    800a18 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a0e:	0f b6 10             	movzbl (%eax),%edx
  800a11:	39 da                	cmp    %ebx,%edx
  800a13:	74 07                	je     800a1c <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a15:	83 c0 01             	add    $0x1,%eax
  800a18:	39 c8                	cmp    %ecx,%eax
  800a1a:	72 f2                	jb     800a0e <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a1c:	5b                   	pop    %ebx
  800a1d:	5d                   	pop    %ebp
  800a1e:	c3                   	ret    

00800a1f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a1f:	55                   	push   %ebp
  800a20:	89 e5                	mov    %esp,%ebp
  800a22:	57                   	push   %edi
  800a23:	56                   	push   %esi
  800a24:	53                   	push   %ebx
  800a25:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a28:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a2b:	eb 03                	jmp    800a30 <strtol+0x11>
		s++;
  800a2d:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a30:	0f b6 01             	movzbl (%ecx),%eax
  800a33:	3c 20                	cmp    $0x20,%al
  800a35:	74 f6                	je     800a2d <strtol+0xe>
  800a37:	3c 09                	cmp    $0x9,%al
  800a39:	74 f2                	je     800a2d <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a3b:	3c 2b                	cmp    $0x2b,%al
  800a3d:	75 0a                	jne    800a49 <strtol+0x2a>
		s++;
  800a3f:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a42:	bf 00 00 00 00       	mov    $0x0,%edi
  800a47:	eb 11                	jmp    800a5a <strtol+0x3b>
  800a49:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a4e:	3c 2d                	cmp    $0x2d,%al
  800a50:	75 08                	jne    800a5a <strtol+0x3b>
		s++, neg = 1;
  800a52:	83 c1 01             	add    $0x1,%ecx
  800a55:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a5a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a60:	75 15                	jne    800a77 <strtol+0x58>
  800a62:	80 39 30             	cmpb   $0x30,(%ecx)
  800a65:	75 10                	jne    800a77 <strtol+0x58>
  800a67:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a6b:	75 7c                	jne    800ae9 <strtol+0xca>
		s += 2, base = 16;
  800a6d:	83 c1 02             	add    $0x2,%ecx
  800a70:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a75:	eb 16                	jmp    800a8d <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a77:	85 db                	test   %ebx,%ebx
  800a79:	75 12                	jne    800a8d <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a7b:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a80:	80 39 30             	cmpb   $0x30,(%ecx)
  800a83:	75 08                	jne    800a8d <strtol+0x6e>
		s++, base = 8;
  800a85:	83 c1 01             	add    $0x1,%ecx
  800a88:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a8d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a92:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a95:	0f b6 11             	movzbl (%ecx),%edx
  800a98:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a9b:	89 f3                	mov    %esi,%ebx
  800a9d:	80 fb 09             	cmp    $0x9,%bl
  800aa0:	77 08                	ja     800aaa <strtol+0x8b>
			dig = *s - '0';
  800aa2:	0f be d2             	movsbl %dl,%edx
  800aa5:	83 ea 30             	sub    $0x30,%edx
  800aa8:	eb 22                	jmp    800acc <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800aaa:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aad:	89 f3                	mov    %esi,%ebx
  800aaf:	80 fb 19             	cmp    $0x19,%bl
  800ab2:	77 08                	ja     800abc <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ab4:	0f be d2             	movsbl %dl,%edx
  800ab7:	83 ea 57             	sub    $0x57,%edx
  800aba:	eb 10                	jmp    800acc <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800abc:	8d 72 bf             	lea    -0x41(%edx),%esi
  800abf:	89 f3                	mov    %esi,%ebx
  800ac1:	80 fb 19             	cmp    $0x19,%bl
  800ac4:	77 16                	ja     800adc <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ac6:	0f be d2             	movsbl %dl,%edx
  800ac9:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800acc:	3b 55 10             	cmp    0x10(%ebp),%edx
  800acf:	7d 0b                	jge    800adc <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ad1:	83 c1 01             	add    $0x1,%ecx
  800ad4:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ad8:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ada:	eb b9                	jmp    800a95 <strtol+0x76>

	if (endptr)
  800adc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ae0:	74 0d                	je     800aef <strtol+0xd0>
		*endptr = (char *) s;
  800ae2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ae5:	89 0e                	mov    %ecx,(%esi)
  800ae7:	eb 06                	jmp    800aef <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ae9:	85 db                	test   %ebx,%ebx
  800aeb:	74 98                	je     800a85 <strtol+0x66>
  800aed:	eb 9e                	jmp    800a8d <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800aef:	89 c2                	mov    %eax,%edx
  800af1:	f7 da                	neg    %edx
  800af3:	85 ff                	test   %edi,%edi
  800af5:	0f 45 c2             	cmovne %edx,%eax
}
  800af8:	5b                   	pop    %ebx
  800af9:	5e                   	pop    %esi
  800afa:	5f                   	pop    %edi
  800afb:	5d                   	pop    %ebp
  800afc:	c3                   	ret    

00800afd <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800afd:	55                   	push   %ebp
  800afe:	89 e5                	mov    %esp,%ebp
  800b00:	57                   	push   %edi
  800b01:	56                   	push   %esi
  800b02:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b03:	b8 00 00 00 00       	mov    $0x0,%eax
  800b08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b0b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b0e:	89 c3                	mov    %eax,%ebx
  800b10:	89 c7                	mov    %eax,%edi
  800b12:	89 c6                	mov    %eax,%esi
  800b14:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b16:	5b                   	pop    %ebx
  800b17:	5e                   	pop    %esi
  800b18:	5f                   	pop    %edi
  800b19:	5d                   	pop    %ebp
  800b1a:	c3                   	ret    

00800b1b <sys_cgetc>:

int
sys_cgetc(void)
{
  800b1b:	55                   	push   %ebp
  800b1c:	89 e5                	mov    %esp,%ebp
  800b1e:	57                   	push   %edi
  800b1f:	56                   	push   %esi
  800b20:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b21:	ba 00 00 00 00       	mov    $0x0,%edx
  800b26:	b8 01 00 00 00       	mov    $0x1,%eax
  800b2b:	89 d1                	mov    %edx,%ecx
  800b2d:	89 d3                	mov    %edx,%ebx
  800b2f:	89 d7                	mov    %edx,%edi
  800b31:	89 d6                	mov    %edx,%esi
  800b33:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b35:	5b                   	pop    %ebx
  800b36:	5e                   	pop    %esi
  800b37:	5f                   	pop    %edi
  800b38:	5d                   	pop    %ebp
  800b39:	c3                   	ret    

00800b3a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b3a:	55                   	push   %ebp
  800b3b:	89 e5                	mov    %esp,%ebp
  800b3d:	57                   	push   %edi
  800b3e:	56                   	push   %esi
  800b3f:	53                   	push   %ebx
  800b40:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b43:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b48:	b8 03 00 00 00       	mov    $0x3,%eax
  800b4d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b50:	89 cb                	mov    %ecx,%ebx
  800b52:	89 cf                	mov    %ecx,%edi
  800b54:	89 ce                	mov    %ecx,%esi
  800b56:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b58:	85 c0                	test   %eax,%eax
  800b5a:	7e 17                	jle    800b73 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b5c:	83 ec 0c             	sub    $0xc,%esp
  800b5f:	50                   	push   %eax
  800b60:	6a 03                	push   $0x3
  800b62:	68 7f 24 80 00       	push   $0x80247f
  800b67:	6a 23                	push   $0x23
  800b69:	68 9c 24 80 00       	push   $0x80249c
  800b6e:	e8 e5 f5 ff ff       	call   800158 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b73:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b76:	5b                   	pop    %ebx
  800b77:	5e                   	pop    %esi
  800b78:	5f                   	pop    %edi
  800b79:	5d                   	pop    %ebp
  800b7a:	c3                   	ret    

00800b7b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b7b:	55                   	push   %ebp
  800b7c:	89 e5                	mov    %esp,%ebp
  800b7e:	57                   	push   %edi
  800b7f:	56                   	push   %esi
  800b80:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b81:	ba 00 00 00 00       	mov    $0x0,%edx
  800b86:	b8 02 00 00 00       	mov    $0x2,%eax
  800b8b:	89 d1                	mov    %edx,%ecx
  800b8d:	89 d3                	mov    %edx,%ebx
  800b8f:	89 d7                	mov    %edx,%edi
  800b91:	89 d6                	mov    %edx,%esi
  800b93:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b95:	5b                   	pop    %ebx
  800b96:	5e                   	pop    %esi
  800b97:	5f                   	pop    %edi
  800b98:	5d                   	pop    %ebp
  800b99:	c3                   	ret    

00800b9a <sys_yield>:

void
sys_yield(void)
{
  800b9a:	55                   	push   %ebp
  800b9b:	89 e5                	mov    %esp,%ebp
  800b9d:	57                   	push   %edi
  800b9e:	56                   	push   %esi
  800b9f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba5:	b8 0b 00 00 00       	mov    $0xb,%eax
  800baa:	89 d1                	mov    %edx,%ecx
  800bac:	89 d3                	mov    %edx,%ebx
  800bae:	89 d7                	mov    %edx,%edi
  800bb0:	89 d6                	mov    %edx,%esi
  800bb2:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bb4:	5b                   	pop    %ebx
  800bb5:	5e                   	pop    %esi
  800bb6:	5f                   	pop    %edi
  800bb7:	5d                   	pop    %ebp
  800bb8:	c3                   	ret    

00800bb9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bb9:	55                   	push   %ebp
  800bba:	89 e5                	mov    %esp,%ebp
  800bbc:	57                   	push   %edi
  800bbd:	56                   	push   %esi
  800bbe:	53                   	push   %ebx
  800bbf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc2:	be 00 00 00 00       	mov    $0x0,%esi
  800bc7:	b8 04 00 00 00       	mov    $0x4,%eax
  800bcc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bcf:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd5:	89 f7                	mov    %esi,%edi
  800bd7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bd9:	85 c0                	test   %eax,%eax
  800bdb:	7e 17                	jle    800bf4 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bdd:	83 ec 0c             	sub    $0xc,%esp
  800be0:	50                   	push   %eax
  800be1:	6a 04                	push   $0x4
  800be3:	68 7f 24 80 00       	push   $0x80247f
  800be8:	6a 23                	push   $0x23
  800bea:	68 9c 24 80 00       	push   $0x80249c
  800bef:	e8 64 f5 ff ff       	call   800158 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bf4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf7:	5b                   	pop    %ebx
  800bf8:	5e                   	pop    %esi
  800bf9:	5f                   	pop    %edi
  800bfa:	5d                   	pop    %ebp
  800bfb:	c3                   	ret    

00800bfc <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bfc:	55                   	push   %ebp
  800bfd:	89 e5                	mov    %esp,%ebp
  800bff:	57                   	push   %edi
  800c00:	56                   	push   %esi
  800c01:	53                   	push   %ebx
  800c02:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c05:	b8 05 00 00 00       	mov    $0x5,%eax
  800c0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c10:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c13:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c16:	8b 75 18             	mov    0x18(%ebp),%esi
  800c19:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c1b:	85 c0                	test   %eax,%eax
  800c1d:	7e 17                	jle    800c36 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1f:	83 ec 0c             	sub    $0xc,%esp
  800c22:	50                   	push   %eax
  800c23:	6a 05                	push   $0x5
  800c25:	68 7f 24 80 00       	push   $0x80247f
  800c2a:	6a 23                	push   $0x23
  800c2c:	68 9c 24 80 00       	push   $0x80249c
  800c31:	e8 22 f5 ff ff       	call   800158 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c39:	5b                   	pop    %ebx
  800c3a:	5e                   	pop    %esi
  800c3b:	5f                   	pop    %edi
  800c3c:	5d                   	pop    %ebp
  800c3d:	c3                   	ret    

00800c3e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c3e:	55                   	push   %ebp
  800c3f:	89 e5                	mov    %esp,%ebp
  800c41:	57                   	push   %edi
  800c42:	56                   	push   %esi
  800c43:	53                   	push   %ebx
  800c44:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c47:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c4c:	b8 06 00 00 00       	mov    $0x6,%eax
  800c51:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c54:	8b 55 08             	mov    0x8(%ebp),%edx
  800c57:	89 df                	mov    %ebx,%edi
  800c59:	89 de                	mov    %ebx,%esi
  800c5b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c5d:	85 c0                	test   %eax,%eax
  800c5f:	7e 17                	jle    800c78 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c61:	83 ec 0c             	sub    $0xc,%esp
  800c64:	50                   	push   %eax
  800c65:	6a 06                	push   $0x6
  800c67:	68 7f 24 80 00       	push   $0x80247f
  800c6c:	6a 23                	push   $0x23
  800c6e:	68 9c 24 80 00       	push   $0x80249c
  800c73:	e8 e0 f4 ff ff       	call   800158 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c78:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7b:	5b                   	pop    %ebx
  800c7c:	5e                   	pop    %esi
  800c7d:	5f                   	pop    %edi
  800c7e:	5d                   	pop    %ebp
  800c7f:	c3                   	ret    

00800c80 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c80:	55                   	push   %ebp
  800c81:	89 e5                	mov    %esp,%ebp
  800c83:	57                   	push   %edi
  800c84:	56                   	push   %esi
  800c85:	53                   	push   %ebx
  800c86:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c89:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c8e:	b8 08 00 00 00       	mov    $0x8,%eax
  800c93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c96:	8b 55 08             	mov    0x8(%ebp),%edx
  800c99:	89 df                	mov    %ebx,%edi
  800c9b:	89 de                	mov    %ebx,%esi
  800c9d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c9f:	85 c0                	test   %eax,%eax
  800ca1:	7e 17                	jle    800cba <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca3:	83 ec 0c             	sub    $0xc,%esp
  800ca6:	50                   	push   %eax
  800ca7:	6a 08                	push   $0x8
  800ca9:	68 7f 24 80 00       	push   $0x80247f
  800cae:	6a 23                	push   $0x23
  800cb0:	68 9c 24 80 00       	push   $0x80249c
  800cb5:	e8 9e f4 ff ff       	call   800158 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbd:	5b                   	pop    %ebx
  800cbe:	5e                   	pop    %esi
  800cbf:	5f                   	pop    %edi
  800cc0:	5d                   	pop    %ebp
  800cc1:	c3                   	ret    

00800cc2 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cc2:	55                   	push   %ebp
  800cc3:	89 e5                	mov    %esp,%ebp
  800cc5:	57                   	push   %edi
  800cc6:	56                   	push   %esi
  800cc7:	53                   	push   %ebx
  800cc8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd0:	b8 09 00 00 00       	mov    $0x9,%eax
  800cd5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdb:	89 df                	mov    %ebx,%edi
  800cdd:	89 de                	mov    %ebx,%esi
  800cdf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ce1:	85 c0                	test   %eax,%eax
  800ce3:	7e 17                	jle    800cfc <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce5:	83 ec 0c             	sub    $0xc,%esp
  800ce8:	50                   	push   %eax
  800ce9:	6a 09                	push   $0x9
  800ceb:	68 7f 24 80 00       	push   $0x80247f
  800cf0:	6a 23                	push   $0x23
  800cf2:	68 9c 24 80 00       	push   $0x80249c
  800cf7:	e8 5c f4 ff ff       	call   800158 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cfc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cff:	5b                   	pop    %ebx
  800d00:	5e                   	pop    %esi
  800d01:	5f                   	pop    %edi
  800d02:	5d                   	pop    %ebp
  800d03:	c3                   	ret    

00800d04 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d04:	55                   	push   %ebp
  800d05:	89 e5                	mov    %esp,%ebp
  800d07:	57                   	push   %edi
  800d08:	56                   	push   %esi
  800d09:	53                   	push   %ebx
  800d0a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d12:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1d:	89 df                	mov    %ebx,%edi
  800d1f:	89 de                	mov    %ebx,%esi
  800d21:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d23:	85 c0                	test   %eax,%eax
  800d25:	7e 17                	jle    800d3e <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d27:	83 ec 0c             	sub    $0xc,%esp
  800d2a:	50                   	push   %eax
  800d2b:	6a 0a                	push   $0xa
  800d2d:	68 7f 24 80 00       	push   $0x80247f
  800d32:	6a 23                	push   $0x23
  800d34:	68 9c 24 80 00       	push   $0x80249c
  800d39:	e8 1a f4 ff ff       	call   800158 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d41:	5b                   	pop    %ebx
  800d42:	5e                   	pop    %esi
  800d43:	5f                   	pop    %edi
  800d44:	5d                   	pop    %ebp
  800d45:	c3                   	ret    

00800d46 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d46:	55                   	push   %ebp
  800d47:	89 e5                	mov    %esp,%ebp
  800d49:	57                   	push   %edi
  800d4a:	56                   	push   %esi
  800d4b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4c:	be 00 00 00 00       	mov    $0x0,%esi
  800d51:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d59:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d5f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d62:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d64:	5b                   	pop    %ebx
  800d65:	5e                   	pop    %esi
  800d66:	5f                   	pop    %edi
  800d67:	5d                   	pop    %ebp
  800d68:	c3                   	ret    

00800d69 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d69:	55                   	push   %ebp
  800d6a:	89 e5                	mov    %esp,%ebp
  800d6c:	57                   	push   %edi
  800d6d:	56                   	push   %esi
  800d6e:	53                   	push   %ebx
  800d6f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d72:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d77:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7f:	89 cb                	mov    %ecx,%ebx
  800d81:	89 cf                	mov    %ecx,%edi
  800d83:	89 ce                	mov    %ecx,%esi
  800d85:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d87:	85 c0                	test   %eax,%eax
  800d89:	7e 17                	jle    800da2 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8b:	83 ec 0c             	sub    $0xc,%esp
  800d8e:	50                   	push   %eax
  800d8f:	6a 0d                	push   $0xd
  800d91:	68 7f 24 80 00       	push   $0x80247f
  800d96:	6a 23                	push   $0x23
  800d98:	68 9c 24 80 00       	push   $0x80249c
  800d9d:	e8 b6 f3 ff ff       	call   800158 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800da2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da5:	5b                   	pop    %ebx
  800da6:	5e                   	pop    %esi
  800da7:	5f                   	pop    %edi
  800da8:	5d                   	pop    %ebp
  800da9:	c3                   	ret    

00800daa <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800daa:	55                   	push   %ebp
  800dab:	89 e5                	mov    %esp,%ebp
  800dad:	56                   	push   %esi
  800dae:	53                   	push   %ebx
	int r;

	// LAB 4: Your code here.
	// Check if page is writable or COW
	pte_t pte = uvpt[pn];
  800daf:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
	uint32_t perm = PTE_P | PTE_U;
	if (pte && (PTE_COW | PTE_W)) {
		perm |= PTE_COW;
  800db6:	83 f9 01             	cmp    $0x1,%ecx
  800db9:	19 f6                	sbb    %esi,%esi
  800dbb:	81 e6 00 f8 ff ff    	and    $0xfffff800,%esi
  800dc1:	81 c6 05 08 00 00    	add    $0x805,%esi
	}

	// Map page
	void *va = (void *) (pn * PGSIZE);
  800dc7:	c1 e2 0c             	shl    $0xc,%edx
  800dca:	89 d3                	mov    %edx,%ebx
	// Map on the child
	if ((r = sys_page_map(0, va, envid, va, perm)) < 0) {
  800dcc:	83 ec 0c             	sub    $0xc,%esp
  800dcf:	56                   	push   %esi
  800dd0:	52                   	push   %edx
  800dd1:	50                   	push   %eax
  800dd2:	52                   	push   %edx
  800dd3:	6a 00                	push   $0x0
  800dd5:	e8 22 fe ff ff       	call   800bfc <sys_page_map>
  800dda:	83 c4 20             	add    $0x20,%esp
  800ddd:	85 c0                	test   %eax,%eax
  800ddf:	79 12                	jns    800df3 <duppage+0x49>
		panic("sys_page_alloc: %e", r);
  800de1:	50                   	push   %eax
  800de2:	68 aa 24 80 00       	push   $0x8024aa
  800de7:	6a 56                	push   $0x56
  800de9:	68 bd 24 80 00       	push   $0x8024bd
  800dee:	e8 65 f3 ff ff       	call   800158 <_panic>
		return r;
	}

	// Change the permission on the parent
	if ((r = sys_page_map(0, va, 0, va, perm)) < 0) {
  800df3:	83 ec 0c             	sub    $0xc,%esp
  800df6:	56                   	push   %esi
  800df7:	53                   	push   %ebx
  800df8:	6a 00                	push   $0x0
  800dfa:	53                   	push   %ebx
  800dfb:	6a 00                	push   $0x0
  800dfd:	e8 fa fd ff ff       	call   800bfc <sys_page_map>
  800e02:	83 c4 20             	add    $0x20,%esp
  800e05:	85 c0                	test   %eax,%eax
  800e07:	79 12                	jns    800e1b <duppage+0x71>
		panic("sys_page_alloc: %e", r);
  800e09:	50                   	push   %eax
  800e0a:	68 aa 24 80 00       	push   $0x8024aa
  800e0f:	6a 5c                	push   $0x5c
  800e11:	68 bd 24 80 00       	push   $0x8024bd
  800e16:	e8 3d f3 ff ff       	call   800158 <_panic>
		return r;
	}

	return 0;
}
  800e1b:	b8 00 00 00 00       	mov    $0x0,%eax
  800e20:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e23:	5b                   	pop    %ebx
  800e24:	5e                   	pop    %esi
  800e25:	5d                   	pop    %ebp
  800e26:	c3                   	ret    

00800e27 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e27:	55                   	push   %ebp
  800e28:	89 e5                	mov    %esp,%ebp
  800e2a:	53                   	push   %ebx
  800e2b:	83 ec 04             	sub    $0x4,%esp
  800e2e:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e31:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	unsigned pn = ((uint32_t)addr)/PGSIZE;
  800e33:	89 da                	mov    %ebx,%edx
  800e35:	c1 ea 0c             	shr    $0xc,%edx
	pte_t pte = uvpt[pn];
  800e38:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(err & FEC_WR) || !(pte & PTE_COW)) {
  800e3f:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e43:	74 05                	je     800e4a <pgfault+0x23>
  800e45:	f6 c6 08             	test   $0x8,%dh
  800e48:	75 14                	jne    800e5e <pgfault+0x37>
		panic("fork pgfault handler: does not handle this fault");
  800e4a:	83 ec 04             	sub    $0x4,%esp
  800e4d:	68 2c 25 80 00       	push   $0x80252c
  800e52:	6a 1f                	push   $0x1f
  800e54:	68 bd 24 80 00       	push   $0x8024bd
  800e59:	e8 fa f2 ff ff       	call   800158 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// Allocate a new page, mapped at temp location
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  800e5e:	83 ec 04             	sub    $0x4,%esp
  800e61:	6a 07                	push   $0x7
  800e63:	68 00 f0 7f 00       	push   $0x7ff000
  800e68:	6a 00                	push   $0x0
  800e6a:	e8 4a fd ff ff       	call   800bb9 <sys_page_alloc>
  800e6f:	83 c4 10             	add    $0x10,%esp
  800e72:	85 c0                	test   %eax,%eax
  800e74:	79 12                	jns    800e88 <pgfault+0x61>
		panic("sys_page_alloc: %e", r);
  800e76:	50                   	push   %eax
  800e77:	68 aa 24 80 00       	push   $0x8024aa
  800e7c:	6a 2b                	push   $0x2b
  800e7e:	68 bd 24 80 00       	push   $0x8024bd
  800e83:	e8 d0 f2 ff ff       	call   800158 <_panic>

	// Copy the data from the old page to this new page
	void *addr_pgstart = (void *) ROUNDDOWN(addr, PGSIZE);
  800e88:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr_pgstart, PGSIZE);
  800e8e:	83 ec 04             	sub    $0x4,%esp
  800e91:	68 00 10 00 00       	push   $0x1000
  800e96:	53                   	push   %ebx
  800e97:	68 00 f0 7f 00       	push   $0x7ff000
  800e9c:	e8 a7 fa ff ff       	call   800948 <memmove>

	// Move the new page to the old page's address
	if ((r = sys_page_map(0, PFTEMP, 0, addr_pgstart, PTE_P|PTE_U|PTE_W)) < 0)
  800ea1:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800ea8:	53                   	push   %ebx
  800ea9:	6a 00                	push   $0x0
  800eab:	68 00 f0 7f 00       	push   $0x7ff000
  800eb0:	6a 00                	push   $0x0
  800eb2:	e8 45 fd ff ff       	call   800bfc <sys_page_map>
  800eb7:	83 c4 20             	add    $0x20,%esp
  800eba:	85 c0                	test   %eax,%eax
  800ebc:	79 12                	jns    800ed0 <pgfault+0xa9>
		panic("sys_page_map: %e", r);
  800ebe:	50                   	push   %eax
  800ebf:	68 c8 24 80 00       	push   $0x8024c8
  800ec4:	6a 33                	push   $0x33
  800ec6:	68 bd 24 80 00       	push   $0x8024bd
  800ecb:	e8 88 f2 ff ff       	call   800158 <_panic>

	// Unmap the temp location
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800ed0:	83 ec 08             	sub    $0x8,%esp
  800ed3:	68 00 f0 7f 00       	push   $0x7ff000
  800ed8:	6a 00                	push   $0x0
  800eda:	e8 5f fd ff ff       	call   800c3e <sys_page_unmap>
  800edf:	83 c4 10             	add    $0x10,%esp
  800ee2:	85 c0                	test   %eax,%eax
  800ee4:	79 12                	jns    800ef8 <pgfault+0xd1>
		panic("sys_page_unmap: %e", r);
  800ee6:	50                   	push   %eax
  800ee7:	68 d9 24 80 00       	push   $0x8024d9
  800eec:	6a 37                	push   $0x37
  800eee:	68 bd 24 80 00       	push   $0x8024bd
  800ef3:	e8 60 f2 ff ff       	call   800158 <_panic>
}
  800ef8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800efb:	c9                   	leave  
  800efc:	c3                   	ret    

00800efd <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800efd:	55                   	push   %ebp
  800efe:	89 e5                	mov    %esp,%ebp
  800f00:	56                   	push   %esi
  800f01:	53                   	push   %ebx
  800f02:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
	// Set up page fault handler
	set_pgfault_handler(&pgfault);
  800f05:	68 27 0e 80 00       	push   $0x800e27
  800f0a:	e8 ec 0e 00 00       	call   801dfb <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f0f:	b8 07 00 00 00       	mov    $0x7,%eax
  800f14:	cd 30                	int    $0x30

	// Create child
	envid_t envid = sys_exofork();
  800f16:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (envid < 0) {
  800f19:	83 c4 10             	add    $0x10,%esp
  800f1c:	85 c0                	test   %eax,%eax
  800f1e:	79 12                	jns    800f32 <fork+0x35>
		panic("sys_exofork: %e", envid);
  800f20:	50                   	push   %eax
  800f21:	68 ec 24 80 00       	push   $0x8024ec
  800f26:	6a 7d                	push   $0x7d
  800f28:	68 bd 24 80 00       	push   $0x8024bd
  800f2d:	e8 26 f2 ff ff       	call   800158 <_panic>
		return envid;
	}
	if (envid == 0) {
  800f32:	85 c0                	test   %eax,%eax
  800f34:	75 1e                	jne    800f54 <fork+0x57>
		// We are the child.
		thisenv = &envs[ENVX(sys_getenvid())]; // Fix thisenv
  800f36:	e8 40 fc ff ff       	call   800b7b <sys_getenvid>
  800f3b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f40:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f43:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f48:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800f4d:	b8 00 00 00 00       	mov    $0x0,%eax
  800f52:	eb 7d                	jmp    800fd1 <fork+0xd4>

	// Set page fault handler on the child.
	// The parent needs to do it, else the child wouldn't be able to handle
	// the fault when trying to access it's stack (which happens as soon it starts)
	extern void _pgfault_upcall(void);
	sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);
  800f54:	83 ec 04             	sub    $0x4,%esp
  800f57:	6a 07                	push   $0x7
  800f59:	68 00 f0 bf ee       	push   $0xeebff000
  800f5e:	50                   	push   %eax
  800f5f:	e8 55 fc ff ff       	call   800bb9 <sys_page_alloc>
	sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  800f64:	83 c4 08             	add    $0x8,%esp
  800f67:	68 40 1e 80 00       	push   $0x801e40
  800f6c:	ff 75 f4             	pushl  -0xc(%ebp)
  800f6f:	e8 90 fd ff ff       	call   800d04 <sys_env_set_pgfault_upcall>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  800f74:	be 04 60 80 00       	mov    $0x806004,%esi
  800f79:	c1 ee 0c             	shr    $0xc,%esi
  800f7c:	83 c4 10             	add    $0x10,%esp
  800f7f:	bb 00 08 00 00       	mov    $0x800,%ebx
  800f84:	eb 0d                	jmp    800f93 <fork+0x96>
		duppage(envid, pn);
  800f86:	89 da                	mov    %ebx,%edx
  800f88:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f8b:	e8 1a fe ff ff       	call   800daa <duppage>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  800f90:	83 c3 01             	add    $0x1,%ebx
  800f93:	39 f3                	cmp    %esi,%ebx
  800f95:	76 ef                	jbe    800f86 <fork+0x89>
	}

	// Also copy the stack we are currently running on
	// I think it should loop from ustacktop to this page, since the stack
	// can have more than 1 page
	duppage(envid, ((uint32_t) &envid)/PGSIZE);
  800f97:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800f9a:	c1 ea 0c             	shr    $0xc,%edx
  800f9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fa0:	e8 05 fe ff ff       	call   800daa <duppage>

	// Start the child environmnet running
	int r;
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  800fa5:	83 ec 08             	sub    $0x8,%esp
  800fa8:	6a 02                	push   $0x2
  800faa:	ff 75 f4             	pushl  -0xc(%ebp)
  800fad:	e8 ce fc ff ff       	call   800c80 <sys_env_set_status>
  800fb2:	83 c4 10             	add    $0x10,%esp
  800fb5:	85 c0                	test   %eax,%eax
  800fb7:	79 15                	jns    800fce <fork+0xd1>
		panic("sys_env_set_status: %e", r);
  800fb9:	50                   	push   %eax
  800fba:	68 fc 24 80 00       	push   $0x8024fc
  800fbf:	68 9d 00 00 00       	push   $0x9d
  800fc4:	68 bd 24 80 00       	push   $0x8024bd
  800fc9:	e8 8a f1 ff ff       	call   800158 <_panic>
		return r;
	}

	return envid;
  800fce:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800fd1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fd4:	5b                   	pop    %ebx
  800fd5:	5e                   	pop    %esi
  800fd6:	5d                   	pop    %ebp
  800fd7:	c3                   	ret    

00800fd8 <sfork>:

// Challenge!
int
sfork(void)
{
  800fd8:	55                   	push   %ebp
  800fd9:	89 e5                	mov    %esp,%ebp
  800fdb:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800fde:	68 13 25 80 00       	push   $0x802513
  800fe3:	68 a8 00 00 00       	push   $0xa8
  800fe8:	68 bd 24 80 00       	push   $0x8024bd
  800fed:	e8 66 f1 ff ff       	call   800158 <_panic>

00800ff2 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800ff2:	55                   	push   %ebp
  800ff3:	89 e5                	mov    %esp,%ebp
  800ff5:	56                   	push   %esi
  800ff6:	53                   	push   %ebx
  800ff7:	8b 75 08             	mov    0x8(%ebp),%esi
  800ffa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ffd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  801000:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801002:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801007:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  80100a:	83 ec 0c             	sub    $0xc,%esp
  80100d:	50                   	push   %eax
  80100e:	e8 56 fd ff ff       	call   800d69 <sys_ipc_recv>

	if (r < 0) {
  801013:	83 c4 10             	add    $0x10,%esp
  801016:	85 c0                	test   %eax,%eax
  801018:	79 16                	jns    801030 <ipc_recv+0x3e>
		if (from_env_store)
  80101a:	85 f6                	test   %esi,%esi
  80101c:	74 06                	je     801024 <ipc_recv+0x32>
			*from_env_store = 0;
  80101e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  801024:	85 db                	test   %ebx,%ebx
  801026:	74 2c                	je     801054 <ipc_recv+0x62>
			*perm_store = 0;
  801028:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80102e:	eb 24                	jmp    801054 <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  801030:	85 f6                	test   %esi,%esi
  801032:	74 0a                	je     80103e <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  801034:	a1 04 40 80 00       	mov    0x804004,%eax
  801039:	8b 40 74             	mov    0x74(%eax),%eax
  80103c:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  80103e:	85 db                	test   %ebx,%ebx
  801040:	74 0a                	je     80104c <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  801042:	a1 04 40 80 00       	mov    0x804004,%eax
  801047:	8b 40 78             	mov    0x78(%eax),%eax
  80104a:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  80104c:	a1 04 40 80 00       	mov    0x804004,%eax
  801051:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  801054:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801057:	5b                   	pop    %ebx
  801058:	5e                   	pop    %esi
  801059:	5d                   	pop    %ebp
  80105a:	c3                   	ret    

0080105b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80105b:	55                   	push   %ebp
  80105c:	89 e5                	mov    %esp,%ebp
  80105e:	57                   	push   %edi
  80105f:	56                   	push   %esi
  801060:	53                   	push   %ebx
  801061:	83 ec 0c             	sub    $0xc,%esp
  801064:	8b 7d 08             	mov    0x8(%ebp),%edi
  801067:	8b 75 0c             	mov    0xc(%ebp),%esi
  80106a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  80106d:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  80106f:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801074:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  801077:	ff 75 14             	pushl  0x14(%ebp)
  80107a:	53                   	push   %ebx
  80107b:	56                   	push   %esi
  80107c:	57                   	push   %edi
  80107d:	e8 c4 fc ff ff       	call   800d46 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  801082:	83 c4 10             	add    $0x10,%esp
  801085:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801088:	75 07                	jne    801091 <ipc_send+0x36>
			sys_yield();
  80108a:	e8 0b fb ff ff       	call   800b9a <sys_yield>
  80108f:	eb e6                	jmp    801077 <ipc_send+0x1c>
		} else if (r < 0) {
  801091:	85 c0                	test   %eax,%eax
  801093:	79 12                	jns    8010a7 <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  801095:	50                   	push   %eax
  801096:	68 5d 25 80 00       	push   $0x80255d
  80109b:	6a 51                	push   $0x51
  80109d:	68 6a 25 80 00       	push   $0x80256a
  8010a2:	e8 b1 f0 ff ff       	call   800158 <_panic>
		}
	}
}
  8010a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010aa:	5b                   	pop    %ebx
  8010ab:	5e                   	pop    %esi
  8010ac:	5f                   	pop    %edi
  8010ad:	5d                   	pop    %ebp
  8010ae:	c3                   	ret    

008010af <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8010af:	55                   	push   %ebp
  8010b0:	89 e5                	mov    %esp,%ebp
  8010b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8010b5:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8010ba:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8010bd:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8010c3:	8b 52 50             	mov    0x50(%edx),%edx
  8010c6:	39 ca                	cmp    %ecx,%edx
  8010c8:	75 0d                	jne    8010d7 <ipc_find_env+0x28>
			return envs[i].env_id;
  8010ca:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8010cd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010d2:	8b 40 48             	mov    0x48(%eax),%eax
  8010d5:	eb 0f                	jmp    8010e6 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8010d7:	83 c0 01             	add    $0x1,%eax
  8010da:	3d 00 04 00 00       	cmp    $0x400,%eax
  8010df:	75 d9                	jne    8010ba <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8010e1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8010e6:	5d                   	pop    %ebp
  8010e7:	c3                   	ret    

008010e8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010e8:	55                   	push   %ebp
  8010e9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ee:	05 00 00 00 30       	add    $0x30000000,%eax
  8010f3:	c1 e8 0c             	shr    $0xc,%eax
}
  8010f6:	5d                   	pop    %ebp
  8010f7:	c3                   	ret    

008010f8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010f8:	55                   	push   %ebp
  8010f9:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8010fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8010fe:	05 00 00 00 30       	add    $0x30000000,%eax
  801103:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801108:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80110d:	5d                   	pop    %ebp
  80110e:	c3                   	ret    

0080110f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80110f:	55                   	push   %ebp
  801110:	89 e5                	mov    %esp,%ebp
  801112:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801115:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80111a:	89 c2                	mov    %eax,%edx
  80111c:	c1 ea 16             	shr    $0x16,%edx
  80111f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801126:	f6 c2 01             	test   $0x1,%dl
  801129:	74 11                	je     80113c <fd_alloc+0x2d>
  80112b:	89 c2                	mov    %eax,%edx
  80112d:	c1 ea 0c             	shr    $0xc,%edx
  801130:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801137:	f6 c2 01             	test   $0x1,%dl
  80113a:	75 09                	jne    801145 <fd_alloc+0x36>
			*fd_store = fd;
  80113c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80113e:	b8 00 00 00 00       	mov    $0x0,%eax
  801143:	eb 17                	jmp    80115c <fd_alloc+0x4d>
  801145:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80114a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80114f:	75 c9                	jne    80111a <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801151:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801157:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80115c:	5d                   	pop    %ebp
  80115d:	c3                   	ret    

0080115e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80115e:	55                   	push   %ebp
  80115f:	89 e5                	mov    %esp,%ebp
  801161:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801164:	83 f8 1f             	cmp    $0x1f,%eax
  801167:	77 36                	ja     80119f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801169:	c1 e0 0c             	shl    $0xc,%eax
  80116c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801171:	89 c2                	mov    %eax,%edx
  801173:	c1 ea 16             	shr    $0x16,%edx
  801176:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80117d:	f6 c2 01             	test   $0x1,%dl
  801180:	74 24                	je     8011a6 <fd_lookup+0x48>
  801182:	89 c2                	mov    %eax,%edx
  801184:	c1 ea 0c             	shr    $0xc,%edx
  801187:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80118e:	f6 c2 01             	test   $0x1,%dl
  801191:	74 1a                	je     8011ad <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801193:	8b 55 0c             	mov    0xc(%ebp),%edx
  801196:	89 02                	mov    %eax,(%edx)
	return 0;
  801198:	b8 00 00 00 00       	mov    $0x0,%eax
  80119d:	eb 13                	jmp    8011b2 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80119f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011a4:	eb 0c                	jmp    8011b2 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011a6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011ab:	eb 05                	jmp    8011b2 <fd_lookup+0x54>
  8011ad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8011b2:	5d                   	pop    %ebp
  8011b3:	c3                   	ret    

008011b4 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011b4:	55                   	push   %ebp
  8011b5:	89 e5                	mov    %esp,%ebp
  8011b7:	83 ec 08             	sub    $0x8,%esp
  8011ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011bd:	ba f4 25 80 00       	mov    $0x8025f4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8011c2:	eb 13                	jmp    8011d7 <dev_lookup+0x23>
  8011c4:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8011c7:	39 08                	cmp    %ecx,(%eax)
  8011c9:	75 0c                	jne    8011d7 <dev_lookup+0x23>
			*dev = devtab[i];
  8011cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011ce:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8011d5:	eb 2e                	jmp    801205 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011d7:	8b 02                	mov    (%edx),%eax
  8011d9:	85 c0                	test   %eax,%eax
  8011db:	75 e7                	jne    8011c4 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011dd:	a1 04 40 80 00       	mov    0x804004,%eax
  8011e2:	8b 40 48             	mov    0x48(%eax),%eax
  8011e5:	83 ec 04             	sub    $0x4,%esp
  8011e8:	51                   	push   %ecx
  8011e9:	50                   	push   %eax
  8011ea:	68 74 25 80 00       	push   $0x802574
  8011ef:	e8 3d f0 ff ff       	call   800231 <cprintf>
	*dev = 0;
  8011f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011f7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8011fd:	83 c4 10             	add    $0x10,%esp
  801200:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801205:	c9                   	leave  
  801206:	c3                   	ret    

00801207 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801207:	55                   	push   %ebp
  801208:	89 e5                	mov    %esp,%ebp
  80120a:	56                   	push   %esi
  80120b:	53                   	push   %ebx
  80120c:	83 ec 10             	sub    $0x10,%esp
  80120f:	8b 75 08             	mov    0x8(%ebp),%esi
  801212:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801215:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801218:	50                   	push   %eax
  801219:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80121f:	c1 e8 0c             	shr    $0xc,%eax
  801222:	50                   	push   %eax
  801223:	e8 36 ff ff ff       	call   80115e <fd_lookup>
  801228:	83 c4 08             	add    $0x8,%esp
  80122b:	85 c0                	test   %eax,%eax
  80122d:	78 05                	js     801234 <fd_close+0x2d>
	    || fd != fd2)
  80122f:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801232:	74 0c                	je     801240 <fd_close+0x39>
		return (must_exist ? r : 0);
  801234:	84 db                	test   %bl,%bl
  801236:	ba 00 00 00 00       	mov    $0x0,%edx
  80123b:	0f 44 c2             	cmove  %edx,%eax
  80123e:	eb 41                	jmp    801281 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801240:	83 ec 08             	sub    $0x8,%esp
  801243:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801246:	50                   	push   %eax
  801247:	ff 36                	pushl  (%esi)
  801249:	e8 66 ff ff ff       	call   8011b4 <dev_lookup>
  80124e:	89 c3                	mov    %eax,%ebx
  801250:	83 c4 10             	add    $0x10,%esp
  801253:	85 c0                	test   %eax,%eax
  801255:	78 1a                	js     801271 <fd_close+0x6a>
		if (dev->dev_close)
  801257:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80125a:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80125d:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801262:	85 c0                	test   %eax,%eax
  801264:	74 0b                	je     801271 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801266:	83 ec 0c             	sub    $0xc,%esp
  801269:	56                   	push   %esi
  80126a:	ff d0                	call   *%eax
  80126c:	89 c3                	mov    %eax,%ebx
  80126e:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801271:	83 ec 08             	sub    $0x8,%esp
  801274:	56                   	push   %esi
  801275:	6a 00                	push   $0x0
  801277:	e8 c2 f9 ff ff       	call   800c3e <sys_page_unmap>
	return r;
  80127c:	83 c4 10             	add    $0x10,%esp
  80127f:	89 d8                	mov    %ebx,%eax
}
  801281:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801284:	5b                   	pop    %ebx
  801285:	5e                   	pop    %esi
  801286:	5d                   	pop    %ebp
  801287:	c3                   	ret    

00801288 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801288:	55                   	push   %ebp
  801289:	89 e5                	mov    %esp,%ebp
  80128b:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80128e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801291:	50                   	push   %eax
  801292:	ff 75 08             	pushl  0x8(%ebp)
  801295:	e8 c4 fe ff ff       	call   80115e <fd_lookup>
  80129a:	83 c4 08             	add    $0x8,%esp
  80129d:	85 c0                	test   %eax,%eax
  80129f:	78 10                	js     8012b1 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8012a1:	83 ec 08             	sub    $0x8,%esp
  8012a4:	6a 01                	push   $0x1
  8012a6:	ff 75 f4             	pushl  -0xc(%ebp)
  8012a9:	e8 59 ff ff ff       	call   801207 <fd_close>
  8012ae:	83 c4 10             	add    $0x10,%esp
}
  8012b1:	c9                   	leave  
  8012b2:	c3                   	ret    

008012b3 <close_all>:

void
close_all(void)
{
  8012b3:	55                   	push   %ebp
  8012b4:	89 e5                	mov    %esp,%ebp
  8012b6:	53                   	push   %ebx
  8012b7:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012ba:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012bf:	83 ec 0c             	sub    $0xc,%esp
  8012c2:	53                   	push   %ebx
  8012c3:	e8 c0 ff ff ff       	call   801288 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8012c8:	83 c3 01             	add    $0x1,%ebx
  8012cb:	83 c4 10             	add    $0x10,%esp
  8012ce:	83 fb 20             	cmp    $0x20,%ebx
  8012d1:	75 ec                	jne    8012bf <close_all+0xc>
		close(i);
}
  8012d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012d6:	c9                   	leave  
  8012d7:	c3                   	ret    

008012d8 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012d8:	55                   	push   %ebp
  8012d9:	89 e5                	mov    %esp,%ebp
  8012db:	57                   	push   %edi
  8012dc:	56                   	push   %esi
  8012dd:	53                   	push   %ebx
  8012de:	83 ec 2c             	sub    $0x2c,%esp
  8012e1:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012e4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012e7:	50                   	push   %eax
  8012e8:	ff 75 08             	pushl  0x8(%ebp)
  8012eb:	e8 6e fe ff ff       	call   80115e <fd_lookup>
  8012f0:	83 c4 08             	add    $0x8,%esp
  8012f3:	85 c0                	test   %eax,%eax
  8012f5:	0f 88 c1 00 00 00    	js     8013bc <dup+0xe4>
		return r;
	close(newfdnum);
  8012fb:	83 ec 0c             	sub    $0xc,%esp
  8012fe:	56                   	push   %esi
  8012ff:	e8 84 ff ff ff       	call   801288 <close>

	newfd = INDEX2FD(newfdnum);
  801304:	89 f3                	mov    %esi,%ebx
  801306:	c1 e3 0c             	shl    $0xc,%ebx
  801309:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80130f:	83 c4 04             	add    $0x4,%esp
  801312:	ff 75 e4             	pushl  -0x1c(%ebp)
  801315:	e8 de fd ff ff       	call   8010f8 <fd2data>
  80131a:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80131c:	89 1c 24             	mov    %ebx,(%esp)
  80131f:	e8 d4 fd ff ff       	call   8010f8 <fd2data>
  801324:	83 c4 10             	add    $0x10,%esp
  801327:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80132a:	89 f8                	mov    %edi,%eax
  80132c:	c1 e8 16             	shr    $0x16,%eax
  80132f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801336:	a8 01                	test   $0x1,%al
  801338:	74 37                	je     801371 <dup+0x99>
  80133a:	89 f8                	mov    %edi,%eax
  80133c:	c1 e8 0c             	shr    $0xc,%eax
  80133f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801346:	f6 c2 01             	test   $0x1,%dl
  801349:	74 26                	je     801371 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80134b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801352:	83 ec 0c             	sub    $0xc,%esp
  801355:	25 07 0e 00 00       	and    $0xe07,%eax
  80135a:	50                   	push   %eax
  80135b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80135e:	6a 00                	push   $0x0
  801360:	57                   	push   %edi
  801361:	6a 00                	push   $0x0
  801363:	e8 94 f8 ff ff       	call   800bfc <sys_page_map>
  801368:	89 c7                	mov    %eax,%edi
  80136a:	83 c4 20             	add    $0x20,%esp
  80136d:	85 c0                	test   %eax,%eax
  80136f:	78 2e                	js     80139f <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801371:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801374:	89 d0                	mov    %edx,%eax
  801376:	c1 e8 0c             	shr    $0xc,%eax
  801379:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801380:	83 ec 0c             	sub    $0xc,%esp
  801383:	25 07 0e 00 00       	and    $0xe07,%eax
  801388:	50                   	push   %eax
  801389:	53                   	push   %ebx
  80138a:	6a 00                	push   $0x0
  80138c:	52                   	push   %edx
  80138d:	6a 00                	push   $0x0
  80138f:	e8 68 f8 ff ff       	call   800bfc <sys_page_map>
  801394:	89 c7                	mov    %eax,%edi
  801396:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801399:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80139b:	85 ff                	test   %edi,%edi
  80139d:	79 1d                	jns    8013bc <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80139f:	83 ec 08             	sub    $0x8,%esp
  8013a2:	53                   	push   %ebx
  8013a3:	6a 00                	push   $0x0
  8013a5:	e8 94 f8 ff ff       	call   800c3e <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013aa:	83 c4 08             	add    $0x8,%esp
  8013ad:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013b0:	6a 00                	push   $0x0
  8013b2:	e8 87 f8 ff ff       	call   800c3e <sys_page_unmap>
	return r;
  8013b7:	83 c4 10             	add    $0x10,%esp
  8013ba:	89 f8                	mov    %edi,%eax
}
  8013bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013bf:	5b                   	pop    %ebx
  8013c0:	5e                   	pop    %esi
  8013c1:	5f                   	pop    %edi
  8013c2:	5d                   	pop    %ebp
  8013c3:	c3                   	ret    

008013c4 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013c4:	55                   	push   %ebp
  8013c5:	89 e5                	mov    %esp,%ebp
  8013c7:	53                   	push   %ebx
  8013c8:	83 ec 14             	sub    $0x14,%esp
  8013cb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013ce:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013d1:	50                   	push   %eax
  8013d2:	53                   	push   %ebx
  8013d3:	e8 86 fd ff ff       	call   80115e <fd_lookup>
  8013d8:	83 c4 08             	add    $0x8,%esp
  8013db:	89 c2                	mov    %eax,%edx
  8013dd:	85 c0                	test   %eax,%eax
  8013df:	78 6d                	js     80144e <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013e1:	83 ec 08             	sub    $0x8,%esp
  8013e4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013e7:	50                   	push   %eax
  8013e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013eb:	ff 30                	pushl  (%eax)
  8013ed:	e8 c2 fd ff ff       	call   8011b4 <dev_lookup>
  8013f2:	83 c4 10             	add    $0x10,%esp
  8013f5:	85 c0                	test   %eax,%eax
  8013f7:	78 4c                	js     801445 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013f9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013fc:	8b 42 08             	mov    0x8(%edx),%eax
  8013ff:	83 e0 03             	and    $0x3,%eax
  801402:	83 f8 01             	cmp    $0x1,%eax
  801405:	75 21                	jne    801428 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801407:	a1 04 40 80 00       	mov    0x804004,%eax
  80140c:	8b 40 48             	mov    0x48(%eax),%eax
  80140f:	83 ec 04             	sub    $0x4,%esp
  801412:	53                   	push   %ebx
  801413:	50                   	push   %eax
  801414:	68 b8 25 80 00       	push   $0x8025b8
  801419:	e8 13 ee ff ff       	call   800231 <cprintf>
		return -E_INVAL;
  80141e:	83 c4 10             	add    $0x10,%esp
  801421:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801426:	eb 26                	jmp    80144e <read+0x8a>
	}
	if (!dev->dev_read)
  801428:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80142b:	8b 40 08             	mov    0x8(%eax),%eax
  80142e:	85 c0                	test   %eax,%eax
  801430:	74 17                	je     801449 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801432:	83 ec 04             	sub    $0x4,%esp
  801435:	ff 75 10             	pushl  0x10(%ebp)
  801438:	ff 75 0c             	pushl  0xc(%ebp)
  80143b:	52                   	push   %edx
  80143c:	ff d0                	call   *%eax
  80143e:	89 c2                	mov    %eax,%edx
  801440:	83 c4 10             	add    $0x10,%esp
  801443:	eb 09                	jmp    80144e <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801445:	89 c2                	mov    %eax,%edx
  801447:	eb 05                	jmp    80144e <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801449:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80144e:	89 d0                	mov    %edx,%eax
  801450:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801453:	c9                   	leave  
  801454:	c3                   	ret    

00801455 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801455:	55                   	push   %ebp
  801456:	89 e5                	mov    %esp,%ebp
  801458:	57                   	push   %edi
  801459:	56                   	push   %esi
  80145a:	53                   	push   %ebx
  80145b:	83 ec 0c             	sub    $0xc,%esp
  80145e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801461:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801464:	bb 00 00 00 00       	mov    $0x0,%ebx
  801469:	eb 21                	jmp    80148c <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80146b:	83 ec 04             	sub    $0x4,%esp
  80146e:	89 f0                	mov    %esi,%eax
  801470:	29 d8                	sub    %ebx,%eax
  801472:	50                   	push   %eax
  801473:	89 d8                	mov    %ebx,%eax
  801475:	03 45 0c             	add    0xc(%ebp),%eax
  801478:	50                   	push   %eax
  801479:	57                   	push   %edi
  80147a:	e8 45 ff ff ff       	call   8013c4 <read>
		if (m < 0)
  80147f:	83 c4 10             	add    $0x10,%esp
  801482:	85 c0                	test   %eax,%eax
  801484:	78 10                	js     801496 <readn+0x41>
			return m;
		if (m == 0)
  801486:	85 c0                	test   %eax,%eax
  801488:	74 0a                	je     801494 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80148a:	01 c3                	add    %eax,%ebx
  80148c:	39 f3                	cmp    %esi,%ebx
  80148e:	72 db                	jb     80146b <readn+0x16>
  801490:	89 d8                	mov    %ebx,%eax
  801492:	eb 02                	jmp    801496 <readn+0x41>
  801494:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801496:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801499:	5b                   	pop    %ebx
  80149a:	5e                   	pop    %esi
  80149b:	5f                   	pop    %edi
  80149c:	5d                   	pop    %ebp
  80149d:	c3                   	ret    

0080149e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80149e:	55                   	push   %ebp
  80149f:	89 e5                	mov    %esp,%ebp
  8014a1:	53                   	push   %ebx
  8014a2:	83 ec 14             	sub    $0x14,%esp
  8014a5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014a8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014ab:	50                   	push   %eax
  8014ac:	53                   	push   %ebx
  8014ad:	e8 ac fc ff ff       	call   80115e <fd_lookup>
  8014b2:	83 c4 08             	add    $0x8,%esp
  8014b5:	89 c2                	mov    %eax,%edx
  8014b7:	85 c0                	test   %eax,%eax
  8014b9:	78 68                	js     801523 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014bb:	83 ec 08             	sub    $0x8,%esp
  8014be:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014c1:	50                   	push   %eax
  8014c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014c5:	ff 30                	pushl  (%eax)
  8014c7:	e8 e8 fc ff ff       	call   8011b4 <dev_lookup>
  8014cc:	83 c4 10             	add    $0x10,%esp
  8014cf:	85 c0                	test   %eax,%eax
  8014d1:	78 47                	js     80151a <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014d6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014da:	75 21                	jne    8014fd <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014dc:	a1 04 40 80 00       	mov    0x804004,%eax
  8014e1:	8b 40 48             	mov    0x48(%eax),%eax
  8014e4:	83 ec 04             	sub    $0x4,%esp
  8014e7:	53                   	push   %ebx
  8014e8:	50                   	push   %eax
  8014e9:	68 d4 25 80 00       	push   $0x8025d4
  8014ee:	e8 3e ed ff ff       	call   800231 <cprintf>
		return -E_INVAL;
  8014f3:	83 c4 10             	add    $0x10,%esp
  8014f6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014fb:	eb 26                	jmp    801523 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014fd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801500:	8b 52 0c             	mov    0xc(%edx),%edx
  801503:	85 d2                	test   %edx,%edx
  801505:	74 17                	je     80151e <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801507:	83 ec 04             	sub    $0x4,%esp
  80150a:	ff 75 10             	pushl  0x10(%ebp)
  80150d:	ff 75 0c             	pushl  0xc(%ebp)
  801510:	50                   	push   %eax
  801511:	ff d2                	call   *%edx
  801513:	89 c2                	mov    %eax,%edx
  801515:	83 c4 10             	add    $0x10,%esp
  801518:	eb 09                	jmp    801523 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80151a:	89 c2                	mov    %eax,%edx
  80151c:	eb 05                	jmp    801523 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80151e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801523:	89 d0                	mov    %edx,%eax
  801525:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801528:	c9                   	leave  
  801529:	c3                   	ret    

0080152a <seek>:

int
seek(int fdnum, off_t offset)
{
  80152a:	55                   	push   %ebp
  80152b:	89 e5                	mov    %esp,%ebp
  80152d:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801530:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801533:	50                   	push   %eax
  801534:	ff 75 08             	pushl  0x8(%ebp)
  801537:	e8 22 fc ff ff       	call   80115e <fd_lookup>
  80153c:	83 c4 08             	add    $0x8,%esp
  80153f:	85 c0                	test   %eax,%eax
  801541:	78 0e                	js     801551 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801543:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801546:	8b 55 0c             	mov    0xc(%ebp),%edx
  801549:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80154c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801551:	c9                   	leave  
  801552:	c3                   	ret    

00801553 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801553:	55                   	push   %ebp
  801554:	89 e5                	mov    %esp,%ebp
  801556:	53                   	push   %ebx
  801557:	83 ec 14             	sub    $0x14,%esp
  80155a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80155d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801560:	50                   	push   %eax
  801561:	53                   	push   %ebx
  801562:	e8 f7 fb ff ff       	call   80115e <fd_lookup>
  801567:	83 c4 08             	add    $0x8,%esp
  80156a:	89 c2                	mov    %eax,%edx
  80156c:	85 c0                	test   %eax,%eax
  80156e:	78 65                	js     8015d5 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801570:	83 ec 08             	sub    $0x8,%esp
  801573:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801576:	50                   	push   %eax
  801577:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80157a:	ff 30                	pushl  (%eax)
  80157c:	e8 33 fc ff ff       	call   8011b4 <dev_lookup>
  801581:	83 c4 10             	add    $0x10,%esp
  801584:	85 c0                	test   %eax,%eax
  801586:	78 44                	js     8015cc <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801588:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80158b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80158f:	75 21                	jne    8015b2 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801591:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801596:	8b 40 48             	mov    0x48(%eax),%eax
  801599:	83 ec 04             	sub    $0x4,%esp
  80159c:	53                   	push   %ebx
  80159d:	50                   	push   %eax
  80159e:	68 94 25 80 00       	push   $0x802594
  8015a3:	e8 89 ec ff ff       	call   800231 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015a8:	83 c4 10             	add    $0x10,%esp
  8015ab:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015b0:	eb 23                	jmp    8015d5 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8015b2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015b5:	8b 52 18             	mov    0x18(%edx),%edx
  8015b8:	85 d2                	test   %edx,%edx
  8015ba:	74 14                	je     8015d0 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015bc:	83 ec 08             	sub    $0x8,%esp
  8015bf:	ff 75 0c             	pushl  0xc(%ebp)
  8015c2:	50                   	push   %eax
  8015c3:	ff d2                	call   *%edx
  8015c5:	89 c2                	mov    %eax,%edx
  8015c7:	83 c4 10             	add    $0x10,%esp
  8015ca:	eb 09                	jmp    8015d5 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015cc:	89 c2                	mov    %eax,%edx
  8015ce:	eb 05                	jmp    8015d5 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8015d0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8015d5:	89 d0                	mov    %edx,%eax
  8015d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015da:	c9                   	leave  
  8015db:	c3                   	ret    

008015dc <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015dc:	55                   	push   %ebp
  8015dd:	89 e5                	mov    %esp,%ebp
  8015df:	53                   	push   %ebx
  8015e0:	83 ec 14             	sub    $0x14,%esp
  8015e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015e6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015e9:	50                   	push   %eax
  8015ea:	ff 75 08             	pushl  0x8(%ebp)
  8015ed:	e8 6c fb ff ff       	call   80115e <fd_lookup>
  8015f2:	83 c4 08             	add    $0x8,%esp
  8015f5:	89 c2                	mov    %eax,%edx
  8015f7:	85 c0                	test   %eax,%eax
  8015f9:	78 58                	js     801653 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015fb:	83 ec 08             	sub    $0x8,%esp
  8015fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801601:	50                   	push   %eax
  801602:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801605:	ff 30                	pushl  (%eax)
  801607:	e8 a8 fb ff ff       	call   8011b4 <dev_lookup>
  80160c:	83 c4 10             	add    $0x10,%esp
  80160f:	85 c0                	test   %eax,%eax
  801611:	78 37                	js     80164a <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801613:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801616:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80161a:	74 32                	je     80164e <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80161c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80161f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801626:	00 00 00 
	stat->st_isdir = 0;
  801629:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801630:	00 00 00 
	stat->st_dev = dev;
  801633:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801639:	83 ec 08             	sub    $0x8,%esp
  80163c:	53                   	push   %ebx
  80163d:	ff 75 f0             	pushl  -0x10(%ebp)
  801640:	ff 50 14             	call   *0x14(%eax)
  801643:	89 c2                	mov    %eax,%edx
  801645:	83 c4 10             	add    $0x10,%esp
  801648:	eb 09                	jmp    801653 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80164a:	89 c2                	mov    %eax,%edx
  80164c:	eb 05                	jmp    801653 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80164e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801653:	89 d0                	mov    %edx,%eax
  801655:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801658:	c9                   	leave  
  801659:	c3                   	ret    

0080165a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80165a:	55                   	push   %ebp
  80165b:	89 e5                	mov    %esp,%ebp
  80165d:	56                   	push   %esi
  80165e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80165f:	83 ec 08             	sub    $0x8,%esp
  801662:	6a 00                	push   $0x0
  801664:	ff 75 08             	pushl  0x8(%ebp)
  801667:	e8 0c 02 00 00       	call   801878 <open>
  80166c:	89 c3                	mov    %eax,%ebx
  80166e:	83 c4 10             	add    $0x10,%esp
  801671:	85 c0                	test   %eax,%eax
  801673:	78 1b                	js     801690 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801675:	83 ec 08             	sub    $0x8,%esp
  801678:	ff 75 0c             	pushl  0xc(%ebp)
  80167b:	50                   	push   %eax
  80167c:	e8 5b ff ff ff       	call   8015dc <fstat>
  801681:	89 c6                	mov    %eax,%esi
	close(fd);
  801683:	89 1c 24             	mov    %ebx,(%esp)
  801686:	e8 fd fb ff ff       	call   801288 <close>
	return r;
  80168b:	83 c4 10             	add    $0x10,%esp
  80168e:	89 f0                	mov    %esi,%eax
}
  801690:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801693:	5b                   	pop    %ebx
  801694:	5e                   	pop    %esi
  801695:	5d                   	pop    %ebp
  801696:	c3                   	ret    

00801697 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801697:	55                   	push   %ebp
  801698:	89 e5                	mov    %esp,%ebp
  80169a:	56                   	push   %esi
  80169b:	53                   	push   %ebx
  80169c:	89 c6                	mov    %eax,%esi
  80169e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016a0:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016a7:	75 12                	jne    8016bb <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016a9:	83 ec 0c             	sub    $0xc,%esp
  8016ac:	6a 01                	push   $0x1
  8016ae:	e8 fc f9 ff ff       	call   8010af <ipc_find_env>
  8016b3:	a3 00 40 80 00       	mov    %eax,0x804000
  8016b8:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016bb:	6a 07                	push   $0x7
  8016bd:	68 00 50 80 00       	push   $0x805000
  8016c2:	56                   	push   %esi
  8016c3:	ff 35 00 40 80 00    	pushl  0x804000
  8016c9:	e8 8d f9 ff ff       	call   80105b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016ce:	83 c4 0c             	add    $0xc,%esp
  8016d1:	6a 00                	push   $0x0
  8016d3:	53                   	push   %ebx
  8016d4:	6a 00                	push   $0x0
  8016d6:	e8 17 f9 ff ff       	call   800ff2 <ipc_recv>
}
  8016db:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016de:	5b                   	pop    %ebx
  8016df:	5e                   	pop    %esi
  8016e0:	5d                   	pop    %ebp
  8016e1:	c3                   	ret    

008016e2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016e2:	55                   	push   %ebp
  8016e3:	89 e5                	mov    %esp,%ebp
  8016e5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8016eb:	8b 40 0c             	mov    0xc(%eax),%eax
  8016ee:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8016f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016f6:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016fb:	ba 00 00 00 00       	mov    $0x0,%edx
  801700:	b8 02 00 00 00       	mov    $0x2,%eax
  801705:	e8 8d ff ff ff       	call   801697 <fsipc>
}
  80170a:	c9                   	leave  
  80170b:	c3                   	ret    

0080170c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80170c:	55                   	push   %ebp
  80170d:	89 e5                	mov    %esp,%ebp
  80170f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801712:	8b 45 08             	mov    0x8(%ebp),%eax
  801715:	8b 40 0c             	mov    0xc(%eax),%eax
  801718:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80171d:	ba 00 00 00 00       	mov    $0x0,%edx
  801722:	b8 06 00 00 00       	mov    $0x6,%eax
  801727:	e8 6b ff ff ff       	call   801697 <fsipc>
}
  80172c:	c9                   	leave  
  80172d:	c3                   	ret    

0080172e <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80172e:	55                   	push   %ebp
  80172f:	89 e5                	mov    %esp,%ebp
  801731:	53                   	push   %ebx
  801732:	83 ec 04             	sub    $0x4,%esp
  801735:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801738:	8b 45 08             	mov    0x8(%ebp),%eax
  80173b:	8b 40 0c             	mov    0xc(%eax),%eax
  80173e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801743:	ba 00 00 00 00       	mov    $0x0,%edx
  801748:	b8 05 00 00 00       	mov    $0x5,%eax
  80174d:	e8 45 ff ff ff       	call   801697 <fsipc>
  801752:	85 c0                	test   %eax,%eax
  801754:	78 2c                	js     801782 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801756:	83 ec 08             	sub    $0x8,%esp
  801759:	68 00 50 80 00       	push   $0x805000
  80175e:	53                   	push   %ebx
  80175f:	e8 52 f0 ff ff       	call   8007b6 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801764:	a1 80 50 80 00       	mov    0x805080,%eax
  801769:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80176f:	a1 84 50 80 00       	mov    0x805084,%eax
  801774:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80177a:	83 c4 10             	add    $0x10,%esp
  80177d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801782:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801785:	c9                   	leave  
  801786:	c3                   	ret    

00801787 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801787:	55                   	push   %ebp
  801788:	89 e5                	mov    %esp,%ebp
  80178a:	53                   	push   %ebx
  80178b:	83 ec 08             	sub    $0x8,%esp
  80178e:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801791:	8b 55 08             	mov    0x8(%ebp),%edx
  801794:	8b 52 0c             	mov    0xc(%edx),%edx
  801797:	89 15 00 50 80 00    	mov    %edx,0x805000
  80179d:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8017a2:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  8017a7:	0f 46 d8             	cmovbe %eax,%ebx
	
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  8017aa:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  8017b0:	53                   	push   %ebx
  8017b1:	ff 75 0c             	pushl  0xc(%ebp)
  8017b4:	68 08 50 80 00       	push   $0x805008
  8017b9:	e8 8a f1 ff ff       	call   800948 <memmove>

	
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) 
  8017be:	ba 00 00 00 00       	mov    $0x0,%edx
  8017c3:	b8 04 00 00 00       	mov    $0x4,%eax
  8017c8:	e8 ca fe ff ff       	call   801697 <fsipc>
  8017cd:	83 c4 10             	add    $0x10,%esp
  8017d0:	85 c0                	test   %eax,%eax
  8017d2:	78 1d                	js     8017f1 <devfile_write+0x6a>
		return r;
	assert(r <= n_real); 
  8017d4:	39 d8                	cmp    %ebx,%eax
  8017d6:	76 19                	jbe    8017f1 <devfile_write+0x6a>
  8017d8:	68 04 26 80 00       	push   $0x802604
  8017dd:	68 10 26 80 00       	push   $0x802610
  8017e2:	68 a3 00 00 00       	push   $0xa3
  8017e7:	68 25 26 80 00       	push   $0x802625
  8017ec:	e8 67 e9 ff ff       	call   800158 <_panic>
	return r;
}
  8017f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017f4:	c9                   	leave  
  8017f5:	c3                   	ret    

008017f6 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017f6:	55                   	push   %ebp
  8017f7:	89 e5                	mov    %esp,%ebp
  8017f9:	56                   	push   %esi
  8017fa:	53                   	push   %ebx
  8017fb:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801801:	8b 40 0c             	mov    0xc(%eax),%eax
  801804:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801809:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80180f:	ba 00 00 00 00       	mov    $0x0,%edx
  801814:	b8 03 00 00 00       	mov    $0x3,%eax
  801819:	e8 79 fe ff ff       	call   801697 <fsipc>
  80181e:	89 c3                	mov    %eax,%ebx
  801820:	85 c0                	test   %eax,%eax
  801822:	78 4b                	js     80186f <devfile_read+0x79>
		return r;
	assert(r <= n);
  801824:	39 c6                	cmp    %eax,%esi
  801826:	73 16                	jae    80183e <devfile_read+0x48>
  801828:	68 30 26 80 00       	push   $0x802630
  80182d:	68 10 26 80 00       	push   $0x802610
  801832:	6a 7c                	push   $0x7c
  801834:	68 25 26 80 00       	push   $0x802625
  801839:	e8 1a e9 ff ff       	call   800158 <_panic>
	assert(r <= PGSIZE);
  80183e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801843:	7e 16                	jle    80185b <devfile_read+0x65>
  801845:	68 37 26 80 00       	push   $0x802637
  80184a:	68 10 26 80 00       	push   $0x802610
  80184f:	6a 7d                	push   $0x7d
  801851:	68 25 26 80 00       	push   $0x802625
  801856:	e8 fd e8 ff ff       	call   800158 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80185b:	83 ec 04             	sub    $0x4,%esp
  80185e:	50                   	push   %eax
  80185f:	68 00 50 80 00       	push   $0x805000
  801864:	ff 75 0c             	pushl  0xc(%ebp)
  801867:	e8 dc f0 ff ff       	call   800948 <memmove>
	return r;
  80186c:	83 c4 10             	add    $0x10,%esp
}
  80186f:	89 d8                	mov    %ebx,%eax
  801871:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801874:	5b                   	pop    %ebx
  801875:	5e                   	pop    %esi
  801876:	5d                   	pop    %ebp
  801877:	c3                   	ret    

00801878 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801878:	55                   	push   %ebp
  801879:	89 e5                	mov    %esp,%ebp
  80187b:	53                   	push   %ebx
  80187c:	83 ec 20             	sub    $0x20,%esp
  80187f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801882:	53                   	push   %ebx
  801883:	e8 f5 ee ff ff       	call   80077d <strlen>
  801888:	83 c4 10             	add    $0x10,%esp
  80188b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801890:	7f 67                	jg     8018f9 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801892:	83 ec 0c             	sub    $0xc,%esp
  801895:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801898:	50                   	push   %eax
  801899:	e8 71 f8 ff ff       	call   80110f <fd_alloc>
  80189e:	83 c4 10             	add    $0x10,%esp
		return r;
  8018a1:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018a3:	85 c0                	test   %eax,%eax
  8018a5:	78 57                	js     8018fe <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018a7:	83 ec 08             	sub    $0x8,%esp
  8018aa:	53                   	push   %ebx
  8018ab:	68 00 50 80 00       	push   $0x805000
  8018b0:	e8 01 ef ff ff       	call   8007b6 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018b5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018b8:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018bd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018c0:	b8 01 00 00 00       	mov    $0x1,%eax
  8018c5:	e8 cd fd ff ff       	call   801697 <fsipc>
  8018ca:	89 c3                	mov    %eax,%ebx
  8018cc:	83 c4 10             	add    $0x10,%esp
  8018cf:	85 c0                	test   %eax,%eax
  8018d1:	79 14                	jns    8018e7 <open+0x6f>
		fd_close(fd, 0);
  8018d3:	83 ec 08             	sub    $0x8,%esp
  8018d6:	6a 00                	push   $0x0
  8018d8:	ff 75 f4             	pushl  -0xc(%ebp)
  8018db:	e8 27 f9 ff ff       	call   801207 <fd_close>
		return r;
  8018e0:	83 c4 10             	add    $0x10,%esp
  8018e3:	89 da                	mov    %ebx,%edx
  8018e5:	eb 17                	jmp    8018fe <open+0x86>
	}

	return fd2num(fd);
  8018e7:	83 ec 0c             	sub    $0xc,%esp
  8018ea:	ff 75 f4             	pushl  -0xc(%ebp)
  8018ed:	e8 f6 f7 ff ff       	call   8010e8 <fd2num>
  8018f2:	89 c2                	mov    %eax,%edx
  8018f4:	83 c4 10             	add    $0x10,%esp
  8018f7:	eb 05                	jmp    8018fe <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8018f9:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8018fe:	89 d0                	mov    %edx,%eax
  801900:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801903:	c9                   	leave  
  801904:	c3                   	ret    

00801905 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801905:	55                   	push   %ebp
  801906:	89 e5                	mov    %esp,%ebp
  801908:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80190b:	ba 00 00 00 00       	mov    $0x0,%edx
  801910:	b8 08 00 00 00       	mov    $0x8,%eax
  801915:	e8 7d fd ff ff       	call   801697 <fsipc>
}
  80191a:	c9                   	leave  
  80191b:	c3                   	ret    

0080191c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80191c:	55                   	push   %ebp
  80191d:	89 e5                	mov    %esp,%ebp
  80191f:	56                   	push   %esi
  801920:	53                   	push   %ebx
  801921:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801924:	83 ec 0c             	sub    $0xc,%esp
  801927:	ff 75 08             	pushl  0x8(%ebp)
  80192a:	e8 c9 f7 ff ff       	call   8010f8 <fd2data>
  80192f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801931:	83 c4 08             	add    $0x8,%esp
  801934:	68 43 26 80 00       	push   $0x802643
  801939:	53                   	push   %ebx
  80193a:	e8 77 ee ff ff       	call   8007b6 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80193f:	8b 46 04             	mov    0x4(%esi),%eax
  801942:	2b 06                	sub    (%esi),%eax
  801944:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80194a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801951:	00 00 00 
	stat->st_dev = &devpipe;
  801954:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80195b:	30 80 00 
	return 0;
}
  80195e:	b8 00 00 00 00       	mov    $0x0,%eax
  801963:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801966:	5b                   	pop    %ebx
  801967:	5e                   	pop    %esi
  801968:	5d                   	pop    %ebp
  801969:	c3                   	ret    

0080196a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80196a:	55                   	push   %ebp
  80196b:	89 e5                	mov    %esp,%ebp
  80196d:	53                   	push   %ebx
  80196e:	83 ec 0c             	sub    $0xc,%esp
  801971:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801974:	53                   	push   %ebx
  801975:	6a 00                	push   $0x0
  801977:	e8 c2 f2 ff ff       	call   800c3e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80197c:	89 1c 24             	mov    %ebx,(%esp)
  80197f:	e8 74 f7 ff ff       	call   8010f8 <fd2data>
  801984:	83 c4 08             	add    $0x8,%esp
  801987:	50                   	push   %eax
  801988:	6a 00                	push   $0x0
  80198a:	e8 af f2 ff ff       	call   800c3e <sys_page_unmap>
}
  80198f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801992:	c9                   	leave  
  801993:	c3                   	ret    

00801994 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801994:	55                   	push   %ebp
  801995:	89 e5                	mov    %esp,%ebp
  801997:	57                   	push   %edi
  801998:	56                   	push   %esi
  801999:	53                   	push   %ebx
  80199a:	83 ec 1c             	sub    $0x1c,%esp
  80199d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8019a0:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8019a2:	a1 04 40 80 00       	mov    0x804004,%eax
  8019a7:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8019aa:	83 ec 0c             	sub    $0xc,%esp
  8019ad:	ff 75 e0             	pushl  -0x20(%ebp)
  8019b0:	e8 bc 04 00 00       	call   801e71 <pageref>
  8019b5:	89 c3                	mov    %eax,%ebx
  8019b7:	89 3c 24             	mov    %edi,(%esp)
  8019ba:	e8 b2 04 00 00       	call   801e71 <pageref>
  8019bf:	83 c4 10             	add    $0x10,%esp
  8019c2:	39 c3                	cmp    %eax,%ebx
  8019c4:	0f 94 c1             	sete   %cl
  8019c7:	0f b6 c9             	movzbl %cl,%ecx
  8019ca:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8019cd:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8019d3:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8019d6:	39 ce                	cmp    %ecx,%esi
  8019d8:	74 1b                	je     8019f5 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8019da:	39 c3                	cmp    %eax,%ebx
  8019dc:	75 c4                	jne    8019a2 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8019de:	8b 42 58             	mov    0x58(%edx),%eax
  8019e1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8019e4:	50                   	push   %eax
  8019e5:	56                   	push   %esi
  8019e6:	68 4a 26 80 00       	push   $0x80264a
  8019eb:	e8 41 e8 ff ff       	call   800231 <cprintf>
  8019f0:	83 c4 10             	add    $0x10,%esp
  8019f3:	eb ad                	jmp    8019a2 <_pipeisclosed+0xe>
	}
}
  8019f5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019fb:	5b                   	pop    %ebx
  8019fc:	5e                   	pop    %esi
  8019fd:	5f                   	pop    %edi
  8019fe:	5d                   	pop    %ebp
  8019ff:	c3                   	ret    

00801a00 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a00:	55                   	push   %ebp
  801a01:	89 e5                	mov    %esp,%ebp
  801a03:	57                   	push   %edi
  801a04:	56                   	push   %esi
  801a05:	53                   	push   %ebx
  801a06:	83 ec 28             	sub    $0x28,%esp
  801a09:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a0c:	56                   	push   %esi
  801a0d:	e8 e6 f6 ff ff       	call   8010f8 <fd2data>
  801a12:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a14:	83 c4 10             	add    $0x10,%esp
  801a17:	bf 00 00 00 00       	mov    $0x0,%edi
  801a1c:	eb 4b                	jmp    801a69 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a1e:	89 da                	mov    %ebx,%edx
  801a20:	89 f0                	mov    %esi,%eax
  801a22:	e8 6d ff ff ff       	call   801994 <_pipeisclosed>
  801a27:	85 c0                	test   %eax,%eax
  801a29:	75 48                	jne    801a73 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a2b:	e8 6a f1 ff ff       	call   800b9a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a30:	8b 43 04             	mov    0x4(%ebx),%eax
  801a33:	8b 0b                	mov    (%ebx),%ecx
  801a35:	8d 51 20             	lea    0x20(%ecx),%edx
  801a38:	39 d0                	cmp    %edx,%eax
  801a3a:	73 e2                	jae    801a1e <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a3f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a43:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a46:	89 c2                	mov    %eax,%edx
  801a48:	c1 fa 1f             	sar    $0x1f,%edx
  801a4b:	89 d1                	mov    %edx,%ecx
  801a4d:	c1 e9 1b             	shr    $0x1b,%ecx
  801a50:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801a53:	83 e2 1f             	and    $0x1f,%edx
  801a56:	29 ca                	sub    %ecx,%edx
  801a58:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801a5c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a60:	83 c0 01             	add    $0x1,%eax
  801a63:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a66:	83 c7 01             	add    $0x1,%edi
  801a69:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a6c:	75 c2                	jne    801a30 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a6e:	8b 45 10             	mov    0x10(%ebp),%eax
  801a71:	eb 05                	jmp    801a78 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a73:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801a78:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a7b:	5b                   	pop    %ebx
  801a7c:	5e                   	pop    %esi
  801a7d:	5f                   	pop    %edi
  801a7e:	5d                   	pop    %ebp
  801a7f:	c3                   	ret    

00801a80 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a80:	55                   	push   %ebp
  801a81:	89 e5                	mov    %esp,%ebp
  801a83:	57                   	push   %edi
  801a84:	56                   	push   %esi
  801a85:	53                   	push   %ebx
  801a86:	83 ec 18             	sub    $0x18,%esp
  801a89:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a8c:	57                   	push   %edi
  801a8d:	e8 66 f6 ff ff       	call   8010f8 <fd2data>
  801a92:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a94:	83 c4 10             	add    $0x10,%esp
  801a97:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a9c:	eb 3d                	jmp    801adb <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801a9e:	85 db                	test   %ebx,%ebx
  801aa0:	74 04                	je     801aa6 <devpipe_read+0x26>
				return i;
  801aa2:	89 d8                	mov    %ebx,%eax
  801aa4:	eb 44                	jmp    801aea <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801aa6:	89 f2                	mov    %esi,%edx
  801aa8:	89 f8                	mov    %edi,%eax
  801aaa:	e8 e5 fe ff ff       	call   801994 <_pipeisclosed>
  801aaf:	85 c0                	test   %eax,%eax
  801ab1:	75 32                	jne    801ae5 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801ab3:	e8 e2 f0 ff ff       	call   800b9a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ab8:	8b 06                	mov    (%esi),%eax
  801aba:	3b 46 04             	cmp    0x4(%esi),%eax
  801abd:	74 df                	je     801a9e <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801abf:	99                   	cltd   
  801ac0:	c1 ea 1b             	shr    $0x1b,%edx
  801ac3:	01 d0                	add    %edx,%eax
  801ac5:	83 e0 1f             	and    $0x1f,%eax
  801ac8:	29 d0                	sub    %edx,%eax
  801aca:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801acf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ad2:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801ad5:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ad8:	83 c3 01             	add    $0x1,%ebx
  801adb:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801ade:	75 d8                	jne    801ab8 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801ae0:	8b 45 10             	mov    0x10(%ebp),%eax
  801ae3:	eb 05                	jmp    801aea <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ae5:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801aea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aed:	5b                   	pop    %ebx
  801aee:	5e                   	pop    %esi
  801aef:	5f                   	pop    %edi
  801af0:	5d                   	pop    %ebp
  801af1:	c3                   	ret    

00801af2 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801af2:	55                   	push   %ebp
  801af3:	89 e5                	mov    %esp,%ebp
  801af5:	56                   	push   %esi
  801af6:	53                   	push   %ebx
  801af7:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801afa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801afd:	50                   	push   %eax
  801afe:	e8 0c f6 ff ff       	call   80110f <fd_alloc>
  801b03:	83 c4 10             	add    $0x10,%esp
  801b06:	89 c2                	mov    %eax,%edx
  801b08:	85 c0                	test   %eax,%eax
  801b0a:	0f 88 2c 01 00 00    	js     801c3c <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b10:	83 ec 04             	sub    $0x4,%esp
  801b13:	68 07 04 00 00       	push   $0x407
  801b18:	ff 75 f4             	pushl  -0xc(%ebp)
  801b1b:	6a 00                	push   $0x0
  801b1d:	e8 97 f0 ff ff       	call   800bb9 <sys_page_alloc>
  801b22:	83 c4 10             	add    $0x10,%esp
  801b25:	89 c2                	mov    %eax,%edx
  801b27:	85 c0                	test   %eax,%eax
  801b29:	0f 88 0d 01 00 00    	js     801c3c <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b2f:	83 ec 0c             	sub    $0xc,%esp
  801b32:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b35:	50                   	push   %eax
  801b36:	e8 d4 f5 ff ff       	call   80110f <fd_alloc>
  801b3b:	89 c3                	mov    %eax,%ebx
  801b3d:	83 c4 10             	add    $0x10,%esp
  801b40:	85 c0                	test   %eax,%eax
  801b42:	0f 88 e2 00 00 00    	js     801c2a <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b48:	83 ec 04             	sub    $0x4,%esp
  801b4b:	68 07 04 00 00       	push   $0x407
  801b50:	ff 75 f0             	pushl  -0x10(%ebp)
  801b53:	6a 00                	push   $0x0
  801b55:	e8 5f f0 ff ff       	call   800bb9 <sys_page_alloc>
  801b5a:	89 c3                	mov    %eax,%ebx
  801b5c:	83 c4 10             	add    $0x10,%esp
  801b5f:	85 c0                	test   %eax,%eax
  801b61:	0f 88 c3 00 00 00    	js     801c2a <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b67:	83 ec 0c             	sub    $0xc,%esp
  801b6a:	ff 75 f4             	pushl  -0xc(%ebp)
  801b6d:	e8 86 f5 ff ff       	call   8010f8 <fd2data>
  801b72:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b74:	83 c4 0c             	add    $0xc,%esp
  801b77:	68 07 04 00 00       	push   $0x407
  801b7c:	50                   	push   %eax
  801b7d:	6a 00                	push   $0x0
  801b7f:	e8 35 f0 ff ff       	call   800bb9 <sys_page_alloc>
  801b84:	89 c3                	mov    %eax,%ebx
  801b86:	83 c4 10             	add    $0x10,%esp
  801b89:	85 c0                	test   %eax,%eax
  801b8b:	0f 88 89 00 00 00    	js     801c1a <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b91:	83 ec 0c             	sub    $0xc,%esp
  801b94:	ff 75 f0             	pushl  -0x10(%ebp)
  801b97:	e8 5c f5 ff ff       	call   8010f8 <fd2data>
  801b9c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ba3:	50                   	push   %eax
  801ba4:	6a 00                	push   $0x0
  801ba6:	56                   	push   %esi
  801ba7:	6a 00                	push   $0x0
  801ba9:	e8 4e f0 ff ff       	call   800bfc <sys_page_map>
  801bae:	89 c3                	mov    %eax,%ebx
  801bb0:	83 c4 20             	add    $0x20,%esp
  801bb3:	85 c0                	test   %eax,%eax
  801bb5:	78 55                	js     801c0c <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801bb7:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bc0:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801bc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bc5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801bcc:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bd2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bd5:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801bd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bda:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801be1:	83 ec 0c             	sub    $0xc,%esp
  801be4:	ff 75 f4             	pushl  -0xc(%ebp)
  801be7:	e8 fc f4 ff ff       	call   8010e8 <fd2num>
  801bec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bef:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801bf1:	83 c4 04             	add    $0x4,%esp
  801bf4:	ff 75 f0             	pushl  -0x10(%ebp)
  801bf7:	e8 ec f4 ff ff       	call   8010e8 <fd2num>
  801bfc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bff:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c02:	83 c4 10             	add    $0x10,%esp
  801c05:	ba 00 00 00 00       	mov    $0x0,%edx
  801c0a:	eb 30                	jmp    801c3c <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c0c:	83 ec 08             	sub    $0x8,%esp
  801c0f:	56                   	push   %esi
  801c10:	6a 00                	push   $0x0
  801c12:	e8 27 f0 ff ff       	call   800c3e <sys_page_unmap>
  801c17:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c1a:	83 ec 08             	sub    $0x8,%esp
  801c1d:	ff 75 f0             	pushl  -0x10(%ebp)
  801c20:	6a 00                	push   $0x0
  801c22:	e8 17 f0 ff ff       	call   800c3e <sys_page_unmap>
  801c27:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c2a:	83 ec 08             	sub    $0x8,%esp
  801c2d:	ff 75 f4             	pushl  -0xc(%ebp)
  801c30:	6a 00                	push   $0x0
  801c32:	e8 07 f0 ff ff       	call   800c3e <sys_page_unmap>
  801c37:	83 c4 10             	add    $0x10,%esp
  801c3a:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801c3c:	89 d0                	mov    %edx,%eax
  801c3e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c41:	5b                   	pop    %ebx
  801c42:	5e                   	pop    %esi
  801c43:	5d                   	pop    %ebp
  801c44:	c3                   	ret    

00801c45 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c45:	55                   	push   %ebp
  801c46:	89 e5                	mov    %esp,%ebp
  801c48:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c4b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c4e:	50                   	push   %eax
  801c4f:	ff 75 08             	pushl  0x8(%ebp)
  801c52:	e8 07 f5 ff ff       	call   80115e <fd_lookup>
  801c57:	83 c4 10             	add    $0x10,%esp
  801c5a:	85 c0                	test   %eax,%eax
  801c5c:	78 18                	js     801c76 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c5e:	83 ec 0c             	sub    $0xc,%esp
  801c61:	ff 75 f4             	pushl  -0xc(%ebp)
  801c64:	e8 8f f4 ff ff       	call   8010f8 <fd2data>
	return _pipeisclosed(fd, p);
  801c69:	89 c2                	mov    %eax,%edx
  801c6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c6e:	e8 21 fd ff ff       	call   801994 <_pipeisclosed>
  801c73:	83 c4 10             	add    $0x10,%esp
}
  801c76:	c9                   	leave  
  801c77:	c3                   	ret    

00801c78 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c78:	55                   	push   %ebp
  801c79:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801c7b:	b8 00 00 00 00       	mov    $0x0,%eax
  801c80:	5d                   	pop    %ebp
  801c81:	c3                   	ret    

00801c82 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c82:	55                   	push   %ebp
  801c83:	89 e5                	mov    %esp,%ebp
  801c85:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801c88:	68 62 26 80 00       	push   $0x802662
  801c8d:	ff 75 0c             	pushl  0xc(%ebp)
  801c90:	e8 21 eb ff ff       	call   8007b6 <strcpy>
	return 0;
}
  801c95:	b8 00 00 00 00       	mov    $0x0,%eax
  801c9a:	c9                   	leave  
  801c9b:	c3                   	ret    

00801c9c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c9c:	55                   	push   %ebp
  801c9d:	89 e5                	mov    %esp,%ebp
  801c9f:	57                   	push   %edi
  801ca0:	56                   	push   %esi
  801ca1:	53                   	push   %ebx
  801ca2:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ca8:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801cad:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cb3:	eb 2d                	jmp    801ce2 <devcons_write+0x46>
		m = n - tot;
  801cb5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801cb8:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801cba:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801cbd:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801cc2:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801cc5:	83 ec 04             	sub    $0x4,%esp
  801cc8:	53                   	push   %ebx
  801cc9:	03 45 0c             	add    0xc(%ebp),%eax
  801ccc:	50                   	push   %eax
  801ccd:	57                   	push   %edi
  801cce:	e8 75 ec ff ff       	call   800948 <memmove>
		sys_cputs(buf, m);
  801cd3:	83 c4 08             	add    $0x8,%esp
  801cd6:	53                   	push   %ebx
  801cd7:	57                   	push   %edi
  801cd8:	e8 20 ee ff ff       	call   800afd <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cdd:	01 de                	add    %ebx,%esi
  801cdf:	83 c4 10             	add    $0x10,%esp
  801ce2:	89 f0                	mov    %esi,%eax
  801ce4:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ce7:	72 cc                	jb     801cb5 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ce9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cec:	5b                   	pop    %ebx
  801ced:	5e                   	pop    %esi
  801cee:	5f                   	pop    %edi
  801cef:	5d                   	pop    %ebp
  801cf0:	c3                   	ret    

00801cf1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801cf1:	55                   	push   %ebp
  801cf2:	89 e5                	mov    %esp,%ebp
  801cf4:	83 ec 08             	sub    $0x8,%esp
  801cf7:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801cfc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d00:	74 2a                	je     801d2c <devcons_read+0x3b>
  801d02:	eb 05                	jmp    801d09 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d04:	e8 91 ee ff ff       	call   800b9a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d09:	e8 0d ee ff ff       	call   800b1b <sys_cgetc>
  801d0e:	85 c0                	test   %eax,%eax
  801d10:	74 f2                	je     801d04 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801d12:	85 c0                	test   %eax,%eax
  801d14:	78 16                	js     801d2c <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d16:	83 f8 04             	cmp    $0x4,%eax
  801d19:	74 0c                	je     801d27 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801d1b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d1e:	88 02                	mov    %al,(%edx)
	return 1;
  801d20:	b8 01 00 00 00       	mov    $0x1,%eax
  801d25:	eb 05                	jmp    801d2c <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801d27:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801d2c:	c9                   	leave  
  801d2d:	c3                   	ret    

00801d2e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801d2e:	55                   	push   %ebp
  801d2f:	89 e5                	mov    %esp,%ebp
  801d31:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801d34:	8b 45 08             	mov    0x8(%ebp),%eax
  801d37:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801d3a:	6a 01                	push   $0x1
  801d3c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d3f:	50                   	push   %eax
  801d40:	e8 b8 ed ff ff       	call   800afd <sys_cputs>
}
  801d45:	83 c4 10             	add    $0x10,%esp
  801d48:	c9                   	leave  
  801d49:	c3                   	ret    

00801d4a <getchar>:

int
getchar(void)
{
  801d4a:	55                   	push   %ebp
  801d4b:	89 e5                	mov    %esp,%ebp
  801d4d:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801d50:	6a 01                	push   $0x1
  801d52:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d55:	50                   	push   %eax
  801d56:	6a 00                	push   $0x0
  801d58:	e8 67 f6 ff ff       	call   8013c4 <read>
	if (r < 0)
  801d5d:	83 c4 10             	add    $0x10,%esp
  801d60:	85 c0                	test   %eax,%eax
  801d62:	78 0f                	js     801d73 <getchar+0x29>
		return r;
	if (r < 1)
  801d64:	85 c0                	test   %eax,%eax
  801d66:	7e 06                	jle    801d6e <getchar+0x24>
		return -E_EOF;
	return c;
  801d68:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801d6c:	eb 05                	jmp    801d73 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801d6e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801d73:	c9                   	leave  
  801d74:	c3                   	ret    

00801d75 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801d75:	55                   	push   %ebp
  801d76:	89 e5                	mov    %esp,%ebp
  801d78:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d7b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d7e:	50                   	push   %eax
  801d7f:	ff 75 08             	pushl  0x8(%ebp)
  801d82:	e8 d7 f3 ff ff       	call   80115e <fd_lookup>
  801d87:	83 c4 10             	add    $0x10,%esp
  801d8a:	85 c0                	test   %eax,%eax
  801d8c:	78 11                	js     801d9f <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801d8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d91:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d97:	39 10                	cmp    %edx,(%eax)
  801d99:	0f 94 c0             	sete   %al
  801d9c:	0f b6 c0             	movzbl %al,%eax
}
  801d9f:	c9                   	leave  
  801da0:	c3                   	ret    

00801da1 <opencons>:

int
opencons(void)
{
  801da1:	55                   	push   %ebp
  801da2:	89 e5                	mov    %esp,%ebp
  801da4:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801da7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801daa:	50                   	push   %eax
  801dab:	e8 5f f3 ff ff       	call   80110f <fd_alloc>
  801db0:	83 c4 10             	add    $0x10,%esp
		return r;
  801db3:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801db5:	85 c0                	test   %eax,%eax
  801db7:	78 3e                	js     801df7 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801db9:	83 ec 04             	sub    $0x4,%esp
  801dbc:	68 07 04 00 00       	push   $0x407
  801dc1:	ff 75 f4             	pushl  -0xc(%ebp)
  801dc4:	6a 00                	push   $0x0
  801dc6:	e8 ee ed ff ff       	call   800bb9 <sys_page_alloc>
  801dcb:	83 c4 10             	add    $0x10,%esp
		return r;
  801dce:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801dd0:	85 c0                	test   %eax,%eax
  801dd2:	78 23                	js     801df7 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801dd4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801dda:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ddd:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ddf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801de2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801de9:	83 ec 0c             	sub    $0xc,%esp
  801dec:	50                   	push   %eax
  801ded:	e8 f6 f2 ff ff       	call   8010e8 <fd2num>
  801df2:	89 c2                	mov    %eax,%edx
  801df4:	83 c4 10             	add    $0x10,%esp
}
  801df7:	89 d0                	mov    %edx,%eax
  801df9:	c9                   	leave  
  801dfa:	c3                   	ret    

00801dfb <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801dfb:	55                   	push   %ebp
  801dfc:	89 e5                	mov    %esp,%ebp
  801dfe:	53                   	push   %ebx
  801dff:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  801e02:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801e09:	75 28                	jne    801e33 <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  801e0b:	e8 6b ed ff ff       	call   800b7b <sys_getenvid>
  801e10:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_U | PTE_W);
  801e12:	83 ec 04             	sub    $0x4,%esp
  801e15:	6a 06                	push   $0x6
  801e17:	68 00 f0 bf ee       	push   $0xeebff000
  801e1c:	50                   	push   %eax
  801e1d:	e8 97 ed ff ff       	call   800bb9 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  801e22:	83 c4 08             	add    $0x8,%esp
  801e25:	68 40 1e 80 00       	push   $0x801e40
  801e2a:	53                   	push   %ebx
  801e2b:	e8 d4 ee ff ff       	call   800d04 <sys_env_set_pgfault_upcall>
  801e30:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801e33:	8b 45 08             	mov    0x8(%ebp),%eax
  801e36:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801e3b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e3e:	c9                   	leave  
  801e3f:	c3                   	ret    

00801e40 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e40:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e41:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e46:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e48:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	# My method is different. Copy the values to the other stack
	# in a convinient way, and then pop everything.
	movl %esp, %ebp		# ebp refers to the exception stack
  801e4b:	89 e5                	mov    %esp,%ebp
	movl 48(%ebp), %esp 	# go to other stack
  801e4d:	8b 65 30             	mov    0x30(%ebp),%esp

	pushl 40(%ebp)		# eip - ORDER SWITCHED WITH EFLAGS
  801e50:	ff 75 28             	pushl  0x28(%ebp)
	pushl 44(%ebp)      	# eflags
  801e53:	ff 75 2c             	pushl  0x2c(%ebp)
	pushl 36(%ebp)		# all the 8 remaining regs
  801e56:	ff 75 24             	pushl  0x24(%ebp)
	pushl 32(%ebp)
  801e59:	ff 75 20             	pushl  0x20(%ebp)
	pushl 28(%ebp)
  801e5c:	ff 75 1c             	pushl  0x1c(%ebp)
	pushl 24(%ebp)
  801e5f:	ff 75 18             	pushl  0x18(%ebp)
	pushl 20(%ebp)
  801e62:	ff 75 14             	pushl  0x14(%ebp)
	pushl 16(%ebp)
  801e65:	ff 75 10             	pushl  0x10(%ebp)
	pushl 12(%ebp)
  801e68:	ff 75 0c             	pushl  0xc(%ebp)
	pushl 8(%ebp)
  801e6b:	ff 75 08             	pushl  0x8(%ebp)

	popal			# now just pop everything!
  801e6e:	61                   	popa   
	popfl
  801e6f:	9d                   	popf   
	ret
  801e70:	c3                   	ret    

00801e71 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801e71:	55                   	push   %ebp
  801e72:	89 e5                	mov    %esp,%ebp
  801e74:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e77:	89 d0                	mov    %edx,%eax
  801e79:	c1 e8 16             	shr    $0x16,%eax
  801e7c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801e83:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e88:	f6 c1 01             	test   $0x1,%cl
  801e8b:	74 1d                	je     801eaa <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801e8d:	c1 ea 0c             	shr    $0xc,%edx
  801e90:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801e97:	f6 c2 01             	test   $0x1,%dl
  801e9a:	74 0e                	je     801eaa <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801e9c:	c1 ea 0c             	shr    $0xc,%edx
  801e9f:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801ea6:	ef 
  801ea7:	0f b7 c0             	movzwl %ax,%eax
}
  801eaa:	5d                   	pop    %ebp
  801eab:	c3                   	ret    
  801eac:	66 90                	xchg   %ax,%ax
  801eae:	66 90                	xchg   %ax,%ax

00801eb0 <__udivdi3>:
  801eb0:	55                   	push   %ebp
  801eb1:	57                   	push   %edi
  801eb2:	56                   	push   %esi
  801eb3:	53                   	push   %ebx
  801eb4:	83 ec 1c             	sub    $0x1c,%esp
  801eb7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801ebb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801ebf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801ec3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ec7:	85 f6                	test   %esi,%esi
  801ec9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ecd:	89 ca                	mov    %ecx,%edx
  801ecf:	89 f8                	mov    %edi,%eax
  801ed1:	75 3d                	jne    801f10 <__udivdi3+0x60>
  801ed3:	39 cf                	cmp    %ecx,%edi
  801ed5:	0f 87 c5 00 00 00    	ja     801fa0 <__udivdi3+0xf0>
  801edb:	85 ff                	test   %edi,%edi
  801edd:	89 fd                	mov    %edi,%ebp
  801edf:	75 0b                	jne    801eec <__udivdi3+0x3c>
  801ee1:	b8 01 00 00 00       	mov    $0x1,%eax
  801ee6:	31 d2                	xor    %edx,%edx
  801ee8:	f7 f7                	div    %edi
  801eea:	89 c5                	mov    %eax,%ebp
  801eec:	89 c8                	mov    %ecx,%eax
  801eee:	31 d2                	xor    %edx,%edx
  801ef0:	f7 f5                	div    %ebp
  801ef2:	89 c1                	mov    %eax,%ecx
  801ef4:	89 d8                	mov    %ebx,%eax
  801ef6:	89 cf                	mov    %ecx,%edi
  801ef8:	f7 f5                	div    %ebp
  801efa:	89 c3                	mov    %eax,%ebx
  801efc:	89 d8                	mov    %ebx,%eax
  801efe:	89 fa                	mov    %edi,%edx
  801f00:	83 c4 1c             	add    $0x1c,%esp
  801f03:	5b                   	pop    %ebx
  801f04:	5e                   	pop    %esi
  801f05:	5f                   	pop    %edi
  801f06:	5d                   	pop    %ebp
  801f07:	c3                   	ret    
  801f08:	90                   	nop
  801f09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f10:	39 ce                	cmp    %ecx,%esi
  801f12:	77 74                	ja     801f88 <__udivdi3+0xd8>
  801f14:	0f bd fe             	bsr    %esi,%edi
  801f17:	83 f7 1f             	xor    $0x1f,%edi
  801f1a:	0f 84 98 00 00 00    	je     801fb8 <__udivdi3+0x108>
  801f20:	bb 20 00 00 00       	mov    $0x20,%ebx
  801f25:	89 f9                	mov    %edi,%ecx
  801f27:	89 c5                	mov    %eax,%ebp
  801f29:	29 fb                	sub    %edi,%ebx
  801f2b:	d3 e6                	shl    %cl,%esi
  801f2d:	89 d9                	mov    %ebx,%ecx
  801f2f:	d3 ed                	shr    %cl,%ebp
  801f31:	89 f9                	mov    %edi,%ecx
  801f33:	d3 e0                	shl    %cl,%eax
  801f35:	09 ee                	or     %ebp,%esi
  801f37:	89 d9                	mov    %ebx,%ecx
  801f39:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f3d:	89 d5                	mov    %edx,%ebp
  801f3f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801f43:	d3 ed                	shr    %cl,%ebp
  801f45:	89 f9                	mov    %edi,%ecx
  801f47:	d3 e2                	shl    %cl,%edx
  801f49:	89 d9                	mov    %ebx,%ecx
  801f4b:	d3 e8                	shr    %cl,%eax
  801f4d:	09 c2                	or     %eax,%edx
  801f4f:	89 d0                	mov    %edx,%eax
  801f51:	89 ea                	mov    %ebp,%edx
  801f53:	f7 f6                	div    %esi
  801f55:	89 d5                	mov    %edx,%ebp
  801f57:	89 c3                	mov    %eax,%ebx
  801f59:	f7 64 24 0c          	mull   0xc(%esp)
  801f5d:	39 d5                	cmp    %edx,%ebp
  801f5f:	72 10                	jb     801f71 <__udivdi3+0xc1>
  801f61:	8b 74 24 08          	mov    0x8(%esp),%esi
  801f65:	89 f9                	mov    %edi,%ecx
  801f67:	d3 e6                	shl    %cl,%esi
  801f69:	39 c6                	cmp    %eax,%esi
  801f6b:	73 07                	jae    801f74 <__udivdi3+0xc4>
  801f6d:	39 d5                	cmp    %edx,%ebp
  801f6f:	75 03                	jne    801f74 <__udivdi3+0xc4>
  801f71:	83 eb 01             	sub    $0x1,%ebx
  801f74:	31 ff                	xor    %edi,%edi
  801f76:	89 d8                	mov    %ebx,%eax
  801f78:	89 fa                	mov    %edi,%edx
  801f7a:	83 c4 1c             	add    $0x1c,%esp
  801f7d:	5b                   	pop    %ebx
  801f7e:	5e                   	pop    %esi
  801f7f:	5f                   	pop    %edi
  801f80:	5d                   	pop    %ebp
  801f81:	c3                   	ret    
  801f82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801f88:	31 ff                	xor    %edi,%edi
  801f8a:	31 db                	xor    %ebx,%ebx
  801f8c:	89 d8                	mov    %ebx,%eax
  801f8e:	89 fa                	mov    %edi,%edx
  801f90:	83 c4 1c             	add    $0x1c,%esp
  801f93:	5b                   	pop    %ebx
  801f94:	5e                   	pop    %esi
  801f95:	5f                   	pop    %edi
  801f96:	5d                   	pop    %ebp
  801f97:	c3                   	ret    
  801f98:	90                   	nop
  801f99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fa0:	89 d8                	mov    %ebx,%eax
  801fa2:	f7 f7                	div    %edi
  801fa4:	31 ff                	xor    %edi,%edi
  801fa6:	89 c3                	mov    %eax,%ebx
  801fa8:	89 d8                	mov    %ebx,%eax
  801faa:	89 fa                	mov    %edi,%edx
  801fac:	83 c4 1c             	add    $0x1c,%esp
  801faf:	5b                   	pop    %ebx
  801fb0:	5e                   	pop    %esi
  801fb1:	5f                   	pop    %edi
  801fb2:	5d                   	pop    %ebp
  801fb3:	c3                   	ret    
  801fb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801fb8:	39 ce                	cmp    %ecx,%esi
  801fba:	72 0c                	jb     801fc8 <__udivdi3+0x118>
  801fbc:	31 db                	xor    %ebx,%ebx
  801fbe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801fc2:	0f 87 34 ff ff ff    	ja     801efc <__udivdi3+0x4c>
  801fc8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801fcd:	e9 2a ff ff ff       	jmp    801efc <__udivdi3+0x4c>
  801fd2:	66 90                	xchg   %ax,%ax
  801fd4:	66 90                	xchg   %ax,%ax
  801fd6:	66 90                	xchg   %ax,%ax
  801fd8:	66 90                	xchg   %ax,%ax
  801fda:	66 90                	xchg   %ax,%ax
  801fdc:	66 90                	xchg   %ax,%ax
  801fde:	66 90                	xchg   %ax,%ax

00801fe0 <__umoddi3>:
  801fe0:	55                   	push   %ebp
  801fe1:	57                   	push   %edi
  801fe2:	56                   	push   %esi
  801fe3:	53                   	push   %ebx
  801fe4:	83 ec 1c             	sub    $0x1c,%esp
  801fe7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801feb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801fef:	8b 74 24 34          	mov    0x34(%esp),%esi
  801ff3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ff7:	85 d2                	test   %edx,%edx
  801ff9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801ffd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802001:	89 f3                	mov    %esi,%ebx
  802003:	89 3c 24             	mov    %edi,(%esp)
  802006:	89 74 24 04          	mov    %esi,0x4(%esp)
  80200a:	75 1c                	jne    802028 <__umoddi3+0x48>
  80200c:	39 f7                	cmp    %esi,%edi
  80200e:	76 50                	jbe    802060 <__umoddi3+0x80>
  802010:	89 c8                	mov    %ecx,%eax
  802012:	89 f2                	mov    %esi,%edx
  802014:	f7 f7                	div    %edi
  802016:	89 d0                	mov    %edx,%eax
  802018:	31 d2                	xor    %edx,%edx
  80201a:	83 c4 1c             	add    $0x1c,%esp
  80201d:	5b                   	pop    %ebx
  80201e:	5e                   	pop    %esi
  80201f:	5f                   	pop    %edi
  802020:	5d                   	pop    %ebp
  802021:	c3                   	ret    
  802022:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802028:	39 f2                	cmp    %esi,%edx
  80202a:	89 d0                	mov    %edx,%eax
  80202c:	77 52                	ja     802080 <__umoddi3+0xa0>
  80202e:	0f bd ea             	bsr    %edx,%ebp
  802031:	83 f5 1f             	xor    $0x1f,%ebp
  802034:	75 5a                	jne    802090 <__umoddi3+0xb0>
  802036:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80203a:	0f 82 e0 00 00 00    	jb     802120 <__umoddi3+0x140>
  802040:	39 0c 24             	cmp    %ecx,(%esp)
  802043:	0f 86 d7 00 00 00    	jbe    802120 <__umoddi3+0x140>
  802049:	8b 44 24 08          	mov    0x8(%esp),%eax
  80204d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802051:	83 c4 1c             	add    $0x1c,%esp
  802054:	5b                   	pop    %ebx
  802055:	5e                   	pop    %esi
  802056:	5f                   	pop    %edi
  802057:	5d                   	pop    %ebp
  802058:	c3                   	ret    
  802059:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802060:	85 ff                	test   %edi,%edi
  802062:	89 fd                	mov    %edi,%ebp
  802064:	75 0b                	jne    802071 <__umoddi3+0x91>
  802066:	b8 01 00 00 00       	mov    $0x1,%eax
  80206b:	31 d2                	xor    %edx,%edx
  80206d:	f7 f7                	div    %edi
  80206f:	89 c5                	mov    %eax,%ebp
  802071:	89 f0                	mov    %esi,%eax
  802073:	31 d2                	xor    %edx,%edx
  802075:	f7 f5                	div    %ebp
  802077:	89 c8                	mov    %ecx,%eax
  802079:	f7 f5                	div    %ebp
  80207b:	89 d0                	mov    %edx,%eax
  80207d:	eb 99                	jmp    802018 <__umoddi3+0x38>
  80207f:	90                   	nop
  802080:	89 c8                	mov    %ecx,%eax
  802082:	89 f2                	mov    %esi,%edx
  802084:	83 c4 1c             	add    $0x1c,%esp
  802087:	5b                   	pop    %ebx
  802088:	5e                   	pop    %esi
  802089:	5f                   	pop    %edi
  80208a:	5d                   	pop    %ebp
  80208b:	c3                   	ret    
  80208c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802090:	8b 34 24             	mov    (%esp),%esi
  802093:	bf 20 00 00 00       	mov    $0x20,%edi
  802098:	89 e9                	mov    %ebp,%ecx
  80209a:	29 ef                	sub    %ebp,%edi
  80209c:	d3 e0                	shl    %cl,%eax
  80209e:	89 f9                	mov    %edi,%ecx
  8020a0:	89 f2                	mov    %esi,%edx
  8020a2:	d3 ea                	shr    %cl,%edx
  8020a4:	89 e9                	mov    %ebp,%ecx
  8020a6:	09 c2                	or     %eax,%edx
  8020a8:	89 d8                	mov    %ebx,%eax
  8020aa:	89 14 24             	mov    %edx,(%esp)
  8020ad:	89 f2                	mov    %esi,%edx
  8020af:	d3 e2                	shl    %cl,%edx
  8020b1:	89 f9                	mov    %edi,%ecx
  8020b3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8020b7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8020bb:	d3 e8                	shr    %cl,%eax
  8020bd:	89 e9                	mov    %ebp,%ecx
  8020bf:	89 c6                	mov    %eax,%esi
  8020c1:	d3 e3                	shl    %cl,%ebx
  8020c3:	89 f9                	mov    %edi,%ecx
  8020c5:	89 d0                	mov    %edx,%eax
  8020c7:	d3 e8                	shr    %cl,%eax
  8020c9:	89 e9                	mov    %ebp,%ecx
  8020cb:	09 d8                	or     %ebx,%eax
  8020cd:	89 d3                	mov    %edx,%ebx
  8020cf:	89 f2                	mov    %esi,%edx
  8020d1:	f7 34 24             	divl   (%esp)
  8020d4:	89 d6                	mov    %edx,%esi
  8020d6:	d3 e3                	shl    %cl,%ebx
  8020d8:	f7 64 24 04          	mull   0x4(%esp)
  8020dc:	39 d6                	cmp    %edx,%esi
  8020de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020e2:	89 d1                	mov    %edx,%ecx
  8020e4:	89 c3                	mov    %eax,%ebx
  8020e6:	72 08                	jb     8020f0 <__umoddi3+0x110>
  8020e8:	75 11                	jne    8020fb <__umoddi3+0x11b>
  8020ea:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8020ee:	73 0b                	jae    8020fb <__umoddi3+0x11b>
  8020f0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8020f4:	1b 14 24             	sbb    (%esp),%edx
  8020f7:	89 d1                	mov    %edx,%ecx
  8020f9:	89 c3                	mov    %eax,%ebx
  8020fb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8020ff:	29 da                	sub    %ebx,%edx
  802101:	19 ce                	sbb    %ecx,%esi
  802103:	89 f9                	mov    %edi,%ecx
  802105:	89 f0                	mov    %esi,%eax
  802107:	d3 e0                	shl    %cl,%eax
  802109:	89 e9                	mov    %ebp,%ecx
  80210b:	d3 ea                	shr    %cl,%edx
  80210d:	89 e9                	mov    %ebp,%ecx
  80210f:	d3 ee                	shr    %cl,%esi
  802111:	09 d0                	or     %edx,%eax
  802113:	89 f2                	mov    %esi,%edx
  802115:	83 c4 1c             	add    $0x1c,%esp
  802118:	5b                   	pop    %ebx
  802119:	5e                   	pop    %esi
  80211a:	5f                   	pop    %edi
  80211b:	5d                   	pop    %ebp
  80211c:	c3                   	ret    
  80211d:	8d 76 00             	lea    0x0(%esi),%esi
  802120:	29 f9                	sub    %edi,%ecx
  802122:	19 d6                	sbb    %edx,%esi
  802124:	89 74 24 04          	mov    %esi,0x4(%esp)
  802128:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80212c:	e9 18 ff ff ff       	jmp    802049 <__umoddi3+0x69>
