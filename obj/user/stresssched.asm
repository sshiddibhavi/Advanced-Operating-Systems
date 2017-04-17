
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
  800044:	e8 29 0f 00 00       	call   800f72 <fork>
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
  80008f:	a1 08 40 80 00       	mov    0x804008,%eax
  800094:	83 c0 01             	add    $0x1,%eax
  800097:	a3 08 40 80 00       	mov    %eax,0x804008
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
  8000a6:	a1 08 40 80 00       	mov    0x804008,%eax
  8000ab:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000b0:	74 17                	je     8000c9 <umain+0x96>
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000b2:	a1 08 40 80 00       	mov    0x804008,%eax
  8000b7:	50                   	push   %eax
  8000b8:	68 20 26 80 00       	push   $0x802620
  8000bd:	6a 21                	push   $0x21
  8000bf:	68 48 26 80 00       	push   $0x802648
  8000c4:	e8 84 00 00 00       	call   80014d <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000c9:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8000ce:	8b 50 5c             	mov    0x5c(%eax),%edx
  8000d1:	8b 40 48             	mov    0x48(%eax),%eax
  8000d4:	83 ec 04             	sub    $0x4,%esp
  8000d7:	52                   	push   %edx
  8000d8:	50                   	push   %eax
  8000d9:	68 5b 26 80 00       	push   $0x80265b
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
  80010a:	a3 0c 40 80 00       	mov    %eax,0x80400c

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
  800139:	e8 f4 10 00 00       	call   801232 <close_all>
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
  80016b:	68 84 26 80 00       	push   $0x802684
  800170:	e8 b1 00 00 00       	call   800226 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800175:	83 c4 18             	add    $0x18,%esp
  800178:	53                   	push   %ebx
  800179:	ff 75 10             	pushl  0x10(%ebp)
  80017c:	e8 54 00 00 00       	call   8001d5 <vcprintf>
	cprintf("\n");
  800181:	c7 04 24 77 26 80 00 	movl   $0x802677,(%esp)
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
  800289:	e8 02 21 00 00       	call   802390 <__udivdi3>
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
  8002cc:	e8 ef 21 00 00       	call   8024c0 <__umoddi3>
  8002d1:	83 c4 14             	add    $0x14,%esp
  8002d4:	0f be 80 a7 26 80 00 	movsbl 0x8026a7(%eax),%eax
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
  8003d0:	ff 24 85 e0 27 80 00 	jmp    *0x8027e0(,%eax,4)
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
  800494:	8b 14 85 40 29 80 00 	mov    0x802940(,%eax,4),%edx
  80049b:	85 d2                	test   %edx,%edx
  80049d:	75 18                	jne    8004b7 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80049f:	50                   	push   %eax
  8004a0:	68 bf 26 80 00       	push   $0x8026bf
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
  8004b8:	68 fe 2a 80 00       	push   $0x802afe
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
  8004dc:	b8 b8 26 80 00       	mov    $0x8026b8,%eax
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
  800b57:	68 9f 29 80 00       	push   $0x80299f
  800b5c:	6a 23                	push   $0x23
  800b5e:	68 bc 29 80 00       	push   $0x8029bc
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
  800bd8:	68 9f 29 80 00       	push   $0x80299f
  800bdd:	6a 23                	push   $0x23
  800bdf:	68 bc 29 80 00       	push   $0x8029bc
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
  800c1a:	68 9f 29 80 00       	push   $0x80299f
  800c1f:	6a 23                	push   $0x23
  800c21:	68 bc 29 80 00       	push   $0x8029bc
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
  800c5c:	68 9f 29 80 00       	push   $0x80299f
  800c61:	6a 23                	push   $0x23
  800c63:	68 bc 29 80 00       	push   $0x8029bc
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
  800c9e:	68 9f 29 80 00       	push   $0x80299f
  800ca3:	6a 23                	push   $0x23
  800ca5:	68 bc 29 80 00       	push   $0x8029bc
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
  800ce0:	68 9f 29 80 00       	push   $0x80299f
  800ce5:	6a 23                	push   $0x23
  800ce7:	68 bc 29 80 00       	push   $0x8029bc
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
  800d22:	68 9f 29 80 00       	push   $0x80299f
  800d27:	6a 23                	push   $0x23
  800d29:	68 bc 29 80 00       	push   $0x8029bc
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
  800d86:	68 9f 29 80 00       	push   $0x80299f
  800d8b:	6a 23                	push   $0x23
  800d8d:	68 bc 29 80 00       	push   $0x8029bc
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

00800d9f <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d9f:	55                   	push   %ebp
  800da0:	89 e5                	mov    %esp,%ebp
  800da2:	57                   	push   %edi
  800da3:	56                   	push   %esi
  800da4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da5:	ba 00 00 00 00       	mov    $0x0,%edx
  800daa:	b8 0e 00 00 00       	mov    $0xe,%eax
  800daf:	89 d1                	mov    %edx,%ecx
  800db1:	89 d3                	mov    %edx,%ebx
  800db3:	89 d7                	mov    %edx,%edi
  800db5:	89 d6                	mov    %edx,%esi
  800db7:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800db9:	5b                   	pop    %ebx
  800dba:	5e                   	pop    %esi
  800dbb:	5f                   	pop    %edi
  800dbc:	5d                   	pop    %ebp
  800dbd:	c3                   	ret    

00800dbe <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800dbe:	55                   	push   %ebp
  800dbf:	89 e5                	mov    %esp,%ebp
  800dc1:	53                   	push   %ebx
  800dc2:	83 ec 04             	sub    $0x4,%esp
	int r;
	void * address = (void *)(pn*PGSIZE);
  800dc5:	89 d3                	mov    %edx,%ebx
  800dc7:	c1 e3 0c             	shl    $0xc,%ebx
	
	if((uvpt[pn] & PTE_SHARE))
  800dca:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800dd1:	f6 c5 04             	test   $0x4,%ch
  800dd4:	74 38                	je     800e0e <duppage+0x50>
	{
		if ((r = sys_page_map(0, address, envid, address, (uvpt[pn] | PTE_SYSCALL))) < 0)
  800dd6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ddd:	83 ec 0c             	sub    $0xc,%esp
  800de0:	81 ca 07 0e 00 00    	or     $0xe07,%edx
  800de6:	52                   	push   %edx
  800de7:	53                   	push   %ebx
  800de8:	50                   	push   %eax
  800de9:	53                   	push   %ebx
  800dea:	6a 00                	push   $0x0
  800dec:	e8 00 fe ff ff       	call   800bf1 <sys_page_map>
  800df1:	83 c4 20             	add    $0x20,%esp
  800df4:	85 c0                	test   %eax,%eax
  800df6:	0f 89 b8 00 00 00    	jns    800eb4 <duppage+0xf6>
			panic("sys_page_map: %e", r);
  800dfc:	50                   	push   %eax
  800dfd:	68 ca 29 80 00       	push   $0x8029ca
  800e02:	6a 4e                	push   $0x4e
  800e04:	68 db 29 80 00       	push   $0x8029db
  800e09:	e8 3f f3 ff ff       	call   80014d <_panic>
	}
	else if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW))
  800e0e:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800e15:	f6 c1 02             	test   $0x2,%cl
  800e18:	75 0c                	jne    800e26 <duppage+0x68>
  800e1a:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800e21:	f6 c5 08             	test   $0x8,%ch
  800e24:	74 57                	je     800e7d <duppage+0xbf>
	{
		int perm = 0;
		perm |= PTE_P|PTE_U|PTE_COW;
	
		if ((r = sys_page_map(0, address, envid, address, perm)) < 0)
  800e26:	83 ec 0c             	sub    $0xc,%esp
  800e29:	68 05 08 00 00       	push   $0x805
  800e2e:	53                   	push   %ebx
  800e2f:	50                   	push   %eax
  800e30:	53                   	push   %ebx
  800e31:	6a 00                	push   $0x0
  800e33:	e8 b9 fd ff ff       	call   800bf1 <sys_page_map>
  800e38:	83 c4 20             	add    $0x20,%esp
  800e3b:	85 c0                	test   %eax,%eax
  800e3d:	79 12                	jns    800e51 <duppage+0x93>
			panic("sys_page_map: %e", r);
  800e3f:	50                   	push   %eax
  800e40:	68 ca 29 80 00       	push   $0x8029ca
  800e45:	6a 56                	push   $0x56
  800e47:	68 db 29 80 00       	push   $0x8029db
  800e4c:	e8 fc f2 ff ff       	call   80014d <_panic>
		if ((r = sys_page_map(0, address, 0, address, perm)) < 0)
  800e51:	83 ec 0c             	sub    $0xc,%esp
  800e54:	68 05 08 00 00       	push   $0x805
  800e59:	53                   	push   %ebx
  800e5a:	6a 00                	push   $0x0
  800e5c:	53                   	push   %ebx
  800e5d:	6a 00                	push   $0x0
  800e5f:	e8 8d fd ff ff       	call   800bf1 <sys_page_map>
  800e64:	83 c4 20             	add    $0x20,%esp
  800e67:	85 c0                	test   %eax,%eax
  800e69:	79 49                	jns    800eb4 <duppage+0xf6>
			panic("sys_page_map: %e", r);
  800e6b:	50                   	push   %eax
  800e6c:	68 ca 29 80 00       	push   $0x8029ca
  800e71:	6a 58                	push   $0x58
  800e73:	68 db 29 80 00       	push   $0x8029db
  800e78:	e8 d0 f2 ff ff       	call   80014d <_panic>
	}
	else if((uvpt[pn] & ~PTE_U) == 0)
  800e7d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e84:	f7 c2 fb ff ff ff    	test   $0xfffffffb,%edx
  800e8a:	75 28                	jne    800eb4 <duppage+0xf6>
	{
		//cprintf("im here");
		if ((r = sys_page_map(0, address, envid, address, PTE_P|PTE_U)) < 0)
  800e8c:	83 ec 0c             	sub    $0xc,%esp
  800e8f:	6a 05                	push   $0x5
  800e91:	53                   	push   %ebx
  800e92:	50                   	push   %eax
  800e93:	53                   	push   %ebx
  800e94:	6a 00                	push   $0x0
  800e96:	e8 56 fd ff ff       	call   800bf1 <sys_page_map>
  800e9b:	83 c4 20             	add    $0x20,%esp
  800e9e:	85 c0                	test   %eax,%eax
  800ea0:	79 12                	jns    800eb4 <duppage+0xf6>
			panic("sys_page_map: %e", r);	
  800ea2:	50                   	push   %eax
  800ea3:	68 ca 29 80 00       	push   $0x8029ca
  800ea8:	6a 5e                	push   $0x5e
  800eaa:	68 db 29 80 00       	push   $0x8029db
  800eaf:	e8 99 f2 ff ff       	call   80014d <_panic>
	}
	return 0;
}
  800eb4:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ebc:	c9                   	leave  
  800ebd:	c3                   	ret    

00800ebe <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ebe:	55                   	push   %ebp
  800ebf:	89 e5                	mov    %esp,%ebp
  800ec1:	53                   	push   %ebx
  800ec2:	83 ec 08             	sub    $0x8,%esp
	void *addr = (void *) utf->utf_fault_va;
  800ec5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec8:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	unsigned pn = ((uint32_t)addr)/PGSIZE;
  800eca:	89 d8                	mov    %ebx,%eax
  800ecc:	c1 e8 0c             	shr    $0xc,%eax
	pte_t pte = uvpt[pn];
  800ecf:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// Allocate a new page, mapped at temp location
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  800ed6:	6a 07                	push   $0x7
  800ed8:	68 00 f0 7f 00       	push   $0x7ff000
  800edd:	6a 00                	push   $0x0
  800edf:	e8 ca fc ff ff       	call   800bae <sys_page_alloc>
  800ee4:	83 c4 10             	add    $0x10,%esp
  800ee7:	85 c0                	test   %eax,%eax
  800ee9:	79 12                	jns    800efd <pgfault+0x3f>
		panic("sys_page_alloc: %e", r);
  800eeb:	50                   	push   %eax
  800eec:	68 e6 29 80 00       	push   $0x8029e6
  800ef1:	6a 2b                	push   $0x2b
  800ef3:	68 db 29 80 00       	push   $0x8029db
  800ef8:	e8 50 f2 ff ff       	call   80014d <_panic>

	// Copy the data from the old page to this new page
	void *addr_pgstart = (void *) ROUNDDOWN(addr, PGSIZE);
  800efd:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr_pgstart, PGSIZE);
  800f03:	83 ec 04             	sub    $0x4,%esp
  800f06:	68 00 10 00 00       	push   $0x1000
  800f0b:	53                   	push   %ebx
  800f0c:	68 00 f0 7f 00       	push   $0x7ff000
  800f11:	e8 27 fa ff ff       	call   80093d <memmove>

	// Move the new page to the old page's address
	if ((r = sys_page_map(0, PFTEMP, 0, addr_pgstart, PTE_P|PTE_U|PTE_W)) < 0)
  800f16:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f1d:	53                   	push   %ebx
  800f1e:	6a 00                	push   $0x0
  800f20:	68 00 f0 7f 00       	push   $0x7ff000
  800f25:	6a 00                	push   $0x0
  800f27:	e8 c5 fc ff ff       	call   800bf1 <sys_page_map>
  800f2c:	83 c4 20             	add    $0x20,%esp
  800f2f:	85 c0                	test   %eax,%eax
  800f31:	79 12                	jns    800f45 <pgfault+0x87>
		panic("sys_page_map: %e", r);
  800f33:	50                   	push   %eax
  800f34:	68 ca 29 80 00       	push   $0x8029ca
  800f39:	6a 33                	push   $0x33
  800f3b:	68 db 29 80 00       	push   $0x8029db
  800f40:	e8 08 f2 ff ff       	call   80014d <_panic>

	// Unmap the temp location
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800f45:	83 ec 08             	sub    $0x8,%esp
  800f48:	68 00 f0 7f 00       	push   $0x7ff000
  800f4d:	6a 00                	push   $0x0
  800f4f:	e8 df fc ff ff       	call   800c33 <sys_page_unmap>
  800f54:	83 c4 10             	add    $0x10,%esp
  800f57:	85 c0                	test   %eax,%eax
  800f59:	79 12                	jns    800f6d <pgfault+0xaf>
		panic("sys_page_unmap: %e", r);
  800f5b:	50                   	push   %eax
  800f5c:	68 f9 29 80 00       	push   $0x8029f9
  800f61:	6a 37                	push   $0x37
  800f63:	68 db 29 80 00       	push   $0x8029db
  800f68:	e8 e0 f1 ff ff       	call   80014d <_panic>
}
  800f6d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f70:	c9                   	leave  
  800f71:	c3                   	ret    

