
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
  800047:	e8 26 10 00 00       	call   801072 <ipc_recv>
  80004c:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80004e:	a1 08 40 80 00       	mov    0x804008,%eax
  800053:	8b 40 5c             	mov    0x5c(%eax),%eax
  800056:	83 c4 0c             	add    $0xc,%esp
  800059:	53                   	push   %ebx
  80005a:	50                   	push   %eax
  80005b:	68 40 26 80 00       	push   $0x802640
  800060:	e8 cc 01 00 00       	call   800231 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800065:	e8 13 0f 00 00       	call   800f7d <fork>
  80006a:	89 c7                	mov    %eax,%edi
  80006c:	83 c4 10             	add    $0x10,%esp
  80006f:	85 c0                	test   %eax,%eax
  800071:	79 12                	jns    800085 <primeproc+0x52>
		panic("fork: %e", id);
  800073:	50                   	push   %eax
  800074:	68 f3 29 80 00       	push   $0x8029f3
  800079:	6a 1a                	push   $0x1a
  80007b:	68 4c 26 80 00       	push   $0x80264c
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
  800094:	e8 d9 0f 00 00       	call   801072 <ipc_recv>
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
  8000ab:	e8 2b 10 00 00       	call   8010db <ipc_send>
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
  8000ba:	e8 be 0e 00 00       	call   800f7d <fork>
  8000bf:	89 c6                	mov    %eax,%esi
  8000c1:	85 c0                	test   %eax,%eax
  8000c3:	79 12                	jns    8000d7 <umain+0x22>
		panic("fork: %e", id);
  8000c5:	50                   	push   %eax
  8000c6:	68 f3 29 80 00       	push   $0x8029f3
  8000cb:	6a 2d                	push   $0x2d
  8000cd:	68 4c 26 80 00       	push   $0x80264c
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
  8000eb:	e8 eb 0f 00 00       	call   8010db <ipc_send>
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
  800115:	a3 08 40 80 00       	mov    %eax,0x804008

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
  800144:	e8 ea 11 00 00       	call   801333 <close_all>
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
  800176:	68 64 26 80 00       	push   $0x802664
  80017b:	e8 b1 00 00 00       	call   800231 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800180:	83 c4 18             	add    $0x18,%esp
  800183:	53                   	push   %ebx
  800184:	ff 75 10             	pushl  0x10(%ebp)
  800187:	e8 54 00 00 00       	call   8001e0 <vcprintf>
	cprintf("\n");
  80018c:	c7 04 24 64 2b 80 00 	movl   $0x802b64,(%esp)
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
  800294:	e8 07 21 00 00       	call   8023a0 <__udivdi3>
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
  8002d7:	e8 f4 21 00 00       	call   8024d0 <__umoddi3>
  8002dc:	83 c4 14             	add    $0x14,%esp
  8002df:	0f be 80 87 26 80 00 	movsbl 0x802687(%eax),%eax
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
  8003db:	ff 24 85 c0 27 80 00 	jmp    *0x8027c0(,%eax,4)
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
  80049f:	8b 14 85 20 29 80 00 	mov    0x802920(,%eax,4),%edx
  8004a6:	85 d2                	test   %edx,%edx
  8004a8:	75 18                	jne    8004c2 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004aa:	50                   	push   %eax
  8004ab:	68 9f 26 80 00       	push   $0x80269f
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
  8004c3:	68 f2 2a 80 00       	push   $0x802af2
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
  8004e7:	b8 98 26 80 00       	mov    $0x802698,%eax
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
  800b62:	68 7f 29 80 00       	push   $0x80297f
  800b67:	6a 23                	push   $0x23
  800b69:	68 9c 29 80 00       	push   $0x80299c
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
  800be3:	68 7f 29 80 00       	push   $0x80297f
  800be8:	6a 23                	push   $0x23
  800bea:	68 9c 29 80 00       	push   $0x80299c
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
  800c25:	68 7f 29 80 00       	push   $0x80297f
  800c2a:	6a 23                	push   $0x23
  800c2c:	68 9c 29 80 00       	push   $0x80299c
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
  800c67:	68 7f 29 80 00       	push   $0x80297f
  800c6c:	6a 23                	push   $0x23
  800c6e:	68 9c 29 80 00       	push   $0x80299c
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
  800ca9:	68 7f 29 80 00       	push   $0x80297f
  800cae:	6a 23                	push   $0x23
  800cb0:	68 9c 29 80 00       	push   $0x80299c
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
  800ceb:	68 7f 29 80 00       	push   $0x80297f
  800cf0:	6a 23                	push   $0x23
  800cf2:	68 9c 29 80 00       	push   $0x80299c
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
  800d2d:	68 7f 29 80 00       	push   $0x80297f
  800d32:	6a 23                	push   $0x23
  800d34:	68 9c 29 80 00       	push   $0x80299c
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
  800d91:	68 7f 29 80 00       	push   $0x80297f
  800d96:	6a 23                	push   $0x23
  800d98:	68 9c 29 80 00       	push   $0x80299c
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

00800daa <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800daa:	55                   	push   %ebp
  800dab:	89 e5                	mov    %esp,%ebp
  800dad:	57                   	push   %edi
  800dae:	56                   	push   %esi
  800daf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db0:	ba 00 00 00 00       	mov    $0x0,%edx
  800db5:	b8 0e 00 00 00       	mov    $0xe,%eax
  800dba:	89 d1                	mov    %edx,%ecx
  800dbc:	89 d3                	mov    %edx,%ebx
  800dbe:	89 d7                	mov    %edx,%edi
  800dc0:	89 d6                	mov    %edx,%esi
  800dc2:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800dc4:	5b                   	pop    %ebx
  800dc5:	5e                   	pop    %esi
  800dc6:	5f                   	pop    %edi
  800dc7:	5d                   	pop    %ebp
  800dc8:	c3                   	ret    

00800dc9 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800dc9:	55                   	push   %ebp
  800dca:	89 e5                	mov    %esp,%ebp
  800dcc:	53                   	push   %ebx
  800dcd:	83 ec 04             	sub    $0x4,%esp
	int r;
	void * address = (void *)(pn*PGSIZE);
  800dd0:	89 d3                	mov    %edx,%ebx
  800dd2:	c1 e3 0c             	shl    $0xc,%ebx
	
	if((uvpt[pn] & PTE_SHARE))
  800dd5:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800ddc:	f6 c5 04             	test   $0x4,%ch
  800ddf:	74 38                	je     800e19 <duppage+0x50>
	{
		if ((r = sys_page_map(0, address, envid, address, (uvpt[pn] | PTE_SYSCALL))) < 0)
  800de1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800de8:	83 ec 0c             	sub    $0xc,%esp
  800deb:	81 ca 07 0e 00 00    	or     $0xe07,%edx
  800df1:	52                   	push   %edx
  800df2:	53                   	push   %ebx
  800df3:	50                   	push   %eax
  800df4:	53                   	push   %ebx
  800df5:	6a 00                	push   $0x0
  800df7:	e8 00 fe ff ff       	call   800bfc <sys_page_map>
  800dfc:	83 c4 20             	add    $0x20,%esp
  800dff:	85 c0                	test   %eax,%eax
  800e01:	0f 89 b8 00 00 00    	jns    800ebf <duppage+0xf6>
			panic("sys_page_map: %e", r);
  800e07:	50                   	push   %eax
  800e08:	68 aa 29 80 00       	push   $0x8029aa
  800e0d:	6a 4e                	push   $0x4e
  800e0f:	68 bb 29 80 00       	push   $0x8029bb
  800e14:	e8 3f f3 ff ff       	call   800158 <_panic>
	}
	else if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW))
  800e19:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800e20:	f6 c1 02             	test   $0x2,%cl
  800e23:	75 0c                	jne    800e31 <duppage+0x68>
  800e25:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800e2c:	f6 c5 08             	test   $0x8,%ch
  800e2f:	74 57                	je     800e88 <duppage+0xbf>
	{
		int perm = 0;
		perm |= PTE_P|PTE_U|PTE_COW;
	
		if ((r = sys_page_map(0, address, envid, address, perm)) < 0)
  800e31:	83 ec 0c             	sub    $0xc,%esp
  800e34:	68 05 08 00 00       	push   $0x805
  800e39:	53                   	push   %ebx
  800e3a:	50                   	push   %eax
  800e3b:	53                   	push   %ebx
  800e3c:	6a 00                	push   $0x0
  800e3e:	e8 b9 fd ff ff       	call   800bfc <sys_page_map>
  800e43:	83 c4 20             	add    $0x20,%esp
  800e46:	85 c0                	test   %eax,%eax
  800e48:	79 12                	jns    800e5c <duppage+0x93>
			panic("sys_page_map: %e", r);
  800e4a:	50                   	push   %eax
  800e4b:	68 aa 29 80 00       	push   $0x8029aa
  800e50:	6a 56                	push   $0x56
  800e52:	68 bb 29 80 00       	push   $0x8029bb
  800e57:	e8 fc f2 ff ff       	call   800158 <_panic>
		if ((r = sys_page_map(0, address, 0, address, perm)) < 0)
  800e5c:	83 ec 0c             	sub    $0xc,%esp
  800e5f:	68 05 08 00 00       	push   $0x805
  800e64:	53                   	push   %ebx
  800e65:	6a 00                	push   $0x0
  800e67:	53                   	push   %ebx
  800e68:	6a 00                	push   $0x0
  800e6a:	e8 8d fd ff ff       	call   800bfc <sys_page_map>
  800e6f:	83 c4 20             	add    $0x20,%esp
  800e72:	85 c0                	test   %eax,%eax
  800e74:	79 49                	jns    800ebf <duppage+0xf6>
			panic("sys_page_map: %e", r);
  800e76:	50                   	push   %eax
  800e77:	68 aa 29 80 00       	push   $0x8029aa
  800e7c:	6a 58                	push   $0x58
  800e7e:	68 bb 29 80 00       	push   $0x8029bb
  800e83:	e8 d0 f2 ff ff       	call   800158 <_panic>
	}
	else if((uvpt[pn] & ~PTE_U) == 0)
  800e88:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e8f:	f7 c2 fb ff ff ff    	test   $0xfffffffb,%edx
  800e95:	75 28                	jne    800ebf <duppage+0xf6>
	{
		//cprintf("im here");
		if ((r = sys_page_map(0, address, envid, address, PTE_P|PTE_U)) < 0)
  800e97:	83 ec 0c             	sub    $0xc,%esp
  800e9a:	6a 05                	push   $0x5
  800e9c:	53                   	push   %ebx
  800e9d:	50                   	push   %eax
  800e9e:	53                   	push   %ebx
  800e9f:	6a 00                	push   $0x0
  800ea1:	e8 56 fd ff ff       	call   800bfc <sys_page_map>
  800ea6:	83 c4 20             	add    $0x20,%esp
  800ea9:	85 c0                	test   %eax,%eax
  800eab:	79 12                	jns    800ebf <duppage+0xf6>
			panic("sys_page_map: %e", r);	
  800ead:	50                   	push   %eax
  800eae:	68 aa 29 80 00       	push   $0x8029aa
  800eb3:	6a 5e                	push   $0x5e
  800eb5:	68 bb 29 80 00       	push   $0x8029bb
  800eba:	e8 99 f2 ff ff       	call   800158 <_panic>
	}
	return 0;
}
  800ebf:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ec7:	c9                   	leave  
  800ec8:	c3                   	ret    

00800ec9 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ec9:	55                   	push   %ebp
  800eca:	89 e5                	mov    %esp,%ebp
  800ecc:	53                   	push   %ebx
  800ecd:	83 ec 08             	sub    $0x8,%esp
	void *addr = (void *) utf->utf_fault_va;
  800ed0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed3:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	unsigned pn = ((uint32_t)addr)/PGSIZE;
  800ed5:	89 d8                	mov    %ebx,%eax
  800ed7:	c1 e8 0c             	shr    $0xc,%eax
	pte_t pte = uvpt[pn];
  800eda:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// Allocate a new page, mapped at temp location
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  800ee1:	6a 07                	push   $0x7
  800ee3:	68 00 f0 7f 00       	push   $0x7ff000
  800ee8:	6a 00                	push   $0x0
  800eea:	e8 ca fc ff ff       	call   800bb9 <sys_page_alloc>
  800eef:	83 c4 10             	add    $0x10,%esp
  800ef2:	85 c0                	test   %eax,%eax
  800ef4:	79 12                	jns    800f08 <pgfault+0x3f>
		panic("sys_page_alloc: %e", r);
  800ef6:	50                   	push   %eax
  800ef7:	68 c6 29 80 00       	push   $0x8029c6
  800efc:	6a 2b                	push   $0x2b
  800efe:	68 bb 29 80 00       	push   $0x8029bb
  800f03:	e8 50 f2 ff ff       	call   800158 <_panic>

	// Copy the data from the old page to this new page
	void *addr_pgstart = (void *) ROUNDDOWN(addr, PGSIZE);
  800f08:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr_pgstart, PGSIZE);
  800f0e:	83 ec 04             	sub    $0x4,%esp
  800f11:	68 00 10 00 00       	push   $0x1000
  800f16:	53                   	push   %ebx
  800f17:	68 00 f0 7f 00       	push   $0x7ff000
  800f1c:	e8 27 fa ff ff       	call   800948 <memmove>

	// Move the new page to the old page's address
	if ((r = sys_page_map(0, PFTEMP, 0, addr_pgstart, PTE_P|PTE_U|PTE_W)) < 0)
  800f21:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f28:	53                   	push   %ebx
  800f29:	6a 00                	push   $0x0
  800f2b:	68 00 f0 7f 00       	push   $0x7ff000
  800f30:	6a 00                	push   $0x0
  800f32:	e8 c5 fc ff ff       	call   800bfc <sys_page_map>
  800f37:	83 c4 20             	add    $0x20,%esp
  800f3a:	85 c0                	test   %eax,%eax
  800f3c:	79 12                	jns    800f50 <pgfault+0x87>
		panic("sys_page_map: %e", r);
  800f3e:	50                   	push   %eax
  800f3f:	68 aa 29 80 00       	push   $0x8029aa
  800f44:	6a 33                	push   $0x33
  800f46:	68 bb 29 80 00       	push   $0x8029bb
  800f4b:	e8 08 f2 ff ff       	call   800158 <_panic>

	// Unmap the temp location
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800f50:	83 ec 08             	sub    $0x8,%esp
  800f53:	68 00 f0 7f 00       	push   $0x7ff000
  800f58:	6a 00                	push   $0x0
  800f5a:	e8 df fc ff ff       	call   800c3e <sys_page_unmap>
  800f5f:	83 c4 10             	add    $0x10,%esp
  800f62:	85 c0                	test   %eax,%eax
  800f64:	79 12                	jns    800f78 <pgfault+0xaf>
		panic("sys_page_unmap: %e", r);
  800f66:	50                   	push   %eax
  800f67:	68 d9 29 80 00       	push   $0x8029d9
  800f6c:	6a 37                	push   $0x37
  800f6e:	68 bb 29 80 00       	push   $0x8029bb
  800f73:	e8 e0 f1 ff ff       	call   800158 <_panic>
}
  800f78:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f7b:	c9                   	leave  
  800f7c:	c3                   	ret    

