
obj/net/testoutput:     file format elf32-i386


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
  80002c:	e8 9b 01 00 00       	call   8001cc <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
static struct jif_pkt *pkt = (struct jif_pkt*)REQVA;


void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
	envid_t ns_envid = sys_getenvid();
  800038:	e8 12 0c 00 00       	call   800c4f <sys_getenvid>
  80003d:	89 c6                	mov    %eax,%esi
	int i, r;

	binaryname = "testoutput";
  80003f:	c7 05 00 30 80 00 00 	movl   $0x802700,0x803000
  800046:	27 80 00 

	output_envid = fork();
  800049:	e8 03 10 00 00       	call   801051 <fork>
  80004e:	a3 00 40 80 00       	mov    %eax,0x804000
	if (output_envid < 0)
  800053:	85 c0                	test   %eax,%eax
  800055:	79 14                	jns    80006b <umain+0x38>
		panic("error forking");
  800057:	83 ec 04             	sub    $0x4,%esp
  80005a:	68 0b 27 80 00       	push   $0x80270b
  80005f:	6a 16                	push   $0x16
  800061:	68 19 27 80 00       	push   $0x802719
  800066:	e8 c1 01 00 00       	call   80022c <_panic>
  80006b:	bb 00 00 00 00       	mov    $0x0,%ebx
	else if (output_envid == 0) {
  800070:	85 c0                	test   %eax,%eax
  800072:	75 11                	jne    800085 <umain+0x52>
		output(ns_envid);
  800074:	83 ec 0c             	sub    $0xc,%esp
  800077:	56                   	push   %esi
  800078:	e8 40 01 00 00       	call   8001bd <output>
		return;
  80007d:	83 c4 10             	add    $0x10,%esp
  800080:	e9 8f 00 00 00       	jmp    800114 <umain+0xe1>
	}

	for (i = 0; i < TESTOUTPUT_COUNT; i++) {
		if ((r = sys_page_alloc(0, pkt, PTE_P|PTE_U|PTE_W)) < 0)
  800085:	83 ec 04             	sub    $0x4,%esp
  800088:	6a 07                	push   $0x7
  80008a:	68 00 b0 fe 0f       	push   $0xffeb000
  80008f:	6a 00                	push   $0x0
  800091:	e8 f7 0b 00 00       	call   800c8d <sys_page_alloc>
  800096:	83 c4 10             	add    $0x10,%esp
  800099:	85 c0                	test   %eax,%eax
  80009b:	79 12                	jns    8000af <umain+0x7c>
			panic("sys_page_alloc: %e", r);
  80009d:	50                   	push   %eax
  80009e:	68 2a 27 80 00       	push   $0x80272a
  8000a3:	6a 1e                	push   $0x1e
  8000a5:	68 19 27 80 00       	push   $0x802719
  8000aa:	e8 7d 01 00 00       	call   80022c <_panic>
		pkt->jp_len = snprintf(pkt->jp_data,
  8000af:	53                   	push   %ebx
  8000b0:	68 3d 27 80 00       	push   $0x80273d
  8000b5:	68 fc 0f 00 00       	push   $0xffc
  8000ba:	68 04 b0 fe 0f       	push   $0xffeb004
  8000bf:	e8 73 07 00 00       	call   800837 <snprintf>
  8000c4:	a3 00 b0 fe 0f       	mov    %eax,0xffeb000
				       PGSIZE - sizeof(pkt->jp_len),
				       "Packet %02d", i);
		cprintf("Transmitting packet %d\n", i);
  8000c9:	83 c4 08             	add    $0x8,%esp
  8000cc:	53                   	push   %ebx
  8000cd:	68 49 27 80 00       	push   $0x802749
  8000d2:	e8 2e 02 00 00       	call   800305 <cprintf>
		ipc_send(output_envid, NSREQ_OUTPUT, pkt, PTE_P|PTE_W|PTE_U);
  8000d7:	6a 07                	push   $0x7
  8000d9:	68 00 b0 fe 0f       	push   $0xffeb000
  8000de:	6a 0b                	push   $0xb
  8000e0:	ff 35 00 40 80 00    	pushl  0x804000
  8000e6:	e8 c4 10 00 00       	call   8011af <ipc_send>
		sys_page_unmap(0, pkt);
  8000eb:	83 c4 18             	add    $0x18,%esp
  8000ee:	68 00 b0 fe 0f       	push   $0xffeb000
  8000f3:	6a 00                	push   $0x0
  8000f5:	e8 18 0c 00 00       	call   800d12 <sys_page_unmap>
	else if (output_envid == 0) {
		output(ns_envid);
		return;
	}

	for (i = 0; i < TESTOUTPUT_COUNT; i++) {
  8000fa:	83 c3 01             	add    $0x1,%ebx
  8000fd:	83 c4 10             	add    $0x10,%esp
  800100:	83 fb 0a             	cmp    $0xa,%ebx
  800103:	75 80                	jne    800085 <umain+0x52>
  800105:	bb 14 00 00 00       	mov    $0x14,%ebx
		sys_page_unmap(0, pkt);
	}

	// Spin for a while, just in case IPC's or packets need to be flushed
	for (i = 0; i < TESTOUTPUT_COUNT*2; i++)
		sys_yield();
  80010a:	e8 5f 0b 00 00       	call   800c6e <sys_yield>
		ipc_send(output_envid, NSREQ_OUTPUT, pkt, PTE_P|PTE_W|PTE_U);
		sys_page_unmap(0, pkt);
	}

	// Spin for a while, just in case IPC's or packets need to be flushed
	for (i = 0; i < TESTOUTPUT_COUNT*2; i++)
  80010f:	83 eb 01             	sub    $0x1,%ebx
  800112:	75 f6                	jne    80010a <umain+0xd7>
		sys_yield();
}
  800114:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800117:	5b                   	pop    %ebx
  800118:	5e                   	pop    %esi
  800119:	5d                   	pop    %ebp
  80011a:	c3                   	ret    

0080011b <timer>:
#include "ns.h"

void
timer(envid_t ns_envid, uint32_t initial_to) {
  80011b:	55                   	push   %ebp
  80011c:	89 e5                	mov    %esp,%ebp
  80011e:	57                   	push   %edi
  80011f:	56                   	push   %esi
  800120:	53                   	push   %ebx
  800121:	83 ec 1c             	sub    $0x1c,%esp
  800124:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	uint32_t stop = sys_time_msec() + initial_to;
  800127:	e8 52 0d 00 00       	call   800e7e <sys_time_msec>
  80012c:	03 45 0c             	add    0xc(%ebp),%eax
  80012f:	89 c3                	mov    %eax,%ebx

	binaryname = "ns_timer";
  800131:	c7 05 00 30 80 00 61 	movl   $0x802761,0x803000
  800138:	27 80 00 

		ipc_send(ns_envid, NSREQ_TIMER, 0, 0);

		while (1) {
			uint32_t to, whom;
			to = ipc_recv((int32_t *) &whom, 0, 0);
  80013b:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  80013e:	eb 05                	jmp    800145 <timer+0x2a>

	binaryname = "ns_timer";

	while (1) {
		while((r = sys_time_msec()) < stop && r >= 0) {
			sys_yield();
  800140:	e8 29 0b 00 00       	call   800c6e <sys_yield>
	uint32_t stop = sys_time_msec() + initial_to;

	binaryname = "ns_timer";

	while (1) {
		while((r = sys_time_msec()) < stop && r >= 0) {
  800145:	e8 34 0d 00 00       	call   800e7e <sys_time_msec>
  80014a:	89 c2                	mov    %eax,%edx
  80014c:	85 c0                	test   %eax,%eax
  80014e:	78 04                	js     800154 <timer+0x39>
  800150:	39 c3                	cmp    %eax,%ebx
  800152:	77 ec                	ja     800140 <timer+0x25>
			sys_yield();
		}
		if (r < 0)
  800154:	85 c0                	test   %eax,%eax
  800156:	79 12                	jns    80016a <timer+0x4f>
			panic("sys_time_msec: %e", r);
  800158:	52                   	push   %edx
  800159:	68 6a 27 80 00       	push   $0x80276a
  80015e:	6a 0f                	push   $0xf
  800160:	68 7c 27 80 00       	push   $0x80277c
  800165:	e8 c2 00 00 00       	call   80022c <_panic>

		ipc_send(ns_envid, NSREQ_TIMER, 0, 0);
  80016a:	6a 00                	push   $0x0
  80016c:	6a 00                	push   $0x0
  80016e:	6a 0c                	push   $0xc
  800170:	56                   	push   %esi
  800171:	e8 39 10 00 00       	call   8011af <ipc_send>
  800176:	83 c4 10             	add    $0x10,%esp

		while (1) {
			uint32_t to, whom;
			to = ipc_recv((int32_t *) &whom, 0, 0);
  800179:	83 ec 04             	sub    $0x4,%esp
  80017c:	6a 00                	push   $0x0
  80017e:	6a 00                	push   $0x0
  800180:	57                   	push   %edi
  800181:	e8 c0 0f 00 00       	call   801146 <ipc_recv>
  800186:	89 c3                	mov    %eax,%ebx

			if (whom != ns_envid) {
  800188:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80018b:	83 c4 10             	add    $0x10,%esp
  80018e:	39 f0                	cmp    %esi,%eax
  800190:	74 13                	je     8001a5 <timer+0x8a>
				cprintf("NS TIMER: timer thread got IPC message from env %x not NS\n", whom);
  800192:	83 ec 08             	sub    $0x8,%esp
  800195:	50                   	push   %eax
  800196:	68 88 27 80 00       	push   $0x802788
  80019b:	e8 65 01 00 00       	call   800305 <cprintf>
				continue;
  8001a0:	83 c4 10             	add    $0x10,%esp
  8001a3:	eb d4                	jmp    800179 <timer+0x5e>
			}

			stop = sys_time_msec() + to;
  8001a5:	e8 d4 0c 00 00       	call   800e7e <sys_time_msec>
  8001aa:	01 c3                	add    %eax,%ebx
  8001ac:	eb 97                	jmp    800145 <timer+0x2a>

008001ae <input>:

extern union Nsipc nsipcbuf;

void
input(envid_t ns_envid)
{
  8001ae:	55                   	push   %ebp
  8001af:	89 e5                	mov    %esp,%ebp
	binaryname = "ns_input";
  8001b1:	c7 05 00 30 80 00 c3 	movl   $0x8027c3,0x803000
  8001b8:	27 80 00 
	// 	- read a packet from the device driver
	//	- send it to the network server
	// Hint: When you IPC a page to the network server, it will be
	// reading from it for a while, so don't immediately receive
	// another packet in to the same physical page.
}
  8001bb:	5d                   	pop    %ebp
  8001bc:	c3                   	ret    

008001bd <output>:

extern union Nsipc nsipcbuf;

void
output(envid_t ns_envid)
{
  8001bd:	55                   	push   %ebp
  8001be:	89 e5                	mov    %esp,%ebp
	binaryname = "ns_output";
  8001c0:	c7 05 00 30 80 00 cc 	movl   $0x8027cc,0x803000
  8001c7:	27 80 00 

	// LAB 6: Your code here:
	// 	- read a packet from the network server
	//	- send the packet to the device driver
}
  8001ca:	5d                   	pop    %ebp
  8001cb:	c3                   	ret    

008001cc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001cc:	55                   	push   %ebp
  8001cd:	89 e5                	mov    %esp,%ebp
  8001cf:	56                   	push   %esi
  8001d0:	53                   	push   %ebx
  8001d1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001d4:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8001d7:	e8 73 0a 00 00       	call   800c4f <sys_getenvid>
  8001dc:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001e1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001e4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001e9:	a3 0c 40 80 00       	mov    %eax,0x80400c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001ee:	85 db                	test   %ebx,%ebx
  8001f0:	7e 07                	jle    8001f9 <libmain+0x2d>
		binaryname = argv[0];
  8001f2:	8b 06                	mov    (%esi),%eax
  8001f4:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8001f9:	83 ec 08             	sub    $0x8,%esp
  8001fc:	56                   	push   %esi
  8001fd:	53                   	push   %ebx
  8001fe:	e8 30 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800203:	e8 0a 00 00 00       	call   800212 <exit>
}
  800208:	83 c4 10             	add    $0x10,%esp
  80020b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80020e:	5b                   	pop    %ebx
  80020f:	5e                   	pop    %esi
  800210:	5d                   	pop    %ebp
  800211:	c3                   	ret    

00800212 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800212:	55                   	push   %ebp
  800213:	89 e5                	mov    %esp,%ebp
  800215:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800218:	e8 ea 11 00 00       	call   801407 <close_all>
	sys_env_destroy(0);
  80021d:	83 ec 0c             	sub    $0xc,%esp
  800220:	6a 00                	push   $0x0
  800222:	e8 e7 09 00 00       	call   800c0e <sys_env_destroy>
}
  800227:	83 c4 10             	add    $0x10,%esp
  80022a:	c9                   	leave  
  80022b:	c3                   	ret    

0080022c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80022c:	55                   	push   %ebp
  80022d:	89 e5                	mov    %esp,%ebp
  80022f:	56                   	push   %esi
  800230:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800231:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800234:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80023a:	e8 10 0a 00 00       	call   800c4f <sys_getenvid>
  80023f:	83 ec 0c             	sub    $0xc,%esp
  800242:	ff 75 0c             	pushl  0xc(%ebp)
  800245:	ff 75 08             	pushl  0x8(%ebp)
  800248:	56                   	push   %esi
  800249:	50                   	push   %eax
  80024a:	68 e0 27 80 00       	push   $0x8027e0
  80024f:	e8 b1 00 00 00       	call   800305 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800254:	83 c4 18             	add    $0x18,%esp
  800257:	53                   	push   %ebx
  800258:	ff 75 10             	pushl  0x10(%ebp)
  80025b:	e8 54 00 00 00       	call   8002b4 <vcprintf>
	cprintf("\n");
  800260:	c7 04 24 5f 27 80 00 	movl   $0x80275f,(%esp)
  800267:	e8 99 00 00 00       	call   800305 <cprintf>
  80026c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80026f:	cc                   	int3   
  800270:	eb fd                	jmp    80026f <_panic+0x43>

00800272 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800272:	55                   	push   %ebp
  800273:	89 e5                	mov    %esp,%ebp
  800275:	53                   	push   %ebx
  800276:	83 ec 04             	sub    $0x4,%esp
  800279:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80027c:	8b 13                	mov    (%ebx),%edx
  80027e:	8d 42 01             	lea    0x1(%edx),%eax
  800281:	89 03                	mov    %eax,(%ebx)
  800283:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800286:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80028a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80028f:	75 1a                	jne    8002ab <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800291:	83 ec 08             	sub    $0x8,%esp
  800294:	68 ff 00 00 00       	push   $0xff
  800299:	8d 43 08             	lea    0x8(%ebx),%eax
  80029c:	50                   	push   %eax
  80029d:	e8 2f 09 00 00       	call   800bd1 <sys_cputs>
		b->idx = 0;
  8002a2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002a8:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002ab:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002b2:	c9                   	leave  
  8002b3:	c3                   	ret    

008002b4 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002b4:	55                   	push   %ebp
  8002b5:	89 e5                	mov    %esp,%ebp
  8002b7:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002bd:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002c4:	00 00 00 
	b.cnt = 0;
  8002c7:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002ce:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002d1:	ff 75 0c             	pushl  0xc(%ebp)
  8002d4:	ff 75 08             	pushl  0x8(%ebp)
  8002d7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002dd:	50                   	push   %eax
  8002de:	68 72 02 80 00       	push   $0x800272
  8002e3:	e8 54 01 00 00       	call   80043c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002e8:	83 c4 08             	add    $0x8,%esp
  8002eb:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002f1:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002f7:	50                   	push   %eax
  8002f8:	e8 d4 08 00 00       	call   800bd1 <sys_cputs>

	return b.cnt;
}
  8002fd:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800303:	c9                   	leave  
  800304:	c3                   	ret    

00800305 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800305:	55                   	push   %ebp
  800306:	89 e5                	mov    %esp,%ebp
  800308:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80030b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80030e:	50                   	push   %eax
  80030f:	ff 75 08             	pushl  0x8(%ebp)
  800312:	e8 9d ff ff ff       	call   8002b4 <vcprintf>
	va_end(ap);

	return cnt;
}
  800317:	c9                   	leave  
  800318:	c3                   	ret    

00800319 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800319:	55                   	push   %ebp
  80031a:	89 e5                	mov    %esp,%ebp
  80031c:	57                   	push   %edi
  80031d:	56                   	push   %esi
  80031e:	53                   	push   %ebx
  80031f:	83 ec 1c             	sub    $0x1c,%esp
  800322:	89 c7                	mov    %eax,%edi
  800324:	89 d6                	mov    %edx,%esi
  800326:	8b 45 08             	mov    0x8(%ebp),%eax
  800329:	8b 55 0c             	mov    0xc(%ebp),%edx
  80032c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80032f:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800332:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800335:	bb 00 00 00 00       	mov    $0x0,%ebx
  80033a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80033d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800340:	39 d3                	cmp    %edx,%ebx
  800342:	72 05                	jb     800349 <printnum+0x30>
  800344:	39 45 10             	cmp    %eax,0x10(%ebp)
  800347:	77 45                	ja     80038e <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800349:	83 ec 0c             	sub    $0xc,%esp
  80034c:	ff 75 18             	pushl  0x18(%ebp)
  80034f:	8b 45 14             	mov    0x14(%ebp),%eax
  800352:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800355:	53                   	push   %ebx
  800356:	ff 75 10             	pushl  0x10(%ebp)
  800359:	83 ec 08             	sub    $0x8,%esp
  80035c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80035f:	ff 75 e0             	pushl  -0x20(%ebp)
  800362:	ff 75 dc             	pushl  -0x24(%ebp)
  800365:	ff 75 d8             	pushl  -0x28(%ebp)
  800368:	e8 03 21 00 00       	call   802470 <__udivdi3>
  80036d:	83 c4 18             	add    $0x18,%esp
  800370:	52                   	push   %edx
  800371:	50                   	push   %eax
  800372:	89 f2                	mov    %esi,%edx
  800374:	89 f8                	mov    %edi,%eax
  800376:	e8 9e ff ff ff       	call   800319 <printnum>
  80037b:	83 c4 20             	add    $0x20,%esp
  80037e:	eb 18                	jmp    800398 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800380:	83 ec 08             	sub    $0x8,%esp
  800383:	56                   	push   %esi
  800384:	ff 75 18             	pushl  0x18(%ebp)
  800387:	ff d7                	call   *%edi
  800389:	83 c4 10             	add    $0x10,%esp
  80038c:	eb 03                	jmp    800391 <printnum+0x78>
  80038e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800391:	83 eb 01             	sub    $0x1,%ebx
  800394:	85 db                	test   %ebx,%ebx
  800396:	7f e8                	jg     800380 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800398:	83 ec 08             	sub    $0x8,%esp
  80039b:	56                   	push   %esi
  80039c:	83 ec 04             	sub    $0x4,%esp
  80039f:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003a2:	ff 75 e0             	pushl  -0x20(%ebp)
  8003a5:	ff 75 dc             	pushl  -0x24(%ebp)
  8003a8:	ff 75 d8             	pushl  -0x28(%ebp)
  8003ab:	e8 f0 21 00 00       	call   8025a0 <__umoddi3>
  8003b0:	83 c4 14             	add    $0x14,%esp
  8003b3:	0f be 80 03 28 80 00 	movsbl 0x802803(%eax),%eax
  8003ba:	50                   	push   %eax
  8003bb:	ff d7                	call   *%edi
}
  8003bd:	83 c4 10             	add    $0x10,%esp
  8003c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003c3:	5b                   	pop    %ebx
  8003c4:	5e                   	pop    %esi
  8003c5:	5f                   	pop    %edi
  8003c6:	5d                   	pop    %ebp
  8003c7:	c3                   	ret    

008003c8 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003c8:	55                   	push   %ebp
  8003c9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003cb:	83 fa 01             	cmp    $0x1,%edx
  8003ce:	7e 0e                	jle    8003de <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003d0:	8b 10                	mov    (%eax),%edx
  8003d2:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003d5:	89 08                	mov    %ecx,(%eax)
  8003d7:	8b 02                	mov    (%edx),%eax
  8003d9:	8b 52 04             	mov    0x4(%edx),%edx
  8003dc:	eb 22                	jmp    800400 <getuint+0x38>
	else if (lflag)
  8003de:	85 d2                	test   %edx,%edx
  8003e0:	74 10                	je     8003f2 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003e2:	8b 10                	mov    (%eax),%edx
  8003e4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003e7:	89 08                	mov    %ecx,(%eax)
  8003e9:	8b 02                	mov    (%edx),%eax
  8003eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8003f0:	eb 0e                	jmp    800400 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003f2:	8b 10                	mov    (%eax),%edx
  8003f4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003f7:	89 08                	mov    %ecx,(%eax)
  8003f9:	8b 02                	mov    (%edx),%eax
  8003fb:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800400:	5d                   	pop    %ebp
  800401:	c3                   	ret    

00800402 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800402:	55                   	push   %ebp
  800403:	89 e5                	mov    %esp,%ebp
  800405:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800408:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80040c:	8b 10                	mov    (%eax),%edx
  80040e:	3b 50 04             	cmp    0x4(%eax),%edx
  800411:	73 0a                	jae    80041d <sprintputch+0x1b>
		*b->buf++ = ch;
  800413:	8d 4a 01             	lea    0x1(%edx),%ecx
  800416:	89 08                	mov    %ecx,(%eax)
  800418:	8b 45 08             	mov    0x8(%ebp),%eax
  80041b:	88 02                	mov    %al,(%edx)
}
  80041d:	5d                   	pop    %ebp
  80041e:	c3                   	ret    

0080041f <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80041f:	55                   	push   %ebp
  800420:	89 e5                	mov    %esp,%ebp
  800422:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800425:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800428:	50                   	push   %eax
  800429:	ff 75 10             	pushl  0x10(%ebp)
  80042c:	ff 75 0c             	pushl  0xc(%ebp)
  80042f:	ff 75 08             	pushl  0x8(%ebp)
  800432:	e8 05 00 00 00       	call   80043c <vprintfmt>
	va_end(ap);
}
  800437:	83 c4 10             	add    $0x10,%esp
  80043a:	c9                   	leave  
  80043b:	c3                   	ret    

