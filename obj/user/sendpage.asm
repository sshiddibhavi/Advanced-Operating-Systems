
obj/user/sendpage.debug:     file format elf32-i386


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
  80002c:	e8 68 01 00 00       	call   800199 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#define TEMP_ADDR	((char*)0xa00000)
#define TEMP_ADDR_CHILD	((char*)0xb00000)

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	envid_t who;

	if ((who = fork()) == 0) {
  800039:	e8 9a 0f 00 00       	call   800fd8 <fork>
  80003e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800041:	85 c0                	test   %eax,%eax
  800043:	0f 85 9f 00 00 00    	jne    8000e8 <umain+0xb5>
		// Child
		ipc_recv(&who, TEMP_ADDR_CHILD, 0);
  800049:	83 ec 04             	sub    $0x4,%esp
  80004c:	6a 00                	push   $0x0
  80004e:	68 00 00 b0 00       	push   $0xb00000
  800053:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800056:	50                   	push   %eax
  800057:	e8 71 10 00 00       	call   8010cd <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  80005c:	83 c4 0c             	add    $0xc,%esp
  80005f:	68 00 00 b0 00       	push   $0xb00000
  800064:	ff 75 f4             	pushl  -0xc(%ebp)
  800067:	68 e0 26 80 00       	push   $0x8026e0
  80006c:	e8 1b 02 00 00       	call   80028c <cprintf>
		if (strncmp(TEMP_ADDR_CHILD, str1, strlen(str1)) == 0)
  800071:	83 c4 04             	add    $0x4,%esp
  800074:	ff 35 04 30 80 00    	pushl  0x803004
  80007a:	e8 59 07 00 00       	call   8007d8 <strlen>
  80007f:	83 c4 0c             	add    $0xc,%esp
  800082:	50                   	push   %eax
  800083:	ff 35 04 30 80 00    	pushl  0x803004
  800089:	68 00 00 b0 00       	push   $0xb00000
  80008e:	e8 4e 08 00 00       	call   8008e1 <strncmp>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	85 c0                	test   %eax,%eax
  800098:	75 10                	jne    8000aa <umain+0x77>
			cprintf("child received correct message\n");
  80009a:	83 ec 0c             	sub    $0xc,%esp
  80009d:	68 f4 26 80 00       	push   $0x8026f4
  8000a2:	e8 e5 01 00 00       	call   80028c <cprintf>
  8000a7:	83 c4 10             	add    $0x10,%esp

		memcpy(TEMP_ADDR_CHILD, str2, strlen(str2) + 1);
  8000aa:	83 ec 0c             	sub    $0xc,%esp
  8000ad:	ff 35 00 30 80 00    	pushl  0x803000
  8000b3:	e8 20 07 00 00       	call   8007d8 <strlen>
  8000b8:	83 c4 0c             	add    $0xc,%esp
  8000bb:	83 c0 01             	add    $0x1,%eax
  8000be:	50                   	push   %eax
  8000bf:	ff 35 00 30 80 00    	pushl  0x803000
  8000c5:	68 00 00 b0 00       	push   $0xb00000
  8000ca:	e8 3c 09 00 00       	call   800a0b <memcpy>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
  8000cf:	6a 07                	push   $0x7
  8000d1:	68 00 00 b0 00       	push   $0xb00000
  8000d6:	6a 00                	push   $0x0
  8000d8:	ff 75 f4             	pushl  -0xc(%ebp)
  8000db:	e8 56 10 00 00       	call   801136 <ipc_send>
		return;
  8000e0:	83 c4 20             	add    $0x20,%esp
  8000e3:	e9 af 00 00 00       	jmp    800197 <umain+0x164>
	}

	// Parent
	sys_page_alloc(thisenv->env_id, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  8000e8:	a1 08 40 80 00       	mov    0x804008,%eax
  8000ed:	8b 40 48             	mov    0x48(%eax),%eax
  8000f0:	83 ec 04             	sub    $0x4,%esp
  8000f3:	6a 07                	push   $0x7
  8000f5:	68 00 00 a0 00       	push   $0xa00000
  8000fa:	50                   	push   %eax
  8000fb:	e8 14 0b 00 00       	call   800c14 <sys_page_alloc>
	memcpy(TEMP_ADDR, str1, strlen(str1) + 1);
  800100:	83 c4 04             	add    $0x4,%esp
  800103:	ff 35 04 30 80 00    	pushl  0x803004
  800109:	e8 ca 06 00 00       	call   8007d8 <strlen>
  80010e:	83 c4 0c             	add    $0xc,%esp
  800111:	83 c0 01             	add    $0x1,%eax
  800114:	50                   	push   %eax
  800115:	ff 35 04 30 80 00    	pushl  0x803004
  80011b:	68 00 00 a0 00       	push   $0xa00000
  800120:	e8 e6 08 00 00       	call   800a0b <memcpy>
	ipc_send(who, 0, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  800125:	6a 07                	push   $0x7
  800127:	68 00 00 a0 00       	push   $0xa00000
  80012c:	6a 00                	push   $0x0
  80012e:	ff 75 f4             	pushl  -0xc(%ebp)
  800131:	e8 00 10 00 00       	call   801136 <ipc_send>

	ipc_recv(&who, TEMP_ADDR, 0);
  800136:	83 c4 1c             	add    $0x1c,%esp
  800139:	6a 00                	push   $0x0
  80013b:	68 00 00 a0 00       	push   $0xa00000
  800140:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800143:	50                   	push   %eax
  800144:	e8 84 0f 00 00       	call   8010cd <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  800149:	83 c4 0c             	add    $0xc,%esp
  80014c:	68 00 00 a0 00       	push   $0xa00000
  800151:	ff 75 f4             	pushl  -0xc(%ebp)
  800154:	68 e0 26 80 00       	push   $0x8026e0
  800159:	e8 2e 01 00 00       	call   80028c <cprintf>
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
  80015e:	83 c4 04             	add    $0x4,%esp
  800161:	ff 35 00 30 80 00    	pushl  0x803000
  800167:	e8 6c 06 00 00       	call   8007d8 <strlen>
  80016c:	83 c4 0c             	add    $0xc,%esp
  80016f:	50                   	push   %eax
  800170:	ff 35 00 30 80 00    	pushl  0x803000
  800176:	68 00 00 a0 00       	push   $0xa00000
  80017b:	e8 61 07 00 00       	call   8008e1 <strncmp>
  800180:	83 c4 10             	add    $0x10,%esp
  800183:	85 c0                	test   %eax,%eax
  800185:	75 10                	jne    800197 <umain+0x164>
		cprintf("parent received correct message\n");
  800187:	83 ec 0c             	sub    $0xc,%esp
  80018a:	68 14 27 80 00       	push   $0x802714
  80018f:	e8 f8 00 00 00       	call   80028c <cprintf>
  800194:	83 c4 10             	add    $0x10,%esp
	return;
}
  800197:	c9                   	leave  
  800198:	c3                   	ret    

00800199 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800199:	55                   	push   %ebp
  80019a:	89 e5                	mov    %esp,%ebp
  80019c:	56                   	push   %esi
  80019d:	53                   	push   %ebx
  80019e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001a1:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8001a4:	e8 2d 0a 00 00       	call   800bd6 <sys_getenvid>
  8001a9:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001ae:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001b1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001b6:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001bb:	85 db                	test   %ebx,%ebx
  8001bd:	7e 07                	jle    8001c6 <libmain+0x2d>
		binaryname = argv[0];
  8001bf:	8b 06                	mov    (%esi),%eax
  8001c1:	a3 08 30 80 00       	mov    %eax,0x803008

	// call user main routine
	umain(argc, argv);
  8001c6:	83 ec 08             	sub    $0x8,%esp
  8001c9:	56                   	push   %esi
  8001ca:	53                   	push   %ebx
  8001cb:	e8 63 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8001d0:	e8 0a 00 00 00       	call   8001df <exit>
}
  8001d5:	83 c4 10             	add    $0x10,%esp
  8001d8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001db:	5b                   	pop    %ebx
  8001dc:	5e                   	pop    %esi
  8001dd:	5d                   	pop    %ebp
  8001de:	c3                   	ret    

008001df <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001df:	55                   	push   %ebp
  8001e0:	89 e5                	mov    %esp,%ebp
  8001e2:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001e5:	e8 a4 11 00 00       	call   80138e <close_all>
	sys_env_destroy(0);
  8001ea:	83 ec 0c             	sub    $0xc,%esp
  8001ed:	6a 00                	push   $0x0
  8001ef:	e8 a1 09 00 00       	call   800b95 <sys_env_destroy>
}
  8001f4:	83 c4 10             	add    $0x10,%esp
  8001f7:	c9                   	leave  
  8001f8:	c3                   	ret    

008001f9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001f9:	55                   	push   %ebp
  8001fa:	89 e5                	mov    %esp,%ebp
  8001fc:	53                   	push   %ebx
  8001fd:	83 ec 04             	sub    $0x4,%esp
  800200:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800203:	8b 13                	mov    (%ebx),%edx
  800205:	8d 42 01             	lea    0x1(%edx),%eax
  800208:	89 03                	mov    %eax,(%ebx)
  80020a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80020d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800211:	3d ff 00 00 00       	cmp    $0xff,%eax
  800216:	75 1a                	jne    800232 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800218:	83 ec 08             	sub    $0x8,%esp
  80021b:	68 ff 00 00 00       	push   $0xff
  800220:	8d 43 08             	lea    0x8(%ebx),%eax
  800223:	50                   	push   %eax
  800224:	e8 2f 09 00 00       	call   800b58 <sys_cputs>
		b->idx = 0;
  800229:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80022f:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800232:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800236:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800239:	c9                   	leave  
  80023a:	c3                   	ret    

0080023b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80023b:	55                   	push   %ebp
  80023c:	89 e5                	mov    %esp,%ebp
  80023e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800244:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80024b:	00 00 00 
	b.cnt = 0;
  80024e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800255:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800258:	ff 75 0c             	pushl  0xc(%ebp)
  80025b:	ff 75 08             	pushl  0x8(%ebp)
  80025e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800264:	50                   	push   %eax
  800265:	68 f9 01 80 00       	push   $0x8001f9
  80026a:	e8 54 01 00 00       	call   8003c3 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80026f:	83 c4 08             	add    $0x8,%esp
  800272:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800278:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80027e:	50                   	push   %eax
  80027f:	e8 d4 08 00 00       	call   800b58 <sys_cputs>

	return b.cnt;
}
  800284:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80028a:	c9                   	leave  
  80028b:	c3                   	ret    

0080028c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80028c:	55                   	push   %ebp
  80028d:	89 e5                	mov    %esp,%ebp
  80028f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800292:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800295:	50                   	push   %eax
  800296:	ff 75 08             	pushl  0x8(%ebp)
  800299:	e8 9d ff ff ff       	call   80023b <vcprintf>
	va_end(ap);

	return cnt;
}
  80029e:	c9                   	leave  
  80029f:	c3                   	ret    

008002a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	57                   	push   %edi
  8002a4:	56                   	push   %esi
  8002a5:	53                   	push   %ebx
  8002a6:	83 ec 1c             	sub    $0x1c,%esp
  8002a9:	89 c7                	mov    %eax,%edi
  8002ab:	89 d6                	mov    %edx,%esi
  8002ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002b3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002b6:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002b9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002bc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002c4:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002c7:	39 d3                	cmp    %edx,%ebx
  8002c9:	72 05                	jb     8002d0 <printnum+0x30>
  8002cb:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002ce:	77 45                	ja     800315 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002d0:	83 ec 0c             	sub    $0xc,%esp
  8002d3:	ff 75 18             	pushl  0x18(%ebp)
  8002d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8002d9:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002dc:	53                   	push   %ebx
  8002dd:	ff 75 10             	pushl  0x10(%ebp)
  8002e0:	83 ec 08             	sub    $0x8,%esp
  8002e3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002e6:	ff 75 e0             	pushl  -0x20(%ebp)
  8002e9:	ff 75 dc             	pushl  -0x24(%ebp)
  8002ec:	ff 75 d8             	pushl  -0x28(%ebp)
  8002ef:	e8 4c 21 00 00       	call   802440 <__udivdi3>
  8002f4:	83 c4 18             	add    $0x18,%esp
  8002f7:	52                   	push   %edx
  8002f8:	50                   	push   %eax
  8002f9:	89 f2                	mov    %esi,%edx
  8002fb:	89 f8                	mov    %edi,%eax
  8002fd:	e8 9e ff ff ff       	call   8002a0 <printnum>
  800302:	83 c4 20             	add    $0x20,%esp
  800305:	eb 18                	jmp    80031f <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800307:	83 ec 08             	sub    $0x8,%esp
  80030a:	56                   	push   %esi
  80030b:	ff 75 18             	pushl  0x18(%ebp)
  80030e:	ff d7                	call   *%edi
  800310:	83 c4 10             	add    $0x10,%esp
  800313:	eb 03                	jmp    800318 <printnum+0x78>
  800315:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800318:	83 eb 01             	sub    $0x1,%ebx
  80031b:	85 db                	test   %ebx,%ebx
  80031d:	7f e8                	jg     800307 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80031f:	83 ec 08             	sub    $0x8,%esp
  800322:	56                   	push   %esi
  800323:	83 ec 04             	sub    $0x4,%esp
  800326:	ff 75 e4             	pushl  -0x1c(%ebp)
  800329:	ff 75 e0             	pushl  -0x20(%ebp)
  80032c:	ff 75 dc             	pushl  -0x24(%ebp)
  80032f:	ff 75 d8             	pushl  -0x28(%ebp)
  800332:	e8 39 22 00 00       	call   802570 <__umoddi3>
  800337:	83 c4 14             	add    $0x14,%esp
  80033a:	0f be 80 8c 27 80 00 	movsbl 0x80278c(%eax),%eax
  800341:	50                   	push   %eax
  800342:	ff d7                	call   *%edi
}
  800344:	83 c4 10             	add    $0x10,%esp
  800347:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80034a:	5b                   	pop    %ebx
  80034b:	5e                   	pop    %esi
  80034c:	5f                   	pop    %edi
  80034d:	5d                   	pop    %ebp
  80034e:	c3                   	ret    

0080034f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80034f:	55                   	push   %ebp
  800350:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800352:	83 fa 01             	cmp    $0x1,%edx
  800355:	7e 0e                	jle    800365 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800357:	8b 10                	mov    (%eax),%edx
  800359:	8d 4a 08             	lea    0x8(%edx),%ecx
  80035c:	89 08                	mov    %ecx,(%eax)
  80035e:	8b 02                	mov    (%edx),%eax
  800360:	8b 52 04             	mov    0x4(%edx),%edx
  800363:	eb 22                	jmp    800387 <getuint+0x38>
	else if (lflag)
  800365:	85 d2                	test   %edx,%edx
  800367:	74 10                	je     800379 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800369:	8b 10                	mov    (%eax),%edx
  80036b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80036e:	89 08                	mov    %ecx,(%eax)
  800370:	8b 02                	mov    (%edx),%eax
  800372:	ba 00 00 00 00       	mov    $0x0,%edx
  800377:	eb 0e                	jmp    800387 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800379:	8b 10                	mov    (%eax),%edx
  80037b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80037e:	89 08                	mov    %ecx,(%eax)
  800380:	8b 02                	mov    (%edx),%eax
  800382:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800387:	5d                   	pop    %ebp
  800388:	c3                   	ret    

00800389 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800389:	55                   	push   %ebp
  80038a:	89 e5                	mov    %esp,%ebp
  80038c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80038f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800393:	8b 10                	mov    (%eax),%edx
  800395:	3b 50 04             	cmp    0x4(%eax),%edx
  800398:	73 0a                	jae    8003a4 <sprintputch+0x1b>
		*b->buf++ = ch;
  80039a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80039d:	89 08                	mov    %ecx,(%eax)
  80039f:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a2:	88 02                	mov    %al,(%edx)
}
  8003a4:	5d                   	pop    %ebp
  8003a5:	c3                   	ret    

008003a6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003a6:	55                   	push   %ebp
  8003a7:	89 e5                	mov    %esp,%ebp
  8003a9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003ac:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003af:	50                   	push   %eax
  8003b0:	ff 75 10             	pushl  0x10(%ebp)
  8003b3:	ff 75 0c             	pushl  0xc(%ebp)
  8003b6:	ff 75 08             	pushl  0x8(%ebp)
  8003b9:	e8 05 00 00 00       	call   8003c3 <vprintfmt>
	va_end(ap);
}
  8003be:	83 c4 10             	add    $0x10,%esp
  8003c1:	c9                   	leave  
  8003c2:	c3                   	ret    

