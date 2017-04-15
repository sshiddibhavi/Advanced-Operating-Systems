
obj/user/pingpongs.debug:     file format elf32-i386


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
  80002c:	e8 cd 00 00 00       	call   8000fe <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t val;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 2c             	sub    $0x2c,%esp
	envid_t who;
	uint32_t i;

	i = 0;
	if ((who = sfork()) != 0) {
  80003c:	e8 b8 0f 00 00       	call   800ff9 <sfork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	74 42                	je     80008a <umain+0x57>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800048:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  80004e:	e8 e8 0a 00 00       	call   800b3b <sys_getenvid>
  800053:	83 ec 04             	sub    $0x4,%esp
  800056:	53                   	push   %ebx
  800057:	50                   	push   %eax
  800058:	68 c0 21 80 00       	push   $0x8021c0
  80005d:	e8 8f 01 00 00       	call   8001f1 <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800062:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800065:	e8 d1 0a 00 00       	call   800b3b <sys_getenvid>
  80006a:	83 c4 0c             	add    $0xc,%esp
  80006d:	53                   	push   %ebx
  80006e:	50                   	push   %eax
  80006f:	68 da 21 80 00       	push   $0x8021da
  800074:	e8 78 01 00 00       	call   8001f1 <cprintf>
		ipc_send(who, 0, 0, 0);
  800079:	6a 00                	push   $0x0
  80007b:	6a 00                	push   $0x0
  80007d:	6a 00                	push   $0x0
  80007f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800082:	e8 f5 0f 00 00       	call   80107c <ipc_send>
  800087:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  80008a:	83 ec 04             	sub    $0x4,%esp
  80008d:	6a 00                	push   $0x0
  80008f:	6a 00                	push   $0x0
  800091:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800094:	50                   	push   %eax
  800095:	e8 79 0f 00 00       	call   801013 <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  80009a:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  8000a0:	8b 7b 48             	mov    0x48(%ebx),%edi
  8000a3:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8000a6:	a1 04 40 80 00       	mov    0x804004,%eax
  8000ab:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8000ae:	e8 88 0a 00 00       	call   800b3b <sys_getenvid>
  8000b3:	83 c4 08             	add    $0x8,%esp
  8000b6:	57                   	push   %edi
  8000b7:	53                   	push   %ebx
  8000b8:	56                   	push   %esi
  8000b9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8000bc:	50                   	push   %eax
  8000bd:	68 f0 21 80 00       	push   $0x8021f0
  8000c2:	e8 2a 01 00 00       	call   8001f1 <cprintf>
		if (val == 10)
  8000c7:	a1 04 40 80 00       	mov    0x804004,%eax
  8000cc:	83 c4 20             	add    $0x20,%esp
  8000cf:	83 f8 0a             	cmp    $0xa,%eax
  8000d2:	74 22                	je     8000f6 <umain+0xc3>
			return;
		++val;
  8000d4:	83 c0 01             	add    $0x1,%eax
  8000d7:	a3 04 40 80 00       	mov    %eax,0x804004
		ipc_send(who, 0, 0, 0);
  8000dc:	6a 00                	push   $0x0
  8000de:	6a 00                	push   $0x0
  8000e0:	6a 00                	push   $0x0
  8000e2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000e5:	e8 92 0f 00 00       	call   80107c <ipc_send>
		if (val == 10)
  8000ea:	83 c4 10             	add    $0x10,%esp
  8000ed:	83 3d 04 40 80 00 0a 	cmpl   $0xa,0x804004
  8000f4:	75 94                	jne    80008a <umain+0x57>
			return;
	}

}
  8000f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000f9:	5b                   	pop    %ebx
  8000fa:	5e                   	pop    %esi
  8000fb:	5f                   	pop    %edi
  8000fc:	5d                   	pop    %ebp
  8000fd:	c3                   	ret    

008000fe <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000fe:	55                   	push   %ebp
  8000ff:	89 e5                	mov    %esp,%ebp
  800101:	56                   	push   %esi
  800102:	53                   	push   %ebx
  800103:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800106:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800109:	e8 2d 0a 00 00       	call   800b3b <sys_getenvid>
  80010e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800113:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800116:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011b:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800120:	85 db                	test   %ebx,%ebx
  800122:	7e 07                	jle    80012b <libmain+0x2d>
		binaryname = argv[0];
  800124:	8b 06                	mov    (%esi),%eax
  800126:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80012b:	83 ec 08             	sub    $0x8,%esp
  80012e:	56                   	push   %esi
  80012f:	53                   	push   %ebx
  800130:	e8 fe fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800135:	e8 0a 00 00 00       	call   800144 <exit>
}
  80013a:	83 c4 10             	add    $0x10,%esp
  80013d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800140:	5b                   	pop    %ebx
  800141:	5e                   	pop    %esi
  800142:	5d                   	pop    %ebp
  800143:	c3                   	ret    

00800144 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80014a:	e8 85 11 00 00       	call   8012d4 <close_all>
	sys_env_destroy(0);
  80014f:	83 ec 0c             	sub    $0xc,%esp
  800152:	6a 00                	push   $0x0
  800154:	e8 a1 09 00 00       	call   800afa <sys_env_destroy>
}
  800159:	83 c4 10             	add    $0x10,%esp
  80015c:	c9                   	leave  
  80015d:	c3                   	ret    

0080015e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80015e:	55                   	push   %ebp
  80015f:	89 e5                	mov    %esp,%ebp
  800161:	53                   	push   %ebx
  800162:	83 ec 04             	sub    $0x4,%esp
  800165:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800168:	8b 13                	mov    (%ebx),%edx
  80016a:	8d 42 01             	lea    0x1(%edx),%eax
  80016d:	89 03                	mov    %eax,(%ebx)
  80016f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800172:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800176:	3d ff 00 00 00       	cmp    $0xff,%eax
  80017b:	75 1a                	jne    800197 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80017d:	83 ec 08             	sub    $0x8,%esp
  800180:	68 ff 00 00 00       	push   $0xff
  800185:	8d 43 08             	lea    0x8(%ebx),%eax
  800188:	50                   	push   %eax
  800189:	e8 2f 09 00 00       	call   800abd <sys_cputs>
		b->idx = 0;
  80018e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800194:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800197:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80019b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80019e:	c9                   	leave  
  80019f:	c3                   	ret    

008001a0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001a9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001b0:	00 00 00 
	b.cnt = 0;
  8001b3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ba:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001bd:	ff 75 0c             	pushl  0xc(%ebp)
  8001c0:	ff 75 08             	pushl  0x8(%ebp)
  8001c3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001c9:	50                   	push   %eax
  8001ca:	68 5e 01 80 00       	push   $0x80015e
  8001cf:	e8 54 01 00 00       	call   800328 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001d4:	83 c4 08             	add    $0x8,%esp
  8001d7:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001dd:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001e3:	50                   	push   %eax
  8001e4:	e8 d4 08 00 00       	call   800abd <sys_cputs>

	return b.cnt;
}
  8001e9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ef:	c9                   	leave  
  8001f0:	c3                   	ret    

008001f1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001f1:	55                   	push   %ebp
  8001f2:	89 e5                	mov    %esp,%ebp
  8001f4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001f7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001fa:	50                   	push   %eax
  8001fb:	ff 75 08             	pushl  0x8(%ebp)
  8001fe:	e8 9d ff ff ff       	call   8001a0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800203:	c9                   	leave  
  800204:	c3                   	ret    

00800205 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800205:	55                   	push   %ebp
  800206:	89 e5                	mov    %esp,%ebp
  800208:	57                   	push   %edi
  800209:	56                   	push   %esi
  80020a:	53                   	push   %ebx
  80020b:	83 ec 1c             	sub    $0x1c,%esp
  80020e:	89 c7                	mov    %eax,%edi
  800210:	89 d6                	mov    %edx,%esi
  800212:	8b 45 08             	mov    0x8(%ebp),%eax
  800215:	8b 55 0c             	mov    0xc(%ebp),%edx
  800218:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80021b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80021e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800221:	bb 00 00 00 00       	mov    $0x0,%ebx
  800226:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800229:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80022c:	39 d3                	cmp    %edx,%ebx
  80022e:	72 05                	jb     800235 <printnum+0x30>
  800230:	39 45 10             	cmp    %eax,0x10(%ebp)
  800233:	77 45                	ja     80027a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800235:	83 ec 0c             	sub    $0xc,%esp
  800238:	ff 75 18             	pushl  0x18(%ebp)
  80023b:	8b 45 14             	mov    0x14(%ebp),%eax
  80023e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800241:	53                   	push   %ebx
  800242:	ff 75 10             	pushl  0x10(%ebp)
  800245:	83 ec 08             	sub    $0x8,%esp
  800248:	ff 75 e4             	pushl  -0x1c(%ebp)
  80024b:	ff 75 e0             	pushl  -0x20(%ebp)
  80024e:	ff 75 dc             	pushl  -0x24(%ebp)
  800251:	ff 75 d8             	pushl  -0x28(%ebp)
  800254:	e8 c7 1c 00 00       	call   801f20 <__udivdi3>
  800259:	83 c4 18             	add    $0x18,%esp
  80025c:	52                   	push   %edx
  80025d:	50                   	push   %eax
  80025e:	89 f2                	mov    %esi,%edx
  800260:	89 f8                	mov    %edi,%eax
  800262:	e8 9e ff ff ff       	call   800205 <printnum>
  800267:	83 c4 20             	add    $0x20,%esp
  80026a:	eb 18                	jmp    800284 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80026c:	83 ec 08             	sub    $0x8,%esp
  80026f:	56                   	push   %esi
  800270:	ff 75 18             	pushl  0x18(%ebp)
  800273:	ff d7                	call   *%edi
  800275:	83 c4 10             	add    $0x10,%esp
  800278:	eb 03                	jmp    80027d <printnum+0x78>
  80027a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80027d:	83 eb 01             	sub    $0x1,%ebx
  800280:	85 db                	test   %ebx,%ebx
  800282:	7f e8                	jg     80026c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800284:	83 ec 08             	sub    $0x8,%esp
  800287:	56                   	push   %esi
  800288:	83 ec 04             	sub    $0x4,%esp
  80028b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80028e:	ff 75 e0             	pushl  -0x20(%ebp)
  800291:	ff 75 dc             	pushl  -0x24(%ebp)
  800294:	ff 75 d8             	pushl  -0x28(%ebp)
  800297:	e8 b4 1d 00 00       	call   802050 <__umoddi3>
  80029c:	83 c4 14             	add    $0x14,%esp
  80029f:	0f be 80 20 22 80 00 	movsbl 0x802220(%eax),%eax
  8002a6:	50                   	push   %eax
  8002a7:	ff d7                	call   *%edi
}
  8002a9:	83 c4 10             	add    $0x10,%esp
  8002ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002af:	5b                   	pop    %ebx
  8002b0:	5e                   	pop    %esi
  8002b1:	5f                   	pop    %edi
  8002b2:	5d                   	pop    %ebp
  8002b3:	c3                   	ret    

008002b4 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002b4:	55                   	push   %ebp
  8002b5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002b7:	83 fa 01             	cmp    $0x1,%edx
  8002ba:	7e 0e                	jle    8002ca <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002bc:	8b 10                	mov    (%eax),%edx
  8002be:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002c1:	89 08                	mov    %ecx,(%eax)
  8002c3:	8b 02                	mov    (%edx),%eax
  8002c5:	8b 52 04             	mov    0x4(%edx),%edx
  8002c8:	eb 22                	jmp    8002ec <getuint+0x38>
	else if (lflag)
  8002ca:	85 d2                	test   %edx,%edx
  8002cc:	74 10                	je     8002de <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002ce:	8b 10                	mov    (%eax),%edx
  8002d0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d3:	89 08                	mov    %ecx,(%eax)
  8002d5:	8b 02                	mov    (%edx),%eax
  8002d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8002dc:	eb 0e                	jmp    8002ec <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002de:	8b 10                	mov    (%eax),%edx
  8002e0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e3:	89 08                	mov    %ecx,(%eax)
  8002e5:	8b 02                	mov    (%edx),%eax
  8002e7:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002ec:	5d                   	pop    %ebp
  8002ed:	c3                   	ret    

008002ee <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002ee:	55                   	push   %ebp
  8002ef:	89 e5                	mov    %esp,%ebp
  8002f1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002f4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002f8:	8b 10                	mov    (%eax),%edx
  8002fa:	3b 50 04             	cmp    0x4(%eax),%edx
  8002fd:	73 0a                	jae    800309 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002ff:	8d 4a 01             	lea    0x1(%edx),%ecx
  800302:	89 08                	mov    %ecx,(%eax)
  800304:	8b 45 08             	mov    0x8(%ebp),%eax
  800307:	88 02                	mov    %al,(%edx)
}
  800309:	5d                   	pop    %ebp
  80030a:	c3                   	ret    

0080030b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80030b:	55                   	push   %ebp
  80030c:	89 e5                	mov    %esp,%ebp
  80030e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800311:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800314:	50                   	push   %eax
  800315:	ff 75 10             	pushl  0x10(%ebp)
  800318:	ff 75 0c             	pushl  0xc(%ebp)
  80031b:	ff 75 08             	pushl  0x8(%ebp)
  80031e:	e8 05 00 00 00       	call   800328 <vprintfmt>
	va_end(ap);
}
  800323:	83 c4 10             	add    $0x10,%esp
  800326:	c9                   	leave  
  800327:	c3                   	ret    

