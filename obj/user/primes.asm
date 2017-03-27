
obj/user/primes:     file format elf32-i386


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
  800047:	e8 cb 0f 00 00       	call   801017 <ipc_recv>
  80004c:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80004e:	a1 04 20 80 00       	mov    0x802004,%eax
  800053:	8b 40 5c             	mov    0x5c(%eax),%eax
  800056:	83 c4 0c             	add    $0xc,%esp
  800059:	53                   	push   %ebx
  80005a:	50                   	push   %eax
  80005b:	68 40 14 80 00       	push   $0x801440
  800060:	e8 c4 01 00 00       	call   800229 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800065:	e8 aa 0d 00 00       	call   800e14 <fork>
  80006a:	89 c7                	mov    %eax,%edi
  80006c:	83 c4 10             	add    $0x10,%esp
  80006f:	85 c0                	test   %eax,%eax
  800071:	79 12                	jns    800085 <primeproc+0x52>
		panic("fork: %e", id);
  800073:	50                   	push   %eax
  800074:	68 4c 14 80 00       	push   $0x80144c
  800079:	6a 1a                	push   $0x1a
  80007b:	68 55 14 80 00       	push   $0x801455
  800080:	e8 cb 00 00 00       	call   800150 <_panic>
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
  800094:	e8 7e 0f 00 00       	call   801017 <ipc_recv>
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
  8000ab:	e8 cd 0f 00 00       	call   80107d <ipc_send>
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
  8000ba:	e8 55 0d 00 00       	call   800e14 <fork>
  8000bf:	89 c6                	mov    %eax,%esi
  8000c1:	85 c0                	test   %eax,%eax
  8000c3:	79 12                	jns    8000d7 <umain+0x22>
		panic("fork: %e", id);
  8000c5:	50                   	push   %eax
  8000c6:	68 4c 14 80 00       	push   $0x80144c
  8000cb:	6a 2d                	push   $0x2d
  8000cd:	68 55 14 80 00       	push   $0x801455
  8000d2:	e8 79 00 00 00       	call   800150 <_panic>
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
  8000eb:	e8 8d 0f 00 00       	call   80107d <ipc_send>
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

	thisenv = (struct Env *) envs + ENVX(sys_getenvid());
  800103:	e8 6b 0a 00 00       	call   800b73 <sys_getenvid>
  800108:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800110:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800115:	a3 04 20 80 00       	mov    %eax,0x802004


	// save the name of the program so that panic() can use it
	if (argc > 0)
  80011a:	85 db                	test   %ebx,%ebx
  80011c:	7e 07                	jle    800125 <libmain+0x2d>
		binaryname = argv[0];
  80011e:	8b 06                	mov    (%esi),%eax
  800120:	a3 00 20 80 00       	mov    %eax,0x802000

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
  800141:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800144:	6a 00                	push   $0x0
  800146:	e8 e7 09 00 00       	call   800b32 <sys_env_destroy>
}
  80014b:	83 c4 10             	add    $0x10,%esp
  80014e:	c9                   	leave  
  80014f:	c3                   	ret    

00800150 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800150:	55                   	push   %ebp
  800151:	89 e5                	mov    %esp,%ebp
  800153:	56                   	push   %esi
  800154:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800155:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800158:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80015e:	e8 10 0a 00 00       	call   800b73 <sys_getenvid>
  800163:	83 ec 0c             	sub    $0xc,%esp
  800166:	ff 75 0c             	pushl  0xc(%ebp)
  800169:	ff 75 08             	pushl  0x8(%ebp)
  80016c:	56                   	push   %esi
  80016d:	50                   	push   %eax
  80016e:	68 70 14 80 00       	push   $0x801470
  800173:	e8 b1 00 00 00       	call   800229 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800178:	83 c4 18             	add    $0x18,%esp
  80017b:	53                   	push   %ebx
  80017c:	ff 75 10             	pushl  0x10(%ebp)
  80017f:	e8 54 00 00 00       	call   8001d8 <vcprintf>
	cprintf("\n");
  800184:	c7 04 24 93 14 80 00 	movl   $0x801493,(%esp)
  80018b:	e8 99 00 00 00       	call   800229 <cprintf>
  800190:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800193:	cc                   	int3   
  800194:	eb fd                	jmp    800193 <_panic+0x43>

00800196 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800196:	55                   	push   %ebp
  800197:	89 e5                	mov    %esp,%ebp
  800199:	53                   	push   %ebx
  80019a:	83 ec 04             	sub    $0x4,%esp
  80019d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001a0:	8b 13                	mov    (%ebx),%edx
  8001a2:	8d 42 01             	lea    0x1(%edx),%eax
  8001a5:	89 03                	mov    %eax,(%ebx)
  8001a7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001aa:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001ae:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001b3:	75 1a                	jne    8001cf <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001b5:	83 ec 08             	sub    $0x8,%esp
  8001b8:	68 ff 00 00 00       	push   $0xff
  8001bd:	8d 43 08             	lea    0x8(%ebx),%eax
  8001c0:	50                   	push   %eax
  8001c1:	e8 2f 09 00 00       	call   800af5 <sys_cputs>
		b->idx = 0;
  8001c6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001cc:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001cf:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001d6:	c9                   	leave  
  8001d7:	c3                   	ret    

008001d8 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001d8:	55                   	push   %ebp
  8001d9:	89 e5                	mov    %esp,%ebp
  8001db:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001e1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001e8:	00 00 00 
	b.cnt = 0;
  8001eb:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001f2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001f5:	ff 75 0c             	pushl  0xc(%ebp)
  8001f8:	ff 75 08             	pushl  0x8(%ebp)
  8001fb:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800201:	50                   	push   %eax
  800202:	68 96 01 80 00       	push   $0x800196
  800207:	e8 54 01 00 00       	call   800360 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80020c:	83 c4 08             	add    $0x8,%esp
  80020f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800215:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80021b:	50                   	push   %eax
  80021c:	e8 d4 08 00 00       	call   800af5 <sys_cputs>

	return b.cnt;
}
  800221:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800227:	c9                   	leave  
  800228:	c3                   	ret    

00800229 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800229:	55                   	push   %ebp
  80022a:	89 e5                	mov    %esp,%ebp
  80022c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80022f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800232:	50                   	push   %eax
  800233:	ff 75 08             	pushl  0x8(%ebp)
  800236:	e8 9d ff ff ff       	call   8001d8 <vcprintf>
	va_end(ap);

	return cnt;
}
  80023b:	c9                   	leave  
  80023c:	c3                   	ret    

0080023d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80023d:	55                   	push   %ebp
  80023e:	89 e5                	mov    %esp,%ebp
  800240:	57                   	push   %edi
  800241:	56                   	push   %esi
  800242:	53                   	push   %ebx
  800243:	83 ec 1c             	sub    $0x1c,%esp
  800246:	89 c7                	mov    %eax,%edi
  800248:	89 d6                	mov    %edx,%esi
  80024a:	8b 45 08             	mov    0x8(%ebp),%eax
  80024d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800250:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800253:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800256:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800259:	bb 00 00 00 00       	mov    $0x0,%ebx
  80025e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800261:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800264:	39 d3                	cmp    %edx,%ebx
  800266:	72 05                	jb     80026d <printnum+0x30>
  800268:	39 45 10             	cmp    %eax,0x10(%ebp)
  80026b:	77 45                	ja     8002b2 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80026d:	83 ec 0c             	sub    $0xc,%esp
  800270:	ff 75 18             	pushl  0x18(%ebp)
  800273:	8b 45 14             	mov    0x14(%ebp),%eax
  800276:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800279:	53                   	push   %ebx
  80027a:	ff 75 10             	pushl  0x10(%ebp)
  80027d:	83 ec 08             	sub    $0x8,%esp
  800280:	ff 75 e4             	pushl  -0x1c(%ebp)
  800283:	ff 75 e0             	pushl  -0x20(%ebp)
  800286:	ff 75 dc             	pushl  -0x24(%ebp)
  800289:	ff 75 d8             	pushl  -0x28(%ebp)
  80028c:	e8 0f 0f 00 00       	call   8011a0 <__udivdi3>
  800291:	83 c4 18             	add    $0x18,%esp
  800294:	52                   	push   %edx
  800295:	50                   	push   %eax
  800296:	89 f2                	mov    %esi,%edx
  800298:	89 f8                	mov    %edi,%eax
  80029a:	e8 9e ff ff ff       	call   80023d <printnum>
  80029f:	83 c4 20             	add    $0x20,%esp
  8002a2:	eb 18                	jmp    8002bc <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002a4:	83 ec 08             	sub    $0x8,%esp
  8002a7:	56                   	push   %esi
  8002a8:	ff 75 18             	pushl  0x18(%ebp)
  8002ab:	ff d7                	call   *%edi
  8002ad:	83 c4 10             	add    $0x10,%esp
  8002b0:	eb 03                	jmp    8002b5 <printnum+0x78>
  8002b2:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002b5:	83 eb 01             	sub    $0x1,%ebx
  8002b8:	85 db                	test   %ebx,%ebx
  8002ba:	7f e8                	jg     8002a4 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002bc:	83 ec 08             	sub    $0x8,%esp
  8002bf:	56                   	push   %esi
  8002c0:	83 ec 04             	sub    $0x4,%esp
  8002c3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002c6:	ff 75 e0             	pushl  -0x20(%ebp)
  8002c9:	ff 75 dc             	pushl  -0x24(%ebp)
  8002cc:	ff 75 d8             	pushl  -0x28(%ebp)
  8002cf:	e8 fc 0f 00 00       	call   8012d0 <__umoddi3>
  8002d4:	83 c4 14             	add    $0x14,%esp
  8002d7:	0f be 80 95 14 80 00 	movsbl 0x801495(%eax),%eax
  8002de:	50                   	push   %eax
  8002df:	ff d7                	call   *%edi
}
  8002e1:	83 c4 10             	add    $0x10,%esp
  8002e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e7:	5b                   	pop    %ebx
  8002e8:	5e                   	pop    %esi
  8002e9:	5f                   	pop    %edi
  8002ea:	5d                   	pop    %ebp
  8002eb:	c3                   	ret    

008002ec <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002ec:	55                   	push   %ebp
  8002ed:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002ef:	83 fa 01             	cmp    $0x1,%edx
  8002f2:	7e 0e                	jle    800302 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002f4:	8b 10                	mov    (%eax),%edx
  8002f6:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002f9:	89 08                	mov    %ecx,(%eax)
  8002fb:	8b 02                	mov    (%edx),%eax
  8002fd:	8b 52 04             	mov    0x4(%edx),%edx
  800300:	eb 22                	jmp    800324 <getuint+0x38>
	else if (lflag)
  800302:	85 d2                	test   %edx,%edx
  800304:	74 10                	je     800316 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800306:	8b 10                	mov    (%eax),%edx
  800308:	8d 4a 04             	lea    0x4(%edx),%ecx
  80030b:	89 08                	mov    %ecx,(%eax)
  80030d:	8b 02                	mov    (%edx),%eax
  80030f:	ba 00 00 00 00       	mov    $0x0,%edx
  800314:	eb 0e                	jmp    800324 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800316:	8b 10                	mov    (%eax),%edx
  800318:	8d 4a 04             	lea    0x4(%edx),%ecx
  80031b:	89 08                	mov    %ecx,(%eax)
  80031d:	8b 02                	mov    (%edx),%eax
  80031f:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800324:	5d                   	pop    %ebp
  800325:	c3                   	ret    

00800326 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800326:	55                   	push   %ebp
  800327:	89 e5                	mov    %esp,%ebp
  800329:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80032c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800330:	8b 10                	mov    (%eax),%edx
  800332:	3b 50 04             	cmp    0x4(%eax),%edx
  800335:	73 0a                	jae    800341 <sprintputch+0x1b>
		*b->buf++ = ch;
  800337:	8d 4a 01             	lea    0x1(%edx),%ecx
  80033a:	89 08                	mov    %ecx,(%eax)
  80033c:	8b 45 08             	mov    0x8(%ebp),%eax
  80033f:	88 02                	mov    %al,(%edx)
}
  800341:	5d                   	pop    %ebp
  800342:	c3                   	ret    

