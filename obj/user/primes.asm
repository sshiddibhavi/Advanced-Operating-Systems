
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
  800047:	e8 07 10 00 00       	call   801053 <ipc_recv>
  80004c:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80004e:	a1 04 40 80 00       	mov    0x804004,%eax
  800053:	8b 40 5c             	mov    0x5c(%eax),%eax
  800056:	83 c4 0c             	add    $0xc,%esp
  800059:	53                   	push   %ebx
  80005a:	50                   	push   %eax
  80005b:	68 a0 21 80 00       	push   $0x8021a0
  800060:	e8 cc 01 00 00       	call   800231 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800065:	e8 f4 0e 00 00       	call   800f5e <fork>
  80006a:	89 c7                	mov    %eax,%edi
  80006c:	83 c4 10             	add    $0x10,%esp
  80006f:	85 c0                	test   %eax,%eax
  800071:	79 12                	jns    800085 <primeproc+0x52>
		panic("fork: %e", id);
  800073:	50                   	push   %eax
  800074:	68 53 25 80 00       	push   $0x802553
  800079:	6a 1a                	push   $0x1a
  80007b:	68 ac 21 80 00       	push   $0x8021ac
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
  800094:	e8 ba 0f 00 00       	call   801053 <ipc_recv>
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
  8000ab:	e8 0c 10 00 00       	call   8010bc <ipc_send>
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
  8000ba:	e8 9f 0e 00 00       	call   800f5e <fork>
  8000bf:	89 c6                	mov    %eax,%esi
  8000c1:	85 c0                	test   %eax,%eax
  8000c3:	79 12                	jns    8000d7 <umain+0x22>
		panic("fork: %e", id);
  8000c5:	50                   	push   %eax
  8000c6:	68 53 25 80 00       	push   $0x802553
  8000cb:	6a 2d                	push   $0x2d
  8000cd:	68 ac 21 80 00       	push   $0x8021ac
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
  8000eb:	e8 cc 0f 00 00       	call   8010bc <ipc_send>
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
  800144:	e8 cb 11 00 00       	call   801314 <close_all>
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
  800176:	68 c4 21 80 00       	push   $0x8021c4
  80017b:	e8 b1 00 00 00       	call   800231 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800180:	83 c4 18             	add    $0x18,%esp
  800183:	53                   	push   %ebx
  800184:	ff 75 10             	pushl  0x10(%ebp)
  800187:	e8 54 00 00 00       	call   8001e0 <vcprintf>
	cprintf("\n");
  80018c:	c7 04 24 87 26 80 00 	movl   $0x802687,(%esp)
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
  800294:	e8 77 1c 00 00       	call   801f10 <__udivdi3>
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
  8002d7:	e8 64 1d 00 00       	call   802040 <__umoddi3>
  8002dc:	83 c4 14             	add    $0x14,%esp
  8002df:	0f be 80 e7 21 80 00 	movsbl 0x8021e7(%eax),%eax
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
  8003db:	ff 24 85 20 23 80 00 	jmp    *0x802320(,%eax,4)
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
  80049f:	8b 14 85 80 24 80 00 	mov    0x802480(,%eax,4),%edx
  8004a6:	85 d2                	test   %edx,%edx
  8004a8:	75 18                	jne    8004c2 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004aa:	50                   	push   %eax
  8004ab:	68 ff 21 80 00       	push   $0x8021ff
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
  8004c3:	68 4e 26 80 00       	push   $0x80264e
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
  8004e7:	b8 f8 21 80 00       	mov    $0x8021f8,%eax
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
  800b62:	68 df 24 80 00       	push   $0x8024df
  800b67:	6a 23                	push   $0x23
  800b69:	68 fc 24 80 00       	push   $0x8024fc
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
  800be3:	68 df 24 80 00       	push   $0x8024df
  800be8:	6a 23                	push   $0x23
  800bea:	68 fc 24 80 00       	push   $0x8024fc
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
  800c25:	68 df 24 80 00       	push   $0x8024df
  800c2a:	6a 23                	push   $0x23
  800c2c:	68 fc 24 80 00       	push   $0x8024fc
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
  800c67:	68 df 24 80 00       	push   $0x8024df
  800c6c:	6a 23                	push   $0x23
  800c6e:	68 fc 24 80 00       	push   $0x8024fc
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
  800ca9:	68 df 24 80 00       	push   $0x8024df
  800cae:	6a 23                	push   $0x23
  800cb0:	68 fc 24 80 00       	push   $0x8024fc
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
  800ceb:	68 df 24 80 00       	push   $0x8024df
  800cf0:	6a 23                	push   $0x23
  800cf2:	68 fc 24 80 00       	push   $0x8024fc
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
  800d2d:	68 df 24 80 00       	push   $0x8024df
  800d32:	6a 23                	push   $0x23
  800d34:	68 fc 24 80 00       	push   $0x8024fc
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
  800d91:	68 df 24 80 00       	push   $0x8024df
  800d96:	6a 23                	push   $0x23
  800d98:	68 fc 24 80 00       	push   $0x8024fc
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
  800dad:	53                   	push   %ebx
  800dae:	83 ec 04             	sub    $0x4,%esp
	int r;
	void * address = (void *)(pn*PGSIZE);
  800db1:	89 d3                	mov    %edx,%ebx
  800db3:	c1 e3 0c             	shl    $0xc,%ebx
	
	if((uvpt[pn] & PTE_SHARE))
  800db6:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800dbd:	f6 c5 04             	test   $0x4,%ch
  800dc0:	74 38                	je     800dfa <duppage+0x50>
	{
		if ((r = sys_page_map(0, address, envid, address, (uvpt[pn] | PTE_SYSCALL))) < 0)
  800dc2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dc9:	83 ec 0c             	sub    $0xc,%esp
  800dcc:	81 ca 07 0e 00 00    	or     $0xe07,%edx
  800dd2:	52                   	push   %edx
  800dd3:	53                   	push   %ebx
  800dd4:	50                   	push   %eax
  800dd5:	53                   	push   %ebx
  800dd6:	6a 00                	push   $0x0
  800dd8:	e8 1f fe ff ff       	call   800bfc <sys_page_map>
  800ddd:	83 c4 20             	add    $0x20,%esp
  800de0:	85 c0                	test   %eax,%eax
  800de2:	0f 89 b8 00 00 00    	jns    800ea0 <duppage+0xf6>
			panic("sys_page_map: %e", r);
  800de8:	50                   	push   %eax
  800de9:	68 0a 25 80 00       	push   $0x80250a
  800dee:	6a 4e                	push   $0x4e
  800df0:	68 1b 25 80 00       	push   $0x80251b
  800df5:	e8 5e f3 ff ff       	call   800158 <_panic>
	}
	else if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW))
  800dfa:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800e01:	f6 c1 02             	test   $0x2,%cl
  800e04:	75 0c                	jne    800e12 <duppage+0x68>
  800e06:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800e0d:	f6 c5 08             	test   $0x8,%ch
  800e10:	74 57                	je     800e69 <duppage+0xbf>
	{
		int perm = 0;
		perm |= PTE_P|PTE_U|PTE_COW;
	
		if ((r = sys_page_map(0, address, envid, address, perm)) < 0)
  800e12:	83 ec 0c             	sub    $0xc,%esp
  800e15:	68 05 08 00 00       	push   $0x805
  800e1a:	53                   	push   %ebx
  800e1b:	50                   	push   %eax
  800e1c:	53                   	push   %ebx
  800e1d:	6a 00                	push   $0x0
  800e1f:	e8 d8 fd ff ff       	call   800bfc <sys_page_map>
  800e24:	83 c4 20             	add    $0x20,%esp
  800e27:	85 c0                	test   %eax,%eax
  800e29:	79 12                	jns    800e3d <duppage+0x93>
			panic("sys_page_map: %e", r);
  800e2b:	50                   	push   %eax
  800e2c:	68 0a 25 80 00       	push   $0x80250a
  800e31:	6a 56                	push   $0x56
  800e33:	68 1b 25 80 00       	push   $0x80251b
  800e38:	e8 1b f3 ff ff       	call   800158 <_panic>
		if ((r = sys_page_map(0, address, 0, address, perm)) < 0)
  800e3d:	83 ec 0c             	sub    $0xc,%esp
  800e40:	68 05 08 00 00       	push   $0x805
  800e45:	53                   	push   %ebx
  800e46:	6a 00                	push   $0x0
  800e48:	53                   	push   %ebx
  800e49:	6a 00                	push   $0x0
  800e4b:	e8 ac fd ff ff       	call   800bfc <sys_page_map>
  800e50:	83 c4 20             	add    $0x20,%esp
  800e53:	85 c0                	test   %eax,%eax
  800e55:	79 49                	jns    800ea0 <duppage+0xf6>
			panic("sys_page_map: %e", r);
  800e57:	50                   	push   %eax
  800e58:	68 0a 25 80 00       	push   $0x80250a
  800e5d:	6a 58                	push   $0x58
  800e5f:	68 1b 25 80 00       	push   $0x80251b
  800e64:	e8 ef f2 ff ff       	call   800158 <_panic>
	}
	else if((uvpt[pn] & ~PTE_U) == 0)
  800e69:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e70:	f7 c2 fb ff ff ff    	test   $0xfffffffb,%edx
  800e76:	75 28                	jne    800ea0 <duppage+0xf6>
	{
		//cprintf("im here");
		if ((r = sys_page_map(0, address, envid, address, PTE_P|PTE_U)) < 0)
  800e78:	83 ec 0c             	sub    $0xc,%esp
  800e7b:	6a 05                	push   $0x5
  800e7d:	53                   	push   %ebx
  800e7e:	50                   	push   %eax
  800e7f:	53                   	push   %ebx
  800e80:	6a 00                	push   $0x0
  800e82:	e8 75 fd ff ff       	call   800bfc <sys_page_map>
  800e87:	83 c4 20             	add    $0x20,%esp
  800e8a:	85 c0                	test   %eax,%eax
  800e8c:	79 12                	jns    800ea0 <duppage+0xf6>
			panic("sys_page_map: %e", r);	
  800e8e:	50                   	push   %eax
  800e8f:	68 0a 25 80 00       	push   $0x80250a
  800e94:	6a 5e                	push   $0x5e
  800e96:	68 1b 25 80 00       	push   $0x80251b
  800e9b:	e8 b8 f2 ff ff       	call   800158 <_panic>
	}
	return 0;
}
  800ea0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ea5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ea8:	c9                   	leave  
  800ea9:	c3                   	ret    

00800eaa <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800eaa:	55                   	push   %ebp
  800eab:	89 e5                	mov    %esp,%ebp
  800ead:	53                   	push   %ebx
  800eae:	83 ec 08             	sub    $0x8,%esp
	void *addr = (void *) utf->utf_fault_va;
  800eb1:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb4:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	unsigned pn = ((uint32_t)addr)/PGSIZE;
  800eb6:	89 d8                	mov    %ebx,%eax
  800eb8:	c1 e8 0c             	shr    $0xc,%eax
	pte_t pte = uvpt[pn];
  800ebb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// Allocate a new page, mapped at temp location
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  800ec2:	6a 07                	push   $0x7
  800ec4:	68 00 f0 7f 00       	push   $0x7ff000
  800ec9:	6a 00                	push   $0x0
  800ecb:	e8 e9 fc ff ff       	call   800bb9 <sys_page_alloc>
  800ed0:	83 c4 10             	add    $0x10,%esp
  800ed3:	85 c0                	test   %eax,%eax
  800ed5:	79 12                	jns    800ee9 <pgfault+0x3f>
		panic("sys_page_alloc: %e", r);
  800ed7:	50                   	push   %eax
  800ed8:	68 26 25 80 00       	push   $0x802526
  800edd:	6a 2b                	push   $0x2b
  800edf:	68 1b 25 80 00       	push   $0x80251b
  800ee4:	e8 6f f2 ff ff       	call   800158 <_panic>

	// Copy the data from the old page to this new page
	void *addr_pgstart = (void *) ROUNDDOWN(addr, PGSIZE);
  800ee9:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr_pgstart, PGSIZE);
  800eef:	83 ec 04             	sub    $0x4,%esp
  800ef2:	68 00 10 00 00       	push   $0x1000
  800ef7:	53                   	push   %ebx
  800ef8:	68 00 f0 7f 00       	push   $0x7ff000
  800efd:	e8 46 fa ff ff       	call   800948 <memmove>

	// Move the new page to the old page's address
	if ((r = sys_page_map(0, PFTEMP, 0, addr_pgstart, PTE_P|PTE_U|PTE_W)) < 0)
  800f02:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f09:	53                   	push   %ebx
  800f0a:	6a 00                	push   $0x0
  800f0c:	68 00 f0 7f 00       	push   $0x7ff000
  800f11:	6a 00                	push   $0x0
  800f13:	e8 e4 fc ff ff       	call   800bfc <sys_page_map>
  800f18:	83 c4 20             	add    $0x20,%esp
  800f1b:	85 c0                	test   %eax,%eax
  800f1d:	79 12                	jns    800f31 <pgfault+0x87>
		panic("sys_page_map: %e", r);
  800f1f:	50                   	push   %eax
  800f20:	68 0a 25 80 00       	push   $0x80250a
  800f25:	6a 33                	push   $0x33
  800f27:	68 1b 25 80 00       	push   $0x80251b
  800f2c:	e8 27 f2 ff ff       	call   800158 <_panic>

	// Unmap the temp location
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800f31:	83 ec 08             	sub    $0x8,%esp
  800f34:	68 00 f0 7f 00       	push   $0x7ff000
  800f39:	6a 00                	push   $0x0
  800f3b:	e8 fe fc ff ff       	call   800c3e <sys_page_unmap>
  800f40:	83 c4 10             	add    $0x10,%esp
  800f43:	85 c0                	test   %eax,%eax
  800f45:	79 12                	jns    800f59 <pgfault+0xaf>
		panic("sys_page_unmap: %e", r);
  800f47:	50                   	push   %eax
  800f48:	68 39 25 80 00       	push   $0x802539
  800f4d:	6a 37                	push   $0x37
  800f4f:	68 1b 25 80 00       	push   $0x80251b
  800f54:	e8 ff f1 ff ff       	call   800158 <_panic>
}
  800f59:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f5c:	c9                   	leave  
  800f5d:	c3                   	ret    