008003c3 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003c3:	55                   	push   %ebp
  8003c4:	89 e5                	mov    %esp,%ebp
  8003c6:	57                   	push   %edi
  8003c7:	56                   	push   %esi
  8003c8:	53                   	push   %ebx
  8003c9:	83 ec 2c             	sub    $0x2c,%esp
  8003cc:	8b 75 08             	mov    0x8(%ebp),%esi
  8003cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003d2:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003d5:	eb 12                	jmp    8003e9 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003d7:	85 c0                	test   %eax,%eax
  8003d9:	0f 84 89 03 00 00    	je     800768 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8003df:	83 ec 08             	sub    $0x8,%esp
  8003e2:	53                   	push   %ebx
  8003e3:	50                   	push   %eax
  8003e4:	ff d6                	call   *%esi
  8003e6:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003e9:	83 c7 01             	add    $0x1,%edi
  8003ec:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003f0:	83 f8 25             	cmp    $0x25,%eax
  8003f3:	75 e2                	jne    8003d7 <vprintfmt+0x14>
  8003f5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003f9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800400:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800407:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80040e:	ba 00 00 00 00       	mov    $0x0,%edx
  800413:	eb 07                	jmp    80041c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800415:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800418:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041c:	8d 47 01             	lea    0x1(%edi),%eax
  80041f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800422:	0f b6 07             	movzbl (%edi),%eax
  800425:	0f b6 c8             	movzbl %al,%ecx
  800428:	83 e8 23             	sub    $0x23,%eax
  80042b:	3c 55                	cmp    $0x55,%al
  80042d:	0f 87 1a 03 00 00    	ja     80074d <vprintfmt+0x38a>
  800433:	0f b6 c0             	movzbl %al,%eax
  800436:	ff 24 85 c0 28 80 00 	jmp    *0x8028c0(,%eax,4)
  80043d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800440:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800444:	eb d6                	jmp    80041c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800446:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800449:	b8 00 00 00 00       	mov    $0x0,%eax
  80044e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800451:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800454:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800458:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80045b:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80045e:	83 fa 09             	cmp    $0x9,%edx
  800461:	77 39                	ja     80049c <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800463:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800466:	eb e9                	jmp    800451 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800468:	8b 45 14             	mov    0x14(%ebp),%eax
  80046b:	8d 48 04             	lea    0x4(%eax),%ecx
  80046e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800471:	8b 00                	mov    (%eax),%eax
  800473:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800476:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800479:	eb 27                	jmp    8004a2 <vprintfmt+0xdf>
  80047b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80047e:	85 c0                	test   %eax,%eax
  800480:	b9 00 00 00 00       	mov    $0x0,%ecx
  800485:	0f 49 c8             	cmovns %eax,%ecx
  800488:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80048e:	eb 8c                	jmp    80041c <vprintfmt+0x59>
  800490:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800493:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80049a:	eb 80                	jmp    80041c <vprintfmt+0x59>
  80049c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80049f:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004a2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004a6:	0f 89 70 ff ff ff    	jns    80041c <vprintfmt+0x59>
				width = precision, precision = -1;
  8004ac:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004af:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004b2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004b9:	e9 5e ff ff ff       	jmp    80041c <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004be:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004c4:	e9 53 ff ff ff       	jmp    80041c <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004cc:	8d 50 04             	lea    0x4(%eax),%edx
  8004cf:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d2:	83 ec 08             	sub    $0x8,%esp
  8004d5:	53                   	push   %ebx
  8004d6:	ff 30                	pushl  (%eax)
  8004d8:	ff d6                	call   *%esi
			break;
  8004da:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004e0:	e9 04 ff ff ff       	jmp    8003e9 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e8:	8d 50 04             	lea    0x4(%eax),%edx
  8004eb:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ee:	8b 00                	mov    (%eax),%eax
  8004f0:	99                   	cltd   
  8004f1:	31 d0                	xor    %edx,%eax
  8004f3:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004f5:	83 f8 0f             	cmp    $0xf,%eax
  8004f8:	7f 0b                	jg     800505 <vprintfmt+0x142>
  8004fa:	8b 14 85 20 2a 80 00 	mov    0x802a20(,%eax,4),%edx
  800501:	85 d2                	test   %edx,%edx
  800503:	75 18                	jne    80051d <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800505:	50                   	push   %eax
  800506:	68 a4 27 80 00       	push   $0x8027a4
  80050b:	53                   	push   %ebx
  80050c:	56                   	push   %esi
  80050d:	e8 94 fe ff ff       	call   8003a6 <printfmt>
  800512:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800515:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800518:	e9 cc fe ff ff       	jmp    8003e9 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80051d:	52                   	push   %edx
  80051e:	68 ee 2b 80 00       	push   $0x802bee
  800523:	53                   	push   %ebx
  800524:	56                   	push   %esi
  800525:	e8 7c fe ff ff       	call   8003a6 <printfmt>
  80052a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800530:	e9 b4 fe ff ff       	jmp    8003e9 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800535:	8b 45 14             	mov    0x14(%ebp),%eax
  800538:	8d 50 04             	lea    0x4(%eax),%edx
  80053b:	89 55 14             	mov    %edx,0x14(%ebp)
  80053e:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800540:	85 ff                	test   %edi,%edi
  800542:	b8 9d 27 80 00       	mov    $0x80279d,%eax
  800547:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80054a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80054e:	0f 8e 94 00 00 00    	jle    8005e8 <vprintfmt+0x225>
  800554:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800558:	0f 84 98 00 00 00    	je     8005f6 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80055e:	83 ec 08             	sub    $0x8,%esp
  800561:	ff 75 d0             	pushl  -0x30(%ebp)
  800564:	57                   	push   %edi
  800565:	e8 86 02 00 00       	call   8007f0 <strnlen>
  80056a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80056d:	29 c1                	sub    %eax,%ecx
  80056f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800572:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800575:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800579:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80057c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80057f:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800581:	eb 0f                	jmp    800592 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800583:	83 ec 08             	sub    $0x8,%esp
  800586:	53                   	push   %ebx
  800587:	ff 75 e0             	pushl  -0x20(%ebp)
  80058a:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80058c:	83 ef 01             	sub    $0x1,%edi
  80058f:	83 c4 10             	add    $0x10,%esp
  800592:	85 ff                	test   %edi,%edi
  800594:	7f ed                	jg     800583 <vprintfmt+0x1c0>
  800596:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800599:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80059c:	85 c9                	test   %ecx,%ecx
  80059e:	b8 00 00 00 00       	mov    $0x0,%eax
  8005a3:	0f 49 c1             	cmovns %ecx,%eax
  8005a6:	29 c1                	sub    %eax,%ecx
  8005a8:	89 75 08             	mov    %esi,0x8(%ebp)
  8005ab:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005ae:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005b1:	89 cb                	mov    %ecx,%ebx
  8005b3:	eb 4d                	jmp    800602 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005b5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005b9:	74 1b                	je     8005d6 <vprintfmt+0x213>
  8005bb:	0f be c0             	movsbl %al,%eax
  8005be:	83 e8 20             	sub    $0x20,%eax
  8005c1:	83 f8 5e             	cmp    $0x5e,%eax
  8005c4:	76 10                	jbe    8005d6 <vprintfmt+0x213>
					putch('?', putdat);
  8005c6:	83 ec 08             	sub    $0x8,%esp
  8005c9:	ff 75 0c             	pushl  0xc(%ebp)
  8005cc:	6a 3f                	push   $0x3f
  8005ce:	ff 55 08             	call   *0x8(%ebp)
  8005d1:	83 c4 10             	add    $0x10,%esp
  8005d4:	eb 0d                	jmp    8005e3 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8005d6:	83 ec 08             	sub    $0x8,%esp
  8005d9:	ff 75 0c             	pushl  0xc(%ebp)
  8005dc:	52                   	push   %edx
  8005dd:	ff 55 08             	call   *0x8(%ebp)
  8005e0:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005e3:	83 eb 01             	sub    $0x1,%ebx
  8005e6:	eb 1a                	jmp    800602 <vprintfmt+0x23f>
  8005e8:	89 75 08             	mov    %esi,0x8(%ebp)
  8005eb:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005ee:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005f1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005f4:	eb 0c                	jmp    800602 <vprintfmt+0x23f>
  8005f6:	89 75 08             	mov    %esi,0x8(%ebp)
  8005f9:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005fc:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005ff:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800602:	83 c7 01             	add    $0x1,%edi
  800605:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800609:	0f be d0             	movsbl %al,%edx
  80060c:	85 d2                	test   %edx,%edx
  80060e:	74 23                	je     800633 <vprintfmt+0x270>
  800610:	85 f6                	test   %esi,%esi
  800612:	78 a1                	js     8005b5 <vprintfmt+0x1f2>
  800614:	83 ee 01             	sub    $0x1,%esi
  800617:	79 9c                	jns    8005b5 <vprintfmt+0x1f2>
  800619:	89 df                	mov    %ebx,%edi
  80061b:	8b 75 08             	mov    0x8(%ebp),%esi
  80061e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800621:	eb 18                	jmp    80063b <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800623:	83 ec 08             	sub    $0x8,%esp
  800626:	53                   	push   %ebx
  800627:	6a 20                	push   $0x20
  800629:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80062b:	83 ef 01             	sub    $0x1,%edi
  80062e:	83 c4 10             	add    $0x10,%esp
  800631:	eb 08                	jmp    80063b <vprintfmt+0x278>
  800633:	89 df                	mov    %ebx,%edi
  800635:	8b 75 08             	mov    0x8(%ebp),%esi
  800638:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80063b:	85 ff                	test   %edi,%edi
  80063d:	7f e4                	jg     800623 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800642:	e9 a2 fd ff ff       	jmp    8003e9 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800647:	83 fa 01             	cmp    $0x1,%edx
  80064a:	7e 16                	jle    800662 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80064c:	8b 45 14             	mov    0x14(%ebp),%eax
  80064f:	8d 50 08             	lea    0x8(%eax),%edx
  800652:	89 55 14             	mov    %edx,0x14(%ebp)
  800655:	8b 50 04             	mov    0x4(%eax),%edx
  800658:	8b 00                	mov    (%eax),%eax
  80065a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80065d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800660:	eb 32                	jmp    800694 <vprintfmt+0x2d1>
	else if (lflag)
  800662:	85 d2                	test   %edx,%edx
  800664:	74 18                	je     80067e <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800666:	8b 45 14             	mov    0x14(%ebp),%eax
  800669:	8d 50 04             	lea    0x4(%eax),%edx
  80066c:	89 55 14             	mov    %edx,0x14(%ebp)
  80066f:	8b 00                	mov    (%eax),%eax
  800671:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800674:	89 c1                	mov    %eax,%ecx
  800676:	c1 f9 1f             	sar    $0x1f,%ecx
  800679:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80067c:	eb 16                	jmp    800694 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80067e:	8b 45 14             	mov    0x14(%ebp),%eax
  800681:	8d 50 04             	lea    0x4(%eax),%edx
  800684:	89 55 14             	mov    %edx,0x14(%ebp)
  800687:	8b 00                	mov    (%eax),%eax
  800689:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80068c:	89 c1                	mov    %eax,%ecx
  80068e:	c1 f9 1f             	sar    $0x1f,%ecx
  800691:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800694:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800697:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80069a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80069f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006a3:	79 74                	jns    800719 <vprintfmt+0x356>
				putch('-', putdat);
  8006a5:	83 ec 08             	sub    $0x8,%esp
  8006a8:	53                   	push   %ebx
  8006a9:	6a 2d                	push   $0x2d
  8006ab:	ff d6                	call   *%esi
				num = -(long long) num;
  8006ad:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006b0:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006b3:	f7 d8                	neg    %eax
  8006b5:	83 d2 00             	adc    $0x0,%edx
  8006b8:	f7 da                	neg    %edx
  8006ba:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006bd:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006c2:	eb 55                	jmp    800719 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006c4:	8d 45 14             	lea    0x14(%ebp),%eax
  8006c7:	e8 83 fc ff ff       	call   80034f <getuint>
			base = 10;
  8006cc:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006d1:	eb 46                	jmp    800719 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8006d3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006d6:	e8 74 fc ff ff       	call   80034f <getuint>
                        base = 8;
  8006db:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  8006e0:	eb 37                	jmp    800719 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8006e2:	83 ec 08             	sub    $0x8,%esp
  8006e5:	53                   	push   %ebx
  8006e6:	6a 30                	push   $0x30
  8006e8:	ff d6                	call   *%esi
			putch('x', putdat);
  8006ea:	83 c4 08             	add    $0x8,%esp
  8006ed:	53                   	push   %ebx
  8006ee:	6a 78                	push   $0x78
  8006f0:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f5:	8d 50 04             	lea    0x4(%eax),%edx
  8006f8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006fb:	8b 00                	mov    (%eax),%eax
  8006fd:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800702:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800705:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80070a:	eb 0d                	jmp    800719 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80070c:	8d 45 14             	lea    0x14(%ebp),%eax
  80070f:	e8 3b fc ff ff       	call   80034f <getuint>
			base = 16;
  800714:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800719:	83 ec 0c             	sub    $0xc,%esp
  80071c:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800720:	57                   	push   %edi
  800721:	ff 75 e0             	pushl  -0x20(%ebp)
  800724:	51                   	push   %ecx
  800725:	52                   	push   %edx
  800726:	50                   	push   %eax
  800727:	89 da                	mov    %ebx,%edx
  800729:	89 f0                	mov    %esi,%eax
  80072b:	e8 70 fb ff ff       	call   8002a0 <printnum>
			break;
  800730:	83 c4 20             	add    $0x20,%esp
  800733:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800736:	e9 ae fc ff ff       	jmp    8003e9 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80073b:	83 ec 08             	sub    $0x8,%esp
  80073e:	53                   	push   %ebx
  80073f:	51                   	push   %ecx
  800740:	ff d6                	call   *%esi
			break;
  800742:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800745:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800748:	e9 9c fc ff ff       	jmp    8003e9 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80074d:	83 ec 08             	sub    $0x8,%esp
  800750:	53                   	push   %ebx
  800751:	6a 25                	push   $0x25
  800753:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800755:	83 c4 10             	add    $0x10,%esp
  800758:	eb 03                	jmp    80075d <vprintfmt+0x39a>
  80075a:	83 ef 01             	sub    $0x1,%edi
  80075d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800761:	75 f7                	jne    80075a <vprintfmt+0x397>
  800763:	e9 81 fc ff ff       	jmp    8003e9 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800768:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80076b:	5b                   	pop    %ebx
  80076c:	5e                   	pop    %esi
  80076d:	5f                   	pop    %edi
  80076e:	5d                   	pop    %ebp
  80076f:	c3                   	ret    

00800770 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800770:	55                   	push   %ebp
  800771:	89 e5                	mov    %esp,%ebp
  800773:	83 ec 18             	sub    $0x18,%esp
  800776:	8b 45 08             	mov    0x8(%ebp),%eax
  800779:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80077c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80077f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800783:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800786:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80078d:	85 c0                	test   %eax,%eax
  80078f:	74 26                	je     8007b7 <vsnprintf+0x47>
  800791:	85 d2                	test   %edx,%edx
  800793:	7e 22                	jle    8007b7 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800795:	ff 75 14             	pushl  0x14(%ebp)
  800798:	ff 75 10             	pushl  0x10(%ebp)
  80079b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80079e:	50                   	push   %eax
  80079f:	68 89 03 80 00       	push   $0x800389
  8007a4:	e8 1a fc ff ff       	call   8003c3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007ac:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007b2:	83 c4 10             	add    $0x10,%esp
  8007b5:	eb 05                	jmp    8007bc <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007b7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007bc:	c9                   	leave  
  8007bd:	c3                   	ret    

008007be <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007be:	55                   	push   %ebp
  8007bf:	89 e5                	mov    %esp,%ebp
  8007c1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007c4:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007c7:	50                   	push   %eax
  8007c8:	ff 75 10             	pushl  0x10(%ebp)
  8007cb:	ff 75 0c             	pushl  0xc(%ebp)
  8007ce:	ff 75 08             	pushl  0x8(%ebp)
  8007d1:	e8 9a ff ff ff       	call   800770 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007d6:	c9                   	leave  
  8007d7:	c3                   	ret    

008007d8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007d8:	55                   	push   %ebp
  8007d9:	89 e5                	mov    %esp,%ebp
  8007db:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007de:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e3:	eb 03                	jmp    8007e8 <strlen+0x10>
		n++;
  8007e5:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007e8:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007ec:	75 f7                	jne    8007e5 <strlen+0xd>
		n++;
	return n;
}
  8007ee:	5d                   	pop    %ebp
  8007ef:	c3                   	ret    

008007f0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007f6:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8007fe:	eb 03                	jmp    800803 <strnlen+0x13>
		n++;
  800800:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800803:	39 c2                	cmp    %eax,%edx
  800805:	74 08                	je     80080f <strnlen+0x1f>
  800807:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80080b:	75 f3                	jne    800800 <strnlen+0x10>
  80080d:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80080f:	5d                   	pop    %ebp
  800810:	c3                   	ret    

00800811 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800811:	55                   	push   %ebp
  800812:	89 e5                	mov    %esp,%ebp
  800814:	53                   	push   %ebx
  800815:	8b 45 08             	mov    0x8(%ebp),%eax
  800818:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80081b:	89 c2                	mov    %eax,%edx
  80081d:	83 c2 01             	add    $0x1,%edx
  800820:	83 c1 01             	add    $0x1,%ecx
  800823:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800827:	88 5a ff             	mov    %bl,-0x1(%edx)
  80082a:	84 db                	test   %bl,%bl
  80082c:	75 ef                	jne    80081d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80082e:	5b                   	pop    %ebx
  80082f:	5d                   	pop    %ebp
  800830:	c3                   	ret    

00800831 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800831:	55                   	push   %ebp
  800832:	89 e5                	mov    %esp,%ebp
  800834:	53                   	push   %ebx
  800835:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800838:	53                   	push   %ebx
  800839:	e8 9a ff ff ff       	call   8007d8 <strlen>
  80083e:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800841:	ff 75 0c             	pushl  0xc(%ebp)
  800844:	01 d8                	add    %ebx,%eax
  800846:	50                   	push   %eax
  800847:	e8 c5 ff ff ff       	call   800811 <strcpy>
	return dst;
}
  80084c:	89 d8                	mov    %ebx,%eax
  80084e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800851:	c9                   	leave  
  800852:	c3                   	ret    

00800853 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800853:	55                   	push   %ebp
  800854:	89 e5                	mov    %esp,%ebp
  800856:	56                   	push   %esi
  800857:	53                   	push   %ebx
  800858:	8b 75 08             	mov    0x8(%ebp),%esi
  80085b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80085e:	89 f3                	mov    %esi,%ebx
  800860:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800863:	89 f2                	mov    %esi,%edx
  800865:	eb 0f                	jmp    800876 <strncpy+0x23>
		*dst++ = *src;
  800867:	83 c2 01             	add    $0x1,%edx
  80086a:	0f b6 01             	movzbl (%ecx),%eax
  80086d:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800870:	80 39 01             	cmpb   $0x1,(%ecx)
  800873:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800876:	39 da                	cmp    %ebx,%edx
  800878:	75 ed                	jne    800867 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80087a:	89 f0                	mov    %esi,%eax
  80087c:	5b                   	pop    %ebx
  80087d:	5e                   	pop    %esi
  80087e:	5d                   	pop    %ebp
  80087f:	c3                   	ret    

00800880 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800880:	55                   	push   %ebp
  800881:	89 e5                	mov    %esp,%ebp
  800883:	56                   	push   %esi
  800884:	53                   	push   %ebx
  800885:	8b 75 08             	mov    0x8(%ebp),%esi
  800888:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80088b:	8b 55 10             	mov    0x10(%ebp),%edx
  80088e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800890:	85 d2                	test   %edx,%edx
  800892:	74 21                	je     8008b5 <strlcpy+0x35>
  800894:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800898:	89 f2                	mov    %esi,%edx
  80089a:	eb 09                	jmp    8008a5 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80089c:	83 c2 01             	add    $0x1,%edx
  80089f:	83 c1 01             	add    $0x1,%ecx
  8008a2:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008a5:	39 c2                	cmp    %eax,%edx
  8008a7:	74 09                	je     8008b2 <strlcpy+0x32>
  8008a9:	0f b6 19             	movzbl (%ecx),%ebx
  8008ac:	84 db                	test   %bl,%bl
  8008ae:	75 ec                	jne    80089c <strlcpy+0x1c>
  8008b0:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008b2:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008b5:	29 f0                	sub    %esi,%eax
}
  8008b7:	5b                   	pop    %ebx
  8008b8:	5e                   	pop    %esi
  8008b9:	5d                   	pop    %ebp
  8008ba:	c3                   	ret    

008008bb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008bb:	55                   	push   %ebp
  8008bc:	89 e5                	mov    %esp,%ebp
  8008be:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008c4:	eb 06                	jmp    8008cc <strcmp+0x11>
		p++, q++;
  8008c6:	83 c1 01             	add    $0x1,%ecx
  8008c9:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008cc:	0f b6 01             	movzbl (%ecx),%eax
  8008cf:	84 c0                	test   %al,%al
  8008d1:	74 04                	je     8008d7 <strcmp+0x1c>
  8008d3:	3a 02                	cmp    (%edx),%al
  8008d5:	74 ef                	je     8008c6 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d7:	0f b6 c0             	movzbl %al,%eax
  8008da:	0f b6 12             	movzbl (%edx),%edx
  8008dd:	29 d0                	sub    %edx,%eax
}
  8008df:	5d                   	pop    %ebp
  8008e0:	c3                   	ret    

008008e1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008e1:	55                   	push   %ebp
  8008e2:	89 e5                	mov    %esp,%ebp
  8008e4:	53                   	push   %ebx
  8008e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008eb:	89 c3                	mov    %eax,%ebx
  8008ed:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008f0:	eb 06                	jmp    8008f8 <strncmp+0x17>
		n--, p++, q++;
  8008f2:	83 c0 01             	add    $0x1,%eax
  8008f5:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008f8:	39 d8                	cmp    %ebx,%eax
  8008fa:	74 15                	je     800911 <strncmp+0x30>
  8008fc:	0f b6 08             	movzbl (%eax),%ecx
  8008ff:	84 c9                	test   %cl,%cl
  800901:	74 04                	je     800907 <strncmp+0x26>
  800903:	3a 0a                	cmp    (%edx),%cl
  800905:	74 eb                	je     8008f2 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800907:	0f b6 00             	movzbl (%eax),%eax
  80090a:	0f b6 12             	movzbl (%edx),%edx
  80090d:	29 d0                	sub    %edx,%eax
  80090f:	eb 05                	jmp    800916 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800911:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800916:	5b                   	pop    %ebx
  800917:	5d                   	pop    %ebp
  800918:	c3                   	ret    

00800919 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800919:	55                   	push   %ebp
  80091a:	89 e5                	mov    %esp,%ebp
  80091c:	8b 45 08             	mov    0x8(%ebp),%eax
  80091f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800923:	eb 07                	jmp    80092c <strchr+0x13>
		if (*s == c)
  800925:	38 ca                	cmp    %cl,%dl
  800927:	74 0f                	je     800938 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800929:	83 c0 01             	add    $0x1,%eax
  80092c:	0f b6 10             	movzbl (%eax),%edx
  80092f:	84 d2                	test   %dl,%dl
  800931:	75 f2                	jne    800925 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800933:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800938:	5d                   	pop    %ebp
  800939:	c3                   	ret    

0080093a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
  80093d:	8b 45 08             	mov    0x8(%ebp),%eax
  800940:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800944:	eb 03                	jmp    800949 <strfind+0xf>
  800946:	83 c0 01             	add    $0x1,%eax
  800949:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80094c:	38 ca                	cmp    %cl,%dl
  80094e:	74 04                	je     800954 <strfind+0x1a>
  800950:	84 d2                	test   %dl,%dl
  800952:	75 f2                	jne    800946 <strfind+0xc>
			break;
	return (char *) s;
}
  800954:	5d                   	pop    %ebp
  800955:	c3                   	ret    

00800956 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800956:	55                   	push   %ebp
  800957:	89 e5                	mov    %esp,%ebp
  800959:	57                   	push   %edi
  80095a:	56                   	push   %esi
  80095b:	53                   	push   %ebx
  80095c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80095f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800962:	85 c9                	test   %ecx,%ecx
  800964:	74 36                	je     80099c <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800966:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80096c:	75 28                	jne    800996 <memset+0x40>
  80096e:	f6 c1 03             	test   $0x3,%cl
  800971:	75 23                	jne    800996 <memset+0x40>
		c &= 0xFF;
  800973:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800977:	89 d3                	mov    %edx,%ebx
  800979:	c1 e3 08             	shl    $0x8,%ebx
  80097c:	89 d6                	mov    %edx,%esi
  80097e:	c1 e6 18             	shl    $0x18,%esi
  800981:	89 d0                	mov    %edx,%eax
  800983:	c1 e0 10             	shl    $0x10,%eax
  800986:	09 f0                	or     %esi,%eax
  800988:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80098a:	89 d8                	mov    %ebx,%eax
  80098c:	09 d0                	or     %edx,%eax
  80098e:	c1 e9 02             	shr    $0x2,%ecx
  800991:	fc                   	cld    
  800992:	f3 ab                	rep stos %eax,%es:(%edi)
  800994:	eb 06                	jmp    80099c <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800996:	8b 45 0c             	mov    0xc(%ebp),%eax
  800999:	fc                   	cld    
  80099a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80099c:	89 f8                	mov    %edi,%eax
  80099e:	5b                   	pop    %ebx
  80099f:	5e                   	pop    %esi
  8009a0:	5f                   	pop    %edi
  8009a1:	5d                   	pop    %ebp
  8009a2:	c3                   	ret    

008009a3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009a3:	55                   	push   %ebp
  8009a4:	89 e5                	mov    %esp,%ebp
  8009a6:	57                   	push   %edi
  8009a7:	56                   	push   %esi
  8009a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ab:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009ae:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009b1:	39 c6                	cmp    %eax,%esi
  8009b3:	73 35                	jae    8009ea <memmove+0x47>
  8009b5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009b8:	39 d0                	cmp    %edx,%eax
  8009ba:	73 2e                	jae    8009ea <memmove+0x47>
		s += n;
		d += n;
  8009bc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009bf:	89 d6                	mov    %edx,%esi
  8009c1:	09 fe                	or     %edi,%esi
  8009c3:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009c9:	75 13                	jne    8009de <memmove+0x3b>
  8009cb:	f6 c1 03             	test   $0x3,%cl
  8009ce:	75 0e                	jne    8009de <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009d0:	83 ef 04             	sub    $0x4,%edi
  8009d3:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009d6:	c1 e9 02             	shr    $0x2,%ecx
  8009d9:	fd                   	std    
  8009da:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009dc:	eb 09                	jmp    8009e7 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009de:	83 ef 01             	sub    $0x1,%edi
  8009e1:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009e4:	fd                   	std    
  8009e5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009e7:	fc                   	cld    
  8009e8:	eb 1d                	jmp    800a07 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ea:	89 f2                	mov    %esi,%edx
  8009ec:	09 c2                	or     %eax,%edx
  8009ee:	f6 c2 03             	test   $0x3,%dl
  8009f1:	75 0f                	jne    800a02 <memmove+0x5f>
  8009f3:	f6 c1 03             	test   $0x3,%cl
  8009f6:	75 0a                	jne    800a02 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009f8:	c1 e9 02             	shr    $0x2,%ecx
  8009fb:	89 c7                	mov    %eax,%edi
  8009fd:	fc                   	cld    
  8009fe:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a00:	eb 05                	jmp    800a07 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a02:	89 c7                	mov    %eax,%edi
  800a04:	fc                   	cld    
  800a05:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a07:	5e                   	pop    %esi
  800a08:	5f                   	pop    %edi
  800a09:	5d                   	pop    %ebp
  800a0a:	c3                   	ret    

00800a0b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a0b:	55                   	push   %ebp
  800a0c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a0e:	ff 75 10             	pushl  0x10(%ebp)
  800a11:	ff 75 0c             	pushl  0xc(%ebp)
  800a14:	ff 75 08             	pushl  0x8(%ebp)
  800a17:	e8 87 ff ff ff       	call   8009a3 <memmove>
}
  800a1c:	c9                   	leave  
  800a1d:	c3                   	ret    

00800a1e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a1e:	55                   	push   %ebp
  800a1f:	89 e5                	mov    %esp,%ebp
  800a21:	56                   	push   %esi
  800a22:	53                   	push   %ebx
  800a23:	8b 45 08             	mov    0x8(%ebp),%eax
  800a26:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a29:	89 c6                	mov    %eax,%esi
  800a2b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a2e:	eb 1a                	jmp    800a4a <memcmp+0x2c>
		if (*s1 != *s2)
  800a30:	0f b6 08             	movzbl (%eax),%ecx
  800a33:	0f b6 1a             	movzbl (%edx),%ebx
  800a36:	38 d9                	cmp    %bl,%cl
  800a38:	74 0a                	je     800a44 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a3a:	0f b6 c1             	movzbl %cl,%eax
  800a3d:	0f b6 db             	movzbl %bl,%ebx
  800a40:	29 d8                	sub    %ebx,%eax
  800a42:	eb 0f                	jmp    800a53 <memcmp+0x35>
		s1++, s2++;
  800a44:	83 c0 01             	add    $0x1,%eax
  800a47:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a4a:	39 f0                	cmp    %esi,%eax
  800a4c:	75 e2                	jne    800a30 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a4e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a53:	5b                   	pop    %ebx
  800a54:	5e                   	pop    %esi
  800a55:	5d                   	pop    %ebp
  800a56:	c3                   	ret    

