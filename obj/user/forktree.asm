
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
  800047:	68 a0 21 80 00       	push   $0x8021a0
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
  800095:	68 b1 21 80 00       	push   $0x8021b1
  80009a:	6a 04                	push   $0x4
  80009c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80009f:	50                   	push   %eax
  8000a0:	e8 61 06 00 00       	call   800706 <snprintf>
	if (fork() == 0) {
  8000a5:	83 c4 20             	add    $0x20,%esp
  8000a8:	e8 54 0e 00 00       	call   800f01 <fork>
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
  8000d2:	68 b0 21 80 00       	push   $0x8021b0
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
  8000fe:	a3 04 40 80 00       	mov    %eax,0x804004

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
  80012d:	e8 8f 10 00 00       	call   8011c1 <close_all>
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
  800237:	e8 c4 1c 00 00       	call   801f00 <__udivdi3>
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
  80027a:	e8 b1 1d 00 00       	call   802030 <__umoddi3>
  80027f:	83 c4 14             	add    $0x14,%esp
  800282:	0f be 80 c0 21 80 00 	movsbl 0x8021c0(%eax),%eax
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
  80037e:	ff 24 85 00 23 80 00 	jmp    *0x802300(,%eax,4)
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
  800442:	8b 14 85 60 24 80 00 	mov    0x802460(,%eax,4),%edx
  800449:	85 d2                	test   %edx,%edx
  80044b:	75 18                	jne    800465 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80044d:	50                   	push   %eax
  80044e:	68 d8 21 80 00       	push   $0x8021d8
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
  800466:	68 16 26 80 00       	push   $0x802616
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
  80048a:	b8 d1 21 80 00       	mov    $0x8021d1,%eax
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
  800b05:	68 bf 24 80 00       	push   $0x8024bf
  800b0a:	6a 23                	push   $0x23
  800b0c:	68 dc 24 80 00       	push   $0x8024dc
  800b11:	e8 f3 11 00 00       	call   801d09 <_panic>

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
  800b86:	68 bf 24 80 00       	push   $0x8024bf
  800b8b:	6a 23                	push   $0x23
  800b8d:	68 dc 24 80 00       	push   $0x8024dc
  800b92:	e8 72 11 00 00       	call   801d09 <_panic>

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
  800bc8:	68 bf 24 80 00       	push   $0x8024bf
  800bcd:	6a 23                	push   $0x23
  800bcf:	68 dc 24 80 00       	push   $0x8024dc
  800bd4:	e8 30 11 00 00       	call   801d09 <_panic>

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
  800c0a:	68 bf 24 80 00       	push   $0x8024bf
  800c0f:	6a 23                	push   $0x23
  800c11:	68 dc 24 80 00       	push   $0x8024dc
  800c16:	e8 ee 10 00 00       	call   801d09 <_panic>

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
  800c4c:	68 bf 24 80 00       	push   $0x8024bf
  800c51:	6a 23                	push   $0x23
  800c53:	68 dc 24 80 00       	push   $0x8024dc
  800c58:	e8 ac 10 00 00       	call   801d09 <_panic>

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
  800c8e:	68 bf 24 80 00       	push   $0x8024bf
  800c93:	6a 23                	push   $0x23
  800c95:	68 dc 24 80 00       	push   $0x8024dc
  800c9a:	e8 6a 10 00 00       	call   801d09 <_panic>

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
  800cd0:	68 bf 24 80 00       	push   $0x8024bf
  800cd5:	6a 23                	push   $0x23
  800cd7:	68 dc 24 80 00       	push   $0x8024dc
  800cdc:	e8 28 10 00 00       	call   801d09 <_panic>

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
  800d34:	68 bf 24 80 00       	push   $0x8024bf
  800d39:	6a 23                	push   $0x23
  800d3b:	68 dc 24 80 00       	push   $0x8024dc
  800d40:	e8 c4 0f 00 00       	call   801d09 <_panic>

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

00800d4d <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800d4d:	55                   	push   %ebp
  800d4e:	89 e5                	mov    %esp,%ebp
  800d50:	53                   	push   %ebx
  800d51:	83 ec 04             	sub    $0x4,%esp
	int r;
	void * address = (void *)(pn*PGSIZE);
  800d54:	89 d3                	mov    %edx,%ebx
  800d56:	c1 e3 0c             	shl    $0xc,%ebx
	
	if((uvpt[pn] & PTE_SHARE))
  800d59:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800d60:	f6 c5 04             	test   $0x4,%ch
  800d63:	74 38                	je     800d9d <duppage+0x50>
	{
		if ((r = sys_page_map(0, address, envid, address, (uvpt[pn] | PTE_SYSCALL))) < 0)
  800d65:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d6c:	83 ec 0c             	sub    $0xc,%esp
  800d6f:	81 ca 07 0e 00 00    	or     $0xe07,%edx
  800d75:	52                   	push   %edx
  800d76:	53                   	push   %ebx
  800d77:	50                   	push   %eax
  800d78:	53                   	push   %ebx
  800d79:	6a 00                	push   $0x0
  800d7b:	e8 1f fe ff ff       	call   800b9f <sys_page_map>
  800d80:	83 c4 20             	add    $0x20,%esp
  800d83:	85 c0                	test   %eax,%eax
  800d85:	0f 89 b8 00 00 00    	jns    800e43 <duppage+0xf6>
			panic("sys_page_map: %e", r);
  800d8b:	50                   	push   %eax
  800d8c:	68 ea 24 80 00       	push   $0x8024ea
  800d91:	6a 4e                	push   $0x4e
  800d93:	68 fb 24 80 00       	push   $0x8024fb
  800d98:	e8 6c 0f 00 00       	call   801d09 <_panic>
	}
	else if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW))
  800d9d:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800da4:	f6 c1 02             	test   $0x2,%cl
  800da7:	75 0c                	jne    800db5 <duppage+0x68>
  800da9:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800db0:	f6 c5 08             	test   $0x8,%ch
  800db3:	74 57                	je     800e0c <duppage+0xbf>
	{
		int perm = 0;
		perm |= PTE_P|PTE_U|PTE_COW;
	
		if ((r = sys_page_map(0, address, envid, address, perm)) < 0)
  800db5:	83 ec 0c             	sub    $0xc,%esp
  800db8:	68 05 08 00 00       	push   $0x805
  800dbd:	53                   	push   %ebx
  800dbe:	50                   	push   %eax
  800dbf:	53                   	push   %ebx
  800dc0:	6a 00                	push   $0x0
  800dc2:	e8 d8 fd ff ff       	call   800b9f <sys_page_map>
  800dc7:	83 c4 20             	add    $0x20,%esp
  800dca:	85 c0                	test   %eax,%eax
  800dcc:	79 12                	jns    800de0 <duppage+0x93>
			panic("sys_page_map: %e", r);
  800dce:	50                   	push   %eax
  800dcf:	68 ea 24 80 00       	push   $0x8024ea
  800dd4:	6a 56                	push   $0x56
  800dd6:	68 fb 24 80 00       	push   $0x8024fb
  800ddb:	e8 29 0f 00 00       	call   801d09 <_panic>
		if ((r = sys_page_map(0, address, 0, address, perm)) < 0)
  800de0:	83 ec 0c             	sub    $0xc,%esp
  800de3:	68 05 08 00 00       	push   $0x805
  800de8:	53                   	push   %ebx
  800de9:	6a 00                	push   $0x0
  800deb:	53                   	push   %ebx
  800dec:	6a 00                	push   $0x0
  800dee:	e8 ac fd ff ff       	call   800b9f <sys_page_map>
  800df3:	83 c4 20             	add    $0x20,%esp
  800df6:	85 c0                	test   %eax,%eax
  800df8:	79 49                	jns    800e43 <duppage+0xf6>
			panic("sys_page_map: %e", r);
  800dfa:	50                   	push   %eax
  800dfb:	68 ea 24 80 00       	push   $0x8024ea
  800e00:	6a 58                	push   $0x58
  800e02:	68 fb 24 80 00       	push   $0x8024fb
  800e07:	e8 fd 0e 00 00       	call   801d09 <_panic>
	}
	else if((uvpt[pn] & ~PTE_U) == 0)
  800e0c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e13:	f7 c2 fb ff ff ff    	test   $0xfffffffb,%edx
  800e19:	75 28                	jne    800e43 <duppage+0xf6>
	{
		//cprintf("im here");
		if ((r = sys_page_map(0, address, envid, address, PTE_P|PTE_U)) < 0)
  800e1b:	83 ec 0c             	sub    $0xc,%esp
  800e1e:	6a 05                	push   $0x5
  800e20:	53                   	push   %ebx
  800e21:	50                   	push   %eax
  800e22:	53                   	push   %ebx
  800e23:	6a 00                	push   $0x0
  800e25:	e8 75 fd ff ff       	call   800b9f <sys_page_map>
  800e2a:	83 c4 20             	add    $0x20,%esp
  800e2d:	85 c0                	test   %eax,%eax
  800e2f:	79 12                	jns    800e43 <duppage+0xf6>
			panic("sys_page_map: %e", r);	
  800e31:	50                   	push   %eax
  800e32:	68 ea 24 80 00       	push   $0x8024ea
  800e37:	6a 5e                	push   $0x5e
  800e39:	68 fb 24 80 00       	push   $0x8024fb
  800e3e:	e8 c6 0e 00 00       	call   801d09 <_panic>
	}
	return 0;
}
  800e43:	b8 00 00 00 00       	mov    $0x0,%eax
  800e48:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e4b:	c9                   	leave  
  800e4c:	c3                   	ret    

00800e4d <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e4d:	55                   	push   %ebp
  800e4e:	89 e5                	mov    %esp,%ebp
  800e50:	53                   	push   %ebx
  800e51:	83 ec 08             	sub    $0x8,%esp
	void *addr = (void *) utf->utf_fault_va;
  800e54:	8b 45 08             	mov    0x8(%ebp),%eax
  800e57:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	unsigned pn = ((uint32_t)addr)/PGSIZE;
  800e59:	89 d8                	mov    %ebx,%eax
  800e5b:	c1 e8 0c             	shr    $0xc,%eax
	pte_t pte = uvpt[pn];
  800e5e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// Allocate a new page, mapped at temp location
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  800e65:	6a 07                	push   $0x7
  800e67:	68 00 f0 7f 00       	push   $0x7ff000
  800e6c:	6a 00                	push   $0x0
  800e6e:	e8 e9 fc ff ff       	call   800b5c <sys_page_alloc>
  800e73:	83 c4 10             	add    $0x10,%esp
  800e76:	85 c0                	test   %eax,%eax
  800e78:	79 12                	jns    800e8c <pgfault+0x3f>
		panic("sys_page_alloc: %e", r);
  800e7a:	50                   	push   %eax
  800e7b:	68 06 25 80 00       	push   $0x802506
  800e80:	6a 2b                	push   $0x2b
  800e82:	68 fb 24 80 00       	push   $0x8024fb
  800e87:	e8 7d 0e 00 00       	call   801d09 <_panic>

	// Copy the data from the old page to this new page
	void *addr_pgstart = (void *) ROUNDDOWN(addr, PGSIZE);
  800e8c:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr_pgstart, PGSIZE);
  800e92:	83 ec 04             	sub    $0x4,%esp
  800e95:	68 00 10 00 00       	push   $0x1000
  800e9a:	53                   	push   %ebx
  800e9b:	68 00 f0 7f 00       	push   $0x7ff000
  800ea0:	e8 46 fa ff ff       	call   8008eb <memmove>

	// Move the new page to the old page's address
	if ((r = sys_page_map(0, PFTEMP, 0, addr_pgstart, PTE_P|PTE_U|PTE_W)) < 0)
  800ea5:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800eac:	53                   	push   %ebx
  800ead:	6a 00                	push   $0x0
  800eaf:	68 00 f0 7f 00       	push   $0x7ff000
  800eb4:	6a 00                	push   $0x0
  800eb6:	e8 e4 fc ff ff       	call   800b9f <sys_page_map>
  800ebb:	83 c4 20             	add    $0x20,%esp
  800ebe:	85 c0                	test   %eax,%eax
  800ec0:	79 12                	jns    800ed4 <pgfault+0x87>
		panic("sys_page_map: %e", r);
  800ec2:	50                   	push   %eax
  800ec3:	68 ea 24 80 00       	push   $0x8024ea
  800ec8:	6a 33                	push   $0x33
  800eca:	68 fb 24 80 00       	push   $0x8024fb
  800ecf:	e8 35 0e 00 00       	call   801d09 <_panic>

	// Unmap the temp location
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800ed4:	83 ec 08             	sub    $0x8,%esp
  800ed7:	68 00 f0 7f 00       	push   $0x7ff000
  800edc:	6a 00                	push   $0x0
  800ede:	e8 fe fc ff ff       	call   800be1 <sys_page_unmap>
  800ee3:	83 c4 10             	add    $0x10,%esp
  800ee6:	85 c0                	test   %eax,%eax
  800ee8:	79 12                	jns    800efc <pgfault+0xaf>
		panic("sys_page_unmap: %e", r);
  800eea:	50                   	push   %eax
  800eeb:	68 19 25 80 00       	push   $0x802519
  800ef0:	6a 37                	push   $0x37
  800ef2:	68 fb 24 80 00       	push   $0x8024fb
  800ef7:	e8 0d 0e 00 00       	call   801d09 <_panic>
}
  800efc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800eff:	c9                   	leave  
  800f00:	c3                   	ret    

