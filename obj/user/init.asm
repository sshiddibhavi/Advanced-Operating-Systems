
obj/user/init.debug:     file format elf32-i386


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
  80002c:	e8 6e 03 00 00       	call   80039f <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <sum>:

char bss[6000];

int
sum(const char *s, int n)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 75 08             	mov    0x8(%ebp),%esi
  80003b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i, tot = 0;
  80003e:	b8 00 00 00 00       	mov    $0x0,%eax
	for (i = 0; i < n; i++)
  800043:	ba 00 00 00 00       	mov    $0x0,%edx
  800048:	eb 0c                	jmp    800056 <sum+0x23>
		tot ^= i * s[i];
  80004a:	0f be 0c 16          	movsbl (%esi,%edx,1),%ecx
  80004e:	0f af ca             	imul   %edx,%ecx
  800051:	31 c8                	xor    %ecx,%eax

int
sum(const char *s, int n)
{
	int i, tot = 0;
	for (i = 0; i < n; i++)
  800053:	83 c2 01             	add    $0x1,%edx
  800056:	39 da                	cmp    %ebx,%edx
  800058:	7c f0                	jl     80004a <sum+0x17>
		tot ^= i * s[i];
	return tot;
}
  80005a:	5b                   	pop    %ebx
  80005b:	5e                   	pop    %esi
  80005c:	5d                   	pop    %ebp
  80005d:	c3                   	ret    

0080005e <umain>:

void
umain(int argc, char **argv)
{
  80005e:	55                   	push   %ebp
  80005f:	89 e5                	mov    %esp,%ebp
  800061:	57                   	push   %edi
  800062:	56                   	push   %esi
  800063:	53                   	push   %ebx
  800064:	81 ec 18 01 00 00    	sub    $0x118,%esp
  80006a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int i, r, x, want;
	char args[256];

	cprintf("init: running\n");
  80006d:	68 40 2a 80 00       	push   $0x802a40
  800072:	e8 61 04 00 00       	call   8004d8 <cprintf>

	want = 0xf989e;
	if ((x = sum((char*)&data, sizeof data)) != want)
  800077:	83 c4 08             	add    $0x8,%esp
  80007a:	68 70 17 00 00       	push   $0x1770
  80007f:	68 00 40 80 00       	push   $0x804000
  800084:	e8 aa ff ff ff       	call   800033 <sum>
  800089:	83 c4 10             	add    $0x10,%esp
  80008c:	3d 9e 98 0f 00       	cmp    $0xf989e,%eax
  800091:	74 18                	je     8000ab <umain+0x4d>
		cprintf("init: data is not initialized: got sum %08x wanted %08x\n",
  800093:	83 ec 04             	sub    $0x4,%esp
  800096:	68 9e 98 0f 00       	push   $0xf989e
  80009b:	50                   	push   %eax
  80009c:	68 08 2b 80 00       	push   $0x802b08
  8000a1:	e8 32 04 00 00       	call   8004d8 <cprintf>
  8000a6:	83 c4 10             	add    $0x10,%esp
  8000a9:	eb 10                	jmp    8000bb <umain+0x5d>
			x, want);
	else
		cprintf("init: data seems okay\n");
  8000ab:	83 ec 0c             	sub    $0xc,%esp
  8000ae:	68 4f 2a 80 00       	push   $0x802a4f
  8000b3:	e8 20 04 00 00       	call   8004d8 <cprintf>
  8000b8:	83 c4 10             	add    $0x10,%esp
	if ((x = sum(bss, sizeof bss)) != 0)
  8000bb:	83 ec 08             	sub    $0x8,%esp
  8000be:	68 70 17 00 00       	push   $0x1770
  8000c3:	68 20 60 80 00       	push   $0x806020
  8000c8:	e8 66 ff ff ff       	call   800033 <sum>
  8000cd:	83 c4 10             	add    $0x10,%esp
  8000d0:	85 c0                	test   %eax,%eax
  8000d2:	74 13                	je     8000e7 <umain+0x89>
		cprintf("bss is not initialized: wanted sum 0 got %08x\n", x);
  8000d4:	83 ec 08             	sub    $0x8,%esp
  8000d7:	50                   	push   %eax
  8000d8:	68 44 2b 80 00       	push   $0x802b44
  8000dd:	e8 f6 03 00 00       	call   8004d8 <cprintf>
  8000e2:	83 c4 10             	add    $0x10,%esp
  8000e5:	eb 10                	jmp    8000f7 <umain+0x99>
	else
		cprintf("init: bss seems okay\n");
  8000e7:	83 ec 0c             	sub    $0xc,%esp
  8000ea:	68 66 2a 80 00       	push   $0x802a66
  8000ef:	e8 e4 03 00 00       	call   8004d8 <cprintf>
  8000f4:	83 c4 10             	add    $0x10,%esp

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
  8000f7:	83 ec 08             	sub    $0x8,%esp
  8000fa:	68 7c 2a 80 00       	push   $0x802a7c
  8000ff:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  800105:	50                   	push   %eax
  800106:	e8 72 09 00 00       	call   800a7d <strcat>
	for (i = 0; i < argc; i++) {
  80010b:	83 c4 10             	add    $0x10,%esp
  80010e:	bb 00 00 00 00       	mov    $0x0,%ebx
		strcat(args, " '");
  800113:	8d b5 e8 fe ff ff    	lea    -0x118(%ebp),%esi
	else
		cprintf("init: bss seems okay\n");

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
	for (i = 0; i < argc; i++) {
  800119:	eb 2e                	jmp    800149 <umain+0xeb>
		strcat(args, " '");
  80011b:	83 ec 08             	sub    $0x8,%esp
  80011e:	68 88 2a 80 00       	push   $0x802a88
  800123:	56                   	push   %esi
  800124:	e8 54 09 00 00       	call   800a7d <strcat>
		strcat(args, argv[i]);
  800129:	83 c4 08             	add    $0x8,%esp
  80012c:	ff 34 9f             	pushl  (%edi,%ebx,4)
  80012f:	56                   	push   %esi
  800130:	e8 48 09 00 00       	call   800a7d <strcat>
		strcat(args, "'");
  800135:	83 c4 08             	add    $0x8,%esp
  800138:	68 89 2a 80 00       	push   $0x802a89
  80013d:	56                   	push   %esi
  80013e:	e8 3a 09 00 00       	call   800a7d <strcat>
	else
		cprintf("init: bss seems okay\n");

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
	for (i = 0; i < argc; i++) {
  800143:	83 c3 01             	add    $0x1,%ebx
  800146:	83 c4 10             	add    $0x10,%esp
  800149:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  80014c:	7c cd                	jl     80011b <umain+0xbd>
		strcat(args, " '");
		strcat(args, argv[i]);
		strcat(args, "'");
	}
	cprintf("%s\n", args);
  80014e:	83 ec 08             	sub    $0x8,%esp
  800151:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  800157:	50                   	push   %eax
  800158:	68 8b 2a 80 00       	push   $0x802a8b
  80015d:	e8 76 03 00 00       	call   8004d8 <cprintf>

	cprintf("init: running sh\n");
  800162:	c7 04 24 8f 2a 80 00 	movl   $0x802a8f,(%esp)
  800169:	e8 6a 03 00 00       	call   8004d8 <cprintf>

	// being run directly from kernel, so no file descriptors open yet
	close(0);
  80016e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800175:	e8 96 10 00 00       	call   801210 <close>
	if ((r = opencons()) < 0)
  80017a:	e8 c6 01 00 00       	call   800345 <opencons>
  80017f:	83 c4 10             	add    $0x10,%esp
  800182:	85 c0                	test   %eax,%eax
  800184:	79 12                	jns    800198 <umain+0x13a>
		panic("opencons: %e", r);
  800186:	50                   	push   %eax
  800187:	68 a1 2a 80 00       	push   $0x802aa1
  80018c:	6a 37                	push   $0x37
  80018e:	68 ae 2a 80 00       	push   $0x802aae
  800193:	e8 67 02 00 00       	call   8003ff <_panic>
	if (r != 0)
  800198:	85 c0                	test   %eax,%eax
  80019a:	74 12                	je     8001ae <umain+0x150>
		panic("first opencons used fd %d", r);
  80019c:	50                   	push   %eax
  80019d:	68 ba 2a 80 00       	push   $0x802aba
  8001a2:	6a 39                	push   $0x39
  8001a4:	68 ae 2a 80 00       	push   $0x802aae
  8001a9:	e8 51 02 00 00       	call   8003ff <_panic>
	if ((r = dup(0, 1)) < 0)
  8001ae:	83 ec 08             	sub    $0x8,%esp
  8001b1:	6a 01                	push   $0x1
  8001b3:	6a 00                	push   $0x0
  8001b5:	e8 a6 10 00 00       	call   801260 <dup>
  8001ba:	83 c4 10             	add    $0x10,%esp
  8001bd:	85 c0                	test   %eax,%eax
  8001bf:	79 12                	jns    8001d3 <umain+0x175>
		panic("dup: %e", r);
  8001c1:	50                   	push   %eax
  8001c2:	68 d4 2a 80 00       	push   $0x802ad4
  8001c7:	6a 3b                	push   $0x3b
  8001c9:	68 ae 2a 80 00       	push   $0x802aae
  8001ce:	e8 2c 02 00 00       	call   8003ff <_panic>
	while (1) {
		cprintf("init: starting sh\n");
  8001d3:	83 ec 0c             	sub    $0xc,%esp
  8001d6:	68 dc 2a 80 00       	push   $0x802adc
  8001db:	e8 f8 02 00 00       	call   8004d8 <cprintf>
		r = spawnl("/sh", "sh", (char*)0);
  8001e0:	83 c4 0c             	add    $0xc,%esp
  8001e3:	6a 00                	push   $0x0
  8001e5:	68 f0 2a 80 00       	push   $0x802af0
  8001ea:	68 ef 2a 80 00       	push   $0x802aef
  8001ef:	e8 f1 1b 00 00       	call   801de5 <spawnl>
		if (r < 0) {
  8001f4:	83 c4 10             	add    $0x10,%esp
  8001f7:	85 c0                	test   %eax,%eax
  8001f9:	79 13                	jns    80020e <umain+0x1b0>
			cprintf("init: spawn sh: %e\n", r);
  8001fb:	83 ec 08             	sub    $0x8,%esp
  8001fe:	50                   	push   %eax
  8001ff:	68 f3 2a 80 00       	push   $0x802af3
  800204:	e8 cf 02 00 00       	call   8004d8 <cprintf>
			continue;
  800209:	83 c4 10             	add    $0x10,%esp
  80020c:	eb c5                	jmp    8001d3 <umain+0x175>
		}
		wait(r);
  80020e:	83 ec 0c             	sub    $0xc,%esp
  800211:	50                   	push   %eax
  800212:	e8 04 24 00 00       	call   80261b <wait>
  800217:	83 c4 10             	add    $0x10,%esp
  80021a:	eb b7                	jmp    8001d3 <umain+0x175>

0080021c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80021f:	b8 00 00 00 00       	mov    $0x0,%eax
  800224:	5d                   	pop    %ebp
  800225:	c3                   	ret    

00800226 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800226:	55                   	push   %ebp
  800227:	89 e5                	mov    %esp,%ebp
  800229:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80022c:	68 73 2b 80 00       	push   $0x802b73
  800231:	ff 75 0c             	pushl  0xc(%ebp)
  800234:	e8 24 08 00 00       	call   800a5d <strcpy>
	return 0;
}
  800239:	b8 00 00 00 00       	mov    $0x0,%eax
  80023e:	c9                   	leave  
  80023f:	c3                   	ret    

00800240 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800240:	55                   	push   %ebp
  800241:	89 e5                	mov    %esp,%ebp
  800243:	57                   	push   %edi
  800244:	56                   	push   %esi
  800245:	53                   	push   %ebx
  800246:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80024c:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800251:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800257:	eb 2d                	jmp    800286 <devcons_write+0x46>
		m = n - tot;
  800259:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80025c:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80025e:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800261:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800266:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800269:	83 ec 04             	sub    $0x4,%esp
  80026c:	53                   	push   %ebx
  80026d:	03 45 0c             	add    0xc(%ebp),%eax
  800270:	50                   	push   %eax
  800271:	57                   	push   %edi
  800272:	e8 78 09 00 00       	call   800bef <memmove>
		sys_cputs(buf, m);
  800277:	83 c4 08             	add    $0x8,%esp
  80027a:	53                   	push   %ebx
  80027b:	57                   	push   %edi
  80027c:	e8 23 0b 00 00       	call   800da4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800281:	01 de                	add    %ebx,%esi
  800283:	83 c4 10             	add    $0x10,%esp
  800286:	89 f0                	mov    %esi,%eax
  800288:	3b 75 10             	cmp    0x10(%ebp),%esi
  80028b:	72 cc                	jb     800259 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80028d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800290:	5b                   	pop    %ebx
  800291:	5e                   	pop    %esi
  800292:	5f                   	pop    %edi
  800293:	5d                   	pop    %ebp
  800294:	c3                   	ret    

00800295 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800295:	55                   	push   %ebp
  800296:	89 e5                	mov    %esp,%ebp
  800298:	83 ec 08             	sub    $0x8,%esp
  80029b:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8002a0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8002a4:	74 2a                	je     8002d0 <devcons_read+0x3b>
  8002a6:	eb 05                	jmp    8002ad <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8002a8:	e8 94 0b 00 00       	call   800e41 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8002ad:	e8 10 0b 00 00       	call   800dc2 <sys_cgetc>
  8002b2:	85 c0                	test   %eax,%eax
  8002b4:	74 f2                	je     8002a8 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8002b6:	85 c0                	test   %eax,%eax
  8002b8:	78 16                	js     8002d0 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8002ba:	83 f8 04             	cmp    $0x4,%eax
  8002bd:	74 0c                	je     8002cb <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8002bf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002c2:	88 02                	mov    %al,(%edx)
	return 1;
  8002c4:	b8 01 00 00 00       	mov    $0x1,%eax
  8002c9:	eb 05                	jmp    8002d0 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8002cb:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8002d0:	c9                   	leave  
  8002d1:	c3                   	ret    

008002d2 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8002d2:	55                   	push   %ebp
  8002d3:	89 e5                	mov    %esp,%ebp
  8002d5:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8002d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8002db:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8002de:	6a 01                	push   $0x1
  8002e0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8002e3:	50                   	push   %eax
  8002e4:	e8 bb 0a 00 00       	call   800da4 <sys_cputs>
}
  8002e9:	83 c4 10             	add    $0x10,%esp
  8002ec:	c9                   	leave  
  8002ed:	c3                   	ret    

008002ee <getchar>:

int
getchar(void)
{
  8002ee:	55                   	push   %ebp
  8002ef:	89 e5                	mov    %esp,%ebp
  8002f1:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8002f4:	6a 01                	push   $0x1
  8002f6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8002f9:	50                   	push   %eax
  8002fa:	6a 00                	push   $0x0
  8002fc:	e8 4b 10 00 00       	call   80134c <read>
	if (r < 0)
  800301:	83 c4 10             	add    $0x10,%esp
  800304:	85 c0                	test   %eax,%eax
  800306:	78 0f                	js     800317 <getchar+0x29>
		return r;
	if (r < 1)
  800308:	85 c0                	test   %eax,%eax
  80030a:	7e 06                	jle    800312 <getchar+0x24>
		return -E_EOF;
	return c;
  80030c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800310:	eb 05                	jmp    800317 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800312:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800317:	c9                   	leave  
  800318:	c3                   	ret    

00800319 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800319:	55                   	push   %ebp
  80031a:	89 e5                	mov    %esp,%ebp
  80031c:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80031f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800322:	50                   	push   %eax
  800323:	ff 75 08             	pushl  0x8(%ebp)
  800326:	e8 bb 0d 00 00       	call   8010e6 <fd_lookup>
  80032b:	83 c4 10             	add    $0x10,%esp
  80032e:	85 c0                	test   %eax,%eax
  800330:	78 11                	js     800343 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800332:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800335:	8b 15 70 57 80 00    	mov    0x805770,%edx
  80033b:	39 10                	cmp    %edx,(%eax)
  80033d:	0f 94 c0             	sete   %al
  800340:	0f b6 c0             	movzbl %al,%eax
}
  800343:	c9                   	leave  
  800344:	c3                   	ret    

00800345 <opencons>:

int
opencons(void)
{
  800345:	55                   	push   %ebp
  800346:	89 e5                	mov    %esp,%ebp
  800348:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80034b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80034e:	50                   	push   %eax
  80034f:	e8 43 0d 00 00       	call   801097 <fd_alloc>
  800354:	83 c4 10             	add    $0x10,%esp
		return r;
  800357:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800359:	85 c0                	test   %eax,%eax
  80035b:	78 3e                	js     80039b <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80035d:	83 ec 04             	sub    $0x4,%esp
  800360:	68 07 04 00 00       	push   $0x407
  800365:	ff 75 f4             	pushl  -0xc(%ebp)
  800368:	6a 00                	push   $0x0
  80036a:	e8 f1 0a 00 00       	call   800e60 <sys_page_alloc>
  80036f:	83 c4 10             	add    $0x10,%esp
		return r;
  800372:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800374:	85 c0                	test   %eax,%eax
  800376:	78 23                	js     80039b <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800378:	8b 15 70 57 80 00    	mov    0x805770,%edx
  80037e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800381:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800383:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800386:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80038d:	83 ec 0c             	sub    $0xc,%esp
  800390:	50                   	push   %eax
  800391:	e8 da 0c 00 00       	call   801070 <fd2num>
  800396:	89 c2                	mov    %eax,%edx
  800398:	83 c4 10             	add    $0x10,%esp
}
  80039b:	89 d0                	mov    %edx,%eax
  80039d:	c9                   	leave  
  80039e:	c3                   	ret    

0080039f <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80039f:	55                   	push   %ebp
  8003a0:	89 e5                	mov    %esp,%ebp
  8003a2:	56                   	push   %esi
  8003a3:	53                   	push   %ebx
  8003a4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8003a7:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8003aa:	e8 73 0a 00 00       	call   800e22 <sys_getenvid>
  8003af:	25 ff 03 00 00       	and    $0x3ff,%eax
  8003b4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8003b7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8003bc:	a3 90 77 80 00       	mov    %eax,0x807790

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8003c1:	85 db                	test   %ebx,%ebx
  8003c3:	7e 07                	jle    8003cc <libmain+0x2d>
		binaryname = argv[0];
  8003c5:	8b 06                	mov    (%esi),%eax
  8003c7:	a3 8c 57 80 00       	mov    %eax,0x80578c

	// call user main routine
	umain(argc, argv);
  8003cc:	83 ec 08             	sub    $0x8,%esp
  8003cf:	56                   	push   %esi
  8003d0:	53                   	push   %ebx
  8003d1:	e8 88 fc ff ff       	call   80005e <umain>

	// exit gracefully
	exit();
  8003d6:	e8 0a 00 00 00       	call   8003e5 <exit>
}
  8003db:	83 c4 10             	add    $0x10,%esp
  8003de:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8003e1:	5b                   	pop    %ebx
  8003e2:	5e                   	pop    %esi
  8003e3:	5d                   	pop    %ebp
  8003e4:	c3                   	ret    

008003e5 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8003e5:	55                   	push   %ebp
  8003e6:	89 e5                	mov    %esp,%ebp
  8003e8:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8003eb:	e8 4b 0e 00 00       	call   80123b <close_all>
	sys_env_destroy(0);
  8003f0:	83 ec 0c             	sub    $0xc,%esp
  8003f3:	6a 00                	push   $0x0
  8003f5:	e8 e7 09 00 00       	call   800de1 <sys_env_destroy>
}
  8003fa:	83 c4 10             	add    $0x10,%esp
  8003fd:	c9                   	leave  
  8003fe:	c3                   	ret    

008003ff <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8003ff:	55                   	push   %ebp
  800400:	89 e5                	mov    %esp,%ebp
  800402:	56                   	push   %esi
  800403:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800404:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800407:	8b 35 8c 57 80 00    	mov    0x80578c,%esi
  80040d:	e8 10 0a 00 00       	call   800e22 <sys_getenvid>
  800412:	83 ec 0c             	sub    $0xc,%esp
  800415:	ff 75 0c             	pushl  0xc(%ebp)
  800418:	ff 75 08             	pushl  0x8(%ebp)
  80041b:	56                   	push   %esi
  80041c:	50                   	push   %eax
  80041d:	68 8c 2b 80 00       	push   $0x802b8c
  800422:	e8 b1 00 00 00       	call   8004d8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800427:	83 c4 18             	add    $0x18,%esp
  80042a:	53                   	push   %ebx
  80042b:	ff 75 10             	pushl  0x10(%ebp)
  80042e:	e8 54 00 00 00       	call   800487 <vcprintf>
	cprintf("\n");
  800433:	c7 04 24 a9 30 80 00 	movl   $0x8030a9,(%esp)
  80043a:	e8 99 00 00 00       	call   8004d8 <cprintf>
  80043f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800442:	cc                   	int3   
  800443:	eb fd                	jmp    800442 <_panic+0x43>

00800445 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800445:	55                   	push   %ebp
  800446:	89 e5                	mov    %esp,%ebp
  800448:	53                   	push   %ebx
  800449:	83 ec 04             	sub    $0x4,%esp
  80044c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80044f:	8b 13                	mov    (%ebx),%edx
  800451:	8d 42 01             	lea    0x1(%edx),%eax
  800454:	89 03                	mov    %eax,(%ebx)
  800456:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800459:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80045d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800462:	75 1a                	jne    80047e <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800464:	83 ec 08             	sub    $0x8,%esp
  800467:	68 ff 00 00 00       	push   $0xff
  80046c:	8d 43 08             	lea    0x8(%ebx),%eax
  80046f:	50                   	push   %eax
  800470:	e8 2f 09 00 00       	call   800da4 <sys_cputs>
		b->idx = 0;
  800475:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80047b:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80047e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800482:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800485:	c9                   	leave  
  800486:	c3                   	ret    

00800487 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800487:	55                   	push   %ebp
  800488:	89 e5                	mov    %esp,%ebp
  80048a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800490:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800497:	00 00 00 
	b.cnt = 0;
  80049a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8004a1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8004a4:	ff 75 0c             	pushl  0xc(%ebp)
  8004a7:	ff 75 08             	pushl  0x8(%ebp)
  8004aa:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8004b0:	50                   	push   %eax
  8004b1:	68 45 04 80 00       	push   $0x800445
  8004b6:	e8 54 01 00 00       	call   80060f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8004bb:	83 c4 08             	add    $0x8,%esp
  8004be:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8004c4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8004ca:	50                   	push   %eax
  8004cb:	e8 d4 08 00 00       	call   800da4 <sys_cputs>

	return b.cnt;
}
  8004d0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8004d6:	c9                   	leave  
  8004d7:	c3                   	ret    

008004d8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8004d8:	55                   	push   %ebp
  8004d9:	89 e5                	mov    %esp,%ebp
  8004db:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8004de:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8004e1:	50                   	push   %eax
  8004e2:	ff 75 08             	pushl  0x8(%ebp)
  8004e5:	e8 9d ff ff ff       	call   800487 <vcprintf>
	va_end(ap);

	return cnt;
}
  8004ea:	c9                   	leave  
  8004eb:	c3                   	ret    

