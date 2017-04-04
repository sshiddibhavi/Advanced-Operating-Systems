
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
  800047:	68 40 21 80 00       	push   $0x802140
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
  800095:	68 51 21 80 00       	push   $0x802151
  80009a:	6a 04                	push   $0x4
  80009c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80009f:	50                   	push   %eax
  8000a0:	e8 61 06 00 00       	call   800706 <snprintf>
	if (fork() == 0) {
  8000a5:	83 c4 20             	add    $0x20,%esp
  8000a8:	e8 f3 0d 00 00       	call   800ea0 <fork>
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
  8000d2:	68 50 21 80 00       	push   $0x802150
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
  80012d:	e8 2e 10 00 00       	call   801160 <close_all>
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
  800237:	e8 64 1c 00 00       	call   801ea0 <__udivdi3>
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
  80027a:	e8 51 1d 00 00       	call   801fd0 <__umoddi3>
  80027f:	83 c4 14             	add    $0x14,%esp
  800282:	0f be 80 60 21 80 00 	movsbl 0x802160(%eax),%eax
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
  80037e:	ff 24 85 a0 22 80 00 	jmp    *0x8022a0(,%eax,4)
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
  800442:	8b 14 85 00 24 80 00 	mov    0x802400(,%eax,4),%edx
  800449:	85 d2                	test   %edx,%edx
  80044b:	75 18                	jne    800465 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80044d:	50                   	push   %eax
  80044e:	68 78 21 80 00       	push   $0x802178
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
  800466:	68 ea 25 80 00       	push   $0x8025ea
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
  80048a:	b8 71 21 80 00       	mov    $0x802171,%eax
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
  800b05:	68 5f 24 80 00       	push   $0x80245f
  800b0a:	6a 23                	push   $0x23
  800b0c:	68 7c 24 80 00       	push   $0x80247c
  800b11:	e8 92 11 00 00       	call   801ca8 <_panic>

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
  800b86:	68 5f 24 80 00       	push   $0x80245f
  800b8b:	6a 23                	push   $0x23
  800b8d:	68 7c 24 80 00       	push   $0x80247c
  800b92:	e8 11 11 00 00       	call   801ca8 <_panic>

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
  800bc8:	68 5f 24 80 00       	push   $0x80245f
  800bcd:	6a 23                	push   $0x23
  800bcf:	68 7c 24 80 00       	push   $0x80247c
  800bd4:	e8 cf 10 00 00       	call   801ca8 <_panic>

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
  800c0a:	68 5f 24 80 00       	push   $0x80245f
  800c0f:	6a 23                	push   $0x23
  800c11:	68 7c 24 80 00       	push   $0x80247c
  800c16:	e8 8d 10 00 00       	call   801ca8 <_panic>

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
  800c4c:	68 5f 24 80 00       	push   $0x80245f
  800c51:	6a 23                	push   $0x23
  800c53:	68 7c 24 80 00       	push   $0x80247c
  800c58:	e8 4b 10 00 00       	call   801ca8 <_panic>

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
  800c8e:	68 5f 24 80 00       	push   $0x80245f
  800c93:	6a 23                	push   $0x23
  800c95:	68 7c 24 80 00       	push   $0x80247c
  800c9a:	e8 09 10 00 00       	call   801ca8 <_panic>

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
  800cd0:	68 5f 24 80 00       	push   $0x80245f
  800cd5:	6a 23                	push   $0x23
  800cd7:	68 7c 24 80 00       	push   $0x80247c
  800cdc:	e8 c7 0f 00 00       	call   801ca8 <_panic>

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
  800d34:	68 5f 24 80 00       	push   $0x80245f
  800d39:	6a 23                	push   $0x23
  800d3b:	68 7c 24 80 00       	push   $0x80247c
  800d40:	e8 63 0f 00 00       	call   801ca8 <_panic>

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
  800d50:	56                   	push   %esi
  800d51:	53                   	push   %ebx
	int r;

	// LAB 4: Your code here.
	// Check if page is writable or COW
	pte_t pte = uvpt[pn];
  800d52:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
	uint32_t perm = PTE_P | PTE_U;
	if (pte && (PTE_COW | PTE_W)) {
		perm |= PTE_COW;
  800d59:	83 f9 01             	cmp    $0x1,%ecx
  800d5c:	19 f6                	sbb    %esi,%esi
  800d5e:	81 e6 00 f8 ff ff    	and    $0xfffff800,%esi
  800d64:	81 c6 05 08 00 00    	add    $0x805,%esi
	}

	// Map page
	void *va = (void *) (pn * PGSIZE);
  800d6a:	c1 e2 0c             	shl    $0xc,%edx
  800d6d:	89 d3                	mov    %edx,%ebx
	// Map on the child
	if ((r = sys_page_map(0, va, envid, va, perm)) < 0) {
  800d6f:	83 ec 0c             	sub    $0xc,%esp
  800d72:	56                   	push   %esi
  800d73:	52                   	push   %edx
  800d74:	50                   	push   %eax
  800d75:	52                   	push   %edx
  800d76:	6a 00                	push   $0x0
  800d78:	e8 22 fe ff ff       	call   800b9f <sys_page_map>
  800d7d:	83 c4 20             	add    $0x20,%esp
  800d80:	85 c0                	test   %eax,%eax
  800d82:	79 12                	jns    800d96 <duppage+0x49>
		panic("sys_page_alloc: %e", r);
  800d84:	50                   	push   %eax
  800d85:	68 8a 24 80 00       	push   $0x80248a
  800d8a:	6a 56                	push   $0x56
  800d8c:	68 9d 24 80 00       	push   $0x80249d
  800d91:	e8 12 0f 00 00       	call   801ca8 <_panic>
		return r;
	}

	// Change the permission on the parent
	if ((r = sys_page_map(0, va, 0, va, perm)) < 0) {
  800d96:	83 ec 0c             	sub    $0xc,%esp
  800d99:	56                   	push   %esi
  800d9a:	53                   	push   %ebx
  800d9b:	6a 00                	push   $0x0
  800d9d:	53                   	push   %ebx
  800d9e:	6a 00                	push   $0x0
  800da0:	e8 fa fd ff ff       	call   800b9f <sys_page_map>
  800da5:	83 c4 20             	add    $0x20,%esp
  800da8:	85 c0                	test   %eax,%eax
  800daa:	79 12                	jns    800dbe <duppage+0x71>
		panic("sys_page_alloc: %e", r);
  800dac:	50                   	push   %eax
  800dad:	68 8a 24 80 00       	push   $0x80248a
  800db2:	6a 5c                	push   $0x5c
  800db4:	68 9d 24 80 00       	push   $0x80249d
  800db9:	e8 ea 0e 00 00       	call   801ca8 <_panic>
		return r;
	}

	return 0;
}
  800dbe:	b8 00 00 00 00       	mov    $0x0,%eax
  800dc3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800dc6:	5b                   	pop    %ebx
  800dc7:	5e                   	pop    %esi
  800dc8:	5d                   	pop    %ebp
  800dc9:	c3                   	ret    

00800dca <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800dca:	55                   	push   %ebp
  800dcb:	89 e5                	mov    %esp,%ebp
  800dcd:	53                   	push   %ebx
  800dce:	83 ec 04             	sub    $0x4,%esp
  800dd1:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800dd4:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	unsigned pn = ((uint32_t)addr)/PGSIZE;
  800dd6:	89 da                	mov    %ebx,%edx
  800dd8:	c1 ea 0c             	shr    $0xc,%edx
	pte_t pte = uvpt[pn];
  800ddb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(err & FEC_WR) || !(pte & PTE_COW)) {
  800de2:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800de6:	74 05                	je     800ded <pgfault+0x23>
  800de8:	f6 c6 08             	test   $0x8,%dh
  800deb:	75 14                	jne    800e01 <pgfault+0x37>
		panic("fork pgfault handler: does not handle this fault");
  800ded:	83 ec 04             	sub    $0x4,%esp
  800df0:	68 0c 25 80 00       	push   $0x80250c
  800df5:	6a 1f                	push   $0x1f
  800df7:	68 9d 24 80 00       	push   $0x80249d
  800dfc:	e8 a7 0e 00 00       	call   801ca8 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// Allocate a new page, mapped at temp location
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  800e01:	83 ec 04             	sub    $0x4,%esp
  800e04:	6a 07                	push   $0x7
  800e06:	68 00 f0 7f 00       	push   $0x7ff000
  800e0b:	6a 00                	push   $0x0
  800e0d:	e8 4a fd ff ff       	call   800b5c <sys_page_alloc>
  800e12:	83 c4 10             	add    $0x10,%esp
  800e15:	85 c0                	test   %eax,%eax
  800e17:	79 12                	jns    800e2b <pgfault+0x61>
		panic("sys_page_alloc: %e", r);
  800e19:	50                   	push   %eax
  800e1a:	68 8a 24 80 00       	push   $0x80248a
  800e1f:	6a 2b                	push   $0x2b
  800e21:	68 9d 24 80 00       	push   $0x80249d
  800e26:	e8 7d 0e 00 00       	call   801ca8 <_panic>

	// Copy the data from the old page to this new page
	void *addr_pgstart = (void *) ROUNDDOWN(addr, PGSIZE);
  800e2b:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr_pgstart, PGSIZE);
  800e31:	83 ec 04             	sub    $0x4,%esp
  800e34:	68 00 10 00 00       	push   $0x1000
  800e39:	53                   	push   %ebx
  800e3a:	68 00 f0 7f 00       	push   $0x7ff000
  800e3f:	e8 a7 fa ff ff       	call   8008eb <memmove>

	// Move the new page to the old page's address
	if ((r = sys_page_map(0, PFTEMP, 0, addr_pgstart, PTE_P|PTE_U|PTE_W)) < 0)
  800e44:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e4b:	53                   	push   %ebx
  800e4c:	6a 00                	push   $0x0
  800e4e:	68 00 f0 7f 00       	push   $0x7ff000
  800e53:	6a 00                	push   $0x0
  800e55:	e8 45 fd ff ff       	call   800b9f <sys_page_map>
  800e5a:	83 c4 20             	add    $0x20,%esp
  800e5d:	85 c0                	test   %eax,%eax
  800e5f:	79 12                	jns    800e73 <pgfault+0xa9>
		panic("sys_page_map: %e", r);
  800e61:	50                   	push   %eax
  800e62:	68 a8 24 80 00       	push   $0x8024a8
  800e67:	6a 33                	push   $0x33
  800e69:	68 9d 24 80 00       	push   $0x80249d
  800e6e:	e8 35 0e 00 00       	call   801ca8 <_panic>

	// Unmap the temp location
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800e73:	83 ec 08             	sub    $0x8,%esp
  800e76:	68 00 f0 7f 00       	push   $0x7ff000
  800e7b:	6a 00                	push   $0x0
  800e7d:	e8 5f fd ff ff       	call   800be1 <sys_page_unmap>
  800e82:	83 c4 10             	add    $0x10,%esp
  800e85:	85 c0                	test   %eax,%eax
  800e87:	79 12                	jns    800e9b <pgfault+0xd1>
		panic("sys_page_unmap: %e", r);
  800e89:	50                   	push   %eax
  800e8a:	68 b9 24 80 00       	push   $0x8024b9
  800e8f:	6a 37                	push   $0x37
  800e91:	68 9d 24 80 00       	push   $0x80249d
  800e96:	e8 0d 0e 00 00       	call   801ca8 <_panic>
}
  800e9b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e9e:	c9                   	leave  
  800e9f:	c3                   	ret    