00800f01 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f01:	55                   	push   %ebp
  800f02:	89 e5                	mov    %esp,%ebp
  800f04:	56                   	push   %esi
  800f05:	53                   	push   %ebx
  800f06:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
	// Set up page fault handler
	set_pgfault_handler(&pgfault);
  800f09:	68 4d 0e 80 00       	push   $0x800e4d
  800f0e:	e8 3c 0e 00 00       	call   801d4f <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f13:	b8 07 00 00 00       	mov    $0x7,%eax
  800f18:	cd 30                	int    $0x30

	// Create child
	envid_t envid = sys_exofork();
  800f1a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (envid < 0) {
  800f1d:	83 c4 10             	add    $0x10,%esp
  800f20:	85 c0                	test   %eax,%eax
  800f22:	79 12                	jns    800f36 <fork+0x35>
		panic("sys_exofork: %e", envid);
  800f24:	50                   	push   %eax
  800f25:	68 2c 25 80 00       	push   $0x80252c
  800f2a:	6a 7c                	push   $0x7c
  800f2c:	68 fb 24 80 00       	push   $0x8024fb
  800f31:	e8 d3 0d 00 00       	call   801d09 <_panic>
		return envid;
	}
	if (envid == 0) {
  800f36:	85 c0                	test   %eax,%eax
  800f38:	75 1e                	jne    800f58 <fork+0x57>
		// We are the child.
		thisenv = &envs[ENVX(sys_getenvid())]; // Fix thisenv
  800f3a:	e8 df fb ff ff       	call   800b1e <sys_getenvid>
  800f3f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f44:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f47:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f4c:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800f51:	b8 00 00 00 00       	mov    $0x0,%eax
  800f56:	eb 7d                	jmp    800fd5 <fork+0xd4>

	// Set page fault handler on the child.
	// The parent needs to do it, else the child wouldn't be able to handle
	// the fault when trying to access it's stack (which happens as soon it starts)
	extern void _pgfault_upcall(void);
	sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);
  800f58:	83 ec 04             	sub    $0x4,%esp
  800f5b:	6a 07                	push   $0x7
  800f5d:	68 00 f0 bf ee       	push   $0xeebff000
  800f62:	50                   	push   %eax
  800f63:	e8 f4 fb ff ff       	call   800b5c <sys_page_alloc>
	sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  800f68:	83 c4 08             	add    $0x8,%esp
  800f6b:	68 94 1d 80 00       	push   $0x801d94
  800f70:	ff 75 f4             	pushl  -0xc(%ebp)
  800f73:	e8 2f fd ff ff       	call   800ca7 <sys_env_set_pgfault_upcall>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  800f78:	be 04 60 80 00       	mov    $0x806004,%esi
  800f7d:	c1 ee 0c             	shr    $0xc,%esi
  800f80:	83 c4 10             	add    $0x10,%esp
  800f83:	bb 00 08 00 00       	mov    $0x800,%ebx
  800f88:	eb 0d                	jmp    800f97 <fork+0x96>
		duppage(envid, pn);
  800f8a:	89 da                	mov    %ebx,%edx
  800f8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f8f:	e8 b9 fd ff ff       	call   800d4d <duppage>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  800f94:	83 c3 01             	add    $0x1,%ebx
  800f97:	39 f3                	cmp    %esi,%ebx
  800f99:	76 ef                	jbe    800f8a <fork+0x89>
	}

	// Also copy the stack we are currently running on
	// I think it should loop from ustacktop to this page, since the stack
	// can have more than 1 page
	duppage(envid, ((uint32_t) &envid)/PGSIZE);
  800f9b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800f9e:	c1 ea 0c             	shr    $0xc,%edx
  800fa1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fa4:	e8 a4 fd ff ff       	call   800d4d <duppage>

	// Start the child environmnet running
	int r;
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  800fa9:	83 ec 08             	sub    $0x8,%esp
  800fac:	6a 02                	push   $0x2
  800fae:	ff 75 f4             	pushl  -0xc(%ebp)
  800fb1:	e8 6d fc ff ff       	call   800c23 <sys_env_set_status>
  800fb6:	83 c4 10             	add    $0x10,%esp
  800fb9:	85 c0                	test   %eax,%eax
  800fbb:	79 15                	jns    800fd2 <fork+0xd1>
		panic("sys_env_set_status: %e", r);
  800fbd:	50                   	push   %eax
  800fbe:	68 3c 25 80 00       	push   $0x80253c
  800fc3:	68 9c 00 00 00       	push   $0x9c
  800fc8:	68 fb 24 80 00       	push   $0x8024fb
  800fcd:	e8 37 0d 00 00       	call   801d09 <_panic>
		return r;
	}

	return envid;
  800fd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800fd5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fd8:	5b                   	pop    %ebx
  800fd9:	5e                   	pop    %esi
  800fda:	5d                   	pop    %ebp
  800fdb:	c3                   	ret    

00800fdc <sfork>:

// Challenge!
int
sfork(void)
{
  800fdc:	55                   	push   %ebp
  800fdd:	89 e5                	mov    %esp,%ebp
  800fdf:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800fe2:	68 53 25 80 00       	push   $0x802553
  800fe7:	68 a7 00 00 00       	push   $0xa7
  800fec:	68 fb 24 80 00       	push   $0x8024fb
  800ff1:	e8 13 0d 00 00       	call   801d09 <_panic>

00800ff6 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800ff6:	55                   	push   %ebp
  800ff7:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ff9:	8b 45 08             	mov    0x8(%ebp),%eax
  800ffc:	05 00 00 00 30       	add    $0x30000000,%eax
  801001:	c1 e8 0c             	shr    $0xc,%eax
}
  801004:	5d                   	pop    %ebp
  801005:	c3                   	ret    

00801006 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801006:	55                   	push   %ebp
  801007:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801009:	8b 45 08             	mov    0x8(%ebp),%eax
  80100c:	05 00 00 00 30       	add    $0x30000000,%eax
  801011:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801016:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80101b:	5d                   	pop    %ebp
  80101c:	c3                   	ret    

0080101d <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80101d:	55                   	push   %ebp
  80101e:	89 e5                	mov    %esp,%ebp
  801020:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801023:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801028:	89 c2                	mov    %eax,%edx
  80102a:	c1 ea 16             	shr    $0x16,%edx
  80102d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801034:	f6 c2 01             	test   $0x1,%dl
  801037:	74 11                	je     80104a <fd_alloc+0x2d>
  801039:	89 c2                	mov    %eax,%edx
  80103b:	c1 ea 0c             	shr    $0xc,%edx
  80103e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801045:	f6 c2 01             	test   $0x1,%dl
  801048:	75 09                	jne    801053 <fd_alloc+0x36>
			*fd_store = fd;
  80104a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80104c:	b8 00 00 00 00       	mov    $0x0,%eax
  801051:	eb 17                	jmp    80106a <fd_alloc+0x4d>
  801053:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801058:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80105d:	75 c9                	jne    801028 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80105f:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801065:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80106a:	5d                   	pop    %ebp
  80106b:	c3                   	ret    

0080106c <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80106c:	55                   	push   %ebp
  80106d:	89 e5                	mov    %esp,%ebp
  80106f:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801072:	83 f8 1f             	cmp    $0x1f,%eax
  801075:	77 36                	ja     8010ad <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801077:	c1 e0 0c             	shl    $0xc,%eax
  80107a:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80107f:	89 c2                	mov    %eax,%edx
  801081:	c1 ea 16             	shr    $0x16,%edx
  801084:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80108b:	f6 c2 01             	test   $0x1,%dl
  80108e:	74 24                	je     8010b4 <fd_lookup+0x48>
  801090:	89 c2                	mov    %eax,%edx
  801092:	c1 ea 0c             	shr    $0xc,%edx
  801095:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80109c:	f6 c2 01             	test   $0x1,%dl
  80109f:	74 1a                	je     8010bb <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8010a1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010a4:	89 02                	mov    %eax,(%edx)
	return 0;
  8010a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8010ab:	eb 13                	jmp    8010c0 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010ad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010b2:	eb 0c                	jmp    8010c0 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010b4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010b9:	eb 05                	jmp    8010c0 <fd_lookup+0x54>
  8010bb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8010c0:	5d                   	pop    %ebp
  8010c1:	c3                   	ret    

008010c2 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8010c2:	55                   	push   %ebp
  8010c3:	89 e5                	mov    %esp,%ebp
  8010c5:	83 ec 08             	sub    $0x8,%esp
  8010c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010cb:	ba e8 25 80 00       	mov    $0x8025e8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8010d0:	eb 13                	jmp    8010e5 <dev_lookup+0x23>
  8010d2:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8010d5:	39 08                	cmp    %ecx,(%eax)
  8010d7:	75 0c                	jne    8010e5 <dev_lookup+0x23>
			*dev = devtab[i];
  8010d9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010dc:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010de:	b8 00 00 00 00       	mov    $0x0,%eax
  8010e3:	eb 2e                	jmp    801113 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8010e5:	8b 02                	mov    (%edx),%eax
  8010e7:	85 c0                	test   %eax,%eax
  8010e9:	75 e7                	jne    8010d2 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8010eb:	a1 04 40 80 00       	mov    0x804004,%eax
  8010f0:	8b 40 48             	mov    0x48(%eax),%eax
  8010f3:	83 ec 04             	sub    $0x4,%esp
  8010f6:	51                   	push   %ecx
  8010f7:	50                   	push   %eax
  8010f8:	68 6c 25 80 00       	push   $0x80256c
  8010fd:	e8 d2 f0 ff ff       	call   8001d4 <cprintf>
	*dev = 0;
  801102:	8b 45 0c             	mov    0xc(%ebp),%eax
  801105:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80110b:	83 c4 10             	add    $0x10,%esp
  80110e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801113:	c9                   	leave  
  801114:	c3                   	ret    

00801115 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801115:	55                   	push   %ebp
  801116:	89 e5                	mov    %esp,%ebp
  801118:	56                   	push   %esi
  801119:	53                   	push   %ebx
  80111a:	83 ec 10             	sub    $0x10,%esp
  80111d:	8b 75 08             	mov    0x8(%ebp),%esi
  801120:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801123:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801126:	50                   	push   %eax
  801127:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80112d:	c1 e8 0c             	shr    $0xc,%eax
  801130:	50                   	push   %eax
  801131:	e8 36 ff ff ff       	call   80106c <fd_lookup>
  801136:	83 c4 08             	add    $0x8,%esp
  801139:	85 c0                	test   %eax,%eax
  80113b:	78 05                	js     801142 <fd_close+0x2d>
	    || fd != fd2)
  80113d:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801140:	74 0c                	je     80114e <fd_close+0x39>
		return (must_exist ? r : 0);
  801142:	84 db                	test   %bl,%bl
  801144:	ba 00 00 00 00       	mov    $0x0,%edx
  801149:	0f 44 c2             	cmove  %edx,%eax
  80114c:	eb 41                	jmp    80118f <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80114e:	83 ec 08             	sub    $0x8,%esp
  801151:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801154:	50                   	push   %eax
  801155:	ff 36                	pushl  (%esi)
  801157:	e8 66 ff ff ff       	call   8010c2 <dev_lookup>
  80115c:	89 c3                	mov    %eax,%ebx
  80115e:	83 c4 10             	add    $0x10,%esp
  801161:	85 c0                	test   %eax,%eax
  801163:	78 1a                	js     80117f <fd_close+0x6a>
		if (dev->dev_close)
  801165:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801168:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80116b:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801170:	85 c0                	test   %eax,%eax
  801172:	74 0b                	je     80117f <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801174:	83 ec 0c             	sub    $0xc,%esp
  801177:	56                   	push   %esi
  801178:	ff d0                	call   *%eax
  80117a:	89 c3                	mov    %eax,%ebx
  80117c:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80117f:	83 ec 08             	sub    $0x8,%esp
  801182:	56                   	push   %esi
  801183:	6a 00                	push   $0x0
  801185:	e8 57 fa ff ff       	call   800be1 <sys_page_unmap>
	return r;
  80118a:	83 c4 10             	add    $0x10,%esp
  80118d:	89 d8                	mov    %ebx,%eax
}
  80118f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801192:	5b                   	pop    %ebx
  801193:	5e                   	pop    %esi
  801194:	5d                   	pop    %ebp
  801195:	c3                   	ret    

