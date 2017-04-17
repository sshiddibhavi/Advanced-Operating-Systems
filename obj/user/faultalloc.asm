
obj/user/faultalloc.debug:     file format elf32-i386


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
  80002c:	e8 99 00 00 00       	call   8000ca <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80003a:	8b 45 08             	mov    0x8(%ebp),%eax
  80003d:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  80003f:	53                   	push   %ebx
  800040:	68 60 23 80 00       	push   $0x802360
  800045:	e8 b9 01 00 00       	call   800203 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 2d 0b 00 00       	call   800b8b <sys_page_alloc>
  80005e:	83 c4 10             	add    $0x10,%esp
  800061:	85 c0                	test   %eax,%eax
  800063:	79 16                	jns    80007b <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800065:	83 ec 0c             	sub    $0xc,%esp
  800068:	50                   	push   %eax
  800069:	53                   	push   %ebx
  80006a:	68 80 23 80 00       	push   $0x802380
  80006f:	6a 0e                	push   $0xe
  800071:	68 6a 23 80 00       	push   $0x80236a
  800076:	e8 af 00 00 00       	call   80012a <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  80007b:	53                   	push   %ebx
  80007c:	68 ac 23 80 00       	push   $0x8023ac
  800081:	6a 64                	push   $0x64
  800083:	53                   	push   %ebx
  800084:	e8 ac 06 00 00       	call   800735 <snprintf>
}
  800089:	83 c4 10             	add    $0x10,%esp
  80008c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80008f:	c9                   	leave  
  800090:	c3                   	ret    

00800091 <umain>:

void
umain(int argc, char **argv)
{
  800091:	55                   	push   %ebp
  800092:	89 e5                	mov    %esp,%ebp
  800094:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800097:	68 33 00 80 00       	push   $0x800033
  80009c:	e8 fa 0c 00 00       	call   800d9b <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	68 ef be ad de       	push   $0xdeadbeef
  8000a9:	68 7c 23 80 00       	push   $0x80237c
  8000ae:	e8 50 01 00 00       	call   800203 <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000b3:	83 c4 08             	add    $0x8,%esp
  8000b6:	68 fe bf fe ca       	push   $0xcafebffe
  8000bb:	68 7c 23 80 00       	push   $0x80237c
  8000c0:	e8 3e 01 00 00       	call   800203 <cprintf>
}
  8000c5:	83 c4 10             	add    $0x10,%esp
  8000c8:	c9                   	leave  
  8000c9:	c3                   	ret    

008000ca <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000ca:	55                   	push   %ebp
  8000cb:	89 e5                	mov    %esp,%ebp
  8000cd:	56                   	push   %esi
  8000ce:	53                   	push   %ebx
  8000cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000d2:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000d5:	e8 73 0a 00 00       	call   800b4d <sys_getenvid>
  8000da:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000df:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000e2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000e7:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ec:	85 db                	test   %ebx,%ebx
  8000ee:	7e 07                	jle    8000f7 <libmain+0x2d>
		binaryname = argv[0];
  8000f0:	8b 06                	mov    (%esi),%eax
  8000f2:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000f7:	83 ec 08             	sub    $0x8,%esp
  8000fa:	56                   	push   %esi
  8000fb:	53                   	push   %ebx
  8000fc:	e8 90 ff ff ff       	call   800091 <umain>

	// exit gracefully
	exit();
  800101:	e8 0a 00 00 00       	call   800110 <exit>
}
  800106:	83 c4 10             	add    $0x10,%esp
  800109:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80010c:	5b                   	pop    %ebx
  80010d:	5e                   	pop    %esi
  80010e:	5d                   	pop    %ebp
  80010f:	c3                   	ret    

00800110 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800110:	55                   	push   %ebp
  800111:	89 e5                	mov    %esp,%ebp
  800113:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800116:	e8 c1 0e 00 00       	call   800fdc <close_all>
	sys_env_destroy(0);
  80011b:	83 ec 0c             	sub    $0xc,%esp
  80011e:	6a 00                	push   $0x0
  800120:	e8 e7 09 00 00       	call   800b0c <sys_env_destroy>
}
  800125:	83 c4 10             	add    $0x10,%esp
  800128:	c9                   	leave  
  800129:	c3                   	ret    

0080012a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80012a:	55                   	push   %ebp
  80012b:	89 e5                	mov    %esp,%ebp
  80012d:	56                   	push   %esi
  80012e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80012f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800132:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800138:	e8 10 0a 00 00       	call   800b4d <sys_getenvid>
  80013d:	83 ec 0c             	sub    $0xc,%esp
  800140:	ff 75 0c             	pushl  0xc(%ebp)
  800143:	ff 75 08             	pushl  0x8(%ebp)
  800146:	56                   	push   %esi
  800147:	50                   	push   %eax
  800148:	68 d8 23 80 00       	push   $0x8023d8
  80014d:	e8 b1 00 00 00       	call   800203 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800152:	83 c4 18             	add    $0x18,%esp
  800155:	53                   	push   %ebx
  800156:	ff 75 10             	pushl  0x10(%ebp)
  800159:	e8 54 00 00 00       	call   8001b2 <vcprintf>
	cprintf("\n");
  80015e:	c7 04 24 50 28 80 00 	movl   $0x802850,(%esp)
  800165:	e8 99 00 00 00       	call   800203 <cprintf>
  80016a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80016d:	cc                   	int3   
  80016e:	eb fd                	jmp    80016d <_panic+0x43>

00800170 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	53                   	push   %ebx
  800174:	83 ec 04             	sub    $0x4,%esp
  800177:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80017a:	8b 13                	mov    (%ebx),%edx
  80017c:	8d 42 01             	lea    0x1(%edx),%eax
  80017f:	89 03                	mov    %eax,(%ebx)
  800181:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800184:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800188:	3d ff 00 00 00       	cmp    $0xff,%eax
  80018d:	75 1a                	jne    8001a9 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80018f:	83 ec 08             	sub    $0x8,%esp
  800192:	68 ff 00 00 00       	push   $0xff
  800197:	8d 43 08             	lea    0x8(%ebx),%eax
  80019a:	50                   	push   %eax
  80019b:	e8 2f 09 00 00       	call   800acf <sys_cputs>
		b->idx = 0;
  8001a0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001a6:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001a9:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001b0:	c9                   	leave  
  8001b1:	c3                   	ret    

008001b2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001b2:	55                   	push   %ebp
  8001b3:	89 e5                	mov    %esp,%ebp
  8001b5:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001bb:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001c2:	00 00 00 
	b.cnt = 0;
  8001c5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001cc:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001cf:	ff 75 0c             	pushl  0xc(%ebp)
  8001d2:	ff 75 08             	pushl  0x8(%ebp)
  8001d5:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001db:	50                   	push   %eax
  8001dc:	68 70 01 80 00       	push   $0x800170
  8001e1:	e8 54 01 00 00       	call   80033a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001e6:	83 c4 08             	add    $0x8,%esp
  8001e9:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001ef:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001f5:	50                   	push   %eax
  8001f6:	e8 d4 08 00 00       	call   800acf <sys_cputs>

	return b.cnt;
}
  8001fb:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800201:	c9                   	leave  
  800202:	c3                   	ret    

00800203 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800203:	55                   	push   %ebp
  800204:	89 e5                	mov    %esp,%ebp
  800206:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800209:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80020c:	50                   	push   %eax
  80020d:	ff 75 08             	pushl  0x8(%ebp)
  800210:	e8 9d ff ff ff       	call   8001b2 <vcprintf>
	va_end(ap);

	return cnt;
}
  800215:	c9                   	leave  
  800216:	c3                   	ret    

00800217 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800217:	55                   	push   %ebp
  800218:	89 e5                	mov    %esp,%ebp
  80021a:	57                   	push   %edi
  80021b:	56                   	push   %esi
  80021c:	53                   	push   %ebx
  80021d:	83 ec 1c             	sub    $0x1c,%esp
  800220:	89 c7                	mov    %eax,%edi
  800222:	89 d6                	mov    %edx,%esi
  800224:	8b 45 08             	mov    0x8(%ebp),%eax
  800227:	8b 55 0c             	mov    0xc(%ebp),%edx
  80022a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80022d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800230:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800233:	bb 00 00 00 00       	mov    $0x0,%ebx
  800238:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80023b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80023e:	39 d3                	cmp    %edx,%ebx
  800240:	72 05                	jb     800247 <printnum+0x30>
  800242:	39 45 10             	cmp    %eax,0x10(%ebp)
  800245:	77 45                	ja     80028c <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800247:	83 ec 0c             	sub    $0xc,%esp
  80024a:	ff 75 18             	pushl  0x18(%ebp)
  80024d:	8b 45 14             	mov    0x14(%ebp),%eax
  800250:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800253:	53                   	push   %ebx
  800254:	ff 75 10             	pushl  0x10(%ebp)
  800257:	83 ec 08             	sub    $0x8,%esp
  80025a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80025d:	ff 75 e0             	pushl  -0x20(%ebp)
  800260:	ff 75 dc             	pushl  -0x24(%ebp)
  800263:	ff 75 d8             	pushl  -0x28(%ebp)
  800266:	e8 55 1e 00 00       	call   8020c0 <__udivdi3>
  80026b:	83 c4 18             	add    $0x18,%esp
  80026e:	52                   	push   %edx
  80026f:	50                   	push   %eax
  800270:	89 f2                	mov    %esi,%edx
  800272:	89 f8                	mov    %edi,%eax
  800274:	e8 9e ff ff ff       	call   800217 <printnum>
  800279:	83 c4 20             	add    $0x20,%esp
  80027c:	eb 18                	jmp    800296 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80027e:	83 ec 08             	sub    $0x8,%esp
  800281:	56                   	push   %esi
  800282:	ff 75 18             	pushl  0x18(%ebp)
  800285:	ff d7                	call   *%edi
  800287:	83 c4 10             	add    $0x10,%esp
  80028a:	eb 03                	jmp    80028f <printnum+0x78>
  80028c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80028f:	83 eb 01             	sub    $0x1,%ebx
  800292:	85 db                	test   %ebx,%ebx
  800294:	7f e8                	jg     80027e <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800296:	83 ec 08             	sub    $0x8,%esp
  800299:	56                   	push   %esi
  80029a:	83 ec 04             	sub    $0x4,%esp
  80029d:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002a0:	ff 75 e0             	pushl  -0x20(%ebp)
  8002a3:	ff 75 dc             	pushl  -0x24(%ebp)
  8002a6:	ff 75 d8             	pushl  -0x28(%ebp)
  8002a9:	e8 42 1f 00 00       	call   8021f0 <__umoddi3>
  8002ae:	83 c4 14             	add    $0x14,%esp
  8002b1:	0f be 80 fb 23 80 00 	movsbl 0x8023fb(%eax),%eax
  8002b8:	50                   	push   %eax
  8002b9:	ff d7                	call   *%edi
}
  8002bb:	83 c4 10             	add    $0x10,%esp
  8002be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c1:	5b                   	pop    %ebx
  8002c2:	5e                   	pop    %esi
  8002c3:	5f                   	pop    %edi
  8002c4:	5d                   	pop    %ebp
  8002c5:	c3                   	ret    

008002c6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002c6:	55                   	push   %ebp
  8002c7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002c9:	83 fa 01             	cmp    $0x1,%edx
  8002cc:	7e 0e                	jle    8002dc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002ce:	8b 10                	mov    (%eax),%edx
  8002d0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002d3:	89 08                	mov    %ecx,(%eax)
  8002d5:	8b 02                	mov    (%edx),%eax
  8002d7:	8b 52 04             	mov    0x4(%edx),%edx
  8002da:	eb 22                	jmp    8002fe <getuint+0x38>
	else if (lflag)
  8002dc:	85 d2                	test   %edx,%edx
  8002de:	74 10                	je     8002f0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002e0:	8b 10                	mov    (%eax),%edx
  8002e2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e5:	89 08                	mov    %ecx,(%eax)
  8002e7:	8b 02                	mov    (%edx),%eax
  8002e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ee:	eb 0e                	jmp    8002fe <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002f0:	8b 10                	mov    (%eax),%edx
  8002f2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f5:	89 08                	mov    %ecx,(%eax)
  8002f7:	8b 02                	mov    (%edx),%eax
  8002f9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002fe:	5d                   	pop    %ebp
  8002ff:	c3                   	ret    

00800300 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800300:	55                   	push   %ebp
  800301:	89 e5                	mov    %esp,%ebp
  800303:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800306:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80030a:	8b 10                	mov    (%eax),%edx
  80030c:	3b 50 04             	cmp    0x4(%eax),%edx
  80030f:	73 0a                	jae    80031b <sprintputch+0x1b>
		*b->buf++ = ch;
  800311:	8d 4a 01             	lea    0x1(%edx),%ecx
  800314:	89 08                	mov    %ecx,(%eax)
  800316:	8b 45 08             	mov    0x8(%ebp),%eax
  800319:	88 02                	mov    %al,(%edx)
}
  80031b:	5d                   	pop    %ebp
  80031c:	c3                   	ret    

0080031d <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80031d:	55                   	push   %ebp
  80031e:	89 e5                	mov    %esp,%ebp
  800320:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800323:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800326:	50                   	push   %eax
  800327:	ff 75 10             	pushl  0x10(%ebp)
  80032a:	ff 75 0c             	pushl  0xc(%ebp)
  80032d:	ff 75 08             	pushl  0x8(%ebp)
  800330:	e8 05 00 00 00       	call   80033a <vprintfmt>
	va_end(ap);
}
  800335:	83 c4 10             	add    $0x10,%esp
  800338:	c9                   	leave  
  800339:	c3                   	ret    