008004ec <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8004ec:	55                   	push   %ebp
  8004ed:	89 e5                	mov    %esp,%ebp
  8004ef:	57                   	push   %edi
  8004f0:	56                   	push   %esi
  8004f1:	53                   	push   %ebx
  8004f2:	83 ec 1c             	sub    $0x1c,%esp
  8004f5:	89 c7                	mov    %eax,%edi
  8004f7:	89 d6                	mov    %edx,%esi
  8004f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8004fc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004ff:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800502:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800505:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800508:	bb 00 00 00 00       	mov    $0x0,%ebx
  80050d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800510:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800513:	39 d3                	cmp    %edx,%ebx
  800515:	72 05                	jb     80051c <printnum+0x30>
  800517:	39 45 10             	cmp    %eax,0x10(%ebp)
  80051a:	77 45                	ja     800561 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80051c:	83 ec 0c             	sub    $0xc,%esp
  80051f:	ff 75 18             	pushl  0x18(%ebp)
  800522:	8b 45 14             	mov    0x14(%ebp),%eax
  800525:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800528:	53                   	push   %ebx
  800529:	ff 75 10             	pushl  0x10(%ebp)
  80052c:	83 ec 08             	sub    $0x8,%esp
  80052f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800532:	ff 75 e0             	pushl  -0x20(%ebp)
  800535:	ff 75 dc             	pushl  -0x24(%ebp)
  800538:	ff 75 d8             	pushl  -0x28(%ebp)
  80053b:	e8 60 22 00 00       	call   8027a0 <__udivdi3>
  800540:	83 c4 18             	add    $0x18,%esp
  800543:	52                   	push   %edx
  800544:	50                   	push   %eax
  800545:	89 f2                	mov    %esi,%edx
  800547:	89 f8                	mov    %edi,%eax
  800549:	e8 9e ff ff ff       	call   8004ec <printnum>
  80054e:	83 c4 20             	add    $0x20,%esp
  800551:	eb 18                	jmp    80056b <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800553:	83 ec 08             	sub    $0x8,%esp
  800556:	56                   	push   %esi
  800557:	ff 75 18             	pushl  0x18(%ebp)
  80055a:	ff d7                	call   *%edi
  80055c:	83 c4 10             	add    $0x10,%esp
  80055f:	eb 03                	jmp    800564 <printnum+0x78>
  800561:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800564:	83 eb 01             	sub    $0x1,%ebx
  800567:	85 db                	test   %ebx,%ebx
  800569:	7f e8                	jg     800553 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80056b:	83 ec 08             	sub    $0x8,%esp
  80056e:	56                   	push   %esi
  80056f:	83 ec 04             	sub    $0x4,%esp
  800572:	ff 75 e4             	pushl  -0x1c(%ebp)
  800575:	ff 75 e0             	pushl  -0x20(%ebp)
  800578:	ff 75 dc             	pushl  -0x24(%ebp)
  80057b:	ff 75 d8             	pushl  -0x28(%ebp)
  80057e:	e8 4d 23 00 00       	call   8028d0 <__umoddi3>
  800583:	83 c4 14             	add    $0x14,%esp
  800586:	0f be 80 af 2b 80 00 	movsbl 0x802baf(%eax),%eax
  80058d:	50                   	push   %eax
  80058e:	ff d7                	call   *%edi
}
  800590:	83 c4 10             	add    $0x10,%esp
  800593:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800596:	5b                   	pop    %ebx
  800597:	5e                   	pop    %esi
  800598:	5f                   	pop    %edi
  800599:	5d                   	pop    %ebp
  80059a:	c3                   	ret    

0080059b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80059b:	55                   	push   %ebp
  80059c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80059e:	83 fa 01             	cmp    $0x1,%edx
  8005a1:	7e 0e                	jle    8005b1 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8005a3:	8b 10                	mov    (%eax),%edx
  8005a5:	8d 4a 08             	lea    0x8(%edx),%ecx
  8005a8:	89 08                	mov    %ecx,(%eax)
  8005aa:	8b 02                	mov    (%edx),%eax
  8005ac:	8b 52 04             	mov    0x4(%edx),%edx
  8005af:	eb 22                	jmp    8005d3 <getuint+0x38>
	else if (lflag)
  8005b1:	85 d2                	test   %edx,%edx
  8005b3:	74 10                	je     8005c5 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8005b5:	8b 10                	mov    (%eax),%edx
  8005b7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005ba:	89 08                	mov    %ecx,(%eax)
  8005bc:	8b 02                	mov    (%edx),%eax
  8005be:	ba 00 00 00 00       	mov    $0x0,%edx
  8005c3:	eb 0e                	jmp    8005d3 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8005c5:	8b 10                	mov    (%eax),%edx
  8005c7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005ca:	89 08                	mov    %ecx,(%eax)
  8005cc:	8b 02                	mov    (%edx),%eax
  8005ce:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8005d3:	5d                   	pop    %ebp
  8005d4:	c3                   	ret    

008005d5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005d5:	55                   	push   %ebp
  8005d6:	89 e5                	mov    %esp,%ebp
  8005d8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005db:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8005df:	8b 10                	mov    (%eax),%edx
  8005e1:	3b 50 04             	cmp    0x4(%eax),%edx
  8005e4:	73 0a                	jae    8005f0 <sprintputch+0x1b>
		*b->buf++ = ch;
  8005e6:	8d 4a 01             	lea    0x1(%edx),%ecx
  8005e9:	89 08                	mov    %ecx,(%eax)
  8005eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ee:	88 02                	mov    %al,(%edx)
}
  8005f0:	5d                   	pop    %ebp
  8005f1:	c3                   	ret    

008005f2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8005f2:	55                   	push   %ebp
  8005f3:	89 e5                	mov    %esp,%ebp
  8005f5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8005f8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005fb:	50                   	push   %eax
  8005fc:	ff 75 10             	pushl  0x10(%ebp)
  8005ff:	ff 75 0c             	pushl  0xc(%ebp)
  800602:	ff 75 08             	pushl  0x8(%ebp)
  800605:	e8 05 00 00 00       	call   80060f <vprintfmt>
	va_end(ap);
}
  80060a:	83 c4 10             	add    $0x10,%esp
  80060d:	c9                   	leave  
  80060e:	c3                   	ret    

0080060f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80060f:	55                   	push   %ebp
  800610:	89 e5                	mov    %esp,%ebp
  800612:	57                   	push   %edi
  800613:	56                   	push   %esi
  800614:	53                   	push   %ebx
  800615:	83 ec 2c             	sub    $0x2c,%esp
  800618:	8b 75 08             	mov    0x8(%ebp),%esi
  80061b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80061e:	8b 7d 10             	mov    0x10(%ebp),%edi
  800621:	eb 12                	jmp    800635 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800623:	85 c0                	test   %eax,%eax
  800625:	0f 84 89 03 00 00    	je     8009b4 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80062b:	83 ec 08             	sub    $0x8,%esp
  80062e:	53                   	push   %ebx
  80062f:	50                   	push   %eax
  800630:	ff d6                	call   *%esi
  800632:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800635:	83 c7 01             	add    $0x1,%edi
  800638:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80063c:	83 f8 25             	cmp    $0x25,%eax
  80063f:	75 e2                	jne    800623 <vprintfmt+0x14>
  800641:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800645:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80064c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800653:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80065a:	ba 00 00 00 00       	mov    $0x0,%edx
  80065f:	eb 07                	jmp    800668 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800661:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800664:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800668:	8d 47 01             	lea    0x1(%edi),%eax
  80066b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80066e:	0f b6 07             	movzbl (%edi),%eax
  800671:	0f b6 c8             	movzbl %al,%ecx
  800674:	83 e8 23             	sub    $0x23,%eax
  800677:	3c 55                	cmp    $0x55,%al
  800679:	0f 87 1a 03 00 00    	ja     800999 <vprintfmt+0x38a>
  80067f:	0f b6 c0             	movzbl %al,%eax
  800682:	ff 24 85 00 2d 80 00 	jmp    *0x802d00(,%eax,4)
  800689:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80068c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800690:	eb d6                	jmp    800668 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800692:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800695:	b8 00 00 00 00       	mov    $0x0,%eax
  80069a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80069d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8006a0:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8006a4:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8006a7:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8006aa:	83 fa 09             	cmp    $0x9,%edx
  8006ad:	77 39                	ja     8006e8 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8006af:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8006b2:	eb e9                	jmp    80069d <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8006b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b7:	8d 48 04             	lea    0x4(%eax),%ecx
  8006ba:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006bd:	8b 00                	mov    (%eax),%eax
  8006bf:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8006c5:	eb 27                	jmp    8006ee <vprintfmt+0xdf>
  8006c7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006ca:	85 c0                	test   %eax,%eax
  8006cc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006d1:	0f 49 c8             	cmovns %eax,%ecx
  8006d4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006da:	eb 8c                	jmp    800668 <vprintfmt+0x59>
  8006dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8006df:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8006e6:	eb 80                	jmp    800668 <vprintfmt+0x59>
  8006e8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006eb:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8006ee:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006f2:	0f 89 70 ff ff ff    	jns    800668 <vprintfmt+0x59>
				width = precision, precision = -1;
  8006f8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8006fb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006fe:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800705:	e9 5e ff ff ff       	jmp    800668 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80070a:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80070d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800710:	e9 53 ff ff ff       	jmp    800668 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800715:	8b 45 14             	mov    0x14(%ebp),%eax
  800718:	8d 50 04             	lea    0x4(%eax),%edx
  80071b:	89 55 14             	mov    %edx,0x14(%ebp)
  80071e:	83 ec 08             	sub    $0x8,%esp
  800721:	53                   	push   %ebx
  800722:	ff 30                	pushl  (%eax)
  800724:	ff d6                	call   *%esi
			break;
  800726:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800729:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80072c:	e9 04 ff ff ff       	jmp    800635 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800731:	8b 45 14             	mov    0x14(%ebp),%eax
  800734:	8d 50 04             	lea    0x4(%eax),%edx
  800737:	89 55 14             	mov    %edx,0x14(%ebp)
  80073a:	8b 00                	mov    (%eax),%eax
  80073c:	99                   	cltd   
  80073d:	31 d0                	xor    %edx,%eax
  80073f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800741:	83 f8 0f             	cmp    $0xf,%eax
  800744:	7f 0b                	jg     800751 <vprintfmt+0x142>
  800746:	8b 14 85 60 2e 80 00 	mov    0x802e60(,%eax,4),%edx
  80074d:	85 d2                	test   %edx,%edx
  80074f:	75 18                	jne    800769 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800751:	50                   	push   %eax
  800752:	68 c7 2b 80 00       	push   $0x802bc7
  800757:	53                   	push   %ebx
  800758:	56                   	push   %esi
  800759:	e8 94 fe ff ff       	call   8005f2 <printfmt>
  80075e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800761:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800764:	e9 cc fe ff ff       	jmp    800635 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800769:	52                   	push   %edx
  80076a:	68 9a 2f 80 00       	push   $0x802f9a
  80076f:	53                   	push   %ebx
  800770:	56                   	push   %esi
  800771:	e8 7c fe ff ff       	call   8005f2 <printfmt>
  800776:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800779:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80077c:	e9 b4 fe ff ff       	jmp    800635 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800781:	8b 45 14             	mov    0x14(%ebp),%eax
  800784:	8d 50 04             	lea    0x4(%eax),%edx
  800787:	89 55 14             	mov    %edx,0x14(%ebp)
  80078a:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80078c:	85 ff                	test   %edi,%edi
  80078e:	b8 c0 2b 80 00       	mov    $0x802bc0,%eax
  800793:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800796:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80079a:	0f 8e 94 00 00 00    	jle    800834 <vprintfmt+0x225>
  8007a0:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8007a4:	0f 84 98 00 00 00    	je     800842 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8007aa:	83 ec 08             	sub    $0x8,%esp
  8007ad:	ff 75 d0             	pushl  -0x30(%ebp)
  8007b0:	57                   	push   %edi
  8007b1:	e8 86 02 00 00       	call   800a3c <strnlen>
  8007b6:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8007b9:	29 c1                	sub    %eax,%ecx
  8007bb:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8007be:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8007c1:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8007c5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007c8:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8007cb:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007cd:	eb 0f                	jmp    8007de <vprintfmt+0x1cf>
					putch(padc, putdat);
  8007cf:	83 ec 08             	sub    $0x8,%esp
  8007d2:	53                   	push   %ebx
  8007d3:	ff 75 e0             	pushl  -0x20(%ebp)
  8007d6:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007d8:	83 ef 01             	sub    $0x1,%edi
  8007db:	83 c4 10             	add    $0x10,%esp
  8007de:	85 ff                	test   %edi,%edi
  8007e0:	7f ed                	jg     8007cf <vprintfmt+0x1c0>
  8007e2:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8007e5:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8007e8:	85 c9                	test   %ecx,%ecx
  8007ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ef:	0f 49 c1             	cmovns %ecx,%eax
  8007f2:	29 c1                	sub    %eax,%ecx
  8007f4:	89 75 08             	mov    %esi,0x8(%ebp)
  8007f7:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8007fa:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8007fd:	89 cb                	mov    %ecx,%ebx
  8007ff:	eb 4d                	jmp    80084e <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800801:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800805:	74 1b                	je     800822 <vprintfmt+0x213>
  800807:	0f be c0             	movsbl %al,%eax
  80080a:	83 e8 20             	sub    $0x20,%eax
  80080d:	83 f8 5e             	cmp    $0x5e,%eax
  800810:	76 10                	jbe    800822 <vprintfmt+0x213>
					putch('?', putdat);
  800812:	83 ec 08             	sub    $0x8,%esp
  800815:	ff 75 0c             	pushl  0xc(%ebp)
  800818:	6a 3f                	push   $0x3f
  80081a:	ff 55 08             	call   *0x8(%ebp)
  80081d:	83 c4 10             	add    $0x10,%esp
  800820:	eb 0d                	jmp    80082f <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800822:	83 ec 08             	sub    $0x8,%esp
  800825:	ff 75 0c             	pushl  0xc(%ebp)
  800828:	52                   	push   %edx
  800829:	ff 55 08             	call   *0x8(%ebp)
  80082c:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80082f:	83 eb 01             	sub    $0x1,%ebx
  800832:	eb 1a                	jmp    80084e <vprintfmt+0x23f>
  800834:	89 75 08             	mov    %esi,0x8(%ebp)
  800837:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80083a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80083d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800840:	eb 0c                	jmp    80084e <vprintfmt+0x23f>
  800842:	89 75 08             	mov    %esi,0x8(%ebp)
  800845:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800848:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80084b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80084e:	83 c7 01             	add    $0x1,%edi
  800851:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800855:	0f be d0             	movsbl %al,%edx
  800858:	85 d2                	test   %edx,%edx
  80085a:	74 23                	je     80087f <vprintfmt+0x270>
  80085c:	85 f6                	test   %esi,%esi
  80085e:	78 a1                	js     800801 <vprintfmt+0x1f2>
  800860:	83 ee 01             	sub    $0x1,%esi
  800863:	79 9c                	jns    800801 <vprintfmt+0x1f2>
  800865:	89 df                	mov    %ebx,%edi
  800867:	8b 75 08             	mov    0x8(%ebp),%esi
  80086a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80086d:	eb 18                	jmp    800887 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80086f:	83 ec 08             	sub    $0x8,%esp
  800872:	53                   	push   %ebx
  800873:	6a 20                	push   $0x20
  800875:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800877:	83 ef 01             	sub    $0x1,%edi
  80087a:	83 c4 10             	add    $0x10,%esp
  80087d:	eb 08                	jmp    800887 <vprintfmt+0x278>
  80087f:	89 df                	mov    %ebx,%edi
  800881:	8b 75 08             	mov    0x8(%ebp),%esi
  800884:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800887:	85 ff                	test   %edi,%edi
  800889:	7f e4                	jg     80086f <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80088b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80088e:	e9 a2 fd ff ff       	jmp    800635 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800893:	83 fa 01             	cmp    $0x1,%edx
  800896:	7e 16                	jle    8008ae <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800898:	8b 45 14             	mov    0x14(%ebp),%eax
  80089b:	8d 50 08             	lea    0x8(%eax),%edx
  80089e:	89 55 14             	mov    %edx,0x14(%ebp)
  8008a1:	8b 50 04             	mov    0x4(%eax),%edx
  8008a4:	8b 00                	mov    (%eax),%eax
  8008a6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008a9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8008ac:	eb 32                	jmp    8008e0 <vprintfmt+0x2d1>
	else if (lflag)
  8008ae:	85 d2                	test   %edx,%edx
  8008b0:	74 18                	je     8008ca <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8008b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b5:	8d 50 04             	lea    0x4(%eax),%edx
  8008b8:	89 55 14             	mov    %edx,0x14(%ebp)
  8008bb:	8b 00                	mov    (%eax),%eax
  8008bd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008c0:	89 c1                	mov    %eax,%ecx
  8008c2:	c1 f9 1f             	sar    $0x1f,%ecx
  8008c5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8008c8:	eb 16                	jmp    8008e0 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8008ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8008cd:	8d 50 04             	lea    0x4(%eax),%edx
  8008d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8008d3:	8b 00                	mov    (%eax),%eax
  8008d5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008d8:	89 c1                	mov    %eax,%ecx
  8008da:	c1 f9 1f             	sar    $0x1f,%ecx
  8008dd:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8008e0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8008e3:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8008e6:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8008eb:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8008ef:	79 74                	jns    800965 <vprintfmt+0x356>
				putch('-', putdat);
  8008f1:	83 ec 08             	sub    $0x8,%esp
  8008f4:	53                   	push   %ebx
  8008f5:	6a 2d                	push   $0x2d
  8008f7:	ff d6                	call   *%esi
				num = -(long long) num;
  8008f9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8008fc:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8008ff:	f7 d8                	neg    %eax
  800901:	83 d2 00             	adc    $0x0,%edx
  800904:	f7 da                	neg    %edx
  800906:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800909:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80090e:	eb 55                	jmp    800965 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800910:	8d 45 14             	lea    0x14(%ebp),%eax
  800913:	e8 83 fc ff ff       	call   80059b <getuint>
			base = 10;
  800918:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80091d:	eb 46                	jmp    800965 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80091f:	8d 45 14             	lea    0x14(%ebp),%eax
  800922:	e8 74 fc ff ff       	call   80059b <getuint>
                        base = 8;
  800927:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  80092c:	eb 37                	jmp    800965 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80092e:	83 ec 08             	sub    $0x8,%esp
  800931:	53                   	push   %ebx
  800932:	6a 30                	push   $0x30
  800934:	ff d6                	call   *%esi
			putch('x', putdat);
  800936:	83 c4 08             	add    $0x8,%esp
  800939:	53                   	push   %ebx
  80093a:	6a 78                	push   $0x78
  80093c:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80093e:	8b 45 14             	mov    0x14(%ebp),%eax
  800941:	8d 50 04             	lea    0x4(%eax),%edx
  800944:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800947:	8b 00                	mov    (%eax),%eax
  800949:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80094e:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800951:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800956:	eb 0d                	jmp    800965 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800958:	8d 45 14             	lea    0x14(%ebp),%eax
  80095b:	e8 3b fc ff ff       	call   80059b <getuint>
			base = 16;
  800960:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800965:	83 ec 0c             	sub    $0xc,%esp
  800968:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80096c:	57                   	push   %edi
  80096d:	ff 75 e0             	pushl  -0x20(%ebp)
  800970:	51                   	push   %ecx
  800971:	52                   	push   %edx
  800972:	50                   	push   %eax
  800973:	89 da                	mov    %ebx,%edx
  800975:	89 f0                	mov    %esi,%eax
  800977:	e8 70 fb ff ff       	call   8004ec <printnum>
			break;
  80097c:	83 c4 20             	add    $0x20,%esp
  80097f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800982:	e9 ae fc ff ff       	jmp    800635 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800987:	83 ec 08             	sub    $0x8,%esp
  80098a:	53                   	push   %ebx
  80098b:	51                   	push   %ecx
  80098c:	ff d6                	call   *%esi
			break;
  80098e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800991:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800994:	e9 9c fc ff ff       	jmp    800635 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800999:	83 ec 08             	sub    $0x8,%esp
  80099c:	53                   	push   %ebx
  80099d:	6a 25                	push   $0x25
  80099f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009a1:	83 c4 10             	add    $0x10,%esp
  8009a4:	eb 03                	jmp    8009a9 <vprintfmt+0x39a>
  8009a6:	83 ef 01             	sub    $0x1,%edi
  8009a9:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8009ad:	75 f7                	jne    8009a6 <vprintfmt+0x397>
  8009af:	e9 81 fc ff ff       	jmp    800635 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8009b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009b7:	5b                   	pop    %ebx
  8009b8:	5e                   	pop    %esi
  8009b9:	5f                   	pop    %edi
  8009ba:	5d                   	pop    %ebp
  8009bb:	c3                   	ret    

008009bc <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009bc:	55                   	push   %ebp
  8009bd:	89 e5                	mov    %esp,%ebp
  8009bf:	83 ec 18             	sub    $0x18,%esp
  8009c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c5:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009c8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009cb:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009cf:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009d2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009d9:	85 c0                	test   %eax,%eax
  8009db:	74 26                	je     800a03 <vsnprintf+0x47>
  8009dd:	85 d2                	test   %edx,%edx
  8009df:	7e 22                	jle    800a03 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009e1:	ff 75 14             	pushl  0x14(%ebp)
  8009e4:	ff 75 10             	pushl  0x10(%ebp)
  8009e7:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009ea:	50                   	push   %eax
  8009eb:	68 d5 05 80 00       	push   $0x8005d5
  8009f0:	e8 1a fc ff ff       	call   80060f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009f8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009fe:	83 c4 10             	add    $0x10,%esp
  800a01:	eb 05                	jmp    800a08 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800a03:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800a08:	c9                   	leave  
  800a09:	c3                   	ret    

00800a0a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a0a:	55                   	push   %ebp
  800a0b:	89 e5                	mov    %esp,%ebp
  800a0d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a10:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a13:	50                   	push   %eax
  800a14:	ff 75 10             	pushl  0x10(%ebp)
  800a17:	ff 75 0c             	pushl  0xc(%ebp)
  800a1a:	ff 75 08             	pushl  0x8(%ebp)
  800a1d:	e8 9a ff ff ff       	call   8009bc <vsnprintf>
	va_end(ap);

	return rc;
}
  800a22:	c9                   	leave  
  800a23:	c3                   	ret    

00800a24 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a24:	55                   	push   %ebp
  800a25:	89 e5                	mov    %esp,%ebp
  800a27:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a2a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a2f:	eb 03                	jmp    800a34 <strlen+0x10>
		n++;
  800a31:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a34:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a38:	75 f7                	jne    800a31 <strlen+0xd>
		n++;
	return n;
}
  800a3a:	5d                   	pop    %ebp
  800a3b:	c3                   	ret    

00800a3c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a3c:	55                   	push   %ebp
  800a3d:	89 e5                	mov    %esp,%ebp
  800a3f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a42:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a45:	ba 00 00 00 00       	mov    $0x0,%edx
  800a4a:	eb 03                	jmp    800a4f <strnlen+0x13>
		n++;
  800a4c:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a4f:	39 c2                	cmp    %eax,%edx
  800a51:	74 08                	je     800a5b <strnlen+0x1f>
  800a53:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800a57:	75 f3                	jne    800a4c <strnlen+0x10>
  800a59:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800a5b:	5d                   	pop    %ebp
  800a5c:	c3                   	ret    

00800a5d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a5d:	55                   	push   %ebp
  800a5e:	89 e5                	mov    %esp,%ebp
  800a60:	53                   	push   %ebx
  800a61:	8b 45 08             	mov    0x8(%ebp),%eax
  800a64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a67:	89 c2                	mov    %eax,%edx
  800a69:	83 c2 01             	add    $0x1,%edx
  800a6c:	83 c1 01             	add    $0x1,%ecx
  800a6f:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a73:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a76:	84 db                	test   %bl,%bl
  800a78:	75 ef                	jne    800a69 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a7a:	5b                   	pop    %ebx
  800a7b:	5d                   	pop    %ebp
  800a7c:	c3                   	ret    

00800a7d <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a7d:	55                   	push   %ebp
  800a7e:	89 e5                	mov    %esp,%ebp
  800a80:	53                   	push   %ebx
  800a81:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a84:	53                   	push   %ebx
  800a85:	e8 9a ff ff ff       	call   800a24 <strlen>
  800a8a:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a8d:	ff 75 0c             	pushl  0xc(%ebp)
  800a90:	01 d8                	add    %ebx,%eax
  800a92:	50                   	push   %eax
  800a93:	e8 c5 ff ff ff       	call   800a5d <strcpy>
	return dst;
}
  800a98:	89 d8                	mov    %ebx,%eax
  800a9a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a9d:	c9                   	leave  
  800a9e:	c3                   	ret    

00800a9f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a9f:	55                   	push   %ebp
  800aa0:	89 e5                	mov    %esp,%ebp
  800aa2:	56                   	push   %esi
  800aa3:	53                   	push   %ebx
  800aa4:	8b 75 08             	mov    0x8(%ebp),%esi
  800aa7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aaa:	89 f3                	mov    %esi,%ebx
  800aac:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800aaf:	89 f2                	mov    %esi,%edx
  800ab1:	eb 0f                	jmp    800ac2 <strncpy+0x23>
		*dst++ = *src;
  800ab3:	83 c2 01             	add    $0x1,%edx
  800ab6:	0f b6 01             	movzbl (%ecx),%eax
  800ab9:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800abc:	80 39 01             	cmpb   $0x1,(%ecx)
  800abf:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ac2:	39 da                	cmp    %ebx,%edx
  800ac4:	75 ed                	jne    800ab3 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800ac6:	89 f0                	mov    %esi,%eax
  800ac8:	5b                   	pop    %ebx
  800ac9:	5e                   	pop    %esi
  800aca:	5d                   	pop    %ebp
  800acb:	c3                   	ret    

