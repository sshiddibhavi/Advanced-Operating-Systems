
obj/user/lsfd.debug:     file format elf32-i386


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
  80002c:	e8 dc 00 00 00       	call   80010d <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <usage>:
#include <inc/lib.h>

void
usage(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	cprintf("usage: lsfd [-1]\n");
  800039:	68 80 25 80 00       	push   $0x802580
  80003e:	e8 bd 01 00 00       	call   800200 <cprintf>
	exit();
  800043:	e8 0b 01 00 00       	call   800153 <exit>
}
  800048:	83 c4 10             	add    $0x10,%esp
  80004b:	c9                   	leave  
  80004c:	c3                   	ret    

0080004d <umain>:

void
umain(int argc, char **argv)
{
  80004d:	55                   	push   %ebp
  80004e:	89 e5                	mov    %esp,%ebp
  800050:	57                   	push   %edi
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	81 ec b0 00 00 00    	sub    $0xb0,%esp
	int i, usefprint = 0;
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
  800059:	8d 85 4c ff ff ff    	lea    -0xb4(%ebp),%eax
  80005f:	50                   	push   %eax
  800060:	ff 75 0c             	pushl  0xc(%ebp)
  800063:	8d 45 08             	lea    0x8(%ebp),%eax
  800066:	50                   	push   %eax
  800067:	e8 2c 0d 00 00       	call   800d98 <argstart>
	while ((i = argnext(&args)) >= 0)
  80006c:	83 c4 10             	add    $0x10,%esp
}

void
umain(int argc, char **argv)
{
	int i, usefprint = 0;
  80006f:	be 00 00 00 00       	mov    $0x0,%esi
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
  800074:	8d 9d 4c ff ff ff    	lea    -0xb4(%ebp),%ebx
  80007a:	eb 11                	jmp    80008d <umain+0x40>
		if (i == '1')
  80007c:	83 f8 31             	cmp    $0x31,%eax
  80007f:	74 07                	je     800088 <umain+0x3b>
			usefprint = 1;
		else
			usage();
  800081:	e8 ad ff ff ff       	call   800033 <usage>
  800086:	eb 05                	jmp    80008d <umain+0x40>
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
		if (i == '1')
			usefprint = 1;
  800088:	be 01 00 00 00       	mov    $0x1,%esi
	int i, usefprint = 0;
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
  80008d:	83 ec 0c             	sub    $0xc,%esp
  800090:	53                   	push   %ebx
  800091:	e8 32 0d 00 00       	call   800dc8 <argnext>
  800096:	83 c4 10             	add    $0x10,%esp
  800099:	85 c0                	test   %eax,%eax
  80009b:	79 df                	jns    80007c <umain+0x2f>
  80009d:	bb 00 00 00 00       	mov    $0x0,%ebx
			usefprint = 1;
		else
			usage();

	for (i = 0; i < 32; i++)
		if (fstat(i, &st) >= 0) {
  8000a2:	8d bd 5c ff ff ff    	lea    -0xa4(%ebp),%edi
  8000a8:	83 ec 08             	sub    $0x8,%esp
  8000ab:	57                   	push   %edi
  8000ac:	53                   	push   %ebx
  8000ad:	e8 2e 13 00 00       	call   8013e0 <fstat>
  8000b2:	83 c4 10             	add    $0x10,%esp
  8000b5:	85 c0                	test   %eax,%eax
  8000b7:	78 44                	js     8000fd <umain+0xb0>
			if (usefprint)
  8000b9:	85 f6                	test   %esi,%esi
  8000bb:	74 22                	je     8000df <umain+0x92>
				fprintf(1, "fd %d: name %s isdir %d size %d dev %s\n",
  8000bd:	83 ec 04             	sub    $0x4,%esp
  8000c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000c3:	ff 70 04             	pushl  0x4(%eax)
  8000c6:	ff 75 dc             	pushl  -0x24(%ebp)
  8000c9:	ff 75 e0             	pushl  -0x20(%ebp)
  8000cc:	57                   	push   %edi
  8000cd:	53                   	push   %ebx
  8000ce:	68 94 25 80 00       	push   $0x802594
  8000d3:	6a 01                	push   $0x1
  8000d5:	e8 29 17 00 00       	call   801803 <fprintf>
  8000da:	83 c4 20             	add    $0x20,%esp
  8000dd:	eb 1e                	jmp    8000fd <umain+0xb0>
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
			else
				cprintf("fd %d: name %s isdir %d size %d dev %s\n",
  8000df:	83 ec 08             	sub    $0x8,%esp
  8000e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000e5:	ff 70 04             	pushl  0x4(%eax)
  8000e8:	ff 75 dc             	pushl  -0x24(%ebp)
  8000eb:	ff 75 e0             	pushl  -0x20(%ebp)
  8000ee:	57                   	push   %edi
  8000ef:	53                   	push   %ebx
  8000f0:	68 94 25 80 00       	push   $0x802594
  8000f5:	e8 06 01 00 00       	call   800200 <cprintf>
  8000fa:	83 c4 20             	add    $0x20,%esp
		if (i == '1')
			usefprint = 1;
		else
			usage();

	for (i = 0; i < 32; i++)
  8000fd:	83 c3 01             	add    $0x1,%ebx
  800100:	83 fb 20             	cmp    $0x20,%ebx
  800103:	75 a3                	jne    8000a8 <umain+0x5b>
			else
				cprintf("fd %d: name %s isdir %d size %d dev %s\n",
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
		}
}
  800105:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800108:	5b                   	pop    %ebx
  800109:	5e                   	pop    %esi
  80010a:	5f                   	pop    %edi
  80010b:	5d                   	pop    %ebp
  80010c:	c3                   	ret    

0080010d <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80010d:	55                   	push   %ebp
  80010e:	89 e5                	mov    %esp,%ebp
  800110:	56                   	push   %esi
  800111:	53                   	push   %ebx
  800112:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800115:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800118:	e8 2d 0a 00 00       	call   800b4a <sys_getenvid>
  80011d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800122:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800125:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80012a:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80012f:	85 db                	test   %ebx,%ebx
  800131:	7e 07                	jle    80013a <libmain+0x2d>
		binaryname = argv[0];
  800133:	8b 06                	mov    (%esi),%eax
  800135:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80013a:	83 ec 08             	sub    $0x8,%esp
  80013d:	56                   	push   %esi
  80013e:	53                   	push   %ebx
  80013f:	e8 09 ff ff ff       	call   80004d <umain>

	// exit gracefully
	exit();
  800144:	e8 0a 00 00 00       	call   800153 <exit>
}
  800149:	83 c4 10             	add    $0x10,%esp
  80014c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80014f:	5b                   	pop    %ebx
  800150:	5e                   	pop    %esi
  800151:	5d                   	pop    %ebp
  800152:	c3                   	ret    

00800153 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800153:	55                   	push   %ebp
  800154:	89 e5                	mov    %esp,%ebp
  800156:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800159:	e8 59 0f 00 00       	call   8010b7 <close_all>
	sys_env_destroy(0);
  80015e:	83 ec 0c             	sub    $0xc,%esp
  800161:	6a 00                	push   $0x0
  800163:	e8 a1 09 00 00       	call   800b09 <sys_env_destroy>
}
  800168:	83 c4 10             	add    $0x10,%esp
  80016b:	c9                   	leave  
  80016c:	c3                   	ret    

0080016d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80016d:	55                   	push   %ebp
  80016e:	89 e5                	mov    %esp,%ebp
  800170:	53                   	push   %ebx
  800171:	83 ec 04             	sub    $0x4,%esp
  800174:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800177:	8b 13                	mov    (%ebx),%edx
  800179:	8d 42 01             	lea    0x1(%edx),%eax
  80017c:	89 03                	mov    %eax,(%ebx)
  80017e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800181:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800185:	3d ff 00 00 00       	cmp    $0xff,%eax
  80018a:	75 1a                	jne    8001a6 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80018c:	83 ec 08             	sub    $0x8,%esp
  80018f:	68 ff 00 00 00       	push   $0xff
  800194:	8d 43 08             	lea    0x8(%ebx),%eax
  800197:	50                   	push   %eax
  800198:	e8 2f 09 00 00       	call   800acc <sys_cputs>
		b->idx = 0;
  80019d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001a3:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001a6:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001ad:	c9                   	leave  
  8001ae:	c3                   	ret    

008001af <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001af:	55                   	push   %ebp
  8001b0:	89 e5                	mov    %esp,%ebp
  8001b2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001b8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001bf:	00 00 00 
	b.cnt = 0;
  8001c2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001c9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001cc:	ff 75 0c             	pushl  0xc(%ebp)
  8001cf:	ff 75 08             	pushl  0x8(%ebp)
  8001d2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001d8:	50                   	push   %eax
  8001d9:	68 6d 01 80 00       	push   $0x80016d
  8001de:	e8 54 01 00 00       	call   800337 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001e3:	83 c4 08             	add    $0x8,%esp
  8001e6:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001ec:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001f2:	50                   	push   %eax
  8001f3:	e8 d4 08 00 00       	call   800acc <sys_cputs>

	return b.cnt;
}
  8001f8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001fe:	c9                   	leave  
  8001ff:	c3                   	ret    

00800200 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800200:	55                   	push   %ebp
  800201:	89 e5                	mov    %esp,%ebp
  800203:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800206:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800209:	50                   	push   %eax
  80020a:	ff 75 08             	pushl  0x8(%ebp)
  80020d:	e8 9d ff ff ff       	call   8001af <vcprintf>
	va_end(ap);

	return cnt;
}
  800212:	c9                   	leave  
  800213:	c3                   	ret    

00800214 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
  800217:	57                   	push   %edi
  800218:	56                   	push   %esi
  800219:	53                   	push   %ebx
  80021a:	83 ec 1c             	sub    $0x1c,%esp
  80021d:	89 c7                	mov    %eax,%edi
  80021f:	89 d6                	mov    %edx,%esi
  800221:	8b 45 08             	mov    0x8(%ebp),%eax
  800224:	8b 55 0c             	mov    0xc(%ebp),%edx
  800227:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80022a:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80022d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800230:	bb 00 00 00 00       	mov    $0x0,%ebx
  800235:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800238:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80023b:	39 d3                	cmp    %edx,%ebx
  80023d:	72 05                	jb     800244 <printnum+0x30>
  80023f:	39 45 10             	cmp    %eax,0x10(%ebp)
  800242:	77 45                	ja     800289 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800244:	83 ec 0c             	sub    $0xc,%esp
  800247:	ff 75 18             	pushl  0x18(%ebp)
  80024a:	8b 45 14             	mov    0x14(%ebp),%eax
  80024d:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800250:	53                   	push   %ebx
  800251:	ff 75 10             	pushl  0x10(%ebp)
  800254:	83 ec 08             	sub    $0x8,%esp
  800257:	ff 75 e4             	pushl  -0x1c(%ebp)
  80025a:	ff 75 e0             	pushl  -0x20(%ebp)
  80025d:	ff 75 dc             	pushl  -0x24(%ebp)
  800260:	ff 75 d8             	pushl  -0x28(%ebp)
  800263:	e8 88 20 00 00       	call   8022f0 <__udivdi3>
  800268:	83 c4 18             	add    $0x18,%esp
  80026b:	52                   	push   %edx
  80026c:	50                   	push   %eax
  80026d:	89 f2                	mov    %esi,%edx
  80026f:	89 f8                	mov    %edi,%eax
  800271:	e8 9e ff ff ff       	call   800214 <printnum>
  800276:	83 c4 20             	add    $0x20,%esp
  800279:	eb 18                	jmp    800293 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80027b:	83 ec 08             	sub    $0x8,%esp
  80027e:	56                   	push   %esi
  80027f:	ff 75 18             	pushl  0x18(%ebp)
  800282:	ff d7                	call   *%edi
  800284:	83 c4 10             	add    $0x10,%esp
  800287:	eb 03                	jmp    80028c <printnum+0x78>
  800289:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80028c:	83 eb 01             	sub    $0x1,%ebx
  80028f:	85 db                	test   %ebx,%ebx
  800291:	7f e8                	jg     80027b <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800293:	83 ec 08             	sub    $0x8,%esp
  800296:	56                   	push   %esi
  800297:	83 ec 04             	sub    $0x4,%esp
  80029a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80029d:	ff 75 e0             	pushl  -0x20(%ebp)
  8002a0:	ff 75 dc             	pushl  -0x24(%ebp)
  8002a3:	ff 75 d8             	pushl  -0x28(%ebp)
  8002a6:	e8 75 21 00 00       	call   802420 <__umoddi3>
  8002ab:	83 c4 14             	add    $0x14,%esp
  8002ae:	0f be 80 c6 25 80 00 	movsbl 0x8025c6(%eax),%eax
  8002b5:	50                   	push   %eax
  8002b6:	ff d7                	call   *%edi
}
  8002b8:	83 c4 10             	add    $0x10,%esp
  8002bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002be:	5b                   	pop    %ebx
  8002bf:	5e                   	pop    %esi
  8002c0:	5f                   	pop    %edi
  8002c1:	5d                   	pop    %ebp
  8002c2:	c3                   	ret    

008002c3 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002c3:	55                   	push   %ebp
  8002c4:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002c6:	83 fa 01             	cmp    $0x1,%edx
  8002c9:	7e 0e                	jle    8002d9 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002cb:	8b 10                	mov    (%eax),%edx
  8002cd:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002d0:	89 08                	mov    %ecx,(%eax)
  8002d2:	8b 02                	mov    (%edx),%eax
  8002d4:	8b 52 04             	mov    0x4(%edx),%edx
  8002d7:	eb 22                	jmp    8002fb <getuint+0x38>
	else if (lflag)
  8002d9:	85 d2                	test   %edx,%edx
  8002db:	74 10                	je     8002ed <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002dd:	8b 10                	mov    (%eax),%edx
  8002df:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e2:	89 08                	mov    %ecx,(%eax)
  8002e4:	8b 02                	mov    (%edx),%eax
  8002e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8002eb:	eb 0e                	jmp    8002fb <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002ed:	8b 10                	mov    (%eax),%edx
  8002ef:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f2:	89 08                	mov    %ecx,(%eax)
  8002f4:	8b 02                	mov    (%edx),%eax
  8002f6:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002fb:	5d                   	pop    %ebp
  8002fc:	c3                   	ret    

008002fd <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002fd:	55                   	push   %ebp
  8002fe:	89 e5                	mov    %esp,%ebp
  800300:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800303:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800307:	8b 10                	mov    (%eax),%edx
  800309:	3b 50 04             	cmp    0x4(%eax),%edx
  80030c:	73 0a                	jae    800318 <sprintputch+0x1b>
		*b->buf++ = ch;
  80030e:	8d 4a 01             	lea    0x1(%edx),%ecx
  800311:	89 08                	mov    %ecx,(%eax)
  800313:	8b 45 08             	mov    0x8(%ebp),%eax
  800316:	88 02                	mov    %al,(%edx)
}
  800318:	5d                   	pop    %ebp
  800319:	c3                   	ret    

0080031a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80031a:	55                   	push   %ebp
  80031b:	89 e5                	mov    %esp,%ebp
  80031d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800320:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800323:	50                   	push   %eax
  800324:	ff 75 10             	pushl  0x10(%ebp)
  800327:	ff 75 0c             	pushl  0xc(%ebp)
  80032a:	ff 75 08             	pushl  0x8(%ebp)
  80032d:	e8 05 00 00 00       	call   800337 <vprintfmt>
	va_end(ap);
}
  800332:	83 c4 10             	add    $0x10,%esp
  800335:	c9                   	leave  
  800336:	c3                   	ret    