00800ea0 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ea0:	55                   	push   %ebp
  800ea1:	89 e5                	mov    %esp,%ebp
  800ea3:	56                   	push   %esi
  800ea4:	53                   	push   %ebx
  800ea5:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
	// Set up page fault handler
	set_pgfault_handler(&pgfault);
  800ea8:	68 ca 0d 80 00       	push   $0x800dca
  800ead:	e8 3c 0e 00 00       	call   801cee <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800eb2:	b8 07 00 00 00       	mov    $0x7,%eax
  800eb7:	cd 30                	int    $0x30

	// Create child
	envid_t envid = sys_exofork();
  800eb9:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (envid < 0) {
  800ebc:	83 c4 10             	add    $0x10,%esp
  800ebf:	85 c0                	test   %eax,%eax
  800ec1:	79 12                	jns    800ed5 <fork+0x35>
		panic("sys_exofork: %e", envid);
  800ec3:	50                   	push   %eax
  800ec4:	68 cc 24 80 00       	push   $0x8024cc
  800ec9:	6a 7d                	push   $0x7d
  800ecb:	68 9d 24 80 00       	push   $0x80249d
  800ed0:	e8 d3 0d 00 00       	call   801ca8 <_panic>
		return envid;
	}
	if (envid == 0) {
  800ed5:	85 c0                	test   %eax,%eax
  800ed7:	75 1e                	jne    800ef7 <fork+0x57>
		// We are the child.
		thisenv = &envs[ENVX(sys_getenvid())]; // Fix thisenv
  800ed9:	e8 40 fc ff ff       	call   800b1e <sys_getenvid>
  800ede:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ee3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800ee6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800eeb:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800ef0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ef5:	eb 7d                	jmp    800f74 <fork+0xd4>

	// Set page fault handler on the child.
	// The parent needs to do it, else the child wouldn't be able to handle
	// the fault when trying to access it's stack (which happens as soon it starts)
	extern void _pgfault_upcall(void);
	sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);
  800ef7:	83 ec 04             	sub    $0x4,%esp
  800efa:	6a 07                	push   $0x7
  800efc:	68 00 f0 bf ee       	push   $0xeebff000
  800f01:	50                   	push   %eax
  800f02:	e8 55 fc ff ff       	call   800b5c <sys_page_alloc>
	sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  800f07:	83 c4 08             	add    $0x8,%esp
  800f0a:	68 33 1d 80 00       	push   $0x801d33
  800f0f:	ff 75 f4             	pushl  -0xc(%ebp)
  800f12:	e8 90 fd ff ff       	call   800ca7 <sys_env_set_pgfault_upcall>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  800f17:	be 04 60 80 00       	mov    $0x806004,%esi
  800f1c:	c1 ee 0c             	shr    $0xc,%esi
  800f1f:	83 c4 10             	add    $0x10,%esp
  800f22:	bb 00 08 00 00       	mov    $0x800,%ebx
  800f27:	eb 0d                	jmp    800f36 <fork+0x96>
		duppage(envid, pn);
  800f29:	89 da                	mov    %ebx,%edx
  800f2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f2e:	e8 1a fe ff ff       	call   800d4d <duppage>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  800f33:	83 c3 01             	add    $0x1,%ebx
  800f36:	39 f3                	cmp    %esi,%ebx
  800f38:	76 ef                	jbe    800f29 <fork+0x89>
	}

	// Also copy the stack we are currently running on
	// I think it should loop from ustacktop to this page, since the stack
	// can have more than 1 page
	duppage(envid, ((uint32_t) &envid)/PGSIZE);
  800f3a:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800f3d:	c1 ea 0c             	shr    $0xc,%edx
  800f40:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f43:	e8 05 fe ff ff       	call   800d4d <duppage>

	// Start the child environmnet running
	int r;
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  800f48:	83 ec 08             	sub    $0x8,%esp
  800f4b:	6a 02                	push   $0x2
  800f4d:	ff 75 f4             	pushl  -0xc(%ebp)
  800f50:	e8 ce fc ff ff       	call   800c23 <sys_env_set_status>
  800f55:	83 c4 10             	add    $0x10,%esp
  800f58:	85 c0                	test   %eax,%eax
  800f5a:	79 15                	jns    800f71 <fork+0xd1>
		panic("sys_env_set_status: %e", r);
  800f5c:	50                   	push   %eax
  800f5d:	68 dc 24 80 00       	push   $0x8024dc
  800f62:	68 9d 00 00 00       	push   $0x9d
  800f67:	68 9d 24 80 00       	push   $0x80249d
  800f6c:	e8 37 0d 00 00       	call   801ca8 <_panic>
		return r;
	}

	return envid;
  800f71:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800f74:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f77:	5b                   	pop    %ebx
  800f78:	5e                   	pop    %esi
  800f79:	5d                   	pop    %ebp
  800f7a:	c3                   	ret    

00800f7b <sfork>:

// Challenge!
int
sfork(void)
{
  800f7b:	55                   	push   %ebp
  800f7c:	89 e5                	mov    %esp,%ebp
  800f7e:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800f81:	68 f3 24 80 00       	push   $0x8024f3
  800f86:	68 a8 00 00 00       	push   $0xa8
  800f8b:	68 9d 24 80 00       	push   $0x80249d
  800f90:	e8 13 0d 00 00       	call   801ca8 <_panic>

00800f95 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800f95:	55                   	push   %ebp
  800f96:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f98:	8b 45 08             	mov    0x8(%ebp),%eax
  800f9b:	05 00 00 00 30       	add    $0x30000000,%eax
  800fa0:	c1 e8 0c             	shr    $0xc,%eax
}
  800fa3:	5d                   	pop    %ebp
  800fa4:	c3                   	ret    

00800fa5 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800fa5:	55                   	push   %ebp
  800fa6:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800fa8:	8b 45 08             	mov    0x8(%ebp),%eax
  800fab:	05 00 00 00 30       	add    $0x30000000,%eax
  800fb0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800fb5:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800fba:	5d                   	pop    %ebp
  800fbb:	c3                   	ret    

00800fbc <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800fbc:	55                   	push   %ebp
  800fbd:	89 e5                	mov    %esp,%ebp
  800fbf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fc2:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800fc7:	89 c2                	mov    %eax,%edx
  800fc9:	c1 ea 16             	shr    $0x16,%edx
  800fcc:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800fd3:	f6 c2 01             	test   $0x1,%dl
  800fd6:	74 11                	je     800fe9 <fd_alloc+0x2d>
  800fd8:	89 c2                	mov    %eax,%edx
  800fda:	c1 ea 0c             	shr    $0xc,%edx
  800fdd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fe4:	f6 c2 01             	test   $0x1,%dl
  800fe7:	75 09                	jne    800ff2 <fd_alloc+0x36>
			*fd_store = fd;
  800fe9:	89 01                	mov    %eax,(%ecx)
			return 0;
  800feb:	b8 00 00 00 00       	mov    $0x0,%eax
  800ff0:	eb 17                	jmp    801009 <fd_alloc+0x4d>
  800ff2:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800ff7:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800ffc:	75 c9                	jne    800fc7 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800ffe:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801004:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801009:	5d                   	pop    %ebp
  80100a:	c3                   	ret    

0080100b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80100b:	55                   	push   %ebp
  80100c:	89 e5                	mov    %esp,%ebp
  80100e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801011:	83 f8 1f             	cmp    $0x1f,%eax
  801014:	77 36                	ja     80104c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801016:	c1 e0 0c             	shl    $0xc,%eax
  801019:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80101e:	89 c2                	mov    %eax,%edx
  801020:	c1 ea 16             	shr    $0x16,%edx
  801023:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80102a:	f6 c2 01             	test   $0x1,%dl
  80102d:	74 24                	je     801053 <fd_lookup+0x48>
  80102f:	89 c2                	mov    %eax,%edx
  801031:	c1 ea 0c             	shr    $0xc,%edx
  801034:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80103b:	f6 c2 01             	test   $0x1,%dl
  80103e:	74 1a                	je     80105a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801040:	8b 55 0c             	mov    0xc(%ebp),%edx
  801043:	89 02                	mov    %eax,(%edx)
	return 0;
  801045:	b8 00 00 00 00       	mov    $0x0,%eax
  80104a:	eb 13                	jmp    80105f <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80104c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801051:	eb 0c                	jmp    80105f <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801053:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801058:	eb 05                	jmp    80105f <fd_lookup+0x54>
  80105a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80105f:	5d                   	pop    %ebp
  801060:	c3                   	ret    

00801061 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801061:	55                   	push   %ebp
  801062:	89 e5                	mov    %esp,%ebp
  801064:	83 ec 08             	sub    $0x8,%esp
  801067:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80106a:	ba bc 25 80 00       	mov    $0x8025bc,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80106f:	eb 13                	jmp    801084 <dev_lookup+0x23>
  801071:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801074:	39 08                	cmp    %ecx,(%eax)
  801076:	75 0c                	jne    801084 <dev_lookup+0x23>
			*dev = devtab[i];
  801078:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80107b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80107d:	b8 00 00 00 00       	mov    $0x0,%eax
  801082:	eb 2e                	jmp    8010b2 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801084:	8b 02                	mov    (%edx),%eax
  801086:	85 c0                	test   %eax,%eax
  801088:	75 e7                	jne    801071 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80108a:	a1 04 40 80 00       	mov    0x804004,%eax
  80108f:	8b 40 48             	mov    0x48(%eax),%eax
  801092:	83 ec 04             	sub    $0x4,%esp
  801095:	51                   	push   %ecx
  801096:	50                   	push   %eax
  801097:	68 40 25 80 00       	push   $0x802540
  80109c:	e8 33 f1 ff ff       	call   8001d4 <cprintf>
	*dev = 0;
  8010a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010a4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8010aa:	83 c4 10             	add    $0x10,%esp
  8010ad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8010b2:	c9                   	leave  
  8010b3:	c3                   	ret    

008010b4 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8010b4:	55                   	push   %ebp
  8010b5:	89 e5                	mov    %esp,%ebp
  8010b7:	56                   	push   %esi
  8010b8:	53                   	push   %ebx
  8010b9:	83 ec 10             	sub    $0x10,%esp
  8010bc:	8b 75 08             	mov    0x8(%ebp),%esi
  8010bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8010c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010c5:	50                   	push   %eax
  8010c6:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8010cc:	c1 e8 0c             	shr    $0xc,%eax
  8010cf:	50                   	push   %eax
  8010d0:	e8 36 ff ff ff       	call   80100b <fd_lookup>
  8010d5:	83 c4 08             	add    $0x8,%esp
  8010d8:	85 c0                	test   %eax,%eax
  8010da:	78 05                	js     8010e1 <fd_close+0x2d>
	    || fd != fd2)
  8010dc:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8010df:	74 0c                	je     8010ed <fd_close+0x39>
		return (must_exist ? r : 0);
  8010e1:	84 db                	test   %bl,%bl
  8010e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8010e8:	0f 44 c2             	cmove  %edx,%eax
  8010eb:	eb 41                	jmp    80112e <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8010ed:	83 ec 08             	sub    $0x8,%esp
  8010f0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010f3:	50                   	push   %eax
  8010f4:	ff 36                	pushl  (%esi)
  8010f6:	e8 66 ff ff ff       	call   801061 <dev_lookup>
  8010fb:	89 c3                	mov    %eax,%ebx
  8010fd:	83 c4 10             	add    $0x10,%esp
  801100:	85 c0                	test   %eax,%eax
  801102:	78 1a                	js     80111e <fd_close+0x6a>
		if (dev->dev_close)
  801104:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801107:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80110a:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80110f:	85 c0                	test   %eax,%eax
  801111:	74 0b                	je     80111e <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801113:	83 ec 0c             	sub    $0xc,%esp
  801116:	56                   	push   %esi
  801117:	ff d0                	call   *%eax
  801119:	89 c3                	mov    %eax,%ebx
  80111b:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80111e:	83 ec 08             	sub    $0x8,%esp
  801121:	56                   	push   %esi
  801122:	6a 00                	push   $0x0
  801124:	e8 b8 fa ff ff       	call   800be1 <sys_page_unmap>
	return r;
  801129:	83 c4 10             	add    $0x10,%esp
  80112c:	89 d8                	mov    %ebx,%eax
}
  80112e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801131:	5b                   	pop    %ebx
  801132:	5e                   	pop    %esi
  801133:	5d                   	pop    %ebp
  801134:	c3                   	ret    

00801135 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801135:	55                   	push   %ebp
  801136:	89 e5                	mov    %esp,%ebp
  801138:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80113b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80113e:	50                   	push   %eax
  80113f:	ff 75 08             	pushl  0x8(%ebp)
  801142:	e8 c4 fe ff ff       	call   80100b <fd_lookup>
  801147:	83 c4 08             	add    $0x8,%esp
  80114a:	85 c0                	test   %eax,%eax
  80114c:	78 10                	js     80115e <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80114e:	83 ec 08             	sub    $0x8,%esp
  801151:	6a 01                	push   $0x1
  801153:	ff 75 f4             	pushl  -0xc(%ebp)
  801156:	e8 59 ff ff ff       	call   8010b4 <fd_close>
  80115b:	83 c4 10             	add    $0x10,%esp
}
  80115e:	c9                   	leave  
  80115f:	c3                   	ret    

00801160 <close_all>:

void
close_all(void)
{
  801160:	55                   	push   %ebp
  801161:	89 e5                	mov    %esp,%ebp
  801163:	53                   	push   %ebx
  801164:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801167:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80116c:	83 ec 0c             	sub    $0xc,%esp
  80116f:	53                   	push   %ebx
  801170:	e8 c0 ff ff ff       	call   801135 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801175:	83 c3 01             	add    $0x1,%ebx
  801178:	83 c4 10             	add    $0x10,%esp
  80117b:	83 fb 20             	cmp    $0x20,%ebx
  80117e:	75 ec                	jne    80116c <close_all+0xc>
		close(i);
}
  801180:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801183:	c9                   	leave  
  801184:	c3                   	ret    

