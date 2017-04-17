
obj/user/forktree.debug:     file format elf32-i386


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
  80002c:	e8 b0 00 00 00       	call   8000e1 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <forktree>:
	}
}

void
forktree(const char *cur)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 04             	sub    $0x4,%esp
  80003a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("%04x: I am '%s'\n", sys_getenvid(), cur);
  80003d:	e8 dc 0a 00 00       	call   800b1e <sys_getenvid>
  800042:	83 ec 04             	sub    $0x4,%esp
  800045:	53                   	push   %ebx
  800046:	50                   	push   %eax
  800047:	68 20 26 80 00       	push   $0x802620
  80004c:	e8 83 01 00 00       	call   8001d4 <cprintf>

	forkchild(cur, '0');
  800051:	83 c4 08             	add    $0x8,%esp
  800054:	6a 30                	push   $0x30
  800056:	53                   	push   %ebx
  800057:	e8 13 00 00 00       	call   80006f <forkchild>
	forkchild(cur, '1');
  80005c:	83 c4 08             	add    $0x8,%esp
  80005f:	6a 31                	push   $0x31
  800061:	53                   	push   %ebx
  800062:	e8 08 00 00 00       	call   80006f <forkchild>
}
  800067:	83 c4 10             	add    $0x10,%esp
  80006a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80006d:	c9                   	leave  
  80006e:	c3                   	ret    

0080006f <forkchild>:

void forktree(const char *cur);

void
forkchild(const char *cur, char branch)
{
  80006f:	55                   	push   %ebp
  800070:	89 e5                	mov    %esp,%ebp
  800072:	56                   	push   %esi
  800073:	53                   	push   %ebx
  800074:	83 ec 1c             	sub    $0x1c,%esp
  800077:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80007a:	8b 75 0c             	mov    0xc(%ebp),%esi
	char nxt[DEPTH+1];

	if (strlen(cur) >= DEPTH)
  80007d:	53                   	push   %ebx
  80007e:	e8 9d 06 00 00       	call   800720 <strlen>
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	83 f8 02             	cmp    $0x2,%eax
  800089:	7f 3a                	jg     8000c5 <forkchild+0x56>
		return;

	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  80008b:	83 ec 0c             	sub    $0xc,%esp
  80008e:	89 f0                	mov    %esi,%eax
  800090:	0f be f0             	movsbl %al,%esi
  800093:	56                   	push   %esi
  800094:	53                   	push   %ebx
  800095:	68 31 26 80 00       	push   $0x802631
  80009a:	6a 04                	push   $0x4
  80009c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80009f:	50                   	push   %eax
  8000a0:	e8 61 06 00 00       	call   800706 <snprintf>
	if (fork() == 0) {
  8000a5:	83 c4 20             	add    $0x20,%esp
  8000a8:	e8 73 0e 00 00       	call   800f20 <fork>
  8000ad:	85 c0                	test   %eax,%eax
  8000af:	75 14                	jne    8000c5 <forkchild+0x56>
		forktree(nxt);
  8000b1:	83 ec 0c             	sub    $0xc,%esp
  8000b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000b7:	50                   	push   %eax
  8000b8:	e8 76 ff ff ff       	call   800033 <forktree>
		exit();
  8000bd:	e8 65 00 00 00       	call   800127 <exit>
  8000c2:	83 c4 10             	add    $0x10,%esp
	}
}
  8000c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000c8:	5b                   	pop    %ebx
  8000c9:	5e                   	pop    %esi
  8000ca:	5d                   	pop    %ebp
  8000cb:	c3                   	ret    

008000cc <umain>:
	forkchild(cur, '1');
}

void
umain(int argc, char **argv)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	83 ec 14             	sub    $0x14,%esp
	forktree("");
  8000d2:	68 30 26 80 00       	push   $0x802630
  8000d7:	e8 57 ff ff ff       	call   800033 <forktree>
}
  8000dc:	83 c4 10             	add    $0x10,%esp
  8000df:	c9                   	leave  
  8000e0:	c3                   	ret    

008000e1 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e1:	55                   	push   %ebp
  8000e2:	89 e5                	mov    %esp,%ebp
  8000e4:	56                   	push   %esi
  8000e5:	53                   	push   %ebx
  8000e6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000e9:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000ec:	e8 2d 0a 00 00       	call   800b1e <sys_getenvid>
  8000f1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000f9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000fe:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800103:	85 db                	test   %ebx,%ebx
  800105:	7e 07                	jle    80010e <libmain+0x2d>
		binaryname = argv[0];
  800107:	8b 06                	mov    (%esi),%eax
  800109:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80010e:	83 ec 08             	sub    $0x8,%esp
  800111:	56                   	push   %esi
  800112:	53                   	push   %ebx
  800113:	e8 b4 ff ff ff       	call   8000cc <umain>

	// exit gracefully
	exit();
  800118:	e8 0a 00 00 00       	call   800127 <exit>
}
  80011d:	83 c4 10             	add    $0x10,%esp
  800120:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800123:	5b                   	pop    %ebx
  800124:	5e                   	pop    %esi
  800125:	5d                   	pop    %ebp
  800126:	c3                   	ret    

00800127 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800127:	55                   	push   %ebp
  800128:	89 e5                	mov    %esp,%ebp
  80012a:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80012d:	e8 ae 10 00 00       	call   8011e0 <close_all>
	sys_env_destroy(0);
  800132:	83 ec 0c             	sub    $0xc,%esp
  800135:	6a 00                	push   $0x0
  800137:	e8 a1 09 00 00       	call   800add <sys_env_destroy>
}
  80013c:	83 c4 10             	add    $0x10,%esp
  80013f:	c9                   	leave  
  800140:	c3                   	ret    

00800141 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800141:	55                   	push   %ebp
  800142:	89 e5                	mov    %esp,%ebp
  800144:	53                   	push   %ebx
  800145:	83 ec 04             	sub    $0x4,%esp
  800148:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80014b:	8b 13                	mov    (%ebx),%edx
  80014d:	8d 42 01             	lea    0x1(%edx),%eax
  800150:	89 03                	mov    %eax,(%ebx)
  800152:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800155:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800159:	3d ff 00 00 00       	cmp    $0xff,%eax
  80015e:	75 1a                	jne    80017a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800160:	83 ec 08             	sub    $0x8,%esp
  800163:	68 ff 00 00 00       	push   $0xff
  800168:	8d 43 08             	lea    0x8(%ebx),%eax
  80016b:	50                   	push   %eax
  80016c:	e8 2f 09 00 00       	call   800aa0 <sys_cputs>
		b->idx = 0;
  800171:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800177:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80017a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80017e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800181:	c9                   	leave  
  800182:	c3                   	ret    

00800183 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800183:	55                   	push   %ebp
  800184:	89 e5                	mov    %esp,%ebp
  800186:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80018c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800193:	00 00 00 
	b.cnt = 0;
  800196:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80019d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001a0:	ff 75 0c             	pushl  0xc(%ebp)
  8001a3:	ff 75 08             	pushl  0x8(%ebp)
  8001a6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001ac:	50                   	push   %eax
  8001ad:	68 41 01 80 00       	push   $0x800141
  8001b2:	e8 54 01 00 00       	call   80030b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001b7:	83 c4 08             	add    $0x8,%esp
  8001ba:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001c0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001c6:	50                   	push   %eax
  8001c7:	e8 d4 08 00 00       	call   800aa0 <sys_cputs>

	return b.cnt;
}
  8001cc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001d2:	c9                   	leave  
  8001d3:	c3                   	ret    

008001d4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001d4:	55                   	push   %ebp
  8001d5:	89 e5                	mov    %esp,%ebp
  8001d7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001da:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001dd:	50                   	push   %eax
  8001de:	ff 75 08             	pushl  0x8(%ebp)
  8001e1:	e8 9d ff ff ff       	call   800183 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001e6:	c9                   	leave  
  8001e7:	c3                   	ret    

008001e8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001e8:	55                   	push   %ebp
  8001e9:	89 e5                	mov    %esp,%ebp
  8001eb:	57                   	push   %edi
  8001ec:	56                   	push   %esi
  8001ed:	53                   	push   %ebx
  8001ee:	83 ec 1c             	sub    $0x1c,%esp
  8001f1:	89 c7                	mov    %eax,%edi
  8001f3:	89 d6                	mov    %edx,%esi
  8001f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001fb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001fe:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800201:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800204:	bb 00 00 00 00       	mov    $0x0,%ebx
  800209:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80020c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80020f:	39 d3                	cmp    %edx,%ebx
  800211:	72 05                	jb     800218 <printnum+0x30>
  800213:	39 45 10             	cmp    %eax,0x10(%ebp)
  800216:	77 45                	ja     80025d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800218:	83 ec 0c             	sub    $0xc,%esp
  80021b:	ff 75 18             	pushl  0x18(%ebp)
  80021e:	8b 45 14             	mov    0x14(%ebp),%eax
  800221:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800224:	53                   	push   %ebx
  800225:	ff 75 10             	pushl  0x10(%ebp)
  800228:	83 ec 08             	sub    $0x8,%esp
  80022b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80022e:	ff 75 e0             	pushl  -0x20(%ebp)
  800231:	ff 75 dc             	pushl  -0x24(%ebp)
  800234:	ff 75 d8             	pushl  -0x28(%ebp)
  800237:	e8 44 21 00 00       	call   802380 <__udivdi3>
  80023c:	83 c4 18             	add    $0x18,%esp
  80023f:	52                   	push   %edx
  800240:	50                   	push   %eax
  800241:	89 f2                	mov    %esi,%edx
  800243:	89 f8                	mov    %edi,%eax
  800245:	e8 9e ff ff ff       	call   8001e8 <printnum>
  80024a:	83 c4 20             	add    $0x20,%esp
  80024d:	eb 18                	jmp    800267 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80024f:	83 ec 08             	sub    $0x8,%esp
  800252:	56                   	push   %esi
  800253:	ff 75 18             	pushl  0x18(%ebp)
  800256:	ff d7                	call   *%edi
  800258:	83 c4 10             	add    $0x10,%esp
  80025b:	eb 03                	jmp    800260 <printnum+0x78>
  80025d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800260:	83 eb 01             	sub    $0x1,%ebx
  800263:	85 db                	test   %ebx,%ebx
  800265:	7f e8                	jg     80024f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800267:	83 ec 08             	sub    $0x8,%esp
  80026a:	56                   	push   %esi
  80026b:	83 ec 04             	sub    $0x4,%esp
  80026e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800271:	ff 75 e0             	pushl  -0x20(%ebp)
  800274:	ff 75 dc             	pushl  -0x24(%ebp)
  800277:	ff 75 d8             	pushl  -0x28(%ebp)
  80027a:	e8 31 22 00 00       	call   8024b0 <__umoddi3>
  80027f:	83 c4 14             	add    $0x14,%esp
  800282:	0f be 80 40 26 80 00 	movsbl 0x802640(%eax),%eax
  800289:	50                   	push   %eax
  80028a:	ff d7                	call   *%edi
}
  80028c:	83 c4 10             	add    $0x10,%esp
  80028f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800292:	5b                   	pop    %ebx
  800293:	5e                   	pop    %esi
  800294:	5f                   	pop    %edi
  800295:	5d                   	pop    %ebp
  800296:	c3                   	ret    

00800297 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800297:	55                   	push   %ebp
  800298:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80029a:	83 fa 01             	cmp    $0x1,%edx
  80029d:	7e 0e                	jle    8002ad <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80029f:	8b 10                	mov    (%eax),%edx
  8002a1:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002a4:	89 08                	mov    %ecx,(%eax)
  8002a6:	8b 02                	mov    (%edx),%eax
  8002a8:	8b 52 04             	mov    0x4(%edx),%edx
  8002ab:	eb 22                	jmp    8002cf <getuint+0x38>
	else if (lflag)
  8002ad:	85 d2                	test   %edx,%edx
  8002af:	74 10                	je     8002c1 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002b1:	8b 10                	mov    (%eax),%edx
  8002b3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002b6:	89 08                	mov    %ecx,(%eax)
  8002b8:	8b 02                	mov    (%edx),%eax
  8002ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8002bf:	eb 0e                	jmp    8002cf <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002c1:	8b 10                	mov    (%eax),%edx
  8002c3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002c6:	89 08                	mov    %ecx,(%eax)
  8002c8:	8b 02                	mov    (%edx),%eax
  8002ca:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002cf:	5d                   	pop    %ebp
  8002d0:	c3                   	ret    

008002d1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002d1:	55                   	push   %ebp
  8002d2:	89 e5                	mov    %esp,%ebp
  8002d4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002d7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002db:	8b 10                	mov    (%eax),%edx
  8002dd:	3b 50 04             	cmp    0x4(%eax),%edx
  8002e0:	73 0a                	jae    8002ec <sprintputch+0x1b>
		*b->buf++ = ch;
  8002e2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002e5:	89 08                	mov    %ecx,(%eax)
  8002e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ea:	88 02                	mov    %al,(%edx)
}
  8002ec:	5d                   	pop    %ebp
  8002ed:	c3                   	ret    

008002ee <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002ee:	55                   	push   %ebp
  8002ef:	89 e5                	mov    %esp,%ebp
  8002f1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002f4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002f7:	50                   	push   %eax
  8002f8:	ff 75 10             	pushl  0x10(%ebp)
  8002fb:	ff 75 0c             	pushl  0xc(%ebp)
  8002fe:	ff 75 08             	pushl  0x8(%ebp)
  800301:	e8 05 00 00 00       	call   80030b <vprintfmt>
	va_end(ap);
}
  800306:	83 c4 10             	add    $0x10,%esp
  800309:	c9                   	leave  
  80030a:	c3                   	ret    

0080030b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80030b:	55                   	push   %ebp
  80030c:	89 e5                	mov    %esp,%ebp
  80030e:	57                   	push   %edi
  80030f:	56                   	push   %esi
  800310:	53                   	push   %ebx
  800311:	83 ec 2c             	sub    $0x2c,%esp
  800314:	8b 75 08             	mov    0x8(%ebp),%esi
  800317:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80031a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80031d:	eb 12                	jmp    800331 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80031f:	85 c0                	test   %eax,%eax
  800321:	0f 84 89 03 00 00    	je     8006b0 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800327:	83 ec 08             	sub    $0x8,%esp
  80032a:	53                   	push   %ebx
  80032b:	50                   	push   %eax
  80032c:	ff d6                	call   *%esi
  80032e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800331:	83 c7 01             	add    $0x1,%edi
  800334:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800338:	83 f8 25             	cmp    $0x25,%eax
  80033b:	75 e2                	jne    80031f <vprintfmt+0x14>
  80033d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800341:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800348:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80034f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800356:	ba 00 00 00 00       	mov    $0x0,%edx
  80035b:	eb 07                	jmp    800364 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800360:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800364:	8d 47 01             	lea    0x1(%edi),%eax
  800367:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80036a:	0f b6 07             	movzbl (%edi),%eax
  80036d:	0f b6 c8             	movzbl %al,%ecx
  800370:	83 e8 23             	sub    $0x23,%eax
  800373:	3c 55                	cmp    $0x55,%al
  800375:	0f 87 1a 03 00 00    	ja     800695 <vprintfmt+0x38a>
  80037b:	0f b6 c0             	movzbl %al,%eax
  80037e:	ff 24 85 80 27 80 00 	jmp    *0x802780(,%eax,4)
  800385:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800388:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80038c:	eb d6                	jmp    800364 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800391:	b8 00 00 00 00       	mov    $0x0,%eax
  800396:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800399:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80039c:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003a0:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003a3:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003a6:	83 fa 09             	cmp    $0x9,%edx
  8003a9:	77 39                	ja     8003e4 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003ab:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003ae:	eb e9                	jmp    800399 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b3:	8d 48 04             	lea    0x4(%eax),%ecx
  8003b6:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003b9:	8b 00                	mov    (%eax),%eax
  8003bb:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003c1:	eb 27                	jmp    8003ea <vprintfmt+0xdf>
  8003c3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003c6:	85 c0                	test   %eax,%eax
  8003c8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003cd:	0f 49 c8             	cmovns %eax,%ecx
  8003d0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003d6:	eb 8c                	jmp    800364 <vprintfmt+0x59>
  8003d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003db:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003e2:	eb 80                	jmp    800364 <vprintfmt+0x59>
  8003e4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003e7:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003ea:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003ee:	0f 89 70 ff ff ff    	jns    800364 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003f4:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003f7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003fa:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800401:	e9 5e ff ff ff       	jmp    800364 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800406:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800409:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80040c:	e9 53 ff ff ff       	jmp    800364 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800411:	8b 45 14             	mov    0x14(%ebp),%eax
  800414:	8d 50 04             	lea    0x4(%eax),%edx
  800417:	89 55 14             	mov    %edx,0x14(%ebp)
  80041a:	83 ec 08             	sub    $0x8,%esp
  80041d:	53                   	push   %ebx
  80041e:	ff 30                	pushl  (%eax)
  800420:	ff d6                	call   *%esi
			break;
  800422:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800425:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800428:	e9 04 ff ff ff       	jmp    800331 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80042d:	8b 45 14             	mov    0x14(%ebp),%eax
  800430:	8d 50 04             	lea    0x4(%eax),%edx
  800433:	89 55 14             	mov    %edx,0x14(%ebp)
  800436:	8b 00                	mov    (%eax),%eax
  800438:	99                   	cltd   
  800439:	31 d0                	xor    %edx,%eax
  80043b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80043d:	83 f8 0f             	cmp    $0xf,%eax
  800440:	7f 0b                	jg     80044d <vprintfmt+0x142>
  800442:	8b 14 85 e0 28 80 00 	mov    0x8028e0(,%eax,4),%edx
  800449:	85 d2                	test   %edx,%edx
  80044b:	75 18                	jne    800465 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80044d:	50                   	push   %eax
  80044e:	68 58 26 80 00       	push   $0x802658
  800453:	53                   	push   %ebx
  800454:	56                   	push   %esi
  800455:	e8 94 fe ff ff       	call   8002ee <printfmt>
  80045a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800460:	e9 cc fe ff ff       	jmp    800331 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800465:	52                   	push   %edx
  800466:	68 9a 2a 80 00       	push   $0x802a9a
  80046b:	53                   	push   %ebx
  80046c:	56                   	push   %esi
  80046d:	e8 7c fe ff ff       	call   8002ee <printfmt>
  800472:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800475:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800478:	e9 b4 fe ff ff       	jmp    800331 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80047d:	8b 45 14             	mov    0x14(%ebp),%eax
  800480:	8d 50 04             	lea    0x4(%eax),%edx
  800483:	89 55 14             	mov    %edx,0x14(%ebp)
  800486:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800488:	85 ff                	test   %edi,%edi
  80048a:	b8 51 26 80 00       	mov    $0x802651,%eax
  80048f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800492:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800496:	0f 8e 94 00 00 00    	jle    800530 <vprintfmt+0x225>
  80049c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004a0:	0f 84 98 00 00 00    	je     80053e <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a6:	83 ec 08             	sub    $0x8,%esp
  8004a9:	ff 75 d0             	pushl  -0x30(%ebp)
  8004ac:	57                   	push   %edi
  8004ad:	e8 86 02 00 00       	call   800738 <strnlen>
  8004b2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004b5:	29 c1                	sub    %eax,%ecx
  8004b7:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004ba:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004bd:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004c1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004c4:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004c7:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c9:	eb 0f                	jmp    8004da <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004cb:	83 ec 08             	sub    $0x8,%esp
  8004ce:	53                   	push   %ebx
  8004cf:	ff 75 e0             	pushl  -0x20(%ebp)
  8004d2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d4:	83 ef 01             	sub    $0x1,%edi
  8004d7:	83 c4 10             	add    $0x10,%esp
  8004da:	85 ff                	test   %edi,%edi
  8004dc:	7f ed                	jg     8004cb <vprintfmt+0x1c0>
  8004de:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004e1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004e4:	85 c9                	test   %ecx,%ecx
  8004e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8004eb:	0f 49 c1             	cmovns %ecx,%eax
  8004ee:	29 c1                	sub    %eax,%ecx
  8004f0:	89 75 08             	mov    %esi,0x8(%ebp)
  8004f3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004f6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004f9:	89 cb                	mov    %ecx,%ebx
  8004fb:	eb 4d                	jmp    80054a <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004fd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800501:	74 1b                	je     80051e <vprintfmt+0x213>
  800503:	0f be c0             	movsbl %al,%eax
  800506:	83 e8 20             	sub    $0x20,%eax
  800509:	83 f8 5e             	cmp    $0x5e,%eax
  80050c:	76 10                	jbe    80051e <vprintfmt+0x213>
					putch('?', putdat);
  80050e:	83 ec 08             	sub    $0x8,%esp
  800511:	ff 75 0c             	pushl  0xc(%ebp)
  800514:	6a 3f                	push   $0x3f
  800516:	ff 55 08             	call   *0x8(%ebp)
  800519:	83 c4 10             	add    $0x10,%esp
  80051c:	eb 0d                	jmp    80052b <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80051e:	83 ec 08             	sub    $0x8,%esp
  800521:	ff 75 0c             	pushl  0xc(%ebp)
  800524:	52                   	push   %edx
  800525:	ff 55 08             	call   *0x8(%ebp)
  800528:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80052b:	83 eb 01             	sub    $0x1,%ebx
  80052e:	eb 1a                	jmp    80054a <vprintfmt+0x23f>
  800530:	89 75 08             	mov    %esi,0x8(%ebp)
  800533:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800536:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800539:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80053c:	eb 0c                	jmp    80054a <vprintfmt+0x23f>
  80053e:	89 75 08             	mov    %esi,0x8(%ebp)
  800541:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800544:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800547:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80054a:	83 c7 01             	add    $0x1,%edi
  80054d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800551:	0f be d0             	movsbl %al,%edx
  800554:	85 d2                	test   %edx,%edx
  800556:	74 23                	je     80057b <vprintfmt+0x270>
  800558:	85 f6                	test   %esi,%esi
  80055a:	78 a1                	js     8004fd <vprintfmt+0x1f2>
  80055c:	83 ee 01             	sub    $0x1,%esi
  80055f:	79 9c                	jns    8004fd <vprintfmt+0x1f2>
  800561:	89 df                	mov    %ebx,%edi
  800563:	8b 75 08             	mov    0x8(%ebp),%esi
  800566:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800569:	eb 18                	jmp    800583 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80056b:	83 ec 08             	sub    $0x8,%esp
  80056e:	53                   	push   %ebx
  80056f:	6a 20                	push   $0x20
  800571:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800573:	83 ef 01             	sub    $0x1,%edi
  800576:	83 c4 10             	add    $0x10,%esp
  800579:	eb 08                	jmp    800583 <vprintfmt+0x278>
  80057b:	89 df                	mov    %ebx,%edi
  80057d:	8b 75 08             	mov    0x8(%ebp),%esi
  800580:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800583:	85 ff                	test   %edi,%edi
  800585:	7f e4                	jg     80056b <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800587:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80058a:	e9 a2 fd ff ff       	jmp    800331 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80058f:	83 fa 01             	cmp    $0x1,%edx
  800592:	7e 16                	jle    8005aa <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800594:	8b 45 14             	mov    0x14(%ebp),%eax
  800597:	8d 50 08             	lea    0x8(%eax),%edx
  80059a:	89 55 14             	mov    %edx,0x14(%ebp)
  80059d:	8b 50 04             	mov    0x4(%eax),%edx
  8005a0:	8b 00                	mov    (%eax),%eax
  8005a2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a5:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005a8:	eb 32                	jmp    8005dc <vprintfmt+0x2d1>
	else if (lflag)
  8005aa:	85 d2                	test   %edx,%edx
  8005ac:	74 18                	je     8005c6 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b1:	8d 50 04             	lea    0x4(%eax),%edx
  8005b4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b7:	8b 00                	mov    (%eax),%eax
  8005b9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005bc:	89 c1                	mov    %eax,%ecx
  8005be:	c1 f9 1f             	sar    $0x1f,%ecx
  8005c1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005c4:	eb 16                	jmp    8005dc <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c9:	8d 50 04             	lea    0x4(%eax),%edx
  8005cc:	89 55 14             	mov    %edx,0x14(%ebp)
  8005cf:	8b 00                	mov    (%eax),%eax
  8005d1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d4:	89 c1                	mov    %eax,%ecx
  8005d6:	c1 f9 1f             	sar    $0x1f,%ecx
  8005d9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005dc:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005df:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005e2:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005e7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005eb:	79 74                	jns    800661 <vprintfmt+0x356>
				putch('-', putdat);
  8005ed:	83 ec 08             	sub    $0x8,%esp
  8005f0:	53                   	push   %ebx
  8005f1:	6a 2d                	push   $0x2d
  8005f3:	ff d6                	call   *%esi
				num = -(long long) num;
  8005f5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005f8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005fb:	f7 d8                	neg    %eax
  8005fd:	83 d2 00             	adc    $0x0,%edx
  800600:	f7 da                	neg    %edx
  800602:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800605:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80060a:	eb 55                	jmp    800661 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80060c:	8d 45 14             	lea    0x14(%ebp),%eax
  80060f:	e8 83 fc ff ff       	call   800297 <getuint>
			base = 10;
  800614:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800619:	eb 46                	jmp    800661 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80061b:	8d 45 14             	lea    0x14(%ebp),%eax
  80061e:	e8 74 fc ff ff       	call   800297 <getuint>
                        base = 8;
  800623:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800628:	eb 37                	jmp    800661 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80062a:	83 ec 08             	sub    $0x8,%esp
  80062d:	53                   	push   %ebx
  80062e:	6a 30                	push   $0x30
  800630:	ff d6                	call   *%esi
			putch('x', putdat);
  800632:	83 c4 08             	add    $0x8,%esp
  800635:	53                   	push   %ebx
  800636:	6a 78                	push   $0x78
  800638:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80063a:	8b 45 14             	mov    0x14(%ebp),%eax
  80063d:	8d 50 04             	lea    0x4(%eax),%edx
  800640:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800643:	8b 00                	mov    (%eax),%eax
  800645:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80064a:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80064d:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800652:	eb 0d                	jmp    800661 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800654:	8d 45 14             	lea    0x14(%ebp),%eax
  800657:	e8 3b fc ff ff       	call   800297 <getuint>
			base = 16;
  80065c:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800661:	83 ec 0c             	sub    $0xc,%esp
  800664:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800668:	57                   	push   %edi
  800669:	ff 75 e0             	pushl  -0x20(%ebp)
  80066c:	51                   	push   %ecx
  80066d:	52                   	push   %edx
  80066e:	50                   	push   %eax
  80066f:	89 da                	mov    %ebx,%edx
  800671:	89 f0                	mov    %esi,%eax
  800673:	e8 70 fb ff ff       	call   8001e8 <printnum>
			break;
  800678:	83 c4 20             	add    $0x20,%esp
  80067b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80067e:	e9 ae fc ff ff       	jmp    800331 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800683:	83 ec 08             	sub    $0x8,%esp
  800686:	53                   	push   %ebx
  800687:	51                   	push   %ecx
  800688:	ff d6                	call   *%esi
			break;
  80068a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800690:	e9 9c fc ff ff       	jmp    800331 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800695:	83 ec 08             	sub    $0x8,%esp
  800698:	53                   	push   %ebx
  800699:	6a 25                	push   $0x25
  80069b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80069d:	83 c4 10             	add    $0x10,%esp
  8006a0:	eb 03                	jmp    8006a5 <vprintfmt+0x39a>
  8006a2:	83 ef 01             	sub    $0x1,%edi
  8006a5:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006a9:	75 f7                	jne    8006a2 <vprintfmt+0x397>
  8006ab:	e9 81 fc ff ff       	jmp    800331 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006b3:	5b                   	pop    %ebx
  8006b4:	5e                   	pop    %esi
  8006b5:	5f                   	pop    %edi
  8006b6:	5d                   	pop    %ebp
  8006b7:	c3                   	ret    