0080043c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80043c:	55                   	push   %ebp
  80043d:	89 e5                	mov    %esp,%ebp
  80043f:	57                   	push   %edi
  800440:	56                   	push   %esi
  800441:	53                   	push   %ebx
  800442:	83 ec 2c             	sub    $0x2c,%esp
  800445:	8b 75 08             	mov    0x8(%ebp),%esi
  800448:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80044b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80044e:	eb 12                	jmp    800462 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800450:	85 c0                	test   %eax,%eax
  800452:	0f 84 89 03 00 00    	je     8007e1 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800458:	83 ec 08             	sub    $0x8,%esp
  80045b:	53                   	push   %ebx
  80045c:	50                   	push   %eax
  80045d:	ff d6                	call   *%esi
  80045f:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800462:	83 c7 01             	add    $0x1,%edi
  800465:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800469:	83 f8 25             	cmp    $0x25,%eax
  80046c:	75 e2                	jne    800450 <vprintfmt+0x14>
  80046e:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800472:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800479:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800480:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800487:	ba 00 00 00 00       	mov    $0x0,%edx
  80048c:	eb 07                	jmp    800495 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048e:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800491:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800495:	8d 47 01             	lea    0x1(%edi),%eax
  800498:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80049b:	0f b6 07             	movzbl (%edi),%eax
  80049e:	0f b6 c8             	movzbl %al,%ecx
  8004a1:	83 e8 23             	sub    $0x23,%eax
  8004a4:	3c 55                	cmp    $0x55,%al
  8004a6:	0f 87 1a 03 00 00    	ja     8007c6 <vprintfmt+0x38a>
  8004ac:	0f b6 c0             	movzbl %al,%eax
  8004af:	ff 24 85 40 29 80 00 	jmp    *0x802940(,%eax,4)
  8004b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004b9:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004bd:	eb d6                	jmp    800495 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004ca:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004cd:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8004d1:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8004d4:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8004d7:	83 fa 09             	cmp    $0x9,%edx
  8004da:	77 39                	ja     800515 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004dc:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004df:	eb e9                	jmp    8004ca <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e4:	8d 48 04             	lea    0x4(%eax),%ecx
  8004e7:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004ea:	8b 00                	mov    (%eax),%eax
  8004ec:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004f2:	eb 27                	jmp    80051b <vprintfmt+0xdf>
  8004f4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004f7:	85 c0                	test   %eax,%eax
  8004f9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004fe:	0f 49 c8             	cmovns %eax,%ecx
  800501:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800504:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800507:	eb 8c                	jmp    800495 <vprintfmt+0x59>
  800509:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80050c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800513:	eb 80                	jmp    800495 <vprintfmt+0x59>
  800515:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800518:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80051b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80051f:	0f 89 70 ff ff ff    	jns    800495 <vprintfmt+0x59>
				width = precision, precision = -1;
  800525:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800528:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80052b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800532:	e9 5e ff ff ff       	jmp    800495 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800537:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80053d:	e9 53 ff ff ff       	jmp    800495 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800542:	8b 45 14             	mov    0x14(%ebp),%eax
  800545:	8d 50 04             	lea    0x4(%eax),%edx
  800548:	89 55 14             	mov    %edx,0x14(%ebp)
  80054b:	83 ec 08             	sub    $0x8,%esp
  80054e:	53                   	push   %ebx
  80054f:	ff 30                	pushl  (%eax)
  800551:	ff d6                	call   *%esi
			break;
  800553:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800556:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800559:	e9 04 ff ff ff       	jmp    800462 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80055e:	8b 45 14             	mov    0x14(%ebp),%eax
  800561:	8d 50 04             	lea    0x4(%eax),%edx
  800564:	89 55 14             	mov    %edx,0x14(%ebp)
  800567:	8b 00                	mov    (%eax),%eax
  800569:	99                   	cltd   
  80056a:	31 d0                	xor    %edx,%eax
  80056c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80056e:	83 f8 0f             	cmp    $0xf,%eax
  800571:	7f 0b                	jg     80057e <vprintfmt+0x142>
  800573:	8b 14 85 a0 2a 80 00 	mov    0x802aa0(,%eax,4),%edx
  80057a:	85 d2                	test   %edx,%edx
  80057c:	75 18                	jne    800596 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80057e:	50                   	push   %eax
  80057f:	68 1b 28 80 00       	push   $0x80281b
  800584:	53                   	push   %ebx
  800585:	56                   	push   %esi
  800586:	e8 94 fe ff ff       	call   80041f <printfmt>
  80058b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800591:	e9 cc fe ff ff       	jmp    800462 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800596:	52                   	push   %edx
  800597:	68 62 2c 80 00       	push   $0x802c62
  80059c:	53                   	push   %ebx
  80059d:	56                   	push   %esi
  80059e:	e8 7c fe ff ff       	call   80041f <printfmt>
  8005a3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a9:	e9 b4 fe ff ff       	jmp    800462 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b1:	8d 50 04             	lea    0x4(%eax),%edx
  8005b4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005b9:	85 ff                	test   %edi,%edi
  8005bb:	b8 14 28 80 00       	mov    $0x802814,%eax
  8005c0:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005c3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005c7:	0f 8e 94 00 00 00    	jle    800661 <vprintfmt+0x225>
  8005cd:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005d1:	0f 84 98 00 00 00    	je     80066f <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005d7:	83 ec 08             	sub    $0x8,%esp
  8005da:	ff 75 d0             	pushl  -0x30(%ebp)
  8005dd:	57                   	push   %edi
  8005de:	e8 86 02 00 00       	call   800869 <strnlen>
  8005e3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005e6:	29 c1                	sub    %eax,%ecx
  8005e8:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005eb:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005ee:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005f2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005f5:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005f8:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005fa:	eb 0f                	jmp    80060b <vprintfmt+0x1cf>
					putch(padc, putdat);
  8005fc:	83 ec 08             	sub    $0x8,%esp
  8005ff:	53                   	push   %ebx
  800600:	ff 75 e0             	pushl  -0x20(%ebp)
  800603:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800605:	83 ef 01             	sub    $0x1,%edi
  800608:	83 c4 10             	add    $0x10,%esp
  80060b:	85 ff                	test   %edi,%edi
  80060d:	7f ed                	jg     8005fc <vprintfmt+0x1c0>
  80060f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800612:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800615:	85 c9                	test   %ecx,%ecx
  800617:	b8 00 00 00 00       	mov    $0x0,%eax
  80061c:	0f 49 c1             	cmovns %ecx,%eax
  80061f:	29 c1                	sub    %eax,%ecx
  800621:	89 75 08             	mov    %esi,0x8(%ebp)
  800624:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800627:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80062a:	89 cb                	mov    %ecx,%ebx
  80062c:	eb 4d                	jmp    80067b <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80062e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800632:	74 1b                	je     80064f <vprintfmt+0x213>
  800634:	0f be c0             	movsbl %al,%eax
  800637:	83 e8 20             	sub    $0x20,%eax
  80063a:	83 f8 5e             	cmp    $0x5e,%eax
  80063d:	76 10                	jbe    80064f <vprintfmt+0x213>
					putch('?', putdat);
  80063f:	83 ec 08             	sub    $0x8,%esp
  800642:	ff 75 0c             	pushl  0xc(%ebp)
  800645:	6a 3f                	push   $0x3f
  800647:	ff 55 08             	call   *0x8(%ebp)
  80064a:	83 c4 10             	add    $0x10,%esp
  80064d:	eb 0d                	jmp    80065c <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80064f:	83 ec 08             	sub    $0x8,%esp
  800652:	ff 75 0c             	pushl  0xc(%ebp)
  800655:	52                   	push   %edx
  800656:	ff 55 08             	call   *0x8(%ebp)
  800659:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80065c:	83 eb 01             	sub    $0x1,%ebx
  80065f:	eb 1a                	jmp    80067b <vprintfmt+0x23f>
  800661:	89 75 08             	mov    %esi,0x8(%ebp)
  800664:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800667:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80066a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80066d:	eb 0c                	jmp    80067b <vprintfmt+0x23f>
  80066f:	89 75 08             	mov    %esi,0x8(%ebp)
  800672:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800675:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800678:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80067b:	83 c7 01             	add    $0x1,%edi
  80067e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800682:	0f be d0             	movsbl %al,%edx
  800685:	85 d2                	test   %edx,%edx
  800687:	74 23                	je     8006ac <vprintfmt+0x270>
  800689:	85 f6                	test   %esi,%esi
  80068b:	78 a1                	js     80062e <vprintfmt+0x1f2>
  80068d:	83 ee 01             	sub    $0x1,%esi
  800690:	79 9c                	jns    80062e <vprintfmt+0x1f2>
  800692:	89 df                	mov    %ebx,%edi
  800694:	8b 75 08             	mov    0x8(%ebp),%esi
  800697:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80069a:	eb 18                	jmp    8006b4 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80069c:	83 ec 08             	sub    $0x8,%esp
  80069f:	53                   	push   %ebx
  8006a0:	6a 20                	push   $0x20
  8006a2:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006a4:	83 ef 01             	sub    $0x1,%edi
  8006a7:	83 c4 10             	add    $0x10,%esp
  8006aa:	eb 08                	jmp    8006b4 <vprintfmt+0x278>
  8006ac:	89 df                	mov    %ebx,%edi
  8006ae:	8b 75 08             	mov    0x8(%ebp),%esi
  8006b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006b4:	85 ff                	test   %edi,%edi
  8006b6:	7f e4                	jg     80069c <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006bb:	e9 a2 fd ff ff       	jmp    800462 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006c0:	83 fa 01             	cmp    $0x1,%edx
  8006c3:	7e 16                	jle    8006db <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8006c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c8:	8d 50 08             	lea    0x8(%eax),%edx
  8006cb:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ce:	8b 50 04             	mov    0x4(%eax),%edx
  8006d1:	8b 00                	mov    (%eax),%eax
  8006d3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006d6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006d9:	eb 32                	jmp    80070d <vprintfmt+0x2d1>
	else if (lflag)
  8006db:	85 d2                	test   %edx,%edx
  8006dd:	74 18                	je     8006f7 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8006df:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e2:	8d 50 04             	lea    0x4(%eax),%edx
  8006e5:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e8:	8b 00                	mov    (%eax),%eax
  8006ea:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006ed:	89 c1                	mov    %eax,%ecx
  8006ef:	c1 f9 1f             	sar    $0x1f,%ecx
  8006f2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006f5:	eb 16                	jmp    80070d <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8006f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fa:	8d 50 04             	lea    0x4(%eax),%edx
  8006fd:	89 55 14             	mov    %edx,0x14(%ebp)
  800700:	8b 00                	mov    (%eax),%eax
  800702:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800705:	89 c1                	mov    %eax,%ecx
  800707:	c1 f9 1f             	sar    $0x1f,%ecx
  80070a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80070d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800710:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800713:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800718:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80071c:	79 74                	jns    800792 <vprintfmt+0x356>
				putch('-', putdat);
  80071e:	83 ec 08             	sub    $0x8,%esp
  800721:	53                   	push   %ebx
  800722:	6a 2d                	push   $0x2d
  800724:	ff d6                	call   *%esi
				num = -(long long) num;
  800726:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800729:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80072c:	f7 d8                	neg    %eax
  80072e:	83 d2 00             	adc    $0x0,%edx
  800731:	f7 da                	neg    %edx
  800733:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800736:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80073b:	eb 55                	jmp    800792 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80073d:	8d 45 14             	lea    0x14(%ebp),%eax
  800740:	e8 83 fc ff ff       	call   8003c8 <getuint>
			base = 10;
  800745:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80074a:	eb 46                	jmp    800792 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80074c:	8d 45 14             	lea    0x14(%ebp),%eax
  80074f:	e8 74 fc ff ff       	call   8003c8 <getuint>
                        base = 8;
  800754:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800759:	eb 37                	jmp    800792 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80075b:	83 ec 08             	sub    $0x8,%esp
  80075e:	53                   	push   %ebx
  80075f:	6a 30                	push   $0x30
  800761:	ff d6                	call   *%esi
			putch('x', putdat);
  800763:	83 c4 08             	add    $0x8,%esp
  800766:	53                   	push   %ebx
  800767:	6a 78                	push   $0x78
  800769:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80076b:	8b 45 14             	mov    0x14(%ebp),%eax
  80076e:	8d 50 04             	lea    0x4(%eax),%edx
  800771:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800774:	8b 00                	mov    (%eax),%eax
  800776:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80077b:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80077e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800783:	eb 0d                	jmp    800792 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800785:	8d 45 14             	lea    0x14(%ebp),%eax
  800788:	e8 3b fc ff ff       	call   8003c8 <getuint>
			base = 16;
  80078d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800792:	83 ec 0c             	sub    $0xc,%esp
  800795:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800799:	57                   	push   %edi
  80079a:	ff 75 e0             	pushl  -0x20(%ebp)
  80079d:	51                   	push   %ecx
  80079e:	52                   	push   %edx
  80079f:	50                   	push   %eax
  8007a0:	89 da                	mov    %ebx,%edx
  8007a2:	89 f0                	mov    %esi,%eax
  8007a4:	e8 70 fb ff ff       	call   800319 <printnum>
			break;
  8007a9:	83 c4 20             	add    $0x20,%esp
  8007ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007af:	e9 ae fc ff ff       	jmp    800462 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007b4:	83 ec 08             	sub    $0x8,%esp
  8007b7:	53                   	push   %ebx
  8007b8:	51                   	push   %ecx
  8007b9:	ff d6                	call   *%esi
			break;
  8007bb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007c1:	e9 9c fc ff ff       	jmp    800462 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007c6:	83 ec 08             	sub    $0x8,%esp
  8007c9:	53                   	push   %ebx
  8007ca:	6a 25                	push   $0x25
  8007cc:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007ce:	83 c4 10             	add    $0x10,%esp
  8007d1:	eb 03                	jmp    8007d6 <vprintfmt+0x39a>
  8007d3:	83 ef 01             	sub    $0x1,%edi
  8007d6:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007da:	75 f7                	jne    8007d3 <vprintfmt+0x397>
  8007dc:	e9 81 fc ff ff       	jmp    800462 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007e4:	5b                   	pop    %ebx
  8007e5:	5e                   	pop    %esi
  8007e6:	5f                   	pop    %edi
  8007e7:	5d                   	pop    %ebp
  8007e8:	c3                   	ret    

008007e9 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007e9:	55                   	push   %ebp
  8007ea:	89 e5                	mov    %esp,%ebp
  8007ec:	83 ec 18             	sub    $0x18,%esp
  8007ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f2:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007f5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007f8:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007fc:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007ff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800806:	85 c0                	test   %eax,%eax
  800808:	74 26                	je     800830 <vsnprintf+0x47>
  80080a:	85 d2                	test   %edx,%edx
  80080c:	7e 22                	jle    800830 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80080e:	ff 75 14             	pushl  0x14(%ebp)
  800811:	ff 75 10             	pushl  0x10(%ebp)
  800814:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800817:	50                   	push   %eax
  800818:	68 02 04 80 00       	push   $0x800402
  80081d:	e8 1a fc ff ff       	call   80043c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800822:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800825:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800828:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80082b:	83 c4 10             	add    $0x10,%esp
  80082e:	eb 05                	jmp    800835 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800830:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800835:	c9                   	leave  
  800836:	c3                   	ret    

00800837 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800837:	55                   	push   %ebp
  800838:	89 e5                	mov    %esp,%ebp
  80083a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80083d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800840:	50                   	push   %eax
  800841:	ff 75 10             	pushl  0x10(%ebp)
  800844:	ff 75 0c             	pushl  0xc(%ebp)
  800847:	ff 75 08             	pushl  0x8(%ebp)
  80084a:	e8 9a ff ff ff       	call   8007e9 <vsnprintf>
	va_end(ap);

	return rc;
}
  80084f:	c9                   	leave  
  800850:	c3                   	ret    

00800851 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800851:	55                   	push   %ebp
  800852:	89 e5                	mov    %esp,%ebp
  800854:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800857:	b8 00 00 00 00       	mov    $0x0,%eax
  80085c:	eb 03                	jmp    800861 <strlen+0x10>
		n++;
  80085e:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800861:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800865:	75 f7                	jne    80085e <strlen+0xd>
		n++;
	return n;
}
  800867:	5d                   	pop    %ebp
  800868:	c3                   	ret    

00800869 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800869:	55                   	push   %ebp
  80086a:	89 e5                	mov    %esp,%ebp
  80086c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80086f:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800872:	ba 00 00 00 00       	mov    $0x0,%edx
  800877:	eb 03                	jmp    80087c <strnlen+0x13>
		n++;
  800879:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80087c:	39 c2                	cmp    %eax,%edx
  80087e:	74 08                	je     800888 <strnlen+0x1f>
  800880:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800884:	75 f3                	jne    800879 <strnlen+0x10>
  800886:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800888:	5d                   	pop    %ebp
  800889:	c3                   	ret    

0080088a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80088a:	55                   	push   %ebp
  80088b:	89 e5                	mov    %esp,%ebp
  80088d:	53                   	push   %ebx
  80088e:	8b 45 08             	mov    0x8(%ebp),%eax
  800891:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800894:	89 c2                	mov    %eax,%edx
  800896:	83 c2 01             	add    $0x1,%edx
  800899:	83 c1 01             	add    $0x1,%ecx
  80089c:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008a0:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008a3:	84 db                	test   %bl,%bl
  8008a5:	75 ef                	jne    800896 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008a7:	5b                   	pop    %ebx
  8008a8:	5d                   	pop    %ebp
  8008a9:	c3                   	ret    

008008aa <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008aa:	55                   	push   %ebp
  8008ab:	89 e5                	mov    %esp,%ebp
  8008ad:	53                   	push   %ebx
  8008ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008b1:	53                   	push   %ebx
  8008b2:	e8 9a ff ff ff       	call   800851 <strlen>
  8008b7:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008ba:	ff 75 0c             	pushl  0xc(%ebp)
  8008bd:	01 d8                	add    %ebx,%eax
  8008bf:	50                   	push   %eax
  8008c0:	e8 c5 ff ff ff       	call   80088a <strcpy>
	return dst;
}
  8008c5:	89 d8                	mov    %ebx,%eax
  8008c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008ca:	c9                   	leave  
  8008cb:	c3                   	ret    

008008cc <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008cc:	55                   	push   %ebp
  8008cd:	89 e5                	mov    %esp,%ebp
  8008cf:	56                   	push   %esi
  8008d0:	53                   	push   %ebx
  8008d1:	8b 75 08             	mov    0x8(%ebp),%esi
  8008d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008d7:	89 f3                	mov    %esi,%ebx
  8008d9:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008dc:	89 f2                	mov    %esi,%edx
  8008de:	eb 0f                	jmp    8008ef <strncpy+0x23>
		*dst++ = *src;
  8008e0:	83 c2 01             	add    $0x1,%edx
  8008e3:	0f b6 01             	movzbl (%ecx),%eax
  8008e6:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008e9:	80 39 01             	cmpb   $0x1,(%ecx)
  8008ec:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008ef:	39 da                	cmp    %ebx,%edx
  8008f1:	75 ed                	jne    8008e0 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008f3:	89 f0                	mov    %esi,%eax
  8008f5:	5b                   	pop    %ebx
  8008f6:	5e                   	pop    %esi
  8008f7:	5d                   	pop    %ebp
  8008f8:	c3                   	ret    

008008f9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008f9:	55                   	push   %ebp
  8008fa:	89 e5                	mov    %esp,%ebp
  8008fc:	56                   	push   %esi
  8008fd:	53                   	push   %ebx
  8008fe:	8b 75 08             	mov    0x8(%ebp),%esi
  800901:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800904:	8b 55 10             	mov    0x10(%ebp),%edx
  800907:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800909:	85 d2                	test   %edx,%edx
  80090b:	74 21                	je     80092e <strlcpy+0x35>
  80090d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800911:	89 f2                	mov    %esi,%edx
  800913:	eb 09                	jmp    80091e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800915:	83 c2 01             	add    $0x1,%edx
  800918:	83 c1 01             	add    $0x1,%ecx
  80091b:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80091e:	39 c2                	cmp    %eax,%edx
  800920:	74 09                	je     80092b <strlcpy+0x32>
  800922:	0f b6 19             	movzbl (%ecx),%ebx
  800925:	84 db                	test   %bl,%bl
  800927:	75 ec                	jne    800915 <strlcpy+0x1c>
  800929:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80092b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80092e:	29 f0                	sub    %esi,%eax
}
  800930:	5b                   	pop    %ebx
  800931:	5e                   	pop    %esi
  800932:	5d                   	pop    %ebp
  800933:	c3                   	ret    

00800934 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800934:	55                   	push   %ebp
  800935:	89 e5                	mov    %esp,%ebp
  800937:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80093a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80093d:	eb 06                	jmp    800945 <strcmp+0x11>
		p++, q++;
  80093f:	83 c1 01             	add    $0x1,%ecx
  800942:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800945:	0f b6 01             	movzbl (%ecx),%eax
  800948:	84 c0                	test   %al,%al
  80094a:	74 04                	je     800950 <strcmp+0x1c>
  80094c:	3a 02                	cmp    (%edx),%al
  80094e:	74 ef                	je     80093f <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800950:	0f b6 c0             	movzbl %al,%eax
  800953:	0f b6 12             	movzbl (%edx),%edx
  800956:	29 d0                	sub    %edx,%eax
}
  800958:	5d                   	pop    %ebp
  800959:	c3                   	ret    

0080095a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80095a:	55                   	push   %ebp
  80095b:	89 e5                	mov    %esp,%ebp
  80095d:	53                   	push   %ebx
  80095e:	8b 45 08             	mov    0x8(%ebp),%eax
  800961:	8b 55 0c             	mov    0xc(%ebp),%edx
  800964:	89 c3                	mov    %eax,%ebx
  800966:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800969:	eb 06                	jmp    800971 <strncmp+0x17>
		n--, p++, q++;
  80096b:	83 c0 01             	add    $0x1,%eax
  80096e:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800971:	39 d8                	cmp    %ebx,%eax
  800973:	74 15                	je     80098a <strncmp+0x30>
  800975:	0f b6 08             	movzbl (%eax),%ecx
  800978:	84 c9                	test   %cl,%cl
  80097a:	74 04                	je     800980 <strncmp+0x26>
  80097c:	3a 0a                	cmp    (%edx),%cl
  80097e:	74 eb                	je     80096b <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800980:	0f b6 00             	movzbl (%eax),%eax
  800983:	0f b6 12             	movzbl (%edx),%edx
  800986:	29 d0                	sub    %edx,%eax
  800988:	eb 05                	jmp    80098f <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80098a:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80098f:	5b                   	pop    %ebx
  800990:	5d                   	pop    %ebp
  800991:	c3                   	ret    

00800992 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800992:	55                   	push   %ebp
  800993:	89 e5                	mov    %esp,%ebp
  800995:	8b 45 08             	mov    0x8(%ebp),%eax
  800998:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80099c:	eb 07                	jmp    8009a5 <strchr+0x13>
		if (*s == c)
  80099e:	38 ca                	cmp    %cl,%dl
  8009a0:	74 0f                	je     8009b1 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009a2:	83 c0 01             	add    $0x1,%eax
  8009a5:	0f b6 10             	movzbl (%eax),%edx
  8009a8:	84 d2                	test   %dl,%dl
  8009aa:	75 f2                	jne    80099e <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009ac:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009b1:	5d                   	pop    %ebp
  8009b2:	c3                   	ret    

008009b3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009b3:	55                   	push   %ebp
  8009b4:	89 e5                	mov    %esp,%ebp
  8009b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009bd:	eb 03                	jmp    8009c2 <strfind+0xf>
  8009bf:	83 c0 01             	add    $0x1,%eax
  8009c2:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009c5:	38 ca                	cmp    %cl,%dl
  8009c7:	74 04                	je     8009cd <strfind+0x1a>
  8009c9:	84 d2                	test   %dl,%dl
  8009cb:	75 f2                	jne    8009bf <strfind+0xc>
			break;
	return (char *) s;
}
  8009cd:	5d                   	pop    %ebp
  8009ce:	c3                   	ret    