00800343 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800343:	55                   	push   %ebp
  800344:	89 e5                	mov    %esp,%ebp
  800346:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800349:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80034c:	50                   	push   %eax
  80034d:	ff 75 10             	pushl  0x10(%ebp)
  800350:	ff 75 0c             	pushl  0xc(%ebp)
  800353:	ff 75 08             	pushl  0x8(%ebp)
  800356:	e8 05 00 00 00       	call   800360 <vprintfmt>
	va_end(ap);
}
  80035b:	83 c4 10             	add    $0x10,%esp
  80035e:	c9                   	leave  
  80035f:	c3                   	ret    

00800360 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800360:	55                   	push   %ebp
  800361:	89 e5                	mov    %esp,%ebp
  800363:	57                   	push   %edi
  800364:	56                   	push   %esi
  800365:	53                   	push   %ebx
  800366:	83 ec 2c             	sub    $0x2c,%esp
  800369:	8b 75 08             	mov    0x8(%ebp),%esi
  80036c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80036f:	8b 7d 10             	mov    0x10(%ebp),%edi
  800372:	eb 12                	jmp    800386 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800374:	85 c0                	test   %eax,%eax
  800376:	0f 84 89 03 00 00    	je     800705 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80037c:	83 ec 08             	sub    $0x8,%esp
  80037f:	53                   	push   %ebx
  800380:	50                   	push   %eax
  800381:	ff d6                	call   *%esi
  800383:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800386:	83 c7 01             	add    $0x1,%edi
  800389:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80038d:	83 f8 25             	cmp    $0x25,%eax
  800390:	75 e2                	jne    800374 <vprintfmt+0x14>
  800392:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800396:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80039d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003a4:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b0:	eb 07                	jmp    8003b9 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003b5:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b9:	8d 47 01             	lea    0x1(%edi),%eax
  8003bc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003bf:	0f b6 07             	movzbl (%edi),%eax
  8003c2:	0f b6 c8             	movzbl %al,%ecx
  8003c5:	83 e8 23             	sub    $0x23,%eax
  8003c8:	3c 55                	cmp    $0x55,%al
  8003ca:	0f 87 1a 03 00 00    	ja     8006ea <vprintfmt+0x38a>
  8003d0:	0f b6 c0             	movzbl %al,%eax
  8003d3:	ff 24 85 60 15 80 00 	jmp    *0x801560(,%eax,4)
  8003da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003dd:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003e1:	eb d6                	jmp    8003b9 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8003eb:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003ee:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003f1:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003f5:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003f8:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003fb:	83 fa 09             	cmp    $0x9,%edx
  8003fe:	77 39                	ja     800439 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800400:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800403:	eb e9                	jmp    8003ee <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800405:	8b 45 14             	mov    0x14(%ebp),%eax
  800408:	8d 48 04             	lea    0x4(%eax),%ecx
  80040b:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80040e:	8b 00                	mov    (%eax),%eax
  800410:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800413:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800416:	eb 27                	jmp    80043f <vprintfmt+0xdf>
  800418:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80041b:	85 c0                	test   %eax,%eax
  80041d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800422:	0f 49 c8             	cmovns %eax,%ecx
  800425:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800428:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80042b:	eb 8c                	jmp    8003b9 <vprintfmt+0x59>
  80042d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800430:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800437:	eb 80                	jmp    8003b9 <vprintfmt+0x59>
  800439:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80043c:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80043f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800443:	0f 89 70 ff ff ff    	jns    8003b9 <vprintfmt+0x59>
				width = precision, precision = -1;
  800449:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80044c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80044f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800456:	e9 5e ff ff ff       	jmp    8003b9 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80045b:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800461:	e9 53 ff ff ff       	jmp    8003b9 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800466:	8b 45 14             	mov    0x14(%ebp),%eax
  800469:	8d 50 04             	lea    0x4(%eax),%edx
  80046c:	89 55 14             	mov    %edx,0x14(%ebp)
  80046f:	83 ec 08             	sub    $0x8,%esp
  800472:	53                   	push   %ebx
  800473:	ff 30                	pushl  (%eax)
  800475:	ff d6                	call   *%esi
			break;
  800477:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80047d:	e9 04 ff ff ff       	jmp    800386 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800482:	8b 45 14             	mov    0x14(%ebp),%eax
  800485:	8d 50 04             	lea    0x4(%eax),%edx
  800488:	89 55 14             	mov    %edx,0x14(%ebp)
  80048b:	8b 00                	mov    (%eax),%eax
  80048d:	99                   	cltd   
  80048e:	31 d0                	xor    %edx,%eax
  800490:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800492:	83 f8 08             	cmp    $0x8,%eax
  800495:	7f 0b                	jg     8004a2 <vprintfmt+0x142>
  800497:	8b 14 85 c0 16 80 00 	mov    0x8016c0(,%eax,4),%edx
  80049e:	85 d2                	test   %edx,%edx
  8004a0:	75 18                	jne    8004ba <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004a2:	50                   	push   %eax
  8004a3:	68 ad 14 80 00       	push   $0x8014ad
  8004a8:	53                   	push   %ebx
  8004a9:	56                   	push   %esi
  8004aa:	e8 94 fe ff ff       	call   800343 <printfmt>
  8004af:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004b5:	e9 cc fe ff ff       	jmp    800386 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004ba:	52                   	push   %edx
  8004bb:	68 b6 14 80 00       	push   $0x8014b6
  8004c0:	53                   	push   %ebx
  8004c1:	56                   	push   %esi
  8004c2:	e8 7c fe ff ff       	call   800343 <printfmt>
  8004c7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004cd:	e9 b4 fe ff ff       	jmp    800386 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d5:	8d 50 04             	lea    0x4(%eax),%edx
  8004d8:	89 55 14             	mov    %edx,0x14(%ebp)
  8004db:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004dd:	85 ff                	test   %edi,%edi
  8004df:	b8 a6 14 80 00       	mov    $0x8014a6,%eax
  8004e4:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004e7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004eb:	0f 8e 94 00 00 00    	jle    800585 <vprintfmt+0x225>
  8004f1:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004f5:	0f 84 98 00 00 00    	je     800593 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004fb:	83 ec 08             	sub    $0x8,%esp
  8004fe:	ff 75 d0             	pushl  -0x30(%ebp)
  800501:	57                   	push   %edi
  800502:	e8 86 02 00 00       	call   80078d <strnlen>
  800507:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80050a:	29 c1                	sub    %eax,%ecx
  80050c:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80050f:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800512:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800516:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800519:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80051c:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80051e:	eb 0f                	jmp    80052f <vprintfmt+0x1cf>
					putch(padc, putdat);
  800520:	83 ec 08             	sub    $0x8,%esp
  800523:	53                   	push   %ebx
  800524:	ff 75 e0             	pushl  -0x20(%ebp)
  800527:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800529:	83 ef 01             	sub    $0x1,%edi
  80052c:	83 c4 10             	add    $0x10,%esp
  80052f:	85 ff                	test   %edi,%edi
  800531:	7f ed                	jg     800520 <vprintfmt+0x1c0>
  800533:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800536:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800539:	85 c9                	test   %ecx,%ecx
  80053b:	b8 00 00 00 00       	mov    $0x0,%eax
  800540:	0f 49 c1             	cmovns %ecx,%eax
  800543:	29 c1                	sub    %eax,%ecx
  800545:	89 75 08             	mov    %esi,0x8(%ebp)
  800548:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80054b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80054e:	89 cb                	mov    %ecx,%ebx
  800550:	eb 4d                	jmp    80059f <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800552:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800556:	74 1b                	je     800573 <vprintfmt+0x213>
  800558:	0f be c0             	movsbl %al,%eax
  80055b:	83 e8 20             	sub    $0x20,%eax
  80055e:	83 f8 5e             	cmp    $0x5e,%eax
  800561:	76 10                	jbe    800573 <vprintfmt+0x213>
					putch('?', putdat);
  800563:	83 ec 08             	sub    $0x8,%esp
  800566:	ff 75 0c             	pushl  0xc(%ebp)
  800569:	6a 3f                	push   $0x3f
  80056b:	ff 55 08             	call   *0x8(%ebp)
  80056e:	83 c4 10             	add    $0x10,%esp
  800571:	eb 0d                	jmp    800580 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800573:	83 ec 08             	sub    $0x8,%esp
  800576:	ff 75 0c             	pushl  0xc(%ebp)
  800579:	52                   	push   %edx
  80057a:	ff 55 08             	call   *0x8(%ebp)
  80057d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800580:	83 eb 01             	sub    $0x1,%ebx
  800583:	eb 1a                	jmp    80059f <vprintfmt+0x23f>
  800585:	89 75 08             	mov    %esi,0x8(%ebp)
  800588:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80058b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80058e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800591:	eb 0c                	jmp    80059f <vprintfmt+0x23f>
  800593:	89 75 08             	mov    %esi,0x8(%ebp)
  800596:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800599:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80059c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80059f:	83 c7 01             	add    $0x1,%edi
  8005a2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005a6:	0f be d0             	movsbl %al,%edx
  8005a9:	85 d2                	test   %edx,%edx
  8005ab:	74 23                	je     8005d0 <vprintfmt+0x270>
  8005ad:	85 f6                	test   %esi,%esi
  8005af:	78 a1                	js     800552 <vprintfmt+0x1f2>
  8005b1:	83 ee 01             	sub    $0x1,%esi
  8005b4:	79 9c                	jns    800552 <vprintfmt+0x1f2>
  8005b6:	89 df                	mov    %ebx,%edi
  8005b8:	8b 75 08             	mov    0x8(%ebp),%esi
  8005bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005be:	eb 18                	jmp    8005d8 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005c0:	83 ec 08             	sub    $0x8,%esp
  8005c3:	53                   	push   %ebx
  8005c4:	6a 20                	push   $0x20
  8005c6:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005c8:	83 ef 01             	sub    $0x1,%edi
  8005cb:	83 c4 10             	add    $0x10,%esp
  8005ce:	eb 08                	jmp    8005d8 <vprintfmt+0x278>
  8005d0:	89 df                	mov    %ebx,%edi
  8005d2:	8b 75 08             	mov    0x8(%ebp),%esi
  8005d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005d8:	85 ff                	test   %edi,%edi
  8005da:	7f e4                	jg     8005c0 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005df:	e9 a2 fd ff ff       	jmp    800386 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005e4:	83 fa 01             	cmp    $0x1,%edx
  8005e7:	7e 16                	jle    8005ff <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ec:	8d 50 08             	lea    0x8(%eax),%edx
  8005ef:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f2:	8b 50 04             	mov    0x4(%eax),%edx
  8005f5:	8b 00                	mov    (%eax),%eax
  8005f7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005fa:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005fd:	eb 32                	jmp    800631 <vprintfmt+0x2d1>
	else if (lflag)
  8005ff:	85 d2                	test   %edx,%edx
  800601:	74 18                	je     80061b <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800603:	8b 45 14             	mov    0x14(%ebp),%eax
  800606:	8d 50 04             	lea    0x4(%eax),%edx
  800609:	89 55 14             	mov    %edx,0x14(%ebp)
  80060c:	8b 00                	mov    (%eax),%eax
  80060e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800611:	89 c1                	mov    %eax,%ecx
  800613:	c1 f9 1f             	sar    $0x1f,%ecx
  800616:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800619:	eb 16                	jmp    800631 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80061b:	8b 45 14             	mov    0x14(%ebp),%eax
  80061e:	8d 50 04             	lea    0x4(%eax),%edx
  800621:	89 55 14             	mov    %edx,0x14(%ebp)
  800624:	8b 00                	mov    (%eax),%eax
  800626:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800629:	89 c1                	mov    %eax,%ecx
  80062b:	c1 f9 1f             	sar    $0x1f,%ecx
  80062e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800631:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800634:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800637:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80063c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800640:	79 74                	jns    8006b6 <vprintfmt+0x356>
				putch('-', putdat);
  800642:	83 ec 08             	sub    $0x8,%esp
  800645:	53                   	push   %ebx
  800646:	6a 2d                	push   $0x2d
  800648:	ff d6                	call   *%esi
				num = -(long long) num;
  80064a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80064d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800650:	f7 d8                	neg    %eax
  800652:	83 d2 00             	adc    $0x0,%edx
  800655:	f7 da                	neg    %edx
  800657:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80065a:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80065f:	eb 55                	jmp    8006b6 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800661:	8d 45 14             	lea    0x14(%ebp),%eax
  800664:	e8 83 fc ff ff       	call   8002ec <getuint>
			base = 10;
  800669:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80066e:	eb 46                	jmp    8006b6 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800670:	8d 45 14             	lea    0x14(%ebp),%eax
  800673:	e8 74 fc ff ff       	call   8002ec <getuint>
			base = 8;
  800678:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80067d:	eb 37                	jmp    8006b6 <vprintfmt+0x356>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80067f:	83 ec 08             	sub    $0x8,%esp
  800682:	53                   	push   %ebx
  800683:	6a 30                	push   $0x30
  800685:	ff d6                	call   *%esi
			putch('x', putdat);
  800687:	83 c4 08             	add    $0x8,%esp
  80068a:	53                   	push   %ebx
  80068b:	6a 78                	push   $0x78
  80068d:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80068f:	8b 45 14             	mov    0x14(%ebp),%eax
  800692:	8d 50 04             	lea    0x4(%eax),%edx
  800695:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800698:	8b 00                	mov    (%eax),%eax
  80069a:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80069f:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006a2:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006a7:	eb 0d                	jmp    8006b6 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006a9:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ac:	e8 3b fc ff ff       	call   8002ec <getuint>
			base = 16;
  8006b1:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006b6:	83 ec 0c             	sub    $0xc,%esp
  8006b9:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006bd:	57                   	push   %edi
  8006be:	ff 75 e0             	pushl  -0x20(%ebp)
  8006c1:	51                   	push   %ecx
  8006c2:	52                   	push   %edx
  8006c3:	50                   	push   %eax
  8006c4:	89 da                	mov    %ebx,%edx
  8006c6:	89 f0                	mov    %esi,%eax
  8006c8:	e8 70 fb ff ff       	call   80023d <printnum>
			break;
  8006cd:	83 c4 20             	add    $0x20,%esp
  8006d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006d3:	e9 ae fc ff ff       	jmp    800386 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006d8:	83 ec 08             	sub    $0x8,%esp
  8006db:	53                   	push   %ebx
  8006dc:	51                   	push   %ecx
  8006dd:	ff d6                	call   *%esi
			break;
  8006df:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006e5:	e9 9c fc ff ff       	jmp    800386 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006ea:	83 ec 08             	sub    $0x8,%esp
  8006ed:	53                   	push   %ebx
  8006ee:	6a 25                	push   $0x25
  8006f0:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006f2:	83 c4 10             	add    $0x10,%esp
  8006f5:	eb 03                	jmp    8006fa <vprintfmt+0x39a>
  8006f7:	83 ef 01             	sub    $0x1,%edi
  8006fa:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006fe:	75 f7                	jne    8006f7 <vprintfmt+0x397>
  800700:	e9 81 fc ff ff       	jmp    800386 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800705:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800708:	5b                   	pop    %ebx
  800709:	5e                   	pop    %esi
  80070a:	5f                   	pop    %edi
  80070b:	5d                   	pop    %ebp
  80070c:	c3                   	ret    

