
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
  800044:	e8 a9 0e 00 00       	call   800ef2 <fork>
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
  8000b8:	68 40 21 80 00       	push   $0x802140
  8000bd:	6a 21                	push   $0x21
  8000bf:	68 68 21 80 00       	push   $0x802168
  8000c4:	e8 84 00 00 00       	call   80014d <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000c9:	a1 08 40 80 00       	mov    0x804008,%eax
  8000ce:	8b 50 5c             	mov    0x5c(%eax),%edx
  8000d1:	8b 40 48             	mov    0x48(%eax),%eax
  8000d4:	83 ec 04             	sub    $0x4,%esp
  8000d7:	52                   	push   %edx
  8000d8:	50                   	push   %eax
  8000d9:	68 7b 21 80 00       	push   $0x80217b
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
  800139:	e8 74 10 00 00       	call   8011b2 <close_all>
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
  80016b:	68 a4 21 80 00       	push   $0x8021a4
  800170:	e8 b1 00 00 00       	call   800226 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800175:	83 c4 18             	add    $0x18,%esp
  800178:	53                   	push   %ebx
  800179:	ff 75 10             	pushl  0x10(%ebp)
  80017c:	e8 54 00 00 00       	call   8001d5 <vcprintf>
	cprintf("\n");
  800181:	c7 04 24 97 21 80 00 	movl   $0x802197,(%esp)
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
  800289:	e8 22 1c 00 00       	call   801eb0 <__udivdi3>
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
  8002cc:	e8 0f 1d 00 00       	call   801fe0 <__umoddi3>
  8002d1:	83 c4 14             	add    $0x14,%esp
  8002d4:	0f be 80 c7 21 80 00 	movsbl 0x8021c7(%eax),%eax
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
  8003d0:	ff 24 85 00 23 80 00 	jmp    *0x802300(,%eax,4)
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
  800494:	8b 14 85 60 24 80 00 	mov    0x802460(,%eax,4),%edx
  80049b:	85 d2                	test   %edx,%edx
  80049d:	75 18                	jne    8004b7 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80049f:	50                   	push   %eax
  8004a0:	68 df 21 80 00       	push   $0x8021df
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
  8004b8:	68 4e 26 80 00       	push   $0x80264e
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
  8004dc:	b8 d8 21 80 00       	mov    $0x8021d8,%eax
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
  800b57:	68 bf 24 80 00       	push   $0x8024bf
  800b5c:	6a 23                	push   $0x23
  800b5e:	68 dc 24 80 00       	push   $0x8024dc
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
  800bd8:	68 bf 24 80 00       	push   $0x8024bf
  800bdd:	6a 23                	push   $0x23
  800bdf:	68 dc 24 80 00       	push   $0x8024dc
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
  800c1a:	68 bf 24 80 00       	push   $0x8024bf
  800c1f:	6a 23                	push   $0x23
  800c21:	68 dc 24 80 00       	push   $0x8024dc
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
  800c5c:	68 bf 24 80 00       	push   $0x8024bf
  800c61:	6a 23                	push   $0x23
  800c63:	68 dc 24 80 00       	push   $0x8024dc
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
  800c9e:	68 bf 24 80 00       	push   $0x8024bf
  800ca3:	6a 23                	push   $0x23
  800ca5:	68 dc 24 80 00       	push   $0x8024dc
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
  800ce0:	68 bf 24 80 00       	push   $0x8024bf
  800ce5:	6a 23                	push   $0x23
  800ce7:	68 dc 24 80 00       	push   $0x8024dc
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
  800d22:	68 bf 24 80 00       	push   $0x8024bf
  800d27:	6a 23                	push   $0x23
  800d29:	68 dc 24 80 00       	push   $0x8024dc
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
  800d86:	68 bf 24 80 00       	push   $0x8024bf
  800d8b:	6a 23                	push   $0x23
  800d8d:	68 dc 24 80 00       	push   $0x8024dc
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
  800da2:	56                   	push   %esi
  800da3:	53                   	push   %ebx
	int r;

	// LAB 4: Your code here.
	// Check if page is writable or COW
	pte_t pte = uvpt[pn];
  800da4:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
	uint32_t perm = PTE_P | PTE_U;
	if (pte && (PTE_COW | PTE_W)) {
		perm |= PTE_COW;
  800dab:	83 f9 01             	cmp    $0x1,%ecx
  800dae:	19 f6                	sbb    %esi,%esi
  800db0:	81 e6 00 f8 ff ff    	and    $0xfffff800,%esi
  800db6:	81 c6 05 08 00 00    	add    $0x805,%esi
	}

	// Map page
	void *va = (void *) (pn * PGSIZE);
  800dbc:	c1 e2 0c             	shl    $0xc,%edx
  800dbf:	89 d3                	mov    %edx,%ebx
	// Map on the child
	if ((r = sys_page_map(0, va, envid, va, perm)) < 0) {
  800dc1:	83 ec 0c             	sub    $0xc,%esp
  800dc4:	56                   	push   %esi
  800dc5:	52                   	push   %edx
  800dc6:	50                   	push   %eax
  800dc7:	52                   	push   %edx
  800dc8:	6a 00                	push   $0x0
  800dca:	e8 22 fe ff ff       	call   800bf1 <sys_page_map>
  800dcf:	83 c4 20             	add    $0x20,%esp
  800dd2:	85 c0                	test   %eax,%eax
  800dd4:	79 12                	jns    800de8 <duppage+0x49>
		panic("sys_page_alloc: %e", r);
  800dd6:	50                   	push   %eax
  800dd7:	68 ea 24 80 00       	push   $0x8024ea
  800ddc:	6a 56                	push   $0x56
  800dde:	68 fd 24 80 00       	push   $0x8024fd
  800de3:	e8 65 f3 ff ff       	call   80014d <_panic>
		return r;
	}

	// Change the permission on the parent
	if ((r = sys_page_map(0, va, 0, va, perm)) < 0) {
  800de8:	83 ec 0c             	sub    $0xc,%esp
  800deb:	56                   	push   %esi
  800dec:	53                   	push   %ebx
  800ded:	6a 00                	push   $0x0
  800def:	53                   	push   %ebx
  800df0:	6a 00                	push   $0x0
  800df2:	e8 fa fd ff ff       	call   800bf1 <sys_page_map>
  800df7:	83 c4 20             	add    $0x20,%esp
  800dfa:	85 c0                	test   %eax,%eax
  800dfc:	79 12                	jns    800e10 <duppage+0x71>
		panic("sys_page_alloc: %e", r);
  800dfe:	50                   	push   %eax
  800dff:	68 ea 24 80 00       	push   $0x8024ea
  800e04:	6a 5c                	push   $0x5c
  800e06:	68 fd 24 80 00       	push   $0x8024fd
  800e0b:	e8 3d f3 ff ff       	call   80014d <_panic>
		return r;
	}

	return 0;
}
  800e10:	b8 00 00 00 00       	mov    $0x0,%eax
  800e15:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e18:	5b                   	pop    %ebx
  800e19:	5e                   	pop    %esi
  800e1a:	5d                   	pop    %ebp
  800e1b:	c3                   	ret    

00800e1c <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e1c:	55                   	push   %ebp
  800e1d:	89 e5                	mov    %esp,%ebp
  800e1f:	53                   	push   %ebx
  800e20:	83 ec 04             	sub    $0x4,%esp
  800e23:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e26:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	unsigned pn = ((uint32_t)addr)/PGSIZE;
  800e28:	89 da                	mov    %ebx,%edx
  800e2a:	c1 ea 0c             	shr    $0xc,%edx
	pte_t pte = uvpt[pn];
  800e2d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(err & FEC_WR) || !(pte & PTE_COW)) {
  800e34:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e38:	74 05                	je     800e3f <pgfault+0x23>
  800e3a:	f6 c6 08             	test   $0x8,%dh
  800e3d:	75 14                	jne    800e53 <pgfault+0x37>
		panic("fork pgfault handler: does not handle this fault");
  800e3f:	83 ec 04             	sub    $0x4,%esp
  800e42:	68 6c 25 80 00       	push   $0x80256c
  800e47:	6a 1f                	push   $0x1f
  800e49:	68 fd 24 80 00       	push   $0x8024fd
  800e4e:	e8 fa f2 ff ff       	call   80014d <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// Allocate a new page, mapped at temp location
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  800e53:	83 ec 04             	sub    $0x4,%esp
  800e56:	6a 07                	push   $0x7
  800e58:	68 00 f0 7f 00       	push   $0x7ff000
  800e5d:	6a 00                	push   $0x0
  800e5f:	e8 4a fd ff ff       	call   800bae <sys_page_alloc>
  800e64:	83 c4 10             	add    $0x10,%esp
  800e67:	85 c0                	test   %eax,%eax
  800e69:	79 12                	jns    800e7d <pgfault+0x61>
		panic("sys_page_alloc: %e", r);
  800e6b:	50                   	push   %eax
  800e6c:	68 ea 24 80 00       	push   $0x8024ea
  800e71:	6a 2b                	push   $0x2b
  800e73:	68 fd 24 80 00       	push   $0x8024fd
  800e78:	e8 d0 f2 ff ff       	call   80014d <_panic>

	// Copy the data from the old page to this new page
	void *addr_pgstart = (void *) ROUNDDOWN(addr, PGSIZE);
  800e7d:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr_pgstart, PGSIZE);
  800e83:	83 ec 04             	sub    $0x4,%esp
  800e86:	68 00 10 00 00       	push   $0x1000
  800e8b:	53                   	push   %ebx
  800e8c:	68 00 f0 7f 00       	push   $0x7ff000
  800e91:	e8 a7 fa ff ff       	call   80093d <memmove>

	// Move the new page to the old page's address
	if ((r = sys_page_map(0, PFTEMP, 0, addr_pgstart, PTE_P|PTE_U|PTE_W)) < 0)
  800e96:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e9d:	53                   	push   %ebx
  800e9e:	6a 00                	push   $0x0
  800ea0:	68 00 f0 7f 00       	push   $0x7ff000
  800ea5:	6a 00                	push   $0x0
  800ea7:	e8 45 fd ff ff       	call   800bf1 <sys_page_map>
  800eac:	83 c4 20             	add    $0x20,%esp
  800eaf:	85 c0                	test   %eax,%eax
  800eb1:	79 12                	jns    800ec5 <pgfault+0xa9>
		panic("sys_page_map: %e", r);
  800eb3:	50                   	push   %eax
  800eb4:	68 08 25 80 00       	push   $0x802508
  800eb9:	6a 33                	push   $0x33
  800ebb:	68 fd 24 80 00       	push   $0x8024fd
  800ec0:	e8 88 f2 ff ff       	call   80014d <_panic>

	// Unmap the temp location
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800ec5:	83 ec 08             	sub    $0x8,%esp
  800ec8:	68 00 f0 7f 00       	push   $0x7ff000
  800ecd:	6a 00                	push   $0x0
  800ecf:	e8 5f fd ff ff       	call   800c33 <sys_page_unmap>
  800ed4:	83 c4 10             	add    $0x10,%esp
  800ed7:	85 c0                	test   %eax,%eax
  800ed9:	79 12                	jns    800eed <pgfault+0xd1>
		panic("sys_page_unmap: %e", r);
  800edb:	50                   	push   %eax
  800edc:	68 19 25 80 00       	push   $0x802519
  800ee1:	6a 37                	push   $0x37
  800ee3:	68 fd 24 80 00       	push   $0x8024fd
  800ee8:	e8 60 f2 ff ff       	call   80014d <_panic>
}
  800eed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ef0:	c9                   	leave  
  800ef1:	c3                   	ret    

