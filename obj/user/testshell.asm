
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
  80004a:	e8 71 17 00 00       	call   8017c0 <seek>
	seek(kfd, off);
  80004f:	83 c4 08             	add    $0x8,%esp
  800052:	53                   	push   %ebx
  800053:	57                   	push   %edi
  800054:	e8 67 17 00 00       	call   8017c0 <seek>

	cprintf("shell produced incorrect output.\n");
  800059:	c7 04 24 60 29 80 00 	movl   $0x802960,(%esp)
  800060:	e8 58 05 00 00       	call   8005bd <cprintf>
	cprintf("expected:\n===\n");
  800065:	c7 04 24 cb 29 80 00 	movl   $0x8029cb,(%esp)
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
  80008d:	e8 c8 15 00 00       	call   80165a <read>
  800092:	83 c4 10             	add    $0x10,%esp
  800095:	85 c0                	test   %eax,%eax
  800097:	7f e0                	jg     800079 <wrong+0x46>
		sys_cputs(buf, n);
	cprintf("===\ngot:\n===\n");
  800099:	83 ec 0c             	sub    $0xc,%esp
  80009c:	68 da 29 80 00       	push   $0x8029da
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
  8000c2:	e8 93 15 00 00       	call   80165a <read>
  8000c7:	83 c4 10             	add    $0x10,%esp
  8000ca:	85 c0                	test   %eax,%eax
  8000cc:	7f e0                	jg     8000ae <wrong+0x7b>
		sys_cputs(buf, n);
	cprintf("===\n");
  8000ce:	83 ec 0c             	sub    $0xc,%esp
  8000d1:	68 d5 29 80 00       	push   $0x8029d5
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
  8000f6:	e8 23 14 00 00       	call   80151e <close>
	close(1);
  8000fb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800102:	e8 17 14 00 00       	call   80151e <close>
	opencons();
  800107:	e8 1e 03 00 00       	call   80042a <opencons>
	opencons();
  80010c:	e8 19 03 00 00       	call   80042a <opencons>

	if ((rfd = open("testshell.sh", O_RDONLY)) < 0)
  800111:	83 c4 08             	add    $0x8,%esp
  800114:	6a 00                	push   $0x0
  800116:	68 e8 29 80 00       	push   $0x8029e8
  80011b:	e8 ee 19 00 00       	call   801b0e <open>
  800120:	89 c3                	mov    %eax,%ebx
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	85 c0                	test   %eax,%eax
  800127:	79 12                	jns    80013b <umain+0x50>
		panic("open testshell.sh: %e", rfd);
  800129:	50                   	push   %eax
  80012a:	68 f5 29 80 00       	push   $0x8029f5
  80012f:	6a 13                	push   $0x13
  800131:	68 0b 2a 80 00       	push   $0x802a0b
  800136:	e8 a9 03 00 00       	call   8004e4 <_panic>
	if ((wfd = pipe(pfds)) < 0)
  80013b:	83 ec 0c             	sub    $0xc,%esp
  80013e:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800141:	50                   	push   %eax
  800142:	e8 f5 21 00 00       	call   80233c <pipe>
  800147:	83 c4 10             	add    $0x10,%esp
  80014a:	85 c0                	test   %eax,%eax
  80014c:	79 12                	jns    800160 <umain+0x75>
		panic("pipe: %e", wfd);
  80014e:	50                   	push   %eax
  80014f:	68 1c 2a 80 00       	push   $0x802a1c
  800154:	6a 15                	push   $0x15
  800156:	68 0b 2a 80 00       	push   $0x802a0b
  80015b:	e8 84 03 00 00       	call   8004e4 <_panic>
	wfd = pfds[1];
  800160:	8b 75 e0             	mov    -0x20(%ebp),%esi

	cprintf("running sh -x < testshell.sh | cat\n");
  800163:	83 ec 0c             	sub    $0xc,%esp
  800166:	68 84 29 80 00       	push   $0x802984
  80016b:	e8 4d 04 00 00       	call   8005bd <cprintf>
	if ((r = fork()) < 0)
  800170:	e8 14 11 00 00       	call   801289 <fork>
  800175:	83 c4 10             	add    $0x10,%esp
  800178:	85 c0                	test   %eax,%eax
  80017a:	79 12                	jns    80018e <umain+0xa3>
		panic("fork: %e", r);
  80017c:	50                   	push   %eax
  80017d:	68 33 2e 80 00       	push   $0x802e33
  800182:	6a 1a                	push   $0x1a
  800184:	68 0b 2a 80 00       	push   $0x802a0b
  800189:	e8 56 03 00 00       	call   8004e4 <_panic>
	if (r == 0) {
  80018e:	85 c0                	test   %eax,%eax
  800190:	75 7d                	jne    80020f <umain+0x124>
		dup(rfd, 0);
  800192:	83 ec 08             	sub    $0x8,%esp
  800195:	6a 00                	push   $0x0
  800197:	53                   	push   %ebx
  800198:	e8 d1 13 00 00       	call   80156e <dup>
		dup(wfd, 1);
  80019d:	83 c4 08             	add    $0x8,%esp
  8001a0:	6a 01                	push   $0x1
  8001a2:	56                   	push   %esi
  8001a3:	e8 c6 13 00 00       	call   80156e <dup>
		close(rfd);
  8001a8:	89 1c 24             	mov    %ebx,(%esp)
  8001ab:	e8 6e 13 00 00       	call   80151e <close>
		close(wfd);
  8001b0:	89 34 24             	mov    %esi,(%esp)
  8001b3:	e8 66 13 00 00       	call   80151e <close>
		if ((r = spawnl("/sh", "sh", "-x", 0)) < 0)
  8001b8:	6a 00                	push   $0x0
  8001ba:	68 25 2a 80 00       	push   $0x802a25
  8001bf:	68 f2 29 80 00       	push   $0x8029f2
  8001c4:	68 28 2a 80 00       	push   $0x802a28
  8001c9:	e8 25 1f 00 00       	call   8020f3 <spawnl>
  8001ce:	89 c7                	mov    %eax,%edi
  8001d0:	83 c4 20             	add    $0x20,%esp
  8001d3:	85 c0                	test   %eax,%eax
  8001d5:	79 12                	jns    8001e9 <umain+0xfe>
			panic("spawn: %e", r);
  8001d7:	50                   	push   %eax
  8001d8:	68 2c 2a 80 00       	push   $0x802a2c
  8001dd:	6a 21                	push   $0x21
  8001df:	68 0b 2a 80 00       	push   $0x802a0b
  8001e4:	e8 fb 02 00 00       	call   8004e4 <_panic>
		close(0);
  8001e9:	83 ec 0c             	sub    $0xc,%esp
  8001ec:	6a 00                	push   $0x0
  8001ee:	e8 2b 13 00 00       	call   80151e <close>
		close(1);
  8001f3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8001fa:	e8 1f 13 00 00       	call   80151e <close>
		wait(r);
  8001ff:	89 3c 24             	mov    %edi,(%esp)
  800202:	e8 bb 22 00 00       	call   8024c2 <wait>
		exit();
  800207:	e8 be 02 00 00       	call   8004ca <exit>
  80020c:	83 c4 10             	add    $0x10,%esp
	}
	close(rfd);
  80020f:	83 ec 0c             	sub    $0xc,%esp
  800212:	53                   	push   %ebx
  800213:	e8 06 13 00 00       	call   80151e <close>
	close(wfd);
  800218:	89 34 24             	mov    %esi,(%esp)
  80021b:	e8 fe 12 00 00       	call   80151e <close>

	rfd = pfds[0];
  800220:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800223:	89 45 d0             	mov    %eax,-0x30(%ebp)
	if ((kfd = open("testshell.key", O_RDONLY)) < 0)
  800226:	83 c4 08             	add    $0x8,%esp
  800229:	6a 00                	push   $0x0
  80022b:	68 36 2a 80 00       	push   $0x802a36
  800230:	e8 d9 18 00 00       	call   801b0e <open>
  800235:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800238:	83 c4 10             	add    $0x10,%esp
  80023b:	85 c0                	test   %eax,%eax
  80023d:	79 12                	jns    800251 <umain+0x166>
		panic("open testshell.key for reading: %e", kfd);
  80023f:	50                   	push   %eax
  800240:	68 a8 29 80 00       	push   $0x8029a8
  800245:	6a 2c                	push   $0x2c
  800247:	68 0b 2a 80 00       	push   $0x802a0b
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
  800267:	e8 ee 13 00 00       	call   80165a <read>
  80026c:	89 c3                	mov    %eax,%ebx
		n2 = read(kfd, &c2, 1);
  80026e:	83 c4 0c             	add    $0xc,%esp
  800271:	6a 01                	push   $0x1
  800273:	8d 45 e6             	lea    -0x1a(%ebp),%eax
  800276:	50                   	push   %eax
  800277:	ff 75 d4             	pushl  -0x2c(%ebp)
  80027a:	e8 db 13 00 00       	call   80165a <read>
		if (n1 < 0)
  80027f:	83 c4 10             	add    $0x10,%esp
  800282:	85 db                	test   %ebx,%ebx
  800284:	79 12                	jns    800298 <umain+0x1ad>
			panic("reading testshell.out: %e", n1);
  800286:	53                   	push   %ebx
  800287:	68 44 2a 80 00       	push   $0x802a44
  80028c:	6a 33                	push   $0x33
  80028e:	68 0b 2a 80 00       	push   $0x802a0b
  800293:	e8 4c 02 00 00       	call   8004e4 <_panic>
		if (n2 < 0)
  800298:	85 c0                	test   %eax,%eax
  80029a:	79 12                	jns    8002ae <umain+0x1c3>
			panic("reading testshell.key: %e", n2);
  80029c:	50                   	push   %eax
  80029d:	68 5e 2a 80 00       	push   $0x802a5e
  8002a2:	6a 35                	push   $0x35
  8002a4:	68 0b 2a 80 00       	push   $0x802a0b
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
  8002eb:	68 78 2a 80 00       	push   $0x802a78
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
  800311:	68 8d 2a 80 00       	push   $0x802a8d
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
  8003e1:	e8 74 12 00 00       	call   80165a <read>
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
  80040b:	e8 e4 0f 00 00       	call   8013f4 <fd_lookup>
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
  800434:	e8 6c 0f 00 00       	call   8013a5 <fd_alloc>
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
  800476:	e8 03 0f 00 00       	call   80137e <fd2num>
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
  8004d0:	e8 74 10 00 00       	call   801549 <close_all>
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
  800502:	68 a4 2a 80 00       	push   $0x802aa4
  800507:	e8 b1 00 00 00       	call   8005bd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80050c:	83 c4 18             	add    $0x18,%esp
  80050f:	53                   	push   %ebx
  800510:	ff 75 10             	pushl  0x10(%ebp)
  800513:	e8 54 00 00 00       	call   80056c <vcprintf>
	cprintf("\n");
  800518:	c7 04 24 d8 29 80 00 	movl   $0x8029d8,(%esp)
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
  800620:	e8 9b 20 00 00       	call   8026c0 <__udivdi3>
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
  800663:	e8 88 21 00 00       	call   8027f0 <__umoddi3>
  800668:	83 c4 14             	add    $0x14,%esp
  80066b:	0f be 80 c7 2a 80 00 	movsbl 0x802ac7(%eax),%eax
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
  800767:	ff 24 85 00 2c 80 00 	jmp    *0x802c00(,%eax,4)
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
  80082b:	8b 14 85 60 2d 80 00 	mov    0x802d60(,%eax,4),%edx
  800832:	85 d2                	test   %edx,%edx
  800834:	75 18                	jne    80084e <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800836:	50                   	push   %eax
  800837:	68 df 2a 80 00       	push   $0x802adf
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
  80084f:	68 4a 2f 80 00       	push   $0x802f4a
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
  800873:	b8 d8 2a 80 00       	mov    $0x802ad8,%eax
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
  800eee:	68 bf 2d 80 00       	push   $0x802dbf
  800ef3:	6a 23                	push   $0x23
  800ef5:	68 dc 2d 80 00       	push   $0x802ddc
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
  800f6f:	68 bf 2d 80 00       	push   $0x802dbf
  800f74:	6a 23                	push   $0x23
  800f76:	68 dc 2d 80 00       	push   $0x802ddc
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
  800fb1:	68 bf 2d 80 00       	push   $0x802dbf
  800fb6:	6a 23                	push   $0x23
  800fb8:	68 dc 2d 80 00       	push   $0x802ddc
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
  800ff3:	68 bf 2d 80 00       	push   $0x802dbf
  800ff8:	6a 23                	push   $0x23
  800ffa:	68 dc 2d 80 00       	push   $0x802ddc
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
  801035:	68 bf 2d 80 00       	push   $0x802dbf
  80103a:	6a 23                	push   $0x23
  80103c:	68 dc 2d 80 00       	push   $0x802ddc
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
  801077:	68 bf 2d 80 00       	push   $0x802dbf
  80107c:	6a 23                	push   $0x23
  80107e:	68 dc 2d 80 00       	push   $0x802ddc
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
  8010b9:	68 bf 2d 80 00       	push   $0x802dbf
  8010be:	6a 23                	push   $0x23
  8010c0:	68 dc 2d 80 00       	push   $0x802ddc
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
  80111d:	68 bf 2d 80 00       	push   $0x802dbf
  801122:	6a 23                	push   $0x23
  801124:	68 dc 2d 80 00       	push   $0x802ddc
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
  801139:	56                   	push   %esi
  80113a:	53                   	push   %ebx
	int r;

	// LAB 4: Your code here.
	// Check if page is writable or COW
	pte_t pte = uvpt[pn];
  80113b:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
	uint32_t perm = PTE_P | PTE_U;
	if (pte && (PTE_COW | PTE_W)) {
		perm |= PTE_COW;
  801142:	83 f9 01             	cmp    $0x1,%ecx
  801145:	19 f6                	sbb    %esi,%esi
  801147:	81 e6 00 f8 ff ff    	and    $0xfffff800,%esi
  80114d:	81 c6 05 08 00 00    	add    $0x805,%esi
	}

	// Map page
	void *va = (void *) (pn * PGSIZE);
  801153:	c1 e2 0c             	shl    $0xc,%edx
  801156:	89 d3                	mov    %edx,%ebx
	// Map on the child
	if ((r = sys_page_map(0, va, envid, va, perm)) < 0) {
  801158:	83 ec 0c             	sub    $0xc,%esp
  80115b:	56                   	push   %esi
  80115c:	52                   	push   %edx
  80115d:	50                   	push   %eax
  80115e:	52                   	push   %edx
  80115f:	6a 00                	push   $0x0
  801161:	e8 22 fe ff ff       	call   800f88 <sys_page_map>
  801166:	83 c4 20             	add    $0x20,%esp
  801169:	85 c0                	test   %eax,%eax
  80116b:	79 12                	jns    80117f <duppage+0x49>
		panic("sys_page_alloc: %e", r);
  80116d:	50                   	push   %eax
  80116e:	68 ea 2d 80 00       	push   $0x802dea
  801173:	6a 56                	push   $0x56
  801175:	68 fd 2d 80 00       	push   $0x802dfd
  80117a:	e8 65 f3 ff ff       	call   8004e4 <_panic>
		return r;
	}

	// Change the permission on the parent
	if ((r = sys_page_map(0, va, 0, va, perm)) < 0) {
  80117f:	83 ec 0c             	sub    $0xc,%esp
  801182:	56                   	push   %esi
  801183:	53                   	push   %ebx
  801184:	6a 00                	push   $0x0
  801186:	53                   	push   %ebx
  801187:	6a 00                	push   $0x0
  801189:	e8 fa fd ff ff       	call   800f88 <sys_page_map>
  80118e:	83 c4 20             	add    $0x20,%esp
  801191:	85 c0                	test   %eax,%eax
  801193:	79 12                	jns    8011a7 <duppage+0x71>
		panic("sys_page_alloc: %e", r);
  801195:	50                   	push   %eax
  801196:	68 ea 2d 80 00       	push   $0x802dea
  80119b:	6a 5c                	push   $0x5c
  80119d:	68 fd 2d 80 00       	push   $0x802dfd
  8011a2:	e8 3d f3 ff ff       	call   8004e4 <_panic>
		return r;
	}

	return 0;
}
  8011a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011af:	5b                   	pop    %ebx
  8011b0:	5e                   	pop    %esi
  8011b1:	5d                   	pop    %ebp
  8011b2:	c3                   	ret    