00800a57 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a57:	55                   	push   %ebp
  800a58:	89 e5                	mov    %esp,%ebp
  800a5a:	53                   	push   %ebx
  800a5b:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a5e:	89 c1                	mov    %eax,%ecx
  800a60:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a63:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a67:	eb 0a                	jmp    800a73 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a69:	0f b6 10             	movzbl (%eax),%edx
  800a6c:	39 da                	cmp    %ebx,%edx
  800a6e:	74 07                	je     800a77 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a70:	83 c0 01             	add    $0x1,%eax
  800a73:	39 c8                	cmp    %ecx,%eax
  800a75:	72 f2                	jb     800a69 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a77:	5b                   	pop    %ebx
  800a78:	5d                   	pop    %ebp
  800a79:	c3                   	ret    

00800a7a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a7a:	55                   	push   %ebp
  800a7b:	89 e5                	mov    %esp,%ebp
  800a7d:	57                   	push   %edi
  800a7e:	56                   	push   %esi
  800a7f:	53                   	push   %ebx
  800a80:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a83:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a86:	eb 03                	jmp    800a8b <strtol+0x11>
		s++;
  800a88:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a8b:	0f b6 01             	movzbl (%ecx),%eax
  800a8e:	3c 20                	cmp    $0x20,%al
  800a90:	74 f6                	je     800a88 <strtol+0xe>
  800a92:	3c 09                	cmp    $0x9,%al
  800a94:	74 f2                	je     800a88 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a96:	3c 2b                	cmp    $0x2b,%al
  800a98:	75 0a                	jne    800aa4 <strtol+0x2a>
		s++;
  800a9a:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a9d:	bf 00 00 00 00       	mov    $0x0,%edi
  800aa2:	eb 11                	jmp    800ab5 <strtol+0x3b>
  800aa4:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800aa9:	3c 2d                	cmp    $0x2d,%al
  800aab:	75 08                	jne    800ab5 <strtol+0x3b>
		s++, neg = 1;
  800aad:	83 c1 01             	add    $0x1,%ecx
  800ab0:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ab5:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800abb:	75 15                	jne    800ad2 <strtol+0x58>
  800abd:	80 39 30             	cmpb   $0x30,(%ecx)
  800ac0:	75 10                	jne    800ad2 <strtol+0x58>
  800ac2:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ac6:	75 7c                	jne    800b44 <strtol+0xca>
		s += 2, base = 16;
  800ac8:	83 c1 02             	add    $0x2,%ecx
  800acb:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ad0:	eb 16                	jmp    800ae8 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800ad2:	85 db                	test   %ebx,%ebx
  800ad4:	75 12                	jne    800ae8 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ad6:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800adb:	80 39 30             	cmpb   $0x30,(%ecx)
  800ade:	75 08                	jne    800ae8 <strtol+0x6e>
		s++, base = 8;
  800ae0:	83 c1 01             	add    $0x1,%ecx
  800ae3:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ae8:	b8 00 00 00 00       	mov    $0x0,%eax
  800aed:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800af0:	0f b6 11             	movzbl (%ecx),%edx
  800af3:	8d 72 d0             	lea    -0x30(%edx),%esi
  800af6:	89 f3                	mov    %esi,%ebx
  800af8:	80 fb 09             	cmp    $0x9,%bl
  800afb:	77 08                	ja     800b05 <strtol+0x8b>
			dig = *s - '0';
  800afd:	0f be d2             	movsbl %dl,%edx
  800b00:	83 ea 30             	sub    $0x30,%edx
  800b03:	eb 22                	jmp    800b27 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b05:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b08:	89 f3                	mov    %esi,%ebx
  800b0a:	80 fb 19             	cmp    $0x19,%bl
  800b0d:	77 08                	ja     800b17 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b0f:	0f be d2             	movsbl %dl,%edx
  800b12:	83 ea 57             	sub    $0x57,%edx
  800b15:	eb 10                	jmp    800b27 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b17:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b1a:	89 f3                	mov    %esi,%ebx
  800b1c:	80 fb 19             	cmp    $0x19,%bl
  800b1f:	77 16                	ja     800b37 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b21:	0f be d2             	movsbl %dl,%edx
  800b24:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b27:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b2a:	7d 0b                	jge    800b37 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b2c:	83 c1 01             	add    $0x1,%ecx
  800b2f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b33:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b35:	eb b9                	jmp    800af0 <strtol+0x76>

	if (endptr)
  800b37:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b3b:	74 0d                	je     800b4a <strtol+0xd0>
		*endptr = (char *) s;
  800b3d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b40:	89 0e                	mov    %ecx,(%esi)
  800b42:	eb 06                	jmp    800b4a <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b44:	85 db                	test   %ebx,%ebx
  800b46:	74 98                	je     800ae0 <strtol+0x66>
  800b48:	eb 9e                	jmp    800ae8 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b4a:	89 c2                	mov    %eax,%edx
  800b4c:	f7 da                	neg    %edx
  800b4e:	85 ff                	test   %edi,%edi
  800b50:	0f 45 c2             	cmovne %edx,%eax
}
  800b53:	5b                   	pop    %ebx
  800b54:	5e                   	pop    %esi
  800b55:	5f                   	pop    %edi
  800b56:	5d                   	pop    %ebp
  800b57:	c3                   	ret    

00800b58 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b58:	55                   	push   %ebp
  800b59:	89 e5                	mov    %esp,%ebp
  800b5b:	57                   	push   %edi
  800b5c:	56                   	push   %esi
  800b5d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b66:	8b 55 08             	mov    0x8(%ebp),%edx
  800b69:	89 c3                	mov    %eax,%ebx
  800b6b:	89 c7                	mov    %eax,%edi
  800b6d:	89 c6                	mov    %eax,%esi
  800b6f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b71:	5b                   	pop    %ebx
  800b72:	5e                   	pop    %esi
  800b73:	5f                   	pop    %edi
  800b74:	5d                   	pop    %ebp
  800b75:	c3                   	ret    

00800b76 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b76:	55                   	push   %ebp
  800b77:	89 e5                	mov    %esp,%ebp
  800b79:	57                   	push   %edi
  800b7a:	56                   	push   %esi
  800b7b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b81:	b8 01 00 00 00       	mov    $0x1,%eax
  800b86:	89 d1                	mov    %edx,%ecx
  800b88:	89 d3                	mov    %edx,%ebx
  800b8a:	89 d7                	mov    %edx,%edi
  800b8c:	89 d6                	mov    %edx,%esi
  800b8e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b90:	5b                   	pop    %ebx
  800b91:	5e                   	pop    %esi
  800b92:	5f                   	pop    %edi
  800b93:	5d                   	pop    %ebp
  800b94:	c3                   	ret    

00800b95 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b95:	55                   	push   %ebp
  800b96:	89 e5                	mov    %esp,%ebp
  800b98:	57                   	push   %edi
  800b99:	56                   	push   %esi
  800b9a:	53                   	push   %ebx
  800b9b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b9e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ba3:	b8 03 00 00 00       	mov    $0x3,%eax
  800ba8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bab:	89 cb                	mov    %ecx,%ebx
  800bad:	89 cf                	mov    %ecx,%edi
  800baf:	89 ce                	mov    %ecx,%esi
  800bb1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bb3:	85 c0                	test   %eax,%eax
  800bb5:	7e 17                	jle    800bce <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb7:	83 ec 0c             	sub    $0xc,%esp
  800bba:	50                   	push   %eax
  800bbb:	6a 03                	push   $0x3
  800bbd:	68 7f 2a 80 00       	push   $0x802a7f
  800bc2:	6a 23                	push   $0x23
  800bc4:	68 9c 2a 80 00       	push   $0x802a9c
  800bc9:	e8 6f 17 00 00       	call   80233d <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd1:	5b                   	pop    %ebx
  800bd2:	5e                   	pop    %esi
  800bd3:	5f                   	pop    %edi
  800bd4:	5d                   	pop    %ebp
  800bd5:	c3                   	ret    

00800bd6 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bd6:	55                   	push   %ebp
  800bd7:	89 e5                	mov    %esp,%ebp
  800bd9:	57                   	push   %edi
  800bda:	56                   	push   %esi
  800bdb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bdc:	ba 00 00 00 00       	mov    $0x0,%edx
  800be1:	b8 02 00 00 00       	mov    $0x2,%eax
  800be6:	89 d1                	mov    %edx,%ecx
  800be8:	89 d3                	mov    %edx,%ebx
  800bea:	89 d7                	mov    %edx,%edi
  800bec:	89 d6                	mov    %edx,%esi
  800bee:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bf0:	5b                   	pop    %ebx
  800bf1:	5e                   	pop    %esi
  800bf2:	5f                   	pop    %edi
  800bf3:	5d                   	pop    %ebp
  800bf4:	c3                   	ret    

00800bf5 <sys_yield>:

void
sys_yield(void)
{
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	57                   	push   %edi
  800bf9:	56                   	push   %esi
  800bfa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfb:	ba 00 00 00 00       	mov    $0x0,%edx
  800c00:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c05:	89 d1                	mov    %edx,%ecx
  800c07:	89 d3                	mov    %edx,%ebx
  800c09:	89 d7                	mov    %edx,%edi
  800c0b:	89 d6                	mov    %edx,%esi
  800c0d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c0f:	5b                   	pop    %ebx
  800c10:	5e                   	pop    %esi
  800c11:	5f                   	pop    %edi
  800c12:	5d                   	pop    %ebp
  800c13:	c3                   	ret    

00800c14 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c14:	55                   	push   %ebp
  800c15:	89 e5                	mov    %esp,%ebp
  800c17:	57                   	push   %edi
  800c18:	56                   	push   %esi
  800c19:	53                   	push   %ebx
  800c1a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1d:	be 00 00 00 00       	mov    $0x0,%esi
  800c22:	b8 04 00 00 00       	mov    $0x4,%eax
  800c27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c30:	89 f7                	mov    %esi,%edi
  800c32:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c34:	85 c0                	test   %eax,%eax
  800c36:	7e 17                	jle    800c4f <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c38:	83 ec 0c             	sub    $0xc,%esp
  800c3b:	50                   	push   %eax
  800c3c:	6a 04                	push   $0x4
  800c3e:	68 7f 2a 80 00       	push   $0x802a7f
  800c43:	6a 23                	push   $0x23
  800c45:	68 9c 2a 80 00       	push   $0x802a9c
  800c4a:	e8 ee 16 00 00       	call   80233d <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c52:	5b                   	pop    %ebx
  800c53:	5e                   	pop    %esi
  800c54:	5f                   	pop    %edi
  800c55:	5d                   	pop    %ebp
  800c56:	c3                   	ret    

00800c57 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c57:	55                   	push   %ebp
  800c58:	89 e5                	mov    %esp,%ebp
  800c5a:	57                   	push   %edi
  800c5b:	56                   	push   %esi
  800c5c:	53                   	push   %ebx
  800c5d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c60:	b8 05 00 00 00       	mov    $0x5,%eax
  800c65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c68:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c6e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c71:	8b 75 18             	mov    0x18(%ebp),%esi
  800c74:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c76:	85 c0                	test   %eax,%eax
  800c78:	7e 17                	jle    800c91 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7a:	83 ec 0c             	sub    $0xc,%esp
  800c7d:	50                   	push   %eax
  800c7e:	6a 05                	push   $0x5
  800c80:	68 7f 2a 80 00       	push   $0x802a7f
  800c85:	6a 23                	push   $0x23
  800c87:	68 9c 2a 80 00       	push   $0x802a9c
  800c8c:	e8 ac 16 00 00       	call   80233d <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c91:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c94:	5b                   	pop    %ebx
  800c95:	5e                   	pop    %esi
  800c96:	5f                   	pop    %edi
  800c97:	5d                   	pop    %ebp
  800c98:	c3                   	ret    

00800c99 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c99:	55                   	push   %ebp
  800c9a:	89 e5                	mov    %esp,%ebp
  800c9c:	57                   	push   %edi
  800c9d:	56                   	push   %esi
  800c9e:	53                   	push   %ebx
  800c9f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca7:	b8 06 00 00 00       	mov    $0x6,%eax
  800cac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800caf:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb2:	89 df                	mov    %ebx,%edi
  800cb4:	89 de                	mov    %ebx,%esi
  800cb6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cb8:	85 c0                	test   %eax,%eax
  800cba:	7e 17                	jle    800cd3 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbc:	83 ec 0c             	sub    $0xc,%esp
  800cbf:	50                   	push   %eax
  800cc0:	6a 06                	push   $0x6
  800cc2:	68 7f 2a 80 00       	push   $0x802a7f
  800cc7:	6a 23                	push   $0x23
  800cc9:	68 9c 2a 80 00       	push   $0x802a9c
  800cce:	e8 6a 16 00 00       	call   80233d <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cd3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd6:	5b                   	pop    %ebx
  800cd7:	5e                   	pop    %esi
  800cd8:	5f                   	pop    %edi
  800cd9:	5d                   	pop    %ebp
  800cda:	c3                   	ret    

00800cdb <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cdb:	55                   	push   %ebp
  800cdc:	89 e5                	mov    %esp,%ebp
  800cde:	57                   	push   %edi
  800cdf:	56                   	push   %esi
  800ce0:	53                   	push   %ebx
  800ce1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce9:	b8 08 00 00 00       	mov    $0x8,%eax
  800cee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf1:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf4:	89 df                	mov    %ebx,%edi
  800cf6:	89 de                	mov    %ebx,%esi
  800cf8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cfa:	85 c0                	test   %eax,%eax
  800cfc:	7e 17                	jle    800d15 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfe:	83 ec 0c             	sub    $0xc,%esp
  800d01:	50                   	push   %eax
  800d02:	6a 08                	push   $0x8
  800d04:	68 7f 2a 80 00       	push   $0x802a7f
  800d09:	6a 23                	push   $0x23
  800d0b:	68 9c 2a 80 00       	push   $0x802a9c
  800d10:	e8 28 16 00 00       	call   80233d <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d15:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d18:	5b                   	pop    %ebx
  800d19:	5e                   	pop    %esi
  800d1a:	5f                   	pop    %edi
  800d1b:	5d                   	pop    %ebp
  800d1c:	c3                   	ret    

00800d1d <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d1d:	55                   	push   %ebp
  800d1e:	89 e5                	mov    %esp,%ebp
  800d20:	57                   	push   %edi
  800d21:	56                   	push   %esi
  800d22:	53                   	push   %ebx
  800d23:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d26:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d2b:	b8 09 00 00 00       	mov    $0x9,%eax
  800d30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d33:	8b 55 08             	mov    0x8(%ebp),%edx
  800d36:	89 df                	mov    %ebx,%edi
  800d38:	89 de                	mov    %ebx,%esi
  800d3a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d3c:	85 c0                	test   %eax,%eax
  800d3e:	7e 17                	jle    800d57 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d40:	83 ec 0c             	sub    $0xc,%esp
  800d43:	50                   	push   %eax
  800d44:	6a 09                	push   $0x9
  800d46:	68 7f 2a 80 00       	push   $0x802a7f
  800d4b:	6a 23                	push   $0x23
  800d4d:	68 9c 2a 80 00       	push   $0x802a9c
  800d52:	e8 e6 15 00 00       	call   80233d <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d57:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d5a:	5b                   	pop    %ebx
  800d5b:	5e                   	pop    %esi
  800d5c:	5f                   	pop    %edi
  800d5d:	5d                   	pop    %ebp
  800d5e:	c3                   	ret    

00800d5f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d5f:	55                   	push   %ebp
  800d60:	89 e5                	mov    %esp,%ebp
  800d62:	57                   	push   %edi
  800d63:	56                   	push   %esi
  800d64:	53                   	push   %ebx
  800d65:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d68:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d6d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d75:	8b 55 08             	mov    0x8(%ebp),%edx
  800d78:	89 df                	mov    %ebx,%edi
  800d7a:	89 de                	mov    %ebx,%esi
  800d7c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d7e:	85 c0                	test   %eax,%eax
  800d80:	7e 17                	jle    800d99 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d82:	83 ec 0c             	sub    $0xc,%esp
  800d85:	50                   	push   %eax
  800d86:	6a 0a                	push   $0xa
  800d88:	68 7f 2a 80 00       	push   $0x802a7f
  800d8d:	6a 23                	push   $0x23
  800d8f:	68 9c 2a 80 00       	push   $0x802a9c
  800d94:	e8 a4 15 00 00       	call   80233d <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d9c:	5b                   	pop    %ebx
  800d9d:	5e                   	pop    %esi
  800d9e:	5f                   	pop    %edi
  800d9f:	5d                   	pop    %ebp
  800da0:	c3                   	ret    

00800da1 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800da1:	55                   	push   %ebp
  800da2:	89 e5                	mov    %esp,%ebp
  800da4:	57                   	push   %edi
  800da5:	56                   	push   %esi
  800da6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da7:	be 00 00 00 00       	mov    $0x0,%esi
  800dac:	b8 0c 00 00 00       	mov    $0xc,%eax
  800db1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db4:	8b 55 08             	mov    0x8(%ebp),%edx
  800db7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dba:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dbd:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dbf:	5b                   	pop    %ebx
  800dc0:	5e                   	pop    %esi
  800dc1:	5f                   	pop    %edi
  800dc2:	5d                   	pop    %ebp
  800dc3:	c3                   	ret    

00800dc4 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dc4:	55                   	push   %ebp
  800dc5:	89 e5                	mov    %esp,%ebp
  800dc7:	57                   	push   %edi
  800dc8:	56                   	push   %esi
  800dc9:	53                   	push   %ebx
  800dca:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dcd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dd2:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800dda:	89 cb                	mov    %ecx,%ebx
  800ddc:	89 cf                	mov    %ecx,%edi
  800dde:	89 ce                	mov    %ecx,%esi
  800de0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800de2:	85 c0                	test   %eax,%eax
  800de4:	7e 17                	jle    800dfd <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de6:	83 ec 0c             	sub    $0xc,%esp
  800de9:	50                   	push   %eax
  800dea:	6a 0d                	push   $0xd
  800dec:	68 7f 2a 80 00       	push   $0x802a7f
  800df1:	6a 23                	push   $0x23
  800df3:	68 9c 2a 80 00       	push   $0x802a9c
  800df8:	e8 40 15 00 00       	call   80233d <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dfd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e00:	5b                   	pop    %ebx
  800e01:	5e                   	pop    %esi
  800e02:	5f                   	pop    %edi
  800e03:	5d                   	pop    %ebp
  800e04:	c3                   	ret    

00800e05 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e05:	55                   	push   %ebp
  800e06:	89 e5                	mov    %esp,%ebp
  800e08:	57                   	push   %edi
  800e09:	56                   	push   %esi
  800e0a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0b:	ba 00 00 00 00       	mov    $0x0,%edx
  800e10:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e15:	89 d1                	mov    %edx,%ecx
  800e17:	89 d3                	mov    %edx,%ebx
  800e19:	89 d7                	mov    %edx,%edi
  800e1b:	89 d6                	mov    %edx,%esi
  800e1d:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e1f:	5b                   	pop    %ebx
  800e20:	5e                   	pop    %esi
  800e21:	5f                   	pop    %edi
  800e22:	5d                   	pop    %ebp
  800e23:	c3                   	ret    

00800e24 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800e24:	55                   	push   %ebp
  800e25:	89 e5                	mov    %esp,%ebp
  800e27:	53                   	push   %ebx
  800e28:	83 ec 04             	sub    $0x4,%esp
	int r;
	void * address = (void *)(pn*PGSIZE);
  800e2b:	89 d3                	mov    %edx,%ebx
  800e2d:	c1 e3 0c             	shl    $0xc,%ebx
	
	if((uvpt[pn] & PTE_SHARE))
  800e30:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800e37:	f6 c5 04             	test   $0x4,%ch
  800e3a:	74 38                	je     800e74 <duppage+0x50>
	{
		if ((r = sys_page_map(0, address, envid, address, (uvpt[pn] | PTE_SYSCALL))) < 0)
  800e3c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e43:	83 ec 0c             	sub    $0xc,%esp
  800e46:	81 ca 07 0e 00 00    	or     $0xe07,%edx
  800e4c:	52                   	push   %edx
  800e4d:	53                   	push   %ebx
  800e4e:	50                   	push   %eax
  800e4f:	53                   	push   %ebx
  800e50:	6a 00                	push   $0x0
  800e52:	e8 00 fe ff ff       	call   800c57 <sys_page_map>
  800e57:	83 c4 20             	add    $0x20,%esp
  800e5a:	85 c0                	test   %eax,%eax
  800e5c:	0f 89 b8 00 00 00    	jns    800f1a <duppage+0xf6>
			panic("sys_page_map: %e", r);
  800e62:	50                   	push   %eax
  800e63:	68 aa 2a 80 00       	push   $0x802aaa
  800e68:	6a 4e                	push   $0x4e
  800e6a:	68 bb 2a 80 00       	push   $0x802abb
  800e6f:	e8 c9 14 00 00       	call   80233d <_panic>
	}
	else if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW))
  800e74:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800e7b:	f6 c1 02             	test   $0x2,%cl
  800e7e:	75 0c                	jne    800e8c <duppage+0x68>
  800e80:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800e87:	f6 c5 08             	test   $0x8,%ch
  800e8a:	74 57                	je     800ee3 <duppage+0xbf>
	{
		int perm = 0;
		perm |= PTE_P|PTE_U|PTE_COW;
	
		if ((r = sys_page_map(0, address, envid, address, perm)) < 0)
  800e8c:	83 ec 0c             	sub    $0xc,%esp
  800e8f:	68 05 08 00 00       	push   $0x805
  800e94:	53                   	push   %ebx
  800e95:	50                   	push   %eax
  800e96:	53                   	push   %ebx
  800e97:	6a 00                	push   $0x0
  800e99:	e8 b9 fd ff ff       	call   800c57 <sys_page_map>
  800e9e:	83 c4 20             	add    $0x20,%esp
  800ea1:	85 c0                	test   %eax,%eax
  800ea3:	79 12                	jns    800eb7 <duppage+0x93>
			panic("sys_page_map: %e", r);
  800ea5:	50                   	push   %eax
  800ea6:	68 aa 2a 80 00       	push   $0x802aaa
  800eab:	6a 56                	push   $0x56
  800ead:	68 bb 2a 80 00       	push   $0x802abb
  800eb2:	e8 86 14 00 00       	call   80233d <_panic>
		if ((r = sys_page_map(0, address, 0, address, perm)) < 0)
  800eb7:	83 ec 0c             	sub    $0xc,%esp
  800eba:	68 05 08 00 00       	push   $0x805
  800ebf:	53                   	push   %ebx
  800ec0:	6a 00                	push   $0x0
  800ec2:	53                   	push   %ebx
  800ec3:	6a 00                	push   $0x0
  800ec5:	e8 8d fd ff ff       	call   800c57 <sys_page_map>
  800eca:	83 c4 20             	add    $0x20,%esp
  800ecd:	85 c0                	test   %eax,%eax
  800ecf:	79 49                	jns    800f1a <duppage+0xf6>
			panic("sys_page_map: %e", r);
  800ed1:	50                   	push   %eax
  800ed2:	68 aa 2a 80 00       	push   $0x802aaa
  800ed7:	6a 58                	push   $0x58
  800ed9:	68 bb 2a 80 00       	push   $0x802abb
  800ede:	e8 5a 14 00 00       	call   80233d <_panic>
	}
	else if((uvpt[pn] & ~PTE_U) == 0)
  800ee3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800eea:	f7 c2 fb ff ff ff    	test   $0xfffffffb,%edx
  800ef0:	75 28                	jne    800f1a <duppage+0xf6>
	{
		//cprintf("im here");
		if ((r = sys_page_map(0, address, envid, address, PTE_P|PTE_U)) < 0)
  800ef2:	83 ec 0c             	sub    $0xc,%esp
  800ef5:	6a 05                	push   $0x5
  800ef7:	53                   	push   %ebx
  800ef8:	50                   	push   %eax
  800ef9:	53                   	push   %ebx
  800efa:	6a 00                	push   $0x0
  800efc:	e8 56 fd ff ff       	call   800c57 <sys_page_map>
  800f01:	83 c4 20             	add    $0x20,%esp
  800f04:	85 c0                	test   %eax,%eax
  800f06:	79 12                	jns    800f1a <duppage+0xf6>
			panic("sys_page_map: %e", r);	
  800f08:	50                   	push   %eax
  800f09:	68 aa 2a 80 00       	push   $0x802aaa
  800f0e:	6a 5e                	push   $0x5e
  800f10:	68 bb 2a 80 00       	push   $0x802abb
  800f15:	e8 23 14 00 00       	call   80233d <_panic>
	}
	return 0;
}
  800f1a:	b8 00 00 00 00       	mov    $0x0,%eax
  800f1f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f22:	c9                   	leave  
  800f23:	c3                   	ret    

