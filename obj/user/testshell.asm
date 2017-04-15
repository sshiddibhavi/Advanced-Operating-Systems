
obj/user/testshell.debug:     file format elf32-i386


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
  80002c:	e8 53 04 00 00       	call   800484 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <wrong>:
	breakpoint();
}

void
wrong(int rfd, int kfd, int off)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	81 ec 84 00 00 00    	sub    $0x84,%esp
  80003f:	8b 75 08             	mov    0x8(%ebp),%esi
  800042:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800045:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char buf[100];
	int n;

	seek(rfd, off);
  800048:	53                   	push   %ebx
  800049:	56                   	push   %esi
  80004a:	e8 d2 17 00 00       	call   801821 <seek>
	seek(kfd, off);
  80004f:	83 c4 08             	add    $0x8,%esp
  800052:	53                   	push   %ebx
  800053:	57                   	push   %edi
  800054:	e8 c8 17 00 00       	call   801821 <seek>

	cprintf("shell produced incorrect output.\n");
  800059:	c7 04 24 c0 29 80 00 	movl   $0x8029c0,(%esp)
  800060:	e8 58 05 00 00       	call   8005bd <cprintf>
	cprintf("expected:\n===\n");
  800065:	c7 04 24 2b 2a 80 00 	movl   $0x802a2b,(%esp)
  80006c:	e8 4c 05 00 00       	call   8005bd <cprintf>
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  800071:	83 c4 10             	add    $0x10,%esp
  800074:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  800077:	eb 0d                	jmp    800086 <wrong+0x53>
		sys_cputs(buf, n);
  800079:	83 ec 08             	sub    $0x8,%esp
  80007c:	50                   	push   %eax
  80007d:	53                   	push   %ebx
  80007e:	e8 06 0e 00 00       	call   800e89 <sys_cputs>
  800083:	83 c4 10             	add    $0x10,%esp
	seek(rfd, off);
	seek(kfd, off);

	cprintf("shell produced incorrect output.\n");
	cprintf("expected:\n===\n");
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  800086:	83 ec 04             	sub    $0x4,%esp
  800089:	6a 63                	push   $0x63
  80008b:	53                   	push   %ebx
  80008c:	57                   	push   %edi
  80008d:	e8 29 16 00 00       	call   8016bb <read>
  800092:	83 c4 10             	add    $0x10,%esp
  800095:	85 c0                	test   %eax,%eax
  800097:	7f e0                	jg     800079 <wrong+0x46>
		sys_cputs(buf, n);
	cprintf("===\ngot:\n===\n");
  800099:	83 ec 0c             	sub    $0xc,%esp
  80009c:	68 3a 2a 80 00       	push   $0x802a3a
  8000a1:	e8 17 05 00 00       	call   8005bd <cprintf>
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000a6:	83 c4 10             	add    $0x10,%esp
  8000a9:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  8000ac:	eb 0d                	jmp    8000bb <wrong+0x88>
		sys_cputs(buf, n);
  8000ae:	83 ec 08             	sub    $0x8,%esp
  8000b1:	50                   	push   %eax
  8000b2:	53                   	push   %ebx
  8000b3:	e8 d1 0d 00 00       	call   800e89 <sys_cputs>
  8000b8:	83 c4 10             	add    $0x10,%esp
	cprintf("shell produced incorrect output.\n");
	cprintf("expected:\n===\n");
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
		sys_cputs(buf, n);
	cprintf("===\ngot:\n===\n");
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000bb:	83 ec 04             	sub    $0x4,%esp
  8000be:	6a 63                	push   $0x63
  8000c0:	53                   	push   %ebx
  8000c1:	56                   	push   %esi
  8000c2:	e8 f4 15 00 00       	call   8016bb <read>
  8000c7:	83 c4 10             	add    $0x10,%esp
  8000ca:	85 c0                	test   %eax,%eax
  8000cc:	7f e0                	jg     8000ae <wrong+0x7b>
		sys_cputs(buf, n);
	cprintf("===\n");
  8000ce:	83 ec 0c             	sub    $0xc,%esp
  8000d1:	68 35 2a 80 00       	push   $0x802a35
  8000d6:	e8 e2 04 00 00       	call   8005bd <cprintf>
	exit();
  8000db:	e8 ea 03 00 00       	call   8004ca <exit>
}
  8000e0:	83 c4 10             	add    $0x10,%esp
  8000e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000e6:	5b                   	pop    %ebx
  8000e7:	5e                   	pop    %esi
  8000e8:	5f                   	pop    %edi
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    

008000eb <umain>:

void wrong(int, int, int);

void
umain(int argc, char **argv)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	57                   	push   %edi
  8000ef:	56                   	push   %esi
  8000f0:	53                   	push   %ebx
  8000f1:	83 ec 38             	sub    $0x38,%esp
	char c1, c2;
	int r, rfd, wfd, kfd, n1, n2, off, nloff;
	int pfds[2];

	close(0);
  8000f4:	6a 00                	push   $0x0
  8000f6:	e8 84 14 00 00       	call   80157f <close>
	close(1);
  8000fb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800102:	e8 78 14 00 00       	call   80157f <close>
	opencons();
  800107:	e8 1e 03 00 00       	call   80042a <opencons>
	opencons();
  80010c:	e8 19 03 00 00       	call   80042a <opencons>

	if ((rfd = open("testshell.sh", O_RDONLY)) < 0)
  800111:	83 c4 08             	add    $0x8,%esp
  800114:	6a 00                	push   $0x0
  800116:	68 48 2a 80 00       	push   $0x802a48
  80011b:	e8 4f 1a 00 00       	call   801b6f <open>
  800120:	89 c3                	mov    %eax,%ebx
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	85 c0                	test   %eax,%eax
  800127:	79 12                	jns    80013b <umain+0x50>
		panic("open testshell.sh: %e", rfd);
  800129:	50                   	push   %eax
  80012a:	68 55 2a 80 00       	push   $0x802a55
  80012f:	6a 13                	push   $0x13
  800131:	68 6b 2a 80 00       	push   $0x802a6b
  800136:	e8 a9 03 00 00       	call   8004e4 <_panic>
	if ((wfd = pipe(pfds)) < 0)
  80013b:	83 ec 0c             	sub    $0xc,%esp
  80013e:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800141:	50                   	push   %eax
  800142:	e8 56 22 00 00       	call   80239d <pipe>
  800147:	83 c4 10             	add    $0x10,%esp
  80014a:	85 c0                	test   %eax,%eax
  80014c:	79 12                	jns    800160 <umain+0x75>
		panic("pipe: %e", wfd);
  80014e:	50                   	push   %eax
  80014f:	68 7c 2a 80 00       	push   $0x802a7c
  800154:	6a 15                	push   $0x15
  800156:	68 6b 2a 80 00       	push   $0x802a6b
  80015b:	e8 84 03 00 00       	call   8004e4 <_panic>
	wfd = pfds[1];
  800160:	8b 75 e0             	mov    -0x20(%ebp),%esi

	cprintf("running sh -x < testshell.sh | cat\n");
  800163:	83 ec 0c             	sub    $0xc,%esp
  800166:	68 e4 29 80 00       	push   $0x8029e4
  80016b:	e8 4d 04 00 00       	call   8005bd <cprintf>
	if ((r = fork()) < 0)
  800170:	e8 75 11 00 00       	call   8012ea <fork>
  800175:	83 c4 10             	add    $0x10,%esp
  800178:	85 c0                	test   %eax,%eax
  80017a:	79 12                	jns    80018e <umain+0xa3>
		panic("fork: %e", r);
  80017c:	50                   	push   %eax
  80017d:	68 93 2e 80 00       	push   $0x802e93
  800182:	6a 1a                	push   $0x1a
  800184:	68 6b 2a 80 00       	push   $0x802a6b
  800189:	e8 56 03 00 00       	call   8004e4 <_panic>
	if (r == 0) {
  80018e:	85 c0                	test   %eax,%eax
  800190:	75 7d                	jne    80020f <umain+0x124>
		dup(rfd, 0);
  800192:	83 ec 08             	sub    $0x8,%esp
  800195:	6a 00                	push   $0x0
  800197:	53                   	push   %ebx
  800198:	e8 32 14 00 00       	call   8015cf <dup>
		dup(wfd, 1);
  80019d:	83 c4 08             	add    $0x8,%esp
  8001a0:	6a 01                	push   $0x1
  8001a2:	56                   	push   %esi
  8001a3:	e8 27 14 00 00       	call   8015cf <dup>
		close(rfd);
  8001a8:	89 1c 24             	mov    %ebx,(%esp)
  8001ab:	e8 cf 13 00 00       	call   80157f <close>
		close(wfd);
  8001b0:	89 34 24             	mov    %esi,(%esp)
  8001b3:	e8 c7 13 00 00       	call   80157f <close>
		if ((r = spawnl("/sh", "sh", "-x", 0)) < 0)
  8001b8:	6a 00                	push   $0x0
  8001ba:	68 85 2a 80 00       	push   $0x802a85
  8001bf:	68 52 2a 80 00       	push   $0x802a52
  8001c4:	68 88 2a 80 00       	push   $0x802a88
  8001c9:	e8 86 1f 00 00       	call   802154 <spawnl>
  8001ce:	89 c7                	mov    %eax,%edi
  8001d0:	83 c4 20             	add    $0x20,%esp
  8001d3:	85 c0                	test   %eax,%eax
  8001d5:	79 12                	jns    8001e9 <umain+0xfe>
			panic("spawn: %e", r);
  8001d7:	50                   	push   %eax
  8001d8:	68 8c 2a 80 00       	push   $0x802a8c
  8001dd:	6a 21                	push   $0x21
  8001df:	68 6b 2a 80 00       	push   $0x802a6b
  8001e4:	e8 fb 02 00 00       	call   8004e4 <_panic>
		close(0);
  8001e9:	83 ec 0c             	sub    $0xc,%esp
  8001ec:	6a 00                	push   $0x0
  8001ee:	e8 8c 13 00 00       	call   80157f <close>
		close(1);
  8001f3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8001fa:	e8 80 13 00 00       	call   80157f <close>
		wait(r);
  8001ff:	89 3c 24             	mov    %edi,(%esp)
  800202:	e8 1c 23 00 00       	call   802523 <wait>
		exit();
  800207:	e8 be 02 00 00       	call   8004ca <exit>
  80020c:	83 c4 10             	add    $0x10,%esp
	}
	close(rfd);
  80020f:	83 ec 0c             	sub    $0xc,%esp
  800212:	53                   	push   %ebx
  800213:	e8 67 13 00 00       	call   80157f <close>
	close(wfd);
  800218:	89 34 24             	mov    %esi,(%esp)
  80021b:	e8 5f 13 00 00       	call   80157f <close>

	rfd = pfds[0];
  800220:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800223:	89 45 d0             	mov    %eax,-0x30(%ebp)
	if ((kfd = open("testshell.key", O_RDONLY)) < 0)
  800226:	83 c4 08             	add    $0x8,%esp
  800229:	6a 00                	push   $0x0
  80022b:	68 96 2a 80 00       	push   $0x802a96
  800230:	e8 3a 19 00 00       	call   801b6f <open>
  800235:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800238:	83 c4 10             	add    $0x10,%esp
  80023b:	85 c0                	test   %eax,%eax
  80023d:	79 12                	jns    800251 <umain+0x166>
		panic("open testshell.key for reading: %e", kfd);
  80023f:	50                   	push   %eax
  800240:	68 08 2a 80 00       	push   $0x802a08
  800245:	6a 2c                	push   $0x2c
  800247:	68 6b 2a 80 00       	push   $0x802a6b
  80024c:	e8 93 02 00 00       	call   8004e4 <_panic>
  800251:	be 01 00 00 00       	mov    $0x1,%esi
  800256:	bf 00 00 00 00       	mov    $0x0,%edi

	nloff = 0;
	for (off=0;; off++) {
		n1 = read(rfd, &c1, 1);
  80025b:	83 ec 04             	sub    $0x4,%esp
  80025e:	6a 01                	push   $0x1
  800260:	8d 45 e7             	lea    -0x19(%ebp),%eax
  800263:	50                   	push   %eax
  800264:	ff 75 d0             	pushl  -0x30(%ebp)
  800267:	e8 4f 14 00 00       	call   8016bb <read>
  80026c:	89 c3                	mov    %eax,%ebx
		n2 = read(kfd, &c2, 1);
  80026e:	83 c4 0c             	add    $0xc,%esp
  800271:	6a 01                	push   $0x1
  800273:	8d 45 e6             	lea    -0x1a(%ebp),%eax
  800276:	50                   	push   %eax
  800277:	ff 75 d4             	pushl  -0x2c(%ebp)
  80027a:	e8 3c 14 00 00       	call   8016bb <read>
		if (n1 < 0)
  80027f:	83 c4 10             	add    $0x10,%esp
  800282:	85 db                	test   %ebx,%ebx
  800284:	79 12                	jns    800298 <umain+0x1ad>
			panic("reading testshell.out: %e", n1);
  800286:	53                   	push   %ebx
  800287:	68 a4 2a 80 00       	push   $0x802aa4
  80028c:	6a 33                	push   $0x33
  80028e:	68 6b 2a 80 00       	push   $0x802a6b
  800293:	e8 4c 02 00 00       	call   8004e4 <_panic>
		if (n2 < 0)
  800298:	85 c0                	test   %eax,%eax
  80029a:	79 12                	jns    8002ae <umain+0x1c3>
			panic("reading testshell.key: %e", n2);
  80029c:	50                   	push   %eax
  80029d:	68 be 2a 80 00       	push   $0x802abe
  8002a2:	6a 35                	push   $0x35
  8002a4:	68 6b 2a 80 00       	push   $0x802a6b
  8002a9:	e8 36 02 00 00       	call   8004e4 <_panic>
		if (n1 == 0 && n2 == 0)
  8002ae:	89 da                	mov    %ebx,%edx
  8002b0:	09 c2                	or     %eax,%edx
  8002b2:	74 34                	je     8002e8 <umain+0x1fd>
			break;
		if (n1 != 1 || n2 != 1 || c1 != c2)
  8002b4:	83 fb 01             	cmp    $0x1,%ebx
  8002b7:	75 0e                	jne    8002c7 <umain+0x1dc>
  8002b9:	83 f8 01             	cmp    $0x1,%eax
  8002bc:	75 09                	jne    8002c7 <umain+0x1dc>
  8002be:	0f b6 45 e6          	movzbl -0x1a(%ebp),%eax
  8002c2:	38 45 e7             	cmp    %al,-0x19(%ebp)
  8002c5:	74 12                	je     8002d9 <umain+0x1ee>
			wrong(rfd, kfd, nloff);
  8002c7:	83 ec 04             	sub    $0x4,%esp
  8002ca:	57                   	push   %edi
  8002cb:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002ce:	ff 75 d0             	pushl  -0x30(%ebp)
  8002d1:	e8 5d fd ff ff       	call   800033 <wrong>
  8002d6:	83 c4 10             	add    $0x10,%esp
		if (c1 == '\n')
			nloff = off+1;
  8002d9:	80 7d e7 0a          	cmpb   $0xa,-0x19(%ebp)
  8002dd:	0f 44 fe             	cmove  %esi,%edi
  8002e0:	83 c6 01             	add    $0x1,%esi
	}
  8002e3:	e9 73 ff ff ff       	jmp    80025b <umain+0x170>
	cprintf("shell ran correctly\n");
  8002e8:	83 ec 0c             	sub    $0xc,%esp
  8002eb:	68 d8 2a 80 00       	push   $0x802ad8
  8002f0:	e8 c8 02 00 00       	call   8005bd <cprintf>
static __inline uint64_t read_tsc(void) __attribute__((always_inline));

static __inline void
breakpoint(void)
{
	__asm __volatile("int3");
  8002f5:	cc                   	int3   

	breakpoint();
}
  8002f6:	83 c4 10             	add    $0x10,%esp
  8002f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002fc:	5b                   	pop    %ebx
  8002fd:	5e                   	pop    %esi
  8002fe:	5f                   	pop    %edi
  8002ff:	5d                   	pop    %ebp
  800300:	c3                   	ret    

00800301 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800301:	55                   	push   %ebp
  800302:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800304:	b8 00 00 00 00       	mov    $0x0,%eax
  800309:	5d                   	pop    %ebp
  80030a:	c3                   	ret    

0080030b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80030b:	55                   	push   %ebp
  80030c:	89 e5                	mov    %esp,%ebp
  80030e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800311:	68 ed 2a 80 00       	push   $0x802aed
  800316:	ff 75 0c             	pushl  0xc(%ebp)
  800319:	e8 24 08 00 00       	call   800b42 <strcpy>
	return 0;
}
  80031e:	b8 00 00 00 00       	mov    $0x0,%eax
  800323:	c9                   	leave  
  800324:	c3                   	ret    

00800325 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800325:	55                   	push   %ebp
  800326:	89 e5                	mov    %esp,%ebp
  800328:	57                   	push   %edi
  800329:	56                   	push   %esi
  80032a:	53                   	push   %ebx
  80032b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800331:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800336:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80033c:	eb 2d                	jmp    80036b <devcons_write+0x46>
		m = n - tot;
  80033e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800341:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800343:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800346:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80034b:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80034e:	83 ec 04             	sub    $0x4,%esp
  800351:	53                   	push   %ebx
  800352:	03 45 0c             	add    0xc(%ebp),%eax
  800355:	50                   	push   %eax
  800356:	57                   	push   %edi
  800357:	e8 78 09 00 00       	call   800cd4 <memmove>
		sys_cputs(buf, m);
  80035c:	83 c4 08             	add    $0x8,%esp
  80035f:	53                   	push   %ebx
  800360:	57                   	push   %edi
  800361:	e8 23 0b 00 00       	call   800e89 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800366:	01 de                	add    %ebx,%esi
  800368:	83 c4 10             	add    $0x10,%esp
  80036b:	89 f0                	mov    %esi,%eax
  80036d:	3b 75 10             	cmp    0x10(%ebp),%esi
  800370:	72 cc                	jb     80033e <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800372:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800375:	5b                   	pop    %ebx
  800376:	5e                   	pop    %esi
  800377:	5f                   	pop    %edi
  800378:	5d                   	pop    %ebp
  800379:	c3                   	ret    

0080037a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80037a:	55                   	push   %ebp
  80037b:	89 e5                	mov    %esp,%ebp
  80037d:	83 ec 08             	sub    $0x8,%esp
  800380:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800385:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800389:	74 2a                	je     8003b5 <devcons_read+0x3b>
  80038b:	eb 05                	jmp    800392 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80038d:	e8 94 0b 00 00       	call   800f26 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800392:	e8 10 0b 00 00       	call   800ea7 <sys_cgetc>
  800397:	85 c0                	test   %eax,%eax
  800399:	74 f2                	je     80038d <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80039b:	85 c0                	test   %eax,%eax
  80039d:	78 16                	js     8003b5 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80039f:	83 f8 04             	cmp    $0x4,%eax
  8003a2:	74 0c                	je     8003b0 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8003a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003a7:	88 02                	mov    %al,(%edx)
	return 1;
  8003a9:	b8 01 00 00 00       	mov    $0x1,%eax
  8003ae:	eb 05                	jmp    8003b5 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8003b0:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8003b5:	c9                   	leave  
  8003b6:	c3                   	ret    

008003b7 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8003b7:	55                   	push   %ebp
  8003b8:	89 e5                	mov    %esp,%ebp
  8003ba:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8003bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c0:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8003c3:	6a 01                	push   $0x1
  8003c5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8003c8:	50                   	push   %eax
  8003c9:	e8 bb 0a 00 00       	call   800e89 <sys_cputs>
}
  8003ce:	83 c4 10             	add    $0x10,%esp
  8003d1:	c9                   	leave  
  8003d2:	c3                   	ret    

008003d3 <getchar>:

int
getchar(void)
{
  8003d3:	55                   	push   %ebp
  8003d4:	89 e5                	mov    %esp,%ebp
  8003d6:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8003d9:	6a 01                	push   $0x1
  8003db:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8003de:	50                   	push   %eax
  8003df:	6a 00                	push   $0x0
  8003e1:	e8 d5 12 00 00       	call   8016bb <read>
	if (r < 0)
  8003e6:	83 c4 10             	add    $0x10,%esp
  8003e9:	85 c0                	test   %eax,%eax
  8003eb:	78 0f                	js     8003fc <getchar+0x29>
		return r;
	if (r < 1)
  8003ed:	85 c0                	test   %eax,%eax
  8003ef:	7e 06                	jle    8003f7 <getchar+0x24>
		return -E_EOF;
	return c;
  8003f1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8003f5:	eb 05                	jmp    8003fc <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8003f7:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8003fc:	c9                   	leave  
  8003fd:	c3                   	ret    

008003fe <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8003fe:	55                   	push   %ebp
  8003ff:	89 e5                	mov    %esp,%ebp
  800401:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800404:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800407:	50                   	push   %eax
  800408:	ff 75 08             	pushl  0x8(%ebp)
  80040b:	e8 45 10 00 00       	call   801455 <fd_lookup>
  800410:	83 c4 10             	add    $0x10,%esp
  800413:	85 c0                	test   %eax,%eax
  800415:	78 11                	js     800428 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800417:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80041a:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800420:	39 10                	cmp    %edx,(%eax)
  800422:	0f 94 c0             	sete   %al
  800425:	0f b6 c0             	movzbl %al,%eax
}
  800428:	c9                   	leave  
  800429:	c3                   	ret    

0080042a <opencons>:

int
opencons(void)
{
  80042a:	55                   	push   %ebp
  80042b:	89 e5                	mov    %esp,%ebp
  80042d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800430:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800433:	50                   	push   %eax
  800434:	e8 cd 0f 00 00       	call   801406 <fd_alloc>
  800439:	83 c4 10             	add    $0x10,%esp
		return r;
  80043c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80043e:	85 c0                	test   %eax,%eax
  800440:	78 3e                	js     800480 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800442:	83 ec 04             	sub    $0x4,%esp
  800445:	68 07 04 00 00       	push   $0x407
  80044a:	ff 75 f4             	pushl  -0xc(%ebp)
  80044d:	6a 00                	push   $0x0
  80044f:	e8 f1 0a 00 00       	call   800f45 <sys_page_alloc>
  800454:	83 c4 10             	add    $0x10,%esp
		return r;
  800457:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800459:	85 c0                	test   %eax,%eax
  80045b:	78 23                	js     800480 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80045d:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800463:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800466:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800468:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80046b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800472:	83 ec 0c             	sub    $0xc,%esp
  800475:	50                   	push   %eax
  800476:	e8 64 0f 00 00       	call   8013df <fd2num>
  80047b:	89 c2                	mov    %eax,%edx
  80047d:	83 c4 10             	add    $0x10,%esp
}
  800480:	89 d0                	mov    %edx,%eax
  800482:	c9                   	leave  
  800483:	c3                   	ret    

00800484 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800484:	55                   	push   %ebp
  800485:	89 e5                	mov    %esp,%ebp
  800487:	56                   	push   %esi
  800488:	53                   	push   %ebx
  800489:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80048c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80048f:	e8 73 0a 00 00       	call   800f07 <sys_getenvid>
  800494:	25 ff 03 00 00       	and    $0x3ff,%eax
  800499:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80049c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8004a1:	a3 04 50 80 00       	mov    %eax,0x805004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8004a6:	85 db                	test   %ebx,%ebx
  8004a8:	7e 07                	jle    8004b1 <libmain+0x2d>
		binaryname = argv[0];
  8004aa:	8b 06                	mov    (%esi),%eax
  8004ac:	a3 1c 40 80 00       	mov    %eax,0x80401c

	// call user main routine
	umain(argc, argv);
  8004b1:	83 ec 08             	sub    $0x8,%esp
  8004b4:	56                   	push   %esi
  8004b5:	53                   	push   %ebx
  8004b6:	e8 30 fc ff ff       	call   8000eb <umain>

	// exit gracefully
	exit();
  8004bb:	e8 0a 00 00 00       	call   8004ca <exit>
}
  8004c0:	83 c4 10             	add    $0x10,%esp
  8004c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004c6:	5b                   	pop    %ebx
  8004c7:	5e                   	pop    %esi
  8004c8:	5d                   	pop    %ebp
  8004c9:	c3                   	ret    