008009cf <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009cf:	55                   	push   %ebp
  8009d0:	89 e5                	mov    %esp,%ebp
  8009d2:	57                   	push   %edi
  8009d3:	56                   	push   %esi
  8009d4:	53                   	push   %ebx
  8009d5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009d8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009db:	85 c9                	test   %ecx,%ecx
  8009dd:	74 36                	je     800a15 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009df:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009e5:	75 28                	jne    800a0f <memset+0x40>
  8009e7:	f6 c1 03             	test   $0x3,%cl
  8009ea:	75 23                	jne    800a0f <memset+0x40>
		c &= 0xFF;
  8009ec:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009f0:	89 d3                	mov    %edx,%ebx
  8009f2:	c1 e3 08             	shl    $0x8,%ebx
  8009f5:	89 d6                	mov    %edx,%esi
  8009f7:	c1 e6 18             	shl    $0x18,%esi
  8009fa:	89 d0                	mov    %edx,%eax
  8009fc:	c1 e0 10             	shl    $0x10,%eax
  8009ff:	09 f0                	or     %esi,%eax
  800a01:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a03:	89 d8                	mov    %ebx,%eax
  800a05:	09 d0                	or     %edx,%eax
  800a07:	c1 e9 02             	shr    $0x2,%ecx
  800a0a:	fc                   	cld    
  800a0b:	f3 ab                	rep stos %eax,%es:(%edi)
  800a0d:	eb 06                	jmp    800a15 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a0f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a12:	fc                   	cld    
  800a13:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a15:	89 f8                	mov    %edi,%eax
  800a17:	5b                   	pop    %ebx
  800a18:	5e                   	pop    %esi
  800a19:	5f                   	pop    %edi
  800a1a:	5d                   	pop    %ebp
  800a1b:	c3                   	ret    

00800a1c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a1c:	55                   	push   %ebp
  800a1d:	89 e5                	mov    %esp,%ebp
  800a1f:	57                   	push   %edi
  800a20:	56                   	push   %esi
  800a21:	8b 45 08             	mov    0x8(%ebp),%eax
  800a24:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a27:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a2a:	39 c6                	cmp    %eax,%esi
  800a2c:	73 35                	jae    800a63 <memmove+0x47>
  800a2e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a31:	39 d0                	cmp    %edx,%eax
  800a33:	73 2e                	jae    800a63 <memmove+0x47>
		s += n;
		d += n;
  800a35:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a38:	89 d6                	mov    %edx,%esi
  800a3a:	09 fe                	or     %edi,%esi
  800a3c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a42:	75 13                	jne    800a57 <memmove+0x3b>
  800a44:	f6 c1 03             	test   $0x3,%cl
  800a47:	75 0e                	jne    800a57 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a49:	83 ef 04             	sub    $0x4,%edi
  800a4c:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a4f:	c1 e9 02             	shr    $0x2,%ecx
  800a52:	fd                   	std    
  800a53:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a55:	eb 09                	jmp    800a60 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a57:	83 ef 01             	sub    $0x1,%edi
  800a5a:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a5d:	fd                   	std    
  800a5e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a60:	fc                   	cld    
  800a61:	eb 1d                	jmp    800a80 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a63:	89 f2                	mov    %esi,%edx
  800a65:	09 c2                	or     %eax,%edx
  800a67:	f6 c2 03             	test   $0x3,%dl
  800a6a:	75 0f                	jne    800a7b <memmove+0x5f>
  800a6c:	f6 c1 03             	test   $0x3,%cl
  800a6f:	75 0a                	jne    800a7b <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a71:	c1 e9 02             	shr    $0x2,%ecx
  800a74:	89 c7                	mov    %eax,%edi
  800a76:	fc                   	cld    
  800a77:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a79:	eb 05                	jmp    800a80 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a7b:	89 c7                	mov    %eax,%edi
  800a7d:	fc                   	cld    
  800a7e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a80:	5e                   	pop    %esi
  800a81:	5f                   	pop    %edi
  800a82:	5d                   	pop    %ebp
  800a83:	c3                   	ret    

00800a84 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a84:	55                   	push   %ebp
  800a85:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a87:	ff 75 10             	pushl  0x10(%ebp)
  800a8a:	ff 75 0c             	pushl  0xc(%ebp)
  800a8d:	ff 75 08             	pushl  0x8(%ebp)
  800a90:	e8 87 ff ff ff       	call   800a1c <memmove>
}
  800a95:	c9                   	leave  
  800a96:	c3                   	ret    

00800a97 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a97:	55                   	push   %ebp
  800a98:	89 e5                	mov    %esp,%ebp
  800a9a:	56                   	push   %esi
  800a9b:	53                   	push   %ebx
  800a9c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aa2:	89 c6                	mov    %eax,%esi
  800aa4:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aa7:	eb 1a                	jmp    800ac3 <memcmp+0x2c>
		if (*s1 != *s2)
  800aa9:	0f b6 08             	movzbl (%eax),%ecx
  800aac:	0f b6 1a             	movzbl (%edx),%ebx
  800aaf:	38 d9                	cmp    %bl,%cl
  800ab1:	74 0a                	je     800abd <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800ab3:	0f b6 c1             	movzbl %cl,%eax
  800ab6:	0f b6 db             	movzbl %bl,%ebx
  800ab9:	29 d8                	sub    %ebx,%eax
  800abb:	eb 0f                	jmp    800acc <memcmp+0x35>
		s1++, s2++;
  800abd:	83 c0 01             	add    $0x1,%eax
  800ac0:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ac3:	39 f0                	cmp    %esi,%eax
  800ac5:	75 e2                	jne    800aa9 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ac7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800acc:	5b                   	pop    %ebx
  800acd:	5e                   	pop    %esi
  800ace:	5d                   	pop    %ebp
  800acf:	c3                   	ret    

00800ad0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ad0:	55                   	push   %ebp
  800ad1:	89 e5                	mov    %esp,%ebp
  800ad3:	53                   	push   %ebx
  800ad4:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ad7:	89 c1                	mov    %eax,%ecx
  800ad9:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800adc:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ae0:	eb 0a                	jmp    800aec <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ae2:	0f b6 10             	movzbl (%eax),%edx
  800ae5:	39 da                	cmp    %ebx,%edx
  800ae7:	74 07                	je     800af0 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ae9:	83 c0 01             	add    $0x1,%eax
  800aec:	39 c8                	cmp    %ecx,%eax
  800aee:	72 f2                	jb     800ae2 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800af0:	5b                   	pop    %ebx
  800af1:	5d                   	pop    %ebp
  800af2:	c3                   	ret    

00800af3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800af3:	55                   	push   %ebp
  800af4:	89 e5                	mov    %esp,%ebp
  800af6:	57                   	push   %edi
  800af7:	56                   	push   %esi
  800af8:	53                   	push   %ebx
  800af9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800afc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aff:	eb 03                	jmp    800b04 <strtol+0x11>
		s++;
  800b01:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b04:	0f b6 01             	movzbl (%ecx),%eax
  800b07:	3c 20                	cmp    $0x20,%al
  800b09:	74 f6                	je     800b01 <strtol+0xe>
  800b0b:	3c 09                	cmp    $0x9,%al
  800b0d:	74 f2                	je     800b01 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b0f:	3c 2b                	cmp    $0x2b,%al
  800b11:	75 0a                	jne    800b1d <strtol+0x2a>
		s++;
  800b13:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b16:	bf 00 00 00 00       	mov    $0x0,%edi
  800b1b:	eb 11                	jmp    800b2e <strtol+0x3b>
  800b1d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b22:	3c 2d                	cmp    $0x2d,%al
  800b24:	75 08                	jne    800b2e <strtol+0x3b>
		s++, neg = 1;
  800b26:	83 c1 01             	add    $0x1,%ecx
  800b29:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b2e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b34:	75 15                	jne    800b4b <strtol+0x58>
  800b36:	80 39 30             	cmpb   $0x30,(%ecx)
  800b39:	75 10                	jne    800b4b <strtol+0x58>
  800b3b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b3f:	75 7c                	jne    800bbd <strtol+0xca>
		s += 2, base = 16;
  800b41:	83 c1 02             	add    $0x2,%ecx
  800b44:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b49:	eb 16                	jmp    800b61 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b4b:	85 db                	test   %ebx,%ebx
  800b4d:	75 12                	jne    800b61 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b4f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b54:	80 39 30             	cmpb   $0x30,(%ecx)
  800b57:	75 08                	jne    800b61 <strtol+0x6e>
		s++, base = 8;
  800b59:	83 c1 01             	add    $0x1,%ecx
  800b5c:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b61:	b8 00 00 00 00       	mov    $0x0,%eax
  800b66:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b69:	0f b6 11             	movzbl (%ecx),%edx
  800b6c:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b6f:	89 f3                	mov    %esi,%ebx
  800b71:	80 fb 09             	cmp    $0x9,%bl
  800b74:	77 08                	ja     800b7e <strtol+0x8b>
			dig = *s - '0';
  800b76:	0f be d2             	movsbl %dl,%edx
  800b79:	83 ea 30             	sub    $0x30,%edx
  800b7c:	eb 22                	jmp    800ba0 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b7e:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b81:	89 f3                	mov    %esi,%ebx
  800b83:	80 fb 19             	cmp    $0x19,%bl
  800b86:	77 08                	ja     800b90 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b88:	0f be d2             	movsbl %dl,%edx
  800b8b:	83 ea 57             	sub    $0x57,%edx
  800b8e:	eb 10                	jmp    800ba0 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b90:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b93:	89 f3                	mov    %esi,%ebx
  800b95:	80 fb 19             	cmp    $0x19,%bl
  800b98:	77 16                	ja     800bb0 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b9a:	0f be d2             	movsbl %dl,%edx
  800b9d:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ba0:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ba3:	7d 0b                	jge    800bb0 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ba5:	83 c1 01             	add    $0x1,%ecx
  800ba8:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bac:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800bae:	eb b9                	jmp    800b69 <strtol+0x76>

	if (endptr)
  800bb0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bb4:	74 0d                	je     800bc3 <strtol+0xd0>
		*endptr = (char *) s;
  800bb6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bb9:	89 0e                	mov    %ecx,(%esi)
  800bbb:	eb 06                	jmp    800bc3 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bbd:	85 db                	test   %ebx,%ebx
  800bbf:	74 98                	je     800b59 <strtol+0x66>
  800bc1:	eb 9e                	jmp    800b61 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800bc3:	89 c2                	mov    %eax,%edx
  800bc5:	f7 da                	neg    %edx
  800bc7:	85 ff                	test   %edi,%edi
  800bc9:	0f 45 c2             	cmovne %edx,%eax
}
  800bcc:	5b                   	pop    %ebx
  800bcd:	5e                   	pop    %esi
  800bce:	5f                   	pop    %edi
  800bcf:	5d                   	pop    %ebp
  800bd0:	c3                   	ret    

00800bd1 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bd1:	55                   	push   %ebp
  800bd2:	89 e5                	mov    %esp,%ebp
  800bd4:	57                   	push   %edi
  800bd5:	56                   	push   %esi
  800bd6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd7:	b8 00 00 00 00       	mov    $0x0,%eax
  800bdc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bdf:	8b 55 08             	mov    0x8(%ebp),%edx
  800be2:	89 c3                	mov    %eax,%ebx
  800be4:	89 c7                	mov    %eax,%edi
  800be6:	89 c6                	mov    %eax,%esi
  800be8:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bea:	5b                   	pop    %ebx
  800beb:	5e                   	pop    %esi
  800bec:	5f                   	pop    %edi
  800bed:	5d                   	pop    %ebp
  800bee:	c3                   	ret    

00800bef <sys_cgetc>:

int
sys_cgetc(void)
{
  800bef:	55                   	push   %ebp
  800bf0:	89 e5                	mov    %esp,%ebp
  800bf2:	57                   	push   %edi
  800bf3:	56                   	push   %esi
  800bf4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf5:	ba 00 00 00 00       	mov    $0x0,%edx
  800bfa:	b8 01 00 00 00       	mov    $0x1,%eax
  800bff:	89 d1                	mov    %edx,%ecx
  800c01:	89 d3                	mov    %edx,%ebx
  800c03:	89 d7                	mov    %edx,%edi
  800c05:	89 d6                	mov    %edx,%esi
  800c07:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c09:	5b                   	pop    %ebx
  800c0a:	5e                   	pop    %esi
  800c0b:	5f                   	pop    %edi
  800c0c:	5d                   	pop    %ebp
  800c0d:	c3                   	ret    

00800c0e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c0e:	55                   	push   %ebp
  800c0f:	89 e5                	mov    %esp,%ebp
  800c11:	57                   	push   %edi
  800c12:	56                   	push   %esi
  800c13:	53                   	push   %ebx
  800c14:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c17:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c1c:	b8 03 00 00 00       	mov    $0x3,%eax
  800c21:	8b 55 08             	mov    0x8(%ebp),%edx
  800c24:	89 cb                	mov    %ecx,%ebx
  800c26:	89 cf                	mov    %ecx,%edi
  800c28:	89 ce                	mov    %ecx,%esi
  800c2a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c2c:	85 c0                	test   %eax,%eax
  800c2e:	7e 17                	jle    800c47 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c30:	83 ec 0c             	sub    $0xc,%esp
  800c33:	50                   	push   %eax
  800c34:	6a 03                	push   $0x3
  800c36:	68 ff 2a 80 00       	push   $0x802aff
  800c3b:	6a 23                	push   $0x23
  800c3d:	68 1c 2b 80 00       	push   $0x802b1c
  800c42:	e8 e5 f5 ff ff       	call   80022c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c47:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c4a:	5b                   	pop    %ebx
  800c4b:	5e                   	pop    %esi
  800c4c:	5f                   	pop    %edi
  800c4d:	5d                   	pop    %ebp
  800c4e:	c3                   	ret    

00800c4f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c4f:	55                   	push   %ebp
  800c50:	89 e5                	mov    %esp,%ebp
  800c52:	57                   	push   %edi
  800c53:	56                   	push   %esi
  800c54:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c55:	ba 00 00 00 00       	mov    $0x0,%edx
  800c5a:	b8 02 00 00 00       	mov    $0x2,%eax
  800c5f:	89 d1                	mov    %edx,%ecx
  800c61:	89 d3                	mov    %edx,%ebx
  800c63:	89 d7                	mov    %edx,%edi
  800c65:	89 d6                	mov    %edx,%esi
  800c67:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c69:	5b                   	pop    %ebx
  800c6a:	5e                   	pop    %esi
  800c6b:	5f                   	pop    %edi
  800c6c:	5d                   	pop    %ebp
  800c6d:	c3                   	ret    

00800c6e <sys_yield>:

void
sys_yield(void)
{
  800c6e:	55                   	push   %ebp
  800c6f:	89 e5                	mov    %esp,%ebp
  800c71:	57                   	push   %edi
  800c72:	56                   	push   %esi
  800c73:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c74:	ba 00 00 00 00       	mov    $0x0,%edx
  800c79:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c7e:	89 d1                	mov    %edx,%ecx
  800c80:	89 d3                	mov    %edx,%ebx
  800c82:	89 d7                	mov    %edx,%edi
  800c84:	89 d6                	mov    %edx,%esi
  800c86:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c88:	5b                   	pop    %ebx
  800c89:	5e                   	pop    %esi
  800c8a:	5f                   	pop    %edi
  800c8b:	5d                   	pop    %ebp
  800c8c:	c3                   	ret    

00800c8d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c8d:	55                   	push   %ebp
  800c8e:	89 e5                	mov    %esp,%ebp
  800c90:	57                   	push   %edi
  800c91:	56                   	push   %esi
  800c92:	53                   	push   %ebx
  800c93:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c96:	be 00 00 00 00       	mov    $0x0,%esi
  800c9b:	b8 04 00 00 00       	mov    $0x4,%eax
  800ca0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ca9:	89 f7                	mov    %esi,%edi
  800cab:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cad:	85 c0                	test   %eax,%eax
  800caf:	7e 17                	jle    800cc8 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb1:	83 ec 0c             	sub    $0xc,%esp
  800cb4:	50                   	push   %eax
  800cb5:	6a 04                	push   $0x4
  800cb7:	68 ff 2a 80 00       	push   $0x802aff
  800cbc:	6a 23                	push   $0x23
  800cbe:	68 1c 2b 80 00       	push   $0x802b1c
  800cc3:	e8 64 f5 ff ff       	call   80022c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cc8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ccb:	5b                   	pop    %ebx
  800ccc:	5e                   	pop    %esi
  800ccd:	5f                   	pop    %edi
  800cce:	5d                   	pop    %ebp
  800ccf:	c3                   	ret    

00800cd0 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cd0:	55                   	push   %ebp
  800cd1:	89 e5                	mov    %esp,%ebp
  800cd3:	57                   	push   %edi
  800cd4:	56                   	push   %esi
  800cd5:	53                   	push   %ebx
  800cd6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd9:	b8 05 00 00 00       	mov    $0x5,%eax
  800cde:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ce7:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cea:	8b 75 18             	mov    0x18(%ebp),%esi
  800ced:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cef:	85 c0                	test   %eax,%eax
  800cf1:	7e 17                	jle    800d0a <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf3:	83 ec 0c             	sub    $0xc,%esp
  800cf6:	50                   	push   %eax
  800cf7:	6a 05                	push   $0x5
  800cf9:	68 ff 2a 80 00       	push   $0x802aff
  800cfe:	6a 23                	push   $0x23
  800d00:	68 1c 2b 80 00       	push   $0x802b1c
  800d05:	e8 22 f5 ff ff       	call   80022c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d0a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0d:	5b                   	pop    %ebx
  800d0e:	5e                   	pop    %esi
  800d0f:	5f                   	pop    %edi
  800d10:	5d                   	pop    %ebp
  800d11:	c3                   	ret    

00800d12 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d12:	55                   	push   %ebp
  800d13:	89 e5                	mov    %esp,%ebp
  800d15:	57                   	push   %edi
  800d16:	56                   	push   %esi
  800d17:	53                   	push   %ebx
  800d18:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d20:	b8 06 00 00 00       	mov    $0x6,%eax
  800d25:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d28:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2b:	89 df                	mov    %ebx,%edi
  800d2d:	89 de                	mov    %ebx,%esi
  800d2f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d31:	85 c0                	test   %eax,%eax
  800d33:	7e 17                	jle    800d4c <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d35:	83 ec 0c             	sub    $0xc,%esp
  800d38:	50                   	push   %eax
  800d39:	6a 06                	push   $0x6
  800d3b:	68 ff 2a 80 00       	push   $0x802aff
  800d40:	6a 23                	push   $0x23
  800d42:	68 1c 2b 80 00       	push   $0x802b1c
  800d47:	e8 e0 f4 ff ff       	call   80022c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d4c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d4f:	5b                   	pop    %ebx
  800d50:	5e                   	pop    %esi
  800d51:	5f                   	pop    %edi
  800d52:	5d                   	pop    %ebp
  800d53:	c3                   	ret    

00800d54 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d54:	55                   	push   %ebp
  800d55:	89 e5                	mov    %esp,%ebp
  800d57:	57                   	push   %edi
  800d58:	56                   	push   %esi
  800d59:	53                   	push   %ebx
  800d5a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d62:	b8 08 00 00 00       	mov    $0x8,%eax
  800d67:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6d:	89 df                	mov    %ebx,%edi
  800d6f:	89 de                	mov    %ebx,%esi
  800d71:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d73:	85 c0                	test   %eax,%eax
  800d75:	7e 17                	jle    800d8e <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d77:	83 ec 0c             	sub    $0xc,%esp
  800d7a:	50                   	push   %eax
  800d7b:	6a 08                	push   $0x8
  800d7d:	68 ff 2a 80 00       	push   $0x802aff
  800d82:	6a 23                	push   $0x23
  800d84:	68 1c 2b 80 00       	push   $0x802b1c
  800d89:	e8 9e f4 ff ff       	call   80022c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d8e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d91:	5b                   	pop    %ebx
  800d92:	5e                   	pop    %esi
  800d93:	5f                   	pop    %edi
  800d94:	5d                   	pop    %ebp
  800d95:	c3                   	ret    

00800d96 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d96:	55                   	push   %ebp
  800d97:	89 e5                	mov    %esp,%ebp
  800d99:	57                   	push   %edi
  800d9a:	56                   	push   %esi
  800d9b:	53                   	push   %ebx
  800d9c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d9f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800da4:	b8 09 00 00 00       	mov    $0x9,%eax
  800da9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dac:	8b 55 08             	mov    0x8(%ebp),%edx
  800daf:	89 df                	mov    %ebx,%edi
  800db1:	89 de                	mov    %ebx,%esi
  800db3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800db5:	85 c0                	test   %eax,%eax
  800db7:	7e 17                	jle    800dd0 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db9:	83 ec 0c             	sub    $0xc,%esp
  800dbc:	50                   	push   %eax
  800dbd:	6a 09                	push   $0x9
  800dbf:	68 ff 2a 80 00       	push   $0x802aff
  800dc4:	6a 23                	push   $0x23
  800dc6:	68 1c 2b 80 00       	push   $0x802b1c
  800dcb:	e8 5c f4 ff ff       	call   80022c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800dd0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dd3:	5b                   	pop    %ebx
  800dd4:	5e                   	pop    %esi
  800dd5:	5f                   	pop    %edi
  800dd6:	5d                   	pop    %ebp
  800dd7:	c3                   	ret    

00800dd8 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dd8:	55                   	push   %ebp
  800dd9:	89 e5                	mov    %esp,%ebp
  800ddb:	57                   	push   %edi
  800ddc:	56                   	push   %esi
  800ddd:	53                   	push   %ebx
  800dde:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800de6:	b8 0a 00 00 00       	mov    $0xa,%eax
  800deb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dee:	8b 55 08             	mov    0x8(%ebp),%edx
  800df1:	89 df                	mov    %ebx,%edi
  800df3:	89 de                	mov    %ebx,%esi
  800df5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800df7:	85 c0                	test   %eax,%eax
  800df9:	7e 17                	jle    800e12 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dfb:	83 ec 0c             	sub    $0xc,%esp
  800dfe:	50                   	push   %eax
  800dff:	6a 0a                	push   $0xa
  800e01:	68 ff 2a 80 00       	push   $0x802aff
  800e06:	6a 23                	push   $0x23
  800e08:	68 1c 2b 80 00       	push   $0x802b1c
  800e0d:	e8 1a f4 ff ff       	call   80022c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e12:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e15:	5b                   	pop    %ebx
  800e16:	5e                   	pop    %esi
  800e17:	5f                   	pop    %edi
  800e18:	5d                   	pop    %ebp
  800e19:	c3                   	ret    

00800e1a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e1a:	55                   	push   %ebp
  800e1b:	89 e5                	mov    %esp,%ebp
  800e1d:	57                   	push   %edi
  800e1e:	56                   	push   %esi
  800e1f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e20:	be 00 00 00 00       	mov    $0x0,%esi
  800e25:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e30:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e33:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e36:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e38:	5b                   	pop    %ebx
  800e39:	5e                   	pop    %esi
  800e3a:	5f                   	pop    %edi
  800e3b:	5d                   	pop    %ebp
  800e3c:	c3                   	ret    

00800e3d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e3d:	55                   	push   %ebp
  800e3e:	89 e5                	mov    %esp,%ebp
  800e40:	57                   	push   %edi
  800e41:	56                   	push   %esi
  800e42:	53                   	push   %ebx
  800e43:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e46:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e4b:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e50:	8b 55 08             	mov    0x8(%ebp),%edx
  800e53:	89 cb                	mov    %ecx,%ebx
  800e55:	89 cf                	mov    %ecx,%edi
  800e57:	89 ce                	mov    %ecx,%esi
  800e59:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e5b:	85 c0                	test   %eax,%eax
  800e5d:	7e 17                	jle    800e76 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e5f:	83 ec 0c             	sub    $0xc,%esp
  800e62:	50                   	push   %eax
  800e63:	6a 0d                	push   $0xd
  800e65:	68 ff 2a 80 00       	push   $0x802aff
  800e6a:	6a 23                	push   $0x23
  800e6c:	68 1c 2b 80 00       	push   $0x802b1c
  800e71:	e8 b6 f3 ff ff       	call   80022c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e76:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e79:	5b                   	pop    %ebx
  800e7a:	5e                   	pop    %esi
  800e7b:	5f                   	pop    %edi
  800e7c:	5d                   	pop    %ebp
  800e7d:	c3                   	ret    

00800e7e <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e7e:	55                   	push   %ebp
  800e7f:	89 e5                	mov    %esp,%ebp
  800e81:	57                   	push   %edi
  800e82:	56                   	push   %esi
  800e83:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e84:	ba 00 00 00 00       	mov    $0x0,%edx
  800e89:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e8e:	89 d1                	mov    %edx,%ecx
  800e90:	89 d3                	mov    %edx,%ebx
  800e92:	89 d7                	mov    %edx,%edi
  800e94:	89 d6                	mov    %edx,%esi
  800e96:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e98:	5b                   	pop    %ebx
  800e99:	5e                   	pop    %esi
  800e9a:	5f                   	pop    %edi
  800e9b:	5d                   	pop    %ebp
  800e9c:	c3                   	ret    

00800e9d <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800e9d:	55                   	push   %ebp
  800e9e:	89 e5                	mov    %esp,%ebp
  800ea0:	53                   	push   %ebx
  800ea1:	83 ec 04             	sub    $0x4,%esp
	int r;
	void * address = (void *)(pn*PGSIZE);
  800ea4:	89 d3                	mov    %edx,%ebx
  800ea6:	c1 e3 0c             	shl    $0xc,%ebx
	
	if((uvpt[pn] & PTE_SHARE))
  800ea9:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800eb0:	f6 c5 04             	test   $0x4,%ch
  800eb3:	74 38                	je     800eed <duppage+0x50>
	{
		if ((r = sys_page_map(0, address, envid, address, (uvpt[pn] | PTE_SYSCALL))) < 0)
  800eb5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ebc:	83 ec 0c             	sub    $0xc,%esp
  800ebf:	81 ca 07 0e 00 00    	or     $0xe07,%edx
  800ec5:	52                   	push   %edx
  800ec6:	53                   	push   %ebx
  800ec7:	50                   	push   %eax
  800ec8:	53                   	push   %ebx
  800ec9:	6a 00                	push   $0x0
  800ecb:	e8 00 fe ff ff       	call   800cd0 <sys_page_map>
  800ed0:	83 c4 20             	add    $0x20,%esp
  800ed3:	85 c0                	test   %eax,%eax
  800ed5:	0f 89 b8 00 00 00    	jns    800f93 <duppage+0xf6>
			panic("sys_page_map: %e", r);
  800edb:	50                   	push   %eax
  800edc:	68 2a 2b 80 00       	push   $0x802b2a
  800ee1:	6a 4e                	push   $0x4e
  800ee3:	68 3b 2b 80 00       	push   $0x802b3b
  800ee8:	e8 3f f3 ff ff       	call   80022c <_panic>
	}
	else if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW))
  800eed:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800ef4:	f6 c1 02             	test   $0x2,%cl
  800ef7:	75 0c                	jne    800f05 <duppage+0x68>
  800ef9:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800f00:	f6 c5 08             	test   $0x8,%ch
  800f03:	74 57                	je     800f5c <duppage+0xbf>
	{
		int perm = 0;
		perm |= PTE_P|PTE_U|PTE_COW;
	
		if ((r = sys_page_map(0, address, envid, address, perm)) < 0)
  800f05:	83 ec 0c             	sub    $0xc,%esp
  800f08:	68 05 08 00 00       	push   $0x805
  800f0d:	53                   	push   %ebx
  800f0e:	50                   	push   %eax
  800f0f:	53                   	push   %ebx
  800f10:	6a 00                	push   $0x0
  800f12:	e8 b9 fd ff ff       	call   800cd0 <sys_page_map>
  800f17:	83 c4 20             	add    $0x20,%esp
  800f1a:	85 c0                	test   %eax,%eax
  800f1c:	79 12                	jns    800f30 <duppage+0x93>
			panic("sys_page_map: %e", r);
  800f1e:	50                   	push   %eax
  800f1f:	68 2a 2b 80 00       	push   $0x802b2a
  800f24:	6a 56                	push   $0x56
  800f26:	68 3b 2b 80 00       	push   $0x802b3b
  800f2b:	e8 fc f2 ff ff       	call   80022c <_panic>
		if ((r = sys_page_map(0, address, 0, address, perm)) < 0)
  800f30:	83 ec 0c             	sub    $0xc,%esp
  800f33:	68 05 08 00 00       	push   $0x805
  800f38:	53                   	push   %ebx
  800f39:	6a 00                	push   $0x0
  800f3b:	53                   	push   %ebx
  800f3c:	6a 00                	push   $0x0
  800f3e:	e8 8d fd ff ff       	call   800cd0 <sys_page_map>
  800f43:	83 c4 20             	add    $0x20,%esp
  800f46:	85 c0                	test   %eax,%eax
  800f48:	79 49                	jns    800f93 <duppage+0xf6>
			panic("sys_page_map: %e", r);
  800f4a:	50                   	push   %eax
  800f4b:	68 2a 2b 80 00       	push   $0x802b2a
  800f50:	6a 58                	push   $0x58
  800f52:	68 3b 2b 80 00       	push   $0x802b3b
  800f57:	e8 d0 f2 ff ff       	call   80022c <_panic>
	}
	else if((uvpt[pn] & ~PTE_U) == 0)
  800f5c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f63:	f7 c2 fb ff ff ff    	test   $0xfffffffb,%edx
  800f69:	75 28                	jne    800f93 <duppage+0xf6>
	{
		//cprintf("im here");
		if ((r = sys_page_map(0, address, envid, address, PTE_P|PTE_U)) < 0)
  800f6b:	83 ec 0c             	sub    $0xc,%esp
  800f6e:	6a 05                	push   $0x5
  800f70:	53                   	push   %ebx
  800f71:	50                   	push   %eax
  800f72:	53                   	push   %ebx
  800f73:	6a 00                	push   $0x0
  800f75:	e8 56 fd ff ff       	call   800cd0 <sys_page_map>
  800f7a:	83 c4 20             	add    $0x20,%esp
  800f7d:	85 c0                	test   %eax,%eax
  800f7f:	79 12                	jns    800f93 <duppage+0xf6>
			panic("sys_page_map: %e", r);	
  800f81:	50                   	push   %eax
  800f82:	68 2a 2b 80 00       	push   $0x802b2a
  800f87:	6a 5e                	push   $0x5e
  800f89:	68 3b 2b 80 00       	push   $0x802b3b
  800f8e:	e8 99 f2 ff ff       	call   80022c <_panic>
	}
	return 0;
}
  800f93:	b8 00 00 00 00       	mov    $0x0,%eax
  800f98:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f9b:	c9                   	leave  
  800f9c:	c3                   	ret    