00800f72 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f72:	55                   	push   %ebp
  800f73:	89 e5                	mov    %esp,%ebp
  800f75:	56                   	push   %esi
  800f76:	53                   	push   %ebx
  800f77:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
	// Set up page fault handler
	set_pgfault_handler(&pgfault);
  800f7a:	68 be 0e 80 00       	push   $0x800ebe
  800f7f:	e8 5d 12 00 00       	call   8021e1 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f84:	b8 07 00 00 00       	mov    $0x7,%eax
  800f89:	cd 30                	int    $0x30

	// Create child
	envid_t envid = sys_exofork();
  800f8b:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (envid < 0) {
  800f8e:	83 c4 10             	add    $0x10,%esp
  800f91:	85 c0                	test   %eax,%eax
  800f93:	79 12                	jns    800fa7 <fork+0x35>
		panic("sys_exofork: %e", envid);
  800f95:	50                   	push   %eax
  800f96:	68 0c 2a 80 00       	push   $0x802a0c
  800f9b:	6a 7c                	push   $0x7c
  800f9d:	68 db 29 80 00       	push   $0x8029db
  800fa2:	e8 a6 f1 ff ff       	call   80014d <_panic>
		return envid;
	}
	if (envid == 0) {
  800fa7:	85 c0                	test   %eax,%eax
  800fa9:	75 1e                	jne    800fc9 <fork+0x57>
		// We are the child.
		thisenv = &envs[ENVX(sys_getenvid())]; // Fix thisenv
  800fab:	e8 c0 fb ff ff       	call   800b70 <sys_getenvid>
  800fb0:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fb5:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800fb8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fbd:	a3 0c 40 80 00       	mov    %eax,0x80400c
		return 0;
  800fc2:	b8 00 00 00 00       	mov    $0x0,%eax
  800fc7:	eb 7d                	jmp    801046 <fork+0xd4>

	// Set page fault handler on the child.
	// The parent needs to do it, else the child wouldn't be able to handle
	// the fault when trying to access it's stack (which happens as soon it starts)
	extern void _pgfault_upcall(void);
	sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);
  800fc9:	83 ec 04             	sub    $0x4,%esp
  800fcc:	6a 07                	push   $0x7
  800fce:	68 00 f0 bf ee       	push   $0xeebff000
  800fd3:	50                   	push   %eax
  800fd4:	e8 d5 fb ff ff       	call   800bae <sys_page_alloc>
	sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  800fd9:	83 c4 08             	add    $0x8,%esp
  800fdc:	68 26 22 80 00       	push   $0x802226
  800fe1:	ff 75 f4             	pushl  -0xc(%ebp)
  800fe4:	e8 10 fd ff ff       	call   800cf9 <sys_env_set_pgfault_upcall>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  800fe9:	be 04 70 80 00       	mov    $0x807004,%esi
  800fee:	c1 ee 0c             	shr    $0xc,%esi
  800ff1:	83 c4 10             	add    $0x10,%esp
  800ff4:	bb 00 08 00 00       	mov    $0x800,%ebx
  800ff9:	eb 0d                	jmp    801008 <fork+0x96>
		duppage(envid, pn);
  800ffb:	89 da                	mov    %ebx,%edx
  800ffd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801000:	e8 b9 fd ff ff       	call   800dbe <duppage>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  801005:	83 c3 01             	add    $0x1,%ebx
  801008:	39 f3                	cmp    %esi,%ebx
  80100a:	76 ef                	jbe    800ffb <fork+0x89>
	}

	// Also copy the stack we are currently running on
	// I think it should loop from ustacktop to this page, since the stack
	// can have more than 1 page
	duppage(envid, ((uint32_t) &envid)/PGSIZE);
  80100c:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80100f:	c1 ea 0c             	shr    $0xc,%edx
  801012:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801015:	e8 a4 fd ff ff       	call   800dbe <duppage>

	// Start the child environmnet running
	int r;
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  80101a:	83 ec 08             	sub    $0x8,%esp
  80101d:	6a 02                	push   $0x2
  80101f:	ff 75 f4             	pushl  -0xc(%ebp)
  801022:	e8 4e fc ff ff       	call   800c75 <sys_env_set_status>
  801027:	83 c4 10             	add    $0x10,%esp
  80102a:	85 c0                	test   %eax,%eax
  80102c:	79 15                	jns    801043 <fork+0xd1>
		panic("sys_env_set_status: %e", r);
  80102e:	50                   	push   %eax
  80102f:	68 1c 2a 80 00       	push   $0x802a1c
  801034:	68 9c 00 00 00       	push   $0x9c
  801039:	68 db 29 80 00       	push   $0x8029db
  80103e:	e8 0a f1 ff ff       	call   80014d <_panic>
		return r;
	}

	return envid;
  801043:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  801046:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801049:	5b                   	pop    %ebx
  80104a:	5e                   	pop    %esi
  80104b:	5d                   	pop    %ebp
  80104c:	c3                   	ret    

0080104d <sfork>:

// Challenge!
int
sfork(void)
{
  80104d:	55                   	push   %ebp
  80104e:	89 e5                	mov    %esp,%ebp
  801050:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801053:	68 33 2a 80 00       	push   $0x802a33
  801058:	68 a7 00 00 00       	push   $0xa7
  80105d:	68 db 29 80 00       	push   $0x8029db
  801062:	e8 e6 f0 ff ff       	call   80014d <_panic>

00801067 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801067:	55                   	push   %ebp
  801068:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80106a:	8b 45 08             	mov    0x8(%ebp),%eax
  80106d:	05 00 00 00 30       	add    $0x30000000,%eax
  801072:	c1 e8 0c             	shr    $0xc,%eax
}
  801075:	5d                   	pop    %ebp
  801076:	c3                   	ret    

00801077 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801077:	55                   	push   %ebp
  801078:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80107a:	8b 45 08             	mov    0x8(%ebp),%eax
  80107d:	05 00 00 00 30       	add    $0x30000000,%eax
  801082:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801087:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80108c:	5d                   	pop    %ebp
  80108d:	c3                   	ret    

0080108e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80108e:	55                   	push   %ebp
  80108f:	89 e5                	mov    %esp,%ebp
  801091:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801094:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801099:	89 c2                	mov    %eax,%edx
  80109b:	c1 ea 16             	shr    $0x16,%edx
  80109e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010a5:	f6 c2 01             	test   $0x1,%dl
  8010a8:	74 11                	je     8010bb <fd_alloc+0x2d>
  8010aa:	89 c2                	mov    %eax,%edx
  8010ac:	c1 ea 0c             	shr    $0xc,%edx
  8010af:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010b6:	f6 c2 01             	test   $0x1,%dl
  8010b9:	75 09                	jne    8010c4 <fd_alloc+0x36>
			*fd_store = fd;
  8010bb:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8010c2:	eb 17                	jmp    8010db <fd_alloc+0x4d>
  8010c4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010c9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010ce:	75 c9                	jne    801099 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8010d0:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8010d6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8010db:	5d                   	pop    %ebp
  8010dc:	c3                   	ret    

008010dd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010dd:	55                   	push   %ebp
  8010de:	89 e5                	mov    %esp,%ebp
  8010e0:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010e3:	83 f8 1f             	cmp    $0x1f,%eax
  8010e6:	77 36                	ja     80111e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010e8:	c1 e0 0c             	shl    $0xc,%eax
  8010eb:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8010f0:	89 c2                	mov    %eax,%edx
  8010f2:	c1 ea 16             	shr    $0x16,%edx
  8010f5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010fc:	f6 c2 01             	test   $0x1,%dl
  8010ff:	74 24                	je     801125 <fd_lookup+0x48>
  801101:	89 c2                	mov    %eax,%edx
  801103:	c1 ea 0c             	shr    $0xc,%edx
  801106:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80110d:	f6 c2 01             	test   $0x1,%dl
  801110:	74 1a                	je     80112c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801112:	8b 55 0c             	mov    0xc(%ebp),%edx
  801115:	89 02                	mov    %eax,(%edx)
	return 0;
  801117:	b8 00 00 00 00       	mov    $0x0,%eax
  80111c:	eb 13                	jmp    801131 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80111e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801123:	eb 0c                	jmp    801131 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801125:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80112a:	eb 05                	jmp    801131 <fd_lookup+0x54>
  80112c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801131:	5d                   	pop    %ebp
  801132:	c3                   	ret    

00801133 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801133:	55                   	push   %ebp
  801134:	89 e5                	mov    %esp,%ebp
  801136:	83 ec 08             	sub    $0x8,%esp
  801139:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80113c:	ba cc 2a 80 00       	mov    $0x802acc,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801141:	eb 13                	jmp    801156 <dev_lookup+0x23>
  801143:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801146:	39 08                	cmp    %ecx,(%eax)
  801148:	75 0c                	jne    801156 <dev_lookup+0x23>
			*dev = devtab[i];
  80114a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80114d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80114f:	b8 00 00 00 00       	mov    $0x0,%eax
  801154:	eb 2e                	jmp    801184 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801156:	8b 02                	mov    (%edx),%eax
  801158:	85 c0                	test   %eax,%eax
  80115a:	75 e7                	jne    801143 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80115c:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801161:	8b 40 48             	mov    0x48(%eax),%eax
  801164:	83 ec 04             	sub    $0x4,%esp
  801167:	51                   	push   %ecx
  801168:	50                   	push   %eax
  801169:	68 4c 2a 80 00       	push   $0x802a4c
  80116e:	e8 b3 f0 ff ff       	call   800226 <cprintf>
	*dev = 0;
  801173:	8b 45 0c             	mov    0xc(%ebp),%eax
  801176:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80117c:	83 c4 10             	add    $0x10,%esp
  80117f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801184:	c9                   	leave  
  801185:	c3                   	ret    

00801186 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801186:	55                   	push   %ebp
  801187:	89 e5                	mov    %esp,%ebp
  801189:	56                   	push   %esi
  80118a:	53                   	push   %ebx
  80118b:	83 ec 10             	sub    $0x10,%esp
  80118e:	8b 75 08             	mov    0x8(%ebp),%esi
  801191:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801194:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801197:	50                   	push   %eax
  801198:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80119e:	c1 e8 0c             	shr    $0xc,%eax
  8011a1:	50                   	push   %eax
  8011a2:	e8 36 ff ff ff       	call   8010dd <fd_lookup>
  8011a7:	83 c4 08             	add    $0x8,%esp
  8011aa:	85 c0                	test   %eax,%eax
  8011ac:	78 05                	js     8011b3 <fd_close+0x2d>
	    || fd != fd2)
  8011ae:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8011b1:	74 0c                	je     8011bf <fd_close+0x39>
		return (must_exist ? r : 0);
  8011b3:	84 db                	test   %bl,%bl
  8011b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8011ba:	0f 44 c2             	cmove  %edx,%eax
  8011bd:	eb 41                	jmp    801200 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011bf:	83 ec 08             	sub    $0x8,%esp
  8011c2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011c5:	50                   	push   %eax
  8011c6:	ff 36                	pushl  (%esi)
  8011c8:	e8 66 ff ff ff       	call   801133 <dev_lookup>
  8011cd:	89 c3                	mov    %eax,%ebx
  8011cf:	83 c4 10             	add    $0x10,%esp
  8011d2:	85 c0                	test   %eax,%eax
  8011d4:	78 1a                	js     8011f0 <fd_close+0x6a>
		if (dev->dev_close)
  8011d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011d9:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8011dc:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8011e1:	85 c0                	test   %eax,%eax
  8011e3:	74 0b                	je     8011f0 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8011e5:	83 ec 0c             	sub    $0xc,%esp
  8011e8:	56                   	push   %esi
  8011e9:	ff d0                	call   *%eax
  8011eb:	89 c3                	mov    %eax,%ebx
  8011ed:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8011f0:	83 ec 08             	sub    $0x8,%esp
  8011f3:	56                   	push   %esi
  8011f4:	6a 00                	push   $0x0
  8011f6:	e8 38 fa ff ff       	call   800c33 <sys_page_unmap>
	return r;
  8011fb:	83 c4 10             	add    $0x10,%esp
  8011fe:	89 d8                	mov    %ebx,%eax
}
  801200:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801203:	5b                   	pop    %ebx
  801204:	5e                   	pop    %esi
  801205:	5d                   	pop    %ebp
  801206:	c3                   	ret    

00801207 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801207:	55                   	push   %ebp
  801208:	89 e5                	mov    %esp,%ebp
  80120a:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80120d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801210:	50                   	push   %eax
  801211:	ff 75 08             	pushl  0x8(%ebp)
  801214:	e8 c4 fe ff ff       	call   8010dd <fd_lookup>
  801219:	83 c4 08             	add    $0x8,%esp
  80121c:	85 c0                	test   %eax,%eax
  80121e:	78 10                	js     801230 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801220:	83 ec 08             	sub    $0x8,%esp
  801223:	6a 01                	push   $0x1
  801225:	ff 75 f4             	pushl  -0xc(%ebp)
  801228:	e8 59 ff ff ff       	call   801186 <fd_close>
  80122d:	83 c4 10             	add    $0x10,%esp
}
  801230:	c9                   	leave  
  801231:	c3                   	ret    

00801232 <close_all>:

void
close_all(void)
{
  801232:	55                   	push   %ebp
  801233:	89 e5                	mov    %esp,%ebp
  801235:	53                   	push   %ebx
  801236:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801239:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80123e:	83 ec 0c             	sub    $0xc,%esp
  801241:	53                   	push   %ebx
  801242:	e8 c0 ff ff ff       	call   801207 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801247:	83 c3 01             	add    $0x1,%ebx
  80124a:	83 c4 10             	add    $0x10,%esp
  80124d:	83 fb 20             	cmp    $0x20,%ebx
  801250:	75 ec                	jne    80123e <close_all+0xc>
		close(i);
}
  801252:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801255:	c9                   	leave  
  801256:	c3                   	ret    