00801185 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801185:	55                   	push   %ebp
  801186:	89 e5                	mov    %esp,%ebp
  801188:	57                   	push   %edi
  801189:	56                   	push   %esi
  80118a:	53                   	push   %ebx
  80118b:	83 ec 2c             	sub    $0x2c,%esp
  80118e:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801191:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801194:	50                   	push   %eax
  801195:	ff 75 08             	pushl  0x8(%ebp)
  801198:	e8 6e fe ff ff       	call   80100b <fd_lookup>
  80119d:	83 c4 08             	add    $0x8,%esp
  8011a0:	85 c0                	test   %eax,%eax
  8011a2:	0f 88 c1 00 00 00    	js     801269 <dup+0xe4>
		return r;
	close(newfdnum);
  8011a8:	83 ec 0c             	sub    $0xc,%esp
  8011ab:	56                   	push   %esi
  8011ac:	e8 84 ff ff ff       	call   801135 <close>

	newfd = INDEX2FD(newfdnum);
  8011b1:	89 f3                	mov    %esi,%ebx
  8011b3:	c1 e3 0c             	shl    $0xc,%ebx
  8011b6:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8011bc:	83 c4 04             	add    $0x4,%esp
  8011bf:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011c2:	e8 de fd ff ff       	call   800fa5 <fd2data>
  8011c7:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8011c9:	89 1c 24             	mov    %ebx,(%esp)
  8011cc:	e8 d4 fd ff ff       	call   800fa5 <fd2data>
  8011d1:	83 c4 10             	add    $0x10,%esp
  8011d4:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8011d7:	89 f8                	mov    %edi,%eax
  8011d9:	c1 e8 16             	shr    $0x16,%eax
  8011dc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011e3:	a8 01                	test   $0x1,%al
  8011e5:	74 37                	je     80121e <dup+0x99>
  8011e7:	89 f8                	mov    %edi,%eax
  8011e9:	c1 e8 0c             	shr    $0xc,%eax
  8011ec:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8011f3:	f6 c2 01             	test   $0x1,%dl
  8011f6:	74 26                	je     80121e <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8011f8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011ff:	83 ec 0c             	sub    $0xc,%esp
  801202:	25 07 0e 00 00       	and    $0xe07,%eax
  801207:	50                   	push   %eax
  801208:	ff 75 d4             	pushl  -0x2c(%ebp)
  80120b:	6a 00                	push   $0x0
  80120d:	57                   	push   %edi
  80120e:	6a 00                	push   $0x0
  801210:	e8 8a f9 ff ff       	call   800b9f <sys_page_map>
  801215:	89 c7                	mov    %eax,%edi
  801217:	83 c4 20             	add    $0x20,%esp
  80121a:	85 c0                	test   %eax,%eax
  80121c:	78 2e                	js     80124c <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80121e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801221:	89 d0                	mov    %edx,%eax
  801223:	c1 e8 0c             	shr    $0xc,%eax
  801226:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80122d:	83 ec 0c             	sub    $0xc,%esp
  801230:	25 07 0e 00 00       	and    $0xe07,%eax
  801235:	50                   	push   %eax
  801236:	53                   	push   %ebx
  801237:	6a 00                	push   $0x0
  801239:	52                   	push   %edx
  80123a:	6a 00                	push   $0x0
  80123c:	e8 5e f9 ff ff       	call   800b9f <sys_page_map>
  801241:	89 c7                	mov    %eax,%edi
  801243:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801246:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801248:	85 ff                	test   %edi,%edi
  80124a:	79 1d                	jns    801269 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80124c:	83 ec 08             	sub    $0x8,%esp
  80124f:	53                   	push   %ebx
  801250:	6a 00                	push   $0x0
  801252:	e8 8a f9 ff ff       	call   800be1 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801257:	83 c4 08             	add    $0x8,%esp
  80125a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80125d:	6a 00                	push   $0x0
  80125f:	e8 7d f9 ff ff       	call   800be1 <sys_page_unmap>
	return r;
  801264:	83 c4 10             	add    $0x10,%esp
  801267:	89 f8                	mov    %edi,%eax
}
  801269:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80126c:	5b                   	pop    %ebx
  80126d:	5e                   	pop    %esi
  80126e:	5f                   	pop    %edi
  80126f:	5d                   	pop    %ebp
  801270:	c3                   	ret    

00801271 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801271:	55                   	push   %ebp
  801272:	89 e5                	mov    %esp,%ebp
  801274:	53                   	push   %ebx
  801275:	83 ec 14             	sub    $0x14,%esp
  801278:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80127b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80127e:	50                   	push   %eax
  80127f:	53                   	push   %ebx
  801280:	e8 86 fd ff ff       	call   80100b <fd_lookup>
  801285:	83 c4 08             	add    $0x8,%esp
  801288:	89 c2                	mov    %eax,%edx
  80128a:	85 c0                	test   %eax,%eax
  80128c:	78 6d                	js     8012fb <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80128e:	83 ec 08             	sub    $0x8,%esp
  801291:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801294:	50                   	push   %eax
  801295:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801298:	ff 30                	pushl  (%eax)
  80129a:	e8 c2 fd ff ff       	call   801061 <dev_lookup>
  80129f:	83 c4 10             	add    $0x10,%esp
  8012a2:	85 c0                	test   %eax,%eax
  8012a4:	78 4c                	js     8012f2 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8012a6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8012a9:	8b 42 08             	mov    0x8(%edx),%eax
  8012ac:	83 e0 03             	and    $0x3,%eax
  8012af:	83 f8 01             	cmp    $0x1,%eax
  8012b2:	75 21                	jne    8012d5 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8012b4:	a1 04 40 80 00       	mov    0x804004,%eax
  8012b9:	8b 40 48             	mov    0x48(%eax),%eax
  8012bc:	83 ec 04             	sub    $0x4,%esp
  8012bf:	53                   	push   %ebx
  8012c0:	50                   	push   %eax
  8012c1:	68 81 25 80 00       	push   $0x802581
  8012c6:	e8 09 ef ff ff       	call   8001d4 <cprintf>
		return -E_INVAL;
  8012cb:	83 c4 10             	add    $0x10,%esp
  8012ce:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012d3:	eb 26                	jmp    8012fb <read+0x8a>
	}
	if (!dev->dev_read)
  8012d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012d8:	8b 40 08             	mov    0x8(%eax),%eax
  8012db:	85 c0                	test   %eax,%eax
  8012dd:	74 17                	je     8012f6 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8012df:	83 ec 04             	sub    $0x4,%esp
  8012e2:	ff 75 10             	pushl  0x10(%ebp)
  8012e5:	ff 75 0c             	pushl  0xc(%ebp)
  8012e8:	52                   	push   %edx
  8012e9:	ff d0                	call   *%eax
  8012eb:	89 c2                	mov    %eax,%edx
  8012ed:	83 c4 10             	add    $0x10,%esp
  8012f0:	eb 09                	jmp    8012fb <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012f2:	89 c2                	mov    %eax,%edx
  8012f4:	eb 05                	jmp    8012fb <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8012f6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8012fb:	89 d0                	mov    %edx,%eax
  8012fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801300:	c9                   	leave  
  801301:	c3                   	ret    

00801302 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801302:	55                   	push   %ebp
  801303:	89 e5                	mov    %esp,%ebp
  801305:	57                   	push   %edi
  801306:	56                   	push   %esi
  801307:	53                   	push   %ebx
  801308:	83 ec 0c             	sub    $0xc,%esp
  80130b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80130e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801311:	bb 00 00 00 00       	mov    $0x0,%ebx
  801316:	eb 21                	jmp    801339 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801318:	83 ec 04             	sub    $0x4,%esp
  80131b:	89 f0                	mov    %esi,%eax
  80131d:	29 d8                	sub    %ebx,%eax
  80131f:	50                   	push   %eax
  801320:	89 d8                	mov    %ebx,%eax
  801322:	03 45 0c             	add    0xc(%ebp),%eax
  801325:	50                   	push   %eax
  801326:	57                   	push   %edi
  801327:	e8 45 ff ff ff       	call   801271 <read>
		if (m < 0)
  80132c:	83 c4 10             	add    $0x10,%esp
  80132f:	85 c0                	test   %eax,%eax
  801331:	78 10                	js     801343 <readn+0x41>
			return m;
		if (m == 0)
  801333:	85 c0                	test   %eax,%eax
  801335:	74 0a                	je     801341 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801337:	01 c3                	add    %eax,%ebx
  801339:	39 f3                	cmp    %esi,%ebx
  80133b:	72 db                	jb     801318 <readn+0x16>
  80133d:	89 d8                	mov    %ebx,%eax
  80133f:	eb 02                	jmp    801343 <readn+0x41>
  801341:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801343:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801346:	5b                   	pop    %ebx
  801347:	5e                   	pop    %esi
  801348:	5f                   	pop    %edi
  801349:	5d                   	pop    %ebp
  80134a:	c3                   	ret    

0080134b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80134b:	55                   	push   %ebp
  80134c:	89 e5                	mov    %esp,%ebp
  80134e:	53                   	push   %ebx
  80134f:	83 ec 14             	sub    $0x14,%esp
  801352:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801355:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801358:	50                   	push   %eax
  801359:	53                   	push   %ebx
  80135a:	e8 ac fc ff ff       	call   80100b <fd_lookup>
  80135f:	83 c4 08             	add    $0x8,%esp
  801362:	89 c2                	mov    %eax,%edx
  801364:	85 c0                	test   %eax,%eax
  801366:	78 68                	js     8013d0 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801368:	83 ec 08             	sub    $0x8,%esp
  80136b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80136e:	50                   	push   %eax
  80136f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801372:	ff 30                	pushl  (%eax)
  801374:	e8 e8 fc ff ff       	call   801061 <dev_lookup>
  801379:	83 c4 10             	add    $0x10,%esp
  80137c:	85 c0                	test   %eax,%eax
  80137e:	78 47                	js     8013c7 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801380:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801383:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801387:	75 21                	jne    8013aa <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801389:	a1 04 40 80 00       	mov    0x804004,%eax
  80138e:	8b 40 48             	mov    0x48(%eax),%eax
  801391:	83 ec 04             	sub    $0x4,%esp
  801394:	53                   	push   %ebx
  801395:	50                   	push   %eax
  801396:	68 9d 25 80 00       	push   $0x80259d
  80139b:	e8 34 ee ff ff       	call   8001d4 <cprintf>
		return -E_INVAL;
  8013a0:	83 c4 10             	add    $0x10,%esp
  8013a3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013a8:	eb 26                	jmp    8013d0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8013aa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013ad:	8b 52 0c             	mov    0xc(%edx),%edx
  8013b0:	85 d2                	test   %edx,%edx
  8013b2:	74 17                	je     8013cb <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8013b4:	83 ec 04             	sub    $0x4,%esp
  8013b7:	ff 75 10             	pushl  0x10(%ebp)
  8013ba:	ff 75 0c             	pushl  0xc(%ebp)
  8013bd:	50                   	push   %eax
  8013be:	ff d2                	call   *%edx
  8013c0:	89 c2                	mov    %eax,%edx
  8013c2:	83 c4 10             	add    $0x10,%esp
  8013c5:	eb 09                	jmp    8013d0 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013c7:	89 c2                	mov    %eax,%edx
  8013c9:	eb 05                	jmp    8013d0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8013cb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8013d0:	89 d0                	mov    %edx,%eax
  8013d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013d5:	c9                   	leave  
  8013d6:	c3                   	ret    

008013d7 <seek>:

int
seek(int fdnum, off_t offset)
{
  8013d7:	55                   	push   %ebp
  8013d8:	89 e5                	mov    %esp,%ebp
  8013da:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013dd:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8013e0:	50                   	push   %eax
  8013e1:	ff 75 08             	pushl  0x8(%ebp)
  8013e4:	e8 22 fc ff ff       	call   80100b <fd_lookup>
  8013e9:	83 c4 08             	add    $0x8,%esp
  8013ec:	85 c0                	test   %eax,%eax
  8013ee:	78 0e                	js     8013fe <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8013f0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8013f3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013f6:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8013f9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013fe:	c9                   	leave  
  8013ff:	c3                   	ret    

00801400 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801400:	55                   	push   %ebp
  801401:	89 e5                	mov    %esp,%ebp
  801403:	53                   	push   %ebx
  801404:	83 ec 14             	sub    $0x14,%esp
  801407:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80140a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80140d:	50                   	push   %eax
  80140e:	53                   	push   %ebx
  80140f:	e8 f7 fb ff ff       	call   80100b <fd_lookup>
  801414:	83 c4 08             	add    $0x8,%esp
  801417:	89 c2                	mov    %eax,%edx
  801419:	85 c0                	test   %eax,%eax
  80141b:	78 65                	js     801482 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80141d:	83 ec 08             	sub    $0x8,%esp
  801420:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801423:	50                   	push   %eax
  801424:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801427:	ff 30                	pushl  (%eax)
  801429:	e8 33 fc ff ff       	call   801061 <dev_lookup>
  80142e:	83 c4 10             	add    $0x10,%esp
  801431:	85 c0                	test   %eax,%eax
  801433:	78 44                	js     801479 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801435:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801438:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80143c:	75 21                	jne    80145f <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80143e:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801443:	8b 40 48             	mov    0x48(%eax),%eax
  801446:	83 ec 04             	sub    $0x4,%esp
  801449:	53                   	push   %ebx
  80144a:	50                   	push   %eax
  80144b:	68 60 25 80 00       	push   $0x802560
  801450:	e8 7f ed ff ff       	call   8001d4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801455:	83 c4 10             	add    $0x10,%esp
  801458:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80145d:	eb 23                	jmp    801482 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80145f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801462:	8b 52 18             	mov    0x18(%edx),%edx
  801465:	85 d2                	test   %edx,%edx
  801467:	74 14                	je     80147d <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801469:	83 ec 08             	sub    $0x8,%esp
  80146c:	ff 75 0c             	pushl  0xc(%ebp)
  80146f:	50                   	push   %eax
  801470:	ff d2                	call   *%edx
  801472:	89 c2                	mov    %eax,%edx
  801474:	83 c4 10             	add    $0x10,%esp
  801477:	eb 09                	jmp    801482 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801479:	89 c2                	mov    %eax,%edx
  80147b:	eb 05                	jmp    801482 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80147d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801482:	89 d0                	mov    %edx,%eax
  801484:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801487:	c9                   	leave  
  801488:	c3                   	ret    

00801489 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801489:	55                   	push   %ebp
  80148a:	89 e5                	mov    %esp,%ebp
  80148c:	53                   	push   %ebx
  80148d:	83 ec 14             	sub    $0x14,%esp
  801490:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801493:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801496:	50                   	push   %eax
  801497:	ff 75 08             	pushl  0x8(%ebp)
  80149a:	e8 6c fb ff ff       	call   80100b <fd_lookup>
  80149f:	83 c4 08             	add    $0x8,%esp
  8014a2:	89 c2                	mov    %eax,%edx
  8014a4:	85 c0                	test   %eax,%eax
  8014a6:	78 58                	js     801500 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014a8:	83 ec 08             	sub    $0x8,%esp
  8014ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ae:	50                   	push   %eax
  8014af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014b2:	ff 30                	pushl  (%eax)
  8014b4:	e8 a8 fb ff ff       	call   801061 <dev_lookup>
  8014b9:	83 c4 10             	add    $0x10,%esp
  8014bc:	85 c0                	test   %eax,%eax
  8014be:	78 37                	js     8014f7 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8014c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014c3:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8014c7:	74 32                	je     8014fb <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8014c9:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8014cc:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8014d3:	00 00 00 
	stat->st_isdir = 0;
  8014d6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8014dd:	00 00 00 
	stat->st_dev = dev;
  8014e0:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8014e6:	83 ec 08             	sub    $0x8,%esp
  8014e9:	53                   	push   %ebx
  8014ea:	ff 75 f0             	pushl  -0x10(%ebp)
  8014ed:	ff 50 14             	call   *0x14(%eax)
  8014f0:	89 c2                	mov    %eax,%edx
  8014f2:	83 c4 10             	add    $0x10,%esp
  8014f5:	eb 09                	jmp    801500 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014f7:	89 c2                	mov    %eax,%edx
  8014f9:	eb 05                	jmp    801500 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8014fb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801500:	89 d0                	mov    %edx,%eax
  801502:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801505:	c9                   	leave  
  801506:	c3                   	ret    

00801507 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801507:	55                   	push   %ebp
  801508:	89 e5                	mov    %esp,%ebp
  80150a:	56                   	push   %esi
  80150b:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80150c:	83 ec 08             	sub    $0x8,%esp
  80150f:	6a 00                	push   $0x0
  801511:	ff 75 08             	pushl  0x8(%ebp)
  801514:	e8 0c 02 00 00       	call   801725 <open>
  801519:	89 c3                	mov    %eax,%ebx
  80151b:	83 c4 10             	add    $0x10,%esp
  80151e:	85 c0                	test   %eax,%eax
  801520:	78 1b                	js     80153d <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801522:	83 ec 08             	sub    $0x8,%esp
  801525:	ff 75 0c             	pushl  0xc(%ebp)
  801528:	50                   	push   %eax
  801529:	e8 5b ff ff ff       	call   801489 <fstat>
  80152e:	89 c6                	mov    %eax,%esi
	close(fd);
  801530:	89 1c 24             	mov    %ebx,(%esp)
  801533:	e8 fd fb ff ff       	call   801135 <close>
	return r;
  801538:	83 c4 10             	add    $0x10,%esp
  80153b:	89 f0                	mov    %esi,%eax
}
  80153d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801540:	5b                   	pop    %ebx
  801541:	5e                   	pop    %esi
  801542:	5d                   	pop    %ebp
  801543:	c3                   	ret    

00801544 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801544:	55                   	push   %ebp
  801545:	89 e5                	mov    %esp,%ebp
  801547:	56                   	push   %esi
  801548:	53                   	push   %ebx
  801549:	89 c6                	mov    %eax,%esi
  80154b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80154d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801554:	75 12                	jne    801568 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801556:	83 ec 0c             	sub    $0xc,%esp
  801559:	6a 01                	push   $0x1
  80155b:	e8 c1 08 00 00       	call   801e21 <ipc_find_env>
  801560:	a3 00 40 80 00       	mov    %eax,0x804000
  801565:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801568:	6a 07                	push   $0x7
  80156a:	68 00 50 80 00       	push   $0x805000
  80156f:	56                   	push   %esi
  801570:	ff 35 00 40 80 00    	pushl  0x804000
  801576:	e8 52 08 00 00       	call   801dcd <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80157b:	83 c4 0c             	add    $0xc,%esp
  80157e:	6a 00                	push   $0x0
  801580:	53                   	push   %ebx
  801581:	6a 00                	push   $0x0
  801583:	e8 dc 07 00 00       	call   801d64 <ipc_recv>
}
  801588:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80158b:	5b                   	pop    %ebx
  80158c:	5e                   	pop    %esi
  80158d:	5d                   	pop    %ebp
  80158e:	c3                   	ret    

0080158f <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80158f:	55                   	push   %ebp
  801590:	89 e5                	mov    %esp,%ebp
  801592:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801595:	8b 45 08             	mov    0x8(%ebp),%eax
  801598:	8b 40 0c             	mov    0xc(%eax),%eax
  80159b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8015a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015a3:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8015a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8015ad:	b8 02 00 00 00       	mov    $0x2,%eax
  8015b2:	e8 8d ff ff ff       	call   801544 <fsipc>
}
  8015b7:	c9                   	leave  
  8015b8:	c3                   	ret    

008015b9 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8015b9:	55                   	push   %ebp
  8015ba:	89 e5                	mov    %esp,%ebp
  8015bc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8015bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8015c2:	8b 40 0c             	mov    0xc(%eax),%eax
  8015c5:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8015ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8015cf:	b8 06 00 00 00       	mov    $0x6,%eax
  8015d4:	e8 6b ff ff ff       	call   801544 <fsipc>
}
  8015d9:	c9                   	leave  
  8015da:	c3                   	ret    

008015db <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8015db:	55                   	push   %ebp
  8015dc:	89 e5                	mov    %esp,%ebp
  8015de:	53                   	push   %ebx
  8015df:	83 ec 04             	sub    $0x4,%esp
  8015e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8015e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8015e8:	8b 40 0c             	mov    0xc(%eax),%eax
  8015eb:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8015f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8015f5:	b8 05 00 00 00       	mov    $0x5,%eax
  8015fa:	e8 45 ff ff ff       	call   801544 <fsipc>
  8015ff:	85 c0                	test   %eax,%eax
  801601:	78 2c                	js     80162f <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801603:	83 ec 08             	sub    $0x8,%esp
  801606:	68 00 50 80 00       	push   $0x805000
  80160b:	53                   	push   %ebx
  80160c:	e8 48 f1 ff ff       	call   800759 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801611:	a1 80 50 80 00       	mov    0x805080,%eax
  801616:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80161c:	a1 84 50 80 00       	mov    0x805084,%eax
  801621:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801627:	83 c4 10             	add    $0x10,%esp
  80162a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80162f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801632:	c9                   	leave  
  801633:	c3                   	ret    

00801634 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801634:	55                   	push   %ebp
  801635:	89 e5                	mov    %esp,%ebp
  801637:	53                   	push   %ebx
  801638:	83 ec 08             	sub    $0x8,%esp
  80163b:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80163e:	8b 55 08             	mov    0x8(%ebp),%edx
  801641:	8b 52 0c             	mov    0xc(%edx),%edx
  801644:	89 15 00 50 80 00    	mov    %edx,0x805000
  80164a:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80164f:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  801654:	0f 46 d8             	cmovbe %eax,%ebx
	
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  801657:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  80165d:	53                   	push   %ebx
  80165e:	ff 75 0c             	pushl  0xc(%ebp)
  801661:	68 08 50 80 00       	push   $0x805008
  801666:	e8 80 f2 ff ff       	call   8008eb <memmove>

	
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) 
  80166b:	ba 00 00 00 00       	mov    $0x0,%edx
  801670:	b8 04 00 00 00       	mov    $0x4,%eax
  801675:	e8 ca fe ff ff       	call   801544 <fsipc>
  80167a:	83 c4 10             	add    $0x10,%esp
  80167d:	85 c0                	test   %eax,%eax
  80167f:	78 1d                	js     80169e <devfile_write+0x6a>
		return r;
	assert(r <= n_real); 
  801681:	39 d8                	cmp    %ebx,%eax
  801683:	76 19                	jbe    80169e <devfile_write+0x6a>
  801685:	68 cc 25 80 00       	push   $0x8025cc
  80168a:	68 d8 25 80 00       	push   $0x8025d8
  80168f:	68 a3 00 00 00       	push   $0xa3
  801694:	68 ed 25 80 00       	push   $0x8025ed
  801699:	e8 0a 06 00 00       	call   801ca8 <_panic>
	return r;
}
  80169e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016a1:	c9                   	leave  
  8016a2:	c3                   	ret    

008016a3 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8016a3:	55                   	push   %ebp
  8016a4:	89 e5                	mov    %esp,%ebp
  8016a6:	56                   	push   %esi
  8016a7:	53                   	push   %ebx
  8016a8:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8016ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ae:	8b 40 0c             	mov    0xc(%eax),%eax
  8016b1:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8016b6:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8016bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8016c1:	b8 03 00 00 00       	mov    $0x3,%eax
  8016c6:	e8 79 fe ff ff       	call   801544 <fsipc>
  8016cb:	89 c3                	mov    %eax,%ebx
  8016cd:	85 c0                	test   %eax,%eax
  8016cf:	78 4b                	js     80171c <devfile_read+0x79>
		return r;
	assert(r <= n);
  8016d1:	39 c6                	cmp    %eax,%esi
  8016d3:	73 16                	jae    8016eb <devfile_read+0x48>
  8016d5:	68 f8 25 80 00       	push   $0x8025f8
  8016da:	68 d8 25 80 00       	push   $0x8025d8
  8016df:	6a 7c                	push   $0x7c
  8016e1:	68 ed 25 80 00       	push   $0x8025ed
  8016e6:	e8 bd 05 00 00       	call   801ca8 <_panic>
	assert(r <= PGSIZE);
  8016eb:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8016f0:	7e 16                	jle    801708 <devfile_read+0x65>
  8016f2:	68 ff 25 80 00       	push   $0x8025ff
  8016f7:	68 d8 25 80 00       	push   $0x8025d8
  8016fc:	6a 7d                	push   $0x7d
  8016fe:	68 ed 25 80 00       	push   $0x8025ed
  801703:	e8 a0 05 00 00       	call   801ca8 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801708:	83 ec 04             	sub    $0x4,%esp
  80170b:	50                   	push   %eax
  80170c:	68 00 50 80 00       	push   $0x805000
  801711:	ff 75 0c             	pushl  0xc(%ebp)
  801714:	e8 d2 f1 ff ff       	call   8008eb <memmove>
	return r;
  801719:	83 c4 10             	add    $0x10,%esp
}
  80171c:	89 d8                	mov    %ebx,%eax
  80171e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801721:	5b                   	pop    %ebx
  801722:	5e                   	pop    %esi
  801723:	5d                   	pop    %ebp
  801724:	c3                   	ret    