008004ca <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8004ca:	55                   	push   %ebp
  8004cb:	89 e5                	mov    %esp,%ebp
  8004cd:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8004d0:	e8 d5 10 00 00       	call   8015aa <close_all>
	sys_env_destroy(0);
  8004d5:	83 ec 0c             	sub    $0xc,%esp
  8004d8:	6a 00                	push   $0x0
  8004da:	e8 e7 09 00 00       	call   800ec6 <sys_env_destroy>
}
  8004df:	83 c4 10             	add    $0x10,%esp
  8004e2:	c9                   	leave  
  8004e3:	c3                   	ret    

008004e4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8004e4:	55                   	push   %ebp
  8004e5:	89 e5                	mov    %esp,%ebp
  8004e7:	56                   	push   %esi
  8004e8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8004e9:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8004ec:	8b 35 1c 40 80 00    	mov    0x80401c,%esi
  8004f2:	e8 10 0a 00 00       	call   800f07 <sys_getenvid>
  8004f7:	83 ec 0c             	sub    $0xc,%esp
  8004fa:	ff 75 0c             	pushl  0xc(%ebp)
  8004fd:	ff 75 08             	pushl  0x8(%ebp)
  800500:	56                   	push   %esi
  800501:	50                   	push   %eax
  800502:	68 04 2b 80 00       	push   $0x802b04
  800507:	e8 b1 00 00 00       	call   8005bd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80050c:	83 c4 18             	add    $0x18,%esp
  80050f:	53                   	push   %ebx
  800510:	ff 75 10             	pushl  0x10(%ebp)
  800513:	e8 54 00 00 00       	call   80056c <vcprintf>
	cprintf("\n");
  800518:	c7 04 24 38 2a 80 00 	movl   $0x802a38,(%esp)
  80051f:	e8 99 00 00 00       	call   8005bd <cprintf>
  800524:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800527:	cc                   	int3   
  800528:	eb fd                	jmp    800527 <_panic+0x43>

0080052a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80052a:	55                   	push   %ebp
  80052b:	89 e5                	mov    %esp,%ebp
  80052d:	53                   	push   %ebx
  80052e:	83 ec 04             	sub    $0x4,%esp
  800531:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800534:	8b 13                	mov    (%ebx),%edx
  800536:	8d 42 01             	lea    0x1(%edx),%eax
  800539:	89 03                	mov    %eax,(%ebx)
  80053b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80053e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800542:	3d ff 00 00 00       	cmp    $0xff,%eax
  800547:	75 1a                	jne    800563 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800549:	83 ec 08             	sub    $0x8,%esp
  80054c:	68 ff 00 00 00       	push   $0xff
  800551:	8d 43 08             	lea    0x8(%ebx),%eax
  800554:	50                   	push   %eax
  800555:	e8 2f 09 00 00       	call   800e89 <sys_cputs>
		b->idx = 0;
  80055a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800560:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800563:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800567:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80056a:	c9                   	leave  
  80056b:	c3                   	ret    

0080056c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80056c:	55                   	push   %ebp
  80056d:	89 e5                	mov    %esp,%ebp
  80056f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800575:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80057c:	00 00 00 
	b.cnt = 0;
  80057f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800586:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800589:	ff 75 0c             	pushl  0xc(%ebp)
  80058c:	ff 75 08             	pushl  0x8(%ebp)
  80058f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800595:	50                   	push   %eax
  800596:	68 2a 05 80 00       	push   $0x80052a
  80059b:	e8 54 01 00 00       	call   8006f4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8005a0:	83 c4 08             	add    $0x8,%esp
  8005a3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8005a9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8005af:	50                   	push   %eax
  8005b0:	e8 d4 08 00 00       	call   800e89 <sys_cputs>

	return b.cnt;
}
  8005b5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8005bb:	c9                   	leave  
  8005bc:	c3                   	ret    

008005bd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8005bd:	55                   	push   %ebp
  8005be:	89 e5                	mov    %esp,%ebp
  8005c0:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8005c3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8005c6:	50                   	push   %eax
  8005c7:	ff 75 08             	pushl  0x8(%ebp)
  8005ca:	e8 9d ff ff ff       	call   80056c <vcprintf>
	va_end(ap);

	return cnt;
}
  8005cf:	c9                   	leave  
  8005d0:	c3                   	ret    

008005d1 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005d1:	55                   	push   %ebp
  8005d2:	89 e5                	mov    %esp,%ebp
  8005d4:	57                   	push   %edi
  8005d5:	56                   	push   %esi
  8005d6:	53                   	push   %ebx
  8005d7:	83 ec 1c             	sub    $0x1c,%esp
  8005da:	89 c7                	mov    %eax,%edi
  8005dc:	89 d6                	mov    %edx,%esi
  8005de:	8b 45 08             	mov    0x8(%ebp),%eax
  8005e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005e4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e7:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005ea:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8005ed:	bb 00 00 00 00       	mov    $0x0,%ebx
  8005f2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8005f5:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8005f8:	39 d3                	cmp    %edx,%ebx
  8005fa:	72 05                	jb     800601 <printnum+0x30>
  8005fc:	39 45 10             	cmp    %eax,0x10(%ebp)
  8005ff:	77 45                	ja     800646 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800601:	83 ec 0c             	sub    $0xc,%esp
  800604:	ff 75 18             	pushl  0x18(%ebp)
  800607:	8b 45 14             	mov    0x14(%ebp),%eax
  80060a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80060d:	53                   	push   %ebx
  80060e:	ff 75 10             	pushl  0x10(%ebp)
  800611:	83 ec 08             	sub    $0x8,%esp
  800614:	ff 75 e4             	pushl  -0x1c(%ebp)
  800617:	ff 75 e0             	pushl  -0x20(%ebp)
  80061a:	ff 75 dc             	pushl  -0x24(%ebp)
  80061d:	ff 75 d8             	pushl  -0x28(%ebp)
  800620:	e8 fb 20 00 00       	call   802720 <__udivdi3>
  800625:	83 c4 18             	add    $0x18,%esp
  800628:	52                   	push   %edx
  800629:	50                   	push   %eax
  80062a:	89 f2                	mov    %esi,%edx
  80062c:	89 f8                	mov    %edi,%eax
  80062e:	e8 9e ff ff ff       	call   8005d1 <printnum>
  800633:	83 c4 20             	add    $0x20,%esp
  800636:	eb 18                	jmp    800650 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800638:	83 ec 08             	sub    $0x8,%esp
  80063b:	56                   	push   %esi
  80063c:	ff 75 18             	pushl  0x18(%ebp)
  80063f:	ff d7                	call   *%edi
  800641:	83 c4 10             	add    $0x10,%esp
  800644:	eb 03                	jmp    800649 <printnum+0x78>
  800646:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800649:	83 eb 01             	sub    $0x1,%ebx
  80064c:	85 db                	test   %ebx,%ebx
  80064e:	7f e8                	jg     800638 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800650:	83 ec 08             	sub    $0x8,%esp
  800653:	56                   	push   %esi
  800654:	83 ec 04             	sub    $0x4,%esp
  800657:	ff 75 e4             	pushl  -0x1c(%ebp)
  80065a:	ff 75 e0             	pushl  -0x20(%ebp)
  80065d:	ff 75 dc             	pushl  -0x24(%ebp)
  800660:	ff 75 d8             	pushl  -0x28(%ebp)
  800663:	e8 e8 21 00 00       	call   802850 <__umoddi3>
  800668:	83 c4 14             	add    $0x14,%esp
  80066b:	0f be 80 27 2b 80 00 	movsbl 0x802b27(%eax),%eax
  800672:	50                   	push   %eax
  800673:	ff d7                	call   *%edi
}
  800675:	83 c4 10             	add    $0x10,%esp
  800678:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80067b:	5b                   	pop    %ebx
  80067c:	5e                   	pop    %esi
  80067d:	5f                   	pop    %edi
  80067e:	5d                   	pop    %ebp
  80067f:	c3                   	ret    

00800680 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800680:	55                   	push   %ebp
  800681:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800683:	83 fa 01             	cmp    $0x1,%edx
  800686:	7e 0e                	jle    800696 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800688:	8b 10                	mov    (%eax),%edx
  80068a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80068d:	89 08                	mov    %ecx,(%eax)
  80068f:	8b 02                	mov    (%edx),%eax
  800691:	8b 52 04             	mov    0x4(%edx),%edx
  800694:	eb 22                	jmp    8006b8 <getuint+0x38>
	else if (lflag)
  800696:	85 d2                	test   %edx,%edx
  800698:	74 10                	je     8006aa <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80069a:	8b 10                	mov    (%eax),%edx
  80069c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80069f:	89 08                	mov    %ecx,(%eax)
  8006a1:	8b 02                	mov    (%edx),%eax
  8006a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8006a8:	eb 0e                	jmp    8006b8 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8006aa:	8b 10                	mov    (%eax),%edx
  8006ac:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006af:	89 08                	mov    %ecx,(%eax)
  8006b1:	8b 02                	mov    (%edx),%eax
  8006b3:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8006b8:	5d                   	pop    %ebp
  8006b9:	c3                   	ret    

008006ba <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8006ba:	55                   	push   %ebp
  8006bb:	89 e5                	mov    %esp,%ebp
  8006bd:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8006c0:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8006c4:	8b 10                	mov    (%eax),%edx
  8006c6:	3b 50 04             	cmp    0x4(%eax),%edx
  8006c9:	73 0a                	jae    8006d5 <sprintputch+0x1b>
		*b->buf++ = ch;
  8006cb:	8d 4a 01             	lea    0x1(%edx),%ecx
  8006ce:	89 08                	mov    %ecx,(%eax)
  8006d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d3:	88 02                	mov    %al,(%edx)
}
  8006d5:	5d                   	pop    %ebp
  8006d6:	c3                   	ret    

008006d7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8006d7:	55                   	push   %ebp
  8006d8:	89 e5                	mov    %esp,%ebp
  8006da:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8006dd:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8006e0:	50                   	push   %eax
  8006e1:	ff 75 10             	pushl  0x10(%ebp)
  8006e4:	ff 75 0c             	pushl  0xc(%ebp)
  8006e7:	ff 75 08             	pushl  0x8(%ebp)
  8006ea:	e8 05 00 00 00       	call   8006f4 <vprintfmt>
	va_end(ap);
}
  8006ef:	83 c4 10             	add    $0x10,%esp
  8006f2:	c9                   	leave  
  8006f3:	c3                   	ret    

008006f4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006f4:	55                   	push   %ebp
  8006f5:	89 e5                	mov    %esp,%ebp
  8006f7:	57                   	push   %edi
  8006f8:	56                   	push   %esi
  8006f9:	53                   	push   %ebx
  8006fa:	83 ec 2c             	sub    $0x2c,%esp
  8006fd:	8b 75 08             	mov    0x8(%ebp),%esi
  800700:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800703:	8b 7d 10             	mov    0x10(%ebp),%edi
  800706:	eb 12                	jmp    80071a <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800708:	85 c0                	test   %eax,%eax
  80070a:	0f 84 89 03 00 00    	je     800a99 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800710:	83 ec 08             	sub    $0x8,%esp
  800713:	53                   	push   %ebx
  800714:	50                   	push   %eax
  800715:	ff d6                	call   *%esi
  800717:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80071a:	83 c7 01             	add    $0x1,%edi
  80071d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800721:	83 f8 25             	cmp    $0x25,%eax
  800724:	75 e2                	jne    800708 <vprintfmt+0x14>
  800726:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80072a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800731:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800738:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80073f:	ba 00 00 00 00       	mov    $0x0,%edx
  800744:	eb 07                	jmp    80074d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800746:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800749:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80074d:	8d 47 01             	lea    0x1(%edi),%eax
  800750:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800753:	0f b6 07             	movzbl (%edi),%eax
  800756:	0f b6 c8             	movzbl %al,%ecx
  800759:	83 e8 23             	sub    $0x23,%eax
  80075c:	3c 55                	cmp    $0x55,%al
  80075e:	0f 87 1a 03 00 00    	ja     800a7e <vprintfmt+0x38a>
  800764:	0f b6 c0             	movzbl %al,%eax
  800767:	ff 24 85 60 2c 80 00 	jmp    *0x802c60(,%eax,4)
  80076e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800771:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800775:	eb d6                	jmp    80074d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800777:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80077a:	b8 00 00 00 00       	mov    $0x0,%eax
  80077f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800782:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800785:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800789:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80078c:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80078f:	83 fa 09             	cmp    $0x9,%edx
  800792:	77 39                	ja     8007cd <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800794:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800797:	eb e9                	jmp    800782 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800799:	8b 45 14             	mov    0x14(%ebp),%eax
  80079c:	8d 48 04             	lea    0x4(%eax),%ecx
  80079f:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8007a2:	8b 00                	mov    (%eax),%eax
  8007a4:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8007aa:	eb 27                	jmp    8007d3 <vprintfmt+0xdf>
  8007ac:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007af:	85 c0                	test   %eax,%eax
  8007b1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007b6:	0f 49 c8             	cmovns %eax,%ecx
  8007b9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007bf:	eb 8c                	jmp    80074d <vprintfmt+0x59>
  8007c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8007c4:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8007cb:	eb 80                	jmp    80074d <vprintfmt+0x59>
  8007cd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007d0:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8007d3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8007d7:	0f 89 70 ff ff ff    	jns    80074d <vprintfmt+0x59>
				width = precision, precision = -1;
  8007dd:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8007e0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007e3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8007ea:	e9 5e ff ff ff       	jmp    80074d <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007ef:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8007f5:	e9 53 ff ff ff       	jmp    80074d <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fd:	8d 50 04             	lea    0x4(%eax),%edx
  800800:	89 55 14             	mov    %edx,0x14(%ebp)
  800803:	83 ec 08             	sub    $0x8,%esp
  800806:	53                   	push   %ebx
  800807:	ff 30                	pushl  (%eax)
  800809:	ff d6                	call   *%esi
			break;
  80080b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80080e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800811:	e9 04 ff ff ff       	jmp    80071a <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800816:	8b 45 14             	mov    0x14(%ebp),%eax
  800819:	8d 50 04             	lea    0x4(%eax),%edx
  80081c:	89 55 14             	mov    %edx,0x14(%ebp)
  80081f:	8b 00                	mov    (%eax),%eax
  800821:	99                   	cltd   
  800822:	31 d0                	xor    %edx,%eax
  800824:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800826:	83 f8 0f             	cmp    $0xf,%eax
  800829:	7f 0b                	jg     800836 <vprintfmt+0x142>
  80082b:	8b 14 85 c0 2d 80 00 	mov    0x802dc0(,%eax,4),%edx
  800832:	85 d2                	test   %edx,%edx
  800834:	75 18                	jne    80084e <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800836:	50                   	push   %eax
  800837:	68 3f 2b 80 00       	push   $0x802b3f
  80083c:	53                   	push   %ebx
  80083d:	56                   	push   %esi
  80083e:	e8 94 fe ff ff       	call   8006d7 <printfmt>
  800843:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800846:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800849:	e9 cc fe ff ff       	jmp    80071a <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80084e:	52                   	push   %edx
  80084f:	68 76 2f 80 00       	push   $0x802f76
  800854:	53                   	push   %ebx
  800855:	56                   	push   %esi
  800856:	e8 7c fe ff ff       	call   8006d7 <printfmt>
  80085b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80085e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800861:	e9 b4 fe ff ff       	jmp    80071a <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800866:	8b 45 14             	mov    0x14(%ebp),%eax
  800869:	8d 50 04             	lea    0x4(%eax),%edx
  80086c:	89 55 14             	mov    %edx,0x14(%ebp)
  80086f:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800871:	85 ff                	test   %edi,%edi
  800873:	b8 38 2b 80 00       	mov    $0x802b38,%eax
  800878:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80087b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80087f:	0f 8e 94 00 00 00    	jle    800919 <vprintfmt+0x225>
  800885:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800889:	0f 84 98 00 00 00    	je     800927 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80088f:	83 ec 08             	sub    $0x8,%esp
  800892:	ff 75 d0             	pushl  -0x30(%ebp)
  800895:	57                   	push   %edi
  800896:	e8 86 02 00 00       	call   800b21 <strnlen>
  80089b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80089e:	29 c1                	sub    %eax,%ecx
  8008a0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8008a3:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8008a6:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8008aa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008ad:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8008b0:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008b2:	eb 0f                	jmp    8008c3 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8008b4:	83 ec 08             	sub    $0x8,%esp
  8008b7:	53                   	push   %ebx
  8008b8:	ff 75 e0             	pushl  -0x20(%ebp)
  8008bb:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008bd:	83 ef 01             	sub    $0x1,%edi
  8008c0:	83 c4 10             	add    $0x10,%esp
  8008c3:	85 ff                	test   %edi,%edi
  8008c5:	7f ed                	jg     8008b4 <vprintfmt+0x1c0>
  8008c7:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8008ca:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8008cd:	85 c9                	test   %ecx,%ecx
  8008cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d4:	0f 49 c1             	cmovns %ecx,%eax
  8008d7:	29 c1                	sub    %eax,%ecx
  8008d9:	89 75 08             	mov    %esi,0x8(%ebp)
  8008dc:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8008df:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8008e2:	89 cb                	mov    %ecx,%ebx
  8008e4:	eb 4d                	jmp    800933 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8008e6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8008ea:	74 1b                	je     800907 <vprintfmt+0x213>
  8008ec:	0f be c0             	movsbl %al,%eax
  8008ef:	83 e8 20             	sub    $0x20,%eax
  8008f2:	83 f8 5e             	cmp    $0x5e,%eax
  8008f5:	76 10                	jbe    800907 <vprintfmt+0x213>
					putch('?', putdat);
  8008f7:	83 ec 08             	sub    $0x8,%esp
  8008fa:	ff 75 0c             	pushl  0xc(%ebp)
  8008fd:	6a 3f                	push   $0x3f
  8008ff:	ff 55 08             	call   *0x8(%ebp)
  800902:	83 c4 10             	add    $0x10,%esp
  800905:	eb 0d                	jmp    800914 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800907:	83 ec 08             	sub    $0x8,%esp
  80090a:	ff 75 0c             	pushl  0xc(%ebp)
  80090d:	52                   	push   %edx
  80090e:	ff 55 08             	call   *0x8(%ebp)
  800911:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800914:	83 eb 01             	sub    $0x1,%ebx
  800917:	eb 1a                	jmp    800933 <vprintfmt+0x23f>
  800919:	89 75 08             	mov    %esi,0x8(%ebp)
  80091c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80091f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800922:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800925:	eb 0c                	jmp    800933 <vprintfmt+0x23f>
  800927:	89 75 08             	mov    %esi,0x8(%ebp)
  80092a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80092d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800930:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800933:	83 c7 01             	add    $0x1,%edi
  800936:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80093a:	0f be d0             	movsbl %al,%edx
  80093d:	85 d2                	test   %edx,%edx
  80093f:	74 23                	je     800964 <vprintfmt+0x270>
  800941:	85 f6                	test   %esi,%esi
  800943:	78 a1                	js     8008e6 <vprintfmt+0x1f2>
  800945:	83 ee 01             	sub    $0x1,%esi
  800948:	79 9c                	jns    8008e6 <vprintfmt+0x1f2>
  80094a:	89 df                	mov    %ebx,%edi
  80094c:	8b 75 08             	mov    0x8(%ebp),%esi
  80094f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800952:	eb 18                	jmp    80096c <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800954:	83 ec 08             	sub    $0x8,%esp
  800957:	53                   	push   %ebx
  800958:	6a 20                	push   $0x20
  80095a:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80095c:	83 ef 01             	sub    $0x1,%edi
  80095f:	83 c4 10             	add    $0x10,%esp
  800962:	eb 08                	jmp    80096c <vprintfmt+0x278>
  800964:	89 df                	mov    %ebx,%edi
  800966:	8b 75 08             	mov    0x8(%ebp),%esi
  800969:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80096c:	85 ff                	test   %edi,%edi
  80096e:	7f e4                	jg     800954 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800970:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800973:	e9 a2 fd ff ff       	jmp    80071a <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800978:	83 fa 01             	cmp    $0x1,%edx
  80097b:	7e 16                	jle    800993 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80097d:	8b 45 14             	mov    0x14(%ebp),%eax
  800980:	8d 50 08             	lea    0x8(%eax),%edx
  800983:	89 55 14             	mov    %edx,0x14(%ebp)
  800986:	8b 50 04             	mov    0x4(%eax),%edx
  800989:	8b 00                	mov    (%eax),%eax
  80098b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80098e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800991:	eb 32                	jmp    8009c5 <vprintfmt+0x2d1>
	else if (lflag)
  800993:	85 d2                	test   %edx,%edx
  800995:	74 18                	je     8009af <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800997:	8b 45 14             	mov    0x14(%ebp),%eax
  80099a:	8d 50 04             	lea    0x4(%eax),%edx
  80099d:	89 55 14             	mov    %edx,0x14(%ebp)
  8009a0:	8b 00                	mov    (%eax),%eax
  8009a2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8009a5:	89 c1                	mov    %eax,%ecx
  8009a7:	c1 f9 1f             	sar    $0x1f,%ecx
  8009aa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8009ad:	eb 16                	jmp    8009c5 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8009af:	8b 45 14             	mov    0x14(%ebp),%eax
  8009b2:	8d 50 04             	lea    0x4(%eax),%edx
  8009b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8009b8:	8b 00                	mov    (%eax),%eax
  8009ba:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8009bd:	89 c1                	mov    %eax,%ecx
  8009bf:	c1 f9 1f             	sar    $0x1f,%ecx
  8009c2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8009c5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8009c8:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8009cb:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8009d0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8009d4:	79 74                	jns    800a4a <vprintfmt+0x356>
				putch('-', putdat);
  8009d6:	83 ec 08             	sub    $0x8,%esp
  8009d9:	53                   	push   %ebx
  8009da:	6a 2d                	push   $0x2d
  8009dc:	ff d6                	call   *%esi
				num = -(long long) num;
  8009de:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8009e1:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8009e4:	f7 d8                	neg    %eax
  8009e6:	83 d2 00             	adc    $0x0,%edx
  8009e9:	f7 da                	neg    %edx
  8009eb:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8009ee:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8009f3:	eb 55                	jmp    800a4a <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8009f5:	8d 45 14             	lea    0x14(%ebp),%eax
  8009f8:	e8 83 fc ff ff       	call   800680 <getuint>
			base = 10;
  8009fd:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800a02:	eb 46                	jmp    800a4a <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800a04:	8d 45 14             	lea    0x14(%ebp),%eax
  800a07:	e8 74 fc ff ff       	call   800680 <getuint>
                        base = 8;
  800a0c:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800a11:	eb 37                	jmp    800a4a <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800a13:	83 ec 08             	sub    $0x8,%esp
  800a16:	53                   	push   %ebx
  800a17:	6a 30                	push   $0x30
  800a19:	ff d6                	call   *%esi
			putch('x', putdat);
  800a1b:	83 c4 08             	add    $0x8,%esp
  800a1e:	53                   	push   %ebx
  800a1f:	6a 78                	push   $0x78
  800a21:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a23:	8b 45 14             	mov    0x14(%ebp),%eax
  800a26:	8d 50 04             	lea    0x4(%eax),%edx
  800a29:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a2c:	8b 00                	mov    (%eax),%eax
  800a2e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800a33:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a36:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800a3b:	eb 0d                	jmp    800a4a <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a3d:	8d 45 14             	lea    0x14(%ebp),%eax
  800a40:	e8 3b fc ff ff       	call   800680 <getuint>
			base = 16;
  800a45:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a4a:	83 ec 0c             	sub    $0xc,%esp
  800a4d:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800a51:	57                   	push   %edi
  800a52:	ff 75 e0             	pushl  -0x20(%ebp)
  800a55:	51                   	push   %ecx
  800a56:	52                   	push   %edx
  800a57:	50                   	push   %eax
  800a58:	89 da                	mov    %ebx,%edx
  800a5a:	89 f0                	mov    %esi,%eax
  800a5c:	e8 70 fb ff ff       	call   8005d1 <printnum>
			break;
  800a61:	83 c4 20             	add    $0x20,%esp
  800a64:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a67:	e9 ae fc ff ff       	jmp    80071a <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a6c:	83 ec 08             	sub    $0x8,%esp
  800a6f:	53                   	push   %ebx
  800a70:	51                   	push   %ecx
  800a71:	ff d6                	call   *%esi
			break;
  800a73:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a76:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800a79:	e9 9c fc ff ff       	jmp    80071a <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a7e:	83 ec 08             	sub    $0x8,%esp
  800a81:	53                   	push   %ebx
  800a82:	6a 25                	push   $0x25
  800a84:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a86:	83 c4 10             	add    $0x10,%esp
  800a89:	eb 03                	jmp    800a8e <vprintfmt+0x39a>
  800a8b:	83 ef 01             	sub    $0x1,%edi
  800a8e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800a92:	75 f7                	jne    800a8b <vprintfmt+0x397>
  800a94:	e9 81 fc ff ff       	jmp    80071a <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800a99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a9c:	5b                   	pop    %ebx
  800a9d:	5e                   	pop    %esi
  800a9e:	5f                   	pop    %edi
  800a9f:	5d                   	pop    %ebp
  800aa0:	c3                   	ret    