00800337 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800337:	55                   	push   %ebp
  800338:	89 e5                	mov    %esp,%ebp
  80033a:	57                   	push   %edi
  80033b:	56                   	push   %esi
  80033c:	53                   	push   %ebx
  80033d:	83 ec 2c             	sub    $0x2c,%esp
  800340:	8b 75 08             	mov    0x8(%ebp),%esi
  800343:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800346:	8b 7d 10             	mov    0x10(%ebp),%edi
  800349:	eb 12                	jmp    80035d <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80034b:	85 c0                	test   %eax,%eax
  80034d:	0f 84 89 03 00 00    	je     8006dc <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800353:	83 ec 08             	sub    $0x8,%esp
  800356:	53                   	push   %ebx
  800357:	50                   	push   %eax
  800358:	ff d6                	call   *%esi
  80035a:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80035d:	83 c7 01             	add    $0x1,%edi
  800360:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800364:	83 f8 25             	cmp    $0x25,%eax
  800367:	75 e2                	jne    80034b <vprintfmt+0x14>
  800369:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80036d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800374:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80037b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800382:	ba 00 00 00 00       	mov    $0x0,%edx
  800387:	eb 07                	jmp    800390 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800389:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80038c:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800390:	8d 47 01             	lea    0x1(%edi),%eax
  800393:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800396:	0f b6 07             	movzbl (%edi),%eax
  800399:	0f b6 c8             	movzbl %al,%ecx
  80039c:	83 e8 23             	sub    $0x23,%eax
  80039f:	3c 55                	cmp    $0x55,%al
  8003a1:	0f 87 1a 03 00 00    	ja     8006c1 <vprintfmt+0x38a>
  8003a7:	0f b6 c0             	movzbl %al,%eax
  8003aa:	ff 24 85 00 27 80 00 	jmp    *0x802700(,%eax,4)
  8003b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003b4:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003b8:	eb d6                	jmp    800390 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8003c2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003c5:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003c8:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003cc:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003cf:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003d2:	83 fa 09             	cmp    $0x9,%edx
  8003d5:	77 39                	ja     800410 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003d7:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003da:	eb e9                	jmp    8003c5 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8003df:	8d 48 04             	lea    0x4(%eax),%ecx
  8003e2:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003e5:	8b 00                	mov    (%eax),%eax
  8003e7:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003ed:	eb 27                	jmp    800416 <vprintfmt+0xdf>
  8003ef:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003f2:	85 c0                	test   %eax,%eax
  8003f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003f9:	0f 49 c8             	cmovns %eax,%ecx
  8003fc:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800402:	eb 8c                	jmp    800390 <vprintfmt+0x59>
  800404:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800407:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80040e:	eb 80                	jmp    800390 <vprintfmt+0x59>
  800410:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800413:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800416:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80041a:	0f 89 70 ff ff ff    	jns    800390 <vprintfmt+0x59>
				width = precision, precision = -1;
  800420:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800423:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800426:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80042d:	e9 5e ff ff ff       	jmp    800390 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800432:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800435:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800438:	e9 53 ff ff ff       	jmp    800390 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80043d:	8b 45 14             	mov    0x14(%ebp),%eax
  800440:	8d 50 04             	lea    0x4(%eax),%edx
  800443:	89 55 14             	mov    %edx,0x14(%ebp)
  800446:	83 ec 08             	sub    $0x8,%esp
  800449:	53                   	push   %ebx
  80044a:	ff 30                	pushl  (%eax)
  80044c:	ff d6                	call   *%esi
			break;
  80044e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800451:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800454:	e9 04 ff ff ff       	jmp    80035d <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800459:	8b 45 14             	mov    0x14(%ebp),%eax
  80045c:	8d 50 04             	lea    0x4(%eax),%edx
  80045f:	89 55 14             	mov    %edx,0x14(%ebp)
  800462:	8b 00                	mov    (%eax),%eax
  800464:	99                   	cltd   
  800465:	31 d0                	xor    %edx,%eax
  800467:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800469:	83 f8 0f             	cmp    $0xf,%eax
  80046c:	7f 0b                	jg     800479 <vprintfmt+0x142>
  80046e:	8b 14 85 60 28 80 00 	mov    0x802860(,%eax,4),%edx
  800475:	85 d2                	test   %edx,%edx
  800477:	75 18                	jne    800491 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800479:	50                   	push   %eax
  80047a:	68 de 25 80 00       	push   $0x8025de
  80047f:	53                   	push   %ebx
  800480:	56                   	push   %esi
  800481:	e8 94 fe ff ff       	call   80031a <printfmt>
  800486:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800489:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80048c:	e9 cc fe ff ff       	jmp    80035d <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800491:	52                   	push   %edx
  800492:	68 9a 29 80 00       	push   $0x80299a
  800497:	53                   	push   %ebx
  800498:	56                   	push   %esi
  800499:	e8 7c fe ff ff       	call   80031a <printfmt>
  80049e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004a4:	e9 b4 fe ff ff       	jmp    80035d <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ac:	8d 50 04             	lea    0x4(%eax),%edx
  8004af:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b2:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004b4:	85 ff                	test   %edi,%edi
  8004b6:	b8 d7 25 80 00       	mov    $0x8025d7,%eax
  8004bb:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004be:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004c2:	0f 8e 94 00 00 00    	jle    80055c <vprintfmt+0x225>
  8004c8:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004cc:	0f 84 98 00 00 00    	je     80056a <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d2:	83 ec 08             	sub    $0x8,%esp
  8004d5:	ff 75 d0             	pushl  -0x30(%ebp)
  8004d8:	57                   	push   %edi
  8004d9:	e8 86 02 00 00       	call   800764 <strnlen>
  8004de:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004e1:	29 c1                	sub    %eax,%ecx
  8004e3:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004e6:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004e9:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004ed:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004f0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004f3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f5:	eb 0f                	jmp    800506 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004f7:	83 ec 08             	sub    $0x8,%esp
  8004fa:	53                   	push   %ebx
  8004fb:	ff 75 e0             	pushl  -0x20(%ebp)
  8004fe:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800500:	83 ef 01             	sub    $0x1,%edi
  800503:	83 c4 10             	add    $0x10,%esp
  800506:	85 ff                	test   %edi,%edi
  800508:	7f ed                	jg     8004f7 <vprintfmt+0x1c0>
  80050a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80050d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800510:	85 c9                	test   %ecx,%ecx
  800512:	b8 00 00 00 00       	mov    $0x0,%eax
  800517:	0f 49 c1             	cmovns %ecx,%eax
  80051a:	29 c1                	sub    %eax,%ecx
  80051c:	89 75 08             	mov    %esi,0x8(%ebp)
  80051f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800522:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800525:	89 cb                	mov    %ecx,%ebx
  800527:	eb 4d                	jmp    800576 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800529:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80052d:	74 1b                	je     80054a <vprintfmt+0x213>
  80052f:	0f be c0             	movsbl %al,%eax
  800532:	83 e8 20             	sub    $0x20,%eax
  800535:	83 f8 5e             	cmp    $0x5e,%eax
  800538:	76 10                	jbe    80054a <vprintfmt+0x213>
					putch('?', putdat);
  80053a:	83 ec 08             	sub    $0x8,%esp
  80053d:	ff 75 0c             	pushl  0xc(%ebp)
  800540:	6a 3f                	push   $0x3f
  800542:	ff 55 08             	call   *0x8(%ebp)
  800545:	83 c4 10             	add    $0x10,%esp
  800548:	eb 0d                	jmp    800557 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80054a:	83 ec 08             	sub    $0x8,%esp
  80054d:	ff 75 0c             	pushl  0xc(%ebp)
  800550:	52                   	push   %edx
  800551:	ff 55 08             	call   *0x8(%ebp)
  800554:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800557:	83 eb 01             	sub    $0x1,%ebx
  80055a:	eb 1a                	jmp    800576 <vprintfmt+0x23f>
  80055c:	89 75 08             	mov    %esi,0x8(%ebp)
  80055f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800562:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800565:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800568:	eb 0c                	jmp    800576 <vprintfmt+0x23f>
  80056a:	89 75 08             	mov    %esi,0x8(%ebp)
  80056d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800570:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800573:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800576:	83 c7 01             	add    $0x1,%edi
  800579:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80057d:	0f be d0             	movsbl %al,%edx
  800580:	85 d2                	test   %edx,%edx
  800582:	74 23                	je     8005a7 <vprintfmt+0x270>
  800584:	85 f6                	test   %esi,%esi
  800586:	78 a1                	js     800529 <vprintfmt+0x1f2>
  800588:	83 ee 01             	sub    $0x1,%esi
  80058b:	79 9c                	jns    800529 <vprintfmt+0x1f2>
  80058d:	89 df                	mov    %ebx,%edi
  80058f:	8b 75 08             	mov    0x8(%ebp),%esi
  800592:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800595:	eb 18                	jmp    8005af <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800597:	83 ec 08             	sub    $0x8,%esp
  80059a:	53                   	push   %ebx
  80059b:	6a 20                	push   $0x20
  80059d:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80059f:	83 ef 01             	sub    $0x1,%edi
  8005a2:	83 c4 10             	add    $0x10,%esp
  8005a5:	eb 08                	jmp    8005af <vprintfmt+0x278>
  8005a7:	89 df                	mov    %ebx,%edi
  8005a9:	8b 75 08             	mov    0x8(%ebp),%esi
  8005ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005af:	85 ff                	test   %edi,%edi
  8005b1:	7f e4                	jg     800597 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005b6:	e9 a2 fd ff ff       	jmp    80035d <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005bb:	83 fa 01             	cmp    $0x1,%edx
  8005be:	7e 16                	jle    8005d6 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c3:	8d 50 08             	lea    0x8(%eax),%edx
  8005c6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c9:	8b 50 04             	mov    0x4(%eax),%edx
  8005cc:	8b 00                	mov    (%eax),%eax
  8005ce:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d1:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005d4:	eb 32                	jmp    800608 <vprintfmt+0x2d1>
	else if (lflag)
  8005d6:	85 d2                	test   %edx,%edx
  8005d8:	74 18                	je     8005f2 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005da:	8b 45 14             	mov    0x14(%ebp),%eax
  8005dd:	8d 50 04             	lea    0x4(%eax),%edx
  8005e0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e3:	8b 00                	mov    (%eax),%eax
  8005e5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e8:	89 c1                	mov    %eax,%ecx
  8005ea:	c1 f9 1f             	sar    $0x1f,%ecx
  8005ed:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005f0:	eb 16                	jmp    800608 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f5:	8d 50 04             	lea    0x4(%eax),%edx
  8005f8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fb:	8b 00                	mov    (%eax),%eax
  8005fd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800600:	89 c1                	mov    %eax,%ecx
  800602:	c1 f9 1f             	sar    $0x1f,%ecx
  800605:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800608:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80060b:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80060e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800613:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800617:	79 74                	jns    80068d <vprintfmt+0x356>
				putch('-', putdat);
  800619:	83 ec 08             	sub    $0x8,%esp
  80061c:	53                   	push   %ebx
  80061d:	6a 2d                	push   $0x2d
  80061f:	ff d6                	call   *%esi
				num = -(long long) num;
  800621:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800624:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800627:	f7 d8                	neg    %eax
  800629:	83 d2 00             	adc    $0x0,%edx
  80062c:	f7 da                	neg    %edx
  80062e:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800631:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800636:	eb 55                	jmp    80068d <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800638:	8d 45 14             	lea    0x14(%ebp),%eax
  80063b:	e8 83 fc ff ff       	call   8002c3 <getuint>
			base = 10;
  800640:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800645:	eb 46                	jmp    80068d <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800647:	8d 45 14             	lea    0x14(%ebp),%eax
  80064a:	e8 74 fc ff ff       	call   8002c3 <getuint>
                        base = 8;
  80064f:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800654:	eb 37                	jmp    80068d <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800656:	83 ec 08             	sub    $0x8,%esp
  800659:	53                   	push   %ebx
  80065a:	6a 30                	push   $0x30
  80065c:	ff d6                	call   *%esi
			putch('x', putdat);
  80065e:	83 c4 08             	add    $0x8,%esp
  800661:	53                   	push   %ebx
  800662:	6a 78                	push   $0x78
  800664:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800666:	8b 45 14             	mov    0x14(%ebp),%eax
  800669:	8d 50 04             	lea    0x4(%eax),%edx
  80066c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80066f:	8b 00                	mov    (%eax),%eax
  800671:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800676:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800679:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80067e:	eb 0d                	jmp    80068d <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800680:	8d 45 14             	lea    0x14(%ebp),%eax
  800683:	e8 3b fc ff ff       	call   8002c3 <getuint>
			base = 16;
  800688:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80068d:	83 ec 0c             	sub    $0xc,%esp
  800690:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800694:	57                   	push   %edi
  800695:	ff 75 e0             	pushl  -0x20(%ebp)
  800698:	51                   	push   %ecx
  800699:	52                   	push   %edx
  80069a:	50                   	push   %eax
  80069b:	89 da                	mov    %ebx,%edx
  80069d:	89 f0                	mov    %esi,%eax
  80069f:	e8 70 fb ff ff       	call   800214 <printnum>
			break;
  8006a4:	83 c4 20             	add    $0x20,%esp
  8006a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006aa:	e9 ae fc ff ff       	jmp    80035d <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006af:	83 ec 08             	sub    $0x8,%esp
  8006b2:	53                   	push   %ebx
  8006b3:	51                   	push   %ecx
  8006b4:	ff d6                	call   *%esi
			break;
  8006b6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006bc:	e9 9c fc ff ff       	jmp    80035d <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006c1:	83 ec 08             	sub    $0x8,%esp
  8006c4:	53                   	push   %ebx
  8006c5:	6a 25                	push   $0x25
  8006c7:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006c9:	83 c4 10             	add    $0x10,%esp
  8006cc:	eb 03                	jmp    8006d1 <vprintfmt+0x39a>
  8006ce:	83 ef 01             	sub    $0x1,%edi
  8006d1:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006d5:	75 f7                	jne    8006ce <vprintfmt+0x397>
  8006d7:	e9 81 fc ff ff       	jmp    80035d <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006df:	5b                   	pop    %ebx
  8006e0:	5e                   	pop    %esi
  8006e1:	5f                   	pop    %edi
  8006e2:	5d                   	pop    %ebp
  8006e3:	c3                   	ret    

008006e4 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006e4:	55                   	push   %ebp
  8006e5:	89 e5                	mov    %esp,%ebp
  8006e7:	83 ec 18             	sub    $0x18,%esp
  8006ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ed:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006f0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006f3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006f7:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006fa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800701:	85 c0                	test   %eax,%eax
  800703:	74 26                	je     80072b <vsnprintf+0x47>
  800705:	85 d2                	test   %edx,%edx
  800707:	7e 22                	jle    80072b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800709:	ff 75 14             	pushl  0x14(%ebp)
  80070c:	ff 75 10             	pushl  0x10(%ebp)
  80070f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800712:	50                   	push   %eax
  800713:	68 fd 02 80 00       	push   $0x8002fd
  800718:	e8 1a fc ff ff       	call   800337 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80071d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800720:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800723:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800726:	83 c4 10             	add    $0x10,%esp
  800729:	eb 05                	jmp    800730 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80072b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800730:	c9                   	leave  
  800731:	c3                   	ret    

00800732 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800732:	55                   	push   %ebp
  800733:	89 e5                	mov    %esp,%ebp
  800735:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800738:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80073b:	50                   	push   %eax
  80073c:	ff 75 10             	pushl  0x10(%ebp)
  80073f:	ff 75 0c             	pushl  0xc(%ebp)
  800742:	ff 75 08             	pushl  0x8(%ebp)
  800745:	e8 9a ff ff ff       	call   8006e4 <vsnprintf>
	va_end(ap);

	return rc;
}
  80074a:	c9                   	leave  
  80074b:	c3                   	ret    

0080074c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80074c:	55                   	push   %ebp
  80074d:	89 e5                	mov    %esp,%ebp
  80074f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800752:	b8 00 00 00 00       	mov    $0x0,%eax
  800757:	eb 03                	jmp    80075c <strlen+0x10>
		n++;
  800759:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80075c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800760:	75 f7                	jne    800759 <strlen+0xd>
		n++;
	return n;
}
  800762:	5d                   	pop    %ebp
  800763:	c3                   	ret    

00800764 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800764:	55                   	push   %ebp
  800765:	89 e5                	mov    %esp,%ebp
  800767:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80076a:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80076d:	ba 00 00 00 00       	mov    $0x0,%edx
  800772:	eb 03                	jmp    800777 <strnlen+0x13>
		n++;
  800774:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800777:	39 c2                	cmp    %eax,%edx
  800779:	74 08                	je     800783 <strnlen+0x1f>
  80077b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80077f:	75 f3                	jne    800774 <strnlen+0x10>
  800781:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800783:	5d                   	pop    %ebp
  800784:	c3                   	ret    

00800785 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800785:	55                   	push   %ebp
  800786:	89 e5                	mov    %esp,%ebp
  800788:	53                   	push   %ebx
  800789:	8b 45 08             	mov    0x8(%ebp),%eax
  80078c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80078f:	89 c2                	mov    %eax,%edx
  800791:	83 c2 01             	add    $0x1,%edx
  800794:	83 c1 01             	add    $0x1,%ecx
  800797:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80079b:	88 5a ff             	mov    %bl,-0x1(%edx)
  80079e:	84 db                	test   %bl,%bl
  8007a0:	75 ef                	jne    800791 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007a2:	5b                   	pop    %ebx
  8007a3:	5d                   	pop    %ebp
  8007a4:	c3                   	ret    

008007a5 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007a5:	55                   	push   %ebp
  8007a6:	89 e5                	mov    %esp,%ebp
  8007a8:	53                   	push   %ebx
  8007a9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007ac:	53                   	push   %ebx
  8007ad:	e8 9a ff ff ff       	call   80074c <strlen>
  8007b2:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007b5:	ff 75 0c             	pushl  0xc(%ebp)
  8007b8:	01 d8                	add    %ebx,%eax
  8007ba:	50                   	push   %eax
  8007bb:	e8 c5 ff ff ff       	call   800785 <strcpy>
	return dst;
}
  8007c0:	89 d8                	mov    %ebx,%eax
  8007c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007c5:	c9                   	leave  
  8007c6:	c3                   	ret    

008007c7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007c7:	55                   	push   %ebp
  8007c8:	89 e5                	mov    %esp,%ebp
  8007ca:	56                   	push   %esi
  8007cb:	53                   	push   %ebx
  8007cc:	8b 75 08             	mov    0x8(%ebp),%esi
  8007cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007d2:	89 f3                	mov    %esi,%ebx
  8007d4:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d7:	89 f2                	mov    %esi,%edx
  8007d9:	eb 0f                	jmp    8007ea <strncpy+0x23>
		*dst++ = *src;
  8007db:	83 c2 01             	add    $0x1,%edx
  8007de:	0f b6 01             	movzbl (%ecx),%eax
  8007e1:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007e4:	80 39 01             	cmpb   $0x1,(%ecx)
  8007e7:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007ea:	39 da                	cmp    %ebx,%edx
  8007ec:	75 ed                	jne    8007db <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007ee:	89 f0                	mov    %esi,%eax
  8007f0:	5b                   	pop    %ebx
  8007f1:	5e                   	pop    %esi
  8007f2:	5d                   	pop    %ebp
  8007f3:	c3                   	ret    

008007f4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007f4:	55                   	push   %ebp
  8007f5:	89 e5                	mov    %esp,%ebp
  8007f7:	56                   	push   %esi
  8007f8:	53                   	push   %ebx
  8007f9:	8b 75 08             	mov    0x8(%ebp),%esi
  8007fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007ff:	8b 55 10             	mov    0x10(%ebp),%edx
  800802:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800804:	85 d2                	test   %edx,%edx
  800806:	74 21                	je     800829 <strlcpy+0x35>
  800808:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80080c:	89 f2                	mov    %esi,%edx
  80080e:	eb 09                	jmp    800819 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800810:	83 c2 01             	add    $0x1,%edx
  800813:	83 c1 01             	add    $0x1,%ecx
  800816:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800819:	39 c2                	cmp    %eax,%edx
  80081b:	74 09                	je     800826 <strlcpy+0x32>
  80081d:	0f b6 19             	movzbl (%ecx),%ebx
  800820:	84 db                	test   %bl,%bl
  800822:	75 ec                	jne    800810 <strlcpy+0x1c>
  800824:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800826:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800829:	29 f0                	sub    %esi,%eax
}
  80082b:	5b                   	pop    %ebx
  80082c:	5e                   	pop    %esi
  80082d:	5d                   	pop    %ebp
  80082e:	c3                   	ret    

0080082f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80082f:	55                   	push   %ebp
  800830:	89 e5                	mov    %esp,%ebp
  800832:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800835:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800838:	eb 06                	jmp    800840 <strcmp+0x11>
		p++, q++;
  80083a:	83 c1 01             	add    $0x1,%ecx
  80083d:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800840:	0f b6 01             	movzbl (%ecx),%eax
  800843:	84 c0                	test   %al,%al
  800845:	74 04                	je     80084b <strcmp+0x1c>
  800847:	3a 02                	cmp    (%edx),%al
  800849:	74 ef                	je     80083a <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80084b:	0f b6 c0             	movzbl %al,%eax
  80084e:	0f b6 12             	movzbl (%edx),%edx
  800851:	29 d0                	sub    %edx,%eax
}
  800853:	5d                   	pop    %ebp
  800854:	c3                   	ret    

00800855 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800855:	55                   	push   %ebp
  800856:	89 e5                	mov    %esp,%ebp
  800858:	53                   	push   %ebx
  800859:	8b 45 08             	mov    0x8(%ebp),%eax
  80085c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80085f:	89 c3                	mov    %eax,%ebx
  800861:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800864:	eb 06                	jmp    80086c <strncmp+0x17>
		n--, p++, q++;
  800866:	83 c0 01             	add    $0x1,%eax
  800869:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80086c:	39 d8                	cmp    %ebx,%eax
  80086e:	74 15                	je     800885 <strncmp+0x30>
  800870:	0f b6 08             	movzbl (%eax),%ecx
  800873:	84 c9                	test   %cl,%cl
  800875:	74 04                	je     80087b <strncmp+0x26>
  800877:	3a 0a                	cmp    (%edx),%cl
  800879:	74 eb                	je     800866 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80087b:	0f b6 00             	movzbl (%eax),%eax
  80087e:	0f b6 12             	movzbl (%edx),%edx
  800881:	29 d0                	sub    %edx,%eax
  800883:	eb 05                	jmp    80088a <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800885:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80088a:	5b                   	pop    %ebx
  80088b:	5d                   	pop    %ebp
  80088c:	c3                   	ret    

0080088d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80088d:	55                   	push   %ebp
  80088e:	89 e5                	mov    %esp,%ebp
  800890:	8b 45 08             	mov    0x8(%ebp),%eax
  800893:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800897:	eb 07                	jmp    8008a0 <strchr+0x13>
		if (*s == c)
  800899:	38 ca                	cmp    %cl,%dl
  80089b:	74 0f                	je     8008ac <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80089d:	83 c0 01             	add    $0x1,%eax
  8008a0:	0f b6 10             	movzbl (%eax),%edx
  8008a3:	84 d2                	test   %dl,%dl
  8008a5:	75 f2                	jne    800899 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008a7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008ac:	5d                   	pop    %ebp
  8008ad:	c3                   	ret    

008008ae <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008ae:	55                   	push   %ebp
  8008af:	89 e5                	mov    %esp,%ebp
  8008b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008b8:	eb 03                	jmp    8008bd <strfind+0xf>
  8008ba:	83 c0 01             	add    $0x1,%eax
  8008bd:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008c0:	38 ca                	cmp    %cl,%dl
  8008c2:	74 04                	je     8008c8 <strfind+0x1a>
  8008c4:	84 d2                	test   %dl,%dl
  8008c6:	75 f2                	jne    8008ba <strfind+0xc>
			break;
	return (char *) s;
}
  8008c8:	5d                   	pop    %ebp
  8008c9:	c3                   	ret    

008008ca <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008ca:	55                   	push   %ebp
  8008cb:	89 e5                	mov    %esp,%ebp
  8008cd:	57                   	push   %edi
  8008ce:	56                   	push   %esi
  8008cf:	53                   	push   %ebx
  8008d0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008d3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008d6:	85 c9                	test   %ecx,%ecx
  8008d8:	74 36                	je     800910 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008da:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008e0:	75 28                	jne    80090a <memset+0x40>
  8008e2:	f6 c1 03             	test   $0x3,%cl
  8008e5:	75 23                	jne    80090a <memset+0x40>
		c &= 0xFF;
  8008e7:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008eb:	89 d3                	mov    %edx,%ebx
  8008ed:	c1 e3 08             	shl    $0x8,%ebx
  8008f0:	89 d6                	mov    %edx,%esi
  8008f2:	c1 e6 18             	shl    $0x18,%esi
  8008f5:	89 d0                	mov    %edx,%eax
  8008f7:	c1 e0 10             	shl    $0x10,%eax
  8008fa:	09 f0                	or     %esi,%eax
  8008fc:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008fe:	89 d8                	mov    %ebx,%eax
  800900:	09 d0                	or     %edx,%eax
  800902:	c1 e9 02             	shr    $0x2,%ecx
  800905:	fc                   	cld    
  800906:	f3 ab                	rep stos %eax,%es:(%edi)
  800908:	eb 06                	jmp    800910 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80090a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80090d:	fc                   	cld    
  80090e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800910:	89 f8                	mov    %edi,%eax
  800912:	5b                   	pop    %ebx
  800913:	5e                   	pop    %esi
  800914:	5f                   	pop    %edi
  800915:	5d                   	pop    %ebp
  800916:	c3                   	ret    

00800917 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800917:	55                   	push   %ebp
  800918:	89 e5                	mov    %esp,%ebp
  80091a:	57                   	push   %edi
  80091b:	56                   	push   %esi
  80091c:	8b 45 08             	mov    0x8(%ebp),%eax
  80091f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800922:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800925:	39 c6                	cmp    %eax,%esi
  800927:	73 35                	jae    80095e <memmove+0x47>
  800929:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80092c:	39 d0                	cmp    %edx,%eax
  80092e:	73 2e                	jae    80095e <memmove+0x47>
		s += n;
		d += n;
  800930:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800933:	89 d6                	mov    %edx,%esi
  800935:	09 fe                	or     %edi,%esi
  800937:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80093d:	75 13                	jne    800952 <memmove+0x3b>
  80093f:	f6 c1 03             	test   $0x3,%cl
  800942:	75 0e                	jne    800952 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800944:	83 ef 04             	sub    $0x4,%edi
  800947:	8d 72 fc             	lea    -0x4(%edx),%esi
  80094a:	c1 e9 02             	shr    $0x2,%ecx
  80094d:	fd                   	std    
  80094e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800950:	eb 09                	jmp    80095b <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800952:	83 ef 01             	sub    $0x1,%edi
  800955:	8d 72 ff             	lea    -0x1(%edx),%esi
  800958:	fd                   	std    
  800959:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80095b:	fc                   	cld    
  80095c:	eb 1d                	jmp    80097b <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80095e:	89 f2                	mov    %esi,%edx
  800960:	09 c2                	or     %eax,%edx
  800962:	f6 c2 03             	test   $0x3,%dl
  800965:	75 0f                	jne    800976 <memmove+0x5f>
  800967:	f6 c1 03             	test   $0x3,%cl
  80096a:	75 0a                	jne    800976 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80096c:	c1 e9 02             	shr    $0x2,%ecx
  80096f:	89 c7                	mov    %eax,%edi
  800971:	fc                   	cld    
  800972:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800974:	eb 05                	jmp    80097b <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800976:	89 c7                	mov    %eax,%edi
  800978:	fc                   	cld    
  800979:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80097b:	5e                   	pop    %esi
  80097c:	5f                   	pop    %edi
  80097d:	5d                   	pop    %ebp
  80097e:	c3                   	ret    

0080097f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800982:	ff 75 10             	pushl  0x10(%ebp)
  800985:	ff 75 0c             	pushl  0xc(%ebp)
  800988:	ff 75 08             	pushl  0x8(%ebp)
  80098b:	e8 87 ff ff ff       	call   800917 <memmove>
}
  800990:	c9                   	leave  
  800991:	c3                   	ret    