008006b8 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006b8:	55                   	push   %ebp
  8006b9:	89 e5                	mov    %esp,%ebp
  8006bb:	83 ec 18             	sub    $0x18,%esp
  8006be:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006c4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006c7:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006cb:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006ce:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006d5:	85 c0                	test   %eax,%eax
  8006d7:	74 26                	je     8006ff <vsnprintf+0x47>
  8006d9:	85 d2                	test   %edx,%edx
  8006db:	7e 22                	jle    8006ff <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006dd:	ff 75 14             	pushl  0x14(%ebp)
  8006e0:	ff 75 10             	pushl  0x10(%ebp)
  8006e3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006e6:	50                   	push   %eax
  8006e7:	68 d1 02 80 00       	push   $0x8002d1
  8006ec:	e8 1a fc ff ff       	call   80030b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006f4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006fa:	83 c4 10             	add    $0x10,%esp
  8006fd:	eb 05                	jmp    800704 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006ff:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800704:	c9                   	leave  
  800705:	c3                   	ret    

00800706 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800706:	55                   	push   %ebp
  800707:	89 e5                	mov    %esp,%ebp
  800709:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80070c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80070f:	50                   	push   %eax
  800710:	ff 75 10             	pushl  0x10(%ebp)
  800713:	ff 75 0c             	pushl  0xc(%ebp)
  800716:	ff 75 08             	pushl  0x8(%ebp)
  800719:	e8 9a ff ff ff       	call   8006b8 <vsnprintf>
	va_end(ap);

	return rc;
}
  80071e:	c9                   	leave  
  80071f:	c3                   	ret    

00800720 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800720:	55                   	push   %ebp
  800721:	89 e5                	mov    %esp,%ebp
  800723:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800726:	b8 00 00 00 00       	mov    $0x0,%eax
  80072b:	eb 03                	jmp    800730 <strlen+0x10>
		n++;
  80072d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800730:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800734:	75 f7                	jne    80072d <strlen+0xd>
		n++;
	return n;
}
  800736:	5d                   	pop    %ebp
  800737:	c3                   	ret    

00800738 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800738:	55                   	push   %ebp
  800739:	89 e5                	mov    %esp,%ebp
  80073b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80073e:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800741:	ba 00 00 00 00       	mov    $0x0,%edx
  800746:	eb 03                	jmp    80074b <strnlen+0x13>
		n++;
  800748:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80074b:	39 c2                	cmp    %eax,%edx
  80074d:	74 08                	je     800757 <strnlen+0x1f>
  80074f:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800753:	75 f3                	jne    800748 <strnlen+0x10>
  800755:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800757:	5d                   	pop    %ebp
  800758:	c3                   	ret    

00800759 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800759:	55                   	push   %ebp
  80075a:	89 e5                	mov    %esp,%ebp
  80075c:	53                   	push   %ebx
  80075d:	8b 45 08             	mov    0x8(%ebp),%eax
  800760:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800763:	89 c2                	mov    %eax,%edx
  800765:	83 c2 01             	add    $0x1,%edx
  800768:	83 c1 01             	add    $0x1,%ecx
  80076b:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80076f:	88 5a ff             	mov    %bl,-0x1(%edx)
  800772:	84 db                	test   %bl,%bl
  800774:	75 ef                	jne    800765 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800776:	5b                   	pop    %ebx
  800777:	5d                   	pop    %ebp
  800778:	c3                   	ret    

00800779 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800779:	55                   	push   %ebp
  80077a:	89 e5                	mov    %esp,%ebp
  80077c:	53                   	push   %ebx
  80077d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800780:	53                   	push   %ebx
  800781:	e8 9a ff ff ff       	call   800720 <strlen>
  800786:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800789:	ff 75 0c             	pushl  0xc(%ebp)
  80078c:	01 d8                	add    %ebx,%eax
  80078e:	50                   	push   %eax
  80078f:	e8 c5 ff ff ff       	call   800759 <strcpy>
	return dst;
}
  800794:	89 d8                	mov    %ebx,%eax
  800796:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800799:	c9                   	leave  
  80079a:	c3                   	ret    

0080079b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80079b:	55                   	push   %ebp
  80079c:	89 e5                	mov    %esp,%ebp
  80079e:	56                   	push   %esi
  80079f:	53                   	push   %ebx
  8007a0:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007a6:	89 f3                	mov    %esi,%ebx
  8007a8:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007ab:	89 f2                	mov    %esi,%edx
  8007ad:	eb 0f                	jmp    8007be <strncpy+0x23>
		*dst++ = *src;
  8007af:	83 c2 01             	add    $0x1,%edx
  8007b2:	0f b6 01             	movzbl (%ecx),%eax
  8007b5:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007b8:	80 39 01             	cmpb   $0x1,(%ecx)
  8007bb:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007be:	39 da                	cmp    %ebx,%edx
  8007c0:	75 ed                	jne    8007af <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007c2:	89 f0                	mov    %esi,%eax
  8007c4:	5b                   	pop    %ebx
  8007c5:	5e                   	pop    %esi
  8007c6:	5d                   	pop    %ebp
  8007c7:	c3                   	ret    

008007c8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007c8:	55                   	push   %ebp
  8007c9:	89 e5                	mov    %esp,%ebp
  8007cb:	56                   	push   %esi
  8007cc:	53                   	push   %ebx
  8007cd:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007d3:	8b 55 10             	mov    0x10(%ebp),%edx
  8007d6:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007d8:	85 d2                	test   %edx,%edx
  8007da:	74 21                	je     8007fd <strlcpy+0x35>
  8007dc:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007e0:	89 f2                	mov    %esi,%edx
  8007e2:	eb 09                	jmp    8007ed <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007e4:	83 c2 01             	add    $0x1,%edx
  8007e7:	83 c1 01             	add    $0x1,%ecx
  8007ea:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007ed:	39 c2                	cmp    %eax,%edx
  8007ef:	74 09                	je     8007fa <strlcpy+0x32>
  8007f1:	0f b6 19             	movzbl (%ecx),%ebx
  8007f4:	84 db                	test   %bl,%bl
  8007f6:	75 ec                	jne    8007e4 <strlcpy+0x1c>
  8007f8:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007fa:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007fd:	29 f0                	sub    %esi,%eax
}
  8007ff:	5b                   	pop    %ebx
  800800:	5e                   	pop    %esi
  800801:	5d                   	pop    %ebp
  800802:	c3                   	ret    

00800803 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800803:	55                   	push   %ebp
  800804:	89 e5                	mov    %esp,%ebp
  800806:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800809:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80080c:	eb 06                	jmp    800814 <strcmp+0x11>
		p++, q++;
  80080e:	83 c1 01             	add    $0x1,%ecx
  800811:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800814:	0f b6 01             	movzbl (%ecx),%eax
  800817:	84 c0                	test   %al,%al
  800819:	74 04                	je     80081f <strcmp+0x1c>
  80081b:	3a 02                	cmp    (%edx),%al
  80081d:	74 ef                	je     80080e <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80081f:	0f b6 c0             	movzbl %al,%eax
  800822:	0f b6 12             	movzbl (%edx),%edx
  800825:	29 d0                	sub    %edx,%eax
}
  800827:	5d                   	pop    %ebp
  800828:	c3                   	ret    

00800829 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800829:	55                   	push   %ebp
  80082a:	89 e5                	mov    %esp,%ebp
  80082c:	53                   	push   %ebx
  80082d:	8b 45 08             	mov    0x8(%ebp),%eax
  800830:	8b 55 0c             	mov    0xc(%ebp),%edx
  800833:	89 c3                	mov    %eax,%ebx
  800835:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800838:	eb 06                	jmp    800840 <strncmp+0x17>
		n--, p++, q++;
  80083a:	83 c0 01             	add    $0x1,%eax
  80083d:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800840:	39 d8                	cmp    %ebx,%eax
  800842:	74 15                	je     800859 <strncmp+0x30>
  800844:	0f b6 08             	movzbl (%eax),%ecx
  800847:	84 c9                	test   %cl,%cl
  800849:	74 04                	je     80084f <strncmp+0x26>
  80084b:	3a 0a                	cmp    (%edx),%cl
  80084d:	74 eb                	je     80083a <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80084f:	0f b6 00             	movzbl (%eax),%eax
  800852:	0f b6 12             	movzbl (%edx),%edx
  800855:	29 d0                	sub    %edx,%eax
  800857:	eb 05                	jmp    80085e <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800859:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80085e:	5b                   	pop    %ebx
  80085f:	5d                   	pop    %ebp
  800860:	c3                   	ret    

00800861 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800861:	55                   	push   %ebp
  800862:	89 e5                	mov    %esp,%ebp
  800864:	8b 45 08             	mov    0x8(%ebp),%eax
  800867:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80086b:	eb 07                	jmp    800874 <strchr+0x13>
		if (*s == c)
  80086d:	38 ca                	cmp    %cl,%dl
  80086f:	74 0f                	je     800880 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800871:	83 c0 01             	add    $0x1,%eax
  800874:	0f b6 10             	movzbl (%eax),%edx
  800877:	84 d2                	test   %dl,%dl
  800879:	75 f2                	jne    80086d <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80087b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800880:	5d                   	pop    %ebp
  800881:	c3                   	ret    

00800882 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800882:	55                   	push   %ebp
  800883:	89 e5                	mov    %esp,%ebp
  800885:	8b 45 08             	mov    0x8(%ebp),%eax
  800888:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80088c:	eb 03                	jmp    800891 <strfind+0xf>
  80088e:	83 c0 01             	add    $0x1,%eax
  800891:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800894:	38 ca                	cmp    %cl,%dl
  800896:	74 04                	je     80089c <strfind+0x1a>
  800898:	84 d2                	test   %dl,%dl
  80089a:	75 f2                	jne    80088e <strfind+0xc>
			break;
	return (char *) s;
}
  80089c:	5d                   	pop    %ebp
  80089d:	c3                   	ret    

0080089e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80089e:	55                   	push   %ebp
  80089f:	89 e5                	mov    %esp,%ebp
  8008a1:	57                   	push   %edi
  8008a2:	56                   	push   %esi
  8008a3:	53                   	push   %ebx
  8008a4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008a7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008aa:	85 c9                	test   %ecx,%ecx
  8008ac:	74 36                	je     8008e4 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008ae:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008b4:	75 28                	jne    8008de <memset+0x40>
  8008b6:	f6 c1 03             	test   $0x3,%cl
  8008b9:	75 23                	jne    8008de <memset+0x40>
		c &= 0xFF;
  8008bb:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008bf:	89 d3                	mov    %edx,%ebx
  8008c1:	c1 e3 08             	shl    $0x8,%ebx
  8008c4:	89 d6                	mov    %edx,%esi
  8008c6:	c1 e6 18             	shl    $0x18,%esi
  8008c9:	89 d0                	mov    %edx,%eax
  8008cb:	c1 e0 10             	shl    $0x10,%eax
  8008ce:	09 f0                	or     %esi,%eax
  8008d0:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008d2:	89 d8                	mov    %ebx,%eax
  8008d4:	09 d0                	or     %edx,%eax
  8008d6:	c1 e9 02             	shr    $0x2,%ecx
  8008d9:	fc                   	cld    
  8008da:	f3 ab                	rep stos %eax,%es:(%edi)
  8008dc:	eb 06                	jmp    8008e4 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008e1:	fc                   	cld    
  8008e2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008e4:	89 f8                	mov    %edi,%eax
  8008e6:	5b                   	pop    %ebx
  8008e7:	5e                   	pop    %esi
  8008e8:	5f                   	pop    %edi
  8008e9:	5d                   	pop    %ebp
  8008ea:	c3                   	ret    

008008eb <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008eb:	55                   	push   %ebp
  8008ec:	89 e5                	mov    %esp,%ebp
  8008ee:	57                   	push   %edi
  8008ef:	56                   	push   %esi
  8008f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008f6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008f9:	39 c6                	cmp    %eax,%esi
  8008fb:	73 35                	jae    800932 <memmove+0x47>
  8008fd:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800900:	39 d0                	cmp    %edx,%eax
  800902:	73 2e                	jae    800932 <memmove+0x47>
		s += n;
		d += n;
  800904:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800907:	89 d6                	mov    %edx,%esi
  800909:	09 fe                	or     %edi,%esi
  80090b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800911:	75 13                	jne    800926 <memmove+0x3b>
  800913:	f6 c1 03             	test   $0x3,%cl
  800916:	75 0e                	jne    800926 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800918:	83 ef 04             	sub    $0x4,%edi
  80091b:	8d 72 fc             	lea    -0x4(%edx),%esi
  80091e:	c1 e9 02             	shr    $0x2,%ecx
  800921:	fd                   	std    
  800922:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800924:	eb 09                	jmp    80092f <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800926:	83 ef 01             	sub    $0x1,%edi
  800929:	8d 72 ff             	lea    -0x1(%edx),%esi
  80092c:	fd                   	std    
  80092d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80092f:	fc                   	cld    
  800930:	eb 1d                	jmp    80094f <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800932:	89 f2                	mov    %esi,%edx
  800934:	09 c2                	or     %eax,%edx
  800936:	f6 c2 03             	test   $0x3,%dl
  800939:	75 0f                	jne    80094a <memmove+0x5f>
  80093b:	f6 c1 03             	test   $0x3,%cl
  80093e:	75 0a                	jne    80094a <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800940:	c1 e9 02             	shr    $0x2,%ecx
  800943:	89 c7                	mov    %eax,%edi
  800945:	fc                   	cld    
  800946:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800948:	eb 05                	jmp    80094f <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80094a:	89 c7                	mov    %eax,%edi
  80094c:	fc                   	cld    
  80094d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80094f:	5e                   	pop    %esi
  800950:	5f                   	pop    %edi
  800951:	5d                   	pop    %ebp
  800952:	c3                   	ret    

00800953 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800953:	55                   	push   %ebp
  800954:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800956:	ff 75 10             	pushl  0x10(%ebp)
  800959:	ff 75 0c             	pushl  0xc(%ebp)
  80095c:	ff 75 08             	pushl  0x8(%ebp)
  80095f:	e8 87 ff ff ff       	call   8008eb <memmove>
}
  800964:	c9                   	leave  
  800965:	c3                   	ret    

00800966 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800966:	55                   	push   %ebp
  800967:	89 e5                	mov    %esp,%ebp
  800969:	56                   	push   %esi
  80096a:	53                   	push   %ebx
  80096b:	8b 45 08             	mov    0x8(%ebp),%eax
  80096e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800971:	89 c6                	mov    %eax,%esi
  800973:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800976:	eb 1a                	jmp    800992 <memcmp+0x2c>
		if (*s1 != *s2)
  800978:	0f b6 08             	movzbl (%eax),%ecx
  80097b:	0f b6 1a             	movzbl (%edx),%ebx
  80097e:	38 d9                	cmp    %bl,%cl
  800980:	74 0a                	je     80098c <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800982:	0f b6 c1             	movzbl %cl,%eax
  800985:	0f b6 db             	movzbl %bl,%ebx
  800988:	29 d8                	sub    %ebx,%eax
  80098a:	eb 0f                	jmp    80099b <memcmp+0x35>
		s1++, s2++;
  80098c:	83 c0 01             	add    $0x1,%eax
  80098f:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800992:	39 f0                	cmp    %esi,%eax
  800994:	75 e2                	jne    800978 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800996:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80099b:	5b                   	pop    %ebx
  80099c:	5e                   	pop    %esi
  80099d:	5d                   	pop    %ebp
  80099e:	c3                   	ret    

0080099f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80099f:	55                   	push   %ebp
  8009a0:	89 e5                	mov    %esp,%ebp
  8009a2:	53                   	push   %ebx
  8009a3:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009a6:	89 c1                	mov    %eax,%ecx
  8009a8:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ab:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009af:	eb 0a                	jmp    8009bb <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009b1:	0f b6 10             	movzbl (%eax),%edx
  8009b4:	39 da                	cmp    %ebx,%edx
  8009b6:	74 07                	je     8009bf <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009b8:	83 c0 01             	add    $0x1,%eax
  8009bb:	39 c8                	cmp    %ecx,%eax
  8009bd:	72 f2                	jb     8009b1 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009bf:	5b                   	pop    %ebx
  8009c0:	5d                   	pop    %ebp
  8009c1:	c3                   	ret    