008011b3 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8011b3:	55                   	push   %ebp
  8011b4:	89 e5                	mov    %esp,%ebp
  8011b6:	53                   	push   %ebx
  8011b7:	83 ec 04             	sub    $0x4,%esp
  8011ba:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8011bd:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	unsigned pn = ((uint32_t)addr)/PGSIZE;
  8011bf:	89 da                	mov    %ebx,%edx
  8011c1:	c1 ea 0c             	shr    $0xc,%edx
	pte_t pte = uvpt[pn];
  8011c4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(err & FEC_WR) || !(pte & PTE_COW)) {
  8011cb:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8011cf:	74 05                	je     8011d6 <pgfault+0x23>
  8011d1:	f6 c6 08             	test   $0x8,%dh
  8011d4:	75 14                	jne    8011ea <pgfault+0x37>
		panic("fork pgfault handler: does not handle this fault");
  8011d6:	83 ec 04             	sub    $0x4,%esp
  8011d9:	68 6c 2e 80 00       	push   $0x802e6c
  8011de:	6a 1f                	push   $0x1f
  8011e0:	68 fd 2d 80 00       	push   $0x802dfd
  8011e5:	e8 fa f2 ff ff       	call   8004e4 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// Allocate a new page, mapped at temp location
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  8011ea:	83 ec 04             	sub    $0x4,%esp
  8011ed:	6a 07                	push   $0x7
  8011ef:	68 00 f0 7f 00       	push   $0x7ff000
  8011f4:	6a 00                	push   $0x0
  8011f6:	e8 4a fd ff ff       	call   800f45 <sys_page_alloc>
  8011fb:	83 c4 10             	add    $0x10,%esp
  8011fe:	85 c0                	test   %eax,%eax
  801200:	79 12                	jns    801214 <pgfault+0x61>
		panic("sys_page_alloc: %e", r);
  801202:	50                   	push   %eax
  801203:	68 ea 2d 80 00       	push   $0x802dea
  801208:	6a 2b                	push   $0x2b
  80120a:	68 fd 2d 80 00       	push   $0x802dfd
  80120f:	e8 d0 f2 ff ff       	call   8004e4 <_panic>

	// Copy the data from the old page to this new page
	void *addr_pgstart = (void *) ROUNDDOWN(addr, PGSIZE);
  801214:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr_pgstart, PGSIZE);
  80121a:	83 ec 04             	sub    $0x4,%esp
  80121d:	68 00 10 00 00       	push   $0x1000
  801222:	53                   	push   %ebx
  801223:	68 00 f0 7f 00       	push   $0x7ff000
  801228:	e8 a7 fa ff ff       	call   800cd4 <memmove>

	// Move the new page to the old page's address
	if ((r = sys_page_map(0, PFTEMP, 0, addr_pgstart, PTE_P|PTE_U|PTE_W)) < 0)
  80122d:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801234:	53                   	push   %ebx
  801235:	6a 00                	push   $0x0
  801237:	68 00 f0 7f 00       	push   $0x7ff000
  80123c:	6a 00                	push   $0x0
  80123e:	e8 45 fd ff ff       	call   800f88 <sys_page_map>
  801243:	83 c4 20             	add    $0x20,%esp
  801246:	85 c0                	test   %eax,%eax
  801248:	79 12                	jns    80125c <pgfault+0xa9>
		panic("sys_page_map: %e", r);
  80124a:	50                   	push   %eax
  80124b:	68 08 2e 80 00       	push   $0x802e08
  801250:	6a 33                	push   $0x33
  801252:	68 fd 2d 80 00       	push   $0x802dfd
  801257:	e8 88 f2 ff ff       	call   8004e4 <_panic>

	// Unmap the temp location
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  80125c:	83 ec 08             	sub    $0x8,%esp
  80125f:	68 00 f0 7f 00       	push   $0x7ff000
  801264:	6a 00                	push   $0x0
  801266:	e8 5f fd ff ff       	call   800fca <sys_page_unmap>
  80126b:	83 c4 10             	add    $0x10,%esp
  80126e:	85 c0                	test   %eax,%eax
  801270:	79 12                	jns    801284 <pgfault+0xd1>
		panic("sys_page_unmap: %e", r);
  801272:	50                   	push   %eax
  801273:	68 19 2e 80 00       	push   $0x802e19
  801278:	6a 37                	push   $0x37
  80127a:	68 fd 2d 80 00       	push   $0x802dfd
  80127f:	e8 60 f2 ff ff       	call   8004e4 <_panic>
}
  801284:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801287:	c9                   	leave  
  801288:	c3                   	ret    

00801289 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801289:	55                   	push   %ebp
  80128a:	89 e5                	mov    %esp,%ebp
  80128c:	56                   	push   %esi
  80128d:	53                   	push   %ebx
  80128e:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
	// Set up page fault handler
	set_pgfault_handler(&pgfault);
  801291:	68 b3 11 80 00       	push   $0x8011b3
  801296:	e8 76 12 00 00       	call   802511 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  80129b:	b8 07 00 00 00       	mov    $0x7,%eax
  8012a0:	cd 30                	int    $0x30

	// Create child
	envid_t envid = sys_exofork();
  8012a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (envid < 0) {
  8012a5:	83 c4 10             	add    $0x10,%esp
  8012a8:	85 c0                	test   %eax,%eax
  8012aa:	79 12                	jns    8012be <fork+0x35>
		panic("sys_exofork: %e", envid);
  8012ac:	50                   	push   %eax
  8012ad:	68 2c 2e 80 00       	push   $0x802e2c
  8012b2:	6a 7d                	push   $0x7d
  8012b4:	68 fd 2d 80 00       	push   $0x802dfd
  8012b9:	e8 26 f2 ff ff       	call   8004e4 <_panic>
		return envid;
	}
	if (envid == 0) {
  8012be:	85 c0                	test   %eax,%eax
  8012c0:	75 1e                	jne    8012e0 <fork+0x57>
		// We are the child.
		thisenv = &envs[ENVX(sys_getenvid())]; // Fix thisenv
  8012c2:	e8 40 fc ff ff       	call   800f07 <sys_getenvid>
  8012c7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8012cc:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8012cf:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8012d4:	a3 04 50 80 00       	mov    %eax,0x805004
		return 0;
  8012d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8012de:	eb 7d                	jmp    80135d <fork+0xd4>

	// Set page fault handler on the child.
	// The parent needs to do it, else the child wouldn't be able to handle
	// the fault when trying to access it's stack (which happens as soon it starts)
	extern void _pgfault_upcall(void);
	sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);
  8012e0:	83 ec 04             	sub    $0x4,%esp
  8012e3:	6a 07                	push   $0x7
  8012e5:	68 00 f0 bf ee       	push   $0xeebff000
  8012ea:	50                   	push   %eax
  8012eb:	e8 55 fc ff ff       	call   800f45 <sys_page_alloc>
	sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  8012f0:	83 c4 08             	add    $0x8,%esp
  8012f3:	68 56 25 80 00       	push   $0x802556
  8012f8:	ff 75 f4             	pushl  -0xc(%ebp)
  8012fb:	e8 90 fd ff ff       	call   801090 <sys_env_set_pgfault_upcall>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  801300:	be 04 70 80 00       	mov    $0x807004,%esi
  801305:	c1 ee 0c             	shr    $0xc,%esi
  801308:	83 c4 10             	add    $0x10,%esp
  80130b:	bb 00 08 00 00       	mov    $0x800,%ebx
  801310:	eb 0d                	jmp    80131f <fork+0x96>
		duppage(envid, pn);
  801312:	89 da                	mov    %ebx,%edx
  801314:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801317:	e8 1a fe ff ff       	call   801136 <duppage>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  80131c:	83 c3 01             	add    $0x1,%ebx
  80131f:	39 f3                	cmp    %esi,%ebx
  801321:	76 ef                	jbe    801312 <fork+0x89>
	}

	// Also copy the stack we are currently running on
	// I think it should loop from ustacktop to this page, since the stack
	// can have more than 1 page
	duppage(envid, ((uint32_t) &envid)/PGSIZE);
  801323:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801326:	c1 ea 0c             	shr    $0xc,%edx
  801329:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80132c:	e8 05 fe ff ff       	call   801136 <duppage>

	// Start the child environmnet running
	int r;
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  801331:	83 ec 08             	sub    $0x8,%esp
  801334:	6a 02                	push   $0x2
  801336:	ff 75 f4             	pushl  -0xc(%ebp)
  801339:	e8 ce fc ff ff       	call   80100c <sys_env_set_status>
  80133e:	83 c4 10             	add    $0x10,%esp
  801341:	85 c0                	test   %eax,%eax
  801343:	79 15                	jns    80135a <fork+0xd1>
		panic("sys_env_set_status: %e", r);
  801345:	50                   	push   %eax
  801346:	68 3c 2e 80 00       	push   $0x802e3c
  80134b:	68 9d 00 00 00       	push   $0x9d
  801350:	68 fd 2d 80 00       	push   $0x802dfd
  801355:	e8 8a f1 ff ff       	call   8004e4 <_panic>
		return r;
	}

	return envid;
  80135a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80135d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801360:	5b                   	pop    %ebx
  801361:	5e                   	pop    %esi
  801362:	5d                   	pop    %ebp
  801363:	c3                   	ret    

00801364 <sfork>:

// Challenge!
int
sfork(void)
{
  801364:	55                   	push   %ebp
  801365:	89 e5                	mov    %esp,%ebp
  801367:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80136a:	68 53 2e 80 00       	push   $0x802e53
  80136f:	68 a8 00 00 00       	push   $0xa8
  801374:	68 fd 2d 80 00       	push   $0x802dfd
  801379:	e8 66 f1 ff ff       	call   8004e4 <_panic>

0080137e <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80137e:	55                   	push   %ebp
  80137f:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801381:	8b 45 08             	mov    0x8(%ebp),%eax
  801384:	05 00 00 00 30       	add    $0x30000000,%eax
  801389:	c1 e8 0c             	shr    $0xc,%eax
}
  80138c:	5d                   	pop    %ebp
  80138d:	c3                   	ret    

0080138e <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80138e:	55                   	push   %ebp
  80138f:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801391:	8b 45 08             	mov    0x8(%ebp),%eax
  801394:	05 00 00 00 30       	add    $0x30000000,%eax
  801399:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80139e:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8013a3:	5d                   	pop    %ebp
  8013a4:	c3                   	ret    

008013a5 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8013a5:	55                   	push   %ebp
  8013a6:	89 e5                	mov    %esp,%ebp
  8013a8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013ab:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8013b0:	89 c2                	mov    %eax,%edx
  8013b2:	c1 ea 16             	shr    $0x16,%edx
  8013b5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013bc:	f6 c2 01             	test   $0x1,%dl
  8013bf:	74 11                	je     8013d2 <fd_alloc+0x2d>
  8013c1:	89 c2                	mov    %eax,%edx
  8013c3:	c1 ea 0c             	shr    $0xc,%edx
  8013c6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013cd:	f6 c2 01             	test   $0x1,%dl
  8013d0:	75 09                	jne    8013db <fd_alloc+0x36>
			*fd_store = fd;
  8013d2:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8013d9:	eb 17                	jmp    8013f2 <fd_alloc+0x4d>
  8013db:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8013e0:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8013e5:	75 c9                	jne    8013b0 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8013e7:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8013ed:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8013f2:	5d                   	pop    %ebp
  8013f3:	c3                   	ret    

008013f4 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8013f4:	55                   	push   %ebp
  8013f5:	89 e5                	mov    %esp,%ebp
  8013f7:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8013fa:	83 f8 1f             	cmp    $0x1f,%eax
  8013fd:	77 36                	ja     801435 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8013ff:	c1 e0 0c             	shl    $0xc,%eax
  801402:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801407:	89 c2                	mov    %eax,%edx
  801409:	c1 ea 16             	shr    $0x16,%edx
  80140c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801413:	f6 c2 01             	test   $0x1,%dl
  801416:	74 24                	je     80143c <fd_lookup+0x48>
  801418:	89 c2                	mov    %eax,%edx
  80141a:	c1 ea 0c             	shr    $0xc,%edx
  80141d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801424:	f6 c2 01             	test   $0x1,%dl
  801427:	74 1a                	je     801443 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801429:	8b 55 0c             	mov    0xc(%ebp),%edx
  80142c:	89 02                	mov    %eax,(%edx)
	return 0;
  80142e:	b8 00 00 00 00       	mov    $0x0,%eax
  801433:	eb 13                	jmp    801448 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801435:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80143a:	eb 0c                	jmp    801448 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80143c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801441:	eb 05                	jmp    801448 <fd_lookup+0x54>
  801443:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801448:	5d                   	pop    %ebp
  801449:	c3                   	ret    

0080144a <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80144a:	55                   	push   %ebp
  80144b:	89 e5                	mov    %esp,%ebp
  80144d:	83 ec 08             	sub    $0x8,%esp
  801450:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801453:	ba 1c 2f 80 00       	mov    $0x802f1c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801458:	eb 13                	jmp    80146d <dev_lookup+0x23>
  80145a:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80145d:	39 08                	cmp    %ecx,(%eax)
  80145f:	75 0c                	jne    80146d <dev_lookup+0x23>
			*dev = devtab[i];
  801461:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801464:	89 01                	mov    %eax,(%ecx)
			return 0;
  801466:	b8 00 00 00 00       	mov    $0x0,%eax
  80146b:	eb 2e                	jmp    80149b <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80146d:	8b 02                	mov    (%edx),%eax
  80146f:	85 c0                	test   %eax,%eax
  801471:	75 e7                	jne    80145a <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801473:	a1 04 50 80 00       	mov    0x805004,%eax
  801478:	8b 40 48             	mov    0x48(%eax),%eax
  80147b:	83 ec 04             	sub    $0x4,%esp
  80147e:	51                   	push   %ecx
  80147f:	50                   	push   %eax
  801480:	68 a0 2e 80 00       	push   $0x802ea0
  801485:	e8 33 f1 ff ff       	call   8005bd <cprintf>
	*dev = 0;
  80148a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80148d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801493:	83 c4 10             	add    $0x10,%esp
  801496:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80149b:	c9                   	leave  
  80149c:	c3                   	ret    