00800328 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800328:	55                   	push   %ebp
  800329:	89 e5                	mov    %esp,%ebp
  80032b:	57                   	push   %edi
  80032c:	56                   	push   %esi
  80032d:	53                   	push   %ebx
  80032e:	83 ec 2c             	sub    $0x2c,%esp
  800331:	8b 75 08             	mov    0x8(%ebp),%esi
  800334:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800337:	8b 7d 10             	mov    0x10(%ebp),%edi
  80033a:	eb 12                	jmp    80034e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80033c:	85 c0                	test   %eax,%eax
  80033e:	0f 84 89 03 00 00    	je     8006cd <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800344:	83 ec 08             	sub    $0x8,%esp
  800347:	53                   	push   %ebx
  800348:	50                   	push   %eax
  800349:	ff d6                	call   *%esi
  80034b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80034e:	83 c7 01             	add    $0x1,%edi
  800351:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800355:	83 f8 25             	cmp    $0x25,%eax
  800358:	75 e2                	jne    80033c <vprintfmt+0x14>
  80035a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80035e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800365:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80036c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800373:	ba 00 00 00 00       	mov    $0x0,%edx
  800378:	eb 07                	jmp    800381 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80037d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800381:	8d 47 01             	lea    0x1(%edi),%eax
  800384:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800387:	0f b6 07             	movzbl (%edi),%eax
  80038a:	0f b6 c8             	movzbl %al,%ecx
  80038d:	83 e8 23             	sub    $0x23,%eax
  800390:	3c 55                	cmp    $0x55,%al
  800392:	0f 87 1a 03 00 00    	ja     8006b2 <vprintfmt+0x38a>
  800398:	0f b6 c0             	movzbl %al,%eax
  80039b:	ff 24 85 60 23 80 00 	jmp    *0x802360(,%eax,4)
  8003a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003a5:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003a9:	eb d6                	jmp    800381 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8003b3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003b6:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003b9:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003bd:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003c0:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003c3:	83 fa 09             	cmp    $0x9,%edx
  8003c6:	77 39                	ja     800401 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003c8:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003cb:	eb e9                	jmp    8003b6 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d0:	8d 48 04             	lea    0x4(%eax),%ecx
  8003d3:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003d6:	8b 00                	mov    (%eax),%eax
  8003d8:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003de:	eb 27                	jmp    800407 <vprintfmt+0xdf>
  8003e0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003e3:	85 c0                	test   %eax,%eax
  8003e5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003ea:	0f 49 c8             	cmovns %eax,%ecx
  8003ed:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003f3:	eb 8c                	jmp    800381 <vprintfmt+0x59>
  8003f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003f8:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003ff:	eb 80                	jmp    800381 <vprintfmt+0x59>
  800401:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800404:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800407:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80040b:	0f 89 70 ff ff ff    	jns    800381 <vprintfmt+0x59>
				width = precision, precision = -1;
  800411:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800414:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800417:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80041e:	e9 5e ff ff ff       	jmp    800381 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800423:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800426:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800429:	e9 53 ff ff ff       	jmp    800381 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80042e:	8b 45 14             	mov    0x14(%ebp),%eax
  800431:	8d 50 04             	lea    0x4(%eax),%edx
  800434:	89 55 14             	mov    %edx,0x14(%ebp)
  800437:	83 ec 08             	sub    $0x8,%esp
  80043a:	53                   	push   %ebx
  80043b:	ff 30                	pushl  (%eax)
  80043d:	ff d6                	call   *%esi
			break;
  80043f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800442:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800445:	e9 04 ff ff ff       	jmp    80034e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80044a:	8b 45 14             	mov    0x14(%ebp),%eax
  80044d:	8d 50 04             	lea    0x4(%eax),%edx
  800450:	89 55 14             	mov    %edx,0x14(%ebp)
  800453:	8b 00                	mov    (%eax),%eax
  800455:	99                   	cltd   
  800456:	31 d0                	xor    %edx,%eax
  800458:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80045a:	83 f8 0f             	cmp    $0xf,%eax
  80045d:	7f 0b                	jg     80046a <vprintfmt+0x142>
  80045f:	8b 14 85 c0 24 80 00 	mov    0x8024c0(,%eax,4),%edx
  800466:	85 d2                	test   %edx,%edx
  800468:	75 18                	jne    800482 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80046a:	50                   	push   %eax
  80046b:	68 38 22 80 00       	push   $0x802238
  800470:	53                   	push   %ebx
  800471:	56                   	push   %esi
  800472:	e8 94 fe ff ff       	call   80030b <printfmt>
  800477:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80047d:	e9 cc fe ff ff       	jmp    80034e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800482:	52                   	push   %edx
  800483:	68 8a 26 80 00       	push   $0x80268a
  800488:	53                   	push   %ebx
  800489:	56                   	push   %esi
  80048a:	e8 7c fe ff ff       	call   80030b <printfmt>
  80048f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800492:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800495:	e9 b4 fe ff ff       	jmp    80034e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80049a:	8b 45 14             	mov    0x14(%ebp),%eax
  80049d:	8d 50 04             	lea    0x4(%eax),%edx
  8004a0:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a3:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004a5:	85 ff                	test   %edi,%edi
  8004a7:	b8 31 22 80 00       	mov    $0x802231,%eax
  8004ac:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004af:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004b3:	0f 8e 94 00 00 00    	jle    80054d <vprintfmt+0x225>
  8004b9:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004bd:	0f 84 98 00 00 00    	je     80055b <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c3:	83 ec 08             	sub    $0x8,%esp
  8004c6:	ff 75 d0             	pushl  -0x30(%ebp)
  8004c9:	57                   	push   %edi
  8004ca:	e8 86 02 00 00       	call   800755 <strnlen>
  8004cf:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004d2:	29 c1                	sub    %eax,%ecx
  8004d4:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004d7:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004da:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004de:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004e1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004e4:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e6:	eb 0f                	jmp    8004f7 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004e8:	83 ec 08             	sub    $0x8,%esp
  8004eb:	53                   	push   %ebx
  8004ec:	ff 75 e0             	pushl  -0x20(%ebp)
  8004ef:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f1:	83 ef 01             	sub    $0x1,%edi
  8004f4:	83 c4 10             	add    $0x10,%esp
  8004f7:	85 ff                	test   %edi,%edi
  8004f9:	7f ed                	jg     8004e8 <vprintfmt+0x1c0>
  8004fb:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004fe:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800501:	85 c9                	test   %ecx,%ecx
  800503:	b8 00 00 00 00       	mov    $0x0,%eax
  800508:	0f 49 c1             	cmovns %ecx,%eax
  80050b:	29 c1                	sub    %eax,%ecx
  80050d:	89 75 08             	mov    %esi,0x8(%ebp)
  800510:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800513:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800516:	89 cb                	mov    %ecx,%ebx
  800518:	eb 4d                	jmp    800567 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80051a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80051e:	74 1b                	je     80053b <vprintfmt+0x213>
  800520:	0f be c0             	movsbl %al,%eax
  800523:	83 e8 20             	sub    $0x20,%eax
  800526:	83 f8 5e             	cmp    $0x5e,%eax
  800529:	76 10                	jbe    80053b <vprintfmt+0x213>
					putch('?', putdat);
  80052b:	83 ec 08             	sub    $0x8,%esp
  80052e:	ff 75 0c             	pushl  0xc(%ebp)
  800531:	6a 3f                	push   $0x3f
  800533:	ff 55 08             	call   *0x8(%ebp)
  800536:	83 c4 10             	add    $0x10,%esp
  800539:	eb 0d                	jmp    800548 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80053b:	83 ec 08             	sub    $0x8,%esp
  80053e:	ff 75 0c             	pushl  0xc(%ebp)
  800541:	52                   	push   %edx
  800542:	ff 55 08             	call   *0x8(%ebp)
  800545:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800548:	83 eb 01             	sub    $0x1,%ebx
  80054b:	eb 1a                	jmp    800567 <vprintfmt+0x23f>
  80054d:	89 75 08             	mov    %esi,0x8(%ebp)
  800550:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800553:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800556:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800559:	eb 0c                	jmp    800567 <vprintfmt+0x23f>
  80055b:	89 75 08             	mov    %esi,0x8(%ebp)
  80055e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800561:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800564:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800567:	83 c7 01             	add    $0x1,%edi
  80056a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80056e:	0f be d0             	movsbl %al,%edx
  800571:	85 d2                	test   %edx,%edx
  800573:	74 23                	je     800598 <vprintfmt+0x270>
  800575:	85 f6                	test   %esi,%esi
  800577:	78 a1                	js     80051a <vprintfmt+0x1f2>
  800579:	83 ee 01             	sub    $0x1,%esi
  80057c:	79 9c                	jns    80051a <vprintfmt+0x1f2>
  80057e:	89 df                	mov    %ebx,%edi
  800580:	8b 75 08             	mov    0x8(%ebp),%esi
  800583:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800586:	eb 18                	jmp    8005a0 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800588:	83 ec 08             	sub    $0x8,%esp
  80058b:	53                   	push   %ebx
  80058c:	6a 20                	push   $0x20
  80058e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800590:	83 ef 01             	sub    $0x1,%edi
  800593:	83 c4 10             	add    $0x10,%esp
  800596:	eb 08                	jmp    8005a0 <vprintfmt+0x278>
  800598:	89 df                	mov    %ebx,%edi
  80059a:	8b 75 08             	mov    0x8(%ebp),%esi
  80059d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005a0:	85 ff                	test   %edi,%edi
  8005a2:	7f e4                	jg     800588 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a7:	e9 a2 fd ff ff       	jmp    80034e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005ac:	83 fa 01             	cmp    $0x1,%edx
  8005af:	7e 16                	jle    8005c7 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b4:	8d 50 08             	lea    0x8(%eax),%edx
  8005b7:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ba:	8b 50 04             	mov    0x4(%eax),%edx
  8005bd:	8b 00                	mov    (%eax),%eax
  8005bf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005c5:	eb 32                	jmp    8005f9 <vprintfmt+0x2d1>
	else if (lflag)
  8005c7:	85 d2                	test   %edx,%edx
  8005c9:	74 18                	je     8005e3 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ce:	8d 50 04             	lea    0x4(%eax),%edx
  8005d1:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d4:	8b 00                	mov    (%eax),%eax
  8005d6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d9:	89 c1                	mov    %eax,%ecx
  8005db:	c1 f9 1f             	sar    $0x1f,%ecx
  8005de:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005e1:	eb 16                	jmp    8005f9 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e6:	8d 50 04             	lea    0x4(%eax),%edx
  8005e9:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ec:	8b 00                	mov    (%eax),%eax
  8005ee:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f1:	89 c1                	mov    %eax,%ecx
  8005f3:	c1 f9 1f             	sar    $0x1f,%ecx
  8005f6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005f9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005fc:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005ff:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800604:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800608:	79 74                	jns    80067e <vprintfmt+0x356>
				putch('-', putdat);
  80060a:	83 ec 08             	sub    $0x8,%esp
  80060d:	53                   	push   %ebx
  80060e:	6a 2d                	push   $0x2d
  800610:	ff d6                	call   *%esi
				num = -(long long) num;
  800612:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800615:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800618:	f7 d8                	neg    %eax
  80061a:	83 d2 00             	adc    $0x0,%edx
  80061d:	f7 da                	neg    %edx
  80061f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800622:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800627:	eb 55                	jmp    80067e <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800629:	8d 45 14             	lea    0x14(%ebp),%eax
  80062c:	e8 83 fc ff ff       	call   8002b4 <getuint>
			base = 10;
  800631:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800636:	eb 46                	jmp    80067e <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800638:	8d 45 14             	lea    0x14(%ebp),%eax
  80063b:	e8 74 fc ff ff       	call   8002b4 <getuint>
                        base = 8;
  800640:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800645:	eb 37                	jmp    80067e <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800647:	83 ec 08             	sub    $0x8,%esp
  80064a:	53                   	push   %ebx
  80064b:	6a 30                	push   $0x30
  80064d:	ff d6                	call   *%esi
			putch('x', putdat);
  80064f:	83 c4 08             	add    $0x8,%esp
  800652:	53                   	push   %ebx
  800653:	6a 78                	push   $0x78
  800655:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800657:	8b 45 14             	mov    0x14(%ebp),%eax
  80065a:	8d 50 04             	lea    0x4(%eax),%edx
  80065d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800660:	8b 00                	mov    (%eax),%eax
  800662:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800667:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80066a:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80066f:	eb 0d                	jmp    80067e <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800671:	8d 45 14             	lea    0x14(%ebp),%eax
  800674:	e8 3b fc ff ff       	call   8002b4 <getuint>
			base = 16;
  800679:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80067e:	83 ec 0c             	sub    $0xc,%esp
  800681:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800685:	57                   	push   %edi
  800686:	ff 75 e0             	pushl  -0x20(%ebp)
  800689:	51                   	push   %ecx
  80068a:	52                   	push   %edx
  80068b:	50                   	push   %eax
  80068c:	89 da                	mov    %ebx,%edx
  80068e:	89 f0                	mov    %esi,%eax
  800690:	e8 70 fb ff ff       	call   800205 <printnum>
			break;
  800695:	83 c4 20             	add    $0x20,%esp
  800698:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80069b:	e9 ae fc ff ff       	jmp    80034e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006a0:	83 ec 08             	sub    $0x8,%esp
  8006a3:	53                   	push   %ebx
  8006a4:	51                   	push   %ecx
  8006a5:	ff d6                	call   *%esi
			break;
  8006a7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006ad:	e9 9c fc ff ff       	jmp    80034e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006b2:	83 ec 08             	sub    $0x8,%esp
  8006b5:	53                   	push   %ebx
  8006b6:	6a 25                	push   $0x25
  8006b8:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006ba:	83 c4 10             	add    $0x10,%esp
  8006bd:	eb 03                	jmp    8006c2 <vprintfmt+0x39a>
  8006bf:	83 ef 01             	sub    $0x1,%edi
  8006c2:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006c6:	75 f7                	jne    8006bf <vprintfmt+0x397>
  8006c8:	e9 81 fc ff ff       	jmp    80034e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006d0:	5b                   	pop    %ebx
  8006d1:	5e                   	pop    %esi
  8006d2:	5f                   	pop    %edi
  8006d3:	5d                   	pop    %ebp
  8006d4:	c3                   	ret    

008006d5 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006d5:	55                   	push   %ebp
  8006d6:	89 e5                	mov    %esp,%ebp
  8006d8:	83 ec 18             	sub    $0x18,%esp
  8006db:	8b 45 08             	mov    0x8(%ebp),%eax
  8006de:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006e1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006e4:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006e8:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006eb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006f2:	85 c0                	test   %eax,%eax
  8006f4:	74 26                	je     80071c <vsnprintf+0x47>
  8006f6:	85 d2                	test   %edx,%edx
  8006f8:	7e 22                	jle    80071c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006fa:	ff 75 14             	pushl  0x14(%ebp)
  8006fd:	ff 75 10             	pushl  0x10(%ebp)
  800700:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800703:	50                   	push   %eax
  800704:	68 ee 02 80 00       	push   $0x8002ee
  800709:	e8 1a fc ff ff       	call   800328 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80070e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800711:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800714:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800717:	83 c4 10             	add    $0x10,%esp
  80071a:	eb 05                	jmp    800721 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80071c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800721:	c9                   	leave  
  800722:	c3                   	ret    

00800723 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800723:	55                   	push   %ebp
  800724:	89 e5                	mov    %esp,%ebp
  800726:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800729:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80072c:	50                   	push   %eax
  80072d:	ff 75 10             	pushl  0x10(%ebp)
  800730:	ff 75 0c             	pushl  0xc(%ebp)
  800733:	ff 75 08             	pushl  0x8(%ebp)
  800736:	e8 9a ff ff ff       	call   8006d5 <vsnprintf>
	va_end(ap);

	return rc;
}
  80073b:	c9                   	leave  
  80073c:	c3                   	ret    

0080073d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80073d:	55                   	push   %ebp
  80073e:	89 e5                	mov    %esp,%ebp
  800740:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800743:	b8 00 00 00 00       	mov    $0x0,%eax
  800748:	eb 03                	jmp    80074d <strlen+0x10>
		n++;
  80074a:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80074d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800751:	75 f7                	jne    80074a <strlen+0xd>
		n++;
	return n;
}
  800753:	5d                   	pop    %ebp
  800754:	c3                   	ret    

00800755 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800755:	55                   	push   %ebp
  800756:	89 e5                	mov    %esp,%ebp
  800758:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80075b:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80075e:	ba 00 00 00 00       	mov    $0x0,%edx
  800763:	eb 03                	jmp    800768 <strnlen+0x13>
		n++;
  800765:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800768:	39 c2                	cmp    %eax,%edx
  80076a:	74 08                	je     800774 <strnlen+0x1f>
  80076c:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800770:	75 f3                	jne    800765 <strnlen+0x10>
  800772:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800774:	5d                   	pop    %ebp
  800775:	c3                   	ret    

00800776 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800776:	55                   	push   %ebp
  800777:	89 e5                	mov    %esp,%ebp
  800779:	53                   	push   %ebx
  80077a:	8b 45 08             	mov    0x8(%ebp),%eax
  80077d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800780:	89 c2                	mov    %eax,%edx
  800782:	83 c2 01             	add    $0x1,%edx
  800785:	83 c1 01             	add    $0x1,%ecx
  800788:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80078c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80078f:	84 db                	test   %bl,%bl
  800791:	75 ef                	jne    800782 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800793:	5b                   	pop    %ebx
  800794:	5d                   	pop    %ebp
  800795:	c3                   	ret    

00800796 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800796:	55                   	push   %ebp
  800797:	89 e5                	mov    %esp,%ebp
  800799:	53                   	push   %ebx
  80079a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80079d:	53                   	push   %ebx
  80079e:	e8 9a ff ff ff       	call   80073d <strlen>
  8007a3:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007a6:	ff 75 0c             	pushl  0xc(%ebp)
  8007a9:	01 d8                	add    %ebx,%eax
  8007ab:	50                   	push   %eax
  8007ac:	e8 c5 ff ff ff       	call   800776 <strcpy>
	return dst;
}
  8007b1:	89 d8                	mov    %ebx,%eax
  8007b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b6:	c9                   	leave  
  8007b7:	c3                   	ret    

008007b8 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007b8:	55                   	push   %ebp
  8007b9:	89 e5                	mov    %esp,%ebp
  8007bb:	56                   	push   %esi
  8007bc:	53                   	push   %ebx
  8007bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007c3:	89 f3                	mov    %esi,%ebx
  8007c5:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c8:	89 f2                	mov    %esi,%edx
  8007ca:	eb 0f                	jmp    8007db <strncpy+0x23>
		*dst++ = *src;
  8007cc:	83 c2 01             	add    $0x1,%edx
  8007cf:	0f b6 01             	movzbl (%ecx),%eax
  8007d2:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007d5:	80 39 01             	cmpb   $0x1,(%ecx)
  8007d8:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007db:	39 da                	cmp    %ebx,%edx
  8007dd:	75 ed                	jne    8007cc <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007df:	89 f0                	mov    %esi,%eax
  8007e1:	5b                   	pop    %ebx
  8007e2:	5e                   	pop    %esi
  8007e3:	5d                   	pop    %ebp
  8007e4:	c3                   	ret    

008007e5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007e5:	55                   	push   %ebp
  8007e6:	89 e5                	mov    %esp,%ebp
  8007e8:	56                   	push   %esi
  8007e9:	53                   	push   %ebx
  8007ea:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f0:	8b 55 10             	mov    0x10(%ebp),%edx
  8007f3:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007f5:	85 d2                	test   %edx,%edx
  8007f7:	74 21                	je     80081a <strlcpy+0x35>
  8007f9:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007fd:	89 f2                	mov    %esi,%edx
  8007ff:	eb 09                	jmp    80080a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800801:	83 c2 01             	add    $0x1,%edx
  800804:	83 c1 01             	add    $0x1,%ecx
  800807:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80080a:	39 c2                	cmp    %eax,%edx
  80080c:	74 09                	je     800817 <strlcpy+0x32>
  80080e:	0f b6 19             	movzbl (%ecx),%ebx
  800811:	84 db                	test   %bl,%bl
  800813:	75 ec                	jne    800801 <strlcpy+0x1c>
  800815:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800817:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80081a:	29 f0                	sub    %esi,%eax
}
  80081c:	5b                   	pop    %ebx
  80081d:	5e                   	pop    %esi
  80081e:	5d                   	pop    %ebp
  80081f:	c3                   	ret    

00800820 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800820:	55                   	push   %ebp
  800821:	89 e5                	mov    %esp,%ebp
  800823:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800826:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800829:	eb 06                	jmp    800831 <strcmp+0x11>
		p++, q++;
  80082b:	83 c1 01             	add    $0x1,%ecx
  80082e:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800831:	0f b6 01             	movzbl (%ecx),%eax
  800834:	84 c0                	test   %al,%al
  800836:	74 04                	je     80083c <strcmp+0x1c>
  800838:	3a 02                	cmp    (%edx),%al
  80083a:	74 ef                	je     80082b <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80083c:	0f b6 c0             	movzbl %al,%eax
  80083f:	0f b6 12             	movzbl (%edx),%edx
  800842:	29 d0                	sub    %edx,%eax
}
  800844:	5d                   	pop    %ebp
  800845:	c3                   	ret    

00800846 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800846:	55                   	push   %ebp
  800847:	89 e5                	mov    %esp,%ebp
  800849:	53                   	push   %ebx
  80084a:	8b 45 08             	mov    0x8(%ebp),%eax
  80084d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800850:	89 c3                	mov    %eax,%ebx
  800852:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800855:	eb 06                	jmp    80085d <strncmp+0x17>
		n--, p++, q++;
  800857:	83 c0 01             	add    $0x1,%eax
  80085a:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80085d:	39 d8                	cmp    %ebx,%eax
  80085f:	74 15                	je     800876 <strncmp+0x30>
  800861:	0f b6 08             	movzbl (%eax),%ecx
  800864:	84 c9                	test   %cl,%cl
  800866:	74 04                	je     80086c <strncmp+0x26>
  800868:	3a 0a                	cmp    (%edx),%cl
  80086a:	74 eb                	je     800857 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80086c:	0f b6 00             	movzbl (%eax),%eax
  80086f:	0f b6 12             	movzbl (%edx),%edx
  800872:	29 d0                	sub    %edx,%eax
  800874:	eb 05                	jmp    80087b <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800876:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80087b:	5b                   	pop    %ebx
  80087c:	5d                   	pop    %ebp
  80087d:	c3                   	ret    

0080087e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80087e:	55                   	push   %ebp
  80087f:	89 e5                	mov    %esp,%ebp
  800881:	8b 45 08             	mov    0x8(%ebp),%eax
  800884:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800888:	eb 07                	jmp    800891 <strchr+0x13>
		if (*s == c)
  80088a:	38 ca                	cmp    %cl,%dl
  80088c:	74 0f                	je     80089d <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80088e:	83 c0 01             	add    $0x1,%eax
  800891:	0f b6 10             	movzbl (%eax),%edx
  800894:	84 d2                	test   %dl,%dl
  800896:	75 f2                	jne    80088a <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800898:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80089d:	5d                   	pop    %ebp
  80089e:	c3                   	ret    

0080089f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80089f:	55                   	push   %ebp
  8008a0:	89 e5                	mov    %esp,%ebp
  8008a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008a9:	eb 03                	jmp    8008ae <strfind+0xf>
  8008ab:	83 c0 01             	add    $0x1,%eax
  8008ae:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008b1:	38 ca                	cmp    %cl,%dl
  8008b3:	74 04                	je     8008b9 <strfind+0x1a>
  8008b5:	84 d2                	test   %dl,%dl
  8008b7:	75 f2                	jne    8008ab <strfind+0xc>
			break;
	return (char *) s;
}
  8008b9:	5d                   	pop    %ebp
  8008ba:	c3                   	ret    

008008bb <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008bb:	55                   	push   %ebp
  8008bc:	89 e5                	mov    %esp,%ebp
  8008be:	57                   	push   %edi
  8008bf:	56                   	push   %esi
  8008c0:	53                   	push   %ebx
  8008c1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008c4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008c7:	85 c9                	test   %ecx,%ecx
  8008c9:	74 36                	je     800901 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008cb:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008d1:	75 28                	jne    8008fb <memset+0x40>
  8008d3:	f6 c1 03             	test   $0x3,%cl
  8008d6:	75 23                	jne    8008fb <memset+0x40>
		c &= 0xFF;
  8008d8:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008dc:	89 d3                	mov    %edx,%ebx
  8008de:	c1 e3 08             	shl    $0x8,%ebx
  8008e1:	89 d6                	mov    %edx,%esi
  8008e3:	c1 e6 18             	shl    $0x18,%esi
  8008e6:	89 d0                	mov    %edx,%eax
  8008e8:	c1 e0 10             	shl    $0x10,%eax
  8008eb:	09 f0                	or     %esi,%eax
  8008ed:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008ef:	89 d8                	mov    %ebx,%eax
  8008f1:	09 d0                	or     %edx,%eax
  8008f3:	c1 e9 02             	shr    $0x2,%ecx
  8008f6:	fc                   	cld    
  8008f7:	f3 ab                	rep stos %eax,%es:(%edi)
  8008f9:	eb 06                	jmp    800901 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008fe:	fc                   	cld    
  8008ff:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800901:	89 f8                	mov    %edi,%eax
  800903:	5b                   	pop    %ebx
  800904:	5e                   	pop    %esi
  800905:	5f                   	pop    %edi
  800906:	5d                   	pop    %ebp
  800907:	c3                   	ret    