00800f5e <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f5e:	55                   	push   %ebp
  800f5f:	89 e5                	mov    %esp,%ebp
  800f61:	56                   	push   %esi
  800f62:	53                   	push   %ebx
  800f63:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
	// Set up page fault handler
	set_pgfault_handler(&pgfault);
  800f66:	68 aa 0e 80 00       	push   $0x800eaa
  800f6b:	e8 ec 0e 00 00       	call   801e5c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f70:	b8 07 00 00 00       	mov    $0x7,%eax
  800f75:	cd 30                	int    $0x30

	// Create child
	envid_t envid = sys_exofork();
  800f77:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (envid < 0) {
  800f7a:	83 c4 10             	add    $0x10,%esp
  800f7d:	85 c0                	test   %eax,%eax
  800f7f:	79 12                	jns    800f93 <fork+0x35>
		panic("sys_exofork: %e", envid);
  800f81:	50                   	push   %eax
  800f82:	68 4c 25 80 00       	push   $0x80254c
  800f87:	6a 7c                	push   $0x7c
  800f89:	68 1b 25 80 00       	push   $0x80251b
  800f8e:	e8 c5 f1 ff ff       	call   800158 <_panic>
		return envid;
	}
	if (envid == 0) {
  800f93:	85 c0                	test   %eax,%eax
  800f95:	75 1e                	jne    800fb5 <fork+0x57>
		// We are the child.
		thisenv = &envs[ENVX(sys_getenvid())]; // Fix thisenv
  800f97:	e8 df fb ff ff       	call   800b7b <sys_getenvid>
  800f9c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fa1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800fa4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fa9:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800fae:	b8 00 00 00 00       	mov    $0x0,%eax
  800fb3:	eb 7d                	jmp    801032 <fork+0xd4>

	// Set page fault handler on the child.
	// The parent needs to do it, else the child wouldn't be able to handle
	// the fault when trying to access it's stack (which happens as soon it starts)
	extern void _pgfault_upcall(void);
	sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);
  800fb5:	83 ec 04             	sub    $0x4,%esp
  800fb8:	6a 07                	push   $0x7
  800fba:	68 00 f0 bf ee       	push   $0xeebff000
  800fbf:	50                   	push   %eax
  800fc0:	e8 f4 fb ff ff       	call   800bb9 <sys_page_alloc>
	sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  800fc5:	83 c4 08             	add    $0x8,%esp
  800fc8:	68 a1 1e 80 00       	push   $0x801ea1
  800fcd:	ff 75 f4             	pushl  -0xc(%ebp)
  800fd0:	e8 2f fd ff ff       	call   800d04 <sys_env_set_pgfault_upcall>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  800fd5:	be 04 60 80 00       	mov    $0x806004,%esi
  800fda:	c1 ee 0c             	shr    $0xc,%esi
  800fdd:	83 c4 10             	add    $0x10,%esp
  800fe0:	bb 00 08 00 00       	mov    $0x800,%ebx
  800fe5:	eb 0d                	jmp    800ff4 <fork+0x96>
		duppage(envid, pn);
  800fe7:	89 da                	mov    %ebx,%edx
  800fe9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fec:	e8 b9 fd ff ff       	call   800daa <duppage>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  800ff1:	83 c3 01             	add    $0x1,%ebx
  800ff4:	39 f3                	cmp    %esi,%ebx
  800ff6:	76 ef                	jbe    800fe7 <fork+0x89>
	}

	// Also copy the stack we are currently running on
	// I think it should loop from ustacktop to this page, since the stack
	// can have more than 1 page
	duppage(envid, ((uint32_t) &envid)/PGSIZE);
  800ff8:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800ffb:	c1 ea 0c             	shr    $0xc,%edx
  800ffe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801001:	e8 a4 fd ff ff       	call   800daa <duppage>

	// Start the child environmnet running
	int r;
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  801006:	83 ec 08             	sub    $0x8,%esp
  801009:	6a 02                	push   $0x2
  80100b:	ff 75 f4             	pushl  -0xc(%ebp)
  80100e:	e8 6d fc ff ff       	call   800c80 <sys_env_set_status>
  801013:	83 c4 10             	add    $0x10,%esp
  801016:	85 c0                	test   %eax,%eax
  801018:	79 15                	jns    80102f <fork+0xd1>
		panic("sys_env_set_status: %e", r);
  80101a:	50                   	push   %eax
  80101b:	68 5c 25 80 00       	push   $0x80255c
  801020:	68 9c 00 00 00       	push   $0x9c
  801025:	68 1b 25 80 00       	push   $0x80251b
  80102a:	e8 29 f1 ff ff       	call   800158 <_panic>
		return r;
	}

	return envid;
  80102f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  801032:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801035:	5b                   	pop    %ebx
  801036:	5e                   	pop    %esi
  801037:	5d                   	pop    %ebp
  801038:	c3                   	ret    

00801039 <sfork>:

// Challenge!
int
sfork(void)
{
  801039:	55                   	push   %ebp
  80103a:	89 e5                	mov    %esp,%ebp
  80103c:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80103f:	68 73 25 80 00       	push   $0x802573
  801044:	68 a7 00 00 00       	push   $0xa7
  801049:	68 1b 25 80 00       	push   $0x80251b
  80104e:	e8 05 f1 ff ff       	call   800158 <_panic>

00801053 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801053:	55                   	push   %ebp
  801054:	89 e5                	mov    %esp,%ebp
  801056:	56                   	push   %esi
  801057:	53                   	push   %ebx
  801058:	8b 75 08             	mov    0x8(%ebp),%esi
  80105b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80105e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  801061:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801063:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801068:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  80106b:	83 ec 0c             	sub    $0xc,%esp
  80106e:	50                   	push   %eax
  80106f:	e8 f5 fc ff ff       	call   800d69 <sys_ipc_recv>

	if (r < 0) {
  801074:	83 c4 10             	add    $0x10,%esp
  801077:	85 c0                	test   %eax,%eax
  801079:	79 16                	jns    801091 <ipc_recv+0x3e>
		if (from_env_store)
  80107b:	85 f6                	test   %esi,%esi
  80107d:	74 06                	je     801085 <ipc_recv+0x32>
			*from_env_store = 0;
  80107f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  801085:	85 db                	test   %ebx,%ebx
  801087:	74 2c                	je     8010b5 <ipc_recv+0x62>
			*perm_store = 0;
  801089:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80108f:	eb 24                	jmp    8010b5 <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  801091:	85 f6                	test   %esi,%esi
  801093:	74 0a                	je     80109f <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  801095:	a1 04 40 80 00       	mov    0x804004,%eax
  80109a:	8b 40 74             	mov    0x74(%eax),%eax
  80109d:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  80109f:	85 db                	test   %ebx,%ebx
  8010a1:	74 0a                	je     8010ad <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  8010a3:	a1 04 40 80 00       	mov    0x804004,%eax
  8010a8:	8b 40 78             	mov    0x78(%eax),%eax
  8010ab:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  8010ad:	a1 04 40 80 00       	mov    0x804004,%eax
  8010b2:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  8010b5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010b8:	5b                   	pop    %ebx
  8010b9:	5e                   	pop    %esi
  8010ba:	5d                   	pop    %ebp
  8010bb:	c3                   	ret    

008010bc <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8010bc:	55                   	push   %ebp
  8010bd:	89 e5                	mov    %esp,%ebp
  8010bf:	57                   	push   %edi
  8010c0:	56                   	push   %esi
  8010c1:	53                   	push   %ebx
  8010c2:	83 ec 0c             	sub    $0xc,%esp
  8010c5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010c8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010cb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  8010ce:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  8010d0:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  8010d5:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  8010d8:	ff 75 14             	pushl  0x14(%ebp)
  8010db:	53                   	push   %ebx
  8010dc:	56                   	push   %esi
  8010dd:	57                   	push   %edi
  8010de:	e8 63 fc ff ff       	call   800d46 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  8010e3:	83 c4 10             	add    $0x10,%esp
  8010e6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8010e9:	75 07                	jne    8010f2 <ipc_send+0x36>
			sys_yield();
  8010eb:	e8 aa fa ff ff       	call   800b9a <sys_yield>
  8010f0:	eb e6                	jmp    8010d8 <ipc_send+0x1c>
		} else if (r < 0) {
  8010f2:	85 c0                	test   %eax,%eax
  8010f4:	79 12                	jns    801108 <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  8010f6:	50                   	push   %eax
  8010f7:	68 89 25 80 00       	push   $0x802589
  8010fc:	6a 51                	push   $0x51
  8010fe:	68 96 25 80 00       	push   $0x802596
  801103:	e8 50 f0 ff ff       	call   800158 <_panic>
		}
	}
}
  801108:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80110b:	5b                   	pop    %ebx
  80110c:	5e                   	pop    %esi
  80110d:	5f                   	pop    %edi
  80110e:	5d                   	pop    %ebp
  80110f:	c3                   	ret    

00801110 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801110:	55                   	push   %ebp
  801111:	89 e5                	mov    %esp,%ebp
  801113:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801116:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80111b:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80111e:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801124:	8b 52 50             	mov    0x50(%edx),%edx
  801127:	39 ca                	cmp    %ecx,%edx
  801129:	75 0d                	jne    801138 <ipc_find_env+0x28>
			return envs[i].env_id;
  80112b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80112e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801133:	8b 40 48             	mov    0x48(%eax),%eax
  801136:	eb 0f                	jmp    801147 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801138:	83 c0 01             	add    $0x1,%eax
  80113b:	3d 00 04 00 00       	cmp    $0x400,%eax
  801140:	75 d9                	jne    80111b <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801142:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801147:	5d                   	pop    %ebp
  801148:	c3                   	ret    

00801149 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801149:	55                   	push   %ebp
  80114a:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80114c:	8b 45 08             	mov    0x8(%ebp),%eax
  80114f:	05 00 00 00 30       	add    $0x30000000,%eax
  801154:	c1 e8 0c             	shr    $0xc,%eax
}
  801157:	5d                   	pop    %ebp
  801158:	c3                   	ret    

00801159 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801159:	55                   	push   %ebp
  80115a:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80115c:	8b 45 08             	mov    0x8(%ebp),%eax
  80115f:	05 00 00 00 30       	add    $0x30000000,%eax
  801164:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801169:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80116e:	5d                   	pop    %ebp
  80116f:	c3                   	ret    

00801170 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801170:	55                   	push   %ebp
  801171:	89 e5                	mov    %esp,%ebp
  801173:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801176:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80117b:	89 c2                	mov    %eax,%edx
  80117d:	c1 ea 16             	shr    $0x16,%edx
  801180:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801187:	f6 c2 01             	test   $0x1,%dl
  80118a:	74 11                	je     80119d <fd_alloc+0x2d>
  80118c:	89 c2                	mov    %eax,%edx
  80118e:	c1 ea 0c             	shr    $0xc,%edx
  801191:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801198:	f6 c2 01             	test   $0x1,%dl
  80119b:	75 09                	jne    8011a6 <fd_alloc+0x36>
			*fd_store = fd;
  80119d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80119f:	b8 00 00 00 00       	mov    $0x0,%eax
  8011a4:	eb 17                	jmp    8011bd <fd_alloc+0x4d>
  8011a6:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011ab:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011b0:	75 c9                	jne    80117b <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011b2:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011b8:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011bd:	5d                   	pop    %ebp
  8011be:	c3                   	ret    