00800f7d <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f7d:	55                   	push   %ebp
  800f7e:	89 e5                	mov    %esp,%ebp
  800f80:	56                   	push   %esi
  800f81:	53                   	push   %ebx
  800f82:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
	// Set up page fault handler
	set_pgfault_handler(&pgfault);
  800f85:	68 c9 0e 80 00       	push   $0x800ec9
  800f8a:	e8 53 13 00 00       	call   8022e2 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f8f:	b8 07 00 00 00       	mov    $0x7,%eax
  800f94:	cd 30                	int    $0x30

	// Create child
	envid_t envid = sys_exofork();
  800f96:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (envid < 0) {
  800f99:	83 c4 10             	add    $0x10,%esp
  800f9c:	85 c0                	test   %eax,%eax
  800f9e:	79 12                	jns    800fb2 <fork+0x35>
		panic("sys_exofork: %e", envid);
  800fa0:	50                   	push   %eax
  800fa1:	68 ec 29 80 00       	push   $0x8029ec
  800fa6:	6a 7c                	push   $0x7c
  800fa8:	68 bb 29 80 00       	push   $0x8029bb
  800fad:	e8 a6 f1 ff ff       	call   800158 <_panic>
		return envid;
	}
	if (envid == 0) {
  800fb2:	85 c0                	test   %eax,%eax
  800fb4:	75 1e                	jne    800fd4 <fork+0x57>
		// We are the child.
		thisenv = &envs[ENVX(sys_getenvid())]; // Fix thisenv
  800fb6:	e8 c0 fb ff ff       	call   800b7b <sys_getenvid>
  800fbb:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fc0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800fc3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fc8:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  800fcd:	b8 00 00 00 00       	mov    $0x0,%eax
  800fd2:	eb 7d                	jmp    801051 <fork+0xd4>

	// Set page fault handler on the child.
	// The parent needs to do it, else the child wouldn't be able to handle
	// the fault when trying to access it's stack (which happens as soon it starts)
	extern void _pgfault_upcall(void);
	sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);
  800fd4:	83 ec 04             	sub    $0x4,%esp
  800fd7:	6a 07                	push   $0x7
  800fd9:	68 00 f0 bf ee       	push   $0xeebff000
  800fde:	50                   	push   %eax
  800fdf:	e8 d5 fb ff ff       	call   800bb9 <sys_page_alloc>
	sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  800fe4:	83 c4 08             	add    $0x8,%esp
  800fe7:	68 27 23 80 00       	push   $0x802327
  800fec:	ff 75 f4             	pushl  -0xc(%ebp)
  800fef:	e8 10 fd ff ff       	call   800d04 <sys_env_set_pgfault_upcall>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  800ff4:	be 04 70 80 00       	mov    $0x807004,%esi
  800ff9:	c1 ee 0c             	shr    $0xc,%esi
  800ffc:	83 c4 10             	add    $0x10,%esp
  800fff:	bb 00 08 00 00       	mov    $0x800,%ebx
  801004:	eb 0d                	jmp    801013 <fork+0x96>
		duppage(envid, pn);
  801006:	89 da                	mov    %ebx,%edx
  801008:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80100b:	e8 b9 fd ff ff       	call   800dc9 <duppage>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  801010:	83 c3 01             	add    $0x1,%ebx
  801013:	39 f3                	cmp    %esi,%ebx
  801015:	76 ef                	jbe    801006 <fork+0x89>
	}

	// Also copy the stack we are currently running on
	// I think it should loop from ustacktop to this page, since the stack
	// can have more than 1 page
	duppage(envid, ((uint32_t) &envid)/PGSIZE);
  801017:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80101a:	c1 ea 0c             	shr    $0xc,%edx
  80101d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801020:	e8 a4 fd ff ff       	call   800dc9 <duppage>

	// Start the child environmnet running
	int r;
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  801025:	83 ec 08             	sub    $0x8,%esp
  801028:	6a 02                	push   $0x2
  80102a:	ff 75 f4             	pushl  -0xc(%ebp)
  80102d:	e8 4e fc ff ff       	call   800c80 <sys_env_set_status>
  801032:	83 c4 10             	add    $0x10,%esp
  801035:	85 c0                	test   %eax,%eax
  801037:	79 15                	jns    80104e <fork+0xd1>
		panic("sys_env_set_status: %e", r);
  801039:	50                   	push   %eax
  80103a:	68 fc 29 80 00       	push   $0x8029fc
  80103f:	68 9c 00 00 00       	push   $0x9c
  801044:	68 bb 29 80 00       	push   $0x8029bb
  801049:	e8 0a f1 ff ff       	call   800158 <_panic>
		return r;
	}

	return envid;
  80104e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  801051:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801054:	5b                   	pop    %ebx
  801055:	5e                   	pop    %esi
  801056:	5d                   	pop    %ebp
  801057:	c3                   	ret    

00801058 <sfork>:

// Challenge!
int
sfork(void)
{
  801058:	55                   	push   %ebp
  801059:	89 e5                	mov    %esp,%ebp
  80105b:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80105e:	68 13 2a 80 00       	push   $0x802a13
  801063:	68 a7 00 00 00       	push   $0xa7
  801068:	68 bb 29 80 00       	push   $0x8029bb
  80106d:	e8 e6 f0 ff ff       	call   800158 <_panic>

00801072 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801072:	55                   	push   %ebp
  801073:	89 e5                	mov    %esp,%ebp
  801075:	56                   	push   %esi
  801076:	53                   	push   %ebx
  801077:	8b 75 08             	mov    0x8(%ebp),%esi
  80107a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80107d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  801080:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801082:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801087:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  80108a:	83 ec 0c             	sub    $0xc,%esp
  80108d:	50                   	push   %eax
  80108e:	e8 d6 fc ff ff       	call   800d69 <sys_ipc_recv>

	if (r < 0) {
  801093:	83 c4 10             	add    $0x10,%esp
  801096:	85 c0                	test   %eax,%eax
  801098:	79 16                	jns    8010b0 <ipc_recv+0x3e>
		if (from_env_store)
  80109a:	85 f6                	test   %esi,%esi
  80109c:	74 06                	je     8010a4 <ipc_recv+0x32>
			*from_env_store = 0;
  80109e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  8010a4:	85 db                	test   %ebx,%ebx
  8010a6:	74 2c                	je     8010d4 <ipc_recv+0x62>
			*perm_store = 0;
  8010a8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010ae:	eb 24                	jmp    8010d4 <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  8010b0:	85 f6                	test   %esi,%esi
  8010b2:	74 0a                	je     8010be <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  8010b4:	a1 08 40 80 00       	mov    0x804008,%eax
  8010b9:	8b 40 74             	mov    0x74(%eax),%eax
  8010bc:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  8010be:	85 db                	test   %ebx,%ebx
  8010c0:	74 0a                	je     8010cc <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  8010c2:	a1 08 40 80 00       	mov    0x804008,%eax
  8010c7:	8b 40 78             	mov    0x78(%eax),%eax
  8010ca:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  8010cc:	a1 08 40 80 00       	mov    0x804008,%eax
  8010d1:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  8010d4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010d7:	5b                   	pop    %ebx
  8010d8:	5e                   	pop    %esi
  8010d9:	5d                   	pop    %ebp
  8010da:	c3                   	ret    

008010db <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8010db:	55                   	push   %ebp
  8010dc:	89 e5                	mov    %esp,%ebp
  8010de:	57                   	push   %edi
  8010df:	56                   	push   %esi
  8010e0:	53                   	push   %ebx
  8010e1:	83 ec 0c             	sub    $0xc,%esp
  8010e4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010e7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010ea:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  8010ed:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  8010ef:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  8010f4:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  8010f7:	ff 75 14             	pushl  0x14(%ebp)
  8010fa:	53                   	push   %ebx
  8010fb:	56                   	push   %esi
  8010fc:	57                   	push   %edi
  8010fd:	e8 44 fc ff ff       	call   800d46 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  801102:	83 c4 10             	add    $0x10,%esp
  801105:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801108:	75 07                	jne    801111 <ipc_send+0x36>
			sys_yield();
  80110a:	e8 8b fa ff ff       	call   800b9a <sys_yield>
  80110f:	eb e6                	jmp    8010f7 <ipc_send+0x1c>
		} else if (r < 0) {
  801111:	85 c0                	test   %eax,%eax
  801113:	79 12                	jns    801127 <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  801115:	50                   	push   %eax
  801116:	68 29 2a 80 00       	push   $0x802a29
  80111b:	6a 51                	push   $0x51
  80111d:	68 36 2a 80 00       	push   $0x802a36
  801122:	e8 31 f0 ff ff       	call   800158 <_panic>
		}
	}
}
  801127:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80112a:	5b                   	pop    %ebx
  80112b:	5e                   	pop    %esi
  80112c:	5f                   	pop    %edi
  80112d:	5d                   	pop    %ebp
  80112e:	c3                   	ret    

0080112f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80112f:	55                   	push   %ebp
  801130:	89 e5                	mov    %esp,%ebp
  801132:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801135:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80113a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80113d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801143:	8b 52 50             	mov    0x50(%edx),%edx
  801146:	39 ca                	cmp    %ecx,%edx
  801148:	75 0d                	jne    801157 <ipc_find_env+0x28>
			return envs[i].env_id;
  80114a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80114d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801152:	8b 40 48             	mov    0x48(%eax),%eax
  801155:	eb 0f                	jmp    801166 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801157:	83 c0 01             	add    $0x1,%eax
  80115a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80115f:	75 d9                	jne    80113a <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801161:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801166:	5d                   	pop    %ebp
  801167:	c3                   	ret    

00801168 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801168:	55                   	push   %ebp
  801169:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80116b:	8b 45 08             	mov    0x8(%ebp),%eax
  80116e:	05 00 00 00 30       	add    $0x30000000,%eax
  801173:	c1 e8 0c             	shr    $0xc,%eax
}
  801176:	5d                   	pop    %ebp
  801177:	c3                   	ret    

00801178 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801178:	55                   	push   %ebp
  801179:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80117b:	8b 45 08             	mov    0x8(%ebp),%eax
  80117e:	05 00 00 00 30       	add    $0x30000000,%eax
  801183:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801188:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80118d:	5d                   	pop    %ebp
  80118e:	c3                   	ret    

0080118f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80118f:	55                   	push   %ebp
  801190:	89 e5                	mov    %esp,%ebp
  801192:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801195:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80119a:	89 c2                	mov    %eax,%edx
  80119c:	c1 ea 16             	shr    $0x16,%edx
  80119f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011a6:	f6 c2 01             	test   $0x1,%dl
  8011a9:	74 11                	je     8011bc <fd_alloc+0x2d>
  8011ab:	89 c2                	mov    %eax,%edx
  8011ad:	c1 ea 0c             	shr    $0xc,%edx
  8011b0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011b7:	f6 c2 01             	test   $0x1,%dl
  8011ba:	75 09                	jne    8011c5 <fd_alloc+0x36>
			*fd_store = fd;
  8011bc:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011be:	b8 00 00 00 00       	mov    $0x0,%eax
  8011c3:	eb 17                	jmp    8011dc <fd_alloc+0x4d>
  8011c5:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011ca:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011cf:	75 c9                	jne    80119a <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011d1:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011d7:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011dc:	5d                   	pop    %ebp
  8011dd:	c3                   	ret    

008011de <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011de:	55                   	push   %ebp
  8011df:	89 e5                	mov    %esp,%ebp
  8011e1:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011e4:	83 f8 1f             	cmp    $0x1f,%eax
  8011e7:	77 36                	ja     80121f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011e9:	c1 e0 0c             	shl    $0xc,%eax
  8011ec:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011f1:	89 c2                	mov    %eax,%edx
  8011f3:	c1 ea 16             	shr    $0x16,%edx
  8011f6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011fd:	f6 c2 01             	test   $0x1,%dl
  801200:	74 24                	je     801226 <fd_lookup+0x48>
  801202:	89 c2                	mov    %eax,%edx
  801204:	c1 ea 0c             	shr    $0xc,%edx
  801207:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80120e:	f6 c2 01             	test   $0x1,%dl
  801211:	74 1a                	je     80122d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801213:	8b 55 0c             	mov    0xc(%ebp),%edx
  801216:	89 02                	mov    %eax,(%edx)
	return 0;
  801218:	b8 00 00 00 00       	mov    $0x0,%eax
  80121d:	eb 13                	jmp    801232 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80121f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801224:	eb 0c                	jmp    801232 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801226:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80122b:	eb 05                	jmp    801232 <fd_lookup+0x54>
  80122d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801232:	5d                   	pop    %ebp
  801233:	c3                   	ret    

00801234 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801234:	55                   	push   %ebp
  801235:	89 e5                	mov    %esp,%ebp
  801237:	83 ec 08             	sub    $0x8,%esp
  80123a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80123d:	ba c0 2a 80 00       	mov    $0x802ac0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801242:	eb 13                	jmp    801257 <dev_lookup+0x23>
  801244:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801247:	39 08                	cmp    %ecx,(%eax)
  801249:	75 0c                	jne    801257 <dev_lookup+0x23>
			*dev = devtab[i];
  80124b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80124e:	89 01                	mov    %eax,(%ecx)
			return 0;
  801250:	b8 00 00 00 00       	mov    $0x0,%eax
  801255:	eb 2e                	jmp    801285 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801257:	8b 02                	mov    (%edx),%eax
  801259:	85 c0                	test   %eax,%eax
  80125b:	75 e7                	jne    801244 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80125d:	a1 08 40 80 00       	mov    0x804008,%eax
  801262:	8b 40 48             	mov    0x48(%eax),%eax
  801265:	83 ec 04             	sub    $0x4,%esp
  801268:	51                   	push   %ecx
  801269:	50                   	push   %eax
  80126a:	68 40 2a 80 00       	push   $0x802a40
  80126f:	e8 bd ef ff ff       	call   800231 <cprintf>
	*dev = 0;
  801274:	8b 45 0c             	mov    0xc(%ebp),%eax
  801277:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80127d:	83 c4 10             	add    $0x10,%esp
  801280:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801285:	c9                   	leave  
  801286:	c3                   	ret    

00801287 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801287:	55                   	push   %ebp
  801288:	89 e5                	mov    %esp,%ebp
  80128a:	56                   	push   %esi
  80128b:	53                   	push   %ebx
  80128c:	83 ec 10             	sub    $0x10,%esp
  80128f:	8b 75 08             	mov    0x8(%ebp),%esi
  801292:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801295:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801298:	50                   	push   %eax
  801299:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80129f:	c1 e8 0c             	shr    $0xc,%eax
  8012a2:	50                   	push   %eax
  8012a3:	e8 36 ff ff ff       	call   8011de <fd_lookup>
  8012a8:	83 c4 08             	add    $0x8,%esp
  8012ab:	85 c0                	test   %eax,%eax
  8012ad:	78 05                	js     8012b4 <fd_close+0x2d>
	    || fd != fd2)
  8012af:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012b2:	74 0c                	je     8012c0 <fd_close+0x39>
		return (must_exist ? r : 0);
  8012b4:	84 db                	test   %bl,%bl
  8012b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8012bb:	0f 44 c2             	cmove  %edx,%eax
  8012be:	eb 41                	jmp    801301 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012c0:	83 ec 08             	sub    $0x8,%esp
  8012c3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012c6:	50                   	push   %eax
  8012c7:	ff 36                	pushl  (%esi)
  8012c9:	e8 66 ff ff ff       	call   801234 <dev_lookup>
  8012ce:	89 c3                	mov    %eax,%ebx
  8012d0:	83 c4 10             	add    $0x10,%esp
  8012d3:	85 c0                	test   %eax,%eax
  8012d5:	78 1a                	js     8012f1 <fd_close+0x6a>
		if (dev->dev_close)
  8012d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012da:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012dd:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012e2:	85 c0                	test   %eax,%eax
  8012e4:	74 0b                	je     8012f1 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012e6:	83 ec 0c             	sub    $0xc,%esp
  8012e9:	56                   	push   %esi
  8012ea:	ff d0                	call   *%eax
  8012ec:	89 c3                	mov    %eax,%ebx
  8012ee:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012f1:	83 ec 08             	sub    $0x8,%esp
  8012f4:	56                   	push   %esi
  8012f5:	6a 00                	push   $0x0
  8012f7:	e8 42 f9 ff ff       	call   800c3e <sys_page_unmap>
	return r;
  8012fc:	83 c4 10             	add    $0x10,%esp
  8012ff:	89 d8                	mov    %ebx,%eax
}
  801301:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801304:	5b                   	pop    %ebx
  801305:	5e                   	pop    %esi
  801306:	5d                   	pop    %ebp
  801307:	c3                   	ret    