00801725 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801725:	55                   	push   %ebp
  801726:	89 e5                	mov    %esp,%ebp
  801728:	53                   	push   %ebx
  801729:	83 ec 20             	sub    $0x20,%esp
  80172c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80172f:	53                   	push   %ebx
  801730:	e8 eb ef ff ff       	call   800720 <strlen>
  801735:	83 c4 10             	add    $0x10,%esp
  801738:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80173d:	7f 67                	jg     8017a6 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80173f:	83 ec 0c             	sub    $0xc,%esp
  801742:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801745:	50                   	push   %eax
  801746:	e8 71 f8 ff ff       	call   800fbc <fd_alloc>
  80174b:	83 c4 10             	add    $0x10,%esp
		return r;
  80174e:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801750:	85 c0                	test   %eax,%eax
  801752:	78 57                	js     8017ab <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801754:	83 ec 08             	sub    $0x8,%esp
  801757:	53                   	push   %ebx
  801758:	68 00 50 80 00       	push   $0x805000
  80175d:	e8 f7 ef ff ff       	call   800759 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801762:	8b 45 0c             	mov    0xc(%ebp),%eax
  801765:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80176a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80176d:	b8 01 00 00 00       	mov    $0x1,%eax
  801772:	e8 cd fd ff ff       	call   801544 <fsipc>
  801777:	89 c3                	mov    %eax,%ebx
  801779:	83 c4 10             	add    $0x10,%esp
  80177c:	85 c0                	test   %eax,%eax
  80177e:	79 14                	jns    801794 <open+0x6f>
		fd_close(fd, 0);
  801780:	83 ec 08             	sub    $0x8,%esp
  801783:	6a 00                	push   $0x0
  801785:	ff 75 f4             	pushl  -0xc(%ebp)
  801788:	e8 27 f9 ff ff       	call   8010b4 <fd_close>
		return r;
  80178d:	83 c4 10             	add    $0x10,%esp
  801790:	89 da                	mov    %ebx,%edx
  801792:	eb 17                	jmp    8017ab <open+0x86>
	}

	return fd2num(fd);
  801794:	83 ec 0c             	sub    $0xc,%esp
  801797:	ff 75 f4             	pushl  -0xc(%ebp)
  80179a:	e8 f6 f7 ff ff       	call   800f95 <fd2num>
  80179f:	89 c2                	mov    %eax,%edx
  8017a1:	83 c4 10             	add    $0x10,%esp
  8017a4:	eb 05                	jmp    8017ab <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8017a6:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8017ab:	89 d0                	mov    %edx,%eax
  8017ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017b0:	c9                   	leave  
  8017b1:	c3                   	ret    

008017b2 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8017b2:	55                   	push   %ebp
  8017b3:	89 e5                	mov    %esp,%ebp
  8017b5:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8017b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8017bd:	b8 08 00 00 00       	mov    $0x8,%eax
  8017c2:	e8 7d fd ff ff       	call   801544 <fsipc>
}
  8017c7:	c9                   	leave  
  8017c8:	c3                   	ret    

008017c9 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8017c9:	55                   	push   %ebp
  8017ca:	89 e5                	mov    %esp,%ebp
  8017cc:	56                   	push   %esi
  8017cd:	53                   	push   %ebx
  8017ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8017d1:	83 ec 0c             	sub    $0xc,%esp
  8017d4:	ff 75 08             	pushl  0x8(%ebp)
  8017d7:	e8 c9 f7 ff ff       	call   800fa5 <fd2data>
  8017dc:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8017de:	83 c4 08             	add    $0x8,%esp
  8017e1:	68 0b 26 80 00       	push   $0x80260b
  8017e6:	53                   	push   %ebx
  8017e7:	e8 6d ef ff ff       	call   800759 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8017ec:	8b 46 04             	mov    0x4(%esi),%eax
  8017ef:	2b 06                	sub    (%esi),%eax
  8017f1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8017f7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017fe:	00 00 00 
	stat->st_dev = &devpipe;
  801801:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801808:	30 80 00 
	return 0;
}
  80180b:	b8 00 00 00 00       	mov    $0x0,%eax
  801810:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801813:	5b                   	pop    %ebx
  801814:	5e                   	pop    %esi
  801815:	5d                   	pop    %ebp
  801816:	c3                   	ret    

00801817 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801817:	55                   	push   %ebp
  801818:	89 e5                	mov    %esp,%ebp
  80181a:	53                   	push   %ebx
  80181b:	83 ec 0c             	sub    $0xc,%esp
  80181e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801821:	53                   	push   %ebx
  801822:	6a 00                	push   $0x0
  801824:	e8 b8 f3 ff ff       	call   800be1 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801829:	89 1c 24             	mov    %ebx,(%esp)
  80182c:	e8 74 f7 ff ff       	call   800fa5 <fd2data>
  801831:	83 c4 08             	add    $0x8,%esp
  801834:	50                   	push   %eax
  801835:	6a 00                	push   $0x0
  801837:	e8 a5 f3 ff ff       	call   800be1 <sys_page_unmap>
}
  80183c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80183f:	c9                   	leave  
  801840:	c3                   	ret    

00801841 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801841:	55                   	push   %ebp
  801842:	89 e5                	mov    %esp,%ebp
  801844:	57                   	push   %edi
  801845:	56                   	push   %esi
  801846:	53                   	push   %ebx
  801847:	83 ec 1c             	sub    $0x1c,%esp
  80184a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80184d:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80184f:	a1 04 40 80 00       	mov    0x804004,%eax
  801854:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801857:	83 ec 0c             	sub    $0xc,%esp
  80185a:	ff 75 e0             	pushl  -0x20(%ebp)
  80185d:	e8 f8 05 00 00       	call   801e5a <pageref>
  801862:	89 c3                	mov    %eax,%ebx
  801864:	89 3c 24             	mov    %edi,(%esp)
  801867:	e8 ee 05 00 00       	call   801e5a <pageref>
  80186c:	83 c4 10             	add    $0x10,%esp
  80186f:	39 c3                	cmp    %eax,%ebx
  801871:	0f 94 c1             	sete   %cl
  801874:	0f b6 c9             	movzbl %cl,%ecx
  801877:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80187a:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801880:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801883:	39 ce                	cmp    %ecx,%esi
  801885:	74 1b                	je     8018a2 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801887:	39 c3                	cmp    %eax,%ebx
  801889:	75 c4                	jne    80184f <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80188b:	8b 42 58             	mov    0x58(%edx),%eax
  80188e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801891:	50                   	push   %eax
  801892:	56                   	push   %esi
  801893:	68 12 26 80 00       	push   $0x802612
  801898:	e8 37 e9 ff ff       	call   8001d4 <cprintf>
  80189d:	83 c4 10             	add    $0x10,%esp
  8018a0:	eb ad                	jmp    80184f <_pipeisclosed+0xe>
	}
}
  8018a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018a8:	5b                   	pop    %ebx
  8018a9:	5e                   	pop    %esi
  8018aa:	5f                   	pop    %edi
  8018ab:	5d                   	pop    %ebp
  8018ac:	c3                   	ret    

008018ad <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8018ad:	55                   	push   %ebp
  8018ae:	89 e5                	mov    %esp,%ebp
  8018b0:	57                   	push   %edi
  8018b1:	56                   	push   %esi
  8018b2:	53                   	push   %ebx
  8018b3:	83 ec 28             	sub    $0x28,%esp
  8018b6:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8018b9:	56                   	push   %esi
  8018ba:	e8 e6 f6 ff ff       	call   800fa5 <fd2data>
  8018bf:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018c1:	83 c4 10             	add    $0x10,%esp
  8018c4:	bf 00 00 00 00       	mov    $0x0,%edi
  8018c9:	eb 4b                	jmp    801916 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8018cb:	89 da                	mov    %ebx,%edx
  8018cd:	89 f0                	mov    %esi,%eax
  8018cf:	e8 6d ff ff ff       	call   801841 <_pipeisclosed>
  8018d4:	85 c0                	test   %eax,%eax
  8018d6:	75 48                	jne    801920 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8018d8:	e8 60 f2 ff ff       	call   800b3d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8018dd:	8b 43 04             	mov    0x4(%ebx),%eax
  8018e0:	8b 0b                	mov    (%ebx),%ecx
  8018e2:	8d 51 20             	lea    0x20(%ecx),%edx
  8018e5:	39 d0                	cmp    %edx,%eax
  8018e7:	73 e2                	jae    8018cb <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8018e9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018ec:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8018f0:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8018f3:	89 c2                	mov    %eax,%edx
  8018f5:	c1 fa 1f             	sar    $0x1f,%edx
  8018f8:	89 d1                	mov    %edx,%ecx
  8018fa:	c1 e9 1b             	shr    $0x1b,%ecx
  8018fd:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801900:	83 e2 1f             	and    $0x1f,%edx
  801903:	29 ca                	sub    %ecx,%edx
  801905:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801909:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80190d:	83 c0 01             	add    $0x1,%eax
  801910:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801913:	83 c7 01             	add    $0x1,%edi
  801916:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801919:	75 c2                	jne    8018dd <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80191b:	8b 45 10             	mov    0x10(%ebp),%eax
  80191e:	eb 05                	jmp    801925 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801920:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801925:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801928:	5b                   	pop    %ebx
  801929:	5e                   	pop    %esi
  80192a:	5f                   	pop    %edi
  80192b:	5d                   	pop    %ebp
  80192c:	c3                   	ret    

0080192d <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80192d:	55                   	push   %ebp
  80192e:	89 e5                	mov    %esp,%ebp
  801930:	57                   	push   %edi
  801931:	56                   	push   %esi
  801932:	53                   	push   %ebx
  801933:	83 ec 18             	sub    $0x18,%esp
  801936:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801939:	57                   	push   %edi
  80193a:	e8 66 f6 ff ff       	call   800fa5 <fd2data>
  80193f:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801941:	83 c4 10             	add    $0x10,%esp
  801944:	bb 00 00 00 00       	mov    $0x0,%ebx
  801949:	eb 3d                	jmp    801988 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80194b:	85 db                	test   %ebx,%ebx
  80194d:	74 04                	je     801953 <devpipe_read+0x26>
				return i;
  80194f:	89 d8                	mov    %ebx,%eax
  801951:	eb 44                	jmp    801997 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801953:	89 f2                	mov    %esi,%edx
  801955:	89 f8                	mov    %edi,%eax
  801957:	e8 e5 fe ff ff       	call   801841 <_pipeisclosed>
  80195c:	85 c0                	test   %eax,%eax
  80195e:	75 32                	jne    801992 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801960:	e8 d8 f1 ff ff       	call   800b3d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801965:	8b 06                	mov    (%esi),%eax
  801967:	3b 46 04             	cmp    0x4(%esi),%eax
  80196a:	74 df                	je     80194b <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80196c:	99                   	cltd   
  80196d:	c1 ea 1b             	shr    $0x1b,%edx
  801970:	01 d0                	add    %edx,%eax
  801972:	83 e0 1f             	and    $0x1f,%eax
  801975:	29 d0                	sub    %edx,%eax
  801977:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80197c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80197f:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801982:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801985:	83 c3 01             	add    $0x1,%ebx
  801988:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80198b:	75 d8                	jne    801965 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80198d:	8b 45 10             	mov    0x10(%ebp),%eax
  801990:	eb 05                	jmp    801997 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801992:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801997:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80199a:	5b                   	pop    %ebx
  80199b:	5e                   	pop    %esi
  80199c:	5f                   	pop    %edi
  80199d:	5d                   	pop    %ebp
  80199e:	c3                   	ret    