008011bf <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011bf:	55                   	push   %ebp
  8011c0:	89 e5                	mov    %esp,%ebp
  8011c2:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011c5:	83 f8 1f             	cmp    $0x1f,%eax
  8011c8:	77 36                	ja     801200 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011ca:	c1 e0 0c             	shl    $0xc,%eax
  8011cd:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011d2:	89 c2                	mov    %eax,%edx
  8011d4:	c1 ea 16             	shr    $0x16,%edx
  8011d7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011de:	f6 c2 01             	test   $0x1,%dl
  8011e1:	74 24                	je     801207 <fd_lookup+0x48>
  8011e3:	89 c2                	mov    %eax,%edx
  8011e5:	c1 ea 0c             	shr    $0xc,%edx
  8011e8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011ef:	f6 c2 01             	test   $0x1,%dl
  8011f2:	74 1a                	je     80120e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011f7:	89 02                	mov    %eax,(%edx)
	return 0;
  8011f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8011fe:	eb 13                	jmp    801213 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801200:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801205:	eb 0c                	jmp    801213 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801207:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80120c:	eb 05                	jmp    801213 <fd_lookup+0x54>
  80120e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801213:	5d                   	pop    %ebp
  801214:	c3                   	ret    

00801215 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801215:	55                   	push   %ebp
  801216:	89 e5                	mov    %esp,%ebp
  801218:	83 ec 08             	sub    $0x8,%esp
  80121b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80121e:	ba 20 26 80 00       	mov    $0x802620,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801223:	eb 13                	jmp    801238 <dev_lookup+0x23>
  801225:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801228:	39 08                	cmp    %ecx,(%eax)
  80122a:	75 0c                	jne    801238 <dev_lookup+0x23>
			*dev = devtab[i];
  80122c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80122f:	89 01                	mov    %eax,(%ecx)
			return 0;
  801231:	b8 00 00 00 00       	mov    $0x0,%eax
  801236:	eb 2e                	jmp    801266 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801238:	8b 02                	mov    (%edx),%eax
  80123a:	85 c0                	test   %eax,%eax
  80123c:	75 e7                	jne    801225 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80123e:	a1 04 40 80 00       	mov    0x804004,%eax
  801243:	8b 40 48             	mov    0x48(%eax),%eax
  801246:	83 ec 04             	sub    $0x4,%esp
  801249:	51                   	push   %ecx
  80124a:	50                   	push   %eax
  80124b:	68 a0 25 80 00       	push   $0x8025a0
  801250:	e8 dc ef ff ff       	call   800231 <cprintf>
	*dev = 0;
  801255:	8b 45 0c             	mov    0xc(%ebp),%eax
  801258:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80125e:	83 c4 10             	add    $0x10,%esp
  801261:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801266:	c9                   	leave  
  801267:	c3                   	ret    

00801268 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801268:	55                   	push   %ebp
  801269:	89 e5                	mov    %esp,%ebp
  80126b:	56                   	push   %esi
  80126c:	53                   	push   %ebx
  80126d:	83 ec 10             	sub    $0x10,%esp
  801270:	8b 75 08             	mov    0x8(%ebp),%esi
  801273:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801276:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801279:	50                   	push   %eax
  80127a:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801280:	c1 e8 0c             	shr    $0xc,%eax
  801283:	50                   	push   %eax
  801284:	e8 36 ff ff ff       	call   8011bf <fd_lookup>
  801289:	83 c4 08             	add    $0x8,%esp
  80128c:	85 c0                	test   %eax,%eax
  80128e:	78 05                	js     801295 <fd_close+0x2d>
	    || fd != fd2)
  801290:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801293:	74 0c                	je     8012a1 <fd_close+0x39>
		return (must_exist ? r : 0);
  801295:	84 db                	test   %bl,%bl
  801297:	ba 00 00 00 00       	mov    $0x0,%edx
  80129c:	0f 44 c2             	cmove  %edx,%eax
  80129f:	eb 41                	jmp    8012e2 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012a1:	83 ec 08             	sub    $0x8,%esp
  8012a4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012a7:	50                   	push   %eax
  8012a8:	ff 36                	pushl  (%esi)
  8012aa:	e8 66 ff ff ff       	call   801215 <dev_lookup>
  8012af:	89 c3                	mov    %eax,%ebx
  8012b1:	83 c4 10             	add    $0x10,%esp
  8012b4:	85 c0                	test   %eax,%eax
  8012b6:	78 1a                	js     8012d2 <fd_close+0x6a>
		if (dev->dev_close)
  8012b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012bb:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012be:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012c3:	85 c0                	test   %eax,%eax
  8012c5:	74 0b                	je     8012d2 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012c7:	83 ec 0c             	sub    $0xc,%esp
  8012ca:	56                   	push   %esi
  8012cb:	ff d0                	call   *%eax
  8012cd:	89 c3                	mov    %eax,%ebx
  8012cf:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012d2:	83 ec 08             	sub    $0x8,%esp
  8012d5:	56                   	push   %esi
  8012d6:	6a 00                	push   $0x0
  8012d8:	e8 61 f9 ff ff       	call   800c3e <sys_page_unmap>
	return r;
  8012dd:	83 c4 10             	add    $0x10,%esp
  8012e0:	89 d8                	mov    %ebx,%eax
}
  8012e2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012e5:	5b                   	pop    %ebx
  8012e6:	5e                   	pop    %esi
  8012e7:	5d                   	pop    %ebp
  8012e8:	c3                   	ret    

008012e9 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012e9:	55                   	push   %ebp
  8012ea:	89 e5                	mov    %esp,%ebp
  8012ec:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f2:	50                   	push   %eax
  8012f3:	ff 75 08             	pushl  0x8(%ebp)
  8012f6:	e8 c4 fe ff ff       	call   8011bf <fd_lookup>
  8012fb:	83 c4 08             	add    $0x8,%esp
  8012fe:	85 c0                	test   %eax,%eax
  801300:	78 10                	js     801312 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801302:	83 ec 08             	sub    $0x8,%esp
  801305:	6a 01                	push   $0x1
  801307:	ff 75 f4             	pushl  -0xc(%ebp)
  80130a:	e8 59 ff ff ff       	call   801268 <fd_close>
  80130f:	83 c4 10             	add    $0x10,%esp
}
  801312:	c9                   	leave  
  801313:	c3                   	ret    

00801314 <close_all>:

void
close_all(void)
{
  801314:	55                   	push   %ebp
  801315:	89 e5                	mov    %esp,%ebp
  801317:	53                   	push   %ebx
  801318:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80131b:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801320:	83 ec 0c             	sub    $0xc,%esp
  801323:	53                   	push   %ebx
  801324:	e8 c0 ff ff ff       	call   8012e9 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801329:	83 c3 01             	add    $0x1,%ebx
  80132c:	83 c4 10             	add    $0x10,%esp
  80132f:	83 fb 20             	cmp    $0x20,%ebx
  801332:	75 ec                	jne    801320 <close_all+0xc>
		close(i);
}
  801334:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801337:	c9                   	leave  
  801338:	c3                   	ret    

00801339 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801339:	55                   	push   %ebp
  80133a:	89 e5                	mov    %esp,%ebp
  80133c:	57                   	push   %edi
  80133d:	56                   	push   %esi
  80133e:	53                   	push   %ebx
  80133f:	83 ec 2c             	sub    $0x2c,%esp
  801342:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801345:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801348:	50                   	push   %eax
  801349:	ff 75 08             	pushl  0x8(%ebp)
  80134c:	e8 6e fe ff ff       	call   8011bf <fd_lookup>
  801351:	83 c4 08             	add    $0x8,%esp
  801354:	85 c0                	test   %eax,%eax
  801356:	0f 88 c1 00 00 00    	js     80141d <dup+0xe4>
		return r;
	close(newfdnum);
  80135c:	83 ec 0c             	sub    $0xc,%esp
  80135f:	56                   	push   %esi
  801360:	e8 84 ff ff ff       	call   8012e9 <close>

	newfd = INDEX2FD(newfdnum);
  801365:	89 f3                	mov    %esi,%ebx
  801367:	c1 e3 0c             	shl    $0xc,%ebx
  80136a:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801370:	83 c4 04             	add    $0x4,%esp
  801373:	ff 75 e4             	pushl  -0x1c(%ebp)
  801376:	e8 de fd ff ff       	call   801159 <fd2data>
  80137b:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80137d:	89 1c 24             	mov    %ebx,(%esp)
  801380:	e8 d4 fd ff ff       	call   801159 <fd2data>
  801385:	83 c4 10             	add    $0x10,%esp
  801388:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80138b:	89 f8                	mov    %edi,%eax
  80138d:	c1 e8 16             	shr    $0x16,%eax
  801390:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801397:	a8 01                	test   $0x1,%al
  801399:	74 37                	je     8013d2 <dup+0x99>
  80139b:	89 f8                	mov    %edi,%eax
  80139d:	c1 e8 0c             	shr    $0xc,%eax
  8013a0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013a7:	f6 c2 01             	test   $0x1,%dl
  8013aa:	74 26                	je     8013d2 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013ac:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013b3:	83 ec 0c             	sub    $0xc,%esp
  8013b6:	25 07 0e 00 00       	and    $0xe07,%eax
  8013bb:	50                   	push   %eax
  8013bc:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013bf:	6a 00                	push   $0x0
  8013c1:	57                   	push   %edi
  8013c2:	6a 00                	push   $0x0
  8013c4:	e8 33 f8 ff ff       	call   800bfc <sys_page_map>
  8013c9:	89 c7                	mov    %eax,%edi
  8013cb:	83 c4 20             	add    $0x20,%esp
  8013ce:	85 c0                	test   %eax,%eax
  8013d0:	78 2e                	js     801400 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013d2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013d5:	89 d0                	mov    %edx,%eax
  8013d7:	c1 e8 0c             	shr    $0xc,%eax
  8013da:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013e1:	83 ec 0c             	sub    $0xc,%esp
  8013e4:	25 07 0e 00 00       	and    $0xe07,%eax
  8013e9:	50                   	push   %eax
  8013ea:	53                   	push   %ebx
  8013eb:	6a 00                	push   $0x0
  8013ed:	52                   	push   %edx
  8013ee:	6a 00                	push   $0x0
  8013f0:	e8 07 f8 ff ff       	call   800bfc <sys_page_map>
  8013f5:	89 c7                	mov    %eax,%edi
  8013f7:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8013fa:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013fc:	85 ff                	test   %edi,%edi
  8013fe:	79 1d                	jns    80141d <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801400:	83 ec 08             	sub    $0x8,%esp
  801403:	53                   	push   %ebx
  801404:	6a 00                	push   $0x0
  801406:	e8 33 f8 ff ff       	call   800c3e <sys_page_unmap>
	sys_page_unmap(0, nva);
  80140b:	83 c4 08             	add    $0x8,%esp
  80140e:	ff 75 d4             	pushl  -0x2c(%ebp)
  801411:	6a 00                	push   $0x0
  801413:	e8 26 f8 ff ff       	call   800c3e <sys_page_unmap>
	return r;
  801418:	83 c4 10             	add    $0x10,%esp
  80141b:	89 f8                	mov    %edi,%eax
}
  80141d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801420:	5b                   	pop    %ebx
  801421:	5e                   	pop    %esi
  801422:	5f                   	pop    %edi
  801423:	5d                   	pop    %ebp
  801424:	c3                   	ret    