0080149d <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80149d:	55                   	push   %ebp
  80149e:	89 e5                	mov    %esp,%ebp
  8014a0:	56                   	push   %esi
  8014a1:	53                   	push   %ebx
  8014a2:	83 ec 10             	sub    $0x10,%esp
  8014a5:	8b 75 08             	mov    0x8(%ebp),%esi
  8014a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ae:	50                   	push   %eax
  8014af:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8014b5:	c1 e8 0c             	shr    $0xc,%eax
  8014b8:	50                   	push   %eax
  8014b9:	e8 36 ff ff ff       	call   8013f4 <fd_lookup>
  8014be:	83 c4 08             	add    $0x8,%esp
  8014c1:	85 c0                	test   %eax,%eax
  8014c3:	78 05                	js     8014ca <fd_close+0x2d>
	    || fd != fd2)
  8014c5:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8014c8:	74 0c                	je     8014d6 <fd_close+0x39>
		return (must_exist ? r : 0);
  8014ca:	84 db                	test   %bl,%bl
  8014cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8014d1:	0f 44 c2             	cmove  %edx,%eax
  8014d4:	eb 41                	jmp    801517 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8014d6:	83 ec 08             	sub    $0x8,%esp
  8014d9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014dc:	50                   	push   %eax
  8014dd:	ff 36                	pushl  (%esi)
  8014df:	e8 66 ff ff ff       	call   80144a <dev_lookup>
  8014e4:	89 c3                	mov    %eax,%ebx
  8014e6:	83 c4 10             	add    $0x10,%esp
  8014e9:	85 c0                	test   %eax,%eax
  8014eb:	78 1a                	js     801507 <fd_close+0x6a>
		if (dev->dev_close)
  8014ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014f0:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8014f3:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8014f8:	85 c0                	test   %eax,%eax
  8014fa:	74 0b                	je     801507 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8014fc:	83 ec 0c             	sub    $0xc,%esp
  8014ff:	56                   	push   %esi
  801500:	ff d0                	call   *%eax
  801502:	89 c3                	mov    %eax,%ebx
  801504:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801507:	83 ec 08             	sub    $0x8,%esp
  80150a:	56                   	push   %esi
  80150b:	6a 00                	push   $0x0
  80150d:	e8 b8 fa ff ff       	call   800fca <sys_page_unmap>
	return r;
  801512:	83 c4 10             	add    $0x10,%esp
  801515:	89 d8                	mov    %ebx,%eax
}
  801517:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80151a:	5b                   	pop    %ebx
  80151b:	5e                   	pop    %esi
  80151c:	5d                   	pop    %ebp
  80151d:	c3                   	ret    

0080151e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80151e:	55                   	push   %ebp
  80151f:	89 e5                	mov    %esp,%ebp
  801521:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801524:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801527:	50                   	push   %eax
  801528:	ff 75 08             	pushl  0x8(%ebp)
  80152b:	e8 c4 fe ff ff       	call   8013f4 <fd_lookup>
  801530:	83 c4 08             	add    $0x8,%esp
  801533:	85 c0                	test   %eax,%eax
  801535:	78 10                	js     801547 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801537:	83 ec 08             	sub    $0x8,%esp
  80153a:	6a 01                	push   $0x1
  80153c:	ff 75 f4             	pushl  -0xc(%ebp)
  80153f:	e8 59 ff ff ff       	call   80149d <fd_close>
  801544:	83 c4 10             	add    $0x10,%esp
}
  801547:	c9                   	leave  
  801548:	c3                   	ret    

00801549 <close_all>:

void
close_all(void)
{
  801549:	55                   	push   %ebp
  80154a:	89 e5                	mov    %esp,%ebp
  80154c:	53                   	push   %ebx
  80154d:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801550:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801555:	83 ec 0c             	sub    $0xc,%esp
  801558:	53                   	push   %ebx
  801559:	e8 c0 ff ff ff       	call   80151e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80155e:	83 c3 01             	add    $0x1,%ebx
  801561:	83 c4 10             	add    $0x10,%esp
  801564:	83 fb 20             	cmp    $0x20,%ebx
  801567:	75 ec                	jne    801555 <close_all+0xc>
		close(i);
}
  801569:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80156c:	c9                   	leave  
  80156d:	c3                   	ret    

0080156e <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80156e:	55                   	push   %ebp
  80156f:	89 e5                	mov    %esp,%ebp
  801571:	57                   	push   %edi
  801572:	56                   	push   %esi
  801573:	53                   	push   %ebx
  801574:	83 ec 2c             	sub    $0x2c,%esp
  801577:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80157a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80157d:	50                   	push   %eax
  80157e:	ff 75 08             	pushl  0x8(%ebp)
  801581:	e8 6e fe ff ff       	call   8013f4 <fd_lookup>
  801586:	83 c4 08             	add    $0x8,%esp
  801589:	85 c0                	test   %eax,%eax
  80158b:	0f 88 c1 00 00 00    	js     801652 <dup+0xe4>
		return r;
	close(newfdnum);
  801591:	83 ec 0c             	sub    $0xc,%esp
  801594:	56                   	push   %esi
  801595:	e8 84 ff ff ff       	call   80151e <close>

	newfd = INDEX2FD(newfdnum);
  80159a:	89 f3                	mov    %esi,%ebx
  80159c:	c1 e3 0c             	shl    $0xc,%ebx
  80159f:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8015a5:	83 c4 04             	add    $0x4,%esp
  8015a8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015ab:	e8 de fd ff ff       	call   80138e <fd2data>
  8015b0:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8015b2:	89 1c 24             	mov    %ebx,(%esp)
  8015b5:	e8 d4 fd ff ff       	call   80138e <fd2data>
  8015ba:	83 c4 10             	add    $0x10,%esp
  8015bd:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8015c0:	89 f8                	mov    %edi,%eax
  8015c2:	c1 e8 16             	shr    $0x16,%eax
  8015c5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015cc:	a8 01                	test   $0x1,%al
  8015ce:	74 37                	je     801607 <dup+0x99>
  8015d0:	89 f8                	mov    %edi,%eax
  8015d2:	c1 e8 0c             	shr    $0xc,%eax
  8015d5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8015dc:	f6 c2 01             	test   $0x1,%dl
  8015df:	74 26                	je     801607 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8015e1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015e8:	83 ec 0c             	sub    $0xc,%esp
  8015eb:	25 07 0e 00 00       	and    $0xe07,%eax
  8015f0:	50                   	push   %eax
  8015f1:	ff 75 d4             	pushl  -0x2c(%ebp)
  8015f4:	6a 00                	push   $0x0
  8015f6:	57                   	push   %edi
  8015f7:	6a 00                	push   $0x0
  8015f9:	e8 8a f9 ff ff       	call   800f88 <sys_page_map>
  8015fe:	89 c7                	mov    %eax,%edi
  801600:	83 c4 20             	add    $0x20,%esp
  801603:	85 c0                	test   %eax,%eax
  801605:	78 2e                	js     801635 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801607:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80160a:	89 d0                	mov    %edx,%eax
  80160c:	c1 e8 0c             	shr    $0xc,%eax
  80160f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801616:	83 ec 0c             	sub    $0xc,%esp
  801619:	25 07 0e 00 00       	and    $0xe07,%eax
  80161e:	50                   	push   %eax
  80161f:	53                   	push   %ebx
  801620:	6a 00                	push   $0x0
  801622:	52                   	push   %edx
  801623:	6a 00                	push   $0x0
  801625:	e8 5e f9 ff ff       	call   800f88 <sys_page_map>
  80162a:	89 c7                	mov    %eax,%edi
  80162c:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80162f:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801631:	85 ff                	test   %edi,%edi
  801633:	79 1d                	jns    801652 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801635:	83 ec 08             	sub    $0x8,%esp
  801638:	53                   	push   %ebx
  801639:	6a 00                	push   $0x0
  80163b:	e8 8a f9 ff ff       	call   800fca <sys_page_unmap>
	sys_page_unmap(0, nva);
  801640:	83 c4 08             	add    $0x8,%esp
  801643:	ff 75 d4             	pushl  -0x2c(%ebp)
  801646:	6a 00                	push   $0x0
  801648:	e8 7d f9 ff ff       	call   800fca <sys_page_unmap>
	return r;
  80164d:	83 c4 10             	add    $0x10,%esp
  801650:	89 f8                	mov    %edi,%eax
}
  801652:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801655:	5b                   	pop    %ebx
  801656:	5e                   	pop    %esi
  801657:	5f                   	pop    %edi
  801658:	5d                   	pop    %ebp
  801659:	c3                   	ret    

0080165a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80165a:	55                   	push   %ebp
  80165b:	89 e5                	mov    %esp,%ebp
  80165d:	53                   	push   %ebx
  80165e:	83 ec 14             	sub    $0x14,%esp
  801661:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801664:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801667:	50                   	push   %eax
  801668:	53                   	push   %ebx
  801669:	e8 86 fd ff ff       	call   8013f4 <fd_lookup>
  80166e:	83 c4 08             	add    $0x8,%esp
  801671:	89 c2                	mov    %eax,%edx
  801673:	85 c0                	test   %eax,%eax
  801675:	78 6d                	js     8016e4 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801677:	83 ec 08             	sub    $0x8,%esp
  80167a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80167d:	50                   	push   %eax
  80167e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801681:	ff 30                	pushl  (%eax)
  801683:	e8 c2 fd ff ff       	call   80144a <dev_lookup>
  801688:	83 c4 10             	add    $0x10,%esp
  80168b:	85 c0                	test   %eax,%eax
  80168d:	78 4c                	js     8016db <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80168f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801692:	8b 42 08             	mov    0x8(%edx),%eax
  801695:	83 e0 03             	and    $0x3,%eax
  801698:	83 f8 01             	cmp    $0x1,%eax
  80169b:	75 21                	jne    8016be <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80169d:	a1 04 50 80 00       	mov    0x805004,%eax
  8016a2:	8b 40 48             	mov    0x48(%eax),%eax
  8016a5:	83 ec 04             	sub    $0x4,%esp
  8016a8:	53                   	push   %ebx
  8016a9:	50                   	push   %eax
  8016aa:	68 e1 2e 80 00       	push   $0x802ee1
  8016af:	e8 09 ef ff ff       	call   8005bd <cprintf>
		return -E_INVAL;
  8016b4:	83 c4 10             	add    $0x10,%esp
  8016b7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016bc:	eb 26                	jmp    8016e4 <read+0x8a>
	}
	if (!dev->dev_read)
  8016be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016c1:	8b 40 08             	mov    0x8(%eax),%eax
  8016c4:	85 c0                	test   %eax,%eax
  8016c6:	74 17                	je     8016df <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8016c8:	83 ec 04             	sub    $0x4,%esp
  8016cb:	ff 75 10             	pushl  0x10(%ebp)
  8016ce:	ff 75 0c             	pushl  0xc(%ebp)
  8016d1:	52                   	push   %edx
  8016d2:	ff d0                	call   *%eax
  8016d4:	89 c2                	mov    %eax,%edx
  8016d6:	83 c4 10             	add    $0x10,%esp
  8016d9:	eb 09                	jmp    8016e4 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016db:	89 c2                	mov    %eax,%edx
  8016dd:	eb 05                	jmp    8016e4 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8016df:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8016e4:	89 d0                	mov    %edx,%eax
  8016e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016e9:	c9                   	leave  
  8016ea:	c3                   	ret    

008016eb <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8016eb:	55                   	push   %ebp
  8016ec:	89 e5                	mov    %esp,%ebp
  8016ee:	57                   	push   %edi
  8016ef:	56                   	push   %esi
  8016f0:	53                   	push   %ebx
  8016f1:	83 ec 0c             	sub    $0xc,%esp
  8016f4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016f7:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016fa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016ff:	eb 21                	jmp    801722 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801701:	83 ec 04             	sub    $0x4,%esp
  801704:	89 f0                	mov    %esi,%eax
  801706:	29 d8                	sub    %ebx,%eax
  801708:	50                   	push   %eax
  801709:	89 d8                	mov    %ebx,%eax
  80170b:	03 45 0c             	add    0xc(%ebp),%eax
  80170e:	50                   	push   %eax
  80170f:	57                   	push   %edi
  801710:	e8 45 ff ff ff       	call   80165a <read>
		if (m < 0)
  801715:	83 c4 10             	add    $0x10,%esp
  801718:	85 c0                	test   %eax,%eax
  80171a:	78 10                	js     80172c <readn+0x41>
			return m;
		if (m == 0)
  80171c:	85 c0                	test   %eax,%eax
  80171e:	74 0a                	je     80172a <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801720:	01 c3                	add    %eax,%ebx
  801722:	39 f3                	cmp    %esi,%ebx
  801724:	72 db                	jb     801701 <readn+0x16>
  801726:	89 d8                	mov    %ebx,%eax
  801728:	eb 02                	jmp    80172c <readn+0x41>
  80172a:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80172c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80172f:	5b                   	pop    %ebx
  801730:	5e                   	pop    %esi
  801731:	5f                   	pop    %edi
  801732:	5d                   	pop    %ebp
  801733:	c3                   	ret    

00801734 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801734:	55                   	push   %ebp
  801735:	89 e5                	mov    %esp,%ebp
  801737:	53                   	push   %ebx
  801738:	83 ec 14             	sub    $0x14,%esp
  80173b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80173e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801741:	50                   	push   %eax
  801742:	53                   	push   %ebx
  801743:	e8 ac fc ff ff       	call   8013f4 <fd_lookup>
  801748:	83 c4 08             	add    $0x8,%esp
  80174b:	89 c2                	mov    %eax,%edx
  80174d:	85 c0                	test   %eax,%eax
  80174f:	78 68                	js     8017b9 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801751:	83 ec 08             	sub    $0x8,%esp
  801754:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801757:	50                   	push   %eax
  801758:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80175b:	ff 30                	pushl  (%eax)
  80175d:	e8 e8 fc ff ff       	call   80144a <dev_lookup>
  801762:	83 c4 10             	add    $0x10,%esp
  801765:	85 c0                	test   %eax,%eax
  801767:	78 47                	js     8017b0 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801769:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80176c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801770:	75 21                	jne    801793 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801772:	a1 04 50 80 00       	mov    0x805004,%eax
  801777:	8b 40 48             	mov    0x48(%eax),%eax
  80177a:	83 ec 04             	sub    $0x4,%esp
  80177d:	53                   	push   %ebx
  80177e:	50                   	push   %eax
  80177f:	68 fd 2e 80 00       	push   $0x802efd
  801784:	e8 34 ee ff ff       	call   8005bd <cprintf>
		return -E_INVAL;
  801789:	83 c4 10             	add    $0x10,%esp
  80178c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801791:	eb 26                	jmp    8017b9 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801793:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801796:	8b 52 0c             	mov    0xc(%edx),%edx
  801799:	85 d2                	test   %edx,%edx
  80179b:	74 17                	je     8017b4 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80179d:	83 ec 04             	sub    $0x4,%esp
  8017a0:	ff 75 10             	pushl  0x10(%ebp)
  8017a3:	ff 75 0c             	pushl  0xc(%ebp)
  8017a6:	50                   	push   %eax
  8017a7:	ff d2                	call   *%edx
  8017a9:	89 c2                	mov    %eax,%edx
  8017ab:	83 c4 10             	add    $0x10,%esp
  8017ae:	eb 09                	jmp    8017b9 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017b0:	89 c2                	mov    %eax,%edx
  8017b2:	eb 05                	jmp    8017b9 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8017b4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8017b9:	89 d0                	mov    %edx,%eax
  8017bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017be:	c9                   	leave  
  8017bf:	c3                   	ret    