008009c2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009c2:	55                   	push   %ebp
  8009c3:	89 e5                	mov    %esp,%ebp
  8009c5:	57                   	push   %edi
  8009c6:	56                   	push   %esi
  8009c7:	53                   	push   %ebx
  8009c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009cb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ce:	eb 03                	jmp    8009d3 <strtol+0x11>
		s++;
  8009d0:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009d3:	0f b6 01             	movzbl (%ecx),%eax
  8009d6:	3c 20                	cmp    $0x20,%al
  8009d8:	74 f6                	je     8009d0 <strtol+0xe>
  8009da:	3c 09                	cmp    $0x9,%al
  8009dc:	74 f2                	je     8009d0 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009de:	3c 2b                	cmp    $0x2b,%al
  8009e0:	75 0a                	jne    8009ec <strtol+0x2a>
		s++;
  8009e2:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009e5:	bf 00 00 00 00       	mov    $0x0,%edi
  8009ea:	eb 11                	jmp    8009fd <strtol+0x3b>
  8009ec:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009f1:	3c 2d                	cmp    $0x2d,%al
  8009f3:	75 08                	jne    8009fd <strtol+0x3b>
		s++, neg = 1;
  8009f5:	83 c1 01             	add    $0x1,%ecx
  8009f8:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009fd:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a03:	75 15                	jne    800a1a <strtol+0x58>
  800a05:	80 39 30             	cmpb   $0x30,(%ecx)
  800a08:	75 10                	jne    800a1a <strtol+0x58>
  800a0a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a0e:	75 7c                	jne    800a8c <strtol+0xca>
		s += 2, base = 16;
  800a10:	83 c1 02             	add    $0x2,%ecx
  800a13:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a18:	eb 16                	jmp    800a30 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a1a:	85 db                	test   %ebx,%ebx
  800a1c:	75 12                	jne    800a30 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a1e:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a23:	80 39 30             	cmpb   $0x30,(%ecx)
  800a26:	75 08                	jne    800a30 <strtol+0x6e>
		s++, base = 8;
  800a28:	83 c1 01             	add    $0x1,%ecx
  800a2b:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a30:	b8 00 00 00 00       	mov    $0x0,%eax
  800a35:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a38:	0f b6 11             	movzbl (%ecx),%edx
  800a3b:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a3e:	89 f3                	mov    %esi,%ebx
  800a40:	80 fb 09             	cmp    $0x9,%bl
  800a43:	77 08                	ja     800a4d <strtol+0x8b>
			dig = *s - '0';
  800a45:	0f be d2             	movsbl %dl,%edx
  800a48:	83 ea 30             	sub    $0x30,%edx
  800a4b:	eb 22                	jmp    800a6f <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a4d:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a50:	89 f3                	mov    %esi,%ebx
  800a52:	80 fb 19             	cmp    $0x19,%bl
  800a55:	77 08                	ja     800a5f <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a57:	0f be d2             	movsbl %dl,%edx
  800a5a:	83 ea 57             	sub    $0x57,%edx
  800a5d:	eb 10                	jmp    800a6f <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a5f:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a62:	89 f3                	mov    %esi,%ebx
  800a64:	80 fb 19             	cmp    $0x19,%bl
  800a67:	77 16                	ja     800a7f <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a69:	0f be d2             	movsbl %dl,%edx
  800a6c:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a6f:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a72:	7d 0b                	jge    800a7f <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a74:	83 c1 01             	add    $0x1,%ecx
  800a77:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a7b:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a7d:	eb b9                	jmp    800a38 <strtol+0x76>

	if (endptr)
  800a7f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a83:	74 0d                	je     800a92 <strtol+0xd0>
		*endptr = (char *) s;
  800a85:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a88:	89 0e                	mov    %ecx,(%esi)
  800a8a:	eb 06                	jmp    800a92 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a8c:	85 db                	test   %ebx,%ebx
  800a8e:	74 98                	je     800a28 <strtol+0x66>
  800a90:	eb 9e                	jmp    800a30 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a92:	89 c2                	mov    %eax,%edx
  800a94:	f7 da                	neg    %edx
  800a96:	85 ff                	test   %edi,%edi
  800a98:	0f 45 c2             	cmovne %edx,%eax
}
  800a9b:	5b                   	pop    %ebx
  800a9c:	5e                   	pop    %esi
  800a9d:	5f                   	pop    %edi
  800a9e:	5d                   	pop    %ebp
  800a9f:	c3                   	ret    

00800aa0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800aa0:	55                   	push   %ebp
  800aa1:	89 e5                	mov    %esp,%ebp
  800aa3:	57                   	push   %edi
  800aa4:	56                   	push   %esi
  800aa5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa6:	b8 00 00 00 00       	mov    $0x0,%eax
  800aab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aae:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab1:	89 c3                	mov    %eax,%ebx
  800ab3:	89 c7                	mov    %eax,%edi
  800ab5:	89 c6                	mov    %eax,%esi
  800ab7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ab9:	5b                   	pop    %ebx
  800aba:	5e                   	pop    %esi
  800abb:	5f                   	pop    %edi
  800abc:	5d                   	pop    %ebp
  800abd:	c3                   	ret    

00800abe <sys_cgetc>:

int
sys_cgetc(void)
{
  800abe:	55                   	push   %ebp
  800abf:	89 e5                	mov    %esp,%ebp
  800ac1:	57                   	push   %edi
  800ac2:	56                   	push   %esi
  800ac3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac9:	b8 01 00 00 00       	mov    $0x1,%eax
  800ace:	89 d1                	mov    %edx,%ecx
  800ad0:	89 d3                	mov    %edx,%ebx
  800ad2:	89 d7                	mov    %edx,%edi
  800ad4:	89 d6                	mov    %edx,%esi
  800ad6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ad8:	5b                   	pop    %ebx
  800ad9:	5e                   	pop    %esi
  800ada:	5f                   	pop    %edi
  800adb:	5d                   	pop    %ebp
  800adc:	c3                   	ret    

00800add <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800add:	55                   	push   %ebp
  800ade:	89 e5                	mov    %esp,%ebp
  800ae0:	57                   	push   %edi
  800ae1:	56                   	push   %esi
  800ae2:	53                   	push   %ebx
  800ae3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aeb:	b8 03 00 00 00       	mov    $0x3,%eax
  800af0:	8b 55 08             	mov    0x8(%ebp),%edx
  800af3:	89 cb                	mov    %ecx,%ebx
  800af5:	89 cf                	mov    %ecx,%edi
  800af7:	89 ce                	mov    %ecx,%esi
  800af9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800afb:	85 c0                	test   %eax,%eax
  800afd:	7e 17                	jle    800b16 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800aff:	83 ec 0c             	sub    $0xc,%esp
  800b02:	50                   	push   %eax
  800b03:	6a 03                	push   $0x3
  800b05:	68 3f 29 80 00       	push   $0x80293f
  800b0a:	6a 23                	push   $0x23
  800b0c:	68 5c 29 80 00       	push   $0x80295c
  800b11:	e8 79 16 00 00       	call   80218f <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b19:	5b                   	pop    %ebx
  800b1a:	5e                   	pop    %esi
  800b1b:	5f                   	pop    %edi
  800b1c:	5d                   	pop    %ebp
  800b1d:	c3                   	ret    

00800b1e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b1e:	55                   	push   %ebp
  800b1f:	89 e5                	mov    %esp,%ebp
  800b21:	57                   	push   %edi
  800b22:	56                   	push   %esi
  800b23:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b24:	ba 00 00 00 00       	mov    $0x0,%edx
  800b29:	b8 02 00 00 00       	mov    $0x2,%eax
  800b2e:	89 d1                	mov    %edx,%ecx
  800b30:	89 d3                	mov    %edx,%ebx
  800b32:	89 d7                	mov    %edx,%edi
  800b34:	89 d6                	mov    %edx,%esi
  800b36:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b38:	5b                   	pop    %ebx
  800b39:	5e                   	pop    %esi
  800b3a:	5f                   	pop    %edi
  800b3b:	5d                   	pop    %ebp
  800b3c:	c3                   	ret    

00800b3d <sys_yield>:

void
sys_yield(void)
{
  800b3d:	55                   	push   %ebp
  800b3e:	89 e5                	mov    %esp,%ebp
  800b40:	57                   	push   %edi
  800b41:	56                   	push   %esi
  800b42:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b43:	ba 00 00 00 00       	mov    $0x0,%edx
  800b48:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b4d:	89 d1                	mov    %edx,%ecx
  800b4f:	89 d3                	mov    %edx,%ebx
  800b51:	89 d7                	mov    %edx,%edi
  800b53:	89 d6                	mov    %edx,%esi
  800b55:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b57:	5b                   	pop    %ebx
  800b58:	5e                   	pop    %esi
  800b59:	5f                   	pop    %edi
  800b5a:	5d                   	pop    %ebp
  800b5b:	c3                   	ret    

00800b5c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b5c:	55                   	push   %ebp
  800b5d:	89 e5                	mov    %esp,%ebp
  800b5f:	57                   	push   %edi
  800b60:	56                   	push   %esi
  800b61:	53                   	push   %ebx
  800b62:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b65:	be 00 00 00 00       	mov    $0x0,%esi
  800b6a:	b8 04 00 00 00       	mov    $0x4,%eax
  800b6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b72:	8b 55 08             	mov    0x8(%ebp),%edx
  800b75:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b78:	89 f7                	mov    %esi,%edi
  800b7a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b7c:	85 c0                	test   %eax,%eax
  800b7e:	7e 17                	jle    800b97 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b80:	83 ec 0c             	sub    $0xc,%esp
  800b83:	50                   	push   %eax
  800b84:	6a 04                	push   $0x4
  800b86:	68 3f 29 80 00       	push   $0x80293f
  800b8b:	6a 23                	push   $0x23
  800b8d:	68 5c 29 80 00       	push   $0x80295c
  800b92:	e8 f8 15 00 00       	call   80218f <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b97:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b9a:	5b                   	pop    %ebx
  800b9b:	5e                   	pop    %esi
  800b9c:	5f                   	pop    %edi
  800b9d:	5d                   	pop    %ebp
  800b9e:	c3                   	ret    

00800b9f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b9f:	55                   	push   %ebp
  800ba0:	89 e5                	mov    %esp,%ebp
  800ba2:	57                   	push   %edi
  800ba3:	56                   	push   %esi
  800ba4:	53                   	push   %ebx
  800ba5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba8:	b8 05 00 00 00       	mov    $0x5,%eax
  800bad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bb6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bb9:	8b 75 18             	mov    0x18(%ebp),%esi
  800bbc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bbe:	85 c0                	test   %eax,%eax
  800bc0:	7e 17                	jle    800bd9 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc2:	83 ec 0c             	sub    $0xc,%esp
  800bc5:	50                   	push   %eax
  800bc6:	6a 05                	push   $0x5
  800bc8:	68 3f 29 80 00       	push   $0x80293f
  800bcd:	6a 23                	push   $0x23
  800bcf:	68 5c 29 80 00       	push   $0x80295c
  800bd4:	e8 b6 15 00 00       	call   80218f <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bd9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bdc:	5b                   	pop    %ebx
  800bdd:	5e                   	pop    %esi
  800bde:	5f                   	pop    %edi
  800bdf:	5d                   	pop    %ebp
  800be0:	c3                   	ret    

00800be1 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800be1:	55                   	push   %ebp
  800be2:	89 e5                	mov    %esp,%ebp
  800be4:	57                   	push   %edi
  800be5:	56                   	push   %esi
  800be6:	53                   	push   %ebx
  800be7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bea:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bef:	b8 06 00 00 00       	mov    $0x6,%eax
  800bf4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf7:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfa:	89 df                	mov    %ebx,%edi
  800bfc:	89 de                	mov    %ebx,%esi
  800bfe:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c00:	85 c0                	test   %eax,%eax
  800c02:	7e 17                	jle    800c1b <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c04:	83 ec 0c             	sub    $0xc,%esp
  800c07:	50                   	push   %eax
  800c08:	6a 06                	push   $0x6
  800c0a:	68 3f 29 80 00       	push   $0x80293f
  800c0f:	6a 23                	push   $0x23
  800c11:	68 5c 29 80 00       	push   $0x80295c
  800c16:	e8 74 15 00 00       	call   80218f <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c1b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c1e:	5b                   	pop    %ebx
  800c1f:	5e                   	pop    %esi
  800c20:	5f                   	pop    %edi
  800c21:	5d                   	pop    %ebp
  800c22:	c3                   	ret    

00800c23 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c23:	55                   	push   %ebp
  800c24:	89 e5                	mov    %esp,%ebp
  800c26:	57                   	push   %edi
  800c27:	56                   	push   %esi
  800c28:	53                   	push   %ebx
  800c29:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c31:	b8 08 00 00 00       	mov    $0x8,%eax
  800c36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c39:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3c:	89 df                	mov    %ebx,%edi
  800c3e:	89 de                	mov    %ebx,%esi
  800c40:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c42:	85 c0                	test   %eax,%eax
  800c44:	7e 17                	jle    800c5d <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c46:	83 ec 0c             	sub    $0xc,%esp
  800c49:	50                   	push   %eax
  800c4a:	6a 08                	push   $0x8
  800c4c:	68 3f 29 80 00       	push   $0x80293f
  800c51:	6a 23                	push   $0x23
  800c53:	68 5c 29 80 00       	push   $0x80295c
  800c58:	e8 32 15 00 00       	call   80218f <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c5d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c60:	5b                   	pop    %ebx
  800c61:	5e                   	pop    %esi
  800c62:	5f                   	pop    %edi
  800c63:	5d                   	pop    %ebp
  800c64:	c3                   	ret    

00800c65 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c65:	55                   	push   %ebp
  800c66:	89 e5                	mov    %esp,%ebp
  800c68:	57                   	push   %edi
  800c69:	56                   	push   %esi
  800c6a:	53                   	push   %ebx
  800c6b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c73:	b8 09 00 00 00       	mov    $0x9,%eax
  800c78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7e:	89 df                	mov    %ebx,%edi
  800c80:	89 de                	mov    %ebx,%esi
  800c82:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c84:	85 c0                	test   %eax,%eax
  800c86:	7e 17                	jle    800c9f <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c88:	83 ec 0c             	sub    $0xc,%esp
  800c8b:	50                   	push   %eax
  800c8c:	6a 09                	push   $0x9
  800c8e:	68 3f 29 80 00       	push   $0x80293f
  800c93:	6a 23                	push   $0x23
  800c95:	68 5c 29 80 00       	push   $0x80295c
  800c9a:	e8 f0 14 00 00       	call   80218f <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c9f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca2:	5b                   	pop    %ebx
  800ca3:	5e                   	pop    %esi
  800ca4:	5f                   	pop    %edi
  800ca5:	5d                   	pop    %ebp
  800ca6:	c3                   	ret    

00800ca7 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ca7:	55                   	push   %ebp
  800ca8:	89 e5                	mov    %esp,%ebp
  800caa:	57                   	push   %edi
  800cab:	56                   	push   %esi
  800cac:	53                   	push   %ebx
  800cad:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbd:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc0:	89 df                	mov    %ebx,%edi
  800cc2:	89 de                	mov    %ebx,%esi
  800cc4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cc6:	85 c0                	test   %eax,%eax
  800cc8:	7e 17                	jle    800ce1 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cca:	83 ec 0c             	sub    $0xc,%esp
  800ccd:	50                   	push   %eax
  800cce:	6a 0a                	push   $0xa
  800cd0:	68 3f 29 80 00       	push   $0x80293f
  800cd5:	6a 23                	push   $0x23
  800cd7:	68 5c 29 80 00       	push   $0x80295c
  800cdc:	e8 ae 14 00 00       	call   80218f <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ce1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce4:	5b                   	pop    %ebx
  800ce5:	5e                   	pop    %esi
  800ce6:	5f                   	pop    %edi
  800ce7:	5d                   	pop    %ebp
  800ce8:	c3                   	ret    

00800ce9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ce9:	55                   	push   %ebp
  800cea:	89 e5                	mov    %esp,%ebp
  800cec:	57                   	push   %edi
  800ced:	56                   	push   %esi
  800cee:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cef:	be 00 00 00 00       	mov    $0x0,%esi
  800cf4:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cf9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfc:	8b 55 08             	mov    0x8(%ebp),%edx
  800cff:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d02:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d05:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d07:	5b                   	pop    %ebx
  800d08:	5e                   	pop    %esi
  800d09:	5f                   	pop    %edi
  800d0a:	5d                   	pop    %ebp
  800d0b:	c3                   	ret    

00800d0c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d0c:	55                   	push   %ebp
  800d0d:	89 e5                	mov    %esp,%ebp
  800d0f:	57                   	push   %edi
  800d10:	56                   	push   %esi
  800d11:	53                   	push   %ebx
  800d12:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d15:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d1a:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d22:	89 cb                	mov    %ecx,%ebx
  800d24:	89 cf                	mov    %ecx,%edi
  800d26:	89 ce                	mov    %ecx,%esi
  800d28:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d2a:	85 c0                	test   %eax,%eax
  800d2c:	7e 17                	jle    800d45 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2e:	83 ec 0c             	sub    $0xc,%esp
  800d31:	50                   	push   %eax
  800d32:	6a 0d                	push   $0xd
  800d34:	68 3f 29 80 00       	push   $0x80293f
  800d39:	6a 23                	push   $0x23
  800d3b:	68 5c 29 80 00       	push   $0x80295c
  800d40:	e8 4a 14 00 00       	call   80218f <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d45:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d48:	5b                   	pop    %ebx
  800d49:	5e                   	pop    %esi
  800d4a:	5f                   	pop    %edi
  800d4b:	5d                   	pop    %ebp
  800d4c:	c3                   	ret    

00800d4d <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d4d:	55                   	push   %ebp
  800d4e:	89 e5                	mov    %esp,%ebp
  800d50:	57                   	push   %edi
  800d51:	56                   	push   %esi
  800d52:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d53:	ba 00 00 00 00       	mov    $0x0,%edx
  800d58:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d5d:	89 d1                	mov    %edx,%ecx
  800d5f:	89 d3                	mov    %edx,%ebx
  800d61:	89 d7                	mov    %edx,%edi
  800d63:	89 d6                	mov    %edx,%esi
  800d65:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d67:	5b                   	pop    %ebx
  800d68:	5e                   	pop    %esi
  800d69:	5f                   	pop    %edi
  800d6a:	5d                   	pop    %ebp
  800d6b:	c3                   	ret    

00800d6c <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800d6c:	55                   	push   %ebp
  800d6d:	89 e5                	mov    %esp,%ebp
  800d6f:	53                   	push   %ebx
  800d70:	83 ec 04             	sub    $0x4,%esp
	int r;
	void * address = (void *)(pn*PGSIZE);
  800d73:	89 d3                	mov    %edx,%ebx
  800d75:	c1 e3 0c             	shl    $0xc,%ebx
	
	if((uvpt[pn] & PTE_SHARE))
  800d78:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800d7f:	f6 c5 04             	test   $0x4,%ch
  800d82:	74 38                	je     800dbc <duppage+0x50>
	{
		if ((r = sys_page_map(0, address, envid, address, (uvpt[pn] | PTE_SYSCALL))) < 0)
  800d84:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d8b:	83 ec 0c             	sub    $0xc,%esp
  800d8e:	81 ca 07 0e 00 00    	or     $0xe07,%edx
  800d94:	52                   	push   %edx
  800d95:	53                   	push   %ebx
  800d96:	50                   	push   %eax
  800d97:	53                   	push   %ebx
  800d98:	6a 00                	push   $0x0
  800d9a:	e8 00 fe ff ff       	call   800b9f <sys_page_map>
  800d9f:	83 c4 20             	add    $0x20,%esp
  800da2:	85 c0                	test   %eax,%eax
  800da4:	0f 89 b8 00 00 00    	jns    800e62 <duppage+0xf6>
			panic("sys_page_map: %e", r);
  800daa:	50                   	push   %eax
  800dab:	68 6a 29 80 00       	push   $0x80296a
  800db0:	6a 4e                	push   $0x4e
  800db2:	68 7b 29 80 00       	push   $0x80297b
  800db7:	e8 d3 13 00 00       	call   80218f <_panic>
	}
	else if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW))
  800dbc:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800dc3:	f6 c1 02             	test   $0x2,%cl
  800dc6:	75 0c                	jne    800dd4 <duppage+0x68>
  800dc8:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800dcf:	f6 c5 08             	test   $0x8,%ch
  800dd2:	74 57                	je     800e2b <duppage+0xbf>
	{
		int perm = 0;
		perm |= PTE_P|PTE_U|PTE_COW;
	
		if ((r = sys_page_map(0, address, envid, address, perm)) < 0)
  800dd4:	83 ec 0c             	sub    $0xc,%esp
  800dd7:	68 05 08 00 00       	push   $0x805
  800ddc:	53                   	push   %ebx
  800ddd:	50                   	push   %eax
  800dde:	53                   	push   %ebx
  800ddf:	6a 00                	push   $0x0
  800de1:	e8 b9 fd ff ff       	call   800b9f <sys_page_map>
  800de6:	83 c4 20             	add    $0x20,%esp
  800de9:	85 c0                	test   %eax,%eax
  800deb:	79 12                	jns    800dff <duppage+0x93>
			panic("sys_page_map: %e", r);
  800ded:	50                   	push   %eax
  800dee:	68 6a 29 80 00       	push   $0x80296a
  800df3:	6a 56                	push   $0x56
  800df5:	68 7b 29 80 00       	push   $0x80297b
  800dfa:	e8 90 13 00 00       	call   80218f <_panic>
		if ((r = sys_page_map(0, address, 0, address, perm)) < 0)
  800dff:	83 ec 0c             	sub    $0xc,%esp
  800e02:	68 05 08 00 00       	push   $0x805
  800e07:	53                   	push   %ebx
  800e08:	6a 00                	push   $0x0
  800e0a:	53                   	push   %ebx
  800e0b:	6a 00                	push   $0x0
  800e0d:	e8 8d fd ff ff       	call   800b9f <sys_page_map>
  800e12:	83 c4 20             	add    $0x20,%esp
  800e15:	85 c0                	test   %eax,%eax
  800e17:	79 49                	jns    800e62 <duppage+0xf6>
			panic("sys_page_map: %e", r);
  800e19:	50                   	push   %eax
  800e1a:	68 6a 29 80 00       	push   $0x80296a
  800e1f:	6a 58                	push   $0x58
  800e21:	68 7b 29 80 00       	push   $0x80297b
  800e26:	e8 64 13 00 00       	call   80218f <_panic>
	}
	else if((uvpt[pn] & ~PTE_U) == 0)
  800e2b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e32:	f7 c2 fb ff ff ff    	test   $0xfffffffb,%edx
  800e38:	75 28                	jne    800e62 <duppage+0xf6>
	{
		//cprintf("im here");
		if ((r = sys_page_map(0, address, envid, address, PTE_P|PTE_U)) < 0)
  800e3a:	83 ec 0c             	sub    $0xc,%esp
  800e3d:	6a 05                	push   $0x5
  800e3f:	53                   	push   %ebx
  800e40:	50                   	push   %eax
  800e41:	53                   	push   %ebx
  800e42:	6a 00                	push   $0x0
  800e44:	e8 56 fd ff ff       	call   800b9f <sys_page_map>
  800e49:	83 c4 20             	add    $0x20,%esp
  800e4c:	85 c0                	test   %eax,%eax
  800e4e:	79 12                	jns    800e62 <duppage+0xf6>
			panic("sys_page_map: %e", r);	
  800e50:	50                   	push   %eax
  800e51:	68 6a 29 80 00       	push   $0x80296a
  800e56:	6a 5e                	push   $0x5e
  800e58:	68 7b 29 80 00       	push   $0x80297b
  800e5d:	e8 2d 13 00 00       	call   80218f <_panic>
	}
	return 0;
}
  800e62:	b8 00 00 00 00       	mov    $0x0,%eax
  800e67:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e6a:	c9                   	leave  
  800e6b:	c3                   	ret    