00801425 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801425:	55                   	push   %ebp
  801426:	89 e5                	mov    %esp,%ebp
  801428:	53                   	push   %ebx
  801429:	83 ec 14             	sub    $0x14,%esp
  80142c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80142f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801432:	50                   	push   %eax
  801433:	53                   	push   %ebx
  801434:	e8 86 fd ff ff       	call   8011bf <fd_lookup>
  801439:	83 c4 08             	add    $0x8,%esp
  80143c:	89 c2                	mov    %eax,%edx
  80143e:	85 c0                	test   %eax,%eax
  801440:	78 6d                	js     8014af <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801442:	83 ec 08             	sub    $0x8,%esp
  801445:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801448:	50                   	push   %eax
  801449:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80144c:	ff 30                	pushl  (%eax)
  80144e:	e8 c2 fd ff ff       	call   801215 <dev_lookup>
  801453:	83 c4 10             	add    $0x10,%esp
  801456:	85 c0                	test   %eax,%eax
  801458:	78 4c                	js     8014a6 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80145a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80145d:	8b 42 08             	mov    0x8(%edx),%eax
  801460:	83 e0 03             	and    $0x3,%eax
  801463:	83 f8 01             	cmp    $0x1,%eax
  801466:	75 21                	jne    801489 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801468:	a1 04 40 80 00       	mov    0x804004,%eax
  80146d:	8b 40 48             	mov    0x48(%eax),%eax
  801470:	83 ec 04             	sub    $0x4,%esp
  801473:	53                   	push   %ebx
  801474:	50                   	push   %eax
  801475:	68 e4 25 80 00       	push   $0x8025e4
  80147a:	e8 b2 ed ff ff       	call   800231 <cprintf>
		return -E_INVAL;
  80147f:	83 c4 10             	add    $0x10,%esp
  801482:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801487:	eb 26                	jmp    8014af <read+0x8a>
	}
	if (!dev->dev_read)
  801489:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80148c:	8b 40 08             	mov    0x8(%eax),%eax
  80148f:	85 c0                	test   %eax,%eax
  801491:	74 17                	je     8014aa <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801493:	83 ec 04             	sub    $0x4,%esp
  801496:	ff 75 10             	pushl  0x10(%ebp)
  801499:	ff 75 0c             	pushl  0xc(%ebp)
  80149c:	52                   	push   %edx
  80149d:	ff d0                	call   *%eax
  80149f:	89 c2                	mov    %eax,%edx
  8014a1:	83 c4 10             	add    $0x10,%esp
  8014a4:	eb 09                	jmp    8014af <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014a6:	89 c2                	mov    %eax,%edx
  8014a8:	eb 05                	jmp    8014af <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014aa:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8014af:	89 d0                	mov    %edx,%eax
  8014b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014b4:	c9                   	leave  
  8014b5:	c3                   	ret    

008014b6 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014b6:	55                   	push   %ebp
  8014b7:	89 e5                	mov    %esp,%ebp
  8014b9:	57                   	push   %edi
  8014ba:	56                   	push   %esi
  8014bb:	53                   	push   %ebx
  8014bc:	83 ec 0c             	sub    $0xc,%esp
  8014bf:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014c2:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014c5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014ca:	eb 21                	jmp    8014ed <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014cc:	83 ec 04             	sub    $0x4,%esp
  8014cf:	89 f0                	mov    %esi,%eax
  8014d1:	29 d8                	sub    %ebx,%eax
  8014d3:	50                   	push   %eax
  8014d4:	89 d8                	mov    %ebx,%eax
  8014d6:	03 45 0c             	add    0xc(%ebp),%eax
  8014d9:	50                   	push   %eax
  8014da:	57                   	push   %edi
  8014db:	e8 45 ff ff ff       	call   801425 <read>
		if (m < 0)
  8014e0:	83 c4 10             	add    $0x10,%esp
  8014e3:	85 c0                	test   %eax,%eax
  8014e5:	78 10                	js     8014f7 <readn+0x41>
			return m;
		if (m == 0)
  8014e7:	85 c0                	test   %eax,%eax
  8014e9:	74 0a                	je     8014f5 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014eb:	01 c3                	add    %eax,%ebx
  8014ed:	39 f3                	cmp    %esi,%ebx
  8014ef:	72 db                	jb     8014cc <readn+0x16>
  8014f1:	89 d8                	mov    %ebx,%eax
  8014f3:	eb 02                	jmp    8014f7 <readn+0x41>
  8014f5:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8014f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014fa:	5b                   	pop    %ebx
  8014fb:	5e                   	pop    %esi
  8014fc:	5f                   	pop    %edi
  8014fd:	5d                   	pop    %ebp
  8014fe:	c3                   	ret    

008014ff <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014ff:	55                   	push   %ebp
  801500:	89 e5                	mov    %esp,%ebp
  801502:	53                   	push   %ebx
  801503:	83 ec 14             	sub    $0x14,%esp
  801506:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801509:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80150c:	50                   	push   %eax
  80150d:	53                   	push   %ebx
  80150e:	e8 ac fc ff ff       	call   8011bf <fd_lookup>
  801513:	83 c4 08             	add    $0x8,%esp
  801516:	89 c2                	mov    %eax,%edx
  801518:	85 c0                	test   %eax,%eax
  80151a:	78 68                	js     801584 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80151c:	83 ec 08             	sub    $0x8,%esp
  80151f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801522:	50                   	push   %eax
  801523:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801526:	ff 30                	pushl  (%eax)
  801528:	e8 e8 fc ff ff       	call   801215 <dev_lookup>
  80152d:	83 c4 10             	add    $0x10,%esp
  801530:	85 c0                	test   %eax,%eax
  801532:	78 47                	js     80157b <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801534:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801537:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80153b:	75 21                	jne    80155e <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80153d:	a1 04 40 80 00       	mov    0x804004,%eax
  801542:	8b 40 48             	mov    0x48(%eax),%eax
  801545:	83 ec 04             	sub    $0x4,%esp
  801548:	53                   	push   %ebx
  801549:	50                   	push   %eax
  80154a:	68 00 26 80 00       	push   $0x802600
  80154f:	e8 dd ec ff ff       	call   800231 <cprintf>
		return -E_INVAL;
  801554:	83 c4 10             	add    $0x10,%esp
  801557:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80155c:	eb 26                	jmp    801584 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80155e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801561:	8b 52 0c             	mov    0xc(%edx),%edx
  801564:	85 d2                	test   %edx,%edx
  801566:	74 17                	je     80157f <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801568:	83 ec 04             	sub    $0x4,%esp
  80156b:	ff 75 10             	pushl  0x10(%ebp)
  80156e:	ff 75 0c             	pushl  0xc(%ebp)
  801571:	50                   	push   %eax
  801572:	ff d2                	call   *%edx
  801574:	89 c2                	mov    %eax,%edx
  801576:	83 c4 10             	add    $0x10,%esp
  801579:	eb 09                	jmp    801584 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80157b:	89 c2                	mov    %eax,%edx
  80157d:	eb 05                	jmp    801584 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80157f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801584:	89 d0                	mov    %edx,%eax
  801586:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801589:	c9                   	leave  
  80158a:	c3                   	ret    

0080158b <seek>:

int
seek(int fdnum, off_t offset)
{
  80158b:	55                   	push   %ebp
  80158c:	89 e5                	mov    %esp,%ebp
  80158e:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801591:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801594:	50                   	push   %eax
  801595:	ff 75 08             	pushl  0x8(%ebp)
  801598:	e8 22 fc ff ff       	call   8011bf <fd_lookup>
  80159d:	83 c4 08             	add    $0x8,%esp
  8015a0:	85 c0                	test   %eax,%eax
  8015a2:	78 0e                	js     8015b2 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015a4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015aa:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015ad:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015b2:	c9                   	leave  
  8015b3:	c3                   	ret    

008015b4 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015b4:	55                   	push   %ebp
  8015b5:	89 e5                	mov    %esp,%ebp
  8015b7:	53                   	push   %ebx
  8015b8:	83 ec 14             	sub    $0x14,%esp
  8015bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015be:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015c1:	50                   	push   %eax
  8015c2:	53                   	push   %ebx
  8015c3:	e8 f7 fb ff ff       	call   8011bf <fd_lookup>
  8015c8:	83 c4 08             	add    $0x8,%esp
  8015cb:	89 c2                	mov    %eax,%edx
  8015cd:	85 c0                	test   %eax,%eax
  8015cf:	78 65                	js     801636 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015d1:	83 ec 08             	sub    $0x8,%esp
  8015d4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015d7:	50                   	push   %eax
  8015d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015db:	ff 30                	pushl  (%eax)
  8015dd:	e8 33 fc ff ff       	call   801215 <dev_lookup>
  8015e2:	83 c4 10             	add    $0x10,%esp
  8015e5:	85 c0                	test   %eax,%eax
  8015e7:	78 44                	js     80162d <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ec:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015f0:	75 21                	jne    801613 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015f2:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015f7:	8b 40 48             	mov    0x48(%eax),%eax
  8015fa:	83 ec 04             	sub    $0x4,%esp
  8015fd:	53                   	push   %ebx
  8015fe:	50                   	push   %eax
  8015ff:	68 c0 25 80 00       	push   $0x8025c0
  801604:	e8 28 ec ff ff       	call   800231 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801609:	83 c4 10             	add    $0x10,%esp
  80160c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801611:	eb 23                	jmp    801636 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801613:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801616:	8b 52 18             	mov    0x18(%edx),%edx
  801619:	85 d2                	test   %edx,%edx
  80161b:	74 14                	je     801631 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80161d:	83 ec 08             	sub    $0x8,%esp
  801620:	ff 75 0c             	pushl  0xc(%ebp)
  801623:	50                   	push   %eax
  801624:	ff d2                	call   *%edx
  801626:	89 c2                	mov    %eax,%edx
  801628:	83 c4 10             	add    $0x10,%esp
  80162b:	eb 09                	jmp    801636 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80162d:	89 c2                	mov    %eax,%edx
  80162f:	eb 05                	jmp    801636 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801631:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801636:	89 d0                	mov    %edx,%eax
  801638:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80163b:	c9                   	leave  
  80163c:	c3                   	ret    

0080163d <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80163d:	55                   	push   %ebp
  80163e:	89 e5                	mov    %esp,%ebp
  801640:	53                   	push   %ebx
  801641:	83 ec 14             	sub    $0x14,%esp
  801644:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801647:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80164a:	50                   	push   %eax
  80164b:	ff 75 08             	pushl  0x8(%ebp)
  80164e:	e8 6c fb ff ff       	call   8011bf <fd_lookup>
  801653:	83 c4 08             	add    $0x8,%esp
  801656:	89 c2                	mov    %eax,%edx
  801658:	85 c0                	test   %eax,%eax
  80165a:	78 58                	js     8016b4 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80165c:	83 ec 08             	sub    $0x8,%esp
  80165f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801662:	50                   	push   %eax
  801663:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801666:	ff 30                	pushl  (%eax)
  801668:	e8 a8 fb ff ff       	call   801215 <dev_lookup>
  80166d:	83 c4 10             	add    $0x10,%esp
  801670:	85 c0                	test   %eax,%eax
  801672:	78 37                	js     8016ab <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801674:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801677:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80167b:	74 32                	je     8016af <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80167d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801680:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801687:	00 00 00 
	stat->st_isdir = 0;
  80168a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801691:	00 00 00 
	stat->st_dev = dev;
  801694:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80169a:	83 ec 08             	sub    $0x8,%esp
  80169d:	53                   	push   %ebx
  80169e:	ff 75 f0             	pushl  -0x10(%ebp)
  8016a1:	ff 50 14             	call   *0x14(%eax)
  8016a4:	89 c2                	mov    %eax,%edx
  8016a6:	83 c4 10             	add    $0x10,%esp
  8016a9:	eb 09                	jmp    8016b4 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ab:	89 c2                	mov    %eax,%edx
  8016ad:	eb 05                	jmp    8016b4 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016af:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016b4:	89 d0                	mov    %edx,%eax
  8016b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016b9:	c9                   	leave  
  8016ba:	c3                   	ret    

008016bb <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016bb:	55                   	push   %ebp
  8016bc:	89 e5                	mov    %esp,%ebp
  8016be:	56                   	push   %esi
  8016bf:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016c0:	83 ec 08             	sub    $0x8,%esp
  8016c3:	6a 00                	push   $0x0
  8016c5:	ff 75 08             	pushl  0x8(%ebp)
  8016c8:	e8 0c 02 00 00       	call   8018d9 <open>
  8016cd:	89 c3                	mov    %eax,%ebx
  8016cf:	83 c4 10             	add    $0x10,%esp
  8016d2:	85 c0                	test   %eax,%eax
  8016d4:	78 1b                	js     8016f1 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016d6:	83 ec 08             	sub    $0x8,%esp
  8016d9:	ff 75 0c             	pushl  0xc(%ebp)
  8016dc:	50                   	push   %eax
  8016dd:	e8 5b ff ff ff       	call   80163d <fstat>
  8016e2:	89 c6                	mov    %eax,%esi
	close(fd);
  8016e4:	89 1c 24             	mov    %ebx,(%esp)
  8016e7:	e8 fd fb ff ff       	call   8012e9 <close>
	return r;
  8016ec:	83 c4 10             	add    $0x10,%esp
  8016ef:	89 f0                	mov    %esi,%eax
}
  8016f1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016f4:	5b                   	pop    %ebx
  8016f5:	5e                   	pop    %esi
  8016f6:	5d                   	pop    %ebp
  8016f7:	c3                   	ret    

