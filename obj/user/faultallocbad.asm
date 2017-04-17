
obj/user/faultallocbad.debug:     file format elf32-i386


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
  80002c:	e8 84 00 00 00       	call   8000b5 <libmain>
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
  800040:	68 40 23 80 00       	push   $0x802340
  800045:	e8 a4 01 00 00       	call   8001ee <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 18 0b 00 00       	call   800b76 <sys_page_alloc>
  80005e:	83 c4 10             	add    $0x10,%esp
  800061:	85 c0                	test   %eax,%eax
  800063:	79 16                	jns    80007b <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800065:	83 ec 0c             	sub    $0xc,%esp
  800068:	50                   	push   %eax
  800069:	53                   	push   %ebx
  80006a:	68 60 23 80 00       	push   $0x802360
  80006f:	6a 0f                	push   $0xf
  800071:	68 4a 23 80 00       	push   $0x80234a
  800076:	e8 9a 00 00 00       	call   800115 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  80007b:	53                   	push   %ebx
  80007c:	68 8c 23 80 00       	push   $0x80238c
  800081:	6a 64                	push   $0x64
  800083:	53                   	push   %ebx
  800084:	e8 97 06 00 00       	call   800720 <snprintf>
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
  80009c:	e8 e5 0c 00 00       	call   800d86 <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	6a 04                	push   $0x4
  8000a6:	68 ef be ad de       	push   $0xdeadbeef
  8000ab:	e8 0a 0a 00 00       	call   800aba <sys_cputs>
}
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	c9                   	leave  
  8000b4:	c3                   	ret    

008000b5 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
  8000ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000bd:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000c0:	e8 73 0a 00 00       	call   800b38 <sys_getenvid>
  8000c5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ca:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000cd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d2:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000d7:	85 db                	test   %ebx,%ebx
  8000d9:	7e 07                	jle    8000e2 <libmain+0x2d>
		binaryname = argv[0];
  8000db:	8b 06                	mov    (%esi),%eax
  8000dd:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000e2:	83 ec 08             	sub    $0x8,%esp
  8000e5:	56                   	push   %esi
  8000e6:	53                   	push   %ebx
  8000e7:	e8 a5 ff ff ff       	call   800091 <umain>

	// exit gracefully
	exit();
  8000ec:	e8 0a 00 00 00       	call   8000fb <exit>
}
  8000f1:	83 c4 10             	add    $0x10,%esp
  8000f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000f7:	5b                   	pop    %ebx
  8000f8:	5e                   	pop    %esi
  8000f9:	5d                   	pop    %ebp
  8000fa:	c3                   	ret    

008000fb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000fb:	55                   	push   %ebp
  8000fc:	89 e5                	mov    %esp,%ebp
  8000fe:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800101:	e8 c1 0e 00 00       	call   800fc7 <close_all>
	sys_env_destroy(0);
  800106:	83 ec 0c             	sub    $0xc,%esp
  800109:	6a 00                	push   $0x0
  80010b:	e8 e7 09 00 00       	call   800af7 <sys_env_destroy>
}
  800110:	83 c4 10             	add    $0x10,%esp
  800113:	c9                   	leave  
  800114:	c3                   	ret    

00800115 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800115:	55                   	push   %ebp
  800116:	89 e5                	mov    %esp,%ebp
  800118:	56                   	push   %esi
  800119:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80011a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80011d:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800123:	e8 10 0a 00 00       	call   800b38 <sys_getenvid>
  800128:	83 ec 0c             	sub    $0xc,%esp
  80012b:	ff 75 0c             	pushl  0xc(%ebp)
  80012e:	ff 75 08             	pushl  0x8(%ebp)
  800131:	56                   	push   %esi
  800132:	50                   	push   %eax
  800133:	68 b8 23 80 00       	push   $0x8023b8
  800138:	e8 b1 00 00 00       	call   8001ee <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80013d:	83 c4 18             	add    $0x18,%esp
  800140:	53                   	push   %ebx
  800141:	ff 75 10             	pushl  0x10(%ebp)
  800144:	e8 54 00 00 00       	call   80019d <vcprintf>
	cprintf("\n");
  800149:	c7 04 24 30 28 80 00 	movl   $0x802830,(%esp)
  800150:	e8 99 00 00 00       	call   8001ee <cprintf>
  800155:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800158:	cc                   	int3   
  800159:	eb fd                	jmp    800158 <_panic+0x43>

0080015b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80015b:	55                   	push   %ebp
  80015c:	89 e5                	mov    %esp,%ebp
  80015e:	53                   	push   %ebx
  80015f:	83 ec 04             	sub    $0x4,%esp
  800162:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800165:	8b 13                	mov    (%ebx),%edx
  800167:	8d 42 01             	lea    0x1(%edx),%eax
  80016a:	89 03                	mov    %eax,(%ebx)
  80016c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80016f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800173:	3d ff 00 00 00       	cmp    $0xff,%eax
  800178:	75 1a                	jne    800194 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80017a:	83 ec 08             	sub    $0x8,%esp
  80017d:	68 ff 00 00 00       	push   $0xff
  800182:	8d 43 08             	lea    0x8(%ebx),%eax
  800185:	50                   	push   %eax
  800186:	e8 2f 09 00 00       	call   800aba <sys_cputs>
		b->idx = 0;
  80018b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800191:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800194:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800198:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80019b:	c9                   	leave  
  80019c:	c3                   	ret    

0080019d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80019d:	55                   	push   %ebp
  80019e:	89 e5                	mov    %esp,%ebp
  8001a0:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001a6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ad:	00 00 00 
	b.cnt = 0;
  8001b0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001b7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001ba:	ff 75 0c             	pushl  0xc(%ebp)
  8001bd:	ff 75 08             	pushl  0x8(%ebp)
  8001c0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001c6:	50                   	push   %eax
  8001c7:	68 5b 01 80 00       	push   $0x80015b
  8001cc:	e8 54 01 00 00       	call   800325 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001d1:	83 c4 08             	add    $0x8,%esp
  8001d4:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001da:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001e0:	50                   	push   %eax
  8001e1:	e8 d4 08 00 00       	call   800aba <sys_cputs>

	return b.cnt;
}
  8001e6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ec:	c9                   	leave  
  8001ed:	c3                   	ret    

008001ee <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001ee:	55                   	push   %ebp
  8001ef:	89 e5                	mov    %esp,%ebp
  8001f1:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001f4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001f7:	50                   	push   %eax
  8001f8:	ff 75 08             	pushl  0x8(%ebp)
  8001fb:	e8 9d ff ff ff       	call   80019d <vcprintf>
	va_end(ap);

	return cnt;
}
  800200:	c9                   	leave  
  800201:	c3                   	ret    

00800202 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800202:	55                   	push   %ebp
  800203:	89 e5                	mov    %esp,%ebp
  800205:	57                   	push   %edi
  800206:	56                   	push   %esi
  800207:	53                   	push   %ebx
  800208:	83 ec 1c             	sub    $0x1c,%esp
  80020b:	89 c7                	mov    %eax,%edi
  80020d:	89 d6                	mov    %edx,%esi
  80020f:	8b 45 08             	mov    0x8(%ebp),%eax
  800212:	8b 55 0c             	mov    0xc(%ebp),%edx
  800215:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800218:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80021b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80021e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800223:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800226:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800229:	39 d3                	cmp    %edx,%ebx
  80022b:	72 05                	jb     800232 <printnum+0x30>
  80022d:	39 45 10             	cmp    %eax,0x10(%ebp)
  800230:	77 45                	ja     800277 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800232:	83 ec 0c             	sub    $0xc,%esp
  800235:	ff 75 18             	pushl  0x18(%ebp)
  800238:	8b 45 14             	mov    0x14(%ebp),%eax
  80023b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80023e:	53                   	push   %ebx
  80023f:	ff 75 10             	pushl  0x10(%ebp)
  800242:	83 ec 08             	sub    $0x8,%esp
  800245:	ff 75 e4             	pushl  -0x1c(%ebp)
  800248:	ff 75 e0             	pushl  -0x20(%ebp)
  80024b:	ff 75 dc             	pushl  -0x24(%ebp)
  80024e:	ff 75 d8             	pushl  -0x28(%ebp)
  800251:	e8 5a 1e 00 00       	call   8020b0 <__udivdi3>
  800256:	83 c4 18             	add    $0x18,%esp
  800259:	52                   	push   %edx
  80025a:	50                   	push   %eax
  80025b:	89 f2                	mov    %esi,%edx
  80025d:	89 f8                	mov    %edi,%eax
  80025f:	e8 9e ff ff ff       	call   800202 <printnum>
  800264:	83 c4 20             	add    $0x20,%esp
  800267:	eb 18                	jmp    800281 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800269:	83 ec 08             	sub    $0x8,%esp
  80026c:	56                   	push   %esi
  80026d:	ff 75 18             	pushl  0x18(%ebp)
  800270:	ff d7                	call   *%edi
  800272:	83 c4 10             	add    $0x10,%esp
  800275:	eb 03                	jmp    80027a <printnum+0x78>
  800277:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80027a:	83 eb 01             	sub    $0x1,%ebx
  80027d:	85 db                	test   %ebx,%ebx
  80027f:	7f e8                	jg     800269 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800281:	83 ec 08             	sub    $0x8,%esp
  800284:	56                   	push   %esi
  800285:	83 ec 04             	sub    $0x4,%esp
  800288:	ff 75 e4             	pushl  -0x1c(%ebp)
  80028b:	ff 75 e0             	pushl  -0x20(%ebp)
  80028e:	ff 75 dc             	pushl  -0x24(%ebp)
  800291:	ff 75 d8             	pushl  -0x28(%ebp)
  800294:	e8 47 1f 00 00       	call   8021e0 <__umoddi3>
  800299:	83 c4 14             	add    $0x14,%esp
  80029c:	0f be 80 db 23 80 00 	movsbl 0x8023db(%eax),%eax
  8002a3:	50                   	push   %eax
  8002a4:	ff d7                	call   *%edi
}
  8002a6:	83 c4 10             	add    $0x10,%esp
  8002a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ac:	5b                   	pop    %ebx
  8002ad:	5e                   	pop    %esi
  8002ae:	5f                   	pop    %edi
  8002af:	5d                   	pop    %ebp
  8002b0:	c3                   	ret    

008002b1 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002b4:	83 fa 01             	cmp    $0x1,%edx
  8002b7:	7e 0e                	jle    8002c7 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002b9:	8b 10                	mov    (%eax),%edx
  8002bb:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002be:	89 08                	mov    %ecx,(%eax)
  8002c0:	8b 02                	mov    (%edx),%eax
  8002c2:	8b 52 04             	mov    0x4(%edx),%edx
  8002c5:	eb 22                	jmp    8002e9 <getuint+0x38>
	else if (lflag)
  8002c7:	85 d2                	test   %edx,%edx
  8002c9:	74 10                	je     8002db <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002cb:	8b 10                	mov    (%eax),%edx
  8002cd:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d0:	89 08                	mov    %ecx,(%eax)
  8002d2:	8b 02                	mov    (%edx),%eax
  8002d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d9:	eb 0e                	jmp    8002e9 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002db:	8b 10                	mov    (%eax),%edx
  8002dd:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e0:	89 08                	mov    %ecx,(%eax)
  8002e2:	8b 02                	mov    (%edx),%eax
  8002e4:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002e9:	5d                   	pop    %ebp
  8002ea:	c3                   	ret    

008002eb <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002eb:	55                   	push   %ebp
  8002ec:	89 e5                	mov    %esp,%ebp
  8002ee:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002f1:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002f5:	8b 10                	mov    (%eax),%edx
  8002f7:	3b 50 04             	cmp    0x4(%eax),%edx
  8002fa:	73 0a                	jae    800306 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002fc:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002ff:	89 08                	mov    %ecx,(%eax)
  800301:	8b 45 08             	mov    0x8(%ebp),%eax
  800304:	88 02                	mov    %al,(%edx)
}
  800306:	5d                   	pop    %ebp
  800307:	c3                   	ret    

00800308 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800308:	55                   	push   %ebp
  800309:	89 e5                	mov    %esp,%ebp
  80030b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80030e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800311:	50                   	push   %eax
  800312:	ff 75 10             	pushl  0x10(%ebp)
  800315:	ff 75 0c             	pushl  0xc(%ebp)
  800318:	ff 75 08             	pushl  0x8(%ebp)
  80031b:	e8 05 00 00 00       	call   800325 <vprintfmt>
	va_end(ap);
}
  800320:	83 c4 10             	add    $0x10,%esp
  800323:	c9                   	leave  
  800324:	c3                   	ret    

00800325 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800325:	55                   	push   %ebp
  800326:	89 e5                	mov    %esp,%ebp
  800328:	57                   	push   %edi
  800329:	56                   	push   %esi
  80032a:	53                   	push   %ebx
  80032b:	83 ec 2c             	sub    $0x2c,%esp
  80032e:	8b 75 08             	mov    0x8(%ebp),%esi
  800331:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800334:	8b 7d 10             	mov    0x10(%ebp),%edi
  800337:	eb 12                	jmp    80034b <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800339:	85 c0                	test   %eax,%eax
  80033b:	0f 84 89 03 00 00    	je     8006ca <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800341:	83 ec 08             	sub    $0x8,%esp
  800344:	53                   	push   %ebx
  800345:	50                   	push   %eax
  800346:	ff d6                	call   *%esi
  800348:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80034b:	83 c7 01             	add    $0x1,%edi
  80034e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800352:	83 f8 25             	cmp    $0x25,%eax
  800355:	75 e2                	jne    800339 <vprintfmt+0x14>
  800357:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80035b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800362:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800369:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800370:	ba 00 00 00 00       	mov    $0x0,%edx
  800375:	eb 07                	jmp    80037e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800377:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80037a:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037e:	8d 47 01             	lea    0x1(%edi),%eax
  800381:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800384:	0f b6 07             	movzbl (%edi),%eax
  800387:	0f b6 c8             	movzbl %al,%ecx
  80038a:	83 e8 23             	sub    $0x23,%eax
  80038d:	3c 55                	cmp    $0x55,%al
  80038f:	0f 87 1a 03 00 00    	ja     8006af <vprintfmt+0x38a>
  800395:	0f b6 c0             	movzbl %al,%eax
  800398:	ff 24 85 20 25 80 00 	jmp    *0x802520(,%eax,4)
  80039f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003a2:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003a6:	eb d6                	jmp    80037e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8003b0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003b3:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003b6:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003ba:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003bd:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003c0:	83 fa 09             	cmp    $0x9,%edx
  8003c3:	77 39                	ja     8003fe <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003c5:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003c8:	eb e9                	jmp    8003b3 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cd:	8d 48 04             	lea    0x4(%eax),%ecx
  8003d0:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003d3:	8b 00                	mov    (%eax),%eax
  8003d5:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003db:	eb 27                	jmp    800404 <vprintfmt+0xdf>
  8003dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003e0:	85 c0                	test   %eax,%eax
  8003e2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003e7:	0f 49 c8             	cmovns %eax,%ecx
  8003ea:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003f0:	eb 8c                	jmp    80037e <vprintfmt+0x59>
  8003f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003f5:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003fc:	eb 80                	jmp    80037e <vprintfmt+0x59>
  8003fe:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800401:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800404:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800408:	0f 89 70 ff ff ff    	jns    80037e <vprintfmt+0x59>
				width = precision, precision = -1;
  80040e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800411:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800414:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80041b:	e9 5e ff ff ff       	jmp    80037e <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800420:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800423:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800426:	e9 53 ff ff ff       	jmp    80037e <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80042b:	8b 45 14             	mov    0x14(%ebp),%eax
  80042e:	8d 50 04             	lea    0x4(%eax),%edx
  800431:	89 55 14             	mov    %edx,0x14(%ebp)
  800434:	83 ec 08             	sub    $0x8,%esp
  800437:	53                   	push   %ebx
  800438:	ff 30                	pushl  (%eax)
  80043a:	ff d6                	call   *%esi
			break;
  80043c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800442:	e9 04 ff ff ff       	jmp    80034b <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800447:	8b 45 14             	mov    0x14(%ebp),%eax
  80044a:	8d 50 04             	lea    0x4(%eax),%edx
  80044d:	89 55 14             	mov    %edx,0x14(%ebp)
  800450:	8b 00                	mov    (%eax),%eax
  800452:	99                   	cltd   
  800453:	31 d0                	xor    %edx,%eax
  800455:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800457:	83 f8 0f             	cmp    $0xf,%eax
  80045a:	7f 0b                	jg     800467 <vprintfmt+0x142>
  80045c:	8b 14 85 80 26 80 00 	mov    0x802680(,%eax,4),%edx
  800463:	85 d2                	test   %edx,%edx
  800465:	75 18                	jne    80047f <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800467:	50                   	push   %eax
  800468:	68 f3 23 80 00       	push   $0x8023f3
  80046d:	53                   	push   %ebx
  80046e:	56                   	push   %esi
  80046f:	e8 94 fe ff ff       	call   800308 <printfmt>
  800474:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800477:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80047a:	e9 cc fe ff ff       	jmp    80034b <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80047f:	52                   	push   %edx
  800480:	68 be 27 80 00       	push   $0x8027be
  800485:	53                   	push   %ebx
  800486:	56                   	push   %esi
  800487:	e8 7c fe ff ff       	call   800308 <printfmt>
  80048c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800492:	e9 b4 fe ff ff       	jmp    80034b <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800497:	8b 45 14             	mov    0x14(%ebp),%eax
  80049a:	8d 50 04             	lea    0x4(%eax),%edx
  80049d:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a0:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004a2:	85 ff                	test   %edi,%edi
  8004a4:	b8 ec 23 80 00       	mov    $0x8023ec,%eax
  8004a9:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004ac:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004b0:	0f 8e 94 00 00 00    	jle    80054a <vprintfmt+0x225>
  8004b6:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004ba:	0f 84 98 00 00 00    	je     800558 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c0:	83 ec 08             	sub    $0x8,%esp
  8004c3:	ff 75 d0             	pushl  -0x30(%ebp)
  8004c6:	57                   	push   %edi
  8004c7:	e8 86 02 00 00       	call   800752 <strnlen>
  8004cc:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004cf:	29 c1                	sub    %eax,%ecx
  8004d1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004d4:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004d7:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004db:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004de:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004e1:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e3:	eb 0f                	jmp    8004f4 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004e5:	83 ec 08             	sub    $0x8,%esp
  8004e8:	53                   	push   %ebx
  8004e9:	ff 75 e0             	pushl  -0x20(%ebp)
  8004ec:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ee:	83 ef 01             	sub    $0x1,%edi
  8004f1:	83 c4 10             	add    $0x10,%esp
  8004f4:	85 ff                	test   %edi,%edi
  8004f6:	7f ed                	jg     8004e5 <vprintfmt+0x1c0>
  8004f8:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004fb:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004fe:	85 c9                	test   %ecx,%ecx
  800500:	b8 00 00 00 00       	mov    $0x0,%eax
  800505:	0f 49 c1             	cmovns %ecx,%eax
  800508:	29 c1                	sub    %eax,%ecx
  80050a:	89 75 08             	mov    %esi,0x8(%ebp)
  80050d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800510:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800513:	89 cb                	mov    %ecx,%ebx
  800515:	eb 4d                	jmp    800564 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800517:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80051b:	74 1b                	je     800538 <vprintfmt+0x213>
  80051d:	0f be c0             	movsbl %al,%eax
  800520:	83 e8 20             	sub    $0x20,%eax
  800523:	83 f8 5e             	cmp    $0x5e,%eax
  800526:	76 10                	jbe    800538 <vprintfmt+0x213>
					putch('?', putdat);
  800528:	83 ec 08             	sub    $0x8,%esp
  80052b:	ff 75 0c             	pushl  0xc(%ebp)
  80052e:	6a 3f                	push   $0x3f
  800530:	ff 55 08             	call   *0x8(%ebp)
  800533:	83 c4 10             	add    $0x10,%esp
  800536:	eb 0d                	jmp    800545 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800538:	83 ec 08             	sub    $0x8,%esp
  80053b:	ff 75 0c             	pushl  0xc(%ebp)
  80053e:	52                   	push   %edx
  80053f:	ff 55 08             	call   *0x8(%ebp)
  800542:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800545:	83 eb 01             	sub    $0x1,%ebx
  800548:	eb 1a                	jmp    800564 <vprintfmt+0x23f>
  80054a:	89 75 08             	mov    %esi,0x8(%ebp)
  80054d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800550:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800553:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800556:	eb 0c                	jmp    800564 <vprintfmt+0x23f>
  800558:	89 75 08             	mov    %esi,0x8(%ebp)
  80055b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80055e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800561:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800564:	83 c7 01             	add    $0x1,%edi
  800567:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80056b:	0f be d0             	movsbl %al,%edx
  80056e:	85 d2                	test   %edx,%edx
  800570:	74 23                	je     800595 <vprintfmt+0x270>
  800572:	85 f6                	test   %esi,%esi
  800574:	78 a1                	js     800517 <vprintfmt+0x1f2>
  800576:	83 ee 01             	sub    $0x1,%esi
  800579:	79 9c                	jns    800517 <vprintfmt+0x1f2>
  80057b:	89 df                	mov    %ebx,%edi
  80057d:	8b 75 08             	mov    0x8(%ebp),%esi
  800580:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800583:	eb 18                	jmp    80059d <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800585:	83 ec 08             	sub    $0x8,%esp
  800588:	53                   	push   %ebx
  800589:	6a 20                	push   $0x20
  80058b:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80058d:	83 ef 01             	sub    $0x1,%edi
  800590:	83 c4 10             	add    $0x10,%esp
  800593:	eb 08                	jmp    80059d <vprintfmt+0x278>
  800595:	89 df                	mov    %ebx,%edi
  800597:	8b 75 08             	mov    0x8(%ebp),%esi
  80059a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80059d:	85 ff                	test   %edi,%edi
  80059f:	7f e4                	jg     800585 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a4:	e9 a2 fd ff ff       	jmp    80034b <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005a9:	83 fa 01             	cmp    $0x1,%edx
  8005ac:	7e 16                	jle    8005c4 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b1:	8d 50 08             	lea    0x8(%eax),%edx
  8005b4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b7:	8b 50 04             	mov    0x4(%eax),%edx
  8005ba:	8b 00                	mov    (%eax),%eax
  8005bc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005bf:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005c2:	eb 32                	jmp    8005f6 <vprintfmt+0x2d1>
	else if (lflag)
  8005c4:	85 d2                	test   %edx,%edx
  8005c6:	74 18                	je     8005e0 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cb:	8d 50 04             	lea    0x4(%eax),%edx
  8005ce:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d1:	8b 00                	mov    (%eax),%eax
  8005d3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d6:	89 c1                	mov    %eax,%ecx
  8005d8:	c1 f9 1f             	sar    $0x1f,%ecx
  8005db:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005de:	eb 16                	jmp    8005f6 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e3:	8d 50 04             	lea    0x4(%eax),%edx
  8005e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e9:	8b 00                	mov    (%eax),%eax
  8005eb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ee:	89 c1                	mov    %eax,%ecx
  8005f0:	c1 f9 1f             	sar    $0x1f,%ecx
  8005f3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005f6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005f9:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005fc:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800601:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800605:	79 74                	jns    80067b <vprintfmt+0x356>
				putch('-', putdat);
  800607:	83 ec 08             	sub    $0x8,%esp
  80060a:	53                   	push   %ebx
  80060b:	6a 2d                	push   $0x2d
  80060d:	ff d6                	call   *%esi
				num = -(long long) num;
  80060f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800612:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800615:	f7 d8                	neg    %eax
  800617:	83 d2 00             	adc    $0x0,%edx
  80061a:	f7 da                	neg    %edx
  80061c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80061f:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800624:	eb 55                	jmp    80067b <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800626:	8d 45 14             	lea    0x14(%ebp),%eax
  800629:	e8 83 fc ff ff       	call   8002b1 <getuint>
			base = 10;
  80062e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800633:	eb 46                	jmp    80067b <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800635:	8d 45 14             	lea    0x14(%ebp),%eax
  800638:	e8 74 fc ff ff       	call   8002b1 <getuint>
                        base = 8;
  80063d:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800642:	eb 37                	jmp    80067b <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800644:	83 ec 08             	sub    $0x8,%esp
  800647:	53                   	push   %ebx
  800648:	6a 30                	push   $0x30
  80064a:	ff d6                	call   *%esi
			putch('x', putdat);
  80064c:	83 c4 08             	add    $0x8,%esp
  80064f:	53                   	push   %ebx
  800650:	6a 78                	push   $0x78
  800652:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800654:	8b 45 14             	mov    0x14(%ebp),%eax
  800657:	8d 50 04             	lea    0x4(%eax),%edx
  80065a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80065d:	8b 00                	mov    (%eax),%eax
  80065f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800664:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800667:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80066c:	eb 0d                	jmp    80067b <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80066e:	8d 45 14             	lea    0x14(%ebp),%eax
  800671:	e8 3b fc ff ff       	call   8002b1 <getuint>
			base = 16;
  800676:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80067b:	83 ec 0c             	sub    $0xc,%esp
  80067e:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800682:	57                   	push   %edi
  800683:	ff 75 e0             	pushl  -0x20(%ebp)
  800686:	51                   	push   %ecx
  800687:	52                   	push   %edx
  800688:	50                   	push   %eax
  800689:	89 da                	mov    %ebx,%edx
  80068b:	89 f0                	mov    %esi,%eax
  80068d:	e8 70 fb ff ff       	call   800202 <printnum>
			break;
  800692:	83 c4 20             	add    $0x20,%esp
  800695:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800698:	e9 ae fc ff ff       	jmp    80034b <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80069d:	83 ec 08             	sub    $0x8,%esp
  8006a0:	53                   	push   %ebx
  8006a1:	51                   	push   %ecx
  8006a2:	ff d6                	call   *%esi
			break;
  8006a4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006aa:	e9 9c fc ff ff       	jmp    80034b <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006af:	83 ec 08             	sub    $0x8,%esp
  8006b2:	53                   	push   %ebx
  8006b3:	6a 25                	push   $0x25
  8006b5:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006b7:	83 c4 10             	add    $0x10,%esp
  8006ba:	eb 03                	jmp    8006bf <vprintfmt+0x39a>
  8006bc:	83 ef 01             	sub    $0x1,%edi
  8006bf:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006c3:	75 f7                	jne    8006bc <vprintfmt+0x397>
  8006c5:	e9 81 fc ff ff       	jmp    80034b <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006cd:	5b                   	pop    %ebx
  8006ce:	5e                   	pop    %esi
  8006cf:	5f                   	pop    %edi
  8006d0:	5d                   	pop    %ebp
  8006d1:	c3                   	ret    

