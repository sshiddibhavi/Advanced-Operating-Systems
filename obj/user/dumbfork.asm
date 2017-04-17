
obj/user/dumbfork.debug:     file format elf32-i386


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
  80002c:	e8 aa 01 00 00       	call   8001db <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <duppage>:
	}
}

void
duppage(envid_t dstenv, void *addr)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 75 08             	mov    0x8(%ebp),%esi
  80003b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	// This is NOT what you should do in your fork.
	if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  80003e:	83 ec 04             	sub    $0x4,%esp
  800041:	6a 07                	push   $0x7
  800043:	53                   	push   %ebx
  800044:	56                   	push   %esi
  800045:	e8 52 0c 00 00       	call   800c9c <sys_page_alloc>
  80004a:	83 c4 10             	add    $0x10,%esp
  80004d:	85 c0                	test   %eax,%eax
  80004f:	79 12                	jns    800063 <duppage+0x30>
		panic("sys_page_alloc: %e", r);
  800051:	50                   	push   %eax
  800052:	68 00 24 80 00       	push   $0x802400
  800057:	6a 20                	push   $0x20
  800059:	68 13 24 80 00       	push   $0x802413
  80005e:	e8 d8 01 00 00       	call   80023b <_panic>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800063:	83 ec 0c             	sub    $0xc,%esp
  800066:	6a 07                	push   $0x7
  800068:	68 00 00 40 00       	push   $0x400000
  80006d:	6a 00                	push   $0x0
  80006f:	53                   	push   %ebx
  800070:	56                   	push   %esi
  800071:	e8 69 0c 00 00       	call   800cdf <sys_page_map>
  800076:	83 c4 20             	add    $0x20,%esp
  800079:	85 c0                	test   %eax,%eax
  80007b:	79 12                	jns    80008f <duppage+0x5c>
		panic("sys_page_map: %e", r);
  80007d:	50                   	push   %eax
  80007e:	68 23 24 80 00       	push   $0x802423
  800083:	6a 22                	push   $0x22
  800085:	68 13 24 80 00       	push   $0x802413
  80008a:	e8 ac 01 00 00       	call   80023b <_panic>
	memmove(UTEMP, addr, PGSIZE);
  80008f:	83 ec 04             	sub    $0x4,%esp
  800092:	68 00 10 00 00       	push   $0x1000
  800097:	53                   	push   %ebx
  800098:	68 00 00 40 00       	push   $0x400000
  80009d:	e8 89 09 00 00       	call   800a2b <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8000a2:	83 c4 08             	add    $0x8,%esp
  8000a5:	68 00 00 40 00       	push   $0x400000
  8000aa:	6a 00                	push   $0x0
  8000ac:	e8 70 0c 00 00       	call   800d21 <sys_page_unmap>
  8000b1:	83 c4 10             	add    $0x10,%esp
  8000b4:	85 c0                	test   %eax,%eax
  8000b6:	79 12                	jns    8000ca <duppage+0x97>
		panic("sys_page_unmap: %e", r);
  8000b8:	50                   	push   %eax
  8000b9:	68 34 24 80 00       	push   $0x802434
  8000be:	6a 25                	push   $0x25
  8000c0:	68 13 24 80 00       	push   $0x802413
  8000c5:	e8 71 01 00 00       	call   80023b <_panic>
}
  8000ca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000cd:	5b                   	pop    %ebx
  8000ce:	5e                   	pop    %esi
  8000cf:	5d                   	pop    %ebp
  8000d0:	c3                   	ret    

008000d1 <dumbfork>:

envid_t
dumbfork(void)
{
  8000d1:	55                   	push   %ebp
  8000d2:	89 e5                	mov    %esp,%ebp
  8000d4:	56                   	push   %esi
  8000d5:	53                   	push   %ebx
  8000d6:	83 ec 10             	sub    $0x10,%esp
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8000d9:	b8 07 00 00 00       	mov    $0x7,%eax
  8000de:	cd 30                	int    $0x30
  8000e0:	89 c3                	mov    %eax,%ebx
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  8000e2:	85 c0                	test   %eax,%eax
  8000e4:	79 12                	jns    8000f8 <dumbfork+0x27>
		panic("sys_exofork: %e", envid);
  8000e6:	50                   	push   %eax
  8000e7:	68 47 24 80 00       	push   $0x802447
  8000ec:	6a 37                	push   $0x37
  8000ee:	68 13 24 80 00       	push   $0x802413
  8000f3:	e8 43 01 00 00       	call   80023b <_panic>
  8000f8:	89 c6                	mov    %eax,%esi
	if (envid == 0) {
  8000fa:	85 c0                	test   %eax,%eax
  8000fc:	75 1e                	jne    80011c <dumbfork+0x4b>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  8000fe:	e8 5b 0b 00 00       	call   800c5e <sys_getenvid>
  800103:	25 ff 03 00 00       	and    $0x3ff,%eax
  800108:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80010b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800110:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  800115:	b8 00 00 00 00       	mov    $0x0,%eax
  80011a:	eb 60                	jmp    80017c <dumbfork+0xab>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  80011c:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  800123:	eb 14                	jmp    800139 <dumbfork+0x68>
		duppage(envid, addr);
  800125:	83 ec 08             	sub    $0x8,%esp
  800128:	52                   	push   %edx
  800129:	56                   	push   %esi
  80012a:	e8 04 ff ff ff       	call   800033 <duppage>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  80012f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  800136:	83 c4 10             	add    $0x10,%esp
  800139:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80013c:	81 fa 00 70 80 00    	cmp    $0x807000,%edx
  800142:	72 e1                	jb     800125 <dumbfork+0x54>
		duppage(envid, addr);

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  800144:	83 ec 08             	sub    $0x8,%esp
  800147:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80014a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80014f:	50                   	push   %eax
  800150:	53                   	push   %ebx
  800151:	e8 dd fe ff ff       	call   800033 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  800156:	83 c4 08             	add    $0x8,%esp
  800159:	6a 02                	push   $0x2
  80015b:	53                   	push   %ebx
  80015c:	e8 02 0c 00 00       	call   800d63 <sys_env_set_status>
  800161:	83 c4 10             	add    $0x10,%esp
  800164:	85 c0                	test   %eax,%eax
  800166:	79 12                	jns    80017a <dumbfork+0xa9>
		panic("sys_env_set_status: %e", r);
  800168:	50                   	push   %eax
  800169:	68 57 24 80 00       	push   $0x802457
  80016e:	6a 4c                	push   $0x4c
  800170:	68 13 24 80 00       	push   $0x802413
  800175:	e8 c1 00 00 00       	call   80023b <_panic>

	return envid;
  80017a:	89 d8                	mov    %ebx,%eax
}
  80017c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80017f:	5b                   	pop    %ebx
  800180:	5e                   	pop    %esi
  800181:	5d                   	pop    %ebp
  800182:	c3                   	ret    

00800183 <umain>:

envid_t dumbfork(void);

void
umain(int argc, char **argv)
{
  800183:	55                   	push   %ebp
  800184:	89 e5                	mov    %esp,%ebp
  800186:	57                   	push   %edi
  800187:	56                   	push   %esi
  800188:	53                   	push   %ebx
  800189:	83 ec 0c             	sub    $0xc,%esp
	envid_t who;
	int i;

	// fork a child process
	who = dumbfork();
  80018c:	e8 40 ff ff ff       	call   8000d1 <dumbfork>
  800191:	89 c7                	mov    %eax,%edi
  800193:	85 c0                	test   %eax,%eax
  800195:	be 75 24 80 00       	mov    $0x802475,%esi
  80019a:	b8 6e 24 80 00       	mov    $0x80246e,%eax
  80019f:	0f 45 f0             	cmovne %eax,%esi

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001a2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001a7:	eb 1a                	jmp    8001c3 <umain+0x40>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  8001a9:	83 ec 04             	sub    $0x4,%esp
  8001ac:	56                   	push   %esi
  8001ad:	53                   	push   %ebx
  8001ae:	68 7b 24 80 00       	push   $0x80247b
  8001b3:	e8 5c 01 00 00       	call   800314 <cprintf>
		sys_yield();
  8001b8:	e8 c0 0a 00 00       	call   800c7d <sys_yield>

	// fork a child process
	who = dumbfork();

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001bd:	83 c3 01             	add    $0x1,%ebx
  8001c0:	83 c4 10             	add    $0x10,%esp
  8001c3:	85 ff                	test   %edi,%edi
  8001c5:	74 07                	je     8001ce <umain+0x4b>
  8001c7:	83 fb 09             	cmp    $0x9,%ebx
  8001ca:	7e dd                	jle    8001a9 <umain+0x26>
  8001cc:	eb 05                	jmp    8001d3 <umain+0x50>
  8001ce:	83 fb 13             	cmp    $0x13,%ebx
  8001d1:	7e d6                	jle    8001a9 <umain+0x26>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
		sys_yield();
	}
}
  8001d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d6:	5b                   	pop    %ebx
  8001d7:	5e                   	pop    %esi
  8001d8:	5f                   	pop    %edi
  8001d9:	5d                   	pop    %ebp
  8001da:	c3                   	ret    

008001db <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001db:	55                   	push   %ebp
  8001dc:	89 e5                	mov    %esp,%ebp
  8001de:	56                   	push   %esi
  8001df:	53                   	push   %ebx
  8001e0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001e3:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8001e6:	e8 73 0a 00 00       	call   800c5e <sys_getenvid>
  8001eb:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001f0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001f3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001f8:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001fd:	85 db                	test   %ebx,%ebx
  8001ff:	7e 07                	jle    800208 <libmain+0x2d>
		binaryname = argv[0];
  800201:	8b 06                	mov    (%esi),%eax
  800203:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800208:	83 ec 08             	sub    $0x8,%esp
  80020b:	56                   	push   %esi
  80020c:	53                   	push   %ebx
  80020d:	e8 71 ff ff ff       	call   800183 <umain>

	// exit gracefully
	exit();
  800212:	e8 0a 00 00 00       	call   800221 <exit>
}
  800217:	83 c4 10             	add    $0x10,%esp
  80021a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80021d:	5b                   	pop    %ebx
  80021e:	5e                   	pop    %esi
  80021f:	5d                   	pop    %ebp
  800220:	c3                   	ret    

00800221 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800221:	55                   	push   %ebp
  800222:	89 e5                	mov    %esp,%ebp
  800224:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800227:	e8 4b 0e 00 00       	call   801077 <close_all>
	sys_env_destroy(0);
  80022c:	83 ec 0c             	sub    $0xc,%esp
  80022f:	6a 00                	push   $0x0
  800231:	e8 e7 09 00 00       	call   800c1d <sys_env_destroy>
}
  800236:	83 c4 10             	add    $0x10,%esp
  800239:	c9                   	leave  
  80023a:	c3                   	ret    

0080023b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80023b:	55                   	push   %ebp
  80023c:	89 e5                	mov    %esp,%ebp
  80023e:	56                   	push   %esi
  80023f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800240:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800243:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800249:	e8 10 0a 00 00       	call   800c5e <sys_getenvid>
  80024e:	83 ec 0c             	sub    $0xc,%esp
  800251:	ff 75 0c             	pushl  0xc(%ebp)
  800254:	ff 75 08             	pushl  0x8(%ebp)
  800257:	56                   	push   %esi
  800258:	50                   	push   %eax
  800259:	68 98 24 80 00       	push   $0x802498
  80025e:	e8 b1 00 00 00       	call   800314 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800263:	83 c4 18             	add    $0x18,%esp
  800266:	53                   	push   %ebx
  800267:	ff 75 10             	pushl  0x10(%ebp)
  80026a:	e8 54 00 00 00       	call   8002c3 <vcprintf>
	cprintf("\n");
  80026f:	c7 04 24 8b 24 80 00 	movl   $0x80248b,(%esp)
  800276:	e8 99 00 00 00       	call   800314 <cprintf>
  80027b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80027e:	cc                   	int3   
  80027f:	eb fd                	jmp    80027e <_panic+0x43>

00800281 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800281:	55                   	push   %ebp
  800282:	89 e5                	mov    %esp,%ebp
  800284:	53                   	push   %ebx
  800285:	83 ec 04             	sub    $0x4,%esp
  800288:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80028b:	8b 13                	mov    (%ebx),%edx
  80028d:	8d 42 01             	lea    0x1(%edx),%eax
  800290:	89 03                	mov    %eax,(%ebx)
  800292:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800295:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800299:	3d ff 00 00 00       	cmp    $0xff,%eax
  80029e:	75 1a                	jne    8002ba <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8002a0:	83 ec 08             	sub    $0x8,%esp
  8002a3:	68 ff 00 00 00       	push   $0xff
  8002a8:	8d 43 08             	lea    0x8(%ebx),%eax
  8002ab:	50                   	push   %eax
  8002ac:	e8 2f 09 00 00       	call   800be0 <sys_cputs>
		b->idx = 0;
  8002b1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002b7:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002ba:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002c1:	c9                   	leave  
  8002c2:	c3                   	ret    

008002c3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002c3:	55                   	push   %ebp
  8002c4:	89 e5                	mov    %esp,%ebp
  8002c6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002cc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002d3:	00 00 00 
	b.cnt = 0;
  8002d6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002dd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002e0:	ff 75 0c             	pushl  0xc(%ebp)
  8002e3:	ff 75 08             	pushl  0x8(%ebp)
  8002e6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002ec:	50                   	push   %eax
  8002ed:	68 81 02 80 00       	push   $0x800281
  8002f2:	e8 54 01 00 00       	call   80044b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002f7:	83 c4 08             	add    $0x8,%esp
  8002fa:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800300:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800306:	50                   	push   %eax
  800307:	e8 d4 08 00 00       	call   800be0 <sys_cputs>

	return b.cnt;
}
  80030c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800312:	c9                   	leave  
  800313:	c3                   	ret    

00800314 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800314:	55                   	push   %ebp
  800315:	89 e5                	mov    %esp,%ebp
  800317:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80031a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80031d:	50                   	push   %eax
  80031e:	ff 75 08             	pushl  0x8(%ebp)
  800321:	e8 9d ff ff ff       	call   8002c3 <vcprintf>
	va_end(ap);

	return cnt;
}
  800326:	c9                   	leave  
  800327:	c3                   	ret    

00800328 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800328:	55                   	push   %ebp
  800329:	89 e5                	mov    %esp,%ebp
  80032b:	57                   	push   %edi
  80032c:	56                   	push   %esi
  80032d:	53                   	push   %ebx
  80032e:	83 ec 1c             	sub    $0x1c,%esp
  800331:	89 c7                	mov    %eax,%edi
  800333:	89 d6                	mov    %edx,%esi
  800335:	8b 45 08             	mov    0x8(%ebp),%eax
  800338:	8b 55 0c             	mov    0xc(%ebp),%edx
  80033b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80033e:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800341:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800344:	bb 00 00 00 00       	mov    $0x0,%ebx
  800349:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80034c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80034f:	39 d3                	cmp    %edx,%ebx
  800351:	72 05                	jb     800358 <printnum+0x30>
  800353:	39 45 10             	cmp    %eax,0x10(%ebp)
  800356:	77 45                	ja     80039d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800358:	83 ec 0c             	sub    $0xc,%esp
  80035b:	ff 75 18             	pushl  0x18(%ebp)
  80035e:	8b 45 14             	mov    0x14(%ebp),%eax
  800361:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800364:	53                   	push   %ebx
  800365:	ff 75 10             	pushl  0x10(%ebp)
  800368:	83 ec 08             	sub    $0x8,%esp
  80036b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80036e:	ff 75 e0             	pushl  -0x20(%ebp)
  800371:	ff 75 dc             	pushl  -0x24(%ebp)
  800374:	ff 75 d8             	pushl  -0x28(%ebp)
  800377:	e8 e4 1d 00 00       	call   802160 <__udivdi3>
  80037c:	83 c4 18             	add    $0x18,%esp
  80037f:	52                   	push   %edx
  800380:	50                   	push   %eax
  800381:	89 f2                	mov    %esi,%edx
  800383:	89 f8                	mov    %edi,%eax
  800385:	e8 9e ff ff ff       	call   800328 <printnum>
  80038a:	83 c4 20             	add    $0x20,%esp
  80038d:	eb 18                	jmp    8003a7 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80038f:	83 ec 08             	sub    $0x8,%esp
  800392:	56                   	push   %esi
  800393:	ff 75 18             	pushl  0x18(%ebp)
  800396:	ff d7                	call   *%edi
  800398:	83 c4 10             	add    $0x10,%esp
  80039b:	eb 03                	jmp    8003a0 <printnum+0x78>
  80039d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003a0:	83 eb 01             	sub    $0x1,%ebx
  8003a3:	85 db                	test   %ebx,%ebx
  8003a5:	7f e8                	jg     80038f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003a7:	83 ec 08             	sub    $0x8,%esp
  8003aa:	56                   	push   %esi
  8003ab:	83 ec 04             	sub    $0x4,%esp
  8003ae:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003b1:	ff 75 e0             	pushl  -0x20(%ebp)
  8003b4:	ff 75 dc             	pushl  -0x24(%ebp)
  8003b7:	ff 75 d8             	pushl  -0x28(%ebp)
  8003ba:	e8 d1 1e 00 00       	call   802290 <__umoddi3>
  8003bf:	83 c4 14             	add    $0x14,%esp
  8003c2:	0f be 80 bb 24 80 00 	movsbl 0x8024bb(%eax),%eax
  8003c9:	50                   	push   %eax
  8003ca:	ff d7                	call   *%edi
}
  8003cc:	83 c4 10             	add    $0x10,%esp
  8003cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003d2:	5b                   	pop    %ebx
  8003d3:	5e                   	pop    %esi
  8003d4:	5f                   	pop    %edi
  8003d5:	5d                   	pop    %ebp
  8003d6:	c3                   	ret    

008003d7 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003d7:	55                   	push   %ebp
  8003d8:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003da:	83 fa 01             	cmp    $0x1,%edx
  8003dd:	7e 0e                	jle    8003ed <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003df:	8b 10                	mov    (%eax),%edx
  8003e1:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003e4:	89 08                	mov    %ecx,(%eax)
  8003e6:	8b 02                	mov    (%edx),%eax
  8003e8:	8b 52 04             	mov    0x4(%edx),%edx
  8003eb:	eb 22                	jmp    80040f <getuint+0x38>
	else if (lflag)
  8003ed:	85 d2                	test   %edx,%edx
  8003ef:	74 10                	je     800401 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003f1:	8b 10                	mov    (%eax),%edx
  8003f3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003f6:	89 08                	mov    %ecx,(%eax)
  8003f8:	8b 02                	mov    (%edx),%eax
  8003fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8003ff:	eb 0e                	jmp    80040f <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800401:	8b 10                	mov    (%eax),%edx
  800403:	8d 4a 04             	lea    0x4(%edx),%ecx
  800406:	89 08                	mov    %ecx,(%eax)
  800408:	8b 02                	mov    (%edx),%eax
  80040a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80040f:	5d                   	pop    %ebp
  800410:	c3                   	ret    

00800411 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800411:	55                   	push   %ebp
  800412:	89 e5                	mov    %esp,%ebp
  800414:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800417:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80041b:	8b 10                	mov    (%eax),%edx
  80041d:	3b 50 04             	cmp    0x4(%eax),%edx
  800420:	73 0a                	jae    80042c <sprintputch+0x1b>
		*b->buf++ = ch;
  800422:	8d 4a 01             	lea    0x1(%edx),%ecx
  800425:	89 08                	mov    %ecx,(%eax)
  800427:	8b 45 08             	mov    0x8(%ebp),%eax
  80042a:	88 02                	mov    %al,(%edx)
}
  80042c:	5d                   	pop    %ebp
  80042d:	c3                   	ret    

0080042e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80042e:	55                   	push   %ebp
  80042f:	89 e5                	mov    %esp,%ebp
  800431:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800434:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800437:	50                   	push   %eax
  800438:	ff 75 10             	pushl  0x10(%ebp)
  80043b:	ff 75 0c             	pushl  0xc(%ebp)
  80043e:	ff 75 08             	pushl  0x8(%ebp)
  800441:	e8 05 00 00 00       	call   80044b <vprintfmt>
	va_end(ap);
}
  800446:	83 c4 10             	add    $0x10,%esp
  800449:	c9                   	leave  
  80044a:	c3                   	ret    