008016f8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016f8:	55                   	push   %ebp
  8016f9:	89 e5                	mov    %esp,%ebp
  8016fb:	56                   	push   %esi
  8016fc:	53                   	push   %ebx
  8016fd:	89 c6                	mov    %eax,%esi
  8016ff:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801701:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801708:	75 12                	jne    80171c <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80170a:	83 ec 0c             	sub    $0xc,%esp
  80170d:	6a 01                	push   $0x1
  80170f:	e8 fc f9 ff ff       	call   801110 <ipc_find_env>
  801714:	a3 00 40 80 00       	mov    %eax,0x804000
  801719:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80171c:	6a 07                	push   $0x7
  80171e:	68 00 50 80 00       	push   $0x805000
  801723:	56                   	push   %esi
  801724:	ff 35 00 40 80 00    	pushl  0x804000
  80172a:	e8 8d f9 ff ff       	call   8010bc <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80172f:	83 c4 0c             	add    $0xc,%esp
  801732:	6a 00                	push   $0x0
  801734:	53                   	push   %ebx
  801735:	6a 00                	push   $0x0
  801737:	e8 17 f9 ff ff       	call   801053 <ipc_recv>
}
  80173c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80173f:	5b                   	pop    %ebx
  801740:	5e                   	pop    %esi
  801741:	5d                   	pop    %ebp
  801742:	c3                   	ret    

00801743 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801743:	55                   	push   %ebp
  801744:	89 e5                	mov    %esp,%ebp
  801746:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801749:	8b 45 08             	mov    0x8(%ebp),%eax
  80174c:	8b 40 0c             	mov    0xc(%eax),%eax
  80174f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801754:	8b 45 0c             	mov    0xc(%ebp),%eax
  801757:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80175c:	ba 00 00 00 00       	mov    $0x0,%edx
  801761:	b8 02 00 00 00       	mov    $0x2,%eax
  801766:	e8 8d ff ff ff       	call   8016f8 <fsipc>
}
  80176b:	c9                   	leave  
  80176c:	c3                   	ret    

0080176d <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80176d:	55                   	push   %ebp
  80176e:	89 e5                	mov    %esp,%ebp
  801770:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801773:	8b 45 08             	mov    0x8(%ebp),%eax
  801776:	8b 40 0c             	mov    0xc(%eax),%eax
  801779:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80177e:	ba 00 00 00 00       	mov    $0x0,%edx
  801783:	b8 06 00 00 00       	mov    $0x6,%eax
  801788:	e8 6b ff ff ff       	call   8016f8 <fsipc>
}
  80178d:	c9                   	leave  
  80178e:	c3                   	ret    

0080178f <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80178f:	55                   	push   %ebp
  801790:	89 e5                	mov    %esp,%ebp
  801792:	53                   	push   %ebx
  801793:	83 ec 04             	sub    $0x4,%esp
  801796:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801799:	8b 45 08             	mov    0x8(%ebp),%eax
  80179c:	8b 40 0c             	mov    0xc(%eax),%eax
  80179f:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017a4:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a9:	b8 05 00 00 00       	mov    $0x5,%eax
  8017ae:	e8 45 ff ff ff       	call   8016f8 <fsipc>
  8017b3:	85 c0                	test   %eax,%eax
  8017b5:	78 2c                	js     8017e3 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017b7:	83 ec 08             	sub    $0x8,%esp
  8017ba:	68 00 50 80 00       	push   $0x805000
  8017bf:	53                   	push   %ebx
  8017c0:	e8 f1 ef ff ff       	call   8007b6 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017c5:	a1 80 50 80 00       	mov    0x805080,%eax
  8017ca:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017d0:	a1 84 50 80 00       	mov    0x805084,%eax
  8017d5:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017db:	83 c4 10             	add    $0x10,%esp
  8017de:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017e6:	c9                   	leave  
  8017e7:	c3                   	ret    

008017e8 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017e8:	55                   	push   %ebp
  8017e9:	89 e5                	mov    %esp,%ebp
  8017eb:	53                   	push   %ebx
  8017ec:	83 ec 08             	sub    $0x8,%esp
  8017ef:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8017f5:	8b 52 0c             	mov    0xc(%edx),%edx
  8017f8:	89 15 00 50 80 00    	mov    %edx,0x805000
  8017fe:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801803:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  801808:	0f 46 d8             	cmovbe %eax,%ebx
	
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  80180b:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  801811:	53                   	push   %ebx
  801812:	ff 75 0c             	pushl  0xc(%ebp)
  801815:	68 08 50 80 00       	push   $0x805008
  80181a:	e8 29 f1 ff ff       	call   800948 <memmove>

	
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) 
  80181f:	ba 00 00 00 00       	mov    $0x0,%edx
  801824:	b8 04 00 00 00       	mov    $0x4,%eax
  801829:	e8 ca fe ff ff       	call   8016f8 <fsipc>
  80182e:	83 c4 10             	add    $0x10,%esp
  801831:	85 c0                	test   %eax,%eax
  801833:	78 1d                	js     801852 <devfile_write+0x6a>
		return r;
	assert(r <= n_real); 
  801835:	39 d8                	cmp    %ebx,%eax
  801837:	76 19                	jbe    801852 <devfile_write+0x6a>
  801839:	68 30 26 80 00       	push   $0x802630
  80183e:	68 3c 26 80 00       	push   $0x80263c
  801843:	68 a3 00 00 00       	push   $0xa3
  801848:	68 51 26 80 00       	push   $0x802651
  80184d:	e8 06 e9 ff ff       	call   800158 <_panic>
	return r;
}
  801852:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801855:	c9                   	leave  
  801856:	c3                   	ret    

00801857 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801857:	55                   	push   %ebp
  801858:	89 e5                	mov    %esp,%ebp
  80185a:	56                   	push   %esi
  80185b:	53                   	push   %ebx
  80185c:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80185f:	8b 45 08             	mov    0x8(%ebp),%eax
  801862:	8b 40 0c             	mov    0xc(%eax),%eax
  801865:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80186a:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801870:	ba 00 00 00 00       	mov    $0x0,%edx
  801875:	b8 03 00 00 00       	mov    $0x3,%eax
  80187a:	e8 79 fe ff ff       	call   8016f8 <fsipc>
  80187f:	89 c3                	mov    %eax,%ebx
  801881:	85 c0                	test   %eax,%eax
  801883:	78 4b                	js     8018d0 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801885:	39 c6                	cmp    %eax,%esi
  801887:	73 16                	jae    80189f <devfile_read+0x48>
  801889:	68 5c 26 80 00       	push   $0x80265c
  80188e:	68 3c 26 80 00       	push   $0x80263c
  801893:	6a 7c                	push   $0x7c
  801895:	68 51 26 80 00       	push   $0x802651
  80189a:	e8 b9 e8 ff ff       	call   800158 <_panic>
	assert(r <= PGSIZE);
  80189f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018a4:	7e 16                	jle    8018bc <devfile_read+0x65>
  8018a6:	68 63 26 80 00       	push   $0x802663
  8018ab:	68 3c 26 80 00       	push   $0x80263c
  8018b0:	6a 7d                	push   $0x7d
  8018b2:	68 51 26 80 00       	push   $0x802651
  8018b7:	e8 9c e8 ff ff       	call   800158 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018bc:	83 ec 04             	sub    $0x4,%esp
  8018bf:	50                   	push   %eax
  8018c0:	68 00 50 80 00       	push   $0x805000
  8018c5:	ff 75 0c             	pushl  0xc(%ebp)
  8018c8:	e8 7b f0 ff ff       	call   800948 <memmove>
	return r;
  8018cd:	83 c4 10             	add    $0x10,%esp
}
  8018d0:	89 d8                	mov    %ebx,%eax
  8018d2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018d5:	5b                   	pop    %ebx
  8018d6:	5e                   	pop    %esi
  8018d7:	5d                   	pop    %ebp
  8018d8:	c3                   	ret    

008018d9 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018d9:	55                   	push   %ebp
  8018da:	89 e5                	mov    %esp,%ebp
  8018dc:	53                   	push   %ebx
  8018dd:	83 ec 20             	sub    $0x20,%esp
  8018e0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018e3:	53                   	push   %ebx
  8018e4:	e8 94 ee ff ff       	call   80077d <strlen>
  8018e9:	83 c4 10             	add    $0x10,%esp
  8018ec:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018f1:	7f 67                	jg     80195a <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018f3:	83 ec 0c             	sub    $0xc,%esp
  8018f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018f9:	50                   	push   %eax
  8018fa:	e8 71 f8 ff ff       	call   801170 <fd_alloc>
  8018ff:	83 c4 10             	add    $0x10,%esp
		return r;
  801902:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801904:	85 c0                	test   %eax,%eax
  801906:	78 57                	js     80195f <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801908:	83 ec 08             	sub    $0x8,%esp
  80190b:	53                   	push   %ebx
  80190c:	68 00 50 80 00       	push   $0x805000
  801911:	e8 a0 ee ff ff       	call   8007b6 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801916:	8b 45 0c             	mov    0xc(%ebp),%eax
  801919:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80191e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801921:	b8 01 00 00 00       	mov    $0x1,%eax
  801926:	e8 cd fd ff ff       	call   8016f8 <fsipc>
  80192b:	89 c3                	mov    %eax,%ebx
  80192d:	83 c4 10             	add    $0x10,%esp
  801930:	85 c0                	test   %eax,%eax
  801932:	79 14                	jns    801948 <open+0x6f>
		fd_close(fd, 0);
  801934:	83 ec 08             	sub    $0x8,%esp
  801937:	6a 00                	push   $0x0
  801939:	ff 75 f4             	pushl  -0xc(%ebp)
  80193c:	e8 27 f9 ff ff       	call   801268 <fd_close>
		return r;
  801941:	83 c4 10             	add    $0x10,%esp
  801944:	89 da                	mov    %ebx,%edx
  801946:	eb 17                	jmp    80195f <open+0x86>
	}

	return fd2num(fd);
  801948:	83 ec 0c             	sub    $0xc,%esp
  80194b:	ff 75 f4             	pushl  -0xc(%ebp)
  80194e:	e8 f6 f7 ff ff       	call   801149 <fd2num>
  801953:	89 c2                	mov    %eax,%edx
  801955:	83 c4 10             	add    $0x10,%esp
  801958:	eb 05                	jmp    80195f <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80195a:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80195f:	89 d0                	mov    %edx,%eax
  801961:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801964:	c9                   	leave  
  801965:	c3                   	ret    

00801966 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801966:	55                   	push   %ebp
  801967:	89 e5                	mov    %esp,%ebp
  801969:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80196c:	ba 00 00 00 00       	mov    $0x0,%edx
  801971:	b8 08 00 00 00       	mov    $0x8,%eax
  801976:	e8 7d fd ff ff       	call   8016f8 <fsipc>
}
  80197b:	c9                   	leave  
  80197c:	c3                   	ret    

0080197d <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80197d:	55                   	push   %ebp
  80197e:	89 e5                	mov    %esp,%ebp
  801980:	56                   	push   %esi
  801981:	53                   	push   %ebx
  801982:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801985:	83 ec 0c             	sub    $0xc,%esp
  801988:	ff 75 08             	pushl  0x8(%ebp)
  80198b:	e8 c9 f7 ff ff       	call   801159 <fd2data>
  801990:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801992:	83 c4 08             	add    $0x8,%esp
  801995:	68 6f 26 80 00       	push   $0x80266f
  80199a:	53                   	push   %ebx
  80199b:	e8 16 ee ff ff       	call   8007b6 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019a0:	8b 46 04             	mov    0x4(%esi),%eax
  8019a3:	2b 06                	sub    (%esi),%eax
  8019a5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019ab:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019b2:	00 00 00 
	stat->st_dev = &devpipe;
  8019b5:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8019bc:	30 80 00 
	return 0;
}
  8019bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8019c4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019c7:	5b                   	pop    %ebx
  8019c8:	5e                   	pop    %esi
  8019c9:	5d                   	pop    %ebp
  8019ca:	c3                   	ret    

008019cb <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019cb:	55                   	push   %ebp
  8019cc:	89 e5                	mov    %esp,%ebp
  8019ce:	53                   	push   %ebx
  8019cf:	83 ec 0c             	sub    $0xc,%esp
  8019d2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019d5:	53                   	push   %ebx
  8019d6:	6a 00                	push   $0x0
  8019d8:	e8 61 f2 ff ff       	call   800c3e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019dd:	89 1c 24             	mov    %ebx,(%esp)
  8019e0:	e8 74 f7 ff ff       	call   801159 <fd2data>
  8019e5:	83 c4 08             	add    $0x8,%esp
  8019e8:	50                   	push   %eax
  8019e9:	6a 00                	push   $0x0
  8019eb:	e8 4e f2 ff ff       	call   800c3e <sys_page_unmap>
}
  8019f0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019f3:	c9                   	leave  
  8019f4:	c3                   	ret    

