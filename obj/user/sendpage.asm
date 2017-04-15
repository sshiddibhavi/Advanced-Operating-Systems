
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
  800039:	e8 7b 0f 00 00       	call   800fb9 <fork>
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
  800057:	e8 52 10 00 00       	call   8010ae <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  80005c:	83 c4 0c             	add    $0xc,%esp
  80005f:	68 00 00 b0 00       	push   $0xb00000
  800064:	ff 75 f4             	pushl  -0xc(%ebp)
  800067:	68 40 22 80 00       	push   $0x802240
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
  80009d:	68 54 22 80 00       	push   $0x802254
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
  8000db:	e8 37 10 00 00       	call   801117 <ipc_send>
		return;
  8000e0:	83 c4 20             	add    $0x20,%esp
  8000e3:	e9 af 00 00 00       	jmp    800197 <umain+0x164>
	}

	// Parent
	sys_page_alloc(thisenv->env_id, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  8000e8:	a1 04 40 80 00       	mov    0x804004,%eax
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
  800131:	e8 e1 0f 00 00       	call   801117 <ipc_send>

	ipc_recv(&who, TEMP_ADDR, 0);
  800136:	83 c4 1c             	add    $0x1c,%esp
  800139:	6a 00                	push   $0x0
  80013b:	68 00 00 a0 00       	push   $0xa00000
  800140:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800143:	50                   	push   %eax
  800144:	e8 65 0f 00 00       	call   8010ae <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  800149:	83 c4 0c             	add    $0xc,%esp
  80014c:	68 00 00 a0 00       	push   $0xa00000
  800151:	ff 75 f4             	pushl  -0xc(%ebp)
  800154:	68 40 22 80 00       	push   $0x802240
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
  80018a:	68 74 22 80 00       	push   $0x802274
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
  8001b6:	a3 04 40 80 00       	mov    %eax,0x804004

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
  8001e5:	e8 85 11 00 00       	call   80136f <close_all>
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
  8002ef:	e8 bc 1c 00 00       	call   801fb0 <__udivdi3>
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
  800332:	e8 a9 1d 00 00       	call   8020e0 <__umoddi3>
  800337:	83 c4 14             	add    $0x14,%esp
  80033a:	0f be 80 ec 22 80 00 	movsbl 0x8022ec(%eax),%eax
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
  800436:	ff 24 85 20 24 80 00 	jmp    *0x802420(,%eax,4)
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
  8004fa:	8b 14 85 80 25 80 00 	mov    0x802580(,%eax,4),%edx
  800501:	85 d2                	test   %edx,%edx
  800503:	75 18                	jne    80051d <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800505:	50                   	push   %eax
  800506:	68 04 23 80 00       	push   $0x802304
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
  80051e:	68 4a 27 80 00       	push   $0x80274a
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
  800542:	b8 fd 22 80 00       	mov    $0x8022fd,%eax
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
  800bbd:	68 df 25 80 00       	push   $0x8025df
  800bc2:	6a 23                	push   $0x23
  800bc4:	68 fc 25 80 00       	push   $0x8025fc
  800bc9:	e8 e9 12 00 00       	call   801eb7 <_panic>

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
  800c3e:	68 df 25 80 00       	push   $0x8025df
  800c43:	6a 23                	push   $0x23
  800c45:	68 fc 25 80 00       	push   $0x8025fc
  800c4a:	e8 68 12 00 00       	call   801eb7 <_panic>

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
  800c80:	68 df 25 80 00       	push   $0x8025df
  800c85:	6a 23                	push   $0x23
  800c87:	68 fc 25 80 00       	push   $0x8025fc
  800c8c:	e8 26 12 00 00       	call   801eb7 <_panic>

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
  800cc2:	68 df 25 80 00       	push   $0x8025df
  800cc7:	6a 23                	push   $0x23
  800cc9:	68 fc 25 80 00       	push   $0x8025fc
  800cce:	e8 e4 11 00 00       	call   801eb7 <_panic>

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
  800d04:	68 df 25 80 00       	push   $0x8025df
  800d09:	6a 23                	push   $0x23
  800d0b:	68 fc 25 80 00       	push   $0x8025fc
  800d10:	e8 a2 11 00 00       	call   801eb7 <_panic>

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
  800d46:	68 df 25 80 00       	push   $0x8025df
  800d4b:	6a 23                	push   $0x23
  800d4d:	68 fc 25 80 00       	push   $0x8025fc
  800d52:	e8 60 11 00 00       	call   801eb7 <_panic>

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
  800d88:	68 df 25 80 00       	push   $0x8025df
  800d8d:	6a 23                	push   $0x23
  800d8f:	68 fc 25 80 00       	push   $0x8025fc
  800d94:	e8 1e 11 00 00       	call   801eb7 <_panic>

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
  800dec:	68 df 25 80 00       	push   $0x8025df
  800df1:	6a 23                	push   $0x23
  800df3:	68 fc 25 80 00       	push   $0x8025fc
  800df8:	e8 ba 10 00 00       	call   801eb7 <_panic>

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

00800e05 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800e05:	55                   	push   %ebp
  800e06:	89 e5                	mov    %esp,%ebp
  800e08:	53                   	push   %ebx
  800e09:	83 ec 04             	sub    $0x4,%esp
	int r;
	void * address = (void *)(pn*PGSIZE);
  800e0c:	89 d3                	mov    %edx,%ebx
  800e0e:	c1 e3 0c             	shl    $0xc,%ebx
	
	if((uvpt[pn] & PTE_SHARE))
  800e11:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800e18:	f6 c5 04             	test   $0x4,%ch
  800e1b:	74 38                	je     800e55 <duppage+0x50>
	{
		if ((r = sys_page_map(0, address, envid, address, (uvpt[pn] | PTE_SYSCALL))) < 0)
  800e1d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e24:	83 ec 0c             	sub    $0xc,%esp
  800e27:	81 ca 07 0e 00 00    	or     $0xe07,%edx
  800e2d:	52                   	push   %edx
  800e2e:	53                   	push   %ebx
  800e2f:	50                   	push   %eax
  800e30:	53                   	push   %ebx
  800e31:	6a 00                	push   $0x0
  800e33:	e8 1f fe ff ff       	call   800c57 <sys_page_map>
  800e38:	83 c4 20             	add    $0x20,%esp
  800e3b:	85 c0                	test   %eax,%eax
  800e3d:	0f 89 b8 00 00 00    	jns    800efb <duppage+0xf6>
			panic("sys_page_map: %e", r);
  800e43:	50                   	push   %eax
  800e44:	68 0a 26 80 00       	push   $0x80260a
  800e49:	6a 4e                	push   $0x4e
  800e4b:	68 1b 26 80 00       	push   $0x80261b
  800e50:	e8 62 10 00 00       	call   801eb7 <_panic>
	}
	else if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW))
  800e55:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800e5c:	f6 c1 02             	test   $0x2,%cl
  800e5f:	75 0c                	jne    800e6d <duppage+0x68>
  800e61:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800e68:	f6 c5 08             	test   $0x8,%ch
  800e6b:	74 57                	je     800ec4 <duppage+0xbf>
	{
		int perm = 0;
		perm |= PTE_P|PTE_U|PTE_COW;
	
		if ((r = sys_page_map(0, address, envid, address, perm)) < 0)
  800e6d:	83 ec 0c             	sub    $0xc,%esp
  800e70:	68 05 08 00 00       	push   $0x805
  800e75:	53                   	push   %ebx
  800e76:	50                   	push   %eax
  800e77:	53                   	push   %ebx
  800e78:	6a 00                	push   $0x0
  800e7a:	e8 d8 fd ff ff       	call   800c57 <sys_page_map>
  800e7f:	83 c4 20             	add    $0x20,%esp
  800e82:	85 c0                	test   %eax,%eax
  800e84:	79 12                	jns    800e98 <duppage+0x93>
			panic("sys_page_map: %e", r);
  800e86:	50                   	push   %eax
  800e87:	68 0a 26 80 00       	push   $0x80260a
  800e8c:	6a 56                	push   $0x56
  800e8e:	68 1b 26 80 00       	push   $0x80261b
  800e93:	e8 1f 10 00 00       	call   801eb7 <_panic>
		if ((r = sys_page_map(0, address, 0, address, perm)) < 0)
  800e98:	83 ec 0c             	sub    $0xc,%esp
  800e9b:	68 05 08 00 00       	push   $0x805
  800ea0:	53                   	push   %ebx
  800ea1:	6a 00                	push   $0x0
  800ea3:	53                   	push   %ebx
  800ea4:	6a 00                	push   $0x0
  800ea6:	e8 ac fd ff ff       	call   800c57 <sys_page_map>
  800eab:	83 c4 20             	add    $0x20,%esp
  800eae:	85 c0                	test   %eax,%eax
  800eb0:	79 49                	jns    800efb <duppage+0xf6>
			panic("sys_page_map: %e", r);
  800eb2:	50                   	push   %eax
  800eb3:	68 0a 26 80 00       	push   $0x80260a
  800eb8:	6a 58                	push   $0x58
  800eba:	68 1b 26 80 00       	push   $0x80261b
  800ebf:	e8 f3 0f 00 00       	call   801eb7 <_panic>
	}
	else if((uvpt[pn] & ~PTE_U) == 0)
  800ec4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ecb:	f7 c2 fb ff ff ff    	test   $0xfffffffb,%edx
  800ed1:	75 28                	jne    800efb <duppage+0xf6>
	{
		//cprintf("im here");
		if ((r = sys_page_map(0, address, envid, address, PTE_P|PTE_U)) < 0)
  800ed3:	83 ec 0c             	sub    $0xc,%esp
  800ed6:	6a 05                	push   $0x5
  800ed8:	53                   	push   %ebx
  800ed9:	50                   	push   %eax
  800eda:	53                   	push   %ebx
  800edb:	6a 00                	push   $0x0
  800edd:	e8 75 fd ff ff       	call   800c57 <sys_page_map>
  800ee2:	83 c4 20             	add    $0x20,%esp
  800ee5:	85 c0                	test   %eax,%eax
  800ee7:	79 12                	jns    800efb <duppage+0xf6>
			panic("sys_page_map: %e", r);	
  800ee9:	50                   	push   %eax
  800eea:	68 0a 26 80 00       	push   $0x80260a
  800eef:	6a 5e                	push   $0x5e
  800ef1:	68 1b 26 80 00       	push   $0x80261b
  800ef6:	e8 bc 0f 00 00       	call   801eb7 <_panic>
	}
	return 0;
}
  800efb:	b8 00 00 00 00       	mov    $0x0,%eax
  800f00:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f03:	c9                   	leave  
  800f04:	c3                   	ret    

00800f05 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f05:	55                   	push   %ebp
  800f06:	89 e5                	mov    %esp,%ebp
  800f08:	53                   	push   %ebx
  800f09:	83 ec 08             	sub    $0x8,%esp
	void *addr = (void *) utf->utf_fault_va;
  800f0c:	8b 45 08             	mov    0x8(%ebp),%eax
  800f0f:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	unsigned pn = ((uint32_t)addr)/PGSIZE;
  800f11:	89 d8                	mov    %ebx,%eax
  800f13:	c1 e8 0c             	shr    $0xc,%eax
	pte_t pte = uvpt[pn];
  800f16:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// Allocate a new page, mapped at temp location
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  800f1d:	6a 07                	push   $0x7
  800f1f:	68 00 f0 7f 00       	push   $0x7ff000
  800f24:	6a 00                	push   $0x0
  800f26:	e8 e9 fc ff ff       	call   800c14 <sys_page_alloc>
  800f2b:	83 c4 10             	add    $0x10,%esp
  800f2e:	85 c0                	test   %eax,%eax
  800f30:	79 12                	jns    800f44 <pgfault+0x3f>
		panic("sys_page_alloc: %e", r);
  800f32:	50                   	push   %eax
  800f33:	68 26 26 80 00       	push   $0x802626
  800f38:	6a 2b                	push   $0x2b
  800f3a:	68 1b 26 80 00       	push   $0x80261b
  800f3f:	e8 73 0f 00 00       	call   801eb7 <_panic>

	// Copy the data from the old page to this new page
	void *addr_pgstart = (void *) ROUNDDOWN(addr, PGSIZE);
  800f44:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr_pgstart, PGSIZE);
  800f4a:	83 ec 04             	sub    $0x4,%esp
  800f4d:	68 00 10 00 00       	push   $0x1000
  800f52:	53                   	push   %ebx
  800f53:	68 00 f0 7f 00       	push   $0x7ff000
  800f58:	e8 46 fa ff ff       	call   8009a3 <memmove>

	// Move the new page to the old page's address
	if ((r = sys_page_map(0, PFTEMP, 0, addr_pgstart, PTE_P|PTE_U|PTE_W)) < 0)
  800f5d:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f64:	53                   	push   %ebx
  800f65:	6a 00                	push   $0x0
  800f67:	68 00 f0 7f 00       	push   $0x7ff000
  800f6c:	6a 00                	push   $0x0
  800f6e:	e8 e4 fc ff ff       	call   800c57 <sys_page_map>
  800f73:	83 c4 20             	add    $0x20,%esp
  800f76:	85 c0                	test   %eax,%eax
  800f78:	79 12                	jns    800f8c <pgfault+0x87>
		panic("sys_page_map: %e", r);
  800f7a:	50                   	push   %eax
  800f7b:	68 0a 26 80 00       	push   $0x80260a
  800f80:	6a 33                	push   $0x33
  800f82:	68 1b 26 80 00       	push   $0x80261b
  800f87:	e8 2b 0f 00 00       	call   801eb7 <_panic>

	// Unmap the temp location
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800f8c:	83 ec 08             	sub    $0x8,%esp
  800f8f:	68 00 f0 7f 00       	push   $0x7ff000
  800f94:	6a 00                	push   $0x0
  800f96:	e8 fe fc ff ff       	call   800c99 <sys_page_unmap>
  800f9b:	83 c4 10             	add    $0x10,%esp
  800f9e:	85 c0                	test   %eax,%eax
  800fa0:	79 12                	jns    800fb4 <pgfault+0xaf>
		panic("sys_page_unmap: %e", r);
  800fa2:	50                   	push   %eax
  800fa3:	68 39 26 80 00       	push   $0x802639
  800fa8:	6a 37                	push   $0x37
  800faa:	68 1b 26 80 00       	push   $0x80261b
  800faf:	e8 03 0f 00 00       	call   801eb7 <_panic>
}
  800fb4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fb7:	c9                   	leave  
  800fb8:	c3                   	ret    