008017c0 <seek>:

int
seek(int fdnum, off_t offset)
{
  8017c0:	55                   	push   %ebp
  8017c1:	89 e5                	mov    %esp,%ebp
  8017c3:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017c6:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8017c9:	50                   	push   %eax
  8017ca:	ff 75 08             	pushl  0x8(%ebp)
  8017cd:	e8 22 fc ff ff       	call   8013f4 <fd_lookup>
  8017d2:	83 c4 08             	add    $0x8,%esp
  8017d5:	85 c0                	test   %eax,%eax
  8017d7:	78 0e                	js     8017e7 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8017d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8017dc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017df:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8017e2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017e7:	c9                   	leave  
  8017e8:	c3                   	ret    

008017e9 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8017e9:	55                   	push   %ebp
  8017ea:	89 e5                	mov    %esp,%ebp
  8017ec:	53                   	push   %ebx
  8017ed:	83 ec 14             	sub    $0x14,%esp
  8017f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017f3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017f6:	50                   	push   %eax
  8017f7:	53                   	push   %ebx
  8017f8:	e8 f7 fb ff ff       	call   8013f4 <fd_lookup>
  8017fd:	83 c4 08             	add    $0x8,%esp
  801800:	89 c2                	mov    %eax,%edx
  801802:	85 c0                	test   %eax,%eax
  801804:	78 65                	js     80186b <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801806:	83 ec 08             	sub    $0x8,%esp
  801809:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80180c:	50                   	push   %eax
  80180d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801810:	ff 30                	pushl  (%eax)
  801812:	e8 33 fc ff ff       	call   80144a <dev_lookup>
  801817:	83 c4 10             	add    $0x10,%esp
  80181a:	85 c0                	test   %eax,%eax
  80181c:	78 44                	js     801862 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80181e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801821:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801825:	75 21                	jne    801848 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801827:	a1 04 50 80 00       	mov    0x805004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80182c:	8b 40 48             	mov    0x48(%eax),%eax
  80182f:	83 ec 04             	sub    $0x4,%esp
  801832:	53                   	push   %ebx
  801833:	50                   	push   %eax
  801834:	68 c0 2e 80 00       	push   $0x802ec0
  801839:	e8 7f ed ff ff       	call   8005bd <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80183e:	83 c4 10             	add    $0x10,%esp
  801841:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801846:	eb 23                	jmp    80186b <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801848:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80184b:	8b 52 18             	mov    0x18(%edx),%edx
  80184e:	85 d2                	test   %edx,%edx
  801850:	74 14                	je     801866 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801852:	83 ec 08             	sub    $0x8,%esp
  801855:	ff 75 0c             	pushl  0xc(%ebp)
  801858:	50                   	push   %eax
  801859:	ff d2                	call   *%edx
  80185b:	89 c2                	mov    %eax,%edx
  80185d:	83 c4 10             	add    $0x10,%esp
  801860:	eb 09                	jmp    80186b <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801862:	89 c2                	mov    %eax,%edx
  801864:	eb 05                	jmp    80186b <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801866:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80186b:	89 d0                	mov    %edx,%eax
  80186d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801870:	c9                   	leave  
  801871:	c3                   	ret    

00801872 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801872:	55                   	push   %ebp
  801873:	89 e5                	mov    %esp,%ebp
  801875:	53                   	push   %ebx
  801876:	83 ec 14             	sub    $0x14,%esp
  801879:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80187c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80187f:	50                   	push   %eax
  801880:	ff 75 08             	pushl  0x8(%ebp)
  801883:	e8 6c fb ff ff       	call   8013f4 <fd_lookup>
  801888:	83 c4 08             	add    $0x8,%esp
  80188b:	89 c2                	mov    %eax,%edx
  80188d:	85 c0                	test   %eax,%eax
  80188f:	78 58                	js     8018e9 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801891:	83 ec 08             	sub    $0x8,%esp
  801894:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801897:	50                   	push   %eax
  801898:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80189b:	ff 30                	pushl  (%eax)
  80189d:	e8 a8 fb ff ff       	call   80144a <dev_lookup>
  8018a2:	83 c4 10             	add    $0x10,%esp
  8018a5:	85 c0                	test   %eax,%eax
  8018a7:	78 37                	js     8018e0 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8018a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018ac:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8018b0:	74 32                	je     8018e4 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8018b2:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8018b5:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8018bc:	00 00 00 
	stat->st_isdir = 0;
  8018bf:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018c6:	00 00 00 
	stat->st_dev = dev;
  8018c9:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8018cf:	83 ec 08             	sub    $0x8,%esp
  8018d2:	53                   	push   %ebx
  8018d3:	ff 75 f0             	pushl  -0x10(%ebp)
  8018d6:	ff 50 14             	call   *0x14(%eax)
  8018d9:	89 c2                	mov    %eax,%edx
  8018db:	83 c4 10             	add    $0x10,%esp
  8018de:	eb 09                	jmp    8018e9 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018e0:	89 c2                	mov    %eax,%edx
  8018e2:	eb 05                	jmp    8018e9 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8018e4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8018e9:	89 d0                	mov    %edx,%eax
  8018eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018ee:	c9                   	leave  
  8018ef:	c3                   	ret    

008018f0 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8018f0:	55                   	push   %ebp
  8018f1:	89 e5                	mov    %esp,%ebp
  8018f3:	56                   	push   %esi
  8018f4:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8018f5:	83 ec 08             	sub    $0x8,%esp
  8018f8:	6a 00                	push   $0x0
  8018fa:	ff 75 08             	pushl  0x8(%ebp)
  8018fd:	e8 0c 02 00 00       	call   801b0e <open>
  801902:	89 c3                	mov    %eax,%ebx
  801904:	83 c4 10             	add    $0x10,%esp
  801907:	85 c0                	test   %eax,%eax
  801909:	78 1b                	js     801926 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80190b:	83 ec 08             	sub    $0x8,%esp
  80190e:	ff 75 0c             	pushl  0xc(%ebp)
  801911:	50                   	push   %eax
  801912:	e8 5b ff ff ff       	call   801872 <fstat>
  801917:	89 c6                	mov    %eax,%esi
	close(fd);
  801919:	89 1c 24             	mov    %ebx,(%esp)
  80191c:	e8 fd fb ff ff       	call   80151e <close>
	return r;
  801921:	83 c4 10             	add    $0x10,%esp
  801924:	89 f0                	mov    %esi,%eax
}
  801926:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801929:	5b                   	pop    %ebx
  80192a:	5e                   	pop    %esi
  80192b:	5d                   	pop    %ebp
  80192c:	c3                   	ret    

0080192d <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80192d:	55                   	push   %ebp
  80192e:	89 e5                	mov    %esp,%ebp
  801930:	56                   	push   %esi
  801931:	53                   	push   %ebx
  801932:	89 c6                	mov    %eax,%esi
  801934:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801936:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80193d:	75 12                	jne    801951 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80193f:	83 ec 0c             	sub    $0xc,%esp
  801942:	6a 01                	push   $0x1
  801944:	e8 fb 0c 00 00       	call   802644 <ipc_find_env>
  801949:	a3 00 50 80 00       	mov    %eax,0x805000
  80194e:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801951:	6a 07                	push   $0x7
  801953:	68 00 60 80 00       	push   $0x806000
  801958:	56                   	push   %esi
  801959:	ff 35 00 50 80 00    	pushl  0x805000
  80195f:	e8 8c 0c 00 00       	call   8025f0 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801964:	83 c4 0c             	add    $0xc,%esp
  801967:	6a 00                	push   $0x0
  801969:	53                   	push   %ebx
  80196a:	6a 00                	push   $0x0
  80196c:	e8 16 0c 00 00       	call   802587 <ipc_recv>
}
  801971:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801974:	5b                   	pop    %ebx
  801975:	5e                   	pop    %esi
  801976:	5d                   	pop    %ebp
  801977:	c3                   	ret    

00801978 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801978:	55                   	push   %ebp
  801979:	89 e5                	mov    %esp,%ebp
  80197b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80197e:	8b 45 08             	mov    0x8(%ebp),%eax
  801981:	8b 40 0c             	mov    0xc(%eax),%eax
  801984:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801989:	8b 45 0c             	mov    0xc(%ebp),%eax
  80198c:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801991:	ba 00 00 00 00       	mov    $0x0,%edx
  801996:	b8 02 00 00 00       	mov    $0x2,%eax
  80199b:	e8 8d ff ff ff       	call   80192d <fsipc>
}
  8019a0:	c9                   	leave  
  8019a1:	c3                   	ret    

008019a2 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8019a2:	55                   	push   %ebp
  8019a3:	89 e5                	mov    %esp,%ebp
  8019a5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8019a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ab:	8b 40 0c             	mov    0xc(%eax),%eax
  8019ae:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  8019b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8019b8:	b8 06 00 00 00       	mov    $0x6,%eax
  8019bd:	e8 6b ff ff ff       	call   80192d <fsipc>
}
  8019c2:	c9                   	leave  
  8019c3:	c3                   	ret    

008019c4 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8019c4:	55                   	push   %ebp
  8019c5:	89 e5                	mov    %esp,%ebp
  8019c7:	53                   	push   %ebx
  8019c8:	83 ec 04             	sub    $0x4,%esp
  8019cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8019ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d1:	8b 40 0c             	mov    0xc(%eax),%eax
  8019d4:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8019d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8019de:	b8 05 00 00 00       	mov    $0x5,%eax
  8019e3:	e8 45 ff ff ff       	call   80192d <fsipc>
  8019e8:	85 c0                	test   %eax,%eax
  8019ea:	78 2c                	js     801a18 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8019ec:	83 ec 08             	sub    $0x8,%esp
  8019ef:	68 00 60 80 00       	push   $0x806000
  8019f4:	53                   	push   %ebx
  8019f5:	e8 48 f1 ff ff       	call   800b42 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8019fa:	a1 80 60 80 00       	mov    0x806080,%eax
  8019ff:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a05:	a1 84 60 80 00       	mov    0x806084,%eax
  801a0a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a10:	83 c4 10             	add    $0x10,%esp
  801a13:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a18:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a1b:	c9                   	leave  
  801a1c:	c3                   	ret    

00801a1d <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801a1d:	55                   	push   %ebp
  801a1e:	89 e5                	mov    %esp,%ebp
  801a20:	53                   	push   %ebx
  801a21:	83 ec 08             	sub    $0x8,%esp
  801a24:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801a27:	8b 55 08             	mov    0x8(%ebp),%edx
  801a2a:	8b 52 0c             	mov    0xc(%edx),%edx
  801a2d:	89 15 00 60 80 00    	mov    %edx,0x806000
  801a33:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801a38:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  801a3d:	0f 46 d8             	cmovbe %eax,%ebx
	
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  801a40:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  801a46:	53                   	push   %ebx
  801a47:	ff 75 0c             	pushl  0xc(%ebp)
  801a4a:	68 08 60 80 00       	push   $0x806008
  801a4f:	e8 80 f2 ff ff       	call   800cd4 <memmove>

	
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) 
  801a54:	ba 00 00 00 00       	mov    $0x0,%edx
  801a59:	b8 04 00 00 00       	mov    $0x4,%eax
  801a5e:	e8 ca fe ff ff       	call   80192d <fsipc>
  801a63:	83 c4 10             	add    $0x10,%esp
  801a66:	85 c0                	test   %eax,%eax
  801a68:	78 1d                	js     801a87 <devfile_write+0x6a>
		return r;
	assert(r <= n_real); 
  801a6a:	39 d8                	cmp    %ebx,%eax
  801a6c:	76 19                	jbe    801a87 <devfile_write+0x6a>
  801a6e:	68 2c 2f 80 00       	push   $0x802f2c
  801a73:	68 38 2f 80 00       	push   $0x802f38
  801a78:	68 a3 00 00 00       	push   $0xa3
  801a7d:	68 4d 2f 80 00       	push   $0x802f4d
  801a82:	e8 5d ea ff ff       	call   8004e4 <_panic>
	return r;
}
  801a87:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a8a:	c9                   	leave  
  801a8b:	c3                   	ret    

00801a8c <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801a8c:	55                   	push   %ebp
  801a8d:	89 e5                	mov    %esp,%ebp
  801a8f:	56                   	push   %esi
  801a90:	53                   	push   %ebx
  801a91:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a94:	8b 45 08             	mov    0x8(%ebp),%eax
  801a97:	8b 40 0c             	mov    0xc(%eax),%eax
  801a9a:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801a9f:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801aa5:	ba 00 00 00 00       	mov    $0x0,%edx
  801aaa:	b8 03 00 00 00       	mov    $0x3,%eax
  801aaf:	e8 79 fe ff ff       	call   80192d <fsipc>
  801ab4:	89 c3                	mov    %eax,%ebx
  801ab6:	85 c0                	test   %eax,%eax
  801ab8:	78 4b                	js     801b05 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801aba:	39 c6                	cmp    %eax,%esi
  801abc:	73 16                	jae    801ad4 <devfile_read+0x48>
  801abe:	68 58 2f 80 00       	push   $0x802f58
  801ac3:	68 38 2f 80 00       	push   $0x802f38
  801ac8:	6a 7c                	push   $0x7c
  801aca:	68 4d 2f 80 00       	push   $0x802f4d
  801acf:	e8 10 ea ff ff       	call   8004e4 <_panic>
	assert(r <= PGSIZE);
  801ad4:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801ad9:	7e 16                	jle    801af1 <devfile_read+0x65>
  801adb:	68 5f 2f 80 00       	push   $0x802f5f
  801ae0:	68 38 2f 80 00       	push   $0x802f38
  801ae5:	6a 7d                	push   $0x7d
  801ae7:	68 4d 2f 80 00       	push   $0x802f4d
  801aec:	e8 f3 e9 ff ff       	call   8004e4 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801af1:	83 ec 04             	sub    $0x4,%esp
  801af4:	50                   	push   %eax
  801af5:	68 00 60 80 00       	push   $0x806000
  801afa:	ff 75 0c             	pushl  0xc(%ebp)
  801afd:	e8 d2 f1 ff ff       	call   800cd4 <memmove>
	return r;
  801b02:	83 c4 10             	add    $0x10,%esp
}
  801b05:	89 d8                	mov    %ebx,%eax
  801b07:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b0a:	5b                   	pop    %ebx
  801b0b:	5e                   	pop    %esi
  801b0c:	5d                   	pop    %ebp
  801b0d:	c3                   	ret    