0080044b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80044b:	55                   	push   %ebp
  80044c:	89 e5                	mov    %esp,%ebp
  80044e:	57                   	push   %edi
  80044f:	56                   	push   %esi
  800450:	53                   	push   %ebx
  800451:	83 ec 2c             	sub    $0x2c,%esp
  800454:	8b 75 08             	mov    0x8(%ebp),%esi
  800457:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80045a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80045d:	eb 12                	jmp    800471 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80045f:	85 c0                	test   %eax,%eax
  800461:	0f 84 89 03 00 00    	je     8007f0 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800467:	83 ec 08             	sub    $0x8,%esp
  80046a:	53                   	push   %ebx
  80046b:	50                   	push   %eax
  80046c:	ff d6                	call   *%esi
  80046e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800471:	83 c7 01             	add    $0x1,%edi
  800474:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800478:	83 f8 25             	cmp    $0x25,%eax
  80047b:	75 e2                	jne    80045f <vprintfmt+0x14>
  80047d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800481:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800488:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80048f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800496:	ba 00 00 00 00       	mov    $0x0,%edx
  80049b:	eb 07                	jmp    8004a4 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004a0:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a4:	8d 47 01             	lea    0x1(%edi),%eax
  8004a7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004aa:	0f b6 07             	movzbl (%edi),%eax
  8004ad:	0f b6 c8             	movzbl %al,%ecx
  8004b0:	83 e8 23             	sub    $0x23,%eax
  8004b3:	3c 55                	cmp    $0x55,%al
  8004b5:	0f 87 1a 03 00 00    	ja     8007d5 <vprintfmt+0x38a>
  8004bb:	0f b6 c0             	movzbl %al,%eax
  8004be:	ff 24 85 00 26 80 00 	jmp    *0x802600(,%eax,4)
  8004c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004c8:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004cc:	eb d6                	jmp    8004a4 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004d9:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004dc:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8004e0:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8004e3:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8004e6:	83 fa 09             	cmp    $0x9,%edx
  8004e9:	77 39                	ja     800524 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004eb:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004ee:	eb e9                	jmp    8004d9 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f3:	8d 48 04             	lea    0x4(%eax),%ecx
  8004f6:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004f9:	8b 00                	mov    (%eax),%eax
  8004fb:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800501:	eb 27                	jmp    80052a <vprintfmt+0xdf>
  800503:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800506:	85 c0                	test   %eax,%eax
  800508:	b9 00 00 00 00       	mov    $0x0,%ecx
  80050d:	0f 49 c8             	cmovns %eax,%ecx
  800510:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800513:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800516:	eb 8c                	jmp    8004a4 <vprintfmt+0x59>
  800518:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80051b:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800522:	eb 80                	jmp    8004a4 <vprintfmt+0x59>
  800524:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800527:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80052a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80052e:	0f 89 70 ff ff ff    	jns    8004a4 <vprintfmt+0x59>
				width = precision, precision = -1;
  800534:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800537:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80053a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800541:	e9 5e ff ff ff       	jmp    8004a4 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800546:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800549:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80054c:	e9 53 ff ff ff       	jmp    8004a4 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800551:	8b 45 14             	mov    0x14(%ebp),%eax
  800554:	8d 50 04             	lea    0x4(%eax),%edx
  800557:	89 55 14             	mov    %edx,0x14(%ebp)
  80055a:	83 ec 08             	sub    $0x8,%esp
  80055d:	53                   	push   %ebx
  80055e:	ff 30                	pushl  (%eax)
  800560:	ff d6                	call   *%esi
			break;
  800562:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800565:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800568:	e9 04 ff ff ff       	jmp    800471 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80056d:	8b 45 14             	mov    0x14(%ebp),%eax
  800570:	8d 50 04             	lea    0x4(%eax),%edx
  800573:	89 55 14             	mov    %edx,0x14(%ebp)
  800576:	8b 00                	mov    (%eax),%eax
  800578:	99                   	cltd   
  800579:	31 d0                	xor    %edx,%eax
  80057b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80057d:	83 f8 0f             	cmp    $0xf,%eax
  800580:	7f 0b                	jg     80058d <vprintfmt+0x142>
  800582:	8b 14 85 60 27 80 00 	mov    0x802760(,%eax,4),%edx
  800589:	85 d2                	test   %edx,%edx
  80058b:	75 18                	jne    8005a5 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80058d:	50                   	push   %eax
  80058e:	68 d3 24 80 00       	push   $0x8024d3
  800593:	53                   	push   %ebx
  800594:	56                   	push   %esi
  800595:	e8 94 fe ff ff       	call   80042e <printfmt>
  80059a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005a0:	e9 cc fe ff ff       	jmp    800471 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8005a5:	52                   	push   %edx
  8005a6:	68 9e 28 80 00       	push   $0x80289e
  8005ab:	53                   	push   %ebx
  8005ac:	56                   	push   %esi
  8005ad:	e8 7c fe ff ff       	call   80042e <printfmt>
  8005b2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005b8:	e9 b4 fe ff ff       	jmp    800471 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c0:	8d 50 04             	lea    0x4(%eax),%edx
  8005c3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c6:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005c8:	85 ff                	test   %edi,%edi
  8005ca:	b8 cc 24 80 00       	mov    $0x8024cc,%eax
  8005cf:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005d2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005d6:	0f 8e 94 00 00 00    	jle    800670 <vprintfmt+0x225>
  8005dc:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005e0:	0f 84 98 00 00 00    	je     80067e <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e6:	83 ec 08             	sub    $0x8,%esp
  8005e9:	ff 75 d0             	pushl  -0x30(%ebp)
  8005ec:	57                   	push   %edi
  8005ed:	e8 86 02 00 00       	call   800878 <strnlen>
  8005f2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005f5:	29 c1                	sub    %eax,%ecx
  8005f7:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005fa:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005fd:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800601:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800604:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800607:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800609:	eb 0f                	jmp    80061a <vprintfmt+0x1cf>
					putch(padc, putdat);
  80060b:	83 ec 08             	sub    $0x8,%esp
  80060e:	53                   	push   %ebx
  80060f:	ff 75 e0             	pushl  -0x20(%ebp)
  800612:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800614:	83 ef 01             	sub    $0x1,%edi
  800617:	83 c4 10             	add    $0x10,%esp
  80061a:	85 ff                	test   %edi,%edi
  80061c:	7f ed                	jg     80060b <vprintfmt+0x1c0>
  80061e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800621:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800624:	85 c9                	test   %ecx,%ecx
  800626:	b8 00 00 00 00       	mov    $0x0,%eax
  80062b:	0f 49 c1             	cmovns %ecx,%eax
  80062e:	29 c1                	sub    %eax,%ecx
  800630:	89 75 08             	mov    %esi,0x8(%ebp)
  800633:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800636:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800639:	89 cb                	mov    %ecx,%ebx
  80063b:	eb 4d                	jmp    80068a <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80063d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800641:	74 1b                	je     80065e <vprintfmt+0x213>
  800643:	0f be c0             	movsbl %al,%eax
  800646:	83 e8 20             	sub    $0x20,%eax
  800649:	83 f8 5e             	cmp    $0x5e,%eax
  80064c:	76 10                	jbe    80065e <vprintfmt+0x213>
					putch('?', putdat);
  80064e:	83 ec 08             	sub    $0x8,%esp
  800651:	ff 75 0c             	pushl  0xc(%ebp)
  800654:	6a 3f                	push   $0x3f
  800656:	ff 55 08             	call   *0x8(%ebp)
  800659:	83 c4 10             	add    $0x10,%esp
  80065c:	eb 0d                	jmp    80066b <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80065e:	83 ec 08             	sub    $0x8,%esp
  800661:	ff 75 0c             	pushl  0xc(%ebp)
  800664:	52                   	push   %edx
  800665:	ff 55 08             	call   *0x8(%ebp)
  800668:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80066b:	83 eb 01             	sub    $0x1,%ebx
  80066e:	eb 1a                	jmp    80068a <vprintfmt+0x23f>
  800670:	89 75 08             	mov    %esi,0x8(%ebp)
  800673:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800676:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800679:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80067c:	eb 0c                	jmp    80068a <vprintfmt+0x23f>
  80067e:	89 75 08             	mov    %esi,0x8(%ebp)
  800681:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800684:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800687:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80068a:	83 c7 01             	add    $0x1,%edi
  80068d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800691:	0f be d0             	movsbl %al,%edx
  800694:	85 d2                	test   %edx,%edx
  800696:	74 23                	je     8006bb <vprintfmt+0x270>
  800698:	85 f6                	test   %esi,%esi
  80069a:	78 a1                	js     80063d <vprintfmt+0x1f2>
  80069c:	83 ee 01             	sub    $0x1,%esi
  80069f:	79 9c                	jns    80063d <vprintfmt+0x1f2>
  8006a1:	89 df                	mov    %ebx,%edi
  8006a3:	8b 75 08             	mov    0x8(%ebp),%esi
  8006a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006a9:	eb 18                	jmp    8006c3 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006ab:	83 ec 08             	sub    $0x8,%esp
  8006ae:	53                   	push   %ebx
  8006af:	6a 20                	push   $0x20
  8006b1:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006b3:	83 ef 01             	sub    $0x1,%edi
  8006b6:	83 c4 10             	add    $0x10,%esp
  8006b9:	eb 08                	jmp    8006c3 <vprintfmt+0x278>
  8006bb:	89 df                	mov    %ebx,%edi
  8006bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8006c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006c3:	85 ff                	test   %edi,%edi
  8006c5:	7f e4                	jg     8006ab <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006ca:	e9 a2 fd ff ff       	jmp    800471 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006cf:	83 fa 01             	cmp    $0x1,%edx
  8006d2:	7e 16                	jle    8006ea <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8006d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d7:	8d 50 08             	lea    0x8(%eax),%edx
  8006da:	89 55 14             	mov    %edx,0x14(%ebp)
  8006dd:	8b 50 04             	mov    0x4(%eax),%edx
  8006e0:	8b 00                	mov    (%eax),%eax
  8006e2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006e5:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006e8:	eb 32                	jmp    80071c <vprintfmt+0x2d1>
	else if (lflag)
  8006ea:	85 d2                	test   %edx,%edx
  8006ec:	74 18                	je     800706 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8006ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f1:	8d 50 04             	lea    0x4(%eax),%edx
  8006f4:	89 55 14             	mov    %edx,0x14(%ebp)
  8006f7:	8b 00                	mov    (%eax),%eax
  8006f9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006fc:	89 c1                	mov    %eax,%ecx
  8006fe:	c1 f9 1f             	sar    $0x1f,%ecx
  800701:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800704:	eb 16                	jmp    80071c <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800706:	8b 45 14             	mov    0x14(%ebp),%eax
  800709:	8d 50 04             	lea    0x4(%eax),%edx
  80070c:	89 55 14             	mov    %edx,0x14(%ebp)
  80070f:	8b 00                	mov    (%eax),%eax
  800711:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800714:	89 c1                	mov    %eax,%ecx
  800716:	c1 f9 1f             	sar    $0x1f,%ecx
  800719:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80071c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80071f:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800722:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800727:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80072b:	79 74                	jns    8007a1 <vprintfmt+0x356>
				putch('-', putdat);
  80072d:	83 ec 08             	sub    $0x8,%esp
  800730:	53                   	push   %ebx
  800731:	6a 2d                	push   $0x2d
  800733:	ff d6                	call   *%esi
				num = -(long long) num;
  800735:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800738:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80073b:	f7 d8                	neg    %eax
  80073d:	83 d2 00             	adc    $0x0,%edx
  800740:	f7 da                	neg    %edx
  800742:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800745:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80074a:	eb 55                	jmp    8007a1 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80074c:	8d 45 14             	lea    0x14(%ebp),%eax
  80074f:	e8 83 fc ff ff       	call   8003d7 <getuint>
			base = 10;
  800754:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800759:	eb 46                	jmp    8007a1 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80075b:	8d 45 14             	lea    0x14(%ebp),%eax
  80075e:	e8 74 fc ff ff       	call   8003d7 <getuint>
                        base = 8;
  800763:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800768:	eb 37                	jmp    8007a1 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80076a:	83 ec 08             	sub    $0x8,%esp
  80076d:	53                   	push   %ebx
  80076e:	6a 30                	push   $0x30
  800770:	ff d6                	call   *%esi
			putch('x', putdat);
  800772:	83 c4 08             	add    $0x8,%esp
  800775:	53                   	push   %ebx
  800776:	6a 78                	push   $0x78
  800778:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80077a:	8b 45 14             	mov    0x14(%ebp),%eax
  80077d:	8d 50 04             	lea    0x4(%eax),%edx
  800780:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800783:	8b 00                	mov    (%eax),%eax
  800785:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80078a:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80078d:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800792:	eb 0d                	jmp    8007a1 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800794:	8d 45 14             	lea    0x14(%ebp),%eax
  800797:	e8 3b fc ff ff       	call   8003d7 <getuint>
			base = 16;
  80079c:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007a1:	83 ec 0c             	sub    $0xc,%esp
  8007a4:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8007a8:	57                   	push   %edi
  8007a9:	ff 75 e0             	pushl  -0x20(%ebp)
  8007ac:	51                   	push   %ecx
  8007ad:	52                   	push   %edx
  8007ae:	50                   	push   %eax
  8007af:	89 da                	mov    %ebx,%edx
  8007b1:	89 f0                	mov    %esi,%eax
  8007b3:	e8 70 fb ff ff       	call   800328 <printnum>
			break;
  8007b8:	83 c4 20             	add    $0x20,%esp
  8007bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007be:	e9 ae fc ff ff       	jmp    800471 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007c3:	83 ec 08             	sub    $0x8,%esp
  8007c6:	53                   	push   %ebx
  8007c7:	51                   	push   %ecx
  8007c8:	ff d6                	call   *%esi
			break;
  8007ca:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007d0:	e9 9c fc ff ff       	jmp    800471 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007d5:	83 ec 08             	sub    $0x8,%esp
  8007d8:	53                   	push   %ebx
  8007d9:	6a 25                	push   $0x25
  8007db:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007dd:	83 c4 10             	add    $0x10,%esp
  8007e0:	eb 03                	jmp    8007e5 <vprintfmt+0x39a>
  8007e2:	83 ef 01             	sub    $0x1,%edi
  8007e5:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007e9:	75 f7                	jne    8007e2 <vprintfmt+0x397>
  8007eb:	e9 81 fc ff ff       	jmp    800471 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007f3:	5b                   	pop    %ebx
  8007f4:	5e                   	pop    %esi
  8007f5:	5f                   	pop    %edi
  8007f6:	5d                   	pop    %ebp
  8007f7:	c3                   	ret    

008007f8 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007f8:	55                   	push   %ebp
  8007f9:	89 e5                	mov    %esp,%ebp
  8007fb:	83 ec 18             	sub    $0x18,%esp
  8007fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800801:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800804:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800807:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80080b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80080e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800815:	85 c0                	test   %eax,%eax
  800817:	74 26                	je     80083f <vsnprintf+0x47>
  800819:	85 d2                	test   %edx,%edx
  80081b:	7e 22                	jle    80083f <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80081d:	ff 75 14             	pushl  0x14(%ebp)
  800820:	ff 75 10             	pushl  0x10(%ebp)
  800823:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800826:	50                   	push   %eax
  800827:	68 11 04 80 00       	push   $0x800411
  80082c:	e8 1a fc ff ff       	call   80044b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800831:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800834:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800837:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80083a:	83 c4 10             	add    $0x10,%esp
  80083d:	eb 05                	jmp    800844 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80083f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800844:	c9                   	leave  
  800845:	c3                   	ret    

00800846 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800846:	55                   	push   %ebp
  800847:	89 e5                	mov    %esp,%ebp
  800849:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80084c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80084f:	50                   	push   %eax
  800850:	ff 75 10             	pushl  0x10(%ebp)
  800853:	ff 75 0c             	pushl  0xc(%ebp)
  800856:	ff 75 08             	pushl  0x8(%ebp)
  800859:	e8 9a ff ff ff       	call   8007f8 <vsnprintf>
	va_end(ap);

	return rc;
}
  80085e:	c9                   	leave  
  80085f:	c3                   	ret    

00800860 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800866:	b8 00 00 00 00       	mov    $0x0,%eax
  80086b:	eb 03                	jmp    800870 <strlen+0x10>
		n++;
  80086d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800870:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800874:	75 f7                	jne    80086d <strlen+0xd>
		n++;
	return n;
}
  800876:	5d                   	pop    %ebp
  800877:	c3                   	ret    

00800878 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800878:	55                   	push   %ebp
  800879:	89 e5                	mov    %esp,%ebp
  80087b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80087e:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800881:	ba 00 00 00 00       	mov    $0x0,%edx
  800886:	eb 03                	jmp    80088b <strnlen+0x13>
		n++;
  800888:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80088b:	39 c2                	cmp    %eax,%edx
  80088d:	74 08                	je     800897 <strnlen+0x1f>
  80088f:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800893:	75 f3                	jne    800888 <strnlen+0x10>
  800895:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800897:	5d                   	pop    %ebp
  800898:	c3                   	ret    

00800899 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800899:	55                   	push   %ebp
  80089a:	89 e5                	mov    %esp,%ebp
  80089c:	53                   	push   %ebx
  80089d:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008a3:	89 c2                	mov    %eax,%edx
  8008a5:	83 c2 01             	add    $0x1,%edx
  8008a8:	83 c1 01             	add    $0x1,%ecx
  8008ab:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008af:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008b2:	84 db                	test   %bl,%bl
  8008b4:	75 ef                	jne    8008a5 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008b6:	5b                   	pop    %ebx
  8008b7:	5d                   	pop    %ebp
  8008b8:	c3                   	ret    

008008b9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008b9:	55                   	push   %ebp
  8008ba:	89 e5                	mov    %esp,%ebp
  8008bc:	53                   	push   %ebx
  8008bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008c0:	53                   	push   %ebx
  8008c1:	e8 9a ff ff ff       	call   800860 <strlen>
  8008c6:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008c9:	ff 75 0c             	pushl  0xc(%ebp)
  8008cc:	01 d8                	add    %ebx,%eax
  8008ce:	50                   	push   %eax
  8008cf:	e8 c5 ff ff ff       	call   800899 <strcpy>
	return dst;
}
  8008d4:	89 d8                	mov    %ebx,%eax
  8008d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008d9:	c9                   	leave  
  8008da:	c3                   	ret    

008008db <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008db:	55                   	push   %ebp
  8008dc:	89 e5                	mov    %esp,%ebp
  8008de:	56                   	push   %esi
  8008df:	53                   	push   %ebx
  8008e0:	8b 75 08             	mov    0x8(%ebp),%esi
  8008e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008e6:	89 f3                	mov    %esi,%ebx
  8008e8:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008eb:	89 f2                	mov    %esi,%edx
  8008ed:	eb 0f                	jmp    8008fe <strncpy+0x23>
		*dst++ = *src;
  8008ef:	83 c2 01             	add    $0x1,%edx
  8008f2:	0f b6 01             	movzbl (%ecx),%eax
  8008f5:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008f8:	80 39 01             	cmpb   $0x1,(%ecx)
  8008fb:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008fe:	39 da                	cmp    %ebx,%edx
  800900:	75 ed                	jne    8008ef <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800902:	89 f0                	mov    %esi,%eax
  800904:	5b                   	pop    %ebx
  800905:	5e                   	pop    %esi
  800906:	5d                   	pop    %ebp
  800907:	c3                   	ret    

00800908 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800908:	55                   	push   %ebp
  800909:	89 e5                	mov    %esp,%ebp
  80090b:	56                   	push   %esi
  80090c:	53                   	push   %ebx
  80090d:	8b 75 08             	mov    0x8(%ebp),%esi
  800910:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800913:	8b 55 10             	mov    0x10(%ebp),%edx
  800916:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800918:	85 d2                	test   %edx,%edx
  80091a:	74 21                	je     80093d <strlcpy+0x35>
  80091c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800920:	89 f2                	mov    %esi,%edx
  800922:	eb 09                	jmp    80092d <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800924:	83 c2 01             	add    $0x1,%edx
  800927:	83 c1 01             	add    $0x1,%ecx
  80092a:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80092d:	39 c2                	cmp    %eax,%edx
  80092f:	74 09                	je     80093a <strlcpy+0x32>
  800931:	0f b6 19             	movzbl (%ecx),%ebx
  800934:	84 db                	test   %bl,%bl
  800936:	75 ec                	jne    800924 <strlcpy+0x1c>
  800938:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80093a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80093d:	29 f0                	sub    %esi,%eax
}
  80093f:	5b                   	pop    %ebx
  800940:	5e                   	pop    %esi
  800941:	5d                   	pop    %ebp
  800942:	c3                   	ret    

00800943 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800943:	55                   	push   %ebp
  800944:	89 e5                	mov    %esp,%ebp
  800946:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800949:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80094c:	eb 06                	jmp    800954 <strcmp+0x11>
		p++, q++;
  80094e:	83 c1 01             	add    $0x1,%ecx
  800951:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800954:	0f b6 01             	movzbl (%ecx),%eax
  800957:	84 c0                	test   %al,%al
  800959:	74 04                	je     80095f <strcmp+0x1c>
  80095b:	3a 02                	cmp    (%edx),%al
  80095d:	74 ef                	je     80094e <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80095f:	0f b6 c0             	movzbl %al,%eax
  800962:	0f b6 12             	movzbl (%edx),%edx
  800965:	29 d0                	sub    %edx,%eax
}
  800967:	5d                   	pop    %ebp
  800968:	c3                   	ret    