00800fb9 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fb9:	55                   	push   %ebp
  800fba:	89 e5                	mov    %esp,%ebp
  800fbc:	56                   	push   %esi
  800fbd:	53                   	push   %ebx
  800fbe:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
	// Set up page fault handler
	set_pgfault_handler(&pgfault);
  800fc1:	68 05 0f 80 00       	push   $0x800f05
  800fc6:	e8 32 0f 00 00       	call   801efd <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800fcb:	b8 07 00 00 00       	mov    $0x7,%eax
  800fd0:	cd 30                	int    $0x30

	// Create child
	envid_t envid = sys_exofork();
  800fd2:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (envid < 0) {
  800fd5:	83 c4 10             	add    $0x10,%esp
  800fd8:	85 c0                	test   %eax,%eax
  800fda:	79 12                	jns    800fee <fork+0x35>
		panic("sys_exofork: %e", envid);
  800fdc:	50                   	push   %eax
  800fdd:	68 4c 26 80 00       	push   $0x80264c
  800fe2:	6a 7c                	push   $0x7c
  800fe4:	68 1b 26 80 00       	push   $0x80261b
  800fe9:	e8 c9 0e 00 00       	call   801eb7 <_panic>
		return envid;
	}
	if (envid == 0) {
  800fee:	85 c0                	test   %eax,%eax
  800ff0:	75 1e                	jne    801010 <fork+0x57>
		// We are the child.
		thisenv = &envs[ENVX(sys_getenvid())]; // Fix thisenv
  800ff2:	e8 df fb ff ff       	call   800bd6 <sys_getenvid>
  800ff7:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ffc:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800fff:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801004:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  801009:	b8 00 00 00 00       	mov    $0x0,%eax
  80100e:	eb 7d                	jmp    80108d <fork+0xd4>

	// Set page fault handler on the child.
	// The parent needs to do it, else the child wouldn't be able to handle
	// the fault when trying to access it's stack (which happens as soon it starts)
	extern void _pgfault_upcall(void);
	sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);
  801010:	83 ec 04             	sub    $0x4,%esp
  801013:	6a 07                	push   $0x7
  801015:	68 00 f0 bf ee       	push   $0xeebff000
  80101a:	50                   	push   %eax
  80101b:	e8 f4 fb ff ff       	call   800c14 <sys_page_alloc>
	sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  801020:	83 c4 08             	add    $0x8,%esp
  801023:	68 42 1f 80 00       	push   $0x801f42
  801028:	ff 75 f4             	pushl  -0xc(%ebp)
  80102b:	e8 2f fd ff ff       	call   800d5f <sys_env_set_pgfault_upcall>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  801030:	be 04 60 80 00       	mov    $0x806004,%esi
  801035:	c1 ee 0c             	shr    $0xc,%esi
  801038:	83 c4 10             	add    $0x10,%esp
  80103b:	bb 00 08 00 00       	mov    $0x800,%ebx
  801040:	eb 0d                	jmp    80104f <fork+0x96>
		duppage(envid, pn);
  801042:	89 da                	mov    %ebx,%edx
  801044:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801047:	e8 b9 fd ff ff       	call   800e05 <duppage>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  80104c:	83 c3 01             	add    $0x1,%ebx
  80104f:	39 f3                	cmp    %esi,%ebx
  801051:	76 ef                	jbe    801042 <fork+0x89>
	}

	// Also copy the stack we are currently running on
	// I think it should loop from ustacktop to this page, since the stack
	// can have more than 1 page
	duppage(envid, ((uint32_t) &envid)/PGSIZE);
  801053:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801056:	c1 ea 0c             	shr    $0xc,%edx
  801059:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80105c:	e8 a4 fd ff ff       	call   800e05 <duppage>

	// Start the child environmnet running
	int r;
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  801061:	83 ec 08             	sub    $0x8,%esp
  801064:	6a 02                	push   $0x2
  801066:	ff 75 f4             	pushl  -0xc(%ebp)
  801069:	e8 6d fc ff ff       	call   800cdb <sys_env_set_status>
  80106e:	83 c4 10             	add    $0x10,%esp
  801071:	85 c0                	test   %eax,%eax
  801073:	79 15                	jns    80108a <fork+0xd1>
		panic("sys_env_set_status: %e", r);
  801075:	50                   	push   %eax
  801076:	68 5c 26 80 00       	push   $0x80265c
  80107b:	68 9c 00 00 00       	push   $0x9c
  801080:	68 1b 26 80 00       	push   $0x80261b
  801085:	e8 2d 0e 00 00       	call   801eb7 <_panic>
		return r;
	}

	return envid;
  80108a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80108d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801090:	5b                   	pop    %ebx
  801091:	5e                   	pop    %esi
  801092:	5d                   	pop    %ebp
  801093:	c3                   	ret    

00801094 <sfork>:

// Challenge!
int
sfork(void)
{
  801094:	55                   	push   %ebp
  801095:	89 e5                	mov    %esp,%ebp
  801097:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80109a:	68 73 26 80 00       	push   $0x802673
  80109f:	68 a7 00 00 00       	push   $0xa7
  8010a4:	68 1b 26 80 00       	push   $0x80261b
  8010a9:	e8 09 0e 00 00       	call   801eb7 <_panic>

008010ae <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8010ae:	55                   	push   %ebp
  8010af:	89 e5                	mov    %esp,%ebp
  8010b1:	56                   	push   %esi
  8010b2:	53                   	push   %ebx
  8010b3:	8b 75 08             	mov    0x8(%ebp),%esi
  8010b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010b9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  8010bc:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  8010be:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  8010c3:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  8010c6:	83 ec 0c             	sub    $0xc,%esp
  8010c9:	50                   	push   %eax
  8010ca:	e8 f5 fc ff ff       	call   800dc4 <sys_ipc_recv>

	if (r < 0) {
  8010cf:	83 c4 10             	add    $0x10,%esp
  8010d2:	85 c0                	test   %eax,%eax
  8010d4:	79 16                	jns    8010ec <ipc_recv+0x3e>
		if (from_env_store)
  8010d6:	85 f6                	test   %esi,%esi
  8010d8:	74 06                	je     8010e0 <ipc_recv+0x32>
			*from_env_store = 0;
  8010da:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  8010e0:	85 db                	test   %ebx,%ebx
  8010e2:	74 2c                	je     801110 <ipc_recv+0x62>
			*perm_store = 0;
  8010e4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010ea:	eb 24                	jmp    801110 <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  8010ec:	85 f6                	test   %esi,%esi
  8010ee:	74 0a                	je     8010fa <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  8010f0:	a1 04 40 80 00       	mov    0x804004,%eax
  8010f5:	8b 40 74             	mov    0x74(%eax),%eax
  8010f8:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  8010fa:	85 db                	test   %ebx,%ebx
  8010fc:	74 0a                	je     801108 <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  8010fe:	a1 04 40 80 00       	mov    0x804004,%eax
  801103:	8b 40 78             	mov    0x78(%eax),%eax
  801106:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  801108:	a1 04 40 80 00       	mov    0x804004,%eax
  80110d:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  801110:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801113:	5b                   	pop    %ebx
  801114:	5e                   	pop    %esi
  801115:	5d                   	pop    %ebp
  801116:	c3                   	ret    

00801117 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801117:	55                   	push   %ebp
  801118:	89 e5                	mov    %esp,%ebp
  80111a:	57                   	push   %edi
  80111b:	56                   	push   %esi
  80111c:	53                   	push   %ebx
  80111d:	83 ec 0c             	sub    $0xc,%esp
  801120:	8b 7d 08             	mov    0x8(%ebp),%edi
  801123:	8b 75 0c             	mov    0xc(%ebp),%esi
  801126:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  801129:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  80112b:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801130:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  801133:	ff 75 14             	pushl  0x14(%ebp)
  801136:	53                   	push   %ebx
  801137:	56                   	push   %esi
  801138:	57                   	push   %edi
  801139:	e8 63 fc ff ff       	call   800da1 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  80113e:	83 c4 10             	add    $0x10,%esp
  801141:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801144:	75 07                	jne    80114d <ipc_send+0x36>
			sys_yield();
  801146:	e8 aa fa ff ff       	call   800bf5 <sys_yield>
  80114b:	eb e6                	jmp    801133 <ipc_send+0x1c>
		} else if (r < 0) {
  80114d:	85 c0                	test   %eax,%eax
  80114f:	79 12                	jns    801163 <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  801151:	50                   	push   %eax
  801152:	68 89 26 80 00       	push   $0x802689
  801157:	6a 51                	push   $0x51
  801159:	68 96 26 80 00       	push   $0x802696
  80115e:	e8 54 0d 00 00       	call   801eb7 <_panic>
		}
	}
}
  801163:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801166:	5b                   	pop    %ebx
  801167:	5e                   	pop    %esi
  801168:	5f                   	pop    %edi
  801169:	5d                   	pop    %ebp
  80116a:	c3                   	ret    

0080116b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80116b:	55                   	push   %ebp
  80116c:	89 e5                	mov    %esp,%ebp
  80116e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801171:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801176:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801179:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80117f:	8b 52 50             	mov    0x50(%edx),%edx
  801182:	39 ca                	cmp    %ecx,%edx
  801184:	75 0d                	jne    801193 <ipc_find_env+0x28>
			return envs[i].env_id;
  801186:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801189:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80118e:	8b 40 48             	mov    0x48(%eax),%eax
  801191:	eb 0f                	jmp    8011a2 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801193:	83 c0 01             	add    $0x1,%eax
  801196:	3d 00 04 00 00       	cmp    $0x400,%eax
  80119b:	75 d9                	jne    801176 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80119d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011a2:	5d                   	pop    %ebp
  8011a3:	c3                   	ret    

008011a4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011a4:	55                   	push   %ebp
  8011a5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8011aa:	05 00 00 00 30       	add    $0x30000000,%eax
  8011af:	c1 e8 0c             	shr    $0xc,%eax
}
  8011b2:	5d                   	pop    %ebp
  8011b3:	c3                   	ret    

008011b4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011b4:	55                   	push   %ebp
  8011b5:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ba:	05 00 00 00 30       	add    $0x30000000,%eax
  8011bf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011c4:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011c9:	5d                   	pop    %ebp
  8011ca:	c3                   	ret    

008011cb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011cb:	55                   	push   %ebp
  8011cc:	89 e5                	mov    %esp,%ebp
  8011ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011d1:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011d6:	89 c2                	mov    %eax,%edx
  8011d8:	c1 ea 16             	shr    $0x16,%edx
  8011db:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011e2:	f6 c2 01             	test   $0x1,%dl
  8011e5:	74 11                	je     8011f8 <fd_alloc+0x2d>
  8011e7:	89 c2                	mov    %eax,%edx
  8011e9:	c1 ea 0c             	shr    $0xc,%edx
  8011ec:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011f3:	f6 c2 01             	test   $0x1,%dl
  8011f6:	75 09                	jne    801201 <fd_alloc+0x36>
			*fd_store = fd;
  8011f8:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ff:	eb 17                	jmp    801218 <fd_alloc+0x4d>
  801201:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801206:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80120b:	75 c9                	jne    8011d6 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80120d:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801213:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801218:	5d                   	pop    %ebp
  801219:	c3                   	ret    

