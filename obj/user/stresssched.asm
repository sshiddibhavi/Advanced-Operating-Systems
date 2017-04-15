
obj/user/stresssched.debug:     file format elf32-i386


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
  80002c:	e8 bc 00 00 00       	call   8000ed <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

volatile int counter;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();
  800038:	e8 33 0b 00 00       	call   800b70 <sys_getenvid>
  80003d:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  80003f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800044:	e8 0a 0f 00 00       	call   800f53 <fork>
  800049:	85 c0                	test   %eax,%eax
  80004b:	74 0a                	je     800057 <umain+0x24>
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();

	// Fork several environments
	for (i = 0; i < 20; i++)
  80004d:	83 c3 01             	add    $0x1,%ebx
  800050:	83 fb 14             	cmp    $0x14,%ebx
  800053:	75 ef                	jne    800044 <umain+0x11>
  800055:	eb 05                	jmp    80005c <umain+0x29>
		if (fork() == 0)
			break;
	if (i == 20) {
  800057:	83 fb 14             	cmp    $0x14,%ebx
  80005a:	75 0e                	jne    80006a <umain+0x37>
		sys_yield();
  80005c:	e8 2e 0b 00 00       	call   800b8f <sys_yield>
		return;
  800061:	e9 80 00 00 00       	jmp    8000e6 <umain+0xb3>
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");
  800066:	f3 90                	pause  
  800068:	eb 0f                	jmp    800079 <umain+0x46>
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  80006a:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  800070:	6b d6 7c             	imul   $0x7c,%esi,%edx
  800073:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800079:	8b 42 54             	mov    0x54(%edx),%eax
  80007c:	85 c0                	test   %eax,%eax
  80007e:	75 e6                	jne    800066 <umain+0x33>
  800080:	bb 0a 00 00 00       	mov    $0xa,%ebx
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
  800085:	e8 05 0b 00 00       	call   800b8f <sys_yield>
  80008a:	ba 10 27 00 00       	mov    $0x2710,%edx
		for (j = 0; j < 10000; j++)
			counter++;
  80008f:	a1 04 40 80 00       	mov    0x804004,%eax
  800094:	83 c0 01             	add    $0x1,%eax
  800097:	a3 04 40 80 00       	mov    %eax,0x804004
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
		for (j = 0; j < 10000; j++)
  80009c:	83 ea 01             	sub    $0x1,%edx
  80009f:	75 ee                	jne    80008f <umain+0x5c>
	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
  8000a1:	83 eb 01             	sub    $0x1,%ebx
  8000a4:	75 df                	jne    800085 <umain+0x52>
		sys_yield();
		for (j = 0; j < 10000; j++)
			counter++;
	}

	if (counter != 10*10000)
  8000a6:	a1 04 40 80 00       	mov    0x804004,%eax
  8000ab:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000b0:	74 17                	je     8000c9 <umain+0x96>
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000b2:	a1 04 40 80 00       	mov    0x804004,%eax
  8000b7:	50                   	push   %eax
  8000b8:	68 a0 21 80 00       	push   $0x8021a0
  8000bd:	6a 21                	push   $0x21
  8000bf:	68 c8 21 80 00       	push   $0x8021c8
  8000c4:	e8 84 00 00 00       	call   80014d <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000c9:	a1 08 40 80 00       	mov    0x804008,%eax
  8000ce:	8b 50 5c             	mov    0x5c(%eax),%edx
  8000d1:	8b 40 48             	mov    0x48(%eax),%eax
  8000d4:	83 ec 04             	sub    $0x4,%esp
  8000d7:	52                   	push   %edx
  8000d8:	50                   	push   %eax
  8000d9:	68 db 21 80 00       	push   $0x8021db
  8000de:	e8 43 01 00 00       	call   800226 <cprintf>
  8000e3:	83 c4 10             	add    $0x10,%esp

}
  8000e6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e9:	5b                   	pop    %ebx
  8000ea:	5e                   	pop    %esi
  8000eb:	5d                   	pop    %ebp
  8000ec:	c3                   	ret    

008000ed <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000ed:	55                   	push   %ebp
  8000ee:	89 e5                	mov    %esp,%ebp
  8000f0:	56                   	push   %esi
  8000f1:	53                   	push   %ebx
  8000f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000f5:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000f8:	e8 73 0a 00 00       	call   800b70 <sys_getenvid>
  8000fd:	25 ff 03 00 00       	and    $0x3ff,%eax
  800102:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800105:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80010a:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80010f:	85 db                	test   %ebx,%ebx
  800111:	7e 07                	jle    80011a <libmain+0x2d>
		binaryname = argv[0];
  800113:	8b 06                	mov    (%esi),%eax
  800115:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80011a:	83 ec 08             	sub    $0x8,%esp
  80011d:	56                   	push   %esi
  80011e:	53                   	push   %ebx
  80011f:	e8 0f ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800124:	e8 0a 00 00 00       	call   800133 <exit>
}
  800129:	83 c4 10             	add    $0x10,%esp
  80012c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80012f:	5b                   	pop    %ebx
  800130:	5e                   	pop    %esi
  800131:	5d                   	pop    %ebp
  800132:	c3                   	ret    

00800133 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800133:	55                   	push   %ebp
  800134:	89 e5                	mov    %esp,%ebp
  800136:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800139:	e8 d5 10 00 00       	call   801213 <close_all>
	sys_env_destroy(0);
  80013e:	83 ec 0c             	sub    $0xc,%esp
  800141:	6a 00                	push   $0x0
  800143:	e8 e7 09 00 00       	call   800b2f <sys_env_destroy>
}
  800148:	83 c4 10             	add    $0x10,%esp
  80014b:	c9                   	leave  
  80014c:	c3                   	ret    

0080014d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80014d:	55                   	push   %ebp
  80014e:	89 e5                	mov    %esp,%ebp
  800150:	56                   	push   %esi
  800151:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800152:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800155:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80015b:	e8 10 0a 00 00       	call   800b70 <sys_getenvid>
  800160:	83 ec 0c             	sub    $0xc,%esp
  800163:	ff 75 0c             	pushl  0xc(%ebp)
  800166:	ff 75 08             	pushl  0x8(%ebp)
  800169:	56                   	push   %esi
  80016a:	50                   	push   %eax
  80016b:	68 04 22 80 00       	push   $0x802204
  800170:	e8 b1 00 00 00       	call   800226 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800175:	83 c4 18             	add    $0x18,%esp
  800178:	53                   	push   %ebx
  800179:	ff 75 10             	pushl  0x10(%ebp)
  80017c:	e8 54 00 00 00       	call   8001d5 <vcprintf>
	cprintf("\n");
  800181:	c7 04 24 f7 21 80 00 	movl   $0x8021f7,(%esp)
  800188:	e8 99 00 00 00       	call   800226 <cprintf>
  80018d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800190:	cc                   	int3   
  800191:	eb fd                	jmp    800190 <_panic+0x43>

00800193 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800193:	55                   	push   %ebp
  800194:	89 e5                	mov    %esp,%ebp
  800196:	53                   	push   %ebx
  800197:	83 ec 04             	sub    $0x4,%esp
  80019a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80019d:	8b 13                	mov    (%ebx),%edx
  80019f:	8d 42 01             	lea    0x1(%edx),%eax
  8001a2:	89 03                	mov    %eax,(%ebx)
  8001a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001a7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001ab:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001b0:	75 1a                	jne    8001cc <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001b2:	83 ec 08             	sub    $0x8,%esp
  8001b5:	68 ff 00 00 00       	push   $0xff
  8001ba:	8d 43 08             	lea    0x8(%ebx),%eax
  8001bd:	50                   	push   %eax
  8001be:	e8 2f 09 00 00       	call   800af2 <sys_cputs>
		b->idx = 0;
  8001c3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001c9:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001cc:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001d3:	c9                   	leave  
  8001d4:	c3                   	ret    

008001d5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001d5:	55                   	push   %ebp
  8001d6:	89 e5                	mov    %esp,%ebp
  8001d8:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001de:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001e5:	00 00 00 
	b.cnt = 0;
  8001e8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ef:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001f2:	ff 75 0c             	pushl  0xc(%ebp)
  8001f5:	ff 75 08             	pushl  0x8(%ebp)
  8001f8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001fe:	50                   	push   %eax
  8001ff:	68 93 01 80 00       	push   $0x800193
  800204:	e8 54 01 00 00       	call   80035d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800209:	83 c4 08             	add    $0x8,%esp
  80020c:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800212:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800218:	50                   	push   %eax
  800219:	e8 d4 08 00 00       	call   800af2 <sys_cputs>

	return b.cnt;
}
  80021e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800224:	c9                   	leave  
  800225:	c3                   	ret    

00800226 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800226:	55                   	push   %ebp
  800227:	89 e5                	mov    %esp,%ebp
  800229:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80022c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80022f:	50                   	push   %eax
  800230:	ff 75 08             	pushl  0x8(%ebp)
  800233:	e8 9d ff ff ff       	call   8001d5 <vcprintf>
	va_end(ap);

	return cnt;
}
  800238:	c9                   	leave  
  800239:	c3                   	ret    

0080023a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80023a:	55                   	push   %ebp
  80023b:	89 e5                	mov    %esp,%ebp
  80023d:	57                   	push   %edi
  80023e:	56                   	push   %esi
  80023f:	53                   	push   %ebx
  800240:	83 ec 1c             	sub    $0x1c,%esp
  800243:	89 c7                	mov    %eax,%edi
  800245:	89 d6                	mov    %edx,%esi
  800247:	8b 45 08             	mov    0x8(%ebp),%eax
  80024a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80024d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800250:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800253:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800256:	bb 00 00 00 00       	mov    $0x0,%ebx
  80025b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80025e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800261:	39 d3                	cmp    %edx,%ebx
  800263:	72 05                	jb     80026a <printnum+0x30>
  800265:	39 45 10             	cmp    %eax,0x10(%ebp)
  800268:	77 45                	ja     8002af <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80026a:	83 ec 0c             	sub    $0xc,%esp
  80026d:	ff 75 18             	pushl  0x18(%ebp)
  800270:	8b 45 14             	mov    0x14(%ebp),%eax
  800273:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800276:	53                   	push   %ebx
  800277:	ff 75 10             	pushl  0x10(%ebp)
  80027a:	83 ec 08             	sub    $0x8,%esp
  80027d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800280:	ff 75 e0             	pushl  -0x20(%ebp)
  800283:	ff 75 dc             	pushl  -0x24(%ebp)
  800286:	ff 75 d8             	pushl  -0x28(%ebp)
  800289:	e8 82 1c 00 00       	call   801f10 <__udivdi3>
  80028e:	83 c4 18             	add    $0x18,%esp
  800291:	52                   	push   %edx
  800292:	50                   	push   %eax
  800293:	89 f2                	mov    %esi,%edx
  800295:	89 f8                	mov    %edi,%eax
  800297:	e8 9e ff ff ff       	call   80023a <printnum>
  80029c:	83 c4 20             	add    $0x20,%esp
  80029f:	eb 18                	jmp    8002b9 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002a1:	83 ec 08             	sub    $0x8,%esp
  8002a4:	56                   	push   %esi
  8002a5:	ff 75 18             	pushl  0x18(%ebp)
  8002a8:	ff d7                	call   *%edi
  8002aa:	83 c4 10             	add    $0x10,%esp
  8002ad:	eb 03                	jmp    8002b2 <printnum+0x78>
  8002af:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002b2:	83 eb 01             	sub    $0x1,%ebx
  8002b5:	85 db                	test   %ebx,%ebx
  8002b7:	7f e8                	jg     8002a1 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002b9:	83 ec 08             	sub    $0x8,%esp
  8002bc:	56                   	push   %esi
  8002bd:	83 ec 04             	sub    $0x4,%esp
  8002c0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002c3:	ff 75 e0             	pushl  -0x20(%ebp)
  8002c6:	ff 75 dc             	pushl  -0x24(%ebp)
  8002c9:	ff 75 d8             	pushl  -0x28(%ebp)
  8002cc:	e8 6f 1d 00 00       	call   802040 <__umoddi3>
  8002d1:	83 c4 14             	add    $0x14,%esp
  8002d4:	0f be 80 27 22 80 00 	movsbl 0x802227(%eax),%eax
  8002db:	50                   	push   %eax
  8002dc:	ff d7                	call   *%edi
}
  8002de:	83 c4 10             	add    $0x10,%esp
  8002e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e4:	5b                   	pop    %ebx
  8002e5:	5e                   	pop    %esi
  8002e6:	5f                   	pop    %edi
  8002e7:	5d                   	pop    %ebp
  8002e8:	c3                   	ret    

008002e9 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002e9:	55                   	push   %ebp
  8002ea:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002ec:	83 fa 01             	cmp    $0x1,%edx
  8002ef:	7e 0e                	jle    8002ff <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002f1:	8b 10                	mov    (%eax),%edx
  8002f3:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002f6:	89 08                	mov    %ecx,(%eax)
  8002f8:	8b 02                	mov    (%edx),%eax
  8002fa:	8b 52 04             	mov    0x4(%edx),%edx
  8002fd:	eb 22                	jmp    800321 <getuint+0x38>
	else if (lflag)
  8002ff:	85 d2                	test   %edx,%edx
  800301:	74 10                	je     800313 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800303:	8b 10                	mov    (%eax),%edx
  800305:	8d 4a 04             	lea    0x4(%edx),%ecx
  800308:	89 08                	mov    %ecx,(%eax)
  80030a:	8b 02                	mov    (%edx),%eax
  80030c:	ba 00 00 00 00       	mov    $0x0,%edx
  800311:	eb 0e                	jmp    800321 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800313:	8b 10                	mov    (%eax),%edx
  800315:	8d 4a 04             	lea    0x4(%edx),%ecx
  800318:	89 08                	mov    %ecx,(%eax)
  80031a:	8b 02                	mov    (%edx),%eax
  80031c:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800321:	5d                   	pop    %ebp
  800322:	c3                   	ret    

00800323 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800323:	55                   	push   %ebp
  800324:	89 e5                	mov    %esp,%ebp
  800326:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800329:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80032d:	8b 10                	mov    (%eax),%edx
  80032f:	3b 50 04             	cmp    0x4(%eax),%edx
  800332:	73 0a                	jae    80033e <sprintputch+0x1b>
		*b->buf++ = ch;
  800334:	8d 4a 01             	lea    0x1(%edx),%ecx
  800337:	89 08                	mov    %ecx,(%eax)
  800339:	8b 45 08             	mov    0x8(%ebp),%eax
  80033c:	88 02                	mov    %al,(%edx)
}
  80033e:	5d                   	pop    %ebp
  80033f:	c3                   	ret    

00800340 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800340:	55                   	push   %ebp
  800341:	89 e5                	mov    %esp,%ebp
  800343:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800346:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800349:	50                   	push   %eax
  80034a:	ff 75 10             	pushl  0x10(%ebp)
  80034d:	ff 75 0c             	pushl  0xc(%ebp)
  800350:	ff 75 08             	pushl  0x8(%ebp)
  800353:	e8 05 00 00 00       	call   80035d <vprintfmt>
	va_end(ap);
}
  800358:	83 c4 10             	add    $0x10,%esp
  80035b:	c9                   	leave  
  80035c:	c3                   	ret    