00801196 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801196:	55                   	push   %ebp
  801197:	89 e5                	mov    %esp,%ebp
  801199:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80119c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80119f:	50                   	push   %eax
  8011a0:	ff 75 08             	pushl  0x8(%ebp)
  8011a3:	e8 c4 fe ff ff       	call   80106c <fd_lookup>
  8011a8:	83 c4 08             	add    $0x8,%esp
  8011ab:	85 c0                	test   %eax,%eax
  8011ad:	78 10                	js     8011bf <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8011af:	83 ec 08             	sub    $0x8,%esp
  8011b2:	6a 01                	push   $0x1
  8011b4:	ff 75 f4             	pushl  -0xc(%ebp)
  8011b7:	e8 59 ff ff ff       	call   801115 <fd_close>
  8011bc:	83 c4 10             	add    $0x10,%esp
}
  8011bf:	c9                   	leave  
  8011c0:	c3                   	ret    

008011c1 <close_all>:

void
close_all(void)
{
  8011c1:	55                   	push   %ebp
  8011c2:	89 e5                	mov    %esp,%ebp
  8011c4:	53                   	push   %ebx
  8011c5:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8011c8:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8011cd:	83 ec 0c             	sub    $0xc,%esp
  8011d0:	53                   	push   %ebx
  8011d1:	e8 c0 ff ff ff       	call   801196 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8011d6:	83 c3 01             	add    $0x1,%ebx
  8011d9:	83 c4 10             	add    $0x10,%esp
  8011dc:	83 fb 20             	cmp    $0x20,%ebx
  8011df:	75 ec                	jne    8011cd <close_all+0xc>
		close(i);
}
  8011e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011e4:	c9                   	leave  
  8011e5:	c3                   	ret    

008011e6 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8011e6:	55                   	push   %ebp
  8011e7:	89 e5                	mov    %esp,%ebp
  8011e9:	57                   	push   %edi
  8011ea:	56                   	push   %esi
  8011eb:	53                   	push   %ebx
  8011ec:	83 ec 2c             	sub    $0x2c,%esp
  8011ef:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8011f2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8011f5:	50                   	push   %eax
  8011f6:	ff 75 08             	pushl  0x8(%ebp)
  8011f9:	e8 6e fe ff ff       	call   80106c <fd_lookup>
  8011fe:	83 c4 08             	add    $0x8,%esp
  801201:	85 c0                	test   %eax,%eax
  801203:	0f 88 c1 00 00 00    	js     8012ca <dup+0xe4>
		return r;
	close(newfdnum);
  801209:	83 ec 0c             	sub    $0xc,%esp
  80120c:	56                   	push   %esi
  80120d:	e8 84 ff ff ff       	call   801196 <close>

	newfd = INDEX2FD(newfdnum);
  801212:	89 f3                	mov    %esi,%ebx
  801214:	c1 e3 0c             	shl    $0xc,%ebx
  801217:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80121d:	83 c4 04             	add    $0x4,%esp
  801220:	ff 75 e4             	pushl  -0x1c(%ebp)
  801223:	e8 de fd ff ff       	call   801006 <fd2data>
  801228:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80122a:	89 1c 24             	mov    %ebx,(%esp)
  80122d:	e8 d4 fd ff ff       	call   801006 <fd2data>
  801232:	83 c4 10             	add    $0x10,%esp
  801235:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801238:	89 f8                	mov    %edi,%eax
  80123a:	c1 e8 16             	shr    $0x16,%eax
  80123d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801244:	a8 01                	test   $0x1,%al
  801246:	74 37                	je     80127f <dup+0x99>
  801248:	89 f8                	mov    %edi,%eax
  80124a:	c1 e8 0c             	shr    $0xc,%eax
  80124d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801254:	f6 c2 01             	test   $0x1,%dl
  801257:	74 26                	je     80127f <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801259:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801260:	83 ec 0c             	sub    $0xc,%esp
  801263:	25 07 0e 00 00       	and    $0xe07,%eax
  801268:	50                   	push   %eax
  801269:	ff 75 d4             	pushl  -0x2c(%ebp)
  80126c:	6a 00                	push   $0x0
  80126e:	57                   	push   %edi
  80126f:	6a 00                	push   $0x0
  801271:	e8 29 f9 ff ff       	call   800b9f <sys_page_map>
  801276:	89 c7                	mov    %eax,%edi
  801278:	83 c4 20             	add    $0x20,%esp
  80127b:	85 c0                	test   %eax,%eax
  80127d:	78 2e                	js     8012ad <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80127f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801282:	89 d0                	mov    %edx,%eax
  801284:	c1 e8 0c             	shr    $0xc,%eax
  801287:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80128e:	83 ec 0c             	sub    $0xc,%esp
  801291:	25 07 0e 00 00       	and    $0xe07,%eax
  801296:	50                   	push   %eax
  801297:	53                   	push   %ebx
  801298:	6a 00                	push   $0x0
  80129a:	52                   	push   %edx
  80129b:	6a 00                	push   $0x0
  80129d:	e8 fd f8 ff ff       	call   800b9f <sys_page_map>
  8012a2:	89 c7                	mov    %eax,%edi
  8012a4:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8012a7:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012a9:	85 ff                	test   %edi,%edi
  8012ab:	79 1d                	jns    8012ca <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8012ad:	83 ec 08             	sub    $0x8,%esp
  8012b0:	53                   	push   %ebx
  8012b1:	6a 00                	push   $0x0
  8012b3:	e8 29 f9 ff ff       	call   800be1 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8012b8:	83 c4 08             	add    $0x8,%esp
  8012bb:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012be:	6a 00                	push   $0x0
  8012c0:	e8 1c f9 ff ff       	call   800be1 <sys_page_unmap>
	return r;
  8012c5:	83 c4 10             	add    $0x10,%esp
  8012c8:	89 f8                	mov    %edi,%eax
}
  8012ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012cd:	5b                   	pop    %ebx
  8012ce:	5e                   	pop    %esi
  8012cf:	5f                   	pop    %edi
  8012d0:	5d                   	pop    %ebp
  8012d1:	c3                   	ret    

008012d2 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8012d2:	55                   	push   %ebp
  8012d3:	89 e5                	mov    %esp,%ebp
  8012d5:	53                   	push   %ebx
  8012d6:	83 ec 14             	sub    $0x14,%esp
  8012d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012dc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012df:	50                   	push   %eax
  8012e0:	53                   	push   %ebx
  8012e1:	e8 86 fd ff ff       	call   80106c <fd_lookup>
  8012e6:	83 c4 08             	add    $0x8,%esp
  8012e9:	89 c2                	mov    %eax,%edx
  8012eb:	85 c0                	test   %eax,%eax
  8012ed:	78 6d                	js     80135c <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ef:	83 ec 08             	sub    $0x8,%esp
  8012f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f5:	50                   	push   %eax
  8012f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f9:	ff 30                	pushl  (%eax)
  8012fb:	e8 c2 fd ff ff       	call   8010c2 <dev_lookup>
  801300:	83 c4 10             	add    $0x10,%esp
  801303:	85 c0                	test   %eax,%eax
  801305:	78 4c                	js     801353 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801307:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80130a:	8b 42 08             	mov    0x8(%edx),%eax
  80130d:	83 e0 03             	and    $0x3,%eax
  801310:	83 f8 01             	cmp    $0x1,%eax
  801313:	75 21                	jne    801336 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801315:	a1 04 40 80 00       	mov    0x804004,%eax
  80131a:	8b 40 48             	mov    0x48(%eax),%eax
  80131d:	83 ec 04             	sub    $0x4,%esp
  801320:	53                   	push   %ebx
  801321:	50                   	push   %eax
  801322:	68 ad 25 80 00       	push   $0x8025ad
  801327:	e8 a8 ee ff ff       	call   8001d4 <cprintf>
		return -E_INVAL;
  80132c:	83 c4 10             	add    $0x10,%esp
  80132f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801334:	eb 26                	jmp    80135c <read+0x8a>
	}
	if (!dev->dev_read)
  801336:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801339:	8b 40 08             	mov    0x8(%eax),%eax
  80133c:	85 c0                	test   %eax,%eax
  80133e:	74 17                	je     801357 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801340:	83 ec 04             	sub    $0x4,%esp
  801343:	ff 75 10             	pushl  0x10(%ebp)
  801346:	ff 75 0c             	pushl  0xc(%ebp)
  801349:	52                   	push   %edx
  80134a:	ff d0                	call   *%eax
  80134c:	89 c2                	mov    %eax,%edx
  80134e:	83 c4 10             	add    $0x10,%esp
  801351:	eb 09                	jmp    80135c <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801353:	89 c2                	mov    %eax,%edx
  801355:	eb 05                	jmp    80135c <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801357:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80135c:	89 d0                	mov    %edx,%eax
  80135e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801361:	c9                   	leave  
  801362:	c3                   	ret    

00801363 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801363:	55                   	push   %ebp
  801364:	89 e5                	mov    %esp,%ebp
  801366:	57                   	push   %edi
  801367:	56                   	push   %esi
  801368:	53                   	push   %ebx
  801369:	83 ec 0c             	sub    $0xc,%esp
  80136c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80136f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801372:	bb 00 00 00 00       	mov    $0x0,%ebx
  801377:	eb 21                	jmp    80139a <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801379:	83 ec 04             	sub    $0x4,%esp
  80137c:	89 f0                	mov    %esi,%eax
  80137e:	29 d8                	sub    %ebx,%eax
  801380:	50                   	push   %eax
  801381:	89 d8                	mov    %ebx,%eax
  801383:	03 45 0c             	add    0xc(%ebp),%eax
  801386:	50                   	push   %eax
  801387:	57                   	push   %edi
  801388:	e8 45 ff ff ff       	call   8012d2 <read>
		if (m < 0)
  80138d:	83 c4 10             	add    $0x10,%esp
  801390:	85 c0                	test   %eax,%eax
  801392:	78 10                	js     8013a4 <readn+0x41>
			return m;
		if (m == 0)
  801394:	85 c0                	test   %eax,%eax
  801396:	74 0a                	je     8013a2 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801398:	01 c3                	add    %eax,%ebx
  80139a:	39 f3                	cmp    %esi,%ebx
  80139c:	72 db                	jb     801379 <readn+0x16>
  80139e:	89 d8                	mov    %ebx,%eax
  8013a0:	eb 02                	jmp    8013a4 <readn+0x41>
  8013a2:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8013a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013a7:	5b                   	pop    %ebx
  8013a8:	5e                   	pop    %esi
  8013a9:	5f                   	pop    %edi
  8013aa:	5d                   	pop    %ebp
  8013ab:	c3                   	ret    

008013ac <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8013ac:	55                   	push   %ebp
  8013ad:	89 e5                	mov    %esp,%ebp
  8013af:	53                   	push   %ebx
  8013b0:	83 ec 14             	sub    $0x14,%esp
  8013b3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013b6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013b9:	50                   	push   %eax
  8013ba:	53                   	push   %ebx
  8013bb:	e8 ac fc ff ff       	call   80106c <fd_lookup>
  8013c0:	83 c4 08             	add    $0x8,%esp
  8013c3:	89 c2                	mov    %eax,%edx
  8013c5:	85 c0                	test   %eax,%eax
  8013c7:	78 68                	js     801431 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013c9:	83 ec 08             	sub    $0x8,%esp
  8013cc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013cf:	50                   	push   %eax
  8013d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013d3:	ff 30                	pushl  (%eax)
  8013d5:	e8 e8 fc ff ff       	call   8010c2 <dev_lookup>
  8013da:	83 c4 10             	add    $0x10,%esp
  8013dd:	85 c0                	test   %eax,%eax
  8013df:	78 47                	js     801428 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013e4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013e8:	75 21                	jne    80140b <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8013ea:	a1 04 40 80 00       	mov    0x804004,%eax
  8013ef:	8b 40 48             	mov    0x48(%eax),%eax
  8013f2:	83 ec 04             	sub    $0x4,%esp
  8013f5:	53                   	push   %ebx
  8013f6:	50                   	push   %eax
  8013f7:	68 c9 25 80 00       	push   $0x8025c9
  8013fc:	e8 d3 ed ff ff       	call   8001d4 <cprintf>
		return -E_INVAL;
  801401:	83 c4 10             	add    $0x10,%esp
  801404:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801409:	eb 26                	jmp    801431 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80140b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80140e:	8b 52 0c             	mov    0xc(%edx),%edx
  801411:	85 d2                	test   %edx,%edx
  801413:	74 17                	je     80142c <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801415:	83 ec 04             	sub    $0x4,%esp
  801418:	ff 75 10             	pushl  0x10(%ebp)
  80141b:	ff 75 0c             	pushl  0xc(%ebp)
  80141e:	50                   	push   %eax
  80141f:	ff d2                	call   *%edx
  801421:	89 c2                	mov    %eax,%edx
  801423:	83 c4 10             	add    $0x10,%esp
  801426:	eb 09                	jmp    801431 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801428:	89 c2                	mov    %eax,%edx
  80142a:	eb 05                	jmp    801431 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80142c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801431:	89 d0                	mov    %edx,%eax
  801433:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801436:	c9                   	leave  
  801437:	c3                   	ret    