008006d2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006d2:	55                   	push   %ebp
  8006d3:	89 e5                	mov    %esp,%ebp
  8006d5:	83 ec 18             	sub    $0x18,%esp
  8006d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006db:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006de:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006e1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006e5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006e8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006ef:	85 c0                	test   %eax,%eax
  8006f1:	74 26                	je     800719 <vsnprintf+0x47>
  8006f3:	85 d2                	test   %edx,%edx
  8006f5:	7e 22                	jle    800719 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006f7:	ff 75 14             	pushl  0x14(%ebp)
  8006fa:	ff 75 10             	pushl  0x10(%ebp)
  8006fd:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800700:	50                   	push   %eax
  800701:	68 eb 02 80 00       	push   $0x8002eb
  800706:	e8 1a fc ff ff       	call   800325 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80070b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80070e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800711:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800714:	83 c4 10             	add    $0x10,%esp
  800717:	eb 05                	jmp    80071e <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800719:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80071e:	c9                   	leave  
  80071f:	c3                   	ret    

00800720 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800720:	55                   	push   %ebp
  800721:	89 e5                	mov    %esp,%ebp
  800723:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800726:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800729:	50                   	push   %eax
  80072a:	ff 75 10             	pushl  0x10(%ebp)
  80072d:	ff 75 0c             	pushl  0xc(%ebp)
  800730:	ff 75 08             	pushl  0x8(%ebp)
  800733:	e8 9a ff ff ff       	call   8006d2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800738:	c9                   	leave  
  800739:	c3                   	ret    

0080073a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80073a:	55                   	push   %ebp
  80073b:	89 e5                	mov    %esp,%ebp
  80073d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800740:	b8 00 00 00 00       	mov    $0x0,%eax
  800745:	eb 03                	jmp    80074a <strlen+0x10>
		n++;
  800747:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80074a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80074e:	75 f7                	jne    800747 <strlen+0xd>
		n++;
	return n;
}
  800750:	5d                   	pop    %ebp
  800751:	c3                   	ret    

00800752 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800752:	55                   	push   %ebp
  800753:	89 e5                	mov    %esp,%ebp
  800755:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800758:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80075b:	ba 00 00 00 00       	mov    $0x0,%edx
  800760:	eb 03                	jmp    800765 <strnlen+0x13>
		n++;
  800762:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800765:	39 c2                	cmp    %eax,%edx
  800767:	74 08                	je     800771 <strnlen+0x1f>
  800769:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80076d:	75 f3                	jne    800762 <strnlen+0x10>
  80076f:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800771:	5d                   	pop    %ebp
  800772:	c3                   	ret    

00800773 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800773:	55                   	push   %ebp
  800774:	89 e5                	mov    %esp,%ebp
  800776:	53                   	push   %ebx
  800777:	8b 45 08             	mov    0x8(%ebp),%eax
  80077a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80077d:	89 c2                	mov    %eax,%edx
  80077f:	83 c2 01             	add    $0x1,%edx
  800782:	83 c1 01             	add    $0x1,%ecx
  800785:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800789:	88 5a ff             	mov    %bl,-0x1(%edx)
  80078c:	84 db                	test   %bl,%bl
  80078e:	75 ef                	jne    80077f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800790:	5b                   	pop    %ebx
  800791:	5d                   	pop    %ebp
  800792:	c3                   	ret    

00800793 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800793:	55                   	push   %ebp
  800794:	89 e5                	mov    %esp,%ebp
  800796:	53                   	push   %ebx
  800797:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80079a:	53                   	push   %ebx
  80079b:	e8 9a ff ff ff       	call   80073a <strlen>
  8007a0:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007a3:	ff 75 0c             	pushl  0xc(%ebp)
  8007a6:	01 d8                	add    %ebx,%eax
  8007a8:	50                   	push   %eax
  8007a9:	e8 c5 ff ff ff       	call   800773 <strcpy>
	return dst;
}
  8007ae:	89 d8                	mov    %ebx,%eax
  8007b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b3:	c9                   	leave  
  8007b4:	c3                   	ret    

008007b5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007b5:	55                   	push   %ebp
  8007b6:	89 e5                	mov    %esp,%ebp
  8007b8:	56                   	push   %esi
  8007b9:	53                   	push   %ebx
  8007ba:	8b 75 08             	mov    0x8(%ebp),%esi
  8007bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007c0:	89 f3                	mov    %esi,%ebx
  8007c2:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c5:	89 f2                	mov    %esi,%edx
  8007c7:	eb 0f                	jmp    8007d8 <strncpy+0x23>
		*dst++ = *src;
  8007c9:	83 c2 01             	add    $0x1,%edx
  8007cc:	0f b6 01             	movzbl (%ecx),%eax
  8007cf:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007d2:	80 39 01             	cmpb   $0x1,(%ecx)
  8007d5:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d8:	39 da                	cmp    %ebx,%edx
  8007da:	75 ed                	jne    8007c9 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007dc:	89 f0                	mov    %esi,%eax
  8007de:	5b                   	pop    %ebx
  8007df:	5e                   	pop    %esi
  8007e0:	5d                   	pop    %ebp
  8007e1:	c3                   	ret    

008007e2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007e2:	55                   	push   %ebp
  8007e3:	89 e5                	mov    %esp,%ebp
  8007e5:	56                   	push   %esi
  8007e6:	53                   	push   %ebx
  8007e7:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007ed:	8b 55 10             	mov    0x10(%ebp),%edx
  8007f0:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007f2:	85 d2                	test   %edx,%edx
  8007f4:	74 21                	je     800817 <strlcpy+0x35>
  8007f6:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007fa:	89 f2                	mov    %esi,%edx
  8007fc:	eb 09                	jmp    800807 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007fe:	83 c2 01             	add    $0x1,%edx
  800801:	83 c1 01             	add    $0x1,%ecx
  800804:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800807:	39 c2                	cmp    %eax,%edx
  800809:	74 09                	je     800814 <strlcpy+0x32>
  80080b:	0f b6 19             	movzbl (%ecx),%ebx
  80080e:	84 db                	test   %bl,%bl
  800810:	75 ec                	jne    8007fe <strlcpy+0x1c>
  800812:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800814:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800817:	29 f0                	sub    %esi,%eax
}
  800819:	5b                   	pop    %ebx
  80081a:	5e                   	pop    %esi
  80081b:	5d                   	pop    %ebp
  80081c:	c3                   	ret    

0080081d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80081d:	55                   	push   %ebp
  80081e:	89 e5                	mov    %esp,%ebp
  800820:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800823:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800826:	eb 06                	jmp    80082e <strcmp+0x11>
		p++, q++;
  800828:	83 c1 01             	add    $0x1,%ecx
  80082b:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80082e:	0f b6 01             	movzbl (%ecx),%eax
  800831:	84 c0                	test   %al,%al
  800833:	74 04                	je     800839 <strcmp+0x1c>
  800835:	3a 02                	cmp    (%edx),%al
  800837:	74 ef                	je     800828 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800839:	0f b6 c0             	movzbl %al,%eax
  80083c:	0f b6 12             	movzbl (%edx),%edx
  80083f:	29 d0                	sub    %edx,%eax
}
  800841:	5d                   	pop    %ebp
  800842:	c3                   	ret    

00800843 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800843:	55                   	push   %ebp
  800844:	89 e5                	mov    %esp,%ebp
  800846:	53                   	push   %ebx
  800847:	8b 45 08             	mov    0x8(%ebp),%eax
  80084a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80084d:	89 c3                	mov    %eax,%ebx
  80084f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800852:	eb 06                	jmp    80085a <strncmp+0x17>
		n--, p++, q++;
  800854:	83 c0 01             	add    $0x1,%eax
  800857:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80085a:	39 d8                	cmp    %ebx,%eax
  80085c:	74 15                	je     800873 <strncmp+0x30>
  80085e:	0f b6 08             	movzbl (%eax),%ecx
  800861:	84 c9                	test   %cl,%cl
  800863:	74 04                	je     800869 <strncmp+0x26>
  800865:	3a 0a                	cmp    (%edx),%cl
  800867:	74 eb                	je     800854 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800869:	0f b6 00             	movzbl (%eax),%eax
  80086c:	0f b6 12             	movzbl (%edx),%edx
  80086f:	29 d0                	sub    %edx,%eax
  800871:	eb 05                	jmp    800878 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800873:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800878:	5b                   	pop    %ebx
  800879:	5d                   	pop    %ebp
  80087a:	c3                   	ret    

0080087b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	8b 45 08             	mov    0x8(%ebp),%eax
  800881:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800885:	eb 07                	jmp    80088e <strchr+0x13>
		if (*s == c)
  800887:	38 ca                	cmp    %cl,%dl
  800889:	74 0f                	je     80089a <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80088b:	83 c0 01             	add    $0x1,%eax
  80088e:	0f b6 10             	movzbl (%eax),%edx
  800891:	84 d2                	test   %dl,%dl
  800893:	75 f2                	jne    800887 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800895:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80089a:	5d                   	pop    %ebp
  80089b:	c3                   	ret    

0080089c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80089c:	55                   	push   %ebp
  80089d:	89 e5                	mov    %esp,%ebp
  80089f:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008a6:	eb 03                	jmp    8008ab <strfind+0xf>
  8008a8:	83 c0 01             	add    $0x1,%eax
  8008ab:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008ae:	38 ca                	cmp    %cl,%dl
  8008b0:	74 04                	je     8008b6 <strfind+0x1a>
  8008b2:	84 d2                	test   %dl,%dl
  8008b4:	75 f2                	jne    8008a8 <strfind+0xc>
			break;
	return (char *) s;
}
  8008b6:	5d                   	pop    %ebp
  8008b7:	c3                   	ret    

008008b8 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008b8:	55                   	push   %ebp
  8008b9:	89 e5                	mov    %esp,%ebp
  8008bb:	57                   	push   %edi
  8008bc:	56                   	push   %esi
  8008bd:	53                   	push   %ebx
  8008be:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008c1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008c4:	85 c9                	test   %ecx,%ecx
  8008c6:	74 36                	je     8008fe <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008c8:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008ce:	75 28                	jne    8008f8 <memset+0x40>
  8008d0:	f6 c1 03             	test   $0x3,%cl
  8008d3:	75 23                	jne    8008f8 <memset+0x40>
		c &= 0xFF;
  8008d5:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008d9:	89 d3                	mov    %edx,%ebx
  8008db:	c1 e3 08             	shl    $0x8,%ebx
  8008de:	89 d6                	mov    %edx,%esi
  8008e0:	c1 e6 18             	shl    $0x18,%esi
  8008e3:	89 d0                	mov    %edx,%eax
  8008e5:	c1 e0 10             	shl    $0x10,%eax
  8008e8:	09 f0                	or     %esi,%eax
  8008ea:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008ec:	89 d8                	mov    %ebx,%eax
  8008ee:	09 d0                	or     %edx,%eax
  8008f0:	c1 e9 02             	shr    $0x2,%ecx
  8008f3:	fc                   	cld    
  8008f4:	f3 ab                	rep stos %eax,%es:(%edi)
  8008f6:	eb 06                	jmp    8008fe <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008fb:	fc                   	cld    
  8008fc:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008fe:	89 f8                	mov    %edi,%eax
  800900:	5b                   	pop    %ebx
  800901:	5e                   	pop    %esi
  800902:	5f                   	pop    %edi
  800903:	5d                   	pop    %ebp
  800904:	c3                   	ret    

00800905 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800905:	55                   	push   %ebp
  800906:	89 e5                	mov    %esp,%ebp
  800908:	57                   	push   %edi
  800909:	56                   	push   %esi
  80090a:	8b 45 08             	mov    0x8(%ebp),%eax
  80090d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800910:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800913:	39 c6                	cmp    %eax,%esi
  800915:	73 35                	jae    80094c <memmove+0x47>
  800917:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80091a:	39 d0                	cmp    %edx,%eax
  80091c:	73 2e                	jae    80094c <memmove+0x47>
		s += n;
		d += n;
  80091e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800921:	89 d6                	mov    %edx,%esi
  800923:	09 fe                	or     %edi,%esi
  800925:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80092b:	75 13                	jne    800940 <memmove+0x3b>
  80092d:	f6 c1 03             	test   $0x3,%cl
  800930:	75 0e                	jne    800940 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800932:	83 ef 04             	sub    $0x4,%edi
  800935:	8d 72 fc             	lea    -0x4(%edx),%esi
  800938:	c1 e9 02             	shr    $0x2,%ecx
  80093b:	fd                   	std    
  80093c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80093e:	eb 09                	jmp    800949 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800940:	83 ef 01             	sub    $0x1,%edi
  800943:	8d 72 ff             	lea    -0x1(%edx),%esi
  800946:	fd                   	std    
  800947:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800949:	fc                   	cld    
  80094a:	eb 1d                	jmp    800969 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80094c:	89 f2                	mov    %esi,%edx
  80094e:	09 c2                	or     %eax,%edx
  800950:	f6 c2 03             	test   $0x3,%dl
  800953:	75 0f                	jne    800964 <memmove+0x5f>
  800955:	f6 c1 03             	test   $0x3,%cl
  800958:	75 0a                	jne    800964 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80095a:	c1 e9 02             	shr    $0x2,%ecx
  80095d:	89 c7                	mov    %eax,%edi
  80095f:	fc                   	cld    
  800960:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800962:	eb 05                	jmp    800969 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800964:	89 c7                	mov    %eax,%edi
  800966:	fc                   	cld    
  800967:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800969:	5e                   	pop    %esi
  80096a:	5f                   	pop    %edi
  80096b:	5d                   	pop    %ebp
  80096c:	c3                   	ret    

0080096d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80096d:	55                   	push   %ebp
  80096e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800970:	ff 75 10             	pushl  0x10(%ebp)
  800973:	ff 75 0c             	pushl  0xc(%ebp)
  800976:	ff 75 08             	pushl  0x8(%ebp)
  800979:	e8 87 ff ff ff       	call   800905 <memmove>
}
  80097e:	c9                   	leave  
  80097f:	c3                   	ret    