00800f9d <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f9d:	55                   	push   %ebp
  800f9e:	89 e5                	mov    %esp,%ebp
  800fa0:	53                   	push   %ebx
  800fa1:	83 ec 08             	sub    $0x8,%esp
	void *addr = (void *) utf->utf_fault_va;
  800fa4:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa7:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	unsigned pn = ((uint32_t)addr)/PGSIZE;
  800fa9:	89 d8                	mov    %ebx,%eax
  800fab:	c1 e8 0c             	shr    $0xc,%eax
	pte_t pte = uvpt[pn];
  800fae:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// Allocate a new page, mapped at temp location
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  800fb5:	6a 07                	push   $0x7
  800fb7:	68 00 f0 7f 00       	push   $0x7ff000
  800fbc:	6a 00                	push   $0x0
  800fbe:	e8 ca fc ff ff       	call   800c8d <sys_page_alloc>
  800fc3:	83 c4 10             	add    $0x10,%esp
  800fc6:	85 c0                	test   %eax,%eax
  800fc8:	79 12                	jns    800fdc <pgfault+0x3f>
		panic("sys_page_alloc: %e", r);
  800fca:	50                   	push   %eax
  800fcb:	68 2a 27 80 00       	push   $0x80272a
  800fd0:	6a 2b                	push   $0x2b
  800fd2:	68 3b 2b 80 00       	push   $0x802b3b
  800fd7:	e8 50 f2 ff ff       	call   80022c <_panic>

	// Copy the data from the old page to this new page
	void *addr_pgstart = (void *) ROUNDDOWN(addr, PGSIZE);
  800fdc:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr_pgstart, PGSIZE);
  800fe2:	83 ec 04             	sub    $0x4,%esp
  800fe5:	68 00 10 00 00       	push   $0x1000
  800fea:	53                   	push   %ebx
  800feb:	68 00 f0 7f 00       	push   $0x7ff000
  800ff0:	e8 27 fa ff ff       	call   800a1c <memmove>

	// Move the new page to the old page's address
	if ((r = sys_page_map(0, PFTEMP, 0, addr_pgstart, PTE_P|PTE_U|PTE_W)) < 0)
  800ff5:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800ffc:	53                   	push   %ebx
  800ffd:	6a 00                	push   $0x0
  800fff:	68 00 f0 7f 00       	push   $0x7ff000
  801004:	6a 00                	push   $0x0
  801006:	e8 c5 fc ff ff       	call   800cd0 <sys_page_map>
  80100b:	83 c4 20             	add    $0x20,%esp
  80100e:	85 c0                	test   %eax,%eax
  801010:	79 12                	jns    801024 <pgfault+0x87>
		panic("sys_page_map: %e", r);
  801012:	50                   	push   %eax
  801013:	68 2a 2b 80 00       	push   $0x802b2a
  801018:	6a 33                	push   $0x33
  80101a:	68 3b 2b 80 00       	push   $0x802b3b
  80101f:	e8 08 f2 ff ff       	call   80022c <_panic>

	// Unmap the temp location
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  801024:	83 ec 08             	sub    $0x8,%esp
  801027:	68 00 f0 7f 00       	push   $0x7ff000
  80102c:	6a 00                	push   $0x0
  80102e:	e8 df fc ff ff       	call   800d12 <sys_page_unmap>
  801033:	83 c4 10             	add    $0x10,%esp
  801036:	85 c0                	test   %eax,%eax
  801038:	79 12                	jns    80104c <pgfault+0xaf>
		panic("sys_page_unmap: %e", r);
  80103a:	50                   	push   %eax
  80103b:	68 46 2b 80 00       	push   $0x802b46
  801040:	6a 37                	push   $0x37
  801042:	68 3b 2b 80 00       	push   $0x802b3b
  801047:	e8 e0 f1 ff ff       	call   80022c <_panic>
}
  80104c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80104f:	c9                   	leave  
  801050:	c3                   	ret    

00801051 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801051:	55                   	push   %ebp
  801052:	89 e5                	mov    %esp,%ebp
  801054:	56                   	push   %esi
  801055:	53                   	push   %ebx
  801056:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
	// Set up page fault handler
	set_pgfault_handler(&pgfault);
  801059:	68 9d 0f 80 00       	push   $0x800f9d
  80105e:	e8 53 13 00 00       	call   8023b6 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801063:	b8 07 00 00 00       	mov    $0x7,%eax
  801068:	cd 30                	int    $0x30

	// Create child
	envid_t envid = sys_exofork();
  80106a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (envid < 0) {
  80106d:	83 c4 10             	add    $0x10,%esp
  801070:	85 c0                	test   %eax,%eax
  801072:	79 12                	jns    801086 <fork+0x35>
		panic("sys_exofork: %e", envid);
  801074:	50                   	push   %eax
  801075:	68 59 2b 80 00       	push   $0x802b59
  80107a:	6a 7c                	push   $0x7c
  80107c:	68 3b 2b 80 00       	push   $0x802b3b
  801081:	e8 a6 f1 ff ff       	call   80022c <_panic>
		return envid;
	}
	if (envid == 0) {
  801086:	85 c0                	test   %eax,%eax
  801088:	75 1e                	jne    8010a8 <fork+0x57>
		// We are the child.
		thisenv = &envs[ENVX(sys_getenvid())]; // Fix thisenv
  80108a:	e8 c0 fb ff ff       	call   800c4f <sys_getenvid>
  80108f:	25 ff 03 00 00       	and    $0x3ff,%eax
  801094:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801097:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80109c:	a3 0c 40 80 00       	mov    %eax,0x80400c
		return 0;
  8010a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8010a6:	eb 7d                	jmp    801125 <fork+0xd4>

	// Set page fault handler on the child.
	// The parent needs to do it, else the child wouldn't be able to handle
	// the fault when trying to access it's stack (which happens as soon it starts)
	extern void _pgfault_upcall(void);
	sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);
  8010a8:	83 ec 04             	sub    $0x4,%esp
  8010ab:	6a 07                	push   $0x7
  8010ad:	68 00 f0 bf ee       	push   $0xeebff000
  8010b2:	50                   	push   %eax
  8010b3:	e8 d5 fb ff ff       	call   800c8d <sys_page_alloc>
	sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  8010b8:	83 c4 08             	add    $0x8,%esp
  8010bb:	68 fb 23 80 00       	push   $0x8023fb
  8010c0:	ff 75 f4             	pushl  -0xc(%ebp)
  8010c3:	e8 10 fd ff ff       	call   800dd8 <sys_env_set_pgfault_upcall>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  8010c8:	be 04 70 80 00       	mov    $0x807004,%esi
  8010cd:	c1 ee 0c             	shr    $0xc,%esi
  8010d0:	83 c4 10             	add    $0x10,%esp
  8010d3:	bb 00 08 00 00       	mov    $0x800,%ebx
  8010d8:	eb 0d                	jmp    8010e7 <fork+0x96>
		duppage(envid, pn);
  8010da:	89 da                	mov    %ebx,%edx
  8010dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010df:	e8 b9 fd ff ff       	call   800e9d <duppage>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  8010e4:	83 c3 01             	add    $0x1,%ebx
  8010e7:	39 f3                	cmp    %esi,%ebx
  8010e9:	76 ef                	jbe    8010da <fork+0x89>
	}

	// Also copy the stack we are currently running on
	// I think it should loop from ustacktop to this page, since the stack
	// can have more than 1 page
	duppage(envid, ((uint32_t) &envid)/PGSIZE);
  8010eb:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8010ee:	c1 ea 0c             	shr    $0xc,%edx
  8010f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010f4:	e8 a4 fd ff ff       	call   800e9d <duppage>

	// Start the child environmnet running
	int r;
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  8010f9:	83 ec 08             	sub    $0x8,%esp
  8010fc:	6a 02                	push   $0x2
  8010fe:	ff 75 f4             	pushl  -0xc(%ebp)
  801101:	e8 4e fc ff ff       	call   800d54 <sys_env_set_status>
  801106:	83 c4 10             	add    $0x10,%esp
  801109:	85 c0                	test   %eax,%eax
  80110b:	79 15                	jns    801122 <fork+0xd1>
		panic("sys_env_set_status: %e", r);
  80110d:	50                   	push   %eax
  80110e:	68 69 2b 80 00       	push   $0x802b69
  801113:	68 9c 00 00 00       	push   $0x9c
  801118:	68 3b 2b 80 00       	push   $0x802b3b
  80111d:	e8 0a f1 ff ff       	call   80022c <_panic>
		return r;
	}

	return envid;
  801122:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  801125:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801128:	5b                   	pop    %ebx
  801129:	5e                   	pop    %esi
  80112a:	5d                   	pop    %ebp
  80112b:	c3                   	ret    

0080112c <sfork>:

// Challenge!
int
sfork(void)
{
  80112c:	55                   	push   %ebp
  80112d:	89 e5                	mov    %esp,%ebp
  80112f:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801132:	68 80 2b 80 00       	push   $0x802b80
  801137:	68 a7 00 00 00       	push   $0xa7
  80113c:	68 3b 2b 80 00       	push   $0x802b3b
  801141:	e8 e6 f0 ff ff       	call   80022c <_panic>

00801146 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801146:	55                   	push   %ebp
  801147:	89 e5                	mov    %esp,%ebp
  801149:	56                   	push   %esi
  80114a:	53                   	push   %ebx
  80114b:	8b 75 08             	mov    0x8(%ebp),%esi
  80114e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801151:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  801154:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801156:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  80115b:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  80115e:	83 ec 0c             	sub    $0xc,%esp
  801161:	50                   	push   %eax
  801162:	e8 d6 fc ff ff       	call   800e3d <sys_ipc_recv>

	if (r < 0) {
  801167:	83 c4 10             	add    $0x10,%esp
  80116a:	85 c0                	test   %eax,%eax
  80116c:	79 16                	jns    801184 <ipc_recv+0x3e>
		if (from_env_store)
  80116e:	85 f6                	test   %esi,%esi
  801170:	74 06                	je     801178 <ipc_recv+0x32>
			*from_env_store = 0;
  801172:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  801178:	85 db                	test   %ebx,%ebx
  80117a:	74 2c                	je     8011a8 <ipc_recv+0x62>
			*perm_store = 0;
  80117c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801182:	eb 24                	jmp    8011a8 <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  801184:	85 f6                	test   %esi,%esi
  801186:	74 0a                	je     801192 <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  801188:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80118d:	8b 40 74             	mov    0x74(%eax),%eax
  801190:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  801192:	85 db                	test   %ebx,%ebx
  801194:	74 0a                	je     8011a0 <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  801196:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80119b:	8b 40 78             	mov    0x78(%eax),%eax
  80119e:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  8011a0:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8011a5:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  8011a8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011ab:	5b                   	pop    %ebx
  8011ac:	5e                   	pop    %esi
  8011ad:	5d                   	pop    %ebp
  8011ae:	c3                   	ret    

008011af <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8011af:	55                   	push   %ebp
  8011b0:	89 e5                	mov    %esp,%ebp
  8011b2:	57                   	push   %edi
  8011b3:	56                   	push   %esi
  8011b4:	53                   	push   %ebx
  8011b5:	83 ec 0c             	sub    $0xc,%esp
  8011b8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011bb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8011be:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  8011c1:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  8011c3:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  8011c8:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  8011cb:	ff 75 14             	pushl  0x14(%ebp)
  8011ce:	53                   	push   %ebx
  8011cf:	56                   	push   %esi
  8011d0:	57                   	push   %edi
  8011d1:	e8 44 fc ff ff       	call   800e1a <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  8011d6:	83 c4 10             	add    $0x10,%esp
  8011d9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8011dc:	75 07                	jne    8011e5 <ipc_send+0x36>
			sys_yield();
  8011de:	e8 8b fa ff ff       	call   800c6e <sys_yield>
  8011e3:	eb e6                	jmp    8011cb <ipc_send+0x1c>
		} else if (r < 0) {
  8011e5:	85 c0                	test   %eax,%eax
  8011e7:	79 12                	jns    8011fb <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  8011e9:	50                   	push   %eax
  8011ea:	68 96 2b 80 00       	push   $0x802b96
  8011ef:	6a 51                	push   $0x51
  8011f1:	68 a3 2b 80 00       	push   $0x802ba3
  8011f6:	e8 31 f0 ff ff       	call   80022c <_panic>
		}
	}
}
  8011fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011fe:	5b                   	pop    %ebx
  8011ff:	5e                   	pop    %esi
  801200:	5f                   	pop    %edi
  801201:	5d                   	pop    %ebp
  801202:	c3                   	ret    

00801203 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801203:	55                   	push   %ebp
  801204:	89 e5                	mov    %esp,%ebp
  801206:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801209:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80120e:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801211:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801217:	8b 52 50             	mov    0x50(%edx),%edx
  80121a:	39 ca                	cmp    %ecx,%edx
  80121c:	75 0d                	jne    80122b <ipc_find_env+0x28>
			return envs[i].env_id;
  80121e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801221:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801226:	8b 40 48             	mov    0x48(%eax),%eax
  801229:	eb 0f                	jmp    80123a <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80122b:	83 c0 01             	add    $0x1,%eax
  80122e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801233:	75 d9                	jne    80120e <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801235:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80123a:	5d                   	pop    %ebp
  80123b:	c3                   	ret    

0080123c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80123c:	55                   	push   %ebp
  80123d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80123f:	8b 45 08             	mov    0x8(%ebp),%eax
  801242:	05 00 00 00 30       	add    $0x30000000,%eax
  801247:	c1 e8 0c             	shr    $0xc,%eax
}
  80124a:	5d                   	pop    %ebp
  80124b:	c3                   	ret    

0080124c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80124c:	55                   	push   %ebp
  80124d:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80124f:	8b 45 08             	mov    0x8(%ebp),%eax
  801252:	05 00 00 00 30       	add    $0x30000000,%eax
  801257:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80125c:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801261:	5d                   	pop    %ebp
  801262:	c3                   	ret    

00801263 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801263:	55                   	push   %ebp
  801264:	89 e5                	mov    %esp,%ebp
  801266:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801269:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80126e:	89 c2                	mov    %eax,%edx
  801270:	c1 ea 16             	shr    $0x16,%edx
  801273:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80127a:	f6 c2 01             	test   $0x1,%dl
  80127d:	74 11                	je     801290 <fd_alloc+0x2d>
  80127f:	89 c2                	mov    %eax,%edx
  801281:	c1 ea 0c             	shr    $0xc,%edx
  801284:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80128b:	f6 c2 01             	test   $0x1,%dl
  80128e:	75 09                	jne    801299 <fd_alloc+0x36>
			*fd_store = fd;
  801290:	89 01                	mov    %eax,(%ecx)
			return 0;
  801292:	b8 00 00 00 00       	mov    $0x0,%eax
  801297:	eb 17                	jmp    8012b0 <fd_alloc+0x4d>
  801299:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80129e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012a3:	75 c9                	jne    80126e <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012a5:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8012ab:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012b0:	5d                   	pop    %ebp
  8012b1:	c3                   	ret    

008012b2 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012b2:	55                   	push   %ebp
  8012b3:	89 e5                	mov    %esp,%ebp
  8012b5:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012b8:	83 f8 1f             	cmp    $0x1f,%eax
  8012bb:	77 36                	ja     8012f3 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012bd:	c1 e0 0c             	shl    $0xc,%eax
  8012c0:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012c5:	89 c2                	mov    %eax,%edx
  8012c7:	c1 ea 16             	shr    $0x16,%edx
  8012ca:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012d1:	f6 c2 01             	test   $0x1,%dl
  8012d4:	74 24                	je     8012fa <fd_lookup+0x48>
  8012d6:	89 c2                	mov    %eax,%edx
  8012d8:	c1 ea 0c             	shr    $0xc,%edx
  8012db:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012e2:	f6 c2 01             	test   $0x1,%dl
  8012e5:	74 1a                	je     801301 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012e7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012ea:	89 02                	mov    %eax,(%edx)
	return 0;
  8012ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8012f1:	eb 13                	jmp    801306 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012f3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012f8:	eb 0c                	jmp    801306 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012fa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012ff:	eb 05                	jmp    801306 <fd_lookup+0x54>
  801301:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801306:	5d                   	pop    %ebp
  801307:	c3                   	ret    

00801308 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801308:	55                   	push   %ebp
  801309:	89 e5                	mov    %esp,%ebp
  80130b:	83 ec 08             	sub    $0x8,%esp
  80130e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801311:	ba 30 2c 80 00       	mov    $0x802c30,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801316:	eb 13                	jmp    80132b <dev_lookup+0x23>
  801318:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80131b:	39 08                	cmp    %ecx,(%eax)
  80131d:	75 0c                	jne    80132b <dev_lookup+0x23>
			*dev = devtab[i];
  80131f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801322:	89 01                	mov    %eax,(%ecx)
			return 0;
  801324:	b8 00 00 00 00       	mov    $0x0,%eax
  801329:	eb 2e                	jmp    801359 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80132b:	8b 02                	mov    (%edx),%eax
  80132d:	85 c0                	test   %eax,%eax
  80132f:	75 e7                	jne    801318 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801331:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801336:	8b 40 48             	mov    0x48(%eax),%eax
  801339:	83 ec 04             	sub    $0x4,%esp
  80133c:	51                   	push   %ecx
  80133d:	50                   	push   %eax
  80133e:	68 b0 2b 80 00       	push   $0x802bb0
  801343:	e8 bd ef ff ff       	call   800305 <cprintf>
	*dev = 0;
  801348:	8b 45 0c             	mov    0xc(%ebp),%eax
  80134b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801351:	83 c4 10             	add    $0x10,%esp
  801354:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801359:	c9                   	leave  
  80135a:	c3                   	ret    

