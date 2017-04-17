
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
  80003c:	e8 d7 0f 00 00       	call   801018 <sfork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	74 42                	je     80008a <umain+0x57>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800048:	8b 1d 0c 40 80 00    	mov    0x80400c,%ebx
  80004e:	e8 e8 0a 00 00       	call   800b3b <sys_getenvid>
  800053:	83 ec 04             	sub    $0x4,%esp
  800056:	53                   	push   %ebx
  800057:	50                   	push   %eax
  800058:	68 40 26 80 00       	push   $0x802640
  80005d:	e8 8f 01 00 00       	call   8001f1 <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800062:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800065:	e8 d1 0a 00 00       	call   800b3b <sys_getenvid>
  80006a:	83 c4 0c             	add    $0xc,%esp
  80006d:	53                   	push   %ebx
  80006e:	50                   	push   %eax
  80006f:	68 5a 26 80 00       	push   $0x80265a
  800074:	e8 78 01 00 00       	call   8001f1 <cprintf>
		ipc_send(who, 0, 0, 0);
  800079:	6a 00                	push   $0x0
  80007b:	6a 00                	push   $0x0
  80007d:	6a 00                	push   $0x0
  80007f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800082:	e8 14 10 00 00       	call   80109b <ipc_send>
  800087:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  80008a:	83 ec 04             	sub    $0x4,%esp
  80008d:	6a 00                	push   $0x0
  80008f:	6a 00                	push   $0x0
  800091:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800094:	50                   	push   %eax
  800095:	e8 98 0f 00 00       	call   801032 <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  80009a:	8b 1d 0c 40 80 00    	mov    0x80400c,%ebx
  8000a0:	8b 7b 48             	mov    0x48(%ebx),%edi
  8000a3:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8000a6:	a1 08 40 80 00       	mov    0x804008,%eax
  8000ab:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8000ae:	e8 88 0a 00 00       	call   800b3b <sys_getenvid>
  8000b3:	83 c4 08             	add    $0x8,%esp
  8000b6:	57                   	push   %edi
  8000b7:	53                   	push   %ebx
  8000b8:	56                   	push   %esi
  8000b9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8000bc:	50                   	push   %eax
  8000bd:	68 70 26 80 00       	push   $0x802670
  8000c2:	e8 2a 01 00 00       	call   8001f1 <cprintf>
		if (val == 10)
  8000c7:	a1 08 40 80 00       	mov    0x804008,%eax
  8000cc:	83 c4 20             	add    $0x20,%esp
  8000cf:	83 f8 0a             	cmp    $0xa,%eax
  8000d2:	74 22                	je     8000f6 <umain+0xc3>
			return;
		++val;
  8000d4:	83 c0 01             	add    $0x1,%eax
  8000d7:	a3 08 40 80 00       	mov    %eax,0x804008
		ipc_send(who, 0, 0, 0);
  8000dc:	6a 00                	push   $0x0
  8000de:	6a 00                	push   $0x0
  8000e0:	6a 00                	push   $0x0
  8000e2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000e5:	e8 b1 0f 00 00       	call   80109b <ipc_send>
		if (val == 10)
  8000ea:	83 c4 10             	add    $0x10,%esp
  8000ed:	83 3d 08 40 80 00 0a 	cmpl   $0xa,0x804008
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
  80011b:	a3 0c 40 80 00       	mov    %eax,0x80400c

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
  80014a:	e8 a4 11 00 00       	call   8012f3 <close_all>
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
  800254:	e8 47 21 00 00       	call   8023a0 <__udivdi3>
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
  800297:	e8 34 22 00 00       	call   8024d0 <__umoddi3>
  80029c:	83 c4 14             	add    $0x14,%esp
  80029f:	0f be 80 a0 26 80 00 	movsbl 0x8026a0(%eax),%eax
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
  80039b:	ff 24 85 e0 27 80 00 	jmp    *0x8027e0(,%eax,4)
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
  80045f:	8b 14 85 40 29 80 00 	mov    0x802940(,%eax,4),%edx
  800466:	85 d2                	test   %edx,%edx
  800468:	75 18                	jne    800482 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80046a:	50                   	push   %eax
  80046b:	68 b8 26 80 00       	push   $0x8026b8
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
  800483:	68 0e 2b 80 00       	push   $0x802b0e
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
  8004a7:	b8 b1 26 80 00       	mov    $0x8026b1,%eax
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
  800b22:	68 9f 29 80 00       	push   $0x80299f
  800b27:	6a 23                	push   $0x23
  800b29:	68 bc 29 80 00       	push   $0x8029bc
  800b2e:	e8 6f 17 00 00       	call   8022a2 <_panic>

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
  800ba3:	68 9f 29 80 00       	push   $0x80299f
  800ba8:	6a 23                	push   $0x23
  800baa:	68 bc 29 80 00       	push   $0x8029bc
  800baf:	e8 ee 16 00 00       	call   8022a2 <_panic>

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
  800be5:	68 9f 29 80 00       	push   $0x80299f
  800bea:	6a 23                	push   $0x23
  800bec:	68 bc 29 80 00       	push   $0x8029bc
  800bf1:	e8 ac 16 00 00       	call   8022a2 <_panic>

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
  800c27:	68 9f 29 80 00       	push   $0x80299f
  800c2c:	6a 23                	push   $0x23
  800c2e:	68 bc 29 80 00       	push   $0x8029bc
  800c33:	e8 6a 16 00 00       	call   8022a2 <_panic>

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
  800c69:	68 9f 29 80 00       	push   $0x80299f
  800c6e:	6a 23                	push   $0x23
  800c70:	68 bc 29 80 00       	push   $0x8029bc
  800c75:	e8 28 16 00 00       	call   8022a2 <_panic>

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
  800cab:	68 9f 29 80 00       	push   $0x80299f
  800cb0:	6a 23                	push   $0x23
  800cb2:	68 bc 29 80 00       	push   $0x8029bc
  800cb7:	e8 e6 15 00 00       	call   8022a2 <_panic>

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
  800ced:	68 9f 29 80 00       	push   $0x80299f
  800cf2:	6a 23                	push   $0x23
  800cf4:	68 bc 29 80 00       	push   $0x8029bc
  800cf9:	e8 a4 15 00 00       	call   8022a2 <_panic>

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
  800d51:	68 9f 29 80 00       	push   $0x80299f
  800d56:	6a 23                	push   $0x23
  800d58:	68 bc 29 80 00       	push   $0x8029bc
  800d5d:	e8 40 15 00 00       	call   8022a2 <_panic>

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

00800d6a <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d6a:	55                   	push   %ebp
  800d6b:	89 e5                	mov    %esp,%ebp
  800d6d:	57                   	push   %edi
  800d6e:	56                   	push   %esi
  800d6f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d70:	ba 00 00 00 00       	mov    $0x0,%edx
  800d75:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d7a:	89 d1                	mov    %edx,%ecx
  800d7c:	89 d3                	mov    %edx,%ebx
  800d7e:	89 d7                	mov    %edx,%edi
  800d80:	89 d6                	mov    %edx,%esi
  800d82:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d84:	5b                   	pop    %ebx
  800d85:	5e                   	pop    %esi
  800d86:	5f                   	pop    %edi
  800d87:	5d                   	pop    %ebp
  800d88:	c3                   	ret    

00800d89 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800d89:	55                   	push   %ebp
  800d8a:	89 e5                	mov    %esp,%ebp
  800d8c:	53                   	push   %ebx
  800d8d:	83 ec 04             	sub    $0x4,%esp
	int r;
	void * address = (void *)(pn*PGSIZE);
  800d90:	89 d3                	mov    %edx,%ebx
  800d92:	c1 e3 0c             	shl    $0xc,%ebx
	
	if((uvpt[pn] & PTE_SHARE))
  800d95:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800d9c:	f6 c5 04             	test   $0x4,%ch
  800d9f:	74 38                	je     800dd9 <duppage+0x50>
	{
		if ((r = sys_page_map(0, address, envid, address, (uvpt[pn] | PTE_SYSCALL))) < 0)
  800da1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800da8:	83 ec 0c             	sub    $0xc,%esp
  800dab:	81 ca 07 0e 00 00    	or     $0xe07,%edx
  800db1:	52                   	push   %edx
  800db2:	53                   	push   %ebx
  800db3:	50                   	push   %eax
  800db4:	53                   	push   %ebx
  800db5:	6a 00                	push   $0x0
  800db7:	e8 00 fe ff ff       	call   800bbc <sys_page_map>
  800dbc:	83 c4 20             	add    $0x20,%esp
  800dbf:	85 c0                	test   %eax,%eax
  800dc1:	0f 89 b8 00 00 00    	jns    800e7f <duppage+0xf6>
			panic("sys_page_map: %e", r);
  800dc7:	50                   	push   %eax
  800dc8:	68 ca 29 80 00       	push   $0x8029ca
  800dcd:	6a 4e                	push   $0x4e
  800dcf:	68 db 29 80 00       	push   $0x8029db
  800dd4:	e8 c9 14 00 00       	call   8022a2 <_panic>
	}
	else if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW))
  800dd9:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800de0:	f6 c1 02             	test   $0x2,%cl
  800de3:	75 0c                	jne    800df1 <duppage+0x68>
  800de5:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800dec:	f6 c5 08             	test   $0x8,%ch
  800def:	74 57                	je     800e48 <duppage+0xbf>
	{
		int perm = 0;
		perm |= PTE_P|PTE_U|PTE_COW;
	
		if ((r = sys_page_map(0, address, envid, address, perm)) < 0)
  800df1:	83 ec 0c             	sub    $0xc,%esp
  800df4:	68 05 08 00 00       	push   $0x805
  800df9:	53                   	push   %ebx
  800dfa:	50                   	push   %eax
  800dfb:	53                   	push   %ebx
  800dfc:	6a 00                	push   $0x0
  800dfe:	e8 b9 fd ff ff       	call   800bbc <sys_page_map>
  800e03:	83 c4 20             	add    $0x20,%esp
  800e06:	85 c0                	test   %eax,%eax
  800e08:	79 12                	jns    800e1c <duppage+0x93>
			panic("sys_page_map: %e", r);
  800e0a:	50                   	push   %eax
  800e0b:	68 ca 29 80 00       	push   $0x8029ca
  800e10:	6a 56                	push   $0x56
  800e12:	68 db 29 80 00       	push   $0x8029db
  800e17:	e8 86 14 00 00       	call   8022a2 <_panic>
		if ((r = sys_page_map(0, address, 0, address, perm)) < 0)
  800e1c:	83 ec 0c             	sub    $0xc,%esp
  800e1f:	68 05 08 00 00       	push   $0x805
  800e24:	53                   	push   %ebx
  800e25:	6a 00                	push   $0x0
  800e27:	53                   	push   %ebx
  800e28:	6a 00                	push   $0x0
  800e2a:	e8 8d fd ff ff       	call   800bbc <sys_page_map>
  800e2f:	83 c4 20             	add    $0x20,%esp
  800e32:	85 c0                	test   %eax,%eax
  800e34:	79 49                	jns    800e7f <duppage+0xf6>
			panic("sys_page_map: %e", r);
  800e36:	50                   	push   %eax
  800e37:	68 ca 29 80 00       	push   $0x8029ca
  800e3c:	6a 58                	push   $0x58
  800e3e:	68 db 29 80 00       	push   $0x8029db
  800e43:	e8 5a 14 00 00       	call   8022a2 <_panic>
	}
	else if((uvpt[pn] & ~PTE_U) == 0)
  800e48:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e4f:	f7 c2 fb ff ff ff    	test   $0xfffffffb,%edx
  800e55:	75 28                	jne    800e7f <duppage+0xf6>
	{
		//cprintf("im here");
		if ((r = sys_page_map(0, address, envid, address, PTE_P|PTE_U)) < 0)
  800e57:	83 ec 0c             	sub    $0xc,%esp
  800e5a:	6a 05                	push   $0x5
  800e5c:	53                   	push   %ebx
  800e5d:	50                   	push   %eax
  800e5e:	53                   	push   %ebx
  800e5f:	6a 00                	push   $0x0
  800e61:	e8 56 fd ff ff       	call   800bbc <sys_page_map>
  800e66:	83 c4 20             	add    $0x20,%esp
  800e69:	85 c0                	test   %eax,%eax
  800e6b:	79 12                	jns    800e7f <duppage+0xf6>
			panic("sys_page_map: %e", r);	
  800e6d:	50                   	push   %eax
  800e6e:	68 ca 29 80 00       	push   $0x8029ca
  800e73:	6a 5e                	push   $0x5e
  800e75:	68 db 29 80 00       	push   $0x8029db
  800e7a:	e8 23 14 00 00       	call   8022a2 <_panic>
	}
	return 0;
}
  800e7f:	b8 00 00 00 00       	mov    $0x0,%eax
  800e84:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e87:	c9                   	leave  
  800e88:	c3                   	ret    