0080121a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80121a:	55                   	push   %ebp
  80121b:	89 e5                	mov    %esp,%ebp
  80121d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801220:	83 f8 1f             	cmp    $0x1f,%eax
  801223:	77 36                	ja     80125b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801225:	c1 e0 0c             	shl    $0xc,%eax
  801228:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80122d:	89 c2                	mov    %eax,%edx
  80122f:	c1 ea 16             	shr    $0x16,%edx
  801232:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801239:	f6 c2 01             	test   $0x1,%dl
  80123c:	74 24                	je     801262 <fd_lookup+0x48>
  80123e:	89 c2                	mov    %eax,%edx
  801240:	c1 ea 0c             	shr    $0xc,%edx
  801243:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80124a:	f6 c2 01             	test   $0x1,%dl
  80124d:	74 1a                	je     801269 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80124f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801252:	89 02                	mov    %eax,(%edx)
	return 0;
  801254:	b8 00 00 00 00       	mov    $0x0,%eax
  801259:	eb 13                	jmp    80126e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80125b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801260:	eb 0c                	jmp    80126e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801262:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801267:	eb 05                	jmp    80126e <fd_lookup+0x54>
  801269:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80126e:	5d                   	pop    %ebp
  80126f:	c3                   	ret    

00801270 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801270:	55                   	push   %ebp
  801271:	89 e5                	mov    %esp,%ebp
  801273:	83 ec 08             	sub    $0x8,%esp
  801276:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801279:	ba 1c 27 80 00       	mov    $0x80271c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80127e:	eb 13                	jmp    801293 <dev_lookup+0x23>
  801280:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801283:	39 08                	cmp    %ecx,(%eax)
  801285:	75 0c                	jne    801293 <dev_lookup+0x23>
			*dev = devtab[i];
  801287:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80128a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80128c:	b8 00 00 00 00       	mov    $0x0,%eax
  801291:	eb 2e                	jmp    8012c1 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801293:	8b 02                	mov    (%edx),%eax
  801295:	85 c0                	test   %eax,%eax
  801297:	75 e7                	jne    801280 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801299:	a1 04 40 80 00       	mov    0x804004,%eax
  80129e:	8b 40 48             	mov    0x48(%eax),%eax
  8012a1:	83 ec 04             	sub    $0x4,%esp
  8012a4:	51                   	push   %ecx
  8012a5:	50                   	push   %eax
  8012a6:	68 a0 26 80 00       	push   $0x8026a0
  8012ab:	e8 dc ef ff ff       	call   80028c <cprintf>
	*dev = 0;
  8012b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012b3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012b9:	83 c4 10             	add    $0x10,%esp
  8012bc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012c1:	c9                   	leave  
  8012c2:	c3                   	ret    

008012c3 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012c3:	55                   	push   %ebp
  8012c4:	89 e5                	mov    %esp,%ebp
  8012c6:	56                   	push   %esi
  8012c7:	53                   	push   %ebx
  8012c8:	83 ec 10             	sub    $0x10,%esp
  8012cb:	8b 75 08             	mov    0x8(%ebp),%esi
  8012ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012d4:	50                   	push   %eax
  8012d5:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012db:	c1 e8 0c             	shr    $0xc,%eax
  8012de:	50                   	push   %eax
  8012df:	e8 36 ff ff ff       	call   80121a <fd_lookup>
  8012e4:	83 c4 08             	add    $0x8,%esp
  8012e7:	85 c0                	test   %eax,%eax
  8012e9:	78 05                	js     8012f0 <fd_close+0x2d>
	    || fd != fd2)
  8012eb:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012ee:	74 0c                	je     8012fc <fd_close+0x39>
		return (must_exist ? r : 0);
  8012f0:	84 db                	test   %bl,%bl
  8012f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8012f7:	0f 44 c2             	cmove  %edx,%eax
  8012fa:	eb 41                	jmp    80133d <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012fc:	83 ec 08             	sub    $0x8,%esp
  8012ff:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801302:	50                   	push   %eax
  801303:	ff 36                	pushl  (%esi)
  801305:	e8 66 ff ff ff       	call   801270 <dev_lookup>
  80130a:	89 c3                	mov    %eax,%ebx
  80130c:	83 c4 10             	add    $0x10,%esp
  80130f:	85 c0                	test   %eax,%eax
  801311:	78 1a                	js     80132d <fd_close+0x6a>
		if (dev->dev_close)
  801313:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801316:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801319:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80131e:	85 c0                	test   %eax,%eax
  801320:	74 0b                	je     80132d <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801322:	83 ec 0c             	sub    $0xc,%esp
  801325:	56                   	push   %esi
  801326:	ff d0                	call   *%eax
  801328:	89 c3                	mov    %eax,%ebx
  80132a:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80132d:	83 ec 08             	sub    $0x8,%esp
  801330:	56                   	push   %esi
  801331:	6a 00                	push   $0x0
  801333:	e8 61 f9 ff ff       	call   800c99 <sys_page_unmap>
	return r;
  801338:	83 c4 10             	add    $0x10,%esp
  80133b:	89 d8                	mov    %ebx,%eax
}
  80133d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801340:	5b                   	pop    %ebx
  801341:	5e                   	pop    %esi
  801342:	5d                   	pop    %ebp
  801343:	c3                   	ret    

00801344 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801344:	55                   	push   %ebp
  801345:	89 e5                	mov    %esp,%ebp
  801347:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80134a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80134d:	50                   	push   %eax
  80134e:	ff 75 08             	pushl  0x8(%ebp)
  801351:	e8 c4 fe ff ff       	call   80121a <fd_lookup>
  801356:	83 c4 08             	add    $0x8,%esp
  801359:	85 c0                	test   %eax,%eax
  80135b:	78 10                	js     80136d <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80135d:	83 ec 08             	sub    $0x8,%esp
  801360:	6a 01                	push   $0x1
  801362:	ff 75 f4             	pushl  -0xc(%ebp)
  801365:	e8 59 ff ff ff       	call   8012c3 <fd_close>
  80136a:	83 c4 10             	add    $0x10,%esp
}
  80136d:	c9                   	leave  
  80136e:	c3                   	ret    

0080136f <close_all>:

void
close_all(void)
{
  80136f:	55                   	push   %ebp
  801370:	89 e5                	mov    %esp,%ebp
  801372:	53                   	push   %ebx
  801373:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801376:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80137b:	83 ec 0c             	sub    $0xc,%esp
  80137e:	53                   	push   %ebx
  80137f:	e8 c0 ff ff ff       	call   801344 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801384:	83 c3 01             	add    $0x1,%ebx
  801387:	83 c4 10             	add    $0x10,%esp
  80138a:	83 fb 20             	cmp    $0x20,%ebx
  80138d:	75 ec                	jne    80137b <close_all+0xc>
		close(i);
}
  80138f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801392:	c9                   	leave  
  801393:	c3                   	ret    

00801394 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801394:	55                   	push   %ebp
  801395:	89 e5                	mov    %esp,%ebp
  801397:	57                   	push   %edi
  801398:	56                   	push   %esi
  801399:	53                   	push   %ebx
  80139a:	83 ec 2c             	sub    $0x2c,%esp
  80139d:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013a0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013a3:	50                   	push   %eax
  8013a4:	ff 75 08             	pushl  0x8(%ebp)
  8013a7:	e8 6e fe ff ff       	call   80121a <fd_lookup>
  8013ac:	83 c4 08             	add    $0x8,%esp
  8013af:	85 c0                	test   %eax,%eax
  8013b1:	0f 88 c1 00 00 00    	js     801478 <dup+0xe4>
		return r;
	close(newfdnum);
  8013b7:	83 ec 0c             	sub    $0xc,%esp
  8013ba:	56                   	push   %esi
  8013bb:	e8 84 ff ff ff       	call   801344 <close>

	newfd = INDEX2FD(newfdnum);
  8013c0:	89 f3                	mov    %esi,%ebx
  8013c2:	c1 e3 0c             	shl    $0xc,%ebx
  8013c5:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013cb:	83 c4 04             	add    $0x4,%esp
  8013ce:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013d1:	e8 de fd ff ff       	call   8011b4 <fd2data>
  8013d6:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013d8:	89 1c 24             	mov    %ebx,(%esp)
  8013db:	e8 d4 fd ff ff       	call   8011b4 <fd2data>
  8013e0:	83 c4 10             	add    $0x10,%esp
  8013e3:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013e6:	89 f8                	mov    %edi,%eax
  8013e8:	c1 e8 16             	shr    $0x16,%eax
  8013eb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013f2:	a8 01                	test   $0x1,%al
  8013f4:	74 37                	je     80142d <dup+0x99>
  8013f6:	89 f8                	mov    %edi,%eax
  8013f8:	c1 e8 0c             	shr    $0xc,%eax
  8013fb:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801402:	f6 c2 01             	test   $0x1,%dl
  801405:	74 26                	je     80142d <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801407:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80140e:	83 ec 0c             	sub    $0xc,%esp
  801411:	25 07 0e 00 00       	and    $0xe07,%eax
  801416:	50                   	push   %eax
  801417:	ff 75 d4             	pushl  -0x2c(%ebp)
  80141a:	6a 00                	push   $0x0
  80141c:	57                   	push   %edi
  80141d:	6a 00                	push   $0x0
  80141f:	e8 33 f8 ff ff       	call   800c57 <sys_page_map>
  801424:	89 c7                	mov    %eax,%edi
  801426:	83 c4 20             	add    $0x20,%esp
  801429:	85 c0                	test   %eax,%eax
  80142b:	78 2e                	js     80145b <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80142d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801430:	89 d0                	mov    %edx,%eax
  801432:	c1 e8 0c             	shr    $0xc,%eax
  801435:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80143c:	83 ec 0c             	sub    $0xc,%esp
  80143f:	25 07 0e 00 00       	and    $0xe07,%eax
  801444:	50                   	push   %eax
  801445:	53                   	push   %ebx
  801446:	6a 00                	push   $0x0
  801448:	52                   	push   %edx
  801449:	6a 00                	push   $0x0
  80144b:	e8 07 f8 ff ff       	call   800c57 <sys_page_map>
  801450:	89 c7                	mov    %eax,%edi
  801452:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801455:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801457:	85 ff                	test   %edi,%edi
  801459:	79 1d                	jns    801478 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80145b:	83 ec 08             	sub    $0x8,%esp
  80145e:	53                   	push   %ebx
  80145f:	6a 00                	push   $0x0
  801461:	e8 33 f8 ff ff       	call   800c99 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801466:	83 c4 08             	add    $0x8,%esp
  801469:	ff 75 d4             	pushl  -0x2c(%ebp)
  80146c:	6a 00                	push   $0x0
  80146e:	e8 26 f8 ff ff       	call   800c99 <sys_page_unmap>
	return r;
  801473:	83 c4 10             	add    $0x10,%esp
  801476:	89 f8                	mov    %edi,%eax
}
  801478:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80147b:	5b                   	pop    %ebx
  80147c:	5e                   	pop    %esi
  80147d:	5f                   	pop    %edi
  80147e:	5d                   	pop    %ebp
  80147f:	c3                   	ret    

00801480 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
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
  80148f:	e8 86 fd ff ff       	call   80121a <fd_lookup>
  801494:	83 c4 08             	add    $0x8,%esp
  801497:	89 c2                	mov    %eax,%edx
  801499:	85 c0                	test   %eax,%eax
  80149b:	78 6d                	js     80150a <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80149d:	83 ec 08             	sub    $0x8,%esp
  8014a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014a3:	50                   	push   %eax
  8014a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014a7:	ff 30                	pushl  (%eax)
  8014a9:	e8 c2 fd ff ff       	call   801270 <dev_lookup>
  8014ae:	83 c4 10             	add    $0x10,%esp
  8014b1:	85 c0                	test   %eax,%eax
  8014b3:	78 4c                	js     801501 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014b5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014b8:	8b 42 08             	mov    0x8(%edx),%eax
  8014bb:	83 e0 03             	and    $0x3,%eax
  8014be:	83 f8 01             	cmp    $0x1,%eax
  8014c1:	75 21                	jne    8014e4 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014c3:	a1 04 40 80 00       	mov    0x804004,%eax
  8014c8:	8b 40 48             	mov    0x48(%eax),%eax
  8014cb:	83 ec 04             	sub    $0x4,%esp
  8014ce:	53                   	push   %ebx
  8014cf:	50                   	push   %eax
  8014d0:	68 e1 26 80 00       	push   $0x8026e1
  8014d5:	e8 b2 ed ff ff       	call   80028c <cprintf>
		return -E_INVAL;
  8014da:	83 c4 10             	add    $0x10,%esp
  8014dd:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014e2:	eb 26                	jmp    80150a <read+0x8a>
	}
	if (!dev->dev_read)
  8014e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014e7:	8b 40 08             	mov    0x8(%eax),%eax
  8014ea:	85 c0                	test   %eax,%eax
  8014ec:	74 17                	je     801505 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014ee:	83 ec 04             	sub    $0x4,%esp
  8014f1:	ff 75 10             	pushl  0x10(%ebp)
  8014f4:	ff 75 0c             	pushl  0xc(%ebp)
  8014f7:	52                   	push   %edx
  8014f8:	ff d0                	call   *%eax
  8014fa:	89 c2                	mov    %eax,%edx
  8014fc:	83 c4 10             	add    $0x10,%esp
  8014ff:	eb 09                	jmp    80150a <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801501:	89 c2                	mov    %eax,%edx
  801503:	eb 05                	jmp    80150a <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801505:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80150a:	89 d0                	mov    %edx,%eax
  80150c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80150f:	c9                   	leave  
  801510:	c3                   	ret    