00800908 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800908:	55                   	push   %ebp
  800909:	89 e5                	mov    %esp,%ebp
  80090b:	57                   	push   %edi
  80090c:	56                   	push   %esi
  80090d:	8b 45 08             	mov    0x8(%ebp),%eax
  800910:	8b 75 0c             	mov    0xc(%ebp),%esi
  800913:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800916:	39 c6                	cmp    %eax,%esi
  800918:	73 35                	jae    80094f <memmove+0x47>
  80091a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80091d:	39 d0                	cmp    %edx,%eax
  80091f:	73 2e                	jae    80094f <memmove+0x47>
		s += n;
		d += n;
  800921:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800924:	89 d6                	mov    %edx,%esi
  800926:	09 fe                	or     %edi,%esi
  800928:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80092e:	75 13                	jne    800943 <memmove+0x3b>
  800930:	f6 c1 03             	test   $0x3,%cl
  800933:	75 0e                	jne    800943 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800935:	83 ef 04             	sub    $0x4,%edi
  800938:	8d 72 fc             	lea    -0x4(%edx),%esi
  80093b:	c1 e9 02             	shr    $0x2,%ecx
  80093e:	fd                   	std    
  80093f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800941:	eb 09                	jmp    80094c <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800943:	83 ef 01             	sub    $0x1,%edi
  800946:	8d 72 ff             	lea    -0x1(%edx),%esi
  800949:	fd                   	std    
  80094a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80094c:	fc                   	cld    
  80094d:	eb 1d                	jmp    80096c <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80094f:	89 f2                	mov    %esi,%edx
  800951:	09 c2                	or     %eax,%edx
  800953:	f6 c2 03             	test   $0x3,%dl
  800956:	75 0f                	jne    800967 <memmove+0x5f>
  800958:	f6 c1 03             	test   $0x3,%cl
  80095b:	75 0a                	jne    800967 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80095d:	c1 e9 02             	shr    $0x2,%ecx
  800960:	89 c7                	mov    %eax,%edi
  800962:	fc                   	cld    
  800963:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800965:	eb 05                	jmp    80096c <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800967:	89 c7                	mov    %eax,%edi
  800969:	fc                   	cld    
  80096a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80096c:	5e                   	pop    %esi
  80096d:	5f                   	pop    %edi
  80096e:	5d                   	pop    %ebp
  80096f:	c3                   	ret    

00800970 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800970:	55                   	push   %ebp
  800971:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800973:	ff 75 10             	pushl  0x10(%ebp)
  800976:	ff 75 0c             	pushl  0xc(%ebp)
  800979:	ff 75 08             	pushl  0x8(%ebp)
  80097c:	e8 87 ff ff ff       	call   800908 <memmove>
}
  800981:	c9                   	leave  
  800982:	c3                   	ret    

00800983 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800983:	55                   	push   %ebp
  800984:	89 e5                	mov    %esp,%ebp
  800986:	56                   	push   %esi
  800987:	53                   	push   %ebx
  800988:	8b 45 08             	mov    0x8(%ebp),%eax
  80098b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098e:	89 c6                	mov    %eax,%esi
  800990:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800993:	eb 1a                	jmp    8009af <memcmp+0x2c>
		if (*s1 != *s2)
  800995:	0f b6 08             	movzbl (%eax),%ecx
  800998:	0f b6 1a             	movzbl (%edx),%ebx
  80099b:	38 d9                	cmp    %bl,%cl
  80099d:	74 0a                	je     8009a9 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80099f:	0f b6 c1             	movzbl %cl,%eax
  8009a2:	0f b6 db             	movzbl %bl,%ebx
  8009a5:	29 d8                	sub    %ebx,%eax
  8009a7:	eb 0f                	jmp    8009b8 <memcmp+0x35>
		s1++, s2++;
  8009a9:	83 c0 01             	add    $0x1,%eax
  8009ac:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009af:	39 f0                	cmp    %esi,%eax
  8009b1:	75 e2                	jne    800995 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009b3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009b8:	5b                   	pop    %ebx
  8009b9:	5e                   	pop    %esi
  8009ba:	5d                   	pop    %ebp
  8009bb:	c3                   	ret    

008009bc <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009bc:	55                   	push   %ebp
  8009bd:	89 e5                	mov    %esp,%ebp
  8009bf:	53                   	push   %ebx
  8009c0:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009c3:	89 c1                	mov    %eax,%ecx
  8009c5:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009c8:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009cc:	eb 0a                	jmp    8009d8 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ce:	0f b6 10             	movzbl (%eax),%edx
  8009d1:	39 da                	cmp    %ebx,%edx
  8009d3:	74 07                	je     8009dc <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009d5:	83 c0 01             	add    $0x1,%eax
  8009d8:	39 c8                	cmp    %ecx,%eax
  8009da:	72 f2                	jb     8009ce <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009dc:	5b                   	pop    %ebx
  8009dd:	5d                   	pop    %ebp
  8009de:	c3                   	ret    

008009df <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009df:	55                   	push   %ebp
  8009e0:	89 e5                	mov    %esp,%ebp
  8009e2:	57                   	push   %edi
  8009e3:	56                   	push   %esi
  8009e4:	53                   	push   %ebx
  8009e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009e8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009eb:	eb 03                	jmp    8009f0 <strtol+0x11>
		s++;
  8009ed:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009f0:	0f b6 01             	movzbl (%ecx),%eax
  8009f3:	3c 20                	cmp    $0x20,%al
  8009f5:	74 f6                	je     8009ed <strtol+0xe>
  8009f7:	3c 09                	cmp    $0x9,%al
  8009f9:	74 f2                	je     8009ed <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009fb:	3c 2b                	cmp    $0x2b,%al
  8009fd:	75 0a                	jne    800a09 <strtol+0x2a>
		s++;
  8009ff:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a02:	bf 00 00 00 00       	mov    $0x0,%edi
  800a07:	eb 11                	jmp    800a1a <strtol+0x3b>
  800a09:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a0e:	3c 2d                	cmp    $0x2d,%al
  800a10:	75 08                	jne    800a1a <strtol+0x3b>
		s++, neg = 1;
  800a12:	83 c1 01             	add    $0x1,%ecx
  800a15:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a1a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a20:	75 15                	jne    800a37 <strtol+0x58>
  800a22:	80 39 30             	cmpb   $0x30,(%ecx)
  800a25:	75 10                	jne    800a37 <strtol+0x58>
  800a27:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a2b:	75 7c                	jne    800aa9 <strtol+0xca>
		s += 2, base = 16;
  800a2d:	83 c1 02             	add    $0x2,%ecx
  800a30:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a35:	eb 16                	jmp    800a4d <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a37:	85 db                	test   %ebx,%ebx
  800a39:	75 12                	jne    800a4d <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a3b:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a40:	80 39 30             	cmpb   $0x30,(%ecx)
  800a43:	75 08                	jne    800a4d <strtol+0x6e>
		s++, base = 8;
  800a45:	83 c1 01             	add    $0x1,%ecx
  800a48:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a4d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a52:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a55:	0f b6 11             	movzbl (%ecx),%edx
  800a58:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a5b:	89 f3                	mov    %esi,%ebx
  800a5d:	80 fb 09             	cmp    $0x9,%bl
  800a60:	77 08                	ja     800a6a <strtol+0x8b>
			dig = *s - '0';
  800a62:	0f be d2             	movsbl %dl,%edx
  800a65:	83 ea 30             	sub    $0x30,%edx
  800a68:	eb 22                	jmp    800a8c <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a6a:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a6d:	89 f3                	mov    %esi,%ebx
  800a6f:	80 fb 19             	cmp    $0x19,%bl
  800a72:	77 08                	ja     800a7c <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a74:	0f be d2             	movsbl %dl,%edx
  800a77:	83 ea 57             	sub    $0x57,%edx
  800a7a:	eb 10                	jmp    800a8c <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a7c:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a7f:	89 f3                	mov    %esi,%ebx
  800a81:	80 fb 19             	cmp    $0x19,%bl
  800a84:	77 16                	ja     800a9c <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a86:	0f be d2             	movsbl %dl,%edx
  800a89:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a8c:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a8f:	7d 0b                	jge    800a9c <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a91:	83 c1 01             	add    $0x1,%ecx
  800a94:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a98:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a9a:	eb b9                	jmp    800a55 <strtol+0x76>

	if (endptr)
  800a9c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aa0:	74 0d                	je     800aaf <strtol+0xd0>
		*endptr = (char *) s;
  800aa2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aa5:	89 0e                	mov    %ecx,(%esi)
  800aa7:	eb 06                	jmp    800aaf <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aa9:	85 db                	test   %ebx,%ebx
  800aab:	74 98                	je     800a45 <strtol+0x66>
  800aad:	eb 9e                	jmp    800a4d <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800aaf:	89 c2                	mov    %eax,%edx
  800ab1:	f7 da                	neg    %edx
  800ab3:	85 ff                	test   %edi,%edi
  800ab5:	0f 45 c2             	cmovne %edx,%eax
}
  800ab8:	5b                   	pop    %ebx
  800ab9:	5e                   	pop    %esi
  800aba:	5f                   	pop    %edi
  800abb:	5d                   	pop    %ebp
  800abc:	c3                   	ret    

00800abd <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800abd:	55                   	push   %ebp
  800abe:	89 e5                	mov    %esp,%ebp
  800ac0:	57                   	push   %edi
  800ac1:	56                   	push   %esi
  800ac2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800acb:	8b 55 08             	mov    0x8(%ebp),%edx
  800ace:	89 c3                	mov    %eax,%ebx
  800ad0:	89 c7                	mov    %eax,%edi
  800ad2:	89 c6                	mov    %eax,%esi
  800ad4:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ad6:	5b                   	pop    %ebx
  800ad7:	5e                   	pop    %esi
  800ad8:	5f                   	pop    %edi
  800ad9:	5d                   	pop    %ebp
  800ada:	c3                   	ret    

00800adb <sys_cgetc>:

int
sys_cgetc(void)
{
  800adb:	55                   	push   %ebp
  800adc:	89 e5                	mov    %esp,%ebp
  800ade:	57                   	push   %edi
  800adf:	56                   	push   %esi
  800ae0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae6:	b8 01 00 00 00       	mov    $0x1,%eax
  800aeb:	89 d1                	mov    %edx,%ecx
  800aed:	89 d3                	mov    %edx,%ebx
  800aef:	89 d7                	mov    %edx,%edi
  800af1:	89 d6                	mov    %edx,%esi
  800af3:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800af5:	5b                   	pop    %ebx
  800af6:	5e                   	pop    %esi
  800af7:	5f                   	pop    %edi
  800af8:	5d                   	pop    %ebp
  800af9:	c3                   	ret    

00800afa <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800afa:	55                   	push   %ebp
  800afb:	89 e5                	mov    %esp,%ebp
  800afd:	57                   	push   %edi
  800afe:	56                   	push   %esi
  800aff:	53                   	push   %ebx
  800b00:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b03:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b08:	b8 03 00 00 00       	mov    $0x3,%eax
  800b0d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b10:	89 cb                	mov    %ecx,%ebx
  800b12:	89 cf                	mov    %ecx,%edi
  800b14:	89 ce                	mov    %ecx,%esi
  800b16:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b18:	85 c0                	test   %eax,%eax
  800b1a:	7e 17                	jle    800b33 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b1c:	83 ec 0c             	sub    $0xc,%esp
  800b1f:	50                   	push   %eax
  800b20:	6a 03                	push   $0x3
  800b22:	68 1f 25 80 00       	push   $0x80251f
  800b27:	6a 23                	push   $0x23
  800b29:	68 3c 25 80 00       	push   $0x80253c
  800b2e:	e8 e9 12 00 00       	call   801e1c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b36:	5b                   	pop    %ebx
  800b37:	5e                   	pop    %esi
  800b38:	5f                   	pop    %edi
  800b39:	5d                   	pop    %ebp
  800b3a:	c3                   	ret    

00800b3b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b3b:	55                   	push   %ebp
  800b3c:	89 e5                	mov    %esp,%ebp
  800b3e:	57                   	push   %edi
  800b3f:	56                   	push   %esi
  800b40:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b41:	ba 00 00 00 00       	mov    $0x0,%edx
  800b46:	b8 02 00 00 00       	mov    $0x2,%eax
  800b4b:	89 d1                	mov    %edx,%ecx
  800b4d:	89 d3                	mov    %edx,%ebx
  800b4f:	89 d7                	mov    %edx,%edi
  800b51:	89 d6                	mov    %edx,%esi
  800b53:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b55:	5b                   	pop    %ebx
  800b56:	5e                   	pop    %esi
  800b57:	5f                   	pop    %edi
  800b58:	5d                   	pop    %ebp
  800b59:	c3                   	ret    

00800b5a <sys_yield>:

void
sys_yield(void)
{
  800b5a:	55                   	push   %ebp
  800b5b:	89 e5                	mov    %esp,%ebp
  800b5d:	57                   	push   %edi
  800b5e:	56                   	push   %esi
  800b5f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b60:	ba 00 00 00 00       	mov    $0x0,%edx
  800b65:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b6a:	89 d1                	mov    %edx,%ecx
  800b6c:	89 d3                	mov    %edx,%ebx
  800b6e:	89 d7                	mov    %edx,%edi
  800b70:	89 d6                	mov    %edx,%esi
  800b72:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b74:	5b                   	pop    %ebx
  800b75:	5e                   	pop    %esi
  800b76:	5f                   	pop    %edi
  800b77:	5d                   	pop    %ebp
  800b78:	c3                   	ret    

00800b79 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b79:	55                   	push   %ebp
  800b7a:	89 e5                	mov    %esp,%ebp
  800b7c:	57                   	push   %edi
  800b7d:	56                   	push   %esi
  800b7e:	53                   	push   %ebx
  800b7f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b82:	be 00 00 00 00       	mov    $0x0,%esi
  800b87:	b8 04 00 00 00       	mov    $0x4,%eax
  800b8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b92:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b95:	89 f7                	mov    %esi,%edi
  800b97:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b99:	85 c0                	test   %eax,%eax
  800b9b:	7e 17                	jle    800bb4 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9d:	83 ec 0c             	sub    $0xc,%esp
  800ba0:	50                   	push   %eax
  800ba1:	6a 04                	push   $0x4
  800ba3:	68 1f 25 80 00       	push   $0x80251f
  800ba8:	6a 23                	push   $0x23
  800baa:	68 3c 25 80 00       	push   $0x80253c
  800baf:	e8 68 12 00 00       	call   801e1c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bb4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb7:	5b                   	pop    %ebx
  800bb8:	5e                   	pop    %esi
  800bb9:	5f                   	pop    %edi
  800bba:	5d                   	pop    %ebp
  800bbb:	c3                   	ret    

00800bbc <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bbc:	55                   	push   %ebp
  800bbd:	89 e5                	mov    %esp,%ebp
  800bbf:	57                   	push   %edi
  800bc0:	56                   	push   %esi
  800bc1:	53                   	push   %ebx
  800bc2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc5:	b8 05 00 00 00       	mov    $0x5,%eax
  800bca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bcd:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd3:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bd6:	8b 75 18             	mov    0x18(%ebp),%esi
  800bd9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bdb:	85 c0                	test   %eax,%eax
  800bdd:	7e 17                	jle    800bf6 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bdf:	83 ec 0c             	sub    $0xc,%esp
  800be2:	50                   	push   %eax
  800be3:	6a 05                	push   $0x5
  800be5:	68 1f 25 80 00       	push   $0x80251f
  800bea:	6a 23                	push   $0x23
  800bec:	68 3c 25 80 00       	push   $0x80253c
  800bf1:	e8 26 12 00 00       	call   801e1c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bf6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf9:	5b                   	pop    %ebx
  800bfa:	5e                   	pop    %esi
  800bfb:	5f                   	pop    %edi
  800bfc:	5d                   	pop    %ebp
  800bfd:	c3                   	ret    

00800bfe <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bfe:	55                   	push   %ebp
  800bff:	89 e5                	mov    %esp,%ebp
  800c01:	57                   	push   %edi
  800c02:	56                   	push   %esi
  800c03:	53                   	push   %ebx
  800c04:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c07:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c0c:	b8 06 00 00 00       	mov    $0x6,%eax
  800c11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c14:	8b 55 08             	mov    0x8(%ebp),%edx
  800c17:	89 df                	mov    %ebx,%edi
  800c19:	89 de                	mov    %ebx,%esi
  800c1b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c1d:	85 c0                	test   %eax,%eax
  800c1f:	7e 17                	jle    800c38 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c21:	83 ec 0c             	sub    $0xc,%esp
  800c24:	50                   	push   %eax
  800c25:	6a 06                	push   $0x6
  800c27:	68 1f 25 80 00       	push   $0x80251f
  800c2c:	6a 23                	push   $0x23
  800c2e:	68 3c 25 80 00       	push   $0x80253c
  800c33:	e8 e4 11 00 00       	call   801e1c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c38:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3b:	5b                   	pop    %ebx
  800c3c:	5e                   	pop    %esi
  800c3d:	5f                   	pop    %edi
  800c3e:	5d                   	pop    %ebp
  800c3f:	c3                   	ret    

00800c40 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c40:	55                   	push   %ebp
  800c41:	89 e5                	mov    %esp,%ebp
  800c43:	57                   	push   %edi
  800c44:	56                   	push   %esi
  800c45:	53                   	push   %ebx
  800c46:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c49:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c4e:	b8 08 00 00 00       	mov    $0x8,%eax
  800c53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c56:	8b 55 08             	mov    0x8(%ebp),%edx
  800c59:	89 df                	mov    %ebx,%edi
  800c5b:	89 de                	mov    %ebx,%esi
  800c5d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c5f:	85 c0                	test   %eax,%eax
  800c61:	7e 17                	jle    800c7a <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c63:	83 ec 0c             	sub    $0xc,%esp
  800c66:	50                   	push   %eax
  800c67:	6a 08                	push   $0x8
  800c69:	68 1f 25 80 00       	push   $0x80251f
  800c6e:	6a 23                	push   $0x23
  800c70:	68 3c 25 80 00       	push   $0x80253c
  800c75:	e8 a2 11 00 00       	call   801e1c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7d:	5b                   	pop    %ebx
  800c7e:	5e                   	pop    %esi
  800c7f:	5f                   	pop    %edi
  800c80:	5d                   	pop    %ebp
  800c81:	c3                   	ret    

00800c82 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c82:	55                   	push   %ebp
  800c83:	89 e5                	mov    %esp,%ebp
  800c85:	57                   	push   %edi
  800c86:	56                   	push   %esi
  800c87:	53                   	push   %ebx
  800c88:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c90:	b8 09 00 00 00       	mov    $0x9,%eax
  800c95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c98:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9b:	89 df                	mov    %ebx,%edi
  800c9d:	89 de                	mov    %ebx,%esi
  800c9f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ca1:	85 c0                	test   %eax,%eax
  800ca3:	7e 17                	jle    800cbc <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca5:	83 ec 0c             	sub    $0xc,%esp
  800ca8:	50                   	push   %eax
  800ca9:	6a 09                	push   $0x9
  800cab:	68 1f 25 80 00       	push   $0x80251f
  800cb0:	6a 23                	push   $0x23
  800cb2:	68 3c 25 80 00       	push   $0x80253c
  800cb7:	e8 60 11 00 00       	call   801e1c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbf:	5b                   	pop    %ebx
  800cc0:	5e                   	pop    %esi
  800cc1:	5f                   	pop    %edi
  800cc2:	5d                   	pop    %ebp
  800cc3:	c3                   	ret    

00800cc4 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cc4:	55                   	push   %ebp
  800cc5:	89 e5                	mov    %esp,%ebp
  800cc7:	57                   	push   %edi
  800cc8:	56                   	push   %esi
  800cc9:	53                   	push   %ebx
  800cca:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd2:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cda:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdd:	89 df                	mov    %ebx,%edi
  800cdf:	89 de                	mov    %ebx,%esi
  800ce1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ce3:	85 c0                	test   %eax,%eax
  800ce5:	7e 17                	jle    800cfe <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce7:	83 ec 0c             	sub    $0xc,%esp
  800cea:	50                   	push   %eax
  800ceb:	6a 0a                	push   $0xa
  800ced:	68 1f 25 80 00       	push   $0x80251f
  800cf2:	6a 23                	push   $0x23
  800cf4:	68 3c 25 80 00       	push   $0x80253c
  800cf9:	e8 1e 11 00 00       	call   801e1c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d01:	5b                   	pop    %ebx
  800d02:	5e                   	pop    %esi
  800d03:	5f                   	pop    %edi
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    

00800d06 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
  800d09:	57                   	push   %edi
  800d0a:	56                   	push   %esi
  800d0b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0c:	be 00 00 00 00       	mov    $0x0,%esi
  800d11:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d19:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d1f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d22:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d24:	5b                   	pop    %ebx
  800d25:	5e                   	pop    %esi
  800d26:	5f                   	pop    %edi
  800d27:	5d                   	pop    %ebp
  800d28:	c3                   	ret    

00800d29 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d29:	55                   	push   %ebp
  800d2a:	89 e5                	mov    %esp,%ebp
  800d2c:	57                   	push   %edi
  800d2d:	56                   	push   %esi
  800d2e:	53                   	push   %ebx
  800d2f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d32:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d37:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3f:	89 cb                	mov    %ecx,%ebx
  800d41:	89 cf                	mov    %ecx,%edi
  800d43:	89 ce                	mov    %ecx,%esi
  800d45:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d47:	85 c0                	test   %eax,%eax
  800d49:	7e 17                	jle    800d62 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4b:	83 ec 0c             	sub    $0xc,%esp
  800d4e:	50                   	push   %eax
  800d4f:	6a 0d                	push   $0xd
  800d51:	68 1f 25 80 00       	push   $0x80251f
  800d56:	6a 23                	push   $0x23
  800d58:	68 3c 25 80 00       	push   $0x80253c
  800d5d:	e8 ba 10 00 00       	call   801e1c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d62:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d65:	5b                   	pop    %ebx
  800d66:	5e                   	pop    %esi
  800d67:	5f                   	pop    %edi
  800d68:	5d                   	pop    %ebp
  800d69:	c3                   	ret    

00800d6a <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800d6a:	55                   	push   %ebp
  800d6b:	89 e5                	mov    %esp,%ebp
  800d6d:	53                   	push   %ebx
  800d6e:	83 ec 04             	sub    $0x4,%esp
	int r;
	void * address = (void *)(pn*PGSIZE);
  800d71:	89 d3                	mov    %edx,%ebx
  800d73:	c1 e3 0c             	shl    $0xc,%ebx
	
	if((uvpt[pn] & PTE_SHARE))
  800d76:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800d7d:	f6 c5 04             	test   $0x4,%ch
  800d80:	74 38                	je     800dba <duppage+0x50>
	{
		if ((r = sys_page_map(0, address, envid, address, (uvpt[pn] | PTE_SYSCALL))) < 0)
  800d82:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d89:	83 ec 0c             	sub    $0xc,%esp
  800d8c:	81 ca 07 0e 00 00    	or     $0xe07,%edx
  800d92:	52                   	push   %edx
  800d93:	53                   	push   %ebx
  800d94:	50                   	push   %eax
  800d95:	53                   	push   %ebx
  800d96:	6a 00                	push   $0x0
  800d98:	e8 1f fe ff ff       	call   800bbc <sys_page_map>
  800d9d:	83 c4 20             	add    $0x20,%esp
  800da0:	85 c0                	test   %eax,%eax
  800da2:	0f 89 b8 00 00 00    	jns    800e60 <duppage+0xf6>
			panic("sys_page_map: %e", r);
  800da8:	50                   	push   %eax
  800da9:	68 4a 25 80 00       	push   $0x80254a
  800dae:	6a 4e                	push   $0x4e
  800db0:	68 5b 25 80 00       	push   $0x80255b
  800db5:	e8 62 10 00 00       	call   801e1c <_panic>
	}
	else if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW))
  800dba:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800dc1:	f6 c1 02             	test   $0x2,%cl
  800dc4:	75 0c                	jne    800dd2 <duppage+0x68>
  800dc6:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800dcd:	f6 c5 08             	test   $0x8,%ch
  800dd0:	74 57                	je     800e29 <duppage+0xbf>
	{
		int perm = 0;
		perm |= PTE_P|PTE_U|PTE_COW;
	
		if ((r = sys_page_map(0, address, envid, address, perm)) < 0)
  800dd2:	83 ec 0c             	sub    $0xc,%esp
  800dd5:	68 05 08 00 00       	push   $0x805
  800dda:	53                   	push   %ebx
  800ddb:	50                   	push   %eax
  800ddc:	53                   	push   %ebx
  800ddd:	6a 00                	push   $0x0
  800ddf:	e8 d8 fd ff ff       	call   800bbc <sys_page_map>
  800de4:	83 c4 20             	add    $0x20,%esp
  800de7:	85 c0                	test   %eax,%eax
  800de9:	79 12                	jns    800dfd <duppage+0x93>
			panic("sys_page_map: %e", r);
  800deb:	50                   	push   %eax
  800dec:	68 4a 25 80 00       	push   $0x80254a
  800df1:	6a 56                	push   $0x56
  800df3:	68 5b 25 80 00       	push   $0x80255b
  800df8:	e8 1f 10 00 00       	call   801e1c <_panic>
		if ((r = sys_page_map(0, address, 0, address, perm)) < 0)
  800dfd:	83 ec 0c             	sub    $0xc,%esp
  800e00:	68 05 08 00 00       	push   $0x805
  800e05:	53                   	push   %ebx
  800e06:	6a 00                	push   $0x0
  800e08:	53                   	push   %ebx
  800e09:	6a 00                	push   $0x0
  800e0b:	e8 ac fd ff ff       	call   800bbc <sys_page_map>
  800e10:	83 c4 20             	add    $0x20,%esp
  800e13:	85 c0                	test   %eax,%eax
  800e15:	79 49                	jns    800e60 <duppage+0xf6>
			panic("sys_page_map: %e", r);
  800e17:	50                   	push   %eax
  800e18:	68 4a 25 80 00       	push   $0x80254a
  800e1d:	6a 58                	push   $0x58
  800e1f:	68 5b 25 80 00       	push   $0x80255b
  800e24:	e8 f3 0f 00 00       	call   801e1c <_panic>
	}
	else if((uvpt[pn] & ~PTE_U) == 0)
  800e29:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e30:	f7 c2 fb ff ff ff    	test   $0xfffffffb,%edx
  800e36:	75 28                	jne    800e60 <duppage+0xf6>
	{
		//cprintf("im here");
		if ((r = sys_page_map(0, address, envid, address, PTE_P|PTE_U)) < 0)
  800e38:	83 ec 0c             	sub    $0xc,%esp
  800e3b:	6a 05                	push   $0x5
  800e3d:	53                   	push   %ebx
  800e3e:	50                   	push   %eax
  800e3f:	53                   	push   %ebx
  800e40:	6a 00                	push   $0x0
  800e42:	e8 75 fd ff ff       	call   800bbc <sys_page_map>
  800e47:	83 c4 20             	add    $0x20,%esp
  800e4a:	85 c0                	test   %eax,%eax
  800e4c:	79 12                	jns    800e60 <duppage+0xf6>
			panic("sys_page_map: %e", r);	
  800e4e:	50                   	push   %eax
  800e4f:	68 4a 25 80 00       	push   $0x80254a
  800e54:	6a 5e                	push   $0x5e
  800e56:	68 5b 25 80 00       	push   $0x80255b
  800e5b:	e8 bc 0f 00 00       	call   801e1c <_panic>
	}
	return 0;
}
  800e60:	b8 00 00 00 00       	mov    $0x0,%eax
  800e65:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e68:	c9                   	leave  
  800e69:	c3                   	ret    