0080033a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80033a:	55                   	push   %ebp
  80033b:	89 e5                	mov    %esp,%ebp
  80033d:	57                   	push   %edi
  80033e:	56                   	push   %esi
  80033f:	53                   	push   %ebx
  800340:	83 ec 2c             	sub    $0x2c,%esp
  800343:	8b 75 08             	mov    0x8(%ebp),%esi
  800346:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800349:	8b 7d 10             	mov    0x10(%ebp),%edi
  80034c:	eb 12                	jmp    800360 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80034e:	85 c0                	test   %eax,%eax
  800350:	0f 84 89 03 00 00    	je     8006df <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800356:	83 ec 08             	sub    $0x8,%esp
  800359:	53                   	push   %ebx
  80035a:	50                   	push   %eax
  80035b:	ff d6                	call   *%esi
  80035d:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800360:	83 c7 01             	add    $0x1,%edi
  800363:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800367:	83 f8 25             	cmp    $0x25,%eax
  80036a:	75 e2                	jne    80034e <vprintfmt+0x14>
  80036c:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800370:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800377:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80037e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800385:	ba 00 00 00 00       	mov    $0x0,%edx
  80038a:	eb 07                	jmp    800393 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038c:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80038f:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800393:	8d 47 01             	lea    0x1(%edi),%eax
  800396:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800399:	0f b6 07             	movzbl (%edi),%eax
  80039c:	0f b6 c8             	movzbl %al,%ecx
  80039f:	83 e8 23             	sub    $0x23,%eax
  8003a2:	3c 55                	cmp    $0x55,%al
  8003a4:	0f 87 1a 03 00 00    	ja     8006c4 <vprintfmt+0x38a>
  8003aa:	0f b6 c0             	movzbl %al,%eax
  8003ad:	ff 24 85 40 25 80 00 	jmp    *0x802540(,%eax,4)
  8003b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003b7:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003bb:	eb d6                	jmp    800393 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8003c5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003c8:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003cb:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003cf:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003d2:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003d5:	83 fa 09             	cmp    $0x9,%edx
  8003d8:	77 39                	ja     800413 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003da:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003dd:	eb e9                	jmp    8003c8 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003df:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e2:	8d 48 04             	lea    0x4(%eax),%ecx
  8003e5:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003e8:	8b 00                	mov    (%eax),%eax
  8003ea:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003f0:	eb 27                	jmp    800419 <vprintfmt+0xdf>
  8003f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003f5:	85 c0                	test   %eax,%eax
  8003f7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003fc:	0f 49 c8             	cmovns %eax,%ecx
  8003ff:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800402:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800405:	eb 8c                	jmp    800393 <vprintfmt+0x59>
  800407:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80040a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800411:	eb 80                	jmp    800393 <vprintfmt+0x59>
  800413:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800416:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800419:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80041d:	0f 89 70 ff ff ff    	jns    800393 <vprintfmt+0x59>
				width = precision, precision = -1;
  800423:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800426:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800429:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800430:	e9 5e ff ff ff       	jmp    800393 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800435:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800438:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80043b:	e9 53 ff ff ff       	jmp    800393 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800440:	8b 45 14             	mov    0x14(%ebp),%eax
  800443:	8d 50 04             	lea    0x4(%eax),%edx
  800446:	89 55 14             	mov    %edx,0x14(%ebp)
  800449:	83 ec 08             	sub    $0x8,%esp
  80044c:	53                   	push   %ebx
  80044d:	ff 30                	pushl  (%eax)
  80044f:	ff d6                	call   *%esi
			break;
  800451:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800454:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800457:	e9 04 ff ff ff       	jmp    800360 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80045c:	8b 45 14             	mov    0x14(%ebp),%eax
  80045f:	8d 50 04             	lea    0x4(%eax),%edx
  800462:	89 55 14             	mov    %edx,0x14(%ebp)
  800465:	8b 00                	mov    (%eax),%eax
  800467:	99                   	cltd   
  800468:	31 d0                	xor    %edx,%eax
  80046a:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80046c:	83 f8 0f             	cmp    $0xf,%eax
  80046f:	7f 0b                	jg     80047c <vprintfmt+0x142>
  800471:	8b 14 85 a0 26 80 00 	mov    0x8026a0(,%eax,4),%edx
  800478:	85 d2                	test   %edx,%edx
  80047a:	75 18                	jne    800494 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80047c:	50                   	push   %eax
  80047d:	68 13 24 80 00       	push   $0x802413
  800482:	53                   	push   %ebx
  800483:	56                   	push   %esi
  800484:	e8 94 fe ff ff       	call   80031d <printfmt>
  800489:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80048f:	e9 cc fe ff ff       	jmp    800360 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800494:	52                   	push   %edx
  800495:	68 de 27 80 00       	push   $0x8027de
  80049a:	53                   	push   %ebx
  80049b:	56                   	push   %esi
  80049c:	e8 7c fe ff ff       	call   80031d <printfmt>
  8004a1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004a7:	e9 b4 fe ff ff       	jmp    800360 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8004af:	8d 50 04             	lea    0x4(%eax),%edx
  8004b2:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b5:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004b7:	85 ff                	test   %edi,%edi
  8004b9:	b8 0c 24 80 00       	mov    $0x80240c,%eax
  8004be:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004c1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004c5:	0f 8e 94 00 00 00    	jle    80055f <vprintfmt+0x225>
  8004cb:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004cf:	0f 84 98 00 00 00    	je     80056d <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d5:	83 ec 08             	sub    $0x8,%esp
  8004d8:	ff 75 d0             	pushl  -0x30(%ebp)
  8004db:	57                   	push   %edi
  8004dc:	e8 86 02 00 00       	call   800767 <strnlen>
  8004e1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004e4:	29 c1                	sub    %eax,%ecx
  8004e6:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004e9:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004ec:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004f0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004f3:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004f6:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f8:	eb 0f                	jmp    800509 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004fa:	83 ec 08             	sub    $0x8,%esp
  8004fd:	53                   	push   %ebx
  8004fe:	ff 75 e0             	pushl  -0x20(%ebp)
  800501:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800503:	83 ef 01             	sub    $0x1,%edi
  800506:	83 c4 10             	add    $0x10,%esp
  800509:	85 ff                	test   %edi,%edi
  80050b:	7f ed                	jg     8004fa <vprintfmt+0x1c0>
  80050d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800510:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800513:	85 c9                	test   %ecx,%ecx
  800515:	b8 00 00 00 00       	mov    $0x0,%eax
  80051a:	0f 49 c1             	cmovns %ecx,%eax
  80051d:	29 c1                	sub    %eax,%ecx
  80051f:	89 75 08             	mov    %esi,0x8(%ebp)
  800522:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800525:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800528:	89 cb                	mov    %ecx,%ebx
  80052a:	eb 4d                	jmp    800579 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80052c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800530:	74 1b                	je     80054d <vprintfmt+0x213>
  800532:	0f be c0             	movsbl %al,%eax
  800535:	83 e8 20             	sub    $0x20,%eax
  800538:	83 f8 5e             	cmp    $0x5e,%eax
  80053b:	76 10                	jbe    80054d <vprintfmt+0x213>
					putch('?', putdat);
  80053d:	83 ec 08             	sub    $0x8,%esp
  800540:	ff 75 0c             	pushl  0xc(%ebp)
  800543:	6a 3f                	push   $0x3f
  800545:	ff 55 08             	call   *0x8(%ebp)
  800548:	83 c4 10             	add    $0x10,%esp
  80054b:	eb 0d                	jmp    80055a <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80054d:	83 ec 08             	sub    $0x8,%esp
  800550:	ff 75 0c             	pushl  0xc(%ebp)
  800553:	52                   	push   %edx
  800554:	ff 55 08             	call   *0x8(%ebp)
  800557:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80055a:	83 eb 01             	sub    $0x1,%ebx
  80055d:	eb 1a                	jmp    800579 <vprintfmt+0x23f>
  80055f:	89 75 08             	mov    %esi,0x8(%ebp)
  800562:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800565:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800568:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80056b:	eb 0c                	jmp    800579 <vprintfmt+0x23f>
  80056d:	89 75 08             	mov    %esi,0x8(%ebp)
  800570:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800573:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800576:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800579:	83 c7 01             	add    $0x1,%edi
  80057c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800580:	0f be d0             	movsbl %al,%edx
  800583:	85 d2                	test   %edx,%edx
  800585:	74 23                	je     8005aa <vprintfmt+0x270>
  800587:	85 f6                	test   %esi,%esi
  800589:	78 a1                	js     80052c <vprintfmt+0x1f2>
  80058b:	83 ee 01             	sub    $0x1,%esi
  80058e:	79 9c                	jns    80052c <vprintfmt+0x1f2>
  800590:	89 df                	mov    %ebx,%edi
  800592:	8b 75 08             	mov    0x8(%ebp),%esi
  800595:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800598:	eb 18                	jmp    8005b2 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80059a:	83 ec 08             	sub    $0x8,%esp
  80059d:	53                   	push   %ebx
  80059e:	6a 20                	push   $0x20
  8005a0:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005a2:	83 ef 01             	sub    $0x1,%edi
  8005a5:	83 c4 10             	add    $0x10,%esp
  8005a8:	eb 08                	jmp    8005b2 <vprintfmt+0x278>
  8005aa:	89 df                	mov    %ebx,%edi
  8005ac:	8b 75 08             	mov    0x8(%ebp),%esi
  8005af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005b2:	85 ff                	test   %edi,%edi
  8005b4:	7f e4                	jg     80059a <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005b9:	e9 a2 fd ff ff       	jmp    800360 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005be:	83 fa 01             	cmp    $0x1,%edx
  8005c1:	7e 16                	jle    8005d9 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c6:	8d 50 08             	lea    0x8(%eax),%edx
  8005c9:	89 55 14             	mov    %edx,0x14(%ebp)
  8005cc:	8b 50 04             	mov    0x4(%eax),%edx
  8005cf:	8b 00                	mov    (%eax),%eax
  8005d1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005d7:	eb 32                	jmp    80060b <vprintfmt+0x2d1>
	else if (lflag)
  8005d9:	85 d2                	test   %edx,%edx
  8005db:	74 18                	je     8005f5 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e0:	8d 50 04             	lea    0x4(%eax),%edx
  8005e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e6:	8b 00                	mov    (%eax),%eax
  8005e8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005eb:	89 c1                	mov    %eax,%ecx
  8005ed:	c1 f9 1f             	sar    $0x1f,%ecx
  8005f0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005f3:	eb 16                	jmp    80060b <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f8:	8d 50 04             	lea    0x4(%eax),%edx
  8005fb:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fe:	8b 00                	mov    (%eax),%eax
  800600:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800603:	89 c1                	mov    %eax,%ecx
  800605:	c1 f9 1f             	sar    $0x1f,%ecx
  800608:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80060b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80060e:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800611:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800616:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80061a:	79 74                	jns    800690 <vprintfmt+0x356>
				putch('-', putdat);
  80061c:	83 ec 08             	sub    $0x8,%esp
  80061f:	53                   	push   %ebx
  800620:	6a 2d                	push   $0x2d
  800622:	ff d6                	call   *%esi
				num = -(long long) num;
  800624:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800627:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80062a:	f7 d8                	neg    %eax
  80062c:	83 d2 00             	adc    $0x0,%edx
  80062f:	f7 da                	neg    %edx
  800631:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800634:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800639:	eb 55                	jmp    800690 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80063b:	8d 45 14             	lea    0x14(%ebp),%eax
  80063e:	e8 83 fc ff ff       	call   8002c6 <getuint>
			base = 10;
  800643:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800648:	eb 46                	jmp    800690 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80064a:	8d 45 14             	lea    0x14(%ebp),%eax
  80064d:	e8 74 fc ff ff       	call   8002c6 <getuint>
                        base = 8;
  800652:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800657:	eb 37                	jmp    800690 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800659:	83 ec 08             	sub    $0x8,%esp
  80065c:	53                   	push   %ebx
  80065d:	6a 30                	push   $0x30
  80065f:	ff d6                	call   *%esi
			putch('x', putdat);
  800661:	83 c4 08             	add    $0x8,%esp
  800664:	53                   	push   %ebx
  800665:	6a 78                	push   $0x78
  800667:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800669:	8b 45 14             	mov    0x14(%ebp),%eax
  80066c:	8d 50 04             	lea    0x4(%eax),%edx
  80066f:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800672:	8b 00                	mov    (%eax),%eax
  800674:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800679:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80067c:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800681:	eb 0d                	jmp    800690 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800683:	8d 45 14             	lea    0x14(%ebp),%eax
  800686:	e8 3b fc ff ff       	call   8002c6 <getuint>
			base = 16;
  80068b:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800690:	83 ec 0c             	sub    $0xc,%esp
  800693:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800697:	57                   	push   %edi
  800698:	ff 75 e0             	pushl  -0x20(%ebp)
  80069b:	51                   	push   %ecx
  80069c:	52                   	push   %edx
  80069d:	50                   	push   %eax
  80069e:	89 da                	mov    %ebx,%edx
  8006a0:	89 f0                	mov    %esi,%eax
  8006a2:	e8 70 fb ff ff       	call   800217 <printnum>
			break;
  8006a7:	83 c4 20             	add    $0x20,%esp
  8006aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006ad:	e9 ae fc ff ff       	jmp    800360 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006b2:	83 ec 08             	sub    $0x8,%esp
  8006b5:	53                   	push   %ebx
  8006b6:	51                   	push   %ecx
  8006b7:	ff d6                	call   *%esi
			break;
  8006b9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006bf:	e9 9c fc ff ff       	jmp    800360 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006c4:	83 ec 08             	sub    $0x8,%esp
  8006c7:	53                   	push   %ebx
  8006c8:	6a 25                	push   $0x25
  8006ca:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006cc:	83 c4 10             	add    $0x10,%esp
  8006cf:	eb 03                	jmp    8006d4 <vprintfmt+0x39a>
  8006d1:	83 ef 01             	sub    $0x1,%edi
  8006d4:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006d8:	75 f7                	jne    8006d1 <vprintfmt+0x397>
  8006da:	e9 81 fc ff ff       	jmp    800360 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006e2:	5b                   	pop    %ebx
  8006e3:	5e                   	pop    %esi
  8006e4:	5f                   	pop    %edi
  8006e5:	5d                   	pop    %ebp
  8006e6:	c3                   	ret    

008006e7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006e7:	55                   	push   %ebp
  8006e8:	89 e5                	mov    %esp,%ebp
  8006ea:	83 ec 18             	sub    $0x18,%esp
  8006ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006f3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006f6:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006fa:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006fd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800704:	85 c0                	test   %eax,%eax
  800706:	74 26                	je     80072e <vsnprintf+0x47>
  800708:	85 d2                	test   %edx,%edx
  80070a:	7e 22                	jle    80072e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80070c:	ff 75 14             	pushl  0x14(%ebp)
  80070f:	ff 75 10             	pushl  0x10(%ebp)
  800712:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800715:	50                   	push   %eax
  800716:	68 00 03 80 00       	push   $0x800300
  80071b:	e8 1a fc ff ff       	call   80033a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800720:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800723:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800726:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800729:	83 c4 10             	add    $0x10,%esp
  80072c:	eb 05                	jmp    800733 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80072e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800733:	c9                   	leave  
  800734:	c3                   	ret    

00800735 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800735:	55                   	push   %ebp
  800736:	89 e5                	mov    %esp,%ebp
  800738:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80073b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80073e:	50                   	push   %eax
  80073f:	ff 75 10             	pushl  0x10(%ebp)
  800742:	ff 75 0c             	pushl  0xc(%ebp)
  800745:	ff 75 08             	pushl  0x8(%ebp)
  800748:	e8 9a ff ff ff       	call   8006e7 <vsnprintf>
	va_end(ap);

	return rc;
}
  80074d:	c9                   	leave  
  80074e:	c3                   	ret    

0080074f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80074f:	55                   	push   %ebp
  800750:	89 e5                	mov    %esp,%ebp
  800752:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800755:	b8 00 00 00 00       	mov    $0x0,%eax
  80075a:	eb 03                	jmp    80075f <strlen+0x10>
		n++;
  80075c:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80075f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800763:	75 f7                	jne    80075c <strlen+0xd>
		n++;
	return n;
}
  800765:	5d                   	pop    %ebp
  800766:	c3                   	ret    

00800767 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800767:	55                   	push   %ebp
  800768:	89 e5                	mov    %esp,%ebp
  80076a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80076d:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800770:	ba 00 00 00 00       	mov    $0x0,%edx
  800775:	eb 03                	jmp    80077a <strnlen+0x13>
		n++;
  800777:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80077a:	39 c2                	cmp    %eax,%edx
  80077c:	74 08                	je     800786 <strnlen+0x1f>
  80077e:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800782:	75 f3                	jne    800777 <strnlen+0x10>
  800784:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800786:	5d                   	pop    %ebp
  800787:	c3                   	ret    

00800788 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800788:	55                   	push   %ebp
  800789:	89 e5                	mov    %esp,%ebp
  80078b:	53                   	push   %ebx
  80078c:	8b 45 08             	mov    0x8(%ebp),%eax
  80078f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800792:	89 c2                	mov    %eax,%edx
  800794:	83 c2 01             	add    $0x1,%edx
  800797:	83 c1 01             	add    $0x1,%ecx
  80079a:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80079e:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007a1:	84 db                	test   %bl,%bl
  8007a3:	75 ef                	jne    800794 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007a5:	5b                   	pop    %ebx
  8007a6:	5d                   	pop    %ebp
  8007a7:	c3                   	ret    

008007a8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007a8:	55                   	push   %ebp
  8007a9:	89 e5                	mov    %esp,%ebp
  8007ab:	53                   	push   %ebx
  8007ac:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007af:	53                   	push   %ebx
  8007b0:	e8 9a ff ff ff       	call   80074f <strlen>
  8007b5:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007b8:	ff 75 0c             	pushl  0xc(%ebp)
  8007bb:	01 d8                	add    %ebx,%eax
  8007bd:	50                   	push   %eax
  8007be:	e8 c5 ff ff ff       	call   800788 <strcpy>
	return dst;
}
  8007c3:	89 d8                	mov    %ebx,%eax
  8007c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007c8:	c9                   	leave  
  8007c9:	c3                   	ret    

008007ca <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007ca:	55                   	push   %ebp
  8007cb:	89 e5                	mov    %esp,%ebp
  8007cd:	56                   	push   %esi
  8007ce:	53                   	push   %ebx
  8007cf:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007d5:	89 f3                	mov    %esi,%ebx
  8007d7:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007da:	89 f2                	mov    %esi,%edx
  8007dc:	eb 0f                	jmp    8007ed <strncpy+0x23>
		*dst++ = *src;
  8007de:	83 c2 01             	add    $0x1,%edx
  8007e1:	0f b6 01             	movzbl (%ecx),%eax
  8007e4:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007e7:	80 39 01             	cmpb   $0x1,(%ecx)
  8007ea:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007ed:	39 da                	cmp    %ebx,%edx
  8007ef:	75 ed                	jne    8007de <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007f1:	89 f0                	mov    %esi,%eax
  8007f3:	5b                   	pop    %ebx
  8007f4:	5e                   	pop    %esi
  8007f5:	5d                   	pop    %ebp
  8007f6:	c3                   	ret    

008007f7 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007f7:	55                   	push   %ebp
  8007f8:	89 e5                	mov    %esp,%ebp
  8007fa:	56                   	push   %esi
  8007fb:	53                   	push   %ebx
  8007fc:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800802:	8b 55 10             	mov    0x10(%ebp),%edx
  800805:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800807:	85 d2                	test   %edx,%edx
  800809:	74 21                	je     80082c <strlcpy+0x35>
  80080b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80080f:	89 f2                	mov    %esi,%edx
  800811:	eb 09                	jmp    80081c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800813:	83 c2 01             	add    $0x1,%edx
  800816:	83 c1 01             	add    $0x1,%ecx
  800819:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80081c:	39 c2                	cmp    %eax,%edx
  80081e:	74 09                	je     800829 <strlcpy+0x32>
  800820:	0f b6 19             	movzbl (%ecx),%ebx
  800823:	84 db                	test   %bl,%bl
  800825:	75 ec                	jne    800813 <strlcpy+0x1c>
  800827:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800829:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80082c:	29 f0                	sub    %esi,%eax
}
  80082e:	5b                   	pop    %ebx
  80082f:	5e                   	pop    %esi
  800830:	5d                   	pop    %ebp
  800831:	c3                   	ret    

00800832 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800832:	55                   	push   %ebp
  800833:	89 e5                	mov    %esp,%ebp
  800835:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800838:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80083b:	eb 06                	jmp    800843 <strcmp+0x11>
		p++, q++;
  80083d:	83 c1 01             	add    $0x1,%ecx
  800840:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800843:	0f b6 01             	movzbl (%ecx),%eax
  800846:	84 c0                	test   %al,%al
  800848:	74 04                	je     80084e <strcmp+0x1c>
  80084a:	3a 02                	cmp    (%edx),%al
  80084c:	74 ef                	je     80083d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80084e:	0f b6 c0             	movzbl %al,%eax
  800851:	0f b6 12             	movzbl (%edx),%edx
  800854:	29 d0                	sub    %edx,%eax
}
  800856:	5d                   	pop    %ebp
  800857:	c3                   	ret    

00800858 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800858:	55                   	push   %ebp
  800859:	89 e5                	mov    %esp,%ebp
  80085b:	53                   	push   %ebx
  80085c:	8b 45 08             	mov    0x8(%ebp),%eax
  80085f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800862:	89 c3                	mov    %eax,%ebx
  800864:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800867:	eb 06                	jmp    80086f <strncmp+0x17>
		n--, p++, q++;
  800869:	83 c0 01             	add    $0x1,%eax
  80086c:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80086f:	39 d8                	cmp    %ebx,%eax
  800871:	74 15                	je     800888 <strncmp+0x30>
  800873:	0f b6 08             	movzbl (%eax),%ecx
  800876:	84 c9                	test   %cl,%cl
  800878:	74 04                	je     80087e <strncmp+0x26>
  80087a:	3a 0a                	cmp    (%edx),%cl
  80087c:	74 eb                	je     800869 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80087e:	0f b6 00             	movzbl (%eax),%eax
  800881:	0f b6 12             	movzbl (%edx),%edx
  800884:	29 d0                	sub    %edx,%eax
  800886:	eb 05                	jmp    80088d <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800888:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80088d:	5b                   	pop    %ebx
  80088e:	5d                   	pop    %ebp
  80088f:	c3                   	ret    

00800890 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800890:	55                   	push   %ebp
  800891:	89 e5                	mov    %esp,%ebp
  800893:	8b 45 08             	mov    0x8(%ebp),%eax
  800896:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80089a:	eb 07                	jmp    8008a3 <strchr+0x13>
		if (*s == c)
  80089c:	38 ca                	cmp    %cl,%dl
  80089e:	74 0f                	je     8008af <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008a0:	83 c0 01             	add    $0x1,%eax
  8008a3:	0f b6 10             	movzbl (%eax),%edx
  8008a6:	84 d2                	test   %dl,%dl
  8008a8:	75 f2                	jne    80089c <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008aa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008af:	5d                   	pop    %ebp
  8008b0:	c3                   	ret    

008008b1 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008b1:	55                   	push   %ebp
  8008b2:	89 e5                	mov    %esp,%ebp
  8008b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008bb:	eb 03                	jmp    8008c0 <strfind+0xf>
  8008bd:	83 c0 01             	add    $0x1,%eax
  8008c0:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008c3:	38 ca                	cmp    %cl,%dl
  8008c5:	74 04                	je     8008cb <strfind+0x1a>
  8008c7:	84 d2                	test   %dl,%dl
  8008c9:	75 f2                	jne    8008bd <strfind+0xc>
			break;
	return (char *) s;
}
  8008cb:	5d                   	pop    %ebp
  8008cc:	c3                   	ret    

008008cd <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008cd:	55                   	push   %ebp
  8008ce:	89 e5                	mov    %esp,%ebp
  8008d0:	57                   	push   %edi
  8008d1:	56                   	push   %esi
  8008d2:	53                   	push   %ebx
  8008d3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008d6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008d9:	85 c9                	test   %ecx,%ecx
  8008db:	74 36                	je     800913 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008dd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008e3:	75 28                	jne    80090d <memset+0x40>
  8008e5:	f6 c1 03             	test   $0x3,%cl
  8008e8:	75 23                	jne    80090d <memset+0x40>
		c &= 0xFF;
  8008ea:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008ee:	89 d3                	mov    %edx,%ebx
  8008f0:	c1 e3 08             	shl    $0x8,%ebx
  8008f3:	89 d6                	mov    %edx,%esi
  8008f5:	c1 e6 18             	shl    $0x18,%esi
  8008f8:	89 d0                	mov    %edx,%eax
  8008fa:	c1 e0 10             	shl    $0x10,%eax
  8008fd:	09 f0                	or     %esi,%eax
  8008ff:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800901:	89 d8                	mov    %ebx,%eax
  800903:	09 d0                	or     %edx,%eax
  800905:	c1 e9 02             	shr    $0x2,%ecx
  800908:	fc                   	cld    
  800909:	f3 ab                	rep stos %eax,%es:(%edi)
  80090b:	eb 06                	jmp    800913 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80090d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800910:	fc                   	cld    
  800911:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800913:	89 f8                	mov    %edi,%eax
  800915:	5b                   	pop    %ebx
  800916:	5e                   	pop    %esi
  800917:	5f                   	pop    %edi
  800918:	5d                   	pop    %ebp
  800919:	c3                   	ret    

0080091a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80091a:	55                   	push   %ebp
  80091b:	89 e5                	mov    %esp,%ebp
  80091d:	57                   	push   %edi
  80091e:	56                   	push   %esi
  80091f:	8b 45 08             	mov    0x8(%ebp),%eax
  800922:	8b 75 0c             	mov    0xc(%ebp),%esi
  800925:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800928:	39 c6                	cmp    %eax,%esi
  80092a:	73 35                	jae    800961 <memmove+0x47>
  80092c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80092f:	39 d0                	cmp    %edx,%eax
  800931:	73 2e                	jae    800961 <memmove+0x47>
		s += n;
		d += n;
  800933:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800936:	89 d6                	mov    %edx,%esi
  800938:	09 fe                	or     %edi,%esi
  80093a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800940:	75 13                	jne    800955 <memmove+0x3b>
  800942:	f6 c1 03             	test   $0x3,%cl
  800945:	75 0e                	jne    800955 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800947:	83 ef 04             	sub    $0x4,%edi
  80094a:	8d 72 fc             	lea    -0x4(%edx),%esi
  80094d:	c1 e9 02             	shr    $0x2,%ecx
  800950:	fd                   	std    
  800951:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800953:	eb 09                	jmp    80095e <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800955:	83 ef 01             	sub    $0x1,%edi
  800958:	8d 72 ff             	lea    -0x1(%edx),%esi
  80095b:	fd                   	std    
  80095c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80095e:	fc                   	cld    
  80095f:	eb 1d                	jmp    80097e <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800961:	89 f2                	mov    %esi,%edx
  800963:	09 c2                	or     %eax,%edx
  800965:	f6 c2 03             	test   $0x3,%dl
  800968:	75 0f                	jne    800979 <memmove+0x5f>
  80096a:	f6 c1 03             	test   $0x3,%cl
  80096d:	75 0a                	jne    800979 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80096f:	c1 e9 02             	shr    $0x2,%ecx
  800972:	89 c7                	mov    %eax,%edi
  800974:	fc                   	cld    
  800975:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800977:	eb 05                	jmp    80097e <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800979:	89 c7                	mov    %eax,%edi
  80097b:	fc                   	cld    
  80097c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80097e:	5e                   	pop    %esi
  80097f:	5f                   	pop    %edi
  800980:	5d                   	pop    %ebp
  800981:	c3                   	ret    