00800acc <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800acc:	55                   	push   %ebp
  800acd:	89 e5                	mov    %esp,%ebp
  800acf:	56                   	push   %esi
  800ad0:	53                   	push   %ebx
  800ad1:	8b 75 08             	mov    0x8(%ebp),%esi
  800ad4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ad7:	8b 55 10             	mov    0x10(%ebp),%edx
  800ada:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800adc:	85 d2                	test   %edx,%edx
  800ade:	74 21                	je     800b01 <strlcpy+0x35>
  800ae0:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800ae4:	89 f2                	mov    %esi,%edx
  800ae6:	eb 09                	jmp    800af1 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800ae8:	83 c2 01             	add    $0x1,%edx
  800aeb:	83 c1 01             	add    $0x1,%ecx
  800aee:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800af1:	39 c2                	cmp    %eax,%edx
  800af3:	74 09                	je     800afe <strlcpy+0x32>
  800af5:	0f b6 19             	movzbl (%ecx),%ebx
  800af8:	84 db                	test   %bl,%bl
  800afa:	75 ec                	jne    800ae8 <strlcpy+0x1c>
  800afc:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800afe:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b01:	29 f0                	sub    %esi,%eax
}
  800b03:	5b                   	pop    %ebx
  800b04:	5e                   	pop    %esi
  800b05:	5d                   	pop    %ebp
  800b06:	c3                   	ret    

00800b07 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b07:	55                   	push   %ebp
  800b08:	89 e5                	mov    %esp,%ebp
  800b0a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b0d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b10:	eb 06                	jmp    800b18 <strcmp+0x11>
		p++, q++;
  800b12:	83 c1 01             	add    $0x1,%ecx
  800b15:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b18:	0f b6 01             	movzbl (%ecx),%eax
  800b1b:	84 c0                	test   %al,%al
  800b1d:	74 04                	je     800b23 <strcmp+0x1c>
  800b1f:	3a 02                	cmp    (%edx),%al
  800b21:	74 ef                	je     800b12 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b23:	0f b6 c0             	movzbl %al,%eax
  800b26:	0f b6 12             	movzbl (%edx),%edx
  800b29:	29 d0                	sub    %edx,%eax
}
  800b2b:	5d                   	pop    %ebp
  800b2c:	c3                   	ret    

00800b2d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b2d:	55                   	push   %ebp
  800b2e:	89 e5                	mov    %esp,%ebp
  800b30:	53                   	push   %ebx
  800b31:	8b 45 08             	mov    0x8(%ebp),%eax
  800b34:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b37:	89 c3                	mov    %eax,%ebx
  800b39:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b3c:	eb 06                	jmp    800b44 <strncmp+0x17>
		n--, p++, q++;
  800b3e:	83 c0 01             	add    $0x1,%eax
  800b41:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b44:	39 d8                	cmp    %ebx,%eax
  800b46:	74 15                	je     800b5d <strncmp+0x30>
  800b48:	0f b6 08             	movzbl (%eax),%ecx
  800b4b:	84 c9                	test   %cl,%cl
  800b4d:	74 04                	je     800b53 <strncmp+0x26>
  800b4f:	3a 0a                	cmp    (%edx),%cl
  800b51:	74 eb                	je     800b3e <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b53:	0f b6 00             	movzbl (%eax),%eax
  800b56:	0f b6 12             	movzbl (%edx),%edx
  800b59:	29 d0                	sub    %edx,%eax
  800b5b:	eb 05                	jmp    800b62 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b5d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b62:	5b                   	pop    %ebx
  800b63:	5d                   	pop    %ebp
  800b64:	c3                   	ret    

00800b65 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b65:	55                   	push   %ebp
  800b66:	89 e5                	mov    %esp,%ebp
  800b68:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b6f:	eb 07                	jmp    800b78 <strchr+0x13>
		if (*s == c)
  800b71:	38 ca                	cmp    %cl,%dl
  800b73:	74 0f                	je     800b84 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b75:	83 c0 01             	add    $0x1,%eax
  800b78:	0f b6 10             	movzbl (%eax),%edx
  800b7b:	84 d2                	test   %dl,%dl
  800b7d:	75 f2                	jne    800b71 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800b7f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b84:	5d                   	pop    %ebp
  800b85:	c3                   	ret    

00800b86 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b86:	55                   	push   %ebp
  800b87:	89 e5                	mov    %esp,%ebp
  800b89:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b90:	eb 03                	jmp    800b95 <strfind+0xf>
  800b92:	83 c0 01             	add    $0x1,%eax
  800b95:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b98:	38 ca                	cmp    %cl,%dl
  800b9a:	74 04                	je     800ba0 <strfind+0x1a>
  800b9c:	84 d2                	test   %dl,%dl
  800b9e:	75 f2                	jne    800b92 <strfind+0xc>
			break;
	return (char *) s;
}
  800ba0:	5d                   	pop    %ebp
  800ba1:	c3                   	ret    

00800ba2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ba2:	55                   	push   %ebp
  800ba3:	89 e5                	mov    %esp,%ebp
  800ba5:	57                   	push   %edi
  800ba6:	56                   	push   %esi
  800ba7:	53                   	push   %ebx
  800ba8:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bab:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bae:	85 c9                	test   %ecx,%ecx
  800bb0:	74 36                	je     800be8 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bb2:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bb8:	75 28                	jne    800be2 <memset+0x40>
  800bba:	f6 c1 03             	test   $0x3,%cl
  800bbd:	75 23                	jne    800be2 <memset+0x40>
		c &= 0xFF;
  800bbf:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bc3:	89 d3                	mov    %edx,%ebx
  800bc5:	c1 e3 08             	shl    $0x8,%ebx
  800bc8:	89 d6                	mov    %edx,%esi
  800bca:	c1 e6 18             	shl    $0x18,%esi
  800bcd:	89 d0                	mov    %edx,%eax
  800bcf:	c1 e0 10             	shl    $0x10,%eax
  800bd2:	09 f0                	or     %esi,%eax
  800bd4:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800bd6:	89 d8                	mov    %ebx,%eax
  800bd8:	09 d0                	or     %edx,%eax
  800bda:	c1 e9 02             	shr    $0x2,%ecx
  800bdd:	fc                   	cld    
  800bde:	f3 ab                	rep stos %eax,%es:(%edi)
  800be0:	eb 06                	jmp    800be8 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800be2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800be5:	fc                   	cld    
  800be6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800be8:	89 f8                	mov    %edi,%eax
  800bea:	5b                   	pop    %ebx
  800beb:	5e                   	pop    %esi
  800bec:	5f                   	pop    %edi
  800bed:	5d                   	pop    %ebp
  800bee:	c3                   	ret    

00800bef <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bef:	55                   	push   %ebp
  800bf0:	89 e5                	mov    %esp,%ebp
  800bf2:	57                   	push   %edi
  800bf3:	56                   	push   %esi
  800bf4:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf7:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bfa:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bfd:	39 c6                	cmp    %eax,%esi
  800bff:	73 35                	jae    800c36 <memmove+0x47>
  800c01:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c04:	39 d0                	cmp    %edx,%eax
  800c06:	73 2e                	jae    800c36 <memmove+0x47>
		s += n;
		d += n;
  800c08:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c0b:	89 d6                	mov    %edx,%esi
  800c0d:	09 fe                	or     %edi,%esi
  800c0f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c15:	75 13                	jne    800c2a <memmove+0x3b>
  800c17:	f6 c1 03             	test   $0x3,%cl
  800c1a:	75 0e                	jne    800c2a <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800c1c:	83 ef 04             	sub    $0x4,%edi
  800c1f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c22:	c1 e9 02             	shr    $0x2,%ecx
  800c25:	fd                   	std    
  800c26:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c28:	eb 09                	jmp    800c33 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c2a:	83 ef 01             	sub    $0x1,%edi
  800c2d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800c30:	fd                   	std    
  800c31:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c33:	fc                   	cld    
  800c34:	eb 1d                	jmp    800c53 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c36:	89 f2                	mov    %esi,%edx
  800c38:	09 c2                	or     %eax,%edx
  800c3a:	f6 c2 03             	test   $0x3,%dl
  800c3d:	75 0f                	jne    800c4e <memmove+0x5f>
  800c3f:	f6 c1 03             	test   $0x3,%cl
  800c42:	75 0a                	jne    800c4e <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800c44:	c1 e9 02             	shr    $0x2,%ecx
  800c47:	89 c7                	mov    %eax,%edi
  800c49:	fc                   	cld    
  800c4a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c4c:	eb 05                	jmp    800c53 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c4e:	89 c7                	mov    %eax,%edi
  800c50:	fc                   	cld    
  800c51:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c53:	5e                   	pop    %esi
  800c54:	5f                   	pop    %edi
  800c55:	5d                   	pop    %ebp
  800c56:	c3                   	ret    

00800c57 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c57:	55                   	push   %ebp
  800c58:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800c5a:	ff 75 10             	pushl  0x10(%ebp)
  800c5d:	ff 75 0c             	pushl  0xc(%ebp)
  800c60:	ff 75 08             	pushl  0x8(%ebp)
  800c63:	e8 87 ff ff ff       	call   800bef <memmove>
}
  800c68:	c9                   	leave  
  800c69:	c3                   	ret    

00800c6a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c6a:	55                   	push   %ebp
  800c6b:	89 e5                	mov    %esp,%ebp
  800c6d:	56                   	push   %esi
  800c6e:	53                   	push   %ebx
  800c6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c72:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c75:	89 c6                	mov    %eax,%esi
  800c77:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c7a:	eb 1a                	jmp    800c96 <memcmp+0x2c>
		if (*s1 != *s2)
  800c7c:	0f b6 08             	movzbl (%eax),%ecx
  800c7f:	0f b6 1a             	movzbl (%edx),%ebx
  800c82:	38 d9                	cmp    %bl,%cl
  800c84:	74 0a                	je     800c90 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800c86:	0f b6 c1             	movzbl %cl,%eax
  800c89:	0f b6 db             	movzbl %bl,%ebx
  800c8c:	29 d8                	sub    %ebx,%eax
  800c8e:	eb 0f                	jmp    800c9f <memcmp+0x35>
		s1++, s2++;
  800c90:	83 c0 01             	add    $0x1,%eax
  800c93:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c96:	39 f0                	cmp    %esi,%eax
  800c98:	75 e2                	jne    800c7c <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c9a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c9f:	5b                   	pop    %ebx
  800ca0:	5e                   	pop    %esi
  800ca1:	5d                   	pop    %ebp
  800ca2:	c3                   	ret    

00800ca3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ca3:	55                   	push   %ebp
  800ca4:	89 e5                	mov    %esp,%ebp
  800ca6:	53                   	push   %ebx
  800ca7:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800caa:	89 c1                	mov    %eax,%ecx
  800cac:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800caf:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cb3:	eb 0a                	jmp    800cbf <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cb5:	0f b6 10             	movzbl (%eax),%edx
  800cb8:	39 da                	cmp    %ebx,%edx
  800cba:	74 07                	je     800cc3 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cbc:	83 c0 01             	add    $0x1,%eax
  800cbf:	39 c8                	cmp    %ecx,%eax
  800cc1:	72 f2                	jb     800cb5 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800cc3:	5b                   	pop    %ebx
  800cc4:	5d                   	pop    %ebp
  800cc5:	c3                   	ret    

00800cc6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cc6:	55                   	push   %ebp
  800cc7:	89 e5                	mov    %esp,%ebp
  800cc9:	57                   	push   %edi
  800cca:	56                   	push   %esi
  800ccb:	53                   	push   %ebx
  800ccc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ccf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cd2:	eb 03                	jmp    800cd7 <strtol+0x11>
		s++;
  800cd4:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cd7:	0f b6 01             	movzbl (%ecx),%eax
  800cda:	3c 20                	cmp    $0x20,%al
  800cdc:	74 f6                	je     800cd4 <strtol+0xe>
  800cde:	3c 09                	cmp    $0x9,%al
  800ce0:	74 f2                	je     800cd4 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ce2:	3c 2b                	cmp    $0x2b,%al
  800ce4:	75 0a                	jne    800cf0 <strtol+0x2a>
		s++;
  800ce6:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ce9:	bf 00 00 00 00       	mov    $0x0,%edi
  800cee:	eb 11                	jmp    800d01 <strtol+0x3b>
  800cf0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800cf5:	3c 2d                	cmp    $0x2d,%al
  800cf7:	75 08                	jne    800d01 <strtol+0x3b>
		s++, neg = 1;
  800cf9:	83 c1 01             	add    $0x1,%ecx
  800cfc:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d01:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d07:	75 15                	jne    800d1e <strtol+0x58>
  800d09:	80 39 30             	cmpb   $0x30,(%ecx)
  800d0c:	75 10                	jne    800d1e <strtol+0x58>
  800d0e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d12:	75 7c                	jne    800d90 <strtol+0xca>
		s += 2, base = 16;
  800d14:	83 c1 02             	add    $0x2,%ecx
  800d17:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d1c:	eb 16                	jmp    800d34 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800d1e:	85 db                	test   %ebx,%ebx
  800d20:	75 12                	jne    800d34 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d22:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d27:	80 39 30             	cmpb   $0x30,(%ecx)
  800d2a:	75 08                	jne    800d34 <strtol+0x6e>
		s++, base = 8;
  800d2c:	83 c1 01             	add    $0x1,%ecx
  800d2f:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800d34:	b8 00 00 00 00       	mov    $0x0,%eax
  800d39:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d3c:	0f b6 11             	movzbl (%ecx),%edx
  800d3f:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d42:	89 f3                	mov    %esi,%ebx
  800d44:	80 fb 09             	cmp    $0x9,%bl
  800d47:	77 08                	ja     800d51 <strtol+0x8b>
			dig = *s - '0';
  800d49:	0f be d2             	movsbl %dl,%edx
  800d4c:	83 ea 30             	sub    $0x30,%edx
  800d4f:	eb 22                	jmp    800d73 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800d51:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d54:	89 f3                	mov    %esi,%ebx
  800d56:	80 fb 19             	cmp    $0x19,%bl
  800d59:	77 08                	ja     800d63 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800d5b:	0f be d2             	movsbl %dl,%edx
  800d5e:	83 ea 57             	sub    $0x57,%edx
  800d61:	eb 10                	jmp    800d73 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800d63:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d66:	89 f3                	mov    %esi,%ebx
  800d68:	80 fb 19             	cmp    $0x19,%bl
  800d6b:	77 16                	ja     800d83 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800d6d:	0f be d2             	movsbl %dl,%edx
  800d70:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800d73:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d76:	7d 0b                	jge    800d83 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800d78:	83 c1 01             	add    $0x1,%ecx
  800d7b:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d7f:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800d81:	eb b9                	jmp    800d3c <strtol+0x76>

	if (endptr)
  800d83:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d87:	74 0d                	je     800d96 <strtol+0xd0>
		*endptr = (char *) s;
  800d89:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d8c:	89 0e                	mov    %ecx,(%esi)
  800d8e:	eb 06                	jmp    800d96 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d90:	85 db                	test   %ebx,%ebx
  800d92:	74 98                	je     800d2c <strtol+0x66>
  800d94:	eb 9e                	jmp    800d34 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800d96:	89 c2                	mov    %eax,%edx
  800d98:	f7 da                	neg    %edx
  800d9a:	85 ff                	test   %edi,%edi
  800d9c:	0f 45 c2             	cmovne %edx,%eax
}
  800d9f:	5b                   	pop    %ebx
  800da0:	5e                   	pop    %esi
  800da1:	5f                   	pop    %edi
  800da2:	5d                   	pop    %ebp
  800da3:	c3                   	ret    

00800da4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800da4:	55                   	push   %ebp
  800da5:	89 e5                	mov    %esp,%ebp
  800da7:	57                   	push   %edi
  800da8:	56                   	push   %esi
  800da9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800daa:	b8 00 00 00 00       	mov    $0x0,%eax
  800daf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db2:	8b 55 08             	mov    0x8(%ebp),%edx
  800db5:	89 c3                	mov    %eax,%ebx
  800db7:	89 c7                	mov    %eax,%edi
  800db9:	89 c6                	mov    %eax,%esi
  800dbb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800dbd:	5b                   	pop    %ebx
  800dbe:	5e                   	pop    %esi
  800dbf:	5f                   	pop    %edi
  800dc0:	5d                   	pop    %ebp
  800dc1:	c3                   	ret    

00800dc2 <sys_cgetc>:

int
sys_cgetc(void)
{
  800dc2:	55                   	push   %ebp
  800dc3:	89 e5                	mov    %esp,%ebp
  800dc5:	57                   	push   %edi
  800dc6:	56                   	push   %esi
  800dc7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc8:	ba 00 00 00 00       	mov    $0x0,%edx
  800dcd:	b8 01 00 00 00       	mov    $0x1,%eax
  800dd2:	89 d1                	mov    %edx,%ecx
  800dd4:	89 d3                	mov    %edx,%ebx
  800dd6:	89 d7                	mov    %edx,%edi
  800dd8:	89 d6                	mov    %edx,%esi
  800dda:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ddc:	5b                   	pop    %ebx
  800ddd:	5e                   	pop    %esi
  800dde:	5f                   	pop    %edi
  800ddf:	5d                   	pop    %ebp
  800de0:	c3                   	ret    

00800de1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800de1:	55                   	push   %ebp
  800de2:	89 e5                	mov    %esp,%ebp
  800de4:	57                   	push   %edi
  800de5:	56                   	push   %esi
  800de6:	53                   	push   %ebx
  800de7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dea:	b9 00 00 00 00       	mov    $0x0,%ecx
  800def:	b8 03 00 00 00       	mov    $0x3,%eax
  800df4:	8b 55 08             	mov    0x8(%ebp),%edx
  800df7:	89 cb                	mov    %ecx,%ebx
  800df9:	89 cf                	mov    %ecx,%edi
  800dfb:	89 ce                	mov    %ecx,%esi
  800dfd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dff:	85 c0                	test   %eax,%eax
  800e01:	7e 17                	jle    800e1a <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e03:	83 ec 0c             	sub    $0xc,%esp
  800e06:	50                   	push   %eax
  800e07:	6a 03                	push   $0x3
  800e09:	68 bf 2e 80 00       	push   $0x802ebf
  800e0e:	6a 23                	push   $0x23
  800e10:	68 dc 2e 80 00       	push   $0x802edc
  800e15:	e8 e5 f5 ff ff       	call   8003ff <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e1d:	5b                   	pop    %ebx
  800e1e:	5e                   	pop    %esi
  800e1f:	5f                   	pop    %edi
  800e20:	5d                   	pop    %ebp
  800e21:	c3                   	ret    

00800e22 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e22:	55                   	push   %ebp
  800e23:	89 e5                	mov    %esp,%ebp
  800e25:	57                   	push   %edi
  800e26:	56                   	push   %esi
  800e27:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e28:	ba 00 00 00 00       	mov    $0x0,%edx
  800e2d:	b8 02 00 00 00       	mov    $0x2,%eax
  800e32:	89 d1                	mov    %edx,%ecx
  800e34:	89 d3                	mov    %edx,%ebx
  800e36:	89 d7                	mov    %edx,%edi
  800e38:	89 d6                	mov    %edx,%esi
  800e3a:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e3c:	5b                   	pop    %ebx
  800e3d:	5e                   	pop    %esi
  800e3e:	5f                   	pop    %edi
  800e3f:	5d                   	pop    %ebp
  800e40:	c3                   	ret    

00800e41 <sys_yield>:

void
sys_yield(void)
{
  800e41:	55                   	push   %ebp
  800e42:	89 e5                	mov    %esp,%ebp
  800e44:	57                   	push   %edi
  800e45:	56                   	push   %esi
  800e46:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e47:	ba 00 00 00 00       	mov    $0x0,%edx
  800e4c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e51:	89 d1                	mov    %edx,%ecx
  800e53:	89 d3                	mov    %edx,%ebx
  800e55:	89 d7                	mov    %edx,%edi
  800e57:	89 d6                	mov    %edx,%esi
  800e59:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e5b:	5b                   	pop    %ebx
  800e5c:	5e                   	pop    %esi
  800e5d:	5f                   	pop    %edi
  800e5e:	5d                   	pop    %ebp
  800e5f:	c3                   	ret    

00800e60 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e60:	55                   	push   %ebp
  800e61:	89 e5                	mov    %esp,%ebp
  800e63:	57                   	push   %edi
  800e64:	56                   	push   %esi
  800e65:	53                   	push   %ebx
  800e66:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e69:	be 00 00 00 00       	mov    $0x0,%esi
  800e6e:	b8 04 00 00 00       	mov    $0x4,%eax
  800e73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e76:	8b 55 08             	mov    0x8(%ebp),%edx
  800e79:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e7c:	89 f7                	mov    %esi,%edi
  800e7e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e80:	85 c0                	test   %eax,%eax
  800e82:	7e 17                	jle    800e9b <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e84:	83 ec 0c             	sub    $0xc,%esp
  800e87:	50                   	push   %eax
  800e88:	6a 04                	push   $0x4
  800e8a:	68 bf 2e 80 00       	push   $0x802ebf
  800e8f:	6a 23                	push   $0x23
  800e91:	68 dc 2e 80 00       	push   $0x802edc
  800e96:	e8 64 f5 ff ff       	call   8003ff <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e9b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e9e:	5b                   	pop    %ebx
  800e9f:	5e                   	pop    %esi
  800ea0:	5f                   	pop    %edi
  800ea1:	5d                   	pop    %ebp
  800ea2:	c3                   	ret    

00800ea3 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ea3:	55                   	push   %ebp
  800ea4:	89 e5                	mov    %esp,%ebp
  800ea6:	57                   	push   %edi
  800ea7:	56                   	push   %esi
  800ea8:	53                   	push   %ebx
  800ea9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eac:	b8 05 00 00 00       	mov    $0x5,%eax
  800eb1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb4:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eba:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ebd:	8b 75 18             	mov    0x18(%ebp),%esi
  800ec0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ec2:	85 c0                	test   %eax,%eax
  800ec4:	7e 17                	jle    800edd <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec6:	83 ec 0c             	sub    $0xc,%esp
  800ec9:	50                   	push   %eax
  800eca:	6a 05                	push   $0x5
  800ecc:	68 bf 2e 80 00       	push   $0x802ebf
  800ed1:	6a 23                	push   $0x23
  800ed3:	68 dc 2e 80 00       	push   $0x802edc
  800ed8:	e8 22 f5 ff ff       	call   8003ff <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800edd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ee0:	5b                   	pop    %ebx
  800ee1:	5e                   	pop    %esi
  800ee2:	5f                   	pop    %edi
  800ee3:	5d                   	pop    %ebp
  800ee4:	c3                   	ret    

00800ee5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ee5:	55                   	push   %ebp
  800ee6:	89 e5                	mov    %esp,%ebp
  800ee8:	57                   	push   %edi
  800ee9:	56                   	push   %esi
  800eea:	53                   	push   %ebx
  800eeb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eee:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ef3:	b8 06 00 00 00       	mov    $0x6,%eax
  800ef8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800efb:	8b 55 08             	mov    0x8(%ebp),%edx
  800efe:	89 df                	mov    %ebx,%edi
  800f00:	89 de                	mov    %ebx,%esi
  800f02:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f04:	85 c0                	test   %eax,%eax
  800f06:	7e 17                	jle    800f1f <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f08:	83 ec 0c             	sub    $0xc,%esp
  800f0b:	50                   	push   %eax
  800f0c:	6a 06                	push   $0x6
  800f0e:	68 bf 2e 80 00       	push   $0x802ebf
  800f13:	6a 23                	push   $0x23
  800f15:	68 dc 2e 80 00       	push   $0x802edc
  800f1a:	e8 e0 f4 ff ff       	call   8003ff <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f1f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f22:	5b                   	pop    %ebx
  800f23:	5e                   	pop    %esi
  800f24:	5f                   	pop    %edi
  800f25:	5d                   	pop    %ebp
  800f26:	c3                   	ret    

00800f27 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f27:	55                   	push   %ebp
  800f28:	89 e5                	mov    %esp,%ebp
  800f2a:	57                   	push   %edi
  800f2b:	56                   	push   %esi
  800f2c:	53                   	push   %ebx
  800f2d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f30:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f35:	b8 08 00 00 00       	mov    $0x8,%eax
  800f3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f3d:	8b 55 08             	mov    0x8(%ebp),%edx
  800f40:	89 df                	mov    %ebx,%edi
  800f42:	89 de                	mov    %ebx,%esi
  800f44:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f46:	85 c0                	test   %eax,%eax
  800f48:	7e 17                	jle    800f61 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f4a:	83 ec 0c             	sub    $0xc,%esp
  800f4d:	50                   	push   %eax
  800f4e:	6a 08                	push   $0x8
  800f50:	68 bf 2e 80 00       	push   $0x802ebf
  800f55:	6a 23                	push   $0x23
  800f57:	68 dc 2e 80 00       	push   $0x802edc
  800f5c:	e8 9e f4 ff ff       	call   8003ff <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f61:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f64:	5b                   	pop    %ebx
  800f65:	5e                   	pop    %esi
  800f66:	5f                   	pop    %edi
  800f67:	5d                   	pop    %ebp
  800f68:	c3                   	ret    

00800f69 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f69:	55                   	push   %ebp
  800f6a:	89 e5                	mov    %esp,%ebp
  800f6c:	57                   	push   %edi
  800f6d:	56                   	push   %esi
  800f6e:	53                   	push   %ebx
  800f6f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f72:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f77:	b8 09 00 00 00       	mov    $0x9,%eax
  800f7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f7f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f82:	89 df                	mov    %ebx,%edi
  800f84:	89 de                	mov    %ebx,%esi
  800f86:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f88:	85 c0                	test   %eax,%eax
  800f8a:	7e 17                	jle    800fa3 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f8c:	83 ec 0c             	sub    $0xc,%esp
  800f8f:	50                   	push   %eax
  800f90:	6a 09                	push   $0x9
  800f92:	68 bf 2e 80 00       	push   $0x802ebf
  800f97:	6a 23                	push   $0x23
  800f99:	68 dc 2e 80 00       	push   $0x802edc
  800f9e:	e8 5c f4 ff ff       	call   8003ff <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800fa3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fa6:	5b                   	pop    %ebx
  800fa7:	5e                   	pop    %esi
  800fa8:	5f                   	pop    %edi
  800fa9:	5d                   	pop    %ebp
  800faa:	c3                   	ret    

00800fab <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800fab:	55                   	push   %ebp
  800fac:	89 e5                	mov    %esp,%ebp
  800fae:	57                   	push   %edi
  800faf:	56                   	push   %esi
  800fb0:	53                   	push   %ebx
  800fb1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fb4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fb9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800fbe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fc1:	8b 55 08             	mov    0x8(%ebp),%edx
  800fc4:	89 df                	mov    %ebx,%edi
  800fc6:	89 de                	mov    %ebx,%esi
  800fc8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fca:	85 c0                	test   %eax,%eax
  800fcc:	7e 17                	jle    800fe5 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fce:	83 ec 0c             	sub    $0xc,%esp
  800fd1:	50                   	push   %eax
  800fd2:	6a 0a                	push   $0xa
  800fd4:	68 bf 2e 80 00       	push   $0x802ebf
  800fd9:	6a 23                	push   $0x23
  800fdb:	68 dc 2e 80 00       	push   $0x802edc
  800fe0:	e8 1a f4 ff ff       	call   8003ff <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800fe5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fe8:	5b                   	pop    %ebx
  800fe9:	5e                   	pop    %esi
  800fea:	5f                   	pop    %edi
  800feb:	5d                   	pop    %ebp
  800fec:	c3                   	ret    

00800fed <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800fed:	55                   	push   %ebp
  800fee:	89 e5                	mov    %esp,%ebp
  800ff0:	57                   	push   %edi
  800ff1:	56                   	push   %esi
  800ff2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ff3:	be 00 00 00 00       	mov    $0x0,%esi
  800ff8:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ffd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801000:	8b 55 08             	mov    0x8(%ebp),%edx
  801003:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801006:	8b 7d 14             	mov    0x14(%ebp),%edi
  801009:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80100b:	5b                   	pop    %ebx
  80100c:	5e                   	pop    %esi
  80100d:	5f                   	pop    %edi
  80100e:	5d                   	pop    %ebp
  80100f:	c3                   	ret    

00801010 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801010:	55                   	push   %ebp
  801011:	89 e5                	mov    %esp,%ebp
  801013:	57                   	push   %edi
  801014:	56                   	push   %esi
  801015:	53                   	push   %ebx
  801016:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801019:	b9 00 00 00 00       	mov    $0x0,%ecx
  80101e:	b8 0d 00 00 00       	mov    $0xd,%eax
  801023:	8b 55 08             	mov    0x8(%ebp),%edx
  801026:	89 cb                	mov    %ecx,%ebx
  801028:	89 cf                	mov    %ecx,%edi
  80102a:	89 ce                	mov    %ecx,%esi
  80102c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80102e:	85 c0                	test   %eax,%eax
  801030:	7e 17                	jle    801049 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801032:	83 ec 0c             	sub    $0xc,%esp
  801035:	50                   	push   %eax
  801036:	6a 0d                	push   $0xd
  801038:	68 bf 2e 80 00       	push   $0x802ebf
  80103d:	6a 23                	push   $0x23
  80103f:	68 dc 2e 80 00       	push   $0x802edc
  801044:	e8 b6 f3 ff ff       	call   8003ff <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801049:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80104c:	5b                   	pop    %ebx
  80104d:	5e                   	pop    %esi
  80104e:	5f                   	pop    %edi
  80104f:	5d                   	pop    %ebp
  801050:	c3                   	ret    

00801051 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  801051:	55                   	push   %ebp
  801052:	89 e5                	mov    %esp,%ebp
  801054:	57                   	push   %edi
  801055:	56                   	push   %esi
  801056:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801057:	ba 00 00 00 00       	mov    $0x0,%edx
  80105c:	b8 0e 00 00 00       	mov    $0xe,%eax
  801061:	89 d1                	mov    %edx,%ecx
  801063:	89 d3                	mov    %edx,%ebx
  801065:	89 d7                	mov    %edx,%edi
  801067:	89 d6                	mov    %edx,%esi
  801069:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  80106b:	5b                   	pop    %ebx
  80106c:	5e                   	pop    %esi
  80106d:	5f                   	pop    %edi
  80106e:	5d                   	pop    %ebp
  80106f:	c3                   	ret    

00801070 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801070:	55                   	push   %ebp
  801071:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801073:	8b 45 08             	mov    0x8(%ebp),%eax
  801076:	05 00 00 00 30       	add    $0x30000000,%eax
  80107b:	c1 e8 0c             	shr    $0xc,%eax
}
  80107e:	5d                   	pop    %ebp
  80107f:	c3                   	ret    

00801080 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801080:	55                   	push   %ebp
  801081:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801083:	8b 45 08             	mov    0x8(%ebp),%eax
  801086:	05 00 00 00 30       	add    $0x30000000,%eax
  80108b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801090:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801095:	5d                   	pop    %ebp
  801096:	c3                   	ret    

00801097 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801097:	55                   	push   %ebp
  801098:	89 e5                	mov    %esp,%ebp
  80109a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80109d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010a2:	89 c2                	mov    %eax,%edx
  8010a4:	c1 ea 16             	shr    $0x16,%edx
  8010a7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010ae:	f6 c2 01             	test   $0x1,%dl
  8010b1:	74 11                	je     8010c4 <fd_alloc+0x2d>
  8010b3:	89 c2                	mov    %eax,%edx
  8010b5:	c1 ea 0c             	shr    $0xc,%edx
  8010b8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010bf:	f6 c2 01             	test   $0x1,%dl
  8010c2:	75 09                	jne    8010cd <fd_alloc+0x36>
			*fd_store = fd;
  8010c4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8010cb:	eb 17                	jmp    8010e4 <fd_alloc+0x4d>
  8010cd:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010d2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010d7:	75 c9                	jne    8010a2 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8010d9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8010df:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8010e4:	5d                   	pop    %ebp
  8010e5:	c3                   	ret    

008010e6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010e6:	55                   	push   %ebp
  8010e7:	89 e5                	mov    %esp,%ebp
  8010e9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010ec:	83 f8 1f             	cmp    $0x1f,%eax
  8010ef:	77 36                	ja     801127 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010f1:	c1 e0 0c             	shl    $0xc,%eax
  8010f4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8010f9:	89 c2                	mov    %eax,%edx
  8010fb:	c1 ea 16             	shr    $0x16,%edx
  8010fe:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801105:	f6 c2 01             	test   $0x1,%dl
  801108:	74 24                	je     80112e <fd_lookup+0x48>
  80110a:	89 c2                	mov    %eax,%edx
  80110c:	c1 ea 0c             	shr    $0xc,%edx
  80110f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801116:	f6 c2 01             	test   $0x1,%dl
  801119:	74 1a                	je     801135 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80111b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80111e:	89 02                	mov    %eax,(%edx)
	return 0;
  801120:	b8 00 00 00 00       	mov    $0x0,%eax
  801125:	eb 13                	jmp    80113a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801127:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80112c:	eb 0c                	jmp    80113a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80112e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801133:	eb 05                	jmp    80113a <fd_lookup+0x54>
  801135:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80113a:	5d                   	pop    %ebp
  80113b:	c3                   	ret    

0080113c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80113c:	55                   	push   %ebp
  80113d:	89 e5                	mov    %esp,%ebp
  80113f:	83 ec 08             	sub    $0x8,%esp
  801142:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801145:	ba 68 2f 80 00       	mov    $0x802f68,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80114a:	eb 13                	jmp    80115f <dev_lookup+0x23>
  80114c:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80114f:	39 08                	cmp    %ecx,(%eax)
  801151:	75 0c                	jne    80115f <dev_lookup+0x23>
			*dev = devtab[i];
  801153:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801156:	89 01                	mov    %eax,(%ecx)
			return 0;
  801158:	b8 00 00 00 00       	mov    $0x0,%eax
  80115d:	eb 2e                	jmp    80118d <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80115f:	8b 02                	mov    (%edx),%eax
  801161:	85 c0                	test   %eax,%eax
  801163:	75 e7                	jne    80114c <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801165:	a1 90 77 80 00       	mov    0x807790,%eax
  80116a:	8b 40 48             	mov    0x48(%eax),%eax
  80116d:	83 ec 04             	sub    $0x4,%esp
  801170:	51                   	push   %ecx
  801171:	50                   	push   %eax
  801172:	68 ec 2e 80 00       	push   $0x802eec
  801177:	e8 5c f3 ff ff       	call   8004d8 <cprintf>
	*dev = 0;
  80117c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80117f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801185:	83 c4 10             	add    $0x10,%esp
  801188:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80118d:	c9                   	leave  
  80118e:	c3                   	ret    

0080118f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80118f:	55                   	push   %ebp
  801190:	89 e5                	mov    %esp,%ebp
  801192:	56                   	push   %esi
  801193:	53                   	push   %ebx
  801194:	83 ec 10             	sub    $0x10,%esp
  801197:	8b 75 08             	mov    0x8(%ebp),%esi
  80119a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80119d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011a0:	50                   	push   %eax
  8011a1:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8011a7:	c1 e8 0c             	shr    $0xc,%eax
  8011aa:	50                   	push   %eax
  8011ab:	e8 36 ff ff ff       	call   8010e6 <fd_lookup>
  8011b0:	83 c4 08             	add    $0x8,%esp
  8011b3:	85 c0                	test   %eax,%eax
  8011b5:	78 05                	js     8011bc <fd_close+0x2d>
	    || fd != fd2)
  8011b7:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8011ba:	74 0c                	je     8011c8 <fd_close+0x39>
		return (must_exist ? r : 0);
  8011bc:	84 db                	test   %bl,%bl
  8011be:	ba 00 00 00 00       	mov    $0x0,%edx
  8011c3:	0f 44 c2             	cmove  %edx,%eax
  8011c6:	eb 41                	jmp    801209 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011c8:	83 ec 08             	sub    $0x8,%esp
  8011cb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011ce:	50                   	push   %eax
  8011cf:	ff 36                	pushl  (%esi)
  8011d1:	e8 66 ff ff ff       	call   80113c <dev_lookup>
  8011d6:	89 c3                	mov    %eax,%ebx
  8011d8:	83 c4 10             	add    $0x10,%esp
  8011db:	85 c0                	test   %eax,%eax
  8011dd:	78 1a                	js     8011f9 <fd_close+0x6a>
		if (dev->dev_close)
  8011df:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011e2:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8011e5:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8011ea:	85 c0                	test   %eax,%eax
  8011ec:	74 0b                	je     8011f9 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8011ee:	83 ec 0c             	sub    $0xc,%esp
  8011f1:	56                   	push   %esi
  8011f2:	ff d0                	call   *%eax
  8011f4:	89 c3                	mov    %eax,%ebx
  8011f6:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8011f9:	83 ec 08             	sub    $0x8,%esp
  8011fc:	56                   	push   %esi
  8011fd:	6a 00                	push   $0x0
  8011ff:	e8 e1 fc ff ff       	call   800ee5 <sys_page_unmap>
	return r;
  801204:	83 c4 10             	add    $0x10,%esp
  801207:	89 d8                	mov    %ebx,%eax
}
  801209:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80120c:	5b                   	pop    %ebx
  80120d:	5e                   	pop    %esi
  80120e:	5d                   	pop    %ebp
  80120f:	c3                   	ret    

00801210 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801210:	55                   	push   %ebp
  801211:	89 e5                	mov    %esp,%ebp
  801213:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801216:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801219:	50                   	push   %eax
  80121a:	ff 75 08             	pushl  0x8(%ebp)
  80121d:	e8 c4 fe ff ff       	call   8010e6 <fd_lookup>
  801222:	83 c4 08             	add    $0x8,%esp
  801225:	85 c0                	test   %eax,%eax
  801227:	78 10                	js     801239 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801229:	83 ec 08             	sub    $0x8,%esp
  80122c:	6a 01                	push   $0x1
  80122e:	ff 75 f4             	pushl  -0xc(%ebp)
  801231:	e8 59 ff ff ff       	call   80118f <fd_close>
  801236:	83 c4 10             	add    $0x10,%esp
}
  801239:	c9                   	leave  
  80123a:	c3                   	ret    

0080123b <close_all>:

void
close_all(void)
{
  80123b:	55                   	push   %ebp
  80123c:	89 e5                	mov    %esp,%ebp
  80123e:	53                   	push   %ebx
  80123f:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801242:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801247:	83 ec 0c             	sub    $0xc,%esp
  80124a:	53                   	push   %ebx
  80124b:	e8 c0 ff ff ff       	call   801210 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801250:	83 c3 01             	add    $0x1,%ebx
  801253:	83 c4 10             	add    $0x10,%esp
  801256:	83 fb 20             	cmp    $0x20,%ebx
  801259:	75 ec                	jne    801247 <close_all+0xc>
		close(i);
}
  80125b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80125e:	c9                   	leave  
  80125f:	c3                   	ret    

00801260 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801260:	55                   	push   %ebp
  801261:	89 e5                	mov    %esp,%ebp
  801263:	57                   	push   %edi
  801264:	56                   	push   %esi
  801265:	53                   	push   %ebx
  801266:	83 ec 2c             	sub    $0x2c,%esp
  801269:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80126c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80126f:	50                   	push   %eax
  801270:	ff 75 08             	pushl  0x8(%ebp)
  801273:	e8 6e fe ff ff       	call   8010e6 <fd_lookup>
  801278:	83 c4 08             	add    $0x8,%esp
  80127b:	85 c0                	test   %eax,%eax
  80127d:	0f 88 c1 00 00 00    	js     801344 <dup+0xe4>
		return r;
	close(newfdnum);
  801283:	83 ec 0c             	sub    $0xc,%esp
  801286:	56                   	push   %esi
  801287:	e8 84 ff ff ff       	call   801210 <close>

	newfd = INDEX2FD(newfdnum);
  80128c:	89 f3                	mov    %esi,%ebx
  80128e:	c1 e3 0c             	shl    $0xc,%ebx
  801291:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801297:	83 c4 04             	add    $0x4,%esp
  80129a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80129d:	e8 de fd ff ff       	call   801080 <fd2data>
  8012a2:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8012a4:	89 1c 24             	mov    %ebx,(%esp)
  8012a7:	e8 d4 fd ff ff       	call   801080 <fd2data>
  8012ac:	83 c4 10             	add    $0x10,%esp
  8012af:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012b2:	89 f8                	mov    %edi,%eax
  8012b4:	c1 e8 16             	shr    $0x16,%eax
  8012b7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012be:	a8 01                	test   $0x1,%al
  8012c0:	74 37                	je     8012f9 <dup+0x99>
  8012c2:	89 f8                	mov    %edi,%eax
  8012c4:	c1 e8 0c             	shr    $0xc,%eax
  8012c7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012ce:	f6 c2 01             	test   $0x1,%dl
  8012d1:	74 26                	je     8012f9 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012d3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012da:	83 ec 0c             	sub    $0xc,%esp
  8012dd:	25 07 0e 00 00       	and    $0xe07,%eax
  8012e2:	50                   	push   %eax
  8012e3:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012e6:	6a 00                	push   $0x0
  8012e8:	57                   	push   %edi
  8012e9:	6a 00                	push   $0x0
  8012eb:	e8 b3 fb ff ff       	call   800ea3 <sys_page_map>
  8012f0:	89 c7                	mov    %eax,%edi
  8012f2:	83 c4 20             	add    $0x20,%esp
  8012f5:	85 c0                	test   %eax,%eax
  8012f7:	78 2e                	js     801327 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012f9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8012fc:	89 d0                	mov    %edx,%eax
  8012fe:	c1 e8 0c             	shr    $0xc,%eax
  801301:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801308:	83 ec 0c             	sub    $0xc,%esp
  80130b:	25 07 0e 00 00       	and    $0xe07,%eax
  801310:	50                   	push   %eax
  801311:	53                   	push   %ebx
  801312:	6a 00                	push   $0x0
  801314:	52                   	push   %edx
  801315:	6a 00                	push   $0x0
  801317:	e8 87 fb ff ff       	call   800ea3 <sys_page_map>
  80131c:	89 c7                	mov    %eax,%edi
  80131e:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801321:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801323:	85 ff                	test   %edi,%edi
  801325:	79 1d                	jns    801344 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801327:	83 ec 08             	sub    $0x8,%esp
  80132a:	53                   	push   %ebx
  80132b:	6a 00                	push   $0x0
  80132d:	e8 b3 fb ff ff       	call   800ee5 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801332:	83 c4 08             	add    $0x8,%esp
  801335:	ff 75 d4             	pushl  -0x2c(%ebp)
  801338:	6a 00                	push   $0x0
  80133a:	e8 a6 fb ff ff       	call   800ee5 <sys_page_unmap>
	return r;
  80133f:	83 c4 10             	add    $0x10,%esp
  801342:	89 f8                	mov    %edi,%eax
}
  801344:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801347:	5b                   	pop    %ebx
  801348:	5e                   	pop    %esi
  801349:	5f                   	pop    %edi
  80134a:	5d                   	pop    %ebp
  80134b:	c3                   	ret    

0080134c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80134c:	55                   	push   %ebp
  80134d:	89 e5                	mov    %esp,%ebp
  80134f:	53                   	push   %ebx
  801350:	83 ec 14             	sub    $0x14,%esp
  801353:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801356:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801359:	50                   	push   %eax
  80135a:	53                   	push   %ebx
  80135b:	e8 86 fd ff ff       	call   8010e6 <fd_lookup>
  801360:	83 c4 08             	add    $0x8,%esp
  801363:	89 c2                	mov    %eax,%edx
  801365:	85 c0                	test   %eax,%eax
  801367:	78 6d                	js     8013d6 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801369:	83 ec 08             	sub    $0x8,%esp
  80136c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80136f:	50                   	push   %eax
  801370:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801373:	ff 30                	pushl  (%eax)
  801375:	e8 c2 fd ff ff       	call   80113c <dev_lookup>
  80137a:	83 c4 10             	add    $0x10,%esp
  80137d:	85 c0                	test   %eax,%eax
  80137f:	78 4c                	js     8013cd <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801381:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801384:	8b 42 08             	mov    0x8(%edx),%eax
  801387:	83 e0 03             	and    $0x3,%eax
  80138a:	83 f8 01             	cmp    $0x1,%eax
  80138d:	75 21                	jne    8013b0 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80138f:	a1 90 77 80 00       	mov    0x807790,%eax
  801394:	8b 40 48             	mov    0x48(%eax),%eax
  801397:	83 ec 04             	sub    $0x4,%esp
  80139a:	53                   	push   %ebx
  80139b:	50                   	push   %eax
  80139c:	68 2d 2f 80 00       	push   $0x802f2d
  8013a1:	e8 32 f1 ff ff       	call   8004d8 <cprintf>
		return -E_INVAL;
  8013a6:	83 c4 10             	add    $0x10,%esp
  8013a9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013ae:	eb 26                	jmp    8013d6 <read+0x8a>
	}
	if (!dev->dev_read)
  8013b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013b3:	8b 40 08             	mov    0x8(%eax),%eax
  8013b6:	85 c0                	test   %eax,%eax
  8013b8:	74 17                	je     8013d1 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013ba:	83 ec 04             	sub    $0x4,%esp
  8013bd:	ff 75 10             	pushl  0x10(%ebp)
  8013c0:	ff 75 0c             	pushl  0xc(%ebp)
  8013c3:	52                   	push   %edx
  8013c4:	ff d0                	call   *%eax
  8013c6:	89 c2                	mov    %eax,%edx
  8013c8:	83 c4 10             	add    $0x10,%esp
  8013cb:	eb 09                	jmp    8013d6 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013cd:	89 c2                	mov    %eax,%edx
  8013cf:	eb 05                	jmp    8013d6 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8013d1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8013d6:	89 d0                	mov    %edx,%eax
  8013d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013db:	c9                   	leave  
  8013dc:	c3                   	ret    

008013dd <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013dd:	55                   	push   %ebp
  8013de:	89 e5                	mov    %esp,%ebp
  8013e0:	57                   	push   %edi
  8013e1:	56                   	push   %esi
  8013e2:	53                   	push   %ebx
  8013e3:	83 ec 0c             	sub    $0xc,%esp
  8013e6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013e9:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013ec:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013f1:	eb 21                	jmp    801414 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013f3:	83 ec 04             	sub    $0x4,%esp
  8013f6:	89 f0                	mov    %esi,%eax
  8013f8:	29 d8                	sub    %ebx,%eax
  8013fa:	50                   	push   %eax
  8013fb:	89 d8                	mov    %ebx,%eax
  8013fd:	03 45 0c             	add    0xc(%ebp),%eax
  801400:	50                   	push   %eax
  801401:	57                   	push   %edi
  801402:	e8 45 ff ff ff       	call   80134c <read>
		if (m < 0)
  801407:	83 c4 10             	add    $0x10,%esp
  80140a:	85 c0                	test   %eax,%eax
  80140c:	78 10                	js     80141e <readn+0x41>
			return m;
		if (m == 0)
  80140e:	85 c0                	test   %eax,%eax
  801410:	74 0a                	je     80141c <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801412:	01 c3                	add    %eax,%ebx
  801414:	39 f3                	cmp    %esi,%ebx
  801416:	72 db                	jb     8013f3 <readn+0x16>
  801418:	89 d8                	mov    %ebx,%eax
  80141a:	eb 02                	jmp    80141e <readn+0x41>
  80141c:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80141e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801421:	5b                   	pop    %ebx
  801422:	5e                   	pop    %esi
  801423:	5f                   	pop    %edi
  801424:	5d                   	pop    %ebp
  801425:	c3                   	ret    