00801257 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801257:	55                   	push   %ebp
  801258:	89 e5                	mov    %esp,%ebp
  80125a:	57                   	push   %edi
  80125b:	56                   	push   %esi
  80125c:	53                   	push   %ebx
  80125d:	83 ec 2c             	sub    $0x2c,%esp
  801260:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801263:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801266:	50                   	push   %eax
  801267:	ff 75 08             	pushl  0x8(%ebp)
  80126a:	e8 6e fe ff ff       	call   8010dd <fd_lookup>
  80126f:	83 c4 08             	add    $0x8,%esp
  801272:	85 c0                	test   %eax,%eax
  801274:	0f 88 c1 00 00 00    	js     80133b <dup+0xe4>
		return r;
	close(newfdnum);
  80127a:	83 ec 0c             	sub    $0xc,%esp
  80127d:	56                   	push   %esi
  80127e:	e8 84 ff ff ff       	call   801207 <close>

	newfd = INDEX2FD(newfdnum);
  801283:	89 f3                	mov    %esi,%ebx
  801285:	c1 e3 0c             	shl    $0xc,%ebx
  801288:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80128e:	83 c4 04             	add    $0x4,%esp
  801291:	ff 75 e4             	pushl  -0x1c(%ebp)
  801294:	e8 de fd ff ff       	call   801077 <fd2data>
  801299:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80129b:	89 1c 24             	mov    %ebx,(%esp)
  80129e:	e8 d4 fd ff ff       	call   801077 <fd2data>
  8012a3:	83 c4 10             	add    $0x10,%esp
  8012a6:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012a9:	89 f8                	mov    %edi,%eax
  8012ab:	c1 e8 16             	shr    $0x16,%eax
  8012ae:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012b5:	a8 01                	test   $0x1,%al
  8012b7:	74 37                	je     8012f0 <dup+0x99>
  8012b9:	89 f8                	mov    %edi,%eax
  8012bb:	c1 e8 0c             	shr    $0xc,%eax
  8012be:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012c5:	f6 c2 01             	test   $0x1,%dl
  8012c8:	74 26                	je     8012f0 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012ca:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012d1:	83 ec 0c             	sub    $0xc,%esp
  8012d4:	25 07 0e 00 00       	and    $0xe07,%eax
  8012d9:	50                   	push   %eax
  8012da:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012dd:	6a 00                	push   $0x0
  8012df:	57                   	push   %edi
  8012e0:	6a 00                	push   $0x0
  8012e2:	e8 0a f9 ff ff       	call   800bf1 <sys_page_map>
  8012e7:	89 c7                	mov    %eax,%edi
  8012e9:	83 c4 20             	add    $0x20,%esp
  8012ec:	85 c0                	test   %eax,%eax
  8012ee:	78 2e                	js     80131e <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012f0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8012f3:	89 d0                	mov    %edx,%eax
  8012f5:	c1 e8 0c             	shr    $0xc,%eax
  8012f8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012ff:	83 ec 0c             	sub    $0xc,%esp
  801302:	25 07 0e 00 00       	and    $0xe07,%eax
  801307:	50                   	push   %eax
  801308:	53                   	push   %ebx
  801309:	6a 00                	push   $0x0
  80130b:	52                   	push   %edx
  80130c:	6a 00                	push   $0x0
  80130e:	e8 de f8 ff ff       	call   800bf1 <sys_page_map>
  801313:	89 c7                	mov    %eax,%edi
  801315:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801318:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80131a:	85 ff                	test   %edi,%edi
  80131c:	79 1d                	jns    80133b <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80131e:	83 ec 08             	sub    $0x8,%esp
  801321:	53                   	push   %ebx
  801322:	6a 00                	push   $0x0
  801324:	e8 0a f9 ff ff       	call   800c33 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801329:	83 c4 08             	add    $0x8,%esp
  80132c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80132f:	6a 00                	push   $0x0
  801331:	e8 fd f8 ff ff       	call   800c33 <sys_page_unmap>
	return r;
  801336:	83 c4 10             	add    $0x10,%esp
  801339:	89 f8                	mov    %edi,%eax
}
  80133b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80133e:	5b                   	pop    %ebx
  80133f:	5e                   	pop    %esi
  801340:	5f                   	pop    %edi
  801341:	5d                   	pop    %ebp
  801342:	c3                   	ret    

00801343 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801343:	55                   	push   %ebp
  801344:	89 e5                	mov    %esp,%ebp
  801346:	53                   	push   %ebx
  801347:	83 ec 14             	sub    $0x14,%esp
  80134a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80134d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801350:	50                   	push   %eax
  801351:	53                   	push   %ebx
  801352:	e8 86 fd ff ff       	call   8010dd <fd_lookup>
  801357:	83 c4 08             	add    $0x8,%esp
  80135a:	89 c2                	mov    %eax,%edx
  80135c:	85 c0                	test   %eax,%eax
  80135e:	78 6d                	js     8013cd <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801360:	83 ec 08             	sub    $0x8,%esp
  801363:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801366:	50                   	push   %eax
  801367:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80136a:	ff 30                	pushl  (%eax)
  80136c:	e8 c2 fd ff ff       	call   801133 <dev_lookup>
  801371:	83 c4 10             	add    $0x10,%esp
  801374:	85 c0                	test   %eax,%eax
  801376:	78 4c                	js     8013c4 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801378:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80137b:	8b 42 08             	mov    0x8(%edx),%eax
  80137e:	83 e0 03             	and    $0x3,%eax
  801381:	83 f8 01             	cmp    $0x1,%eax
  801384:	75 21                	jne    8013a7 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801386:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80138b:	8b 40 48             	mov    0x48(%eax),%eax
  80138e:	83 ec 04             	sub    $0x4,%esp
  801391:	53                   	push   %ebx
  801392:	50                   	push   %eax
  801393:	68 90 2a 80 00       	push   $0x802a90
  801398:	e8 89 ee ff ff       	call   800226 <cprintf>
		return -E_INVAL;
  80139d:	83 c4 10             	add    $0x10,%esp
  8013a0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013a5:	eb 26                	jmp    8013cd <read+0x8a>
	}
	if (!dev->dev_read)
  8013a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013aa:	8b 40 08             	mov    0x8(%eax),%eax
  8013ad:	85 c0                	test   %eax,%eax
  8013af:	74 17                	je     8013c8 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013b1:	83 ec 04             	sub    $0x4,%esp
  8013b4:	ff 75 10             	pushl  0x10(%ebp)
  8013b7:	ff 75 0c             	pushl  0xc(%ebp)
  8013ba:	52                   	push   %edx
  8013bb:	ff d0                	call   *%eax
  8013bd:	89 c2                	mov    %eax,%edx
  8013bf:	83 c4 10             	add    $0x10,%esp
  8013c2:	eb 09                	jmp    8013cd <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013c4:	89 c2                	mov    %eax,%edx
  8013c6:	eb 05                	jmp    8013cd <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8013c8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8013cd:	89 d0                	mov    %edx,%eax
  8013cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013d2:	c9                   	leave  
  8013d3:	c3                   	ret    

008013d4 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013d4:	55                   	push   %ebp
  8013d5:	89 e5                	mov    %esp,%ebp
  8013d7:	57                   	push   %edi
  8013d8:	56                   	push   %esi
  8013d9:	53                   	push   %ebx
  8013da:	83 ec 0c             	sub    $0xc,%esp
  8013dd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013e0:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013e3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013e8:	eb 21                	jmp    80140b <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013ea:	83 ec 04             	sub    $0x4,%esp
  8013ed:	89 f0                	mov    %esi,%eax
  8013ef:	29 d8                	sub    %ebx,%eax
  8013f1:	50                   	push   %eax
  8013f2:	89 d8                	mov    %ebx,%eax
  8013f4:	03 45 0c             	add    0xc(%ebp),%eax
  8013f7:	50                   	push   %eax
  8013f8:	57                   	push   %edi
  8013f9:	e8 45 ff ff ff       	call   801343 <read>
		if (m < 0)
  8013fe:	83 c4 10             	add    $0x10,%esp
  801401:	85 c0                	test   %eax,%eax
  801403:	78 10                	js     801415 <readn+0x41>
			return m;
		if (m == 0)
  801405:	85 c0                	test   %eax,%eax
  801407:	74 0a                	je     801413 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801409:	01 c3                	add    %eax,%ebx
  80140b:	39 f3                	cmp    %esi,%ebx
  80140d:	72 db                	jb     8013ea <readn+0x16>
  80140f:	89 d8                	mov    %ebx,%eax
  801411:	eb 02                	jmp    801415 <readn+0x41>
  801413:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801415:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801418:	5b                   	pop    %ebx
  801419:	5e                   	pop    %esi
  80141a:	5f                   	pop    %edi
  80141b:	5d                   	pop    %ebp
  80141c:	c3                   	ret    

0080141d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80141d:	55                   	push   %ebp
  80141e:	89 e5                	mov    %esp,%ebp
  801420:	53                   	push   %ebx
  801421:	83 ec 14             	sub    $0x14,%esp
  801424:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801427:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80142a:	50                   	push   %eax
  80142b:	53                   	push   %ebx
  80142c:	e8 ac fc ff ff       	call   8010dd <fd_lookup>
  801431:	83 c4 08             	add    $0x8,%esp
  801434:	89 c2                	mov    %eax,%edx
  801436:	85 c0                	test   %eax,%eax
  801438:	78 68                	js     8014a2 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80143a:	83 ec 08             	sub    $0x8,%esp
  80143d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801440:	50                   	push   %eax
  801441:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801444:	ff 30                	pushl  (%eax)
  801446:	e8 e8 fc ff ff       	call   801133 <dev_lookup>
  80144b:	83 c4 10             	add    $0x10,%esp
  80144e:	85 c0                	test   %eax,%eax
  801450:	78 47                	js     801499 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801452:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801455:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801459:	75 21                	jne    80147c <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80145b:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801460:	8b 40 48             	mov    0x48(%eax),%eax
  801463:	83 ec 04             	sub    $0x4,%esp
  801466:	53                   	push   %ebx
  801467:	50                   	push   %eax
  801468:	68 ac 2a 80 00       	push   $0x802aac
  80146d:	e8 b4 ed ff ff       	call   800226 <cprintf>
		return -E_INVAL;
  801472:	83 c4 10             	add    $0x10,%esp
  801475:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80147a:	eb 26                	jmp    8014a2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80147c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80147f:	8b 52 0c             	mov    0xc(%edx),%edx
  801482:	85 d2                	test   %edx,%edx
  801484:	74 17                	je     80149d <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801486:	83 ec 04             	sub    $0x4,%esp
  801489:	ff 75 10             	pushl  0x10(%ebp)
  80148c:	ff 75 0c             	pushl  0xc(%ebp)
  80148f:	50                   	push   %eax
  801490:	ff d2                	call   *%edx
  801492:	89 c2                	mov    %eax,%edx
  801494:	83 c4 10             	add    $0x10,%esp
  801497:	eb 09                	jmp    8014a2 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801499:	89 c2                	mov    %eax,%edx
  80149b:	eb 05                	jmp    8014a2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80149d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8014a2:	89 d0                	mov    %edx,%eax
  8014a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014a7:	c9                   	leave  
  8014a8:	c3                   	ret    

008014a9 <seek>:

int
seek(int fdnum, off_t offset)
{
  8014a9:	55                   	push   %ebp
  8014aa:	89 e5                	mov    %esp,%ebp
  8014ac:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014af:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014b2:	50                   	push   %eax
  8014b3:	ff 75 08             	pushl  0x8(%ebp)
  8014b6:	e8 22 fc ff ff       	call   8010dd <fd_lookup>
  8014bb:	83 c4 08             	add    $0x8,%esp
  8014be:	85 c0                	test   %eax,%eax
  8014c0:	78 0e                	js     8014d0 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8014c2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014c5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014c8:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014cb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014d0:	c9                   	leave  
  8014d1:	c3                   	ret    

008014d2 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8014d2:	55                   	push   %ebp
  8014d3:	89 e5                	mov    %esp,%ebp
  8014d5:	53                   	push   %ebx
  8014d6:	83 ec 14             	sub    $0x14,%esp
  8014d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014dc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014df:	50                   	push   %eax
  8014e0:	53                   	push   %ebx
  8014e1:	e8 f7 fb ff ff       	call   8010dd <fd_lookup>
  8014e6:	83 c4 08             	add    $0x8,%esp
  8014e9:	89 c2                	mov    %eax,%edx
  8014eb:	85 c0                	test   %eax,%eax
  8014ed:	78 65                	js     801554 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014ef:	83 ec 08             	sub    $0x8,%esp
  8014f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014f5:	50                   	push   %eax
  8014f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014f9:	ff 30                	pushl  (%eax)
  8014fb:	e8 33 fc ff ff       	call   801133 <dev_lookup>
  801500:	83 c4 10             	add    $0x10,%esp
  801503:	85 c0                	test   %eax,%eax
  801505:	78 44                	js     80154b <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801507:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80150a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80150e:	75 21                	jne    801531 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801510:	a1 0c 40 80 00       	mov    0x80400c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801515:	8b 40 48             	mov    0x48(%eax),%eax
  801518:	83 ec 04             	sub    $0x4,%esp
  80151b:	53                   	push   %ebx
  80151c:	50                   	push   %eax
  80151d:	68 6c 2a 80 00       	push   $0x802a6c
  801522:	e8 ff ec ff ff       	call   800226 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801527:	83 c4 10             	add    $0x10,%esp
  80152a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80152f:	eb 23                	jmp    801554 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801531:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801534:	8b 52 18             	mov    0x18(%edx),%edx
  801537:	85 d2                	test   %edx,%edx
  801539:	74 14                	je     80154f <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80153b:	83 ec 08             	sub    $0x8,%esp
  80153e:	ff 75 0c             	pushl  0xc(%ebp)
  801541:	50                   	push   %eax
  801542:	ff d2                	call   *%edx
  801544:	89 c2                	mov    %eax,%edx
  801546:	83 c4 10             	add    $0x10,%esp
  801549:	eb 09                	jmp    801554 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80154b:	89 c2                	mov    %eax,%edx
  80154d:	eb 05                	jmp    801554 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80154f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801554:	89 d0                	mov    %edx,%eax
  801556:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801559:	c9                   	leave  
  80155a:	c3                   	ret    

0080155b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80155b:	55                   	push   %ebp
  80155c:	89 e5                	mov    %esp,%ebp
  80155e:	53                   	push   %ebx
  80155f:	83 ec 14             	sub    $0x14,%esp
  801562:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801565:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801568:	50                   	push   %eax
  801569:	ff 75 08             	pushl  0x8(%ebp)
  80156c:	e8 6c fb ff ff       	call   8010dd <fd_lookup>
  801571:	83 c4 08             	add    $0x8,%esp
  801574:	89 c2                	mov    %eax,%edx
  801576:	85 c0                	test   %eax,%eax
  801578:	78 58                	js     8015d2 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80157a:	83 ec 08             	sub    $0x8,%esp
  80157d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801580:	50                   	push   %eax
  801581:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801584:	ff 30                	pushl  (%eax)
  801586:	e8 a8 fb ff ff       	call   801133 <dev_lookup>
  80158b:	83 c4 10             	add    $0x10,%esp
  80158e:	85 c0                	test   %eax,%eax
  801590:	78 37                	js     8015c9 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801592:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801595:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801599:	74 32                	je     8015cd <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80159b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80159e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015a5:	00 00 00 
	stat->st_isdir = 0;
  8015a8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015af:	00 00 00 
	stat->st_dev = dev;
  8015b2:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015b8:	83 ec 08             	sub    $0x8,%esp
  8015bb:	53                   	push   %ebx
  8015bc:	ff 75 f0             	pushl  -0x10(%ebp)
  8015bf:	ff 50 14             	call   *0x14(%eax)
  8015c2:	89 c2                	mov    %eax,%edx
  8015c4:	83 c4 10             	add    $0x10,%esp
  8015c7:	eb 09                	jmp    8015d2 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015c9:	89 c2                	mov    %eax,%edx
  8015cb:	eb 05                	jmp    8015d2 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8015cd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8015d2:	89 d0                	mov    %edx,%eax
  8015d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015d7:	c9                   	leave  
  8015d8:	c3                   	ret    

008015d9 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015d9:	55                   	push   %ebp
  8015da:	89 e5                	mov    %esp,%ebp
  8015dc:	56                   	push   %esi
  8015dd:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015de:	83 ec 08             	sub    $0x8,%esp
  8015e1:	6a 00                	push   $0x0
  8015e3:	ff 75 08             	pushl  0x8(%ebp)
  8015e6:	e8 0c 02 00 00       	call   8017f7 <open>
  8015eb:	89 c3                	mov    %eax,%ebx
  8015ed:	83 c4 10             	add    $0x10,%esp
  8015f0:	85 c0                	test   %eax,%eax
  8015f2:	78 1b                	js     80160f <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8015f4:	83 ec 08             	sub    $0x8,%esp
  8015f7:	ff 75 0c             	pushl  0xc(%ebp)
  8015fa:	50                   	push   %eax
  8015fb:	e8 5b ff ff ff       	call   80155b <fstat>
  801600:	89 c6                	mov    %eax,%esi
	close(fd);
  801602:	89 1c 24             	mov    %ebx,(%esp)
  801605:	e8 fd fb ff ff       	call   801207 <close>
	return r;
  80160a:	83 c4 10             	add    $0x10,%esp
  80160d:	89 f0                	mov    %esi,%eax
}
  80160f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801612:	5b                   	pop    %ebx
  801613:	5e                   	pop    %esi
  801614:	5d                   	pop    %ebp
  801615:	c3                   	ret    