00800982 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800985:	ff 75 10             	pushl  0x10(%ebp)
  800988:	ff 75 0c             	pushl  0xc(%ebp)
  80098b:	ff 75 08             	pushl  0x8(%ebp)
  80098e:	e8 87 ff ff ff       	call   80091a <memmove>
}
  800993:	c9                   	leave  
  800994:	c3                   	ret    

00800995 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800995:	55                   	push   %ebp
  800996:	89 e5                	mov    %esp,%ebp
  800998:	56                   	push   %esi
  800999:	53                   	push   %ebx
  80099a:	8b 45 08             	mov    0x8(%ebp),%eax
  80099d:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a0:	89 c6                	mov    %eax,%esi
  8009a2:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009a5:	eb 1a                	jmp    8009c1 <memcmp+0x2c>
		if (*s1 != *s2)
  8009a7:	0f b6 08             	movzbl (%eax),%ecx
  8009aa:	0f b6 1a             	movzbl (%edx),%ebx
  8009ad:	38 d9                	cmp    %bl,%cl
  8009af:	74 0a                	je     8009bb <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009b1:	0f b6 c1             	movzbl %cl,%eax
  8009b4:	0f b6 db             	movzbl %bl,%ebx
  8009b7:	29 d8                	sub    %ebx,%eax
  8009b9:	eb 0f                	jmp    8009ca <memcmp+0x35>
		s1++, s2++;
  8009bb:	83 c0 01             	add    $0x1,%eax
  8009be:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009c1:	39 f0                	cmp    %esi,%eax
  8009c3:	75 e2                	jne    8009a7 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009c5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ca:	5b                   	pop    %ebx
  8009cb:	5e                   	pop    %esi
  8009cc:	5d                   	pop    %ebp
  8009cd:	c3                   	ret    

008009ce <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009ce:	55                   	push   %ebp
  8009cf:	89 e5                	mov    %esp,%ebp
  8009d1:	53                   	push   %ebx
  8009d2:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009d5:	89 c1                	mov    %eax,%ecx
  8009d7:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009da:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009de:	eb 0a                	jmp    8009ea <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009e0:	0f b6 10             	movzbl (%eax),%edx
  8009e3:	39 da                	cmp    %ebx,%edx
  8009e5:	74 07                	je     8009ee <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009e7:	83 c0 01             	add    $0x1,%eax
  8009ea:	39 c8                	cmp    %ecx,%eax
  8009ec:	72 f2                	jb     8009e0 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009ee:	5b                   	pop    %ebx
  8009ef:	5d                   	pop    %ebp
  8009f0:	c3                   	ret    

008009f1 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009f1:	55                   	push   %ebp
  8009f2:	89 e5                	mov    %esp,%ebp
  8009f4:	57                   	push   %edi
  8009f5:	56                   	push   %esi
  8009f6:	53                   	push   %ebx
  8009f7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009fa:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009fd:	eb 03                	jmp    800a02 <strtol+0x11>
		s++;
  8009ff:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a02:	0f b6 01             	movzbl (%ecx),%eax
  800a05:	3c 20                	cmp    $0x20,%al
  800a07:	74 f6                	je     8009ff <strtol+0xe>
  800a09:	3c 09                	cmp    $0x9,%al
  800a0b:	74 f2                	je     8009ff <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a0d:	3c 2b                	cmp    $0x2b,%al
  800a0f:	75 0a                	jne    800a1b <strtol+0x2a>
		s++;
  800a11:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a14:	bf 00 00 00 00       	mov    $0x0,%edi
  800a19:	eb 11                	jmp    800a2c <strtol+0x3b>
  800a1b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a20:	3c 2d                	cmp    $0x2d,%al
  800a22:	75 08                	jne    800a2c <strtol+0x3b>
		s++, neg = 1;
  800a24:	83 c1 01             	add    $0x1,%ecx
  800a27:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a2c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a32:	75 15                	jne    800a49 <strtol+0x58>
  800a34:	80 39 30             	cmpb   $0x30,(%ecx)
  800a37:	75 10                	jne    800a49 <strtol+0x58>
  800a39:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a3d:	75 7c                	jne    800abb <strtol+0xca>
		s += 2, base = 16;
  800a3f:	83 c1 02             	add    $0x2,%ecx
  800a42:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a47:	eb 16                	jmp    800a5f <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a49:	85 db                	test   %ebx,%ebx
  800a4b:	75 12                	jne    800a5f <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a4d:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a52:	80 39 30             	cmpb   $0x30,(%ecx)
  800a55:	75 08                	jne    800a5f <strtol+0x6e>
		s++, base = 8;
  800a57:	83 c1 01             	add    $0x1,%ecx
  800a5a:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a5f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a64:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a67:	0f b6 11             	movzbl (%ecx),%edx
  800a6a:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a6d:	89 f3                	mov    %esi,%ebx
  800a6f:	80 fb 09             	cmp    $0x9,%bl
  800a72:	77 08                	ja     800a7c <strtol+0x8b>
			dig = *s - '0';
  800a74:	0f be d2             	movsbl %dl,%edx
  800a77:	83 ea 30             	sub    $0x30,%edx
  800a7a:	eb 22                	jmp    800a9e <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a7c:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a7f:	89 f3                	mov    %esi,%ebx
  800a81:	80 fb 19             	cmp    $0x19,%bl
  800a84:	77 08                	ja     800a8e <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a86:	0f be d2             	movsbl %dl,%edx
  800a89:	83 ea 57             	sub    $0x57,%edx
  800a8c:	eb 10                	jmp    800a9e <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a8e:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a91:	89 f3                	mov    %esi,%ebx
  800a93:	80 fb 19             	cmp    $0x19,%bl
  800a96:	77 16                	ja     800aae <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a98:	0f be d2             	movsbl %dl,%edx
  800a9b:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a9e:	3b 55 10             	cmp    0x10(%ebp),%edx
  800aa1:	7d 0b                	jge    800aae <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800aa3:	83 c1 01             	add    $0x1,%ecx
  800aa6:	0f af 45 10          	imul   0x10(%ebp),%eax
  800aaa:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800aac:	eb b9                	jmp    800a67 <strtol+0x76>

	if (endptr)
  800aae:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ab2:	74 0d                	je     800ac1 <strtol+0xd0>
		*endptr = (char *) s;
  800ab4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ab7:	89 0e                	mov    %ecx,(%esi)
  800ab9:	eb 06                	jmp    800ac1 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800abb:	85 db                	test   %ebx,%ebx
  800abd:	74 98                	je     800a57 <strtol+0x66>
  800abf:	eb 9e                	jmp    800a5f <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ac1:	89 c2                	mov    %eax,%edx
  800ac3:	f7 da                	neg    %edx
  800ac5:	85 ff                	test   %edi,%edi
  800ac7:	0f 45 c2             	cmovne %edx,%eax
}
  800aca:	5b                   	pop    %ebx
  800acb:	5e                   	pop    %esi
  800acc:	5f                   	pop    %edi
  800acd:	5d                   	pop    %ebp
  800ace:	c3                   	ret    

00800acf <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800acf:	55                   	push   %ebp
  800ad0:	89 e5                	mov    %esp,%ebp
  800ad2:	57                   	push   %edi
  800ad3:	56                   	push   %esi
  800ad4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ad5:	b8 00 00 00 00       	mov    $0x0,%eax
  800ada:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800add:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae0:	89 c3                	mov    %eax,%ebx
  800ae2:	89 c7                	mov    %eax,%edi
  800ae4:	89 c6                	mov    %eax,%esi
  800ae6:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ae8:	5b                   	pop    %ebx
  800ae9:	5e                   	pop    %esi
  800aea:	5f                   	pop    %edi
  800aeb:	5d                   	pop    %ebp
  800aec:	c3                   	ret    

00800aed <sys_cgetc>:

int
sys_cgetc(void)
{
  800aed:	55                   	push   %ebp
  800aee:	89 e5                	mov    %esp,%ebp
  800af0:	57                   	push   %edi
  800af1:	56                   	push   %esi
  800af2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af3:	ba 00 00 00 00       	mov    $0x0,%edx
  800af8:	b8 01 00 00 00       	mov    $0x1,%eax
  800afd:	89 d1                	mov    %edx,%ecx
  800aff:	89 d3                	mov    %edx,%ebx
  800b01:	89 d7                	mov    %edx,%edi
  800b03:	89 d6                	mov    %edx,%esi
  800b05:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b07:	5b                   	pop    %ebx
  800b08:	5e                   	pop    %esi
  800b09:	5f                   	pop    %edi
  800b0a:	5d                   	pop    %ebp
  800b0b:	c3                   	ret    

00800b0c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b0c:	55                   	push   %ebp
  800b0d:	89 e5                	mov    %esp,%ebp
  800b0f:	57                   	push   %edi
  800b10:	56                   	push   %esi
  800b11:	53                   	push   %ebx
  800b12:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b15:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b1a:	b8 03 00 00 00       	mov    $0x3,%eax
  800b1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b22:	89 cb                	mov    %ecx,%ebx
  800b24:	89 cf                	mov    %ecx,%edi
  800b26:	89 ce                	mov    %ecx,%esi
  800b28:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b2a:	85 c0                	test   %eax,%eax
  800b2c:	7e 17                	jle    800b45 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b2e:	83 ec 0c             	sub    $0xc,%esp
  800b31:	50                   	push   %eax
  800b32:	6a 03                	push   $0x3
  800b34:	68 ff 26 80 00       	push   $0x8026ff
  800b39:	6a 23                	push   $0x23
  800b3b:	68 1c 27 80 00       	push   $0x80271c
  800b40:	e8 e5 f5 ff ff       	call   80012a <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b45:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b48:	5b                   	pop    %ebx
  800b49:	5e                   	pop    %esi
  800b4a:	5f                   	pop    %edi
  800b4b:	5d                   	pop    %ebp
  800b4c:	c3                   	ret    

00800b4d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b4d:	55                   	push   %ebp
  800b4e:	89 e5                	mov    %esp,%ebp
  800b50:	57                   	push   %edi
  800b51:	56                   	push   %esi
  800b52:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b53:	ba 00 00 00 00       	mov    $0x0,%edx
  800b58:	b8 02 00 00 00       	mov    $0x2,%eax
  800b5d:	89 d1                	mov    %edx,%ecx
  800b5f:	89 d3                	mov    %edx,%ebx
  800b61:	89 d7                	mov    %edx,%edi
  800b63:	89 d6                	mov    %edx,%esi
  800b65:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b67:	5b                   	pop    %ebx
  800b68:	5e                   	pop    %esi
  800b69:	5f                   	pop    %edi
  800b6a:	5d                   	pop    %ebp
  800b6b:	c3                   	ret    

00800b6c <sys_yield>:

void
sys_yield(void)
{
  800b6c:	55                   	push   %ebp
  800b6d:	89 e5                	mov    %esp,%ebp
  800b6f:	57                   	push   %edi
  800b70:	56                   	push   %esi
  800b71:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b72:	ba 00 00 00 00       	mov    $0x0,%edx
  800b77:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b7c:	89 d1                	mov    %edx,%ecx
  800b7e:	89 d3                	mov    %edx,%ebx
  800b80:	89 d7                	mov    %edx,%edi
  800b82:	89 d6                	mov    %edx,%esi
  800b84:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b86:	5b                   	pop    %ebx
  800b87:	5e                   	pop    %esi
  800b88:	5f                   	pop    %edi
  800b89:	5d                   	pop    %ebp
  800b8a:	c3                   	ret    

00800b8b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b8b:	55                   	push   %ebp
  800b8c:	89 e5                	mov    %esp,%ebp
  800b8e:	57                   	push   %edi
  800b8f:	56                   	push   %esi
  800b90:	53                   	push   %ebx
  800b91:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b94:	be 00 00 00 00       	mov    $0x0,%esi
  800b99:	b8 04 00 00 00       	mov    $0x4,%eax
  800b9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ba7:	89 f7                	mov    %esi,%edi
  800ba9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bab:	85 c0                	test   %eax,%eax
  800bad:	7e 17                	jle    800bc6 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800baf:	83 ec 0c             	sub    $0xc,%esp
  800bb2:	50                   	push   %eax
  800bb3:	6a 04                	push   $0x4
  800bb5:	68 ff 26 80 00       	push   $0x8026ff
  800bba:	6a 23                	push   $0x23
  800bbc:	68 1c 27 80 00       	push   $0x80271c
  800bc1:	e8 64 f5 ff ff       	call   80012a <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bc6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc9:	5b                   	pop    %ebx
  800bca:	5e                   	pop    %esi
  800bcb:	5f                   	pop    %edi
  800bcc:	5d                   	pop    %ebp
  800bcd:	c3                   	ret    

00800bce <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bce:	55                   	push   %ebp
  800bcf:	89 e5                	mov    %esp,%ebp
  800bd1:	57                   	push   %edi
  800bd2:	56                   	push   %esi
  800bd3:	53                   	push   %ebx
  800bd4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd7:	b8 05 00 00 00       	mov    $0x5,%eax
  800bdc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bdf:	8b 55 08             	mov    0x8(%ebp),%edx
  800be2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800be5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800be8:	8b 75 18             	mov    0x18(%ebp),%esi
  800beb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bed:	85 c0                	test   %eax,%eax
  800bef:	7e 17                	jle    800c08 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf1:	83 ec 0c             	sub    $0xc,%esp
  800bf4:	50                   	push   %eax
  800bf5:	6a 05                	push   $0x5
  800bf7:	68 ff 26 80 00       	push   $0x8026ff
  800bfc:	6a 23                	push   $0x23
  800bfe:	68 1c 27 80 00       	push   $0x80271c
  800c03:	e8 22 f5 ff ff       	call   80012a <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c08:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c0b:	5b                   	pop    %ebx
  800c0c:	5e                   	pop    %esi
  800c0d:	5f                   	pop    %edi
  800c0e:	5d                   	pop    %ebp
  800c0f:	c3                   	ret    

00800c10 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c10:	55                   	push   %ebp
  800c11:	89 e5                	mov    %esp,%ebp
  800c13:	57                   	push   %edi
  800c14:	56                   	push   %esi
  800c15:	53                   	push   %ebx
  800c16:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c19:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c1e:	b8 06 00 00 00       	mov    $0x6,%eax
  800c23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c26:	8b 55 08             	mov    0x8(%ebp),%edx
  800c29:	89 df                	mov    %ebx,%edi
  800c2b:	89 de                	mov    %ebx,%esi
  800c2d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c2f:	85 c0                	test   %eax,%eax
  800c31:	7e 17                	jle    800c4a <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c33:	83 ec 0c             	sub    $0xc,%esp
  800c36:	50                   	push   %eax
  800c37:	6a 06                	push   $0x6
  800c39:	68 ff 26 80 00       	push   $0x8026ff
  800c3e:	6a 23                	push   $0x23
  800c40:	68 1c 27 80 00       	push   $0x80271c
  800c45:	e8 e0 f4 ff ff       	call   80012a <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c4d:	5b                   	pop    %ebx
  800c4e:	5e                   	pop    %esi
  800c4f:	5f                   	pop    %edi
  800c50:	5d                   	pop    %ebp
  800c51:	c3                   	ret    

00800c52 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c52:	55                   	push   %ebp
  800c53:	89 e5                	mov    %esp,%ebp
  800c55:	57                   	push   %edi
  800c56:	56                   	push   %esi
  800c57:	53                   	push   %ebx
  800c58:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c60:	b8 08 00 00 00       	mov    $0x8,%eax
  800c65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c68:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6b:	89 df                	mov    %ebx,%edi
  800c6d:	89 de                	mov    %ebx,%esi
  800c6f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c71:	85 c0                	test   %eax,%eax
  800c73:	7e 17                	jle    800c8c <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c75:	83 ec 0c             	sub    $0xc,%esp
  800c78:	50                   	push   %eax
  800c79:	6a 08                	push   $0x8
  800c7b:	68 ff 26 80 00       	push   $0x8026ff
  800c80:	6a 23                	push   $0x23
  800c82:	68 1c 27 80 00       	push   $0x80271c
  800c87:	e8 9e f4 ff ff       	call   80012a <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c8c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8f:	5b                   	pop    %ebx
  800c90:	5e                   	pop    %esi
  800c91:	5f                   	pop    %edi
  800c92:	5d                   	pop    %ebp
  800c93:	c3                   	ret    

00800c94 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c94:	55                   	push   %ebp
  800c95:	89 e5                	mov    %esp,%ebp
  800c97:	57                   	push   %edi
  800c98:	56                   	push   %esi
  800c99:	53                   	push   %ebx
  800c9a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca2:	b8 09 00 00 00       	mov    $0x9,%eax
  800ca7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800caa:	8b 55 08             	mov    0x8(%ebp),%edx
  800cad:	89 df                	mov    %ebx,%edi
  800caf:	89 de                	mov    %ebx,%esi
  800cb1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cb3:	85 c0                	test   %eax,%eax
  800cb5:	7e 17                	jle    800cce <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb7:	83 ec 0c             	sub    $0xc,%esp
  800cba:	50                   	push   %eax
  800cbb:	6a 09                	push   $0x9
  800cbd:	68 ff 26 80 00       	push   $0x8026ff
  800cc2:	6a 23                	push   $0x23
  800cc4:	68 1c 27 80 00       	push   $0x80271c
  800cc9:	e8 5c f4 ff ff       	call   80012a <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd1:	5b                   	pop    %ebx
  800cd2:	5e                   	pop    %esi
  800cd3:	5f                   	pop    %edi
  800cd4:	5d                   	pop    %ebp
  800cd5:	c3                   	ret    

00800cd6 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cd6:	55                   	push   %ebp
  800cd7:	89 e5                	mov    %esp,%ebp
  800cd9:	57                   	push   %edi
  800cda:	56                   	push   %esi
  800cdb:	53                   	push   %ebx
  800cdc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cdf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce4:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ce9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cec:	8b 55 08             	mov    0x8(%ebp),%edx
  800cef:	89 df                	mov    %ebx,%edi
  800cf1:	89 de                	mov    %ebx,%esi
  800cf3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cf5:	85 c0                	test   %eax,%eax
  800cf7:	7e 17                	jle    800d10 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf9:	83 ec 0c             	sub    $0xc,%esp
  800cfc:	50                   	push   %eax
  800cfd:	6a 0a                	push   $0xa
  800cff:	68 ff 26 80 00       	push   $0x8026ff
  800d04:	6a 23                	push   $0x23
  800d06:	68 1c 27 80 00       	push   $0x80271c
  800d0b:	e8 1a f4 ff ff       	call   80012a <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d10:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d13:	5b                   	pop    %ebx
  800d14:	5e                   	pop    %esi
  800d15:	5f                   	pop    %edi
  800d16:	5d                   	pop    %ebp
  800d17:	c3                   	ret    

00800d18 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d18:	55                   	push   %ebp
  800d19:	89 e5                	mov    %esp,%ebp
  800d1b:	57                   	push   %edi
  800d1c:	56                   	push   %esi
  800d1d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1e:	be 00 00 00 00       	mov    $0x0,%esi
  800d23:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d31:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d34:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d36:	5b                   	pop    %ebx
  800d37:	5e                   	pop    %esi
  800d38:	5f                   	pop    %edi
  800d39:	5d                   	pop    %ebp
  800d3a:	c3                   	ret    

00800d3b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d3b:	55                   	push   %ebp
  800d3c:	89 e5                	mov    %esp,%ebp
  800d3e:	57                   	push   %edi
  800d3f:	56                   	push   %esi
  800d40:	53                   	push   %ebx
  800d41:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d44:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d49:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d51:	89 cb                	mov    %ecx,%ebx
  800d53:	89 cf                	mov    %ecx,%edi
  800d55:	89 ce                	mov    %ecx,%esi
  800d57:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d59:	85 c0                	test   %eax,%eax
  800d5b:	7e 17                	jle    800d74 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5d:	83 ec 0c             	sub    $0xc,%esp
  800d60:	50                   	push   %eax
  800d61:	6a 0d                	push   $0xd
  800d63:	68 ff 26 80 00       	push   $0x8026ff
  800d68:	6a 23                	push   $0x23
  800d6a:	68 1c 27 80 00       	push   $0x80271c
  800d6f:	e8 b6 f3 ff ff       	call   80012a <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d74:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d77:	5b                   	pop    %ebx
  800d78:	5e                   	pop    %esi
  800d79:	5f                   	pop    %edi
  800d7a:	5d                   	pop    %ebp
  800d7b:	c3                   	ret    

00800d7c <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d7c:	55                   	push   %ebp
  800d7d:	89 e5                	mov    %esp,%ebp
  800d7f:	57                   	push   %edi
  800d80:	56                   	push   %esi
  800d81:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d82:	ba 00 00 00 00       	mov    $0x0,%edx
  800d87:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d8c:	89 d1                	mov    %edx,%ecx
  800d8e:	89 d3                	mov    %edx,%ebx
  800d90:	89 d7                	mov    %edx,%edi
  800d92:	89 d6                	mov    %edx,%esi
  800d94:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d96:	5b                   	pop    %ebx
  800d97:	5e                   	pop    %esi
  800d98:	5f                   	pop    %edi
  800d99:	5d                   	pop    %ebp
  800d9a:	c3                   	ret    

00800d9b <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d9b:	55                   	push   %ebp
  800d9c:	89 e5                	mov    %esp,%ebp
  800d9e:	53                   	push   %ebx
  800d9f:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  800da2:	83 3d 0c 40 80 00 00 	cmpl   $0x0,0x80400c
  800da9:	75 28                	jne    800dd3 <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  800dab:	e8 9d fd ff ff       	call   800b4d <sys_getenvid>
  800db0:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_U | PTE_W);
  800db2:	83 ec 04             	sub    $0x4,%esp
  800db5:	6a 06                	push   $0x6
  800db7:	68 00 f0 bf ee       	push   $0xeebff000
  800dbc:	50                   	push   %eax
  800dbd:	e8 c9 fd ff ff       	call   800b8b <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  800dc2:	83 c4 08             	add    $0x8,%esp
  800dc5:	68 e0 0d 80 00       	push   $0x800de0
  800dca:	53                   	push   %ebx
  800dcb:	e8 06 ff ff ff       	call   800cd6 <sys_env_set_pgfault_upcall>
  800dd0:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800dd3:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd6:	a3 0c 40 80 00       	mov    %eax,0x80400c
}
  800ddb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dde:	c9                   	leave  
  800ddf:	c3                   	ret    