00801438 <seek>:

int
seek(int fdnum, off_t offset)
{
  801438:	55                   	push   %ebp
  801439:	89 e5                	mov    %esp,%ebp
  80143b:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80143e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801441:	50                   	push   %eax
  801442:	ff 75 08             	pushl  0x8(%ebp)
  801445:	e8 22 fc ff ff       	call   80106c <fd_lookup>
  80144a:	83 c4 08             	add    $0x8,%esp
  80144d:	85 c0                	test   %eax,%eax
  80144f:	78 0e                	js     80145f <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801451:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801454:	8b 55 0c             	mov    0xc(%ebp),%edx
  801457:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80145a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80145f:	c9                   	leave  
  801460:	c3                   	ret    

00801461 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801461:	55                   	push   %ebp
  801462:	89 e5                	mov    %esp,%ebp
  801464:	53                   	push   %ebx
  801465:	83 ec 14             	sub    $0x14,%esp
  801468:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80146b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80146e:	50                   	push   %eax
  80146f:	53                   	push   %ebx
  801470:	e8 f7 fb ff ff       	call   80106c <fd_lookup>
  801475:	83 c4 08             	add    $0x8,%esp
  801478:	89 c2                	mov    %eax,%edx
  80147a:	85 c0                	test   %eax,%eax
  80147c:	78 65                	js     8014e3 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80147e:	83 ec 08             	sub    $0x8,%esp
  801481:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801484:	50                   	push   %eax
  801485:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801488:	ff 30                	pushl  (%eax)
  80148a:	e8 33 fc ff ff       	call   8010c2 <dev_lookup>
  80148f:	83 c4 10             	add    $0x10,%esp
  801492:	85 c0                	test   %eax,%eax
  801494:	78 44                	js     8014da <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801496:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801499:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80149d:	75 21                	jne    8014c0 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80149f:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8014a4:	8b 40 48             	mov    0x48(%eax),%eax
  8014a7:	83 ec 04             	sub    $0x4,%esp
  8014aa:	53                   	push   %ebx
  8014ab:	50                   	push   %eax
  8014ac:	68 8c 25 80 00       	push   $0x80258c
  8014b1:	e8 1e ed ff ff       	call   8001d4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8014b6:	83 c4 10             	add    $0x10,%esp
  8014b9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014be:	eb 23                	jmp    8014e3 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8014c0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014c3:	8b 52 18             	mov    0x18(%edx),%edx
  8014c6:	85 d2                	test   %edx,%edx
  8014c8:	74 14                	je     8014de <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8014ca:	83 ec 08             	sub    $0x8,%esp
  8014cd:	ff 75 0c             	pushl  0xc(%ebp)
  8014d0:	50                   	push   %eax
  8014d1:	ff d2                	call   *%edx
  8014d3:	89 c2                	mov    %eax,%edx
  8014d5:	83 c4 10             	add    $0x10,%esp
  8014d8:	eb 09                	jmp    8014e3 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014da:	89 c2                	mov    %eax,%edx
  8014dc:	eb 05                	jmp    8014e3 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8014de:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8014e3:	89 d0                	mov    %edx,%eax
  8014e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014e8:	c9                   	leave  
  8014e9:	c3                   	ret    

008014ea <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8014ea:	55                   	push   %ebp
  8014eb:	89 e5                	mov    %esp,%ebp
  8014ed:	53                   	push   %ebx
  8014ee:	83 ec 14             	sub    $0x14,%esp
  8014f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014f4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014f7:	50                   	push   %eax
  8014f8:	ff 75 08             	pushl  0x8(%ebp)
  8014fb:	e8 6c fb ff ff       	call   80106c <fd_lookup>
  801500:	83 c4 08             	add    $0x8,%esp
  801503:	89 c2                	mov    %eax,%edx
  801505:	85 c0                	test   %eax,%eax
  801507:	78 58                	js     801561 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801509:	83 ec 08             	sub    $0x8,%esp
  80150c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80150f:	50                   	push   %eax
  801510:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801513:	ff 30                	pushl  (%eax)
  801515:	e8 a8 fb ff ff       	call   8010c2 <dev_lookup>
  80151a:	83 c4 10             	add    $0x10,%esp
  80151d:	85 c0                	test   %eax,%eax
  80151f:	78 37                	js     801558 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801521:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801524:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801528:	74 32                	je     80155c <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80152a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80152d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801534:	00 00 00 
	stat->st_isdir = 0;
  801537:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80153e:	00 00 00 
	stat->st_dev = dev;
  801541:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801547:	83 ec 08             	sub    $0x8,%esp
  80154a:	53                   	push   %ebx
  80154b:	ff 75 f0             	pushl  -0x10(%ebp)
  80154e:	ff 50 14             	call   *0x14(%eax)
  801551:	89 c2                	mov    %eax,%edx
  801553:	83 c4 10             	add    $0x10,%esp
  801556:	eb 09                	jmp    801561 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801558:	89 c2                	mov    %eax,%edx
  80155a:	eb 05                	jmp    801561 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80155c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801561:	89 d0                	mov    %edx,%eax
  801563:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801566:	c9                   	leave  
  801567:	c3                   	ret    

00801568 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801568:	55                   	push   %ebp
  801569:	89 e5                	mov    %esp,%ebp
  80156b:	56                   	push   %esi
  80156c:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80156d:	83 ec 08             	sub    $0x8,%esp
  801570:	6a 00                	push   $0x0
  801572:	ff 75 08             	pushl  0x8(%ebp)
  801575:	e8 0c 02 00 00       	call   801786 <open>
  80157a:	89 c3                	mov    %eax,%ebx
  80157c:	83 c4 10             	add    $0x10,%esp
  80157f:	85 c0                	test   %eax,%eax
  801581:	78 1b                	js     80159e <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801583:	83 ec 08             	sub    $0x8,%esp
  801586:	ff 75 0c             	pushl  0xc(%ebp)
  801589:	50                   	push   %eax
  80158a:	e8 5b ff ff ff       	call   8014ea <fstat>
  80158f:	89 c6                	mov    %eax,%esi
	close(fd);
  801591:	89 1c 24             	mov    %ebx,(%esp)
  801594:	e8 fd fb ff ff       	call   801196 <close>
	return r;
  801599:	83 c4 10             	add    $0x10,%esp
  80159c:	89 f0                	mov    %esi,%eax
}
  80159e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015a1:	5b                   	pop    %ebx
  8015a2:	5e                   	pop    %esi
  8015a3:	5d                   	pop    %ebp
  8015a4:	c3                   	ret    

008015a5 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8015a5:	55                   	push   %ebp
  8015a6:	89 e5                	mov    %esp,%ebp
  8015a8:	56                   	push   %esi
  8015a9:	53                   	push   %ebx
  8015aa:	89 c6                	mov    %eax,%esi
  8015ac:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8015ae:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8015b5:	75 12                	jne    8015c9 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8015b7:	83 ec 0c             	sub    $0xc,%esp
  8015ba:	6a 01                	push   $0x1
  8015bc:	e8 c1 08 00 00       	call   801e82 <ipc_find_env>
  8015c1:	a3 00 40 80 00       	mov    %eax,0x804000
  8015c6:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8015c9:	6a 07                	push   $0x7
  8015cb:	68 00 50 80 00       	push   $0x805000
  8015d0:	56                   	push   %esi
  8015d1:	ff 35 00 40 80 00    	pushl  0x804000
  8015d7:	e8 52 08 00 00       	call   801e2e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8015dc:	83 c4 0c             	add    $0xc,%esp
  8015df:	6a 00                	push   $0x0
  8015e1:	53                   	push   %ebx
  8015e2:	6a 00                	push   $0x0
  8015e4:	e8 dc 07 00 00       	call   801dc5 <ipc_recv>
}
  8015e9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015ec:	5b                   	pop    %ebx
  8015ed:	5e                   	pop    %esi
  8015ee:	5d                   	pop    %ebp
  8015ef:	c3                   	ret    

008015f0 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8015f0:	55                   	push   %ebp
  8015f1:	89 e5                	mov    %esp,%ebp
  8015f3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8015f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8015f9:	8b 40 0c             	mov    0xc(%eax),%eax
  8015fc:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801601:	8b 45 0c             	mov    0xc(%ebp),%eax
  801604:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801609:	ba 00 00 00 00       	mov    $0x0,%edx
  80160e:	b8 02 00 00 00       	mov    $0x2,%eax
  801613:	e8 8d ff ff ff       	call   8015a5 <fsipc>
}
  801618:	c9                   	leave  
  801619:	c3                   	ret    

0080161a <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80161a:	55                   	push   %ebp
  80161b:	89 e5                	mov    %esp,%ebp
  80161d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801620:	8b 45 08             	mov    0x8(%ebp),%eax
  801623:	8b 40 0c             	mov    0xc(%eax),%eax
  801626:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80162b:	ba 00 00 00 00       	mov    $0x0,%edx
  801630:	b8 06 00 00 00       	mov    $0x6,%eax
  801635:	e8 6b ff ff ff       	call   8015a5 <fsipc>
}
  80163a:	c9                   	leave  
  80163b:	c3                   	ret    

0080163c <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80163c:	55                   	push   %ebp
  80163d:	89 e5                	mov    %esp,%ebp
  80163f:	53                   	push   %ebx
  801640:	83 ec 04             	sub    $0x4,%esp
  801643:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801646:	8b 45 08             	mov    0x8(%ebp),%eax
  801649:	8b 40 0c             	mov    0xc(%eax),%eax
  80164c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801651:	ba 00 00 00 00       	mov    $0x0,%edx
  801656:	b8 05 00 00 00       	mov    $0x5,%eax
  80165b:	e8 45 ff ff ff       	call   8015a5 <fsipc>
  801660:	85 c0                	test   %eax,%eax
  801662:	78 2c                	js     801690 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801664:	83 ec 08             	sub    $0x8,%esp
  801667:	68 00 50 80 00       	push   $0x805000
  80166c:	53                   	push   %ebx
  80166d:	e8 e7 f0 ff ff       	call   800759 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801672:	a1 80 50 80 00       	mov    0x805080,%eax
  801677:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80167d:	a1 84 50 80 00       	mov    0x805084,%eax
  801682:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801688:	83 c4 10             	add    $0x10,%esp
  80168b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801690:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801693:	c9                   	leave  
  801694:	c3                   	ret    

00801695 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801695:	55                   	push   %ebp
  801696:	89 e5                	mov    %esp,%ebp
  801698:	53                   	push   %ebx
  801699:	83 ec 08             	sub    $0x8,%esp
  80169c:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80169f:	8b 55 08             	mov    0x8(%ebp),%edx
  8016a2:	8b 52 0c             	mov    0xc(%edx),%edx
  8016a5:	89 15 00 50 80 00    	mov    %edx,0x805000
  8016ab:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8016b0:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  8016b5:	0f 46 d8             	cmovbe %eax,%ebx
	
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  8016b8:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  8016be:	53                   	push   %ebx
  8016bf:	ff 75 0c             	pushl  0xc(%ebp)
  8016c2:	68 08 50 80 00       	push   $0x805008
  8016c7:	e8 1f f2 ff ff       	call   8008eb <memmove>

	
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) 
  8016cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8016d1:	b8 04 00 00 00       	mov    $0x4,%eax
  8016d6:	e8 ca fe ff ff       	call   8015a5 <fsipc>
  8016db:	83 c4 10             	add    $0x10,%esp
  8016de:	85 c0                	test   %eax,%eax
  8016e0:	78 1d                	js     8016ff <devfile_write+0x6a>
		return r;
	assert(r <= n_real); 
  8016e2:	39 d8                	cmp    %ebx,%eax
  8016e4:	76 19                	jbe    8016ff <devfile_write+0x6a>
  8016e6:	68 f8 25 80 00       	push   $0x8025f8
  8016eb:	68 04 26 80 00       	push   $0x802604
  8016f0:	68 a3 00 00 00       	push   $0xa3
  8016f5:	68 19 26 80 00       	push   $0x802619
  8016fa:	e8 0a 06 00 00       	call   801d09 <_panic>
	return r;
}
  8016ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801702:	c9                   	leave  
  801703:	c3                   	ret    