00800ef2 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ef2:	55                   	push   %ebp
  800ef3:	89 e5                	mov    %esp,%ebp
  800ef5:	56                   	push   %esi
  800ef6:	53                   	push   %ebx
  800ef7:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
	// Set up page fault handler
	set_pgfault_handler(&pgfault);
  800efa:	68 1c 0e 80 00       	push   $0x800e1c
  800eff:	e8 f6 0d 00 00       	call   801cfa <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f04:	b8 07 00 00 00       	mov    $0x7,%eax
  800f09:	cd 30                	int    $0x30

	// Create child
	envid_t envid = sys_exofork();
  800f0b:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (envid < 0) {
  800f0e:	83 c4 10             	add    $0x10,%esp
  800f11:	85 c0                	test   %eax,%eax
  800f13:	79 12                	jns    800f27 <fork+0x35>
		panic("sys_exofork: %e", envid);
  800f15:	50                   	push   %eax
  800f16:	68 2c 25 80 00       	push   $0x80252c
  800f1b:	6a 7d                	push   $0x7d
  800f1d:	68 fd 24 80 00       	push   $0x8024fd
  800f22:	e8 26 f2 ff ff       	call   80014d <_panic>
		return envid;
	}
	if (envid == 0) {
  800f27:	85 c0                	test   %eax,%eax
  800f29:	75 1e                	jne    800f49 <fork+0x57>
		// We are the child.
		thisenv = &envs[ENVX(sys_getenvid())]; // Fix thisenv
  800f2b:	e8 40 fc ff ff       	call   800b70 <sys_getenvid>
  800f30:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f35:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f38:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f3d:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  800f42:	b8 00 00 00 00       	mov    $0x0,%eax
  800f47:	eb 7d                	jmp    800fc6 <fork+0xd4>

	// Set page fault handler on the child.
	// The parent needs to do it, else the child wouldn't be able to handle
	// the fault when trying to access it's stack (which happens as soon it starts)
	extern void _pgfault_upcall(void);
	sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);
  800f49:	83 ec 04             	sub    $0x4,%esp
  800f4c:	6a 07                	push   $0x7
  800f4e:	68 00 f0 bf ee       	push   $0xeebff000
  800f53:	50                   	push   %eax
  800f54:	e8 55 fc ff ff       	call   800bae <sys_page_alloc>
	sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  800f59:	83 c4 08             	add    $0x8,%esp
  800f5c:	68 3f 1d 80 00       	push   $0x801d3f
  800f61:	ff 75 f4             	pushl  -0xc(%ebp)
  800f64:	e8 90 fd ff ff       	call   800cf9 <sys_env_set_pgfault_upcall>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  800f69:	be 04 60 80 00       	mov    $0x806004,%esi
  800f6e:	c1 ee 0c             	shr    $0xc,%esi
  800f71:	83 c4 10             	add    $0x10,%esp
  800f74:	bb 00 08 00 00       	mov    $0x800,%ebx
  800f79:	eb 0d                	jmp    800f88 <fork+0x96>
		duppage(envid, pn);
  800f7b:	89 da                	mov    %ebx,%edx
  800f7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f80:	e8 1a fe ff ff       	call   800d9f <duppage>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  800f85:	83 c3 01             	add    $0x1,%ebx
  800f88:	39 f3                	cmp    %esi,%ebx
  800f8a:	76 ef                	jbe    800f7b <fork+0x89>
	}

	// Also copy the stack we are currently running on
	// I think it should loop from ustacktop to this page, since the stack
	// can have more than 1 page
	duppage(envid, ((uint32_t) &envid)/PGSIZE);
  800f8c:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800f8f:	c1 ea 0c             	shr    $0xc,%edx
  800f92:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f95:	e8 05 fe ff ff       	call   800d9f <duppage>

	// Start the child environmnet running
	int r;
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  800f9a:	83 ec 08             	sub    $0x8,%esp
  800f9d:	6a 02                	push   $0x2
  800f9f:	ff 75 f4             	pushl  -0xc(%ebp)
  800fa2:	e8 ce fc ff ff       	call   800c75 <sys_env_set_status>
  800fa7:	83 c4 10             	add    $0x10,%esp
  800faa:	85 c0                	test   %eax,%eax
  800fac:	79 15                	jns    800fc3 <fork+0xd1>
		panic("sys_env_set_status: %e", r);
  800fae:	50                   	push   %eax
  800faf:	68 3c 25 80 00       	push   $0x80253c
  800fb4:	68 9d 00 00 00       	push   $0x9d
  800fb9:	68 fd 24 80 00       	push   $0x8024fd
  800fbe:	e8 8a f1 ff ff       	call   80014d <_panic>
		return r;
	}

	return envid;
  800fc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800fc6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fc9:	5b                   	pop    %ebx
  800fca:	5e                   	pop    %esi
  800fcb:	5d                   	pop    %ebp
  800fcc:	c3                   	ret    

00800fcd <sfork>:

// Challenge!
int
sfork(void)
{
  800fcd:	55                   	push   %ebp
  800fce:	89 e5                	mov    %esp,%ebp
  800fd0:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800fd3:	68 53 25 80 00       	push   $0x802553
  800fd8:	68 a8 00 00 00       	push   $0xa8
  800fdd:	68 fd 24 80 00       	push   $0x8024fd
  800fe2:	e8 66 f1 ff ff       	call   80014d <_panic>

00800fe7 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800fe7:	55                   	push   %ebp
  800fe8:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800fea:	8b 45 08             	mov    0x8(%ebp),%eax
  800fed:	05 00 00 00 30       	add    $0x30000000,%eax
  800ff2:	c1 e8 0c             	shr    $0xc,%eax
}
  800ff5:	5d                   	pop    %ebp
  800ff6:	c3                   	ret    

00800ff7 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800ff7:	55                   	push   %ebp
  800ff8:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800ffa:	8b 45 08             	mov    0x8(%ebp),%eax
  800ffd:	05 00 00 00 30       	add    $0x30000000,%eax
  801002:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801007:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80100c:	5d                   	pop    %ebp
  80100d:	c3                   	ret    

0080100e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80100e:	55                   	push   %ebp
  80100f:	89 e5                	mov    %esp,%ebp
  801011:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801014:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801019:	89 c2                	mov    %eax,%edx
  80101b:	c1 ea 16             	shr    $0x16,%edx
  80101e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801025:	f6 c2 01             	test   $0x1,%dl
  801028:	74 11                	je     80103b <fd_alloc+0x2d>
  80102a:	89 c2                	mov    %eax,%edx
  80102c:	c1 ea 0c             	shr    $0xc,%edx
  80102f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801036:	f6 c2 01             	test   $0x1,%dl
  801039:	75 09                	jne    801044 <fd_alloc+0x36>
			*fd_store = fd;
  80103b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80103d:	b8 00 00 00 00       	mov    $0x0,%eax
  801042:	eb 17                	jmp    80105b <fd_alloc+0x4d>
  801044:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801049:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80104e:	75 c9                	jne    801019 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801050:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801056:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80105b:	5d                   	pop    %ebp
  80105c:	c3                   	ret    

0080105d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80105d:	55                   	push   %ebp
  80105e:	89 e5                	mov    %esp,%ebp
  801060:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801063:	83 f8 1f             	cmp    $0x1f,%eax
  801066:	77 36                	ja     80109e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801068:	c1 e0 0c             	shl    $0xc,%eax
  80106b:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801070:	89 c2                	mov    %eax,%edx
  801072:	c1 ea 16             	shr    $0x16,%edx
  801075:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80107c:	f6 c2 01             	test   $0x1,%dl
  80107f:	74 24                	je     8010a5 <fd_lookup+0x48>
  801081:	89 c2                	mov    %eax,%edx
  801083:	c1 ea 0c             	shr    $0xc,%edx
  801086:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80108d:	f6 c2 01             	test   $0x1,%dl
  801090:	74 1a                	je     8010ac <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801092:	8b 55 0c             	mov    0xc(%ebp),%edx
  801095:	89 02                	mov    %eax,(%edx)
	return 0;
  801097:	b8 00 00 00 00       	mov    $0x0,%eax
  80109c:	eb 13                	jmp    8010b1 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80109e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010a3:	eb 0c                	jmp    8010b1 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010a5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010aa:	eb 05                	jmp    8010b1 <fd_lookup+0x54>
  8010ac:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8010b1:	5d                   	pop    %ebp
  8010b2:	c3                   	ret    

008010b3 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8010b3:	55                   	push   %ebp
  8010b4:	89 e5                	mov    %esp,%ebp
  8010b6:	83 ec 08             	sub    $0x8,%esp
  8010b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010bc:	ba 20 26 80 00       	mov    $0x802620,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8010c1:	eb 13                	jmp    8010d6 <dev_lookup+0x23>
  8010c3:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8010c6:	39 08                	cmp    %ecx,(%eax)
  8010c8:	75 0c                	jne    8010d6 <dev_lookup+0x23>
			*dev = devtab[i];
  8010ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010cd:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8010d4:	eb 2e                	jmp    801104 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8010d6:	8b 02                	mov    (%edx),%eax
  8010d8:	85 c0                	test   %eax,%eax
  8010da:	75 e7                	jne    8010c3 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8010dc:	a1 08 40 80 00       	mov    0x804008,%eax
  8010e1:	8b 40 48             	mov    0x48(%eax),%eax
  8010e4:	83 ec 04             	sub    $0x4,%esp
  8010e7:	51                   	push   %ecx
  8010e8:	50                   	push   %eax
  8010e9:	68 a0 25 80 00       	push   $0x8025a0
  8010ee:	e8 33 f1 ff ff       	call   800226 <cprintf>
	*dev = 0;
  8010f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010f6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8010fc:	83 c4 10             	add    $0x10,%esp
  8010ff:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801104:	c9                   	leave  
  801105:	c3                   	ret    

00801106 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801106:	55                   	push   %ebp
  801107:	89 e5                	mov    %esp,%ebp
  801109:	56                   	push   %esi
  80110a:	53                   	push   %ebx
  80110b:	83 ec 10             	sub    $0x10,%esp
  80110e:	8b 75 08             	mov    0x8(%ebp),%esi
  801111:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801114:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801117:	50                   	push   %eax
  801118:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80111e:	c1 e8 0c             	shr    $0xc,%eax
  801121:	50                   	push   %eax
  801122:	e8 36 ff ff ff       	call   80105d <fd_lookup>
  801127:	83 c4 08             	add    $0x8,%esp
  80112a:	85 c0                	test   %eax,%eax
  80112c:	78 05                	js     801133 <fd_close+0x2d>
	    || fd != fd2)
  80112e:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801131:	74 0c                	je     80113f <fd_close+0x39>
		return (must_exist ? r : 0);
  801133:	84 db                	test   %bl,%bl
  801135:	ba 00 00 00 00       	mov    $0x0,%edx
  80113a:	0f 44 c2             	cmove  %edx,%eax
  80113d:	eb 41                	jmp    801180 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80113f:	83 ec 08             	sub    $0x8,%esp
  801142:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801145:	50                   	push   %eax
  801146:	ff 36                	pushl  (%esi)
  801148:	e8 66 ff ff ff       	call   8010b3 <dev_lookup>
  80114d:	89 c3                	mov    %eax,%ebx
  80114f:	83 c4 10             	add    $0x10,%esp
  801152:	85 c0                	test   %eax,%eax
  801154:	78 1a                	js     801170 <fd_close+0x6a>
		if (dev->dev_close)
  801156:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801159:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80115c:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801161:	85 c0                	test   %eax,%eax
  801163:	74 0b                	je     801170 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801165:	83 ec 0c             	sub    $0xc,%esp
  801168:	56                   	push   %esi
  801169:	ff d0                	call   *%eax
  80116b:	89 c3                	mov    %eax,%ebx
  80116d:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801170:	83 ec 08             	sub    $0x8,%esp
  801173:	56                   	push   %esi
  801174:	6a 00                	push   $0x0
  801176:	e8 b8 fa ff ff       	call   800c33 <sys_page_unmap>
	return r;
  80117b:	83 c4 10             	add    $0x10,%esp
  80117e:	89 d8                	mov    %ebx,%eax
}
  801180:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801183:	5b                   	pop    %ebx
  801184:	5e                   	pop    %esi
  801185:	5d                   	pop    %ebp
  801186:	c3                   	ret    

00801187 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801187:	55                   	push   %ebp
  801188:	89 e5                	mov    %esp,%ebp
  80118a:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80118d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801190:	50                   	push   %eax
  801191:	ff 75 08             	pushl  0x8(%ebp)
  801194:	e8 c4 fe ff ff       	call   80105d <fd_lookup>
  801199:	83 c4 08             	add    $0x8,%esp
  80119c:	85 c0                	test   %eax,%eax
  80119e:	78 10                	js     8011b0 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8011a0:	83 ec 08             	sub    $0x8,%esp
  8011a3:	6a 01                	push   $0x1
  8011a5:	ff 75 f4             	pushl  -0xc(%ebp)
  8011a8:	e8 59 ff ff ff       	call   801106 <fd_close>
  8011ad:	83 c4 10             	add    $0x10,%esp
}
  8011b0:	c9                   	leave  
  8011b1:	c3                   	ret    

008011b2 <close_all>:

void
close_all(void)
{
  8011b2:	55                   	push   %ebp
  8011b3:	89 e5                	mov    %esp,%ebp
  8011b5:	53                   	push   %ebx
  8011b6:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8011b9:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8011be:	83 ec 0c             	sub    $0xc,%esp
  8011c1:	53                   	push   %ebx
  8011c2:	e8 c0 ff ff ff       	call   801187 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8011c7:	83 c3 01             	add    $0x1,%ebx
  8011ca:	83 c4 10             	add    $0x10,%esp
  8011cd:	83 fb 20             	cmp    $0x20,%ebx
  8011d0:	75 ec                	jne    8011be <close_all+0xc>
		close(i);
}
  8011d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011d5:	c9                   	leave  
  8011d6:	c3                   	ret    

008011d7 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8011d7:	55                   	push   %ebp
  8011d8:	89 e5                	mov    %esp,%ebp
  8011da:	57                   	push   %edi
  8011db:	56                   	push   %esi
  8011dc:	53                   	push   %ebx
  8011dd:	83 ec 2c             	sub    $0x2c,%esp
  8011e0:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8011e3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8011e6:	50                   	push   %eax
  8011e7:	ff 75 08             	pushl  0x8(%ebp)
  8011ea:	e8 6e fe ff ff       	call   80105d <fd_lookup>
  8011ef:	83 c4 08             	add    $0x8,%esp
  8011f2:	85 c0                	test   %eax,%eax
  8011f4:	0f 88 c1 00 00 00    	js     8012bb <dup+0xe4>
		return r;
	close(newfdnum);
  8011fa:	83 ec 0c             	sub    $0xc,%esp
  8011fd:	56                   	push   %esi
  8011fe:	e8 84 ff ff ff       	call   801187 <close>

	newfd = INDEX2FD(newfdnum);
  801203:	89 f3                	mov    %esi,%ebx
  801205:	c1 e3 0c             	shl    $0xc,%ebx
  801208:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80120e:	83 c4 04             	add    $0x4,%esp
  801211:	ff 75 e4             	pushl  -0x1c(%ebp)
  801214:	e8 de fd ff ff       	call   800ff7 <fd2data>
  801219:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80121b:	89 1c 24             	mov    %ebx,(%esp)
  80121e:	e8 d4 fd ff ff       	call   800ff7 <fd2data>
  801223:	83 c4 10             	add    $0x10,%esp
  801226:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801229:	89 f8                	mov    %edi,%eax
  80122b:	c1 e8 16             	shr    $0x16,%eax
  80122e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801235:	a8 01                	test   $0x1,%al
  801237:	74 37                	je     801270 <dup+0x99>
  801239:	89 f8                	mov    %edi,%eax
  80123b:	c1 e8 0c             	shr    $0xc,%eax
  80123e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801245:	f6 c2 01             	test   $0x1,%dl
  801248:	74 26                	je     801270 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80124a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801251:	83 ec 0c             	sub    $0xc,%esp
  801254:	25 07 0e 00 00       	and    $0xe07,%eax
  801259:	50                   	push   %eax
  80125a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80125d:	6a 00                	push   $0x0
  80125f:	57                   	push   %edi
  801260:	6a 00                	push   $0x0
  801262:	e8 8a f9 ff ff       	call   800bf1 <sys_page_map>
  801267:	89 c7                	mov    %eax,%edi
  801269:	83 c4 20             	add    $0x20,%esp
  80126c:	85 c0                	test   %eax,%eax
  80126e:	78 2e                	js     80129e <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801270:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801273:	89 d0                	mov    %edx,%eax
  801275:	c1 e8 0c             	shr    $0xc,%eax
  801278:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80127f:	83 ec 0c             	sub    $0xc,%esp
  801282:	25 07 0e 00 00       	and    $0xe07,%eax
  801287:	50                   	push   %eax
  801288:	53                   	push   %ebx
  801289:	6a 00                	push   $0x0
  80128b:	52                   	push   %edx
  80128c:	6a 00                	push   $0x0
  80128e:	e8 5e f9 ff ff       	call   800bf1 <sys_page_map>
  801293:	89 c7                	mov    %eax,%edi
  801295:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801298:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80129a:	85 ff                	test   %edi,%edi
  80129c:	79 1d                	jns    8012bb <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80129e:	83 ec 08             	sub    $0x8,%esp
  8012a1:	53                   	push   %ebx
  8012a2:	6a 00                	push   $0x0
  8012a4:	e8 8a f9 ff ff       	call   800c33 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8012a9:	83 c4 08             	add    $0x8,%esp
  8012ac:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012af:	6a 00                	push   $0x0
  8012b1:	e8 7d f9 ff ff       	call   800c33 <sys_page_unmap>
	return r;
  8012b6:	83 c4 10             	add    $0x10,%esp
  8012b9:	89 f8                	mov    %edi,%eax
}
  8012bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012be:	5b                   	pop    %ebx
  8012bf:	5e                   	pop    %esi
  8012c0:	5f                   	pop    %edi
  8012c1:	5d                   	pop    %ebp
  8012c2:	c3                   	ret    

008012c3 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8012c3:	55                   	push   %ebp
  8012c4:	89 e5                	mov    %esp,%ebp
  8012c6:	53                   	push   %ebx
  8012c7:	83 ec 14             	sub    $0x14,%esp
  8012ca:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012cd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012d0:	50                   	push   %eax
  8012d1:	53                   	push   %ebx
  8012d2:	e8 86 fd ff ff       	call   80105d <fd_lookup>
  8012d7:	83 c4 08             	add    $0x8,%esp
  8012da:	89 c2                	mov    %eax,%edx
  8012dc:	85 c0                	test   %eax,%eax
  8012de:	78 6d                	js     80134d <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012e0:	83 ec 08             	sub    $0x8,%esp
  8012e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012e6:	50                   	push   %eax
  8012e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ea:	ff 30                	pushl  (%eax)
  8012ec:	e8 c2 fd ff ff       	call   8010b3 <dev_lookup>
  8012f1:	83 c4 10             	add    $0x10,%esp
  8012f4:	85 c0                	test   %eax,%eax
  8012f6:	78 4c                	js     801344 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8012f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8012fb:	8b 42 08             	mov    0x8(%edx),%eax
  8012fe:	83 e0 03             	and    $0x3,%eax
  801301:	83 f8 01             	cmp    $0x1,%eax
  801304:	75 21                	jne    801327 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801306:	a1 08 40 80 00       	mov    0x804008,%eax
  80130b:	8b 40 48             	mov    0x48(%eax),%eax
  80130e:	83 ec 04             	sub    $0x4,%esp
  801311:	53                   	push   %ebx
  801312:	50                   	push   %eax
  801313:	68 e4 25 80 00       	push   $0x8025e4
  801318:	e8 09 ef ff ff       	call   800226 <cprintf>
		return -E_INVAL;
  80131d:	83 c4 10             	add    $0x10,%esp
  801320:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801325:	eb 26                	jmp    80134d <read+0x8a>
	}
	if (!dev->dev_read)
  801327:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80132a:	8b 40 08             	mov    0x8(%eax),%eax
  80132d:	85 c0                	test   %eax,%eax
  80132f:	74 17                	je     801348 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801331:	83 ec 04             	sub    $0x4,%esp
  801334:	ff 75 10             	pushl  0x10(%ebp)
  801337:	ff 75 0c             	pushl  0xc(%ebp)
  80133a:	52                   	push   %edx
  80133b:	ff d0                	call   *%eax
  80133d:	89 c2                	mov    %eax,%edx
  80133f:	83 c4 10             	add    $0x10,%esp
  801342:	eb 09                	jmp    80134d <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801344:	89 c2                	mov    %eax,%edx
  801346:	eb 05                	jmp    80134d <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801348:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80134d:	89 d0                	mov    %edx,%eax
  80134f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801352:	c9                   	leave  
  801353:	c3                   	ret    

00801354 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801354:	55                   	push   %ebp
  801355:	89 e5                	mov    %esp,%ebp
  801357:	57                   	push   %edi
  801358:	56                   	push   %esi
  801359:	53                   	push   %ebx
  80135a:	83 ec 0c             	sub    $0xc,%esp
  80135d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801360:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801363:	bb 00 00 00 00       	mov    $0x0,%ebx
  801368:	eb 21                	jmp    80138b <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80136a:	83 ec 04             	sub    $0x4,%esp
  80136d:	89 f0                	mov    %esi,%eax
  80136f:	29 d8                	sub    %ebx,%eax
  801371:	50                   	push   %eax
  801372:	89 d8                	mov    %ebx,%eax
  801374:	03 45 0c             	add    0xc(%ebp),%eax
  801377:	50                   	push   %eax
  801378:	57                   	push   %edi
  801379:	e8 45 ff ff ff       	call   8012c3 <read>
		if (m < 0)
  80137e:	83 c4 10             	add    $0x10,%esp
  801381:	85 c0                	test   %eax,%eax
  801383:	78 10                	js     801395 <readn+0x41>
			return m;
		if (m == 0)
  801385:	85 c0                	test   %eax,%eax
  801387:	74 0a                	je     801393 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801389:	01 c3                	add    %eax,%ebx
  80138b:	39 f3                	cmp    %esi,%ebx
  80138d:	72 db                	jb     80136a <readn+0x16>
  80138f:	89 d8                	mov    %ebx,%eax
  801391:	eb 02                	jmp    801395 <readn+0x41>
  801393:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801395:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801398:	5b                   	pop    %ebx
  801399:	5e                   	pop    %esi
  80139a:	5f                   	pop    %edi
  80139b:	5d                   	pop    %ebp
  80139c:	c3                   	ret    

0080139d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80139d:	55                   	push   %ebp
  80139e:	89 e5                	mov    %esp,%ebp
  8013a0:	53                   	push   %ebx
  8013a1:	83 ec 14             	sub    $0x14,%esp
  8013a4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013a7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013aa:	50                   	push   %eax
  8013ab:	53                   	push   %ebx
  8013ac:	e8 ac fc ff ff       	call   80105d <fd_lookup>
  8013b1:	83 c4 08             	add    $0x8,%esp
  8013b4:	89 c2                	mov    %eax,%edx
  8013b6:	85 c0                	test   %eax,%eax
  8013b8:	78 68                	js     801422 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013ba:	83 ec 08             	sub    $0x8,%esp
  8013bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013c0:	50                   	push   %eax
  8013c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013c4:	ff 30                	pushl  (%eax)
  8013c6:	e8 e8 fc ff ff       	call   8010b3 <dev_lookup>
  8013cb:	83 c4 10             	add    $0x10,%esp
  8013ce:	85 c0                	test   %eax,%eax
  8013d0:	78 47                	js     801419 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013d5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013d9:	75 21                	jne    8013fc <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8013db:	a1 08 40 80 00       	mov    0x804008,%eax
  8013e0:	8b 40 48             	mov    0x48(%eax),%eax
  8013e3:	83 ec 04             	sub    $0x4,%esp
  8013e6:	53                   	push   %ebx
  8013e7:	50                   	push   %eax
  8013e8:	68 00 26 80 00       	push   $0x802600
  8013ed:	e8 34 ee ff ff       	call   800226 <cprintf>
		return -E_INVAL;
  8013f2:	83 c4 10             	add    $0x10,%esp
  8013f5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013fa:	eb 26                	jmp    801422 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8013fc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013ff:	8b 52 0c             	mov    0xc(%edx),%edx
  801402:	85 d2                	test   %edx,%edx
  801404:	74 17                	je     80141d <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801406:	83 ec 04             	sub    $0x4,%esp
  801409:	ff 75 10             	pushl  0x10(%ebp)
  80140c:	ff 75 0c             	pushl  0xc(%ebp)
  80140f:	50                   	push   %eax
  801410:	ff d2                	call   *%edx
  801412:	89 c2                	mov    %eax,%edx
  801414:	83 c4 10             	add    $0x10,%esp
  801417:	eb 09                	jmp    801422 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801419:	89 c2                	mov    %eax,%edx
  80141b:	eb 05                	jmp    801422 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80141d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801422:	89 d0                	mov    %edx,%eax
  801424:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801427:	c9                   	leave  
  801428:	c3                   	ret    

00801429 <seek>:

int
seek(int fdnum, off_t offset)
{
  801429:	55                   	push   %ebp
  80142a:	89 e5                	mov    %esp,%ebp
  80142c:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80142f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801432:	50                   	push   %eax
  801433:	ff 75 08             	pushl  0x8(%ebp)
  801436:	e8 22 fc ff ff       	call   80105d <fd_lookup>
  80143b:	83 c4 08             	add    $0x8,%esp
  80143e:	85 c0                	test   %eax,%eax
  801440:	78 0e                	js     801450 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801442:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801445:	8b 55 0c             	mov    0xc(%ebp),%edx
  801448:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80144b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801450:	c9                   	leave  
  801451:	c3                   	ret    

00801452 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801452:	55                   	push   %ebp
  801453:	89 e5                	mov    %esp,%ebp
  801455:	53                   	push   %ebx
  801456:	83 ec 14             	sub    $0x14,%esp
  801459:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80145c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80145f:	50                   	push   %eax
  801460:	53                   	push   %ebx
  801461:	e8 f7 fb ff ff       	call   80105d <fd_lookup>
  801466:	83 c4 08             	add    $0x8,%esp
  801469:	89 c2                	mov    %eax,%edx
  80146b:	85 c0                	test   %eax,%eax
  80146d:	78 65                	js     8014d4 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80146f:	83 ec 08             	sub    $0x8,%esp
  801472:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801475:	50                   	push   %eax
  801476:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801479:	ff 30                	pushl  (%eax)
  80147b:	e8 33 fc ff ff       	call   8010b3 <dev_lookup>
  801480:	83 c4 10             	add    $0x10,%esp
  801483:	85 c0                	test   %eax,%eax
  801485:	78 44                	js     8014cb <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801487:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80148a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80148e:	75 21                	jne    8014b1 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801490:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801495:	8b 40 48             	mov    0x48(%eax),%eax
  801498:	83 ec 04             	sub    $0x4,%esp
  80149b:	53                   	push   %ebx
  80149c:	50                   	push   %eax
  80149d:	68 c0 25 80 00       	push   $0x8025c0
  8014a2:	e8 7f ed ff ff       	call   800226 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8014a7:	83 c4 10             	add    $0x10,%esp
  8014aa:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014af:	eb 23                	jmp    8014d4 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8014b1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014b4:	8b 52 18             	mov    0x18(%edx),%edx
  8014b7:	85 d2                	test   %edx,%edx
  8014b9:	74 14                	je     8014cf <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8014bb:	83 ec 08             	sub    $0x8,%esp
  8014be:	ff 75 0c             	pushl  0xc(%ebp)
  8014c1:	50                   	push   %eax
  8014c2:	ff d2                	call   *%edx
  8014c4:	89 c2                	mov    %eax,%edx
  8014c6:	83 c4 10             	add    $0x10,%esp
  8014c9:	eb 09                	jmp    8014d4 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014cb:	89 c2                	mov    %eax,%edx
  8014cd:	eb 05                	jmp    8014d4 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8014cf:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8014d4:	89 d0                	mov    %edx,%eax
  8014d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014d9:	c9                   	leave  
  8014da:	c3                   	ret    

008014db <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8014db:	55                   	push   %ebp
  8014dc:	89 e5                	mov    %esp,%ebp
  8014de:	53                   	push   %ebx
  8014df:	83 ec 14             	sub    $0x14,%esp
  8014e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014e5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014e8:	50                   	push   %eax
  8014e9:	ff 75 08             	pushl  0x8(%ebp)
  8014ec:	e8 6c fb ff ff       	call   80105d <fd_lookup>
  8014f1:	83 c4 08             	add    $0x8,%esp
  8014f4:	89 c2                	mov    %eax,%edx
  8014f6:	85 c0                	test   %eax,%eax
  8014f8:	78 58                	js     801552 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014fa:	83 ec 08             	sub    $0x8,%esp
  8014fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801500:	50                   	push   %eax
  801501:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801504:	ff 30                	pushl  (%eax)
  801506:	e8 a8 fb ff ff       	call   8010b3 <dev_lookup>
  80150b:	83 c4 10             	add    $0x10,%esp
  80150e:	85 c0                	test   %eax,%eax
  801510:	78 37                	js     801549 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801512:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801515:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801519:	74 32                	je     80154d <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80151b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80151e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801525:	00 00 00 
	stat->st_isdir = 0;
  801528:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80152f:	00 00 00 
	stat->st_dev = dev;
  801532:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801538:	83 ec 08             	sub    $0x8,%esp
  80153b:	53                   	push   %ebx
  80153c:	ff 75 f0             	pushl  -0x10(%ebp)
  80153f:	ff 50 14             	call   *0x14(%eax)
  801542:	89 c2                	mov    %eax,%edx
  801544:	83 c4 10             	add    $0x10,%esp
  801547:	eb 09                	jmp    801552 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801549:	89 c2                	mov    %eax,%edx
  80154b:	eb 05                	jmp    801552 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80154d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801552:	89 d0                	mov    %edx,%eax
  801554:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801557:	c9                   	leave  
  801558:	c3                   	ret    

00801559 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801559:	55                   	push   %ebp
  80155a:	89 e5                	mov    %esp,%ebp
  80155c:	56                   	push   %esi
  80155d:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80155e:	83 ec 08             	sub    $0x8,%esp
  801561:	6a 00                	push   $0x0
  801563:	ff 75 08             	pushl  0x8(%ebp)
  801566:	e8 0c 02 00 00       	call   801777 <open>
  80156b:	89 c3                	mov    %eax,%ebx
  80156d:	83 c4 10             	add    $0x10,%esp
  801570:	85 c0                	test   %eax,%eax
  801572:	78 1b                	js     80158f <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801574:	83 ec 08             	sub    $0x8,%esp
  801577:	ff 75 0c             	pushl  0xc(%ebp)
  80157a:	50                   	push   %eax
  80157b:	e8 5b ff ff ff       	call   8014db <fstat>
  801580:	89 c6                	mov    %eax,%esi
	close(fd);
  801582:	89 1c 24             	mov    %ebx,(%esp)
  801585:	e8 fd fb ff ff       	call   801187 <close>
	return r;
  80158a:	83 c4 10             	add    $0x10,%esp
  80158d:	89 f0                	mov    %esi,%eax
}
  80158f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801592:	5b                   	pop    %ebx
  801593:	5e                   	pop    %esi
  801594:	5d                   	pop    %ebp
  801595:	c3                   	ret    

00801596 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801596:	55                   	push   %ebp
  801597:	89 e5                	mov    %esp,%ebp
  801599:	56                   	push   %esi
  80159a:	53                   	push   %ebx
  80159b:	89 c6                	mov    %eax,%esi
  80159d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80159f:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8015a6:	75 12                	jne    8015ba <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8015a8:	83 ec 0c             	sub    $0xc,%esp
  8015ab:	6a 01                	push   $0x1
  8015ad:	e8 7b 08 00 00       	call   801e2d <ipc_find_env>
  8015b2:	a3 00 40 80 00       	mov    %eax,0x804000
  8015b7:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8015ba:	6a 07                	push   $0x7
  8015bc:	68 00 50 80 00       	push   $0x805000
  8015c1:	56                   	push   %esi
  8015c2:	ff 35 00 40 80 00    	pushl  0x804000
  8015c8:	e8 0c 08 00 00       	call   801dd9 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8015cd:	83 c4 0c             	add    $0xc,%esp
  8015d0:	6a 00                	push   $0x0
  8015d2:	53                   	push   %ebx
  8015d3:	6a 00                	push   $0x0
  8015d5:	e8 96 07 00 00       	call   801d70 <ipc_recv>
}
  8015da:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015dd:	5b                   	pop    %ebx
  8015de:	5e                   	pop    %esi
  8015df:	5d                   	pop    %ebp
  8015e0:	c3                   	ret    

008015e1 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8015e1:	55                   	push   %ebp
  8015e2:	89 e5                	mov    %esp,%ebp
  8015e4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8015e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8015ea:	8b 40 0c             	mov    0xc(%eax),%eax
  8015ed:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8015f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015f5:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8015fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8015ff:	b8 02 00 00 00       	mov    $0x2,%eax
  801604:	e8 8d ff ff ff       	call   801596 <fsipc>
}
  801609:	c9                   	leave  
  80160a:	c3                   	ret    

0080160b <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80160b:	55                   	push   %ebp
  80160c:	89 e5                	mov    %esp,%ebp
  80160e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801611:	8b 45 08             	mov    0x8(%ebp),%eax
  801614:	8b 40 0c             	mov    0xc(%eax),%eax
  801617:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80161c:	ba 00 00 00 00       	mov    $0x0,%edx
  801621:	b8 06 00 00 00       	mov    $0x6,%eax
  801626:	e8 6b ff ff ff       	call   801596 <fsipc>
}
  80162b:	c9                   	leave  
  80162c:	c3                   	ret    

0080162d <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80162d:	55                   	push   %ebp
  80162e:	89 e5                	mov    %esp,%ebp
  801630:	53                   	push   %ebx
  801631:	83 ec 04             	sub    $0x4,%esp
  801634:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801637:	8b 45 08             	mov    0x8(%ebp),%eax
  80163a:	8b 40 0c             	mov    0xc(%eax),%eax
  80163d:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801642:	ba 00 00 00 00       	mov    $0x0,%edx
  801647:	b8 05 00 00 00       	mov    $0x5,%eax
  80164c:	e8 45 ff ff ff       	call   801596 <fsipc>
  801651:	85 c0                	test   %eax,%eax
  801653:	78 2c                	js     801681 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801655:	83 ec 08             	sub    $0x8,%esp
  801658:	68 00 50 80 00       	push   $0x805000
  80165d:	53                   	push   %ebx
  80165e:	e8 48 f1 ff ff       	call   8007ab <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801663:	a1 80 50 80 00       	mov    0x805080,%eax
  801668:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80166e:	a1 84 50 80 00       	mov    0x805084,%eax
  801673:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801679:	83 c4 10             	add    $0x10,%esp
  80167c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801681:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801684:	c9                   	leave  
  801685:	c3                   	ret    

00801686 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801686:	55                   	push   %ebp
  801687:	89 e5                	mov    %esp,%ebp
  801689:	53                   	push   %ebx
  80168a:	83 ec 08             	sub    $0x8,%esp
  80168d:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801690:	8b 55 08             	mov    0x8(%ebp),%edx
  801693:	8b 52 0c             	mov    0xc(%edx),%edx
  801696:	89 15 00 50 80 00    	mov    %edx,0x805000
  80169c:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8016a1:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  8016a6:	0f 46 d8             	cmovbe %eax,%ebx
	
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  8016a9:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  8016af:	53                   	push   %ebx
  8016b0:	ff 75 0c             	pushl  0xc(%ebp)
  8016b3:	68 08 50 80 00       	push   $0x805008
  8016b8:	e8 80 f2 ff ff       	call   80093d <memmove>

	
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) 
  8016bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8016c2:	b8 04 00 00 00       	mov    $0x4,%eax
  8016c7:	e8 ca fe ff ff       	call   801596 <fsipc>
  8016cc:	83 c4 10             	add    $0x10,%esp
  8016cf:	85 c0                	test   %eax,%eax
  8016d1:	78 1d                	js     8016f0 <devfile_write+0x6a>
		return r;
	assert(r <= n_real); 
  8016d3:	39 d8                	cmp    %ebx,%eax
  8016d5:	76 19                	jbe    8016f0 <devfile_write+0x6a>
  8016d7:	68 30 26 80 00       	push   $0x802630
  8016dc:	68 3c 26 80 00       	push   $0x80263c
  8016e1:	68 a3 00 00 00       	push   $0xa3
  8016e6:	68 51 26 80 00       	push   $0x802651
  8016eb:	e8 5d ea ff ff       	call   80014d <_panic>
	return r;
}
  8016f0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016f3:	c9                   	leave  
  8016f4:	c3                   	ret    

008016f5 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8016f5:	55                   	push   %ebp
  8016f6:	89 e5                	mov    %esp,%ebp
  8016f8:	56                   	push   %esi
  8016f9:	53                   	push   %ebx
  8016fa:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8016fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801700:	8b 40 0c             	mov    0xc(%eax),%eax
  801703:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801708:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80170e:	ba 00 00 00 00       	mov    $0x0,%edx
  801713:	b8 03 00 00 00       	mov    $0x3,%eax
  801718:	e8 79 fe ff ff       	call   801596 <fsipc>
  80171d:	89 c3                	mov    %eax,%ebx
  80171f:	85 c0                	test   %eax,%eax
  801721:	78 4b                	js     80176e <devfile_read+0x79>
		return r;
	assert(r <= n);
  801723:	39 c6                	cmp    %eax,%esi
  801725:	73 16                	jae    80173d <devfile_read+0x48>
  801727:	68 5c 26 80 00       	push   $0x80265c
  80172c:	68 3c 26 80 00       	push   $0x80263c
  801731:	6a 7c                	push   $0x7c
  801733:	68 51 26 80 00       	push   $0x802651
  801738:	e8 10 ea ff ff       	call   80014d <_panic>
	assert(r <= PGSIZE);
  80173d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801742:	7e 16                	jle    80175a <devfile_read+0x65>
  801744:	68 63 26 80 00       	push   $0x802663
  801749:	68 3c 26 80 00       	push   $0x80263c
  80174e:	6a 7d                	push   $0x7d
  801750:	68 51 26 80 00       	push   $0x802651
  801755:	e8 f3 e9 ff ff       	call   80014d <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80175a:	83 ec 04             	sub    $0x4,%esp
  80175d:	50                   	push   %eax
  80175e:	68 00 50 80 00       	push   $0x805000
  801763:	ff 75 0c             	pushl  0xc(%ebp)
  801766:	e8 d2 f1 ff ff       	call   80093d <memmove>
	return r;
  80176b:	83 c4 10             	add    $0x10,%esp
}
  80176e:	89 d8                	mov    %ebx,%eax
  801770:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801773:	5b                   	pop    %ebx
  801774:	5e                   	pop    %esi
  801775:	5d                   	pop    %ebp
  801776:	c3                   	ret    