00800e6a <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e6a:	55                   	push   %ebp
  800e6b:	89 e5                	mov    %esp,%ebp
  800e6d:	53                   	push   %ebx
  800e6e:	83 ec 08             	sub    $0x8,%esp
	void *addr = (void *) utf->utf_fault_va;
  800e71:	8b 45 08             	mov    0x8(%ebp),%eax
  800e74:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	unsigned pn = ((uint32_t)addr)/PGSIZE;
  800e76:	89 d8                	mov    %ebx,%eax
  800e78:	c1 e8 0c             	shr    $0xc,%eax
	pte_t pte = uvpt[pn];
  800e7b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// Allocate a new page, mapped at temp location
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  800e82:	6a 07                	push   $0x7
  800e84:	68 00 f0 7f 00       	push   $0x7ff000
  800e89:	6a 00                	push   $0x0
  800e8b:	e8 e9 fc ff ff       	call   800b79 <sys_page_alloc>
  800e90:	83 c4 10             	add    $0x10,%esp
  800e93:	85 c0                	test   %eax,%eax
  800e95:	79 12                	jns    800ea9 <pgfault+0x3f>
		panic("sys_page_alloc: %e", r);
  800e97:	50                   	push   %eax
  800e98:	68 66 25 80 00       	push   $0x802566
  800e9d:	6a 2b                	push   $0x2b
  800e9f:	68 5b 25 80 00       	push   $0x80255b
  800ea4:	e8 73 0f 00 00       	call   801e1c <_panic>

	// Copy the data from the old page to this new page
	void *addr_pgstart = (void *) ROUNDDOWN(addr, PGSIZE);
  800ea9:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr_pgstart, PGSIZE);
  800eaf:	83 ec 04             	sub    $0x4,%esp
  800eb2:	68 00 10 00 00       	push   $0x1000
  800eb7:	53                   	push   %ebx
  800eb8:	68 00 f0 7f 00       	push   $0x7ff000
  800ebd:	e8 46 fa ff ff       	call   800908 <memmove>

	// Move the new page to the old page's address
	if ((r = sys_page_map(0, PFTEMP, 0, addr_pgstart, PTE_P|PTE_U|PTE_W)) < 0)
  800ec2:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800ec9:	53                   	push   %ebx
  800eca:	6a 00                	push   $0x0
  800ecc:	68 00 f0 7f 00       	push   $0x7ff000
  800ed1:	6a 00                	push   $0x0
  800ed3:	e8 e4 fc ff ff       	call   800bbc <sys_page_map>
  800ed8:	83 c4 20             	add    $0x20,%esp
  800edb:	85 c0                	test   %eax,%eax
  800edd:	79 12                	jns    800ef1 <pgfault+0x87>
		panic("sys_page_map: %e", r);
  800edf:	50                   	push   %eax
  800ee0:	68 4a 25 80 00       	push   $0x80254a
  800ee5:	6a 33                	push   $0x33
  800ee7:	68 5b 25 80 00       	push   $0x80255b
  800eec:	e8 2b 0f 00 00       	call   801e1c <_panic>

	// Unmap the temp location
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800ef1:	83 ec 08             	sub    $0x8,%esp
  800ef4:	68 00 f0 7f 00       	push   $0x7ff000
  800ef9:	6a 00                	push   $0x0
  800efb:	e8 fe fc ff ff       	call   800bfe <sys_page_unmap>
  800f00:	83 c4 10             	add    $0x10,%esp
  800f03:	85 c0                	test   %eax,%eax
  800f05:	79 12                	jns    800f19 <pgfault+0xaf>
		panic("sys_page_unmap: %e", r);
  800f07:	50                   	push   %eax
  800f08:	68 79 25 80 00       	push   $0x802579
  800f0d:	6a 37                	push   $0x37
  800f0f:	68 5b 25 80 00       	push   $0x80255b
  800f14:	e8 03 0f 00 00       	call   801e1c <_panic>
}
  800f19:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f1c:	c9                   	leave  
  800f1d:	c3                   	ret    

00800f1e <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f1e:	55                   	push   %ebp
  800f1f:	89 e5                	mov    %esp,%ebp
  800f21:	56                   	push   %esi
  800f22:	53                   	push   %ebx
  800f23:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
	// Set up page fault handler
	set_pgfault_handler(&pgfault);
  800f26:	68 6a 0e 80 00       	push   $0x800e6a
  800f2b:	e8 32 0f 00 00       	call   801e62 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f30:	b8 07 00 00 00       	mov    $0x7,%eax
  800f35:	cd 30                	int    $0x30

	// Create child
	envid_t envid = sys_exofork();
  800f37:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (envid < 0) {
  800f3a:	83 c4 10             	add    $0x10,%esp
  800f3d:	85 c0                	test   %eax,%eax
  800f3f:	79 12                	jns    800f53 <fork+0x35>
		panic("sys_exofork: %e", envid);
  800f41:	50                   	push   %eax
  800f42:	68 8c 25 80 00       	push   $0x80258c
  800f47:	6a 7c                	push   $0x7c
  800f49:	68 5b 25 80 00       	push   $0x80255b
  800f4e:	e8 c9 0e 00 00       	call   801e1c <_panic>
		return envid;
	}
	if (envid == 0) {
  800f53:	85 c0                	test   %eax,%eax
  800f55:	75 1e                	jne    800f75 <fork+0x57>
		// We are the child.
		thisenv = &envs[ENVX(sys_getenvid())]; // Fix thisenv
  800f57:	e8 df fb ff ff       	call   800b3b <sys_getenvid>
  800f5c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f61:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f64:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f69:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  800f6e:	b8 00 00 00 00       	mov    $0x0,%eax
  800f73:	eb 7d                	jmp    800ff2 <fork+0xd4>

	// Set page fault handler on the child.
	// The parent needs to do it, else the child wouldn't be able to handle
	// the fault when trying to access it's stack (which happens as soon it starts)
	extern void _pgfault_upcall(void);
	sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);
  800f75:	83 ec 04             	sub    $0x4,%esp
  800f78:	6a 07                	push   $0x7
  800f7a:	68 00 f0 bf ee       	push   $0xeebff000
  800f7f:	50                   	push   %eax
  800f80:	e8 f4 fb ff ff       	call   800b79 <sys_page_alloc>
	sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  800f85:	83 c4 08             	add    $0x8,%esp
  800f88:	68 a7 1e 80 00       	push   $0x801ea7
  800f8d:	ff 75 f4             	pushl  -0xc(%ebp)
  800f90:	e8 2f fd ff ff       	call   800cc4 <sys_env_set_pgfault_upcall>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  800f95:	be 04 60 80 00       	mov    $0x806004,%esi
  800f9a:	c1 ee 0c             	shr    $0xc,%esi
  800f9d:	83 c4 10             	add    $0x10,%esp
  800fa0:	bb 00 08 00 00       	mov    $0x800,%ebx
  800fa5:	eb 0d                	jmp    800fb4 <fork+0x96>
		duppage(envid, pn);
  800fa7:	89 da                	mov    %ebx,%edx
  800fa9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fac:	e8 b9 fd ff ff       	call   800d6a <duppage>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  800fb1:	83 c3 01             	add    $0x1,%ebx
  800fb4:	39 f3                	cmp    %esi,%ebx
  800fb6:	76 ef                	jbe    800fa7 <fork+0x89>
	}

	// Also copy the stack we are currently running on
	// I think it should loop from ustacktop to this page, since the stack
	// can have more than 1 page
	duppage(envid, ((uint32_t) &envid)/PGSIZE);
  800fb8:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800fbb:	c1 ea 0c             	shr    $0xc,%edx
  800fbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fc1:	e8 a4 fd ff ff       	call   800d6a <duppage>

	// Start the child environmnet running
	int r;
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  800fc6:	83 ec 08             	sub    $0x8,%esp
  800fc9:	6a 02                	push   $0x2
  800fcb:	ff 75 f4             	pushl  -0xc(%ebp)
  800fce:	e8 6d fc ff ff       	call   800c40 <sys_env_set_status>
  800fd3:	83 c4 10             	add    $0x10,%esp
  800fd6:	85 c0                	test   %eax,%eax
  800fd8:	79 15                	jns    800fef <fork+0xd1>
		panic("sys_env_set_status: %e", r);
  800fda:	50                   	push   %eax
  800fdb:	68 9c 25 80 00       	push   $0x80259c
  800fe0:	68 9c 00 00 00       	push   $0x9c
  800fe5:	68 5b 25 80 00       	push   $0x80255b
  800fea:	e8 2d 0e 00 00       	call   801e1c <_panic>
		return r;
	}

	return envid;
  800fef:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800ff2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ff5:	5b                   	pop    %ebx
  800ff6:	5e                   	pop    %esi
  800ff7:	5d                   	pop    %ebp
  800ff8:	c3                   	ret    

00800ff9 <sfork>:

// Challenge!
int
sfork(void)
{
  800ff9:	55                   	push   %ebp
  800ffa:	89 e5                	mov    %esp,%ebp
  800ffc:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800fff:	68 b3 25 80 00       	push   $0x8025b3
  801004:	68 a7 00 00 00       	push   $0xa7
  801009:	68 5b 25 80 00       	push   $0x80255b
  80100e:	e8 09 0e 00 00       	call   801e1c <_panic>

00801013 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801013:	55                   	push   %ebp
  801014:	89 e5                	mov    %esp,%ebp
  801016:	56                   	push   %esi
  801017:	53                   	push   %ebx
  801018:	8b 75 08             	mov    0x8(%ebp),%esi
  80101b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80101e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  801021:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801023:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801028:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  80102b:	83 ec 0c             	sub    $0xc,%esp
  80102e:	50                   	push   %eax
  80102f:	e8 f5 fc ff ff       	call   800d29 <sys_ipc_recv>

	if (r < 0) {
  801034:	83 c4 10             	add    $0x10,%esp
  801037:	85 c0                	test   %eax,%eax
  801039:	79 16                	jns    801051 <ipc_recv+0x3e>
		if (from_env_store)
  80103b:	85 f6                	test   %esi,%esi
  80103d:	74 06                	je     801045 <ipc_recv+0x32>
			*from_env_store = 0;
  80103f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  801045:	85 db                	test   %ebx,%ebx
  801047:	74 2c                	je     801075 <ipc_recv+0x62>
			*perm_store = 0;
  801049:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80104f:	eb 24                	jmp    801075 <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  801051:	85 f6                	test   %esi,%esi
  801053:	74 0a                	je     80105f <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  801055:	a1 08 40 80 00       	mov    0x804008,%eax
  80105a:	8b 40 74             	mov    0x74(%eax),%eax
  80105d:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  80105f:	85 db                	test   %ebx,%ebx
  801061:	74 0a                	je     80106d <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  801063:	a1 08 40 80 00       	mov    0x804008,%eax
  801068:	8b 40 78             	mov    0x78(%eax),%eax
  80106b:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  80106d:	a1 08 40 80 00       	mov    0x804008,%eax
  801072:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  801075:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801078:	5b                   	pop    %ebx
  801079:	5e                   	pop    %esi
  80107a:	5d                   	pop    %ebp
  80107b:	c3                   	ret    

0080107c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80107c:	55                   	push   %ebp
  80107d:	89 e5                	mov    %esp,%ebp
  80107f:	57                   	push   %edi
  801080:	56                   	push   %esi
  801081:	53                   	push   %ebx
  801082:	83 ec 0c             	sub    $0xc,%esp
  801085:	8b 7d 08             	mov    0x8(%ebp),%edi
  801088:	8b 75 0c             	mov    0xc(%ebp),%esi
  80108b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  80108e:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801090:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801095:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  801098:	ff 75 14             	pushl  0x14(%ebp)
  80109b:	53                   	push   %ebx
  80109c:	56                   	push   %esi
  80109d:	57                   	push   %edi
  80109e:	e8 63 fc ff ff       	call   800d06 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  8010a3:	83 c4 10             	add    $0x10,%esp
  8010a6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8010a9:	75 07                	jne    8010b2 <ipc_send+0x36>
			sys_yield();
  8010ab:	e8 aa fa ff ff       	call   800b5a <sys_yield>
  8010b0:	eb e6                	jmp    801098 <ipc_send+0x1c>
		} else if (r < 0) {
  8010b2:	85 c0                	test   %eax,%eax
  8010b4:	79 12                	jns    8010c8 <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  8010b6:	50                   	push   %eax
  8010b7:	68 c9 25 80 00       	push   $0x8025c9
  8010bc:	6a 51                	push   $0x51
  8010be:	68 d6 25 80 00       	push   $0x8025d6
  8010c3:	e8 54 0d 00 00       	call   801e1c <_panic>
		}
	}
}
  8010c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010cb:	5b                   	pop    %ebx
  8010cc:	5e                   	pop    %esi
  8010cd:	5f                   	pop    %edi
  8010ce:	5d                   	pop    %ebp
  8010cf:	c3                   	ret    