00801704 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801704:	55                   	push   %ebp
  801705:	89 e5                	mov    %esp,%ebp
  801707:	56                   	push   %esi
  801708:	53                   	push   %ebx
  801709:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80170c:	8b 45 08             	mov    0x8(%ebp),%eax
  80170f:	8b 40 0c             	mov    0xc(%eax),%eax
  801712:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801717:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80171d:	ba 00 00 00 00       	mov    $0x0,%edx
  801722:	b8 03 00 00 00       	mov    $0x3,%eax
  801727:	e8 79 fe ff ff       	call   8015a5 <fsipc>
  80172c:	89 c3                	mov    %eax,%ebx
  80172e:	85 c0                	test   %eax,%eax
  801730:	78 4b                	js     80177d <devfile_read+0x79>
		return r;
	assert(r <= n);
  801732:	39 c6                	cmp    %eax,%esi
  801734:	73 16                	jae    80174c <devfile_read+0x48>
  801736:	68 24 26 80 00       	push   $0x802624
  80173b:	68 04 26 80 00       	push   $0x802604
  801740:	6a 7c                	push   $0x7c
  801742:	68 19 26 80 00       	push   $0x802619
  801747:	e8 bd 05 00 00       	call   801d09 <_panic>
	assert(r <= PGSIZE);
  80174c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801751:	7e 16                	jle    801769 <devfile_read+0x65>
  801753:	68 2b 26 80 00       	push   $0x80262b
  801758:	68 04 26 80 00       	push   $0x802604
  80175d:	6a 7d                	push   $0x7d
  80175f:	68 19 26 80 00       	push   $0x802619
  801764:	e8 a0 05 00 00       	call   801d09 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801769:	83 ec 04             	sub    $0x4,%esp
  80176c:	50                   	push   %eax
  80176d:	68 00 50 80 00       	push   $0x805000
  801772:	ff 75 0c             	pushl  0xc(%ebp)
  801775:	e8 71 f1 ff ff       	call   8008eb <memmove>
	return r;
  80177a:	83 c4 10             	add    $0x10,%esp
}
  80177d:	89 d8                	mov    %ebx,%eax
  80177f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801782:	5b                   	pop    %ebx
  801783:	5e                   	pop    %esi
  801784:	5d                   	pop    %ebp
  801785:	c3                   	ret    

00801786 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801786:	55                   	push   %ebp
  801787:	89 e5                	mov    %esp,%ebp
  801789:	53                   	push   %ebx
  80178a:	83 ec 20             	sub    $0x20,%esp
  80178d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801790:	53                   	push   %ebx
  801791:	e8 8a ef ff ff       	call   800720 <strlen>
  801796:	83 c4 10             	add    $0x10,%esp
  801799:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80179e:	7f 67                	jg     801807 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017a0:	83 ec 0c             	sub    $0xc,%esp
  8017a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017a6:	50                   	push   %eax
  8017a7:	e8 71 f8 ff ff       	call   80101d <fd_alloc>
  8017ac:	83 c4 10             	add    $0x10,%esp
		return r;
  8017af:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017b1:	85 c0                	test   %eax,%eax
  8017b3:	78 57                	js     80180c <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8017b5:	83 ec 08             	sub    $0x8,%esp
  8017b8:	53                   	push   %ebx
  8017b9:	68 00 50 80 00       	push   $0x805000
  8017be:	e8 96 ef ff ff       	call   800759 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8017c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017c6:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8017cb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017ce:	b8 01 00 00 00       	mov    $0x1,%eax
  8017d3:	e8 cd fd ff ff       	call   8015a5 <fsipc>
  8017d8:	89 c3                	mov    %eax,%ebx
  8017da:	83 c4 10             	add    $0x10,%esp
  8017dd:	85 c0                	test   %eax,%eax
  8017df:	79 14                	jns    8017f5 <open+0x6f>
		fd_close(fd, 0);
  8017e1:	83 ec 08             	sub    $0x8,%esp
  8017e4:	6a 00                	push   $0x0
  8017e6:	ff 75 f4             	pushl  -0xc(%ebp)
  8017e9:	e8 27 f9 ff ff       	call   801115 <fd_close>
		return r;
  8017ee:	83 c4 10             	add    $0x10,%esp
  8017f1:	89 da                	mov    %ebx,%edx
  8017f3:	eb 17                	jmp    80180c <open+0x86>
	}

	return fd2num(fd);
  8017f5:	83 ec 0c             	sub    $0xc,%esp
  8017f8:	ff 75 f4             	pushl  -0xc(%ebp)
  8017fb:	e8 f6 f7 ff ff       	call   800ff6 <fd2num>
  801800:	89 c2                	mov    %eax,%edx
  801802:	83 c4 10             	add    $0x10,%esp
  801805:	eb 05                	jmp    80180c <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801807:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80180c:	89 d0                	mov    %edx,%eax
  80180e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801811:	c9                   	leave  
  801812:	c3                   	ret    

00801813 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801813:	55                   	push   %ebp
  801814:	89 e5                	mov    %esp,%ebp
  801816:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801819:	ba 00 00 00 00       	mov    $0x0,%edx
  80181e:	b8 08 00 00 00       	mov    $0x8,%eax
  801823:	e8 7d fd ff ff       	call   8015a5 <fsipc>
}
  801828:	c9                   	leave  
  801829:	c3                   	ret    

0080182a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80182a:	55                   	push   %ebp
  80182b:	89 e5                	mov    %esp,%ebp
  80182d:	56                   	push   %esi
  80182e:	53                   	push   %ebx
  80182f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801832:	83 ec 0c             	sub    $0xc,%esp
  801835:	ff 75 08             	pushl  0x8(%ebp)
  801838:	e8 c9 f7 ff ff       	call   801006 <fd2data>
  80183d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80183f:	83 c4 08             	add    $0x8,%esp
  801842:	68 37 26 80 00       	push   $0x802637
  801847:	53                   	push   %ebx
  801848:	e8 0c ef ff ff       	call   800759 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80184d:	8b 46 04             	mov    0x4(%esi),%eax
  801850:	2b 06                	sub    (%esi),%eax
  801852:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801858:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80185f:	00 00 00 
	stat->st_dev = &devpipe;
  801862:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801869:	30 80 00 
	return 0;
}
  80186c:	b8 00 00 00 00       	mov    $0x0,%eax
  801871:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801874:	5b                   	pop    %ebx
  801875:	5e                   	pop    %esi
  801876:	5d                   	pop    %ebp
  801877:	c3                   	ret    

00801878 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801878:	55                   	push   %ebp
  801879:	89 e5                	mov    %esp,%ebp
  80187b:	53                   	push   %ebx
  80187c:	83 ec 0c             	sub    $0xc,%esp
  80187f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801882:	53                   	push   %ebx
  801883:	6a 00                	push   $0x0
  801885:	e8 57 f3 ff ff       	call   800be1 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80188a:	89 1c 24             	mov    %ebx,(%esp)
  80188d:	e8 74 f7 ff ff       	call   801006 <fd2data>
  801892:	83 c4 08             	add    $0x8,%esp
  801895:	50                   	push   %eax
  801896:	6a 00                	push   $0x0
  801898:	e8 44 f3 ff ff       	call   800be1 <sys_page_unmap>
}
  80189d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018a0:	c9                   	leave  
  8018a1:	c3                   	ret    

008018a2 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8018a2:	55                   	push   %ebp
  8018a3:	89 e5                	mov    %esp,%ebp
  8018a5:	57                   	push   %edi
  8018a6:	56                   	push   %esi
  8018a7:	53                   	push   %ebx
  8018a8:	83 ec 1c             	sub    $0x1c,%esp
  8018ab:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018ae:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8018b0:	a1 04 40 80 00       	mov    0x804004,%eax
  8018b5:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8018b8:	83 ec 0c             	sub    $0xc,%esp
  8018bb:	ff 75 e0             	pushl  -0x20(%ebp)
  8018be:	e8 f8 05 00 00       	call   801ebb <pageref>
  8018c3:	89 c3                	mov    %eax,%ebx
  8018c5:	89 3c 24             	mov    %edi,(%esp)
  8018c8:	e8 ee 05 00 00       	call   801ebb <pageref>
  8018cd:	83 c4 10             	add    $0x10,%esp
  8018d0:	39 c3                	cmp    %eax,%ebx
  8018d2:	0f 94 c1             	sete   %cl
  8018d5:	0f b6 c9             	movzbl %cl,%ecx
  8018d8:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8018db:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8018e1:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8018e4:	39 ce                	cmp    %ecx,%esi
  8018e6:	74 1b                	je     801903 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8018e8:	39 c3                	cmp    %eax,%ebx
  8018ea:	75 c4                	jne    8018b0 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8018ec:	8b 42 58             	mov    0x58(%edx),%eax
  8018ef:	ff 75 e4             	pushl  -0x1c(%ebp)
  8018f2:	50                   	push   %eax
  8018f3:	56                   	push   %esi
  8018f4:	68 3e 26 80 00       	push   $0x80263e
  8018f9:	e8 d6 e8 ff ff       	call   8001d4 <cprintf>
  8018fe:	83 c4 10             	add    $0x10,%esp
  801901:	eb ad                	jmp    8018b0 <_pipeisclosed+0xe>
	}
}
  801903:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801906:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801909:	5b                   	pop    %ebx
  80190a:	5e                   	pop    %esi
  80190b:	5f                   	pop    %edi
  80190c:	5d                   	pop    %ebp
  80190d:	c3                   	ret    

0080190e <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80190e:	55                   	push   %ebp
  80190f:	89 e5                	mov    %esp,%ebp
  801911:	57                   	push   %edi
  801912:	56                   	push   %esi
  801913:	53                   	push   %ebx
  801914:	83 ec 28             	sub    $0x28,%esp
  801917:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80191a:	56                   	push   %esi
  80191b:	e8 e6 f6 ff ff       	call   801006 <fd2data>
  801920:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801922:	83 c4 10             	add    $0x10,%esp
  801925:	bf 00 00 00 00       	mov    $0x0,%edi
  80192a:	eb 4b                	jmp    801977 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80192c:	89 da                	mov    %ebx,%edx
  80192e:	89 f0                	mov    %esi,%eax
  801930:	e8 6d ff ff ff       	call   8018a2 <_pipeisclosed>
  801935:	85 c0                	test   %eax,%eax
  801937:	75 48                	jne    801981 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801939:	e8 ff f1 ff ff       	call   800b3d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80193e:	8b 43 04             	mov    0x4(%ebx),%eax
  801941:	8b 0b                	mov    (%ebx),%ecx
  801943:	8d 51 20             	lea    0x20(%ecx),%edx
  801946:	39 d0                	cmp    %edx,%eax
  801948:	73 e2                	jae    80192c <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80194a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80194d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801951:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801954:	89 c2                	mov    %eax,%edx
  801956:	c1 fa 1f             	sar    $0x1f,%edx
  801959:	89 d1                	mov    %edx,%ecx
  80195b:	c1 e9 1b             	shr    $0x1b,%ecx
  80195e:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801961:	83 e2 1f             	and    $0x1f,%edx
  801964:	29 ca                	sub    %ecx,%edx
  801966:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80196a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80196e:	83 c0 01             	add    $0x1,%eax
  801971:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801974:	83 c7 01             	add    $0x1,%edi
  801977:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80197a:	75 c2                	jne    80193e <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80197c:	8b 45 10             	mov    0x10(%ebp),%eax
  80197f:	eb 05                	jmp    801986 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801981:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801986:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801989:	5b                   	pop    %ebx
  80198a:	5e                   	pop    %esi
  80198b:	5f                   	pop    %edi
  80198c:	5d                   	pop    %ebp
  80198d:	c3                   	ret    

0080198e <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80198e:	55                   	push   %ebp
  80198f:	89 e5                	mov    %esp,%ebp
  801991:	57                   	push   %edi
  801992:	56                   	push   %esi
  801993:	53                   	push   %ebx
  801994:	83 ec 18             	sub    $0x18,%esp
  801997:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80199a:	57                   	push   %edi
  80199b:	e8 66 f6 ff ff       	call   801006 <fd2data>
  8019a0:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019a2:	83 c4 10             	add    $0x10,%esp
  8019a5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019aa:	eb 3d                	jmp    8019e9 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8019ac:	85 db                	test   %ebx,%ebx
  8019ae:	74 04                	je     8019b4 <devpipe_read+0x26>
				return i;
  8019b0:	89 d8                	mov    %ebx,%eax
  8019b2:	eb 44                	jmp    8019f8 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8019b4:	89 f2                	mov    %esi,%edx
  8019b6:	89 f8                	mov    %edi,%eax
  8019b8:	e8 e5 fe ff ff       	call   8018a2 <_pipeisclosed>
  8019bd:	85 c0                	test   %eax,%eax
  8019bf:	75 32                	jne    8019f3 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8019c1:	e8 77 f1 ff ff       	call   800b3d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8019c6:	8b 06                	mov    (%esi),%eax
  8019c8:	3b 46 04             	cmp    0x4(%esi),%eax
  8019cb:	74 df                	je     8019ac <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8019cd:	99                   	cltd   
  8019ce:	c1 ea 1b             	shr    $0x1b,%edx
  8019d1:	01 d0                	add    %edx,%eax
  8019d3:	83 e0 1f             	and    $0x1f,%eax
  8019d6:	29 d0                	sub    %edx,%eax
  8019d8:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8019dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019e0:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8019e3:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019e6:	83 c3 01             	add    $0x1,%ebx
  8019e9:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8019ec:	75 d8                	jne    8019c6 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8019ee:	8b 45 10             	mov    0x10(%ebp),%eax
  8019f1:	eb 05                	jmp    8019f8 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019f3:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8019f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019fb:	5b                   	pop    %ebx
  8019fc:	5e                   	pop    %esi
  8019fd:	5f                   	pop    %edi
  8019fe:	5d                   	pop    %ebp
  8019ff:	c3                   	ret    

