
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
  80004a:	e8 f1 17 00 00       	call   801840 <seek>
	seek(kfd, off);
  80004f:	83 c4 08             	add    $0x8,%esp
  800052:	53                   	push   %ebx
  800053:	57                   	push   %edi
  800054:	e8 e7 17 00 00       	call   801840 <seek>

	cprintf("shell produced incorrect output.\n");
  800059:	c7 04 24 40 2e 80 00 	movl   $0x802e40,(%esp)
  800060:	e8 58 05 00 00       	call   8005bd <cprintf>
	cprintf("expected:\n===\n");
  800065:	c7 04 24 ab 2e 80 00 	movl   $0x802eab,(%esp)
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
  80008d:	e8 48 16 00 00       	call   8016da <read>
  800092:	83 c4 10             	add    $0x10,%esp
  800095:	85 c0                	test   %eax,%eax
  800097:	7f e0                	jg     800079 <wrong+0x46>
		sys_cputs(buf, n);
	cprintf("===\ngot:\n===\n");
  800099:	83 ec 0c             	sub    $0xc,%esp
  80009c:	68 ba 2e 80 00       	push   $0x802eba
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
  8000c2:	e8 13 16 00 00       	call   8016da <read>
  8000c7:	83 c4 10             	add    $0x10,%esp
  8000ca:	85 c0                	test   %eax,%eax
  8000cc:	7f e0                	jg     8000ae <wrong+0x7b>
		sys_cputs(buf, n);
	cprintf("===\n");
  8000ce:	83 ec 0c             	sub    $0xc,%esp
  8000d1:	68 b5 2e 80 00       	push   $0x802eb5
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
  8000f6:	e8 a3 14 00 00       	call   80159e <close>
	close(1);
  8000fb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800102:	e8 97 14 00 00       	call   80159e <close>
	opencons();
  800107:	e8 1e 03 00 00       	call   80042a <opencons>
	opencons();
  80010c:	e8 19 03 00 00       	call   80042a <opencons>

	if ((rfd = open("testshell.sh", O_RDONLY)) < 0)
  800111:	83 c4 08             	add    $0x8,%esp
  800114:	6a 00                	push   $0x0
  800116:	68 c8 2e 80 00       	push   $0x802ec8
  80011b:	e8 6e 1a 00 00       	call   801b8e <open>
  800120:	89 c3                	mov    %eax,%ebx
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	85 c0                	test   %eax,%eax
  800127:	79 12                	jns    80013b <umain+0x50>
		panic("open testshell.sh: %e", rfd);
  800129:	50                   	push   %eax
  80012a:	68 d5 2e 80 00       	push   $0x802ed5
  80012f:	6a 13                	push   $0x13
  800131:	68 eb 2e 80 00       	push   $0x802eeb
  800136:	e8 a9 03 00 00       	call   8004e4 <_panic>
	if ((wfd = pipe(pfds)) < 0)
  80013b:	83 ec 0c             	sub    $0xc,%esp
  80013e:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800141:	50                   	push   %eax
  800142:	e8 dc 26 00 00       	call   802823 <pipe>
  800147:	83 c4 10             	add    $0x10,%esp
  80014a:	85 c0                	test   %eax,%eax
  80014c:	79 12                	jns    800160 <umain+0x75>
		panic("pipe: %e", wfd);
  80014e:	50                   	push   %eax
  80014f:	68 fc 2e 80 00       	push   $0x802efc
  800154:	6a 15                	push   $0x15
  800156:	68 eb 2e 80 00       	push   $0x802eeb
  80015b:	e8 84 03 00 00       	call   8004e4 <_panic>
	wfd = pfds[1];
  800160:	8b 75 e0             	mov    -0x20(%ebp),%esi

	cprintf("running sh -x < testshell.sh | cat\n");
  800163:	83 ec 0c             	sub    $0xc,%esp
  800166:	68 64 2e 80 00       	push   $0x802e64
  80016b:	e8 4d 04 00 00       	call   8005bd <cprintf>
	if ((r = fork()) < 0)
  800170:	e8 94 11 00 00       	call   801309 <fork>
  800175:	83 c4 10             	add    $0x10,%esp
  800178:	85 c0                	test   %eax,%eax
  80017a:	79 12                	jns    80018e <umain+0xa3>
		panic("fork: %e", r);
  80017c:	50                   	push   %eax
  80017d:	68 13 33 80 00       	push   $0x803313
  800182:	6a 1a                	push   $0x1a
  800184:	68 eb 2e 80 00       	push   $0x802eeb
  800189:	e8 56 03 00 00       	call   8004e4 <_panic>
	if (r == 0) {
  80018e:	85 c0                	test   %eax,%eax
  800190:	75 7d                	jne    80020f <umain+0x124>
		dup(rfd, 0);
  800192:	83 ec 08             	sub    $0x8,%esp
  800195:	6a 00                	push   $0x0
  800197:	53                   	push   %ebx
  800198:	e8 51 14 00 00       	call   8015ee <dup>
		dup(wfd, 1);
  80019d:	83 c4 08             	add    $0x8,%esp
  8001a0:	6a 01                	push   $0x1
  8001a2:	56                   	push   %esi
  8001a3:	e8 46 14 00 00       	call   8015ee <dup>
		close(rfd);
  8001a8:	89 1c 24             	mov    %ebx,(%esp)
  8001ab:	e8 ee 13 00 00       	call   80159e <close>
		close(wfd);
  8001b0:	89 34 24             	mov    %esi,(%esp)
  8001b3:	e8 e6 13 00 00       	call   80159e <close>
		if ((r = spawnl("/sh", "sh", "-x", 0)) < 0)
  8001b8:	6a 00                	push   $0x0
  8001ba:	68 05 2f 80 00       	push   $0x802f05
  8001bf:	68 d2 2e 80 00       	push   $0x802ed2
  8001c4:	68 08 2f 80 00       	push   $0x802f08
  8001c9:	e8 a5 1f 00 00       	call   802173 <spawnl>
  8001ce:	89 c7                	mov    %eax,%edi
  8001d0:	83 c4 20             	add    $0x20,%esp
  8001d3:	85 c0                	test   %eax,%eax
  8001d5:	79 12                	jns    8001e9 <umain+0xfe>
			panic("spawn: %e", r);
  8001d7:	50                   	push   %eax
  8001d8:	68 0c 2f 80 00       	push   $0x802f0c
  8001dd:	6a 21                	push   $0x21
  8001df:	68 eb 2e 80 00       	push   $0x802eeb
  8001e4:	e8 fb 02 00 00       	call   8004e4 <_panic>
		close(0);
  8001e9:	83 ec 0c             	sub    $0xc,%esp
  8001ec:	6a 00                	push   $0x0
  8001ee:	e8 ab 13 00 00       	call   80159e <close>
		close(1);
  8001f3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8001fa:	e8 9f 13 00 00       	call   80159e <close>
		wait(r);
  8001ff:	89 3c 24             	mov    %edi,(%esp)
  800202:	e8 a2 27 00 00       	call   8029a9 <wait>
		exit();
  800207:	e8 be 02 00 00       	call   8004ca <exit>
  80020c:	83 c4 10             	add    $0x10,%esp
	}
	close(rfd);
  80020f:	83 ec 0c             	sub    $0xc,%esp
  800212:	53                   	push   %ebx
  800213:	e8 86 13 00 00       	call   80159e <close>
	close(wfd);
  800218:	89 34 24             	mov    %esi,(%esp)
  80021b:	e8 7e 13 00 00       	call   80159e <close>

	rfd = pfds[0];
  800220:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800223:	89 45 d0             	mov    %eax,-0x30(%ebp)
	if ((kfd = open("testshell.key", O_RDONLY)) < 0)
  800226:	83 c4 08             	add    $0x8,%esp
  800229:	6a 00                	push   $0x0
  80022b:	68 16 2f 80 00       	push   $0x802f16
  800230:	e8 59 19 00 00       	call   801b8e <open>
  800235:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800238:	83 c4 10             	add    $0x10,%esp
  80023b:	85 c0                	test   %eax,%eax
  80023d:	79 12                	jns    800251 <umain+0x166>
		panic("open testshell.key for reading: %e", kfd);
  80023f:	50                   	push   %eax
  800240:	68 88 2e 80 00       	push   $0x802e88
  800245:	6a 2c                	push   $0x2c
  800247:	68 eb 2e 80 00       	push   $0x802eeb
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
  800267:	e8 6e 14 00 00       	call   8016da <read>
  80026c:	89 c3                	mov    %eax,%ebx
		n2 = read(kfd, &c2, 1);
  80026e:	83 c4 0c             	add    $0xc,%esp
  800271:	6a 01                	push   $0x1
  800273:	8d 45 e6             	lea    -0x1a(%ebp),%eax
  800276:	50                   	push   %eax
  800277:	ff 75 d4             	pushl  -0x2c(%ebp)
  80027a:	e8 5b 14 00 00       	call   8016da <read>
		if (n1 < 0)
  80027f:	83 c4 10             	add    $0x10,%esp
  800282:	85 db                	test   %ebx,%ebx
  800284:	79 12                	jns    800298 <umain+0x1ad>
			panic("reading testshell.out: %e", n1);
  800286:	53                   	push   %ebx
  800287:	68 24 2f 80 00       	push   $0x802f24
  80028c:	6a 33                	push   $0x33
  80028e:	68 eb 2e 80 00       	push   $0x802eeb
  800293:	e8 4c 02 00 00       	call   8004e4 <_panic>
		if (n2 < 0)
  800298:	85 c0                	test   %eax,%eax
  80029a:	79 12                	jns    8002ae <umain+0x1c3>
			panic("reading testshell.key: %e", n2);
  80029c:	50                   	push   %eax
  80029d:	68 3e 2f 80 00       	push   $0x802f3e
  8002a2:	6a 35                	push   $0x35
  8002a4:	68 eb 2e 80 00       	push   $0x802eeb
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
  8002eb:	68 58 2f 80 00       	push   $0x802f58
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
  800311:	68 6d 2f 80 00       	push   $0x802f6d
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
  8003e1:	e8 f4 12 00 00       	call   8016da <read>
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
  80040b:	e8 64 10 00 00       	call   801474 <fd_lookup>
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
  800434:	e8 ec 0f 00 00       	call   801425 <fd_alloc>
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
  800476:	e8 83 0f 00 00       	call   8013fe <fd2num>
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
  8004a1:	a3 08 50 80 00       	mov    %eax,0x805008

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
  8004d0:	e8 f4 10 00 00       	call   8015c9 <close_all>
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
  800502:	68 84 2f 80 00       	push   $0x802f84
  800507:	e8 b1 00 00 00       	call   8005bd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80050c:	83 c4 18             	add    $0x18,%esp
  80050f:	53                   	push   %ebx
  800510:	ff 75 10             	pushl  0x10(%ebp)
  800513:	e8 54 00 00 00       	call   80056c <vcprintf>
	cprintf("\n");
  800518:	c7 04 24 b8 2e 80 00 	movl   $0x802eb8,(%esp)
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
  800620:	e8 7b 25 00 00       	call   802ba0 <__udivdi3>
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
  800663:	e8 68 26 00 00       	call   802cd0 <__umoddi3>
  800668:	83 c4 14             	add    $0x14,%esp
  80066b:	0f be 80 a7 2f 80 00 	movsbl 0x802fa7(%eax),%eax
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
  800767:	ff 24 85 e0 30 80 00 	jmp    *0x8030e0(,%eax,4)
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
  80082b:	8b 14 85 40 32 80 00 	mov    0x803240(,%eax,4),%edx
  800832:	85 d2                	test   %edx,%edx
  800834:	75 18                	jne    80084e <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800836:	50                   	push   %eax
  800837:	68 bf 2f 80 00       	push   $0x802fbf
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
  80084f:	68 fa 33 80 00       	push   $0x8033fa
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
  800873:	b8 b8 2f 80 00       	mov    $0x802fb8,%eax
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
  800eee:	68 9f 32 80 00       	push   $0x80329f
  800ef3:	6a 23                	push   $0x23
  800ef5:	68 bc 32 80 00       	push   $0x8032bc
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
  800f6f:	68 9f 32 80 00       	push   $0x80329f
  800f74:	6a 23                	push   $0x23
  800f76:	68 bc 32 80 00       	push   $0x8032bc
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
  800fb1:	68 9f 32 80 00       	push   $0x80329f
  800fb6:	6a 23                	push   $0x23
  800fb8:	68 bc 32 80 00       	push   $0x8032bc
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
  800ff3:	68 9f 32 80 00       	push   $0x80329f
  800ff8:	6a 23                	push   $0x23
  800ffa:	68 bc 32 80 00       	push   $0x8032bc
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
  801035:	68 9f 32 80 00       	push   $0x80329f
  80103a:	6a 23                	push   $0x23
  80103c:	68 bc 32 80 00       	push   $0x8032bc
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
  801077:	68 9f 32 80 00       	push   $0x80329f
  80107c:	6a 23                	push   $0x23
  80107e:	68 bc 32 80 00       	push   $0x8032bc
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
  8010b9:	68 9f 32 80 00       	push   $0x80329f
  8010be:	6a 23                	push   $0x23
  8010c0:	68 bc 32 80 00       	push   $0x8032bc
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
  80111d:	68 9f 32 80 00       	push   $0x80329f
  801122:	6a 23                	push   $0x23
  801124:	68 bc 32 80 00       	push   $0x8032bc
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

00801136 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  801136:	55                   	push   %ebp
  801137:	89 e5                	mov    %esp,%ebp
  801139:	57                   	push   %edi
  80113a:	56                   	push   %esi
  80113b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80113c:	ba 00 00 00 00       	mov    $0x0,%edx
  801141:	b8 0e 00 00 00       	mov    $0xe,%eax
  801146:	89 d1                	mov    %edx,%ecx
  801148:	89 d3                	mov    %edx,%ebx
  80114a:	89 d7                	mov    %edx,%edi
  80114c:	89 d6                	mov    %edx,%esi
  80114e:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  801150:	5b                   	pop    %ebx
  801151:	5e                   	pop    %esi
  801152:	5f                   	pop    %edi
  801153:	5d                   	pop    %ebp
  801154:	c3                   	ret    

00801155 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  801155:	55                   	push   %ebp
  801156:	89 e5                	mov    %esp,%ebp
  801158:	53                   	push   %ebx
  801159:	83 ec 04             	sub    $0x4,%esp
	int r;
	void * address = (void *)(pn*PGSIZE);
  80115c:	89 d3                	mov    %edx,%ebx
  80115e:	c1 e3 0c             	shl    $0xc,%ebx
	
	if((uvpt[pn] & PTE_SHARE))
  801161:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  801168:	f6 c5 04             	test   $0x4,%ch
  80116b:	74 38                	je     8011a5 <duppage+0x50>
	{
		if ((r = sys_page_map(0, address, envid, address, (uvpt[pn] | PTE_SYSCALL))) < 0)
  80116d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801174:	83 ec 0c             	sub    $0xc,%esp
  801177:	81 ca 07 0e 00 00    	or     $0xe07,%edx
  80117d:	52                   	push   %edx
  80117e:	53                   	push   %ebx
  80117f:	50                   	push   %eax
  801180:	53                   	push   %ebx
  801181:	6a 00                	push   $0x0
  801183:	e8 00 fe ff ff       	call   800f88 <sys_page_map>
  801188:	83 c4 20             	add    $0x20,%esp
  80118b:	85 c0                	test   %eax,%eax
  80118d:	0f 89 b8 00 00 00    	jns    80124b <duppage+0xf6>
			panic("sys_page_map: %e", r);
  801193:	50                   	push   %eax
  801194:	68 ca 32 80 00       	push   $0x8032ca
  801199:	6a 4e                	push   $0x4e
  80119b:	68 db 32 80 00       	push   $0x8032db
  8011a0:	e8 3f f3 ff ff       	call   8004e4 <_panic>
	}
	else if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW))
  8011a5:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  8011ac:	f6 c1 02             	test   $0x2,%cl
  8011af:	75 0c                	jne    8011bd <duppage+0x68>
  8011b1:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  8011b8:	f6 c5 08             	test   $0x8,%ch
  8011bb:	74 57                	je     801214 <duppage+0xbf>
	{
		int perm = 0;
		perm |= PTE_P|PTE_U|PTE_COW;
	
		if ((r = sys_page_map(0, address, envid, address, perm)) < 0)
  8011bd:	83 ec 0c             	sub    $0xc,%esp
  8011c0:	68 05 08 00 00       	push   $0x805
  8011c5:	53                   	push   %ebx
  8011c6:	50                   	push   %eax
  8011c7:	53                   	push   %ebx
  8011c8:	6a 00                	push   $0x0
  8011ca:	e8 b9 fd ff ff       	call   800f88 <sys_page_map>
  8011cf:	83 c4 20             	add    $0x20,%esp
  8011d2:	85 c0                	test   %eax,%eax
  8011d4:	79 12                	jns    8011e8 <duppage+0x93>
			panic("sys_page_map: %e", r);
  8011d6:	50                   	push   %eax
  8011d7:	68 ca 32 80 00       	push   $0x8032ca
  8011dc:	6a 56                	push   $0x56
  8011de:	68 db 32 80 00       	push   $0x8032db
  8011e3:	e8 fc f2 ff ff       	call   8004e4 <_panic>
		if ((r = sys_page_map(0, address, 0, address, perm)) < 0)
  8011e8:	83 ec 0c             	sub    $0xc,%esp
  8011eb:	68 05 08 00 00       	push   $0x805
  8011f0:	53                   	push   %ebx
  8011f1:	6a 00                	push   $0x0
  8011f3:	53                   	push   %ebx
  8011f4:	6a 00                	push   $0x0
  8011f6:	e8 8d fd ff ff       	call   800f88 <sys_page_map>
  8011fb:	83 c4 20             	add    $0x20,%esp
  8011fe:	85 c0                	test   %eax,%eax
  801200:	79 49                	jns    80124b <duppage+0xf6>
			panic("sys_page_map: %e", r);
  801202:	50                   	push   %eax
  801203:	68 ca 32 80 00       	push   $0x8032ca
  801208:	6a 58                	push   $0x58
  80120a:	68 db 32 80 00       	push   $0x8032db
  80120f:	e8 d0 f2 ff ff       	call   8004e4 <_panic>
	}
	else if((uvpt[pn] & ~PTE_U) == 0)
  801214:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80121b:	f7 c2 fb ff ff ff    	test   $0xfffffffb,%edx
  801221:	75 28                	jne    80124b <duppage+0xf6>
	{
		//cprintf("im here");
		if ((r = sys_page_map(0, address, envid, address, PTE_P|PTE_U)) < 0)
  801223:	83 ec 0c             	sub    $0xc,%esp
  801226:	6a 05                	push   $0x5
  801228:	53                   	push   %ebx
  801229:	50                   	push   %eax
  80122a:	53                   	push   %ebx
  80122b:	6a 00                	push   $0x0
  80122d:	e8 56 fd ff ff       	call   800f88 <sys_page_map>
  801232:	83 c4 20             	add    $0x20,%esp
  801235:	85 c0                	test   %eax,%eax
  801237:	79 12                	jns    80124b <duppage+0xf6>
			panic("sys_page_map: %e", r);	
  801239:	50                   	push   %eax
  80123a:	68 ca 32 80 00       	push   $0x8032ca
  80123f:	6a 5e                	push   $0x5e
  801241:	68 db 32 80 00       	push   $0x8032db
  801246:	e8 99 f2 ff ff       	call   8004e4 <_panic>
	}
	return 0;
}
  80124b:	b8 00 00 00 00       	mov    $0x0,%eax
  801250:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801253:	c9                   	leave  
  801254:	c3                   	ret    