00801308 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801308:	55                   	push   %ebp
  801309:	89 e5                	mov    %esp,%ebp
  80130b:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80130e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801311:	50                   	push   %eax
  801312:	ff 75 08             	pushl  0x8(%ebp)
  801315:	e8 c4 fe ff ff       	call   8011de <fd_lookup>
  80131a:	83 c4 08             	add    $0x8,%esp
  80131d:	85 c0                	test   %eax,%eax
  80131f:	78 10                	js     801331 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801321:	83 ec 08             	sub    $0x8,%esp
  801324:	6a 01                	push   $0x1
  801326:	ff 75 f4             	pushl  -0xc(%ebp)
  801329:	e8 59 ff ff ff       	call   801287 <fd_close>
  80132e:	83 c4 10             	add    $0x10,%esp
}
  801331:	c9                   	leave  
  801332:	c3                   	ret    

00801333 <close_all>:

void
close_all(void)
{
  801333:	55                   	push   %ebp
  801334:	89 e5                	mov    %esp,%ebp
  801336:	53                   	push   %ebx
  801337:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80133a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80133f:	83 ec 0c             	sub    $0xc,%esp
  801342:	53                   	push   %ebx
  801343:	e8 c0 ff ff ff       	call   801308 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801348:	83 c3 01             	add    $0x1,%ebx
  80134b:	83 c4 10             	add    $0x10,%esp
  80134e:	83 fb 20             	cmp    $0x20,%ebx
  801351:	75 ec                	jne    80133f <close_all+0xc>
		close(i);
}
  801353:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801356:	c9                   	leave  
  801357:	c3                   	ret    

00801358 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801358:	55                   	push   %ebp
  801359:	89 e5                	mov    %esp,%ebp
  80135b:	57                   	push   %edi
  80135c:	56                   	push   %esi
  80135d:	53                   	push   %ebx
  80135e:	83 ec 2c             	sub    $0x2c,%esp
  801361:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801364:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801367:	50                   	push   %eax
  801368:	ff 75 08             	pushl  0x8(%ebp)
  80136b:	e8 6e fe ff ff       	call   8011de <fd_lookup>
  801370:	83 c4 08             	add    $0x8,%esp
  801373:	85 c0                	test   %eax,%eax
  801375:	0f 88 c1 00 00 00    	js     80143c <dup+0xe4>
		return r;
	close(newfdnum);
  80137b:	83 ec 0c             	sub    $0xc,%esp
  80137e:	56                   	push   %esi
  80137f:	e8 84 ff ff ff       	call   801308 <close>

	newfd = INDEX2FD(newfdnum);
  801384:	89 f3                	mov    %esi,%ebx
  801386:	c1 e3 0c             	shl    $0xc,%ebx
  801389:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80138f:	83 c4 04             	add    $0x4,%esp
  801392:	ff 75 e4             	pushl  -0x1c(%ebp)
  801395:	e8 de fd ff ff       	call   801178 <fd2data>
  80139a:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80139c:	89 1c 24             	mov    %ebx,(%esp)
  80139f:	e8 d4 fd ff ff       	call   801178 <fd2data>
  8013a4:	83 c4 10             	add    $0x10,%esp
  8013a7:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013aa:	89 f8                	mov    %edi,%eax
  8013ac:	c1 e8 16             	shr    $0x16,%eax
  8013af:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013b6:	a8 01                	test   $0x1,%al
  8013b8:	74 37                	je     8013f1 <dup+0x99>
  8013ba:	89 f8                	mov    %edi,%eax
  8013bc:	c1 e8 0c             	shr    $0xc,%eax
  8013bf:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013c6:	f6 c2 01             	test   $0x1,%dl
  8013c9:	74 26                	je     8013f1 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013cb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013d2:	83 ec 0c             	sub    $0xc,%esp
  8013d5:	25 07 0e 00 00       	and    $0xe07,%eax
  8013da:	50                   	push   %eax
  8013db:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013de:	6a 00                	push   $0x0
  8013e0:	57                   	push   %edi
  8013e1:	6a 00                	push   $0x0
  8013e3:	e8 14 f8 ff ff       	call   800bfc <sys_page_map>
  8013e8:	89 c7                	mov    %eax,%edi
  8013ea:	83 c4 20             	add    $0x20,%esp
  8013ed:	85 c0                	test   %eax,%eax
  8013ef:	78 2e                	js     80141f <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013f1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013f4:	89 d0                	mov    %edx,%eax
  8013f6:	c1 e8 0c             	shr    $0xc,%eax
  8013f9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801400:	83 ec 0c             	sub    $0xc,%esp
  801403:	25 07 0e 00 00       	and    $0xe07,%eax
  801408:	50                   	push   %eax
  801409:	53                   	push   %ebx
  80140a:	6a 00                	push   $0x0
  80140c:	52                   	push   %edx
  80140d:	6a 00                	push   $0x0
  80140f:	e8 e8 f7 ff ff       	call   800bfc <sys_page_map>
  801414:	89 c7                	mov    %eax,%edi
  801416:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801419:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80141b:	85 ff                	test   %edi,%edi
  80141d:	79 1d                	jns    80143c <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80141f:	83 ec 08             	sub    $0x8,%esp
  801422:	53                   	push   %ebx
  801423:	6a 00                	push   $0x0
  801425:	e8 14 f8 ff ff       	call   800c3e <sys_page_unmap>
	sys_page_unmap(0, nva);
  80142a:	83 c4 08             	add    $0x8,%esp
  80142d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801430:	6a 00                	push   $0x0
  801432:	e8 07 f8 ff ff       	call   800c3e <sys_page_unmap>
	return r;
  801437:	83 c4 10             	add    $0x10,%esp
  80143a:	89 f8                	mov    %edi,%eax
}
  80143c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80143f:	5b                   	pop    %ebx
  801440:	5e                   	pop    %esi
  801441:	5f                   	pop    %edi
  801442:	5d                   	pop    %ebp
  801443:	c3                   	ret    

00801444 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801444:	55                   	push   %ebp
  801445:	89 e5                	mov    %esp,%ebp
  801447:	53                   	push   %ebx
  801448:	83 ec 14             	sub    $0x14,%esp
  80144b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80144e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801451:	50                   	push   %eax
  801452:	53                   	push   %ebx
  801453:	e8 86 fd ff ff       	call   8011de <fd_lookup>
  801458:	83 c4 08             	add    $0x8,%esp
  80145b:	89 c2                	mov    %eax,%edx
  80145d:	85 c0                	test   %eax,%eax
  80145f:	78 6d                	js     8014ce <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801461:	83 ec 08             	sub    $0x8,%esp
  801464:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801467:	50                   	push   %eax
  801468:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80146b:	ff 30                	pushl  (%eax)
  80146d:	e8 c2 fd ff ff       	call   801234 <dev_lookup>
  801472:	83 c4 10             	add    $0x10,%esp
  801475:	85 c0                	test   %eax,%eax
  801477:	78 4c                	js     8014c5 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801479:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80147c:	8b 42 08             	mov    0x8(%edx),%eax
  80147f:	83 e0 03             	and    $0x3,%eax
  801482:	83 f8 01             	cmp    $0x1,%eax
  801485:	75 21                	jne    8014a8 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801487:	a1 08 40 80 00       	mov    0x804008,%eax
  80148c:	8b 40 48             	mov    0x48(%eax),%eax
  80148f:	83 ec 04             	sub    $0x4,%esp
  801492:	53                   	push   %ebx
  801493:	50                   	push   %eax
  801494:	68 84 2a 80 00       	push   $0x802a84
  801499:	e8 93 ed ff ff       	call   800231 <cprintf>
		return -E_INVAL;
  80149e:	83 c4 10             	add    $0x10,%esp
  8014a1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014a6:	eb 26                	jmp    8014ce <read+0x8a>
	}
	if (!dev->dev_read)
  8014a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014ab:	8b 40 08             	mov    0x8(%eax),%eax
  8014ae:	85 c0                	test   %eax,%eax
  8014b0:	74 17                	je     8014c9 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014b2:	83 ec 04             	sub    $0x4,%esp
  8014b5:	ff 75 10             	pushl  0x10(%ebp)
  8014b8:	ff 75 0c             	pushl  0xc(%ebp)
  8014bb:	52                   	push   %edx
  8014bc:	ff d0                	call   *%eax
  8014be:	89 c2                	mov    %eax,%edx
  8014c0:	83 c4 10             	add    $0x10,%esp
  8014c3:	eb 09                	jmp    8014ce <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014c5:	89 c2                	mov    %eax,%edx
  8014c7:	eb 05                	jmp    8014ce <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014c9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8014ce:	89 d0                	mov    %edx,%eax
  8014d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014d3:	c9                   	leave  
  8014d4:	c3                   	ret    

008014d5 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014d5:	55                   	push   %ebp
  8014d6:	89 e5                	mov    %esp,%ebp
  8014d8:	57                   	push   %edi
  8014d9:	56                   	push   %esi
  8014da:	53                   	push   %ebx
  8014db:	83 ec 0c             	sub    $0xc,%esp
  8014de:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014e1:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014e4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014e9:	eb 21                	jmp    80150c <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014eb:	83 ec 04             	sub    $0x4,%esp
  8014ee:	89 f0                	mov    %esi,%eax
  8014f0:	29 d8                	sub    %ebx,%eax
  8014f2:	50                   	push   %eax
  8014f3:	89 d8                	mov    %ebx,%eax
  8014f5:	03 45 0c             	add    0xc(%ebp),%eax
  8014f8:	50                   	push   %eax
  8014f9:	57                   	push   %edi
  8014fa:	e8 45 ff ff ff       	call   801444 <read>
		if (m < 0)
  8014ff:	83 c4 10             	add    $0x10,%esp
  801502:	85 c0                	test   %eax,%eax
  801504:	78 10                	js     801516 <readn+0x41>
			return m;
		if (m == 0)
  801506:	85 c0                	test   %eax,%eax
  801508:	74 0a                	je     801514 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80150a:	01 c3                	add    %eax,%ebx
  80150c:	39 f3                	cmp    %esi,%ebx
  80150e:	72 db                	jb     8014eb <readn+0x16>
  801510:	89 d8                	mov    %ebx,%eax
  801512:	eb 02                	jmp    801516 <readn+0x41>
  801514:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801516:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801519:	5b                   	pop    %ebx
  80151a:	5e                   	pop    %esi
  80151b:	5f                   	pop    %edi
  80151c:	5d                   	pop    %ebp
  80151d:	c3                   	ret    

0080151e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80151e:	55                   	push   %ebp
  80151f:	89 e5                	mov    %esp,%ebp
  801521:	53                   	push   %ebx
  801522:	83 ec 14             	sub    $0x14,%esp
  801525:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801528:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80152b:	50                   	push   %eax
  80152c:	53                   	push   %ebx
  80152d:	e8 ac fc ff ff       	call   8011de <fd_lookup>
  801532:	83 c4 08             	add    $0x8,%esp
  801535:	89 c2                	mov    %eax,%edx
  801537:	85 c0                	test   %eax,%eax
  801539:	78 68                	js     8015a3 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80153b:	83 ec 08             	sub    $0x8,%esp
  80153e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801541:	50                   	push   %eax
  801542:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801545:	ff 30                	pushl  (%eax)
  801547:	e8 e8 fc ff ff       	call   801234 <dev_lookup>
  80154c:	83 c4 10             	add    $0x10,%esp
  80154f:	85 c0                	test   %eax,%eax
  801551:	78 47                	js     80159a <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801553:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801556:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80155a:	75 21                	jne    80157d <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80155c:	a1 08 40 80 00       	mov    0x804008,%eax
  801561:	8b 40 48             	mov    0x48(%eax),%eax
  801564:	83 ec 04             	sub    $0x4,%esp
  801567:	53                   	push   %ebx
  801568:	50                   	push   %eax
  801569:	68 a0 2a 80 00       	push   $0x802aa0
  80156e:	e8 be ec ff ff       	call   800231 <cprintf>
		return -E_INVAL;
  801573:	83 c4 10             	add    $0x10,%esp
  801576:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80157b:	eb 26                	jmp    8015a3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80157d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801580:	8b 52 0c             	mov    0xc(%edx),%edx
  801583:	85 d2                	test   %edx,%edx
  801585:	74 17                	je     80159e <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801587:	83 ec 04             	sub    $0x4,%esp
  80158a:	ff 75 10             	pushl  0x10(%ebp)
  80158d:	ff 75 0c             	pushl  0xc(%ebp)
  801590:	50                   	push   %eax
  801591:	ff d2                	call   *%edx
  801593:	89 c2                	mov    %eax,%edx
  801595:	83 c4 10             	add    $0x10,%esp
  801598:	eb 09                	jmp    8015a3 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80159a:	89 c2                	mov    %eax,%edx
  80159c:	eb 05                	jmp    8015a3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80159e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8015a3:	89 d0                	mov    %edx,%eax
  8015a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015a8:	c9                   	leave  
  8015a9:	c3                   	ret    

008015aa <seek>:

int
seek(int fdnum, off_t offset)
{
  8015aa:	55                   	push   %ebp
  8015ab:	89 e5                	mov    %esp,%ebp
  8015ad:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015b0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015b3:	50                   	push   %eax
  8015b4:	ff 75 08             	pushl  0x8(%ebp)
  8015b7:	e8 22 fc ff ff       	call   8011de <fd_lookup>
  8015bc:	83 c4 08             	add    $0x8,%esp
  8015bf:	85 c0                	test   %eax,%eax
  8015c1:	78 0e                	js     8015d1 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015c6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015c9:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015cc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015d1:	c9                   	leave  
  8015d2:	c3                   	ret    

008015d3 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015d3:	55                   	push   %ebp
  8015d4:	89 e5                	mov    %esp,%ebp
  8015d6:	53                   	push   %ebx
  8015d7:	83 ec 14             	sub    $0x14,%esp
  8015da:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015dd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015e0:	50                   	push   %eax
  8015e1:	53                   	push   %ebx
  8015e2:	e8 f7 fb ff ff       	call   8011de <fd_lookup>
  8015e7:	83 c4 08             	add    $0x8,%esp
  8015ea:	89 c2                	mov    %eax,%edx
  8015ec:	85 c0                	test   %eax,%eax
  8015ee:	78 65                	js     801655 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015f0:	83 ec 08             	sub    $0x8,%esp
  8015f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015f6:	50                   	push   %eax
  8015f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015fa:	ff 30                	pushl  (%eax)
  8015fc:	e8 33 fc ff ff       	call   801234 <dev_lookup>
  801601:	83 c4 10             	add    $0x10,%esp
  801604:	85 c0                	test   %eax,%eax
  801606:	78 44                	js     80164c <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801608:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80160b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80160f:	75 21                	jne    801632 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801611:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801616:	8b 40 48             	mov    0x48(%eax),%eax
  801619:	83 ec 04             	sub    $0x4,%esp
  80161c:	53                   	push   %ebx
  80161d:	50                   	push   %eax
  80161e:	68 60 2a 80 00       	push   $0x802a60
  801623:	e8 09 ec ff ff       	call   800231 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801628:	83 c4 10             	add    $0x10,%esp
  80162b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801630:	eb 23                	jmp    801655 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801632:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801635:	8b 52 18             	mov    0x18(%edx),%edx
  801638:	85 d2                	test   %edx,%edx
  80163a:	74 14                	je     801650 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80163c:	83 ec 08             	sub    $0x8,%esp
  80163f:	ff 75 0c             	pushl  0xc(%ebp)
  801642:	50                   	push   %eax
  801643:	ff d2                	call   *%edx
  801645:	89 c2                	mov    %eax,%edx
  801647:	83 c4 10             	add    $0x10,%esp
  80164a:	eb 09                	jmp    801655 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80164c:	89 c2                	mov    %eax,%edx
  80164e:	eb 05                	jmp    801655 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801650:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801655:	89 d0                	mov    %edx,%eax
  801657:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80165a:	c9                   	leave  
  80165b:	c3                   	ret    

0080165c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80165c:	55                   	push   %ebp
  80165d:	89 e5                	mov    %esp,%ebp
  80165f:	53                   	push   %ebx
  801660:	83 ec 14             	sub    $0x14,%esp
  801663:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801666:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801669:	50                   	push   %eax
  80166a:	ff 75 08             	pushl  0x8(%ebp)
  80166d:	e8 6c fb ff ff       	call   8011de <fd_lookup>
  801672:	83 c4 08             	add    $0x8,%esp
  801675:	89 c2                	mov    %eax,%edx
  801677:	85 c0                	test   %eax,%eax
  801679:	78 58                	js     8016d3 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80167b:	83 ec 08             	sub    $0x8,%esp
  80167e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801681:	50                   	push   %eax
  801682:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801685:	ff 30                	pushl  (%eax)
  801687:	e8 a8 fb ff ff       	call   801234 <dev_lookup>
  80168c:	83 c4 10             	add    $0x10,%esp
  80168f:	85 c0                	test   %eax,%eax
  801691:	78 37                	js     8016ca <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801693:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801696:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80169a:	74 32                	je     8016ce <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80169c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80169f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016a6:	00 00 00 
	stat->st_isdir = 0;
  8016a9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016b0:	00 00 00 
	stat->st_dev = dev;
  8016b3:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016b9:	83 ec 08             	sub    $0x8,%esp
  8016bc:	53                   	push   %ebx
  8016bd:	ff 75 f0             	pushl  -0x10(%ebp)
  8016c0:	ff 50 14             	call   *0x14(%eax)
  8016c3:	89 c2                	mov    %eax,%edx
  8016c5:	83 c4 10             	add    $0x10,%esp
  8016c8:	eb 09                	jmp    8016d3 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ca:	89 c2                	mov    %eax,%edx
  8016cc:	eb 05                	jmp    8016d3 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016ce:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016d3:	89 d0                	mov    %edx,%eax
  8016d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016d8:	c9                   	leave  
  8016d9:	c3                   	ret    

008016da <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016da:	55                   	push   %ebp
  8016db:	89 e5                	mov    %esp,%ebp
  8016dd:	56                   	push   %esi
  8016de:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016df:	83 ec 08             	sub    $0x8,%esp
  8016e2:	6a 00                	push   $0x0
  8016e4:	ff 75 08             	pushl  0x8(%ebp)
  8016e7:	e8 0c 02 00 00       	call   8018f8 <open>
  8016ec:	89 c3                	mov    %eax,%ebx
  8016ee:	83 c4 10             	add    $0x10,%esp
  8016f1:	85 c0                	test   %eax,%eax
  8016f3:	78 1b                	js     801710 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016f5:	83 ec 08             	sub    $0x8,%esp
  8016f8:	ff 75 0c             	pushl  0xc(%ebp)
  8016fb:	50                   	push   %eax
  8016fc:	e8 5b ff ff ff       	call   80165c <fstat>
  801701:	89 c6                	mov    %eax,%esi
	close(fd);
  801703:	89 1c 24             	mov    %ebx,(%esp)
  801706:	e8 fd fb ff ff       	call   801308 <close>
	return r;
  80170b:	83 c4 10             	add    $0x10,%esp
  80170e:	89 f0                	mov    %esi,%eax
}
  801710:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801713:	5b                   	pop    %ebx
  801714:	5e                   	pop    %esi
  801715:	5d                   	pop    %ebp
  801716:	c3                   	ret    

00801717 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801717:	55                   	push   %ebp
  801718:	89 e5                	mov    %esp,%ebp
  80171a:	56                   	push   %esi
  80171b:	53                   	push   %ebx
  80171c:	89 c6                	mov    %eax,%esi
  80171e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801720:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801727:	75 12                	jne    80173b <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801729:	83 ec 0c             	sub    $0xc,%esp
  80172c:	6a 01                	push   $0x1
  80172e:	e8 fc f9 ff ff       	call   80112f <ipc_find_env>
  801733:	a3 00 40 80 00       	mov    %eax,0x804000
  801738:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80173b:	6a 07                	push   $0x7
  80173d:	68 00 50 80 00       	push   $0x805000
  801742:	56                   	push   %esi
  801743:	ff 35 00 40 80 00    	pushl  0x804000
  801749:	e8 8d f9 ff ff       	call   8010db <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80174e:	83 c4 0c             	add    $0xc,%esp
  801751:	6a 00                	push   $0x0
  801753:	53                   	push   %ebx
  801754:	6a 00                	push   $0x0
  801756:	e8 17 f9 ff ff       	call   801072 <ipc_recv>
}
  80175b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80175e:	5b                   	pop    %ebx
  80175f:	5e                   	pop    %esi
  801760:	5d                   	pop    %ebp
  801761:	c3                   	ret    

00801762 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801762:	55                   	push   %ebp
  801763:	89 e5                	mov    %esp,%ebp
  801765:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801768:	8b 45 08             	mov    0x8(%ebp),%eax
  80176b:	8b 40 0c             	mov    0xc(%eax),%eax
  80176e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801773:	8b 45 0c             	mov    0xc(%ebp),%eax
  801776:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80177b:	ba 00 00 00 00       	mov    $0x0,%edx
  801780:	b8 02 00 00 00       	mov    $0x2,%eax
  801785:	e8 8d ff ff ff       	call   801717 <fsipc>
}
  80178a:	c9                   	leave  
  80178b:	c3                   	ret    

0080178c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80178c:	55                   	push   %ebp
  80178d:	89 e5                	mov    %esp,%ebp
  80178f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801792:	8b 45 08             	mov    0x8(%ebp),%eax
  801795:	8b 40 0c             	mov    0xc(%eax),%eax
  801798:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80179d:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a2:	b8 06 00 00 00       	mov    $0x6,%eax
  8017a7:	e8 6b ff ff ff       	call   801717 <fsipc>
}
  8017ac:	c9                   	leave  
  8017ad:	c3                   	ret    

008017ae <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017ae:	55                   	push   %ebp
  8017af:	89 e5                	mov    %esp,%ebp
  8017b1:	53                   	push   %ebx
  8017b2:	83 ec 04             	sub    $0x4,%esp
  8017b5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017bb:	8b 40 0c             	mov    0xc(%eax),%eax
  8017be:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8017c8:	b8 05 00 00 00       	mov    $0x5,%eax
  8017cd:	e8 45 ff ff ff       	call   801717 <fsipc>
  8017d2:	85 c0                	test   %eax,%eax
  8017d4:	78 2c                	js     801802 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017d6:	83 ec 08             	sub    $0x8,%esp
  8017d9:	68 00 50 80 00       	push   $0x805000
  8017de:	53                   	push   %ebx
  8017df:	e8 d2 ef ff ff       	call   8007b6 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017e4:	a1 80 50 80 00       	mov    0x805080,%eax
  8017e9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017ef:	a1 84 50 80 00       	mov    0x805084,%eax
  8017f4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017fa:	83 c4 10             	add    $0x10,%esp
  8017fd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801802:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801805:	c9                   	leave  
  801806:	c3                   	ret    

00801807 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801807:	55                   	push   %ebp
  801808:	89 e5                	mov    %esp,%ebp
  80180a:	53                   	push   %ebx
  80180b:	83 ec 08             	sub    $0x8,%esp
  80180e:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801811:	8b 55 08             	mov    0x8(%ebp),%edx
  801814:	8b 52 0c             	mov    0xc(%edx),%edx
  801817:	89 15 00 50 80 00    	mov    %edx,0x805000
  80181d:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801822:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  801827:	0f 46 d8             	cmovbe %eax,%ebx
	
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  80182a:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  801830:	53                   	push   %ebx
  801831:	ff 75 0c             	pushl  0xc(%ebp)
  801834:	68 08 50 80 00       	push   $0x805008
  801839:	e8 0a f1 ff ff       	call   800948 <memmove>

	
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) 
  80183e:	ba 00 00 00 00       	mov    $0x0,%edx
  801843:	b8 04 00 00 00       	mov    $0x4,%eax
  801848:	e8 ca fe ff ff       	call   801717 <fsipc>
  80184d:	83 c4 10             	add    $0x10,%esp
  801850:	85 c0                	test   %eax,%eax
  801852:	78 1d                	js     801871 <devfile_write+0x6a>
		return r;
	assert(r <= n_real); 
  801854:	39 d8                	cmp    %ebx,%eax
  801856:	76 19                	jbe    801871 <devfile_write+0x6a>
  801858:	68 d4 2a 80 00       	push   $0x802ad4
  80185d:	68 e0 2a 80 00       	push   $0x802ae0
  801862:	68 a3 00 00 00       	push   $0xa3
  801867:	68 f5 2a 80 00       	push   $0x802af5
  80186c:	e8 e7 e8 ff ff       	call   800158 <_panic>
	return r;
}
  801871:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801874:	c9                   	leave  
  801875:	c3                   	ret    

00801876 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801876:	55                   	push   %ebp
  801877:	89 e5                	mov    %esp,%ebp
  801879:	56                   	push   %esi
  80187a:	53                   	push   %ebx
  80187b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80187e:	8b 45 08             	mov    0x8(%ebp),%eax
  801881:	8b 40 0c             	mov    0xc(%eax),%eax
  801884:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801889:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80188f:	ba 00 00 00 00       	mov    $0x0,%edx
  801894:	b8 03 00 00 00       	mov    $0x3,%eax
  801899:	e8 79 fe ff ff       	call   801717 <fsipc>
  80189e:	89 c3                	mov    %eax,%ebx
  8018a0:	85 c0                	test   %eax,%eax
  8018a2:	78 4b                	js     8018ef <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018a4:	39 c6                	cmp    %eax,%esi
  8018a6:	73 16                	jae    8018be <devfile_read+0x48>
  8018a8:	68 00 2b 80 00       	push   $0x802b00
  8018ad:	68 e0 2a 80 00       	push   $0x802ae0
  8018b2:	6a 7c                	push   $0x7c
  8018b4:	68 f5 2a 80 00       	push   $0x802af5
  8018b9:	e8 9a e8 ff ff       	call   800158 <_panic>
	assert(r <= PGSIZE);
  8018be:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018c3:	7e 16                	jle    8018db <devfile_read+0x65>
  8018c5:	68 07 2b 80 00       	push   $0x802b07
  8018ca:	68 e0 2a 80 00       	push   $0x802ae0
  8018cf:	6a 7d                	push   $0x7d
  8018d1:	68 f5 2a 80 00       	push   $0x802af5
  8018d6:	e8 7d e8 ff ff       	call   800158 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018db:	83 ec 04             	sub    $0x4,%esp
  8018de:	50                   	push   %eax
  8018df:	68 00 50 80 00       	push   $0x805000
  8018e4:	ff 75 0c             	pushl  0xc(%ebp)
  8018e7:	e8 5c f0 ff ff       	call   800948 <memmove>
	return r;
  8018ec:	83 c4 10             	add    $0x10,%esp
}
  8018ef:	89 d8                	mov    %ebx,%eax
  8018f1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018f4:	5b                   	pop    %ebx
  8018f5:	5e                   	pop    %esi
  8018f6:	5d                   	pop    %ebp
  8018f7:	c3                   	ret    

008018f8 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018f8:	55                   	push   %ebp
  8018f9:	89 e5                	mov    %esp,%ebp
  8018fb:	53                   	push   %ebx
  8018fc:	83 ec 20             	sub    $0x20,%esp
  8018ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801902:	53                   	push   %ebx
  801903:	e8 75 ee ff ff       	call   80077d <strlen>
  801908:	83 c4 10             	add    $0x10,%esp
  80190b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801910:	7f 67                	jg     801979 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801912:	83 ec 0c             	sub    $0xc,%esp
  801915:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801918:	50                   	push   %eax
  801919:	e8 71 f8 ff ff       	call   80118f <fd_alloc>
  80191e:	83 c4 10             	add    $0x10,%esp
		return r;
  801921:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801923:	85 c0                	test   %eax,%eax
  801925:	78 57                	js     80197e <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801927:	83 ec 08             	sub    $0x8,%esp
  80192a:	53                   	push   %ebx
  80192b:	68 00 50 80 00       	push   $0x805000
  801930:	e8 81 ee ff ff       	call   8007b6 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801935:	8b 45 0c             	mov    0xc(%ebp),%eax
  801938:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80193d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801940:	b8 01 00 00 00       	mov    $0x1,%eax
  801945:	e8 cd fd ff ff       	call   801717 <fsipc>
  80194a:	89 c3                	mov    %eax,%ebx
  80194c:	83 c4 10             	add    $0x10,%esp
  80194f:	85 c0                	test   %eax,%eax
  801951:	79 14                	jns    801967 <open+0x6f>
		fd_close(fd, 0);
  801953:	83 ec 08             	sub    $0x8,%esp
  801956:	6a 00                	push   $0x0
  801958:	ff 75 f4             	pushl  -0xc(%ebp)
  80195b:	e8 27 f9 ff ff       	call   801287 <fd_close>
		return r;
  801960:	83 c4 10             	add    $0x10,%esp
  801963:	89 da                	mov    %ebx,%edx
  801965:	eb 17                	jmp    80197e <open+0x86>
	}

	return fd2num(fd);
  801967:	83 ec 0c             	sub    $0xc,%esp
  80196a:	ff 75 f4             	pushl  -0xc(%ebp)
  80196d:	e8 f6 f7 ff ff       	call   801168 <fd2num>
  801972:	89 c2                	mov    %eax,%edx
  801974:	83 c4 10             	add    $0x10,%esp
  801977:	eb 05                	jmp    80197e <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801979:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80197e:	89 d0                	mov    %edx,%eax
  801980:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801983:	c9                   	leave  
  801984:	c3                   	ret    