00801511 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801511:	55                   	push   %ebp
  801512:	89 e5                	mov    %esp,%ebp
  801514:	57                   	push   %edi
  801515:	56                   	push   %esi
  801516:	53                   	push   %ebx
  801517:	83 ec 0c             	sub    $0xc,%esp
  80151a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80151d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801520:	bb 00 00 00 00       	mov    $0x0,%ebx
  801525:	eb 21                	jmp    801548 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801527:	83 ec 04             	sub    $0x4,%esp
  80152a:	89 f0                	mov    %esi,%eax
  80152c:	29 d8                	sub    %ebx,%eax
  80152e:	50                   	push   %eax
  80152f:	89 d8                	mov    %ebx,%eax
  801531:	03 45 0c             	add    0xc(%ebp),%eax
  801534:	50                   	push   %eax
  801535:	57                   	push   %edi
  801536:	e8 45 ff ff ff       	call   801480 <read>
		if (m < 0)
  80153b:	83 c4 10             	add    $0x10,%esp
  80153e:	85 c0                	test   %eax,%eax
  801540:	78 10                	js     801552 <readn+0x41>
			return m;
		if (m == 0)
  801542:	85 c0                	test   %eax,%eax
  801544:	74 0a                	je     801550 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801546:	01 c3                	add    %eax,%ebx
  801548:	39 f3                	cmp    %esi,%ebx
  80154a:	72 db                	jb     801527 <readn+0x16>
  80154c:	89 d8                	mov    %ebx,%eax
  80154e:	eb 02                	jmp    801552 <readn+0x41>
  801550:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801552:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801555:	5b                   	pop    %ebx
  801556:	5e                   	pop    %esi
  801557:	5f                   	pop    %edi
  801558:	5d                   	pop    %ebp
  801559:	c3                   	ret    

0080155a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80155a:	55                   	push   %ebp
  80155b:	89 e5                	mov    %esp,%ebp
  80155d:	53                   	push   %ebx
  80155e:	83 ec 14             	sub    $0x14,%esp
  801561:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801564:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801567:	50                   	push   %eax
  801568:	53                   	push   %ebx
  801569:	e8 ac fc ff ff       	call   80121a <fd_lookup>
  80156e:	83 c4 08             	add    $0x8,%esp
  801571:	89 c2                	mov    %eax,%edx
  801573:	85 c0                	test   %eax,%eax
  801575:	78 68                	js     8015df <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801577:	83 ec 08             	sub    $0x8,%esp
  80157a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80157d:	50                   	push   %eax
  80157e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801581:	ff 30                	pushl  (%eax)
  801583:	e8 e8 fc ff ff       	call   801270 <dev_lookup>
  801588:	83 c4 10             	add    $0x10,%esp
  80158b:	85 c0                	test   %eax,%eax
  80158d:	78 47                	js     8015d6 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80158f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801592:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801596:	75 21                	jne    8015b9 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801598:	a1 04 40 80 00       	mov    0x804004,%eax
  80159d:	8b 40 48             	mov    0x48(%eax),%eax
  8015a0:	83 ec 04             	sub    $0x4,%esp
  8015a3:	53                   	push   %ebx
  8015a4:	50                   	push   %eax
  8015a5:	68 fd 26 80 00       	push   $0x8026fd
  8015aa:	e8 dd ec ff ff       	call   80028c <cprintf>
		return -E_INVAL;
  8015af:	83 c4 10             	add    $0x10,%esp
  8015b2:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015b7:	eb 26                	jmp    8015df <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015b9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015bc:	8b 52 0c             	mov    0xc(%edx),%edx
  8015bf:	85 d2                	test   %edx,%edx
  8015c1:	74 17                	je     8015da <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015c3:	83 ec 04             	sub    $0x4,%esp
  8015c6:	ff 75 10             	pushl  0x10(%ebp)
  8015c9:	ff 75 0c             	pushl  0xc(%ebp)
  8015cc:	50                   	push   %eax
  8015cd:	ff d2                	call   *%edx
  8015cf:	89 c2                	mov    %eax,%edx
  8015d1:	83 c4 10             	add    $0x10,%esp
  8015d4:	eb 09                	jmp    8015df <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015d6:	89 c2                	mov    %eax,%edx
  8015d8:	eb 05                	jmp    8015df <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015da:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8015df:	89 d0                	mov    %edx,%eax
  8015e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015e4:	c9                   	leave  
  8015e5:	c3                   	ret    

008015e6 <seek>:

int
seek(int fdnum, off_t offset)
{
  8015e6:	55                   	push   %ebp
  8015e7:	89 e5                	mov    %esp,%ebp
  8015e9:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015ec:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015ef:	50                   	push   %eax
  8015f0:	ff 75 08             	pushl  0x8(%ebp)
  8015f3:	e8 22 fc ff ff       	call   80121a <fd_lookup>
  8015f8:	83 c4 08             	add    $0x8,%esp
  8015fb:	85 c0                	test   %eax,%eax
  8015fd:	78 0e                	js     80160d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015ff:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801602:	8b 55 0c             	mov    0xc(%ebp),%edx
  801605:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801608:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80160d:	c9                   	leave  
  80160e:	c3                   	ret    

0080160f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80160f:	55                   	push   %ebp
  801610:	89 e5                	mov    %esp,%ebp
  801612:	53                   	push   %ebx
  801613:	83 ec 14             	sub    $0x14,%esp
  801616:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801619:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80161c:	50                   	push   %eax
  80161d:	53                   	push   %ebx
  80161e:	e8 f7 fb ff ff       	call   80121a <fd_lookup>
  801623:	83 c4 08             	add    $0x8,%esp
  801626:	89 c2                	mov    %eax,%edx
  801628:	85 c0                	test   %eax,%eax
  80162a:	78 65                	js     801691 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80162c:	83 ec 08             	sub    $0x8,%esp
  80162f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801632:	50                   	push   %eax
  801633:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801636:	ff 30                	pushl  (%eax)
  801638:	e8 33 fc ff ff       	call   801270 <dev_lookup>
  80163d:	83 c4 10             	add    $0x10,%esp
  801640:	85 c0                	test   %eax,%eax
  801642:	78 44                	js     801688 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801644:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801647:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80164b:	75 21                	jne    80166e <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80164d:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801652:	8b 40 48             	mov    0x48(%eax),%eax
  801655:	83 ec 04             	sub    $0x4,%esp
  801658:	53                   	push   %ebx
  801659:	50                   	push   %eax
  80165a:	68 c0 26 80 00       	push   $0x8026c0
  80165f:	e8 28 ec ff ff       	call   80028c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801664:	83 c4 10             	add    $0x10,%esp
  801667:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80166c:	eb 23                	jmp    801691 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80166e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801671:	8b 52 18             	mov    0x18(%edx),%edx
  801674:	85 d2                	test   %edx,%edx
  801676:	74 14                	je     80168c <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801678:	83 ec 08             	sub    $0x8,%esp
  80167b:	ff 75 0c             	pushl  0xc(%ebp)
  80167e:	50                   	push   %eax
  80167f:	ff d2                	call   *%edx
  801681:	89 c2                	mov    %eax,%edx
  801683:	83 c4 10             	add    $0x10,%esp
  801686:	eb 09                	jmp    801691 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801688:	89 c2                	mov    %eax,%edx
  80168a:	eb 05                	jmp    801691 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80168c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801691:	89 d0                	mov    %edx,%eax
  801693:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801696:	c9                   	leave  
  801697:	c3                   	ret    

00801698 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801698:	55                   	push   %ebp
  801699:	89 e5                	mov    %esp,%ebp
  80169b:	53                   	push   %ebx
  80169c:	83 ec 14             	sub    $0x14,%esp
  80169f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016a2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016a5:	50                   	push   %eax
  8016a6:	ff 75 08             	pushl  0x8(%ebp)
  8016a9:	e8 6c fb ff ff       	call   80121a <fd_lookup>
  8016ae:	83 c4 08             	add    $0x8,%esp
  8016b1:	89 c2                	mov    %eax,%edx
  8016b3:	85 c0                	test   %eax,%eax
  8016b5:	78 58                	js     80170f <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016b7:	83 ec 08             	sub    $0x8,%esp
  8016ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016bd:	50                   	push   %eax
  8016be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016c1:	ff 30                	pushl  (%eax)
  8016c3:	e8 a8 fb ff ff       	call   801270 <dev_lookup>
  8016c8:	83 c4 10             	add    $0x10,%esp
  8016cb:	85 c0                	test   %eax,%eax
  8016cd:	78 37                	js     801706 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016d2:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016d6:	74 32                	je     80170a <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016d8:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016db:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016e2:	00 00 00 
	stat->st_isdir = 0;
  8016e5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016ec:	00 00 00 
	stat->st_dev = dev;
  8016ef:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016f5:	83 ec 08             	sub    $0x8,%esp
  8016f8:	53                   	push   %ebx
  8016f9:	ff 75 f0             	pushl  -0x10(%ebp)
  8016fc:	ff 50 14             	call   *0x14(%eax)
  8016ff:	89 c2                	mov    %eax,%edx
  801701:	83 c4 10             	add    $0x10,%esp
  801704:	eb 09                	jmp    80170f <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801706:	89 c2                	mov    %eax,%edx
  801708:	eb 05                	jmp    80170f <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80170a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80170f:	89 d0                	mov    %edx,%eax
  801711:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801714:	c9                   	leave  
  801715:	c3                   	ret    

00801716 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801716:	55                   	push   %ebp
  801717:	89 e5                	mov    %esp,%ebp
  801719:	56                   	push   %esi
  80171a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80171b:	83 ec 08             	sub    $0x8,%esp
  80171e:	6a 00                	push   $0x0
  801720:	ff 75 08             	pushl  0x8(%ebp)
  801723:	e8 0c 02 00 00       	call   801934 <open>
  801728:	89 c3                	mov    %eax,%ebx
  80172a:	83 c4 10             	add    $0x10,%esp
  80172d:	85 c0                	test   %eax,%eax
  80172f:	78 1b                	js     80174c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801731:	83 ec 08             	sub    $0x8,%esp
  801734:	ff 75 0c             	pushl  0xc(%ebp)
  801737:	50                   	push   %eax
  801738:	e8 5b ff ff ff       	call   801698 <fstat>
  80173d:	89 c6                	mov    %eax,%esi
	close(fd);
  80173f:	89 1c 24             	mov    %ebx,(%esp)
  801742:	e8 fd fb ff ff       	call   801344 <close>
	return r;
  801747:	83 c4 10             	add    $0x10,%esp
  80174a:	89 f0                	mov    %esi,%eax
}
  80174c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80174f:	5b                   	pop    %ebx
  801750:	5e                   	pop    %esi
  801751:	5d                   	pop    %ebp
  801752:	c3                   	ret    

00801753 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801753:	55                   	push   %ebp
  801754:	89 e5                	mov    %esp,%ebp
  801756:	56                   	push   %esi
  801757:	53                   	push   %ebx
  801758:	89 c6                	mov    %eax,%esi
  80175a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80175c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801763:	75 12                	jne    801777 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801765:	83 ec 0c             	sub    $0xc,%esp
  801768:	6a 01                	push   $0x1
  80176a:	e8 fc f9 ff ff       	call   80116b <ipc_find_env>
  80176f:	a3 00 40 80 00       	mov    %eax,0x804000
  801774:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801777:	6a 07                	push   $0x7
  801779:	68 00 50 80 00       	push   $0x805000
  80177e:	56                   	push   %esi
  80177f:	ff 35 00 40 80 00    	pushl  0x804000
  801785:	e8 8d f9 ff ff       	call   801117 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80178a:	83 c4 0c             	add    $0xc,%esp
  80178d:	6a 00                	push   $0x0
  80178f:	53                   	push   %ebx
  801790:	6a 00                	push   $0x0
  801792:	e8 17 f9 ff ff       	call   8010ae <ipc_recv>
}
  801797:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80179a:	5b                   	pop    %ebx
  80179b:	5e                   	pop    %esi
  80179c:	5d                   	pop    %ebp
  80179d:	c3                   	ret    