008010d0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8010d0:	55                   	push   %ebp
  8010d1:	89 e5                	mov    %esp,%ebp
  8010d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8010d6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8010db:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8010de:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8010e4:	8b 52 50             	mov    0x50(%edx),%edx
  8010e7:	39 ca                	cmp    %ecx,%edx
  8010e9:	75 0d                	jne    8010f8 <ipc_find_env+0x28>
			return envs[i].env_id;
  8010eb:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8010ee:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010f3:	8b 40 48             	mov    0x48(%eax),%eax
  8010f6:	eb 0f                	jmp    801107 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8010f8:	83 c0 01             	add    $0x1,%eax
  8010fb:	3d 00 04 00 00       	cmp    $0x400,%eax
  801100:	75 d9                	jne    8010db <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801102:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801107:	5d                   	pop    %ebp
  801108:	c3                   	ret    

00801109 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801109:	55                   	push   %ebp
  80110a:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80110c:	8b 45 08             	mov    0x8(%ebp),%eax
  80110f:	05 00 00 00 30       	add    $0x30000000,%eax
  801114:	c1 e8 0c             	shr    $0xc,%eax
}
  801117:	5d                   	pop    %ebp
  801118:	c3                   	ret    

00801119 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801119:	55                   	push   %ebp
  80111a:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80111c:	8b 45 08             	mov    0x8(%ebp),%eax
  80111f:	05 00 00 00 30       	add    $0x30000000,%eax
  801124:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801129:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80112e:	5d                   	pop    %ebp
  80112f:	c3                   	ret    

00801130 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801130:	55                   	push   %ebp
  801131:	89 e5                	mov    %esp,%ebp
  801133:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801136:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80113b:	89 c2                	mov    %eax,%edx
  80113d:	c1 ea 16             	shr    $0x16,%edx
  801140:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801147:	f6 c2 01             	test   $0x1,%dl
  80114a:	74 11                	je     80115d <fd_alloc+0x2d>
  80114c:	89 c2                	mov    %eax,%edx
  80114e:	c1 ea 0c             	shr    $0xc,%edx
  801151:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801158:	f6 c2 01             	test   $0x1,%dl
  80115b:	75 09                	jne    801166 <fd_alloc+0x36>
			*fd_store = fd;
  80115d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80115f:	b8 00 00 00 00       	mov    $0x0,%eax
  801164:	eb 17                	jmp    80117d <fd_alloc+0x4d>
  801166:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80116b:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801170:	75 c9                	jne    80113b <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801172:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801178:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80117d:	5d                   	pop    %ebp
  80117e:	c3                   	ret    

0080117f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80117f:	55                   	push   %ebp
  801180:	89 e5                	mov    %esp,%ebp
  801182:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801185:	83 f8 1f             	cmp    $0x1f,%eax
  801188:	77 36                	ja     8011c0 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80118a:	c1 e0 0c             	shl    $0xc,%eax
  80118d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801192:	89 c2                	mov    %eax,%edx
  801194:	c1 ea 16             	shr    $0x16,%edx
  801197:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80119e:	f6 c2 01             	test   $0x1,%dl
  8011a1:	74 24                	je     8011c7 <fd_lookup+0x48>
  8011a3:	89 c2                	mov    %eax,%edx
  8011a5:	c1 ea 0c             	shr    $0xc,%edx
  8011a8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011af:	f6 c2 01             	test   $0x1,%dl
  8011b2:	74 1a                	je     8011ce <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011b7:	89 02                	mov    %eax,(%edx)
	return 0;
  8011b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8011be:	eb 13                	jmp    8011d3 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011c0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011c5:	eb 0c                	jmp    8011d3 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011cc:	eb 05                	jmp    8011d3 <fd_lookup+0x54>
  8011ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8011d3:	5d                   	pop    %ebp
  8011d4:	c3                   	ret    

008011d5 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011d5:	55                   	push   %ebp
  8011d6:	89 e5                	mov    %esp,%ebp
  8011d8:	83 ec 08             	sub    $0x8,%esp
  8011db:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011de:	ba 5c 26 80 00       	mov    $0x80265c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8011e3:	eb 13                	jmp    8011f8 <dev_lookup+0x23>
  8011e5:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8011e8:	39 08                	cmp    %ecx,(%eax)
  8011ea:	75 0c                	jne    8011f8 <dev_lookup+0x23>
			*dev = devtab[i];
  8011ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011ef:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8011f6:	eb 2e                	jmp    801226 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011f8:	8b 02                	mov    (%edx),%eax
  8011fa:	85 c0                	test   %eax,%eax
  8011fc:	75 e7                	jne    8011e5 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011fe:	a1 08 40 80 00       	mov    0x804008,%eax
  801203:	8b 40 48             	mov    0x48(%eax),%eax
  801206:	83 ec 04             	sub    $0x4,%esp
  801209:	51                   	push   %ecx
  80120a:	50                   	push   %eax
  80120b:	68 e0 25 80 00       	push   $0x8025e0
  801210:	e8 dc ef ff ff       	call   8001f1 <cprintf>
	*dev = 0;
  801215:	8b 45 0c             	mov    0xc(%ebp),%eax
  801218:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80121e:	83 c4 10             	add    $0x10,%esp
  801221:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801226:	c9                   	leave  
  801227:	c3                   	ret    

00801228 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801228:	55                   	push   %ebp
  801229:	89 e5                	mov    %esp,%ebp
  80122b:	56                   	push   %esi
  80122c:	53                   	push   %ebx
  80122d:	83 ec 10             	sub    $0x10,%esp
  801230:	8b 75 08             	mov    0x8(%ebp),%esi
  801233:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801236:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801239:	50                   	push   %eax
  80123a:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801240:	c1 e8 0c             	shr    $0xc,%eax
  801243:	50                   	push   %eax
  801244:	e8 36 ff ff ff       	call   80117f <fd_lookup>
  801249:	83 c4 08             	add    $0x8,%esp
  80124c:	85 c0                	test   %eax,%eax
  80124e:	78 05                	js     801255 <fd_close+0x2d>
	    || fd != fd2)
  801250:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801253:	74 0c                	je     801261 <fd_close+0x39>
		return (must_exist ? r : 0);
  801255:	84 db                	test   %bl,%bl
  801257:	ba 00 00 00 00       	mov    $0x0,%edx
  80125c:	0f 44 c2             	cmove  %edx,%eax
  80125f:	eb 41                	jmp    8012a2 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801261:	83 ec 08             	sub    $0x8,%esp
  801264:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801267:	50                   	push   %eax
  801268:	ff 36                	pushl  (%esi)
  80126a:	e8 66 ff ff ff       	call   8011d5 <dev_lookup>
  80126f:	89 c3                	mov    %eax,%ebx
  801271:	83 c4 10             	add    $0x10,%esp
  801274:	85 c0                	test   %eax,%eax
  801276:	78 1a                	js     801292 <fd_close+0x6a>
		if (dev->dev_close)
  801278:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80127b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80127e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801283:	85 c0                	test   %eax,%eax
  801285:	74 0b                	je     801292 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801287:	83 ec 0c             	sub    $0xc,%esp
  80128a:	56                   	push   %esi
  80128b:	ff d0                	call   *%eax
  80128d:	89 c3                	mov    %eax,%ebx
  80128f:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801292:	83 ec 08             	sub    $0x8,%esp
  801295:	56                   	push   %esi
  801296:	6a 00                	push   $0x0
  801298:	e8 61 f9 ff ff       	call   800bfe <sys_page_unmap>
	return r;
  80129d:	83 c4 10             	add    $0x10,%esp
  8012a0:	89 d8                	mov    %ebx,%eax
}
  8012a2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012a5:	5b                   	pop    %ebx
  8012a6:	5e                   	pop    %esi
  8012a7:	5d                   	pop    %ebp
  8012a8:	c3                   	ret    

008012a9 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012a9:	55                   	push   %ebp
  8012aa:	89 e5                	mov    %esp,%ebp
  8012ac:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012af:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012b2:	50                   	push   %eax
  8012b3:	ff 75 08             	pushl  0x8(%ebp)
  8012b6:	e8 c4 fe ff ff       	call   80117f <fd_lookup>
  8012bb:	83 c4 08             	add    $0x8,%esp
  8012be:	85 c0                	test   %eax,%eax
  8012c0:	78 10                	js     8012d2 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8012c2:	83 ec 08             	sub    $0x8,%esp
  8012c5:	6a 01                	push   $0x1
  8012c7:	ff 75 f4             	pushl  -0xc(%ebp)
  8012ca:	e8 59 ff ff ff       	call   801228 <fd_close>
  8012cf:	83 c4 10             	add    $0x10,%esp
}
  8012d2:	c9                   	leave  
  8012d3:	c3                   	ret    

008012d4 <close_all>:

void
close_all(void)
{
  8012d4:	55                   	push   %ebp
  8012d5:	89 e5                	mov    %esp,%ebp
  8012d7:	53                   	push   %ebx
  8012d8:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012db:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012e0:	83 ec 0c             	sub    $0xc,%esp
  8012e3:	53                   	push   %ebx
  8012e4:	e8 c0 ff ff ff       	call   8012a9 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8012e9:	83 c3 01             	add    $0x1,%ebx
  8012ec:	83 c4 10             	add    $0x10,%esp
  8012ef:	83 fb 20             	cmp    $0x20,%ebx
  8012f2:	75 ec                	jne    8012e0 <close_all+0xc>
		close(i);
}
  8012f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012f7:	c9                   	leave  
  8012f8:	c3                   	ret    

008012f9 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012f9:	55                   	push   %ebp
  8012fa:	89 e5                	mov    %esp,%ebp
  8012fc:	57                   	push   %edi
  8012fd:	56                   	push   %esi
  8012fe:	53                   	push   %ebx
  8012ff:	83 ec 2c             	sub    $0x2c,%esp
  801302:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801305:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801308:	50                   	push   %eax
  801309:	ff 75 08             	pushl  0x8(%ebp)
  80130c:	e8 6e fe ff ff       	call   80117f <fd_lookup>
  801311:	83 c4 08             	add    $0x8,%esp
  801314:	85 c0                	test   %eax,%eax
  801316:	0f 88 c1 00 00 00    	js     8013dd <dup+0xe4>
		return r;
	close(newfdnum);
  80131c:	83 ec 0c             	sub    $0xc,%esp
  80131f:	56                   	push   %esi
  801320:	e8 84 ff ff ff       	call   8012a9 <close>

	newfd = INDEX2FD(newfdnum);
  801325:	89 f3                	mov    %esi,%ebx
  801327:	c1 e3 0c             	shl    $0xc,%ebx
  80132a:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801330:	83 c4 04             	add    $0x4,%esp
  801333:	ff 75 e4             	pushl  -0x1c(%ebp)
  801336:	e8 de fd ff ff       	call   801119 <fd2data>
  80133b:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80133d:	89 1c 24             	mov    %ebx,(%esp)
  801340:	e8 d4 fd ff ff       	call   801119 <fd2data>
  801345:	83 c4 10             	add    $0x10,%esp
  801348:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80134b:	89 f8                	mov    %edi,%eax
  80134d:	c1 e8 16             	shr    $0x16,%eax
  801350:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801357:	a8 01                	test   $0x1,%al
  801359:	74 37                	je     801392 <dup+0x99>
  80135b:	89 f8                	mov    %edi,%eax
  80135d:	c1 e8 0c             	shr    $0xc,%eax
  801360:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801367:	f6 c2 01             	test   $0x1,%dl
  80136a:	74 26                	je     801392 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80136c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801373:	83 ec 0c             	sub    $0xc,%esp
  801376:	25 07 0e 00 00       	and    $0xe07,%eax
  80137b:	50                   	push   %eax
  80137c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80137f:	6a 00                	push   $0x0
  801381:	57                   	push   %edi
  801382:	6a 00                	push   $0x0
  801384:	e8 33 f8 ff ff       	call   800bbc <sys_page_map>
  801389:	89 c7                	mov    %eax,%edi
  80138b:	83 c4 20             	add    $0x20,%esp
  80138e:	85 c0                	test   %eax,%eax
  801390:	78 2e                	js     8013c0 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801392:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801395:	89 d0                	mov    %edx,%eax
  801397:	c1 e8 0c             	shr    $0xc,%eax
  80139a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013a1:	83 ec 0c             	sub    $0xc,%esp
  8013a4:	25 07 0e 00 00       	and    $0xe07,%eax
  8013a9:	50                   	push   %eax
  8013aa:	53                   	push   %ebx
  8013ab:	6a 00                	push   $0x0
  8013ad:	52                   	push   %edx
  8013ae:	6a 00                	push   $0x0
  8013b0:	e8 07 f8 ff ff       	call   800bbc <sys_page_map>
  8013b5:	89 c7                	mov    %eax,%edi
  8013b7:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8013ba:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013bc:	85 ff                	test   %edi,%edi
  8013be:	79 1d                	jns    8013dd <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013c0:	83 ec 08             	sub    $0x8,%esp
  8013c3:	53                   	push   %ebx
  8013c4:	6a 00                	push   $0x0
  8013c6:	e8 33 f8 ff ff       	call   800bfe <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013cb:	83 c4 08             	add    $0x8,%esp
  8013ce:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013d1:	6a 00                	push   $0x0
  8013d3:	e8 26 f8 ff ff       	call   800bfe <sys_page_unmap>
	return r;
  8013d8:	83 c4 10             	add    $0x10,%esp
  8013db:	89 f8                	mov    %edi,%eax
}
  8013dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013e0:	5b                   	pop    %ebx
  8013e1:	5e                   	pop    %esi
  8013e2:	5f                   	pop    %edi
  8013e3:	5d                   	pop    %ebp
  8013e4:	c3                   	ret    

008013e5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013e5:	55                   	push   %ebp
  8013e6:	89 e5                	mov    %esp,%ebp
  8013e8:	53                   	push   %ebx
  8013e9:	83 ec 14             	sub    $0x14,%esp
  8013ec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013ef:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013f2:	50                   	push   %eax
  8013f3:	53                   	push   %ebx
  8013f4:	e8 86 fd ff ff       	call   80117f <fd_lookup>
  8013f9:	83 c4 08             	add    $0x8,%esp
  8013fc:	89 c2                	mov    %eax,%edx
  8013fe:	85 c0                	test   %eax,%eax
  801400:	78 6d                	js     80146f <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801402:	83 ec 08             	sub    $0x8,%esp
  801405:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801408:	50                   	push   %eax
  801409:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80140c:	ff 30                	pushl  (%eax)
  80140e:	e8 c2 fd ff ff       	call   8011d5 <dev_lookup>
  801413:	83 c4 10             	add    $0x10,%esp
  801416:	85 c0                	test   %eax,%eax
  801418:	78 4c                	js     801466 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80141a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80141d:	8b 42 08             	mov    0x8(%edx),%eax
  801420:	83 e0 03             	and    $0x3,%eax
  801423:	83 f8 01             	cmp    $0x1,%eax
  801426:	75 21                	jne    801449 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801428:	a1 08 40 80 00       	mov    0x804008,%eax
  80142d:	8b 40 48             	mov    0x48(%eax),%eax
  801430:	83 ec 04             	sub    $0x4,%esp
  801433:	53                   	push   %ebx
  801434:	50                   	push   %eax
  801435:	68 21 26 80 00       	push   $0x802621
  80143a:	e8 b2 ed ff ff       	call   8001f1 <cprintf>
		return -E_INVAL;
  80143f:	83 c4 10             	add    $0x10,%esp
  801442:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801447:	eb 26                	jmp    80146f <read+0x8a>
	}
	if (!dev->dev_read)
  801449:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80144c:	8b 40 08             	mov    0x8(%eax),%eax
  80144f:	85 c0                	test   %eax,%eax
  801451:	74 17                	je     80146a <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801453:	83 ec 04             	sub    $0x4,%esp
  801456:	ff 75 10             	pushl  0x10(%ebp)
  801459:	ff 75 0c             	pushl  0xc(%ebp)
  80145c:	52                   	push   %edx
  80145d:	ff d0                	call   *%eax
  80145f:	89 c2                	mov    %eax,%edx
  801461:	83 c4 10             	add    $0x10,%esp
  801464:	eb 09                	jmp    80146f <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801466:	89 c2                	mov    %eax,%edx
  801468:	eb 05                	jmp    80146f <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80146a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80146f:	89 d0                	mov    %edx,%eax
  801471:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801474:	c9                   	leave  
  801475:	c3                   	ret    

00801476 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801476:	55                   	push   %ebp
  801477:	89 e5                	mov    %esp,%ebp
  801479:	57                   	push   %edi
  80147a:	56                   	push   %esi
  80147b:	53                   	push   %ebx
  80147c:	83 ec 0c             	sub    $0xc,%esp
  80147f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801482:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801485:	bb 00 00 00 00       	mov    $0x0,%ebx
  80148a:	eb 21                	jmp    8014ad <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80148c:	83 ec 04             	sub    $0x4,%esp
  80148f:	89 f0                	mov    %esi,%eax
  801491:	29 d8                	sub    %ebx,%eax
  801493:	50                   	push   %eax
  801494:	89 d8                	mov    %ebx,%eax
  801496:	03 45 0c             	add    0xc(%ebp),%eax
  801499:	50                   	push   %eax
  80149a:	57                   	push   %edi
  80149b:	e8 45 ff ff ff       	call   8013e5 <read>
		if (m < 0)
  8014a0:	83 c4 10             	add    $0x10,%esp
  8014a3:	85 c0                	test   %eax,%eax
  8014a5:	78 10                	js     8014b7 <readn+0x41>
			return m;
		if (m == 0)
  8014a7:	85 c0                	test   %eax,%eax
  8014a9:	74 0a                	je     8014b5 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014ab:	01 c3                	add    %eax,%ebx
  8014ad:	39 f3                	cmp    %esi,%ebx
  8014af:	72 db                	jb     80148c <readn+0x16>
  8014b1:	89 d8                	mov    %ebx,%eax
  8014b3:	eb 02                	jmp    8014b7 <readn+0x41>
  8014b5:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8014b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014ba:	5b                   	pop    %ebx
  8014bb:	5e                   	pop    %esi
  8014bc:	5f                   	pop    %edi
  8014bd:	5d                   	pop    %ebp
  8014be:	c3                   	ret    

008014bf <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014bf:	55                   	push   %ebp
  8014c0:	89 e5                	mov    %esp,%ebp
  8014c2:	53                   	push   %ebx
  8014c3:	83 ec 14             	sub    $0x14,%esp
  8014c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014c9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014cc:	50                   	push   %eax
  8014cd:	53                   	push   %ebx
  8014ce:	e8 ac fc ff ff       	call   80117f <fd_lookup>
  8014d3:	83 c4 08             	add    $0x8,%esp
  8014d6:	89 c2                	mov    %eax,%edx
  8014d8:	85 c0                	test   %eax,%eax
  8014da:	78 68                	js     801544 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014dc:	83 ec 08             	sub    $0x8,%esp
  8014df:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014e2:	50                   	push   %eax
  8014e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014e6:	ff 30                	pushl  (%eax)
  8014e8:	e8 e8 fc ff ff       	call   8011d5 <dev_lookup>
  8014ed:	83 c4 10             	add    $0x10,%esp
  8014f0:	85 c0                	test   %eax,%eax
  8014f2:	78 47                	js     80153b <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014f7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014fb:	75 21                	jne    80151e <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014fd:	a1 08 40 80 00       	mov    0x804008,%eax
  801502:	8b 40 48             	mov    0x48(%eax),%eax
  801505:	83 ec 04             	sub    $0x4,%esp
  801508:	53                   	push   %ebx
  801509:	50                   	push   %eax
  80150a:	68 3d 26 80 00       	push   $0x80263d
  80150f:	e8 dd ec ff ff       	call   8001f1 <cprintf>
		return -E_INVAL;
  801514:	83 c4 10             	add    $0x10,%esp
  801517:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80151c:	eb 26                	jmp    801544 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80151e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801521:	8b 52 0c             	mov    0xc(%edx),%edx
  801524:	85 d2                	test   %edx,%edx
  801526:	74 17                	je     80153f <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801528:	83 ec 04             	sub    $0x4,%esp
  80152b:	ff 75 10             	pushl  0x10(%ebp)
  80152e:	ff 75 0c             	pushl  0xc(%ebp)
  801531:	50                   	push   %eax
  801532:	ff d2                	call   *%edx
  801534:	89 c2                	mov    %eax,%edx
  801536:	83 c4 10             	add    $0x10,%esp
  801539:	eb 09                	jmp    801544 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80153b:	89 c2                	mov    %eax,%edx
  80153d:	eb 05                	jmp    801544 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80153f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801544:	89 d0                	mov    %edx,%eax
  801546:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801549:	c9                   	leave  
  80154a:	c3                   	ret    