0080070d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80070d:	55                   	push   %ebp
  80070e:	89 e5                	mov    %esp,%ebp
  800710:	83 ec 18             	sub    $0x18,%esp
  800713:	8b 45 08             	mov    0x8(%ebp),%eax
  800716:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800719:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80071c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800720:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800723:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80072a:	85 c0                	test   %eax,%eax
  80072c:	74 26                	je     800754 <vsnprintf+0x47>
  80072e:	85 d2                	test   %edx,%edx
  800730:	7e 22                	jle    800754 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800732:	ff 75 14             	pushl  0x14(%ebp)
  800735:	ff 75 10             	pushl  0x10(%ebp)
  800738:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80073b:	50                   	push   %eax
  80073c:	68 26 03 80 00       	push   $0x800326
  800741:	e8 1a fc ff ff       	call   800360 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800746:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800749:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80074c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80074f:	83 c4 10             	add    $0x10,%esp
  800752:	eb 05                	jmp    800759 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800754:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800759:	c9                   	leave  
  80075a:	c3                   	ret    

0080075b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80075b:	55                   	push   %ebp
  80075c:	89 e5                	mov    %esp,%ebp
  80075e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800761:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800764:	50                   	push   %eax
  800765:	ff 75 10             	pushl  0x10(%ebp)
  800768:	ff 75 0c             	pushl  0xc(%ebp)
  80076b:	ff 75 08             	pushl  0x8(%ebp)
  80076e:	e8 9a ff ff ff       	call   80070d <vsnprintf>
	va_end(ap);

	return rc;
}
  800773:	c9                   	leave  
  800774:	c3                   	ret    

00800775 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800775:	55                   	push   %ebp
  800776:	89 e5                	mov    %esp,%ebp
  800778:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80077b:	b8 00 00 00 00       	mov    $0x0,%eax
  800780:	eb 03                	jmp    800785 <strlen+0x10>
		n++;
  800782:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800785:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800789:	75 f7                	jne    800782 <strlen+0xd>
		n++;
	return n;
}
  80078b:	5d                   	pop    %ebp
  80078c:	c3                   	ret    

0080078d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80078d:	55                   	push   %ebp
  80078e:	89 e5                	mov    %esp,%ebp
  800790:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800793:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800796:	ba 00 00 00 00       	mov    $0x0,%edx
  80079b:	eb 03                	jmp    8007a0 <strnlen+0x13>
		n++;
  80079d:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a0:	39 c2                	cmp    %eax,%edx
  8007a2:	74 08                	je     8007ac <strnlen+0x1f>
  8007a4:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007a8:	75 f3                	jne    80079d <strnlen+0x10>
  8007aa:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007ac:	5d                   	pop    %ebp
  8007ad:	c3                   	ret    

008007ae <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007ae:	55                   	push   %ebp
  8007af:	89 e5                	mov    %esp,%ebp
  8007b1:	53                   	push   %ebx
  8007b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007b8:	89 c2                	mov    %eax,%edx
  8007ba:	83 c2 01             	add    $0x1,%edx
  8007bd:	83 c1 01             	add    $0x1,%ecx
  8007c0:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007c4:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007c7:	84 db                	test   %bl,%bl
  8007c9:	75 ef                	jne    8007ba <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007cb:	5b                   	pop    %ebx
  8007cc:	5d                   	pop    %ebp
  8007cd:	c3                   	ret    

008007ce <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007ce:	55                   	push   %ebp
  8007cf:	89 e5                	mov    %esp,%ebp
  8007d1:	53                   	push   %ebx
  8007d2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007d5:	53                   	push   %ebx
  8007d6:	e8 9a ff ff ff       	call   800775 <strlen>
  8007db:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007de:	ff 75 0c             	pushl  0xc(%ebp)
  8007e1:	01 d8                	add    %ebx,%eax
  8007e3:	50                   	push   %eax
  8007e4:	e8 c5 ff ff ff       	call   8007ae <strcpy>
	return dst;
}
  8007e9:	89 d8                	mov    %ebx,%eax
  8007eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007ee:	c9                   	leave  
  8007ef:	c3                   	ret    

008007f0 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	56                   	push   %esi
  8007f4:	53                   	push   %ebx
  8007f5:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007fb:	89 f3                	mov    %esi,%ebx
  8007fd:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800800:	89 f2                	mov    %esi,%edx
  800802:	eb 0f                	jmp    800813 <strncpy+0x23>
		*dst++ = *src;
  800804:	83 c2 01             	add    $0x1,%edx
  800807:	0f b6 01             	movzbl (%ecx),%eax
  80080a:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80080d:	80 39 01             	cmpb   $0x1,(%ecx)
  800810:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800813:	39 da                	cmp    %ebx,%edx
  800815:	75 ed                	jne    800804 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800817:	89 f0                	mov    %esi,%eax
  800819:	5b                   	pop    %ebx
  80081a:	5e                   	pop    %esi
  80081b:	5d                   	pop    %ebp
  80081c:	c3                   	ret    

0080081d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80081d:	55                   	push   %ebp
  80081e:	89 e5                	mov    %esp,%ebp
  800820:	56                   	push   %esi
  800821:	53                   	push   %ebx
  800822:	8b 75 08             	mov    0x8(%ebp),%esi
  800825:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800828:	8b 55 10             	mov    0x10(%ebp),%edx
  80082b:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80082d:	85 d2                	test   %edx,%edx
  80082f:	74 21                	je     800852 <strlcpy+0x35>
  800831:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800835:	89 f2                	mov    %esi,%edx
  800837:	eb 09                	jmp    800842 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800839:	83 c2 01             	add    $0x1,%edx
  80083c:	83 c1 01             	add    $0x1,%ecx
  80083f:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800842:	39 c2                	cmp    %eax,%edx
  800844:	74 09                	je     80084f <strlcpy+0x32>
  800846:	0f b6 19             	movzbl (%ecx),%ebx
  800849:	84 db                	test   %bl,%bl
  80084b:	75 ec                	jne    800839 <strlcpy+0x1c>
  80084d:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80084f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800852:	29 f0                	sub    %esi,%eax
}
  800854:	5b                   	pop    %ebx
  800855:	5e                   	pop    %esi
  800856:	5d                   	pop    %ebp
  800857:	c3                   	ret    

00800858 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800858:	55                   	push   %ebp
  800859:	89 e5                	mov    %esp,%ebp
  80085b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80085e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800861:	eb 06                	jmp    800869 <strcmp+0x11>
		p++, q++;
  800863:	83 c1 01             	add    $0x1,%ecx
  800866:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800869:	0f b6 01             	movzbl (%ecx),%eax
  80086c:	84 c0                	test   %al,%al
  80086e:	74 04                	je     800874 <strcmp+0x1c>
  800870:	3a 02                	cmp    (%edx),%al
  800872:	74 ef                	je     800863 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800874:	0f b6 c0             	movzbl %al,%eax
  800877:	0f b6 12             	movzbl (%edx),%edx
  80087a:	29 d0                	sub    %edx,%eax
}
  80087c:	5d                   	pop    %ebp
  80087d:	c3                   	ret    

0080087e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80087e:	55                   	push   %ebp
  80087f:	89 e5                	mov    %esp,%ebp
  800881:	53                   	push   %ebx
  800882:	8b 45 08             	mov    0x8(%ebp),%eax
  800885:	8b 55 0c             	mov    0xc(%ebp),%edx
  800888:	89 c3                	mov    %eax,%ebx
  80088a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80088d:	eb 06                	jmp    800895 <strncmp+0x17>
		n--, p++, q++;
  80088f:	83 c0 01             	add    $0x1,%eax
  800892:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800895:	39 d8                	cmp    %ebx,%eax
  800897:	74 15                	je     8008ae <strncmp+0x30>
  800899:	0f b6 08             	movzbl (%eax),%ecx
  80089c:	84 c9                	test   %cl,%cl
  80089e:	74 04                	je     8008a4 <strncmp+0x26>
  8008a0:	3a 0a                	cmp    (%edx),%cl
  8008a2:	74 eb                	je     80088f <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a4:	0f b6 00             	movzbl (%eax),%eax
  8008a7:	0f b6 12             	movzbl (%edx),%edx
  8008aa:	29 d0                	sub    %edx,%eax
  8008ac:	eb 05                	jmp    8008b3 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008ae:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008b3:	5b                   	pop    %ebx
  8008b4:	5d                   	pop    %ebp
  8008b5:	c3                   	ret    

008008b6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008b6:	55                   	push   %ebp
  8008b7:	89 e5                	mov    %esp,%ebp
  8008b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008c0:	eb 07                	jmp    8008c9 <strchr+0x13>
		if (*s == c)
  8008c2:	38 ca                	cmp    %cl,%dl
  8008c4:	74 0f                	je     8008d5 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008c6:	83 c0 01             	add    $0x1,%eax
  8008c9:	0f b6 10             	movzbl (%eax),%edx
  8008cc:	84 d2                	test   %dl,%dl
  8008ce:	75 f2                	jne    8008c2 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008d0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008d5:	5d                   	pop    %ebp
  8008d6:	c3                   	ret    

008008d7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008d7:	55                   	push   %ebp
  8008d8:	89 e5                	mov    %esp,%ebp
  8008da:	8b 45 08             	mov    0x8(%ebp),%eax
  8008dd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008e1:	eb 03                	jmp    8008e6 <strfind+0xf>
  8008e3:	83 c0 01             	add    $0x1,%eax
  8008e6:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008e9:	38 ca                	cmp    %cl,%dl
  8008eb:	74 04                	je     8008f1 <strfind+0x1a>
  8008ed:	84 d2                	test   %dl,%dl
  8008ef:	75 f2                	jne    8008e3 <strfind+0xc>
			break;
	return (char *) s;
}
  8008f1:	5d                   	pop    %ebp
  8008f2:	c3                   	ret    