00800de0 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800de0:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800de1:	a1 0c 40 80 00       	mov    0x80400c,%eax
	call *%eax
  800de6:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800de8:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	# My method is different. Copy the values to the other stack
	# in a convinient way, and then pop everything.
	movl %esp, %ebp		# ebp refers to the exception stack
  800deb:	89 e5                	mov    %esp,%ebp
	movl 48(%ebp), %esp 	# go to other stack
  800ded:	8b 65 30             	mov    0x30(%ebp),%esp

	pushl 40(%ebp)		# eip - ORDER SWITCHED WITH EFLAGS
  800df0:	ff 75 28             	pushl  0x28(%ebp)
	pushl 44(%ebp)      	# eflags
  800df3:	ff 75 2c             	pushl  0x2c(%ebp)
	pushl 36(%ebp)		# all the 8 remaining regs
  800df6:	ff 75 24             	pushl  0x24(%ebp)
	pushl 32(%ebp)
  800df9:	ff 75 20             	pushl  0x20(%ebp)
	pushl 28(%ebp)
  800dfc:	ff 75 1c             	pushl  0x1c(%ebp)
	pushl 24(%ebp)
  800dff:	ff 75 18             	pushl  0x18(%ebp)
	pushl 20(%ebp)
  800e02:	ff 75 14             	pushl  0x14(%ebp)
	pushl 16(%ebp)
  800e05:	ff 75 10             	pushl  0x10(%ebp)
	pushl 12(%ebp)
  800e08:	ff 75 0c             	pushl  0xc(%ebp)
	pushl 8(%ebp)
  800e0b:	ff 75 08             	pushl  0x8(%ebp)

	popal			# now just pop everything!
  800e0e:	61                   	popa   
	popfl
  800e0f:	9d                   	popf   
	ret
  800e10:	c3                   	ret    

00800e11 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e11:	55                   	push   %ebp
  800e12:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e14:	8b 45 08             	mov    0x8(%ebp),%eax
  800e17:	05 00 00 00 30       	add    $0x30000000,%eax
  800e1c:	c1 e8 0c             	shr    $0xc,%eax
}
  800e1f:	5d                   	pop    %ebp
  800e20:	c3                   	ret    

00800e21 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e21:	55                   	push   %ebp
  800e22:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e24:	8b 45 08             	mov    0x8(%ebp),%eax
  800e27:	05 00 00 00 30       	add    $0x30000000,%eax
  800e2c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e31:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e36:	5d                   	pop    %ebp
  800e37:	c3                   	ret    

00800e38 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e38:	55                   	push   %ebp
  800e39:	89 e5                	mov    %esp,%ebp
  800e3b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e3e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e43:	89 c2                	mov    %eax,%edx
  800e45:	c1 ea 16             	shr    $0x16,%edx
  800e48:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e4f:	f6 c2 01             	test   $0x1,%dl
  800e52:	74 11                	je     800e65 <fd_alloc+0x2d>
  800e54:	89 c2                	mov    %eax,%edx
  800e56:	c1 ea 0c             	shr    $0xc,%edx
  800e59:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e60:	f6 c2 01             	test   $0x1,%dl
  800e63:	75 09                	jne    800e6e <fd_alloc+0x36>
			*fd_store = fd;
  800e65:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e67:	b8 00 00 00 00       	mov    $0x0,%eax
  800e6c:	eb 17                	jmp    800e85 <fd_alloc+0x4d>
  800e6e:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e73:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e78:	75 c9                	jne    800e43 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e7a:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e80:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e85:	5d                   	pop    %ebp
  800e86:	c3                   	ret    

00800e87 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e87:	55                   	push   %ebp
  800e88:	89 e5                	mov    %esp,%ebp
  800e8a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e8d:	83 f8 1f             	cmp    $0x1f,%eax
  800e90:	77 36                	ja     800ec8 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e92:	c1 e0 0c             	shl    $0xc,%eax
  800e95:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e9a:	89 c2                	mov    %eax,%edx
  800e9c:	c1 ea 16             	shr    $0x16,%edx
  800e9f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ea6:	f6 c2 01             	test   $0x1,%dl
  800ea9:	74 24                	je     800ecf <fd_lookup+0x48>
  800eab:	89 c2                	mov    %eax,%edx
  800ead:	c1 ea 0c             	shr    $0xc,%edx
  800eb0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800eb7:	f6 c2 01             	test   $0x1,%dl
  800eba:	74 1a                	je     800ed6 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800ebc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ebf:	89 02                	mov    %eax,(%edx)
	return 0;
  800ec1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec6:	eb 13                	jmp    800edb <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ec8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ecd:	eb 0c                	jmp    800edb <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ecf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ed4:	eb 05                	jmp    800edb <fd_lookup+0x54>
  800ed6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800edb:	5d                   	pop    %ebp
  800edc:	c3                   	ret    

00800edd <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800edd:	55                   	push   %ebp
  800ede:	89 e5                	mov    %esp,%ebp
  800ee0:	83 ec 08             	sub    $0x8,%esp
  800ee3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ee6:	ba ac 27 80 00       	mov    $0x8027ac,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800eeb:	eb 13                	jmp    800f00 <dev_lookup+0x23>
  800eed:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800ef0:	39 08                	cmp    %ecx,(%eax)
  800ef2:	75 0c                	jne    800f00 <dev_lookup+0x23>
			*dev = devtab[i];
  800ef4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef7:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ef9:	b8 00 00 00 00       	mov    $0x0,%eax
  800efe:	eb 2e                	jmp    800f2e <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f00:	8b 02                	mov    (%edx),%eax
  800f02:	85 c0                	test   %eax,%eax
  800f04:	75 e7                	jne    800eed <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f06:	a1 08 40 80 00       	mov    0x804008,%eax
  800f0b:	8b 40 48             	mov    0x48(%eax),%eax
  800f0e:	83 ec 04             	sub    $0x4,%esp
  800f11:	51                   	push   %ecx
  800f12:	50                   	push   %eax
  800f13:	68 2c 27 80 00       	push   $0x80272c
  800f18:	e8 e6 f2 ff ff       	call   800203 <cprintf>
	*dev = 0;
  800f1d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f20:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f26:	83 c4 10             	add    $0x10,%esp
  800f29:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f2e:	c9                   	leave  
  800f2f:	c3                   	ret    

00800f30 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f30:	55                   	push   %ebp
  800f31:	89 e5                	mov    %esp,%ebp
  800f33:	56                   	push   %esi
  800f34:	53                   	push   %ebx
  800f35:	83 ec 10             	sub    $0x10,%esp
  800f38:	8b 75 08             	mov    0x8(%ebp),%esi
  800f3b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f3e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f41:	50                   	push   %eax
  800f42:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f48:	c1 e8 0c             	shr    $0xc,%eax
  800f4b:	50                   	push   %eax
  800f4c:	e8 36 ff ff ff       	call   800e87 <fd_lookup>
  800f51:	83 c4 08             	add    $0x8,%esp
  800f54:	85 c0                	test   %eax,%eax
  800f56:	78 05                	js     800f5d <fd_close+0x2d>
	    || fd != fd2)
  800f58:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f5b:	74 0c                	je     800f69 <fd_close+0x39>
		return (must_exist ? r : 0);
  800f5d:	84 db                	test   %bl,%bl
  800f5f:	ba 00 00 00 00       	mov    $0x0,%edx
  800f64:	0f 44 c2             	cmove  %edx,%eax
  800f67:	eb 41                	jmp    800faa <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f69:	83 ec 08             	sub    $0x8,%esp
  800f6c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f6f:	50                   	push   %eax
  800f70:	ff 36                	pushl  (%esi)
  800f72:	e8 66 ff ff ff       	call   800edd <dev_lookup>
  800f77:	89 c3                	mov    %eax,%ebx
  800f79:	83 c4 10             	add    $0x10,%esp
  800f7c:	85 c0                	test   %eax,%eax
  800f7e:	78 1a                	js     800f9a <fd_close+0x6a>
		if (dev->dev_close)
  800f80:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f83:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f86:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f8b:	85 c0                	test   %eax,%eax
  800f8d:	74 0b                	je     800f9a <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f8f:	83 ec 0c             	sub    $0xc,%esp
  800f92:	56                   	push   %esi
  800f93:	ff d0                	call   *%eax
  800f95:	89 c3                	mov    %eax,%ebx
  800f97:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f9a:	83 ec 08             	sub    $0x8,%esp
  800f9d:	56                   	push   %esi
  800f9e:	6a 00                	push   $0x0
  800fa0:	e8 6b fc ff ff       	call   800c10 <sys_page_unmap>
	return r;
  800fa5:	83 c4 10             	add    $0x10,%esp
  800fa8:	89 d8                	mov    %ebx,%eax
}
  800faa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fad:	5b                   	pop    %ebx
  800fae:	5e                   	pop    %esi
  800faf:	5d                   	pop    %ebp
  800fb0:	c3                   	ret    

00800fb1 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800fb1:	55                   	push   %ebp
  800fb2:	89 e5                	mov    %esp,%ebp
  800fb4:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fb7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fba:	50                   	push   %eax
  800fbb:	ff 75 08             	pushl  0x8(%ebp)
  800fbe:	e8 c4 fe ff ff       	call   800e87 <fd_lookup>
  800fc3:	83 c4 08             	add    $0x8,%esp
  800fc6:	85 c0                	test   %eax,%eax
  800fc8:	78 10                	js     800fda <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800fca:	83 ec 08             	sub    $0x8,%esp
  800fcd:	6a 01                	push   $0x1
  800fcf:	ff 75 f4             	pushl  -0xc(%ebp)
  800fd2:	e8 59 ff ff ff       	call   800f30 <fd_close>
  800fd7:	83 c4 10             	add    $0x10,%esp
}
  800fda:	c9                   	leave  
  800fdb:	c3                   	ret    

00800fdc <close_all>:

void
close_all(void)
{
  800fdc:	55                   	push   %ebp
  800fdd:	89 e5                	mov    %esp,%ebp
  800fdf:	53                   	push   %ebx
  800fe0:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fe3:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fe8:	83 ec 0c             	sub    $0xc,%esp
  800feb:	53                   	push   %ebx
  800fec:	e8 c0 ff ff ff       	call   800fb1 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800ff1:	83 c3 01             	add    $0x1,%ebx
  800ff4:	83 c4 10             	add    $0x10,%esp
  800ff7:	83 fb 20             	cmp    $0x20,%ebx
  800ffa:	75 ec                	jne    800fe8 <close_all+0xc>
		close(i);
}
  800ffc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fff:	c9                   	leave  
  801000:	c3                   	ret    

00801001 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801001:	55                   	push   %ebp
  801002:	89 e5                	mov    %esp,%ebp
  801004:	57                   	push   %edi
  801005:	56                   	push   %esi
  801006:	53                   	push   %ebx
  801007:	83 ec 2c             	sub    $0x2c,%esp
  80100a:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80100d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801010:	50                   	push   %eax
  801011:	ff 75 08             	pushl  0x8(%ebp)
  801014:	e8 6e fe ff ff       	call   800e87 <fd_lookup>
  801019:	83 c4 08             	add    $0x8,%esp
  80101c:	85 c0                	test   %eax,%eax
  80101e:	0f 88 c1 00 00 00    	js     8010e5 <dup+0xe4>
		return r;
	close(newfdnum);
  801024:	83 ec 0c             	sub    $0xc,%esp
  801027:	56                   	push   %esi
  801028:	e8 84 ff ff ff       	call   800fb1 <close>

	newfd = INDEX2FD(newfdnum);
  80102d:	89 f3                	mov    %esi,%ebx
  80102f:	c1 e3 0c             	shl    $0xc,%ebx
  801032:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801038:	83 c4 04             	add    $0x4,%esp
  80103b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80103e:	e8 de fd ff ff       	call   800e21 <fd2data>
  801043:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801045:	89 1c 24             	mov    %ebx,(%esp)
  801048:	e8 d4 fd ff ff       	call   800e21 <fd2data>
  80104d:	83 c4 10             	add    $0x10,%esp
  801050:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801053:	89 f8                	mov    %edi,%eax
  801055:	c1 e8 16             	shr    $0x16,%eax
  801058:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80105f:	a8 01                	test   $0x1,%al
  801061:	74 37                	je     80109a <dup+0x99>
  801063:	89 f8                	mov    %edi,%eax
  801065:	c1 e8 0c             	shr    $0xc,%eax
  801068:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80106f:	f6 c2 01             	test   $0x1,%dl
  801072:	74 26                	je     80109a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801074:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80107b:	83 ec 0c             	sub    $0xc,%esp
  80107e:	25 07 0e 00 00       	and    $0xe07,%eax
  801083:	50                   	push   %eax
  801084:	ff 75 d4             	pushl  -0x2c(%ebp)
  801087:	6a 00                	push   $0x0
  801089:	57                   	push   %edi
  80108a:	6a 00                	push   $0x0
  80108c:	e8 3d fb ff ff       	call   800bce <sys_page_map>
  801091:	89 c7                	mov    %eax,%edi
  801093:	83 c4 20             	add    $0x20,%esp
  801096:	85 c0                	test   %eax,%eax
  801098:	78 2e                	js     8010c8 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80109a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80109d:	89 d0                	mov    %edx,%eax
  80109f:	c1 e8 0c             	shr    $0xc,%eax
  8010a2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010a9:	83 ec 0c             	sub    $0xc,%esp
  8010ac:	25 07 0e 00 00       	and    $0xe07,%eax
  8010b1:	50                   	push   %eax
  8010b2:	53                   	push   %ebx
  8010b3:	6a 00                	push   $0x0
  8010b5:	52                   	push   %edx
  8010b6:	6a 00                	push   $0x0
  8010b8:	e8 11 fb ff ff       	call   800bce <sys_page_map>
  8010bd:	89 c7                	mov    %eax,%edi
  8010bf:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8010c2:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010c4:	85 ff                	test   %edi,%edi
  8010c6:	79 1d                	jns    8010e5 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010c8:	83 ec 08             	sub    $0x8,%esp
  8010cb:	53                   	push   %ebx
  8010cc:	6a 00                	push   $0x0
  8010ce:	e8 3d fb ff ff       	call   800c10 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010d3:	83 c4 08             	add    $0x8,%esp
  8010d6:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010d9:	6a 00                	push   $0x0
  8010db:	e8 30 fb ff ff       	call   800c10 <sys_page_unmap>
	return r;
  8010e0:	83 c4 10             	add    $0x10,%esp
  8010e3:	89 f8                	mov    %edi,%eax
}
  8010e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010e8:	5b                   	pop    %ebx
  8010e9:	5e                   	pop    %esi
  8010ea:	5f                   	pop    %edi
  8010eb:	5d                   	pop    %ebp
  8010ec:	c3                   	ret    

008010ed <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010ed:	55                   	push   %ebp
  8010ee:	89 e5                	mov    %esp,%ebp
  8010f0:	53                   	push   %ebx
  8010f1:	83 ec 14             	sub    $0x14,%esp
  8010f4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010f7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010fa:	50                   	push   %eax
  8010fb:	53                   	push   %ebx
  8010fc:	e8 86 fd ff ff       	call   800e87 <fd_lookup>
  801101:	83 c4 08             	add    $0x8,%esp
  801104:	89 c2                	mov    %eax,%edx
  801106:	85 c0                	test   %eax,%eax
  801108:	78 6d                	js     801177 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80110a:	83 ec 08             	sub    $0x8,%esp
  80110d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801110:	50                   	push   %eax
  801111:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801114:	ff 30                	pushl  (%eax)
  801116:	e8 c2 fd ff ff       	call   800edd <dev_lookup>
  80111b:	83 c4 10             	add    $0x10,%esp
  80111e:	85 c0                	test   %eax,%eax
  801120:	78 4c                	js     80116e <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801122:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801125:	8b 42 08             	mov    0x8(%edx),%eax
  801128:	83 e0 03             	and    $0x3,%eax
  80112b:	83 f8 01             	cmp    $0x1,%eax
  80112e:	75 21                	jne    801151 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801130:	a1 08 40 80 00       	mov    0x804008,%eax
  801135:	8b 40 48             	mov    0x48(%eax),%eax
  801138:	83 ec 04             	sub    $0x4,%esp
  80113b:	53                   	push   %ebx
  80113c:	50                   	push   %eax
  80113d:	68 70 27 80 00       	push   $0x802770
  801142:	e8 bc f0 ff ff       	call   800203 <cprintf>
		return -E_INVAL;
  801147:	83 c4 10             	add    $0x10,%esp
  80114a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80114f:	eb 26                	jmp    801177 <read+0x8a>
	}
	if (!dev->dev_read)
  801151:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801154:	8b 40 08             	mov    0x8(%eax),%eax
  801157:	85 c0                	test   %eax,%eax
  801159:	74 17                	je     801172 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80115b:	83 ec 04             	sub    $0x4,%esp
  80115e:	ff 75 10             	pushl  0x10(%ebp)
  801161:	ff 75 0c             	pushl  0xc(%ebp)
  801164:	52                   	push   %edx
  801165:	ff d0                	call   *%eax
  801167:	89 c2                	mov    %eax,%edx
  801169:	83 c4 10             	add    $0x10,%esp
  80116c:	eb 09                	jmp    801177 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80116e:	89 c2                	mov    %eax,%edx
  801170:	eb 05                	jmp    801177 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801172:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801177:	89 d0                	mov    %edx,%eax
  801179:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80117c:	c9                   	leave  
  80117d:	c3                   	ret    

0080117e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80117e:	55                   	push   %ebp
  80117f:	89 e5                	mov    %esp,%ebp
  801181:	57                   	push   %edi
  801182:	56                   	push   %esi
  801183:	53                   	push   %ebx
  801184:	83 ec 0c             	sub    $0xc,%esp
  801187:	8b 7d 08             	mov    0x8(%ebp),%edi
  80118a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80118d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801192:	eb 21                	jmp    8011b5 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801194:	83 ec 04             	sub    $0x4,%esp
  801197:	89 f0                	mov    %esi,%eax
  801199:	29 d8                	sub    %ebx,%eax
  80119b:	50                   	push   %eax
  80119c:	89 d8                	mov    %ebx,%eax
  80119e:	03 45 0c             	add    0xc(%ebp),%eax
  8011a1:	50                   	push   %eax
  8011a2:	57                   	push   %edi
  8011a3:	e8 45 ff ff ff       	call   8010ed <read>
		if (m < 0)
  8011a8:	83 c4 10             	add    $0x10,%esp
  8011ab:	85 c0                	test   %eax,%eax
  8011ad:	78 10                	js     8011bf <readn+0x41>
			return m;
		if (m == 0)
  8011af:	85 c0                	test   %eax,%eax
  8011b1:	74 0a                	je     8011bd <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011b3:	01 c3                	add    %eax,%ebx
  8011b5:	39 f3                	cmp    %esi,%ebx
  8011b7:	72 db                	jb     801194 <readn+0x16>
  8011b9:	89 d8                	mov    %ebx,%eax
  8011bb:	eb 02                	jmp    8011bf <readn+0x41>
  8011bd:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8011bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011c2:	5b                   	pop    %ebx
  8011c3:	5e                   	pop    %esi
  8011c4:	5f                   	pop    %edi
  8011c5:	5d                   	pop    %ebp
  8011c6:	c3                   	ret    