0080035d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80035d:	55                   	push   %ebp
  80035e:	89 e5                	mov    %esp,%ebp
  800360:	57                   	push   %edi
  800361:	56                   	push   %esi
  800362:	53                   	push   %ebx
  800363:	83 ec 2c             	sub    $0x2c,%esp
  800366:	8b 75 08             	mov    0x8(%ebp),%esi
  800369:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80036c:	8b 7d 10             	mov    0x10(%ebp),%edi
  80036f:	eb 12                	jmp    800383 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800371:	85 c0                	test   %eax,%eax
  800373:	0f 84 89 03 00 00    	je     800702 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800379:	83 ec 08             	sub    $0x8,%esp
  80037c:	53                   	push   %ebx
  80037d:	50                   	push   %eax
  80037e:	ff d6                	call   *%esi
  800380:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800383:	83 c7 01             	add    $0x1,%edi
  800386:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80038a:	83 f8 25             	cmp    $0x25,%eax
  80038d:	75 e2                	jne    800371 <vprintfmt+0x14>
  80038f:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800393:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80039a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003a1:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8003ad:	eb 07                	jmp    8003b6 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003af:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003b2:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b6:	8d 47 01             	lea    0x1(%edi),%eax
  8003b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003bc:	0f b6 07             	movzbl (%edi),%eax
  8003bf:	0f b6 c8             	movzbl %al,%ecx
  8003c2:	83 e8 23             	sub    $0x23,%eax
  8003c5:	3c 55                	cmp    $0x55,%al
  8003c7:	0f 87 1a 03 00 00    	ja     8006e7 <vprintfmt+0x38a>
  8003cd:	0f b6 c0             	movzbl %al,%eax
  8003d0:	ff 24 85 60 23 80 00 	jmp    *0x802360(,%eax,4)
  8003d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003da:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003de:	eb d6                	jmp    8003b6 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8003e8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003eb:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003ee:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003f2:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003f5:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003f8:	83 fa 09             	cmp    $0x9,%edx
  8003fb:	77 39                	ja     800436 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003fd:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800400:	eb e9                	jmp    8003eb <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800402:	8b 45 14             	mov    0x14(%ebp),%eax
  800405:	8d 48 04             	lea    0x4(%eax),%ecx
  800408:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80040b:	8b 00                	mov    (%eax),%eax
  80040d:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800410:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800413:	eb 27                	jmp    80043c <vprintfmt+0xdf>
  800415:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800418:	85 c0                	test   %eax,%eax
  80041a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80041f:	0f 49 c8             	cmovns %eax,%ecx
  800422:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800425:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800428:	eb 8c                	jmp    8003b6 <vprintfmt+0x59>
  80042a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80042d:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800434:	eb 80                	jmp    8003b6 <vprintfmt+0x59>
  800436:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800439:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80043c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800440:	0f 89 70 ff ff ff    	jns    8003b6 <vprintfmt+0x59>
				width = precision, precision = -1;
  800446:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800449:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80044c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800453:	e9 5e ff ff ff       	jmp    8003b6 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800458:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80045e:	e9 53 ff ff ff       	jmp    8003b6 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800463:	8b 45 14             	mov    0x14(%ebp),%eax
  800466:	8d 50 04             	lea    0x4(%eax),%edx
  800469:	89 55 14             	mov    %edx,0x14(%ebp)
  80046c:	83 ec 08             	sub    $0x8,%esp
  80046f:	53                   	push   %ebx
  800470:	ff 30                	pushl  (%eax)
  800472:	ff d6                	call   *%esi
			break;
  800474:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800477:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80047a:	e9 04 ff ff ff       	jmp    800383 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80047f:	8b 45 14             	mov    0x14(%ebp),%eax
  800482:	8d 50 04             	lea    0x4(%eax),%edx
  800485:	89 55 14             	mov    %edx,0x14(%ebp)
  800488:	8b 00                	mov    (%eax),%eax
  80048a:	99                   	cltd   
  80048b:	31 d0                	xor    %edx,%eax
  80048d:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80048f:	83 f8 0f             	cmp    $0xf,%eax
  800492:	7f 0b                	jg     80049f <vprintfmt+0x142>
  800494:	8b 14 85 c0 24 80 00 	mov    0x8024c0(,%eax,4),%edx
  80049b:	85 d2                	test   %edx,%edx
  80049d:	75 18                	jne    8004b7 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80049f:	50                   	push   %eax
  8004a0:	68 3f 22 80 00       	push   $0x80223f
  8004a5:	53                   	push   %ebx
  8004a6:	56                   	push   %esi
  8004a7:	e8 94 fe ff ff       	call   800340 <printfmt>
  8004ac:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004b2:	e9 cc fe ff ff       	jmp    800383 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004b7:	52                   	push   %edx
  8004b8:	68 7a 26 80 00       	push   $0x80267a
  8004bd:	53                   	push   %ebx
  8004be:	56                   	push   %esi
  8004bf:	e8 7c fe ff ff       	call   800340 <printfmt>
  8004c4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004ca:	e9 b4 fe ff ff       	jmp    800383 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d2:	8d 50 04             	lea    0x4(%eax),%edx
  8004d5:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d8:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004da:	85 ff                	test   %edi,%edi
  8004dc:	b8 38 22 80 00       	mov    $0x802238,%eax
  8004e1:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004e4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004e8:	0f 8e 94 00 00 00    	jle    800582 <vprintfmt+0x225>
  8004ee:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004f2:	0f 84 98 00 00 00    	je     800590 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f8:	83 ec 08             	sub    $0x8,%esp
  8004fb:	ff 75 d0             	pushl  -0x30(%ebp)
  8004fe:	57                   	push   %edi
  8004ff:	e8 86 02 00 00       	call   80078a <strnlen>
  800504:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800507:	29 c1                	sub    %eax,%ecx
  800509:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80050c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80050f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800513:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800516:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800519:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80051b:	eb 0f                	jmp    80052c <vprintfmt+0x1cf>
					putch(padc, putdat);
  80051d:	83 ec 08             	sub    $0x8,%esp
  800520:	53                   	push   %ebx
  800521:	ff 75 e0             	pushl  -0x20(%ebp)
  800524:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800526:	83 ef 01             	sub    $0x1,%edi
  800529:	83 c4 10             	add    $0x10,%esp
  80052c:	85 ff                	test   %edi,%edi
  80052e:	7f ed                	jg     80051d <vprintfmt+0x1c0>
  800530:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800533:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800536:	85 c9                	test   %ecx,%ecx
  800538:	b8 00 00 00 00       	mov    $0x0,%eax
  80053d:	0f 49 c1             	cmovns %ecx,%eax
  800540:	29 c1                	sub    %eax,%ecx
  800542:	89 75 08             	mov    %esi,0x8(%ebp)
  800545:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800548:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80054b:	89 cb                	mov    %ecx,%ebx
  80054d:	eb 4d                	jmp    80059c <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80054f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800553:	74 1b                	je     800570 <vprintfmt+0x213>
  800555:	0f be c0             	movsbl %al,%eax
  800558:	83 e8 20             	sub    $0x20,%eax
  80055b:	83 f8 5e             	cmp    $0x5e,%eax
  80055e:	76 10                	jbe    800570 <vprintfmt+0x213>
					putch('?', putdat);
  800560:	83 ec 08             	sub    $0x8,%esp
  800563:	ff 75 0c             	pushl  0xc(%ebp)
  800566:	6a 3f                	push   $0x3f
  800568:	ff 55 08             	call   *0x8(%ebp)
  80056b:	83 c4 10             	add    $0x10,%esp
  80056e:	eb 0d                	jmp    80057d <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800570:	83 ec 08             	sub    $0x8,%esp
  800573:	ff 75 0c             	pushl  0xc(%ebp)
  800576:	52                   	push   %edx
  800577:	ff 55 08             	call   *0x8(%ebp)
  80057a:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80057d:	83 eb 01             	sub    $0x1,%ebx
  800580:	eb 1a                	jmp    80059c <vprintfmt+0x23f>
  800582:	89 75 08             	mov    %esi,0x8(%ebp)
  800585:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800588:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80058b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80058e:	eb 0c                	jmp    80059c <vprintfmt+0x23f>
  800590:	89 75 08             	mov    %esi,0x8(%ebp)
  800593:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800596:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800599:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80059c:	83 c7 01             	add    $0x1,%edi
  80059f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005a3:	0f be d0             	movsbl %al,%edx
  8005a6:	85 d2                	test   %edx,%edx
  8005a8:	74 23                	je     8005cd <vprintfmt+0x270>
  8005aa:	85 f6                	test   %esi,%esi
  8005ac:	78 a1                	js     80054f <vprintfmt+0x1f2>
  8005ae:	83 ee 01             	sub    $0x1,%esi
  8005b1:	79 9c                	jns    80054f <vprintfmt+0x1f2>
  8005b3:	89 df                	mov    %ebx,%edi
  8005b5:	8b 75 08             	mov    0x8(%ebp),%esi
  8005b8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005bb:	eb 18                	jmp    8005d5 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005bd:	83 ec 08             	sub    $0x8,%esp
  8005c0:	53                   	push   %ebx
  8005c1:	6a 20                	push   $0x20
  8005c3:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005c5:	83 ef 01             	sub    $0x1,%edi
  8005c8:	83 c4 10             	add    $0x10,%esp
  8005cb:	eb 08                	jmp    8005d5 <vprintfmt+0x278>
  8005cd:	89 df                	mov    %ebx,%edi
  8005cf:	8b 75 08             	mov    0x8(%ebp),%esi
  8005d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005d5:	85 ff                	test   %edi,%edi
  8005d7:	7f e4                	jg     8005bd <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005dc:	e9 a2 fd ff ff       	jmp    800383 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005e1:	83 fa 01             	cmp    $0x1,%edx
  8005e4:	7e 16                	jle    8005fc <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e9:	8d 50 08             	lea    0x8(%eax),%edx
  8005ec:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ef:	8b 50 04             	mov    0x4(%eax),%edx
  8005f2:	8b 00                	mov    (%eax),%eax
  8005f4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005fa:	eb 32                	jmp    80062e <vprintfmt+0x2d1>
	else if (lflag)
  8005fc:	85 d2                	test   %edx,%edx
  8005fe:	74 18                	je     800618 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800600:	8b 45 14             	mov    0x14(%ebp),%eax
  800603:	8d 50 04             	lea    0x4(%eax),%edx
  800606:	89 55 14             	mov    %edx,0x14(%ebp)
  800609:	8b 00                	mov    (%eax),%eax
  80060b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80060e:	89 c1                	mov    %eax,%ecx
  800610:	c1 f9 1f             	sar    $0x1f,%ecx
  800613:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800616:	eb 16                	jmp    80062e <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800618:	8b 45 14             	mov    0x14(%ebp),%eax
  80061b:	8d 50 04             	lea    0x4(%eax),%edx
  80061e:	89 55 14             	mov    %edx,0x14(%ebp)
  800621:	8b 00                	mov    (%eax),%eax
  800623:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800626:	89 c1                	mov    %eax,%ecx
  800628:	c1 f9 1f             	sar    $0x1f,%ecx
  80062b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80062e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800631:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800634:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800639:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80063d:	79 74                	jns    8006b3 <vprintfmt+0x356>
				putch('-', putdat);
  80063f:	83 ec 08             	sub    $0x8,%esp
  800642:	53                   	push   %ebx
  800643:	6a 2d                	push   $0x2d
  800645:	ff d6                	call   *%esi
				num = -(long long) num;
  800647:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80064a:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80064d:	f7 d8                	neg    %eax
  80064f:	83 d2 00             	adc    $0x0,%edx
  800652:	f7 da                	neg    %edx
  800654:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800657:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80065c:	eb 55                	jmp    8006b3 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80065e:	8d 45 14             	lea    0x14(%ebp),%eax
  800661:	e8 83 fc ff ff       	call   8002e9 <getuint>
			base = 10;
  800666:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80066b:	eb 46                	jmp    8006b3 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80066d:	8d 45 14             	lea    0x14(%ebp),%eax
  800670:	e8 74 fc ff ff       	call   8002e9 <getuint>
                        base = 8;
  800675:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  80067a:	eb 37                	jmp    8006b3 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80067c:	83 ec 08             	sub    $0x8,%esp
  80067f:	53                   	push   %ebx
  800680:	6a 30                	push   $0x30
  800682:	ff d6                	call   *%esi
			putch('x', putdat);
  800684:	83 c4 08             	add    $0x8,%esp
  800687:	53                   	push   %ebx
  800688:	6a 78                	push   $0x78
  80068a:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80068c:	8b 45 14             	mov    0x14(%ebp),%eax
  80068f:	8d 50 04             	lea    0x4(%eax),%edx
  800692:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800695:	8b 00                	mov    (%eax),%eax
  800697:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80069c:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80069f:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006a4:	eb 0d                	jmp    8006b3 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006a6:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a9:	e8 3b fc ff ff       	call   8002e9 <getuint>
			base = 16;
  8006ae:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006b3:	83 ec 0c             	sub    $0xc,%esp
  8006b6:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006ba:	57                   	push   %edi
  8006bb:	ff 75 e0             	pushl  -0x20(%ebp)
  8006be:	51                   	push   %ecx
  8006bf:	52                   	push   %edx
  8006c0:	50                   	push   %eax
  8006c1:	89 da                	mov    %ebx,%edx
  8006c3:	89 f0                	mov    %esi,%eax
  8006c5:	e8 70 fb ff ff       	call   80023a <printnum>
			break;
  8006ca:	83 c4 20             	add    $0x20,%esp
  8006cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006d0:	e9 ae fc ff ff       	jmp    800383 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006d5:	83 ec 08             	sub    $0x8,%esp
  8006d8:	53                   	push   %ebx
  8006d9:	51                   	push   %ecx
  8006da:	ff d6                	call   *%esi
			break;
  8006dc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006e2:	e9 9c fc ff ff       	jmp    800383 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006e7:	83 ec 08             	sub    $0x8,%esp
  8006ea:	53                   	push   %ebx
  8006eb:	6a 25                	push   $0x25
  8006ed:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006ef:	83 c4 10             	add    $0x10,%esp
  8006f2:	eb 03                	jmp    8006f7 <vprintfmt+0x39a>
  8006f4:	83 ef 01             	sub    $0x1,%edi
  8006f7:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006fb:	75 f7                	jne    8006f4 <vprintfmt+0x397>
  8006fd:	e9 81 fc ff ff       	jmp    800383 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800702:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800705:	5b                   	pop    %ebx
  800706:	5e                   	pop    %esi
  800707:	5f                   	pop    %edi
  800708:	5d                   	pop    %ebp
  800709:	c3                   	ret    

0080070a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80070a:	55                   	push   %ebp
  80070b:	89 e5                	mov    %esp,%ebp
  80070d:	83 ec 18             	sub    $0x18,%esp
  800710:	8b 45 08             	mov    0x8(%ebp),%eax
  800713:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800716:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800719:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80071d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800720:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800727:	85 c0                	test   %eax,%eax
  800729:	74 26                	je     800751 <vsnprintf+0x47>
  80072b:	85 d2                	test   %edx,%edx
  80072d:	7e 22                	jle    800751 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80072f:	ff 75 14             	pushl  0x14(%ebp)
  800732:	ff 75 10             	pushl  0x10(%ebp)
  800735:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800738:	50                   	push   %eax
  800739:	68 23 03 80 00       	push   $0x800323
  80073e:	e8 1a fc ff ff       	call   80035d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800743:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800746:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800749:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80074c:	83 c4 10             	add    $0x10,%esp
  80074f:	eb 05                	jmp    800756 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800751:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800756:	c9                   	leave  
  800757:	c3                   	ret    

00800758 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800758:	55                   	push   %ebp
  800759:	89 e5                	mov    %esp,%ebp
  80075b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80075e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800761:	50                   	push   %eax
  800762:	ff 75 10             	pushl  0x10(%ebp)
  800765:	ff 75 0c             	pushl  0xc(%ebp)
  800768:	ff 75 08             	pushl  0x8(%ebp)
  80076b:	e8 9a ff ff ff       	call   80070a <vsnprintf>
	va_end(ap);

	return rc;
}
  800770:	c9                   	leave  
  800771:	c3                   	ret    

00800772 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800772:	55                   	push   %ebp
  800773:	89 e5                	mov    %esp,%ebp
  800775:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800778:	b8 00 00 00 00       	mov    $0x0,%eax
  80077d:	eb 03                	jmp    800782 <strlen+0x10>
		n++;
  80077f:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800782:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800786:	75 f7                	jne    80077f <strlen+0xd>
		n++;
	return n;
}
  800788:	5d                   	pop    %ebp
  800789:	c3                   	ret    

0080078a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80078a:	55                   	push   %ebp
  80078b:	89 e5                	mov    %esp,%ebp
  80078d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800790:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800793:	ba 00 00 00 00       	mov    $0x0,%edx
  800798:	eb 03                	jmp    80079d <strnlen+0x13>
		n++;
  80079a:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80079d:	39 c2                	cmp    %eax,%edx
  80079f:	74 08                	je     8007a9 <strnlen+0x1f>
  8007a1:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007a5:	75 f3                	jne    80079a <strnlen+0x10>
  8007a7:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007a9:	5d                   	pop    %ebp
  8007aa:	c3                   	ret    

008007ab <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007ab:	55                   	push   %ebp
  8007ac:	89 e5                	mov    %esp,%ebp
  8007ae:	53                   	push   %ebx
  8007af:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007b5:	89 c2                	mov    %eax,%edx
  8007b7:	83 c2 01             	add    $0x1,%edx
  8007ba:	83 c1 01             	add    $0x1,%ecx
  8007bd:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007c1:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007c4:	84 db                	test   %bl,%bl
  8007c6:	75 ef                	jne    8007b7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007c8:	5b                   	pop    %ebx
  8007c9:	5d                   	pop    %ebp
  8007ca:	c3                   	ret    

008007cb <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007cb:	55                   	push   %ebp
  8007cc:	89 e5                	mov    %esp,%ebp
  8007ce:	53                   	push   %ebx
  8007cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007d2:	53                   	push   %ebx
  8007d3:	e8 9a ff ff ff       	call   800772 <strlen>
  8007d8:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007db:	ff 75 0c             	pushl  0xc(%ebp)
  8007de:	01 d8                	add    %ebx,%eax
  8007e0:	50                   	push   %eax
  8007e1:	e8 c5 ff ff ff       	call   8007ab <strcpy>
	return dst;
}
  8007e6:	89 d8                	mov    %ebx,%eax
  8007e8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007eb:	c9                   	leave  
  8007ec:	c3                   	ret    

008007ed <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007ed:	55                   	push   %ebp
  8007ee:	89 e5                	mov    %esp,%ebp
  8007f0:	56                   	push   %esi
  8007f1:	53                   	push   %ebx
  8007f2:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f8:	89 f3                	mov    %esi,%ebx
  8007fa:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007fd:	89 f2                	mov    %esi,%edx
  8007ff:	eb 0f                	jmp    800810 <strncpy+0x23>
		*dst++ = *src;
  800801:	83 c2 01             	add    $0x1,%edx
  800804:	0f b6 01             	movzbl (%ecx),%eax
  800807:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80080a:	80 39 01             	cmpb   $0x1,(%ecx)
  80080d:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800810:	39 da                	cmp    %ebx,%edx
  800812:	75 ed                	jne    800801 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800814:	89 f0                	mov    %esi,%eax
  800816:	5b                   	pop    %ebx
  800817:	5e                   	pop    %esi
  800818:	5d                   	pop    %ebp
  800819:	c3                   	ret    

0080081a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80081a:	55                   	push   %ebp
  80081b:	89 e5                	mov    %esp,%ebp
  80081d:	56                   	push   %esi
  80081e:	53                   	push   %ebx
  80081f:	8b 75 08             	mov    0x8(%ebp),%esi
  800822:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800825:	8b 55 10             	mov    0x10(%ebp),%edx
  800828:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80082a:	85 d2                	test   %edx,%edx
  80082c:	74 21                	je     80084f <strlcpy+0x35>
  80082e:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800832:	89 f2                	mov    %esi,%edx
  800834:	eb 09                	jmp    80083f <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800836:	83 c2 01             	add    $0x1,%edx
  800839:	83 c1 01             	add    $0x1,%ecx
  80083c:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80083f:	39 c2                	cmp    %eax,%edx
  800841:	74 09                	je     80084c <strlcpy+0x32>
  800843:	0f b6 19             	movzbl (%ecx),%ebx
  800846:	84 db                	test   %bl,%bl
  800848:	75 ec                	jne    800836 <strlcpy+0x1c>
  80084a:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80084c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80084f:	29 f0                	sub    %esi,%eax
}
  800851:	5b                   	pop    %ebx
  800852:	5e                   	pop    %esi
  800853:	5d                   	pop    %ebp
  800854:	c3                   	ret    

00800855 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800855:	55                   	push   %ebp
  800856:	89 e5                	mov    %esp,%ebp
  800858:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80085b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80085e:	eb 06                	jmp    800866 <strcmp+0x11>
		p++, q++;
  800860:	83 c1 01             	add    $0x1,%ecx
  800863:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800866:	0f b6 01             	movzbl (%ecx),%eax
  800869:	84 c0                	test   %al,%al
  80086b:	74 04                	je     800871 <strcmp+0x1c>
  80086d:	3a 02                	cmp    (%edx),%al
  80086f:	74 ef                	je     800860 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800871:	0f b6 c0             	movzbl %al,%eax
  800874:	0f b6 12             	movzbl (%edx),%edx
  800877:	29 d0                	sub    %edx,%eax
}
  800879:	5d                   	pop    %ebp
  80087a:	c3                   	ret    

0080087b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	53                   	push   %ebx
  80087f:	8b 45 08             	mov    0x8(%ebp),%eax
  800882:	8b 55 0c             	mov    0xc(%ebp),%edx
  800885:	89 c3                	mov    %eax,%ebx
  800887:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80088a:	eb 06                	jmp    800892 <strncmp+0x17>
		n--, p++, q++;
  80088c:	83 c0 01             	add    $0x1,%eax
  80088f:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800892:	39 d8                	cmp    %ebx,%eax
  800894:	74 15                	je     8008ab <strncmp+0x30>
  800896:	0f b6 08             	movzbl (%eax),%ecx
  800899:	84 c9                	test   %cl,%cl
  80089b:	74 04                	je     8008a1 <strncmp+0x26>
  80089d:	3a 0a                	cmp    (%edx),%cl
  80089f:	74 eb                	je     80088c <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a1:	0f b6 00             	movzbl (%eax),%eax
  8008a4:	0f b6 12             	movzbl (%edx),%edx
  8008a7:	29 d0                	sub    %edx,%eax
  8008a9:	eb 05                	jmp    8008b0 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008ab:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008b0:	5b                   	pop    %ebx
  8008b1:	5d                   	pop    %ebp
  8008b2:	c3                   	ret    

008008b3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008b3:	55                   	push   %ebp
  8008b4:	89 e5                	mov    %esp,%ebp
  8008b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008bd:	eb 07                	jmp    8008c6 <strchr+0x13>
		if (*s == c)
  8008bf:	38 ca                	cmp    %cl,%dl
  8008c1:	74 0f                	je     8008d2 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008c3:	83 c0 01             	add    $0x1,%eax
  8008c6:	0f b6 10             	movzbl (%eax),%edx
  8008c9:	84 d2                	test   %dl,%dl
  8008cb:	75 f2                	jne    8008bf <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008cd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008d2:	5d                   	pop    %ebp
  8008d3:	c3                   	ret    

008008d4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008d4:	55                   	push   %ebp
  8008d5:	89 e5                	mov    %esp,%ebp
  8008d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008da:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008de:	eb 03                	jmp    8008e3 <strfind+0xf>
  8008e0:	83 c0 01             	add    $0x1,%eax
  8008e3:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008e6:	38 ca                	cmp    %cl,%dl
  8008e8:	74 04                	je     8008ee <strfind+0x1a>
  8008ea:	84 d2                	test   %dl,%dl
  8008ec:	75 f2                	jne    8008e0 <strfind+0xc>
			break;
	return (char *) s;
}
  8008ee:	5d                   	pop    %ebp
  8008ef:	c3                   	ret    