00800e89 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e89:	55                   	push   %ebp
  800e8a:	89 e5                	mov    %esp,%ebp
  800e8c:	53                   	push   %ebx
  800e8d:	83 ec 08             	sub    $0x8,%esp
	void *addr = (void *) utf->utf_fault_va;
  800e90:	8b 45 08             	mov    0x8(%ebp),%eax
  800e93:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	unsigned pn = ((uint32_t)addr)/PGSIZE;
  800e95:	89 d8                	mov    %ebx,%eax
  800e97:	c1 e8 0c             	shr    $0xc,%eax
	pte_t pte = uvpt[pn];
  800e9a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// Allocate a new page, mapped at temp location
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  800ea1:	6a 07                	push   $0x7
  800ea3:	68 00 f0 7f 00       	push   $0x7ff000
  800ea8:	6a 00                	push   $0x0
  800eaa:	e8 ca fc ff ff       	call   800b79 <sys_page_alloc>
  800eaf:	83 c4 10             	add    $0x10,%esp
  800eb2:	85 c0                	test   %eax,%eax
  800eb4:	79 12                	jns    800ec8 <pgfault+0x3f>
		panic("sys_page_alloc: %e", r);
  800eb6:	50                   	push   %eax
  800eb7:	68 e6 29 80 00       	push   $0x8029e6
  800ebc:	6a 2b                	push   $0x2b
  800ebe:	68 db 29 80 00       	push   $0x8029db
  800ec3:	e8 da 13 00 00       	call   8022a2 <_panic>

	// Copy the data from the old page to this new page
	void *addr_pgstart = (void *) ROUNDDOWN(addr, PGSIZE);
  800ec8:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr_pgstart, PGSIZE);
  800ece:	83 ec 04             	sub    $0x4,%esp
  800ed1:	68 00 10 00 00       	push   $0x1000
  800ed6:	53                   	push   %ebx
  800ed7:	68 00 f0 7f 00       	push   $0x7ff000
  800edc:	e8 27 fa ff ff       	call   800908 <memmove>

	// Move the new page to the old page's address
	if ((r = sys_page_map(0, PFTEMP, 0, addr_pgstart, PTE_P|PTE_U|PTE_W)) < 0)
  800ee1:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800ee8:	53                   	push   %ebx
  800ee9:	6a 00                	push   $0x0
  800eeb:	68 00 f0 7f 00       	push   $0x7ff000
  800ef0:	6a 00                	push   $0x0
  800ef2:	e8 c5 fc ff ff       	call   800bbc <sys_page_map>
  800ef7:	83 c4 20             	add    $0x20,%esp
  800efa:	85 c0                	test   %eax,%eax
  800efc:	79 12                	jns    800f10 <pgfault+0x87>
		panic("sys_page_map: %e", r);
  800efe:	50                   	push   %eax
  800eff:	68 ca 29 80 00       	push   $0x8029ca
  800f04:	6a 33                	push   $0x33
  800f06:	68 db 29 80 00       	push   $0x8029db
  800f0b:	e8 92 13 00 00       	call   8022a2 <_panic>

	// Unmap the temp location
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800f10:	83 ec 08             	sub    $0x8,%esp
  800f13:	68 00 f0 7f 00       	push   $0x7ff000
  800f18:	6a 00                	push   $0x0
  800f1a:	e8 df fc ff ff       	call   800bfe <sys_page_unmap>
  800f1f:	83 c4 10             	add    $0x10,%esp
  800f22:	85 c0                	test   %eax,%eax
  800f24:	79 12                	jns    800f38 <pgfault+0xaf>
		panic("sys_page_unmap: %e", r);
  800f26:	50                   	push   %eax
  800f27:	68 f9 29 80 00       	push   $0x8029f9
  800f2c:	6a 37                	push   $0x37
  800f2e:	68 db 29 80 00       	push   $0x8029db
  800f33:	e8 6a 13 00 00       	call   8022a2 <_panic>
}
  800f38:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f3b:	c9                   	leave  
  800f3c:	c3                   	ret    

00800f3d <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f3d:	55                   	push   %ebp
  800f3e:	89 e5                	mov    %esp,%ebp
  800f40:	56                   	push   %esi
  800f41:	53                   	push   %ebx
  800f42:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
	// Set up page fault handler
	set_pgfault_handler(&pgfault);
  800f45:	68 89 0e 80 00       	push   $0x800e89
  800f4a:	e8 99 13 00 00       	call   8022e8 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f4f:	b8 07 00 00 00       	mov    $0x7,%eax
  800f54:	cd 30                	int    $0x30

	// Create child
	envid_t envid = sys_exofork();
  800f56:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (envid < 0) {
  800f59:	83 c4 10             	add    $0x10,%esp
  800f5c:	85 c0                	test   %eax,%eax
  800f5e:	79 12                	jns    800f72 <fork+0x35>
		panic("sys_exofork: %e", envid);
  800f60:	50                   	push   %eax
  800f61:	68 0c 2a 80 00       	push   $0x802a0c
  800f66:	6a 7c                	push   $0x7c
  800f68:	68 db 29 80 00       	push   $0x8029db
  800f6d:	e8 30 13 00 00       	call   8022a2 <_panic>
		return envid;
	}
	if (envid == 0) {
  800f72:	85 c0                	test   %eax,%eax
  800f74:	75 1e                	jne    800f94 <fork+0x57>
		// We are the child.
		thisenv = &envs[ENVX(sys_getenvid())]; // Fix thisenv
  800f76:	e8 c0 fb ff ff       	call   800b3b <sys_getenvid>
  800f7b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f80:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f83:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f88:	a3 0c 40 80 00       	mov    %eax,0x80400c
		return 0;
  800f8d:	b8 00 00 00 00       	mov    $0x0,%eax
  800f92:	eb 7d                	jmp    801011 <fork+0xd4>

	// Set page fault handler on the child.
	// The parent needs to do it, else the child wouldn't be able to handle
	// the fault when trying to access it's stack (which happens as soon it starts)
	extern void _pgfault_upcall(void);
	sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);
  800f94:	83 ec 04             	sub    $0x4,%esp
  800f97:	6a 07                	push   $0x7
  800f99:	68 00 f0 bf ee       	push   $0xeebff000
  800f9e:	50                   	push   %eax
  800f9f:	e8 d5 fb ff ff       	call   800b79 <sys_page_alloc>
	sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  800fa4:	83 c4 08             	add    $0x8,%esp
  800fa7:	68 2d 23 80 00       	push   $0x80232d
  800fac:	ff 75 f4             	pushl  -0xc(%ebp)
  800faf:	e8 10 fd ff ff       	call   800cc4 <sys_env_set_pgfault_upcall>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  800fb4:	be 04 70 80 00       	mov    $0x807004,%esi
  800fb9:	c1 ee 0c             	shr    $0xc,%esi
  800fbc:	83 c4 10             	add    $0x10,%esp
  800fbf:	bb 00 08 00 00       	mov    $0x800,%ebx
  800fc4:	eb 0d                	jmp    800fd3 <fork+0x96>
		duppage(envid, pn);
  800fc6:	89 da                	mov    %ebx,%edx
  800fc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fcb:	e8 b9 fd ff ff       	call   800d89 <duppage>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  800fd0:	83 c3 01             	add    $0x1,%ebx
  800fd3:	39 f3                	cmp    %esi,%ebx
  800fd5:	76 ef                	jbe    800fc6 <fork+0x89>
	}

	// Also copy the stack we are currently running on
	// I think it should loop from ustacktop to this page, since the stack
	// can have more than 1 page
	duppage(envid, ((uint32_t) &envid)/PGSIZE);
  800fd7:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800fda:	c1 ea 0c             	shr    $0xc,%edx
  800fdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fe0:	e8 a4 fd ff ff       	call   800d89 <duppage>

	// Start the child environmnet running
	int r;
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  800fe5:	83 ec 08             	sub    $0x8,%esp
  800fe8:	6a 02                	push   $0x2
  800fea:	ff 75 f4             	pushl  -0xc(%ebp)
  800fed:	e8 4e fc ff ff       	call   800c40 <sys_env_set_status>
  800ff2:	83 c4 10             	add    $0x10,%esp
  800ff5:	85 c0                	test   %eax,%eax
  800ff7:	79 15                	jns    80100e <fork+0xd1>
		panic("sys_env_set_status: %e", r);
  800ff9:	50                   	push   %eax
  800ffa:	68 1c 2a 80 00       	push   $0x802a1c
  800fff:	68 9c 00 00 00       	push   $0x9c
  801004:	68 db 29 80 00       	push   $0x8029db
  801009:	e8 94 12 00 00       	call   8022a2 <_panic>
		return r;
	}

	return envid;
  80100e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  801011:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801014:	5b                   	pop    %ebx
  801015:	5e                   	pop    %esi
  801016:	5d                   	pop    %ebp
  801017:	c3                   	ret    

00801018 <sfork>:

// Challenge!
int
sfork(void)
{
  801018:	55                   	push   %ebp
  801019:	89 e5                	mov    %esp,%ebp
  80101b:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80101e:	68 33 2a 80 00       	push   $0x802a33
  801023:	68 a7 00 00 00       	push   $0xa7
  801028:	68 db 29 80 00       	push   $0x8029db
  80102d:	e8 70 12 00 00       	call   8022a2 <_panic>

00801032 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801032:	55                   	push   %ebp
  801033:	89 e5                	mov    %esp,%ebp
  801035:	56                   	push   %esi
  801036:	53                   	push   %ebx
  801037:	8b 75 08             	mov    0x8(%ebp),%esi
  80103a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80103d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  801040:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801042:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801047:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  80104a:	83 ec 0c             	sub    $0xc,%esp
  80104d:	50                   	push   %eax
  80104e:	e8 d6 fc ff ff       	call   800d29 <sys_ipc_recv>

	if (r < 0) {
  801053:	83 c4 10             	add    $0x10,%esp
  801056:	85 c0                	test   %eax,%eax
  801058:	79 16                	jns    801070 <ipc_recv+0x3e>
		if (from_env_store)
  80105a:	85 f6                	test   %esi,%esi
  80105c:	74 06                	je     801064 <ipc_recv+0x32>
			*from_env_store = 0;
  80105e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  801064:	85 db                	test   %ebx,%ebx
  801066:	74 2c                	je     801094 <ipc_recv+0x62>
			*perm_store = 0;
  801068:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80106e:	eb 24                	jmp    801094 <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  801070:	85 f6                	test   %esi,%esi
  801072:	74 0a                	je     80107e <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  801074:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801079:	8b 40 74             	mov    0x74(%eax),%eax
  80107c:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  80107e:	85 db                	test   %ebx,%ebx
  801080:	74 0a                	je     80108c <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  801082:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801087:	8b 40 78             	mov    0x78(%eax),%eax
  80108a:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  80108c:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801091:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  801094:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801097:	5b                   	pop    %ebx
  801098:	5e                   	pop    %esi
  801099:	5d                   	pop    %ebp
  80109a:	c3                   	ret    

0080109b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80109b:	55                   	push   %ebp
  80109c:	89 e5                	mov    %esp,%ebp
  80109e:	57                   	push   %edi
  80109f:	56                   	push   %esi
  8010a0:	53                   	push   %ebx
  8010a1:	83 ec 0c             	sub    $0xc,%esp
  8010a4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010a7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010aa:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  8010ad:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  8010af:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  8010b4:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  8010b7:	ff 75 14             	pushl  0x14(%ebp)
  8010ba:	53                   	push   %ebx
  8010bb:	56                   	push   %esi
  8010bc:	57                   	push   %edi
  8010bd:	e8 44 fc ff ff       	call   800d06 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  8010c2:	83 c4 10             	add    $0x10,%esp
  8010c5:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8010c8:	75 07                	jne    8010d1 <ipc_send+0x36>
			sys_yield();
  8010ca:	e8 8b fa ff ff       	call   800b5a <sys_yield>
  8010cf:	eb e6                	jmp    8010b7 <ipc_send+0x1c>
		} else if (r < 0) {
  8010d1:	85 c0                	test   %eax,%eax
  8010d3:	79 12                	jns    8010e7 <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  8010d5:	50                   	push   %eax
  8010d6:	68 49 2a 80 00       	push   $0x802a49
  8010db:	6a 51                	push   $0x51
  8010dd:	68 56 2a 80 00       	push   $0x802a56
  8010e2:	e8 bb 11 00 00       	call   8022a2 <_panic>
		}
	}
}
  8010e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010ea:	5b                   	pop    %ebx
  8010eb:	5e                   	pop    %esi
  8010ec:	5f                   	pop    %edi
  8010ed:	5d                   	pop    %ebp
  8010ee:	c3                   	ret    

008010ef <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8010ef:	55                   	push   %ebp
  8010f0:	89 e5                	mov    %esp,%ebp
  8010f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8010f5:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8010fa:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8010fd:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801103:	8b 52 50             	mov    0x50(%edx),%edx
  801106:	39 ca                	cmp    %ecx,%edx
  801108:	75 0d                	jne    801117 <ipc_find_env+0x28>
			return envs[i].env_id;
  80110a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80110d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801112:	8b 40 48             	mov    0x48(%eax),%eax
  801115:	eb 0f                	jmp    801126 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801117:	83 c0 01             	add    $0x1,%eax
  80111a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80111f:	75 d9                	jne    8010fa <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801121:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801126:	5d                   	pop    %ebp
  801127:	c3                   	ret    

00801128 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801128:	55                   	push   %ebp
  801129:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80112b:	8b 45 08             	mov    0x8(%ebp),%eax
  80112e:	05 00 00 00 30       	add    $0x30000000,%eax
  801133:	c1 e8 0c             	shr    $0xc,%eax
}
  801136:	5d                   	pop    %ebp
  801137:	c3                   	ret    

00801138 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801138:	55                   	push   %ebp
  801139:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80113b:	8b 45 08             	mov    0x8(%ebp),%eax
  80113e:	05 00 00 00 30       	add    $0x30000000,%eax
  801143:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801148:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80114d:	5d                   	pop    %ebp
  80114e:	c3                   	ret    

0080114f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80114f:	55                   	push   %ebp
  801150:	89 e5                	mov    %esp,%ebp
  801152:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801155:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80115a:	89 c2                	mov    %eax,%edx
  80115c:	c1 ea 16             	shr    $0x16,%edx
  80115f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801166:	f6 c2 01             	test   $0x1,%dl
  801169:	74 11                	je     80117c <fd_alloc+0x2d>
  80116b:	89 c2                	mov    %eax,%edx
  80116d:	c1 ea 0c             	shr    $0xc,%edx
  801170:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801177:	f6 c2 01             	test   $0x1,%dl
  80117a:	75 09                	jne    801185 <fd_alloc+0x36>
			*fd_store = fd;
  80117c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80117e:	b8 00 00 00 00       	mov    $0x0,%eax
  801183:	eb 17                	jmp    80119c <fd_alloc+0x4d>
  801185:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80118a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80118f:	75 c9                	jne    80115a <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801191:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801197:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80119c:	5d                   	pop    %ebp
  80119d:	c3                   	ret    