00801777 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801777:	55                   	push   %ebp
  801778:	89 e5                	mov    %esp,%ebp
  80177a:	53                   	push   %ebx
  80177b:	83 ec 20             	sub    $0x20,%esp
  80177e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801781:	53                   	push   %ebx
  801782:	e8 eb ef ff ff       	call   800772 <strlen>
  801787:	83 c4 10             	add    $0x10,%esp
  80178a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80178f:	7f 67                	jg     8017f8 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801791:	83 ec 0c             	sub    $0xc,%esp
  801794:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801797:	50                   	push   %eax
  801798:	e8 71 f8 ff ff       	call   80100e <fd_alloc>
  80179d:	83 c4 10             	add    $0x10,%esp
		return r;
  8017a0:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017a2:	85 c0                	test   %eax,%eax
  8017a4:	78 57                	js     8017fd <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8017a6:	83 ec 08             	sub    $0x8,%esp
  8017a9:	53                   	push   %ebx
  8017aa:	68 00 50 80 00       	push   $0x805000
  8017af:	e8 f7 ef ff ff       	call   8007ab <strcpy>
	fsipcbuf.open.req_omode = mode;
  8017b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017b7:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8017bc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017bf:	b8 01 00 00 00       	mov    $0x1,%eax
  8017c4:	e8 cd fd ff ff       	call   801596 <fsipc>
  8017c9:	89 c3                	mov    %eax,%ebx
  8017cb:	83 c4 10             	add    $0x10,%esp
  8017ce:	85 c0                	test   %eax,%eax
  8017d0:	79 14                	jns    8017e6 <open+0x6f>
		fd_close(fd, 0);
  8017d2:	83 ec 08             	sub    $0x8,%esp
  8017d5:	6a 00                	push   $0x0
  8017d7:	ff 75 f4             	pushl  -0xc(%ebp)
  8017da:	e8 27 f9 ff ff       	call   801106 <fd_close>
		return r;
  8017df:	83 c4 10             	add    $0x10,%esp
  8017e2:	89 da                	mov    %ebx,%edx
  8017e4:	eb 17                	jmp    8017fd <open+0x86>
	}

	return fd2num(fd);
  8017e6:	83 ec 0c             	sub    $0xc,%esp
  8017e9:	ff 75 f4             	pushl  -0xc(%ebp)
  8017ec:	e8 f6 f7 ff ff       	call   800fe7 <fd2num>
  8017f1:	89 c2                	mov    %eax,%edx
  8017f3:	83 c4 10             	add    $0x10,%esp
  8017f6:	eb 05                	jmp    8017fd <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8017f8:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8017fd:	89 d0                	mov    %edx,%eax
  8017ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801802:	c9                   	leave  
  801803:	c3                   	ret    

00801804 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801804:	55                   	push   %ebp
  801805:	89 e5                	mov    %esp,%ebp
  801807:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80180a:	ba 00 00 00 00       	mov    $0x0,%edx
  80180f:	b8 08 00 00 00       	mov    $0x8,%eax
  801814:	e8 7d fd ff ff       	call   801596 <fsipc>
}
  801819:	c9                   	leave  
  80181a:	c3                   	ret    

0080181b <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80181b:	55                   	push   %ebp
  80181c:	89 e5                	mov    %esp,%ebp
  80181e:	56                   	push   %esi
  80181f:	53                   	push   %ebx
  801820:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801823:	83 ec 0c             	sub    $0xc,%esp
  801826:	ff 75 08             	pushl  0x8(%ebp)
  801829:	e8 c9 f7 ff ff       	call   800ff7 <fd2data>
  80182e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801830:	83 c4 08             	add    $0x8,%esp
  801833:	68 6f 26 80 00       	push   $0x80266f
  801838:	53                   	push   %ebx
  801839:	e8 6d ef ff ff       	call   8007ab <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80183e:	8b 46 04             	mov    0x4(%esi),%eax
  801841:	2b 06                	sub    (%esi),%eax
  801843:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801849:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801850:	00 00 00 
	stat->st_dev = &devpipe;
  801853:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80185a:	30 80 00 
	return 0;
}
  80185d:	b8 00 00 00 00       	mov    $0x0,%eax
  801862:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801865:	5b                   	pop    %ebx
  801866:	5e                   	pop    %esi
  801867:	5d                   	pop    %ebp
  801868:	c3                   	ret    

00801869 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801869:	55                   	push   %ebp
  80186a:	89 e5                	mov    %esp,%ebp
  80186c:	53                   	push   %ebx
  80186d:	83 ec 0c             	sub    $0xc,%esp
  801870:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801873:	53                   	push   %ebx
  801874:	6a 00                	push   $0x0
  801876:	e8 b8 f3 ff ff       	call   800c33 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80187b:	89 1c 24             	mov    %ebx,(%esp)
  80187e:	e8 74 f7 ff ff       	call   800ff7 <fd2data>
  801883:	83 c4 08             	add    $0x8,%esp
  801886:	50                   	push   %eax
  801887:	6a 00                	push   $0x0
  801889:	e8 a5 f3 ff ff       	call   800c33 <sys_page_unmap>
}
  80188e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801891:	c9                   	leave  
  801892:	c3                   	ret    

00801893 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801893:	55                   	push   %ebp
  801894:	89 e5                	mov    %esp,%ebp
  801896:	57                   	push   %edi
  801897:	56                   	push   %esi
  801898:	53                   	push   %ebx
  801899:	83 ec 1c             	sub    $0x1c,%esp
  80189c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80189f:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8018a1:	a1 08 40 80 00       	mov    0x804008,%eax
  8018a6:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8018a9:	83 ec 0c             	sub    $0xc,%esp
  8018ac:	ff 75 e0             	pushl  -0x20(%ebp)
  8018af:	e8 b2 05 00 00       	call   801e66 <pageref>
  8018b4:	89 c3                	mov    %eax,%ebx
  8018b6:	89 3c 24             	mov    %edi,(%esp)
  8018b9:	e8 a8 05 00 00       	call   801e66 <pageref>
  8018be:	83 c4 10             	add    $0x10,%esp
  8018c1:	39 c3                	cmp    %eax,%ebx
  8018c3:	0f 94 c1             	sete   %cl
  8018c6:	0f b6 c9             	movzbl %cl,%ecx
  8018c9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8018cc:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8018d2:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8018d5:	39 ce                	cmp    %ecx,%esi
  8018d7:	74 1b                	je     8018f4 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8018d9:	39 c3                	cmp    %eax,%ebx
  8018db:	75 c4                	jne    8018a1 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8018dd:	8b 42 58             	mov    0x58(%edx),%eax
  8018e0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8018e3:	50                   	push   %eax
  8018e4:	56                   	push   %esi
  8018e5:	68 76 26 80 00       	push   $0x802676
  8018ea:	e8 37 e9 ff ff       	call   800226 <cprintf>
  8018ef:	83 c4 10             	add    $0x10,%esp
  8018f2:	eb ad                	jmp    8018a1 <_pipeisclosed+0xe>
	}
}
  8018f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018fa:	5b                   	pop    %ebx
  8018fb:	5e                   	pop    %esi
  8018fc:	5f                   	pop    %edi
  8018fd:	5d                   	pop    %ebp
  8018fe:	c3                   	ret    

008018ff <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8018ff:	55                   	push   %ebp
  801900:	89 e5                	mov    %esp,%ebp
  801902:	57                   	push   %edi
  801903:	56                   	push   %esi
  801904:	53                   	push   %ebx
  801905:	83 ec 28             	sub    $0x28,%esp
  801908:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80190b:	56                   	push   %esi
  80190c:	e8 e6 f6 ff ff       	call   800ff7 <fd2data>
  801911:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801913:	83 c4 10             	add    $0x10,%esp
  801916:	bf 00 00 00 00       	mov    $0x0,%edi
  80191b:	eb 4b                	jmp    801968 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80191d:	89 da                	mov    %ebx,%edx
  80191f:	89 f0                	mov    %esi,%eax
  801921:	e8 6d ff ff ff       	call   801893 <_pipeisclosed>
  801926:	85 c0                	test   %eax,%eax
  801928:	75 48                	jne    801972 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80192a:	e8 60 f2 ff ff       	call   800b8f <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80192f:	8b 43 04             	mov    0x4(%ebx),%eax
  801932:	8b 0b                	mov    (%ebx),%ecx
  801934:	8d 51 20             	lea    0x20(%ecx),%edx
  801937:	39 d0                	cmp    %edx,%eax
  801939:	73 e2                	jae    80191d <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80193b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80193e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801942:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801945:	89 c2                	mov    %eax,%edx
  801947:	c1 fa 1f             	sar    $0x1f,%edx
  80194a:	89 d1                	mov    %edx,%ecx
  80194c:	c1 e9 1b             	shr    $0x1b,%ecx
  80194f:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801952:	83 e2 1f             	and    $0x1f,%edx
  801955:	29 ca                	sub    %ecx,%edx
  801957:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80195b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80195f:	83 c0 01             	add    $0x1,%eax
  801962:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801965:	83 c7 01             	add    $0x1,%edi
  801968:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80196b:	75 c2                	jne    80192f <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80196d:	8b 45 10             	mov    0x10(%ebp),%eax
  801970:	eb 05                	jmp    801977 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801972:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801977:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80197a:	5b                   	pop    %ebx
  80197b:	5e                   	pop    %esi
  80197c:	5f                   	pop    %edi
  80197d:	5d                   	pop    %ebp
  80197e:	c3                   	ret    

0080197f <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80197f:	55                   	push   %ebp
  801980:	89 e5                	mov    %esp,%ebp
  801982:	57                   	push   %edi
  801983:	56                   	push   %esi
  801984:	53                   	push   %ebx
  801985:	83 ec 18             	sub    $0x18,%esp
  801988:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80198b:	57                   	push   %edi
  80198c:	e8 66 f6 ff ff       	call   800ff7 <fd2data>
  801991:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801993:	83 c4 10             	add    $0x10,%esp
  801996:	bb 00 00 00 00       	mov    $0x0,%ebx
  80199b:	eb 3d                	jmp    8019da <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80199d:	85 db                	test   %ebx,%ebx
  80199f:	74 04                	je     8019a5 <devpipe_read+0x26>
				return i;
  8019a1:	89 d8                	mov    %ebx,%eax
  8019a3:	eb 44                	jmp    8019e9 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8019a5:	89 f2                	mov    %esi,%edx
  8019a7:	89 f8                	mov    %edi,%eax
  8019a9:	e8 e5 fe ff ff       	call   801893 <_pipeisclosed>
  8019ae:	85 c0                	test   %eax,%eax
  8019b0:	75 32                	jne    8019e4 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8019b2:	e8 d8 f1 ff ff       	call   800b8f <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8019b7:	8b 06                	mov    (%esi),%eax
  8019b9:	3b 46 04             	cmp    0x4(%esi),%eax
  8019bc:	74 df                	je     80199d <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8019be:	99                   	cltd   
  8019bf:	c1 ea 1b             	shr    $0x1b,%edx
  8019c2:	01 d0                	add    %edx,%eax
  8019c4:	83 e0 1f             	and    $0x1f,%eax
  8019c7:	29 d0                	sub    %edx,%eax
  8019c9:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8019ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019d1:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8019d4:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019d7:	83 c3 01             	add    $0x1,%ebx
  8019da:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8019dd:	75 d8                	jne    8019b7 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8019df:	8b 45 10             	mov    0x10(%ebp),%eax
  8019e2:	eb 05                	jmp    8019e9 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019e4:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8019e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019ec:	5b                   	pop    %ebx
  8019ed:	5e                   	pop    %esi
  8019ee:	5f                   	pop    %edi
  8019ef:	5d                   	pop    %ebp
  8019f0:	c3                   	ret    