008011c7 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011c7:	55                   	push   %ebp
  8011c8:	89 e5                	mov    %esp,%ebp
  8011ca:	53                   	push   %ebx
  8011cb:	83 ec 14             	sub    $0x14,%esp
  8011ce:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011d1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011d4:	50                   	push   %eax
  8011d5:	53                   	push   %ebx
  8011d6:	e8 ac fc ff ff       	call   800e87 <fd_lookup>
  8011db:	83 c4 08             	add    $0x8,%esp
  8011de:	89 c2                	mov    %eax,%edx
  8011e0:	85 c0                	test   %eax,%eax
  8011e2:	78 68                	js     80124c <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011e4:	83 ec 08             	sub    $0x8,%esp
  8011e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011ea:	50                   	push   %eax
  8011eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011ee:	ff 30                	pushl  (%eax)
  8011f0:	e8 e8 fc ff ff       	call   800edd <dev_lookup>
  8011f5:	83 c4 10             	add    $0x10,%esp
  8011f8:	85 c0                	test   %eax,%eax
  8011fa:	78 47                	js     801243 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011ff:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801203:	75 21                	jne    801226 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801205:	a1 08 40 80 00       	mov    0x804008,%eax
  80120a:	8b 40 48             	mov    0x48(%eax),%eax
  80120d:	83 ec 04             	sub    $0x4,%esp
  801210:	53                   	push   %ebx
  801211:	50                   	push   %eax
  801212:	68 8c 27 80 00       	push   $0x80278c
  801217:	e8 e7 ef ff ff       	call   800203 <cprintf>
		return -E_INVAL;
  80121c:	83 c4 10             	add    $0x10,%esp
  80121f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801224:	eb 26                	jmp    80124c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801226:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801229:	8b 52 0c             	mov    0xc(%edx),%edx
  80122c:	85 d2                	test   %edx,%edx
  80122e:	74 17                	je     801247 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801230:	83 ec 04             	sub    $0x4,%esp
  801233:	ff 75 10             	pushl  0x10(%ebp)
  801236:	ff 75 0c             	pushl  0xc(%ebp)
  801239:	50                   	push   %eax
  80123a:	ff d2                	call   *%edx
  80123c:	89 c2                	mov    %eax,%edx
  80123e:	83 c4 10             	add    $0x10,%esp
  801241:	eb 09                	jmp    80124c <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801243:	89 c2                	mov    %eax,%edx
  801245:	eb 05                	jmp    80124c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801247:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80124c:	89 d0                	mov    %edx,%eax
  80124e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801251:	c9                   	leave  
  801252:	c3                   	ret    

00801253 <seek>:

int
seek(int fdnum, off_t offset)
{
  801253:	55                   	push   %ebp
  801254:	89 e5                	mov    %esp,%ebp
  801256:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801259:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80125c:	50                   	push   %eax
  80125d:	ff 75 08             	pushl  0x8(%ebp)
  801260:	e8 22 fc ff ff       	call   800e87 <fd_lookup>
  801265:	83 c4 08             	add    $0x8,%esp
  801268:	85 c0                	test   %eax,%eax
  80126a:	78 0e                	js     80127a <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80126c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80126f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801272:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801275:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80127a:	c9                   	leave  
  80127b:	c3                   	ret    

0080127c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80127c:	55                   	push   %ebp
  80127d:	89 e5                	mov    %esp,%ebp
  80127f:	53                   	push   %ebx
  801280:	83 ec 14             	sub    $0x14,%esp
  801283:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801286:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801289:	50                   	push   %eax
  80128a:	53                   	push   %ebx
  80128b:	e8 f7 fb ff ff       	call   800e87 <fd_lookup>
  801290:	83 c4 08             	add    $0x8,%esp
  801293:	89 c2                	mov    %eax,%edx
  801295:	85 c0                	test   %eax,%eax
  801297:	78 65                	js     8012fe <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801299:	83 ec 08             	sub    $0x8,%esp
  80129c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80129f:	50                   	push   %eax
  8012a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012a3:	ff 30                	pushl  (%eax)
  8012a5:	e8 33 fc ff ff       	call   800edd <dev_lookup>
  8012aa:	83 c4 10             	add    $0x10,%esp
  8012ad:	85 c0                	test   %eax,%eax
  8012af:	78 44                	js     8012f5 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012b4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012b8:	75 21                	jne    8012db <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012ba:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012bf:	8b 40 48             	mov    0x48(%eax),%eax
  8012c2:	83 ec 04             	sub    $0x4,%esp
  8012c5:	53                   	push   %ebx
  8012c6:	50                   	push   %eax
  8012c7:	68 4c 27 80 00       	push   $0x80274c
  8012cc:	e8 32 ef ff ff       	call   800203 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012d1:	83 c4 10             	add    $0x10,%esp
  8012d4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012d9:	eb 23                	jmp    8012fe <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8012db:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012de:	8b 52 18             	mov    0x18(%edx),%edx
  8012e1:	85 d2                	test   %edx,%edx
  8012e3:	74 14                	je     8012f9 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012e5:	83 ec 08             	sub    $0x8,%esp
  8012e8:	ff 75 0c             	pushl  0xc(%ebp)
  8012eb:	50                   	push   %eax
  8012ec:	ff d2                	call   *%edx
  8012ee:	89 c2                	mov    %eax,%edx
  8012f0:	83 c4 10             	add    $0x10,%esp
  8012f3:	eb 09                	jmp    8012fe <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012f5:	89 c2                	mov    %eax,%edx
  8012f7:	eb 05                	jmp    8012fe <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012f9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8012fe:	89 d0                	mov    %edx,%eax
  801300:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801303:	c9                   	leave  
  801304:	c3                   	ret    

00801305 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801305:	55                   	push   %ebp
  801306:	89 e5                	mov    %esp,%ebp
  801308:	53                   	push   %ebx
  801309:	83 ec 14             	sub    $0x14,%esp
  80130c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80130f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801312:	50                   	push   %eax
  801313:	ff 75 08             	pushl  0x8(%ebp)
  801316:	e8 6c fb ff ff       	call   800e87 <fd_lookup>
  80131b:	83 c4 08             	add    $0x8,%esp
  80131e:	89 c2                	mov    %eax,%edx
  801320:	85 c0                	test   %eax,%eax
  801322:	78 58                	js     80137c <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801324:	83 ec 08             	sub    $0x8,%esp
  801327:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80132a:	50                   	push   %eax
  80132b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80132e:	ff 30                	pushl  (%eax)
  801330:	e8 a8 fb ff ff       	call   800edd <dev_lookup>
  801335:	83 c4 10             	add    $0x10,%esp
  801338:	85 c0                	test   %eax,%eax
  80133a:	78 37                	js     801373 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80133c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80133f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801343:	74 32                	je     801377 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801345:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801348:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80134f:	00 00 00 
	stat->st_isdir = 0;
  801352:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801359:	00 00 00 
	stat->st_dev = dev;
  80135c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801362:	83 ec 08             	sub    $0x8,%esp
  801365:	53                   	push   %ebx
  801366:	ff 75 f0             	pushl  -0x10(%ebp)
  801369:	ff 50 14             	call   *0x14(%eax)
  80136c:	89 c2                	mov    %eax,%edx
  80136e:	83 c4 10             	add    $0x10,%esp
  801371:	eb 09                	jmp    80137c <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801373:	89 c2                	mov    %eax,%edx
  801375:	eb 05                	jmp    80137c <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801377:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80137c:	89 d0                	mov    %edx,%eax
  80137e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801381:	c9                   	leave  
  801382:	c3                   	ret    

00801383 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801383:	55                   	push   %ebp
  801384:	89 e5                	mov    %esp,%ebp
  801386:	56                   	push   %esi
  801387:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801388:	83 ec 08             	sub    $0x8,%esp
  80138b:	6a 00                	push   $0x0
  80138d:	ff 75 08             	pushl  0x8(%ebp)
  801390:	e8 0c 02 00 00       	call   8015a1 <open>
  801395:	89 c3                	mov    %eax,%ebx
  801397:	83 c4 10             	add    $0x10,%esp
  80139a:	85 c0                	test   %eax,%eax
  80139c:	78 1b                	js     8013b9 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80139e:	83 ec 08             	sub    $0x8,%esp
  8013a1:	ff 75 0c             	pushl  0xc(%ebp)
  8013a4:	50                   	push   %eax
  8013a5:	e8 5b ff ff ff       	call   801305 <fstat>
  8013aa:	89 c6                	mov    %eax,%esi
	close(fd);
  8013ac:	89 1c 24             	mov    %ebx,(%esp)
  8013af:	e8 fd fb ff ff       	call   800fb1 <close>
	return r;
  8013b4:	83 c4 10             	add    $0x10,%esp
  8013b7:	89 f0                	mov    %esi,%eax
}
  8013b9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013bc:	5b                   	pop    %ebx
  8013bd:	5e                   	pop    %esi
  8013be:	5d                   	pop    %ebp
  8013bf:	c3                   	ret    

008013c0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013c0:	55                   	push   %ebp
  8013c1:	89 e5                	mov    %esp,%ebp
  8013c3:	56                   	push   %esi
  8013c4:	53                   	push   %ebx
  8013c5:	89 c6                	mov    %eax,%esi
  8013c7:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013c9:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013d0:	75 12                	jne    8013e4 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013d2:	83 ec 0c             	sub    $0xc,%esp
  8013d5:	6a 01                	push   $0x1
  8013d7:	e8 6c 0c 00 00       	call   802048 <ipc_find_env>
  8013dc:	a3 00 40 80 00       	mov    %eax,0x804000
  8013e1:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013e4:	6a 07                	push   $0x7
  8013e6:	68 00 50 80 00       	push   $0x805000
  8013eb:	56                   	push   %esi
  8013ec:	ff 35 00 40 80 00    	pushl  0x804000
  8013f2:	e8 fd 0b 00 00       	call   801ff4 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013f7:	83 c4 0c             	add    $0xc,%esp
  8013fa:	6a 00                	push   $0x0
  8013fc:	53                   	push   %ebx
  8013fd:	6a 00                	push   $0x0
  8013ff:	e8 87 0b 00 00       	call   801f8b <ipc_recv>
}
  801404:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801407:	5b                   	pop    %ebx
  801408:	5e                   	pop    %esi
  801409:	5d                   	pop    %ebp
  80140a:	c3                   	ret    

0080140b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80140b:	55                   	push   %ebp
  80140c:	89 e5                	mov    %esp,%ebp
  80140e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801411:	8b 45 08             	mov    0x8(%ebp),%eax
  801414:	8b 40 0c             	mov    0xc(%eax),%eax
  801417:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80141c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80141f:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801424:	ba 00 00 00 00       	mov    $0x0,%edx
  801429:	b8 02 00 00 00       	mov    $0x2,%eax
  80142e:	e8 8d ff ff ff       	call   8013c0 <fsipc>
}
  801433:	c9                   	leave  
  801434:	c3                   	ret    

00801435 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801435:	55                   	push   %ebp
  801436:	89 e5                	mov    %esp,%ebp
  801438:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80143b:	8b 45 08             	mov    0x8(%ebp),%eax
  80143e:	8b 40 0c             	mov    0xc(%eax),%eax
  801441:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801446:	ba 00 00 00 00       	mov    $0x0,%edx
  80144b:	b8 06 00 00 00       	mov    $0x6,%eax
  801450:	e8 6b ff ff ff       	call   8013c0 <fsipc>
}
  801455:	c9                   	leave  
  801456:	c3                   	ret    

00801457 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801457:	55                   	push   %ebp
  801458:	89 e5                	mov    %esp,%ebp
  80145a:	53                   	push   %ebx
  80145b:	83 ec 04             	sub    $0x4,%esp
  80145e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801461:	8b 45 08             	mov    0x8(%ebp),%eax
  801464:	8b 40 0c             	mov    0xc(%eax),%eax
  801467:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80146c:	ba 00 00 00 00       	mov    $0x0,%edx
  801471:	b8 05 00 00 00       	mov    $0x5,%eax
  801476:	e8 45 ff ff ff       	call   8013c0 <fsipc>
  80147b:	85 c0                	test   %eax,%eax
  80147d:	78 2c                	js     8014ab <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80147f:	83 ec 08             	sub    $0x8,%esp
  801482:	68 00 50 80 00       	push   $0x805000
  801487:	53                   	push   %ebx
  801488:	e8 fb f2 ff ff       	call   800788 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80148d:	a1 80 50 80 00       	mov    0x805080,%eax
  801492:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801498:	a1 84 50 80 00       	mov    0x805084,%eax
  80149d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014a3:	83 c4 10             	add    $0x10,%esp
  8014a6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014ab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014ae:	c9                   	leave  
  8014af:	c3                   	ret    

008014b0 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8014b0:	55                   	push   %ebp
  8014b1:	89 e5                	mov    %esp,%ebp
  8014b3:	53                   	push   %ebx
  8014b4:	83 ec 08             	sub    $0x8,%esp
  8014b7:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8014bd:	8b 52 0c             	mov    0xc(%edx),%edx
  8014c0:	89 15 00 50 80 00    	mov    %edx,0x805000
  8014c6:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8014cb:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  8014d0:	0f 46 d8             	cmovbe %eax,%ebx
	
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  8014d3:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  8014d9:	53                   	push   %ebx
  8014da:	ff 75 0c             	pushl  0xc(%ebp)
  8014dd:	68 08 50 80 00       	push   $0x805008
  8014e2:	e8 33 f4 ff ff       	call   80091a <memmove>

	
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) 
  8014e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ec:	b8 04 00 00 00       	mov    $0x4,%eax
  8014f1:	e8 ca fe ff ff       	call   8013c0 <fsipc>
  8014f6:	83 c4 10             	add    $0x10,%esp
  8014f9:	85 c0                	test   %eax,%eax
  8014fb:	78 1d                	js     80151a <devfile_write+0x6a>
		return r;
	assert(r <= n_real); 
  8014fd:	39 d8                	cmp    %ebx,%eax
  8014ff:	76 19                	jbe    80151a <devfile_write+0x6a>
  801501:	68 c0 27 80 00       	push   $0x8027c0
  801506:	68 cc 27 80 00       	push   $0x8027cc
  80150b:	68 a3 00 00 00       	push   $0xa3
  801510:	68 e1 27 80 00       	push   $0x8027e1
  801515:	e8 10 ec ff ff       	call   80012a <_panic>
	return r;
}
  80151a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80151d:	c9                   	leave  
  80151e:	c3                   	ret    

0080151f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80151f:	55                   	push   %ebp
  801520:	89 e5                	mov    %esp,%ebp
  801522:	56                   	push   %esi
  801523:	53                   	push   %ebx
  801524:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801527:	8b 45 08             	mov    0x8(%ebp),%eax
  80152a:	8b 40 0c             	mov    0xc(%eax),%eax
  80152d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801532:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801538:	ba 00 00 00 00       	mov    $0x0,%edx
  80153d:	b8 03 00 00 00       	mov    $0x3,%eax
  801542:	e8 79 fe ff ff       	call   8013c0 <fsipc>
  801547:	89 c3                	mov    %eax,%ebx
  801549:	85 c0                	test   %eax,%eax
  80154b:	78 4b                	js     801598 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80154d:	39 c6                	cmp    %eax,%esi
  80154f:	73 16                	jae    801567 <devfile_read+0x48>
  801551:	68 ec 27 80 00       	push   $0x8027ec
  801556:	68 cc 27 80 00       	push   $0x8027cc
  80155b:	6a 7c                	push   $0x7c
  80155d:	68 e1 27 80 00       	push   $0x8027e1
  801562:	e8 c3 eb ff ff       	call   80012a <_panic>
	assert(r <= PGSIZE);
  801567:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80156c:	7e 16                	jle    801584 <devfile_read+0x65>
  80156e:	68 f3 27 80 00       	push   $0x8027f3
  801573:	68 cc 27 80 00       	push   $0x8027cc
  801578:	6a 7d                	push   $0x7d
  80157a:	68 e1 27 80 00       	push   $0x8027e1
  80157f:	e8 a6 eb ff ff       	call   80012a <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801584:	83 ec 04             	sub    $0x4,%esp
  801587:	50                   	push   %eax
  801588:	68 00 50 80 00       	push   $0x805000
  80158d:	ff 75 0c             	pushl  0xc(%ebp)
  801590:	e8 85 f3 ff ff       	call   80091a <memmove>
	return r;
  801595:	83 c4 10             	add    $0x10,%esp
}
  801598:	89 d8                	mov    %ebx,%eax
  80159a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80159d:	5b                   	pop    %ebx
  80159e:	5e                   	pop    %esi
  80159f:	5d                   	pop    %ebp
  8015a0:	c3                   	ret    

008015a1 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8015a1:	55                   	push   %ebp
  8015a2:	89 e5                	mov    %esp,%ebp
  8015a4:	53                   	push   %ebx
  8015a5:	83 ec 20             	sub    $0x20,%esp
  8015a8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015ab:	53                   	push   %ebx
  8015ac:	e8 9e f1 ff ff       	call   80074f <strlen>
  8015b1:	83 c4 10             	add    $0x10,%esp
  8015b4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015b9:	7f 67                	jg     801622 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015bb:	83 ec 0c             	sub    $0xc,%esp
  8015be:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015c1:	50                   	push   %eax
  8015c2:	e8 71 f8 ff ff       	call   800e38 <fd_alloc>
  8015c7:	83 c4 10             	add    $0x10,%esp
		return r;
  8015ca:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015cc:	85 c0                	test   %eax,%eax
  8015ce:	78 57                	js     801627 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015d0:	83 ec 08             	sub    $0x8,%esp
  8015d3:	53                   	push   %ebx
  8015d4:	68 00 50 80 00       	push   $0x805000
  8015d9:	e8 aa f1 ff ff       	call   800788 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015e1:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015e6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015e9:	b8 01 00 00 00       	mov    $0x1,%eax
  8015ee:	e8 cd fd ff ff       	call   8013c0 <fsipc>
  8015f3:	89 c3                	mov    %eax,%ebx
  8015f5:	83 c4 10             	add    $0x10,%esp
  8015f8:	85 c0                	test   %eax,%eax
  8015fa:	79 14                	jns    801610 <open+0x6f>
		fd_close(fd, 0);
  8015fc:	83 ec 08             	sub    $0x8,%esp
  8015ff:	6a 00                	push   $0x0
  801601:	ff 75 f4             	pushl  -0xc(%ebp)
  801604:	e8 27 f9 ff ff       	call   800f30 <fd_close>
		return r;
  801609:	83 c4 10             	add    $0x10,%esp
  80160c:	89 da                	mov    %ebx,%edx
  80160e:	eb 17                	jmp    801627 <open+0x86>
	}

	return fd2num(fd);
  801610:	83 ec 0c             	sub    $0xc,%esp
  801613:	ff 75 f4             	pushl  -0xc(%ebp)
  801616:	e8 f6 f7 ff ff       	call   800e11 <fd2num>
  80161b:	89 c2                	mov    %eax,%edx
  80161d:	83 c4 10             	add    $0x10,%esp
  801620:	eb 05                	jmp    801627 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801622:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801627:	89 d0                	mov    %edx,%eax
  801629:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80162c:	c9                   	leave  
  80162d:	c3                   	ret    

0080162e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80162e:	55                   	push   %ebp
  80162f:	89 e5                	mov    %esp,%ebp
  801631:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801634:	ba 00 00 00 00       	mov    $0x0,%edx
  801639:	b8 08 00 00 00       	mov    $0x8,%eax
  80163e:	e8 7d fd ff ff       	call   8013c0 <fsipc>
}
  801643:	c9                   	leave  
  801644:	c3                   	ret    