0080135b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80135b:	55                   	push   %ebp
  80135c:	89 e5                	mov    %esp,%ebp
  80135e:	56                   	push   %esi
  80135f:	53                   	push   %ebx
  801360:	83 ec 10             	sub    $0x10,%esp
  801363:	8b 75 08             	mov    0x8(%ebp),%esi
  801366:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801369:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80136c:	50                   	push   %eax
  80136d:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801373:	c1 e8 0c             	shr    $0xc,%eax
  801376:	50                   	push   %eax
  801377:	e8 36 ff ff ff       	call   8012b2 <fd_lookup>
  80137c:	83 c4 08             	add    $0x8,%esp
  80137f:	85 c0                	test   %eax,%eax
  801381:	78 05                	js     801388 <fd_close+0x2d>
	    || fd != fd2)
  801383:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801386:	74 0c                	je     801394 <fd_close+0x39>
		return (must_exist ? r : 0);
  801388:	84 db                	test   %bl,%bl
  80138a:	ba 00 00 00 00       	mov    $0x0,%edx
  80138f:	0f 44 c2             	cmove  %edx,%eax
  801392:	eb 41                	jmp    8013d5 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801394:	83 ec 08             	sub    $0x8,%esp
  801397:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80139a:	50                   	push   %eax
  80139b:	ff 36                	pushl  (%esi)
  80139d:	e8 66 ff ff ff       	call   801308 <dev_lookup>
  8013a2:	89 c3                	mov    %eax,%ebx
  8013a4:	83 c4 10             	add    $0x10,%esp
  8013a7:	85 c0                	test   %eax,%eax
  8013a9:	78 1a                	js     8013c5 <fd_close+0x6a>
		if (dev->dev_close)
  8013ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013ae:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8013b1:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8013b6:	85 c0                	test   %eax,%eax
  8013b8:	74 0b                	je     8013c5 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8013ba:	83 ec 0c             	sub    $0xc,%esp
  8013bd:	56                   	push   %esi
  8013be:	ff d0                	call   *%eax
  8013c0:	89 c3                	mov    %eax,%ebx
  8013c2:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013c5:	83 ec 08             	sub    $0x8,%esp
  8013c8:	56                   	push   %esi
  8013c9:	6a 00                	push   $0x0
  8013cb:	e8 42 f9 ff ff       	call   800d12 <sys_page_unmap>
	return r;
  8013d0:	83 c4 10             	add    $0x10,%esp
  8013d3:	89 d8                	mov    %ebx,%eax
}
  8013d5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013d8:	5b                   	pop    %ebx
  8013d9:	5e                   	pop    %esi
  8013da:	5d                   	pop    %ebp
  8013db:	c3                   	ret    

008013dc <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013dc:	55                   	push   %ebp
  8013dd:	89 e5                	mov    %esp,%ebp
  8013df:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013e5:	50                   	push   %eax
  8013e6:	ff 75 08             	pushl  0x8(%ebp)
  8013e9:	e8 c4 fe ff ff       	call   8012b2 <fd_lookup>
  8013ee:	83 c4 08             	add    $0x8,%esp
  8013f1:	85 c0                	test   %eax,%eax
  8013f3:	78 10                	js     801405 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8013f5:	83 ec 08             	sub    $0x8,%esp
  8013f8:	6a 01                	push   $0x1
  8013fa:	ff 75 f4             	pushl  -0xc(%ebp)
  8013fd:	e8 59 ff ff ff       	call   80135b <fd_close>
  801402:	83 c4 10             	add    $0x10,%esp
}
  801405:	c9                   	leave  
  801406:	c3                   	ret    

00801407 <close_all>:

void
close_all(void)
{
  801407:	55                   	push   %ebp
  801408:	89 e5                	mov    %esp,%ebp
  80140a:	53                   	push   %ebx
  80140b:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80140e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801413:	83 ec 0c             	sub    $0xc,%esp
  801416:	53                   	push   %ebx
  801417:	e8 c0 ff ff ff       	call   8013dc <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80141c:	83 c3 01             	add    $0x1,%ebx
  80141f:	83 c4 10             	add    $0x10,%esp
  801422:	83 fb 20             	cmp    $0x20,%ebx
  801425:	75 ec                	jne    801413 <close_all+0xc>
		close(i);
}
  801427:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80142a:	c9                   	leave  
  80142b:	c3                   	ret    

0080142c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80142c:	55                   	push   %ebp
  80142d:	89 e5                	mov    %esp,%ebp
  80142f:	57                   	push   %edi
  801430:	56                   	push   %esi
  801431:	53                   	push   %ebx
  801432:	83 ec 2c             	sub    $0x2c,%esp
  801435:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801438:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80143b:	50                   	push   %eax
  80143c:	ff 75 08             	pushl  0x8(%ebp)
  80143f:	e8 6e fe ff ff       	call   8012b2 <fd_lookup>
  801444:	83 c4 08             	add    $0x8,%esp
  801447:	85 c0                	test   %eax,%eax
  801449:	0f 88 c1 00 00 00    	js     801510 <dup+0xe4>
		return r;
	close(newfdnum);
  80144f:	83 ec 0c             	sub    $0xc,%esp
  801452:	56                   	push   %esi
  801453:	e8 84 ff ff ff       	call   8013dc <close>

	newfd = INDEX2FD(newfdnum);
  801458:	89 f3                	mov    %esi,%ebx
  80145a:	c1 e3 0c             	shl    $0xc,%ebx
  80145d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801463:	83 c4 04             	add    $0x4,%esp
  801466:	ff 75 e4             	pushl  -0x1c(%ebp)
  801469:	e8 de fd ff ff       	call   80124c <fd2data>
  80146e:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801470:	89 1c 24             	mov    %ebx,(%esp)
  801473:	e8 d4 fd ff ff       	call   80124c <fd2data>
  801478:	83 c4 10             	add    $0x10,%esp
  80147b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80147e:	89 f8                	mov    %edi,%eax
  801480:	c1 e8 16             	shr    $0x16,%eax
  801483:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80148a:	a8 01                	test   $0x1,%al
  80148c:	74 37                	je     8014c5 <dup+0x99>
  80148e:	89 f8                	mov    %edi,%eax
  801490:	c1 e8 0c             	shr    $0xc,%eax
  801493:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80149a:	f6 c2 01             	test   $0x1,%dl
  80149d:	74 26                	je     8014c5 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80149f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014a6:	83 ec 0c             	sub    $0xc,%esp
  8014a9:	25 07 0e 00 00       	and    $0xe07,%eax
  8014ae:	50                   	push   %eax
  8014af:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014b2:	6a 00                	push   $0x0
  8014b4:	57                   	push   %edi
  8014b5:	6a 00                	push   $0x0
  8014b7:	e8 14 f8 ff ff       	call   800cd0 <sys_page_map>
  8014bc:	89 c7                	mov    %eax,%edi
  8014be:	83 c4 20             	add    $0x20,%esp
  8014c1:	85 c0                	test   %eax,%eax
  8014c3:	78 2e                	js     8014f3 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014c5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014c8:	89 d0                	mov    %edx,%eax
  8014ca:	c1 e8 0c             	shr    $0xc,%eax
  8014cd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014d4:	83 ec 0c             	sub    $0xc,%esp
  8014d7:	25 07 0e 00 00       	and    $0xe07,%eax
  8014dc:	50                   	push   %eax
  8014dd:	53                   	push   %ebx
  8014de:	6a 00                	push   $0x0
  8014e0:	52                   	push   %edx
  8014e1:	6a 00                	push   $0x0
  8014e3:	e8 e8 f7 ff ff       	call   800cd0 <sys_page_map>
  8014e8:	89 c7                	mov    %eax,%edi
  8014ea:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8014ed:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014ef:	85 ff                	test   %edi,%edi
  8014f1:	79 1d                	jns    801510 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014f3:	83 ec 08             	sub    $0x8,%esp
  8014f6:	53                   	push   %ebx
  8014f7:	6a 00                	push   $0x0
  8014f9:	e8 14 f8 ff ff       	call   800d12 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014fe:	83 c4 08             	add    $0x8,%esp
  801501:	ff 75 d4             	pushl  -0x2c(%ebp)
  801504:	6a 00                	push   $0x0
  801506:	e8 07 f8 ff ff       	call   800d12 <sys_page_unmap>
	return r;
  80150b:	83 c4 10             	add    $0x10,%esp
  80150e:	89 f8                	mov    %edi,%eax
}
  801510:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801513:	5b                   	pop    %ebx
  801514:	5e                   	pop    %esi
  801515:	5f                   	pop    %edi
  801516:	5d                   	pop    %ebp
  801517:	c3                   	ret    

00801518 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801518:	55                   	push   %ebp
  801519:	89 e5                	mov    %esp,%ebp
  80151b:	53                   	push   %ebx
  80151c:	83 ec 14             	sub    $0x14,%esp
  80151f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801522:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801525:	50                   	push   %eax
  801526:	53                   	push   %ebx
  801527:	e8 86 fd ff ff       	call   8012b2 <fd_lookup>
  80152c:	83 c4 08             	add    $0x8,%esp
  80152f:	89 c2                	mov    %eax,%edx
  801531:	85 c0                	test   %eax,%eax
  801533:	78 6d                	js     8015a2 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801535:	83 ec 08             	sub    $0x8,%esp
  801538:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80153b:	50                   	push   %eax
  80153c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80153f:	ff 30                	pushl  (%eax)
  801541:	e8 c2 fd ff ff       	call   801308 <dev_lookup>
  801546:	83 c4 10             	add    $0x10,%esp
  801549:	85 c0                	test   %eax,%eax
  80154b:	78 4c                	js     801599 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80154d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801550:	8b 42 08             	mov    0x8(%edx),%eax
  801553:	83 e0 03             	and    $0x3,%eax
  801556:	83 f8 01             	cmp    $0x1,%eax
  801559:	75 21                	jne    80157c <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80155b:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801560:	8b 40 48             	mov    0x48(%eax),%eax
  801563:	83 ec 04             	sub    $0x4,%esp
  801566:	53                   	push   %ebx
  801567:	50                   	push   %eax
  801568:	68 f4 2b 80 00       	push   $0x802bf4
  80156d:	e8 93 ed ff ff       	call   800305 <cprintf>
		return -E_INVAL;
  801572:	83 c4 10             	add    $0x10,%esp
  801575:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80157a:	eb 26                	jmp    8015a2 <read+0x8a>
	}
	if (!dev->dev_read)
  80157c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80157f:	8b 40 08             	mov    0x8(%eax),%eax
  801582:	85 c0                	test   %eax,%eax
  801584:	74 17                	je     80159d <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801586:	83 ec 04             	sub    $0x4,%esp
  801589:	ff 75 10             	pushl  0x10(%ebp)
  80158c:	ff 75 0c             	pushl  0xc(%ebp)
  80158f:	52                   	push   %edx
  801590:	ff d0                	call   *%eax
  801592:	89 c2                	mov    %eax,%edx
  801594:	83 c4 10             	add    $0x10,%esp
  801597:	eb 09                	jmp    8015a2 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801599:	89 c2                	mov    %eax,%edx
  80159b:	eb 05                	jmp    8015a2 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80159d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8015a2:	89 d0                	mov    %edx,%eax
  8015a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015a7:	c9                   	leave  
  8015a8:	c3                   	ret    

008015a9 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015a9:	55                   	push   %ebp
  8015aa:	89 e5                	mov    %esp,%ebp
  8015ac:	57                   	push   %edi
  8015ad:	56                   	push   %esi
  8015ae:	53                   	push   %ebx
  8015af:	83 ec 0c             	sub    $0xc,%esp
  8015b2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015b5:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015b8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015bd:	eb 21                	jmp    8015e0 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015bf:	83 ec 04             	sub    $0x4,%esp
  8015c2:	89 f0                	mov    %esi,%eax
  8015c4:	29 d8                	sub    %ebx,%eax
  8015c6:	50                   	push   %eax
  8015c7:	89 d8                	mov    %ebx,%eax
  8015c9:	03 45 0c             	add    0xc(%ebp),%eax
  8015cc:	50                   	push   %eax
  8015cd:	57                   	push   %edi
  8015ce:	e8 45 ff ff ff       	call   801518 <read>
		if (m < 0)
  8015d3:	83 c4 10             	add    $0x10,%esp
  8015d6:	85 c0                	test   %eax,%eax
  8015d8:	78 10                	js     8015ea <readn+0x41>
			return m;
		if (m == 0)
  8015da:	85 c0                	test   %eax,%eax
  8015dc:	74 0a                	je     8015e8 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015de:	01 c3                	add    %eax,%ebx
  8015e0:	39 f3                	cmp    %esi,%ebx
  8015e2:	72 db                	jb     8015bf <readn+0x16>
  8015e4:	89 d8                	mov    %ebx,%eax
  8015e6:	eb 02                	jmp    8015ea <readn+0x41>
  8015e8:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8015ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015ed:	5b                   	pop    %ebx
  8015ee:	5e                   	pop    %esi
  8015ef:	5f                   	pop    %edi
  8015f0:	5d                   	pop    %ebp
  8015f1:	c3                   	ret    

008015f2 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015f2:	55                   	push   %ebp
  8015f3:	89 e5                	mov    %esp,%ebp
  8015f5:	53                   	push   %ebx
  8015f6:	83 ec 14             	sub    $0x14,%esp
  8015f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015fc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015ff:	50                   	push   %eax
  801600:	53                   	push   %ebx
  801601:	e8 ac fc ff ff       	call   8012b2 <fd_lookup>
  801606:	83 c4 08             	add    $0x8,%esp
  801609:	89 c2                	mov    %eax,%edx
  80160b:	85 c0                	test   %eax,%eax
  80160d:	78 68                	js     801677 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80160f:	83 ec 08             	sub    $0x8,%esp
  801612:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801615:	50                   	push   %eax
  801616:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801619:	ff 30                	pushl  (%eax)
  80161b:	e8 e8 fc ff ff       	call   801308 <dev_lookup>
  801620:	83 c4 10             	add    $0x10,%esp
  801623:	85 c0                	test   %eax,%eax
  801625:	78 47                	js     80166e <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801627:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80162a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80162e:	75 21                	jne    801651 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801630:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801635:	8b 40 48             	mov    0x48(%eax),%eax
  801638:	83 ec 04             	sub    $0x4,%esp
  80163b:	53                   	push   %ebx
  80163c:	50                   	push   %eax
  80163d:	68 10 2c 80 00       	push   $0x802c10
  801642:	e8 be ec ff ff       	call   800305 <cprintf>
		return -E_INVAL;
  801647:	83 c4 10             	add    $0x10,%esp
  80164a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80164f:	eb 26                	jmp    801677 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801651:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801654:	8b 52 0c             	mov    0xc(%edx),%edx
  801657:	85 d2                	test   %edx,%edx
  801659:	74 17                	je     801672 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80165b:	83 ec 04             	sub    $0x4,%esp
  80165e:	ff 75 10             	pushl  0x10(%ebp)
  801661:	ff 75 0c             	pushl  0xc(%ebp)
  801664:	50                   	push   %eax
  801665:	ff d2                	call   *%edx
  801667:	89 c2                	mov    %eax,%edx
  801669:	83 c4 10             	add    $0x10,%esp
  80166c:	eb 09                	jmp    801677 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80166e:	89 c2                	mov    %eax,%edx
  801670:	eb 05                	jmp    801677 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801672:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801677:	89 d0                	mov    %edx,%eax
  801679:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80167c:	c9                   	leave  
  80167d:	c3                   	ret    

0080167e <seek>:

int
seek(int fdnum, off_t offset)
{
  80167e:	55                   	push   %ebp
  80167f:	89 e5                	mov    %esp,%ebp
  801681:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801684:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801687:	50                   	push   %eax
  801688:	ff 75 08             	pushl  0x8(%ebp)
  80168b:	e8 22 fc ff ff       	call   8012b2 <fd_lookup>
  801690:	83 c4 08             	add    $0x8,%esp
  801693:	85 c0                	test   %eax,%eax
  801695:	78 0e                	js     8016a5 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801697:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80169a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80169d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016a0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016a5:	c9                   	leave  
  8016a6:	c3                   	ret    

008016a7 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016a7:	55                   	push   %ebp
  8016a8:	89 e5                	mov    %esp,%ebp
  8016aa:	53                   	push   %ebx
  8016ab:	83 ec 14             	sub    $0x14,%esp
  8016ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016b1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016b4:	50                   	push   %eax
  8016b5:	53                   	push   %ebx
  8016b6:	e8 f7 fb ff ff       	call   8012b2 <fd_lookup>
  8016bb:	83 c4 08             	add    $0x8,%esp
  8016be:	89 c2                	mov    %eax,%edx
  8016c0:	85 c0                	test   %eax,%eax
  8016c2:	78 65                	js     801729 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016c4:	83 ec 08             	sub    $0x8,%esp
  8016c7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016ca:	50                   	push   %eax
  8016cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ce:	ff 30                	pushl  (%eax)
  8016d0:	e8 33 fc ff ff       	call   801308 <dev_lookup>
  8016d5:	83 c4 10             	add    $0x10,%esp
  8016d8:	85 c0                	test   %eax,%eax
  8016da:	78 44                	js     801720 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016df:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016e3:	75 21                	jne    801706 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016e5:	a1 0c 40 80 00       	mov    0x80400c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016ea:	8b 40 48             	mov    0x48(%eax),%eax
  8016ed:	83 ec 04             	sub    $0x4,%esp
  8016f0:	53                   	push   %ebx
  8016f1:	50                   	push   %eax
  8016f2:	68 d0 2b 80 00       	push   $0x802bd0
  8016f7:	e8 09 ec ff ff       	call   800305 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016fc:	83 c4 10             	add    $0x10,%esp
  8016ff:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801704:	eb 23                	jmp    801729 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801706:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801709:	8b 52 18             	mov    0x18(%edx),%edx
  80170c:	85 d2                	test   %edx,%edx
  80170e:	74 14                	je     801724 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801710:	83 ec 08             	sub    $0x8,%esp
  801713:	ff 75 0c             	pushl  0xc(%ebp)
  801716:	50                   	push   %eax
  801717:	ff d2                	call   *%edx
  801719:	89 c2                	mov    %eax,%edx
  80171b:	83 c4 10             	add    $0x10,%esp
  80171e:	eb 09                	jmp    801729 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801720:	89 c2                	mov    %eax,%edx
  801722:	eb 05                	jmp    801729 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801724:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801729:	89 d0                	mov    %edx,%eax
  80172b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80172e:	c9                   	leave  
  80172f:	c3                   	ret    

00801730 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801730:	55                   	push   %ebp
  801731:	89 e5                	mov    %esp,%ebp
  801733:	53                   	push   %ebx
  801734:	83 ec 14             	sub    $0x14,%esp
  801737:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80173a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80173d:	50                   	push   %eax
  80173e:	ff 75 08             	pushl  0x8(%ebp)
  801741:	e8 6c fb ff ff       	call   8012b2 <fd_lookup>
  801746:	83 c4 08             	add    $0x8,%esp
  801749:	89 c2                	mov    %eax,%edx
  80174b:	85 c0                	test   %eax,%eax
  80174d:	78 58                	js     8017a7 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80174f:	83 ec 08             	sub    $0x8,%esp
  801752:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801755:	50                   	push   %eax
  801756:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801759:	ff 30                	pushl  (%eax)
  80175b:	e8 a8 fb ff ff       	call   801308 <dev_lookup>
  801760:	83 c4 10             	add    $0x10,%esp
  801763:	85 c0                	test   %eax,%eax
  801765:	78 37                	js     80179e <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801767:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80176a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80176e:	74 32                	je     8017a2 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801770:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801773:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80177a:	00 00 00 
	stat->st_isdir = 0;
  80177d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801784:	00 00 00 
	stat->st_dev = dev;
  801787:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80178d:	83 ec 08             	sub    $0x8,%esp
  801790:	53                   	push   %ebx
  801791:	ff 75 f0             	pushl  -0x10(%ebp)
  801794:	ff 50 14             	call   *0x14(%eax)
  801797:	89 c2                	mov    %eax,%edx
  801799:	83 c4 10             	add    $0x10,%esp
  80179c:	eb 09                	jmp    8017a7 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80179e:	89 c2                	mov    %eax,%edx
  8017a0:	eb 05                	jmp    8017a7 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8017a2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8017a7:	89 d0                	mov    %edx,%eax
  8017a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017ac:	c9                   	leave  
  8017ad:	c3                   	ret    

008017ae <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017ae:	55                   	push   %ebp
  8017af:	89 e5                	mov    %esp,%ebp
  8017b1:	56                   	push   %esi
  8017b2:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017b3:	83 ec 08             	sub    $0x8,%esp
  8017b6:	6a 00                	push   $0x0
  8017b8:	ff 75 08             	pushl  0x8(%ebp)
  8017bb:	e8 0c 02 00 00       	call   8019cc <open>
  8017c0:	89 c3                	mov    %eax,%ebx
  8017c2:	83 c4 10             	add    $0x10,%esp
  8017c5:	85 c0                	test   %eax,%eax
  8017c7:	78 1b                	js     8017e4 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017c9:	83 ec 08             	sub    $0x8,%esp
  8017cc:	ff 75 0c             	pushl  0xc(%ebp)
  8017cf:	50                   	push   %eax
  8017d0:	e8 5b ff ff ff       	call   801730 <fstat>
  8017d5:	89 c6                	mov    %eax,%esi
	close(fd);
  8017d7:	89 1c 24             	mov    %ebx,(%esp)
  8017da:	e8 fd fb ff ff       	call   8013dc <close>
	return r;
  8017df:	83 c4 10             	add    $0x10,%esp
  8017e2:	89 f0                	mov    %esi,%eax
}
  8017e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017e7:	5b                   	pop    %ebx
  8017e8:	5e                   	pop    %esi
  8017e9:	5d                   	pop    %ebp
  8017ea:	c3                   	ret    

008017eb <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017eb:	55                   	push   %ebp
  8017ec:	89 e5                	mov    %esp,%ebp
  8017ee:	56                   	push   %esi
  8017ef:	53                   	push   %ebx
  8017f0:	89 c6                	mov    %eax,%esi
  8017f2:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017f4:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8017fb:	75 12                	jne    80180f <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017fd:	83 ec 0c             	sub    $0xc,%esp
  801800:	6a 01                	push   $0x1
  801802:	e8 fc f9 ff ff       	call   801203 <ipc_find_env>
  801807:	a3 04 40 80 00       	mov    %eax,0x804004
  80180c:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80180f:	6a 07                	push   $0x7
  801811:	68 00 50 80 00       	push   $0x805000
  801816:	56                   	push   %esi
  801817:	ff 35 04 40 80 00    	pushl  0x804004
  80181d:	e8 8d f9 ff ff       	call   8011af <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801822:	83 c4 0c             	add    $0xc,%esp
  801825:	6a 00                	push   $0x0
  801827:	53                   	push   %ebx
  801828:	6a 00                	push   $0x0
  80182a:	e8 17 f9 ff ff       	call   801146 <ipc_recv>
}
  80182f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801832:	5b                   	pop    %ebx
  801833:	5e                   	pop    %esi
  801834:	5d                   	pop    %ebp
  801835:	c3                   	ret    