00801426 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801426:	55                   	push   %ebp
  801427:	89 e5                	mov    %esp,%ebp
  801429:	53                   	push   %ebx
  80142a:	83 ec 14             	sub    $0x14,%esp
  80142d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801430:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801433:	50                   	push   %eax
  801434:	53                   	push   %ebx
  801435:	e8 ac fc ff ff       	call   8010e6 <fd_lookup>
  80143a:	83 c4 08             	add    $0x8,%esp
  80143d:	89 c2                	mov    %eax,%edx
  80143f:	85 c0                	test   %eax,%eax
  801441:	78 68                	js     8014ab <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801443:	83 ec 08             	sub    $0x8,%esp
  801446:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801449:	50                   	push   %eax
  80144a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80144d:	ff 30                	pushl  (%eax)
  80144f:	e8 e8 fc ff ff       	call   80113c <dev_lookup>
  801454:	83 c4 10             	add    $0x10,%esp
  801457:	85 c0                	test   %eax,%eax
  801459:	78 47                	js     8014a2 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80145b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80145e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801462:	75 21                	jne    801485 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801464:	a1 90 77 80 00       	mov    0x807790,%eax
  801469:	8b 40 48             	mov    0x48(%eax),%eax
  80146c:	83 ec 04             	sub    $0x4,%esp
  80146f:	53                   	push   %ebx
  801470:	50                   	push   %eax
  801471:	68 49 2f 80 00       	push   $0x802f49
  801476:	e8 5d f0 ff ff       	call   8004d8 <cprintf>
		return -E_INVAL;
  80147b:	83 c4 10             	add    $0x10,%esp
  80147e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801483:	eb 26                	jmp    8014ab <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801485:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801488:	8b 52 0c             	mov    0xc(%edx),%edx
  80148b:	85 d2                	test   %edx,%edx
  80148d:	74 17                	je     8014a6 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80148f:	83 ec 04             	sub    $0x4,%esp
  801492:	ff 75 10             	pushl  0x10(%ebp)
  801495:	ff 75 0c             	pushl  0xc(%ebp)
  801498:	50                   	push   %eax
  801499:	ff d2                	call   *%edx
  80149b:	89 c2                	mov    %eax,%edx
  80149d:	83 c4 10             	add    $0x10,%esp
  8014a0:	eb 09                	jmp    8014ab <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014a2:	89 c2                	mov    %eax,%edx
  8014a4:	eb 05                	jmp    8014ab <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8014a6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8014ab:	89 d0                	mov    %edx,%eax
  8014ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014b0:	c9                   	leave  
  8014b1:	c3                   	ret    

008014b2 <seek>:

int
seek(int fdnum, off_t offset)
{
  8014b2:	55                   	push   %ebp
  8014b3:	89 e5                	mov    %esp,%ebp
  8014b5:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014b8:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014bb:	50                   	push   %eax
  8014bc:	ff 75 08             	pushl  0x8(%ebp)
  8014bf:	e8 22 fc ff ff       	call   8010e6 <fd_lookup>
  8014c4:	83 c4 08             	add    $0x8,%esp
  8014c7:	85 c0                	test   %eax,%eax
  8014c9:	78 0e                	js     8014d9 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8014cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014d1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014d9:	c9                   	leave  
  8014da:	c3                   	ret    

008014db <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8014db:	55                   	push   %ebp
  8014dc:	89 e5                	mov    %esp,%ebp
  8014de:	53                   	push   %ebx
  8014df:	83 ec 14             	sub    $0x14,%esp
  8014e2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014e5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014e8:	50                   	push   %eax
  8014e9:	53                   	push   %ebx
  8014ea:	e8 f7 fb ff ff       	call   8010e6 <fd_lookup>
  8014ef:	83 c4 08             	add    $0x8,%esp
  8014f2:	89 c2                	mov    %eax,%edx
  8014f4:	85 c0                	test   %eax,%eax
  8014f6:	78 65                	js     80155d <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014f8:	83 ec 08             	sub    $0x8,%esp
  8014fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014fe:	50                   	push   %eax
  8014ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801502:	ff 30                	pushl  (%eax)
  801504:	e8 33 fc ff ff       	call   80113c <dev_lookup>
  801509:	83 c4 10             	add    $0x10,%esp
  80150c:	85 c0                	test   %eax,%eax
  80150e:	78 44                	js     801554 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801510:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801513:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801517:	75 21                	jne    80153a <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801519:	a1 90 77 80 00       	mov    0x807790,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80151e:	8b 40 48             	mov    0x48(%eax),%eax
  801521:	83 ec 04             	sub    $0x4,%esp
  801524:	53                   	push   %ebx
  801525:	50                   	push   %eax
  801526:	68 0c 2f 80 00       	push   $0x802f0c
  80152b:	e8 a8 ef ff ff       	call   8004d8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801530:	83 c4 10             	add    $0x10,%esp
  801533:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801538:	eb 23                	jmp    80155d <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80153a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80153d:	8b 52 18             	mov    0x18(%edx),%edx
  801540:	85 d2                	test   %edx,%edx
  801542:	74 14                	je     801558 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801544:	83 ec 08             	sub    $0x8,%esp
  801547:	ff 75 0c             	pushl  0xc(%ebp)
  80154a:	50                   	push   %eax
  80154b:	ff d2                	call   *%edx
  80154d:	89 c2                	mov    %eax,%edx
  80154f:	83 c4 10             	add    $0x10,%esp
  801552:	eb 09                	jmp    80155d <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801554:	89 c2                	mov    %eax,%edx
  801556:	eb 05                	jmp    80155d <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801558:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80155d:	89 d0                	mov    %edx,%eax
  80155f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801562:	c9                   	leave  
  801563:	c3                   	ret    

00801564 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801564:	55                   	push   %ebp
  801565:	89 e5                	mov    %esp,%ebp
  801567:	53                   	push   %ebx
  801568:	83 ec 14             	sub    $0x14,%esp
  80156b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80156e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801571:	50                   	push   %eax
  801572:	ff 75 08             	pushl  0x8(%ebp)
  801575:	e8 6c fb ff ff       	call   8010e6 <fd_lookup>
  80157a:	83 c4 08             	add    $0x8,%esp
  80157d:	89 c2                	mov    %eax,%edx
  80157f:	85 c0                	test   %eax,%eax
  801581:	78 58                	js     8015db <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801583:	83 ec 08             	sub    $0x8,%esp
  801586:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801589:	50                   	push   %eax
  80158a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80158d:	ff 30                	pushl  (%eax)
  80158f:	e8 a8 fb ff ff       	call   80113c <dev_lookup>
  801594:	83 c4 10             	add    $0x10,%esp
  801597:	85 c0                	test   %eax,%eax
  801599:	78 37                	js     8015d2 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80159b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80159e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015a2:	74 32                	je     8015d6 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015a4:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015a7:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015ae:	00 00 00 
	stat->st_isdir = 0;
  8015b1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015b8:	00 00 00 
	stat->st_dev = dev;
  8015bb:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015c1:	83 ec 08             	sub    $0x8,%esp
  8015c4:	53                   	push   %ebx
  8015c5:	ff 75 f0             	pushl  -0x10(%ebp)
  8015c8:	ff 50 14             	call   *0x14(%eax)
  8015cb:	89 c2                	mov    %eax,%edx
  8015cd:	83 c4 10             	add    $0x10,%esp
  8015d0:	eb 09                	jmp    8015db <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015d2:	89 c2                	mov    %eax,%edx
  8015d4:	eb 05                	jmp    8015db <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8015d6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8015db:	89 d0                	mov    %edx,%eax
  8015dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015e0:	c9                   	leave  
  8015e1:	c3                   	ret    

008015e2 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015e2:	55                   	push   %ebp
  8015e3:	89 e5                	mov    %esp,%ebp
  8015e5:	56                   	push   %esi
  8015e6:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015e7:	83 ec 08             	sub    $0x8,%esp
  8015ea:	6a 00                	push   $0x0
  8015ec:	ff 75 08             	pushl  0x8(%ebp)
  8015ef:	e8 0c 02 00 00       	call   801800 <open>
  8015f4:	89 c3                	mov    %eax,%ebx
  8015f6:	83 c4 10             	add    $0x10,%esp
  8015f9:	85 c0                	test   %eax,%eax
  8015fb:	78 1b                	js     801618 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8015fd:	83 ec 08             	sub    $0x8,%esp
  801600:	ff 75 0c             	pushl  0xc(%ebp)
  801603:	50                   	push   %eax
  801604:	e8 5b ff ff ff       	call   801564 <fstat>
  801609:	89 c6                	mov    %eax,%esi
	close(fd);
  80160b:	89 1c 24             	mov    %ebx,(%esp)
  80160e:	e8 fd fb ff ff       	call   801210 <close>
	return r;
  801613:	83 c4 10             	add    $0x10,%esp
  801616:	89 f0                	mov    %esi,%eax
}
  801618:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80161b:	5b                   	pop    %ebx
  80161c:	5e                   	pop    %esi
  80161d:	5d                   	pop    %ebp
  80161e:	c3                   	ret    

0080161f <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80161f:	55                   	push   %ebp
  801620:	89 e5                	mov    %esp,%ebp
  801622:	56                   	push   %esi
  801623:	53                   	push   %ebx
  801624:	89 c6                	mov    %eax,%esi
  801626:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801628:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80162f:	75 12                	jne    801643 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801631:	83 ec 0c             	sub    $0xc,%esp
  801634:	6a 01                	push   $0x1
  801636:	e8 ec 10 00 00       	call   802727 <ipc_find_env>
  80163b:	a3 00 60 80 00       	mov    %eax,0x806000
  801640:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801643:	6a 07                	push   $0x7
  801645:	68 00 80 80 00       	push   $0x808000
  80164a:	56                   	push   %esi
  80164b:	ff 35 00 60 80 00    	pushl  0x806000
  801651:	e8 7d 10 00 00       	call   8026d3 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801656:	83 c4 0c             	add    $0xc,%esp
  801659:	6a 00                	push   $0x0
  80165b:	53                   	push   %ebx
  80165c:	6a 00                	push   $0x0
  80165e:	e8 07 10 00 00       	call   80266a <ipc_recv>
}
  801663:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801666:	5b                   	pop    %ebx
  801667:	5e                   	pop    %esi
  801668:	5d                   	pop    %ebp
  801669:	c3                   	ret    

0080166a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80166a:	55                   	push   %ebp
  80166b:	89 e5                	mov    %esp,%ebp
  80166d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801670:	8b 45 08             	mov    0x8(%ebp),%eax
  801673:	8b 40 0c             	mov    0xc(%eax),%eax
  801676:	a3 00 80 80 00       	mov    %eax,0x808000
	fsipcbuf.set_size.req_size = newsize;
  80167b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80167e:	a3 04 80 80 00       	mov    %eax,0x808004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801683:	ba 00 00 00 00       	mov    $0x0,%edx
  801688:	b8 02 00 00 00       	mov    $0x2,%eax
  80168d:	e8 8d ff ff ff       	call   80161f <fsipc>
}
  801692:	c9                   	leave  
  801693:	c3                   	ret    

00801694 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801694:	55                   	push   %ebp
  801695:	89 e5                	mov    %esp,%ebp
  801697:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80169a:	8b 45 08             	mov    0x8(%ebp),%eax
  80169d:	8b 40 0c             	mov    0xc(%eax),%eax
  8016a0:	a3 00 80 80 00       	mov    %eax,0x808000
	return fsipc(FSREQ_FLUSH, NULL);
  8016a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8016aa:	b8 06 00 00 00       	mov    $0x6,%eax
  8016af:	e8 6b ff ff ff       	call   80161f <fsipc>
}
  8016b4:	c9                   	leave  
  8016b5:	c3                   	ret    

008016b6 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016b6:	55                   	push   %ebp
  8016b7:	89 e5                	mov    %esp,%ebp
  8016b9:	53                   	push   %ebx
  8016ba:	83 ec 04             	sub    $0x4,%esp
  8016bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c3:	8b 40 0c             	mov    0xc(%eax),%eax
  8016c6:	a3 00 80 80 00       	mov    %eax,0x808000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8016d0:	b8 05 00 00 00       	mov    $0x5,%eax
  8016d5:	e8 45 ff ff ff       	call   80161f <fsipc>
  8016da:	85 c0                	test   %eax,%eax
  8016dc:	78 2c                	js     80170a <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016de:	83 ec 08             	sub    $0x8,%esp
  8016e1:	68 00 80 80 00       	push   $0x808000
  8016e6:	53                   	push   %ebx
  8016e7:	e8 71 f3 ff ff       	call   800a5d <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016ec:	a1 80 80 80 00       	mov    0x808080,%eax
  8016f1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016f7:	a1 84 80 80 00       	mov    0x808084,%eax
  8016fc:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801702:	83 c4 10             	add    $0x10,%esp
  801705:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80170a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80170d:	c9                   	leave  
  80170e:	c3                   	ret    

0080170f <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80170f:	55                   	push   %ebp
  801710:	89 e5                	mov    %esp,%ebp
  801712:	53                   	push   %ebx
  801713:	83 ec 08             	sub    $0x8,%esp
  801716:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801719:	8b 55 08             	mov    0x8(%ebp),%edx
  80171c:	8b 52 0c             	mov    0xc(%edx),%edx
  80171f:	89 15 00 80 80 00    	mov    %edx,0x808000
  801725:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80172a:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  80172f:	0f 46 d8             	cmovbe %eax,%ebx
	
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  801732:	89 1d 04 80 80 00    	mov    %ebx,0x808004
	
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  801738:	53                   	push   %ebx
  801739:	ff 75 0c             	pushl  0xc(%ebp)
  80173c:	68 08 80 80 00       	push   $0x808008
  801741:	e8 a9 f4 ff ff       	call   800bef <memmove>

	
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) 
  801746:	ba 00 00 00 00       	mov    $0x0,%edx
  80174b:	b8 04 00 00 00       	mov    $0x4,%eax
  801750:	e8 ca fe ff ff       	call   80161f <fsipc>
  801755:	83 c4 10             	add    $0x10,%esp
  801758:	85 c0                	test   %eax,%eax
  80175a:	78 1d                	js     801779 <devfile_write+0x6a>
		return r;
	assert(r <= n_real); 
  80175c:	39 d8                	cmp    %ebx,%eax
  80175e:	76 19                	jbe    801779 <devfile_write+0x6a>
  801760:	68 7c 2f 80 00       	push   $0x802f7c
  801765:	68 88 2f 80 00       	push   $0x802f88
  80176a:	68 a3 00 00 00       	push   $0xa3
  80176f:	68 9d 2f 80 00       	push   $0x802f9d
  801774:	e8 86 ec ff ff       	call   8003ff <_panic>
	return r;
}
  801779:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80177c:	c9                   	leave  
  80177d:	c3                   	ret    

0080177e <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80177e:	55                   	push   %ebp
  80177f:	89 e5                	mov    %esp,%ebp
  801781:	56                   	push   %esi
  801782:	53                   	push   %ebx
  801783:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801786:	8b 45 08             	mov    0x8(%ebp),%eax
  801789:	8b 40 0c             	mov    0xc(%eax),%eax
  80178c:	a3 00 80 80 00       	mov    %eax,0x808000
	fsipcbuf.read.req_n = n;
  801791:	89 35 04 80 80 00    	mov    %esi,0x808004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801797:	ba 00 00 00 00       	mov    $0x0,%edx
  80179c:	b8 03 00 00 00       	mov    $0x3,%eax
  8017a1:	e8 79 fe ff ff       	call   80161f <fsipc>
  8017a6:	89 c3                	mov    %eax,%ebx
  8017a8:	85 c0                	test   %eax,%eax
  8017aa:	78 4b                	js     8017f7 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8017ac:	39 c6                	cmp    %eax,%esi
  8017ae:	73 16                	jae    8017c6 <devfile_read+0x48>
  8017b0:	68 a8 2f 80 00       	push   $0x802fa8
  8017b5:	68 88 2f 80 00       	push   $0x802f88
  8017ba:	6a 7c                	push   $0x7c
  8017bc:	68 9d 2f 80 00       	push   $0x802f9d
  8017c1:	e8 39 ec ff ff       	call   8003ff <_panic>
	assert(r <= PGSIZE);
  8017c6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017cb:	7e 16                	jle    8017e3 <devfile_read+0x65>
  8017cd:	68 af 2f 80 00       	push   $0x802faf
  8017d2:	68 88 2f 80 00       	push   $0x802f88
  8017d7:	6a 7d                	push   $0x7d
  8017d9:	68 9d 2f 80 00       	push   $0x802f9d
  8017de:	e8 1c ec ff ff       	call   8003ff <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017e3:	83 ec 04             	sub    $0x4,%esp
  8017e6:	50                   	push   %eax
  8017e7:	68 00 80 80 00       	push   $0x808000
  8017ec:	ff 75 0c             	pushl  0xc(%ebp)
  8017ef:	e8 fb f3 ff ff       	call   800bef <memmove>
	return r;
  8017f4:	83 c4 10             	add    $0x10,%esp
}
  8017f7:	89 d8                	mov    %ebx,%eax
  8017f9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017fc:	5b                   	pop    %ebx
  8017fd:	5e                   	pop    %esi
  8017fe:	5d                   	pop    %ebp
  8017ff:	c3                   	ret    

00801800 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801800:	55                   	push   %ebp
  801801:	89 e5                	mov    %esp,%ebp
  801803:	53                   	push   %ebx
  801804:	83 ec 20             	sub    $0x20,%esp
  801807:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80180a:	53                   	push   %ebx
  80180b:	e8 14 f2 ff ff       	call   800a24 <strlen>
  801810:	83 c4 10             	add    $0x10,%esp
  801813:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801818:	7f 67                	jg     801881 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80181a:	83 ec 0c             	sub    $0xc,%esp
  80181d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801820:	50                   	push   %eax
  801821:	e8 71 f8 ff ff       	call   801097 <fd_alloc>
  801826:	83 c4 10             	add    $0x10,%esp
		return r;
  801829:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80182b:	85 c0                	test   %eax,%eax
  80182d:	78 57                	js     801886 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80182f:	83 ec 08             	sub    $0x8,%esp
  801832:	53                   	push   %ebx
  801833:	68 00 80 80 00       	push   $0x808000
  801838:	e8 20 f2 ff ff       	call   800a5d <strcpy>
	fsipcbuf.open.req_omode = mode;
  80183d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801840:	a3 00 84 80 00       	mov    %eax,0x808400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801845:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801848:	b8 01 00 00 00       	mov    $0x1,%eax
  80184d:	e8 cd fd ff ff       	call   80161f <fsipc>
  801852:	89 c3                	mov    %eax,%ebx
  801854:	83 c4 10             	add    $0x10,%esp
  801857:	85 c0                	test   %eax,%eax
  801859:	79 14                	jns    80186f <open+0x6f>
		fd_close(fd, 0);
  80185b:	83 ec 08             	sub    $0x8,%esp
  80185e:	6a 00                	push   $0x0
  801860:	ff 75 f4             	pushl  -0xc(%ebp)
  801863:	e8 27 f9 ff ff       	call   80118f <fd_close>
		return r;
  801868:	83 c4 10             	add    $0x10,%esp
  80186b:	89 da                	mov    %ebx,%edx
  80186d:	eb 17                	jmp    801886 <open+0x86>
	}

	return fd2num(fd);
  80186f:	83 ec 0c             	sub    $0xc,%esp
  801872:	ff 75 f4             	pushl  -0xc(%ebp)
  801875:	e8 f6 f7 ff ff       	call   801070 <fd2num>
  80187a:	89 c2                	mov    %eax,%edx
  80187c:	83 c4 10             	add    $0x10,%esp
  80187f:	eb 05                	jmp    801886 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801881:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801886:	89 d0                	mov    %edx,%eax
  801888:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80188b:	c9                   	leave  
  80188c:	c3                   	ret    

0080188d <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80188d:	55                   	push   %ebp
  80188e:	89 e5                	mov    %esp,%ebp
  801890:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801893:	ba 00 00 00 00       	mov    $0x0,%edx
  801898:	b8 08 00 00 00       	mov    $0x8,%eax
  80189d:	e8 7d fd ff ff       	call   80161f <fsipc>
}
  8018a2:	c9                   	leave  
  8018a3:	c3                   	ret    