00800e6c <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e6c:	55                   	push   %ebp
  800e6d:	89 e5                	mov    %esp,%ebp
  800e6f:	53                   	push   %ebx
  800e70:	83 ec 08             	sub    $0x8,%esp
	void *addr = (void *) utf->utf_fault_va;
  800e73:	8b 45 08             	mov    0x8(%ebp),%eax
  800e76:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	unsigned pn = ((uint32_t)addr)/PGSIZE;
  800e78:	89 d8                	mov    %ebx,%eax
  800e7a:	c1 e8 0c             	shr    $0xc,%eax
	pte_t pte = uvpt[pn];
  800e7d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// Allocate a new page, mapped at temp location
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  800e84:	6a 07                	push   $0x7
  800e86:	68 00 f0 7f 00       	push   $0x7ff000
  800e8b:	6a 00                	push   $0x0
  800e8d:	e8 ca fc ff ff       	call   800b5c <sys_page_alloc>
  800e92:	83 c4 10             	add    $0x10,%esp
  800e95:	85 c0                	test   %eax,%eax
  800e97:	79 12                	jns    800eab <pgfault+0x3f>
		panic("sys_page_alloc: %e", r);
  800e99:	50                   	push   %eax
  800e9a:	68 86 29 80 00       	push   $0x802986
  800e9f:	6a 2b                	push   $0x2b
  800ea1:	68 7b 29 80 00       	push   $0x80297b
  800ea6:	e8 e4 12 00 00       	call   80218f <_panic>

	// Copy the data from the old page to this new page
	void *addr_pgstart = (void *) ROUNDDOWN(addr, PGSIZE);
  800eab:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr_pgstart, PGSIZE);
  800eb1:	83 ec 04             	sub    $0x4,%esp
  800eb4:	68 00 10 00 00       	push   $0x1000
  800eb9:	53                   	push   %ebx
  800eba:	68 00 f0 7f 00       	push   $0x7ff000
  800ebf:	e8 27 fa ff ff       	call   8008eb <memmove>

	// Move the new page to the old page's address
	if ((r = sys_page_map(0, PFTEMP, 0, addr_pgstart, PTE_P|PTE_U|PTE_W)) < 0)
  800ec4:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800ecb:	53                   	push   %ebx
  800ecc:	6a 00                	push   $0x0
  800ece:	68 00 f0 7f 00       	push   $0x7ff000
  800ed3:	6a 00                	push   $0x0
  800ed5:	e8 c5 fc ff ff       	call   800b9f <sys_page_map>
  800eda:	83 c4 20             	add    $0x20,%esp
  800edd:	85 c0                	test   %eax,%eax
  800edf:	79 12                	jns    800ef3 <pgfault+0x87>
		panic("sys_page_map: %e", r);
  800ee1:	50                   	push   %eax
  800ee2:	68 6a 29 80 00       	push   $0x80296a
  800ee7:	6a 33                	push   $0x33
  800ee9:	68 7b 29 80 00       	push   $0x80297b
  800eee:	e8 9c 12 00 00       	call   80218f <_panic>

	// Unmap the temp location
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800ef3:	83 ec 08             	sub    $0x8,%esp
  800ef6:	68 00 f0 7f 00       	push   $0x7ff000
  800efb:	6a 00                	push   $0x0
  800efd:	e8 df fc ff ff       	call   800be1 <sys_page_unmap>
  800f02:	83 c4 10             	add    $0x10,%esp
  800f05:	85 c0                	test   %eax,%eax
  800f07:	79 12                	jns    800f1b <pgfault+0xaf>
		panic("sys_page_unmap: %e", r);
  800f09:	50                   	push   %eax
  800f0a:	68 99 29 80 00       	push   $0x802999
  800f0f:	6a 37                	push   $0x37
  800f11:	68 7b 29 80 00       	push   $0x80297b
  800f16:	e8 74 12 00 00       	call   80218f <_panic>
}
  800f1b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f1e:	c9                   	leave  
  800f1f:	c3                   	ret    

00800f20 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f20:	55                   	push   %ebp
  800f21:	89 e5                	mov    %esp,%ebp
  800f23:	56                   	push   %esi
  800f24:	53                   	push   %ebx
  800f25:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
	// Set up page fault handler
	set_pgfault_handler(&pgfault);
  800f28:	68 6c 0e 80 00       	push   $0x800e6c
  800f2d:	e8 a3 12 00 00       	call   8021d5 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f32:	b8 07 00 00 00       	mov    $0x7,%eax
  800f37:	cd 30                	int    $0x30

	// Create child
	envid_t envid = sys_exofork();
  800f39:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (envid < 0) {
  800f3c:	83 c4 10             	add    $0x10,%esp
  800f3f:	85 c0                	test   %eax,%eax
  800f41:	79 12                	jns    800f55 <fork+0x35>
		panic("sys_exofork: %e", envid);
  800f43:	50                   	push   %eax
  800f44:	68 ac 29 80 00       	push   $0x8029ac
  800f49:	6a 7c                	push   $0x7c
  800f4b:	68 7b 29 80 00       	push   $0x80297b
  800f50:	e8 3a 12 00 00       	call   80218f <_panic>
		return envid;
	}
	if (envid == 0) {
  800f55:	85 c0                	test   %eax,%eax
  800f57:	75 1e                	jne    800f77 <fork+0x57>
		// We are the child.
		thisenv = &envs[ENVX(sys_getenvid())]; // Fix thisenv
  800f59:	e8 c0 fb ff ff       	call   800b1e <sys_getenvid>
  800f5e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f63:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f66:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f6b:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  800f70:	b8 00 00 00 00       	mov    $0x0,%eax
  800f75:	eb 7d                	jmp    800ff4 <fork+0xd4>

	// Set page fault handler on the child.
	// The parent needs to do it, else the child wouldn't be able to handle
	// the fault when trying to access it's stack (which happens as soon it starts)
	extern void _pgfault_upcall(void);
	sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);
  800f77:	83 ec 04             	sub    $0x4,%esp
  800f7a:	6a 07                	push   $0x7
  800f7c:	68 00 f0 bf ee       	push   $0xeebff000
  800f81:	50                   	push   %eax
  800f82:	e8 d5 fb ff ff       	call   800b5c <sys_page_alloc>
	sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  800f87:	83 c4 08             	add    $0x8,%esp
  800f8a:	68 1a 22 80 00       	push   $0x80221a
  800f8f:	ff 75 f4             	pushl  -0xc(%ebp)
  800f92:	e8 10 fd ff ff       	call   800ca7 <sys_env_set_pgfault_upcall>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  800f97:	be 04 70 80 00       	mov    $0x807004,%esi
  800f9c:	c1 ee 0c             	shr    $0xc,%esi
  800f9f:	83 c4 10             	add    $0x10,%esp
  800fa2:	bb 00 08 00 00       	mov    $0x800,%ebx
  800fa7:	eb 0d                	jmp    800fb6 <fork+0x96>
		duppage(envid, pn);
  800fa9:	89 da                	mov    %ebx,%edx
  800fab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fae:	e8 b9 fd ff ff       	call   800d6c <duppage>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  800fb3:	83 c3 01             	add    $0x1,%ebx
  800fb6:	39 f3                	cmp    %esi,%ebx
  800fb8:	76 ef                	jbe    800fa9 <fork+0x89>
	}

	// Also copy the stack we are currently running on
	// I think it should loop from ustacktop to this page, since the stack
	// can have more than 1 page
	duppage(envid, ((uint32_t) &envid)/PGSIZE);
  800fba:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800fbd:	c1 ea 0c             	shr    $0xc,%edx
  800fc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fc3:	e8 a4 fd ff ff       	call   800d6c <duppage>

	// Start the child environmnet running
	int r;
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  800fc8:	83 ec 08             	sub    $0x8,%esp
  800fcb:	6a 02                	push   $0x2
  800fcd:	ff 75 f4             	pushl  -0xc(%ebp)
  800fd0:	e8 4e fc ff ff       	call   800c23 <sys_env_set_status>
  800fd5:	83 c4 10             	add    $0x10,%esp
  800fd8:	85 c0                	test   %eax,%eax
  800fda:	79 15                	jns    800ff1 <fork+0xd1>
		panic("sys_env_set_status: %e", r);
  800fdc:	50                   	push   %eax
  800fdd:	68 bc 29 80 00       	push   $0x8029bc
  800fe2:	68 9c 00 00 00       	push   $0x9c
  800fe7:	68 7b 29 80 00       	push   $0x80297b
  800fec:	e8 9e 11 00 00       	call   80218f <_panic>
		return r;
	}

	return envid;
  800ff1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800ff4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ff7:	5b                   	pop    %ebx
  800ff8:	5e                   	pop    %esi
  800ff9:	5d                   	pop    %ebp
  800ffa:	c3                   	ret    

00800ffb <sfork>:

// Challenge!
int
sfork(void)
{
  800ffb:	55                   	push   %ebp
  800ffc:	89 e5                	mov    %esp,%ebp
  800ffe:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801001:	68 d3 29 80 00       	push   $0x8029d3
  801006:	68 a7 00 00 00       	push   $0xa7
  80100b:	68 7b 29 80 00       	push   $0x80297b
  801010:	e8 7a 11 00 00       	call   80218f <_panic>

00801015 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801015:	55                   	push   %ebp
  801016:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801018:	8b 45 08             	mov    0x8(%ebp),%eax
  80101b:	05 00 00 00 30       	add    $0x30000000,%eax
  801020:	c1 e8 0c             	shr    $0xc,%eax
}
  801023:	5d                   	pop    %ebp
  801024:	c3                   	ret    

00801025 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801025:	55                   	push   %ebp
  801026:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801028:	8b 45 08             	mov    0x8(%ebp),%eax
  80102b:	05 00 00 00 30       	add    $0x30000000,%eax
  801030:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801035:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80103a:	5d                   	pop    %ebp
  80103b:	c3                   	ret    

0080103c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80103c:	55                   	push   %ebp
  80103d:	89 e5                	mov    %esp,%ebp
  80103f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801042:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801047:	89 c2                	mov    %eax,%edx
  801049:	c1 ea 16             	shr    $0x16,%edx
  80104c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801053:	f6 c2 01             	test   $0x1,%dl
  801056:	74 11                	je     801069 <fd_alloc+0x2d>
  801058:	89 c2                	mov    %eax,%edx
  80105a:	c1 ea 0c             	shr    $0xc,%edx
  80105d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801064:	f6 c2 01             	test   $0x1,%dl
  801067:	75 09                	jne    801072 <fd_alloc+0x36>
			*fd_store = fd;
  801069:	89 01                	mov    %eax,(%ecx)
			return 0;
  80106b:	b8 00 00 00 00       	mov    $0x0,%eax
  801070:	eb 17                	jmp    801089 <fd_alloc+0x4d>
  801072:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801077:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80107c:	75 c9                	jne    801047 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80107e:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801084:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801089:	5d                   	pop    %ebp
  80108a:	c3                   	ret    

0080108b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80108b:	55                   	push   %ebp
  80108c:	89 e5                	mov    %esp,%ebp
  80108e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801091:	83 f8 1f             	cmp    $0x1f,%eax
  801094:	77 36                	ja     8010cc <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801096:	c1 e0 0c             	shl    $0xc,%eax
  801099:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80109e:	89 c2                	mov    %eax,%edx
  8010a0:	c1 ea 16             	shr    $0x16,%edx
  8010a3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010aa:	f6 c2 01             	test   $0x1,%dl
  8010ad:	74 24                	je     8010d3 <fd_lookup+0x48>
  8010af:	89 c2                	mov    %eax,%edx
  8010b1:	c1 ea 0c             	shr    $0xc,%edx
  8010b4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010bb:	f6 c2 01             	test   $0x1,%dl
  8010be:	74 1a                	je     8010da <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8010c0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010c3:	89 02                	mov    %eax,(%edx)
	return 0;
  8010c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8010ca:	eb 13                	jmp    8010df <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010cc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010d1:	eb 0c                	jmp    8010df <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010d3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010d8:	eb 05                	jmp    8010df <fd_lookup+0x54>
  8010da:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8010df:	5d                   	pop    %ebp
  8010e0:	c3                   	ret    

008010e1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8010e1:	55                   	push   %ebp
  8010e2:	89 e5                	mov    %esp,%ebp
  8010e4:	83 ec 08             	sub    $0x8,%esp
  8010e7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010ea:	ba 68 2a 80 00       	mov    $0x802a68,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8010ef:	eb 13                	jmp    801104 <dev_lookup+0x23>
  8010f1:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8010f4:	39 08                	cmp    %ecx,(%eax)
  8010f6:	75 0c                	jne    801104 <dev_lookup+0x23>
			*dev = devtab[i];
  8010f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010fb:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010fd:	b8 00 00 00 00       	mov    $0x0,%eax
  801102:	eb 2e                	jmp    801132 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801104:	8b 02                	mov    (%edx),%eax
  801106:	85 c0                	test   %eax,%eax
  801108:	75 e7                	jne    8010f1 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80110a:	a1 08 40 80 00       	mov    0x804008,%eax
  80110f:	8b 40 48             	mov    0x48(%eax),%eax
  801112:	83 ec 04             	sub    $0x4,%esp
  801115:	51                   	push   %ecx
  801116:	50                   	push   %eax
  801117:	68 ec 29 80 00       	push   $0x8029ec
  80111c:	e8 b3 f0 ff ff       	call   8001d4 <cprintf>
	*dev = 0;
  801121:	8b 45 0c             	mov    0xc(%ebp),%eax
  801124:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80112a:	83 c4 10             	add    $0x10,%esp
  80112d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801132:	c9                   	leave  
  801133:	c3                   	ret    

00801134 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801134:	55                   	push   %ebp
  801135:	89 e5                	mov    %esp,%ebp
  801137:	56                   	push   %esi
  801138:	53                   	push   %ebx
  801139:	83 ec 10             	sub    $0x10,%esp
  80113c:	8b 75 08             	mov    0x8(%ebp),%esi
  80113f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801142:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801145:	50                   	push   %eax
  801146:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80114c:	c1 e8 0c             	shr    $0xc,%eax
  80114f:	50                   	push   %eax
  801150:	e8 36 ff ff ff       	call   80108b <fd_lookup>
  801155:	83 c4 08             	add    $0x8,%esp
  801158:	85 c0                	test   %eax,%eax
  80115a:	78 05                	js     801161 <fd_close+0x2d>
	    || fd != fd2)
  80115c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80115f:	74 0c                	je     80116d <fd_close+0x39>
		return (must_exist ? r : 0);
  801161:	84 db                	test   %bl,%bl
  801163:	ba 00 00 00 00       	mov    $0x0,%edx
  801168:	0f 44 c2             	cmove  %edx,%eax
  80116b:	eb 41                	jmp    8011ae <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80116d:	83 ec 08             	sub    $0x8,%esp
  801170:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801173:	50                   	push   %eax
  801174:	ff 36                	pushl  (%esi)
  801176:	e8 66 ff ff ff       	call   8010e1 <dev_lookup>
  80117b:	89 c3                	mov    %eax,%ebx
  80117d:	83 c4 10             	add    $0x10,%esp
  801180:	85 c0                	test   %eax,%eax
  801182:	78 1a                	js     80119e <fd_close+0x6a>
		if (dev->dev_close)
  801184:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801187:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80118a:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80118f:	85 c0                	test   %eax,%eax
  801191:	74 0b                	je     80119e <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801193:	83 ec 0c             	sub    $0xc,%esp
  801196:	56                   	push   %esi
  801197:	ff d0                	call   *%eax
  801199:	89 c3                	mov    %eax,%ebx
  80119b:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80119e:	83 ec 08             	sub    $0x8,%esp
  8011a1:	56                   	push   %esi
  8011a2:	6a 00                	push   $0x0
  8011a4:	e8 38 fa ff ff       	call   800be1 <sys_page_unmap>
	return r;
  8011a9:	83 c4 10             	add    $0x10,%esp
  8011ac:	89 d8                	mov    %ebx,%eax
}
  8011ae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011b1:	5b                   	pop    %ebx
  8011b2:	5e                   	pop    %esi
  8011b3:	5d                   	pop    %ebp
  8011b4:	c3                   	ret    

008011b5 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8011b5:	55                   	push   %ebp
  8011b6:	89 e5                	mov    %esp,%ebp
  8011b8:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011be:	50                   	push   %eax
  8011bf:	ff 75 08             	pushl  0x8(%ebp)
  8011c2:	e8 c4 fe ff ff       	call   80108b <fd_lookup>
  8011c7:	83 c4 08             	add    $0x8,%esp
  8011ca:	85 c0                	test   %eax,%eax
  8011cc:	78 10                	js     8011de <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8011ce:	83 ec 08             	sub    $0x8,%esp
  8011d1:	6a 01                	push   $0x1
  8011d3:	ff 75 f4             	pushl  -0xc(%ebp)
  8011d6:	e8 59 ff ff ff       	call   801134 <fd_close>
  8011db:	83 c4 10             	add    $0x10,%esp
}
  8011de:	c9                   	leave  
  8011df:	c3                   	ret    

008011e0 <close_all>:

void
close_all(void)
{
  8011e0:	55                   	push   %ebp
  8011e1:	89 e5                	mov    %esp,%ebp
  8011e3:	53                   	push   %ebx
  8011e4:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8011e7:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8011ec:	83 ec 0c             	sub    $0xc,%esp
  8011ef:	53                   	push   %ebx
  8011f0:	e8 c0 ff ff ff       	call   8011b5 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8011f5:	83 c3 01             	add    $0x1,%ebx
  8011f8:	83 c4 10             	add    $0x10,%esp
  8011fb:	83 fb 20             	cmp    $0x20,%ebx
  8011fe:	75 ec                	jne    8011ec <close_all+0xc>
		close(i);
}
  801200:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801203:	c9                   	leave  
  801204:	c3                   	ret    

00801205 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801205:	55                   	push   %ebp
  801206:	89 e5                	mov    %esp,%ebp
  801208:	57                   	push   %edi
  801209:	56                   	push   %esi
  80120a:	53                   	push   %ebx
  80120b:	83 ec 2c             	sub    $0x2c,%esp
  80120e:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801211:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801214:	50                   	push   %eax
  801215:	ff 75 08             	pushl  0x8(%ebp)
  801218:	e8 6e fe ff ff       	call   80108b <fd_lookup>
  80121d:	83 c4 08             	add    $0x8,%esp
  801220:	85 c0                	test   %eax,%eax
  801222:	0f 88 c1 00 00 00    	js     8012e9 <dup+0xe4>
		return r;
	close(newfdnum);
  801228:	83 ec 0c             	sub    $0xc,%esp
  80122b:	56                   	push   %esi
  80122c:	e8 84 ff ff ff       	call   8011b5 <close>

	newfd = INDEX2FD(newfdnum);
  801231:	89 f3                	mov    %esi,%ebx
  801233:	c1 e3 0c             	shl    $0xc,%ebx
  801236:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80123c:	83 c4 04             	add    $0x4,%esp
  80123f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801242:	e8 de fd ff ff       	call   801025 <fd2data>
  801247:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801249:	89 1c 24             	mov    %ebx,(%esp)
  80124c:	e8 d4 fd ff ff       	call   801025 <fd2data>
  801251:	83 c4 10             	add    $0x10,%esp
  801254:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801257:	89 f8                	mov    %edi,%eax
  801259:	c1 e8 16             	shr    $0x16,%eax
  80125c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801263:	a8 01                	test   $0x1,%al
  801265:	74 37                	je     80129e <dup+0x99>
  801267:	89 f8                	mov    %edi,%eax
  801269:	c1 e8 0c             	shr    $0xc,%eax
  80126c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801273:	f6 c2 01             	test   $0x1,%dl
  801276:	74 26                	je     80129e <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801278:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80127f:	83 ec 0c             	sub    $0xc,%esp
  801282:	25 07 0e 00 00       	and    $0xe07,%eax
  801287:	50                   	push   %eax
  801288:	ff 75 d4             	pushl  -0x2c(%ebp)
  80128b:	6a 00                	push   $0x0
  80128d:	57                   	push   %edi
  80128e:	6a 00                	push   $0x0
  801290:	e8 0a f9 ff ff       	call   800b9f <sys_page_map>
  801295:	89 c7                	mov    %eax,%edi
  801297:	83 c4 20             	add    $0x20,%esp
  80129a:	85 c0                	test   %eax,%eax
  80129c:	78 2e                	js     8012cc <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80129e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8012a1:	89 d0                	mov    %edx,%eax
  8012a3:	c1 e8 0c             	shr    $0xc,%eax
  8012a6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012ad:	83 ec 0c             	sub    $0xc,%esp
  8012b0:	25 07 0e 00 00       	and    $0xe07,%eax
  8012b5:	50                   	push   %eax
  8012b6:	53                   	push   %ebx
  8012b7:	6a 00                	push   $0x0
  8012b9:	52                   	push   %edx
  8012ba:	6a 00                	push   $0x0
  8012bc:	e8 de f8 ff ff       	call   800b9f <sys_page_map>
  8012c1:	89 c7                	mov    %eax,%edi
  8012c3:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8012c6:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012c8:	85 ff                	test   %edi,%edi
  8012ca:	79 1d                	jns    8012e9 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8012cc:	83 ec 08             	sub    $0x8,%esp
  8012cf:	53                   	push   %ebx
  8012d0:	6a 00                	push   $0x0
  8012d2:	e8 0a f9 ff ff       	call   800be1 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8012d7:	83 c4 08             	add    $0x8,%esp
  8012da:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012dd:	6a 00                	push   $0x0
  8012df:	e8 fd f8 ff ff       	call   800be1 <sys_page_unmap>
	return r;
  8012e4:	83 c4 10             	add    $0x10,%esp
  8012e7:	89 f8                	mov    %edi,%eax
}
  8012e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012ec:	5b                   	pop    %ebx
  8012ed:	5e                   	pop    %esi
  8012ee:	5f                   	pop    %edi
  8012ef:	5d                   	pop    %ebp
  8012f0:	c3                   	ret    