00801836 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801836:	55                   	push   %ebp
  801837:	89 e5                	mov    %esp,%ebp
  801839:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80183c:	8b 45 08             	mov    0x8(%ebp),%eax
  80183f:	8b 40 0c             	mov    0xc(%eax),%eax
  801842:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801847:	8b 45 0c             	mov    0xc(%ebp),%eax
  80184a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80184f:	ba 00 00 00 00       	mov    $0x0,%edx
  801854:	b8 02 00 00 00       	mov    $0x2,%eax
  801859:	e8 8d ff ff ff       	call   8017eb <fsipc>
}
  80185e:	c9                   	leave  
  80185f:	c3                   	ret    

00801860 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801860:	55                   	push   %ebp
  801861:	89 e5                	mov    %esp,%ebp
  801863:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801866:	8b 45 08             	mov    0x8(%ebp),%eax
  801869:	8b 40 0c             	mov    0xc(%eax),%eax
  80186c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801871:	ba 00 00 00 00       	mov    $0x0,%edx
  801876:	b8 06 00 00 00       	mov    $0x6,%eax
  80187b:	e8 6b ff ff ff       	call   8017eb <fsipc>
}
  801880:	c9                   	leave  
  801881:	c3                   	ret    

00801882 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801882:	55                   	push   %ebp
  801883:	89 e5                	mov    %esp,%ebp
  801885:	53                   	push   %ebx
  801886:	83 ec 04             	sub    $0x4,%esp
  801889:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80188c:	8b 45 08             	mov    0x8(%ebp),%eax
  80188f:	8b 40 0c             	mov    0xc(%eax),%eax
  801892:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801897:	ba 00 00 00 00       	mov    $0x0,%edx
  80189c:	b8 05 00 00 00       	mov    $0x5,%eax
  8018a1:	e8 45 ff ff ff       	call   8017eb <fsipc>
  8018a6:	85 c0                	test   %eax,%eax
  8018a8:	78 2c                	js     8018d6 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018aa:	83 ec 08             	sub    $0x8,%esp
  8018ad:	68 00 50 80 00       	push   $0x805000
  8018b2:	53                   	push   %ebx
  8018b3:	e8 d2 ef ff ff       	call   80088a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018b8:	a1 80 50 80 00       	mov    0x805080,%eax
  8018bd:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018c3:	a1 84 50 80 00       	mov    0x805084,%eax
  8018c8:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018ce:	83 c4 10             	add    $0x10,%esp
  8018d1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018d9:	c9                   	leave  
  8018da:	c3                   	ret    

008018db <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8018db:	55                   	push   %ebp
  8018dc:	89 e5                	mov    %esp,%ebp
  8018de:	53                   	push   %ebx
  8018df:	83 ec 08             	sub    $0x8,%esp
  8018e2:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8018e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8018e8:	8b 52 0c             	mov    0xc(%edx),%edx
  8018eb:	89 15 00 50 80 00    	mov    %edx,0x805000
  8018f1:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8018f6:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  8018fb:	0f 46 d8             	cmovbe %eax,%ebx
	
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  8018fe:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  801904:	53                   	push   %ebx
  801905:	ff 75 0c             	pushl  0xc(%ebp)
  801908:	68 08 50 80 00       	push   $0x805008
  80190d:	e8 0a f1 ff ff       	call   800a1c <memmove>

	
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) 
  801912:	ba 00 00 00 00       	mov    $0x0,%edx
  801917:	b8 04 00 00 00       	mov    $0x4,%eax
  80191c:	e8 ca fe ff ff       	call   8017eb <fsipc>
  801921:	83 c4 10             	add    $0x10,%esp
  801924:	85 c0                	test   %eax,%eax
  801926:	78 1d                	js     801945 <devfile_write+0x6a>
		return r;
	assert(r <= n_real); 
  801928:	39 d8                	cmp    %ebx,%eax
  80192a:	76 19                	jbe    801945 <devfile_write+0x6a>
  80192c:	68 44 2c 80 00       	push   $0x802c44
  801931:	68 50 2c 80 00       	push   $0x802c50
  801936:	68 a3 00 00 00       	push   $0xa3
  80193b:	68 65 2c 80 00       	push   $0x802c65
  801940:	e8 e7 e8 ff ff       	call   80022c <_panic>
	return r;
}
  801945:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801948:	c9                   	leave  
  801949:	c3                   	ret    

0080194a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80194a:	55                   	push   %ebp
  80194b:	89 e5                	mov    %esp,%ebp
  80194d:	56                   	push   %esi
  80194e:	53                   	push   %ebx
  80194f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801952:	8b 45 08             	mov    0x8(%ebp),%eax
  801955:	8b 40 0c             	mov    0xc(%eax),%eax
  801958:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80195d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801963:	ba 00 00 00 00       	mov    $0x0,%edx
  801968:	b8 03 00 00 00       	mov    $0x3,%eax
  80196d:	e8 79 fe ff ff       	call   8017eb <fsipc>
  801972:	89 c3                	mov    %eax,%ebx
  801974:	85 c0                	test   %eax,%eax
  801976:	78 4b                	js     8019c3 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801978:	39 c6                	cmp    %eax,%esi
  80197a:	73 16                	jae    801992 <devfile_read+0x48>
  80197c:	68 70 2c 80 00       	push   $0x802c70
  801981:	68 50 2c 80 00       	push   $0x802c50
  801986:	6a 7c                	push   $0x7c
  801988:	68 65 2c 80 00       	push   $0x802c65
  80198d:	e8 9a e8 ff ff       	call   80022c <_panic>
	assert(r <= PGSIZE);
  801992:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801997:	7e 16                	jle    8019af <devfile_read+0x65>
  801999:	68 77 2c 80 00       	push   $0x802c77
  80199e:	68 50 2c 80 00       	push   $0x802c50
  8019a3:	6a 7d                	push   $0x7d
  8019a5:	68 65 2c 80 00       	push   $0x802c65
  8019aa:	e8 7d e8 ff ff       	call   80022c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8019af:	83 ec 04             	sub    $0x4,%esp
  8019b2:	50                   	push   %eax
  8019b3:	68 00 50 80 00       	push   $0x805000
  8019b8:	ff 75 0c             	pushl  0xc(%ebp)
  8019bb:	e8 5c f0 ff ff       	call   800a1c <memmove>
	return r;
  8019c0:	83 c4 10             	add    $0x10,%esp
}
  8019c3:	89 d8                	mov    %ebx,%eax
  8019c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019c8:	5b                   	pop    %ebx
  8019c9:	5e                   	pop    %esi
  8019ca:	5d                   	pop    %ebp
  8019cb:	c3                   	ret    

008019cc <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8019cc:	55                   	push   %ebp
  8019cd:	89 e5                	mov    %esp,%ebp
  8019cf:	53                   	push   %ebx
  8019d0:	83 ec 20             	sub    $0x20,%esp
  8019d3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8019d6:	53                   	push   %ebx
  8019d7:	e8 75 ee ff ff       	call   800851 <strlen>
  8019dc:	83 c4 10             	add    $0x10,%esp
  8019df:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019e4:	7f 67                	jg     801a4d <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019e6:	83 ec 0c             	sub    $0xc,%esp
  8019e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019ec:	50                   	push   %eax
  8019ed:	e8 71 f8 ff ff       	call   801263 <fd_alloc>
  8019f2:	83 c4 10             	add    $0x10,%esp
		return r;
  8019f5:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019f7:	85 c0                	test   %eax,%eax
  8019f9:	78 57                	js     801a52 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8019fb:	83 ec 08             	sub    $0x8,%esp
  8019fe:	53                   	push   %ebx
  8019ff:	68 00 50 80 00       	push   $0x805000
  801a04:	e8 81 ee ff ff       	call   80088a <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a09:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a0c:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a11:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a14:	b8 01 00 00 00       	mov    $0x1,%eax
  801a19:	e8 cd fd ff ff       	call   8017eb <fsipc>
  801a1e:	89 c3                	mov    %eax,%ebx
  801a20:	83 c4 10             	add    $0x10,%esp
  801a23:	85 c0                	test   %eax,%eax
  801a25:	79 14                	jns    801a3b <open+0x6f>
		fd_close(fd, 0);
  801a27:	83 ec 08             	sub    $0x8,%esp
  801a2a:	6a 00                	push   $0x0
  801a2c:	ff 75 f4             	pushl  -0xc(%ebp)
  801a2f:	e8 27 f9 ff ff       	call   80135b <fd_close>
		return r;
  801a34:	83 c4 10             	add    $0x10,%esp
  801a37:	89 da                	mov    %ebx,%edx
  801a39:	eb 17                	jmp    801a52 <open+0x86>
	}

	return fd2num(fd);
  801a3b:	83 ec 0c             	sub    $0xc,%esp
  801a3e:	ff 75 f4             	pushl  -0xc(%ebp)
  801a41:	e8 f6 f7 ff ff       	call   80123c <fd2num>
  801a46:	89 c2                	mov    %eax,%edx
  801a48:	83 c4 10             	add    $0x10,%esp
  801a4b:	eb 05                	jmp    801a52 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a4d:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a52:	89 d0                	mov    %edx,%eax
  801a54:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a57:	c9                   	leave  
  801a58:	c3                   	ret    

00801a59 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a59:	55                   	push   %ebp
  801a5a:	89 e5                	mov    %esp,%ebp
  801a5c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a5f:	ba 00 00 00 00       	mov    $0x0,%edx
  801a64:	b8 08 00 00 00       	mov    $0x8,%eax
  801a69:	e8 7d fd ff ff       	call   8017eb <fsipc>
}
  801a6e:	c9                   	leave  
  801a6f:	c3                   	ret    

00801a70 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801a70:	55                   	push   %ebp
  801a71:	89 e5                	mov    %esp,%ebp
  801a73:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801a76:	68 83 2c 80 00       	push   $0x802c83
  801a7b:	ff 75 0c             	pushl  0xc(%ebp)
  801a7e:	e8 07 ee ff ff       	call   80088a <strcpy>
	return 0;
}
  801a83:	b8 00 00 00 00       	mov    $0x0,%eax
  801a88:	c9                   	leave  
  801a89:	c3                   	ret    

00801a8a <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801a8a:	55                   	push   %ebp
  801a8b:	89 e5                	mov    %esp,%ebp
  801a8d:	53                   	push   %ebx
  801a8e:	83 ec 10             	sub    $0x10,%esp
  801a91:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801a94:	53                   	push   %ebx
  801a95:	e8 92 09 00 00       	call   80242c <pageref>
  801a9a:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801a9d:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801aa2:	83 f8 01             	cmp    $0x1,%eax
  801aa5:	75 10                	jne    801ab7 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801aa7:	83 ec 0c             	sub    $0xc,%esp
  801aaa:	ff 73 0c             	pushl  0xc(%ebx)
  801aad:	e8 c0 02 00 00       	call   801d72 <nsipc_close>
  801ab2:	89 c2                	mov    %eax,%edx
  801ab4:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801ab7:	89 d0                	mov    %edx,%eax
  801ab9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801abc:	c9                   	leave  
  801abd:	c3                   	ret    

00801abe <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801abe:	55                   	push   %ebp
  801abf:	89 e5                	mov    %esp,%ebp
  801ac1:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801ac4:	6a 00                	push   $0x0
  801ac6:	ff 75 10             	pushl  0x10(%ebp)
  801ac9:	ff 75 0c             	pushl  0xc(%ebp)
  801acc:	8b 45 08             	mov    0x8(%ebp),%eax
  801acf:	ff 70 0c             	pushl  0xc(%eax)
  801ad2:	e8 78 03 00 00       	call   801e4f <nsipc_send>
}
  801ad7:	c9                   	leave  
  801ad8:	c3                   	ret    

00801ad9 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801ad9:	55                   	push   %ebp
  801ada:	89 e5                	mov    %esp,%ebp
  801adc:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801adf:	6a 00                	push   $0x0
  801ae1:	ff 75 10             	pushl  0x10(%ebp)
  801ae4:	ff 75 0c             	pushl  0xc(%ebp)
  801ae7:	8b 45 08             	mov    0x8(%ebp),%eax
  801aea:	ff 70 0c             	pushl  0xc(%eax)
  801aed:	e8 f1 02 00 00       	call   801de3 <nsipc_recv>
}
  801af2:	c9                   	leave  
  801af3:	c3                   	ret    

00801af4 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801af4:	55                   	push   %ebp
  801af5:	89 e5                	mov    %esp,%ebp
  801af7:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801afa:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801afd:	52                   	push   %edx
  801afe:	50                   	push   %eax
  801aff:	e8 ae f7 ff ff       	call   8012b2 <fd_lookup>
  801b04:	83 c4 10             	add    $0x10,%esp
  801b07:	85 c0                	test   %eax,%eax
  801b09:	78 17                	js     801b22 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801b0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b0e:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801b14:	39 08                	cmp    %ecx,(%eax)
  801b16:	75 05                	jne    801b1d <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801b18:	8b 40 0c             	mov    0xc(%eax),%eax
  801b1b:	eb 05                	jmp    801b22 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801b1d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801b22:	c9                   	leave  
  801b23:	c3                   	ret    

00801b24 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801b24:	55                   	push   %ebp
  801b25:	89 e5                	mov    %esp,%ebp
  801b27:	56                   	push   %esi
  801b28:	53                   	push   %ebx
  801b29:	83 ec 1c             	sub    $0x1c,%esp
  801b2c:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801b2e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b31:	50                   	push   %eax
  801b32:	e8 2c f7 ff ff       	call   801263 <fd_alloc>
  801b37:	89 c3                	mov    %eax,%ebx
  801b39:	83 c4 10             	add    $0x10,%esp
  801b3c:	85 c0                	test   %eax,%eax
  801b3e:	78 1b                	js     801b5b <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801b40:	83 ec 04             	sub    $0x4,%esp
  801b43:	68 07 04 00 00       	push   $0x407
  801b48:	ff 75 f4             	pushl  -0xc(%ebp)
  801b4b:	6a 00                	push   $0x0
  801b4d:	e8 3b f1 ff ff       	call   800c8d <sys_page_alloc>
  801b52:	89 c3                	mov    %eax,%ebx
  801b54:	83 c4 10             	add    $0x10,%esp
  801b57:	85 c0                	test   %eax,%eax
  801b59:	79 10                	jns    801b6b <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801b5b:	83 ec 0c             	sub    $0xc,%esp
  801b5e:	56                   	push   %esi
  801b5f:	e8 0e 02 00 00       	call   801d72 <nsipc_close>
		return r;
  801b64:	83 c4 10             	add    $0x10,%esp
  801b67:	89 d8                	mov    %ebx,%eax
  801b69:	eb 24                	jmp    801b8f <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801b6b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b71:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b74:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801b76:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b79:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801b80:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801b83:	83 ec 0c             	sub    $0xc,%esp
  801b86:	50                   	push   %eax
  801b87:	e8 b0 f6 ff ff       	call   80123c <fd2num>
  801b8c:	83 c4 10             	add    $0x10,%esp
}
  801b8f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b92:	5b                   	pop    %ebx
  801b93:	5e                   	pop    %esi
  801b94:	5d                   	pop    %ebp
  801b95:	c3                   	ret    

00801b96 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801b96:	55                   	push   %ebp
  801b97:	89 e5                	mov    %esp,%ebp
  801b99:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b9c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b9f:	e8 50 ff ff ff       	call   801af4 <fd2sockid>
		return r;
  801ba4:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ba6:	85 c0                	test   %eax,%eax
  801ba8:	78 1f                	js     801bc9 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801baa:	83 ec 04             	sub    $0x4,%esp
  801bad:	ff 75 10             	pushl  0x10(%ebp)
  801bb0:	ff 75 0c             	pushl  0xc(%ebp)
  801bb3:	50                   	push   %eax
  801bb4:	e8 12 01 00 00       	call   801ccb <nsipc_accept>
  801bb9:	83 c4 10             	add    $0x10,%esp
		return r;
  801bbc:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801bbe:	85 c0                	test   %eax,%eax
  801bc0:	78 07                	js     801bc9 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801bc2:	e8 5d ff ff ff       	call   801b24 <alloc_sockfd>
  801bc7:	89 c1                	mov    %eax,%ecx
}
  801bc9:	89 c8                	mov    %ecx,%eax
  801bcb:	c9                   	leave  
  801bcc:	c3                   	ret    

00801bcd <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801bcd:	55                   	push   %ebp
  801bce:	89 e5                	mov    %esp,%ebp
  801bd0:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bd3:	8b 45 08             	mov    0x8(%ebp),%eax
  801bd6:	e8 19 ff ff ff       	call   801af4 <fd2sockid>
  801bdb:	85 c0                	test   %eax,%eax
  801bdd:	78 12                	js     801bf1 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801bdf:	83 ec 04             	sub    $0x4,%esp
  801be2:	ff 75 10             	pushl  0x10(%ebp)
  801be5:	ff 75 0c             	pushl  0xc(%ebp)
  801be8:	50                   	push   %eax
  801be9:	e8 2d 01 00 00       	call   801d1b <nsipc_bind>
  801bee:	83 c4 10             	add    $0x10,%esp
}
  801bf1:	c9                   	leave  
  801bf2:	c3                   	ret    

00801bf3 <shutdown>:

int
shutdown(int s, int how)
{
  801bf3:	55                   	push   %ebp
  801bf4:	89 e5                	mov    %esp,%ebp
  801bf6:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bf9:	8b 45 08             	mov    0x8(%ebp),%eax
  801bfc:	e8 f3 fe ff ff       	call   801af4 <fd2sockid>
  801c01:	85 c0                	test   %eax,%eax
  801c03:	78 0f                	js     801c14 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801c05:	83 ec 08             	sub    $0x8,%esp
  801c08:	ff 75 0c             	pushl  0xc(%ebp)
  801c0b:	50                   	push   %eax
  801c0c:	e8 3f 01 00 00       	call   801d50 <nsipc_shutdown>
  801c11:	83 c4 10             	add    $0x10,%esp
}
  801c14:	c9                   	leave  
  801c15:	c3                   	ret    

00801c16 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801c16:	55                   	push   %ebp
  801c17:	89 e5                	mov    %esp,%ebp
  801c19:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c1c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c1f:	e8 d0 fe ff ff       	call   801af4 <fd2sockid>
  801c24:	85 c0                	test   %eax,%eax
  801c26:	78 12                	js     801c3a <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801c28:	83 ec 04             	sub    $0x4,%esp
  801c2b:	ff 75 10             	pushl  0x10(%ebp)
  801c2e:	ff 75 0c             	pushl  0xc(%ebp)
  801c31:	50                   	push   %eax
  801c32:	e8 55 01 00 00       	call   801d8c <nsipc_connect>
  801c37:	83 c4 10             	add    $0x10,%esp
}
  801c3a:	c9                   	leave  
  801c3b:	c3                   	ret    

00801c3c <listen>:

int
listen(int s, int backlog)
{
  801c3c:	55                   	push   %ebp
  801c3d:	89 e5                	mov    %esp,%ebp
  801c3f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c42:	8b 45 08             	mov    0x8(%ebp),%eax
  801c45:	e8 aa fe ff ff       	call   801af4 <fd2sockid>
  801c4a:	85 c0                	test   %eax,%eax
  801c4c:	78 0f                	js     801c5d <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801c4e:	83 ec 08             	sub    $0x8,%esp
  801c51:	ff 75 0c             	pushl  0xc(%ebp)
  801c54:	50                   	push   %eax
  801c55:	e8 67 01 00 00       	call   801dc1 <nsipc_listen>
  801c5a:	83 c4 10             	add    $0x10,%esp
}
  801c5d:	c9                   	leave  
  801c5e:	c3                   	ret    

00801c5f <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801c5f:	55                   	push   %ebp
  801c60:	89 e5                	mov    %esp,%ebp
  801c62:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801c65:	ff 75 10             	pushl  0x10(%ebp)
  801c68:	ff 75 0c             	pushl  0xc(%ebp)
  801c6b:	ff 75 08             	pushl  0x8(%ebp)
  801c6e:	e8 3a 02 00 00       	call   801ead <nsipc_socket>
  801c73:	83 c4 10             	add    $0x10,%esp
  801c76:	85 c0                	test   %eax,%eax
  801c78:	78 05                	js     801c7f <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801c7a:	e8 a5 fe ff ff       	call   801b24 <alloc_sockfd>
}
  801c7f:	c9                   	leave  
  801c80:	c3                   	ret    

00801c81 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801c81:	55                   	push   %ebp
  801c82:	89 e5                	mov    %esp,%ebp
  801c84:	53                   	push   %ebx
  801c85:	83 ec 04             	sub    $0x4,%esp
  801c88:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801c8a:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  801c91:	75 12                	jne    801ca5 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801c93:	83 ec 0c             	sub    $0xc,%esp
  801c96:	6a 02                	push   $0x2
  801c98:	e8 66 f5 ff ff       	call   801203 <ipc_find_env>
  801c9d:	a3 08 40 80 00       	mov    %eax,0x804008
  801ca2:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801ca5:	6a 07                	push   $0x7
  801ca7:	68 00 60 80 00       	push   $0x806000
  801cac:	53                   	push   %ebx
  801cad:	ff 35 08 40 80 00    	pushl  0x804008
  801cb3:	e8 f7 f4 ff ff       	call   8011af <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801cb8:	83 c4 0c             	add    $0xc,%esp
  801cbb:	6a 00                	push   $0x0
  801cbd:	6a 00                	push   $0x0
  801cbf:	6a 00                	push   $0x0
  801cc1:	e8 80 f4 ff ff       	call   801146 <ipc_recv>
}
  801cc6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cc9:	c9                   	leave  
  801cca:	c3                   	ret    

00801ccb <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801ccb:	55                   	push   %ebp
  801ccc:	89 e5                	mov    %esp,%ebp
  801cce:	56                   	push   %esi
  801ccf:	53                   	push   %ebx
  801cd0:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801cd3:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd6:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801cdb:	8b 06                	mov    (%esi),%eax
  801cdd:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801ce2:	b8 01 00 00 00       	mov    $0x1,%eax
  801ce7:	e8 95 ff ff ff       	call   801c81 <nsipc>
  801cec:	89 c3                	mov    %eax,%ebx
  801cee:	85 c0                	test   %eax,%eax
  801cf0:	78 20                	js     801d12 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801cf2:	83 ec 04             	sub    $0x4,%esp
  801cf5:	ff 35 10 60 80 00    	pushl  0x806010
  801cfb:	68 00 60 80 00       	push   $0x806000
  801d00:	ff 75 0c             	pushl  0xc(%ebp)
  801d03:	e8 14 ed ff ff       	call   800a1c <memmove>
		*addrlen = ret->ret_addrlen;
  801d08:	a1 10 60 80 00       	mov    0x806010,%eax
  801d0d:	89 06                	mov    %eax,(%esi)
  801d0f:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801d12:	89 d8                	mov    %ebx,%eax
  801d14:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d17:	5b                   	pop    %ebx
  801d18:	5e                   	pop    %esi
  801d19:	5d                   	pop    %ebp
  801d1a:	c3                   	ret    