00801645 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801645:	55                   	push   %ebp
  801646:	89 e5                	mov    %esp,%ebp
  801648:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  80164b:	68 ff 27 80 00       	push   $0x8027ff
  801650:	ff 75 0c             	pushl  0xc(%ebp)
  801653:	e8 30 f1 ff ff       	call   800788 <strcpy>
	return 0;
}
  801658:	b8 00 00 00 00       	mov    $0x0,%eax
  80165d:	c9                   	leave  
  80165e:	c3                   	ret    

0080165f <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  80165f:	55                   	push   %ebp
  801660:	89 e5                	mov    %esp,%ebp
  801662:	53                   	push   %ebx
  801663:	83 ec 10             	sub    $0x10,%esp
  801666:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801669:	53                   	push   %ebx
  80166a:	e8 12 0a 00 00       	call   802081 <pageref>
  80166f:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801672:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801677:	83 f8 01             	cmp    $0x1,%eax
  80167a:	75 10                	jne    80168c <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  80167c:	83 ec 0c             	sub    $0xc,%esp
  80167f:	ff 73 0c             	pushl  0xc(%ebx)
  801682:	e8 c0 02 00 00       	call   801947 <nsipc_close>
  801687:	89 c2                	mov    %eax,%edx
  801689:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  80168c:	89 d0                	mov    %edx,%eax
  80168e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801691:	c9                   	leave  
  801692:	c3                   	ret    

00801693 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801693:	55                   	push   %ebp
  801694:	89 e5                	mov    %esp,%ebp
  801696:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801699:	6a 00                	push   $0x0
  80169b:	ff 75 10             	pushl  0x10(%ebp)
  80169e:	ff 75 0c             	pushl  0xc(%ebp)
  8016a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a4:	ff 70 0c             	pushl  0xc(%eax)
  8016a7:	e8 78 03 00 00       	call   801a24 <nsipc_send>
}
  8016ac:	c9                   	leave  
  8016ad:	c3                   	ret    

008016ae <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8016ae:	55                   	push   %ebp
  8016af:	89 e5                	mov    %esp,%ebp
  8016b1:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8016b4:	6a 00                	push   $0x0
  8016b6:	ff 75 10             	pushl  0x10(%ebp)
  8016b9:	ff 75 0c             	pushl  0xc(%ebp)
  8016bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8016bf:	ff 70 0c             	pushl  0xc(%eax)
  8016c2:	e8 f1 02 00 00       	call   8019b8 <nsipc_recv>
}
  8016c7:	c9                   	leave  
  8016c8:	c3                   	ret    

008016c9 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8016c9:	55                   	push   %ebp
  8016ca:	89 e5                	mov    %esp,%ebp
  8016cc:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8016cf:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8016d2:	52                   	push   %edx
  8016d3:	50                   	push   %eax
  8016d4:	e8 ae f7 ff ff       	call   800e87 <fd_lookup>
  8016d9:	83 c4 10             	add    $0x10,%esp
  8016dc:	85 c0                	test   %eax,%eax
  8016de:	78 17                	js     8016f7 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8016e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016e3:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  8016e9:	39 08                	cmp    %ecx,(%eax)
  8016eb:	75 05                	jne    8016f2 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8016ed:	8b 40 0c             	mov    0xc(%eax),%eax
  8016f0:	eb 05                	jmp    8016f7 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  8016f2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  8016f7:	c9                   	leave  
  8016f8:	c3                   	ret    

008016f9 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  8016f9:	55                   	push   %ebp
  8016fa:	89 e5                	mov    %esp,%ebp
  8016fc:	56                   	push   %esi
  8016fd:	53                   	push   %ebx
  8016fe:	83 ec 1c             	sub    $0x1c,%esp
  801701:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801703:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801706:	50                   	push   %eax
  801707:	e8 2c f7 ff ff       	call   800e38 <fd_alloc>
  80170c:	89 c3                	mov    %eax,%ebx
  80170e:	83 c4 10             	add    $0x10,%esp
  801711:	85 c0                	test   %eax,%eax
  801713:	78 1b                	js     801730 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801715:	83 ec 04             	sub    $0x4,%esp
  801718:	68 07 04 00 00       	push   $0x407
  80171d:	ff 75 f4             	pushl  -0xc(%ebp)
  801720:	6a 00                	push   $0x0
  801722:	e8 64 f4 ff ff       	call   800b8b <sys_page_alloc>
  801727:	89 c3                	mov    %eax,%ebx
  801729:	83 c4 10             	add    $0x10,%esp
  80172c:	85 c0                	test   %eax,%eax
  80172e:	79 10                	jns    801740 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801730:	83 ec 0c             	sub    $0xc,%esp
  801733:	56                   	push   %esi
  801734:	e8 0e 02 00 00       	call   801947 <nsipc_close>
		return r;
  801739:	83 c4 10             	add    $0x10,%esp
  80173c:	89 d8                	mov    %ebx,%eax
  80173e:	eb 24                	jmp    801764 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801740:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801746:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801749:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  80174b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80174e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801755:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801758:	83 ec 0c             	sub    $0xc,%esp
  80175b:	50                   	push   %eax
  80175c:	e8 b0 f6 ff ff       	call   800e11 <fd2num>
  801761:	83 c4 10             	add    $0x10,%esp
}
  801764:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801767:	5b                   	pop    %ebx
  801768:	5e                   	pop    %esi
  801769:	5d                   	pop    %ebp
  80176a:	c3                   	ret    

0080176b <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80176b:	55                   	push   %ebp
  80176c:	89 e5                	mov    %esp,%ebp
  80176e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801771:	8b 45 08             	mov    0x8(%ebp),%eax
  801774:	e8 50 ff ff ff       	call   8016c9 <fd2sockid>
		return r;
  801779:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  80177b:	85 c0                	test   %eax,%eax
  80177d:	78 1f                	js     80179e <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80177f:	83 ec 04             	sub    $0x4,%esp
  801782:	ff 75 10             	pushl  0x10(%ebp)
  801785:	ff 75 0c             	pushl  0xc(%ebp)
  801788:	50                   	push   %eax
  801789:	e8 12 01 00 00       	call   8018a0 <nsipc_accept>
  80178e:	83 c4 10             	add    $0x10,%esp
		return r;
  801791:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801793:	85 c0                	test   %eax,%eax
  801795:	78 07                	js     80179e <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801797:	e8 5d ff ff ff       	call   8016f9 <alloc_sockfd>
  80179c:	89 c1                	mov    %eax,%ecx
}
  80179e:	89 c8                	mov    %ecx,%eax
  8017a0:	c9                   	leave  
  8017a1:	c3                   	ret    

008017a2 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8017a2:	55                   	push   %ebp
  8017a3:	89 e5                	mov    %esp,%ebp
  8017a5:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8017a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ab:	e8 19 ff ff ff       	call   8016c9 <fd2sockid>
  8017b0:	85 c0                	test   %eax,%eax
  8017b2:	78 12                	js     8017c6 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  8017b4:	83 ec 04             	sub    $0x4,%esp
  8017b7:	ff 75 10             	pushl  0x10(%ebp)
  8017ba:	ff 75 0c             	pushl  0xc(%ebp)
  8017bd:	50                   	push   %eax
  8017be:	e8 2d 01 00 00       	call   8018f0 <nsipc_bind>
  8017c3:	83 c4 10             	add    $0x10,%esp
}
  8017c6:	c9                   	leave  
  8017c7:	c3                   	ret    

008017c8 <shutdown>:

int
shutdown(int s, int how)
{
  8017c8:	55                   	push   %ebp
  8017c9:	89 e5                	mov    %esp,%ebp
  8017cb:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8017ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d1:	e8 f3 fe ff ff       	call   8016c9 <fd2sockid>
  8017d6:	85 c0                	test   %eax,%eax
  8017d8:	78 0f                	js     8017e9 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8017da:	83 ec 08             	sub    $0x8,%esp
  8017dd:	ff 75 0c             	pushl  0xc(%ebp)
  8017e0:	50                   	push   %eax
  8017e1:	e8 3f 01 00 00       	call   801925 <nsipc_shutdown>
  8017e6:	83 c4 10             	add    $0x10,%esp
}
  8017e9:	c9                   	leave  
  8017ea:	c3                   	ret    

008017eb <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8017eb:	55                   	push   %ebp
  8017ec:	89 e5                	mov    %esp,%ebp
  8017ee:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8017f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f4:	e8 d0 fe ff ff       	call   8016c9 <fd2sockid>
  8017f9:	85 c0                	test   %eax,%eax
  8017fb:	78 12                	js     80180f <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  8017fd:	83 ec 04             	sub    $0x4,%esp
  801800:	ff 75 10             	pushl  0x10(%ebp)
  801803:	ff 75 0c             	pushl  0xc(%ebp)
  801806:	50                   	push   %eax
  801807:	e8 55 01 00 00       	call   801961 <nsipc_connect>
  80180c:	83 c4 10             	add    $0x10,%esp
}
  80180f:	c9                   	leave  
  801810:	c3                   	ret    

00801811 <listen>:

int
listen(int s, int backlog)
{
  801811:	55                   	push   %ebp
  801812:	89 e5                	mov    %esp,%ebp
  801814:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801817:	8b 45 08             	mov    0x8(%ebp),%eax
  80181a:	e8 aa fe ff ff       	call   8016c9 <fd2sockid>
  80181f:	85 c0                	test   %eax,%eax
  801821:	78 0f                	js     801832 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801823:	83 ec 08             	sub    $0x8,%esp
  801826:	ff 75 0c             	pushl  0xc(%ebp)
  801829:	50                   	push   %eax
  80182a:	e8 67 01 00 00       	call   801996 <nsipc_listen>
  80182f:	83 c4 10             	add    $0x10,%esp
}
  801832:	c9                   	leave  
  801833:	c3                   	ret    

00801834 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801834:	55                   	push   %ebp
  801835:	89 e5                	mov    %esp,%ebp
  801837:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  80183a:	ff 75 10             	pushl  0x10(%ebp)
  80183d:	ff 75 0c             	pushl  0xc(%ebp)
  801840:	ff 75 08             	pushl  0x8(%ebp)
  801843:	e8 3a 02 00 00       	call   801a82 <nsipc_socket>
  801848:	83 c4 10             	add    $0x10,%esp
  80184b:	85 c0                	test   %eax,%eax
  80184d:	78 05                	js     801854 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  80184f:	e8 a5 fe ff ff       	call   8016f9 <alloc_sockfd>
}
  801854:	c9                   	leave  
  801855:	c3                   	ret    

00801856 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801856:	55                   	push   %ebp
  801857:	89 e5                	mov    %esp,%ebp
  801859:	53                   	push   %ebx
  80185a:	83 ec 04             	sub    $0x4,%esp
  80185d:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  80185f:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801866:	75 12                	jne    80187a <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801868:	83 ec 0c             	sub    $0xc,%esp
  80186b:	6a 02                	push   $0x2
  80186d:	e8 d6 07 00 00       	call   802048 <ipc_find_env>
  801872:	a3 04 40 80 00       	mov    %eax,0x804004
  801877:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  80187a:	6a 07                	push   $0x7
  80187c:	68 00 60 80 00       	push   $0x806000
  801881:	53                   	push   %ebx
  801882:	ff 35 04 40 80 00    	pushl  0x804004
  801888:	e8 67 07 00 00       	call   801ff4 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  80188d:	83 c4 0c             	add    $0xc,%esp
  801890:	6a 00                	push   $0x0
  801892:	6a 00                	push   $0x0
  801894:	6a 00                	push   $0x0
  801896:	e8 f0 06 00 00       	call   801f8b <ipc_recv>
}
  80189b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80189e:	c9                   	leave  
  80189f:	c3                   	ret    

008018a0 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8018a0:	55                   	push   %ebp
  8018a1:	89 e5                	mov    %esp,%ebp
  8018a3:	56                   	push   %esi
  8018a4:	53                   	push   %ebx
  8018a5:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8018a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ab:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8018b0:	8b 06                	mov    (%esi),%eax
  8018b2:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8018b7:	b8 01 00 00 00       	mov    $0x1,%eax
  8018bc:	e8 95 ff ff ff       	call   801856 <nsipc>
  8018c1:	89 c3                	mov    %eax,%ebx
  8018c3:	85 c0                	test   %eax,%eax
  8018c5:	78 20                	js     8018e7 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8018c7:	83 ec 04             	sub    $0x4,%esp
  8018ca:	ff 35 10 60 80 00    	pushl  0x806010
  8018d0:	68 00 60 80 00       	push   $0x806000
  8018d5:	ff 75 0c             	pushl  0xc(%ebp)
  8018d8:	e8 3d f0 ff ff       	call   80091a <memmove>
		*addrlen = ret->ret_addrlen;
  8018dd:	a1 10 60 80 00       	mov    0x806010,%eax
  8018e2:	89 06                	mov    %eax,(%esi)
  8018e4:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  8018e7:	89 d8                	mov    %ebx,%eax
  8018e9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018ec:	5b                   	pop    %ebx
  8018ed:	5e                   	pop    %esi
  8018ee:	5d                   	pop    %ebp
  8018ef:	c3                   	ret    

008018f0 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8018f0:	55                   	push   %ebp
  8018f1:	89 e5                	mov    %esp,%ebp
  8018f3:	53                   	push   %ebx
  8018f4:	83 ec 08             	sub    $0x8,%esp
  8018f7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8018fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8018fd:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801902:	53                   	push   %ebx
  801903:	ff 75 0c             	pushl  0xc(%ebp)
  801906:	68 04 60 80 00       	push   $0x806004
  80190b:	e8 0a f0 ff ff       	call   80091a <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801910:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801916:	b8 02 00 00 00       	mov    $0x2,%eax
  80191b:	e8 36 ff ff ff       	call   801856 <nsipc>
}
  801920:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801923:	c9                   	leave  
  801924:	c3                   	ret    

00801925 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801925:	55                   	push   %ebp
  801926:	89 e5                	mov    %esp,%ebp
  801928:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  80192b:	8b 45 08             	mov    0x8(%ebp),%eax
  80192e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801933:	8b 45 0c             	mov    0xc(%ebp),%eax
  801936:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  80193b:	b8 03 00 00 00       	mov    $0x3,%eax
  801940:	e8 11 ff ff ff       	call   801856 <nsipc>
}
  801945:	c9                   	leave  
  801946:	c3                   	ret    

00801947 <nsipc_close>:

int
nsipc_close(int s)
{
  801947:	55                   	push   %ebp
  801948:	89 e5                	mov    %esp,%ebp
  80194a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  80194d:	8b 45 08             	mov    0x8(%ebp),%eax
  801950:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801955:	b8 04 00 00 00       	mov    $0x4,%eax
  80195a:	e8 f7 fe ff ff       	call   801856 <nsipc>
}
  80195f:	c9                   	leave  
  801960:	c3                   	ret    

00801961 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801961:	55                   	push   %ebp
  801962:	89 e5                	mov    %esp,%ebp
  801964:	53                   	push   %ebx
  801965:	83 ec 08             	sub    $0x8,%esp
  801968:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80196b:	8b 45 08             	mov    0x8(%ebp),%eax
  80196e:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801973:	53                   	push   %ebx
  801974:	ff 75 0c             	pushl  0xc(%ebp)
  801977:	68 04 60 80 00       	push   $0x806004
  80197c:	e8 99 ef ff ff       	call   80091a <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801981:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801987:	b8 05 00 00 00       	mov    $0x5,%eax
  80198c:	e8 c5 fe ff ff       	call   801856 <nsipc>
}
  801991:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801994:	c9                   	leave  
  801995:	c3                   	ret    

00801996 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801996:	55                   	push   %ebp
  801997:	89 e5                	mov    %esp,%ebp
  801999:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80199c:	8b 45 08             	mov    0x8(%ebp),%eax
  80199f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  8019a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019a7:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  8019ac:	b8 06 00 00 00       	mov    $0x6,%eax
  8019b1:	e8 a0 fe ff ff       	call   801856 <nsipc>
}
  8019b6:	c9                   	leave  
  8019b7:	c3                   	ret    

008019b8 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8019b8:	55                   	push   %ebp
  8019b9:	89 e5                	mov    %esp,%ebp
  8019bb:	56                   	push   %esi
  8019bc:	53                   	push   %ebx
  8019bd:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8019c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c3:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  8019c8:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  8019ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8019d1:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8019d6:	b8 07 00 00 00       	mov    $0x7,%eax
  8019db:	e8 76 fe ff ff       	call   801856 <nsipc>
  8019e0:	89 c3                	mov    %eax,%ebx
  8019e2:	85 c0                	test   %eax,%eax
  8019e4:	78 35                	js     801a1b <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  8019e6:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8019eb:	7f 04                	jg     8019f1 <nsipc_recv+0x39>
  8019ed:	39 c6                	cmp    %eax,%esi
  8019ef:	7d 16                	jge    801a07 <nsipc_recv+0x4f>
  8019f1:	68 0b 28 80 00       	push   $0x80280b
  8019f6:	68 cc 27 80 00       	push   $0x8027cc
  8019fb:	6a 62                	push   $0x62
  8019fd:	68 20 28 80 00       	push   $0x802820
  801a02:	e8 23 e7 ff ff       	call   80012a <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801a07:	83 ec 04             	sub    $0x4,%esp
  801a0a:	50                   	push   %eax
  801a0b:	68 00 60 80 00       	push   $0x806000
  801a10:	ff 75 0c             	pushl  0xc(%ebp)
  801a13:	e8 02 ef ff ff       	call   80091a <memmove>
  801a18:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801a1b:	89 d8                	mov    %ebx,%eax
  801a1d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a20:	5b                   	pop    %ebx
  801a21:	5e                   	pop    %esi
  801a22:	5d                   	pop    %ebp
  801a23:	c3                   	ret    

00801a24 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801a24:	55                   	push   %ebp
  801a25:	89 e5                	mov    %esp,%ebp
  801a27:	53                   	push   %ebx
  801a28:	83 ec 04             	sub    $0x4,%esp
  801a2b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801a2e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a31:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801a36:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801a3c:	7e 16                	jle    801a54 <nsipc_send+0x30>
  801a3e:	68 2c 28 80 00       	push   $0x80282c
  801a43:	68 cc 27 80 00       	push   $0x8027cc
  801a48:	6a 6d                	push   $0x6d
  801a4a:	68 20 28 80 00       	push   $0x802820
  801a4f:	e8 d6 e6 ff ff       	call   80012a <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801a54:	83 ec 04             	sub    $0x4,%esp
  801a57:	53                   	push   %ebx
  801a58:	ff 75 0c             	pushl  0xc(%ebp)
  801a5b:	68 0c 60 80 00       	push   $0x80600c
  801a60:	e8 b5 ee ff ff       	call   80091a <memmove>
	nsipcbuf.send.req_size = size;
  801a65:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801a6b:	8b 45 14             	mov    0x14(%ebp),%eax
  801a6e:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801a73:	b8 08 00 00 00       	mov    $0x8,%eax
  801a78:	e8 d9 fd ff ff       	call   801856 <nsipc>
}
  801a7d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a80:	c9                   	leave  
  801a81:	c3                   	ret    

00801a82 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801a82:	55                   	push   %ebp
  801a83:	89 e5                	mov    %esp,%ebp
  801a85:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801a88:	8b 45 08             	mov    0x8(%ebp),%eax
  801a8b:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801a90:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a93:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801a98:	8b 45 10             	mov    0x10(%ebp),%eax
  801a9b:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801aa0:	b8 09 00 00 00       	mov    $0x9,%eax
  801aa5:	e8 ac fd ff ff       	call   801856 <nsipc>
}
  801aaa:	c9                   	leave  
  801aab:	c3                   	ret    

00801aac <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801aac:	55                   	push   %ebp
  801aad:	89 e5                	mov    %esp,%ebp
  801aaf:	56                   	push   %esi
  801ab0:	53                   	push   %ebx
  801ab1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ab4:	83 ec 0c             	sub    $0xc,%esp
  801ab7:	ff 75 08             	pushl  0x8(%ebp)
  801aba:	e8 62 f3 ff ff       	call   800e21 <fd2data>
  801abf:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801ac1:	83 c4 08             	add    $0x8,%esp
  801ac4:	68 38 28 80 00       	push   $0x802838
  801ac9:	53                   	push   %ebx
  801aca:	e8 b9 ec ff ff       	call   800788 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801acf:	8b 46 04             	mov    0x4(%esi),%eax
  801ad2:	2b 06                	sub    (%esi),%eax
  801ad4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ada:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ae1:	00 00 00 
	stat->st_dev = &devpipe;
  801ae4:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801aeb:	30 80 00 
	return 0;
}
  801aee:	b8 00 00 00 00       	mov    $0x0,%eax
  801af3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801af6:	5b                   	pop    %ebx
  801af7:	5e                   	pop    %esi
  801af8:	5d                   	pop    %ebp
  801af9:	c3                   	ret    