0080119e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80119e:	55                   	push   %ebp
  80119f:	89 e5                	mov    %esp,%ebp
  8011a1:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011a4:	83 f8 1f             	cmp    $0x1f,%eax
  8011a7:	77 36                	ja     8011df <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011a9:	c1 e0 0c             	shl    $0xc,%eax
  8011ac:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011b1:	89 c2                	mov    %eax,%edx
  8011b3:	c1 ea 16             	shr    $0x16,%edx
  8011b6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011bd:	f6 c2 01             	test   $0x1,%dl
  8011c0:	74 24                	je     8011e6 <fd_lookup+0x48>
  8011c2:	89 c2                	mov    %eax,%edx
  8011c4:	c1 ea 0c             	shr    $0xc,%edx
  8011c7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011ce:	f6 c2 01             	test   $0x1,%dl
  8011d1:	74 1a                	je     8011ed <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011d3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011d6:	89 02                	mov    %eax,(%edx)
	return 0;
  8011d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8011dd:	eb 13                	jmp    8011f2 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011df:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011e4:	eb 0c                	jmp    8011f2 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011e6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011eb:	eb 05                	jmp    8011f2 <fd_lookup+0x54>
  8011ed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8011f2:	5d                   	pop    %ebp
  8011f3:	c3                   	ret    

008011f4 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011f4:	55                   	push   %ebp
  8011f5:	89 e5                	mov    %esp,%ebp
  8011f7:	83 ec 08             	sub    $0x8,%esp
  8011fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011fd:	ba dc 2a 80 00       	mov    $0x802adc,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801202:	eb 13                	jmp    801217 <dev_lookup+0x23>
  801204:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801207:	39 08                	cmp    %ecx,(%eax)
  801209:	75 0c                	jne    801217 <dev_lookup+0x23>
			*dev = devtab[i];
  80120b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80120e:	89 01                	mov    %eax,(%ecx)
			return 0;
  801210:	b8 00 00 00 00       	mov    $0x0,%eax
  801215:	eb 2e                	jmp    801245 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801217:	8b 02                	mov    (%edx),%eax
  801219:	85 c0                	test   %eax,%eax
  80121b:	75 e7                	jne    801204 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80121d:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801222:	8b 40 48             	mov    0x48(%eax),%eax
  801225:	83 ec 04             	sub    $0x4,%esp
  801228:	51                   	push   %ecx
  801229:	50                   	push   %eax
  80122a:	68 60 2a 80 00       	push   $0x802a60
  80122f:	e8 bd ef ff ff       	call   8001f1 <cprintf>
	*dev = 0;
  801234:	8b 45 0c             	mov    0xc(%ebp),%eax
  801237:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80123d:	83 c4 10             	add    $0x10,%esp
  801240:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801245:	c9                   	leave  
  801246:	c3                   	ret    

00801247 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801247:	55                   	push   %ebp
  801248:	89 e5                	mov    %esp,%ebp
  80124a:	56                   	push   %esi
  80124b:	53                   	push   %ebx
  80124c:	83 ec 10             	sub    $0x10,%esp
  80124f:	8b 75 08             	mov    0x8(%ebp),%esi
  801252:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801255:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801258:	50                   	push   %eax
  801259:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80125f:	c1 e8 0c             	shr    $0xc,%eax
  801262:	50                   	push   %eax
  801263:	e8 36 ff ff ff       	call   80119e <fd_lookup>
  801268:	83 c4 08             	add    $0x8,%esp
  80126b:	85 c0                	test   %eax,%eax
  80126d:	78 05                	js     801274 <fd_close+0x2d>
	    || fd != fd2)
  80126f:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801272:	74 0c                	je     801280 <fd_close+0x39>
		return (must_exist ? r : 0);
  801274:	84 db                	test   %bl,%bl
  801276:	ba 00 00 00 00       	mov    $0x0,%edx
  80127b:	0f 44 c2             	cmove  %edx,%eax
  80127e:	eb 41                	jmp    8012c1 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801280:	83 ec 08             	sub    $0x8,%esp
  801283:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801286:	50                   	push   %eax
  801287:	ff 36                	pushl  (%esi)
  801289:	e8 66 ff ff ff       	call   8011f4 <dev_lookup>
  80128e:	89 c3                	mov    %eax,%ebx
  801290:	83 c4 10             	add    $0x10,%esp
  801293:	85 c0                	test   %eax,%eax
  801295:	78 1a                	js     8012b1 <fd_close+0x6a>
		if (dev->dev_close)
  801297:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80129a:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80129d:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012a2:	85 c0                	test   %eax,%eax
  8012a4:	74 0b                	je     8012b1 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012a6:	83 ec 0c             	sub    $0xc,%esp
  8012a9:	56                   	push   %esi
  8012aa:	ff d0                	call   *%eax
  8012ac:	89 c3                	mov    %eax,%ebx
  8012ae:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012b1:	83 ec 08             	sub    $0x8,%esp
  8012b4:	56                   	push   %esi
  8012b5:	6a 00                	push   $0x0
  8012b7:	e8 42 f9 ff ff       	call   800bfe <sys_page_unmap>
	return r;
  8012bc:	83 c4 10             	add    $0x10,%esp
  8012bf:	89 d8                	mov    %ebx,%eax
}
  8012c1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012c4:	5b                   	pop    %ebx
  8012c5:	5e                   	pop    %esi
  8012c6:	5d                   	pop    %ebp
  8012c7:	c3                   	ret    

008012c8 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012c8:	55                   	push   %ebp
  8012c9:	89 e5                	mov    %esp,%ebp
  8012cb:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012d1:	50                   	push   %eax
  8012d2:	ff 75 08             	pushl  0x8(%ebp)
  8012d5:	e8 c4 fe ff ff       	call   80119e <fd_lookup>
  8012da:	83 c4 08             	add    $0x8,%esp
  8012dd:	85 c0                	test   %eax,%eax
  8012df:	78 10                	js     8012f1 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8012e1:	83 ec 08             	sub    $0x8,%esp
  8012e4:	6a 01                	push   $0x1
  8012e6:	ff 75 f4             	pushl  -0xc(%ebp)
  8012e9:	e8 59 ff ff ff       	call   801247 <fd_close>
  8012ee:	83 c4 10             	add    $0x10,%esp
}
  8012f1:	c9                   	leave  
  8012f2:	c3                   	ret    

008012f3 <close_all>:

void
close_all(void)
{
  8012f3:	55                   	push   %ebp
  8012f4:	89 e5                	mov    %esp,%ebp
  8012f6:	53                   	push   %ebx
  8012f7:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012fa:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012ff:	83 ec 0c             	sub    $0xc,%esp
  801302:	53                   	push   %ebx
  801303:	e8 c0 ff ff ff       	call   8012c8 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801308:	83 c3 01             	add    $0x1,%ebx
  80130b:	83 c4 10             	add    $0x10,%esp
  80130e:	83 fb 20             	cmp    $0x20,%ebx
  801311:	75 ec                	jne    8012ff <close_all+0xc>
		close(i);
}
  801313:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801316:	c9                   	leave  
  801317:	c3                   	ret    

00801318 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801318:	55                   	push   %ebp
  801319:	89 e5                	mov    %esp,%ebp
  80131b:	57                   	push   %edi
  80131c:	56                   	push   %esi
  80131d:	53                   	push   %ebx
  80131e:	83 ec 2c             	sub    $0x2c,%esp
  801321:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801324:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801327:	50                   	push   %eax
  801328:	ff 75 08             	pushl  0x8(%ebp)
  80132b:	e8 6e fe ff ff       	call   80119e <fd_lookup>
  801330:	83 c4 08             	add    $0x8,%esp
  801333:	85 c0                	test   %eax,%eax
  801335:	0f 88 c1 00 00 00    	js     8013fc <dup+0xe4>
		return r;
	close(newfdnum);
  80133b:	83 ec 0c             	sub    $0xc,%esp
  80133e:	56                   	push   %esi
  80133f:	e8 84 ff ff ff       	call   8012c8 <close>

	newfd = INDEX2FD(newfdnum);
  801344:	89 f3                	mov    %esi,%ebx
  801346:	c1 e3 0c             	shl    $0xc,%ebx
  801349:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80134f:	83 c4 04             	add    $0x4,%esp
  801352:	ff 75 e4             	pushl  -0x1c(%ebp)
  801355:	e8 de fd ff ff       	call   801138 <fd2data>
  80135a:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80135c:	89 1c 24             	mov    %ebx,(%esp)
  80135f:	e8 d4 fd ff ff       	call   801138 <fd2data>
  801364:	83 c4 10             	add    $0x10,%esp
  801367:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80136a:	89 f8                	mov    %edi,%eax
  80136c:	c1 e8 16             	shr    $0x16,%eax
  80136f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801376:	a8 01                	test   $0x1,%al
  801378:	74 37                	je     8013b1 <dup+0x99>
  80137a:	89 f8                	mov    %edi,%eax
  80137c:	c1 e8 0c             	shr    $0xc,%eax
  80137f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801386:	f6 c2 01             	test   $0x1,%dl
  801389:	74 26                	je     8013b1 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80138b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801392:	83 ec 0c             	sub    $0xc,%esp
  801395:	25 07 0e 00 00       	and    $0xe07,%eax
  80139a:	50                   	push   %eax
  80139b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80139e:	6a 00                	push   $0x0
  8013a0:	57                   	push   %edi
  8013a1:	6a 00                	push   $0x0
  8013a3:	e8 14 f8 ff ff       	call   800bbc <sys_page_map>
  8013a8:	89 c7                	mov    %eax,%edi
  8013aa:	83 c4 20             	add    $0x20,%esp
  8013ad:	85 c0                	test   %eax,%eax
  8013af:	78 2e                	js     8013df <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013b1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013b4:	89 d0                	mov    %edx,%eax
  8013b6:	c1 e8 0c             	shr    $0xc,%eax
  8013b9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013c0:	83 ec 0c             	sub    $0xc,%esp
  8013c3:	25 07 0e 00 00       	and    $0xe07,%eax
  8013c8:	50                   	push   %eax
  8013c9:	53                   	push   %ebx
  8013ca:	6a 00                	push   $0x0
  8013cc:	52                   	push   %edx
  8013cd:	6a 00                	push   $0x0
  8013cf:	e8 e8 f7 ff ff       	call   800bbc <sys_page_map>
  8013d4:	89 c7                	mov    %eax,%edi
  8013d6:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8013d9:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013db:	85 ff                	test   %edi,%edi
  8013dd:	79 1d                	jns    8013fc <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013df:	83 ec 08             	sub    $0x8,%esp
  8013e2:	53                   	push   %ebx
  8013e3:	6a 00                	push   $0x0
  8013e5:	e8 14 f8 ff ff       	call   800bfe <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013ea:	83 c4 08             	add    $0x8,%esp
  8013ed:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013f0:	6a 00                	push   $0x0
  8013f2:	e8 07 f8 ff ff       	call   800bfe <sys_page_unmap>
	return r;
  8013f7:	83 c4 10             	add    $0x10,%esp
  8013fa:	89 f8                	mov    %edi,%eax
}
  8013fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013ff:	5b                   	pop    %ebx
  801400:	5e                   	pop    %esi
  801401:	5f                   	pop    %edi
  801402:	5d                   	pop    %ebp
  801403:	c3                   	ret    

00801404 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801404:	55                   	push   %ebp
  801405:	89 e5                	mov    %esp,%ebp
  801407:	53                   	push   %ebx
  801408:	83 ec 14             	sub    $0x14,%esp
  80140b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80140e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801411:	50                   	push   %eax
  801412:	53                   	push   %ebx
  801413:	e8 86 fd ff ff       	call   80119e <fd_lookup>
  801418:	83 c4 08             	add    $0x8,%esp
  80141b:	89 c2                	mov    %eax,%edx
  80141d:	85 c0                	test   %eax,%eax
  80141f:	78 6d                	js     80148e <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801421:	83 ec 08             	sub    $0x8,%esp
  801424:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801427:	50                   	push   %eax
  801428:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80142b:	ff 30                	pushl  (%eax)
  80142d:	e8 c2 fd ff ff       	call   8011f4 <dev_lookup>
  801432:	83 c4 10             	add    $0x10,%esp
  801435:	85 c0                	test   %eax,%eax
  801437:	78 4c                	js     801485 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801439:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80143c:	8b 42 08             	mov    0x8(%edx),%eax
  80143f:	83 e0 03             	and    $0x3,%eax
  801442:	83 f8 01             	cmp    $0x1,%eax
  801445:	75 21                	jne    801468 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801447:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80144c:	8b 40 48             	mov    0x48(%eax),%eax
  80144f:	83 ec 04             	sub    $0x4,%esp
  801452:	53                   	push   %ebx
  801453:	50                   	push   %eax
  801454:	68 a1 2a 80 00       	push   $0x802aa1
  801459:	e8 93 ed ff ff       	call   8001f1 <cprintf>
		return -E_INVAL;
  80145e:	83 c4 10             	add    $0x10,%esp
  801461:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801466:	eb 26                	jmp    80148e <read+0x8a>
	}
	if (!dev->dev_read)
  801468:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80146b:	8b 40 08             	mov    0x8(%eax),%eax
  80146e:	85 c0                	test   %eax,%eax
  801470:	74 17                	je     801489 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801472:	83 ec 04             	sub    $0x4,%esp
  801475:	ff 75 10             	pushl  0x10(%ebp)
  801478:	ff 75 0c             	pushl  0xc(%ebp)
  80147b:	52                   	push   %edx
  80147c:	ff d0                	call   *%eax
  80147e:	89 c2                	mov    %eax,%edx
  801480:	83 c4 10             	add    $0x10,%esp
  801483:	eb 09                	jmp    80148e <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801485:	89 c2                	mov    %eax,%edx
  801487:	eb 05                	jmp    80148e <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801489:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80148e:	89 d0                	mov    %edx,%eax
  801490:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801493:	c9                   	leave  
  801494:	c3                   	ret    