00801d1b <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801d1b:	55                   	push   %ebp
  801d1c:	89 e5                	mov    %esp,%ebp
  801d1e:	53                   	push   %ebx
  801d1f:	83 ec 08             	sub    $0x8,%esp
  801d22:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801d25:	8b 45 08             	mov    0x8(%ebp),%eax
  801d28:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801d2d:	53                   	push   %ebx
  801d2e:	ff 75 0c             	pushl  0xc(%ebp)
  801d31:	68 04 60 80 00       	push   $0x806004
  801d36:	e8 e1 ec ff ff       	call   800a1c <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801d3b:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801d41:	b8 02 00 00 00       	mov    $0x2,%eax
  801d46:	e8 36 ff ff ff       	call   801c81 <nsipc>
}
  801d4b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d4e:	c9                   	leave  
  801d4f:	c3                   	ret    

00801d50 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801d50:	55                   	push   %ebp
  801d51:	89 e5                	mov    %esp,%ebp
  801d53:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801d56:	8b 45 08             	mov    0x8(%ebp),%eax
  801d59:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801d5e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d61:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801d66:	b8 03 00 00 00       	mov    $0x3,%eax
  801d6b:	e8 11 ff ff ff       	call   801c81 <nsipc>
}
  801d70:	c9                   	leave  
  801d71:	c3                   	ret    

00801d72 <nsipc_close>:

int
nsipc_close(int s)
{
  801d72:	55                   	push   %ebp
  801d73:	89 e5                	mov    %esp,%ebp
  801d75:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801d78:	8b 45 08             	mov    0x8(%ebp),%eax
  801d7b:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801d80:	b8 04 00 00 00       	mov    $0x4,%eax
  801d85:	e8 f7 fe ff ff       	call   801c81 <nsipc>
}
  801d8a:	c9                   	leave  
  801d8b:	c3                   	ret    

00801d8c <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801d8c:	55                   	push   %ebp
  801d8d:	89 e5                	mov    %esp,%ebp
  801d8f:	53                   	push   %ebx
  801d90:	83 ec 08             	sub    $0x8,%esp
  801d93:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801d96:	8b 45 08             	mov    0x8(%ebp),%eax
  801d99:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801d9e:	53                   	push   %ebx
  801d9f:	ff 75 0c             	pushl  0xc(%ebp)
  801da2:	68 04 60 80 00       	push   $0x806004
  801da7:	e8 70 ec ff ff       	call   800a1c <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801dac:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801db2:	b8 05 00 00 00       	mov    $0x5,%eax
  801db7:	e8 c5 fe ff ff       	call   801c81 <nsipc>
}
  801dbc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801dbf:	c9                   	leave  
  801dc0:	c3                   	ret    

00801dc1 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801dc1:	55                   	push   %ebp
  801dc2:	89 e5                	mov    %esp,%ebp
  801dc4:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801dc7:	8b 45 08             	mov    0x8(%ebp),%eax
  801dca:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801dcf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dd2:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801dd7:	b8 06 00 00 00       	mov    $0x6,%eax
  801ddc:	e8 a0 fe ff ff       	call   801c81 <nsipc>
}
  801de1:	c9                   	leave  
  801de2:	c3                   	ret    

00801de3 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801de3:	55                   	push   %ebp
  801de4:	89 e5                	mov    %esp,%ebp
  801de6:	56                   	push   %esi
  801de7:	53                   	push   %ebx
  801de8:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801deb:	8b 45 08             	mov    0x8(%ebp),%eax
  801dee:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801df3:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801df9:	8b 45 14             	mov    0x14(%ebp),%eax
  801dfc:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801e01:	b8 07 00 00 00       	mov    $0x7,%eax
  801e06:	e8 76 fe ff ff       	call   801c81 <nsipc>
  801e0b:	89 c3                	mov    %eax,%ebx
  801e0d:	85 c0                	test   %eax,%eax
  801e0f:	78 35                	js     801e46 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801e11:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801e16:	7f 04                	jg     801e1c <nsipc_recv+0x39>
  801e18:	39 c6                	cmp    %eax,%esi
  801e1a:	7d 16                	jge    801e32 <nsipc_recv+0x4f>
  801e1c:	68 8f 2c 80 00       	push   $0x802c8f
  801e21:	68 50 2c 80 00       	push   $0x802c50
  801e26:	6a 62                	push   $0x62
  801e28:	68 a4 2c 80 00       	push   $0x802ca4
  801e2d:	e8 fa e3 ff ff       	call   80022c <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801e32:	83 ec 04             	sub    $0x4,%esp
  801e35:	50                   	push   %eax
  801e36:	68 00 60 80 00       	push   $0x806000
  801e3b:	ff 75 0c             	pushl  0xc(%ebp)
  801e3e:	e8 d9 eb ff ff       	call   800a1c <memmove>
  801e43:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801e46:	89 d8                	mov    %ebx,%eax
  801e48:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e4b:	5b                   	pop    %ebx
  801e4c:	5e                   	pop    %esi
  801e4d:	5d                   	pop    %ebp
  801e4e:	c3                   	ret    

00801e4f <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801e4f:	55                   	push   %ebp
  801e50:	89 e5                	mov    %esp,%ebp
  801e52:	53                   	push   %ebx
  801e53:	83 ec 04             	sub    $0x4,%esp
  801e56:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801e59:	8b 45 08             	mov    0x8(%ebp),%eax
  801e5c:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801e61:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801e67:	7e 16                	jle    801e7f <nsipc_send+0x30>
  801e69:	68 b0 2c 80 00       	push   $0x802cb0
  801e6e:	68 50 2c 80 00       	push   $0x802c50
  801e73:	6a 6d                	push   $0x6d
  801e75:	68 a4 2c 80 00       	push   $0x802ca4
  801e7a:	e8 ad e3 ff ff       	call   80022c <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801e7f:	83 ec 04             	sub    $0x4,%esp
  801e82:	53                   	push   %ebx
  801e83:	ff 75 0c             	pushl  0xc(%ebp)
  801e86:	68 0c 60 80 00       	push   $0x80600c
  801e8b:	e8 8c eb ff ff       	call   800a1c <memmove>
	nsipcbuf.send.req_size = size;
  801e90:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801e96:	8b 45 14             	mov    0x14(%ebp),%eax
  801e99:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801e9e:	b8 08 00 00 00       	mov    $0x8,%eax
  801ea3:	e8 d9 fd ff ff       	call   801c81 <nsipc>
}
  801ea8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801eab:	c9                   	leave  
  801eac:	c3                   	ret    

00801ead <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801ead:	55                   	push   %ebp
  801eae:	89 e5                	mov    %esp,%ebp
  801eb0:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801eb3:	8b 45 08             	mov    0x8(%ebp),%eax
  801eb6:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801ebb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ebe:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801ec3:	8b 45 10             	mov    0x10(%ebp),%eax
  801ec6:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801ecb:	b8 09 00 00 00       	mov    $0x9,%eax
  801ed0:	e8 ac fd ff ff       	call   801c81 <nsipc>
}
  801ed5:	c9                   	leave  
  801ed6:	c3                   	ret    

00801ed7 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801ed7:	55                   	push   %ebp
  801ed8:	89 e5                	mov    %esp,%ebp
  801eda:	56                   	push   %esi
  801edb:	53                   	push   %ebx
  801edc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801edf:	83 ec 0c             	sub    $0xc,%esp
  801ee2:	ff 75 08             	pushl  0x8(%ebp)
  801ee5:	e8 62 f3 ff ff       	call   80124c <fd2data>
  801eea:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801eec:	83 c4 08             	add    $0x8,%esp
  801eef:	68 bc 2c 80 00       	push   $0x802cbc
  801ef4:	53                   	push   %ebx
  801ef5:	e8 90 e9 ff ff       	call   80088a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801efa:	8b 46 04             	mov    0x4(%esi),%eax
  801efd:	2b 06                	sub    (%esi),%eax
  801eff:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801f05:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801f0c:	00 00 00 
	stat->st_dev = &devpipe;
  801f0f:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801f16:	30 80 00 
	return 0;
}
  801f19:	b8 00 00 00 00       	mov    $0x0,%eax
  801f1e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f21:	5b                   	pop    %ebx
  801f22:	5e                   	pop    %esi
  801f23:	5d                   	pop    %ebp
  801f24:	c3                   	ret    

00801f25 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801f25:	55                   	push   %ebp
  801f26:	89 e5                	mov    %esp,%ebp
  801f28:	53                   	push   %ebx
  801f29:	83 ec 0c             	sub    $0xc,%esp
  801f2c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801f2f:	53                   	push   %ebx
  801f30:	6a 00                	push   $0x0
  801f32:	e8 db ed ff ff       	call   800d12 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801f37:	89 1c 24             	mov    %ebx,(%esp)
  801f3a:	e8 0d f3 ff ff       	call   80124c <fd2data>
  801f3f:	83 c4 08             	add    $0x8,%esp
  801f42:	50                   	push   %eax
  801f43:	6a 00                	push   $0x0
  801f45:	e8 c8 ed ff ff       	call   800d12 <sys_page_unmap>
}
  801f4a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f4d:	c9                   	leave  
  801f4e:	c3                   	ret    

00801f4f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801f4f:	55                   	push   %ebp
  801f50:	89 e5                	mov    %esp,%ebp
  801f52:	57                   	push   %edi
  801f53:	56                   	push   %esi
  801f54:	53                   	push   %ebx
  801f55:	83 ec 1c             	sub    $0x1c,%esp
  801f58:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801f5b:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801f5d:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801f62:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801f65:	83 ec 0c             	sub    $0xc,%esp
  801f68:	ff 75 e0             	pushl  -0x20(%ebp)
  801f6b:	e8 bc 04 00 00       	call   80242c <pageref>
  801f70:	89 c3                	mov    %eax,%ebx
  801f72:	89 3c 24             	mov    %edi,(%esp)
  801f75:	e8 b2 04 00 00       	call   80242c <pageref>
  801f7a:	83 c4 10             	add    $0x10,%esp
  801f7d:	39 c3                	cmp    %eax,%ebx
  801f7f:	0f 94 c1             	sete   %cl
  801f82:	0f b6 c9             	movzbl %cl,%ecx
  801f85:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801f88:	8b 15 0c 40 80 00    	mov    0x80400c,%edx
  801f8e:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801f91:	39 ce                	cmp    %ecx,%esi
  801f93:	74 1b                	je     801fb0 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801f95:	39 c3                	cmp    %eax,%ebx
  801f97:	75 c4                	jne    801f5d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801f99:	8b 42 58             	mov    0x58(%edx),%eax
  801f9c:	ff 75 e4             	pushl  -0x1c(%ebp)
  801f9f:	50                   	push   %eax
  801fa0:	56                   	push   %esi
  801fa1:	68 c3 2c 80 00       	push   $0x802cc3
  801fa6:	e8 5a e3 ff ff       	call   800305 <cprintf>
  801fab:	83 c4 10             	add    $0x10,%esp
  801fae:	eb ad                	jmp    801f5d <_pipeisclosed+0xe>
	}
}
  801fb0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801fb3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fb6:	5b                   	pop    %ebx
  801fb7:	5e                   	pop    %esi
  801fb8:	5f                   	pop    %edi
  801fb9:	5d                   	pop    %ebp
  801fba:	c3                   	ret    

00801fbb <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801fbb:	55                   	push   %ebp
  801fbc:	89 e5                	mov    %esp,%ebp
  801fbe:	57                   	push   %edi
  801fbf:	56                   	push   %esi
  801fc0:	53                   	push   %ebx
  801fc1:	83 ec 28             	sub    $0x28,%esp
  801fc4:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801fc7:	56                   	push   %esi
  801fc8:	e8 7f f2 ff ff       	call   80124c <fd2data>
  801fcd:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fcf:	83 c4 10             	add    $0x10,%esp
  801fd2:	bf 00 00 00 00       	mov    $0x0,%edi
  801fd7:	eb 4b                	jmp    802024 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801fd9:	89 da                	mov    %ebx,%edx
  801fdb:	89 f0                	mov    %esi,%eax
  801fdd:	e8 6d ff ff ff       	call   801f4f <_pipeisclosed>
  801fe2:	85 c0                	test   %eax,%eax
  801fe4:	75 48                	jne    80202e <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801fe6:	e8 83 ec ff ff       	call   800c6e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801feb:	8b 43 04             	mov    0x4(%ebx),%eax
  801fee:	8b 0b                	mov    (%ebx),%ecx
  801ff0:	8d 51 20             	lea    0x20(%ecx),%edx
  801ff3:	39 d0                	cmp    %edx,%eax
  801ff5:	73 e2                	jae    801fd9 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ff7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ffa:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801ffe:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802001:	89 c2                	mov    %eax,%edx
  802003:	c1 fa 1f             	sar    $0x1f,%edx
  802006:	89 d1                	mov    %edx,%ecx
  802008:	c1 e9 1b             	shr    $0x1b,%ecx
  80200b:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80200e:	83 e2 1f             	and    $0x1f,%edx
  802011:	29 ca                	sub    %ecx,%edx
  802013:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802017:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80201b:	83 c0 01             	add    $0x1,%eax
  80201e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802021:	83 c7 01             	add    $0x1,%edi
  802024:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802027:	75 c2                	jne    801feb <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802029:	8b 45 10             	mov    0x10(%ebp),%eax
  80202c:	eb 05                	jmp    802033 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80202e:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802033:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802036:	5b                   	pop    %ebx
  802037:	5e                   	pop    %esi
  802038:	5f                   	pop    %edi
  802039:	5d                   	pop    %ebp
  80203a:	c3                   	ret    

0080203b <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80203b:	55                   	push   %ebp
  80203c:	89 e5                	mov    %esp,%ebp
  80203e:	57                   	push   %edi
  80203f:	56                   	push   %esi
  802040:	53                   	push   %ebx
  802041:	83 ec 18             	sub    $0x18,%esp
  802044:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802047:	57                   	push   %edi
  802048:	e8 ff f1 ff ff       	call   80124c <fd2data>
  80204d:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80204f:	83 c4 10             	add    $0x10,%esp
  802052:	bb 00 00 00 00       	mov    $0x0,%ebx
  802057:	eb 3d                	jmp    802096 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802059:	85 db                	test   %ebx,%ebx
  80205b:	74 04                	je     802061 <devpipe_read+0x26>
				return i;
  80205d:	89 d8                	mov    %ebx,%eax
  80205f:	eb 44                	jmp    8020a5 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802061:	89 f2                	mov    %esi,%edx
  802063:	89 f8                	mov    %edi,%eax
  802065:	e8 e5 fe ff ff       	call   801f4f <_pipeisclosed>
  80206a:	85 c0                	test   %eax,%eax
  80206c:	75 32                	jne    8020a0 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80206e:	e8 fb eb ff ff       	call   800c6e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802073:	8b 06                	mov    (%esi),%eax
  802075:	3b 46 04             	cmp    0x4(%esi),%eax
  802078:	74 df                	je     802059 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80207a:	99                   	cltd   
  80207b:	c1 ea 1b             	shr    $0x1b,%edx
  80207e:	01 d0                	add    %edx,%eax
  802080:	83 e0 1f             	and    $0x1f,%eax
  802083:	29 d0                	sub    %edx,%eax
  802085:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80208a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80208d:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802090:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802093:	83 c3 01             	add    $0x1,%ebx
  802096:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802099:	75 d8                	jne    802073 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80209b:	8b 45 10             	mov    0x10(%ebp),%eax
  80209e:	eb 05                	jmp    8020a5 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8020a0:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8020a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020a8:	5b                   	pop    %ebx
  8020a9:	5e                   	pop    %esi
  8020aa:	5f                   	pop    %edi
  8020ab:	5d                   	pop    %ebp
  8020ac:	c3                   	ret    

008020ad <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8020ad:	55                   	push   %ebp
  8020ae:	89 e5                	mov    %esp,%ebp
  8020b0:	56                   	push   %esi
  8020b1:	53                   	push   %ebx
  8020b2:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8020b5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020b8:	50                   	push   %eax
  8020b9:	e8 a5 f1 ff ff       	call   801263 <fd_alloc>
  8020be:	83 c4 10             	add    $0x10,%esp
  8020c1:	89 c2                	mov    %eax,%edx
  8020c3:	85 c0                	test   %eax,%eax
  8020c5:	0f 88 2c 01 00 00    	js     8021f7 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020cb:	83 ec 04             	sub    $0x4,%esp
  8020ce:	68 07 04 00 00       	push   $0x407
  8020d3:	ff 75 f4             	pushl  -0xc(%ebp)
  8020d6:	6a 00                	push   $0x0
  8020d8:	e8 b0 eb ff ff       	call   800c8d <sys_page_alloc>
  8020dd:	83 c4 10             	add    $0x10,%esp
  8020e0:	89 c2                	mov    %eax,%edx
  8020e2:	85 c0                	test   %eax,%eax
  8020e4:	0f 88 0d 01 00 00    	js     8021f7 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8020ea:	83 ec 0c             	sub    $0xc,%esp
  8020ed:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8020f0:	50                   	push   %eax
  8020f1:	e8 6d f1 ff ff       	call   801263 <fd_alloc>
  8020f6:	89 c3                	mov    %eax,%ebx
  8020f8:	83 c4 10             	add    $0x10,%esp
  8020fb:	85 c0                	test   %eax,%eax
  8020fd:	0f 88 e2 00 00 00    	js     8021e5 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802103:	83 ec 04             	sub    $0x4,%esp
  802106:	68 07 04 00 00       	push   $0x407
  80210b:	ff 75 f0             	pushl  -0x10(%ebp)
  80210e:	6a 00                	push   $0x0
  802110:	e8 78 eb ff ff       	call   800c8d <sys_page_alloc>
  802115:	89 c3                	mov    %eax,%ebx
  802117:	83 c4 10             	add    $0x10,%esp
  80211a:	85 c0                	test   %eax,%eax
  80211c:	0f 88 c3 00 00 00    	js     8021e5 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802122:	83 ec 0c             	sub    $0xc,%esp
  802125:	ff 75 f4             	pushl  -0xc(%ebp)
  802128:	e8 1f f1 ff ff       	call   80124c <fd2data>
  80212d:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80212f:	83 c4 0c             	add    $0xc,%esp
  802132:	68 07 04 00 00       	push   $0x407
  802137:	50                   	push   %eax
  802138:	6a 00                	push   $0x0
  80213a:	e8 4e eb ff ff       	call   800c8d <sys_page_alloc>
  80213f:	89 c3                	mov    %eax,%ebx
  802141:	83 c4 10             	add    $0x10,%esp
  802144:	85 c0                	test   %eax,%eax
  802146:	0f 88 89 00 00 00    	js     8021d5 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80214c:	83 ec 0c             	sub    $0xc,%esp
  80214f:	ff 75 f0             	pushl  -0x10(%ebp)
  802152:	e8 f5 f0 ff ff       	call   80124c <fd2data>
  802157:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80215e:	50                   	push   %eax
  80215f:	6a 00                	push   $0x0
  802161:	56                   	push   %esi
  802162:	6a 00                	push   $0x0
  802164:	e8 67 eb ff ff       	call   800cd0 <sys_page_map>
  802169:	89 c3                	mov    %eax,%ebx
  80216b:	83 c4 20             	add    $0x20,%esp
  80216e:	85 c0                	test   %eax,%eax
  802170:	78 55                	js     8021c7 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802172:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802178:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80217b:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80217d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802180:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802187:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80218d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802190:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802192:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802195:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80219c:	83 ec 0c             	sub    $0xc,%esp
  80219f:	ff 75 f4             	pushl  -0xc(%ebp)
  8021a2:	e8 95 f0 ff ff       	call   80123c <fd2num>
  8021a7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021aa:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8021ac:	83 c4 04             	add    $0x4,%esp
  8021af:	ff 75 f0             	pushl  -0x10(%ebp)
  8021b2:	e8 85 f0 ff ff       	call   80123c <fd2num>
  8021b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021ba:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8021bd:	83 c4 10             	add    $0x10,%esp
  8021c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8021c5:	eb 30                	jmp    8021f7 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8021c7:	83 ec 08             	sub    $0x8,%esp
  8021ca:	56                   	push   %esi
  8021cb:	6a 00                	push   $0x0
  8021cd:	e8 40 eb ff ff       	call   800d12 <sys_page_unmap>
  8021d2:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8021d5:	83 ec 08             	sub    $0x8,%esp
  8021d8:	ff 75 f0             	pushl  -0x10(%ebp)
  8021db:	6a 00                	push   $0x0
  8021dd:	e8 30 eb ff ff       	call   800d12 <sys_page_unmap>
  8021e2:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8021e5:	83 ec 08             	sub    $0x8,%esp
  8021e8:	ff 75 f4             	pushl  -0xc(%ebp)
  8021eb:	6a 00                	push   $0x0
  8021ed:	e8 20 eb ff ff       	call   800d12 <sys_page_unmap>
  8021f2:	83 c4 10             	add    $0x10,%esp
  8021f5:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8021f7:	89 d0                	mov    %edx,%eax
  8021f9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021fc:	5b                   	pop    %ebx
  8021fd:	5e                   	pop    %esi
  8021fe:	5d                   	pop    %ebp
  8021ff:	c3                   	ret    

00802200 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802200:	55                   	push   %ebp
  802201:	89 e5                	mov    %esp,%ebp
  802203:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802206:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802209:	50                   	push   %eax
  80220a:	ff 75 08             	pushl  0x8(%ebp)
  80220d:	e8 a0 f0 ff ff       	call   8012b2 <fd_lookup>
  802212:	83 c4 10             	add    $0x10,%esp
  802215:	85 c0                	test   %eax,%eax
  802217:	78 18                	js     802231 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802219:	83 ec 0c             	sub    $0xc,%esp
  80221c:	ff 75 f4             	pushl  -0xc(%ebp)
  80221f:	e8 28 f0 ff ff       	call   80124c <fd2data>
	return _pipeisclosed(fd, p);
  802224:	89 c2                	mov    %eax,%edx
  802226:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802229:	e8 21 fd ff ff       	call   801f4f <_pipeisclosed>
  80222e:	83 c4 10             	add    $0x10,%esp
}
  802231:	c9                   	leave  
  802232:	c3                   	ret    

00802233 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802233:	55                   	push   %ebp
  802234:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802236:	b8 00 00 00 00       	mov    $0x0,%eax
  80223b:	5d                   	pop    %ebp
  80223c:	c3                   	ret    

0080223d <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80223d:	55                   	push   %ebp
  80223e:	89 e5                	mov    %esp,%ebp
  802240:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802243:	68 db 2c 80 00       	push   $0x802cdb
  802248:	ff 75 0c             	pushl  0xc(%ebp)
  80224b:	e8 3a e6 ff ff       	call   80088a <strcpy>
	return 0;
}
  802250:	b8 00 00 00 00       	mov    $0x0,%eax
  802255:	c9                   	leave  
  802256:	c3                   	ret    

00802257 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802257:	55                   	push   %ebp
  802258:	89 e5                	mov    %esp,%ebp
  80225a:	57                   	push   %edi
  80225b:	56                   	push   %esi
  80225c:	53                   	push   %ebx
  80225d:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802263:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802268:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80226e:	eb 2d                	jmp    80229d <devcons_write+0x46>
		m = n - tot;
  802270:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802273:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802275:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802278:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80227d:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802280:	83 ec 04             	sub    $0x4,%esp
  802283:	53                   	push   %ebx
  802284:	03 45 0c             	add    0xc(%ebp),%eax
  802287:	50                   	push   %eax
  802288:	57                   	push   %edi
  802289:	e8 8e e7 ff ff       	call   800a1c <memmove>
		sys_cputs(buf, m);
  80228e:	83 c4 08             	add    $0x8,%esp
  802291:	53                   	push   %ebx
  802292:	57                   	push   %edi
  802293:	e8 39 e9 ff ff       	call   800bd1 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802298:	01 de                	add    %ebx,%esi
  80229a:	83 c4 10             	add    $0x10,%esp
  80229d:	89 f0                	mov    %esi,%eax
  80229f:	3b 75 10             	cmp    0x10(%ebp),%esi
  8022a2:	72 cc                	jb     802270 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8022a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022a7:	5b                   	pop    %ebx
  8022a8:	5e                   	pop    %esi
  8022a9:	5f                   	pop    %edi
  8022aa:	5d                   	pop    %ebp
  8022ab:	c3                   	ret    