008012f1 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8012f1:	55                   	push   %ebp
  8012f2:	89 e5                	mov    %esp,%ebp
  8012f4:	53                   	push   %ebx
  8012f5:	83 ec 14             	sub    $0x14,%esp
  8012f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012fb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012fe:	50                   	push   %eax
  8012ff:	53                   	push   %ebx
  801300:	e8 86 fd ff ff       	call   80108b <fd_lookup>
  801305:	83 c4 08             	add    $0x8,%esp
  801308:	89 c2                	mov    %eax,%edx
  80130a:	85 c0                	test   %eax,%eax
  80130c:	78 6d                	js     80137b <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80130e:	83 ec 08             	sub    $0x8,%esp
  801311:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801314:	50                   	push   %eax
  801315:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801318:	ff 30                	pushl  (%eax)
  80131a:	e8 c2 fd ff ff       	call   8010e1 <dev_lookup>
  80131f:	83 c4 10             	add    $0x10,%esp
  801322:	85 c0                	test   %eax,%eax
  801324:	78 4c                	js     801372 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801326:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801329:	8b 42 08             	mov    0x8(%edx),%eax
  80132c:	83 e0 03             	and    $0x3,%eax
  80132f:	83 f8 01             	cmp    $0x1,%eax
  801332:	75 21                	jne    801355 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801334:	a1 08 40 80 00       	mov    0x804008,%eax
  801339:	8b 40 48             	mov    0x48(%eax),%eax
  80133c:	83 ec 04             	sub    $0x4,%esp
  80133f:	53                   	push   %ebx
  801340:	50                   	push   %eax
  801341:	68 2d 2a 80 00       	push   $0x802a2d
  801346:	e8 89 ee ff ff       	call   8001d4 <cprintf>
		return -E_INVAL;
  80134b:	83 c4 10             	add    $0x10,%esp
  80134e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801353:	eb 26                	jmp    80137b <read+0x8a>
	}
	if (!dev->dev_read)
  801355:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801358:	8b 40 08             	mov    0x8(%eax),%eax
  80135b:	85 c0                	test   %eax,%eax
  80135d:	74 17                	je     801376 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80135f:	83 ec 04             	sub    $0x4,%esp
  801362:	ff 75 10             	pushl  0x10(%ebp)
  801365:	ff 75 0c             	pushl  0xc(%ebp)
  801368:	52                   	push   %edx
  801369:	ff d0                	call   *%eax
  80136b:	89 c2                	mov    %eax,%edx
  80136d:	83 c4 10             	add    $0x10,%esp
  801370:	eb 09                	jmp    80137b <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801372:	89 c2                	mov    %eax,%edx
  801374:	eb 05                	jmp    80137b <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801376:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80137b:	89 d0                	mov    %edx,%eax
  80137d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801380:	c9                   	leave  
  801381:	c3                   	ret    

00801382 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801382:	55                   	push   %ebp
  801383:	89 e5                	mov    %esp,%ebp
  801385:	57                   	push   %edi
  801386:	56                   	push   %esi
  801387:	53                   	push   %ebx
  801388:	83 ec 0c             	sub    $0xc,%esp
  80138b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80138e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801391:	bb 00 00 00 00       	mov    $0x0,%ebx
  801396:	eb 21                	jmp    8013b9 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801398:	83 ec 04             	sub    $0x4,%esp
  80139b:	89 f0                	mov    %esi,%eax
  80139d:	29 d8                	sub    %ebx,%eax
  80139f:	50                   	push   %eax
  8013a0:	89 d8                	mov    %ebx,%eax
  8013a2:	03 45 0c             	add    0xc(%ebp),%eax
  8013a5:	50                   	push   %eax
  8013a6:	57                   	push   %edi
  8013a7:	e8 45 ff ff ff       	call   8012f1 <read>
		if (m < 0)
  8013ac:	83 c4 10             	add    $0x10,%esp
  8013af:	85 c0                	test   %eax,%eax
  8013b1:	78 10                	js     8013c3 <readn+0x41>
			return m;
		if (m == 0)
  8013b3:	85 c0                	test   %eax,%eax
  8013b5:	74 0a                	je     8013c1 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013b7:	01 c3                	add    %eax,%ebx
  8013b9:	39 f3                	cmp    %esi,%ebx
  8013bb:	72 db                	jb     801398 <readn+0x16>
  8013bd:	89 d8                	mov    %ebx,%eax
  8013bf:	eb 02                	jmp    8013c3 <readn+0x41>
  8013c1:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8013c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013c6:	5b                   	pop    %ebx
  8013c7:	5e                   	pop    %esi
  8013c8:	5f                   	pop    %edi
  8013c9:	5d                   	pop    %ebp
  8013ca:	c3                   	ret    

008013cb <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8013cb:	55                   	push   %ebp
  8013cc:	89 e5                	mov    %esp,%ebp
  8013ce:	53                   	push   %ebx
  8013cf:	83 ec 14             	sub    $0x14,%esp
  8013d2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013d5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013d8:	50                   	push   %eax
  8013d9:	53                   	push   %ebx
  8013da:	e8 ac fc ff ff       	call   80108b <fd_lookup>
  8013df:	83 c4 08             	add    $0x8,%esp
  8013e2:	89 c2                	mov    %eax,%edx
  8013e4:	85 c0                	test   %eax,%eax
  8013e6:	78 68                	js     801450 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013e8:	83 ec 08             	sub    $0x8,%esp
  8013eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013ee:	50                   	push   %eax
  8013ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013f2:	ff 30                	pushl  (%eax)
  8013f4:	e8 e8 fc ff ff       	call   8010e1 <dev_lookup>
  8013f9:	83 c4 10             	add    $0x10,%esp
  8013fc:	85 c0                	test   %eax,%eax
  8013fe:	78 47                	js     801447 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801400:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801403:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801407:	75 21                	jne    80142a <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801409:	a1 08 40 80 00       	mov    0x804008,%eax
  80140e:	8b 40 48             	mov    0x48(%eax),%eax
  801411:	83 ec 04             	sub    $0x4,%esp
  801414:	53                   	push   %ebx
  801415:	50                   	push   %eax
  801416:	68 49 2a 80 00       	push   $0x802a49
  80141b:	e8 b4 ed ff ff       	call   8001d4 <cprintf>
		return -E_INVAL;
  801420:	83 c4 10             	add    $0x10,%esp
  801423:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801428:	eb 26                	jmp    801450 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80142a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80142d:	8b 52 0c             	mov    0xc(%edx),%edx
  801430:	85 d2                	test   %edx,%edx
  801432:	74 17                	je     80144b <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801434:	83 ec 04             	sub    $0x4,%esp
  801437:	ff 75 10             	pushl  0x10(%ebp)
  80143a:	ff 75 0c             	pushl  0xc(%ebp)
  80143d:	50                   	push   %eax
  80143e:	ff d2                	call   *%edx
  801440:	89 c2                	mov    %eax,%edx
  801442:	83 c4 10             	add    $0x10,%esp
  801445:	eb 09                	jmp    801450 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801447:	89 c2                	mov    %eax,%edx
  801449:	eb 05                	jmp    801450 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80144b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801450:	89 d0                	mov    %edx,%eax
  801452:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801455:	c9                   	leave  
  801456:	c3                   	ret    

00801457 <seek>:

int
seek(int fdnum, off_t offset)
{
  801457:	55                   	push   %ebp
  801458:	89 e5                	mov    %esp,%ebp
  80145a:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80145d:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801460:	50                   	push   %eax
  801461:	ff 75 08             	pushl  0x8(%ebp)
  801464:	e8 22 fc ff ff       	call   80108b <fd_lookup>
  801469:	83 c4 08             	add    $0x8,%esp
  80146c:	85 c0                	test   %eax,%eax
  80146e:	78 0e                	js     80147e <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801470:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801473:	8b 55 0c             	mov    0xc(%ebp),%edx
  801476:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801479:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80147e:	c9                   	leave  
  80147f:	c3                   	ret    

00801480 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801480:	55                   	push   %ebp
  801481:	89 e5                	mov    %esp,%ebp
  801483:	53                   	push   %ebx
  801484:	83 ec 14             	sub    $0x14,%esp
  801487:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80148a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80148d:	50                   	push   %eax
  80148e:	53                   	push   %ebx
  80148f:	e8 f7 fb ff ff       	call   80108b <fd_lookup>
  801494:	83 c4 08             	add    $0x8,%esp
  801497:	89 c2                	mov    %eax,%edx
  801499:	85 c0                	test   %eax,%eax
  80149b:	78 65                	js     801502 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80149d:	83 ec 08             	sub    $0x8,%esp
  8014a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014a3:	50                   	push   %eax
  8014a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014a7:	ff 30                	pushl  (%eax)
  8014a9:	e8 33 fc ff ff       	call   8010e1 <dev_lookup>
  8014ae:	83 c4 10             	add    $0x10,%esp
  8014b1:	85 c0                	test   %eax,%eax
  8014b3:	78 44                	js     8014f9 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014b8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014bc:	75 21                	jne    8014df <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8014be:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8014c3:	8b 40 48             	mov    0x48(%eax),%eax
  8014c6:	83 ec 04             	sub    $0x4,%esp
  8014c9:	53                   	push   %ebx
  8014ca:	50                   	push   %eax
  8014cb:	68 0c 2a 80 00       	push   $0x802a0c
  8014d0:	e8 ff ec ff ff       	call   8001d4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8014d5:	83 c4 10             	add    $0x10,%esp
  8014d8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014dd:	eb 23                	jmp    801502 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8014df:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014e2:	8b 52 18             	mov    0x18(%edx),%edx
  8014e5:	85 d2                	test   %edx,%edx
  8014e7:	74 14                	je     8014fd <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8014e9:	83 ec 08             	sub    $0x8,%esp
  8014ec:	ff 75 0c             	pushl  0xc(%ebp)
  8014ef:	50                   	push   %eax
  8014f0:	ff d2                	call   *%edx
  8014f2:	89 c2                	mov    %eax,%edx
  8014f4:	83 c4 10             	add    $0x10,%esp
  8014f7:	eb 09                	jmp    801502 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014f9:	89 c2                	mov    %eax,%edx
  8014fb:	eb 05                	jmp    801502 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8014fd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801502:	89 d0                	mov    %edx,%eax
  801504:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801507:	c9                   	leave  
  801508:	c3                   	ret    

00801509 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801509:	55                   	push   %ebp
  80150a:	89 e5                	mov    %esp,%ebp
  80150c:	53                   	push   %ebx
  80150d:	83 ec 14             	sub    $0x14,%esp
  801510:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801513:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801516:	50                   	push   %eax
  801517:	ff 75 08             	pushl  0x8(%ebp)
  80151a:	e8 6c fb ff ff       	call   80108b <fd_lookup>
  80151f:	83 c4 08             	add    $0x8,%esp
  801522:	89 c2                	mov    %eax,%edx
  801524:	85 c0                	test   %eax,%eax
  801526:	78 58                	js     801580 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801528:	83 ec 08             	sub    $0x8,%esp
  80152b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80152e:	50                   	push   %eax
  80152f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801532:	ff 30                	pushl  (%eax)
  801534:	e8 a8 fb ff ff       	call   8010e1 <dev_lookup>
  801539:	83 c4 10             	add    $0x10,%esp
  80153c:	85 c0                	test   %eax,%eax
  80153e:	78 37                	js     801577 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801540:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801543:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801547:	74 32                	je     80157b <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801549:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80154c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801553:	00 00 00 
	stat->st_isdir = 0;
  801556:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80155d:	00 00 00 
	stat->st_dev = dev;
  801560:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801566:	83 ec 08             	sub    $0x8,%esp
  801569:	53                   	push   %ebx
  80156a:	ff 75 f0             	pushl  -0x10(%ebp)
  80156d:	ff 50 14             	call   *0x14(%eax)
  801570:	89 c2                	mov    %eax,%edx
  801572:	83 c4 10             	add    $0x10,%esp
  801575:	eb 09                	jmp    801580 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801577:	89 c2                	mov    %eax,%edx
  801579:	eb 05                	jmp    801580 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80157b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801580:	89 d0                	mov    %edx,%eax
  801582:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801585:	c9                   	leave  
  801586:	c3                   	ret    

00801587 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801587:	55                   	push   %ebp
  801588:	89 e5                	mov    %esp,%ebp
  80158a:	56                   	push   %esi
  80158b:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80158c:	83 ec 08             	sub    $0x8,%esp
  80158f:	6a 00                	push   $0x0
  801591:	ff 75 08             	pushl  0x8(%ebp)
  801594:	e8 0c 02 00 00       	call   8017a5 <open>
  801599:	89 c3                	mov    %eax,%ebx
  80159b:	83 c4 10             	add    $0x10,%esp
  80159e:	85 c0                	test   %eax,%eax
  8015a0:	78 1b                	js     8015bd <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8015a2:	83 ec 08             	sub    $0x8,%esp
  8015a5:	ff 75 0c             	pushl  0xc(%ebp)
  8015a8:	50                   	push   %eax
  8015a9:	e8 5b ff ff ff       	call   801509 <fstat>
  8015ae:	89 c6                	mov    %eax,%esi
	close(fd);
  8015b0:	89 1c 24             	mov    %ebx,(%esp)
  8015b3:	e8 fd fb ff ff       	call   8011b5 <close>
	return r;
  8015b8:	83 c4 10             	add    $0x10,%esp
  8015bb:	89 f0                	mov    %esi,%eax
}
  8015bd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015c0:	5b                   	pop    %ebx
  8015c1:	5e                   	pop    %esi
  8015c2:	5d                   	pop    %ebp
  8015c3:	c3                   	ret    

008015c4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8015c4:	55                   	push   %ebp
  8015c5:	89 e5                	mov    %esp,%ebp
  8015c7:	56                   	push   %esi
  8015c8:	53                   	push   %ebx
  8015c9:	89 c6                	mov    %eax,%esi
  8015cb:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8015cd:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8015d4:	75 12                	jne    8015e8 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8015d6:	83 ec 0c             	sub    $0xc,%esp
  8015d9:	6a 01                	push   $0x1
  8015db:	e8 28 0d 00 00       	call   802308 <ipc_find_env>
  8015e0:	a3 00 40 80 00       	mov    %eax,0x804000
  8015e5:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8015e8:	6a 07                	push   $0x7
  8015ea:	68 00 50 80 00       	push   $0x805000
  8015ef:	56                   	push   %esi
  8015f0:	ff 35 00 40 80 00    	pushl  0x804000
  8015f6:	e8 b9 0c 00 00       	call   8022b4 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8015fb:	83 c4 0c             	add    $0xc,%esp
  8015fe:	6a 00                	push   $0x0
  801600:	53                   	push   %ebx
  801601:	6a 00                	push   $0x0
  801603:	e8 43 0c 00 00       	call   80224b <ipc_recv>
}
  801608:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80160b:	5b                   	pop    %ebx
  80160c:	5e                   	pop    %esi
  80160d:	5d                   	pop    %ebp
  80160e:	c3                   	ret    

0080160f <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80160f:	55                   	push   %ebp
  801610:	89 e5                	mov    %esp,%ebp
  801612:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801615:	8b 45 08             	mov    0x8(%ebp),%eax
  801618:	8b 40 0c             	mov    0xc(%eax),%eax
  80161b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801620:	8b 45 0c             	mov    0xc(%ebp),%eax
  801623:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801628:	ba 00 00 00 00       	mov    $0x0,%edx
  80162d:	b8 02 00 00 00       	mov    $0x2,%eax
  801632:	e8 8d ff ff ff       	call   8015c4 <fsipc>
}
  801637:	c9                   	leave  
  801638:	c3                   	ret    

00801639 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801639:	55                   	push   %ebp
  80163a:	89 e5                	mov    %esp,%ebp
  80163c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80163f:	8b 45 08             	mov    0x8(%ebp),%eax
  801642:	8b 40 0c             	mov    0xc(%eax),%eax
  801645:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80164a:	ba 00 00 00 00       	mov    $0x0,%edx
  80164f:	b8 06 00 00 00       	mov    $0x6,%eax
  801654:	e8 6b ff ff ff       	call   8015c4 <fsipc>
}
  801659:	c9                   	leave  
  80165a:	c3                   	ret    

0080165b <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80165b:	55                   	push   %ebp
  80165c:	89 e5                	mov    %esp,%ebp
  80165e:	53                   	push   %ebx
  80165f:	83 ec 04             	sub    $0x4,%esp
  801662:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801665:	8b 45 08             	mov    0x8(%ebp),%eax
  801668:	8b 40 0c             	mov    0xc(%eax),%eax
  80166b:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801670:	ba 00 00 00 00       	mov    $0x0,%edx
  801675:	b8 05 00 00 00       	mov    $0x5,%eax
  80167a:	e8 45 ff ff ff       	call   8015c4 <fsipc>
  80167f:	85 c0                	test   %eax,%eax
  801681:	78 2c                	js     8016af <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801683:	83 ec 08             	sub    $0x8,%esp
  801686:	68 00 50 80 00       	push   $0x805000
  80168b:	53                   	push   %ebx
  80168c:	e8 c8 f0 ff ff       	call   800759 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801691:	a1 80 50 80 00       	mov    0x805080,%eax
  801696:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80169c:	a1 84 50 80 00       	mov    0x805084,%eax
  8016a1:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8016a7:	83 c4 10             	add    $0x10,%esp
  8016aa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016b2:	c9                   	leave  
  8016b3:	c3                   	ret    

008016b4 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8016b4:	55                   	push   %ebp
  8016b5:	89 e5                	mov    %esp,%ebp
  8016b7:	53                   	push   %ebx
  8016b8:	83 ec 08             	sub    $0x8,%esp
  8016bb:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8016be:	8b 55 08             	mov    0x8(%ebp),%edx
  8016c1:	8b 52 0c             	mov    0xc(%edx),%edx
  8016c4:	89 15 00 50 80 00    	mov    %edx,0x805000
  8016ca:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8016cf:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  8016d4:	0f 46 d8             	cmovbe %eax,%ebx
	
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  8016d7:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  8016dd:	53                   	push   %ebx
  8016de:	ff 75 0c             	pushl  0xc(%ebp)
  8016e1:	68 08 50 80 00       	push   $0x805008
  8016e6:	e8 00 f2 ff ff       	call   8008eb <memmove>

	
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) 
  8016eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8016f0:	b8 04 00 00 00       	mov    $0x4,%eax
  8016f5:	e8 ca fe ff ff       	call   8015c4 <fsipc>
  8016fa:	83 c4 10             	add    $0x10,%esp
  8016fd:	85 c0                	test   %eax,%eax
  8016ff:	78 1d                	js     80171e <devfile_write+0x6a>
		return r;
	assert(r <= n_real); 
  801701:	39 d8                	cmp    %ebx,%eax
  801703:	76 19                	jbe    80171e <devfile_write+0x6a>
  801705:	68 7c 2a 80 00       	push   $0x802a7c
  80170a:	68 88 2a 80 00       	push   $0x802a88
  80170f:	68 a3 00 00 00       	push   $0xa3
  801714:	68 9d 2a 80 00       	push   $0x802a9d
  801719:	e8 71 0a 00 00       	call   80218f <_panic>
	return r;
}
  80171e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801721:	c9                   	leave  
  801722:	c3                   	ret    

00801723 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801723:	55                   	push   %ebp
  801724:	89 e5                	mov    %esp,%ebp
  801726:	56                   	push   %esi
  801727:	53                   	push   %ebx
  801728:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80172b:	8b 45 08             	mov    0x8(%ebp),%eax
  80172e:	8b 40 0c             	mov    0xc(%eax),%eax
  801731:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801736:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80173c:	ba 00 00 00 00       	mov    $0x0,%edx
  801741:	b8 03 00 00 00       	mov    $0x3,%eax
  801746:	e8 79 fe ff ff       	call   8015c4 <fsipc>
  80174b:	89 c3                	mov    %eax,%ebx
  80174d:	85 c0                	test   %eax,%eax
  80174f:	78 4b                	js     80179c <devfile_read+0x79>
		return r;
	assert(r <= n);
  801751:	39 c6                	cmp    %eax,%esi
  801753:	73 16                	jae    80176b <devfile_read+0x48>
  801755:	68 a8 2a 80 00       	push   $0x802aa8
  80175a:	68 88 2a 80 00       	push   $0x802a88
  80175f:	6a 7c                	push   $0x7c
  801761:	68 9d 2a 80 00       	push   $0x802a9d
  801766:	e8 24 0a 00 00       	call   80218f <_panic>
	assert(r <= PGSIZE);
  80176b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801770:	7e 16                	jle    801788 <devfile_read+0x65>
  801772:	68 af 2a 80 00       	push   $0x802aaf
  801777:	68 88 2a 80 00       	push   $0x802a88
  80177c:	6a 7d                	push   $0x7d
  80177e:	68 9d 2a 80 00       	push   $0x802a9d
  801783:	e8 07 0a 00 00       	call   80218f <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801788:	83 ec 04             	sub    $0x4,%esp
  80178b:	50                   	push   %eax
  80178c:	68 00 50 80 00       	push   $0x805000
  801791:	ff 75 0c             	pushl  0xc(%ebp)
  801794:	e8 52 f1 ff ff       	call   8008eb <memmove>
	return r;
  801799:	83 c4 10             	add    $0x10,%esp
}
  80179c:	89 d8                	mov    %ebx,%eax
  80179e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017a1:	5b                   	pop    %ebx
  8017a2:	5e                   	pop    %esi
  8017a3:	5d                   	pop    %ebp
  8017a4:	c3                   	ret    