008019f1 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8019f1:	55                   	push   %ebp
  8019f2:	89 e5                	mov    %esp,%ebp
  8019f4:	56                   	push   %esi
  8019f5:	53                   	push   %ebx
  8019f6:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8019f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019fc:	50                   	push   %eax
  8019fd:	e8 0c f6 ff ff       	call   80100e <fd_alloc>
  801a02:	83 c4 10             	add    $0x10,%esp
  801a05:	89 c2                	mov    %eax,%edx
  801a07:	85 c0                	test   %eax,%eax
  801a09:	0f 88 2c 01 00 00    	js     801b3b <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a0f:	83 ec 04             	sub    $0x4,%esp
  801a12:	68 07 04 00 00       	push   $0x407
  801a17:	ff 75 f4             	pushl  -0xc(%ebp)
  801a1a:	6a 00                	push   $0x0
  801a1c:	e8 8d f1 ff ff       	call   800bae <sys_page_alloc>
  801a21:	83 c4 10             	add    $0x10,%esp
  801a24:	89 c2                	mov    %eax,%edx
  801a26:	85 c0                	test   %eax,%eax
  801a28:	0f 88 0d 01 00 00    	js     801b3b <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801a2e:	83 ec 0c             	sub    $0xc,%esp
  801a31:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a34:	50                   	push   %eax
  801a35:	e8 d4 f5 ff ff       	call   80100e <fd_alloc>
  801a3a:	89 c3                	mov    %eax,%ebx
  801a3c:	83 c4 10             	add    $0x10,%esp
  801a3f:	85 c0                	test   %eax,%eax
  801a41:	0f 88 e2 00 00 00    	js     801b29 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a47:	83 ec 04             	sub    $0x4,%esp
  801a4a:	68 07 04 00 00       	push   $0x407
  801a4f:	ff 75 f0             	pushl  -0x10(%ebp)
  801a52:	6a 00                	push   $0x0
  801a54:	e8 55 f1 ff ff       	call   800bae <sys_page_alloc>
  801a59:	89 c3                	mov    %eax,%ebx
  801a5b:	83 c4 10             	add    $0x10,%esp
  801a5e:	85 c0                	test   %eax,%eax
  801a60:	0f 88 c3 00 00 00    	js     801b29 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801a66:	83 ec 0c             	sub    $0xc,%esp
  801a69:	ff 75 f4             	pushl  -0xc(%ebp)
  801a6c:	e8 86 f5 ff ff       	call   800ff7 <fd2data>
  801a71:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a73:	83 c4 0c             	add    $0xc,%esp
  801a76:	68 07 04 00 00       	push   $0x407
  801a7b:	50                   	push   %eax
  801a7c:	6a 00                	push   $0x0
  801a7e:	e8 2b f1 ff ff       	call   800bae <sys_page_alloc>
  801a83:	89 c3                	mov    %eax,%ebx
  801a85:	83 c4 10             	add    $0x10,%esp
  801a88:	85 c0                	test   %eax,%eax
  801a8a:	0f 88 89 00 00 00    	js     801b19 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a90:	83 ec 0c             	sub    $0xc,%esp
  801a93:	ff 75 f0             	pushl  -0x10(%ebp)
  801a96:	e8 5c f5 ff ff       	call   800ff7 <fd2data>
  801a9b:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801aa2:	50                   	push   %eax
  801aa3:	6a 00                	push   $0x0
  801aa5:	56                   	push   %esi
  801aa6:	6a 00                	push   $0x0
  801aa8:	e8 44 f1 ff ff       	call   800bf1 <sys_page_map>
  801aad:	89 c3                	mov    %eax,%ebx
  801aaf:	83 c4 20             	add    $0x20,%esp
  801ab2:	85 c0                	test   %eax,%eax
  801ab4:	78 55                	js     801b0b <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801ab6:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801abc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801abf:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ac1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ac4:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801acb:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ad1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ad4:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ad6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ad9:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801ae0:	83 ec 0c             	sub    $0xc,%esp
  801ae3:	ff 75 f4             	pushl  -0xc(%ebp)
  801ae6:	e8 fc f4 ff ff       	call   800fe7 <fd2num>
  801aeb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801aee:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801af0:	83 c4 04             	add    $0x4,%esp
  801af3:	ff 75 f0             	pushl  -0x10(%ebp)
  801af6:	e8 ec f4 ff ff       	call   800fe7 <fd2num>
  801afb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801afe:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801b01:	83 c4 10             	add    $0x10,%esp
  801b04:	ba 00 00 00 00       	mov    $0x0,%edx
  801b09:	eb 30                	jmp    801b3b <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801b0b:	83 ec 08             	sub    $0x8,%esp
  801b0e:	56                   	push   %esi
  801b0f:	6a 00                	push   $0x0
  801b11:	e8 1d f1 ff ff       	call   800c33 <sys_page_unmap>
  801b16:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801b19:	83 ec 08             	sub    $0x8,%esp
  801b1c:	ff 75 f0             	pushl  -0x10(%ebp)
  801b1f:	6a 00                	push   $0x0
  801b21:	e8 0d f1 ff ff       	call   800c33 <sys_page_unmap>
  801b26:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801b29:	83 ec 08             	sub    $0x8,%esp
  801b2c:	ff 75 f4             	pushl  -0xc(%ebp)
  801b2f:	6a 00                	push   $0x0
  801b31:	e8 fd f0 ff ff       	call   800c33 <sys_page_unmap>
  801b36:	83 c4 10             	add    $0x10,%esp
  801b39:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801b3b:	89 d0                	mov    %edx,%eax
  801b3d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b40:	5b                   	pop    %ebx
  801b41:	5e                   	pop    %esi
  801b42:	5d                   	pop    %ebp
  801b43:	c3                   	ret    

00801b44 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801b44:	55                   	push   %ebp
  801b45:	89 e5                	mov    %esp,%ebp
  801b47:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b4a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b4d:	50                   	push   %eax
  801b4e:	ff 75 08             	pushl  0x8(%ebp)
  801b51:	e8 07 f5 ff ff       	call   80105d <fd_lookup>
  801b56:	83 c4 10             	add    $0x10,%esp
  801b59:	85 c0                	test   %eax,%eax
  801b5b:	78 18                	js     801b75 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801b5d:	83 ec 0c             	sub    $0xc,%esp
  801b60:	ff 75 f4             	pushl  -0xc(%ebp)
  801b63:	e8 8f f4 ff ff       	call   800ff7 <fd2data>
	return _pipeisclosed(fd, p);
  801b68:	89 c2                	mov    %eax,%edx
  801b6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b6d:	e8 21 fd ff ff       	call   801893 <_pipeisclosed>
  801b72:	83 c4 10             	add    $0x10,%esp
}
  801b75:	c9                   	leave  
  801b76:	c3                   	ret    

00801b77 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801b77:	55                   	push   %ebp
  801b78:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801b7a:	b8 00 00 00 00       	mov    $0x0,%eax
  801b7f:	5d                   	pop    %ebp
  801b80:	c3                   	ret    

00801b81 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801b81:	55                   	push   %ebp
  801b82:	89 e5                	mov    %esp,%ebp
  801b84:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801b87:	68 8e 26 80 00       	push   $0x80268e
  801b8c:	ff 75 0c             	pushl  0xc(%ebp)
  801b8f:	e8 17 ec ff ff       	call   8007ab <strcpy>
	return 0;
}
  801b94:	b8 00 00 00 00       	mov    $0x0,%eax
  801b99:	c9                   	leave  
  801b9a:	c3                   	ret    

00801b9b <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b9b:	55                   	push   %ebp
  801b9c:	89 e5                	mov    %esp,%ebp
  801b9e:	57                   	push   %edi
  801b9f:	56                   	push   %esi
  801ba0:	53                   	push   %ebx
  801ba1:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ba7:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801bac:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bb2:	eb 2d                	jmp    801be1 <devcons_write+0x46>
		m = n - tot;
  801bb4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801bb7:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801bb9:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801bbc:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801bc1:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801bc4:	83 ec 04             	sub    $0x4,%esp
  801bc7:	53                   	push   %ebx
  801bc8:	03 45 0c             	add    0xc(%ebp),%eax
  801bcb:	50                   	push   %eax
  801bcc:	57                   	push   %edi
  801bcd:	e8 6b ed ff ff       	call   80093d <memmove>
		sys_cputs(buf, m);
  801bd2:	83 c4 08             	add    $0x8,%esp
  801bd5:	53                   	push   %ebx
  801bd6:	57                   	push   %edi
  801bd7:	e8 16 ef ff ff       	call   800af2 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bdc:	01 de                	add    %ebx,%esi
  801bde:	83 c4 10             	add    $0x10,%esp
  801be1:	89 f0                	mov    %esi,%eax
  801be3:	3b 75 10             	cmp    0x10(%ebp),%esi
  801be6:	72 cc                	jb     801bb4 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801be8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801beb:	5b                   	pop    %ebx
  801bec:	5e                   	pop    %esi
  801bed:	5f                   	pop    %edi
  801bee:	5d                   	pop    %ebp
  801bef:	c3                   	ret    

00801bf0 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801bf0:	55                   	push   %ebp
  801bf1:	89 e5                	mov    %esp,%ebp
  801bf3:	83 ec 08             	sub    $0x8,%esp
  801bf6:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801bfb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801bff:	74 2a                	je     801c2b <devcons_read+0x3b>
  801c01:	eb 05                	jmp    801c08 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801c03:	e8 87 ef ff ff       	call   800b8f <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801c08:	e8 03 ef ff ff       	call   800b10 <sys_cgetc>
  801c0d:	85 c0                	test   %eax,%eax
  801c0f:	74 f2                	je     801c03 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801c11:	85 c0                	test   %eax,%eax
  801c13:	78 16                	js     801c2b <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801c15:	83 f8 04             	cmp    $0x4,%eax
  801c18:	74 0c                	je     801c26 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801c1a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c1d:	88 02                	mov    %al,(%edx)
	return 1;
  801c1f:	b8 01 00 00 00       	mov    $0x1,%eax
  801c24:	eb 05                	jmp    801c2b <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801c26:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801c2b:	c9                   	leave  
  801c2c:	c3                   	ret    

00801c2d <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801c2d:	55                   	push   %ebp
  801c2e:	89 e5                	mov    %esp,%ebp
  801c30:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801c33:	8b 45 08             	mov    0x8(%ebp),%eax
  801c36:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801c39:	6a 01                	push   $0x1
  801c3b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c3e:	50                   	push   %eax
  801c3f:	e8 ae ee ff ff       	call   800af2 <sys_cputs>
}
  801c44:	83 c4 10             	add    $0x10,%esp
  801c47:	c9                   	leave  
  801c48:	c3                   	ret    

00801c49 <getchar>:

int
getchar(void)
{
  801c49:	55                   	push   %ebp
  801c4a:	89 e5                	mov    %esp,%ebp
  801c4c:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801c4f:	6a 01                	push   $0x1
  801c51:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c54:	50                   	push   %eax
  801c55:	6a 00                	push   $0x0
  801c57:	e8 67 f6 ff ff       	call   8012c3 <read>
	if (r < 0)
  801c5c:	83 c4 10             	add    $0x10,%esp
  801c5f:	85 c0                	test   %eax,%eax
  801c61:	78 0f                	js     801c72 <getchar+0x29>
		return r;
	if (r < 1)
  801c63:	85 c0                	test   %eax,%eax
  801c65:	7e 06                	jle    801c6d <getchar+0x24>
		return -E_EOF;
	return c;
  801c67:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801c6b:	eb 05                	jmp    801c72 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801c6d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801c72:	c9                   	leave  
  801c73:	c3                   	ret    

00801c74 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801c74:	55                   	push   %ebp
  801c75:	89 e5                	mov    %esp,%ebp
  801c77:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c7a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c7d:	50                   	push   %eax
  801c7e:	ff 75 08             	pushl  0x8(%ebp)
  801c81:	e8 d7 f3 ff ff       	call   80105d <fd_lookup>
  801c86:	83 c4 10             	add    $0x10,%esp
  801c89:	85 c0                	test   %eax,%eax
  801c8b:	78 11                	js     801c9e <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801c8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c90:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c96:	39 10                	cmp    %edx,(%eax)
  801c98:	0f 94 c0             	sete   %al
  801c9b:	0f b6 c0             	movzbl %al,%eax
}
  801c9e:	c9                   	leave  
  801c9f:	c3                   	ret    