00801495 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801495:	55                   	push   %ebp
  801496:	89 e5                	mov    %esp,%ebp
  801498:	57                   	push   %edi
  801499:	56                   	push   %esi
  80149a:	53                   	push   %ebx
  80149b:	83 ec 0c             	sub    $0xc,%esp
  80149e:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014a1:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014a4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014a9:	eb 21                	jmp    8014cc <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014ab:	83 ec 04             	sub    $0x4,%esp
  8014ae:	89 f0                	mov    %esi,%eax
  8014b0:	29 d8                	sub    %ebx,%eax
  8014b2:	50                   	push   %eax
  8014b3:	89 d8                	mov    %ebx,%eax
  8014b5:	03 45 0c             	add    0xc(%ebp),%eax
  8014b8:	50                   	push   %eax
  8014b9:	57                   	push   %edi
  8014ba:	e8 45 ff ff ff       	call   801404 <read>
		if (m < 0)
  8014bf:	83 c4 10             	add    $0x10,%esp
  8014c2:	85 c0                	test   %eax,%eax
  8014c4:	78 10                	js     8014d6 <readn+0x41>
			return m;
		if (m == 0)
  8014c6:	85 c0                	test   %eax,%eax
  8014c8:	74 0a                	je     8014d4 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014ca:	01 c3                	add    %eax,%ebx
  8014cc:	39 f3                	cmp    %esi,%ebx
  8014ce:	72 db                	jb     8014ab <readn+0x16>
  8014d0:	89 d8                	mov    %ebx,%eax
  8014d2:	eb 02                	jmp    8014d6 <readn+0x41>
  8014d4:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8014d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014d9:	5b                   	pop    %ebx
  8014da:	5e                   	pop    %esi
  8014db:	5f                   	pop    %edi
  8014dc:	5d                   	pop    %ebp
  8014dd:	c3                   	ret    

008014de <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014de:	55                   	push   %ebp
  8014df:	89 e5                	mov    %esp,%ebp
  8014e1:	53                   	push   %ebx
  8014e2:	83 ec 14             	sub    $0x14,%esp
  8014e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014e8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014eb:	50                   	push   %eax
  8014ec:	53                   	push   %ebx
  8014ed:	e8 ac fc ff ff       	call   80119e <fd_lookup>
  8014f2:	83 c4 08             	add    $0x8,%esp
  8014f5:	89 c2                	mov    %eax,%edx
  8014f7:	85 c0                	test   %eax,%eax
  8014f9:	78 68                	js     801563 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014fb:	83 ec 08             	sub    $0x8,%esp
  8014fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801501:	50                   	push   %eax
  801502:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801505:	ff 30                	pushl  (%eax)
  801507:	e8 e8 fc ff ff       	call   8011f4 <dev_lookup>
  80150c:	83 c4 10             	add    $0x10,%esp
  80150f:	85 c0                	test   %eax,%eax
  801511:	78 47                	js     80155a <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801513:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801516:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80151a:	75 21                	jne    80153d <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80151c:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801521:	8b 40 48             	mov    0x48(%eax),%eax
  801524:	83 ec 04             	sub    $0x4,%esp
  801527:	53                   	push   %ebx
  801528:	50                   	push   %eax
  801529:	68 bd 2a 80 00       	push   $0x802abd
  80152e:	e8 be ec ff ff       	call   8001f1 <cprintf>
		return -E_INVAL;
  801533:	83 c4 10             	add    $0x10,%esp
  801536:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80153b:	eb 26                	jmp    801563 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80153d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801540:	8b 52 0c             	mov    0xc(%edx),%edx
  801543:	85 d2                	test   %edx,%edx
  801545:	74 17                	je     80155e <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801547:	83 ec 04             	sub    $0x4,%esp
  80154a:	ff 75 10             	pushl  0x10(%ebp)
  80154d:	ff 75 0c             	pushl  0xc(%ebp)
  801550:	50                   	push   %eax
  801551:	ff d2                	call   *%edx
  801553:	89 c2                	mov    %eax,%edx
  801555:	83 c4 10             	add    $0x10,%esp
  801558:	eb 09                	jmp    801563 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80155a:	89 c2                	mov    %eax,%edx
  80155c:	eb 05                	jmp    801563 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80155e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801563:	89 d0                	mov    %edx,%eax
  801565:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801568:	c9                   	leave  
  801569:	c3                   	ret    

0080156a <seek>:

int
seek(int fdnum, off_t offset)
{
  80156a:	55                   	push   %ebp
  80156b:	89 e5                	mov    %esp,%ebp
  80156d:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801570:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801573:	50                   	push   %eax
  801574:	ff 75 08             	pushl  0x8(%ebp)
  801577:	e8 22 fc ff ff       	call   80119e <fd_lookup>
  80157c:	83 c4 08             	add    $0x8,%esp
  80157f:	85 c0                	test   %eax,%eax
  801581:	78 0e                	js     801591 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801583:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801586:	8b 55 0c             	mov    0xc(%ebp),%edx
  801589:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80158c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801591:	c9                   	leave  
  801592:	c3                   	ret    

00801593 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801593:	55                   	push   %ebp
  801594:	89 e5                	mov    %esp,%ebp
  801596:	53                   	push   %ebx
  801597:	83 ec 14             	sub    $0x14,%esp
  80159a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80159d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015a0:	50                   	push   %eax
  8015a1:	53                   	push   %ebx
  8015a2:	e8 f7 fb ff ff       	call   80119e <fd_lookup>
  8015a7:	83 c4 08             	add    $0x8,%esp
  8015aa:	89 c2                	mov    %eax,%edx
  8015ac:	85 c0                	test   %eax,%eax
  8015ae:	78 65                	js     801615 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b0:	83 ec 08             	sub    $0x8,%esp
  8015b3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015b6:	50                   	push   %eax
  8015b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ba:	ff 30                	pushl  (%eax)
  8015bc:	e8 33 fc ff ff       	call   8011f4 <dev_lookup>
  8015c1:	83 c4 10             	add    $0x10,%esp
  8015c4:	85 c0                	test   %eax,%eax
  8015c6:	78 44                	js     80160c <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015cb:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015cf:	75 21                	jne    8015f2 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015d1:	a1 0c 40 80 00       	mov    0x80400c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015d6:	8b 40 48             	mov    0x48(%eax),%eax
  8015d9:	83 ec 04             	sub    $0x4,%esp
  8015dc:	53                   	push   %ebx
  8015dd:	50                   	push   %eax
  8015de:	68 80 2a 80 00       	push   $0x802a80
  8015e3:	e8 09 ec ff ff       	call   8001f1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015e8:	83 c4 10             	add    $0x10,%esp
  8015eb:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015f0:	eb 23                	jmp    801615 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8015f2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015f5:	8b 52 18             	mov    0x18(%edx),%edx
  8015f8:	85 d2                	test   %edx,%edx
  8015fa:	74 14                	je     801610 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015fc:	83 ec 08             	sub    $0x8,%esp
  8015ff:	ff 75 0c             	pushl  0xc(%ebp)
  801602:	50                   	push   %eax
  801603:	ff d2                	call   *%edx
  801605:	89 c2                	mov    %eax,%edx
  801607:	83 c4 10             	add    $0x10,%esp
  80160a:	eb 09                	jmp    801615 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80160c:	89 c2                	mov    %eax,%edx
  80160e:	eb 05                	jmp    801615 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801610:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801615:	89 d0                	mov    %edx,%eax
  801617:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80161a:	c9                   	leave  
  80161b:	c3                   	ret    

0080161c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80161c:	55                   	push   %ebp
  80161d:	89 e5                	mov    %esp,%ebp
  80161f:	53                   	push   %ebx
  801620:	83 ec 14             	sub    $0x14,%esp
  801623:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801626:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801629:	50                   	push   %eax
  80162a:	ff 75 08             	pushl  0x8(%ebp)
  80162d:	e8 6c fb ff ff       	call   80119e <fd_lookup>
  801632:	83 c4 08             	add    $0x8,%esp
  801635:	89 c2                	mov    %eax,%edx
  801637:	85 c0                	test   %eax,%eax
  801639:	78 58                	js     801693 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80163b:	83 ec 08             	sub    $0x8,%esp
  80163e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801641:	50                   	push   %eax
  801642:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801645:	ff 30                	pushl  (%eax)
  801647:	e8 a8 fb ff ff       	call   8011f4 <dev_lookup>
  80164c:	83 c4 10             	add    $0x10,%esp
  80164f:	85 c0                	test   %eax,%eax
  801651:	78 37                	js     80168a <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801653:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801656:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80165a:	74 32                	je     80168e <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80165c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80165f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801666:	00 00 00 
	stat->st_isdir = 0;
  801669:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801670:	00 00 00 
	stat->st_dev = dev;
  801673:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801679:	83 ec 08             	sub    $0x8,%esp
  80167c:	53                   	push   %ebx
  80167d:	ff 75 f0             	pushl  -0x10(%ebp)
  801680:	ff 50 14             	call   *0x14(%eax)
  801683:	89 c2                	mov    %eax,%edx
  801685:	83 c4 10             	add    $0x10,%esp
  801688:	eb 09                	jmp    801693 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80168a:	89 c2                	mov    %eax,%edx
  80168c:	eb 05                	jmp    801693 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80168e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801693:	89 d0                	mov    %edx,%eax
  801695:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801698:	c9                   	leave  
  801699:	c3                   	ret    

0080169a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80169a:	55                   	push   %ebp
  80169b:	89 e5                	mov    %esp,%ebp
  80169d:	56                   	push   %esi
  80169e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80169f:	83 ec 08             	sub    $0x8,%esp
  8016a2:	6a 00                	push   $0x0
  8016a4:	ff 75 08             	pushl  0x8(%ebp)
  8016a7:	e8 0c 02 00 00       	call   8018b8 <open>
  8016ac:	89 c3                	mov    %eax,%ebx
  8016ae:	83 c4 10             	add    $0x10,%esp
  8016b1:	85 c0                	test   %eax,%eax
  8016b3:	78 1b                	js     8016d0 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016b5:	83 ec 08             	sub    $0x8,%esp
  8016b8:	ff 75 0c             	pushl  0xc(%ebp)
  8016bb:	50                   	push   %eax
  8016bc:	e8 5b ff ff ff       	call   80161c <fstat>
  8016c1:	89 c6                	mov    %eax,%esi
	close(fd);
  8016c3:	89 1c 24             	mov    %ebx,(%esp)
  8016c6:	e8 fd fb ff ff       	call   8012c8 <close>
	return r;
  8016cb:	83 c4 10             	add    $0x10,%esp
  8016ce:	89 f0                	mov    %esi,%eax
}
  8016d0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016d3:	5b                   	pop    %ebx
  8016d4:	5e                   	pop    %esi
  8016d5:	5d                   	pop    %ebp
  8016d6:	c3                   	ret    

008016d7 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016d7:	55                   	push   %ebp
  8016d8:	89 e5                	mov    %esp,%ebp
  8016da:	56                   	push   %esi
  8016db:	53                   	push   %ebx
  8016dc:	89 c6                	mov    %eax,%esi
  8016de:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016e0:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016e7:	75 12                	jne    8016fb <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016e9:	83 ec 0c             	sub    $0xc,%esp
  8016ec:	6a 01                	push   $0x1
  8016ee:	e8 fc f9 ff ff       	call   8010ef <ipc_find_env>
  8016f3:	a3 00 40 80 00       	mov    %eax,0x804000
  8016f8:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016fb:	6a 07                	push   $0x7
  8016fd:	68 00 50 80 00       	push   $0x805000
  801702:	56                   	push   %esi
  801703:	ff 35 00 40 80 00    	pushl  0x804000
  801709:	e8 8d f9 ff ff       	call   80109b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80170e:	83 c4 0c             	add    $0xc,%esp
  801711:	6a 00                	push   $0x0
  801713:	53                   	push   %ebx
  801714:	6a 00                	push   $0x0
  801716:	e8 17 f9 ff ff       	call   801032 <ipc_recv>
}
  80171b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80171e:	5b                   	pop    %ebx
  80171f:	5e                   	pop    %esi
  801720:	5d                   	pop    %ebp
  801721:	c3                   	ret    

00801722 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801722:	55                   	push   %ebp
  801723:	89 e5                	mov    %esp,%ebp
  801725:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801728:	8b 45 08             	mov    0x8(%ebp),%eax
  80172b:	8b 40 0c             	mov    0xc(%eax),%eax
  80172e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801733:	8b 45 0c             	mov    0xc(%ebp),%eax
  801736:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80173b:	ba 00 00 00 00       	mov    $0x0,%edx
  801740:	b8 02 00 00 00       	mov    $0x2,%eax
  801745:	e8 8d ff ff ff       	call   8016d7 <fsipc>
}
  80174a:	c9                   	leave  
  80174b:	c3                   	ret    

0080174c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80174c:	55                   	push   %ebp
  80174d:	89 e5                	mov    %esp,%ebp
  80174f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801752:	8b 45 08             	mov    0x8(%ebp),%eax
  801755:	8b 40 0c             	mov    0xc(%eax),%eax
  801758:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80175d:	ba 00 00 00 00       	mov    $0x0,%edx
  801762:	b8 06 00 00 00       	mov    $0x6,%eax
  801767:	e8 6b ff ff ff       	call   8016d7 <fsipc>
}
  80176c:	c9                   	leave  
  80176d:	c3                   	ret    