008008f3 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008f3:	55                   	push   %ebp
  8008f4:	89 e5                	mov    %esp,%ebp
  8008f6:	57                   	push   %edi
  8008f7:	56                   	push   %esi
  8008f8:	53                   	push   %ebx
  8008f9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008fc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008ff:	85 c9                	test   %ecx,%ecx
  800901:	74 36                	je     800939 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800903:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800909:	75 28                	jne    800933 <memset+0x40>
  80090b:	f6 c1 03             	test   $0x3,%cl
  80090e:	75 23                	jne    800933 <memset+0x40>
		c &= 0xFF;
  800910:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800914:	89 d3                	mov    %edx,%ebx
  800916:	c1 e3 08             	shl    $0x8,%ebx
  800919:	89 d6                	mov    %edx,%esi
  80091b:	c1 e6 18             	shl    $0x18,%esi
  80091e:	89 d0                	mov    %edx,%eax
  800920:	c1 e0 10             	shl    $0x10,%eax
  800923:	09 f0                	or     %esi,%eax
  800925:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800927:	89 d8                	mov    %ebx,%eax
  800929:	09 d0                	or     %edx,%eax
  80092b:	c1 e9 02             	shr    $0x2,%ecx
  80092e:	fc                   	cld    
  80092f:	f3 ab                	rep stos %eax,%es:(%edi)
  800931:	eb 06                	jmp    800939 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800933:	8b 45 0c             	mov    0xc(%ebp),%eax
  800936:	fc                   	cld    
  800937:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800939:	89 f8                	mov    %edi,%eax
  80093b:	5b                   	pop    %ebx
  80093c:	5e                   	pop    %esi
  80093d:	5f                   	pop    %edi
  80093e:	5d                   	pop    %ebp
  80093f:	c3                   	ret    

00800940 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800940:	55                   	push   %ebp
  800941:	89 e5                	mov    %esp,%ebp
  800943:	57                   	push   %edi
  800944:	56                   	push   %esi
  800945:	8b 45 08             	mov    0x8(%ebp),%eax
  800948:	8b 75 0c             	mov    0xc(%ebp),%esi
  80094b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80094e:	39 c6                	cmp    %eax,%esi
  800950:	73 35                	jae    800987 <memmove+0x47>
  800952:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800955:	39 d0                	cmp    %edx,%eax
  800957:	73 2e                	jae    800987 <memmove+0x47>
		s += n;
		d += n;
  800959:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80095c:	89 d6                	mov    %edx,%esi
  80095e:	09 fe                	or     %edi,%esi
  800960:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800966:	75 13                	jne    80097b <memmove+0x3b>
  800968:	f6 c1 03             	test   $0x3,%cl
  80096b:	75 0e                	jne    80097b <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80096d:	83 ef 04             	sub    $0x4,%edi
  800970:	8d 72 fc             	lea    -0x4(%edx),%esi
  800973:	c1 e9 02             	shr    $0x2,%ecx
  800976:	fd                   	std    
  800977:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800979:	eb 09                	jmp    800984 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80097b:	83 ef 01             	sub    $0x1,%edi
  80097e:	8d 72 ff             	lea    -0x1(%edx),%esi
  800981:	fd                   	std    
  800982:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800984:	fc                   	cld    
  800985:	eb 1d                	jmp    8009a4 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800987:	89 f2                	mov    %esi,%edx
  800989:	09 c2                	or     %eax,%edx
  80098b:	f6 c2 03             	test   $0x3,%dl
  80098e:	75 0f                	jne    80099f <memmove+0x5f>
  800990:	f6 c1 03             	test   $0x3,%cl
  800993:	75 0a                	jne    80099f <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800995:	c1 e9 02             	shr    $0x2,%ecx
  800998:	89 c7                	mov    %eax,%edi
  80099a:	fc                   	cld    
  80099b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80099d:	eb 05                	jmp    8009a4 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80099f:	89 c7                	mov    %eax,%edi
  8009a1:	fc                   	cld    
  8009a2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009a4:	5e                   	pop    %esi
  8009a5:	5f                   	pop    %edi
  8009a6:	5d                   	pop    %ebp
  8009a7:	c3                   	ret    

008009a8 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009a8:	55                   	push   %ebp
  8009a9:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009ab:	ff 75 10             	pushl  0x10(%ebp)
  8009ae:	ff 75 0c             	pushl  0xc(%ebp)
  8009b1:	ff 75 08             	pushl  0x8(%ebp)
  8009b4:	e8 87 ff ff ff       	call   800940 <memmove>
}
  8009b9:	c9                   	leave  
  8009ba:	c3                   	ret    

008009bb <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009bb:	55                   	push   %ebp
  8009bc:	89 e5                	mov    %esp,%ebp
  8009be:	56                   	push   %esi
  8009bf:	53                   	push   %ebx
  8009c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009c6:	89 c6                	mov    %eax,%esi
  8009c8:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009cb:	eb 1a                	jmp    8009e7 <memcmp+0x2c>
		if (*s1 != *s2)
  8009cd:	0f b6 08             	movzbl (%eax),%ecx
  8009d0:	0f b6 1a             	movzbl (%edx),%ebx
  8009d3:	38 d9                	cmp    %bl,%cl
  8009d5:	74 0a                	je     8009e1 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009d7:	0f b6 c1             	movzbl %cl,%eax
  8009da:	0f b6 db             	movzbl %bl,%ebx
  8009dd:	29 d8                	sub    %ebx,%eax
  8009df:	eb 0f                	jmp    8009f0 <memcmp+0x35>
		s1++, s2++;
  8009e1:	83 c0 01             	add    $0x1,%eax
  8009e4:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009e7:	39 f0                	cmp    %esi,%eax
  8009e9:	75 e2                	jne    8009cd <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009eb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f0:	5b                   	pop    %ebx
  8009f1:	5e                   	pop    %esi
  8009f2:	5d                   	pop    %ebp
  8009f3:	c3                   	ret    

008009f4 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009f4:	55                   	push   %ebp
  8009f5:	89 e5                	mov    %esp,%ebp
  8009f7:	53                   	push   %ebx
  8009f8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009fb:	89 c1                	mov    %eax,%ecx
  8009fd:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a00:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a04:	eb 0a                	jmp    800a10 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a06:	0f b6 10             	movzbl (%eax),%edx
  800a09:	39 da                	cmp    %ebx,%edx
  800a0b:	74 07                	je     800a14 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a0d:	83 c0 01             	add    $0x1,%eax
  800a10:	39 c8                	cmp    %ecx,%eax
  800a12:	72 f2                	jb     800a06 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a14:	5b                   	pop    %ebx
  800a15:	5d                   	pop    %ebp
  800a16:	c3                   	ret    

00800a17 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a17:	55                   	push   %ebp
  800a18:	89 e5                	mov    %esp,%ebp
  800a1a:	57                   	push   %edi
  800a1b:	56                   	push   %esi
  800a1c:	53                   	push   %ebx
  800a1d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a20:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a23:	eb 03                	jmp    800a28 <strtol+0x11>
		s++;
  800a25:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a28:	0f b6 01             	movzbl (%ecx),%eax
  800a2b:	3c 20                	cmp    $0x20,%al
  800a2d:	74 f6                	je     800a25 <strtol+0xe>
  800a2f:	3c 09                	cmp    $0x9,%al
  800a31:	74 f2                	je     800a25 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a33:	3c 2b                	cmp    $0x2b,%al
  800a35:	75 0a                	jne    800a41 <strtol+0x2a>
		s++;
  800a37:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a3a:	bf 00 00 00 00       	mov    $0x0,%edi
  800a3f:	eb 11                	jmp    800a52 <strtol+0x3b>
  800a41:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a46:	3c 2d                	cmp    $0x2d,%al
  800a48:	75 08                	jne    800a52 <strtol+0x3b>
		s++, neg = 1;
  800a4a:	83 c1 01             	add    $0x1,%ecx
  800a4d:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a52:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a58:	75 15                	jne    800a6f <strtol+0x58>
  800a5a:	80 39 30             	cmpb   $0x30,(%ecx)
  800a5d:	75 10                	jne    800a6f <strtol+0x58>
  800a5f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a63:	75 7c                	jne    800ae1 <strtol+0xca>
		s += 2, base = 16;
  800a65:	83 c1 02             	add    $0x2,%ecx
  800a68:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a6d:	eb 16                	jmp    800a85 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a6f:	85 db                	test   %ebx,%ebx
  800a71:	75 12                	jne    800a85 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a73:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a78:	80 39 30             	cmpb   $0x30,(%ecx)
  800a7b:	75 08                	jne    800a85 <strtol+0x6e>
		s++, base = 8;
  800a7d:	83 c1 01             	add    $0x1,%ecx
  800a80:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a85:	b8 00 00 00 00       	mov    $0x0,%eax
  800a8a:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a8d:	0f b6 11             	movzbl (%ecx),%edx
  800a90:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a93:	89 f3                	mov    %esi,%ebx
  800a95:	80 fb 09             	cmp    $0x9,%bl
  800a98:	77 08                	ja     800aa2 <strtol+0x8b>
			dig = *s - '0';
  800a9a:	0f be d2             	movsbl %dl,%edx
  800a9d:	83 ea 30             	sub    $0x30,%edx
  800aa0:	eb 22                	jmp    800ac4 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800aa2:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aa5:	89 f3                	mov    %esi,%ebx
  800aa7:	80 fb 19             	cmp    $0x19,%bl
  800aaa:	77 08                	ja     800ab4 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800aac:	0f be d2             	movsbl %dl,%edx
  800aaf:	83 ea 57             	sub    $0x57,%edx
  800ab2:	eb 10                	jmp    800ac4 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ab4:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ab7:	89 f3                	mov    %esi,%ebx
  800ab9:	80 fb 19             	cmp    $0x19,%bl
  800abc:	77 16                	ja     800ad4 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800abe:	0f be d2             	movsbl %dl,%edx
  800ac1:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ac4:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ac7:	7d 0b                	jge    800ad4 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ac9:	83 c1 01             	add    $0x1,%ecx
  800acc:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ad0:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ad2:	eb b9                	jmp    800a8d <strtol+0x76>

	if (endptr)
  800ad4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ad8:	74 0d                	je     800ae7 <strtol+0xd0>
		*endptr = (char *) s;
  800ada:	8b 75 0c             	mov    0xc(%ebp),%esi
  800add:	89 0e                	mov    %ecx,(%esi)
  800adf:	eb 06                	jmp    800ae7 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ae1:	85 db                	test   %ebx,%ebx
  800ae3:	74 98                	je     800a7d <strtol+0x66>
  800ae5:	eb 9e                	jmp    800a85 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ae7:	89 c2                	mov    %eax,%edx
  800ae9:	f7 da                	neg    %edx
  800aeb:	85 ff                	test   %edi,%edi
  800aed:	0f 45 c2             	cmovne %edx,%eax
}
  800af0:	5b                   	pop    %ebx
  800af1:	5e                   	pop    %esi
  800af2:	5f                   	pop    %edi
  800af3:	5d                   	pop    %ebp
  800af4:	c3                   	ret    

00800af5 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800af5:	55                   	push   %ebp
  800af6:	89 e5                	mov    %esp,%ebp
  800af8:	57                   	push   %edi
  800af9:	56                   	push   %esi
  800afa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800afb:	b8 00 00 00 00       	mov    $0x0,%eax
  800b00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b03:	8b 55 08             	mov    0x8(%ebp),%edx
  800b06:	89 c3                	mov    %eax,%ebx
  800b08:	89 c7                	mov    %eax,%edi
  800b0a:	89 c6                	mov    %eax,%esi
  800b0c:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b0e:	5b                   	pop    %ebx
  800b0f:	5e                   	pop    %esi
  800b10:	5f                   	pop    %edi
  800b11:	5d                   	pop    %ebp
  800b12:	c3                   	ret    