00801b0e <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801b0e:	55                   	push   %ebp
  801b0f:	89 e5                	mov    %esp,%ebp
  801b11:	53                   	push   %ebx
  801b12:	83 ec 20             	sub    $0x20,%esp
  801b15:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801b18:	53                   	push   %ebx
  801b19:	e8 eb ef ff ff       	call   800b09 <strlen>
  801b1e:	83 c4 10             	add    $0x10,%esp
  801b21:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b26:	7f 67                	jg     801b8f <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b28:	83 ec 0c             	sub    $0xc,%esp
  801b2b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b2e:	50                   	push   %eax
  801b2f:	e8 71 f8 ff ff       	call   8013a5 <fd_alloc>
  801b34:	83 c4 10             	add    $0x10,%esp
		return r;
  801b37:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b39:	85 c0                	test   %eax,%eax
  801b3b:	78 57                	js     801b94 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801b3d:	83 ec 08             	sub    $0x8,%esp
  801b40:	53                   	push   %ebx
  801b41:	68 00 60 80 00       	push   $0x806000
  801b46:	e8 f7 ef ff ff       	call   800b42 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b4b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b4e:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b53:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b56:	b8 01 00 00 00       	mov    $0x1,%eax
  801b5b:	e8 cd fd ff ff       	call   80192d <fsipc>
  801b60:	89 c3                	mov    %eax,%ebx
  801b62:	83 c4 10             	add    $0x10,%esp
  801b65:	85 c0                	test   %eax,%eax
  801b67:	79 14                	jns    801b7d <open+0x6f>
		fd_close(fd, 0);
  801b69:	83 ec 08             	sub    $0x8,%esp
  801b6c:	6a 00                	push   $0x0
  801b6e:	ff 75 f4             	pushl  -0xc(%ebp)
  801b71:	e8 27 f9 ff ff       	call   80149d <fd_close>
		return r;
  801b76:	83 c4 10             	add    $0x10,%esp
  801b79:	89 da                	mov    %ebx,%edx
  801b7b:	eb 17                	jmp    801b94 <open+0x86>
	}

	return fd2num(fd);
  801b7d:	83 ec 0c             	sub    $0xc,%esp
  801b80:	ff 75 f4             	pushl  -0xc(%ebp)
  801b83:	e8 f6 f7 ff ff       	call   80137e <fd2num>
  801b88:	89 c2                	mov    %eax,%edx
  801b8a:	83 c4 10             	add    $0x10,%esp
  801b8d:	eb 05                	jmp    801b94 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801b8f:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801b94:	89 d0                	mov    %edx,%eax
  801b96:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b99:	c9                   	leave  
  801b9a:	c3                   	ret    

00801b9b <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b9b:	55                   	push   %ebp
  801b9c:	89 e5                	mov    %esp,%ebp
  801b9e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801ba1:	ba 00 00 00 00       	mov    $0x0,%edx
  801ba6:	b8 08 00 00 00       	mov    $0x8,%eax
  801bab:	e8 7d fd ff ff       	call   80192d <fsipc>
}
  801bb0:	c9                   	leave  
  801bb1:	c3                   	ret    

00801bb2 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801bb2:	55                   	push   %ebp
  801bb3:	89 e5                	mov    %esp,%ebp
  801bb5:	57                   	push   %edi
  801bb6:	56                   	push   %esi
  801bb7:	53                   	push   %ebx
  801bb8:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801bbe:	6a 00                	push   $0x0
  801bc0:	ff 75 08             	pushl  0x8(%ebp)
  801bc3:	e8 46 ff ff ff       	call   801b0e <open>
  801bc8:	89 c7                	mov    %eax,%edi
  801bca:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801bd0:	83 c4 10             	add    $0x10,%esp
  801bd3:	85 c0                	test   %eax,%eax
  801bd5:	0f 88 ae 04 00 00    	js     802089 <spawn+0x4d7>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801bdb:	83 ec 04             	sub    $0x4,%esp
  801bde:	68 00 02 00 00       	push   $0x200
  801be3:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801be9:	50                   	push   %eax
  801bea:	57                   	push   %edi
  801beb:	e8 fb fa ff ff       	call   8016eb <readn>
  801bf0:	83 c4 10             	add    $0x10,%esp
  801bf3:	3d 00 02 00 00       	cmp    $0x200,%eax
  801bf8:	75 0c                	jne    801c06 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  801bfa:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801c01:	45 4c 46 
  801c04:	74 33                	je     801c39 <spawn+0x87>
		close(fd);
  801c06:	83 ec 0c             	sub    $0xc,%esp
  801c09:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801c0f:	e8 0a f9 ff ff       	call   80151e <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801c14:	83 c4 0c             	add    $0xc,%esp
  801c17:	68 7f 45 4c 46       	push   $0x464c457f
  801c1c:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801c22:	68 6b 2f 80 00       	push   $0x802f6b
  801c27:	e8 91 e9 ff ff       	call   8005bd <cprintf>
		return -E_NOT_EXEC;
  801c2c:	83 c4 10             	add    $0x10,%esp
  801c2f:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801c34:	e9 b0 04 00 00       	jmp    8020e9 <spawn+0x537>
  801c39:	b8 07 00 00 00       	mov    $0x7,%eax
  801c3e:	cd 30                	int    $0x30
  801c40:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801c46:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801c4c:	85 c0                	test   %eax,%eax
  801c4e:	0f 88 3d 04 00 00    	js     802091 <spawn+0x4df>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801c54:	89 c6                	mov    %eax,%esi
  801c56:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801c5c:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801c5f:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801c65:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801c6b:	b9 11 00 00 00       	mov    $0x11,%ecx
  801c70:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801c72:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801c78:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801c7e:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801c83:	be 00 00 00 00       	mov    $0x0,%esi
  801c88:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801c8b:	eb 13                	jmp    801ca0 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801c8d:	83 ec 0c             	sub    $0xc,%esp
  801c90:	50                   	push   %eax
  801c91:	e8 73 ee ff ff       	call   800b09 <strlen>
  801c96:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801c9a:	83 c3 01             	add    $0x1,%ebx
  801c9d:	83 c4 10             	add    $0x10,%esp
  801ca0:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801ca7:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801caa:	85 c0                	test   %eax,%eax
  801cac:	75 df                	jne    801c8d <spawn+0xdb>
  801cae:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801cb4:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801cba:	bf 00 10 40 00       	mov    $0x401000,%edi
  801cbf:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801cc1:	89 fa                	mov    %edi,%edx
  801cc3:	83 e2 fc             	and    $0xfffffffc,%edx
  801cc6:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801ccd:	29 c2                	sub    %eax,%edx
  801ccf:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801cd5:	8d 42 f8             	lea    -0x8(%edx),%eax
  801cd8:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801cdd:	0f 86 be 03 00 00    	jbe    8020a1 <spawn+0x4ef>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801ce3:	83 ec 04             	sub    $0x4,%esp
  801ce6:	6a 07                	push   $0x7
  801ce8:	68 00 00 40 00       	push   $0x400000
  801ced:	6a 00                	push   $0x0
  801cef:	e8 51 f2 ff ff       	call   800f45 <sys_page_alloc>
  801cf4:	83 c4 10             	add    $0x10,%esp
  801cf7:	85 c0                	test   %eax,%eax
  801cf9:	0f 88 a9 03 00 00    	js     8020a8 <spawn+0x4f6>
  801cff:	be 00 00 00 00       	mov    $0x0,%esi
  801d04:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801d0a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801d0d:	eb 30                	jmp    801d3f <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801d0f:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801d15:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801d1b:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801d1e:	83 ec 08             	sub    $0x8,%esp
  801d21:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801d24:	57                   	push   %edi
  801d25:	e8 18 ee ff ff       	call   800b42 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801d2a:	83 c4 04             	add    $0x4,%esp
  801d2d:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801d30:	e8 d4 ed ff ff       	call   800b09 <strlen>
  801d35:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801d39:	83 c6 01             	add    $0x1,%esi
  801d3c:	83 c4 10             	add    $0x10,%esp
  801d3f:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801d45:	7f c8                	jg     801d0f <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801d47:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801d4d:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801d53:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801d5a:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801d60:	74 19                	je     801d7b <spawn+0x1c9>
  801d62:	68 c8 2f 80 00       	push   $0x802fc8
  801d67:	68 38 2f 80 00       	push   $0x802f38
  801d6c:	68 f2 00 00 00       	push   $0xf2
  801d71:	68 85 2f 80 00       	push   $0x802f85
  801d76:	e8 69 e7 ff ff       	call   8004e4 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801d7b:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801d81:	89 f8                	mov    %edi,%eax
  801d83:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801d88:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801d8b:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801d91:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801d94:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801d9a:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801da0:	83 ec 0c             	sub    $0xc,%esp
  801da3:	6a 07                	push   $0x7
  801da5:	68 00 d0 bf ee       	push   $0xeebfd000
  801daa:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801db0:	68 00 00 40 00       	push   $0x400000
  801db5:	6a 00                	push   $0x0
  801db7:	e8 cc f1 ff ff       	call   800f88 <sys_page_map>
  801dbc:	89 c3                	mov    %eax,%ebx
  801dbe:	83 c4 20             	add    $0x20,%esp
  801dc1:	85 c0                	test   %eax,%eax
  801dc3:	0f 88 0e 03 00 00    	js     8020d7 <spawn+0x525>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801dc9:	83 ec 08             	sub    $0x8,%esp
  801dcc:	68 00 00 40 00       	push   $0x400000
  801dd1:	6a 00                	push   $0x0
  801dd3:	e8 f2 f1 ff ff       	call   800fca <sys_page_unmap>
  801dd8:	89 c3                	mov    %eax,%ebx
  801dda:	83 c4 10             	add    $0x10,%esp
  801ddd:	85 c0                	test   %eax,%eax
  801ddf:	0f 88 f2 02 00 00    	js     8020d7 <spawn+0x525>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801de5:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801deb:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801df2:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801df8:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801dff:	00 00 00 
  801e02:	e9 88 01 00 00       	jmp    801f8f <spawn+0x3dd>
		if (ph->p_type != ELF_PROG_LOAD)
  801e07:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801e0d:	83 38 01             	cmpl   $0x1,(%eax)
  801e10:	0f 85 6b 01 00 00    	jne    801f81 <spawn+0x3cf>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801e16:	89 c7                	mov    %eax,%edi
  801e18:	8b 40 18             	mov    0x18(%eax),%eax
  801e1b:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801e21:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801e24:	83 f8 01             	cmp    $0x1,%eax
  801e27:	19 c0                	sbb    %eax,%eax
  801e29:	83 e0 fe             	and    $0xfffffffe,%eax
  801e2c:	83 c0 07             	add    $0x7,%eax
  801e2f:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801e35:	89 f8                	mov    %edi,%eax
  801e37:	8b 7f 04             	mov    0x4(%edi),%edi
  801e3a:	89 f9                	mov    %edi,%ecx
  801e3c:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801e42:	8b 78 10             	mov    0x10(%eax),%edi
  801e45:	8b 50 14             	mov    0x14(%eax),%edx
  801e48:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  801e4e:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801e51:	89 f0                	mov    %esi,%eax
  801e53:	25 ff 0f 00 00       	and    $0xfff,%eax
  801e58:	74 14                	je     801e6e <spawn+0x2bc>
		va -= i;
  801e5a:	29 c6                	sub    %eax,%esi
		memsz += i;
  801e5c:	01 c2                	add    %eax,%edx
  801e5e:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  801e64:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801e66:	29 c1                	sub    %eax,%ecx
  801e68:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801e6e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e73:	e9 f7 00 00 00       	jmp    801f6f <spawn+0x3bd>
		if (i >= filesz) {
  801e78:	39 df                	cmp    %ebx,%edi
  801e7a:	77 27                	ja     801ea3 <spawn+0x2f1>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801e7c:	83 ec 04             	sub    $0x4,%esp
  801e7f:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801e85:	56                   	push   %esi
  801e86:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801e8c:	e8 b4 f0 ff ff       	call   800f45 <sys_page_alloc>
  801e91:	83 c4 10             	add    $0x10,%esp
  801e94:	85 c0                	test   %eax,%eax
  801e96:	0f 89 c7 00 00 00    	jns    801f63 <spawn+0x3b1>
  801e9c:	89 c3                	mov    %eax,%ebx
  801e9e:	e9 13 02 00 00       	jmp    8020b6 <spawn+0x504>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801ea3:	83 ec 04             	sub    $0x4,%esp
  801ea6:	6a 07                	push   $0x7
  801ea8:	68 00 00 40 00       	push   $0x400000
  801ead:	6a 00                	push   $0x0
  801eaf:	e8 91 f0 ff ff       	call   800f45 <sys_page_alloc>
  801eb4:	83 c4 10             	add    $0x10,%esp
  801eb7:	85 c0                	test   %eax,%eax
  801eb9:	0f 88 ed 01 00 00    	js     8020ac <spawn+0x4fa>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801ebf:	83 ec 08             	sub    $0x8,%esp
  801ec2:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801ec8:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801ece:	50                   	push   %eax
  801ecf:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801ed5:	e8 e6 f8 ff ff       	call   8017c0 <seek>
  801eda:	83 c4 10             	add    $0x10,%esp
  801edd:	85 c0                	test   %eax,%eax
  801edf:	0f 88 cb 01 00 00    	js     8020b0 <spawn+0x4fe>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801ee5:	83 ec 04             	sub    $0x4,%esp
  801ee8:	89 f8                	mov    %edi,%eax
  801eea:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801ef0:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801ef5:	ba 00 10 00 00       	mov    $0x1000,%edx
  801efa:	0f 47 c2             	cmova  %edx,%eax
  801efd:	50                   	push   %eax
  801efe:	68 00 00 40 00       	push   $0x400000
  801f03:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801f09:	e8 dd f7 ff ff       	call   8016eb <readn>
  801f0e:	83 c4 10             	add    $0x10,%esp
  801f11:	85 c0                	test   %eax,%eax
  801f13:	0f 88 9b 01 00 00    	js     8020b4 <spawn+0x502>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801f19:	83 ec 0c             	sub    $0xc,%esp
  801f1c:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801f22:	56                   	push   %esi
  801f23:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801f29:	68 00 00 40 00       	push   $0x400000
  801f2e:	6a 00                	push   $0x0
  801f30:	e8 53 f0 ff ff       	call   800f88 <sys_page_map>
  801f35:	83 c4 20             	add    $0x20,%esp
  801f38:	85 c0                	test   %eax,%eax
  801f3a:	79 15                	jns    801f51 <spawn+0x39f>
				panic("spawn: sys_page_map data: %e", r);
  801f3c:	50                   	push   %eax
  801f3d:	68 91 2f 80 00       	push   $0x802f91
  801f42:	68 25 01 00 00       	push   $0x125
  801f47:	68 85 2f 80 00       	push   $0x802f85
  801f4c:	e8 93 e5 ff ff       	call   8004e4 <_panic>
			sys_page_unmap(0, UTEMP);
  801f51:	83 ec 08             	sub    $0x8,%esp
  801f54:	68 00 00 40 00       	push   $0x400000
  801f59:	6a 00                	push   $0x0
  801f5b:	e8 6a f0 ff ff       	call   800fca <sys_page_unmap>
  801f60:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801f63:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801f69:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801f6f:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801f75:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  801f7b:	0f 87 f7 fe ff ff    	ja     801e78 <spawn+0x2c6>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801f81:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801f88:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801f8f:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801f96:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801f9c:	0f 8c 65 fe ff ff    	jl     801e07 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801fa2:	83 ec 0c             	sub    $0xc,%esp
  801fa5:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801fab:	e8 6e f5 ff ff       	call   80151e <close>
  801fb0:	83 c4 10             	add    $0x10,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	uintptr_t i;
	for (i = 0; i < USTACKTOP; i += PGSIZE){
  801fb3:	bb 00 00 00 00       	mov    $0x0,%ebx
  801fb8:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[PGNUM(i)] & PTE_P) && (uvpt[PGNUM(i)] & PTE_U) && (uvpt[PGNUM(i)] & PTE_SHARE)){
  801fbe:	89 d8                	mov    %ebx,%eax
  801fc0:	c1 e8 16             	shr    $0x16,%eax
  801fc3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801fca:	a8 01                	test   $0x1,%al
  801fcc:	74 46                	je     802014 <spawn+0x462>
  801fce:	89 d8                	mov    %ebx,%eax
  801fd0:	c1 e8 0c             	shr    $0xc,%eax
  801fd3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801fda:	f6 c2 01             	test   $0x1,%dl
  801fdd:	74 35                	je     802014 <spawn+0x462>
  801fdf:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801fe6:	f6 c2 04             	test   $0x4,%dl
  801fe9:	74 29                	je     802014 <spawn+0x462>
  801feb:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801ff2:	f6 c6 04             	test   $0x4,%dh
  801ff5:	74 1d                	je     802014 <spawn+0x462>
			sys_page_map(0, (void*)i,child, (void*)i,(uvpt[PGNUM(i)] & PTE_SYSCALL));
  801ff7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801ffe:	83 ec 0c             	sub    $0xc,%esp
  802001:	25 07 0e 00 00       	and    $0xe07,%eax
  802006:	50                   	push   %eax
  802007:	53                   	push   %ebx
  802008:	56                   	push   %esi
  802009:	53                   	push   %ebx
  80200a:	6a 00                	push   $0x0
  80200c:	e8 77 ef ff ff       	call   800f88 <sys_page_map>
  802011:	83 c4 20             	add    $0x20,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	uintptr_t i;
	for (i = 0; i < USTACKTOP; i += PGSIZE){
  802014:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80201a:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  802020:	75 9c                	jne    801fbe <spawn+0x40c>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  802022:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  802029:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  80202c:	83 ec 08             	sub    $0x8,%esp
  80202f:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  802035:	50                   	push   %eax
  802036:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  80203c:	e8 0d f0 ff ff       	call   80104e <sys_env_set_trapframe>
  802041:	83 c4 10             	add    $0x10,%esp
  802044:	85 c0                	test   %eax,%eax
  802046:	79 15                	jns    80205d <spawn+0x4ab>
		panic("sys_env_set_trapframe: %e", r);
  802048:	50                   	push   %eax
  802049:	68 ae 2f 80 00       	push   $0x802fae
  80204e:	68 86 00 00 00       	push   $0x86
  802053:	68 85 2f 80 00       	push   $0x802f85
  802058:	e8 87 e4 ff ff       	call   8004e4 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  80205d:	83 ec 08             	sub    $0x8,%esp
  802060:	6a 02                	push   $0x2
  802062:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802068:	e8 9f ef ff ff       	call   80100c <sys_env_set_status>
  80206d:	83 c4 10             	add    $0x10,%esp
  802070:	85 c0                	test   %eax,%eax
  802072:	79 25                	jns    802099 <spawn+0x4e7>
		panic("sys_env_set_status: %e", r);
  802074:	50                   	push   %eax
  802075:	68 3c 2e 80 00       	push   $0x802e3c
  80207a:	68 89 00 00 00       	push   $0x89
  80207f:	68 85 2f 80 00       	push   $0x802f85
  802084:	e8 5b e4 ff ff       	call   8004e4 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  802089:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  80208f:	eb 58                	jmp    8020e9 <spawn+0x537>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  802091:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  802097:	eb 50                	jmp    8020e9 <spawn+0x537>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  802099:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  80209f:	eb 48                	jmp    8020e9 <spawn+0x537>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  8020a1:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  8020a6:	eb 41                	jmp    8020e9 <spawn+0x537>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  8020a8:	89 c3                	mov    %eax,%ebx
  8020aa:	eb 3d                	jmp    8020e9 <spawn+0x537>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8020ac:	89 c3                	mov    %eax,%ebx
  8020ae:	eb 06                	jmp    8020b6 <spawn+0x504>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  8020b0:	89 c3                	mov    %eax,%ebx
  8020b2:	eb 02                	jmp    8020b6 <spawn+0x504>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  8020b4:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  8020b6:	83 ec 0c             	sub    $0xc,%esp
  8020b9:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8020bf:	e8 02 ee ff ff       	call   800ec6 <sys_env_destroy>
	close(fd);
  8020c4:	83 c4 04             	add    $0x4,%esp
  8020c7:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8020cd:	e8 4c f4 ff ff       	call   80151e <close>
	return r;
  8020d2:	83 c4 10             	add    $0x10,%esp
  8020d5:	eb 12                	jmp    8020e9 <spawn+0x537>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  8020d7:	83 ec 08             	sub    $0x8,%esp
  8020da:	68 00 00 40 00       	push   $0x400000
  8020df:	6a 00                	push   $0x0
  8020e1:	e8 e4 ee ff ff       	call   800fca <sys_page_unmap>
  8020e6:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  8020e9:	89 d8                	mov    %ebx,%eax
  8020eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020ee:	5b                   	pop    %ebx
  8020ef:	5e                   	pop    %esi
  8020f0:	5f                   	pop    %edi
  8020f1:	5d                   	pop    %ebp
  8020f2:	c3                   	ret    

008020f3 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  8020f3:	55                   	push   %ebp
  8020f4:	89 e5                	mov    %esp,%ebp
  8020f6:	56                   	push   %esi
  8020f7:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8020f8:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  8020fb:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802100:	eb 03                	jmp    802105 <spawnl+0x12>
		argc++;
  802102:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802105:	83 c2 04             	add    $0x4,%edx
  802108:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  80210c:	75 f4                	jne    802102 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  80210e:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  802115:	83 e2 f0             	and    $0xfffffff0,%edx
  802118:	29 d4                	sub    %edx,%esp
  80211a:	8d 54 24 03          	lea    0x3(%esp),%edx
  80211e:	c1 ea 02             	shr    $0x2,%edx
  802121:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  802128:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  80212a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80212d:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  802134:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  80213b:	00 
  80213c:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  80213e:	b8 00 00 00 00       	mov    $0x0,%eax
  802143:	eb 0a                	jmp    80214f <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  802145:	83 c0 01             	add    $0x1,%eax
  802148:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  80214c:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  80214f:	39 d0                	cmp    %edx,%eax
  802151:	75 f2                	jne    802145 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802153:	83 ec 08             	sub    $0x8,%esp
  802156:	56                   	push   %esi
  802157:	ff 75 08             	pushl  0x8(%ebp)
  80215a:	e8 53 fa ff ff       	call   801bb2 <spawn>
}
  80215f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802162:	5b                   	pop    %ebx
  802163:	5e                   	pop    %esi
  802164:	5d                   	pop    %ebp
  802165:	c3                   	ret    

00802166 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802166:	55                   	push   %ebp
  802167:	89 e5                	mov    %esp,%ebp
  802169:	56                   	push   %esi
  80216a:	53                   	push   %ebx
  80216b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80216e:	83 ec 0c             	sub    $0xc,%esp
  802171:	ff 75 08             	pushl  0x8(%ebp)
  802174:	e8 15 f2 ff ff       	call   80138e <fd2data>
  802179:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80217b:	83 c4 08             	add    $0x8,%esp
  80217e:	68 f0 2f 80 00       	push   $0x802ff0
  802183:	53                   	push   %ebx
  802184:	e8 b9 e9 ff ff       	call   800b42 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802189:	8b 46 04             	mov    0x4(%esi),%eax
  80218c:	2b 06                	sub    (%esi),%eax
  80218e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802194:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80219b:	00 00 00 
	stat->st_dev = &devpipe;
  80219e:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  8021a5:	40 80 00 
	return 0;
}
  8021a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8021ad:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021b0:	5b                   	pop    %ebx
  8021b1:	5e                   	pop    %esi
  8021b2:	5d                   	pop    %ebp
  8021b3:	c3                   	ret    