0080199f <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80199f:	55                   	push   %ebp
  8019a0:	89 e5                	mov    %esp,%ebp
  8019a2:	56                   	push   %esi
  8019a3:	53                   	push   %ebx
  8019a4:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8019a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019aa:	50                   	push   %eax
  8019ab:	e8 0c f6 ff ff       	call   800fbc <fd_alloc>
  8019b0:	83 c4 10             	add    $0x10,%esp
  8019b3:	89 c2                	mov    %eax,%edx
  8019b5:	85 c0                	test   %eax,%eax
  8019b7:	0f 88 2c 01 00 00    	js     801ae9 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019bd:	83 ec 04             	sub    $0x4,%esp
  8019c0:	68 07 04 00 00       	push   $0x407
  8019c5:	ff 75 f4             	pushl  -0xc(%ebp)
  8019c8:	6a 00                	push   $0x0
  8019ca:	e8 8d f1 ff ff       	call   800b5c <sys_page_alloc>
  8019cf:	83 c4 10             	add    $0x10,%esp
  8019d2:	89 c2                	mov    %eax,%edx
  8019d4:	85 c0                	test   %eax,%eax
  8019d6:	0f 88 0d 01 00 00    	js     801ae9 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8019dc:	83 ec 0c             	sub    $0xc,%esp
  8019df:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019e2:	50                   	push   %eax
  8019e3:	e8 d4 f5 ff ff       	call   800fbc <fd_alloc>
  8019e8:	89 c3                	mov    %eax,%ebx
  8019ea:	83 c4 10             	add    $0x10,%esp
  8019ed:	85 c0                	test   %eax,%eax
  8019ef:	0f 88 e2 00 00 00    	js     801ad7 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019f5:	83 ec 04             	sub    $0x4,%esp
  8019f8:	68 07 04 00 00       	push   $0x407
  8019fd:	ff 75 f0             	pushl  -0x10(%ebp)
  801a00:	6a 00                	push   $0x0
  801a02:	e8 55 f1 ff ff       	call   800b5c <sys_page_alloc>
  801a07:	89 c3                	mov    %eax,%ebx
  801a09:	83 c4 10             	add    $0x10,%esp
  801a0c:	85 c0                	test   %eax,%eax
  801a0e:	0f 88 c3 00 00 00    	js     801ad7 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801a14:	83 ec 0c             	sub    $0xc,%esp
  801a17:	ff 75 f4             	pushl  -0xc(%ebp)
  801a1a:	e8 86 f5 ff ff       	call   800fa5 <fd2data>
  801a1f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a21:	83 c4 0c             	add    $0xc,%esp
  801a24:	68 07 04 00 00       	push   $0x407
  801a29:	50                   	push   %eax
  801a2a:	6a 00                	push   $0x0
  801a2c:	e8 2b f1 ff ff       	call   800b5c <sys_page_alloc>
  801a31:	89 c3                	mov    %eax,%ebx
  801a33:	83 c4 10             	add    $0x10,%esp
  801a36:	85 c0                	test   %eax,%eax
  801a38:	0f 88 89 00 00 00    	js     801ac7 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a3e:	83 ec 0c             	sub    $0xc,%esp
  801a41:	ff 75 f0             	pushl  -0x10(%ebp)
  801a44:	e8 5c f5 ff ff       	call   800fa5 <fd2data>
  801a49:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801a50:	50                   	push   %eax
  801a51:	6a 00                	push   $0x0
  801a53:	56                   	push   %esi
  801a54:	6a 00                	push   $0x0
  801a56:	e8 44 f1 ff ff       	call   800b9f <sys_page_map>
  801a5b:	89 c3                	mov    %eax,%ebx
  801a5d:	83 c4 20             	add    $0x20,%esp
  801a60:	85 c0                	test   %eax,%eax
  801a62:	78 55                	js     801ab9 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801a64:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a6d:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801a6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a72:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801a79:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a82:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801a84:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a87:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801a8e:	83 ec 0c             	sub    $0xc,%esp
  801a91:	ff 75 f4             	pushl  -0xc(%ebp)
  801a94:	e8 fc f4 ff ff       	call   800f95 <fd2num>
  801a99:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a9c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801a9e:	83 c4 04             	add    $0x4,%esp
  801aa1:	ff 75 f0             	pushl  -0x10(%ebp)
  801aa4:	e8 ec f4 ff ff       	call   800f95 <fd2num>
  801aa9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801aac:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801aaf:	83 c4 10             	add    $0x10,%esp
  801ab2:	ba 00 00 00 00       	mov    $0x0,%edx
  801ab7:	eb 30                	jmp    801ae9 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801ab9:	83 ec 08             	sub    $0x8,%esp
  801abc:	56                   	push   %esi
  801abd:	6a 00                	push   $0x0
  801abf:	e8 1d f1 ff ff       	call   800be1 <sys_page_unmap>
  801ac4:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801ac7:	83 ec 08             	sub    $0x8,%esp
  801aca:	ff 75 f0             	pushl  -0x10(%ebp)
  801acd:	6a 00                	push   $0x0
  801acf:	e8 0d f1 ff ff       	call   800be1 <sys_page_unmap>
  801ad4:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801ad7:	83 ec 08             	sub    $0x8,%esp
  801ada:	ff 75 f4             	pushl  -0xc(%ebp)
  801add:	6a 00                	push   $0x0
  801adf:	e8 fd f0 ff ff       	call   800be1 <sys_page_unmap>
  801ae4:	83 c4 10             	add    $0x10,%esp
  801ae7:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801ae9:	89 d0                	mov    %edx,%eax
  801aeb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aee:	5b                   	pop    %ebx
  801aef:	5e                   	pop    %esi
  801af0:	5d                   	pop    %ebp
  801af1:	c3                   	ret    

00801af2 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801af2:	55                   	push   %ebp
  801af3:	89 e5                	mov    %esp,%ebp
  801af5:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801af8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801afb:	50                   	push   %eax
  801afc:	ff 75 08             	pushl  0x8(%ebp)
  801aff:	e8 07 f5 ff ff       	call   80100b <fd_lookup>
  801b04:	83 c4 10             	add    $0x10,%esp
  801b07:	85 c0                	test   %eax,%eax
  801b09:	78 18                	js     801b23 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801b0b:	83 ec 0c             	sub    $0xc,%esp
  801b0e:	ff 75 f4             	pushl  -0xc(%ebp)
  801b11:	e8 8f f4 ff ff       	call   800fa5 <fd2data>
	return _pipeisclosed(fd, p);
  801b16:	89 c2                	mov    %eax,%edx
  801b18:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b1b:	e8 21 fd ff ff       	call   801841 <_pipeisclosed>
  801b20:	83 c4 10             	add    $0x10,%esp
}
  801b23:	c9                   	leave  
  801b24:	c3                   	ret    

00801b25 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801b25:	55                   	push   %ebp
  801b26:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801b28:	b8 00 00 00 00       	mov    $0x0,%eax
  801b2d:	5d                   	pop    %ebp
  801b2e:	c3                   	ret    

00801b2f <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801b2f:	55                   	push   %ebp
  801b30:	89 e5                	mov    %esp,%ebp
  801b32:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801b35:	68 2a 26 80 00       	push   $0x80262a
  801b3a:	ff 75 0c             	pushl  0xc(%ebp)
  801b3d:	e8 17 ec ff ff       	call   800759 <strcpy>
	return 0;
}
  801b42:	b8 00 00 00 00       	mov    $0x0,%eax
  801b47:	c9                   	leave  
  801b48:	c3                   	ret    

00801b49 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b49:	55                   	push   %ebp
  801b4a:	89 e5                	mov    %esp,%ebp
  801b4c:	57                   	push   %edi
  801b4d:	56                   	push   %esi
  801b4e:	53                   	push   %ebx
  801b4f:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b55:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801b5a:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b60:	eb 2d                	jmp    801b8f <devcons_write+0x46>
		m = n - tot;
  801b62:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801b65:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801b67:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801b6a:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801b6f:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801b72:	83 ec 04             	sub    $0x4,%esp
  801b75:	53                   	push   %ebx
  801b76:	03 45 0c             	add    0xc(%ebp),%eax
  801b79:	50                   	push   %eax
  801b7a:	57                   	push   %edi
  801b7b:	e8 6b ed ff ff       	call   8008eb <memmove>
		sys_cputs(buf, m);
  801b80:	83 c4 08             	add    $0x8,%esp
  801b83:	53                   	push   %ebx
  801b84:	57                   	push   %edi
  801b85:	e8 16 ef ff ff       	call   800aa0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b8a:	01 de                	add    %ebx,%esi
  801b8c:	83 c4 10             	add    $0x10,%esp
  801b8f:	89 f0                	mov    %esi,%eax
  801b91:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b94:	72 cc                	jb     801b62 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801b96:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b99:	5b                   	pop    %ebx
  801b9a:	5e                   	pop    %esi
  801b9b:	5f                   	pop    %edi
  801b9c:	5d                   	pop    %ebp
  801b9d:	c3                   	ret    

00801b9e <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b9e:	55                   	push   %ebp
  801b9f:	89 e5                	mov    %esp,%ebp
  801ba1:	83 ec 08             	sub    $0x8,%esp
  801ba4:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801ba9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801bad:	74 2a                	je     801bd9 <devcons_read+0x3b>
  801baf:	eb 05                	jmp    801bb6 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801bb1:	e8 87 ef ff ff       	call   800b3d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801bb6:	e8 03 ef ff ff       	call   800abe <sys_cgetc>
  801bbb:	85 c0                	test   %eax,%eax
  801bbd:	74 f2                	je     801bb1 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801bbf:	85 c0                	test   %eax,%eax
  801bc1:	78 16                	js     801bd9 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801bc3:	83 f8 04             	cmp    $0x4,%eax
  801bc6:	74 0c                	je     801bd4 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801bc8:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bcb:	88 02                	mov    %al,(%edx)
	return 1;
  801bcd:	b8 01 00 00 00       	mov    $0x1,%eax
  801bd2:	eb 05                	jmp    801bd9 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801bd4:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801bd9:	c9                   	leave  
  801bda:	c3                   	ret    

00801bdb <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801bdb:	55                   	push   %ebp
  801bdc:	89 e5                	mov    %esp,%ebp
  801bde:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801be1:	8b 45 08             	mov    0x8(%ebp),%eax
  801be4:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801be7:	6a 01                	push   $0x1
  801be9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801bec:	50                   	push   %eax
  801bed:	e8 ae ee ff ff       	call   800aa0 <sys_cputs>
}
  801bf2:	83 c4 10             	add    $0x10,%esp
  801bf5:	c9                   	leave  
  801bf6:	c3                   	ret    

00801bf7 <getchar>:

int
getchar(void)
{
  801bf7:	55                   	push   %ebp
  801bf8:	89 e5                	mov    %esp,%ebp
  801bfa:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801bfd:	6a 01                	push   $0x1
  801bff:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c02:	50                   	push   %eax
  801c03:	6a 00                	push   $0x0
  801c05:	e8 67 f6 ff ff       	call   801271 <read>
	if (r < 0)
  801c0a:	83 c4 10             	add    $0x10,%esp
  801c0d:	85 c0                	test   %eax,%eax
  801c0f:	78 0f                	js     801c20 <getchar+0x29>
		return r;
	if (r < 1)
  801c11:	85 c0                	test   %eax,%eax
  801c13:	7e 06                	jle    801c1b <getchar+0x24>
		return -E_EOF;
	return c;
  801c15:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801c19:	eb 05                	jmp    801c20 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801c1b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801c20:	c9                   	leave  
  801c21:	c3                   	ret    

00801c22 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801c22:	55                   	push   %ebp
  801c23:	89 e5                	mov    %esp,%ebp
  801c25:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c28:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c2b:	50                   	push   %eax
  801c2c:	ff 75 08             	pushl  0x8(%ebp)
  801c2f:	e8 d7 f3 ff ff       	call   80100b <fd_lookup>
  801c34:	83 c4 10             	add    $0x10,%esp
  801c37:	85 c0                	test   %eax,%eax
  801c39:	78 11                	js     801c4c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801c3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c3e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c44:	39 10                	cmp    %edx,(%eax)
  801c46:	0f 94 c0             	sete   %al
  801c49:	0f b6 c0             	movzbl %al,%eax
}
  801c4c:	c9                   	leave  
  801c4d:	c3                   	ret    

00801c4e <opencons>:

int
opencons(void)
{
  801c4e:	55                   	push   %ebp
  801c4f:	89 e5                	mov    %esp,%ebp
  801c51:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801c54:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c57:	50                   	push   %eax
  801c58:	e8 5f f3 ff ff       	call   800fbc <fd_alloc>
  801c5d:	83 c4 10             	add    $0x10,%esp
		return r;
  801c60:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801c62:	85 c0                	test   %eax,%eax
  801c64:	78 3e                	js     801ca4 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801c66:	83 ec 04             	sub    $0x4,%esp
  801c69:	68 07 04 00 00       	push   $0x407
  801c6e:	ff 75 f4             	pushl  -0xc(%ebp)
  801c71:	6a 00                	push   $0x0
  801c73:	e8 e4 ee ff ff       	call   800b5c <sys_page_alloc>
  801c78:	83 c4 10             	add    $0x10,%esp
		return r;
  801c7b:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801c7d:	85 c0                	test   %eax,%eax
  801c7f:	78 23                	js     801ca4 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801c81:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c87:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c8a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801c8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c8f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801c96:	83 ec 0c             	sub    $0xc,%esp
  801c99:	50                   	push   %eax
  801c9a:	e8 f6 f2 ff ff       	call   800f95 <fd2num>
  801c9f:	89 c2                	mov    %eax,%edx
  801ca1:	83 c4 10             	add    $0x10,%esp
}
  801ca4:	89 d0                	mov    %edx,%eax
  801ca6:	c9                   	leave  
  801ca7:	c3                   	ret    