00801afa <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801afa:	55                   	push   %ebp
  801afb:	89 e5                	mov    %esp,%ebp
  801afd:	53                   	push   %ebx
  801afe:	83 ec 0c             	sub    $0xc,%esp
  801b01:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b04:	53                   	push   %ebx
  801b05:	6a 00                	push   $0x0
  801b07:	e8 04 f1 ff ff       	call   800c10 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b0c:	89 1c 24             	mov    %ebx,(%esp)
  801b0f:	e8 0d f3 ff ff       	call   800e21 <fd2data>
  801b14:	83 c4 08             	add    $0x8,%esp
  801b17:	50                   	push   %eax
  801b18:	6a 00                	push   $0x0
  801b1a:	e8 f1 f0 ff ff       	call   800c10 <sys_page_unmap>
}
  801b1f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b22:	c9                   	leave  
  801b23:	c3                   	ret    

00801b24 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b24:	55                   	push   %ebp
  801b25:	89 e5                	mov    %esp,%ebp
  801b27:	57                   	push   %edi
  801b28:	56                   	push   %esi
  801b29:	53                   	push   %ebx
  801b2a:	83 ec 1c             	sub    $0x1c,%esp
  801b2d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b30:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b32:	a1 08 40 80 00       	mov    0x804008,%eax
  801b37:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801b3a:	83 ec 0c             	sub    $0xc,%esp
  801b3d:	ff 75 e0             	pushl  -0x20(%ebp)
  801b40:	e8 3c 05 00 00       	call   802081 <pageref>
  801b45:	89 c3                	mov    %eax,%ebx
  801b47:	89 3c 24             	mov    %edi,(%esp)
  801b4a:	e8 32 05 00 00       	call   802081 <pageref>
  801b4f:	83 c4 10             	add    $0x10,%esp
  801b52:	39 c3                	cmp    %eax,%ebx
  801b54:	0f 94 c1             	sete   %cl
  801b57:	0f b6 c9             	movzbl %cl,%ecx
  801b5a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801b5d:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801b63:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b66:	39 ce                	cmp    %ecx,%esi
  801b68:	74 1b                	je     801b85 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801b6a:	39 c3                	cmp    %eax,%ebx
  801b6c:	75 c4                	jne    801b32 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b6e:	8b 42 58             	mov    0x58(%edx),%eax
  801b71:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b74:	50                   	push   %eax
  801b75:	56                   	push   %esi
  801b76:	68 3f 28 80 00       	push   $0x80283f
  801b7b:	e8 83 e6 ff ff       	call   800203 <cprintf>
  801b80:	83 c4 10             	add    $0x10,%esp
  801b83:	eb ad                	jmp    801b32 <_pipeisclosed+0xe>
	}
}
  801b85:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b88:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b8b:	5b                   	pop    %ebx
  801b8c:	5e                   	pop    %esi
  801b8d:	5f                   	pop    %edi
  801b8e:	5d                   	pop    %ebp
  801b8f:	c3                   	ret    

00801b90 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b90:	55                   	push   %ebp
  801b91:	89 e5                	mov    %esp,%ebp
  801b93:	57                   	push   %edi
  801b94:	56                   	push   %esi
  801b95:	53                   	push   %ebx
  801b96:	83 ec 28             	sub    $0x28,%esp
  801b99:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b9c:	56                   	push   %esi
  801b9d:	e8 7f f2 ff ff       	call   800e21 <fd2data>
  801ba2:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ba4:	83 c4 10             	add    $0x10,%esp
  801ba7:	bf 00 00 00 00       	mov    $0x0,%edi
  801bac:	eb 4b                	jmp    801bf9 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801bae:	89 da                	mov    %ebx,%edx
  801bb0:	89 f0                	mov    %esi,%eax
  801bb2:	e8 6d ff ff ff       	call   801b24 <_pipeisclosed>
  801bb7:	85 c0                	test   %eax,%eax
  801bb9:	75 48                	jne    801c03 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801bbb:	e8 ac ef ff ff       	call   800b6c <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801bc0:	8b 43 04             	mov    0x4(%ebx),%eax
  801bc3:	8b 0b                	mov    (%ebx),%ecx
  801bc5:	8d 51 20             	lea    0x20(%ecx),%edx
  801bc8:	39 d0                	cmp    %edx,%eax
  801bca:	73 e2                	jae    801bae <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801bcc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bcf:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801bd3:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801bd6:	89 c2                	mov    %eax,%edx
  801bd8:	c1 fa 1f             	sar    $0x1f,%edx
  801bdb:	89 d1                	mov    %edx,%ecx
  801bdd:	c1 e9 1b             	shr    $0x1b,%ecx
  801be0:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801be3:	83 e2 1f             	and    $0x1f,%edx
  801be6:	29 ca                	sub    %ecx,%edx
  801be8:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801bec:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801bf0:	83 c0 01             	add    $0x1,%eax
  801bf3:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bf6:	83 c7 01             	add    $0x1,%edi
  801bf9:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801bfc:	75 c2                	jne    801bc0 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801bfe:	8b 45 10             	mov    0x10(%ebp),%eax
  801c01:	eb 05                	jmp    801c08 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c03:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c08:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c0b:	5b                   	pop    %ebx
  801c0c:	5e                   	pop    %esi
  801c0d:	5f                   	pop    %edi
  801c0e:	5d                   	pop    %ebp
  801c0f:	c3                   	ret    

00801c10 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c10:	55                   	push   %ebp
  801c11:	89 e5                	mov    %esp,%ebp
  801c13:	57                   	push   %edi
  801c14:	56                   	push   %esi
  801c15:	53                   	push   %ebx
  801c16:	83 ec 18             	sub    $0x18,%esp
  801c19:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c1c:	57                   	push   %edi
  801c1d:	e8 ff f1 ff ff       	call   800e21 <fd2data>
  801c22:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c24:	83 c4 10             	add    $0x10,%esp
  801c27:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c2c:	eb 3d                	jmp    801c6b <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c2e:	85 db                	test   %ebx,%ebx
  801c30:	74 04                	je     801c36 <devpipe_read+0x26>
				return i;
  801c32:	89 d8                	mov    %ebx,%eax
  801c34:	eb 44                	jmp    801c7a <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c36:	89 f2                	mov    %esi,%edx
  801c38:	89 f8                	mov    %edi,%eax
  801c3a:	e8 e5 fe ff ff       	call   801b24 <_pipeisclosed>
  801c3f:	85 c0                	test   %eax,%eax
  801c41:	75 32                	jne    801c75 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c43:	e8 24 ef ff ff       	call   800b6c <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c48:	8b 06                	mov    (%esi),%eax
  801c4a:	3b 46 04             	cmp    0x4(%esi),%eax
  801c4d:	74 df                	je     801c2e <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c4f:	99                   	cltd   
  801c50:	c1 ea 1b             	shr    $0x1b,%edx
  801c53:	01 d0                	add    %edx,%eax
  801c55:	83 e0 1f             	and    $0x1f,%eax
  801c58:	29 d0                	sub    %edx,%eax
  801c5a:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c62:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801c65:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c68:	83 c3 01             	add    $0x1,%ebx
  801c6b:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c6e:	75 d8                	jne    801c48 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c70:	8b 45 10             	mov    0x10(%ebp),%eax
  801c73:	eb 05                	jmp    801c7a <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c75:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c7d:	5b                   	pop    %ebx
  801c7e:	5e                   	pop    %esi
  801c7f:	5f                   	pop    %edi
  801c80:	5d                   	pop    %ebp
  801c81:	c3                   	ret    

00801c82 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c82:	55                   	push   %ebp
  801c83:	89 e5                	mov    %esp,%ebp
  801c85:	56                   	push   %esi
  801c86:	53                   	push   %ebx
  801c87:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c8a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c8d:	50                   	push   %eax
  801c8e:	e8 a5 f1 ff ff       	call   800e38 <fd_alloc>
  801c93:	83 c4 10             	add    $0x10,%esp
  801c96:	89 c2                	mov    %eax,%edx
  801c98:	85 c0                	test   %eax,%eax
  801c9a:	0f 88 2c 01 00 00    	js     801dcc <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ca0:	83 ec 04             	sub    $0x4,%esp
  801ca3:	68 07 04 00 00       	push   $0x407
  801ca8:	ff 75 f4             	pushl  -0xc(%ebp)
  801cab:	6a 00                	push   $0x0
  801cad:	e8 d9 ee ff ff       	call   800b8b <sys_page_alloc>
  801cb2:	83 c4 10             	add    $0x10,%esp
  801cb5:	89 c2                	mov    %eax,%edx
  801cb7:	85 c0                	test   %eax,%eax
  801cb9:	0f 88 0d 01 00 00    	js     801dcc <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801cbf:	83 ec 0c             	sub    $0xc,%esp
  801cc2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801cc5:	50                   	push   %eax
  801cc6:	e8 6d f1 ff ff       	call   800e38 <fd_alloc>
  801ccb:	89 c3                	mov    %eax,%ebx
  801ccd:	83 c4 10             	add    $0x10,%esp
  801cd0:	85 c0                	test   %eax,%eax
  801cd2:	0f 88 e2 00 00 00    	js     801dba <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cd8:	83 ec 04             	sub    $0x4,%esp
  801cdb:	68 07 04 00 00       	push   $0x407
  801ce0:	ff 75 f0             	pushl  -0x10(%ebp)
  801ce3:	6a 00                	push   $0x0
  801ce5:	e8 a1 ee ff ff       	call   800b8b <sys_page_alloc>
  801cea:	89 c3                	mov    %eax,%ebx
  801cec:	83 c4 10             	add    $0x10,%esp
  801cef:	85 c0                	test   %eax,%eax
  801cf1:	0f 88 c3 00 00 00    	js     801dba <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801cf7:	83 ec 0c             	sub    $0xc,%esp
  801cfa:	ff 75 f4             	pushl  -0xc(%ebp)
  801cfd:	e8 1f f1 ff ff       	call   800e21 <fd2data>
  801d02:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d04:	83 c4 0c             	add    $0xc,%esp
  801d07:	68 07 04 00 00       	push   $0x407
  801d0c:	50                   	push   %eax
  801d0d:	6a 00                	push   $0x0
  801d0f:	e8 77 ee ff ff       	call   800b8b <sys_page_alloc>
  801d14:	89 c3                	mov    %eax,%ebx
  801d16:	83 c4 10             	add    $0x10,%esp
  801d19:	85 c0                	test   %eax,%eax
  801d1b:	0f 88 89 00 00 00    	js     801daa <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d21:	83 ec 0c             	sub    $0xc,%esp
  801d24:	ff 75 f0             	pushl  -0x10(%ebp)
  801d27:	e8 f5 f0 ff ff       	call   800e21 <fd2data>
  801d2c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d33:	50                   	push   %eax
  801d34:	6a 00                	push   $0x0
  801d36:	56                   	push   %esi
  801d37:	6a 00                	push   $0x0
  801d39:	e8 90 ee ff ff       	call   800bce <sys_page_map>
  801d3e:	89 c3                	mov    %eax,%ebx
  801d40:	83 c4 20             	add    $0x20,%esp
  801d43:	85 c0                	test   %eax,%eax
  801d45:	78 55                	js     801d9c <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d47:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d50:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d52:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d55:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d5c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d62:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d65:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d67:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d6a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d71:	83 ec 0c             	sub    $0xc,%esp
  801d74:	ff 75 f4             	pushl  -0xc(%ebp)
  801d77:	e8 95 f0 ff ff       	call   800e11 <fd2num>
  801d7c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d7f:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d81:	83 c4 04             	add    $0x4,%esp
  801d84:	ff 75 f0             	pushl  -0x10(%ebp)
  801d87:	e8 85 f0 ff ff       	call   800e11 <fd2num>
  801d8c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d8f:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d92:	83 c4 10             	add    $0x10,%esp
  801d95:	ba 00 00 00 00       	mov    $0x0,%edx
  801d9a:	eb 30                	jmp    801dcc <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d9c:	83 ec 08             	sub    $0x8,%esp
  801d9f:	56                   	push   %esi
  801da0:	6a 00                	push   $0x0
  801da2:	e8 69 ee ff ff       	call   800c10 <sys_page_unmap>
  801da7:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801daa:	83 ec 08             	sub    $0x8,%esp
  801dad:	ff 75 f0             	pushl  -0x10(%ebp)
  801db0:	6a 00                	push   $0x0
  801db2:	e8 59 ee ff ff       	call   800c10 <sys_page_unmap>
  801db7:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801dba:	83 ec 08             	sub    $0x8,%esp
  801dbd:	ff 75 f4             	pushl  -0xc(%ebp)
  801dc0:	6a 00                	push   $0x0
  801dc2:	e8 49 ee ff ff       	call   800c10 <sys_page_unmap>
  801dc7:	83 c4 10             	add    $0x10,%esp
  801dca:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801dcc:	89 d0                	mov    %edx,%eax
  801dce:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dd1:	5b                   	pop    %ebx
  801dd2:	5e                   	pop    %esi
  801dd3:	5d                   	pop    %ebp
  801dd4:	c3                   	ret    

00801dd5 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801dd5:	55                   	push   %ebp
  801dd6:	89 e5                	mov    %esp,%ebp
  801dd8:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ddb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dde:	50                   	push   %eax
  801ddf:	ff 75 08             	pushl  0x8(%ebp)
  801de2:	e8 a0 f0 ff ff       	call   800e87 <fd_lookup>
  801de7:	83 c4 10             	add    $0x10,%esp
  801dea:	85 c0                	test   %eax,%eax
  801dec:	78 18                	js     801e06 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801dee:	83 ec 0c             	sub    $0xc,%esp
  801df1:	ff 75 f4             	pushl  -0xc(%ebp)
  801df4:	e8 28 f0 ff ff       	call   800e21 <fd2data>
	return _pipeisclosed(fd, p);
  801df9:	89 c2                	mov    %eax,%edx
  801dfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dfe:	e8 21 fd ff ff       	call   801b24 <_pipeisclosed>
  801e03:	83 c4 10             	add    $0x10,%esp
}
  801e06:	c9                   	leave  
  801e07:	c3                   	ret    

00801e08 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e08:	55                   	push   %ebp
  801e09:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e0b:	b8 00 00 00 00       	mov    $0x0,%eax
  801e10:	5d                   	pop    %ebp
  801e11:	c3                   	ret    

00801e12 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e12:	55                   	push   %ebp
  801e13:	89 e5                	mov    %esp,%ebp
  801e15:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e18:	68 57 28 80 00       	push   $0x802857
  801e1d:	ff 75 0c             	pushl  0xc(%ebp)
  801e20:	e8 63 e9 ff ff       	call   800788 <strcpy>
	return 0;
}
  801e25:	b8 00 00 00 00       	mov    $0x0,%eax
  801e2a:	c9                   	leave  
  801e2b:	c3                   	ret    

00801e2c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e2c:	55                   	push   %ebp
  801e2d:	89 e5                	mov    %esp,%ebp
  801e2f:	57                   	push   %edi
  801e30:	56                   	push   %esi
  801e31:	53                   	push   %ebx
  801e32:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e38:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e3d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e43:	eb 2d                	jmp    801e72 <devcons_write+0x46>
		m = n - tot;
  801e45:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e48:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801e4a:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e4d:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e52:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e55:	83 ec 04             	sub    $0x4,%esp
  801e58:	53                   	push   %ebx
  801e59:	03 45 0c             	add    0xc(%ebp),%eax
  801e5c:	50                   	push   %eax
  801e5d:	57                   	push   %edi
  801e5e:	e8 b7 ea ff ff       	call   80091a <memmove>
		sys_cputs(buf, m);
  801e63:	83 c4 08             	add    $0x8,%esp
  801e66:	53                   	push   %ebx
  801e67:	57                   	push   %edi
  801e68:	e8 62 ec ff ff       	call   800acf <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e6d:	01 de                	add    %ebx,%esi
  801e6f:	83 c4 10             	add    $0x10,%esp
  801e72:	89 f0                	mov    %esi,%eax
  801e74:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e77:	72 cc                	jb     801e45 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e79:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e7c:	5b                   	pop    %ebx
  801e7d:	5e                   	pop    %esi
  801e7e:	5f                   	pop    %edi
  801e7f:	5d                   	pop    %ebp
  801e80:	c3                   	ret    

00801e81 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e81:	55                   	push   %ebp
  801e82:	89 e5                	mov    %esp,%ebp
  801e84:	83 ec 08             	sub    $0x8,%esp
  801e87:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801e8c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e90:	74 2a                	je     801ebc <devcons_read+0x3b>
  801e92:	eb 05                	jmp    801e99 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e94:	e8 d3 ec ff ff       	call   800b6c <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e99:	e8 4f ec ff ff       	call   800aed <sys_cgetc>
  801e9e:	85 c0                	test   %eax,%eax
  801ea0:	74 f2                	je     801e94 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801ea2:	85 c0                	test   %eax,%eax
  801ea4:	78 16                	js     801ebc <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ea6:	83 f8 04             	cmp    $0x4,%eax
  801ea9:	74 0c                	je     801eb7 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801eab:	8b 55 0c             	mov    0xc(%ebp),%edx
  801eae:	88 02                	mov    %al,(%edx)
	return 1;
  801eb0:	b8 01 00 00 00       	mov    $0x1,%eax
  801eb5:	eb 05                	jmp    801ebc <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801eb7:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801ebc:	c9                   	leave  
  801ebd:	c3                   	ret    

00801ebe <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801ebe:	55                   	push   %ebp
  801ebf:	89 e5                	mov    %esp,%ebp
  801ec1:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801ec4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ec7:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801eca:	6a 01                	push   $0x1
  801ecc:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ecf:	50                   	push   %eax
  801ed0:	e8 fa eb ff ff       	call   800acf <sys_cputs>
}
  801ed5:	83 c4 10             	add    $0x10,%esp
  801ed8:	c9                   	leave  
  801ed9:	c3                   	ret    

00801eda <getchar>:

int
getchar(void)
{
  801eda:	55                   	push   %ebp
  801edb:	89 e5                	mov    %esp,%ebp
  801edd:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801ee0:	6a 01                	push   $0x1
  801ee2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ee5:	50                   	push   %eax
  801ee6:	6a 00                	push   $0x0
  801ee8:	e8 00 f2 ff ff       	call   8010ed <read>
	if (r < 0)
  801eed:	83 c4 10             	add    $0x10,%esp
  801ef0:	85 c0                	test   %eax,%eax
  801ef2:	78 0f                	js     801f03 <getchar+0x29>
		return r;
	if (r < 1)
  801ef4:	85 c0                	test   %eax,%eax
  801ef6:	7e 06                	jle    801efe <getchar+0x24>
		return -E_EOF;
	return c;
  801ef8:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801efc:	eb 05                	jmp    801f03 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801efe:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f03:	c9                   	leave  
  801f04:	c3                   	ret    

00801f05 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f05:	55                   	push   %ebp
  801f06:	89 e5                	mov    %esp,%ebp
  801f08:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f0b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f0e:	50                   	push   %eax
  801f0f:	ff 75 08             	pushl  0x8(%ebp)
  801f12:	e8 70 ef ff ff       	call   800e87 <fd_lookup>
  801f17:	83 c4 10             	add    $0x10,%esp
  801f1a:	85 c0                	test   %eax,%eax
  801f1c:	78 11                	js     801f2f <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f21:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801f27:	39 10                	cmp    %edx,(%eax)
  801f29:	0f 94 c0             	sete   %al
  801f2c:	0f b6 c0             	movzbl %al,%eax
}
  801f2f:	c9                   	leave  
  801f30:	c3                   	ret    

00801f31 <opencons>:

int
opencons(void)
{
  801f31:	55                   	push   %ebp
  801f32:	89 e5                	mov    %esp,%ebp
  801f34:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f37:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f3a:	50                   	push   %eax
  801f3b:	e8 f8 ee ff ff       	call   800e38 <fd_alloc>
  801f40:	83 c4 10             	add    $0x10,%esp
		return r;
  801f43:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f45:	85 c0                	test   %eax,%eax
  801f47:	78 3e                	js     801f87 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f49:	83 ec 04             	sub    $0x4,%esp
  801f4c:	68 07 04 00 00       	push   $0x407
  801f51:	ff 75 f4             	pushl  -0xc(%ebp)
  801f54:	6a 00                	push   $0x0
  801f56:	e8 30 ec ff ff       	call   800b8b <sys_page_alloc>
  801f5b:	83 c4 10             	add    $0x10,%esp
		return r;
  801f5e:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f60:	85 c0                	test   %eax,%eax
  801f62:	78 23                	js     801f87 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f64:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801f6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f6d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f72:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f79:	83 ec 0c             	sub    $0xc,%esp
  801f7c:	50                   	push   %eax
  801f7d:	e8 8f ee ff ff       	call   800e11 <fd2num>
  801f82:	89 c2                	mov    %eax,%edx
  801f84:	83 c4 10             	add    $0x10,%esp
}
  801f87:	89 d0                	mov    %edx,%eax
  801f89:	c9                   	leave  
  801f8a:	c3                   	ret    