00801ca0 <opencons>:

int
opencons(void)
{
  801ca0:	55                   	push   %ebp
  801ca1:	89 e5                	mov    %esp,%ebp
  801ca3:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ca6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ca9:	50                   	push   %eax
  801caa:	e8 5f f3 ff ff       	call   80100e <fd_alloc>
  801caf:	83 c4 10             	add    $0x10,%esp
		return r;
  801cb2:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801cb4:	85 c0                	test   %eax,%eax
  801cb6:	78 3e                	js     801cf6 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801cb8:	83 ec 04             	sub    $0x4,%esp
  801cbb:	68 07 04 00 00       	push   $0x407
  801cc0:	ff 75 f4             	pushl  -0xc(%ebp)
  801cc3:	6a 00                	push   $0x0
  801cc5:	e8 e4 ee ff ff       	call   800bae <sys_page_alloc>
  801cca:	83 c4 10             	add    $0x10,%esp
		return r;
  801ccd:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ccf:	85 c0                	test   %eax,%eax
  801cd1:	78 23                	js     801cf6 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801cd3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cdc:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801cde:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ce1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ce8:	83 ec 0c             	sub    $0xc,%esp
  801ceb:	50                   	push   %eax
  801cec:	e8 f6 f2 ff ff       	call   800fe7 <fd2num>
  801cf1:	89 c2                	mov    %eax,%edx
  801cf3:	83 c4 10             	add    $0x10,%esp
}
  801cf6:	89 d0                	mov    %edx,%eax
  801cf8:	c9                   	leave  
  801cf9:	c3                   	ret    

00801cfa <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801cfa:	55                   	push   %ebp
  801cfb:	89 e5                	mov    %esp,%ebp
  801cfd:	53                   	push   %ebx
  801cfe:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  801d01:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801d08:	75 28                	jne    801d32 <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  801d0a:	e8 61 ee ff ff       	call   800b70 <sys_getenvid>
  801d0f:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_U | PTE_W);
  801d11:	83 ec 04             	sub    $0x4,%esp
  801d14:	6a 06                	push   $0x6
  801d16:	68 00 f0 bf ee       	push   $0xeebff000
  801d1b:	50                   	push   %eax
  801d1c:	e8 8d ee ff ff       	call   800bae <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  801d21:	83 c4 08             	add    $0x8,%esp
  801d24:	68 3f 1d 80 00       	push   $0x801d3f
  801d29:	53                   	push   %ebx
  801d2a:	e8 ca ef ff ff       	call   800cf9 <sys_env_set_pgfault_upcall>
  801d2f:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801d32:	8b 45 08             	mov    0x8(%ebp),%eax
  801d35:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801d3a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d3d:	c9                   	leave  
  801d3e:	c3                   	ret    

00801d3f <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801d3f:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801d40:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801d45:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801d47:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	# My method is different. Copy the values to the other stack
	# in a convinient way, and then pop everything.
	movl %esp, %ebp		# ebp refers to the exception stack
  801d4a:	89 e5                	mov    %esp,%ebp
	movl 48(%ebp), %esp 	# go to other stack
  801d4c:	8b 65 30             	mov    0x30(%ebp),%esp

	pushl 40(%ebp)		# eip - ORDER SWITCHED WITH EFLAGS
  801d4f:	ff 75 28             	pushl  0x28(%ebp)
	pushl 44(%ebp)      	# eflags
  801d52:	ff 75 2c             	pushl  0x2c(%ebp)
	pushl 36(%ebp)		# all the 8 remaining regs
  801d55:	ff 75 24             	pushl  0x24(%ebp)
	pushl 32(%ebp)
  801d58:	ff 75 20             	pushl  0x20(%ebp)
	pushl 28(%ebp)
  801d5b:	ff 75 1c             	pushl  0x1c(%ebp)
	pushl 24(%ebp)
  801d5e:	ff 75 18             	pushl  0x18(%ebp)
	pushl 20(%ebp)
  801d61:	ff 75 14             	pushl  0x14(%ebp)
	pushl 16(%ebp)
  801d64:	ff 75 10             	pushl  0x10(%ebp)
	pushl 12(%ebp)
  801d67:	ff 75 0c             	pushl  0xc(%ebp)
	pushl 8(%ebp)
  801d6a:	ff 75 08             	pushl  0x8(%ebp)

	popal			# now just pop everything!
  801d6d:	61                   	popa   
	popfl
  801d6e:	9d                   	popf   
	ret
  801d6f:	c3                   	ret    

00801d70 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801d70:	55                   	push   %ebp
  801d71:	89 e5                	mov    %esp,%ebp
  801d73:	56                   	push   %esi
  801d74:	53                   	push   %ebx
  801d75:	8b 75 08             	mov    0x8(%ebp),%esi
  801d78:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d7b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  801d7e:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801d80:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801d85:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  801d88:	83 ec 0c             	sub    $0xc,%esp
  801d8b:	50                   	push   %eax
  801d8c:	e8 cd ef ff ff       	call   800d5e <sys_ipc_recv>

	if (r < 0) {
  801d91:	83 c4 10             	add    $0x10,%esp
  801d94:	85 c0                	test   %eax,%eax
  801d96:	79 16                	jns    801dae <ipc_recv+0x3e>
		if (from_env_store)
  801d98:	85 f6                	test   %esi,%esi
  801d9a:	74 06                	je     801da2 <ipc_recv+0x32>
			*from_env_store = 0;
  801d9c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  801da2:	85 db                	test   %ebx,%ebx
  801da4:	74 2c                	je     801dd2 <ipc_recv+0x62>
			*perm_store = 0;
  801da6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801dac:	eb 24                	jmp    801dd2 <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  801dae:	85 f6                	test   %esi,%esi
  801db0:	74 0a                	je     801dbc <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  801db2:	a1 08 40 80 00       	mov    0x804008,%eax
  801db7:	8b 40 74             	mov    0x74(%eax),%eax
  801dba:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  801dbc:	85 db                	test   %ebx,%ebx
  801dbe:	74 0a                	je     801dca <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  801dc0:	a1 08 40 80 00       	mov    0x804008,%eax
  801dc5:	8b 40 78             	mov    0x78(%eax),%eax
  801dc8:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  801dca:	a1 08 40 80 00       	mov    0x804008,%eax
  801dcf:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  801dd2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dd5:	5b                   	pop    %ebx
  801dd6:	5e                   	pop    %esi
  801dd7:	5d                   	pop    %ebp
  801dd8:	c3                   	ret    

00801dd9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801dd9:	55                   	push   %ebp
  801dda:	89 e5                	mov    %esp,%ebp
  801ddc:	57                   	push   %edi
  801ddd:	56                   	push   %esi
  801dde:	53                   	push   %ebx
  801ddf:	83 ec 0c             	sub    $0xc,%esp
  801de2:	8b 7d 08             	mov    0x8(%ebp),%edi
  801de5:	8b 75 0c             	mov    0xc(%ebp),%esi
  801de8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  801deb:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801ded:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801df2:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  801df5:	ff 75 14             	pushl  0x14(%ebp)
  801df8:	53                   	push   %ebx
  801df9:	56                   	push   %esi
  801dfa:	57                   	push   %edi
  801dfb:	e8 3b ef ff ff       	call   800d3b <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  801e00:	83 c4 10             	add    $0x10,%esp
  801e03:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e06:	75 07                	jne    801e0f <ipc_send+0x36>
			sys_yield();
  801e08:	e8 82 ed ff ff       	call   800b8f <sys_yield>
  801e0d:	eb e6                	jmp    801df5 <ipc_send+0x1c>
		} else if (r < 0) {
  801e0f:	85 c0                	test   %eax,%eax
  801e11:	79 12                	jns    801e25 <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  801e13:	50                   	push   %eax
  801e14:	68 9a 26 80 00       	push   $0x80269a
  801e19:	6a 51                	push   $0x51
  801e1b:	68 a7 26 80 00       	push   $0x8026a7
  801e20:	e8 28 e3 ff ff       	call   80014d <_panic>
		}
	}
}
  801e25:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e28:	5b                   	pop    %ebx
  801e29:	5e                   	pop    %esi
  801e2a:	5f                   	pop    %edi
  801e2b:	5d                   	pop    %ebp
  801e2c:	c3                   	ret    

00801e2d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801e2d:	55                   	push   %ebp
  801e2e:	89 e5                	mov    %esp,%ebp
  801e30:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801e33:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801e38:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801e3b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801e41:	8b 52 50             	mov    0x50(%edx),%edx
  801e44:	39 ca                	cmp    %ecx,%edx
  801e46:	75 0d                	jne    801e55 <ipc_find_env+0x28>
			return envs[i].env_id;
  801e48:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801e4b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801e50:	8b 40 48             	mov    0x48(%eax),%eax
  801e53:	eb 0f                	jmp    801e64 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801e55:	83 c0 01             	add    $0x1,%eax
  801e58:	3d 00 04 00 00       	cmp    $0x400,%eax
  801e5d:	75 d9                	jne    801e38 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801e5f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e64:	5d                   	pop    %ebp
  801e65:	c3                   	ret    

00801e66 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801e66:	55                   	push   %ebp
  801e67:	89 e5                	mov    %esp,%ebp
  801e69:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e6c:	89 d0                	mov    %edx,%eax
  801e6e:	c1 e8 16             	shr    $0x16,%eax
  801e71:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801e78:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e7d:	f6 c1 01             	test   $0x1,%cl
  801e80:	74 1d                	je     801e9f <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801e82:	c1 ea 0c             	shr    $0xc,%edx
  801e85:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801e8c:	f6 c2 01             	test   $0x1,%dl
  801e8f:	74 0e                	je     801e9f <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801e91:	c1 ea 0c             	shr    $0xc,%edx
  801e94:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801e9b:	ef 
  801e9c:	0f b7 c0             	movzwl %ax,%eax
}
  801e9f:	5d                   	pop    %ebp
  801ea0:	c3                   	ret    
  801ea1:	66 90                	xchg   %ax,%ax
  801ea3:	66 90                	xchg   %ax,%ax
  801ea5:	66 90                	xchg   %ax,%ax
  801ea7:	66 90                	xchg   %ax,%ax
  801ea9:	66 90                	xchg   %ax,%ax
  801eab:	66 90                	xchg   %ax,%ax
  801ead:	66 90                	xchg   %ax,%ax
  801eaf:	90                   	nop