00801985 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801985:	55                   	push   %ebp
  801986:	89 e5                	mov    %esp,%ebp
  801988:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80198b:	ba 00 00 00 00       	mov    $0x0,%edx
  801990:	b8 08 00 00 00       	mov    $0x8,%eax
  801995:	e8 7d fd ff ff       	call   801717 <fsipc>
}
  80199a:	c9                   	leave  
  80199b:	c3                   	ret    

0080199c <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  80199c:	55                   	push   %ebp
  80199d:	89 e5                	mov    %esp,%ebp
  80199f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8019a2:	68 13 2b 80 00       	push   $0x802b13
  8019a7:	ff 75 0c             	pushl  0xc(%ebp)
  8019aa:	e8 07 ee ff ff       	call   8007b6 <strcpy>
	return 0;
}
  8019af:	b8 00 00 00 00       	mov    $0x0,%eax
  8019b4:	c9                   	leave  
  8019b5:	c3                   	ret    

008019b6 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8019b6:	55                   	push   %ebp
  8019b7:	89 e5                	mov    %esp,%ebp
  8019b9:	53                   	push   %ebx
  8019ba:	83 ec 10             	sub    $0x10,%esp
  8019bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8019c0:	53                   	push   %ebx
  8019c1:	e8 92 09 00 00       	call   802358 <pageref>
  8019c6:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  8019c9:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  8019ce:	83 f8 01             	cmp    $0x1,%eax
  8019d1:	75 10                	jne    8019e3 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  8019d3:	83 ec 0c             	sub    $0xc,%esp
  8019d6:	ff 73 0c             	pushl  0xc(%ebx)
  8019d9:	e8 c0 02 00 00       	call   801c9e <nsipc_close>
  8019de:	89 c2                	mov    %eax,%edx
  8019e0:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8019e3:	89 d0                	mov    %edx,%eax
  8019e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019e8:	c9                   	leave  
  8019e9:	c3                   	ret    

008019ea <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8019ea:	55                   	push   %ebp
  8019eb:	89 e5                	mov    %esp,%ebp
  8019ed:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8019f0:	6a 00                	push   $0x0
  8019f2:	ff 75 10             	pushl  0x10(%ebp)
  8019f5:	ff 75 0c             	pushl  0xc(%ebp)
  8019f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8019fb:	ff 70 0c             	pushl  0xc(%eax)
  8019fe:	e8 78 03 00 00       	call   801d7b <nsipc_send>
}
  801a03:	c9                   	leave  
  801a04:	c3                   	ret    

00801a05 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801a05:	55                   	push   %ebp
  801a06:	89 e5                	mov    %esp,%ebp
  801a08:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801a0b:	6a 00                	push   $0x0
  801a0d:	ff 75 10             	pushl  0x10(%ebp)
  801a10:	ff 75 0c             	pushl  0xc(%ebp)
  801a13:	8b 45 08             	mov    0x8(%ebp),%eax
  801a16:	ff 70 0c             	pushl  0xc(%eax)
  801a19:	e8 f1 02 00 00       	call   801d0f <nsipc_recv>
}
  801a1e:	c9                   	leave  
  801a1f:	c3                   	ret    

00801a20 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801a20:	55                   	push   %ebp
  801a21:	89 e5                	mov    %esp,%ebp
  801a23:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801a26:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801a29:	52                   	push   %edx
  801a2a:	50                   	push   %eax
  801a2b:	e8 ae f7 ff ff       	call   8011de <fd_lookup>
  801a30:	83 c4 10             	add    $0x10,%esp
  801a33:	85 c0                	test   %eax,%eax
  801a35:	78 17                	js     801a4e <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801a37:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a3a:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801a40:	39 08                	cmp    %ecx,(%eax)
  801a42:	75 05                	jne    801a49 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801a44:	8b 40 0c             	mov    0xc(%eax),%eax
  801a47:	eb 05                	jmp    801a4e <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801a49:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801a4e:	c9                   	leave  
  801a4f:	c3                   	ret    

00801a50 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801a50:	55                   	push   %ebp
  801a51:	89 e5                	mov    %esp,%ebp
  801a53:	56                   	push   %esi
  801a54:	53                   	push   %ebx
  801a55:	83 ec 1c             	sub    $0x1c,%esp
  801a58:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801a5a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a5d:	50                   	push   %eax
  801a5e:	e8 2c f7 ff ff       	call   80118f <fd_alloc>
  801a63:	89 c3                	mov    %eax,%ebx
  801a65:	83 c4 10             	add    $0x10,%esp
  801a68:	85 c0                	test   %eax,%eax
  801a6a:	78 1b                	js     801a87 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801a6c:	83 ec 04             	sub    $0x4,%esp
  801a6f:	68 07 04 00 00       	push   $0x407
  801a74:	ff 75 f4             	pushl  -0xc(%ebp)
  801a77:	6a 00                	push   $0x0
  801a79:	e8 3b f1 ff ff       	call   800bb9 <sys_page_alloc>
  801a7e:	89 c3                	mov    %eax,%ebx
  801a80:	83 c4 10             	add    $0x10,%esp
  801a83:	85 c0                	test   %eax,%eax
  801a85:	79 10                	jns    801a97 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801a87:	83 ec 0c             	sub    $0xc,%esp
  801a8a:	56                   	push   %esi
  801a8b:	e8 0e 02 00 00       	call   801c9e <nsipc_close>
		return r;
  801a90:	83 c4 10             	add    $0x10,%esp
  801a93:	89 d8                	mov    %ebx,%eax
  801a95:	eb 24                	jmp    801abb <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801a97:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aa0:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801aa2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aa5:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801aac:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801aaf:	83 ec 0c             	sub    $0xc,%esp
  801ab2:	50                   	push   %eax
  801ab3:	e8 b0 f6 ff ff       	call   801168 <fd2num>
  801ab8:	83 c4 10             	add    $0x10,%esp
}
  801abb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801abe:	5b                   	pop    %ebx
  801abf:	5e                   	pop    %esi
  801ac0:	5d                   	pop    %ebp
  801ac1:	c3                   	ret    

00801ac2 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801ac2:	55                   	push   %ebp
  801ac3:	89 e5                	mov    %esp,%ebp
  801ac5:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ac8:	8b 45 08             	mov    0x8(%ebp),%eax
  801acb:	e8 50 ff ff ff       	call   801a20 <fd2sockid>
		return r;
  801ad0:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ad2:	85 c0                	test   %eax,%eax
  801ad4:	78 1f                	js     801af5 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801ad6:	83 ec 04             	sub    $0x4,%esp
  801ad9:	ff 75 10             	pushl  0x10(%ebp)
  801adc:	ff 75 0c             	pushl  0xc(%ebp)
  801adf:	50                   	push   %eax
  801ae0:	e8 12 01 00 00       	call   801bf7 <nsipc_accept>
  801ae5:	83 c4 10             	add    $0x10,%esp
		return r;
  801ae8:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801aea:	85 c0                	test   %eax,%eax
  801aec:	78 07                	js     801af5 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801aee:	e8 5d ff ff ff       	call   801a50 <alloc_sockfd>
  801af3:	89 c1                	mov    %eax,%ecx
}
  801af5:	89 c8                	mov    %ecx,%eax
  801af7:	c9                   	leave  
  801af8:	c3                   	ret    

00801af9 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801af9:	55                   	push   %ebp
  801afa:	89 e5                	mov    %esp,%ebp
  801afc:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801aff:	8b 45 08             	mov    0x8(%ebp),%eax
  801b02:	e8 19 ff ff ff       	call   801a20 <fd2sockid>
  801b07:	85 c0                	test   %eax,%eax
  801b09:	78 12                	js     801b1d <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801b0b:	83 ec 04             	sub    $0x4,%esp
  801b0e:	ff 75 10             	pushl  0x10(%ebp)
  801b11:	ff 75 0c             	pushl  0xc(%ebp)
  801b14:	50                   	push   %eax
  801b15:	e8 2d 01 00 00       	call   801c47 <nsipc_bind>
  801b1a:	83 c4 10             	add    $0x10,%esp
}
  801b1d:	c9                   	leave  
  801b1e:	c3                   	ret    

00801b1f <shutdown>:

int
shutdown(int s, int how)
{
  801b1f:	55                   	push   %ebp
  801b20:	89 e5                	mov    %esp,%ebp
  801b22:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b25:	8b 45 08             	mov    0x8(%ebp),%eax
  801b28:	e8 f3 fe ff ff       	call   801a20 <fd2sockid>
  801b2d:	85 c0                	test   %eax,%eax
  801b2f:	78 0f                	js     801b40 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801b31:	83 ec 08             	sub    $0x8,%esp
  801b34:	ff 75 0c             	pushl  0xc(%ebp)
  801b37:	50                   	push   %eax
  801b38:	e8 3f 01 00 00       	call   801c7c <nsipc_shutdown>
  801b3d:	83 c4 10             	add    $0x10,%esp
}
  801b40:	c9                   	leave  
  801b41:	c3                   	ret    

00801b42 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801b42:	55                   	push   %ebp
  801b43:	89 e5                	mov    %esp,%ebp
  801b45:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b48:	8b 45 08             	mov    0x8(%ebp),%eax
  801b4b:	e8 d0 fe ff ff       	call   801a20 <fd2sockid>
  801b50:	85 c0                	test   %eax,%eax
  801b52:	78 12                	js     801b66 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801b54:	83 ec 04             	sub    $0x4,%esp
  801b57:	ff 75 10             	pushl  0x10(%ebp)
  801b5a:	ff 75 0c             	pushl  0xc(%ebp)
  801b5d:	50                   	push   %eax
  801b5e:	e8 55 01 00 00       	call   801cb8 <nsipc_connect>
  801b63:	83 c4 10             	add    $0x10,%esp
}
  801b66:	c9                   	leave  
  801b67:	c3                   	ret    

00801b68 <listen>:

int
listen(int s, int backlog)
{
  801b68:	55                   	push   %ebp
  801b69:	89 e5                	mov    %esp,%ebp
  801b6b:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b6e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b71:	e8 aa fe ff ff       	call   801a20 <fd2sockid>
  801b76:	85 c0                	test   %eax,%eax
  801b78:	78 0f                	js     801b89 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801b7a:	83 ec 08             	sub    $0x8,%esp
  801b7d:	ff 75 0c             	pushl  0xc(%ebp)
  801b80:	50                   	push   %eax
  801b81:	e8 67 01 00 00       	call   801ced <nsipc_listen>
  801b86:	83 c4 10             	add    $0x10,%esp
}
  801b89:	c9                   	leave  
  801b8a:	c3                   	ret    

00801b8b <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801b8b:	55                   	push   %ebp
  801b8c:	89 e5                	mov    %esp,%ebp
  801b8e:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801b91:	ff 75 10             	pushl  0x10(%ebp)
  801b94:	ff 75 0c             	pushl  0xc(%ebp)
  801b97:	ff 75 08             	pushl  0x8(%ebp)
  801b9a:	e8 3a 02 00 00       	call   801dd9 <nsipc_socket>
  801b9f:	83 c4 10             	add    $0x10,%esp
  801ba2:	85 c0                	test   %eax,%eax
  801ba4:	78 05                	js     801bab <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801ba6:	e8 a5 fe ff ff       	call   801a50 <alloc_sockfd>
}
  801bab:	c9                   	leave  
  801bac:	c3                   	ret    

00801bad <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801bad:	55                   	push   %ebp
  801bae:	89 e5                	mov    %esp,%ebp
  801bb0:	53                   	push   %ebx
  801bb1:	83 ec 04             	sub    $0x4,%esp
  801bb4:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801bb6:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801bbd:	75 12                	jne    801bd1 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801bbf:	83 ec 0c             	sub    $0xc,%esp
  801bc2:	6a 02                	push   $0x2
  801bc4:	e8 66 f5 ff ff       	call   80112f <ipc_find_env>
  801bc9:	a3 04 40 80 00       	mov    %eax,0x804004
  801bce:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801bd1:	6a 07                	push   $0x7
  801bd3:	68 00 60 80 00       	push   $0x806000
  801bd8:	53                   	push   %ebx
  801bd9:	ff 35 04 40 80 00    	pushl  0x804004
  801bdf:	e8 f7 f4 ff ff       	call   8010db <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801be4:	83 c4 0c             	add    $0xc,%esp
  801be7:	6a 00                	push   $0x0
  801be9:	6a 00                	push   $0x0
  801beb:	6a 00                	push   $0x0
  801bed:	e8 80 f4 ff ff       	call   801072 <ipc_recv>
}
  801bf2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bf5:	c9                   	leave  
  801bf6:	c3                   	ret    

00801bf7 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801bf7:	55                   	push   %ebp
  801bf8:	89 e5                	mov    %esp,%ebp
  801bfa:	56                   	push   %esi
  801bfb:	53                   	push   %ebx
  801bfc:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801bff:	8b 45 08             	mov    0x8(%ebp),%eax
  801c02:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801c07:	8b 06                	mov    (%esi),%eax
  801c09:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801c0e:	b8 01 00 00 00       	mov    $0x1,%eax
  801c13:	e8 95 ff ff ff       	call   801bad <nsipc>
  801c18:	89 c3                	mov    %eax,%ebx
  801c1a:	85 c0                	test   %eax,%eax
  801c1c:	78 20                	js     801c3e <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801c1e:	83 ec 04             	sub    $0x4,%esp
  801c21:	ff 35 10 60 80 00    	pushl  0x806010
  801c27:	68 00 60 80 00       	push   $0x806000
  801c2c:	ff 75 0c             	pushl  0xc(%ebp)
  801c2f:	e8 14 ed ff ff       	call   800948 <memmove>
		*addrlen = ret->ret_addrlen;
  801c34:	a1 10 60 80 00       	mov    0x806010,%eax
  801c39:	89 06                	mov    %eax,(%esi)
  801c3b:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801c3e:	89 d8                	mov    %ebx,%eax
  801c40:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c43:	5b                   	pop    %ebx
  801c44:	5e                   	pop    %esi
  801c45:	5d                   	pop    %ebp
  801c46:	c3                   	ret    

00801c47 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c47:	55                   	push   %ebp
  801c48:	89 e5                	mov    %esp,%ebp
  801c4a:	53                   	push   %ebx
  801c4b:	83 ec 08             	sub    $0x8,%esp
  801c4e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801c51:	8b 45 08             	mov    0x8(%ebp),%eax
  801c54:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801c59:	53                   	push   %ebx
  801c5a:	ff 75 0c             	pushl  0xc(%ebp)
  801c5d:	68 04 60 80 00       	push   $0x806004
  801c62:	e8 e1 ec ff ff       	call   800948 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801c67:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801c6d:	b8 02 00 00 00       	mov    $0x2,%eax
  801c72:	e8 36 ff ff ff       	call   801bad <nsipc>
}
  801c77:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c7a:	c9                   	leave  
  801c7b:	c3                   	ret    

00801c7c <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801c7c:	55                   	push   %ebp
  801c7d:	89 e5                	mov    %esp,%ebp
  801c7f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801c82:	8b 45 08             	mov    0x8(%ebp),%eax
  801c85:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801c8a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c8d:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801c92:	b8 03 00 00 00       	mov    $0x3,%eax
  801c97:	e8 11 ff ff ff       	call   801bad <nsipc>
}
  801c9c:	c9                   	leave  
  801c9d:	c3                   	ret    

00801c9e <nsipc_close>:

int
nsipc_close(int s)
{
  801c9e:	55                   	push   %ebp
  801c9f:	89 e5                	mov    %esp,%ebp
  801ca1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801ca4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca7:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801cac:	b8 04 00 00 00       	mov    $0x4,%eax
  801cb1:	e8 f7 fe ff ff       	call   801bad <nsipc>
}
  801cb6:	c9                   	leave  
  801cb7:	c3                   	ret    

00801cb8 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801cb8:	55                   	push   %ebp
  801cb9:	89 e5                	mov    %esp,%ebp
  801cbb:	53                   	push   %ebx
  801cbc:	83 ec 08             	sub    $0x8,%esp
  801cbf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801cc2:	8b 45 08             	mov    0x8(%ebp),%eax
  801cc5:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801cca:	53                   	push   %ebx
  801ccb:	ff 75 0c             	pushl  0xc(%ebp)
  801cce:	68 04 60 80 00       	push   $0x806004
  801cd3:	e8 70 ec ff ff       	call   800948 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801cd8:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801cde:	b8 05 00 00 00       	mov    $0x5,%eax
  801ce3:	e8 c5 fe ff ff       	call   801bad <nsipc>
}
  801ce8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ceb:	c9                   	leave  
  801cec:	c3                   	ret    

00801ced <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801ced:	55                   	push   %ebp
  801cee:	89 e5                	mov    %esp,%ebp
  801cf0:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801cf3:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf6:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801cfb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cfe:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801d03:	b8 06 00 00 00       	mov    $0x6,%eax
  801d08:	e8 a0 fe ff ff       	call   801bad <nsipc>
}
  801d0d:	c9                   	leave  
  801d0e:	c3                   	ret    

00801d0f <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801d0f:	55                   	push   %ebp
  801d10:	89 e5                	mov    %esp,%ebp
  801d12:	56                   	push   %esi
  801d13:	53                   	push   %ebx
  801d14:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801d17:	8b 45 08             	mov    0x8(%ebp),%eax
  801d1a:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801d1f:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801d25:	8b 45 14             	mov    0x14(%ebp),%eax
  801d28:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801d2d:	b8 07 00 00 00       	mov    $0x7,%eax
  801d32:	e8 76 fe ff ff       	call   801bad <nsipc>
  801d37:	89 c3                	mov    %eax,%ebx
  801d39:	85 c0                	test   %eax,%eax
  801d3b:	78 35                	js     801d72 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801d3d:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801d42:	7f 04                	jg     801d48 <nsipc_recv+0x39>
  801d44:	39 c6                	cmp    %eax,%esi
  801d46:	7d 16                	jge    801d5e <nsipc_recv+0x4f>
  801d48:	68 1f 2b 80 00       	push   $0x802b1f
  801d4d:	68 e0 2a 80 00       	push   $0x802ae0
  801d52:	6a 62                	push   $0x62
  801d54:	68 34 2b 80 00       	push   $0x802b34
  801d59:	e8 fa e3 ff ff       	call   800158 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801d5e:	83 ec 04             	sub    $0x4,%esp
  801d61:	50                   	push   %eax
  801d62:	68 00 60 80 00       	push   $0x806000
  801d67:	ff 75 0c             	pushl  0xc(%ebp)
  801d6a:	e8 d9 eb ff ff       	call   800948 <memmove>
  801d6f:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801d72:	89 d8                	mov    %ebx,%eax
  801d74:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d77:	5b                   	pop    %ebx
  801d78:	5e                   	pop    %esi
  801d79:	5d                   	pop    %ebp
  801d7a:	c3                   	ret    

00801d7b <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801d7b:	55                   	push   %ebp
  801d7c:	89 e5                	mov    %esp,%ebp
  801d7e:	53                   	push   %ebx
  801d7f:	83 ec 04             	sub    $0x4,%esp
  801d82:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801d85:	8b 45 08             	mov    0x8(%ebp),%eax
  801d88:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801d8d:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801d93:	7e 16                	jle    801dab <nsipc_send+0x30>
  801d95:	68 40 2b 80 00       	push   $0x802b40
  801d9a:	68 e0 2a 80 00       	push   $0x802ae0
  801d9f:	6a 6d                	push   $0x6d
  801da1:	68 34 2b 80 00       	push   $0x802b34
  801da6:	e8 ad e3 ff ff       	call   800158 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801dab:	83 ec 04             	sub    $0x4,%esp
  801dae:	53                   	push   %ebx
  801daf:	ff 75 0c             	pushl  0xc(%ebp)
  801db2:	68 0c 60 80 00       	push   $0x80600c
  801db7:	e8 8c eb ff ff       	call   800948 <memmove>
	nsipcbuf.send.req_size = size;
  801dbc:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801dc2:	8b 45 14             	mov    0x14(%ebp),%eax
  801dc5:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801dca:	b8 08 00 00 00       	mov    $0x8,%eax
  801dcf:	e8 d9 fd ff ff       	call   801bad <nsipc>
}
  801dd4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801dd7:	c9                   	leave  
  801dd8:	c3                   	ret    

00801dd9 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801dd9:	55                   	push   %ebp
  801dda:	89 e5                	mov    %esp,%ebp
  801ddc:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801ddf:	8b 45 08             	mov    0x8(%ebp),%eax
  801de2:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801de7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dea:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801def:	8b 45 10             	mov    0x10(%ebp),%eax
  801df2:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801df7:	b8 09 00 00 00       	mov    $0x9,%eax
  801dfc:	e8 ac fd ff ff       	call   801bad <nsipc>
}
  801e01:	c9                   	leave  
  801e02:	c3                   	ret    

00801e03 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e03:	55                   	push   %ebp
  801e04:	89 e5                	mov    %esp,%ebp
  801e06:	56                   	push   %esi
  801e07:	53                   	push   %ebx
  801e08:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e0b:	83 ec 0c             	sub    $0xc,%esp
  801e0e:	ff 75 08             	pushl  0x8(%ebp)
  801e11:	e8 62 f3 ff ff       	call   801178 <fd2data>
  801e16:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801e18:	83 c4 08             	add    $0x8,%esp
  801e1b:	68 4c 2b 80 00       	push   $0x802b4c
  801e20:	53                   	push   %ebx
  801e21:	e8 90 e9 ff ff       	call   8007b6 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e26:	8b 46 04             	mov    0x4(%esi),%eax
  801e29:	2b 06                	sub    (%esi),%eax
  801e2b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801e31:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801e38:	00 00 00 
	stat->st_dev = &devpipe;
  801e3b:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801e42:	30 80 00 
	return 0;
}
  801e45:	b8 00 00 00 00       	mov    $0x0,%eax
  801e4a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e4d:	5b                   	pop    %ebx
  801e4e:	5e                   	pop    %esi
  801e4f:	5d                   	pop    %ebp
  801e50:	c3                   	ret    

00801e51 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801e51:	55                   	push   %ebp
  801e52:	89 e5                	mov    %esp,%ebp
  801e54:	53                   	push   %ebx
  801e55:	83 ec 0c             	sub    $0xc,%esp
  801e58:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801e5b:	53                   	push   %ebx
  801e5c:	6a 00                	push   $0x0
  801e5e:	e8 db ed ff ff       	call   800c3e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801e63:	89 1c 24             	mov    %ebx,(%esp)
  801e66:	e8 0d f3 ff ff       	call   801178 <fd2data>
  801e6b:	83 c4 08             	add    $0x8,%esp
  801e6e:	50                   	push   %eax
  801e6f:	6a 00                	push   $0x0
  801e71:	e8 c8 ed ff ff       	call   800c3e <sys_page_unmap>
}
  801e76:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e79:	c9                   	leave  
  801e7a:	c3                   	ret    

00801e7b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801e7b:	55                   	push   %ebp
  801e7c:	89 e5                	mov    %esp,%ebp
  801e7e:	57                   	push   %edi
  801e7f:	56                   	push   %esi
  801e80:	53                   	push   %ebx
  801e81:	83 ec 1c             	sub    $0x1c,%esp
  801e84:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801e87:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801e89:	a1 08 40 80 00       	mov    0x804008,%eax
  801e8e:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801e91:	83 ec 0c             	sub    $0xc,%esp
  801e94:	ff 75 e0             	pushl  -0x20(%ebp)
  801e97:	e8 bc 04 00 00       	call   802358 <pageref>
  801e9c:	89 c3                	mov    %eax,%ebx
  801e9e:	89 3c 24             	mov    %edi,(%esp)
  801ea1:	e8 b2 04 00 00       	call   802358 <pageref>
  801ea6:	83 c4 10             	add    $0x10,%esp
  801ea9:	39 c3                	cmp    %eax,%ebx
  801eab:	0f 94 c1             	sete   %cl
  801eae:	0f b6 c9             	movzbl %cl,%ecx
  801eb1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801eb4:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801eba:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ebd:	39 ce                	cmp    %ecx,%esi
  801ebf:	74 1b                	je     801edc <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801ec1:	39 c3                	cmp    %eax,%ebx
  801ec3:	75 c4                	jne    801e89 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ec5:	8b 42 58             	mov    0x58(%edx),%eax
  801ec8:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ecb:	50                   	push   %eax
  801ecc:	56                   	push   %esi
  801ecd:	68 53 2b 80 00       	push   $0x802b53
  801ed2:	e8 5a e3 ff ff       	call   800231 <cprintf>
  801ed7:	83 c4 10             	add    $0x10,%esp
  801eda:	eb ad                	jmp    801e89 <_pipeisclosed+0xe>
	}
}
  801edc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801edf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ee2:	5b                   	pop    %ebx
  801ee3:	5e                   	pop    %esi
  801ee4:	5f                   	pop    %edi
  801ee5:	5d                   	pop    %ebp
  801ee6:	c3                   	ret    

00801ee7 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ee7:	55                   	push   %ebp
  801ee8:	89 e5                	mov    %esp,%ebp
  801eea:	57                   	push   %edi
  801eeb:	56                   	push   %esi
  801eec:	53                   	push   %ebx
  801eed:	83 ec 28             	sub    $0x28,%esp
  801ef0:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801ef3:	56                   	push   %esi
  801ef4:	e8 7f f2 ff ff       	call   801178 <fd2data>
  801ef9:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801efb:	83 c4 10             	add    $0x10,%esp
  801efe:	bf 00 00 00 00       	mov    $0x0,%edi
  801f03:	eb 4b                	jmp    801f50 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801f05:	89 da                	mov    %ebx,%edx
  801f07:	89 f0                	mov    %esi,%eax
  801f09:	e8 6d ff ff ff       	call   801e7b <_pipeisclosed>
  801f0e:	85 c0                	test   %eax,%eax
  801f10:	75 48                	jne    801f5a <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801f12:	e8 83 ec ff ff       	call   800b9a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f17:	8b 43 04             	mov    0x4(%ebx),%eax
  801f1a:	8b 0b                	mov    (%ebx),%ecx
  801f1c:	8d 51 20             	lea    0x20(%ecx),%edx
  801f1f:	39 d0                	cmp    %edx,%eax
  801f21:	73 e2                	jae    801f05 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f26:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801f2a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801f2d:	89 c2                	mov    %eax,%edx
  801f2f:	c1 fa 1f             	sar    $0x1f,%edx
  801f32:	89 d1                	mov    %edx,%ecx
  801f34:	c1 e9 1b             	shr    $0x1b,%ecx
  801f37:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801f3a:	83 e2 1f             	and    $0x1f,%edx
  801f3d:	29 ca                	sub    %ecx,%edx
  801f3f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801f43:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801f47:	83 c0 01             	add    $0x1,%eax
  801f4a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f4d:	83 c7 01             	add    $0x1,%edi
  801f50:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801f53:	75 c2                	jne    801f17 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801f55:	8b 45 10             	mov    0x10(%ebp),%eax
  801f58:	eb 05                	jmp    801f5f <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f5a:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801f5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f62:	5b                   	pop    %ebx
  801f63:	5e                   	pop    %esi
  801f64:	5f                   	pop    %edi
  801f65:	5d                   	pop    %ebp
  801f66:	c3                   	ret    

00801f67 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f67:	55                   	push   %ebp
  801f68:	89 e5                	mov    %esp,%ebp
  801f6a:	57                   	push   %edi
  801f6b:	56                   	push   %esi
  801f6c:	53                   	push   %ebx
  801f6d:	83 ec 18             	sub    $0x18,%esp
  801f70:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801f73:	57                   	push   %edi
  801f74:	e8 ff f1 ff ff       	call   801178 <fd2data>
  801f79:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f7b:	83 c4 10             	add    $0x10,%esp
  801f7e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f83:	eb 3d                	jmp    801fc2 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801f85:	85 db                	test   %ebx,%ebx
  801f87:	74 04                	je     801f8d <devpipe_read+0x26>
				return i;
  801f89:	89 d8                	mov    %ebx,%eax
  801f8b:	eb 44                	jmp    801fd1 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801f8d:	89 f2                	mov    %esi,%edx
  801f8f:	89 f8                	mov    %edi,%eax
  801f91:	e8 e5 fe ff ff       	call   801e7b <_pipeisclosed>
  801f96:	85 c0                	test   %eax,%eax
  801f98:	75 32                	jne    801fcc <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801f9a:	e8 fb eb ff ff       	call   800b9a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801f9f:	8b 06                	mov    (%esi),%eax
  801fa1:	3b 46 04             	cmp    0x4(%esi),%eax
  801fa4:	74 df                	je     801f85 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801fa6:	99                   	cltd   
  801fa7:	c1 ea 1b             	shr    $0x1b,%edx
  801faa:	01 d0                	add    %edx,%eax
  801fac:	83 e0 1f             	and    $0x1f,%eax
  801faf:	29 d0                	sub    %edx,%eax
  801fb1:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801fb6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801fb9:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801fbc:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fbf:	83 c3 01             	add    $0x1,%ebx
  801fc2:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801fc5:	75 d8                	jne    801f9f <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801fc7:	8b 45 10             	mov    0x10(%ebp),%eax
  801fca:	eb 05                	jmp    801fd1 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801fcc:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801fd1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fd4:	5b                   	pop    %ebx
  801fd5:	5e                   	pop    %esi
  801fd6:	5f                   	pop    %edi
  801fd7:	5d                   	pop    %ebp
  801fd8:	c3                   	ret    