00800980 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800980:	55                   	push   %ebp
  800981:	89 e5                	mov    %esp,%ebp
  800983:	56                   	push   %esi
  800984:	53                   	push   %ebx
  800985:	8b 45 08             	mov    0x8(%ebp),%eax
  800988:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098b:	89 c6                	mov    %eax,%esi
  80098d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800990:	eb 1a                	jmp    8009ac <memcmp+0x2c>
		if (*s1 != *s2)
  800992:	0f b6 08             	movzbl (%eax),%ecx
  800995:	0f b6 1a             	movzbl (%edx),%ebx
  800998:	38 d9                	cmp    %bl,%cl
  80099a:	74 0a                	je     8009a6 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80099c:	0f b6 c1             	movzbl %cl,%eax
  80099f:	0f b6 db             	movzbl %bl,%ebx
  8009a2:	29 d8                	sub    %ebx,%eax
  8009a4:	eb 0f                	jmp    8009b5 <memcmp+0x35>
		s1++, s2++;
  8009a6:	83 c0 01             	add    $0x1,%eax
  8009a9:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ac:	39 f0                	cmp    %esi,%eax
  8009ae:	75 e2                	jne    800992 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009b0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009b5:	5b                   	pop    %ebx
  8009b6:	5e                   	pop    %esi
  8009b7:	5d                   	pop    %ebp
  8009b8:	c3                   	ret    

008009b9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009b9:	55                   	push   %ebp
  8009ba:	89 e5                	mov    %esp,%ebp
  8009bc:	53                   	push   %ebx
  8009bd:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009c0:	89 c1                	mov    %eax,%ecx
  8009c2:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009c5:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009c9:	eb 0a                	jmp    8009d5 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009cb:	0f b6 10             	movzbl (%eax),%edx
  8009ce:	39 da                	cmp    %ebx,%edx
  8009d0:	74 07                	je     8009d9 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009d2:	83 c0 01             	add    $0x1,%eax
  8009d5:	39 c8                	cmp    %ecx,%eax
  8009d7:	72 f2                	jb     8009cb <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009d9:	5b                   	pop    %ebx
  8009da:	5d                   	pop    %ebp
  8009db:	c3                   	ret    

008009dc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009dc:	55                   	push   %ebp
  8009dd:	89 e5                	mov    %esp,%ebp
  8009df:	57                   	push   %edi
  8009e0:	56                   	push   %esi
  8009e1:	53                   	push   %ebx
  8009e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009e5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009e8:	eb 03                	jmp    8009ed <strtol+0x11>
		s++;
  8009ea:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ed:	0f b6 01             	movzbl (%ecx),%eax
  8009f0:	3c 20                	cmp    $0x20,%al
  8009f2:	74 f6                	je     8009ea <strtol+0xe>
  8009f4:	3c 09                	cmp    $0x9,%al
  8009f6:	74 f2                	je     8009ea <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009f8:	3c 2b                	cmp    $0x2b,%al
  8009fa:	75 0a                	jne    800a06 <strtol+0x2a>
		s++;
  8009fc:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009ff:	bf 00 00 00 00       	mov    $0x0,%edi
  800a04:	eb 11                	jmp    800a17 <strtol+0x3b>
  800a06:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a0b:	3c 2d                	cmp    $0x2d,%al
  800a0d:	75 08                	jne    800a17 <strtol+0x3b>
		s++, neg = 1;
  800a0f:	83 c1 01             	add    $0x1,%ecx
  800a12:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a17:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a1d:	75 15                	jne    800a34 <strtol+0x58>
  800a1f:	80 39 30             	cmpb   $0x30,(%ecx)
  800a22:	75 10                	jne    800a34 <strtol+0x58>
  800a24:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a28:	75 7c                	jne    800aa6 <strtol+0xca>
		s += 2, base = 16;
  800a2a:	83 c1 02             	add    $0x2,%ecx
  800a2d:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a32:	eb 16                	jmp    800a4a <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a34:	85 db                	test   %ebx,%ebx
  800a36:	75 12                	jne    800a4a <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a38:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a3d:	80 39 30             	cmpb   $0x30,(%ecx)
  800a40:	75 08                	jne    800a4a <strtol+0x6e>
		s++, base = 8;
  800a42:	83 c1 01             	add    $0x1,%ecx
  800a45:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a4a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a4f:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a52:	0f b6 11             	movzbl (%ecx),%edx
  800a55:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a58:	89 f3                	mov    %esi,%ebx
  800a5a:	80 fb 09             	cmp    $0x9,%bl
  800a5d:	77 08                	ja     800a67 <strtol+0x8b>
			dig = *s - '0';
  800a5f:	0f be d2             	movsbl %dl,%edx
  800a62:	83 ea 30             	sub    $0x30,%edx
  800a65:	eb 22                	jmp    800a89 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a67:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a6a:	89 f3                	mov    %esi,%ebx
  800a6c:	80 fb 19             	cmp    $0x19,%bl
  800a6f:	77 08                	ja     800a79 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a71:	0f be d2             	movsbl %dl,%edx
  800a74:	83 ea 57             	sub    $0x57,%edx
  800a77:	eb 10                	jmp    800a89 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a79:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a7c:	89 f3                	mov    %esi,%ebx
  800a7e:	80 fb 19             	cmp    $0x19,%bl
  800a81:	77 16                	ja     800a99 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a83:	0f be d2             	movsbl %dl,%edx
  800a86:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a89:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a8c:	7d 0b                	jge    800a99 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a8e:	83 c1 01             	add    $0x1,%ecx
  800a91:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a95:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a97:	eb b9                	jmp    800a52 <strtol+0x76>

	if (endptr)
  800a99:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a9d:	74 0d                	je     800aac <strtol+0xd0>
		*endptr = (char *) s;
  800a9f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aa2:	89 0e                	mov    %ecx,(%esi)
  800aa4:	eb 06                	jmp    800aac <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aa6:	85 db                	test   %ebx,%ebx
  800aa8:	74 98                	je     800a42 <strtol+0x66>
  800aaa:	eb 9e                	jmp    800a4a <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800aac:	89 c2                	mov    %eax,%edx
  800aae:	f7 da                	neg    %edx
  800ab0:	85 ff                	test   %edi,%edi
  800ab2:	0f 45 c2             	cmovne %edx,%eax
}
  800ab5:	5b                   	pop    %ebx
  800ab6:	5e                   	pop    %esi
  800ab7:	5f                   	pop    %edi
  800ab8:	5d                   	pop    %ebp
  800ab9:	c3                   	ret    

00800aba <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800aba:	55                   	push   %ebp
  800abb:	89 e5                	mov    %esp,%ebp
  800abd:	57                   	push   %edi
  800abe:	56                   	push   %esi
  800abf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ac8:	8b 55 08             	mov    0x8(%ebp),%edx
  800acb:	89 c3                	mov    %eax,%ebx
  800acd:	89 c7                	mov    %eax,%edi
  800acf:	89 c6                	mov    %eax,%esi
  800ad1:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ad3:	5b                   	pop    %ebx
  800ad4:	5e                   	pop    %esi
  800ad5:	5f                   	pop    %edi
  800ad6:	5d                   	pop    %ebp
  800ad7:	c3                   	ret    

00800ad8 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ad8:	55                   	push   %ebp
  800ad9:	89 e5                	mov    %esp,%ebp
  800adb:	57                   	push   %edi
  800adc:	56                   	push   %esi
  800add:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ade:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae3:	b8 01 00 00 00       	mov    $0x1,%eax
  800ae8:	89 d1                	mov    %edx,%ecx
  800aea:	89 d3                	mov    %edx,%ebx
  800aec:	89 d7                	mov    %edx,%edi
  800aee:	89 d6                	mov    %edx,%esi
  800af0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800af2:	5b                   	pop    %ebx
  800af3:	5e                   	pop    %esi
  800af4:	5f                   	pop    %edi
  800af5:	5d                   	pop    %ebp
  800af6:	c3                   	ret    

00800af7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800af7:	55                   	push   %ebp
  800af8:	89 e5                	mov    %esp,%ebp
  800afa:	57                   	push   %edi
  800afb:	56                   	push   %esi
  800afc:	53                   	push   %ebx
  800afd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b00:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b05:	b8 03 00 00 00       	mov    $0x3,%eax
  800b0a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b0d:	89 cb                	mov    %ecx,%ebx
  800b0f:	89 cf                	mov    %ecx,%edi
  800b11:	89 ce                	mov    %ecx,%esi
  800b13:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b15:	85 c0                	test   %eax,%eax
  800b17:	7e 17                	jle    800b30 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b19:	83 ec 0c             	sub    $0xc,%esp
  800b1c:	50                   	push   %eax
  800b1d:	6a 03                	push   $0x3
  800b1f:	68 df 26 80 00       	push   $0x8026df
  800b24:	6a 23                	push   $0x23
  800b26:	68 fc 26 80 00       	push   $0x8026fc
  800b2b:	e8 e5 f5 ff ff       	call   800115 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b30:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b33:	5b                   	pop    %ebx
  800b34:	5e                   	pop    %esi
  800b35:	5f                   	pop    %edi
  800b36:	5d                   	pop    %ebp
  800b37:	c3                   	ret    

00800b38 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b38:	55                   	push   %ebp
  800b39:	89 e5                	mov    %esp,%ebp
  800b3b:	57                   	push   %edi
  800b3c:	56                   	push   %esi
  800b3d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b43:	b8 02 00 00 00       	mov    $0x2,%eax
  800b48:	89 d1                	mov    %edx,%ecx
  800b4a:	89 d3                	mov    %edx,%ebx
  800b4c:	89 d7                	mov    %edx,%edi
  800b4e:	89 d6                	mov    %edx,%esi
  800b50:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b52:	5b                   	pop    %ebx
  800b53:	5e                   	pop    %esi
  800b54:	5f                   	pop    %edi
  800b55:	5d                   	pop    %ebp
  800b56:	c3                   	ret    

00800b57 <sys_yield>:

void
sys_yield(void)
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
  800b62:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b67:	89 d1                	mov    %edx,%ecx
  800b69:	89 d3                	mov    %edx,%ebx
  800b6b:	89 d7                	mov    %edx,%edi
  800b6d:	89 d6                	mov    %edx,%esi
  800b6f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b71:	5b                   	pop    %ebx
  800b72:	5e                   	pop    %esi
  800b73:	5f                   	pop    %edi
  800b74:	5d                   	pop    %ebp
  800b75:	c3                   	ret    

00800b76 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800b7f:	be 00 00 00 00       	mov    $0x0,%esi
  800b84:	b8 04 00 00 00       	mov    $0x4,%eax
  800b89:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b92:	89 f7                	mov    %esi,%edi
  800b94:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b96:	85 c0                	test   %eax,%eax
  800b98:	7e 17                	jle    800bb1 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9a:	83 ec 0c             	sub    $0xc,%esp
  800b9d:	50                   	push   %eax
  800b9e:	6a 04                	push   $0x4
  800ba0:	68 df 26 80 00       	push   $0x8026df
  800ba5:	6a 23                	push   $0x23
  800ba7:	68 fc 26 80 00       	push   $0x8026fc
  800bac:	e8 64 f5 ff ff       	call   800115 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bb1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb4:	5b                   	pop    %ebx
  800bb5:	5e                   	pop    %esi
  800bb6:	5f                   	pop    %edi
  800bb7:	5d                   	pop    %ebp
  800bb8:	c3                   	ret    

00800bb9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
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
  800bc2:	b8 05 00 00 00       	mov    $0x5,%eax
  800bc7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bca:	8b 55 08             	mov    0x8(%ebp),%edx
  800bcd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bd3:	8b 75 18             	mov    0x18(%ebp),%esi
  800bd6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bd8:	85 c0                	test   %eax,%eax
  800bda:	7e 17                	jle    800bf3 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bdc:	83 ec 0c             	sub    $0xc,%esp
  800bdf:	50                   	push   %eax
  800be0:	6a 05                	push   $0x5
  800be2:	68 df 26 80 00       	push   $0x8026df
  800be7:	6a 23                	push   $0x23
  800be9:	68 fc 26 80 00       	push   $0x8026fc
  800bee:	e8 22 f5 ff ff       	call   800115 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bf3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf6:	5b                   	pop    %ebx
  800bf7:	5e                   	pop    %esi
  800bf8:	5f                   	pop    %edi
  800bf9:	5d                   	pop    %ebp
  800bfa:	c3                   	ret    

00800bfb <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bfb:	55                   	push   %ebp
  800bfc:	89 e5                	mov    %esp,%ebp
  800bfe:	57                   	push   %edi
  800bff:	56                   	push   %esi
  800c00:	53                   	push   %ebx
  800c01:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c04:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c09:	b8 06 00 00 00       	mov    $0x6,%eax
  800c0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c11:	8b 55 08             	mov    0x8(%ebp),%edx
  800c14:	89 df                	mov    %ebx,%edi
  800c16:	89 de                	mov    %ebx,%esi
  800c18:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c1a:	85 c0                	test   %eax,%eax
  800c1c:	7e 17                	jle    800c35 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1e:	83 ec 0c             	sub    $0xc,%esp
  800c21:	50                   	push   %eax
  800c22:	6a 06                	push   $0x6
  800c24:	68 df 26 80 00       	push   $0x8026df
  800c29:	6a 23                	push   $0x23
  800c2b:	68 fc 26 80 00       	push   $0x8026fc
  800c30:	e8 e0 f4 ff ff       	call   800115 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c35:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c38:	5b                   	pop    %ebx
  800c39:	5e                   	pop    %esi
  800c3a:	5f                   	pop    %edi
  800c3b:	5d                   	pop    %ebp
  800c3c:	c3                   	ret    

00800c3d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c3d:	55                   	push   %ebp
  800c3e:	89 e5                	mov    %esp,%ebp
  800c40:	57                   	push   %edi
  800c41:	56                   	push   %esi
  800c42:	53                   	push   %ebx
  800c43:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c46:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c4b:	b8 08 00 00 00       	mov    $0x8,%eax
  800c50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c53:	8b 55 08             	mov    0x8(%ebp),%edx
  800c56:	89 df                	mov    %ebx,%edi
  800c58:	89 de                	mov    %ebx,%esi
  800c5a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c5c:	85 c0                	test   %eax,%eax
  800c5e:	7e 17                	jle    800c77 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c60:	83 ec 0c             	sub    $0xc,%esp
  800c63:	50                   	push   %eax
  800c64:	6a 08                	push   $0x8
  800c66:	68 df 26 80 00       	push   $0x8026df
  800c6b:	6a 23                	push   $0x23
  800c6d:	68 fc 26 80 00       	push   $0x8026fc
  800c72:	e8 9e f4 ff ff       	call   800115 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c77:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7a:	5b                   	pop    %ebx
  800c7b:	5e                   	pop    %esi
  800c7c:	5f                   	pop    %edi
  800c7d:	5d                   	pop    %ebp
  800c7e:	c3                   	ret    

00800c7f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c7f:	55                   	push   %ebp
  800c80:	89 e5                	mov    %esp,%ebp
  800c82:	57                   	push   %edi
  800c83:	56                   	push   %esi
  800c84:	53                   	push   %ebx
  800c85:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c88:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c8d:	b8 09 00 00 00       	mov    $0x9,%eax
  800c92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c95:	8b 55 08             	mov    0x8(%ebp),%edx
  800c98:	89 df                	mov    %ebx,%edi
  800c9a:	89 de                	mov    %ebx,%esi
  800c9c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c9e:	85 c0                	test   %eax,%eax
  800ca0:	7e 17                	jle    800cb9 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca2:	83 ec 0c             	sub    $0xc,%esp
  800ca5:	50                   	push   %eax
  800ca6:	6a 09                	push   $0x9
  800ca8:	68 df 26 80 00       	push   $0x8026df
  800cad:	6a 23                	push   $0x23
  800caf:	68 fc 26 80 00       	push   $0x8026fc
  800cb4:	e8 5c f4 ff ff       	call   800115 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cb9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbc:	5b                   	pop    %ebx
  800cbd:	5e                   	pop    %esi
  800cbe:	5f                   	pop    %edi
  800cbf:	5d                   	pop    %ebp
  800cc0:	c3                   	ret    

00800cc1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cc1:	55                   	push   %ebp
  800cc2:	89 e5                	mov    %esp,%ebp
  800cc4:	57                   	push   %edi
  800cc5:	56                   	push   %esi
  800cc6:	53                   	push   %ebx
  800cc7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cca:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ccf:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cda:	89 df                	mov    %ebx,%edi
  800cdc:	89 de                	mov    %ebx,%esi
  800cde:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ce0:	85 c0                	test   %eax,%eax
  800ce2:	7e 17                	jle    800cfb <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce4:	83 ec 0c             	sub    $0xc,%esp
  800ce7:	50                   	push   %eax
  800ce8:	6a 0a                	push   $0xa
  800cea:	68 df 26 80 00       	push   $0x8026df
  800cef:	6a 23                	push   $0x23
  800cf1:	68 fc 26 80 00       	push   $0x8026fc
  800cf6:	e8 1a f4 ff ff       	call   800115 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cfb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfe:	5b                   	pop    %ebx
  800cff:	5e                   	pop    %esi
  800d00:	5f                   	pop    %edi
  800d01:	5d                   	pop    %ebp
  800d02:	c3                   	ret    

00800d03 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d03:	55                   	push   %ebp
  800d04:	89 e5                	mov    %esp,%ebp
  800d06:	57                   	push   %edi
  800d07:	56                   	push   %esi
  800d08:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d09:	be 00 00 00 00       	mov    $0x0,%esi
  800d0e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d16:	8b 55 08             	mov    0x8(%ebp),%edx
  800d19:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d1c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d1f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d21:	5b                   	pop    %ebx
  800d22:	5e                   	pop    %esi
  800d23:	5f                   	pop    %edi
  800d24:	5d                   	pop    %ebp
  800d25:	c3                   	ret    

00800d26 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d26:	55                   	push   %ebp
  800d27:	89 e5                	mov    %esp,%ebp
  800d29:	57                   	push   %edi
  800d2a:	56                   	push   %esi
  800d2b:	53                   	push   %ebx
  800d2c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d34:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d39:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3c:	89 cb                	mov    %ecx,%ebx
  800d3e:	89 cf                	mov    %ecx,%edi
  800d40:	89 ce                	mov    %ecx,%esi
  800d42:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d44:	85 c0                	test   %eax,%eax
  800d46:	7e 17                	jle    800d5f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d48:	83 ec 0c             	sub    $0xc,%esp
  800d4b:	50                   	push   %eax
  800d4c:	6a 0d                	push   $0xd
  800d4e:	68 df 26 80 00       	push   $0x8026df
  800d53:	6a 23                	push   $0x23
  800d55:	68 fc 26 80 00       	push   $0x8026fc
  800d5a:	e8 b6 f3 ff ff       	call   800115 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d62:	5b                   	pop    %ebx
  800d63:	5e                   	pop    %esi
  800d64:	5f                   	pop    %edi
  800d65:	5d                   	pop    %ebp
  800d66:	c3                   	ret    

00800d67 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d67:	55                   	push   %ebp
  800d68:	89 e5                	mov    %esp,%ebp
  800d6a:	57                   	push   %edi
  800d6b:	56                   	push   %esi
  800d6c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6d:	ba 00 00 00 00       	mov    $0x0,%edx
  800d72:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d77:	89 d1                	mov    %edx,%ecx
  800d79:	89 d3                	mov    %edx,%ebx
  800d7b:	89 d7                	mov    %edx,%edi
  800d7d:	89 d6                	mov    %edx,%esi
  800d7f:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d81:	5b                   	pop    %ebx
  800d82:	5e                   	pop    %esi
  800d83:	5f                   	pop    %edi
  800d84:	5d                   	pop    %ebp
  800d85:	c3                   	ret    

00800d86 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d86:	55                   	push   %ebp
  800d87:	89 e5                	mov    %esp,%ebp
  800d89:	53                   	push   %ebx
  800d8a:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  800d8d:	83 3d 0c 40 80 00 00 	cmpl   $0x0,0x80400c
  800d94:	75 28                	jne    800dbe <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  800d96:	e8 9d fd ff ff       	call   800b38 <sys_getenvid>
  800d9b:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_U | PTE_W);
  800d9d:	83 ec 04             	sub    $0x4,%esp
  800da0:	6a 06                	push   $0x6
  800da2:	68 00 f0 bf ee       	push   $0xeebff000
  800da7:	50                   	push   %eax
  800da8:	e8 c9 fd ff ff       	call   800b76 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  800dad:	83 c4 08             	add    $0x8,%esp
  800db0:	68 cb 0d 80 00       	push   $0x800dcb
  800db5:	53                   	push   %ebx
  800db6:	e8 06 ff ff ff       	call   800cc1 <sys_env_set_pgfault_upcall>
  800dbb:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800dbe:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc1:	a3 0c 40 80 00       	mov    %eax,0x80400c
}
  800dc6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dc9:	c9                   	leave  
  800dca:	c3                   	ret    