008021b4 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8021b4:	55                   	push   %ebp
  8021b5:	89 e5                	mov    %esp,%ebp
  8021b7:	53                   	push   %ebx
  8021b8:	83 ec 0c             	sub    $0xc,%esp
  8021bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8021be:	53                   	push   %ebx
  8021bf:	6a 00                	push   $0x0
  8021c1:	e8 04 ee ff ff       	call   800fca <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8021c6:	89 1c 24             	mov    %ebx,(%esp)
  8021c9:	e8 c0 f1 ff ff       	call   80138e <fd2data>
  8021ce:	83 c4 08             	add    $0x8,%esp
  8021d1:	50                   	push   %eax
  8021d2:	6a 00                	push   $0x0
  8021d4:	e8 f1 ed ff ff       	call   800fca <sys_page_unmap>
}
  8021d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8021dc:	c9                   	leave  
  8021dd:	c3                   	ret    

008021de <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8021de:	55                   	push   %ebp
  8021df:	89 e5                	mov    %esp,%ebp
  8021e1:	57                   	push   %edi
  8021e2:	56                   	push   %esi
  8021e3:	53                   	push   %ebx
  8021e4:	83 ec 1c             	sub    $0x1c,%esp
  8021e7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8021ea:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8021ec:	a1 04 50 80 00       	mov    0x805004,%eax
  8021f1:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8021f4:	83 ec 0c             	sub    $0xc,%esp
  8021f7:	ff 75 e0             	pushl  -0x20(%ebp)
  8021fa:	e8 7e 04 00 00       	call   80267d <pageref>
  8021ff:	89 c3                	mov    %eax,%ebx
  802201:	89 3c 24             	mov    %edi,(%esp)
  802204:	e8 74 04 00 00       	call   80267d <pageref>
  802209:	83 c4 10             	add    $0x10,%esp
  80220c:	39 c3                	cmp    %eax,%ebx
  80220e:	0f 94 c1             	sete   %cl
  802211:	0f b6 c9             	movzbl %cl,%ecx
  802214:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  802217:	8b 15 04 50 80 00    	mov    0x805004,%edx
  80221d:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802220:	39 ce                	cmp    %ecx,%esi
  802222:	74 1b                	je     80223f <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802224:	39 c3                	cmp    %eax,%ebx
  802226:	75 c4                	jne    8021ec <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802228:	8b 42 58             	mov    0x58(%edx),%eax
  80222b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80222e:	50                   	push   %eax
  80222f:	56                   	push   %esi
  802230:	68 f7 2f 80 00       	push   $0x802ff7
  802235:	e8 83 e3 ff ff       	call   8005bd <cprintf>
  80223a:	83 c4 10             	add    $0x10,%esp
  80223d:	eb ad                	jmp    8021ec <_pipeisclosed+0xe>
	}
}
  80223f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802242:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802245:	5b                   	pop    %ebx
  802246:	5e                   	pop    %esi
  802247:	5f                   	pop    %edi
  802248:	5d                   	pop    %ebp
  802249:	c3                   	ret    

0080224a <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80224a:	55                   	push   %ebp
  80224b:	89 e5                	mov    %esp,%ebp
  80224d:	57                   	push   %edi
  80224e:	56                   	push   %esi
  80224f:	53                   	push   %ebx
  802250:	83 ec 28             	sub    $0x28,%esp
  802253:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802256:	56                   	push   %esi
  802257:	e8 32 f1 ff ff       	call   80138e <fd2data>
  80225c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80225e:	83 c4 10             	add    $0x10,%esp
  802261:	bf 00 00 00 00       	mov    $0x0,%edi
  802266:	eb 4b                	jmp    8022b3 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802268:	89 da                	mov    %ebx,%edx
  80226a:	89 f0                	mov    %esi,%eax
  80226c:	e8 6d ff ff ff       	call   8021de <_pipeisclosed>
  802271:	85 c0                	test   %eax,%eax
  802273:	75 48                	jne    8022bd <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802275:	e8 ac ec ff ff       	call   800f26 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80227a:	8b 43 04             	mov    0x4(%ebx),%eax
  80227d:	8b 0b                	mov    (%ebx),%ecx
  80227f:	8d 51 20             	lea    0x20(%ecx),%edx
  802282:	39 d0                	cmp    %edx,%eax
  802284:	73 e2                	jae    802268 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802286:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802289:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80228d:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802290:	89 c2                	mov    %eax,%edx
  802292:	c1 fa 1f             	sar    $0x1f,%edx
  802295:	89 d1                	mov    %edx,%ecx
  802297:	c1 e9 1b             	shr    $0x1b,%ecx
  80229a:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80229d:	83 e2 1f             	and    $0x1f,%edx
  8022a0:	29 ca                	sub    %ecx,%edx
  8022a2:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8022a6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8022aa:	83 c0 01             	add    $0x1,%eax
  8022ad:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8022b0:	83 c7 01             	add    $0x1,%edi
  8022b3:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8022b6:	75 c2                	jne    80227a <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8022b8:	8b 45 10             	mov    0x10(%ebp),%eax
  8022bb:	eb 05                	jmp    8022c2 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8022bd:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8022c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022c5:	5b                   	pop    %ebx
  8022c6:	5e                   	pop    %esi
  8022c7:	5f                   	pop    %edi
  8022c8:	5d                   	pop    %ebp
  8022c9:	c3                   	ret    

008022ca <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8022ca:	55                   	push   %ebp
  8022cb:	89 e5                	mov    %esp,%ebp
  8022cd:	57                   	push   %edi
  8022ce:	56                   	push   %esi
  8022cf:	53                   	push   %ebx
  8022d0:	83 ec 18             	sub    $0x18,%esp
  8022d3:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8022d6:	57                   	push   %edi
  8022d7:	e8 b2 f0 ff ff       	call   80138e <fd2data>
  8022dc:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8022de:	83 c4 10             	add    $0x10,%esp
  8022e1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8022e6:	eb 3d                	jmp    802325 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8022e8:	85 db                	test   %ebx,%ebx
  8022ea:	74 04                	je     8022f0 <devpipe_read+0x26>
				return i;
  8022ec:	89 d8                	mov    %ebx,%eax
  8022ee:	eb 44                	jmp    802334 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8022f0:	89 f2                	mov    %esi,%edx
  8022f2:	89 f8                	mov    %edi,%eax
  8022f4:	e8 e5 fe ff ff       	call   8021de <_pipeisclosed>
  8022f9:	85 c0                	test   %eax,%eax
  8022fb:	75 32                	jne    80232f <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8022fd:	e8 24 ec ff ff       	call   800f26 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802302:	8b 06                	mov    (%esi),%eax
  802304:	3b 46 04             	cmp    0x4(%esi),%eax
  802307:	74 df                	je     8022e8 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802309:	99                   	cltd   
  80230a:	c1 ea 1b             	shr    $0x1b,%edx
  80230d:	01 d0                	add    %edx,%eax
  80230f:	83 e0 1f             	and    $0x1f,%eax
  802312:	29 d0                	sub    %edx,%eax
  802314:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802319:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80231c:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80231f:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802322:	83 c3 01             	add    $0x1,%ebx
  802325:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802328:	75 d8                	jne    802302 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80232a:	8b 45 10             	mov    0x10(%ebp),%eax
  80232d:	eb 05                	jmp    802334 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80232f:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802334:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802337:	5b                   	pop    %ebx
  802338:	5e                   	pop    %esi
  802339:	5f                   	pop    %edi
  80233a:	5d                   	pop    %ebp
  80233b:	c3                   	ret    