008017a5 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8017a5:	55                   	push   %ebp
  8017a6:	89 e5                	mov    %esp,%ebp
  8017a8:	53                   	push   %ebx
  8017a9:	83 ec 20             	sub    $0x20,%esp
  8017ac:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8017af:	53                   	push   %ebx
  8017b0:	e8 6b ef ff ff       	call   800720 <strlen>
  8017b5:	83 c4 10             	add    $0x10,%esp
  8017b8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017bd:	7f 67                	jg     801826 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017bf:	83 ec 0c             	sub    $0xc,%esp
  8017c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017c5:	50                   	push   %eax
  8017c6:	e8 71 f8 ff ff       	call   80103c <fd_alloc>
  8017cb:	83 c4 10             	add    $0x10,%esp
		return r;
  8017ce:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017d0:	85 c0                	test   %eax,%eax
  8017d2:	78 57                	js     80182b <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8017d4:	83 ec 08             	sub    $0x8,%esp
  8017d7:	53                   	push   %ebx
  8017d8:	68 00 50 80 00       	push   $0x805000
  8017dd:	e8 77 ef ff ff       	call   800759 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8017e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017e5:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8017ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017ed:	b8 01 00 00 00       	mov    $0x1,%eax
  8017f2:	e8 cd fd ff ff       	call   8015c4 <fsipc>
  8017f7:	89 c3                	mov    %eax,%ebx
  8017f9:	83 c4 10             	add    $0x10,%esp
  8017fc:	85 c0                	test   %eax,%eax
  8017fe:	79 14                	jns    801814 <open+0x6f>
		fd_close(fd, 0);
  801800:	83 ec 08             	sub    $0x8,%esp
  801803:	6a 00                	push   $0x0
  801805:	ff 75 f4             	pushl  -0xc(%ebp)
  801808:	e8 27 f9 ff ff       	call   801134 <fd_close>
		return r;
  80180d:	83 c4 10             	add    $0x10,%esp
  801810:	89 da                	mov    %ebx,%edx
  801812:	eb 17                	jmp    80182b <open+0x86>
	}

	return fd2num(fd);
  801814:	83 ec 0c             	sub    $0xc,%esp
  801817:	ff 75 f4             	pushl  -0xc(%ebp)
  80181a:	e8 f6 f7 ff ff       	call   801015 <fd2num>
  80181f:	89 c2                	mov    %eax,%edx
  801821:	83 c4 10             	add    $0x10,%esp
  801824:	eb 05                	jmp    80182b <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801826:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80182b:	89 d0                	mov    %edx,%eax
  80182d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801830:	c9                   	leave  
  801831:	c3                   	ret    

00801832 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801832:	55                   	push   %ebp
  801833:	89 e5                	mov    %esp,%ebp
  801835:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801838:	ba 00 00 00 00       	mov    $0x0,%edx
  80183d:	b8 08 00 00 00       	mov    $0x8,%eax
  801842:	e8 7d fd ff ff       	call   8015c4 <fsipc>
}
  801847:	c9                   	leave  
  801848:	c3                   	ret    

00801849 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801849:	55                   	push   %ebp
  80184a:	89 e5                	mov    %esp,%ebp
  80184c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  80184f:	68 bb 2a 80 00       	push   $0x802abb
  801854:	ff 75 0c             	pushl  0xc(%ebp)
  801857:	e8 fd ee ff ff       	call   800759 <strcpy>
	return 0;
}
  80185c:	b8 00 00 00 00       	mov    $0x0,%eax
  801861:	c9                   	leave  
  801862:	c3                   	ret    

00801863 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801863:	55                   	push   %ebp
  801864:	89 e5                	mov    %esp,%ebp
  801866:	53                   	push   %ebx
  801867:	83 ec 10             	sub    $0x10,%esp
  80186a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80186d:	53                   	push   %ebx
  80186e:	e8 ce 0a 00 00       	call   802341 <pageref>
  801873:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801876:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  80187b:	83 f8 01             	cmp    $0x1,%eax
  80187e:	75 10                	jne    801890 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801880:	83 ec 0c             	sub    $0xc,%esp
  801883:	ff 73 0c             	pushl  0xc(%ebx)
  801886:	e8 c0 02 00 00       	call   801b4b <nsipc_close>
  80188b:	89 c2                	mov    %eax,%edx
  80188d:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801890:	89 d0                	mov    %edx,%eax
  801892:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801895:	c9                   	leave  
  801896:	c3                   	ret    

00801897 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801897:	55                   	push   %ebp
  801898:	89 e5                	mov    %esp,%ebp
  80189a:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  80189d:	6a 00                	push   $0x0
  80189f:	ff 75 10             	pushl  0x10(%ebp)
  8018a2:	ff 75 0c             	pushl  0xc(%ebp)
  8018a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a8:	ff 70 0c             	pushl  0xc(%eax)
  8018ab:	e8 78 03 00 00       	call   801c28 <nsipc_send>
}
  8018b0:	c9                   	leave  
  8018b1:	c3                   	ret    

008018b2 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8018b2:	55                   	push   %ebp
  8018b3:	89 e5                	mov    %esp,%ebp
  8018b5:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8018b8:	6a 00                	push   $0x0
  8018ba:	ff 75 10             	pushl  0x10(%ebp)
  8018bd:	ff 75 0c             	pushl  0xc(%ebp)
  8018c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c3:	ff 70 0c             	pushl  0xc(%eax)
  8018c6:	e8 f1 02 00 00       	call   801bbc <nsipc_recv>
}
  8018cb:	c9                   	leave  
  8018cc:	c3                   	ret    

008018cd <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8018cd:	55                   	push   %ebp
  8018ce:	89 e5                	mov    %esp,%ebp
  8018d0:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8018d3:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8018d6:	52                   	push   %edx
  8018d7:	50                   	push   %eax
  8018d8:	e8 ae f7 ff ff       	call   80108b <fd_lookup>
  8018dd:	83 c4 10             	add    $0x10,%esp
  8018e0:	85 c0                	test   %eax,%eax
  8018e2:	78 17                	js     8018fb <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8018e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018e7:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  8018ed:	39 08                	cmp    %ecx,(%eax)
  8018ef:	75 05                	jne    8018f6 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8018f1:	8b 40 0c             	mov    0xc(%eax),%eax
  8018f4:	eb 05                	jmp    8018fb <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  8018f6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  8018fb:	c9                   	leave  
  8018fc:	c3                   	ret    

008018fd <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  8018fd:	55                   	push   %ebp
  8018fe:	89 e5                	mov    %esp,%ebp
  801900:	56                   	push   %esi
  801901:	53                   	push   %ebx
  801902:	83 ec 1c             	sub    $0x1c,%esp
  801905:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801907:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80190a:	50                   	push   %eax
  80190b:	e8 2c f7 ff ff       	call   80103c <fd_alloc>
  801910:	89 c3                	mov    %eax,%ebx
  801912:	83 c4 10             	add    $0x10,%esp
  801915:	85 c0                	test   %eax,%eax
  801917:	78 1b                	js     801934 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801919:	83 ec 04             	sub    $0x4,%esp
  80191c:	68 07 04 00 00       	push   $0x407
  801921:	ff 75 f4             	pushl  -0xc(%ebp)
  801924:	6a 00                	push   $0x0
  801926:	e8 31 f2 ff ff       	call   800b5c <sys_page_alloc>
  80192b:	89 c3                	mov    %eax,%ebx
  80192d:	83 c4 10             	add    $0x10,%esp
  801930:	85 c0                	test   %eax,%eax
  801932:	79 10                	jns    801944 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801934:	83 ec 0c             	sub    $0xc,%esp
  801937:	56                   	push   %esi
  801938:	e8 0e 02 00 00       	call   801b4b <nsipc_close>
		return r;
  80193d:	83 c4 10             	add    $0x10,%esp
  801940:	89 d8                	mov    %ebx,%eax
  801942:	eb 24                	jmp    801968 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801944:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80194a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80194d:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  80194f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801952:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801959:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  80195c:	83 ec 0c             	sub    $0xc,%esp
  80195f:	50                   	push   %eax
  801960:	e8 b0 f6 ff ff       	call   801015 <fd2num>
  801965:	83 c4 10             	add    $0x10,%esp
}
  801968:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80196b:	5b                   	pop    %ebx
  80196c:	5e                   	pop    %esi
  80196d:	5d                   	pop    %ebp
  80196e:	c3                   	ret    

0080196f <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80196f:	55                   	push   %ebp
  801970:	89 e5                	mov    %esp,%ebp
  801972:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801975:	8b 45 08             	mov    0x8(%ebp),%eax
  801978:	e8 50 ff ff ff       	call   8018cd <fd2sockid>
		return r;
  80197d:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  80197f:	85 c0                	test   %eax,%eax
  801981:	78 1f                	js     8019a2 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801983:	83 ec 04             	sub    $0x4,%esp
  801986:	ff 75 10             	pushl  0x10(%ebp)
  801989:	ff 75 0c             	pushl  0xc(%ebp)
  80198c:	50                   	push   %eax
  80198d:	e8 12 01 00 00       	call   801aa4 <nsipc_accept>
  801992:	83 c4 10             	add    $0x10,%esp
		return r;
  801995:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801997:	85 c0                	test   %eax,%eax
  801999:	78 07                	js     8019a2 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  80199b:	e8 5d ff ff ff       	call   8018fd <alloc_sockfd>
  8019a0:	89 c1                	mov    %eax,%ecx
}
  8019a2:	89 c8                	mov    %ecx,%eax
  8019a4:	c9                   	leave  
  8019a5:	c3                   	ret    

008019a6 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8019a6:	55                   	push   %ebp
  8019a7:	89 e5                	mov    %esp,%ebp
  8019a9:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8019af:	e8 19 ff ff ff       	call   8018cd <fd2sockid>
  8019b4:	85 c0                	test   %eax,%eax
  8019b6:	78 12                	js     8019ca <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  8019b8:	83 ec 04             	sub    $0x4,%esp
  8019bb:	ff 75 10             	pushl  0x10(%ebp)
  8019be:	ff 75 0c             	pushl  0xc(%ebp)
  8019c1:	50                   	push   %eax
  8019c2:	e8 2d 01 00 00       	call   801af4 <nsipc_bind>
  8019c7:	83 c4 10             	add    $0x10,%esp
}
  8019ca:	c9                   	leave  
  8019cb:	c3                   	ret    

008019cc <shutdown>:

int
shutdown(int s, int how)
{
  8019cc:	55                   	push   %ebp
  8019cd:	89 e5                	mov    %esp,%ebp
  8019cf:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d5:	e8 f3 fe ff ff       	call   8018cd <fd2sockid>
  8019da:	85 c0                	test   %eax,%eax
  8019dc:	78 0f                	js     8019ed <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8019de:	83 ec 08             	sub    $0x8,%esp
  8019e1:	ff 75 0c             	pushl  0xc(%ebp)
  8019e4:	50                   	push   %eax
  8019e5:	e8 3f 01 00 00       	call   801b29 <nsipc_shutdown>
  8019ea:	83 c4 10             	add    $0x10,%esp
}
  8019ed:	c9                   	leave  
  8019ee:	c3                   	ret    

008019ef <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8019ef:	55                   	push   %ebp
  8019f0:	89 e5                	mov    %esp,%ebp
  8019f2:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f8:	e8 d0 fe ff ff       	call   8018cd <fd2sockid>
  8019fd:	85 c0                	test   %eax,%eax
  8019ff:	78 12                	js     801a13 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801a01:	83 ec 04             	sub    $0x4,%esp
  801a04:	ff 75 10             	pushl  0x10(%ebp)
  801a07:	ff 75 0c             	pushl  0xc(%ebp)
  801a0a:	50                   	push   %eax
  801a0b:	e8 55 01 00 00       	call   801b65 <nsipc_connect>
  801a10:	83 c4 10             	add    $0x10,%esp
}
  801a13:	c9                   	leave  
  801a14:	c3                   	ret    

00801a15 <listen>:

int
listen(int s, int backlog)
{
  801a15:	55                   	push   %ebp
  801a16:	89 e5                	mov    %esp,%ebp
  801a18:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a1b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a1e:	e8 aa fe ff ff       	call   8018cd <fd2sockid>
  801a23:	85 c0                	test   %eax,%eax
  801a25:	78 0f                	js     801a36 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801a27:	83 ec 08             	sub    $0x8,%esp
  801a2a:	ff 75 0c             	pushl  0xc(%ebp)
  801a2d:	50                   	push   %eax
  801a2e:	e8 67 01 00 00       	call   801b9a <nsipc_listen>
  801a33:	83 c4 10             	add    $0x10,%esp
}
  801a36:	c9                   	leave  
  801a37:	c3                   	ret    

00801a38 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801a38:	55                   	push   %ebp
  801a39:	89 e5                	mov    %esp,%ebp
  801a3b:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801a3e:	ff 75 10             	pushl  0x10(%ebp)
  801a41:	ff 75 0c             	pushl  0xc(%ebp)
  801a44:	ff 75 08             	pushl  0x8(%ebp)
  801a47:	e8 3a 02 00 00       	call   801c86 <nsipc_socket>
  801a4c:	83 c4 10             	add    $0x10,%esp
  801a4f:	85 c0                	test   %eax,%eax
  801a51:	78 05                	js     801a58 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801a53:	e8 a5 fe ff ff       	call   8018fd <alloc_sockfd>
}
  801a58:	c9                   	leave  
  801a59:	c3                   	ret    

00801a5a <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801a5a:	55                   	push   %ebp
  801a5b:	89 e5                	mov    %esp,%ebp
  801a5d:	53                   	push   %ebx
  801a5e:	83 ec 04             	sub    $0x4,%esp
  801a61:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801a63:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801a6a:	75 12                	jne    801a7e <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801a6c:	83 ec 0c             	sub    $0xc,%esp
  801a6f:	6a 02                	push   $0x2
  801a71:	e8 92 08 00 00       	call   802308 <ipc_find_env>
  801a76:	a3 04 40 80 00       	mov    %eax,0x804004
  801a7b:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801a7e:	6a 07                	push   $0x7
  801a80:	68 00 60 80 00       	push   $0x806000
  801a85:	53                   	push   %ebx
  801a86:	ff 35 04 40 80 00    	pushl  0x804004
  801a8c:	e8 23 08 00 00       	call   8022b4 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801a91:	83 c4 0c             	add    $0xc,%esp
  801a94:	6a 00                	push   $0x0
  801a96:	6a 00                	push   $0x0
  801a98:	6a 00                	push   $0x0
  801a9a:	e8 ac 07 00 00       	call   80224b <ipc_recv>
}
  801a9f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801aa2:	c9                   	leave  
  801aa3:	c3                   	ret    

00801aa4 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801aa4:	55                   	push   %ebp
  801aa5:	89 e5                	mov    %esp,%ebp
  801aa7:	56                   	push   %esi
  801aa8:	53                   	push   %ebx
  801aa9:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801aac:	8b 45 08             	mov    0x8(%ebp),%eax
  801aaf:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801ab4:	8b 06                	mov    (%esi),%eax
  801ab6:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801abb:	b8 01 00 00 00       	mov    $0x1,%eax
  801ac0:	e8 95 ff ff ff       	call   801a5a <nsipc>
  801ac5:	89 c3                	mov    %eax,%ebx
  801ac7:	85 c0                	test   %eax,%eax
  801ac9:	78 20                	js     801aeb <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801acb:	83 ec 04             	sub    $0x4,%esp
  801ace:	ff 35 10 60 80 00    	pushl  0x806010
  801ad4:	68 00 60 80 00       	push   $0x806000
  801ad9:	ff 75 0c             	pushl  0xc(%ebp)
  801adc:	e8 0a ee ff ff       	call   8008eb <memmove>
		*addrlen = ret->ret_addrlen;
  801ae1:	a1 10 60 80 00       	mov    0x806010,%eax
  801ae6:	89 06                	mov    %eax,(%esi)
  801ae8:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801aeb:	89 d8                	mov    %ebx,%eax
  801aed:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801af0:	5b                   	pop    %ebx
  801af1:	5e                   	pop    %esi
  801af2:	5d                   	pop    %ebp
  801af3:	c3                   	ret    

00801af4 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801af4:	55                   	push   %ebp
  801af5:	89 e5                	mov    %esp,%ebp
  801af7:	53                   	push   %ebx
  801af8:	83 ec 08             	sub    $0x8,%esp
  801afb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801afe:	8b 45 08             	mov    0x8(%ebp),%eax
  801b01:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801b06:	53                   	push   %ebx
  801b07:	ff 75 0c             	pushl  0xc(%ebp)
  801b0a:	68 04 60 80 00       	push   $0x806004
  801b0f:	e8 d7 ed ff ff       	call   8008eb <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801b14:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801b1a:	b8 02 00 00 00       	mov    $0x2,%eax
  801b1f:	e8 36 ff ff ff       	call   801a5a <nsipc>
}
  801b24:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b27:	c9                   	leave  
  801b28:	c3                   	ret    

00801b29 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801b29:	55                   	push   %ebp
  801b2a:	89 e5                	mov    %esp,%ebp
  801b2c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801b2f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b32:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801b37:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b3a:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801b3f:	b8 03 00 00 00       	mov    $0x3,%eax
  801b44:	e8 11 ff ff ff       	call   801a5a <nsipc>
}
  801b49:	c9                   	leave  
  801b4a:	c3                   	ret    

00801b4b <nsipc_close>:

int
nsipc_close(int s)
{
  801b4b:	55                   	push   %ebp
  801b4c:	89 e5                	mov    %esp,%ebp
  801b4e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801b51:	8b 45 08             	mov    0x8(%ebp),%eax
  801b54:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801b59:	b8 04 00 00 00       	mov    $0x4,%eax
  801b5e:	e8 f7 fe ff ff       	call   801a5a <nsipc>
}
  801b63:	c9                   	leave  
  801b64:	c3                   	ret    

00801b65 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801b65:	55                   	push   %ebp
  801b66:	89 e5                	mov    %esp,%ebp
  801b68:	53                   	push   %ebx
  801b69:	83 ec 08             	sub    $0x8,%esp
  801b6c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801b6f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b72:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801b77:	53                   	push   %ebx
  801b78:	ff 75 0c             	pushl  0xc(%ebp)
  801b7b:	68 04 60 80 00       	push   $0x806004
  801b80:	e8 66 ed ff ff       	call   8008eb <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801b85:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801b8b:	b8 05 00 00 00       	mov    $0x5,%eax
  801b90:	e8 c5 fe ff ff       	call   801a5a <nsipc>
}
  801b95:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b98:	c9                   	leave  
  801b99:	c3                   	ret    

00801b9a <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801b9a:	55                   	push   %ebp
  801b9b:	89 e5                	mov    %esp,%ebp
  801b9d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801ba0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba3:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801ba8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bab:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801bb0:	b8 06 00 00 00       	mov    $0x6,%eax
  801bb5:	e8 a0 fe ff ff       	call   801a5a <nsipc>
}
  801bba:	c9                   	leave  
  801bbb:	c3                   	ret    

00801bbc <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801bbc:	55                   	push   %ebp
  801bbd:	89 e5                	mov    %esp,%ebp
  801bbf:	56                   	push   %esi
  801bc0:	53                   	push   %ebx
  801bc1:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801bc4:	8b 45 08             	mov    0x8(%ebp),%eax
  801bc7:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801bcc:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801bd2:	8b 45 14             	mov    0x14(%ebp),%eax
  801bd5:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801bda:	b8 07 00 00 00       	mov    $0x7,%eax
  801bdf:	e8 76 fe ff ff       	call   801a5a <nsipc>
  801be4:	89 c3                	mov    %eax,%ebx
  801be6:	85 c0                	test   %eax,%eax
  801be8:	78 35                	js     801c1f <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801bea:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801bef:	7f 04                	jg     801bf5 <nsipc_recv+0x39>
  801bf1:	39 c6                	cmp    %eax,%esi
  801bf3:	7d 16                	jge    801c0b <nsipc_recv+0x4f>
  801bf5:	68 c7 2a 80 00       	push   $0x802ac7
  801bfa:	68 88 2a 80 00       	push   $0x802a88
  801bff:	6a 62                	push   $0x62
  801c01:	68 dc 2a 80 00       	push   $0x802adc
  801c06:	e8 84 05 00 00       	call   80218f <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801c0b:	83 ec 04             	sub    $0x4,%esp
  801c0e:	50                   	push   %eax
  801c0f:	68 00 60 80 00       	push   $0x806000
  801c14:	ff 75 0c             	pushl  0xc(%ebp)
  801c17:	e8 cf ec ff ff       	call   8008eb <memmove>
  801c1c:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801c1f:	89 d8                	mov    %ebx,%eax
  801c21:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c24:	5b                   	pop    %ebx
  801c25:	5e                   	pop    %esi
  801c26:	5d                   	pop    %ebp
  801c27:	c3                   	ret    

00801c28 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801c28:	55                   	push   %ebp
  801c29:	89 e5                	mov    %esp,%ebp
  801c2b:	53                   	push   %ebx
  801c2c:	83 ec 04             	sub    $0x4,%esp
  801c2f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801c32:	8b 45 08             	mov    0x8(%ebp),%eax
  801c35:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801c3a:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801c40:	7e 16                	jle    801c58 <nsipc_send+0x30>
  801c42:	68 e8 2a 80 00       	push   $0x802ae8
  801c47:	68 88 2a 80 00       	push   $0x802a88
  801c4c:	6a 6d                	push   $0x6d
  801c4e:	68 dc 2a 80 00       	push   $0x802adc
  801c53:	e8 37 05 00 00       	call   80218f <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801c58:	83 ec 04             	sub    $0x4,%esp
  801c5b:	53                   	push   %ebx
  801c5c:	ff 75 0c             	pushl  0xc(%ebp)
  801c5f:	68 0c 60 80 00       	push   $0x80600c
  801c64:	e8 82 ec ff ff       	call   8008eb <memmove>
	nsipcbuf.send.req_size = size;
  801c69:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801c6f:	8b 45 14             	mov    0x14(%ebp),%eax
  801c72:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801c77:	b8 08 00 00 00       	mov    $0x8,%eax
  801c7c:	e8 d9 fd ff ff       	call   801a5a <nsipc>
}
  801c81:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c84:	c9                   	leave  
  801c85:	c3                   	ret    

00801c86 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801c86:	55                   	push   %ebp
  801c87:	89 e5                	mov    %esp,%ebp
  801c89:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801c8c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c8f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801c94:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c97:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801c9c:	8b 45 10             	mov    0x10(%ebp),%eax
  801c9f:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801ca4:	b8 09 00 00 00       	mov    $0x9,%eax
  801ca9:	e8 ac fd ff ff       	call   801a5a <nsipc>
}
  801cae:	c9                   	leave  
  801caf:	c3                   	ret    

00801cb0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801cb0:	55                   	push   %ebp
  801cb1:	89 e5                	mov    %esp,%ebp
  801cb3:	56                   	push   %esi
  801cb4:	53                   	push   %ebx
  801cb5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801cb8:	83 ec 0c             	sub    $0xc,%esp
  801cbb:	ff 75 08             	pushl  0x8(%ebp)
  801cbe:	e8 62 f3 ff ff       	call   801025 <fd2data>
  801cc3:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801cc5:	83 c4 08             	add    $0x8,%esp
  801cc8:	68 f4 2a 80 00       	push   $0x802af4
  801ccd:	53                   	push   %ebx
  801cce:	e8 86 ea ff ff       	call   800759 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801cd3:	8b 46 04             	mov    0x4(%esi),%eax
  801cd6:	2b 06                	sub    (%esi),%eax
  801cd8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801cde:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ce5:	00 00 00 
	stat->st_dev = &devpipe;
  801ce8:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801cef:	30 80 00 
	return 0;
}
  801cf2:	b8 00 00 00 00       	mov    $0x0,%eax
  801cf7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cfa:	5b                   	pop    %ebx
  801cfb:	5e                   	pop    %esi
  801cfc:	5d                   	pop    %ebp
  801cfd:	c3                   	ret    