00800dcb <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800dcb:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800dcc:	a1 0c 40 80 00       	mov    0x80400c,%eax
	call *%eax
  800dd1:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800dd3:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	# My method is different. Copy the values to the other stack
	# in a convinient way, and then pop everything.
	movl %esp, %ebp		# ebp refers to the exception stack
  800dd6:	89 e5                	mov    %esp,%ebp
	movl 48(%ebp), %esp 	# go to other stack
  800dd8:	8b 65 30             	mov    0x30(%ebp),%esp

	pushl 40(%ebp)		# eip - ORDER SWITCHED WITH EFLAGS
  800ddb:	ff 75 28             	pushl  0x28(%ebp)
	pushl 44(%ebp)      	# eflags
  800dde:	ff 75 2c             	pushl  0x2c(%ebp)
	pushl 36(%ebp)		# all the 8 remaining regs
  800de1:	ff 75 24             	pushl  0x24(%ebp)
	pushl 32(%ebp)
  800de4:	ff 75 20             	pushl  0x20(%ebp)
	pushl 28(%ebp)
  800de7:	ff 75 1c             	pushl  0x1c(%ebp)
	pushl 24(%ebp)
  800dea:	ff 75 18             	pushl  0x18(%ebp)
	pushl 20(%ebp)
  800ded:	ff 75 14             	pushl  0x14(%ebp)
	pushl 16(%ebp)
  800df0:	ff 75 10             	pushl  0x10(%ebp)
	pushl 12(%ebp)
  800df3:	ff 75 0c             	pushl  0xc(%ebp)
	pushl 8(%ebp)
  800df6:	ff 75 08             	pushl  0x8(%ebp)

	popal			# now just pop everything!
  800df9:	61                   	popa   
	popfl
  800dfa:	9d                   	popf   
	ret
  800dfb:	c3                   	ret    

00800dfc <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800dfc:	55                   	push   %ebp
  800dfd:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800dff:	8b 45 08             	mov    0x8(%ebp),%eax
  800e02:	05 00 00 00 30       	add    $0x30000000,%eax
  800e07:	c1 e8 0c             	shr    $0xc,%eax
}
  800e0a:	5d                   	pop    %ebp
  800e0b:	c3                   	ret    

00800e0c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e0c:	55                   	push   %ebp
  800e0d:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e12:	05 00 00 00 30       	add    $0x30000000,%eax
  800e17:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e1c:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e21:	5d                   	pop    %ebp
  800e22:	c3                   	ret    

00800e23 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e23:	55                   	push   %ebp
  800e24:	89 e5                	mov    %esp,%ebp
  800e26:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e29:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e2e:	89 c2                	mov    %eax,%edx
  800e30:	c1 ea 16             	shr    $0x16,%edx
  800e33:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e3a:	f6 c2 01             	test   $0x1,%dl
  800e3d:	74 11                	je     800e50 <fd_alloc+0x2d>
  800e3f:	89 c2                	mov    %eax,%edx
  800e41:	c1 ea 0c             	shr    $0xc,%edx
  800e44:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e4b:	f6 c2 01             	test   $0x1,%dl
  800e4e:	75 09                	jne    800e59 <fd_alloc+0x36>
			*fd_store = fd;
  800e50:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e52:	b8 00 00 00 00       	mov    $0x0,%eax
  800e57:	eb 17                	jmp    800e70 <fd_alloc+0x4d>
  800e59:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e5e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e63:	75 c9                	jne    800e2e <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e65:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e6b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e70:	5d                   	pop    %ebp
  800e71:	c3                   	ret    

00800e72 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e72:	55                   	push   %ebp
  800e73:	89 e5                	mov    %esp,%ebp
  800e75:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e78:	83 f8 1f             	cmp    $0x1f,%eax
  800e7b:	77 36                	ja     800eb3 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e7d:	c1 e0 0c             	shl    $0xc,%eax
  800e80:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e85:	89 c2                	mov    %eax,%edx
  800e87:	c1 ea 16             	shr    $0x16,%edx
  800e8a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e91:	f6 c2 01             	test   $0x1,%dl
  800e94:	74 24                	je     800eba <fd_lookup+0x48>
  800e96:	89 c2                	mov    %eax,%edx
  800e98:	c1 ea 0c             	shr    $0xc,%edx
  800e9b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ea2:	f6 c2 01             	test   $0x1,%dl
  800ea5:	74 1a                	je     800ec1 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800ea7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800eaa:	89 02                	mov    %eax,(%edx)
	return 0;
  800eac:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb1:	eb 13                	jmp    800ec6 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800eb3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800eb8:	eb 0c                	jmp    800ec6 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800eba:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ebf:	eb 05                	jmp    800ec6 <fd_lookup+0x54>
  800ec1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800ec6:	5d                   	pop    %ebp
  800ec7:	c3                   	ret    

00800ec8 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ec8:	55                   	push   %ebp
  800ec9:	89 e5                	mov    %esp,%ebp
  800ecb:	83 ec 08             	sub    $0x8,%esp
  800ece:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ed1:	ba 8c 27 80 00       	mov    $0x80278c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800ed6:	eb 13                	jmp    800eeb <dev_lookup+0x23>
  800ed8:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800edb:	39 08                	cmp    %ecx,(%eax)
  800edd:	75 0c                	jne    800eeb <dev_lookup+0x23>
			*dev = devtab[i];
  800edf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee2:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ee4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee9:	eb 2e                	jmp    800f19 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800eeb:	8b 02                	mov    (%edx),%eax
  800eed:	85 c0                	test   %eax,%eax
  800eef:	75 e7                	jne    800ed8 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ef1:	a1 08 40 80 00       	mov    0x804008,%eax
  800ef6:	8b 40 48             	mov    0x48(%eax),%eax
  800ef9:	83 ec 04             	sub    $0x4,%esp
  800efc:	51                   	push   %ecx
  800efd:	50                   	push   %eax
  800efe:	68 0c 27 80 00       	push   $0x80270c
  800f03:	e8 e6 f2 ff ff       	call   8001ee <cprintf>
	*dev = 0;
  800f08:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f0b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f11:	83 c4 10             	add    $0x10,%esp
  800f14:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f19:	c9                   	leave  
  800f1a:	c3                   	ret    

00800f1b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f1b:	55                   	push   %ebp
  800f1c:	89 e5                	mov    %esp,%ebp
  800f1e:	56                   	push   %esi
  800f1f:	53                   	push   %ebx
  800f20:	83 ec 10             	sub    $0x10,%esp
  800f23:	8b 75 08             	mov    0x8(%ebp),%esi
  800f26:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f29:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f2c:	50                   	push   %eax
  800f2d:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f33:	c1 e8 0c             	shr    $0xc,%eax
  800f36:	50                   	push   %eax
  800f37:	e8 36 ff ff ff       	call   800e72 <fd_lookup>
  800f3c:	83 c4 08             	add    $0x8,%esp
  800f3f:	85 c0                	test   %eax,%eax
  800f41:	78 05                	js     800f48 <fd_close+0x2d>
	    || fd != fd2)
  800f43:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f46:	74 0c                	je     800f54 <fd_close+0x39>
		return (must_exist ? r : 0);
  800f48:	84 db                	test   %bl,%bl
  800f4a:	ba 00 00 00 00       	mov    $0x0,%edx
  800f4f:	0f 44 c2             	cmove  %edx,%eax
  800f52:	eb 41                	jmp    800f95 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f54:	83 ec 08             	sub    $0x8,%esp
  800f57:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f5a:	50                   	push   %eax
  800f5b:	ff 36                	pushl  (%esi)
  800f5d:	e8 66 ff ff ff       	call   800ec8 <dev_lookup>
  800f62:	89 c3                	mov    %eax,%ebx
  800f64:	83 c4 10             	add    $0x10,%esp
  800f67:	85 c0                	test   %eax,%eax
  800f69:	78 1a                	js     800f85 <fd_close+0x6a>
		if (dev->dev_close)
  800f6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f6e:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f71:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f76:	85 c0                	test   %eax,%eax
  800f78:	74 0b                	je     800f85 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f7a:	83 ec 0c             	sub    $0xc,%esp
  800f7d:	56                   	push   %esi
  800f7e:	ff d0                	call   *%eax
  800f80:	89 c3                	mov    %eax,%ebx
  800f82:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f85:	83 ec 08             	sub    $0x8,%esp
  800f88:	56                   	push   %esi
  800f89:	6a 00                	push   $0x0
  800f8b:	e8 6b fc ff ff       	call   800bfb <sys_page_unmap>
	return r;
  800f90:	83 c4 10             	add    $0x10,%esp
  800f93:	89 d8                	mov    %ebx,%eax
}
  800f95:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f98:	5b                   	pop    %ebx
  800f99:	5e                   	pop    %esi
  800f9a:	5d                   	pop    %ebp
  800f9b:	c3                   	ret    

00800f9c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f9c:	55                   	push   %ebp
  800f9d:	89 e5                	mov    %esp,%ebp
  800f9f:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fa2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fa5:	50                   	push   %eax
  800fa6:	ff 75 08             	pushl  0x8(%ebp)
  800fa9:	e8 c4 fe ff ff       	call   800e72 <fd_lookup>
  800fae:	83 c4 08             	add    $0x8,%esp
  800fb1:	85 c0                	test   %eax,%eax
  800fb3:	78 10                	js     800fc5 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800fb5:	83 ec 08             	sub    $0x8,%esp
  800fb8:	6a 01                	push   $0x1
  800fba:	ff 75 f4             	pushl  -0xc(%ebp)
  800fbd:	e8 59 ff ff ff       	call   800f1b <fd_close>
  800fc2:	83 c4 10             	add    $0x10,%esp
}
  800fc5:	c9                   	leave  
  800fc6:	c3                   	ret    

00800fc7 <close_all>:

void
close_all(void)
{
  800fc7:	55                   	push   %ebp
  800fc8:	89 e5                	mov    %esp,%ebp
  800fca:	53                   	push   %ebx
  800fcb:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fce:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fd3:	83 ec 0c             	sub    $0xc,%esp
  800fd6:	53                   	push   %ebx
  800fd7:	e8 c0 ff ff ff       	call   800f9c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800fdc:	83 c3 01             	add    $0x1,%ebx
  800fdf:	83 c4 10             	add    $0x10,%esp
  800fe2:	83 fb 20             	cmp    $0x20,%ebx
  800fe5:	75 ec                	jne    800fd3 <close_all+0xc>
		close(i);
}
  800fe7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fea:	c9                   	leave  
  800feb:	c3                   	ret    

00800fec <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800fec:	55                   	push   %ebp
  800fed:	89 e5                	mov    %esp,%ebp
  800fef:	57                   	push   %edi
  800ff0:	56                   	push   %esi
  800ff1:	53                   	push   %ebx
  800ff2:	83 ec 2c             	sub    $0x2c,%esp
  800ff5:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800ff8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ffb:	50                   	push   %eax
  800ffc:	ff 75 08             	pushl  0x8(%ebp)
  800fff:	e8 6e fe ff ff       	call   800e72 <fd_lookup>
  801004:	83 c4 08             	add    $0x8,%esp
  801007:	85 c0                	test   %eax,%eax
  801009:	0f 88 c1 00 00 00    	js     8010d0 <dup+0xe4>
		return r;
	close(newfdnum);
  80100f:	83 ec 0c             	sub    $0xc,%esp
  801012:	56                   	push   %esi
  801013:	e8 84 ff ff ff       	call   800f9c <close>

	newfd = INDEX2FD(newfdnum);
  801018:	89 f3                	mov    %esi,%ebx
  80101a:	c1 e3 0c             	shl    $0xc,%ebx
  80101d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801023:	83 c4 04             	add    $0x4,%esp
  801026:	ff 75 e4             	pushl  -0x1c(%ebp)
  801029:	e8 de fd ff ff       	call   800e0c <fd2data>
  80102e:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801030:	89 1c 24             	mov    %ebx,(%esp)
  801033:	e8 d4 fd ff ff       	call   800e0c <fd2data>
  801038:	83 c4 10             	add    $0x10,%esp
  80103b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80103e:	89 f8                	mov    %edi,%eax
  801040:	c1 e8 16             	shr    $0x16,%eax
  801043:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80104a:	a8 01                	test   $0x1,%al
  80104c:	74 37                	je     801085 <dup+0x99>
  80104e:	89 f8                	mov    %edi,%eax
  801050:	c1 e8 0c             	shr    $0xc,%eax
  801053:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80105a:	f6 c2 01             	test   $0x1,%dl
  80105d:	74 26                	je     801085 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80105f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801066:	83 ec 0c             	sub    $0xc,%esp
  801069:	25 07 0e 00 00       	and    $0xe07,%eax
  80106e:	50                   	push   %eax
  80106f:	ff 75 d4             	pushl  -0x2c(%ebp)
  801072:	6a 00                	push   $0x0
  801074:	57                   	push   %edi
  801075:	6a 00                	push   $0x0
  801077:	e8 3d fb ff ff       	call   800bb9 <sys_page_map>
  80107c:	89 c7                	mov    %eax,%edi
  80107e:	83 c4 20             	add    $0x20,%esp
  801081:	85 c0                	test   %eax,%eax
  801083:	78 2e                	js     8010b3 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801085:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801088:	89 d0                	mov    %edx,%eax
  80108a:	c1 e8 0c             	shr    $0xc,%eax
  80108d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801094:	83 ec 0c             	sub    $0xc,%esp
  801097:	25 07 0e 00 00       	and    $0xe07,%eax
  80109c:	50                   	push   %eax
  80109d:	53                   	push   %ebx
  80109e:	6a 00                	push   $0x0
  8010a0:	52                   	push   %edx
  8010a1:	6a 00                	push   $0x0
  8010a3:	e8 11 fb ff ff       	call   800bb9 <sys_page_map>
  8010a8:	89 c7                	mov    %eax,%edi
  8010aa:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8010ad:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010af:	85 ff                	test   %edi,%edi
  8010b1:	79 1d                	jns    8010d0 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010b3:	83 ec 08             	sub    $0x8,%esp
  8010b6:	53                   	push   %ebx
  8010b7:	6a 00                	push   $0x0
  8010b9:	e8 3d fb ff ff       	call   800bfb <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010be:	83 c4 08             	add    $0x8,%esp
  8010c1:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010c4:	6a 00                	push   $0x0
  8010c6:	e8 30 fb ff ff       	call   800bfb <sys_page_unmap>
	return r;
  8010cb:	83 c4 10             	add    $0x10,%esp
  8010ce:	89 f8                	mov    %edi,%eax
}
  8010d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010d3:	5b                   	pop    %ebx
  8010d4:	5e                   	pop    %esi
  8010d5:	5f                   	pop    %edi
  8010d6:	5d                   	pop    %ebp
  8010d7:	c3                   	ret    

008010d8 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010d8:	55                   	push   %ebp
  8010d9:	89 e5                	mov    %esp,%ebp
  8010db:	53                   	push   %ebx
  8010dc:	83 ec 14             	sub    $0x14,%esp
  8010df:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010e2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010e5:	50                   	push   %eax
  8010e6:	53                   	push   %ebx
  8010e7:	e8 86 fd ff ff       	call   800e72 <fd_lookup>
  8010ec:	83 c4 08             	add    $0x8,%esp
  8010ef:	89 c2                	mov    %eax,%edx
  8010f1:	85 c0                	test   %eax,%eax
  8010f3:	78 6d                	js     801162 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010f5:	83 ec 08             	sub    $0x8,%esp
  8010f8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010fb:	50                   	push   %eax
  8010fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010ff:	ff 30                	pushl  (%eax)
  801101:	e8 c2 fd ff ff       	call   800ec8 <dev_lookup>
  801106:	83 c4 10             	add    $0x10,%esp
  801109:	85 c0                	test   %eax,%eax
  80110b:	78 4c                	js     801159 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80110d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801110:	8b 42 08             	mov    0x8(%edx),%eax
  801113:	83 e0 03             	and    $0x3,%eax
  801116:	83 f8 01             	cmp    $0x1,%eax
  801119:	75 21                	jne    80113c <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80111b:	a1 08 40 80 00       	mov    0x804008,%eax
  801120:	8b 40 48             	mov    0x48(%eax),%eax
  801123:	83 ec 04             	sub    $0x4,%esp
  801126:	53                   	push   %ebx
  801127:	50                   	push   %eax
  801128:	68 50 27 80 00       	push   $0x802750
  80112d:	e8 bc f0 ff ff       	call   8001ee <cprintf>
		return -E_INVAL;
  801132:	83 c4 10             	add    $0x10,%esp
  801135:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80113a:	eb 26                	jmp    801162 <read+0x8a>
	}
	if (!dev->dev_read)
  80113c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80113f:	8b 40 08             	mov    0x8(%eax),%eax
  801142:	85 c0                	test   %eax,%eax
  801144:	74 17                	je     80115d <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801146:	83 ec 04             	sub    $0x4,%esp
  801149:	ff 75 10             	pushl  0x10(%ebp)
  80114c:	ff 75 0c             	pushl  0xc(%ebp)
  80114f:	52                   	push   %edx
  801150:	ff d0                	call   *%eax
  801152:	89 c2                	mov    %eax,%edx
  801154:	83 c4 10             	add    $0x10,%esp
  801157:	eb 09                	jmp    801162 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801159:	89 c2                	mov    %eax,%edx
  80115b:	eb 05                	jmp    801162 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80115d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801162:	89 d0                	mov    %edx,%eax
  801164:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801167:	c9                   	leave  
  801168:	c3                   	ret    

00801169 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801169:	55                   	push   %ebp
  80116a:	89 e5                	mov    %esp,%ebp
  80116c:	57                   	push   %edi
  80116d:	56                   	push   %esi
  80116e:	53                   	push   %ebx
  80116f:	83 ec 0c             	sub    $0xc,%esp
  801172:	8b 7d 08             	mov    0x8(%ebp),%edi
  801175:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801178:	bb 00 00 00 00       	mov    $0x0,%ebx
  80117d:	eb 21                	jmp    8011a0 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80117f:	83 ec 04             	sub    $0x4,%esp
  801182:	89 f0                	mov    %esi,%eax
  801184:	29 d8                	sub    %ebx,%eax
  801186:	50                   	push   %eax
  801187:	89 d8                	mov    %ebx,%eax
  801189:	03 45 0c             	add    0xc(%ebp),%eax
  80118c:	50                   	push   %eax
  80118d:	57                   	push   %edi
  80118e:	e8 45 ff ff ff       	call   8010d8 <read>
		if (m < 0)
  801193:	83 c4 10             	add    $0x10,%esp
  801196:	85 c0                	test   %eax,%eax
  801198:	78 10                	js     8011aa <readn+0x41>
			return m;
		if (m == 0)
  80119a:	85 c0                	test   %eax,%eax
  80119c:	74 0a                	je     8011a8 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80119e:	01 c3                	add    %eax,%ebx
  8011a0:	39 f3                	cmp    %esi,%ebx
  8011a2:	72 db                	jb     80117f <readn+0x16>
  8011a4:	89 d8                	mov    %ebx,%eax
  8011a6:	eb 02                	jmp    8011aa <readn+0x41>
  8011a8:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8011aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011ad:	5b                   	pop    %ebx
  8011ae:	5e                   	pop    %esi
  8011af:	5f                   	pop    %edi
  8011b0:	5d                   	pop    %ebp
  8011b1:	c3                   	ret    