00801f8b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f8b:	55                   	push   %ebp
  801f8c:	89 e5                	mov    %esp,%ebp
  801f8e:	56                   	push   %esi
  801f8f:	53                   	push   %ebx
  801f90:	8b 75 08             	mov    0x8(%ebp),%esi
  801f93:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f96:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  801f99:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801f9b:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801fa0:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  801fa3:	83 ec 0c             	sub    $0xc,%esp
  801fa6:	50                   	push   %eax
  801fa7:	e8 8f ed ff ff       	call   800d3b <sys_ipc_recv>

	if (r < 0) {
  801fac:	83 c4 10             	add    $0x10,%esp
  801faf:	85 c0                	test   %eax,%eax
  801fb1:	79 16                	jns    801fc9 <ipc_recv+0x3e>
		if (from_env_store)
  801fb3:	85 f6                	test   %esi,%esi
  801fb5:	74 06                	je     801fbd <ipc_recv+0x32>
			*from_env_store = 0;
  801fb7:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  801fbd:	85 db                	test   %ebx,%ebx
  801fbf:	74 2c                	je     801fed <ipc_recv+0x62>
			*perm_store = 0;
  801fc1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801fc7:	eb 24                	jmp    801fed <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  801fc9:	85 f6                	test   %esi,%esi
  801fcb:	74 0a                	je     801fd7 <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  801fcd:	a1 08 40 80 00       	mov    0x804008,%eax
  801fd2:	8b 40 74             	mov    0x74(%eax),%eax
  801fd5:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  801fd7:	85 db                	test   %ebx,%ebx
  801fd9:	74 0a                	je     801fe5 <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  801fdb:	a1 08 40 80 00       	mov    0x804008,%eax
  801fe0:	8b 40 78             	mov    0x78(%eax),%eax
  801fe3:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  801fe5:	a1 08 40 80 00       	mov    0x804008,%eax
  801fea:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  801fed:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ff0:	5b                   	pop    %ebx
  801ff1:	5e                   	pop    %esi
  801ff2:	5d                   	pop    %ebp
  801ff3:	c3                   	ret    

00801ff4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ff4:	55                   	push   %ebp
  801ff5:	89 e5                	mov    %esp,%ebp
  801ff7:	57                   	push   %edi
  801ff8:	56                   	push   %esi
  801ff9:	53                   	push   %ebx
  801ffa:	83 ec 0c             	sub    $0xc,%esp
  801ffd:	8b 7d 08             	mov    0x8(%ebp),%edi
  802000:	8b 75 0c             	mov    0xc(%ebp),%esi
  802003:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  802006:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  802008:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  80200d:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  802010:	ff 75 14             	pushl  0x14(%ebp)
  802013:	53                   	push   %ebx
  802014:	56                   	push   %esi
  802015:	57                   	push   %edi
  802016:	e8 fd ec ff ff       	call   800d18 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  80201b:	83 c4 10             	add    $0x10,%esp
  80201e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802021:	75 07                	jne    80202a <ipc_send+0x36>
			sys_yield();
  802023:	e8 44 eb ff ff       	call   800b6c <sys_yield>
  802028:	eb e6                	jmp    802010 <ipc_send+0x1c>
		} else if (r < 0) {
  80202a:	85 c0                	test   %eax,%eax
  80202c:	79 12                	jns    802040 <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  80202e:	50                   	push   %eax
  80202f:	68 63 28 80 00       	push   $0x802863
  802034:	6a 51                	push   $0x51
  802036:	68 70 28 80 00       	push   $0x802870
  80203b:	e8 ea e0 ff ff       	call   80012a <_panic>
		}
	}
}
  802040:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802043:	5b                   	pop    %ebx
  802044:	5e                   	pop    %esi
  802045:	5f                   	pop    %edi
  802046:	5d                   	pop    %ebp
  802047:	c3                   	ret    

00802048 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802048:	55                   	push   %ebp
  802049:	89 e5                	mov    %esp,%ebp
  80204b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80204e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802053:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802056:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80205c:	8b 52 50             	mov    0x50(%edx),%edx
  80205f:	39 ca                	cmp    %ecx,%edx
  802061:	75 0d                	jne    802070 <ipc_find_env+0x28>
			return envs[i].env_id;
  802063:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802066:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80206b:	8b 40 48             	mov    0x48(%eax),%eax
  80206e:	eb 0f                	jmp    80207f <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802070:	83 c0 01             	add    $0x1,%eax
  802073:	3d 00 04 00 00       	cmp    $0x400,%eax
  802078:	75 d9                	jne    802053 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80207a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80207f:	5d                   	pop    %ebp
  802080:	c3                   	ret    

00802081 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802081:	55                   	push   %ebp
  802082:	89 e5                	mov    %esp,%ebp
  802084:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802087:	89 d0                	mov    %edx,%eax
  802089:	c1 e8 16             	shr    $0x16,%eax
  80208c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802093:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802098:	f6 c1 01             	test   $0x1,%cl
  80209b:	74 1d                	je     8020ba <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80209d:	c1 ea 0c             	shr    $0xc,%edx
  8020a0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8020a7:	f6 c2 01             	test   $0x1,%dl
  8020aa:	74 0e                	je     8020ba <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020ac:	c1 ea 0c             	shr    $0xc,%edx
  8020af:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8020b6:	ef 
  8020b7:	0f b7 c0             	movzwl %ax,%eax
}
  8020ba:	5d                   	pop    %ebp
  8020bb:	c3                   	ret    
  8020bc:	66 90                	xchg   %ax,%ax
  8020be:	66 90                	xchg   %ax,%ax

008020c0 <__udivdi3>:
  8020c0:	55                   	push   %ebp
  8020c1:	57                   	push   %edi
  8020c2:	56                   	push   %esi
  8020c3:	53                   	push   %ebx
  8020c4:	83 ec 1c             	sub    $0x1c,%esp
  8020c7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8020cb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8020cf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8020d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020d7:	85 f6                	test   %esi,%esi
  8020d9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020dd:	89 ca                	mov    %ecx,%edx
  8020df:	89 f8                	mov    %edi,%eax
  8020e1:	75 3d                	jne    802120 <__udivdi3+0x60>
  8020e3:	39 cf                	cmp    %ecx,%edi
  8020e5:	0f 87 c5 00 00 00    	ja     8021b0 <__udivdi3+0xf0>
  8020eb:	85 ff                	test   %edi,%edi
  8020ed:	89 fd                	mov    %edi,%ebp
  8020ef:	75 0b                	jne    8020fc <__udivdi3+0x3c>
  8020f1:	b8 01 00 00 00       	mov    $0x1,%eax
  8020f6:	31 d2                	xor    %edx,%edx
  8020f8:	f7 f7                	div    %edi
  8020fa:	89 c5                	mov    %eax,%ebp
  8020fc:	89 c8                	mov    %ecx,%eax
  8020fe:	31 d2                	xor    %edx,%edx
  802100:	f7 f5                	div    %ebp
  802102:	89 c1                	mov    %eax,%ecx
  802104:	89 d8                	mov    %ebx,%eax
  802106:	89 cf                	mov    %ecx,%edi
  802108:	f7 f5                	div    %ebp
  80210a:	89 c3                	mov    %eax,%ebx
  80210c:	89 d8                	mov    %ebx,%eax
  80210e:	89 fa                	mov    %edi,%edx
  802110:	83 c4 1c             	add    $0x1c,%esp
  802113:	5b                   	pop    %ebx
  802114:	5e                   	pop    %esi
  802115:	5f                   	pop    %edi
  802116:	5d                   	pop    %ebp
  802117:	c3                   	ret    
  802118:	90                   	nop
  802119:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802120:	39 ce                	cmp    %ecx,%esi
  802122:	77 74                	ja     802198 <__udivdi3+0xd8>
  802124:	0f bd fe             	bsr    %esi,%edi
  802127:	83 f7 1f             	xor    $0x1f,%edi
  80212a:	0f 84 98 00 00 00    	je     8021c8 <__udivdi3+0x108>
  802130:	bb 20 00 00 00       	mov    $0x20,%ebx
  802135:	89 f9                	mov    %edi,%ecx
  802137:	89 c5                	mov    %eax,%ebp
  802139:	29 fb                	sub    %edi,%ebx
  80213b:	d3 e6                	shl    %cl,%esi
  80213d:	89 d9                	mov    %ebx,%ecx
  80213f:	d3 ed                	shr    %cl,%ebp
  802141:	89 f9                	mov    %edi,%ecx
  802143:	d3 e0                	shl    %cl,%eax
  802145:	09 ee                	or     %ebp,%esi
  802147:	89 d9                	mov    %ebx,%ecx
  802149:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80214d:	89 d5                	mov    %edx,%ebp
  80214f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802153:	d3 ed                	shr    %cl,%ebp
  802155:	89 f9                	mov    %edi,%ecx
  802157:	d3 e2                	shl    %cl,%edx
  802159:	89 d9                	mov    %ebx,%ecx
  80215b:	d3 e8                	shr    %cl,%eax
  80215d:	09 c2                	or     %eax,%edx
  80215f:	89 d0                	mov    %edx,%eax
  802161:	89 ea                	mov    %ebp,%edx
  802163:	f7 f6                	div    %esi
  802165:	89 d5                	mov    %edx,%ebp
  802167:	89 c3                	mov    %eax,%ebx
  802169:	f7 64 24 0c          	mull   0xc(%esp)
  80216d:	39 d5                	cmp    %edx,%ebp
  80216f:	72 10                	jb     802181 <__udivdi3+0xc1>
  802171:	8b 74 24 08          	mov    0x8(%esp),%esi
  802175:	89 f9                	mov    %edi,%ecx
  802177:	d3 e6                	shl    %cl,%esi
  802179:	39 c6                	cmp    %eax,%esi
  80217b:	73 07                	jae    802184 <__udivdi3+0xc4>
  80217d:	39 d5                	cmp    %edx,%ebp
  80217f:	75 03                	jne    802184 <__udivdi3+0xc4>
  802181:	83 eb 01             	sub    $0x1,%ebx
  802184:	31 ff                	xor    %edi,%edi
  802186:	89 d8                	mov    %ebx,%eax
  802188:	89 fa                	mov    %edi,%edx
  80218a:	83 c4 1c             	add    $0x1c,%esp
  80218d:	5b                   	pop    %ebx
  80218e:	5e                   	pop    %esi
  80218f:	5f                   	pop    %edi
  802190:	5d                   	pop    %ebp
  802191:	c3                   	ret    
  802192:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802198:	31 ff                	xor    %edi,%edi
  80219a:	31 db                	xor    %ebx,%ebx
  80219c:	89 d8                	mov    %ebx,%eax
  80219e:	89 fa                	mov    %edi,%edx
  8021a0:	83 c4 1c             	add    $0x1c,%esp
  8021a3:	5b                   	pop    %ebx
  8021a4:	5e                   	pop    %esi
  8021a5:	5f                   	pop    %edi
  8021a6:	5d                   	pop    %ebp
  8021a7:	c3                   	ret    
  8021a8:	90                   	nop
  8021a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021b0:	89 d8                	mov    %ebx,%eax
  8021b2:	f7 f7                	div    %edi
  8021b4:	31 ff                	xor    %edi,%edi
  8021b6:	89 c3                	mov    %eax,%ebx
  8021b8:	89 d8                	mov    %ebx,%eax
  8021ba:	89 fa                	mov    %edi,%edx
  8021bc:	83 c4 1c             	add    $0x1c,%esp
  8021bf:	5b                   	pop    %ebx
  8021c0:	5e                   	pop    %esi
  8021c1:	5f                   	pop    %edi
  8021c2:	5d                   	pop    %ebp
  8021c3:	c3                   	ret    
  8021c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021c8:	39 ce                	cmp    %ecx,%esi
  8021ca:	72 0c                	jb     8021d8 <__udivdi3+0x118>
  8021cc:	31 db                	xor    %ebx,%ebx
  8021ce:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8021d2:	0f 87 34 ff ff ff    	ja     80210c <__udivdi3+0x4c>
  8021d8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8021dd:	e9 2a ff ff ff       	jmp    80210c <__udivdi3+0x4c>
  8021e2:	66 90                	xchg   %ax,%ax
  8021e4:	66 90                	xchg   %ax,%ax
  8021e6:	66 90                	xchg   %ax,%ax
  8021e8:	66 90                	xchg   %ax,%ax
  8021ea:	66 90                	xchg   %ax,%ax
  8021ec:	66 90                	xchg   %ax,%ax
  8021ee:	66 90                	xchg   %ax,%ax

008021f0 <__umoddi3>:
  8021f0:	55                   	push   %ebp
  8021f1:	57                   	push   %edi
  8021f2:	56                   	push   %esi
  8021f3:	53                   	push   %ebx
  8021f4:	83 ec 1c             	sub    $0x1c,%esp
  8021f7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021fb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8021ff:	8b 74 24 34          	mov    0x34(%esp),%esi
  802203:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802207:	85 d2                	test   %edx,%edx
  802209:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80220d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802211:	89 f3                	mov    %esi,%ebx
  802213:	89 3c 24             	mov    %edi,(%esp)
  802216:	89 74 24 04          	mov    %esi,0x4(%esp)
  80221a:	75 1c                	jne    802238 <__umoddi3+0x48>
  80221c:	39 f7                	cmp    %esi,%edi
  80221e:	76 50                	jbe    802270 <__umoddi3+0x80>
  802220:	89 c8                	mov    %ecx,%eax
  802222:	89 f2                	mov    %esi,%edx
  802224:	f7 f7                	div    %edi
  802226:	89 d0                	mov    %edx,%eax
  802228:	31 d2                	xor    %edx,%edx
  80222a:	83 c4 1c             	add    $0x1c,%esp
  80222d:	5b                   	pop    %ebx
  80222e:	5e                   	pop    %esi
  80222f:	5f                   	pop    %edi
  802230:	5d                   	pop    %ebp
  802231:	c3                   	ret    
  802232:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802238:	39 f2                	cmp    %esi,%edx
  80223a:	89 d0                	mov    %edx,%eax
  80223c:	77 52                	ja     802290 <__umoddi3+0xa0>
  80223e:	0f bd ea             	bsr    %edx,%ebp
  802241:	83 f5 1f             	xor    $0x1f,%ebp
  802244:	75 5a                	jne    8022a0 <__umoddi3+0xb0>
  802246:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80224a:	0f 82 e0 00 00 00    	jb     802330 <__umoddi3+0x140>
  802250:	39 0c 24             	cmp    %ecx,(%esp)
  802253:	0f 86 d7 00 00 00    	jbe    802330 <__umoddi3+0x140>
  802259:	8b 44 24 08          	mov    0x8(%esp),%eax
  80225d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802261:	83 c4 1c             	add    $0x1c,%esp
  802264:	5b                   	pop    %ebx
  802265:	5e                   	pop    %esi
  802266:	5f                   	pop    %edi
  802267:	5d                   	pop    %ebp
  802268:	c3                   	ret    
  802269:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802270:	85 ff                	test   %edi,%edi
  802272:	89 fd                	mov    %edi,%ebp
  802274:	75 0b                	jne    802281 <__umoddi3+0x91>
  802276:	b8 01 00 00 00       	mov    $0x1,%eax
  80227b:	31 d2                	xor    %edx,%edx
  80227d:	f7 f7                	div    %edi
  80227f:	89 c5                	mov    %eax,%ebp
  802281:	89 f0                	mov    %esi,%eax
  802283:	31 d2                	xor    %edx,%edx
  802285:	f7 f5                	div    %ebp
  802287:	89 c8                	mov    %ecx,%eax
  802289:	f7 f5                	div    %ebp
  80228b:	89 d0                	mov    %edx,%eax
  80228d:	eb 99                	jmp    802228 <__umoddi3+0x38>
  80228f:	90                   	nop
  802290:	89 c8                	mov    %ecx,%eax
  802292:	89 f2                	mov    %esi,%edx
  802294:	83 c4 1c             	add    $0x1c,%esp
  802297:	5b                   	pop    %ebx
  802298:	5e                   	pop    %esi
  802299:	5f                   	pop    %edi
  80229a:	5d                   	pop    %ebp
  80229b:	c3                   	ret    
  80229c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022a0:	8b 34 24             	mov    (%esp),%esi
  8022a3:	bf 20 00 00 00       	mov    $0x20,%edi
  8022a8:	89 e9                	mov    %ebp,%ecx
  8022aa:	29 ef                	sub    %ebp,%edi
  8022ac:	d3 e0                	shl    %cl,%eax
  8022ae:	89 f9                	mov    %edi,%ecx
  8022b0:	89 f2                	mov    %esi,%edx
  8022b2:	d3 ea                	shr    %cl,%edx
  8022b4:	89 e9                	mov    %ebp,%ecx
  8022b6:	09 c2                	or     %eax,%edx
  8022b8:	89 d8                	mov    %ebx,%eax
  8022ba:	89 14 24             	mov    %edx,(%esp)
  8022bd:	89 f2                	mov    %esi,%edx
  8022bf:	d3 e2                	shl    %cl,%edx
  8022c1:	89 f9                	mov    %edi,%ecx
  8022c3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8022c7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8022cb:	d3 e8                	shr    %cl,%eax
  8022cd:	89 e9                	mov    %ebp,%ecx
  8022cf:	89 c6                	mov    %eax,%esi
  8022d1:	d3 e3                	shl    %cl,%ebx
  8022d3:	89 f9                	mov    %edi,%ecx
  8022d5:	89 d0                	mov    %edx,%eax
  8022d7:	d3 e8                	shr    %cl,%eax
  8022d9:	89 e9                	mov    %ebp,%ecx
  8022db:	09 d8                	or     %ebx,%eax
  8022dd:	89 d3                	mov    %edx,%ebx
  8022df:	89 f2                	mov    %esi,%edx
  8022e1:	f7 34 24             	divl   (%esp)
  8022e4:	89 d6                	mov    %edx,%esi
  8022e6:	d3 e3                	shl    %cl,%ebx
  8022e8:	f7 64 24 04          	mull   0x4(%esp)
  8022ec:	39 d6                	cmp    %edx,%esi
  8022ee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022f2:	89 d1                	mov    %edx,%ecx
  8022f4:	89 c3                	mov    %eax,%ebx
  8022f6:	72 08                	jb     802300 <__umoddi3+0x110>
  8022f8:	75 11                	jne    80230b <__umoddi3+0x11b>
  8022fa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8022fe:	73 0b                	jae    80230b <__umoddi3+0x11b>
  802300:	2b 44 24 04          	sub    0x4(%esp),%eax
  802304:	1b 14 24             	sbb    (%esp),%edx
  802307:	89 d1                	mov    %edx,%ecx
  802309:	89 c3                	mov    %eax,%ebx
  80230b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80230f:	29 da                	sub    %ebx,%edx
  802311:	19 ce                	sbb    %ecx,%esi
  802313:	89 f9                	mov    %edi,%ecx
  802315:	89 f0                	mov    %esi,%eax
  802317:	d3 e0                	shl    %cl,%eax
  802319:	89 e9                	mov    %ebp,%ecx
  80231b:	d3 ea                	shr    %cl,%edx
  80231d:	89 e9                	mov    %ebp,%ecx
  80231f:	d3 ee                	shr    %cl,%esi
  802321:	09 d0                	or     %edx,%eax
  802323:	89 f2                	mov    %esi,%edx
  802325:	83 c4 1c             	add    $0x1c,%esp
  802328:	5b                   	pop    %ebx
  802329:	5e                   	pop    %esi
  80232a:	5f                   	pop    %edi
  80232b:	5d                   	pop    %ebp
  80232c:	c3                   	ret    
  80232d:	8d 76 00             	lea    0x0(%esi),%esi
  802330:	29 f9                	sub    %edi,%ecx
  802332:	19 d6                	sbb    %edx,%esi
  802334:	89 74 24 04          	mov    %esi,0x4(%esp)
  802338:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80233c:	e9 18 ff ff ff       	jmp    802259 <__umoddi3+0x69>