00801fd9 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801fd9:	55                   	push   %ebp
  801fda:	89 e5                	mov    %esp,%ebp
  801fdc:	56                   	push   %esi
  801fdd:	53                   	push   %ebx
  801fde:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801fe1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fe4:	50                   	push   %eax
  801fe5:	e8 a5 f1 ff ff       	call   80118f <fd_alloc>
  801fea:	83 c4 10             	add    $0x10,%esp
  801fed:	89 c2                	mov    %eax,%edx
  801fef:	85 c0                	test   %eax,%eax
  801ff1:	0f 88 2c 01 00 00    	js     802123 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ff7:	83 ec 04             	sub    $0x4,%esp
  801ffa:	68 07 04 00 00       	push   $0x407
  801fff:	ff 75 f4             	pushl  -0xc(%ebp)
  802002:	6a 00                	push   $0x0
  802004:	e8 b0 eb ff ff       	call   800bb9 <sys_page_alloc>
  802009:	83 c4 10             	add    $0x10,%esp
  80200c:	89 c2                	mov    %eax,%edx
  80200e:	85 c0                	test   %eax,%eax
  802010:	0f 88 0d 01 00 00    	js     802123 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802016:	83 ec 0c             	sub    $0xc,%esp
  802019:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80201c:	50                   	push   %eax
  80201d:	e8 6d f1 ff ff       	call   80118f <fd_alloc>
  802022:	89 c3                	mov    %eax,%ebx
  802024:	83 c4 10             	add    $0x10,%esp
  802027:	85 c0                	test   %eax,%eax
  802029:	0f 88 e2 00 00 00    	js     802111 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80202f:	83 ec 04             	sub    $0x4,%esp
  802032:	68 07 04 00 00       	push   $0x407
  802037:	ff 75 f0             	pushl  -0x10(%ebp)
  80203a:	6a 00                	push   $0x0
  80203c:	e8 78 eb ff ff       	call   800bb9 <sys_page_alloc>
  802041:	89 c3                	mov    %eax,%ebx
  802043:	83 c4 10             	add    $0x10,%esp
  802046:	85 c0                	test   %eax,%eax
  802048:	0f 88 c3 00 00 00    	js     802111 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80204e:	83 ec 0c             	sub    $0xc,%esp
  802051:	ff 75 f4             	pushl  -0xc(%ebp)
  802054:	e8 1f f1 ff ff       	call   801178 <fd2data>
  802059:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80205b:	83 c4 0c             	add    $0xc,%esp
  80205e:	68 07 04 00 00       	push   $0x407
  802063:	50                   	push   %eax
  802064:	6a 00                	push   $0x0
  802066:	e8 4e eb ff ff       	call   800bb9 <sys_page_alloc>
  80206b:	89 c3                	mov    %eax,%ebx
  80206d:	83 c4 10             	add    $0x10,%esp
  802070:	85 c0                	test   %eax,%eax
  802072:	0f 88 89 00 00 00    	js     802101 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802078:	83 ec 0c             	sub    $0xc,%esp
  80207b:	ff 75 f0             	pushl  -0x10(%ebp)
  80207e:	e8 f5 f0 ff ff       	call   801178 <fd2data>
  802083:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80208a:	50                   	push   %eax
  80208b:	6a 00                	push   $0x0
  80208d:	56                   	push   %esi
  80208e:	6a 00                	push   $0x0
  802090:	e8 67 eb ff ff       	call   800bfc <sys_page_map>
  802095:	89 c3                	mov    %eax,%ebx
  802097:	83 c4 20             	add    $0x20,%esp
  80209a:	85 c0                	test   %eax,%eax
  80209c:	78 55                	js     8020f3 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80209e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020a7:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8020a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020ac:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8020b3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020bc:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8020be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020c1:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8020c8:	83 ec 0c             	sub    $0xc,%esp
  8020cb:	ff 75 f4             	pushl  -0xc(%ebp)
  8020ce:	e8 95 f0 ff ff       	call   801168 <fd2num>
  8020d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020d6:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8020d8:	83 c4 04             	add    $0x4,%esp
  8020db:	ff 75 f0             	pushl  -0x10(%ebp)
  8020de:	e8 85 f0 ff ff       	call   801168 <fd2num>
  8020e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020e6:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8020e9:	83 c4 10             	add    $0x10,%esp
  8020ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8020f1:	eb 30                	jmp    802123 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8020f3:	83 ec 08             	sub    $0x8,%esp
  8020f6:	56                   	push   %esi
  8020f7:	6a 00                	push   $0x0
  8020f9:	e8 40 eb ff ff       	call   800c3e <sys_page_unmap>
  8020fe:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802101:	83 ec 08             	sub    $0x8,%esp
  802104:	ff 75 f0             	pushl  -0x10(%ebp)
  802107:	6a 00                	push   $0x0
  802109:	e8 30 eb ff ff       	call   800c3e <sys_page_unmap>
  80210e:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802111:	83 ec 08             	sub    $0x8,%esp
  802114:	ff 75 f4             	pushl  -0xc(%ebp)
  802117:	6a 00                	push   $0x0
  802119:	e8 20 eb ff ff       	call   800c3e <sys_page_unmap>
  80211e:	83 c4 10             	add    $0x10,%esp
  802121:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802123:	89 d0                	mov    %edx,%eax
  802125:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802128:	5b                   	pop    %ebx
  802129:	5e                   	pop    %esi
  80212a:	5d                   	pop    %ebp
  80212b:	c3                   	ret    

0080212c <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80212c:	55                   	push   %ebp
  80212d:	89 e5                	mov    %esp,%ebp
  80212f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802132:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802135:	50                   	push   %eax
  802136:	ff 75 08             	pushl  0x8(%ebp)
  802139:	e8 a0 f0 ff ff       	call   8011de <fd_lookup>
  80213e:	83 c4 10             	add    $0x10,%esp
  802141:	85 c0                	test   %eax,%eax
  802143:	78 18                	js     80215d <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802145:	83 ec 0c             	sub    $0xc,%esp
  802148:	ff 75 f4             	pushl  -0xc(%ebp)
  80214b:	e8 28 f0 ff ff       	call   801178 <fd2data>
	return _pipeisclosed(fd, p);
  802150:	89 c2                	mov    %eax,%edx
  802152:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802155:	e8 21 fd ff ff       	call   801e7b <_pipeisclosed>
  80215a:	83 c4 10             	add    $0x10,%esp
}
  80215d:	c9                   	leave  
  80215e:	c3                   	ret    

0080215f <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80215f:	55                   	push   %ebp
  802160:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802162:	b8 00 00 00 00       	mov    $0x0,%eax
  802167:	5d                   	pop    %ebp
  802168:	c3                   	ret    

00802169 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802169:	55                   	push   %ebp
  80216a:	89 e5                	mov    %esp,%ebp
  80216c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80216f:	68 6b 2b 80 00       	push   $0x802b6b
  802174:	ff 75 0c             	pushl  0xc(%ebp)
  802177:	e8 3a e6 ff ff       	call   8007b6 <strcpy>
	return 0;
}
  80217c:	b8 00 00 00 00       	mov    $0x0,%eax
  802181:	c9                   	leave  
  802182:	c3                   	ret    

00802183 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802183:	55                   	push   %ebp
  802184:	89 e5                	mov    %esp,%ebp
  802186:	57                   	push   %edi
  802187:	56                   	push   %esi
  802188:	53                   	push   %ebx
  802189:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80218f:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802194:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80219a:	eb 2d                	jmp    8021c9 <devcons_write+0x46>
		m = n - tot;
  80219c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80219f:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8021a1:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8021a4:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8021a9:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8021ac:	83 ec 04             	sub    $0x4,%esp
  8021af:	53                   	push   %ebx
  8021b0:	03 45 0c             	add    0xc(%ebp),%eax
  8021b3:	50                   	push   %eax
  8021b4:	57                   	push   %edi
  8021b5:	e8 8e e7 ff ff       	call   800948 <memmove>
		sys_cputs(buf, m);
  8021ba:	83 c4 08             	add    $0x8,%esp
  8021bd:	53                   	push   %ebx
  8021be:	57                   	push   %edi
  8021bf:	e8 39 e9 ff ff       	call   800afd <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021c4:	01 de                	add    %ebx,%esi
  8021c6:	83 c4 10             	add    $0x10,%esp
  8021c9:	89 f0                	mov    %esi,%eax
  8021cb:	3b 75 10             	cmp    0x10(%ebp),%esi
  8021ce:	72 cc                	jb     80219c <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8021d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021d3:	5b                   	pop    %ebx
  8021d4:	5e                   	pop    %esi
  8021d5:	5f                   	pop    %edi
  8021d6:	5d                   	pop    %ebp
  8021d7:	c3                   	ret    

008021d8 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8021d8:	55                   	push   %ebp
  8021d9:	89 e5                	mov    %esp,%ebp
  8021db:	83 ec 08             	sub    $0x8,%esp
  8021de:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8021e3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8021e7:	74 2a                	je     802213 <devcons_read+0x3b>
  8021e9:	eb 05                	jmp    8021f0 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8021eb:	e8 aa e9 ff ff       	call   800b9a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8021f0:	e8 26 e9 ff ff       	call   800b1b <sys_cgetc>
  8021f5:	85 c0                	test   %eax,%eax
  8021f7:	74 f2                	je     8021eb <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8021f9:	85 c0                	test   %eax,%eax
  8021fb:	78 16                	js     802213 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8021fd:	83 f8 04             	cmp    $0x4,%eax
  802200:	74 0c                	je     80220e <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802202:	8b 55 0c             	mov    0xc(%ebp),%edx
  802205:	88 02                	mov    %al,(%edx)
	return 1;
  802207:	b8 01 00 00 00       	mov    $0x1,%eax
  80220c:	eb 05                	jmp    802213 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80220e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802213:	c9                   	leave  
  802214:	c3                   	ret    

00802215 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802215:	55                   	push   %ebp
  802216:	89 e5                	mov    %esp,%ebp
  802218:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80221b:	8b 45 08             	mov    0x8(%ebp),%eax
  80221e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802221:	6a 01                	push   $0x1
  802223:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802226:	50                   	push   %eax
  802227:	e8 d1 e8 ff ff       	call   800afd <sys_cputs>
}
  80222c:	83 c4 10             	add    $0x10,%esp
  80222f:	c9                   	leave  
  802230:	c3                   	ret    

00802231 <getchar>:

int
getchar(void)
{
  802231:	55                   	push   %ebp
  802232:	89 e5                	mov    %esp,%ebp
  802234:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802237:	6a 01                	push   $0x1
  802239:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80223c:	50                   	push   %eax
  80223d:	6a 00                	push   $0x0
  80223f:	e8 00 f2 ff ff       	call   801444 <read>
	if (r < 0)
  802244:	83 c4 10             	add    $0x10,%esp
  802247:	85 c0                	test   %eax,%eax
  802249:	78 0f                	js     80225a <getchar+0x29>
		return r;
	if (r < 1)
  80224b:	85 c0                	test   %eax,%eax
  80224d:	7e 06                	jle    802255 <getchar+0x24>
		return -E_EOF;
	return c;
  80224f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802253:	eb 05                	jmp    80225a <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802255:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80225a:	c9                   	leave  
  80225b:	c3                   	ret    

0080225c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80225c:	55                   	push   %ebp
  80225d:	89 e5                	mov    %esp,%ebp
  80225f:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802262:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802265:	50                   	push   %eax
  802266:	ff 75 08             	pushl  0x8(%ebp)
  802269:	e8 70 ef ff ff       	call   8011de <fd_lookup>
  80226e:	83 c4 10             	add    $0x10,%esp
  802271:	85 c0                	test   %eax,%eax
  802273:	78 11                	js     802286 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802275:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802278:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80227e:	39 10                	cmp    %edx,(%eax)
  802280:	0f 94 c0             	sete   %al
  802283:	0f b6 c0             	movzbl %al,%eax
}
  802286:	c9                   	leave  
  802287:	c3                   	ret    

00802288 <opencons>:

int
opencons(void)
{
  802288:	55                   	push   %ebp
  802289:	89 e5                	mov    %esp,%ebp
  80228b:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80228e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802291:	50                   	push   %eax
  802292:	e8 f8 ee ff ff       	call   80118f <fd_alloc>
  802297:	83 c4 10             	add    $0x10,%esp
		return r;
  80229a:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80229c:	85 c0                	test   %eax,%eax
  80229e:	78 3e                	js     8022de <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8022a0:	83 ec 04             	sub    $0x4,%esp
  8022a3:	68 07 04 00 00       	push   $0x407
  8022a8:	ff 75 f4             	pushl  -0xc(%ebp)
  8022ab:	6a 00                	push   $0x0
  8022ad:	e8 07 e9 ff ff       	call   800bb9 <sys_page_alloc>
  8022b2:	83 c4 10             	add    $0x10,%esp
		return r;
  8022b5:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8022b7:	85 c0                	test   %eax,%eax
  8022b9:	78 23                	js     8022de <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8022bb:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8022c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022c4:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8022c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022c9:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8022d0:	83 ec 0c             	sub    $0xc,%esp
  8022d3:	50                   	push   %eax
  8022d4:	e8 8f ee ff ff       	call   801168 <fd2num>
  8022d9:	89 c2                	mov    %eax,%edx
  8022db:	83 c4 10             	add    $0x10,%esp
}
  8022de:	89 d0                	mov    %edx,%eax
  8022e0:	c9                   	leave  
  8022e1:	c3                   	ret    

008022e2 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8022e2:	55                   	push   %ebp
  8022e3:	89 e5                	mov    %esp,%ebp
  8022e5:	53                   	push   %ebx
  8022e6:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  8022e9:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8022f0:	75 28                	jne    80231a <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  8022f2:	e8 84 e8 ff ff       	call   800b7b <sys_getenvid>
  8022f7:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_U | PTE_W);
  8022f9:	83 ec 04             	sub    $0x4,%esp
  8022fc:	6a 06                	push   $0x6
  8022fe:	68 00 f0 bf ee       	push   $0xeebff000
  802303:	50                   	push   %eax
  802304:	e8 b0 e8 ff ff       	call   800bb9 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  802309:	83 c4 08             	add    $0x8,%esp
  80230c:	68 27 23 80 00       	push   $0x802327
  802311:	53                   	push   %ebx
  802312:	e8 ed e9 ff ff       	call   800d04 <sys_env_set_pgfault_upcall>
  802317:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80231a:	8b 45 08             	mov    0x8(%ebp),%eax
  80231d:	a3 00 70 80 00       	mov    %eax,0x807000
}
  802322:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802325:	c9                   	leave  
  802326:	c3                   	ret    

00802327 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802327:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802328:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  80232d:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80232f:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	# My method is different. Copy the values to the other stack
	# in a convinient way, and then pop everything.
	movl %esp, %ebp		# ebp refers to the exception stack
  802332:	89 e5                	mov    %esp,%ebp
	movl 48(%ebp), %esp 	# go to other stack
  802334:	8b 65 30             	mov    0x30(%ebp),%esp

	pushl 40(%ebp)		# eip - ORDER SWITCHED WITH EFLAGS
  802337:	ff 75 28             	pushl  0x28(%ebp)
	pushl 44(%ebp)      	# eflags
  80233a:	ff 75 2c             	pushl  0x2c(%ebp)
	pushl 36(%ebp)		# all the 8 remaining regs
  80233d:	ff 75 24             	pushl  0x24(%ebp)
	pushl 32(%ebp)
  802340:	ff 75 20             	pushl  0x20(%ebp)
	pushl 28(%ebp)
  802343:	ff 75 1c             	pushl  0x1c(%ebp)
	pushl 24(%ebp)
  802346:	ff 75 18             	pushl  0x18(%ebp)
	pushl 20(%ebp)
  802349:	ff 75 14             	pushl  0x14(%ebp)
	pushl 16(%ebp)
  80234c:	ff 75 10             	pushl  0x10(%ebp)
	pushl 12(%ebp)
  80234f:	ff 75 0c             	pushl  0xc(%ebp)
	pushl 8(%ebp)
  802352:	ff 75 08             	pushl  0x8(%ebp)

	popal			# now just pop everything!
  802355:	61                   	popa   
	popfl
  802356:	9d                   	popf   
	ret
  802357:	c3                   	ret    