00800969 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800969:	55                   	push   %ebp
  80096a:	89 e5                	mov    %esp,%ebp
  80096c:	53                   	push   %ebx
  80096d:	8b 45 08             	mov    0x8(%ebp),%eax
  800970:	8b 55 0c             	mov    0xc(%ebp),%edx
  800973:	89 c3                	mov    %eax,%ebx
  800975:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800978:	eb 06                	jmp    800980 <strncmp+0x17>
		n--, p++, q++;
  80097a:	83 c0 01             	add    $0x1,%eax
  80097d:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800980:	39 d8                	cmp    %ebx,%eax
  800982:	74 15                	je     800999 <strncmp+0x30>
  800984:	0f b6 08             	movzbl (%eax),%ecx
  800987:	84 c9                	test   %cl,%cl
  800989:	74 04                	je     80098f <strncmp+0x26>
  80098b:	3a 0a                	cmp    (%edx),%cl
  80098d:	74 eb                	je     80097a <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80098f:	0f b6 00             	movzbl (%eax),%eax
  800992:	0f b6 12             	movzbl (%edx),%edx
  800995:	29 d0                	sub    %edx,%eax
  800997:	eb 05                	jmp    80099e <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800999:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80099e:	5b                   	pop    %ebx
  80099f:	5d                   	pop    %ebp
  8009a0:	c3                   	ret    

008009a1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009a1:	55                   	push   %ebp
  8009a2:	89 e5                	mov    %esp,%ebp
  8009a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009ab:	eb 07                	jmp    8009b4 <strchr+0x13>
		if (*s == c)
  8009ad:	38 ca                	cmp    %cl,%dl
  8009af:	74 0f                	je     8009c0 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009b1:	83 c0 01             	add    $0x1,%eax
  8009b4:	0f b6 10             	movzbl (%eax),%edx
  8009b7:	84 d2                	test   %dl,%dl
  8009b9:	75 f2                	jne    8009ad <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c0:	5d                   	pop    %ebp
  8009c1:	c3                   	ret    

008009c2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009c2:	55                   	push   %ebp
  8009c3:	89 e5                	mov    %esp,%ebp
  8009c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009cc:	eb 03                	jmp    8009d1 <strfind+0xf>
  8009ce:	83 c0 01             	add    $0x1,%eax
  8009d1:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009d4:	38 ca                	cmp    %cl,%dl
  8009d6:	74 04                	je     8009dc <strfind+0x1a>
  8009d8:	84 d2                	test   %dl,%dl
  8009da:	75 f2                	jne    8009ce <strfind+0xc>
			break;
	return (char *) s;
}
  8009dc:	5d                   	pop    %ebp
  8009dd:	c3                   	ret    

008009de <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009de:	55                   	push   %ebp
  8009df:	89 e5                	mov    %esp,%ebp
  8009e1:	57                   	push   %edi
  8009e2:	56                   	push   %esi
  8009e3:	53                   	push   %ebx
  8009e4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009e7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009ea:	85 c9                	test   %ecx,%ecx
  8009ec:	74 36                	je     800a24 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009ee:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009f4:	75 28                	jne    800a1e <memset+0x40>
  8009f6:	f6 c1 03             	test   $0x3,%cl
  8009f9:	75 23                	jne    800a1e <memset+0x40>
		c &= 0xFF;
  8009fb:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009ff:	89 d3                	mov    %edx,%ebx
  800a01:	c1 e3 08             	shl    $0x8,%ebx
  800a04:	89 d6                	mov    %edx,%esi
  800a06:	c1 e6 18             	shl    $0x18,%esi
  800a09:	89 d0                	mov    %edx,%eax
  800a0b:	c1 e0 10             	shl    $0x10,%eax
  800a0e:	09 f0                	or     %esi,%eax
  800a10:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a12:	89 d8                	mov    %ebx,%eax
  800a14:	09 d0                	or     %edx,%eax
  800a16:	c1 e9 02             	shr    $0x2,%ecx
  800a19:	fc                   	cld    
  800a1a:	f3 ab                	rep stos %eax,%es:(%edi)
  800a1c:	eb 06                	jmp    800a24 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a1e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a21:	fc                   	cld    
  800a22:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a24:	89 f8                	mov    %edi,%eax
  800a26:	5b                   	pop    %ebx
  800a27:	5e                   	pop    %esi
  800a28:	5f                   	pop    %edi
  800a29:	5d                   	pop    %ebp
  800a2a:	c3                   	ret    

00800a2b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a2b:	55                   	push   %ebp
  800a2c:	89 e5                	mov    %esp,%ebp
  800a2e:	57                   	push   %edi
  800a2f:	56                   	push   %esi
  800a30:	8b 45 08             	mov    0x8(%ebp),%eax
  800a33:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a36:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a39:	39 c6                	cmp    %eax,%esi
  800a3b:	73 35                	jae    800a72 <memmove+0x47>
  800a3d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a40:	39 d0                	cmp    %edx,%eax
  800a42:	73 2e                	jae    800a72 <memmove+0x47>
		s += n;
		d += n;
  800a44:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a47:	89 d6                	mov    %edx,%esi
  800a49:	09 fe                	or     %edi,%esi
  800a4b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a51:	75 13                	jne    800a66 <memmove+0x3b>
  800a53:	f6 c1 03             	test   $0x3,%cl
  800a56:	75 0e                	jne    800a66 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a58:	83 ef 04             	sub    $0x4,%edi
  800a5b:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a5e:	c1 e9 02             	shr    $0x2,%ecx
  800a61:	fd                   	std    
  800a62:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a64:	eb 09                	jmp    800a6f <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a66:	83 ef 01             	sub    $0x1,%edi
  800a69:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a6c:	fd                   	std    
  800a6d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a6f:	fc                   	cld    
  800a70:	eb 1d                	jmp    800a8f <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a72:	89 f2                	mov    %esi,%edx
  800a74:	09 c2                	or     %eax,%edx
  800a76:	f6 c2 03             	test   $0x3,%dl
  800a79:	75 0f                	jne    800a8a <memmove+0x5f>
  800a7b:	f6 c1 03             	test   $0x3,%cl
  800a7e:	75 0a                	jne    800a8a <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a80:	c1 e9 02             	shr    $0x2,%ecx
  800a83:	89 c7                	mov    %eax,%edi
  800a85:	fc                   	cld    
  800a86:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a88:	eb 05                	jmp    800a8f <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a8a:	89 c7                	mov    %eax,%edi
  800a8c:	fc                   	cld    
  800a8d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a8f:	5e                   	pop    %esi
  800a90:	5f                   	pop    %edi
  800a91:	5d                   	pop    %ebp
  800a92:	c3                   	ret    

00800a93 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a93:	55                   	push   %ebp
  800a94:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a96:	ff 75 10             	pushl  0x10(%ebp)
  800a99:	ff 75 0c             	pushl  0xc(%ebp)
  800a9c:	ff 75 08             	pushl  0x8(%ebp)
  800a9f:	e8 87 ff ff ff       	call   800a2b <memmove>
}
  800aa4:	c9                   	leave  
  800aa5:	c3                   	ret    

00800aa6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aa6:	55                   	push   %ebp
  800aa7:	89 e5                	mov    %esp,%ebp
  800aa9:	56                   	push   %esi
  800aaa:	53                   	push   %ebx
  800aab:	8b 45 08             	mov    0x8(%ebp),%eax
  800aae:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ab1:	89 c6                	mov    %eax,%esi
  800ab3:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ab6:	eb 1a                	jmp    800ad2 <memcmp+0x2c>
		if (*s1 != *s2)
  800ab8:	0f b6 08             	movzbl (%eax),%ecx
  800abb:	0f b6 1a             	movzbl (%edx),%ebx
  800abe:	38 d9                	cmp    %bl,%cl
  800ac0:	74 0a                	je     800acc <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800ac2:	0f b6 c1             	movzbl %cl,%eax
  800ac5:	0f b6 db             	movzbl %bl,%ebx
  800ac8:	29 d8                	sub    %ebx,%eax
  800aca:	eb 0f                	jmp    800adb <memcmp+0x35>
		s1++, s2++;
  800acc:	83 c0 01             	add    $0x1,%eax
  800acf:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ad2:	39 f0                	cmp    %esi,%eax
  800ad4:	75 e2                	jne    800ab8 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ad6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800adb:	5b                   	pop    %ebx
  800adc:	5e                   	pop    %esi
  800add:	5d                   	pop    %ebp
  800ade:	c3                   	ret    

00800adf <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800adf:	55                   	push   %ebp
  800ae0:	89 e5                	mov    %esp,%ebp
  800ae2:	53                   	push   %ebx
  800ae3:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ae6:	89 c1                	mov    %eax,%ecx
  800ae8:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800aeb:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800aef:	eb 0a                	jmp    800afb <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800af1:	0f b6 10             	movzbl (%eax),%edx
  800af4:	39 da                	cmp    %ebx,%edx
  800af6:	74 07                	je     800aff <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800af8:	83 c0 01             	add    $0x1,%eax
  800afb:	39 c8                	cmp    %ecx,%eax
  800afd:	72 f2                	jb     800af1 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800aff:	5b                   	pop    %ebx
  800b00:	5d                   	pop    %ebp
  800b01:	c3                   	ret    

00800b02 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b02:	55                   	push   %ebp
  800b03:	89 e5                	mov    %esp,%ebp
  800b05:	57                   	push   %edi
  800b06:	56                   	push   %esi
  800b07:	53                   	push   %ebx
  800b08:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b0b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b0e:	eb 03                	jmp    800b13 <strtol+0x11>
		s++;
  800b10:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b13:	0f b6 01             	movzbl (%ecx),%eax
  800b16:	3c 20                	cmp    $0x20,%al
  800b18:	74 f6                	je     800b10 <strtol+0xe>
  800b1a:	3c 09                	cmp    $0x9,%al
  800b1c:	74 f2                	je     800b10 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b1e:	3c 2b                	cmp    $0x2b,%al
  800b20:	75 0a                	jne    800b2c <strtol+0x2a>
		s++;
  800b22:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b25:	bf 00 00 00 00       	mov    $0x0,%edi
  800b2a:	eb 11                	jmp    800b3d <strtol+0x3b>
  800b2c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b31:	3c 2d                	cmp    $0x2d,%al
  800b33:	75 08                	jne    800b3d <strtol+0x3b>
		s++, neg = 1;
  800b35:	83 c1 01             	add    $0x1,%ecx
  800b38:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b3d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b43:	75 15                	jne    800b5a <strtol+0x58>
  800b45:	80 39 30             	cmpb   $0x30,(%ecx)
  800b48:	75 10                	jne    800b5a <strtol+0x58>
  800b4a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b4e:	75 7c                	jne    800bcc <strtol+0xca>
		s += 2, base = 16;
  800b50:	83 c1 02             	add    $0x2,%ecx
  800b53:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b58:	eb 16                	jmp    800b70 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b5a:	85 db                	test   %ebx,%ebx
  800b5c:	75 12                	jne    800b70 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b5e:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b63:	80 39 30             	cmpb   $0x30,(%ecx)
  800b66:	75 08                	jne    800b70 <strtol+0x6e>
		s++, base = 8;
  800b68:	83 c1 01             	add    $0x1,%ecx
  800b6b:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b70:	b8 00 00 00 00       	mov    $0x0,%eax
  800b75:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b78:	0f b6 11             	movzbl (%ecx),%edx
  800b7b:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b7e:	89 f3                	mov    %esi,%ebx
  800b80:	80 fb 09             	cmp    $0x9,%bl
  800b83:	77 08                	ja     800b8d <strtol+0x8b>
			dig = *s - '0';
  800b85:	0f be d2             	movsbl %dl,%edx
  800b88:	83 ea 30             	sub    $0x30,%edx
  800b8b:	eb 22                	jmp    800baf <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b8d:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b90:	89 f3                	mov    %esi,%ebx
  800b92:	80 fb 19             	cmp    $0x19,%bl
  800b95:	77 08                	ja     800b9f <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b97:	0f be d2             	movsbl %dl,%edx
  800b9a:	83 ea 57             	sub    $0x57,%edx
  800b9d:	eb 10                	jmp    800baf <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b9f:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ba2:	89 f3                	mov    %esi,%ebx
  800ba4:	80 fb 19             	cmp    $0x19,%bl
  800ba7:	77 16                	ja     800bbf <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ba9:	0f be d2             	movsbl %dl,%edx
  800bac:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800baf:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bb2:	7d 0b                	jge    800bbf <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800bb4:	83 c1 01             	add    $0x1,%ecx
  800bb7:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bbb:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800bbd:	eb b9                	jmp    800b78 <strtol+0x76>

	if (endptr)
  800bbf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bc3:	74 0d                	je     800bd2 <strtol+0xd0>
		*endptr = (char *) s;
  800bc5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bc8:	89 0e                	mov    %ecx,(%esi)
  800bca:	eb 06                	jmp    800bd2 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bcc:	85 db                	test   %ebx,%ebx
  800bce:	74 98                	je     800b68 <strtol+0x66>
  800bd0:	eb 9e                	jmp    800b70 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800bd2:	89 c2                	mov    %eax,%edx
  800bd4:	f7 da                	neg    %edx
  800bd6:	85 ff                	test   %edi,%edi
  800bd8:	0f 45 c2             	cmovne %edx,%eax
}
  800bdb:	5b                   	pop    %ebx
  800bdc:	5e                   	pop    %esi
  800bdd:	5f                   	pop    %edi
  800bde:	5d                   	pop    %ebp
  800bdf:	c3                   	ret    

00800be0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800be0:	55                   	push   %ebp
  800be1:	89 e5                	mov    %esp,%ebp
  800be3:	57                   	push   %edi
  800be4:	56                   	push   %esi
  800be5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be6:	b8 00 00 00 00       	mov    $0x0,%eax
  800beb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bee:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf1:	89 c3                	mov    %eax,%ebx
  800bf3:	89 c7                	mov    %eax,%edi
  800bf5:	89 c6                	mov    %eax,%esi
  800bf7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bf9:	5b                   	pop    %ebx
  800bfa:	5e                   	pop    %esi
  800bfb:	5f                   	pop    %edi
  800bfc:	5d                   	pop    %ebp
  800bfd:	c3                   	ret    

00800bfe <sys_cgetc>:

int
sys_cgetc(void)
{
  800bfe:	55                   	push   %ebp
  800bff:	89 e5                	mov    %esp,%ebp
  800c01:	57                   	push   %edi
  800c02:	56                   	push   %esi
  800c03:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c04:	ba 00 00 00 00       	mov    $0x0,%edx
  800c09:	b8 01 00 00 00       	mov    $0x1,%eax
  800c0e:	89 d1                	mov    %edx,%ecx
  800c10:	89 d3                	mov    %edx,%ebx
  800c12:	89 d7                	mov    %edx,%edi
  800c14:	89 d6                	mov    %edx,%esi
  800c16:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c18:	5b                   	pop    %ebx
  800c19:	5e                   	pop    %esi
  800c1a:	5f                   	pop    %edi
  800c1b:	5d                   	pop    %ebp
  800c1c:	c3                   	ret    

00800c1d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c1d:	55                   	push   %ebp
  800c1e:	89 e5                	mov    %esp,%ebp
  800c20:	57                   	push   %edi
  800c21:	56                   	push   %esi
  800c22:	53                   	push   %ebx
  800c23:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c26:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c2b:	b8 03 00 00 00       	mov    $0x3,%eax
  800c30:	8b 55 08             	mov    0x8(%ebp),%edx
  800c33:	89 cb                	mov    %ecx,%ebx
  800c35:	89 cf                	mov    %ecx,%edi
  800c37:	89 ce                	mov    %ecx,%esi
  800c39:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c3b:	85 c0                	test   %eax,%eax
  800c3d:	7e 17                	jle    800c56 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3f:	83 ec 0c             	sub    $0xc,%esp
  800c42:	50                   	push   %eax
  800c43:	6a 03                	push   $0x3
  800c45:	68 bf 27 80 00       	push   $0x8027bf
  800c4a:	6a 23                	push   $0x23
  800c4c:	68 dc 27 80 00       	push   $0x8027dc
  800c51:	e8 e5 f5 ff ff       	call   80023b <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c59:	5b                   	pop    %ebx
  800c5a:	5e                   	pop    %esi
  800c5b:	5f                   	pop    %edi
  800c5c:	5d                   	pop    %ebp
  800c5d:	c3                   	ret    

00800c5e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c5e:	55                   	push   %ebp
  800c5f:	89 e5                	mov    %esp,%ebp
  800c61:	57                   	push   %edi
  800c62:	56                   	push   %esi
  800c63:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c64:	ba 00 00 00 00       	mov    $0x0,%edx
  800c69:	b8 02 00 00 00       	mov    $0x2,%eax
  800c6e:	89 d1                	mov    %edx,%ecx
  800c70:	89 d3                	mov    %edx,%ebx
  800c72:	89 d7                	mov    %edx,%edi
  800c74:	89 d6                	mov    %edx,%esi
  800c76:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c78:	5b                   	pop    %ebx
  800c79:	5e                   	pop    %esi
  800c7a:	5f                   	pop    %edi
  800c7b:	5d                   	pop    %ebp
  800c7c:	c3                   	ret    

00800c7d <sys_yield>:

void
sys_yield(void)
{
  800c7d:	55                   	push   %ebp
  800c7e:	89 e5                	mov    %esp,%ebp
  800c80:	57                   	push   %edi
  800c81:	56                   	push   %esi
  800c82:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c83:	ba 00 00 00 00       	mov    $0x0,%edx
  800c88:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c8d:	89 d1                	mov    %edx,%ecx
  800c8f:	89 d3                	mov    %edx,%ebx
  800c91:	89 d7                	mov    %edx,%edi
  800c93:	89 d6                	mov    %edx,%esi
  800c95:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c97:	5b                   	pop    %ebx
  800c98:	5e                   	pop    %esi
  800c99:	5f                   	pop    %edi
  800c9a:	5d                   	pop    %ebp
  800c9b:	c3                   	ret    

00800c9c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c9c:	55                   	push   %ebp
  800c9d:	89 e5                	mov    %esp,%ebp
  800c9f:	57                   	push   %edi
  800ca0:	56                   	push   %esi
  800ca1:	53                   	push   %ebx
  800ca2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca5:	be 00 00 00 00       	mov    $0x0,%esi
  800caa:	b8 04 00 00 00       	mov    $0x4,%eax
  800caf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cb8:	89 f7                	mov    %esi,%edi
  800cba:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cbc:	85 c0                	test   %eax,%eax
  800cbe:	7e 17                	jle    800cd7 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc0:	83 ec 0c             	sub    $0xc,%esp
  800cc3:	50                   	push   %eax
  800cc4:	6a 04                	push   $0x4
  800cc6:	68 bf 27 80 00       	push   $0x8027bf
  800ccb:	6a 23                	push   $0x23
  800ccd:	68 dc 27 80 00       	push   $0x8027dc
  800cd2:	e8 64 f5 ff ff       	call   80023b <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cd7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cda:	5b                   	pop    %ebx
  800cdb:	5e                   	pop    %esi
  800cdc:	5f                   	pop    %edi
  800cdd:	5d                   	pop    %ebp
  800cde:	c3                   	ret    

00800cdf <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cdf:	55                   	push   %ebp
  800ce0:	89 e5                	mov    %esp,%ebp
  800ce2:	57                   	push   %edi
  800ce3:	56                   	push   %esi
  800ce4:	53                   	push   %ebx
  800ce5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce8:	b8 05 00 00 00       	mov    $0x5,%eax
  800ced:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cf6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cf9:	8b 75 18             	mov    0x18(%ebp),%esi
  800cfc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cfe:	85 c0                	test   %eax,%eax
  800d00:	7e 17                	jle    800d19 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d02:	83 ec 0c             	sub    $0xc,%esp
  800d05:	50                   	push   %eax
  800d06:	6a 05                	push   $0x5
  800d08:	68 bf 27 80 00       	push   $0x8027bf
  800d0d:	6a 23                	push   $0x23
  800d0f:	68 dc 27 80 00       	push   $0x8027dc
  800d14:	e8 22 f5 ff ff       	call   80023b <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d19:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1c:	5b                   	pop    %ebx
  800d1d:	5e                   	pop    %esi
  800d1e:	5f                   	pop    %edi
  800d1f:	5d                   	pop    %ebp
  800d20:	c3                   	ret    

00800d21 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d21:	55                   	push   %ebp
  800d22:	89 e5                	mov    %esp,%ebp
  800d24:	57                   	push   %edi
  800d25:	56                   	push   %esi
  800d26:	53                   	push   %ebx
  800d27:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d2f:	b8 06 00 00 00       	mov    $0x6,%eax
  800d34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d37:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3a:	89 df                	mov    %ebx,%edi
  800d3c:	89 de                	mov    %ebx,%esi
  800d3e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d40:	85 c0                	test   %eax,%eax
  800d42:	7e 17                	jle    800d5b <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d44:	83 ec 0c             	sub    $0xc,%esp
  800d47:	50                   	push   %eax
  800d48:	6a 06                	push   $0x6
  800d4a:	68 bf 27 80 00       	push   $0x8027bf
  800d4f:	6a 23                	push   $0x23
  800d51:	68 dc 27 80 00       	push   $0x8027dc
  800d56:	e8 e0 f4 ff ff       	call   80023b <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d5b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d5e:	5b                   	pop    %ebx
  800d5f:	5e                   	pop    %esi
  800d60:	5f                   	pop    %edi
  800d61:	5d                   	pop    %ebp
  800d62:	c3                   	ret    

00800d63 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d63:	55                   	push   %ebp
  800d64:	89 e5                	mov    %esp,%ebp
  800d66:	57                   	push   %edi
  800d67:	56                   	push   %esi
  800d68:	53                   	push   %ebx
  800d69:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d71:	b8 08 00 00 00       	mov    $0x8,%eax
  800d76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d79:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7c:	89 df                	mov    %ebx,%edi
  800d7e:	89 de                	mov    %ebx,%esi
  800d80:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d82:	85 c0                	test   %eax,%eax
  800d84:	7e 17                	jle    800d9d <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d86:	83 ec 0c             	sub    $0xc,%esp
  800d89:	50                   	push   %eax
  800d8a:	6a 08                	push   $0x8
  800d8c:	68 bf 27 80 00       	push   $0x8027bf
  800d91:	6a 23                	push   $0x23
  800d93:	68 dc 27 80 00       	push   $0x8027dc
  800d98:	e8 9e f4 ff ff       	call   80023b <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d9d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da0:	5b                   	pop    %ebx
  800da1:	5e                   	pop    %esi
  800da2:	5f                   	pop    %edi
  800da3:	5d                   	pop    %ebp
  800da4:	c3                   	ret    

00800da5 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800da5:	55                   	push   %ebp
  800da6:	89 e5                	mov    %esp,%ebp
  800da8:	57                   	push   %edi
  800da9:	56                   	push   %esi
  800daa:	53                   	push   %ebx
  800dab:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dae:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db3:	b8 09 00 00 00       	mov    $0x9,%eax
  800db8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbe:	89 df                	mov    %ebx,%edi
  800dc0:	89 de                	mov    %ebx,%esi
  800dc2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dc4:	85 c0                	test   %eax,%eax
  800dc6:	7e 17                	jle    800ddf <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc8:	83 ec 0c             	sub    $0xc,%esp
  800dcb:	50                   	push   %eax
  800dcc:	6a 09                	push   $0x9
  800dce:	68 bf 27 80 00       	push   $0x8027bf
  800dd3:	6a 23                	push   $0x23
  800dd5:	68 dc 27 80 00       	push   $0x8027dc
  800dda:	e8 5c f4 ff ff       	call   80023b <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ddf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de2:	5b                   	pop    %ebx
  800de3:	5e                   	pop    %esi
  800de4:	5f                   	pop    %edi
  800de5:	5d                   	pop    %ebp
  800de6:	c3                   	ret    

00800de7 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800de7:	55                   	push   %ebp
  800de8:	89 e5                	mov    %esp,%ebp
  800dea:	57                   	push   %edi
  800deb:	56                   	push   %esi
  800dec:	53                   	push   %ebx
  800ded:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800df5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dfa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dfd:	8b 55 08             	mov    0x8(%ebp),%edx
  800e00:	89 df                	mov    %ebx,%edi
  800e02:	89 de                	mov    %ebx,%esi
  800e04:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e06:	85 c0                	test   %eax,%eax
  800e08:	7e 17                	jle    800e21 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e0a:	83 ec 0c             	sub    $0xc,%esp
  800e0d:	50                   	push   %eax
  800e0e:	6a 0a                	push   $0xa
  800e10:	68 bf 27 80 00       	push   $0x8027bf
  800e15:	6a 23                	push   $0x23
  800e17:	68 dc 27 80 00       	push   $0x8027dc
  800e1c:	e8 1a f4 ff ff       	call   80023b <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e21:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e24:	5b                   	pop    %ebx
  800e25:	5e                   	pop    %esi
  800e26:	5f                   	pop    %edi
  800e27:	5d                   	pop    %ebp
  800e28:	c3                   	ret    

00800e29 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e29:	55                   	push   %ebp
  800e2a:	89 e5                	mov    %esp,%ebp
  800e2c:	57                   	push   %edi
  800e2d:	56                   	push   %esi
  800e2e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2f:	be 00 00 00 00       	mov    $0x0,%esi
  800e34:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e39:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e42:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e45:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e47:	5b                   	pop    %ebx
  800e48:	5e                   	pop    %esi
  800e49:	5f                   	pop    %edi
  800e4a:	5d                   	pop    %ebp
  800e4b:	c3                   	ret    

00800e4c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e4c:	55                   	push   %ebp
  800e4d:	89 e5                	mov    %esp,%ebp
  800e4f:	57                   	push   %edi
  800e50:	56                   	push   %esi
  800e51:	53                   	push   %ebx
  800e52:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e55:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e5a:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e5f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e62:	89 cb                	mov    %ecx,%ebx
  800e64:	89 cf                	mov    %ecx,%edi
  800e66:	89 ce                	mov    %ecx,%esi
  800e68:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e6a:	85 c0                	test   %eax,%eax
  800e6c:	7e 17                	jle    800e85 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e6e:	83 ec 0c             	sub    $0xc,%esp
  800e71:	50                   	push   %eax
  800e72:	6a 0d                	push   $0xd
  800e74:	68 bf 27 80 00       	push   $0x8027bf
  800e79:	6a 23                	push   $0x23
  800e7b:	68 dc 27 80 00       	push   $0x8027dc
  800e80:	e8 b6 f3 ff ff       	call   80023b <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e85:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e88:	5b                   	pop    %ebx
  800e89:	5e                   	pop    %esi
  800e8a:	5f                   	pop    %edi
  800e8b:	5d                   	pop    %ebp
  800e8c:	c3                   	ret    

00800e8d <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e8d:	55                   	push   %ebp
  800e8e:	89 e5                	mov    %esp,%ebp
  800e90:	57                   	push   %edi
  800e91:	56                   	push   %esi
  800e92:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e93:	ba 00 00 00 00       	mov    $0x0,%edx
  800e98:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e9d:	89 d1                	mov    %edx,%ecx
  800e9f:	89 d3                	mov    %edx,%ebx
  800ea1:	89 d7                	mov    %edx,%edi
  800ea3:	89 d6                	mov    %edx,%esi
  800ea5:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800ea7:	5b                   	pop    %ebx
  800ea8:	5e                   	pop    %esi
  800ea9:	5f                   	pop    %edi
  800eaa:	5d                   	pop    %ebp
  800eab:	c3                   	ret    

00800eac <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800eac:	55                   	push   %ebp
  800ead:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800eaf:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb2:	05 00 00 00 30       	add    $0x30000000,%eax
  800eb7:	c1 e8 0c             	shr    $0xc,%eax
}
  800eba:	5d                   	pop    %ebp
  800ebb:	c3                   	ret    

00800ebc <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800ebc:	55                   	push   %ebp
  800ebd:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800ebf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec2:	05 00 00 00 30       	add    $0x30000000,%eax
  800ec7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800ecc:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800ed1:	5d                   	pop    %ebp
  800ed2:	c3                   	ret    

00800ed3 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800ed3:	55                   	push   %ebp
  800ed4:	89 e5                	mov    %esp,%ebp
  800ed6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ed9:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ede:	89 c2                	mov    %eax,%edx
  800ee0:	c1 ea 16             	shr    $0x16,%edx
  800ee3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800eea:	f6 c2 01             	test   $0x1,%dl
  800eed:	74 11                	je     800f00 <fd_alloc+0x2d>
  800eef:	89 c2                	mov    %eax,%edx
  800ef1:	c1 ea 0c             	shr    $0xc,%edx
  800ef4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800efb:	f6 c2 01             	test   $0x1,%dl
  800efe:	75 09                	jne    800f09 <fd_alloc+0x36>
			*fd_store = fd;
  800f00:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f02:	b8 00 00 00 00       	mov    $0x0,%eax
  800f07:	eb 17                	jmp    800f20 <fd_alloc+0x4d>
  800f09:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f0e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f13:	75 c9                	jne    800ede <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f15:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800f1b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f20:	5d                   	pop    %ebp
  800f21:	c3                   	ret    

00800f22 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f22:	55                   	push   %ebp
  800f23:	89 e5                	mov    %esp,%ebp
  800f25:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f28:	83 f8 1f             	cmp    $0x1f,%eax
  800f2b:	77 36                	ja     800f63 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f2d:	c1 e0 0c             	shl    $0xc,%eax
  800f30:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f35:	89 c2                	mov    %eax,%edx
  800f37:	c1 ea 16             	shr    $0x16,%edx
  800f3a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f41:	f6 c2 01             	test   $0x1,%dl
  800f44:	74 24                	je     800f6a <fd_lookup+0x48>
  800f46:	89 c2                	mov    %eax,%edx
  800f48:	c1 ea 0c             	shr    $0xc,%edx
  800f4b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f52:	f6 c2 01             	test   $0x1,%dl
  800f55:	74 1a                	je     800f71 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f57:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f5a:	89 02                	mov    %eax,(%edx)
	return 0;
  800f5c:	b8 00 00 00 00       	mov    $0x0,%eax
  800f61:	eb 13                	jmp    800f76 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f63:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f68:	eb 0c                	jmp    800f76 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f6a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f6f:	eb 05                	jmp    800f76 <fd_lookup+0x54>
  800f71:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f76:	5d                   	pop    %ebp
  800f77:	c3                   	ret    

00800f78 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f78:	55                   	push   %ebp
  800f79:	89 e5                	mov    %esp,%ebp
  800f7b:	83 ec 08             	sub    $0x8,%esp
  800f7e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f81:	ba 6c 28 80 00       	mov    $0x80286c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f86:	eb 13                	jmp    800f9b <dev_lookup+0x23>
  800f88:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f8b:	39 08                	cmp    %ecx,(%eax)
  800f8d:	75 0c                	jne    800f9b <dev_lookup+0x23>
			*dev = devtab[i];
  800f8f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f92:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f94:	b8 00 00 00 00       	mov    $0x0,%eax
  800f99:	eb 2e                	jmp    800fc9 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f9b:	8b 02                	mov    (%edx),%eax
  800f9d:	85 c0                	test   %eax,%eax
  800f9f:	75 e7                	jne    800f88 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800fa1:	a1 08 40 80 00       	mov    0x804008,%eax
  800fa6:	8b 40 48             	mov    0x48(%eax),%eax
  800fa9:	83 ec 04             	sub    $0x4,%esp
  800fac:	51                   	push   %ecx
  800fad:	50                   	push   %eax
  800fae:	68 ec 27 80 00       	push   $0x8027ec
  800fb3:	e8 5c f3 ff ff       	call   800314 <cprintf>
	*dev = 0;
  800fb8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fbb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800fc1:	83 c4 10             	add    $0x10,%esp
  800fc4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800fc9:	c9                   	leave  
  800fca:	c3                   	ret    

00800fcb <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800fcb:	55                   	push   %ebp
  800fcc:	89 e5                	mov    %esp,%ebp
  800fce:	56                   	push   %esi
  800fcf:	53                   	push   %ebx
  800fd0:	83 ec 10             	sub    $0x10,%esp
  800fd3:	8b 75 08             	mov    0x8(%ebp),%esi
  800fd6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fd9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fdc:	50                   	push   %eax
  800fdd:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800fe3:	c1 e8 0c             	shr    $0xc,%eax
  800fe6:	50                   	push   %eax
  800fe7:	e8 36 ff ff ff       	call   800f22 <fd_lookup>
  800fec:	83 c4 08             	add    $0x8,%esp
  800fef:	85 c0                	test   %eax,%eax
  800ff1:	78 05                	js     800ff8 <fd_close+0x2d>
	    || fd != fd2)
  800ff3:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800ff6:	74 0c                	je     801004 <fd_close+0x39>
		return (must_exist ? r : 0);
  800ff8:	84 db                	test   %bl,%bl
  800ffa:	ba 00 00 00 00       	mov    $0x0,%edx
  800fff:	0f 44 c2             	cmove  %edx,%eax
  801002:	eb 41                	jmp    801045 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801004:	83 ec 08             	sub    $0x8,%esp
  801007:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80100a:	50                   	push   %eax
  80100b:	ff 36                	pushl  (%esi)
  80100d:	e8 66 ff ff ff       	call   800f78 <dev_lookup>
  801012:	89 c3                	mov    %eax,%ebx
  801014:	83 c4 10             	add    $0x10,%esp
  801017:	85 c0                	test   %eax,%eax
  801019:	78 1a                	js     801035 <fd_close+0x6a>
		if (dev->dev_close)
  80101b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80101e:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801021:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801026:	85 c0                	test   %eax,%eax
  801028:	74 0b                	je     801035 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80102a:	83 ec 0c             	sub    $0xc,%esp
  80102d:	56                   	push   %esi
  80102e:	ff d0                	call   *%eax
  801030:	89 c3                	mov    %eax,%ebx
  801032:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801035:	83 ec 08             	sub    $0x8,%esp
  801038:	56                   	push   %esi
  801039:	6a 00                	push   $0x0
  80103b:	e8 e1 fc ff ff       	call   800d21 <sys_page_unmap>
	return r;
  801040:	83 c4 10             	add    $0x10,%esp
  801043:	89 d8                	mov    %ebx,%eax
}
  801045:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801048:	5b                   	pop    %ebx
  801049:	5e                   	pop    %esi
  80104a:	5d                   	pop    %ebp
  80104b:	c3                   	ret    

0080104c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80104c:	55                   	push   %ebp
  80104d:	89 e5                	mov    %esp,%ebp
  80104f:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801052:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801055:	50                   	push   %eax
  801056:	ff 75 08             	pushl  0x8(%ebp)
  801059:	e8 c4 fe ff ff       	call   800f22 <fd_lookup>
  80105e:	83 c4 08             	add    $0x8,%esp
  801061:	85 c0                	test   %eax,%eax
  801063:	78 10                	js     801075 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801065:	83 ec 08             	sub    $0x8,%esp
  801068:	6a 01                	push   $0x1
  80106a:	ff 75 f4             	pushl  -0xc(%ebp)
  80106d:	e8 59 ff ff ff       	call   800fcb <fd_close>
  801072:	83 c4 10             	add    $0x10,%esp
}
  801075:	c9                   	leave  
  801076:	c3                   	ret    

00801077 <close_all>:

void
close_all(void)
{
  801077:	55                   	push   %ebp
  801078:	89 e5                	mov    %esp,%ebp
  80107a:	53                   	push   %ebx
  80107b:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80107e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801083:	83 ec 0c             	sub    $0xc,%esp
  801086:	53                   	push   %ebx
  801087:	e8 c0 ff ff ff       	call   80104c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80108c:	83 c3 01             	add    $0x1,%ebx
  80108f:	83 c4 10             	add    $0x10,%esp
  801092:	83 fb 20             	cmp    $0x20,%ebx
  801095:	75 ec                	jne    801083 <close_all+0xc>
		close(i);
}
  801097:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80109a:	c9                   	leave  
  80109b:	c3                   	ret    

0080109c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80109c:	55                   	push   %ebp
  80109d:	89 e5                	mov    %esp,%ebp
  80109f:	57                   	push   %edi
  8010a0:	56                   	push   %esi
  8010a1:	53                   	push   %ebx
  8010a2:	83 ec 2c             	sub    $0x2c,%esp
  8010a5:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010a8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010ab:	50                   	push   %eax
  8010ac:	ff 75 08             	pushl  0x8(%ebp)
  8010af:	e8 6e fe ff ff       	call   800f22 <fd_lookup>
  8010b4:	83 c4 08             	add    $0x8,%esp
  8010b7:	85 c0                	test   %eax,%eax
  8010b9:	0f 88 c1 00 00 00    	js     801180 <dup+0xe4>
		return r;
	close(newfdnum);
  8010bf:	83 ec 0c             	sub    $0xc,%esp
  8010c2:	56                   	push   %esi
  8010c3:	e8 84 ff ff ff       	call   80104c <close>

	newfd = INDEX2FD(newfdnum);
  8010c8:	89 f3                	mov    %esi,%ebx
  8010ca:	c1 e3 0c             	shl    $0xc,%ebx
  8010cd:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8010d3:	83 c4 04             	add    $0x4,%esp
  8010d6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010d9:	e8 de fd ff ff       	call   800ebc <fd2data>
  8010de:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8010e0:	89 1c 24             	mov    %ebx,(%esp)
  8010e3:	e8 d4 fd ff ff       	call   800ebc <fd2data>
  8010e8:	83 c4 10             	add    $0x10,%esp
  8010eb:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010ee:	89 f8                	mov    %edi,%eax
  8010f0:	c1 e8 16             	shr    $0x16,%eax
  8010f3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010fa:	a8 01                	test   $0x1,%al
  8010fc:	74 37                	je     801135 <dup+0x99>
  8010fe:	89 f8                	mov    %edi,%eax
  801100:	c1 e8 0c             	shr    $0xc,%eax
  801103:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80110a:	f6 c2 01             	test   $0x1,%dl
  80110d:	74 26                	je     801135 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80110f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801116:	83 ec 0c             	sub    $0xc,%esp
  801119:	25 07 0e 00 00       	and    $0xe07,%eax
  80111e:	50                   	push   %eax
  80111f:	ff 75 d4             	pushl  -0x2c(%ebp)
  801122:	6a 00                	push   $0x0
  801124:	57                   	push   %edi
  801125:	6a 00                	push   $0x0
  801127:	e8 b3 fb ff ff       	call   800cdf <sys_page_map>
  80112c:	89 c7                	mov    %eax,%edi
  80112e:	83 c4 20             	add    $0x20,%esp
  801131:	85 c0                	test   %eax,%eax
  801133:	78 2e                	js     801163 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801135:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801138:	89 d0                	mov    %edx,%eax
  80113a:	c1 e8 0c             	shr    $0xc,%eax
  80113d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801144:	83 ec 0c             	sub    $0xc,%esp
  801147:	25 07 0e 00 00       	and    $0xe07,%eax
  80114c:	50                   	push   %eax
  80114d:	53                   	push   %ebx
  80114e:	6a 00                	push   $0x0
  801150:	52                   	push   %edx
  801151:	6a 00                	push   $0x0
  801153:	e8 87 fb ff ff       	call   800cdf <sys_page_map>
  801158:	89 c7                	mov    %eax,%edi
  80115a:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80115d:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80115f:	85 ff                	test   %edi,%edi
  801161:	79 1d                	jns    801180 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801163:	83 ec 08             	sub    $0x8,%esp
  801166:	53                   	push   %ebx
  801167:	6a 00                	push   $0x0
  801169:	e8 b3 fb ff ff       	call   800d21 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80116e:	83 c4 08             	add    $0x8,%esp
  801171:	ff 75 d4             	pushl  -0x2c(%ebp)
  801174:	6a 00                	push   $0x0
  801176:	e8 a6 fb ff ff       	call   800d21 <sys_page_unmap>
	return r;
  80117b:	83 c4 10             	add    $0x10,%esp
  80117e:	89 f8                	mov    %edi,%eax
}
  801180:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801183:	5b                   	pop    %ebx
  801184:	5e                   	pop    %esi
  801185:	5f                   	pop    %edi
  801186:	5d                   	pop    %ebp
  801187:	c3                   	ret    

00801188 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801188:	55                   	push   %ebp
  801189:	89 e5                	mov    %esp,%ebp
  80118b:	53                   	push   %ebx
  80118c:	83 ec 14             	sub    $0x14,%esp
  80118f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801192:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801195:	50                   	push   %eax
  801196:	53                   	push   %ebx
  801197:	e8 86 fd ff ff       	call   800f22 <fd_lookup>
  80119c:	83 c4 08             	add    $0x8,%esp
  80119f:	89 c2                	mov    %eax,%edx
  8011a1:	85 c0                	test   %eax,%eax
  8011a3:	78 6d                	js     801212 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011a5:	83 ec 08             	sub    $0x8,%esp
  8011a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011ab:	50                   	push   %eax
  8011ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011af:	ff 30                	pushl  (%eax)
  8011b1:	e8 c2 fd ff ff       	call   800f78 <dev_lookup>
  8011b6:	83 c4 10             	add    $0x10,%esp
  8011b9:	85 c0                	test   %eax,%eax
  8011bb:	78 4c                	js     801209 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011bd:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011c0:	8b 42 08             	mov    0x8(%edx),%eax
  8011c3:	83 e0 03             	and    $0x3,%eax
  8011c6:	83 f8 01             	cmp    $0x1,%eax
  8011c9:	75 21                	jne    8011ec <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011cb:	a1 08 40 80 00       	mov    0x804008,%eax
  8011d0:	8b 40 48             	mov    0x48(%eax),%eax
  8011d3:	83 ec 04             	sub    $0x4,%esp
  8011d6:	53                   	push   %ebx
  8011d7:	50                   	push   %eax
  8011d8:	68 30 28 80 00       	push   $0x802830
  8011dd:	e8 32 f1 ff ff       	call   800314 <cprintf>
		return -E_INVAL;
  8011e2:	83 c4 10             	add    $0x10,%esp
  8011e5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011ea:	eb 26                	jmp    801212 <read+0x8a>
	}
	if (!dev->dev_read)
  8011ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011ef:	8b 40 08             	mov    0x8(%eax),%eax
  8011f2:	85 c0                	test   %eax,%eax
  8011f4:	74 17                	je     80120d <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011f6:	83 ec 04             	sub    $0x4,%esp
  8011f9:	ff 75 10             	pushl  0x10(%ebp)
  8011fc:	ff 75 0c             	pushl  0xc(%ebp)
  8011ff:	52                   	push   %edx
  801200:	ff d0                	call   *%eax
  801202:	89 c2                	mov    %eax,%edx
  801204:	83 c4 10             	add    $0x10,%esp
  801207:	eb 09                	jmp    801212 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801209:	89 c2                	mov    %eax,%edx
  80120b:	eb 05                	jmp    801212 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80120d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801212:	89 d0                	mov    %edx,%eax
  801214:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801217:	c9                   	leave  
  801218:	c3                   	ret    