00801255 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801255:	55                   	push   %ebp
  801256:	89 e5                	mov    %esp,%ebp
  801258:	53                   	push   %ebx
  801259:	83 ec 08             	sub    $0x8,%esp
	void *addr = (void *) utf->utf_fault_va;
  80125c:	8b 45 08             	mov    0x8(%ebp),%eax
  80125f:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	unsigned pn = ((uint32_t)addr)/PGSIZE;
  801261:	89 d8                	mov    %ebx,%eax
  801263:	c1 e8 0c             	shr    $0xc,%eax
	pte_t pte = uvpt[pn];
  801266:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// Allocate a new page, mapped at temp location
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  80126d:	6a 07                	push   $0x7
  80126f:	68 00 f0 7f 00       	push   $0x7ff000
  801274:	6a 00                	push   $0x0
  801276:	e8 ca fc ff ff       	call   800f45 <sys_page_alloc>
  80127b:	83 c4 10             	add    $0x10,%esp
  80127e:	85 c0                	test   %eax,%eax
  801280:	79 12                	jns    801294 <pgfault+0x3f>
		panic("sys_page_alloc: %e", r);
  801282:	50                   	push   %eax
  801283:	68 e6 32 80 00       	push   $0x8032e6
  801288:	6a 2b                	push   $0x2b
  80128a:	68 db 32 80 00       	push   $0x8032db
  80128f:	e8 50 f2 ff ff       	call   8004e4 <_panic>

	// Copy the data from the old page to this new page
	void *addr_pgstart = (void *) ROUNDDOWN(addr, PGSIZE);
  801294:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr_pgstart, PGSIZE);
  80129a:	83 ec 04             	sub    $0x4,%esp
  80129d:	68 00 10 00 00       	push   $0x1000
  8012a2:	53                   	push   %ebx
  8012a3:	68 00 f0 7f 00       	push   $0x7ff000
  8012a8:	e8 27 fa ff ff       	call   800cd4 <memmove>

	// Move the new page to the old page's address
	if ((r = sys_page_map(0, PFTEMP, 0, addr_pgstart, PTE_P|PTE_U|PTE_W)) < 0)
  8012ad:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  8012b4:	53                   	push   %ebx
  8012b5:	6a 00                	push   $0x0
  8012b7:	68 00 f0 7f 00       	push   $0x7ff000
  8012bc:	6a 00                	push   $0x0
  8012be:	e8 c5 fc ff ff       	call   800f88 <sys_page_map>
  8012c3:	83 c4 20             	add    $0x20,%esp
  8012c6:	85 c0                	test   %eax,%eax
  8012c8:	79 12                	jns    8012dc <pgfault+0x87>
		panic("sys_page_map: %e", r);
  8012ca:	50                   	push   %eax
  8012cb:	68 ca 32 80 00       	push   $0x8032ca
  8012d0:	6a 33                	push   $0x33
  8012d2:	68 db 32 80 00       	push   $0x8032db
  8012d7:	e8 08 f2 ff ff       	call   8004e4 <_panic>

	// Unmap the temp location
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  8012dc:	83 ec 08             	sub    $0x8,%esp
  8012df:	68 00 f0 7f 00       	push   $0x7ff000
  8012e4:	6a 00                	push   $0x0
  8012e6:	e8 df fc ff ff       	call   800fca <sys_page_unmap>
  8012eb:	83 c4 10             	add    $0x10,%esp
  8012ee:	85 c0                	test   %eax,%eax
  8012f0:	79 12                	jns    801304 <pgfault+0xaf>
		panic("sys_page_unmap: %e", r);
  8012f2:	50                   	push   %eax
  8012f3:	68 f9 32 80 00       	push   $0x8032f9
  8012f8:	6a 37                	push   $0x37
  8012fa:	68 db 32 80 00       	push   $0x8032db
  8012ff:	e8 e0 f1 ff ff       	call   8004e4 <_panic>
}
  801304:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801307:	c9                   	leave  
  801308:	c3                   	ret    

00801309 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801309:	55                   	push   %ebp
  80130a:	89 e5                	mov    %esp,%ebp
  80130c:	56                   	push   %esi
  80130d:	53                   	push   %ebx
  80130e:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
	// Set up page fault handler
	set_pgfault_handler(&pgfault);
  801311:	68 55 12 80 00       	push   $0x801255
  801316:	e8 dd 16 00 00       	call   8029f8 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  80131b:	b8 07 00 00 00       	mov    $0x7,%eax
  801320:	cd 30                	int    $0x30

	// Create child
	envid_t envid = sys_exofork();
  801322:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (envid < 0) {
  801325:	83 c4 10             	add    $0x10,%esp
  801328:	85 c0                	test   %eax,%eax
  80132a:	79 12                	jns    80133e <fork+0x35>
		panic("sys_exofork: %e", envid);
  80132c:	50                   	push   %eax
  80132d:	68 0c 33 80 00       	push   $0x80330c
  801332:	6a 7c                	push   $0x7c
  801334:	68 db 32 80 00       	push   $0x8032db
  801339:	e8 a6 f1 ff ff       	call   8004e4 <_panic>
		return envid;
	}
	if (envid == 0) {
  80133e:	85 c0                	test   %eax,%eax
  801340:	75 1e                	jne    801360 <fork+0x57>
		// We are the child.
		thisenv = &envs[ENVX(sys_getenvid())]; // Fix thisenv
  801342:	e8 c0 fb ff ff       	call   800f07 <sys_getenvid>
  801347:	25 ff 03 00 00       	and    $0x3ff,%eax
  80134c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80134f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801354:	a3 08 50 80 00       	mov    %eax,0x805008
		return 0;
  801359:	b8 00 00 00 00       	mov    $0x0,%eax
  80135e:	eb 7d                	jmp    8013dd <fork+0xd4>

	// Set page fault handler on the child.
	// The parent needs to do it, else the child wouldn't be able to handle
	// the fault when trying to access it's stack (which happens as soon it starts)
	extern void _pgfault_upcall(void);
	sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);
  801360:	83 ec 04             	sub    $0x4,%esp
  801363:	6a 07                	push   $0x7
  801365:	68 00 f0 bf ee       	push   $0xeebff000
  80136a:	50                   	push   %eax
  80136b:	e8 d5 fb ff ff       	call   800f45 <sys_page_alloc>
	sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  801370:	83 c4 08             	add    $0x8,%esp
  801373:	68 3d 2a 80 00       	push   $0x802a3d
  801378:	ff 75 f4             	pushl  -0xc(%ebp)
  80137b:	e8 10 fd ff ff       	call   801090 <sys_env_set_pgfault_upcall>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  801380:	be 04 80 80 00       	mov    $0x808004,%esi
  801385:	c1 ee 0c             	shr    $0xc,%esi
  801388:	83 c4 10             	add    $0x10,%esp
  80138b:	bb 00 08 00 00       	mov    $0x800,%ebx
  801390:	eb 0d                	jmp    80139f <fork+0x96>
		duppage(envid, pn);
  801392:	89 da                	mov    %ebx,%edx
  801394:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801397:	e8 b9 fd ff ff       	call   801155 <duppage>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  80139c:	83 c3 01             	add    $0x1,%ebx
  80139f:	39 f3                	cmp    %esi,%ebx
  8013a1:	76 ef                	jbe    801392 <fork+0x89>
	}

	// Also copy the stack we are currently running on
	// I think it should loop from ustacktop to this page, since the stack
	// can have more than 1 page
	duppage(envid, ((uint32_t) &envid)/PGSIZE);
  8013a3:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8013a6:	c1 ea 0c             	shr    $0xc,%edx
  8013a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013ac:	e8 a4 fd ff ff       	call   801155 <duppage>

	// Start the child environmnet running
	int r;
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  8013b1:	83 ec 08             	sub    $0x8,%esp
  8013b4:	6a 02                	push   $0x2
  8013b6:	ff 75 f4             	pushl  -0xc(%ebp)
  8013b9:	e8 4e fc ff ff       	call   80100c <sys_env_set_status>
  8013be:	83 c4 10             	add    $0x10,%esp
  8013c1:	85 c0                	test   %eax,%eax
  8013c3:	79 15                	jns    8013da <fork+0xd1>
		panic("sys_env_set_status: %e", r);
  8013c5:	50                   	push   %eax
  8013c6:	68 1c 33 80 00       	push   $0x80331c
  8013cb:	68 9c 00 00 00       	push   $0x9c
  8013d0:	68 db 32 80 00       	push   $0x8032db
  8013d5:	e8 0a f1 ff ff       	call   8004e4 <_panic>
		return r;
	}

	return envid;
  8013da:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8013dd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013e0:	5b                   	pop    %ebx
  8013e1:	5e                   	pop    %esi
  8013e2:	5d                   	pop    %ebp
  8013e3:	c3                   	ret    

008013e4 <sfork>:

// Challenge!
int
sfork(void)
{
  8013e4:	55                   	push   %ebp
  8013e5:	89 e5                	mov    %esp,%ebp
  8013e7:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8013ea:	68 33 33 80 00       	push   $0x803333
  8013ef:	68 a7 00 00 00       	push   $0xa7
  8013f4:	68 db 32 80 00       	push   $0x8032db
  8013f9:	e8 e6 f0 ff ff       	call   8004e4 <_panic>

008013fe <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8013fe:	55                   	push   %ebp
  8013ff:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801401:	8b 45 08             	mov    0x8(%ebp),%eax
  801404:	05 00 00 00 30       	add    $0x30000000,%eax
  801409:	c1 e8 0c             	shr    $0xc,%eax
}
  80140c:	5d                   	pop    %ebp
  80140d:	c3                   	ret    

0080140e <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80140e:	55                   	push   %ebp
  80140f:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801411:	8b 45 08             	mov    0x8(%ebp),%eax
  801414:	05 00 00 00 30       	add    $0x30000000,%eax
  801419:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80141e:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801423:	5d                   	pop    %ebp
  801424:	c3                   	ret    

00801425 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801425:	55                   	push   %ebp
  801426:	89 e5                	mov    %esp,%ebp
  801428:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80142b:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801430:	89 c2                	mov    %eax,%edx
  801432:	c1 ea 16             	shr    $0x16,%edx
  801435:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80143c:	f6 c2 01             	test   $0x1,%dl
  80143f:	74 11                	je     801452 <fd_alloc+0x2d>
  801441:	89 c2                	mov    %eax,%edx
  801443:	c1 ea 0c             	shr    $0xc,%edx
  801446:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80144d:	f6 c2 01             	test   $0x1,%dl
  801450:	75 09                	jne    80145b <fd_alloc+0x36>
			*fd_store = fd;
  801452:	89 01                	mov    %eax,(%ecx)
			return 0;
  801454:	b8 00 00 00 00       	mov    $0x0,%eax
  801459:	eb 17                	jmp    801472 <fd_alloc+0x4d>
  80145b:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801460:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801465:	75 c9                	jne    801430 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801467:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80146d:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801472:	5d                   	pop    %ebp
  801473:	c3                   	ret    

00801474 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801474:	55                   	push   %ebp
  801475:	89 e5                	mov    %esp,%ebp
  801477:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80147a:	83 f8 1f             	cmp    $0x1f,%eax
  80147d:	77 36                	ja     8014b5 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80147f:	c1 e0 0c             	shl    $0xc,%eax
  801482:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801487:	89 c2                	mov    %eax,%edx
  801489:	c1 ea 16             	shr    $0x16,%edx
  80148c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801493:	f6 c2 01             	test   $0x1,%dl
  801496:	74 24                	je     8014bc <fd_lookup+0x48>
  801498:	89 c2                	mov    %eax,%edx
  80149a:	c1 ea 0c             	shr    $0xc,%edx
  80149d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014a4:	f6 c2 01             	test   $0x1,%dl
  8014a7:	74 1a                	je     8014c3 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8014a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014ac:	89 02                	mov    %eax,(%edx)
	return 0;
  8014ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8014b3:	eb 13                	jmp    8014c8 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014b5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014ba:	eb 0c                	jmp    8014c8 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014bc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014c1:	eb 05                	jmp    8014c8 <fd_lookup+0x54>
  8014c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8014c8:	5d                   	pop    %ebp
  8014c9:	c3                   	ret    

008014ca <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8014ca:	55                   	push   %ebp
  8014cb:	89 e5                	mov    %esp,%ebp
  8014cd:	83 ec 08             	sub    $0x8,%esp
  8014d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014d3:	ba c8 33 80 00       	mov    $0x8033c8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8014d8:	eb 13                	jmp    8014ed <dev_lookup+0x23>
  8014da:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8014dd:	39 08                	cmp    %ecx,(%eax)
  8014df:	75 0c                	jne    8014ed <dev_lookup+0x23>
			*dev = devtab[i];
  8014e1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014e4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8014e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8014eb:	eb 2e                	jmp    80151b <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8014ed:	8b 02                	mov    (%edx),%eax
  8014ef:	85 c0                	test   %eax,%eax
  8014f1:	75 e7                	jne    8014da <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8014f3:	a1 08 50 80 00       	mov    0x805008,%eax
  8014f8:	8b 40 48             	mov    0x48(%eax),%eax
  8014fb:	83 ec 04             	sub    $0x4,%esp
  8014fe:	51                   	push   %ecx
  8014ff:	50                   	push   %eax
  801500:	68 4c 33 80 00       	push   $0x80334c
  801505:	e8 b3 f0 ff ff       	call   8005bd <cprintf>
	*dev = 0;
  80150a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80150d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801513:	83 c4 10             	add    $0x10,%esp
  801516:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80151b:	c9                   	leave  
  80151c:	c3                   	ret    

0080151d <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80151d:	55                   	push   %ebp
  80151e:	89 e5                	mov    %esp,%ebp
  801520:	56                   	push   %esi
  801521:	53                   	push   %ebx
  801522:	83 ec 10             	sub    $0x10,%esp
  801525:	8b 75 08             	mov    0x8(%ebp),%esi
  801528:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80152b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80152e:	50                   	push   %eax
  80152f:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801535:	c1 e8 0c             	shr    $0xc,%eax
  801538:	50                   	push   %eax
  801539:	e8 36 ff ff ff       	call   801474 <fd_lookup>
  80153e:	83 c4 08             	add    $0x8,%esp
  801541:	85 c0                	test   %eax,%eax
  801543:	78 05                	js     80154a <fd_close+0x2d>
	    || fd != fd2)
  801545:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801548:	74 0c                	je     801556 <fd_close+0x39>
		return (must_exist ? r : 0);
  80154a:	84 db                	test   %bl,%bl
  80154c:	ba 00 00 00 00       	mov    $0x0,%edx
  801551:	0f 44 c2             	cmove  %edx,%eax
  801554:	eb 41                	jmp    801597 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801556:	83 ec 08             	sub    $0x8,%esp
  801559:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80155c:	50                   	push   %eax
  80155d:	ff 36                	pushl  (%esi)
  80155f:	e8 66 ff ff ff       	call   8014ca <dev_lookup>
  801564:	89 c3                	mov    %eax,%ebx
  801566:	83 c4 10             	add    $0x10,%esp
  801569:	85 c0                	test   %eax,%eax
  80156b:	78 1a                	js     801587 <fd_close+0x6a>
		if (dev->dev_close)
  80156d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801570:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801573:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801578:	85 c0                	test   %eax,%eax
  80157a:	74 0b                	je     801587 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80157c:	83 ec 0c             	sub    $0xc,%esp
  80157f:	56                   	push   %esi
  801580:	ff d0                	call   *%eax
  801582:	89 c3                	mov    %eax,%ebx
  801584:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801587:	83 ec 08             	sub    $0x8,%esp
  80158a:	56                   	push   %esi
  80158b:	6a 00                	push   $0x0
  80158d:	e8 38 fa ff ff       	call   800fca <sys_page_unmap>
	return r;
  801592:	83 c4 10             	add    $0x10,%esp
  801595:	89 d8                	mov    %ebx,%eax
}
  801597:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80159a:	5b                   	pop    %ebx
  80159b:	5e                   	pop    %esi
  80159c:	5d                   	pop    %ebp
  80159d:	c3                   	ret    

0080159e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80159e:	55                   	push   %ebp
  80159f:	89 e5                	mov    %esp,%ebp
  8015a1:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015a4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015a7:	50                   	push   %eax
  8015a8:	ff 75 08             	pushl  0x8(%ebp)
  8015ab:	e8 c4 fe ff ff       	call   801474 <fd_lookup>
  8015b0:	83 c4 08             	add    $0x8,%esp
  8015b3:	85 c0                	test   %eax,%eax
  8015b5:	78 10                	js     8015c7 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8015b7:	83 ec 08             	sub    $0x8,%esp
  8015ba:	6a 01                	push   $0x1
  8015bc:	ff 75 f4             	pushl  -0xc(%ebp)
  8015bf:	e8 59 ff ff ff       	call   80151d <fd_close>
  8015c4:	83 c4 10             	add    $0x10,%esp
}
  8015c7:	c9                   	leave  
  8015c8:	c3                   	ret    

008015c9 <close_all>:

void
close_all(void)
{
  8015c9:	55                   	push   %ebp
  8015ca:	89 e5                	mov    %esp,%ebp
  8015cc:	53                   	push   %ebx
  8015cd:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8015d0:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8015d5:	83 ec 0c             	sub    $0xc,%esp
  8015d8:	53                   	push   %ebx
  8015d9:	e8 c0 ff ff ff       	call   80159e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8015de:	83 c3 01             	add    $0x1,%ebx
  8015e1:	83 c4 10             	add    $0x10,%esp
  8015e4:	83 fb 20             	cmp    $0x20,%ebx
  8015e7:	75 ec                	jne    8015d5 <close_all+0xc>
		close(i);
}
  8015e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015ec:	c9                   	leave  
  8015ed:	c3                   	ret    

008015ee <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8015ee:	55                   	push   %ebp
  8015ef:	89 e5                	mov    %esp,%ebp
  8015f1:	57                   	push   %edi
  8015f2:	56                   	push   %esi
  8015f3:	53                   	push   %ebx
  8015f4:	83 ec 2c             	sub    $0x2c,%esp
  8015f7:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8015fa:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8015fd:	50                   	push   %eax
  8015fe:	ff 75 08             	pushl  0x8(%ebp)
  801601:	e8 6e fe ff ff       	call   801474 <fd_lookup>
  801606:	83 c4 08             	add    $0x8,%esp
  801609:	85 c0                	test   %eax,%eax
  80160b:	0f 88 c1 00 00 00    	js     8016d2 <dup+0xe4>
		return r;
	close(newfdnum);
  801611:	83 ec 0c             	sub    $0xc,%esp
  801614:	56                   	push   %esi
  801615:	e8 84 ff ff ff       	call   80159e <close>

	newfd = INDEX2FD(newfdnum);
  80161a:	89 f3                	mov    %esi,%ebx
  80161c:	c1 e3 0c             	shl    $0xc,%ebx
  80161f:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801625:	83 c4 04             	add    $0x4,%esp
  801628:	ff 75 e4             	pushl  -0x1c(%ebp)
  80162b:	e8 de fd ff ff       	call   80140e <fd2data>
  801630:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801632:	89 1c 24             	mov    %ebx,(%esp)
  801635:	e8 d4 fd ff ff       	call   80140e <fd2data>
  80163a:	83 c4 10             	add    $0x10,%esp
  80163d:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801640:	89 f8                	mov    %edi,%eax
  801642:	c1 e8 16             	shr    $0x16,%eax
  801645:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80164c:	a8 01                	test   $0x1,%al
  80164e:	74 37                	je     801687 <dup+0x99>
  801650:	89 f8                	mov    %edi,%eax
  801652:	c1 e8 0c             	shr    $0xc,%eax
  801655:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80165c:	f6 c2 01             	test   $0x1,%dl
  80165f:	74 26                	je     801687 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801661:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801668:	83 ec 0c             	sub    $0xc,%esp
  80166b:	25 07 0e 00 00       	and    $0xe07,%eax
  801670:	50                   	push   %eax
  801671:	ff 75 d4             	pushl  -0x2c(%ebp)
  801674:	6a 00                	push   $0x0
  801676:	57                   	push   %edi
  801677:	6a 00                	push   $0x0
  801679:	e8 0a f9 ff ff       	call   800f88 <sys_page_map>
  80167e:	89 c7                	mov    %eax,%edi
  801680:	83 c4 20             	add    $0x20,%esp
  801683:	85 c0                	test   %eax,%eax
  801685:	78 2e                	js     8016b5 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801687:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80168a:	89 d0                	mov    %edx,%eax
  80168c:	c1 e8 0c             	shr    $0xc,%eax
  80168f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801696:	83 ec 0c             	sub    $0xc,%esp
  801699:	25 07 0e 00 00       	and    $0xe07,%eax
  80169e:	50                   	push   %eax
  80169f:	53                   	push   %ebx
  8016a0:	6a 00                	push   $0x0
  8016a2:	52                   	push   %edx
  8016a3:	6a 00                	push   $0x0
  8016a5:	e8 de f8 ff ff       	call   800f88 <sys_page_map>
  8016aa:	89 c7                	mov    %eax,%edi
  8016ac:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8016af:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016b1:	85 ff                	test   %edi,%edi
  8016b3:	79 1d                	jns    8016d2 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8016b5:	83 ec 08             	sub    $0x8,%esp
  8016b8:	53                   	push   %ebx
  8016b9:	6a 00                	push   $0x0
  8016bb:	e8 0a f9 ff ff       	call   800fca <sys_page_unmap>
	sys_page_unmap(0, nva);
  8016c0:	83 c4 08             	add    $0x8,%esp
  8016c3:	ff 75 d4             	pushl  -0x2c(%ebp)
  8016c6:	6a 00                	push   $0x0
  8016c8:	e8 fd f8 ff ff       	call   800fca <sys_page_unmap>
	return r;
  8016cd:	83 c4 10             	add    $0x10,%esp
  8016d0:	89 f8                	mov    %edi,%eax
}
  8016d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016d5:	5b                   	pop    %ebx
  8016d6:	5e                   	pop    %esi
  8016d7:	5f                   	pop    %edi
  8016d8:	5d                   	pop    %ebp
  8016d9:	c3                   	ret    

008016da <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8016da:	55                   	push   %ebp
  8016db:	89 e5                	mov    %esp,%ebp
  8016dd:	53                   	push   %ebx
  8016de:	83 ec 14             	sub    $0x14,%esp
  8016e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016e4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016e7:	50                   	push   %eax
  8016e8:	53                   	push   %ebx
  8016e9:	e8 86 fd ff ff       	call   801474 <fd_lookup>
  8016ee:	83 c4 08             	add    $0x8,%esp
  8016f1:	89 c2                	mov    %eax,%edx
  8016f3:	85 c0                	test   %eax,%eax
  8016f5:	78 6d                	js     801764 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016f7:	83 ec 08             	sub    $0x8,%esp
  8016fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016fd:	50                   	push   %eax
  8016fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801701:	ff 30                	pushl  (%eax)
  801703:	e8 c2 fd ff ff       	call   8014ca <dev_lookup>
  801708:	83 c4 10             	add    $0x10,%esp
  80170b:	85 c0                	test   %eax,%eax
  80170d:	78 4c                	js     80175b <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80170f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801712:	8b 42 08             	mov    0x8(%edx),%eax
  801715:	83 e0 03             	and    $0x3,%eax
  801718:	83 f8 01             	cmp    $0x1,%eax
  80171b:	75 21                	jne    80173e <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80171d:	a1 08 50 80 00       	mov    0x805008,%eax
  801722:	8b 40 48             	mov    0x48(%eax),%eax
  801725:	83 ec 04             	sub    $0x4,%esp
  801728:	53                   	push   %ebx
  801729:	50                   	push   %eax
  80172a:	68 8d 33 80 00       	push   $0x80338d
  80172f:	e8 89 ee ff ff       	call   8005bd <cprintf>
		return -E_INVAL;
  801734:	83 c4 10             	add    $0x10,%esp
  801737:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80173c:	eb 26                	jmp    801764 <read+0x8a>
	}
	if (!dev->dev_read)
  80173e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801741:	8b 40 08             	mov    0x8(%eax),%eax
  801744:	85 c0                	test   %eax,%eax
  801746:	74 17                	je     80175f <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801748:	83 ec 04             	sub    $0x4,%esp
  80174b:	ff 75 10             	pushl  0x10(%ebp)
  80174e:	ff 75 0c             	pushl  0xc(%ebp)
  801751:	52                   	push   %edx
  801752:	ff d0                	call   *%eax
  801754:	89 c2                	mov    %eax,%edx
  801756:	83 c4 10             	add    $0x10,%esp
  801759:	eb 09                	jmp    801764 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80175b:	89 c2                	mov    %eax,%edx
  80175d:	eb 05                	jmp    801764 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80175f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801764:	89 d0                	mov    %edx,%eax
  801766:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801769:	c9                   	leave  
  80176a:	c3                   	ret    

0080176b <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80176b:	55                   	push   %ebp
  80176c:	89 e5                	mov    %esp,%ebp
  80176e:	57                   	push   %edi
  80176f:	56                   	push   %esi
  801770:	53                   	push   %ebx
  801771:	83 ec 0c             	sub    $0xc,%esp
  801774:	8b 7d 08             	mov    0x8(%ebp),%edi
  801777:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80177a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80177f:	eb 21                	jmp    8017a2 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801781:	83 ec 04             	sub    $0x4,%esp
  801784:	89 f0                	mov    %esi,%eax
  801786:	29 d8                	sub    %ebx,%eax
  801788:	50                   	push   %eax
  801789:	89 d8                	mov    %ebx,%eax
  80178b:	03 45 0c             	add    0xc(%ebp),%eax
  80178e:	50                   	push   %eax
  80178f:	57                   	push   %edi
  801790:	e8 45 ff ff ff       	call   8016da <read>
		if (m < 0)
  801795:	83 c4 10             	add    $0x10,%esp
  801798:	85 c0                	test   %eax,%eax
  80179a:	78 10                	js     8017ac <readn+0x41>
			return m;
		if (m == 0)
  80179c:	85 c0                	test   %eax,%eax
  80179e:	74 0a                	je     8017aa <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017a0:	01 c3                	add    %eax,%ebx
  8017a2:	39 f3                	cmp    %esi,%ebx
  8017a4:	72 db                	jb     801781 <readn+0x16>
  8017a6:	89 d8                	mov    %ebx,%eax
  8017a8:	eb 02                	jmp    8017ac <readn+0x41>
  8017aa:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8017ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017af:	5b                   	pop    %ebx
  8017b0:	5e                   	pop    %esi
  8017b1:	5f                   	pop    %edi
  8017b2:	5d                   	pop    %ebp
  8017b3:	c3                   	ret    

008017b4 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8017b4:	55                   	push   %ebp
  8017b5:	89 e5                	mov    %esp,%ebp
  8017b7:	53                   	push   %ebx
  8017b8:	83 ec 14             	sub    $0x14,%esp
  8017bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017be:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017c1:	50                   	push   %eax
  8017c2:	53                   	push   %ebx
  8017c3:	e8 ac fc ff ff       	call   801474 <fd_lookup>
  8017c8:	83 c4 08             	add    $0x8,%esp
  8017cb:	89 c2                	mov    %eax,%edx
  8017cd:	85 c0                	test   %eax,%eax
  8017cf:	78 68                	js     801839 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017d1:	83 ec 08             	sub    $0x8,%esp
  8017d4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017d7:	50                   	push   %eax
  8017d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017db:	ff 30                	pushl  (%eax)
  8017dd:	e8 e8 fc ff ff       	call   8014ca <dev_lookup>
  8017e2:	83 c4 10             	add    $0x10,%esp
  8017e5:	85 c0                	test   %eax,%eax
  8017e7:	78 47                	js     801830 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ec:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017f0:	75 21                	jne    801813 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8017f2:	a1 08 50 80 00       	mov    0x805008,%eax
  8017f7:	8b 40 48             	mov    0x48(%eax),%eax
  8017fa:	83 ec 04             	sub    $0x4,%esp
  8017fd:	53                   	push   %ebx
  8017fe:	50                   	push   %eax
  8017ff:	68 a9 33 80 00       	push   $0x8033a9
  801804:	e8 b4 ed ff ff       	call   8005bd <cprintf>
		return -E_INVAL;
  801809:	83 c4 10             	add    $0x10,%esp
  80180c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801811:	eb 26                	jmp    801839 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801813:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801816:	8b 52 0c             	mov    0xc(%edx),%edx
  801819:	85 d2                	test   %edx,%edx
  80181b:	74 17                	je     801834 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80181d:	83 ec 04             	sub    $0x4,%esp
  801820:	ff 75 10             	pushl  0x10(%ebp)
  801823:	ff 75 0c             	pushl  0xc(%ebp)
  801826:	50                   	push   %eax
  801827:	ff d2                	call   *%edx
  801829:	89 c2                	mov    %eax,%edx
  80182b:	83 c4 10             	add    $0x10,%esp
  80182e:	eb 09                	jmp    801839 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801830:	89 c2                	mov    %eax,%edx
  801832:	eb 05                	jmp    801839 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801834:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801839:	89 d0                	mov    %edx,%eax
  80183b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80183e:	c9                   	leave  
  80183f:	c3                   	ret    

00801840 <seek>:

int
seek(int fdnum, off_t offset)
{
  801840:	55                   	push   %ebp
  801841:	89 e5                	mov    %esp,%ebp
  801843:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801846:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801849:	50                   	push   %eax
  80184a:	ff 75 08             	pushl  0x8(%ebp)
  80184d:	e8 22 fc ff ff       	call   801474 <fd_lookup>
  801852:	83 c4 08             	add    $0x8,%esp
  801855:	85 c0                	test   %eax,%eax
  801857:	78 0e                	js     801867 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801859:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80185c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80185f:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801862:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801867:	c9                   	leave  
  801868:	c3                   	ret    

00801869 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801869:	55                   	push   %ebp
  80186a:	89 e5                	mov    %esp,%ebp
  80186c:	53                   	push   %ebx
  80186d:	83 ec 14             	sub    $0x14,%esp
  801870:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801873:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801876:	50                   	push   %eax
  801877:	53                   	push   %ebx
  801878:	e8 f7 fb ff ff       	call   801474 <fd_lookup>
  80187d:	83 c4 08             	add    $0x8,%esp
  801880:	89 c2                	mov    %eax,%edx
  801882:	85 c0                	test   %eax,%eax
  801884:	78 65                	js     8018eb <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801886:	83 ec 08             	sub    $0x8,%esp
  801889:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80188c:	50                   	push   %eax
  80188d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801890:	ff 30                	pushl  (%eax)
  801892:	e8 33 fc ff ff       	call   8014ca <dev_lookup>
  801897:	83 c4 10             	add    $0x10,%esp
  80189a:	85 c0                	test   %eax,%eax
  80189c:	78 44                	js     8018e2 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80189e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018a1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018a5:	75 21                	jne    8018c8 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8018a7:	a1 08 50 80 00       	mov    0x805008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8018ac:	8b 40 48             	mov    0x48(%eax),%eax
  8018af:	83 ec 04             	sub    $0x4,%esp
  8018b2:	53                   	push   %ebx
  8018b3:	50                   	push   %eax
  8018b4:	68 6c 33 80 00       	push   $0x80336c
  8018b9:	e8 ff ec ff ff       	call   8005bd <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8018be:	83 c4 10             	add    $0x10,%esp
  8018c1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8018c6:	eb 23                	jmp    8018eb <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8018c8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018cb:	8b 52 18             	mov    0x18(%edx),%edx
  8018ce:	85 d2                	test   %edx,%edx
  8018d0:	74 14                	je     8018e6 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8018d2:	83 ec 08             	sub    $0x8,%esp
  8018d5:	ff 75 0c             	pushl  0xc(%ebp)
  8018d8:	50                   	push   %eax
  8018d9:	ff d2                	call   *%edx
  8018db:	89 c2                	mov    %eax,%edx
  8018dd:	83 c4 10             	add    $0x10,%esp
  8018e0:	eb 09                	jmp    8018eb <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018e2:	89 c2                	mov    %eax,%edx
  8018e4:	eb 05                	jmp    8018eb <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8018e6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8018eb:	89 d0                	mov    %edx,%eax
  8018ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018f0:	c9                   	leave  
  8018f1:	c3                   	ret    

008018f2 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8018f2:	55                   	push   %ebp
  8018f3:	89 e5                	mov    %esp,%ebp
  8018f5:	53                   	push   %ebx
  8018f6:	83 ec 14             	sub    $0x14,%esp
  8018f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018fc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018ff:	50                   	push   %eax
  801900:	ff 75 08             	pushl  0x8(%ebp)
  801903:	e8 6c fb ff ff       	call   801474 <fd_lookup>
  801908:	83 c4 08             	add    $0x8,%esp
  80190b:	89 c2                	mov    %eax,%edx
  80190d:	85 c0                	test   %eax,%eax
  80190f:	78 58                	js     801969 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801911:	83 ec 08             	sub    $0x8,%esp
  801914:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801917:	50                   	push   %eax
  801918:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80191b:	ff 30                	pushl  (%eax)
  80191d:	e8 a8 fb ff ff       	call   8014ca <dev_lookup>
  801922:	83 c4 10             	add    $0x10,%esp
  801925:	85 c0                	test   %eax,%eax
  801927:	78 37                	js     801960 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801929:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80192c:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801930:	74 32                	je     801964 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801932:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801935:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80193c:	00 00 00 
	stat->st_isdir = 0;
  80193f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801946:	00 00 00 
	stat->st_dev = dev;
  801949:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80194f:	83 ec 08             	sub    $0x8,%esp
  801952:	53                   	push   %ebx
  801953:	ff 75 f0             	pushl  -0x10(%ebp)
  801956:	ff 50 14             	call   *0x14(%eax)
  801959:	89 c2                	mov    %eax,%edx
  80195b:	83 c4 10             	add    $0x10,%esp
  80195e:	eb 09                	jmp    801969 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801960:	89 c2                	mov    %eax,%edx
  801962:	eb 05                	jmp    801969 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801964:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801969:	89 d0                	mov    %edx,%eax
  80196b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80196e:	c9                   	leave  
  80196f:	c3                   	ret    

00801970 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801970:	55                   	push   %ebp
  801971:	89 e5                	mov    %esp,%ebp
  801973:	56                   	push   %esi
  801974:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801975:	83 ec 08             	sub    $0x8,%esp
  801978:	6a 00                	push   $0x0
  80197a:	ff 75 08             	pushl  0x8(%ebp)
  80197d:	e8 0c 02 00 00       	call   801b8e <open>
  801982:	89 c3                	mov    %eax,%ebx
  801984:	83 c4 10             	add    $0x10,%esp
  801987:	85 c0                	test   %eax,%eax
  801989:	78 1b                	js     8019a6 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80198b:	83 ec 08             	sub    $0x8,%esp
  80198e:	ff 75 0c             	pushl  0xc(%ebp)
  801991:	50                   	push   %eax
  801992:	e8 5b ff ff ff       	call   8018f2 <fstat>
  801997:	89 c6                	mov    %eax,%esi
	close(fd);
  801999:	89 1c 24             	mov    %ebx,(%esp)
  80199c:	e8 fd fb ff ff       	call   80159e <close>
	return r;
  8019a1:	83 c4 10             	add    $0x10,%esp
  8019a4:	89 f0                	mov    %esi,%eax
}
  8019a6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019a9:	5b                   	pop    %ebx
  8019aa:	5e                   	pop    %esi
  8019ab:	5d                   	pop    %ebp
  8019ac:	c3                   	ret    