0080154b <seek>:

int
seek(int fdnum, off_t offset)
{
  80154b:	55                   	push   %ebp
  80154c:	89 e5                	mov    %esp,%ebp
  80154e:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801551:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801554:	50                   	push   %eax
  801555:	ff 75 08             	pushl  0x8(%ebp)
  801558:	e8 22 fc ff ff       	call   80117f <fd_lookup>
  80155d:	83 c4 08             	add    $0x8,%esp
  801560:	85 c0                	test   %eax,%eax
  801562:	78 0e                	js     801572 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801564:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801567:	8b 55 0c             	mov    0xc(%ebp),%edx
  80156a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80156d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801572:	c9                   	leave  
  801573:	c3                   	ret    

00801574 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801574:	55                   	push   %ebp
  801575:	89 e5                	mov    %esp,%ebp
  801577:	53                   	push   %ebx
  801578:	83 ec 14             	sub    $0x14,%esp
  80157b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80157e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801581:	50                   	push   %eax
  801582:	53                   	push   %ebx
  801583:	e8 f7 fb ff ff       	call   80117f <fd_lookup>
  801588:	83 c4 08             	add    $0x8,%esp
  80158b:	89 c2                	mov    %eax,%edx
  80158d:	85 c0                	test   %eax,%eax
  80158f:	78 65                	js     8015f6 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801591:	83 ec 08             	sub    $0x8,%esp
  801594:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801597:	50                   	push   %eax
  801598:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80159b:	ff 30                	pushl  (%eax)
  80159d:	e8 33 fc ff ff       	call   8011d5 <dev_lookup>
  8015a2:	83 c4 10             	add    $0x10,%esp
  8015a5:	85 c0                	test   %eax,%eax
  8015a7:	78 44                	js     8015ed <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ac:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015b0:	75 21                	jne    8015d3 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015b2:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015b7:	8b 40 48             	mov    0x48(%eax),%eax
  8015ba:	83 ec 04             	sub    $0x4,%esp
  8015bd:	53                   	push   %ebx
  8015be:	50                   	push   %eax
  8015bf:	68 00 26 80 00       	push   $0x802600
  8015c4:	e8 28 ec ff ff       	call   8001f1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015c9:	83 c4 10             	add    $0x10,%esp
  8015cc:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015d1:	eb 23                	jmp    8015f6 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8015d3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015d6:	8b 52 18             	mov    0x18(%edx),%edx
  8015d9:	85 d2                	test   %edx,%edx
  8015db:	74 14                	je     8015f1 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015dd:	83 ec 08             	sub    $0x8,%esp
  8015e0:	ff 75 0c             	pushl  0xc(%ebp)
  8015e3:	50                   	push   %eax
  8015e4:	ff d2                	call   *%edx
  8015e6:	89 c2                	mov    %eax,%edx
  8015e8:	83 c4 10             	add    $0x10,%esp
  8015eb:	eb 09                	jmp    8015f6 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ed:	89 c2                	mov    %eax,%edx
  8015ef:	eb 05                	jmp    8015f6 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8015f1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8015f6:	89 d0                	mov    %edx,%eax
  8015f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015fb:	c9                   	leave  
  8015fc:	c3                   	ret    

008015fd <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015fd:	55                   	push   %ebp
  8015fe:	89 e5                	mov    %esp,%ebp
  801600:	53                   	push   %ebx
  801601:	83 ec 14             	sub    $0x14,%esp
  801604:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801607:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80160a:	50                   	push   %eax
  80160b:	ff 75 08             	pushl  0x8(%ebp)
  80160e:	e8 6c fb ff ff       	call   80117f <fd_lookup>
  801613:	83 c4 08             	add    $0x8,%esp
  801616:	89 c2                	mov    %eax,%edx
  801618:	85 c0                	test   %eax,%eax
  80161a:	78 58                	js     801674 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80161c:	83 ec 08             	sub    $0x8,%esp
  80161f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801622:	50                   	push   %eax
  801623:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801626:	ff 30                	pushl  (%eax)
  801628:	e8 a8 fb ff ff       	call   8011d5 <dev_lookup>
  80162d:	83 c4 10             	add    $0x10,%esp
  801630:	85 c0                	test   %eax,%eax
  801632:	78 37                	js     80166b <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801634:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801637:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80163b:	74 32                	je     80166f <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80163d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801640:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801647:	00 00 00 
	stat->st_isdir = 0;
  80164a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801651:	00 00 00 
	stat->st_dev = dev;
  801654:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80165a:	83 ec 08             	sub    $0x8,%esp
  80165d:	53                   	push   %ebx
  80165e:	ff 75 f0             	pushl  -0x10(%ebp)
  801661:	ff 50 14             	call   *0x14(%eax)
  801664:	89 c2                	mov    %eax,%edx
  801666:	83 c4 10             	add    $0x10,%esp
  801669:	eb 09                	jmp    801674 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80166b:	89 c2                	mov    %eax,%edx
  80166d:	eb 05                	jmp    801674 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80166f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801674:	89 d0                	mov    %edx,%eax
  801676:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801679:	c9                   	leave  
  80167a:	c3                   	ret    

0080167b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80167b:	55                   	push   %ebp
  80167c:	89 e5                	mov    %esp,%ebp
  80167e:	56                   	push   %esi
  80167f:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801680:	83 ec 08             	sub    $0x8,%esp
  801683:	6a 00                	push   $0x0
  801685:	ff 75 08             	pushl  0x8(%ebp)
  801688:	e8 0c 02 00 00       	call   801899 <open>
  80168d:	89 c3                	mov    %eax,%ebx
  80168f:	83 c4 10             	add    $0x10,%esp
  801692:	85 c0                	test   %eax,%eax
  801694:	78 1b                	js     8016b1 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801696:	83 ec 08             	sub    $0x8,%esp
  801699:	ff 75 0c             	pushl  0xc(%ebp)
  80169c:	50                   	push   %eax
  80169d:	e8 5b ff ff ff       	call   8015fd <fstat>
  8016a2:	89 c6                	mov    %eax,%esi
	close(fd);
  8016a4:	89 1c 24             	mov    %ebx,(%esp)
  8016a7:	e8 fd fb ff ff       	call   8012a9 <close>
	return r;
  8016ac:	83 c4 10             	add    $0x10,%esp
  8016af:	89 f0                	mov    %esi,%eax
}
  8016b1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016b4:	5b                   	pop    %ebx
  8016b5:	5e                   	pop    %esi
  8016b6:	5d                   	pop    %ebp
  8016b7:	c3                   	ret    

008016b8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016b8:	55                   	push   %ebp
  8016b9:	89 e5                	mov    %esp,%ebp
  8016bb:	56                   	push   %esi
  8016bc:	53                   	push   %ebx
  8016bd:	89 c6                	mov    %eax,%esi
  8016bf:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016c1:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016c8:	75 12                	jne    8016dc <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016ca:	83 ec 0c             	sub    $0xc,%esp
  8016cd:	6a 01                	push   $0x1
  8016cf:	e8 fc f9 ff ff       	call   8010d0 <ipc_find_env>
  8016d4:	a3 00 40 80 00       	mov    %eax,0x804000
  8016d9:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016dc:	6a 07                	push   $0x7
  8016de:	68 00 50 80 00       	push   $0x805000
  8016e3:	56                   	push   %esi
  8016e4:	ff 35 00 40 80 00    	pushl  0x804000
  8016ea:	e8 8d f9 ff ff       	call   80107c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016ef:	83 c4 0c             	add    $0xc,%esp
  8016f2:	6a 00                	push   $0x0
  8016f4:	53                   	push   %ebx
  8016f5:	6a 00                	push   $0x0
  8016f7:	e8 17 f9 ff ff       	call   801013 <ipc_recv>
}
  8016fc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016ff:	5b                   	pop    %ebx
  801700:	5e                   	pop    %esi
  801701:	5d                   	pop    %ebp
  801702:	c3                   	ret    

00801703 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801703:	55                   	push   %ebp
  801704:	89 e5                	mov    %esp,%ebp
  801706:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801709:	8b 45 08             	mov    0x8(%ebp),%eax
  80170c:	8b 40 0c             	mov    0xc(%eax),%eax
  80170f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801714:	8b 45 0c             	mov    0xc(%ebp),%eax
  801717:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80171c:	ba 00 00 00 00       	mov    $0x0,%edx
  801721:	b8 02 00 00 00       	mov    $0x2,%eax
  801726:	e8 8d ff ff ff       	call   8016b8 <fsipc>
}
  80172b:	c9                   	leave  
  80172c:	c3                   	ret    

0080172d <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80172d:	55                   	push   %ebp
  80172e:	89 e5                	mov    %esp,%ebp
  801730:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801733:	8b 45 08             	mov    0x8(%ebp),%eax
  801736:	8b 40 0c             	mov    0xc(%eax),%eax
  801739:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80173e:	ba 00 00 00 00       	mov    $0x0,%edx
  801743:	b8 06 00 00 00       	mov    $0x6,%eax
  801748:	e8 6b ff ff ff       	call   8016b8 <fsipc>
}
  80174d:	c9                   	leave  
  80174e:	c3                   	ret    

0080174f <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80174f:	55                   	push   %ebp
  801750:	89 e5                	mov    %esp,%ebp
  801752:	53                   	push   %ebx
  801753:	83 ec 04             	sub    $0x4,%esp
  801756:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801759:	8b 45 08             	mov    0x8(%ebp),%eax
  80175c:	8b 40 0c             	mov    0xc(%eax),%eax
  80175f:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801764:	ba 00 00 00 00       	mov    $0x0,%edx
  801769:	b8 05 00 00 00       	mov    $0x5,%eax
  80176e:	e8 45 ff ff ff       	call   8016b8 <fsipc>
  801773:	85 c0                	test   %eax,%eax
  801775:	78 2c                	js     8017a3 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801777:	83 ec 08             	sub    $0x8,%esp
  80177a:	68 00 50 80 00       	push   $0x805000
  80177f:	53                   	push   %ebx
  801780:	e8 f1 ef ff ff       	call   800776 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801785:	a1 80 50 80 00       	mov    0x805080,%eax
  80178a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801790:	a1 84 50 80 00       	mov    0x805084,%eax
  801795:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80179b:	83 c4 10             	add    $0x10,%esp
  80179e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017a6:	c9                   	leave  
  8017a7:	c3                   	ret    

008017a8 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017a8:	55                   	push   %ebp
  8017a9:	89 e5                	mov    %esp,%ebp
  8017ab:	53                   	push   %ebx
  8017ac:	83 ec 08             	sub    $0x8,%esp
  8017af:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8017b5:	8b 52 0c             	mov    0xc(%edx),%edx
  8017b8:	89 15 00 50 80 00    	mov    %edx,0x805000
  8017be:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8017c3:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  8017c8:	0f 46 d8             	cmovbe %eax,%ebx
	
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  8017cb:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  8017d1:	53                   	push   %ebx
  8017d2:	ff 75 0c             	pushl  0xc(%ebp)
  8017d5:	68 08 50 80 00       	push   $0x805008
  8017da:	e8 29 f1 ff ff       	call   800908 <memmove>

	
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) 
  8017df:	ba 00 00 00 00       	mov    $0x0,%edx
  8017e4:	b8 04 00 00 00       	mov    $0x4,%eax
  8017e9:	e8 ca fe ff ff       	call   8016b8 <fsipc>
  8017ee:	83 c4 10             	add    $0x10,%esp
  8017f1:	85 c0                	test   %eax,%eax
  8017f3:	78 1d                	js     801812 <devfile_write+0x6a>
		return r;
	assert(r <= n_real); 
  8017f5:	39 d8                	cmp    %ebx,%eax
  8017f7:	76 19                	jbe    801812 <devfile_write+0x6a>
  8017f9:	68 6c 26 80 00       	push   $0x80266c
  8017fe:	68 78 26 80 00       	push   $0x802678
  801803:	68 a3 00 00 00       	push   $0xa3
  801808:	68 8d 26 80 00       	push   $0x80268d
  80180d:	e8 0a 06 00 00       	call   801e1c <_panic>
	return r;
}
  801812:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801815:	c9                   	leave  
  801816:	c3                   	ret    

00801817 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801817:	55                   	push   %ebp
  801818:	89 e5                	mov    %esp,%ebp
  80181a:	56                   	push   %esi
  80181b:	53                   	push   %ebx
  80181c:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80181f:	8b 45 08             	mov    0x8(%ebp),%eax
  801822:	8b 40 0c             	mov    0xc(%eax),%eax
  801825:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80182a:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801830:	ba 00 00 00 00       	mov    $0x0,%edx
  801835:	b8 03 00 00 00       	mov    $0x3,%eax
  80183a:	e8 79 fe ff ff       	call   8016b8 <fsipc>
  80183f:	89 c3                	mov    %eax,%ebx
  801841:	85 c0                	test   %eax,%eax
  801843:	78 4b                	js     801890 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801845:	39 c6                	cmp    %eax,%esi
  801847:	73 16                	jae    80185f <devfile_read+0x48>
  801849:	68 98 26 80 00       	push   $0x802698
  80184e:	68 78 26 80 00       	push   $0x802678
  801853:	6a 7c                	push   $0x7c
  801855:	68 8d 26 80 00       	push   $0x80268d
  80185a:	e8 bd 05 00 00       	call   801e1c <_panic>
	assert(r <= PGSIZE);
  80185f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801864:	7e 16                	jle    80187c <devfile_read+0x65>
  801866:	68 9f 26 80 00       	push   $0x80269f
  80186b:	68 78 26 80 00       	push   $0x802678
  801870:	6a 7d                	push   $0x7d
  801872:	68 8d 26 80 00       	push   $0x80268d
  801877:	e8 a0 05 00 00       	call   801e1c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80187c:	83 ec 04             	sub    $0x4,%esp
  80187f:	50                   	push   %eax
  801880:	68 00 50 80 00       	push   $0x805000
  801885:	ff 75 0c             	pushl  0xc(%ebp)
  801888:	e8 7b f0 ff ff       	call   800908 <memmove>
	return r;
  80188d:	83 c4 10             	add    $0x10,%esp
}
  801890:	89 d8                	mov    %ebx,%eax
  801892:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801895:	5b                   	pop    %ebx
  801896:	5e                   	pop    %esi
  801897:	5d                   	pop    %ebp
  801898:	c3                   	ret    

00801899 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801899:	55                   	push   %ebp
  80189a:	89 e5                	mov    %esp,%ebp
  80189c:	53                   	push   %ebx
  80189d:	83 ec 20             	sub    $0x20,%esp
  8018a0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018a3:	53                   	push   %ebx
  8018a4:	e8 94 ee ff ff       	call   80073d <strlen>
  8018a9:	83 c4 10             	add    $0x10,%esp
  8018ac:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018b1:	7f 67                	jg     80191a <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018b3:	83 ec 0c             	sub    $0xc,%esp
  8018b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018b9:	50                   	push   %eax
  8018ba:	e8 71 f8 ff ff       	call   801130 <fd_alloc>
  8018bf:	83 c4 10             	add    $0x10,%esp
		return r;
  8018c2:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018c4:	85 c0                	test   %eax,%eax
  8018c6:	78 57                	js     80191f <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018c8:	83 ec 08             	sub    $0x8,%esp
  8018cb:	53                   	push   %ebx
  8018cc:	68 00 50 80 00       	push   $0x805000
  8018d1:	e8 a0 ee ff ff       	call   800776 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018d9:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018de:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018e1:	b8 01 00 00 00       	mov    $0x1,%eax
  8018e6:	e8 cd fd ff ff       	call   8016b8 <fsipc>
  8018eb:	89 c3                	mov    %eax,%ebx
  8018ed:	83 c4 10             	add    $0x10,%esp
  8018f0:	85 c0                	test   %eax,%eax
  8018f2:	79 14                	jns    801908 <open+0x6f>
		fd_close(fd, 0);
  8018f4:	83 ec 08             	sub    $0x8,%esp
  8018f7:	6a 00                	push   $0x0
  8018f9:	ff 75 f4             	pushl  -0xc(%ebp)
  8018fc:	e8 27 f9 ff ff       	call   801228 <fd_close>
		return r;
  801901:	83 c4 10             	add    $0x10,%esp
  801904:	89 da                	mov    %ebx,%edx
  801906:	eb 17                	jmp    80191f <open+0x86>
	}

	return fd2num(fd);
  801908:	83 ec 0c             	sub    $0xc,%esp
  80190b:	ff 75 f4             	pushl  -0xc(%ebp)
  80190e:	e8 f6 f7 ff ff       	call   801109 <fd2num>
  801913:	89 c2                	mov    %eax,%edx
  801915:	83 c4 10             	add    $0x10,%esp
  801918:	eb 05                	jmp    80191f <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80191a:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80191f:	89 d0                	mov    %edx,%eax
  801921:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801924:	c9                   	leave  
  801925:	c3                   	ret    

00801926 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801926:	55                   	push   %ebp
  801927:	89 e5                	mov    %esp,%ebp
  801929:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80192c:	ba 00 00 00 00       	mov    $0x0,%edx
  801931:	b8 08 00 00 00       	mov    $0x8,%eax
  801936:	e8 7d fd ff ff       	call   8016b8 <fsipc>
}
  80193b:	c9                   	leave  
  80193c:	c3                   	ret    

0080193d <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80193d:	55                   	push   %ebp
  80193e:	89 e5                	mov    %esp,%ebp
  801940:	56                   	push   %esi
  801941:	53                   	push   %ebx
  801942:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801945:	83 ec 0c             	sub    $0xc,%esp
  801948:	ff 75 08             	pushl  0x8(%ebp)
  80194b:	e8 c9 f7 ff ff       	call   801119 <fd2data>
  801950:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801952:	83 c4 08             	add    $0x8,%esp
  801955:	68 ab 26 80 00       	push   $0x8026ab
  80195a:	53                   	push   %ebx
  80195b:	e8 16 ee ff ff       	call   800776 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801960:	8b 46 04             	mov    0x4(%esi),%eax
  801963:	2b 06                	sub    (%esi),%eax
  801965:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80196b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801972:	00 00 00 
	stat->st_dev = &devpipe;
  801975:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80197c:	30 80 00 
	return 0;
}
  80197f:	b8 00 00 00 00       	mov    $0x0,%eax
  801984:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801987:	5b                   	pop    %ebx
  801988:	5e                   	pop    %esi
  801989:	5d                   	pop    %ebp
  80198a:	c3                   	ret    

0080198b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80198b:	55                   	push   %ebp
  80198c:	89 e5                	mov    %esp,%ebp
  80198e:	53                   	push   %ebx
  80198f:	83 ec 0c             	sub    $0xc,%esp
  801992:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801995:	53                   	push   %ebx
  801996:	6a 00                	push   $0x0
  801998:	e8 61 f2 ff ff       	call   800bfe <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80199d:	89 1c 24             	mov    %ebx,(%esp)
  8019a0:	e8 74 f7 ff ff       	call   801119 <fd2data>
  8019a5:	83 c4 08             	add    $0x8,%esp
  8019a8:	50                   	push   %eax
  8019a9:	6a 00                	push   $0x0
  8019ab:	e8 4e f2 ff ff       	call   800bfe <sys_page_unmap>
}
  8019b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019b3:	c9                   	leave  
  8019b4:	c3                   	ret    