00801219 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801219:	55                   	push   %ebp
  80121a:	89 e5                	mov    %esp,%ebp
  80121c:	57                   	push   %edi
  80121d:	56                   	push   %esi
  80121e:	53                   	push   %ebx
  80121f:	83 ec 0c             	sub    $0xc,%esp
  801222:	8b 7d 08             	mov    0x8(%ebp),%edi
  801225:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801228:	bb 00 00 00 00       	mov    $0x0,%ebx
  80122d:	eb 21                	jmp    801250 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80122f:	83 ec 04             	sub    $0x4,%esp
  801232:	89 f0                	mov    %esi,%eax
  801234:	29 d8                	sub    %ebx,%eax
  801236:	50                   	push   %eax
  801237:	89 d8                	mov    %ebx,%eax
  801239:	03 45 0c             	add    0xc(%ebp),%eax
  80123c:	50                   	push   %eax
  80123d:	57                   	push   %edi
  80123e:	e8 45 ff ff ff       	call   801188 <read>
		if (m < 0)
  801243:	83 c4 10             	add    $0x10,%esp
  801246:	85 c0                	test   %eax,%eax
  801248:	78 10                	js     80125a <readn+0x41>
			return m;
		if (m == 0)
  80124a:	85 c0                	test   %eax,%eax
  80124c:	74 0a                	je     801258 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80124e:	01 c3                	add    %eax,%ebx
  801250:	39 f3                	cmp    %esi,%ebx
  801252:	72 db                	jb     80122f <readn+0x16>
  801254:	89 d8                	mov    %ebx,%eax
  801256:	eb 02                	jmp    80125a <readn+0x41>
  801258:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80125a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80125d:	5b                   	pop    %ebx
  80125e:	5e                   	pop    %esi
  80125f:	5f                   	pop    %edi
  801260:	5d                   	pop    %ebp
  801261:	c3                   	ret    

00801262 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801262:	55                   	push   %ebp
  801263:	89 e5                	mov    %esp,%ebp
  801265:	53                   	push   %ebx
  801266:	83 ec 14             	sub    $0x14,%esp
  801269:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80126c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80126f:	50                   	push   %eax
  801270:	53                   	push   %ebx
  801271:	e8 ac fc ff ff       	call   800f22 <fd_lookup>
  801276:	83 c4 08             	add    $0x8,%esp
  801279:	89 c2                	mov    %eax,%edx
  80127b:	85 c0                	test   %eax,%eax
  80127d:	78 68                	js     8012e7 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80127f:	83 ec 08             	sub    $0x8,%esp
  801282:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801285:	50                   	push   %eax
  801286:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801289:	ff 30                	pushl  (%eax)
  80128b:	e8 e8 fc ff ff       	call   800f78 <dev_lookup>
  801290:	83 c4 10             	add    $0x10,%esp
  801293:	85 c0                	test   %eax,%eax
  801295:	78 47                	js     8012de <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801297:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80129a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80129e:	75 21                	jne    8012c1 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8012a0:	a1 08 40 80 00       	mov    0x804008,%eax
  8012a5:	8b 40 48             	mov    0x48(%eax),%eax
  8012a8:	83 ec 04             	sub    $0x4,%esp
  8012ab:	53                   	push   %ebx
  8012ac:	50                   	push   %eax
  8012ad:	68 4c 28 80 00       	push   $0x80284c
  8012b2:	e8 5d f0 ff ff       	call   800314 <cprintf>
		return -E_INVAL;
  8012b7:	83 c4 10             	add    $0x10,%esp
  8012ba:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012bf:	eb 26                	jmp    8012e7 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012c4:	8b 52 0c             	mov    0xc(%edx),%edx
  8012c7:	85 d2                	test   %edx,%edx
  8012c9:	74 17                	je     8012e2 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012cb:	83 ec 04             	sub    $0x4,%esp
  8012ce:	ff 75 10             	pushl  0x10(%ebp)
  8012d1:	ff 75 0c             	pushl  0xc(%ebp)
  8012d4:	50                   	push   %eax
  8012d5:	ff d2                	call   *%edx
  8012d7:	89 c2                	mov    %eax,%edx
  8012d9:	83 c4 10             	add    $0x10,%esp
  8012dc:	eb 09                	jmp    8012e7 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012de:	89 c2                	mov    %eax,%edx
  8012e0:	eb 05                	jmp    8012e7 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8012e2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8012e7:	89 d0                	mov    %edx,%eax
  8012e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012ec:	c9                   	leave  
  8012ed:	c3                   	ret    

008012ee <seek>:

int
seek(int fdnum, off_t offset)
{
  8012ee:	55                   	push   %ebp
  8012ef:	89 e5                	mov    %esp,%ebp
  8012f1:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012f4:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012f7:	50                   	push   %eax
  8012f8:	ff 75 08             	pushl  0x8(%ebp)
  8012fb:	e8 22 fc ff ff       	call   800f22 <fd_lookup>
  801300:	83 c4 08             	add    $0x8,%esp
  801303:	85 c0                	test   %eax,%eax
  801305:	78 0e                	js     801315 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801307:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80130a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80130d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801310:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801315:	c9                   	leave  
  801316:	c3                   	ret    

00801317 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801317:	55                   	push   %ebp
  801318:	89 e5                	mov    %esp,%ebp
  80131a:	53                   	push   %ebx
  80131b:	83 ec 14             	sub    $0x14,%esp
  80131e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801321:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801324:	50                   	push   %eax
  801325:	53                   	push   %ebx
  801326:	e8 f7 fb ff ff       	call   800f22 <fd_lookup>
  80132b:	83 c4 08             	add    $0x8,%esp
  80132e:	89 c2                	mov    %eax,%edx
  801330:	85 c0                	test   %eax,%eax
  801332:	78 65                	js     801399 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801334:	83 ec 08             	sub    $0x8,%esp
  801337:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80133a:	50                   	push   %eax
  80133b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80133e:	ff 30                	pushl  (%eax)
  801340:	e8 33 fc ff ff       	call   800f78 <dev_lookup>
  801345:	83 c4 10             	add    $0x10,%esp
  801348:	85 c0                	test   %eax,%eax
  80134a:	78 44                	js     801390 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80134c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80134f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801353:	75 21                	jne    801376 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801355:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80135a:	8b 40 48             	mov    0x48(%eax),%eax
  80135d:	83 ec 04             	sub    $0x4,%esp
  801360:	53                   	push   %ebx
  801361:	50                   	push   %eax
  801362:	68 0c 28 80 00       	push   $0x80280c
  801367:	e8 a8 ef ff ff       	call   800314 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80136c:	83 c4 10             	add    $0x10,%esp
  80136f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801374:	eb 23                	jmp    801399 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801376:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801379:	8b 52 18             	mov    0x18(%edx),%edx
  80137c:	85 d2                	test   %edx,%edx
  80137e:	74 14                	je     801394 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801380:	83 ec 08             	sub    $0x8,%esp
  801383:	ff 75 0c             	pushl  0xc(%ebp)
  801386:	50                   	push   %eax
  801387:	ff d2                	call   *%edx
  801389:	89 c2                	mov    %eax,%edx
  80138b:	83 c4 10             	add    $0x10,%esp
  80138e:	eb 09                	jmp    801399 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801390:	89 c2                	mov    %eax,%edx
  801392:	eb 05                	jmp    801399 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801394:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801399:	89 d0                	mov    %edx,%eax
  80139b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80139e:	c9                   	leave  
  80139f:	c3                   	ret    

008013a0 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8013a0:	55                   	push   %ebp
  8013a1:	89 e5                	mov    %esp,%ebp
  8013a3:	53                   	push   %ebx
  8013a4:	83 ec 14             	sub    $0x14,%esp
  8013a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013aa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013ad:	50                   	push   %eax
  8013ae:	ff 75 08             	pushl  0x8(%ebp)
  8013b1:	e8 6c fb ff ff       	call   800f22 <fd_lookup>
  8013b6:	83 c4 08             	add    $0x8,%esp
  8013b9:	89 c2                	mov    %eax,%edx
  8013bb:	85 c0                	test   %eax,%eax
  8013bd:	78 58                	js     801417 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013bf:	83 ec 08             	sub    $0x8,%esp
  8013c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013c5:	50                   	push   %eax
  8013c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013c9:	ff 30                	pushl  (%eax)
  8013cb:	e8 a8 fb ff ff       	call   800f78 <dev_lookup>
  8013d0:	83 c4 10             	add    $0x10,%esp
  8013d3:	85 c0                	test   %eax,%eax
  8013d5:	78 37                	js     80140e <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8013d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013da:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013de:	74 32                	je     801412 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013e0:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013e3:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013ea:	00 00 00 
	stat->st_isdir = 0;
  8013ed:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013f4:	00 00 00 
	stat->st_dev = dev;
  8013f7:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013fd:	83 ec 08             	sub    $0x8,%esp
  801400:	53                   	push   %ebx
  801401:	ff 75 f0             	pushl  -0x10(%ebp)
  801404:	ff 50 14             	call   *0x14(%eax)
  801407:	89 c2                	mov    %eax,%edx
  801409:	83 c4 10             	add    $0x10,%esp
  80140c:	eb 09                	jmp    801417 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80140e:	89 c2                	mov    %eax,%edx
  801410:	eb 05                	jmp    801417 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801412:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801417:	89 d0                	mov    %edx,%eax
  801419:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80141c:	c9                   	leave  
  80141d:	c3                   	ret    

0080141e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80141e:	55                   	push   %ebp
  80141f:	89 e5                	mov    %esp,%ebp
  801421:	56                   	push   %esi
  801422:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801423:	83 ec 08             	sub    $0x8,%esp
  801426:	6a 00                	push   $0x0
  801428:	ff 75 08             	pushl  0x8(%ebp)
  80142b:	e8 0c 02 00 00       	call   80163c <open>
  801430:	89 c3                	mov    %eax,%ebx
  801432:	83 c4 10             	add    $0x10,%esp
  801435:	85 c0                	test   %eax,%eax
  801437:	78 1b                	js     801454 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801439:	83 ec 08             	sub    $0x8,%esp
  80143c:	ff 75 0c             	pushl  0xc(%ebp)
  80143f:	50                   	push   %eax
  801440:	e8 5b ff ff ff       	call   8013a0 <fstat>
  801445:	89 c6                	mov    %eax,%esi
	close(fd);
  801447:	89 1c 24             	mov    %ebx,(%esp)
  80144a:	e8 fd fb ff ff       	call   80104c <close>
	return r;
  80144f:	83 c4 10             	add    $0x10,%esp
  801452:	89 f0                	mov    %esi,%eax
}
  801454:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801457:	5b                   	pop    %ebx
  801458:	5e                   	pop    %esi
  801459:	5d                   	pop    %ebp
  80145a:	c3                   	ret    

0080145b <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80145b:	55                   	push   %ebp
  80145c:	89 e5                	mov    %esp,%ebp
  80145e:	56                   	push   %esi
  80145f:	53                   	push   %ebx
  801460:	89 c6                	mov    %eax,%esi
  801462:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801464:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80146b:	75 12                	jne    80147f <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80146d:	83 ec 0c             	sub    $0xc,%esp
  801470:	6a 01                	push   $0x1
  801472:	e8 6c 0c 00 00       	call   8020e3 <ipc_find_env>
  801477:	a3 00 40 80 00       	mov    %eax,0x804000
  80147c:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80147f:	6a 07                	push   $0x7
  801481:	68 00 50 80 00       	push   $0x805000
  801486:	56                   	push   %esi
  801487:	ff 35 00 40 80 00    	pushl  0x804000
  80148d:	e8 fd 0b 00 00       	call   80208f <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801492:	83 c4 0c             	add    $0xc,%esp
  801495:	6a 00                	push   $0x0
  801497:	53                   	push   %ebx
  801498:	6a 00                	push   $0x0
  80149a:	e8 87 0b 00 00       	call   802026 <ipc_recv>
}
  80149f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014a2:	5b                   	pop    %ebx
  8014a3:	5e                   	pop    %esi
  8014a4:	5d                   	pop    %ebp
  8014a5:	c3                   	ret    

008014a6 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8014a6:	55                   	push   %ebp
  8014a7:	89 e5                	mov    %esp,%ebp
  8014a9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8014ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8014af:	8b 40 0c             	mov    0xc(%eax),%eax
  8014b2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8014b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014ba:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8014bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8014c4:	b8 02 00 00 00       	mov    $0x2,%eax
  8014c9:	e8 8d ff ff ff       	call   80145b <fsipc>
}
  8014ce:	c9                   	leave  
  8014cf:	c3                   	ret    

008014d0 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8014d0:	55                   	push   %ebp
  8014d1:	89 e5                	mov    %esp,%ebp
  8014d3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8014d9:	8b 40 0c             	mov    0xc(%eax),%eax
  8014dc:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8014e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8014e6:	b8 06 00 00 00       	mov    $0x6,%eax
  8014eb:	e8 6b ff ff ff       	call   80145b <fsipc>
}
  8014f0:	c9                   	leave  
  8014f1:	c3                   	ret    

008014f2 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8014f2:	55                   	push   %ebp
  8014f3:	89 e5                	mov    %esp,%ebp
  8014f5:	53                   	push   %ebx
  8014f6:	83 ec 04             	sub    $0x4,%esp
  8014f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ff:	8b 40 0c             	mov    0xc(%eax),%eax
  801502:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801507:	ba 00 00 00 00       	mov    $0x0,%edx
  80150c:	b8 05 00 00 00       	mov    $0x5,%eax
  801511:	e8 45 ff ff ff       	call   80145b <fsipc>
  801516:	85 c0                	test   %eax,%eax
  801518:	78 2c                	js     801546 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80151a:	83 ec 08             	sub    $0x8,%esp
  80151d:	68 00 50 80 00       	push   $0x805000
  801522:	53                   	push   %ebx
  801523:	e8 71 f3 ff ff       	call   800899 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801528:	a1 80 50 80 00       	mov    0x805080,%eax
  80152d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801533:	a1 84 50 80 00       	mov    0x805084,%eax
  801538:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80153e:	83 c4 10             	add    $0x10,%esp
  801541:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801546:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801549:	c9                   	leave  
  80154a:	c3                   	ret    

0080154b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80154b:	55                   	push   %ebp
  80154c:	89 e5                	mov    %esp,%ebp
  80154e:	53                   	push   %ebx
  80154f:	83 ec 08             	sub    $0x8,%esp
  801552:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801555:	8b 55 08             	mov    0x8(%ebp),%edx
  801558:	8b 52 0c             	mov    0xc(%edx),%edx
  80155b:	89 15 00 50 80 00    	mov    %edx,0x805000
  801561:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801566:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  80156b:	0f 46 d8             	cmovbe %eax,%ebx
	
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  80156e:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  801574:	53                   	push   %ebx
  801575:	ff 75 0c             	pushl  0xc(%ebp)
  801578:	68 08 50 80 00       	push   $0x805008
  80157d:	e8 a9 f4 ff ff       	call   800a2b <memmove>

	
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) 
  801582:	ba 00 00 00 00       	mov    $0x0,%edx
  801587:	b8 04 00 00 00       	mov    $0x4,%eax
  80158c:	e8 ca fe ff ff       	call   80145b <fsipc>
  801591:	83 c4 10             	add    $0x10,%esp
  801594:	85 c0                	test   %eax,%eax
  801596:	78 1d                	js     8015b5 <devfile_write+0x6a>
		return r;
	assert(r <= n_real); 
  801598:	39 d8                	cmp    %ebx,%eax
  80159a:	76 19                	jbe    8015b5 <devfile_write+0x6a>
  80159c:	68 80 28 80 00       	push   $0x802880
  8015a1:	68 8c 28 80 00       	push   $0x80288c
  8015a6:	68 a3 00 00 00       	push   $0xa3
  8015ab:	68 a1 28 80 00       	push   $0x8028a1
  8015b0:	e8 86 ec ff ff       	call   80023b <_panic>
	return r;
}
  8015b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015b8:	c9                   	leave  
  8015b9:	c3                   	ret    

008015ba <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8015ba:	55                   	push   %ebp
  8015bb:	89 e5                	mov    %esp,%ebp
  8015bd:	56                   	push   %esi
  8015be:	53                   	push   %ebx
  8015bf:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8015c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8015c5:	8b 40 0c             	mov    0xc(%eax),%eax
  8015c8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8015cd:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8015d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8015d8:	b8 03 00 00 00       	mov    $0x3,%eax
  8015dd:	e8 79 fe ff ff       	call   80145b <fsipc>
  8015e2:	89 c3                	mov    %eax,%ebx
  8015e4:	85 c0                	test   %eax,%eax
  8015e6:	78 4b                	js     801633 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8015e8:	39 c6                	cmp    %eax,%esi
  8015ea:	73 16                	jae    801602 <devfile_read+0x48>
  8015ec:	68 ac 28 80 00       	push   $0x8028ac
  8015f1:	68 8c 28 80 00       	push   $0x80288c
  8015f6:	6a 7c                	push   $0x7c
  8015f8:	68 a1 28 80 00       	push   $0x8028a1
  8015fd:	e8 39 ec ff ff       	call   80023b <_panic>
	assert(r <= PGSIZE);
  801602:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801607:	7e 16                	jle    80161f <devfile_read+0x65>
  801609:	68 b3 28 80 00       	push   $0x8028b3
  80160e:	68 8c 28 80 00       	push   $0x80288c
  801613:	6a 7d                	push   $0x7d
  801615:	68 a1 28 80 00       	push   $0x8028a1
  80161a:	e8 1c ec ff ff       	call   80023b <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80161f:	83 ec 04             	sub    $0x4,%esp
  801622:	50                   	push   %eax
  801623:	68 00 50 80 00       	push   $0x805000
  801628:	ff 75 0c             	pushl  0xc(%ebp)
  80162b:	e8 fb f3 ff ff       	call   800a2b <memmove>
	return r;
  801630:	83 c4 10             	add    $0x10,%esp
}
  801633:	89 d8                	mov    %ebx,%eax
  801635:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801638:	5b                   	pop    %ebx
  801639:	5e                   	pop    %esi
  80163a:	5d                   	pop    %ebp
  80163b:	c3                   	ret    

0080163c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80163c:	55                   	push   %ebp
  80163d:	89 e5                	mov    %esp,%ebp
  80163f:	53                   	push   %ebx
  801640:	83 ec 20             	sub    $0x20,%esp
  801643:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801646:	53                   	push   %ebx
  801647:	e8 14 f2 ff ff       	call   800860 <strlen>
  80164c:	83 c4 10             	add    $0x10,%esp
  80164f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801654:	7f 67                	jg     8016bd <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801656:	83 ec 0c             	sub    $0xc,%esp
  801659:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80165c:	50                   	push   %eax
  80165d:	e8 71 f8 ff ff       	call   800ed3 <fd_alloc>
  801662:	83 c4 10             	add    $0x10,%esp
		return r;
  801665:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801667:	85 c0                	test   %eax,%eax
  801669:	78 57                	js     8016c2 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80166b:	83 ec 08             	sub    $0x8,%esp
  80166e:	53                   	push   %ebx
  80166f:	68 00 50 80 00       	push   $0x805000
  801674:	e8 20 f2 ff ff       	call   800899 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801679:	8b 45 0c             	mov    0xc(%ebp),%eax
  80167c:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801681:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801684:	b8 01 00 00 00       	mov    $0x1,%eax
  801689:	e8 cd fd ff ff       	call   80145b <fsipc>
  80168e:	89 c3                	mov    %eax,%ebx
  801690:	83 c4 10             	add    $0x10,%esp
  801693:	85 c0                	test   %eax,%eax
  801695:	79 14                	jns    8016ab <open+0x6f>
		fd_close(fd, 0);
  801697:	83 ec 08             	sub    $0x8,%esp
  80169a:	6a 00                	push   $0x0
  80169c:	ff 75 f4             	pushl  -0xc(%ebp)
  80169f:	e8 27 f9 ff ff       	call   800fcb <fd_close>
		return r;
  8016a4:	83 c4 10             	add    $0x10,%esp
  8016a7:	89 da                	mov    %ebx,%edx
  8016a9:	eb 17                	jmp    8016c2 <open+0x86>
	}

	return fd2num(fd);
  8016ab:	83 ec 0c             	sub    $0xc,%esp
  8016ae:	ff 75 f4             	pushl  -0xc(%ebp)
  8016b1:	e8 f6 f7 ff ff       	call   800eac <fd2num>
  8016b6:	89 c2                	mov    %eax,%edx
  8016b8:	83 c4 10             	add    $0x10,%esp
  8016bb:	eb 05                	jmp    8016c2 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8016bd:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8016c2:	89 d0                	mov    %edx,%eax
  8016c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016c7:	c9                   	leave  
  8016c8:	c3                   	ret    