0080179e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80179e:	55                   	push   %ebp
  80179f:	89 e5                	mov    %esp,%ebp
  8017a1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a7:	8b 40 0c             	mov    0xc(%eax),%eax
  8017aa:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017af:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017b2:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017b7:	ba 00 00 00 00       	mov    $0x0,%edx
  8017bc:	b8 02 00 00 00       	mov    $0x2,%eax
  8017c1:	e8 8d ff ff ff       	call   801753 <fsipc>
}
  8017c6:	c9                   	leave  
  8017c7:	c3                   	ret    

008017c8 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017c8:	55                   	push   %ebp
  8017c9:	89 e5                	mov    %esp,%ebp
  8017cb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d1:	8b 40 0c             	mov    0xc(%eax),%eax
  8017d4:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8017de:	b8 06 00 00 00       	mov    $0x6,%eax
  8017e3:	e8 6b ff ff ff       	call   801753 <fsipc>
}
  8017e8:	c9                   	leave  
  8017e9:	c3                   	ret    

008017ea <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017ea:	55                   	push   %ebp
  8017eb:	89 e5                	mov    %esp,%ebp
  8017ed:	53                   	push   %ebx
  8017ee:	83 ec 04             	sub    $0x4,%esp
  8017f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f7:	8b 40 0c             	mov    0xc(%eax),%eax
  8017fa:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017ff:	ba 00 00 00 00       	mov    $0x0,%edx
  801804:	b8 05 00 00 00       	mov    $0x5,%eax
  801809:	e8 45 ff ff ff       	call   801753 <fsipc>
  80180e:	85 c0                	test   %eax,%eax
  801810:	78 2c                	js     80183e <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801812:	83 ec 08             	sub    $0x8,%esp
  801815:	68 00 50 80 00       	push   $0x805000
  80181a:	53                   	push   %ebx
  80181b:	e8 f1 ef ff ff       	call   800811 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801820:	a1 80 50 80 00       	mov    0x805080,%eax
  801825:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80182b:	a1 84 50 80 00       	mov    0x805084,%eax
  801830:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801836:	83 c4 10             	add    $0x10,%esp
  801839:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80183e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801841:	c9                   	leave  
  801842:	c3                   	ret    

00801843 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801843:	55                   	push   %ebp
  801844:	89 e5                	mov    %esp,%ebp
  801846:	53                   	push   %ebx
  801847:	83 ec 08             	sub    $0x8,%esp
  80184a:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80184d:	8b 55 08             	mov    0x8(%ebp),%edx
  801850:	8b 52 0c             	mov    0xc(%edx),%edx
  801853:	89 15 00 50 80 00    	mov    %edx,0x805000
  801859:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80185e:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  801863:	0f 46 d8             	cmovbe %eax,%ebx
	
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  801866:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  80186c:	53                   	push   %ebx
  80186d:	ff 75 0c             	pushl  0xc(%ebp)
  801870:	68 08 50 80 00       	push   $0x805008
  801875:	e8 29 f1 ff ff       	call   8009a3 <memmove>

	
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) 
  80187a:	ba 00 00 00 00       	mov    $0x0,%edx
  80187f:	b8 04 00 00 00       	mov    $0x4,%eax
  801884:	e8 ca fe ff ff       	call   801753 <fsipc>
  801889:	83 c4 10             	add    $0x10,%esp
  80188c:	85 c0                	test   %eax,%eax
  80188e:	78 1d                	js     8018ad <devfile_write+0x6a>
		return r;
	assert(r <= n_real); 
  801890:	39 d8                	cmp    %ebx,%eax
  801892:	76 19                	jbe    8018ad <devfile_write+0x6a>
  801894:	68 2c 27 80 00       	push   $0x80272c
  801899:	68 38 27 80 00       	push   $0x802738
  80189e:	68 a3 00 00 00       	push   $0xa3
  8018a3:	68 4d 27 80 00       	push   $0x80274d
  8018a8:	e8 0a 06 00 00       	call   801eb7 <_panic>
	return r;
}
  8018ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018b0:	c9                   	leave  
  8018b1:	c3                   	ret    

008018b2 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018b2:	55                   	push   %ebp
  8018b3:	89 e5                	mov    %esp,%ebp
  8018b5:	56                   	push   %esi
  8018b6:	53                   	push   %ebx
  8018b7:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8018bd:	8b 40 0c             	mov    0xc(%eax),%eax
  8018c0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018c5:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8018d0:	b8 03 00 00 00       	mov    $0x3,%eax
  8018d5:	e8 79 fe ff ff       	call   801753 <fsipc>
  8018da:	89 c3                	mov    %eax,%ebx
  8018dc:	85 c0                	test   %eax,%eax
  8018de:	78 4b                	js     80192b <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018e0:	39 c6                	cmp    %eax,%esi
  8018e2:	73 16                	jae    8018fa <devfile_read+0x48>
  8018e4:	68 58 27 80 00       	push   $0x802758
  8018e9:	68 38 27 80 00       	push   $0x802738
  8018ee:	6a 7c                	push   $0x7c
  8018f0:	68 4d 27 80 00       	push   $0x80274d
  8018f5:	e8 bd 05 00 00       	call   801eb7 <_panic>
	assert(r <= PGSIZE);
  8018fa:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018ff:	7e 16                	jle    801917 <devfile_read+0x65>
  801901:	68 5f 27 80 00       	push   $0x80275f
  801906:	68 38 27 80 00       	push   $0x802738
  80190b:	6a 7d                	push   $0x7d
  80190d:	68 4d 27 80 00       	push   $0x80274d
  801912:	e8 a0 05 00 00       	call   801eb7 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801917:	83 ec 04             	sub    $0x4,%esp
  80191a:	50                   	push   %eax
  80191b:	68 00 50 80 00       	push   $0x805000
  801920:	ff 75 0c             	pushl  0xc(%ebp)
  801923:	e8 7b f0 ff ff       	call   8009a3 <memmove>
	return r;
  801928:	83 c4 10             	add    $0x10,%esp
}
  80192b:	89 d8                	mov    %ebx,%eax
  80192d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801930:	5b                   	pop    %ebx
  801931:	5e                   	pop    %esi
  801932:	5d                   	pop    %ebp
  801933:	c3                   	ret    

00801934 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801934:	55                   	push   %ebp
  801935:	89 e5                	mov    %esp,%ebp
  801937:	53                   	push   %ebx
  801938:	83 ec 20             	sub    $0x20,%esp
  80193b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80193e:	53                   	push   %ebx
  80193f:	e8 94 ee ff ff       	call   8007d8 <strlen>
  801944:	83 c4 10             	add    $0x10,%esp
  801947:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80194c:	7f 67                	jg     8019b5 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80194e:	83 ec 0c             	sub    $0xc,%esp
  801951:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801954:	50                   	push   %eax
  801955:	e8 71 f8 ff ff       	call   8011cb <fd_alloc>
  80195a:	83 c4 10             	add    $0x10,%esp
		return r;
  80195d:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80195f:	85 c0                	test   %eax,%eax
  801961:	78 57                	js     8019ba <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801963:	83 ec 08             	sub    $0x8,%esp
  801966:	53                   	push   %ebx
  801967:	68 00 50 80 00       	push   $0x805000
  80196c:	e8 a0 ee ff ff       	call   800811 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801971:	8b 45 0c             	mov    0xc(%ebp),%eax
  801974:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801979:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80197c:	b8 01 00 00 00       	mov    $0x1,%eax
  801981:	e8 cd fd ff ff       	call   801753 <fsipc>
  801986:	89 c3                	mov    %eax,%ebx
  801988:	83 c4 10             	add    $0x10,%esp
  80198b:	85 c0                	test   %eax,%eax
  80198d:	79 14                	jns    8019a3 <open+0x6f>
		fd_close(fd, 0);
  80198f:	83 ec 08             	sub    $0x8,%esp
  801992:	6a 00                	push   $0x0
  801994:	ff 75 f4             	pushl  -0xc(%ebp)
  801997:	e8 27 f9 ff ff       	call   8012c3 <fd_close>
		return r;
  80199c:	83 c4 10             	add    $0x10,%esp
  80199f:	89 da                	mov    %ebx,%edx
  8019a1:	eb 17                	jmp    8019ba <open+0x86>
	}

	return fd2num(fd);
  8019a3:	83 ec 0c             	sub    $0xc,%esp
  8019a6:	ff 75 f4             	pushl  -0xc(%ebp)
  8019a9:	e8 f6 f7 ff ff       	call   8011a4 <fd2num>
  8019ae:	89 c2                	mov    %eax,%edx
  8019b0:	83 c4 10             	add    $0x10,%esp
  8019b3:	eb 05                	jmp    8019ba <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019b5:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019ba:	89 d0                	mov    %edx,%eax
  8019bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019bf:	c9                   	leave  
  8019c0:	c3                   	ret    

008019c1 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019c1:	55                   	push   %ebp
  8019c2:	89 e5                	mov    %esp,%ebp
  8019c4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8019cc:	b8 08 00 00 00       	mov    $0x8,%eax
  8019d1:	e8 7d fd ff ff       	call   801753 <fsipc>
}
  8019d6:	c9                   	leave  
  8019d7:	c3                   	ret    

008019d8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019d8:	55                   	push   %ebp
  8019d9:	89 e5                	mov    %esp,%ebp
  8019db:	56                   	push   %esi
  8019dc:	53                   	push   %ebx
  8019dd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019e0:	83 ec 0c             	sub    $0xc,%esp
  8019e3:	ff 75 08             	pushl  0x8(%ebp)
  8019e6:	e8 c9 f7 ff ff       	call   8011b4 <fd2data>
  8019eb:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019ed:	83 c4 08             	add    $0x8,%esp
  8019f0:	68 6b 27 80 00       	push   $0x80276b
  8019f5:	53                   	push   %ebx
  8019f6:	e8 16 ee ff ff       	call   800811 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019fb:	8b 46 04             	mov    0x4(%esi),%eax
  8019fe:	2b 06                	sub    (%esi),%eax
  801a00:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a06:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a0d:	00 00 00 
	stat->st_dev = &devpipe;
  801a10:	c7 83 88 00 00 00 28 	movl   $0x803028,0x88(%ebx)
  801a17:	30 80 00 
	return 0;
}
  801a1a:	b8 00 00 00 00       	mov    $0x0,%eax
  801a1f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a22:	5b                   	pop    %ebx
  801a23:	5e                   	pop    %esi
  801a24:	5d                   	pop    %ebp
  801a25:	c3                   	ret    

00801a26 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a26:	55                   	push   %ebp
  801a27:	89 e5                	mov    %esp,%ebp
  801a29:	53                   	push   %ebx
  801a2a:	83 ec 0c             	sub    $0xc,%esp
  801a2d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a30:	53                   	push   %ebx
  801a31:	6a 00                	push   $0x0
  801a33:	e8 61 f2 ff ff       	call   800c99 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a38:	89 1c 24             	mov    %ebx,(%esp)
  801a3b:	e8 74 f7 ff ff       	call   8011b4 <fd2data>
  801a40:	83 c4 08             	add    $0x8,%esp
  801a43:	50                   	push   %eax
  801a44:	6a 00                	push   $0x0
  801a46:	e8 4e f2 ff ff       	call   800c99 <sys_page_unmap>
}
  801a4b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a4e:	c9                   	leave  
  801a4f:	c3                   	ret    

00801a50 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a50:	55                   	push   %ebp
  801a51:	89 e5                	mov    %esp,%ebp
  801a53:	57                   	push   %edi
  801a54:	56                   	push   %esi
  801a55:	53                   	push   %ebx
  801a56:	83 ec 1c             	sub    $0x1c,%esp
  801a59:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a5c:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a5e:	a1 04 40 80 00       	mov    0x804004,%eax
  801a63:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a66:	83 ec 0c             	sub    $0xc,%esp
  801a69:	ff 75 e0             	pushl  -0x20(%ebp)
  801a6c:	e8 02 05 00 00       	call   801f73 <pageref>
  801a71:	89 c3                	mov    %eax,%ebx
  801a73:	89 3c 24             	mov    %edi,(%esp)
  801a76:	e8 f8 04 00 00       	call   801f73 <pageref>
  801a7b:	83 c4 10             	add    $0x10,%esp
  801a7e:	39 c3                	cmp    %eax,%ebx
  801a80:	0f 94 c1             	sete   %cl
  801a83:	0f b6 c9             	movzbl %cl,%ecx
  801a86:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a89:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a8f:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a92:	39 ce                	cmp    %ecx,%esi
  801a94:	74 1b                	je     801ab1 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a96:	39 c3                	cmp    %eax,%ebx
  801a98:	75 c4                	jne    801a5e <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a9a:	8b 42 58             	mov    0x58(%edx),%eax
  801a9d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801aa0:	50                   	push   %eax
  801aa1:	56                   	push   %esi
  801aa2:	68 72 27 80 00       	push   $0x802772
  801aa7:	e8 e0 e7 ff ff       	call   80028c <cprintf>
  801aac:	83 c4 10             	add    $0x10,%esp
  801aaf:	eb ad                	jmp    801a5e <_pipeisclosed+0xe>
	}
}
  801ab1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ab4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ab7:	5b                   	pop    %ebx
  801ab8:	5e                   	pop    %esi
  801ab9:	5f                   	pop    %edi
  801aba:	5d                   	pop    %ebp
  801abb:	c3                   	ret    