00800992 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800992:	55                   	push   %ebp
  800993:	89 e5                	mov    %esp,%ebp
  800995:	56                   	push   %esi
  800996:	53                   	push   %ebx
  800997:	8b 45 08             	mov    0x8(%ebp),%eax
  80099a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80099d:	89 c6                	mov    %eax,%esi
  80099f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009a2:	eb 1a                	jmp    8009be <memcmp+0x2c>
		if (*s1 != *s2)
  8009a4:	0f b6 08             	movzbl (%eax),%ecx
  8009a7:	0f b6 1a             	movzbl (%edx),%ebx
  8009aa:	38 d9                	cmp    %bl,%cl
  8009ac:	74 0a                	je     8009b8 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009ae:	0f b6 c1             	movzbl %cl,%eax
  8009b1:	0f b6 db             	movzbl %bl,%ebx
  8009b4:	29 d8                	sub    %ebx,%eax
  8009b6:	eb 0f                	jmp    8009c7 <memcmp+0x35>
		s1++, s2++;
  8009b8:	83 c0 01             	add    $0x1,%eax
  8009bb:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009be:	39 f0                	cmp    %esi,%eax
  8009c0:	75 e2                	jne    8009a4 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009c2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c7:	5b                   	pop    %ebx
  8009c8:	5e                   	pop    %esi
  8009c9:	5d                   	pop    %ebp
  8009ca:	c3                   	ret    

008009cb <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	53                   	push   %ebx
  8009cf:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009d2:	89 c1                	mov    %eax,%ecx
  8009d4:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009d7:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009db:	eb 0a                	jmp    8009e7 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009dd:	0f b6 10             	movzbl (%eax),%edx
  8009e0:	39 da                	cmp    %ebx,%edx
  8009e2:	74 07                	je     8009eb <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009e4:	83 c0 01             	add    $0x1,%eax
  8009e7:	39 c8                	cmp    %ecx,%eax
  8009e9:	72 f2                	jb     8009dd <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009eb:	5b                   	pop    %ebx
  8009ec:	5d                   	pop    %ebp
  8009ed:	c3                   	ret    

008009ee <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009ee:	55                   	push   %ebp
  8009ef:	89 e5                	mov    %esp,%ebp
  8009f1:	57                   	push   %edi
  8009f2:	56                   	push   %esi
  8009f3:	53                   	push   %ebx
  8009f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009f7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009fa:	eb 03                	jmp    8009ff <strtol+0x11>
		s++;
  8009fc:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ff:	0f b6 01             	movzbl (%ecx),%eax
  800a02:	3c 20                	cmp    $0x20,%al
  800a04:	74 f6                	je     8009fc <strtol+0xe>
  800a06:	3c 09                	cmp    $0x9,%al
  800a08:	74 f2                	je     8009fc <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a0a:	3c 2b                	cmp    $0x2b,%al
  800a0c:	75 0a                	jne    800a18 <strtol+0x2a>
		s++;
  800a0e:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a11:	bf 00 00 00 00       	mov    $0x0,%edi
  800a16:	eb 11                	jmp    800a29 <strtol+0x3b>
  800a18:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a1d:	3c 2d                	cmp    $0x2d,%al
  800a1f:	75 08                	jne    800a29 <strtol+0x3b>
		s++, neg = 1;
  800a21:	83 c1 01             	add    $0x1,%ecx
  800a24:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a29:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a2f:	75 15                	jne    800a46 <strtol+0x58>
  800a31:	80 39 30             	cmpb   $0x30,(%ecx)
  800a34:	75 10                	jne    800a46 <strtol+0x58>
  800a36:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a3a:	75 7c                	jne    800ab8 <strtol+0xca>
		s += 2, base = 16;
  800a3c:	83 c1 02             	add    $0x2,%ecx
  800a3f:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a44:	eb 16                	jmp    800a5c <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a46:	85 db                	test   %ebx,%ebx
  800a48:	75 12                	jne    800a5c <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a4a:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a4f:	80 39 30             	cmpb   $0x30,(%ecx)
  800a52:	75 08                	jne    800a5c <strtol+0x6e>
		s++, base = 8;
  800a54:	83 c1 01             	add    $0x1,%ecx
  800a57:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a5c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a61:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a64:	0f b6 11             	movzbl (%ecx),%edx
  800a67:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a6a:	89 f3                	mov    %esi,%ebx
  800a6c:	80 fb 09             	cmp    $0x9,%bl
  800a6f:	77 08                	ja     800a79 <strtol+0x8b>
			dig = *s - '0';
  800a71:	0f be d2             	movsbl %dl,%edx
  800a74:	83 ea 30             	sub    $0x30,%edx
  800a77:	eb 22                	jmp    800a9b <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a79:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a7c:	89 f3                	mov    %esi,%ebx
  800a7e:	80 fb 19             	cmp    $0x19,%bl
  800a81:	77 08                	ja     800a8b <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a83:	0f be d2             	movsbl %dl,%edx
  800a86:	83 ea 57             	sub    $0x57,%edx
  800a89:	eb 10                	jmp    800a9b <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a8b:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a8e:	89 f3                	mov    %esi,%ebx
  800a90:	80 fb 19             	cmp    $0x19,%bl
  800a93:	77 16                	ja     800aab <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a95:	0f be d2             	movsbl %dl,%edx
  800a98:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a9b:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a9e:	7d 0b                	jge    800aab <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800aa0:	83 c1 01             	add    $0x1,%ecx
  800aa3:	0f af 45 10          	imul   0x10(%ebp),%eax
  800aa7:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800aa9:	eb b9                	jmp    800a64 <strtol+0x76>

	if (endptr)
  800aab:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aaf:	74 0d                	je     800abe <strtol+0xd0>
		*endptr = (char *) s;
  800ab1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ab4:	89 0e                	mov    %ecx,(%esi)
  800ab6:	eb 06                	jmp    800abe <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ab8:	85 db                	test   %ebx,%ebx
  800aba:	74 98                	je     800a54 <strtol+0x66>
  800abc:	eb 9e                	jmp    800a5c <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800abe:	89 c2                	mov    %eax,%edx
  800ac0:	f7 da                	neg    %edx
  800ac2:	85 ff                	test   %edi,%edi
  800ac4:	0f 45 c2             	cmovne %edx,%eax
}
  800ac7:	5b                   	pop    %ebx
  800ac8:	5e                   	pop    %esi
  800ac9:	5f                   	pop    %edi
  800aca:	5d                   	pop    %ebp
  800acb:	c3                   	ret    

00800acc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800acc:	55                   	push   %ebp
  800acd:	89 e5                	mov    %esp,%ebp
  800acf:	57                   	push   %edi
  800ad0:	56                   	push   %esi
  800ad1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ad2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ada:	8b 55 08             	mov    0x8(%ebp),%edx
  800add:	89 c3                	mov    %eax,%ebx
  800adf:	89 c7                	mov    %eax,%edi
  800ae1:	89 c6                	mov    %eax,%esi
  800ae3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ae5:	5b                   	pop    %ebx
  800ae6:	5e                   	pop    %esi
  800ae7:	5f                   	pop    %edi
  800ae8:	5d                   	pop    %ebp
  800ae9:	c3                   	ret    

00800aea <sys_cgetc>:

int
sys_cgetc(void)
{
  800aea:	55                   	push   %ebp
  800aeb:	89 e5                	mov    %esp,%ebp
  800aed:	57                   	push   %edi
  800aee:	56                   	push   %esi
  800aef:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af0:	ba 00 00 00 00       	mov    $0x0,%edx
  800af5:	b8 01 00 00 00       	mov    $0x1,%eax
  800afa:	89 d1                	mov    %edx,%ecx
  800afc:	89 d3                	mov    %edx,%ebx
  800afe:	89 d7                	mov    %edx,%edi
  800b00:	89 d6                	mov    %edx,%esi
  800b02:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b04:	5b                   	pop    %ebx
  800b05:	5e                   	pop    %esi
  800b06:	5f                   	pop    %edi
  800b07:	5d                   	pop    %ebp
  800b08:	c3                   	ret    

00800b09 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b09:	55                   	push   %ebp
  800b0a:	89 e5                	mov    %esp,%ebp
  800b0c:	57                   	push   %edi
  800b0d:	56                   	push   %esi
  800b0e:	53                   	push   %ebx
  800b0f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b12:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b17:	b8 03 00 00 00       	mov    $0x3,%eax
  800b1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b1f:	89 cb                	mov    %ecx,%ebx
  800b21:	89 cf                	mov    %ecx,%edi
  800b23:	89 ce                	mov    %ecx,%esi
  800b25:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b27:	85 c0                	test   %eax,%eax
  800b29:	7e 17                	jle    800b42 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b2b:	83 ec 0c             	sub    $0xc,%esp
  800b2e:	50                   	push   %eax
  800b2f:	6a 03                	push   $0x3
  800b31:	68 bf 28 80 00       	push   $0x8028bf
  800b36:	6a 23                	push   $0x23
  800b38:	68 dc 28 80 00       	push   $0x8028dc
  800b3d:	e8 34 16 00 00       	call   802176 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b42:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b45:	5b                   	pop    %ebx
  800b46:	5e                   	pop    %esi
  800b47:	5f                   	pop    %edi
  800b48:	5d                   	pop    %ebp
  800b49:	c3                   	ret    

00800b4a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b4a:	55                   	push   %ebp
  800b4b:	89 e5                	mov    %esp,%ebp
  800b4d:	57                   	push   %edi
  800b4e:	56                   	push   %esi
  800b4f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b50:	ba 00 00 00 00       	mov    $0x0,%edx
  800b55:	b8 02 00 00 00       	mov    $0x2,%eax
  800b5a:	89 d1                	mov    %edx,%ecx
  800b5c:	89 d3                	mov    %edx,%ebx
  800b5e:	89 d7                	mov    %edx,%edi
  800b60:	89 d6                	mov    %edx,%esi
  800b62:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b64:	5b                   	pop    %ebx
  800b65:	5e                   	pop    %esi
  800b66:	5f                   	pop    %edi
  800b67:	5d                   	pop    %ebp
  800b68:	c3                   	ret    

00800b69 <sys_yield>:

void
sys_yield(void)
{
  800b69:	55                   	push   %ebp
  800b6a:	89 e5                	mov    %esp,%ebp
  800b6c:	57                   	push   %edi
  800b6d:	56                   	push   %esi
  800b6e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b6f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b74:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b79:	89 d1                	mov    %edx,%ecx
  800b7b:	89 d3                	mov    %edx,%ebx
  800b7d:	89 d7                	mov    %edx,%edi
  800b7f:	89 d6                	mov    %edx,%esi
  800b81:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b83:	5b                   	pop    %ebx
  800b84:	5e                   	pop    %esi
  800b85:	5f                   	pop    %edi
  800b86:	5d                   	pop    %ebp
  800b87:	c3                   	ret    

00800b88 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b88:	55                   	push   %ebp
  800b89:	89 e5                	mov    %esp,%ebp
  800b8b:	57                   	push   %edi
  800b8c:	56                   	push   %esi
  800b8d:	53                   	push   %ebx
  800b8e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b91:	be 00 00 00 00       	mov    $0x0,%esi
  800b96:	b8 04 00 00 00       	mov    $0x4,%eax
  800b9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ba4:	89 f7                	mov    %esi,%edi
  800ba6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ba8:	85 c0                	test   %eax,%eax
  800baa:	7e 17                	jle    800bc3 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bac:	83 ec 0c             	sub    $0xc,%esp
  800baf:	50                   	push   %eax
  800bb0:	6a 04                	push   $0x4
  800bb2:	68 bf 28 80 00       	push   $0x8028bf
  800bb7:	6a 23                	push   $0x23
  800bb9:	68 dc 28 80 00       	push   $0x8028dc
  800bbe:	e8 b3 15 00 00       	call   802176 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bc3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc6:	5b                   	pop    %ebx
  800bc7:	5e                   	pop    %esi
  800bc8:	5f                   	pop    %edi
  800bc9:	5d                   	pop    %ebp
  800bca:	c3                   	ret    

00800bcb <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bcb:	55                   	push   %ebp
  800bcc:	89 e5                	mov    %esp,%ebp
  800bce:	57                   	push   %edi
  800bcf:	56                   	push   %esi
  800bd0:	53                   	push   %ebx
  800bd1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd4:	b8 05 00 00 00       	mov    $0x5,%eax
  800bd9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bdc:	8b 55 08             	mov    0x8(%ebp),%edx
  800bdf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800be2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800be5:	8b 75 18             	mov    0x18(%ebp),%esi
  800be8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bea:	85 c0                	test   %eax,%eax
  800bec:	7e 17                	jle    800c05 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bee:	83 ec 0c             	sub    $0xc,%esp
  800bf1:	50                   	push   %eax
  800bf2:	6a 05                	push   $0x5
  800bf4:	68 bf 28 80 00       	push   $0x8028bf
  800bf9:	6a 23                	push   $0x23
  800bfb:	68 dc 28 80 00       	push   $0x8028dc
  800c00:	e8 71 15 00 00       	call   802176 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c05:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c08:	5b                   	pop    %ebx
  800c09:	5e                   	pop    %esi
  800c0a:	5f                   	pop    %edi
  800c0b:	5d                   	pop    %ebp
  800c0c:	c3                   	ret    

00800c0d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c0d:	55                   	push   %ebp
  800c0e:	89 e5                	mov    %esp,%ebp
  800c10:	57                   	push   %edi
  800c11:	56                   	push   %esi
  800c12:	53                   	push   %ebx
  800c13:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c16:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c1b:	b8 06 00 00 00       	mov    $0x6,%eax
  800c20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c23:	8b 55 08             	mov    0x8(%ebp),%edx
  800c26:	89 df                	mov    %ebx,%edi
  800c28:	89 de                	mov    %ebx,%esi
  800c2a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c2c:	85 c0                	test   %eax,%eax
  800c2e:	7e 17                	jle    800c47 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c30:	83 ec 0c             	sub    $0xc,%esp
  800c33:	50                   	push   %eax
  800c34:	6a 06                	push   $0x6
  800c36:	68 bf 28 80 00       	push   $0x8028bf
  800c3b:	6a 23                	push   $0x23
  800c3d:	68 dc 28 80 00       	push   $0x8028dc
  800c42:	e8 2f 15 00 00       	call   802176 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c47:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c4a:	5b                   	pop    %ebx
  800c4b:	5e                   	pop    %esi
  800c4c:	5f                   	pop    %edi
  800c4d:	5d                   	pop    %ebp
  800c4e:	c3                   	ret    

00800c4f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c4f:	55                   	push   %ebp
  800c50:	89 e5                	mov    %esp,%ebp
  800c52:	57                   	push   %edi
  800c53:	56                   	push   %esi
  800c54:	53                   	push   %ebx
  800c55:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c58:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c5d:	b8 08 00 00 00       	mov    $0x8,%eax
  800c62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c65:	8b 55 08             	mov    0x8(%ebp),%edx
  800c68:	89 df                	mov    %ebx,%edi
  800c6a:	89 de                	mov    %ebx,%esi
  800c6c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c6e:	85 c0                	test   %eax,%eax
  800c70:	7e 17                	jle    800c89 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c72:	83 ec 0c             	sub    $0xc,%esp
  800c75:	50                   	push   %eax
  800c76:	6a 08                	push   $0x8
  800c78:	68 bf 28 80 00       	push   $0x8028bf
  800c7d:	6a 23                	push   $0x23
  800c7f:	68 dc 28 80 00       	push   $0x8028dc
  800c84:	e8 ed 14 00 00       	call   802176 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c89:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8c:	5b                   	pop    %ebx
  800c8d:	5e                   	pop    %esi
  800c8e:	5f                   	pop    %edi
  800c8f:	5d                   	pop    %ebp
  800c90:	c3                   	ret    

00800c91 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c91:	55                   	push   %ebp
  800c92:	89 e5                	mov    %esp,%ebp
  800c94:	57                   	push   %edi
  800c95:	56                   	push   %esi
  800c96:	53                   	push   %ebx
  800c97:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c9f:	b8 09 00 00 00       	mov    $0x9,%eax
  800ca4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca7:	8b 55 08             	mov    0x8(%ebp),%edx
  800caa:	89 df                	mov    %ebx,%edi
  800cac:	89 de                	mov    %ebx,%esi
  800cae:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cb0:	85 c0                	test   %eax,%eax
  800cb2:	7e 17                	jle    800ccb <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb4:	83 ec 0c             	sub    $0xc,%esp
  800cb7:	50                   	push   %eax
  800cb8:	6a 09                	push   $0x9
  800cba:	68 bf 28 80 00       	push   $0x8028bf
  800cbf:	6a 23                	push   $0x23
  800cc1:	68 dc 28 80 00       	push   $0x8028dc
  800cc6:	e8 ab 14 00 00       	call   802176 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ccb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cce:	5b                   	pop    %ebx
  800ccf:	5e                   	pop    %esi
  800cd0:	5f                   	pop    %edi
  800cd1:	5d                   	pop    %ebp
  800cd2:	c3                   	ret    

00800cd3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cd3:	55                   	push   %ebp
  800cd4:	89 e5                	mov    %esp,%ebp
  800cd6:	57                   	push   %edi
  800cd7:	56                   	push   %esi
  800cd8:	53                   	push   %ebx
  800cd9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cdc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce1:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ce6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cec:	89 df                	mov    %ebx,%edi
  800cee:	89 de                	mov    %ebx,%esi
  800cf0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cf2:	85 c0                	test   %eax,%eax
  800cf4:	7e 17                	jle    800d0d <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf6:	83 ec 0c             	sub    $0xc,%esp
  800cf9:	50                   	push   %eax
  800cfa:	6a 0a                	push   $0xa
  800cfc:	68 bf 28 80 00       	push   $0x8028bf
  800d01:	6a 23                	push   $0x23
  800d03:	68 dc 28 80 00       	push   $0x8028dc
  800d08:	e8 69 14 00 00       	call   802176 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d0d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d10:	5b                   	pop    %ebx
  800d11:	5e                   	pop    %esi
  800d12:	5f                   	pop    %edi
  800d13:	5d                   	pop    %ebp
  800d14:	c3                   	ret    

00800d15 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d15:	55                   	push   %ebp
  800d16:	89 e5                	mov    %esp,%ebp
  800d18:	57                   	push   %edi
  800d19:	56                   	push   %esi
  800d1a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1b:	be 00 00 00 00       	mov    $0x0,%esi
  800d20:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d25:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d28:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d2e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d31:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d33:	5b                   	pop    %ebx
  800d34:	5e                   	pop    %esi
  800d35:	5f                   	pop    %edi
  800d36:	5d                   	pop    %ebp
  800d37:	c3                   	ret    

00800d38 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d38:	55                   	push   %ebp
  800d39:	89 e5                	mov    %esp,%ebp
  800d3b:	57                   	push   %edi
  800d3c:	56                   	push   %esi
  800d3d:	53                   	push   %ebx
  800d3e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d41:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d46:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d4b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4e:	89 cb                	mov    %ecx,%ebx
  800d50:	89 cf                	mov    %ecx,%edi
  800d52:	89 ce                	mov    %ecx,%esi
  800d54:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d56:	85 c0                	test   %eax,%eax
  800d58:	7e 17                	jle    800d71 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5a:	83 ec 0c             	sub    $0xc,%esp
  800d5d:	50                   	push   %eax
  800d5e:	6a 0d                	push   $0xd
  800d60:	68 bf 28 80 00       	push   $0x8028bf
  800d65:	6a 23                	push   $0x23
  800d67:	68 dc 28 80 00       	push   $0x8028dc
  800d6c:	e8 05 14 00 00       	call   802176 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d71:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d74:	5b                   	pop    %ebx
  800d75:	5e                   	pop    %esi
  800d76:	5f                   	pop    %edi
  800d77:	5d                   	pop    %ebp
  800d78:	c3                   	ret    

00800d79 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d79:	55                   	push   %ebp
  800d7a:	89 e5                	mov    %esp,%ebp
  800d7c:	57                   	push   %edi
  800d7d:	56                   	push   %esi
  800d7e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7f:	ba 00 00 00 00       	mov    $0x0,%edx
  800d84:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d89:	89 d1                	mov    %edx,%ecx
  800d8b:	89 d3                	mov    %edx,%ebx
  800d8d:	89 d7                	mov    %edx,%edi
  800d8f:	89 d6                	mov    %edx,%esi
  800d91:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d93:	5b                   	pop    %ebx
  800d94:	5e                   	pop    %esi
  800d95:	5f                   	pop    %edi
  800d96:	5d                   	pop    %ebp
  800d97:	c3                   	ret    

00800d98 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  800d98:	55                   	push   %ebp
  800d99:	89 e5                	mov    %esp,%ebp
  800d9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da1:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  800da4:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  800da6:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  800da9:	83 3a 01             	cmpl   $0x1,(%edx)
  800dac:	7e 09                	jle    800db7 <argstart+0x1f>
  800dae:	ba 91 25 80 00       	mov    $0x802591,%edx
  800db3:	85 c9                	test   %ecx,%ecx
  800db5:	75 05                	jne    800dbc <argstart+0x24>
  800db7:	ba 00 00 00 00       	mov    $0x0,%edx
  800dbc:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  800dbf:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  800dc6:	5d                   	pop    %ebp
  800dc7:	c3                   	ret    

00800dc8 <argnext>:

int
argnext(struct Argstate *args)
{
  800dc8:	55                   	push   %ebp
  800dc9:	89 e5                	mov    %esp,%ebp
  800dcb:	53                   	push   %ebx
  800dcc:	83 ec 04             	sub    $0x4,%esp
  800dcf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  800dd2:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  800dd9:	8b 43 08             	mov    0x8(%ebx),%eax
  800ddc:	85 c0                	test   %eax,%eax
  800dde:	74 6f                	je     800e4f <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  800de0:	80 38 00             	cmpb   $0x0,(%eax)
  800de3:	75 4e                	jne    800e33 <argnext+0x6b>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  800de5:	8b 0b                	mov    (%ebx),%ecx
  800de7:	83 39 01             	cmpl   $0x1,(%ecx)
  800dea:	74 55                	je     800e41 <argnext+0x79>
		    || args->argv[1][0] != '-'
  800dec:	8b 53 04             	mov    0x4(%ebx),%edx
  800def:	8b 42 04             	mov    0x4(%edx),%eax
  800df2:	80 38 2d             	cmpb   $0x2d,(%eax)
  800df5:	75 4a                	jne    800e41 <argnext+0x79>
		    || args->argv[1][1] == '\0')
  800df7:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  800dfb:	74 44                	je     800e41 <argnext+0x79>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  800dfd:	83 c0 01             	add    $0x1,%eax
  800e00:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800e03:	83 ec 04             	sub    $0x4,%esp
  800e06:	8b 01                	mov    (%ecx),%eax
  800e08:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  800e0f:	50                   	push   %eax
  800e10:	8d 42 08             	lea    0x8(%edx),%eax
  800e13:	50                   	push   %eax
  800e14:	83 c2 04             	add    $0x4,%edx
  800e17:	52                   	push   %edx
  800e18:	e8 fa fa ff ff       	call   800917 <memmove>
		(*args->argc)--;
  800e1d:	8b 03                	mov    (%ebx),%eax
  800e1f:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  800e22:	8b 43 08             	mov    0x8(%ebx),%eax
  800e25:	83 c4 10             	add    $0x10,%esp
  800e28:	80 38 2d             	cmpb   $0x2d,(%eax)
  800e2b:	75 06                	jne    800e33 <argnext+0x6b>
  800e2d:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  800e31:	74 0e                	je     800e41 <argnext+0x79>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  800e33:	8b 53 08             	mov    0x8(%ebx),%edx
  800e36:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  800e39:	83 c2 01             	add    $0x1,%edx
  800e3c:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  800e3f:	eb 13                	jmp    800e54 <argnext+0x8c>

    endofargs:
	args->curarg = 0;
  800e41:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  800e48:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800e4d:	eb 05                	jmp    800e54 <argnext+0x8c>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  800e4f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  800e54:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e57:	c9                   	leave  
  800e58:	c3                   	ret    

00800e59 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  800e59:	55                   	push   %ebp
  800e5a:	89 e5                	mov    %esp,%ebp
  800e5c:	53                   	push   %ebx
  800e5d:	83 ec 04             	sub    $0x4,%esp
  800e60:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  800e63:	8b 43 08             	mov    0x8(%ebx),%eax
  800e66:	85 c0                	test   %eax,%eax
  800e68:	74 58                	je     800ec2 <argnextvalue+0x69>
		return 0;
	if (*args->curarg) {
  800e6a:	80 38 00             	cmpb   $0x0,(%eax)
  800e6d:	74 0c                	je     800e7b <argnextvalue+0x22>
		args->argvalue = args->curarg;
  800e6f:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  800e72:	c7 43 08 91 25 80 00 	movl   $0x802591,0x8(%ebx)
  800e79:	eb 42                	jmp    800ebd <argnextvalue+0x64>
	} else if (*args->argc > 1) {
  800e7b:	8b 13                	mov    (%ebx),%edx
  800e7d:	83 3a 01             	cmpl   $0x1,(%edx)
  800e80:	7e 2d                	jle    800eaf <argnextvalue+0x56>
		args->argvalue = args->argv[1];
  800e82:	8b 43 04             	mov    0x4(%ebx),%eax
  800e85:	8b 48 04             	mov    0x4(%eax),%ecx
  800e88:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800e8b:	83 ec 04             	sub    $0x4,%esp
  800e8e:	8b 12                	mov    (%edx),%edx
  800e90:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  800e97:	52                   	push   %edx
  800e98:	8d 50 08             	lea    0x8(%eax),%edx
  800e9b:	52                   	push   %edx
  800e9c:	83 c0 04             	add    $0x4,%eax
  800e9f:	50                   	push   %eax
  800ea0:	e8 72 fa ff ff       	call   800917 <memmove>
		(*args->argc)--;
  800ea5:	8b 03                	mov    (%ebx),%eax
  800ea7:	83 28 01             	subl   $0x1,(%eax)
  800eaa:	83 c4 10             	add    $0x10,%esp
  800ead:	eb 0e                	jmp    800ebd <argnextvalue+0x64>
	} else {
		args->argvalue = 0;
  800eaf:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  800eb6:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  800ebd:	8b 43 0c             	mov    0xc(%ebx),%eax
  800ec0:	eb 05                	jmp    800ec7 <argnextvalue+0x6e>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  800ec2:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  800ec7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800eca:	c9                   	leave  
  800ecb:	c3                   	ret    

00800ecc <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  800ecc:	55                   	push   %ebp
  800ecd:	89 e5                	mov    %esp,%ebp
  800ecf:	83 ec 08             	sub    $0x8,%esp
  800ed2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  800ed5:	8b 51 0c             	mov    0xc(%ecx),%edx
  800ed8:	89 d0                	mov    %edx,%eax
  800eda:	85 d2                	test   %edx,%edx
  800edc:	75 0c                	jne    800eea <argvalue+0x1e>
  800ede:	83 ec 0c             	sub    $0xc,%esp
  800ee1:	51                   	push   %ecx
  800ee2:	e8 72 ff ff ff       	call   800e59 <argnextvalue>
  800ee7:	83 c4 10             	add    $0x10,%esp
}
  800eea:	c9                   	leave  
  800eeb:	c3                   	ret    

00800eec <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800eec:	55                   	push   %ebp
  800eed:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800eef:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef2:	05 00 00 00 30       	add    $0x30000000,%eax
  800ef7:	c1 e8 0c             	shr    $0xc,%eax
}
  800efa:	5d                   	pop    %ebp
  800efb:	c3                   	ret    

00800efc <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800efc:	55                   	push   %ebp
  800efd:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800eff:	8b 45 08             	mov    0x8(%ebp),%eax
  800f02:	05 00 00 00 30       	add    $0x30000000,%eax
  800f07:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f0c:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800f11:	5d                   	pop    %ebp
  800f12:	c3                   	ret    

00800f13 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f13:	55                   	push   %ebp
  800f14:	89 e5                	mov    %esp,%ebp
  800f16:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f19:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f1e:	89 c2                	mov    %eax,%edx
  800f20:	c1 ea 16             	shr    $0x16,%edx
  800f23:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f2a:	f6 c2 01             	test   $0x1,%dl
  800f2d:	74 11                	je     800f40 <fd_alloc+0x2d>
  800f2f:	89 c2                	mov    %eax,%edx
  800f31:	c1 ea 0c             	shr    $0xc,%edx
  800f34:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f3b:	f6 c2 01             	test   $0x1,%dl
  800f3e:	75 09                	jne    800f49 <fd_alloc+0x36>
			*fd_store = fd;
  800f40:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f42:	b8 00 00 00 00       	mov    $0x0,%eax
  800f47:	eb 17                	jmp    800f60 <fd_alloc+0x4d>
  800f49:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f4e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f53:	75 c9                	jne    800f1e <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f55:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800f5b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f60:	5d                   	pop    %ebp
  800f61:	c3                   	ret    

00800f62 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f62:	55                   	push   %ebp
  800f63:	89 e5                	mov    %esp,%ebp
  800f65:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f68:	83 f8 1f             	cmp    $0x1f,%eax
  800f6b:	77 36                	ja     800fa3 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f6d:	c1 e0 0c             	shl    $0xc,%eax
  800f70:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f75:	89 c2                	mov    %eax,%edx
  800f77:	c1 ea 16             	shr    $0x16,%edx
  800f7a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f81:	f6 c2 01             	test   $0x1,%dl
  800f84:	74 24                	je     800faa <fd_lookup+0x48>
  800f86:	89 c2                	mov    %eax,%edx
  800f88:	c1 ea 0c             	shr    $0xc,%edx
  800f8b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f92:	f6 c2 01             	test   $0x1,%dl
  800f95:	74 1a                	je     800fb1 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f97:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f9a:	89 02                	mov    %eax,(%edx)
	return 0;
  800f9c:	b8 00 00 00 00       	mov    $0x0,%eax
  800fa1:	eb 13                	jmp    800fb6 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800fa3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fa8:	eb 0c                	jmp    800fb6 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800faa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800faf:	eb 05                	jmp    800fb6 <fd_lookup+0x54>
  800fb1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800fb6:	5d                   	pop    %ebp
  800fb7:	c3                   	ret    

00800fb8 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800fb8:	55                   	push   %ebp
  800fb9:	89 e5                	mov    %esp,%ebp
  800fbb:	83 ec 08             	sub    $0x8,%esp
  800fbe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fc1:	ba 68 29 80 00       	mov    $0x802968,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800fc6:	eb 13                	jmp    800fdb <dev_lookup+0x23>
  800fc8:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800fcb:	39 08                	cmp    %ecx,(%eax)
  800fcd:	75 0c                	jne    800fdb <dev_lookup+0x23>
			*dev = devtab[i];
  800fcf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fd2:	89 01                	mov    %eax,(%ecx)
			return 0;
  800fd4:	b8 00 00 00 00       	mov    $0x0,%eax
  800fd9:	eb 2e                	jmp    801009 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800fdb:	8b 02                	mov    (%edx),%eax
  800fdd:	85 c0                	test   %eax,%eax
  800fdf:	75 e7                	jne    800fc8 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800fe1:	a1 08 40 80 00       	mov    0x804008,%eax
  800fe6:	8b 40 48             	mov    0x48(%eax),%eax
  800fe9:	83 ec 04             	sub    $0x4,%esp
  800fec:	51                   	push   %ecx
  800fed:	50                   	push   %eax
  800fee:	68 ec 28 80 00       	push   $0x8028ec
  800ff3:	e8 08 f2 ff ff       	call   800200 <cprintf>
	*dev = 0;
  800ff8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ffb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801001:	83 c4 10             	add    $0x10,%esp
  801004:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801009:	c9                   	leave  
  80100a:	c3                   	ret    

0080100b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80100b:	55                   	push   %ebp
  80100c:	89 e5                	mov    %esp,%ebp
  80100e:	56                   	push   %esi
  80100f:	53                   	push   %ebx
  801010:	83 ec 10             	sub    $0x10,%esp
  801013:	8b 75 08             	mov    0x8(%ebp),%esi
  801016:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801019:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80101c:	50                   	push   %eax
  80101d:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801023:	c1 e8 0c             	shr    $0xc,%eax
  801026:	50                   	push   %eax
  801027:	e8 36 ff ff ff       	call   800f62 <fd_lookup>
  80102c:	83 c4 08             	add    $0x8,%esp
  80102f:	85 c0                	test   %eax,%eax
  801031:	78 05                	js     801038 <fd_close+0x2d>
	    || fd != fd2)
  801033:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801036:	74 0c                	je     801044 <fd_close+0x39>
		return (must_exist ? r : 0);
  801038:	84 db                	test   %bl,%bl
  80103a:	ba 00 00 00 00       	mov    $0x0,%edx
  80103f:	0f 44 c2             	cmove  %edx,%eax
  801042:	eb 41                	jmp    801085 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801044:	83 ec 08             	sub    $0x8,%esp
  801047:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80104a:	50                   	push   %eax
  80104b:	ff 36                	pushl  (%esi)
  80104d:	e8 66 ff ff ff       	call   800fb8 <dev_lookup>
  801052:	89 c3                	mov    %eax,%ebx
  801054:	83 c4 10             	add    $0x10,%esp
  801057:	85 c0                	test   %eax,%eax
  801059:	78 1a                	js     801075 <fd_close+0x6a>
		if (dev->dev_close)
  80105b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80105e:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801061:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801066:	85 c0                	test   %eax,%eax
  801068:	74 0b                	je     801075 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80106a:	83 ec 0c             	sub    $0xc,%esp
  80106d:	56                   	push   %esi
  80106e:	ff d0                	call   *%eax
  801070:	89 c3                	mov    %eax,%ebx
  801072:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801075:	83 ec 08             	sub    $0x8,%esp
  801078:	56                   	push   %esi
  801079:	6a 00                	push   $0x0
  80107b:	e8 8d fb ff ff       	call   800c0d <sys_page_unmap>
	return r;
  801080:	83 c4 10             	add    $0x10,%esp
  801083:	89 d8                	mov    %ebx,%eax
}
  801085:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801088:	5b                   	pop    %ebx
  801089:	5e                   	pop    %esi
  80108a:	5d                   	pop    %ebp
  80108b:	c3                   	ret    