008008f0 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008f0:	55                   	push   %ebp
  8008f1:	89 e5                	mov    %esp,%ebp
  8008f3:	57                   	push   %edi
  8008f4:	56                   	push   %esi
  8008f5:	53                   	push   %ebx
  8008f6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008f9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008fc:	85 c9                	test   %ecx,%ecx
  8008fe:	74 36                	je     800936 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800900:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800906:	75 28                	jne    800930 <memset+0x40>
  800908:	f6 c1 03             	test   $0x3,%cl
  80090b:	75 23                	jne    800930 <memset+0x40>
		c &= 0xFF;
  80090d:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800911:	89 d3                	mov    %edx,%ebx
  800913:	c1 e3 08             	shl    $0x8,%ebx
  800916:	89 d6                	mov    %edx,%esi
  800918:	c1 e6 18             	shl    $0x18,%esi
  80091b:	89 d0                	mov    %edx,%eax
  80091d:	c1 e0 10             	shl    $0x10,%eax
  800920:	09 f0                	or     %esi,%eax
  800922:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800924:	89 d8                	mov    %ebx,%eax
  800926:	09 d0                	or     %edx,%eax
  800928:	c1 e9 02             	shr    $0x2,%ecx
  80092b:	fc                   	cld    
  80092c:	f3 ab                	rep stos %eax,%es:(%edi)
  80092e:	eb 06                	jmp    800936 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800930:	8b 45 0c             	mov    0xc(%ebp),%eax
  800933:	fc                   	cld    
  800934:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800936:	89 f8                	mov    %edi,%eax
  800938:	5b                   	pop    %ebx
  800939:	5e                   	pop    %esi
  80093a:	5f                   	pop    %edi
  80093b:	5d                   	pop    %ebp
  80093c:	c3                   	ret    

0080093d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80093d:	55                   	push   %ebp
  80093e:	89 e5                	mov    %esp,%ebp
  800940:	57                   	push   %edi
  800941:	56                   	push   %esi
  800942:	8b 45 08             	mov    0x8(%ebp),%eax
  800945:	8b 75 0c             	mov    0xc(%ebp),%esi
  800948:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80094b:	39 c6                	cmp    %eax,%esi
  80094d:	73 35                	jae    800984 <memmove+0x47>
  80094f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800952:	39 d0                	cmp    %edx,%eax
  800954:	73 2e                	jae    800984 <memmove+0x47>
		s += n;
		d += n;
  800956:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800959:	89 d6                	mov    %edx,%esi
  80095b:	09 fe                	or     %edi,%esi
  80095d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800963:	75 13                	jne    800978 <memmove+0x3b>
  800965:	f6 c1 03             	test   $0x3,%cl
  800968:	75 0e                	jne    800978 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80096a:	83 ef 04             	sub    $0x4,%edi
  80096d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800970:	c1 e9 02             	shr    $0x2,%ecx
  800973:	fd                   	std    
  800974:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800976:	eb 09                	jmp    800981 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800978:	83 ef 01             	sub    $0x1,%edi
  80097b:	8d 72 ff             	lea    -0x1(%edx),%esi
  80097e:	fd                   	std    
  80097f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800981:	fc                   	cld    
  800982:	eb 1d                	jmp    8009a1 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800984:	89 f2                	mov    %esi,%edx
  800986:	09 c2                	or     %eax,%edx
  800988:	f6 c2 03             	test   $0x3,%dl
  80098b:	75 0f                	jne    80099c <memmove+0x5f>
  80098d:	f6 c1 03             	test   $0x3,%cl
  800990:	75 0a                	jne    80099c <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800992:	c1 e9 02             	shr    $0x2,%ecx
  800995:	89 c7                	mov    %eax,%edi
  800997:	fc                   	cld    
  800998:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80099a:	eb 05                	jmp    8009a1 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80099c:	89 c7                	mov    %eax,%edi
  80099e:	fc                   	cld    
  80099f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009a1:	5e                   	pop    %esi
  8009a2:	5f                   	pop    %edi
  8009a3:	5d                   	pop    %ebp
  8009a4:	c3                   	ret    

008009a5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009a5:	55                   	push   %ebp
  8009a6:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009a8:	ff 75 10             	pushl  0x10(%ebp)
  8009ab:	ff 75 0c             	pushl  0xc(%ebp)
  8009ae:	ff 75 08             	pushl  0x8(%ebp)
  8009b1:	e8 87 ff ff ff       	call   80093d <memmove>
}
  8009b6:	c9                   	leave  
  8009b7:	c3                   	ret    

008009b8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009b8:	55                   	push   %ebp
  8009b9:	89 e5                	mov    %esp,%ebp
  8009bb:	56                   	push   %esi
  8009bc:	53                   	push   %ebx
  8009bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009c3:	89 c6                	mov    %eax,%esi
  8009c5:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009c8:	eb 1a                	jmp    8009e4 <memcmp+0x2c>
		if (*s1 != *s2)
  8009ca:	0f b6 08             	movzbl (%eax),%ecx
  8009cd:	0f b6 1a             	movzbl (%edx),%ebx
  8009d0:	38 d9                	cmp    %bl,%cl
  8009d2:	74 0a                	je     8009de <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009d4:	0f b6 c1             	movzbl %cl,%eax
  8009d7:	0f b6 db             	movzbl %bl,%ebx
  8009da:	29 d8                	sub    %ebx,%eax
  8009dc:	eb 0f                	jmp    8009ed <memcmp+0x35>
		s1++, s2++;
  8009de:	83 c0 01             	add    $0x1,%eax
  8009e1:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009e4:	39 f0                	cmp    %esi,%eax
  8009e6:	75 e2                	jne    8009ca <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009e8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ed:	5b                   	pop    %ebx
  8009ee:	5e                   	pop    %esi
  8009ef:	5d                   	pop    %ebp
  8009f0:	c3                   	ret    

008009f1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009f1:	55                   	push   %ebp
  8009f2:	89 e5                	mov    %esp,%ebp
  8009f4:	53                   	push   %ebx
  8009f5:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009f8:	89 c1                	mov    %eax,%ecx
  8009fa:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009fd:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a01:	eb 0a                	jmp    800a0d <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a03:	0f b6 10             	movzbl (%eax),%edx
  800a06:	39 da                	cmp    %ebx,%edx
  800a08:	74 07                	je     800a11 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a0a:	83 c0 01             	add    $0x1,%eax
  800a0d:	39 c8                	cmp    %ecx,%eax
  800a0f:	72 f2                	jb     800a03 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a11:	5b                   	pop    %ebx
  800a12:	5d                   	pop    %ebp
  800a13:	c3                   	ret    

00800a14 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	57                   	push   %edi
  800a18:	56                   	push   %esi
  800a19:	53                   	push   %ebx
  800a1a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a1d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a20:	eb 03                	jmp    800a25 <strtol+0x11>
		s++;
  800a22:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a25:	0f b6 01             	movzbl (%ecx),%eax
  800a28:	3c 20                	cmp    $0x20,%al
  800a2a:	74 f6                	je     800a22 <strtol+0xe>
  800a2c:	3c 09                	cmp    $0x9,%al
  800a2e:	74 f2                	je     800a22 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a30:	3c 2b                	cmp    $0x2b,%al
  800a32:	75 0a                	jne    800a3e <strtol+0x2a>
		s++;
  800a34:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a37:	bf 00 00 00 00       	mov    $0x0,%edi
  800a3c:	eb 11                	jmp    800a4f <strtol+0x3b>
  800a3e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a43:	3c 2d                	cmp    $0x2d,%al
  800a45:	75 08                	jne    800a4f <strtol+0x3b>
		s++, neg = 1;
  800a47:	83 c1 01             	add    $0x1,%ecx
  800a4a:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a4f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a55:	75 15                	jne    800a6c <strtol+0x58>
  800a57:	80 39 30             	cmpb   $0x30,(%ecx)
  800a5a:	75 10                	jne    800a6c <strtol+0x58>
  800a5c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a60:	75 7c                	jne    800ade <strtol+0xca>
		s += 2, base = 16;
  800a62:	83 c1 02             	add    $0x2,%ecx
  800a65:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a6a:	eb 16                	jmp    800a82 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a6c:	85 db                	test   %ebx,%ebx
  800a6e:	75 12                	jne    800a82 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a70:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a75:	80 39 30             	cmpb   $0x30,(%ecx)
  800a78:	75 08                	jne    800a82 <strtol+0x6e>
		s++, base = 8;
  800a7a:	83 c1 01             	add    $0x1,%ecx
  800a7d:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a82:	b8 00 00 00 00       	mov    $0x0,%eax
  800a87:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a8a:	0f b6 11             	movzbl (%ecx),%edx
  800a8d:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a90:	89 f3                	mov    %esi,%ebx
  800a92:	80 fb 09             	cmp    $0x9,%bl
  800a95:	77 08                	ja     800a9f <strtol+0x8b>
			dig = *s - '0';
  800a97:	0f be d2             	movsbl %dl,%edx
  800a9a:	83 ea 30             	sub    $0x30,%edx
  800a9d:	eb 22                	jmp    800ac1 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a9f:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aa2:	89 f3                	mov    %esi,%ebx
  800aa4:	80 fb 19             	cmp    $0x19,%bl
  800aa7:	77 08                	ja     800ab1 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800aa9:	0f be d2             	movsbl %dl,%edx
  800aac:	83 ea 57             	sub    $0x57,%edx
  800aaf:	eb 10                	jmp    800ac1 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ab1:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ab4:	89 f3                	mov    %esi,%ebx
  800ab6:	80 fb 19             	cmp    $0x19,%bl
  800ab9:	77 16                	ja     800ad1 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800abb:	0f be d2             	movsbl %dl,%edx
  800abe:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ac1:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ac4:	7d 0b                	jge    800ad1 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ac6:	83 c1 01             	add    $0x1,%ecx
  800ac9:	0f af 45 10          	imul   0x10(%ebp),%eax
  800acd:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800acf:	eb b9                	jmp    800a8a <strtol+0x76>

	if (endptr)
  800ad1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ad5:	74 0d                	je     800ae4 <strtol+0xd0>
		*endptr = (char *) s;
  800ad7:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ada:	89 0e                	mov    %ecx,(%esi)
  800adc:	eb 06                	jmp    800ae4 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ade:	85 db                	test   %ebx,%ebx
  800ae0:	74 98                	je     800a7a <strtol+0x66>
  800ae2:	eb 9e                	jmp    800a82 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ae4:	89 c2                	mov    %eax,%edx
  800ae6:	f7 da                	neg    %edx
  800ae8:	85 ff                	test   %edi,%edi
  800aea:	0f 45 c2             	cmovne %edx,%eax
}
  800aed:	5b                   	pop    %ebx
  800aee:	5e                   	pop    %esi
  800aef:	5f                   	pop    %edi
  800af0:	5d                   	pop    %ebp
  800af1:	c3                   	ret    

00800af2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800af2:	55                   	push   %ebp
  800af3:	89 e5                	mov    %esp,%ebp
  800af5:	57                   	push   %edi
  800af6:	56                   	push   %esi
  800af7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af8:	b8 00 00 00 00       	mov    $0x0,%eax
  800afd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b00:	8b 55 08             	mov    0x8(%ebp),%edx
  800b03:	89 c3                	mov    %eax,%ebx
  800b05:	89 c7                	mov    %eax,%edi
  800b07:	89 c6                	mov    %eax,%esi
  800b09:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b0b:	5b                   	pop    %ebx
  800b0c:	5e                   	pop    %esi
  800b0d:	5f                   	pop    %edi
  800b0e:	5d                   	pop    %ebp
  800b0f:	c3                   	ret    

00800b10 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b10:	55                   	push   %ebp
  800b11:	89 e5                	mov    %esp,%ebp
  800b13:	57                   	push   %edi
  800b14:	56                   	push   %esi
  800b15:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b16:	ba 00 00 00 00       	mov    $0x0,%edx
  800b1b:	b8 01 00 00 00       	mov    $0x1,%eax
  800b20:	89 d1                	mov    %edx,%ecx
  800b22:	89 d3                	mov    %edx,%ebx
  800b24:	89 d7                	mov    %edx,%edi
  800b26:	89 d6                	mov    %edx,%esi
  800b28:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b2a:	5b                   	pop    %ebx
  800b2b:	5e                   	pop    %esi
  800b2c:	5f                   	pop    %edi
  800b2d:	5d                   	pop    %ebp
  800b2e:	c3                   	ret    

00800b2f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b2f:	55                   	push   %ebp
  800b30:	89 e5                	mov    %esp,%ebp
  800b32:	57                   	push   %edi
  800b33:	56                   	push   %esi
  800b34:	53                   	push   %ebx
  800b35:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b38:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b3d:	b8 03 00 00 00       	mov    $0x3,%eax
  800b42:	8b 55 08             	mov    0x8(%ebp),%edx
  800b45:	89 cb                	mov    %ecx,%ebx
  800b47:	89 cf                	mov    %ecx,%edi
  800b49:	89 ce                	mov    %ecx,%esi
  800b4b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b4d:	85 c0                	test   %eax,%eax
  800b4f:	7e 17                	jle    800b68 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b51:	83 ec 0c             	sub    $0xc,%esp
  800b54:	50                   	push   %eax
  800b55:	6a 03                	push   $0x3
  800b57:	68 1f 25 80 00       	push   $0x80251f
  800b5c:	6a 23                	push   $0x23
  800b5e:	68 3c 25 80 00       	push   $0x80253c
  800b63:	e8 e5 f5 ff ff       	call   80014d <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b68:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b6b:	5b                   	pop    %ebx
  800b6c:	5e                   	pop    %esi
  800b6d:	5f                   	pop    %edi
  800b6e:	5d                   	pop    %ebp
  800b6f:	c3                   	ret    

00800b70 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b70:	55                   	push   %ebp
  800b71:	89 e5                	mov    %esp,%ebp
  800b73:	57                   	push   %edi
  800b74:	56                   	push   %esi
  800b75:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b76:	ba 00 00 00 00       	mov    $0x0,%edx
  800b7b:	b8 02 00 00 00       	mov    $0x2,%eax
  800b80:	89 d1                	mov    %edx,%ecx
  800b82:	89 d3                	mov    %edx,%ebx
  800b84:	89 d7                	mov    %edx,%edi
  800b86:	89 d6                	mov    %edx,%esi
  800b88:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b8a:	5b                   	pop    %ebx
  800b8b:	5e                   	pop    %esi
  800b8c:	5f                   	pop    %edi
  800b8d:	5d                   	pop    %ebp
  800b8e:	c3                   	ret    

00800b8f <sys_yield>:

void
sys_yield(void)
{
  800b8f:	55                   	push   %ebp
  800b90:	89 e5                	mov    %esp,%ebp
  800b92:	57                   	push   %edi
  800b93:	56                   	push   %esi
  800b94:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b95:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9a:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b9f:	89 d1                	mov    %edx,%ecx
  800ba1:	89 d3                	mov    %edx,%ebx
  800ba3:	89 d7                	mov    %edx,%edi
  800ba5:	89 d6                	mov    %edx,%esi
  800ba7:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ba9:	5b                   	pop    %ebx
  800baa:	5e                   	pop    %esi
  800bab:	5f                   	pop    %edi
  800bac:	5d                   	pop    %ebp
  800bad:	c3                   	ret    

00800bae <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bae:	55                   	push   %ebp
  800baf:	89 e5                	mov    %esp,%ebp
  800bb1:	57                   	push   %edi
  800bb2:	56                   	push   %esi
  800bb3:	53                   	push   %ebx
  800bb4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb7:	be 00 00 00 00       	mov    $0x0,%esi
  800bbc:	b8 04 00 00 00       	mov    $0x4,%eax
  800bc1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bca:	89 f7                	mov    %esi,%edi
  800bcc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bce:	85 c0                	test   %eax,%eax
  800bd0:	7e 17                	jle    800be9 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd2:	83 ec 0c             	sub    $0xc,%esp
  800bd5:	50                   	push   %eax
  800bd6:	6a 04                	push   $0x4
  800bd8:	68 1f 25 80 00       	push   $0x80251f
  800bdd:	6a 23                	push   $0x23
  800bdf:	68 3c 25 80 00       	push   $0x80253c
  800be4:	e8 64 f5 ff ff       	call   80014d <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800be9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bec:	5b                   	pop    %ebx
  800bed:	5e                   	pop    %esi
  800bee:	5f                   	pop    %edi
  800bef:	5d                   	pop    %ebp
  800bf0:	c3                   	ret    

00800bf1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bf1:	55                   	push   %ebp
  800bf2:	89 e5                	mov    %esp,%ebp
  800bf4:	57                   	push   %edi
  800bf5:	56                   	push   %esi
  800bf6:	53                   	push   %ebx
  800bf7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfa:	b8 05 00 00 00       	mov    $0x5,%eax
  800bff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c02:	8b 55 08             	mov    0x8(%ebp),%edx
  800c05:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c08:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c0b:	8b 75 18             	mov    0x18(%ebp),%esi
  800c0e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c10:	85 c0                	test   %eax,%eax
  800c12:	7e 17                	jle    800c2b <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c14:	83 ec 0c             	sub    $0xc,%esp
  800c17:	50                   	push   %eax
  800c18:	6a 05                	push   $0x5
  800c1a:	68 1f 25 80 00       	push   $0x80251f
  800c1f:	6a 23                	push   $0x23
  800c21:	68 3c 25 80 00       	push   $0x80253c
  800c26:	e8 22 f5 ff ff       	call   80014d <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c2b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2e:	5b                   	pop    %ebx
  800c2f:	5e                   	pop    %esi
  800c30:	5f                   	pop    %edi
  800c31:	5d                   	pop    %ebp
  800c32:	c3                   	ret    

00800c33 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c33:	55                   	push   %ebp
  800c34:	89 e5                	mov    %esp,%ebp
  800c36:	57                   	push   %edi
  800c37:	56                   	push   %esi
  800c38:	53                   	push   %ebx
  800c39:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c41:	b8 06 00 00 00       	mov    $0x6,%eax
  800c46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c49:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4c:	89 df                	mov    %ebx,%edi
  800c4e:	89 de                	mov    %ebx,%esi
  800c50:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c52:	85 c0                	test   %eax,%eax
  800c54:	7e 17                	jle    800c6d <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c56:	83 ec 0c             	sub    $0xc,%esp
  800c59:	50                   	push   %eax
  800c5a:	6a 06                	push   $0x6
  800c5c:	68 1f 25 80 00       	push   $0x80251f
  800c61:	6a 23                	push   $0x23
  800c63:	68 3c 25 80 00       	push   $0x80253c
  800c68:	e8 e0 f4 ff ff       	call   80014d <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c6d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c70:	5b                   	pop    %ebx
  800c71:	5e                   	pop    %esi
  800c72:	5f                   	pop    %edi
  800c73:	5d                   	pop    %ebp
  800c74:	c3                   	ret    

00800c75 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c75:	55                   	push   %ebp
  800c76:	89 e5                	mov    %esp,%ebp
  800c78:	57                   	push   %edi
  800c79:	56                   	push   %esi
  800c7a:	53                   	push   %ebx
  800c7b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c83:	b8 08 00 00 00       	mov    $0x8,%eax
  800c88:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8e:	89 df                	mov    %ebx,%edi
  800c90:	89 de                	mov    %ebx,%esi
  800c92:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c94:	85 c0                	test   %eax,%eax
  800c96:	7e 17                	jle    800caf <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c98:	83 ec 0c             	sub    $0xc,%esp
  800c9b:	50                   	push   %eax
  800c9c:	6a 08                	push   $0x8
  800c9e:	68 1f 25 80 00       	push   $0x80251f
  800ca3:	6a 23                	push   $0x23
  800ca5:	68 3c 25 80 00       	push   $0x80253c
  800caa:	e8 9e f4 ff ff       	call   80014d <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800caf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb2:	5b                   	pop    %ebx
  800cb3:	5e                   	pop    %esi
  800cb4:	5f                   	pop    %edi
  800cb5:	5d                   	pop    %ebp
  800cb6:	c3                   	ret    

00800cb7 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cb7:	55                   	push   %ebp
  800cb8:	89 e5                	mov    %esp,%ebp
  800cba:	57                   	push   %edi
  800cbb:	56                   	push   %esi
  800cbc:	53                   	push   %ebx
  800cbd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc5:	b8 09 00 00 00       	mov    $0x9,%eax
  800cca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccd:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd0:	89 df                	mov    %ebx,%edi
  800cd2:	89 de                	mov    %ebx,%esi
  800cd4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cd6:	85 c0                	test   %eax,%eax
  800cd8:	7e 17                	jle    800cf1 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cda:	83 ec 0c             	sub    $0xc,%esp
  800cdd:	50                   	push   %eax
  800cde:	6a 09                	push   $0x9
  800ce0:	68 1f 25 80 00       	push   $0x80251f
  800ce5:	6a 23                	push   $0x23
  800ce7:	68 3c 25 80 00       	push   $0x80253c
  800cec:	e8 5c f4 ff ff       	call   80014d <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cf1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf4:	5b                   	pop    %ebx
  800cf5:	5e                   	pop    %esi
  800cf6:	5f                   	pop    %edi
  800cf7:	5d                   	pop    %ebp
  800cf8:	c3                   	ret    

00800cf9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cf9:	55                   	push   %ebp
  800cfa:	89 e5                	mov    %esp,%ebp
  800cfc:	57                   	push   %edi
  800cfd:	56                   	push   %esi
  800cfe:	53                   	push   %ebx
  800cff:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d02:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d07:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d12:	89 df                	mov    %ebx,%edi
  800d14:	89 de                	mov    %ebx,%esi
  800d16:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d18:	85 c0                	test   %eax,%eax
  800d1a:	7e 17                	jle    800d33 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1c:	83 ec 0c             	sub    $0xc,%esp
  800d1f:	50                   	push   %eax
  800d20:	6a 0a                	push   $0xa
  800d22:	68 1f 25 80 00       	push   $0x80251f
  800d27:	6a 23                	push   $0x23
  800d29:	68 3c 25 80 00       	push   $0x80253c
  800d2e:	e8 1a f4 ff ff       	call   80014d <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d36:	5b                   	pop    %ebx
  800d37:	5e                   	pop    %esi
  800d38:	5f                   	pop    %edi
  800d39:	5d                   	pop    %ebp
  800d3a:	c3                   	ret    

00800d3b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d3b:	55                   	push   %ebp
  800d3c:	89 e5                	mov    %esp,%ebp
  800d3e:	57                   	push   %edi
  800d3f:	56                   	push   %esi
  800d40:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d41:	be 00 00 00 00       	mov    $0x0,%esi
  800d46:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d51:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d54:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d57:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d59:	5b                   	pop    %ebx
  800d5a:	5e                   	pop    %esi
  800d5b:	5f                   	pop    %edi
  800d5c:	5d                   	pop    %ebp
  800d5d:	c3                   	ret    

00800d5e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d5e:	55                   	push   %ebp
  800d5f:	89 e5                	mov    %esp,%ebp
  800d61:	57                   	push   %edi
  800d62:	56                   	push   %esi
  800d63:	53                   	push   %ebx
  800d64:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d67:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d6c:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d71:	8b 55 08             	mov    0x8(%ebp),%edx
  800d74:	89 cb                	mov    %ecx,%ebx
  800d76:	89 cf                	mov    %ecx,%edi
  800d78:	89 ce                	mov    %ecx,%esi
  800d7a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d7c:	85 c0                	test   %eax,%eax
  800d7e:	7e 17                	jle    800d97 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d80:	83 ec 0c             	sub    $0xc,%esp
  800d83:	50                   	push   %eax
  800d84:	6a 0d                	push   $0xd
  800d86:	68 1f 25 80 00       	push   $0x80251f
  800d8b:	6a 23                	push   $0x23
  800d8d:	68 3c 25 80 00       	push   $0x80253c
  800d92:	e8 b6 f3 ff ff       	call   80014d <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d97:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d9a:	5b                   	pop    %ebx
  800d9b:	5e                   	pop    %esi
  800d9c:	5f                   	pop    %edi
  800d9d:	5d                   	pop    %ebp
  800d9e:	c3                   	ret    

00800d9f <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800d9f:	55                   	push   %ebp
  800da0:	89 e5                	mov    %esp,%ebp
  800da2:	53                   	push   %ebx
  800da3:	83 ec 04             	sub    $0x4,%esp
	int r;
	void * address = (void *)(pn*PGSIZE);
  800da6:	89 d3                	mov    %edx,%ebx
  800da8:	c1 e3 0c             	shl    $0xc,%ebx
	
	if((uvpt[pn] & PTE_SHARE))
  800dab:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800db2:	f6 c5 04             	test   $0x4,%ch
  800db5:	74 38                	je     800def <duppage+0x50>
	{
		if ((r = sys_page_map(0, address, envid, address, (uvpt[pn] | PTE_SYSCALL))) < 0)
  800db7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dbe:	83 ec 0c             	sub    $0xc,%esp
  800dc1:	81 ca 07 0e 00 00    	or     $0xe07,%edx
  800dc7:	52                   	push   %edx
  800dc8:	53                   	push   %ebx
  800dc9:	50                   	push   %eax
  800dca:	53                   	push   %ebx
  800dcb:	6a 00                	push   $0x0
  800dcd:	e8 1f fe ff ff       	call   800bf1 <sys_page_map>
  800dd2:	83 c4 20             	add    $0x20,%esp
  800dd5:	85 c0                	test   %eax,%eax
  800dd7:	0f 89 b8 00 00 00    	jns    800e95 <duppage+0xf6>
			panic("sys_page_map: %e", r);
  800ddd:	50                   	push   %eax
  800dde:	68 4a 25 80 00       	push   $0x80254a
  800de3:	6a 4e                	push   $0x4e
  800de5:	68 5b 25 80 00       	push   $0x80255b
  800dea:	e8 5e f3 ff ff       	call   80014d <_panic>
	}
	else if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW))
  800def:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800df6:	f6 c1 02             	test   $0x2,%cl
  800df9:	75 0c                	jne    800e07 <duppage+0x68>
  800dfb:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800e02:	f6 c5 08             	test   $0x8,%ch
  800e05:	74 57                	je     800e5e <duppage+0xbf>
	{
		int perm = 0;
		perm |= PTE_P|PTE_U|PTE_COW;
	
		if ((r = sys_page_map(0, address, envid, address, perm)) < 0)
  800e07:	83 ec 0c             	sub    $0xc,%esp
  800e0a:	68 05 08 00 00       	push   $0x805
  800e0f:	53                   	push   %ebx
  800e10:	50                   	push   %eax
  800e11:	53                   	push   %ebx
  800e12:	6a 00                	push   $0x0
  800e14:	e8 d8 fd ff ff       	call   800bf1 <sys_page_map>
  800e19:	83 c4 20             	add    $0x20,%esp
  800e1c:	85 c0                	test   %eax,%eax
  800e1e:	79 12                	jns    800e32 <duppage+0x93>
			panic("sys_page_map: %e", r);
  800e20:	50                   	push   %eax
  800e21:	68 4a 25 80 00       	push   $0x80254a
  800e26:	6a 56                	push   $0x56
  800e28:	68 5b 25 80 00       	push   $0x80255b
  800e2d:	e8 1b f3 ff ff       	call   80014d <_panic>
		if ((r = sys_page_map(0, address, 0, address, perm)) < 0)
  800e32:	83 ec 0c             	sub    $0xc,%esp
  800e35:	68 05 08 00 00       	push   $0x805
  800e3a:	53                   	push   %ebx
  800e3b:	6a 00                	push   $0x0
  800e3d:	53                   	push   %ebx
  800e3e:	6a 00                	push   $0x0
  800e40:	e8 ac fd ff ff       	call   800bf1 <sys_page_map>
  800e45:	83 c4 20             	add    $0x20,%esp
  800e48:	85 c0                	test   %eax,%eax
  800e4a:	79 49                	jns    800e95 <duppage+0xf6>
			panic("sys_page_map: %e", r);
  800e4c:	50                   	push   %eax
  800e4d:	68 4a 25 80 00       	push   $0x80254a
  800e52:	6a 58                	push   $0x58
  800e54:	68 5b 25 80 00       	push   $0x80255b
  800e59:	e8 ef f2 ff ff       	call   80014d <_panic>
	}
	else if((uvpt[pn] & ~PTE_U) == 0)
  800e5e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e65:	f7 c2 fb ff ff ff    	test   $0xfffffffb,%edx
  800e6b:	75 28                	jne    800e95 <duppage+0xf6>
	{
		//cprintf("im here");
		if ((r = sys_page_map(0, address, envid, address, PTE_P|PTE_U)) < 0)
  800e6d:	83 ec 0c             	sub    $0xc,%esp
  800e70:	6a 05                	push   $0x5
  800e72:	53                   	push   %ebx
  800e73:	50                   	push   %eax
  800e74:	53                   	push   %ebx
  800e75:	6a 00                	push   $0x0
  800e77:	e8 75 fd ff ff       	call   800bf1 <sys_page_map>
  800e7c:	83 c4 20             	add    $0x20,%esp
  800e7f:	85 c0                	test   %eax,%eax
  800e81:	79 12                	jns    800e95 <duppage+0xf6>
			panic("sys_page_map: %e", r);	
  800e83:	50                   	push   %eax
  800e84:	68 4a 25 80 00       	push   $0x80254a
  800e89:	6a 5e                	push   $0x5e
  800e8b:	68 5b 25 80 00       	push   $0x80255b
  800e90:	e8 b8 f2 ff ff       	call   80014d <_panic>
	}
	return 0;
}
  800e95:	b8 00 00 00 00       	mov    $0x0,%eax
  800e9a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e9d:	c9                   	leave  
  800e9e:	c3                   	ret    

00800e9f <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e9f:	55                   	push   %ebp
  800ea0:	89 e5                	mov    %esp,%ebp
  800ea2:	53                   	push   %ebx
  800ea3:	83 ec 08             	sub    $0x8,%esp
	void *addr = (void *) utf->utf_fault_va;
  800ea6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea9:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	unsigned pn = ((uint32_t)addr)/PGSIZE;
  800eab:	89 d8                	mov    %ebx,%eax
  800ead:	c1 e8 0c             	shr    $0xc,%eax
	pte_t pte = uvpt[pn];
  800eb0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// Allocate a new page, mapped at temp location
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  800eb7:	6a 07                	push   $0x7
  800eb9:	68 00 f0 7f 00       	push   $0x7ff000
  800ebe:	6a 00                	push   $0x0
  800ec0:	e8 e9 fc ff ff       	call   800bae <sys_page_alloc>
  800ec5:	83 c4 10             	add    $0x10,%esp
  800ec8:	85 c0                	test   %eax,%eax
  800eca:	79 12                	jns    800ede <pgfault+0x3f>
		panic("sys_page_alloc: %e", r);
  800ecc:	50                   	push   %eax
  800ecd:	68 66 25 80 00       	push   $0x802566
  800ed2:	6a 2b                	push   $0x2b
  800ed4:	68 5b 25 80 00       	push   $0x80255b
  800ed9:	e8 6f f2 ff ff       	call   80014d <_panic>

	// Copy the data from the old page to this new page
	void *addr_pgstart = (void *) ROUNDDOWN(addr, PGSIZE);
  800ede:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr_pgstart, PGSIZE);
  800ee4:	83 ec 04             	sub    $0x4,%esp
  800ee7:	68 00 10 00 00       	push   $0x1000
  800eec:	53                   	push   %ebx
  800eed:	68 00 f0 7f 00       	push   $0x7ff000
  800ef2:	e8 46 fa ff ff       	call   80093d <memmove>

	// Move the new page to the old page's address
	if ((r = sys_page_map(0, PFTEMP, 0, addr_pgstart, PTE_P|PTE_U|PTE_W)) < 0)
  800ef7:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800efe:	53                   	push   %ebx
  800eff:	6a 00                	push   $0x0
  800f01:	68 00 f0 7f 00       	push   $0x7ff000
  800f06:	6a 00                	push   $0x0
  800f08:	e8 e4 fc ff ff       	call   800bf1 <sys_page_map>
  800f0d:	83 c4 20             	add    $0x20,%esp
  800f10:	85 c0                	test   %eax,%eax
  800f12:	79 12                	jns    800f26 <pgfault+0x87>
		panic("sys_page_map: %e", r);
  800f14:	50                   	push   %eax
  800f15:	68 4a 25 80 00       	push   $0x80254a
  800f1a:	6a 33                	push   $0x33
  800f1c:	68 5b 25 80 00       	push   $0x80255b
  800f21:	e8 27 f2 ff ff       	call   80014d <_panic>

	// Unmap the temp location
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800f26:	83 ec 08             	sub    $0x8,%esp
  800f29:	68 00 f0 7f 00       	push   $0x7ff000
  800f2e:	6a 00                	push   $0x0
  800f30:	e8 fe fc ff ff       	call   800c33 <sys_page_unmap>
  800f35:	83 c4 10             	add    $0x10,%esp
  800f38:	85 c0                	test   %eax,%eax
  800f3a:	79 12                	jns    800f4e <pgfault+0xaf>
		panic("sys_page_unmap: %e", r);
  800f3c:	50                   	push   %eax
  800f3d:	68 79 25 80 00       	push   $0x802579
  800f42:	6a 37                	push   $0x37
  800f44:	68 5b 25 80 00       	push   $0x80255b
  800f49:	e8 ff f1 ff ff       	call   80014d <_panic>
}
  800f4e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f51:	c9                   	leave  
  800f52:	c3                   	ret    

00800f53 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f53:	55                   	push   %ebp
  800f54:	89 e5                	mov    %esp,%ebp
  800f56:	56                   	push   %esi
  800f57:	53                   	push   %ebx
  800f58:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
	// Set up page fault handler
	set_pgfault_handler(&pgfault);
  800f5b:	68 9f 0e 80 00       	push   $0x800e9f
  800f60:	e8 f6 0d 00 00       	call   801d5b <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f65:	b8 07 00 00 00       	mov    $0x7,%eax
  800f6a:	cd 30                	int    $0x30

	// Create child
	envid_t envid = sys_exofork();
  800f6c:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (envid < 0) {
  800f6f:	83 c4 10             	add    $0x10,%esp
  800f72:	85 c0                	test   %eax,%eax
  800f74:	79 12                	jns    800f88 <fork+0x35>
		panic("sys_exofork: %e", envid);
  800f76:	50                   	push   %eax
  800f77:	68 8c 25 80 00       	push   $0x80258c
  800f7c:	6a 7c                	push   $0x7c
  800f7e:	68 5b 25 80 00       	push   $0x80255b
  800f83:	e8 c5 f1 ff ff       	call   80014d <_panic>
		return envid;
	}
	if (envid == 0) {
  800f88:	85 c0                	test   %eax,%eax
  800f8a:	75 1e                	jne    800faa <fork+0x57>
		// We are the child.
		thisenv = &envs[ENVX(sys_getenvid())]; // Fix thisenv
  800f8c:	e8 df fb ff ff       	call   800b70 <sys_getenvid>
  800f91:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f96:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f99:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f9e:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  800fa3:	b8 00 00 00 00       	mov    $0x0,%eax
  800fa8:	eb 7d                	jmp    801027 <fork+0xd4>

	// Set page fault handler on the child.
	// The parent needs to do it, else the child wouldn't be able to handle
	// the fault when trying to access it's stack (which happens as soon it starts)
	extern void _pgfault_upcall(void);
	sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);
  800faa:	83 ec 04             	sub    $0x4,%esp
  800fad:	6a 07                	push   $0x7
  800faf:	68 00 f0 bf ee       	push   $0xeebff000
  800fb4:	50                   	push   %eax
  800fb5:	e8 f4 fb ff ff       	call   800bae <sys_page_alloc>
	sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  800fba:	83 c4 08             	add    $0x8,%esp
  800fbd:	68 a0 1d 80 00       	push   $0x801da0
  800fc2:	ff 75 f4             	pushl  -0xc(%ebp)
  800fc5:	e8 2f fd ff ff       	call   800cf9 <sys_env_set_pgfault_upcall>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  800fca:	be 04 60 80 00       	mov    $0x806004,%esi
  800fcf:	c1 ee 0c             	shr    $0xc,%esi
  800fd2:	83 c4 10             	add    $0x10,%esp
  800fd5:	bb 00 08 00 00       	mov    $0x800,%ebx
  800fda:	eb 0d                	jmp    800fe9 <fork+0x96>
		duppage(envid, pn);
  800fdc:	89 da                	mov    %ebx,%edx
  800fde:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fe1:	e8 b9 fd ff ff       	call   800d9f <duppage>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  800fe6:	83 c3 01             	add    $0x1,%ebx
  800fe9:	39 f3                	cmp    %esi,%ebx
  800feb:	76 ef                	jbe    800fdc <fork+0x89>
	}

	// Also copy the stack we are currently running on
	// I think it should loop from ustacktop to this page, since the stack
	// can have more than 1 page
	duppage(envid, ((uint32_t) &envid)/PGSIZE);
  800fed:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800ff0:	c1 ea 0c             	shr    $0xc,%edx
  800ff3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ff6:	e8 a4 fd ff ff       	call   800d9f <duppage>

	// Start the child environmnet running
	int r;
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  800ffb:	83 ec 08             	sub    $0x8,%esp
  800ffe:	6a 02                	push   $0x2
  801000:	ff 75 f4             	pushl  -0xc(%ebp)
  801003:	e8 6d fc ff ff       	call   800c75 <sys_env_set_status>
  801008:	83 c4 10             	add    $0x10,%esp
  80100b:	85 c0                	test   %eax,%eax
  80100d:	79 15                	jns    801024 <fork+0xd1>
		panic("sys_env_set_status: %e", r);
  80100f:	50                   	push   %eax
  801010:	68 9c 25 80 00       	push   $0x80259c
  801015:	68 9c 00 00 00       	push   $0x9c
  80101a:	68 5b 25 80 00       	push   $0x80255b
  80101f:	e8 29 f1 ff ff       	call   80014d <_panic>
		return r;
	}

	return envid;
  801024:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  801027:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80102a:	5b                   	pop    %ebx
  80102b:	5e                   	pop    %esi
  80102c:	5d                   	pop    %ebp
  80102d:	c3                   	ret    

0080102e <sfork>:

// Challenge!
int
sfork(void)
{
  80102e:	55                   	push   %ebp
  80102f:	89 e5                	mov    %esp,%ebp
  801031:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801034:	68 b3 25 80 00       	push   $0x8025b3
  801039:	68 a7 00 00 00       	push   $0xa7
  80103e:	68 5b 25 80 00       	push   $0x80255b
  801043:	e8 05 f1 ff ff       	call   80014d <_panic>

00801048 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801048:	55                   	push   %ebp
  801049:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80104b:	8b 45 08             	mov    0x8(%ebp),%eax
  80104e:	05 00 00 00 30       	add    $0x30000000,%eax
  801053:	c1 e8 0c             	shr    $0xc,%eax
}
  801056:	5d                   	pop    %ebp
  801057:	c3                   	ret    

00801058 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801058:	55                   	push   %ebp
  801059:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80105b:	8b 45 08             	mov    0x8(%ebp),%eax
  80105e:	05 00 00 00 30       	add    $0x30000000,%eax
  801063:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801068:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80106d:	5d                   	pop    %ebp
  80106e:	c3                   	ret    

0080106f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80106f:	55                   	push   %ebp
  801070:	89 e5                	mov    %esp,%ebp
  801072:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801075:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80107a:	89 c2                	mov    %eax,%edx
  80107c:	c1 ea 16             	shr    $0x16,%edx
  80107f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801086:	f6 c2 01             	test   $0x1,%dl
  801089:	74 11                	je     80109c <fd_alloc+0x2d>
  80108b:	89 c2                	mov    %eax,%edx
  80108d:	c1 ea 0c             	shr    $0xc,%edx
  801090:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801097:	f6 c2 01             	test   $0x1,%dl
  80109a:	75 09                	jne    8010a5 <fd_alloc+0x36>
			*fd_store = fd;
  80109c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80109e:	b8 00 00 00 00       	mov    $0x0,%eax
  8010a3:	eb 17                	jmp    8010bc <fd_alloc+0x4d>
  8010a5:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010aa:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010af:	75 c9                	jne    80107a <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8010b1:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8010b7:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8010bc:	5d                   	pop    %ebp
  8010bd:	c3                   	ret    