00801ca8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801ca8:	55                   	push   %ebp
  801ca9:	89 e5                	mov    %esp,%ebp
  801cab:	56                   	push   %esi
  801cac:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801cad:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801cb0:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801cb6:	e8 63 ee ff ff       	call   800b1e <sys_getenvid>
  801cbb:	83 ec 0c             	sub    $0xc,%esp
  801cbe:	ff 75 0c             	pushl  0xc(%ebp)
  801cc1:	ff 75 08             	pushl  0x8(%ebp)
  801cc4:	56                   	push   %esi
  801cc5:	50                   	push   %eax
  801cc6:	68 38 26 80 00       	push   $0x802638
  801ccb:	e8 04 e5 ff ff       	call   8001d4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801cd0:	83 c4 18             	add    $0x18,%esp
  801cd3:	53                   	push   %ebx
  801cd4:	ff 75 10             	pushl  0x10(%ebp)
  801cd7:	e8 a7 e4 ff ff       	call   800183 <vcprintf>
	cprintf("\n");
  801cdc:	c7 04 24 4f 21 80 00 	movl   $0x80214f,(%esp)
  801ce3:	e8 ec e4 ff ff       	call   8001d4 <cprintf>
  801ce8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801ceb:	cc                   	int3   
  801cec:	eb fd                	jmp    801ceb <_panic+0x43>

00801cee <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801cee:	55                   	push   %ebp
  801cef:	89 e5                	mov    %esp,%ebp
  801cf1:	53                   	push   %ebx
  801cf2:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  801cf5:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801cfc:	75 28                	jne    801d26 <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  801cfe:	e8 1b ee ff ff       	call   800b1e <sys_getenvid>
  801d03:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_U | PTE_W);
  801d05:	83 ec 04             	sub    $0x4,%esp
  801d08:	6a 06                	push   $0x6
  801d0a:	68 00 f0 bf ee       	push   $0xeebff000
  801d0f:	50                   	push   %eax
  801d10:	e8 47 ee ff ff       	call   800b5c <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  801d15:	83 c4 08             	add    $0x8,%esp
  801d18:	68 33 1d 80 00       	push   $0x801d33
  801d1d:	53                   	push   %ebx
  801d1e:	e8 84 ef ff ff       	call   800ca7 <sys_env_set_pgfault_upcall>
  801d23:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801d26:	8b 45 08             	mov    0x8(%ebp),%eax
  801d29:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801d2e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d31:	c9                   	leave  
  801d32:	c3                   	ret    

00801d33 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801d33:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801d34:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801d39:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801d3b:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	# My method is different. Copy the values to the other stack
	# in a convinient way, and then pop everything.
	movl %esp, %ebp		# ebp refers to the exception stack
  801d3e:	89 e5                	mov    %esp,%ebp
	movl 48(%ebp), %esp 	# go to other stack
  801d40:	8b 65 30             	mov    0x30(%ebp),%esp

	pushl 40(%ebp)		# eip - ORDER SWITCHED WITH EFLAGS
  801d43:	ff 75 28             	pushl  0x28(%ebp)
	pushl 44(%ebp)      	# eflags
  801d46:	ff 75 2c             	pushl  0x2c(%ebp)
	pushl 36(%ebp)		# all the 8 remaining regs
  801d49:	ff 75 24             	pushl  0x24(%ebp)
	pushl 32(%ebp)
  801d4c:	ff 75 20             	pushl  0x20(%ebp)
	pushl 28(%ebp)
  801d4f:	ff 75 1c             	pushl  0x1c(%ebp)
	pushl 24(%ebp)
  801d52:	ff 75 18             	pushl  0x18(%ebp)
	pushl 20(%ebp)
  801d55:	ff 75 14             	pushl  0x14(%ebp)
	pushl 16(%ebp)
  801d58:	ff 75 10             	pushl  0x10(%ebp)
	pushl 12(%ebp)
  801d5b:	ff 75 0c             	pushl  0xc(%ebp)
	pushl 8(%ebp)
  801d5e:	ff 75 08             	pushl  0x8(%ebp)

	popal			# now just pop everything!
  801d61:	61                   	popa   
	popfl
  801d62:	9d                   	popf   
	ret
  801d63:	c3                   	ret    

00801d64 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801d64:	55                   	push   %ebp
  801d65:	89 e5                	mov    %esp,%ebp
  801d67:	56                   	push   %esi
  801d68:	53                   	push   %ebx
  801d69:	8b 75 08             	mov    0x8(%ebp),%esi
  801d6c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d6f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  801d72:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801d74:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801d79:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  801d7c:	83 ec 0c             	sub    $0xc,%esp
  801d7f:	50                   	push   %eax
  801d80:	e8 87 ef ff ff       	call   800d0c <sys_ipc_recv>

	if (r < 0) {
  801d85:	83 c4 10             	add    $0x10,%esp
  801d88:	85 c0                	test   %eax,%eax
  801d8a:	79 16                	jns    801da2 <ipc_recv+0x3e>
		if (from_env_store)
  801d8c:	85 f6                	test   %esi,%esi
  801d8e:	74 06                	je     801d96 <ipc_recv+0x32>
			*from_env_store = 0;
  801d90:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  801d96:	85 db                	test   %ebx,%ebx
  801d98:	74 2c                	je     801dc6 <ipc_recv+0x62>
			*perm_store = 0;
  801d9a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801da0:	eb 24                	jmp    801dc6 <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  801da2:	85 f6                	test   %esi,%esi
  801da4:	74 0a                	je     801db0 <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  801da6:	a1 04 40 80 00       	mov    0x804004,%eax
  801dab:	8b 40 74             	mov    0x74(%eax),%eax
  801dae:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  801db0:	85 db                	test   %ebx,%ebx
  801db2:	74 0a                	je     801dbe <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  801db4:	a1 04 40 80 00       	mov    0x804004,%eax
  801db9:	8b 40 78             	mov    0x78(%eax),%eax
  801dbc:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  801dbe:	a1 04 40 80 00       	mov    0x804004,%eax
  801dc3:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  801dc6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dc9:	5b                   	pop    %ebx
  801dca:	5e                   	pop    %esi
  801dcb:	5d                   	pop    %ebp
  801dcc:	c3                   	ret    

00801dcd <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801dcd:	55                   	push   %ebp
  801dce:	89 e5                	mov    %esp,%ebp
  801dd0:	57                   	push   %edi
  801dd1:	56                   	push   %esi
  801dd2:	53                   	push   %ebx
  801dd3:	83 ec 0c             	sub    $0xc,%esp
  801dd6:	8b 7d 08             	mov    0x8(%ebp),%edi
  801dd9:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ddc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  801ddf:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801de1:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801de6:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  801de9:	ff 75 14             	pushl  0x14(%ebp)
  801dec:	53                   	push   %ebx
  801ded:	56                   	push   %esi
  801dee:	57                   	push   %edi
  801def:	e8 f5 ee ff ff       	call   800ce9 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  801df4:	83 c4 10             	add    $0x10,%esp
  801df7:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801dfa:	75 07                	jne    801e03 <ipc_send+0x36>
			sys_yield();
  801dfc:	e8 3c ed ff ff       	call   800b3d <sys_yield>
  801e01:	eb e6                	jmp    801de9 <ipc_send+0x1c>
		} else if (r < 0) {
  801e03:	85 c0                	test   %eax,%eax
  801e05:	79 12                	jns    801e19 <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  801e07:	50                   	push   %eax
  801e08:	68 5c 26 80 00       	push   $0x80265c
  801e0d:	6a 51                	push   $0x51
  801e0f:	68 69 26 80 00       	push   $0x802669
  801e14:	e8 8f fe ff ff       	call   801ca8 <_panic>
		}
	}
}
  801e19:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e1c:	5b                   	pop    %ebx
  801e1d:	5e                   	pop    %esi
  801e1e:	5f                   	pop    %edi
  801e1f:	5d                   	pop    %ebp
  801e20:	c3                   	ret    

00801e21 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801e21:	55                   	push   %ebp
  801e22:	89 e5                	mov    %esp,%ebp
  801e24:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801e27:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801e2c:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801e2f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801e35:	8b 52 50             	mov    0x50(%edx),%edx
  801e38:	39 ca                	cmp    %ecx,%edx
  801e3a:	75 0d                	jne    801e49 <ipc_find_env+0x28>
			return envs[i].env_id;
  801e3c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801e3f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801e44:	8b 40 48             	mov    0x48(%eax),%eax
  801e47:	eb 0f                	jmp    801e58 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801e49:	83 c0 01             	add    $0x1,%eax
  801e4c:	3d 00 04 00 00       	cmp    $0x400,%eax
  801e51:	75 d9                	jne    801e2c <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801e53:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e58:	5d                   	pop    %ebp
  801e59:	c3                   	ret    

00801e5a <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801e5a:	55                   	push   %ebp
  801e5b:	89 e5                	mov    %esp,%ebp
  801e5d:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e60:	89 d0                	mov    %edx,%eax
  801e62:	c1 e8 16             	shr    $0x16,%eax
  801e65:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801e6c:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e71:	f6 c1 01             	test   $0x1,%cl
  801e74:	74 1d                	je     801e93 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801e76:	c1 ea 0c             	shr    $0xc,%edx
  801e79:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801e80:	f6 c2 01             	test   $0x1,%dl
  801e83:	74 0e                	je     801e93 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801e85:	c1 ea 0c             	shr    $0xc,%edx
  801e88:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801e8f:	ef 
  801e90:	0f b7 c0             	movzwl %ax,%eax
}
  801e93:	5d                   	pop    %ebp
  801e94:	c3                   	ret    
  801e95:	66 90                	xchg   %ax,%ax
  801e97:	66 90                	xchg   %ax,%ax
  801e99:	66 90                	xchg   %ax,%ax
  801e9b:	66 90                	xchg   %ax,%ax
  801e9d:	66 90                	xchg   %ax,%ax
  801e9f:	90                   	nop