008019ad <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8019ad:	55                   	push   %ebp
  8019ae:	89 e5                	mov    %esp,%ebp
  8019b0:	56                   	push   %esi
  8019b1:	53                   	push   %ebx
  8019b2:	89 c6                	mov    %eax,%esi
  8019b4:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8019b6:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8019bd:	75 12                	jne    8019d1 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8019bf:	83 ec 0c             	sub    $0xc,%esp
  8019c2:	6a 01                	push   $0x1
  8019c4:	e8 62 11 00 00       	call   802b2b <ipc_find_env>
  8019c9:	a3 00 50 80 00       	mov    %eax,0x805000
  8019ce:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8019d1:	6a 07                	push   $0x7
  8019d3:	68 00 60 80 00       	push   $0x806000
  8019d8:	56                   	push   %esi
  8019d9:	ff 35 00 50 80 00    	pushl  0x805000
  8019df:	e8 f3 10 00 00       	call   802ad7 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8019e4:	83 c4 0c             	add    $0xc,%esp
  8019e7:	6a 00                	push   $0x0
  8019e9:	53                   	push   %ebx
  8019ea:	6a 00                	push   $0x0
  8019ec:	e8 7d 10 00 00       	call   802a6e <ipc_recv>
}
  8019f1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019f4:	5b                   	pop    %ebx
  8019f5:	5e                   	pop    %esi
  8019f6:	5d                   	pop    %ebp
  8019f7:	c3                   	ret    

008019f8 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8019f8:	55                   	push   %ebp
  8019f9:	89 e5                	mov    %esp,%ebp
  8019fb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8019fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801a01:	8b 40 0c             	mov    0xc(%eax),%eax
  801a04:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801a09:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a0c:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a11:	ba 00 00 00 00       	mov    $0x0,%edx
  801a16:	b8 02 00 00 00       	mov    $0x2,%eax
  801a1b:	e8 8d ff ff ff       	call   8019ad <fsipc>
}
  801a20:	c9                   	leave  
  801a21:	c3                   	ret    

00801a22 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801a22:	55                   	push   %ebp
  801a23:	89 e5                	mov    %esp,%ebp
  801a25:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a28:	8b 45 08             	mov    0x8(%ebp),%eax
  801a2b:	8b 40 0c             	mov    0xc(%eax),%eax
  801a2e:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801a33:	ba 00 00 00 00       	mov    $0x0,%edx
  801a38:	b8 06 00 00 00       	mov    $0x6,%eax
  801a3d:	e8 6b ff ff ff       	call   8019ad <fsipc>
}
  801a42:	c9                   	leave  
  801a43:	c3                   	ret    

00801a44 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a44:	55                   	push   %ebp
  801a45:	89 e5                	mov    %esp,%ebp
  801a47:	53                   	push   %ebx
  801a48:	83 ec 04             	sub    $0x4,%esp
  801a4b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a4e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a51:	8b 40 0c             	mov    0xc(%eax),%eax
  801a54:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a59:	ba 00 00 00 00       	mov    $0x0,%edx
  801a5e:	b8 05 00 00 00       	mov    $0x5,%eax
  801a63:	e8 45 ff ff ff       	call   8019ad <fsipc>
  801a68:	85 c0                	test   %eax,%eax
  801a6a:	78 2c                	js     801a98 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a6c:	83 ec 08             	sub    $0x8,%esp
  801a6f:	68 00 60 80 00       	push   $0x806000
  801a74:	53                   	push   %ebx
  801a75:	e8 c8 f0 ff ff       	call   800b42 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a7a:	a1 80 60 80 00       	mov    0x806080,%eax
  801a7f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a85:	a1 84 60 80 00       	mov    0x806084,%eax
  801a8a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a90:	83 c4 10             	add    $0x10,%esp
  801a93:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a98:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a9b:	c9                   	leave  
  801a9c:	c3                   	ret    

00801a9d <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801a9d:	55                   	push   %ebp
  801a9e:	89 e5                	mov    %esp,%ebp
  801aa0:	53                   	push   %ebx
  801aa1:	83 ec 08             	sub    $0x8,%esp
  801aa4:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801aa7:	8b 55 08             	mov    0x8(%ebp),%edx
  801aaa:	8b 52 0c             	mov    0xc(%edx),%edx
  801aad:	89 15 00 60 80 00    	mov    %edx,0x806000
  801ab3:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801ab8:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  801abd:	0f 46 d8             	cmovbe %eax,%ebx
	
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  801ac0:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  801ac6:	53                   	push   %ebx
  801ac7:	ff 75 0c             	pushl  0xc(%ebp)
  801aca:	68 08 60 80 00       	push   $0x806008
  801acf:	e8 00 f2 ff ff       	call   800cd4 <memmove>

	
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) 
  801ad4:	ba 00 00 00 00       	mov    $0x0,%edx
  801ad9:	b8 04 00 00 00       	mov    $0x4,%eax
  801ade:	e8 ca fe ff ff       	call   8019ad <fsipc>
  801ae3:	83 c4 10             	add    $0x10,%esp
  801ae6:	85 c0                	test   %eax,%eax
  801ae8:	78 1d                	js     801b07 <devfile_write+0x6a>
		return r;
	assert(r <= n_real); 
  801aea:	39 d8                	cmp    %ebx,%eax
  801aec:	76 19                	jbe    801b07 <devfile_write+0x6a>
  801aee:	68 dc 33 80 00       	push   $0x8033dc
  801af3:	68 e8 33 80 00       	push   $0x8033e8
  801af8:	68 a3 00 00 00       	push   $0xa3
  801afd:	68 fd 33 80 00       	push   $0x8033fd
  801b02:	e8 dd e9 ff ff       	call   8004e4 <_panic>
	return r;
}
  801b07:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b0a:	c9                   	leave  
  801b0b:	c3                   	ret    

00801b0c <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801b0c:	55                   	push   %ebp
  801b0d:	89 e5                	mov    %esp,%ebp
  801b0f:	56                   	push   %esi
  801b10:	53                   	push   %ebx
  801b11:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b14:	8b 45 08             	mov    0x8(%ebp),%eax
  801b17:	8b 40 0c             	mov    0xc(%eax),%eax
  801b1a:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801b1f:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b25:	ba 00 00 00 00       	mov    $0x0,%edx
  801b2a:	b8 03 00 00 00       	mov    $0x3,%eax
  801b2f:	e8 79 fe ff ff       	call   8019ad <fsipc>
  801b34:	89 c3                	mov    %eax,%ebx
  801b36:	85 c0                	test   %eax,%eax
  801b38:	78 4b                	js     801b85 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801b3a:	39 c6                	cmp    %eax,%esi
  801b3c:	73 16                	jae    801b54 <devfile_read+0x48>
  801b3e:	68 08 34 80 00       	push   $0x803408
  801b43:	68 e8 33 80 00       	push   $0x8033e8
  801b48:	6a 7c                	push   $0x7c
  801b4a:	68 fd 33 80 00       	push   $0x8033fd
  801b4f:	e8 90 e9 ff ff       	call   8004e4 <_panic>
	assert(r <= PGSIZE);
  801b54:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b59:	7e 16                	jle    801b71 <devfile_read+0x65>
  801b5b:	68 0f 34 80 00       	push   $0x80340f
  801b60:	68 e8 33 80 00       	push   $0x8033e8
  801b65:	6a 7d                	push   $0x7d
  801b67:	68 fd 33 80 00       	push   $0x8033fd
  801b6c:	e8 73 e9 ff ff       	call   8004e4 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b71:	83 ec 04             	sub    $0x4,%esp
  801b74:	50                   	push   %eax
  801b75:	68 00 60 80 00       	push   $0x806000
  801b7a:	ff 75 0c             	pushl  0xc(%ebp)
  801b7d:	e8 52 f1 ff ff       	call   800cd4 <memmove>
	return r;
  801b82:	83 c4 10             	add    $0x10,%esp
}
  801b85:	89 d8                	mov    %ebx,%eax
  801b87:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b8a:	5b                   	pop    %ebx
  801b8b:	5e                   	pop    %esi
  801b8c:	5d                   	pop    %ebp
  801b8d:	c3                   	ret    

00801b8e <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801b8e:	55                   	push   %ebp
  801b8f:	89 e5                	mov    %esp,%ebp
  801b91:	53                   	push   %ebx
  801b92:	83 ec 20             	sub    $0x20,%esp
  801b95:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801b98:	53                   	push   %ebx
  801b99:	e8 6b ef ff ff       	call   800b09 <strlen>
  801b9e:	83 c4 10             	add    $0x10,%esp
  801ba1:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801ba6:	7f 67                	jg     801c0f <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801ba8:	83 ec 0c             	sub    $0xc,%esp
  801bab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bae:	50                   	push   %eax
  801baf:	e8 71 f8 ff ff       	call   801425 <fd_alloc>
  801bb4:	83 c4 10             	add    $0x10,%esp
		return r;
  801bb7:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801bb9:	85 c0                	test   %eax,%eax
  801bbb:	78 57                	js     801c14 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801bbd:	83 ec 08             	sub    $0x8,%esp
  801bc0:	53                   	push   %ebx
  801bc1:	68 00 60 80 00       	push   $0x806000
  801bc6:	e8 77 ef ff ff       	call   800b42 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801bcb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bce:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801bd3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bd6:	b8 01 00 00 00       	mov    $0x1,%eax
  801bdb:	e8 cd fd ff ff       	call   8019ad <fsipc>
  801be0:	89 c3                	mov    %eax,%ebx
  801be2:	83 c4 10             	add    $0x10,%esp
  801be5:	85 c0                	test   %eax,%eax
  801be7:	79 14                	jns    801bfd <open+0x6f>
		fd_close(fd, 0);
  801be9:	83 ec 08             	sub    $0x8,%esp
  801bec:	6a 00                	push   $0x0
  801bee:	ff 75 f4             	pushl  -0xc(%ebp)
  801bf1:	e8 27 f9 ff ff       	call   80151d <fd_close>
		return r;
  801bf6:	83 c4 10             	add    $0x10,%esp
  801bf9:	89 da                	mov    %ebx,%edx
  801bfb:	eb 17                	jmp    801c14 <open+0x86>
	}

	return fd2num(fd);
  801bfd:	83 ec 0c             	sub    $0xc,%esp
  801c00:	ff 75 f4             	pushl  -0xc(%ebp)
  801c03:	e8 f6 f7 ff ff       	call   8013fe <fd2num>
  801c08:	89 c2                	mov    %eax,%edx
  801c0a:	83 c4 10             	add    $0x10,%esp
  801c0d:	eb 05                	jmp    801c14 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801c0f:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801c14:	89 d0                	mov    %edx,%eax
  801c16:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c19:	c9                   	leave  
  801c1a:	c3                   	ret    

00801c1b <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c1b:	55                   	push   %ebp
  801c1c:	89 e5                	mov    %esp,%ebp
  801c1e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c21:	ba 00 00 00 00       	mov    $0x0,%edx
  801c26:	b8 08 00 00 00       	mov    $0x8,%eax
  801c2b:	e8 7d fd ff ff       	call   8019ad <fsipc>
}
  801c30:	c9                   	leave  
  801c31:	c3                   	ret    