008016c9 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8016c9:	55                   	push   %ebp
  8016ca:	89 e5                	mov    %esp,%ebp
  8016cc:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8016cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8016d4:	b8 08 00 00 00       	mov    $0x8,%eax
  8016d9:	e8 7d fd ff ff       	call   80145b <fsipc>
}
  8016de:	c9                   	leave  
  8016df:	c3                   	ret    

008016e0 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8016e0:	55                   	push   %ebp
  8016e1:	89 e5                	mov    %esp,%ebp
  8016e3:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8016e6:	68 bf 28 80 00       	push   $0x8028bf
  8016eb:	ff 75 0c             	pushl  0xc(%ebp)
  8016ee:	e8 a6 f1 ff ff       	call   800899 <strcpy>
	return 0;
}
  8016f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8016f8:	c9                   	leave  
  8016f9:	c3                   	ret    

008016fa <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8016fa:	55                   	push   %ebp
  8016fb:	89 e5                	mov    %esp,%ebp
  8016fd:	53                   	push   %ebx
  8016fe:	83 ec 10             	sub    $0x10,%esp
  801701:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801704:	53                   	push   %ebx
  801705:	e8 12 0a 00 00       	call   80211c <pageref>
  80170a:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  80170d:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801712:	83 f8 01             	cmp    $0x1,%eax
  801715:	75 10                	jne    801727 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801717:	83 ec 0c             	sub    $0xc,%esp
  80171a:	ff 73 0c             	pushl  0xc(%ebx)
  80171d:	e8 c0 02 00 00       	call   8019e2 <nsipc_close>
  801722:	89 c2                	mov    %eax,%edx
  801724:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801727:	89 d0                	mov    %edx,%eax
  801729:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80172c:	c9                   	leave  
  80172d:	c3                   	ret    

0080172e <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  80172e:	55                   	push   %ebp
  80172f:	89 e5                	mov    %esp,%ebp
  801731:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801734:	6a 00                	push   $0x0
  801736:	ff 75 10             	pushl  0x10(%ebp)
  801739:	ff 75 0c             	pushl  0xc(%ebp)
  80173c:	8b 45 08             	mov    0x8(%ebp),%eax
  80173f:	ff 70 0c             	pushl  0xc(%eax)
  801742:	e8 78 03 00 00       	call   801abf <nsipc_send>
}
  801747:	c9                   	leave  
  801748:	c3                   	ret    

00801749 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801749:	55                   	push   %ebp
  80174a:	89 e5                	mov    %esp,%ebp
  80174c:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  80174f:	6a 00                	push   $0x0
  801751:	ff 75 10             	pushl  0x10(%ebp)
  801754:	ff 75 0c             	pushl  0xc(%ebp)
  801757:	8b 45 08             	mov    0x8(%ebp),%eax
  80175a:	ff 70 0c             	pushl  0xc(%eax)
  80175d:	e8 f1 02 00 00       	call   801a53 <nsipc_recv>
}
  801762:	c9                   	leave  
  801763:	c3                   	ret    

00801764 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801764:	55                   	push   %ebp
  801765:	89 e5                	mov    %esp,%ebp
  801767:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  80176a:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80176d:	52                   	push   %edx
  80176e:	50                   	push   %eax
  80176f:	e8 ae f7 ff ff       	call   800f22 <fd_lookup>
  801774:	83 c4 10             	add    $0x10,%esp
  801777:	85 c0                	test   %eax,%eax
  801779:	78 17                	js     801792 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  80177b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80177e:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801784:	39 08                	cmp    %ecx,(%eax)
  801786:	75 05                	jne    80178d <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801788:	8b 40 0c             	mov    0xc(%eax),%eax
  80178b:	eb 05                	jmp    801792 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  80178d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801792:	c9                   	leave  
  801793:	c3                   	ret    

00801794 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801794:	55                   	push   %ebp
  801795:	89 e5                	mov    %esp,%ebp
  801797:	56                   	push   %esi
  801798:	53                   	push   %ebx
  801799:	83 ec 1c             	sub    $0x1c,%esp
  80179c:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  80179e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017a1:	50                   	push   %eax
  8017a2:	e8 2c f7 ff ff       	call   800ed3 <fd_alloc>
  8017a7:	89 c3                	mov    %eax,%ebx
  8017a9:	83 c4 10             	add    $0x10,%esp
  8017ac:	85 c0                	test   %eax,%eax
  8017ae:	78 1b                	js     8017cb <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8017b0:	83 ec 04             	sub    $0x4,%esp
  8017b3:	68 07 04 00 00       	push   $0x407
  8017b8:	ff 75 f4             	pushl  -0xc(%ebp)
  8017bb:	6a 00                	push   $0x0
  8017bd:	e8 da f4 ff ff       	call   800c9c <sys_page_alloc>
  8017c2:	89 c3                	mov    %eax,%ebx
  8017c4:	83 c4 10             	add    $0x10,%esp
  8017c7:	85 c0                	test   %eax,%eax
  8017c9:	79 10                	jns    8017db <alloc_sockfd+0x47>
		nsipc_close(sockid);
  8017cb:	83 ec 0c             	sub    $0xc,%esp
  8017ce:	56                   	push   %esi
  8017cf:	e8 0e 02 00 00       	call   8019e2 <nsipc_close>
		return r;
  8017d4:	83 c4 10             	add    $0x10,%esp
  8017d7:	89 d8                	mov    %ebx,%eax
  8017d9:	eb 24                	jmp    8017ff <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  8017db:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017e4:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8017e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017e9:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8017f0:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8017f3:	83 ec 0c             	sub    $0xc,%esp
  8017f6:	50                   	push   %eax
  8017f7:	e8 b0 f6 ff ff       	call   800eac <fd2num>
  8017fc:	83 c4 10             	add    $0x10,%esp
}
  8017ff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801802:	5b                   	pop    %ebx
  801803:	5e                   	pop    %esi
  801804:	5d                   	pop    %ebp
  801805:	c3                   	ret    

00801806 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801806:	55                   	push   %ebp
  801807:	89 e5                	mov    %esp,%ebp
  801809:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80180c:	8b 45 08             	mov    0x8(%ebp),%eax
  80180f:	e8 50 ff ff ff       	call   801764 <fd2sockid>
		return r;
  801814:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801816:	85 c0                	test   %eax,%eax
  801818:	78 1f                	js     801839 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80181a:	83 ec 04             	sub    $0x4,%esp
  80181d:	ff 75 10             	pushl  0x10(%ebp)
  801820:	ff 75 0c             	pushl  0xc(%ebp)
  801823:	50                   	push   %eax
  801824:	e8 12 01 00 00       	call   80193b <nsipc_accept>
  801829:	83 c4 10             	add    $0x10,%esp
		return r;
  80182c:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80182e:	85 c0                	test   %eax,%eax
  801830:	78 07                	js     801839 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801832:	e8 5d ff ff ff       	call   801794 <alloc_sockfd>
  801837:	89 c1                	mov    %eax,%ecx
}
  801839:	89 c8                	mov    %ecx,%eax
  80183b:	c9                   	leave  
  80183c:	c3                   	ret    

0080183d <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80183d:	55                   	push   %ebp
  80183e:	89 e5                	mov    %esp,%ebp
  801840:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801843:	8b 45 08             	mov    0x8(%ebp),%eax
  801846:	e8 19 ff ff ff       	call   801764 <fd2sockid>
  80184b:	85 c0                	test   %eax,%eax
  80184d:	78 12                	js     801861 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  80184f:	83 ec 04             	sub    $0x4,%esp
  801852:	ff 75 10             	pushl  0x10(%ebp)
  801855:	ff 75 0c             	pushl  0xc(%ebp)
  801858:	50                   	push   %eax
  801859:	e8 2d 01 00 00       	call   80198b <nsipc_bind>
  80185e:	83 c4 10             	add    $0x10,%esp
}
  801861:	c9                   	leave  
  801862:	c3                   	ret    

00801863 <shutdown>:

int
shutdown(int s, int how)
{
  801863:	55                   	push   %ebp
  801864:	89 e5                	mov    %esp,%ebp
  801866:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801869:	8b 45 08             	mov    0x8(%ebp),%eax
  80186c:	e8 f3 fe ff ff       	call   801764 <fd2sockid>
  801871:	85 c0                	test   %eax,%eax
  801873:	78 0f                	js     801884 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801875:	83 ec 08             	sub    $0x8,%esp
  801878:	ff 75 0c             	pushl  0xc(%ebp)
  80187b:	50                   	push   %eax
  80187c:	e8 3f 01 00 00       	call   8019c0 <nsipc_shutdown>
  801881:	83 c4 10             	add    $0x10,%esp
}
  801884:	c9                   	leave  
  801885:	c3                   	ret    

00801886 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801886:	55                   	push   %ebp
  801887:	89 e5                	mov    %esp,%ebp
  801889:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80188c:	8b 45 08             	mov    0x8(%ebp),%eax
  80188f:	e8 d0 fe ff ff       	call   801764 <fd2sockid>
  801894:	85 c0                	test   %eax,%eax
  801896:	78 12                	js     8018aa <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801898:	83 ec 04             	sub    $0x4,%esp
  80189b:	ff 75 10             	pushl  0x10(%ebp)
  80189e:	ff 75 0c             	pushl  0xc(%ebp)
  8018a1:	50                   	push   %eax
  8018a2:	e8 55 01 00 00       	call   8019fc <nsipc_connect>
  8018a7:	83 c4 10             	add    $0x10,%esp
}
  8018aa:	c9                   	leave  
  8018ab:	c3                   	ret    

008018ac <listen>:

int
listen(int s, int backlog)
{
  8018ac:	55                   	push   %ebp
  8018ad:	89 e5                	mov    %esp,%ebp
  8018af:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8018b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b5:	e8 aa fe ff ff       	call   801764 <fd2sockid>
  8018ba:	85 c0                	test   %eax,%eax
  8018bc:	78 0f                	js     8018cd <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8018be:	83 ec 08             	sub    $0x8,%esp
  8018c1:	ff 75 0c             	pushl  0xc(%ebp)
  8018c4:	50                   	push   %eax
  8018c5:	e8 67 01 00 00       	call   801a31 <nsipc_listen>
  8018ca:	83 c4 10             	add    $0x10,%esp
}
  8018cd:	c9                   	leave  
  8018ce:	c3                   	ret    

008018cf <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8018cf:	55                   	push   %ebp
  8018d0:	89 e5                	mov    %esp,%ebp
  8018d2:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8018d5:	ff 75 10             	pushl  0x10(%ebp)
  8018d8:	ff 75 0c             	pushl  0xc(%ebp)
  8018db:	ff 75 08             	pushl  0x8(%ebp)
  8018de:	e8 3a 02 00 00       	call   801b1d <nsipc_socket>
  8018e3:	83 c4 10             	add    $0x10,%esp
  8018e6:	85 c0                	test   %eax,%eax
  8018e8:	78 05                	js     8018ef <socket+0x20>
		return r;
	return alloc_sockfd(r);
  8018ea:	e8 a5 fe ff ff       	call   801794 <alloc_sockfd>
}
  8018ef:	c9                   	leave  
  8018f0:	c3                   	ret    

008018f1 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8018f1:	55                   	push   %ebp
  8018f2:	89 e5                	mov    %esp,%ebp
  8018f4:	53                   	push   %ebx
  8018f5:	83 ec 04             	sub    $0x4,%esp
  8018f8:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8018fa:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801901:	75 12                	jne    801915 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801903:	83 ec 0c             	sub    $0xc,%esp
  801906:	6a 02                	push   $0x2
  801908:	e8 d6 07 00 00       	call   8020e3 <ipc_find_env>
  80190d:	a3 04 40 80 00       	mov    %eax,0x804004
  801912:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801915:	6a 07                	push   $0x7
  801917:	68 00 60 80 00       	push   $0x806000
  80191c:	53                   	push   %ebx
  80191d:	ff 35 04 40 80 00    	pushl  0x804004
  801923:	e8 67 07 00 00       	call   80208f <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801928:	83 c4 0c             	add    $0xc,%esp
  80192b:	6a 00                	push   $0x0
  80192d:	6a 00                	push   $0x0
  80192f:	6a 00                	push   $0x0
  801931:	e8 f0 06 00 00       	call   802026 <ipc_recv>
}
  801936:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801939:	c9                   	leave  
  80193a:	c3                   	ret    

0080193b <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80193b:	55                   	push   %ebp
  80193c:	89 e5                	mov    %esp,%ebp
  80193e:	56                   	push   %esi
  80193f:	53                   	push   %ebx
  801940:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801943:	8b 45 08             	mov    0x8(%ebp),%eax
  801946:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  80194b:	8b 06                	mov    (%esi),%eax
  80194d:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801952:	b8 01 00 00 00       	mov    $0x1,%eax
  801957:	e8 95 ff ff ff       	call   8018f1 <nsipc>
  80195c:	89 c3                	mov    %eax,%ebx
  80195e:	85 c0                	test   %eax,%eax
  801960:	78 20                	js     801982 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801962:	83 ec 04             	sub    $0x4,%esp
  801965:	ff 35 10 60 80 00    	pushl  0x806010
  80196b:	68 00 60 80 00       	push   $0x806000
  801970:	ff 75 0c             	pushl  0xc(%ebp)
  801973:	e8 b3 f0 ff ff       	call   800a2b <memmove>
		*addrlen = ret->ret_addrlen;
  801978:	a1 10 60 80 00       	mov    0x806010,%eax
  80197d:	89 06                	mov    %eax,(%esi)
  80197f:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801982:	89 d8                	mov    %ebx,%eax
  801984:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801987:	5b                   	pop    %ebx
  801988:	5e                   	pop    %esi
  801989:	5d                   	pop    %ebp
  80198a:	c3                   	ret    

0080198b <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80198b:	55                   	push   %ebp
  80198c:	89 e5                	mov    %esp,%ebp
  80198e:	53                   	push   %ebx
  80198f:	83 ec 08             	sub    $0x8,%esp
  801992:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801995:	8b 45 08             	mov    0x8(%ebp),%eax
  801998:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  80199d:	53                   	push   %ebx
  80199e:	ff 75 0c             	pushl  0xc(%ebp)
  8019a1:	68 04 60 80 00       	push   $0x806004
  8019a6:	e8 80 f0 ff ff       	call   800a2b <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8019ab:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  8019b1:	b8 02 00 00 00       	mov    $0x2,%eax
  8019b6:	e8 36 ff ff ff       	call   8018f1 <nsipc>
}
  8019bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019be:	c9                   	leave  
  8019bf:	c3                   	ret    

008019c0 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8019c0:	55                   	push   %ebp
  8019c1:	89 e5                	mov    %esp,%ebp
  8019c3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8019c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  8019ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019d1:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  8019d6:	b8 03 00 00 00       	mov    $0x3,%eax
  8019db:	e8 11 ff ff ff       	call   8018f1 <nsipc>
}
  8019e0:	c9                   	leave  
  8019e1:	c3                   	ret    

008019e2 <nsipc_close>:

int
nsipc_close(int s)
{
  8019e2:	55                   	push   %ebp
  8019e3:	89 e5                	mov    %esp,%ebp
  8019e5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8019e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8019eb:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  8019f0:	b8 04 00 00 00       	mov    $0x4,%eax
  8019f5:	e8 f7 fe ff ff       	call   8018f1 <nsipc>
}
  8019fa:	c9                   	leave  
  8019fb:	c3                   	ret    

008019fc <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8019fc:	55                   	push   %ebp
  8019fd:	89 e5                	mov    %esp,%ebp
  8019ff:	53                   	push   %ebx
  801a00:	83 ec 08             	sub    $0x8,%esp
  801a03:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801a06:	8b 45 08             	mov    0x8(%ebp),%eax
  801a09:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801a0e:	53                   	push   %ebx
  801a0f:	ff 75 0c             	pushl  0xc(%ebp)
  801a12:	68 04 60 80 00       	push   $0x806004
  801a17:	e8 0f f0 ff ff       	call   800a2b <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801a1c:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801a22:	b8 05 00 00 00       	mov    $0x5,%eax
  801a27:	e8 c5 fe ff ff       	call   8018f1 <nsipc>
}
  801a2c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a2f:	c9                   	leave  
  801a30:	c3                   	ret    

00801a31 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801a31:	55                   	push   %ebp
  801a32:	89 e5                	mov    %esp,%ebp
  801a34:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801a37:	8b 45 08             	mov    0x8(%ebp),%eax
  801a3a:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801a3f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a42:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801a47:	b8 06 00 00 00       	mov    $0x6,%eax
  801a4c:	e8 a0 fe ff ff       	call   8018f1 <nsipc>
}
  801a51:	c9                   	leave  
  801a52:	c3                   	ret    

00801a53 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801a53:	55                   	push   %ebp
  801a54:	89 e5                	mov    %esp,%ebp
  801a56:	56                   	push   %esi
  801a57:	53                   	push   %ebx
  801a58:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801a5b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a5e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801a63:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801a69:	8b 45 14             	mov    0x14(%ebp),%eax
  801a6c:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801a71:	b8 07 00 00 00       	mov    $0x7,%eax
  801a76:	e8 76 fe ff ff       	call   8018f1 <nsipc>
  801a7b:	89 c3                	mov    %eax,%ebx
  801a7d:	85 c0                	test   %eax,%eax
  801a7f:	78 35                	js     801ab6 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801a81:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801a86:	7f 04                	jg     801a8c <nsipc_recv+0x39>
  801a88:	39 c6                	cmp    %eax,%esi
  801a8a:	7d 16                	jge    801aa2 <nsipc_recv+0x4f>
  801a8c:	68 cb 28 80 00       	push   $0x8028cb
  801a91:	68 8c 28 80 00       	push   $0x80288c
  801a96:	6a 62                	push   $0x62
  801a98:	68 e0 28 80 00       	push   $0x8028e0
  801a9d:	e8 99 e7 ff ff       	call   80023b <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801aa2:	83 ec 04             	sub    $0x4,%esp
  801aa5:	50                   	push   %eax
  801aa6:	68 00 60 80 00       	push   $0x806000
  801aab:	ff 75 0c             	pushl  0xc(%ebp)
  801aae:	e8 78 ef ff ff       	call   800a2b <memmove>
  801ab3:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801ab6:	89 d8                	mov    %ebx,%eax
  801ab8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801abb:	5b                   	pop    %ebx
  801abc:	5e                   	pop    %esi
  801abd:	5d                   	pop    %ebp
  801abe:	c3                   	ret    

00801abf <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801abf:	55                   	push   %ebp
  801ac0:	89 e5                	mov    %esp,%ebp
  801ac2:	53                   	push   %ebx
  801ac3:	83 ec 04             	sub    $0x4,%esp
  801ac6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801ac9:	8b 45 08             	mov    0x8(%ebp),%eax
  801acc:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801ad1:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801ad7:	7e 16                	jle    801aef <nsipc_send+0x30>
  801ad9:	68 ec 28 80 00       	push   $0x8028ec
  801ade:	68 8c 28 80 00       	push   $0x80288c
  801ae3:	6a 6d                	push   $0x6d
  801ae5:	68 e0 28 80 00       	push   $0x8028e0
  801aea:	e8 4c e7 ff ff       	call   80023b <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801aef:	83 ec 04             	sub    $0x4,%esp
  801af2:	53                   	push   %ebx
  801af3:	ff 75 0c             	pushl  0xc(%ebp)
  801af6:	68 0c 60 80 00       	push   $0x80600c
  801afb:	e8 2b ef ff ff       	call   800a2b <memmove>
	nsipcbuf.send.req_size = size;
  801b00:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801b06:	8b 45 14             	mov    0x14(%ebp),%eax
  801b09:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801b0e:	b8 08 00 00 00       	mov    $0x8,%eax
  801b13:	e8 d9 fd ff ff       	call   8018f1 <nsipc>
}
  801b18:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b1b:	c9                   	leave  
  801b1c:	c3                   	ret    

00801b1d <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801b1d:	55                   	push   %ebp
  801b1e:	89 e5                	mov    %esp,%ebp
  801b20:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801b23:	8b 45 08             	mov    0x8(%ebp),%eax
  801b26:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801b2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b2e:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801b33:	8b 45 10             	mov    0x10(%ebp),%eax
  801b36:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801b3b:	b8 09 00 00 00       	mov    $0x9,%eax
  801b40:	e8 ac fd ff ff       	call   8018f1 <nsipc>
}
  801b45:	c9                   	leave  
  801b46:	c3                   	ret    