008022ac <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8022ac:	55                   	push   %ebp
  8022ad:	89 e5                	mov    %esp,%ebp
  8022af:	83 ec 08             	sub    $0x8,%esp
  8022b2:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8022b7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8022bb:	74 2a                	je     8022e7 <devcons_read+0x3b>
  8022bd:	eb 05                	jmp    8022c4 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8022bf:	e8 aa e9 ff ff       	call   800c6e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8022c4:	e8 26 e9 ff ff       	call   800bef <sys_cgetc>
  8022c9:	85 c0                	test   %eax,%eax
  8022cb:	74 f2                	je     8022bf <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8022cd:	85 c0                	test   %eax,%eax
  8022cf:	78 16                	js     8022e7 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8022d1:	83 f8 04             	cmp    $0x4,%eax
  8022d4:	74 0c                	je     8022e2 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8022d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8022d9:	88 02                	mov    %al,(%edx)
	return 1;
  8022db:	b8 01 00 00 00       	mov    $0x1,%eax
  8022e0:	eb 05                	jmp    8022e7 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8022e2:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8022e7:	c9                   	leave  
  8022e8:	c3                   	ret    

008022e9 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8022e9:	55                   	push   %ebp
  8022ea:	89 e5                	mov    %esp,%ebp
  8022ec:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8022ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8022f2:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8022f5:	6a 01                	push   $0x1
  8022f7:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8022fa:	50                   	push   %eax
  8022fb:	e8 d1 e8 ff ff       	call   800bd1 <sys_cputs>
}
  802300:	83 c4 10             	add    $0x10,%esp
  802303:	c9                   	leave  
  802304:	c3                   	ret    

00802305 <getchar>:

int
getchar(void)
{
  802305:	55                   	push   %ebp
  802306:	89 e5                	mov    %esp,%ebp
  802308:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80230b:	6a 01                	push   $0x1
  80230d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802310:	50                   	push   %eax
  802311:	6a 00                	push   $0x0
  802313:	e8 00 f2 ff ff       	call   801518 <read>
	if (r < 0)
  802318:	83 c4 10             	add    $0x10,%esp
  80231b:	85 c0                	test   %eax,%eax
  80231d:	78 0f                	js     80232e <getchar+0x29>
		return r;
	if (r < 1)
  80231f:	85 c0                	test   %eax,%eax
  802321:	7e 06                	jle    802329 <getchar+0x24>
		return -E_EOF;
	return c;
  802323:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802327:	eb 05                	jmp    80232e <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802329:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80232e:	c9                   	leave  
  80232f:	c3                   	ret    

00802330 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802330:	55                   	push   %ebp
  802331:	89 e5                	mov    %esp,%ebp
  802333:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802336:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802339:	50                   	push   %eax
  80233a:	ff 75 08             	pushl  0x8(%ebp)
  80233d:	e8 70 ef ff ff       	call   8012b2 <fd_lookup>
  802342:	83 c4 10             	add    $0x10,%esp
  802345:	85 c0                	test   %eax,%eax
  802347:	78 11                	js     80235a <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802349:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80234c:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802352:	39 10                	cmp    %edx,(%eax)
  802354:	0f 94 c0             	sete   %al
  802357:	0f b6 c0             	movzbl %al,%eax
}
  80235a:	c9                   	leave  
  80235b:	c3                   	ret    

0080235c <opencons>:

int
opencons(void)
{
  80235c:	55                   	push   %ebp
  80235d:	89 e5                	mov    %esp,%ebp
  80235f:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802362:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802365:	50                   	push   %eax
  802366:	e8 f8 ee ff ff       	call   801263 <fd_alloc>
  80236b:	83 c4 10             	add    $0x10,%esp
		return r;
  80236e:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802370:	85 c0                	test   %eax,%eax
  802372:	78 3e                	js     8023b2 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802374:	83 ec 04             	sub    $0x4,%esp
  802377:	68 07 04 00 00       	push   $0x407
  80237c:	ff 75 f4             	pushl  -0xc(%ebp)
  80237f:	6a 00                	push   $0x0
  802381:	e8 07 e9 ff ff       	call   800c8d <sys_page_alloc>
  802386:	83 c4 10             	add    $0x10,%esp
		return r;
  802389:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80238b:	85 c0                	test   %eax,%eax
  80238d:	78 23                	js     8023b2 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80238f:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802395:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802398:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80239a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80239d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8023a4:	83 ec 0c             	sub    $0xc,%esp
  8023a7:	50                   	push   %eax
  8023a8:	e8 8f ee ff ff       	call   80123c <fd2num>
  8023ad:	89 c2                	mov    %eax,%edx
  8023af:	83 c4 10             	add    $0x10,%esp
}
  8023b2:	89 d0                	mov    %edx,%eax
  8023b4:	c9                   	leave  
  8023b5:	c3                   	ret    

008023b6 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8023b6:	55                   	push   %ebp
  8023b7:	89 e5                	mov    %esp,%ebp
  8023b9:	53                   	push   %ebx
  8023ba:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  8023bd:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8023c4:	75 28                	jne    8023ee <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  8023c6:	e8 84 e8 ff ff       	call   800c4f <sys_getenvid>
  8023cb:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_U | PTE_W);
  8023cd:	83 ec 04             	sub    $0x4,%esp
  8023d0:	6a 06                	push   $0x6
  8023d2:	68 00 f0 bf ee       	push   $0xeebff000
  8023d7:	50                   	push   %eax
  8023d8:	e8 b0 e8 ff ff       	call   800c8d <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  8023dd:	83 c4 08             	add    $0x8,%esp
  8023e0:	68 fb 23 80 00       	push   $0x8023fb
  8023e5:	53                   	push   %ebx
  8023e6:	e8 ed e9 ff ff       	call   800dd8 <sys_env_set_pgfault_upcall>
  8023eb:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8023ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8023f1:	a3 00 70 80 00       	mov    %eax,0x807000
}
  8023f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8023f9:	c9                   	leave  
  8023fa:	c3                   	ret    

008023fb <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8023fb:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8023fc:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802401:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802403:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	# My method is different. Copy the values to the other stack
	# in a convinient way, and then pop everything.
	movl %esp, %ebp		# ebp refers to the exception stack
  802406:	89 e5                	mov    %esp,%ebp
	movl 48(%ebp), %esp 	# go to other stack
  802408:	8b 65 30             	mov    0x30(%ebp),%esp

	pushl 40(%ebp)		# eip - ORDER SWITCHED WITH EFLAGS
  80240b:	ff 75 28             	pushl  0x28(%ebp)
	pushl 44(%ebp)      	# eflags
  80240e:	ff 75 2c             	pushl  0x2c(%ebp)
	pushl 36(%ebp)		# all the 8 remaining regs
  802411:	ff 75 24             	pushl  0x24(%ebp)
	pushl 32(%ebp)
  802414:	ff 75 20             	pushl  0x20(%ebp)
	pushl 28(%ebp)
  802417:	ff 75 1c             	pushl  0x1c(%ebp)
	pushl 24(%ebp)
  80241a:	ff 75 18             	pushl  0x18(%ebp)
	pushl 20(%ebp)
  80241d:	ff 75 14             	pushl  0x14(%ebp)
	pushl 16(%ebp)
  802420:	ff 75 10             	pushl  0x10(%ebp)
	pushl 12(%ebp)
  802423:	ff 75 0c             	pushl  0xc(%ebp)
	pushl 8(%ebp)
  802426:	ff 75 08             	pushl  0x8(%ebp)

	popal			# now just pop everything!
  802429:	61                   	popa   
	popfl
  80242a:	9d                   	popf   
	ret
  80242b:	c3                   	ret    

0080242c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80242c:	55                   	push   %ebp
  80242d:	89 e5                	mov    %esp,%ebp
  80242f:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802432:	89 d0                	mov    %edx,%eax
  802434:	c1 e8 16             	shr    $0x16,%eax
  802437:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80243e:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802443:	f6 c1 01             	test   $0x1,%cl
  802446:	74 1d                	je     802465 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802448:	c1 ea 0c             	shr    $0xc,%edx
  80244b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802452:	f6 c2 01             	test   $0x1,%dl
  802455:	74 0e                	je     802465 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802457:	c1 ea 0c             	shr    $0xc,%edx
  80245a:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802461:	ef 
  802462:	0f b7 c0             	movzwl %ax,%eax
}
  802465:	5d                   	pop    %ebp
  802466:	c3                   	ret    
  802467:	66 90                	xchg   %ax,%ax
  802469:	66 90                	xchg   %ax,%ax
  80246b:	66 90                	xchg   %ax,%ax
  80246d:	66 90                	xchg   %ax,%ax
  80246f:	90                   	nop

00802470 <__udivdi3>:
  802470:	55                   	push   %ebp
  802471:	57                   	push   %edi
  802472:	56                   	push   %esi
  802473:	53                   	push   %ebx
  802474:	83 ec 1c             	sub    $0x1c,%esp
  802477:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80247b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80247f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802483:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802487:	85 f6                	test   %esi,%esi
  802489:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80248d:	89 ca                	mov    %ecx,%edx
  80248f:	89 f8                	mov    %edi,%eax
  802491:	75 3d                	jne    8024d0 <__udivdi3+0x60>
  802493:	39 cf                	cmp    %ecx,%edi
  802495:	0f 87 c5 00 00 00    	ja     802560 <__udivdi3+0xf0>
  80249b:	85 ff                	test   %edi,%edi
  80249d:	89 fd                	mov    %edi,%ebp
  80249f:	75 0b                	jne    8024ac <__udivdi3+0x3c>
  8024a1:	b8 01 00 00 00       	mov    $0x1,%eax
  8024a6:	31 d2                	xor    %edx,%edx
  8024a8:	f7 f7                	div    %edi
  8024aa:	89 c5                	mov    %eax,%ebp
  8024ac:	89 c8                	mov    %ecx,%eax
  8024ae:	31 d2                	xor    %edx,%edx
  8024b0:	f7 f5                	div    %ebp
  8024b2:	89 c1                	mov    %eax,%ecx
  8024b4:	89 d8                	mov    %ebx,%eax
  8024b6:	89 cf                	mov    %ecx,%edi
  8024b8:	f7 f5                	div    %ebp
  8024ba:	89 c3                	mov    %eax,%ebx
  8024bc:	89 d8                	mov    %ebx,%eax
  8024be:	89 fa                	mov    %edi,%edx
  8024c0:	83 c4 1c             	add    $0x1c,%esp
  8024c3:	5b                   	pop    %ebx
  8024c4:	5e                   	pop    %esi
  8024c5:	5f                   	pop    %edi
  8024c6:	5d                   	pop    %ebp
  8024c7:	c3                   	ret    
  8024c8:	90                   	nop
  8024c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024d0:	39 ce                	cmp    %ecx,%esi
  8024d2:	77 74                	ja     802548 <__udivdi3+0xd8>
  8024d4:	0f bd fe             	bsr    %esi,%edi
  8024d7:	83 f7 1f             	xor    $0x1f,%edi
  8024da:	0f 84 98 00 00 00    	je     802578 <__udivdi3+0x108>
  8024e0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8024e5:	89 f9                	mov    %edi,%ecx
  8024e7:	89 c5                	mov    %eax,%ebp
  8024e9:	29 fb                	sub    %edi,%ebx
  8024eb:	d3 e6                	shl    %cl,%esi
  8024ed:	89 d9                	mov    %ebx,%ecx
  8024ef:	d3 ed                	shr    %cl,%ebp
  8024f1:	89 f9                	mov    %edi,%ecx
  8024f3:	d3 e0                	shl    %cl,%eax
  8024f5:	09 ee                	or     %ebp,%esi
  8024f7:	89 d9                	mov    %ebx,%ecx
  8024f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024fd:	89 d5                	mov    %edx,%ebp
  8024ff:	8b 44 24 08          	mov    0x8(%esp),%eax
  802503:	d3 ed                	shr    %cl,%ebp
  802505:	89 f9                	mov    %edi,%ecx
  802507:	d3 e2                	shl    %cl,%edx
  802509:	89 d9                	mov    %ebx,%ecx
  80250b:	d3 e8                	shr    %cl,%eax
  80250d:	09 c2                	or     %eax,%edx
  80250f:	89 d0                	mov    %edx,%eax
  802511:	89 ea                	mov    %ebp,%edx
  802513:	f7 f6                	div    %esi
  802515:	89 d5                	mov    %edx,%ebp
  802517:	89 c3                	mov    %eax,%ebx
  802519:	f7 64 24 0c          	mull   0xc(%esp)
  80251d:	39 d5                	cmp    %edx,%ebp
  80251f:	72 10                	jb     802531 <__udivdi3+0xc1>
  802521:	8b 74 24 08          	mov    0x8(%esp),%esi
  802525:	89 f9                	mov    %edi,%ecx
  802527:	d3 e6                	shl    %cl,%esi
  802529:	39 c6                	cmp    %eax,%esi
  80252b:	73 07                	jae    802534 <__udivdi3+0xc4>
  80252d:	39 d5                	cmp    %edx,%ebp
  80252f:	75 03                	jne    802534 <__udivdi3+0xc4>
  802531:	83 eb 01             	sub    $0x1,%ebx
  802534:	31 ff                	xor    %edi,%edi
  802536:	89 d8                	mov    %ebx,%eax
  802538:	89 fa                	mov    %edi,%edx
  80253a:	83 c4 1c             	add    $0x1c,%esp
  80253d:	5b                   	pop    %ebx
  80253e:	5e                   	pop    %esi
  80253f:	5f                   	pop    %edi
  802540:	5d                   	pop    %ebp
  802541:	c3                   	ret    
  802542:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802548:	31 ff                	xor    %edi,%edi
  80254a:	31 db                	xor    %ebx,%ebx
  80254c:	89 d8                	mov    %ebx,%eax
  80254e:	89 fa                	mov    %edi,%edx
  802550:	83 c4 1c             	add    $0x1c,%esp
  802553:	5b                   	pop    %ebx
  802554:	5e                   	pop    %esi
  802555:	5f                   	pop    %edi
  802556:	5d                   	pop    %ebp
  802557:	c3                   	ret    
  802558:	90                   	nop
  802559:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802560:	89 d8                	mov    %ebx,%eax
  802562:	f7 f7                	div    %edi
  802564:	31 ff                	xor    %edi,%edi
  802566:	89 c3                	mov    %eax,%ebx
  802568:	89 d8                	mov    %ebx,%eax
  80256a:	89 fa                	mov    %edi,%edx
  80256c:	83 c4 1c             	add    $0x1c,%esp
  80256f:	5b                   	pop    %ebx
  802570:	5e                   	pop    %esi
  802571:	5f                   	pop    %edi
  802572:	5d                   	pop    %ebp
  802573:	c3                   	ret    
  802574:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802578:	39 ce                	cmp    %ecx,%esi
  80257a:	72 0c                	jb     802588 <__udivdi3+0x118>
  80257c:	31 db                	xor    %ebx,%ebx
  80257e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802582:	0f 87 34 ff ff ff    	ja     8024bc <__udivdi3+0x4c>
  802588:	bb 01 00 00 00       	mov    $0x1,%ebx
  80258d:	e9 2a ff ff ff       	jmp    8024bc <__udivdi3+0x4c>
  802592:	66 90                	xchg   %ax,%ax
  802594:	66 90                	xchg   %ax,%ax
  802596:	66 90                	xchg   %ax,%ax
  802598:	66 90                	xchg   %ax,%ax
  80259a:	66 90                	xchg   %ax,%ax
  80259c:	66 90                	xchg   %ax,%ax
  80259e:	66 90                	xchg   %ax,%ax

008025a0 <__umoddi3>:
  8025a0:	55                   	push   %ebp
  8025a1:	57                   	push   %edi
  8025a2:	56                   	push   %esi
  8025a3:	53                   	push   %ebx
  8025a4:	83 ec 1c             	sub    $0x1c,%esp
  8025a7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8025ab:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8025af:	8b 74 24 34          	mov    0x34(%esp),%esi
  8025b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8025b7:	85 d2                	test   %edx,%edx
  8025b9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8025bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8025c1:	89 f3                	mov    %esi,%ebx
  8025c3:	89 3c 24             	mov    %edi,(%esp)
  8025c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8025ca:	75 1c                	jne    8025e8 <__umoddi3+0x48>
  8025cc:	39 f7                	cmp    %esi,%edi
  8025ce:	76 50                	jbe    802620 <__umoddi3+0x80>
  8025d0:	89 c8                	mov    %ecx,%eax
  8025d2:	89 f2                	mov    %esi,%edx
  8025d4:	f7 f7                	div    %edi
  8025d6:	89 d0                	mov    %edx,%eax
  8025d8:	31 d2                	xor    %edx,%edx
  8025da:	83 c4 1c             	add    $0x1c,%esp
  8025dd:	5b                   	pop    %ebx
  8025de:	5e                   	pop    %esi
  8025df:	5f                   	pop    %edi
  8025e0:	5d                   	pop    %ebp
  8025e1:	c3                   	ret    
  8025e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8025e8:	39 f2                	cmp    %esi,%edx
  8025ea:	89 d0                	mov    %edx,%eax
  8025ec:	77 52                	ja     802640 <__umoddi3+0xa0>
  8025ee:	0f bd ea             	bsr    %edx,%ebp
  8025f1:	83 f5 1f             	xor    $0x1f,%ebp
  8025f4:	75 5a                	jne    802650 <__umoddi3+0xb0>
  8025f6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8025fa:	0f 82 e0 00 00 00    	jb     8026e0 <__umoddi3+0x140>
  802600:	39 0c 24             	cmp    %ecx,(%esp)
  802603:	0f 86 d7 00 00 00    	jbe    8026e0 <__umoddi3+0x140>
  802609:	8b 44 24 08          	mov    0x8(%esp),%eax
  80260d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802611:	83 c4 1c             	add    $0x1c,%esp
  802614:	5b                   	pop    %ebx
  802615:	5e                   	pop    %esi
  802616:	5f                   	pop    %edi
  802617:	5d                   	pop    %ebp
  802618:	c3                   	ret    
  802619:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802620:	85 ff                	test   %edi,%edi
  802622:	89 fd                	mov    %edi,%ebp
  802624:	75 0b                	jne    802631 <__umoddi3+0x91>
  802626:	b8 01 00 00 00       	mov    $0x1,%eax
  80262b:	31 d2                	xor    %edx,%edx
  80262d:	f7 f7                	div    %edi
  80262f:	89 c5                	mov    %eax,%ebp
  802631:	89 f0                	mov    %esi,%eax
  802633:	31 d2                	xor    %edx,%edx
  802635:	f7 f5                	div    %ebp
  802637:	89 c8                	mov    %ecx,%eax
  802639:	f7 f5                	div    %ebp
  80263b:	89 d0                	mov    %edx,%eax
  80263d:	eb 99                	jmp    8025d8 <__umoddi3+0x38>
  80263f:	90                   	nop
  802640:	89 c8                	mov    %ecx,%eax
  802642:	89 f2                	mov    %esi,%edx
  802644:	83 c4 1c             	add    $0x1c,%esp
  802647:	5b                   	pop    %ebx
  802648:	5e                   	pop    %esi
  802649:	5f                   	pop    %edi
  80264a:	5d                   	pop    %ebp
  80264b:	c3                   	ret    
  80264c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802650:	8b 34 24             	mov    (%esp),%esi
  802653:	bf 20 00 00 00       	mov    $0x20,%edi
  802658:	89 e9                	mov    %ebp,%ecx
  80265a:	29 ef                	sub    %ebp,%edi
  80265c:	d3 e0                	shl    %cl,%eax
  80265e:	89 f9                	mov    %edi,%ecx
  802660:	89 f2                	mov    %esi,%edx
  802662:	d3 ea                	shr    %cl,%edx
  802664:	89 e9                	mov    %ebp,%ecx
  802666:	09 c2                	or     %eax,%edx
  802668:	89 d8                	mov    %ebx,%eax
  80266a:	89 14 24             	mov    %edx,(%esp)
  80266d:	89 f2                	mov    %esi,%edx
  80266f:	d3 e2                	shl    %cl,%edx
  802671:	89 f9                	mov    %edi,%ecx
  802673:	89 54 24 04          	mov    %edx,0x4(%esp)
  802677:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80267b:	d3 e8                	shr    %cl,%eax
  80267d:	89 e9                	mov    %ebp,%ecx
  80267f:	89 c6                	mov    %eax,%esi
  802681:	d3 e3                	shl    %cl,%ebx
  802683:	89 f9                	mov    %edi,%ecx
  802685:	89 d0                	mov    %edx,%eax
  802687:	d3 e8                	shr    %cl,%eax
  802689:	89 e9                	mov    %ebp,%ecx
  80268b:	09 d8                	or     %ebx,%eax
  80268d:	89 d3                	mov    %edx,%ebx
  80268f:	89 f2                	mov    %esi,%edx
  802691:	f7 34 24             	divl   (%esp)
  802694:	89 d6                	mov    %edx,%esi
  802696:	d3 e3                	shl    %cl,%ebx
  802698:	f7 64 24 04          	mull   0x4(%esp)
  80269c:	39 d6                	cmp    %edx,%esi
  80269e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8026a2:	89 d1                	mov    %edx,%ecx
  8026a4:	89 c3                	mov    %eax,%ebx
  8026a6:	72 08                	jb     8026b0 <__umoddi3+0x110>
  8026a8:	75 11                	jne    8026bb <__umoddi3+0x11b>
  8026aa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8026ae:	73 0b                	jae    8026bb <__umoddi3+0x11b>
  8026b0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8026b4:	1b 14 24             	sbb    (%esp),%edx
  8026b7:	89 d1                	mov    %edx,%ecx
  8026b9:	89 c3                	mov    %eax,%ebx
  8026bb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8026bf:	29 da                	sub    %ebx,%edx
  8026c1:	19 ce                	sbb    %ecx,%esi
  8026c3:	89 f9                	mov    %edi,%ecx
  8026c5:	89 f0                	mov    %esi,%eax
  8026c7:	d3 e0                	shl    %cl,%eax
  8026c9:	89 e9                	mov    %ebp,%ecx
  8026cb:	d3 ea                	shr    %cl,%edx
  8026cd:	89 e9                	mov    %ebp,%ecx
  8026cf:	d3 ee                	shr    %cl,%esi
  8026d1:	09 d0                	or     %edx,%eax
  8026d3:	89 f2                	mov    %esi,%edx
  8026d5:	83 c4 1c             	add    $0x1c,%esp
  8026d8:	5b                   	pop    %ebx
  8026d9:	5e                   	pop    %esi
  8026da:	5f                   	pop    %edi
  8026db:	5d                   	pop    %ebp
  8026dc:	c3                   	ret    
  8026dd:	8d 76 00             	lea    0x0(%esi),%esi
  8026e0:	29 f9                	sub    %edi,%ecx
  8026e2:	19 d6                	sbb    %edx,%esi
  8026e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8026e8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8026ec:	e9 18 ff ff ff       	jmp    802609 <__umoddi3+0x69>