00801c32 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801c32:	55                   	push   %ebp
  801c33:	89 e5                	mov    %esp,%ebp
  801c35:	57                   	push   %edi
  801c36:	56                   	push   %esi
  801c37:	53                   	push   %ebx
  801c38:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801c3e:	6a 00                	push   $0x0
  801c40:	ff 75 08             	pushl  0x8(%ebp)
  801c43:	e8 46 ff ff ff       	call   801b8e <open>
  801c48:	89 c7                	mov    %eax,%edi
  801c4a:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801c50:	83 c4 10             	add    $0x10,%esp
  801c53:	85 c0                	test   %eax,%eax
  801c55:	0f 88 ae 04 00 00    	js     802109 <spawn+0x4d7>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801c5b:	83 ec 04             	sub    $0x4,%esp
  801c5e:	68 00 02 00 00       	push   $0x200
  801c63:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801c69:	50                   	push   %eax
  801c6a:	57                   	push   %edi
  801c6b:	e8 fb fa ff ff       	call   80176b <readn>
  801c70:	83 c4 10             	add    $0x10,%esp
  801c73:	3d 00 02 00 00       	cmp    $0x200,%eax
  801c78:	75 0c                	jne    801c86 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  801c7a:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801c81:	45 4c 46 
  801c84:	74 33                	je     801cb9 <spawn+0x87>
		close(fd);
  801c86:	83 ec 0c             	sub    $0xc,%esp
  801c89:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801c8f:	e8 0a f9 ff ff       	call   80159e <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801c94:	83 c4 0c             	add    $0xc,%esp
  801c97:	68 7f 45 4c 46       	push   $0x464c457f
  801c9c:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801ca2:	68 1b 34 80 00       	push   $0x80341b
  801ca7:	e8 11 e9 ff ff       	call   8005bd <cprintf>
		return -E_NOT_EXEC;
  801cac:	83 c4 10             	add    $0x10,%esp
  801caf:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801cb4:	e9 b0 04 00 00       	jmp    802169 <spawn+0x537>
  801cb9:	b8 07 00 00 00       	mov    $0x7,%eax
  801cbe:	cd 30                	int    $0x30
  801cc0:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801cc6:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801ccc:	85 c0                	test   %eax,%eax
  801cce:	0f 88 3d 04 00 00    	js     802111 <spawn+0x4df>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801cd4:	89 c6                	mov    %eax,%esi
  801cd6:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801cdc:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801cdf:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801ce5:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801ceb:	b9 11 00 00 00       	mov    $0x11,%ecx
  801cf0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801cf2:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801cf8:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801cfe:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801d03:	be 00 00 00 00       	mov    $0x0,%esi
  801d08:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801d0b:	eb 13                	jmp    801d20 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801d0d:	83 ec 0c             	sub    $0xc,%esp
  801d10:	50                   	push   %eax
  801d11:	e8 f3 ed ff ff       	call   800b09 <strlen>
  801d16:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801d1a:	83 c3 01             	add    $0x1,%ebx
  801d1d:	83 c4 10             	add    $0x10,%esp
  801d20:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801d27:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801d2a:	85 c0                	test   %eax,%eax
  801d2c:	75 df                	jne    801d0d <spawn+0xdb>
  801d2e:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801d34:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801d3a:	bf 00 10 40 00       	mov    $0x401000,%edi
  801d3f:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801d41:	89 fa                	mov    %edi,%edx
  801d43:	83 e2 fc             	and    $0xfffffffc,%edx
  801d46:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801d4d:	29 c2                	sub    %eax,%edx
  801d4f:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801d55:	8d 42 f8             	lea    -0x8(%edx),%eax
  801d58:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801d5d:	0f 86 be 03 00 00    	jbe    802121 <spawn+0x4ef>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801d63:	83 ec 04             	sub    $0x4,%esp
  801d66:	6a 07                	push   $0x7
  801d68:	68 00 00 40 00       	push   $0x400000
  801d6d:	6a 00                	push   $0x0
  801d6f:	e8 d1 f1 ff ff       	call   800f45 <sys_page_alloc>
  801d74:	83 c4 10             	add    $0x10,%esp
  801d77:	85 c0                	test   %eax,%eax
  801d79:	0f 88 a9 03 00 00    	js     802128 <spawn+0x4f6>
  801d7f:	be 00 00 00 00       	mov    $0x0,%esi
  801d84:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801d8a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801d8d:	eb 30                	jmp    801dbf <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801d8f:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801d95:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801d9b:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801d9e:	83 ec 08             	sub    $0x8,%esp
  801da1:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801da4:	57                   	push   %edi
  801da5:	e8 98 ed ff ff       	call   800b42 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801daa:	83 c4 04             	add    $0x4,%esp
  801dad:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801db0:	e8 54 ed ff ff       	call   800b09 <strlen>
  801db5:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801db9:	83 c6 01             	add    $0x1,%esi
  801dbc:	83 c4 10             	add    $0x10,%esp
  801dbf:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801dc5:	7f c8                	jg     801d8f <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801dc7:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801dcd:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801dd3:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801dda:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801de0:	74 19                	je     801dfb <spawn+0x1c9>
  801de2:	68 78 34 80 00       	push   $0x803478
  801de7:	68 e8 33 80 00       	push   $0x8033e8
  801dec:	68 f2 00 00 00       	push   $0xf2
  801df1:	68 35 34 80 00       	push   $0x803435
  801df6:	e8 e9 e6 ff ff       	call   8004e4 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801dfb:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801e01:	89 f8                	mov    %edi,%eax
  801e03:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801e08:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801e0b:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801e11:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801e14:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801e1a:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801e20:	83 ec 0c             	sub    $0xc,%esp
  801e23:	6a 07                	push   $0x7
  801e25:	68 00 d0 bf ee       	push   $0xeebfd000
  801e2a:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e30:	68 00 00 40 00       	push   $0x400000
  801e35:	6a 00                	push   $0x0
  801e37:	e8 4c f1 ff ff       	call   800f88 <sys_page_map>
  801e3c:	89 c3                	mov    %eax,%ebx
  801e3e:	83 c4 20             	add    $0x20,%esp
  801e41:	85 c0                	test   %eax,%eax
  801e43:	0f 88 0e 03 00 00    	js     802157 <spawn+0x525>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801e49:	83 ec 08             	sub    $0x8,%esp
  801e4c:	68 00 00 40 00       	push   $0x400000
  801e51:	6a 00                	push   $0x0
  801e53:	e8 72 f1 ff ff       	call   800fca <sys_page_unmap>
  801e58:	89 c3                	mov    %eax,%ebx
  801e5a:	83 c4 10             	add    $0x10,%esp
  801e5d:	85 c0                	test   %eax,%eax
  801e5f:	0f 88 f2 02 00 00    	js     802157 <spawn+0x525>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801e65:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801e6b:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801e72:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801e78:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801e7f:	00 00 00 
  801e82:	e9 88 01 00 00       	jmp    80200f <spawn+0x3dd>
		if (ph->p_type != ELF_PROG_LOAD)
  801e87:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801e8d:	83 38 01             	cmpl   $0x1,(%eax)
  801e90:	0f 85 6b 01 00 00    	jne    802001 <spawn+0x3cf>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801e96:	89 c7                	mov    %eax,%edi
  801e98:	8b 40 18             	mov    0x18(%eax),%eax
  801e9b:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801ea1:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801ea4:	83 f8 01             	cmp    $0x1,%eax
  801ea7:	19 c0                	sbb    %eax,%eax
  801ea9:	83 e0 fe             	and    $0xfffffffe,%eax
  801eac:	83 c0 07             	add    $0x7,%eax
  801eaf:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801eb5:	89 f8                	mov    %edi,%eax
  801eb7:	8b 7f 04             	mov    0x4(%edi),%edi
  801eba:	89 f9                	mov    %edi,%ecx
  801ebc:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801ec2:	8b 78 10             	mov    0x10(%eax),%edi
  801ec5:	8b 50 14             	mov    0x14(%eax),%edx
  801ec8:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  801ece:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801ed1:	89 f0                	mov    %esi,%eax
  801ed3:	25 ff 0f 00 00       	and    $0xfff,%eax
  801ed8:	74 14                	je     801eee <spawn+0x2bc>
		va -= i;
  801eda:	29 c6                	sub    %eax,%esi
		memsz += i;
  801edc:	01 c2                	add    %eax,%edx
  801ede:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  801ee4:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801ee6:	29 c1                	sub    %eax,%ecx
  801ee8:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801eee:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ef3:	e9 f7 00 00 00       	jmp    801fef <spawn+0x3bd>
		if (i >= filesz) {
  801ef8:	39 df                	cmp    %ebx,%edi
  801efa:	77 27                	ja     801f23 <spawn+0x2f1>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801efc:	83 ec 04             	sub    $0x4,%esp
  801eff:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801f05:	56                   	push   %esi
  801f06:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801f0c:	e8 34 f0 ff ff       	call   800f45 <sys_page_alloc>
  801f11:	83 c4 10             	add    $0x10,%esp
  801f14:	85 c0                	test   %eax,%eax
  801f16:	0f 89 c7 00 00 00    	jns    801fe3 <spawn+0x3b1>
  801f1c:	89 c3                	mov    %eax,%ebx
  801f1e:	e9 13 02 00 00       	jmp    802136 <spawn+0x504>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801f23:	83 ec 04             	sub    $0x4,%esp
  801f26:	6a 07                	push   $0x7
  801f28:	68 00 00 40 00       	push   $0x400000
  801f2d:	6a 00                	push   $0x0
  801f2f:	e8 11 f0 ff ff       	call   800f45 <sys_page_alloc>
  801f34:	83 c4 10             	add    $0x10,%esp
  801f37:	85 c0                	test   %eax,%eax
  801f39:	0f 88 ed 01 00 00    	js     80212c <spawn+0x4fa>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801f3f:	83 ec 08             	sub    $0x8,%esp
  801f42:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801f48:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801f4e:	50                   	push   %eax
  801f4f:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801f55:	e8 e6 f8 ff ff       	call   801840 <seek>
  801f5a:	83 c4 10             	add    $0x10,%esp
  801f5d:	85 c0                	test   %eax,%eax
  801f5f:	0f 88 cb 01 00 00    	js     802130 <spawn+0x4fe>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801f65:	83 ec 04             	sub    $0x4,%esp
  801f68:	89 f8                	mov    %edi,%eax
  801f6a:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801f70:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801f75:	ba 00 10 00 00       	mov    $0x1000,%edx
  801f7a:	0f 47 c2             	cmova  %edx,%eax
  801f7d:	50                   	push   %eax
  801f7e:	68 00 00 40 00       	push   $0x400000
  801f83:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801f89:	e8 dd f7 ff ff       	call   80176b <readn>
  801f8e:	83 c4 10             	add    $0x10,%esp
  801f91:	85 c0                	test   %eax,%eax
  801f93:	0f 88 9b 01 00 00    	js     802134 <spawn+0x502>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801f99:	83 ec 0c             	sub    $0xc,%esp
  801f9c:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801fa2:	56                   	push   %esi
  801fa3:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801fa9:	68 00 00 40 00       	push   $0x400000
  801fae:	6a 00                	push   $0x0
  801fb0:	e8 d3 ef ff ff       	call   800f88 <sys_page_map>
  801fb5:	83 c4 20             	add    $0x20,%esp
  801fb8:	85 c0                	test   %eax,%eax
  801fba:	79 15                	jns    801fd1 <spawn+0x39f>
				panic("spawn: sys_page_map data: %e", r);
  801fbc:	50                   	push   %eax
  801fbd:	68 41 34 80 00       	push   $0x803441
  801fc2:	68 25 01 00 00       	push   $0x125
  801fc7:	68 35 34 80 00       	push   $0x803435
  801fcc:	e8 13 e5 ff ff       	call   8004e4 <_panic>
			sys_page_unmap(0, UTEMP);
  801fd1:	83 ec 08             	sub    $0x8,%esp
  801fd4:	68 00 00 40 00       	push   $0x400000
  801fd9:	6a 00                	push   $0x0
  801fdb:	e8 ea ef ff ff       	call   800fca <sys_page_unmap>
  801fe0:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801fe3:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801fe9:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801fef:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801ff5:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  801ffb:	0f 87 f7 fe ff ff    	ja     801ef8 <spawn+0x2c6>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802001:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  802008:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  80200f:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  802016:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  80201c:	0f 8c 65 fe ff ff    	jl     801e87 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  802022:	83 ec 0c             	sub    $0xc,%esp
  802025:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80202b:	e8 6e f5 ff ff       	call   80159e <close>
  802030:	83 c4 10             	add    $0x10,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	uintptr_t i;
	for (i = 0; i < USTACKTOP; i += PGSIZE){
  802033:	bb 00 00 00 00       	mov    $0x0,%ebx
  802038:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[PGNUM(i)] & PTE_P) && (uvpt[PGNUM(i)] & PTE_U) && (uvpt[PGNUM(i)] & PTE_SHARE)){
  80203e:	89 d8                	mov    %ebx,%eax
  802040:	c1 e8 16             	shr    $0x16,%eax
  802043:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80204a:	a8 01                	test   $0x1,%al
  80204c:	74 46                	je     802094 <spawn+0x462>
  80204e:	89 d8                	mov    %ebx,%eax
  802050:	c1 e8 0c             	shr    $0xc,%eax
  802053:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80205a:	f6 c2 01             	test   $0x1,%dl
  80205d:	74 35                	je     802094 <spawn+0x462>
  80205f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802066:	f6 c2 04             	test   $0x4,%dl
  802069:	74 29                	je     802094 <spawn+0x462>
  80206b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802072:	f6 c6 04             	test   $0x4,%dh
  802075:	74 1d                	je     802094 <spawn+0x462>
			sys_page_map(0, (void*)i,child, (void*)i,(uvpt[PGNUM(i)] | PTE_SYSCALL));
  802077:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80207e:	83 ec 0c             	sub    $0xc,%esp
  802081:	0d 07 0e 00 00       	or     $0xe07,%eax
  802086:	50                   	push   %eax
  802087:	53                   	push   %ebx
  802088:	56                   	push   %esi
  802089:	53                   	push   %ebx
  80208a:	6a 00                	push   $0x0
  80208c:	e8 f7 ee ff ff       	call   800f88 <sys_page_map>
  802091:	83 c4 20             	add    $0x20,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	uintptr_t i;
	for (i = 0; i < USTACKTOP; i += PGSIZE){
  802094:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80209a:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8020a0:	75 9c                	jne    80203e <spawn+0x40c>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  8020a2:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  8020a9:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  8020ac:	83 ec 08             	sub    $0x8,%esp
  8020af:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  8020b5:	50                   	push   %eax
  8020b6:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8020bc:	e8 8d ef ff ff       	call   80104e <sys_env_set_trapframe>
  8020c1:	83 c4 10             	add    $0x10,%esp
  8020c4:	85 c0                	test   %eax,%eax
  8020c6:	79 15                	jns    8020dd <spawn+0x4ab>
		panic("sys_env_set_trapframe: %e", r);
  8020c8:	50                   	push   %eax
  8020c9:	68 5e 34 80 00       	push   $0x80345e
  8020ce:	68 86 00 00 00       	push   $0x86
  8020d3:	68 35 34 80 00       	push   $0x803435
  8020d8:	e8 07 e4 ff ff       	call   8004e4 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  8020dd:	83 ec 08             	sub    $0x8,%esp
  8020e0:	6a 02                	push   $0x2
  8020e2:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8020e8:	e8 1f ef ff ff       	call   80100c <sys_env_set_status>
  8020ed:	83 c4 10             	add    $0x10,%esp
  8020f0:	85 c0                	test   %eax,%eax
  8020f2:	79 25                	jns    802119 <spawn+0x4e7>
		panic("sys_env_set_status: %e", r);
  8020f4:	50                   	push   %eax
  8020f5:	68 1c 33 80 00       	push   $0x80331c
  8020fa:	68 89 00 00 00       	push   $0x89
  8020ff:	68 35 34 80 00       	push   $0x803435
  802104:	e8 db e3 ff ff       	call   8004e4 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  802109:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  80210f:	eb 58                	jmp    802169 <spawn+0x537>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  802111:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  802117:	eb 50                	jmp    802169 <spawn+0x537>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  802119:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  80211f:	eb 48                	jmp    802169 <spawn+0x537>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  802121:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  802126:	eb 41                	jmp    802169 <spawn+0x537>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  802128:	89 c3                	mov    %eax,%ebx
  80212a:	eb 3d                	jmp    802169 <spawn+0x537>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80212c:	89 c3                	mov    %eax,%ebx
  80212e:	eb 06                	jmp    802136 <spawn+0x504>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  802130:	89 c3                	mov    %eax,%ebx
  802132:	eb 02                	jmp    802136 <spawn+0x504>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  802134:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  802136:	83 ec 0c             	sub    $0xc,%esp
  802139:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  80213f:	e8 82 ed ff ff       	call   800ec6 <sys_env_destroy>
	close(fd);
  802144:	83 c4 04             	add    $0x4,%esp
  802147:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80214d:	e8 4c f4 ff ff       	call   80159e <close>
	return r;
  802152:	83 c4 10             	add    $0x10,%esp
  802155:	eb 12                	jmp    802169 <spawn+0x537>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  802157:	83 ec 08             	sub    $0x8,%esp
  80215a:	68 00 00 40 00       	push   $0x400000
  80215f:	6a 00                	push   $0x0
  802161:	e8 64 ee ff ff       	call   800fca <sys_page_unmap>
  802166:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  802169:	89 d8                	mov    %ebx,%eax
  80216b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80216e:	5b                   	pop    %ebx
  80216f:	5e                   	pop    %esi
  802170:	5f                   	pop    %edi
  802171:	5d                   	pop    %ebp
  802172:	c3                   	ret    

00802173 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  802173:	55                   	push   %ebp
  802174:	89 e5                	mov    %esp,%ebp
  802176:	56                   	push   %esi
  802177:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802178:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  80217b:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802180:	eb 03                	jmp    802185 <spawnl+0x12>
		argc++;
  802182:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802185:	83 c2 04             	add    $0x4,%edx
  802188:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  80218c:	75 f4                	jne    802182 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  80218e:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  802195:	83 e2 f0             	and    $0xfffffff0,%edx
  802198:	29 d4                	sub    %edx,%esp
  80219a:	8d 54 24 03          	lea    0x3(%esp),%edx
  80219e:	c1 ea 02             	shr    $0x2,%edx
  8021a1:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  8021a8:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  8021aa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8021ad:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  8021b4:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  8021bb:	00 
  8021bc:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  8021be:	b8 00 00 00 00       	mov    $0x0,%eax
  8021c3:	eb 0a                	jmp    8021cf <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  8021c5:	83 c0 01             	add    $0x1,%eax
  8021c8:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  8021cc:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  8021cf:	39 d0                	cmp    %edx,%eax
  8021d1:	75 f2                	jne    8021c5 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  8021d3:	83 ec 08             	sub    $0x8,%esp
  8021d6:	56                   	push   %esi
  8021d7:	ff 75 08             	pushl  0x8(%ebp)
  8021da:	e8 53 fa ff ff       	call   801c32 <spawn>
}
  8021df:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021e2:	5b                   	pop    %ebx
  8021e3:	5e                   	pop    %esi
  8021e4:	5d                   	pop    %ebp
  8021e5:	c3                   	ret    

008021e6 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8021e6:	55                   	push   %ebp
  8021e7:	89 e5                	mov    %esp,%ebp
  8021e9:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8021ec:	68 a0 34 80 00       	push   $0x8034a0
  8021f1:	ff 75 0c             	pushl  0xc(%ebp)
  8021f4:	e8 49 e9 ff ff       	call   800b42 <strcpy>
	return 0;
}
  8021f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8021fe:	c9                   	leave  
  8021ff:	c3                   	ret    

00802200 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  802200:	55                   	push   %ebp
  802201:	89 e5                	mov    %esp,%ebp
  802203:	53                   	push   %ebx
  802204:	83 ec 10             	sub    $0x10,%esp
  802207:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80220a:	53                   	push   %ebx
  80220b:	e8 54 09 00 00       	call   802b64 <pageref>
  802210:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  802213:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  802218:	83 f8 01             	cmp    $0x1,%eax
  80221b:	75 10                	jne    80222d <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  80221d:	83 ec 0c             	sub    $0xc,%esp
  802220:	ff 73 0c             	pushl  0xc(%ebx)
  802223:	e8 c0 02 00 00       	call   8024e8 <nsipc_close>
  802228:	89 c2                	mov    %eax,%edx
  80222a:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  80222d:	89 d0                	mov    %edx,%eax
  80222f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802232:	c9                   	leave  
  802233:	c3                   	ret    

00802234 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  802234:	55                   	push   %ebp
  802235:	89 e5                	mov    %esp,%ebp
  802237:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  80223a:	6a 00                	push   $0x0
  80223c:	ff 75 10             	pushl  0x10(%ebp)
  80223f:	ff 75 0c             	pushl  0xc(%ebp)
  802242:	8b 45 08             	mov    0x8(%ebp),%eax
  802245:	ff 70 0c             	pushl  0xc(%eax)
  802248:	e8 78 03 00 00       	call   8025c5 <nsipc_send>
}
  80224d:	c9                   	leave  
  80224e:	c3                   	ret    

0080224f <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  80224f:	55                   	push   %ebp
  802250:	89 e5                	mov    %esp,%ebp
  802252:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  802255:	6a 00                	push   $0x0
  802257:	ff 75 10             	pushl  0x10(%ebp)
  80225a:	ff 75 0c             	pushl  0xc(%ebp)
  80225d:	8b 45 08             	mov    0x8(%ebp),%eax
  802260:	ff 70 0c             	pushl  0xc(%eax)
  802263:	e8 f1 02 00 00       	call   802559 <nsipc_recv>
}
  802268:	c9                   	leave  
  802269:	c3                   	ret    

0080226a <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  80226a:	55                   	push   %ebp
  80226b:	89 e5                	mov    %esp,%ebp
  80226d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  802270:	8d 55 f4             	lea    -0xc(%ebp),%edx
  802273:	52                   	push   %edx
  802274:	50                   	push   %eax
  802275:	e8 fa f1 ff ff       	call   801474 <fd_lookup>
  80227a:	83 c4 10             	add    $0x10,%esp
  80227d:	85 c0                	test   %eax,%eax
  80227f:	78 17                	js     802298 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  802281:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802284:	8b 0d 3c 40 80 00    	mov    0x80403c,%ecx
  80228a:	39 08                	cmp    %ecx,(%eax)
  80228c:	75 05                	jne    802293 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  80228e:	8b 40 0c             	mov    0xc(%eax),%eax
  802291:	eb 05                	jmp    802298 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  802293:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  802298:	c9                   	leave  
  802299:	c3                   	ret    

0080229a <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  80229a:	55                   	push   %ebp
  80229b:	89 e5                	mov    %esp,%ebp
  80229d:	56                   	push   %esi
  80229e:	53                   	push   %ebx
  80229f:	83 ec 1c             	sub    $0x1c,%esp
  8022a2:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8022a4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022a7:	50                   	push   %eax
  8022a8:	e8 78 f1 ff ff       	call   801425 <fd_alloc>
  8022ad:	89 c3                	mov    %eax,%ebx
  8022af:	83 c4 10             	add    $0x10,%esp
  8022b2:	85 c0                	test   %eax,%eax
  8022b4:	78 1b                	js     8022d1 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8022b6:	83 ec 04             	sub    $0x4,%esp
  8022b9:	68 07 04 00 00       	push   $0x407
  8022be:	ff 75 f4             	pushl  -0xc(%ebp)
  8022c1:	6a 00                	push   $0x0
  8022c3:	e8 7d ec ff ff       	call   800f45 <sys_page_alloc>
  8022c8:	89 c3                	mov    %eax,%ebx
  8022ca:	83 c4 10             	add    $0x10,%esp
  8022cd:	85 c0                	test   %eax,%eax
  8022cf:	79 10                	jns    8022e1 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  8022d1:	83 ec 0c             	sub    $0xc,%esp
  8022d4:	56                   	push   %esi
  8022d5:	e8 0e 02 00 00       	call   8024e8 <nsipc_close>
		return r;
  8022da:	83 c4 10             	add    $0x10,%esp
  8022dd:	89 d8                	mov    %ebx,%eax
  8022df:	eb 24                	jmp    802305 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  8022e1:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  8022e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022ea:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8022ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022ef:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8022f6:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8022f9:	83 ec 0c             	sub    $0xc,%esp
  8022fc:	50                   	push   %eax
  8022fd:	e8 fc f0 ff ff       	call   8013fe <fd2num>
  802302:	83 c4 10             	add    $0x10,%esp
}
  802305:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802308:	5b                   	pop    %ebx
  802309:	5e                   	pop    %esi
  80230a:	5d                   	pop    %ebp
  80230b:	c3                   	ret    