00800f24 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f24:	55                   	push   %ebp
  800f25:	89 e5                	mov    %esp,%ebp
  800f27:	53                   	push   %ebx
  800f28:	83 ec 08             	sub    $0x8,%esp
	void *addr = (void *) utf->utf_fault_va;
  800f2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f2e:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	unsigned pn = ((uint32_t)addr)/PGSIZE;
  800f30:	89 d8                	mov    %ebx,%eax
  800f32:	c1 e8 0c             	shr    $0xc,%eax
	pte_t pte = uvpt[pn];
  800f35:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// Allocate a new page, mapped at temp location
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  800f3c:	6a 07                	push   $0x7
  800f3e:	68 00 f0 7f 00       	push   $0x7ff000
  800f43:	6a 00                	push   $0x0
  800f45:	e8 ca fc ff ff       	call   800c14 <sys_page_alloc>
  800f4a:	83 c4 10             	add    $0x10,%esp
  800f4d:	85 c0                	test   %eax,%eax
  800f4f:	79 12                	jns    800f63 <pgfault+0x3f>
		panic("sys_page_alloc: %e", r);
  800f51:	50                   	push   %eax
  800f52:	68 c6 2a 80 00       	push   $0x802ac6
  800f57:	6a 2b                	push   $0x2b
  800f59:	68 bb 2a 80 00       	push   $0x802abb
  800f5e:	e8 da 13 00 00       	call   80233d <_panic>

	// Copy the data from the old page to this new page
	void *addr_pgstart = (void *) ROUNDDOWN(addr, PGSIZE);
  800f63:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr_pgstart, PGSIZE);
  800f69:	83 ec 04             	sub    $0x4,%esp
  800f6c:	68 00 10 00 00       	push   $0x1000
  800f71:	53                   	push   %ebx
  800f72:	68 00 f0 7f 00       	push   $0x7ff000
  800f77:	e8 27 fa ff ff       	call   8009a3 <memmove>

	// Move the new page to the old page's address
	if ((r = sys_page_map(0, PFTEMP, 0, addr_pgstart, PTE_P|PTE_U|PTE_W)) < 0)
  800f7c:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f83:	53                   	push   %ebx
  800f84:	6a 00                	push   $0x0
  800f86:	68 00 f0 7f 00       	push   $0x7ff000
  800f8b:	6a 00                	push   $0x0
  800f8d:	e8 c5 fc ff ff       	call   800c57 <sys_page_map>
  800f92:	83 c4 20             	add    $0x20,%esp
  800f95:	85 c0                	test   %eax,%eax
  800f97:	79 12                	jns    800fab <pgfault+0x87>
		panic("sys_page_map: %e", r);
  800f99:	50                   	push   %eax
  800f9a:	68 aa 2a 80 00       	push   $0x802aaa
  800f9f:	6a 33                	push   $0x33
  800fa1:	68 bb 2a 80 00       	push   $0x802abb
  800fa6:	e8 92 13 00 00       	call   80233d <_panic>

	// Unmap the temp location
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800fab:	83 ec 08             	sub    $0x8,%esp
  800fae:	68 00 f0 7f 00       	push   $0x7ff000
  800fb3:	6a 00                	push   $0x0
  800fb5:	e8 df fc ff ff       	call   800c99 <sys_page_unmap>
  800fba:	83 c4 10             	add    $0x10,%esp
  800fbd:	85 c0                	test   %eax,%eax
  800fbf:	79 12                	jns    800fd3 <pgfault+0xaf>
		panic("sys_page_unmap: %e", r);
  800fc1:	50                   	push   %eax
  800fc2:	68 d9 2a 80 00       	push   $0x802ad9
  800fc7:	6a 37                	push   $0x37
  800fc9:	68 bb 2a 80 00       	push   $0x802abb
  800fce:	e8 6a 13 00 00       	call   80233d <_panic>
}
  800fd3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fd6:	c9                   	leave  
  800fd7:	c3                   	ret    

00800fd8 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fd8:	55                   	push   %ebp
  800fd9:	89 e5                	mov    %esp,%ebp
  800fdb:	56                   	push   %esi
  800fdc:	53                   	push   %ebx
  800fdd:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
	// Set up page fault handler
	set_pgfault_handler(&pgfault);
  800fe0:	68 24 0f 80 00       	push   $0x800f24
  800fe5:	e8 99 13 00 00       	call   802383 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800fea:	b8 07 00 00 00       	mov    $0x7,%eax
  800fef:	cd 30                	int    $0x30

	// Create child
	envid_t envid = sys_exofork();
  800ff1:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (envid < 0) {
  800ff4:	83 c4 10             	add    $0x10,%esp
  800ff7:	85 c0                	test   %eax,%eax
  800ff9:	79 12                	jns    80100d <fork+0x35>
		panic("sys_exofork: %e", envid);
  800ffb:	50                   	push   %eax
  800ffc:	68 ec 2a 80 00       	push   $0x802aec
  801001:	6a 7c                	push   $0x7c
  801003:	68 bb 2a 80 00       	push   $0x802abb
  801008:	e8 30 13 00 00       	call   80233d <_panic>
		return envid;
	}
	if (envid == 0) {
  80100d:	85 c0                	test   %eax,%eax
  80100f:	75 1e                	jne    80102f <fork+0x57>
		// We are the child.
		thisenv = &envs[ENVX(sys_getenvid())]; // Fix thisenv
  801011:	e8 c0 fb ff ff       	call   800bd6 <sys_getenvid>
  801016:	25 ff 03 00 00       	and    $0x3ff,%eax
  80101b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80101e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801023:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  801028:	b8 00 00 00 00       	mov    $0x0,%eax
  80102d:	eb 7d                	jmp    8010ac <fork+0xd4>

	// Set page fault handler on the child.
	// The parent needs to do it, else the child wouldn't be able to handle
	// the fault when trying to access it's stack (which happens as soon it starts)
	extern void _pgfault_upcall(void);
	sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);
  80102f:	83 ec 04             	sub    $0x4,%esp
  801032:	6a 07                	push   $0x7
  801034:	68 00 f0 bf ee       	push   $0xeebff000
  801039:	50                   	push   %eax
  80103a:	e8 d5 fb ff ff       	call   800c14 <sys_page_alloc>
	sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  80103f:	83 c4 08             	add    $0x8,%esp
  801042:	68 c8 23 80 00       	push   $0x8023c8
  801047:	ff 75 f4             	pushl  -0xc(%ebp)
  80104a:	e8 10 fd ff ff       	call   800d5f <sys_env_set_pgfault_upcall>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  80104f:	be 04 70 80 00       	mov    $0x807004,%esi
  801054:	c1 ee 0c             	shr    $0xc,%esi
  801057:	83 c4 10             	add    $0x10,%esp
  80105a:	bb 00 08 00 00       	mov    $0x800,%ebx
  80105f:	eb 0d                	jmp    80106e <fork+0x96>
		duppage(envid, pn);
  801061:	89 da                	mov    %ebx,%edx
  801063:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801066:	e8 b9 fd ff ff       	call   800e24 <duppage>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  80106b:	83 c3 01             	add    $0x1,%ebx
  80106e:	39 f3                	cmp    %esi,%ebx
  801070:	76 ef                	jbe    801061 <fork+0x89>
	}

	// Also copy the stack we are currently running on
	// I think it should loop from ustacktop to this page, since the stack
	// can have more than 1 page
	duppage(envid, ((uint32_t) &envid)/PGSIZE);
  801072:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801075:	c1 ea 0c             	shr    $0xc,%edx
  801078:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80107b:	e8 a4 fd ff ff       	call   800e24 <duppage>

	// Start the child environmnet running
	int r;
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  801080:	83 ec 08             	sub    $0x8,%esp
  801083:	6a 02                	push   $0x2
  801085:	ff 75 f4             	pushl  -0xc(%ebp)
  801088:	e8 4e fc ff ff       	call   800cdb <sys_env_set_status>
  80108d:	83 c4 10             	add    $0x10,%esp
  801090:	85 c0                	test   %eax,%eax
  801092:	79 15                	jns    8010a9 <fork+0xd1>
		panic("sys_env_set_status: %e", r);
  801094:	50                   	push   %eax
  801095:	68 fc 2a 80 00       	push   $0x802afc
  80109a:	68 9c 00 00 00       	push   $0x9c
  80109f:	68 bb 2a 80 00       	push   $0x802abb
  8010a4:	e8 94 12 00 00       	call   80233d <_panic>
		return r;
	}

	return envid;
  8010a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8010ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010af:	5b                   	pop    %ebx
  8010b0:	5e                   	pop    %esi
  8010b1:	5d                   	pop    %ebp
  8010b2:	c3                   	ret    

008010b3 <sfork>:

// Challenge!
int
sfork(void)
{
  8010b3:	55                   	push   %ebp
  8010b4:	89 e5                	mov    %esp,%ebp
  8010b6:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010b9:	68 13 2b 80 00       	push   $0x802b13
  8010be:	68 a7 00 00 00       	push   $0xa7
  8010c3:	68 bb 2a 80 00       	push   $0x802abb
  8010c8:	e8 70 12 00 00       	call   80233d <_panic>

008010cd <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8010cd:	55                   	push   %ebp
  8010ce:	89 e5                	mov    %esp,%ebp
  8010d0:	56                   	push   %esi
  8010d1:	53                   	push   %ebx
  8010d2:	8b 75 08             	mov    0x8(%ebp),%esi
  8010d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010d8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  8010db:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  8010dd:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  8010e2:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  8010e5:	83 ec 0c             	sub    $0xc,%esp
  8010e8:	50                   	push   %eax
  8010e9:	e8 d6 fc ff ff       	call   800dc4 <sys_ipc_recv>

	if (r < 0) {
  8010ee:	83 c4 10             	add    $0x10,%esp
  8010f1:	85 c0                	test   %eax,%eax
  8010f3:	79 16                	jns    80110b <ipc_recv+0x3e>
		if (from_env_store)
  8010f5:	85 f6                	test   %esi,%esi
  8010f7:	74 06                	je     8010ff <ipc_recv+0x32>
			*from_env_store = 0;
  8010f9:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  8010ff:	85 db                	test   %ebx,%ebx
  801101:	74 2c                	je     80112f <ipc_recv+0x62>
			*perm_store = 0;
  801103:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801109:	eb 24                	jmp    80112f <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  80110b:	85 f6                	test   %esi,%esi
  80110d:	74 0a                	je     801119 <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  80110f:	a1 08 40 80 00       	mov    0x804008,%eax
  801114:	8b 40 74             	mov    0x74(%eax),%eax
  801117:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  801119:	85 db                	test   %ebx,%ebx
  80111b:	74 0a                	je     801127 <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  80111d:	a1 08 40 80 00       	mov    0x804008,%eax
  801122:	8b 40 78             	mov    0x78(%eax),%eax
  801125:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  801127:	a1 08 40 80 00       	mov    0x804008,%eax
  80112c:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  80112f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801132:	5b                   	pop    %ebx
  801133:	5e                   	pop    %esi
  801134:	5d                   	pop    %ebp
  801135:	c3                   	ret    

00801136 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801136:	55                   	push   %ebp
  801137:	89 e5                	mov    %esp,%ebp
  801139:	57                   	push   %edi
  80113a:	56                   	push   %esi
  80113b:	53                   	push   %ebx
  80113c:	83 ec 0c             	sub    $0xc,%esp
  80113f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801142:	8b 75 0c             	mov    0xc(%ebp),%esi
  801145:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  801148:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  80114a:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  80114f:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  801152:	ff 75 14             	pushl  0x14(%ebp)
  801155:	53                   	push   %ebx
  801156:	56                   	push   %esi
  801157:	57                   	push   %edi
  801158:	e8 44 fc ff ff       	call   800da1 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  80115d:	83 c4 10             	add    $0x10,%esp
  801160:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801163:	75 07                	jne    80116c <ipc_send+0x36>
			sys_yield();
  801165:	e8 8b fa ff ff       	call   800bf5 <sys_yield>
  80116a:	eb e6                	jmp    801152 <ipc_send+0x1c>
		} else if (r < 0) {
  80116c:	85 c0                	test   %eax,%eax
  80116e:	79 12                	jns    801182 <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  801170:	50                   	push   %eax
  801171:	68 29 2b 80 00       	push   $0x802b29
  801176:	6a 51                	push   $0x51
  801178:	68 36 2b 80 00       	push   $0x802b36
  80117d:	e8 bb 11 00 00       	call   80233d <_panic>
		}
	}
}
  801182:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801185:	5b                   	pop    %ebx
  801186:	5e                   	pop    %esi
  801187:	5f                   	pop    %edi
  801188:	5d                   	pop    %ebp
  801189:	c3                   	ret    

0080118a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80118a:	55                   	push   %ebp
  80118b:	89 e5                	mov    %esp,%ebp
  80118d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801190:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801195:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801198:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80119e:	8b 52 50             	mov    0x50(%edx),%edx
  8011a1:	39 ca                	cmp    %ecx,%edx
  8011a3:	75 0d                	jne    8011b2 <ipc_find_env+0x28>
			return envs[i].env_id;
  8011a5:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8011a8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011ad:	8b 40 48             	mov    0x48(%eax),%eax
  8011b0:	eb 0f                	jmp    8011c1 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8011b2:	83 c0 01             	add    $0x1,%eax
  8011b5:	3d 00 04 00 00       	cmp    $0x400,%eax
  8011ba:	75 d9                	jne    801195 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8011bc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011c1:	5d                   	pop    %ebp
  8011c2:	c3                   	ret    

008011c3 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011c3:	55                   	push   %ebp
  8011c4:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c9:	05 00 00 00 30       	add    $0x30000000,%eax
  8011ce:	c1 e8 0c             	shr    $0xc,%eax
}
  8011d1:	5d                   	pop    %ebp
  8011d2:	c3                   	ret    

008011d3 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011d3:	55                   	push   %ebp
  8011d4:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8011d9:	05 00 00 00 30       	add    $0x30000000,%eax
  8011de:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011e3:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011e8:	5d                   	pop    %ebp
  8011e9:	c3                   	ret    

008011ea <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011ea:	55                   	push   %ebp
  8011eb:	89 e5                	mov    %esp,%ebp
  8011ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011f0:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011f5:	89 c2                	mov    %eax,%edx
  8011f7:	c1 ea 16             	shr    $0x16,%edx
  8011fa:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801201:	f6 c2 01             	test   $0x1,%dl
  801204:	74 11                	je     801217 <fd_alloc+0x2d>
  801206:	89 c2                	mov    %eax,%edx
  801208:	c1 ea 0c             	shr    $0xc,%edx
  80120b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801212:	f6 c2 01             	test   $0x1,%dl
  801215:	75 09                	jne    801220 <fd_alloc+0x36>
			*fd_store = fd;
  801217:	89 01                	mov    %eax,(%ecx)
			return 0;
  801219:	b8 00 00 00 00       	mov    $0x0,%eax
  80121e:	eb 17                	jmp    801237 <fd_alloc+0x4d>
  801220:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801225:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80122a:	75 c9                	jne    8011f5 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80122c:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801232:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801237:	5d                   	pop    %ebp
  801238:	c3                   	ret    

00801239 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801239:	55                   	push   %ebp
  80123a:	89 e5                	mov    %esp,%ebp
  80123c:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80123f:	83 f8 1f             	cmp    $0x1f,%eax
  801242:	77 36                	ja     80127a <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801244:	c1 e0 0c             	shl    $0xc,%eax
  801247:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80124c:	89 c2                	mov    %eax,%edx
  80124e:	c1 ea 16             	shr    $0x16,%edx
  801251:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801258:	f6 c2 01             	test   $0x1,%dl
  80125b:	74 24                	je     801281 <fd_lookup+0x48>
  80125d:	89 c2                	mov    %eax,%edx
  80125f:	c1 ea 0c             	shr    $0xc,%edx
  801262:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801269:	f6 c2 01             	test   $0x1,%dl
  80126c:	74 1a                	je     801288 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80126e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801271:	89 02                	mov    %eax,(%edx)
	return 0;
  801273:	b8 00 00 00 00       	mov    $0x0,%eax
  801278:	eb 13                	jmp    80128d <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80127a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80127f:	eb 0c                	jmp    80128d <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801281:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801286:	eb 05                	jmp    80128d <fd_lookup+0x54>
  801288:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80128d:	5d                   	pop    %ebp
  80128e:	c3                   	ret    

0080128f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80128f:	55                   	push   %ebp
  801290:	89 e5                	mov    %esp,%ebp
  801292:	83 ec 08             	sub    $0x8,%esp
  801295:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801298:	ba bc 2b 80 00       	mov    $0x802bbc,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80129d:	eb 13                	jmp    8012b2 <dev_lookup+0x23>
  80129f:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8012a2:	39 08                	cmp    %ecx,(%eax)
  8012a4:	75 0c                	jne    8012b2 <dev_lookup+0x23>
			*dev = devtab[i];
  8012a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012a9:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8012b0:	eb 2e                	jmp    8012e0 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012b2:	8b 02                	mov    (%edx),%eax
  8012b4:	85 c0                	test   %eax,%eax
  8012b6:	75 e7                	jne    80129f <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012b8:	a1 08 40 80 00       	mov    0x804008,%eax
  8012bd:	8b 40 48             	mov    0x48(%eax),%eax
  8012c0:	83 ec 04             	sub    $0x4,%esp
  8012c3:	51                   	push   %ecx
  8012c4:	50                   	push   %eax
  8012c5:	68 40 2b 80 00       	push   $0x802b40
  8012ca:	e8 bd ef ff ff       	call   80028c <cprintf>
	*dev = 0;
  8012cf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012d2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012d8:	83 c4 10             	add    $0x10,%esp
  8012db:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012e0:	c9                   	leave  
  8012e1:	c3                   	ret    

008012e2 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012e2:	55                   	push   %ebp
  8012e3:	89 e5                	mov    %esp,%ebp
  8012e5:	56                   	push   %esi
  8012e6:	53                   	push   %ebx
  8012e7:	83 ec 10             	sub    $0x10,%esp
  8012ea:	8b 75 08             	mov    0x8(%ebp),%esi
  8012ed:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f3:	50                   	push   %eax
  8012f4:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012fa:	c1 e8 0c             	shr    $0xc,%eax
  8012fd:	50                   	push   %eax
  8012fe:	e8 36 ff ff ff       	call   801239 <fd_lookup>
  801303:	83 c4 08             	add    $0x8,%esp
  801306:	85 c0                	test   %eax,%eax
  801308:	78 05                	js     80130f <fd_close+0x2d>
	    || fd != fd2)
  80130a:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80130d:	74 0c                	je     80131b <fd_close+0x39>
		return (must_exist ? r : 0);
  80130f:	84 db                	test   %bl,%bl
  801311:	ba 00 00 00 00       	mov    $0x0,%edx
  801316:	0f 44 c2             	cmove  %edx,%eax
  801319:	eb 41                	jmp    80135c <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80131b:	83 ec 08             	sub    $0x8,%esp
  80131e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801321:	50                   	push   %eax
  801322:	ff 36                	pushl  (%esi)
  801324:	e8 66 ff ff ff       	call   80128f <dev_lookup>
  801329:	89 c3                	mov    %eax,%ebx
  80132b:	83 c4 10             	add    $0x10,%esp
  80132e:	85 c0                	test   %eax,%eax
  801330:	78 1a                	js     80134c <fd_close+0x6a>
		if (dev->dev_close)
  801332:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801335:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801338:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80133d:	85 c0                	test   %eax,%eax
  80133f:	74 0b                	je     80134c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801341:	83 ec 0c             	sub    $0xc,%esp
  801344:	56                   	push   %esi
  801345:	ff d0                	call   *%eax
  801347:	89 c3                	mov    %eax,%ebx
  801349:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80134c:	83 ec 08             	sub    $0x8,%esp
  80134f:	56                   	push   %esi
  801350:	6a 00                	push   $0x0
  801352:	e8 42 f9 ff ff       	call   800c99 <sys_page_unmap>
	return r;
  801357:	83 c4 10             	add    $0x10,%esp
  80135a:	89 d8                	mov    %ebx,%eax
}
  80135c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80135f:	5b                   	pop    %ebx
  801360:	5e                   	pop    %esi
  801361:	5d                   	pop    %ebp
  801362:	c3                   	ret    

00801363 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801363:	55                   	push   %ebp
  801364:	89 e5                	mov    %esp,%ebp
  801366:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801369:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80136c:	50                   	push   %eax
  80136d:	ff 75 08             	pushl  0x8(%ebp)
  801370:	e8 c4 fe ff ff       	call   801239 <fd_lookup>
  801375:	83 c4 08             	add    $0x8,%esp
  801378:	85 c0                	test   %eax,%eax
  80137a:	78 10                	js     80138c <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80137c:	83 ec 08             	sub    $0x8,%esp
  80137f:	6a 01                	push   $0x1
  801381:	ff 75 f4             	pushl  -0xc(%ebp)
  801384:	e8 59 ff ff ff       	call   8012e2 <fd_close>
  801389:	83 c4 10             	add    $0x10,%esp
}
  80138c:	c9                   	leave  
  80138d:	c3                   	ret    