008011b2 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011b2:	55                   	push   %ebp
  8011b3:	89 e5                	mov    %esp,%ebp
  8011b5:	53                   	push   %ebx
  8011b6:	83 ec 14             	sub    $0x14,%esp
  8011b9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011bc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011bf:	50                   	push   %eax
  8011c0:	53                   	push   %ebx
  8011c1:	e8 ac fc ff ff       	call   800e72 <fd_lookup>
  8011c6:	83 c4 08             	add    $0x8,%esp
  8011c9:	89 c2                	mov    %eax,%edx
  8011cb:	85 c0                	test   %eax,%eax
  8011cd:	78 68                	js     801237 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011cf:	83 ec 08             	sub    $0x8,%esp
  8011d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011d5:	50                   	push   %eax
  8011d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011d9:	ff 30                	pushl  (%eax)
  8011db:	e8 e8 fc ff ff       	call   800ec8 <dev_lookup>
  8011e0:	83 c4 10             	add    $0x10,%esp
  8011e3:	85 c0                	test   %eax,%eax
  8011e5:	78 47                	js     80122e <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011ea:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011ee:	75 21                	jne    801211 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011f0:	a1 08 40 80 00       	mov    0x804008,%eax
  8011f5:	8b 40 48             	mov    0x48(%eax),%eax
  8011f8:	83 ec 04             	sub    $0x4,%esp
  8011fb:	53                   	push   %ebx
  8011fc:	50                   	push   %eax
  8011fd:	68 6c 27 80 00       	push   $0x80276c
  801202:	e8 e7 ef ff ff       	call   8001ee <cprintf>
		return -E_INVAL;
  801207:	83 c4 10             	add    $0x10,%esp
  80120a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80120f:	eb 26                	jmp    801237 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801211:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801214:	8b 52 0c             	mov    0xc(%edx),%edx
  801217:	85 d2                	test   %edx,%edx
  801219:	74 17                	je     801232 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80121b:	83 ec 04             	sub    $0x4,%esp
  80121e:	ff 75 10             	pushl  0x10(%ebp)
  801221:	ff 75 0c             	pushl  0xc(%ebp)
  801224:	50                   	push   %eax
  801225:	ff d2                	call   *%edx
  801227:	89 c2                	mov    %eax,%edx
  801229:	83 c4 10             	add    $0x10,%esp
  80122c:	eb 09                	jmp    801237 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80122e:	89 c2                	mov    %eax,%edx
  801230:	eb 05                	jmp    801237 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801232:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801237:	89 d0                	mov    %edx,%eax
  801239:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80123c:	c9                   	leave  
  80123d:	c3                   	ret    

0080123e <seek>:

int
seek(int fdnum, off_t offset)
{
  80123e:	55                   	push   %ebp
  80123f:	89 e5                	mov    %esp,%ebp
  801241:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801244:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801247:	50                   	push   %eax
  801248:	ff 75 08             	pushl  0x8(%ebp)
  80124b:	e8 22 fc ff ff       	call   800e72 <fd_lookup>
  801250:	83 c4 08             	add    $0x8,%esp
  801253:	85 c0                	test   %eax,%eax
  801255:	78 0e                	js     801265 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801257:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80125a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80125d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801260:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801265:	c9                   	leave  
  801266:	c3                   	ret    

00801267 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801267:	55                   	push   %ebp
  801268:	89 e5                	mov    %esp,%ebp
  80126a:	53                   	push   %ebx
  80126b:	83 ec 14             	sub    $0x14,%esp
  80126e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801271:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801274:	50                   	push   %eax
  801275:	53                   	push   %ebx
  801276:	e8 f7 fb ff ff       	call   800e72 <fd_lookup>
  80127b:	83 c4 08             	add    $0x8,%esp
  80127e:	89 c2                	mov    %eax,%edx
  801280:	85 c0                	test   %eax,%eax
  801282:	78 65                	js     8012e9 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801284:	83 ec 08             	sub    $0x8,%esp
  801287:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80128a:	50                   	push   %eax
  80128b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80128e:	ff 30                	pushl  (%eax)
  801290:	e8 33 fc ff ff       	call   800ec8 <dev_lookup>
  801295:	83 c4 10             	add    $0x10,%esp
  801298:	85 c0                	test   %eax,%eax
  80129a:	78 44                	js     8012e0 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80129c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80129f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012a3:	75 21                	jne    8012c6 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012a5:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012aa:	8b 40 48             	mov    0x48(%eax),%eax
  8012ad:	83 ec 04             	sub    $0x4,%esp
  8012b0:	53                   	push   %ebx
  8012b1:	50                   	push   %eax
  8012b2:	68 2c 27 80 00       	push   $0x80272c
  8012b7:	e8 32 ef ff ff       	call   8001ee <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012bc:	83 c4 10             	add    $0x10,%esp
  8012bf:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012c4:	eb 23                	jmp    8012e9 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8012c6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012c9:	8b 52 18             	mov    0x18(%edx),%edx
  8012cc:	85 d2                	test   %edx,%edx
  8012ce:	74 14                	je     8012e4 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012d0:	83 ec 08             	sub    $0x8,%esp
  8012d3:	ff 75 0c             	pushl  0xc(%ebp)
  8012d6:	50                   	push   %eax
  8012d7:	ff d2                	call   *%edx
  8012d9:	89 c2                	mov    %eax,%edx
  8012db:	83 c4 10             	add    $0x10,%esp
  8012de:	eb 09                	jmp    8012e9 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012e0:	89 c2                	mov    %eax,%edx
  8012e2:	eb 05                	jmp    8012e9 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012e4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8012e9:	89 d0                	mov    %edx,%eax
  8012eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012ee:	c9                   	leave  
  8012ef:	c3                   	ret    

008012f0 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012f0:	55                   	push   %ebp
  8012f1:	89 e5                	mov    %esp,%ebp
  8012f3:	53                   	push   %ebx
  8012f4:	83 ec 14             	sub    $0x14,%esp
  8012f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012fa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012fd:	50                   	push   %eax
  8012fe:	ff 75 08             	pushl  0x8(%ebp)
  801301:	e8 6c fb ff ff       	call   800e72 <fd_lookup>
  801306:	83 c4 08             	add    $0x8,%esp
  801309:	89 c2                	mov    %eax,%edx
  80130b:	85 c0                	test   %eax,%eax
  80130d:	78 58                	js     801367 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80130f:	83 ec 08             	sub    $0x8,%esp
  801312:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801315:	50                   	push   %eax
  801316:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801319:	ff 30                	pushl  (%eax)
  80131b:	e8 a8 fb ff ff       	call   800ec8 <dev_lookup>
  801320:	83 c4 10             	add    $0x10,%esp
  801323:	85 c0                	test   %eax,%eax
  801325:	78 37                	js     80135e <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801327:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80132a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80132e:	74 32                	je     801362 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801330:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801333:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80133a:	00 00 00 
	stat->st_isdir = 0;
  80133d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801344:	00 00 00 
	stat->st_dev = dev;
  801347:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80134d:	83 ec 08             	sub    $0x8,%esp
  801350:	53                   	push   %ebx
  801351:	ff 75 f0             	pushl  -0x10(%ebp)
  801354:	ff 50 14             	call   *0x14(%eax)
  801357:	89 c2                	mov    %eax,%edx
  801359:	83 c4 10             	add    $0x10,%esp
  80135c:	eb 09                	jmp    801367 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80135e:	89 c2                	mov    %eax,%edx
  801360:	eb 05                	jmp    801367 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801362:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801367:	89 d0                	mov    %edx,%eax
  801369:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80136c:	c9                   	leave  
  80136d:	c3                   	ret    

0080136e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80136e:	55                   	push   %ebp
  80136f:	89 e5                	mov    %esp,%ebp
  801371:	56                   	push   %esi
  801372:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801373:	83 ec 08             	sub    $0x8,%esp
  801376:	6a 00                	push   $0x0
  801378:	ff 75 08             	pushl  0x8(%ebp)
  80137b:	e8 0c 02 00 00       	call   80158c <open>
  801380:	89 c3                	mov    %eax,%ebx
  801382:	83 c4 10             	add    $0x10,%esp
  801385:	85 c0                	test   %eax,%eax
  801387:	78 1b                	js     8013a4 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801389:	83 ec 08             	sub    $0x8,%esp
  80138c:	ff 75 0c             	pushl  0xc(%ebp)
  80138f:	50                   	push   %eax
  801390:	e8 5b ff ff ff       	call   8012f0 <fstat>
  801395:	89 c6                	mov    %eax,%esi
	close(fd);
  801397:	89 1c 24             	mov    %ebx,(%esp)
  80139a:	e8 fd fb ff ff       	call   800f9c <close>
	return r;
  80139f:	83 c4 10             	add    $0x10,%esp
  8013a2:	89 f0                	mov    %esi,%eax
}
  8013a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013a7:	5b                   	pop    %ebx
  8013a8:	5e                   	pop    %esi
  8013a9:	5d                   	pop    %ebp
  8013aa:	c3                   	ret    

008013ab <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013ab:	55                   	push   %ebp
  8013ac:	89 e5                	mov    %esp,%ebp
  8013ae:	56                   	push   %esi
  8013af:	53                   	push   %ebx
  8013b0:	89 c6                	mov    %eax,%esi
  8013b2:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013b4:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013bb:	75 12                	jne    8013cf <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013bd:	83 ec 0c             	sub    $0xc,%esp
  8013c0:	6a 01                	push   $0x1
  8013c2:	e8 6c 0c 00 00       	call   802033 <ipc_find_env>
  8013c7:	a3 00 40 80 00       	mov    %eax,0x804000
  8013cc:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013cf:	6a 07                	push   $0x7
  8013d1:	68 00 50 80 00       	push   $0x805000
  8013d6:	56                   	push   %esi
  8013d7:	ff 35 00 40 80 00    	pushl  0x804000
  8013dd:	e8 fd 0b 00 00       	call   801fdf <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013e2:	83 c4 0c             	add    $0xc,%esp
  8013e5:	6a 00                	push   $0x0
  8013e7:	53                   	push   %ebx
  8013e8:	6a 00                	push   $0x0
  8013ea:	e8 87 0b 00 00       	call   801f76 <ipc_recv>
}
  8013ef:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013f2:	5b                   	pop    %ebx
  8013f3:	5e                   	pop    %esi
  8013f4:	5d                   	pop    %ebp
  8013f5:	c3                   	ret    

008013f6 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013f6:	55                   	push   %ebp
  8013f7:	89 e5                	mov    %esp,%ebp
  8013f9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ff:	8b 40 0c             	mov    0xc(%eax),%eax
  801402:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801407:	8b 45 0c             	mov    0xc(%ebp),%eax
  80140a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80140f:	ba 00 00 00 00       	mov    $0x0,%edx
  801414:	b8 02 00 00 00       	mov    $0x2,%eax
  801419:	e8 8d ff ff ff       	call   8013ab <fsipc>
}
  80141e:	c9                   	leave  
  80141f:	c3                   	ret    

00801420 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801420:	55                   	push   %ebp
  801421:	89 e5                	mov    %esp,%ebp
  801423:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801426:	8b 45 08             	mov    0x8(%ebp),%eax
  801429:	8b 40 0c             	mov    0xc(%eax),%eax
  80142c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801431:	ba 00 00 00 00       	mov    $0x0,%edx
  801436:	b8 06 00 00 00       	mov    $0x6,%eax
  80143b:	e8 6b ff ff ff       	call   8013ab <fsipc>
}
  801440:	c9                   	leave  
  801441:	c3                   	ret    

00801442 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801442:	55                   	push   %ebp
  801443:	89 e5                	mov    %esp,%ebp
  801445:	53                   	push   %ebx
  801446:	83 ec 04             	sub    $0x4,%esp
  801449:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80144c:	8b 45 08             	mov    0x8(%ebp),%eax
  80144f:	8b 40 0c             	mov    0xc(%eax),%eax
  801452:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801457:	ba 00 00 00 00       	mov    $0x0,%edx
  80145c:	b8 05 00 00 00       	mov    $0x5,%eax
  801461:	e8 45 ff ff ff       	call   8013ab <fsipc>
  801466:	85 c0                	test   %eax,%eax
  801468:	78 2c                	js     801496 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80146a:	83 ec 08             	sub    $0x8,%esp
  80146d:	68 00 50 80 00       	push   $0x805000
  801472:	53                   	push   %ebx
  801473:	e8 fb f2 ff ff       	call   800773 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801478:	a1 80 50 80 00       	mov    0x805080,%eax
  80147d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801483:	a1 84 50 80 00       	mov    0x805084,%eax
  801488:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80148e:	83 c4 10             	add    $0x10,%esp
  801491:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801496:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801499:	c9                   	leave  
  80149a:	c3                   	ret    

0080149b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80149b:	55                   	push   %ebp
  80149c:	89 e5                	mov    %esp,%ebp
  80149e:	53                   	push   %ebx
  80149f:	83 ec 08             	sub    $0x8,%esp
  8014a2:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8014a8:	8b 52 0c             	mov    0xc(%edx),%edx
  8014ab:	89 15 00 50 80 00    	mov    %edx,0x805000
  8014b1:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8014b6:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  8014bb:	0f 46 d8             	cmovbe %eax,%ebx
	
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  8014be:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  8014c4:	53                   	push   %ebx
  8014c5:	ff 75 0c             	pushl  0xc(%ebp)
  8014c8:	68 08 50 80 00       	push   $0x805008
  8014cd:	e8 33 f4 ff ff       	call   800905 <memmove>

	
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) 
  8014d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8014d7:	b8 04 00 00 00       	mov    $0x4,%eax
  8014dc:	e8 ca fe ff ff       	call   8013ab <fsipc>
  8014e1:	83 c4 10             	add    $0x10,%esp
  8014e4:	85 c0                	test   %eax,%eax
  8014e6:	78 1d                	js     801505 <devfile_write+0x6a>
		return r;
	assert(r <= n_real); 
  8014e8:	39 d8                	cmp    %ebx,%eax
  8014ea:	76 19                	jbe    801505 <devfile_write+0x6a>
  8014ec:	68 a0 27 80 00       	push   $0x8027a0
  8014f1:	68 ac 27 80 00       	push   $0x8027ac
  8014f6:	68 a3 00 00 00       	push   $0xa3
  8014fb:	68 c1 27 80 00       	push   $0x8027c1
  801500:	e8 10 ec ff ff       	call   800115 <_panic>
	return r;
}
  801505:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801508:	c9                   	leave  
  801509:	c3                   	ret    

0080150a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80150a:	55                   	push   %ebp
  80150b:	89 e5                	mov    %esp,%ebp
  80150d:	56                   	push   %esi
  80150e:	53                   	push   %ebx
  80150f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801512:	8b 45 08             	mov    0x8(%ebp),%eax
  801515:	8b 40 0c             	mov    0xc(%eax),%eax
  801518:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80151d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801523:	ba 00 00 00 00       	mov    $0x0,%edx
  801528:	b8 03 00 00 00       	mov    $0x3,%eax
  80152d:	e8 79 fe ff ff       	call   8013ab <fsipc>
  801532:	89 c3                	mov    %eax,%ebx
  801534:	85 c0                	test   %eax,%eax
  801536:	78 4b                	js     801583 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801538:	39 c6                	cmp    %eax,%esi
  80153a:	73 16                	jae    801552 <devfile_read+0x48>
  80153c:	68 cc 27 80 00       	push   $0x8027cc
  801541:	68 ac 27 80 00       	push   $0x8027ac
  801546:	6a 7c                	push   $0x7c
  801548:	68 c1 27 80 00       	push   $0x8027c1
  80154d:	e8 c3 eb ff ff       	call   800115 <_panic>
	assert(r <= PGSIZE);
  801552:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801557:	7e 16                	jle    80156f <devfile_read+0x65>
  801559:	68 d3 27 80 00       	push   $0x8027d3
  80155e:	68 ac 27 80 00       	push   $0x8027ac
  801563:	6a 7d                	push   $0x7d
  801565:	68 c1 27 80 00       	push   $0x8027c1
  80156a:	e8 a6 eb ff ff       	call   800115 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80156f:	83 ec 04             	sub    $0x4,%esp
  801572:	50                   	push   %eax
  801573:	68 00 50 80 00       	push   $0x805000
  801578:	ff 75 0c             	pushl  0xc(%ebp)
  80157b:	e8 85 f3 ff ff       	call   800905 <memmove>
	return r;
  801580:	83 c4 10             	add    $0x10,%esp
}
  801583:	89 d8                	mov    %ebx,%eax
  801585:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801588:	5b                   	pop    %ebx
  801589:	5e                   	pop    %esi
  80158a:	5d                   	pop    %ebp
  80158b:	c3                   	ret    

0080158c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80158c:	55                   	push   %ebp
  80158d:	89 e5                	mov    %esp,%ebp
  80158f:	53                   	push   %ebx
  801590:	83 ec 20             	sub    $0x20,%esp
  801593:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801596:	53                   	push   %ebx
  801597:	e8 9e f1 ff ff       	call   80073a <strlen>
  80159c:	83 c4 10             	add    $0x10,%esp
  80159f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015a4:	7f 67                	jg     80160d <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015a6:	83 ec 0c             	sub    $0xc,%esp
  8015a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ac:	50                   	push   %eax
  8015ad:	e8 71 f8 ff ff       	call   800e23 <fd_alloc>
  8015b2:	83 c4 10             	add    $0x10,%esp
		return r;
  8015b5:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015b7:	85 c0                	test   %eax,%eax
  8015b9:	78 57                	js     801612 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015bb:	83 ec 08             	sub    $0x8,%esp
  8015be:	53                   	push   %ebx
  8015bf:	68 00 50 80 00       	push   $0x805000
  8015c4:	e8 aa f1 ff ff       	call   800773 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015cc:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015d1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015d4:	b8 01 00 00 00       	mov    $0x1,%eax
  8015d9:	e8 cd fd ff ff       	call   8013ab <fsipc>
  8015de:	89 c3                	mov    %eax,%ebx
  8015e0:	83 c4 10             	add    $0x10,%esp
  8015e3:	85 c0                	test   %eax,%eax
  8015e5:	79 14                	jns    8015fb <open+0x6f>
		fd_close(fd, 0);
  8015e7:	83 ec 08             	sub    $0x8,%esp
  8015ea:	6a 00                	push   $0x0
  8015ec:	ff 75 f4             	pushl  -0xc(%ebp)
  8015ef:	e8 27 f9 ff ff       	call   800f1b <fd_close>
		return r;
  8015f4:	83 c4 10             	add    $0x10,%esp
  8015f7:	89 da                	mov    %ebx,%edx
  8015f9:	eb 17                	jmp    801612 <open+0x86>
	}

	return fd2num(fd);
  8015fb:	83 ec 0c             	sub    $0xc,%esp
  8015fe:	ff 75 f4             	pushl  -0xc(%ebp)
  801601:	e8 f6 f7 ff ff       	call   800dfc <fd2num>
  801606:	89 c2                	mov    %eax,%edx
  801608:	83 c4 10             	add    $0x10,%esp
  80160b:	eb 05                	jmp    801612 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80160d:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801612:	89 d0                	mov    %edx,%eax
  801614:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801617:	c9                   	leave  
  801618:	c3                   	ret    

00801619 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801619:	55                   	push   %ebp
  80161a:	89 e5                	mov    %esp,%ebp
  80161c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80161f:	ba 00 00 00 00       	mov    $0x0,%edx
  801624:	b8 08 00 00 00       	mov    $0x8,%eax
  801629:	e8 7d fd ff ff       	call   8013ab <fsipc>
}
  80162e:	c9                   	leave  
  80162f:	c3                   	ret    

00801630 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801630:	55                   	push   %ebp
  801631:	89 e5                	mov    %esp,%ebp
  801633:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801636:	68 df 27 80 00       	push   $0x8027df
  80163b:	ff 75 0c             	pushl  0xc(%ebp)
  80163e:	e8 30 f1 ff ff       	call   800773 <strcpy>
	return 0;
}
  801643:	b8 00 00 00 00       	mov    $0x0,%eax
  801648:	c9                   	leave  
  801649:	c3                   	ret    

0080164a <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  80164a:	55                   	push   %ebp
  80164b:	89 e5                	mov    %esp,%ebp
  80164d:	53                   	push   %ebx
  80164e:	83 ec 10             	sub    $0x10,%esp
  801651:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801654:	53                   	push   %ebx
  801655:	e8 12 0a 00 00       	call   80206c <pageref>
  80165a:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  80165d:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801662:	83 f8 01             	cmp    $0x1,%eax
  801665:	75 10                	jne    801677 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801667:	83 ec 0c             	sub    $0xc,%esp
  80166a:	ff 73 0c             	pushl  0xc(%ebx)
  80166d:	e8 c0 02 00 00       	call   801932 <nsipc_close>
  801672:	89 c2                	mov    %eax,%edx
  801674:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801677:	89 d0                	mov    %edx,%eax
  801679:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80167c:	c9                   	leave  
  80167d:	c3                   	ret    