0080176e <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80176e:	55                   	push   %ebp
  80176f:	89 e5                	mov    %esp,%ebp
  801771:	53                   	push   %ebx
  801772:	83 ec 04             	sub    $0x4,%esp
  801775:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801778:	8b 45 08             	mov    0x8(%ebp),%eax
  80177b:	8b 40 0c             	mov    0xc(%eax),%eax
  80177e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801783:	ba 00 00 00 00       	mov    $0x0,%edx
  801788:	b8 05 00 00 00       	mov    $0x5,%eax
  80178d:	e8 45 ff ff ff       	call   8016d7 <fsipc>
  801792:	85 c0                	test   %eax,%eax
  801794:	78 2c                	js     8017c2 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801796:	83 ec 08             	sub    $0x8,%esp
  801799:	68 00 50 80 00       	push   $0x805000
  80179e:	53                   	push   %ebx
  80179f:	e8 d2 ef ff ff       	call   800776 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017a4:	a1 80 50 80 00       	mov    0x805080,%eax
  8017a9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017af:	a1 84 50 80 00       	mov    0x805084,%eax
  8017b4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017ba:	83 c4 10             	add    $0x10,%esp
  8017bd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017c5:	c9                   	leave  
  8017c6:	c3                   	ret    

008017c7 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017c7:	55                   	push   %ebp
  8017c8:	89 e5                	mov    %esp,%ebp
  8017ca:	53                   	push   %ebx
  8017cb:	83 ec 08             	sub    $0x8,%esp
  8017ce:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017d1:	8b 55 08             	mov    0x8(%ebp),%edx
  8017d4:	8b 52 0c             	mov    0xc(%edx),%edx
  8017d7:	89 15 00 50 80 00    	mov    %edx,0x805000
  8017dd:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8017e2:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  8017e7:	0f 46 d8             	cmovbe %eax,%ebx
	
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  8017ea:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  8017f0:	53                   	push   %ebx
  8017f1:	ff 75 0c             	pushl  0xc(%ebp)
  8017f4:	68 08 50 80 00       	push   $0x805008
  8017f9:	e8 0a f1 ff ff       	call   800908 <memmove>

	
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) 
  8017fe:	ba 00 00 00 00       	mov    $0x0,%edx
  801803:	b8 04 00 00 00       	mov    $0x4,%eax
  801808:	e8 ca fe ff ff       	call   8016d7 <fsipc>
  80180d:	83 c4 10             	add    $0x10,%esp
  801810:	85 c0                	test   %eax,%eax
  801812:	78 1d                	js     801831 <devfile_write+0x6a>
		return r;
	assert(r <= n_real); 
  801814:	39 d8                	cmp    %ebx,%eax
  801816:	76 19                	jbe    801831 <devfile_write+0x6a>
  801818:	68 f0 2a 80 00       	push   $0x802af0
  80181d:	68 fc 2a 80 00       	push   $0x802afc
  801822:	68 a3 00 00 00       	push   $0xa3
  801827:	68 11 2b 80 00       	push   $0x802b11
  80182c:	e8 71 0a 00 00       	call   8022a2 <_panic>
	return r;
}
  801831:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801834:	c9                   	leave  
  801835:	c3                   	ret    

00801836 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801836:	55                   	push   %ebp
  801837:	89 e5                	mov    %esp,%ebp
  801839:	56                   	push   %esi
  80183a:	53                   	push   %ebx
  80183b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80183e:	8b 45 08             	mov    0x8(%ebp),%eax
  801841:	8b 40 0c             	mov    0xc(%eax),%eax
  801844:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801849:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80184f:	ba 00 00 00 00       	mov    $0x0,%edx
  801854:	b8 03 00 00 00       	mov    $0x3,%eax
  801859:	e8 79 fe ff ff       	call   8016d7 <fsipc>
  80185e:	89 c3                	mov    %eax,%ebx
  801860:	85 c0                	test   %eax,%eax
  801862:	78 4b                	js     8018af <devfile_read+0x79>
		return r;
	assert(r <= n);
  801864:	39 c6                	cmp    %eax,%esi
  801866:	73 16                	jae    80187e <devfile_read+0x48>
  801868:	68 1c 2b 80 00       	push   $0x802b1c
  80186d:	68 fc 2a 80 00       	push   $0x802afc
  801872:	6a 7c                	push   $0x7c
  801874:	68 11 2b 80 00       	push   $0x802b11
  801879:	e8 24 0a 00 00       	call   8022a2 <_panic>
	assert(r <= PGSIZE);
  80187e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801883:	7e 16                	jle    80189b <devfile_read+0x65>
  801885:	68 23 2b 80 00       	push   $0x802b23
  80188a:	68 fc 2a 80 00       	push   $0x802afc
  80188f:	6a 7d                	push   $0x7d
  801891:	68 11 2b 80 00       	push   $0x802b11
  801896:	e8 07 0a 00 00       	call   8022a2 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80189b:	83 ec 04             	sub    $0x4,%esp
  80189e:	50                   	push   %eax
  80189f:	68 00 50 80 00       	push   $0x805000
  8018a4:	ff 75 0c             	pushl  0xc(%ebp)
  8018a7:	e8 5c f0 ff ff       	call   800908 <memmove>
	return r;
  8018ac:	83 c4 10             	add    $0x10,%esp
}
  8018af:	89 d8                	mov    %ebx,%eax
  8018b1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018b4:	5b                   	pop    %ebx
  8018b5:	5e                   	pop    %esi
  8018b6:	5d                   	pop    %ebp
  8018b7:	c3                   	ret    

008018b8 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018b8:	55                   	push   %ebp
  8018b9:	89 e5                	mov    %esp,%ebp
  8018bb:	53                   	push   %ebx
  8018bc:	83 ec 20             	sub    $0x20,%esp
  8018bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018c2:	53                   	push   %ebx
  8018c3:	e8 75 ee ff ff       	call   80073d <strlen>
  8018c8:	83 c4 10             	add    $0x10,%esp
  8018cb:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018d0:	7f 67                	jg     801939 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018d2:	83 ec 0c             	sub    $0xc,%esp
  8018d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018d8:	50                   	push   %eax
  8018d9:	e8 71 f8 ff ff       	call   80114f <fd_alloc>
  8018de:	83 c4 10             	add    $0x10,%esp
		return r;
  8018e1:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018e3:	85 c0                	test   %eax,%eax
  8018e5:	78 57                	js     80193e <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018e7:	83 ec 08             	sub    $0x8,%esp
  8018ea:	53                   	push   %ebx
  8018eb:	68 00 50 80 00       	push   $0x805000
  8018f0:	e8 81 ee ff ff       	call   800776 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018f8:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018fd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801900:	b8 01 00 00 00       	mov    $0x1,%eax
  801905:	e8 cd fd ff ff       	call   8016d7 <fsipc>
  80190a:	89 c3                	mov    %eax,%ebx
  80190c:	83 c4 10             	add    $0x10,%esp
  80190f:	85 c0                	test   %eax,%eax
  801911:	79 14                	jns    801927 <open+0x6f>
		fd_close(fd, 0);
  801913:	83 ec 08             	sub    $0x8,%esp
  801916:	6a 00                	push   $0x0
  801918:	ff 75 f4             	pushl  -0xc(%ebp)
  80191b:	e8 27 f9 ff ff       	call   801247 <fd_close>
		return r;
  801920:	83 c4 10             	add    $0x10,%esp
  801923:	89 da                	mov    %ebx,%edx
  801925:	eb 17                	jmp    80193e <open+0x86>
	}

	return fd2num(fd);
  801927:	83 ec 0c             	sub    $0xc,%esp
  80192a:	ff 75 f4             	pushl  -0xc(%ebp)
  80192d:	e8 f6 f7 ff ff       	call   801128 <fd2num>
  801932:	89 c2                	mov    %eax,%edx
  801934:	83 c4 10             	add    $0x10,%esp
  801937:	eb 05                	jmp    80193e <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801939:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80193e:	89 d0                	mov    %edx,%eax
  801940:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801943:	c9                   	leave  
  801944:	c3                   	ret    

00801945 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801945:	55                   	push   %ebp
  801946:	89 e5                	mov    %esp,%ebp
  801948:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80194b:	ba 00 00 00 00       	mov    $0x0,%edx
  801950:	b8 08 00 00 00       	mov    $0x8,%eax
  801955:	e8 7d fd ff ff       	call   8016d7 <fsipc>
}
  80195a:	c9                   	leave  
  80195b:	c3                   	ret    

0080195c <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  80195c:	55                   	push   %ebp
  80195d:	89 e5                	mov    %esp,%ebp
  80195f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801962:	68 2f 2b 80 00       	push   $0x802b2f
  801967:	ff 75 0c             	pushl  0xc(%ebp)
  80196a:	e8 07 ee ff ff       	call   800776 <strcpy>
	return 0;
}
  80196f:	b8 00 00 00 00       	mov    $0x0,%eax
  801974:	c9                   	leave  
  801975:	c3                   	ret    

00801976 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801976:	55                   	push   %ebp
  801977:	89 e5                	mov    %esp,%ebp
  801979:	53                   	push   %ebx
  80197a:	83 ec 10             	sub    $0x10,%esp
  80197d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801980:	53                   	push   %ebx
  801981:	e8 d8 09 00 00       	call   80235e <pageref>
  801986:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801989:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  80198e:	83 f8 01             	cmp    $0x1,%eax
  801991:	75 10                	jne    8019a3 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801993:	83 ec 0c             	sub    $0xc,%esp
  801996:	ff 73 0c             	pushl  0xc(%ebx)
  801999:	e8 c0 02 00 00       	call   801c5e <nsipc_close>
  80199e:	89 c2                	mov    %eax,%edx
  8019a0:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8019a3:	89 d0                	mov    %edx,%eax
  8019a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019a8:	c9                   	leave  
  8019a9:	c3                   	ret    

008019aa <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8019aa:	55                   	push   %ebp
  8019ab:	89 e5                	mov    %esp,%ebp
  8019ad:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8019b0:	6a 00                	push   $0x0
  8019b2:	ff 75 10             	pushl  0x10(%ebp)
  8019b5:	ff 75 0c             	pushl  0xc(%ebp)
  8019b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8019bb:	ff 70 0c             	pushl  0xc(%eax)
  8019be:	e8 78 03 00 00       	call   801d3b <nsipc_send>
}
  8019c3:	c9                   	leave  
  8019c4:	c3                   	ret    

008019c5 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8019c5:	55                   	push   %ebp
  8019c6:	89 e5                	mov    %esp,%ebp
  8019c8:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8019cb:	6a 00                	push   $0x0
  8019cd:	ff 75 10             	pushl  0x10(%ebp)
  8019d0:	ff 75 0c             	pushl  0xc(%ebp)
  8019d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d6:	ff 70 0c             	pushl  0xc(%eax)
  8019d9:	e8 f1 02 00 00       	call   801ccf <nsipc_recv>
}
  8019de:	c9                   	leave  
  8019df:	c3                   	ret    

008019e0 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8019e0:	55                   	push   %ebp
  8019e1:	89 e5                	mov    %esp,%ebp
  8019e3:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8019e6:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8019e9:	52                   	push   %edx
  8019ea:	50                   	push   %eax
  8019eb:	e8 ae f7 ff ff       	call   80119e <fd_lookup>
  8019f0:	83 c4 10             	add    $0x10,%esp
  8019f3:	85 c0                	test   %eax,%eax
  8019f5:	78 17                	js     801a0e <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8019f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019fa:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801a00:	39 08                	cmp    %ecx,(%eax)
  801a02:	75 05                	jne    801a09 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801a04:	8b 40 0c             	mov    0xc(%eax),%eax
  801a07:	eb 05                	jmp    801a0e <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801a09:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801a0e:	c9                   	leave  
  801a0f:	c3                   	ret    

00801a10 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801a10:	55                   	push   %ebp
  801a11:	89 e5                	mov    %esp,%ebp
  801a13:	56                   	push   %esi
  801a14:	53                   	push   %ebx
  801a15:	83 ec 1c             	sub    $0x1c,%esp
  801a18:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801a1a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a1d:	50                   	push   %eax
  801a1e:	e8 2c f7 ff ff       	call   80114f <fd_alloc>
  801a23:	89 c3                	mov    %eax,%ebx
  801a25:	83 c4 10             	add    $0x10,%esp
  801a28:	85 c0                	test   %eax,%eax
  801a2a:	78 1b                	js     801a47 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801a2c:	83 ec 04             	sub    $0x4,%esp
  801a2f:	68 07 04 00 00       	push   $0x407
  801a34:	ff 75 f4             	pushl  -0xc(%ebp)
  801a37:	6a 00                	push   $0x0
  801a39:	e8 3b f1 ff ff       	call   800b79 <sys_page_alloc>
  801a3e:	89 c3                	mov    %eax,%ebx
  801a40:	83 c4 10             	add    $0x10,%esp
  801a43:	85 c0                	test   %eax,%eax
  801a45:	79 10                	jns    801a57 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801a47:	83 ec 0c             	sub    $0xc,%esp
  801a4a:	56                   	push   %esi
  801a4b:	e8 0e 02 00 00       	call   801c5e <nsipc_close>
		return r;
  801a50:	83 c4 10             	add    $0x10,%esp
  801a53:	89 d8                	mov    %ebx,%eax
  801a55:	eb 24                	jmp    801a7b <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801a57:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a60:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801a62:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a65:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801a6c:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801a6f:	83 ec 0c             	sub    $0xc,%esp
  801a72:	50                   	push   %eax
  801a73:	e8 b0 f6 ff ff       	call   801128 <fd2num>
  801a78:	83 c4 10             	add    $0x10,%esp
}
  801a7b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a7e:	5b                   	pop    %ebx
  801a7f:	5e                   	pop    %esi
  801a80:	5d                   	pop    %ebp
  801a81:	c3                   	ret    