0080233c <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80233c:	55                   	push   %ebp
  80233d:	89 e5                	mov    %esp,%ebp
  80233f:	56                   	push   %esi
  802340:	53                   	push   %ebx
  802341:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802344:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802347:	50                   	push   %eax
  802348:	e8 58 f0 ff ff       	call   8013a5 <fd_alloc>
  80234d:	83 c4 10             	add    $0x10,%esp
  802350:	89 c2                	mov    %eax,%edx
  802352:	85 c0                	test   %eax,%eax
  802354:	0f 88 2c 01 00 00    	js     802486 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80235a:	83 ec 04             	sub    $0x4,%esp
  80235d:	68 07 04 00 00       	push   $0x407
  802362:	ff 75 f4             	pushl  -0xc(%ebp)
  802365:	6a 00                	push   $0x0
  802367:	e8 d9 eb ff ff       	call   800f45 <sys_page_alloc>
  80236c:	83 c4 10             	add    $0x10,%esp
  80236f:	89 c2                	mov    %eax,%edx
  802371:	85 c0                	test   %eax,%eax
  802373:	0f 88 0d 01 00 00    	js     802486 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802379:	83 ec 0c             	sub    $0xc,%esp
  80237c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80237f:	50                   	push   %eax
  802380:	e8 20 f0 ff ff       	call   8013a5 <fd_alloc>
  802385:	89 c3                	mov    %eax,%ebx
  802387:	83 c4 10             	add    $0x10,%esp
  80238a:	85 c0                	test   %eax,%eax
  80238c:	0f 88 e2 00 00 00    	js     802474 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802392:	83 ec 04             	sub    $0x4,%esp
  802395:	68 07 04 00 00       	push   $0x407
  80239a:	ff 75 f0             	pushl  -0x10(%ebp)
  80239d:	6a 00                	push   $0x0
  80239f:	e8 a1 eb ff ff       	call   800f45 <sys_page_alloc>
  8023a4:	89 c3                	mov    %eax,%ebx
  8023a6:	83 c4 10             	add    $0x10,%esp
  8023a9:	85 c0                	test   %eax,%eax
  8023ab:	0f 88 c3 00 00 00    	js     802474 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8023b1:	83 ec 0c             	sub    $0xc,%esp
  8023b4:	ff 75 f4             	pushl  -0xc(%ebp)
  8023b7:	e8 d2 ef ff ff       	call   80138e <fd2data>
  8023bc:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023be:	83 c4 0c             	add    $0xc,%esp
  8023c1:	68 07 04 00 00       	push   $0x407
  8023c6:	50                   	push   %eax
  8023c7:	6a 00                	push   $0x0
  8023c9:	e8 77 eb ff ff       	call   800f45 <sys_page_alloc>
  8023ce:	89 c3                	mov    %eax,%ebx
  8023d0:	83 c4 10             	add    $0x10,%esp
  8023d3:	85 c0                	test   %eax,%eax
  8023d5:	0f 88 89 00 00 00    	js     802464 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023db:	83 ec 0c             	sub    $0xc,%esp
  8023de:	ff 75 f0             	pushl  -0x10(%ebp)
  8023e1:	e8 a8 ef ff ff       	call   80138e <fd2data>
  8023e6:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8023ed:	50                   	push   %eax
  8023ee:	6a 00                	push   $0x0
  8023f0:	56                   	push   %esi
  8023f1:	6a 00                	push   $0x0
  8023f3:	e8 90 eb ff ff       	call   800f88 <sys_page_map>
  8023f8:	89 c3                	mov    %eax,%ebx
  8023fa:	83 c4 20             	add    $0x20,%esp
  8023fd:	85 c0                	test   %eax,%eax
  8023ff:	78 55                	js     802456 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802401:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802407:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80240a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80240c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80240f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802416:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  80241c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80241f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802421:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802424:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80242b:	83 ec 0c             	sub    $0xc,%esp
  80242e:	ff 75 f4             	pushl  -0xc(%ebp)
  802431:	e8 48 ef ff ff       	call   80137e <fd2num>
  802436:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802439:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80243b:	83 c4 04             	add    $0x4,%esp
  80243e:	ff 75 f0             	pushl  -0x10(%ebp)
  802441:	e8 38 ef ff ff       	call   80137e <fd2num>
  802446:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802449:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80244c:	83 c4 10             	add    $0x10,%esp
  80244f:	ba 00 00 00 00       	mov    $0x0,%edx
  802454:	eb 30                	jmp    802486 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802456:	83 ec 08             	sub    $0x8,%esp
  802459:	56                   	push   %esi
  80245a:	6a 00                	push   $0x0
  80245c:	e8 69 eb ff ff       	call   800fca <sys_page_unmap>
  802461:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802464:	83 ec 08             	sub    $0x8,%esp
  802467:	ff 75 f0             	pushl  -0x10(%ebp)
  80246a:	6a 00                	push   $0x0
  80246c:	e8 59 eb ff ff       	call   800fca <sys_page_unmap>
  802471:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802474:	83 ec 08             	sub    $0x8,%esp
  802477:	ff 75 f4             	pushl  -0xc(%ebp)
  80247a:	6a 00                	push   $0x0
  80247c:	e8 49 eb ff ff       	call   800fca <sys_page_unmap>
  802481:	83 c4 10             	add    $0x10,%esp
  802484:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802486:	89 d0                	mov    %edx,%eax
  802488:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80248b:	5b                   	pop    %ebx
  80248c:	5e                   	pop    %esi
  80248d:	5d                   	pop    %ebp
  80248e:	c3                   	ret    

0080248f <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80248f:	55                   	push   %ebp
  802490:	89 e5                	mov    %esp,%ebp
  802492:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802495:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802498:	50                   	push   %eax
  802499:	ff 75 08             	pushl  0x8(%ebp)
  80249c:	e8 53 ef ff ff       	call   8013f4 <fd_lookup>
  8024a1:	83 c4 10             	add    $0x10,%esp
  8024a4:	85 c0                	test   %eax,%eax
  8024a6:	78 18                	js     8024c0 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8024a8:	83 ec 0c             	sub    $0xc,%esp
  8024ab:	ff 75 f4             	pushl  -0xc(%ebp)
  8024ae:	e8 db ee ff ff       	call   80138e <fd2data>
	return _pipeisclosed(fd, p);
  8024b3:	89 c2                	mov    %eax,%edx
  8024b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024b8:	e8 21 fd ff ff       	call   8021de <_pipeisclosed>
  8024bd:	83 c4 10             	add    $0x10,%esp
}
  8024c0:	c9                   	leave  
  8024c1:	c3                   	ret    

008024c2 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  8024c2:	55                   	push   %ebp
  8024c3:	89 e5                	mov    %esp,%ebp
  8024c5:	56                   	push   %esi
  8024c6:	53                   	push   %ebx
  8024c7:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  8024ca:	85 f6                	test   %esi,%esi
  8024cc:	75 16                	jne    8024e4 <wait+0x22>
  8024ce:	68 0f 30 80 00       	push   $0x80300f
  8024d3:	68 38 2f 80 00       	push   $0x802f38
  8024d8:	6a 09                	push   $0x9
  8024da:	68 1a 30 80 00       	push   $0x80301a
  8024df:	e8 00 e0 ff ff       	call   8004e4 <_panic>
	e = &envs[ENVX(envid)];
  8024e4:	89 f3                	mov    %esi,%ebx
  8024e6:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8024ec:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  8024ef:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  8024f5:	eb 05                	jmp    8024fc <wait+0x3a>
		sys_yield();
  8024f7:	e8 2a ea ff ff       	call   800f26 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8024fc:	8b 43 48             	mov    0x48(%ebx),%eax
  8024ff:	39 c6                	cmp    %eax,%esi
  802501:	75 07                	jne    80250a <wait+0x48>
  802503:	8b 43 54             	mov    0x54(%ebx),%eax
  802506:	85 c0                	test   %eax,%eax
  802508:	75 ed                	jne    8024f7 <wait+0x35>
		sys_yield();
}
  80250a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80250d:	5b                   	pop    %ebx
  80250e:	5e                   	pop    %esi
  80250f:	5d                   	pop    %ebp
  802510:	c3                   	ret    

00802511 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802511:	55                   	push   %ebp
  802512:	89 e5                	mov    %esp,%ebp
  802514:	53                   	push   %ebx
  802515:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  802518:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  80251f:	75 28                	jne    802549 <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  802521:	e8 e1 e9 ff ff       	call   800f07 <sys_getenvid>
  802526:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_U | PTE_W);
  802528:	83 ec 04             	sub    $0x4,%esp
  80252b:	6a 06                	push   $0x6
  80252d:	68 00 f0 bf ee       	push   $0xeebff000
  802532:	50                   	push   %eax
  802533:	e8 0d ea ff ff       	call   800f45 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  802538:	83 c4 08             	add    $0x8,%esp
  80253b:	68 56 25 80 00       	push   $0x802556
  802540:	53                   	push   %ebx
  802541:	e8 4a eb ff ff       	call   801090 <sys_env_set_pgfault_upcall>
  802546:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802549:	8b 45 08             	mov    0x8(%ebp),%eax
  80254c:	a3 00 70 80 00       	mov    %eax,0x807000
}
  802551:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802554:	c9                   	leave  
  802555:	c3                   	ret    

00802556 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802556:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802557:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  80255c:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80255e:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	# My method is different. Copy the values to the other stack
	# in a convinient way, and then pop everything.
	movl %esp, %ebp		# ebp refers to the exception stack
  802561:	89 e5                	mov    %esp,%ebp
	movl 48(%ebp), %esp 	# go to other stack
  802563:	8b 65 30             	mov    0x30(%ebp),%esp

	pushl 40(%ebp)		# eip - ORDER SWITCHED WITH EFLAGS
  802566:	ff 75 28             	pushl  0x28(%ebp)
	pushl 44(%ebp)      	# eflags
  802569:	ff 75 2c             	pushl  0x2c(%ebp)
	pushl 36(%ebp)		# all the 8 remaining regs
  80256c:	ff 75 24             	pushl  0x24(%ebp)
	pushl 32(%ebp)
  80256f:	ff 75 20             	pushl  0x20(%ebp)
	pushl 28(%ebp)
  802572:	ff 75 1c             	pushl  0x1c(%ebp)
	pushl 24(%ebp)
  802575:	ff 75 18             	pushl  0x18(%ebp)
	pushl 20(%ebp)
  802578:	ff 75 14             	pushl  0x14(%ebp)
	pushl 16(%ebp)
  80257b:	ff 75 10             	pushl  0x10(%ebp)
	pushl 12(%ebp)
  80257e:	ff 75 0c             	pushl  0xc(%ebp)
	pushl 8(%ebp)
  802581:	ff 75 08             	pushl  0x8(%ebp)

	popal			# now just pop everything!
  802584:	61                   	popa   
	popfl
  802585:	9d                   	popf   
	ret
  802586:	c3                   	ret    

00802587 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802587:	55                   	push   %ebp
  802588:	89 e5                	mov    %esp,%ebp
  80258a:	56                   	push   %esi
  80258b:	53                   	push   %ebx
  80258c:	8b 75 08             	mov    0x8(%ebp),%esi
  80258f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802592:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  802595:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  802597:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  80259c:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  80259f:	83 ec 0c             	sub    $0xc,%esp
  8025a2:	50                   	push   %eax
  8025a3:	e8 4d eb ff ff       	call   8010f5 <sys_ipc_recv>

	if (r < 0) {
  8025a8:	83 c4 10             	add    $0x10,%esp
  8025ab:	85 c0                	test   %eax,%eax
  8025ad:	79 16                	jns    8025c5 <ipc_recv+0x3e>
		if (from_env_store)
  8025af:	85 f6                	test   %esi,%esi
  8025b1:	74 06                	je     8025b9 <ipc_recv+0x32>
			*from_env_store = 0;
  8025b3:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  8025b9:	85 db                	test   %ebx,%ebx
  8025bb:	74 2c                	je     8025e9 <ipc_recv+0x62>
			*perm_store = 0;
  8025bd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8025c3:	eb 24                	jmp    8025e9 <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  8025c5:	85 f6                	test   %esi,%esi
  8025c7:	74 0a                	je     8025d3 <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  8025c9:	a1 04 50 80 00       	mov    0x805004,%eax
  8025ce:	8b 40 74             	mov    0x74(%eax),%eax
  8025d1:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  8025d3:	85 db                	test   %ebx,%ebx
  8025d5:	74 0a                	je     8025e1 <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  8025d7:	a1 04 50 80 00       	mov    0x805004,%eax
  8025dc:	8b 40 78             	mov    0x78(%eax),%eax
  8025df:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  8025e1:	a1 04 50 80 00       	mov    0x805004,%eax
  8025e6:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  8025e9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8025ec:	5b                   	pop    %ebx
  8025ed:	5e                   	pop    %esi
  8025ee:	5d                   	pop    %ebp
  8025ef:	c3                   	ret    

008025f0 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8025f0:	55                   	push   %ebp
  8025f1:	89 e5                	mov    %esp,%ebp
  8025f3:	57                   	push   %edi
  8025f4:	56                   	push   %esi
  8025f5:	53                   	push   %ebx
  8025f6:	83 ec 0c             	sub    $0xc,%esp
  8025f9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8025fc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8025ff:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  802602:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  802604:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  802609:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  80260c:	ff 75 14             	pushl  0x14(%ebp)
  80260f:	53                   	push   %ebx
  802610:	56                   	push   %esi
  802611:	57                   	push   %edi
  802612:	e8 bb ea ff ff       	call   8010d2 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  802617:	83 c4 10             	add    $0x10,%esp
  80261a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80261d:	75 07                	jne    802626 <ipc_send+0x36>
			sys_yield();
  80261f:	e8 02 e9 ff ff       	call   800f26 <sys_yield>
  802624:	eb e6                	jmp    80260c <ipc_send+0x1c>
		} else if (r < 0) {
  802626:	85 c0                	test   %eax,%eax
  802628:	79 12                	jns    80263c <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  80262a:	50                   	push   %eax
  80262b:	68 25 30 80 00       	push   $0x803025
  802630:	6a 51                	push   $0x51
  802632:	68 32 30 80 00       	push   $0x803032
  802637:	e8 a8 de ff ff       	call   8004e4 <_panic>
		}
	}
}
  80263c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80263f:	5b                   	pop    %ebx
  802640:	5e                   	pop    %esi
  802641:	5f                   	pop    %edi
  802642:	5d                   	pop    %ebp
  802643:	c3                   	ret    

00802644 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802644:	55                   	push   %ebp
  802645:	89 e5                	mov    %esp,%ebp
  802647:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80264a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80264f:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802652:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802658:	8b 52 50             	mov    0x50(%edx),%edx
  80265b:	39 ca                	cmp    %ecx,%edx
  80265d:	75 0d                	jne    80266c <ipc_find_env+0x28>
			return envs[i].env_id;
  80265f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802662:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802667:	8b 40 48             	mov    0x48(%eax),%eax
  80266a:	eb 0f                	jmp    80267b <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80266c:	83 c0 01             	add    $0x1,%eax
  80266f:	3d 00 04 00 00       	cmp    $0x400,%eax
  802674:	75 d9                	jne    80264f <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802676:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80267b:	5d                   	pop    %ebp
  80267c:	c3                   	ret    