008019f5 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8019f5:	55                   	push   %ebp
  8019f6:	89 e5                	mov    %esp,%ebp
  8019f8:	57                   	push   %edi
  8019f9:	56                   	push   %esi
  8019fa:	53                   	push   %ebx
  8019fb:	83 ec 1c             	sub    $0x1c,%esp
  8019fe:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a01:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a03:	a1 04 40 80 00       	mov    0x804004,%eax
  801a08:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a0b:	83 ec 0c             	sub    $0xc,%esp
  801a0e:	ff 75 e0             	pushl  -0x20(%ebp)
  801a11:	e8 bc 04 00 00       	call   801ed2 <pageref>
  801a16:	89 c3                	mov    %eax,%ebx
  801a18:	89 3c 24             	mov    %edi,(%esp)
  801a1b:	e8 b2 04 00 00       	call   801ed2 <pageref>
  801a20:	83 c4 10             	add    $0x10,%esp
  801a23:	39 c3                	cmp    %eax,%ebx
  801a25:	0f 94 c1             	sete   %cl
  801a28:	0f b6 c9             	movzbl %cl,%ecx
  801a2b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a2e:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a34:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a37:	39 ce                	cmp    %ecx,%esi
  801a39:	74 1b                	je     801a56 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a3b:	39 c3                	cmp    %eax,%ebx
  801a3d:	75 c4                	jne    801a03 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a3f:	8b 42 58             	mov    0x58(%edx),%eax
  801a42:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a45:	50                   	push   %eax
  801a46:	56                   	push   %esi
  801a47:	68 76 26 80 00       	push   $0x802676
  801a4c:	e8 e0 e7 ff ff       	call   800231 <cprintf>
  801a51:	83 c4 10             	add    $0x10,%esp
  801a54:	eb ad                	jmp    801a03 <_pipeisclosed+0xe>
	}
}
  801a56:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a59:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a5c:	5b                   	pop    %ebx
  801a5d:	5e                   	pop    %esi
  801a5e:	5f                   	pop    %edi
  801a5f:	5d                   	pop    %ebp
  801a60:	c3                   	ret    

00801a61 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a61:	55                   	push   %ebp
  801a62:	89 e5                	mov    %esp,%ebp
  801a64:	57                   	push   %edi
  801a65:	56                   	push   %esi
  801a66:	53                   	push   %ebx
  801a67:	83 ec 28             	sub    $0x28,%esp
  801a6a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a6d:	56                   	push   %esi
  801a6e:	e8 e6 f6 ff ff       	call   801159 <fd2data>
  801a73:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a75:	83 c4 10             	add    $0x10,%esp
  801a78:	bf 00 00 00 00       	mov    $0x0,%edi
  801a7d:	eb 4b                	jmp    801aca <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a7f:	89 da                	mov    %ebx,%edx
  801a81:	89 f0                	mov    %esi,%eax
  801a83:	e8 6d ff ff ff       	call   8019f5 <_pipeisclosed>
  801a88:	85 c0                	test   %eax,%eax
  801a8a:	75 48                	jne    801ad4 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a8c:	e8 09 f1 ff ff       	call   800b9a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a91:	8b 43 04             	mov    0x4(%ebx),%eax
  801a94:	8b 0b                	mov    (%ebx),%ecx
  801a96:	8d 51 20             	lea    0x20(%ecx),%edx
  801a99:	39 d0                	cmp    %edx,%eax
  801a9b:	73 e2                	jae    801a7f <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801aa0:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801aa4:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801aa7:	89 c2                	mov    %eax,%edx
  801aa9:	c1 fa 1f             	sar    $0x1f,%edx
  801aac:	89 d1                	mov    %edx,%ecx
  801aae:	c1 e9 1b             	shr    $0x1b,%ecx
  801ab1:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801ab4:	83 e2 1f             	and    $0x1f,%edx
  801ab7:	29 ca                	sub    %ecx,%edx
  801ab9:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801abd:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ac1:	83 c0 01             	add    $0x1,%eax
  801ac4:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ac7:	83 c7 01             	add    $0x1,%edi
  801aca:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801acd:	75 c2                	jne    801a91 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801acf:	8b 45 10             	mov    0x10(%ebp),%eax
  801ad2:	eb 05                	jmp    801ad9 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ad4:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ad9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801adc:	5b                   	pop    %ebx
  801add:	5e                   	pop    %esi
  801ade:	5f                   	pop    %edi
  801adf:	5d                   	pop    %ebp
  801ae0:	c3                   	ret    

00801ae1 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ae1:	55                   	push   %ebp
  801ae2:	89 e5                	mov    %esp,%ebp
  801ae4:	57                   	push   %edi
  801ae5:	56                   	push   %esi
  801ae6:	53                   	push   %ebx
  801ae7:	83 ec 18             	sub    $0x18,%esp
  801aea:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801aed:	57                   	push   %edi
  801aee:	e8 66 f6 ff ff       	call   801159 <fd2data>
  801af3:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801af5:	83 c4 10             	add    $0x10,%esp
  801af8:	bb 00 00 00 00       	mov    $0x0,%ebx
  801afd:	eb 3d                	jmp    801b3c <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801aff:	85 db                	test   %ebx,%ebx
  801b01:	74 04                	je     801b07 <devpipe_read+0x26>
				return i;
  801b03:	89 d8                	mov    %ebx,%eax
  801b05:	eb 44                	jmp    801b4b <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b07:	89 f2                	mov    %esi,%edx
  801b09:	89 f8                	mov    %edi,%eax
  801b0b:	e8 e5 fe ff ff       	call   8019f5 <_pipeisclosed>
  801b10:	85 c0                	test   %eax,%eax
  801b12:	75 32                	jne    801b46 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b14:	e8 81 f0 ff ff       	call   800b9a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b19:	8b 06                	mov    (%esi),%eax
  801b1b:	3b 46 04             	cmp    0x4(%esi),%eax
  801b1e:	74 df                	je     801aff <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b20:	99                   	cltd   
  801b21:	c1 ea 1b             	shr    $0x1b,%edx
  801b24:	01 d0                	add    %edx,%eax
  801b26:	83 e0 1f             	and    $0x1f,%eax
  801b29:	29 d0                	sub    %edx,%eax
  801b2b:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b33:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b36:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b39:	83 c3 01             	add    $0x1,%ebx
  801b3c:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b3f:	75 d8                	jne    801b19 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b41:	8b 45 10             	mov    0x10(%ebp),%eax
  801b44:	eb 05                	jmp    801b4b <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b46:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b4b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b4e:	5b                   	pop    %ebx
  801b4f:	5e                   	pop    %esi
  801b50:	5f                   	pop    %edi
  801b51:	5d                   	pop    %ebp
  801b52:	c3                   	ret    

00801b53 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b53:	55                   	push   %ebp
  801b54:	89 e5                	mov    %esp,%ebp
  801b56:	56                   	push   %esi
  801b57:	53                   	push   %ebx
  801b58:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b5b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b5e:	50                   	push   %eax
  801b5f:	e8 0c f6 ff ff       	call   801170 <fd_alloc>
  801b64:	83 c4 10             	add    $0x10,%esp
  801b67:	89 c2                	mov    %eax,%edx
  801b69:	85 c0                	test   %eax,%eax
  801b6b:	0f 88 2c 01 00 00    	js     801c9d <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b71:	83 ec 04             	sub    $0x4,%esp
  801b74:	68 07 04 00 00       	push   $0x407
  801b79:	ff 75 f4             	pushl  -0xc(%ebp)
  801b7c:	6a 00                	push   $0x0
  801b7e:	e8 36 f0 ff ff       	call   800bb9 <sys_page_alloc>
  801b83:	83 c4 10             	add    $0x10,%esp
  801b86:	89 c2                	mov    %eax,%edx
  801b88:	85 c0                	test   %eax,%eax
  801b8a:	0f 88 0d 01 00 00    	js     801c9d <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b90:	83 ec 0c             	sub    $0xc,%esp
  801b93:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b96:	50                   	push   %eax
  801b97:	e8 d4 f5 ff ff       	call   801170 <fd_alloc>
  801b9c:	89 c3                	mov    %eax,%ebx
  801b9e:	83 c4 10             	add    $0x10,%esp
  801ba1:	85 c0                	test   %eax,%eax
  801ba3:	0f 88 e2 00 00 00    	js     801c8b <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ba9:	83 ec 04             	sub    $0x4,%esp
  801bac:	68 07 04 00 00       	push   $0x407
  801bb1:	ff 75 f0             	pushl  -0x10(%ebp)
  801bb4:	6a 00                	push   $0x0
  801bb6:	e8 fe ef ff ff       	call   800bb9 <sys_page_alloc>
  801bbb:	89 c3                	mov    %eax,%ebx
  801bbd:	83 c4 10             	add    $0x10,%esp
  801bc0:	85 c0                	test   %eax,%eax
  801bc2:	0f 88 c3 00 00 00    	js     801c8b <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801bc8:	83 ec 0c             	sub    $0xc,%esp
  801bcb:	ff 75 f4             	pushl  -0xc(%ebp)
  801bce:	e8 86 f5 ff ff       	call   801159 <fd2data>
  801bd3:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bd5:	83 c4 0c             	add    $0xc,%esp
  801bd8:	68 07 04 00 00       	push   $0x407
  801bdd:	50                   	push   %eax
  801bde:	6a 00                	push   $0x0
  801be0:	e8 d4 ef ff ff       	call   800bb9 <sys_page_alloc>
  801be5:	89 c3                	mov    %eax,%ebx
  801be7:	83 c4 10             	add    $0x10,%esp
  801bea:	85 c0                	test   %eax,%eax
  801bec:	0f 88 89 00 00 00    	js     801c7b <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bf2:	83 ec 0c             	sub    $0xc,%esp
  801bf5:	ff 75 f0             	pushl  -0x10(%ebp)
  801bf8:	e8 5c f5 ff ff       	call   801159 <fd2data>
  801bfd:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c04:	50                   	push   %eax
  801c05:	6a 00                	push   $0x0
  801c07:	56                   	push   %esi
  801c08:	6a 00                	push   $0x0
  801c0a:	e8 ed ef ff ff       	call   800bfc <sys_page_map>
  801c0f:	89 c3                	mov    %eax,%ebx
  801c11:	83 c4 20             	add    $0x20,%esp
  801c14:	85 c0                	test   %eax,%eax
  801c16:	78 55                	js     801c6d <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c18:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c21:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c23:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c26:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c2d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c33:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c36:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c38:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c3b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c42:	83 ec 0c             	sub    $0xc,%esp
  801c45:	ff 75 f4             	pushl  -0xc(%ebp)
  801c48:	e8 fc f4 ff ff       	call   801149 <fd2num>
  801c4d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c50:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c52:	83 c4 04             	add    $0x4,%esp
  801c55:	ff 75 f0             	pushl  -0x10(%ebp)
  801c58:	e8 ec f4 ff ff       	call   801149 <fd2num>
  801c5d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c60:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c63:	83 c4 10             	add    $0x10,%esp
  801c66:	ba 00 00 00 00       	mov    $0x0,%edx
  801c6b:	eb 30                	jmp    801c9d <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c6d:	83 ec 08             	sub    $0x8,%esp
  801c70:	56                   	push   %esi
  801c71:	6a 00                	push   $0x0
  801c73:	e8 c6 ef ff ff       	call   800c3e <sys_page_unmap>
  801c78:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c7b:	83 ec 08             	sub    $0x8,%esp
  801c7e:	ff 75 f0             	pushl  -0x10(%ebp)
  801c81:	6a 00                	push   $0x0
  801c83:	e8 b6 ef ff ff       	call   800c3e <sys_page_unmap>
  801c88:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c8b:	83 ec 08             	sub    $0x8,%esp
  801c8e:	ff 75 f4             	pushl  -0xc(%ebp)
  801c91:	6a 00                	push   $0x0
  801c93:	e8 a6 ef ff ff       	call   800c3e <sys_page_unmap>
  801c98:	83 c4 10             	add    $0x10,%esp
  801c9b:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801c9d:	89 d0                	mov    %edx,%eax
  801c9f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ca2:	5b                   	pop    %ebx
  801ca3:	5e                   	pop    %esi
  801ca4:	5d                   	pop    %ebp
  801ca5:	c3                   	ret    

00801ca6 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801ca6:	55                   	push   %ebp
  801ca7:	89 e5                	mov    %esp,%ebp
  801ca9:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801caf:	50                   	push   %eax
  801cb0:	ff 75 08             	pushl  0x8(%ebp)
  801cb3:	e8 07 f5 ff ff       	call   8011bf <fd_lookup>
  801cb8:	83 c4 10             	add    $0x10,%esp
  801cbb:	85 c0                	test   %eax,%eax
  801cbd:	78 18                	js     801cd7 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801cbf:	83 ec 0c             	sub    $0xc,%esp
  801cc2:	ff 75 f4             	pushl  -0xc(%ebp)
  801cc5:	e8 8f f4 ff ff       	call   801159 <fd2data>
	return _pipeisclosed(fd, p);
  801cca:	89 c2                	mov    %eax,%edx
  801ccc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ccf:	e8 21 fd ff ff       	call   8019f5 <_pipeisclosed>
  801cd4:	83 c4 10             	add    $0x10,%esp
}
  801cd7:	c9                   	leave  
  801cd8:	c3                   	ret    