008019b5 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8019b5:	55                   	push   %ebp
  8019b6:	89 e5                	mov    %esp,%ebp
  8019b8:	57                   	push   %edi
  8019b9:	56                   	push   %esi
  8019ba:	53                   	push   %ebx
  8019bb:	83 ec 1c             	sub    $0x1c,%esp
  8019be:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8019c1:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8019c3:	a1 08 40 80 00       	mov    0x804008,%eax
  8019c8:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8019cb:	83 ec 0c             	sub    $0xc,%esp
  8019ce:	ff 75 e0             	pushl  -0x20(%ebp)
  8019d1:	e8 02 05 00 00       	call   801ed8 <pageref>
  8019d6:	89 c3                	mov    %eax,%ebx
  8019d8:	89 3c 24             	mov    %edi,(%esp)
  8019db:	e8 f8 04 00 00       	call   801ed8 <pageref>
  8019e0:	83 c4 10             	add    $0x10,%esp
  8019e3:	39 c3                	cmp    %eax,%ebx
  8019e5:	0f 94 c1             	sete   %cl
  8019e8:	0f b6 c9             	movzbl %cl,%ecx
  8019eb:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8019ee:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8019f4:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8019f7:	39 ce                	cmp    %ecx,%esi
  8019f9:	74 1b                	je     801a16 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8019fb:	39 c3                	cmp    %eax,%ebx
  8019fd:	75 c4                	jne    8019c3 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8019ff:	8b 42 58             	mov    0x58(%edx),%eax
  801a02:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a05:	50                   	push   %eax
  801a06:	56                   	push   %esi
  801a07:	68 b2 26 80 00       	push   $0x8026b2
  801a0c:	e8 e0 e7 ff ff       	call   8001f1 <cprintf>
  801a11:	83 c4 10             	add    $0x10,%esp
  801a14:	eb ad                	jmp    8019c3 <_pipeisclosed+0xe>
	}
}
  801a16:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a19:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a1c:	5b                   	pop    %ebx
  801a1d:	5e                   	pop    %esi
  801a1e:	5f                   	pop    %edi
  801a1f:	5d                   	pop    %ebp
  801a20:	c3                   	ret    

00801a21 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a21:	55                   	push   %ebp
  801a22:	89 e5                	mov    %esp,%ebp
  801a24:	57                   	push   %edi
  801a25:	56                   	push   %esi
  801a26:	53                   	push   %ebx
  801a27:	83 ec 28             	sub    $0x28,%esp
  801a2a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a2d:	56                   	push   %esi
  801a2e:	e8 e6 f6 ff ff       	call   801119 <fd2data>
  801a33:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a35:	83 c4 10             	add    $0x10,%esp
  801a38:	bf 00 00 00 00       	mov    $0x0,%edi
  801a3d:	eb 4b                	jmp    801a8a <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a3f:	89 da                	mov    %ebx,%edx
  801a41:	89 f0                	mov    %esi,%eax
  801a43:	e8 6d ff ff ff       	call   8019b5 <_pipeisclosed>
  801a48:	85 c0                	test   %eax,%eax
  801a4a:	75 48                	jne    801a94 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a4c:	e8 09 f1 ff ff       	call   800b5a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a51:	8b 43 04             	mov    0x4(%ebx),%eax
  801a54:	8b 0b                	mov    (%ebx),%ecx
  801a56:	8d 51 20             	lea    0x20(%ecx),%edx
  801a59:	39 d0                	cmp    %edx,%eax
  801a5b:	73 e2                	jae    801a3f <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a60:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a64:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a67:	89 c2                	mov    %eax,%edx
  801a69:	c1 fa 1f             	sar    $0x1f,%edx
  801a6c:	89 d1                	mov    %edx,%ecx
  801a6e:	c1 e9 1b             	shr    $0x1b,%ecx
  801a71:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801a74:	83 e2 1f             	and    $0x1f,%edx
  801a77:	29 ca                	sub    %ecx,%edx
  801a79:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801a7d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a81:	83 c0 01             	add    $0x1,%eax
  801a84:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a87:	83 c7 01             	add    $0x1,%edi
  801a8a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a8d:	75 c2                	jne    801a51 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a8f:	8b 45 10             	mov    0x10(%ebp),%eax
  801a92:	eb 05                	jmp    801a99 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a94:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801a99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a9c:	5b                   	pop    %ebx
  801a9d:	5e                   	pop    %esi
  801a9e:	5f                   	pop    %edi
  801a9f:	5d                   	pop    %ebp
  801aa0:	c3                   	ret    

00801aa1 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801aa1:	55                   	push   %ebp
  801aa2:	89 e5                	mov    %esp,%ebp
  801aa4:	57                   	push   %edi
  801aa5:	56                   	push   %esi
  801aa6:	53                   	push   %ebx
  801aa7:	83 ec 18             	sub    $0x18,%esp
  801aaa:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801aad:	57                   	push   %edi
  801aae:	e8 66 f6 ff ff       	call   801119 <fd2data>
  801ab3:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ab5:	83 c4 10             	add    $0x10,%esp
  801ab8:	bb 00 00 00 00       	mov    $0x0,%ebx
  801abd:	eb 3d                	jmp    801afc <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801abf:	85 db                	test   %ebx,%ebx
  801ac1:	74 04                	je     801ac7 <devpipe_read+0x26>
				return i;
  801ac3:	89 d8                	mov    %ebx,%eax
  801ac5:	eb 44                	jmp    801b0b <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ac7:	89 f2                	mov    %esi,%edx
  801ac9:	89 f8                	mov    %edi,%eax
  801acb:	e8 e5 fe ff ff       	call   8019b5 <_pipeisclosed>
  801ad0:	85 c0                	test   %eax,%eax
  801ad2:	75 32                	jne    801b06 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801ad4:	e8 81 f0 ff ff       	call   800b5a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ad9:	8b 06                	mov    (%esi),%eax
  801adb:	3b 46 04             	cmp    0x4(%esi),%eax
  801ade:	74 df                	je     801abf <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801ae0:	99                   	cltd   
  801ae1:	c1 ea 1b             	shr    $0x1b,%edx
  801ae4:	01 d0                	add    %edx,%eax
  801ae6:	83 e0 1f             	and    $0x1f,%eax
  801ae9:	29 d0                	sub    %edx,%eax
  801aeb:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801af0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801af3:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801af6:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801af9:	83 c3 01             	add    $0x1,%ebx
  801afc:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801aff:	75 d8                	jne    801ad9 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b01:	8b 45 10             	mov    0x10(%ebp),%eax
  801b04:	eb 05                	jmp    801b0b <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b06:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b0e:	5b                   	pop    %ebx
  801b0f:	5e                   	pop    %esi
  801b10:	5f                   	pop    %edi
  801b11:	5d                   	pop    %ebp
  801b12:	c3                   	ret    

00801b13 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b13:	55                   	push   %ebp
  801b14:	89 e5                	mov    %esp,%ebp
  801b16:	56                   	push   %esi
  801b17:	53                   	push   %ebx
  801b18:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b1b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b1e:	50                   	push   %eax
  801b1f:	e8 0c f6 ff ff       	call   801130 <fd_alloc>
  801b24:	83 c4 10             	add    $0x10,%esp
  801b27:	89 c2                	mov    %eax,%edx
  801b29:	85 c0                	test   %eax,%eax
  801b2b:	0f 88 2c 01 00 00    	js     801c5d <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b31:	83 ec 04             	sub    $0x4,%esp
  801b34:	68 07 04 00 00       	push   $0x407
  801b39:	ff 75 f4             	pushl  -0xc(%ebp)
  801b3c:	6a 00                	push   $0x0
  801b3e:	e8 36 f0 ff ff       	call   800b79 <sys_page_alloc>
  801b43:	83 c4 10             	add    $0x10,%esp
  801b46:	89 c2                	mov    %eax,%edx
  801b48:	85 c0                	test   %eax,%eax
  801b4a:	0f 88 0d 01 00 00    	js     801c5d <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b50:	83 ec 0c             	sub    $0xc,%esp
  801b53:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b56:	50                   	push   %eax
  801b57:	e8 d4 f5 ff ff       	call   801130 <fd_alloc>
  801b5c:	89 c3                	mov    %eax,%ebx
  801b5e:	83 c4 10             	add    $0x10,%esp
  801b61:	85 c0                	test   %eax,%eax
  801b63:	0f 88 e2 00 00 00    	js     801c4b <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b69:	83 ec 04             	sub    $0x4,%esp
  801b6c:	68 07 04 00 00       	push   $0x407
  801b71:	ff 75 f0             	pushl  -0x10(%ebp)
  801b74:	6a 00                	push   $0x0
  801b76:	e8 fe ef ff ff       	call   800b79 <sys_page_alloc>
  801b7b:	89 c3                	mov    %eax,%ebx
  801b7d:	83 c4 10             	add    $0x10,%esp
  801b80:	85 c0                	test   %eax,%eax
  801b82:	0f 88 c3 00 00 00    	js     801c4b <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b88:	83 ec 0c             	sub    $0xc,%esp
  801b8b:	ff 75 f4             	pushl  -0xc(%ebp)
  801b8e:	e8 86 f5 ff ff       	call   801119 <fd2data>
  801b93:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b95:	83 c4 0c             	add    $0xc,%esp
  801b98:	68 07 04 00 00       	push   $0x407
  801b9d:	50                   	push   %eax
  801b9e:	6a 00                	push   $0x0
  801ba0:	e8 d4 ef ff ff       	call   800b79 <sys_page_alloc>
  801ba5:	89 c3                	mov    %eax,%ebx
  801ba7:	83 c4 10             	add    $0x10,%esp
  801baa:	85 c0                	test   %eax,%eax
  801bac:	0f 88 89 00 00 00    	js     801c3b <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bb2:	83 ec 0c             	sub    $0xc,%esp
  801bb5:	ff 75 f0             	pushl  -0x10(%ebp)
  801bb8:	e8 5c f5 ff ff       	call   801119 <fd2data>
  801bbd:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801bc4:	50                   	push   %eax
  801bc5:	6a 00                	push   $0x0
  801bc7:	56                   	push   %esi
  801bc8:	6a 00                	push   $0x0
  801bca:	e8 ed ef ff ff       	call   800bbc <sys_page_map>
  801bcf:	89 c3                	mov    %eax,%ebx
  801bd1:	83 c4 20             	add    $0x20,%esp
  801bd4:	85 c0                	test   %eax,%eax
  801bd6:	78 55                	js     801c2d <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801bd8:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bde:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801be1:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801be3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801be6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801bed:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bf3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bf6:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801bf8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bfb:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c02:	83 ec 0c             	sub    $0xc,%esp
  801c05:	ff 75 f4             	pushl  -0xc(%ebp)
  801c08:	e8 fc f4 ff ff       	call   801109 <fd2num>
  801c0d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c10:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c12:	83 c4 04             	add    $0x4,%esp
  801c15:	ff 75 f0             	pushl  -0x10(%ebp)
  801c18:	e8 ec f4 ff ff       	call   801109 <fd2num>
  801c1d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c20:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c23:	83 c4 10             	add    $0x10,%esp
  801c26:	ba 00 00 00 00       	mov    $0x0,%edx
  801c2b:	eb 30                	jmp    801c5d <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c2d:	83 ec 08             	sub    $0x8,%esp
  801c30:	56                   	push   %esi
  801c31:	6a 00                	push   $0x0
  801c33:	e8 c6 ef ff ff       	call   800bfe <sys_page_unmap>
  801c38:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c3b:	83 ec 08             	sub    $0x8,%esp
  801c3e:	ff 75 f0             	pushl  -0x10(%ebp)
  801c41:	6a 00                	push   $0x0
  801c43:	e8 b6 ef ff ff       	call   800bfe <sys_page_unmap>
  801c48:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c4b:	83 ec 08             	sub    $0x8,%esp
  801c4e:	ff 75 f4             	pushl  -0xc(%ebp)
  801c51:	6a 00                	push   $0x0
  801c53:	e8 a6 ef ff ff       	call   800bfe <sys_page_unmap>
  801c58:	83 c4 10             	add    $0x10,%esp
  801c5b:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801c5d:	89 d0                	mov    %edx,%eax
  801c5f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c62:	5b                   	pop    %ebx
  801c63:	5e                   	pop    %esi
  801c64:	5d                   	pop    %ebp
  801c65:	c3                   	ret    

00801c66 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c66:	55                   	push   %ebp
  801c67:	89 e5                	mov    %esp,%ebp
  801c69:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c6c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c6f:	50                   	push   %eax
  801c70:	ff 75 08             	pushl  0x8(%ebp)
  801c73:	e8 07 f5 ff ff       	call   80117f <fd_lookup>
  801c78:	83 c4 10             	add    $0x10,%esp
  801c7b:	85 c0                	test   %eax,%eax
  801c7d:	78 18                	js     801c97 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c7f:	83 ec 0c             	sub    $0xc,%esp
  801c82:	ff 75 f4             	pushl  -0xc(%ebp)
  801c85:	e8 8f f4 ff ff       	call   801119 <fd2data>
	return _pipeisclosed(fd, p);
  801c8a:	89 c2                	mov    %eax,%edx
  801c8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c8f:	e8 21 fd ff ff       	call   8019b5 <_pipeisclosed>
  801c94:	83 c4 10             	add    $0x10,%esp
}
  801c97:	c9                   	leave  
  801c98:	c3                   	ret    

00801c99 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c99:	55                   	push   %ebp
  801c9a:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801c9c:	b8 00 00 00 00       	mov    $0x0,%eax
  801ca1:	5d                   	pop    %ebp
  801ca2:	c3                   	ret    

00801ca3 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ca3:	55                   	push   %ebp
  801ca4:	89 e5                	mov    %esp,%ebp
  801ca6:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801ca9:	68 ca 26 80 00       	push   $0x8026ca
  801cae:	ff 75 0c             	pushl  0xc(%ebp)
  801cb1:	e8 c0 ea ff ff       	call   800776 <strcpy>
	return 0;
}
  801cb6:	b8 00 00 00 00       	mov    $0x0,%eax
  801cbb:	c9                   	leave  
  801cbc:	c3                   	ret    

00801cbd <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801cbd:	55                   	push   %ebp
  801cbe:	89 e5                	mov    %esp,%ebp
  801cc0:	57                   	push   %edi
  801cc1:	56                   	push   %esi
  801cc2:	53                   	push   %ebx
  801cc3:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cc9:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801cce:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cd4:	eb 2d                	jmp    801d03 <devcons_write+0x46>
		m = n - tot;
  801cd6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801cd9:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801cdb:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801cde:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801ce3:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ce6:	83 ec 04             	sub    $0x4,%esp
  801ce9:	53                   	push   %ebx
  801cea:	03 45 0c             	add    0xc(%ebp),%eax
  801ced:	50                   	push   %eax
  801cee:	57                   	push   %edi
  801cef:	e8 14 ec ff ff       	call   800908 <memmove>
		sys_cputs(buf, m);
  801cf4:	83 c4 08             	add    $0x8,%esp
  801cf7:	53                   	push   %ebx
  801cf8:	57                   	push   %edi
  801cf9:	e8 bf ed ff ff       	call   800abd <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cfe:	01 de                	add    %ebx,%esi
  801d00:	83 c4 10             	add    $0x10,%esp
  801d03:	89 f0                	mov    %esi,%eax
  801d05:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d08:	72 cc                	jb     801cd6 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d0a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d0d:	5b                   	pop    %ebx
  801d0e:	5e                   	pop    %esi
  801d0f:	5f                   	pop    %edi
  801d10:	5d                   	pop    %ebp
  801d11:	c3                   	ret    

00801d12 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d12:	55                   	push   %ebp
  801d13:	89 e5                	mov    %esp,%ebp
  801d15:	83 ec 08             	sub    $0x8,%esp
  801d18:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801d1d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d21:	74 2a                	je     801d4d <devcons_read+0x3b>
  801d23:	eb 05                	jmp    801d2a <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d25:	e8 30 ee ff ff       	call   800b5a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d2a:	e8 ac ed ff ff       	call   800adb <sys_cgetc>
  801d2f:	85 c0                	test   %eax,%eax
  801d31:	74 f2                	je     801d25 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801d33:	85 c0                	test   %eax,%eax
  801d35:	78 16                	js     801d4d <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d37:	83 f8 04             	cmp    $0x4,%eax
  801d3a:	74 0c                	je     801d48 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801d3c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d3f:	88 02                	mov    %al,(%edx)
	return 1;
  801d41:	b8 01 00 00 00       	mov    $0x1,%eax
  801d46:	eb 05                	jmp    801d4d <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801d48:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801d4d:	c9                   	leave  
  801d4e:	c3                   	ret    

00801d4f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801d4f:	55                   	push   %ebp
  801d50:	89 e5                	mov    %esp,%ebp
  801d52:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801d55:	8b 45 08             	mov    0x8(%ebp),%eax
  801d58:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801d5b:	6a 01                	push   $0x1
  801d5d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d60:	50                   	push   %eax
  801d61:	e8 57 ed ff ff       	call   800abd <sys_cputs>
}
  801d66:	83 c4 10             	add    $0x10,%esp
  801d69:	c9                   	leave  
  801d6a:	c3                   	ret    

00801d6b <getchar>:

int
getchar(void)
{
  801d6b:	55                   	push   %ebp
  801d6c:	89 e5                	mov    %esp,%ebp
  801d6e:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801d71:	6a 01                	push   $0x1
  801d73:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d76:	50                   	push   %eax
  801d77:	6a 00                	push   $0x0
  801d79:	e8 67 f6 ff ff       	call   8013e5 <read>
	if (r < 0)
  801d7e:	83 c4 10             	add    $0x10,%esp
  801d81:	85 c0                	test   %eax,%eax
  801d83:	78 0f                	js     801d94 <getchar+0x29>
		return r;
	if (r < 1)
  801d85:	85 c0                	test   %eax,%eax
  801d87:	7e 06                	jle    801d8f <getchar+0x24>
		return -E_EOF;
	return c;
  801d89:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801d8d:	eb 05                	jmp    801d94 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801d8f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801d94:	c9                   	leave  
  801d95:	c3                   	ret    

00801d96 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801d96:	55                   	push   %ebp
  801d97:	89 e5                	mov    %esp,%ebp
  801d99:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d9c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d9f:	50                   	push   %eax
  801da0:	ff 75 08             	pushl  0x8(%ebp)
  801da3:	e8 d7 f3 ff ff       	call   80117f <fd_lookup>
  801da8:	83 c4 10             	add    $0x10,%esp
  801dab:	85 c0                	test   %eax,%eax
  801dad:	78 11                	js     801dc0 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801daf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801db2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801db8:	39 10                	cmp    %edx,(%eax)
  801dba:	0f 94 c0             	sete   %al
  801dbd:	0f b6 c0             	movzbl %al,%eax
}
  801dc0:	c9                   	leave  
  801dc1:	c3                   	ret    

00801dc2 <opencons>:

int
opencons(void)
{
  801dc2:	55                   	push   %ebp
  801dc3:	89 e5                	mov    %esp,%ebp
  801dc5:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801dc8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dcb:	50                   	push   %eax
  801dcc:	e8 5f f3 ff ff       	call   801130 <fd_alloc>
  801dd1:	83 c4 10             	add    $0x10,%esp
		return r;
  801dd4:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801dd6:	85 c0                	test   %eax,%eax
  801dd8:	78 3e                	js     801e18 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801dda:	83 ec 04             	sub    $0x4,%esp
  801ddd:	68 07 04 00 00       	push   $0x407
  801de2:	ff 75 f4             	pushl  -0xc(%ebp)
  801de5:	6a 00                	push   $0x0
  801de7:	e8 8d ed ff ff       	call   800b79 <sys_page_alloc>
  801dec:	83 c4 10             	add    $0x10,%esp
		return r;
  801def:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801df1:	85 c0                	test   %eax,%eax
  801df3:	78 23                	js     801e18 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801df5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801dfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dfe:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e00:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e03:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e0a:	83 ec 0c             	sub    $0xc,%esp
  801e0d:	50                   	push   %eax
  801e0e:	e8 f6 f2 ff ff       	call   801109 <fd2num>
  801e13:	89 c2                	mov    %eax,%edx
  801e15:	83 c4 10             	add    $0x10,%esp
}
  801e18:	89 d0                	mov    %edx,%eax
  801e1a:	c9                   	leave  
  801e1b:	c3                   	ret    