00801abc <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801abc:	55                   	push   %ebp
  801abd:	89 e5                	mov    %esp,%ebp
  801abf:	57                   	push   %edi
  801ac0:	56                   	push   %esi
  801ac1:	53                   	push   %ebx
  801ac2:	83 ec 28             	sub    $0x28,%esp
  801ac5:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801ac8:	56                   	push   %esi
  801ac9:	e8 e6 f6 ff ff       	call   8011b4 <fd2data>
  801ace:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ad0:	83 c4 10             	add    $0x10,%esp
  801ad3:	bf 00 00 00 00       	mov    $0x0,%edi
  801ad8:	eb 4b                	jmp    801b25 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ada:	89 da                	mov    %ebx,%edx
  801adc:	89 f0                	mov    %esi,%eax
  801ade:	e8 6d ff ff ff       	call   801a50 <_pipeisclosed>
  801ae3:	85 c0                	test   %eax,%eax
  801ae5:	75 48                	jne    801b2f <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ae7:	e8 09 f1 ff ff       	call   800bf5 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801aec:	8b 43 04             	mov    0x4(%ebx),%eax
  801aef:	8b 0b                	mov    (%ebx),%ecx
  801af1:	8d 51 20             	lea    0x20(%ecx),%edx
  801af4:	39 d0                	cmp    %edx,%eax
  801af6:	73 e2                	jae    801ada <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801af8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801afb:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801aff:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b02:	89 c2                	mov    %eax,%edx
  801b04:	c1 fa 1f             	sar    $0x1f,%edx
  801b07:	89 d1                	mov    %edx,%ecx
  801b09:	c1 e9 1b             	shr    $0x1b,%ecx
  801b0c:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b0f:	83 e2 1f             	and    $0x1f,%edx
  801b12:	29 ca                	sub    %ecx,%edx
  801b14:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b18:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b1c:	83 c0 01             	add    $0x1,%eax
  801b1f:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b22:	83 c7 01             	add    $0x1,%edi
  801b25:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b28:	75 c2                	jne    801aec <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b2a:	8b 45 10             	mov    0x10(%ebp),%eax
  801b2d:	eb 05                	jmp    801b34 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b2f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b34:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b37:	5b                   	pop    %ebx
  801b38:	5e                   	pop    %esi
  801b39:	5f                   	pop    %edi
  801b3a:	5d                   	pop    %ebp
  801b3b:	c3                   	ret    

00801b3c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b3c:	55                   	push   %ebp
  801b3d:	89 e5                	mov    %esp,%ebp
  801b3f:	57                   	push   %edi
  801b40:	56                   	push   %esi
  801b41:	53                   	push   %ebx
  801b42:	83 ec 18             	sub    $0x18,%esp
  801b45:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b48:	57                   	push   %edi
  801b49:	e8 66 f6 ff ff       	call   8011b4 <fd2data>
  801b4e:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b50:	83 c4 10             	add    $0x10,%esp
  801b53:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b58:	eb 3d                	jmp    801b97 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b5a:	85 db                	test   %ebx,%ebx
  801b5c:	74 04                	je     801b62 <devpipe_read+0x26>
				return i;
  801b5e:	89 d8                	mov    %ebx,%eax
  801b60:	eb 44                	jmp    801ba6 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b62:	89 f2                	mov    %esi,%edx
  801b64:	89 f8                	mov    %edi,%eax
  801b66:	e8 e5 fe ff ff       	call   801a50 <_pipeisclosed>
  801b6b:	85 c0                	test   %eax,%eax
  801b6d:	75 32                	jne    801ba1 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b6f:	e8 81 f0 ff ff       	call   800bf5 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b74:	8b 06                	mov    (%esi),%eax
  801b76:	3b 46 04             	cmp    0x4(%esi),%eax
  801b79:	74 df                	je     801b5a <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b7b:	99                   	cltd   
  801b7c:	c1 ea 1b             	shr    $0x1b,%edx
  801b7f:	01 d0                	add    %edx,%eax
  801b81:	83 e0 1f             	and    $0x1f,%eax
  801b84:	29 d0                	sub    %edx,%eax
  801b86:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b8e:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b91:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b94:	83 c3 01             	add    $0x1,%ebx
  801b97:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b9a:	75 d8                	jne    801b74 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b9c:	8b 45 10             	mov    0x10(%ebp),%eax
  801b9f:	eb 05                	jmp    801ba6 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ba1:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801ba6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ba9:	5b                   	pop    %ebx
  801baa:	5e                   	pop    %esi
  801bab:	5f                   	pop    %edi
  801bac:	5d                   	pop    %ebp
  801bad:	c3                   	ret    

00801bae <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801bae:	55                   	push   %ebp
  801baf:	89 e5                	mov    %esp,%ebp
  801bb1:	56                   	push   %esi
  801bb2:	53                   	push   %ebx
  801bb3:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801bb6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bb9:	50                   	push   %eax
  801bba:	e8 0c f6 ff ff       	call   8011cb <fd_alloc>
  801bbf:	83 c4 10             	add    $0x10,%esp
  801bc2:	89 c2                	mov    %eax,%edx
  801bc4:	85 c0                	test   %eax,%eax
  801bc6:	0f 88 2c 01 00 00    	js     801cf8 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bcc:	83 ec 04             	sub    $0x4,%esp
  801bcf:	68 07 04 00 00       	push   $0x407
  801bd4:	ff 75 f4             	pushl  -0xc(%ebp)
  801bd7:	6a 00                	push   $0x0
  801bd9:	e8 36 f0 ff ff       	call   800c14 <sys_page_alloc>
  801bde:	83 c4 10             	add    $0x10,%esp
  801be1:	89 c2                	mov    %eax,%edx
  801be3:	85 c0                	test   %eax,%eax
  801be5:	0f 88 0d 01 00 00    	js     801cf8 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801beb:	83 ec 0c             	sub    $0xc,%esp
  801bee:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bf1:	50                   	push   %eax
  801bf2:	e8 d4 f5 ff ff       	call   8011cb <fd_alloc>
  801bf7:	89 c3                	mov    %eax,%ebx
  801bf9:	83 c4 10             	add    $0x10,%esp
  801bfc:	85 c0                	test   %eax,%eax
  801bfe:	0f 88 e2 00 00 00    	js     801ce6 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c04:	83 ec 04             	sub    $0x4,%esp
  801c07:	68 07 04 00 00       	push   $0x407
  801c0c:	ff 75 f0             	pushl  -0x10(%ebp)
  801c0f:	6a 00                	push   $0x0
  801c11:	e8 fe ef ff ff       	call   800c14 <sys_page_alloc>
  801c16:	89 c3                	mov    %eax,%ebx
  801c18:	83 c4 10             	add    $0x10,%esp
  801c1b:	85 c0                	test   %eax,%eax
  801c1d:	0f 88 c3 00 00 00    	js     801ce6 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c23:	83 ec 0c             	sub    $0xc,%esp
  801c26:	ff 75 f4             	pushl  -0xc(%ebp)
  801c29:	e8 86 f5 ff ff       	call   8011b4 <fd2data>
  801c2e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c30:	83 c4 0c             	add    $0xc,%esp
  801c33:	68 07 04 00 00       	push   $0x407
  801c38:	50                   	push   %eax
  801c39:	6a 00                	push   $0x0
  801c3b:	e8 d4 ef ff ff       	call   800c14 <sys_page_alloc>
  801c40:	89 c3                	mov    %eax,%ebx
  801c42:	83 c4 10             	add    $0x10,%esp
  801c45:	85 c0                	test   %eax,%eax
  801c47:	0f 88 89 00 00 00    	js     801cd6 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c4d:	83 ec 0c             	sub    $0xc,%esp
  801c50:	ff 75 f0             	pushl  -0x10(%ebp)
  801c53:	e8 5c f5 ff ff       	call   8011b4 <fd2data>
  801c58:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c5f:	50                   	push   %eax
  801c60:	6a 00                	push   $0x0
  801c62:	56                   	push   %esi
  801c63:	6a 00                	push   $0x0
  801c65:	e8 ed ef ff ff       	call   800c57 <sys_page_map>
  801c6a:	89 c3                	mov    %eax,%ebx
  801c6c:	83 c4 20             	add    $0x20,%esp
  801c6f:	85 c0                	test   %eax,%eax
  801c71:	78 55                	js     801cc8 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c73:	8b 15 28 30 80 00    	mov    0x803028,%edx
  801c79:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c7c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c81:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c88:	8b 15 28 30 80 00    	mov    0x803028,%edx
  801c8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c91:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c93:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c96:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c9d:	83 ec 0c             	sub    $0xc,%esp
  801ca0:	ff 75 f4             	pushl  -0xc(%ebp)
  801ca3:	e8 fc f4 ff ff       	call   8011a4 <fd2num>
  801ca8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cab:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801cad:	83 c4 04             	add    $0x4,%esp
  801cb0:	ff 75 f0             	pushl  -0x10(%ebp)
  801cb3:	e8 ec f4 ff ff       	call   8011a4 <fd2num>
  801cb8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cbb:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801cbe:	83 c4 10             	add    $0x10,%esp
  801cc1:	ba 00 00 00 00       	mov    $0x0,%edx
  801cc6:	eb 30                	jmp    801cf8 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801cc8:	83 ec 08             	sub    $0x8,%esp
  801ccb:	56                   	push   %esi
  801ccc:	6a 00                	push   $0x0
  801cce:	e8 c6 ef ff ff       	call   800c99 <sys_page_unmap>
  801cd3:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801cd6:	83 ec 08             	sub    $0x8,%esp
  801cd9:	ff 75 f0             	pushl  -0x10(%ebp)
  801cdc:	6a 00                	push   $0x0
  801cde:	e8 b6 ef ff ff       	call   800c99 <sys_page_unmap>
  801ce3:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801ce6:	83 ec 08             	sub    $0x8,%esp
  801ce9:	ff 75 f4             	pushl  -0xc(%ebp)
  801cec:	6a 00                	push   $0x0
  801cee:	e8 a6 ef ff ff       	call   800c99 <sys_page_unmap>
  801cf3:	83 c4 10             	add    $0x10,%esp
  801cf6:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801cf8:	89 d0                	mov    %edx,%eax
  801cfa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cfd:	5b                   	pop    %ebx
  801cfe:	5e                   	pop    %esi
  801cff:	5d                   	pop    %ebp
  801d00:	c3                   	ret    

00801d01 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d01:	55                   	push   %ebp
  801d02:	89 e5                	mov    %esp,%ebp
  801d04:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d07:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d0a:	50                   	push   %eax
  801d0b:	ff 75 08             	pushl  0x8(%ebp)
  801d0e:	e8 07 f5 ff ff       	call   80121a <fd_lookup>
  801d13:	83 c4 10             	add    $0x10,%esp
  801d16:	85 c0                	test   %eax,%eax
  801d18:	78 18                	js     801d32 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d1a:	83 ec 0c             	sub    $0xc,%esp
  801d1d:	ff 75 f4             	pushl  -0xc(%ebp)
  801d20:	e8 8f f4 ff ff       	call   8011b4 <fd2data>
	return _pipeisclosed(fd, p);
  801d25:	89 c2                	mov    %eax,%edx
  801d27:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d2a:	e8 21 fd ff ff       	call   801a50 <_pipeisclosed>
  801d2f:	83 c4 10             	add    $0x10,%esp
}
  801d32:	c9                   	leave  
  801d33:	c3                   	ret    

00801d34 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d34:	55                   	push   %ebp
  801d35:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d37:	b8 00 00 00 00       	mov    $0x0,%eax
  801d3c:	5d                   	pop    %ebp
  801d3d:	c3                   	ret    

00801d3e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d3e:	55                   	push   %ebp
  801d3f:	89 e5                	mov    %esp,%ebp
  801d41:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d44:	68 8a 27 80 00       	push   $0x80278a
  801d49:	ff 75 0c             	pushl  0xc(%ebp)
  801d4c:	e8 c0 ea ff ff       	call   800811 <strcpy>
	return 0;
}
  801d51:	b8 00 00 00 00       	mov    $0x0,%eax
  801d56:	c9                   	leave  
  801d57:	c3                   	ret    