008018a4 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8018a4:	55                   	push   %ebp
  8018a5:	89 e5                	mov    %esp,%ebp
  8018a7:	57                   	push   %edi
  8018a8:	56                   	push   %esi
  8018a9:	53                   	push   %ebx
  8018aa:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8018b0:	6a 00                	push   $0x0
  8018b2:	ff 75 08             	pushl  0x8(%ebp)
  8018b5:	e8 46 ff ff ff       	call   801800 <open>
  8018ba:	89 c7                	mov    %eax,%edi
  8018bc:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  8018c2:	83 c4 10             	add    $0x10,%esp
  8018c5:	85 c0                	test   %eax,%eax
  8018c7:	0f 88 ae 04 00 00    	js     801d7b <spawn+0x4d7>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8018cd:	83 ec 04             	sub    $0x4,%esp
  8018d0:	68 00 02 00 00       	push   $0x200
  8018d5:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8018db:	50                   	push   %eax
  8018dc:	57                   	push   %edi
  8018dd:	e8 fb fa ff ff       	call   8013dd <readn>
  8018e2:	83 c4 10             	add    $0x10,%esp
  8018e5:	3d 00 02 00 00       	cmp    $0x200,%eax
  8018ea:	75 0c                	jne    8018f8 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  8018ec:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8018f3:	45 4c 46 
  8018f6:	74 33                	je     80192b <spawn+0x87>
		close(fd);
  8018f8:	83 ec 0c             	sub    $0xc,%esp
  8018fb:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801901:	e8 0a f9 ff ff       	call   801210 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801906:	83 c4 0c             	add    $0xc,%esp
  801909:	68 7f 45 4c 46       	push   $0x464c457f
  80190e:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801914:	68 bb 2f 80 00       	push   $0x802fbb
  801919:	e8 ba eb ff ff       	call   8004d8 <cprintf>
		return -E_NOT_EXEC;
  80191e:	83 c4 10             	add    $0x10,%esp
  801921:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801926:	e9 b0 04 00 00       	jmp    801ddb <spawn+0x537>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  80192b:	b8 07 00 00 00       	mov    $0x7,%eax
  801930:	cd 30                	int    $0x30
  801932:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801938:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  80193e:	85 c0                	test   %eax,%eax
  801940:	0f 88 3d 04 00 00    	js     801d83 <spawn+0x4df>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801946:	89 c6                	mov    %eax,%esi
  801948:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  80194e:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801951:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801957:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  80195d:	b9 11 00 00 00       	mov    $0x11,%ecx
  801962:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801964:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  80196a:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801970:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801975:	be 00 00 00 00       	mov    $0x0,%esi
  80197a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80197d:	eb 13                	jmp    801992 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  80197f:	83 ec 0c             	sub    $0xc,%esp
  801982:	50                   	push   %eax
  801983:	e8 9c f0 ff ff       	call   800a24 <strlen>
  801988:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80198c:	83 c3 01             	add    $0x1,%ebx
  80198f:	83 c4 10             	add    $0x10,%esp
  801992:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801999:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  80199c:	85 c0                	test   %eax,%eax
  80199e:	75 df                	jne    80197f <spawn+0xdb>
  8019a0:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  8019a6:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8019ac:	bf 00 10 40 00       	mov    $0x401000,%edi
  8019b1:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  8019b3:	89 fa                	mov    %edi,%edx
  8019b5:	83 e2 fc             	and    $0xfffffffc,%edx
  8019b8:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  8019bf:	29 c2                	sub    %eax,%edx
  8019c1:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8019c7:	8d 42 f8             	lea    -0x8(%edx),%eax
  8019ca:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8019cf:	0f 86 be 03 00 00    	jbe    801d93 <spawn+0x4ef>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8019d5:	83 ec 04             	sub    $0x4,%esp
  8019d8:	6a 07                	push   $0x7
  8019da:	68 00 00 40 00       	push   $0x400000
  8019df:	6a 00                	push   $0x0
  8019e1:	e8 7a f4 ff ff       	call   800e60 <sys_page_alloc>
  8019e6:	83 c4 10             	add    $0x10,%esp
  8019e9:	85 c0                	test   %eax,%eax
  8019eb:	0f 88 a9 03 00 00    	js     801d9a <spawn+0x4f6>
  8019f1:	be 00 00 00 00       	mov    $0x0,%esi
  8019f6:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  8019fc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8019ff:	eb 30                	jmp    801a31 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801a01:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801a07:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801a0d:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801a10:	83 ec 08             	sub    $0x8,%esp
  801a13:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801a16:	57                   	push   %edi
  801a17:	e8 41 f0 ff ff       	call   800a5d <strcpy>
		string_store += strlen(argv[i]) + 1;
  801a1c:	83 c4 04             	add    $0x4,%esp
  801a1f:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801a22:	e8 fd ef ff ff       	call   800a24 <strlen>
  801a27:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801a2b:	83 c6 01             	add    $0x1,%esi
  801a2e:	83 c4 10             	add    $0x10,%esp
  801a31:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801a37:	7f c8                	jg     801a01 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801a39:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801a3f:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801a45:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801a4c:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801a52:	74 19                	je     801a6d <spawn+0x1c9>
  801a54:	68 30 30 80 00       	push   $0x803030
  801a59:	68 88 2f 80 00       	push   $0x802f88
  801a5e:	68 f2 00 00 00       	push   $0xf2
  801a63:	68 d5 2f 80 00       	push   $0x802fd5
  801a68:	e8 92 e9 ff ff       	call   8003ff <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801a6d:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801a73:	89 f8                	mov    %edi,%eax
  801a75:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801a7a:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801a7d:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801a83:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801a86:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801a8c:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801a92:	83 ec 0c             	sub    $0xc,%esp
  801a95:	6a 07                	push   $0x7
  801a97:	68 00 d0 bf ee       	push   $0xeebfd000
  801a9c:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801aa2:	68 00 00 40 00       	push   $0x400000
  801aa7:	6a 00                	push   $0x0
  801aa9:	e8 f5 f3 ff ff       	call   800ea3 <sys_page_map>
  801aae:	89 c3                	mov    %eax,%ebx
  801ab0:	83 c4 20             	add    $0x20,%esp
  801ab3:	85 c0                	test   %eax,%eax
  801ab5:	0f 88 0e 03 00 00    	js     801dc9 <spawn+0x525>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801abb:	83 ec 08             	sub    $0x8,%esp
  801abe:	68 00 00 40 00       	push   $0x400000
  801ac3:	6a 00                	push   $0x0
  801ac5:	e8 1b f4 ff ff       	call   800ee5 <sys_page_unmap>
  801aca:	89 c3                	mov    %eax,%ebx
  801acc:	83 c4 10             	add    $0x10,%esp
  801acf:	85 c0                	test   %eax,%eax
  801ad1:	0f 88 f2 02 00 00    	js     801dc9 <spawn+0x525>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801ad7:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801add:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801ae4:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801aea:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801af1:	00 00 00 
  801af4:	e9 88 01 00 00       	jmp    801c81 <spawn+0x3dd>
		if (ph->p_type != ELF_PROG_LOAD)
  801af9:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801aff:	83 38 01             	cmpl   $0x1,(%eax)
  801b02:	0f 85 6b 01 00 00    	jne    801c73 <spawn+0x3cf>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801b08:	89 c7                	mov    %eax,%edi
  801b0a:	8b 40 18             	mov    0x18(%eax),%eax
  801b0d:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801b13:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801b16:	83 f8 01             	cmp    $0x1,%eax
  801b19:	19 c0                	sbb    %eax,%eax
  801b1b:	83 e0 fe             	and    $0xfffffffe,%eax
  801b1e:	83 c0 07             	add    $0x7,%eax
  801b21:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801b27:	89 f8                	mov    %edi,%eax
  801b29:	8b 7f 04             	mov    0x4(%edi),%edi
  801b2c:	89 f9                	mov    %edi,%ecx
  801b2e:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801b34:	8b 78 10             	mov    0x10(%eax),%edi
  801b37:	8b 50 14             	mov    0x14(%eax),%edx
  801b3a:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  801b40:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801b43:	89 f0                	mov    %esi,%eax
  801b45:	25 ff 0f 00 00       	and    $0xfff,%eax
  801b4a:	74 14                	je     801b60 <spawn+0x2bc>
		va -= i;
  801b4c:	29 c6                	sub    %eax,%esi
		memsz += i;
  801b4e:	01 c2                	add    %eax,%edx
  801b50:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  801b56:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801b58:	29 c1                	sub    %eax,%ecx
  801b5a:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801b60:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b65:	e9 f7 00 00 00       	jmp    801c61 <spawn+0x3bd>
		if (i >= filesz) {
  801b6a:	39 df                	cmp    %ebx,%edi
  801b6c:	77 27                	ja     801b95 <spawn+0x2f1>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801b6e:	83 ec 04             	sub    $0x4,%esp
  801b71:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801b77:	56                   	push   %esi
  801b78:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801b7e:	e8 dd f2 ff ff       	call   800e60 <sys_page_alloc>
  801b83:	83 c4 10             	add    $0x10,%esp
  801b86:	85 c0                	test   %eax,%eax
  801b88:	0f 89 c7 00 00 00    	jns    801c55 <spawn+0x3b1>
  801b8e:	89 c3                	mov    %eax,%ebx
  801b90:	e9 13 02 00 00       	jmp    801da8 <spawn+0x504>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801b95:	83 ec 04             	sub    $0x4,%esp
  801b98:	6a 07                	push   $0x7
  801b9a:	68 00 00 40 00       	push   $0x400000
  801b9f:	6a 00                	push   $0x0
  801ba1:	e8 ba f2 ff ff       	call   800e60 <sys_page_alloc>
  801ba6:	83 c4 10             	add    $0x10,%esp
  801ba9:	85 c0                	test   %eax,%eax
  801bab:	0f 88 ed 01 00 00    	js     801d9e <spawn+0x4fa>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801bb1:	83 ec 08             	sub    $0x8,%esp
  801bb4:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801bba:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801bc0:	50                   	push   %eax
  801bc1:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801bc7:	e8 e6 f8 ff ff       	call   8014b2 <seek>
  801bcc:	83 c4 10             	add    $0x10,%esp
  801bcf:	85 c0                	test   %eax,%eax
  801bd1:	0f 88 cb 01 00 00    	js     801da2 <spawn+0x4fe>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801bd7:	83 ec 04             	sub    $0x4,%esp
  801bda:	89 f8                	mov    %edi,%eax
  801bdc:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801be2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801be7:	ba 00 10 00 00       	mov    $0x1000,%edx
  801bec:	0f 47 c2             	cmova  %edx,%eax
  801bef:	50                   	push   %eax
  801bf0:	68 00 00 40 00       	push   $0x400000
  801bf5:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801bfb:	e8 dd f7 ff ff       	call   8013dd <readn>
  801c00:	83 c4 10             	add    $0x10,%esp
  801c03:	85 c0                	test   %eax,%eax
  801c05:	0f 88 9b 01 00 00    	js     801da6 <spawn+0x502>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801c0b:	83 ec 0c             	sub    $0xc,%esp
  801c0e:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801c14:	56                   	push   %esi
  801c15:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801c1b:	68 00 00 40 00       	push   $0x400000
  801c20:	6a 00                	push   $0x0
  801c22:	e8 7c f2 ff ff       	call   800ea3 <sys_page_map>
  801c27:	83 c4 20             	add    $0x20,%esp
  801c2a:	85 c0                	test   %eax,%eax
  801c2c:	79 15                	jns    801c43 <spawn+0x39f>
				panic("spawn: sys_page_map data: %e", r);
  801c2e:	50                   	push   %eax
  801c2f:	68 e1 2f 80 00       	push   $0x802fe1
  801c34:	68 25 01 00 00       	push   $0x125
  801c39:	68 d5 2f 80 00       	push   $0x802fd5
  801c3e:	e8 bc e7 ff ff       	call   8003ff <_panic>
			sys_page_unmap(0, UTEMP);
  801c43:	83 ec 08             	sub    $0x8,%esp
  801c46:	68 00 00 40 00       	push   $0x400000
  801c4b:	6a 00                	push   $0x0
  801c4d:	e8 93 f2 ff ff       	call   800ee5 <sys_page_unmap>
  801c52:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801c55:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801c5b:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801c61:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801c67:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  801c6d:	0f 87 f7 fe ff ff    	ja     801b6a <spawn+0x2c6>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801c73:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801c7a:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801c81:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801c88:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801c8e:	0f 8c 65 fe ff ff    	jl     801af9 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801c94:	83 ec 0c             	sub    $0xc,%esp
  801c97:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801c9d:	e8 6e f5 ff ff       	call   801210 <close>
  801ca2:	83 c4 10             	add    $0x10,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	uintptr_t i;
	for (i = 0; i < USTACKTOP; i += PGSIZE){
  801ca5:	bb 00 00 00 00       	mov    $0x0,%ebx
  801caa:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[PGNUM(i)] & PTE_P) && (uvpt[PGNUM(i)] & PTE_U) && (uvpt[PGNUM(i)] & PTE_SHARE)){
  801cb0:	89 d8                	mov    %ebx,%eax
  801cb2:	c1 e8 16             	shr    $0x16,%eax
  801cb5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801cbc:	a8 01                	test   $0x1,%al
  801cbe:	74 46                	je     801d06 <spawn+0x462>
  801cc0:	89 d8                	mov    %ebx,%eax
  801cc2:	c1 e8 0c             	shr    $0xc,%eax
  801cc5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801ccc:	f6 c2 01             	test   $0x1,%dl
  801ccf:	74 35                	je     801d06 <spawn+0x462>
  801cd1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801cd8:	f6 c2 04             	test   $0x4,%dl
  801cdb:	74 29                	je     801d06 <spawn+0x462>
  801cdd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801ce4:	f6 c6 04             	test   $0x4,%dh
  801ce7:	74 1d                	je     801d06 <spawn+0x462>
			sys_page_map(0, (void*)i,child, (void*)i,(uvpt[PGNUM(i)] | PTE_SYSCALL));
  801ce9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801cf0:	83 ec 0c             	sub    $0xc,%esp
  801cf3:	0d 07 0e 00 00       	or     $0xe07,%eax
  801cf8:	50                   	push   %eax
  801cf9:	53                   	push   %ebx
  801cfa:	56                   	push   %esi
  801cfb:	53                   	push   %ebx
  801cfc:	6a 00                	push   $0x0
  801cfe:	e8 a0 f1 ff ff       	call   800ea3 <sys_page_map>
  801d03:	83 c4 20             	add    $0x20,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	uintptr_t i;
	for (i = 0; i < USTACKTOP; i += PGSIZE){
  801d06:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801d0c:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801d12:	75 9c                	jne    801cb0 <spawn+0x40c>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801d14:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801d1b:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801d1e:	83 ec 08             	sub    $0x8,%esp
  801d21:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801d27:	50                   	push   %eax
  801d28:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801d2e:	e8 36 f2 ff ff       	call   800f69 <sys_env_set_trapframe>
  801d33:	83 c4 10             	add    $0x10,%esp
  801d36:	85 c0                	test   %eax,%eax
  801d38:	79 15                	jns    801d4f <spawn+0x4ab>
		panic("sys_env_set_trapframe: %e", r);
  801d3a:	50                   	push   %eax
  801d3b:	68 fe 2f 80 00       	push   $0x802ffe
  801d40:	68 86 00 00 00       	push   $0x86
  801d45:	68 d5 2f 80 00       	push   $0x802fd5
  801d4a:	e8 b0 e6 ff ff       	call   8003ff <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801d4f:	83 ec 08             	sub    $0x8,%esp
  801d52:	6a 02                	push   $0x2
  801d54:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801d5a:	e8 c8 f1 ff ff       	call   800f27 <sys_env_set_status>
  801d5f:	83 c4 10             	add    $0x10,%esp
  801d62:	85 c0                	test   %eax,%eax
  801d64:	79 25                	jns    801d8b <spawn+0x4e7>
		panic("sys_env_set_status: %e", r);
  801d66:	50                   	push   %eax
  801d67:	68 18 30 80 00       	push   $0x803018
  801d6c:	68 89 00 00 00       	push   $0x89
  801d71:	68 d5 2f 80 00       	push   $0x802fd5
  801d76:	e8 84 e6 ff ff       	call   8003ff <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801d7b:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801d81:	eb 58                	jmp    801ddb <spawn+0x537>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801d83:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801d89:	eb 50                	jmp    801ddb <spawn+0x537>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801d8b:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801d91:	eb 48                	jmp    801ddb <spawn+0x537>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801d93:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801d98:	eb 41                	jmp    801ddb <spawn+0x537>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801d9a:	89 c3                	mov    %eax,%ebx
  801d9c:	eb 3d                	jmp    801ddb <spawn+0x537>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801d9e:	89 c3                	mov    %eax,%ebx
  801da0:	eb 06                	jmp    801da8 <spawn+0x504>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801da2:	89 c3                	mov    %eax,%ebx
  801da4:	eb 02                	jmp    801da8 <spawn+0x504>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801da6:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801da8:	83 ec 0c             	sub    $0xc,%esp
  801dab:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801db1:	e8 2b f0 ff ff       	call   800de1 <sys_env_destroy>
	close(fd);
  801db6:	83 c4 04             	add    $0x4,%esp
  801db9:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801dbf:	e8 4c f4 ff ff       	call   801210 <close>
	return r;
  801dc4:	83 c4 10             	add    $0x10,%esp
  801dc7:	eb 12                	jmp    801ddb <spawn+0x537>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801dc9:	83 ec 08             	sub    $0x8,%esp
  801dcc:	68 00 00 40 00       	push   $0x400000
  801dd1:	6a 00                	push   $0x0
  801dd3:	e8 0d f1 ff ff       	call   800ee5 <sys_page_unmap>
  801dd8:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801ddb:	89 d8                	mov    %ebx,%eax
  801ddd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801de0:	5b                   	pop    %ebx
  801de1:	5e                   	pop    %esi
  801de2:	5f                   	pop    %edi
  801de3:	5d                   	pop    %ebp
  801de4:	c3                   	ret    

00801de5 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801de5:	55                   	push   %ebp
  801de6:	89 e5                	mov    %esp,%ebp
  801de8:	56                   	push   %esi
  801de9:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801dea:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801ded:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801df2:	eb 03                	jmp    801df7 <spawnl+0x12>
		argc++;
  801df4:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801df7:	83 c2 04             	add    $0x4,%edx
  801dfa:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801dfe:	75 f4                	jne    801df4 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801e00:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801e07:	83 e2 f0             	and    $0xfffffff0,%edx
  801e0a:	29 d4                	sub    %edx,%esp
  801e0c:	8d 54 24 03          	lea    0x3(%esp),%edx
  801e10:	c1 ea 02             	shr    $0x2,%edx
  801e13:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801e1a:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801e1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e1f:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801e26:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801e2d:	00 
  801e2e:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801e30:	b8 00 00 00 00       	mov    $0x0,%eax
  801e35:	eb 0a                	jmp    801e41 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801e37:	83 c0 01             	add    $0x1,%eax
  801e3a:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801e3e:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801e41:	39 d0                	cmp    %edx,%eax
  801e43:	75 f2                	jne    801e37 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801e45:	83 ec 08             	sub    $0x8,%esp
  801e48:	56                   	push   %esi
  801e49:	ff 75 08             	pushl  0x8(%ebp)
  801e4c:	e8 53 fa ff ff       	call   8018a4 <spawn>
}
  801e51:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e54:	5b                   	pop    %ebx
  801e55:	5e                   	pop    %esi
  801e56:	5d                   	pop    %ebp
  801e57:	c3                   	ret    

00801e58 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801e58:	55                   	push   %ebp
  801e59:	89 e5                	mov    %esp,%ebp
  801e5b:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801e5e:	68 58 30 80 00       	push   $0x803058
  801e63:	ff 75 0c             	pushl  0xc(%ebp)
  801e66:	e8 f2 eb ff ff       	call   800a5d <strcpy>
	return 0;
}
  801e6b:	b8 00 00 00 00       	mov    $0x0,%eax
  801e70:	c9                   	leave  
  801e71:	c3                   	ret    

00801e72 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801e72:	55                   	push   %ebp
  801e73:	89 e5                	mov    %esp,%ebp
  801e75:	53                   	push   %ebx
  801e76:	83 ec 10             	sub    $0x10,%esp
  801e79:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801e7c:	53                   	push   %ebx
  801e7d:	e8 de 08 00 00       	call   802760 <pageref>
  801e82:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801e85:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801e8a:	83 f8 01             	cmp    $0x1,%eax
  801e8d:	75 10                	jne    801e9f <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801e8f:	83 ec 0c             	sub    $0xc,%esp
  801e92:	ff 73 0c             	pushl  0xc(%ebx)
  801e95:	e8 c0 02 00 00       	call   80215a <nsipc_close>
  801e9a:	89 c2                	mov    %eax,%edx
  801e9c:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801e9f:	89 d0                	mov    %edx,%eax
  801ea1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ea4:	c9                   	leave  
  801ea5:	c3                   	ret    

00801ea6 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801ea6:	55                   	push   %ebp
  801ea7:	89 e5                	mov    %esp,%ebp
  801ea9:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801eac:	6a 00                	push   $0x0
  801eae:	ff 75 10             	pushl  0x10(%ebp)
  801eb1:	ff 75 0c             	pushl  0xc(%ebp)
  801eb4:	8b 45 08             	mov    0x8(%ebp),%eax
  801eb7:	ff 70 0c             	pushl  0xc(%eax)
  801eba:	e8 78 03 00 00       	call   802237 <nsipc_send>
}
  801ebf:	c9                   	leave  
  801ec0:	c3                   	ret    

00801ec1 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801ec1:	55                   	push   %ebp
  801ec2:	89 e5                	mov    %esp,%ebp
  801ec4:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801ec7:	6a 00                	push   $0x0
  801ec9:	ff 75 10             	pushl  0x10(%ebp)
  801ecc:	ff 75 0c             	pushl  0xc(%ebp)
  801ecf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ed2:	ff 70 0c             	pushl  0xc(%eax)
  801ed5:	e8 f1 02 00 00       	call   8021cb <nsipc_recv>
}
  801eda:	c9                   	leave  
  801edb:	c3                   	ret    

00801edc <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801edc:	55                   	push   %ebp
  801edd:	89 e5                	mov    %esp,%ebp
  801edf:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801ee2:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801ee5:	52                   	push   %edx
  801ee6:	50                   	push   %eax
  801ee7:	e8 fa f1 ff ff       	call   8010e6 <fd_lookup>
  801eec:	83 c4 10             	add    $0x10,%esp
  801eef:	85 c0                	test   %eax,%eax
  801ef1:	78 17                	js     801f0a <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801ef3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ef6:	8b 0d ac 57 80 00    	mov    0x8057ac,%ecx
  801efc:	39 08                	cmp    %ecx,(%eax)
  801efe:	75 05                	jne    801f05 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801f00:	8b 40 0c             	mov    0xc(%eax),%eax
  801f03:	eb 05                	jmp    801f0a <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801f05:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801f0a:	c9                   	leave  
  801f0b:	c3                   	ret    

00801f0c <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801f0c:	55                   	push   %ebp
  801f0d:	89 e5                	mov    %esp,%ebp
  801f0f:	56                   	push   %esi
  801f10:	53                   	push   %ebx
  801f11:	83 ec 1c             	sub    $0x1c,%esp
  801f14:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801f16:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f19:	50                   	push   %eax
  801f1a:	e8 78 f1 ff ff       	call   801097 <fd_alloc>
  801f1f:	89 c3                	mov    %eax,%ebx
  801f21:	83 c4 10             	add    $0x10,%esp
  801f24:	85 c0                	test   %eax,%eax
  801f26:	78 1b                	js     801f43 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801f28:	83 ec 04             	sub    $0x4,%esp
  801f2b:	68 07 04 00 00       	push   $0x407
  801f30:	ff 75 f4             	pushl  -0xc(%ebp)
  801f33:	6a 00                	push   $0x0
  801f35:	e8 26 ef ff ff       	call   800e60 <sys_page_alloc>
  801f3a:	89 c3                	mov    %eax,%ebx
  801f3c:	83 c4 10             	add    $0x10,%esp
  801f3f:	85 c0                	test   %eax,%eax
  801f41:	79 10                	jns    801f53 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801f43:	83 ec 0c             	sub    $0xc,%esp
  801f46:	56                   	push   %esi
  801f47:	e8 0e 02 00 00       	call   80215a <nsipc_close>
		return r;
  801f4c:	83 c4 10             	add    $0x10,%esp
  801f4f:	89 d8                	mov    %ebx,%eax
  801f51:	eb 24                	jmp    801f77 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801f53:	8b 15 ac 57 80 00    	mov    0x8057ac,%edx
  801f59:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f5c:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801f5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f61:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801f68:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801f6b:	83 ec 0c             	sub    $0xc,%esp
  801f6e:	50                   	push   %eax
  801f6f:	e8 fc f0 ff ff       	call   801070 <fd2num>
  801f74:	83 c4 10             	add    $0x10,%esp
}
  801f77:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f7a:	5b                   	pop    %ebx
  801f7b:	5e                   	pop    %esi
  801f7c:	5d                   	pop    %ebp
  801f7d:	c3                   	ret    

00801f7e <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801f7e:	55                   	push   %ebp
  801f7f:	89 e5                	mov    %esp,%ebp
  801f81:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f84:	8b 45 08             	mov    0x8(%ebp),%eax
  801f87:	e8 50 ff ff ff       	call   801edc <fd2sockid>
		return r;
  801f8c:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f8e:	85 c0                	test   %eax,%eax
  801f90:	78 1f                	js     801fb1 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801f92:	83 ec 04             	sub    $0x4,%esp
  801f95:	ff 75 10             	pushl  0x10(%ebp)
  801f98:	ff 75 0c             	pushl  0xc(%ebp)
  801f9b:	50                   	push   %eax
  801f9c:	e8 12 01 00 00       	call   8020b3 <nsipc_accept>
  801fa1:	83 c4 10             	add    $0x10,%esp
		return r;
  801fa4:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801fa6:	85 c0                	test   %eax,%eax
  801fa8:	78 07                	js     801fb1 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801faa:	e8 5d ff ff ff       	call   801f0c <alloc_sockfd>
  801faf:	89 c1                	mov    %eax,%ecx
}
  801fb1:	89 c8                	mov    %ecx,%eax
  801fb3:	c9                   	leave  
  801fb4:	c3                   	ret    

00801fb5 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801fb5:	55                   	push   %ebp
  801fb6:	89 e5                	mov    %esp,%ebp
  801fb8:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801fbb:	8b 45 08             	mov    0x8(%ebp),%eax
  801fbe:	e8 19 ff ff ff       	call   801edc <fd2sockid>
  801fc3:	85 c0                	test   %eax,%eax
  801fc5:	78 12                	js     801fd9 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801fc7:	83 ec 04             	sub    $0x4,%esp
  801fca:	ff 75 10             	pushl  0x10(%ebp)
  801fcd:	ff 75 0c             	pushl  0xc(%ebp)
  801fd0:	50                   	push   %eax
  801fd1:	e8 2d 01 00 00       	call   802103 <nsipc_bind>
  801fd6:	83 c4 10             	add    $0x10,%esp
}
  801fd9:	c9                   	leave  
  801fda:	c3                   	ret    

00801fdb <shutdown>:

int
shutdown(int s, int how)
{
  801fdb:	55                   	push   %ebp
  801fdc:	89 e5                	mov    %esp,%ebp
  801fde:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801fe1:	8b 45 08             	mov    0x8(%ebp),%eax
  801fe4:	e8 f3 fe ff ff       	call   801edc <fd2sockid>
  801fe9:	85 c0                	test   %eax,%eax
  801feb:	78 0f                	js     801ffc <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801fed:	83 ec 08             	sub    $0x8,%esp
  801ff0:	ff 75 0c             	pushl  0xc(%ebp)
  801ff3:	50                   	push   %eax
  801ff4:	e8 3f 01 00 00       	call   802138 <nsipc_shutdown>
  801ff9:	83 c4 10             	add    $0x10,%esp
}
  801ffc:	c9                   	leave  
  801ffd:	c3                   	ret    

00801ffe <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801ffe:	55                   	push   %ebp
  801fff:	89 e5                	mov    %esp,%ebp
  802001:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802004:	8b 45 08             	mov    0x8(%ebp),%eax
  802007:	e8 d0 fe ff ff       	call   801edc <fd2sockid>
  80200c:	85 c0                	test   %eax,%eax
  80200e:	78 12                	js     802022 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  802010:	83 ec 04             	sub    $0x4,%esp
  802013:	ff 75 10             	pushl  0x10(%ebp)
  802016:	ff 75 0c             	pushl  0xc(%ebp)
  802019:	50                   	push   %eax
  80201a:	e8 55 01 00 00       	call   802174 <nsipc_connect>
  80201f:	83 c4 10             	add    $0x10,%esp
}
  802022:	c9                   	leave  
  802023:	c3                   	ret    

00802024 <listen>:

int
listen(int s, int backlog)
{
  802024:	55                   	push   %ebp
  802025:	89 e5                	mov    %esp,%ebp
  802027:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80202a:	8b 45 08             	mov    0x8(%ebp),%eax
  80202d:	e8 aa fe ff ff       	call   801edc <fd2sockid>
  802032:	85 c0                	test   %eax,%eax
  802034:	78 0f                	js     802045 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  802036:	83 ec 08             	sub    $0x8,%esp
  802039:	ff 75 0c             	pushl  0xc(%ebp)
  80203c:	50                   	push   %eax
  80203d:	e8 67 01 00 00       	call   8021a9 <nsipc_listen>
  802042:	83 c4 10             	add    $0x10,%esp
}
  802045:	c9                   	leave  
  802046:	c3                   	ret    

00802047 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  802047:	55                   	push   %ebp
  802048:	89 e5                	mov    %esp,%ebp
  80204a:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  80204d:	ff 75 10             	pushl  0x10(%ebp)
  802050:	ff 75 0c             	pushl  0xc(%ebp)
  802053:	ff 75 08             	pushl  0x8(%ebp)
  802056:	e8 3a 02 00 00       	call   802295 <nsipc_socket>
  80205b:	83 c4 10             	add    $0x10,%esp
  80205e:	85 c0                	test   %eax,%eax
  802060:	78 05                	js     802067 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  802062:	e8 a5 fe ff ff       	call   801f0c <alloc_sockfd>
}
  802067:	c9                   	leave  
  802068:	c3                   	ret    

00802069 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  802069:	55                   	push   %ebp
  80206a:	89 e5                	mov    %esp,%ebp
  80206c:	53                   	push   %ebx
  80206d:	83 ec 04             	sub    $0x4,%esp
  802070:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  802072:	83 3d 04 60 80 00 00 	cmpl   $0x0,0x806004
  802079:	75 12                	jne    80208d <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  80207b:	83 ec 0c             	sub    $0xc,%esp
  80207e:	6a 02                	push   $0x2
  802080:	e8 a2 06 00 00       	call   802727 <ipc_find_env>
  802085:	a3 04 60 80 00       	mov    %eax,0x806004
  80208a:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  80208d:	6a 07                	push   $0x7
  80208f:	68 00 90 80 00       	push   $0x809000
  802094:	53                   	push   %ebx
  802095:	ff 35 04 60 80 00    	pushl  0x806004
  80209b:	e8 33 06 00 00       	call   8026d3 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8020a0:	83 c4 0c             	add    $0xc,%esp
  8020a3:	6a 00                	push   $0x0
  8020a5:	6a 00                	push   $0x0
  8020a7:	6a 00                	push   $0x0
  8020a9:	e8 bc 05 00 00       	call   80266a <ipc_recv>
}
  8020ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020b1:	c9                   	leave  
  8020b2:	c3                   	ret    

008020b3 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8020b3:	55                   	push   %ebp
  8020b4:	89 e5                	mov    %esp,%ebp
  8020b6:	56                   	push   %esi
  8020b7:	53                   	push   %ebx
  8020b8:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8020bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8020be:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8020c3:	8b 06                	mov    (%esi),%eax
  8020c5:	a3 04 90 80 00       	mov    %eax,0x809004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8020ca:	b8 01 00 00 00       	mov    $0x1,%eax
  8020cf:	e8 95 ff ff ff       	call   802069 <nsipc>
  8020d4:	89 c3                	mov    %eax,%ebx
  8020d6:	85 c0                	test   %eax,%eax
  8020d8:	78 20                	js     8020fa <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8020da:	83 ec 04             	sub    $0x4,%esp
  8020dd:	ff 35 10 90 80 00    	pushl  0x809010
  8020e3:	68 00 90 80 00       	push   $0x809000
  8020e8:	ff 75 0c             	pushl  0xc(%ebp)
  8020eb:	e8 ff ea ff ff       	call   800bef <memmove>
		*addrlen = ret->ret_addrlen;
  8020f0:	a1 10 90 80 00       	mov    0x809010,%eax
  8020f5:	89 06                	mov    %eax,(%esi)
  8020f7:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  8020fa:	89 d8                	mov    %ebx,%eax
  8020fc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020ff:	5b                   	pop    %ebx
  802100:	5e                   	pop    %esi
  802101:	5d                   	pop    %ebp
  802102:	c3                   	ret    

00802103 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802103:	55                   	push   %ebp
  802104:	89 e5                	mov    %esp,%ebp
  802106:	53                   	push   %ebx
  802107:	83 ec 08             	sub    $0x8,%esp
  80210a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80210d:	8b 45 08             	mov    0x8(%ebp),%eax
  802110:	a3 00 90 80 00       	mov    %eax,0x809000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802115:	53                   	push   %ebx
  802116:	ff 75 0c             	pushl  0xc(%ebp)
  802119:	68 04 90 80 00       	push   $0x809004
  80211e:	e8 cc ea ff ff       	call   800bef <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802123:	89 1d 14 90 80 00    	mov    %ebx,0x809014
	return nsipc(NSREQ_BIND);
  802129:	b8 02 00 00 00       	mov    $0x2,%eax
  80212e:	e8 36 ff ff ff       	call   802069 <nsipc>
}
  802133:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802136:	c9                   	leave  
  802137:	c3                   	ret    

00802138 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  802138:	55                   	push   %ebp
  802139:	89 e5                	mov    %esp,%ebp
  80213b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  80213e:	8b 45 08             	mov    0x8(%ebp),%eax
  802141:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.shutdown.req_how = how;
  802146:	8b 45 0c             	mov    0xc(%ebp),%eax
  802149:	a3 04 90 80 00       	mov    %eax,0x809004
	return nsipc(NSREQ_SHUTDOWN);
  80214e:	b8 03 00 00 00       	mov    $0x3,%eax
  802153:	e8 11 ff ff ff       	call   802069 <nsipc>
}
  802158:	c9                   	leave  
  802159:	c3                   	ret    

0080215a <nsipc_close>:

int
nsipc_close(int s)
{
  80215a:	55                   	push   %ebp
  80215b:	89 e5                	mov    %esp,%ebp
  80215d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802160:	8b 45 08             	mov    0x8(%ebp),%eax
  802163:	a3 00 90 80 00       	mov    %eax,0x809000
	return nsipc(NSREQ_CLOSE);
  802168:	b8 04 00 00 00       	mov    $0x4,%eax
  80216d:	e8 f7 fe ff ff       	call   802069 <nsipc>
}
  802172:	c9                   	leave  
  802173:	c3                   	ret    

00802174 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802174:	55                   	push   %ebp
  802175:	89 e5                	mov    %esp,%ebp
  802177:	53                   	push   %ebx
  802178:	83 ec 08             	sub    $0x8,%esp
  80217b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80217e:	8b 45 08             	mov    0x8(%ebp),%eax
  802181:	a3 00 90 80 00       	mov    %eax,0x809000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802186:	53                   	push   %ebx
  802187:	ff 75 0c             	pushl  0xc(%ebp)
  80218a:	68 04 90 80 00       	push   $0x809004
  80218f:	e8 5b ea ff ff       	call   800bef <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  802194:	89 1d 14 90 80 00    	mov    %ebx,0x809014
	return nsipc(NSREQ_CONNECT);
  80219a:	b8 05 00 00 00       	mov    $0x5,%eax
  80219f:	e8 c5 fe ff ff       	call   802069 <nsipc>
}
  8021a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8021a7:	c9                   	leave  
  8021a8:	c3                   	ret    

008021a9 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8021a9:	55                   	push   %ebp
  8021aa:	89 e5                	mov    %esp,%ebp
  8021ac:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8021af:	8b 45 08             	mov    0x8(%ebp),%eax
  8021b2:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.listen.req_backlog = backlog;
  8021b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021ba:	a3 04 90 80 00       	mov    %eax,0x809004
	return nsipc(NSREQ_LISTEN);
  8021bf:	b8 06 00 00 00       	mov    $0x6,%eax
  8021c4:	e8 a0 fe ff ff       	call   802069 <nsipc>
}
  8021c9:	c9                   	leave  
  8021ca:	c3                   	ret    

008021cb <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8021cb:	55                   	push   %ebp
  8021cc:	89 e5                	mov    %esp,%ebp
  8021ce:	56                   	push   %esi
  8021cf:	53                   	push   %ebx
  8021d0:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8021d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8021d6:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.recv.req_len = len;
  8021db:	89 35 04 90 80 00    	mov    %esi,0x809004
	nsipcbuf.recv.req_flags = flags;
  8021e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8021e4:	a3 08 90 80 00       	mov    %eax,0x809008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8021e9:	b8 07 00 00 00       	mov    $0x7,%eax
  8021ee:	e8 76 fe ff ff       	call   802069 <nsipc>
  8021f3:	89 c3                	mov    %eax,%ebx
  8021f5:	85 c0                	test   %eax,%eax
  8021f7:	78 35                	js     80222e <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  8021f9:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8021fe:	7f 04                	jg     802204 <nsipc_recv+0x39>
  802200:	39 c6                	cmp    %eax,%esi
  802202:	7d 16                	jge    80221a <nsipc_recv+0x4f>
  802204:	68 64 30 80 00       	push   $0x803064
  802209:	68 88 2f 80 00       	push   $0x802f88
  80220e:	6a 62                	push   $0x62
  802210:	68 79 30 80 00       	push   $0x803079
  802215:	e8 e5 e1 ff ff       	call   8003ff <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  80221a:	83 ec 04             	sub    $0x4,%esp
  80221d:	50                   	push   %eax
  80221e:	68 00 90 80 00       	push   $0x809000
  802223:	ff 75 0c             	pushl  0xc(%ebp)
  802226:	e8 c4 e9 ff ff       	call   800bef <memmove>
  80222b:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  80222e:	89 d8                	mov    %ebx,%eax
  802230:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802233:	5b                   	pop    %ebx
  802234:	5e                   	pop    %esi
  802235:	5d                   	pop    %ebp
  802236:	c3                   	ret    

00802237 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802237:	55                   	push   %ebp
  802238:	89 e5                	mov    %esp,%ebp
  80223a:	53                   	push   %ebx
  80223b:	83 ec 04             	sub    $0x4,%esp
  80223e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802241:	8b 45 08             	mov    0x8(%ebp),%eax
  802244:	a3 00 90 80 00       	mov    %eax,0x809000
	assert(size < 1600);
  802249:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  80224f:	7e 16                	jle    802267 <nsipc_send+0x30>
  802251:	68 85 30 80 00       	push   $0x803085
  802256:	68 88 2f 80 00       	push   $0x802f88
  80225b:	6a 6d                	push   $0x6d
  80225d:	68 79 30 80 00       	push   $0x803079
  802262:	e8 98 e1 ff ff       	call   8003ff <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  802267:	83 ec 04             	sub    $0x4,%esp
  80226a:	53                   	push   %ebx
  80226b:	ff 75 0c             	pushl  0xc(%ebp)
  80226e:	68 0c 90 80 00       	push   $0x80900c
  802273:	e8 77 e9 ff ff       	call   800bef <memmove>
	nsipcbuf.send.req_size = size;
  802278:	89 1d 04 90 80 00    	mov    %ebx,0x809004
	nsipcbuf.send.req_flags = flags;
  80227e:	8b 45 14             	mov    0x14(%ebp),%eax
  802281:	a3 08 90 80 00       	mov    %eax,0x809008
	return nsipc(NSREQ_SEND);
  802286:	b8 08 00 00 00       	mov    $0x8,%eax
  80228b:	e8 d9 fd ff ff       	call   802069 <nsipc>
}
  802290:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802293:	c9                   	leave  
  802294:	c3                   	ret    

00802295 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  802295:	55                   	push   %ebp
  802296:	89 e5                	mov    %esp,%ebp
  802298:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80229b:	8b 45 08             	mov    0x8(%ebp),%eax
  80229e:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.socket.req_type = type;
  8022a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022a6:	a3 04 90 80 00       	mov    %eax,0x809004
	nsipcbuf.socket.req_protocol = protocol;
  8022ab:	8b 45 10             	mov    0x10(%ebp),%eax
  8022ae:	a3 08 90 80 00       	mov    %eax,0x809008
	return nsipc(NSREQ_SOCKET);
  8022b3:	b8 09 00 00 00       	mov    $0x9,%eax
  8022b8:	e8 ac fd ff ff       	call   802069 <nsipc>
}
  8022bd:	c9                   	leave  
  8022be:	c3                   	ret    

008022bf <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8022bf:	55                   	push   %ebp
  8022c0:	89 e5                	mov    %esp,%ebp
  8022c2:	56                   	push   %esi
  8022c3:	53                   	push   %ebx
  8022c4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8022c7:	83 ec 0c             	sub    $0xc,%esp
  8022ca:	ff 75 08             	pushl  0x8(%ebp)
  8022cd:	e8 ae ed ff ff       	call   801080 <fd2data>
  8022d2:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8022d4:	83 c4 08             	add    $0x8,%esp
  8022d7:	68 91 30 80 00       	push   $0x803091
  8022dc:	53                   	push   %ebx
  8022dd:	e8 7b e7 ff ff       	call   800a5d <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8022e2:	8b 46 04             	mov    0x4(%esi),%eax
  8022e5:	2b 06                	sub    (%esi),%eax
  8022e7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8022ed:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8022f4:	00 00 00 
	stat->st_dev = &devpipe;
  8022f7:	c7 83 88 00 00 00 c8 	movl   $0x8057c8,0x88(%ebx)
  8022fe:	57 80 00 
	return 0;
}
  802301:	b8 00 00 00 00       	mov    $0x0,%eax
  802306:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802309:	5b                   	pop    %ebx
  80230a:	5e                   	pop    %esi
  80230b:	5d                   	pop    %ebp
  80230c:	c3                   	ret    

0080230d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80230d:	55                   	push   %ebp
  80230e:	89 e5                	mov    %esp,%ebp
  802310:	53                   	push   %ebx
  802311:	83 ec 0c             	sub    $0xc,%esp
  802314:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802317:	53                   	push   %ebx
  802318:	6a 00                	push   $0x0
  80231a:	e8 c6 eb ff ff       	call   800ee5 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80231f:	89 1c 24             	mov    %ebx,(%esp)
  802322:	e8 59 ed ff ff       	call   801080 <fd2data>
  802327:	83 c4 08             	add    $0x8,%esp
  80232a:	50                   	push   %eax
  80232b:	6a 00                	push   $0x0
  80232d:	e8 b3 eb ff ff       	call   800ee5 <sys_page_unmap>
}
  802332:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802335:	c9                   	leave  
  802336:	c3                   	ret    

00802337 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802337:	55                   	push   %ebp
  802338:	89 e5                	mov    %esp,%ebp
  80233a:	57                   	push   %edi
  80233b:	56                   	push   %esi
  80233c:	53                   	push   %ebx
  80233d:	83 ec 1c             	sub    $0x1c,%esp
  802340:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802343:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802345:	a1 90 77 80 00       	mov    0x807790,%eax
  80234a:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80234d:	83 ec 0c             	sub    $0xc,%esp
  802350:	ff 75 e0             	pushl  -0x20(%ebp)
  802353:	e8 08 04 00 00       	call   802760 <pageref>
  802358:	89 c3                	mov    %eax,%ebx
  80235a:	89 3c 24             	mov    %edi,(%esp)
  80235d:	e8 fe 03 00 00       	call   802760 <pageref>
  802362:	83 c4 10             	add    $0x10,%esp
  802365:	39 c3                	cmp    %eax,%ebx
  802367:	0f 94 c1             	sete   %cl
  80236a:	0f b6 c9             	movzbl %cl,%ecx
  80236d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  802370:	8b 15 90 77 80 00    	mov    0x807790,%edx
  802376:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802379:	39 ce                	cmp    %ecx,%esi
  80237b:	74 1b                	je     802398 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80237d:	39 c3                	cmp    %eax,%ebx
  80237f:	75 c4                	jne    802345 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802381:	8b 42 58             	mov    0x58(%edx),%eax
  802384:	ff 75 e4             	pushl  -0x1c(%ebp)
  802387:	50                   	push   %eax
  802388:	56                   	push   %esi
  802389:	68 98 30 80 00       	push   $0x803098
  80238e:	e8 45 e1 ff ff       	call   8004d8 <cprintf>
  802393:	83 c4 10             	add    $0x10,%esp
  802396:	eb ad                	jmp    802345 <_pipeisclosed+0xe>
	}
}
  802398:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80239b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80239e:	5b                   	pop    %ebx
  80239f:	5e                   	pop    %esi
  8023a0:	5f                   	pop    %edi
  8023a1:	5d                   	pop    %ebp
  8023a2:	c3                   	ret    

008023a3 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8023a3:	55                   	push   %ebp
  8023a4:	89 e5                	mov    %esp,%ebp
  8023a6:	57                   	push   %edi
  8023a7:	56                   	push   %esi
  8023a8:	53                   	push   %ebx
  8023a9:	83 ec 28             	sub    $0x28,%esp
  8023ac:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8023af:	56                   	push   %esi
  8023b0:	e8 cb ec ff ff       	call   801080 <fd2data>
  8023b5:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8023b7:	83 c4 10             	add    $0x10,%esp
  8023ba:	bf 00 00 00 00       	mov    $0x0,%edi
  8023bf:	eb 4b                	jmp    80240c <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8023c1:	89 da                	mov    %ebx,%edx
  8023c3:	89 f0                	mov    %esi,%eax
  8023c5:	e8 6d ff ff ff       	call   802337 <_pipeisclosed>
  8023ca:	85 c0                	test   %eax,%eax
  8023cc:	75 48                	jne    802416 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8023ce:	e8 6e ea ff ff       	call   800e41 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8023d3:	8b 43 04             	mov    0x4(%ebx),%eax
  8023d6:	8b 0b                	mov    (%ebx),%ecx
  8023d8:	8d 51 20             	lea    0x20(%ecx),%edx
  8023db:	39 d0                	cmp    %edx,%eax
  8023dd:	73 e2                	jae    8023c1 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8023df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8023e2:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8023e6:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8023e9:	89 c2                	mov    %eax,%edx
  8023eb:	c1 fa 1f             	sar    $0x1f,%edx
  8023ee:	89 d1                	mov    %edx,%ecx
  8023f0:	c1 e9 1b             	shr    $0x1b,%ecx
  8023f3:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8023f6:	83 e2 1f             	and    $0x1f,%edx
  8023f9:	29 ca                	sub    %ecx,%edx
  8023fb:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8023ff:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802403:	83 c0 01             	add    $0x1,%eax
  802406:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802409:	83 c7 01             	add    $0x1,%edi
  80240c:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80240f:	75 c2                	jne    8023d3 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802411:	8b 45 10             	mov    0x10(%ebp),%eax
  802414:	eb 05                	jmp    80241b <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802416:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80241b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80241e:	5b                   	pop    %ebx
  80241f:	5e                   	pop    %esi
  802420:	5f                   	pop    %edi
  802421:	5d                   	pop    %ebp
  802422:	c3                   	ret    

00802423 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802423:	55                   	push   %ebp
  802424:	89 e5                	mov    %esp,%ebp
  802426:	57                   	push   %edi
  802427:	56                   	push   %esi
  802428:	53                   	push   %ebx
  802429:	83 ec 18             	sub    $0x18,%esp
  80242c:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80242f:	57                   	push   %edi
  802430:	e8 4b ec ff ff       	call   801080 <fd2data>
  802435:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802437:	83 c4 10             	add    $0x10,%esp
  80243a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80243f:	eb 3d                	jmp    80247e <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802441:	85 db                	test   %ebx,%ebx
  802443:	74 04                	je     802449 <devpipe_read+0x26>
				return i;
  802445:	89 d8                	mov    %ebx,%eax
  802447:	eb 44                	jmp    80248d <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802449:	89 f2                	mov    %esi,%edx
  80244b:	89 f8                	mov    %edi,%eax
  80244d:	e8 e5 fe ff ff       	call   802337 <_pipeisclosed>
  802452:	85 c0                	test   %eax,%eax
  802454:	75 32                	jne    802488 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802456:	e8 e6 e9 ff ff       	call   800e41 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80245b:	8b 06                	mov    (%esi),%eax
  80245d:	3b 46 04             	cmp    0x4(%esi),%eax
  802460:	74 df                	je     802441 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802462:	99                   	cltd   
  802463:	c1 ea 1b             	shr    $0x1b,%edx
  802466:	01 d0                	add    %edx,%eax
  802468:	83 e0 1f             	and    $0x1f,%eax
  80246b:	29 d0                	sub    %edx,%eax
  80246d:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802472:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802475:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802478:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80247b:	83 c3 01             	add    $0x1,%ebx
  80247e:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802481:	75 d8                	jne    80245b <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802483:	8b 45 10             	mov    0x10(%ebp),%eax
  802486:	eb 05                	jmp    80248d <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802488:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80248d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802490:	5b                   	pop    %ebx
  802491:	5e                   	pop    %esi
  802492:	5f                   	pop    %edi
  802493:	5d                   	pop    %ebp
  802494:	c3                   	ret    

00802495 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802495:	55                   	push   %ebp
  802496:	89 e5                	mov    %esp,%ebp
  802498:	56                   	push   %esi
  802499:	53                   	push   %ebx
  80249a:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80249d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024a0:	50                   	push   %eax
  8024a1:	e8 f1 eb ff ff       	call   801097 <fd_alloc>
  8024a6:	83 c4 10             	add    $0x10,%esp
  8024a9:	89 c2                	mov    %eax,%edx
  8024ab:	85 c0                	test   %eax,%eax
  8024ad:	0f 88 2c 01 00 00    	js     8025df <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8024b3:	83 ec 04             	sub    $0x4,%esp
  8024b6:	68 07 04 00 00       	push   $0x407
  8024bb:	ff 75 f4             	pushl  -0xc(%ebp)
  8024be:	6a 00                	push   $0x0
  8024c0:	e8 9b e9 ff ff       	call   800e60 <sys_page_alloc>
  8024c5:	83 c4 10             	add    $0x10,%esp
  8024c8:	89 c2                	mov    %eax,%edx
  8024ca:	85 c0                	test   %eax,%eax
  8024cc:	0f 88 0d 01 00 00    	js     8025df <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8024d2:	83 ec 0c             	sub    $0xc,%esp
  8024d5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8024d8:	50                   	push   %eax
  8024d9:	e8 b9 eb ff ff       	call   801097 <fd_alloc>
  8024de:	89 c3                	mov    %eax,%ebx
  8024e0:	83 c4 10             	add    $0x10,%esp
  8024e3:	85 c0                	test   %eax,%eax
  8024e5:	0f 88 e2 00 00 00    	js     8025cd <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8024eb:	83 ec 04             	sub    $0x4,%esp
  8024ee:	68 07 04 00 00       	push   $0x407
  8024f3:	ff 75 f0             	pushl  -0x10(%ebp)
  8024f6:	6a 00                	push   $0x0
  8024f8:	e8 63 e9 ff ff       	call   800e60 <sys_page_alloc>
  8024fd:	89 c3                	mov    %eax,%ebx
  8024ff:	83 c4 10             	add    $0x10,%esp
  802502:	85 c0                	test   %eax,%eax
  802504:	0f 88 c3 00 00 00    	js     8025cd <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80250a:	83 ec 0c             	sub    $0xc,%esp
  80250d:	ff 75 f4             	pushl  -0xc(%ebp)
  802510:	e8 6b eb ff ff       	call   801080 <fd2data>
  802515:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802517:	83 c4 0c             	add    $0xc,%esp
  80251a:	68 07 04 00 00       	push   $0x407
  80251f:	50                   	push   %eax
  802520:	6a 00                	push   $0x0
  802522:	e8 39 e9 ff ff       	call   800e60 <sys_page_alloc>
  802527:	89 c3                	mov    %eax,%ebx
  802529:	83 c4 10             	add    $0x10,%esp
  80252c:	85 c0                	test   %eax,%eax
  80252e:	0f 88 89 00 00 00    	js     8025bd <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802534:	83 ec 0c             	sub    $0xc,%esp
  802537:	ff 75 f0             	pushl  -0x10(%ebp)
  80253a:	e8 41 eb ff ff       	call   801080 <fd2data>
  80253f:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802546:	50                   	push   %eax
  802547:	6a 00                	push   $0x0
  802549:	56                   	push   %esi
  80254a:	6a 00                	push   $0x0
  80254c:	e8 52 e9 ff ff       	call   800ea3 <sys_page_map>
  802551:	89 c3                	mov    %eax,%ebx
  802553:	83 c4 20             	add    $0x20,%esp
  802556:	85 c0                	test   %eax,%eax
  802558:	78 55                	js     8025af <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80255a:	8b 15 c8 57 80 00    	mov    0x8057c8,%edx
  802560:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802563:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802565:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802568:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80256f:	8b 15 c8 57 80 00    	mov    0x8057c8,%edx
  802575:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802578:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80257a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80257d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802584:	83 ec 0c             	sub    $0xc,%esp
  802587:	ff 75 f4             	pushl  -0xc(%ebp)
  80258a:	e8 e1 ea ff ff       	call   801070 <fd2num>
  80258f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802592:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802594:	83 c4 04             	add    $0x4,%esp
  802597:	ff 75 f0             	pushl  -0x10(%ebp)
  80259a:	e8 d1 ea ff ff       	call   801070 <fd2num>
  80259f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8025a2:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8025a5:	83 c4 10             	add    $0x10,%esp
  8025a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8025ad:	eb 30                	jmp    8025df <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8025af:	83 ec 08             	sub    $0x8,%esp
  8025b2:	56                   	push   %esi
  8025b3:	6a 00                	push   $0x0
  8025b5:	e8 2b e9 ff ff       	call   800ee5 <sys_page_unmap>
  8025ba:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8025bd:	83 ec 08             	sub    $0x8,%esp
  8025c0:	ff 75 f0             	pushl  -0x10(%ebp)
  8025c3:	6a 00                	push   $0x0
  8025c5:	e8 1b e9 ff ff       	call   800ee5 <sys_page_unmap>
  8025ca:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8025cd:	83 ec 08             	sub    $0x8,%esp
  8025d0:	ff 75 f4             	pushl  -0xc(%ebp)
  8025d3:	6a 00                	push   $0x0
  8025d5:	e8 0b e9 ff ff       	call   800ee5 <sys_page_unmap>
  8025da:	83 c4 10             	add    $0x10,%esp
  8025dd:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8025df:	89 d0                	mov    %edx,%eax
  8025e1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8025e4:	5b                   	pop    %ebx
  8025e5:	5e                   	pop    %esi
  8025e6:	5d                   	pop    %ebp
  8025e7:	c3                   	ret    