0080138e <close_all>:

void
close_all(void)
{
  80138e:	55                   	push   %ebp
  80138f:	89 e5                	mov    %esp,%ebp
  801391:	53                   	push   %ebx
  801392:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801395:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80139a:	83 ec 0c             	sub    $0xc,%esp
  80139d:	53                   	push   %ebx
  80139e:	e8 c0 ff ff ff       	call   801363 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013a3:	83 c3 01             	add    $0x1,%ebx
  8013a6:	83 c4 10             	add    $0x10,%esp
  8013a9:	83 fb 20             	cmp    $0x20,%ebx
  8013ac:	75 ec                	jne    80139a <close_all+0xc>
		close(i);
}
  8013ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013b1:	c9                   	leave  
  8013b2:	c3                   	ret    

008013b3 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013b3:	55                   	push   %ebp
  8013b4:	89 e5                	mov    %esp,%ebp
  8013b6:	57                   	push   %edi
  8013b7:	56                   	push   %esi
  8013b8:	53                   	push   %ebx
  8013b9:	83 ec 2c             	sub    $0x2c,%esp
  8013bc:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013bf:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013c2:	50                   	push   %eax
  8013c3:	ff 75 08             	pushl  0x8(%ebp)
  8013c6:	e8 6e fe ff ff       	call   801239 <fd_lookup>
  8013cb:	83 c4 08             	add    $0x8,%esp
  8013ce:	85 c0                	test   %eax,%eax
  8013d0:	0f 88 c1 00 00 00    	js     801497 <dup+0xe4>
		return r;
	close(newfdnum);
  8013d6:	83 ec 0c             	sub    $0xc,%esp
  8013d9:	56                   	push   %esi
  8013da:	e8 84 ff ff ff       	call   801363 <close>

	newfd = INDEX2FD(newfdnum);
  8013df:	89 f3                	mov    %esi,%ebx
  8013e1:	c1 e3 0c             	shl    $0xc,%ebx
  8013e4:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013ea:	83 c4 04             	add    $0x4,%esp
  8013ed:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013f0:	e8 de fd ff ff       	call   8011d3 <fd2data>
  8013f5:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013f7:	89 1c 24             	mov    %ebx,(%esp)
  8013fa:	e8 d4 fd ff ff       	call   8011d3 <fd2data>
  8013ff:	83 c4 10             	add    $0x10,%esp
  801402:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801405:	89 f8                	mov    %edi,%eax
  801407:	c1 e8 16             	shr    $0x16,%eax
  80140a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801411:	a8 01                	test   $0x1,%al
  801413:	74 37                	je     80144c <dup+0x99>
  801415:	89 f8                	mov    %edi,%eax
  801417:	c1 e8 0c             	shr    $0xc,%eax
  80141a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801421:	f6 c2 01             	test   $0x1,%dl
  801424:	74 26                	je     80144c <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801426:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80142d:	83 ec 0c             	sub    $0xc,%esp
  801430:	25 07 0e 00 00       	and    $0xe07,%eax
  801435:	50                   	push   %eax
  801436:	ff 75 d4             	pushl  -0x2c(%ebp)
  801439:	6a 00                	push   $0x0
  80143b:	57                   	push   %edi
  80143c:	6a 00                	push   $0x0
  80143e:	e8 14 f8 ff ff       	call   800c57 <sys_page_map>
  801443:	89 c7                	mov    %eax,%edi
  801445:	83 c4 20             	add    $0x20,%esp
  801448:	85 c0                	test   %eax,%eax
  80144a:	78 2e                	js     80147a <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80144c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80144f:	89 d0                	mov    %edx,%eax
  801451:	c1 e8 0c             	shr    $0xc,%eax
  801454:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80145b:	83 ec 0c             	sub    $0xc,%esp
  80145e:	25 07 0e 00 00       	and    $0xe07,%eax
  801463:	50                   	push   %eax
  801464:	53                   	push   %ebx
  801465:	6a 00                	push   $0x0
  801467:	52                   	push   %edx
  801468:	6a 00                	push   $0x0
  80146a:	e8 e8 f7 ff ff       	call   800c57 <sys_page_map>
  80146f:	89 c7                	mov    %eax,%edi
  801471:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801474:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801476:	85 ff                	test   %edi,%edi
  801478:	79 1d                	jns    801497 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80147a:	83 ec 08             	sub    $0x8,%esp
  80147d:	53                   	push   %ebx
  80147e:	6a 00                	push   $0x0
  801480:	e8 14 f8 ff ff       	call   800c99 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801485:	83 c4 08             	add    $0x8,%esp
  801488:	ff 75 d4             	pushl  -0x2c(%ebp)
  80148b:	6a 00                	push   $0x0
  80148d:	e8 07 f8 ff ff       	call   800c99 <sys_page_unmap>
	return r;
  801492:	83 c4 10             	add    $0x10,%esp
  801495:	89 f8                	mov    %edi,%eax
}
  801497:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80149a:	5b                   	pop    %ebx
  80149b:	5e                   	pop    %esi
  80149c:	5f                   	pop    %edi
  80149d:	5d                   	pop    %ebp
  80149e:	c3                   	ret    

0080149f <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80149f:	55                   	push   %ebp
  8014a0:	89 e5                	mov    %esp,%ebp
  8014a2:	53                   	push   %ebx
  8014a3:	83 ec 14             	sub    $0x14,%esp
  8014a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014a9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014ac:	50                   	push   %eax
  8014ad:	53                   	push   %ebx
  8014ae:	e8 86 fd ff ff       	call   801239 <fd_lookup>
  8014b3:	83 c4 08             	add    $0x8,%esp
  8014b6:	89 c2                	mov    %eax,%edx
  8014b8:	85 c0                	test   %eax,%eax
  8014ba:	78 6d                	js     801529 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014bc:	83 ec 08             	sub    $0x8,%esp
  8014bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014c2:	50                   	push   %eax
  8014c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014c6:	ff 30                	pushl  (%eax)
  8014c8:	e8 c2 fd ff ff       	call   80128f <dev_lookup>
  8014cd:	83 c4 10             	add    $0x10,%esp
  8014d0:	85 c0                	test   %eax,%eax
  8014d2:	78 4c                	js     801520 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014d4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014d7:	8b 42 08             	mov    0x8(%edx),%eax
  8014da:	83 e0 03             	and    $0x3,%eax
  8014dd:	83 f8 01             	cmp    $0x1,%eax
  8014e0:	75 21                	jne    801503 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014e2:	a1 08 40 80 00       	mov    0x804008,%eax
  8014e7:	8b 40 48             	mov    0x48(%eax),%eax
  8014ea:	83 ec 04             	sub    $0x4,%esp
  8014ed:	53                   	push   %ebx
  8014ee:	50                   	push   %eax
  8014ef:	68 81 2b 80 00       	push   $0x802b81
  8014f4:	e8 93 ed ff ff       	call   80028c <cprintf>
		return -E_INVAL;
  8014f9:	83 c4 10             	add    $0x10,%esp
  8014fc:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801501:	eb 26                	jmp    801529 <read+0x8a>
	}
	if (!dev->dev_read)
  801503:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801506:	8b 40 08             	mov    0x8(%eax),%eax
  801509:	85 c0                	test   %eax,%eax
  80150b:	74 17                	je     801524 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80150d:	83 ec 04             	sub    $0x4,%esp
  801510:	ff 75 10             	pushl  0x10(%ebp)
  801513:	ff 75 0c             	pushl  0xc(%ebp)
  801516:	52                   	push   %edx
  801517:	ff d0                	call   *%eax
  801519:	89 c2                	mov    %eax,%edx
  80151b:	83 c4 10             	add    $0x10,%esp
  80151e:	eb 09                	jmp    801529 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801520:	89 c2                	mov    %eax,%edx
  801522:	eb 05                	jmp    801529 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801524:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801529:	89 d0                	mov    %edx,%eax
  80152b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80152e:	c9                   	leave  
  80152f:	c3                   	ret    

00801530 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801530:	55                   	push   %ebp
  801531:	89 e5                	mov    %esp,%ebp
  801533:	57                   	push   %edi
  801534:	56                   	push   %esi
  801535:	53                   	push   %ebx
  801536:	83 ec 0c             	sub    $0xc,%esp
  801539:	8b 7d 08             	mov    0x8(%ebp),%edi
  80153c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80153f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801544:	eb 21                	jmp    801567 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801546:	83 ec 04             	sub    $0x4,%esp
  801549:	89 f0                	mov    %esi,%eax
  80154b:	29 d8                	sub    %ebx,%eax
  80154d:	50                   	push   %eax
  80154e:	89 d8                	mov    %ebx,%eax
  801550:	03 45 0c             	add    0xc(%ebp),%eax
  801553:	50                   	push   %eax
  801554:	57                   	push   %edi
  801555:	e8 45 ff ff ff       	call   80149f <read>
		if (m < 0)
  80155a:	83 c4 10             	add    $0x10,%esp
  80155d:	85 c0                	test   %eax,%eax
  80155f:	78 10                	js     801571 <readn+0x41>
			return m;
		if (m == 0)
  801561:	85 c0                	test   %eax,%eax
  801563:	74 0a                	je     80156f <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801565:	01 c3                	add    %eax,%ebx
  801567:	39 f3                	cmp    %esi,%ebx
  801569:	72 db                	jb     801546 <readn+0x16>
  80156b:	89 d8                	mov    %ebx,%eax
  80156d:	eb 02                	jmp    801571 <readn+0x41>
  80156f:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801571:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801574:	5b                   	pop    %ebx
  801575:	5e                   	pop    %esi
  801576:	5f                   	pop    %edi
  801577:	5d                   	pop    %ebp
  801578:	c3                   	ret    

00801579 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801579:	55                   	push   %ebp
  80157a:	89 e5                	mov    %esp,%ebp
  80157c:	53                   	push   %ebx
  80157d:	83 ec 14             	sub    $0x14,%esp
  801580:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801583:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801586:	50                   	push   %eax
  801587:	53                   	push   %ebx
  801588:	e8 ac fc ff ff       	call   801239 <fd_lookup>
  80158d:	83 c4 08             	add    $0x8,%esp
  801590:	89 c2                	mov    %eax,%edx
  801592:	85 c0                	test   %eax,%eax
  801594:	78 68                	js     8015fe <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801596:	83 ec 08             	sub    $0x8,%esp
  801599:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80159c:	50                   	push   %eax
  80159d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015a0:	ff 30                	pushl  (%eax)
  8015a2:	e8 e8 fc ff ff       	call   80128f <dev_lookup>
  8015a7:	83 c4 10             	add    $0x10,%esp
  8015aa:	85 c0                	test   %eax,%eax
  8015ac:	78 47                	js     8015f5 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015b1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015b5:	75 21                	jne    8015d8 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015b7:	a1 08 40 80 00       	mov    0x804008,%eax
  8015bc:	8b 40 48             	mov    0x48(%eax),%eax
  8015bf:	83 ec 04             	sub    $0x4,%esp
  8015c2:	53                   	push   %ebx
  8015c3:	50                   	push   %eax
  8015c4:	68 9d 2b 80 00       	push   $0x802b9d
  8015c9:	e8 be ec ff ff       	call   80028c <cprintf>
		return -E_INVAL;
  8015ce:	83 c4 10             	add    $0x10,%esp
  8015d1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015d6:	eb 26                	jmp    8015fe <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015d8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015db:	8b 52 0c             	mov    0xc(%edx),%edx
  8015de:	85 d2                	test   %edx,%edx
  8015e0:	74 17                	je     8015f9 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015e2:	83 ec 04             	sub    $0x4,%esp
  8015e5:	ff 75 10             	pushl  0x10(%ebp)
  8015e8:	ff 75 0c             	pushl  0xc(%ebp)
  8015eb:	50                   	push   %eax
  8015ec:	ff d2                	call   *%edx
  8015ee:	89 c2                	mov    %eax,%edx
  8015f0:	83 c4 10             	add    $0x10,%esp
  8015f3:	eb 09                	jmp    8015fe <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015f5:	89 c2                	mov    %eax,%edx
  8015f7:	eb 05                	jmp    8015fe <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015f9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8015fe:	89 d0                	mov    %edx,%eax
  801600:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801603:	c9                   	leave  
  801604:	c3                   	ret    

00801605 <seek>:

int
seek(int fdnum, off_t offset)
{
  801605:	55                   	push   %ebp
  801606:	89 e5                	mov    %esp,%ebp
  801608:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80160b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80160e:	50                   	push   %eax
  80160f:	ff 75 08             	pushl  0x8(%ebp)
  801612:	e8 22 fc ff ff       	call   801239 <fd_lookup>
  801617:	83 c4 08             	add    $0x8,%esp
  80161a:	85 c0                	test   %eax,%eax
  80161c:	78 0e                	js     80162c <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80161e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801621:	8b 55 0c             	mov    0xc(%ebp),%edx
  801624:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801627:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80162c:	c9                   	leave  
  80162d:	c3                   	ret    

0080162e <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80162e:	55                   	push   %ebp
  80162f:	89 e5                	mov    %esp,%ebp
  801631:	53                   	push   %ebx
  801632:	83 ec 14             	sub    $0x14,%esp
  801635:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801638:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80163b:	50                   	push   %eax
  80163c:	53                   	push   %ebx
  80163d:	e8 f7 fb ff ff       	call   801239 <fd_lookup>
  801642:	83 c4 08             	add    $0x8,%esp
  801645:	89 c2                	mov    %eax,%edx
  801647:	85 c0                	test   %eax,%eax
  801649:	78 65                	js     8016b0 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80164b:	83 ec 08             	sub    $0x8,%esp
  80164e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801651:	50                   	push   %eax
  801652:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801655:	ff 30                	pushl  (%eax)
  801657:	e8 33 fc ff ff       	call   80128f <dev_lookup>
  80165c:	83 c4 10             	add    $0x10,%esp
  80165f:	85 c0                	test   %eax,%eax
  801661:	78 44                	js     8016a7 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801663:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801666:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80166a:	75 21                	jne    80168d <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80166c:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801671:	8b 40 48             	mov    0x48(%eax),%eax
  801674:	83 ec 04             	sub    $0x4,%esp
  801677:	53                   	push   %ebx
  801678:	50                   	push   %eax
  801679:	68 60 2b 80 00       	push   $0x802b60
  80167e:	e8 09 ec ff ff       	call   80028c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801683:	83 c4 10             	add    $0x10,%esp
  801686:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80168b:	eb 23                	jmp    8016b0 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80168d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801690:	8b 52 18             	mov    0x18(%edx),%edx
  801693:	85 d2                	test   %edx,%edx
  801695:	74 14                	je     8016ab <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801697:	83 ec 08             	sub    $0x8,%esp
  80169a:	ff 75 0c             	pushl  0xc(%ebp)
  80169d:	50                   	push   %eax
  80169e:	ff d2                	call   *%edx
  8016a0:	89 c2                	mov    %eax,%edx
  8016a2:	83 c4 10             	add    $0x10,%esp
  8016a5:	eb 09                	jmp    8016b0 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a7:	89 c2                	mov    %eax,%edx
  8016a9:	eb 05                	jmp    8016b0 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016ab:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8016b0:	89 d0                	mov    %edx,%eax
  8016b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016b5:	c9                   	leave  
  8016b6:	c3                   	ret    

008016b7 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016b7:	55                   	push   %ebp
  8016b8:	89 e5                	mov    %esp,%ebp
  8016ba:	53                   	push   %ebx
  8016bb:	83 ec 14             	sub    $0x14,%esp
  8016be:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016c1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016c4:	50                   	push   %eax
  8016c5:	ff 75 08             	pushl  0x8(%ebp)
  8016c8:	e8 6c fb ff ff       	call   801239 <fd_lookup>
  8016cd:	83 c4 08             	add    $0x8,%esp
  8016d0:	89 c2                	mov    %eax,%edx
  8016d2:	85 c0                	test   %eax,%eax
  8016d4:	78 58                	js     80172e <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016d6:	83 ec 08             	sub    $0x8,%esp
  8016d9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016dc:	50                   	push   %eax
  8016dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016e0:	ff 30                	pushl  (%eax)
  8016e2:	e8 a8 fb ff ff       	call   80128f <dev_lookup>
  8016e7:	83 c4 10             	add    $0x10,%esp
  8016ea:	85 c0                	test   %eax,%eax
  8016ec:	78 37                	js     801725 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016f1:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016f5:	74 32                	je     801729 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016f7:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016fa:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801701:	00 00 00 
	stat->st_isdir = 0;
  801704:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80170b:	00 00 00 
	stat->st_dev = dev;
  80170e:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801714:	83 ec 08             	sub    $0x8,%esp
  801717:	53                   	push   %ebx
  801718:	ff 75 f0             	pushl  -0x10(%ebp)
  80171b:	ff 50 14             	call   *0x14(%eax)
  80171e:	89 c2                	mov    %eax,%edx
  801720:	83 c4 10             	add    $0x10,%esp
  801723:	eb 09                	jmp    80172e <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801725:	89 c2                	mov    %eax,%edx
  801727:	eb 05                	jmp    80172e <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801729:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80172e:	89 d0                	mov    %edx,%eax
  801730:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801733:	c9                   	leave  
  801734:	c3                   	ret    

00801735 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801735:	55                   	push   %ebp
  801736:	89 e5                	mov    %esp,%ebp
  801738:	56                   	push   %esi
  801739:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80173a:	83 ec 08             	sub    $0x8,%esp
  80173d:	6a 00                	push   $0x0
  80173f:	ff 75 08             	pushl  0x8(%ebp)
  801742:	e8 0c 02 00 00       	call   801953 <open>
  801747:	89 c3                	mov    %eax,%ebx
  801749:	83 c4 10             	add    $0x10,%esp
  80174c:	85 c0                	test   %eax,%eax
  80174e:	78 1b                	js     80176b <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801750:	83 ec 08             	sub    $0x8,%esp
  801753:	ff 75 0c             	pushl  0xc(%ebp)
  801756:	50                   	push   %eax
  801757:	e8 5b ff ff ff       	call   8016b7 <fstat>
  80175c:	89 c6                	mov    %eax,%esi
	close(fd);
  80175e:	89 1c 24             	mov    %ebx,(%esp)
  801761:	e8 fd fb ff ff       	call   801363 <close>
	return r;
  801766:	83 c4 10             	add    $0x10,%esp
  801769:	89 f0                	mov    %esi,%eax
}
  80176b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80176e:	5b                   	pop    %ebx
  80176f:	5e                   	pop    %esi
  801770:	5d                   	pop    %ebp
  801771:	c3                   	ret    

00801772 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801772:	55                   	push   %ebp
  801773:	89 e5                	mov    %esp,%ebp
  801775:	56                   	push   %esi
  801776:	53                   	push   %ebx
  801777:	89 c6                	mov    %eax,%esi
  801779:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80177b:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801782:	75 12                	jne    801796 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801784:	83 ec 0c             	sub    $0xc,%esp
  801787:	6a 01                	push   $0x1
  801789:	e8 fc f9 ff ff       	call   80118a <ipc_find_env>
  80178e:	a3 00 40 80 00       	mov    %eax,0x804000
  801793:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801796:	6a 07                	push   $0x7
  801798:	68 00 50 80 00       	push   $0x805000
  80179d:	56                   	push   %esi
  80179e:	ff 35 00 40 80 00    	pushl  0x804000
  8017a4:	e8 8d f9 ff ff       	call   801136 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017a9:	83 c4 0c             	add    $0xc,%esp
  8017ac:	6a 00                	push   $0x0
  8017ae:	53                   	push   %ebx
  8017af:	6a 00                	push   $0x0
  8017b1:	e8 17 f9 ff ff       	call   8010cd <ipc_recv>
}
  8017b6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017b9:	5b                   	pop    %ebx
  8017ba:	5e                   	pop    %esi
  8017bb:	5d                   	pop    %ebp
  8017bc:	c3                   	ret    

008017bd <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017bd:	55                   	push   %ebp
  8017be:	89 e5                	mov    %esp,%ebp
  8017c0:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c6:	8b 40 0c             	mov    0xc(%eax),%eax
  8017c9:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017d1:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017d6:	ba 00 00 00 00       	mov    $0x0,%edx
  8017db:	b8 02 00 00 00       	mov    $0x2,%eax
  8017e0:	e8 8d ff ff ff       	call   801772 <fsipc>
}
  8017e5:	c9                   	leave  
  8017e6:	c3                   	ret    

008017e7 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017e7:	55                   	push   %ebp
  8017e8:	89 e5                	mov    %esp,%ebp
  8017ea:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f0:	8b 40 0c             	mov    0xc(%eax),%eax
  8017f3:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8017fd:	b8 06 00 00 00       	mov    $0x6,%eax
  801802:	e8 6b ff ff ff       	call   801772 <fsipc>
}
  801807:	c9                   	leave  
  801808:	c3                   	ret    

00801809 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801809:	55                   	push   %ebp
  80180a:	89 e5                	mov    %esp,%ebp
  80180c:	53                   	push   %ebx
  80180d:	83 ec 04             	sub    $0x4,%esp
  801810:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801813:	8b 45 08             	mov    0x8(%ebp),%eax
  801816:	8b 40 0c             	mov    0xc(%eax),%eax
  801819:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80181e:	ba 00 00 00 00       	mov    $0x0,%edx
  801823:	b8 05 00 00 00       	mov    $0x5,%eax
  801828:	e8 45 ff ff ff       	call   801772 <fsipc>
  80182d:	85 c0                	test   %eax,%eax
  80182f:	78 2c                	js     80185d <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801831:	83 ec 08             	sub    $0x8,%esp
  801834:	68 00 50 80 00       	push   $0x805000
  801839:	53                   	push   %ebx
  80183a:	e8 d2 ef ff ff       	call   800811 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80183f:	a1 80 50 80 00       	mov    0x805080,%eax
  801844:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80184a:	a1 84 50 80 00       	mov    0x805084,%eax
  80184f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801855:	83 c4 10             	add    $0x10,%esp
  801858:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80185d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801860:	c9                   	leave  
  801861:	c3                   	ret    