00801d58 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d58:	55                   	push   %ebp
  801d59:	89 e5                	mov    %esp,%ebp
  801d5b:	57                   	push   %edi
  801d5c:	56                   	push   %esi
  801d5d:	53                   	push   %ebx
  801d5e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d64:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d69:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d6f:	eb 2d                	jmp    801d9e <devcons_write+0x46>
		m = n - tot;
  801d71:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d74:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d76:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d79:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d7e:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d81:	83 ec 04             	sub    $0x4,%esp
  801d84:	53                   	push   %ebx
  801d85:	03 45 0c             	add    0xc(%ebp),%eax
  801d88:	50                   	push   %eax
  801d89:	57                   	push   %edi
  801d8a:	e8 14 ec ff ff       	call   8009a3 <memmove>
		sys_cputs(buf, m);
  801d8f:	83 c4 08             	add    $0x8,%esp
  801d92:	53                   	push   %ebx
  801d93:	57                   	push   %edi
  801d94:	e8 bf ed ff ff       	call   800b58 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d99:	01 de                	add    %ebx,%esi
  801d9b:	83 c4 10             	add    $0x10,%esp
  801d9e:	89 f0                	mov    %esi,%eax
  801da0:	3b 75 10             	cmp    0x10(%ebp),%esi
  801da3:	72 cc                	jb     801d71 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801da5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801da8:	5b                   	pop    %ebx
  801da9:	5e                   	pop    %esi
  801daa:	5f                   	pop    %edi
  801dab:	5d                   	pop    %ebp
  801dac:	c3                   	ret    

00801dad <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801dad:	55                   	push   %ebp
  801dae:	89 e5                	mov    %esp,%ebp
  801db0:	83 ec 08             	sub    $0x8,%esp
  801db3:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801db8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801dbc:	74 2a                	je     801de8 <devcons_read+0x3b>
  801dbe:	eb 05                	jmp    801dc5 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801dc0:	e8 30 ee ff ff       	call   800bf5 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801dc5:	e8 ac ed ff ff       	call   800b76 <sys_cgetc>
  801dca:	85 c0                	test   %eax,%eax
  801dcc:	74 f2                	je     801dc0 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801dce:	85 c0                	test   %eax,%eax
  801dd0:	78 16                	js     801de8 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801dd2:	83 f8 04             	cmp    $0x4,%eax
  801dd5:	74 0c                	je     801de3 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801dd7:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dda:	88 02                	mov    %al,(%edx)
	return 1;
  801ddc:	b8 01 00 00 00       	mov    $0x1,%eax
  801de1:	eb 05                	jmp    801de8 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801de3:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801de8:	c9                   	leave  
  801de9:	c3                   	ret    

00801dea <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801dea:	55                   	push   %ebp
  801deb:	89 e5                	mov    %esp,%ebp
  801ded:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801df0:	8b 45 08             	mov    0x8(%ebp),%eax
  801df3:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801df6:	6a 01                	push   $0x1
  801df8:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dfb:	50                   	push   %eax
  801dfc:	e8 57 ed ff ff       	call   800b58 <sys_cputs>
}
  801e01:	83 c4 10             	add    $0x10,%esp
  801e04:	c9                   	leave  
  801e05:	c3                   	ret    

00801e06 <getchar>:

int
getchar(void)
{
  801e06:	55                   	push   %ebp
  801e07:	89 e5                	mov    %esp,%ebp
  801e09:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e0c:	6a 01                	push   $0x1
  801e0e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e11:	50                   	push   %eax
  801e12:	6a 00                	push   $0x0
  801e14:	e8 67 f6 ff ff       	call   801480 <read>
	if (r < 0)
  801e19:	83 c4 10             	add    $0x10,%esp
  801e1c:	85 c0                	test   %eax,%eax
  801e1e:	78 0f                	js     801e2f <getchar+0x29>
		return r;
	if (r < 1)
  801e20:	85 c0                	test   %eax,%eax
  801e22:	7e 06                	jle    801e2a <getchar+0x24>
		return -E_EOF;
	return c;
  801e24:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e28:	eb 05                	jmp    801e2f <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e2a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e2f:	c9                   	leave  
  801e30:	c3                   	ret    

00801e31 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e31:	55                   	push   %ebp
  801e32:	89 e5                	mov    %esp,%ebp
  801e34:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e37:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e3a:	50                   	push   %eax
  801e3b:	ff 75 08             	pushl  0x8(%ebp)
  801e3e:	e8 d7 f3 ff ff       	call   80121a <fd_lookup>
  801e43:	83 c4 10             	add    $0x10,%esp
  801e46:	85 c0                	test   %eax,%eax
  801e48:	78 11                	js     801e5b <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e4d:	8b 15 44 30 80 00    	mov    0x803044,%edx
  801e53:	39 10                	cmp    %edx,(%eax)
  801e55:	0f 94 c0             	sete   %al
  801e58:	0f b6 c0             	movzbl %al,%eax
}
  801e5b:	c9                   	leave  
  801e5c:	c3                   	ret    

00801e5d <opencons>:

int
opencons(void)
{
  801e5d:	55                   	push   %ebp
  801e5e:	89 e5                	mov    %esp,%ebp
  801e60:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e63:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e66:	50                   	push   %eax
  801e67:	e8 5f f3 ff ff       	call   8011cb <fd_alloc>
  801e6c:	83 c4 10             	add    $0x10,%esp
		return r;
  801e6f:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e71:	85 c0                	test   %eax,%eax
  801e73:	78 3e                	js     801eb3 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e75:	83 ec 04             	sub    $0x4,%esp
  801e78:	68 07 04 00 00       	push   $0x407
  801e7d:	ff 75 f4             	pushl  -0xc(%ebp)
  801e80:	6a 00                	push   $0x0
  801e82:	e8 8d ed ff ff       	call   800c14 <sys_page_alloc>
  801e87:	83 c4 10             	add    $0x10,%esp
		return r;
  801e8a:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e8c:	85 c0                	test   %eax,%eax
  801e8e:	78 23                	js     801eb3 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e90:	8b 15 44 30 80 00    	mov    0x803044,%edx
  801e96:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e99:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e9e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ea5:	83 ec 0c             	sub    $0xc,%esp
  801ea8:	50                   	push   %eax
  801ea9:	e8 f6 f2 ff ff       	call   8011a4 <fd2num>
  801eae:	89 c2                	mov    %eax,%edx
  801eb0:	83 c4 10             	add    $0x10,%esp
}
  801eb3:	89 d0                	mov    %edx,%eax
  801eb5:	c9                   	leave  
  801eb6:	c3                   	ret    

00801eb7 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801eb7:	55                   	push   %ebp
  801eb8:	89 e5                	mov    %esp,%ebp
  801eba:	56                   	push   %esi
  801ebb:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801ebc:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801ebf:	8b 35 08 30 80 00    	mov    0x803008,%esi
  801ec5:	e8 0c ed ff ff       	call   800bd6 <sys_getenvid>
  801eca:	83 ec 0c             	sub    $0xc,%esp
  801ecd:	ff 75 0c             	pushl  0xc(%ebp)
  801ed0:	ff 75 08             	pushl  0x8(%ebp)
  801ed3:	56                   	push   %esi
  801ed4:	50                   	push   %eax
  801ed5:	68 98 27 80 00       	push   $0x802798
  801eda:	e8 ad e3 ff ff       	call   80028c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801edf:	83 c4 18             	add    $0x18,%esp
  801ee2:	53                   	push   %ebx
  801ee3:	ff 75 10             	pushl  0x10(%ebp)
  801ee6:	e8 50 e3 ff ff       	call   80023b <vcprintf>
	cprintf("\n");
  801eeb:	c7 04 24 83 27 80 00 	movl   $0x802783,(%esp)
  801ef2:	e8 95 e3 ff ff       	call   80028c <cprintf>
  801ef7:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801efa:	cc                   	int3   
  801efb:	eb fd                	jmp    801efa <_panic+0x43>

00801efd <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801efd:	55                   	push   %ebp
  801efe:	89 e5                	mov    %esp,%ebp
  801f00:	53                   	push   %ebx
  801f01:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f04:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f0b:	75 28                	jne    801f35 <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  801f0d:	e8 c4 ec ff ff       	call   800bd6 <sys_getenvid>
  801f12:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_U | PTE_W);
  801f14:	83 ec 04             	sub    $0x4,%esp
  801f17:	6a 06                	push   $0x6
  801f19:	68 00 f0 bf ee       	push   $0xeebff000
  801f1e:	50                   	push   %eax
  801f1f:	e8 f0 ec ff ff       	call   800c14 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  801f24:	83 c4 08             	add    $0x8,%esp
  801f27:	68 42 1f 80 00       	push   $0x801f42
  801f2c:	53                   	push   %ebx
  801f2d:	e8 2d ee ff ff       	call   800d5f <sys_env_set_pgfault_upcall>
  801f32:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f35:	8b 45 08             	mov    0x8(%ebp),%eax
  801f38:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801f3d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f40:	c9                   	leave  
  801f41:	c3                   	ret    

00801f42 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f42:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f43:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f48:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f4a:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	# My method is different. Copy the values to the other stack
	# in a convinient way, and then pop everything.
	movl %esp, %ebp		# ebp refers to the exception stack
  801f4d:	89 e5                	mov    %esp,%ebp
	movl 48(%ebp), %esp 	# go to other stack
  801f4f:	8b 65 30             	mov    0x30(%ebp),%esp

	pushl 40(%ebp)		# eip - ORDER SWITCHED WITH EFLAGS
  801f52:	ff 75 28             	pushl  0x28(%ebp)
	pushl 44(%ebp)      	# eflags
  801f55:	ff 75 2c             	pushl  0x2c(%ebp)
	pushl 36(%ebp)		# all the 8 remaining regs
  801f58:	ff 75 24             	pushl  0x24(%ebp)
	pushl 32(%ebp)
  801f5b:	ff 75 20             	pushl  0x20(%ebp)
	pushl 28(%ebp)
  801f5e:	ff 75 1c             	pushl  0x1c(%ebp)
	pushl 24(%ebp)
  801f61:	ff 75 18             	pushl  0x18(%ebp)
	pushl 20(%ebp)
  801f64:	ff 75 14             	pushl  0x14(%ebp)
	pushl 16(%ebp)
  801f67:	ff 75 10             	pushl  0x10(%ebp)
	pushl 12(%ebp)
  801f6a:	ff 75 0c             	pushl  0xc(%ebp)
	pushl 8(%ebp)
  801f6d:	ff 75 08             	pushl  0x8(%ebp)

	popal			# now just pop everything!
  801f70:	61                   	popa   
	popfl
  801f71:	9d                   	popf   
	ret
  801f72:	c3                   	ret    

00801f73 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f73:	55                   	push   %ebp
  801f74:	89 e5                	mov    %esp,%ebp
  801f76:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f79:	89 d0                	mov    %edx,%eax
  801f7b:	c1 e8 16             	shr    $0x16,%eax
  801f7e:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f85:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f8a:	f6 c1 01             	test   $0x1,%cl
  801f8d:	74 1d                	je     801fac <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f8f:	c1 ea 0c             	shr    $0xc,%edx
  801f92:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f99:	f6 c2 01             	test   $0x1,%dl
  801f9c:	74 0e                	je     801fac <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f9e:	c1 ea 0c             	shr    $0xc,%edx
  801fa1:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fa8:	ef 
  801fa9:	0f b7 c0             	movzwl %ax,%eax
}
  801fac:	5d                   	pop    %ebp
  801fad:	c3                   	ret    
  801fae:	66 90                	xchg   %ax,%ax