0080230c <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80230c:	55                   	push   %ebp
  80230d:	89 e5                	mov    %esp,%ebp
  80230f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802312:	8b 45 08             	mov    0x8(%ebp),%eax
  802315:	e8 50 ff ff ff       	call   80226a <fd2sockid>
		return r;
  80231a:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  80231c:	85 c0                	test   %eax,%eax
  80231e:	78 1f                	js     80233f <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802320:	83 ec 04             	sub    $0x4,%esp
  802323:	ff 75 10             	pushl  0x10(%ebp)
  802326:	ff 75 0c             	pushl  0xc(%ebp)
  802329:	50                   	push   %eax
  80232a:	e8 12 01 00 00       	call   802441 <nsipc_accept>
  80232f:	83 c4 10             	add    $0x10,%esp
		return r;
  802332:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802334:	85 c0                	test   %eax,%eax
  802336:	78 07                	js     80233f <accept+0x33>
		return r;
	return alloc_sockfd(r);
  802338:	e8 5d ff ff ff       	call   80229a <alloc_sockfd>
  80233d:	89 c1                	mov    %eax,%ecx
}
  80233f:	89 c8                	mov    %ecx,%eax
  802341:	c9                   	leave  
  802342:	c3                   	ret    

00802343 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802343:	55                   	push   %ebp
  802344:	89 e5                	mov    %esp,%ebp
  802346:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802349:	8b 45 08             	mov    0x8(%ebp),%eax
  80234c:	e8 19 ff ff ff       	call   80226a <fd2sockid>
  802351:	85 c0                	test   %eax,%eax
  802353:	78 12                	js     802367 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  802355:	83 ec 04             	sub    $0x4,%esp
  802358:	ff 75 10             	pushl  0x10(%ebp)
  80235b:	ff 75 0c             	pushl  0xc(%ebp)
  80235e:	50                   	push   %eax
  80235f:	e8 2d 01 00 00       	call   802491 <nsipc_bind>
  802364:	83 c4 10             	add    $0x10,%esp
}
  802367:	c9                   	leave  
  802368:	c3                   	ret    

00802369 <shutdown>:

int
shutdown(int s, int how)
{
  802369:	55                   	push   %ebp
  80236a:	89 e5                	mov    %esp,%ebp
  80236c:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80236f:	8b 45 08             	mov    0x8(%ebp),%eax
  802372:	e8 f3 fe ff ff       	call   80226a <fd2sockid>
  802377:	85 c0                	test   %eax,%eax
  802379:	78 0f                	js     80238a <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  80237b:	83 ec 08             	sub    $0x8,%esp
  80237e:	ff 75 0c             	pushl  0xc(%ebp)
  802381:	50                   	push   %eax
  802382:	e8 3f 01 00 00       	call   8024c6 <nsipc_shutdown>
  802387:	83 c4 10             	add    $0x10,%esp
}
  80238a:	c9                   	leave  
  80238b:	c3                   	ret    

0080238c <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80238c:	55                   	push   %ebp
  80238d:	89 e5                	mov    %esp,%ebp
  80238f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802392:	8b 45 08             	mov    0x8(%ebp),%eax
  802395:	e8 d0 fe ff ff       	call   80226a <fd2sockid>
  80239a:	85 c0                	test   %eax,%eax
  80239c:	78 12                	js     8023b0 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  80239e:	83 ec 04             	sub    $0x4,%esp
  8023a1:	ff 75 10             	pushl  0x10(%ebp)
  8023a4:	ff 75 0c             	pushl  0xc(%ebp)
  8023a7:	50                   	push   %eax
  8023a8:	e8 55 01 00 00       	call   802502 <nsipc_connect>
  8023ad:	83 c4 10             	add    $0x10,%esp
}
  8023b0:	c9                   	leave  
  8023b1:	c3                   	ret    

008023b2 <listen>:

int
listen(int s, int backlog)
{
  8023b2:	55                   	push   %ebp
  8023b3:	89 e5                	mov    %esp,%ebp
  8023b5:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8023b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8023bb:	e8 aa fe ff ff       	call   80226a <fd2sockid>
  8023c0:	85 c0                	test   %eax,%eax
  8023c2:	78 0f                	js     8023d3 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8023c4:	83 ec 08             	sub    $0x8,%esp
  8023c7:	ff 75 0c             	pushl  0xc(%ebp)
  8023ca:	50                   	push   %eax
  8023cb:	e8 67 01 00 00       	call   802537 <nsipc_listen>
  8023d0:	83 c4 10             	add    $0x10,%esp
}
  8023d3:	c9                   	leave  
  8023d4:	c3                   	ret    

008023d5 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8023d5:	55                   	push   %ebp
  8023d6:	89 e5                	mov    %esp,%ebp
  8023d8:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8023db:	ff 75 10             	pushl  0x10(%ebp)
  8023de:	ff 75 0c             	pushl  0xc(%ebp)
  8023e1:	ff 75 08             	pushl  0x8(%ebp)
  8023e4:	e8 3a 02 00 00       	call   802623 <nsipc_socket>
  8023e9:	83 c4 10             	add    $0x10,%esp
  8023ec:	85 c0                	test   %eax,%eax
  8023ee:	78 05                	js     8023f5 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  8023f0:	e8 a5 fe ff ff       	call   80229a <alloc_sockfd>
}
  8023f5:	c9                   	leave  
  8023f6:	c3                   	ret    

008023f7 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8023f7:	55                   	push   %ebp
  8023f8:	89 e5                	mov    %esp,%ebp
  8023fa:	53                   	push   %ebx
  8023fb:	83 ec 04             	sub    $0x4,%esp
  8023fe:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  802400:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  802407:	75 12                	jne    80241b <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  802409:	83 ec 0c             	sub    $0xc,%esp
  80240c:	6a 02                	push   $0x2
  80240e:	e8 18 07 00 00       	call   802b2b <ipc_find_env>
  802413:	a3 04 50 80 00       	mov    %eax,0x805004
  802418:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  80241b:	6a 07                	push   $0x7
  80241d:	68 00 70 80 00       	push   $0x807000
  802422:	53                   	push   %ebx
  802423:	ff 35 04 50 80 00    	pushl  0x805004
  802429:	e8 a9 06 00 00       	call   802ad7 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  80242e:	83 c4 0c             	add    $0xc,%esp
  802431:	6a 00                	push   $0x0
  802433:	6a 00                	push   $0x0
  802435:	6a 00                	push   $0x0
  802437:	e8 32 06 00 00       	call   802a6e <ipc_recv>
}
  80243c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80243f:	c9                   	leave  
  802440:	c3                   	ret    

00802441 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802441:	55                   	push   %ebp
  802442:	89 e5                	mov    %esp,%ebp
  802444:	56                   	push   %esi
  802445:	53                   	push   %ebx
  802446:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  802449:	8b 45 08             	mov    0x8(%ebp),%eax
  80244c:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  802451:	8b 06                	mov    (%esi),%eax
  802453:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802458:	b8 01 00 00 00       	mov    $0x1,%eax
  80245d:	e8 95 ff ff ff       	call   8023f7 <nsipc>
  802462:	89 c3                	mov    %eax,%ebx
  802464:	85 c0                	test   %eax,%eax
  802466:	78 20                	js     802488 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802468:	83 ec 04             	sub    $0x4,%esp
  80246b:	ff 35 10 70 80 00    	pushl  0x807010
  802471:	68 00 70 80 00       	push   $0x807000
  802476:	ff 75 0c             	pushl  0xc(%ebp)
  802479:	e8 56 e8 ff ff       	call   800cd4 <memmove>
		*addrlen = ret->ret_addrlen;
  80247e:	a1 10 70 80 00       	mov    0x807010,%eax
  802483:	89 06                	mov    %eax,(%esi)
  802485:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  802488:	89 d8                	mov    %ebx,%eax
  80248a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80248d:	5b                   	pop    %ebx
  80248e:	5e                   	pop    %esi
  80248f:	5d                   	pop    %ebp
  802490:	c3                   	ret    

00802491 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802491:	55                   	push   %ebp
  802492:	89 e5                	mov    %esp,%ebp
  802494:	53                   	push   %ebx
  802495:	83 ec 08             	sub    $0x8,%esp
  802498:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80249b:	8b 45 08             	mov    0x8(%ebp),%eax
  80249e:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8024a3:	53                   	push   %ebx
  8024a4:	ff 75 0c             	pushl  0xc(%ebp)
  8024a7:	68 04 70 80 00       	push   $0x807004
  8024ac:	e8 23 e8 ff ff       	call   800cd4 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8024b1:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  8024b7:	b8 02 00 00 00       	mov    $0x2,%eax
  8024bc:	e8 36 ff ff ff       	call   8023f7 <nsipc>
}
  8024c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8024c4:	c9                   	leave  
  8024c5:	c3                   	ret    

008024c6 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8024c6:	55                   	push   %ebp
  8024c7:	89 e5                	mov    %esp,%ebp
  8024c9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8024cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8024cf:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  8024d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024d7:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  8024dc:	b8 03 00 00 00       	mov    $0x3,%eax
  8024e1:	e8 11 ff ff ff       	call   8023f7 <nsipc>
}
  8024e6:	c9                   	leave  
  8024e7:	c3                   	ret    

008024e8 <nsipc_close>:

int
nsipc_close(int s)
{
  8024e8:	55                   	push   %ebp
  8024e9:	89 e5                	mov    %esp,%ebp
  8024eb:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8024ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8024f1:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  8024f6:	b8 04 00 00 00       	mov    $0x4,%eax
  8024fb:	e8 f7 fe ff ff       	call   8023f7 <nsipc>
}
  802500:	c9                   	leave  
  802501:	c3                   	ret    

00802502 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802502:	55                   	push   %ebp
  802503:	89 e5                	mov    %esp,%ebp
  802505:	53                   	push   %ebx
  802506:	83 ec 08             	sub    $0x8,%esp
  802509:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80250c:	8b 45 08             	mov    0x8(%ebp),%eax
  80250f:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802514:	53                   	push   %ebx
  802515:	ff 75 0c             	pushl  0xc(%ebp)
  802518:	68 04 70 80 00       	push   $0x807004
  80251d:	e8 b2 e7 ff ff       	call   800cd4 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  802522:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  802528:	b8 05 00 00 00       	mov    $0x5,%eax
  80252d:	e8 c5 fe ff ff       	call   8023f7 <nsipc>
}
  802532:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802535:	c9                   	leave  
  802536:	c3                   	ret    

00802537 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  802537:	55                   	push   %ebp
  802538:	89 e5                	mov    %esp,%ebp
  80253a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80253d:	8b 45 08             	mov    0x8(%ebp),%eax
  802540:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  802545:	8b 45 0c             	mov    0xc(%ebp),%eax
  802548:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  80254d:	b8 06 00 00 00       	mov    $0x6,%eax
  802552:	e8 a0 fe ff ff       	call   8023f7 <nsipc>
}
  802557:	c9                   	leave  
  802558:	c3                   	ret    

00802559 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802559:	55                   	push   %ebp
  80255a:	89 e5                	mov    %esp,%ebp
  80255c:	56                   	push   %esi
  80255d:	53                   	push   %ebx
  80255e:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  802561:	8b 45 08             	mov    0x8(%ebp),%eax
  802564:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  802569:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  80256f:	8b 45 14             	mov    0x14(%ebp),%eax
  802572:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802577:	b8 07 00 00 00       	mov    $0x7,%eax
  80257c:	e8 76 fe ff ff       	call   8023f7 <nsipc>
  802581:	89 c3                	mov    %eax,%ebx
  802583:	85 c0                	test   %eax,%eax
  802585:	78 35                	js     8025bc <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  802587:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  80258c:	7f 04                	jg     802592 <nsipc_recv+0x39>
  80258e:	39 c6                	cmp    %eax,%esi
  802590:	7d 16                	jge    8025a8 <nsipc_recv+0x4f>
  802592:	68 ac 34 80 00       	push   $0x8034ac
  802597:	68 e8 33 80 00       	push   $0x8033e8
  80259c:	6a 62                	push   $0x62
  80259e:	68 c1 34 80 00       	push   $0x8034c1
  8025a3:	e8 3c df ff ff       	call   8004e4 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8025a8:	83 ec 04             	sub    $0x4,%esp
  8025ab:	50                   	push   %eax
  8025ac:	68 00 70 80 00       	push   $0x807000
  8025b1:	ff 75 0c             	pushl  0xc(%ebp)
  8025b4:	e8 1b e7 ff ff       	call   800cd4 <memmove>
  8025b9:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  8025bc:	89 d8                	mov    %ebx,%eax
  8025be:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8025c1:	5b                   	pop    %ebx
  8025c2:	5e                   	pop    %esi
  8025c3:	5d                   	pop    %ebp
  8025c4:	c3                   	ret    

008025c5 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8025c5:	55                   	push   %ebp
  8025c6:	89 e5                	mov    %esp,%ebp
  8025c8:	53                   	push   %ebx
  8025c9:	83 ec 04             	sub    $0x4,%esp
  8025cc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8025cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8025d2:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  8025d7:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8025dd:	7e 16                	jle    8025f5 <nsipc_send+0x30>
  8025df:	68 cd 34 80 00       	push   $0x8034cd
  8025e4:	68 e8 33 80 00       	push   $0x8033e8
  8025e9:	6a 6d                	push   $0x6d
  8025eb:	68 c1 34 80 00       	push   $0x8034c1
  8025f0:	e8 ef de ff ff       	call   8004e4 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8025f5:	83 ec 04             	sub    $0x4,%esp
  8025f8:	53                   	push   %ebx
  8025f9:	ff 75 0c             	pushl  0xc(%ebp)
  8025fc:	68 0c 70 80 00       	push   $0x80700c
  802601:	e8 ce e6 ff ff       	call   800cd4 <memmove>
	nsipcbuf.send.req_size = size;
  802606:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  80260c:	8b 45 14             	mov    0x14(%ebp),%eax
  80260f:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  802614:	b8 08 00 00 00       	mov    $0x8,%eax
  802619:	e8 d9 fd ff ff       	call   8023f7 <nsipc>
}
  80261e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802621:	c9                   	leave  
  802622:	c3                   	ret    

00802623 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  802623:	55                   	push   %ebp
  802624:	89 e5                	mov    %esp,%ebp
  802626:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802629:	8b 45 08             	mov    0x8(%ebp),%eax
  80262c:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  802631:	8b 45 0c             	mov    0xc(%ebp),%eax
  802634:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  802639:	8b 45 10             	mov    0x10(%ebp),%eax
  80263c:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  802641:	b8 09 00 00 00       	mov    $0x9,%eax
  802646:	e8 ac fd ff ff       	call   8023f7 <nsipc>
}
  80264b:	c9                   	leave  
  80264c:	c3                   	ret    

0080264d <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80264d:	55                   	push   %ebp
  80264e:	89 e5                	mov    %esp,%ebp
  802650:	56                   	push   %esi
  802651:	53                   	push   %ebx
  802652:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802655:	83 ec 0c             	sub    $0xc,%esp
  802658:	ff 75 08             	pushl  0x8(%ebp)
  80265b:	e8 ae ed ff ff       	call   80140e <fd2data>
  802660:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802662:	83 c4 08             	add    $0x8,%esp
  802665:	68 d9 34 80 00       	push   $0x8034d9
  80266a:	53                   	push   %ebx
  80266b:	e8 d2 e4 ff ff       	call   800b42 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802670:	8b 46 04             	mov    0x4(%esi),%eax
  802673:	2b 06                	sub    (%esi),%eax
  802675:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80267b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802682:	00 00 00 
	stat->st_dev = &devpipe;
  802685:	c7 83 88 00 00 00 58 	movl   $0x804058,0x88(%ebx)
  80268c:	40 80 00 
	return 0;
}
  80268f:	b8 00 00 00 00       	mov    $0x0,%eax
  802694:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802697:	5b                   	pop    %ebx
  802698:	5e                   	pop    %esi
  802699:	5d                   	pop    %ebp
  80269a:	c3                   	ret    

0080269b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80269b:	55                   	push   %ebp
  80269c:	89 e5                	mov    %esp,%ebp
  80269e:	53                   	push   %ebx
  80269f:	83 ec 0c             	sub    $0xc,%esp
  8026a2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8026a5:	53                   	push   %ebx
  8026a6:	6a 00                	push   $0x0
  8026a8:	e8 1d e9 ff ff       	call   800fca <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8026ad:	89 1c 24             	mov    %ebx,(%esp)
  8026b0:	e8 59 ed ff ff       	call   80140e <fd2data>
  8026b5:	83 c4 08             	add    $0x8,%esp
  8026b8:	50                   	push   %eax
  8026b9:	6a 00                	push   $0x0
  8026bb:	e8 0a e9 ff ff       	call   800fca <sys_page_unmap>
}
  8026c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8026c3:	c9                   	leave  
  8026c4:	c3                   	ret    

008026c5 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8026c5:	55                   	push   %ebp
  8026c6:	89 e5                	mov    %esp,%ebp
  8026c8:	57                   	push   %edi
  8026c9:	56                   	push   %esi
  8026ca:	53                   	push   %ebx
  8026cb:	83 ec 1c             	sub    $0x1c,%esp
  8026ce:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8026d1:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8026d3:	a1 08 50 80 00       	mov    0x805008,%eax
  8026d8:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8026db:	83 ec 0c             	sub    $0xc,%esp
  8026de:	ff 75 e0             	pushl  -0x20(%ebp)
  8026e1:	e8 7e 04 00 00       	call   802b64 <pageref>
  8026e6:	89 c3                	mov    %eax,%ebx
  8026e8:	89 3c 24             	mov    %edi,(%esp)
  8026eb:	e8 74 04 00 00       	call   802b64 <pageref>
  8026f0:	83 c4 10             	add    $0x10,%esp
  8026f3:	39 c3                	cmp    %eax,%ebx
  8026f5:	0f 94 c1             	sete   %cl
  8026f8:	0f b6 c9             	movzbl %cl,%ecx
  8026fb:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8026fe:	8b 15 08 50 80 00    	mov    0x805008,%edx
  802704:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802707:	39 ce                	cmp    %ecx,%esi
  802709:	74 1b                	je     802726 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80270b:	39 c3                	cmp    %eax,%ebx
  80270d:	75 c4                	jne    8026d3 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80270f:	8b 42 58             	mov    0x58(%edx),%eax
  802712:	ff 75 e4             	pushl  -0x1c(%ebp)
  802715:	50                   	push   %eax
  802716:	56                   	push   %esi
  802717:	68 e0 34 80 00       	push   $0x8034e0
  80271c:	e8 9c de ff ff       	call   8005bd <cprintf>
  802721:	83 c4 10             	add    $0x10,%esp
  802724:	eb ad                	jmp    8026d3 <_pipeisclosed+0xe>
	}
}
  802726:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802729:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80272c:	5b                   	pop    %ebx
  80272d:	5e                   	pop    %esi
  80272e:	5f                   	pop    %edi
  80272f:	5d                   	pop    %ebp
  802730:	c3                   	ret    