00801862 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801862:	55                   	push   %ebp
  801863:	89 e5                	mov    %esp,%ebp
  801865:	53                   	push   %ebx
  801866:	83 ec 08             	sub    $0x8,%esp
  801869:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80186c:	8b 55 08             	mov    0x8(%ebp),%edx
  80186f:	8b 52 0c             	mov    0xc(%edx),%edx
  801872:	89 15 00 50 80 00    	mov    %edx,0x805000
  801878:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80187d:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  801882:	0f 46 d8             	cmovbe %eax,%ebx
	
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  801885:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  80188b:	53                   	push   %ebx
  80188c:	ff 75 0c             	pushl  0xc(%ebp)
  80188f:	68 08 50 80 00       	push   $0x805008
  801894:	e8 0a f1 ff ff       	call   8009a3 <memmove>

	
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) 
  801899:	ba 00 00 00 00       	mov    $0x0,%edx
  80189e:	b8 04 00 00 00       	mov    $0x4,%eax
  8018a3:	e8 ca fe ff ff       	call   801772 <fsipc>
  8018a8:	83 c4 10             	add    $0x10,%esp
  8018ab:	85 c0                	test   %eax,%eax
  8018ad:	78 1d                	js     8018cc <devfile_write+0x6a>
		return r;
	assert(r <= n_real); 
  8018af:	39 d8                	cmp    %ebx,%eax
  8018b1:	76 19                	jbe    8018cc <devfile_write+0x6a>
  8018b3:	68 d0 2b 80 00       	push   $0x802bd0
  8018b8:	68 dc 2b 80 00       	push   $0x802bdc
  8018bd:	68 a3 00 00 00       	push   $0xa3
  8018c2:	68 f1 2b 80 00       	push   $0x802bf1
  8018c7:	e8 71 0a 00 00       	call   80233d <_panic>
	return r;
}
  8018cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018cf:	c9                   	leave  
  8018d0:	c3                   	ret    

008018d1 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018d1:	55                   	push   %ebp
  8018d2:	89 e5                	mov    %esp,%ebp
  8018d4:	56                   	push   %esi
  8018d5:	53                   	push   %ebx
  8018d6:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8018dc:	8b 40 0c             	mov    0xc(%eax),%eax
  8018df:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018e4:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ef:	b8 03 00 00 00       	mov    $0x3,%eax
  8018f4:	e8 79 fe ff ff       	call   801772 <fsipc>
  8018f9:	89 c3                	mov    %eax,%ebx
  8018fb:	85 c0                	test   %eax,%eax
  8018fd:	78 4b                	js     80194a <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018ff:	39 c6                	cmp    %eax,%esi
  801901:	73 16                	jae    801919 <devfile_read+0x48>
  801903:	68 fc 2b 80 00       	push   $0x802bfc
  801908:	68 dc 2b 80 00       	push   $0x802bdc
  80190d:	6a 7c                	push   $0x7c
  80190f:	68 f1 2b 80 00       	push   $0x802bf1
  801914:	e8 24 0a 00 00       	call   80233d <_panic>
	assert(r <= PGSIZE);
  801919:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80191e:	7e 16                	jle    801936 <devfile_read+0x65>
  801920:	68 03 2c 80 00       	push   $0x802c03
  801925:	68 dc 2b 80 00       	push   $0x802bdc
  80192a:	6a 7d                	push   $0x7d
  80192c:	68 f1 2b 80 00       	push   $0x802bf1
  801931:	e8 07 0a 00 00       	call   80233d <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801936:	83 ec 04             	sub    $0x4,%esp
  801939:	50                   	push   %eax
  80193a:	68 00 50 80 00       	push   $0x805000
  80193f:	ff 75 0c             	pushl  0xc(%ebp)
  801942:	e8 5c f0 ff ff       	call   8009a3 <memmove>
	return r;
  801947:	83 c4 10             	add    $0x10,%esp
}
  80194a:	89 d8                	mov    %ebx,%eax
  80194c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80194f:	5b                   	pop    %ebx
  801950:	5e                   	pop    %esi
  801951:	5d                   	pop    %ebp
  801952:	c3                   	ret    

00801953 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801953:	55                   	push   %ebp
  801954:	89 e5                	mov    %esp,%ebp
  801956:	53                   	push   %ebx
  801957:	83 ec 20             	sub    $0x20,%esp
  80195a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80195d:	53                   	push   %ebx
  80195e:	e8 75 ee ff ff       	call   8007d8 <strlen>
  801963:	83 c4 10             	add    $0x10,%esp
  801966:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80196b:	7f 67                	jg     8019d4 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80196d:	83 ec 0c             	sub    $0xc,%esp
  801970:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801973:	50                   	push   %eax
  801974:	e8 71 f8 ff ff       	call   8011ea <fd_alloc>
  801979:	83 c4 10             	add    $0x10,%esp
		return r;
  80197c:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80197e:	85 c0                	test   %eax,%eax
  801980:	78 57                	js     8019d9 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801982:	83 ec 08             	sub    $0x8,%esp
  801985:	53                   	push   %ebx
  801986:	68 00 50 80 00       	push   $0x805000
  80198b:	e8 81 ee ff ff       	call   800811 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801990:	8b 45 0c             	mov    0xc(%ebp),%eax
  801993:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801998:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80199b:	b8 01 00 00 00       	mov    $0x1,%eax
  8019a0:	e8 cd fd ff ff       	call   801772 <fsipc>
  8019a5:	89 c3                	mov    %eax,%ebx
  8019a7:	83 c4 10             	add    $0x10,%esp
  8019aa:	85 c0                	test   %eax,%eax
  8019ac:	79 14                	jns    8019c2 <open+0x6f>
		fd_close(fd, 0);
  8019ae:	83 ec 08             	sub    $0x8,%esp
  8019b1:	6a 00                	push   $0x0
  8019b3:	ff 75 f4             	pushl  -0xc(%ebp)
  8019b6:	e8 27 f9 ff ff       	call   8012e2 <fd_close>
		return r;
  8019bb:	83 c4 10             	add    $0x10,%esp
  8019be:	89 da                	mov    %ebx,%edx
  8019c0:	eb 17                	jmp    8019d9 <open+0x86>
	}

	return fd2num(fd);
  8019c2:	83 ec 0c             	sub    $0xc,%esp
  8019c5:	ff 75 f4             	pushl  -0xc(%ebp)
  8019c8:	e8 f6 f7 ff ff       	call   8011c3 <fd2num>
  8019cd:	89 c2                	mov    %eax,%edx
  8019cf:	83 c4 10             	add    $0x10,%esp
  8019d2:	eb 05                	jmp    8019d9 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019d4:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019d9:	89 d0                	mov    %edx,%eax
  8019db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019de:	c9                   	leave  
  8019df:	c3                   	ret    

008019e0 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019e0:	55                   	push   %ebp
  8019e1:	89 e5                	mov    %esp,%ebp
  8019e3:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8019eb:	b8 08 00 00 00       	mov    $0x8,%eax
  8019f0:	e8 7d fd ff ff       	call   801772 <fsipc>
}
  8019f5:	c9                   	leave  
  8019f6:	c3                   	ret    

008019f7 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8019f7:	55                   	push   %ebp
  8019f8:	89 e5                	mov    %esp,%ebp
  8019fa:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8019fd:	68 0f 2c 80 00       	push   $0x802c0f
  801a02:	ff 75 0c             	pushl  0xc(%ebp)
  801a05:	e8 07 ee ff ff       	call   800811 <strcpy>
	return 0;
}
  801a0a:	b8 00 00 00 00       	mov    $0x0,%eax
  801a0f:	c9                   	leave  
  801a10:	c3                   	ret    

00801a11 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801a11:	55                   	push   %ebp
  801a12:	89 e5                	mov    %esp,%ebp
  801a14:	53                   	push   %ebx
  801a15:	83 ec 10             	sub    $0x10,%esp
  801a18:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801a1b:	53                   	push   %ebx
  801a1c:	e8 d8 09 00 00       	call   8023f9 <pageref>
  801a21:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801a24:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801a29:	83 f8 01             	cmp    $0x1,%eax
  801a2c:	75 10                	jne    801a3e <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801a2e:	83 ec 0c             	sub    $0xc,%esp
  801a31:	ff 73 0c             	pushl  0xc(%ebx)
  801a34:	e8 c0 02 00 00       	call   801cf9 <nsipc_close>
  801a39:	89 c2                	mov    %eax,%edx
  801a3b:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801a3e:	89 d0                	mov    %edx,%eax
  801a40:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a43:	c9                   	leave  
  801a44:	c3                   	ret    

00801a45 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801a45:	55                   	push   %ebp
  801a46:	89 e5                	mov    %esp,%ebp
  801a48:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801a4b:	6a 00                	push   $0x0
  801a4d:	ff 75 10             	pushl  0x10(%ebp)
  801a50:	ff 75 0c             	pushl  0xc(%ebp)
  801a53:	8b 45 08             	mov    0x8(%ebp),%eax
  801a56:	ff 70 0c             	pushl  0xc(%eax)
  801a59:	e8 78 03 00 00       	call   801dd6 <nsipc_send>
}
  801a5e:	c9                   	leave  
  801a5f:	c3                   	ret    

00801a60 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801a60:	55                   	push   %ebp
  801a61:	89 e5                	mov    %esp,%ebp
  801a63:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801a66:	6a 00                	push   $0x0
  801a68:	ff 75 10             	pushl  0x10(%ebp)
  801a6b:	ff 75 0c             	pushl  0xc(%ebp)
  801a6e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a71:	ff 70 0c             	pushl  0xc(%eax)
  801a74:	e8 f1 02 00 00       	call   801d6a <nsipc_recv>
}
  801a79:	c9                   	leave  
  801a7a:	c3                   	ret    

00801a7b <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801a7b:	55                   	push   %ebp
  801a7c:	89 e5                	mov    %esp,%ebp
  801a7e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801a81:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801a84:	52                   	push   %edx
  801a85:	50                   	push   %eax
  801a86:	e8 ae f7 ff ff       	call   801239 <fd_lookup>
  801a8b:	83 c4 10             	add    $0x10,%esp
  801a8e:	85 c0                	test   %eax,%eax
  801a90:	78 17                	js     801aa9 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801a92:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a95:	8b 0d 28 30 80 00    	mov    0x803028,%ecx
  801a9b:	39 08                	cmp    %ecx,(%eax)
  801a9d:	75 05                	jne    801aa4 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801a9f:	8b 40 0c             	mov    0xc(%eax),%eax
  801aa2:	eb 05                	jmp    801aa9 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801aa4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801aa9:	c9                   	leave  
  801aaa:	c3                   	ret    

00801aab <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801aab:	55                   	push   %ebp
  801aac:	89 e5                	mov    %esp,%ebp
  801aae:	56                   	push   %esi
  801aaf:	53                   	push   %ebx
  801ab0:	83 ec 1c             	sub    $0x1c,%esp
  801ab3:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801ab5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ab8:	50                   	push   %eax
  801ab9:	e8 2c f7 ff ff       	call   8011ea <fd_alloc>
  801abe:	89 c3                	mov    %eax,%ebx
  801ac0:	83 c4 10             	add    $0x10,%esp
  801ac3:	85 c0                	test   %eax,%eax
  801ac5:	78 1b                	js     801ae2 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801ac7:	83 ec 04             	sub    $0x4,%esp
  801aca:	68 07 04 00 00       	push   $0x407
  801acf:	ff 75 f4             	pushl  -0xc(%ebp)
  801ad2:	6a 00                	push   $0x0
  801ad4:	e8 3b f1 ff ff       	call   800c14 <sys_page_alloc>
  801ad9:	89 c3                	mov    %eax,%ebx
  801adb:	83 c4 10             	add    $0x10,%esp
  801ade:	85 c0                	test   %eax,%eax
  801ae0:	79 10                	jns    801af2 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801ae2:	83 ec 0c             	sub    $0xc,%esp
  801ae5:	56                   	push   %esi
  801ae6:	e8 0e 02 00 00       	call   801cf9 <nsipc_close>
		return r;
  801aeb:	83 c4 10             	add    $0x10,%esp
  801aee:	89 d8                	mov    %ebx,%eax
  801af0:	eb 24                	jmp    801b16 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801af2:	8b 15 28 30 80 00    	mov    0x803028,%edx
  801af8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801afb:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801afd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b00:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801b07:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801b0a:	83 ec 0c             	sub    $0xc,%esp
  801b0d:	50                   	push   %eax
  801b0e:	e8 b0 f6 ff ff       	call   8011c3 <fd2num>
  801b13:	83 c4 10             	add    $0x10,%esp
}
  801b16:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b19:	5b                   	pop    %ebx
  801b1a:	5e                   	pop    %esi
  801b1b:	5d                   	pop    %ebp
  801b1c:	c3                   	ret    

00801b1d <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801b1d:	55                   	push   %ebp
  801b1e:	89 e5                	mov    %esp,%ebp
  801b20:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b23:	8b 45 08             	mov    0x8(%ebp),%eax
  801b26:	e8 50 ff ff ff       	call   801a7b <fd2sockid>
		return r;
  801b2b:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b2d:	85 c0                	test   %eax,%eax
  801b2f:	78 1f                	js     801b50 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b31:	83 ec 04             	sub    $0x4,%esp
  801b34:	ff 75 10             	pushl  0x10(%ebp)
  801b37:	ff 75 0c             	pushl  0xc(%ebp)
  801b3a:	50                   	push   %eax
  801b3b:	e8 12 01 00 00       	call   801c52 <nsipc_accept>
  801b40:	83 c4 10             	add    $0x10,%esp
		return r;
  801b43:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b45:	85 c0                	test   %eax,%eax
  801b47:	78 07                	js     801b50 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801b49:	e8 5d ff ff ff       	call   801aab <alloc_sockfd>
  801b4e:	89 c1                	mov    %eax,%ecx
}
  801b50:	89 c8                	mov    %ecx,%eax
  801b52:	c9                   	leave  
  801b53:	c3                   	ret    

00801b54 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801b54:	55                   	push   %ebp
  801b55:	89 e5                	mov    %esp,%ebp
  801b57:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b5a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b5d:	e8 19 ff ff ff       	call   801a7b <fd2sockid>
  801b62:	85 c0                	test   %eax,%eax
  801b64:	78 12                	js     801b78 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801b66:	83 ec 04             	sub    $0x4,%esp
  801b69:	ff 75 10             	pushl  0x10(%ebp)
  801b6c:	ff 75 0c             	pushl  0xc(%ebp)
  801b6f:	50                   	push   %eax
  801b70:	e8 2d 01 00 00       	call   801ca2 <nsipc_bind>
  801b75:	83 c4 10             	add    $0x10,%esp
}
  801b78:	c9                   	leave  
  801b79:	c3                   	ret    

00801b7a <shutdown>:

int
shutdown(int s, int how)
{
  801b7a:	55                   	push   %ebp
  801b7b:	89 e5                	mov    %esp,%ebp
  801b7d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b80:	8b 45 08             	mov    0x8(%ebp),%eax
  801b83:	e8 f3 fe ff ff       	call   801a7b <fd2sockid>
  801b88:	85 c0                	test   %eax,%eax
  801b8a:	78 0f                	js     801b9b <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801b8c:	83 ec 08             	sub    $0x8,%esp
  801b8f:	ff 75 0c             	pushl  0xc(%ebp)
  801b92:	50                   	push   %eax
  801b93:	e8 3f 01 00 00       	call   801cd7 <nsipc_shutdown>
  801b98:	83 c4 10             	add    $0x10,%esp
}
  801b9b:	c9                   	leave  
  801b9c:	c3                   	ret    

00801b9d <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801b9d:	55                   	push   %ebp
  801b9e:	89 e5                	mov    %esp,%ebp
  801ba0:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ba3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba6:	e8 d0 fe ff ff       	call   801a7b <fd2sockid>
  801bab:	85 c0                	test   %eax,%eax
  801bad:	78 12                	js     801bc1 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801baf:	83 ec 04             	sub    $0x4,%esp
  801bb2:	ff 75 10             	pushl  0x10(%ebp)
  801bb5:	ff 75 0c             	pushl  0xc(%ebp)
  801bb8:	50                   	push   %eax
  801bb9:	e8 55 01 00 00       	call   801d13 <nsipc_connect>
  801bbe:	83 c4 10             	add    $0x10,%esp
}
  801bc1:	c9                   	leave  
  801bc2:	c3                   	ret    

00801bc3 <listen>:

int
listen(int s, int backlog)
{
  801bc3:	55                   	push   %ebp
  801bc4:	89 e5                	mov    %esp,%ebp
  801bc6:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bc9:	8b 45 08             	mov    0x8(%ebp),%eax
  801bcc:	e8 aa fe ff ff       	call   801a7b <fd2sockid>
  801bd1:	85 c0                	test   %eax,%eax
  801bd3:	78 0f                	js     801be4 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801bd5:	83 ec 08             	sub    $0x8,%esp
  801bd8:	ff 75 0c             	pushl  0xc(%ebp)
  801bdb:	50                   	push   %eax
  801bdc:	e8 67 01 00 00       	call   801d48 <nsipc_listen>
  801be1:	83 c4 10             	add    $0x10,%esp
}
  801be4:	c9                   	leave  
  801be5:	c3                   	ret    

00801be6 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801be6:	55                   	push   %ebp
  801be7:	89 e5                	mov    %esp,%ebp
  801be9:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801bec:	ff 75 10             	pushl  0x10(%ebp)
  801bef:	ff 75 0c             	pushl  0xc(%ebp)
  801bf2:	ff 75 08             	pushl  0x8(%ebp)
  801bf5:	e8 3a 02 00 00       	call   801e34 <nsipc_socket>
  801bfa:	83 c4 10             	add    $0x10,%esp
  801bfd:	85 c0                	test   %eax,%eax
  801bff:	78 05                	js     801c06 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801c01:	e8 a5 fe ff ff       	call   801aab <alloc_sockfd>
}
  801c06:	c9                   	leave  
  801c07:	c3                   	ret    

00801c08 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801c08:	55                   	push   %ebp
  801c09:	89 e5                	mov    %esp,%ebp
  801c0b:	53                   	push   %ebx
  801c0c:	83 ec 04             	sub    $0x4,%esp
  801c0f:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801c11:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801c18:	75 12                	jne    801c2c <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801c1a:	83 ec 0c             	sub    $0xc,%esp
  801c1d:	6a 02                	push   $0x2
  801c1f:	e8 66 f5 ff ff       	call   80118a <ipc_find_env>
  801c24:	a3 04 40 80 00       	mov    %eax,0x804004
  801c29:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801c2c:	6a 07                	push   $0x7
  801c2e:	68 00 60 80 00       	push   $0x806000
  801c33:	53                   	push   %ebx
  801c34:	ff 35 04 40 80 00    	pushl  0x804004
  801c3a:	e8 f7 f4 ff ff       	call   801136 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801c3f:	83 c4 0c             	add    $0xc,%esp
  801c42:	6a 00                	push   $0x0
  801c44:	6a 00                	push   $0x0
  801c46:	6a 00                	push   $0x0
  801c48:	e8 80 f4 ff ff       	call   8010cd <ipc_recv>
}
  801c4d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c50:	c9                   	leave  
  801c51:	c3                   	ret    

00801c52 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c52:	55                   	push   %ebp
  801c53:	89 e5                	mov    %esp,%ebp
  801c55:	56                   	push   %esi
  801c56:	53                   	push   %ebx
  801c57:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801c5a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c5d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801c62:	8b 06                	mov    (%esi),%eax
  801c64:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801c69:	b8 01 00 00 00       	mov    $0x1,%eax
  801c6e:	e8 95 ff ff ff       	call   801c08 <nsipc>
  801c73:	89 c3                	mov    %eax,%ebx
  801c75:	85 c0                	test   %eax,%eax
  801c77:	78 20                	js     801c99 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801c79:	83 ec 04             	sub    $0x4,%esp
  801c7c:	ff 35 10 60 80 00    	pushl  0x806010
  801c82:	68 00 60 80 00       	push   $0x806000
  801c87:	ff 75 0c             	pushl  0xc(%ebp)
  801c8a:	e8 14 ed ff ff       	call   8009a3 <memmove>
		*addrlen = ret->ret_addrlen;
  801c8f:	a1 10 60 80 00       	mov    0x806010,%eax
  801c94:	89 06                	mov    %eax,(%esi)
  801c96:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801c99:	89 d8                	mov    %ebx,%eax
  801c9b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c9e:	5b                   	pop    %ebx
  801c9f:	5e                   	pop    %esi
  801ca0:	5d                   	pop    %ebp
  801ca1:	c3                   	ret    

00801ca2 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801ca2:	55                   	push   %ebp
  801ca3:	89 e5                	mov    %esp,%ebp
  801ca5:	53                   	push   %ebx
  801ca6:	83 ec 08             	sub    $0x8,%esp
  801ca9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801cac:	8b 45 08             	mov    0x8(%ebp),%eax
  801caf:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801cb4:	53                   	push   %ebx
  801cb5:	ff 75 0c             	pushl  0xc(%ebp)
  801cb8:	68 04 60 80 00       	push   $0x806004
  801cbd:	e8 e1 ec ff ff       	call   8009a3 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801cc2:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801cc8:	b8 02 00 00 00       	mov    $0x2,%eax
  801ccd:	e8 36 ff ff ff       	call   801c08 <nsipc>
}
  801cd2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cd5:	c9                   	leave  
  801cd6:	c3                   	ret    

00801cd7 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801cd7:	55                   	push   %ebp
  801cd8:	89 e5                	mov    %esp,%ebp
  801cda:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801cdd:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce0:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801ce5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ce8:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801ced:	b8 03 00 00 00       	mov    $0x3,%eax
  801cf2:	e8 11 ff ff ff       	call   801c08 <nsipc>
}
  801cf7:	c9                   	leave  
  801cf8:	c3                   	ret    

00801cf9 <nsipc_close>:

int
nsipc_close(int s)
{
  801cf9:	55                   	push   %ebp
  801cfa:	89 e5                	mov    %esp,%ebp
  801cfc:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801cff:	8b 45 08             	mov    0x8(%ebp),%eax
  801d02:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801d07:	b8 04 00 00 00       	mov    $0x4,%eax
  801d0c:	e8 f7 fe ff ff       	call   801c08 <nsipc>
}
  801d11:	c9                   	leave  
  801d12:	c3                   	ret    

00801d13 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801d13:	55                   	push   %ebp
  801d14:	89 e5                	mov    %esp,%ebp
  801d16:	53                   	push   %ebx
  801d17:	83 ec 08             	sub    $0x8,%esp
  801d1a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801d1d:	8b 45 08             	mov    0x8(%ebp),%eax
  801d20:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801d25:	53                   	push   %ebx
  801d26:	ff 75 0c             	pushl  0xc(%ebp)
  801d29:	68 04 60 80 00       	push   $0x806004
  801d2e:	e8 70 ec ff ff       	call   8009a3 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801d33:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801d39:	b8 05 00 00 00       	mov    $0x5,%eax
  801d3e:	e8 c5 fe ff ff       	call   801c08 <nsipc>
}
  801d43:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d46:	c9                   	leave  
  801d47:	c3                   	ret    

00801d48 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801d48:	55                   	push   %ebp
  801d49:	89 e5                	mov    %esp,%ebp
  801d4b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801d4e:	8b 45 08             	mov    0x8(%ebp),%eax
  801d51:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801d56:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d59:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801d5e:	b8 06 00 00 00       	mov    $0x6,%eax
  801d63:	e8 a0 fe ff ff       	call   801c08 <nsipc>
}
  801d68:	c9                   	leave  
  801d69:	c3                   	ret    