00801cfe <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801cfe:	55                   	push   %ebp
  801cff:	89 e5                	mov    %esp,%ebp
  801d01:	53                   	push   %ebx
  801d02:	83 ec 0c             	sub    $0xc,%esp
  801d05:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801d08:	53                   	push   %ebx
  801d09:	6a 00                	push   $0x0
  801d0b:	e8 d1 ee ff ff       	call   800be1 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801d10:	89 1c 24             	mov    %ebx,(%esp)
  801d13:	e8 0d f3 ff ff       	call   801025 <fd2data>
  801d18:	83 c4 08             	add    $0x8,%esp
  801d1b:	50                   	push   %eax
  801d1c:	6a 00                	push   $0x0
  801d1e:	e8 be ee ff ff       	call   800be1 <sys_page_unmap>
}
  801d23:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d26:	c9                   	leave  
  801d27:	c3                   	ret    

00801d28 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801d28:	55                   	push   %ebp
  801d29:	89 e5                	mov    %esp,%ebp
  801d2b:	57                   	push   %edi
  801d2c:	56                   	push   %esi
  801d2d:	53                   	push   %ebx
  801d2e:	83 ec 1c             	sub    $0x1c,%esp
  801d31:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801d34:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801d36:	a1 08 40 80 00       	mov    0x804008,%eax
  801d3b:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801d3e:	83 ec 0c             	sub    $0xc,%esp
  801d41:	ff 75 e0             	pushl  -0x20(%ebp)
  801d44:	e8 f8 05 00 00       	call   802341 <pageref>
  801d49:	89 c3                	mov    %eax,%ebx
  801d4b:	89 3c 24             	mov    %edi,(%esp)
  801d4e:	e8 ee 05 00 00       	call   802341 <pageref>
  801d53:	83 c4 10             	add    $0x10,%esp
  801d56:	39 c3                	cmp    %eax,%ebx
  801d58:	0f 94 c1             	sete   %cl
  801d5b:	0f b6 c9             	movzbl %cl,%ecx
  801d5e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801d61:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801d67:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801d6a:	39 ce                	cmp    %ecx,%esi
  801d6c:	74 1b                	je     801d89 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801d6e:	39 c3                	cmp    %eax,%ebx
  801d70:	75 c4                	jne    801d36 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d72:	8b 42 58             	mov    0x58(%edx),%eax
  801d75:	ff 75 e4             	pushl  -0x1c(%ebp)
  801d78:	50                   	push   %eax
  801d79:	56                   	push   %esi
  801d7a:	68 fb 2a 80 00       	push   $0x802afb
  801d7f:	e8 50 e4 ff ff       	call   8001d4 <cprintf>
  801d84:	83 c4 10             	add    $0x10,%esp
  801d87:	eb ad                	jmp    801d36 <_pipeisclosed+0xe>
	}
}
  801d89:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d8c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d8f:	5b                   	pop    %ebx
  801d90:	5e                   	pop    %esi
  801d91:	5f                   	pop    %edi
  801d92:	5d                   	pop    %ebp
  801d93:	c3                   	ret    

00801d94 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d94:	55                   	push   %ebp
  801d95:	89 e5                	mov    %esp,%ebp
  801d97:	57                   	push   %edi
  801d98:	56                   	push   %esi
  801d99:	53                   	push   %ebx
  801d9a:	83 ec 28             	sub    $0x28,%esp
  801d9d:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801da0:	56                   	push   %esi
  801da1:	e8 7f f2 ff ff       	call   801025 <fd2data>
  801da6:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801da8:	83 c4 10             	add    $0x10,%esp
  801dab:	bf 00 00 00 00       	mov    $0x0,%edi
  801db0:	eb 4b                	jmp    801dfd <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801db2:	89 da                	mov    %ebx,%edx
  801db4:	89 f0                	mov    %esi,%eax
  801db6:	e8 6d ff ff ff       	call   801d28 <_pipeisclosed>
  801dbb:	85 c0                	test   %eax,%eax
  801dbd:	75 48                	jne    801e07 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801dbf:	e8 79 ed ff ff       	call   800b3d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801dc4:	8b 43 04             	mov    0x4(%ebx),%eax
  801dc7:	8b 0b                	mov    (%ebx),%ecx
  801dc9:	8d 51 20             	lea    0x20(%ecx),%edx
  801dcc:	39 d0                	cmp    %edx,%eax
  801dce:	73 e2                	jae    801db2 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801dd0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801dd3:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801dd7:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801dda:	89 c2                	mov    %eax,%edx
  801ddc:	c1 fa 1f             	sar    $0x1f,%edx
  801ddf:	89 d1                	mov    %edx,%ecx
  801de1:	c1 e9 1b             	shr    $0x1b,%ecx
  801de4:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801de7:	83 e2 1f             	and    $0x1f,%edx
  801dea:	29 ca                	sub    %ecx,%edx
  801dec:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801df0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801df4:	83 c0 01             	add    $0x1,%eax
  801df7:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801dfa:	83 c7 01             	add    $0x1,%edi
  801dfd:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801e00:	75 c2                	jne    801dc4 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801e02:	8b 45 10             	mov    0x10(%ebp),%eax
  801e05:	eb 05                	jmp    801e0c <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e07:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801e0c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e0f:	5b                   	pop    %ebx
  801e10:	5e                   	pop    %esi
  801e11:	5f                   	pop    %edi
  801e12:	5d                   	pop    %ebp
  801e13:	c3                   	ret    

00801e14 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e14:	55                   	push   %ebp
  801e15:	89 e5                	mov    %esp,%ebp
  801e17:	57                   	push   %edi
  801e18:	56                   	push   %esi
  801e19:	53                   	push   %ebx
  801e1a:	83 ec 18             	sub    $0x18,%esp
  801e1d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801e20:	57                   	push   %edi
  801e21:	e8 ff f1 ff ff       	call   801025 <fd2data>
  801e26:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e28:	83 c4 10             	add    $0x10,%esp
  801e2b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e30:	eb 3d                	jmp    801e6f <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801e32:	85 db                	test   %ebx,%ebx
  801e34:	74 04                	je     801e3a <devpipe_read+0x26>
				return i;
  801e36:	89 d8                	mov    %ebx,%eax
  801e38:	eb 44                	jmp    801e7e <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801e3a:	89 f2                	mov    %esi,%edx
  801e3c:	89 f8                	mov    %edi,%eax
  801e3e:	e8 e5 fe ff ff       	call   801d28 <_pipeisclosed>
  801e43:	85 c0                	test   %eax,%eax
  801e45:	75 32                	jne    801e79 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801e47:	e8 f1 ec ff ff       	call   800b3d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801e4c:	8b 06                	mov    (%esi),%eax
  801e4e:	3b 46 04             	cmp    0x4(%esi),%eax
  801e51:	74 df                	je     801e32 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e53:	99                   	cltd   
  801e54:	c1 ea 1b             	shr    $0x1b,%edx
  801e57:	01 d0                	add    %edx,%eax
  801e59:	83 e0 1f             	and    $0x1f,%eax
  801e5c:	29 d0                	sub    %edx,%eax
  801e5e:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801e63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e66:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801e69:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e6c:	83 c3 01             	add    $0x1,%ebx
  801e6f:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801e72:	75 d8                	jne    801e4c <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801e74:	8b 45 10             	mov    0x10(%ebp),%eax
  801e77:	eb 05                	jmp    801e7e <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e79:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801e7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e81:	5b                   	pop    %ebx
  801e82:	5e                   	pop    %esi
  801e83:	5f                   	pop    %edi
  801e84:	5d                   	pop    %ebp
  801e85:	c3                   	ret    

00801e86 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801e86:	55                   	push   %ebp
  801e87:	89 e5                	mov    %esp,%ebp
  801e89:	56                   	push   %esi
  801e8a:	53                   	push   %ebx
  801e8b:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801e8e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e91:	50                   	push   %eax
  801e92:	e8 a5 f1 ff ff       	call   80103c <fd_alloc>
  801e97:	83 c4 10             	add    $0x10,%esp
  801e9a:	89 c2                	mov    %eax,%edx
  801e9c:	85 c0                	test   %eax,%eax
  801e9e:	0f 88 2c 01 00 00    	js     801fd0 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ea4:	83 ec 04             	sub    $0x4,%esp
  801ea7:	68 07 04 00 00       	push   $0x407
  801eac:	ff 75 f4             	pushl  -0xc(%ebp)
  801eaf:	6a 00                	push   $0x0
  801eb1:	e8 a6 ec ff ff       	call   800b5c <sys_page_alloc>
  801eb6:	83 c4 10             	add    $0x10,%esp
  801eb9:	89 c2                	mov    %eax,%edx
  801ebb:	85 c0                	test   %eax,%eax
  801ebd:	0f 88 0d 01 00 00    	js     801fd0 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801ec3:	83 ec 0c             	sub    $0xc,%esp
  801ec6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ec9:	50                   	push   %eax
  801eca:	e8 6d f1 ff ff       	call   80103c <fd_alloc>
  801ecf:	89 c3                	mov    %eax,%ebx
  801ed1:	83 c4 10             	add    $0x10,%esp
  801ed4:	85 c0                	test   %eax,%eax
  801ed6:	0f 88 e2 00 00 00    	js     801fbe <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801edc:	83 ec 04             	sub    $0x4,%esp
  801edf:	68 07 04 00 00       	push   $0x407
  801ee4:	ff 75 f0             	pushl  -0x10(%ebp)
  801ee7:	6a 00                	push   $0x0
  801ee9:	e8 6e ec ff ff       	call   800b5c <sys_page_alloc>
  801eee:	89 c3                	mov    %eax,%ebx
  801ef0:	83 c4 10             	add    $0x10,%esp
  801ef3:	85 c0                	test   %eax,%eax
  801ef5:	0f 88 c3 00 00 00    	js     801fbe <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801efb:	83 ec 0c             	sub    $0xc,%esp
  801efe:	ff 75 f4             	pushl  -0xc(%ebp)
  801f01:	e8 1f f1 ff ff       	call   801025 <fd2data>
  801f06:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f08:	83 c4 0c             	add    $0xc,%esp
  801f0b:	68 07 04 00 00       	push   $0x407
  801f10:	50                   	push   %eax
  801f11:	6a 00                	push   $0x0
  801f13:	e8 44 ec ff ff       	call   800b5c <sys_page_alloc>
  801f18:	89 c3                	mov    %eax,%ebx
  801f1a:	83 c4 10             	add    $0x10,%esp
  801f1d:	85 c0                	test   %eax,%eax
  801f1f:	0f 88 89 00 00 00    	js     801fae <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f25:	83 ec 0c             	sub    $0xc,%esp
  801f28:	ff 75 f0             	pushl  -0x10(%ebp)
  801f2b:	e8 f5 f0 ff ff       	call   801025 <fd2data>
  801f30:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801f37:	50                   	push   %eax
  801f38:	6a 00                	push   $0x0
  801f3a:	56                   	push   %esi
  801f3b:	6a 00                	push   $0x0
  801f3d:	e8 5d ec ff ff       	call   800b9f <sys_page_map>
  801f42:	89 c3                	mov    %eax,%ebx
  801f44:	83 c4 20             	add    $0x20,%esp
  801f47:	85 c0                	test   %eax,%eax
  801f49:	78 55                	js     801fa0 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801f4b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f51:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f54:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801f56:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f59:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801f60:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f66:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f69:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801f6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f6e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801f75:	83 ec 0c             	sub    $0xc,%esp
  801f78:	ff 75 f4             	pushl  -0xc(%ebp)
  801f7b:	e8 95 f0 ff ff       	call   801015 <fd2num>
  801f80:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f83:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801f85:	83 c4 04             	add    $0x4,%esp
  801f88:	ff 75 f0             	pushl  -0x10(%ebp)
  801f8b:	e8 85 f0 ff ff       	call   801015 <fd2num>
  801f90:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f93:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801f96:	83 c4 10             	add    $0x10,%esp
  801f99:	ba 00 00 00 00       	mov    $0x0,%edx
  801f9e:	eb 30                	jmp    801fd0 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801fa0:	83 ec 08             	sub    $0x8,%esp
  801fa3:	56                   	push   %esi
  801fa4:	6a 00                	push   $0x0
  801fa6:	e8 36 ec ff ff       	call   800be1 <sys_page_unmap>
  801fab:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801fae:	83 ec 08             	sub    $0x8,%esp
  801fb1:	ff 75 f0             	pushl  -0x10(%ebp)
  801fb4:	6a 00                	push   $0x0
  801fb6:	e8 26 ec ff ff       	call   800be1 <sys_page_unmap>
  801fbb:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801fbe:	83 ec 08             	sub    $0x8,%esp
  801fc1:	ff 75 f4             	pushl  -0xc(%ebp)
  801fc4:	6a 00                	push   $0x0
  801fc6:	e8 16 ec ff ff       	call   800be1 <sys_page_unmap>
  801fcb:	83 c4 10             	add    $0x10,%esp
  801fce:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801fd0:	89 d0                	mov    %edx,%eax
  801fd2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fd5:	5b                   	pop    %ebx
  801fd6:	5e                   	pop    %esi
  801fd7:	5d                   	pop    %ebp
  801fd8:	c3                   	ret    

00801fd9 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801fd9:	55                   	push   %ebp
  801fda:	89 e5                	mov    %esp,%ebp
  801fdc:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fdf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fe2:	50                   	push   %eax
  801fe3:	ff 75 08             	pushl  0x8(%ebp)
  801fe6:	e8 a0 f0 ff ff       	call   80108b <fd_lookup>
  801feb:	83 c4 10             	add    $0x10,%esp
  801fee:	85 c0                	test   %eax,%eax
  801ff0:	78 18                	js     80200a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801ff2:	83 ec 0c             	sub    $0xc,%esp
  801ff5:	ff 75 f4             	pushl  -0xc(%ebp)
  801ff8:	e8 28 f0 ff ff       	call   801025 <fd2data>
	return _pipeisclosed(fd, p);
  801ffd:	89 c2                	mov    %eax,%edx
  801fff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802002:	e8 21 fd ff ff       	call   801d28 <_pipeisclosed>
  802007:	83 c4 10             	add    $0x10,%esp
}
  80200a:	c9                   	leave  
  80200b:	c3                   	ret    

0080200c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80200c:	55                   	push   %ebp
  80200d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80200f:	b8 00 00 00 00       	mov    $0x0,%eax
  802014:	5d                   	pop    %ebp
  802015:	c3                   	ret    

00802016 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802016:	55                   	push   %ebp
  802017:	89 e5                	mov    %esp,%ebp
  802019:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80201c:	68 13 2b 80 00       	push   $0x802b13
  802021:	ff 75 0c             	pushl  0xc(%ebp)
  802024:	e8 30 e7 ff ff       	call   800759 <strcpy>
	return 0;
}
  802029:	b8 00 00 00 00       	mov    $0x0,%eax
  80202e:	c9                   	leave  
  80202f:	c3                   	ret    

00802030 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802030:	55                   	push   %ebp
  802031:	89 e5                	mov    %esp,%ebp
  802033:	57                   	push   %edi
  802034:	56                   	push   %esi
  802035:	53                   	push   %ebx
  802036:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80203c:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802041:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802047:	eb 2d                	jmp    802076 <devcons_write+0x46>
		m = n - tot;
  802049:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80204c:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80204e:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802051:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802056:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802059:	83 ec 04             	sub    $0x4,%esp
  80205c:	53                   	push   %ebx
  80205d:	03 45 0c             	add    0xc(%ebp),%eax
  802060:	50                   	push   %eax
  802061:	57                   	push   %edi
  802062:	e8 84 e8 ff ff       	call   8008eb <memmove>
		sys_cputs(buf, m);
  802067:	83 c4 08             	add    $0x8,%esp
  80206a:	53                   	push   %ebx
  80206b:	57                   	push   %edi
  80206c:	e8 2f ea ff ff       	call   800aa0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802071:	01 de                	add    %ebx,%esi
  802073:	83 c4 10             	add    $0x10,%esp
  802076:	89 f0                	mov    %esi,%eax
  802078:	3b 75 10             	cmp    0x10(%ebp),%esi
  80207b:	72 cc                	jb     802049 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80207d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802080:	5b                   	pop    %ebx
  802081:	5e                   	pop    %esi
  802082:	5f                   	pop    %edi
  802083:	5d                   	pop    %ebp
  802084:	c3                   	ret    

00802085 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802085:	55                   	push   %ebp
  802086:	89 e5                	mov    %esp,%ebp
  802088:	83 ec 08             	sub    $0x8,%esp
  80208b:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802090:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802094:	74 2a                	je     8020c0 <devcons_read+0x3b>
  802096:	eb 05                	jmp    80209d <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802098:	e8 a0 ea ff ff       	call   800b3d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80209d:	e8 1c ea ff ff       	call   800abe <sys_cgetc>
  8020a2:	85 c0                	test   %eax,%eax
  8020a4:	74 f2                	je     802098 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8020a6:	85 c0                	test   %eax,%eax
  8020a8:	78 16                	js     8020c0 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8020aa:	83 f8 04             	cmp    $0x4,%eax
  8020ad:	74 0c                	je     8020bb <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8020af:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020b2:	88 02                	mov    %al,(%edx)
	return 1;
  8020b4:	b8 01 00 00 00       	mov    $0x1,%eax
  8020b9:	eb 05                	jmp    8020c0 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8020bb:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8020c0:	c9                   	leave  
  8020c1:	c3                   	ret    

008020c2 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8020c2:	55                   	push   %ebp
  8020c3:	89 e5                	mov    %esp,%ebp
  8020c5:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8020c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8020cb:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8020ce:	6a 01                	push   $0x1
  8020d0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020d3:	50                   	push   %eax
  8020d4:	e8 c7 e9 ff ff       	call   800aa0 <sys_cputs>
}
  8020d9:	83 c4 10             	add    $0x10,%esp
  8020dc:	c9                   	leave  
  8020dd:	c3                   	ret    

008020de <getchar>:

int
getchar(void)
{
  8020de:	55                   	push   %ebp
  8020df:	89 e5                	mov    %esp,%ebp
  8020e1:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8020e4:	6a 01                	push   $0x1
  8020e6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020e9:	50                   	push   %eax
  8020ea:	6a 00                	push   $0x0
  8020ec:	e8 00 f2 ff ff       	call   8012f1 <read>
	if (r < 0)
  8020f1:	83 c4 10             	add    $0x10,%esp
  8020f4:	85 c0                	test   %eax,%eax
  8020f6:	78 0f                	js     802107 <getchar+0x29>
		return r;
	if (r < 1)
  8020f8:	85 c0                	test   %eax,%eax
  8020fa:	7e 06                	jle    802102 <getchar+0x24>
		return -E_EOF;
	return c;
  8020fc:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802100:	eb 05                	jmp    802107 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802102:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802107:	c9                   	leave  
  802108:	c3                   	ret    

00802109 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802109:	55                   	push   %ebp
  80210a:	89 e5                	mov    %esp,%ebp
  80210c:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80210f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802112:	50                   	push   %eax
  802113:	ff 75 08             	pushl  0x8(%ebp)
  802116:	e8 70 ef ff ff       	call   80108b <fd_lookup>
  80211b:	83 c4 10             	add    $0x10,%esp
  80211e:	85 c0                	test   %eax,%eax
  802120:	78 11                	js     802133 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802122:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802125:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80212b:	39 10                	cmp    %edx,(%eax)
  80212d:	0f 94 c0             	sete   %al
  802130:	0f b6 c0             	movzbl %al,%eax
}
  802133:	c9                   	leave  
  802134:	c3                   	ret    

00802135 <opencons>:

int
opencons(void)
{
  802135:	55                   	push   %ebp
  802136:	89 e5                	mov    %esp,%ebp
  802138:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80213b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80213e:	50                   	push   %eax
  80213f:	e8 f8 ee ff ff       	call   80103c <fd_alloc>
  802144:	83 c4 10             	add    $0x10,%esp
		return r;
  802147:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802149:	85 c0                	test   %eax,%eax
  80214b:	78 3e                	js     80218b <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80214d:	83 ec 04             	sub    $0x4,%esp
  802150:	68 07 04 00 00       	push   $0x407
  802155:	ff 75 f4             	pushl  -0xc(%ebp)
  802158:	6a 00                	push   $0x0
  80215a:	e8 fd e9 ff ff       	call   800b5c <sys_page_alloc>
  80215f:	83 c4 10             	add    $0x10,%esp
		return r;
  802162:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802164:	85 c0                	test   %eax,%eax
  802166:	78 23                	js     80218b <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802168:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80216e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802171:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802173:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802176:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80217d:	83 ec 0c             	sub    $0xc,%esp
  802180:	50                   	push   %eax
  802181:	e8 8f ee ff ff       	call   801015 <fd2num>
  802186:	89 c2                	mov    %eax,%edx
  802188:	83 c4 10             	add    $0x10,%esp
}
  80218b:	89 d0                	mov    %edx,%eax
  80218d:	c9                   	leave  
  80218e:	c3                   	ret    

0080218f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80218f:	55                   	push   %ebp
  802190:	89 e5                	mov    %esp,%ebp
  802192:	56                   	push   %esi
  802193:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  802194:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  802197:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80219d:	e8 7c e9 ff ff       	call   800b1e <sys_getenvid>
  8021a2:	83 ec 0c             	sub    $0xc,%esp
  8021a5:	ff 75 0c             	pushl  0xc(%ebp)
  8021a8:	ff 75 08             	pushl  0x8(%ebp)
  8021ab:	56                   	push   %esi
  8021ac:	50                   	push   %eax
  8021ad:	68 20 2b 80 00       	push   $0x802b20
  8021b2:	e8 1d e0 ff ff       	call   8001d4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8021b7:	83 c4 18             	add    $0x18,%esp
  8021ba:	53                   	push   %ebx
  8021bb:	ff 75 10             	pushl  0x10(%ebp)
  8021be:	e8 c0 df ff ff       	call   800183 <vcprintf>
	cprintf("\n");
  8021c3:	c7 04 24 2f 26 80 00 	movl   $0x80262f,(%esp)
  8021ca:	e8 05 e0 ff ff       	call   8001d4 <cprintf>
  8021cf:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8021d2:	cc                   	int3   
  8021d3:	eb fd                	jmp    8021d2 <_panic+0x43>