00802731 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802731:	55                   	push   %ebp
  802732:	89 e5                	mov    %esp,%ebp
  802734:	57                   	push   %edi
  802735:	56                   	push   %esi
  802736:	53                   	push   %ebx
  802737:	83 ec 28             	sub    $0x28,%esp
  80273a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80273d:	56                   	push   %esi
  80273e:	e8 cb ec ff ff       	call   80140e <fd2data>
  802743:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802745:	83 c4 10             	add    $0x10,%esp
  802748:	bf 00 00 00 00       	mov    $0x0,%edi
  80274d:	eb 4b                	jmp    80279a <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80274f:	89 da                	mov    %ebx,%edx
  802751:	89 f0                	mov    %esi,%eax
  802753:	e8 6d ff ff ff       	call   8026c5 <_pipeisclosed>
  802758:	85 c0                	test   %eax,%eax
  80275a:	75 48                	jne    8027a4 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80275c:	e8 c5 e7 ff ff       	call   800f26 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802761:	8b 43 04             	mov    0x4(%ebx),%eax
  802764:	8b 0b                	mov    (%ebx),%ecx
  802766:	8d 51 20             	lea    0x20(%ecx),%edx
  802769:	39 d0                	cmp    %edx,%eax
  80276b:	73 e2                	jae    80274f <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80276d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802770:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802774:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802777:	89 c2                	mov    %eax,%edx
  802779:	c1 fa 1f             	sar    $0x1f,%edx
  80277c:	89 d1                	mov    %edx,%ecx
  80277e:	c1 e9 1b             	shr    $0x1b,%ecx
  802781:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802784:	83 e2 1f             	and    $0x1f,%edx
  802787:	29 ca                	sub    %ecx,%edx
  802789:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80278d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802791:	83 c0 01             	add    $0x1,%eax
  802794:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802797:	83 c7 01             	add    $0x1,%edi
  80279a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80279d:	75 c2                	jne    802761 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80279f:	8b 45 10             	mov    0x10(%ebp),%eax
  8027a2:	eb 05                	jmp    8027a9 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8027a4:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8027a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8027ac:	5b                   	pop    %ebx
  8027ad:	5e                   	pop    %esi
  8027ae:	5f                   	pop    %edi
  8027af:	5d                   	pop    %ebp
  8027b0:	c3                   	ret    

008027b1 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8027b1:	55                   	push   %ebp
  8027b2:	89 e5                	mov    %esp,%ebp
  8027b4:	57                   	push   %edi
  8027b5:	56                   	push   %esi
  8027b6:	53                   	push   %ebx
  8027b7:	83 ec 18             	sub    $0x18,%esp
  8027ba:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8027bd:	57                   	push   %edi
  8027be:	e8 4b ec ff ff       	call   80140e <fd2data>
  8027c3:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8027c5:	83 c4 10             	add    $0x10,%esp
  8027c8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8027cd:	eb 3d                	jmp    80280c <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8027cf:	85 db                	test   %ebx,%ebx
  8027d1:	74 04                	je     8027d7 <devpipe_read+0x26>
				return i;
  8027d3:	89 d8                	mov    %ebx,%eax
  8027d5:	eb 44                	jmp    80281b <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8027d7:	89 f2                	mov    %esi,%edx
  8027d9:	89 f8                	mov    %edi,%eax
  8027db:	e8 e5 fe ff ff       	call   8026c5 <_pipeisclosed>
  8027e0:	85 c0                	test   %eax,%eax
  8027e2:	75 32                	jne    802816 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8027e4:	e8 3d e7 ff ff       	call   800f26 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8027e9:	8b 06                	mov    (%esi),%eax
  8027eb:	3b 46 04             	cmp    0x4(%esi),%eax
  8027ee:	74 df                	je     8027cf <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8027f0:	99                   	cltd   
  8027f1:	c1 ea 1b             	shr    $0x1b,%edx
  8027f4:	01 d0                	add    %edx,%eax
  8027f6:	83 e0 1f             	and    $0x1f,%eax
  8027f9:	29 d0                	sub    %edx,%eax
  8027fb:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802800:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802803:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802806:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802809:	83 c3 01             	add    $0x1,%ebx
  80280c:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80280f:	75 d8                	jne    8027e9 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802811:	8b 45 10             	mov    0x10(%ebp),%eax
  802814:	eb 05                	jmp    80281b <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802816:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80281b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80281e:	5b                   	pop    %ebx
  80281f:	5e                   	pop    %esi
  802820:	5f                   	pop    %edi
  802821:	5d                   	pop    %ebp
  802822:	c3                   	ret    

00802823 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802823:	55                   	push   %ebp
  802824:	89 e5                	mov    %esp,%ebp
  802826:	56                   	push   %esi
  802827:	53                   	push   %ebx
  802828:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80282b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80282e:	50                   	push   %eax
  80282f:	e8 f1 eb ff ff       	call   801425 <fd_alloc>
  802834:	83 c4 10             	add    $0x10,%esp
  802837:	89 c2                	mov    %eax,%edx
  802839:	85 c0                	test   %eax,%eax
  80283b:	0f 88 2c 01 00 00    	js     80296d <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802841:	83 ec 04             	sub    $0x4,%esp
  802844:	68 07 04 00 00       	push   $0x407
  802849:	ff 75 f4             	pushl  -0xc(%ebp)
  80284c:	6a 00                	push   $0x0
  80284e:	e8 f2 e6 ff ff       	call   800f45 <sys_page_alloc>
  802853:	83 c4 10             	add    $0x10,%esp
  802856:	89 c2                	mov    %eax,%edx
  802858:	85 c0                	test   %eax,%eax
  80285a:	0f 88 0d 01 00 00    	js     80296d <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802860:	83 ec 0c             	sub    $0xc,%esp
  802863:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802866:	50                   	push   %eax
  802867:	e8 b9 eb ff ff       	call   801425 <fd_alloc>
  80286c:	89 c3                	mov    %eax,%ebx
  80286e:	83 c4 10             	add    $0x10,%esp
  802871:	85 c0                	test   %eax,%eax
  802873:	0f 88 e2 00 00 00    	js     80295b <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802879:	83 ec 04             	sub    $0x4,%esp
  80287c:	68 07 04 00 00       	push   $0x407
  802881:	ff 75 f0             	pushl  -0x10(%ebp)
  802884:	6a 00                	push   $0x0
  802886:	e8 ba e6 ff ff       	call   800f45 <sys_page_alloc>
  80288b:	89 c3                	mov    %eax,%ebx
  80288d:	83 c4 10             	add    $0x10,%esp
  802890:	85 c0                	test   %eax,%eax
  802892:	0f 88 c3 00 00 00    	js     80295b <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802898:	83 ec 0c             	sub    $0xc,%esp
  80289b:	ff 75 f4             	pushl  -0xc(%ebp)
  80289e:	e8 6b eb ff ff       	call   80140e <fd2data>
  8028a3:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8028a5:	83 c4 0c             	add    $0xc,%esp
  8028a8:	68 07 04 00 00       	push   $0x407
  8028ad:	50                   	push   %eax
  8028ae:	6a 00                	push   $0x0
  8028b0:	e8 90 e6 ff ff       	call   800f45 <sys_page_alloc>
  8028b5:	89 c3                	mov    %eax,%ebx
  8028b7:	83 c4 10             	add    $0x10,%esp
  8028ba:	85 c0                	test   %eax,%eax
  8028bc:	0f 88 89 00 00 00    	js     80294b <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8028c2:	83 ec 0c             	sub    $0xc,%esp
  8028c5:	ff 75 f0             	pushl  -0x10(%ebp)
  8028c8:	e8 41 eb ff ff       	call   80140e <fd2data>
  8028cd:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8028d4:	50                   	push   %eax
  8028d5:	6a 00                	push   $0x0
  8028d7:	56                   	push   %esi
  8028d8:	6a 00                	push   $0x0
  8028da:	e8 a9 e6 ff ff       	call   800f88 <sys_page_map>
  8028df:	89 c3                	mov    %eax,%ebx
  8028e1:	83 c4 20             	add    $0x20,%esp
  8028e4:	85 c0                	test   %eax,%eax
  8028e6:	78 55                	js     80293d <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8028e8:	8b 15 58 40 80 00    	mov    0x804058,%edx
  8028ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8028f1:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8028f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8028f6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8028fd:	8b 15 58 40 80 00    	mov    0x804058,%edx
  802903:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802906:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802908:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80290b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802912:	83 ec 0c             	sub    $0xc,%esp
  802915:	ff 75 f4             	pushl  -0xc(%ebp)
  802918:	e8 e1 ea ff ff       	call   8013fe <fd2num>
  80291d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802920:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802922:	83 c4 04             	add    $0x4,%esp
  802925:	ff 75 f0             	pushl  -0x10(%ebp)
  802928:	e8 d1 ea ff ff       	call   8013fe <fd2num>
  80292d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802930:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802933:	83 c4 10             	add    $0x10,%esp
  802936:	ba 00 00 00 00       	mov    $0x0,%edx
  80293b:	eb 30                	jmp    80296d <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80293d:	83 ec 08             	sub    $0x8,%esp
  802940:	56                   	push   %esi
  802941:	6a 00                	push   $0x0
  802943:	e8 82 e6 ff ff       	call   800fca <sys_page_unmap>
  802948:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80294b:	83 ec 08             	sub    $0x8,%esp
  80294e:	ff 75 f0             	pushl  -0x10(%ebp)
  802951:	6a 00                	push   $0x0
  802953:	e8 72 e6 ff ff       	call   800fca <sys_page_unmap>
  802958:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80295b:	83 ec 08             	sub    $0x8,%esp
  80295e:	ff 75 f4             	pushl  -0xc(%ebp)
  802961:	6a 00                	push   $0x0
  802963:	e8 62 e6 ff ff       	call   800fca <sys_page_unmap>
  802968:	83 c4 10             	add    $0x10,%esp
  80296b:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80296d:	89 d0                	mov    %edx,%eax
  80296f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802972:	5b                   	pop    %ebx
  802973:	5e                   	pop    %esi
  802974:	5d                   	pop    %ebp
  802975:	c3                   	ret    

00802976 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802976:	55                   	push   %ebp
  802977:	89 e5                	mov    %esp,%ebp
  802979:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80297c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80297f:	50                   	push   %eax
  802980:	ff 75 08             	pushl  0x8(%ebp)
  802983:	e8 ec ea ff ff       	call   801474 <fd_lookup>
  802988:	83 c4 10             	add    $0x10,%esp
  80298b:	85 c0                	test   %eax,%eax
  80298d:	78 18                	js     8029a7 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80298f:	83 ec 0c             	sub    $0xc,%esp
  802992:	ff 75 f4             	pushl  -0xc(%ebp)
  802995:	e8 74 ea ff ff       	call   80140e <fd2data>
	return _pipeisclosed(fd, p);
  80299a:	89 c2                	mov    %eax,%edx
  80299c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80299f:	e8 21 fd ff ff       	call   8026c5 <_pipeisclosed>
  8029a4:	83 c4 10             	add    $0x10,%esp
}
  8029a7:	c9                   	leave  
  8029a8:	c3                   	ret    

008029a9 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  8029a9:	55                   	push   %ebp
  8029aa:	89 e5                	mov    %esp,%ebp
  8029ac:	56                   	push   %esi
  8029ad:	53                   	push   %ebx
  8029ae:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  8029b1:	85 f6                	test   %esi,%esi
  8029b3:	75 16                	jne    8029cb <wait+0x22>
  8029b5:	68 f8 34 80 00       	push   $0x8034f8
  8029ba:	68 e8 33 80 00       	push   $0x8033e8
  8029bf:	6a 09                	push   $0x9
  8029c1:	68 03 35 80 00       	push   $0x803503
  8029c6:	e8 19 db ff ff       	call   8004e4 <_panic>
	e = &envs[ENVX(envid)];
  8029cb:	89 f3                	mov    %esi,%ebx
  8029cd:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8029d3:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  8029d6:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  8029dc:	eb 05                	jmp    8029e3 <wait+0x3a>
		sys_yield();
  8029de:	e8 43 e5 ff ff       	call   800f26 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8029e3:	8b 43 48             	mov    0x48(%ebx),%eax
  8029e6:	39 c6                	cmp    %eax,%esi
  8029e8:	75 07                	jne    8029f1 <wait+0x48>
  8029ea:	8b 43 54             	mov    0x54(%ebx),%eax
  8029ed:	85 c0                	test   %eax,%eax
  8029ef:	75 ed                	jne    8029de <wait+0x35>
		sys_yield();
}
  8029f1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8029f4:	5b                   	pop    %ebx
  8029f5:	5e                   	pop    %esi
  8029f6:	5d                   	pop    %ebp
  8029f7:	c3                   	ret    

008029f8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8029f8:	55                   	push   %ebp
  8029f9:	89 e5                	mov    %esp,%ebp
  8029fb:	53                   	push   %ebx
  8029fc:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  8029ff:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  802a06:	75 28                	jne    802a30 <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  802a08:	e8 fa e4 ff ff       	call   800f07 <sys_getenvid>
  802a0d:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_U | PTE_W);
  802a0f:	83 ec 04             	sub    $0x4,%esp
  802a12:	6a 06                	push   $0x6
  802a14:	68 00 f0 bf ee       	push   $0xeebff000
  802a19:	50                   	push   %eax
  802a1a:	e8 26 e5 ff ff       	call   800f45 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  802a1f:	83 c4 08             	add    $0x8,%esp
  802a22:	68 3d 2a 80 00       	push   $0x802a3d
  802a27:	53                   	push   %ebx
  802a28:	e8 63 e6 ff ff       	call   801090 <sys_env_set_pgfault_upcall>
  802a2d:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802a30:	8b 45 08             	mov    0x8(%ebp),%eax
  802a33:	a3 00 80 80 00       	mov    %eax,0x808000
}
  802a38:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802a3b:	c9                   	leave  
  802a3c:	c3                   	ret    

00802a3d <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802a3d:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802a3e:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  802a43:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802a45:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	# My method is different. Copy the values to the other stack
	# in a convinient way, and then pop everything.
	movl %esp, %ebp		# ebp refers to the exception stack
  802a48:	89 e5                	mov    %esp,%ebp
	movl 48(%ebp), %esp 	# go to other stack
  802a4a:	8b 65 30             	mov    0x30(%ebp),%esp

	pushl 40(%ebp)		# eip - ORDER SWITCHED WITH EFLAGS
  802a4d:	ff 75 28             	pushl  0x28(%ebp)
	pushl 44(%ebp)      	# eflags
  802a50:	ff 75 2c             	pushl  0x2c(%ebp)
	pushl 36(%ebp)		# all the 8 remaining regs
  802a53:	ff 75 24             	pushl  0x24(%ebp)
	pushl 32(%ebp)
  802a56:	ff 75 20             	pushl  0x20(%ebp)
	pushl 28(%ebp)
  802a59:	ff 75 1c             	pushl  0x1c(%ebp)
	pushl 24(%ebp)
  802a5c:	ff 75 18             	pushl  0x18(%ebp)
	pushl 20(%ebp)
  802a5f:	ff 75 14             	pushl  0x14(%ebp)
	pushl 16(%ebp)
  802a62:	ff 75 10             	pushl  0x10(%ebp)
	pushl 12(%ebp)
  802a65:	ff 75 0c             	pushl  0xc(%ebp)
	pushl 8(%ebp)
  802a68:	ff 75 08             	pushl  0x8(%ebp)

	popal			# now just pop everything!
  802a6b:	61                   	popa   
	popfl
  802a6c:	9d                   	popf   
	ret
  802a6d:	c3                   	ret    

00802a6e <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802a6e:	55                   	push   %ebp
  802a6f:	89 e5                	mov    %esp,%ebp
  802a71:	56                   	push   %esi
  802a72:	53                   	push   %ebx
  802a73:	8b 75 08             	mov    0x8(%ebp),%esi
  802a76:	8b 45 0c             	mov    0xc(%ebp),%eax
  802a79:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  802a7c:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  802a7e:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  802a83:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  802a86:	83 ec 0c             	sub    $0xc,%esp
  802a89:	50                   	push   %eax
  802a8a:	e8 66 e6 ff ff       	call   8010f5 <sys_ipc_recv>

	if (r < 0) {
  802a8f:	83 c4 10             	add    $0x10,%esp
  802a92:	85 c0                	test   %eax,%eax
  802a94:	79 16                	jns    802aac <ipc_recv+0x3e>
		if (from_env_store)
  802a96:	85 f6                	test   %esi,%esi
  802a98:	74 06                	je     802aa0 <ipc_recv+0x32>
			*from_env_store = 0;
  802a9a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  802aa0:	85 db                	test   %ebx,%ebx
  802aa2:	74 2c                	je     802ad0 <ipc_recv+0x62>
			*perm_store = 0;
  802aa4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802aaa:	eb 24                	jmp    802ad0 <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  802aac:	85 f6                	test   %esi,%esi
  802aae:	74 0a                	je     802aba <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  802ab0:	a1 08 50 80 00       	mov    0x805008,%eax
  802ab5:	8b 40 74             	mov    0x74(%eax),%eax
  802ab8:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  802aba:	85 db                	test   %ebx,%ebx
  802abc:	74 0a                	je     802ac8 <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  802abe:	a1 08 50 80 00       	mov    0x805008,%eax
  802ac3:	8b 40 78             	mov    0x78(%eax),%eax
  802ac6:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  802ac8:	a1 08 50 80 00       	mov    0x805008,%eax
  802acd:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  802ad0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802ad3:	5b                   	pop    %ebx
  802ad4:	5e                   	pop    %esi
  802ad5:	5d                   	pop    %ebp
  802ad6:	c3                   	ret    

00802ad7 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802ad7:	55                   	push   %ebp
  802ad8:	89 e5                	mov    %esp,%ebp
  802ada:	57                   	push   %edi
  802adb:	56                   	push   %esi
  802adc:	53                   	push   %ebx
  802add:	83 ec 0c             	sub    $0xc,%esp
  802ae0:	8b 7d 08             	mov    0x8(%ebp),%edi
  802ae3:	8b 75 0c             	mov    0xc(%ebp),%esi
  802ae6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  802ae9:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  802aeb:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  802af0:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  802af3:	ff 75 14             	pushl  0x14(%ebp)
  802af6:	53                   	push   %ebx
  802af7:	56                   	push   %esi
  802af8:	57                   	push   %edi
  802af9:	e8 d4 e5 ff ff       	call   8010d2 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  802afe:	83 c4 10             	add    $0x10,%esp
  802b01:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802b04:	75 07                	jne    802b0d <ipc_send+0x36>
			sys_yield();
  802b06:	e8 1b e4 ff ff       	call   800f26 <sys_yield>
  802b0b:	eb e6                	jmp    802af3 <ipc_send+0x1c>
		} else if (r < 0) {
  802b0d:	85 c0                	test   %eax,%eax
  802b0f:	79 12                	jns    802b23 <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  802b11:	50                   	push   %eax
  802b12:	68 0e 35 80 00       	push   $0x80350e
  802b17:	6a 51                	push   $0x51
  802b19:	68 1b 35 80 00       	push   $0x80351b
  802b1e:	e8 c1 d9 ff ff       	call   8004e4 <_panic>
		}
	}
}
  802b23:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802b26:	5b                   	pop    %ebx
  802b27:	5e                   	pop    %esi
  802b28:	5f                   	pop    %edi
  802b29:	5d                   	pop    %ebp
  802b2a:	c3                   	ret    