00802358 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802358:	55                   	push   %ebp
  802359:	89 e5                	mov    %esp,%ebp
  80235b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80235e:	89 d0                	mov    %edx,%eax
  802360:	c1 e8 16             	shr    $0x16,%eax
  802363:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80236a:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80236f:	f6 c1 01             	test   $0x1,%cl
  802372:	74 1d                	je     802391 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802374:	c1 ea 0c             	shr    $0xc,%edx
  802377:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80237e:	f6 c2 01             	test   $0x1,%dl
  802381:	74 0e                	je     802391 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802383:	c1 ea 0c             	shr    $0xc,%edx
  802386:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80238d:	ef 
  80238e:	0f b7 c0             	movzwl %ax,%eax
}
  802391:	5d                   	pop    %ebp
  802392:	c3                   	ret    
  802393:	66 90                	xchg   %ax,%ax
  802395:	66 90                	xchg   %ax,%ax
  802397:	66 90                	xchg   %ax,%ax
  802399:	66 90                	xchg   %ax,%ax
  80239b:	66 90                	xchg   %ax,%ax
  80239d:	66 90                	xchg   %ax,%ax
  80239f:	90                   	nop

008023a0 <__udivdi3>:
  8023a0:	55                   	push   %ebp
  8023a1:	57                   	push   %edi
  8023a2:	56                   	push   %esi
  8023a3:	53                   	push   %ebx
  8023a4:	83 ec 1c             	sub    $0x1c,%esp
  8023a7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8023ab:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8023af:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8023b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8023b7:	85 f6                	test   %esi,%esi
  8023b9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023bd:	89 ca                	mov    %ecx,%edx
  8023bf:	89 f8                	mov    %edi,%eax
  8023c1:	75 3d                	jne    802400 <__udivdi3+0x60>
  8023c3:	39 cf                	cmp    %ecx,%edi
  8023c5:	0f 87 c5 00 00 00    	ja     802490 <__udivdi3+0xf0>
  8023cb:	85 ff                	test   %edi,%edi
  8023cd:	89 fd                	mov    %edi,%ebp
  8023cf:	75 0b                	jne    8023dc <__udivdi3+0x3c>
  8023d1:	b8 01 00 00 00       	mov    $0x1,%eax
  8023d6:	31 d2                	xor    %edx,%edx
  8023d8:	f7 f7                	div    %edi
  8023da:	89 c5                	mov    %eax,%ebp
  8023dc:	89 c8                	mov    %ecx,%eax
  8023de:	31 d2                	xor    %edx,%edx
  8023e0:	f7 f5                	div    %ebp
  8023e2:	89 c1                	mov    %eax,%ecx
  8023e4:	89 d8                	mov    %ebx,%eax
  8023e6:	89 cf                	mov    %ecx,%edi
  8023e8:	f7 f5                	div    %ebp
  8023ea:	89 c3                	mov    %eax,%ebx
  8023ec:	89 d8                	mov    %ebx,%eax
  8023ee:	89 fa                	mov    %edi,%edx
  8023f0:	83 c4 1c             	add    $0x1c,%esp
  8023f3:	5b                   	pop    %ebx
  8023f4:	5e                   	pop    %esi
  8023f5:	5f                   	pop    %edi
  8023f6:	5d                   	pop    %ebp
  8023f7:	c3                   	ret    
  8023f8:	90                   	nop
  8023f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802400:	39 ce                	cmp    %ecx,%esi
  802402:	77 74                	ja     802478 <__udivdi3+0xd8>
  802404:	0f bd fe             	bsr    %esi,%edi
  802407:	83 f7 1f             	xor    $0x1f,%edi
  80240a:	0f 84 98 00 00 00    	je     8024a8 <__udivdi3+0x108>
  802410:	bb 20 00 00 00       	mov    $0x20,%ebx
  802415:	89 f9                	mov    %edi,%ecx
  802417:	89 c5                	mov    %eax,%ebp
  802419:	29 fb                	sub    %edi,%ebx
  80241b:	d3 e6                	shl    %cl,%esi
  80241d:	89 d9                	mov    %ebx,%ecx
  80241f:	d3 ed                	shr    %cl,%ebp
  802421:	89 f9                	mov    %edi,%ecx
  802423:	d3 e0                	shl    %cl,%eax
  802425:	09 ee                	or     %ebp,%esi
  802427:	89 d9                	mov    %ebx,%ecx
  802429:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80242d:	89 d5                	mov    %edx,%ebp
  80242f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802433:	d3 ed                	shr    %cl,%ebp
  802435:	89 f9                	mov    %edi,%ecx
  802437:	d3 e2                	shl    %cl,%edx
  802439:	89 d9                	mov    %ebx,%ecx
  80243b:	d3 e8                	shr    %cl,%eax
  80243d:	09 c2                	or     %eax,%edx
  80243f:	89 d0                	mov    %edx,%eax
  802441:	89 ea                	mov    %ebp,%edx
  802443:	f7 f6                	div    %esi
  802445:	89 d5                	mov    %edx,%ebp
  802447:	89 c3                	mov    %eax,%ebx
  802449:	f7 64 24 0c          	mull   0xc(%esp)
  80244d:	39 d5                	cmp    %edx,%ebp
  80244f:	72 10                	jb     802461 <__udivdi3+0xc1>
  802451:	8b 74 24 08          	mov    0x8(%esp),%esi
  802455:	89 f9                	mov    %edi,%ecx
  802457:	d3 e6                	shl    %cl,%esi
  802459:	39 c6                	cmp    %eax,%esi
  80245b:	73 07                	jae    802464 <__udivdi3+0xc4>
  80245d:	39 d5                	cmp    %edx,%ebp
  80245f:	75 03                	jne    802464 <__udivdi3+0xc4>
  802461:	83 eb 01             	sub    $0x1,%ebx
  802464:	31 ff                	xor    %edi,%edi
  802466:	89 d8                	mov    %ebx,%eax
  802468:	89 fa                	mov    %edi,%edx
  80246a:	83 c4 1c             	add    $0x1c,%esp
  80246d:	5b                   	pop    %ebx
  80246e:	5e                   	pop    %esi
  80246f:	5f                   	pop    %edi
  802470:	5d                   	pop    %ebp
  802471:	c3                   	ret    
  802472:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802478:	31 ff                	xor    %edi,%edi
  80247a:	31 db                	xor    %ebx,%ebx
  80247c:	89 d8                	mov    %ebx,%eax
  80247e:	89 fa                	mov    %edi,%edx
  802480:	83 c4 1c             	add    $0x1c,%esp
  802483:	5b                   	pop    %ebx
  802484:	5e                   	pop    %esi
  802485:	5f                   	pop    %edi
  802486:	5d                   	pop    %ebp
  802487:	c3                   	ret    
  802488:	90                   	nop
  802489:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802490:	89 d8                	mov    %ebx,%eax
  802492:	f7 f7                	div    %edi
  802494:	31 ff                	xor    %edi,%edi
  802496:	89 c3                	mov    %eax,%ebx
  802498:	89 d8                	mov    %ebx,%eax
  80249a:	89 fa                	mov    %edi,%edx
  80249c:	83 c4 1c             	add    $0x1c,%esp
  80249f:	5b                   	pop    %ebx
  8024a0:	5e                   	pop    %esi
  8024a1:	5f                   	pop    %edi
  8024a2:	5d                   	pop    %ebp
  8024a3:	c3                   	ret    
  8024a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8024a8:	39 ce                	cmp    %ecx,%esi
  8024aa:	72 0c                	jb     8024b8 <__udivdi3+0x118>
  8024ac:	31 db                	xor    %ebx,%ebx
  8024ae:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8024b2:	0f 87 34 ff ff ff    	ja     8023ec <__udivdi3+0x4c>
  8024b8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8024bd:	e9 2a ff ff ff       	jmp    8023ec <__udivdi3+0x4c>
  8024c2:	66 90                	xchg   %ax,%ax
  8024c4:	66 90                	xchg   %ax,%ax
  8024c6:	66 90                	xchg   %ax,%ax
  8024c8:	66 90                	xchg   %ax,%ax
  8024ca:	66 90                	xchg   %ax,%ax
  8024cc:	66 90                	xchg   %ax,%ax
  8024ce:	66 90                	xchg   %ax,%ax

008024d0 <__umoddi3>:
  8024d0:	55                   	push   %ebp
  8024d1:	57                   	push   %edi
  8024d2:	56                   	push   %esi
  8024d3:	53                   	push   %ebx
  8024d4:	83 ec 1c             	sub    $0x1c,%esp
  8024d7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8024db:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8024df:	8b 74 24 34          	mov    0x34(%esp),%esi
  8024e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8024e7:	85 d2                	test   %edx,%edx
  8024e9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8024ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024f1:	89 f3                	mov    %esi,%ebx
  8024f3:	89 3c 24             	mov    %edi,(%esp)
  8024f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024fa:	75 1c                	jne    802518 <__umoddi3+0x48>
  8024fc:	39 f7                	cmp    %esi,%edi
  8024fe:	76 50                	jbe    802550 <__umoddi3+0x80>
  802500:	89 c8                	mov    %ecx,%eax
  802502:	89 f2                	mov    %esi,%edx
  802504:	f7 f7                	div    %edi
  802506:	89 d0                	mov    %edx,%eax
  802508:	31 d2                	xor    %edx,%edx
  80250a:	83 c4 1c             	add    $0x1c,%esp
  80250d:	5b                   	pop    %ebx
  80250e:	5e                   	pop    %esi
  80250f:	5f                   	pop    %edi
  802510:	5d                   	pop    %ebp
  802511:	c3                   	ret    
  802512:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802518:	39 f2                	cmp    %esi,%edx
  80251a:	89 d0                	mov    %edx,%eax
  80251c:	77 52                	ja     802570 <__umoddi3+0xa0>
  80251e:	0f bd ea             	bsr    %edx,%ebp
  802521:	83 f5 1f             	xor    $0x1f,%ebp
  802524:	75 5a                	jne    802580 <__umoddi3+0xb0>
  802526:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80252a:	0f 82 e0 00 00 00    	jb     802610 <__umoddi3+0x140>
  802530:	39 0c 24             	cmp    %ecx,(%esp)
  802533:	0f 86 d7 00 00 00    	jbe    802610 <__umoddi3+0x140>
  802539:	8b 44 24 08          	mov    0x8(%esp),%eax
  80253d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802541:	83 c4 1c             	add    $0x1c,%esp
  802544:	5b                   	pop    %ebx
  802545:	5e                   	pop    %esi
  802546:	5f                   	pop    %edi
  802547:	5d                   	pop    %ebp
  802548:	c3                   	ret    
  802549:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802550:	85 ff                	test   %edi,%edi
  802552:	89 fd                	mov    %edi,%ebp
  802554:	75 0b                	jne    802561 <__umoddi3+0x91>
  802556:	b8 01 00 00 00       	mov    $0x1,%eax
  80255b:	31 d2                	xor    %edx,%edx
  80255d:	f7 f7                	div    %edi
  80255f:	89 c5                	mov    %eax,%ebp
  802561:	89 f0                	mov    %esi,%eax
  802563:	31 d2                	xor    %edx,%edx
  802565:	f7 f5                	div    %ebp
  802567:	89 c8                	mov    %ecx,%eax
  802569:	f7 f5                	div    %ebp
  80256b:	89 d0                	mov    %edx,%eax
  80256d:	eb 99                	jmp    802508 <__umoddi3+0x38>
  80256f:	90                   	nop
  802570:	89 c8                	mov    %ecx,%eax
  802572:	89 f2                	mov    %esi,%edx
  802574:	83 c4 1c             	add    $0x1c,%esp
  802577:	5b                   	pop    %ebx
  802578:	5e                   	pop    %esi
  802579:	5f                   	pop    %edi
  80257a:	5d                   	pop    %ebp
  80257b:	c3                   	ret    
  80257c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802580:	8b 34 24             	mov    (%esp),%esi
  802583:	bf 20 00 00 00       	mov    $0x20,%edi
  802588:	89 e9                	mov    %ebp,%ecx
  80258a:	29 ef                	sub    %ebp,%edi
  80258c:	d3 e0                	shl    %cl,%eax
  80258e:	89 f9                	mov    %edi,%ecx
  802590:	89 f2                	mov    %esi,%edx
  802592:	d3 ea                	shr    %cl,%edx
  802594:	89 e9                	mov    %ebp,%ecx
  802596:	09 c2                	or     %eax,%edx
  802598:	89 d8                	mov    %ebx,%eax
  80259a:	89 14 24             	mov    %edx,(%esp)
  80259d:	89 f2                	mov    %esi,%edx
  80259f:	d3 e2                	shl    %cl,%edx
  8025a1:	89 f9                	mov    %edi,%ecx
  8025a3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8025a7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8025ab:	d3 e8                	shr    %cl,%eax
  8025ad:	89 e9                	mov    %ebp,%ecx
  8025af:	89 c6                	mov    %eax,%esi
  8025b1:	d3 e3                	shl    %cl,%ebx
  8025b3:	89 f9                	mov    %edi,%ecx
  8025b5:	89 d0                	mov    %edx,%eax
  8025b7:	d3 e8                	shr    %cl,%eax
  8025b9:	89 e9                	mov    %ebp,%ecx
  8025bb:	09 d8                	or     %ebx,%eax
  8025bd:	89 d3                	mov    %edx,%ebx
  8025bf:	89 f2                	mov    %esi,%edx
  8025c1:	f7 34 24             	divl   (%esp)
  8025c4:	89 d6                	mov    %edx,%esi
  8025c6:	d3 e3                	shl    %cl,%ebx
  8025c8:	f7 64 24 04          	mull   0x4(%esp)
  8025cc:	39 d6                	cmp    %edx,%esi
  8025ce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8025d2:	89 d1                	mov    %edx,%ecx
  8025d4:	89 c3                	mov    %eax,%ebx
  8025d6:	72 08                	jb     8025e0 <__umoddi3+0x110>
  8025d8:	75 11                	jne    8025eb <__umoddi3+0x11b>
  8025da:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8025de:	73 0b                	jae    8025eb <__umoddi3+0x11b>
  8025e0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8025e4:	1b 14 24             	sbb    (%esp),%edx
  8025e7:	89 d1                	mov    %edx,%ecx
  8025e9:	89 c3                	mov    %eax,%ebx
  8025eb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8025ef:	29 da                	sub    %ebx,%edx
  8025f1:	19 ce                	sbb    %ecx,%esi
  8025f3:	89 f9                	mov    %edi,%ecx
  8025f5:	89 f0                	mov    %esi,%eax
  8025f7:	d3 e0                	shl    %cl,%eax
  8025f9:	89 e9                	mov    %ebp,%ecx
  8025fb:	d3 ea                	shr    %cl,%edx
  8025fd:	89 e9                	mov    %ebp,%ecx
  8025ff:	d3 ee                	shr    %cl,%esi
  802601:	09 d0                	or     %edx,%eax
  802603:	89 f2                	mov    %esi,%edx
  802605:	83 c4 1c             	add    $0x1c,%esp
  802608:	5b                   	pop    %ebx
  802609:	5e                   	pop    %esi
  80260a:	5f                   	pop    %edi
  80260b:	5d                   	pop    %ebp
  80260c:	c3                   	ret    
  80260d:	8d 76 00             	lea    0x0(%esi),%esi
  802610:	29 f9                	sub    %edi,%ecx
  802612:	19 d6                	sbb    %edx,%esi
  802614:	89 74 24 04          	mov    %esi,0x4(%esp)
  802618:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80261c:	e9 18 ff ff ff       	jmp    802539 <__umoddi3+0x69>