008021d5 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8021d5:	55                   	push   %ebp
  8021d6:	89 e5                	mov    %esp,%ebp
  8021d8:	53                   	push   %ebx
  8021d9:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  8021dc:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8021e3:	75 28                	jne    80220d <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  8021e5:	e8 34 e9 ff ff       	call   800b1e <sys_getenvid>
  8021ea:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_U | PTE_W);
  8021ec:	83 ec 04             	sub    $0x4,%esp
  8021ef:	6a 06                	push   $0x6
  8021f1:	68 00 f0 bf ee       	push   $0xeebff000
  8021f6:	50                   	push   %eax
  8021f7:	e8 60 e9 ff ff       	call   800b5c <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  8021fc:	83 c4 08             	add    $0x8,%esp
  8021ff:	68 1a 22 80 00       	push   $0x80221a
  802204:	53                   	push   %ebx
  802205:	e8 9d ea ff ff       	call   800ca7 <sys_env_set_pgfault_upcall>
  80220a:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80220d:	8b 45 08             	mov    0x8(%ebp),%eax
  802210:	a3 00 70 80 00       	mov    %eax,0x807000
}
  802215:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802218:	c9                   	leave  
  802219:	c3                   	ret    

0080221a <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80221a:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80221b:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802220:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802222:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	# My method is different. Copy the values to the other stack
	# in a convinient way, and then pop everything.
	movl %esp, %ebp		# ebp refers to the exception stack
  802225:	89 e5                	mov    %esp,%ebp
	movl 48(%ebp), %esp 	# go to other stack
  802227:	8b 65 30             	mov    0x30(%ebp),%esp

	pushl 40(%ebp)		# eip - ORDER SWITCHED WITH EFLAGS
  80222a:	ff 75 28             	pushl  0x28(%ebp)
	pushl 44(%ebp)      	# eflags
  80222d:	ff 75 2c             	pushl  0x2c(%ebp)
	pushl 36(%ebp)		# all the 8 remaining regs
  802230:	ff 75 24             	pushl  0x24(%ebp)
	pushl 32(%ebp)
  802233:	ff 75 20             	pushl  0x20(%ebp)
	pushl 28(%ebp)
  802236:	ff 75 1c             	pushl  0x1c(%ebp)
	pushl 24(%ebp)
  802239:	ff 75 18             	pushl  0x18(%ebp)
	pushl 20(%ebp)
  80223c:	ff 75 14             	pushl  0x14(%ebp)
	pushl 16(%ebp)
  80223f:	ff 75 10             	pushl  0x10(%ebp)
	pushl 12(%ebp)
  802242:	ff 75 0c             	pushl  0xc(%ebp)
	pushl 8(%ebp)
  802245:	ff 75 08             	pushl  0x8(%ebp)

	popal			# now just pop everything!
  802248:	61                   	popa   
	popfl
  802249:	9d                   	popf   
	ret
  80224a:	c3                   	ret    

0080224b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80224b:	55                   	push   %ebp
  80224c:	89 e5                	mov    %esp,%ebp
  80224e:	56                   	push   %esi
  80224f:	53                   	push   %ebx
  802250:	8b 75 08             	mov    0x8(%ebp),%esi
  802253:	8b 45 0c             	mov    0xc(%ebp),%eax
  802256:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  802259:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  80225b:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  802260:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  802263:	83 ec 0c             	sub    $0xc,%esp
  802266:	50                   	push   %eax
  802267:	e8 a0 ea ff ff       	call   800d0c <sys_ipc_recv>

	if (r < 0) {
  80226c:	83 c4 10             	add    $0x10,%esp
  80226f:	85 c0                	test   %eax,%eax
  802271:	79 16                	jns    802289 <ipc_recv+0x3e>
		if (from_env_store)
  802273:	85 f6                	test   %esi,%esi
  802275:	74 06                	je     80227d <ipc_recv+0x32>
			*from_env_store = 0;
  802277:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  80227d:	85 db                	test   %ebx,%ebx
  80227f:	74 2c                	je     8022ad <ipc_recv+0x62>
			*perm_store = 0;
  802281:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802287:	eb 24                	jmp    8022ad <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  802289:	85 f6                	test   %esi,%esi
  80228b:	74 0a                	je     802297 <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  80228d:	a1 08 40 80 00       	mov    0x804008,%eax
  802292:	8b 40 74             	mov    0x74(%eax),%eax
  802295:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  802297:	85 db                	test   %ebx,%ebx
  802299:	74 0a                	je     8022a5 <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  80229b:	a1 08 40 80 00       	mov    0x804008,%eax
  8022a0:	8b 40 78             	mov    0x78(%eax),%eax
  8022a3:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  8022a5:	a1 08 40 80 00       	mov    0x804008,%eax
  8022aa:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  8022ad:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022b0:	5b                   	pop    %ebx
  8022b1:	5e                   	pop    %esi
  8022b2:	5d                   	pop    %ebp
  8022b3:	c3                   	ret    

008022b4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8022b4:	55                   	push   %ebp
  8022b5:	89 e5                	mov    %esp,%ebp
  8022b7:	57                   	push   %edi
  8022b8:	56                   	push   %esi
  8022b9:	53                   	push   %ebx
  8022ba:	83 ec 0c             	sub    $0xc,%esp
  8022bd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8022c0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8022c3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  8022c6:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  8022c8:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  8022cd:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  8022d0:	ff 75 14             	pushl  0x14(%ebp)
  8022d3:	53                   	push   %ebx
  8022d4:	56                   	push   %esi
  8022d5:	57                   	push   %edi
  8022d6:	e8 0e ea ff ff       	call   800ce9 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  8022db:	83 c4 10             	add    $0x10,%esp
  8022de:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8022e1:	75 07                	jne    8022ea <ipc_send+0x36>
			sys_yield();
  8022e3:	e8 55 e8 ff ff       	call   800b3d <sys_yield>
  8022e8:	eb e6                	jmp    8022d0 <ipc_send+0x1c>
		} else if (r < 0) {
  8022ea:	85 c0                	test   %eax,%eax
  8022ec:	79 12                	jns    802300 <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  8022ee:	50                   	push   %eax
  8022ef:	68 44 2b 80 00       	push   $0x802b44
  8022f4:	6a 51                	push   $0x51
  8022f6:	68 51 2b 80 00       	push   $0x802b51
  8022fb:	e8 8f fe ff ff       	call   80218f <_panic>
		}
	}
}
  802300:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802303:	5b                   	pop    %ebx
  802304:	5e                   	pop    %esi
  802305:	5f                   	pop    %edi
  802306:	5d                   	pop    %ebp
  802307:	c3                   	ret    

00802308 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802308:	55                   	push   %ebp
  802309:	89 e5                	mov    %esp,%ebp
  80230b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80230e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802313:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802316:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80231c:	8b 52 50             	mov    0x50(%edx),%edx
  80231f:	39 ca                	cmp    %ecx,%edx
  802321:	75 0d                	jne    802330 <ipc_find_env+0x28>
			return envs[i].env_id;
  802323:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802326:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80232b:	8b 40 48             	mov    0x48(%eax),%eax
  80232e:	eb 0f                	jmp    80233f <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802330:	83 c0 01             	add    $0x1,%eax
  802333:	3d 00 04 00 00       	cmp    $0x400,%eax
  802338:	75 d9                	jne    802313 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80233a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80233f:	5d                   	pop    %ebp
  802340:	c3                   	ret    

00802341 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802341:	55                   	push   %ebp
  802342:	89 e5                	mov    %esp,%ebp
  802344:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802347:	89 d0                	mov    %edx,%eax
  802349:	c1 e8 16             	shr    $0x16,%eax
  80234c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802353:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802358:	f6 c1 01             	test   $0x1,%cl
  80235b:	74 1d                	je     80237a <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80235d:	c1 ea 0c             	shr    $0xc,%edx
  802360:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802367:	f6 c2 01             	test   $0x1,%dl
  80236a:	74 0e                	je     80237a <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80236c:	c1 ea 0c             	shr    $0xc,%edx
  80236f:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802376:	ef 
  802377:	0f b7 c0             	movzwl %ax,%eax
}
  80237a:	5d                   	pop    %ebp
  80237b:	c3                   	ret    
  80237c:	66 90                	xchg   %ax,%ax
  80237e:	66 90                	xchg   %ax,%ax

00802380 <__udivdi3>:
  802380:	55                   	push   %ebp
  802381:	57                   	push   %edi
  802382:	56                   	push   %esi
  802383:	53                   	push   %ebx
  802384:	83 ec 1c             	sub    $0x1c,%esp
  802387:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80238b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80238f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802393:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802397:	85 f6                	test   %esi,%esi
  802399:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80239d:	89 ca                	mov    %ecx,%edx
  80239f:	89 f8                	mov    %edi,%eax
  8023a1:	75 3d                	jne    8023e0 <__udivdi3+0x60>
  8023a3:	39 cf                	cmp    %ecx,%edi
  8023a5:	0f 87 c5 00 00 00    	ja     802470 <__udivdi3+0xf0>
  8023ab:	85 ff                	test   %edi,%edi
  8023ad:	89 fd                	mov    %edi,%ebp
  8023af:	75 0b                	jne    8023bc <__udivdi3+0x3c>
  8023b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8023b6:	31 d2                	xor    %edx,%edx
  8023b8:	f7 f7                	div    %edi
  8023ba:	89 c5                	mov    %eax,%ebp
  8023bc:	89 c8                	mov    %ecx,%eax
  8023be:	31 d2                	xor    %edx,%edx
  8023c0:	f7 f5                	div    %ebp
  8023c2:	89 c1                	mov    %eax,%ecx
  8023c4:	89 d8                	mov    %ebx,%eax
  8023c6:	89 cf                	mov    %ecx,%edi
  8023c8:	f7 f5                	div    %ebp
  8023ca:	89 c3                	mov    %eax,%ebx
  8023cc:	89 d8                	mov    %ebx,%eax
  8023ce:	89 fa                	mov    %edi,%edx
  8023d0:	83 c4 1c             	add    $0x1c,%esp
  8023d3:	5b                   	pop    %ebx
  8023d4:	5e                   	pop    %esi
  8023d5:	5f                   	pop    %edi
  8023d6:	5d                   	pop    %ebp
  8023d7:	c3                   	ret    
  8023d8:	90                   	nop
  8023d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023e0:	39 ce                	cmp    %ecx,%esi
  8023e2:	77 74                	ja     802458 <__udivdi3+0xd8>
  8023e4:	0f bd fe             	bsr    %esi,%edi
  8023e7:	83 f7 1f             	xor    $0x1f,%edi
  8023ea:	0f 84 98 00 00 00    	je     802488 <__udivdi3+0x108>
  8023f0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8023f5:	89 f9                	mov    %edi,%ecx
  8023f7:	89 c5                	mov    %eax,%ebp
  8023f9:	29 fb                	sub    %edi,%ebx
  8023fb:	d3 e6                	shl    %cl,%esi
  8023fd:	89 d9                	mov    %ebx,%ecx
  8023ff:	d3 ed                	shr    %cl,%ebp
  802401:	89 f9                	mov    %edi,%ecx
  802403:	d3 e0                	shl    %cl,%eax
  802405:	09 ee                	or     %ebp,%esi
  802407:	89 d9                	mov    %ebx,%ecx
  802409:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80240d:	89 d5                	mov    %edx,%ebp
  80240f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802413:	d3 ed                	shr    %cl,%ebp
  802415:	89 f9                	mov    %edi,%ecx
  802417:	d3 e2                	shl    %cl,%edx
  802419:	89 d9                	mov    %ebx,%ecx
  80241b:	d3 e8                	shr    %cl,%eax
  80241d:	09 c2                	or     %eax,%edx
  80241f:	89 d0                	mov    %edx,%eax
  802421:	89 ea                	mov    %ebp,%edx
  802423:	f7 f6                	div    %esi
  802425:	89 d5                	mov    %edx,%ebp
  802427:	89 c3                	mov    %eax,%ebx
  802429:	f7 64 24 0c          	mull   0xc(%esp)
  80242d:	39 d5                	cmp    %edx,%ebp
  80242f:	72 10                	jb     802441 <__udivdi3+0xc1>
  802431:	8b 74 24 08          	mov    0x8(%esp),%esi
  802435:	89 f9                	mov    %edi,%ecx
  802437:	d3 e6                	shl    %cl,%esi
  802439:	39 c6                	cmp    %eax,%esi
  80243b:	73 07                	jae    802444 <__udivdi3+0xc4>
  80243d:	39 d5                	cmp    %edx,%ebp
  80243f:	75 03                	jne    802444 <__udivdi3+0xc4>
  802441:	83 eb 01             	sub    $0x1,%ebx
  802444:	31 ff                	xor    %edi,%edi
  802446:	89 d8                	mov    %ebx,%eax
  802448:	89 fa                	mov    %edi,%edx
  80244a:	83 c4 1c             	add    $0x1c,%esp
  80244d:	5b                   	pop    %ebx
  80244e:	5e                   	pop    %esi
  80244f:	5f                   	pop    %edi
  802450:	5d                   	pop    %ebp
  802451:	c3                   	ret    
  802452:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802458:	31 ff                	xor    %edi,%edi
  80245a:	31 db                	xor    %ebx,%ebx
  80245c:	89 d8                	mov    %ebx,%eax
  80245e:	89 fa                	mov    %edi,%edx
  802460:	83 c4 1c             	add    $0x1c,%esp
  802463:	5b                   	pop    %ebx
  802464:	5e                   	pop    %esi
  802465:	5f                   	pop    %edi
  802466:	5d                   	pop    %ebp
  802467:	c3                   	ret    
  802468:	90                   	nop
  802469:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802470:	89 d8                	mov    %ebx,%eax
  802472:	f7 f7                	div    %edi
  802474:	31 ff                	xor    %edi,%edi
  802476:	89 c3                	mov    %eax,%ebx
  802478:	89 d8                	mov    %ebx,%eax
  80247a:	89 fa                	mov    %edi,%edx
  80247c:	83 c4 1c             	add    $0x1c,%esp
  80247f:	5b                   	pop    %ebx
  802480:	5e                   	pop    %esi
  802481:	5f                   	pop    %edi
  802482:	5d                   	pop    %ebp
  802483:	c3                   	ret    
  802484:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802488:	39 ce                	cmp    %ecx,%esi
  80248a:	72 0c                	jb     802498 <__udivdi3+0x118>
  80248c:	31 db                	xor    %ebx,%ebx
  80248e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802492:	0f 87 34 ff ff ff    	ja     8023cc <__udivdi3+0x4c>
  802498:	bb 01 00 00 00       	mov    $0x1,%ebx
  80249d:	e9 2a ff ff ff       	jmp    8023cc <__udivdi3+0x4c>
  8024a2:	66 90                	xchg   %ax,%ax
  8024a4:	66 90                	xchg   %ax,%ax
  8024a6:	66 90                	xchg   %ax,%ax
  8024a8:	66 90                	xchg   %ax,%ax
  8024aa:	66 90                	xchg   %ax,%ax
  8024ac:	66 90                	xchg   %ax,%ax
  8024ae:	66 90                	xchg   %ax,%ax

008024b0 <__umoddi3>:
  8024b0:	55                   	push   %ebp
  8024b1:	57                   	push   %edi
  8024b2:	56                   	push   %esi
  8024b3:	53                   	push   %ebx
  8024b4:	83 ec 1c             	sub    $0x1c,%esp
  8024b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8024bb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8024bf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8024c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8024c7:	85 d2                	test   %edx,%edx
  8024c9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8024cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024d1:	89 f3                	mov    %esi,%ebx
  8024d3:	89 3c 24             	mov    %edi,(%esp)
  8024d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024da:	75 1c                	jne    8024f8 <__umoddi3+0x48>
  8024dc:	39 f7                	cmp    %esi,%edi
  8024de:	76 50                	jbe    802530 <__umoddi3+0x80>
  8024e0:	89 c8                	mov    %ecx,%eax
  8024e2:	89 f2                	mov    %esi,%edx
  8024e4:	f7 f7                	div    %edi
  8024e6:	89 d0                	mov    %edx,%eax
  8024e8:	31 d2                	xor    %edx,%edx
  8024ea:	83 c4 1c             	add    $0x1c,%esp
  8024ed:	5b                   	pop    %ebx
  8024ee:	5e                   	pop    %esi
  8024ef:	5f                   	pop    %edi
  8024f0:	5d                   	pop    %ebp
  8024f1:	c3                   	ret    
  8024f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8024f8:	39 f2                	cmp    %esi,%edx
  8024fa:	89 d0                	mov    %edx,%eax
  8024fc:	77 52                	ja     802550 <__umoddi3+0xa0>
  8024fe:	0f bd ea             	bsr    %edx,%ebp
  802501:	83 f5 1f             	xor    $0x1f,%ebp
  802504:	75 5a                	jne    802560 <__umoddi3+0xb0>
  802506:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80250a:	0f 82 e0 00 00 00    	jb     8025f0 <__umoddi3+0x140>
  802510:	39 0c 24             	cmp    %ecx,(%esp)
  802513:	0f 86 d7 00 00 00    	jbe    8025f0 <__umoddi3+0x140>
  802519:	8b 44 24 08          	mov    0x8(%esp),%eax
  80251d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802521:	83 c4 1c             	add    $0x1c,%esp
  802524:	5b                   	pop    %ebx
  802525:	5e                   	pop    %esi
  802526:	5f                   	pop    %edi
  802527:	5d                   	pop    %ebp
  802528:	c3                   	ret    
  802529:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802530:	85 ff                	test   %edi,%edi
  802532:	89 fd                	mov    %edi,%ebp
  802534:	75 0b                	jne    802541 <__umoddi3+0x91>
  802536:	b8 01 00 00 00       	mov    $0x1,%eax
  80253b:	31 d2                	xor    %edx,%edx
  80253d:	f7 f7                	div    %edi
  80253f:	89 c5                	mov    %eax,%ebp
  802541:	89 f0                	mov    %esi,%eax
  802543:	31 d2                	xor    %edx,%edx
  802545:	f7 f5                	div    %ebp
  802547:	89 c8                	mov    %ecx,%eax
  802549:	f7 f5                	div    %ebp
  80254b:	89 d0                	mov    %edx,%eax
  80254d:	eb 99                	jmp    8024e8 <__umoddi3+0x38>
  80254f:	90                   	nop
  802550:	89 c8                	mov    %ecx,%eax
  802552:	89 f2                	mov    %esi,%edx
  802554:	83 c4 1c             	add    $0x1c,%esp
  802557:	5b                   	pop    %ebx
  802558:	5e                   	pop    %esi
  802559:	5f                   	pop    %edi
  80255a:	5d                   	pop    %ebp
  80255b:	c3                   	ret    
  80255c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802560:	8b 34 24             	mov    (%esp),%esi
  802563:	bf 20 00 00 00       	mov    $0x20,%edi
  802568:	89 e9                	mov    %ebp,%ecx
  80256a:	29 ef                	sub    %ebp,%edi
  80256c:	d3 e0                	shl    %cl,%eax
  80256e:	89 f9                	mov    %edi,%ecx
  802570:	89 f2                	mov    %esi,%edx
  802572:	d3 ea                	shr    %cl,%edx
  802574:	89 e9                	mov    %ebp,%ecx
  802576:	09 c2                	or     %eax,%edx
  802578:	89 d8                	mov    %ebx,%eax
  80257a:	89 14 24             	mov    %edx,(%esp)
  80257d:	89 f2                	mov    %esi,%edx
  80257f:	d3 e2                	shl    %cl,%edx
  802581:	89 f9                	mov    %edi,%ecx
  802583:	89 54 24 04          	mov    %edx,0x4(%esp)
  802587:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80258b:	d3 e8                	shr    %cl,%eax
  80258d:	89 e9                	mov    %ebp,%ecx
  80258f:	89 c6                	mov    %eax,%esi
  802591:	d3 e3                	shl    %cl,%ebx
  802593:	89 f9                	mov    %edi,%ecx
  802595:	89 d0                	mov    %edx,%eax
  802597:	d3 e8                	shr    %cl,%eax
  802599:	89 e9                	mov    %ebp,%ecx
  80259b:	09 d8                	or     %ebx,%eax
  80259d:	89 d3                	mov    %edx,%ebx
  80259f:	89 f2                	mov    %esi,%edx
  8025a1:	f7 34 24             	divl   (%esp)
  8025a4:	89 d6                	mov    %edx,%esi
  8025a6:	d3 e3                	shl    %cl,%ebx
  8025a8:	f7 64 24 04          	mull   0x4(%esp)
  8025ac:	39 d6                	cmp    %edx,%esi
  8025ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8025b2:	89 d1                	mov    %edx,%ecx
  8025b4:	89 c3                	mov    %eax,%ebx
  8025b6:	72 08                	jb     8025c0 <__umoddi3+0x110>
  8025b8:	75 11                	jne    8025cb <__umoddi3+0x11b>
  8025ba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8025be:	73 0b                	jae    8025cb <__umoddi3+0x11b>
  8025c0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8025c4:	1b 14 24             	sbb    (%esp),%edx
  8025c7:	89 d1                	mov    %edx,%ecx
  8025c9:	89 c3                	mov    %eax,%ebx
  8025cb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8025cf:	29 da                	sub    %ebx,%edx
  8025d1:	19 ce                	sbb    %ecx,%esi
  8025d3:	89 f9                	mov    %edi,%ecx
  8025d5:	89 f0                	mov    %esi,%eax
  8025d7:	d3 e0                	shl    %cl,%eax
  8025d9:	89 e9                	mov    %ebp,%ecx
  8025db:	d3 ea                	shr    %cl,%edx
  8025dd:	89 e9                	mov    %ebp,%ecx
  8025df:	d3 ee                	shr    %cl,%esi
  8025e1:	09 d0                	or     %edx,%eax
  8025e3:	89 f2                	mov    %esi,%edx
  8025e5:	83 c4 1c             	add    $0x1c,%esp
  8025e8:	5b                   	pop    %ebx
  8025e9:	5e                   	pop    %esi
  8025ea:	5f                   	pop    %edi
  8025eb:	5d                   	pop    %ebp
  8025ec:	c3                   	ret    
  8025ed:	8d 76 00             	lea    0x0(%esi),%esi
  8025f0:	29 f9                	sub    %edi,%ecx
  8025f2:	19 d6                	sbb    %edx,%esi
  8025f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8025f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8025fc:	e9 18 ff ff ff       	jmp    802519 <__umoddi3+0x69>