008025e8 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8025e8:	55                   	push   %ebp
  8025e9:	89 e5                	mov    %esp,%ebp
  8025eb:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8025ee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8025f1:	50                   	push   %eax
  8025f2:	ff 75 08             	pushl  0x8(%ebp)
  8025f5:	e8 ec ea ff ff       	call   8010e6 <fd_lookup>
  8025fa:	83 c4 10             	add    $0x10,%esp
  8025fd:	85 c0                	test   %eax,%eax
  8025ff:	78 18                	js     802619 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802601:	83 ec 0c             	sub    $0xc,%esp
  802604:	ff 75 f4             	pushl  -0xc(%ebp)
  802607:	e8 74 ea ff ff       	call   801080 <fd2data>
	return _pipeisclosed(fd, p);
  80260c:	89 c2                	mov    %eax,%edx
  80260e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802611:	e8 21 fd ff ff       	call   802337 <_pipeisclosed>
  802616:	83 c4 10             	add    $0x10,%esp
}
  802619:	c9                   	leave  
  80261a:	c3                   	ret    

0080261b <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  80261b:	55                   	push   %ebp
  80261c:	89 e5                	mov    %esp,%ebp
  80261e:	56                   	push   %esi
  80261f:	53                   	push   %ebx
  802620:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802623:	85 f6                	test   %esi,%esi
  802625:	75 16                	jne    80263d <wait+0x22>
  802627:	68 b0 30 80 00       	push   $0x8030b0
  80262c:	68 88 2f 80 00       	push   $0x802f88
  802631:	6a 09                	push   $0x9
  802633:	68 bb 30 80 00       	push   $0x8030bb
  802638:	e8 c2 dd ff ff       	call   8003ff <_panic>
	e = &envs[ENVX(envid)];
  80263d:	89 f3                	mov    %esi,%ebx
  80263f:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802645:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  802648:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  80264e:	eb 05                	jmp    802655 <wait+0x3a>
		sys_yield();
  802650:	e8 ec e7 ff ff       	call   800e41 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802655:	8b 43 48             	mov    0x48(%ebx),%eax
  802658:	39 c6                	cmp    %eax,%esi
  80265a:	75 07                	jne    802663 <wait+0x48>
  80265c:	8b 43 54             	mov    0x54(%ebx),%eax
  80265f:	85 c0                	test   %eax,%eax
  802661:	75 ed                	jne    802650 <wait+0x35>
		sys_yield();
}
  802663:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802666:	5b                   	pop    %ebx
  802667:	5e                   	pop    %esi
  802668:	5d                   	pop    %ebp
  802669:	c3                   	ret    

0080266a <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80266a:	55                   	push   %ebp
  80266b:	89 e5                	mov    %esp,%ebp
  80266d:	56                   	push   %esi
  80266e:	53                   	push   %ebx
  80266f:	8b 75 08             	mov    0x8(%ebp),%esi
  802672:	8b 45 0c             	mov    0xc(%ebp),%eax
  802675:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  802678:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  80267a:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  80267f:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  802682:	83 ec 0c             	sub    $0xc,%esp
  802685:	50                   	push   %eax
  802686:	e8 85 e9 ff ff       	call   801010 <sys_ipc_recv>

	if (r < 0) {
  80268b:	83 c4 10             	add    $0x10,%esp
  80268e:	85 c0                	test   %eax,%eax
  802690:	79 16                	jns    8026a8 <ipc_recv+0x3e>
		if (from_env_store)
  802692:	85 f6                	test   %esi,%esi
  802694:	74 06                	je     80269c <ipc_recv+0x32>
			*from_env_store = 0;
  802696:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  80269c:	85 db                	test   %ebx,%ebx
  80269e:	74 2c                	je     8026cc <ipc_recv+0x62>
			*perm_store = 0;
  8026a0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8026a6:	eb 24                	jmp    8026cc <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  8026a8:	85 f6                	test   %esi,%esi
  8026aa:	74 0a                	je     8026b6 <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  8026ac:	a1 90 77 80 00       	mov    0x807790,%eax
  8026b1:	8b 40 74             	mov    0x74(%eax),%eax
  8026b4:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  8026b6:	85 db                	test   %ebx,%ebx
  8026b8:	74 0a                	je     8026c4 <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  8026ba:	a1 90 77 80 00       	mov    0x807790,%eax
  8026bf:	8b 40 78             	mov    0x78(%eax),%eax
  8026c2:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  8026c4:	a1 90 77 80 00       	mov    0x807790,%eax
  8026c9:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  8026cc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8026cf:	5b                   	pop    %ebx
  8026d0:	5e                   	pop    %esi
  8026d1:	5d                   	pop    %ebp
  8026d2:	c3                   	ret    

008026d3 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8026d3:	55                   	push   %ebp
  8026d4:	89 e5                	mov    %esp,%ebp
  8026d6:	57                   	push   %edi
  8026d7:	56                   	push   %esi
  8026d8:	53                   	push   %ebx
  8026d9:	83 ec 0c             	sub    $0xc,%esp
  8026dc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8026df:	8b 75 0c             	mov    0xc(%ebp),%esi
  8026e2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  8026e5:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  8026e7:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  8026ec:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  8026ef:	ff 75 14             	pushl  0x14(%ebp)
  8026f2:	53                   	push   %ebx
  8026f3:	56                   	push   %esi
  8026f4:	57                   	push   %edi
  8026f5:	e8 f3 e8 ff ff       	call   800fed <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  8026fa:	83 c4 10             	add    $0x10,%esp
  8026fd:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802700:	75 07                	jne    802709 <ipc_send+0x36>
			sys_yield();
  802702:	e8 3a e7 ff ff       	call   800e41 <sys_yield>
  802707:	eb e6                	jmp    8026ef <ipc_send+0x1c>
		} else if (r < 0) {
  802709:	85 c0                	test   %eax,%eax
  80270b:	79 12                	jns    80271f <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  80270d:	50                   	push   %eax
  80270e:	68 c6 30 80 00       	push   $0x8030c6
  802713:	6a 51                	push   $0x51
  802715:	68 d3 30 80 00       	push   $0x8030d3
  80271a:	e8 e0 dc ff ff       	call   8003ff <_panic>
		}
	}
}
  80271f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802722:	5b                   	pop    %ebx
  802723:	5e                   	pop    %esi
  802724:	5f                   	pop    %edi
  802725:	5d                   	pop    %ebp
  802726:	c3                   	ret    

00802727 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802727:	55                   	push   %ebp
  802728:	89 e5                	mov    %esp,%ebp
  80272a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80272d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802732:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802735:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80273b:	8b 52 50             	mov    0x50(%edx),%edx
  80273e:	39 ca                	cmp    %ecx,%edx
  802740:	75 0d                	jne    80274f <ipc_find_env+0x28>
			return envs[i].env_id;
  802742:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802745:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80274a:	8b 40 48             	mov    0x48(%eax),%eax
  80274d:	eb 0f                	jmp    80275e <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80274f:	83 c0 01             	add    $0x1,%eax
  802752:	3d 00 04 00 00       	cmp    $0x400,%eax
  802757:	75 d9                	jne    802732 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802759:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80275e:	5d                   	pop    %ebp
  80275f:	c3                   	ret    

00802760 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802760:	55                   	push   %ebp
  802761:	89 e5                	mov    %esp,%ebp
  802763:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802766:	89 d0                	mov    %edx,%eax
  802768:	c1 e8 16             	shr    $0x16,%eax
  80276b:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802772:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802777:	f6 c1 01             	test   $0x1,%cl
  80277a:	74 1d                	je     802799 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80277c:	c1 ea 0c             	shr    $0xc,%edx
  80277f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802786:	f6 c2 01             	test   $0x1,%dl
  802789:	74 0e                	je     802799 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80278b:	c1 ea 0c             	shr    $0xc,%edx
  80278e:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802795:	ef 
  802796:	0f b7 c0             	movzwl %ax,%eax
}
  802799:	5d                   	pop    %ebp
  80279a:	c3                   	ret    
  80279b:	66 90                	xchg   %ax,%ax
  80279d:	66 90                	xchg   %ax,%ax
  80279f:	90                   	nop

008027a0 <__udivdi3>:
  8027a0:	55                   	push   %ebp
  8027a1:	57                   	push   %edi
  8027a2:	56                   	push   %esi
  8027a3:	53                   	push   %ebx
  8027a4:	83 ec 1c             	sub    $0x1c,%esp
  8027a7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8027ab:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8027af:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8027b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8027b7:	85 f6                	test   %esi,%esi
  8027b9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8027bd:	89 ca                	mov    %ecx,%edx
  8027bf:	89 f8                	mov    %edi,%eax
  8027c1:	75 3d                	jne    802800 <__udivdi3+0x60>
  8027c3:	39 cf                	cmp    %ecx,%edi
  8027c5:	0f 87 c5 00 00 00    	ja     802890 <__udivdi3+0xf0>
  8027cb:	85 ff                	test   %edi,%edi
  8027cd:	89 fd                	mov    %edi,%ebp
  8027cf:	75 0b                	jne    8027dc <__udivdi3+0x3c>
  8027d1:	b8 01 00 00 00       	mov    $0x1,%eax
  8027d6:	31 d2                	xor    %edx,%edx
  8027d8:	f7 f7                	div    %edi
  8027da:	89 c5                	mov    %eax,%ebp
  8027dc:	89 c8                	mov    %ecx,%eax
  8027de:	31 d2                	xor    %edx,%edx
  8027e0:	f7 f5                	div    %ebp
  8027e2:	89 c1                	mov    %eax,%ecx
  8027e4:	89 d8                	mov    %ebx,%eax
  8027e6:	89 cf                	mov    %ecx,%edi
  8027e8:	f7 f5                	div    %ebp
  8027ea:	89 c3                	mov    %eax,%ebx
  8027ec:	89 d8                	mov    %ebx,%eax
  8027ee:	89 fa                	mov    %edi,%edx
  8027f0:	83 c4 1c             	add    $0x1c,%esp
  8027f3:	5b                   	pop    %ebx
  8027f4:	5e                   	pop    %esi
  8027f5:	5f                   	pop    %edi
  8027f6:	5d                   	pop    %ebp
  8027f7:	c3                   	ret    
  8027f8:	90                   	nop
  8027f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802800:	39 ce                	cmp    %ecx,%esi
  802802:	77 74                	ja     802878 <__udivdi3+0xd8>
  802804:	0f bd fe             	bsr    %esi,%edi
  802807:	83 f7 1f             	xor    $0x1f,%edi
  80280a:	0f 84 98 00 00 00    	je     8028a8 <__udivdi3+0x108>
  802810:	bb 20 00 00 00       	mov    $0x20,%ebx
  802815:	89 f9                	mov    %edi,%ecx
  802817:	89 c5                	mov    %eax,%ebp
  802819:	29 fb                	sub    %edi,%ebx
  80281b:	d3 e6                	shl    %cl,%esi
  80281d:	89 d9                	mov    %ebx,%ecx
  80281f:	d3 ed                	shr    %cl,%ebp
  802821:	89 f9                	mov    %edi,%ecx
  802823:	d3 e0                	shl    %cl,%eax
  802825:	09 ee                	or     %ebp,%esi
  802827:	89 d9                	mov    %ebx,%ecx
  802829:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80282d:	89 d5                	mov    %edx,%ebp
  80282f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802833:	d3 ed                	shr    %cl,%ebp
  802835:	89 f9                	mov    %edi,%ecx
  802837:	d3 e2                	shl    %cl,%edx
  802839:	89 d9                	mov    %ebx,%ecx
  80283b:	d3 e8                	shr    %cl,%eax
  80283d:	09 c2                	or     %eax,%edx
  80283f:	89 d0                	mov    %edx,%eax
  802841:	89 ea                	mov    %ebp,%edx
  802843:	f7 f6                	div    %esi
  802845:	89 d5                	mov    %edx,%ebp
  802847:	89 c3                	mov    %eax,%ebx
  802849:	f7 64 24 0c          	mull   0xc(%esp)
  80284d:	39 d5                	cmp    %edx,%ebp
  80284f:	72 10                	jb     802861 <__udivdi3+0xc1>
  802851:	8b 74 24 08          	mov    0x8(%esp),%esi
  802855:	89 f9                	mov    %edi,%ecx
  802857:	d3 e6                	shl    %cl,%esi
  802859:	39 c6                	cmp    %eax,%esi
  80285b:	73 07                	jae    802864 <__udivdi3+0xc4>
  80285d:	39 d5                	cmp    %edx,%ebp
  80285f:	75 03                	jne    802864 <__udivdi3+0xc4>
  802861:	83 eb 01             	sub    $0x1,%ebx
  802864:	31 ff                	xor    %edi,%edi
  802866:	89 d8                	mov    %ebx,%eax
  802868:	89 fa                	mov    %edi,%edx
  80286a:	83 c4 1c             	add    $0x1c,%esp
  80286d:	5b                   	pop    %ebx
  80286e:	5e                   	pop    %esi
  80286f:	5f                   	pop    %edi
  802870:	5d                   	pop    %ebp
  802871:	c3                   	ret    
  802872:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802878:	31 ff                	xor    %edi,%edi
  80287a:	31 db                	xor    %ebx,%ebx
  80287c:	89 d8                	mov    %ebx,%eax
  80287e:	89 fa                	mov    %edi,%edx
  802880:	83 c4 1c             	add    $0x1c,%esp
  802883:	5b                   	pop    %ebx
  802884:	5e                   	pop    %esi
  802885:	5f                   	pop    %edi
  802886:	5d                   	pop    %ebp
  802887:	c3                   	ret    
  802888:	90                   	nop
  802889:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802890:	89 d8                	mov    %ebx,%eax
  802892:	f7 f7                	div    %edi
  802894:	31 ff                	xor    %edi,%edi
  802896:	89 c3                	mov    %eax,%ebx
  802898:	89 d8                	mov    %ebx,%eax
  80289a:	89 fa                	mov    %edi,%edx
  80289c:	83 c4 1c             	add    $0x1c,%esp
  80289f:	5b                   	pop    %ebx
  8028a0:	5e                   	pop    %esi
  8028a1:	5f                   	pop    %edi
  8028a2:	5d                   	pop    %ebp
  8028a3:	c3                   	ret    
  8028a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8028a8:	39 ce                	cmp    %ecx,%esi
  8028aa:	72 0c                	jb     8028b8 <__udivdi3+0x118>
  8028ac:	31 db                	xor    %ebx,%ebx
  8028ae:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8028b2:	0f 87 34 ff ff ff    	ja     8027ec <__udivdi3+0x4c>
  8028b8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8028bd:	e9 2a ff ff ff       	jmp    8027ec <__udivdi3+0x4c>
  8028c2:	66 90                	xchg   %ax,%ax
  8028c4:	66 90                	xchg   %ax,%ax
  8028c6:	66 90                	xchg   %ax,%ax
  8028c8:	66 90                	xchg   %ax,%ax
  8028ca:	66 90                	xchg   %ax,%ax
  8028cc:	66 90                	xchg   %ax,%ax
  8028ce:	66 90                	xchg   %ax,%ax

008028d0 <__umoddi3>:
  8028d0:	55                   	push   %ebp
  8028d1:	57                   	push   %edi
  8028d2:	56                   	push   %esi
  8028d3:	53                   	push   %ebx
  8028d4:	83 ec 1c             	sub    $0x1c,%esp
  8028d7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8028db:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8028df:	8b 74 24 34          	mov    0x34(%esp),%esi
  8028e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8028e7:	85 d2                	test   %edx,%edx
  8028e9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8028ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8028f1:	89 f3                	mov    %esi,%ebx
  8028f3:	89 3c 24             	mov    %edi,(%esp)
  8028f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8028fa:	75 1c                	jne    802918 <__umoddi3+0x48>
  8028fc:	39 f7                	cmp    %esi,%edi
  8028fe:	76 50                	jbe    802950 <__umoddi3+0x80>
  802900:	89 c8                	mov    %ecx,%eax
  802902:	89 f2                	mov    %esi,%edx
  802904:	f7 f7                	div    %edi
  802906:	89 d0                	mov    %edx,%eax
  802908:	31 d2                	xor    %edx,%edx
  80290a:	83 c4 1c             	add    $0x1c,%esp
  80290d:	5b                   	pop    %ebx
  80290e:	5e                   	pop    %esi
  80290f:	5f                   	pop    %edi
  802910:	5d                   	pop    %ebp
  802911:	c3                   	ret    
  802912:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802918:	39 f2                	cmp    %esi,%edx
  80291a:	89 d0                	mov    %edx,%eax
  80291c:	77 52                	ja     802970 <__umoddi3+0xa0>
  80291e:	0f bd ea             	bsr    %edx,%ebp
  802921:	83 f5 1f             	xor    $0x1f,%ebp
  802924:	75 5a                	jne    802980 <__umoddi3+0xb0>
  802926:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80292a:	0f 82 e0 00 00 00    	jb     802a10 <__umoddi3+0x140>
  802930:	39 0c 24             	cmp    %ecx,(%esp)
  802933:	0f 86 d7 00 00 00    	jbe    802a10 <__umoddi3+0x140>
  802939:	8b 44 24 08          	mov    0x8(%esp),%eax
  80293d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802941:	83 c4 1c             	add    $0x1c,%esp
  802944:	5b                   	pop    %ebx
  802945:	5e                   	pop    %esi
  802946:	5f                   	pop    %edi
  802947:	5d                   	pop    %ebp
  802948:	c3                   	ret    
  802949:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802950:	85 ff                	test   %edi,%edi
  802952:	89 fd                	mov    %edi,%ebp
  802954:	75 0b                	jne    802961 <__umoddi3+0x91>
  802956:	b8 01 00 00 00       	mov    $0x1,%eax
  80295b:	31 d2                	xor    %edx,%edx
  80295d:	f7 f7                	div    %edi
  80295f:	89 c5                	mov    %eax,%ebp
  802961:	89 f0                	mov    %esi,%eax
  802963:	31 d2                	xor    %edx,%edx
  802965:	f7 f5                	div    %ebp
  802967:	89 c8                	mov    %ecx,%eax
  802969:	f7 f5                	div    %ebp
  80296b:	89 d0                	mov    %edx,%eax
  80296d:	eb 99                	jmp    802908 <__umoddi3+0x38>
  80296f:	90                   	nop
  802970:	89 c8                	mov    %ecx,%eax
  802972:	89 f2                	mov    %esi,%edx
  802974:	83 c4 1c             	add    $0x1c,%esp
  802977:	5b                   	pop    %ebx
  802978:	5e                   	pop    %esi
  802979:	5f                   	pop    %edi
  80297a:	5d                   	pop    %ebp
  80297b:	c3                   	ret    
  80297c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802980:	8b 34 24             	mov    (%esp),%esi
  802983:	bf 20 00 00 00       	mov    $0x20,%edi
  802988:	89 e9                	mov    %ebp,%ecx
  80298a:	29 ef                	sub    %ebp,%edi
  80298c:	d3 e0                	shl    %cl,%eax
  80298e:	89 f9                	mov    %edi,%ecx
  802990:	89 f2                	mov    %esi,%edx
  802992:	d3 ea                	shr    %cl,%edx
  802994:	89 e9                	mov    %ebp,%ecx
  802996:	09 c2                	or     %eax,%edx
  802998:	89 d8                	mov    %ebx,%eax
  80299a:	89 14 24             	mov    %edx,(%esp)
  80299d:	89 f2                	mov    %esi,%edx
  80299f:	d3 e2                	shl    %cl,%edx
  8029a1:	89 f9                	mov    %edi,%ecx
  8029a3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8029a7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8029ab:	d3 e8                	shr    %cl,%eax
  8029ad:	89 e9                	mov    %ebp,%ecx
  8029af:	89 c6                	mov    %eax,%esi
  8029b1:	d3 e3                	shl    %cl,%ebx
  8029b3:	89 f9                	mov    %edi,%ecx
  8029b5:	89 d0                	mov    %edx,%eax
  8029b7:	d3 e8                	shr    %cl,%eax
  8029b9:	89 e9                	mov    %ebp,%ecx
  8029bb:	09 d8                	or     %ebx,%eax
  8029bd:	89 d3                	mov    %edx,%ebx
  8029bf:	89 f2                	mov    %esi,%edx
  8029c1:	f7 34 24             	divl   (%esp)
  8029c4:	89 d6                	mov    %edx,%esi
  8029c6:	d3 e3                	shl    %cl,%ebx
  8029c8:	f7 64 24 04          	mull   0x4(%esp)
  8029cc:	39 d6                	cmp    %edx,%esi
  8029ce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8029d2:	89 d1                	mov    %edx,%ecx
  8029d4:	89 c3                	mov    %eax,%ebx
  8029d6:	72 08                	jb     8029e0 <__umoddi3+0x110>
  8029d8:	75 11                	jne    8029eb <__umoddi3+0x11b>
  8029da:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8029de:	73 0b                	jae    8029eb <__umoddi3+0x11b>
  8029e0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8029e4:	1b 14 24             	sbb    (%esp),%edx
  8029e7:	89 d1                	mov    %edx,%ecx
  8029e9:	89 c3                	mov    %eax,%ebx
  8029eb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8029ef:	29 da                	sub    %ebx,%edx
  8029f1:	19 ce                	sbb    %ecx,%esi
  8029f3:	89 f9                	mov    %edi,%ecx
  8029f5:	89 f0                	mov    %esi,%eax
  8029f7:	d3 e0                	shl    %cl,%eax
  8029f9:	89 e9                	mov    %ebp,%ecx
  8029fb:	d3 ea                	shr    %cl,%edx
  8029fd:	89 e9                	mov    %ebp,%ecx
  8029ff:	d3 ee                	shr    %cl,%esi
  802a01:	09 d0                	or     %edx,%eax
  802a03:	89 f2                	mov    %esi,%edx
  802a05:	83 c4 1c             	add    $0x1c,%esp
  802a08:	5b                   	pop    %ebx
  802a09:	5e                   	pop    %esi
  802a0a:	5f                   	pop    %edi
  802a0b:	5d                   	pop    %ebp
  802a0c:	c3                   	ret    
  802a0d:	8d 76 00             	lea    0x0(%esi),%esi
  802a10:	29 f9                	sub    %edi,%ecx
  802a12:	19 d6                	sbb    %edx,%esi
  802a14:	89 74 24 04          	mov    %esi,0x4(%esp)
  802a18:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802a1c:	e9 18 ff ff ff       	jmp    802939 <__umoddi3+0x69>