008010be <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010be:	55                   	push   %ebp
  8010bf:	89 e5                	mov    %esp,%ebp
  8010c1:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010c4:	83 f8 1f             	cmp    $0x1f,%eax
  8010c7:	77 36                	ja     8010ff <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010c9:	c1 e0 0c             	shl    $0xc,%eax
  8010cc:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8010d1:	89 c2                	mov    %eax,%edx
  8010d3:	c1 ea 16             	shr    $0x16,%edx
  8010d6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010dd:	f6 c2 01             	test   $0x1,%dl
  8010e0:	74 24                	je     801106 <fd_lookup+0x48>
  8010e2:	89 c2                	mov    %eax,%edx
  8010e4:	c1 ea 0c             	shr    $0xc,%edx
  8010e7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010ee:	f6 c2 01             	test   $0x1,%dl
  8010f1:	74 1a                	je     80110d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8010f3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010f6:	89 02                	mov    %eax,(%edx)
	return 0;
  8010f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8010fd:	eb 13                	jmp    801112 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010ff:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801104:	eb 0c                	jmp    801112 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801106:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80110b:	eb 05                	jmp    801112 <fd_lookup+0x54>
  80110d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801112:	5d                   	pop    %ebp
  801113:	c3                   	ret    

00801114 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801114:	55                   	push   %ebp
  801115:	89 e5                	mov    %esp,%ebp
  801117:	83 ec 08             	sub    $0x8,%esp
  80111a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80111d:	ba 4c 26 80 00       	mov    $0x80264c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801122:	eb 13                	jmp    801137 <dev_lookup+0x23>
  801124:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801127:	39 08                	cmp    %ecx,(%eax)
  801129:	75 0c                	jne    801137 <dev_lookup+0x23>
			*dev = devtab[i];
  80112b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80112e:	89 01                	mov    %eax,(%ecx)
			return 0;
  801130:	b8 00 00 00 00       	mov    $0x0,%eax
  801135:	eb 2e                	jmp    801165 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801137:	8b 02                	mov    (%edx),%eax
  801139:	85 c0                	test   %eax,%eax
  80113b:	75 e7                	jne    801124 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80113d:	a1 08 40 80 00       	mov    0x804008,%eax
  801142:	8b 40 48             	mov    0x48(%eax),%eax
  801145:	83 ec 04             	sub    $0x4,%esp
  801148:	51                   	push   %ecx
  801149:	50                   	push   %eax
  80114a:	68 cc 25 80 00       	push   $0x8025cc
  80114f:	e8 d2 f0 ff ff       	call   800226 <cprintf>
	*dev = 0;
  801154:	8b 45 0c             	mov    0xc(%ebp),%eax
  801157:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80115d:	83 c4 10             	add    $0x10,%esp
  801160:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801165:	c9                   	leave  
  801166:	c3                   	ret    

00801167 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801167:	55                   	push   %ebp
  801168:	89 e5                	mov    %esp,%ebp
  80116a:	56                   	push   %esi
  80116b:	53                   	push   %ebx
  80116c:	83 ec 10             	sub    $0x10,%esp
  80116f:	8b 75 08             	mov    0x8(%ebp),%esi
  801172:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801175:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801178:	50                   	push   %eax
  801179:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80117f:	c1 e8 0c             	shr    $0xc,%eax
  801182:	50                   	push   %eax
  801183:	e8 36 ff ff ff       	call   8010be <fd_lookup>
  801188:	83 c4 08             	add    $0x8,%esp
  80118b:	85 c0                	test   %eax,%eax
  80118d:	78 05                	js     801194 <fd_close+0x2d>
	    || fd != fd2)
  80118f:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801192:	74 0c                	je     8011a0 <fd_close+0x39>
		return (must_exist ? r : 0);
  801194:	84 db                	test   %bl,%bl
  801196:	ba 00 00 00 00       	mov    $0x0,%edx
  80119b:	0f 44 c2             	cmove  %edx,%eax
  80119e:	eb 41                	jmp    8011e1 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011a0:	83 ec 08             	sub    $0x8,%esp
  8011a3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011a6:	50                   	push   %eax
  8011a7:	ff 36                	pushl  (%esi)
  8011a9:	e8 66 ff ff ff       	call   801114 <dev_lookup>
  8011ae:	89 c3                	mov    %eax,%ebx
  8011b0:	83 c4 10             	add    $0x10,%esp
  8011b3:	85 c0                	test   %eax,%eax
  8011b5:	78 1a                	js     8011d1 <fd_close+0x6a>
		if (dev->dev_close)
  8011b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011ba:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8011bd:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8011c2:	85 c0                	test   %eax,%eax
  8011c4:	74 0b                	je     8011d1 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8011c6:	83 ec 0c             	sub    $0xc,%esp
  8011c9:	56                   	push   %esi
  8011ca:	ff d0                	call   *%eax
  8011cc:	89 c3                	mov    %eax,%ebx
  8011ce:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8011d1:	83 ec 08             	sub    $0x8,%esp
  8011d4:	56                   	push   %esi
  8011d5:	6a 00                	push   $0x0
  8011d7:	e8 57 fa ff ff       	call   800c33 <sys_page_unmap>
	return r;
  8011dc:	83 c4 10             	add    $0x10,%esp
  8011df:	89 d8                	mov    %ebx,%eax
}
  8011e1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011e4:	5b                   	pop    %ebx
  8011e5:	5e                   	pop    %esi
  8011e6:	5d                   	pop    %ebp
  8011e7:	c3                   	ret    

008011e8 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8011e8:	55                   	push   %ebp
  8011e9:	89 e5                	mov    %esp,%ebp
  8011eb:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011ee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011f1:	50                   	push   %eax
  8011f2:	ff 75 08             	pushl  0x8(%ebp)
  8011f5:	e8 c4 fe ff ff       	call   8010be <fd_lookup>
  8011fa:	83 c4 08             	add    $0x8,%esp
  8011fd:	85 c0                	test   %eax,%eax
  8011ff:	78 10                	js     801211 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801201:	83 ec 08             	sub    $0x8,%esp
  801204:	6a 01                	push   $0x1
  801206:	ff 75 f4             	pushl  -0xc(%ebp)
  801209:	e8 59 ff ff ff       	call   801167 <fd_close>
  80120e:	83 c4 10             	add    $0x10,%esp
}
  801211:	c9                   	leave  
  801212:	c3                   	ret    

00801213 <close_all>:

void
close_all(void)
{
  801213:	55                   	push   %ebp
  801214:	89 e5                	mov    %esp,%ebp
  801216:	53                   	push   %ebx
  801217:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80121a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80121f:	83 ec 0c             	sub    $0xc,%esp
  801222:	53                   	push   %ebx
  801223:	e8 c0 ff ff ff       	call   8011e8 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801228:	83 c3 01             	add    $0x1,%ebx
  80122b:	83 c4 10             	add    $0x10,%esp
  80122e:	83 fb 20             	cmp    $0x20,%ebx
  801231:	75 ec                	jne    80121f <close_all+0xc>
		close(i);
}
  801233:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801236:	c9                   	leave  
  801237:	c3                   	ret    

00801238 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801238:	55                   	push   %ebp
  801239:	89 e5                	mov    %esp,%ebp
  80123b:	57                   	push   %edi
  80123c:	56                   	push   %esi
  80123d:	53                   	push   %ebx
  80123e:	83 ec 2c             	sub    $0x2c,%esp
  801241:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801244:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801247:	50                   	push   %eax
  801248:	ff 75 08             	pushl  0x8(%ebp)
  80124b:	e8 6e fe ff ff       	call   8010be <fd_lookup>
  801250:	83 c4 08             	add    $0x8,%esp
  801253:	85 c0                	test   %eax,%eax
  801255:	0f 88 c1 00 00 00    	js     80131c <dup+0xe4>
		return r;
	close(newfdnum);
  80125b:	83 ec 0c             	sub    $0xc,%esp
  80125e:	56                   	push   %esi
  80125f:	e8 84 ff ff ff       	call   8011e8 <close>

	newfd = INDEX2FD(newfdnum);
  801264:	89 f3                	mov    %esi,%ebx
  801266:	c1 e3 0c             	shl    $0xc,%ebx
  801269:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80126f:	83 c4 04             	add    $0x4,%esp
  801272:	ff 75 e4             	pushl  -0x1c(%ebp)
  801275:	e8 de fd ff ff       	call   801058 <fd2data>
  80127a:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80127c:	89 1c 24             	mov    %ebx,(%esp)
  80127f:	e8 d4 fd ff ff       	call   801058 <fd2data>
  801284:	83 c4 10             	add    $0x10,%esp
  801287:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80128a:	89 f8                	mov    %edi,%eax
  80128c:	c1 e8 16             	shr    $0x16,%eax
  80128f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801296:	a8 01                	test   $0x1,%al
  801298:	74 37                	je     8012d1 <dup+0x99>
  80129a:	89 f8                	mov    %edi,%eax
  80129c:	c1 e8 0c             	shr    $0xc,%eax
  80129f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012a6:	f6 c2 01             	test   $0x1,%dl
  8012a9:	74 26                	je     8012d1 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012ab:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012b2:	83 ec 0c             	sub    $0xc,%esp
  8012b5:	25 07 0e 00 00       	and    $0xe07,%eax
  8012ba:	50                   	push   %eax
  8012bb:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012be:	6a 00                	push   $0x0
  8012c0:	57                   	push   %edi
  8012c1:	6a 00                	push   $0x0
  8012c3:	e8 29 f9 ff ff       	call   800bf1 <sys_page_map>
  8012c8:	89 c7                	mov    %eax,%edi
  8012ca:	83 c4 20             	add    $0x20,%esp
  8012cd:	85 c0                	test   %eax,%eax
  8012cf:	78 2e                	js     8012ff <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012d1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8012d4:	89 d0                	mov    %edx,%eax
  8012d6:	c1 e8 0c             	shr    $0xc,%eax
  8012d9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012e0:	83 ec 0c             	sub    $0xc,%esp
  8012e3:	25 07 0e 00 00       	and    $0xe07,%eax
  8012e8:	50                   	push   %eax
  8012e9:	53                   	push   %ebx
  8012ea:	6a 00                	push   $0x0
  8012ec:	52                   	push   %edx
  8012ed:	6a 00                	push   $0x0
  8012ef:	e8 fd f8 ff ff       	call   800bf1 <sys_page_map>
  8012f4:	89 c7                	mov    %eax,%edi
  8012f6:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8012f9:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012fb:	85 ff                	test   %edi,%edi
  8012fd:	79 1d                	jns    80131c <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8012ff:	83 ec 08             	sub    $0x8,%esp
  801302:	53                   	push   %ebx
  801303:	6a 00                	push   $0x0
  801305:	e8 29 f9 ff ff       	call   800c33 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80130a:	83 c4 08             	add    $0x8,%esp
  80130d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801310:	6a 00                	push   $0x0
  801312:	e8 1c f9 ff ff       	call   800c33 <sys_page_unmap>
	return r;
  801317:	83 c4 10             	add    $0x10,%esp
  80131a:	89 f8                	mov    %edi,%eax
}
  80131c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80131f:	5b                   	pop    %ebx
  801320:	5e                   	pop    %esi
  801321:	5f                   	pop    %edi
  801322:	5d                   	pop    %ebp
  801323:	c3                   	ret    

00801324 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801324:	55                   	push   %ebp
  801325:	89 e5                	mov    %esp,%ebp
  801327:	53                   	push   %ebx
  801328:	83 ec 14             	sub    $0x14,%esp
  80132b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80132e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801331:	50                   	push   %eax
  801332:	53                   	push   %ebx
  801333:	e8 86 fd ff ff       	call   8010be <fd_lookup>
  801338:	83 c4 08             	add    $0x8,%esp
  80133b:	89 c2                	mov    %eax,%edx
  80133d:	85 c0                	test   %eax,%eax
  80133f:	78 6d                	js     8013ae <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801341:	83 ec 08             	sub    $0x8,%esp
  801344:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801347:	50                   	push   %eax
  801348:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80134b:	ff 30                	pushl  (%eax)
  80134d:	e8 c2 fd ff ff       	call   801114 <dev_lookup>
  801352:	83 c4 10             	add    $0x10,%esp
  801355:	85 c0                	test   %eax,%eax
  801357:	78 4c                	js     8013a5 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801359:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80135c:	8b 42 08             	mov    0x8(%edx),%eax
  80135f:	83 e0 03             	and    $0x3,%eax
  801362:	83 f8 01             	cmp    $0x1,%eax
  801365:	75 21                	jne    801388 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801367:	a1 08 40 80 00       	mov    0x804008,%eax
  80136c:	8b 40 48             	mov    0x48(%eax),%eax
  80136f:	83 ec 04             	sub    $0x4,%esp
  801372:	53                   	push   %ebx
  801373:	50                   	push   %eax
  801374:	68 10 26 80 00       	push   $0x802610
  801379:	e8 a8 ee ff ff       	call   800226 <cprintf>
		return -E_INVAL;
  80137e:	83 c4 10             	add    $0x10,%esp
  801381:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801386:	eb 26                	jmp    8013ae <read+0x8a>
	}
	if (!dev->dev_read)
  801388:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80138b:	8b 40 08             	mov    0x8(%eax),%eax
  80138e:	85 c0                	test   %eax,%eax
  801390:	74 17                	je     8013a9 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801392:	83 ec 04             	sub    $0x4,%esp
  801395:	ff 75 10             	pushl  0x10(%ebp)
  801398:	ff 75 0c             	pushl  0xc(%ebp)
  80139b:	52                   	push   %edx
  80139c:	ff d0                	call   *%eax
  80139e:	89 c2                	mov    %eax,%edx
  8013a0:	83 c4 10             	add    $0x10,%esp
  8013a3:	eb 09                	jmp    8013ae <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013a5:	89 c2                	mov    %eax,%edx
  8013a7:	eb 05                	jmp    8013ae <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8013a9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8013ae:	89 d0                	mov    %edx,%eax
  8013b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013b3:	c9                   	leave  
  8013b4:	c3                   	ret    

008013b5 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013b5:	55                   	push   %ebp
  8013b6:	89 e5                	mov    %esp,%ebp
  8013b8:	57                   	push   %edi
  8013b9:	56                   	push   %esi
  8013ba:	53                   	push   %ebx
  8013bb:	83 ec 0c             	sub    $0xc,%esp
  8013be:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013c1:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013c4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013c9:	eb 21                	jmp    8013ec <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013cb:	83 ec 04             	sub    $0x4,%esp
  8013ce:	89 f0                	mov    %esi,%eax
  8013d0:	29 d8                	sub    %ebx,%eax
  8013d2:	50                   	push   %eax
  8013d3:	89 d8                	mov    %ebx,%eax
  8013d5:	03 45 0c             	add    0xc(%ebp),%eax
  8013d8:	50                   	push   %eax
  8013d9:	57                   	push   %edi
  8013da:	e8 45 ff ff ff       	call   801324 <read>
		if (m < 0)
  8013df:	83 c4 10             	add    $0x10,%esp
  8013e2:	85 c0                	test   %eax,%eax
  8013e4:	78 10                	js     8013f6 <readn+0x41>
			return m;
		if (m == 0)
  8013e6:	85 c0                	test   %eax,%eax
  8013e8:	74 0a                	je     8013f4 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013ea:	01 c3                	add    %eax,%ebx
  8013ec:	39 f3                	cmp    %esi,%ebx
  8013ee:	72 db                	jb     8013cb <readn+0x16>
  8013f0:	89 d8                	mov    %ebx,%eax
  8013f2:	eb 02                	jmp    8013f6 <readn+0x41>
  8013f4:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8013f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013f9:	5b                   	pop    %ebx
  8013fa:	5e                   	pop    %esi
  8013fb:	5f                   	pop    %edi
  8013fc:	5d                   	pop    %ebp
  8013fd:	c3                   	ret    

008013fe <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8013fe:	55                   	push   %ebp
  8013ff:	89 e5                	mov    %esp,%ebp
  801401:	53                   	push   %ebx
  801402:	83 ec 14             	sub    $0x14,%esp
  801405:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801408:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80140b:	50                   	push   %eax
  80140c:	53                   	push   %ebx
  80140d:	e8 ac fc ff ff       	call   8010be <fd_lookup>
  801412:	83 c4 08             	add    $0x8,%esp
  801415:	89 c2                	mov    %eax,%edx
  801417:	85 c0                	test   %eax,%eax
  801419:	78 68                	js     801483 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80141b:	83 ec 08             	sub    $0x8,%esp
  80141e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801421:	50                   	push   %eax
  801422:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801425:	ff 30                	pushl  (%eax)
  801427:	e8 e8 fc ff ff       	call   801114 <dev_lookup>
  80142c:	83 c4 10             	add    $0x10,%esp
  80142f:	85 c0                	test   %eax,%eax
  801431:	78 47                	js     80147a <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801433:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801436:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80143a:	75 21                	jne    80145d <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80143c:	a1 08 40 80 00       	mov    0x804008,%eax
  801441:	8b 40 48             	mov    0x48(%eax),%eax
  801444:	83 ec 04             	sub    $0x4,%esp
  801447:	53                   	push   %ebx
  801448:	50                   	push   %eax
  801449:	68 2c 26 80 00       	push   $0x80262c
  80144e:	e8 d3 ed ff ff       	call   800226 <cprintf>
		return -E_INVAL;
  801453:	83 c4 10             	add    $0x10,%esp
  801456:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80145b:	eb 26                	jmp    801483 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80145d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801460:	8b 52 0c             	mov    0xc(%edx),%edx
  801463:	85 d2                	test   %edx,%edx
  801465:	74 17                	je     80147e <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801467:	83 ec 04             	sub    $0x4,%esp
  80146a:	ff 75 10             	pushl  0x10(%ebp)
  80146d:	ff 75 0c             	pushl  0xc(%ebp)
  801470:	50                   	push   %eax
  801471:	ff d2                	call   *%edx
  801473:	89 c2                	mov    %eax,%edx
  801475:	83 c4 10             	add    $0x10,%esp
  801478:	eb 09                	jmp    801483 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80147a:	89 c2                	mov    %eax,%edx
  80147c:	eb 05                	jmp    801483 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80147e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801483:	89 d0                	mov    %edx,%eax
  801485:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801488:	c9                   	leave  
  801489:	c3                   	ret    

0080148a <seek>:

int
seek(int fdnum, off_t offset)
{
  80148a:	55                   	push   %ebp
  80148b:	89 e5                	mov    %esp,%ebp
  80148d:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801490:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801493:	50                   	push   %eax
  801494:	ff 75 08             	pushl  0x8(%ebp)
  801497:	e8 22 fc ff ff       	call   8010be <fd_lookup>
  80149c:	83 c4 08             	add    $0x8,%esp
  80149f:	85 c0                	test   %eax,%eax
  8014a1:	78 0e                	js     8014b1 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8014a3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014a6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014a9:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014ac:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014b1:	c9                   	leave  
  8014b2:	c3                   	ret    

008014b3 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8014b3:	55                   	push   %ebp
  8014b4:	89 e5                	mov    %esp,%ebp
  8014b6:	53                   	push   %ebx
  8014b7:	83 ec 14             	sub    $0x14,%esp
  8014ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014bd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014c0:	50                   	push   %eax
  8014c1:	53                   	push   %ebx
  8014c2:	e8 f7 fb ff ff       	call   8010be <fd_lookup>
  8014c7:	83 c4 08             	add    $0x8,%esp
  8014ca:	89 c2                	mov    %eax,%edx
  8014cc:	85 c0                	test   %eax,%eax
  8014ce:	78 65                	js     801535 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014d0:	83 ec 08             	sub    $0x8,%esp
  8014d3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014d6:	50                   	push   %eax
  8014d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014da:	ff 30                	pushl  (%eax)
  8014dc:	e8 33 fc ff ff       	call   801114 <dev_lookup>
  8014e1:	83 c4 10             	add    $0x10,%esp
  8014e4:	85 c0                	test   %eax,%eax
  8014e6:	78 44                	js     80152c <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014eb:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014ef:	75 21                	jne    801512 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8014f1:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8014f6:	8b 40 48             	mov    0x48(%eax),%eax
  8014f9:	83 ec 04             	sub    $0x4,%esp
  8014fc:	53                   	push   %ebx
  8014fd:	50                   	push   %eax
  8014fe:	68 ec 25 80 00       	push   $0x8025ec
  801503:	e8 1e ed ff ff       	call   800226 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801508:	83 c4 10             	add    $0x10,%esp
  80150b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801510:	eb 23                	jmp    801535 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801512:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801515:	8b 52 18             	mov    0x18(%edx),%edx
  801518:	85 d2                	test   %edx,%edx
  80151a:	74 14                	je     801530 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80151c:	83 ec 08             	sub    $0x8,%esp
  80151f:	ff 75 0c             	pushl  0xc(%ebp)
  801522:	50                   	push   %eax
  801523:	ff d2                	call   *%edx
  801525:	89 c2                	mov    %eax,%edx
  801527:	83 c4 10             	add    $0x10,%esp
  80152a:	eb 09                	jmp    801535 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80152c:	89 c2                	mov    %eax,%edx
  80152e:	eb 05                	jmp    801535 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801530:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801535:	89 d0                	mov    %edx,%eax
  801537:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80153a:	c9                   	leave  
  80153b:	c3                   	ret    

0080153c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80153c:	55                   	push   %ebp
  80153d:	89 e5                	mov    %esp,%ebp
  80153f:	53                   	push   %ebx
  801540:	83 ec 14             	sub    $0x14,%esp
  801543:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801546:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801549:	50                   	push   %eax
  80154a:	ff 75 08             	pushl  0x8(%ebp)
  80154d:	e8 6c fb ff ff       	call   8010be <fd_lookup>
  801552:	83 c4 08             	add    $0x8,%esp
  801555:	89 c2                	mov    %eax,%edx
  801557:	85 c0                	test   %eax,%eax
  801559:	78 58                	js     8015b3 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80155b:	83 ec 08             	sub    $0x8,%esp
  80155e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801561:	50                   	push   %eax
  801562:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801565:	ff 30                	pushl  (%eax)
  801567:	e8 a8 fb ff ff       	call   801114 <dev_lookup>
  80156c:	83 c4 10             	add    $0x10,%esp
  80156f:	85 c0                	test   %eax,%eax
  801571:	78 37                	js     8015aa <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801573:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801576:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80157a:	74 32                	je     8015ae <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80157c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80157f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801586:	00 00 00 
	stat->st_isdir = 0;
  801589:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801590:	00 00 00 
	stat->st_dev = dev;
  801593:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801599:	83 ec 08             	sub    $0x8,%esp
  80159c:	53                   	push   %ebx
  80159d:	ff 75 f0             	pushl  -0x10(%ebp)
  8015a0:	ff 50 14             	call   *0x14(%eax)
  8015a3:	89 c2                	mov    %eax,%edx
  8015a5:	83 c4 10             	add    $0x10,%esp
  8015a8:	eb 09                	jmp    8015b3 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015aa:	89 c2                	mov    %eax,%edx
  8015ac:	eb 05                	jmp    8015b3 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8015ae:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8015b3:	89 d0                	mov    %edx,%eax
  8015b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015b8:	c9                   	leave  
  8015b9:	c3                   	ret    

008015ba <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015ba:	55                   	push   %ebp
  8015bb:	89 e5                	mov    %esp,%ebp
  8015bd:	56                   	push   %esi
  8015be:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015bf:	83 ec 08             	sub    $0x8,%esp
  8015c2:	6a 00                	push   $0x0
  8015c4:	ff 75 08             	pushl  0x8(%ebp)
  8015c7:	e8 0c 02 00 00       	call   8017d8 <open>
  8015cc:	89 c3                	mov    %eax,%ebx
  8015ce:	83 c4 10             	add    $0x10,%esp
  8015d1:	85 c0                	test   %eax,%eax
  8015d3:	78 1b                	js     8015f0 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8015d5:	83 ec 08             	sub    $0x8,%esp
  8015d8:	ff 75 0c             	pushl  0xc(%ebp)
  8015db:	50                   	push   %eax
  8015dc:	e8 5b ff ff ff       	call   80153c <fstat>
  8015e1:	89 c6                	mov    %eax,%esi
	close(fd);
  8015e3:	89 1c 24             	mov    %ebx,(%esp)
  8015e6:	e8 fd fb ff ff       	call   8011e8 <close>
	return r;
  8015eb:	83 c4 10             	add    $0x10,%esp
  8015ee:	89 f0                	mov    %esi,%eax
}
  8015f0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015f3:	5b                   	pop    %ebx
  8015f4:	5e                   	pop    %esi
  8015f5:	5d                   	pop    %ebp
  8015f6:	c3                   	ret    

008015f7 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8015f7:	55                   	push   %ebp
  8015f8:	89 e5                	mov    %esp,%ebp
  8015fa:	56                   	push   %esi
  8015fb:	53                   	push   %ebx
  8015fc:	89 c6                	mov    %eax,%esi
  8015fe:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801600:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801607:	75 12                	jne    80161b <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801609:	83 ec 0c             	sub    $0xc,%esp
  80160c:	6a 01                	push   $0x1
  80160e:	e8 7b 08 00 00       	call   801e8e <ipc_find_env>
  801613:	a3 00 40 80 00       	mov    %eax,0x804000
  801618:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80161b:	6a 07                	push   $0x7
  80161d:	68 00 50 80 00       	push   $0x805000
  801622:	56                   	push   %esi
  801623:	ff 35 00 40 80 00    	pushl  0x804000
  801629:	e8 0c 08 00 00       	call   801e3a <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80162e:	83 c4 0c             	add    $0xc,%esp
  801631:	6a 00                	push   $0x0
  801633:	53                   	push   %ebx
  801634:	6a 00                	push   $0x0
  801636:	e8 96 07 00 00       	call   801dd1 <ipc_recv>
}
  80163b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80163e:	5b                   	pop    %ebx
  80163f:	5e                   	pop    %esi
  801640:	5d                   	pop    %ebp
  801641:	c3                   	ret    

00801642 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801642:	55                   	push   %ebp
  801643:	89 e5                	mov    %esp,%ebp
  801645:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801648:	8b 45 08             	mov    0x8(%ebp),%eax
  80164b:	8b 40 0c             	mov    0xc(%eax),%eax
  80164e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801653:	8b 45 0c             	mov    0xc(%ebp),%eax
  801656:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80165b:	ba 00 00 00 00       	mov    $0x0,%edx
  801660:	b8 02 00 00 00       	mov    $0x2,%eax
  801665:	e8 8d ff ff ff       	call   8015f7 <fsipc>
}
  80166a:	c9                   	leave  
  80166b:	c3                   	ret    

0080166c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80166c:	55                   	push   %ebp
  80166d:	89 e5                	mov    %esp,%ebp
  80166f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801672:	8b 45 08             	mov    0x8(%ebp),%eax
  801675:	8b 40 0c             	mov    0xc(%eax),%eax
  801678:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80167d:	ba 00 00 00 00       	mov    $0x0,%edx
  801682:	b8 06 00 00 00       	mov    $0x6,%eax
  801687:	e8 6b ff ff ff       	call   8015f7 <fsipc>
}
  80168c:	c9                   	leave  
  80168d:	c3                   	ret    

0080168e <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80168e:	55                   	push   %ebp
  80168f:	89 e5                	mov    %esp,%ebp
  801691:	53                   	push   %ebx
  801692:	83 ec 04             	sub    $0x4,%esp
  801695:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801698:	8b 45 08             	mov    0x8(%ebp),%eax
  80169b:	8b 40 0c             	mov    0xc(%eax),%eax
  80169e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8016a8:	b8 05 00 00 00       	mov    $0x5,%eax
  8016ad:	e8 45 ff ff ff       	call   8015f7 <fsipc>
  8016b2:	85 c0                	test   %eax,%eax
  8016b4:	78 2c                	js     8016e2 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016b6:	83 ec 08             	sub    $0x8,%esp
  8016b9:	68 00 50 80 00       	push   $0x805000
  8016be:	53                   	push   %ebx
  8016bf:	e8 e7 f0 ff ff       	call   8007ab <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016c4:	a1 80 50 80 00       	mov    0x805080,%eax
  8016c9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016cf:	a1 84 50 80 00       	mov    0x805084,%eax
  8016d4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8016da:	83 c4 10             	add    $0x10,%esp
  8016dd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016e5:	c9                   	leave  
  8016e6:	c3                   	ret    

008016e7 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8016e7:	55                   	push   %ebp
  8016e8:	89 e5                	mov    %esp,%ebp
  8016ea:	53                   	push   %ebx
  8016eb:	83 ec 08             	sub    $0x8,%esp
  8016ee:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8016f1:	8b 55 08             	mov    0x8(%ebp),%edx
  8016f4:	8b 52 0c             	mov    0xc(%edx),%edx
  8016f7:	89 15 00 50 80 00    	mov    %edx,0x805000
  8016fd:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801702:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  801707:	0f 46 d8             	cmovbe %eax,%ebx
	
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  80170a:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  801710:	53                   	push   %ebx
  801711:	ff 75 0c             	pushl  0xc(%ebp)
  801714:	68 08 50 80 00       	push   $0x805008
  801719:	e8 1f f2 ff ff       	call   80093d <memmove>

	
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) 
  80171e:	ba 00 00 00 00       	mov    $0x0,%edx
  801723:	b8 04 00 00 00       	mov    $0x4,%eax
  801728:	e8 ca fe ff ff       	call   8015f7 <fsipc>
  80172d:	83 c4 10             	add    $0x10,%esp
  801730:	85 c0                	test   %eax,%eax
  801732:	78 1d                	js     801751 <devfile_write+0x6a>
		return r;
	assert(r <= n_real); 
  801734:	39 d8                	cmp    %ebx,%eax
  801736:	76 19                	jbe    801751 <devfile_write+0x6a>
  801738:	68 5c 26 80 00       	push   $0x80265c
  80173d:	68 68 26 80 00       	push   $0x802668
  801742:	68 a3 00 00 00       	push   $0xa3
  801747:	68 7d 26 80 00       	push   $0x80267d
  80174c:	e8 fc e9 ff ff       	call   80014d <_panic>
	return r;
}
  801751:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801754:	c9                   	leave  
  801755:	c3                   	ret    

00801756 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801756:	55                   	push   %ebp
  801757:	89 e5                	mov    %esp,%ebp
  801759:	56                   	push   %esi
  80175a:	53                   	push   %ebx
  80175b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80175e:	8b 45 08             	mov    0x8(%ebp),%eax
  801761:	8b 40 0c             	mov    0xc(%eax),%eax
  801764:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801769:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80176f:	ba 00 00 00 00       	mov    $0x0,%edx
  801774:	b8 03 00 00 00       	mov    $0x3,%eax
  801779:	e8 79 fe ff ff       	call   8015f7 <fsipc>
  80177e:	89 c3                	mov    %eax,%ebx
  801780:	85 c0                	test   %eax,%eax
  801782:	78 4b                	js     8017cf <devfile_read+0x79>
		return r;
	assert(r <= n);
  801784:	39 c6                	cmp    %eax,%esi
  801786:	73 16                	jae    80179e <devfile_read+0x48>
  801788:	68 88 26 80 00       	push   $0x802688
  80178d:	68 68 26 80 00       	push   $0x802668
  801792:	6a 7c                	push   $0x7c
  801794:	68 7d 26 80 00       	push   $0x80267d
  801799:	e8 af e9 ff ff       	call   80014d <_panic>
	assert(r <= PGSIZE);
  80179e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017a3:	7e 16                	jle    8017bb <devfile_read+0x65>
  8017a5:	68 8f 26 80 00       	push   $0x80268f
  8017aa:	68 68 26 80 00       	push   $0x802668
  8017af:	6a 7d                	push   $0x7d
  8017b1:	68 7d 26 80 00       	push   $0x80267d
  8017b6:	e8 92 e9 ff ff       	call   80014d <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017bb:	83 ec 04             	sub    $0x4,%esp
  8017be:	50                   	push   %eax
  8017bf:	68 00 50 80 00       	push   $0x805000
  8017c4:	ff 75 0c             	pushl  0xc(%ebp)
  8017c7:	e8 71 f1 ff ff       	call   80093d <memmove>
	return r;
  8017cc:	83 c4 10             	add    $0x10,%esp
}
  8017cf:	89 d8                	mov    %ebx,%eax
  8017d1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017d4:	5b                   	pop    %ebx
  8017d5:	5e                   	pop    %esi
  8017d6:	5d                   	pop    %ebp
  8017d7:	c3                   	ret    

008017d8 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8017d8:	55                   	push   %ebp
  8017d9:	89 e5                	mov    %esp,%ebp
  8017db:	53                   	push   %ebx
  8017dc:	83 ec 20             	sub    $0x20,%esp
  8017df:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8017e2:	53                   	push   %ebx
  8017e3:	e8 8a ef ff ff       	call   800772 <strlen>
  8017e8:	83 c4 10             	add    $0x10,%esp
  8017eb:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017f0:	7f 67                	jg     801859 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017f2:	83 ec 0c             	sub    $0xc,%esp
  8017f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017f8:	50                   	push   %eax
  8017f9:	e8 71 f8 ff ff       	call   80106f <fd_alloc>
  8017fe:	83 c4 10             	add    $0x10,%esp
		return r;
  801801:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801803:	85 c0                	test   %eax,%eax
  801805:	78 57                	js     80185e <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801807:	83 ec 08             	sub    $0x8,%esp
  80180a:	53                   	push   %ebx
  80180b:	68 00 50 80 00       	push   $0x805000
  801810:	e8 96 ef ff ff       	call   8007ab <strcpy>
	fsipcbuf.open.req_omode = mode;
  801815:	8b 45 0c             	mov    0xc(%ebp),%eax
  801818:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80181d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801820:	b8 01 00 00 00       	mov    $0x1,%eax
  801825:	e8 cd fd ff ff       	call   8015f7 <fsipc>
  80182a:	89 c3                	mov    %eax,%ebx
  80182c:	83 c4 10             	add    $0x10,%esp
  80182f:	85 c0                	test   %eax,%eax
  801831:	79 14                	jns    801847 <open+0x6f>
		fd_close(fd, 0);
  801833:	83 ec 08             	sub    $0x8,%esp
  801836:	6a 00                	push   $0x0
  801838:	ff 75 f4             	pushl  -0xc(%ebp)
  80183b:	e8 27 f9 ff ff       	call   801167 <fd_close>
		return r;
  801840:	83 c4 10             	add    $0x10,%esp
  801843:	89 da                	mov    %ebx,%edx
  801845:	eb 17                	jmp    80185e <open+0x86>
	}

	return fd2num(fd);
  801847:	83 ec 0c             	sub    $0xc,%esp
  80184a:	ff 75 f4             	pushl  -0xc(%ebp)
  80184d:	e8 f6 f7 ff ff       	call   801048 <fd2num>
  801852:	89 c2                	mov    %eax,%edx
  801854:	83 c4 10             	add    $0x10,%esp
  801857:	eb 05                	jmp    80185e <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801859:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80185e:	89 d0                	mov    %edx,%eax
  801860:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801863:	c9                   	leave  
  801864:	c3                   	ret    

00801865 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801865:	55                   	push   %ebp
  801866:	89 e5                	mov    %esp,%ebp
  801868:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80186b:	ba 00 00 00 00       	mov    $0x0,%edx
  801870:	b8 08 00 00 00       	mov    $0x8,%eax
  801875:	e8 7d fd ff ff       	call   8015f7 <fsipc>
}
  80187a:	c9                   	leave  
  80187b:	c3                   	ret    

0080187c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80187c:	55                   	push   %ebp
  80187d:	89 e5                	mov    %esp,%ebp
  80187f:	56                   	push   %esi
  801880:	53                   	push   %ebx
  801881:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801884:	83 ec 0c             	sub    $0xc,%esp
  801887:	ff 75 08             	pushl  0x8(%ebp)
  80188a:	e8 c9 f7 ff ff       	call   801058 <fd2data>
  80188f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801891:	83 c4 08             	add    $0x8,%esp
  801894:	68 9b 26 80 00       	push   $0x80269b
  801899:	53                   	push   %ebx
  80189a:	e8 0c ef ff ff       	call   8007ab <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80189f:	8b 46 04             	mov    0x4(%esi),%eax
  8018a2:	2b 06                	sub    (%esi),%eax
  8018a4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8018aa:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018b1:	00 00 00 
	stat->st_dev = &devpipe;
  8018b4:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8018bb:	30 80 00 
	return 0;
}
  8018be:	b8 00 00 00 00       	mov    $0x0,%eax
  8018c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018c6:	5b                   	pop    %ebx
  8018c7:	5e                   	pop    %esi
  8018c8:	5d                   	pop    %ebp
  8018c9:	c3                   	ret    

008018ca <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8018ca:	55                   	push   %ebp
  8018cb:	89 e5                	mov    %esp,%ebp
  8018cd:	53                   	push   %ebx
  8018ce:	83 ec 0c             	sub    $0xc,%esp
  8018d1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8018d4:	53                   	push   %ebx
  8018d5:	6a 00                	push   $0x0
  8018d7:	e8 57 f3 ff ff       	call   800c33 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8018dc:	89 1c 24             	mov    %ebx,(%esp)
  8018df:	e8 74 f7 ff ff       	call   801058 <fd2data>
  8018e4:	83 c4 08             	add    $0x8,%esp
  8018e7:	50                   	push   %eax
  8018e8:	6a 00                	push   $0x0
  8018ea:	e8 44 f3 ff ff       	call   800c33 <sys_page_unmap>
}
  8018ef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018f2:	c9                   	leave  
  8018f3:	c3                   	ret    

008018f4 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8018f4:	55                   	push   %ebp
  8018f5:	89 e5                	mov    %esp,%ebp
  8018f7:	57                   	push   %edi
  8018f8:	56                   	push   %esi
  8018f9:	53                   	push   %ebx
  8018fa:	83 ec 1c             	sub    $0x1c,%esp
  8018fd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801900:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801902:	a1 08 40 80 00       	mov    0x804008,%eax
  801907:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80190a:	83 ec 0c             	sub    $0xc,%esp
  80190d:	ff 75 e0             	pushl  -0x20(%ebp)
  801910:	e8 b2 05 00 00       	call   801ec7 <pageref>
  801915:	89 c3                	mov    %eax,%ebx
  801917:	89 3c 24             	mov    %edi,(%esp)
  80191a:	e8 a8 05 00 00       	call   801ec7 <pageref>
  80191f:	83 c4 10             	add    $0x10,%esp
  801922:	39 c3                	cmp    %eax,%ebx
  801924:	0f 94 c1             	sete   %cl
  801927:	0f b6 c9             	movzbl %cl,%ecx
  80192a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80192d:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801933:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801936:	39 ce                	cmp    %ecx,%esi
  801938:	74 1b                	je     801955 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80193a:	39 c3                	cmp    %eax,%ebx
  80193c:	75 c4                	jne    801902 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80193e:	8b 42 58             	mov    0x58(%edx),%eax
  801941:	ff 75 e4             	pushl  -0x1c(%ebp)
  801944:	50                   	push   %eax
  801945:	56                   	push   %esi
  801946:	68 a2 26 80 00       	push   $0x8026a2
  80194b:	e8 d6 e8 ff ff       	call   800226 <cprintf>
  801950:	83 c4 10             	add    $0x10,%esp
  801953:	eb ad                	jmp    801902 <_pipeisclosed+0xe>
	}
}
  801955:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801958:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80195b:	5b                   	pop    %ebx
  80195c:	5e                   	pop    %esi
  80195d:	5f                   	pop    %edi
  80195e:	5d                   	pop    %ebp
  80195f:	c3                   	ret    