00800aa1 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800aa1:	55                   	push   %ebp
  800aa2:	89 e5                	mov    %esp,%ebp
  800aa4:	83 ec 18             	sub    $0x18,%esp
  800aa7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aaa:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800aad:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ab0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800ab4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800ab7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800abe:	85 c0                	test   %eax,%eax
  800ac0:	74 26                	je     800ae8 <vsnprintf+0x47>
  800ac2:	85 d2                	test   %edx,%edx
  800ac4:	7e 22                	jle    800ae8 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800ac6:	ff 75 14             	pushl  0x14(%ebp)
  800ac9:	ff 75 10             	pushl  0x10(%ebp)
  800acc:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800acf:	50                   	push   %eax
  800ad0:	68 ba 06 80 00       	push   $0x8006ba
  800ad5:	e8 1a fc ff ff       	call   8006f4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800ada:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800add:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800ae0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ae3:	83 c4 10             	add    $0x10,%esp
  800ae6:	eb 05                	jmp    800aed <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800ae8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800aed:	c9                   	leave  
  800aee:	c3                   	ret    

00800aef <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800aef:	55                   	push   %ebp
  800af0:	89 e5                	mov    %esp,%ebp
  800af2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800af5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800af8:	50                   	push   %eax
  800af9:	ff 75 10             	pushl  0x10(%ebp)
  800afc:	ff 75 0c             	pushl  0xc(%ebp)
  800aff:	ff 75 08             	pushl  0x8(%ebp)
  800b02:	e8 9a ff ff ff       	call   800aa1 <vsnprintf>
	va_end(ap);

	return rc;
}
  800b07:	c9                   	leave  
  800b08:	c3                   	ret    

00800b09 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b09:	55                   	push   %ebp
  800b0a:	89 e5                	mov    %esp,%ebp
  800b0c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b0f:	b8 00 00 00 00       	mov    $0x0,%eax
  800b14:	eb 03                	jmp    800b19 <strlen+0x10>
		n++;
  800b16:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b19:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b1d:	75 f7                	jne    800b16 <strlen+0xd>
		n++;
	return n;
}
  800b1f:	5d                   	pop    %ebp
  800b20:	c3                   	ret    

00800b21 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b21:	55                   	push   %ebp
  800b22:	89 e5                	mov    %esp,%ebp
  800b24:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b27:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b2a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2f:	eb 03                	jmp    800b34 <strnlen+0x13>
		n++;
  800b31:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b34:	39 c2                	cmp    %eax,%edx
  800b36:	74 08                	je     800b40 <strnlen+0x1f>
  800b38:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800b3c:	75 f3                	jne    800b31 <strnlen+0x10>
  800b3e:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800b40:	5d                   	pop    %ebp
  800b41:	c3                   	ret    

00800b42 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b42:	55                   	push   %ebp
  800b43:	89 e5                	mov    %esp,%ebp
  800b45:	53                   	push   %ebx
  800b46:	8b 45 08             	mov    0x8(%ebp),%eax
  800b49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b4c:	89 c2                	mov    %eax,%edx
  800b4e:	83 c2 01             	add    $0x1,%edx
  800b51:	83 c1 01             	add    $0x1,%ecx
  800b54:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800b58:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b5b:	84 db                	test   %bl,%bl
  800b5d:	75 ef                	jne    800b4e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800b5f:	5b                   	pop    %ebx
  800b60:	5d                   	pop    %ebp
  800b61:	c3                   	ret    

00800b62 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b62:	55                   	push   %ebp
  800b63:	89 e5                	mov    %esp,%ebp
  800b65:	53                   	push   %ebx
  800b66:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b69:	53                   	push   %ebx
  800b6a:	e8 9a ff ff ff       	call   800b09 <strlen>
  800b6f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800b72:	ff 75 0c             	pushl  0xc(%ebp)
  800b75:	01 d8                	add    %ebx,%eax
  800b77:	50                   	push   %eax
  800b78:	e8 c5 ff ff ff       	call   800b42 <strcpy>
	return dst;
}
  800b7d:	89 d8                	mov    %ebx,%eax
  800b7f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b82:	c9                   	leave  
  800b83:	c3                   	ret    

00800b84 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b84:	55                   	push   %ebp
  800b85:	89 e5                	mov    %esp,%ebp
  800b87:	56                   	push   %esi
  800b88:	53                   	push   %ebx
  800b89:	8b 75 08             	mov    0x8(%ebp),%esi
  800b8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8f:	89 f3                	mov    %esi,%ebx
  800b91:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b94:	89 f2                	mov    %esi,%edx
  800b96:	eb 0f                	jmp    800ba7 <strncpy+0x23>
		*dst++ = *src;
  800b98:	83 c2 01             	add    $0x1,%edx
  800b9b:	0f b6 01             	movzbl (%ecx),%eax
  800b9e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ba1:	80 39 01             	cmpb   $0x1,(%ecx)
  800ba4:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ba7:	39 da                	cmp    %ebx,%edx
  800ba9:	75 ed                	jne    800b98 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800bab:	89 f0                	mov    %esi,%eax
  800bad:	5b                   	pop    %ebx
  800bae:	5e                   	pop    %esi
  800baf:	5d                   	pop    %ebp
  800bb0:	c3                   	ret    

00800bb1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800bb1:	55                   	push   %ebp
  800bb2:	89 e5                	mov    %esp,%ebp
  800bb4:	56                   	push   %esi
  800bb5:	53                   	push   %ebx
  800bb6:	8b 75 08             	mov    0x8(%ebp),%esi
  800bb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bbc:	8b 55 10             	mov    0x10(%ebp),%edx
  800bbf:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800bc1:	85 d2                	test   %edx,%edx
  800bc3:	74 21                	je     800be6 <strlcpy+0x35>
  800bc5:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800bc9:	89 f2                	mov    %esi,%edx
  800bcb:	eb 09                	jmp    800bd6 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800bcd:	83 c2 01             	add    $0x1,%edx
  800bd0:	83 c1 01             	add    $0x1,%ecx
  800bd3:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800bd6:	39 c2                	cmp    %eax,%edx
  800bd8:	74 09                	je     800be3 <strlcpy+0x32>
  800bda:	0f b6 19             	movzbl (%ecx),%ebx
  800bdd:	84 db                	test   %bl,%bl
  800bdf:	75 ec                	jne    800bcd <strlcpy+0x1c>
  800be1:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800be3:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800be6:	29 f0                	sub    %esi,%eax
}
  800be8:	5b                   	pop    %ebx
  800be9:	5e                   	pop    %esi
  800bea:	5d                   	pop    %ebp
  800beb:	c3                   	ret    

00800bec <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800bec:	55                   	push   %ebp
  800bed:	89 e5                	mov    %esp,%ebp
  800bef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bf2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800bf5:	eb 06                	jmp    800bfd <strcmp+0x11>
		p++, q++;
  800bf7:	83 c1 01             	add    $0x1,%ecx
  800bfa:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800bfd:	0f b6 01             	movzbl (%ecx),%eax
  800c00:	84 c0                	test   %al,%al
  800c02:	74 04                	je     800c08 <strcmp+0x1c>
  800c04:	3a 02                	cmp    (%edx),%al
  800c06:	74 ef                	je     800bf7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c08:	0f b6 c0             	movzbl %al,%eax
  800c0b:	0f b6 12             	movzbl (%edx),%edx
  800c0e:	29 d0                	sub    %edx,%eax
}
  800c10:	5d                   	pop    %ebp
  800c11:	c3                   	ret    

00800c12 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c12:	55                   	push   %ebp
  800c13:	89 e5                	mov    %esp,%ebp
  800c15:	53                   	push   %ebx
  800c16:	8b 45 08             	mov    0x8(%ebp),%eax
  800c19:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c1c:	89 c3                	mov    %eax,%ebx
  800c1e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800c21:	eb 06                	jmp    800c29 <strncmp+0x17>
		n--, p++, q++;
  800c23:	83 c0 01             	add    $0x1,%eax
  800c26:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c29:	39 d8                	cmp    %ebx,%eax
  800c2b:	74 15                	je     800c42 <strncmp+0x30>
  800c2d:	0f b6 08             	movzbl (%eax),%ecx
  800c30:	84 c9                	test   %cl,%cl
  800c32:	74 04                	je     800c38 <strncmp+0x26>
  800c34:	3a 0a                	cmp    (%edx),%cl
  800c36:	74 eb                	je     800c23 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c38:	0f b6 00             	movzbl (%eax),%eax
  800c3b:	0f b6 12             	movzbl (%edx),%edx
  800c3e:	29 d0                	sub    %edx,%eax
  800c40:	eb 05                	jmp    800c47 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c42:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c47:	5b                   	pop    %ebx
  800c48:	5d                   	pop    %ebp
  800c49:	c3                   	ret    

00800c4a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c4a:	55                   	push   %ebp
  800c4b:	89 e5                	mov    %esp,%ebp
  800c4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c50:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c54:	eb 07                	jmp    800c5d <strchr+0x13>
		if (*s == c)
  800c56:	38 ca                	cmp    %cl,%dl
  800c58:	74 0f                	je     800c69 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c5a:	83 c0 01             	add    $0x1,%eax
  800c5d:	0f b6 10             	movzbl (%eax),%edx
  800c60:	84 d2                	test   %dl,%dl
  800c62:	75 f2                	jne    800c56 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800c64:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c69:	5d                   	pop    %ebp
  800c6a:	c3                   	ret    

00800c6b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c6b:	55                   	push   %ebp
  800c6c:	89 e5                	mov    %esp,%ebp
  800c6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c71:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c75:	eb 03                	jmp    800c7a <strfind+0xf>
  800c77:	83 c0 01             	add    $0x1,%eax
  800c7a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800c7d:	38 ca                	cmp    %cl,%dl
  800c7f:	74 04                	je     800c85 <strfind+0x1a>
  800c81:	84 d2                	test   %dl,%dl
  800c83:	75 f2                	jne    800c77 <strfind+0xc>
			break;
	return (char *) s;
}
  800c85:	5d                   	pop    %ebp
  800c86:	c3                   	ret    

00800c87 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c87:	55                   	push   %ebp
  800c88:	89 e5                	mov    %esp,%ebp
  800c8a:	57                   	push   %edi
  800c8b:	56                   	push   %esi
  800c8c:	53                   	push   %ebx
  800c8d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c90:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c93:	85 c9                	test   %ecx,%ecx
  800c95:	74 36                	je     800ccd <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c97:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c9d:	75 28                	jne    800cc7 <memset+0x40>
  800c9f:	f6 c1 03             	test   $0x3,%cl
  800ca2:	75 23                	jne    800cc7 <memset+0x40>
		c &= 0xFF;
  800ca4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ca8:	89 d3                	mov    %edx,%ebx
  800caa:	c1 e3 08             	shl    $0x8,%ebx
  800cad:	89 d6                	mov    %edx,%esi
  800caf:	c1 e6 18             	shl    $0x18,%esi
  800cb2:	89 d0                	mov    %edx,%eax
  800cb4:	c1 e0 10             	shl    $0x10,%eax
  800cb7:	09 f0                	or     %esi,%eax
  800cb9:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800cbb:	89 d8                	mov    %ebx,%eax
  800cbd:	09 d0                	or     %edx,%eax
  800cbf:	c1 e9 02             	shr    $0x2,%ecx
  800cc2:	fc                   	cld    
  800cc3:	f3 ab                	rep stos %eax,%es:(%edi)
  800cc5:	eb 06                	jmp    800ccd <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800cc7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cca:	fc                   	cld    
  800ccb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ccd:	89 f8                	mov    %edi,%eax
  800ccf:	5b                   	pop    %ebx
  800cd0:	5e                   	pop    %esi
  800cd1:	5f                   	pop    %edi
  800cd2:	5d                   	pop    %ebp
  800cd3:	c3                   	ret    

00800cd4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800cd4:	55                   	push   %ebp
  800cd5:	89 e5                	mov    %esp,%ebp
  800cd7:	57                   	push   %edi
  800cd8:	56                   	push   %esi
  800cd9:	8b 45 08             	mov    0x8(%ebp),%eax
  800cdc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cdf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ce2:	39 c6                	cmp    %eax,%esi
  800ce4:	73 35                	jae    800d1b <memmove+0x47>
  800ce6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ce9:	39 d0                	cmp    %edx,%eax
  800ceb:	73 2e                	jae    800d1b <memmove+0x47>
		s += n;
		d += n;
  800ced:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cf0:	89 d6                	mov    %edx,%esi
  800cf2:	09 fe                	or     %edi,%esi
  800cf4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800cfa:	75 13                	jne    800d0f <memmove+0x3b>
  800cfc:	f6 c1 03             	test   $0x3,%cl
  800cff:	75 0e                	jne    800d0f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800d01:	83 ef 04             	sub    $0x4,%edi
  800d04:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d07:	c1 e9 02             	shr    $0x2,%ecx
  800d0a:	fd                   	std    
  800d0b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d0d:	eb 09                	jmp    800d18 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d0f:	83 ef 01             	sub    $0x1,%edi
  800d12:	8d 72 ff             	lea    -0x1(%edx),%esi
  800d15:	fd                   	std    
  800d16:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d18:	fc                   	cld    
  800d19:	eb 1d                	jmp    800d38 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d1b:	89 f2                	mov    %esi,%edx
  800d1d:	09 c2                	or     %eax,%edx
  800d1f:	f6 c2 03             	test   $0x3,%dl
  800d22:	75 0f                	jne    800d33 <memmove+0x5f>
  800d24:	f6 c1 03             	test   $0x3,%cl
  800d27:	75 0a                	jne    800d33 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800d29:	c1 e9 02             	shr    $0x2,%ecx
  800d2c:	89 c7                	mov    %eax,%edi
  800d2e:	fc                   	cld    
  800d2f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d31:	eb 05                	jmp    800d38 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d33:	89 c7                	mov    %eax,%edi
  800d35:	fc                   	cld    
  800d36:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d38:	5e                   	pop    %esi
  800d39:	5f                   	pop    %edi
  800d3a:	5d                   	pop    %ebp
  800d3b:	c3                   	ret    

00800d3c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d3c:	55                   	push   %ebp
  800d3d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800d3f:	ff 75 10             	pushl  0x10(%ebp)
  800d42:	ff 75 0c             	pushl  0xc(%ebp)
  800d45:	ff 75 08             	pushl  0x8(%ebp)
  800d48:	e8 87 ff ff ff       	call   800cd4 <memmove>
}
  800d4d:	c9                   	leave  
  800d4e:	c3                   	ret    

00800d4f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d4f:	55                   	push   %ebp
  800d50:	89 e5                	mov    %esp,%ebp
  800d52:	56                   	push   %esi
  800d53:	53                   	push   %ebx
  800d54:	8b 45 08             	mov    0x8(%ebp),%eax
  800d57:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d5a:	89 c6                	mov    %eax,%esi
  800d5c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d5f:	eb 1a                	jmp    800d7b <memcmp+0x2c>
		if (*s1 != *s2)
  800d61:	0f b6 08             	movzbl (%eax),%ecx
  800d64:	0f b6 1a             	movzbl (%edx),%ebx
  800d67:	38 d9                	cmp    %bl,%cl
  800d69:	74 0a                	je     800d75 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800d6b:	0f b6 c1             	movzbl %cl,%eax
  800d6e:	0f b6 db             	movzbl %bl,%ebx
  800d71:	29 d8                	sub    %ebx,%eax
  800d73:	eb 0f                	jmp    800d84 <memcmp+0x35>
		s1++, s2++;
  800d75:	83 c0 01             	add    $0x1,%eax
  800d78:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d7b:	39 f0                	cmp    %esi,%eax
  800d7d:	75 e2                	jne    800d61 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d7f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d84:	5b                   	pop    %ebx
  800d85:	5e                   	pop    %esi
  800d86:	5d                   	pop    %ebp
  800d87:	c3                   	ret    

00800d88 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d88:	55                   	push   %ebp
  800d89:	89 e5                	mov    %esp,%ebp
  800d8b:	53                   	push   %ebx
  800d8c:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800d8f:	89 c1                	mov    %eax,%ecx
  800d91:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800d94:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d98:	eb 0a                	jmp    800da4 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d9a:	0f b6 10             	movzbl (%eax),%edx
  800d9d:	39 da                	cmp    %ebx,%edx
  800d9f:	74 07                	je     800da8 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800da1:	83 c0 01             	add    $0x1,%eax
  800da4:	39 c8                	cmp    %ecx,%eax
  800da6:	72 f2                	jb     800d9a <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800da8:	5b                   	pop    %ebx
  800da9:	5d                   	pop    %ebp
  800daa:	c3                   	ret    

00800dab <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800dab:	55                   	push   %ebp
  800dac:	89 e5                	mov    %esp,%ebp
  800dae:	57                   	push   %edi
  800daf:	56                   	push   %esi
  800db0:	53                   	push   %ebx
  800db1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800db4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800db7:	eb 03                	jmp    800dbc <strtol+0x11>
		s++;
  800db9:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800dbc:	0f b6 01             	movzbl (%ecx),%eax
  800dbf:	3c 20                	cmp    $0x20,%al
  800dc1:	74 f6                	je     800db9 <strtol+0xe>
  800dc3:	3c 09                	cmp    $0x9,%al
  800dc5:	74 f2                	je     800db9 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800dc7:	3c 2b                	cmp    $0x2b,%al
  800dc9:	75 0a                	jne    800dd5 <strtol+0x2a>
		s++;
  800dcb:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800dce:	bf 00 00 00 00       	mov    $0x0,%edi
  800dd3:	eb 11                	jmp    800de6 <strtol+0x3b>
  800dd5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800dda:	3c 2d                	cmp    $0x2d,%al
  800ddc:	75 08                	jne    800de6 <strtol+0x3b>
		s++, neg = 1;
  800dde:	83 c1 01             	add    $0x1,%ecx
  800de1:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800de6:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800dec:	75 15                	jne    800e03 <strtol+0x58>
  800dee:	80 39 30             	cmpb   $0x30,(%ecx)
  800df1:	75 10                	jne    800e03 <strtol+0x58>
  800df3:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800df7:	75 7c                	jne    800e75 <strtol+0xca>
		s += 2, base = 16;
  800df9:	83 c1 02             	add    $0x2,%ecx
  800dfc:	bb 10 00 00 00       	mov    $0x10,%ebx
  800e01:	eb 16                	jmp    800e19 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800e03:	85 db                	test   %ebx,%ebx
  800e05:	75 12                	jne    800e19 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800e07:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e0c:	80 39 30             	cmpb   $0x30,(%ecx)
  800e0f:	75 08                	jne    800e19 <strtol+0x6e>
		s++, base = 8;
  800e11:	83 c1 01             	add    $0x1,%ecx
  800e14:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800e19:	b8 00 00 00 00       	mov    $0x0,%eax
  800e1e:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e21:	0f b6 11             	movzbl (%ecx),%edx
  800e24:	8d 72 d0             	lea    -0x30(%edx),%esi
  800e27:	89 f3                	mov    %esi,%ebx
  800e29:	80 fb 09             	cmp    $0x9,%bl
  800e2c:	77 08                	ja     800e36 <strtol+0x8b>
			dig = *s - '0';
  800e2e:	0f be d2             	movsbl %dl,%edx
  800e31:	83 ea 30             	sub    $0x30,%edx
  800e34:	eb 22                	jmp    800e58 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800e36:	8d 72 9f             	lea    -0x61(%edx),%esi
  800e39:	89 f3                	mov    %esi,%ebx
  800e3b:	80 fb 19             	cmp    $0x19,%bl
  800e3e:	77 08                	ja     800e48 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800e40:	0f be d2             	movsbl %dl,%edx
  800e43:	83 ea 57             	sub    $0x57,%edx
  800e46:	eb 10                	jmp    800e58 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800e48:	8d 72 bf             	lea    -0x41(%edx),%esi
  800e4b:	89 f3                	mov    %esi,%ebx
  800e4d:	80 fb 19             	cmp    $0x19,%bl
  800e50:	77 16                	ja     800e68 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800e52:	0f be d2             	movsbl %dl,%edx
  800e55:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800e58:	3b 55 10             	cmp    0x10(%ebp),%edx
  800e5b:	7d 0b                	jge    800e68 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800e5d:	83 c1 01             	add    $0x1,%ecx
  800e60:	0f af 45 10          	imul   0x10(%ebp),%eax
  800e64:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800e66:	eb b9                	jmp    800e21 <strtol+0x76>

	if (endptr)
  800e68:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e6c:	74 0d                	je     800e7b <strtol+0xd0>
		*endptr = (char *) s;
  800e6e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e71:	89 0e                	mov    %ecx,(%esi)
  800e73:	eb 06                	jmp    800e7b <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e75:	85 db                	test   %ebx,%ebx
  800e77:	74 98                	je     800e11 <strtol+0x66>
  800e79:	eb 9e                	jmp    800e19 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800e7b:	89 c2                	mov    %eax,%edx
  800e7d:	f7 da                	neg    %edx
  800e7f:	85 ff                	test   %edi,%edi
  800e81:	0f 45 c2             	cmovne %edx,%eax
}
  800e84:	5b                   	pop    %ebx
  800e85:	5e                   	pop    %esi
  800e86:	5f                   	pop    %edi
  800e87:	5d                   	pop    %ebp
  800e88:	c3                   	ret    

00800e89 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800e89:	55                   	push   %ebp
  800e8a:	89 e5                	mov    %esp,%ebp
  800e8c:	57                   	push   %edi
  800e8d:	56                   	push   %esi
  800e8e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8f:	b8 00 00 00 00       	mov    $0x0,%eax
  800e94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e97:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9a:	89 c3                	mov    %eax,%ebx
  800e9c:	89 c7                	mov    %eax,%edi
  800e9e:	89 c6                	mov    %eax,%esi
  800ea0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ea2:	5b                   	pop    %ebx
  800ea3:	5e                   	pop    %esi
  800ea4:	5f                   	pop    %edi
  800ea5:	5d                   	pop    %ebp
  800ea6:	c3                   	ret    

00800ea7 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ea7:	55                   	push   %ebp
  800ea8:	89 e5                	mov    %esp,%ebp
  800eaa:	57                   	push   %edi
  800eab:	56                   	push   %esi
  800eac:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ead:	ba 00 00 00 00       	mov    $0x0,%edx
  800eb2:	b8 01 00 00 00       	mov    $0x1,%eax
  800eb7:	89 d1                	mov    %edx,%ecx
  800eb9:	89 d3                	mov    %edx,%ebx
  800ebb:	89 d7                	mov    %edx,%edi
  800ebd:	89 d6                	mov    %edx,%esi
  800ebf:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ec1:	5b                   	pop    %ebx
  800ec2:	5e                   	pop    %esi
  800ec3:	5f                   	pop    %edi
  800ec4:	5d                   	pop    %ebp
  800ec5:	c3                   	ret    

00800ec6 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ec6:	55                   	push   %ebp
  800ec7:	89 e5                	mov    %esp,%ebp
  800ec9:	57                   	push   %edi
  800eca:	56                   	push   %esi
  800ecb:	53                   	push   %ebx
  800ecc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ecf:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ed4:	b8 03 00 00 00       	mov    $0x3,%eax
  800ed9:	8b 55 08             	mov    0x8(%ebp),%edx
  800edc:	89 cb                	mov    %ecx,%ebx
  800ede:	89 cf                	mov    %ecx,%edi
  800ee0:	89 ce                	mov    %ecx,%esi
  800ee2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ee4:	85 c0                	test   %eax,%eax
  800ee6:	7e 17                	jle    800eff <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee8:	83 ec 0c             	sub    $0xc,%esp
  800eeb:	50                   	push   %eax
  800eec:	6a 03                	push   $0x3
  800eee:	68 1f 2e 80 00       	push   $0x802e1f
  800ef3:	6a 23                	push   $0x23
  800ef5:	68 3c 2e 80 00       	push   $0x802e3c
  800efa:	e8 e5 f5 ff ff       	call   8004e4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800eff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f02:	5b                   	pop    %ebx
  800f03:	5e                   	pop    %esi
  800f04:	5f                   	pop    %edi
  800f05:	5d                   	pop    %ebp
  800f06:	c3                   	ret    