00801a00 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801a00:	55                   	push   %ebp
  801a01:	89 e5                	mov    %esp,%ebp
  801a03:	56                   	push   %esi
  801a04:	53                   	push   %ebx
  801a05:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a08:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a0b:	50                   	push   %eax
  801a0c:	e8 0c f6 ff ff       	call   80101d <fd_alloc>
  801a11:	83 c4 10             	add    $0x10,%esp
  801a14:	89 c2                	mov    %eax,%edx
  801a16:	85 c0                	test   %eax,%eax
  801a18:	0f 88 2c 01 00 00    	js     801b4a <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a1e:	83 ec 04             	sub    $0x4,%esp
  801a21:	68 07 04 00 00       	push   $0x407
  801a26:	ff 75 f4             	pushl  -0xc(%ebp)
  801a29:	6a 00                	push   $0x0
  801a2b:	e8 2c f1 ff ff       	call   800b5c <sys_page_alloc>
  801a30:	83 c4 10             	add    $0x10,%esp
  801a33:	89 c2                	mov    %eax,%edx
  801a35:	85 c0                	test   %eax,%eax
  801a37:	0f 88 0d 01 00 00    	js     801b4a <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801a3d:	83 ec 0c             	sub    $0xc,%esp
  801a40:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a43:	50                   	push   %eax
  801a44:	e8 d4 f5 ff ff       	call   80101d <fd_alloc>
  801a49:	89 c3                	mov    %eax,%ebx
  801a4b:	83 c4 10             	add    $0x10,%esp
  801a4e:	85 c0                	test   %eax,%eax
  801a50:	0f 88 e2 00 00 00    	js     801b38 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a56:	83 ec 04             	sub    $0x4,%esp
  801a59:	68 07 04 00 00       	push   $0x407
  801a5e:	ff 75 f0             	pushl  -0x10(%ebp)
  801a61:	6a 00                	push   $0x0
  801a63:	e8 f4 f0 ff ff       	call   800b5c <sys_page_alloc>
  801a68:	89 c3                	mov    %eax,%ebx
  801a6a:	83 c4 10             	add    $0x10,%esp
  801a6d:	85 c0                	test   %eax,%eax
  801a6f:	0f 88 c3 00 00 00    	js     801b38 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801a75:	83 ec 0c             	sub    $0xc,%esp
  801a78:	ff 75 f4             	pushl  -0xc(%ebp)
  801a7b:	e8 86 f5 ff ff       	call   801006 <fd2data>
  801a80:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a82:	83 c4 0c             	add    $0xc,%esp
  801a85:	68 07 04 00 00       	push   $0x407
  801a8a:	50                   	push   %eax
  801a8b:	6a 00                	push   $0x0
  801a8d:	e8 ca f0 ff ff       	call   800b5c <sys_page_alloc>
  801a92:	89 c3                	mov    %eax,%ebx
  801a94:	83 c4 10             	add    $0x10,%esp
  801a97:	85 c0                	test   %eax,%eax
  801a99:	0f 88 89 00 00 00    	js     801b28 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a9f:	83 ec 0c             	sub    $0xc,%esp
  801aa2:	ff 75 f0             	pushl  -0x10(%ebp)
  801aa5:	e8 5c f5 ff ff       	call   801006 <fd2data>
  801aaa:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ab1:	50                   	push   %eax
  801ab2:	6a 00                	push   $0x0
  801ab4:	56                   	push   %esi
  801ab5:	6a 00                	push   $0x0
  801ab7:	e8 e3 f0 ff ff       	call   800b9f <sys_page_map>
  801abc:	89 c3                	mov    %eax,%ebx
  801abe:	83 c4 20             	add    $0x20,%esp
  801ac1:	85 c0                	test   %eax,%eax
  801ac3:	78 55                	js     801b1a <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801ac5:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801acb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ace:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ad0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ad3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801ada:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ae0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ae3:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ae5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ae8:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801aef:	83 ec 0c             	sub    $0xc,%esp
  801af2:	ff 75 f4             	pushl  -0xc(%ebp)
  801af5:	e8 fc f4 ff ff       	call   800ff6 <fd2num>
  801afa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801afd:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801aff:	83 c4 04             	add    $0x4,%esp
  801b02:	ff 75 f0             	pushl  -0x10(%ebp)
  801b05:	e8 ec f4 ff ff       	call   800ff6 <fd2num>
  801b0a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b0d:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801b10:	83 c4 10             	add    $0x10,%esp
  801b13:	ba 00 00 00 00       	mov    $0x0,%edx
  801b18:	eb 30                	jmp    801b4a <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801b1a:	83 ec 08             	sub    $0x8,%esp
  801b1d:	56                   	push   %esi
  801b1e:	6a 00                	push   $0x0
  801b20:	e8 bc f0 ff ff       	call   800be1 <sys_page_unmap>
  801b25:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801b28:	83 ec 08             	sub    $0x8,%esp
  801b2b:	ff 75 f0             	pushl  -0x10(%ebp)
  801b2e:	6a 00                	push   $0x0
  801b30:	e8 ac f0 ff ff       	call   800be1 <sys_page_unmap>
  801b35:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801b38:	83 ec 08             	sub    $0x8,%esp
  801b3b:	ff 75 f4             	pushl  -0xc(%ebp)
  801b3e:	6a 00                	push   $0x0
  801b40:	e8 9c f0 ff ff       	call   800be1 <sys_page_unmap>
  801b45:	83 c4 10             	add    $0x10,%esp
  801b48:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801b4a:	89 d0                	mov    %edx,%eax
  801b4c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b4f:	5b                   	pop    %ebx
  801b50:	5e                   	pop    %esi
  801b51:	5d                   	pop    %ebp
  801b52:	c3                   	ret    

00801b53 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801b53:	55                   	push   %ebp
  801b54:	89 e5                	mov    %esp,%ebp
  801b56:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b59:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b5c:	50                   	push   %eax
  801b5d:	ff 75 08             	pushl  0x8(%ebp)
  801b60:	e8 07 f5 ff ff       	call   80106c <fd_lookup>
  801b65:	83 c4 10             	add    $0x10,%esp
  801b68:	85 c0                	test   %eax,%eax
  801b6a:	78 18                	js     801b84 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801b6c:	83 ec 0c             	sub    $0xc,%esp
  801b6f:	ff 75 f4             	pushl  -0xc(%ebp)
  801b72:	e8 8f f4 ff ff       	call   801006 <fd2data>
	return _pipeisclosed(fd, p);
  801b77:	89 c2                	mov    %eax,%edx
  801b79:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b7c:	e8 21 fd ff ff       	call   8018a2 <_pipeisclosed>
  801b81:	83 c4 10             	add    $0x10,%esp
}
  801b84:	c9                   	leave  
  801b85:	c3                   	ret    

00801b86 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801b86:	55                   	push   %ebp
  801b87:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801b89:	b8 00 00 00 00       	mov    $0x0,%eax
  801b8e:	5d                   	pop    %ebp
  801b8f:	c3                   	ret    

00801b90 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801b90:	55                   	push   %ebp
  801b91:	89 e5                	mov    %esp,%ebp
  801b93:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801b96:	68 56 26 80 00       	push   $0x802656
  801b9b:	ff 75 0c             	pushl  0xc(%ebp)
  801b9e:	e8 b6 eb ff ff       	call   800759 <strcpy>
	return 0;
}
  801ba3:	b8 00 00 00 00       	mov    $0x0,%eax
  801ba8:	c9                   	leave  
  801ba9:	c3                   	ret    

00801baa <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801baa:	55                   	push   %ebp
  801bab:	89 e5                	mov    %esp,%ebp
  801bad:	57                   	push   %edi
  801bae:	56                   	push   %esi
  801baf:	53                   	push   %ebx
  801bb0:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bb6:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801bbb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bc1:	eb 2d                	jmp    801bf0 <devcons_write+0x46>
		m = n - tot;
  801bc3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801bc6:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801bc8:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801bcb:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801bd0:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801bd3:	83 ec 04             	sub    $0x4,%esp
  801bd6:	53                   	push   %ebx
  801bd7:	03 45 0c             	add    0xc(%ebp),%eax
  801bda:	50                   	push   %eax
  801bdb:	57                   	push   %edi
  801bdc:	e8 0a ed ff ff       	call   8008eb <memmove>
		sys_cputs(buf, m);
  801be1:	83 c4 08             	add    $0x8,%esp
  801be4:	53                   	push   %ebx
  801be5:	57                   	push   %edi
  801be6:	e8 b5 ee ff ff       	call   800aa0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801beb:	01 de                	add    %ebx,%esi
  801bed:	83 c4 10             	add    $0x10,%esp
  801bf0:	89 f0                	mov    %esi,%eax
  801bf2:	3b 75 10             	cmp    0x10(%ebp),%esi
  801bf5:	72 cc                	jb     801bc3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801bf7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bfa:	5b                   	pop    %ebx
  801bfb:	5e                   	pop    %esi
  801bfc:	5f                   	pop    %edi
  801bfd:	5d                   	pop    %ebp
  801bfe:	c3                   	ret    

00801bff <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801bff:	55                   	push   %ebp
  801c00:	89 e5                	mov    %esp,%ebp
  801c02:	83 ec 08             	sub    $0x8,%esp
  801c05:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801c0a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c0e:	74 2a                	je     801c3a <devcons_read+0x3b>
  801c10:	eb 05                	jmp    801c17 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801c12:	e8 26 ef ff ff       	call   800b3d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801c17:	e8 a2 ee ff ff       	call   800abe <sys_cgetc>
  801c1c:	85 c0                	test   %eax,%eax
  801c1e:	74 f2                	je     801c12 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801c20:	85 c0                	test   %eax,%eax
  801c22:	78 16                	js     801c3a <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801c24:	83 f8 04             	cmp    $0x4,%eax
  801c27:	74 0c                	je     801c35 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801c29:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c2c:	88 02                	mov    %al,(%edx)
	return 1;
  801c2e:	b8 01 00 00 00       	mov    $0x1,%eax
  801c33:	eb 05                	jmp    801c3a <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801c35:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801c3a:	c9                   	leave  
  801c3b:	c3                   	ret    

00801c3c <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801c3c:	55                   	push   %ebp
  801c3d:	89 e5                	mov    %esp,%ebp
  801c3f:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801c42:	8b 45 08             	mov    0x8(%ebp),%eax
  801c45:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801c48:	6a 01                	push   $0x1
  801c4a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c4d:	50                   	push   %eax
  801c4e:	e8 4d ee ff ff       	call   800aa0 <sys_cputs>
}
  801c53:	83 c4 10             	add    $0x10,%esp
  801c56:	c9                   	leave  
  801c57:	c3                   	ret    

00801c58 <getchar>:

int
getchar(void)
{
  801c58:	55                   	push   %ebp
  801c59:	89 e5                	mov    %esp,%ebp
  801c5b:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801c5e:	6a 01                	push   $0x1
  801c60:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c63:	50                   	push   %eax
  801c64:	6a 00                	push   $0x0
  801c66:	e8 67 f6 ff ff       	call   8012d2 <read>
	if (r < 0)
  801c6b:	83 c4 10             	add    $0x10,%esp
  801c6e:	85 c0                	test   %eax,%eax
  801c70:	78 0f                	js     801c81 <getchar+0x29>
		return r;
	if (r < 1)
  801c72:	85 c0                	test   %eax,%eax
  801c74:	7e 06                	jle    801c7c <getchar+0x24>
		return -E_EOF;
	return c;
  801c76:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801c7a:	eb 05                	jmp    801c81 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801c7c:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801c81:	c9                   	leave  
  801c82:	c3                   	ret    

00801c83 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801c83:	55                   	push   %ebp
  801c84:	89 e5                	mov    %esp,%ebp
  801c86:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c89:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c8c:	50                   	push   %eax
  801c8d:	ff 75 08             	pushl  0x8(%ebp)
  801c90:	e8 d7 f3 ff ff       	call   80106c <fd_lookup>
  801c95:	83 c4 10             	add    $0x10,%esp
  801c98:	85 c0                	test   %eax,%eax
  801c9a:	78 11                	js     801cad <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801c9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c9f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ca5:	39 10                	cmp    %edx,(%eax)
  801ca7:	0f 94 c0             	sete   %al
  801caa:	0f b6 c0             	movzbl %al,%eax
}
  801cad:	c9                   	leave  
  801cae:	c3                   	ret    

00801caf <opencons>:

int
opencons(void)
{
  801caf:	55                   	push   %ebp
  801cb0:	89 e5                	mov    %esp,%ebp
  801cb2:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801cb5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cb8:	50                   	push   %eax
  801cb9:	e8 5f f3 ff ff       	call   80101d <fd_alloc>
  801cbe:	83 c4 10             	add    $0x10,%esp
		return r;
  801cc1:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801cc3:	85 c0                	test   %eax,%eax
  801cc5:	78 3e                	js     801d05 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801cc7:	83 ec 04             	sub    $0x4,%esp
  801cca:	68 07 04 00 00       	push   $0x407
  801ccf:	ff 75 f4             	pushl  -0xc(%ebp)
  801cd2:	6a 00                	push   $0x0
  801cd4:	e8 83 ee ff ff       	call   800b5c <sys_page_alloc>
  801cd9:	83 c4 10             	add    $0x10,%esp
		return r;
  801cdc:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801cde:	85 c0                	test   %eax,%eax
  801ce0:	78 23                	js     801d05 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ce2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ce8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ceb:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ced:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cf0:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801cf7:	83 ec 0c             	sub    $0xc,%esp
  801cfa:	50                   	push   %eax
  801cfb:	e8 f6 f2 ff ff       	call   800ff6 <fd2num>
  801d00:	89 c2                	mov    %eax,%edx
  801d02:	83 c4 10             	add    $0x10,%esp
}
  801d05:	89 d0                	mov    %edx,%eax
  801d07:	c9                   	leave  
  801d08:	c3                   	ret    

00801d09 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801d09:	55                   	push   %ebp
  801d0a:	89 e5                	mov    %esp,%ebp
  801d0c:	56                   	push   %esi
  801d0d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801d0e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801d11:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801d17:	e8 02 ee ff ff       	call   800b1e <sys_getenvid>
  801d1c:	83 ec 0c             	sub    $0xc,%esp
  801d1f:	ff 75 0c             	pushl  0xc(%ebp)
  801d22:	ff 75 08             	pushl  0x8(%ebp)
  801d25:	56                   	push   %esi
  801d26:	50                   	push   %eax
  801d27:	68 64 26 80 00       	push   $0x802664
  801d2c:	e8 a3 e4 ff ff       	call   8001d4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801d31:	83 c4 18             	add    $0x18,%esp
  801d34:	53                   	push   %ebx
  801d35:	ff 75 10             	pushl  0x10(%ebp)
  801d38:	e8 46 e4 ff ff       	call   800183 <vcprintf>
	cprintf("\n");
  801d3d:	c7 04 24 af 21 80 00 	movl   $0x8021af,(%esp)
  801d44:	e8 8b e4 ff ff       	call   8001d4 <cprintf>
  801d49:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801d4c:	cc                   	int3   
  801d4d:	eb fd                	jmp    801d4c <_panic+0x43>

00801d4f <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801d4f:	55                   	push   %ebp
  801d50:	89 e5                	mov    %esp,%ebp
  801d52:	53                   	push   %ebx
  801d53:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  801d56:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801d5d:	75 28                	jne    801d87 <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  801d5f:	e8 ba ed ff ff       	call   800b1e <sys_getenvid>
  801d64:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_U | PTE_W);
  801d66:	83 ec 04             	sub    $0x4,%esp
  801d69:	6a 06                	push   $0x6
  801d6b:	68 00 f0 bf ee       	push   $0xeebff000
  801d70:	50                   	push   %eax
  801d71:	e8 e6 ed ff ff       	call   800b5c <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  801d76:	83 c4 08             	add    $0x8,%esp
  801d79:	68 94 1d 80 00       	push   $0x801d94
  801d7e:	53                   	push   %ebx
  801d7f:	e8 23 ef ff ff       	call   800ca7 <sys_env_set_pgfault_upcall>
  801d84:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801d87:	8b 45 08             	mov    0x8(%ebp),%eax
  801d8a:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801d8f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d92:	c9                   	leave  
  801d93:	c3                   	ret    

00801d94 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801d94:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801d95:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801d9a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801d9c:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	# My method is different. Copy the values to the other stack
	# in a convinient way, and then pop everything.
	movl %esp, %ebp		# ebp refers to the exception stack
  801d9f:	89 e5                	mov    %esp,%ebp
	movl 48(%ebp), %esp 	# go to other stack
  801da1:	8b 65 30             	mov    0x30(%ebp),%esp

	pushl 40(%ebp)		# eip - ORDER SWITCHED WITH EFLAGS
  801da4:	ff 75 28             	pushl  0x28(%ebp)
	pushl 44(%ebp)      	# eflags
  801da7:	ff 75 2c             	pushl  0x2c(%ebp)
	pushl 36(%ebp)		# all the 8 remaining regs
  801daa:	ff 75 24             	pushl  0x24(%ebp)
	pushl 32(%ebp)
  801dad:	ff 75 20             	pushl  0x20(%ebp)
	pushl 28(%ebp)
  801db0:	ff 75 1c             	pushl  0x1c(%ebp)
	pushl 24(%ebp)
  801db3:	ff 75 18             	pushl  0x18(%ebp)
	pushl 20(%ebp)
  801db6:	ff 75 14             	pushl  0x14(%ebp)
	pushl 16(%ebp)
  801db9:	ff 75 10             	pushl  0x10(%ebp)
	pushl 12(%ebp)
  801dbc:	ff 75 0c             	pushl  0xc(%ebp)
	pushl 8(%ebp)
  801dbf:	ff 75 08             	pushl  0x8(%ebp)

	popal			# now just pop everything!
  801dc2:	61                   	popa   
	popfl
  801dc3:	9d                   	popf   
	ret
  801dc4:	c3                   	ret    

00801dc5 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801dc5:	55                   	push   %ebp
  801dc6:	89 e5                	mov    %esp,%ebp
  801dc8:	56                   	push   %esi
  801dc9:	53                   	push   %ebx
  801dca:	8b 75 08             	mov    0x8(%ebp),%esi
  801dcd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dd0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  801dd3:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801dd5:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801dda:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  801ddd:	83 ec 0c             	sub    $0xc,%esp
  801de0:	50                   	push   %eax
  801de1:	e8 26 ef ff ff       	call   800d0c <sys_ipc_recv>

	if (r < 0) {
  801de6:	83 c4 10             	add    $0x10,%esp
  801de9:	85 c0                	test   %eax,%eax
  801deb:	79 16                	jns    801e03 <ipc_recv+0x3e>
		if (from_env_store)
  801ded:	85 f6                	test   %esi,%esi
  801def:	74 06                	je     801df7 <ipc_recv+0x32>
			*from_env_store = 0;
  801df1:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  801df7:	85 db                	test   %ebx,%ebx
  801df9:	74 2c                	je     801e27 <ipc_recv+0x62>
			*perm_store = 0;
  801dfb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801e01:	eb 24                	jmp    801e27 <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  801e03:	85 f6                	test   %esi,%esi
  801e05:	74 0a                	je     801e11 <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  801e07:	a1 04 40 80 00       	mov    0x804004,%eax
  801e0c:	8b 40 74             	mov    0x74(%eax),%eax
  801e0f:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  801e11:	85 db                	test   %ebx,%ebx
  801e13:	74 0a                	je     801e1f <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  801e15:	a1 04 40 80 00       	mov    0x804004,%eax
  801e1a:	8b 40 78             	mov    0x78(%eax),%eax
  801e1d:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  801e1f:	a1 04 40 80 00       	mov    0x804004,%eax
  801e24:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  801e27:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e2a:	5b                   	pop    %ebx
  801e2b:	5e                   	pop    %esi
  801e2c:	5d                   	pop    %ebp
  801e2d:	c3                   	ret    

00801e2e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e2e:	55                   	push   %ebp
  801e2f:	89 e5                	mov    %esp,%ebp
  801e31:	57                   	push   %edi
  801e32:	56                   	push   %esi
  801e33:	53                   	push   %ebx
  801e34:	83 ec 0c             	sub    $0xc,%esp
  801e37:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e3a:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e3d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  801e40:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801e42:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801e47:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  801e4a:	ff 75 14             	pushl  0x14(%ebp)
  801e4d:	53                   	push   %ebx
  801e4e:	56                   	push   %esi
  801e4f:	57                   	push   %edi
  801e50:	e8 94 ee ff ff       	call   800ce9 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  801e55:	83 c4 10             	add    $0x10,%esp
  801e58:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e5b:	75 07                	jne    801e64 <ipc_send+0x36>
			sys_yield();
  801e5d:	e8 db ec ff ff       	call   800b3d <sys_yield>
  801e62:	eb e6                	jmp    801e4a <ipc_send+0x1c>
		} else if (r < 0) {
  801e64:	85 c0                	test   %eax,%eax
  801e66:	79 12                	jns    801e7a <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  801e68:	50                   	push   %eax
  801e69:	68 88 26 80 00       	push   $0x802688
  801e6e:	6a 51                	push   $0x51
  801e70:	68 95 26 80 00       	push   $0x802695
  801e75:	e8 8f fe ff ff       	call   801d09 <_panic>
		}
	}
}
  801e7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e7d:	5b                   	pop    %ebx
  801e7e:	5e                   	pop    %esi
  801e7f:	5f                   	pop    %edi
  801e80:	5d                   	pop    %ebp
  801e81:	c3                   	ret    

00801e82 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801e82:	55                   	push   %ebp
  801e83:	89 e5                	mov    %esp,%ebp
  801e85:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801e88:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801e8d:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801e90:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801e96:	8b 52 50             	mov    0x50(%edx),%edx
  801e99:	39 ca                	cmp    %ecx,%edx
  801e9b:	75 0d                	jne    801eaa <ipc_find_env+0x28>
			return envs[i].env_id;
  801e9d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ea0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801ea5:	8b 40 48             	mov    0x48(%eax),%eax
  801ea8:	eb 0f                	jmp    801eb9 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801eaa:	83 c0 01             	add    $0x1,%eax
  801ead:	3d 00 04 00 00       	cmp    $0x400,%eax
  801eb2:	75 d9                	jne    801e8d <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801eb4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801eb9:	5d                   	pop    %ebp
  801eba:	c3                   	ret    

00801ebb <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ebb:	55                   	push   %ebp
  801ebc:	89 e5                	mov    %esp,%ebp
  801ebe:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ec1:	89 d0                	mov    %edx,%eax
  801ec3:	c1 e8 16             	shr    $0x16,%eax
  801ec6:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801ecd:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ed2:	f6 c1 01             	test   $0x1,%cl
  801ed5:	74 1d                	je     801ef4 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801ed7:	c1 ea 0c             	shr    $0xc,%edx
  801eda:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801ee1:	f6 c2 01             	test   $0x1,%dl
  801ee4:	74 0e                	je     801ef4 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ee6:	c1 ea 0c             	shr    $0xc,%edx
  801ee9:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801ef0:	ef 
  801ef1:	0f b7 c0             	movzwl %ax,%eax
}
  801ef4:	5d                   	pop    %ebp
  801ef5:	c3                   	ret    
  801ef6:	66 90                	xchg   %ax,%ax
  801ef8:	66 90                	xchg   %ax,%ax
  801efa:	66 90                	xchg   %ax,%ax
  801efc:	66 90                	xchg   %ax,%ax
  801efe:	66 90                	xchg   %ax,%ax