00801fb0 <__udivdi3>:
  801fb0:	55                   	push   %ebp
  801fb1:	57                   	push   %edi
  801fb2:	56                   	push   %esi
  801fb3:	53                   	push   %ebx
  801fb4:	83 ec 1c             	sub    $0x1c,%esp
  801fb7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801fbb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801fbf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801fc3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801fc7:	85 f6                	test   %esi,%esi
  801fc9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fcd:	89 ca                	mov    %ecx,%edx
  801fcf:	89 f8                	mov    %edi,%eax
  801fd1:	75 3d                	jne    802010 <__udivdi3+0x60>
  801fd3:	39 cf                	cmp    %ecx,%edi
  801fd5:	0f 87 c5 00 00 00    	ja     8020a0 <__udivdi3+0xf0>
  801fdb:	85 ff                	test   %edi,%edi
  801fdd:	89 fd                	mov    %edi,%ebp
  801fdf:	75 0b                	jne    801fec <__udivdi3+0x3c>
  801fe1:	b8 01 00 00 00       	mov    $0x1,%eax
  801fe6:	31 d2                	xor    %edx,%edx
  801fe8:	f7 f7                	div    %edi
  801fea:	89 c5                	mov    %eax,%ebp
  801fec:	89 c8                	mov    %ecx,%eax
  801fee:	31 d2                	xor    %edx,%edx
  801ff0:	f7 f5                	div    %ebp
  801ff2:	89 c1                	mov    %eax,%ecx
  801ff4:	89 d8                	mov    %ebx,%eax
  801ff6:	89 cf                	mov    %ecx,%edi
  801ff8:	f7 f5                	div    %ebp
  801ffa:	89 c3                	mov    %eax,%ebx
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
  802010:	39 ce                	cmp    %ecx,%esi
  802012:	77 74                	ja     802088 <__udivdi3+0xd8>
  802014:	0f bd fe             	bsr    %esi,%edi
  802017:	83 f7 1f             	xor    $0x1f,%edi
  80201a:	0f 84 98 00 00 00    	je     8020b8 <__udivdi3+0x108>
  802020:	bb 20 00 00 00       	mov    $0x20,%ebx
  802025:	89 f9                	mov    %edi,%ecx
  802027:	89 c5                	mov    %eax,%ebp
  802029:	29 fb                	sub    %edi,%ebx
  80202b:	d3 e6                	shl    %cl,%esi
  80202d:	89 d9                	mov    %ebx,%ecx
  80202f:	d3 ed                	shr    %cl,%ebp
  802031:	89 f9                	mov    %edi,%ecx
  802033:	d3 e0                	shl    %cl,%eax
  802035:	09 ee                	or     %ebp,%esi
  802037:	89 d9                	mov    %ebx,%ecx
  802039:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80203d:	89 d5                	mov    %edx,%ebp
  80203f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802043:	d3 ed                	shr    %cl,%ebp
  802045:	89 f9                	mov    %edi,%ecx
  802047:	d3 e2                	shl    %cl,%edx
  802049:	89 d9                	mov    %ebx,%ecx
  80204b:	d3 e8                	shr    %cl,%eax
  80204d:	09 c2                	or     %eax,%edx
  80204f:	89 d0                	mov    %edx,%eax
  802051:	89 ea                	mov    %ebp,%edx
  802053:	f7 f6                	div    %esi
  802055:	89 d5                	mov    %edx,%ebp
  802057:	89 c3                	mov    %eax,%ebx
  802059:	f7 64 24 0c          	mull   0xc(%esp)
  80205d:	39 d5                	cmp    %edx,%ebp
  80205f:	72 10                	jb     802071 <__udivdi3+0xc1>
  802061:	8b 74 24 08          	mov    0x8(%esp),%esi
  802065:	89 f9                	mov    %edi,%ecx
  802067:	d3 e6                	shl    %cl,%esi
  802069:	39 c6                	cmp    %eax,%esi
  80206b:	73 07                	jae    802074 <__udivdi3+0xc4>
  80206d:	39 d5                	cmp    %edx,%ebp
  80206f:	75 03                	jne    802074 <__udivdi3+0xc4>
  802071:	83 eb 01             	sub    $0x1,%ebx
  802074:	31 ff                	xor    %edi,%edi
  802076:	89 d8                	mov    %ebx,%eax
  802078:	89 fa                	mov    %edi,%edx
  80207a:	83 c4 1c             	add    $0x1c,%esp
  80207d:	5b                   	pop    %ebx
  80207e:	5e                   	pop    %esi
  80207f:	5f                   	pop    %edi
  802080:	5d                   	pop    %ebp
  802081:	c3                   	ret    
  802082:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802088:	31 ff                	xor    %edi,%edi
  80208a:	31 db                	xor    %ebx,%ebx
  80208c:	89 d8                	mov    %ebx,%eax
  80208e:	89 fa                	mov    %edi,%edx
  802090:	83 c4 1c             	add    $0x1c,%esp
  802093:	5b                   	pop    %ebx
  802094:	5e                   	pop    %esi
  802095:	5f                   	pop    %edi
  802096:	5d                   	pop    %ebp
  802097:	c3                   	ret    
  802098:	90                   	nop
  802099:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020a0:	89 d8                	mov    %ebx,%eax
  8020a2:	f7 f7                	div    %edi
  8020a4:	31 ff                	xor    %edi,%edi
  8020a6:	89 c3                	mov    %eax,%ebx
  8020a8:	89 d8                	mov    %ebx,%eax
  8020aa:	89 fa                	mov    %edi,%edx
  8020ac:	83 c4 1c             	add    $0x1c,%esp
  8020af:	5b                   	pop    %ebx
  8020b0:	5e                   	pop    %esi
  8020b1:	5f                   	pop    %edi
  8020b2:	5d                   	pop    %ebp
  8020b3:	c3                   	ret    
  8020b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020b8:	39 ce                	cmp    %ecx,%esi
  8020ba:	72 0c                	jb     8020c8 <__udivdi3+0x118>
  8020bc:	31 db                	xor    %ebx,%ebx
  8020be:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8020c2:	0f 87 34 ff ff ff    	ja     801ffc <__udivdi3+0x4c>
  8020c8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8020cd:	e9 2a ff ff ff       	jmp    801ffc <__udivdi3+0x4c>
  8020d2:	66 90                	xchg   %ax,%ax
  8020d4:	66 90                	xchg   %ax,%ax
  8020d6:	66 90                	xchg   %ax,%ax
  8020d8:	66 90                	xchg   %ax,%ax
  8020da:	66 90                	xchg   %ax,%ax
  8020dc:	66 90                	xchg   %ax,%ax
  8020de:	66 90                	xchg   %ax,%ax

008020e0 <__umoddi3>:
  8020e0:	55                   	push   %ebp
  8020e1:	57                   	push   %edi
  8020e2:	56                   	push   %esi
  8020e3:	53                   	push   %ebx
  8020e4:	83 ec 1c             	sub    $0x1c,%esp
  8020e7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8020eb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8020ef:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020f7:	85 d2                	test   %edx,%edx
  8020f9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8020fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802101:	89 f3                	mov    %esi,%ebx
  802103:	89 3c 24             	mov    %edi,(%esp)
  802106:	89 74 24 04          	mov    %esi,0x4(%esp)
  80210a:	75 1c                	jne    802128 <__umoddi3+0x48>
  80210c:	39 f7                	cmp    %esi,%edi
  80210e:	76 50                	jbe    802160 <__umoddi3+0x80>
  802110:	89 c8                	mov    %ecx,%eax
  802112:	89 f2                	mov    %esi,%edx
  802114:	f7 f7                	div    %edi
  802116:	89 d0                	mov    %edx,%eax
  802118:	31 d2                	xor    %edx,%edx
  80211a:	83 c4 1c             	add    $0x1c,%esp
  80211d:	5b                   	pop    %ebx
  80211e:	5e                   	pop    %esi
  80211f:	5f                   	pop    %edi
  802120:	5d                   	pop    %ebp
  802121:	c3                   	ret    
  802122:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802128:	39 f2                	cmp    %esi,%edx
  80212a:	89 d0                	mov    %edx,%eax
  80212c:	77 52                	ja     802180 <__umoddi3+0xa0>
  80212e:	0f bd ea             	bsr    %edx,%ebp
  802131:	83 f5 1f             	xor    $0x1f,%ebp
  802134:	75 5a                	jne    802190 <__umoddi3+0xb0>
  802136:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80213a:	0f 82 e0 00 00 00    	jb     802220 <__umoddi3+0x140>
  802140:	39 0c 24             	cmp    %ecx,(%esp)
  802143:	0f 86 d7 00 00 00    	jbe    802220 <__umoddi3+0x140>
  802149:	8b 44 24 08          	mov    0x8(%esp),%eax
  80214d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802151:	83 c4 1c             	add    $0x1c,%esp
  802154:	5b                   	pop    %ebx
  802155:	5e                   	pop    %esi
  802156:	5f                   	pop    %edi
  802157:	5d                   	pop    %ebp
  802158:	c3                   	ret    
  802159:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802160:	85 ff                	test   %edi,%edi
  802162:	89 fd                	mov    %edi,%ebp
  802164:	75 0b                	jne    802171 <__umoddi3+0x91>
  802166:	b8 01 00 00 00       	mov    $0x1,%eax
  80216b:	31 d2                	xor    %edx,%edx
  80216d:	f7 f7                	div    %edi
  80216f:	89 c5                	mov    %eax,%ebp
  802171:	89 f0                	mov    %esi,%eax
  802173:	31 d2                	xor    %edx,%edx
  802175:	f7 f5                	div    %ebp
  802177:	89 c8                	mov    %ecx,%eax
  802179:	f7 f5                	div    %ebp
  80217b:	89 d0                	mov    %edx,%eax
  80217d:	eb 99                	jmp    802118 <__umoddi3+0x38>
  80217f:	90                   	nop
  802180:	89 c8                	mov    %ecx,%eax
  802182:	89 f2                	mov    %esi,%edx
  802184:	83 c4 1c             	add    $0x1c,%esp
  802187:	5b                   	pop    %ebx
  802188:	5e                   	pop    %esi
  802189:	5f                   	pop    %edi
  80218a:	5d                   	pop    %ebp
  80218b:	c3                   	ret    
  80218c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802190:	8b 34 24             	mov    (%esp),%esi
  802193:	bf 20 00 00 00       	mov    $0x20,%edi
  802198:	89 e9                	mov    %ebp,%ecx
  80219a:	29 ef                	sub    %ebp,%edi
  80219c:	d3 e0                	shl    %cl,%eax
  80219e:	89 f9                	mov    %edi,%ecx
  8021a0:	89 f2                	mov    %esi,%edx
  8021a2:	d3 ea                	shr    %cl,%edx
  8021a4:	89 e9                	mov    %ebp,%ecx
  8021a6:	09 c2                	or     %eax,%edx
  8021a8:	89 d8                	mov    %ebx,%eax
  8021aa:	89 14 24             	mov    %edx,(%esp)
  8021ad:	89 f2                	mov    %esi,%edx
  8021af:	d3 e2                	shl    %cl,%edx
  8021b1:	89 f9                	mov    %edi,%ecx
  8021b3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021b7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8021bb:	d3 e8                	shr    %cl,%eax
  8021bd:	89 e9                	mov    %ebp,%ecx
  8021bf:	89 c6                	mov    %eax,%esi
  8021c1:	d3 e3                	shl    %cl,%ebx
  8021c3:	89 f9                	mov    %edi,%ecx
  8021c5:	89 d0                	mov    %edx,%eax
  8021c7:	d3 e8                	shr    %cl,%eax
  8021c9:	89 e9                	mov    %ebp,%ecx
  8021cb:	09 d8                	or     %ebx,%eax
  8021cd:	89 d3                	mov    %edx,%ebx
  8021cf:	89 f2                	mov    %esi,%edx
  8021d1:	f7 34 24             	divl   (%esp)
  8021d4:	89 d6                	mov    %edx,%esi
  8021d6:	d3 e3                	shl    %cl,%ebx
  8021d8:	f7 64 24 04          	mull   0x4(%esp)
  8021dc:	39 d6                	cmp    %edx,%esi
  8021de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021e2:	89 d1                	mov    %edx,%ecx
  8021e4:	89 c3                	mov    %eax,%ebx
  8021e6:	72 08                	jb     8021f0 <__umoddi3+0x110>
  8021e8:	75 11                	jne    8021fb <__umoddi3+0x11b>
  8021ea:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8021ee:	73 0b                	jae    8021fb <__umoddi3+0x11b>
  8021f0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8021f4:	1b 14 24             	sbb    (%esp),%edx
  8021f7:	89 d1                	mov    %edx,%ecx
  8021f9:	89 c3                	mov    %eax,%ebx
  8021fb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8021ff:	29 da                	sub    %ebx,%edx
  802201:	19 ce                	sbb    %ecx,%esi
  802203:	89 f9                	mov    %edi,%ecx
  802205:	89 f0                	mov    %esi,%eax
  802207:	d3 e0                	shl    %cl,%eax
  802209:	89 e9                	mov    %ebp,%ecx
  80220b:	d3 ea                	shr    %cl,%edx
  80220d:	89 e9                	mov    %ebp,%ecx
  80220f:	d3 ee                	shr    %cl,%esi
  802211:	09 d0                	or     %edx,%eax
  802213:	89 f2                	mov    %esi,%edx
  802215:	83 c4 1c             	add    $0x1c,%esp
  802218:	5b                   	pop    %ebx
  802219:	5e                   	pop    %esi
  80221a:	5f                   	pop    %edi
  80221b:	5d                   	pop    %ebp
  80221c:	c3                   	ret    
  80221d:	8d 76 00             	lea    0x0(%esi),%esi
  802220:	29 f9                	sub    %edi,%ecx
  802222:	19 d6                	sbb    %edx,%esi
  802224:	89 74 24 04          	mov    %esi,0x4(%esp)
  802228:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80222c:	e9 18 ff ff ff       	jmp    802149 <__umoddi3+0x69>