00801a82 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801a82:	55                   	push   %ebp
  801a83:	89 e5                	mov    %esp,%ebp
  801a85:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a88:	8b 45 08             	mov    0x8(%ebp),%eax
  801a8b:	e8 50 ff ff ff       	call   8019e0 <fd2sockid>
		return r;
  801a90:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a92:	85 c0                	test   %eax,%eax
  801a94:	78 1f                	js     801ab5 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801a96:	83 ec 04             	sub    $0x4,%esp
  801a99:	ff 75 10             	pushl  0x10(%ebp)
  801a9c:	ff 75 0c             	pushl  0xc(%ebp)
  801a9f:	50                   	push   %eax
  801aa0:	e8 12 01 00 00       	call   801bb7 <nsipc_accept>
  801aa5:	83 c4 10             	add    $0x10,%esp
		return r;
  801aa8:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801aaa:	85 c0                	test   %eax,%eax
  801aac:	78 07                	js     801ab5 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801aae:	e8 5d ff ff ff       	call   801a10 <alloc_sockfd>
  801ab3:	89 c1                	mov    %eax,%ecx
}
  801ab5:	89 c8                	mov    %ecx,%eax
  801ab7:	c9                   	leave  
  801ab8:	c3                   	ret    

00801ab9 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801ab9:	55                   	push   %ebp
  801aba:	89 e5                	mov    %esp,%ebp
  801abc:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801abf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac2:	e8 19 ff ff ff       	call   8019e0 <fd2sockid>
  801ac7:	85 c0                	test   %eax,%eax
  801ac9:	78 12                	js     801add <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801acb:	83 ec 04             	sub    $0x4,%esp
  801ace:	ff 75 10             	pushl  0x10(%ebp)
  801ad1:	ff 75 0c             	pushl  0xc(%ebp)
  801ad4:	50                   	push   %eax
  801ad5:	e8 2d 01 00 00       	call   801c07 <nsipc_bind>
  801ada:	83 c4 10             	add    $0x10,%esp
}
  801add:	c9                   	leave  
  801ade:	c3                   	ret    

00801adf <shutdown>:

int
shutdown(int s, int how)
{
  801adf:	55                   	push   %ebp
  801ae0:	89 e5                	mov    %esp,%ebp
  801ae2:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ae5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae8:	e8 f3 fe ff ff       	call   8019e0 <fd2sockid>
  801aed:	85 c0                	test   %eax,%eax
  801aef:	78 0f                	js     801b00 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801af1:	83 ec 08             	sub    $0x8,%esp
  801af4:	ff 75 0c             	pushl  0xc(%ebp)
  801af7:	50                   	push   %eax
  801af8:	e8 3f 01 00 00       	call   801c3c <nsipc_shutdown>
  801afd:	83 c4 10             	add    $0x10,%esp
}
  801b00:	c9                   	leave  
  801b01:	c3                   	ret    

00801b02 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801b02:	55                   	push   %ebp
  801b03:	89 e5                	mov    %esp,%ebp
  801b05:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b08:	8b 45 08             	mov    0x8(%ebp),%eax
  801b0b:	e8 d0 fe ff ff       	call   8019e0 <fd2sockid>
  801b10:	85 c0                	test   %eax,%eax
  801b12:	78 12                	js     801b26 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801b14:	83 ec 04             	sub    $0x4,%esp
  801b17:	ff 75 10             	pushl  0x10(%ebp)
  801b1a:	ff 75 0c             	pushl  0xc(%ebp)
  801b1d:	50                   	push   %eax
  801b1e:	e8 55 01 00 00       	call   801c78 <nsipc_connect>
  801b23:	83 c4 10             	add    $0x10,%esp
}
  801b26:	c9                   	leave  
  801b27:	c3                   	ret    

00801b28 <listen>:

int
listen(int s, int backlog)
{
  801b28:	55                   	push   %ebp
  801b29:	89 e5                	mov    %esp,%ebp
  801b2b:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b2e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b31:	e8 aa fe ff ff       	call   8019e0 <fd2sockid>
  801b36:	85 c0                	test   %eax,%eax
  801b38:	78 0f                	js     801b49 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801b3a:	83 ec 08             	sub    $0x8,%esp
  801b3d:	ff 75 0c             	pushl  0xc(%ebp)
  801b40:	50                   	push   %eax
  801b41:	e8 67 01 00 00       	call   801cad <nsipc_listen>
  801b46:	83 c4 10             	add    $0x10,%esp
}
  801b49:	c9                   	leave  
  801b4a:	c3                   	ret    

00801b4b <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801b4b:	55                   	push   %ebp
  801b4c:	89 e5                	mov    %esp,%ebp
  801b4e:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801b51:	ff 75 10             	pushl  0x10(%ebp)
  801b54:	ff 75 0c             	pushl  0xc(%ebp)
  801b57:	ff 75 08             	pushl  0x8(%ebp)
  801b5a:	e8 3a 02 00 00       	call   801d99 <nsipc_socket>
  801b5f:	83 c4 10             	add    $0x10,%esp
  801b62:	85 c0                	test   %eax,%eax
  801b64:	78 05                	js     801b6b <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801b66:	e8 a5 fe ff ff       	call   801a10 <alloc_sockfd>
}
  801b6b:	c9                   	leave  
  801b6c:	c3                   	ret    

00801b6d <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801b6d:	55                   	push   %ebp
  801b6e:	89 e5                	mov    %esp,%ebp
  801b70:	53                   	push   %ebx
  801b71:	83 ec 04             	sub    $0x4,%esp
  801b74:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801b76:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801b7d:	75 12                	jne    801b91 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801b7f:	83 ec 0c             	sub    $0xc,%esp
  801b82:	6a 02                	push   $0x2
  801b84:	e8 66 f5 ff ff       	call   8010ef <ipc_find_env>
  801b89:	a3 04 40 80 00       	mov    %eax,0x804004
  801b8e:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801b91:	6a 07                	push   $0x7
  801b93:	68 00 60 80 00       	push   $0x806000
  801b98:	53                   	push   %ebx
  801b99:	ff 35 04 40 80 00    	pushl  0x804004
  801b9f:	e8 f7 f4 ff ff       	call   80109b <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801ba4:	83 c4 0c             	add    $0xc,%esp
  801ba7:	6a 00                	push   $0x0
  801ba9:	6a 00                	push   $0x0
  801bab:	6a 00                	push   $0x0
  801bad:	e8 80 f4 ff ff       	call   801032 <ipc_recv>
}
  801bb2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bb5:	c9                   	leave  
  801bb6:	c3                   	ret    

00801bb7 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801bb7:	55                   	push   %ebp
  801bb8:	89 e5                	mov    %esp,%ebp
  801bba:	56                   	push   %esi
  801bbb:	53                   	push   %ebx
  801bbc:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801bbf:	8b 45 08             	mov    0x8(%ebp),%eax
  801bc2:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801bc7:	8b 06                	mov    (%esi),%eax
  801bc9:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801bce:	b8 01 00 00 00       	mov    $0x1,%eax
  801bd3:	e8 95 ff ff ff       	call   801b6d <nsipc>
  801bd8:	89 c3                	mov    %eax,%ebx
  801bda:	85 c0                	test   %eax,%eax
  801bdc:	78 20                	js     801bfe <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801bde:	83 ec 04             	sub    $0x4,%esp
  801be1:	ff 35 10 60 80 00    	pushl  0x806010
  801be7:	68 00 60 80 00       	push   $0x806000
  801bec:	ff 75 0c             	pushl  0xc(%ebp)
  801bef:	e8 14 ed ff ff       	call   800908 <memmove>
		*addrlen = ret->ret_addrlen;
  801bf4:	a1 10 60 80 00       	mov    0x806010,%eax
  801bf9:	89 06                	mov    %eax,(%esi)
  801bfb:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801bfe:	89 d8                	mov    %ebx,%eax
  801c00:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c03:	5b                   	pop    %ebx
  801c04:	5e                   	pop    %esi
  801c05:	5d                   	pop    %ebp
  801c06:	c3                   	ret    

00801c07 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c07:	55                   	push   %ebp
  801c08:	89 e5                	mov    %esp,%ebp
  801c0a:	53                   	push   %ebx
  801c0b:	83 ec 08             	sub    $0x8,%esp
  801c0e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801c11:	8b 45 08             	mov    0x8(%ebp),%eax
  801c14:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801c19:	53                   	push   %ebx
  801c1a:	ff 75 0c             	pushl  0xc(%ebp)
  801c1d:	68 04 60 80 00       	push   $0x806004
  801c22:	e8 e1 ec ff ff       	call   800908 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801c27:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801c2d:	b8 02 00 00 00       	mov    $0x2,%eax
  801c32:	e8 36 ff ff ff       	call   801b6d <nsipc>
}
  801c37:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c3a:	c9                   	leave  
  801c3b:	c3                   	ret    

00801c3c <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801c3c:	55                   	push   %ebp
  801c3d:	89 e5                	mov    %esp,%ebp
  801c3f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801c42:	8b 45 08             	mov    0x8(%ebp),%eax
  801c45:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801c4a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c4d:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801c52:	b8 03 00 00 00       	mov    $0x3,%eax
  801c57:	e8 11 ff ff ff       	call   801b6d <nsipc>
}
  801c5c:	c9                   	leave  
  801c5d:	c3                   	ret    

00801c5e <nsipc_close>:

int
nsipc_close(int s)
{
  801c5e:	55                   	push   %ebp
  801c5f:	89 e5                	mov    %esp,%ebp
  801c61:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801c64:	8b 45 08             	mov    0x8(%ebp),%eax
  801c67:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801c6c:	b8 04 00 00 00       	mov    $0x4,%eax
  801c71:	e8 f7 fe ff ff       	call   801b6d <nsipc>
}
  801c76:	c9                   	leave  
  801c77:	c3                   	ret    

00801c78 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801c78:	55                   	push   %ebp
  801c79:	89 e5                	mov    %esp,%ebp
  801c7b:	53                   	push   %ebx
  801c7c:	83 ec 08             	sub    $0x8,%esp
  801c7f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801c82:	8b 45 08             	mov    0x8(%ebp),%eax
  801c85:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801c8a:	53                   	push   %ebx
  801c8b:	ff 75 0c             	pushl  0xc(%ebp)
  801c8e:	68 04 60 80 00       	push   $0x806004
  801c93:	e8 70 ec ff ff       	call   800908 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801c98:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801c9e:	b8 05 00 00 00       	mov    $0x5,%eax
  801ca3:	e8 c5 fe ff ff       	call   801b6d <nsipc>
}
  801ca8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cab:	c9                   	leave  
  801cac:	c3                   	ret    

00801cad <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801cad:	55                   	push   %ebp
  801cae:	89 e5                	mov    %esp,%ebp
  801cb0:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801cb3:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb6:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801cbb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cbe:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801cc3:	b8 06 00 00 00       	mov    $0x6,%eax
  801cc8:	e8 a0 fe ff ff       	call   801b6d <nsipc>
}
  801ccd:	c9                   	leave  
  801cce:	c3                   	ret    

00801ccf <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801ccf:	55                   	push   %ebp
  801cd0:	89 e5                	mov    %esp,%ebp
  801cd2:	56                   	push   %esi
  801cd3:	53                   	push   %ebx
  801cd4:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801cd7:	8b 45 08             	mov    0x8(%ebp),%eax
  801cda:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801cdf:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801ce5:	8b 45 14             	mov    0x14(%ebp),%eax
  801ce8:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801ced:	b8 07 00 00 00       	mov    $0x7,%eax
  801cf2:	e8 76 fe ff ff       	call   801b6d <nsipc>
  801cf7:	89 c3                	mov    %eax,%ebx
  801cf9:	85 c0                	test   %eax,%eax
  801cfb:	78 35                	js     801d32 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801cfd:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801d02:	7f 04                	jg     801d08 <nsipc_recv+0x39>
  801d04:	39 c6                	cmp    %eax,%esi
  801d06:	7d 16                	jge    801d1e <nsipc_recv+0x4f>
  801d08:	68 3b 2b 80 00       	push   $0x802b3b
  801d0d:	68 fc 2a 80 00       	push   $0x802afc
  801d12:	6a 62                	push   $0x62
  801d14:	68 50 2b 80 00       	push   $0x802b50
  801d19:	e8 84 05 00 00       	call   8022a2 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801d1e:	83 ec 04             	sub    $0x4,%esp
  801d21:	50                   	push   %eax
  801d22:	68 00 60 80 00       	push   $0x806000
  801d27:	ff 75 0c             	pushl  0xc(%ebp)
  801d2a:	e8 d9 eb ff ff       	call   800908 <memmove>
  801d2f:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801d32:	89 d8                	mov    %ebx,%eax
  801d34:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d37:	5b                   	pop    %ebx
  801d38:	5e                   	pop    %esi
  801d39:	5d                   	pop    %ebp
  801d3a:	c3                   	ret    

00801d3b <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801d3b:	55                   	push   %ebp
  801d3c:	89 e5                	mov    %esp,%ebp
  801d3e:	53                   	push   %ebx
  801d3f:	83 ec 04             	sub    $0x4,%esp
  801d42:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801d45:	8b 45 08             	mov    0x8(%ebp),%eax
  801d48:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801d4d:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801d53:	7e 16                	jle    801d6b <nsipc_send+0x30>
  801d55:	68 5c 2b 80 00       	push   $0x802b5c
  801d5a:	68 fc 2a 80 00       	push   $0x802afc
  801d5f:	6a 6d                	push   $0x6d
  801d61:	68 50 2b 80 00       	push   $0x802b50
  801d66:	e8 37 05 00 00       	call   8022a2 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801d6b:	83 ec 04             	sub    $0x4,%esp
  801d6e:	53                   	push   %ebx
  801d6f:	ff 75 0c             	pushl  0xc(%ebp)
  801d72:	68 0c 60 80 00       	push   $0x80600c
  801d77:	e8 8c eb ff ff       	call   800908 <memmove>
	nsipcbuf.send.req_size = size;
  801d7c:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801d82:	8b 45 14             	mov    0x14(%ebp),%eax
  801d85:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801d8a:	b8 08 00 00 00       	mov    $0x8,%eax
  801d8f:	e8 d9 fd ff ff       	call   801b6d <nsipc>
}
  801d94:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d97:	c9                   	leave  
  801d98:	c3                   	ret    