00801f00 <__udivdi3>:
  801f00:	55                   	push   %ebp
  801f01:	57                   	push   %edi
  801f02:	56                   	push   %esi
  801f03:	53                   	push   %ebx
  801f04:	83 ec 1c             	sub    $0x1c,%esp
  801f07:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801f0b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801f0f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801f13:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f17:	85 f6                	test   %esi,%esi
  801f19:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f1d:	89 ca                	mov    %ecx,%edx
  801f1f:	89 f8                	mov    %edi,%eax
  801f21:	75 3d                	jne    801f60 <__udivdi3+0x60>
  801f23:	39 cf                	cmp    %ecx,%edi
  801f25:	0f 87 c5 00 00 00    	ja     801ff0 <__udivdi3+0xf0>
  801f2b:	85 ff                	test   %edi,%edi
  801f2d:	89 fd                	mov    %edi,%ebp
  801f2f:	75 0b                	jne    801f3c <__udivdi3+0x3c>
  801f31:	b8 01 00 00 00       	mov    $0x1,%eax
  801f36:	31 d2                	xor    %edx,%edx
  801f38:	f7 f7                	div    %edi
  801f3a:	89 c5                	mov    %eax,%ebp
  801f3c:	89 c8                	mov    %ecx,%eax
  801f3e:	31 d2                	xor    %edx,%edx
  801f40:	f7 f5                	div    %ebp
  801f42:	89 c1                	mov    %eax,%ecx
  801f44:	89 d8                	mov    %ebx,%eax
  801f46:	89 cf                	mov    %ecx,%edi
  801f48:	f7 f5                	div    %ebp
  801f4a:	89 c3                	mov    %eax,%ebx
  801f4c:	89 d8                	mov    %ebx,%eax
  801f4e:	89 fa                	mov    %edi,%edx
  801f50:	83 c4 1c             	add    $0x1c,%esp
  801f53:	5b                   	pop    %ebx
  801f54:	5e                   	pop    %esi
  801f55:	5f                   	pop    %edi
  801f56:	5d                   	pop    %ebp
  801f57:	c3                   	ret    
  801f58:	90                   	nop
  801f59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f60:	39 ce                	cmp    %ecx,%esi
  801f62:	77 74                	ja     801fd8 <__udivdi3+0xd8>
  801f64:	0f bd fe             	bsr    %esi,%edi
  801f67:	83 f7 1f             	xor    $0x1f,%edi
  801f6a:	0f 84 98 00 00 00    	je     802008 <__udivdi3+0x108>
  801f70:	bb 20 00 00 00       	mov    $0x20,%ebx
  801f75:	89 f9                	mov    %edi,%ecx
  801f77:	89 c5                	mov    %eax,%ebp
  801f79:	29 fb                	sub    %edi,%ebx
  801f7b:	d3 e6                	shl    %cl,%esi
  801f7d:	89 d9                	mov    %ebx,%ecx
  801f7f:	d3 ed                	shr    %cl,%ebp
  801f81:	89 f9                	mov    %edi,%ecx
  801f83:	d3 e0                	shl    %cl,%eax
  801f85:	09 ee                	or     %ebp,%esi
  801f87:	89 d9                	mov    %ebx,%ecx
  801f89:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f8d:	89 d5                	mov    %edx,%ebp
  801f8f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801f93:	d3 ed                	shr    %cl,%ebp
  801f95:	89 f9                	mov    %edi,%ecx
  801f97:	d3 e2                	shl    %cl,%edx
  801f99:	89 d9                	mov    %ebx,%ecx
  801f9b:	d3 e8                	shr    %cl,%eax
  801f9d:	09 c2                	or     %eax,%edx
  801f9f:	89 d0                	mov    %edx,%eax
  801fa1:	89 ea                	mov    %ebp,%edx
  801fa3:	f7 f6                	div    %esi
  801fa5:	89 d5                	mov    %edx,%ebp
  801fa7:	89 c3                	mov    %eax,%ebx
  801fa9:	f7 64 24 0c          	mull   0xc(%esp)
  801fad:	39 d5                	cmp    %edx,%ebp
  801faf:	72 10                	jb     801fc1 <__udivdi3+0xc1>
  801fb1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801fb5:	89 f9                	mov    %edi,%ecx
  801fb7:	d3 e6                	shl    %cl,%esi
  801fb9:	39 c6                	cmp    %eax,%esi
  801fbb:	73 07                	jae    801fc4 <__udivdi3+0xc4>
  801fbd:	39 d5                	cmp    %edx,%ebp
  801fbf:	75 03                	jne    801fc4 <__udivdi3+0xc4>
  801fc1:	83 eb 01             	sub    $0x1,%ebx
  801fc4:	31 ff                	xor    %edi,%edi
  801fc6:	89 d8                	mov    %ebx,%eax
  801fc8:	89 fa                	mov    %edi,%edx
  801fca:	83 c4 1c             	add    $0x1c,%esp
  801fcd:	5b                   	pop    %ebx
  801fce:	5e                   	pop    %esi
  801fcf:	5f                   	pop    %edi
  801fd0:	5d                   	pop    %ebp
  801fd1:	c3                   	ret    
  801fd2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801fd8:	31 ff                	xor    %edi,%edi
  801fda:	31 db                	xor    %ebx,%ebx
  801fdc:	89 d8                	mov    %ebx,%eax
  801fde:	89 fa                	mov    %edi,%edx
  801fe0:	83 c4 1c             	add    $0x1c,%esp
  801fe3:	5b                   	pop    %ebx
  801fe4:	5e                   	pop    %esi
  801fe5:	5f                   	pop    %edi
  801fe6:	5d                   	pop    %ebp
  801fe7:	c3                   	ret    
  801fe8:	90                   	nop
  801fe9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ff0:	89 d8                	mov    %ebx,%eax
  801ff2:	f7 f7                	div    %edi
  801ff4:	31 ff                	xor    %edi,%edi
  801ff6:	89 c3                	mov    %eax,%ebx
  801ff8:	89 d8                	mov    %ebx,%eax
  801ffa:	89 fa                	mov    %edi,%edx
  801ffc:	83 c4 1c             	add    $0x1c,%esp
  801fff:	5b                   	pop    %ebx
  802000:	5e                   	pop    %esi
  802001:	5f                   	pop    %edi
  802002:	5d                   	pop    %ebp
  802003:	c3                   	ret    
  802004:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802008:	39 ce                	cmp    %ecx,%esi
  80200a:	72 0c                	jb     802018 <__udivdi3+0x118>
  80200c:	31 db                	xor    %ebx,%ebx
  80200e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802012:	0f 87 34 ff ff ff    	ja     801f4c <__udivdi3+0x4c>
  802018:	bb 01 00 00 00       	mov    $0x1,%ebx
  80201d:	e9 2a ff ff ff       	jmp    801f4c <__udivdi3+0x4c>
  802022:	66 90                	xchg   %ax,%ax
  802024:	66 90                	xchg   %ax,%ax
  802026:	66 90                	xchg   %ax,%ax
  802028:	66 90                	xchg   %ax,%ax
  80202a:	66 90                	xchg   %ax,%ax
  80202c:	66 90                	xchg   %ax,%ax
  80202e:	66 90                	xchg   %ax,%ax

00802030 <__umoddi3>:
  802030:	55                   	push   %ebp
  802031:	57                   	push   %edi
  802032:	56                   	push   %esi
  802033:	53                   	push   %ebx
  802034:	83 ec 1c             	sub    $0x1c,%esp
  802037:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80203b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80203f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802043:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802047:	85 d2                	test   %edx,%edx
  802049:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80204d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802051:	89 f3                	mov    %esi,%ebx
  802053:	89 3c 24             	mov    %edi,(%esp)
  802056:	89 74 24 04          	mov    %esi,0x4(%esp)
  80205a:	75 1c                	jne    802078 <__umoddi3+0x48>
  80205c:	39 f7                	cmp    %esi,%edi
  80205e:	76 50                	jbe    8020b0 <__umoddi3+0x80>
  802060:	89 c8                	mov    %ecx,%eax
  802062:	89 f2                	mov    %esi,%edx
  802064:	f7 f7                	div    %edi
  802066:	89 d0                	mov    %edx,%eax
  802068:	31 d2                	xor    %edx,%edx
  80206a:	83 c4 1c             	add    $0x1c,%esp
  80206d:	5b                   	pop    %ebx
  80206e:	5e                   	pop    %esi
  80206f:	5f                   	pop    %edi
  802070:	5d                   	pop    %ebp
  802071:	c3                   	ret    
  802072:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802078:	39 f2                	cmp    %esi,%edx
  80207a:	89 d0                	mov    %edx,%eax
  80207c:	77 52                	ja     8020d0 <__umoddi3+0xa0>
  80207e:	0f bd ea             	bsr    %edx,%ebp
  802081:	83 f5 1f             	xor    $0x1f,%ebp
  802084:	75 5a                	jne    8020e0 <__umoddi3+0xb0>
  802086:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80208a:	0f 82 e0 00 00 00    	jb     802170 <__umoddi3+0x140>
  802090:	39 0c 24             	cmp    %ecx,(%esp)
  802093:	0f 86 d7 00 00 00    	jbe    802170 <__umoddi3+0x140>
  802099:	8b 44 24 08          	mov    0x8(%esp),%eax
  80209d:	8b 54 24 04          	mov    0x4(%esp),%edx
  8020a1:	83 c4 1c             	add    $0x1c,%esp
  8020a4:	5b                   	pop    %ebx
  8020a5:	5e                   	pop    %esi
  8020a6:	5f                   	pop    %edi
  8020a7:	5d                   	pop    %ebp
  8020a8:	c3                   	ret    
  8020a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020b0:	85 ff                	test   %edi,%edi
  8020b2:	89 fd                	mov    %edi,%ebp
  8020b4:	75 0b                	jne    8020c1 <__umoddi3+0x91>
  8020b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8020bb:	31 d2                	xor    %edx,%edx
  8020bd:	f7 f7                	div    %edi
  8020bf:	89 c5                	mov    %eax,%ebp
  8020c1:	89 f0                	mov    %esi,%eax
  8020c3:	31 d2                	xor    %edx,%edx
  8020c5:	f7 f5                	div    %ebp
  8020c7:	89 c8                	mov    %ecx,%eax
  8020c9:	f7 f5                	div    %ebp
  8020cb:	89 d0                	mov    %edx,%eax
  8020cd:	eb 99                	jmp    802068 <__umoddi3+0x38>
  8020cf:	90                   	nop
  8020d0:	89 c8                	mov    %ecx,%eax
  8020d2:	89 f2                	mov    %esi,%edx
  8020d4:	83 c4 1c             	add    $0x1c,%esp
  8020d7:	5b                   	pop    %ebx
  8020d8:	5e                   	pop    %esi
  8020d9:	5f                   	pop    %edi
  8020da:	5d                   	pop    %ebp
  8020db:	c3                   	ret    
  8020dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020e0:	8b 34 24             	mov    (%esp),%esi
  8020e3:	bf 20 00 00 00       	mov    $0x20,%edi
  8020e8:	89 e9                	mov    %ebp,%ecx
  8020ea:	29 ef                	sub    %ebp,%edi
  8020ec:	d3 e0                	shl    %cl,%eax
  8020ee:	89 f9                	mov    %edi,%ecx
  8020f0:	89 f2                	mov    %esi,%edx
  8020f2:	d3 ea                	shr    %cl,%edx
  8020f4:	89 e9                	mov    %ebp,%ecx
  8020f6:	09 c2                	or     %eax,%edx
  8020f8:	89 d8                	mov    %ebx,%eax
  8020fa:	89 14 24             	mov    %edx,(%esp)
  8020fd:	89 f2                	mov    %esi,%edx
  8020ff:	d3 e2                	shl    %cl,%edx
  802101:	89 f9                	mov    %edi,%ecx
  802103:	89 54 24 04          	mov    %edx,0x4(%esp)
  802107:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80210b:	d3 e8                	shr    %cl,%eax
  80210d:	89 e9                	mov    %ebp,%ecx
  80210f:	89 c6                	mov    %eax,%esi
  802111:	d3 e3                	shl    %cl,%ebx
  802113:	89 f9                	mov    %edi,%ecx
  802115:	89 d0                	mov    %edx,%eax
  802117:	d3 e8                	shr    %cl,%eax
  802119:	89 e9                	mov    %ebp,%ecx
  80211b:	09 d8                	or     %ebx,%eax
  80211d:	89 d3                	mov    %edx,%ebx
  80211f:	89 f2                	mov    %esi,%edx
  802121:	f7 34 24             	divl   (%esp)
  802124:	89 d6                	mov    %edx,%esi
  802126:	d3 e3                	shl    %cl,%ebx
  802128:	f7 64 24 04          	mull   0x4(%esp)
  80212c:	39 d6                	cmp    %edx,%esi
  80212e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802132:	89 d1                	mov    %edx,%ecx
  802134:	89 c3                	mov    %eax,%ebx
  802136:	72 08                	jb     802140 <__umoddi3+0x110>
  802138:	75 11                	jne    80214b <__umoddi3+0x11b>
  80213a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80213e:	73 0b                	jae    80214b <__umoddi3+0x11b>
  802140:	2b 44 24 04          	sub    0x4(%esp),%eax
  802144:	1b 14 24             	sbb    (%esp),%edx
  802147:	89 d1                	mov    %edx,%ecx
  802149:	89 c3                	mov    %eax,%ebx
  80214b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80214f:	29 da                	sub    %ebx,%edx
  802151:	19 ce                	sbb    %ecx,%esi
  802153:	89 f9                	mov    %edi,%ecx
  802155:	89 f0                	mov    %esi,%eax
  802157:	d3 e0                	shl    %cl,%eax
  802159:	89 e9                	mov    %ebp,%ecx
  80215b:	d3 ea                	shr    %cl,%edx
  80215d:	89 e9                	mov    %ebp,%ecx
  80215f:	d3 ee                	shr    %cl,%esi
  802161:	09 d0                	or     %edx,%eax
  802163:	89 f2                	mov    %esi,%edx
  802165:	83 c4 1c             	add    $0x1c,%esp
  802168:	5b                   	pop    %ebx
  802169:	5e                   	pop    %esi
  80216a:	5f                   	pop    %edi
  80216b:	5d                   	pop    %ebp
  80216c:	c3                   	ret    
  80216d:	8d 76 00             	lea    0x0(%esi),%esi
  802170:	29 f9                	sub    %edi,%ecx
  802172:	19 d6                	sbb    %edx,%esi
  802174:	89 74 24 04          	mov    %esi,0x4(%esp)
  802178:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80217c:	e9 18 ff ff ff       	jmp    802099 <__umoddi3+0x69>