00801d6a <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801d6a:	55                   	push   %ebp
  801d6b:	89 e5                	mov    %esp,%ebp
  801d6d:	56                   	push   %esi
  801d6e:	53                   	push   %ebx
  801d6f:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801d72:	8b 45 08             	mov    0x8(%ebp),%eax
  801d75:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801d7a:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801d80:	8b 45 14             	mov    0x14(%ebp),%eax
  801d83:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801d88:	b8 07 00 00 00       	mov    $0x7,%eax
  801d8d:	e8 76 fe ff ff       	call   801c08 <nsipc>
  801d92:	89 c3                	mov    %eax,%ebx
  801d94:	85 c0                	test   %eax,%eax
  801d96:	78 35                	js     801dcd <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801d98:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801d9d:	7f 04                	jg     801da3 <nsipc_recv+0x39>
  801d9f:	39 c6                	cmp    %eax,%esi
  801da1:	7d 16                	jge    801db9 <nsipc_recv+0x4f>
  801da3:	68 1b 2c 80 00       	push   $0x802c1b
  801da8:	68 dc 2b 80 00       	push   $0x802bdc
  801dad:	6a 62                	push   $0x62
  801daf:	68 30 2c 80 00       	push   $0x802c30
  801db4:	e8 84 05 00 00       	call   80233d <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801db9:	83 ec 04             	sub    $0x4,%esp
  801dbc:	50                   	push   %eax
  801dbd:	68 00 60 80 00       	push   $0x806000
  801dc2:	ff 75 0c             	pushl  0xc(%ebp)
  801dc5:	e8 d9 eb ff ff       	call   8009a3 <memmove>
  801dca:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801dcd:	89 d8                	mov    %ebx,%eax
  801dcf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dd2:	5b                   	pop    %ebx
  801dd3:	5e                   	pop    %esi
  801dd4:	5d                   	pop    %ebp
  801dd5:	c3                   	ret    

00801dd6 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801dd6:	55                   	push   %ebp
  801dd7:	89 e5                	mov    %esp,%ebp
  801dd9:	53                   	push   %ebx
  801dda:	83 ec 04             	sub    $0x4,%esp
  801ddd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801de0:	8b 45 08             	mov    0x8(%ebp),%eax
  801de3:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801de8:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801dee:	7e 16                	jle    801e06 <nsipc_send+0x30>
  801df0:	68 3c 2c 80 00       	push   $0x802c3c
  801df5:	68 dc 2b 80 00       	push   $0x802bdc
  801dfa:	6a 6d                	push   $0x6d
  801dfc:	68 30 2c 80 00       	push   $0x802c30
  801e01:	e8 37 05 00 00       	call   80233d <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801e06:	83 ec 04             	sub    $0x4,%esp
  801e09:	53                   	push   %ebx
  801e0a:	ff 75 0c             	pushl  0xc(%ebp)
  801e0d:	68 0c 60 80 00       	push   $0x80600c
  801e12:	e8 8c eb ff ff       	call   8009a3 <memmove>
	nsipcbuf.send.req_size = size;
  801e17:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801e1d:	8b 45 14             	mov    0x14(%ebp),%eax
  801e20:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801e25:	b8 08 00 00 00       	mov    $0x8,%eax
  801e2a:	e8 d9 fd ff ff       	call   801c08 <nsipc>
}
  801e2f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e32:	c9                   	leave  
  801e33:	c3                   	ret    

00801e34 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801e34:	55                   	push   %ebp
  801e35:	89 e5                	mov    %esp,%ebp
  801e37:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801e3a:	8b 45 08             	mov    0x8(%ebp),%eax
  801e3d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801e42:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e45:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801e4a:	8b 45 10             	mov    0x10(%ebp),%eax
  801e4d:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801e52:	b8 09 00 00 00       	mov    $0x9,%eax
  801e57:	e8 ac fd ff ff       	call   801c08 <nsipc>
}
  801e5c:	c9                   	leave  
  801e5d:	c3                   	ret    

00801e5e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e5e:	55                   	push   %ebp
  801e5f:	89 e5                	mov    %esp,%ebp
  801e61:	56                   	push   %esi
  801e62:	53                   	push   %ebx
  801e63:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e66:	83 ec 0c             	sub    $0xc,%esp
  801e69:	ff 75 08             	pushl  0x8(%ebp)
  801e6c:	e8 62 f3 ff ff       	call   8011d3 <fd2data>
  801e71:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801e73:	83 c4 08             	add    $0x8,%esp
  801e76:	68 48 2c 80 00       	push   $0x802c48
  801e7b:	53                   	push   %ebx
  801e7c:	e8 90 e9 ff ff       	call   800811 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e81:	8b 46 04             	mov    0x4(%esi),%eax
  801e84:	2b 06                	sub    (%esi),%eax
  801e86:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801e8c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801e93:	00 00 00 
	stat->st_dev = &devpipe;
  801e96:	c7 83 88 00 00 00 44 	movl   $0x803044,0x88(%ebx)
  801e9d:	30 80 00 
	return 0;
}
  801ea0:	b8 00 00 00 00       	mov    $0x0,%eax
  801ea5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ea8:	5b                   	pop    %ebx
  801ea9:	5e                   	pop    %esi
  801eaa:	5d                   	pop    %ebp
  801eab:	c3                   	ret    

00801eac <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801eac:	55                   	push   %ebp
  801ead:	89 e5                	mov    %esp,%ebp
  801eaf:	53                   	push   %ebx
  801eb0:	83 ec 0c             	sub    $0xc,%esp
  801eb3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801eb6:	53                   	push   %ebx
  801eb7:	6a 00                	push   $0x0
  801eb9:	e8 db ed ff ff       	call   800c99 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ebe:	89 1c 24             	mov    %ebx,(%esp)
  801ec1:	e8 0d f3 ff ff       	call   8011d3 <fd2data>
  801ec6:	83 c4 08             	add    $0x8,%esp
  801ec9:	50                   	push   %eax
  801eca:	6a 00                	push   $0x0
  801ecc:	e8 c8 ed ff ff       	call   800c99 <sys_page_unmap>
}
  801ed1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ed4:	c9                   	leave  
  801ed5:	c3                   	ret    

00801ed6 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801ed6:	55                   	push   %ebp
  801ed7:	89 e5                	mov    %esp,%ebp
  801ed9:	57                   	push   %edi
  801eda:	56                   	push   %esi
  801edb:	53                   	push   %ebx
  801edc:	83 ec 1c             	sub    $0x1c,%esp
  801edf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ee2:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ee4:	a1 08 40 80 00       	mov    0x804008,%eax
  801ee9:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801eec:	83 ec 0c             	sub    $0xc,%esp
  801eef:	ff 75 e0             	pushl  -0x20(%ebp)
  801ef2:	e8 02 05 00 00       	call   8023f9 <pageref>
  801ef7:	89 c3                	mov    %eax,%ebx
  801ef9:	89 3c 24             	mov    %edi,(%esp)
  801efc:	e8 f8 04 00 00       	call   8023f9 <pageref>
  801f01:	83 c4 10             	add    $0x10,%esp
  801f04:	39 c3                	cmp    %eax,%ebx
  801f06:	0f 94 c1             	sete   %cl
  801f09:	0f b6 c9             	movzbl %cl,%ecx
  801f0c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801f0f:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801f15:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801f18:	39 ce                	cmp    %ecx,%esi
  801f1a:	74 1b                	je     801f37 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801f1c:	39 c3                	cmp    %eax,%ebx
  801f1e:	75 c4                	jne    801ee4 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801f20:	8b 42 58             	mov    0x58(%edx),%eax
  801f23:	ff 75 e4             	pushl  -0x1c(%ebp)
  801f26:	50                   	push   %eax
  801f27:	56                   	push   %esi
  801f28:	68 4f 2c 80 00       	push   $0x802c4f
  801f2d:	e8 5a e3 ff ff       	call   80028c <cprintf>
  801f32:	83 c4 10             	add    $0x10,%esp
  801f35:	eb ad                	jmp    801ee4 <_pipeisclosed+0xe>
	}
}
  801f37:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f3d:	5b                   	pop    %ebx
  801f3e:	5e                   	pop    %esi
  801f3f:	5f                   	pop    %edi
  801f40:	5d                   	pop    %ebp
  801f41:	c3                   	ret    

00801f42 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f42:	55                   	push   %ebp
  801f43:	89 e5                	mov    %esp,%ebp
  801f45:	57                   	push   %edi
  801f46:	56                   	push   %esi
  801f47:	53                   	push   %ebx
  801f48:	83 ec 28             	sub    $0x28,%esp
  801f4b:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801f4e:	56                   	push   %esi
  801f4f:	e8 7f f2 ff ff       	call   8011d3 <fd2data>
  801f54:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f56:	83 c4 10             	add    $0x10,%esp
  801f59:	bf 00 00 00 00       	mov    $0x0,%edi
  801f5e:	eb 4b                	jmp    801fab <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801f60:	89 da                	mov    %ebx,%edx
  801f62:	89 f0                	mov    %esi,%eax
  801f64:	e8 6d ff ff ff       	call   801ed6 <_pipeisclosed>
  801f69:	85 c0                	test   %eax,%eax
  801f6b:	75 48                	jne    801fb5 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801f6d:	e8 83 ec ff ff       	call   800bf5 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f72:	8b 43 04             	mov    0x4(%ebx),%eax
  801f75:	8b 0b                	mov    (%ebx),%ecx
  801f77:	8d 51 20             	lea    0x20(%ecx),%edx
  801f7a:	39 d0                	cmp    %edx,%eax
  801f7c:	73 e2                	jae    801f60 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f7e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f81:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801f85:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801f88:	89 c2                	mov    %eax,%edx
  801f8a:	c1 fa 1f             	sar    $0x1f,%edx
  801f8d:	89 d1                	mov    %edx,%ecx
  801f8f:	c1 e9 1b             	shr    $0x1b,%ecx
  801f92:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801f95:	83 e2 1f             	and    $0x1f,%edx
  801f98:	29 ca                	sub    %ecx,%edx
  801f9a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801f9e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801fa2:	83 c0 01             	add    $0x1,%eax
  801fa5:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fa8:	83 c7 01             	add    $0x1,%edi
  801fab:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801fae:	75 c2                	jne    801f72 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801fb0:	8b 45 10             	mov    0x10(%ebp),%eax
  801fb3:	eb 05                	jmp    801fba <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801fb5:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801fba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fbd:	5b                   	pop    %ebx
  801fbe:	5e                   	pop    %esi
  801fbf:	5f                   	pop    %edi
  801fc0:	5d                   	pop    %ebp
  801fc1:	c3                   	ret    

00801fc2 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801fc2:	55                   	push   %ebp
  801fc3:	89 e5                	mov    %esp,%ebp
  801fc5:	57                   	push   %edi
  801fc6:	56                   	push   %esi
  801fc7:	53                   	push   %ebx
  801fc8:	83 ec 18             	sub    $0x18,%esp
  801fcb:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801fce:	57                   	push   %edi
  801fcf:	e8 ff f1 ff ff       	call   8011d3 <fd2data>
  801fd4:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fd6:	83 c4 10             	add    $0x10,%esp
  801fd9:	bb 00 00 00 00       	mov    $0x0,%ebx
  801fde:	eb 3d                	jmp    80201d <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801fe0:	85 db                	test   %ebx,%ebx
  801fe2:	74 04                	je     801fe8 <devpipe_read+0x26>
				return i;
  801fe4:	89 d8                	mov    %ebx,%eax
  801fe6:	eb 44                	jmp    80202c <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801fe8:	89 f2                	mov    %esi,%edx
  801fea:	89 f8                	mov    %edi,%eax
  801fec:	e8 e5 fe ff ff       	call   801ed6 <_pipeisclosed>
  801ff1:	85 c0                	test   %eax,%eax
  801ff3:	75 32                	jne    802027 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801ff5:	e8 fb eb ff ff       	call   800bf5 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ffa:	8b 06                	mov    (%esi),%eax
  801ffc:	3b 46 04             	cmp    0x4(%esi),%eax
  801fff:	74 df                	je     801fe0 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802001:	99                   	cltd   
  802002:	c1 ea 1b             	shr    $0x1b,%edx
  802005:	01 d0                	add    %edx,%eax
  802007:	83 e0 1f             	and    $0x1f,%eax
  80200a:	29 d0                	sub    %edx,%eax
  80200c:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802011:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802014:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802017:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80201a:	83 c3 01             	add    $0x1,%ebx
  80201d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802020:	75 d8                	jne    801ffa <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802022:	8b 45 10             	mov    0x10(%ebp),%eax
  802025:	eb 05                	jmp    80202c <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802027:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80202c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80202f:	5b                   	pop    %ebx
  802030:	5e                   	pop    %esi
  802031:	5f                   	pop    %edi
  802032:	5d                   	pop    %ebp
  802033:	c3                   	ret    

00802034 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802034:	55                   	push   %ebp
  802035:	89 e5                	mov    %esp,%ebp
  802037:	56                   	push   %esi
  802038:	53                   	push   %ebx
  802039:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80203c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80203f:	50                   	push   %eax
  802040:	e8 a5 f1 ff ff       	call   8011ea <fd_alloc>
  802045:	83 c4 10             	add    $0x10,%esp
  802048:	89 c2                	mov    %eax,%edx
  80204a:	85 c0                	test   %eax,%eax
  80204c:	0f 88 2c 01 00 00    	js     80217e <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802052:	83 ec 04             	sub    $0x4,%esp
  802055:	68 07 04 00 00       	push   $0x407
  80205a:	ff 75 f4             	pushl  -0xc(%ebp)
  80205d:	6a 00                	push   $0x0
  80205f:	e8 b0 eb ff ff       	call   800c14 <sys_page_alloc>
  802064:	83 c4 10             	add    $0x10,%esp
  802067:	89 c2                	mov    %eax,%edx
  802069:	85 c0                	test   %eax,%eax
  80206b:	0f 88 0d 01 00 00    	js     80217e <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802071:	83 ec 0c             	sub    $0xc,%esp
  802074:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802077:	50                   	push   %eax
  802078:	e8 6d f1 ff ff       	call   8011ea <fd_alloc>
  80207d:	89 c3                	mov    %eax,%ebx
  80207f:	83 c4 10             	add    $0x10,%esp
  802082:	85 c0                	test   %eax,%eax
  802084:	0f 88 e2 00 00 00    	js     80216c <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80208a:	83 ec 04             	sub    $0x4,%esp
  80208d:	68 07 04 00 00       	push   $0x407
  802092:	ff 75 f0             	pushl  -0x10(%ebp)
  802095:	6a 00                	push   $0x0
  802097:	e8 78 eb ff ff       	call   800c14 <sys_page_alloc>
  80209c:	89 c3                	mov    %eax,%ebx
  80209e:	83 c4 10             	add    $0x10,%esp
  8020a1:	85 c0                	test   %eax,%eax
  8020a3:	0f 88 c3 00 00 00    	js     80216c <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8020a9:	83 ec 0c             	sub    $0xc,%esp
  8020ac:	ff 75 f4             	pushl  -0xc(%ebp)
  8020af:	e8 1f f1 ff ff       	call   8011d3 <fd2data>
  8020b4:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020b6:	83 c4 0c             	add    $0xc,%esp
  8020b9:	68 07 04 00 00       	push   $0x407
  8020be:	50                   	push   %eax
  8020bf:	6a 00                	push   $0x0
  8020c1:	e8 4e eb ff ff       	call   800c14 <sys_page_alloc>
  8020c6:	89 c3                	mov    %eax,%ebx
  8020c8:	83 c4 10             	add    $0x10,%esp
  8020cb:	85 c0                	test   %eax,%eax
  8020cd:	0f 88 89 00 00 00    	js     80215c <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020d3:	83 ec 0c             	sub    $0xc,%esp
  8020d6:	ff 75 f0             	pushl  -0x10(%ebp)
  8020d9:	e8 f5 f0 ff ff       	call   8011d3 <fd2data>
  8020de:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8020e5:	50                   	push   %eax
  8020e6:	6a 00                	push   $0x0
  8020e8:	56                   	push   %esi
  8020e9:	6a 00                	push   $0x0
  8020eb:	e8 67 eb ff ff       	call   800c57 <sys_page_map>
  8020f0:	89 c3                	mov    %eax,%ebx
  8020f2:	83 c4 20             	add    $0x20,%esp
  8020f5:	85 c0                	test   %eax,%eax
  8020f7:	78 55                	js     80214e <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8020f9:	8b 15 44 30 80 00    	mov    0x803044,%edx
  8020ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802102:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802104:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802107:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80210e:	8b 15 44 30 80 00    	mov    0x803044,%edx
  802114:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802117:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802119:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80211c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802123:	83 ec 0c             	sub    $0xc,%esp
  802126:	ff 75 f4             	pushl  -0xc(%ebp)
  802129:	e8 95 f0 ff ff       	call   8011c3 <fd2num>
  80212e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802131:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802133:	83 c4 04             	add    $0x4,%esp
  802136:	ff 75 f0             	pushl  -0x10(%ebp)
  802139:	e8 85 f0 ff ff       	call   8011c3 <fd2num>
  80213e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802141:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802144:	83 c4 10             	add    $0x10,%esp
  802147:	ba 00 00 00 00       	mov    $0x0,%edx
  80214c:	eb 30                	jmp    80217e <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80214e:	83 ec 08             	sub    $0x8,%esp
  802151:	56                   	push   %esi
  802152:	6a 00                	push   $0x0
  802154:	e8 40 eb ff ff       	call   800c99 <sys_page_unmap>
  802159:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80215c:	83 ec 08             	sub    $0x8,%esp
  80215f:	ff 75 f0             	pushl  -0x10(%ebp)
  802162:	6a 00                	push   $0x0
  802164:	e8 30 eb ff ff       	call   800c99 <sys_page_unmap>
  802169:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80216c:	83 ec 08             	sub    $0x8,%esp
  80216f:	ff 75 f4             	pushl  -0xc(%ebp)
  802172:	6a 00                	push   $0x0
  802174:	e8 20 eb ff ff       	call   800c99 <sys_page_unmap>
  802179:	83 c4 10             	add    $0x10,%esp
  80217c:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80217e:	89 d0                	mov    %edx,%eax
  802180:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802183:	5b                   	pop    %ebx
  802184:	5e                   	pop    %esi
  802185:	5d                   	pop    %ebp
  802186:	c3                   	ret    

00802187 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802187:	55                   	push   %ebp
  802188:	89 e5                	mov    %esp,%ebp
  80218a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80218d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802190:	50                   	push   %eax
  802191:	ff 75 08             	pushl  0x8(%ebp)
  802194:	e8 a0 f0 ff ff       	call   801239 <fd_lookup>
  802199:	83 c4 10             	add    $0x10,%esp
  80219c:	85 c0                	test   %eax,%eax
  80219e:	78 18                	js     8021b8 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8021a0:	83 ec 0c             	sub    $0xc,%esp
  8021a3:	ff 75 f4             	pushl  -0xc(%ebp)
  8021a6:	e8 28 f0 ff ff       	call   8011d3 <fd2data>
	return _pipeisclosed(fd, p);
  8021ab:	89 c2                	mov    %eax,%edx
  8021ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021b0:	e8 21 fd ff ff       	call   801ed6 <_pipeisclosed>
  8021b5:	83 c4 10             	add    $0x10,%esp
}
  8021b8:	c9                   	leave  
  8021b9:	c3                   	ret    

008021ba <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8021ba:	55                   	push   %ebp
  8021bb:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8021bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8021c2:	5d                   	pop    %ebp
  8021c3:	c3                   	ret    

008021c4 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8021c4:	55                   	push   %ebp
  8021c5:	89 e5                	mov    %esp,%ebp
  8021c7:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8021ca:	68 67 2c 80 00       	push   $0x802c67
  8021cf:	ff 75 0c             	pushl  0xc(%ebp)
  8021d2:	e8 3a e6 ff ff       	call   800811 <strcpy>
	return 0;
}
  8021d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8021dc:	c9                   	leave  
  8021dd:	c3                   	ret    

008021de <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8021de:	55                   	push   %ebp
  8021df:	89 e5                	mov    %esp,%ebp
  8021e1:	57                   	push   %edi
  8021e2:	56                   	push   %esi
  8021e3:	53                   	push   %ebx
  8021e4:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021ea:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8021ef:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021f5:	eb 2d                	jmp    802224 <devcons_write+0x46>
		m = n - tot;
  8021f7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8021fa:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8021fc:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8021ff:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802204:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802207:	83 ec 04             	sub    $0x4,%esp
  80220a:	53                   	push   %ebx
  80220b:	03 45 0c             	add    0xc(%ebp),%eax
  80220e:	50                   	push   %eax
  80220f:	57                   	push   %edi
  802210:	e8 8e e7 ff ff       	call   8009a3 <memmove>
		sys_cputs(buf, m);
  802215:	83 c4 08             	add    $0x8,%esp
  802218:	53                   	push   %ebx
  802219:	57                   	push   %edi
  80221a:	e8 39 e9 ff ff       	call   800b58 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80221f:	01 de                	add    %ebx,%esi
  802221:	83 c4 10             	add    $0x10,%esp
  802224:	89 f0                	mov    %esi,%eax
  802226:	3b 75 10             	cmp    0x10(%ebp),%esi
  802229:	72 cc                	jb     8021f7 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80222b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80222e:	5b                   	pop    %ebx
  80222f:	5e                   	pop    %esi
  802230:	5f                   	pop    %edi
  802231:	5d                   	pop    %ebp
  802232:	c3                   	ret    

00802233 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802233:	55                   	push   %ebp
  802234:	89 e5                	mov    %esp,%ebp
  802236:	83 ec 08             	sub    $0x8,%esp
  802239:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80223e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802242:	74 2a                	je     80226e <devcons_read+0x3b>
  802244:	eb 05                	jmp    80224b <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802246:	e8 aa e9 ff ff       	call   800bf5 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80224b:	e8 26 e9 ff ff       	call   800b76 <sys_cgetc>
  802250:	85 c0                	test   %eax,%eax
  802252:	74 f2                	je     802246 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802254:	85 c0                	test   %eax,%eax
  802256:	78 16                	js     80226e <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802258:	83 f8 04             	cmp    $0x4,%eax
  80225b:	74 0c                	je     802269 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80225d:	8b 55 0c             	mov    0xc(%ebp),%edx
  802260:	88 02                	mov    %al,(%edx)
	return 1;
  802262:	b8 01 00 00 00       	mov    $0x1,%eax
  802267:	eb 05                	jmp    80226e <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802269:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80226e:	c9                   	leave  
  80226f:	c3                   	ret    

00802270 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802270:	55                   	push   %ebp
  802271:	89 e5                	mov    %esp,%ebp
  802273:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802276:	8b 45 08             	mov    0x8(%ebp),%eax
  802279:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80227c:	6a 01                	push   $0x1
  80227e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802281:	50                   	push   %eax
  802282:	e8 d1 e8 ff ff       	call   800b58 <sys_cputs>
}
  802287:	83 c4 10             	add    $0x10,%esp
  80228a:	c9                   	leave  
  80228b:	c3                   	ret    