00801e1c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801e1c:	55                   	push   %ebp
  801e1d:	89 e5                	mov    %esp,%ebp
  801e1f:	56                   	push   %esi
  801e20:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801e21:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801e24:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801e2a:	e8 0c ed ff ff       	call   800b3b <sys_getenvid>
  801e2f:	83 ec 0c             	sub    $0xc,%esp
  801e32:	ff 75 0c             	pushl  0xc(%ebp)
  801e35:	ff 75 08             	pushl  0x8(%ebp)
  801e38:	56                   	push   %esi
  801e39:	50                   	push   %eax
  801e3a:	68 d8 26 80 00       	push   $0x8026d8
  801e3f:	e8 ad e3 ff ff       	call   8001f1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801e44:	83 c4 18             	add    $0x18,%esp
  801e47:	53                   	push   %ebx
  801e48:	ff 75 10             	pushl  0x10(%ebp)
  801e4b:	e8 50 e3 ff ff       	call   8001a0 <vcprintf>
	cprintf("\n");
  801e50:	c7 04 24 c3 26 80 00 	movl   $0x8026c3,(%esp)
  801e57:	e8 95 e3 ff ff       	call   8001f1 <cprintf>
  801e5c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801e5f:	cc                   	int3   
  801e60:	eb fd                	jmp    801e5f <_panic+0x43>

00801e62 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801e62:	55                   	push   %ebp
  801e63:	89 e5                	mov    %esp,%ebp
  801e65:	53                   	push   %ebx
  801e66:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  801e69:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801e70:	75 28                	jne    801e9a <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  801e72:	e8 c4 ec ff ff       	call   800b3b <sys_getenvid>
  801e77:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_U | PTE_W);
  801e79:	83 ec 04             	sub    $0x4,%esp
  801e7c:	6a 06                	push   $0x6
  801e7e:	68 00 f0 bf ee       	push   $0xeebff000
  801e83:	50                   	push   %eax
  801e84:	e8 f0 ec ff ff       	call   800b79 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  801e89:	83 c4 08             	add    $0x8,%esp
  801e8c:	68 a7 1e 80 00       	push   $0x801ea7
  801e91:	53                   	push   %ebx
  801e92:	e8 2d ee ff ff       	call   800cc4 <sys_env_set_pgfault_upcall>
  801e97:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801e9a:	8b 45 08             	mov    0x8(%ebp),%eax
  801e9d:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801ea2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ea5:	c9                   	leave  
  801ea6:	c3                   	ret    

00801ea7 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801ea7:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801ea8:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801ead:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801eaf:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	# My method is different. Copy the values to the other stack
	# in a convinient way, and then pop everything.
	movl %esp, %ebp		# ebp refers to the exception stack
  801eb2:	89 e5                	mov    %esp,%ebp
	movl 48(%ebp), %esp 	# go to other stack
  801eb4:	8b 65 30             	mov    0x30(%ebp),%esp

	pushl 40(%ebp)		# eip - ORDER SWITCHED WITH EFLAGS
  801eb7:	ff 75 28             	pushl  0x28(%ebp)
	pushl 44(%ebp)      	# eflags
  801eba:	ff 75 2c             	pushl  0x2c(%ebp)
	pushl 36(%ebp)		# all the 8 remaining regs
  801ebd:	ff 75 24             	pushl  0x24(%ebp)
	pushl 32(%ebp)
  801ec0:	ff 75 20             	pushl  0x20(%ebp)
	pushl 28(%ebp)
  801ec3:	ff 75 1c             	pushl  0x1c(%ebp)
	pushl 24(%ebp)
  801ec6:	ff 75 18             	pushl  0x18(%ebp)
	pushl 20(%ebp)
  801ec9:	ff 75 14             	pushl  0x14(%ebp)
	pushl 16(%ebp)
  801ecc:	ff 75 10             	pushl  0x10(%ebp)
	pushl 12(%ebp)
  801ecf:	ff 75 0c             	pushl  0xc(%ebp)
	pushl 8(%ebp)
  801ed2:	ff 75 08             	pushl  0x8(%ebp)

	popal			# now just pop everything!
  801ed5:	61                   	popa   
	popfl
  801ed6:	9d                   	popf   
	ret
  801ed7:	c3                   	ret    

00801ed8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ed8:	55                   	push   %ebp
  801ed9:	89 e5                	mov    %esp,%ebp
  801edb:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ede:	89 d0                	mov    %edx,%eax
  801ee0:	c1 e8 16             	shr    $0x16,%eax
  801ee3:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801eea:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801eef:	f6 c1 01             	test   $0x1,%cl
  801ef2:	74 1d                	je     801f11 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801ef4:	c1 ea 0c             	shr    $0xc,%edx
  801ef7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801efe:	f6 c2 01             	test   $0x1,%dl
  801f01:	74 0e                	je     801f11 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f03:	c1 ea 0c             	shr    $0xc,%edx
  801f06:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f0d:	ef 
  801f0e:	0f b7 c0             	movzwl %ax,%eax
}
  801f11:	5d                   	pop    %ebp
  801f12:	c3                   	ret    
  801f13:	66 90                	xchg   %ax,%ax
  801f15:	66 90                	xchg   %ax,%ax
  801f17:	66 90                	xchg   %ax,%ax
  801f19:	66 90                	xchg   %ax,%ax
  801f1b:	66 90                	xchg   %ax,%ax
  801f1d:	66 90                	xchg   %ax,%ax
  801f1f:	90                   	nop

00801f20 <__udivdi3>:
  801f20:	55                   	push   %ebp
  801f21:	57                   	push   %edi
  801f22:	56                   	push   %esi
  801f23:	53                   	push   %ebx
  801f24:	83 ec 1c             	sub    $0x1c,%esp
  801f27:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801f2b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801f2f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801f33:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f37:	85 f6                	test   %esi,%esi
  801f39:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f3d:	89 ca                	mov    %ecx,%edx
  801f3f:	89 f8                	mov    %edi,%eax
  801f41:	75 3d                	jne    801f80 <__udivdi3+0x60>
  801f43:	39 cf                	cmp    %ecx,%edi
  801f45:	0f 87 c5 00 00 00    	ja     802010 <__udivdi3+0xf0>
  801f4b:	85 ff                	test   %edi,%edi
  801f4d:	89 fd                	mov    %edi,%ebp
  801f4f:	75 0b                	jne    801f5c <__udivdi3+0x3c>
  801f51:	b8 01 00 00 00       	mov    $0x1,%eax
  801f56:	31 d2                	xor    %edx,%edx
  801f58:	f7 f7                	div    %edi
  801f5a:	89 c5                	mov    %eax,%ebp
  801f5c:	89 c8                	mov    %ecx,%eax
  801f5e:	31 d2                	xor    %edx,%edx
  801f60:	f7 f5                	div    %ebp
  801f62:	89 c1                	mov    %eax,%ecx
  801f64:	89 d8                	mov    %ebx,%eax
  801f66:	89 cf                	mov    %ecx,%edi
  801f68:	f7 f5                	div    %ebp
  801f6a:	89 c3                	mov    %eax,%ebx
  801f6c:	89 d8                	mov    %ebx,%eax
  801f6e:	89 fa                	mov    %edi,%edx
  801f70:	83 c4 1c             	add    $0x1c,%esp
  801f73:	5b                   	pop    %ebx
  801f74:	5e                   	pop    %esi
  801f75:	5f                   	pop    %edi
  801f76:	5d                   	pop    %ebp
  801f77:	c3                   	ret    
  801f78:	90                   	nop
  801f79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f80:	39 ce                	cmp    %ecx,%esi
  801f82:	77 74                	ja     801ff8 <__udivdi3+0xd8>
  801f84:	0f bd fe             	bsr    %esi,%edi
  801f87:	83 f7 1f             	xor    $0x1f,%edi
  801f8a:	0f 84 98 00 00 00    	je     802028 <__udivdi3+0x108>
  801f90:	bb 20 00 00 00       	mov    $0x20,%ebx
  801f95:	89 f9                	mov    %edi,%ecx
  801f97:	89 c5                	mov    %eax,%ebp
  801f99:	29 fb                	sub    %edi,%ebx
  801f9b:	d3 e6                	shl    %cl,%esi
  801f9d:	89 d9                	mov    %ebx,%ecx
  801f9f:	d3 ed                	shr    %cl,%ebp
  801fa1:	89 f9                	mov    %edi,%ecx
  801fa3:	d3 e0                	shl    %cl,%eax
  801fa5:	09 ee                	or     %ebp,%esi
  801fa7:	89 d9                	mov    %ebx,%ecx
  801fa9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fad:	89 d5                	mov    %edx,%ebp
  801faf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801fb3:	d3 ed                	shr    %cl,%ebp
  801fb5:	89 f9                	mov    %edi,%ecx
  801fb7:	d3 e2                	shl    %cl,%edx
  801fb9:	89 d9                	mov    %ebx,%ecx
  801fbb:	d3 e8                	shr    %cl,%eax
  801fbd:	09 c2                	or     %eax,%edx
  801fbf:	89 d0                	mov    %edx,%eax
  801fc1:	89 ea                	mov    %ebp,%edx
  801fc3:	f7 f6                	div    %esi
  801fc5:	89 d5                	mov    %edx,%ebp
  801fc7:	89 c3                	mov    %eax,%ebx
  801fc9:	f7 64 24 0c          	mull   0xc(%esp)
  801fcd:	39 d5                	cmp    %edx,%ebp
  801fcf:	72 10                	jb     801fe1 <__udivdi3+0xc1>
  801fd1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801fd5:	89 f9                	mov    %edi,%ecx
  801fd7:	d3 e6                	shl    %cl,%esi
  801fd9:	39 c6                	cmp    %eax,%esi
  801fdb:	73 07                	jae    801fe4 <__udivdi3+0xc4>
  801fdd:	39 d5                	cmp    %edx,%ebp
  801fdf:	75 03                	jne    801fe4 <__udivdi3+0xc4>
  801fe1:	83 eb 01             	sub    $0x1,%ebx
  801fe4:	31 ff                	xor    %edi,%edi
  801fe6:	89 d8                	mov    %ebx,%eax
  801fe8:	89 fa                	mov    %edi,%edx
  801fea:	83 c4 1c             	add    $0x1c,%esp
  801fed:	5b                   	pop    %ebx
  801fee:	5e                   	pop    %esi
  801fef:	5f                   	pop    %edi
  801ff0:	5d                   	pop    %ebp
  801ff1:	c3                   	ret    
  801ff2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ff8:	31 ff                	xor    %edi,%edi
  801ffa:	31 db                	xor    %ebx,%ebx
  801ffc:	89 d8                	mov    %ebx,%eax
  801ffe:	89 fa                	mov    %edi,%edx
  802000:	83 c4 1c             	add    $0x1c,%esp
  802003:	5b                   	pop    %ebx
  802004:	5e                   	pop    %esi
  802005:	5f                   	pop    %edi
  802006:	5d                   	pop    %ebp
  802007:	c3                   	ret    
  802008:	90                   	nop
  802009:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802010:	89 d8                	mov    %ebx,%eax
  802012:	f7 f7                	div    %edi
  802014:	31 ff                	xor    %edi,%edi
  802016:	89 c3                	mov    %eax,%ebx
  802018:	89 d8                	mov    %ebx,%eax
  80201a:	89 fa                	mov    %edi,%edx
  80201c:	83 c4 1c             	add    $0x1c,%esp
  80201f:	5b                   	pop    %ebx
  802020:	5e                   	pop    %esi
  802021:	5f                   	pop    %edi
  802022:	5d                   	pop    %ebp
  802023:	c3                   	ret    
  802024:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802028:	39 ce                	cmp    %ecx,%esi
  80202a:	72 0c                	jb     802038 <__udivdi3+0x118>
  80202c:	31 db                	xor    %ebx,%ebx
  80202e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802032:	0f 87 34 ff ff ff    	ja     801f6c <__udivdi3+0x4c>
  802038:	bb 01 00 00 00       	mov    $0x1,%ebx
  80203d:	e9 2a ff ff ff       	jmp    801f6c <__udivdi3+0x4c>
  802042:	66 90                	xchg   %ax,%ax
  802044:	66 90                	xchg   %ax,%ax
  802046:	66 90                	xchg   %ax,%ax
  802048:	66 90                	xchg   %ax,%ax
  80204a:	66 90                	xchg   %ax,%ax
  80204c:	66 90                	xchg   %ax,%ax
  80204e:	66 90                	xchg   %ax,%ax

00802050 <__umoddi3>:
  802050:	55                   	push   %ebp
  802051:	57                   	push   %edi
  802052:	56                   	push   %esi
  802053:	53                   	push   %ebx
  802054:	83 ec 1c             	sub    $0x1c,%esp
  802057:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80205b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80205f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802063:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802067:	85 d2                	test   %edx,%edx
  802069:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80206d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802071:	89 f3                	mov    %esi,%ebx
  802073:	89 3c 24             	mov    %edi,(%esp)
  802076:	89 74 24 04          	mov    %esi,0x4(%esp)
  80207a:	75 1c                	jne    802098 <__umoddi3+0x48>
  80207c:	39 f7                	cmp    %esi,%edi
  80207e:	76 50                	jbe    8020d0 <__umoddi3+0x80>
  802080:	89 c8                	mov    %ecx,%eax
  802082:	89 f2                	mov    %esi,%edx
  802084:	f7 f7                	div    %edi
  802086:	89 d0                	mov    %edx,%eax
  802088:	31 d2                	xor    %edx,%edx
  80208a:	83 c4 1c             	add    $0x1c,%esp
  80208d:	5b                   	pop    %ebx
  80208e:	5e                   	pop    %esi
  80208f:	5f                   	pop    %edi
  802090:	5d                   	pop    %ebp
  802091:	c3                   	ret    
  802092:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802098:	39 f2                	cmp    %esi,%edx
  80209a:	89 d0                	mov    %edx,%eax
  80209c:	77 52                	ja     8020f0 <__umoddi3+0xa0>
  80209e:	0f bd ea             	bsr    %edx,%ebp
  8020a1:	83 f5 1f             	xor    $0x1f,%ebp
  8020a4:	75 5a                	jne    802100 <__umoddi3+0xb0>
  8020a6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8020aa:	0f 82 e0 00 00 00    	jb     802190 <__umoddi3+0x140>
  8020b0:	39 0c 24             	cmp    %ecx,(%esp)
  8020b3:	0f 86 d7 00 00 00    	jbe    802190 <__umoddi3+0x140>
  8020b9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020bd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8020c1:	83 c4 1c             	add    $0x1c,%esp
  8020c4:	5b                   	pop    %ebx
  8020c5:	5e                   	pop    %esi
  8020c6:	5f                   	pop    %edi
  8020c7:	5d                   	pop    %ebp
  8020c8:	c3                   	ret    
  8020c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020d0:	85 ff                	test   %edi,%edi
  8020d2:	89 fd                	mov    %edi,%ebp
  8020d4:	75 0b                	jne    8020e1 <__umoddi3+0x91>
  8020d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8020db:	31 d2                	xor    %edx,%edx
  8020dd:	f7 f7                	div    %edi
  8020df:	89 c5                	mov    %eax,%ebp
  8020e1:	89 f0                	mov    %esi,%eax
  8020e3:	31 d2                	xor    %edx,%edx
  8020e5:	f7 f5                	div    %ebp
  8020e7:	89 c8                	mov    %ecx,%eax
  8020e9:	f7 f5                	div    %ebp
  8020eb:	89 d0                	mov    %edx,%eax
  8020ed:	eb 99                	jmp    802088 <__umoddi3+0x38>
  8020ef:	90                   	nop
  8020f0:	89 c8                	mov    %ecx,%eax
  8020f2:	89 f2                	mov    %esi,%edx
  8020f4:	83 c4 1c             	add    $0x1c,%esp
  8020f7:	5b                   	pop    %ebx
  8020f8:	5e                   	pop    %esi
  8020f9:	5f                   	pop    %edi
  8020fa:	5d                   	pop    %ebp
  8020fb:	c3                   	ret    
  8020fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802100:	8b 34 24             	mov    (%esp),%esi
  802103:	bf 20 00 00 00       	mov    $0x20,%edi
  802108:	89 e9                	mov    %ebp,%ecx
  80210a:	29 ef                	sub    %ebp,%edi
  80210c:	d3 e0                	shl    %cl,%eax
  80210e:	89 f9                	mov    %edi,%ecx
  802110:	89 f2                	mov    %esi,%edx
  802112:	d3 ea                	shr    %cl,%edx
  802114:	89 e9                	mov    %ebp,%ecx
  802116:	09 c2                	or     %eax,%edx
  802118:	89 d8                	mov    %ebx,%eax
  80211a:	89 14 24             	mov    %edx,(%esp)
  80211d:	89 f2                	mov    %esi,%edx
  80211f:	d3 e2                	shl    %cl,%edx
  802121:	89 f9                	mov    %edi,%ecx
  802123:	89 54 24 04          	mov    %edx,0x4(%esp)
  802127:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80212b:	d3 e8                	shr    %cl,%eax
  80212d:	89 e9                	mov    %ebp,%ecx
  80212f:	89 c6                	mov    %eax,%esi
  802131:	d3 e3                	shl    %cl,%ebx
  802133:	89 f9                	mov    %edi,%ecx
  802135:	89 d0                	mov    %edx,%eax
  802137:	d3 e8                	shr    %cl,%eax
  802139:	89 e9                	mov    %ebp,%ecx
  80213b:	09 d8                	or     %ebx,%eax
  80213d:	89 d3                	mov    %edx,%ebx
  80213f:	89 f2                	mov    %esi,%edx
  802141:	f7 34 24             	divl   (%esp)
  802144:	89 d6                	mov    %edx,%esi
  802146:	d3 e3                	shl    %cl,%ebx
  802148:	f7 64 24 04          	mull   0x4(%esp)
  80214c:	39 d6                	cmp    %edx,%esi
  80214e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802152:	89 d1                	mov    %edx,%ecx
  802154:	89 c3                	mov    %eax,%ebx
  802156:	72 08                	jb     802160 <__umoddi3+0x110>
  802158:	75 11                	jne    80216b <__umoddi3+0x11b>
  80215a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80215e:	73 0b                	jae    80216b <__umoddi3+0x11b>
  802160:	2b 44 24 04          	sub    0x4(%esp),%eax
  802164:	1b 14 24             	sbb    (%esp),%edx
  802167:	89 d1                	mov    %edx,%ecx
  802169:	89 c3                	mov    %eax,%ebx
  80216b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80216f:	29 da                	sub    %ebx,%edx
  802171:	19 ce                	sbb    %ecx,%esi
  802173:	89 f9                	mov    %edi,%ecx
  802175:	89 f0                	mov    %esi,%eax
  802177:	d3 e0                	shl    %cl,%eax
  802179:	89 e9                	mov    %ebp,%ecx
  80217b:	d3 ea                	shr    %cl,%edx
  80217d:	89 e9                	mov    %ebp,%ecx
  80217f:	d3 ee                	shr    %cl,%esi
  802181:	09 d0                	or     %edx,%eax
  802183:	89 f2                	mov    %esi,%edx
  802185:	83 c4 1c             	add    $0x1c,%esp
  802188:	5b                   	pop    %ebx
  802189:	5e                   	pop    %esi
  80218a:	5f                   	pop    %edi
  80218b:	5d                   	pop    %ebp
  80218c:	c3                   	ret    
  80218d:	8d 76 00             	lea    0x0(%esi),%esi
  802190:	29 f9                	sub    %edi,%ecx
  802192:	19 d6                	sbb    %edx,%esi
  802194:	89 74 24 04          	mov    %esi,0x4(%esp)
  802198:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80219c:	e9 18 ff ff ff       	jmp    8020b9 <__umoddi3+0x69>