00800f07 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800f07:	55                   	push   %ebp
  800f08:	89 e5                	mov    %esp,%ebp
  800f0a:	57                   	push   %edi
  800f0b:	56                   	push   %esi
  800f0c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f0d:	ba 00 00 00 00       	mov    $0x0,%edx
  800f12:	b8 02 00 00 00       	mov    $0x2,%eax
  800f17:	89 d1                	mov    %edx,%ecx
  800f19:	89 d3                	mov    %edx,%ebx
  800f1b:	89 d7                	mov    %edx,%edi
  800f1d:	89 d6                	mov    %edx,%esi
  800f1f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f21:	5b                   	pop    %ebx
  800f22:	5e                   	pop    %esi
  800f23:	5f                   	pop    %edi
  800f24:	5d                   	pop    %ebp
  800f25:	c3                   	ret    

00800f26 <sys_yield>:

void
sys_yield(void)
{
  800f26:	55                   	push   %ebp
  800f27:	89 e5                	mov    %esp,%ebp
  800f29:	57                   	push   %edi
  800f2a:	56                   	push   %esi
  800f2b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f2c:	ba 00 00 00 00       	mov    $0x0,%edx
  800f31:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f36:	89 d1                	mov    %edx,%ecx
  800f38:	89 d3                	mov    %edx,%ebx
  800f3a:	89 d7                	mov    %edx,%edi
  800f3c:	89 d6                	mov    %edx,%esi
  800f3e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f40:	5b                   	pop    %ebx
  800f41:	5e                   	pop    %esi
  800f42:	5f                   	pop    %edi
  800f43:	5d                   	pop    %ebp
  800f44:	c3                   	ret    

00800f45 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f45:	55                   	push   %ebp
  800f46:	89 e5                	mov    %esp,%ebp
  800f48:	57                   	push   %edi
  800f49:	56                   	push   %esi
  800f4a:	53                   	push   %ebx
  800f4b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f4e:	be 00 00 00 00       	mov    $0x0,%esi
  800f53:	b8 04 00 00 00       	mov    $0x4,%eax
  800f58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f5e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f61:	89 f7                	mov    %esi,%edi
  800f63:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f65:	85 c0                	test   %eax,%eax
  800f67:	7e 17                	jle    800f80 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f69:	83 ec 0c             	sub    $0xc,%esp
  800f6c:	50                   	push   %eax
  800f6d:	6a 04                	push   $0x4
  800f6f:	68 1f 2e 80 00       	push   $0x802e1f
  800f74:	6a 23                	push   $0x23
  800f76:	68 3c 2e 80 00       	push   $0x802e3c
  800f7b:	e8 64 f5 ff ff       	call   8004e4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f83:	5b                   	pop    %ebx
  800f84:	5e                   	pop    %esi
  800f85:	5f                   	pop    %edi
  800f86:	5d                   	pop    %ebp
  800f87:	c3                   	ret    

00800f88 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f88:	55                   	push   %ebp
  800f89:	89 e5                	mov    %esp,%ebp
  800f8b:	57                   	push   %edi
  800f8c:	56                   	push   %esi
  800f8d:	53                   	push   %ebx
  800f8e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f91:	b8 05 00 00 00       	mov    $0x5,%eax
  800f96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f99:	8b 55 08             	mov    0x8(%ebp),%edx
  800f9c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f9f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fa2:	8b 75 18             	mov    0x18(%ebp),%esi
  800fa5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fa7:	85 c0                	test   %eax,%eax
  800fa9:	7e 17                	jle    800fc2 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fab:	83 ec 0c             	sub    $0xc,%esp
  800fae:	50                   	push   %eax
  800faf:	6a 05                	push   $0x5
  800fb1:	68 1f 2e 80 00       	push   $0x802e1f
  800fb6:	6a 23                	push   $0x23
  800fb8:	68 3c 2e 80 00       	push   $0x802e3c
  800fbd:	e8 22 f5 ff ff       	call   8004e4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800fc2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fc5:	5b                   	pop    %ebx
  800fc6:	5e                   	pop    %esi
  800fc7:	5f                   	pop    %edi
  800fc8:	5d                   	pop    %ebp
  800fc9:	c3                   	ret    

00800fca <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800fca:	55                   	push   %ebp
  800fcb:	89 e5                	mov    %esp,%ebp
  800fcd:	57                   	push   %edi
  800fce:	56                   	push   %esi
  800fcf:	53                   	push   %ebx
  800fd0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fd3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fd8:	b8 06 00 00 00       	mov    $0x6,%eax
  800fdd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fe0:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe3:	89 df                	mov    %ebx,%edi
  800fe5:	89 de                	mov    %ebx,%esi
  800fe7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fe9:	85 c0                	test   %eax,%eax
  800feb:	7e 17                	jle    801004 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fed:	83 ec 0c             	sub    $0xc,%esp
  800ff0:	50                   	push   %eax
  800ff1:	6a 06                	push   $0x6
  800ff3:	68 1f 2e 80 00       	push   $0x802e1f
  800ff8:	6a 23                	push   $0x23
  800ffa:	68 3c 2e 80 00       	push   $0x802e3c
  800fff:	e8 e0 f4 ff ff       	call   8004e4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801004:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801007:	5b                   	pop    %ebx
  801008:	5e                   	pop    %esi
  801009:	5f                   	pop    %edi
  80100a:	5d                   	pop    %ebp
  80100b:	c3                   	ret    

0080100c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80100c:	55                   	push   %ebp
  80100d:	89 e5                	mov    %esp,%ebp
  80100f:	57                   	push   %edi
  801010:	56                   	push   %esi
  801011:	53                   	push   %ebx
  801012:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801015:	bb 00 00 00 00       	mov    $0x0,%ebx
  80101a:	b8 08 00 00 00       	mov    $0x8,%eax
  80101f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801022:	8b 55 08             	mov    0x8(%ebp),%edx
  801025:	89 df                	mov    %ebx,%edi
  801027:	89 de                	mov    %ebx,%esi
  801029:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80102b:	85 c0                	test   %eax,%eax
  80102d:	7e 17                	jle    801046 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80102f:	83 ec 0c             	sub    $0xc,%esp
  801032:	50                   	push   %eax
  801033:	6a 08                	push   $0x8
  801035:	68 1f 2e 80 00       	push   $0x802e1f
  80103a:	6a 23                	push   $0x23
  80103c:	68 3c 2e 80 00       	push   $0x802e3c
  801041:	e8 9e f4 ff ff       	call   8004e4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801046:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801049:	5b                   	pop    %ebx
  80104a:	5e                   	pop    %esi
  80104b:	5f                   	pop    %edi
  80104c:	5d                   	pop    %ebp
  80104d:	c3                   	ret    

0080104e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80104e:	55                   	push   %ebp
  80104f:	89 e5                	mov    %esp,%ebp
  801051:	57                   	push   %edi
  801052:	56                   	push   %esi
  801053:	53                   	push   %ebx
  801054:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801057:	bb 00 00 00 00       	mov    $0x0,%ebx
  80105c:	b8 09 00 00 00       	mov    $0x9,%eax
  801061:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801064:	8b 55 08             	mov    0x8(%ebp),%edx
  801067:	89 df                	mov    %ebx,%edi
  801069:	89 de                	mov    %ebx,%esi
  80106b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80106d:	85 c0                	test   %eax,%eax
  80106f:	7e 17                	jle    801088 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801071:	83 ec 0c             	sub    $0xc,%esp
  801074:	50                   	push   %eax
  801075:	6a 09                	push   $0x9
  801077:	68 1f 2e 80 00       	push   $0x802e1f
  80107c:	6a 23                	push   $0x23
  80107e:	68 3c 2e 80 00       	push   $0x802e3c
  801083:	e8 5c f4 ff ff       	call   8004e4 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801088:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80108b:	5b                   	pop    %ebx
  80108c:	5e                   	pop    %esi
  80108d:	5f                   	pop    %edi
  80108e:	5d                   	pop    %ebp
  80108f:	c3                   	ret    

00801090 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801090:	55                   	push   %ebp
  801091:	89 e5                	mov    %esp,%ebp
  801093:	57                   	push   %edi
  801094:	56                   	push   %esi
  801095:	53                   	push   %ebx
  801096:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801099:	bb 00 00 00 00       	mov    $0x0,%ebx
  80109e:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8010a9:	89 df                	mov    %ebx,%edi
  8010ab:	89 de                	mov    %ebx,%esi
  8010ad:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010af:	85 c0                	test   %eax,%eax
  8010b1:	7e 17                	jle    8010ca <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010b3:	83 ec 0c             	sub    $0xc,%esp
  8010b6:	50                   	push   %eax
  8010b7:	6a 0a                	push   $0xa
  8010b9:	68 1f 2e 80 00       	push   $0x802e1f
  8010be:	6a 23                	push   $0x23
  8010c0:	68 3c 2e 80 00       	push   $0x802e3c
  8010c5:	e8 1a f4 ff ff       	call   8004e4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8010ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010cd:	5b                   	pop    %ebx
  8010ce:	5e                   	pop    %esi
  8010cf:	5f                   	pop    %edi
  8010d0:	5d                   	pop    %ebp
  8010d1:	c3                   	ret    

008010d2 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010d2:	55                   	push   %ebp
  8010d3:	89 e5                	mov    %esp,%ebp
  8010d5:	57                   	push   %edi
  8010d6:	56                   	push   %esi
  8010d7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010d8:	be 00 00 00 00       	mov    $0x0,%esi
  8010dd:	b8 0c 00 00 00       	mov    $0xc,%eax
  8010e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8010e8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010eb:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010ee:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8010f0:	5b                   	pop    %ebx
  8010f1:	5e                   	pop    %esi
  8010f2:	5f                   	pop    %edi
  8010f3:	5d                   	pop    %ebp
  8010f4:	c3                   	ret    

008010f5 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8010f5:	55                   	push   %ebp
  8010f6:	89 e5                	mov    %esp,%ebp
  8010f8:	57                   	push   %edi
  8010f9:	56                   	push   %esi
  8010fa:	53                   	push   %ebx
  8010fb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010fe:	b9 00 00 00 00       	mov    $0x0,%ecx
  801103:	b8 0d 00 00 00       	mov    $0xd,%eax
  801108:	8b 55 08             	mov    0x8(%ebp),%edx
  80110b:	89 cb                	mov    %ecx,%ebx
  80110d:	89 cf                	mov    %ecx,%edi
  80110f:	89 ce                	mov    %ecx,%esi
  801111:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801113:	85 c0                	test   %eax,%eax
  801115:	7e 17                	jle    80112e <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801117:	83 ec 0c             	sub    $0xc,%esp
  80111a:	50                   	push   %eax
  80111b:	6a 0d                	push   $0xd
  80111d:	68 1f 2e 80 00       	push   $0x802e1f
  801122:	6a 23                	push   $0x23
  801124:	68 3c 2e 80 00       	push   $0x802e3c
  801129:	e8 b6 f3 ff ff       	call   8004e4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80112e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801131:	5b                   	pop    %ebx
  801132:	5e                   	pop    %esi
  801133:	5f                   	pop    %edi
  801134:	5d                   	pop    %ebp
  801135:	c3                   	ret    

00801136 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  801136:	55                   	push   %ebp
  801137:	89 e5                	mov    %esp,%ebp
  801139:	53                   	push   %ebx
  80113a:	83 ec 04             	sub    $0x4,%esp
	int r;
	void * address = (void *)(pn*PGSIZE);
  80113d:	89 d3                	mov    %edx,%ebx
  80113f:	c1 e3 0c             	shl    $0xc,%ebx
	
	if((uvpt[pn] & PTE_SHARE))
  801142:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  801149:	f6 c5 04             	test   $0x4,%ch
  80114c:	74 38                	je     801186 <duppage+0x50>
	{
		if ((r = sys_page_map(0, address, envid, address, (uvpt[pn] | PTE_SYSCALL))) < 0)
  80114e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801155:	83 ec 0c             	sub    $0xc,%esp
  801158:	81 ca 07 0e 00 00    	or     $0xe07,%edx
  80115e:	52                   	push   %edx
  80115f:	53                   	push   %ebx
  801160:	50                   	push   %eax
  801161:	53                   	push   %ebx
  801162:	6a 00                	push   $0x0
  801164:	e8 1f fe ff ff       	call   800f88 <sys_page_map>
  801169:	83 c4 20             	add    $0x20,%esp
  80116c:	85 c0                	test   %eax,%eax
  80116e:	0f 89 b8 00 00 00    	jns    80122c <duppage+0xf6>
			panic("sys_page_map: %e", r);
  801174:	50                   	push   %eax
  801175:	68 4a 2e 80 00       	push   $0x802e4a
  80117a:	6a 4e                	push   $0x4e
  80117c:	68 5b 2e 80 00       	push   $0x802e5b
  801181:	e8 5e f3 ff ff       	call   8004e4 <_panic>
	}
	else if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW))
  801186:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  80118d:	f6 c1 02             	test   $0x2,%cl
  801190:	75 0c                	jne    80119e <duppage+0x68>
  801192:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  801199:	f6 c5 08             	test   $0x8,%ch
  80119c:	74 57                	je     8011f5 <duppage+0xbf>
	{
		int perm = 0;
		perm |= PTE_P|PTE_U|PTE_COW;
	
		if ((r = sys_page_map(0, address, envid, address, perm)) < 0)
  80119e:	83 ec 0c             	sub    $0xc,%esp
  8011a1:	68 05 08 00 00       	push   $0x805
  8011a6:	53                   	push   %ebx
  8011a7:	50                   	push   %eax
  8011a8:	53                   	push   %ebx
  8011a9:	6a 00                	push   $0x0
  8011ab:	e8 d8 fd ff ff       	call   800f88 <sys_page_map>
  8011b0:	83 c4 20             	add    $0x20,%esp
  8011b3:	85 c0                	test   %eax,%eax
  8011b5:	79 12                	jns    8011c9 <duppage+0x93>
			panic("sys_page_map: %e", r);
  8011b7:	50                   	push   %eax
  8011b8:	68 4a 2e 80 00       	push   $0x802e4a
  8011bd:	6a 56                	push   $0x56
  8011bf:	68 5b 2e 80 00       	push   $0x802e5b
  8011c4:	e8 1b f3 ff ff       	call   8004e4 <_panic>
		if ((r = sys_page_map(0, address, 0, address, perm)) < 0)
  8011c9:	83 ec 0c             	sub    $0xc,%esp
  8011cc:	68 05 08 00 00       	push   $0x805
  8011d1:	53                   	push   %ebx
  8011d2:	6a 00                	push   $0x0
  8011d4:	53                   	push   %ebx
  8011d5:	6a 00                	push   $0x0
  8011d7:	e8 ac fd ff ff       	call   800f88 <sys_page_map>
  8011dc:	83 c4 20             	add    $0x20,%esp
  8011df:	85 c0                	test   %eax,%eax
  8011e1:	79 49                	jns    80122c <duppage+0xf6>
			panic("sys_page_map: %e", r);
  8011e3:	50                   	push   %eax
  8011e4:	68 4a 2e 80 00       	push   $0x802e4a
  8011e9:	6a 58                	push   $0x58
  8011eb:	68 5b 2e 80 00       	push   $0x802e5b
  8011f0:	e8 ef f2 ff ff       	call   8004e4 <_panic>
	}
	else if((uvpt[pn] & ~PTE_U) == 0)
  8011f5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011fc:	f7 c2 fb ff ff ff    	test   $0xfffffffb,%edx
  801202:	75 28                	jne    80122c <duppage+0xf6>
	{
		//cprintf("im here");
		if ((r = sys_page_map(0, address, envid, address, PTE_P|PTE_U)) < 0)
  801204:	83 ec 0c             	sub    $0xc,%esp
  801207:	6a 05                	push   $0x5
  801209:	53                   	push   %ebx
  80120a:	50                   	push   %eax
  80120b:	53                   	push   %ebx
  80120c:	6a 00                	push   $0x0
  80120e:	e8 75 fd ff ff       	call   800f88 <sys_page_map>
  801213:	83 c4 20             	add    $0x20,%esp
  801216:	85 c0                	test   %eax,%eax
  801218:	79 12                	jns    80122c <duppage+0xf6>
			panic("sys_page_map: %e", r);	
  80121a:	50                   	push   %eax
  80121b:	68 4a 2e 80 00       	push   $0x802e4a
  801220:	6a 5e                	push   $0x5e
  801222:	68 5b 2e 80 00       	push   $0x802e5b
  801227:	e8 b8 f2 ff ff       	call   8004e4 <_panic>
	}
	return 0;
}
  80122c:	b8 00 00 00 00       	mov    $0x0,%eax
  801231:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801234:	c9                   	leave  
  801235:	c3                   	ret    

00801236 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801236:	55                   	push   %ebp
  801237:	89 e5                	mov    %esp,%ebp
  801239:	53                   	push   %ebx
  80123a:	83 ec 08             	sub    $0x8,%esp
	void *addr = (void *) utf->utf_fault_va;
  80123d:	8b 45 08             	mov    0x8(%ebp),%eax
  801240:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	unsigned pn = ((uint32_t)addr)/PGSIZE;
  801242:	89 d8                	mov    %ebx,%eax
  801244:	c1 e8 0c             	shr    $0xc,%eax
	pte_t pte = uvpt[pn];
  801247:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// Allocate a new page, mapped at temp location
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  80124e:	6a 07                	push   $0x7
  801250:	68 00 f0 7f 00       	push   $0x7ff000
  801255:	6a 00                	push   $0x0
  801257:	e8 e9 fc ff ff       	call   800f45 <sys_page_alloc>
  80125c:	83 c4 10             	add    $0x10,%esp
  80125f:	85 c0                	test   %eax,%eax
  801261:	79 12                	jns    801275 <pgfault+0x3f>
		panic("sys_page_alloc: %e", r);
  801263:	50                   	push   %eax
  801264:	68 66 2e 80 00       	push   $0x802e66
  801269:	6a 2b                	push   $0x2b
  80126b:	68 5b 2e 80 00       	push   $0x802e5b
  801270:	e8 6f f2 ff ff       	call   8004e4 <_panic>

	// Copy the data from the old page to this new page
	void *addr_pgstart = (void *) ROUNDDOWN(addr, PGSIZE);
  801275:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr_pgstart, PGSIZE);
  80127b:	83 ec 04             	sub    $0x4,%esp
  80127e:	68 00 10 00 00       	push   $0x1000
  801283:	53                   	push   %ebx
  801284:	68 00 f0 7f 00       	push   $0x7ff000
  801289:	e8 46 fa ff ff       	call   800cd4 <memmove>

	// Move the new page to the old page's address
	if ((r = sys_page_map(0, PFTEMP, 0, addr_pgstart, PTE_P|PTE_U|PTE_W)) < 0)
  80128e:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801295:	53                   	push   %ebx
  801296:	6a 00                	push   $0x0
  801298:	68 00 f0 7f 00       	push   $0x7ff000
  80129d:	6a 00                	push   $0x0
  80129f:	e8 e4 fc ff ff       	call   800f88 <sys_page_map>
  8012a4:	83 c4 20             	add    $0x20,%esp
  8012a7:	85 c0                	test   %eax,%eax
  8012a9:	79 12                	jns    8012bd <pgfault+0x87>
		panic("sys_page_map: %e", r);
  8012ab:	50                   	push   %eax
  8012ac:	68 4a 2e 80 00       	push   $0x802e4a
  8012b1:	6a 33                	push   $0x33
  8012b3:	68 5b 2e 80 00       	push   $0x802e5b
  8012b8:	e8 27 f2 ff ff       	call   8004e4 <_panic>

	// Unmap the temp location
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  8012bd:	83 ec 08             	sub    $0x8,%esp
  8012c0:	68 00 f0 7f 00       	push   $0x7ff000
  8012c5:	6a 00                	push   $0x0
  8012c7:	e8 fe fc ff ff       	call   800fca <sys_page_unmap>
  8012cc:	83 c4 10             	add    $0x10,%esp
  8012cf:	85 c0                	test   %eax,%eax
  8012d1:	79 12                	jns    8012e5 <pgfault+0xaf>
		panic("sys_page_unmap: %e", r);
  8012d3:	50                   	push   %eax
  8012d4:	68 79 2e 80 00       	push   $0x802e79
  8012d9:	6a 37                	push   $0x37
  8012db:	68 5b 2e 80 00       	push   $0x802e5b
  8012e0:	e8 ff f1 ff ff       	call   8004e4 <_panic>
}
  8012e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012e8:	c9                   	leave  
  8012e9:	c3                   	ret    

008012ea <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8012ea:	55                   	push   %ebp
  8012eb:	89 e5                	mov    %esp,%ebp
  8012ed:	56                   	push   %esi
  8012ee:	53                   	push   %ebx
  8012ef:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
	// Set up page fault handler
	set_pgfault_handler(&pgfault);
  8012f2:	68 36 12 80 00       	push   $0x801236
  8012f7:	e8 76 12 00 00       	call   802572 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8012fc:	b8 07 00 00 00       	mov    $0x7,%eax
  801301:	cd 30                	int    $0x30

	// Create child
	envid_t envid = sys_exofork();
  801303:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (envid < 0) {
  801306:	83 c4 10             	add    $0x10,%esp
  801309:	85 c0                	test   %eax,%eax
  80130b:	79 12                	jns    80131f <fork+0x35>
		panic("sys_exofork: %e", envid);
  80130d:	50                   	push   %eax
  80130e:	68 8c 2e 80 00       	push   $0x802e8c
  801313:	6a 7c                	push   $0x7c
  801315:	68 5b 2e 80 00       	push   $0x802e5b
  80131a:	e8 c5 f1 ff ff       	call   8004e4 <_panic>
		return envid;
	}
	if (envid == 0) {
  80131f:	85 c0                	test   %eax,%eax
  801321:	75 1e                	jne    801341 <fork+0x57>
		// We are the child.
		thisenv = &envs[ENVX(sys_getenvid())]; // Fix thisenv
  801323:	e8 df fb ff ff       	call   800f07 <sys_getenvid>
  801328:	25 ff 03 00 00       	and    $0x3ff,%eax
  80132d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801330:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801335:	a3 04 50 80 00       	mov    %eax,0x805004
		return 0;
  80133a:	b8 00 00 00 00       	mov    $0x0,%eax
  80133f:	eb 7d                	jmp    8013be <fork+0xd4>

	// Set page fault handler on the child.
	// The parent needs to do it, else the child wouldn't be able to handle
	// the fault when trying to access it's stack (which happens as soon it starts)
	extern void _pgfault_upcall(void);
	sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);
  801341:	83 ec 04             	sub    $0x4,%esp
  801344:	6a 07                	push   $0x7
  801346:	68 00 f0 bf ee       	push   $0xeebff000
  80134b:	50                   	push   %eax
  80134c:	e8 f4 fb ff ff       	call   800f45 <sys_page_alloc>
	sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  801351:	83 c4 08             	add    $0x8,%esp
  801354:	68 b7 25 80 00       	push   $0x8025b7
  801359:	ff 75 f4             	pushl  -0xc(%ebp)
  80135c:	e8 2f fd ff ff       	call   801090 <sys_env_set_pgfault_upcall>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  801361:	be 04 70 80 00       	mov    $0x807004,%esi
  801366:	c1 ee 0c             	shr    $0xc,%esi
  801369:	83 c4 10             	add    $0x10,%esp
  80136c:	bb 00 08 00 00       	mov    $0x800,%ebx
  801371:	eb 0d                	jmp    801380 <fork+0x96>
		duppage(envid, pn);
  801373:	89 da                	mov    %ebx,%edx
  801375:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801378:	e8 b9 fd ff ff       	call   801136 <duppage>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  80137d:	83 c3 01             	add    $0x1,%ebx
  801380:	39 f3                	cmp    %esi,%ebx
  801382:	76 ef                	jbe    801373 <fork+0x89>
	}

	// Also copy the stack we are currently running on
	// I think it should loop from ustacktop to this page, since the stack
	// can have more than 1 page
	duppage(envid, ((uint32_t) &envid)/PGSIZE);
  801384:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801387:	c1 ea 0c             	shr    $0xc,%edx
  80138a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80138d:	e8 a4 fd ff ff       	call   801136 <duppage>

	// Start the child environmnet running
	int r;
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  801392:	83 ec 08             	sub    $0x8,%esp
  801395:	6a 02                	push   $0x2
  801397:	ff 75 f4             	pushl  -0xc(%ebp)
  80139a:	e8 6d fc ff ff       	call   80100c <sys_env_set_status>
  80139f:	83 c4 10             	add    $0x10,%esp
  8013a2:	85 c0                	test   %eax,%eax
  8013a4:	79 15                	jns    8013bb <fork+0xd1>
		panic("sys_env_set_status: %e", r);
  8013a6:	50                   	push   %eax
  8013a7:	68 9c 2e 80 00       	push   $0x802e9c
  8013ac:	68 9c 00 00 00       	push   $0x9c
  8013b1:	68 5b 2e 80 00       	push   $0x802e5b
  8013b6:	e8 29 f1 ff ff       	call   8004e4 <_panic>
		return r;
	}

	return envid;
  8013bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8013be:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013c1:	5b                   	pop    %ebx
  8013c2:	5e                   	pop    %esi
  8013c3:	5d                   	pop    %ebp
  8013c4:	c3                   	ret    