00800b13 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b13:	55                   	push   %ebp
  800b14:	89 e5                	mov    %esp,%ebp
  800b16:	57                   	push   %edi
  800b17:	56                   	push   %esi
  800b18:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b19:	ba 00 00 00 00       	mov    $0x0,%edx
  800b1e:	b8 01 00 00 00       	mov    $0x1,%eax
  800b23:	89 d1                	mov    %edx,%ecx
  800b25:	89 d3                	mov    %edx,%ebx
  800b27:	89 d7                	mov    %edx,%edi
  800b29:	89 d6                	mov    %edx,%esi
  800b2b:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b2d:	5b                   	pop    %ebx
  800b2e:	5e                   	pop    %esi
  800b2f:	5f                   	pop    %edi
  800b30:	5d                   	pop    %ebp
  800b31:	c3                   	ret    

00800b32 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b32:	55                   	push   %ebp
  800b33:	89 e5                	mov    %esp,%ebp
  800b35:	57                   	push   %edi
  800b36:	56                   	push   %esi
  800b37:	53                   	push   %ebx
  800b38:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b40:	b8 03 00 00 00       	mov    $0x3,%eax
  800b45:	8b 55 08             	mov    0x8(%ebp),%edx
  800b48:	89 cb                	mov    %ecx,%ebx
  800b4a:	89 cf                	mov    %ecx,%edi
  800b4c:	89 ce                	mov    %ecx,%esi
  800b4e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b50:	85 c0                	test   %eax,%eax
  800b52:	7e 17                	jle    800b6b <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b54:	83 ec 0c             	sub    $0xc,%esp
  800b57:	50                   	push   %eax
  800b58:	6a 03                	push   $0x3
  800b5a:	68 e4 16 80 00       	push   $0x8016e4
  800b5f:	6a 23                	push   $0x23
  800b61:	68 01 17 80 00       	push   $0x801701
  800b66:	e8 e5 f5 ff ff       	call   800150 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b6b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b6e:	5b                   	pop    %ebx
  800b6f:	5e                   	pop    %esi
  800b70:	5f                   	pop    %edi
  800b71:	5d                   	pop    %ebp
  800b72:	c3                   	ret    

00800b73 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b73:	55                   	push   %ebp
  800b74:	89 e5                	mov    %esp,%ebp
  800b76:	57                   	push   %edi
  800b77:	56                   	push   %esi
  800b78:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b79:	ba 00 00 00 00       	mov    $0x0,%edx
  800b7e:	b8 02 00 00 00       	mov    $0x2,%eax
  800b83:	89 d1                	mov    %edx,%ecx
  800b85:	89 d3                	mov    %edx,%ebx
  800b87:	89 d7                	mov    %edx,%edi
  800b89:	89 d6                	mov    %edx,%esi
  800b8b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b8d:	5b                   	pop    %ebx
  800b8e:	5e                   	pop    %esi
  800b8f:	5f                   	pop    %edi
  800b90:	5d                   	pop    %ebp
  800b91:	c3                   	ret    

00800b92 <sys_yield>:

void
sys_yield(void)
{
  800b92:	55                   	push   %ebp
  800b93:	89 e5                	mov    %esp,%ebp
  800b95:	57                   	push   %edi
  800b96:	56                   	push   %esi
  800b97:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b98:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ba2:	89 d1                	mov    %edx,%ecx
  800ba4:	89 d3                	mov    %edx,%ebx
  800ba6:	89 d7                	mov    %edx,%edi
  800ba8:	89 d6                	mov    %edx,%esi
  800baa:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bac:	5b                   	pop    %ebx
  800bad:	5e                   	pop    %esi
  800bae:	5f                   	pop    %edi
  800baf:	5d                   	pop    %ebp
  800bb0:	c3                   	ret    

00800bb1 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bb1:	55                   	push   %ebp
  800bb2:	89 e5                	mov    %esp,%ebp
  800bb4:	57                   	push   %edi
  800bb5:	56                   	push   %esi
  800bb6:	53                   	push   %ebx
  800bb7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bba:	be 00 00 00 00       	mov    $0x0,%esi
  800bbf:	b8 04 00 00 00       	mov    $0x4,%eax
  800bc4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc7:	8b 55 08             	mov    0x8(%ebp),%edx
  800bca:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bcd:	89 f7                	mov    %esi,%edi
  800bcf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bd1:	85 c0                	test   %eax,%eax
  800bd3:	7e 17                	jle    800bec <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd5:	83 ec 0c             	sub    $0xc,%esp
  800bd8:	50                   	push   %eax
  800bd9:	6a 04                	push   $0x4
  800bdb:	68 e4 16 80 00       	push   $0x8016e4
  800be0:	6a 23                	push   $0x23
  800be2:	68 01 17 80 00       	push   $0x801701
  800be7:	e8 64 f5 ff ff       	call   800150 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bef:	5b                   	pop    %ebx
  800bf0:	5e                   	pop    %esi
  800bf1:	5f                   	pop    %edi
  800bf2:	5d                   	pop    %ebp
  800bf3:	c3                   	ret    

00800bf4 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bf4:	55                   	push   %ebp
  800bf5:	89 e5                	mov    %esp,%ebp
  800bf7:	57                   	push   %edi
  800bf8:	56                   	push   %esi
  800bf9:	53                   	push   %ebx
  800bfa:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfd:	b8 05 00 00 00       	mov    $0x5,%eax
  800c02:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c05:	8b 55 08             	mov    0x8(%ebp),%edx
  800c08:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c0b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c0e:	8b 75 18             	mov    0x18(%ebp),%esi
  800c11:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c13:	85 c0                	test   %eax,%eax
  800c15:	7e 17                	jle    800c2e <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c17:	83 ec 0c             	sub    $0xc,%esp
  800c1a:	50                   	push   %eax
  800c1b:	6a 05                	push   $0x5
  800c1d:	68 e4 16 80 00       	push   $0x8016e4
  800c22:	6a 23                	push   $0x23
  800c24:	68 01 17 80 00       	push   $0x801701
  800c29:	e8 22 f5 ff ff       	call   800150 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c2e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c31:	5b                   	pop    %ebx
  800c32:	5e                   	pop    %esi
  800c33:	5f                   	pop    %edi
  800c34:	5d                   	pop    %ebp
  800c35:	c3                   	ret    

00800c36 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c36:	55                   	push   %ebp
  800c37:	89 e5                	mov    %esp,%ebp
  800c39:	57                   	push   %edi
  800c3a:	56                   	push   %esi
  800c3b:	53                   	push   %ebx
  800c3c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c44:	b8 06 00 00 00       	mov    $0x6,%eax
  800c49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4f:	89 df                	mov    %ebx,%edi
  800c51:	89 de                	mov    %ebx,%esi
  800c53:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c55:	85 c0                	test   %eax,%eax
  800c57:	7e 17                	jle    800c70 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c59:	83 ec 0c             	sub    $0xc,%esp
  800c5c:	50                   	push   %eax
  800c5d:	6a 06                	push   $0x6
  800c5f:	68 e4 16 80 00       	push   $0x8016e4
  800c64:	6a 23                	push   $0x23
  800c66:	68 01 17 80 00       	push   $0x801701
  800c6b:	e8 e0 f4 ff ff       	call   800150 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c70:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c73:	5b                   	pop    %ebx
  800c74:	5e                   	pop    %esi
  800c75:	5f                   	pop    %edi
  800c76:	5d                   	pop    %ebp
  800c77:	c3                   	ret    

00800c78 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c78:	55                   	push   %ebp
  800c79:	89 e5                	mov    %esp,%ebp
  800c7b:	57                   	push   %edi
  800c7c:	56                   	push   %esi
  800c7d:	53                   	push   %ebx
  800c7e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c81:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c86:	b8 08 00 00 00       	mov    $0x8,%eax
  800c8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c91:	89 df                	mov    %ebx,%edi
  800c93:	89 de                	mov    %ebx,%esi
  800c95:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c97:	85 c0                	test   %eax,%eax
  800c99:	7e 17                	jle    800cb2 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9b:	83 ec 0c             	sub    $0xc,%esp
  800c9e:	50                   	push   %eax
  800c9f:	6a 08                	push   $0x8
  800ca1:	68 e4 16 80 00       	push   $0x8016e4
  800ca6:	6a 23                	push   $0x23
  800ca8:	68 01 17 80 00       	push   $0x801701
  800cad:	e8 9e f4 ff ff       	call   800150 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cb2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb5:	5b                   	pop    %ebx
  800cb6:	5e                   	pop    %esi
  800cb7:	5f                   	pop    %edi
  800cb8:	5d                   	pop    %ebp
  800cb9:	c3                   	ret    

00800cba <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cba:	55                   	push   %ebp
  800cbb:	89 e5                	mov    %esp,%ebp
  800cbd:	57                   	push   %edi
  800cbe:	56                   	push   %esi
  800cbf:	53                   	push   %ebx
  800cc0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc8:	b8 09 00 00 00       	mov    $0x9,%eax
  800ccd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd3:	89 df                	mov    %ebx,%edi
  800cd5:	89 de                	mov    %ebx,%esi
  800cd7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cd9:	85 c0                	test   %eax,%eax
  800cdb:	7e 17                	jle    800cf4 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cdd:	83 ec 0c             	sub    $0xc,%esp
  800ce0:	50                   	push   %eax
  800ce1:	6a 09                	push   $0x9
  800ce3:	68 e4 16 80 00       	push   $0x8016e4
  800ce8:	6a 23                	push   $0x23
  800cea:	68 01 17 80 00       	push   $0x801701
  800cef:	e8 5c f4 ff ff       	call   800150 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cf4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf7:	5b                   	pop    %ebx
  800cf8:	5e                   	pop    %esi
  800cf9:	5f                   	pop    %edi
  800cfa:	5d                   	pop    %ebp
  800cfb:	c3                   	ret    

00800cfc <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cfc:	55                   	push   %ebp
  800cfd:	89 e5                	mov    %esp,%ebp
  800cff:	57                   	push   %edi
  800d00:	56                   	push   %esi
  800d01:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d02:	be 00 00 00 00       	mov    $0x0,%esi
  800d07:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d12:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d15:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d18:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d1a:	5b                   	pop    %ebx
  800d1b:	5e                   	pop    %esi
  800d1c:	5f                   	pop    %edi
  800d1d:	5d                   	pop    %ebp
  800d1e:	c3                   	ret    

00800d1f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d1f:	55                   	push   %ebp
  800d20:	89 e5                	mov    %esp,%ebp
  800d22:	57                   	push   %edi
  800d23:	56                   	push   %esi
  800d24:	53                   	push   %ebx
  800d25:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d28:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d2d:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d32:	8b 55 08             	mov    0x8(%ebp),%edx
  800d35:	89 cb                	mov    %ecx,%ebx
  800d37:	89 cf                	mov    %ecx,%edi
  800d39:	89 ce                	mov    %ecx,%esi
  800d3b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d3d:	85 c0                	test   %eax,%eax
  800d3f:	7e 17                	jle    800d58 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d41:	83 ec 0c             	sub    $0xc,%esp
  800d44:	50                   	push   %eax
  800d45:	6a 0c                	push   $0xc
  800d47:	68 e4 16 80 00       	push   $0x8016e4
  800d4c:	6a 23                	push   $0x23
  800d4e:	68 01 17 80 00       	push   $0x801701
  800d53:	e8 f8 f3 ff ff       	call   800150 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d5b:	5b                   	pop    %ebx
  800d5c:	5e                   	pop    %esi
  800d5d:	5f                   	pop    %edi
  800d5e:	5d                   	pop    %ebp
  800d5f:	c3                   	ret    

00800d60 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d60:	55                   	push   %ebp
  800d61:	89 e5                	mov    %esp,%ebp
  800d63:	56                   	push   %esi
  800d64:	53                   	push   %ebx
  800d65:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d68:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if (!((err & FEC_WR) &&
  800d6a:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800d6e:	74 2c                	je     800d9c <pgfault+0x3c>
	      (uvpd[PDX(addr)] & PTE_P) &&
  800d70:	89 d8                	mov    %ebx,%eax
  800d72:	c1 e8 16             	shr    $0x16,%eax
  800d75:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if (!((err & FEC_WR) &&
  800d7c:	a8 01                	test   $0x1,%al
  800d7e:	74 1c                	je     800d9c <pgfault+0x3c>
	      (uvpd[PDX(addr)] & PTE_P) &&
	      (uvpt[PGNUM(addr)] & PTE_P) &&
  800d80:	89 de                	mov    %ebx,%esi
  800d82:	c1 ee 0c             	shr    $0xc,%esi
  800d85:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if (!((err & FEC_WR) &&
	      (uvpd[PDX(addr)] & PTE_P) &&
  800d8c:	a8 01                	test   $0x1,%al
  800d8e:	74 0c                	je     800d9c <pgfault+0x3c>
	      (uvpt[PGNUM(addr)] & PTE_P) &&
	      (uvpt[PGNUM(addr)] & PTE_COW)))
  800d90:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if (!((err & FEC_WR) &&
  800d97:	f6 c4 08             	test   $0x8,%ah
  800d9a:	75 14                	jne    800db0 <pgfault+0x50>
	      (uvpd[PDX(addr)] & PTE_P) &&
	      (uvpt[PGNUM(addr)] & PTE_P) &&
	      (uvpt[PGNUM(addr)] & PTE_COW)))
		panic("not copy on write");
  800d9c:	83 ec 04             	sub    $0x4,%esp
  800d9f:	68 0f 17 80 00       	push   $0x80170f
  800da4:	6a 21                	push   $0x21
  800da6:	68 21 17 80 00       	push   $0x801721
  800dab:	e8 a0 f3 ff ff       	call   800150 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	addr = ROUNDDOWN(addr, PGSIZE);
  800db0:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	sys_page_alloc(0, PFTEMP, PTE_W | PTE_P | PTE_U);
  800db6:	83 ec 04             	sub    $0x4,%esp
  800db9:	6a 07                	push   $0x7
  800dbb:	68 00 f0 7f 00       	push   $0x7ff000
  800dc0:	6a 00                	push   $0x0
  800dc2:	e8 ea fd ff ff       	call   800bb1 <sys_page_alloc>
	memcpy(PFTEMP, addr, PGSIZE);
  800dc7:	83 c4 0c             	add    $0xc,%esp
  800dca:	68 00 10 00 00       	push   $0x1000
  800dcf:	53                   	push   %ebx
  800dd0:	68 00 f0 7f 00       	push   $0x7ff000
  800dd5:	e8 ce fb ff ff       	call   8009a8 <memcpy>
	sys_page_map(0, PFTEMP,
	             0, addr,
	             (uvpt[PGNUM(addr)] & (PTE_SYSCALL & (~PTE_COW))) | PTE_W);
  800dda:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	// LAB 4: Your code here.

	addr = ROUNDDOWN(addr, PGSIZE);
	sys_page_alloc(0, PFTEMP, PTE_W | PTE_P | PTE_U);
	memcpy(PFTEMP, addr, PGSIZE);
	sys_page_map(0, PFTEMP,
  800de1:	25 05 06 00 00       	and    $0x605,%eax
  800de6:	83 c8 02             	or     $0x2,%eax
  800de9:	89 04 24             	mov    %eax,(%esp)
  800dec:	53                   	push   %ebx
  800ded:	6a 00                	push   $0x0
  800def:	68 00 f0 7f 00       	push   $0x7ff000
  800df4:	6a 00                	push   $0x0
  800df6:	e8 f9 fd ff ff       	call   800bf4 <sys_page_map>
	             0, addr,
	             (uvpt[PGNUM(addr)] & (PTE_SYSCALL & (~PTE_COW))) | PTE_W);
	sys_page_unmap(0, PFTEMP);
  800dfb:	83 c4 18             	add    $0x18,%esp
  800dfe:	68 00 f0 7f 00       	push   $0x7ff000
  800e03:	6a 00                	push   $0x0
  800e05:	e8 2c fe ff ff       	call   800c36 <sys_page_unmap>
	return;
  800e0a:	83 c4 10             	add    $0x10,%esp

	
}
  800e0d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e10:	5b                   	pop    %ebx
  800e11:	5e                   	pop    %esi
  800e12:	5d                   	pop    %ebp
  800e13:	c3                   	ret    

00800e14 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e14:	55                   	push   %ebp
  800e15:	89 e5                	mov    %esp,%ebp
  800e17:	57                   	push   %edi
  800e18:	56                   	push   %esi
  800e19:	53                   	push   %ebx
  800e1a:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	int r;

	set_pgfault_handler(pgfault);
  800e1d:	68 60 0d 80 00       	push   $0x800d60
  800e22:	e8 e3 02 00 00       	call   80110a <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e27:	b8 07 00 00 00       	mov    $0x7,%eax
  800e2c:	cd 30                	int    $0x30
  800e2e:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	if ((r = sys_exofork()) < 0)
  800e31:	83 c4 10             	add    $0x10,%esp
  800e34:	85 c0                	test   %eax,%eax
  800e36:	79 14                	jns    800e4c <fork+0x38>
		panic ("No memory");
  800e38:	83 ec 04             	sub    $0x4,%esp
  800e3b:	68 2c 17 80 00       	push   $0x80172c
  800e40:	6a 77                	push   $0x77
  800e42:	68 21 17 80 00       	push   $0x801721
  800e47:	e8 04 f3 ff ff       	call   800150 <_panic>
  800e4c:	89 c7                	mov    %eax,%edi
  800e4e:	bb 00 00 00 00       	mov    $0x0,%ebx
	else if (r == 0)
  800e53:	85 c0                	test   %eax,%eax
  800e55:	75 31                	jne    800e88 <fork+0x74>
	{
		set_pgfault_handler(pgfault);
  800e57:	83 ec 0c             	sub    $0xc,%esp
  800e5a:	68 60 0d 80 00       	push   $0x800d60
  800e5f:	e8 a6 02 00 00       	call   80110a <set_pgfault_handler>
		thisenv = &envs[ENVX(sys_getenvid())];
  800e64:	e8 0a fd ff ff       	call   800b73 <sys_getenvid>
  800e69:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e6e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800e71:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e76:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  800e7b:	83 c4 10             	add    $0x10,%esp
  800e7e:	b8 00 00 00 00       	mov    $0x0,%eax
  800e83:	e9 6d 01 00 00       	jmp    800ff5 <fork+0x1e1>
	}

	int i;
	for (i=0; i < USTACKTOP; i+=PGSIZE)
	{
		if ((uvpd [PDX(i)] & PTE_P) && (uvpt [PGNUM(i)] & PTE_P) 
  800e88:	89 d8                	mov    %ebx,%eax
  800e8a:	c1 e8 16             	shr    $0x16,%eax
  800e8d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e94:	a8 01                	test   $0x1,%al
  800e96:	0f 84 c2 00 00 00    	je     800f5e <fork+0x14a>
  800e9c:	89 d8                	mov    %ebx,%eax
  800e9e:	c1 e8 0c             	shr    $0xc,%eax
  800ea1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ea8:	f6 c2 01             	test   $0x1,%dl
  800eab:	0f 84 ad 00 00 00    	je     800f5e <fork+0x14a>
			&& (uvpt [PGNUM(i)] & PTE_U))
  800eb1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800eb8:	f6 c2 04             	test   $0x4,%dl
  800ebb:	0f 84 9d 00 00 00    	je     800f5e <fork+0x14a>
{
	int r;

	// LAB 4: Your code here.

	void *address = (void *) (pn*PGSIZE);
  800ec1:	89 c6                	mov    %eax,%esi
  800ec3:	c1 e6 0c             	shl    $0xc,%esi

	if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W)
  800ec6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ecd:	f6 c6 08             	test   $0x8,%dh
  800ed0:	75 0b                	jne    800edd <fork+0xc9>
  800ed2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ed9:	a8 02                	test   $0x2,%al
  800edb:	74 6d                	je     800f4a <fork+0x136>
	{
		if (sys_page_map(thisenv->env_id, address, envid, address, PTE_COW|PTE_U|PTE_P))
  800edd:	a1 04 20 80 00       	mov    0x802004,%eax
  800ee2:	8b 40 48             	mov    0x48(%eax),%eax
  800ee5:	83 ec 0c             	sub    $0xc,%esp
  800ee8:	68 05 08 00 00       	push   $0x805
  800eed:	56                   	push   %esi
  800eee:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ef1:	56                   	push   %esi
  800ef2:	50                   	push   %eax
  800ef3:	e8 fc fc ff ff       	call   800bf4 <sys_page_map>
  800ef8:	83 c4 20             	add    $0x20,%esp
  800efb:	85 c0                	test   %eax,%eax
  800efd:	74 14                	je     800f13 <fork+0xff>
            panic("sys_page_map failed");
  800eff:	83 ec 04             	sub    $0x4,%esp
  800f02:	68 36 17 80 00       	push   $0x801736
  800f07:	6a 4f                	push   $0x4f
  800f09:	68 21 17 80 00       	push   $0x801721
  800f0e:	e8 3d f2 ff ff       	call   800150 <_panic>
        if (sys_page_map(thisenv->env_id, address, thisenv->env_id, address, PTE_COW|PTE_U|PTE_P))
  800f13:	a1 04 20 80 00       	mov    0x802004,%eax
  800f18:	8b 50 48             	mov    0x48(%eax),%edx
  800f1b:	8b 40 48             	mov    0x48(%eax),%eax
  800f1e:	83 ec 0c             	sub    $0xc,%esp
  800f21:	68 05 08 00 00       	push   $0x805
  800f26:	56                   	push   %esi
  800f27:	52                   	push   %edx
  800f28:	56                   	push   %esi
  800f29:	50                   	push   %eax
  800f2a:	e8 c5 fc ff ff       	call   800bf4 <sys_page_map>
  800f2f:	83 c4 20             	add    $0x20,%esp
  800f32:	85 c0                	test   %eax,%eax
  800f34:	74 28                	je     800f5e <fork+0x14a>
            panic("sys_page_map failed");
  800f36:	83 ec 04             	sub    $0x4,%esp
  800f39:	68 36 17 80 00       	push   $0x801736
  800f3e:	6a 51                	push   $0x51
  800f40:	68 21 17 80 00       	push   $0x801721
  800f45:	e8 06 f2 ff ff       	call   800150 <_panic>
	}
	else
		sys_page_map(0, address, envid, address, PTE_U|PTE_P);
  800f4a:	83 ec 0c             	sub    $0xc,%esp
  800f4d:	6a 05                	push   $0x5
  800f4f:	56                   	push   %esi
  800f50:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f53:	56                   	push   %esi
  800f54:	6a 00                	push   $0x0
  800f56:	e8 99 fc ff ff       	call   800bf4 <sys_page_map>
  800f5b:	83 c4 20             	add    $0x20,%esp
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}

	int i;
	for (i=0; i < USTACKTOP; i+=PGSIZE)
  800f5e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f64:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800f6a:	0f 85 18 ff ff ff    	jne    800e88 <fork+0x74>
		if ((uvpd [PDX(i)] & PTE_P) && (uvpt [PGNUM(i)] & PTE_P) 
			&& (uvpt [PGNUM(i)] & PTE_U))
			duppage (r, PGNUM(i));
	}

	if (sys_page_alloc(r, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P))
  800f70:	83 ec 04             	sub    $0x4,%esp
  800f73:	6a 07                	push   $0x7
  800f75:	68 00 f0 bf ee       	push   $0xeebff000
  800f7a:	57                   	push   %edi
  800f7b:	e8 31 fc ff ff       	call   800bb1 <sys_page_alloc>
  800f80:	83 c4 10             	add    $0x10,%esp
  800f83:	85 c0                	test   %eax,%eax
  800f85:	74 17                	je     800f9e <fork+0x18a>
		panic ("sys_page_alloc error in fork()");
  800f87:	83 ec 04             	sub    $0x4,%esp
  800f8a:	68 60 17 80 00       	push   $0x801760
  800f8f:	68 88 00 00 00       	push   $0x88
  800f94:	68 21 17 80 00       	push   $0x801721
  800f99:	e8 b2 f1 ff ff       	call   800150 <_panic>

	extern void _pgfault_upcall();
	if(sys_env_set_pgfault_upcall(r, _pgfault_upcall))
  800f9e:	83 ec 08             	sub    $0x8,%esp
  800fa1:	68 79 11 80 00       	push   $0x801179
  800fa6:	57                   	push   %edi
  800fa7:	e8 0e fd ff ff       	call   800cba <sys_env_set_pgfault_upcall>
  800fac:	83 c4 10             	add    $0x10,%esp
  800faf:	85 c0                	test   %eax,%eax
  800fb1:	74 17                	je     800fca <fork+0x1b6>
		panic ("sys_env_set_pgfault_upcall error in fork()");
  800fb3:	83 ec 04             	sub    $0x4,%esp
  800fb6:	68 80 17 80 00       	push   $0x801780
  800fbb:	68 8c 00 00 00       	push   $0x8c
  800fc0:	68 21 17 80 00       	push   $0x801721
  800fc5:	e8 86 f1 ff ff       	call   800150 <_panic>

	if (sys_env_set_status(r, ENV_RUNNABLE))
  800fca:	83 ec 08             	sub    $0x8,%esp
  800fcd:	6a 02                	push   $0x2
  800fcf:	57                   	push   %edi
  800fd0:	e8 a3 fc ff ff       	call   800c78 <sys_env_set_status>
  800fd5:	83 c4 10             	add    $0x10,%esp
  800fd8:	85 c0                	test   %eax,%eax
  800fda:	74 17                	je     800ff3 <fork+0x1df>
		panic ("Cannot set status in sys_env_set_status");
  800fdc:	83 ec 04             	sub    $0x4,%esp
  800fdf:	68 ac 17 80 00       	push   $0x8017ac
  800fe4:	68 8f 00 00 00       	push   $0x8f
  800fe9:	68 21 17 80 00       	push   $0x801721
  800fee:	e8 5d f1 ff ff       	call   800150 <_panic>
	return r;
  800ff3:	89 f8                	mov    %edi,%eax



	panic("fork not implemented");
}
  800ff5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ff8:	5b                   	pop    %ebx
  800ff9:	5e                   	pop    %esi
  800ffa:	5f                   	pop    %edi
  800ffb:	5d                   	pop    %ebp
  800ffc:	c3                   	ret    

00800ffd <sfork>:

// Challenge!
int
sfork(void)
{
  800ffd:	55                   	push   %ebp
  800ffe:	89 e5                	mov    %esp,%ebp
  801000:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801003:	68 4a 17 80 00       	push   $0x80174a
  801008:	68 9b 00 00 00       	push   $0x9b
  80100d:	68 21 17 80 00       	push   $0x801721
  801012:	e8 39 f1 ff ff       	call   800150 <_panic>

00801017 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801017:	55                   	push   %ebp
  801018:	89 e5                	mov    %esp,%ebp
  80101a:	56                   	push   %esi
  80101b:	53                   	push   %ebx
  80101c:	8b 75 08             	mov    0x8(%ebp),%esi
  80101f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801022:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	if (!pg) 
  801025:	85 c0                	test   %eax,%eax
		pg = (void*) -1;
  801027:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  80102c:	0f 44 c2             	cmove  %edx,%eax

	if (sys_ipc_recv(pg))
  80102f:	83 ec 0c             	sub    $0xc,%esp
  801032:	50                   	push   %eax
  801033:	e8 e7 fc ff ff       	call   800d1f <sys_ipc_recv>
  801038:	83 c4 10             	add    $0x10,%esp
  80103b:	85 c0                	test   %eax,%eax
  80103d:	74 13                	je     801052 <ipc_recv+0x3b>
	{
		*from_env_store = 0;
  80103f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store = 0;
  801045:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return -E_INVAL;
  80104b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801050:	eb 24                	jmp    801076 <ipc_recv+0x5f>
	}

	if (from_env_store)
  801052:	85 f6                	test   %esi,%esi
  801054:	74 0a                	je     801060 <ipc_recv+0x49>
        *from_env_store = thisenv->env_ipc_from;
  801056:	a1 04 20 80 00       	mov    0x802004,%eax
  80105b:	8b 40 74             	mov    0x74(%eax),%eax
  80105e:	89 06                	mov    %eax,(%esi)
    
    if (perm_store)
  801060:	85 db                	test   %ebx,%ebx
  801062:	74 0a                	je     80106e <ipc_recv+0x57>
        *perm_store = thisenv->env_ipc_perm;
  801064:	a1 04 20 80 00       	mov    0x802004,%eax
  801069:	8b 40 78             	mov    0x78(%eax),%eax
  80106c:	89 03                	mov    %eax,(%ebx)

    return thisenv->env_ipc_value;
  80106e:	a1 04 20 80 00       	mov    0x802004,%eax
  801073:	8b 40 70             	mov    0x70(%eax),%eax

}
  801076:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801079:	5b                   	pop    %ebx
  80107a:	5e                   	pop    %esi
  80107b:	5d                   	pop    %ebp
  80107c:	c3                   	ret    

0080107d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80107d:	55                   	push   %ebp
  80107e:	89 e5                	mov    %esp,%ebp
  801080:	57                   	push   %edi
  801081:	56                   	push   %esi
  801082:	53                   	push   %ebx
  801083:	83 ec 0c             	sub    $0xc,%esp
  801086:	8b 7d 08             	mov    0x8(%ebp),%edi
  801089:	8b 75 0c             	mov    0xc(%ebp),%esi
  80108c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int result;
	if (!pg)
  80108f:	85 db                	test   %ebx,%ebx
		pg = (void *)-1;
  801091:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801096:	0f 44 d8             	cmove  %eax,%ebx
  801099:	eb 05                	jmp    8010a0 <ipc_send+0x23>
	while((result = sys_ipc_try_send(to_env, val, pg, perm)) == -E_IPC_NOT_RECV) {
	    sys_yield();
  80109b:	e8 f2 fa ff ff       	call   800b92 <sys_yield>
	// LAB 4: Your code here.

	int result;
	if (!pg)
		pg = (void *)-1;
	while((result = sys_ipc_try_send(to_env, val, pg, perm)) == -E_IPC_NOT_RECV) {
  8010a0:	ff 75 14             	pushl  0x14(%ebp)
  8010a3:	53                   	push   %ebx
  8010a4:	56                   	push   %esi
  8010a5:	57                   	push   %edi
  8010a6:	e8 51 fc ff ff       	call   800cfc <sys_ipc_try_send>
  8010ab:	83 c4 10             	add    $0x10,%esp
  8010ae:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8010b1:	74 e8                	je     80109b <ipc_send+0x1e>
	    sys_yield();
	}
	if (result)
  8010b3:	85 c0                	test   %eax,%eax
  8010b5:	74 12                	je     8010c9 <ipc_send+0x4c>
		panic ("E_IPC_NOT_RECV %e", result);
  8010b7:	50                   	push   %eax
  8010b8:	68 d4 17 80 00       	push   $0x8017d4
  8010bd:	6a 43                	push   $0x43
  8010bf:	68 e6 17 80 00       	push   $0x8017e6
  8010c4:	e8 87 f0 ff ff       	call   800150 <_panic>
	
}
  8010c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010cc:	5b                   	pop    %ebx
  8010cd:	5e                   	pop    %esi
  8010ce:	5f                   	pop    %edi
  8010cf:	5d                   	pop    %ebp
  8010d0:	c3                   	ret    

008010d1 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8010d1:	55                   	push   %ebp
  8010d2:	89 e5                	mov    %esp,%ebp
  8010d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8010d7:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8010dc:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8010df:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8010e5:	8b 52 50             	mov    0x50(%edx),%edx
  8010e8:	39 ca                	cmp    %ecx,%edx
  8010ea:	75 0d                	jne    8010f9 <ipc_find_env+0x28>
			return envs[i].env_id;
  8010ec:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8010ef:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010f4:	8b 40 48             	mov    0x48(%eax),%eax
  8010f7:	eb 0f                	jmp    801108 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8010f9:	83 c0 01             	add    $0x1,%eax
  8010fc:	3d 00 04 00 00       	cmp    $0x400,%eax
  801101:	75 d9                	jne    8010dc <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801103:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801108:	5d                   	pop    %ebp
  801109:	c3                   	ret    

0080110a <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80110a:	55                   	push   %ebp
  80110b:	89 e5                	mov    %esp,%ebp
  80110d:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801110:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  801117:	75 2c                	jne    801145 <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.

		if (sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801119:	83 ec 04             	sub    $0x4,%esp
  80111c:	6a 07                	push   $0x7
  80111e:	68 00 f0 bf ee       	push   $0xeebff000
  801123:	6a 00                	push   $0x0
  801125:	e8 87 fa ff ff       	call   800bb1 <sys_page_alloc>
  80112a:	83 c4 10             	add    $0x10,%esp
  80112d:	85 c0                	test   %eax,%eax
  80112f:	74 14                	je     801145 <set_pgfault_handler+0x3b>
			PTE_P | PTE_U | PTE_W))
			
        	panic("sys_page_alloc failed.");
  801131:	83 ec 04             	sub    $0x4,%esp
  801134:	68 f0 17 80 00       	push   $0x8017f0
  801139:	6a 24                	push   $0x24
  80113b:	68 07 18 80 00       	push   $0x801807
  801140:	e8 0b f0 ff ff       	call   800150 <_panic>

	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801145:	8b 45 08             	mov    0x8(%ebp),%eax
  801148:	a3 08 20 80 00       	mov    %eax,0x802008
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  80114d:	83 ec 08             	sub    $0x8,%esp
  801150:	68 79 11 80 00       	push   $0x801179
  801155:	6a 00                	push   $0x0
  801157:	e8 5e fb ff ff       	call   800cba <sys_env_set_pgfault_upcall>
  80115c:	83 c4 10             	add    $0x10,%esp
  80115f:	85 c0                	test   %eax,%eax
  801161:	79 14                	jns    801177 <set_pgfault_handler+0x6d>
		panic("sys_env_set_pgfault_upcall failed");
  801163:	83 ec 04             	sub    $0x4,%esp
  801166:	68 18 18 80 00       	push   $0x801818
  80116b:	6a 2b                	push   $0x2b
  80116d:	68 07 18 80 00       	push   $0x801807
  801172:	e8 d9 ef ff ff       	call   800150 <_panic>


}
  801177:	c9                   	leave  
  801178:	c3                   	ret    