00801616 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801616:	55                   	push   %ebp
  801617:	89 e5                	mov    %esp,%ebp
  801619:	56                   	push   %esi
  80161a:	53                   	push   %ebx
  80161b:	89 c6                	mov    %eax,%esi
  80161d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80161f:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801626:	75 12                	jne    80163a <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801628:	83 ec 0c             	sub    $0xc,%esp
  80162b:	6a 01                	push   $0x1
  80162d:	e8 e2 0c 00 00       	call   802314 <ipc_find_env>
  801632:	a3 00 40 80 00       	mov    %eax,0x804000
  801637:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80163a:	6a 07                	push   $0x7
  80163c:	68 00 50 80 00       	push   $0x805000
  801641:	56                   	push   %esi
  801642:	ff 35 00 40 80 00    	pushl  0x804000
  801648:	e8 73 0c 00 00       	call   8022c0 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80164d:	83 c4 0c             	add    $0xc,%esp
  801650:	6a 00                	push   $0x0
  801652:	53                   	push   %ebx
  801653:	6a 00                	push   $0x0
  801655:	e8 fd 0b 00 00       	call   802257 <ipc_recv>
}
  80165a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80165d:	5b                   	pop    %ebx
  80165e:	5e                   	pop    %esi
  80165f:	5d                   	pop    %ebp
  801660:	c3                   	ret    

00801661 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801661:	55                   	push   %ebp
  801662:	89 e5                	mov    %esp,%ebp
  801664:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801667:	8b 45 08             	mov    0x8(%ebp),%eax
  80166a:	8b 40 0c             	mov    0xc(%eax),%eax
  80166d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801672:	8b 45 0c             	mov    0xc(%ebp),%eax
  801675:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80167a:	ba 00 00 00 00       	mov    $0x0,%edx
  80167f:	b8 02 00 00 00       	mov    $0x2,%eax
  801684:	e8 8d ff ff ff       	call   801616 <fsipc>
}
  801689:	c9                   	leave  
  80168a:	c3                   	ret    

0080168b <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80168b:	55                   	push   %ebp
  80168c:	89 e5                	mov    %esp,%ebp
  80168e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801691:	8b 45 08             	mov    0x8(%ebp),%eax
  801694:	8b 40 0c             	mov    0xc(%eax),%eax
  801697:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80169c:	ba 00 00 00 00       	mov    $0x0,%edx
  8016a1:	b8 06 00 00 00       	mov    $0x6,%eax
  8016a6:	e8 6b ff ff ff       	call   801616 <fsipc>
}
  8016ab:	c9                   	leave  
  8016ac:	c3                   	ret    

008016ad <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016ad:	55                   	push   %ebp
  8016ae:	89 e5                	mov    %esp,%ebp
  8016b0:	53                   	push   %ebx
  8016b1:	83 ec 04             	sub    $0x4,%esp
  8016b4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ba:	8b 40 0c             	mov    0xc(%eax),%eax
  8016bd:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8016c7:	b8 05 00 00 00       	mov    $0x5,%eax
  8016cc:	e8 45 ff ff ff       	call   801616 <fsipc>
  8016d1:	85 c0                	test   %eax,%eax
  8016d3:	78 2c                	js     801701 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016d5:	83 ec 08             	sub    $0x8,%esp
  8016d8:	68 00 50 80 00       	push   $0x805000
  8016dd:	53                   	push   %ebx
  8016de:	e8 c8 f0 ff ff       	call   8007ab <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016e3:	a1 80 50 80 00       	mov    0x805080,%eax
  8016e8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016ee:	a1 84 50 80 00       	mov    0x805084,%eax
  8016f3:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8016f9:	83 c4 10             	add    $0x10,%esp
  8016fc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801701:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801704:	c9                   	leave  
  801705:	c3                   	ret    

00801706 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801706:	55                   	push   %ebp
  801707:	89 e5                	mov    %esp,%ebp
  801709:	53                   	push   %ebx
  80170a:	83 ec 08             	sub    $0x8,%esp
  80170d:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801710:	8b 55 08             	mov    0x8(%ebp),%edx
  801713:	8b 52 0c             	mov    0xc(%edx),%edx
  801716:	89 15 00 50 80 00    	mov    %edx,0x805000
  80171c:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801721:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  801726:	0f 46 d8             	cmovbe %eax,%ebx
	
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  801729:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  80172f:	53                   	push   %ebx
  801730:	ff 75 0c             	pushl  0xc(%ebp)
  801733:	68 08 50 80 00       	push   $0x805008
  801738:	e8 00 f2 ff ff       	call   80093d <memmove>

	
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) 
  80173d:	ba 00 00 00 00       	mov    $0x0,%edx
  801742:	b8 04 00 00 00       	mov    $0x4,%eax
  801747:	e8 ca fe ff ff       	call   801616 <fsipc>
  80174c:	83 c4 10             	add    $0x10,%esp
  80174f:	85 c0                	test   %eax,%eax
  801751:	78 1d                	js     801770 <devfile_write+0x6a>
		return r;
	assert(r <= n_real); 
  801753:	39 d8                	cmp    %ebx,%eax
  801755:	76 19                	jbe    801770 <devfile_write+0x6a>
  801757:	68 e0 2a 80 00       	push   $0x802ae0
  80175c:	68 ec 2a 80 00       	push   $0x802aec
  801761:	68 a3 00 00 00       	push   $0xa3
  801766:	68 01 2b 80 00       	push   $0x802b01
  80176b:	e8 dd e9 ff ff       	call   80014d <_panic>
	return r;
}
  801770:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801773:	c9                   	leave  
  801774:	c3                   	ret    

00801775 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801775:	55                   	push   %ebp
  801776:	89 e5                	mov    %esp,%ebp
  801778:	56                   	push   %esi
  801779:	53                   	push   %ebx
  80177a:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80177d:	8b 45 08             	mov    0x8(%ebp),%eax
  801780:	8b 40 0c             	mov    0xc(%eax),%eax
  801783:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801788:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80178e:	ba 00 00 00 00       	mov    $0x0,%edx
  801793:	b8 03 00 00 00       	mov    $0x3,%eax
  801798:	e8 79 fe ff ff       	call   801616 <fsipc>
  80179d:	89 c3                	mov    %eax,%ebx
  80179f:	85 c0                	test   %eax,%eax
  8017a1:	78 4b                	js     8017ee <devfile_read+0x79>
		return r;
	assert(r <= n);
  8017a3:	39 c6                	cmp    %eax,%esi
  8017a5:	73 16                	jae    8017bd <devfile_read+0x48>
  8017a7:	68 0c 2b 80 00       	push   $0x802b0c
  8017ac:	68 ec 2a 80 00       	push   $0x802aec
  8017b1:	6a 7c                	push   $0x7c
  8017b3:	68 01 2b 80 00       	push   $0x802b01
  8017b8:	e8 90 e9 ff ff       	call   80014d <_panic>
	assert(r <= PGSIZE);
  8017bd:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017c2:	7e 16                	jle    8017da <devfile_read+0x65>
  8017c4:	68 13 2b 80 00       	push   $0x802b13
  8017c9:	68 ec 2a 80 00       	push   $0x802aec
  8017ce:	6a 7d                	push   $0x7d
  8017d0:	68 01 2b 80 00       	push   $0x802b01
  8017d5:	e8 73 e9 ff ff       	call   80014d <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017da:	83 ec 04             	sub    $0x4,%esp
  8017dd:	50                   	push   %eax
  8017de:	68 00 50 80 00       	push   $0x805000
  8017e3:	ff 75 0c             	pushl  0xc(%ebp)
  8017e6:	e8 52 f1 ff ff       	call   80093d <memmove>
	return r;
  8017eb:	83 c4 10             	add    $0x10,%esp
}
  8017ee:	89 d8                	mov    %ebx,%eax
  8017f0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017f3:	5b                   	pop    %ebx
  8017f4:	5e                   	pop    %esi
  8017f5:	5d                   	pop    %ebp
  8017f6:	c3                   	ret    

008017f7 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8017f7:	55                   	push   %ebp
  8017f8:	89 e5                	mov    %esp,%ebp
  8017fa:	53                   	push   %ebx
  8017fb:	83 ec 20             	sub    $0x20,%esp
  8017fe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801801:	53                   	push   %ebx
  801802:	e8 6b ef ff ff       	call   800772 <strlen>
  801807:	83 c4 10             	add    $0x10,%esp
  80180a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80180f:	7f 67                	jg     801878 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801811:	83 ec 0c             	sub    $0xc,%esp
  801814:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801817:	50                   	push   %eax
  801818:	e8 71 f8 ff ff       	call   80108e <fd_alloc>
  80181d:	83 c4 10             	add    $0x10,%esp
		return r;
  801820:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801822:	85 c0                	test   %eax,%eax
  801824:	78 57                	js     80187d <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801826:	83 ec 08             	sub    $0x8,%esp
  801829:	53                   	push   %ebx
  80182a:	68 00 50 80 00       	push   $0x805000
  80182f:	e8 77 ef ff ff       	call   8007ab <strcpy>
	fsipcbuf.open.req_omode = mode;
  801834:	8b 45 0c             	mov    0xc(%ebp),%eax
  801837:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80183c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80183f:	b8 01 00 00 00       	mov    $0x1,%eax
  801844:	e8 cd fd ff ff       	call   801616 <fsipc>
  801849:	89 c3                	mov    %eax,%ebx
  80184b:	83 c4 10             	add    $0x10,%esp
  80184e:	85 c0                	test   %eax,%eax
  801850:	79 14                	jns    801866 <open+0x6f>
		fd_close(fd, 0);
  801852:	83 ec 08             	sub    $0x8,%esp
  801855:	6a 00                	push   $0x0
  801857:	ff 75 f4             	pushl  -0xc(%ebp)
  80185a:	e8 27 f9 ff ff       	call   801186 <fd_close>
		return r;
  80185f:	83 c4 10             	add    $0x10,%esp
  801862:	89 da                	mov    %ebx,%edx
  801864:	eb 17                	jmp    80187d <open+0x86>
	}

	return fd2num(fd);
  801866:	83 ec 0c             	sub    $0xc,%esp
  801869:	ff 75 f4             	pushl  -0xc(%ebp)
  80186c:	e8 f6 f7 ff ff       	call   801067 <fd2num>
  801871:	89 c2                	mov    %eax,%edx
  801873:	83 c4 10             	add    $0x10,%esp
  801876:	eb 05                	jmp    80187d <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801878:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80187d:	89 d0                	mov    %edx,%eax
  80187f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801882:	c9                   	leave  
  801883:	c3                   	ret    

00801884 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801884:	55                   	push   %ebp
  801885:	89 e5                	mov    %esp,%ebp
  801887:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80188a:	ba 00 00 00 00       	mov    $0x0,%edx
  80188f:	b8 08 00 00 00       	mov    $0x8,%eax
  801894:	e8 7d fd ff ff       	call   801616 <fsipc>
}
  801899:	c9                   	leave  
  80189a:	c3                   	ret    

0080189b <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  80189b:	55                   	push   %ebp
  80189c:	89 e5                	mov    %esp,%ebp
  80189e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8018a1:	68 1f 2b 80 00       	push   $0x802b1f
  8018a6:	ff 75 0c             	pushl  0xc(%ebp)
  8018a9:	e8 fd ee ff ff       	call   8007ab <strcpy>
	return 0;
}
  8018ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8018b3:	c9                   	leave  
  8018b4:	c3                   	ret    

008018b5 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8018b5:	55                   	push   %ebp
  8018b6:	89 e5                	mov    %esp,%ebp
  8018b8:	53                   	push   %ebx
  8018b9:	83 ec 10             	sub    $0x10,%esp
  8018bc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8018bf:	53                   	push   %ebx
  8018c0:	e8 88 0a 00 00       	call   80234d <pageref>
  8018c5:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  8018c8:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  8018cd:	83 f8 01             	cmp    $0x1,%eax
  8018d0:	75 10                	jne    8018e2 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  8018d2:	83 ec 0c             	sub    $0xc,%esp
  8018d5:	ff 73 0c             	pushl  0xc(%ebx)
  8018d8:	e8 c0 02 00 00       	call   801b9d <nsipc_close>
  8018dd:	89 c2                	mov    %eax,%edx
  8018df:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8018e2:	89 d0                	mov    %edx,%eax
  8018e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018e7:	c9                   	leave  
  8018e8:	c3                   	ret    

008018e9 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8018e9:	55                   	push   %ebp
  8018ea:	89 e5                	mov    %esp,%ebp
  8018ec:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8018ef:	6a 00                	push   $0x0
  8018f1:	ff 75 10             	pushl  0x10(%ebp)
  8018f4:	ff 75 0c             	pushl  0xc(%ebp)
  8018f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8018fa:	ff 70 0c             	pushl  0xc(%eax)
  8018fd:	e8 78 03 00 00       	call   801c7a <nsipc_send>
}
  801902:	c9                   	leave  
  801903:	c3                   	ret    

00801904 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801904:	55                   	push   %ebp
  801905:	89 e5                	mov    %esp,%ebp
  801907:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  80190a:	6a 00                	push   $0x0
  80190c:	ff 75 10             	pushl  0x10(%ebp)
  80190f:	ff 75 0c             	pushl  0xc(%ebp)
  801912:	8b 45 08             	mov    0x8(%ebp),%eax
  801915:	ff 70 0c             	pushl  0xc(%eax)
  801918:	e8 f1 02 00 00       	call   801c0e <nsipc_recv>
}
  80191d:	c9                   	leave  
  80191e:	c3                   	ret    

0080191f <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  80191f:	55                   	push   %ebp
  801920:	89 e5                	mov    %esp,%ebp
  801922:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801925:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801928:	52                   	push   %edx
  801929:	50                   	push   %eax
  80192a:	e8 ae f7 ff ff       	call   8010dd <fd_lookup>
  80192f:	83 c4 10             	add    $0x10,%esp
  801932:	85 c0                	test   %eax,%eax
  801934:	78 17                	js     80194d <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801936:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801939:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  80193f:	39 08                	cmp    %ecx,(%eax)
  801941:	75 05                	jne    801948 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801943:	8b 40 0c             	mov    0xc(%eax),%eax
  801946:	eb 05                	jmp    80194d <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801948:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  80194d:	c9                   	leave  
  80194e:	c3                   	ret    