00801ea0 <__udivdi3>:
  801ea0:	55                   	push   %ebp
  801ea1:	57                   	push   %edi
  801ea2:	56                   	push   %esi
  801ea3:	53                   	push   %ebx
  801ea4:	83 ec 1c             	sub    $0x1c,%esp
  801ea7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801eab:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801eaf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801eb3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801eb7:	85 f6                	test   %esi,%esi
  801eb9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ebd:	89 ca                	mov    %ecx,%edx
  801ebf:	89 f8                	mov    %edi,%eax
  801ec1:	75 3d                	jne    801f00 <__udivdi3+0x60>
  801ec3:	39 cf                	cmp    %ecx,%edi
  801ec5:	0f 87 c5 00 00 00    	ja     801f90 <__udivdi3+0xf0>
  801ecb:	85 ff                	test   %edi,%edi
  801ecd:	89 fd                	mov    %edi,%ebp
  801ecf:	75 0b                	jne    801edc <__udivdi3+0x3c>
  801ed1:	b8 01 00 00 00       	mov    $0x1,%eax
  801ed6:	31 d2                	xor    %edx,%edx
  801ed8:	f7 f7                	div    %edi
  801eda:	89 c5                	mov    %eax,%ebp
  801edc:	89 c8                	mov    %ecx,%eax
  801ede:	31 d2                	xor    %edx,%edx
  801ee0:	f7 f5                	div    %ebp
  801ee2:	89 c1                	mov    %eax,%ecx
  801ee4:	89 d8                	mov    %ebx,%eax
  801ee6:	89 cf                	mov    %ecx,%edi
  801ee8:	f7 f5                	div    %ebp
  801eea:	89 c3                	mov    %eax,%ebx
  801eec:	89 d8                	mov    %ebx,%eax
  801eee:	89 fa                	mov    %edi,%edx
  801ef0:	83 c4 1c             	add    $0x1c,%esp
  801ef3:	5b                   	pop    %ebx
  801ef4:	5e                   	pop    %esi
  801ef5:	5f                   	pop    %edi
  801ef6:	5d                   	pop    %ebp
  801ef7:	c3                   	ret    
  801ef8:	90                   	nop
  801ef9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f00:	39 ce                	cmp    %ecx,%esi
  801f02:	77 74                	ja     801f78 <__udivdi3+0xd8>
  801f04:	0f bd fe             	bsr    %esi,%edi
  801f07:	83 f7 1f             	xor    $0x1f,%edi
  801f0a:	0f 84 98 00 00 00    	je     801fa8 <__udivdi3+0x108>
  801f10:	bb 20 00 00 00       	mov    $0x20,%ebx
  801f15:	89 f9                	mov    %edi,%ecx
  801f17:	89 c5                	mov    %eax,%ebp
  801f19:	29 fb                	sub    %edi,%ebx
  801f1b:	d3 e6                	shl    %cl,%esi
  801f1d:	89 d9                	mov    %ebx,%ecx
  801f1f:	d3 ed                	shr    %cl,%ebp
  801f21:	89 f9                	mov    %edi,%ecx
  801f23:	d3 e0                	shl    %cl,%eax
  801f25:	09 ee                	or     %ebp,%esi
  801f27:	89 d9                	mov    %ebx,%ecx
  801f29:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f2d:	89 d5                	mov    %edx,%ebp
  801f2f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801f33:	d3 ed                	shr    %cl,%ebp
  801f35:	89 f9                	mov    %edi,%ecx
  801f37:	d3 e2                	shl    %cl,%edx
  801f39:	89 d9                	mov    %ebx,%ecx
  801f3b:	d3 e8                	shr    %cl,%eax
  801f3d:	09 c2                	or     %eax,%edx
  801f3f:	89 d0                	mov    %edx,%eax
  801f41:	89 ea                	mov    %ebp,%edx
  801f43:	f7 f6                	div    %esi
  801f45:	89 d5                	mov    %edx,%ebp
  801f47:	89 c3                	mov    %eax,%ebx
  801f49:	f7 64 24 0c          	mull   0xc(%esp)
  801f4d:	39 d5                	cmp    %edx,%ebp
  801f4f:	72 10                	jb     801f61 <__udivdi3+0xc1>
  801f51:	8b 74 24 08          	mov    0x8(%esp),%esi
  801f55:	89 f9                	mov    %edi,%ecx
  801f57:	d3 e6                	shl    %cl,%esi
  801f59:	39 c6                	cmp    %eax,%esi
  801f5b:	73 07                	jae    801f64 <__udivdi3+0xc4>
  801f5d:	39 d5                	cmp    %edx,%ebp
  801f5f:	75 03                	jne    801f64 <__udivdi3+0xc4>
  801f61:	83 eb 01             	sub    $0x1,%ebx
  801f64:	31 ff                	xor    %edi,%edi
  801f66:	89 d8                	mov    %ebx,%eax
  801f68:	89 fa                	mov    %edi,%edx
  801f6a:	83 c4 1c             	add    $0x1c,%esp
  801f6d:	5b                   	pop    %ebx
  801f6e:	5e                   	pop    %esi
  801f6f:	5f                   	pop    %edi
  801f70:	5d                   	pop    %ebp
  801f71:	c3                   	ret    
  801f72:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801f78:	31 ff                	xor    %edi,%edi
  801f7a:	31 db                	xor    %ebx,%ebx
  801f7c:	89 d8                	mov    %ebx,%eax
  801f7e:	89 fa                	mov    %edi,%edx
  801f80:	83 c4 1c             	add    $0x1c,%esp
  801f83:	5b                   	pop    %ebx
  801f84:	5e                   	pop    %esi
  801f85:	5f                   	pop    %edi
  801f86:	5d                   	pop    %ebp
  801f87:	c3                   	ret    
  801f88:	90                   	nop
  801f89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f90:	89 d8                	mov    %ebx,%eax
  801f92:	f7 f7                	div    %edi
  801f94:	31 ff                	xor    %edi,%edi
  801f96:	89 c3                	mov    %eax,%ebx
  801f98:	89 d8                	mov    %ebx,%eax
  801f9a:	89 fa                	mov    %edi,%edx
  801f9c:	83 c4 1c             	add    $0x1c,%esp
  801f9f:	5b                   	pop    %ebx
  801fa0:	5e                   	pop    %esi
  801fa1:	5f                   	pop    %edi
  801fa2:	5d                   	pop    %ebp
  801fa3:	c3                   	ret    
  801fa4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801fa8:	39 ce                	cmp    %ecx,%esi
  801faa:	72 0c                	jb     801fb8 <__udivdi3+0x118>
  801fac:	31 db                	xor    %ebx,%ebx
  801fae:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801fb2:	0f 87 34 ff ff ff    	ja     801eec <__udivdi3+0x4c>
  801fb8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801fbd:	e9 2a ff ff ff       	jmp    801eec <__udivdi3+0x4c>
  801fc2:	66 90                	xchg   %ax,%ax
  801fc4:	66 90                	xchg   %ax,%ax
  801fc6:	66 90                	xchg   %ax,%ax
  801fc8:	66 90                	xchg   %ax,%ax
  801fca:	66 90                	xchg   %ax,%ax
  801fcc:	66 90                	xchg   %ax,%ax
  801fce:	66 90                	xchg   %ax,%ax

00801fd0 <__umoddi3>:
  801fd0:	55                   	push   %ebp
  801fd1:	57                   	push   %edi
  801fd2:	56                   	push   %esi
  801fd3:	53                   	push   %ebx
  801fd4:	83 ec 1c             	sub    $0x1c,%esp
  801fd7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801fdb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801fdf:	8b 74 24 34          	mov    0x34(%esp),%esi
  801fe3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801fe7:	85 d2                	test   %edx,%edx
  801fe9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801fed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ff1:	89 f3                	mov    %esi,%ebx
  801ff3:	89 3c 24             	mov    %edi,(%esp)
  801ff6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ffa:	75 1c                	jne    802018 <__umoddi3+0x48>
  801ffc:	39 f7                	cmp    %esi,%edi
  801ffe:	76 50                	jbe    802050 <__umoddi3+0x80>
  802000:	89 c8                	mov    %ecx,%eax
  802002:	89 f2                	mov    %esi,%edx
  802004:	f7 f7                	div    %edi
  802006:	89 d0                	mov    %edx,%eax
  802008:	31 d2                	xor    %edx,%edx
  80200a:	83 c4 1c             	add    $0x1c,%esp
  80200d:	5b                   	pop    %ebx
  80200e:	5e                   	pop    %esi
  80200f:	5f                   	pop    %edi
  802010:	5d                   	pop    %ebp
  802011:	c3                   	ret    
  802012:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802018:	39 f2                	cmp    %esi,%edx
  80201a:	89 d0                	mov    %edx,%eax
  80201c:	77 52                	ja     802070 <__umoddi3+0xa0>
  80201e:	0f bd ea             	bsr    %edx,%ebp
  802021:	83 f5 1f             	xor    $0x1f,%ebp
  802024:	75 5a                	jne    802080 <__umoddi3+0xb0>
  802026:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80202a:	0f 82 e0 00 00 00    	jb     802110 <__umoddi3+0x140>
  802030:	39 0c 24             	cmp    %ecx,(%esp)
  802033:	0f 86 d7 00 00 00    	jbe    802110 <__umoddi3+0x140>
  802039:	8b 44 24 08          	mov    0x8(%esp),%eax
  80203d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802041:	83 c4 1c             	add    $0x1c,%esp
  802044:	5b                   	pop    %ebx
  802045:	5e                   	pop    %esi
  802046:	5f                   	pop    %edi
  802047:	5d                   	pop    %ebp
  802048:	c3                   	ret    
  802049:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802050:	85 ff                	test   %edi,%edi
  802052:	89 fd                	mov    %edi,%ebp
  802054:	75 0b                	jne    802061 <__umoddi3+0x91>
  802056:	b8 01 00 00 00       	mov    $0x1,%eax
  80205b:	31 d2                	xor    %edx,%edx
  80205d:	f7 f7                	div    %edi
  80205f:	89 c5                	mov    %eax,%ebp
  802061:	89 f0                	mov    %esi,%eax
  802063:	31 d2                	xor    %edx,%edx
  802065:	f7 f5                	div    %ebp
  802067:	89 c8                	mov    %ecx,%eax
  802069:	f7 f5                	div    %ebp
  80206b:	89 d0                	mov    %edx,%eax
  80206d:	eb 99                	jmp    802008 <__umoddi3+0x38>
  80206f:	90                   	nop
  802070:	89 c8                	mov    %ecx,%eax
  802072:	89 f2                	mov    %esi,%edx
  802074:	83 c4 1c             	add    $0x1c,%esp
  802077:	5b                   	pop    %ebx
  802078:	5e                   	pop    %esi
  802079:	5f                   	pop    %edi
  80207a:	5d                   	pop    %ebp
  80207b:	c3                   	ret    
  80207c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802080:	8b 34 24             	mov    (%esp),%esi
  802083:	bf 20 00 00 00       	mov    $0x20,%edi
  802088:	89 e9                	mov    %ebp,%ecx
  80208a:	29 ef                	sub    %ebp,%edi
  80208c:	d3 e0                	shl    %cl,%eax
  80208e:	89 f9                	mov    %edi,%ecx
  802090:	89 f2                	mov    %esi,%edx
  802092:	d3 ea                	shr    %cl,%edx
  802094:	89 e9                	mov    %ebp,%ecx
  802096:	09 c2                	or     %eax,%edx
  802098:	89 d8                	mov    %ebx,%eax
  80209a:	89 14 24             	mov    %edx,(%esp)
  80209d:	89 f2                	mov    %esi,%edx
  80209f:	d3 e2                	shl    %cl,%edx
  8020a1:	89 f9                	mov    %edi,%ecx
  8020a3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8020a7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8020ab:	d3 e8                	shr    %cl,%eax
  8020ad:	89 e9                	mov    %ebp,%ecx
  8020af:	89 c6                	mov    %eax,%esi
  8020b1:	d3 e3                	shl    %cl,%ebx
  8020b3:	89 f9                	mov    %edi,%ecx
  8020b5:	89 d0                	mov    %edx,%eax
  8020b7:	d3 e8                	shr    %cl,%eax
  8020b9:	89 e9                	mov    %ebp,%ecx
  8020bb:	09 d8                	or     %ebx,%eax
  8020bd:	89 d3                	mov    %edx,%ebx
  8020bf:	89 f2                	mov    %esi,%edx
  8020c1:	f7 34 24             	divl   (%esp)
  8020c4:	89 d6                	mov    %edx,%esi
  8020c6:	d3 e3                	shl    %cl,%ebx
  8020c8:	f7 64 24 04          	mull   0x4(%esp)
  8020cc:	39 d6                	cmp    %edx,%esi
  8020ce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020d2:	89 d1                	mov    %edx,%ecx
  8020d4:	89 c3                	mov    %eax,%ebx
  8020d6:	72 08                	jb     8020e0 <__umoddi3+0x110>
  8020d8:	75 11                	jne    8020eb <__umoddi3+0x11b>
  8020da:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8020de:	73 0b                	jae    8020eb <__umoddi3+0x11b>
  8020e0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8020e4:	1b 14 24             	sbb    (%esp),%edx
  8020e7:	89 d1                	mov    %edx,%ecx
  8020e9:	89 c3                	mov    %eax,%ebx
  8020eb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8020ef:	29 da                	sub    %ebx,%edx
  8020f1:	19 ce                	sbb    %ecx,%esi
  8020f3:	89 f9                	mov    %edi,%ecx
  8020f5:	89 f0                	mov    %esi,%eax
  8020f7:	d3 e0                	shl    %cl,%eax
  8020f9:	89 e9                	mov    %ebp,%ecx
  8020fb:	d3 ea                	shr    %cl,%edx
  8020fd:	89 e9                	mov    %ebp,%ecx
  8020ff:	d3 ee                	shr    %cl,%esi
  802101:	09 d0                	or     %edx,%eax
  802103:	89 f2                	mov    %esi,%edx
  802105:	83 c4 1c             	add    $0x1c,%esp
  802108:	5b                   	pop    %ebx
  802109:	5e                   	pop    %esi
  80210a:	5f                   	pop    %edi
  80210b:	5d                   	pop    %ebp
  80210c:	c3                   	ret    
  80210d:	8d 76 00             	lea    0x0(%esi),%esi
  802110:	29 f9                	sub    %edi,%ecx
  802112:	19 d6                	sbb    %edx,%esi
  802114:	89 74 24 04          	mov    %esi,0x4(%esp)
  802118:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80211c:	e9 18 ff ff ff       	jmp    802039 <__umoddi3+0x69>