0080167e <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  80167e:	55                   	push   %ebp
  80167f:	89 e5                	mov    %esp,%ebp
  801681:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801684:	6a 00                	push   $0x0
  801686:	ff 75 10             	pushl  0x10(%ebp)
  801689:	ff 75 0c             	pushl  0xc(%ebp)
  80168c:	8b 45 08             	mov    0x8(%ebp),%eax
  80168f:	ff 70 0c             	pushl  0xc(%eax)
  801692:	e8 78 03 00 00       	call   801a0f <nsipc_send>
}
  801697:	c9                   	leave  
  801698:	c3                   	ret    

00801699 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801699:	55                   	push   %ebp
  80169a:	89 e5                	mov    %esp,%ebp
  80169c:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  80169f:	6a 00                	push   $0x0
  8016a1:	ff 75 10             	pushl  0x10(%ebp)
  8016a4:	ff 75 0c             	pushl  0xc(%ebp)
  8016a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8016aa:	ff 70 0c             	pushl  0xc(%eax)
  8016ad:	e8 f1 02 00 00       	call   8019a3 <nsipc_recv>
}
  8016b2:	c9                   	leave  
  8016b3:	c3                   	ret    

008016b4 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8016b4:	55                   	push   %ebp
  8016b5:	89 e5                	mov    %esp,%ebp
  8016b7:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8016ba:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8016bd:	52                   	push   %edx
  8016be:	50                   	push   %eax
  8016bf:	e8 ae f7 ff ff       	call   800e72 <fd_lookup>
  8016c4:	83 c4 10             	add    $0x10,%esp
  8016c7:	85 c0                	test   %eax,%eax
  8016c9:	78 17                	js     8016e2 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8016cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016ce:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  8016d4:	39 08                	cmp    %ecx,(%eax)
  8016d6:	75 05                	jne    8016dd <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8016d8:	8b 40 0c             	mov    0xc(%eax),%eax
  8016db:	eb 05                	jmp    8016e2 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  8016dd:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  8016e2:	c9                   	leave  
  8016e3:	c3                   	ret    

008016e4 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  8016e4:	55                   	push   %ebp
  8016e5:	89 e5                	mov    %esp,%ebp
  8016e7:	56                   	push   %esi
  8016e8:	53                   	push   %ebx
  8016e9:	83 ec 1c             	sub    $0x1c,%esp
  8016ec:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8016ee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016f1:	50                   	push   %eax
  8016f2:	e8 2c f7 ff ff       	call   800e23 <fd_alloc>
  8016f7:	89 c3                	mov    %eax,%ebx
  8016f9:	83 c4 10             	add    $0x10,%esp
  8016fc:	85 c0                	test   %eax,%eax
  8016fe:	78 1b                	js     80171b <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801700:	83 ec 04             	sub    $0x4,%esp
  801703:	68 07 04 00 00       	push   $0x407
  801708:	ff 75 f4             	pushl  -0xc(%ebp)
  80170b:	6a 00                	push   $0x0
  80170d:	e8 64 f4 ff ff       	call   800b76 <sys_page_alloc>
  801712:	89 c3                	mov    %eax,%ebx
  801714:	83 c4 10             	add    $0x10,%esp
  801717:	85 c0                	test   %eax,%eax
  801719:	79 10                	jns    80172b <alloc_sockfd+0x47>
		nsipc_close(sockid);
  80171b:	83 ec 0c             	sub    $0xc,%esp
  80171e:	56                   	push   %esi
  80171f:	e8 0e 02 00 00       	call   801932 <nsipc_close>
		return r;
  801724:	83 c4 10             	add    $0x10,%esp
  801727:	89 d8                	mov    %ebx,%eax
  801729:	eb 24                	jmp    80174f <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  80172b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801731:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801734:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801736:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801739:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801740:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801743:	83 ec 0c             	sub    $0xc,%esp
  801746:	50                   	push   %eax
  801747:	e8 b0 f6 ff ff       	call   800dfc <fd2num>
  80174c:	83 c4 10             	add    $0x10,%esp
}
  80174f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801752:	5b                   	pop    %ebx
  801753:	5e                   	pop    %esi
  801754:	5d                   	pop    %ebp
  801755:	c3                   	ret    

00801756 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801756:	55                   	push   %ebp
  801757:	89 e5                	mov    %esp,%ebp
  801759:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80175c:	8b 45 08             	mov    0x8(%ebp),%eax
  80175f:	e8 50 ff ff ff       	call   8016b4 <fd2sockid>
		return r;
  801764:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801766:	85 c0                	test   %eax,%eax
  801768:	78 1f                	js     801789 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80176a:	83 ec 04             	sub    $0x4,%esp
  80176d:	ff 75 10             	pushl  0x10(%ebp)
  801770:	ff 75 0c             	pushl  0xc(%ebp)
  801773:	50                   	push   %eax
  801774:	e8 12 01 00 00       	call   80188b <nsipc_accept>
  801779:	83 c4 10             	add    $0x10,%esp
		return r;
  80177c:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80177e:	85 c0                	test   %eax,%eax
  801780:	78 07                	js     801789 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801782:	e8 5d ff ff ff       	call   8016e4 <alloc_sockfd>
  801787:	89 c1                	mov    %eax,%ecx
}
  801789:	89 c8                	mov    %ecx,%eax
  80178b:	c9                   	leave  
  80178c:	c3                   	ret    

0080178d <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80178d:	55                   	push   %ebp
  80178e:	89 e5                	mov    %esp,%ebp
  801790:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801793:	8b 45 08             	mov    0x8(%ebp),%eax
  801796:	e8 19 ff ff ff       	call   8016b4 <fd2sockid>
  80179b:	85 c0                	test   %eax,%eax
  80179d:	78 12                	js     8017b1 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  80179f:	83 ec 04             	sub    $0x4,%esp
  8017a2:	ff 75 10             	pushl  0x10(%ebp)
  8017a5:	ff 75 0c             	pushl  0xc(%ebp)
  8017a8:	50                   	push   %eax
  8017a9:	e8 2d 01 00 00       	call   8018db <nsipc_bind>
  8017ae:	83 c4 10             	add    $0x10,%esp
}
  8017b1:	c9                   	leave  
  8017b2:	c3                   	ret    

008017b3 <shutdown>:

int
shutdown(int s, int how)
{
  8017b3:	55                   	push   %ebp
  8017b4:	89 e5                	mov    %esp,%ebp
  8017b6:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8017b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8017bc:	e8 f3 fe ff ff       	call   8016b4 <fd2sockid>
  8017c1:	85 c0                	test   %eax,%eax
  8017c3:	78 0f                	js     8017d4 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8017c5:	83 ec 08             	sub    $0x8,%esp
  8017c8:	ff 75 0c             	pushl  0xc(%ebp)
  8017cb:	50                   	push   %eax
  8017cc:	e8 3f 01 00 00       	call   801910 <nsipc_shutdown>
  8017d1:	83 c4 10             	add    $0x10,%esp
}
  8017d4:	c9                   	leave  
  8017d5:	c3                   	ret    

008017d6 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8017d6:	55                   	push   %ebp
  8017d7:	89 e5                	mov    %esp,%ebp
  8017d9:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8017dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8017df:	e8 d0 fe ff ff       	call   8016b4 <fd2sockid>
  8017e4:	85 c0                	test   %eax,%eax
  8017e6:	78 12                	js     8017fa <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  8017e8:	83 ec 04             	sub    $0x4,%esp
  8017eb:	ff 75 10             	pushl  0x10(%ebp)
  8017ee:	ff 75 0c             	pushl  0xc(%ebp)
  8017f1:	50                   	push   %eax
  8017f2:	e8 55 01 00 00       	call   80194c <nsipc_connect>
  8017f7:	83 c4 10             	add    $0x10,%esp
}
  8017fa:	c9                   	leave  
  8017fb:	c3                   	ret    

008017fc <listen>:

int
listen(int s, int backlog)
{
  8017fc:	55                   	push   %ebp
  8017fd:	89 e5                	mov    %esp,%ebp
  8017ff:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801802:	8b 45 08             	mov    0x8(%ebp),%eax
  801805:	e8 aa fe ff ff       	call   8016b4 <fd2sockid>
  80180a:	85 c0                	test   %eax,%eax
  80180c:	78 0f                	js     80181d <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  80180e:	83 ec 08             	sub    $0x8,%esp
  801811:	ff 75 0c             	pushl  0xc(%ebp)
  801814:	50                   	push   %eax
  801815:	e8 67 01 00 00       	call   801981 <nsipc_listen>
  80181a:	83 c4 10             	add    $0x10,%esp
}
  80181d:	c9                   	leave  
  80181e:	c3                   	ret    

0080181f <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  80181f:	55                   	push   %ebp
  801820:	89 e5                	mov    %esp,%ebp
  801822:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801825:	ff 75 10             	pushl  0x10(%ebp)
  801828:	ff 75 0c             	pushl  0xc(%ebp)
  80182b:	ff 75 08             	pushl  0x8(%ebp)
  80182e:	e8 3a 02 00 00       	call   801a6d <nsipc_socket>
  801833:	83 c4 10             	add    $0x10,%esp
  801836:	85 c0                	test   %eax,%eax
  801838:	78 05                	js     80183f <socket+0x20>
		return r;
	return alloc_sockfd(r);
  80183a:	e8 a5 fe ff ff       	call   8016e4 <alloc_sockfd>
}
  80183f:	c9                   	leave  
  801840:	c3                   	ret    

00801841 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801841:	55                   	push   %ebp
  801842:	89 e5                	mov    %esp,%ebp
  801844:	53                   	push   %ebx
  801845:	83 ec 04             	sub    $0x4,%esp
  801848:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  80184a:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801851:	75 12                	jne    801865 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801853:	83 ec 0c             	sub    $0xc,%esp
  801856:	6a 02                	push   $0x2
  801858:	e8 d6 07 00 00       	call   802033 <ipc_find_env>
  80185d:	a3 04 40 80 00       	mov    %eax,0x804004
  801862:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801865:	6a 07                	push   $0x7
  801867:	68 00 60 80 00       	push   $0x806000
  80186c:	53                   	push   %ebx
  80186d:	ff 35 04 40 80 00    	pushl  0x804004
  801873:	e8 67 07 00 00       	call   801fdf <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801878:	83 c4 0c             	add    $0xc,%esp
  80187b:	6a 00                	push   $0x0
  80187d:	6a 00                	push   $0x0
  80187f:	6a 00                	push   $0x0
  801881:	e8 f0 06 00 00       	call   801f76 <ipc_recv>
}
  801886:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801889:	c9                   	leave  
  80188a:	c3                   	ret    

0080188b <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80188b:	55                   	push   %ebp
  80188c:	89 e5                	mov    %esp,%ebp
  80188e:	56                   	push   %esi
  80188f:	53                   	push   %ebx
  801890:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801893:	8b 45 08             	mov    0x8(%ebp),%eax
  801896:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  80189b:	8b 06                	mov    (%esi),%eax
  80189d:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8018a2:	b8 01 00 00 00       	mov    $0x1,%eax
  8018a7:	e8 95 ff ff ff       	call   801841 <nsipc>
  8018ac:	89 c3                	mov    %eax,%ebx
  8018ae:	85 c0                	test   %eax,%eax
  8018b0:	78 20                	js     8018d2 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8018b2:	83 ec 04             	sub    $0x4,%esp
  8018b5:	ff 35 10 60 80 00    	pushl  0x806010
  8018bb:	68 00 60 80 00       	push   $0x806000
  8018c0:	ff 75 0c             	pushl  0xc(%ebp)
  8018c3:	e8 3d f0 ff ff       	call   800905 <memmove>
		*addrlen = ret->ret_addrlen;
  8018c8:	a1 10 60 80 00       	mov    0x806010,%eax
  8018cd:	89 06                	mov    %eax,(%esi)
  8018cf:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  8018d2:	89 d8                	mov    %ebx,%eax
  8018d4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018d7:	5b                   	pop    %ebx
  8018d8:	5e                   	pop    %esi
  8018d9:	5d                   	pop    %ebp
  8018da:	c3                   	ret    

008018db <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8018db:	55                   	push   %ebp
  8018dc:	89 e5                	mov    %esp,%ebp
  8018de:	53                   	push   %ebx
  8018df:	83 ec 08             	sub    $0x8,%esp
  8018e2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8018e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e8:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8018ed:	53                   	push   %ebx
  8018ee:	ff 75 0c             	pushl  0xc(%ebp)
  8018f1:	68 04 60 80 00       	push   $0x806004
  8018f6:	e8 0a f0 ff ff       	call   800905 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8018fb:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801901:	b8 02 00 00 00       	mov    $0x2,%eax
  801906:	e8 36 ff ff ff       	call   801841 <nsipc>
}
  80190b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80190e:	c9                   	leave  
  80190f:	c3                   	ret    

00801910 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801910:	55                   	push   %ebp
  801911:	89 e5                	mov    %esp,%ebp
  801913:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801916:	8b 45 08             	mov    0x8(%ebp),%eax
  801919:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  80191e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801921:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801926:	b8 03 00 00 00       	mov    $0x3,%eax
  80192b:	e8 11 ff ff ff       	call   801841 <nsipc>
}
  801930:	c9                   	leave  
  801931:	c3                   	ret    

00801932 <nsipc_close>:

int
nsipc_close(int s)
{
  801932:	55                   	push   %ebp
  801933:	89 e5                	mov    %esp,%ebp
  801935:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801938:	8b 45 08             	mov    0x8(%ebp),%eax
  80193b:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801940:	b8 04 00 00 00       	mov    $0x4,%eax
  801945:	e8 f7 fe ff ff       	call   801841 <nsipc>
}
  80194a:	c9                   	leave  
  80194b:	c3                   	ret    

0080194c <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80194c:	55                   	push   %ebp
  80194d:	89 e5                	mov    %esp,%ebp
  80194f:	53                   	push   %ebx
  801950:	83 ec 08             	sub    $0x8,%esp
  801953:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801956:	8b 45 08             	mov    0x8(%ebp),%eax
  801959:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  80195e:	53                   	push   %ebx
  80195f:	ff 75 0c             	pushl  0xc(%ebp)
  801962:	68 04 60 80 00       	push   $0x806004
  801967:	e8 99 ef ff ff       	call   800905 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80196c:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801972:	b8 05 00 00 00       	mov    $0x5,%eax
  801977:	e8 c5 fe ff ff       	call   801841 <nsipc>
}
  80197c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80197f:	c9                   	leave  
  801980:	c3                   	ret    

00801981 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801981:	55                   	push   %ebp
  801982:	89 e5                	mov    %esp,%ebp
  801984:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801987:	8b 45 08             	mov    0x8(%ebp),%eax
  80198a:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  80198f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801992:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801997:	b8 06 00 00 00       	mov    $0x6,%eax
  80199c:	e8 a0 fe ff ff       	call   801841 <nsipc>
}
  8019a1:	c9                   	leave  
  8019a2:	c3                   	ret    

008019a3 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8019a3:	55                   	push   %ebp
  8019a4:	89 e5                	mov    %esp,%ebp
  8019a6:	56                   	push   %esi
  8019a7:	53                   	push   %ebx
  8019a8:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8019ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ae:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  8019b3:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  8019b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8019bc:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8019c1:	b8 07 00 00 00       	mov    $0x7,%eax
  8019c6:	e8 76 fe ff ff       	call   801841 <nsipc>
  8019cb:	89 c3                	mov    %eax,%ebx
  8019cd:	85 c0                	test   %eax,%eax
  8019cf:	78 35                	js     801a06 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  8019d1:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8019d6:	7f 04                	jg     8019dc <nsipc_recv+0x39>
  8019d8:	39 c6                	cmp    %eax,%esi
  8019da:	7d 16                	jge    8019f2 <nsipc_recv+0x4f>
  8019dc:	68 eb 27 80 00       	push   $0x8027eb
  8019e1:	68 ac 27 80 00       	push   $0x8027ac
  8019e6:	6a 62                	push   $0x62
  8019e8:	68 00 28 80 00       	push   $0x802800
  8019ed:	e8 23 e7 ff ff       	call   800115 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8019f2:	83 ec 04             	sub    $0x4,%esp
  8019f5:	50                   	push   %eax
  8019f6:	68 00 60 80 00       	push   $0x806000
  8019fb:	ff 75 0c             	pushl  0xc(%ebp)
  8019fe:	e8 02 ef ff ff       	call   800905 <memmove>
  801a03:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801a06:	89 d8                	mov    %ebx,%eax
  801a08:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a0b:	5b                   	pop    %ebx
  801a0c:	5e                   	pop    %esi
  801a0d:	5d                   	pop    %ebp
  801a0e:	c3                   	ret    

00801a0f <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801a0f:	55                   	push   %ebp
  801a10:	89 e5                	mov    %esp,%ebp
  801a12:	53                   	push   %ebx
  801a13:	83 ec 04             	sub    $0x4,%esp
  801a16:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801a19:	8b 45 08             	mov    0x8(%ebp),%eax
  801a1c:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801a21:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801a27:	7e 16                	jle    801a3f <nsipc_send+0x30>
  801a29:	68 0c 28 80 00       	push   $0x80280c
  801a2e:	68 ac 27 80 00       	push   $0x8027ac
  801a33:	6a 6d                	push   $0x6d
  801a35:	68 00 28 80 00       	push   $0x802800
  801a3a:	e8 d6 e6 ff ff       	call   800115 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801a3f:	83 ec 04             	sub    $0x4,%esp
  801a42:	53                   	push   %ebx
  801a43:	ff 75 0c             	pushl  0xc(%ebp)
  801a46:	68 0c 60 80 00       	push   $0x80600c
  801a4b:	e8 b5 ee ff ff       	call   800905 <memmove>
	nsipcbuf.send.req_size = size;
  801a50:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801a56:	8b 45 14             	mov    0x14(%ebp),%eax
  801a59:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801a5e:	b8 08 00 00 00       	mov    $0x8,%eax
  801a63:	e8 d9 fd ff ff       	call   801841 <nsipc>
}
  801a68:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a6b:	c9                   	leave  
  801a6c:	c3                   	ret    

00801a6d <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801a6d:	55                   	push   %ebp
  801a6e:	89 e5                	mov    %esp,%ebp
  801a70:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801a73:	8b 45 08             	mov    0x8(%ebp),%eax
  801a76:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801a7b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a7e:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801a83:	8b 45 10             	mov    0x10(%ebp),%eax
  801a86:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801a8b:	b8 09 00 00 00       	mov    $0x9,%eax
  801a90:	e8 ac fd ff ff       	call   801841 <nsipc>
}
  801a95:	c9                   	leave  
  801a96:	c3                   	ret    

00801a97 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a97:	55                   	push   %ebp
  801a98:	89 e5                	mov    %esp,%ebp
  801a9a:	56                   	push   %esi
  801a9b:	53                   	push   %ebx
  801a9c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a9f:	83 ec 0c             	sub    $0xc,%esp
  801aa2:	ff 75 08             	pushl  0x8(%ebp)
  801aa5:	e8 62 f3 ff ff       	call   800e0c <fd2data>
  801aaa:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801aac:	83 c4 08             	add    $0x8,%esp
  801aaf:	68 18 28 80 00       	push   $0x802818
  801ab4:	53                   	push   %ebx
  801ab5:	e8 b9 ec ff ff       	call   800773 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801aba:	8b 46 04             	mov    0x4(%esi),%eax
  801abd:	2b 06                	sub    (%esi),%eax
  801abf:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ac5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801acc:	00 00 00 
	stat->st_dev = &devpipe;
  801acf:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801ad6:	30 80 00 
	return 0;
}
  801ad9:	b8 00 00 00 00       	mov    $0x0,%eax
  801ade:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ae1:	5b                   	pop    %ebx
  801ae2:	5e                   	pop    %esi
  801ae3:	5d                   	pop    %ebp
  801ae4:	c3                   	ret    