00801179 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801179:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80117a:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  80117f:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801181:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	movl 0x28(%esp), %eax
  801184:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp)
  801188:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %ebx
  80118d:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	movl %eax, (%ebx)
  801191:	89 03                	mov    %eax,(%ebx)
	addl $0x8, %esp
  801193:	83 c4 08             	add    $0x8,%esp


	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  801196:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp
  801197:	83 c4 04             	add    $0x4,%esp
	popfl
  80119a:	9d                   	popf   


	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80119b:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80119c:	c3                   	ret    
  80119d:	66 90                	xchg   %ax,%ax
  80119f:	90                   	nop

008011a0 <__udivdi3>:
  8011a0:	55                   	push   %ebp
  8011a1:	57                   	push   %edi
  8011a2:	56                   	push   %esi
  8011a3:	53                   	push   %ebx
  8011a4:	83 ec 1c             	sub    $0x1c,%esp
  8011a7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8011ab:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8011af:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8011b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8011b7:	85 f6                	test   %esi,%esi
  8011b9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8011bd:	89 ca                	mov    %ecx,%edx
  8011bf:	89 f8                	mov    %edi,%eax
  8011c1:	75 3d                	jne    801200 <__udivdi3+0x60>
  8011c3:	39 cf                	cmp    %ecx,%edi
  8011c5:	0f 87 c5 00 00 00    	ja     801290 <__udivdi3+0xf0>
  8011cb:	85 ff                	test   %edi,%edi
  8011cd:	89 fd                	mov    %edi,%ebp
  8011cf:	75 0b                	jne    8011dc <__udivdi3+0x3c>
  8011d1:	b8 01 00 00 00       	mov    $0x1,%eax
  8011d6:	31 d2                	xor    %edx,%edx
  8011d8:	f7 f7                	div    %edi
  8011da:	89 c5                	mov    %eax,%ebp
  8011dc:	89 c8                	mov    %ecx,%eax
  8011de:	31 d2                	xor    %edx,%edx
  8011e0:	f7 f5                	div    %ebp
  8011e2:	89 c1                	mov    %eax,%ecx
  8011e4:	89 d8                	mov    %ebx,%eax
  8011e6:	89 cf                	mov    %ecx,%edi
  8011e8:	f7 f5                	div    %ebp
  8011ea:	89 c3                	mov    %eax,%ebx
  8011ec:	89 d8                	mov    %ebx,%eax
  8011ee:	89 fa                	mov    %edi,%edx
  8011f0:	83 c4 1c             	add    $0x1c,%esp
  8011f3:	5b                   	pop    %ebx
  8011f4:	5e                   	pop    %esi
  8011f5:	5f                   	pop    %edi
  8011f6:	5d                   	pop    %ebp
  8011f7:	c3                   	ret    
  8011f8:	90                   	nop
  8011f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801200:	39 ce                	cmp    %ecx,%esi
  801202:	77 74                	ja     801278 <__udivdi3+0xd8>
  801204:	0f bd fe             	bsr    %esi,%edi
  801207:	83 f7 1f             	xor    $0x1f,%edi
  80120a:	0f 84 98 00 00 00    	je     8012a8 <__udivdi3+0x108>
  801210:	bb 20 00 00 00       	mov    $0x20,%ebx
  801215:	89 f9                	mov    %edi,%ecx
  801217:	89 c5                	mov    %eax,%ebp
  801219:	29 fb                	sub    %edi,%ebx
  80121b:	d3 e6                	shl    %cl,%esi
  80121d:	89 d9                	mov    %ebx,%ecx
  80121f:	d3 ed                	shr    %cl,%ebp
  801221:	89 f9                	mov    %edi,%ecx
  801223:	d3 e0                	shl    %cl,%eax
  801225:	09 ee                	or     %ebp,%esi
  801227:	89 d9                	mov    %ebx,%ecx
  801229:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80122d:	89 d5                	mov    %edx,%ebp
  80122f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801233:	d3 ed                	shr    %cl,%ebp
  801235:	89 f9                	mov    %edi,%ecx
  801237:	d3 e2                	shl    %cl,%edx
  801239:	89 d9                	mov    %ebx,%ecx
  80123b:	d3 e8                	shr    %cl,%eax
  80123d:	09 c2                	or     %eax,%edx
  80123f:	89 d0                	mov    %edx,%eax
  801241:	89 ea                	mov    %ebp,%edx
  801243:	f7 f6                	div    %esi
  801245:	89 d5                	mov    %edx,%ebp
  801247:	89 c3                	mov    %eax,%ebx
  801249:	f7 64 24 0c          	mull   0xc(%esp)
  80124d:	39 d5                	cmp    %edx,%ebp
  80124f:	72 10                	jb     801261 <__udivdi3+0xc1>
  801251:	8b 74 24 08          	mov    0x8(%esp),%esi
  801255:	89 f9                	mov    %edi,%ecx
  801257:	d3 e6                	shl    %cl,%esi
  801259:	39 c6                	cmp    %eax,%esi
  80125b:	73 07                	jae    801264 <__udivdi3+0xc4>
  80125d:	39 d5                	cmp    %edx,%ebp
  80125f:	75 03                	jne    801264 <__udivdi3+0xc4>
  801261:	83 eb 01             	sub    $0x1,%ebx
  801264:	31 ff                	xor    %edi,%edi
  801266:	89 d8                	mov    %ebx,%eax
  801268:	89 fa                	mov    %edi,%edx
  80126a:	83 c4 1c             	add    $0x1c,%esp
  80126d:	5b                   	pop    %ebx
  80126e:	5e                   	pop    %esi
  80126f:	5f                   	pop    %edi
  801270:	5d                   	pop    %ebp
  801271:	c3                   	ret    
  801272:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801278:	31 ff                	xor    %edi,%edi
  80127a:	31 db                	xor    %ebx,%ebx
  80127c:	89 d8                	mov    %ebx,%eax
  80127e:	89 fa                	mov    %edi,%edx
  801280:	83 c4 1c             	add    $0x1c,%esp
  801283:	5b                   	pop    %ebx
  801284:	5e                   	pop    %esi
  801285:	5f                   	pop    %edi
  801286:	5d                   	pop    %ebp
  801287:	c3                   	ret    
  801288:	90                   	nop
  801289:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801290:	89 d8                	mov    %ebx,%eax
  801292:	f7 f7                	div    %edi
  801294:	31 ff                	xor    %edi,%edi
  801296:	89 c3                	mov    %eax,%ebx
  801298:	89 d8                	mov    %ebx,%eax
  80129a:	89 fa                	mov    %edi,%edx
  80129c:	83 c4 1c             	add    $0x1c,%esp
  80129f:	5b                   	pop    %ebx
  8012a0:	5e                   	pop    %esi
  8012a1:	5f                   	pop    %edi
  8012a2:	5d                   	pop    %ebp
  8012a3:	c3                   	ret    
  8012a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012a8:	39 ce                	cmp    %ecx,%esi
  8012aa:	72 0c                	jb     8012b8 <__udivdi3+0x118>
  8012ac:	31 db                	xor    %ebx,%ebx
  8012ae:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8012b2:	0f 87 34 ff ff ff    	ja     8011ec <__udivdi3+0x4c>
  8012b8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8012bd:	e9 2a ff ff ff       	jmp    8011ec <__udivdi3+0x4c>
  8012c2:	66 90                	xchg   %ax,%ax
  8012c4:	66 90                	xchg   %ax,%ax
  8012c6:	66 90                	xchg   %ax,%ax
  8012c8:	66 90                	xchg   %ax,%ax
  8012ca:	66 90                	xchg   %ax,%ax
  8012cc:	66 90                	xchg   %ax,%ax
  8012ce:	66 90                	xchg   %ax,%ax