0080108c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80108c:	55                   	push   %ebp
  80108d:	89 e5                	mov    %esp,%ebp
  80108f:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801092:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801095:	50                   	push   %eax
  801096:	ff 75 08             	pushl  0x8(%ebp)
  801099:	e8 c4 fe ff ff       	call   800f62 <fd_lookup>
  80109e:	83 c4 08             	add    $0x8,%esp
  8010a1:	85 c0                	test   %eax,%eax
  8010a3:	78 10                	js     8010b5 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8010a5:	83 ec 08             	sub    $0x8,%esp
  8010a8:	6a 01                	push   $0x1
  8010aa:	ff 75 f4             	pushl  -0xc(%ebp)
  8010ad:	e8 59 ff ff ff       	call   80100b <fd_close>
  8010b2:	83 c4 10             	add    $0x10,%esp
}
  8010b5:	c9                   	leave  
  8010b6:	c3                   	ret    

008010b7 <close_all>:

void
close_all(void)
{
  8010b7:	55                   	push   %ebp
  8010b8:	89 e5                	mov    %esp,%ebp
  8010ba:	53                   	push   %ebx
  8010bb:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8010be:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8010c3:	83 ec 0c             	sub    $0xc,%esp
  8010c6:	53                   	push   %ebx
  8010c7:	e8 c0 ff ff ff       	call   80108c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8010cc:	83 c3 01             	add    $0x1,%ebx
  8010cf:	83 c4 10             	add    $0x10,%esp
  8010d2:	83 fb 20             	cmp    $0x20,%ebx
  8010d5:	75 ec                	jne    8010c3 <close_all+0xc>
		close(i);
}
  8010d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010da:	c9                   	leave  
  8010db:	c3                   	ret    

008010dc <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8010dc:	55                   	push   %ebp
  8010dd:	89 e5                	mov    %esp,%ebp
  8010df:	57                   	push   %edi
  8010e0:	56                   	push   %esi
  8010e1:	53                   	push   %ebx
  8010e2:	83 ec 2c             	sub    $0x2c,%esp
  8010e5:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010e8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010eb:	50                   	push   %eax
  8010ec:	ff 75 08             	pushl  0x8(%ebp)
  8010ef:	e8 6e fe ff ff       	call   800f62 <fd_lookup>
  8010f4:	83 c4 08             	add    $0x8,%esp
  8010f7:	85 c0                	test   %eax,%eax
  8010f9:	0f 88 c1 00 00 00    	js     8011c0 <dup+0xe4>
		return r;
	close(newfdnum);
  8010ff:	83 ec 0c             	sub    $0xc,%esp
  801102:	56                   	push   %esi
  801103:	e8 84 ff ff ff       	call   80108c <close>

	newfd = INDEX2FD(newfdnum);
  801108:	89 f3                	mov    %esi,%ebx
  80110a:	c1 e3 0c             	shl    $0xc,%ebx
  80110d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801113:	83 c4 04             	add    $0x4,%esp
  801116:	ff 75 e4             	pushl  -0x1c(%ebp)
  801119:	e8 de fd ff ff       	call   800efc <fd2data>
  80111e:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801120:	89 1c 24             	mov    %ebx,(%esp)
  801123:	e8 d4 fd ff ff       	call   800efc <fd2data>
  801128:	83 c4 10             	add    $0x10,%esp
  80112b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80112e:	89 f8                	mov    %edi,%eax
  801130:	c1 e8 16             	shr    $0x16,%eax
  801133:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80113a:	a8 01                	test   $0x1,%al
  80113c:	74 37                	je     801175 <dup+0x99>
  80113e:	89 f8                	mov    %edi,%eax
  801140:	c1 e8 0c             	shr    $0xc,%eax
  801143:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80114a:	f6 c2 01             	test   $0x1,%dl
  80114d:	74 26                	je     801175 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80114f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801156:	83 ec 0c             	sub    $0xc,%esp
  801159:	25 07 0e 00 00       	and    $0xe07,%eax
  80115e:	50                   	push   %eax
  80115f:	ff 75 d4             	pushl  -0x2c(%ebp)
  801162:	6a 00                	push   $0x0
  801164:	57                   	push   %edi
  801165:	6a 00                	push   $0x0
  801167:	e8 5f fa ff ff       	call   800bcb <sys_page_map>
  80116c:	89 c7                	mov    %eax,%edi
  80116e:	83 c4 20             	add    $0x20,%esp
  801171:	85 c0                	test   %eax,%eax
  801173:	78 2e                	js     8011a3 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801175:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801178:	89 d0                	mov    %edx,%eax
  80117a:	c1 e8 0c             	shr    $0xc,%eax
  80117d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801184:	83 ec 0c             	sub    $0xc,%esp
  801187:	25 07 0e 00 00       	and    $0xe07,%eax
  80118c:	50                   	push   %eax
  80118d:	53                   	push   %ebx
  80118e:	6a 00                	push   $0x0
  801190:	52                   	push   %edx
  801191:	6a 00                	push   $0x0
  801193:	e8 33 fa ff ff       	call   800bcb <sys_page_map>
  801198:	89 c7                	mov    %eax,%edi
  80119a:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80119d:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80119f:	85 ff                	test   %edi,%edi
  8011a1:	79 1d                	jns    8011c0 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8011a3:	83 ec 08             	sub    $0x8,%esp
  8011a6:	53                   	push   %ebx
  8011a7:	6a 00                	push   $0x0
  8011a9:	e8 5f fa ff ff       	call   800c0d <sys_page_unmap>
	sys_page_unmap(0, nva);
  8011ae:	83 c4 08             	add    $0x8,%esp
  8011b1:	ff 75 d4             	pushl  -0x2c(%ebp)
  8011b4:	6a 00                	push   $0x0
  8011b6:	e8 52 fa ff ff       	call   800c0d <sys_page_unmap>
	return r;
  8011bb:	83 c4 10             	add    $0x10,%esp
  8011be:	89 f8                	mov    %edi,%eax
}
  8011c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011c3:	5b                   	pop    %ebx
  8011c4:	5e                   	pop    %esi
  8011c5:	5f                   	pop    %edi
  8011c6:	5d                   	pop    %ebp
  8011c7:	c3                   	ret    

008011c8 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8011c8:	55                   	push   %ebp
  8011c9:	89 e5                	mov    %esp,%ebp
  8011cb:	53                   	push   %ebx
  8011cc:	83 ec 14             	sub    $0x14,%esp
  8011cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011d2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011d5:	50                   	push   %eax
  8011d6:	53                   	push   %ebx
  8011d7:	e8 86 fd ff ff       	call   800f62 <fd_lookup>
  8011dc:	83 c4 08             	add    $0x8,%esp
  8011df:	89 c2                	mov    %eax,%edx
  8011e1:	85 c0                	test   %eax,%eax
  8011e3:	78 6d                	js     801252 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011e5:	83 ec 08             	sub    $0x8,%esp
  8011e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011eb:	50                   	push   %eax
  8011ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011ef:	ff 30                	pushl  (%eax)
  8011f1:	e8 c2 fd ff ff       	call   800fb8 <dev_lookup>
  8011f6:	83 c4 10             	add    $0x10,%esp
  8011f9:	85 c0                	test   %eax,%eax
  8011fb:	78 4c                	js     801249 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011fd:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801200:	8b 42 08             	mov    0x8(%edx),%eax
  801203:	83 e0 03             	and    $0x3,%eax
  801206:	83 f8 01             	cmp    $0x1,%eax
  801209:	75 21                	jne    80122c <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80120b:	a1 08 40 80 00       	mov    0x804008,%eax
  801210:	8b 40 48             	mov    0x48(%eax),%eax
  801213:	83 ec 04             	sub    $0x4,%esp
  801216:	53                   	push   %ebx
  801217:	50                   	push   %eax
  801218:	68 2d 29 80 00       	push   $0x80292d
  80121d:	e8 de ef ff ff       	call   800200 <cprintf>
		return -E_INVAL;
  801222:	83 c4 10             	add    $0x10,%esp
  801225:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80122a:	eb 26                	jmp    801252 <read+0x8a>
	}
	if (!dev->dev_read)
  80122c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80122f:	8b 40 08             	mov    0x8(%eax),%eax
  801232:	85 c0                	test   %eax,%eax
  801234:	74 17                	je     80124d <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801236:	83 ec 04             	sub    $0x4,%esp
  801239:	ff 75 10             	pushl  0x10(%ebp)
  80123c:	ff 75 0c             	pushl  0xc(%ebp)
  80123f:	52                   	push   %edx
  801240:	ff d0                	call   *%eax
  801242:	89 c2                	mov    %eax,%edx
  801244:	83 c4 10             	add    $0x10,%esp
  801247:	eb 09                	jmp    801252 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801249:	89 c2                	mov    %eax,%edx
  80124b:	eb 05                	jmp    801252 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80124d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801252:	89 d0                	mov    %edx,%eax
  801254:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801257:	c9                   	leave  
  801258:	c3                   	ret    

00801259 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801259:	55                   	push   %ebp
  80125a:	89 e5                	mov    %esp,%ebp
  80125c:	57                   	push   %edi
  80125d:	56                   	push   %esi
  80125e:	53                   	push   %ebx
  80125f:	83 ec 0c             	sub    $0xc,%esp
  801262:	8b 7d 08             	mov    0x8(%ebp),%edi
  801265:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801268:	bb 00 00 00 00       	mov    $0x0,%ebx
  80126d:	eb 21                	jmp    801290 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80126f:	83 ec 04             	sub    $0x4,%esp
  801272:	89 f0                	mov    %esi,%eax
  801274:	29 d8                	sub    %ebx,%eax
  801276:	50                   	push   %eax
  801277:	89 d8                	mov    %ebx,%eax
  801279:	03 45 0c             	add    0xc(%ebp),%eax
  80127c:	50                   	push   %eax
  80127d:	57                   	push   %edi
  80127e:	e8 45 ff ff ff       	call   8011c8 <read>
		if (m < 0)
  801283:	83 c4 10             	add    $0x10,%esp
  801286:	85 c0                	test   %eax,%eax
  801288:	78 10                	js     80129a <readn+0x41>
			return m;
		if (m == 0)
  80128a:	85 c0                	test   %eax,%eax
  80128c:	74 0a                	je     801298 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80128e:	01 c3                	add    %eax,%ebx
  801290:	39 f3                	cmp    %esi,%ebx
  801292:	72 db                	jb     80126f <readn+0x16>
  801294:	89 d8                	mov    %ebx,%eax
  801296:	eb 02                	jmp    80129a <readn+0x41>
  801298:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80129a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80129d:	5b                   	pop    %ebx
  80129e:	5e                   	pop    %esi
  80129f:	5f                   	pop    %edi
  8012a0:	5d                   	pop    %ebp
  8012a1:	c3                   	ret    