00801cd9 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801cd9:	55                   	push   %ebp
  801cda:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801cdc:	b8 00 00 00 00       	mov    $0x0,%eax
  801ce1:	5d                   	pop    %ebp
  801ce2:	c3                   	ret    

00801ce3 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ce3:	55                   	push   %ebp
  801ce4:	89 e5                	mov    %esp,%ebp
  801ce6:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801ce9:	68 8e 26 80 00       	push   $0x80268e
  801cee:	ff 75 0c             	pushl  0xc(%ebp)
  801cf1:	e8 c0 ea ff ff       	call   8007b6 <strcpy>
	return 0;
}
  801cf6:	b8 00 00 00 00       	mov    $0x0,%eax
  801cfb:	c9                   	leave  
  801cfc:	c3                   	ret    

00801cfd <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801cfd:	55                   	push   %ebp
  801cfe:	89 e5                	mov    %esp,%ebp
  801d00:	57                   	push   %edi
  801d01:	56                   	push   %esi
  801d02:	53                   	push   %ebx
  801d03:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d09:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d0e:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d14:	eb 2d                	jmp    801d43 <devcons_write+0x46>
		m = n - tot;
  801d16:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d19:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d1b:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d1e:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d23:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d26:	83 ec 04             	sub    $0x4,%esp
  801d29:	53                   	push   %ebx
  801d2a:	03 45 0c             	add    0xc(%ebp),%eax
  801d2d:	50                   	push   %eax
  801d2e:	57                   	push   %edi
  801d2f:	e8 14 ec ff ff       	call   800948 <memmove>
		sys_cputs(buf, m);
  801d34:	83 c4 08             	add    $0x8,%esp
  801d37:	53                   	push   %ebx
  801d38:	57                   	push   %edi
  801d39:	e8 bf ed ff ff       	call   800afd <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d3e:	01 de                	add    %ebx,%esi
  801d40:	83 c4 10             	add    $0x10,%esp
  801d43:	89 f0                	mov    %esi,%eax
  801d45:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d48:	72 cc                	jb     801d16 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d4d:	5b                   	pop    %ebx
  801d4e:	5e                   	pop    %esi
  801d4f:	5f                   	pop    %edi
  801d50:	5d                   	pop    %ebp
  801d51:	c3                   	ret    

00801d52 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d52:	55                   	push   %ebp
  801d53:	89 e5                	mov    %esp,%ebp
  801d55:	83 ec 08             	sub    $0x8,%esp
  801d58:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801d5d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d61:	74 2a                	je     801d8d <devcons_read+0x3b>
  801d63:	eb 05                	jmp    801d6a <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d65:	e8 30 ee ff ff       	call   800b9a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d6a:	e8 ac ed ff ff       	call   800b1b <sys_cgetc>
  801d6f:	85 c0                	test   %eax,%eax
  801d71:	74 f2                	je     801d65 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801d73:	85 c0                	test   %eax,%eax
  801d75:	78 16                	js     801d8d <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d77:	83 f8 04             	cmp    $0x4,%eax
  801d7a:	74 0c                	je     801d88 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801d7c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d7f:	88 02                	mov    %al,(%edx)
	return 1;
  801d81:	b8 01 00 00 00       	mov    $0x1,%eax
  801d86:	eb 05                	jmp    801d8d <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801d88:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801d8d:	c9                   	leave  
  801d8e:	c3                   	ret    

00801d8f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801d8f:	55                   	push   %ebp
  801d90:	89 e5                	mov    %esp,%ebp
  801d92:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801d95:	8b 45 08             	mov    0x8(%ebp),%eax
  801d98:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801d9b:	6a 01                	push   $0x1
  801d9d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801da0:	50                   	push   %eax
  801da1:	e8 57 ed ff ff       	call   800afd <sys_cputs>
}
  801da6:	83 c4 10             	add    $0x10,%esp
  801da9:	c9                   	leave  
  801daa:	c3                   	ret    

00801dab <getchar>:

int
getchar(void)
{
  801dab:	55                   	push   %ebp
  801dac:	89 e5                	mov    %esp,%ebp
  801dae:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801db1:	6a 01                	push   $0x1
  801db3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801db6:	50                   	push   %eax
  801db7:	6a 00                	push   $0x0
  801db9:	e8 67 f6 ff ff       	call   801425 <read>
	if (r < 0)
  801dbe:	83 c4 10             	add    $0x10,%esp
  801dc1:	85 c0                	test   %eax,%eax
  801dc3:	78 0f                	js     801dd4 <getchar+0x29>
		return r;
	if (r < 1)
  801dc5:	85 c0                	test   %eax,%eax
  801dc7:	7e 06                	jle    801dcf <getchar+0x24>
		return -E_EOF;
	return c;
  801dc9:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801dcd:	eb 05                	jmp    801dd4 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801dcf:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801dd4:	c9                   	leave  
  801dd5:	c3                   	ret    

00801dd6 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801dd6:	55                   	push   %ebp
  801dd7:	89 e5                	mov    %esp,%ebp
  801dd9:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ddc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ddf:	50                   	push   %eax
  801de0:	ff 75 08             	pushl  0x8(%ebp)
  801de3:	e8 d7 f3 ff ff       	call   8011bf <fd_lookup>
  801de8:	83 c4 10             	add    $0x10,%esp
  801deb:	85 c0                	test   %eax,%eax
  801ded:	78 11                	js     801e00 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801def:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801df2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801df8:	39 10                	cmp    %edx,(%eax)
  801dfa:	0f 94 c0             	sete   %al
  801dfd:	0f b6 c0             	movzbl %al,%eax
}
  801e00:	c9                   	leave  
  801e01:	c3                   	ret    

00801e02 <opencons>:

int
opencons(void)
{
  801e02:	55                   	push   %ebp
  801e03:	89 e5                	mov    %esp,%ebp
  801e05:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e08:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e0b:	50                   	push   %eax
  801e0c:	e8 5f f3 ff ff       	call   801170 <fd_alloc>
  801e11:	83 c4 10             	add    $0x10,%esp
		return r;
  801e14:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e16:	85 c0                	test   %eax,%eax
  801e18:	78 3e                	js     801e58 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e1a:	83 ec 04             	sub    $0x4,%esp
  801e1d:	68 07 04 00 00       	push   $0x407
  801e22:	ff 75 f4             	pushl  -0xc(%ebp)
  801e25:	6a 00                	push   $0x0
  801e27:	e8 8d ed ff ff       	call   800bb9 <sys_page_alloc>
  801e2c:	83 c4 10             	add    $0x10,%esp
		return r;
  801e2f:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e31:	85 c0                	test   %eax,%eax
  801e33:	78 23                	js     801e58 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e35:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e3e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e40:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e43:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e4a:	83 ec 0c             	sub    $0xc,%esp
  801e4d:	50                   	push   %eax
  801e4e:	e8 f6 f2 ff ff       	call   801149 <fd2num>
  801e53:	89 c2                	mov    %eax,%edx
  801e55:	83 c4 10             	add    $0x10,%esp
}
  801e58:	89 d0                	mov    %edx,%eax
  801e5a:	c9                   	leave  
  801e5b:	c3                   	ret    

00801e5c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801e5c:	55                   	push   %ebp
  801e5d:	89 e5                	mov    %esp,%ebp
  801e5f:	53                   	push   %ebx
  801e60:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  801e63:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801e6a:	75 28                	jne    801e94 <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  801e6c:	e8 0a ed ff ff       	call   800b7b <sys_getenvid>
  801e71:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_U | PTE_W);
  801e73:	83 ec 04             	sub    $0x4,%esp
  801e76:	6a 06                	push   $0x6
  801e78:	68 00 f0 bf ee       	push   $0xeebff000
  801e7d:	50                   	push   %eax
  801e7e:	e8 36 ed ff ff       	call   800bb9 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  801e83:	83 c4 08             	add    $0x8,%esp
  801e86:	68 a1 1e 80 00       	push   $0x801ea1
  801e8b:	53                   	push   %ebx
  801e8c:	e8 73 ee ff ff       	call   800d04 <sys_env_set_pgfault_upcall>
  801e91:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801e94:	8b 45 08             	mov    0x8(%ebp),%eax
  801e97:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801e9c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e9f:	c9                   	leave  
  801ea0:	c3                   	ret    

00801ea1 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801ea1:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801ea2:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801ea7:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801ea9:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	# My method is different. Copy the values to the other stack
	# in a convinient way, and then pop everything.
	movl %esp, %ebp		# ebp refers to the exception stack
  801eac:	89 e5                	mov    %esp,%ebp
	movl 48(%ebp), %esp 	# go to other stack
  801eae:	8b 65 30             	mov    0x30(%ebp),%esp

	pushl 40(%ebp)		# eip - ORDER SWITCHED WITH EFLAGS
  801eb1:	ff 75 28             	pushl  0x28(%ebp)
	pushl 44(%ebp)      	# eflags
  801eb4:	ff 75 2c             	pushl  0x2c(%ebp)
	pushl 36(%ebp)		# all the 8 remaining regs
  801eb7:	ff 75 24             	pushl  0x24(%ebp)
	pushl 32(%ebp)
  801eba:	ff 75 20             	pushl  0x20(%ebp)
	pushl 28(%ebp)
  801ebd:	ff 75 1c             	pushl  0x1c(%ebp)
	pushl 24(%ebp)
  801ec0:	ff 75 18             	pushl  0x18(%ebp)
	pushl 20(%ebp)
  801ec3:	ff 75 14             	pushl  0x14(%ebp)
	pushl 16(%ebp)
  801ec6:	ff 75 10             	pushl  0x10(%ebp)
	pushl 12(%ebp)
  801ec9:	ff 75 0c             	pushl  0xc(%ebp)
	pushl 8(%ebp)
  801ecc:	ff 75 08             	pushl  0x8(%ebp)

	popal			# now just pop everything!
  801ecf:	61                   	popa   
	popfl
  801ed0:	9d                   	popf   
	ret
  801ed1:	c3                   	ret    

00801ed2 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ed2:	55                   	push   %ebp
  801ed3:	89 e5                	mov    %esp,%ebp
  801ed5:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ed8:	89 d0                	mov    %edx,%eax
  801eda:	c1 e8 16             	shr    $0x16,%eax
  801edd:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801ee4:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ee9:	f6 c1 01             	test   $0x1,%cl
  801eec:	74 1d                	je     801f0b <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801eee:	c1 ea 0c             	shr    $0xc,%edx
  801ef1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801ef8:	f6 c2 01             	test   $0x1,%dl
  801efb:	74 0e                	je     801f0b <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801efd:	c1 ea 0c             	shr    $0xc,%edx
  801f00:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f07:	ef 
  801f08:	0f b7 c0             	movzwl %ax,%eax
}
  801f0b:	5d                   	pop    %ebp
  801f0c:	c3                   	ret    
  801f0d:	66 90                	xchg   %ax,%ax
  801f0f:	90                   	nop