00801ae5 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ae5:	55                   	push   %ebp
  801ae6:	89 e5                	mov    %esp,%ebp
  801ae8:	53                   	push   %ebx
  801ae9:	83 ec 0c             	sub    $0xc,%esp
  801aec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801aef:	53                   	push   %ebx
  801af0:	6a 00                	push   $0x0
  801af2:	e8 04 f1 ff ff       	call   800bfb <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801af7:	89 1c 24             	mov    %ebx,(%esp)
  801afa:	e8 0d f3 ff ff       	call   800e0c <fd2data>
  801aff:	83 c4 08             	add    $0x8,%esp
  801b02:	50                   	push   %eax
  801b03:	6a 00                	push   $0x0
  801b05:	e8 f1 f0 ff ff       	call   800bfb <sys_page_unmap>
}
  801b0a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b0d:	c9                   	leave  
  801b0e:	c3                   	ret    

00801b0f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b0f:	55                   	push   %ebp
  801b10:	89 e5                	mov    %esp,%ebp
  801b12:	57                   	push   %edi
  801b13:	56                   	push   %esi
  801b14:	53                   	push   %ebx
  801b15:	83 ec 1c             	sub    $0x1c,%esp
  801b18:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b1b:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b1d:	a1 08 40 80 00       	mov    0x804008,%eax
  801b22:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801b25:	83 ec 0c             	sub    $0xc,%esp
  801b28:	ff 75 e0             	pushl  -0x20(%ebp)
  801b2b:	e8 3c 05 00 00       	call   80206c <pageref>
  801b30:	89 c3                	mov    %eax,%ebx
  801b32:	89 3c 24             	mov    %edi,(%esp)
  801b35:	e8 32 05 00 00       	call   80206c <pageref>
  801b3a:	83 c4 10             	add    $0x10,%esp
  801b3d:	39 c3                	cmp    %eax,%ebx
  801b3f:	0f 94 c1             	sete   %cl
  801b42:	0f b6 c9             	movzbl %cl,%ecx
  801b45:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801b48:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801b4e:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b51:	39 ce                	cmp    %ecx,%esi
  801b53:	74 1b                	je     801b70 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801b55:	39 c3                	cmp    %eax,%ebx
  801b57:	75 c4                	jne    801b1d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b59:	8b 42 58             	mov    0x58(%edx),%eax
  801b5c:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b5f:	50                   	push   %eax
  801b60:	56                   	push   %esi
  801b61:	68 1f 28 80 00       	push   $0x80281f
  801b66:	e8 83 e6 ff ff       	call   8001ee <cprintf>
  801b6b:	83 c4 10             	add    $0x10,%esp
  801b6e:	eb ad                	jmp    801b1d <_pipeisclosed+0xe>
	}
}
  801b70:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b73:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b76:	5b                   	pop    %ebx
  801b77:	5e                   	pop    %esi
  801b78:	5f                   	pop    %edi
  801b79:	5d                   	pop    %ebp
  801b7a:	c3                   	ret    

00801b7b <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b7b:	55                   	push   %ebp
  801b7c:	89 e5                	mov    %esp,%ebp
  801b7e:	57                   	push   %edi
  801b7f:	56                   	push   %esi
  801b80:	53                   	push   %ebx
  801b81:	83 ec 28             	sub    $0x28,%esp
  801b84:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b87:	56                   	push   %esi
  801b88:	e8 7f f2 ff ff       	call   800e0c <fd2data>
  801b8d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b8f:	83 c4 10             	add    $0x10,%esp
  801b92:	bf 00 00 00 00       	mov    $0x0,%edi
  801b97:	eb 4b                	jmp    801be4 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b99:	89 da                	mov    %ebx,%edx
  801b9b:	89 f0                	mov    %esi,%eax
  801b9d:	e8 6d ff ff ff       	call   801b0f <_pipeisclosed>
  801ba2:	85 c0                	test   %eax,%eax
  801ba4:	75 48                	jne    801bee <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ba6:	e8 ac ef ff ff       	call   800b57 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801bab:	8b 43 04             	mov    0x4(%ebx),%eax
  801bae:	8b 0b                	mov    (%ebx),%ecx
  801bb0:	8d 51 20             	lea    0x20(%ecx),%edx
  801bb3:	39 d0                	cmp    %edx,%eax
  801bb5:	73 e2                	jae    801b99 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801bb7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bba:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801bbe:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801bc1:	89 c2                	mov    %eax,%edx
  801bc3:	c1 fa 1f             	sar    $0x1f,%edx
  801bc6:	89 d1                	mov    %edx,%ecx
  801bc8:	c1 e9 1b             	shr    $0x1b,%ecx
  801bcb:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801bce:	83 e2 1f             	and    $0x1f,%edx
  801bd1:	29 ca                	sub    %ecx,%edx
  801bd3:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801bd7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801bdb:	83 c0 01             	add    $0x1,%eax
  801bde:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801be1:	83 c7 01             	add    $0x1,%edi
  801be4:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801be7:	75 c2                	jne    801bab <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801be9:	8b 45 10             	mov    0x10(%ebp),%eax
  801bec:	eb 05                	jmp    801bf3 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bee:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801bf3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bf6:	5b                   	pop    %ebx
  801bf7:	5e                   	pop    %esi
  801bf8:	5f                   	pop    %edi
  801bf9:	5d                   	pop    %ebp
  801bfa:	c3                   	ret    

00801bfb <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801bfb:	55                   	push   %ebp
  801bfc:	89 e5                	mov    %esp,%ebp
  801bfe:	57                   	push   %edi
  801bff:	56                   	push   %esi
  801c00:	53                   	push   %ebx
  801c01:	83 ec 18             	sub    $0x18,%esp
  801c04:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c07:	57                   	push   %edi
  801c08:	e8 ff f1 ff ff       	call   800e0c <fd2data>
  801c0d:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c0f:	83 c4 10             	add    $0x10,%esp
  801c12:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c17:	eb 3d                	jmp    801c56 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c19:	85 db                	test   %ebx,%ebx
  801c1b:	74 04                	je     801c21 <devpipe_read+0x26>
				return i;
  801c1d:	89 d8                	mov    %ebx,%eax
  801c1f:	eb 44                	jmp    801c65 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c21:	89 f2                	mov    %esi,%edx
  801c23:	89 f8                	mov    %edi,%eax
  801c25:	e8 e5 fe ff ff       	call   801b0f <_pipeisclosed>
  801c2a:	85 c0                	test   %eax,%eax
  801c2c:	75 32                	jne    801c60 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c2e:	e8 24 ef ff ff       	call   800b57 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c33:	8b 06                	mov    (%esi),%eax
  801c35:	3b 46 04             	cmp    0x4(%esi),%eax
  801c38:	74 df                	je     801c19 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c3a:	99                   	cltd   
  801c3b:	c1 ea 1b             	shr    $0x1b,%edx
  801c3e:	01 d0                	add    %edx,%eax
  801c40:	83 e0 1f             	and    $0x1f,%eax
  801c43:	29 d0                	sub    %edx,%eax
  801c45:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c4d:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801c50:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c53:	83 c3 01             	add    $0x1,%ebx
  801c56:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c59:	75 d8                	jne    801c33 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c5b:	8b 45 10             	mov    0x10(%ebp),%eax
  801c5e:	eb 05                	jmp    801c65 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c60:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c68:	5b                   	pop    %ebx
  801c69:	5e                   	pop    %esi
  801c6a:	5f                   	pop    %edi
  801c6b:	5d                   	pop    %ebp
  801c6c:	c3                   	ret    

00801c6d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c6d:	55                   	push   %ebp
  801c6e:	89 e5                	mov    %esp,%ebp
  801c70:	56                   	push   %esi
  801c71:	53                   	push   %ebx
  801c72:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c75:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c78:	50                   	push   %eax
  801c79:	e8 a5 f1 ff ff       	call   800e23 <fd_alloc>
  801c7e:	83 c4 10             	add    $0x10,%esp
  801c81:	89 c2                	mov    %eax,%edx
  801c83:	85 c0                	test   %eax,%eax
  801c85:	0f 88 2c 01 00 00    	js     801db7 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c8b:	83 ec 04             	sub    $0x4,%esp
  801c8e:	68 07 04 00 00       	push   $0x407
  801c93:	ff 75 f4             	pushl  -0xc(%ebp)
  801c96:	6a 00                	push   $0x0
  801c98:	e8 d9 ee ff ff       	call   800b76 <sys_page_alloc>
  801c9d:	83 c4 10             	add    $0x10,%esp
  801ca0:	89 c2                	mov    %eax,%edx
  801ca2:	85 c0                	test   %eax,%eax
  801ca4:	0f 88 0d 01 00 00    	js     801db7 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801caa:	83 ec 0c             	sub    $0xc,%esp
  801cad:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801cb0:	50                   	push   %eax
  801cb1:	e8 6d f1 ff ff       	call   800e23 <fd_alloc>
  801cb6:	89 c3                	mov    %eax,%ebx
  801cb8:	83 c4 10             	add    $0x10,%esp
  801cbb:	85 c0                	test   %eax,%eax
  801cbd:	0f 88 e2 00 00 00    	js     801da5 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cc3:	83 ec 04             	sub    $0x4,%esp
  801cc6:	68 07 04 00 00       	push   $0x407
  801ccb:	ff 75 f0             	pushl  -0x10(%ebp)
  801cce:	6a 00                	push   $0x0
  801cd0:	e8 a1 ee ff ff       	call   800b76 <sys_page_alloc>
  801cd5:	89 c3                	mov    %eax,%ebx
  801cd7:	83 c4 10             	add    $0x10,%esp
  801cda:	85 c0                	test   %eax,%eax
  801cdc:	0f 88 c3 00 00 00    	js     801da5 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801ce2:	83 ec 0c             	sub    $0xc,%esp
  801ce5:	ff 75 f4             	pushl  -0xc(%ebp)
  801ce8:	e8 1f f1 ff ff       	call   800e0c <fd2data>
  801ced:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cef:	83 c4 0c             	add    $0xc,%esp
  801cf2:	68 07 04 00 00       	push   $0x407
  801cf7:	50                   	push   %eax
  801cf8:	6a 00                	push   $0x0
  801cfa:	e8 77 ee ff ff       	call   800b76 <sys_page_alloc>
  801cff:	89 c3                	mov    %eax,%ebx
  801d01:	83 c4 10             	add    $0x10,%esp
  801d04:	85 c0                	test   %eax,%eax
  801d06:	0f 88 89 00 00 00    	js     801d95 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d0c:	83 ec 0c             	sub    $0xc,%esp
  801d0f:	ff 75 f0             	pushl  -0x10(%ebp)
  801d12:	e8 f5 f0 ff ff       	call   800e0c <fd2data>
  801d17:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d1e:	50                   	push   %eax
  801d1f:	6a 00                	push   $0x0
  801d21:	56                   	push   %esi
  801d22:	6a 00                	push   $0x0
  801d24:	e8 90 ee ff ff       	call   800bb9 <sys_page_map>
  801d29:	89 c3                	mov    %eax,%ebx
  801d2b:	83 c4 20             	add    $0x20,%esp
  801d2e:	85 c0                	test   %eax,%eax
  801d30:	78 55                	js     801d87 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d32:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d38:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d3b:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d40:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d47:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d50:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d52:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d55:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d5c:	83 ec 0c             	sub    $0xc,%esp
  801d5f:	ff 75 f4             	pushl  -0xc(%ebp)
  801d62:	e8 95 f0 ff ff       	call   800dfc <fd2num>
  801d67:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d6a:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d6c:	83 c4 04             	add    $0x4,%esp
  801d6f:	ff 75 f0             	pushl  -0x10(%ebp)
  801d72:	e8 85 f0 ff ff       	call   800dfc <fd2num>
  801d77:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d7a:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d7d:	83 c4 10             	add    $0x10,%esp
  801d80:	ba 00 00 00 00       	mov    $0x0,%edx
  801d85:	eb 30                	jmp    801db7 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d87:	83 ec 08             	sub    $0x8,%esp
  801d8a:	56                   	push   %esi
  801d8b:	6a 00                	push   $0x0
  801d8d:	e8 69 ee ff ff       	call   800bfb <sys_page_unmap>
  801d92:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d95:	83 ec 08             	sub    $0x8,%esp
  801d98:	ff 75 f0             	pushl  -0x10(%ebp)
  801d9b:	6a 00                	push   $0x0
  801d9d:	e8 59 ee ff ff       	call   800bfb <sys_page_unmap>
  801da2:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801da5:	83 ec 08             	sub    $0x8,%esp
  801da8:	ff 75 f4             	pushl  -0xc(%ebp)
  801dab:	6a 00                	push   $0x0
  801dad:	e8 49 ee ff ff       	call   800bfb <sys_page_unmap>
  801db2:	83 c4 10             	add    $0x10,%esp
  801db5:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801db7:	89 d0                	mov    %edx,%eax
  801db9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dbc:	5b                   	pop    %ebx
  801dbd:	5e                   	pop    %esi
  801dbe:	5d                   	pop    %ebp
  801dbf:	c3                   	ret    

00801dc0 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801dc0:	55                   	push   %ebp
  801dc1:	89 e5                	mov    %esp,%ebp
  801dc3:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801dc6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dc9:	50                   	push   %eax
  801dca:	ff 75 08             	pushl  0x8(%ebp)
  801dcd:	e8 a0 f0 ff ff       	call   800e72 <fd_lookup>
  801dd2:	83 c4 10             	add    $0x10,%esp
  801dd5:	85 c0                	test   %eax,%eax
  801dd7:	78 18                	js     801df1 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801dd9:	83 ec 0c             	sub    $0xc,%esp
  801ddc:	ff 75 f4             	pushl  -0xc(%ebp)
  801ddf:	e8 28 f0 ff ff       	call   800e0c <fd2data>
	return _pipeisclosed(fd, p);
  801de4:	89 c2                	mov    %eax,%edx
  801de6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801de9:	e8 21 fd ff ff       	call   801b0f <_pipeisclosed>
  801dee:	83 c4 10             	add    $0x10,%esp
}
  801df1:	c9                   	leave  
  801df2:	c3                   	ret    

00801df3 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801df3:	55                   	push   %ebp
  801df4:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801df6:	b8 00 00 00 00       	mov    $0x0,%eax
  801dfb:	5d                   	pop    %ebp
  801dfc:	c3                   	ret    

00801dfd <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801dfd:	55                   	push   %ebp
  801dfe:	89 e5                	mov    %esp,%ebp
  801e00:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e03:	68 37 28 80 00       	push   $0x802837
  801e08:	ff 75 0c             	pushl  0xc(%ebp)
  801e0b:	e8 63 e9 ff ff       	call   800773 <strcpy>
	return 0;
}
  801e10:	b8 00 00 00 00       	mov    $0x0,%eax
  801e15:	c9                   	leave  
  801e16:	c3                   	ret    

00801e17 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e17:	55                   	push   %ebp
  801e18:	89 e5                	mov    %esp,%ebp
  801e1a:	57                   	push   %edi
  801e1b:	56                   	push   %esi
  801e1c:	53                   	push   %ebx
  801e1d:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e23:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e28:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e2e:	eb 2d                	jmp    801e5d <devcons_write+0x46>
		m = n - tot;
  801e30:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e33:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801e35:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e38:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e3d:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e40:	83 ec 04             	sub    $0x4,%esp
  801e43:	53                   	push   %ebx
  801e44:	03 45 0c             	add    0xc(%ebp),%eax
  801e47:	50                   	push   %eax
  801e48:	57                   	push   %edi
  801e49:	e8 b7 ea ff ff       	call   800905 <memmove>
		sys_cputs(buf, m);
  801e4e:	83 c4 08             	add    $0x8,%esp
  801e51:	53                   	push   %ebx
  801e52:	57                   	push   %edi
  801e53:	e8 62 ec ff ff       	call   800aba <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e58:	01 de                	add    %ebx,%esi
  801e5a:	83 c4 10             	add    $0x10,%esp
  801e5d:	89 f0                	mov    %esi,%eax
  801e5f:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e62:	72 cc                	jb     801e30 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e64:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e67:	5b                   	pop    %ebx
  801e68:	5e                   	pop    %esi
  801e69:	5f                   	pop    %edi
  801e6a:	5d                   	pop    %ebp
  801e6b:	c3                   	ret    

00801e6c <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e6c:	55                   	push   %ebp
  801e6d:	89 e5                	mov    %esp,%ebp
  801e6f:	83 ec 08             	sub    $0x8,%esp
  801e72:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801e77:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e7b:	74 2a                	je     801ea7 <devcons_read+0x3b>
  801e7d:	eb 05                	jmp    801e84 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e7f:	e8 d3 ec ff ff       	call   800b57 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e84:	e8 4f ec ff ff       	call   800ad8 <sys_cgetc>
  801e89:	85 c0                	test   %eax,%eax
  801e8b:	74 f2                	je     801e7f <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e8d:	85 c0                	test   %eax,%eax
  801e8f:	78 16                	js     801ea7 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e91:	83 f8 04             	cmp    $0x4,%eax
  801e94:	74 0c                	je     801ea2 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e96:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e99:	88 02                	mov    %al,(%edx)
	return 1;
  801e9b:	b8 01 00 00 00       	mov    $0x1,%eax
  801ea0:	eb 05                	jmp    801ea7 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ea2:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801ea7:	c9                   	leave  
  801ea8:	c3                   	ret    

00801ea9 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801ea9:	55                   	push   %ebp
  801eaa:	89 e5                	mov    %esp,%ebp
  801eac:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801eaf:	8b 45 08             	mov    0x8(%ebp),%eax
  801eb2:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801eb5:	6a 01                	push   $0x1
  801eb7:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801eba:	50                   	push   %eax
  801ebb:	e8 fa eb ff ff       	call   800aba <sys_cputs>
}
  801ec0:	83 c4 10             	add    $0x10,%esp
  801ec3:	c9                   	leave  
  801ec4:	c3                   	ret    

00801ec5 <getchar>:

int
getchar(void)
{
  801ec5:	55                   	push   %ebp
  801ec6:	89 e5                	mov    %esp,%ebp
  801ec8:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801ecb:	6a 01                	push   $0x1
  801ecd:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ed0:	50                   	push   %eax
  801ed1:	6a 00                	push   $0x0
  801ed3:	e8 00 f2 ff ff       	call   8010d8 <read>
	if (r < 0)
  801ed8:	83 c4 10             	add    $0x10,%esp
  801edb:	85 c0                	test   %eax,%eax
  801edd:	78 0f                	js     801eee <getchar+0x29>
		return r;
	if (r < 1)
  801edf:	85 c0                	test   %eax,%eax
  801ee1:	7e 06                	jle    801ee9 <getchar+0x24>
		return -E_EOF;
	return c;
  801ee3:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801ee7:	eb 05                	jmp    801eee <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801ee9:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801eee:	c9                   	leave  
  801eef:	c3                   	ret    

00801ef0 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801ef0:	55                   	push   %ebp
  801ef1:	89 e5                	mov    %esp,%ebp
  801ef3:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ef6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ef9:	50                   	push   %eax
  801efa:	ff 75 08             	pushl  0x8(%ebp)
  801efd:	e8 70 ef ff ff       	call   800e72 <fd_lookup>
  801f02:	83 c4 10             	add    $0x10,%esp
  801f05:	85 c0                	test   %eax,%eax
  801f07:	78 11                	js     801f1a <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f09:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f0c:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801f12:	39 10                	cmp    %edx,(%eax)
  801f14:	0f 94 c0             	sete   %al
  801f17:	0f b6 c0             	movzbl %al,%eax
}
  801f1a:	c9                   	leave  
  801f1b:	c3                   	ret    

00801f1c <opencons>:

int
opencons(void)
{
  801f1c:	55                   	push   %ebp
  801f1d:	89 e5                	mov    %esp,%ebp
  801f1f:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f22:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f25:	50                   	push   %eax
  801f26:	e8 f8 ee ff ff       	call   800e23 <fd_alloc>
  801f2b:	83 c4 10             	add    $0x10,%esp
		return r;
  801f2e:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f30:	85 c0                	test   %eax,%eax
  801f32:	78 3e                	js     801f72 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f34:	83 ec 04             	sub    $0x4,%esp
  801f37:	68 07 04 00 00       	push   $0x407
  801f3c:	ff 75 f4             	pushl  -0xc(%ebp)
  801f3f:	6a 00                	push   $0x0
  801f41:	e8 30 ec ff ff       	call   800b76 <sys_page_alloc>
  801f46:	83 c4 10             	add    $0x10,%esp
		return r;
  801f49:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f4b:	85 c0                	test   %eax,%eax
  801f4d:	78 23                	js     801f72 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f4f:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801f55:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f58:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f5d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f64:	83 ec 0c             	sub    $0xc,%esp
  801f67:	50                   	push   %eax
  801f68:	e8 8f ee ff ff       	call   800dfc <fd2num>
  801f6d:	89 c2                	mov    %eax,%edx
  801f6f:	83 c4 10             	add    $0x10,%esp
}
  801f72:	89 d0                	mov    %edx,%eax
  801f74:	c9                   	leave  
  801f75:	c3                   	ret    