00801960 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801960:	55                   	push   %ebp
  801961:	89 e5                	mov    %esp,%ebp
  801963:	57                   	push   %edi
  801964:	56                   	push   %esi
  801965:	53                   	push   %ebx
  801966:	83 ec 28             	sub    $0x28,%esp
  801969:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80196c:	56                   	push   %esi
  80196d:	e8 e6 f6 ff ff       	call   801058 <fd2data>
  801972:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801974:	83 c4 10             	add    $0x10,%esp
  801977:	bf 00 00 00 00       	mov    $0x0,%edi
  80197c:	eb 4b                	jmp    8019c9 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80197e:	89 da                	mov    %ebx,%edx
  801980:	89 f0                	mov    %esi,%eax
  801982:	e8 6d ff ff ff       	call   8018f4 <_pipeisclosed>
  801987:	85 c0                	test   %eax,%eax
  801989:	75 48                	jne    8019d3 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80198b:	e8 ff f1 ff ff       	call   800b8f <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801990:	8b 43 04             	mov    0x4(%ebx),%eax
  801993:	8b 0b                	mov    (%ebx),%ecx
  801995:	8d 51 20             	lea    0x20(%ecx),%edx
  801998:	39 d0                	cmp    %edx,%eax
  80199a:	73 e2                	jae    80197e <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80199c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80199f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8019a3:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8019a6:	89 c2                	mov    %eax,%edx
  8019a8:	c1 fa 1f             	sar    $0x1f,%edx
  8019ab:	89 d1                	mov    %edx,%ecx
  8019ad:	c1 e9 1b             	shr    $0x1b,%ecx
  8019b0:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8019b3:	83 e2 1f             	and    $0x1f,%edx
  8019b6:	29 ca                	sub    %ecx,%edx
  8019b8:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8019bc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8019c0:	83 c0 01             	add    $0x1,%eax
  8019c3:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019c6:	83 c7 01             	add    $0x1,%edi
  8019c9:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8019cc:	75 c2                	jne    801990 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8019ce:	8b 45 10             	mov    0x10(%ebp),%eax
  8019d1:	eb 05                	jmp    8019d8 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019d3:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8019d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019db:	5b                   	pop    %ebx
  8019dc:	5e                   	pop    %esi
  8019dd:	5f                   	pop    %edi
  8019de:	5d                   	pop    %ebp
  8019df:	c3                   	ret    

008019e0 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019e0:	55                   	push   %ebp
  8019e1:	89 e5                	mov    %esp,%ebp
  8019e3:	57                   	push   %edi
  8019e4:	56                   	push   %esi
  8019e5:	53                   	push   %ebx
  8019e6:	83 ec 18             	sub    $0x18,%esp
  8019e9:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8019ec:	57                   	push   %edi
  8019ed:	e8 66 f6 ff ff       	call   801058 <fd2data>
  8019f2:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019f4:	83 c4 10             	add    $0x10,%esp
  8019f7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019fc:	eb 3d                	jmp    801a3b <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8019fe:	85 db                	test   %ebx,%ebx
  801a00:	74 04                	je     801a06 <devpipe_read+0x26>
				return i;
  801a02:	89 d8                	mov    %ebx,%eax
  801a04:	eb 44                	jmp    801a4a <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801a06:	89 f2                	mov    %esi,%edx
  801a08:	89 f8                	mov    %edi,%eax
  801a0a:	e8 e5 fe ff ff       	call   8018f4 <_pipeisclosed>
  801a0f:	85 c0                	test   %eax,%eax
  801a11:	75 32                	jne    801a45 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801a13:	e8 77 f1 ff ff       	call   800b8f <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801a18:	8b 06                	mov    (%esi),%eax
  801a1a:	3b 46 04             	cmp    0x4(%esi),%eax
  801a1d:	74 df                	je     8019fe <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a1f:	99                   	cltd   
  801a20:	c1 ea 1b             	shr    $0x1b,%edx
  801a23:	01 d0                	add    %edx,%eax
  801a25:	83 e0 1f             	and    $0x1f,%eax
  801a28:	29 d0                	sub    %edx,%eax
  801a2a:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801a2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a32:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801a35:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a38:	83 c3 01             	add    $0x1,%ebx
  801a3b:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801a3e:	75 d8                	jne    801a18 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801a40:	8b 45 10             	mov    0x10(%ebp),%eax
  801a43:	eb 05                	jmp    801a4a <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a45:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801a4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a4d:	5b                   	pop    %ebx
  801a4e:	5e                   	pop    %esi
  801a4f:	5f                   	pop    %edi
  801a50:	5d                   	pop    %ebp
  801a51:	c3                   	ret    

00801a52 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801a52:	55                   	push   %ebp
  801a53:	89 e5                	mov    %esp,%ebp
  801a55:	56                   	push   %esi
  801a56:	53                   	push   %ebx
  801a57:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a5a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a5d:	50                   	push   %eax
  801a5e:	e8 0c f6 ff ff       	call   80106f <fd_alloc>
  801a63:	83 c4 10             	add    $0x10,%esp
  801a66:	89 c2                	mov    %eax,%edx
  801a68:	85 c0                	test   %eax,%eax
  801a6a:	0f 88 2c 01 00 00    	js     801b9c <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a70:	83 ec 04             	sub    $0x4,%esp
  801a73:	68 07 04 00 00       	push   $0x407
  801a78:	ff 75 f4             	pushl  -0xc(%ebp)
  801a7b:	6a 00                	push   $0x0
  801a7d:	e8 2c f1 ff ff       	call   800bae <sys_page_alloc>
  801a82:	83 c4 10             	add    $0x10,%esp
  801a85:	89 c2                	mov    %eax,%edx
  801a87:	85 c0                	test   %eax,%eax
  801a89:	0f 88 0d 01 00 00    	js     801b9c <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801a8f:	83 ec 0c             	sub    $0xc,%esp
  801a92:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a95:	50                   	push   %eax
  801a96:	e8 d4 f5 ff ff       	call   80106f <fd_alloc>
  801a9b:	89 c3                	mov    %eax,%ebx
  801a9d:	83 c4 10             	add    $0x10,%esp
  801aa0:	85 c0                	test   %eax,%eax
  801aa2:	0f 88 e2 00 00 00    	js     801b8a <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801aa8:	83 ec 04             	sub    $0x4,%esp
  801aab:	68 07 04 00 00       	push   $0x407
  801ab0:	ff 75 f0             	pushl  -0x10(%ebp)
  801ab3:	6a 00                	push   $0x0
  801ab5:	e8 f4 f0 ff ff       	call   800bae <sys_page_alloc>
  801aba:	89 c3                	mov    %eax,%ebx
  801abc:	83 c4 10             	add    $0x10,%esp
  801abf:	85 c0                	test   %eax,%eax
  801ac1:	0f 88 c3 00 00 00    	js     801b8a <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801ac7:	83 ec 0c             	sub    $0xc,%esp
  801aca:	ff 75 f4             	pushl  -0xc(%ebp)
  801acd:	e8 86 f5 ff ff       	call   801058 <fd2data>
  801ad2:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ad4:	83 c4 0c             	add    $0xc,%esp
  801ad7:	68 07 04 00 00       	push   $0x407
  801adc:	50                   	push   %eax
  801add:	6a 00                	push   $0x0
  801adf:	e8 ca f0 ff ff       	call   800bae <sys_page_alloc>
  801ae4:	89 c3                	mov    %eax,%ebx
  801ae6:	83 c4 10             	add    $0x10,%esp
  801ae9:	85 c0                	test   %eax,%eax
  801aeb:	0f 88 89 00 00 00    	js     801b7a <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801af1:	83 ec 0c             	sub    $0xc,%esp
  801af4:	ff 75 f0             	pushl  -0x10(%ebp)
  801af7:	e8 5c f5 ff ff       	call   801058 <fd2data>
  801afc:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b03:	50                   	push   %eax
  801b04:	6a 00                	push   $0x0
  801b06:	56                   	push   %esi
  801b07:	6a 00                	push   $0x0
  801b09:	e8 e3 f0 ff ff       	call   800bf1 <sys_page_map>
  801b0e:	89 c3                	mov    %eax,%ebx
  801b10:	83 c4 20             	add    $0x20,%esp
  801b13:	85 c0                	test   %eax,%eax
  801b15:	78 55                	js     801b6c <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801b17:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b20:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b22:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b25:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b2c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b32:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b35:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b37:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b3a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801b41:	83 ec 0c             	sub    $0xc,%esp
  801b44:	ff 75 f4             	pushl  -0xc(%ebp)
  801b47:	e8 fc f4 ff ff       	call   801048 <fd2num>
  801b4c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b4f:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801b51:	83 c4 04             	add    $0x4,%esp
  801b54:	ff 75 f0             	pushl  -0x10(%ebp)
  801b57:	e8 ec f4 ff ff       	call   801048 <fd2num>
  801b5c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b5f:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801b62:	83 c4 10             	add    $0x10,%esp
  801b65:	ba 00 00 00 00       	mov    $0x0,%edx
  801b6a:	eb 30                	jmp    801b9c <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801b6c:	83 ec 08             	sub    $0x8,%esp
  801b6f:	56                   	push   %esi
  801b70:	6a 00                	push   $0x0
  801b72:	e8 bc f0 ff ff       	call   800c33 <sys_page_unmap>
  801b77:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801b7a:	83 ec 08             	sub    $0x8,%esp
  801b7d:	ff 75 f0             	pushl  -0x10(%ebp)
  801b80:	6a 00                	push   $0x0
  801b82:	e8 ac f0 ff ff       	call   800c33 <sys_page_unmap>
  801b87:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801b8a:	83 ec 08             	sub    $0x8,%esp
  801b8d:	ff 75 f4             	pushl  -0xc(%ebp)
  801b90:	6a 00                	push   $0x0
  801b92:	e8 9c f0 ff ff       	call   800c33 <sys_page_unmap>
  801b97:	83 c4 10             	add    $0x10,%esp
  801b9a:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801b9c:	89 d0                	mov    %edx,%eax
  801b9e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ba1:	5b                   	pop    %ebx
  801ba2:	5e                   	pop    %esi
  801ba3:	5d                   	pop    %ebp
  801ba4:	c3                   	ret    

00801ba5 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801ba5:	55                   	push   %ebp
  801ba6:	89 e5                	mov    %esp,%ebp
  801ba8:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bae:	50                   	push   %eax
  801baf:	ff 75 08             	pushl  0x8(%ebp)
  801bb2:	e8 07 f5 ff ff       	call   8010be <fd_lookup>
  801bb7:	83 c4 10             	add    $0x10,%esp
  801bba:	85 c0                	test   %eax,%eax
  801bbc:	78 18                	js     801bd6 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801bbe:	83 ec 0c             	sub    $0xc,%esp
  801bc1:	ff 75 f4             	pushl  -0xc(%ebp)
  801bc4:	e8 8f f4 ff ff       	call   801058 <fd2data>
	return _pipeisclosed(fd, p);
  801bc9:	89 c2                	mov    %eax,%edx
  801bcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bce:	e8 21 fd ff ff       	call   8018f4 <_pipeisclosed>
  801bd3:	83 c4 10             	add    $0x10,%esp
}
  801bd6:	c9                   	leave  
  801bd7:	c3                   	ret    

00801bd8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801bd8:	55                   	push   %ebp
  801bd9:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801bdb:	b8 00 00 00 00       	mov    $0x0,%eax
  801be0:	5d                   	pop    %ebp
  801be1:	c3                   	ret    

00801be2 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801be2:	55                   	push   %ebp
  801be3:	89 e5                	mov    %esp,%ebp
  801be5:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801be8:	68 ba 26 80 00       	push   $0x8026ba
  801bed:	ff 75 0c             	pushl  0xc(%ebp)
  801bf0:	e8 b6 eb ff ff       	call   8007ab <strcpy>
	return 0;
}
  801bf5:	b8 00 00 00 00       	mov    $0x0,%eax
  801bfa:	c9                   	leave  
  801bfb:	c3                   	ret    

00801bfc <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bfc:	55                   	push   %ebp
  801bfd:	89 e5                	mov    %esp,%ebp
  801bff:	57                   	push   %edi
  801c00:	56                   	push   %esi
  801c01:	53                   	push   %ebx
  801c02:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c08:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c0d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c13:	eb 2d                	jmp    801c42 <devcons_write+0x46>
		m = n - tot;
  801c15:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c18:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801c1a:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801c1d:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801c22:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c25:	83 ec 04             	sub    $0x4,%esp
  801c28:	53                   	push   %ebx
  801c29:	03 45 0c             	add    0xc(%ebp),%eax
  801c2c:	50                   	push   %eax
  801c2d:	57                   	push   %edi
  801c2e:	e8 0a ed ff ff       	call   80093d <memmove>
		sys_cputs(buf, m);
  801c33:	83 c4 08             	add    $0x8,%esp
  801c36:	53                   	push   %ebx
  801c37:	57                   	push   %edi
  801c38:	e8 b5 ee ff ff       	call   800af2 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c3d:	01 de                	add    %ebx,%esi
  801c3f:	83 c4 10             	add    $0x10,%esp
  801c42:	89 f0                	mov    %esi,%eax
  801c44:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c47:	72 cc                	jb     801c15 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801c49:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c4c:	5b                   	pop    %ebx
  801c4d:	5e                   	pop    %esi
  801c4e:	5f                   	pop    %edi
  801c4f:	5d                   	pop    %ebp
  801c50:	c3                   	ret    

00801c51 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c51:	55                   	push   %ebp
  801c52:	89 e5                	mov    %esp,%ebp
  801c54:	83 ec 08             	sub    $0x8,%esp
  801c57:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801c5c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c60:	74 2a                	je     801c8c <devcons_read+0x3b>
  801c62:	eb 05                	jmp    801c69 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801c64:	e8 26 ef ff ff       	call   800b8f <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801c69:	e8 a2 ee ff ff       	call   800b10 <sys_cgetc>
  801c6e:	85 c0                	test   %eax,%eax
  801c70:	74 f2                	je     801c64 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801c72:	85 c0                	test   %eax,%eax
  801c74:	78 16                	js     801c8c <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801c76:	83 f8 04             	cmp    $0x4,%eax
  801c79:	74 0c                	je     801c87 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801c7b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c7e:	88 02                	mov    %al,(%edx)
	return 1;
  801c80:	b8 01 00 00 00       	mov    $0x1,%eax
  801c85:	eb 05                	jmp    801c8c <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801c87:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801c8c:	c9                   	leave  
  801c8d:	c3                   	ret    

00801c8e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801c8e:	55                   	push   %ebp
  801c8f:	89 e5                	mov    %esp,%ebp
  801c91:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801c94:	8b 45 08             	mov    0x8(%ebp),%eax
  801c97:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801c9a:	6a 01                	push   $0x1
  801c9c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c9f:	50                   	push   %eax
  801ca0:	e8 4d ee ff ff       	call   800af2 <sys_cputs>
}
  801ca5:	83 c4 10             	add    $0x10,%esp
  801ca8:	c9                   	leave  
  801ca9:	c3                   	ret    

00801caa <getchar>:

int
getchar(void)
{
  801caa:	55                   	push   %ebp
  801cab:	89 e5                	mov    %esp,%ebp
  801cad:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801cb0:	6a 01                	push   $0x1
  801cb2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801cb5:	50                   	push   %eax
  801cb6:	6a 00                	push   $0x0
  801cb8:	e8 67 f6 ff ff       	call   801324 <read>
	if (r < 0)
  801cbd:	83 c4 10             	add    $0x10,%esp
  801cc0:	85 c0                	test   %eax,%eax
  801cc2:	78 0f                	js     801cd3 <getchar+0x29>
		return r;
	if (r < 1)
  801cc4:	85 c0                	test   %eax,%eax
  801cc6:	7e 06                	jle    801cce <getchar+0x24>
		return -E_EOF;
	return c;
  801cc8:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801ccc:	eb 05                	jmp    801cd3 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801cce:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801cd3:	c9                   	leave  
  801cd4:	c3                   	ret    

00801cd5 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801cd5:	55                   	push   %ebp
  801cd6:	89 e5                	mov    %esp,%ebp
  801cd8:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cdb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cde:	50                   	push   %eax
  801cdf:	ff 75 08             	pushl  0x8(%ebp)
  801ce2:	e8 d7 f3 ff ff       	call   8010be <fd_lookup>
  801ce7:	83 c4 10             	add    $0x10,%esp
  801cea:	85 c0                	test   %eax,%eax
  801cec:	78 11                	js     801cff <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801cee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cf1:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cf7:	39 10                	cmp    %edx,(%eax)
  801cf9:	0f 94 c0             	sete   %al
  801cfc:	0f b6 c0             	movzbl %al,%eax
}
  801cff:	c9                   	leave  
  801d00:	c3                   	ret    

00801d01 <opencons>:

int
opencons(void)
{
  801d01:	55                   	push   %ebp
  801d02:	89 e5                	mov    %esp,%ebp
  801d04:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d07:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d0a:	50                   	push   %eax
  801d0b:	e8 5f f3 ff ff       	call   80106f <fd_alloc>
  801d10:	83 c4 10             	add    $0x10,%esp
		return r;
  801d13:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d15:	85 c0                	test   %eax,%eax
  801d17:	78 3e                	js     801d57 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d19:	83 ec 04             	sub    $0x4,%esp
  801d1c:	68 07 04 00 00       	push   $0x407
  801d21:	ff 75 f4             	pushl  -0xc(%ebp)
  801d24:	6a 00                	push   $0x0
  801d26:	e8 83 ee ff ff       	call   800bae <sys_page_alloc>
  801d2b:	83 c4 10             	add    $0x10,%esp
		return r;
  801d2e:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d30:	85 c0                	test   %eax,%eax
  801d32:	78 23                	js     801d57 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801d34:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d3d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d42:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801d49:	83 ec 0c             	sub    $0xc,%esp
  801d4c:	50                   	push   %eax
  801d4d:	e8 f6 f2 ff ff       	call   801048 <fd2num>
  801d52:	89 c2                	mov    %eax,%edx
  801d54:	83 c4 10             	add    $0x10,%esp
}
  801d57:	89 d0                	mov    %edx,%eax
  801d59:	c9                   	leave  
  801d5a:	c3                   	ret    

00801d5b <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801d5b:	55                   	push   %ebp
  801d5c:	89 e5                	mov    %esp,%ebp
  801d5e:	53                   	push   %ebx
  801d5f:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  801d62:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801d69:	75 28                	jne    801d93 <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  801d6b:	e8 00 ee ff ff       	call   800b70 <sys_getenvid>
  801d70:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_U | PTE_W);
  801d72:	83 ec 04             	sub    $0x4,%esp
  801d75:	6a 06                	push   $0x6
  801d77:	68 00 f0 bf ee       	push   $0xeebff000
  801d7c:	50                   	push   %eax
  801d7d:	e8 2c ee ff ff       	call   800bae <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  801d82:	83 c4 08             	add    $0x8,%esp
  801d85:	68 a0 1d 80 00       	push   $0x801da0
  801d8a:	53                   	push   %ebx
  801d8b:	e8 69 ef ff ff       	call   800cf9 <sys_env_set_pgfault_upcall>
  801d90:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801d93:	8b 45 08             	mov    0x8(%ebp),%eax
  801d96:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801d9b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d9e:	c9                   	leave  
  801d9f:	c3                   	ret    

00801da0 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801da0:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801da1:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801da6:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801da8:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	# My method is different. Copy the values to the other stack
	# in a convinient way, and then pop everything.
	movl %esp, %ebp		# ebp refers to the exception stack
  801dab:	89 e5                	mov    %esp,%ebp
	movl 48(%ebp), %esp 	# go to other stack
  801dad:	8b 65 30             	mov    0x30(%ebp),%esp

	pushl 40(%ebp)		# eip - ORDER SWITCHED WITH EFLAGS
  801db0:	ff 75 28             	pushl  0x28(%ebp)
	pushl 44(%ebp)      	# eflags
  801db3:	ff 75 2c             	pushl  0x2c(%ebp)
	pushl 36(%ebp)		# all the 8 remaining regs
  801db6:	ff 75 24             	pushl  0x24(%ebp)
	pushl 32(%ebp)
  801db9:	ff 75 20             	pushl  0x20(%ebp)
	pushl 28(%ebp)
  801dbc:	ff 75 1c             	pushl  0x1c(%ebp)
	pushl 24(%ebp)
  801dbf:	ff 75 18             	pushl  0x18(%ebp)
	pushl 20(%ebp)
  801dc2:	ff 75 14             	pushl  0x14(%ebp)
	pushl 16(%ebp)
  801dc5:	ff 75 10             	pushl  0x10(%ebp)
	pushl 12(%ebp)
  801dc8:	ff 75 0c             	pushl  0xc(%ebp)
	pushl 8(%ebp)
  801dcb:	ff 75 08             	pushl  0x8(%ebp)

	popal			# now just pop everything!
  801dce:	61                   	popa   
	popfl
  801dcf:	9d                   	popf   
	ret
  801dd0:	c3                   	ret    