0080267d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80267d:	55                   	push   %ebp
  80267e:	89 e5                	mov    %esp,%ebp
  802680:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802683:	89 d0                	mov    %edx,%eax
  802685:	c1 e8 16             	shr    $0x16,%eax
  802688:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80268f:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802694:	f6 c1 01             	test   $0x1,%cl
  802697:	74 1d                	je     8026b6 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802699:	c1 ea 0c             	shr    $0xc,%edx
  80269c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8026a3:	f6 c2 01             	test   $0x1,%dl
  8026a6:	74 0e                	je     8026b6 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8026a8:	c1 ea 0c             	shr    $0xc,%edx
  8026ab:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8026b2:	ef 
  8026b3:	0f b7 c0             	movzwl %ax,%eax
}
  8026b6:	5d                   	pop    %ebp
  8026b7:	c3                   	ret    
  8026b8:	66 90                	xchg   %ax,%ax
  8026ba:	66 90                	xchg   %ax,%ax
  8026bc:	66 90                	xchg   %ax,%ax
  8026be:	66 90                	xchg   %ax,%ax

008026c0 <__udivdi3>:
  8026c0:	55                   	push   %ebp
  8026c1:	57                   	push   %edi
  8026c2:	56                   	push   %esi
  8026c3:	53                   	push   %ebx
  8026c4:	83 ec 1c             	sub    $0x1c,%esp
  8026c7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8026cb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8026cf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8026d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8026d7:	85 f6                	test   %esi,%esi
  8026d9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8026dd:	89 ca                	mov    %ecx,%edx
  8026df:	89 f8                	mov    %edi,%eax
  8026e1:	75 3d                	jne    802720 <__udivdi3+0x60>
  8026e3:	39 cf                	cmp    %ecx,%edi
  8026e5:	0f 87 c5 00 00 00    	ja     8027b0 <__udivdi3+0xf0>
  8026eb:	85 ff                	test   %edi,%edi
  8026ed:	89 fd                	mov    %edi,%ebp
  8026ef:	75 0b                	jne    8026fc <__udivdi3+0x3c>
  8026f1:	b8 01 00 00 00       	mov    $0x1,%eax
  8026f6:	31 d2                	xor    %edx,%edx
  8026f8:	f7 f7                	div    %edi
  8026fa:	89 c5                	mov    %eax,%ebp
  8026fc:	89 c8                	mov    %ecx,%eax
  8026fe:	31 d2                	xor    %edx,%edx
  802700:	f7 f5                	div    %ebp
  802702:	89 c1                	mov    %eax,%ecx
  802704:	89 d8                	mov    %ebx,%eax
  802706:	89 cf                	mov    %ecx,%edi
  802708:	f7 f5                	div    %ebp
  80270a:	89 c3                	mov    %eax,%ebx
  80270c:	89 d8                	mov    %ebx,%eax
  80270e:	89 fa                	mov    %edi,%edx
  802710:	83 c4 1c             	add    $0x1c,%esp
  802713:	5b                   	pop    %ebx
  802714:	5e                   	pop    %esi
  802715:	5f                   	pop    %edi
  802716:	5d                   	pop    %ebp
  802717:	c3                   	ret    
  802718:	90                   	nop
  802719:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802720:	39 ce                	cmp    %ecx,%esi
  802722:	77 74                	ja     802798 <__udivdi3+0xd8>
  802724:	0f bd fe             	bsr    %esi,%edi
  802727:	83 f7 1f             	xor    $0x1f,%edi
  80272a:	0f 84 98 00 00 00    	je     8027c8 <__udivdi3+0x108>
  802730:	bb 20 00 00 00       	mov    $0x20,%ebx
  802735:	89 f9                	mov    %edi,%ecx
  802737:	89 c5                	mov    %eax,%ebp
  802739:	29 fb                	sub    %edi,%ebx
  80273b:	d3 e6                	shl    %cl,%esi
  80273d:	89 d9                	mov    %ebx,%ecx
  80273f:	d3 ed                	shr    %cl,%ebp
  802741:	89 f9                	mov    %edi,%ecx
  802743:	d3 e0                	shl    %cl,%eax
  802745:	09 ee                	or     %ebp,%esi
  802747:	89 d9                	mov    %ebx,%ecx
  802749:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80274d:	89 d5                	mov    %edx,%ebp
  80274f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802753:	d3 ed                	shr    %cl,%ebp
  802755:	89 f9                	mov    %edi,%ecx
  802757:	d3 e2                	shl    %cl,%edx
  802759:	89 d9                	mov    %ebx,%ecx
  80275b:	d3 e8                	shr    %cl,%eax
  80275d:	09 c2                	or     %eax,%edx
  80275f:	89 d0                	mov    %edx,%eax
  802761:	89 ea                	mov    %ebp,%edx
  802763:	f7 f6                	div    %esi
  802765:	89 d5                	mov    %edx,%ebp
  802767:	89 c3                	mov    %eax,%ebx
  802769:	f7 64 24 0c          	mull   0xc(%esp)
  80276d:	39 d5                	cmp    %edx,%ebp
  80276f:	72 10                	jb     802781 <__udivdi3+0xc1>
  802771:	8b 74 24 08          	mov    0x8(%esp),%esi
  802775:	89 f9                	mov    %edi,%ecx
  802777:	d3 e6                	shl    %cl,%esi
  802779:	39 c6                	cmp    %eax,%esi
  80277b:	73 07                	jae    802784 <__udivdi3+0xc4>
  80277d:	39 d5                	cmp    %edx,%ebp
  80277f:	75 03                	jne    802784 <__udivdi3+0xc4>
  802781:	83 eb 01             	sub    $0x1,%ebx
  802784:	31 ff                	xor    %edi,%edi
  802786:	89 d8                	mov    %ebx,%eax
  802788:	89 fa                	mov    %edi,%edx
  80278a:	83 c4 1c             	add    $0x1c,%esp
  80278d:	5b                   	pop    %ebx
  80278e:	5e                   	pop    %esi
  80278f:	5f                   	pop    %edi
  802790:	5d                   	pop    %ebp
  802791:	c3                   	ret    
  802792:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802798:	31 ff                	xor    %edi,%edi
  80279a:	31 db                	xor    %ebx,%ebx
  80279c:	89 d8                	mov    %ebx,%eax
  80279e:	89 fa                	mov    %edi,%edx
  8027a0:	83 c4 1c             	add    $0x1c,%esp
  8027a3:	5b                   	pop    %ebx
  8027a4:	5e                   	pop    %esi
  8027a5:	5f                   	pop    %edi
  8027a6:	5d                   	pop    %ebp
  8027a7:	c3                   	ret    
  8027a8:	90                   	nop
  8027a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8027b0:	89 d8                	mov    %ebx,%eax
  8027b2:	f7 f7                	div    %edi
  8027b4:	31 ff                	xor    %edi,%edi
  8027b6:	89 c3                	mov    %eax,%ebx
  8027b8:	89 d8                	mov    %ebx,%eax
  8027ba:	89 fa                	mov    %edi,%edx
  8027bc:	83 c4 1c             	add    $0x1c,%esp
  8027bf:	5b                   	pop    %ebx
  8027c0:	5e                   	pop    %esi
  8027c1:	5f                   	pop    %edi
  8027c2:	5d                   	pop    %ebp
  8027c3:	c3                   	ret    
  8027c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8027c8:	39 ce                	cmp    %ecx,%esi
  8027ca:	72 0c                	jb     8027d8 <__udivdi3+0x118>
  8027cc:	31 db                	xor    %ebx,%ebx
  8027ce:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8027d2:	0f 87 34 ff ff ff    	ja     80270c <__udivdi3+0x4c>
  8027d8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8027dd:	e9 2a ff ff ff       	jmp    80270c <__udivdi3+0x4c>
  8027e2:	66 90                	xchg   %ax,%ax
  8027e4:	66 90                	xchg   %ax,%ax
  8027e6:	66 90                	xchg   %ax,%ax
  8027e8:	66 90                	xchg   %ax,%ax
  8027ea:	66 90                	xchg   %ax,%ax
  8027ec:	66 90                	xchg   %ax,%ax
  8027ee:	66 90                	xchg   %ax,%ax

008027f0 <__umoddi3>:
  8027f0:	55                   	push   %ebp
  8027f1:	57                   	push   %edi
  8027f2:	56                   	push   %esi
  8027f3:	53                   	push   %ebx
  8027f4:	83 ec 1c             	sub    $0x1c,%esp
  8027f7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8027fb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8027ff:	8b 74 24 34          	mov    0x34(%esp),%esi
  802803:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802807:	85 d2                	test   %edx,%edx
  802809:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80280d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802811:	89 f3                	mov    %esi,%ebx
  802813:	89 3c 24             	mov    %edi,(%esp)
  802816:	89 74 24 04          	mov    %esi,0x4(%esp)
  80281a:	75 1c                	jne    802838 <__umoddi3+0x48>
  80281c:	39 f7                	cmp    %esi,%edi
  80281e:	76 50                	jbe    802870 <__umoddi3+0x80>
  802820:	89 c8                	mov    %ecx,%eax
  802822:	89 f2                	mov    %esi,%edx
  802824:	f7 f7                	div    %edi
  802826:	89 d0                	mov    %edx,%eax
  802828:	31 d2                	xor    %edx,%edx
  80282a:	83 c4 1c             	add    $0x1c,%esp
  80282d:	5b                   	pop    %ebx
  80282e:	5e                   	pop    %esi
  80282f:	5f                   	pop    %edi
  802830:	5d                   	pop    %ebp
  802831:	c3                   	ret    
  802832:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802838:	39 f2                	cmp    %esi,%edx
  80283a:	89 d0                	mov    %edx,%eax
  80283c:	77 52                	ja     802890 <__umoddi3+0xa0>
  80283e:	0f bd ea             	bsr    %edx,%ebp
  802841:	83 f5 1f             	xor    $0x1f,%ebp
  802844:	75 5a                	jne    8028a0 <__umoddi3+0xb0>
  802846:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80284a:	0f 82 e0 00 00 00    	jb     802930 <__umoddi3+0x140>
  802850:	39 0c 24             	cmp    %ecx,(%esp)
  802853:	0f 86 d7 00 00 00    	jbe    802930 <__umoddi3+0x140>
  802859:	8b 44 24 08          	mov    0x8(%esp),%eax
  80285d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802861:	83 c4 1c             	add    $0x1c,%esp
  802864:	5b                   	pop    %ebx
  802865:	5e                   	pop    %esi
  802866:	5f                   	pop    %edi
  802867:	5d                   	pop    %ebp
  802868:	c3                   	ret    
  802869:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802870:	85 ff                	test   %edi,%edi
  802872:	89 fd                	mov    %edi,%ebp
  802874:	75 0b                	jne    802881 <__umoddi3+0x91>
  802876:	b8 01 00 00 00       	mov    $0x1,%eax
  80287b:	31 d2                	xor    %edx,%edx
  80287d:	f7 f7                	div    %edi
  80287f:	89 c5                	mov    %eax,%ebp
  802881:	89 f0                	mov    %esi,%eax
  802883:	31 d2                	xor    %edx,%edx
  802885:	f7 f5                	div    %ebp
  802887:	89 c8                	mov    %ecx,%eax
  802889:	f7 f5                	div    %ebp
  80288b:	89 d0                	mov    %edx,%eax
  80288d:	eb 99                	jmp    802828 <__umoddi3+0x38>
  80288f:	90                   	nop
  802890:	89 c8                	mov    %ecx,%eax
  802892:	89 f2                	mov    %esi,%edx
  802894:	83 c4 1c             	add    $0x1c,%esp
  802897:	5b                   	pop    %ebx
  802898:	5e                   	pop    %esi
  802899:	5f                   	pop    %edi
  80289a:	5d                   	pop    %ebp
  80289b:	c3                   	ret    
  80289c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8028a0:	8b 34 24             	mov    (%esp),%esi
  8028a3:	bf 20 00 00 00       	mov    $0x20,%edi
  8028a8:	89 e9                	mov    %ebp,%ecx
  8028aa:	29 ef                	sub    %ebp,%edi
  8028ac:	d3 e0                	shl    %cl,%eax
  8028ae:	89 f9                	mov    %edi,%ecx
  8028b0:	89 f2                	mov    %esi,%edx
  8028b2:	d3 ea                	shr    %cl,%edx
  8028b4:	89 e9                	mov    %ebp,%ecx
  8028b6:	09 c2                	or     %eax,%edx
  8028b8:	89 d8                	mov    %ebx,%eax
  8028ba:	89 14 24             	mov    %edx,(%esp)
  8028bd:	89 f2                	mov    %esi,%edx
  8028bf:	d3 e2                	shl    %cl,%edx
  8028c1:	89 f9                	mov    %edi,%ecx
  8028c3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8028c7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8028cb:	d3 e8                	shr    %cl,%eax
  8028cd:	89 e9                	mov    %ebp,%ecx
  8028cf:	89 c6                	mov    %eax,%esi
  8028d1:	d3 e3                	shl    %cl,%ebx
  8028d3:	89 f9                	mov    %edi,%ecx
  8028d5:	89 d0                	mov    %edx,%eax
  8028d7:	d3 e8                	shr    %cl,%eax
  8028d9:	89 e9                	mov    %ebp,%ecx
  8028db:	09 d8                	or     %ebx,%eax
  8028dd:	89 d3                	mov    %edx,%ebx
  8028df:	89 f2                	mov    %esi,%edx
  8028e1:	f7 34 24             	divl   (%esp)
  8028e4:	89 d6                	mov    %edx,%esi
  8028e6:	d3 e3                	shl    %cl,%ebx
  8028e8:	f7 64 24 04          	mull   0x4(%esp)
  8028ec:	39 d6                	cmp    %edx,%esi
  8028ee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8028f2:	89 d1                	mov    %edx,%ecx
  8028f4:	89 c3                	mov    %eax,%ebx
  8028f6:	72 08                	jb     802900 <__umoddi3+0x110>
  8028f8:	75 11                	jne    80290b <__umoddi3+0x11b>
  8028fa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8028fe:	73 0b                	jae    80290b <__umoddi3+0x11b>
  802900:	2b 44 24 04          	sub    0x4(%esp),%eax
  802904:	1b 14 24             	sbb    (%esp),%edx
  802907:	89 d1                	mov    %edx,%ecx
  802909:	89 c3                	mov    %eax,%ebx
  80290b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80290f:	29 da                	sub    %ebx,%edx
  802911:	19 ce                	sbb    %ecx,%esi
  802913:	89 f9                	mov    %edi,%ecx
  802915:	89 f0                	mov    %esi,%eax
  802917:	d3 e0                	shl    %cl,%eax
  802919:	89 e9                	mov    %ebp,%ecx
  80291b:	d3 ea                	shr    %cl,%edx
  80291d:	89 e9                	mov    %ebp,%ecx
  80291f:	d3 ee                	shr    %cl,%esi
  802921:	09 d0                	or     %edx,%eax
  802923:	89 f2                	mov    %esi,%edx
  802925:	83 c4 1c             	add    $0x1c,%esp
  802928:	5b                   	pop    %ebx
  802929:	5e                   	pop    %esi
  80292a:	5f                   	pop    %edi
  80292b:	5d                   	pop    %ebp
  80292c:	c3                   	ret    
  80292d:	8d 76 00             	lea    0x0(%esi),%esi
  802930:	29 f9                	sub    %edi,%ecx
  802932:	19 d6                	sbb    %edx,%esi
  802934:	89 74 24 04          	mov    %esi,0x4(%esp)
  802938:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80293c:	e9 18 ff ff ff       	jmp    802859 <__umoddi3+0x69>