0080194f <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  80194f:	55                   	push   %ebp
  801950:	89 e5                	mov    %esp,%ebp
  801952:	56                   	push   %esi
  801953:	53                   	push   %ebx
  801954:	83 ec 1c             	sub    $0x1c,%esp
  801957:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801959:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80195c:	50                   	push   %eax
  80195d:	e8 2c f7 ff ff       	call   80108e <fd_alloc>
  801962:	89 c3                	mov    %eax,%ebx
  801964:	83 c4 10             	add    $0x10,%esp
  801967:	85 c0                	test   %eax,%eax
  801969:	78 1b                	js     801986 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  80196b:	83 ec 04             	sub    $0x4,%esp
  80196e:	68 07 04 00 00       	push   $0x407
  801973:	ff 75 f4             	pushl  -0xc(%ebp)
  801976:	6a 00                	push   $0x0
  801978:	e8 31 f2 ff ff       	call   800bae <sys_page_alloc>
  80197d:	89 c3                	mov    %eax,%ebx
  80197f:	83 c4 10             	add    $0x10,%esp
  801982:	85 c0                	test   %eax,%eax
  801984:	79 10                	jns    801996 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801986:	83 ec 0c             	sub    $0xc,%esp
  801989:	56                   	push   %esi
  80198a:	e8 0e 02 00 00       	call   801b9d <nsipc_close>
		return r;
  80198f:	83 c4 10             	add    $0x10,%esp
  801992:	89 d8                	mov    %ebx,%eax
  801994:	eb 24                	jmp    8019ba <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801996:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80199c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80199f:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8019a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019a4:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8019ab:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8019ae:	83 ec 0c             	sub    $0xc,%esp
  8019b1:	50                   	push   %eax
  8019b2:	e8 b0 f6 ff ff       	call   801067 <fd2num>
  8019b7:	83 c4 10             	add    $0x10,%esp
}
  8019ba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019bd:	5b                   	pop    %ebx
  8019be:	5e                   	pop    %esi
  8019bf:	5d                   	pop    %ebp
  8019c0:	c3                   	ret    

008019c1 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8019c1:	55                   	push   %ebp
  8019c2:	89 e5                	mov    %esp,%ebp
  8019c4:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ca:	e8 50 ff ff ff       	call   80191f <fd2sockid>
		return r;
  8019cf:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019d1:	85 c0                	test   %eax,%eax
  8019d3:	78 1f                	js     8019f4 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8019d5:	83 ec 04             	sub    $0x4,%esp
  8019d8:	ff 75 10             	pushl  0x10(%ebp)
  8019db:	ff 75 0c             	pushl  0xc(%ebp)
  8019de:	50                   	push   %eax
  8019df:	e8 12 01 00 00       	call   801af6 <nsipc_accept>
  8019e4:	83 c4 10             	add    $0x10,%esp
		return r;
  8019e7:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8019e9:	85 c0                	test   %eax,%eax
  8019eb:	78 07                	js     8019f4 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  8019ed:	e8 5d ff ff ff       	call   80194f <alloc_sockfd>
  8019f2:	89 c1                	mov    %eax,%ecx
}
  8019f4:	89 c8                	mov    %ecx,%eax
  8019f6:	c9                   	leave  
  8019f7:	c3                   	ret    

008019f8 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8019f8:	55                   	push   %ebp
  8019f9:	89 e5                	mov    %esp,%ebp
  8019fb:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801a01:	e8 19 ff ff ff       	call   80191f <fd2sockid>
  801a06:	85 c0                	test   %eax,%eax
  801a08:	78 12                	js     801a1c <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801a0a:	83 ec 04             	sub    $0x4,%esp
  801a0d:	ff 75 10             	pushl  0x10(%ebp)
  801a10:	ff 75 0c             	pushl  0xc(%ebp)
  801a13:	50                   	push   %eax
  801a14:	e8 2d 01 00 00       	call   801b46 <nsipc_bind>
  801a19:	83 c4 10             	add    $0x10,%esp
}
  801a1c:	c9                   	leave  
  801a1d:	c3                   	ret    

00801a1e <shutdown>:

int
shutdown(int s, int how)
{
  801a1e:	55                   	push   %ebp
  801a1f:	89 e5                	mov    %esp,%ebp
  801a21:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a24:	8b 45 08             	mov    0x8(%ebp),%eax
  801a27:	e8 f3 fe ff ff       	call   80191f <fd2sockid>
  801a2c:	85 c0                	test   %eax,%eax
  801a2e:	78 0f                	js     801a3f <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801a30:	83 ec 08             	sub    $0x8,%esp
  801a33:	ff 75 0c             	pushl  0xc(%ebp)
  801a36:	50                   	push   %eax
  801a37:	e8 3f 01 00 00       	call   801b7b <nsipc_shutdown>
  801a3c:	83 c4 10             	add    $0x10,%esp
}
  801a3f:	c9                   	leave  
  801a40:	c3                   	ret    

00801a41 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801a41:	55                   	push   %ebp
  801a42:	89 e5                	mov    %esp,%ebp
  801a44:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a47:	8b 45 08             	mov    0x8(%ebp),%eax
  801a4a:	e8 d0 fe ff ff       	call   80191f <fd2sockid>
  801a4f:	85 c0                	test   %eax,%eax
  801a51:	78 12                	js     801a65 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801a53:	83 ec 04             	sub    $0x4,%esp
  801a56:	ff 75 10             	pushl  0x10(%ebp)
  801a59:	ff 75 0c             	pushl  0xc(%ebp)
  801a5c:	50                   	push   %eax
  801a5d:	e8 55 01 00 00       	call   801bb7 <nsipc_connect>
  801a62:	83 c4 10             	add    $0x10,%esp
}
  801a65:	c9                   	leave  
  801a66:	c3                   	ret    

00801a67 <listen>:

int
listen(int s, int backlog)
{
  801a67:	55                   	push   %ebp
  801a68:	89 e5                	mov    %esp,%ebp
  801a6a:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a6d:	8b 45 08             	mov    0x8(%ebp),%eax
  801a70:	e8 aa fe ff ff       	call   80191f <fd2sockid>
  801a75:	85 c0                	test   %eax,%eax
  801a77:	78 0f                	js     801a88 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801a79:	83 ec 08             	sub    $0x8,%esp
  801a7c:	ff 75 0c             	pushl  0xc(%ebp)
  801a7f:	50                   	push   %eax
  801a80:	e8 67 01 00 00       	call   801bec <nsipc_listen>
  801a85:	83 c4 10             	add    $0x10,%esp
}
  801a88:	c9                   	leave  
  801a89:	c3                   	ret    

00801a8a <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801a8a:	55                   	push   %ebp
  801a8b:	89 e5                	mov    %esp,%ebp
  801a8d:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801a90:	ff 75 10             	pushl  0x10(%ebp)
  801a93:	ff 75 0c             	pushl  0xc(%ebp)
  801a96:	ff 75 08             	pushl  0x8(%ebp)
  801a99:	e8 3a 02 00 00       	call   801cd8 <nsipc_socket>
  801a9e:	83 c4 10             	add    $0x10,%esp
  801aa1:	85 c0                	test   %eax,%eax
  801aa3:	78 05                	js     801aaa <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801aa5:	e8 a5 fe ff ff       	call   80194f <alloc_sockfd>
}
  801aaa:	c9                   	leave  
  801aab:	c3                   	ret    

00801aac <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801aac:	55                   	push   %ebp
  801aad:	89 e5                	mov    %esp,%ebp
  801aaf:	53                   	push   %ebx
  801ab0:	83 ec 04             	sub    $0x4,%esp
  801ab3:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801ab5:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801abc:	75 12                	jne    801ad0 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801abe:	83 ec 0c             	sub    $0xc,%esp
  801ac1:	6a 02                	push   $0x2
  801ac3:	e8 4c 08 00 00       	call   802314 <ipc_find_env>
  801ac8:	a3 04 40 80 00       	mov    %eax,0x804004
  801acd:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801ad0:	6a 07                	push   $0x7
  801ad2:	68 00 60 80 00       	push   $0x806000
  801ad7:	53                   	push   %ebx
  801ad8:	ff 35 04 40 80 00    	pushl  0x804004
  801ade:	e8 dd 07 00 00       	call   8022c0 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801ae3:	83 c4 0c             	add    $0xc,%esp
  801ae6:	6a 00                	push   $0x0
  801ae8:	6a 00                	push   $0x0
  801aea:	6a 00                	push   $0x0
  801aec:	e8 66 07 00 00       	call   802257 <ipc_recv>
}
  801af1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801af4:	c9                   	leave  
  801af5:	c3                   	ret    

00801af6 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801af6:	55                   	push   %ebp
  801af7:	89 e5                	mov    %esp,%ebp
  801af9:	56                   	push   %esi
  801afa:	53                   	push   %ebx
  801afb:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801afe:	8b 45 08             	mov    0x8(%ebp),%eax
  801b01:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801b06:	8b 06                	mov    (%esi),%eax
  801b08:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801b0d:	b8 01 00 00 00       	mov    $0x1,%eax
  801b12:	e8 95 ff ff ff       	call   801aac <nsipc>
  801b17:	89 c3                	mov    %eax,%ebx
  801b19:	85 c0                	test   %eax,%eax
  801b1b:	78 20                	js     801b3d <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801b1d:	83 ec 04             	sub    $0x4,%esp
  801b20:	ff 35 10 60 80 00    	pushl  0x806010
  801b26:	68 00 60 80 00       	push   $0x806000
  801b2b:	ff 75 0c             	pushl  0xc(%ebp)
  801b2e:	e8 0a ee ff ff       	call   80093d <memmove>
		*addrlen = ret->ret_addrlen;
  801b33:	a1 10 60 80 00       	mov    0x806010,%eax
  801b38:	89 06                	mov    %eax,(%esi)
  801b3a:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801b3d:	89 d8                	mov    %ebx,%eax
  801b3f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b42:	5b                   	pop    %ebx
  801b43:	5e                   	pop    %esi
  801b44:	5d                   	pop    %ebp
  801b45:	c3                   	ret    

00801b46 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801b46:	55                   	push   %ebp
  801b47:	89 e5                	mov    %esp,%ebp
  801b49:	53                   	push   %ebx
  801b4a:	83 ec 08             	sub    $0x8,%esp
  801b4d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801b50:	8b 45 08             	mov    0x8(%ebp),%eax
  801b53:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801b58:	53                   	push   %ebx
  801b59:	ff 75 0c             	pushl  0xc(%ebp)
  801b5c:	68 04 60 80 00       	push   $0x806004
  801b61:	e8 d7 ed ff ff       	call   80093d <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801b66:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801b6c:	b8 02 00 00 00       	mov    $0x2,%eax
  801b71:	e8 36 ff ff ff       	call   801aac <nsipc>
}
  801b76:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b79:	c9                   	leave  
  801b7a:	c3                   	ret    

00801b7b <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801b7b:	55                   	push   %ebp
  801b7c:	89 e5                	mov    %esp,%ebp
  801b7e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801b81:	8b 45 08             	mov    0x8(%ebp),%eax
  801b84:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801b89:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b8c:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801b91:	b8 03 00 00 00       	mov    $0x3,%eax
  801b96:	e8 11 ff ff ff       	call   801aac <nsipc>
}
  801b9b:	c9                   	leave  
  801b9c:	c3                   	ret    

00801b9d <nsipc_close>:

int
nsipc_close(int s)
{
  801b9d:	55                   	push   %ebp
  801b9e:	89 e5                	mov    %esp,%ebp
  801ba0:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801ba3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba6:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801bab:	b8 04 00 00 00       	mov    $0x4,%eax
  801bb0:	e8 f7 fe ff ff       	call   801aac <nsipc>
}
  801bb5:	c9                   	leave  
  801bb6:	c3                   	ret    

00801bb7 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801bb7:	55                   	push   %ebp
  801bb8:	89 e5                	mov    %esp,%ebp
  801bba:	53                   	push   %ebx
  801bbb:	83 ec 08             	sub    $0x8,%esp
  801bbe:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801bc1:	8b 45 08             	mov    0x8(%ebp),%eax
  801bc4:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801bc9:	53                   	push   %ebx
  801bca:	ff 75 0c             	pushl  0xc(%ebp)
  801bcd:	68 04 60 80 00       	push   $0x806004
  801bd2:	e8 66 ed ff ff       	call   80093d <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801bd7:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801bdd:	b8 05 00 00 00       	mov    $0x5,%eax
  801be2:	e8 c5 fe ff ff       	call   801aac <nsipc>
}
  801be7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bea:	c9                   	leave  
  801beb:	c3                   	ret    

00801bec <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801bec:	55                   	push   %ebp
  801bed:	89 e5                	mov    %esp,%ebp
  801bef:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801bf2:	8b 45 08             	mov    0x8(%ebp),%eax
  801bf5:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801bfa:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bfd:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801c02:	b8 06 00 00 00       	mov    $0x6,%eax
  801c07:	e8 a0 fe ff ff       	call   801aac <nsipc>
}
  801c0c:	c9                   	leave  
  801c0d:	c3                   	ret    

00801c0e <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801c0e:	55                   	push   %ebp
  801c0f:	89 e5                	mov    %esp,%ebp
  801c11:	56                   	push   %esi
  801c12:	53                   	push   %ebx
  801c13:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801c16:	8b 45 08             	mov    0x8(%ebp),%eax
  801c19:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801c1e:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801c24:	8b 45 14             	mov    0x14(%ebp),%eax
  801c27:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801c2c:	b8 07 00 00 00       	mov    $0x7,%eax
  801c31:	e8 76 fe ff ff       	call   801aac <nsipc>
  801c36:	89 c3                	mov    %eax,%ebx
  801c38:	85 c0                	test   %eax,%eax
  801c3a:	78 35                	js     801c71 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801c3c:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801c41:	7f 04                	jg     801c47 <nsipc_recv+0x39>
  801c43:	39 c6                	cmp    %eax,%esi
  801c45:	7d 16                	jge    801c5d <nsipc_recv+0x4f>
  801c47:	68 2b 2b 80 00       	push   $0x802b2b
  801c4c:	68 ec 2a 80 00       	push   $0x802aec
  801c51:	6a 62                	push   $0x62
  801c53:	68 40 2b 80 00       	push   $0x802b40
  801c58:	e8 f0 e4 ff ff       	call   80014d <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801c5d:	83 ec 04             	sub    $0x4,%esp
  801c60:	50                   	push   %eax
  801c61:	68 00 60 80 00       	push   $0x806000
  801c66:	ff 75 0c             	pushl  0xc(%ebp)
  801c69:	e8 cf ec ff ff       	call   80093d <memmove>
  801c6e:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801c71:	89 d8                	mov    %ebx,%eax
  801c73:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c76:	5b                   	pop    %ebx
  801c77:	5e                   	pop    %esi
  801c78:	5d                   	pop    %ebp
  801c79:	c3                   	ret    

00801c7a <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801c7a:	55                   	push   %ebp
  801c7b:	89 e5                	mov    %esp,%ebp
  801c7d:	53                   	push   %ebx
  801c7e:	83 ec 04             	sub    $0x4,%esp
  801c81:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801c84:	8b 45 08             	mov    0x8(%ebp),%eax
  801c87:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801c8c:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801c92:	7e 16                	jle    801caa <nsipc_send+0x30>
  801c94:	68 4c 2b 80 00       	push   $0x802b4c
  801c99:	68 ec 2a 80 00       	push   $0x802aec
  801c9e:	6a 6d                	push   $0x6d
  801ca0:	68 40 2b 80 00       	push   $0x802b40
  801ca5:	e8 a3 e4 ff ff       	call   80014d <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801caa:	83 ec 04             	sub    $0x4,%esp
  801cad:	53                   	push   %ebx
  801cae:	ff 75 0c             	pushl  0xc(%ebp)
  801cb1:	68 0c 60 80 00       	push   $0x80600c
  801cb6:	e8 82 ec ff ff       	call   80093d <memmove>
	nsipcbuf.send.req_size = size;
  801cbb:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801cc1:	8b 45 14             	mov    0x14(%ebp),%eax
  801cc4:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801cc9:	b8 08 00 00 00       	mov    $0x8,%eax
  801cce:	e8 d9 fd ff ff       	call   801aac <nsipc>
}
  801cd3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cd6:	c9                   	leave  
  801cd7:	c3                   	ret    