008012d0 <__umoddi3>:
  8012d0:	55                   	push   %ebp
  8012d1:	57                   	push   %edi
  8012d2:	56                   	push   %esi
  8012d3:	53                   	push   %ebx
  8012d4:	83 ec 1c             	sub    $0x1c,%esp
  8012d7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8012db:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8012df:	8b 74 24 34          	mov    0x34(%esp),%esi
  8012e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8012e7:	85 d2                	test   %edx,%edx
  8012e9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8012ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012f1:	89 f3                	mov    %esi,%ebx
  8012f3:	89 3c 24             	mov    %edi,(%esp)
  8012f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012fa:	75 1c                	jne    801318 <__umoddi3+0x48>
  8012fc:	39 f7                	cmp    %esi,%edi
  8012fe:	76 50                	jbe    801350 <__umoddi3+0x80>
  801300:	89 c8                	mov    %ecx,%eax
  801302:	89 f2                	mov    %esi,%edx
  801304:	f7 f7                	div    %edi
  801306:	89 d0                	mov    %edx,%eax
  801308:	31 d2                	xor    %edx,%edx
  80130a:	83 c4 1c             	add    $0x1c,%esp
  80130d:	5b                   	pop    %ebx
  80130e:	5e                   	pop    %esi
  80130f:	5f                   	pop    %edi
  801310:	5d                   	pop    %ebp
  801311:	c3                   	ret    
  801312:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801318:	39 f2                	cmp    %esi,%edx
  80131a:	89 d0                	mov    %edx,%eax
  80131c:	77 52                	ja     801370 <__umoddi3+0xa0>
  80131e:	0f bd ea             	bsr    %edx,%ebp
  801321:	83 f5 1f             	xor    $0x1f,%ebp
  801324:	75 5a                	jne    801380 <__umoddi3+0xb0>
  801326:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80132a:	0f 82 e0 00 00 00    	jb     801410 <__umoddi3+0x140>
  801330:	39 0c 24             	cmp    %ecx,(%esp)
  801333:	0f 86 d7 00 00 00    	jbe    801410 <__umoddi3+0x140>
  801339:	8b 44 24 08          	mov    0x8(%esp),%eax
  80133d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801341:	83 c4 1c             	add    $0x1c,%esp
  801344:	5b                   	pop    %ebx
  801345:	5e                   	pop    %esi
  801346:	5f                   	pop    %edi
  801347:	5d                   	pop    %ebp
  801348:	c3                   	ret    
  801349:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801350:	85 ff                	test   %edi,%edi
  801352:	89 fd                	mov    %edi,%ebp
  801354:	75 0b                	jne    801361 <__umoddi3+0x91>
  801356:	b8 01 00 00 00       	mov    $0x1,%eax
  80135b:	31 d2                	xor    %edx,%edx
  80135d:	f7 f7                	div    %edi
  80135f:	89 c5                	mov    %eax,%ebp
  801361:	89 f0                	mov    %esi,%eax
  801363:	31 d2                	xor    %edx,%edx
  801365:	f7 f5                	div    %ebp
  801367:	89 c8                	mov    %ecx,%eax
  801369:	f7 f5                	div    %ebp
  80136b:	89 d0                	mov    %edx,%eax
  80136d:	eb 99                	jmp    801308 <__umoddi3+0x38>
  80136f:	90                   	nop
  801370:	89 c8                	mov    %ecx,%eax
  801372:	89 f2                	mov    %esi,%edx
  801374:	83 c4 1c             	add    $0x1c,%esp
  801377:	5b                   	pop    %ebx
  801378:	5e                   	pop    %esi
  801379:	5f                   	pop    %edi
  80137a:	5d                   	pop    %ebp
  80137b:	c3                   	ret    
  80137c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801380:	8b 34 24             	mov    (%esp),%esi
  801383:	bf 20 00 00 00       	mov    $0x20,%edi
  801388:	89 e9                	mov    %ebp,%ecx
  80138a:	29 ef                	sub    %ebp,%edi
  80138c:	d3 e0                	shl    %cl,%eax
  80138e:	89 f9                	mov    %edi,%ecx
  801390:	89 f2                	mov    %esi,%edx
  801392:	d3 ea                	shr    %cl,%edx
  801394:	89 e9                	mov    %ebp,%ecx
  801396:	09 c2                	or     %eax,%edx
  801398:	89 d8                	mov    %ebx,%eax
  80139a:	89 14 24             	mov    %edx,(%esp)
  80139d:	89 f2                	mov    %esi,%edx
  80139f:	d3 e2                	shl    %cl,%edx
  8013a1:	89 f9                	mov    %edi,%ecx
  8013a3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8013a7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8013ab:	d3 e8                	shr    %cl,%eax
  8013ad:	89 e9                	mov    %ebp,%ecx
  8013af:	89 c6                	mov    %eax,%esi
  8013b1:	d3 e3                	shl    %cl,%ebx
  8013b3:	89 f9                	mov    %edi,%ecx
  8013b5:	89 d0                	mov    %edx,%eax
  8013b7:	d3 e8                	shr    %cl,%eax
  8013b9:	89 e9                	mov    %ebp,%ecx
  8013bb:	09 d8                	or     %ebx,%eax
  8013bd:	89 d3                	mov    %edx,%ebx
  8013bf:	89 f2                	mov    %esi,%edx
  8013c1:	f7 34 24             	divl   (%esp)
  8013c4:	89 d6                	mov    %edx,%esi
  8013c6:	d3 e3                	shl    %cl,%ebx
  8013c8:	f7 64 24 04          	mull   0x4(%esp)
  8013cc:	39 d6                	cmp    %edx,%esi
  8013ce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013d2:	89 d1                	mov    %edx,%ecx
  8013d4:	89 c3                	mov    %eax,%ebx
  8013d6:	72 08                	jb     8013e0 <__umoddi3+0x110>
  8013d8:	75 11                	jne    8013eb <__umoddi3+0x11b>
  8013da:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8013de:	73 0b                	jae    8013eb <__umoddi3+0x11b>
  8013e0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8013e4:	1b 14 24             	sbb    (%esp),%edx
  8013e7:	89 d1                	mov    %edx,%ecx
  8013e9:	89 c3                	mov    %eax,%ebx
  8013eb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8013ef:	29 da                	sub    %ebx,%edx
  8013f1:	19 ce                	sbb    %ecx,%esi
  8013f3:	89 f9                	mov    %edi,%ecx
  8013f5:	89 f0                	mov    %esi,%eax
  8013f7:	d3 e0                	shl    %cl,%eax
  8013f9:	89 e9                	mov    %ebp,%ecx
  8013fb:	d3 ea                	shr    %cl,%edx
  8013fd:	89 e9                	mov    %ebp,%ecx
  8013ff:	d3 ee                	shr    %cl,%esi
  801401:	09 d0                	or     %edx,%eax
  801403:	89 f2                	mov    %esi,%edx
  801405:	83 c4 1c             	add    $0x1c,%esp
  801408:	5b                   	pop    %ebx
  801409:	5e                   	pop    %esi
  80140a:	5f                   	pop    %edi
  80140b:	5d                   	pop    %ebp
  80140c:	c3                   	ret    
  80140d:	8d 76 00             	lea    0x0(%esi),%esi
  801410:	29 f9                	sub    %edi,%ecx
  801412:	19 d6                	sbb    %edx,%esi
  801414:	89 74 24 04          	mov    %esi,0x4(%esp)
  801418:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80141c:	e9 18 ff ff ff       	jmp    801339 <__umoddi3+0x69>