00801b47 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b47:	55                   	push   %ebp
  801b48:	89 e5                	mov    %esp,%ebp
  801b4a:	56                   	push   %esi
  801b4b:	53                   	push   %ebx
  801b4c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b4f:	83 ec 0c             	sub    $0xc,%esp
  801b52:	ff 75 08             	pushl  0x8(%ebp)
  801b55:	e8 62 f3 ff ff       	call   800ebc <fd2data>
  801b5a:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b5c:	83 c4 08             	add    $0x8,%esp
  801b5f:	68 f8 28 80 00       	push   $0x8028f8
  801b64:	53                   	push   %ebx
  801b65:	e8 2f ed ff ff       	call   800899 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b6a:	8b 46 04             	mov    0x4(%esi),%eax
  801b6d:	2b 06                	sub    (%esi),%eax
  801b6f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b75:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b7c:	00 00 00 
	stat->st_dev = &devpipe;
  801b7f:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801b86:	30 80 00 
	return 0;
}
  801b89:	b8 00 00 00 00       	mov    $0x0,%eax
  801b8e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b91:	5b                   	pop    %ebx
  801b92:	5e                   	pop    %esi
  801b93:	5d                   	pop    %ebp
  801b94:	c3                   	ret    

00801b95 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b95:	55                   	push   %ebp
  801b96:	89 e5                	mov    %esp,%ebp
  801b98:	53                   	push   %ebx
  801b99:	83 ec 0c             	sub    $0xc,%esp
  801b9c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b9f:	53                   	push   %ebx
  801ba0:	6a 00                	push   $0x0
  801ba2:	e8 7a f1 ff ff       	call   800d21 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ba7:	89 1c 24             	mov    %ebx,(%esp)
  801baa:	e8 0d f3 ff ff       	call   800ebc <fd2data>
  801baf:	83 c4 08             	add    $0x8,%esp
  801bb2:	50                   	push   %eax
  801bb3:	6a 00                	push   $0x0
  801bb5:	e8 67 f1 ff ff       	call   800d21 <sys_page_unmap>
}
  801bba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bbd:	c9                   	leave  
  801bbe:	c3                   	ret    

00801bbf <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801bbf:	55                   	push   %ebp
  801bc0:	89 e5                	mov    %esp,%ebp
  801bc2:	57                   	push   %edi
  801bc3:	56                   	push   %esi
  801bc4:	53                   	push   %ebx
  801bc5:	83 ec 1c             	sub    $0x1c,%esp
  801bc8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801bcb:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801bcd:	a1 08 40 80 00       	mov    0x804008,%eax
  801bd2:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801bd5:	83 ec 0c             	sub    $0xc,%esp
  801bd8:	ff 75 e0             	pushl  -0x20(%ebp)
  801bdb:	e8 3c 05 00 00       	call   80211c <pageref>
  801be0:	89 c3                	mov    %eax,%ebx
  801be2:	89 3c 24             	mov    %edi,(%esp)
  801be5:	e8 32 05 00 00       	call   80211c <pageref>
  801bea:	83 c4 10             	add    $0x10,%esp
  801bed:	39 c3                	cmp    %eax,%ebx
  801bef:	0f 94 c1             	sete   %cl
  801bf2:	0f b6 c9             	movzbl %cl,%ecx
  801bf5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801bf8:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801bfe:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801c01:	39 ce                	cmp    %ecx,%esi
  801c03:	74 1b                	je     801c20 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801c05:	39 c3                	cmp    %eax,%ebx
  801c07:	75 c4                	jne    801bcd <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c09:	8b 42 58             	mov    0x58(%edx),%eax
  801c0c:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c0f:	50                   	push   %eax
  801c10:	56                   	push   %esi
  801c11:	68 ff 28 80 00       	push   $0x8028ff
  801c16:	e8 f9 e6 ff ff       	call   800314 <cprintf>
  801c1b:	83 c4 10             	add    $0x10,%esp
  801c1e:	eb ad                	jmp    801bcd <_pipeisclosed+0xe>
	}
}
  801c20:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c23:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c26:	5b                   	pop    %ebx
  801c27:	5e                   	pop    %esi
  801c28:	5f                   	pop    %edi
  801c29:	5d                   	pop    %ebp
  801c2a:	c3                   	ret    

00801c2b <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c2b:	55                   	push   %ebp
  801c2c:	89 e5                	mov    %esp,%ebp
  801c2e:	57                   	push   %edi
  801c2f:	56                   	push   %esi
  801c30:	53                   	push   %ebx
  801c31:	83 ec 28             	sub    $0x28,%esp
  801c34:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801c37:	56                   	push   %esi
  801c38:	e8 7f f2 ff ff       	call   800ebc <fd2data>
  801c3d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c3f:	83 c4 10             	add    $0x10,%esp
  801c42:	bf 00 00 00 00       	mov    $0x0,%edi
  801c47:	eb 4b                	jmp    801c94 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c49:	89 da                	mov    %ebx,%edx
  801c4b:	89 f0                	mov    %esi,%eax
  801c4d:	e8 6d ff ff ff       	call   801bbf <_pipeisclosed>
  801c52:	85 c0                	test   %eax,%eax
  801c54:	75 48                	jne    801c9e <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c56:	e8 22 f0 ff ff       	call   800c7d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c5b:	8b 43 04             	mov    0x4(%ebx),%eax
  801c5e:	8b 0b                	mov    (%ebx),%ecx
  801c60:	8d 51 20             	lea    0x20(%ecx),%edx
  801c63:	39 d0                	cmp    %edx,%eax
  801c65:	73 e2                	jae    801c49 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c67:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c6a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c6e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c71:	89 c2                	mov    %eax,%edx
  801c73:	c1 fa 1f             	sar    $0x1f,%edx
  801c76:	89 d1                	mov    %edx,%ecx
  801c78:	c1 e9 1b             	shr    $0x1b,%ecx
  801c7b:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c7e:	83 e2 1f             	and    $0x1f,%edx
  801c81:	29 ca                	sub    %ecx,%edx
  801c83:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c87:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c8b:	83 c0 01             	add    $0x1,%eax
  801c8e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c91:	83 c7 01             	add    $0x1,%edi
  801c94:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c97:	75 c2                	jne    801c5b <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c99:	8b 45 10             	mov    0x10(%ebp),%eax
  801c9c:	eb 05                	jmp    801ca3 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c9e:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ca3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ca6:	5b                   	pop    %ebx
  801ca7:	5e                   	pop    %esi
  801ca8:	5f                   	pop    %edi
  801ca9:	5d                   	pop    %ebp
  801caa:	c3                   	ret    

00801cab <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801cab:	55                   	push   %ebp
  801cac:	89 e5                	mov    %esp,%ebp
  801cae:	57                   	push   %edi
  801caf:	56                   	push   %esi
  801cb0:	53                   	push   %ebx
  801cb1:	83 ec 18             	sub    $0x18,%esp
  801cb4:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801cb7:	57                   	push   %edi
  801cb8:	e8 ff f1 ff ff       	call   800ebc <fd2data>
  801cbd:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cbf:	83 c4 10             	add    $0x10,%esp
  801cc2:	bb 00 00 00 00       	mov    $0x0,%ebx
  801cc7:	eb 3d                	jmp    801d06 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801cc9:	85 db                	test   %ebx,%ebx
  801ccb:	74 04                	je     801cd1 <devpipe_read+0x26>
				return i;
  801ccd:	89 d8                	mov    %ebx,%eax
  801ccf:	eb 44                	jmp    801d15 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801cd1:	89 f2                	mov    %esi,%edx
  801cd3:	89 f8                	mov    %edi,%eax
  801cd5:	e8 e5 fe ff ff       	call   801bbf <_pipeisclosed>
  801cda:	85 c0                	test   %eax,%eax
  801cdc:	75 32                	jne    801d10 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801cde:	e8 9a ef ff ff       	call   800c7d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ce3:	8b 06                	mov    (%esi),%eax
  801ce5:	3b 46 04             	cmp    0x4(%esi),%eax
  801ce8:	74 df                	je     801cc9 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801cea:	99                   	cltd   
  801ceb:	c1 ea 1b             	shr    $0x1b,%edx
  801cee:	01 d0                	add    %edx,%eax
  801cf0:	83 e0 1f             	and    $0x1f,%eax
  801cf3:	29 d0                	sub    %edx,%eax
  801cf5:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801cfa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cfd:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801d00:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d03:	83 c3 01             	add    $0x1,%ebx
  801d06:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801d09:	75 d8                	jne    801ce3 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d0b:	8b 45 10             	mov    0x10(%ebp),%eax
  801d0e:	eb 05                	jmp    801d15 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d10:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801d15:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d18:	5b                   	pop    %ebx
  801d19:	5e                   	pop    %esi
  801d1a:	5f                   	pop    %edi
  801d1b:	5d                   	pop    %ebp
  801d1c:	c3                   	ret    

00801d1d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d1d:	55                   	push   %ebp
  801d1e:	89 e5                	mov    %esp,%ebp
  801d20:	56                   	push   %esi
  801d21:	53                   	push   %ebx
  801d22:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d25:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d28:	50                   	push   %eax
  801d29:	e8 a5 f1 ff ff       	call   800ed3 <fd_alloc>
  801d2e:	83 c4 10             	add    $0x10,%esp
  801d31:	89 c2                	mov    %eax,%edx
  801d33:	85 c0                	test   %eax,%eax
  801d35:	0f 88 2c 01 00 00    	js     801e67 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d3b:	83 ec 04             	sub    $0x4,%esp
  801d3e:	68 07 04 00 00       	push   $0x407
  801d43:	ff 75 f4             	pushl  -0xc(%ebp)
  801d46:	6a 00                	push   $0x0
  801d48:	e8 4f ef ff ff       	call   800c9c <sys_page_alloc>
  801d4d:	83 c4 10             	add    $0x10,%esp
  801d50:	89 c2                	mov    %eax,%edx
  801d52:	85 c0                	test   %eax,%eax
  801d54:	0f 88 0d 01 00 00    	js     801e67 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d5a:	83 ec 0c             	sub    $0xc,%esp
  801d5d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d60:	50                   	push   %eax
  801d61:	e8 6d f1 ff ff       	call   800ed3 <fd_alloc>
  801d66:	89 c3                	mov    %eax,%ebx
  801d68:	83 c4 10             	add    $0x10,%esp
  801d6b:	85 c0                	test   %eax,%eax
  801d6d:	0f 88 e2 00 00 00    	js     801e55 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d73:	83 ec 04             	sub    $0x4,%esp
  801d76:	68 07 04 00 00       	push   $0x407
  801d7b:	ff 75 f0             	pushl  -0x10(%ebp)
  801d7e:	6a 00                	push   $0x0
  801d80:	e8 17 ef ff ff       	call   800c9c <sys_page_alloc>
  801d85:	89 c3                	mov    %eax,%ebx
  801d87:	83 c4 10             	add    $0x10,%esp
  801d8a:	85 c0                	test   %eax,%eax
  801d8c:	0f 88 c3 00 00 00    	js     801e55 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d92:	83 ec 0c             	sub    $0xc,%esp
  801d95:	ff 75 f4             	pushl  -0xc(%ebp)
  801d98:	e8 1f f1 ff ff       	call   800ebc <fd2data>
  801d9d:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d9f:	83 c4 0c             	add    $0xc,%esp
  801da2:	68 07 04 00 00       	push   $0x407
  801da7:	50                   	push   %eax
  801da8:	6a 00                	push   $0x0
  801daa:	e8 ed ee ff ff       	call   800c9c <sys_page_alloc>
  801daf:	89 c3                	mov    %eax,%ebx
  801db1:	83 c4 10             	add    $0x10,%esp
  801db4:	85 c0                	test   %eax,%eax
  801db6:	0f 88 89 00 00 00    	js     801e45 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dbc:	83 ec 0c             	sub    $0xc,%esp
  801dbf:	ff 75 f0             	pushl  -0x10(%ebp)
  801dc2:	e8 f5 f0 ff ff       	call   800ebc <fd2data>
  801dc7:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801dce:	50                   	push   %eax
  801dcf:	6a 00                	push   $0x0
  801dd1:	56                   	push   %esi
  801dd2:	6a 00                	push   $0x0
  801dd4:	e8 06 ef ff ff       	call   800cdf <sys_page_map>
  801dd9:	89 c3                	mov    %eax,%ebx
  801ddb:	83 c4 20             	add    $0x20,%esp
  801dde:	85 c0                	test   %eax,%eax
  801de0:	78 55                	js     801e37 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801de2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801de8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801deb:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ded:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801df0:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801df7:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801dfd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e00:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e02:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e05:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801e0c:	83 ec 0c             	sub    $0xc,%esp
  801e0f:	ff 75 f4             	pushl  -0xc(%ebp)
  801e12:	e8 95 f0 ff ff       	call   800eac <fd2num>
  801e17:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e1a:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e1c:	83 c4 04             	add    $0x4,%esp
  801e1f:	ff 75 f0             	pushl  -0x10(%ebp)
  801e22:	e8 85 f0 ff ff       	call   800eac <fd2num>
  801e27:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e2a:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801e2d:	83 c4 10             	add    $0x10,%esp
  801e30:	ba 00 00 00 00       	mov    $0x0,%edx
  801e35:	eb 30                	jmp    801e67 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801e37:	83 ec 08             	sub    $0x8,%esp
  801e3a:	56                   	push   %esi
  801e3b:	6a 00                	push   $0x0
  801e3d:	e8 df ee ff ff       	call   800d21 <sys_page_unmap>
  801e42:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801e45:	83 ec 08             	sub    $0x8,%esp
  801e48:	ff 75 f0             	pushl  -0x10(%ebp)
  801e4b:	6a 00                	push   $0x0
  801e4d:	e8 cf ee ff ff       	call   800d21 <sys_page_unmap>
  801e52:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801e55:	83 ec 08             	sub    $0x8,%esp
  801e58:	ff 75 f4             	pushl  -0xc(%ebp)
  801e5b:	6a 00                	push   $0x0
  801e5d:	e8 bf ee ff ff       	call   800d21 <sys_page_unmap>
  801e62:	83 c4 10             	add    $0x10,%esp
  801e65:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801e67:	89 d0                	mov    %edx,%eax
  801e69:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e6c:	5b                   	pop    %ebx
  801e6d:	5e                   	pop    %esi
  801e6e:	5d                   	pop    %ebp
  801e6f:	c3                   	ret    

00801e70 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e70:	55                   	push   %ebp
  801e71:	89 e5                	mov    %esp,%ebp
  801e73:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e76:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e79:	50                   	push   %eax
  801e7a:	ff 75 08             	pushl  0x8(%ebp)
  801e7d:	e8 a0 f0 ff ff       	call   800f22 <fd_lookup>
  801e82:	83 c4 10             	add    $0x10,%esp
  801e85:	85 c0                	test   %eax,%eax
  801e87:	78 18                	js     801ea1 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e89:	83 ec 0c             	sub    $0xc,%esp
  801e8c:	ff 75 f4             	pushl  -0xc(%ebp)
  801e8f:	e8 28 f0 ff ff       	call   800ebc <fd2data>
	return _pipeisclosed(fd, p);
  801e94:	89 c2                	mov    %eax,%edx
  801e96:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e99:	e8 21 fd ff ff       	call   801bbf <_pipeisclosed>
  801e9e:	83 c4 10             	add    $0x10,%esp
}
  801ea1:	c9                   	leave  
  801ea2:	c3                   	ret    

00801ea3 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ea3:	55                   	push   %ebp
  801ea4:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ea6:	b8 00 00 00 00       	mov    $0x0,%eax
  801eab:	5d                   	pop    %ebp
  801eac:	c3                   	ret    

00801ead <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ead:	55                   	push   %ebp
  801eae:	89 e5                	mov    %esp,%ebp
  801eb0:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801eb3:	68 17 29 80 00       	push   $0x802917
  801eb8:	ff 75 0c             	pushl  0xc(%ebp)
  801ebb:	e8 d9 e9 ff ff       	call   800899 <strcpy>
	return 0;
}
  801ec0:	b8 00 00 00 00       	mov    $0x0,%eax
  801ec5:	c9                   	leave  
  801ec6:	c3                   	ret    

00801ec7 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ec7:	55                   	push   %ebp
  801ec8:	89 e5                	mov    %esp,%ebp
  801eca:	57                   	push   %edi
  801ecb:	56                   	push   %esi
  801ecc:	53                   	push   %ebx
  801ecd:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ed3:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ed8:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ede:	eb 2d                	jmp    801f0d <devcons_write+0x46>
		m = n - tot;
  801ee0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ee3:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801ee5:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801ee8:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801eed:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ef0:	83 ec 04             	sub    $0x4,%esp
  801ef3:	53                   	push   %ebx
  801ef4:	03 45 0c             	add    0xc(%ebp),%eax
  801ef7:	50                   	push   %eax
  801ef8:	57                   	push   %edi
  801ef9:	e8 2d eb ff ff       	call   800a2b <memmove>
		sys_cputs(buf, m);
  801efe:	83 c4 08             	add    $0x8,%esp
  801f01:	53                   	push   %ebx
  801f02:	57                   	push   %edi
  801f03:	e8 d8 ec ff ff       	call   800be0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f08:	01 de                	add    %ebx,%esi
  801f0a:	83 c4 10             	add    $0x10,%esp
  801f0d:	89 f0                	mov    %esi,%eax
  801f0f:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f12:	72 cc                	jb     801ee0 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f14:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f17:	5b                   	pop    %ebx
  801f18:	5e                   	pop    %esi
  801f19:	5f                   	pop    %edi
  801f1a:	5d                   	pop    %ebp
  801f1b:	c3                   	ret    

00801f1c <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f1c:	55                   	push   %ebp
  801f1d:	89 e5                	mov    %esp,%ebp
  801f1f:	83 ec 08             	sub    $0x8,%esp
  801f22:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801f27:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f2b:	74 2a                	je     801f57 <devcons_read+0x3b>
  801f2d:	eb 05                	jmp    801f34 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f2f:	e8 49 ed ff ff       	call   800c7d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f34:	e8 c5 ec ff ff       	call   800bfe <sys_cgetc>
  801f39:	85 c0                	test   %eax,%eax
  801f3b:	74 f2                	je     801f2f <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801f3d:	85 c0                	test   %eax,%eax
  801f3f:	78 16                	js     801f57 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f41:	83 f8 04             	cmp    $0x4,%eax
  801f44:	74 0c                	je     801f52 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801f46:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f49:	88 02                	mov    %al,(%edx)
	return 1;
  801f4b:	b8 01 00 00 00       	mov    $0x1,%eax
  801f50:	eb 05                	jmp    801f57 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f52:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f57:	c9                   	leave  
  801f58:	c3                   	ret    

00801f59 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f59:	55                   	push   %ebp
  801f5a:	89 e5                	mov    %esp,%ebp
  801f5c:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f5f:	8b 45 08             	mov    0x8(%ebp),%eax
  801f62:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f65:	6a 01                	push   $0x1
  801f67:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f6a:	50                   	push   %eax
  801f6b:	e8 70 ec ff ff       	call   800be0 <sys_cputs>
}
  801f70:	83 c4 10             	add    $0x10,%esp
  801f73:	c9                   	leave  
  801f74:	c3                   	ret    

00801f75 <getchar>:

int
getchar(void)
{
  801f75:	55                   	push   %ebp
  801f76:	89 e5                	mov    %esp,%ebp
  801f78:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f7b:	6a 01                	push   $0x1
  801f7d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f80:	50                   	push   %eax
  801f81:	6a 00                	push   $0x0
  801f83:	e8 00 f2 ff ff       	call   801188 <read>
	if (r < 0)
  801f88:	83 c4 10             	add    $0x10,%esp
  801f8b:	85 c0                	test   %eax,%eax
  801f8d:	78 0f                	js     801f9e <getchar+0x29>
		return r;
	if (r < 1)
  801f8f:	85 c0                	test   %eax,%eax
  801f91:	7e 06                	jle    801f99 <getchar+0x24>
		return -E_EOF;
	return c;
  801f93:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f97:	eb 05                	jmp    801f9e <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f99:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f9e:	c9                   	leave  
  801f9f:	c3                   	ret    

00801fa0 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801fa0:	55                   	push   %ebp
  801fa1:	89 e5                	mov    %esp,%ebp
  801fa3:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fa6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fa9:	50                   	push   %eax
  801faa:	ff 75 08             	pushl  0x8(%ebp)
  801fad:	e8 70 ef ff ff       	call   800f22 <fd_lookup>
  801fb2:	83 c4 10             	add    $0x10,%esp
  801fb5:	85 c0                	test   %eax,%eax
  801fb7:	78 11                	js     801fca <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801fb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fbc:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801fc2:	39 10                	cmp    %edx,(%eax)
  801fc4:	0f 94 c0             	sete   %al
  801fc7:	0f b6 c0             	movzbl %al,%eax
}
  801fca:	c9                   	leave  
  801fcb:	c3                   	ret    

00801fcc <opencons>:

int
opencons(void)
{
  801fcc:	55                   	push   %ebp
  801fcd:	89 e5                	mov    %esp,%ebp
  801fcf:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fd2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fd5:	50                   	push   %eax
  801fd6:	e8 f8 ee ff ff       	call   800ed3 <fd_alloc>
  801fdb:	83 c4 10             	add    $0x10,%esp
		return r;
  801fde:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fe0:	85 c0                	test   %eax,%eax
  801fe2:	78 3e                	js     802022 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fe4:	83 ec 04             	sub    $0x4,%esp
  801fe7:	68 07 04 00 00       	push   $0x407
  801fec:	ff 75 f4             	pushl  -0xc(%ebp)
  801fef:	6a 00                	push   $0x0
  801ff1:	e8 a6 ec ff ff       	call   800c9c <sys_page_alloc>
  801ff6:	83 c4 10             	add    $0x10,%esp
		return r;
  801ff9:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ffb:	85 c0                	test   %eax,%eax
  801ffd:	78 23                	js     802022 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801fff:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802005:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802008:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80200a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80200d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802014:	83 ec 0c             	sub    $0xc,%esp
  802017:	50                   	push   %eax
  802018:	e8 8f ee ff ff       	call   800eac <fd2num>
  80201d:	89 c2                	mov    %eax,%edx
  80201f:	83 c4 10             	add    $0x10,%esp
}
  802022:	89 d0                	mov    %edx,%eax
  802024:	c9                   	leave  
  802025:	c3                   	ret    

00802026 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802026:	55                   	push   %ebp
  802027:	89 e5                	mov    %esp,%ebp
  802029:	56                   	push   %esi
  80202a:	53                   	push   %ebx
  80202b:	8b 75 08             	mov    0x8(%ebp),%esi
  80202e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802031:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  802034:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  802036:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  80203b:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  80203e:	83 ec 0c             	sub    $0xc,%esp
  802041:	50                   	push   %eax
  802042:	e8 05 ee ff ff       	call   800e4c <sys_ipc_recv>

	if (r < 0) {
  802047:	83 c4 10             	add    $0x10,%esp
  80204a:	85 c0                	test   %eax,%eax
  80204c:	79 16                	jns    802064 <ipc_recv+0x3e>
		if (from_env_store)
  80204e:	85 f6                	test   %esi,%esi
  802050:	74 06                	je     802058 <ipc_recv+0x32>
			*from_env_store = 0;
  802052:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  802058:	85 db                	test   %ebx,%ebx
  80205a:	74 2c                	je     802088 <ipc_recv+0x62>
			*perm_store = 0;
  80205c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802062:	eb 24                	jmp    802088 <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  802064:	85 f6                	test   %esi,%esi
  802066:	74 0a                	je     802072 <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  802068:	a1 08 40 80 00       	mov    0x804008,%eax
  80206d:	8b 40 74             	mov    0x74(%eax),%eax
  802070:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  802072:	85 db                	test   %ebx,%ebx
  802074:	74 0a                	je     802080 <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  802076:	a1 08 40 80 00       	mov    0x804008,%eax
  80207b:	8b 40 78             	mov    0x78(%eax),%eax
  80207e:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  802080:	a1 08 40 80 00       	mov    0x804008,%eax
  802085:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  802088:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80208b:	5b                   	pop    %ebx
  80208c:	5e                   	pop    %esi
  80208d:	5d                   	pop    %ebp
  80208e:	c3                   	ret    

0080208f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80208f:	55                   	push   %ebp
  802090:	89 e5                	mov    %esp,%ebp
  802092:	57                   	push   %edi
  802093:	56                   	push   %esi
  802094:	53                   	push   %ebx
  802095:	83 ec 0c             	sub    $0xc,%esp
  802098:	8b 7d 08             	mov    0x8(%ebp),%edi
  80209b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80209e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  8020a1:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  8020a3:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  8020a8:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  8020ab:	ff 75 14             	pushl  0x14(%ebp)
  8020ae:	53                   	push   %ebx
  8020af:	56                   	push   %esi
  8020b0:	57                   	push   %edi
  8020b1:	e8 73 ed ff ff       	call   800e29 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  8020b6:	83 c4 10             	add    $0x10,%esp
  8020b9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020bc:	75 07                	jne    8020c5 <ipc_send+0x36>
			sys_yield();
  8020be:	e8 ba eb ff ff       	call   800c7d <sys_yield>
  8020c3:	eb e6                	jmp    8020ab <ipc_send+0x1c>
		} else if (r < 0) {
  8020c5:	85 c0                	test   %eax,%eax
  8020c7:	79 12                	jns    8020db <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  8020c9:	50                   	push   %eax
  8020ca:	68 23 29 80 00       	push   $0x802923
  8020cf:	6a 51                	push   $0x51
  8020d1:	68 30 29 80 00       	push   $0x802930
  8020d6:	e8 60 e1 ff ff       	call   80023b <_panic>
		}
	}
}
  8020db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020de:	5b                   	pop    %ebx
  8020df:	5e                   	pop    %esi
  8020e0:	5f                   	pop    %edi
  8020e1:	5d                   	pop    %ebp
  8020e2:	c3                   	ret    

008020e3 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8020e3:	55                   	push   %ebp
  8020e4:	89 e5                	mov    %esp,%ebp
  8020e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8020e9:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8020ee:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8020f1:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8020f7:	8b 52 50             	mov    0x50(%edx),%edx
  8020fa:	39 ca                	cmp    %ecx,%edx
  8020fc:	75 0d                	jne    80210b <ipc_find_env+0x28>
			return envs[i].env_id;
  8020fe:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802101:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802106:	8b 40 48             	mov    0x48(%eax),%eax
  802109:	eb 0f                	jmp    80211a <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80210b:	83 c0 01             	add    $0x1,%eax
  80210e:	3d 00 04 00 00       	cmp    $0x400,%eax
  802113:	75 d9                	jne    8020ee <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802115:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80211a:	5d                   	pop    %ebp
  80211b:	c3                   	ret    

0080211c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80211c:	55                   	push   %ebp
  80211d:	89 e5                	mov    %esp,%ebp
  80211f:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802122:	89 d0                	mov    %edx,%eax
  802124:	c1 e8 16             	shr    $0x16,%eax
  802127:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80212e:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802133:	f6 c1 01             	test   $0x1,%cl
  802136:	74 1d                	je     802155 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802138:	c1 ea 0c             	shr    $0xc,%edx
  80213b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802142:	f6 c2 01             	test   $0x1,%dl
  802145:	74 0e                	je     802155 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802147:	c1 ea 0c             	shr    $0xc,%edx
  80214a:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802151:	ef 
  802152:	0f b7 c0             	movzwl %ax,%eax
}
  802155:	5d                   	pop    %ebp
  802156:	c3                   	ret    
  802157:	66 90                	xchg   %ax,%ax
  802159:	66 90                	xchg   %ax,%ax
  80215b:	66 90                	xchg   %ax,%ax
  80215d:	66 90                	xchg   %ax,%ax
  80215f:	90                   	nop

00802160 <__udivdi3>:
  802160:	55                   	push   %ebp
  802161:	57                   	push   %edi
  802162:	56                   	push   %esi
  802163:	53                   	push   %ebx
  802164:	83 ec 1c             	sub    $0x1c,%esp
  802167:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80216b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80216f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802173:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802177:	85 f6                	test   %esi,%esi
  802179:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80217d:	89 ca                	mov    %ecx,%edx
  80217f:	89 f8                	mov    %edi,%eax
  802181:	75 3d                	jne    8021c0 <__udivdi3+0x60>
  802183:	39 cf                	cmp    %ecx,%edi
  802185:	0f 87 c5 00 00 00    	ja     802250 <__udivdi3+0xf0>
  80218b:	85 ff                	test   %edi,%edi
  80218d:	89 fd                	mov    %edi,%ebp
  80218f:	75 0b                	jne    80219c <__udivdi3+0x3c>
  802191:	b8 01 00 00 00       	mov    $0x1,%eax
  802196:	31 d2                	xor    %edx,%edx
  802198:	f7 f7                	div    %edi
  80219a:	89 c5                	mov    %eax,%ebp
  80219c:	89 c8                	mov    %ecx,%eax
  80219e:	31 d2                	xor    %edx,%edx
  8021a0:	f7 f5                	div    %ebp
  8021a2:	89 c1                	mov    %eax,%ecx
  8021a4:	89 d8                	mov    %ebx,%eax
  8021a6:	89 cf                	mov    %ecx,%edi
  8021a8:	f7 f5                	div    %ebp
  8021aa:	89 c3                	mov    %eax,%ebx
  8021ac:	89 d8                	mov    %ebx,%eax
  8021ae:	89 fa                	mov    %edi,%edx
  8021b0:	83 c4 1c             	add    $0x1c,%esp
  8021b3:	5b                   	pop    %ebx
  8021b4:	5e                   	pop    %esi
  8021b5:	5f                   	pop    %edi
  8021b6:	5d                   	pop    %ebp
  8021b7:	c3                   	ret    
  8021b8:	90                   	nop
  8021b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021c0:	39 ce                	cmp    %ecx,%esi
  8021c2:	77 74                	ja     802238 <__udivdi3+0xd8>
  8021c4:	0f bd fe             	bsr    %esi,%edi
  8021c7:	83 f7 1f             	xor    $0x1f,%edi
  8021ca:	0f 84 98 00 00 00    	je     802268 <__udivdi3+0x108>
  8021d0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8021d5:	89 f9                	mov    %edi,%ecx
  8021d7:	89 c5                	mov    %eax,%ebp
  8021d9:	29 fb                	sub    %edi,%ebx
  8021db:	d3 e6                	shl    %cl,%esi
  8021dd:	89 d9                	mov    %ebx,%ecx
  8021df:	d3 ed                	shr    %cl,%ebp
  8021e1:	89 f9                	mov    %edi,%ecx
  8021e3:	d3 e0                	shl    %cl,%eax
  8021e5:	09 ee                	or     %ebp,%esi
  8021e7:	89 d9                	mov    %ebx,%ecx
  8021e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021ed:	89 d5                	mov    %edx,%ebp
  8021ef:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021f3:	d3 ed                	shr    %cl,%ebp
  8021f5:	89 f9                	mov    %edi,%ecx
  8021f7:	d3 e2                	shl    %cl,%edx
  8021f9:	89 d9                	mov    %ebx,%ecx
  8021fb:	d3 e8                	shr    %cl,%eax
  8021fd:	09 c2                	or     %eax,%edx
  8021ff:	89 d0                	mov    %edx,%eax
  802201:	89 ea                	mov    %ebp,%edx
  802203:	f7 f6                	div    %esi
  802205:	89 d5                	mov    %edx,%ebp
  802207:	89 c3                	mov    %eax,%ebx
  802209:	f7 64 24 0c          	mull   0xc(%esp)
  80220d:	39 d5                	cmp    %edx,%ebp
  80220f:	72 10                	jb     802221 <__udivdi3+0xc1>
  802211:	8b 74 24 08          	mov    0x8(%esp),%esi
  802215:	89 f9                	mov    %edi,%ecx
  802217:	d3 e6                	shl    %cl,%esi
  802219:	39 c6                	cmp    %eax,%esi
  80221b:	73 07                	jae    802224 <__udivdi3+0xc4>
  80221d:	39 d5                	cmp    %edx,%ebp
  80221f:	75 03                	jne    802224 <__udivdi3+0xc4>
  802221:	83 eb 01             	sub    $0x1,%ebx
  802224:	31 ff                	xor    %edi,%edi
  802226:	89 d8                	mov    %ebx,%eax
  802228:	89 fa                	mov    %edi,%edx
  80222a:	83 c4 1c             	add    $0x1c,%esp
  80222d:	5b                   	pop    %ebx
  80222e:	5e                   	pop    %esi
  80222f:	5f                   	pop    %edi
  802230:	5d                   	pop    %ebp
  802231:	c3                   	ret    
  802232:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802238:	31 ff                	xor    %edi,%edi
  80223a:	31 db                	xor    %ebx,%ebx
  80223c:	89 d8                	mov    %ebx,%eax
  80223e:	89 fa                	mov    %edi,%edx
  802240:	83 c4 1c             	add    $0x1c,%esp
  802243:	5b                   	pop    %ebx
  802244:	5e                   	pop    %esi
  802245:	5f                   	pop    %edi
  802246:	5d                   	pop    %ebp
  802247:	c3                   	ret    
  802248:	90                   	nop
  802249:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802250:	89 d8                	mov    %ebx,%eax
  802252:	f7 f7                	div    %edi
  802254:	31 ff                	xor    %edi,%edi
  802256:	89 c3                	mov    %eax,%ebx
  802258:	89 d8                	mov    %ebx,%eax
  80225a:	89 fa                	mov    %edi,%edx
  80225c:	83 c4 1c             	add    $0x1c,%esp
  80225f:	5b                   	pop    %ebx
  802260:	5e                   	pop    %esi
  802261:	5f                   	pop    %edi
  802262:	5d                   	pop    %ebp
  802263:	c3                   	ret    
  802264:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802268:	39 ce                	cmp    %ecx,%esi
  80226a:	72 0c                	jb     802278 <__udivdi3+0x118>
  80226c:	31 db                	xor    %ebx,%ebx
  80226e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802272:	0f 87 34 ff ff ff    	ja     8021ac <__udivdi3+0x4c>
  802278:	bb 01 00 00 00       	mov    $0x1,%ebx
  80227d:	e9 2a ff ff ff       	jmp    8021ac <__udivdi3+0x4c>
  802282:	66 90                	xchg   %ax,%ax
  802284:	66 90                	xchg   %ax,%ax
  802286:	66 90                	xchg   %ax,%ax
  802288:	66 90                	xchg   %ax,%ax
  80228a:	66 90                	xchg   %ax,%ax
  80228c:	66 90                	xchg   %ax,%ax
  80228e:	66 90                	xchg   %ax,%ax

00802290 <__umoddi3>:
  802290:	55                   	push   %ebp
  802291:	57                   	push   %edi
  802292:	56                   	push   %esi
  802293:	53                   	push   %ebx
  802294:	83 ec 1c             	sub    $0x1c,%esp
  802297:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80229b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80229f:	8b 74 24 34          	mov    0x34(%esp),%esi
  8022a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8022a7:	85 d2                	test   %edx,%edx
  8022a9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8022ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022b1:	89 f3                	mov    %esi,%ebx
  8022b3:	89 3c 24             	mov    %edi,(%esp)
  8022b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022ba:	75 1c                	jne    8022d8 <__umoddi3+0x48>
  8022bc:	39 f7                	cmp    %esi,%edi
  8022be:	76 50                	jbe    802310 <__umoddi3+0x80>
  8022c0:	89 c8                	mov    %ecx,%eax
  8022c2:	89 f2                	mov    %esi,%edx
  8022c4:	f7 f7                	div    %edi
  8022c6:	89 d0                	mov    %edx,%eax
  8022c8:	31 d2                	xor    %edx,%edx
  8022ca:	83 c4 1c             	add    $0x1c,%esp
  8022cd:	5b                   	pop    %ebx
  8022ce:	5e                   	pop    %esi
  8022cf:	5f                   	pop    %edi
  8022d0:	5d                   	pop    %ebp
  8022d1:	c3                   	ret    
  8022d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022d8:	39 f2                	cmp    %esi,%edx
  8022da:	89 d0                	mov    %edx,%eax
  8022dc:	77 52                	ja     802330 <__umoddi3+0xa0>
  8022de:	0f bd ea             	bsr    %edx,%ebp
  8022e1:	83 f5 1f             	xor    $0x1f,%ebp
  8022e4:	75 5a                	jne    802340 <__umoddi3+0xb0>
  8022e6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8022ea:	0f 82 e0 00 00 00    	jb     8023d0 <__umoddi3+0x140>
  8022f0:	39 0c 24             	cmp    %ecx,(%esp)
  8022f3:	0f 86 d7 00 00 00    	jbe    8023d0 <__umoddi3+0x140>
  8022f9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8022fd:	8b 54 24 04          	mov    0x4(%esp),%edx
  802301:	83 c4 1c             	add    $0x1c,%esp
  802304:	5b                   	pop    %ebx
  802305:	5e                   	pop    %esi
  802306:	5f                   	pop    %edi
  802307:	5d                   	pop    %ebp
  802308:	c3                   	ret    
  802309:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802310:	85 ff                	test   %edi,%edi
  802312:	89 fd                	mov    %edi,%ebp
  802314:	75 0b                	jne    802321 <__umoddi3+0x91>
  802316:	b8 01 00 00 00       	mov    $0x1,%eax
  80231b:	31 d2                	xor    %edx,%edx
  80231d:	f7 f7                	div    %edi
  80231f:	89 c5                	mov    %eax,%ebp
  802321:	89 f0                	mov    %esi,%eax
  802323:	31 d2                	xor    %edx,%edx
  802325:	f7 f5                	div    %ebp
  802327:	89 c8                	mov    %ecx,%eax
  802329:	f7 f5                	div    %ebp
  80232b:	89 d0                	mov    %edx,%eax
  80232d:	eb 99                	jmp    8022c8 <__umoddi3+0x38>
  80232f:	90                   	nop
  802330:	89 c8                	mov    %ecx,%eax
  802332:	89 f2                	mov    %esi,%edx
  802334:	83 c4 1c             	add    $0x1c,%esp
  802337:	5b                   	pop    %ebx
  802338:	5e                   	pop    %esi
  802339:	5f                   	pop    %edi
  80233a:	5d                   	pop    %ebp
  80233b:	c3                   	ret    
  80233c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802340:	8b 34 24             	mov    (%esp),%esi
  802343:	bf 20 00 00 00       	mov    $0x20,%edi
  802348:	89 e9                	mov    %ebp,%ecx
  80234a:	29 ef                	sub    %ebp,%edi
  80234c:	d3 e0                	shl    %cl,%eax
  80234e:	89 f9                	mov    %edi,%ecx
  802350:	89 f2                	mov    %esi,%edx
  802352:	d3 ea                	shr    %cl,%edx
  802354:	89 e9                	mov    %ebp,%ecx
  802356:	09 c2                	or     %eax,%edx
  802358:	89 d8                	mov    %ebx,%eax
  80235a:	89 14 24             	mov    %edx,(%esp)
  80235d:	89 f2                	mov    %esi,%edx
  80235f:	d3 e2                	shl    %cl,%edx
  802361:	89 f9                	mov    %edi,%ecx
  802363:	89 54 24 04          	mov    %edx,0x4(%esp)
  802367:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80236b:	d3 e8                	shr    %cl,%eax
  80236d:	89 e9                	mov    %ebp,%ecx
  80236f:	89 c6                	mov    %eax,%esi
  802371:	d3 e3                	shl    %cl,%ebx
  802373:	89 f9                	mov    %edi,%ecx
  802375:	89 d0                	mov    %edx,%eax
  802377:	d3 e8                	shr    %cl,%eax
  802379:	89 e9                	mov    %ebp,%ecx
  80237b:	09 d8                	or     %ebx,%eax
  80237d:	89 d3                	mov    %edx,%ebx
  80237f:	89 f2                	mov    %esi,%edx
  802381:	f7 34 24             	divl   (%esp)
  802384:	89 d6                	mov    %edx,%esi
  802386:	d3 e3                	shl    %cl,%ebx
  802388:	f7 64 24 04          	mull   0x4(%esp)
  80238c:	39 d6                	cmp    %edx,%esi
  80238e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802392:	89 d1                	mov    %edx,%ecx
  802394:	89 c3                	mov    %eax,%ebx
  802396:	72 08                	jb     8023a0 <__umoddi3+0x110>
  802398:	75 11                	jne    8023ab <__umoddi3+0x11b>
  80239a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80239e:	73 0b                	jae    8023ab <__umoddi3+0x11b>
  8023a0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8023a4:	1b 14 24             	sbb    (%esp),%edx
  8023a7:	89 d1                	mov    %edx,%ecx
  8023a9:	89 c3                	mov    %eax,%ebx
  8023ab:	8b 54 24 08          	mov    0x8(%esp),%edx
  8023af:	29 da                	sub    %ebx,%edx
  8023b1:	19 ce                	sbb    %ecx,%esi
  8023b3:	89 f9                	mov    %edi,%ecx
  8023b5:	89 f0                	mov    %esi,%eax
  8023b7:	d3 e0                	shl    %cl,%eax
  8023b9:	89 e9                	mov    %ebp,%ecx
  8023bb:	d3 ea                	shr    %cl,%edx
  8023bd:	89 e9                	mov    %ebp,%ecx
  8023bf:	d3 ee                	shr    %cl,%esi
  8023c1:	09 d0                	or     %edx,%eax
  8023c3:	89 f2                	mov    %esi,%edx
  8023c5:	83 c4 1c             	add    $0x1c,%esp
  8023c8:	5b                   	pop    %ebx
  8023c9:	5e                   	pop    %esi
  8023ca:	5f                   	pop    %edi
  8023cb:	5d                   	pop    %ebp
  8023cc:	c3                   	ret    
  8023cd:	8d 76 00             	lea    0x0(%esi),%esi
  8023d0:	29 f9                	sub    %edi,%ecx
  8023d2:	19 d6                	sbb    %edx,%esi
  8023d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023d8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8023dc:	e9 18 ff ff ff       	jmp    8022f9 <__umoddi3+0x69>