00801cd8 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801cd8:	55                   	push   %ebp
  801cd9:	89 e5                	mov    %esp,%ebp
  801cdb:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801cde:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce1:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801ce6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ce9:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801cee:	8b 45 10             	mov    0x10(%ebp),%eax
  801cf1:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801cf6:	b8 09 00 00 00       	mov    $0x9,%eax
  801cfb:	e8 ac fd ff ff       	call   801aac <nsipc>
}
  801d00:	c9                   	leave  
  801d01:	c3                   	ret    

00801d02 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801d02:	55                   	push   %ebp
  801d03:	89 e5                	mov    %esp,%ebp
  801d05:	56                   	push   %esi
  801d06:	53                   	push   %ebx
  801d07:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801d0a:	83 ec 0c             	sub    $0xc,%esp
  801d0d:	ff 75 08             	pushl  0x8(%ebp)
  801d10:	e8 62 f3 ff ff       	call   801077 <fd2data>
  801d15:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801d17:	83 c4 08             	add    $0x8,%esp
  801d1a:	68 58 2b 80 00       	push   $0x802b58
  801d1f:	53                   	push   %ebx
  801d20:	e8 86 ea ff ff       	call   8007ab <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801d25:	8b 46 04             	mov    0x4(%esi),%eax
  801d28:	2b 06                	sub    (%esi),%eax
  801d2a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801d30:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801d37:	00 00 00 
	stat->st_dev = &devpipe;
  801d3a:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801d41:	30 80 00 
	return 0;
}
  801d44:	b8 00 00 00 00       	mov    $0x0,%eax
  801d49:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d4c:	5b                   	pop    %ebx
  801d4d:	5e                   	pop    %esi
  801d4e:	5d                   	pop    %ebp
  801d4f:	c3                   	ret    

00801d50 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801d50:	55                   	push   %ebp
  801d51:	89 e5                	mov    %esp,%ebp
  801d53:	53                   	push   %ebx
  801d54:	83 ec 0c             	sub    $0xc,%esp
  801d57:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801d5a:	53                   	push   %ebx
  801d5b:	6a 00                	push   $0x0
  801d5d:	e8 d1 ee ff ff       	call   800c33 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801d62:	89 1c 24             	mov    %ebx,(%esp)
  801d65:	e8 0d f3 ff ff       	call   801077 <fd2data>
  801d6a:	83 c4 08             	add    $0x8,%esp
  801d6d:	50                   	push   %eax
  801d6e:	6a 00                	push   $0x0
  801d70:	e8 be ee ff ff       	call   800c33 <sys_page_unmap>
}
  801d75:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d78:	c9                   	leave  
  801d79:	c3                   	ret    

00801d7a <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801d7a:	55                   	push   %ebp
  801d7b:	89 e5                	mov    %esp,%ebp
  801d7d:	57                   	push   %edi
  801d7e:	56                   	push   %esi
  801d7f:	53                   	push   %ebx
  801d80:	83 ec 1c             	sub    $0x1c,%esp
  801d83:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801d86:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801d88:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801d8d:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801d90:	83 ec 0c             	sub    $0xc,%esp
  801d93:	ff 75 e0             	pushl  -0x20(%ebp)
  801d96:	e8 b2 05 00 00       	call   80234d <pageref>
  801d9b:	89 c3                	mov    %eax,%ebx
  801d9d:	89 3c 24             	mov    %edi,(%esp)
  801da0:	e8 a8 05 00 00       	call   80234d <pageref>
  801da5:	83 c4 10             	add    $0x10,%esp
  801da8:	39 c3                	cmp    %eax,%ebx
  801daa:	0f 94 c1             	sete   %cl
  801dad:	0f b6 c9             	movzbl %cl,%ecx
  801db0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801db3:	8b 15 0c 40 80 00    	mov    0x80400c,%edx
  801db9:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801dbc:	39 ce                	cmp    %ecx,%esi
  801dbe:	74 1b                	je     801ddb <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801dc0:	39 c3                	cmp    %eax,%ebx
  801dc2:	75 c4                	jne    801d88 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801dc4:	8b 42 58             	mov    0x58(%edx),%eax
  801dc7:	ff 75 e4             	pushl  -0x1c(%ebp)
  801dca:	50                   	push   %eax
  801dcb:	56                   	push   %esi
  801dcc:	68 5f 2b 80 00       	push   $0x802b5f
  801dd1:	e8 50 e4 ff ff       	call   800226 <cprintf>
  801dd6:	83 c4 10             	add    $0x10,%esp
  801dd9:	eb ad                	jmp    801d88 <_pipeisclosed+0xe>
	}
}
  801ddb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801dde:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801de1:	5b                   	pop    %ebx
  801de2:	5e                   	pop    %esi
  801de3:	5f                   	pop    %edi
  801de4:	5d                   	pop    %ebp
  801de5:	c3                   	ret    

00801de6 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801de6:	55                   	push   %ebp
  801de7:	89 e5                	mov    %esp,%ebp
  801de9:	57                   	push   %edi
  801dea:	56                   	push   %esi
  801deb:	53                   	push   %ebx
  801dec:	83 ec 28             	sub    $0x28,%esp
  801def:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801df2:	56                   	push   %esi
  801df3:	e8 7f f2 ff ff       	call   801077 <fd2data>
  801df8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801dfa:	83 c4 10             	add    $0x10,%esp
  801dfd:	bf 00 00 00 00       	mov    $0x0,%edi
  801e02:	eb 4b                	jmp    801e4f <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801e04:	89 da                	mov    %ebx,%edx
  801e06:	89 f0                	mov    %esi,%eax
  801e08:	e8 6d ff ff ff       	call   801d7a <_pipeisclosed>
  801e0d:	85 c0                	test   %eax,%eax
  801e0f:	75 48                	jne    801e59 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801e11:	e8 79 ed ff ff       	call   800b8f <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801e16:	8b 43 04             	mov    0x4(%ebx),%eax
  801e19:	8b 0b                	mov    (%ebx),%ecx
  801e1b:	8d 51 20             	lea    0x20(%ecx),%edx
  801e1e:	39 d0                	cmp    %edx,%eax
  801e20:	73 e2                	jae    801e04 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801e22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e25:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801e29:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801e2c:	89 c2                	mov    %eax,%edx
  801e2e:	c1 fa 1f             	sar    $0x1f,%edx
  801e31:	89 d1                	mov    %edx,%ecx
  801e33:	c1 e9 1b             	shr    $0x1b,%ecx
  801e36:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801e39:	83 e2 1f             	and    $0x1f,%edx
  801e3c:	29 ca                	sub    %ecx,%edx
  801e3e:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801e42:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801e46:	83 c0 01             	add    $0x1,%eax
  801e49:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e4c:	83 c7 01             	add    $0x1,%edi
  801e4f:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801e52:	75 c2                	jne    801e16 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801e54:	8b 45 10             	mov    0x10(%ebp),%eax
  801e57:	eb 05                	jmp    801e5e <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e59:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801e5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e61:	5b                   	pop    %ebx
  801e62:	5e                   	pop    %esi
  801e63:	5f                   	pop    %edi
  801e64:	5d                   	pop    %ebp
  801e65:	c3                   	ret    

00801e66 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e66:	55                   	push   %ebp
  801e67:	89 e5                	mov    %esp,%ebp
  801e69:	57                   	push   %edi
  801e6a:	56                   	push   %esi
  801e6b:	53                   	push   %ebx
  801e6c:	83 ec 18             	sub    $0x18,%esp
  801e6f:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801e72:	57                   	push   %edi
  801e73:	e8 ff f1 ff ff       	call   801077 <fd2data>
  801e78:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e7a:	83 c4 10             	add    $0x10,%esp
  801e7d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e82:	eb 3d                	jmp    801ec1 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801e84:	85 db                	test   %ebx,%ebx
  801e86:	74 04                	je     801e8c <devpipe_read+0x26>
				return i;
  801e88:	89 d8                	mov    %ebx,%eax
  801e8a:	eb 44                	jmp    801ed0 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801e8c:	89 f2                	mov    %esi,%edx
  801e8e:	89 f8                	mov    %edi,%eax
  801e90:	e8 e5 fe ff ff       	call   801d7a <_pipeisclosed>
  801e95:	85 c0                	test   %eax,%eax
  801e97:	75 32                	jne    801ecb <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801e99:	e8 f1 ec ff ff       	call   800b8f <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801e9e:	8b 06                	mov    (%esi),%eax
  801ea0:	3b 46 04             	cmp    0x4(%esi),%eax
  801ea3:	74 df                	je     801e84 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801ea5:	99                   	cltd   
  801ea6:	c1 ea 1b             	shr    $0x1b,%edx
  801ea9:	01 d0                	add    %edx,%eax
  801eab:	83 e0 1f             	and    $0x1f,%eax
  801eae:	29 d0                	sub    %edx,%eax
  801eb0:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801eb5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801eb8:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801ebb:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ebe:	83 c3 01             	add    $0x1,%ebx
  801ec1:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801ec4:	75 d8                	jne    801e9e <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801ec6:	8b 45 10             	mov    0x10(%ebp),%eax
  801ec9:	eb 05                	jmp    801ed0 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ecb:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801ed0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ed3:	5b                   	pop    %ebx
  801ed4:	5e                   	pop    %esi
  801ed5:	5f                   	pop    %edi
  801ed6:	5d                   	pop    %ebp
  801ed7:	c3                   	ret    

00801ed8 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801ed8:	55                   	push   %ebp
  801ed9:	89 e5                	mov    %esp,%ebp
  801edb:	56                   	push   %esi
  801edc:	53                   	push   %ebx
  801edd:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ee0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ee3:	50                   	push   %eax
  801ee4:	e8 a5 f1 ff ff       	call   80108e <fd_alloc>
  801ee9:	83 c4 10             	add    $0x10,%esp
  801eec:	89 c2                	mov    %eax,%edx
  801eee:	85 c0                	test   %eax,%eax
  801ef0:	0f 88 2c 01 00 00    	js     802022 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ef6:	83 ec 04             	sub    $0x4,%esp
  801ef9:	68 07 04 00 00       	push   $0x407
  801efe:	ff 75 f4             	pushl  -0xc(%ebp)
  801f01:	6a 00                	push   $0x0
  801f03:	e8 a6 ec ff ff       	call   800bae <sys_page_alloc>
  801f08:	83 c4 10             	add    $0x10,%esp
  801f0b:	89 c2                	mov    %eax,%edx
  801f0d:	85 c0                	test   %eax,%eax
  801f0f:	0f 88 0d 01 00 00    	js     802022 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801f15:	83 ec 0c             	sub    $0xc,%esp
  801f18:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f1b:	50                   	push   %eax
  801f1c:	e8 6d f1 ff ff       	call   80108e <fd_alloc>
  801f21:	89 c3                	mov    %eax,%ebx
  801f23:	83 c4 10             	add    $0x10,%esp
  801f26:	85 c0                	test   %eax,%eax
  801f28:	0f 88 e2 00 00 00    	js     802010 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f2e:	83 ec 04             	sub    $0x4,%esp
  801f31:	68 07 04 00 00       	push   $0x407
  801f36:	ff 75 f0             	pushl  -0x10(%ebp)
  801f39:	6a 00                	push   $0x0
  801f3b:	e8 6e ec ff ff       	call   800bae <sys_page_alloc>
  801f40:	89 c3                	mov    %eax,%ebx
  801f42:	83 c4 10             	add    $0x10,%esp
  801f45:	85 c0                	test   %eax,%eax
  801f47:	0f 88 c3 00 00 00    	js     802010 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801f4d:	83 ec 0c             	sub    $0xc,%esp
  801f50:	ff 75 f4             	pushl  -0xc(%ebp)
  801f53:	e8 1f f1 ff ff       	call   801077 <fd2data>
  801f58:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f5a:	83 c4 0c             	add    $0xc,%esp
  801f5d:	68 07 04 00 00       	push   $0x407
  801f62:	50                   	push   %eax
  801f63:	6a 00                	push   $0x0
  801f65:	e8 44 ec ff ff       	call   800bae <sys_page_alloc>
  801f6a:	89 c3                	mov    %eax,%ebx
  801f6c:	83 c4 10             	add    $0x10,%esp
  801f6f:	85 c0                	test   %eax,%eax
  801f71:	0f 88 89 00 00 00    	js     802000 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f77:	83 ec 0c             	sub    $0xc,%esp
  801f7a:	ff 75 f0             	pushl  -0x10(%ebp)
  801f7d:	e8 f5 f0 ff ff       	call   801077 <fd2data>
  801f82:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801f89:	50                   	push   %eax
  801f8a:	6a 00                	push   $0x0
  801f8c:	56                   	push   %esi
  801f8d:	6a 00                	push   $0x0
  801f8f:	e8 5d ec ff ff       	call   800bf1 <sys_page_map>
  801f94:	89 c3                	mov    %eax,%ebx
  801f96:	83 c4 20             	add    $0x20,%esp
  801f99:	85 c0                	test   %eax,%eax
  801f9b:	78 55                	js     801ff2 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801f9d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fa3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fa6:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801fa8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fab:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801fb2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fb8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fbb:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801fbd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fc0:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801fc7:	83 ec 0c             	sub    $0xc,%esp
  801fca:	ff 75 f4             	pushl  -0xc(%ebp)
  801fcd:	e8 95 f0 ff ff       	call   801067 <fd2num>
  801fd2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801fd5:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801fd7:	83 c4 04             	add    $0x4,%esp
  801fda:	ff 75 f0             	pushl  -0x10(%ebp)
  801fdd:	e8 85 f0 ff ff       	call   801067 <fd2num>
  801fe2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801fe5:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801fe8:	83 c4 10             	add    $0x10,%esp
  801feb:	ba 00 00 00 00       	mov    $0x0,%edx
  801ff0:	eb 30                	jmp    802022 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801ff2:	83 ec 08             	sub    $0x8,%esp
  801ff5:	56                   	push   %esi
  801ff6:	6a 00                	push   $0x0
  801ff8:	e8 36 ec ff ff       	call   800c33 <sys_page_unmap>
  801ffd:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802000:	83 ec 08             	sub    $0x8,%esp
  802003:	ff 75 f0             	pushl  -0x10(%ebp)
  802006:	6a 00                	push   $0x0
  802008:	e8 26 ec ff ff       	call   800c33 <sys_page_unmap>
  80200d:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802010:	83 ec 08             	sub    $0x8,%esp
  802013:	ff 75 f4             	pushl  -0xc(%ebp)
  802016:	6a 00                	push   $0x0
  802018:	e8 16 ec ff ff       	call   800c33 <sys_page_unmap>
  80201d:	83 c4 10             	add    $0x10,%esp
  802020:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802022:	89 d0                	mov    %edx,%eax
  802024:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802027:	5b                   	pop    %ebx
  802028:	5e                   	pop    %esi
  802029:	5d                   	pop    %ebp
  80202a:	c3                   	ret    