00801f10 <__udivdi3>:
  801f10:	55                   	push   %ebp
  801f11:	57                   	push   %edi
  801f12:	56                   	push   %esi
  801f13:	53                   	push   %ebx
  801f14:	83 ec 1c             	sub    $0x1c,%esp
  801f17:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801f1b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801f1f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801f23:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f27:	85 f6                	test   %esi,%esi
  801f29:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f2d:	89 ca                	mov    %ecx,%edx
  801f2f:	89 f8                	mov    %edi,%eax
  801f31:	75 3d                	jne    801f70 <__udivdi3+0x60>
  801f33:	39 cf                	cmp    %ecx,%edi
  801f35:	0f 87 c5 00 00 00    	ja     802000 <__udivdi3+0xf0>
  801f3b:	85 ff                	test   %edi,%edi
  801f3d:	89 fd                	mov    %edi,%ebp
  801f3f:	75 0b                	jne    801f4c <__udivdi3+0x3c>
  801f41:	b8 01 00 00 00       	mov    $0x1,%eax
  801f46:	31 d2                	xor    %edx,%edx
  801f48:	f7 f7                	div    %edi
  801f4a:	89 c5                	mov    %eax,%ebp
  801f4c:	89 c8                	mov    %ecx,%eax
  801f4e:	31 d2                	xor    %edx,%edx
  801f50:	f7 f5                	div    %ebp
  801f52:	89 c1                	mov    %eax,%ecx
  801f54:	89 d8                	mov    %ebx,%eax
  801f56:	89 cf                	mov    %ecx,%edi
  801f58:	f7 f5                	div    %ebp
  801f5a:	89 c3                	mov    %eax,%ebx
  801f5c:	89 d8                	mov    %ebx,%eax
  801f5e:	89 fa                	mov    %edi,%edx
  801f60:	83 c4 1c             	add    $0x1c,%esp
  801f63:	5b                   	pop    %ebx
  801f64:	5e                   	pop    %esi
  801f65:	5f                   	pop    %edi
  801f66:	5d                   	pop    %ebp
  801f67:	c3                   	ret    
  801f68:	90                   	nop
  801f69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f70:	39 ce                	cmp    %ecx,%esi
  801f72:	77 74                	ja     801fe8 <__udivdi3+0xd8>
  801f74:	0f bd fe             	bsr    %esi,%edi
  801f77:	83 f7 1f             	xor    $0x1f,%edi
  801f7a:	0f 84 98 00 00 00    	je     802018 <__udivdi3+0x108>
  801f80:	bb 20 00 00 00       	mov    $0x20,%ebx
  801f85:	89 f9                	mov    %edi,%ecx
  801f87:	89 c5                	mov    %eax,%ebp
  801f89:	29 fb                	sub    %edi,%ebx
  801f8b:	d3 e6                	shl    %cl,%esi
  801f8d:	89 d9                	mov    %ebx,%ecx
  801f8f:	d3 ed                	shr    %cl,%ebp
  801f91:	89 f9                	mov    %edi,%ecx
  801f93:	d3 e0                	shl    %cl,%eax
  801f95:	09 ee                	or     %ebp,%esi
  801f97:	89 d9                	mov    %ebx,%ecx
  801f99:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f9d:	89 d5                	mov    %edx,%ebp
  801f9f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801fa3:	d3 ed                	shr    %cl,%ebp
  801fa5:	89 f9                	mov    %edi,%ecx
  801fa7:	d3 e2                	shl    %cl,%edx
  801fa9:	89 d9                	mov    %ebx,%ecx
  801fab:	d3 e8                	shr    %cl,%eax
  801fad:	09 c2                	or     %eax,%edx
  801faf:	89 d0                	mov    %edx,%eax
  801fb1:	89 ea                	mov    %ebp,%edx
  801fb3:	f7 f6                	div    %esi
  801fb5:	89 d5                	mov    %edx,%ebp
  801fb7:	89 c3                	mov    %eax,%ebx
  801fb9:	f7 64 24 0c          	mull   0xc(%esp)
  801fbd:	39 d5                	cmp    %edx,%ebp
  801fbf:	72 10                	jb     801fd1 <__udivdi3+0xc1>
  801fc1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801fc5:	89 f9                	mov    %edi,%ecx
  801fc7:	d3 e6                	shl    %cl,%esi
  801fc9:	39 c6                	cmp    %eax,%esi
  801fcb:	73 07                	jae    801fd4 <__udivdi3+0xc4>
  801fcd:	39 d5                	cmp    %edx,%ebp
  801fcf:	75 03                	jne    801fd4 <__udivdi3+0xc4>
  801fd1:	83 eb 01             	sub    $0x1,%ebx
  801fd4:	31 ff                	xor    %edi,%edi
  801fd6:	89 d8                	mov    %ebx,%eax
  801fd8:	89 fa                	mov    %edi,%edx
  801fda:	83 c4 1c             	add    $0x1c,%esp
  801fdd:	5b                   	pop    %ebx
  801fde:	5e                   	pop    %esi
  801fdf:	5f                   	pop    %edi
  801fe0:	5d                   	pop    %ebp
  801fe1:	c3                   	ret    
  801fe2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801fe8:	31 ff                	xor    %edi,%edi
  801fea:	31 db                	xor    %ebx,%ebx
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
  802000:	89 d8                	mov    %ebx,%eax
  802002:	f7 f7                	div    %edi
  802004:	31 ff                	xor    %edi,%edi
  802006:	89 c3                	mov    %eax,%ebx
  802008:	89 d8                	mov    %ebx,%eax
  80200a:	89 fa                	mov    %edi,%edx
  80200c:	83 c4 1c             	add    $0x1c,%esp
  80200f:	5b                   	pop    %ebx
  802010:	5e                   	pop    %esi
  802011:	5f                   	pop    %edi
  802012:	5d                   	pop    %ebp
  802013:	c3                   	ret    
  802014:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802018:	39 ce                	cmp    %ecx,%esi
  80201a:	72 0c                	jb     802028 <__udivdi3+0x118>
  80201c:	31 db                	xor    %ebx,%ebx
  80201e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802022:	0f 87 34 ff ff ff    	ja     801f5c <__udivdi3+0x4c>
  802028:	bb 01 00 00 00       	mov    $0x1,%ebx
  80202d:	e9 2a ff ff ff       	jmp    801f5c <__udivdi3+0x4c>
  802032:	66 90                	xchg   %ax,%ax
  802034:	66 90                	xchg   %ax,%ax
  802036:	66 90                	xchg   %ax,%ax
  802038:	66 90                	xchg   %ax,%ax
  80203a:	66 90                	xchg   %ax,%ax
  80203c:	66 90                	xchg   %ax,%ax
  80203e:	66 90                	xchg   %ax,%ax

00802040 <__umoddi3>:
  802040:	55                   	push   %ebp
  802041:	57                   	push   %edi
  802042:	56                   	push   %esi
  802043:	53                   	push   %ebx
  802044:	83 ec 1c             	sub    $0x1c,%esp
  802047:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80204b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80204f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802053:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802057:	85 d2                	test   %edx,%edx
  802059:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80205d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802061:	89 f3                	mov    %esi,%ebx
  802063:	89 3c 24             	mov    %edi,(%esp)
  802066:	89 74 24 04          	mov    %esi,0x4(%esp)
  80206a:	75 1c                	jne    802088 <__umoddi3+0x48>
  80206c:	39 f7                	cmp    %esi,%edi
  80206e:	76 50                	jbe    8020c0 <__umoddi3+0x80>
  802070:	89 c8                	mov    %ecx,%eax
  802072:	89 f2                	mov    %esi,%edx
  802074:	f7 f7                	div    %edi
  802076:	89 d0                	mov    %edx,%eax
  802078:	31 d2                	xor    %edx,%edx
  80207a:	83 c4 1c             	add    $0x1c,%esp
  80207d:	5b                   	pop    %ebx
  80207e:	5e                   	pop    %esi
  80207f:	5f                   	pop    %edi
  802080:	5d                   	pop    %ebp
  802081:	c3                   	ret    
  802082:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802088:	39 f2                	cmp    %esi,%edx
  80208a:	89 d0                	mov    %edx,%eax
  80208c:	77 52                	ja     8020e0 <__umoddi3+0xa0>
  80208e:	0f bd ea             	bsr    %edx,%ebp
  802091:	83 f5 1f             	xor    $0x1f,%ebp
  802094:	75 5a                	jne    8020f0 <__umoddi3+0xb0>
  802096:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80209a:	0f 82 e0 00 00 00    	jb     802180 <__umoddi3+0x140>
  8020a0:	39 0c 24             	cmp    %ecx,(%esp)
  8020a3:	0f 86 d7 00 00 00    	jbe    802180 <__umoddi3+0x140>
  8020a9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020ad:	8b 54 24 04          	mov    0x4(%esp),%edx
  8020b1:	83 c4 1c             	add    $0x1c,%esp
  8020b4:	5b                   	pop    %ebx
  8020b5:	5e                   	pop    %esi
  8020b6:	5f                   	pop    %edi
  8020b7:	5d                   	pop    %ebp
  8020b8:	c3                   	ret    
  8020b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020c0:	85 ff                	test   %edi,%edi
  8020c2:	89 fd                	mov    %edi,%ebp
  8020c4:	75 0b                	jne    8020d1 <__umoddi3+0x91>
  8020c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8020cb:	31 d2                	xor    %edx,%edx
  8020cd:	f7 f7                	div    %edi
  8020cf:	89 c5                	mov    %eax,%ebp
  8020d1:	89 f0                	mov    %esi,%eax
  8020d3:	31 d2                	xor    %edx,%edx
  8020d5:	f7 f5                	div    %ebp
  8020d7:	89 c8                	mov    %ecx,%eax
  8020d9:	f7 f5                	div    %ebp
  8020db:	89 d0                	mov    %edx,%eax
  8020dd:	eb 99                	jmp    802078 <__umoddi3+0x38>
  8020df:	90                   	nop
  8020e0:	89 c8                	mov    %ecx,%eax
  8020e2:	89 f2                	mov    %esi,%edx
  8020e4:	83 c4 1c             	add    $0x1c,%esp
  8020e7:	5b                   	pop    %ebx
  8020e8:	5e                   	pop    %esi
  8020e9:	5f                   	pop    %edi
  8020ea:	5d                   	pop    %ebp
  8020eb:	c3                   	ret    
  8020ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020f0:	8b 34 24             	mov    (%esp),%esi
  8020f3:	bf 20 00 00 00       	mov    $0x20,%edi
  8020f8:	89 e9                	mov    %ebp,%ecx
  8020fa:	29 ef                	sub    %ebp,%edi
  8020fc:	d3 e0                	shl    %cl,%eax
  8020fe:	89 f9                	mov    %edi,%ecx
  802100:	89 f2                	mov    %esi,%edx
  802102:	d3 ea                	shr    %cl,%edx
  802104:	89 e9                	mov    %ebp,%ecx
  802106:	09 c2                	or     %eax,%edx
  802108:	89 d8                	mov    %ebx,%eax
  80210a:	89 14 24             	mov    %edx,(%esp)
  80210d:	89 f2                	mov    %esi,%edx
  80210f:	d3 e2                	shl    %cl,%edx
  802111:	89 f9                	mov    %edi,%ecx
  802113:	89 54 24 04          	mov    %edx,0x4(%esp)
  802117:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80211b:	d3 e8                	shr    %cl,%eax
  80211d:	89 e9                	mov    %ebp,%ecx
  80211f:	89 c6                	mov    %eax,%esi
  802121:	d3 e3                	shl    %cl,%ebx
  802123:	89 f9                	mov    %edi,%ecx
  802125:	89 d0                	mov    %edx,%eax
  802127:	d3 e8                	shr    %cl,%eax
  802129:	89 e9                	mov    %ebp,%ecx
  80212b:	09 d8                	or     %ebx,%eax
  80212d:	89 d3                	mov    %edx,%ebx
  80212f:	89 f2                	mov    %esi,%edx
  802131:	f7 34 24             	divl   (%esp)
  802134:	89 d6                	mov    %edx,%esi
  802136:	d3 e3                	shl    %cl,%ebx
  802138:	f7 64 24 04          	mull   0x4(%esp)
  80213c:	39 d6                	cmp    %edx,%esi
  80213e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802142:	89 d1                	mov    %edx,%ecx
  802144:	89 c3                	mov    %eax,%ebx
  802146:	72 08                	jb     802150 <__umoddi3+0x110>
  802148:	75 11                	jne    80215b <__umoddi3+0x11b>
  80214a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80214e:	73 0b                	jae    80215b <__umoddi3+0x11b>
  802150:	2b 44 24 04          	sub    0x4(%esp),%eax
  802154:	1b 14 24             	sbb    (%esp),%edx
  802157:	89 d1                	mov    %edx,%ecx
  802159:	89 c3                	mov    %eax,%ebx
  80215b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80215f:	29 da                	sub    %ebx,%edx
  802161:	19 ce                	sbb    %ecx,%esi
  802163:	89 f9                	mov    %edi,%ecx
  802165:	89 f0                	mov    %esi,%eax
  802167:	d3 e0                	shl    %cl,%eax
  802169:	89 e9                	mov    %ebp,%ecx
  80216b:	d3 ea                	shr    %cl,%edx
  80216d:	89 e9                	mov    %ebp,%ecx
  80216f:	d3 ee                	shr    %cl,%esi
  802171:	09 d0                	or     %edx,%eax
  802173:	89 f2                	mov    %esi,%edx
  802175:	83 c4 1c             	add    $0x1c,%esp
  802178:	5b                   	pop    %ebx
  802179:	5e                   	pop    %esi
  80217a:	5f                   	pop    %edi
  80217b:	5d                   	pop    %ebp
  80217c:	c3                   	ret    
  80217d:	8d 76 00             	lea    0x0(%esi),%esi
  802180:	29 f9                	sub    %edi,%ecx
  802182:	19 d6                	sbb    %edx,%esi
  802184:	89 74 24 04          	mov    %esi,0x4(%esp)
  802188:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80218c:	e9 18 ff ff ff       	jmp    8020a9 <__umoddi3+0x69>