00801f76 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f76:	55                   	push   %ebp
  801f77:	89 e5                	mov    %esp,%ebp
  801f79:	56                   	push   %esi
  801f7a:	53                   	push   %ebx
  801f7b:	8b 75 08             	mov    0x8(%ebp),%esi
  801f7e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f81:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  801f84:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801f86:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801f8b:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  801f8e:	83 ec 0c             	sub    $0xc,%esp
  801f91:	50                   	push   %eax
  801f92:	e8 8f ed ff ff       	call   800d26 <sys_ipc_recv>

	if (r < 0) {
  801f97:	83 c4 10             	add    $0x10,%esp
  801f9a:	85 c0                	test   %eax,%eax
  801f9c:	79 16                	jns    801fb4 <ipc_recv+0x3e>
		if (from_env_store)
  801f9e:	85 f6                	test   %esi,%esi
  801fa0:	74 06                	je     801fa8 <ipc_recv+0x32>
			*from_env_store = 0;
  801fa2:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  801fa8:	85 db                	test   %ebx,%ebx
  801faa:	74 2c                	je     801fd8 <ipc_recv+0x62>
			*perm_store = 0;
  801fac:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801fb2:	eb 24                	jmp    801fd8 <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  801fb4:	85 f6                	test   %esi,%esi
  801fb6:	74 0a                	je     801fc2 <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  801fb8:	a1 08 40 80 00       	mov    0x804008,%eax
  801fbd:	8b 40 74             	mov    0x74(%eax),%eax
  801fc0:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  801fc2:	85 db                	test   %ebx,%ebx
  801fc4:	74 0a                	je     801fd0 <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  801fc6:	a1 08 40 80 00       	mov    0x804008,%eax
  801fcb:	8b 40 78             	mov    0x78(%eax),%eax
  801fce:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  801fd0:	a1 08 40 80 00       	mov    0x804008,%eax
  801fd5:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  801fd8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fdb:	5b                   	pop    %ebx
  801fdc:	5e                   	pop    %esi
  801fdd:	5d                   	pop    %ebp
  801fde:	c3                   	ret    

00801fdf <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fdf:	55                   	push   %ebp
  801fe0:	89 e5                	mov    %esp,%ebp
  801fe2:	57                   	push   %edi
  801fe3:	56                   	push   %esi
  801fe4:	53                   	push   %ebx
  801fe5:	83 ec 0c             	sub    $0xc,%esp
  801fe8:	8b 7d 08             	mov    0x8(%ebp),%edi
  801feb:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fee:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  801ff1:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801ff3:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801ff8:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  801ffb:	ff 75 14             	pushl  0x14(%ebp)
  801ffe:	53                   	push   %ebx
  801fff:	56                   	push   %esi
  802000:	57                   	push   %edi
  802001:	e8 fd ec ff ff       	call   800d03 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  802006:	83 c4 10             	add    $0x10,%esp
  802009:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80200c:	75 07                	jne    802015 <ipc_send+0x36>
			sys_yield();
  80200e:	e8 44 eb ff ff       	call   800b57 <sys_yield>
  802013:	eb e6                	jmp    801ffb <ipc_send+0x1c>
		} else if (r < 0) {
  802015:	85 c0                	test   %eax,%eax
  802017:	79 12                	jns    80202b <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  802019:	50                   	push   %eax
  80201a:	68 43 28 80 00       	push   $0x802843
  80201f:	6a 51                	push   $0x51
  802021:	68 50 28 80 00       	push   $0x802850
  802026:	e8 ea e0 ff ff       	call   800115 <_panic>
		}
	}
}
  80202b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80202e:	5b                   	pop    %ebx
  80202f:	5e                   	pop    %esi
  802030:	5f                   	pop    %edi
  802031:	5d                   	pop    %ebp
  802032:	c3                   	ret    

00802033 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802033:	55                   	push   %ebp
  802034:	89 e5                	mov    %esp,%ebp
  802036:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802039:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80203e:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802041:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802047:	8b 52 50             	mov    0x50(%edx),%edx
  80204a:	39 ca                	cmp    %ecx,%edx
  80204c:	75 0d                	jne    80205b <ipc_find_env+0x28>
			return envs[i].env_id;
  80204e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802051:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802056:	8b 40 48             	mov    0x48(%eax),%eax
  802059:	eb 0f                	jmp    80206a <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80205b:	83 c0 01             	add    $0x1,%eax
  80205e:	3d 00 04 00 00       	cmp    $0x400,%eax
  802063:	75 d9                	jne    80203e <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802065:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80206a:	5d                   	pop    %ebp
  80206b:	c3                   	ret    

0080206c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80206c:	55                   	push   %ebp
  80206d:	89 e5                	mov    %esp,%ebp
  80206f:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802072:	89 d0                	mov    %edx,%eax
  802074:	c1 e8 16             	shr    $0x16,%eax
  802077:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80207e:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802083:	f6 c1 01             	test   $0x1,%cl
  802086:	74 1d                	je     8020a5 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802088:	c1 ea 0c             	shr    $0xc,%edx
  80208b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802092:	f6 c2 01             	test   $0x1,%dl
  802095:	74 0e                	je     8020a5 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802097:	c1 ea 0c             	shr    $0xc,%edx
  80209a:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8020a1:	ef 
  8020a2:	0f b7 c0             	movzwl %ax,%eax
}
  8020a5:	5d                   	pop    %ebp
  8020a6:	c3                   	ret    
  8020a7:	66 90                	xchg   %ax,%ax
  8020a9:	66 90                	xchg   %ax,%ax
  8020ab:	66 90                	xchg   %ax,%ax
  8020ad:	66 90                	xchg   %ax,%ax
  8020af:	90                   	nop

008020b0 <__udivdi3>:
  8020b0:	55                   	push   %ebp
  8020b1:	57                   	push   %edi
  8020b2:	56                   	push   %esi
  8020b3:	53                   	push   %ebx
  8020b4:	83 ec 1c             	sub    $0x1c,%esp
  8020b7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8020bb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8020bf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8020c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020c7:	85 f6                	test   %esi,%esi
  8020c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020cd:	89 ca                	mov    %ecx,%edx
  8020cf:	89 f8                	mov    %edi,%eax
  8020d1:	75 3d                	jne    802110 <__udivdi3+0x60>
  8020d3:	39 cf                	cmp    %ecx,%edi
  8020d5:	0f 87 c5 00 00 00    	ja     8021a0 <__udivdi3+0xf0>
  8020db:	85 ff                	test   %edi,%edi
  8020dd:	89 fd                	mov    %edi,%ebp
  8020df:	75 0b                	jne    8020ec <__udivdi3+0x3c>
  8020e1:	b8 01 00 00 00       	mov    $0x1,%eax
  8020e6:	31 d2                	xor    %edx,%edx
  8020e8:	f7 f7                	div    %edi
  8020ea:	89 c5                	mov    %eax,%ebp
  8020ec:	89 c8                	mov    %ecx,%eax
  8020ee:	31 d2                	xor    %edx,%edx
  8020f0:	f7 f5                	div    %ebp
  8020f2:	89 c1                	mov    %eax,%ecx
  8020f4:	89 d8                	mov    %ebx,%eax
  8020f6:	89 cf                	mov    %ecx,%edi
  8020f8:	f7 f5                	div    %ebp
  8020fa:	89 c3                	mov    %eax,%ebx
  8020fc:	89 d8                	mov    %ebx,%eax
  8020fe:	89 fa                	mov    %edi,%edx
  802100:	83 c4 1c             	add    $0x1c,%esp
  802103:	5b                   	pop    %ebx
  802104:	5e                   	pop    %esi
  802105:	5f                   	pop    %edi
  802106:	5d                   	pop    %ebp
  802107:	c3                   	ret    
  802108:	90                   	nop
  802109:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802110:	39 ce                	cmp    %ecx,%esi
  802112:	77 74                	ja     802188 <__udivdi3+0xd8>
  802114:	0f bd fe             	bsr    %esi,%edi
  802117:	83 f7 1f             	xor    $0x1f,%edi
  80211a:	0f 84 98 00 00 00    	je     8021b8 <__udivdi3+0x108>
  802120:	bb 20 00 00 00       	mov    $0x20,%ebx
  802125:	89 f9                	mov    %edi,%ecx
  802127:	89 c5                	mov    %eax,%ebp
  802129:	29 fb                	sub    %edi,%ebx
  80212b:	d3 e6                	shl    %cl,%esi
  80212d:	89 d9                	mov    %ebx,%ecx
  80212f:	d3 ed                	shr    %cl,%ebp
  802131:	89 f9                	mov    %edi,%ecx
  802133:	d3 e0                	shl    %cl,%eax
  802135:	09 ee                	or     %ebp,%esi
  802137:	89 d9                	mov    %ebx,%ecx
  802139:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80213d:	89 d5                	mov    %edx,%ebp
  80213f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802143:	d3 ed                	shr    %cl,%ebp
  802145:	89 f9                	mov    %edi,%ecx
  802147:	d3 e2                	shl    %cl,%edx
  802149:	89 d9                	mov    %ebx,%ecx
  80214b:	d3 e8                	shr    %cl,%eax
  80214d:	09 c2                	or     %eax,%edx
  80214f:	89 d0                	mov    %edx,%eax
  802151:	89 ea                	mov    %ebp,%edx
  802153:	f7 f6                	div    %esi
  802155:	89 d5                	mov    %edx,%ebp
  802157:	89 c3                	mov    %eax,%ebx
  802159:	f7 64 24 0c          	mull   0xc(%esp)
  80215d:	39 d5                	cmp    %edx,%ebp
  80215f:	72 10                	jb     802171 <__udivdi3+0xc1>
  802161:	8b 74 24 08          	mov    0x8(%esp),%esi
  802165:	89 f9                	mov    %edi,%ecx
  802167:	d3 e6                	shl    %cl,%esi
  802169:	39 c6                	cmp    %eax,%esi
  80216b:	73 07                	jae    802174 <__udivdi3+0xc4>
  80216d:	39 d5                	cmp    %edx,%ebp
  80216f:	75 03                	jne    802174 <__udivdi3+0xc4>
  802171:	83 eb 01             	sub    $0x1,%ebx
  802174:	31 ff                	xor    %edi,%edi
  802176:	89 d8                	mov    %ebx,%eax
  802178:	89 fa                	mov    %edi,%edx
  80217a:	83 c4 1c             	add    $0x1c,%esp
  80217d:	5b                   	pop    %ebx
  80217e:	5e                   	pop    %esi
  80217f:	5f                   	pop    %edi
  802180:	5d                   	pop    %ebp
  802181:	c3                   	ret    
  802182:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802188:	31 ff                	xor    %edi,%edi
  80218a:	31 db                	xor    %ebx,%ebx
  80218c:	89 d8                	mov    %ebx,%eax
  80218e:	89 fa                	mov    %edi,%edx
  802190:	83 c4 1c             	add    $0x1c,%esp
  802193:	5b                   	pop    %ebx
  802194:	5e                   	pop    %esi
  802195:	5f                   	pop    %edi
  802196:	5d                   	pop    %ebp
  802197:	c3                   	ret    
  802198:	90                   	nop
  802199:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021a0:	89 d8                	mov    %ebx,%eax
  8021a2:	f7 f7                	div    %edi
  8021a4:	31 ff                	xor    %edi,%edi
  8021a6:	89 c3                	mov    %eax,%ebx
  8021a8:	89 d8                	mov    %ebx,%eax
  8021aa:	89 fa                	mov    %edi,%edx
  8021ac:	83 c4 1c             	add    $0x1c,%esp
  8021af:	5b                   	pop    %ebx
  8021b0:	5e                   	pop    %esi
  8021b1:	5f                   	pop    %edi
  8021b2:	5d                   	pop    %ebp
  8021b3:	c3                   	ret    
  8021b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021b8:	39 ce                	cmp    %ecx,%esi
  8021ba:	72 0c                	jb     8021c8 <__udivdi3+0x118>
  8021bc:	31 db                	xor    %ebx,%ebx
  8021be:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8021c2:	0f 87 34 ff ff ff    	ja     8020fc <__udivdi3+0x4c>
  8021c8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8021cd:	e9 2a ff ff ff       	jmp    8020fc <__udivdi3+0x4c>
  8021d2:	66 90                	xchg   %ax,%ax
  8021d4:	66 90                	xchg   %ax,%ax
  8021d6:	66 90                	xchg   %ax,%ax
  8021d8:	66 90                	xchg   %ax,%ax
  8021da:	66 90                	xchg   %ax,%ax
  8021dc:	66 90                	xchg   %ax,%ax
  8021de:	66 90                	xchg   %ax,%ax

008021e0 <__umoddi3>:
  8021e0:	55                   	push   %ebp
  8021e1:	57                   	push   %edi
  8021e2:	56                   	push   %esi
  8021e3:	53                   	push   %ebx
  8021e4:	83 ec 1c             	sub    $0x1c,%esp
  8021e7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021eb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8021ef:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021f7:	85 d2                	test   %edx,%edx
  8021f9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8021fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802201:	89 f3                	mov    %esi,%ebx
  802203:	89 3c 24             	mov    %edi,(%esp)
  802206:	89 74 24 04          	mov    %esi,0x4(%esp)
  80220a:	75 1c                	jne    802228 <__umoddi3+0x48>
  80220c:	39 f7                	cmp    %esi,%edi
  80220e:	76 50                	jbe    802260 <__umoddi3+0x80>
  802210:	89 c8                	mov    %ecx,%eax
  802212:	89 f2                	mov    %esi,%edx
  802214:	f7 f7                	div    %edi
  802216:	89 d0                	mov    %edx,%eax
  802218:	31 d2                	xor    %edx,%edx
  80221a:	83 c4 1c             	add    $0x1c,%esp
  80221d:	5b                   	pop    %ebx
  80221e:	5e                   	pop    %esi
  80221f:	5f                   	pop    %edi
  802220:	5d                   	pop    %ebp
  802221:	c3                   	ret    
  802222:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802228:	39 f2                	cmp    %esi,%edx
  80222a:	89 d0                	mov    %edx,%eax
  80222c:	77 52                	ja     802280 <__umoddi3+0xa0>
  80222e:	0f bd ea             	bsr    %edx,%ebp
  802231:	83 f5 1f             	xor    $0x1f,%ebp
  802234:	75 5a                	jne    802290 <__umoddi3+0xb0>
  802236:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80223a:	0f 82 e0 00 00 00    	jb     802320 <__umoddi3+0x140>
  802240:	39 0c 24             	cmp    %ecx,(%esp)
  802243:	0f 86 d7 00 00 00    	jbe    802320 <__umoddi3+0x140>
  802249:	8b 44 24 08          	mov    0x8(%esp),%eax
  80224d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802251:	83 c4 1c             	add    $0x1c,%esp
  802254:	5b                   	pop    %ebx
  802255:	5e                   	pop    %esi
  802256:	5f                   	pop    %edi
  802257:	5d                   	pop    %ebp
  802258:	c3                   	ret    
  802259:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802260:	85 ff                	test   %edi,%edi
  802262:	89 fd                	mov    %edi,%ebp
  802264:	75 0b                	jne    802271 <__umoddi3+0x91>
  802266:	b8 01 00 00 00       	mov    $0x1,%eax
  80226b:	31 d2                	xor    %edx,%edx
  80226d:	f7 f7                	div    %edi
  80226f:	89 c5                	mov    %eax,%ebp
  802271:	89 f0                	mov    %esi,%eax
  802273:	31 d2                	xor    %edx,%edx
  802275:	f7 f5                	div    %ebp
  802277:	89 c8                	mov    %ecx,%eax
  802279:	f7 f5                	div    %ebp
  80227b:	89 d0                	mov    %edx,%eax
  80227d:	eb 99                	jmp    802218 <__umoddi3+0x38>
  80227f:	90                   	nop
  802280:	89 c8                	mov    %ecx,%eax
  802282:	89 f2                	mov    %esi,%edx
  802284:	83 c4 1c             	add    $0x1c,%esp
  802287:	5b                   	pop    %ebx
  802288:	5e                   	pop    %esi
  802289:	5f                   	pop    %edi
  80228a:	5d                   	pop    %ebp
  80228b:	c3                   	ret    
  80228c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802290:	8b 34 24             	mov    (%esp),%esi
  802293:	bf 20 00 00 00       	mov    $0x20,%edi
  802298:	89 e9                	mov    %ebp,%ecx
  80229a:	29 ef                	sub    %ebp,%edi
  80229c:	d3 e0                	shl    %cl,%eax
  80229e:	89 f9                	mov    %edi,%ecx
  8022a0:	89 f2                	mov    %esi,%edx
  8022a2:	d3 ea                	shr    %cl,%edx
  8022a4:	89 e9                	mov    %ebp,%ecx
  8022a6:	09 c2                	or     %eax,%edx
  8022a8:	89 d8                	mov    %ebx,%eax
  8022aa:	89 14 24             	mov    %edx,(%esp)
  8022ad:	89 f2                	mov    %esi,%edx
  8022af:	d3 e2                	shl    %cl,%edx
  8022b1:	89 f9                	mov    %edi,%ecx
  8022b3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8022b7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8022bb:	d3 e8                	shr    %cl,%eax
  8022bd:	89 e9                	mov    %ebp,%ecx
  8022bf:	89 c6                	mov    %eax,%esi
  8022c1:	d3 e3                	shl    %cl,%ebx
  8022c3:	89 f9                	mov    %edi,%ecx
  8022c5:	89 d0                	mov    %edx,%eax
  8022c7:	d3 e8                	shr    %cl,%eax
  8022c9:	89 e9                	mov    %ebp,%ecx
  8022cb:	09 d8                	or     %ebx,%eax
  8022cd:	89 d3                	mov    %edx,%ebx
  8022cf:	89 f2                	mov    %esi,%edx
  8022d1:	f7 34 24             	divl   (%esp)
  8022d4:	89 d6                	mov    %edx,%esi
  8022d6:	d3 e3                	shl    %cl,%ebx
  8022d8:	f7 64 24 04          	mull   0x4(%esp)
  8022dc:	39 d6                	cmp    %edx,%esi
  8022de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022e2:	89 d1                	mov    %edx,%ecx
  8022e4:	89 c3                	mov    %eax,%ebx
  8022e6:	72 08                	jb     8022f0 <__umoddi3+0x110>
  8022e8:	75 11                	jne    8022fb <__umoddi3+0x11b>
  8022ea:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8022ee:	73 0b                	jae    8022fb <__umoddi3+0x11b>
  8022f0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8022f4:	1b 14 24             	sbb    (%esp),%edx
  8022f7:	89 d1                	mov    %edx,%ecx
  8022f9:	89 c3                	mov    %eax,%ebx
  8022fb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8022ff:	29 da                	sub    %ebx,%edx
  802301:	19 ce                	sbb    %ecx,%esi
  802303:	89 f9                	mov    %edi,%ecx
  802305:	89 f0                	mov    %esi,%eax
  802307:	d3 e0                	shl    %cl,%eax
  802309:	89 e9                	mov    %ebp,%ecx
  80230b:	d3 ea                	shr    %cl,%edx
  80230d:	89 e9                	mov    %ebp,%ecx
  80230f:	d3 ee                	shr    %cl,%esi
  802311:	09 d0                	or     %edx,%eax
  802313:	89 f2                	mov    %esi,%edx
  802315:	83 c4 1c             	add    $0x1c,%esp
  802318:	5b                   	pop    %ebx
  802319:	5e                   	pop    %esi
  80231a:	5f                   	pop    %edi
  80231b:	5d                   	pop    %ebp
  80231c:	c3                   	ret    
  80231d:	8d 76 00             	lea    0x0(%esi),%esi
  802320:	29 f9                	sub    %edi,%ecx
  802322:	19 d6                	sbb    %edx,%esi
  802324:	89 74 24 04          	mov    %esi,0x4(%esp)
  802328:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80232c:	e9 18 ff ff ff       	jmp    802249 <__umoddi3+0x69>