008013c5 <sfork>:

// Challenge!
int
sfork(void)
{
  8013c5:	55                   	push   %ebp
  8013c6:	89 e5                	mov    %esp,%ebp
  8013c8:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8013cb:	68 b3 2e 80 00       	push   $0x802eb3
  8013d0:	68 a7 00 00 00       	push   $0xa7
  8013d5:	68 5b 2e 80 00       	push   $0x802e5b
  8013da:	e8 05 f1 ff ff       	call   8004e4 <_panic>

008013df <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8013df:	55                   	push   %ebp
  8013e0:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8013e5:	05 00 00 00 30       	add    $0x30000000,%eax
  8013ea:	c1 e8 0c             	shr    $0xc,%eax
}
  8013ed:	5d                   	pop    %ebp
  8013ee:	c3                   	ret    

008013ef <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8013ef:	55                   	push   %ebp
  8013f0:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8013f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f5:	05 00 00 00 30       	add    $0x30000000,%eax
  8013fa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8013ff:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801404:	5d                   	pop    %ebp
  801405:	c3                   	ret    

00801406 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801406:	55                   	push   %ebp
  801407:	89 e5                	mov    %esp,%ebp
  801409:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80140c:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801411:	89 c2                	mov    %eax,%edx
  801413:	c1 ea 16             	shr    $0x16,%edx
  801416:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80141d:	f6 c2 01             	test   $0x1,%dl
  801420:	74 11                	je     801433 <fd_alloc+0x2d>
  801422:	89 c2                	mov    %eax,%edx
  801424:	c1 ea 0c             	shr    $0xc,%edx
  801427:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80142e:	f6 c2 01             	test   $0x1,%dl
  801431:	75 09                	jne    80143c <fd_alloc+0x36>
			*fd_store = fd;
  801433:	89 01                	mov    %eax,(%ecx)
			return 0;
  801435:	b8 00 00 00 00       	mov    $0x0,%eax
  80143a:	eb 17                	jmp    801453 <fd_alloc+0x4d>
  80143c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801441:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801446:	75 c9                	jne    801411 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801448:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80144e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801453:	5d                   	pop    %ebp
  801454:	c3                   	ret    

00801455 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801455:	55                   	push   %ebp
  801456:	89 e5                	mov    %esp,%ebp
  801458:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80145b:	83 f8 1f             	cmp    $0x1f,%eax
  80145e:	77 36                	ja     801496 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801460:	c1 e0 0c             	shl    $0xc,%eax
  801463:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801468:	89 c2                	mov    %eax,%edx
  80146a:	c1 ea 16             	shr    $0x16,%edx
  80146d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801474:	f6 c2 01             	test   $0x1,%dl
  801477:	74 24                	je     80149d <fd_lookup+0x48>
  801479:	89 c2                	mov    %eax,%edx
  80147b:	c1 ea 0c             	shr    $0xc,%edx
  80147e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801485:	f6 c2 01             	test   $0x1,%dl
  801488:	74 1a                	je     8014a4 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80148a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80148d:	89 02                	mov    %eax,(%edx)
	return 0;
  80148f:	b8 00 00 00 00       	mov    $0x0,%eax
  801494:	eb 13                	jmp    8014a9 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801496:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80149b:	eb 0c                	jmp    8014a9 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80149d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014a2:	eb 05                	jmp    8014a9 <fd_lookup+0x54>
  8014a4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8014a9:	5d                   	pop    %ebp
  8014aa:	c3                   	ret    

008014ab <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8014ab:	55                   	push   %ebp
  8014ac:	89 e5                	mov    %esp,%ebp
  8014ae:	83 ec 08             	sub    $0x8,%esp
  8014b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014b4:	ba 48 2f 80 00       	mov    $0x802f48,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8014b9:	eb 13                	jmp    8014ce <dev_lookup+0x23>
  8014bb:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8014be:	39 08                	cmp    %ecx,(%eax)
  8014c0:	75 0c                	jne    8014ce <dev_lookup+0x23>
			*dev = devtab[i];
  8014c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014c5:	89 01                	mov    %eax,(%ecx)
			return 0;
  8014c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8014cc:	eb 2e                	jmp    8014fc <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8014ce:	8b 02                	mov    (%edx),%eax
  8014d0:	85 c0                	test   %eax,%eax
  8014d2:	75 e7                	jne    8014bb <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8014d4:	a1 04 50 80 00       	mov    0x805004,%eax
  8014d9:	8b 40 48             	mov    0x48(%eax),%eax
  8014dc:	83 ec 04             	sub    $0x4,%esp
  8014df:	51                   	push   %ecx
  8014e0:	50                   	push   %eax
  8014e1:	68 cc 2e 80 00       	push   $0x802ecc
  8014e6:	e8 d2 f0 ff ff       	call   8005bd <cprintf>
	*dev = 0;
  8014eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014ee:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8014f4:	83 c4 10             	add    $0x10,%esp
  8014f7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8014fc:	c9                   	leave  
  8014fd:	c3                   	ret    

008014fe <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8014fe:	55                   	push   %ebp
  8014ff:	89 e5                	mov    %esp,%ebp
  801501:	56                   	push   %esi
  801502:	53                   	push   %ebx
  801503:	83 ec 10             	sub    $0x10,%esp
  801506:	8b 75 08             	mov    0x8(%ebp),%esi
  801509:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80150c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80150f:	50                   	push   %eax
  801510:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801516:	c1 e8 0c             	shr    $0xc,%eax
  801519:	50                   	push   %eax
  80151a:	e8 36 ff ff ff       	call   801455 <fd_lookup>
  80151f:	83 c4 08             	add    $0x8,%esp
  801522:	85 c0                	test   %eax,%eax
  801524:	78 05                	js     80152b <fd_close+0x2d>
	    || fd != fd2)
  801526:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801529:	74 0c                	je     801537 <fd_close+0x39>
		return (must_exist ? r : 0);
  80152b:	84 db                	test   %bl,%bl
  80152d:	ba 00 00 00 00       	mov    $0x0,%edx
  801532:	0f 44 c2             	cmove  %edx,%eax
  801535:	eb 41                	jmp    801578 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801537:	83 ec 08             	sub    $0x8,%esp
  80153a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80153d:	50                   	push   %eax
  80153e:	ff 36                	pushl  (%esi)
  801540:	e8 66 ff ff ff       	call   8014ab <dev_lookup>
  801545:	89 c3                	mov    %eax,%ebx
  801547:	83 c4 10             	add    $0x10,%esp
  80154a:	85 c0                	test   %eax,%eax
  80154c:	78 1a                	js     801568 <fd_close+0x6a>
		if (dev->dev_close)
  80154e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801551:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801554:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801559:	85 c0                	test   %eax,%eax
  80155b:	74 0b                	je     801568 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80155d:	83 ec 0c             	sub    $0xc,%esp
  801560:	56                   	push   %esi
  801561:	ff d0                	call   *%eax
  801563:	89 c3                	mov    %eax,%ebx
  801565:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801568:	83 ec 08             	sub    $0x8,%esp
  80156b:	56                   	push   %esi
  80156c:	6a 00                	push   $0x0
  80156e:	e8 57 fa ff ff       	call   800fca <sys_page_unmap>
	return r;
  801573:	83 c4 10             	add    $0x10,%esp
  801576:	89 d8                	mov    %ebx,%eax
}
  801578:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80157b:	5b                   	pop    %ebx
  80157c:	5e                   	pop    %esi
  80157d:	5d                   	pop    %ebp
  80157e:	c3                   	ret    

0080157f <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80157f:	55                   	push   %ebp
  801580:	89 e5                	mov    %esp,%ebp
  801582:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801585:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801588:	50                   	push   %eax
  801589:	ff 75 08             	pushl  0x8(%ebp)
  80158c:	e8 c4 fe ff ff       	call   801455 <fd_lookup>
  801591:	83 c4 08             	add    $0x8,%esp
  801594:	85 c0                	test   %eax,%eax
  801596:	78 10                	js     8015a8 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801598:	83 ec 08             	sub    $0x8,%esp
  80159b:	6a 01                	push   $0x1
  80159d:	ff 75 f4             	pushl  -0xc(%ebp)
  8015a0:	e8 59 ff ff ff       	call   8014fe <fd_close>
  8015a5:	83 c4 10             	add    $0x10,%esp
}
  8015a8:	c9                   	leave  
  8015a9:	c3                   	ret    

008015aa <close_all>:

void
close_all(void)
{
  8015aa:	55                   	push   %ebp
  8015ab:	89 e5                	mov    %esp,%ebp
  8015ad:	53                   	push   %ebx
  8015ae:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8015b1:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8015b6:	83 ec 0c             	sub    $0xc,%esp
  8015b9:	53                   	push   %ebx
  8015ba:	e8 c0 ff ff ff       	call   80157f <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8015bf:	83 c3 01             	add    $0x1,%ebx
  8015c2:	83 c4 10             	add    $0x10,%esp
  8015c5:	83 fb 20             	cmp    $0x20,%ebx
  8015c8:	75 ec                	jne    8015b6 <close_all+0xc>
		close(i);
}
  8015ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015cd:	c9                   	leave  
  8015ce:	c3                   	ret    

008015cf <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8015cf:	55                   	push   %ebp
  8015d0:	89 e5                	mov    %esp,%ebp
  8015d2:	57                   	push   %edi
  8015d3:	56                   	push   %esi
  8015d4:	53                   	push   %ebx
  8015d5:	83 ec 2c             	sub    $0x2c,%esp
  8015d8:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8015db:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8015de:	50                   	push   %eax
  8015df:	ff 75 08             	pushl  0x8(%ebp)
  8015e2:	e8 6e fe ff ff       	call   801455 <fd_lookup>
  8015e7:	83 c4 08             	add    $0x8,%esp
  8015ea:	85 c0                	test   %eax,%eax
  8015ec:	0f 88 c1 00 00 00    	js     8016b3 <dup+0xe4>
		return r;
	close(newfdnum);
  8015f2:	83 ec 0c             	sub    $0xc,%esp
  8015f5:	56                   	push   %esi
  8015f6:	e8 84 ff ff ff       	call   80157f <close>

	newfd = INDEX2FD(newfdnum);
  8015fb:	89 f3                	mov    %esi,%ebx
  8015fd:	c1 e3 0c             	shl    $0xc,%ebx
  801600:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801606:	83 c4 04             	add    $0x4,%esp
  801609:	ff 75 e4             	pushl  -0x1c(%ebp)
  80160c:	e8 de fd ff ff       	call   8013ef <fd2data>
  801611:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801613:	89 1c 24             	mov    %ebx,(%esp)
  801616:	e8 d4 fd ff ff       	call   8013ef <fd2data>
  80161b:	83 c4 10             	add    $0x10,%esp
  80161e:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801621:	89 f8                	mov    %edi,%eax
  801623:	c1 e8 16             	shr    $0x16,%eax
  801626:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80162d:	a8 01                	test   $0x1,%al
  80162f:	74 37                	je     801668 <dup+0x99>
  801631:	89 f8                	mov    %edi,%eax
  801633:	c1 e8 0c             	shr    $0xc,%eax
  801636:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80163d:	f6 c2 01             	test   $0x1,%dl
  801640:	74 26                	je     801668 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801642:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801649:	83 ec 0c             	sub    $0xc,%esp
  80164c:	25 07 0e 00 00       	and    $0xe07,%eax
  801651:	50                   	push   %eax
  801652:	ff 75 d4             	pushl  -0x2c(%ebp)
  801655:	6a 00                	push   $0x0
  801657:	57                   	push   %edi
  801658:	6a 00                	push   $0x0
  80165a:	e8 29 f9 ff ff       	call   800f88 <sys_page_map>
  80165f:	89 c7                	mov    %eax,%edi
  801661:	83 c4 20             	add    $0x20,%esp
  801664:	85 c0                	test   %eax,%eax
  801666:	78 2e                	js     801696 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801668:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80166b:	89 d0                	mov    %edx,%eax
  80166d:	c1 e8 0c             	shr    $0xc,%eax
  801670:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801677:	83 ec 0c             	sub    $0xc,%esp
  80167a:	25 07 0e 00 00       	and    $0xe07,%eax
  80167f:	50                   	push   %eax
  801680:	53                   	push   %ebx
  801681:	6a 00                	push   $0x0
  801683:	52                   	push   %edx
  801684:	6a 00                	push   $0x0
  801686:	e8 fd f8 ff ff       	call   800f88 <sys_page_map>
  80168b:	89 c7                	mov    %eax,%edi
  80168d:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801690:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801692:	85 ff                	test   %edi,%edi
  801694:	79 1d                	jns    8016b3 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801696:	83 ec 08             	sub    $0x8,%esp
  801699:	53                   	push   %ebx
  80169a:	6a 00                	push   $0x0
  80169c:	e8 29 f9 ff ff       	call   800fca <sys_page_unmap>
	sys_page_unmap(0, nva);
  8016a1:	83 c4 08             	add    $0x8,%esp
  8016a4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8016a7:	6a 00                	push   $0x0
  8016a9:	e8 1c f9 ff ff       	call   800fca <sys_page_unmap>
	return r;
  8016ae:	83 c4 10             	add    $0x10,%esp
  8016b1:	89 f8                	mov    %edi,%eax
}
  8016b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016b6:	5b                   	pop    %ebx
  8016b7:	5e                   	pop    %esi
  8016b8:	5f                   	pop    %edi
  8016b9:	5d                   	pop    %ebp
  8016ba:	c3                   	ret    

008016bb <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8016bb:	55                   	push   %ebp
  8016bc:	89 e5                	mov    %esp,%ebp
  8016be:	53                   	push   %ebx
  8016bf:	83 ec 14             	sub    $0x14,%esp
  8016c2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016c5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016c8:	50                   	push   %eax
  8016c9:	53                   	push   %ebx
  8016ca:	e8 86 fd ff ff       	call   801455 <fd_lookup>
  8016cf:	83 c4 08             	add    $0x8,%esp
  8016d2:	89 c2                	mov    %eax,%edx
  8016d4:	85 c0                	test   %eax,%eax
  8016d6:	78 6d                	js     801745 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016d8:	83 ec 08             	sub    $0x8,%esp
  8016db:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016de:	50                   	push   %eax
  8016df:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016e2:	ff 30                	pushl  (%eax)
  8016e4:	e8 c2 fd ff ff       	call   8014ab <dev_lookup>
  8016e9:	83 c4 10             	add    $0x10,%esp
  8016ec:	85 c0                	test   %eax,%eax
  8016ee:	78 4c                	js     80173c <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8016f0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8016f3:	8b 42 08             	mov    0x8(%edx),%eax
  8016f6:	83 e0 03             	and    $0x3,%eax
  8016f9:	83 f8 01             	cmp    $0x1,%eax
  8016fc:	75 21                	jne    80171f <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8016fe:	a1 04 50 80 00       	mov    0x805004,%eax
  801703:	8b 40 48             	mov    0x48(%eax),%eax
  801706:	83 ec 04             	sub    $0x4,%esp
  801709:	53                   	push   %ebx
  80170a:	50                   	push   %eax
  80170b:	68 0d 2f 80 00       	push   $0x802f0d
  801710:	e8 a8 ee ff ff       	call   8005bd <cprintf>
		return -E_INVAL;
  801715:	83 c4 10             	add    $0x10,%esp
  801718:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80171d:	eb 26                	jmp    801745 <read+0x8a>
	}
	if (!dev->dev_read)
  80171f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801722:	8b 40 08             	mov    0x8(%eax),%eax
  801725:	85 c0                	test   %eax,%eax
  801727:	74 17                	je     801740 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801729:	83 ec 04             	sub    $0x4,%esp
  80172c:	ff 75 10             	pushl  0x10(%ebp)
  80172f:	ff 75 0c             	pushl  0xc(%ebp)
  801732:	52                   	push   %edx
  801733:	ff d0                	call   *%eax
  801735:	89 c2                	mov    %eax,%edx
  801737:	83 c4 10             	add    $0x10,%esp
  80173a:	eb 09                	jmp    801745 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80173c:	89 c2                	mov    %eax,%edx
  80173e:	eb 05                	jmp    801745 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801740:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801745:	89 d0                	mov    %edx,%eax
  801747:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80174a:	c9                   	leave  
  80174b:	c3                   	ret    

0080174c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80174c:	55                   	push   %ebp
  80174d:	89 e5                	mov    %esp,%ebp
  80174f:	57                   	push   %edi
  801750:	56                   	push   %esi
  801751:	53                   	push   %ebx
  801752:	83 ec 0c             	sub    $0xc,%esp
  801755:	8b 7d 08             	mov    0x8(%ebp),%edi
  801758:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80175b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801760:	eb 21                	jmp    801783 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801762:	83 ec 04             	sub    $0x4,%esp
  801765:	89 f0                	mov    %esi,%eax
  801767:	29 d8                	sub    %ebx,%eax
  801769:	50                   	push   %eax
  80176a:	89 d8                	mov    %ebx,%eax
  80176c:	03 45 0c             	add    0xc(%ebp),%eax
  80176f:	50                   	push   %eax
  801770:	57                   	push   %edi
  801771:	e8 45 ff ff ff       	call   8016bb <read>
		if (m < 0)
  801776:	83 c4 10             	add    $0x10,%esp
  801779:	85 c0                	test   %eax,%eax
  80177b:	78 10                	js     80178d <readn+0x41>
			return m;
		if (m == 0)
  80177d:	85 c0                	test   %eax,%eax
  80177f:	74 0a                	je     80178b <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801781:	01 c3                	add    %eax,%ebx
  801783:	39 f3                	cmp    %esi,%ebx
  801785:	72 db                	jb     801762 <readn+0x16>
  801787:	89 d8                	mov    %ebx,%eax
  801789:	eb 02                	jmp    80178d <readn+0x41>
  80178b:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80178d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801790:	5b                   	pop    %ebx
  801791:	5e                   	pop    %esi
  801792:	5f                   	pop    %edi
  801793:	5d                   	pop    %ebp
  801794:	c3                   	ret    

00801795 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801795:	55                   	push   %ebp
  801796:	89 e5                	mov    %esp,%ebp
  801798:	53                   	push   %ebx
  801799:	83 ec 14             	sub    $0x14,%esp
  80179c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80179f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017a2:	50                   	push   %eax
  8017a3:	53                   	push   %ebx
  8017a4:	e8 ac fc ff ff       	call   801455 <fd_lookup>
  8017a9:	83 c4 08             	add    $0x8,%esp
  8017ac:	89 c2                	mov    %eax,%edx
  8017ae:	85 c0                	test   %eax,%eax
  8017b0:	78 68                	js     80181a <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017b2:	83 ec 08             	sub    $0x8,%esp
  8017b5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017b8:	50                   	push   %eax
  8017b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017bc:	ff 30                	pushl  (%eax)
  8017be:	e8 e8 fc ff ff       	call   8014ab <dev_lookup>
  8017c3:	83 c4 10             	add    $0x10,%esp
  8017c6:	85 c0                	test   %eax,%eax
  8017c8:	78 47                	js     801811 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017cd:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017d1:	75 21                	jne    8017f4 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8017d3:	a1 04 50 80 00       	mov    0x805004,%eax
  8017d8:	8b 40 48             	mov    0x48(%eax),%eax
  8017db:	83 ec 04             	sub    $0x4,%esp
  8017de:	53                   	push   %ebx
  8017df:	50                   	push   %eax
  8017e0:	68 29 2f 80 00       	push   $0x802f29
  8017e5:	e8 d3 ed ff ff       	call   8005bd <cprintf>
		return -E_INVAL;
  8017ea:	83 c4 10             	add    $0x10,%esp
  8017ed:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017f2:	eb 26                	jmp    80181a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8017f4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017f7:	8b 52 0c             	mov    0xc(%edx),%edx
  8017fa:	85 d2                	test   %edx,%edx
  8017fc:	74 17                	je     801815 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8017fe:	83 ec 04             	sub    $0x4,%esp
  801801:	ff 75 10             	pushl  0x10(%ebp)
  801804:	ff 75 0c             	pushl  0xc(%ebp)
  801807:	50                   	push   %eax
  801808:	ff d2                	call   *%edx
  80180a:	89 c2                	mov    %eax,%edx
  80180c:	83 c4 10             	add    $0x10,%esp
  80180f:	eb 09                	jmp    80181a <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801811:	89 c2                	mov    %eax,%edx
  801813:	eb 05                	jmp    80181a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801815:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80181a:	89 d0                	mov    %edx,%eax
  80181c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80181f:	c9                   	leave  
  801820:	c3                   	ret    

00801821 <seek>:

int
seek(int fdnum, off_t offset)
{
  801821:	55                   	push   %ebp
  801822:	89 e5                	mov    %esp,%ebp
  801824:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801827:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80182a:	50                   	push   %eax
  80182b:	ff 75 08             	pushl  0x8(%ebp)
  80182e:	e8 22 fc ff ff       	call   801455 <fd_lookup>
  801833:	83 c4 08             	add    $0x8,%esp
  801836:	85 c0                	test   %eax,%eax
  801838:	78 0e                	js     801848 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80183a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80183d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801840:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801843:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801848:	c9                   	leave  
  801849:	c3                   	ret    

0080184a <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80184a:	55                   	push   %ebp
  80184b:	89 e5                	mov    %esp,%ebp
  80184d:	53                   	push   %ebx
  80184e:	83 ec 14             	sub    $0x14,%esp
  801851:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801854:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801857:	50                   	push   %eax
  801858:	53                   	push   %ebx
  801859:	e8 f7 fb ff ff       	call   801455 <fd_lookup>
  80185e:	83 c4 08             	add    $0x8,%esp
  801861:	89 c2                	mov    %eax,%edx
  801863:	85 c0                	test   %eax,%eax
  801865:	78 65                	js     8018cc <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801867:	83 ec 08             	sub    $0x8,%esp
  80186a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80186d:	50                   	push   %eax
  80186e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801871:	ff 30                	pushl  (%eax)
  801873:	e8 33 fc ff ff       	call   8014ab <dev_lookup>
  801878:	83 c4 10             	add    $0x10,%esp
  80187b:	85 c0                	test   %eax,%eax
  80187d:	78 44                	js     8018c3 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80187f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801882:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801886:	75 21                	jne    8018a9 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801888:	a1 04 50 80 00       	mov    0x805004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80188d:	8b 40 48             	mov    0x48(%eax),%eax
  801890:	83 ec 04             	sub    $0x4,%esp
  801893:	53                   	push   %ebx
  801894:	50                   	push   %eax
  801895:	68 ec 2e 80 00       	push   $0x802eec
  80189a:	e8 1e ed ff ff       	call   8005bd <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80189f:	83 c4 10             	add    $0x10,%esp
  8018a2:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8018a7:	eb 23                	jmp    8018cc <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8018a9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018ac:	8b 52 18             	mov    0x18(%edx),%edx
  8018af:	85 d2                	test   %edx,%edx
  8018b1:	74 14                	je     8018c7 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8018b3:	83 ec 08             	sub    $0x8,%esp
  8018b6:	ff 75 0c             	pushl  0xc(%ebp)
  8018b9:	50                   	push   %eax
  8018ba:	ff d2                	call   *%edx
  8018bc:	89 c2                	mov    %eax,%edx
  8018be:	83 c4 10             	add    $0x10,%esp
  8018c1:	eb 09                	jmp    8018cc <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018c3:	89 c2                	mov    %eax,%edx
  8018c5:	eb 05                	jmp    8018cc <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8018c7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8018cc:	89 d0                	mov    %edx,%eax
  8018ce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018d1:	c9                   	leave  
  8018d2:	c3                   	ret    

008018d3 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8018d3:	55                   	push   %ebp
  8018d4:	89 e5                	mov    %esp,%ebp
  8018d6:	53                   	push   %ebx
  8018d7:	83 ec 14             	sub    $0x14,%esp
  8018da:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018dd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018e0:	50                   	push   %eax
  8018e1:	ff 75 08             	pushl  0x8(%ebp)
  8018e4:	e8 6c fb ff ff       	call   801455 <fd_lookup>
  8018e9:	83 c4 08             	add    $0x8,%esp
  8018ec:	89 c2                	mov    %eax,%edx
  8018ee:	85 c0                	test   %eax,%eax
  8018f0:	78 58                	js     80194a <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018f2:	83 ec 08             	sub    $0x8,%esp
  8018f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018f8:	50                   	push   %eax
  8018f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018fc:	ff 30                	pushl  (%eax)
  8018fe:	e8 a8 fb ff ff       	call   8014ab <dev_lookup>
  801903:	83 c4 10             	add    $0x10,%esp
  801906:	85 c0                	test   %eax,%eax
  801908:	78 37                	js     801941 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80190a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80190d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801911:	74 32                	je     801945 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801913:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801916:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80191d:	00 00 00 
	stat->st_isdir = 0;
  801920:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801927:	00 00 00 
	stat->st_dev = dev;
  80192a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801930:	83 ec 08             	sub    $0x8,%esp
  801933:	53                   	push   %ebx
  801934:	ff 75 f0             	pushl  -0x10(%ebp)
  801937:	ff 50 14             	call   *0x14(%eax)
  80193a:	89 c2                	mov    %eax,%edx
  80193c:	83 c4 10             	add    $0x10,%esp
  80193f:	eb 09                	jmp    80194a <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801941:	89 c2                	mov    %eax,%edx
  801943:	eb 05                	jmp    80194a <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801945:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80194a:	89 d0                	mov    %edx,%eax
  80194c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80194f:	c9                   	leave  
  801950:	c3                   	ret    

00801951 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801951:	55                   	push   %ebp
  801952:	89 e5                	mov    %esp,%ebp
  801954:	56                   	push   %esi
  801955:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801956:	83 ec 08             	sub    $0x8,%esp
  801959:	6a 00                	push   $0x0
  80195b:	ff 75 08             	pushl  0x8(%ebp)
  80195e:	e8 0c 02 00 00       	call   801b6f <open>
  801963:	89 c3                	mov    %eax,%ebx
  801965:	83 c4 10             	add    $0x10,%esp
  801968:	85 c0                	test   %eax,%eax
  80196a:	78 1b                	js     801987 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80196c:	83 ec 08             	sub    $0x8,%esp
  80196f:	ff 75 0c             	pushl  0xc(%ebp)
  801972:	50                   	push   %eax
  801973:	e8 5b ff ff ff       	call   8018d3 <fstat>
  801978:	89 c6                	mov    %eax,%esi
	close(fd);
  80197a:	89 1c 24             	mov    %ebx,(%esp)
  80197d:	e8 fd fb ff ff       	call   80157f <close>
	return r;
  801982:	83 c4 10             	add    $0x10,%esp
  801985:	89 f0                	mov    %esi,%eax
}
  801987:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80198a:	5b                   	pop    %ebx
  80198b:	5e                   	pop    %esi
  80198c:	5d                   	pop    %ebp
  80198d:	c3                   	ret    

0080198e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80198e:	55                   	push   %ebp
  80198f:	89 e5                	mov    %esp,%ebp
  801991:	56                   	push   %esi
  801992:	53                   	push   %ebx
  801993:	89 c6                	mov    %eax,%esi
  801995:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801997:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80199e:	75 12                	jne    8019b2 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8019a0:	83 ec 0c             	sub    $0xc,%esp
  8019a3:	6a 01                	push   $0x1
  8019a5:	e8 fb 0c 00 00       	call   8026a5 <ipc_find_env>
  8019aa:	a3 00 50 80 00       	mov    %eax,0x805000
  8019af:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8019b2:	6a 07                	push   $0x7
  8019b4:	68 00 60 80 00       	push   $0x806000
  8019b9:	56                   	push   %esi
  8019ba:	ff 35 00 50 80 00    	pushl  0x805000
  8019c0:	e8 8c 0c 00 00       	call   802651 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8019c5:	83 c4 0c             	add    $0xc,%esp
  8019c8:	6a 00                	push   $0x0
  8019ca:	53                   	push   %ebx
  8019cb:	6a 00                	push   $0x0
  8019cd:	e8 16 0c 00 00       	call   8025e8 <ipc_recv>
}
  8019d2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019d5:	5b                   	pop    %ebx
  8019d6:	5e                   	pop    %esi
  8019d7:	5d                   	pop    %ebp
  8019d8:	c3                   	ret    

008019d9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8019d9:	55                   	push   %ebp
  8019da:	89 e5                	mov    %esp,%ebp
  8019dc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8019df:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e2:	8b 40 0c             	mov    0xc(%eax),%eax
  8019e5:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  8019ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019ed:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8019f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8019f7:	b8 02 00 00 00       	mov    $0x2,%eax
  8019fc:	e8 8d ff ff ff       	call   80198e <fsipc>
}
  801a01:	c9                   	leave  
  801a02:	c3                   	ret    

00801a03 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801a03:	55                   	push   %ebp
  801a04:	89 e5                	mov    %esp,%ebp
  801a06:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a09:	8b 45 08             	mov    0x8(%ebp),%eax
  801a0c:	8b 40 0c             	mov    0xc(%eax),%eax
  801a0f:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801a14:	ba 00 00 00 00       	mov    $0x0,%edx
  801a19:	b8 06 00 00 00       	mov    $0x6,%eax
  801a1e:	e8 6b ff ff ff       	call   80198e <fsipc>
}
  801a23:	c9                   	leave  
  801a24:	c3                   	ret    

00801a25 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a25:	55                   	push   %ebp
  801a26:	89 e5                	mov    %esp,%ebp
  801a28:	53                   	push   %ebx
  801a29:	83 ec 04             	sub    $0x4,%esp
  801a2c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a2f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a32:	8b 40 0c             	mov    0xc(%eax),%eax
  801a35:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a3a:	ba 00 00 00 00       	mov    $0x0,%edx
  801a3f:	b8 05 00 00 00       	mov    $0x5,%eax
  801a44:	e8 45 ff ff ff       	call   80198e <fsipc>
  801a49:	85 c0                	test   %eax,%eax
  801a4b:	78 2c                	js     801a79 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a4d:	83 ec 08             	sub    $0x8,%esp
  801a50:	68 00 60 80 00       	push   $0x806000
  801a55:	53                   	push   %ebx
  801a56:	e8 e7 f0 ff ff       	call   800b42 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a5b:	a1 80 60 80 00       	mov    0x806080,%eax
  801a60:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a66:	a1 84 60 80 00       	mov    0x806084,%eax
  801a6b:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a71:	83 c4 10             	add    $0x10,%esp
  801a74:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a79:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a7c:	c9                   	leave  
  801a7d:	c3                   	ret    

00801a7e <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801a7e:	55                   	push   %ebp
  801a7f:	89 e5                	mov    %esp,%ebp
  801a81:	53                   	push   %ebx
  801a82:	83 ec 08             	sub    $0x8,%esp
  801a85:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801a88:	8b 55 08             	mov    0x8(%ebp),%edx
  801a8b:	8b 52 0c             	mov    0xc(%edx),%edx
  801a8e:	89 15 00 60 80 00    	mov    %edx,0x806000
  801a94:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801a99:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  801a9e:	0f 46 d8             	cmovbe %eax,%ebx
	
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  801aa1:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  801aa7:	53                   	push   %ebx
  801aa8:	ff 75 0c             	pushl  0xc(%ebp)
  801aab:	68 08 60 80 00       	push   $0x806008
  801ab0:	e8 1f f2 ff ff       	call   800cd4 <memmove>

	
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) 
  801ab5:	ba 00 00 00 00       	mov    $0x0,%edx
  801aba:	b8 04 00 00 00       	mov    $0x4,%eax
  801abf:	e8 ca fe ff ff       	call   80198e <fsipc>
  801ac4:	83 c4 10             	add    $0x10,%esp
  801ac7:	85 c0                	test   %eax,%eax
  801ac9:	78 1d                	js     801ae8 <devfile_write+0x6a>
		return r;
	assert(r <= n_real); 
  801acb:	39 d8                	cmp    %ebx,%eax
  801acd:	76 19                	jbe    801ae8 <devfile_write+0x6a>
  801acf:	68 58 2f 80 00       	push   $0x802f58
  801ad4:	68 64 2f 80 00       	push   $0x802f64
  801ad9:	68 a3 00 00 00       	push   $0xa3
  801ade:	68 79 2f 80 00       	push   $0x802f79
  801ae3:	e8 fc e9 ff ff       	call   8004e4 <_panic>
	return r;
}
  801ae8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801aeb:	c9                   	leave  
  801aec:	c3                   	ret    

00801aed <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801aed:	55                   	push   %ebp
  801aee:	89 e5                	mov    %esp,%ebp
  801af0:	56                   	push   %esi
  801af1:	53                   	push   %ebx
  801af2:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801af5:	8b 45 08             	mov    0x8(%ebp),%eax
  801af8:	8b 40 0c             	mov    0xc(%eax),%eax
  801afb:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801b00:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b06:	ba 00 00 00 00       	mov    $0x0,%edx
  801b0b:	b8 03 00 00 00       	mov    $0x3,%eax
  801b10:	e8 79 fe ff ff       	call   80198e <fsipc>
  801b15:	89 c3                	mov    %eax,%ebx
  801b17:	85 c0                	test   %eax,%eax
  801b19:	78 4b                	js     801b66 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801b1b:	39 c6                	cmp    %eax,%esi
  801b1d:	73 16                	jae    801b35 <devfile_read+0x48>
  801b1f:	68 84 2f 80 00       	push   $0x802f84
  801b24:	68 64 2f 80 00       	push   $0x802f64
  801b29:	6a 7c                	push   $0x7c
  801b2b:	68 79 2f 80 00       	push   $0x802f79
  801b30:	e8 af e9 ff ff       	call   8004e4 <_panic>
	assert(r <= PGSIZE);
  801b35:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b3a:	7e 16                	jle    801b52 <devfile_read+0x65>
  801b3c:	68 8b 2f 80 00       	push   $0x802f8b
  801b41:	68 64 2f 80 00       	push   $0x802f64
  801b46:	6a 7d                	push   $0x7d
  801b48:	68 79 2f 80 00       	push   $0x802f79
  801b4d:	e8 92 e9 ff ff       	call   8004e4 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b52:	83 ec 04             	sub    $0x4,%esp
  801b55:	50                   	push   %eax
  801b56:	68 00 60 80 00       	push   $0x806000
  801b5b:	ff 75 0c             	pushl  0xc(%ebp)
  801b5e:	e8 71 f1 ff ff       	call   800cd4 <memmove>
	return r;
  801b63:	83 c4 10             	add    $0x10,%esp
}
  801b66:	89 d8                	mov    %ebx,%eax
  801b68:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b6b:	5b                   	pop    %ebx
  801b6c:	5e                   	pop    %esi
  801b6d:	5d                   	pop    %ebp
  801b6e:	c3                   	ret    

00801b6f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801b6f:	55                   	push   %ebp
  801b70:	89 e5                	mov    %esp,%ebp
  801b72:	53                   	push   %ebx
  801b73:	83 ec 20             	sub    $0x20,%esp
  801b76:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801b79:	53                   	push   %ebx
  801b7a:	e8 8a ef ff ff       	call   800b09 <strlen>
  801b7f:	83 c4 10             	add    $0x10,%esp
  801b82:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b87:	7f 67                	jg     801bf0 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b89:	83 ec 0c             	sub    $0xc,%esp
  801b8c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b8f:	50                   	push   %eax
  801b90:	e8 71 f8 ff ff       	call   801406 <fd_alloc>
  801b95:	83 c4 10             	add    $0x10,%esp
		return r;
  801b98:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b9a:	85 c0                	test   %eax,%eax
  801b9c:	78 57                	js     801bf5 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801b9e:	83 ec 08             	sub    $0x8,%esp
  801ba1:	53                   	push   %ebx
  801ba2:	68 00 60 80 00       	push   $0x806000
  801ba7:	e8 96 ef ff ff       	call   800b42 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801bac:	8b 45 0c             	mov    0xc(%ebp),%eax
  801baf:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801bb4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bb7:	b8 01 00 00 00       	mov    $0x1,%eax
  801bbc:	e8 cd fd ff ff       	call   80198e <fsipc>
  801bc1:	89 c3                	mov    %eax,%ebx
  801bc3:	83 c4 10             	add    $0x10,%esp
  801bc6:	85 c0                	test   %eax,%eax
  801bc8:	79 14                	jns    801bde <open+0x6f>
		fd_close(fd, 0);
  801bca:	83 ec 08             	sub    $0x8,%esp
  801bcd:	6a 00                	push   $0x0
  801bcf:	ff 75 f4             	pushl  -0xc(%ebp)
  801bd2:	e8 27 f9 ff ff       	call   8014fe <fd_close>
		return r;
  801bd7:	83 c4 10             	add    $0x10,%esp
  801bda:	89 da                	mov    %ebx,%edx
  801bdc:	eb 17                	jmp    801bf5 <open+0x86>
	}

	return fd2num(fd);
  801bde:	83 ec 0c             	sub    $0xc,%esp
  801be1:	ff 75 f4             	pushl  -0xc(%ebp)
  801be4:	e8 f6 f7 ff ff       	call   8013df <fd2num>
  801be9:	89 c2                	mov    %eax,%edx
  801beb:	83 c4 10             	add    $0x10,%esp
  801bee:	eb 05                	jmp    801bf5 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801bf0:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801bf5:	89 d0                	mov    %edx,%eax
  801bf7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bfa:	c9                   	leave  
  801bfb:	c3                   	ret    

00801bfc <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801bfc:	55                   	push   %ebp
  801bfd:	89 e5                	mov    %esp,%ebp
  801bff:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c02:	ba 00 00 00 00       	mov    $0x0,%edx
  801c07:	b8 08 00 00 00       	mov    $0x8,%eax
  801c0c:	e8 7d fd ff ff       	call   80198e <fsipc>
}
  801c11:	c9                   	leave  
  801c12:	c3                   	ret    