00801d99 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801d99:	55                   	push   %ebp
  801d9a:	89 e5                	mov    %esp,%ebp
  801d9c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801d9f:	8b 45 08             	mov    0x8(%ebp),%eax
  801da2:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801da7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801daa:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801daf:	8b 45 10             	mov    0x10(%ebp),%eax
  801db2:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801db7:	b8 09 00 00 00       	mov    $0x9,%eax
  801dbc:	e8 ac fd ff ff       	call   801b6d <nsipc>
}
  801dc1:	c9                   	leave  
  801dc2:	c3                   	ret    

00801dc3 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801dc3:	55                   	push   %ebp
  801dc4:	89 e5                	mov    %esp,%ebp
  801dc6:	56                   	push   %esi
  801dc7:	53                   	push   %ebx
  801dc8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801dcb:	83 ec 0c             	sub    $0xc,%esp
  801dce:	ff 75 08             	pushl  0x8(%ebp)
  801dd1:	e8 62 f3 ff ff       	call   801138 <fd2data>
  801dd6:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801dd8:	83 c4 08             	add    $0x8,%esp
  801ddb:	68 68 2b 80 00       	push   $0x802b68
  801de0:	53                   	push   %ebx
  801de1:	e8 90 e9 ff ff       	call   800776 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801de6:	8b 46 04             	mov    0x4(%esi),%eax
  801de9:	2b 06                	sub    (%esi),%eax
  801deb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801df1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801df8:	00 00 00 
	stat->st_dev = &devpipe;
  801dfb:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801e02:	30 80 00 
	return 0;
}
  801e05:	b8 00 00 00 00       	mov    $0x0,%eax
  801e0a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e0d:	5b                   	pop    %ebx
  801e0e:	5e                   	pop    %esi
  801e0f:	5d                   	pop    %ebp
  801e10:	c3                   	ret    

00801e11 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801e11:	55                   	push   %ebp
  801e12:	89 e5                	mov    %esp,%ebp
  801e14:	53                   	push   %ebx
  801e15:	83 ec 0c             	sub    $0xc,%esp
  801e18:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801e1b:	53                   	push   %ebx
  801e1c:	6a 00                	push   $0x0
  801e1e:	e8 db ed ff ff       	call   800bfe <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801e23:	89 1c 24             	mov    %ebx,(%esp)
  801e26:	e8 0d f3 ff ff       	call   801138 <fd2data>
  801e2b:	83 c4 08             	add    $0x8,%esp
  801e2e:	50                   	push   %eax
  801e2f:	6a 00                	push   $0x0
  801e31:	e8 c8 ed ff ff       	call   800bfe <sys_page_unmap>
}
  801e36:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e39:	c9                   	leave  
  801e3a:	c3                   	ret    

00801e3b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801e3b:	55                   	push   %ebp
  801e3c:	89 e5                	mov    %esp,%ebp
  801e3e:	57                   	push   %edi
  801e3f:	56                   	push   %esi
  801e40:	53                   	push   %ebx
  801e41:	83 ec 1c             	sub    $0x1c,%esp
  801e44:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801e47:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801e49:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801e4e:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801e51:	83 ec 0c             	sub    $0xc,%esp
  801e54:	ff 75 e0             	pushl  -0x20(%ebp)
  801e57:	e8 02 05 00 00       	call   80235e <pageref>
  801e5c:	89 c3                	mov    %eax,%ebx
  801e5e:	89 3c 24             	mov    %edi,(%esp)
  801e61:	e8 f8 04 00 00       	call   80235e <pageref>
  801e66:	83 c4 10             	add    $0x10,%esp
  801e69:	39 c3                	cmp    %eax,%ebx
  801e6b:	0f 94 c1             	sete   %cl
  801e6e:	0f b6 c9             	movzbl %cl,%ecx
  801e71:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801e74:	8b 15 0c 40 80 00    	mov    0x80400c,%edx
  801e7a:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801e7d:	39 ce                	cmp    %ecx,%esi
  801e7f:	74 1b                	je     801e9c <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801e81:	39 c3                	cmp    %eax,%ebx
  801e83:	75 c4                	jne    801e49 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801e85:	8b 42 58             	mov    0x58(%edx),%eax
  801e88:	ff 75 e4             	pushl  -0x1c(%ebp)
  801e8b:	50                   	push   %eax
  801e8c:	56                   	push   %esi
  801e8d:	68 6f 2b 80 00       	push   $0x802b6f
  801e92:	e8 5a e3 ff ff       	call   8001f1 <cprintf>
  801e97:	83 c4 10             	add    $0x10,%esp
  801e9a:	eb ad                	jmp    801e49 <_pipeisclosed+0xe>
	}
}
  801e9c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e9f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ea2:	5b                   	pop    %ebx
  801ea3:	5e                   	pop    %esi
  801ea4:	5f                   	pop    %edi
  801ea5:	5d                   	pop    %ebp
  801ea6:	c3                   	ret    

00801ea7 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ea7:	55                   	push   %ebp
  801ea8:	89 e5                	mov    %esp,%ebp
  801eaa:	57                   	push   %edi
  801eab:	56                   	push   %esi
  801eac:	53                   	push   %ebx
  801ead:	83 ec 28             	sub    $0x28,%esp
  801eb0:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801eb3:	56                   	push   %esi
  801eb4:	e8 7f f2 ff ff       	call   801138 <fd2data>
  801eb9:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ebb:	83 c4 10             	add    $0x10,%esp
  801ebe:	bf 00 00 00 00       	mov    $0x0,%edi
  801ec3:	eb 4b                	jmp    801f10 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ec5:	89 da                	mov    %ebx,%edx
  801ec7:	89 f0                	mov    %esi,%eax
  801ec9:	e8 6d ff ff ff       	call   801e3b <_pipeisclosed>
  801ece:	85 c0                	test   %eax,%eax
  801ed0:	75 48                	jne    801f1a <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ed2:	e8 83 ec ff ff       	call   800b5a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ed7:	8b 43 04             	mov    0x4(%ebx),%eax
  801eda:	8b 0b                	mov    (%ebx),%ecx
  801edc:	8d 51 20             	lea    0x20(%ecx),%edx
  801edf:	39 d0                	cmp    %edx,%eax
  801ee1:	73 e2                	jae    801ec5 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ee3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ee6:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801eea:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801eed:	89 c2                	mov    %eax,%edx
  801eef:	c1 fa 1f             	sar    $0x1f,%edx
  801ef2:	89 d1                	mov    %edx,%ecx
  801ef4:	c1 e9 1b             	shr    $0x1b,%ecx
  801ef7:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801efa:	83 e2 1f             	and    $0x1f,%edx
  801efd:	29 ca                	sub    %ecx,%edx
  801eff:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801f03:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801f07:	83 c0 01             	add    $0x1,%eax
  801f0a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f0d:	83 c7 01             	add    $0x1,%edi
  801f10:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801f13:	75 c2                	jne    801ed7 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801f15:	8b 45 10             	mov    0x10(%ebp),%eax
  801f18:	eb 05                	jmp    801f1f <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f1a:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801f1f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f22:	5b                   	pop    %ebx
  801f23:	5e                   	pop    %esi
  801f24:	5f                   	pop    %edi
  801f25:	5d                   	pop    %ebp
  801f26:	c3                   	ret    

00801f27 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f27:	55                   	push   %ebp
  801f28:	89 e5                	mov    %esp,%ebp
  801f2a:	57                   	push   %edi
  801f2b:	56                   	push   %esi
  801f2c:	53                   	push   %ebx
  801f2d:	83 ec 18             	sub    $0x18,%esp
  801f30:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801f33:	57                   	push   %edi
  801f34:	e8 ff f1 ff ff       	call   801138 <fd2data>
  801f39:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f3b:	83 c4 10             	add    $0x10,%esp
  801f3e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f43:	eb 3d                	jmp    801f82 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801f45:	85 db                	test   %ebx,%ebx
  801f47:	74 04                	je     801f4d <devpipe_read+0x26>
				return i;
  801f49:	89 d8                	mov    %ebx,%eax
  801f4b:	eb 44                	jmp    801f91 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801f4d:	89 f2                	mov    %esi,%edx
  801f4f:	89 f8                	mov    %edi,%eax
  801f51:	e8 e5 fe ff ff       	call   801e3b <_pipeisclosed>
  801f56:	85 c0                	test   %eax,%eax
  801f58:	75 32                	jne    801f8c <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801f5a:	e8 fb eb ff ff       	call   800b5a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801f5f:	8b 06                	mov    (%esi),%eax
  801f61:	3b 46 04             	cmp    0x4(%esi),%eax
  801f64:	74 df                	je     801f45 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801f66:	99                   	cltd   
  801f67:	c1 ea 1b             	shr    $0x1b,%edx
  801f6a:	01 d0                	add    %edx,%eax
  801f6c:	83 e0 1f             	and    $0x1f,%eax
  801f6f:	29 d0                	sub    %edx,%eax
  801f71:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801f76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f79:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801f7c:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f7f:	83 c3 01             	add    $0x1,%ebx
  801f82:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801f85:	75 d8                	jne    801f5f <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801f87:	8b 45 10             	mov    0x10(%ebp),%eax
  801f8a:	eb 05                	jmp    801f91 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f8c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801f91:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f94:	5b                   	pop    %ebx
  801f95:	5e                   	pop    %esi
  801f96:	5f                   	pop    %edi
  801f97:	5d                   	pop    %ebp
  801f98:	c3                   	ret    

00801f99 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801f99:	55                   	push   %ebp
  801f9a:	89 e5                	mov    %esp,%ebp
  801f9c:	56                   	push   %esi
  801f9d:	53                   	push   %ebx
  801f9e:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801fa1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fa4:	50                   	push   %eax
  801fa5:	e8 a5 f1 ff ff       	call   80114f <fd_alloc>
  801faa:	83 c4 10             	add    $0x10,%esp
  801fad:	89 c2                	mov    %eax,%edx
  801faf:	85 c0                	test   %eax,%eax
  801fb1:	0f 88 2c 01 00 00    	js     8020e3 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fb7:	83 ec 04             	sub    $0x4,%esp
  801fba:	68 07 04 00 00       	push   $0x407
  801fbf:	ff 75 f4             	pushl  -0xc(%ebp)
  801fc2:	6a 00                	push   $0x0
  801fc4:	e8 b0 eb ff ff       	call   800b79 <sys_page_alloc>
  801fc9:	83 c4 10             	add    $0x10,%esp
  801fcc:	89 c2                	mov    %eax,%edx
  801fce:	85 c0                	test   %eax,%eax
  801fd0:	0f 88 0d 01 00 00    	js     8020e3 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801fd6:	83 ec 0c             	sub    $0xc,%esp
  801fd9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801fdc:	50                   	push   %eax
  801fdd:	e8 6d f1 ff ff       	call   80114f <fd_alloc>
  801fe2:	89 c3                	mov    %eax,%ebx
  801fe4:	83 c4 10             	add    $0x10,%esp
  801fe7:	85 c0                	test   %eax,%eax
  801fe9:	0f 88 e2 00 00 00    	js     8020d1 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fef:	83 ec 04             	sub    $0x4,%esp
  801ff2:	68 07 04 00 00       	push   $0x407
  801ff7:	ff 75 f0             	pushl  -0x10(%ebp)
  801ffa:	6a 00                	push   $0x0
  801ffc:	e8 78 eb ff ff       	call   800b79 <sys_page_alloc>
  802001:	89 c3                	mov    %eax,%ebx
  802003:	83 c4 10             	add    $0x10,%esp
  802006:	85 c0                	test   %eax,%eax
  802008:	0f 88 c3 00 00 00    	js     8020d1 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80200e:	83 ec 0c             	sub    $0xc,%esp
  802011:	ff 75 f4             	pushl  -0xc(%ebp)
  802014:	e8 1f f1 ff ff       	call   801138 <fd2data>
  802019:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80201b:	83 c4 0c             	add    $0xc,%esp
  80201e:	68 07 04 00 00       	push   $0x407
  802023:	50                   	push   %eax
  802024:	6a 00                	push   $0x0
  802026:	e8 4e eb ff ff       	call   800b79 <sys_page_alloc>
  80202b:	89 c3                	mov    %eax,%ebx
  80202d:	83 c4 10             	add    $0x10,%esp
  802030:	85 c0                	test   %eax,%eax
  802032:	0f 88 89 00 00 00    	js     8020c1 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802038:	83 ec 0c             	sub    $0xc,%esp
  80203b:	ff 75 f0             	pushl  -0x10(%ebp)
  80203e:	e8 f5 f0 ff ff       	call   801138 <fd2data>
  802043:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80204a:	50                   	push   %eax
  80204b:	6a 00                	push   $0x0
  80204d:	56                   	push   %esi
  80204e:	6a 00                	push   $0x0
  802050:	e8 67 eb ff ff       	call   800bbc <sys_page_map>
  802055:	89 c3                	mov    %eax,%ebx
  802057:	83 c4 20             	add    $0x20,%esp
  80205a:	85 c0                	test   %eax,%eax
  80205c:	78 55                	js     8020b3 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80205e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802064:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802067:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802069:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80206c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802073:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802079:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80207c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80207e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802081:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802088:	83 ec 0c             	sub    $0xc,%esp
  80208b:	ff 75 f4             	pushl  -0xc(%ebp)
  80208e:	e8 95 f0 ff ff       	call   801128 <fd2num>
  802093:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802096:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802098:	83 c4 04             	add    $0x4,%esp
  80209b:	ff 75 f0             	pushl  -0x10(%ebp)
  80209e:	e8 85 f0 ff ff       	call   801128 <fd2num>
  8020a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020a6:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8020a9:	83 c4 10             	add    $0x10,%esp
  8020ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8020b1:	eb 30                	jmp    8020e3 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8020b3:	83 ec 08             	sub    $0x8,%esp
  8020b6:	56                   	push   %esi
  8020b7:	6a 00                	push   $0x0
  8020b9:	e8 40 eb ff ff       	call   800bfe <sys_page_unmap>
  8020be:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8020c1:	83 ec 08             	sub    $0x8,%esp
  8020c4:	ff 75 f0             	pushl  -0x10(%ebp)
  8020c7:	6a 00                	push   $0x0
  8020c9:	e8 30 eb ff ff       	call   800bfe <sys_page_unmap>
  8020ce:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8020d1:	83 ec 08             	sub    $0x8,%esp
  8020d4:	ff 75 f4             	pushl  -0xc(%ebp)
  8020d7:	6a 00                	push   $0x0
  8020d9:	e8 20 eb ff ff       	call   800bfe <sys_page_unmap>
  8020de:	83 c4 10             	add    $0x10,%esp
  8020e1:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8020e3:	89 d0                	mov    %edx,%eax
  8020e5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020e8:	5b                   	pop    %ebx
  8020e9:	5e                   	pop    %esi
  8020ea:	5d                   	pop    %ebp
  8020eb:	c3                   	ret    