0080228c <getchar>:

int
getchar(void)
{
  80228c:	55                   	push   %ebp
  80228d:	89 e5                	mov    %esp,%ebp
  80228f:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802292:	6a 01                	push   $0x1
  802294:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802297:	50                   	push   %eax
  802298:	6a 00                	push   $0x0
  80229a:	e8 00 f2 ff ff       	call   80149f <read>
	if (r < 0)
  80229f:	83 c4 10             	add    $0x10,%esp
  8022a2:	85 c0                	test   %eax,%eax
  8022a4:	78 0f                	js     8022b5 <getchar+0x29>
		return r;
	if (r < 1)
  8022a6:	85 c0                	test   %eax,%eax
  8022a8:	7e 06                	jle    8022b0 <getchar+0x24>
		return -E_EOF;
	return c;
  8022aa:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8022ae:	eb 05                	jmp    8022b5 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8022b0:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8022b5:	c9                   	leave  
  8022b6:	c3                   	ret    

008022b7 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8022b7:	55                   	push   %ebp
  8022b8:	89 e5                	mov    %esp,%ebp
  8022ba:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8022bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022c0:	50                   	push   %eax
  8022c1:	ff 75 08             	pushl  0x8(%ebp)
  8022c4:	e8 70 ef ff ff       	call   801239 <fd_lookup>
  8022c9:	83 c4 10             	add    $0x10,%esp
  8022cc:	85 c0                	test   %eax,%eax
  8022ce:	78 11                	js     8022e1 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8022d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022d3:	8b 15 60 30 80 00    	mov    0x803060,%edx
  8022d9:	39 10                	cmp    %edx,(%eax)
  8022db:	0f 94 c0             	sete   %al
  8022de:	0f b6 c0             	movzbl %al,%eax
}
  8022e1:	c9                   	leave  
  8022e2:	c3                   	ret    

008022e3 <opencons>:

int
opencons(void)
{
  8022e3:	55                   	push   %ebp
  8022e4:	89 e5                	mov    %esp,%ebp
  8022e6:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8022e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022ec:	50                   	push   %eax
  8022ed:	e8 f8 ee ff ff       	call   8011ea <fd_alloc>
  8022f2:	83 c4 10             	add    $0x10,%esp
		return r;
  8022f5:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8022f7:	85 c0                	test   %eax,%eax
  8022f9:	78 3e                	js     802339 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8022fb:	83 ec 04             	sub    $0x4,%esp
  8022fe:	68 07 04 00 00       	push   $0x407
  802303:	ff 75 f4             	pushl  -0xc(%ebp)
  802306:	6a 00                	push   $0x0
  802308:	e8 07 e9 ff ff       	call   800c14 <sys_page_alloc>
  80230d:	83 c4 10             	add    $0x10,%esp
		return r;
  802310:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802312:	85 c0                	test   %eax,%eax
  802314:	78 23                	js     802339 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802316:	8b 15 60 30 80 00    	mov    0x803060,%edx
  80231c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80231f:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802321:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802324:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80232b:	83 ec 0c             	sub    $0xc,%esp
  80232e:	50                   	push   %eax
  80232f:	e8 8f ee ff ff       	call   8011c3 <fd2num>
  802334:	89 c2                	mov    %eax,%edx
  802336:	83 c4 10             	add    $0x10,%esp
}
  802339:	89 d0                	mov    %edx,%eax
  80233b:	c9                   	leave  
  80233c:	c3                   	ret    

0080233d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80233d:	55                   	push   %ebp
  80233e:	89 e5                	mov    %esp,%ebp
  802340:	56                   	push   %esi
  802341:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  802342:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  802345:	8b 35 08 30 80 00    	mov    0x803008,%esi
  80234b:	e8 86 e8 ff ff       	call   800bd6 <sys_getenvid>
  802350:	83 ec 0c             	sub    $0xc,%esp
  802353:	ff 75 0c             	pushl  0xc(%ebp)
  802356:	ff 75 08             	pushl  0x8(%ebp)
  802359:	56                   	push   %esi
  80235a:	50                   	push   %eax
  80235b:	68 74 2c 80 00       	push   $0x802c74
  802360:	e8 27 df ff ff       	call   80028c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  802365:	83 c4 18             	add    $0x18,%esp
  802368:	53                   	push   %ebx
  802369:	ff 75 10             	pushl  0x10(%ebp)
  80236c:	e8 ca de ff ff       	call   80023b <vcprintf>
	cprintf("\n");
  802371:	c7 04 24 60 2c 80 00 	movl   $0x802c60,(%esp)
  802378:	e8 0f df ff ff       	call   80028c <cprintf>
  80237d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802380:	cc                   	int3   
  802381:	eb fd                	jmp    802380 <_panic+0x43>

00802383 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802383:	55                   	push   %ebp
  802384:	89 e5                	mov    %esp,%ebp
  802386:	53                   	push   %ebx
  802387:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  80238a:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802391:	75 28                	jne    8023bb <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  802393:	e8 3e e8 ff ff       	call   800bd6 <sys_getenvid>
  802398:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_U | PTE_W);
  80239a:	83 ec 04             	sub    $0x4,%esp
  80239d:	6a 06                	push   $0x6
  80239f:	68 00 f0 bf ee       	push   $0xeebff000
  8023a4:	50                   	push   %eax
  8023a5:	e8 6a e8 ff ff       	call   800c14 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  8023aa:	83 c4 08             	add    $0x8,%esp
  8023ad:	68 c8 23 80 00       	push   $0x8023c8
  8023b2:	53                   	push   %ebx
  8023b3:	e8 a7 e9 ff ff       	call   800d5f <sys_env_set_pgfault_upcall>
  8023b8:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8023bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8023be:	a3 00 70 80 00       	mov    %eax,0x807000
}
  8023c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8023c6:	c9                   	leave  
  8023c7:	c3                   	ret    

008023c8 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8023c8:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8023c9:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8023ce:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8023d0:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	# My method is different. Copy the values to the other stack
	# in a convinient way, and then pop everything.
	movl %esp, %ebp		# ebp refers to the exception stack
  8023d3:	89 e5                	mov    %esp,%ebp
	movl 48(%ebp), %esp 	# go to other stack
  8023d5:	8b 65 30             	mov    0x30(%ebp),%esp

	pushl 40(%ebp)		# eip - ORDER SWITCHED WITH EFLAGS
  8023d8:	ff 75 28             	pushl  0x28(%ebp)
	pushl 44(%ebp)      	# eflags
  8023db:	ff 75 2c             	pushl  0x2c(%ebp)
	pushl 36(%ebp)		# all the 8 remaining regs
  8023de:	ff 75 24             	pushl  0x24(%ebp)
	pushl 32(%ebp)
  8023e1:	ff 75 20             	pushl  0x20(%ebp)
	pushl 28(%ebp)
  8023e4:	ff 75 1c             	pushl  0x1c(%ebp)
	pushl 24(%ebp)
  8023e7:	ff 75 18             	pushl  0x18(%ebp)
	pushl 20(%ebp)
  8023ea:	ff 75 14             	pushl  0x14(%ebp)
	pushl 16(%ebp)
  8023ed:	ff 75 10             	pushl  0x10(%ebp)
	pushl 12(%ebp)
  8023f0:	ff 75 0c             	pushl  0xc(%ebp)
	pushl 8(%ebp)
  8023f3:	ff 75 08             	pushl  0x8(%ebp)

	popal			# now just pop everything!
  8023f6:	61                   	popa   
	popfl
  8023f7:	9d                   	popf   
	ret
  8023f8:	c3                   	ret    

008023f9 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8023f9:	55                   	push   %ebp
  8023fa:	89 e5                	mov    %esp,%ebp
  8023fc:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023ff:	89 d0                	mov    %edx,%eax
  802401:	c1 e8 16             	shr    $0x16,%eax
  802404:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80240b:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802410:	f6 c1 01             	test   $0x1,%cl
  802413:	74 1d                	je     802432 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802415:	c1 ea 0c             	shr    $0xc,%edx
  802418:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80241f:	f6 c2 01             	test   $0x1,%dl
  802422:	74 0e                	je     802432 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802424:	c1 ea 0c             	shr    $0xc,%edx
  802427:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80242e:	ef 
  80242f:	0f b7 c0             	movzwl %ax,%eax
}
  802432:	5d                   	pop    %ebp
  802433:	c3                   	ret    
  802434:	66 90                	xchg   %ax,%ax
  802436:	66 90                	xchg   %ax,%ax
  802438:	66 90                	xchg   %ax,%ax
  80243a:	66 90                	xchg   %ax,%ax
  80243c:	66 90                	xchg   %ax,%ax
  80243e:	66 90                	xchg   %ax,%ax

00802440 <__udivdi3>:
  802440:	55                   	push   %ebp
  802441:	57                   	push   %edi
  802442:	56                   	push   %esi
  802443:	53                   	push   %ebx
  802444:	83 ec 1c             	sub    $0x1c,%esp
  802447:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80244b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80244f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802453:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802457:	85 f6                	test   %esi,%esi
  802459:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80245d:	89 ca                	mov    %ecx,%edx
  80245f:	89 f8                	mov    %edi,%eax
  802461:	75 3d                	jne    8024a0 <__udivdi3+0x60>
  802463:	39 cf                	cmp    %ecx,%edi
  802465:	0f 87 c5 00 00 00    	ja     802530 <__udivdi3+0xf0>
  80246b:	85 ff                	test   %edi,%edi
  80246d:	89 fd                	mov    %edi,%ebp
  80246f:	75 0b                	jne    80247c <__udivdi3+0x3c>
  802471:	b8 01 00 00 00       	mov    $0x1,%eax
  802476:	31 d2                	xor    %edx,%edx
  802478:	f7 f7                	div    %edi
  80247a:	89 c5                	mov    %eax,%ebp
  80247c:	89 c8                	mov    %ecx,%eax
  80247e:	31 d2                	xor    %edx,%edx
  802480:	f7 f5                	div    %ebp
  802482:	89 c1                	mov    %eax,%ecx
  802484:	89 d8                	mov    %ebx,%eax
  802486:	89 cf                	mov    %ecx,%edi
  802488:	f7 f5                	div    %ebp
  80248a:	89 c3                	mov    %eax,%ebx
  80248c:	89 d8                	mov    %ebx,%eax
  80248e:	89 fa                	mov    %edi,%edx
  802490:	83 c4 1c             	add    $0x1c,%esp
  802493:	5b                   	pop    %ebx
  802494:	5e                   	pop    %esi
  802495:	5f                   	pop    %edi
  802496:	5d                   	pop    %ebp
  802497:	c3                   	ret    
  802498:	90                   	nop
  802499:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024a0:	39 ce                	cmp    %ecx,%esi
  8024a2:	77 74                	ja     802518 <__udivdi3+0xd8>
  8024a4:	0f bd fe             	bsr    %esi,%edi
  8024a7:	83 f7 1f             	xor    $0x1f,%edi
  8024aa:	0f 84 98 00 00 00    	je     802548 <__udivdi3+0x108>
  8024b0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8024b5:	89 f9                	mov    %edi,%ecx
  8024b7:	89 c5                	mov    %eax,%ebp
  8024b9:	29 fb                	sub    %edi,%ebx
  8024bb:	d3 e6                	shl    %cl,%esi
  8024bd:	89 d9                	mov    %ebx,%ecx
  8024bf:	d3 ed                	shr    %cl,%ebp
  8024c1:	89 f9                	mov    %edi,%ecx
  8024c3:	d3 e0                	shl    %cl,%eax
  8024c5:	09 ee                	or     %ebp,%esi
  8024c7:	89 d9                	mov    %ebx,%ecx
  8024c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024cd:	89 d5                	mov    %edx,%ebp
  8024cf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8024d3:	d3 ed                	shr    %cl,%ebp
  8024d5:	89 f9                	mov    %edi,%ecx
  8024d7:	d3 e2                	shl    %cl,%edx
  8024d9:	89 d9                	mov    %ebx,%ecx
  8024db:	d3 e8                	shr    %cl,%eax
  8024dd:	09 c2                	or     %eax,%edx
  8024df:	89 d0                	mov    %edx,%eax
  8024e1:	89 ea                	mov    %ebp,%edx
  8024e3:	f7 f6                	div    %esi
  8024e5:	89 d5                	mov    %edx,%ebp
  8024e7:	89 c3                	mov    %eax,%ebx
  8024e9:	f7 64 24 0c          	mull   0xc(%esp)
  8024ed:	39 d5                	cmp    %edx,%ebp
  8024ef:	72 10                	jb     802501 <__udivdi3+0xc1>
  8024f1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8024f5:	89 f9                	mov    %edi,%ecx
  8024f7:	d3 e6                	shl    %cl,%esi
  8024f9:	39 c6                	cmp    %eax,%esi
  8024fb:	73 07                	jae    802504 <__udivdi3+0xc4>
  8024fd:	39 d5                	cmp    %edx,%ebp
  8024ff:	75 03                	jne    802504 <__udivdi3+0xc4>
  802501:	83 eb 01             	sub    $0x1,%ebx
  802504:	31 ff                	xor    %edi,%edi
  802506:	89 d8                	mov    %ebx,%eax
  802508:	89 fa                	mov    %edi,%edx
  80250a:	83 c4 1c             	add    $0x1c,%esp
  80250d:	5b                   	pop    %ebx
  80250e:	5e                   	pop    %esi
  80250f:	5f                   	pop    %edi
  802510:	5d                   	pop    %ebp
  802511:	c3                   	ret    
  802512:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802518:	31 ff                	xor    %edi,%edi
  80251a:	31 db                	xor    %ebx,%ebx
  80251c:	89 d8                	mov    %ebx,%eax
  80251e:	89 fa                	mov    %edi,%edx
  802520:	83 c4 1c             	add    $0x1c,%esp
  802523:	5b                   	pop    %ebx
  802524:	5e                   	pop    %esi
  802525:	5f                   	pop    %edi
  802526:	5d                   	pop    %ebp
  802527:	c3                   	ret    
  802528:	90                   	nop
  802529:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802530:	89 d8                	mov    %ebx,%eax
  802532:	f7 f7                	div    %edi
  802534:	31 ff                	xor    %edi,%edi
  802536:	89 c3                	mov    %eax,%ebx
  802538:	89 d8                	mov    %ebx,%eax
  80253a:	89 fa                	mov    %edi,%edx
  80253c:	83 c4 1c             	add    $0x1c,%esp
  80253f:	5b                   	pop    %ebx
  802540:	5e                   	pop    %esi
  802541:	5f                   	pop    %edi
  802542:	5d                   	pop    %ebp
  802543:	c3                   	ret    
  802544:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802548:	39 ce                	cmp    %ecx,%esi
  80254a:	72 0c                	jb     802558 <__udivdi3+0x118>
  80254c:	31 db                	xor    %ebx,%ebx
  80254e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802552:	0f 87 34 ff ff ff    	ja     80248c <__udivdi3+0x4c>
  802558:	bb 01 00 00 00       	mov    $0x1,%ebx
  80255d:	e9 2a ff ff ff       	jmp    80248c <__udivdi3+0x4c>
  802562:	66 90                	xchg   %ax,%ax
  802564:	66 90                	xchg   %ax,%ax
  802566:	66 90                	xchg   %ax,%ax
  802568:	66 90                	xchg   %ax,%ax
  80256a:	66 90                	xchg   %ax,%ax
  80256c:	66 90                	xchg   %ax,%ax
  80256e:	66 90                	xchg   %ax,%ax

00802570 <__umoddi3>:
  802570:	55                   	push   %ebp
  802571:	57                   	push   %edi
  802572:	56                   	push   %esi
  802573:	53                   	push   %ebx
  802574:	83 ec 1c             	sub    $0x1c,%esp
  802577:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80257b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80257f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802583:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802587:	85 d2                	test   %edx,%edx
  802589:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80258d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802591:	89 f3                	mov    %esi,%ebx
  802593:	89 3c 24             	mov    %edi,(%esp)
  802596:	89 74 24 04          	mov    %esi,0x4(%esp)
  80259a:	75 1c                	jne    8025b8 <__umoddi3+0x48>
  80259c:	39 f7                	cmp    %esi,%edi
  80259e:	76 50                	jbe    8025f0 <__umoddi3+0x80>
  8025a0:	89 c8                	mov    %ecx,%eax
  8025a2:	89 f2                	mov    %esi,%edx
  8025a4:	f7 f7                	div    %edi
  8025a6:	89 d0                	mov    %edx,%eax
  8025a8:	31 d2                	xor    %edx,%edx
  8025aa:	83 c4 1c             	add    $0x1c,%esp
  8025ad:	5b                   	pop    %ebx
  8025ae:	5e                   	pop    %esi
  8025af:	5f                   	pop    %edi
  8025b0:	5d                   	pop    %ebp
  8025b1:	c3                   	ret    
  8025b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8025b8:	39 f2                	cmp    %esi,%edx
  8025ba:	89 d0                	mov    %edx,%eax
  8025bc:	77 52                	ja     802610 <__umoddi3+0xa0>
  8025be:	0f bd ea             	bsr    %edx,%ebp
  8025c1:	83 f5 1f             	xor    $0x1f,%ebp
  8025c4:	75 5a                	jne    802620 <__umoddi3+0xb0>
  8025c6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8025ca:	0f 82 e0 00 00 00    	jb     8026b0 <__umoddi3+0x140>
  8025d0:	39 0c 24             	cmp    %ecx,(%esp)
  8025d3:	0f 86 d7 00 00 00    	jbe    8026b0 <__umoddi3+0x140>
  8025d9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8025dd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8025e1:	83 c4 1c             	add    $0x1c,%esp
  8025e4:	5b                   	pop    %ebx
  8025e5:	5e                   	pop    %esi
  8025e6:	5f                   	pop    %edi
  8025e7:	5d                   	pop    %ebp
  8025e8:	c3                   	ret    
  8025e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025f0:	85 ff                	test   %edi,%edi
  8025f2:	89 fd                	mov    %edi,%ebp
  8025f4:	75 0b                	jne    802601 <__umoddi3+0x91>
  8025f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8025fb:	31 d2                	xor    %edx,%edx
  8025fd:	f7 f7                	div    %edi
  8025ff:	89 c5                	mov    %eax,%ebp
  802601:	89 f0                	mov    %esi,%eax
  802603:	31 d2                	xor    %edx,%edx
  802605:	f7 f5                	div    %ebp
  802607:	89 c8                	mov    %ecx,%eax
  802609:	f7 f5                	div    %ebp
  80260b:	89 d0                	mov    %edx,%eax
  80260d:	eb 99                	jmp    8025a8 <__umoddi3+0x38>
  80260f:	90                   	nop
  802610:	89 c8                	mov    %ecx,%eax
  802612:	89 f2                	mov    %esi,%edx
  802614:	83 c4 1c             	add    $0x1c,%esp
  802617:	5b                   	pop    %ebx
  802618:	5e                   	pop    %esi
  802619:	5f                   	pop    %edi
  80261a:	5d                   	pop    %ebp
  80261b:	c3                   	ret    
  80261c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802620:	8b 34 24             	mov    (%esp),%esi
  802623:	bf 20 00 00 00       	mov    $0x20,%edi
  802628:	89 e9                	mov    %ebp,%ecx
  80262a:	29 ef                	sub    %ebp,%edi
  80262c:	d3 e0                	shl    %cl,%eax
  80262e:	89 f9                	mov    %edi,%ecx
  802630:	89 f2                	mov    %esi,%edx
  802632:	d3 ea                	shr    %cl,%edx
  802634:	89 e9                	mov    %ebp,%ecx
  802636:	09 c2                	or     %eax,%edx
  802638:	89 d8                	mov    %ebx,%eax
  80263a:	89 14 24             	mov    %edx,(%esp)
  80263d:	89 f2                	mov    %esi,%edx
  80263f:	d3 e2                	shl    %cl,%edx
  802641:	89 f9                	mov    %edi,%ecx
  802643:	89 54 24 04          	mov    %edx,0x4(%esp)
  802647:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80264b:	d3 e8                	shr    %cl,%eax
  80264d:	89 e9                	mov    %ebp,%ecx
  80264f:	89 c6                	mov    %eax,%esi
  802651:	d3 e3                	shl    %cl,%ebx
  802653:	89 f9                	mov    %edi,%ecx
  802655:	89 d0                	mov    %edx,%eax
  802657:	d3 e8                	shr    %cl,%eax
  802659:	89 e9                	mov    %ebp,%ecx
  80265b:	09 d8                	or     %ebx,%eax
  80265d:	89 d3                	mov    %edx,%ebx
  80265f:	89 f2                	mov    %esi,%edx
  802661:	f7 34 24             	divl   (%esp)
  802664:	89 d6                	mov    %edx,%esi
  802666:	d3 e3                	shl    %cl,%ebx
  802668:	f7 64 24 04          	mull   0x4(%esp)
  80266c:	39 d6                	cmp    %edx,%esi
  80266e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802672:	89 d1                	mov    %edx,%ecx
  802674:	89 c3                	mov    %eax,%ebx
  802676:	72 08                	jb     802680 <__umoddi3+0x110>
  802678:	75 11                	jne    80268b <__umoddi3+0x11b>
  80267a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80267e:	73 0b                	jae    80268b <__umoddi3+0x11b>
  802680:	2b 44 24 04          	sub    0x4(%esp),%eax
  802684:	1b 14 24             	sbb    (%esp),%edx
  802687:	89 d1                	mov    %edx,%ecx
  802689:	89 c3                	mov    %eax,%ebx
  80268b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80268f:	29 da                	sub    %ebx,%edx
  802691:	19 ce                	sbb    %ecx,%esi
  802693:	89 f9                	mov    %edi,%ecx
  802695:	89 f0                	mov    %esi,%eax
  802697:	d3 e0                	shl    %cl,%eax
  802699:	89 e9                	mov    %ebp,%ecx
  80269b:	d3 ea                	shr    %cl,%edx
  80269d:	89 e9                	mov    %ebp,%ecx
  80269f:	d3 ee                	shr    %cl,%esi
  8026a1:	09 d0                	or     %edx,%eax
  8026a3:	89 f2                	mov    %esi,%edx
  8026a5:	83 c4 1c             	add    $0x1c,%esp
  8026a8:	5b                   	pop    %ebx
  8026a9:	5e                   	pop    %esi
  8026aa:	5f                   	pop    %edi
  8026ab:	5d                   	pop    %ebp
  8026ac:	c3                   	ret    
  8026ad:	8d 76 00             	lea    0x0(%esi),%esi
  8026b0:	29 f9                	sub    %edi,%ecx
  8026b2:	19 d6                	sbb    %edx,%esi
  8026b4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8026b8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8026bc:	e9 18 ff ff ff       	jmp    8025d9 <__umoddi3+0x69>