0080202b <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80202b:	55                   	push   %ebp
  80202c:	89 e5                	mov    %esp,%ebp
  80202e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802031:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802034:	50                   	push   %eax
  802035:	ff 75 08             	pushl  0x8(%ebp)
  802038:	e8 a0 f0 ff ff       	call   8010dd <fd_lookup>
  80203d:	83 c4 10             	add    $0x10,%esp
  802040:	85 c0                	test   %eax,%eax
  802042:	78 18                	js     80205c <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802044:	83 ec 0c             	sub    $0xc,%esp
  802047:	ff 75 f4             	pushl  -0xc(%ebp)
  80204a:	e8 28 f0 ff ff       	call   801077 <fd2data>
	return _pipeisclosed(fd, p);
  80204f:	89 c2                	mov    %eax,%edx
  802051:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802054:	e8 21 fd ff ff       	call   801d7a <_pipeisclosed>
  802059:	83 c4 10             	add    $0x10,%esp
}
  80205c:	c9                   	leave  
  80205d:	c3                   	ret    

0080205e <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80205e:	55                   	push   %ebp
  80205f:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802061:	b8 00 00 00 00       	mov    $0x0,%eax
  802066:	5d                   	pop    %ebp
  802067:	c3                   	ret    

00802068 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802068:	55                   	push   %ebp
  802069:	89 e5                	mov    %esp,%ebp
  80206b:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80206e:	68 77 2b 80 00       	push   $0x802b77
  802073:	ff 75 0c             	pushl  0xc(%ebp)
  802076:	e8 30 e7 ff ff       	call   8007ab <strcpy>
	return 0;
}
  80207b:	b8 00 00 00 00       	mov    $0x0,%eax
  802080:	c9                   	leave  
  802081:	c3                   	ret    

00802082 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802082:	55                   	push   %ebp
  802083:	89 e5                	mov    %esp,%ebp
  802085:	57                   	push   %edi
  802086:	56                   	push   %esi
  802087:	53                   	push   %ebx
  802088:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80208e:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802093:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802099:	eb 2d                	jmp    8020c8 <devcons_write+0x46>
		m = n - tot;
  80209b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80209e:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8020a0:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8020a3:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8020a8:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8020ab:	83 ec 04             	sub    $0x4,%esp
  8020ae:	53                   	push   %ebx
  8020af:	03 45 0c             	add    0xc(%ebp),%eax
  8020b2:	50                   	push   %eax
  8020b3:	57                   	push   %edi
  8020b4:	e8 84 e8 ff ff       	call   80093d <memmove>
		sys_cputs(buf, m);
  8020b9:	83 c4 08             	add    $0x8,%esp
  8020bc:	53                   	push   %ebx
  8020bd:	57                   	push   %edi
  8020be:	e8 2f ea ff ff       	call   800af2 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020c3:	01 de                	add    %ebx,%esi
  8020c5:	83 c4 10             	add    $0x10,%esp
  8020c8:	89 f0                	mov    %esi,%eax
  8020ca:	3b 75 10             	cmp    0x10(%ebp),%esi
  8020cd:	72 cc                	jb     80209b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8020cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020d2:	5b                   	pop    %ebx
  8020d3:	5e                   	pop    %esi
  8020d4:	5f                   	pop    %edi
  8020d5:	5d                   	pop    %ebp
  8020d6:	c3                   	ret    

008020d7 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8020d7:	55                   	push   %ebp
  8020d8:	89 e5                	mov    %esp,%ebp
  8020da:	83 ec 08             	sub    $0x8,%esp
  8020dd:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8020e2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8020e6:	74 2a                	je     802112 <devcons_read+0x3b>
  8020e8:	eb 05                	jmp    8020ef <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8020ea:	e8 a0 ea ff ff       	call   800b8f <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8020ef:	e8 1c ea ff ff       	call   800b10 <sys_cgetc>
  8020f4:	85 c0                	test   %eax,%eax
  8020f6:	74 f2                	je     8020ea <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8020f8:	85 c0                	test   %eax,%eax
  8020fa:	78 16                	js     802112 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8020fc:	83 f8 04             	cmp    $0x4,%eax
  8020ff:	74 0c                	je     80210d <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802101:	8b 55 0c             	mov    0xc(%ebp),%edx
  802104:	88 02                	mov    %al,(%edx)
	return 1;
  802106:	b8 01 00 00 00       	mov    $0x1,%eax
  80210b:	eb 05                	jmp    802112 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80210d:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802112:	c9                   	leave  
  802113:	c3                   	ret    

00802114 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802114:	55                   	push   %ebp
  802115:	89 e5                	mov    %esp,%ebp
  802117:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80211a:	8b 45 08             	mov    0x8(%ebp),%eax
  80211d:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802120:	6a 01                	push   $0x1
  802122:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802125:	50                   	push   %eax
  802126:	e8 c7 e9 ff ff       	call   800af2 <sys_cputs>
}
  80212b:	83 c4 10             	add    $0x10,%esp
  80212e:	c9                   	leave  
  80212f:	c3                   	ret    

00802130 <getchar>:

int
getchar(void)
{
  802130:	55                   	push   %ebp
  802131:	89 e5                	mov    %esp,%ebp
  802133:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802136:	6a 01                	push   $0x1
  802138:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80213b:	50                   	push   %eax
  80213c:	6a 00                	push   $0x0
  80213e:	e8 00 f2 ff ff       	call   801343 <read>
	if (r < 0)
  802143:	83 c4 10             	add    $0x10,%esp
  802146:	85 c0                	test   %eax,%eax
  802148:	78 0f                	js     802159 <getchar+0x29>
		return r;
	if (r < 1)
  80214a:	85 c0                	test   %eax,%eax
  80214c:	7e 06                	jle    802154 <getchar+0x24>
		return -E_EOF;
	return c;
  80214e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802152:	eb 05                	jmp    802159 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802154:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802159:	c9                   	leave  
  80215a:	c3                   	ret    

0080215b <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80215b:	55                   	push   %ebp
  80215c:	89 e5                	mov    %esp,%ebp
  80215e:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802161:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802164:	50                   	push   %eax
  802165:	ff 75 08             	pushl  0x8(%ebp)
  802168:	e8 70 ef ff ff       	call   8010dd <fd_lookup>
  80216d:	83 c4 10             	add    $0x10,%esp
  802170:	85 c0                	test   %eax,%eax
  802172:	78 11                	js     802185 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802174:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802177:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80217d:	39 10                	cmp    %edx,(%eax)
  80217f:	0f 94 c0             	sete   %al
  802182:	0f b6 c0             	movzbl %al,%eax
}
  802185:	c9                   	leave  
  802186:	c3                   	ret    

00802187 <opencons>:

int
opencons(void)
{
  802187:	55                   	push   %ebp
  802188:	89 e5                	mov    %esp,%ebp
  80218a:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80218d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802190:	50                   	push   %eax
  802191:	e8 f8 ee ff ff       	call   80108e <fd_alloc>
  802196:	83 c4 10             	add    $0x10,%esp
		return r;
  802199:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80219b:	85 c0                	test   %eax,%eax
  80219d:	78 3e                	js     8021dd <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80219f:	83 ec 04             	sub    $0x4,%esp
  8021a2:	68 07 04 00 00       	push   $0x407
  8021a7:	ff 75 f4             	pushl  -0xc(%ebp)
  8021aa:	6a 00                	push   $0x0
  8021ac:	e8 fd e9 ff ff       	call   800bae <sys_page_alloc>
  8021b1:	83 c4 10             	add    $0x10,%esp
		return r;
  8021b4:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8021b6:	85 c0                	test   %eax,%eax
  8021b8:	78 23                	js     8021dd <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8021ba:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8021c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021c3:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8021c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021c8:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8021cf:	83 ec 0c             	sub    $0xc,%esp
  8021d2:	50                   	push   %eax
  8021d3:	e8 8f ee ff ff       	call   801067 <fd2num>
  8021d8:	89 c2                	mov    %eax,%edx
  8021da:	83 c4 10             	add    $0x10,%esp
}
  8021dd:	89 d0                	mov    %edx,%eax
  8021df:	c9                   	leave  
  8021e0:	c3                   	ret    

008021e1 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8021e1:	55                   	push   %ebp
  8021e2:	89 e5                	mov    %esp,%ebp
  8021e4:	53                   	push   %ebx
  8021e5:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  8021e8:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8021ef:	75 28                	jne    802219 <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  8021f1:	e8 7a e9 ff ff       	call   800b70 <sys_getenvid>
  8021f6:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_U | PTE_W);
  8021f8:	83 ec 04             	sub    $0x4,%esp
  8021fb:	6a 06                	push   $0x6
  8021fd:	68 00 f0 bf ee       	push   $0xeebff000
  802202:	50                   	push   %eax
  802203:	e8 a6 e9 ff ff       	call   800bae <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  802208:	83 c4 08             	add    $0x8,%esp
  80220b:	68 26 22 80 00       	push   $0x802226
  802210:	53                   	push   %ebx
  802211:	e8 e3 ea ff ff       	call   800cf9 <sys_env_set_pgfault_upcall>
  802216:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802219:	8b 45 08             	mov    0x8(%ebp),%eax
  80221c:	a3 00 70 80 00       	mov    %eax,0x807000
}
  802221:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802224:	c9                   	leave  
  802225:	c3                   	ret    

00802226 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802226:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802227:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  80222c:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80222e:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	# My method is different. Copy the values to the other stack
	# in a convinient way, and then pop everything.
	movl %esp, %ebp		# ebp refers to the exception stack
  802231:	89 e5                	mov    %esp,%ebp
	movl 48(%ebp), %esp 	# go to other stack
  802233:	8b 65 30             	mov    0x30(%ebp),%esp

	pushl 40(%ebp)		# eip - ORDER SWITCHED WITH EFLAGS
  802236:	ff 75 28             	pushl  0x28(%ebp)
	pushl 44(%ebp)      	# eflags
  802239:	ff 75 2c             	pushl  0x2c(%ebp)
	pushl 36(%ebp)		# all the 8 remaining regs
  80223c:	ff 75 24             	pushl  0x24(%ebp)
	pushl 32(%ebp)
  80223f:	ff 75 20             	pushl  0x20(%ebp)
	pushl 28(%ebp)
  802242:	ff 75 1c             	pushl  0x1c(%ebp)
	pushl 24(%ebp)
  802245:	ff 75 18             	pushl  0x18(%ebp)
	pushl 20(%ebp)
  802248:	ff 75 14             	pushl  0x14(%ebp)
	pushl 16(%ebp)
  80224b:	ff 75 10             	pushl  0x10(%ebp)
	pushl 12(%ebp)
  80224e:	ff 75 0c             	pushl  0xc(%ebp)
	pushl 8(%ebp)
  802251:	ff 75 08             	pushl  0x8(%ebp)

	popal			# now just pop everything!
  802254:	61                   	popa   
	popfl
  802255:	9d                   	popf   
	ret
  802256:	c3                   	ret    

00802257 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802257:	55                   	push   %ebp
  802258:	89 e5                	mov    %esp,%ebp
  80225a:	56                   	push   %esi
  80225b:	53                   	push   %ebx
  80225c:	8b 75 08             	mov    0x8(%ebp),%esi
  80225f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802262:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  802265:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  802267:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  80226c:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  80226f:	83 ec 0c             	sub    $0xc,%esp
  802272:	50                   	push   %eax
  802273:	e8 e6 ea ff ff       	call   800d5e <sys_ipc_recv>

	if (r < 0) {
  802278:	83 c4 10             	add    $0x10,%esp
  80227b:	85 c0                	test   %eax,%eax
  80227d:	79 16                	jns    802295 <ipc_recv+0x3e>
		if (from_env_store)
  80227f:	85 f6                	test   %esi,%esi
  802281:	74 06                	je     802289 <ipc_recv+0x32>
			*from_env_store = 0;
  802283:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  802289:	85 db                	test   %ebx,%ebx
  80228b:	74 2c                	je     8022b9 <ipc_recv+0x62>
			*perm_store = 0;
  80228d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802293:	eb 24                	jmp    8022b9 <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  802295:	85 f6                	test   %esi,%esi
  802297:	74 0a                	je     8022a3 <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  802299:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80229e:	8b 40 74             	mov    0x74(%eax),%eax
  8022a1:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  8022a3:	85 db                	test   %ebx,%ebx
  8022a5:	74 0a                	je     8022b1 <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  8022a7:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8022ac:	8b 40 78             	mov    0x78(%eax),%eax
  8022af:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  8022b1:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8022b6:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  8022b9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022bc:	5b                   	pop    %ebx
  8022bd:	5e                   	pop    %esi
  8022be:	5d                   	pop    %ebp
  8022bf:	c3                   	ret    

008022c0 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8022c0:	55                   	push   %ebp
  8022c1:	89 e5                	mov    %esp,%ebp
  8022c3:	57                   	push   %edi
  8022c4:	56                   	push   %esi
  8022c5:	53                   	push   %ebx
  8022c6:	83 ec 0c             	sub    $0xc,%esp
  8022c9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8022cc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8022cf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  8022d2:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  8022d4:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  8022d9:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  8022dc:	ff 75 14             	pushl  0x14(%ebp)
  8022df:	53                   	push   %ebx
  8022e0:	56                   	push   %esi
  8022e1:	57                   	push   %edi
  8022e2:	e8 54 ea ff ff       	call   800d3b <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  8022e7:	83 c4 10             	add    $0x10,%esp
  8022ea:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8022ed:	75 07                	jne    8022f6 <ipc_send+0x36>
			sys_yield();
  8022ef:	e8 9b e8 ff ff       	call   800b8f <sys_yield>
  8022f4:	eb e6                	jmp    8022dc <ipc_send+0x1c>
		} else if (r < 0) {
  8022f6:	85 c0                	test   %eax,%eax
  8022f8:	79 12                	jns    80230c <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  8022fa:	50                   	push   %eax
  8022fb:	68 83 2b 80 00       	push   $0x802b83
  802300:	6a 51                	push   $0x51
  802302:	68 90 2b 80 00       	push   $0x802b90
  802307:	e8 41 de ff ff       	call   80014d <_panic>
		}
	}
}
  80230c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80230f:	5b                   	pop    %ebx
  802310:	5e                   	pop    %esi
  802311:	5f                   	pop    %edi
  802312:	5d                   	pop    %ebp
  802313:	c3                   	ret    

00802314 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802314:	55                   	push   %ebp
  802315:	89 e5                	mov    %esp,%ebp
  802317:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80231a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80231f:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802322:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802328:	8b 52 50             	mov    0x50(%edx),%edx
  80232b:	39 ca                	cmp    %ecx,%edx
  80232d:	75 0d                	jne    80233c <ipc_find_env+0x28>
			return envs[i].env_id;
  80232f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802332:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802337:	8b 40 48             	mov    0x48(%eax),%eax
  80233a:	eb 0f                	jmp    80234b <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80233c:	83 c0 01             	add    $0x1,%eax
  80233f:	3d 00 04 00 00       	cmp    $0x400,%eax
  802344:	75 d9                	jne    80231f <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802346:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80234b:	5d                   	pop    %ebp
  80234c:	c3                   	ret    