00801c13 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801c13:	55                   	push   %ebp
  801c14:	89 e5                	mov    %esp,%ebp
  801c16:	57                   	push   %edi
  801c17:	56                   	push   %esi
  801c18:	53                   	push   %ebx
  801c19:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801c1f:	6a 00                	push   $0x0
  801c21:	ff 75 08             	pushl  0x8(%ebp)
  801c24:	e8 46 ff ff ff       	call   801b6f <open>
  801c29:	89 c7                	mov    %eax,%edi
  801c2b:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801c31:	83 c4 10             	add    $0x10,%esp
  801c34:	85 c0                	test   %eax,%eax
  801c36:	0f 88 ae 04 00 00    	js     8020ea <spawn+0x4d7>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801c3c:	83 ec 04             	sub    $0x4,%esp
  801c3f:	68 00 02 00 00       	push   $0x200
  801c44:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801c4a:	50                   	push   %eax
  801c4b:	57                   	push   %edi
  801c4c:	e8 fb fa ff ff       	call   80174c <readn>
  801c51:	83 c4 10             	add    $0x10,%esp
  801c54:	3d 00 02 00 00       	cmp    $0x200,%eax
  801c59:	75 0c                	jne    801c67 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  801c5b:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801c62:	45 4c 46 
  801c65:	74 33                	je     801c9a <spawn+0x87>
		close(fd);
  801c67:	83 ec 0c             	sub    $0xc,%esp
  801c6a:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801c70:	e8 0a f9 ff ff       	call   80157f <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801c75:	83 c4 0c             	add    $0xc,%esp
  801c78:	68 7f 45 4c 46       	push   $0x464c457f
  801c7d:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801c83:	68 97 2f 80 00       	push   $0x802f97
  801c88:	e8 30 e9 ff ff       	call   8005bd <cprintf>
		return -E_NOT_EXEC;
  801c8d:	83 c4 10             	add    $0x10,%esp
  801c90:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801c95:	e9 b0 04 00 00       	jmp    80214a <spawn+0x537>
  801c9a:	b8 07 00 00 00       	mov    $0x7,%eax
  801c9f:	cd 30                	int    $0x30
  801ca1:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801ca7:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801cad:	85 c0                	test   %eax,%eax
  801caf:	0f 88 3d 04 00 00    	js     8020f2 <spawn+0x4df>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801cb5:	89 c6                	mov    %eax,%esi
  801cb7:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801cbd:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801cc0:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801cc6:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801ccc:	b9 11 00 00 00       	mov    $0x11,%ecx
  801cd1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801cd3:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801cd9:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801cdf:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801ce4:	be 00 00 00 00       	mov    $0x0,%esi
  801ce9:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801cec:	eb 13                	jmp    801d01 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801cee:	83 ec 0c             	sub    $0xc,%esp
  801cf1:	50                   	push   %eax
  801cf2:	e8 12 ee ff ff       	call   800b09 <strlen>
  801cf7:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801cfb:	83 c3 01             	add    $0x1,%ebx
  801cfe:	83 c4 10             	add    $0x10,%esp
  801d01:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801d08:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801d0b:	85 c0                	test   %eax,%eax
  801d0d:	75 df                	jne    801cee <spawn+0xdb>
  801d0f:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801d15:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801d1b:	bf 00 10 40 00       	mov    $0x401000,%edi
  801d20:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801d22:	89 fa                	mov    %edi,%edx
  801d24:	83 e2 fc             	and    $0xfffffffc,%edx
  801d27:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801d2e:	29 c2                	sub    %eax,%edx
  801d30:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801d36:	8d 42 f8             	lea    -0x8(%edx),%eax
  801d39:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801d3e:	0f 86 be 03 00 00    	jbe    802102 <spawn+0x4ef>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801d44:	83 ec 04             	sub    $0x4,%esp
  801d47:	6a 07                	push   $0x7
  801d49:	68 00 00 40 00       	push   $0x400000
  801d4e:	6a 00                	push   $0x0
  801d50:	e8 f0 f1 ff ff       	call   800f45 <sys_page_alloc>
  801d55:	83 c4 10             	add    $0x10,%esp
  801d58:	85 c0                	test   %eax,%eax
  801d5a:	0f 88 a9 03 00 00    	js     802109 <spawn+0x4f6>
  801d60:	be 00 00 00 00       	mov    $0x0,%esi
  801d65:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801d6b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801d6e:	eb 30                	jmp    801da0 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801d70:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801d76:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801d7c:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801d7f:	83 ec 08             	sub    $0x8,%esp
  801d82:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801d85:	57                   	push   %edi
  801d86:	e8 b7 ed ff ff       	call   800b42 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801d8b:	83 c4 04             	add    $0x4,%esp
  801d8e:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801d91:	e8 73 ed ff ff       	call   800b09 <strlen>
  801d96:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801d9a:	83 c6 01             	add    $0x1,%esi
  801d9d:	83 c4 10             	add    $0x10,%esp
  801da0:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801da6:	7f c8                	jg     801d70 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801da8:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801dae:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801db4:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801dbb:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801dc1:	74 19                	je     801ddc <spawn+0x1c9>
  801dc3:	68 f4 2f 80 00       	push   $0x802ff4
  801dc8:	68 64 2f 80 00       	push   $0x802f64
  801dcd:	68 f2 00 00 00       	push   $0xf2
  801dd2:	68 b1 2f 80 00       	push   $0x802fb1
  801dd7:	e8 08 e7 ff ff       	call   8004e4 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801ddc:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801de2:	89 f8                	mov    %edi,%eax
  801de4:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801de9:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801dec:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801df2:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801df5:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801dfb:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801e01:	83 ec 0c             	sub    $0xc,%esp
  801e04:	6a 07                	push   $0x7
  801e06:	68 00 d0 bf ee       	push   $0xeebfd000
  801e0b:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e11:	68 00 00 40 00       	push   $0x400000
  801e16:	6a 00                	push   $0x0
  801e18:	e8 6b f1 ff ff       	call   800f88 <sys_page_map>
  801e1d:	89 c3                	mov    %eax,%ebx
  801e1f:	83 c4 20             	add    $0x20,%esp
  801e22:	85 c0                	test   %eax,%eax
  801e24:	0f 88 0e 03 00 00    	js     802138 <spawn+0x525>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801e2a:	83 ec 08             	sub    $0x8,%esp
  801e2d:	68 00 00 40 00       	push   $0x400000
  801e32:	6a 00                	push   $0x0
  801e34:	e8 91 f1 ff ff       	call   800fca <sys_page_unmap>
  801e39:	89 c3                	mov    %eax,%ebx
  801e3b:	83 c4 10             	add    $0x10,%esp
  801e3e:	85 c0                	test   %eax,%eax
  801e40:	0f 88 f2 02 00 00    	js     802138 <spawn+0x525>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801e46:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801e4c:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801e53:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801e59:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801e60:	00 00 00 
  801e63:	e9 88 01 00 00       	jmp    801ff0 <spawn+0x3dd>
		if (ph->p_type != ELF_PROG_LOAD)
  801e68:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801e6e:	83 38 01             	cmpl   $0x1,(%eax)
  801e71:	0f 85 6b 01 00 00    	jne    801fe2 <spawn+0x3cf>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801e77:	89 c7                	mov    %eax,%edi
  801e79:	8b 40 18             	mov    0x18(%eax),%eax
  801e7c:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801e82:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801e85:	83 f8 01             	cmp    $0x1,%eax
  801e88:	19 c0                	sbb    %eax,%eax
  801e8a:	83 e0 fe             	and    $0xfffffffe,%eax
  801e8d:	83 c0 07             	add    $0x7,%eax
  801e90:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801e96:	89 f8                	mov    %edi,%eax
  801e98:	8b 7f 04             	mov    0x4(%edi),%edi
  801e9b:	89 f9                	mov    %edi,%ecx
  801e9d:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801ea3:	8b 78 10             	mov    0x10(%eax),%edi
  801ea6:	8b 50 14             	mov    0x14(%eax),%edx
  801ea9:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  801eaf:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801eb2:	89 f0                	mov    %esi,%eax
  801eb4:	25 ff 0f 00 00       	and    $0xfff,%eax
  801eb9:	74 14                	je     801ecf <spawn+0x2bc>
		va -= i;
  801ebb:	29 c6                	sub    %eax,%esi
		memsz += i;
  801ebd:	01 c2                	add    %eax,%edx
  801ebf:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  801ec5:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801ec7:	29 c1                	sub    %eax,%ecx
  801ec9:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801ecf:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ed4:	e9 f7 00 00 00       	jmp    801fd0 <spawn+0x3bd>
		if (i >= filesz) {
  801ed9:	39 df                	cmp    %ebx,%edi
  801edb:	77 27                	ja     801f04 <spawn+0x2f1>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801edd:	83 ec 04             	sub    $0x4,%esp
  801ee0:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801ee6:	56                   	push   %esi
  801ee7:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801eed:	e8 53 f0 ff ff       	call   800f45 <sys_page_alloc>
  801ef2:	83 c4 10             	add    $0x10,%esp
  801ef5:	85 c0                	test   %eax,%eax
  801ef7:	0f 89 c7 00 00 00    	jns    801fc4 <spawn+0x3b1>
  801efd:	89 c3                	mov    %eax,%ebx
  801eff:	e9 13 02 00 00       	jmp    802117 <spawn+0x504>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801f04:	83 ec 04             	sub    $0x4,%esp
  801f07:	6a 07                	push   $0x7
  801f09:	68 00 00 40 00       	push   $0x400000
  801f0e:	6a 00                	push   $0x0
  801f10:	e8 30 f0 ff ff       	call   800f45 <sys_page_alloc>
  801f15:	83 c4 10             	add    $0x10,%esp
  801f18:	85 c0                	test   %eax,%eax
  801f1a:	0f 88 ed 01 00 00    	js     80210d <spawn+0x4fa>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801f20:	83 ec 08             	sub    $0x8,%esp
  801f23:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801f29:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801f2f:	50                   	push   %eax
  801f30:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801f36:	e8 e6 f8 ff ff       	call   801821 <seek>
  801f3b:	83 c4 10             	add    $0x10,%esp
  801f3e:	85 c0                	test   %eax,%eax
  801f40:	0f 88 cb 01 00 00    	js     802111 <spawn+0x4fe>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801f46:	83 ec 04             	sub    $0x4,%esp
  801f49:	89 f8                	mov    %edi,%eax
  801f4b:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801f51:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801f56:	ba 00 10 00 00       	mov    $0x1000,%edx
  801f5b:	0f 47 c2             	cmova  %edx,%eax
  801f5e:	50                   	push   %eax
  801f5f:	68 00 00 40 00       	push   $0x400000
  801f64:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801f6a:	e8 dd f7 ff ff       	call   80174c <readn>
  801f6f:	83 c4 10             	add    $0x10,%esp
  801f72:	85 c0                	test   %eax,%eax
  801f74:	0f 88 9b 01 00 00    	js     802115 <spawn+0x502>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801f7a:	83 ec 0c             	sub    $0xc,%esp
  801f7d:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801f83:	56                   	push   %esi
  801f84:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801f8a:	68 00 00 40 00       	push   $0x400000
  801f8f:	6a 00                	push   $0x0
  801f91:	e8 f2 ef ff ff       	call   800f88 <sys_page_map>
  801f96:	83 c4 20             	add    $0x20,%esp
  801f99:	85 c0                	test   %eax,%eax
  801f9b:	79 15                	jns    801fb2 <spawn+0x39f>
				panic("spawn: sys_page_map data: %e", r);
  801f9d:	50                   	push   %eax
  801f9e:	68 bd 2f 80 00       	push   $0x802fbd
  801fa3:	68 25 01 00 00       	push   $0x125
  801fa8:	68 b1 2f 80 00       	push   $0x802fb1
  801fad:	e8 32 e5 ff ff       	call   8004e4 <_panic>
			sys_page_unmap(0, UTEMP);
  801fb2:	83 ec 08             	sub    $0x8,%esp
  801fb5:	68 00 00 40 00       	push   $0x400000
  801fba:	6a 00                	push   $0x0
  801fbc:	e8 09 f0 ff ff       	call   800fca <sys_page_unmap>
  801fc1:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801fc4:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801fca:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801fd0:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801fd6:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  801fdc:	0f 87 f7 fe ff ff    	ja     801ed9 <spawn+0x2c6>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801fe2:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801fe9:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801ff0:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801ff7:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801ffd:	0f 8c 65 fe ff ff    	jl     801e68 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  802003:	83 ec 0c             	sub    $0xc,%esp
  802006:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80200c:	e8 6e f5 ff ff       	call   80157f <close>
  802011:	83 c4 10             	add    $0x10,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	uintptr_t i;
	for (i = 0; i < USTACKTOP; i += PGSIZE){
  802014:	bb 00 00 00 00       	mov    $0x0,%ebx
  802019:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[PGNUM(i)] & PTE_P) && (uvpt[PGNUM(i)] & PTE_U) && (uvpt[PGNUM(i)] & PTE_SHARE)){
  80201f:	89 d8                	mov    %ebx,%eax
  802021:	c1 e8 16             	shr    $0x16,%eax
  802024:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80202b:	a8 01                	test   $0x1,%al
  80202d:	74 46                	je     802075 <spawn+0x462>
  80202f:	89 d8                	mov    %ebx,%eax
  802031:	c1 e8 0c             	shr    $0xc,%eax
  802034:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80203b:	f6 c2 01             	test   $0x1,%dl
  80203e:	74 35                	je     802075 <spawn+0x462>
  802040:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802047:	f6 c2 04             	test   $0x4,%dl
  80204a:	74 29                	je     802075 <spawn+0x462>
  80204c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802053:	f6 c6 04             	test   $0x4,%dh
  802056:	74 1d                	je     802075 <spawn+0x462>
			sys_page_map(0, (void*)i,child, (void*)i,(uvpt[PGNUM(i)] | PTE_SYSCALL));
  802058:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80205f:	83 ec 0c             	sub    $0xc,%esp
  802062:	0d 07 0e 00 00       	or     $0xe07,%eax
  802067:	50                   	push   %eax
  802068:	53                   	push   %ebx
  802069:	56                   	push   %esi
  80206a:	53                   	push   %ebx
  80206b:	6a 00                	push   $0x0
  80206d:	e8 16 ef ff ff       	call   800f88 <sys_page_map>
  802072:	83 c4 20             	add    $0x20,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	uintptr_t i;
	for (i = 0; i < USTACKTOP; i += PGSIZE){
  802075:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80207b:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  802081:	75 9c                	jne    80201f <spawn+0x40c>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  802083:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  80208a:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  80208d:	83 ec 08             	sub    $0x8,%esp
  802090:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  802096:	50                   	push   %eax
  802097:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  80209d:	e8 ac ef ff ff       	call   80104e <sys_env_set_trapframe>
  8020a2:	83 c4 10             	add    $0x10,%esp
  8020a5:	85 c0                	test   %eax,%eax
  8020a7:	79 15                	jns    8020be <spawn+0x4ab>
		panic("sys_env_set_trapframe: %e", r);
  8020a9:	50                   	push   %eax
  8020aa:	68 da 2f 80 00       	push   $0x802fda
  8020af:	68 86 00 00 00       	push   $0x86
  8020b4:	68 b1 2f 80 00       	push   $0x802fb1
  8020b9:	e8 26 e4 ff ff       	call   8004e4 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  8020be:	83 ec 08             	sub    $0x8,%esp
  8020c1:	6a 02                	push   $0x2
  8020c3:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8020c9:	e8 3e ef ff ff       	call   80100c <sys_env_set_status>
  8020ce:	83 c4 10             	add    $0x10,%esp
  8020d1:	85 c0                	test   %eax,%eax
  8020d3:	79 25                	jns    8020fa <spawn+0x4e7>
		panic("sys_env_set_status: %e", r);
  8020d5:	50                   	push   %eax
  8020d6:	68 9c 2e 80 00       	push   $0x802e9c
  8020db:	68 89 00 00 00       	push   $0x89
  8020e0:	68 b1 2f 80 00       	push   $0x802fb1
  8020e5:	e8 fa e3 ff ff       	call   8004e4 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  8020ea:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  8020f0:	eb 58                	jmp    80214a <spawn+0x537>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  8020f2:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  8020f8:	eb 50                	jmp    80214a <spawn+0x537>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  8020fa:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  802100:	eb 48                	jmp    80214a <spawn+0x537>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  802102:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  802107:	eb 41                	jmp    80214a <spawn+0x537>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  802109:	89 c3                	mov    %eax,%ebx
  80210b:	eb 3d                	jmp    80214a <spawn+0x537>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80210d:	89 c3                	mov    %eax,%ebx
  80210f:	eb 06                	jmp    802117 <spawn+0x504>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  802111:	89 c3                	mov    %eax,%ebx
  802113:	eb 02                	jmp    802117 <spawn+0x504>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  802115:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  802117:	83 ec 0c             	sub    $0xc,%esp
  80211a:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802120:	e8 a1 ed ff ff       	call   800ec6 <sys_env_destroy>
	close(fd);
  802125:	83 c4 04             	add    $0x4,%esp
  802128:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80212e:	e8 4c f4 ff ff       	call   80157f <close>
	return r;
  802133:	83 c4 10             	add    $0x10,%esp
  802136:	eb 12                	jmp    80214a <spawn+0x537>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  802138:	83 ec 08             	sub    $0x8,%esp
  80213b:	68 00 00 40 00       	push   $0x400000
  802140:	6a 00                	push   $0x0
  802142:	e8 83 ee ff ff       	call   800fca <sys_page_unmap>
  802147:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  80214a:	89 d8                	mov    %ebx,%eax
  80214c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80214f:	5b                   	pop    %ebx
  802150:	5e                   	pop    %esi
  802151:	5f                   	pop    %edi
  802152:	5d                   	pop    %ebp
  802153:	c3                   	ret    

00802154 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  802154:	55                   	push   %ebp
  802155:	89 e5                	mov    %esp,%ebp
  802157:	56                   	push   %esi
  802158:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802159:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  80215c:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802161:	eb 03                	jmp    802166 <spawnl+0x12>
		argc++;
  802163:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802166:	83 c2 04             	add    $0x4,%edx
  802169:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  80216d:	75 f4                	jne    802163 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  80216f:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  802176:	83 e2 f0             	and    $0xfffffff0,%edx
  802179:	29 d4                	sub    %edx,%esp
  80217b:	8d 54 24 03          	lea    0x3(%esp),%edx
  80217f:	c1 ea 02             	shr    $0x2,%edx
  802182:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  802189:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  80218b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80218e:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  802195:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  80219c:	00 
  80219d:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  80219f:	b8 00 00 00 00       	mov    $0x0,%eax
  8021a4:	eb 0a                	jmp    8021b0 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  8021a6:	83 c0 01             	add    $0x1,%eax
  8021a9:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  8021ad:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  8021b0:	39 d0                	cmp    %edx,%eax
  8021b2:	75 f2                	jne    8021a6 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  8021b4:	83 ec 08             	sub    $0x8,%esp
  8021b7:	56                   	push   %esi
  8021b8:	ff 75 08             	pushl  0x8(%ebp)
  8021bb:	e8 53 fa ff ff       	call   801c13 <spawn>
}
  8021c0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021c3:	5b                   	pop    %ebx
  8021c4:	5e                   	pop    %esi
  8021c5:	5d                   	pop    %ebp
  8021c6:	c3                   	ret    

008021c7 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8021c7:	55                   	push   %ebp
  8021c8:	89 e5                	mov    %esp,%ebp
  8021ca:	56                   	push   %esi
  8021cb:	53                   	push   %ebx
  8021cc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8021cf:	83 ec 0c             	sub    $0xc,%esp
  8021d2:	ff 75 08             	pushl  0x8(%ebp)
  8021d5:	e8 15 f2 ff ff       	call   8013ef <fd2data>
  8021da:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8021dc:	83 c4 08             	add    $0x8,%esp
  8021df:	68 1c 30 80 00       	push   $0x80301c
  8021e4:	53                   	push   %ebx
  8021e5:	e8 58 e9 ff ff       	call   800b42 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8021ea:	8b 46 04             	mov    0x4(%esi),%eax
  8021ed:	2b 06                	sub    (%esi),%eax
  8021ef:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8021f5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8021fc:	00 00 00 
	stat->st_dev = &devpipe;
  8021ff:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  802206:	40 80 00 
	return 0;
}
  802209:	b8 00 00 00 00       	mov    $0x0,%eax
  80220e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802211:	5b                   	pop    %ebx
  802212:	5e                   	pop    %esi
  802213:	5d                   	pop    %ebp
  802214:	c3                   	ret    

00802215 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802215:	55                   	push   %ebp
  802216:	89 e5                	mov    %esp,%ebp
  802218:	53                   	push   %ebx
  802219:	83 ec 0c             	sub    $0xc,%esp
  80221c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80221f:	53                   	push   %ebx
  802220:	6a 00                	push   $0x0
  802222:	e8 a3 ed ff ff       	call   800fca <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802227:	89 1c 24             	mov    %ebx,(%esp)
  80222a:	e8 c0 f1 ff ff       	call   8013ef <fd2data>
  80222f:	83 c4 08             	add    $0x8,%esp
  802232:	50                   	push   %eax
  802233:	6a 00                	push   $0x0
  802235:	e8 90 ed ff ff       	call   800fca <sys_page_unmap>
}
  80223a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80223d:	c9                   	leave  
  80223e:	c3                   	ret    

0080223f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80223f:	55                   	push   %ebp
  802240:	89 e5                	mov    %esp,%ebp
  802242:	57                   	push   %edi
  802243:	56                   	push   %esi
  802244:	53                   	push   %ebx
  802245:	83 ec 1c             	sub    $0x1c,%esp
  802248:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80224b:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80224d:	a1 04 50 80 00       	mov    0x805004,%eax
  802252:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  802255:	83 ec 0c             	sub    $0xc,%esp
  802258:	ff 75 e0             	pushl  -0x20(%ebp)
  80225b:	e8 7e 04 00 00       	call   8026de <pageref>
  802260:	89 c3                	mov    %eax,%ebx
  802262:	89 3c 24             	mov    %edi,(%esp)
  802265:	e8 74 04 00 00       	call   8026de <pageref>
  80226a:	83 c4 10             	add    $0x10,%esp
  80226d:	39 c3                	cmp    %eax,%ebx
  80226f:	0f 94 c1             	sete   %cl
  802272:	0f b6 c9             	movzbl %cl,%ecx
  802275:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  802278:	8b 15 04 50 80 00    	mov    0x805004,%edx
  80227e:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802281:	39 ce                	cmp    %ecx,%esi
  802283:	74 1b                	je     8022a0 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802285:	39 c3                	cmp    %eax,%ebx
  802287:	75 c4                	jne    80224d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802289:	8b 42 58             	mov    0x58(%edx),%eax
  80228c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80228f:	50                   	push   %eax
  802290:	56                   	push   %esi
  802291:	68 23 30 80 00       	push   $0x803023
  802296:	e8 22 e3 ff ff       	call   8005bd <cprintf>
  80229b:	83 c4 10             	add    $0x10,%esp
  80229e:	eb ad                	jmp    80224d <_pipeisclosed+0xe>
	}
}
  8022a0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8022a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022a6:	5b                   	pop    %ebx
  8022a7:	5e                   	pop    %esi
  8022a8:	5f                   	pop    %edi
  8022a9:	5d                   	pop    %ebp
  8022aa:	c3                   	ret    

008022ab <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8022ab:	55                   	push   %ebp
  8022ac:	89 e5                	mov    %esp,%ebp
  8022ae:	57                   	push   %edi
  8022af:	56                   	push   %esi
  8022b0:	53                   	push   %ebx
  8022b1:	83 ec 28             	sub    $0x28,%esp
  8022b4:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8022b7:	56                   	push   %esi
  8022b8:	e8 32 f1 ff ff       	call   8013ef <fd2data>
  8022bd:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8022bf:	83 c4 10             	add    $0x10,%esp
  8022c2:	bf 00 00 00 00       	mov    $0x0,%edi
  8022c7:	eb 4b                	jmp    802314 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8022c9:	89 da                	mov    %ebx,%edx
  8022cb:	89 f0                	mov    %esi,%eax
  8022cd:	e8 6d ff ff ff       	call   80223f <_pipeisclosed>
  8022d2:	85 c0                	test   %eax,%eax
  8022d4:	75 48                	jne    80231e <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8022d6:	e8 4b ec ff ff       	call   800f26 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8022db:	8b 43 04             	mov    0x4(%ebx),%eax
  8022de:	8b 0b                	mov    (%ebx),%ecx
  8022e0:	8d 51 20             	lea    0x20(%ecx),%edx
  8022e3:	39 d0                	cmp    %edx,%eax
  8022e5:	73 e2                	jae    8022c9 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8022e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8022ea:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8022ee:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8022f1:	89 c2                	mov    %eax,%edx
  8022f3:	c1 fa 1f             	sar    $0x1f,%edx
  8022f6:	89 d1                	mov    %edx,%ecx
  8022f8:	c1 e9 1b             	shr    $0x1b,%ecx
  8022fb:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8022fe:	83 e2 1f             	and    $0x1f,%edx
  802301:	29 ca                	sub    %ecx,%edx
  802303:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802307:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80230b:	83 c0 01             	add    $0x1,%eax
  80230e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802311:	83 c7 01             	add    $0x1,%edi
  802314:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802317:	75 c2                	jne    8022db <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802319:	8b 45 10             	mov    0x10(%ebp),%eax
  80231c:	eb 05                	jmp    802323 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80231e:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802323:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802326:	5b                   	pop    %ebx
  802327:	5e                   	pop    %esi
  802328:	5f                   	pop    %edi
  802329:	5d                   	pop    %ebp
  80232a:	c3                   	ret    

0080232b <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80232b:	55                   	push   %ebp
  80232c:	89 e5                	mov    %esp,%ebp
  80232e:	57                   	push   %edi
  80232f:	56                   	push   %esi
  802330:	53                   	push   %ebx
  802331:	83 ec 18             	sub    $0x18,%esp
  802334:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802337:	57                   	push   %edi
  802338:	e8 b2 f0 ff ff       	call   8013ef <fd2data>
  80233d:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80233f:	83 c4 10             	add    $0x10,%esp
  802342:	bb 00 00 00 00       	mov    $0x0,%ebx
  802347:	eb 3d                	jmp    802386 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802349:	85 db                	test   %ebx,%ebx
  80234b:	74 04                	je     802351 <devpipe_read+0x26>
				return i;
  80234d:	89 d8                	mov    %ebx,%eax
  80234f:	eb 44                	jmp    802395 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802351:	89 f2                	mov    %esi,%edx
  802353:	89 f8                	mov    %edi,%eax
  802355:	e8 e5 fe ff ff       	call   80223f <_pipeisclosed>
  80235a:	85 c0                	test   %eax,%eax
  80235c:	75 32                	jne    802390 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80235e:	e8 c3 eb ff ff       	call   800f26 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802363:	8b 06                	mov    (%esi),%eax
  802365:	3b 46 04             	cmp    0x4(%esi),%eax
  802368:	74 df                	je     802349 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80236a:	99                   	cltd   
  80236b:	c1 ea 1b             	shr    $0x1b,%edx
  80236e:	01 d0                	add    %edx,%eax
  802370:	83 e0 1f             	and    $0x1f,%eax
  802373:	29 d0                	sub    %edx,%eax
  802375:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80237a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80237d:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802380:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802383:	83 c3 01             	add    $0x1,%ebx
  802386:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802389:	75 d8                	jne    802363 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80238b:	8b 45 10             	mov    0x10(%ebp),%eax
  80238e:	eb 05                	jmp    802395 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802390:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802395:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802398:	5b                   	pop    %ebx
  802399:	5e                   	pop    %esi
  80239a:	5f                   	pop    %edi
  80239b:	5d                   	pop    %ebp
  80239c:	c3                   	ret    

0080239d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80239d:	55                   	push   %ebp
  80239e:	89 e5                	mov    %esp,%ebp
  8023a0:	56                   	push   %esi
  8023a1:	53                   	push   %ebx
  8023a2:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8023a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023a8:	50                   	push   %eax
  8023a9:	e8 58 f0 ff ff       	call   801406 <fd_alloc>
  8023ae:	83 c4 10             	add    $0x10,%esp
  8023b1:	89 c2                	mov    %eax,%edx
  8023b3:	85 c0                	test   %eax,%eax
  8023b5:	0f 88 2c 01 00 00    	js     8024e7 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023bb:	83 ec 04             	sub    $0x4,%esp
  8023be:	68 07 04 00 00       	push   $0x407
  8023c3:	ff 75 f4             	pushl  -0xc(%ebp)
  8023c6:	6a 00                	push   $0x0
  8023c8:	e8 78 eb ff ff       	call   800f45 <sys_page_alloc>
  8023cd:	83 c4 10             	add    $0x10,%esp
  8023d0:	89 c2                	mov    %eax,%edx
  8023d2:	85 c0                	test   %eax,%eax
  8023d4:	0f 88 0d 01 00 00    	js     8024e7 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8023da:	83 ec 0c             	sub    $0xc,%esp
  8023dd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8023e0:	50                   	push   %eax
  8023e1:	e8 20 f0 ff ff       	call   801406 <fd_alloc>
  8023e6:	89 c3                	mov    %eax,%ebx
  8023e8:	83 c4 10             	add    $0x10,%esp
  8023eb:	85 c0                	test   %eax,%eax
  8023ed:	0f 88 e2 00 00 00    	js     8024d5 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023f3:	83 ec 04             	sub    $0x4,%esp
  8023f6:	68 07 04 00 00       	push   $0x407
  8023fb:	ff 75 f0             	pushl  -0x10(%ebp)
  8023fe:	6a 00                	push   $0x0
  802400:	e8 40 eb ff ff       	call   800f45 <sys_page_alloc>
  802405:	89 c3                	mov    %eax,%ebx
  802407:	83 c4 10             	add    $0x10,%esp
  80240a:	85 c0                	test   %eax,%eax
  80240c:	0f 88 c3 00 00 00    	js     8024d5 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802412:	83 ec 0c             	sub    $0xc,%esp
  802415:	ff 75 f4             	pushl  -0xc(%ebp)
  802418:	e8 d2 ef ff ff       	call   8013ef <fd2data>
  80241d:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80241f:	83 c4 0c             	add    $0xc,%esp
  802422:	68 07 04 00 00       	push   $0x407
  802427:	50                   	push   %eax
  802428:	6a 00                	push   $0x0
  80242a:	e8 16 eb ff ff       	call   800f45 <sys_page_alloc>
  80242f:	89 c3                	mov    %eax,%ebx
  802431:	83 c4 10             	add    $0x10,%esp
  802434:	85 c0                	test   %eax,%eax
  802436:	0f 88 89 00 00 00    	js     8024c5 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80243c:	83 ec 0c             	sub    $0xc,%esp
  80243f:	ff 75 f0             	pushl  -0x10(%ebp)
  802442:	e8 a8 ef ff ff       	call   8013ef <fd2data>
  802447:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80244e:	50                   	push   %eax
  80244f:	6a 00                	push   $0x0
  802451:	56                   	push   %esi
  802452:	6a 00                	push   $0x0
  802454:	e8 2f eb ff ff       	call   800f88 <sys_page_map>
  802459:	89 c3                	mov    %eax,%ebx
  80245b:	83 c4 20             	add    $0x20,%esp
  80245e:	85 c0                	test   %eax,%eax
  802460:	78 55                	js     8024b7 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802462:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802468:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80246b:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80246d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802470:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802477:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  80247d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802480:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802482:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802485:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80248c:	83 ec 0c             	sub    $0xc,%esp
  80248f:	ff 75 f4             	pushl  -0xc(%ebp)
  802492:	e8 48 ef ff ff       	call   8013df <fd2num>
  802497:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80249a:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80249c:	83 c4 04             	add    $0x4,%esp
  80249f:	ff 75 f0             	pushl  -0x10(%ebp)
  8024a2:	e8 38 ef ff ff       	call   8013df <fd2num>
  8024a7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8024aa:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8024ad:	83 c4 10             	add    $0x10,%esp
  8024b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8024b5:	eb 30                	jmp    8024e7 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8024b7:	83 ec 08             	sub    $0x8,%esp
  8024ba:	56                   	push   %esi
  8024bb:	6a 00                	push   $0x0
  8024bd:	e8 08 eb ff ff       	call   800fca <sys_page_unmap>
  8024c2:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8024c5:	83 ec 08             	sub    $0x8,%esp
  8024c8:	ff 75 f0             	pushl  -0x10(%ebp)
  8024cb:	6a 00                	push   $0x0
  8024cd:	e8 f8 ea ff ff       	call   800fca <sys_page_unmap>
  8024d2:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8024d5:	83 ec 08             	sub    $0x8,%esp
  8024d8:	ff 75 f4             	pushl  -0xc(%ebp)
  8024db:	6a 00                	push   $0x0
  8024dd:	e8 e8 ea ff ff       	call   800fca <sys_page_unmap>
  8024e2:	83 c4 10             	add    $0x10,%esp
  8024e5:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8024e7:	89 d0                	mov    %edx,%eax
  8024e9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8024ec:	5b                   	pop    %ebx
  8024ed:	5e                   	pop    %esi
  8024ee:	5d                   	pop    %ebp
  8024ef:	c3                   	ret    

008024f0 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8024f0:	55                   	push   %ebp
  8024f1:	89 e5                	mov    %esp,%ebp
  8024f3:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8024f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024f9:	50                   	push   %eax
  8024fa:	ff 75 08             	pushl  0x8(%ebp)
  8024fd:	e8 53 ef ff ff       	call   801455 <fd_lookup>
  802502:	83 c4 10             	add    $0x10,%esp
  802505:	85 c0                	test   %eax,%eax
  802507:	78 18                	js     802521 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802509:	83 ec 0c             	sub    $0xc,%esp
  80250c:	ff 75 f4             	pushl  -0xc(%ebp)
  80250f:	e8 db ee ff ff       	call   8013ef <fd2data>
	return _pipeisclosed(fd, p);
  802514:	89 c2                	mov    %eax,%edx
  802516:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802519:	e8 21 fd ff ff       	call   80223f <_pipeisclosed>
  80251e:	83 c4 10             	add    $0x10,%esp
}
  802521:	c9                   	leave  
  802522:	c3                   	ret    