00802b2b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802b2b:	55                   	push   %ebp
  802b2c:	89 e5                	mov    %esp,%ebp
  802b2e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802b31:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802b36:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802b39:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802b3f:	8b 52 50             	mov    0x50(%edx),%edx
  802b42:	39 ca                	cmp    %ecx,%edx
  802b44:	75 0d                	jne    802b53 <ipc_find_env+0x28>
			return envs[i].env_id;
  802b46:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802b49:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802b4e:	8b 40 48             	mov    0x48(%eax),%eax
  802b51:	eb 0f                	jmp    802b62 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802b53:	83 c0 01             	add    $0x1,%eax
  802b56:	3d 00 04 00 00       	cmp    $0x400,%eax
  802b5b:	75 d9                	jne    802b36 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802b5d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802b62:	5d                   	pop    %ebp
  802b63:	c3                   	ret    

00802b64 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802b64:	55                   	push   %ebp
  802b65:	89 e5                	mov    %esp,%ebp
  802b67:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802b6a:	89 d0                	mov    %edx,%eax
  802b6c:	c1 e8 16             	shr    $0x16,%eax
  802b6f:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802b76:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802b7b:	f6 c1 01             	test   $0x1,%cl
  802b7e:	74 1d                	je     802b9d <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802b80:	c1 ea 0c             	shr    $0xc,%edx
  802b83:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802b8a:	f6 c2 01             	test   $0x1,%dl
  802b8d:	74 0e                	je     802b9d <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802b8f:	c1 ea 0c             	shr    $0xc,%edx
  802b92:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802b99:	ef 
  802b9a:	0f b7 c0             	movzwl %ax,%eax
}
  802b9d:	5d                   	pop    %ebp
  802b9e:	c3                   	ret    
  802b9f:	90                   	nop

00802ba0 <__udivdi3>:
  802ba0:	55                   	push   %ebp
  802ba1:	57                   	push   %edi
  802ba2:	56                   	push   %esi
  802ba3:	53                   	push   %ebx
  802ba4:	83 ec 1c             	sub    $0x1c,%esp
  802ba7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  802bab:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  802baf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802bb3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802bb7:	85 f6                	test   %esi,%esi
  802bb9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802bbd:	89 ca                	mov    %ecx,%edx
  802bbf:	89 f8                	mov    %edi,%eax
  802bc1:	75 3d                	jne    802c00 <__udivdi3+0x60>
  802bc3:	39 cf                	cmp    %ecx,%edi
  802bc5:	0f 87 c5 00 00 00    	ja     802c90 <__udivdi3+0xf0>
  802bcb:	85 ff                	test   %edi,%edi
  802bcd:	89 fd                	mov    %edi,%ebp
  802bcf:	75 0b                	jne    802bdc <__udivdi3+0x3c>
  802bd1:	b8 01 00 00 00       	mov    $0x1,%eax
  802bd6:	31 d2                	xor    %edx,%edx
  802bd8:	f7 f7                	div    %edi
  802bda:	89 c5                	mov    %eax,%ebp
  802bdc:	89 c8                	mov    %ecx,%eax
  802bde:	31 d2                	xor    %edx,%edx
  802be0:	f7 f5                	div    %ebp
  802be2:	89 c1                	mov    %eax,%ecx
  802be4:	89 d8                	mov    %ebx,%eax
  802be6:	89 cf                	mov    %ecx,%edi
  802be8:	f7 f5                	div    %ebp
  802bea:	89 c3                	mov    %eax,%ebx
  802bec:	89 d8                	mov    %ebx,%eax
  802bee:	89 fa                	mov    %edi,%edx
  802bf0:	83 c4 1c             	add    $0x1c,%esp
  802bf3:	5b                   	pop    %ebx
  802bf4:	5e                   	pop    %esi
  802bf5:	5f                   	pop    %edi
  802bf6:	5d                   	pop    %ebp
  802bf7:	c3                   	ret    
  802bf8:	90                   	nop
  802bf9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802c00:	39 ce                	cmp    %ecx,%esi
  802c02:	77 74                	ja     802c78 <__udivdi3+0xd8>
  802c04:	0f bd fe             	bsr    %esi,%edi
  802c07:	83 f7 1f             	xor    $0x1f,%edi
  802c0a:	0f 84 98 00 00 00    	je     802ca8 <__udivdi3+0x108>
  802c10:	bb 20 00 00 00       	mov    $0x20,%ebx
  802c15:	89 f9                	mov    %edi,%ecx
  802c17:	89 c5                	mov    %eax,%ebp
  802c19:	29 fb                	sub    %edi,%ebx
  802c1b:	d3 e6                	shl    %cl,%esi
  802c1d:	89 d9                	mov    %ebx,%ecx
  802c1f:	d3 ed                	shr    %cl,%ebp
  802c21:	89 f9                	mov    %edi,%ecx
  802c23:	d3 e0                	shl    %cl,%eax
  802c25:	09 ee                	or     %ebp,%esi
  802c27:	89 d9                	mov    %ebx,%ecx
  802c29:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802c2d:	89 d5                	mov    %edx,%ebp
  802c2f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802c33:	d3 ed                	shr    %cl,%ebp
  802c35:	89 f9                	mov    %edi,%ecx
  802c37:	d3 e2                	shl    %cl,%edx
  802c39:	89 d9                	mov    %ebx,%ecx
  802c3b:	d3 e8                	shr    %cl,%eax
  802c3d:	09 c2                	or     %eax,%edx
  802c3f:	89 d0                	mov    %edx,%eax
  802c41:	89 ea                	mov    %ebp,%edx
  802c43:	f7 f6                	div    %esi
  802c45:	89 d5                	mov    %edx,%ebp
  802c47:	89 c3                	mov    %eax,%ebx
  802c49:	f7 64 24 0c          	mull   0xc(%esp)
  802c4d:	39 d5                	cmp    %edx,%ebp
  802c4f:	72 10                	jb     802c61 <__udivdi3+0xc1>
  802c51:	8b 74 24 08          	mov    0x8(%esp),%esi
  802c55:	89 f9                	mov    %edi,%ecx
  802c57:	d3 e6                	shl    %cl,%esi
  802c59:	39 c6                	cmp    %eax,%esi
  802c5b:	73 07                	jae    802c64 <__udivdi3+0xc4>
  802c5d:	39 d5                	cmp    %edx,%ebp
  802c5f:	75 03                	jne    802c64 <__udivdi3+0xc4>
  802c61:	83 eb 01             	sub    $0x1,%ebx
  802c64:	31 ff                	xor    %edi,%edi
  802c66:	89 d8                	mov    %ebx,%eax
  802c68:	89 fa                	mov    %edi,%edx
  802c6a:	83 c4 1c             	add    $0x1c,%esp
  802c6d:	5b                   	pop    %ebx
  802c6e:	5e                   	pop    %esi
  802c6f:	5f                   	pop    %edi
  802c70:	5d                   	pop    %ebp
  802c71:	c3                   	ret    
  802c72:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802c78:	31 ff                	xor    %edi,%edi
  802c7a:	31 db                	xor    %ebx,%ebx
  802c7c:	89 d8                	mov    %ebx,%eax
  802c7e:	89 fa                	mov    %edi,%edx
  802c80:	83 c4 1c             	add    $0x1c,%esp
  802c83:	5b                   	pop    %ebx
  802c84:	5e                   	pop    %esi
  802c85:	5f                   	pop    %edi
  802c86:	5d                   	pop    %ebp
  802c87:	c3                   	ret    
  802c88:	90                   	nop
  802c89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802c90:	89 d8                	mov    %ebx,%eax
  802c92:	f7 f7                	div    %edi
  802c94:	31 ff                	xor    %edi,%edi
  802c96:	89 c3                	mov    %eax,%ebx
  802c98:	89 d8                	mov    %ebx,%eax
  802c9a:	89 fa                	mov    %edi,%edx
  802c9c:	83 c4 1c             	add    $0x1c,%esp
  802c9f:	5b                   	pop    %ebx
  802ca0:	5e                   	pop    %esi
  802ca1:	5f                   	pop    %edi
  802ca2:	5d                   	pop    %ebp
  802ca3:	c3                   	ret    
  802ca4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802ca8:	39 ce                	cmp    %ecx,%esi
  802caa:	72 0c                	jb     802cb8 <__udivdi3+0x118>
  802cac:	31 db                	xor    %ebx,%ebx
  802cae:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802cb2:	0f 87 34 ff ff ff    	ja     802bec <__udivdi3+0x4c>
  802cb8:	bb 01 00 00 00       	mov    $0x1,%ebx
  802cbd:	e9 2a ff ff ff       	jmp    802bec <__udivdi3+0x4c>
  802cc2:	66 90                	xchg   %ax,%ax
  802cc4:	66 90                	xchg   %ax,%ax
  802cc6:	66 90                	xchg   %ax,%ax
  802cc8:	66 90                	xchg   %ax,%ax
  802cca:	66 90                	xchg   %ax,%ax
  802ccc:	66 90                	xchg   %ax,%ax
  802cce:	66 90                	xchg   %ax,%ax

00802cd0 <__umoddi3>:
  802cd0:	55                   	push   %ebp
  802cd1:	57                   	push   %edi
  802cd2:	56                   	push   %esi
  802cd3:	53                   	push   %ebx
  802cd4:	83 ec 1c             	sub    $0x1c,%esp
  802cd7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  802cdb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  802cdf:	8b 74 24 34          	mov    0x34(%esp),%esi
  802ce3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802ce7:	85 d2                	test   %edx,%edx
  802ce9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802ced:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802cf1:	89 f3                	mov    %esi,%ebx
  802cf3:	89 3c 24             	mov    %edi,(%esp)
  802cf6:	89 74 24 04          	mov    %esi,0x4(%esp)
  802cfa:	75 1c                	jne    802d18 <__umoddi3+0x48>
  802cfc:	39 f7                	cmp    %esi,%edi
  802cfe:	76 50                	jbe    802d50 <__umoddi3+0x80>
  802d00:	89 c8                	mov    %ecx,%eax
  802d02:	89 f2                	mov    %esi,%edx
  802d04:	f7 f7                	div    %edi
  802d06:	89 d0                	mov    %edx,%eax
  802d08:	31 d2                	xor    %edx,%edx
  802d0a:	83 c4 1c             	add    $0x1c,%esp
  802d0d:	5b                   	pop    %ebx
  802d0e:	5e                   	pop    %esi
  802d0f:	5f                   	pop    %edi
  802d10:	5d                   	pop    %ebp
  802d11:	c3                   	ret    
  802d12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802d18:	39 f2                	cmp    %esi,%edx
  802d1a:	89 d0                	mov    %edx,%eax
  802d1c:	77 52                	ja     802d70 <__umoddi3+0xa0>
  802d1e:	0f bd ea             	bsr    %edx,%ebp
  802d21:	83 f5 1f             	xor    $0x1f,%ebp
  802d24:	75 5a                	jne    802d80 <__umoddi3+0xb0>
  802d26:	3b 54 24 04          	cmp    0x4(%esp),%edx
  802d2a:	0f 82 e0 00 00 00    	jb     802e10 <__umoddi3+0x140>
  802d30:	39 0c 24             	cmp    %ecx,(%esp)
  802d33:	0f 86 d7 00 00 00    	jbe    802e10 <__umoddi3+0x140>
  802d39:	8b 44 24 08          	mov    0x8(%esp),%eax
  802d3d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802d41:	83 c4 1c             	add    $0x1c,%esp
  802d44:	5b                   	pop    %ebx
  802d45:	5e                   	pop    %esi
  802d46:	5f                   	pop    %edi
  802d47:	5d                   	pop    %ebp
  802d48:	c3                   	ret    
  802d49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802d50:	85 ff                	test   %edi,%edi
  802d52:	89 fd                	mov    %edi,%ebp
  802d54:	75 0b                	jne    802d61 <__umoddi3+0x91>
  802d56:	b8 01 00 00 00       	mov    $0x1,%eax
  802d5b:	31 d2                	xor    %edx,%edx
  802d5d:	f7 f7                	div    %edi
  802d5f:	89 c5                	mov    %eax,%ebp
  802d61:	89 f0                	mov    %esi,%eax
  802d63:	31 d2                	xor    %edx,%edx
  802d65:	f7 f5                	div    %ebp
  802d67:	89 c8                	mov    %ecx,%eax
  802d69:	f7 f5                	div    %ebp
  802d6b:	89 d0                	mov    %edx,%eax
  802d6d:	eb 99                	jmp    802d08 <__umoddi3+0x38>
  802d6f:	90                   	nop
  802d70:	89 c8                	mov    %ecx,%eax
  802d72:	89 f2                	mov    %esi,%edx
  802d74:	83 c4 1c             	add    $0x1c,%esp
  802d77:	5b                   	pop    %ebx
  802d78:	5e                   	pop    %esi
  802d79:	5f                   	pop    %edi
  802d7a:	5d                   	pop    %ebp
  802d7b:	c3                   	ret    
  802d7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802d80:	8b 34 24             	mov    (%esp),%esi
  802d83:	bf 20 00 00 00       	mov    $0x20,%edi
  802d88:	89 e9                	mov    %ebp,%ecx
  802d8a:	29 ef                	sub    %ebp,%edi
  802d8c:	d3 e0                	shl    %cl,%eax
  802d8e:	89 f9                	mov    %edi,%ecx
  802d90:	89 f2                	mov    %esi,%edx
  802d92:	d3 ea                	shr    %cl,%edx
  802d94:	89 e9                	mov    %ebp,%ecx
  802d96:	09 c2                	or     %eax,%edx
  802d98:	89 d8                	mov    %ebx,%eax
  802d9a:	89 14 24             	mov    %edx,(%esp)
  802d9d:	89 f2                	mov    %esi,%edx
  802d9f:	d3 e2                	shl    %cl,%edx
  802da1:	89 f9                	mov    %edi,%ecx
  802da3:	89 54 24 04          	mov    %edx,0x4(%esp)
  802da7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802dab:	d3 e8                	shr    %cl,%eax
  802dad:	89 e9                	mov    %ebp,%ecx
  802daf:	89 c6                	mov    %eax,%esi
  802db1:	d3 e3                	shl    %cl,%ebx
  802db3:	89 f9                	mov    %edi,%ecx
  802db5:	89 d0                	mov    %edx,%eax
  802db7:	d3 e8                	shr    %cl,%eax
  802db9:	89 e9                	mov    %ebp,%ecx
  802dbb:	09 d8                	or     %ebx,%eax
  802dbd:	89 d3                	mov    %edx,%ebx
  802dbf:	89 f2                	mov    %esi,%edx
  802dc1:	f7 34 24             	divl   (%esp)
  802dc4:	89 d6                	mov    %edx,%esi
  802dc6:	d3 e3                	shl    %cl,%ebx
  802dc8:	f7 64 24 04          	mull   0x4(%esp)
  802dcc:	39 d6                	cmp    %edx,%esi
  802dce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802dd2:	89 d1                	mov    %edx,%ecx
  802dd4:	89 c3                	mov    %eax,%ebx
  802dd6:	72 08                	jb     802de0 <__umoddi3+0x110>
  802dd8:	75 11                	jne    802deb <__umoddi3+0x11b>
  802dda:	39 44 24 08          	cmp    %eax,0x8(%esp)
  802dde:	73 0b                	jae    802deb <__umoddi3+0x11b>
  802de0:	2b 44 24 04          	sub    0x4(%esp),%eax
  802de4:	1b 14 24             	sbb    (%esp),%edx
  802de7:	89 d1                	mov    %edx,%ecx
  802de9:	89 c3                	mov    %eax,%ebx
  802deb:	8b 54 24 08          	mov    0x8(%esp),%edx
  802def:	29 da                	sub    %ebx,%edx
  802df1:	19 ce                	sbb    %ecx,%esi
  802df3:	89 f9                	mov    %edi,%ecx
  802df5:	89 f0                	mov    %esi,%eax
  802df7:	d3 e0                	shl    %cl,%eax
  802df9:	89 e9                	mov    %ebp,%ecx
  802dfb:	d3 ea                	shr    %cl,%edx
  802dfd:	89 e9                	mov    %ebp,%ecx
  802dff:	d3 ee                	shr    %cl,%esi
  802e01:	09 d0                	or     %edx,%eax
  802e03:	89 f2                	mov    %esi,%edx
  802e05:	83 c4 1c             	add    $0x1c,%esp
  802e08:	5b                   	pop    %ebx
  802e09:	5e                   	pop    %esi
  802e0a:	5f                   	pop    %edi
  802e0b:	5d                   	pop    %ebp
  802e0c:	c3                   	ret    
  802e0d:	8d 76 00             	lea    0x0(%esi),%esi
  802e10:	29 f9                	sub    %edi,%ecx
  802e12:	19 d6                	sbb    %edx,%esi
  802e14:	89 74 24 04          	mov    %esi,0x4(%esp)
  802e18:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802e1c:	e9 18 ff ff ff       	jmp    802d39 <__umoddi3+0x69>