008012a2 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8012a2:	55                   	push   %ebp
  8012a3:	89 e5                	mov    %esp,%ebp
  8012a5:	53                   	push   %ebx
  8012a6:	83 ec 14             	sub    $0x14,%esp
  8012a9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012ac:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012af:	50                   	push   %eax
  8012b0:	53                   	push   %ebx
  8012b1:	e8 ac fc ff ff       	call   800f62 <fd_lookup>
  8012b6:	83 c4 08             	add    $0x8,%esp
  8012b9:	89 c2                	mov    %eax,%edx
  8012bb:	85 c0                	test   %eax,%eax
  8012bd:	78 68                	js     801327 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012bf:	83 ec 08             	sub    $0x8,%esp
  8012c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012c5:	50                   	push   %eax
  8012c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c9:	ff 30                	pushl  (%eax)
  8012cb:	e8 e8 fc ff ff       	call   800fb8 <dev_lookup>
  8012d0:	83 c4 10             	add    $0x10,%esp
  8012d3:	85 c0                	test   %eax,%eax
  8012d5:	78 47                	js     80131e <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012da:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012de:	75 21                	jne    801301 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8012e0:	a1 08 40 80 00       	mov    0x804008,%eax
  8012e5:	8b 40 48             	mov    0x48(%eax),%eax
  8012e8:	83 ec 04             	sub    $0x4,%esp
  8012eb:	53                   	push   %ebx
  8012ec:	50                   	push   %eax
  8012ed:	68 49 29 80 00       	push   $0x802949
  8012f2:	e8 09 ef ff ff       	call   800200 <cprintf>
		return -E_INVAL;
  8012f7:	83 c4 10             	add    $0x10,%esp
  8012fa:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012ff:	eb 26                	jmp    801327 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801301:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801304:	8b 52 0c             	mov    0xc(%edx),%edx
  801307:	85 d2                	test   %edx,%edx
  801309:	74 17                	je     801322 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80130b:	83 ec 04             	sub    $0x4,%esp
  80130e:	ff 75 10             	pushl  0x10(%ebp)
  801311:	ff 75 0c             	pushl  0xc(%ebp)
  801314:	50                   	push   %eax
  801315:	ff d2                	call   *%edx
  801317:	89 c2                	mov    %eax,%edx
  801319:	83 c4 10             	add    $0x10,%esp
  80131c:	eb 09                	jmp    801327 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80131e:	89 c2                	mov    %eax,%edx
  801320:	eb 05                	jmp    801327 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801322:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801327:	89 d0                	mov    %edx,%eax
  801329:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80132c:	c9                   	leave  
  80132d:	c3                   	ret    

0080132e <seek>:

int
seek(int fdnum, off_t offset)
{
  80132e:	55                   	push   %ebp
  80132f:	89 e5                	mov    %esp,%ebp
  801331:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801334:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801337:	50                   	push   %eax
  801338:	ff 75 08             	pushl  0x8(%ebp)
  80133b:	e8 22 fc ff ff       	call   800f62 <fd_lookup>
  801340:	83 c4 08             	add    $0x8,%esp
  801343:	85 c0                	test   %eax,%eax
  801345:	78 0e                	js     801355 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801347:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80134a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80134d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801350:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801355:	c9                   	leave  
  801356:	c3                   	ret    

00801357 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801357:	55                   	push   %ebp
  801358:	89 e5                	mov    %esp,%ebp
  80135a:	53                   	push   %ebx
  80135b:	83 ec 14             	sub    $0x14,%esp
  80135e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801361:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801364:	50                   	push   %eax
  801365:	53                   	push   %ebx
  801366:	e8 f7 fb ff ff       	call   800f62 <fd_lookup>
  80136b:	83 c4 08             	add    $0x8,%esp
  80136e:	89 c2                	mov    %eax,%edx
  801370:	85 c0                	test   %eax,%eax
  801372:	78 65                	js     8013d9 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801374:	83 ec 08             	sub    $0x8,%esp
  801377:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80137a:	50                   	push   %eax
  80137b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80137e:	ff 30                	pushl  (%eax)
  801380:	e8 33 fc ff ff       	call   800fb8 <dev_lookup>
  801385:	83 c4 10             	add    $0x10,%esp
  801388:	85 c0                	test   %eax,%eax
  80138a:	78 44                	js     8013d0 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80138c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80138f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801393:	75 21                	jne    8013b6 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801395:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80139a:	8b 40 48             	mov    0x48(%eax),%eax
  80139d:	83 ec 04             	sub    $0x4,%esp
  8013a0:	53                   	push   %ebx
  8013a1:	50                   	push   %eax
  8013a2:	68 0c 29 80 00       	push   $0x80290c
  8013a7:	e8 54 ee ff ff       	call   800200 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8013ac:	83 c4 10             	add    $0x10,%esp
  8013af:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013b4:	eb 23                	jmp    8013d9 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8013b6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013b9:	8b 52 18             	mov    0x18(%edx),%edx
  8013bc:	85 d2                	test   %edx,%edx
  8013be:	74 14                	je     8013d4 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8013c0:	83 ec 08             	sub    $0x8,%esp
  8013c3:	ff 75 0c             	pushl  0xc(%ebp)
  8013c6:	50                   	push   %eax
  8013c7:	ff d2                	call   *%edx
  8013c9:	89 c2                	mov    %eax,%edx
  8013cb:	83 c4 10             	add    $0x10,%esp
  8013ce:	eb 09                	jmp    8013d9 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013d0:	89 c2                	mov    %eax,%edx
  8013d2:	eb 05                	jmp    8013d9 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8013d4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8013d9:	89 d0                	mov    %edx,%eax
  8013db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013de:	c9                   	leave  
  8013df:	c3                   	ret    

008013e0 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8013e0:	55                   	push   %ebp
  8013e1:	89 e5                	mov    %esp,%ebp
  8013e3:	53                   	push   %ebx
  8013e4:	83 ec 14             	sub    $0x14,%esp
  8013e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013ea:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013ed:	50                   	push   %eax
  8013ee:	ff 75 08             	pushl  0x8(%ebp)
  8013f1:	e8 6c fb ff ff       	call   800f62 <fd_lookup>
  8013f6:	83 c4 08             	add    $0x8,%esp
  8013f9:	89 c2                	mov    %eax,%edx
  8013fb:	85 c0                	test   %eax,%eax
  8013fd:	78 58                	js     801457 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013ff:	83 ec 08             	sub    $0x8,%esp
  801402:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801405:	50                   	push   %eax
  801406:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801409:	ff 30                	pushl  (%eax)
  80140b:	e8 a8 fb ff ff       	call   800fb8 <dev_lookup>
  801410:	83 c4 10             	add    $0x10,%esp
  801413:	85 c0                	test   %eax,%eax
  801415:	78 37                	js     80144e <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801417:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80141a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80141e:	74 32                	je     801452 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801420:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801423:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80142a:	00 00 00 
	stat->st_isdir = 0;
  80142d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801434:	00 00 00 
	stat->st_dev = dev;
  801437:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80143d:	83 ec 08             	sub    $0x8,%esp
  801440:	53                   	push   %ebx
  801441:	ff 75 f0             	pushl  -0x10(%ebp)
  801444:	ff 50 14             	call   *0x14(%eax)
  801447:	89 c2                	mov    %eax,%edx
  801449:	83 c4 10             	add    $0x10,%esp
  80144c:	eb 09                	jmp    801457 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80144e:	89 c2                	mov    %eax,%edx
  801450:	eb 05                	jmp    801457 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801452:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801457:	89 d0                	mov    %edx,%eax
  801459:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80145c:	c9                   	leave  
  80145d:	c3                   	ret    

0080145e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80145e:	55                   	push   %ebp
  80145f:	89 e5                	mov    %esp,%ebp
  801461:	56                   	push   %esi
  801462:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801463:	83 ec 08             	sub    $0x8,%esp
  801466:	6a 00                	push   $0x0
  801468:	ff 75 08             	pushl  0x8(%ebp)
  80146b:	e8 0c 02 00 00       	call   80167c <open>
  801470:	89 c3                	mov    %eax,%ebx
  801472:	83 c4 10             	add    $0x10,%esp
  801475:	85 c0                	test   %eax,%eax
  801477:	78 1b                	js     801494 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801479:	83 ec 08             	sub    $0x8,%esp
  80147c:	ff 75 0c             	pushl  0xc(%ebp)
  80147f:	50                   	push   %eax
  801480:	e8 5b ff ff ff       	call   8013e0 <fstat>
  801485:	89 c6                	mov    %eax,%esi
	close(fd);
  801487:	89 1c 24             	mov    %ebx,(%esp)
  80148a:	e8 fd fb ff ff       	call   80108c <close>
	return r;
  80148f:	83 c4 10             	add    $0x10,%esp
  801492:	89 f0                	mov    %esi,%eax
}
  801494:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801497:	5b                   	pop    %ebx
  801498:	5e                   	pop    %esi
  801499:	5d                   	pop    %ebp
  80149a:	c3                   	ret    

0080149b <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80149b:	55                   	push   %ebp
  80149c:	89 e5                	mov    %esp,%ebp
  80149e:	56                   	push   %esi
  80149f:	53                   	push   %ebx
  8014a0:	89 c6                	mov    %eax,%esi
  8014a2:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8014a4:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8014ab:	75 12                	jne    8014bf <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8014ad:	83 ec 0c             	sub    $0xc,%esp
  8014b0:	6a 01                	push   $0x1
  8014b2:	e8 c2 0d 00 00       	call   802279 <ipc_find_env>
  8014b7:	a3 00 40 80 00       	mov    %eax,0x804000
  8014bc:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8014bf:	6a 07                	push   $0x7
  8014c1:	68 00 50 80 00       	push   $0x805000
  8014c6:	56                   	push   %esi
  8014c7:	ff 35 00 40 80 00    	pushl  0x804000
  8014cd:	e8 53 0d 00 00       	call   802225 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8014d2:	83 c4 0c             	add    $0xc,%esp
  8014d5:	6a 00                	push   $0x0
  8014d7:	53                   	push   %ebx
  8014d8:	6a 00                	push   $0x0
  8014da:	e8 dd 0c 00 00       	call   8021bc <ipc_recv>
}
  8014df:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014e2:	5b                   	pop    %ebx
  8014e3:	5e                   	pop    %esi
  8014e4:	5d                   	pop    %ebp
  8014e5:	c3                   	ret    

008014e6 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8014e6:	55                   	push   %ebp
  8014e7:	89 e5                	mov    %esp,%ebp
  8014e9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8014ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ef:	8b 40 0c             	mov    0xc(%eax),%eax
  8014f2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8014f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014fa:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8014ff:	ba 00 00 00 00       	mov    $0x0,%edx
  801504:	b8 02 00 00 00       	mov    $0x2,%eax
  801509:	e8 8d ff ff ff       	call   80149b <fsipc>
}
  80150e:	c9                   	leave  
  80150f:	c3                   	ret    

00801510 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801510:	55                   	push   %ebp
  801511:	89 e5                	mov    %esp,%ebp
  801513:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801516:	8b 45 08             	mov    0x8(%ebp),%eax
  801519:	8b 40 0c             	mov    0xc(%eax),%eax
  80151c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801521:	ba 00 00 00 00       	mov    $0x0,%edx
  801526:	b8 06 00 00 00       	mov    $0x6,%eax
  80152b:	e8 6b ff ff ff       	call   80149b <fsipc>
}
  801530:	c9                   	leave  
  801531:	c3                   	ret    

00801532 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801532:	55                   	push   %ebp
  801533:	89 e5                	mov    %esp,%ebp
  801535:	53                   	push   %ebx
  801536:	83 ec 04             	sub    $0x4,%esp
  801539:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80153c:	8b 45 08             	mov    0x8(%ebp),%eax
  80153f:	8b 40 0c             	mov    0xc(%eax),%eax
  801542:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801547:	ba 00 00 00 00       	mov    $0x0,%edx
  80154c:	b8 05 00 00 00       	mov    $0x5,%eax
  801551:	e8 45 ff ff ff       	call   80149b <fsipc>
  801556:	85 c0                	test   %eax,%eax
  801558:	78 2c                	js     801586 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80155a:	83 ec 08             	sub    $0x8,%esp
  80155d:	68 00 50 80 00       	push   $0x805000
  801562:	53                   	push   %ebx
  801563:	e8 1d f2 ff ff       	call   800785 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801568:	a1 80 50 80 00       	mov    0x805080,%eax
  80156d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801573:	a1 84 50 80 00       	mov    0x805084,%eax
  801578:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80157e:	83 c4 10             	add    $0x10,%esp
  801581:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801586:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801589:	c9                   	leave  
  80158a:	c3                   	ret    

0080158b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80158b:	55                   	push   %ebp
  80158c:	89 e5                	mov    %esp,%ebp
  80158e:	53                   	push   %ebx
  80158f:	83 ec 08             	sub    $0x8,%esp
  801592:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801595:	8b 55 08             	mov    0x8(%ebp),%edx
  801598:	8b 52 0c             	mov    0xc(%edx),%edx
  80159b:	89 15 00 50 80 00    	mov    %edx,0x805000
  8015a1:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8015a6:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  8015ab:	0f 46 d8             	cmovbe %eax,%ebx
	
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  8015ae:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  8015b4:	53                   	push   %ebx
  8015b5:	ff 75 0c             	pushl  0xc(%ebp)
  8015b8:	68 08 50 80 00       	push   $0x805008
  8015bd:	e8 55 f3 ff ff       	call   800917 <memmove>

	
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) 
  8015c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8015c7:	b8 04 00 00 00       	mov    $0x4,%eax
  8015cc:	e8 ca fe ff ff       	call   80149b <fsipc>
  8015d1:	83 c4 10             	add    $0x10,%esp
  8015d4:	85 c0                	test   %eax,%eax
  8015d6:	78 1d                	js     8015f5 <devfile_write+0x6a>
		return r;
	assert(r <= n_real); 
  8015d8:	39 d8                	cmp    %ebx,%eax
  8015da:	76 19                	jbe    8015f5 <devfile_write+0x6a>
  8015dc:	68 7c 29 80 00       	push   $0x80297c
  8015e1:	68 88 29 80 00       	push   $0x802988
  8015e6:	68 a3 00 00 00       	push   $0xa3
  8015eb:	68 9d 29 80 00       	push   $0x80299d
  8015f0:	e8 81 0b 00 00       	call   802176 <_panic>
	return r;
}
  8015f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015f8:	c9                   	leave  
  8015f9:	c3                   	ret    

008015fa <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8015fa:	55                   	push   %ebp
  8015fb:	89 e5                	mov    %esp,%ebp
  8015fd:	56                   	push   %esi
  8015fe:	53                   	push   %ebx
  8015ff:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801602:	8b 45 08             	mov    0x8(%ebp),%eax
  801605:	8b 40 0c             	mov    0xc(%eax),%eax
  801608:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80160d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801613:	ba 00 00 00 00       	mov    $0x0,%edx
  801618:	b8 03 00 00 00       	mov    $0x3,%eax
  80161d:	e8 79 fe ff ff       	call   80149b <fsipc>
  801622:	89 c3                	mov    %eax,%ebx
  801624:	85 c0                	test   %eax,%eax
  801626:	78 4b                	js     801673 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801628:	39 c6                	cmp    %eax,%esi
  80162a:	73 16                	jae    801642 <devfile_read+0x48>
  80162c:	68 a8 29 80 00       	push   $0x8029a8
  801631:	68 88 29 80 00       	push   $0x802988
  801636:	6a 7c                	push   $0x7c
  801638:	68 9d 29 80 00       	push   $0x80299d
  80163d:	e8 34 0b 00 00       	call   802176 <_panic>
	assert(r <= PGSIZE);
  801642:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801647:	7e 16                	jle    80165f <devfile_read+0x65>
  801649:	68 af 29 80 00       	push   $0x8029af
  80164e:	68 88 29 80 00       	push   $0x802988
  801653:	6a 7d                	push   $0x7d
  801655:	68 9d 29 80 00       	push   $0x80299d
  80165a:	e8 17 0b 00 00       	call   802176 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80165f:	83 ec 04             	sub    $0x4,%esp
  801662:	50                   	push   %eax
  801663:	68 00 50 80 00       	push   $0x805000
  801668:	ff 75 0c             	pushl  0xc(%ebp)
  80166b:	e8 a7 f2 ff ff       	call   800917 <memmove>
	return r;
  801670:	83 c4 10             	add    $0x10,%esp
}
  801673:	89 d8                	mov    %ebx,%eax
  801675:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801678:	5b                   	pop    %ebx
  801679:	5e                   	pop    %esi
  80167a:	5d                   	pop    %ebp
  80167b:	c3                   	ret    

0080167c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80167c:	55                   	push   %ebp
  80167d:	89 e5                	mov    %esp,%ebp
  80167f:	53                   	push   %ebx
  801680:	83 ec 20             	sub    $0x20,%esp
  801683:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801686:	53                   	push   %ebx
  801687:	e8 c0 f0 ff ff       	call   80074c <strlen>
  80168c:	83 c4 10             	add    $0x10,%esp
  80168f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801694:	7f 67                	jg     8016fd <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801696:	83 ec 0c             	sub    $0xc,%esp
  801699:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80169c:	50                   	push   %eax
  80169d:	e8 71 f8 ff ff       	call   800f13 <fd_alloc>
  8016a2:	83 c4 10             	add    $0x10,%esp
		return r;
  8016a5:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8016a7:	85 c0                	test   %eax,%eax
  8016a9:	78 57                	js     801702 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8016ab:	83 ec 08             	sub    $0x8,%esp
  8016ae:	53                   	push   %ebx
  8016af:	68 00 50 80 00       	push   $0x805000
  8016b4:	e8 cc f0 ff ff       	call   800785 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8016b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016bc:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8016c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016c4:	b8 01 00 00 00       	mov    $0x1,%eax
  8016c9:	e8 cd fd ff ff       	call   80149b <fsipc>
  8016ce:	89 c3                	mov    %eax,%ebx
  8016d0:	83 c4 10             	add    $0x10,%esp
  8016d3:	85 c0                	test   %eax,%eax
  8016d5:	79 14                	jns    8016eb <open+0x6f>
		fd_close(fd, 0);
  8016d7:	83 ec 08             	sub    $0x8,%esp
  8016da:	6a 00                	push   $0x0
  8016dc:	ff 75 f4             	pushl  -0xc(%ebp)
  8016df:	e8 27 f9 ff ff       	call   80100b <fd_close>
		return r;
  8016e4:	83 c4 10             	add    $0x10,%esp
  8016e7:	89 da                	mov    %ebx,%edx
  8016e9:	eb 17                	jmp    801702 <open+0x86>
	}

	return fd2num(fd);
  8016eb:	83 ec 0c             	sub    $0xc,%esp
  8016ee:	ff 75 f4             	pushl  -0xc(%ebp)
  8016f1:	e8 f6 f7 ff ff       	call   800eec <fd2num>
  8016f6:	89 c2                	mov    %eax,%edx
  8016f8:	83 c4 10             	add    $0x10,%esp
  8016fb:	eb 05                	jmp    801702 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8016fd:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801702:	89 d0                	mov    %edx,%eax
  801704:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801707:	c9                   	leave  
  801708:	c3                   	ret    

00801709 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801709:	55                   	push   %ebp
  80170a:	89 e5                	mov    %esp,%ebp
  80170c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80170f:	ba 00 00 00 00       	mov    $0x0,%edx
  801714:	b8 08 00 00 00       	mov    $0x8,%eax
  801719:	e8 7d fd ff ff       	call   80149b <fsipc>
}
  80171e:	c9                   	leave  
  80171f:	c3                   	ret    

00801720 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801720:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801724:	7e 37                	jle    80175d <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  801726:	55                   	push   %ebp
  801727:	89 e5                	mov    %esp,%ebp
  801729:	53                   	push   %ebx
  80172a:	83 ec 08             	sub    $0x8,%esp
  80172d:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  80172f:	ff 70 04             	pushl  0x4(%eax)
  801732:	8d 40 10             	lea    0x10(%eax),%eax
  801735:	50                   	push   %eax
  801736:	ff 33                	pushl  (%ebx)
  801738:	e8 65 fb ff ff       	call   8012a2 <write>
		if (result > 0)
  80173d:	83 c4 10             	add    $0x10,%esp
  801740:	85 c0                	test   %eax,%eax
  801742:	7e 03                	jle    801747 <writebuf+0x27>
			b->result += result;
  801744:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801747:	3b 43 04             	cmp    0x4(%ebx),%eax
  80174a:	74 0d                	je     801759 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  80174c:	85 c0                	test   %eax,%eax
  80174e:	ba 00 00 00 00       	mov    $0x0,%edx
  801753:	0f 4f c2             	cmovg  %edx,%eax
  801756:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801759:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80175c:	c9                   	leave  
  80175d:	f3 c3                	repz ret 

0080175f <putch>:

static void
putch(int ch, void *thunk)
{
  80175f:	55                   	push   %ebp
  801760:	89 e5                	mov    %esp,%ebp
  801762:	53                   	push   %ebx
  801763:	83 ec 04             	sub    $0x4,%esp
  801766:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801769:	8b 53 04             	mov    0x4(%ebx),%edx
  80176c:	8d 42 01             	lea    0x1(%edx),%eax
  80176f:	89 43 04             	mov    %eax,0x4(%ebx)
  801772:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801775:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  801779:	3d 00 01 00 00       	cmp    $0x100,%eax
  80177e:	75 0e                	jne    80178e <putch+0x2f>
		writebuf(b);
  801780:	89 d8                	mov    %ebx,%eax
  801782:	e8 99 ff ff ff       	call   801720 <writebuf>
		b->idx = 0;
  801787:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  80178e:	83 c4 04             	add    $0x4,%esp
  801791:	5b                   	pop    %ebx
  801792:	5d                   	pop    %ebp
  801793:	c3                   	ret    

00801794 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801794:	55                   	push   %ebp
  801795:	89 e5                	mov    %esp,%ebp
  801797:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  80179d:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a0:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8017a6:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8017ad:	00 00 00 
	b.result = 0;
  8017b0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8017b7:	00 00 00 
	b.error = 1;
  8017ba:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8017c1:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8017c4:	ff 75 10             	pushl  0x10(%ebp)
  8017c7:	ff 75 0c             	pushl  0xc(%ebp)
  8017ca:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8017d0:	50                   	push   %eax
  8017d1:	68 5f 17 80 00       	push   $0x80175f
  8017d6:	e8 5c eb ff ff       	call   800337 <vprintfmt>
	if (b.idx > 0)
  8017db:	83 c4 10             	add    $0x10,%esp
  8017de:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8017e5:	7e 0b                	jle    8017f2 <vfprintf+0x5e>
		writebuf(&b);
  8017e7:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8017ed:	e8 2e ff ff ff       	call   801720 <writebuf>

	return (b.result ? b.result : b.error);
  8017f2:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8017f8:	85 c0                	test   %eax,%eax
  8017fa:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801801:	c9                   	leave  
  801802:	c3                   	ret    

00801803 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801803:	55                   	push   %ebp
  801804:	89 e5                	mov    %esp,%ebp
  801806:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801809:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  80180c:	50                   	push   %eax
  80180d:	ff 75 0c             	pushl  0xc(%ebp)
  801810:	ff 75 08             	pushl  0x8(%ebp)
  801813:	e8 7c ff ff ff       	call   801794 <vfprintf>
	va_end(ap);

	return cnt;
}
  801818:	c9                   	leave  
  801819:	c3                   	ret    

0080181a <printf>:

int
printf(const char *fmt, ...)
{
  80181a:	55                   	push   %ebp
  80181b:	89 e5                	mov    %esp,%ebp
  80181d:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801820:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801823:	50                   	push   %eax
  801824:	ff 75 08             	pushl  0x8(%ebp)
  801827:	6a 01                	push   $0x1
  801829:	e8 66 ff ff ff       	call   801794 <vfprintf>
	va_end(ap);

	return cnt;
}
  80182e:	c9                   	leave  
  80182f:	c3                   	ret    

00801830 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801830:	55                   	push   %ebp
  801831:	89 e5                	mov    %esp,%ebp
  801833:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801836:	68 bb 29 80 00       	push   $0x8029bb
  80183b:	ff 75 0c             	pushl  0xc(%ebp)
  80183e:	e8 42 ef ff ff       	call   800785 <strcpy>
	return 0;
}
  801843:	b8 00 00 00 00       	mov    $0x0,%eax
  801848:	c9                   	leave  
  801849:	c3                   	ret    

0080184a <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  80184a:	55                   	push   %ebp
  80184b:	89 e5                	mov    %esp,%ebp
  80184d:	53                   	push   %ebx
  80184e:	83 ec 10             	sub    $0x10,%esp
  801851:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801854:	53                   	push   %ebx
  801855:	e8 58 0a 00 00       	call   8022b2 <pageref>
  80185a:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  80185d:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801862:	83 f8 01             	cmp    $0x1,%eax
  801865:	75 10                	jne    801877 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801867:	83 ec 0c             	sub    $0xc,%esp
  80186a:	ff 73 0c             	pushl  0xc(%ebx)
  80186d:	e8 c0 02 00 00       	call   801b32 <nsipc_close>
  801872:	89 c2                	mov    %eax,%edx
  801874:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801877:	89 d0                	mov    %edx,%eax
  801879:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80187c:	c9                   	leave  
  80187d:	c3                   	ret    

0080187e <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  80187e:	55                   	push   %ebp
  80187f:	89 e5                	mov    %esp,%ebp
  801881:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801884:	6a 00                	push   $0x0
  801886:	ff 75 10             	pushl  0x10(%ebp)
  801889:	ff 75 0c             	pushl  0xc(%ebp)
  80188c:	8b 45 08             	mov    0x8(%ebp),%eax
  80188f:	ff 70 0c             	pushl  0xc(%eax)
  801892:	e8 78 03 00 00       	call   801c0f <nsipc_send>
}
  801897:	c9                   	leave  
  801898:	c3                   	ret    

00801899 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801899:	55                   	push   %ebp
  80189a:	89 e5                	mov    %esp,%ebp
  80189c:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  80189f:	6a 00                	push   $0x0
  8018a1:	ff 75 10             	pushl  0x10(%ebp)
  8018a4:	ff 75 0c             	pushl  0xc(%ebp)
  8018a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8018aa:	ff 70 0c             	pushl  0xc(%eax)
  8018ad:	e8 f1 02 00 00       	call   801ba3 <nsipc_recv>
}
  8018b2:	c9                   	leave  
  8018b3:	c3                   	ret    

008018b4 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8018b4:	55                   	push   %ebp
  8018b5:	89 e5                	mov    %esp,%ebp
  8018b7:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8018ba:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8018bd:	52                   	push   %edx
  8018be:	50                   	push   %eax
  8018bf:	e8 9e f6 ff ff       	call   800f62 <fd_lookup>
  8018c4:	83 c4 10             	add    $0x10,%esp
  8018c7:	85 c0                	test   %eax,%eax
  8018c9:	78 17                	js     8018e2 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8018cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018ce:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  8018d4:	39 08                	cmp    %ecx,(%eax)
  8018d6:	75 05                	jne    8018dd <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8018d8:	8b 40 0c             	mov    0xc(%eax),%eax
  8018db:	eb 05                	jmp    8018e2 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  8018dd:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  8018e2:	c9                   	leave  
  8018e3:	c3                   	ret    

008018e4 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  8018e4:	55                   	push   %ebp
  8018e5:	89 e5                	mov    %esp,%ebp
  8018e7:	56                   	push   %esi
  8018e8:	53                   	push   %ebx
  8018e9:	83 ec 1c             	sub    $0x1c,%esp
  8018ec:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8018ee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018f1:	50                   	push   %eax
  8018f2:	e8 1c f6 ff ff       	call   800f13 <fd_alloc>
  8018f7:	89 c3                	mov    %eax,%ebx
  8018f9:	83 c4 10             	add    $0x10,%esp
  8018fc:	85 c0                	test   %eax,%eax
  8018fe:	78 1b                	js     80191b <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801900:	83 ec 04             	sub    $0x4,%esp
  801903:	68 07 04 00 00       	push   $0x407
  801908:	ff 75 f4             	pushl  -0xc(%ebp)
  80190b:	6a 00                	push   $0x0
  80190d:	e8 76 f2 ff ff       	call   800b88 <sys_page_alloc>
  801912:	89 c3                	mov    %eax,%ebx
  801914:	83 c4 10             	add    $0x10,%esp
  801917:	85 c0                	test   %eax,%eax
  801919:	79 10                	jns    80192b <alloc_sockfd+0x47>
		nsipc_close(sockid);
  80191b:	83 ec 0c             	sub    $0xc,%esp
  80191e:	56                   	push   %esi
  80191f:	e8 0e 02 00 00       	call   801b32 <nsipc_close>
		return r;
  801924:	83 c4 10             	add    $0x10,%esp
  801927:	89 d8                	mov    %ebx,%eax
  801929:	eb 24                	jmp    80194f <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  80192b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801931:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801934:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801936:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801939:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801940:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801943:	83 ec 0c             	sub    $0xc,%esp
  801946:	50                   	push   %eax
  801947:	e8 a0 f5 ff ff       	call   800eec <fd2num>
  80194c:	83 c4 10             	add    $0x10,%esp
}
  80194f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801952:	5b                   	pop    %ebx
  801953:	5e                   	pop    %esi
  801954:	5d                   	pop    %ebp
  801955:	c3                   	ret    

00801956 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801956:	55                   	push   %ebp
  801957:	89 e5                	mov    %esp,%ebp
  801959:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80195c:	8b 45 08             	mov    0x8(%ebp),%eax
  80195f:	e8 50 ff ff ff       	call   8018b4 <fd2sockid>
		return r;
  801964:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801966:	85 c0                	test   %eax,%eax
  801968:	78 1f                	js     801989 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80196a:	83 ec 04             	sub    $0x4,%esp
  80196d:	ff 75 10             	pushl  0x10(%ebp)
  801970:	ff 75 0c             	pushl  0xc(%ebp)
  801973:	50                   	push   %eax
  801974:	e8 12 01 00 00       	call   801a8b <nsipc_accept>
  801979:	83 c4 10             	add    $0x10,%esp
		return r;
  80197c:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80197e:	85 c0                	test   %eax,%eax
  801980:	78 07                	js     801989 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801982:	e8 5d ff ff ff       	call   8018e4 <alloc_sockfd>
  801987:	89 c1                	mov    %eax,%ecx
}
  801989:	89 c8                	mov    %ecx,%eax
  80198b:	c9                   	leave  
  80198c:	c3                   	ret    

0080198d <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80198d:	55                   	push   %ebp
  80198e:	89 e5                	mov    %esp,%ebp
  801990:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801993:	8b 45 08             	mov    0x8(%ebp),%eax
  801996:	e8 19 ff ff ff       	call   8018b4 <fd2sockid>
  80199b:	85 c0                	test   %eax,%eax
  80199d:	78 12                	js     8019b1 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  80199f:	83 ec 04             	sub    $0x4,%esp
  8019a2:	ff 75 10             	pushl  0x10(%ebp)
  8019a5:	ff 75 0c             	pushl  0xc(%ebp)
  8019a8:	50                   	push   %eax
  8019a9:	e8 2d 01 00 00       	call   801adb <nsipc_bind>
  8019ae:	83 c4 10             	add    $0x10,%esp
}
  8019b1:	c9                   	leave  
  8019b2:	c3                   	ret    

008019b3 <shutdown>:

int
shutdown(int s, int how)
{
  8019b3:	55                   	push   %ebp
  8019b4:	89 e5                	mov    %esp,%ebp
  8019b6:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8019bc:	e8 f3 fe ff ff       	call   8018b4 <fd2sockid>
  8019c1:	85 c0                	test   %eax,%eax
  8019c3:	78 0f                	js     8019d4 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8019c5:	83 ec 08             	sub    $0x8,%esp
  8019c8:	ff 75 0c             	pushl  0xc(%ebp)
  8019cb:	50                   	push   %eax
  8019cc:	e8 3f 01 00 00       	call   801b10 <nsipc_shutdown>
  8019d1:	83 c4 10             	add    $0x10,%esp
}
  8019d4:	c9                   	leave  
  8019d5:	c3                   	ret    

008019d6 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8019d6:	55                   	push   %ebp
  8019d7:	89 e5                	mov    %esp,%ebp
  8019d9:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8019df:	e8 d0 fe ff ff       	call   8018b4 <fd2sockid>
  8019e4:	85 c0                	test   %eax,%eax
  8019e6:	78 12                	js     8019fa <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  8019e8:	83 ec 04             	sub    $0x4,%esp
  8019eb:	ff 75 10             	pushl  0x10(%ebp)
  8019ee:	ff 75 0c             	pushl  0xc(%ebp)
  8019f1:	50                   	push   %eax
  8019f2:	e8 55 01 00 00       	call   801b4c <nsipc_connect>
  8019f7:	83 c4 10             	add    $0x10,%esp
}
  8019fa:	c9                   	leave  
  8019fb:	c3                   	ret    

008019fc <listen>:

int
listen(int s, int backlog)
{
  8019fc:	55                   	push   %ebp
  8019fd:	89 e5                	mov    %esp,%ebp
  8019ff:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a02:	8b 45 08             	mov    0x8(%ebp),%eax
  801a05:	e8 aa fe ff ff       	call   8018b4 <fd2sockid>
  801a0a:	85 c0                	test   %eax,%eax
  801a0c:	78 0f                	js     801a1d <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801a0e:	83 ec 08             	sub    $0x8,%esp
  801a11:	ff 75 0c             	pushl  0xc(%ebp)
  801a14:	50                   	push   %eax
  801a15:	e8 67 01 00 00       	call   801b81 <nsipc_listen>
  801a1a:	83 c4 10             	add    $0x10,%esp
}
  801a1d:	c9                   	leave  
  801a1e:	c3                   	ret    

00801a1f <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801a1f:	55                   	push   %ebp
  801a20:	89 e5                	mov    %esp,%ebp
  801a22:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801a25:	ff 75 10             	pushl  0x10(%ebp)
  801a28:	ff 75 0c             	pushl  0xc(%ebp)
  801a2b:	ff 75 08             	pushl  0x8(%ebp)
  801a2e:	e8 3a 02 00 00       	call   801c6d <nsipc_socket>
  801a33:	83 c4 10             	add    $0x10,%esp
  801a36:	85 c0                	test   %eax,%eax
  801a38:	78 05                	js     801a3f <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801a3a:	e8 a5 fe ff ff       	call   8018e4 <alloc_sockfd>
}
  801a3f:	c9                   	leave  
  801a40:	c3                   	ret    

00801a41 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801a41:	55                   	push   %ebp
  801a42:	89 e5                	mov    %esp,%ebp
  801a44:	53                   	push   %ebx
  801a45:	83 ec 04             	sub    $0x4,%esp
  801a48:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801a4a:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801a51:	75 12                	jne    801a65 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801a53:	83 ec 0c             	sub    $0xc,%esp
  801a56:	6a 02                	push   $0x2
  801a58:	e8 1c 08 00 00       	call   802279 <ipc_find_env>
  801a5d:	a3 04 40 80 00       	mov    %eax,0x804004
  801a62:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801a65:	6a 07                	push   $0x7
  801a67:	68 00 60 80 00       	push   $0x806000
  801a6c:	53                   	push   %ebx
  801a6d:	ff 35 04 40 80 00    	pushl  0x804004
  801a73:	e8 ad 07 00 00       	call   802225 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801a78:	83 c4 0c             	add    $0xc,%esp
  801a7b:	6a 00                	push   $0x0
  801a7d:	6a 00                	push   $0x0
  801a7f:	6a 00                	push   $0x0
  801a81:	e8 36 07 00 00       	call   8021bc <ipc_recv>
}
  801a86:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a89:	c9                   	leave  
  801a8a:	c3                   	ret    

00801a8b <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801a8b:	55                   	push   %ebp
  801a8c:	89 e5                	mov    %esp,%ebp
  801a8e:	56                   	push   %esi
  801a8f:	53                   	push   %ebx
  801a90:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801a93:	8b 45 08             	mov    0x8(%ebp),%eax
  801a96:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801a9b:	8b 06                	mov    (%esi),%eax
  801a9d:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801aa2:	b8 01 00 00 00       	mov    $0x1,%eax
  801aa7:	e8 95 ff ff ff       	call   801a41 <nsipc>
  801aac:	89 c3                	mov    %eax,%ebx
  801aae:	85 c0                	test   %eax,%eax
  801ab0:	78 20                	js     801ad2 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801ab2:	83 ec 04             	sub    $0x4,%esp
  801ab5:	ff 35 10 60 80 00    	pushl  0x806010
  801abb:	68 00 60 80 00       	push   $0x806000
  801ac0:	ff 75 0c             	pushl  0xc(%ebp)
  801ac3:	e8 4f ee ff ff       	call   800917 <memmove>
		*addrlen = ret->ret_addrlen;
  801ac8:	a1 10 60 80 00       	mov    0x806010,%eax
  801acd:	89 06                	mov    %eax,(%esi)
  801acf:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801ad2:	89 d8                	mov    %ebx,%eax
  801ad4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ad7:	5b                   	pop    %ebx
  801ad8:	5e                   	pop    %esi
  801ad9:	5d                   	pop    %ebp
  801ada:	c3                   	ret    

00801adb <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801adb:	55                   	push   %ebp
  801adc:	89 e5                	mov    %esp,%ebp
  801ade:	53                   	push   %ebx
  801adf:	83 ec 08             	sub    $0x8,%esp
  801ae2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801ae5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae8:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801aed:	53                   	push   %ebx
  801aee:	ff 75 0c             	pushl  0xc(%ebp)
  801af1:	68 04 60 80 00       	push   $0x806004
  801af6:	e8 1c ee ff ff       	call   800917 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801afb:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801b01:	b8 02 00 00 00       	mov    $0x2,%eax
  801b06:	e8 36 ff ff ff       	call   801a41 <nsipc>
}
  801b0b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b0e:	c9                   	leave  
  801b0f:	c3                   	ret    

00801b10 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801b10:	55                   	push   %ebp
  801b11:	89 e5                	mov    %esp,%ebp
  801b13:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801b16:	8b 45 08             	mov    0x8(%ebp),%eax
  801b19:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801b1e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b21:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801b26:	b8 03 00 00 00       	mov    $0x3,%eax
  801b2b:	e8 11 ff ff ff       	call   801a41 <nsipc>
}
  801b30:	c9                   	leave  
  801b31:	c3                   	ret    

00801b32 <nsipc_close>:

int
nsipc_close(int s)
{
  801b32:	55                   	push   %ebp
  801b33:	89 e5                	mov    %esp,%ebp
  801b35:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801b38:	8b 45 08             	mov    0x8(%ebp),%eax
  801b3b:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801b40:	b8 04 00 00 00       	mov    $0x4,%eax
  801b45:	e8 f7 fe ff ff       	call   801a41 <nsipc>
}
  801b4a:	c9                   	leave  
  801b4b:	c3                   	ret    

00801b4c <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801b4c:	55                   	push   %ebp
  801b4d:	89 e5                	mov    %esp,%ebp
  801b4f:	53                   	push   %ebx
  801b50:	83 ec 08             	sub    $0x8,%esp
  801b53:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801b56:	8b 45 08             	mov    0x8(%ebp),%eax
  801b59:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801b5e:	53                   	push   %ebx
  801b5f:	ff 75 0c             	pushl  0xc(%ebp)
  801b62:	68 04 60 80 00       	push   $0x806004
  801b67:	e8 ab ed ff ff       	call   800917 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801b6c:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801b72:	b8 05 00 00 00       	mov    $0x5,%eax
  801b77:	e8 c5 fe ff ff       	call   801a41 <nsipc>
}
  801b7c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b7f:	c9                   	leave  
  801b80:	c3                   	ret    

00801b81 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801b81:	55                   	push   %ebp
  801b82:	89 e5                	mov    %esp,%ebp
  801b84:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801b87:	8b 45 08             	mov    0x8(%ebp),%eax
  801b8a:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801b8f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b92:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801b97:	b8 06 00 00 00       	mov    $0x6,%eax
  801b9c:	e8 a0 fe ff ff       	call   801a41 <nsipc>
}
  801ba1:	c9                   	leave  
  801ba2:	c3                   	ret    

00801ba3 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801ba3:	55                   	push   %ebp
  801ba4:	89 e5                	mov    %esp,%ebp
  801ba6:	56                   	push   %esi
  801ba7:	53                   	push   %ebx
  801ba8:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801bab:	8b 45 08             	mov    0x8(%ebp),%eax
  801bae:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801bb3:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801bb9:	8b 45 14             	mov    0x14(%ebp),%eax
  801bbc:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801bc1:	b8 07 00 00 00       	mov    $0x7,%eax
  801bc6:	e8 76 fe ff ff       	call   801a41 <nsipc>
  801bcb:	89 c3                	mov    %eax,%ebx
  801bcd:	85 c0                	test   %eax,%eax
  801bcf:	78 35                	js     801c06 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801bd1:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801bd6:	7f 04                	jg     801bdc <nsipc_recv+0x39>
  801bd8:	39 c6                	cmp    %eax,%esi
  801bda:	7d 16                	jge    801bf2 <nsipc_recv+0x4f>
  801bdc:	68 c7 29 80 00       	push   $0x8029c7
  801be1:	68 88 29 80 00       	push   $0x802988
  801be6:	6a 62                	push   $0x62
  801be8:	68 dc 29 80 00       	push   $0x8029dc
  801bed:	e8 84 05 00 00       	call   802176 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801bf2:	83 ec 04             	sub    $0x4,%esp
  801bf5:	50                   	push   %eax
  801bf6:	68 00 60 80 00       	push   $0x806000
  801bfb:	ff 75 0c             	pushl  0xc(%ebp)
  801bfe:	e8 14 ed ff ff       	call   800917 <memmove>
  801c03:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801c06:	89 d8                	mov    %ebx,%eax
  801c08:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c0b:	5b                   	pop    %ebx
  801c0c:	5e                   	pop    %esi
  801c0d:	5d                   	pop    %ebp
  801c0e:	c3                   	ret    

00801c0f <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801c0f:	55                   	push   %ebp
  801c10:	89 e5                	mov    %esp,%ebp
  801c12:	53                   	push   %ebx
  801c13:	83 ec 04             	sub    $0x4,%esp
  801c16:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801c19:	8b 45 08             	mov    0x8(%ebp),%eax
  801c1c:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801c21:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801c27:	7e 16                	jle    801c3f <nsipc_send+0x30>
  801c29:	68 e8 29 80 00       	push   $0x8029e8
  801c2e:	68 88 29 80 00       	push   $0x802988
  801c33:	6a 6d                	push   $0x6d
  801c35:	68 dc 29 80 00       	push   $0x8029dc
  801c3a:	e8 37 05 00 00       	call   802176 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801c3f:	83 ec 04             	sub    $0x4,%esp
  801c42:	53                   	push   %ebx
  801c43:	ff 75 0c             	pushl  0xc(%ebp)
  801c46:	68 0c 60 80 00       	push   $0x80600c
  801c4b:	e8 c7 ec ff ff       	call   800917 <memmove>
	nsipcbuf.send.req_size = size;
  801c50:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801c56:	8b 45 14             	mov    0x14(%ebp),%eax
  801c59:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801c5e:	b8 08 00 00 00       	mov    $0x8,%eax
  801c63:	e8 d9 fd ff ff       	call   801a41 <nsipc>
}
  801c68:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c6b:	c9                   	leave  
  801c6c:	c3                   	ret    