00801dd1 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801dd1:	55                   	push   %ebp
  801dd2:	89 e5                	mov    %esp,%ebp
  801dd4:	56                   	push   %esi
  801dd5:	53                   	push   %ebx
  801dd6:	8b 75 08             	mov    0x8(%ebp),%esi
  801dd9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ddc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  801ddf:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801de1:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801de6:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  801de9:	83 ec 0c             	sub    $0xc,%esp
  801dec:	50                   	push   %eax
  801ded:	e8 6c ef ff ff       	call   800d5e <sys_ipc_recv>

	if (r < 0) {
  801df2:	83 c4 10             	add    $0x10,%esp
  801df5:	85 c0                	test   %eax,%eax
  801df7:	79 16                	jns    801e0f <ipc_recv+0x3e>
		if (from_env_store)
  801df9:	85 f6                	test   %esi,%esi
  801dfb:	74 06                	je     801e03 <ipc_recv+0x32>
			*from_env_store = 0;
  801dfd:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  801e03:	85 db                	test   %ebx,%ebx
  801e05:	74 2c                	je     801e33 <ipc_recv+0x62>
			*perm_store = 0;
  801e07:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801e0d:	eb 24                	jmp    801e33 <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  801e0f:	85 f6                	test   %esi,%esi
  801e11:	74 0a                	je     801e1d <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  801e13:	a1 08 40 80 00       	mov    0x804008,%eax
  801e18:	8b 40 74             	mov    0x74(%eax),%eax
  801e1b:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  801e1d:	85 db                	test   %ebx,%ebx
  801e1f:	74 0a                	je     801e2b <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  801e21:	a1 08 40 80 00       	mov    0x804008,%eax
  801e26:	8b 40 78             	mov    0x78(%eax),%eax
  801e29:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  801e2b:	a1 08 40 80 00       	mov    0x804008,%eax
  801e30:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  801e33:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e36:	5b                   	pop    %ebx
  801e37:	5e                   	pop    %esi
  801e38:	5d                   	pop    %ebp
  801e39:	c3                   	ret    

00801e3a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e3a:	55                   	push   %ebp
  801e3b:	89 e5                	mov    %esp,%ebp
  801e3d:	57                   	push   %edi
  801e3e:	56                   	push   %esi
  801e3f:	53                   	push   %ebx
  801e40:	83 ec 0c             	sub    $0xc,%esp
  801e43:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e46:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e49:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  801e4c:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801e4e:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801e53:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  801e56:	ff 75 14             	pushl  0x14(%ebp)
  801e59:	53                   	push   %ebx
  801e5a:	56                   	push   %esi
  801e5b:	57                   	push   %edi
  801e5c:	e8 da ee ff ff       	call   800d3b <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  801e61:	83 c4 10             	add    $0x10,%esp
  801e64:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e67:	75 07                	jne    801e70 <ipc_send+0x36>
			sys_yield();
  801e69:	e8 21 ed ff ff       	call   800b8f <sys_yield>
  801e6e:	eb e6                	jmp    801e56 <ipc_send+0x1c>
		} else if (r < 0) {
  801e70:	85 c0                	test   %eax,%eax
  801e72:	79 12                	jns    801e86 <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  801e74:	50                   	push   %eax
  801e75:	68 c6 26 80 00       	push   $0x8026c6
  801e7a:	6a 51                	push   $0x51
  801e7c:	68 d3 26 80 00       	push   $0x8026d3
  801e81:	e8 c7 e2 ff ff       	call   80014d <_panic>
		}
	}
}
  801e86:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e89:	5b                   	pop    %ebx
  801e8a:	5e                   	pop    %esi
  801e8b:	5f                   	pop    %edi
  801e8c:	5d                   	pop    %ebp
  801e8d:	c3                   	ret    

00801e8e <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801e8e:	55                   	push   %ebp
  801e8f:	89 e5                	mov    %esp,%ebp
  801e91:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801e94:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801e99:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801e9c:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ea2:	8b 52 50             	mov    0x50(%edx),%edx
  801ea5:	39 ca                	cmp    %ecx,%edx
  801ea7:	75 0d                	jne    801eb6 <ipc_find_env+0x28>
			return envs[i].env_id;
  801ea9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801eac:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801eb1:	8b 40 48             	mov    0x48(%eax),%eax
  801eb4:	eb 0f                	jmp    801ec5 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801eb6:	83 c0 01             	add    $0x1,%eax
  801eb9:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ebe:	75 d9                	jne    801e99 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801ec0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ec5:	5d                   	pop    %ebp
  801ec6:	c3                   	ret    

00801ec7 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ec7:	55                   	push   %ebp
  801ec8:	89 e5                	mov    %esp,%ebp
  801eca:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ecd:	89 d0                	mov    %edx,%eax
  801ecf:	c1 e8 16             	shr    $0x16,%eax
  801ed2:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801ed9:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ede:	f6 c1 01             	test   $0x1,%cl
  801ee1:	74 1d                	je     801f00 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801ee3:	c1 ea 0c             	shr    $0xc,%edx
  801ee6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801eed:	f6 c2 01             	test   $0x1,%dl
  801ef0:	74 0e                	je     801f00 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ef2:	c1 ea 0c             	shr    $0xc,%edx
  801ef5:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801efc:	ef 
  801efd:	0f b7 c0             	movzwl %ax,%eax
}
  801f00:	5d                   	pop    %ebp
  801f01:	c3                   	ret    
  801f02:	66 90                	xchg   %ax,%ax
  801f04:	66 90                	xchg   %ax,%ax
  801f06:	66 90                	xchg   %ax,%ax
  801f08:	66 90                	xchg   %ax,%ax
  801f0a:	66 90                	xchg   %ax,%ax
  801f0c:	66 90                	xchg   %ax,%ax
  801f0e:	66 90                	xchg   %ax,%ax

00801f10 <__udivdi3>:
  801f10:	55                   	push   %ebp
  801f11:	57                   	push   %edi
  801f12:	56                   	push   %esi
  801f13:	53                   	push   %ebx
  801f14:	83 ec 1c             	sub    $0x1c,%esp
  801f17:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801f1b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801f1f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801f23:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f27:	85 f6                	test   %esi,%esi
  801f29:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f2d:	89 ca                	mov    %ecx,%edx
  801f2f:	89 f8                	mov    %edi,%eax
  801f31:	75 3d                	jne    801f70 <__udivdi3+0x60>
  801f33:	39 cf                	cmp    %ecx,%edi
  801f35:	0f 87 c5 00 00 00    	ja     802000 <__udivdi3+0xf0>
  801f3b:	85 ff                	test   %edi,%edi
  801f3d:	89 fd                	mov    %edi,%ebp
  801f3f:	75 0b                	jne    801f4c <__udivdi3+0x3c>
  801f41:	b8 01 00 00 00       	mov    $0x1,%eax
  801f46:	31 d2                	xor    %edx,%edx
  801f48:	f7 f7                	div    %edi
  801f4a:	89 c5                	mov    %eax,%ebp
  801f4c:	89 c8                	mov    %ecx,%eax
  801f4e:	31 d2                	xor    %edx,%edx
  801f50:	f7 f5                	div    %ebp
  801f52:	89 c1                	mov    %eax,%ecx
  801f54:	89 d8                	mov    %ebx,%eax
  801f56:	89 cf                	mov    %ecx,%edi
  801f58:	f7 f5                	div    %ebp
  801f5a:	89 c3                	mov    %eax,%ebx
  801f5c:	89 d8                	mov    %ebx,%eax
  801f5e:	89 fa                	mov    %edi,%edx
  801f60:	83 c4 1c             	add    $0x1c,%esp
  801f63:	5b                   	pop    %ebx
  801f64:	5e                   	pop    %esi
  801f65:	5f                   	pop    %edi
  801f66:	5d                   	pop    %ebp
  801f67:	c3                   	ret    
  801f68:	90                   	nop
  801f69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f70:	39 ce                	cmp    %ecx,%esi
  801f72:	77 74                	ja     801fe8 <__udivdi3+0xd8>
  801f74:	0f bd fe             	bsr    %esi,%edi
  801f77:	83 f7 1f             	xor    $0x1f,%edi
  801f7a:	0f 84 98 00 00 00    	je     802018 <__udivdi3+0x108>
  801f80:	bb 20 00 00 00       	mov    $0x20,%ebx
  801f85:	89 f9                	mov    %edi,%ecx
  801f87:	89 c5                	mov    %eax,%ebp
  801f89:	29 fb                	sub    %edi,%ebx
  801f8b:	d3 e6                	shl    %cl,%esi
  801f8d:	89 d9                	mov    %ebx,%ecx
  801f8f:	d3 ed                	shr    %cl,%ebp
  801f91:	89 f9                	mov    %edi,%ecx
  801f93:	d3 e0                	shl    %cl,%eax
  801f95:	09 ee                	or     %ebp,%esi
  801f97:	89 d9                	mov    %ebx,%ecx
  801f99:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f9d:	89 d5                	mov    %edx,%ebp
  801f9f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801fa3:	d3 ed                	shr    %cl,%ebp
  801fa5:	89 f9                	mov    %edi,%ecx
  801fa7:	d3 e2                	shl    %cl,%edx
  801fa9:	89 d9                	mov    %ebx,%ecx
  801fab:	d3 e8                	shr    %cl,%eax
  801fad:	09 c2                	or     %eax,%edx
  801faf:	89 d0                	mov    %edx,%eax
  801fb1:	89 ea                	mov    %ebp,%edx
  801fb3:	f7 f6                	div    %esi
  801fb5:	89 d5                	mov    %edx,%ebp
  801fb7:	89 c3                	mov    %eax,%ebx
  801fb9:	f7 64 24 0c          	mull   0xc(%esp)
  801fbd:	39 d5                	cmp    %edx,%ebp
  801fbf:	72 10                	jb     801fd1 <__udivdi3+0xc1>
  801fc1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801fc5:	89 f9                	mov    %edi,%ecx
  801fc7:	d3 e6                	shl    %cl,%esi
  801fc9:	39 c6                	cmp    %eax,%esi
  801fcb:	73 07                	jae    801fd4 <__udivdi3+0xc4>
  801fcd:	39 d5                	cmp    %edx,%ebp
  801fcf:	75 03                	jne    801fd4 <__udivdi3+0xc4>
  801fd1:	83 eb 01             	sub    $0x1,%ebx
  801fd4:	31 ff                	xor    %edi,%edi
  801fd6:	89 d8                	mov    %ebx,%eax
  801fd8:	89 fa                	mov    %edi,%edx
  801fda:	83 c4 1c             	add    $0x1c,%esp
  801fdd:	5b                   	pop    %ebx
  801fde:	5e                   	pop    %esi
  801fdf:	5f                   	pop    %edi
  801fe0:	5d                   	pop    %ebp
  801fe1:	c3                   	ret    
  801fe2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801fe8:	31 ff                	xor    %edi,%edi
  801fea:	31 db                	xor    %ebx,%ebx
  801fec:	89 d8                	mov    %ebx,%eax
  801fee:	89 fa                	mov    %edi,%edx
  801ff0:	83 c4 1c             	add    $0x1c,%esp
  801ff3:	5b                   	pop    %ebx
  801ff4:	5e                   	pop    %esi
  801ff5:	5f                   	pop    %edi
  801ff6:	5d                   	pop    %ebp
  801ff7:	c3                   	ret    
  801ff8:	90                   	nop
  801ff9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802000:	89 d8                	mov    %ebx,%eax
  802002:	f7 f7                	div    %edi
  802004:	31 ff                	xor    %edi,%edi
  802006:	89 c3                	mov    %eax,%ebx
  802008:	89 d8                	mov    %ebx,%eax
  80200a:	89 fa                	mov    %edi,%edx
  80200c:	83 c4 1c             	add    $0x1c,%esp
  80200f:	5b                   	pop    %ebx
  802010:	5e                   	pop    %esi
  802011:	5f                   	pop    %edi
  802012:	5d                   	pop    %ebp
  802013:	c3                   	ret    
  802014:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802018:	39 ce                	cmp    %ecx,%esi
  80201a:	72 0c                	jb     802028 <__udivdi3+0x118>
  80201c:	31 db                	xor    %ebx,%ebx
  80201e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802022:	0f 87 34 ff ff ff    	ja     801f5c <__udivdi3+0x4c>
  802028:	bb 01 00 00 00       	mov    $0x1,%ebx
  80202d:	e9 2a ff ff ff       	jmp    801f5c <__udivdi3+0x4c>
  802032:	66 90                	xchg   %ax,%ax
  802034:	66 90                	xchg   %ax,%ax
  802036:	66 90                	xchg   %ax,%ax
  802038:	66 90                	xchg   %ax,%ax
  80203a:	66 90                	xchg   %ax,%ax
  80203c:	66 90                	xchg   %ax,%ax
  80203e:	66 90                	xchg   %ax,%ax

00802040 <__umoddi3>:
  802040:	55                   	push   %ebp
  802041:	57                   	push   %edi
  802042:	56                   	push   %esi
  802043:	53                   	push   %ebx
  802044:	83 ec 1c             	sub    $0x1c,%esp
  802047:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80204b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80204f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802053:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802057:	85 d2                	test   %edx,%edx
  802059:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80205d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802061:	89 f3                	mov    %esi,%ebx
  802063:	89 3c 24             	mov    %edi,(%esp)
  802066:	89 74 24 04          	mov    %esi,0x4(%esp)
  80206a:	75 1c                	jne    802088 <__umoddi3+0x48>
  80206c:	39 f7                	cmp    %esi,%edi
  80206e:	76 50                	jbe    8020c0 <__umoddi3+0x80>
  802070:	89 c8                	mov    %ecx,%eax
  802072:	89 f2                	mov    %esi,%edx
  802074:	f7 f7                	div    %edi
  802076:	89 d0                	mov    %edx,%eax
  802078:	31 d2                	xor    %edx,%edx
  80207a:	83 c4 1c             	add    $0x1c,%esp
  80207d:	5b                   	pop    %ebx
  80207e:	5e                   	pop    %esi
  80207f:	5f                   	pop    %edi
  802080:	5d                   	pop    %ebp
  802081:	c3                   	ret    
  802082:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802088:	39 f2                	cmp    %esi,%edx
  80208a:	89 d0                	mov    %edx,%eax
  80208c:	77 52                	ja     8020e0 <__umoddi3+0xa0>
  80208e:	0f bd ea             	bsr    %edx,%ebp
  802091:	83 f5 1f             	xor    $0x1f,%ebp
  802094:	75 5a                	jne    8020f0 <__umoddi3+0xb0>
  802096:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80209a:	0f 82 e0 00 00 00    	jb     802180 <__umoddi3+0x140>
  8020a0:	39 0c 24             	cmp    %ecx,(%esp)
  8020a3:	0f 86 d7 00 00 00    	jbe    802180 <__umoddi3+0x140>
  8020a9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020ad:	8b 54 24 04          	mov    0x4(%esp),%edx
  8020b1:	83 c4 1c             	add    $0x1c,%esp
  8020b4:	5b                   	pop    %ebx
  8020b5:	5e                   	pop    %esi
  8020b6:	5f                   	pop    %edi
  8020b7:	5d                   	pop    %ebp
  8020b8:	c3                   	ret    
  8020b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020c0:	85 ff                	test   %edi,%edi
  8020c2:	89 fd                	mov    %edi,%ebp
  8020c4:	75 0b                	jne    8020d1 <__umoddi3+0x91>
  8020c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8020cb:	31 d2                	xor    %edx,%edx
  8020cd:	f7 f7                	div    %edi
  8020cf:	89 c5                	mov    %eax,%ebp
  8020d1:	89 f0                	mov    %esi,%eax
  8020d3:	31 d2                	xor    %edx,%edx
  8020d5:	f7 f5                	div    %ebp
  8020d7:	89 c8                	mov    %ecx,%eax
  8020d9:	f7 f5                	div    %ebp
  8020db:	89 d0                	mov    %edx,%eax
  8020dd:	eb 99                	jmp    802078 <__umoddi3+0x38>
  8020df:	90                   	nop
  8020e0:	89 c8                	mov    %ecx,%eax
  8020e2:	89 f2                	mov    %esi,%edx
  8020e4:	83 c4 1c             	add    $0x1c,%esp
  8020e7:	5b                   	pop    %ebx
  8020e8:	5e                   	pop    %esi
  8020e9:	5f                   	pop    %edi
  8020ea:	5d                   	pop    %ebp
  8020eb:	c3                   	ret    
  8020ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020f0:	8b 34 24             	mov    (%esp),%esi
  8020f3:	bf 20 00 00 00       	mov    $0x20,%edi
  8020f8:	89 e9                	mov    %ebp,%ecx
  8020fa:	29 ef                	sub    %ebp,%edi
  8020fc:	d3 e0                	shl    %cl,%eax
  8020fe:	89 f9                	mov    %edi,%ecx
  802100:	89 f2                	mov    %esi,%edx
  802102:	d3 ea                	shr    %cl,%edx
  802104:	89 e9                	mov    %ebp,%ecx
  802106:	09 c2                	or     %eax,%edx
  802108:	89 d8                	mov    %ebx,%eax
  80210a:	89 14 24             	mov    %edx,(%esp)
  80210d:	89 f2                	mov    %esi,%edx
  80210f:	d3 e2                	shl    %cl,%edx
  802111:	89 f9                	mov    %edi,%ecx
  802113:	89 54 24 04          	mov    %edx,0x4(%esp)
  802117:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80211b:	d3 e8                	shr    %cl,%eax
  80211d:	89 e9                	mov    %ebp,%ecx
  80211f:	89 c6                	mov    %eax,%esi
  802121:	d3 e3                	shl    %cl,%ebx
  802123:	89 f9                	mov    %edi,%ecx
  802125:	89 d0                	mov    %edx,%eax
  802127:	d3 e8                	shr    %cl,%eax
  802129:	89 e9                	mov    %ebp,%ecx
  80212b:	09 d8                	or     %ebx,%eax
  80212d:	89 d3                	mov    %edx,%ebx
  80212f:	89 f2                	mov    %esi,%edx
  802131:	f7 34 24             	divl   (%esp)
  802134:	89 d6                	mov    %edx,%esi
  802136:	d3 e3                	shl    %cl,%ebx
  802138:	f7 64 24 04          	mull   0x4(%esp)
  80213c:	39 d6                	cmp    %edx,%esi
  80213e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802142:	89 d1                	mov    %edx,%ecx
  802144:	89 c3                	mov    %eax,%ebx
  802146:	72 08                	jb     802150 <__umoddi3+0x110>
  802148:	75 11                	jne    80215b <__umoddi3+0x11b>
  80214a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80214e:	73 0b                	jae    80215b <__umoddi3+0x11b>
  802150:	2b 44 24 04          	sub    0x4(%esp),%eax
  802154:	1b 14 24             	sbb    (%esp),%edx
  802157:	89 d1                	mov    %edx,%ecx
  802159:	89 c3                	mov    %eax,%ebx
  80215b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80215f:	29 da                	sub    %ebx,%edx
  802161:	19 ce                	sbb    %ecx,%esi
  802163:	89 f9                	mov    %edi,%ecx
  802165:	89 f0                	mov    %esi,%eax
  802167:	d3 e0                	shl    %cl,%eax
  802169:	89 e9                	mov    %ebp,%ecx
  80216b:	d3 ea                	shr    %cl,%edx
  80216d:	89 e9                	mov    %ebp,%ecx
  80216f:	d3 ee                	shr    %cl,%esi
  802171:	09 d0                	or     %edx,%eax
  802173:	89 f2                	mov    %esi,%edx
  802175:	83 c4 1c             	add    $0x1c,%esp
  802178:	5b                   	pop    %ebx
  802179:	5e                   	pop    %esi
  80217a:	5f                   	pop    %edi
  80217b:	5d                   	pop    %ebp
  80217c:	c3                   	ret    
  80217d:	8d 76 00             	lea    0x0(%esi),%esi
  802180:	29 f9                	sub    %edi,%ecx
  802182:	19 d6                	sbb    %edx,%esi
  802184:	89 74 24 04          	mov    %esi,0x4(%esp)
  802188:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80218c:	e9 18 ff ff ff       	jmp    8020a9 <__umoddi3+0x69>