0080234d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80234d:	55                   	push   %ebp
  80234e:	89 e5                	mov    %esp,%ebp
  802350:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802353:	89 d0                	mov    %edx,%eax
  802355:	c1 e8 16             	shr    $0x16,%eax
  802358:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80235f:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802364:	f6 c1 01             	test   $0x1,%cl
  802367:	74 1d                	je     802386 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802369:	c1 ea 0c             	shr    $0xc,%edx
  80236c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802373:	f6 c2 01             	test   $0x1,%dl
  802376:	74 0e                	je     802386 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802378:	c1 ea 0c             	shr    $0xc,%edx
  80237b:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802382:	ef 
  802383:	0f b7 c0             	movzwl %ax,%eax
}
  802386:	5d                   	pop    %ebp
  802387:	c3                   	ret    
  802388:	66 90                	xchg   %ax,%ax
  80238a:	66 90                	xchg   %ax,%ax
  80238c:	66 90                	xchg   %ax,%ax
  80238e:	66 90                	xchg   %ax,%ax

00802390 <__udivdi3>:
  802390:	55                   	push   %ebp
  802391:	57                   	push   %edi
  802392:	56                   	push   %esi
  802393:	53                   	push   %ebx
  802394:	83 ec 1c             	sub    $0x1c,%esp
  802397:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80239b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80239f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8023a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8023a7:	85 f6                	test   %esi,%esi
  8023a9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023ad:	89 ca                	mov    %ecx,%edx
  8023af:	89 f8                	mov    %edi,%eax
  8023b1:	75 3d                	jne    8023f0 <__udivdi3+0x60>
  8023b3:	39 cf                	cmp    %ecx,%edi
  8023b5:	0f 87 c5 00 00 00    	ja     802480 <__udivdi3+0xf0>
  8023bb:	85 ff                	test   %edi,%edi
  8023bd:	89 fd                	mov    %edi,%ebp
  8023bf:	75 0b                	jne    8023cc <__udivdi3+0x3c>
  8023c1:	b8 01 00 00 00       	mov    $0x1,%eax
  8023c6:	31 d2                	xor    %edx,%edx
  8023c8:	f7 f7                	div    %edi
  8023ca:	89 c5                	mov    %eax,%ebp
  8023cc:	89 c8                	mov    %ecx,%eax
  8023ce:	31 d2                	xor    %edx,%edx
  8023d0:	f7 f5                	div    %ebp
  8023d2:	89 c1                	mov    %eax,%ecx
  8023d4:	89 d8                	mov    %ebx,%eax
  8023d6:	89 cf                	mov    %ecx,%edi
  8023d8:	f7 f5                	div    %ebp
  8023da:	89 c3                	mov    %eax,%ebx
  8023dc:	89 d8                	mov    %ebx,%eax
  8023de:	89 fa                	mov    %edi,%edx
  8023e0:	83 c4 1c             	add    $0x1c,%esp
  8023e3:	5b                   	pop    %ebx
  8023e4:	5e                   	pop    %esi
  8023e5:	5f                   	pop    %edi
  8023e6:	5d                   	pop    %ebp
  8023e7:	c3                   	ret    
  8023e8:	90                   	nop
  8023e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023f0:	39 ce                	cmp    %ecx,%esi
  8023f2:	77 74                	ja     802468 <__udivdi3+0xd8>
  8023f4:	0f bd fe             	bsr    %esi,%edi
  8023f7:	83 f7 1f             	xor    $0x1f,%edi
  8023fa:	0f 84 98 00 00 00    	je     802498 <__udivdi3+0x108>
  802400:	bb 20 00 00 00       	mov    $0x20,%ebx
  802405:	89 f9                	mov    %edi,%ecx
  802407:	89 c5                	mov    %eax,%ebp
  802409:	29 fb                	sub    %edi,%ebx
  80240b:	d3 e6                	shl    %cl,%esi
  80240d:	89 d9                	mov    %ebx,%ecx
  80240f:	d3 ed                	shr    %cl,%ebp
  802411:	89 f9                	mov    %edi,%ecx
  802413:	d3 e0                	shl    %cl,%eax
  802415:	09 ee                	or     %ebp,%esi
  802417:	89 d9                	mov    %ebx,%ecx
  802419:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80241d:	89 d5                	mov    %edx,%ebp
  80241f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802423:	d3 ed                	shr    %cl,%ebp
  802425:	89 f9                	mov    %edi,%ecx
  802427:	d3 e2                	shl    %cl,%edx
  802429:	89 d9                	mov    %ebx,%ecx
  80242b:	d3 e8                	shr    %cl,%eax
  80242d:	09 c2                	or     %eax,%edx
  80242f:	89 d0                	mov    %edx,%eax
  802431:	89 ea                	mov    %ebp,%edx
  802433:	f7 f6                	div    %esi
  802435:	89 d5                	mov    %edx,%ebp
  802437:	89 c3                	mov    %eax,%ebx
  802439:	f7 64 24 0c          	mull   0xc(%esp)
  80243d:	39 d5                	cmp    %edx,%ebp
  80243f:	72 10                	jb     802451 <__udivdi3+0xc1>
  802441:	8b 74 24 08          	mov    0x8(%esp),%esi
  802445:	89 f9                	mov    %edi,%ecx
  802447:	d3 e6                	shl    %cl,%esi
  802449:	39 c6                	cmp    %eax,%esi
  80244b:	73 07                	jae    802454 <__udivdi3+0xc4>
  80244d:	39 d5                	cmp    %edx,%ebp
  80244f:	75 03                	jne    802454 <__udivdi3+0xc4>
  802451:	83 eb 01             	sub    $0x1,%ebx
  802454:	31 ff                	xor    %edi,%edi
  802456:	89 d8                	mov    %ebx,%eax
  802458:	89 fa                	mov    %edi,%edx
  80245a:	83 c4 1c             	add    $0x1c,%esp
  80245d:	5b                   	pop    %ebx
  80245e:	5e                   	pop    %esi
  80245f:	5f                   	pop    %edi
  802460:	5d                   	pop    %ebp
  802461:	c3                   	ret    
  802462:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802468:	31 ff                	xor    %edi,%edi
  80246a:	31 db                	xor    %ebx,%ebx
  80246c:	89 d8                	mov    %ebx,%eax
  80246e:	89 fa                	mov    %edi,%edx
  802470:	83 c4 1c             	add    $0x1c,%esp
  802473:	5b                   	pop    %ebx
  802474:	5e                   	pop    %esi
  802475:	5f                   	pop    %edi
  802476:	5d                   	pop    %ebp
  802477:	c3                   	ret    
  802478:	90                   	nop
  802479:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802480:	89 d8                	mov    %ebx,%eax
  802482:	f7 f7                	div    %edi
  802484:	31 ff                	xor    %edi,%edi
  802486:	89 c3                	mov    %eax,%ebx
  802488:	89 d8                	mov    %ebx,%eax
  80248a:	89 fa                	mov    %edi,%edx
  80248c:	83 c4 1c             	add    $0x1c,%esp
  80248f:	5b                   	pop    %ebx
  802490:	5e                   	pop    %esi
  802491:	5f                   	pop    %edi
  802492:	5d                   	pop    %ebp
  802493:	c3                   	ret    
  802494:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802498:	39 ce                	cmp    %ecx,%esi
  80249a:	72 0c                	jb     8024a8 <__udivdi3+0x118>
  80249c:	31 db                	xor    %ebx,%ebx
  80249e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8024a2:	0f 87 34 ff ff ff    	ja     8023dc <__udivdi3+0x4c>
  8024a8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8024ad:	e9 2a ff ff ff       	jmp    8023dc <__udivdi3+0x4c>
  8024b2:	66 90                	xchg   %ax,%ax
  8024b4:	66 90                	xchg   %ax,%ax
  8024b6:	66 90                	xchg   %ax,%ax
  8024b8:	66 90                	xchg   %ax,%ax
  8024ba:	66 90                	xchg   %ax,%ax
  8024bc:	66 90                	xchg   %ax,%ax
  8024be:	66 90                	xchg   %ax,%ax

008024c0 <__umoddi3>:
  8024c0:	55                   	push   %ebp
  8024c1:	57                   	push   %edi
  8024c2:	56                   	push   %esi
  8024c3:	53                   	push   %ebx
  8024c4:	83 ec 1c             	sub    $0x1c,%esp
  8024c7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8024cb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8024cf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8024d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8024d7:	85 d2                	test   %edx,%edx
  8024d9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8024dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024e1:	89 f3                	mov    %esi,%ebx
  8024e3:	89 3c 24             	mov    %edi,(%esp)
  8024e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024ea:	75 1c                	jne    802508 <__umoddi3+0x48>
  8024ec:	39 f7                	cmp    %esi,%edi
  8024ee:	76 50                	jbe    802540 <__umoddi3+0x80>
  8024f0:	89 c8                	mov    %ecx,%eax
  8024f2:	89 f2                	mov    %esi,%edx
  8024f4:	f7 f7                	div    %edi
  8024f6:	89 d0                	mov    %edx,%eax
  8024f8:	31 d2                	xor    %edx,%edx
  8024fa:	83 c4 1c             	add    $0x1c,%esp
  8024fd:	5b                   	pop    %ebx
  8024fe:	5e                   	pop    %esi
  8024ff:	5f                   	pop    %edi
  802500:	5d                   	pop    %ebp
  802501:	c3                   	ret    
  802502:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802508:	39 f2                	cmp    %esi,%edx
  80250a:	89 d0                	mov    %edx,%eax
  80250c:	77 52                	ja     802560 <__umoddi3+0xa0>
  80250e:	0f bd ea             	bsr    %edx,%ebp
  802511:	83 f5 1f             	xor    $0x1f,%ebp
  802514:	75 5a                	jne    802570 <__umoddi3+0xb0>
  802516:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80251a:	0f 82 e0 00 00 00    	jb     802600 <__umoddi3+0x140>
  802520:	39 0c 24             	cmp    %ecx,(%esp)
  802523:	0f 86 d7 00 00 00    	jbe    802600 <__umoddi3+0x140>
  802529:	8b 44 24 08          	mov    0x8(%esp),%eax
  80252d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802531:	83 c4 1c             	add    $0x1c,%esp
  802534:	5b                   	pop    %ebx
  802535:	5e                   	pop    %esi
  802536:	5f                   	pop    %edi
  802537:	5d                   	pop    %ebp
  802538:	c3                   	ret    
  802539:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802540:	85 ff                	test   %edi,%edi
  802542:	89 fd                	mov    %edi,%ebp
  802544:	75 0b                	jne    802551 <__umoddi3+0x91>
  802546:	b8 01 00 00 00       	mov    $0x1,%eax
  80254b:	31 d2                	xor    %edx,%edx
  80254d:	f7 f7                	div    %edi
  80254f:	89 c5                	mov    %eax,%ebp
  802551:	89 f0                	mov    %esi,%eax
  802553:	31 d2                	xor    %edx,%edx
  802555:	f7 f5                	div    %ebp
  802557:	89 c8                	mov    %ecx,%eax
  802559:	f7 f5                	div    %ebp
  80255b:	89 d0                	mov    %edx,%eax
  80255d:	eb 99                	jmp    8024f8 <__umoddi3+0x38>
  80255f:	90                   	nop
  802560:	89 c8                	mov    %ecx,%eax
  802562:	89 f2                	mov    %esi,%edx
  802564:	83 c4 1c             	add    $0x1c,%esp
  802567:	5b                   	pop    %ebx
  802568:	5e                   	pop    %esi
  802569:	5f                   	pop    %edi
  80256a:	5d                   	pop    %ebp
  80256b:	c3                   	ret    
  80256c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802570:	8b 34 24             	mov    (%esp),%esi
  802573:	bf 20 00 00 00       	mov    $0x20,%edi
  802578:	89 e9                	mov    %ebp,%ecx
  80257a:	29 ef                	sub    %ebp,%edi
  80257c:	d3 e0                	shl    %cl,%eax
  80257e:	89 f9                	mov    %edi,%ecx
  802580:	89 f2                	mov    %esi,%edx
  802582:	d3 ea                	shr    %cl,%edx
  802584:	89 e9                	mov    %ebp,%ecx
  802586:	09 c2                	or     %eax,%edx
  802588:	89 d8                	mov    %ebx,%eax
  80258a:	89 14 24             	mov    %edx,(%esp)
  80258d:	89 f2                	mov    %esi,%edx
  80258f:	d3 e2                	shl    %cl,%edx
  802591:	89 f9                	mov    %edi,%ecx
  802593:	89 54 24 04          	mov    %edx,0x4(%esp)
  802597:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80259b:	d3 e8                	shr    %cl,%eax
  80259d:	89 e9                	mov    %ebp,%ecx
  80259f:	89 c6                	mov    %eax,%esi
  8025a1:	d3 e3                	shl    %cl,%ebx
  8025a3:	89 f9                	mov    %edi,%ecx
  8025a5:	89 d0                	mov    %edx,%eax
  8025a7:	d3 e8                	shr    %cl,%eax
  8025a9:	89 e9                	mov    %ebp,%ecx
  8025ab:	09 d8                	or     %ebx,%eax
  8025ad:	89 d3                	mov    %edx,%ebx
  8025af:	89 f2                	mov    %esi,%edx
  8025b1:	f7 34 24             	divl   (%esp)
  8025b4:	89 d6                	mov    %edx,%esi
  8025b6:	d3 e3                	shl    %cl,%ebx
  8025b8:	f7 64 24 04          	mull   0x4(%esp)
  8025bc:	39 d6                	cmp    %edx,%esi
  8025be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8025c2:	89 d1                	mov    %edx,%ecx
  8025c4:	89 c3                	mov    %eax,%ebx
  8025c6:	72 08                	jb     8025d0 <__umoddi3+0x110>
  8025c8:	75 11                	jne    8025db <__umoddi3+0x11b>
  8025ca:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8025ce:	73 0b                	jae    8025db <__umoddi3+0x11b>
  8025d0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8025d4:	1b 14 24             	sbb    (%esp),%edx
  8025d7:	89 d1                	mov    %edx,%ecx
  8025d9:	89 c3                	mov    %eax,%ebx
  8025db:	8b 54 24 08          	mov    0x8(%esp),%edx
  8025df:	29 da                	sub    %ebx,%edx
  8025e1:	19 ce                	sbb    %ecx,%esi
  8025e3:	89 f9                	mov    %edi,%ecx
  8025e5:	89 f0                	mov    %esi,%eax
  8025e7:	d3 e0                	shl    %cl,%eax
  8025e9:	89 e9                	mov    %ebp,%ecx
  8025eb:	d3 ea                	shr    %cl,%edx
  8025ed:	89 e9                	mov    %ebp,%ecx
  8025ef:	d3 ee                	shr    %cl,%esi
  8025f1:	09 d0                	or     %edx,%eax
  8025f3:	89 f2                	mov    %esi,%edx
  8025f5:	83 c4 1c             	add    $0x1c,%esp
  8025f8:	5b                   	pop    %ebx
  8025f9:	5e                   	pop    %esi
  8025fa:	5f                   	pop    %edi
  8025fb:	5d                   	pop    %ebp
  8025fc:	c3                   	ret    
  8025fd:	8d 76 00             	lea    0x0(%esi),%esi
  802600:	29 f9                	sub    %edi,%ecx
  802602:	19 d6                	sbb    %edx,%esi
  802604:	89 74 24 04          	mov    %esi,0x4(%esp)
  802608:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80260c:	e9 18 ff ff ff       	jmp    802529 <__umoddi3+0x69>