00801c6d <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801c6d:	55                   	push   %ebp
  801c6e:	89 e5                	mov    %esp,%ebp
  801c70:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801c73:	8b 45 08             	mov    0x8(%ebp),%eax
  801c76:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801c7b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c7e:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801c83:	8b 45 10             	mov    0x10(%ebp),%eax
  801c86:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801c8b:	b8 09 00 00 00       	mov    $0x9,%eax
  801c90:	e8 ac fd ff ff       	call   801a41 <nsipc>
}
  801c95:	c9                   	leave  
  801c96:	c3                   	ret    

00801c97 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c97:	55                   	push   %ebp
  801c98:	89 e5                	mov    %esp,%ebp
  801c9a:	56                   	push   %esi
  801c9b:	53                   	push   %ebx
  801c9c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c9f:	83 ec 0c             	sub    $0xc,%esp
  801ca2:	ff 75 08             	pushl  0x8(%ebp)
  801ca5:	e8 52 f2 ff ff       	call   800efc <fd2data>
  801caa:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801cac:	83 c4 08             	add    $0x8,%esp
  801caf:	68 f4 29 80 00       	push   $0x8029f4
  801cb4:	53                   	push   %ebx
  801cb5:	e8 cb ea ff ff       	call   800785 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801cba:	8b 46 04             	mov    0x4(%esi),%eax
  801cbd:	2b 06                	sub    (%esi),%eax
  801cbf:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801cc5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ccc:	00 00 00 
	stat->st_dev = &devpipe;
  801ccf:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801cd6:	30 80 00 
	return 0;
}
  801cd9:	b8 00 00 00 00       	mov    $0x0,%eax
  801cde:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ce1:	5b                   	pop    %ebx
  801ce2:	5e                   	pop    %esi
  801ce3:	5d                   	pop    %ebp
  801ce4:	c3                   	ret    

00801ce5 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ce5:	55                   	push   %ebp
  801ce6:	89 e5                	mov    %esp,%ebp
  801ce8:	53                   	push   %ebx
  801ce9:	83 ec 0c             	sub    $0xc,%esp
  801cec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801cef:	53                   	push   %ebx
  801cf0:	6a 00                	push   $0x0
  801cf2:	e8 16 ef ff ff       	call   800c0d <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801cf7:	89 1c 24             	mov    %ebx,(%esp)
  801cfa:	e8 fd f1 ff ff       	call   800efc <fd2data>
  801cff:	83 c4 08             	add    $0x8,%esp
  801d02:	50                   	push   %eax
  801d03:	6a 00                	push   $0x0
  801d05:	e8 03 ef ff ff       	call   800c0d <sys_page_unmap>
}
  801d0a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d0d:	c9                   	leave  
  801d0e:	c3                   	ret    

00801d0f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801d0f:	55                   	push   %ebp
  801d10:	89 e5                	mov    %esp,%ebp
  801d12:	57                   	push   %edi
  801d13:	56                   	push   %esi
  801d14:	53                   	push   %ebx
  801d15:	83 ec 1c             	sub    $0x1c,%esp
  801d18:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801d1b:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801d1d:	a1 08 40 80 00       	mov    0x804008,%eax
  801d22:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801d25:	83 ec 0c             	sub    $0xc,%esp
  801d28:	ff 75 e0             	pushl  -0x20(%ebp)
  801d2b:	e8 82 05 00 00       	call   8022b2 <pageref>
  801d30:	89 c3                	mov    %eax,%ebx
  801d32:	89 3c 24             	mov    %edi,(%esp)
  801d35:	e8 78 05 00 00       	call   8022b2 <pageref>
  801d3a:	83 c4 10             	add    $0x10,%esp
  801d3d:	39 c3                	cmp    %eax,%ebx
  801d3f:	0f 94 c1             	sete   %cl
  801d42:	0f b6 c9             	movzbl %cl,%ecx
  801d45:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801d48:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801d4e:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801d51:	39 ce                	cmp    %ecx,%esi
  801d53:	74 1b                	je     801d70 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801d55:	39 c3                	cmp    %eax,%ebx
  801d57:	75 c4                	jne    801d1d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d59:	8b 42 58             	mov    0x58(%edx),%eax
  801d5c:	ff 75 e4             	pushl  -0x1c(%ebp)
  801d5f:	50                   	push   %eax
  801d60:	56                   	push   %esi
  801d61:	68 fb 29 80 00       	push   $0x8029fb
  801d66:	e8 95 e4 ff ff       	call   800200 <cprintf>
  801d6b:	83 c4 10             	add    $0x10,%esp
  801d6e:	eb ad                	jmp    801d1d <_pipeisclosed+0xe>
	}
}
  801d70:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d73:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d76:	5b                   	pop    %ebx
  801d77:	5e                   	pop    %esi
  801d78:	5f                   	pop    %edi
  801d79:	5d                   	pop    %ebp
  801d7a:	c3                   	ret    

00801d7b <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d7b:	55                   	push   %ebp
  801d7c:	89 e5                	mov    %esp,%ebp
  801d7e:	57                   	push   %edi
  801d7f:	56                   	push   %esi
  801d80:	53                   	push   %ebx
  801d81:	83 ec 28             	sub    $0x28,%esp
  801d84:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801d87:	56                   	push   %esi
  801d88:	e8 6f f1 ff ff       	call   800efc <fd2data>
  801d8d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d8f:	83 c4 10             	add    $0x10,%esp
  801d92:	bf 00 00 00 00       	mov    $0x0,%edi
  801d97:	eb 4b                	jmp    801de4 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801d99:	89 da                	mov    %ebx,%edx
  801d9b:	89 f0                	mov    %esi,%eax
  801d9d:	e8 6d ff ff ff       	call   801d0f <_pipeisclosed>
  801da2:	85 c0                	test   %eax,%eax
  801da4:	75 48                	jne    801dee <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801da6:	e8 be ed ff ff       	call   800b69 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801dab:	8b 43 04             	mov    0x4(%ebx),%eax
  801dae:	8b 0b                	mov    (%ebx),%ecx
  801db0:	8d 51 20             	lea    0x20(%ecx),%edx
  801db3:	39 d0                	cmp    %edx,%eax
  801db5:	73 e2                	jae    801d99 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801db7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801dba:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801dbe:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801dc1:	89 c2                	mov    %eax,%edx
  801dc3:	c1 fa 1f             	sar    $0x1f,%edx
  801dc6:	89 d1                	mov    %edx,%ecx
  801dc8:	c1 e9 1b             	shr    $0x1b,%ecx
  801dcb:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801dce:	83 e2 1f             	and    $0x1f,%edx
  801dd1:	29 ca                	sub    %ecx,%edx
  801dd3:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801dd7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ddb:	83 c0 01             	add    $0x1,%eax
  801dde:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801de1:	83 c7 01             	add    $0x1,%edi
  801de4:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801de7:	75 c2                	jne    801dab <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801de9:	8b 45 10             	mov    0x10(%ebp),%eax
  801dec:	eb 05                	jmp    801df3 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801dee:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801df3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801df6:	5b                   	pop    %ebx
  801df7:	5e                   	pop    %esi
  801df8:	5f                   	pop    %edi
  801df9:	5d                   	pop    %ebp
  801dfa:	c3                   	ret    

00801dfb <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801dfb:	55                   	push   %ebp
  801dfc:	89 e5                	mov    %esp,%ebp
  801dfe:	57                   	push   %edi
  801dff:	56                   	push   %esi
  801e00:	53                   	push   %ebx
  801e01:	83 ec 18             	sub    $0x18,%esp
  801e04:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801e07:	57                   	push   %edi
  801e08:	e8 ef f0 ff ff       	call   800efc <fd2data>
  801e0d:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e0f:	83 c4 10             	add    $0x10,%esp
  801e12:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e17:	eb 3d                	jmp    801e56 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801e19:	85 db                	test   %ebx,%ebx
  801e1b:	74 04                	je     801e21 <devpipe_read+0x26>
				return i;
  801e1d:	89 d8                	mov    %ebx,%eax
  801e1f:	eb 44                	jmp    801e65 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801e21:	89 f2                	mov    %esi,%edx
  801e23:	89 f8                	mov    %edi,%eax
  801e25:	e8 e5 fe ff ff       	call   801d0f <_pipeisclosed>
  801e2a:	85 c0                	test   %eax,%eax
  801e2c:	75 32                	jne    801e60 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801e2e:	e8 36 ed ff ff       	call   800b69 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801e33:	8b 06                	mov    (%esi),%eax
  801e35:	3b 46 04             	cmp    0x4(%esi),%eax
  801e38:	74 df                	je     801e19 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e3a:	99                   	cltd   
  801e3b:	c1 ea 1b             	shr    $0x1b,%edx
  801e3e:	01 d0                	add    %edx,%eax
  801e40:	83 e0 1f             	and    $0x1f,%eax
  801e43:	29 d0                	sub    %edx,%eax
  801e45:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801e4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e4d:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801e50:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e53:	83 c3 01             	add    $0x1,%ebx
  801e56:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801e59:	75 d8                	jne    801e33 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801e5b:	8b 45 10             	mov    0x10(%ebp),%eax
  801e5e:	eb 05                	jmp    801e65 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e60:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801e65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e68:	5b                   	pop    %ebx
  801e69:	5e                   	pop    %esi
  801e6a:	5f                   	pop    %edi
  801e6b:	5d                   	pop    %ebp
  801e6c:	c3                   	ret    

00801e6d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801e6d:	55                   	push   %ebp
  801e6e:	89 e5                	mov    %esp,%ebp
  801e70:	56                   	push   %esi
  801e71:	53                   	push   %ebx
  801e72:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801e75:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e78:	50                   	push   %eax
  801e79:	e8 95 f0 ff ff       	call   800f13 <fd_alloc>
  801e7e:	83 c4 10             	add    $0x10,%esp
  801e81:	89 c2                	mov    %eax,%edx
  801e83:	85 c0                	test   %eax,%eax
  801e85:	0f 88 2c 01 00 00    	js     801fb7 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e8b:	83 ec 04             	sub    $0x4,%esp
  801e8e:	68 07 04 00 00       	push   $0x407
  801e93:	ff 75 f4             	pushl  -0xc(%ebp)
  801e96:	6a 00                	push   $0x0
  801e98:	e8 eb ec ff ff       	call   800b88 <sys_page_alloc>
  801e9d:	83 c4 10             	add    $0x10,%esp
  801ea0:	89 c2                	mov    %eax,%edx
  801ea2:	85 c0                	test   %eax,%eax
  801ea4:	0f 88 0d 01 00 00    	js     801fb7 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801eaa:	83 ec 0c             	sub    $0xc,%esp
  801ead:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801eb0:	50                   	push   %eax
  801eb1:	e8 5d f0 ff ff       	call   800f13 <fd_alloc>
  801eb6:	89 c3                	mov    %eax,%ebx
  801eb8:	83 c4 10             	add    $0x10,%esp
  801ebb:	85 c0                	test   %eax,%eax
  801ebd:	0f 88 e2 00 00 00    	js     801fa5 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ec3:	83 ec 04             	sub    $0x4,%esp
  801ec6:	68 07 04 00 00       	push   $0x407
  801ecb:	ff 75 f0             	pushl  -0x10(%ebp)
  801ece:	6a 00                	push   $0x0
  801ed0:	e8 b3 ec ff ff       	call   800b88 <sys_page_alloc>
  801ed5:	89 c3                	mov    %eax,%ebx
  801ed7:	83 c4 10             	add    $0x10,%esp
  801eda:	85 c0                	test   %eax,%eax
  801edc:	0f 88 c3 00 00 00    	js     801fa5 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801ee2:	83 ec 0c             	sub    $0xc,%esp
  801ee5:	ff 75 f4             	pushl  -0xc(%ebp)
  801ee8:	e8 0f f0 ff ff       	call   800efc <fd2data>
  801eed:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801eef:	83 c4 0c             	add    $0xc,%esp
  801ef2:	68 07 04 00 00       	push   $0x407
  801ef7:	50                   	push   %eax
  801ef8:	6a 00                	push   $0x0
  801efa:	e8 89 ec ff ff       	call   800b88 <sys_page_alloc>
  801eff:	89 c3                	mov    %eax,%ebx
  801f01:	83 c4 10             	add    $0x10,%esp
  801f04:	85 c0                	test   %eax,%eax
  801f06:	0f 88 89 00 00 00    	js     801f95 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f0c:	83 ec 0c             	sub    $0xc,%esp
  801f0f:	ff 75 f0             	pushl  -0x10(%ebp)
  801f12:	e8 e5 ef ff ff       	call   800efc <fd2data>
  801f17:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801f1e:	50                   	push   %eax
  801f1f:	6a 00                	push   $0x0
  801f21:	56                   	push   %esi
  801f22:	6a 00                	push   $0x0
  801f24:	e8 a2 ec ff ff       	call   800bcb <sys_page_map>
  801f29:	89 c3                	mov    %eax,%ebx
  801f2b:	83 c4 20             	add    $0x20,%esp
  801f2e:	85 c0                	test   %eax,%eax
  801f30:	78 55                	js     801f87 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801f32:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f38:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f3b:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801f3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f40:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801f47:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f50:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801f52:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f55:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801f5c:	83 ec 0c             	sub    $0xc,%esp
  801f5f:	ff 75 f4             	pushl  -0xc(%ebp)
  801f62:	e8 85 ef ff ff       	call   800eec <fd2num>
  801f67:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f6a:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801f6c:	83 c4 04             	add    $0x4,%esp
  801f6f:	ff 75 f0             	pushl  -0x10(%ebp)
  801f72:	e8 75 ef ff ff       	call   800eec <fd2num>
  801f77:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f7a:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801f7d:	83 c4 10             	add    $0x10,%esp
  801f80:	ba 00 00 00 00       	mov    $0x0,%edx
  801f85:	eb 30                	jmp    801fb7 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801f87:	83 ec 08             	sub    $0x8,%esp
  801f8a:	56                   	push   %esi
  801f8b:	6a 00                	push   $0x0
  801f8d:	e8 7b ec ff ff       	call   800c0d <sys_page_unmap>
  801f92:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801f95:	83 ec 08             	sub    $0x8,%esp
  801f98:	ff 75 f0             	pushl  -0x10(%ebp)
  801f9b:	6a 00                	push   $0x0
  801f9d:	e8 6b ec ff ff       	call   800c0d <sys_page_unmap>
  801fa2:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801fa5:	83 ec 08             	sub    $0x8,%esp
  801fa8:	ff 75 f4             	pushl  -0xc(%ebp)
  801fab:	6a 00                	push   $0x0
  801fad:	e8 5b ec ff ff       	call   800c0d <sys_page_unmap>
  801fb2:	83 c4 10             	add    $0x10,%esp
  801fb5:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801fb7:	89 d0                	mov    %edx,%eax
  801fb9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fbc:	5b                   	pop    %ebx
  801fbd:	5e                   	pop    %esi
  801fbe:	5d                   	pop    %ebp
  801fbf:	c3                   	ret    

00801fc0 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801fc0:	55                   	push   %ebp
  801fc1:	89 e5                	mov    %esp,%ebp
  801fc3:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fc6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fc9:	50                   	push   %eax
  801fca:	ff 75 08             	pushl  0x8(%ebp)
  801fcd:	e8 90 ef ff ff       	call   800f62 <fd_lookup>
  801fd2:	83 c4 10             	add    $0x10,%esp
  801fd5:	85 c0                	test   %eax,%eax
  801fd7:	78 18                	js     801ff1 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801fd9:	83 ec 0c             	sub    $0xc,%esp
  801fdc:	ff 75 f4             	pushl  -0xc(%ebp)
  801fdf:	e8 18 ef ff ff       	call   800efc <fd2data>
	return _pipeisclosed(fd, p);
  801fe4:	89 c2                	mov    %eax,%edx
  801fe6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fe9:	e8 21 fd ff ff       	call   801d0f <_pipeisclosed>
  801fee:	83 c4 10             	add    $0x10,%esp
}
  801ff1:	c9                   	leave  
  801ff2:	c3                   	ret    

00801ff3 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ff3:	55                   	push   %ebp
  801ff4:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ff6:	b8 00 00 00 00       	mov    $0x0,%eax
  801ffb:	5d                   	pop    %ebp
  801ffc:	c3                   	ret    

00801ffd <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ffd:	55                   	push   %ebp
  801ffe:	89 e5                	mov    %esp,%ebp
  802000:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802003:	68 13 2a 80 00       	push   $0x802a13
  802008:	ff 75 0c             	pushl  0xc(%ebp)
  80200b:	e8 75 e7 ff ff       	call   800785 <strcpy>
	return 0;
}
  802010:	b8 00 00 00 00       	mov    $0x0,%eax
  802015:	c9                   	leave  
  802016:	c3                   	ret    

00802017 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802017:	55                   	push   %ebp
  802018:	89 e5                	mov    %esp,%ebp
  80201a:	57                   	push   %edi
  80201b:	56                   	push   %esi
  80201c:	53                   	push   %ebx
  80201d:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802023:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802028:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80202e:	eb 2d                	jmp    80205d <devcons_write+0x46>
		m = n - tot;
  802030:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802033:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802035:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802038:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80203d:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802040:	83 ec 04             	sub    $0x4,%esp
  802043:	53                   	push   %ebx
  802044:	03 45 0c             	add    0xc(%ebp),%eax
  802047:	50                   	push   %eax
  802048:	57                   	push   %edi
  802049:	e8 c9 e8 ff ff       	call   800917 <memmove>
		sys_cputs(buf, m);
  80204e:	83 c4 08             	add    $0x8,%esp
  802051:	53                   	push   %ebx
  802052:	57                   	push   %edi
  802053:	e8 74 ea ff ff       	call   800acc <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802058:	01 de                	add    %ebx,%esi
  80205a:	83 c4 10             	add    $0x10,%esp
  80205d:	89 f0                	mov    %esi,%eax
  80205f:	3b 75 10             	cmp    0x10(%ebp),%esi
  802062:	72 cc                	jb     802030 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802064:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802067:	5b                   	pop    %ebx
  802068:	5e                   	pop    %esi
  802069:	5f                   	pop    %edi
  80206a:	5d                   	pop    %ebp
  80206b:	c3                   	ret    

0080206c <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80206c:	55                   	push   %ebp
  80206d:	89 e5                	mov    %esp,%ebp
  80206f:	83 ec 08             	sub    $0x8,%esp
  802072:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802077:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80207b:	74 2a                	je     8020a7 <devcons_read+0x3b>
  80207d:	eb 05                	jmp    802084 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80207f:	e8 e5 ea ff ff       	call   800b69 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802084:	e8 61 ea ff ff       	call   800aea <sys_cgetc>
  802089:	85 c0                	test   %eax,%eax
  80208b:	74 f2                	je     80207f <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80208d:	85 c0                	test   %eax,%eax
  80208f:	78 16                	js     8020a7 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802091:	83 f8 04             	cmp    $0x4,%eax
  802094:	74 0c                	je     8020a2 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802096:	8b 55 0c             	mov    0xc(%ebp),%edx
  802099:	88 02                	mov    %al,(%edx)
	return 1;
  80209b:	b8 01 00 00 00       	mov    $0x1,%eax
  8020a0:	eb 05                	jmp    8020a7 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8020a2:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8020a7:	c9                   	leave  
  8020a8:	c3                   	ret    

008020a9 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8020a9:	55                   	push   %ebp
  8020aa:	89 e5                	mov    %esp,%ebp
  8020ac:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8020af:	8b 45 08             	mov    0x8(%ebp),%eax
  8020b2:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8020b5:	6a 01                	push   $0x1
  8020b7:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020ba:	50                   	push   %eax
  8020bb:	e8 0c ea ff ff       	call   800acc <sys_cputs>
}
  8020c0:	83 c4 10             	add    $0x10,%esp
  8020c3:	c9                   	leave  
  8020c4:	c3                   	ret    

008020c5 <getchar>:

int
getchar(void)
{
  8020c5:	55                   	push   %ebp
  8020c6:	89 e5                	mov    %esp,%ebp
  8020c8:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8020cb:	6a 01                	push   $0x1
  8020cd:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020d0:	50                   	push   %eax
  8020d1:	6a 00                	push   $0x0
  8020d3:	e8 f0 f0 ff ff       	call   8011c8 <read>
	if (r < 0)
  8020d8:	83 c4 10             	add    $0x10,%esp
  8020db:	85 c0                	test   %eax,%eax
  8020dd:	78 0f                	js     8020ee <getchar+0x29>
		return r;
	if (r < 1)
  8020df:	85 c0                	test   %eax,%eax
  8020e1:	7e 06                	jle    8020e9 <getchar+0x24>
		return -E_EOF;
	return c;
  8020e3:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8020e7:	eb 05                	jmp    8020ee <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8020e9:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8020ee:	c9                   	leave  
  8020ef:	c3                   	ret    

008020f0 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8020f0:	55                   	push   %ebp
  8020f1:	89 e5                	mov    %esp,%ebp
  8020f3:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020f9:	50                   	push   %eax
  8020fa:	ff 75 08             	pushl  0x8(%ebp)
  8020fd:	e8 60 ee ff ff       	call   800f62 <fd_lookup>
  802102:	83 c4 10             	add    $0x10,%esp
  802105:	85 c0                	test   %eax,%eax
  802107:	78 11                	js     80211a <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802109:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80210c:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802112:	39 10                	cmp    %edx,(%eax)
  802114:	0f 94 c0             	sete   %al
  802117:	0f b6 c0             	movzbl %al,%eax
}
  80211a:	c9                   	leave  
  80211b:	c3                   	ret    

0080211c <opencons>:

int
opencons(void)
{
  80211c:	55                   	push   %ebp
  80211d:	89 e5                	mov    %esp,%ebp
  80211f:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802122:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802125:	50                   	push   %eax
  802126:	e8 e8 ed ff ff       	call   800f13 <fd_alloc>
  80212b:	83 c4 10             	add    $0x10,%esp
		return r;
  80212e:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802130:	85 c0                	test   %eax,%eax
  802132:	78 3e                	js     802172 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802134:	83 ec 04             	sub    $0x4,%esp
  802137:	68 07 04 00 00       	push   $0x407
  80213c:	ff 75 f4             	pushl  -0xc(%ebp)
  80213f:	6a 00                	push   $0x0
  802141:	e8 42 ea ff ff       	call   800b88 <sys_page_alloc>
  802146:	83 c4 10             	add    $0x10,%esp
		return r;
  802149:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80214b:	85 c0                	test   %eax,%eax
  80214d:	78 23                	js     802172 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80214f:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802155:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802158:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80215a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80215d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802164:	83 ec 0c             	sub    $0xc,%esp
  802167:	50                   	push   %eax
  802168:	e8 7f ed ff ff       	call   800eec <fd2num>
  80216d:	89 c2                	mov    %eax,%edx
  80216f:	83 c4 10             	add    $0x10,%esp
}
  802172:	89 d0                	mov    %edx,%eax
  802174:	c9                   	leave  
  802175:	c3                   	ret    

00802176 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802176:	55                   	push   %ebp
  802177:	89 e5                	mov    %esp,%ebp
  802179:	56                   	push   %esi
  80217a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80217b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80217e:	8b 35 00 30 80 00    	mov    0x803000,%esi
  802184:	e8 c1 e9 ff ff       	call   800b4a <sys_getenvid>
  802189:	83 ec 0c             	sub    $0xc,%esp
  80218c:	ff 75 0c             	pushl  0xc(%ebp)
  80218f:	ff 75 08             	pushl  0x8(%ebp)
  802192:	56                   	push   %esi
  802193:	50                   	push   %eax
  802194:	68 20 2a 80 00       	push   $0x802a20
  802199:	e8 62 e0 ff ff       	call   800200 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80219e:	83 c4 18             	add    $0x18,%esp
  8021a1:	53                   	push   %ebx
  8021a2:	ff 75 10             	pushl  0x10(%ebp)
  8021a5:	e8 05 e0 ff ff       	call   8001af <vcprintf>
	cprintf("\n");
  8021aa:	c7 04 24 90 25 80 00 	movl   $0x802590,(%esp)
  8021b1:	e8 4a e0 ff ff       	call   800200 <cprintf>
  8021b6:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8021b9:	cc                   	int3   
  8021ba:	eb fd                	jmp    8021b9 <_panic+0x43>

008021bc <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8021bc:	55                   	push   %ebp
  8021bd:	89 e5                	mov    %esp,%ebp
  8021bf:	56                   	push   %esi
  8021c0:	53                   	push   %ebx
  8021c1:	8b 75 08             	mov    0x8(%ebp),%esi
  8021c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021c7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  8021ca:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  8021cc:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  8021d1:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  8021d4:	83 ec 0c             	sub    $0xc,%esp
  8021d7:	50                   	push   %eax
  8021d8:	e8 5b eb ff ff       	call   800d38 <sys_ipc_recv>

	if (r < 0) {
  8021dd:	83 c4 10             	add    $0x10,%esp
  8021e0:	85 c0                	test   %eax,%eax
  8021e2:	79 16                	jns    8021fa <ipc_recv+0x3e>
		if (from_env_store)
  8021e4:	85 f6                	test   %esi,%esi
  8021e6:	74 06                	je     8021ee <ipc_recv+0x32>
			*from_env_store = 0;
  8021e8:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  8021ee:	85 db                	test   %ebx,%ebx
  8021f0:	74 2c                	je     80221e <ipc_recv+0x62>
			*perm_store = 0;
  8021f2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8021f8:	eb 24                	jmp    80221e <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  8021fa:	85 f6                	test   %esi,%esi
  8021fc:	74 0a                	je     802208 <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  8021fe:	a1 08 40 80 00       	mov    0x804008,%eax
  802203:	8b 40 74             	mov    0x74(%eax),%eax
  802206:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  802208:	85 db                	test   %ebx,%ebx
  80220a:	74 0a                	je     802216 <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  80220c:	a1 08 40 80 00       	mov    0x804008,%eax
  802211:	8b 40 78             	mov    0x78(%eax),%eax
  802214:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  802216:	a1 08 40 80 00       	mov    0x804008,%eax
  80221b:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  80221e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802221:	5b                   	pop    %ebx
  802222:	5e                   	pop    %esi
  802223:	5d                   	pop    %ebp
  802224:	c3                   	ret    

00802225 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802225:	55                   	push   %ebp
  802226:	89 e5                	mov    %esp,%ebp
  802228:	57                   	push   %edi
  802229:	56                   	push   %esi
  80222a:	53                   	push   %ebx
  80222b:	83 ec 0c             	sub    $0xc,%esp
  80222e:	8b 7d 08             	mov    0x8(%ebp),%edi
  802231:	8b 75 0c             	mov    0xc(%ebp),%esi
  802234:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  802237:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  802239:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  80223e:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  802241:	ff 75 14             	pushl  0x14(%ebp)
  802244:	53                   	push   %ebx
  802245:	56                   	push   %esi
  802246:	57                   	push   %edi
  802247:	e8 c9 ea ff ff       	call   800d15 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  80224c:	83 c4 10             	add    $0x10,%esp
  80224f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802252:	75 07                	jne    80225b <ipc_send+0x36>
			sys_yield();
  802254:	e8 10 e9 ff ff       	call   800b69 <sys_yield>
  802259:	eb e6                	jmp    802241 <ipc_send+0x1c>
		} else if (r < 0) {
  80225b:	85 c0                	test   %eax,%eax
  80225d:	79 12                	jns    802271 <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  80225f:	50                   	push   %eax
  802260:	68 44 2a 80 00       	push   $0x802a44
  802265:	6a 51                	push   $0x51
  802267:	68 51 2a 80 00       	push   $0x802a51
  80226c:	e8 05 ff ff ff       	call   802176 <_panic>
		}
	}
}
  802271:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802274:	5b                   	pop    %ebx
  802275:	5e                   	pop    %esi
  802276:	5f                   	pop    %edi
  802277:	5d                   	pop    %ebp
  802278:	c3                   	ret    

00802279 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802279:	55                   	push   %ebp
  80227a:	89 e5                	mov    %esp,%ebp
  80227c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80227f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802284:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802287:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80228d:	8b 52 50             	mov    0x50(%edx),%edx
  802290:	39 ca                	cmp    %ecx,%edx
  802292:	75 0d                	jne    8022a1 <ipc_find_env+0x28>
			return envs[i].env_id;
  802294:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802297:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80229c:	8b 40 48             	mov    0x48(%eax),%eax
  80229f:	eb 0f                	jmp    8022b0 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8022a1:	83 c0 01             	add    $0x1,%eax
  8022a4:	3d 00 04 00 00       	cmp    $0x400,%eax
  8022a9:	75 d9                	jne    802284 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8022ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8022b0:	5d                   	pop    %ebp
  8022b1:	c3                   	ret    

008022b2 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8022b2:	55                   	push   %ebp
  8022b3:	89 e5                	mov    %esp,%ebp
  8022b5:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8022b8:	89 d0                	mov    %edx,%eax
  8022ba:	c1 e8 16             	shr    $0x16,%eax
  8022bd:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8022c4:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8022c9:	f6 c1 01             	test   $0x1,%cl
  8022cc:	74 1d                	je     8022eb <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8022ce:	c1 ea 0c             	shr    $0xc,%edx
  8022d1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8022d8:	f6 c2 01             	test   $0x1,%dl
  8022db:	74 0e                	je     8022eb <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8022dd:	c1 ea 0c             	shr    $0xc,%edx
  8022e0:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8022e7:	ef 
  8022e8:	0f b7 c0             	movzwl %ax,%eax
}
  8022eb:	5d                   	pop    %ebp
  8022ec:	c3                   	ret    
  8022ed:	66 90                	xchg   %ax,%ax
  8022ef:	90                   	nop

008022f0 <__udivdi3>:
  8022f0:	55                   	push   %ebp
  8022f1:	57                   	push   %edi
  8022f2:	56                   	push   %esi
  8022f3:	53                   	push   %ebx
  8022f4:	83 ec 1c             	sub    $0x1c,%esp
  8022f7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8022fb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8022ff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802303:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802307:	85 f6                	test   %esi,%esi
  802309:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80230d:	89 ca                	mov    %ecx,%edx
  80230f:	89 f8                	mov    %edi,%eax
  802311:	75 3d                	jne    802350 <__udivdi3+0x60>
  802313:	39 cf                	cmp    %ecx,%edi
  802315:	0f 87 c5 00 00 00    	ja     8023e0 <__udivdi3+0xf0>
  80231b:	85 ff                	test   %edi,%edi
  80231d:	89 fd                	mov    %edi,%ebp
  80231f:	75 0b                	jne    80232c <__udivdi3+0x3c>
  802321:	b8 01 00 00 00       	mov    $0x1,%eax
  802326:	31 d2                	xor    %edx,%edx
  802328:	f7 f7                	div    %edi
  80232a:	89 c5                	mov    %eax,%ebp
  80232c:	89 c8                	mov    %ecx,%eax
  80232e:	31 d2                	xor    %edx,%edx
  802330:	f7 f5                	div    %ebp
  802332:	89 c1                	mov    %eax,%ecx
  802334:	89 d8                	mov    %ebx,%eax
  802336:	89 cf                	mov    %ecx,%edi
  802338:	f7 f5                	div    %ebp
  80233a:	89 c3                	mov    %eax,%ebx
  80233c:	89 d8                	mov    %ebx,%eax
  80233e:	89 fa                	mov    %edi,%edx
  802340:	83 c4 1c             	add    $0x1c,%esp
  802343:	5b                   	pop    %ebx
  802344:	5e                   	pop    %esi
  802345:	5f                   	pop    %edi
  802346:	5d                   	pop    %ebp
  802347:	c3                   	ret    
  802348:	90                   	nop
  802349:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802350:	39 ce                	cmp    %ecx,%esi
  802352:	77 74                	ja     8023c8 <__udivdi3+0xd8>
  802354:	0f bd fe             	bsr    %esi,%edi
  802357:	83 f7 1f             	xor    $0x1f,%edi
  80235a:	0f 84 98 00 00 00    	je     8023f8 <__udivdi3+0x108>
  802360:	bb 20 00 00 00       	mov    $0x20,%ebx
  802365:	89 f9                	mov    %edi,%ecx
  802367:	89 c5                	mov    %eax,%ebp
  802369:	29 fb                	sub    %edi,%ebx
  80236b:	d3 e6                	shl    %cl,%esi
  80236d:	89 d9                	mov    %ebx,%ecx
  80236f:	d3 ed                	shr    %cl,%ebp
  802371:	89 f9                	mov    %edi,%ecx
  802373:	d3 e0                	shl    %cl,%eax
  802375:	09 ee                	or     %ebp,%esi
  802377:	89 d9                	mov    %ebx,%ecx
  802379:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80237d:	89 d5                	mov    %edx,%ebp
  80237f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802383:	d3 ed                	shr    %cl,%ebp
  802385:	89 f9                	mov    %edi,%ecx
  802387:	d3 e2                	shl    %cl,%edx
  802389:	89 d9                	mov    %ebx,%ecx
  80238b:	d3 e8                	shr    %cl,%eax
  80238d:	09 c2                	or     %eax,%edx
  80238f:	89 d0                	mov    %edx,%eax
  802391:	89 ea                	mov    %ebp,%edx
  802393:	f7 f6                	div    %esi
  802395:	89 d5                	mov    %edx,%ebp
  802397:	89 c3                	mov    %eax,%ebx
  802399:	f7 64 24 0c          	mull   0xc(%esp)
  80239d:	39 d5                	cmp    %edx,%ebp
  80239f:	72 10                	jb     8023b1 <__udivdi3+0xc1>
  8023a1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8023a5:	89 f9                	mov    %edi,%ecx
  8023a7:	d3 e6                	shl    %cl,%esi
  8023a9:	39 c6                	cmp    %eax,%esi
  8023ab:	73 07                	jae    8023b4 <__udivdi3+0xc4>
  8023ad:	39 d5                	cmp    %edx,%ebp
  8023af:	75 03                	jne    8023b4 <__udivdi3+0xc4>
  8023b1:	83 eb 01             	sub    $0x1,%ebx
  8023b4:	31 ff                	xor    %edi,%edi
  8023b6:	89 d8                	mov    %ebx,%eax
  8023b8:	89 fa                	mov    %edi,%edx
  8023ba:	83 c4 1c             	add    $0x1c,%esp
  8023bd:	5b                   	pop    %ebx
  8023be:	5e                   	pop    %esi
  8023bf:	5f                   	pop    %edi
  8023c0:	5d                   	pop    %ebp
  8023c1:	c3                   	ret    
  8023c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8023c8:	31 ff                	xor    %edi,%edi
  8023ca:	31 db                	xor    %ebx,%ebx
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
  8023e0:	89 d8                	mov    %ebx,%eax
  8023e2:	f7 f7                	div    %edi
  8023e4:	31 ff                	xor    %edi,%edi
  8023e6:	89 c3                	mov    %eax,%ebx
  8023e8:	89 d8                	mov    %ebx,%eax
  8023ea:	89 fa                	mov    %edi,%edx
  8023ec:	83 c4 1c             	add    $0x1c,%esp
  8023ef:	5b                   	pop    %ebx
  8023f0:	5e                   	pop    %esi
  8023f1:	5f                   	pop    %edi
  8023f2:	5d                   	pop    %ebp
  8023f3:	c3                   	ret    
  8023f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023f8:	39 ce                	cmp    %ecx,%esi
  8023fa:	72 0c                	jb     802408 <__udivdi3+0x118>
  8023fc:	31 db                	xor    %ebx,%ebx
  8023fe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802402:	0f 87 34 ff ff ff    	ja     80233c <__udivdi3+0x4c>
  802408:	bb 01 00 00 00       	mov    $0x1,%ebx
  80240d:	e9 2a ff ff ff       	jmp    80233c <__udivdi3+0x4c>
  802412:	66 90                	xchg   %ax,%ax
  802414:	66 90                	xchg   %ax,%ax
  802416:	66 90                	xchg   %ax,%ax
  802418:	66 90                	xchg   %ax,%ax
  80241a:	66 90                	xchg   %ax,%ax
  80241c:	66 90                	xchg   %ax,%ax
  80241e:	66 90                	xchg   %ax,%ax

00802420 <__umoddi3>:
  802420:	55                   	push   %ebp
  802421:	57                   	push   %edi
  802422:	56                   	push   %esi
  802423:	53                   	push   %ebx
  802424:	83 ec 1c             	sub    $0x1c,%esp
  802427:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80242b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80242f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802433:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802437:	85 d2                	test   %edx,%edx
  802439:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80243d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802441:	89 f3                	mov    %esi,%ebx
  802443:	89 3c 24             	mov    %edi,(%esp)
  802446:	89 74 24 04          	mov    %esi,0x4(%esp)
  80244a:	75 1c                	jne    802468 <__umoddi3+0x48>
  80244c:	39 f7                	cmp    %esi,%edi
  80244e:	76 50                	jbe    8024a0 <__umoddi3+0x80>
  802450:	89 c8                	mov    %ecx,%eax
  802452:	89 f2                	mov    %esi,%edx
  802454:	f7 f7                	div    %edi
  802456:	89 d0                	mov    %edx,%eax
  802458:	31 d2                	xor    %edx,%edx
  80245a:	83 c4 1c             	add    $0x1c,%esp
  80245d:	5b                   	pop    %ebx
  80245e:	5e                   	pop    %esi
  80245f:	5f                   	pop    %edi
  802460:	5d                   	pop    %ebp
  802461:	c3                   	ret    
  802462:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802468:	39 f2                	cmp    %esi,%edx
  80246a:	89 d0                	mov    %edx,%eax
  80246c:	77 52                	ja     8024c0 <__umoddi3+0xa0>
  80246e:	0f bd ea             	bsr    %edx,%ebp
  802471:	83 f5 1f             	xor    $0x1f,%ebp
  802474:	75 5a                	jne    8024d0 <__umoddi3+0xb0>
  802476:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80247a:	0f 82 e0 00 00 00    	jb     802560 <__umoddi3+0x140>
  802480:	39 0c 24             	cmp    %ecx,(%esp)
  802483:	0f 86 d7 00 00 00    	jbe    802560 <__umoddi3+0x140>
  802489:	8b 44 24 08          	mov    0x8(%esp),%eax
  80248d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802491:	83 c4 1c             	add    $0x1c,%esp
  802494:	5b                   	pop    %ebx
  802495:	5e                   	pop    %esi
  802496:	5f                   	pop    %edi
  802497:	5d                   	pop    %ebp
  802498:	c3                   	ret    
  802499:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024a0:	85 ff                	test   %edi,%edi
  8024a2:	89 fd                	mov    %edi,%ebp
  8024a4:	75 0b                	jne    8024b1 <__umoddi3+0x91>
  8024a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8024ab:	31 d2                	xor    %edx,%edx
  8024ad:	f7 f7                	div    %edi
  8024af:	89 c5                	mov    %eax,%ebp
  8024b1:	89 f0                	mov    %esi,%eax
  8024b3:	31 d2                	xor    %edx,%edx
  8024b5:	f7 f5                	div    %ebp
  8024b7:	89 c8                	mov    %ecx,%eax
  8024b9:	f7 f5                	div    %ebp
  8024bb:	89 d0                	mov    %edx,%eax
  8024bd:	eb 99                	jmp    802458 <__umoddi3+0x38>
  8024bf:	90                   	nop
  8024c0:	89 c8                	mov    %ecx,%eax
  8024c2:	89 f2                	mov    %esi,%edx
  8024c4:	83 c4 1c             	add    $0x1c,%esp
  8024c7:	5b                   	pop    %ebx
  8024c8:	5e                   	pop    %esi
  8024c9:	5f                   	pop    %edi
  8024ca:	5d                   	pop    %ebp
  8024cb:	c3                   	ret    
  8024cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8024d0:	8b 34 24             	mov    (%esp),%esi
  8024d3:	bf 20 00 00 00       	mov    $0x20,%edi
  8024d8:	89 e9                	mov    %ebp,%ecx
  8024da:	29 ef                	sub    %ebp,%edi
  8024dc:	d3 e0                	shl    %cl,%eax
  8024de:	89 f9                	mov    %edi,%ecx
  8024e0:	89 f2                	mov    %esi,%edx
  8024e2:	d3 ea                	shr    %cl,%edx
  8024e4:	89 e9                	mov    %ebp,%ecx
  8024e6:	09 c2                	or     %eax,%edx
  8024e8:	89 d8                	mov    %ebx,%eax
  8024ea:	89 14 24             	mov    %edx,(%esp)
  8024ed:	89 f2                	mov    %esi,%edx
  8024ef:	d3 e2                	shl    %cl,%edx
  8024f1:	89 f9                	mov    %edi,%ecx
  8024f3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8024f7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8024fb:	d3 e8                	shr    %cl,%eax
  8024fd:	89 e9                	mov    %ebp,%ecx
  8024ff:	89 c6                	mov    %eax,%esi
  802501:	d3 e3                	shl    %cl,%ebx
  802503:	89 f9                	mov    %edi,%ecx
  802505:	89 d0                	mov    %edx,%eax
  802507:	d3 e8                	shr    %cl,%eax
  802509:	89 e9                	mov    %ebp,%ecx
  80250b:	09 d8                	or     %ebx,%eax
  80250d:	89 d3                	mov    %edx,%ebx
  80250f:	89 f2                	mov    %esi,%edx
  802511:	f7 34 24             	divl   (%esp)
  802514:	89 d6                	mov    %edx,%esi
  802516:	d3 e3                	shl    %cl,%ebx
  802518:	f7 64 24 04          	mull   0x4(%esp)
  80251c:	39 d6                	cmp    %edx,%esi
  80251e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802522:	89 d1                	mov    %edx,%ecx
  802524:	89 c3                	mov    %eax,%ebx
  802526:	72 08                	jb     802530 <__umoddi3+0x110>
  802528:	75 11                	jne    80253b <__umoddi3+0x11b>
  80252a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80252e:	73 0b                	jae    80253b <__umoddi3+0x11b>
  802530:	2b 44 24 04          	sub    0x4(%esp),%eax
  802534:	1b 14 24             	sbb    (%esp),%edx
  802537:	89 d1                	mov    %edx,%ecx
  802539:	89 c3                	mov    %eax,%ebx
  80253b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80253f:	29 da                	sub    %ebx,%edx
  802541:	19 ce                	sbb    %ecx,%esi
  802543:	89 f9                	mov    %edi,%ecx
  802545:	89 f0                	mov    %esi,%eax
  802547:	d3 e0                	shl    %cl,%eax
  802549:	89 e9                	mov    %ebp,%ecx
  80254b:	d3 ea                	shr    %cl,%edx
  80254d:	89 e9                	mov    %ebp,%ecx
  80254f:	d3 ee                	shr    %cl,%esi
  802551:	09 d0                	or     %edx,%eax
  802553:	89 f2                	mov    %esi,%edx
  802555:	83 c4 1c             	add    $0x1c,%esp
  802558:	5b                   	pop    %ebx
  802559:	5e                   	pop    %esi
  80255a:	5f                   	pop    %edi
  80255b:	5d                   	pop    %ebp
  80255c:	c3                   	ret    
  80255d:	8d 76 00             	lea    0x0(%esi),%esi
  802560:	29 f9                	sub    %edi,%ecx
  802562:	19 d6                	sbb    %edx,%esi
  802564:	89 74 24 04          	mov    %esi,0x4(%esp)
  802568:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80256c:	e9 18 ff ff ff       	jmp    802489 <__umoddi3+0x69>