008020ec <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8020ec:	55                   	push   %ebp
  8020ed:	89 e5                	mov    %esp,%ebp
  8020ef:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020f5:	50                   	push   %eax
  8020f6:	ff 75 08             	pushl  0x8(%ebp)
  8020f9:	e8 a0 f0 ff ff       	call   80119e <fd_lookup>
  8020fe:	83 c4 10             	add    $0x10,%esp
  802101:	85 c0                	test   %eax,%eax
  802103:	78 18                	js     80211d <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802105:	83 ec 0c             	sub    $0xc,%esp
  802108:	ff 75 f4             	pushl  -0xc(%ebp)
  80210b:	e8 28 f0 ff ff       	call   801138 <fd2data>
	return _pipeisclosed(fd, p);
  802110:	89 c2                	mov    %eax,%edx
  802112:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802115:	e8 21 fd ff ff       	call   801e3b <_pipeisclosed>
  80211a:	83 c4 10             	add    $0x10,%esp
}
  80211d:	c9                   	leave  
  80211e:	c3                   	ret    

0080211f <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80211f:	55                   	push   %ebp
  802120:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802122:	b8 00 00 00 00       	mov    $0x0,%eax
  802127:	5d                   	pop    %ebp
  802128:	c3                   	ret    

00802129 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802129:	55                   	push   %ebp
  80212a:	89 e5                	mov    %esp,%ebp
  80212c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80212f:	68 87 2b 80 00       	push   $0x802b87
  802134:	ff 75 0c             	pushl  0xc(%ebp)
  802137:	e8 3a e6 ff ff       	call   800776 <strcpy>
	return 0;
}
  80213c:	b8 00 00 00 00       	mov    $0x0,%eax
  802141:	c9                   	leave  
  802142:	c3                   	ret    

00802143 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802143:	55                   	push   %ebp
  802144:	89 e5                	mov    %esp,%ebp
  802146:	57                   	push   %edi
  802147:	56                   	push   %esi
  802148:	53                   	push   %ebx
  802149:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80214f:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802154:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80215a:	eb 2d                	jmp    802189 <devcons_write+0x46>
		m = n - tot;
  80215c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80215f:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802161:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802164:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802169:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80216c:	83 ec 04             	sub    $0x4,%esp
  80216f:	53                   	push   %ebx
  802170:	03 45 0c             	add    0xc(%ebp),%eax
  802173:	50                   	push   %eax
  802174:	57                   	push   %edi
  802175:	e8 8e e7 ff ff       	call   800908 <memmove>
		sys_cputs(buf, m);
  80217a:	83 c4 08             	add    $0x8,%esp
  80217d:	53                   	push   %ebx
  80217e:	57                   	push   %edi
  80217f:	e8 39 e9 ff ff       	call   800abd <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802184:	01 de                	add    %ebx,%esi
  802186:	83 c4 10             	add    $0x10,%esp
  802189:	89 f0                	mov    %esi,%eax
  80218b:	3b 75 10             	cmp    0x10(%ebp),%esi
  80218e:	72 cc                	jb     80215c <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802190:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802193:	5b                   	pop    %ebx
  802194:	5e                   	pop    %esi
  802195:	5f                   	pop    %edi
  802196:	5d                   	pop    %ebp
  802197:	c3                   	ret    

00802198 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802198:	55                   	push   %ebp
  802199:	89 e5                	mov    %esp,%ebp
  80219b:	83 ec 08             	sub    $0x8,%esp
  80219e:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8021a3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8021a7:	74 2a                	je     8021d3 <devcons_read+0x3b>
  8021a9:	eb 05                	jmp    8021b0 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8021ab:	e8 aa e9 ff ff       	call   800b5a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8021b0:	e8 26 e9 ff ff       	call   800adb <sys_cgetc>
  8021b5:	85 c0                	test   %eax,%eax
  8021b7:	74 f2                	je     8021ab <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8021b9:	85 c0                	test   %eax,%eax
  8021bb:	78 16                	js     8021d3 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8021bd:	83 f8 04             	cmp    $0x4,%eax
  8021c0:	74 0c                	je     8021ce <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8021c2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021c5:	88 02                	mov    %al,(%edx)
	return 1;
  8021c7:	b8 01 00 00 00       	mov    $0x1,%eax
  8021cc:	eb 05                	jmp    8021d3 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8021ce:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8021d3:	c9                   	leave  
  8021d4:	c3                   	ret    

008021d5 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8021d5:	55                   	push   %ebp
  8021d6:	89 e5                	mov    %esp,%ebp
  8021d8:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8021db:	8b 45 08             	mov    0x8(%ebp),%eax
  8021de:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8021e1:	6a 01                	push   $0x1
  8021e3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8021e6:	50                   	push   %eax
  8021e7:	e8 d1 e8 ff ff       	call   800abd <sys_cputs>
}
  8021ec:	83 c4 10             	add    $0x10,%esp
  8021ef:	c9                   	leave  
  8021f0:	c3                   	ret    

008021f1 <getchar>:

int
getchar(void)
{
  8021f1:	55                   	push   %ebp
  8021f2:	89 e5                	mov    %esp,%ebp
  8021f4:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8021f7:	6a 01                	push   $0x1
  8021f9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8021fc:	50                   	push   %eax
  8021fd:	6a 00                	push   $0x0
  8021ff:	e8 00 f2 ff ff       	call   801404 <read>
	if (r < 0)
  802204:	83 c4 10             	add    $0x10,%esp
  802207:	85 c0                	test   %eax,%eax
  802209:	78 0f                	js     80221a <getchar+0x29>
		return r;
	if (r < 1)
  80220b:	85 c0                	test   %eax,%eax
  80220d:	7e 06                	jle    802215 <getchar+0x24>
		return -E_EOF;
	return c;
  80220f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802213:	eb 05                	jmp    80221a <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802215:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80221a:	c9                   	leave  
  80221b:	c3                   	ret    

0080221c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80221c:	55                   	push   %ebp
  80221d:	89 e5                	mov    %esp,%ebp
  80221f:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802222:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802225:	50                   	push   %eax
  802226:	ff 75 08             	pushl  0x8(%ebp)
  802229:	e8 70 ef ff ff       	call   80119e <fd_lookup>
  80222e:	83 c4 10             	add    $0x10,%esp
  802231:	85 c0                	test   %eax,%eax
  802233:	78 11                	js     802246 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802235:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802238:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80223e:	39 10                	cmp    %edx,(%eax)
  802240:	0f 94 c0             	sete   %al
  802243:	0f b6 c0             	movzbl %al,%eax
}
  802246:	c9                   	leave  
  802247:	c3                   	ret    

00802248 <opencons>:

int
opencons(void)
{
  802248:	55                   	push   %ebp
  802249:	89 e5                	mov    %esp,%ebp
  80224b:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80224e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802251:	50                   	push   %eax
  802252:	e8 f8 ee ff ff       	call   80114f <fd_alloc>
  802257:	83 c4 10             	add    $0x10,%esp
		return r;
  80225a:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80225c:	85 c0                	test   %eax,%eax
  80225e:	78 3e                	js     80229e <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802260:	83 ec 04             	sub    $0x4,%esp
  802263:	68 07 04 00 00       	push   $0x407
  802268:	ff 75 f4             	pushl  -0xc(%ebp)
  80226b:	6a 00                	push   $0x0
  80226d:	e8 07 e9 ff ff       	call   800b79 <sys_page_alloc>
  802272:	83 c4 10             	add    $0x10,%esp
		return r;
  802275:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802277:	85 c0                	test   %eax,%eax
  802279:	78 23                	js     80229e <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80227b:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802281:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802284:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802286:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802289:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802290:	83 ec 0c             	sub    $0xc,%esp
  802293:	50                   	push   %eax
  802294:	e8 8f ee ff ff       	call   801128 <fd2num>
  802299:	89 c2                	mov    %eax,%edx
  80229b:	83 c4 10             	add    $0x10,%esp
}
  80229e:	89 d0                	mov    %edx,%eax
  8022a0:	c9                   	leave  
  8022a1:	c3                   	ret    

008022a2 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8022a2:	55                   	push   %ebp
  8022a3:	89 e5                	mov    %esp,%ebp
  8022a5:	56                   	push   %esi
  8022a6:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8022a7:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8022aa:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8022b0:	e8 86 e8 ff ff       	call   800b3b <sys_getenvid>
  8022b5:	83 ec 0c             	sub    $0xc,%esp
  8022b8:	ff 75 0c             	pushl  0xc(%ebp)
  8022bb:	ff 75 08             	pushl  0x8(%ebp)
  8022be:	56                   	push   %esi
  8022bf:	50                   	push   %eax
  8022c0:	68 94 2b 80 00       	push   $0x802b94
  8022c5:	e8 27 df ff ff       	call   8001f1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8022ca:	83 c4 18             	add    $0x18,%esp
  8022cd:	53                   	push   %ebx
  8022ce:	ff 75 10             	pushl  0x10(%ebp)
  8022d1:	e8 ca de ff ff       	call   8001a0 <vcprintf>
	cprintf("\n");
  8022d6:	c7 04 24 80 2b 80 00 	movl   $0x802b80,(%esp)
  8022dd:	e8 0f df ff ff       	call   8001f1 <cprintf>
  8022e2:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8022e5:	cc                   	int3   
  8022e6:	eb fd                	jmp    8022e5 <_panic+0x43>

008022e8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8022e8:	55                   	push   %ebp
  8022e9:	89 e5                	mov    %esp,%ebp
  8022eb:	53                   	push   %ebx
  8022ec:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  8022ef:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8022f6:	75 28                	jne    802320 <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  8022f8:	e8 3e e8 ff ff       	call   800b3b <sys_getenvid>
  8022fd:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_U | PTE_W);
  8022ff:	83 ec 04             	sub    $0x4,%esp
  802302:	6a 06                	push   $0x6
  802304:	68 00 f0 bf ee       	push   $0xeebff000
  802309:	50                   	push   %eax
  80230a:	e8 6a e8 ff ff       	call   800b79 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  80230f:	83 c4 08             	add    $0x8,%esp
  802312:	68 2d 23 80 00       	push   $0x80232d
  802317:	53                   	push   %ebx
  802318:	e8 a7 e9 ff ff       	call   800cc4 <sys_env_set_pgfault_upcall>
  80231d:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802320:	8b 45 08             	mov    0x8(%ebp),%eax
  802323:	a3 00 70 80 00       	mov    %eax,0x807000
}
  802328:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80232b:	c9                   	leave  
  80232c:	c3                   	ret    

0080232d <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80232d:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80232e:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802333:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802335:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	# My method is different. Copy the values to the other stack
	# in a convinient way, and then pop everything.
	movl %esp, %ebp		# ebp refers to the exception stack
  802338:	89 e5                	mov    %esp,%ebp
	movl 48(%ebp), %esp 	# go to other stack
  80233a:	8b 65 30             	mov    0x30(%ebp),%esp

	pushl 40(%ebp)		# eip - ORDER SWITCHED WITH EFLAGS
  80233d:	ff 75 28             	pushl  0x28(%ebp)
	pushl 44(%ebp)      	# eflags
  802340:	ff 75 2c             	pushl  0x2c(%ebp)
	pushl 36(%ebp)		# all the 8 remaining regs
  802343:	ff 75 24             	pushl  0x24(%ebp)
	pushl 32(%ebp)
  802346:	ff 75 20             	pushl  0x20(%ebp)
	pushl 28(%ebp)
  802349:	ff 75 1c             	pushl  0x1c(%ebp)
	pushl 24(%ebp)
  80234c:	ff 75 18             	pushl  0x18(%ebp)
	pushl 20(%ebp)
  80234f:	ff 75 14             	pushl  0x14(%ebp)
	pushl 16(%ebp)
  802352:	ff 75 10             	pushl  0x10(%ebp)
	pushl 12(%ebp)
  802355:	ff 75 0c             	pushl  0xc(%ebp)
	pushl 8(%ebp)
  802358:	ff 75 08             	pushl  0x8(%ebp)

	popal			# now just pop everything!
  80235b:	61                   	popa   
	popfl
  80235c:	9d                   	popf   
	ret
  80235d:	c3                   	ret    

0080235e <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80235e:	55                   	push   %ebp
  80235f:	89 e5                	mov    %esp,%ebp
  802361:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802364:	89 d0                	mov    %edx,%eax
  802366:	c1 e8 16             	shr    $0x16,%eax
  802369:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802370:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802375:	f6 c1 01             	test   $0x1,%cl
  802378:	74 1d                	je     802397 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80237a:	c1 ea 0c             	shr    $0xc,%edx
  80237d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802384:	f6 c2 01             	test   $0x1,%dl
  802387:	74 0e                	je     802397 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802389:	c1 ea 0c             	shr    $0xc,%edx
  80238c:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802393:	ef 
  802394:	0f b7 c0             	movzwl %ax,%eax
}
  802397:	5d                   	pop    %ebp
  802398:	c3                   	ret    
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