00802523 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802523:	55                   	push   %ebp
  802524:	89 e5                	mov    %esp,%ebp
  802526:	56                   	push   %esi
  802527:	53                   	push   %ebx
  802528:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  80252b:	85 f6                	test   %esi,%esi
  80252d:	75 16                	jne    802545 <wait+0x22>
  80252f:	68 3b 30 80 00       	push   $0x80303b
  802534:	68 64 2f 80 00       	push   $0x802f64
  802539:	6a 09                	push   $0x9
  80253b:	68 46 30 80 00       	push   $0x803046
  802540:	e8 9f df ff ff       	call   8004e4 <_panic>
	e = &envs[ENVX(envid)];
  802545:	89 f3                	mov    %esi,%ebx
  802547:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80254d:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  802550:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  802556:	eb 05                	jmp    80255d <wait+0x3a>
		sys_yield();
  802558:	e8 c9 e9 ff ff       	call   800f26 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80255d:	8b 43 48             	mov    0x48(%ebx),%eax
  802560:	39 c6                	cmp    %eax,%esi
  802562:	75 07                	jne    80256b <wait+0x48>
  802564:	8b 43 54             	mov    0x54(%ebx),%eax
  802567:	85 c0                	test   %eax,%eax
  802569:	75 ed                	jne    802558 <wait+0x35>
		sys_yield();
}
  80256b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80256e:	5b                   	pop    %ebx
  80256f:	5e                   	pop    %esi
  802570:	5d                   	pop    %ebp
  802571:	c3                   	ret    

00802572 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802572:	55                   	push   %ebp
  802573:	89 e5                	mov    %esp,%ebp
  802575:	53                   	push   %ebx
  802576:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  802579:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802580:	75 28                	jne    8025aa <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  802582:	e8 80 e9 ff ff       	call   800f07 <sys_getenvid>
  802587:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_U | PTE_W);
  802589:	83 ec 04             	sub    $0x4,%esp
  80258c:	6a 06                	push   $0x6
  80258e:	68 00 f0 bf ee       	push   $0xeebff000
  802593:	50                   	push   %eax
  802594:	e8 ac e9 ff ff       	call   800f45 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  802599:	83 c4 08             	add    $0x8,%esp
  80259c:	68 b7 25 80 00       	push   $0x8025b7
  8025a1:	53                   	push   %ebx
  8025a2:	e8 e9 ea ff ff       	call   801090 <sys_env_set_pgfault_upcall>
  8025a7:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8025aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8025ad:	a3 00 70 80 00       	mov    %eax,0x807000
}
  8025b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8025b5:	c9                   	leave  
  8025b6:	c3                   	ret    

008025b7 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8025b7:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8025b8:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8025bd:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8025bf:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	# My method is different. Copy the values to the other stack
	# in a convinient way, and then pop everything.
	movl %esp, %ebp		# ebp refers to the exception stack
  8025c2:	89 e5                	mov    %esp,%ebp
	movl 48(%ebp), %esp 	# go to other stack
  8025c4:	8b 65 30             	mov    0x30(%ebp),%esp

	pushl 40(%ebp)		# eip - ORDER SWITCHED WITH EFLAGS
  8025c7:	ff 75 28             	pushl  0x28(%ebp)
	pushl 44(%ebp)      	# eflags
  8025ca:	ff 75 2c             	pushl  0x2c(%ebp)
	pushl 36(%ebp)		# all the 8 remaining regs
  8025cd:	ff 75 24             	pushl  0x24(%ebp)
	pushl 32(%ebp)
  8025d0:	ff 75 20             	pushl  0x20(%ebp)
	pushl 28(%ebp)
  8025d3:	ff 75 1c             	pushl  0x1c(%ebp)
	pushl 24(%ebp)
  8025d6:	ff 75 18             	pushl  0x18(%ebp)
	pushl 20(%ebp)
  8025d9:	ff 75 14             	pushl  0x14(%ebp)
	pushl 16(%ebp)
  8025dc:	ff 75 10             	pushl  0x10(%ebp)
	pushl 12(%ebp)
  8025df:	ff 75 0c             	pushl  0xc(%ebp)
	pushl 8(%ebp)
  8025e2:	ff 75 08             	pushl  0x8(%ebp)

	popal			# now just pop everything!
  8025e5:	61                   	popa   
	popfl
  8025e6:	9d                   	popf   
	ret
  8025e7:	c3                   	ret    

008025e8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8025e8:	55                   	push   %ebp
  8025e9:	89 e5                	mov    %esp,%ebp
  8025eb:	56                   	push   %esi
  8025ec:	53                   	push   %ebx
  8025ed:	8b 75 08             	mov    0x8(%ebp),%esi
  8025f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025f3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  8025f6:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  8025f8:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  8025fd:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  802600:	83 ec 0c             	sub    $0xc,%esp
  802603:	50                   	push   %eax
  802604:	e8 ec ea ff ff       	call   8010f5 <sys_ipc_recv>

	if (r < 0) {
  802609:	83 c4 10             	add    $0x10,%esp
  80260c:	85 c0                	test   %eax,%eax
  80260e:	79 16                	jns    802626 <ipc_recv+0x3e>
		if (from_env_store)
  802610:	85 f6                	test   %esi,%esi
  802612:	74 06                	je     80261a <ipc_recv+0x32>
			*from_env_store = 0;
  802614:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  80261a:	85 db                	test   %ebx,%ebx
  80261c:	74 2c                	je     80264a <ipc_recv+0x62>
			*perm_store = 0;
  80261e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802624:	eb 24                	jmp    80264a <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  802626:	85 f6                	test   %esi,%esi
  802628:	74 0a                	je     802634 <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  80262a:	a1 04 50 80 00       	mov    0x805004,%eax
  80262f:	8b 40 74             	mov    0x74(%eax),%eax
  802632:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  802634:	85 db                	test   %ebx,%ebx
  802636:	74 0a                	je     802642 <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  802638:	a1 04 50 80 00       	mov    0x805004,%eax
  80263d:	8b 40 78             	mov    0x78(%eax),%eax
  802640:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  802642:	a1 04 50 80 00       	mov    0x805004,%eax
  802647:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  80264a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80264d:	5b                   	pop    %ebx
  80264e:	5e                   	pop    %esi
  80264f:	5d                   	pop    %ebp
  802650:	c3                   	ret    

00802651 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802651:	55                   	push   %ebp
  802652:	89 e5                	mov    %esp,%ebp
  802654:	57                   	push   %edi
  802655:	56                   	push   %esi
  802656:	53                   	push   %ebx
  802657:	83 ec 0c             	sub    $0xc,%esp
  80265a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80265d:	8b 75 0c             	mov    0xc(%ebp),%esi
  802660:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  802663:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  802665:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  80266a:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  80266d:	ff 75 14             	pushl  0x14(%ebp)
  802670:	53                   	push   %ebx
  802671:	56                   	push   %esi
  802672:	57                   	push   %edi
  802673:	e8 5a ea ff ff       	call   8010d2 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  802678:	83 c4 10             	add    $0x10,%esp
  80267b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80267e:	75 07                	jne    802687 <ipc_send+0x36>
			sys_yield();
  802680:	e8 a1 e8 ff ff       	call   800f26 <sys_yield>
  802685:	eb e6                	jmp    80266d <ipc_send+0x1c>
		} else if (r < 0) {
  802687:	85 c0                	test   %eax,%eax
  802689:	79 12                	jns    80269d <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  80268b:	50                   	push   %eax
  80268c:	68 51 30 80 00       	push   $0x803051
  802691:	6a 51                	push   $0x51
  802693:	68 5e 30 80 00       	push   $0x80305e
  802698:	e8 47 de ff ff       	call   8004e4 <_panic>
		}
	}
}
  80269d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8026a0:	5b                   	pop    %ebx
  8026a1:	5e                   	pop    %esi
  8026a2:	5f                   	pop    %edi
  8026a3:	5d                   	pop    %ebp
  8026a4:	c3                   	ret    

008026a5 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8026a5:	55                   	push   %ebp
  8026a6:	89 e5                	mov    %esp,%ebp
  8026a8:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8026ab:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8026b0:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8026b3:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8026b9:	8b 52 50             	mov    0x50(%edx),%edx
  8026bc:	39 ca                	cmp    %ecx,%edx
  8026be:	75 0d                	jne    8026cd <ipc_find_env+0x28>
			return envs[i].env_id;
  8026c0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8026c3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8026c8:	8b 40 48             	mov    0x48(%eax),%eax
  8026cb:	eb 0f                	jmp    8026dc <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8026cd:	83 c0 01             	add    $0x1,%eax
  8026d0:	3d 00 04 00 00       	cmp    $0x400,%eax
  8026d5:	75 d9                	jne    8026b0 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8026d7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8026dc:	5d                   	pop    %ebp
  8026dd:	c3                   	ret    

008026de <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8026de:	55                   	push   %ebp
  8026df:	89 e5                	mov    %esp,%ebp
  8026e1:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8026e4:	89 d0                	mov    %edx,%eax
  8026e6:	c1 e8 16             	shr    $0x16,%eax
  8026e9:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8026f0:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8026f5:	f6 c1 01             	test   $0x1,%cl
  8026f8:	74 1d                	je     802717 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8026fa:	c1 ea 0c             	shr    $0xc,%edx
  8026fd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802704:	f6 c2 01             	test   $0x1,%dl
  802707:	74 0e                	je     802717 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802709:	c1 ea 0c             	shr    $0xc,%edx
  80270c:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802713:	ef 
  802714:	0f b7 c0             	movzwl %ax,%eax
}
  802717:	5d                   	pop    %ebp
  802718:	c3                   	ret    
  802719:	66 90                	xchg   %ax,%ax
  80271b:	66 90                	xchg   %ax,%ax
  80271d:	66 90                	xchg   %ax,%ax
  80271f:	90                   	nop

00802720 <__udivdi3>:
  802720:	55                   	push   %ebp
  802721:	57                   	push   %edi
  802722:	56                   	push   %esi
  802723:	53                   	push   %ebx
  802724:	83 ec 1c             	sub    $0x1c,%esp
  802727:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80272b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80272f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802733:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802737:	85 f6                	test   %esi,%esi
  802739:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80273d:	89 ca                	mov    %ecx,%edx
  80273f:	89 f8                	mov    %edi,%eax
  802741:	75 3d                	jne    802780 <__udivdi3+0x60>
  802743:	39 cf                	cmp    %ecx,%edi
  802745:	0f 87 c5 00 00 00    	ja     802810 <__udivdi3+0xf0>
  80274b:	85 ff                	test   %edi,%edi
  80274d:	89 fd                	mov    %edi,%ebp
  80274f:	75 0b                	jne    80275c <__udivdi3+0x3c>
  802751:	b8 01 00 00 00       	mov    $0x1,%eax
  802756:	31 d2                	xor    %edx,%edx
  802758:	f7 f7                	div    %edi
  80275a:	89 c5                	mov    %eax,%ebp
  80275c:	89 c8                	mov    %ecx,%eax
  80275e:	31 d2                	xor    %edx,%edx
  802760:	f7 f5                	div    %ebp
  802762:	89 c1                	mov    %eax,%ecx
  802764:	89 d8                	mov    %ebx,%eax
  802766:	89 cf                	mov    %ecx,%edi
  802768:	f7 f5                	div    %ebp
  80276a:	89 c3                	mov    %eax,%ebx
  80276c:	89 d8                	mov    %ebx,%eax
  80276e:	89 fa                	mov    %edi,%edx
  802770:	83 c4 1c             	add    $0x1c,%esp
  802773:	5b                   	pop    %ebx
  802774:	5e                   	pop    %esi
  802775:	5f                   	pop    %edi
  802776:	5d                   	pop    %ebp
  802777:	c3                   	ret    
  802778:	90                   	nop
  802779:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802780:	39 ce                	cmp    %ecx,%esi
  802782:	77 74                	ja     8027f8 <__udivdi3+0xd8>
  802784:	0f bd fe             	bsr    %esi,%edi
  802787:	83 f7 1f             	xor    $0x1f,%edi
  80278a:	0f 84 98 00 00 00    	je     802828 <__udivdi3+0x108>
  802790:	bb 20 00 00 00       	mov    $0x20,%ebx
  802795:	89 f9                	mov    %edi,%ecx
  802797:	89 c5                	mov    %eax,%ebp
  802799:	29 fb                	sub    %edi,%ebx
  80279b:	d3 e6                	shl    %cl,%esi
  80279d:	89 d9                	mov    %ebx,%ecx
  80279f:	d3 ed                	shr    %cl,%ebp
  8027a1:	89 f9                	mov    %edi,%ecx
  8027a3:	d3 e0                	shl    %cl,%eax
  8027a5:	09 ee                	or     %ebp,%esi
  8027a7:	89 d9                	mov    %ebx,%ecx
  8027a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8027ad:	89 d5                	mov    %edx,%ebp
  8027af:	8b 44 24 08          	mov    0x8(%esp),%eax
  8027b3:	d3 ed                	shr    %cl,%ebp
  8027b5:	89 f9                	mov    %edi,%ecx
  8027b7:	d3 e2                	shl    %cl,%edx
  8027b9:	89 d9                	mov    %ebx,%ecx
  8027bb:	d3 e8                	shr    %cl,%eax
  8027bd:	09 c2                	or     %eax,%edx
  8027bf:	89 d0                	mov    %edx,%eax
  8027c1:	89 ea                	mov    %ebp,%edx
  8027c3:	f7 f6                	div    %esi
  8027c5:	89 d5                	mov    %edx,%ebp
  8027c7:	89 c3                	mov    %eax,%ebx
  8027c9:	f7 64 24 0c          	mull   0xc(%esp)
  8027cd:	39 d5                	cmp    %edx,%ebp
  8027cf:	72 10                	jb     8027e1 <__udivdi3+0xc1>
  8027d1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8027d5:	89 f9                	mov    %edi,%ecx
  8027d7:	d3 e6                	shl    %cl,%esi
  8027d9:	39 c6                	cmp    %eax,%esi
  8027db:	73 07                	jae    8027e4 <__udivdi3+0xc4>
  8027dd:	39 d5                	cmp    %edx,%ebp
  8027df:	75 03                	jne    8027e4 <__udivdi3+0xc4>
  8027e1:	83 eb 01             	sub    $0x1,%ebx
  8027e4:	31 ff                	xor    %edi,%edi
  8027e6:	89 d8                	mov    %ebx,%eax
  8027e8:	89 fa                	mov    %edi,%edx
  8027ea:	83 c4 1c             	add    $0x1c,%esp
  8027ed:	5b                   	pop    %ebx
  8027ee:	5e                   	pop    %esi
  8027ef:	5f                   	pop    %edi
  8027f0:	5d                   	pop    %ebp
  8027f1:	c3                   	ret    
  8027f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8027f8:	31 ff                	xor    %edi,%edi
  8027fa:	31 db                	xor    %ebx,%ebx
  8027fc:	89 d8                	mov    %ebx,%eax
  8027fe:	89 fa                	mov    %edi,%edx
  802800:	83 c4 1c             	add    $0x1c,%esp
  802803:	5b                   	pop    %ebx
  802804:	5e                   	pop    %esi
  802805:	5f                   	pop    %edi
  802806:	5d                   	pop    %ebp
  802807:	c3                   	ret    
  802808:	90                   	nop
  802809:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802810:	89 d8                	mov    %ebx,%eax
  802812:	f7 f7                	div    %edi
  802814:	31 ff                	xor    %edi,%edi
  802816:	89 c3                	mov    %eax,%ebx
  802818:	89 d8                	mov    %ebx,%eax
  80281a:	89 fa                	mov    %edi,%edx
  80281c:	83 c4 1c             	add    $0x1c,%esp
  80281f:	5b                   	pop    %ebx
  802820:	5e                   	pop    %esi
  802821:	5f                   	pop    %edi
  802822:	5d                   	pop    %ebp
  802823:	c3                   	ret    
  802824:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802828:	39 ce                	cmp    %ecx,%esi
  80282a:	72 0c                	jb     802838 <__udivdi3+0x118>
  80282c:	31 db                	xor    %ebx,%ebx
  80282e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802832:	0f 87 34 ff ff ff    	ja     80276c <__udivdi3+0x4c>
  802838:	bb 01 00 00 00       	mov    $0x1,%ebx
  80283d:	e9 2a ff ff ff       	jmp    80276c <__udivdi3+0x4c>
  802842:	66 90                	xchg   %ax,%ax
  802844:	66 90                	xchg   %ax,%ax
  802846:	66 90                	xchg   %ax,%ax
  802848:	66 90                	xchg   %ax,%ax
  80284a:	66 90                	xchg   %ax,%ax
  80284c:	66 90                	xchg   %ax,%ax
  80284e:	66 90                	xchg   %ax,%ax

00802850 <__umoddi3>:
  802850:	55                   	push   %ebp
  802851:	57                   	push   %edi
  802852:	56                   	push   %esi
  802853:	53                   	push   %ebx
  802854:	83 ec 1c             	sub    $0x1c,%esp
  802857:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80285b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80285f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802863:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802867:	85 d2                	test   %edx,%edx
  802869:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80286d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802871:	89 f3                	mov    %esi,%ebx
  802873:	89 3c 24             	mov    %edi,(%esp)
  802876:	89 74 24 04          	mov    %esi,0x4(%esp)
  80287a:	75 1c                	jne    802898 <__umoddi3+0x48>
  80287c:	39 f7                	cmp    %esi,%edi
  80287e:	76 50                	jbe    8028d0 <__umoddi3+0x80>
  802880:	89 c8                	mov    %ecx,%eax
  802882:	89 f2                	mov    %esi,%edx
  802884:	f7 f7                	div    %edi
  802886:	89 d0                	mov    %edx,%eax
  802888:	31 d2                	xor    %edx,%edx
  80288a:	83 c4 1c             	add    $0x1c,%esp
  80288d:	5b                   	pop    %ebx
  80288e:	5e                   	pop    %esi
  80288f:	5f                   	pop    %edi
  802890:	5d                   	pop    %ebp
  802891:	c3                   	ret    
  802892:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802898:	39 f2                	cmp    %esi,%edx
  80289a:	89 d0                	mov    %edx,%eax
  80289c:	77 52                	ja     8028f0 <__umoddi3+0xa0>
  80289e:	0f bd ea             	bsr    %edx,%ebp
  8028a1:	83 f5 1f             	xor    $0x1f,%ebp
  8028a4:	75 5a                	jne    802900 <__umoddi3+0xb0>
  8028a6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8028aa:	0f 82 e0 00 00 00    	jb     802990 <__umoddi3+0x140>
  8028b0:	39 0c 24             	cmp    %ecx,(%esp)
  8028b3:	0f 86 d7 00 00 00    	jbe    802990 <__umoddi3+0x140>
  8028b9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8028bd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8028c1:	83 c4 1c             	add    $0x1c,%esp
  8028c4:	5b                   	pop    %ebx
  8028c5:	5e                   	pop    %esi
  8028c6:	5f                   	pop    %edi
  8028c7:	5d                   	pop    %ebp
  8028c8:	c3                   	ret    
  8028c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8028d0:	85 ff                	test   %edi,%edi
  8028d2:	89 fd                	mov    %edi,%ebp
  8028d4:	75 0b                	jne    8028e1 <__umoddi3+0x91>
  8028d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8028db:	31 d2                	xor    %edx,%edx
  8028dd:	f7 f7                	div    %edi
  8028df:	89 c5                	mov    %eax,%ebp
  8028e1:	89 f0                	mov    %esi,%eax
  8028e3:	31 d2                	xor    %edx,%edx
  8028e5:	f7 f5                	div    %ebp
  8028e7:	89 c8                	mov    %ecx,%eax
  8028e9:	f7 f5                	div    %ebp
  8028eb:	89 d0                	mov    %edx,%eax
  8028ed:	eb 99                	jmp    802888 <__umoddi3+0x38>
  8028ef:	90                   	nop
  8028f0:	89 c8                	mov    %ecx,%eax
  8028f2:	89 f2                	mov    %esi,%edx
  8028f4:	83 c4 1c             	add    $0x1c,%esp
  8028f7:	5b                   	pop    %ebx
  8028f8:	5e                   	pop    %esi
  8028f9:	5f                   	pop    %edi
  8028fa:	5d                   	pop    %ebp
  8028fb:	c3                   	ret    
  8028fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802900:	8b 34 24             	mov    (%esp),%esi
  802903:	bf 20 00 00 00       	mov    $0x20,%edi
  802908:	89 e9                	mov    %ebp,%ecx
  80290a:	29 ef                	sub    %ebp,%edi
  80290c:	d3 e0                	shl    %cl,%eax
  80290e:	89 f9                	mov    %edi,%ecx
  802910:	89 f2                	mov    %esi,%edx
  802912:	d3 ea                	shr    %cl,%edx
  802914:	89 e9                	mov    %ebp,%ecx
  802916:	09 c2                	or     %eax,%edx
  802918:	89 d8                	mov    %ebx,%eax
  80291a:	89 14 24             	mov    %edx,(%esp)
  80291d:	89 f2                	mov    %esi,%edx
  80291f:	d3 e2                	shl    %cl,%edx
  802921:	89 f9                	mov    %edi,%ecx
  802923:	89 54 24 04          	mov    %edx,0x4(%esp)
  802927:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80292b:	d3 e8                	shr    %cl,%eax
  80292d:	89 e9                	mov    %ebp,%ecx
  80292f:	89 c6                	mov    %eax,%esi
  802931:	d3 e3                	shl    %cl,%ebx
  802933:	89 f9                	mov    %edi,%ecx
  802935:	89 d0                	mov    %edx,%eax
  802937:	d3 e8                	shr    %cl,%eax
  802939:	89 e9                	mov    %ebp,%ecx
  80293b:	09 d8                	or     %ebx,%eax
  80293d:	89 d3                	mov    %edx,%ebx
  80293f:	89 f2                	mov    %esi,%edx
  802941:	f7 34 24             	divl   (%esp)
  802944:	89 d6                	mov    %edx,%esi
  802946:	d3 e3                	shl    %cl,%ebx
  802948:	f7 64 24 04          	mull   0x4(%esp)
  80294c:	39 d6                	cmp    %edx,%esi
  80294e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802952:	89 d1                	mov    %edx,%ecx
  802954:	89 c3                	mov    %eax,%ebx
  802956:	72 08                	jb     802960 <__umoddi3+0x110>
  802958:	75 11                	jne    80296b <__umoddi3+0x11b>
  80295a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80295e:	73 0b                	jae    80296b <__umoddi3+0x11b>
  802960:	2b 44 24 04          	sub    0x4(%esp),%eax
  802964:	1b 14 24             	sbb    (%esp),%edx
  802967:	89 d1                	mov    %edx,%ecx
  802969:	89 c3                	mov    %eax,%ebx
  80296b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80296f:	29 da                	sub    %ebx,%edx
  802971:	19 ce                	sbb    %ecx,%esi
  802973:	89 f9                	mov    %edi,%ecx
  802975:	89 f0                	mov    %esi,%eax
  802977:	d3 e0                	shl    %cl,%eax
  802979:	89 e9                	mov    %ebp,%ecx
  80297b:	d3 ea                	shr    %cl,%edx
  80297d:	89 e9                	mov    %ebp,%ecx
  80297f:	d3 ee                	shr    %cl,%esi
  802981:	09 d0                	or     %edx,%eax
  802983:	89 f2                	mov    %esi,%edx
  802985:	83 c4 1c             	add    $0x1c,%esp
  802988:	5b                   	pop    %ebx
  802989:	5e                   	pop    %esi
  80298a:	5f                   	pop    %edi
  80298b:	5d                   	pop    %ebp
  80298c:	c3                   	ret    
  80298d:	8d 76 00             	lea    0x0(%esi),%esi
  802990:	29 f9                	sub    %edi,%ecx
  802992:	19 d6                	sbb    %edx,%esi
  802994:	89 74 24 04          	mov    %esi,0x4(%esp)
  802998:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80299c:	e9 18 ff ff ff       	jmp    8028b9 <__umoddi3+0x69>