00801eb0 <__udivdi3>:
  801eb0:	55                   	push   %ebp
  801eb1:	57                   	push   %edi
  801eb2:	56                   	push   %esi
  801eb3:	53                   	push   %ebx
  801eb4:	83 ec 1c             	sub    $0x1c,%esp
  801eb7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801ebb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801ebf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801ec3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ec7:	85 f6                	test   %esi,%esi
  801ec9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ecd:	89 ca                	mov    %ecx,%edx
  801ecf:	89 f8                	mov    %edi,%eax
  801ed1:	75 3d                	jne    801f10 <__udivdi3+0x60>
  801ed3:	39 cf                	cmp    %ecx,%edi
  801ed5:	0f 87 c5 00 00 00    	ja     801fa0 <__udivdi3+0xf0>
  801edb:	85 ff                	test   %edi,%edi
  801edd:	89 fd                	mov    %edi,%ebp
  801edf:	75 0b                	jne    801eec <__udivdi3+0x3c>
  801ee1:	b8 01 00 00 00       	mov    $0x1,%eax
  801ee6:	31 d2                	xor    %edx,%edx
  801ee8:	f7 f7                	div    %edi
  801eea:	89 c5                	mov    %eax,%ebp
  801eec:	89 c8                	mov    %ecx,%eax
  801eee:	31 d2                	xor    %edx,%edx
  801ef0:	f7 f5                	div    %ebp
  801ef2:	89 c1                	mov    %eax,%ecx
  801ef4:	89 d8                	mov    %ebx,%eax
  801ef6:	89 cf                	mov    %ecx,%edi
  801ef8:	f7 f5                	div    %ebp
  801efa:	89 c3                	mov    %eax,%ebx
  801efc:	89 d8                	mov    %ebx,%eax
  801efe:	89 fa                	mov    %edi,%edx
  801f00:	83 c4 1c             	add    $0x1c,%esp
  801f03:	5b                   	pop    %ebx
  801f04:	5e                   	pop    %esi
  801f05:	5f                   	pop    %edi
  801f06:	5d                   	pop    %ebp
  801f07:	c3                   	ret    
  801f08:	90                   	nop
  801f09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f10:	39 ce                	cmp    %ecx,%esi
  801f12:	77 74                	ja     801f88 <__udivdi3+0xd8>
  801f14:	0f bd fe             	bsr    %esi,%edi
  801f17:	83 f7 1f             	xor    $0x1f,%edi
  801f1a:	0f 84 98 00 00 00    	je     801fb8 <__udivdi3+0x108>
  801f20:	bb 20 00 00 00       	mov    $0x20,%ebx
  801f25:	89 f9                	mov    %edi,%ecx
  801f27:	89 c5                	mov    %eax,%ebp
  801f29:	29 fb                	sub    %edi,%ebx
  801f2b:	d3 e6                	shl    %cl,%esi
  801f2d:	89 d9                	mov    %ebx,%ecx
  801f2f:	d3 ed                	shr    %cl,%ebp
  801f31:	89 f9                	mov    %edi,%ecx
  801f33:	d3 e0                	shl    %cl,%eax
  801f35:	09 ee                	or     %ebp,%esi
  801f37:	89 d9                	mov    %ebx,%ecx
  801f39:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f3d:	89 d5                	mov    %edx,%ebp
  801f3f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801f43:	d3 ed                	shr    %cl,%ebp
  801f45:	89 f9                	mov    %edi,%ecx
  801f47:	d3 e2                	shl    %cl,%edx
  801f49:	89 d9                	mov    %ebx,%ecx
  801f4b:	d3 e8                	shr    %cl,%eax
  801f4d:	09 c2                	or     %eax,%edx
  801f4f:	89 d0                	mov    %edx,%eax
  801f51:	89 ea                	mov    %ebp,%edx
  801f53:	f7 f6                	div    %esi
  801f55:	89 d5                	mov    %edx,%ebp
  801f57:	89 c3                	mov    %eax,%ebx
  801f59:	f7 64 24 0c          	mull   0xc(%esp)
  801f5d:	39 d5                	cmp    %edx,%ebp
  801f5f:	72 10                	jb     801f71 <__udivdi3+0xc1>
  801f61:	8b 74 24 08          	mov    0x8(%esp),%esi
  801f65:	89 f9                	mov    %edi,%ecx
  801f67:	d3 e6                	shl    %cl,%esi
  801f69:	39 c6                	cmp    %eax,%esi
  801f6b:	73 07                	jae    801f74 <__udivdi3+0xc4>
  801f6d:	39 d5                	cmp    %edx,%ebp
  801f6f:	75 03                	jne    801f74 <__udivdi3+0xc4>
  801f71:	83 eb 01             	sub    $0x1,%ebx
  801f74:	31 ff                	xor    %edi,%edi
  801f76:	89 d8                	mov    %ebx,%eax
  801f78:	89 fa                	mov    %edi,%edx
  801f7a:	83 c4 1c             	add    $0x1c,%esp
  801f7d:	5b                   	pop    %ebx
  801f7e:	5e                   	pop    %esi
  801f7f:	5f                   	pop    %edi
  801f80:	5d                   	pop    %ebp
  801f81:	c3                   	ret    
  801f82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801f88:	31 ff                	xor    %edi,%edi
  801f8a:	31 db                	xor    %ebx,%ebx
  801f8c:	89 d8                	mov    %ebx,%eax
  801f8e:	89 fa                	mov    %edi,%edx
  801f90:	83 c4 1c             	add    $0x1c,%esp
  801f93:	5b                   	pop    %ebx
  801f94:	5e                   	pop    %esi
  801f95:	5f                   	pop    %edi
  801f96:	5d                   	pop    %ebp
  801f97:	c3                   	ret    
  801f98:	90                   	nop
  801f99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fa0:	89 d8                	mov    %ebx,%eax
  801fa2:	f7 f7                	div    %edi
  801fa4:	31 ff                	xor    %edi,%edi
  801fa6:	89 c3                	mov    %eax,%ebx
  801fa8:	89 d8                	mov    %ebx,%eax
  801faa:	89 fa                	mov    %edi,%edx
  801fac:	83 c4 1c             	add    $0x1c,%esp
  801faf:	5b                   	pop    %ebx
  801fb0:	5e                   	pop    %esi
  801fb1:	5f                   	pop    %edi
  801fb2:	5d                   	pop    %ebp
  801fb3:	c3                   	ret    
  801fb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801fb8:	39 ce                	cmp    %ecx,%esi
  801fba:	72 0c                	jb     801fc8 <__udivdi3+0x118>
  801fbc:	31 db                	xor    %ebx,%ebx
  801fbe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801fc2:	0f 87 34 ff ff ff    	ja     801efc <__udivdi3+0x4c>
  801fc8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801fcd:	e9 2a ff ff ff       	jmp    801efc <__udivdi3+0x4c>
  801fd2:	66 90                	xchg   %ax,%ax
  801fd4:	66 90                	xchg   %ax,%ax
  801fd6:	66 90                	xchg   %ax,%ax
  801fd8:	66 90                	xchg   %ax,%ax
  801fda:	66 90                	xchg   %ax,%ax
  801fdc:	66 90                	xchg   %ax,%ax
  801fde:	66 90                	xchg   %ax,%ax

00801fe0 <__umoddi3>:
  801fe0:	55                   	push   %ebp
  801fe1:	57                   	push   %edi
  801fe2:	56                   	push   %esi
  801fe3:	53                   	push   %ebx
  801fe4:	83 ec 1c             	sub    $0x1c,%esp
  801fe7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801feb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801fef:	8b 74 24 34          	mov    0x34(%esp),%esi
  801ff3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ff7:	85 d2                	test   %edx,%edx
  801ff9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801ffd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802001:	89 f3                	mov    %esi,%ebx
  802003:	89 3c 24             	mov    %edi,(%esp)
  802006:	89 74 24 04          	mov    %esi,0x4(%esp)
  80200a:	75 1c                	jne    802028 <__umoddi3+0x48>
  80200c:	39 f7                	cmp    %esi,%edi
  80200e:	76 50                	jbe    802060 <__umoddi3+0x80>
  802010:	89 c8                	mov    %ecx,%eax
  802012:	89 f2                	mov    %esi,%edx
  802014:	f7 f7                	div    %edi
  802016:	89 d0                	mov    %edx,%eax
  802018:	31 d2                	xor    %edx,%edx
  80201a:	83 c4 1c             	add    $0x1c,%esp
  80201d:	5b                   	pop    %ebx
  80201e:	5e                   	pop    %esi
  80201f:	5f                   	pop    %edi
  802020:	5d                   	pop    %ebp
  802021:	c3                   	ret    
  802022:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802028:	39 f2                	cmp    %esi,%edx
  80202a:	89 d0                	mov    %edx,%eax
  80202c:	77 52                	ja     802080 <__umoddi3+0xa0>
  80202e:	0f bd ea             	bsr    %edx,%ebp
  802031:	83 f5 1f             	xor    $0x1f,%ebp
  802034:	75 5a                	jne    802090 <__umoddi3+0xb0>
  802036:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80203a:	0f 82 e0 00 00 00    	jb     802120 <__umoddi3+0x140>
  802040:	39 0c 24             	cmp    %ecx,(%esp)
  802043:	0f 86 d7 00 00 00    	jbe    802120 <__umoddi3+0x140>
  802049:	8b 44 24 08          	mov    0x8(%esp),%eax
  80204d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802051:	83 c4 1c             	add    $0x1c,%esp
  802054:	5b                   	pop    %ebx
  802055:	5e                   	pop    %esi
  802056:	5f                   	pop    %edi
  802057:	5d                   	pop    %ebp
  802058:	c3                   	ret    
  802059:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802060:	85 ff                	test   %edi,%edi
  802062:	89 fd                	mov    %edi,%ebp
  802064:	75 0b                	jne    802071 <__umoddi3+0x91>
  802066:	b8 01 00 00 00       	mov    $0x1,%eax
  80206b:	31 d2                	xor    %edx,%edx
  80206d:	f7 f7                	div    %edi
  80206f:	89 c5                	mov    %eax,%ebp
  802071:	89 f0                	mov    %esi,%eax
  802073:	31 d2                	xor    %edx,%edx
  802075:	f7 f5                	div    %ebp
  802077:	89 c8                	mov    %ecx,%eax
  802079:	f7 f5                	div    %ebp
  80207b:	89 d0                	mov    %edx,%eax
  80207d:	eb 99                	jmp    802018 <__umoddi3+0x38>
  80207f:	90                   	nop
  802080:	89 c8                	mov    %ecx,%eax
  802082:	89 f2                	mov    %esi,%edx
  802084:	83 c4 1c             	add    $0x1c,%esp
  802087:	5b                   	pop    %ebx
  802088:	5e                   	pop    %esi
  802089:	5f                   	pop    %edi
  80208a:	5d                   	pop    %ebp
  80208b:	c3                   	ret    
  80208c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802090:	8b 34 24             	mov    (%esp),%esi
  802093:	bf 20 00 00 00       	mov    $0x20,%edi
  802098:	89 e9                	mov    %ebp,%ecx
  80209a:	29 ef                	sub    %ebp,%edi
  80209c:	d3 e0                	shl    %cl,%eax
  80209e:	89 f9                	mov    %edi,%ecx
  8020a0:	89 f2                	mov    %esi,%edx
  8020a2:	d3 ea                	shr    %cl,%edx
  8020a4:	89 e9                	mov    %ebp,%ecx
  8020a6:	09 c2                	or     %eax,%edx
  8020a8:	89 d8                	mov    %ebx,%eax
  8020aa:	89 14 24             	mov    %edx,(%esp)
  8020ad:	89 f2                	mov    %esi,%edx
  8020af:	d3 e2                	shl    %cl,%edx
  8020b1:	89 f9                	mov    %edi,%ecx
  8020b3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8020b7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8020bb:	d3 e8                	shr    %cl,%eax
  8020bd:	89 e9                	mov    %ebp,%ecx
  8020bf:	89 c6                	mov    %eax,%esi
  8020c1:	d3 e3                	shl    %cl,%ebx
  8020c3:	89 f9                	mov    %edi,%ecx
  8020c5:	89 d0                	mov    %edx,%eax
  8020c7:	d3 e8                	shr    %cl,%eax
  8020c9:	89 e9                	mov    %ebp,%ecx
  8020cb:	09 d8                	or     %ebx,%eax
  8020cd:	89 d3                	mov    %edx,%ebx
  8020cf:	89 f2                	mov    %esi,%edx
  8020d1:	f7 34 24             	divl   (%esp)
  8020d4:	89 d6                	mov    %edx,%esi
  8020d6:	d3 e3                	shl    %cl,%ebx
  8020d8:	f7 64 24 04          	mull   0x4(%esp)
  8020dc:	39 d6                	cmp    %edx,%esi
  8020de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020e2:	89 d1                	mov    %edx,%ecx
  8020e4:	89 c3                	mov    %eax,%ebx
  8020e6:	72 08                	jb     8020f0 <__umoddi3+0x110>
  8020e8:	75 11                	jne    8020fb <__umoddi3+0x11b>
  8020ea:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8020ee:	73 0b                	jae    8020fb <__umoddi3+0x11b>
  8020f0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8020f4:	1b 14 24             	sbb    (%esp),%edx
  8020f7:	89 d1                	mov    %edx,%ecx
  8020f9:	89 c3                	mov    %eax,%ebx
  8020fb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8020ff:	29 da                	sub    %ebx,%edx
  802101:	19 ce                	sbb    %ecx,%esi
  802103:	89 f9                	mov    %edi,%ecx
  802105:	89 f0                	mov    %esi,%eax
  802107:	d3 e0                	shl    %cl,%eax
  802109:	89 e9                	mov    %ebp,%ecx
  80210b:	d3 ea                	shr    %cl,%edx
  80210d:	89 e9                	mov    %ebp,%ecx
  80210f:	d3 ee                	shr    %cl,%esi
  802111:	09 d0                	or     %edx,%eax
  802113:	89 f2                	mov    %esi,%edx
  802115:	83 c4 1c             	add    $0x1c,%esp
  802118:	5b                   	pop    %ebx
  802119:	5e                   	pop    %esi
  80211a:	5f                   	pop    %edi
  80211b:	5d                   	pop    %ebp
  80211c:	c3                   	ret    
  80211d:	8d 76 00             	lea    0x0(%esi),%esi
  802120:	29 f9                	sub    %edi,%ecx
  802122:	19 d6                	sbb    %edx,%esi
  802124:	89 74 24 04          	mov    %esi,0x4(%esp)
  802128:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80212c:	e9 18 ff ff ff       	jmp    802049 <__umoddi3+0x69>
