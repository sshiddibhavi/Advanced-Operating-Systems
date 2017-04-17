
obj/user/sh.debug:     file format elf32-i386


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
  80002c:	e8 84 09 00 00       	call   8009b5 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <_gettoken>:
#define WHITESPACE " \t\r\n"
#define SYMBOLS "<|>&;()"

int
_gettoken(char *s, char **p1, char **p2)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 0c             	sub    $0xc,%esp
  80003c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80003f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int t;

	if (s == 0) {
  800042:	85 db                	test   %ebx,%ebx
  800044:	75 2c                	jne    800072 <_gettoken+0x3f>
		if (debug > 1)
			cprintf("GETTOKEN NULL\n");
		return 0;
  800046:	b8 00 00 00 00       	mov    $0x0,%eax
_gettoken(char *s, char **p1, char **p2)
{
	int t;

	if (s == 0) {
		if (debug > 1)
  80004b:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800052:	0f 8e 3e 01 00 00    	jle    800196 <_gettoken+0x163>
			cprintf("GETTOKEN NULL\n");
  800058:	83 ec 0c             	sub    $0xc,%esp
  80005b:	68 c0 36 80 00       	push   $0x8036c0
  800060:	e8 89 0a 00 00       	call   800aee <cprintf>
  800065:	83 c4 10             	add    $0x10,%esp
		return 0;
  800068:	b8 00 00 00 00       	mov    $0x0,%eax
  80006d:	e9 24 01 00 00       	jmp    800196 <_gettoken+0x163>
	}

	if (debug > 1)
  800072:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800079:	7e 11                	jle    80008c <_gettoken+0x59>
		cprintf("GETTOKEN: %s\n", s);
  80007b:	83 ec 08             	sub    $0x8,%esp
  80007e:	53                   	push   %ebx
  80007f:	68 cf 36 80 00       	push   $0x8036cf
  800084:	e8 65 0a 00 00       	call   800aee <cprintf>
  800089:	83 c4 10             	add    $0x10,%esp

	*p1 = 0;
  80008c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	*p2 = 0;
  800092:	8b 45 10             	mov    0x10(%ebp),%eax
  800095:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	while (strchr(WHITESPACE, *s))
  80009b:	eb 07                	jmp    8000a4 <_gettoken+0x71>
		*s++ = 0;
  80009d:	83 c3 01             	add    $0x1,%ebx
  8000a0:	c6 43 ff 00          	movb   $0x0,-0x1(%ebx)
		cprintf("GETTOKEN: %s\n", s);

	*p1 = 0;
	*p2 = 0;

	while (strchr(WHITESPACE, *s))
  8000a4:	83 ec 08             	sub    $0x8,%esp
  8000a7:	0f be 03             	movsbl (%ebx),%eax
  8000aa:	50                   	push   %eax
  8000ab:	68 dd 36 80 00       	push   $0x8036dd
  8000b0:	e8 b9 11 00 00       	call   80126e <strchr>
  8000b5:	83 c4 10             	add    $0x10,%esp
  8000b8:	85 c0                	test   %eax,%eax
  8000ba:	75 e1                	jne    80009d <_gettoken+0x6a>
		*s++ = 0;
	if (*s == 0) {
  8000bc:	0f b6 03             	movzbl (%ebx),%eax
  8000bf:	84 c0                	test   %al,%al
  8000c1:	75 2c                	jne    8000ef <_gettoken+0xbc>
		if (debug > 1)
			cprintf("EOL\n");
		return 0;
  8000c3:	b8 00 00 00 00       	mov    $0x0,%eax
	*p2 = 0;

	while (strchr(WHITESPACE, *s))
		*s++ = 0;
	if (*s == 0) {
		if (debug > 1)
  8000c8:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  8000cf:	0f 8e c1 00 00 00    	jle    800196 <_gettoken+0x163>
			cprintf("EOL\n");
  8000d5:	83 ec 0c             	sub    $0xc,%esp
  8000d8:	68 e2 36 80 00       	push   $0x8036e2
  8000dd:	e8 0c 0a 00 00       	call   800aee <cprintf>
  8000e2:	83 c4 10             	add    $0x10,%esp
		return 0;
  8000e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ea:	e9 a7 00 00 00       	jmp    800196 <_gettoken+0x163>
	}
	if (strchr(SYMBOLS, *s)) {
  8000ef:	83 ec 08             	sub    $0x8,%esp
  8000f2:	0f be c0             	movsbl %al,%eax
  8000f5:	50                   	push   %eax
  8000f6:	68 f3 36 80 00       	push   $0x8036f3
  8000fb:	e8 6e 11 00 00       	call   80126e <strchr>
  800100:	83 c4 10             	add    $0x10,%esp
  800103:	85 c0                	test   %eax,%eax
  800105:	74 30                	je     800137 <_gettoken+0x104>
		t = *s;
  800107:	0f be 3b             	movsbl (%ebx),%edi
		*p1 = s;
  80010a:	89 1e                	mov    %ebx,(%esi)
		*s++ = 0;
  80010c:	c6 03 00             	movb   $0x0,(%ebx)
		*p2 = s;
  80010f:	83 c3 01             	add    $0x1,%ebx
  800112:	8b 45 10             	mov    0x10(%ebp),%eax
  800115:	89 18                	mov    %ebx,(%eax)
		if (debug > 1)
			cprintf("TOK %c\n", t);
		return t;
  800117:	89 f8                	mov    %edi,%eax
	if (strchr(SYMBOLS, *s)) {
		t = *s;
		*p1 = s;
		*s++ = 0;
		*p2 = s;
		if (debug > 1)
  800119:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800120:	7e 74                	jle    800196 <_gettoken+0x163>
			cprintf("TOK %c\n", t);
  800122:	83 ec 08             	sub    $0x8,%esp
  800125:	57                   	push   %edi
  800126:	68 e7 36 80 00       	push   $0x8036e7
  80012b:	e8 be 09 00 00       	call   800aee <cprintf>
  800130:	83 c4 10             	add    $0x10,%esp
		return t;
  800133:	89 f8                	mov    %edi,%eax
  800135:	eb 5f                	jmp    800196 <_gettoken+0x163>
	}
	*p1 = s;
  800137:	89 1e                	mov    %ebx,(%esi)
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
  800139:	eb 03                	jmp    80013e <_gettoken+0x10b>
		s++;
  80013b:	83 c3 01             	add    $0x1,%ebx
		if (debug > 1)
			cprintf("TOK %c\n", t);
		return t;
	}
	*p1 = s;
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
  80013e:	0f b6 03             	movzbl (%ebx),%eax
  800141:	84 c0                	test   %al,%al
  800143:	74 18                	je     80015d <_gettoken+0x12a>
  800145:	83 ec 08             	sub    $0x8,%esp
  800148:	0f be c0             	movsbl %al,%eax
  80014b:	50                   	push   %eax
  80014c:	68 ef 36 80 00       	push   $0x8036ef
  800151:	e8 18 11 00 00       	call   80126e <strchr>
  800156:	83 c4 10             	add    $0x10,%esp
  800159:	85 c0                	test   %eax,%eax
  80015b:	74 de                	je     80013b <_gettoken+0x108>
		s++;
	*p2 = s;
  80015d:	8b 45 10             	mov    0x10(%ebp),%eax
  800160:	89 18                	mov    %ebx,(%eax)
		t = **p2;
		**p2 = 0;
		cprintf("WORD: %s\n", *p1);
		**p2 = t;
	}
	return 'w';
  800162:	b8 77 00 00 00       	mov    $0x77,%eax
	}
	*p1 = s;
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
		s++;
	*p2 = s;
	if (debug > 1) {
  800167:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  80016e:	7e 26                	jle    800196 <_gettoken+0x163>
		t = **p2;
  800170:	0f b6 3b             	movzbl (%ebx),%edi
		**p2 = 0;
  800173:	c6 03 00             	movb   $0x0,(%ebx)
		cprintf("WORD: %s\n", *p1);
  800176:	83 ec 08             	sub    $0x8,%esp
  800179:	ff 36                	pushl  (%esi)
  80017b:	68 fb 36 80 00       	push   $0x8036fb
  800180:	e8 69 09 00 00       	call   800aee <cprintf>
		**p2 = t;
  800185:	8b 45 10             	mov    0x10(%ebp),%eax
  800188:	8b 00                	mov    (%eax),%eax
  80018a:	89 fa                	mov    %edi,%edx
  80018c:	88 10                	mov    %dl,(%eax)
  80018e:	83 c4 10             	add    $0x10,%esp
	}
	return 'w';
  800191:	b8 77 00 00 00       	mov    $0x77,%eax
}
  800196:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800199:	5b                   	pop    %ebx
  80019a:	5e                   	pop    %esi
  80019b:	5f                   	pop    %edi
  80019c:	5d                   	pop    %ebp
  80019d:	c3                   	ret    

0080019e <gettoken>:

int
gettoken(char *s, char **p1)
{
  80019e:	55                   	push   %ebp
  80019f:	89 e5                	mov    %esp,%ebp
  8001a1:	83 ec 08             	sub    $0x8,%esp
  8001a4:	8b 45 08             	mov    0x8(%ebp),%eax
	static int c, nc;
	static char* np1, *np2;

	if (s) {
  8001a7:	85 c0                	test   %eax,%eax
  8001a9:	74 22                	je     8001cd <gettoken+0x2f>
		nc = _gettoken(s, &np1, &np2);
  8001ab:	83 ec 04             	sub    $0x4,%esp
  8001ae:	68 0c 50 80 00       	push   $0x80500c
  8001b3:	68 10 50 80 00       	push   $0x805010
  8001b8:	50                   	push   %eax
  8001b9:	e8 75 fe ff ff       	call   800033 <_gettoken>
  8001be:	a3 08 50 80 00       	mov    %eax,0x805008
		return 0;
  8001c3:	83 c4 10             	add    $0x10,%esp
  8001c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8001cb:	eb 3a                	jmp    800207 <gettoken+0x69>
	}
	c = nc;
  8001cd:	a1 08 50 80 00       	mov    0x805008,%eax
  8001d2:	a3 04 50 80 00       	mov    %eax,0x805004
	*p1 = np1;
  8001d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001da:	8b 15 10 50 80 00    	mov    0x805010,%edx
  8001e0:	89 10                	mov    %edx,(%eax)
	nc = _gettoken(np2, &np1, &np2);
  8001e2:	83 ec 04             	sub    $0x4,%esp
  8001e5:	68 0c 50 80 00       	push   $0x80500c
  8001ea:	68 10 50 80 00       	push   $0x805010
  8001ef:	ff 35 0c 50 80 00    	pushl  0x80500c
  8001f5:	e8 39 fe ff ff       	call   800033 <_gettoken>
  8001fa:	a3 08 50 80 00       	mov    %eax,0x805008
	return c;
  8001ff:	a1 04 50 80 00       	mov    0x805004,%eax
  800204:	83 c4 10             	add    $0x10,%esp
}
  800207:	c9                   	leave  
  800208:	c3                   	ret    

00800209 <runcmd>:
// runcmd() is called in a forked child,
// so it's OK to manipulate file descriptor state.
#define MAXARGS 16
void
runcmd(char* s)
{
  800209:	55                   	push   %ebp
  80020a:	89 e5                	mov    %esp,%ebp
  80020c:	57                   	push   %edi
  80020d:	56                   	push   %esi
  80020e:	53                   	push   %ebx
  80020f:	81 ec 64 04 00 00    	sub    $0x464,%esp
	char *argv[MAXARGS], *t, argv0buf[BUFSIZ];
	int argc, c, i, r, p[2], fd, pipe_child;

	pipe_child = 0;
	gettoken(s, 0);
  800215:	6a 00                	push   $0x0
  800217:	ff 75 08             	pushl  0x8(%ebp)
  80021a:	e8 7f ff ff ff       	call   80019e <gettoken>
  80021f:	83 c4 10             	add    $0x10,%esp

again:
	argc = 0;
	while (1) {
		switch ((c = gettoken(0, &t))) {
  800222:	8d 5d a4             	lea    -0x5c(%ebp),%ebx

	pipe_child = 0;
	gettoken(s, 0);

again:
	argc = 0;
  800225:	be 00 00 00 00       	mov    $0x0,%esi
	while (1) {
		switch ((c = gettoken(0, &t))) {
  80022a:	83 ec 08             	sub    $0x8,%esp
  80022d:	53                   	push   %ebx
  80022e:	6a 00                	push   $0x0
  800230:	e8 69 ff ff ff       	call   80019e <gettoken>
  800235:	83 c4 10             	add    $0x10,%esp
  800238:	83 f8 3e             	cmp    $0x3e,%eax
  80023b:	0f 84 cc 00 00 00    	je     80030d <runcmd+0x104>
  800241:	83 f8 3e             	cmp    $0x3e,%eax
  800244:	7f 12                	jg     800258 <runcmd+0x4f>
  800246:	85 c0                	test   %eax,%eax
  800248:	0f 84 3b 02 00 00    	je     800489 <runcmd+0x280>
  80024e:	83 f8 3c             	cmp    $0x3c,%eax
  800251:	74 3e                	je     800291 <runcmd+0x88>
  800253:	e9 1f 02 00 00       	jmp    800477 <runcmd+0x26e>
  800258:	83 f8 77             	cmp    $0x77,%eax
  80025b:	74 0e                	je     80026b <runcmd+0x62>
  80025d:	83 f8 7c             	cmp    $0x7c,%eax
  800260:	0f 84 25 01 00 00    	je     80038b <runcmd+0x182>
  800266:	e9 0c 02 00 00       	jmp    800477 <runcmd+0x26e>

		case 'w':	// Add an argument
			if (argc == MAXARGS) {
  80026b:	83 fe 10             	cmp    $0x10,%esi
  80026e:	75 15                	jne    800285 <runcmd+0x7c>
				cprintf("too many arguments\n");
  800270:	83 ec 0c             	sub    $0xc,%esp
  800273:	68 05 37 80 00       	push   $0x803705
  800278:	e8 71 08 00 00       	call   800aee <cprintf>
				exit();
  80027d:	e8 79 07 00 00       	call   8009fb <exit>
  800282:	83 c4 10             	add    $0x10,%esp
			}
			argv[argc++] = t;
  800285:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  800288:	89 44 b5 a8          	mov    %eax,-0x58(%ebp,%esi,4)
  80028c:	8d 76 01             	lea    0x1(%esi),%esi
			break;
  80028f:	eb 99                	jmp    80022a <runcmd+0x21>

		case '<':	// Input redirection
			// Grab the filename from the argument list
			if (gettoken(0, &t) != 'w') {
  800291:	83 ec 08             	sub    $0x8,%esp
  800294:	53                   	push   %ebx
  800295:	6a 00                	push   $0x0
  800297:	e8 02 ff ff ff       	call   80019e <gettoken>
  80029c:	83 c4 10             	add    $0x10,%esp
  80029f:	83 f8 77             	cmp    $0x77,%eax
  8002a2:	74 15                	je     8002b9 <runcmd+0xb0>
				cprintf("syntax error: < not followed by word\n");
  8002a4:	83 ec 0c             	sub    $0xc,%esp
  8002a7:	68 50 38 80 00       	push   $0x803850
  8002ac:	e8 3d 08 00 00       	call   800aee <cprintf>
				exit();
  8002b1:	e8 45 07 00 00       	call   8009fb <exit>
  8002b6:	83 c4 10             	add    $0x10,%esp
			// then check whether 'fd' is 0.
			// If not, dup 'fd' onto file descriptor 0,
			// then close the original 'fd'.

			// LAB 5: Your code here.
			if ((fd = open(t, O_RDONLY)) < 0){
  8002b9:	83 ec 08             	sub    $0x8,%esp
  8002bc:	6a 00                	push   $0x0
  8002be:	ff 75 a4             	pushl  -0x5c(%ebp)
  8002c1:	e8 40 20 00 00       	call   802306 <open>
  8002c6:	89 c7                	mov    %eax,%edi
  8002c8:	83 c4 10             	add    $0x10,%esp
  8002cb:	85 c0                	test   %eax,%eax
  8002cd:	79 1b                	jns    8002ea <runcmd+0xe1>
				cprintf("open %s for read: %e", t, fd);
  8002cf:	83 ec 04             	sub    $0x4,%esp
  8002d2:	50                   	push   %eax
  8002d3:	ff 75 a4             	pushl  -0x5c(%ebp)
  8002d6:	68 19 37 80 00       	push   $0x803719
  8002db:	e8 0e 08 00 00       	call   800aee <cprintf>
				exit();
  8002e0:	e8 16 07 00 00       	call   8009fb <exit>
  8002e5:	83 c4 10             	add    $0x10,%esp
  8002e8:	eb 08                	jmp    8002f2 <runcmd+0xe9>
			}
			if (fd != 0) {
  8002ea:	85 c0                	test   %eax,%eax
  8002ec:	0f 84 38 ff ff ff    	je     80022a <runcmd+0x21>
				dup(fd, 0);
  8002f2:	83 ec 08             	sub    $0x8,%esp
  8002f5:	6a 00                	push   $0x0
  8002f7:	57                   	push   %edi
  8002f8:	e8 69 1a 00 00       	call   801d66 <dup>
				close(fd);
  8002fd:	89 3c 24             	mov    %edi,(%esp)
  800300:	e8 11 1a 00 00       	call   801d16 <close>
  800305:	83 c4 10             	add    $0x10,%esp
  800308:	e9 1d ff ff ff       	jmp    80022a <runcmd+0x21>
			//panic("< redirection not implemented");
			break;

		case '>':	// Output redirection
			// Grab the filename from the argument list
			if (gettoken(0, &t) != 'w') {
  80030d:	83 ec 08             	sub    $0x8,%esp
  800310:	53                   	push   %ebx
  800311:	6a 00                	push   $0x0
  800313:	e8 86 fe ff ff       	call   80019e <gettoken>
  800318:	83 c4 10             	add    $0x10,%esp
  80031b:	83 f8 77             	cmp    $0x77,%eax
  80031e:	74 15                	je     800335 <runcmd+0x12c>
				cprintf("syntax error: > not followed by word\n");
  800320:	83 ec 0c             	sub    $0xc,%esp
  800323:	68 78 38 80 00       	push   $0x803878
  800328:	e8 c1 07 00 00       	call   800aee <cprintf>
				exit();
  80032d:	e8 c9 06 00 00       	call   8009fb <exit>
  800332:	83 c4 10             	add    $0x10,%esp
			}
			if ((fd = open(t, O_WRONLY|O_CREAT|O_TRUNC)) < 0) {
  800335:	83 ec 08             	sub    $0x8,%esp
  800338:	68 01 03 00 00       	push   $0x301
  80033d:	ff 75 a4             	pushl  -0x5c(%ebp)
  800340:	e8 c1 1f 00 00       	call   802306 <open>
  800345:	89 c7                	mov    %eax,%edi
  800347:	83 c4 10             	add    $0x10,%esp
  80034a:	85 c0                	test   %eax,%eax
  80034c:	79 19                	jns    800367 <runcmd+0x15e>
				cprintf("open %s for write: %e", t, fd);
  80034e:	83 ec 04             	sub    $0x4,%esp
  800351:	50                   	push   %eax
  800352:	ff 75 a4             	pushl  -0x5c(%ebp)
  800355:	68 2e 37 80 00       	push   $0x80372e
  80035a:	e8 8f 07 00 00       	call   800aee <cprintf>
				exit();
  80035f:	e8 97 06 00 00       	call   8009fb <exit>
  800364:	83 c4 10             	add    $0x10,%esp
			}
			if (fd != 1) {
  800367:	83 ff 01             	cmp    $0x1,%edi
  80036a:	0f 84 ba fe ff ff    	je     80022a <runcmd+0x21>
				dup(fd, 1);
  800370:	83 ec 08             	sub    $0x8,%esp
  800373:	6a 01                	push   $0x1
  800375:	57                   	push   %edi
  800376:	e8 eb 19 00 00       	call   801d66 <dup>
				close(fd);
  80037b:	89 3c 24             	mov    %edi,(%esp)
  80037e:	e8 93 19 00 00       	call   801d16 <close>
  800383:	83 c4 10             	add    $0x10,%esp
  800386:	e9 9f fe ff ff       	jmp    80022a <runcmd+0x21>
			}
			break;

		case '|':	// Pipe
			if ((r = pipe(p)) < 0) {
  80038b:	83 ec 0c             	sub    $0xc,%esp
  80038e:	8d 85 9c fb ff ff    	lea    -0x464(%ebp),%eax
  800394:	50                   	push   %eax
  800395:	e8 11 2d 00 00       	call   8030ab <pipe>
  80039a:	83 c4 10             	add    $0x10,%esp
  80039d:	85 c0                	test   %eax,%eax
  80039f:	79 16                	jns    8003b7 <runcmd+0x1ae>
				cprintf("pipe: %e", r);
  8003a1:	83 ec 08             	sub    $0x8,%esp
  8003a4:	50                   	push   %eax
  8003a5:	68 44 37 80 00       	push   $0x803744
  8003aa:	e8 3f 07 00 00       	call   800aee <cprintf>
				exit();
  8003af:	e8 47 06 00 00       	call   8009fb <exit>
  8003b4:	83 c4 10             	add    $0x10,%esp
			}
			if (debug)
  8003b7:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8003be:	74 1c                	je     8003dc <runcmd+0x1d3>
				cprintf("PIPE: %d %d\n", p[0], p[1]);
  8003c0:	83 ec 04             	sub    $0x4,%esp
  8003c3:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  8003c9:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  8003cf:	68 4d 37 80 00       	push   $0x80374d
  8003d4:	e8 15 07 00 00       	call   800aee <cprintf>
  8003d9:	83 c4 10             	add    $0x10,%esp
			if ((r = fork()) < 0) {
  8003dc:	e8 4c 15 00 00       	call   80192d <fork>
  8003e1:	89 c7                	mov    %eax,%edi
  8003e3:	85 c0                	test   %eax,%eax
  8003e5:	79 16                	jns    8003fd <runcmd+0x1f4>
				cprintf("fork: %e", r);
  8003e7:	83 ec 08             	sub    $0x8,%esp
  8003ea:	50                   	push   %eax
  8003eb:	68 83 3c 80 00       	push   $0x803c83
  8003f0:	e8 f9 06 00 00       	call   800aee <cprintf>
				exit();
  8003f5:	e8 01 06 00 00       	call   8009fb <exit>
  8003fa:	83 c4 10             	add    $0x10,%esp
			}
			if (r == 0) {
  8003fd:	85 ff                	test   %edi,%edi
  8003ff:	75 3c                	jne    80043d <runcmd+0x234>
				if (p[0] != 0) {
  800401:	8b 85 9c fb ff ff    	mov    -0x464(%ebp),%eax
  800407:	85 c0                	test   %eax,%eax
  800409:	74 1c                	je     800427 <runcmd+0x21e>
					dup(p[0], 0);
  80040b:	83 ec 08             	sub    $0x8,%esp
  80040e:	6a 00                	push   $0x0
  800410:	50                   	push   %eax
  800411:	e8 50 19 00 00       	call   801d66 <dup>
					close(p[0]);
  800416:	83 c4 04             	add    $0x4,%esp
  800419:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  80041f:	e8 f2 18 00 00       	call   801d16 <close>
  800424:	83 c4 10             	add    $0x10,%esp
				}
				close(p[1]);
  800427:	83 ec 0c             	sub    $0xc,%esp
  80042a:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  800430:	e8 e1 18 00 00       	call   801d16 <close>
				goto again;
  800435:	83 c4 10             	add    $0x10,%esp
  800438:	e9 e8 fd ff ff       	jmp    800225 <runcmd+0x1c>
			} else {
				pipe_child = r;
				if (p[1] != 1) {
  80043d:	8b 85 a0 fb ff ff    	mov    -0x460(%ebp),%eax
  800443:	83 f8 01             	cmp    $0x1,%eax
  800446:	74 1c                	je     800464 <runcmd+0x25b>
					dup(p[1], 1);
  800448:	83 ec 08             	sub    $0x8,%esp
  80044b:	6a 01                	push   $0x1
  80044d:	50                   	push   %eax
  80044e:	e8 13 19 00 00       	call   801d66 <dup>
					close(p[1]);
  800453:	83 c4 04             	add    $0x4,%esp
  800456:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  80045c:	e8 b5 18 00 00       	call   801d16 <close>
  800461:	83 c4 10             	add    $0x10,%esp
				}
				close(p[0]);
  800464:	83 ec 0c             	sub    $0xc,%esp
  800467:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  80046d:	e8 a4 18 00 00       	call   801d16 <close>
				goto runit;
  800472:	83 c4 10             	add    $0x10,%esp
  800475:	eb 17                	jmp    80048e <runcmd+0x285>
		case 0:		// String is complete
			// Run the current command!
			goto runit;

		default:
			panic("bad return %d from gettoken", c);
  800477:	50                   	push   %eax
  800478:	68 5a 37 80 00       	push   $0x80375a
  80047d:	6a 78                	push   $0x78
  80047f:	68 76 37 80 00       	push   $0x803776
  800484:	e8 8c 05 00 00       	call   800a15 <_panic>
runcmd(char* s)
{
	char *argv[MAXARGS], *t, argv0buf[BUFSIZ];
	int argc, c, i, r, p[2], fd, pipe_child;

	pipe_child = 0;
  800489:	bf 00 00 00 00       	mov    $0x0,%edi
		}
	}

runit:
	// Return immediately if command line was empty.
	if(argc == 0) {
  80048e:	85 f6                	test   %esi,%esi
  800490:	75 22                	jne    8004b4 <runcmd+0x2ab>
		if (debug)
  800492:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800499:	0f 84 96 01 00 00    	je     800635 <runcmd+0x42c>
			cprintf("EMPTY COMMAND\n");
  80049f:	83 ec 0c             	sub    $0xc,%esp
  8004a2:	68 80 37 80 00       	push   $0x803780
  8004a7:	e8 42 06 00 00       	call   800aee <cprintf>
  8004ac:	83 c4 10             	add    $0x10,%esp
  8004af:	e9 81 01 00 00       	jmp    800635 <runcmd+0x42c>

	// Clean up command line.
	// Read all commands from the filesystem: add an initial '/' to
	// the command name.
	// This essentially acts like 'PATH=/'.
	if (argv[0][0] != '/') {
  8004b4:	8b 45 a8             	mov    -0x58(%ebp),%eax
  8004b7:	80 38 2f             	cmpb   $0x2f,(%eax)
  8004ba:	74 23                	je     8004df <runcmd+0x2d6>
		argv0buf[0] = '/';
  8004bc:	c6 85 a4 fb ff ff 2f 	movb   $0x2f,-0x45c(%ebp)
		strcpy(argv0buf + 1, argv[0]);
  8004c3:	83 ec 08             	sub    $0x8,%esp
  8004c6:	50                   	push   %eax
  8004c7:	8d 9d a4 fb ff ff    	lea    -0x45c(%ebp),%ebx
  8004cd:	8d 85 a5 fb ff ff    	lea    -0x45b(%ebp),%eax
  8004d3:	50                   	push   %eax
  8004d4:	e8 8d 0c 00 00       	call   801166 <strcpy>
		argv[0] = argv0buf;
  8004d9:	89 5d a8             	mov    %ebx,-0x58(%ebp)
  8004dc:	83 c4 10             	add    $0x10,%esp
	}
	argv[argc] = 0;
  8004df:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
  8004e6:	00 

	// Print the command.
	if (debug) {
  8004e7:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8004ee:	74 49                	je     800539 <runcmd+0x330>
		cprintf("[%08x] SPAWN:", thisenv->env_id);
  8004f0:	a1 28 54 80 00       	mov    0x805428,%eax
  8004f5:	8b 40 48             	mov    0x48(%eax),%eax
  8004f8:	83 ec 08             	sub    $0x8,%esp
  8004fb:	50                   	push   %eax
  8004fc:	68 8f 37 80 00       	push   $0x80378f
  800501:	e8 e8 05 00 00       	call   800aee <cprintf>
  800506:	8d 5d a8             	lea    -0x58(%ebp),%ebx
		for (i = 0; argv[i]; i++)
  800509:	83 c4 10             	add    $0x10,%esp
  80050c:	eb 11                	jmp    80051f <runcmd+0x316>
			cprintf(" %s", argv[i]);
  80050e:	83 ec 08             	sub    $0x8,%esp
  800511:	50                   	push   %eax
  800512:	68 17 38 80 00       	push   $0x803817
  800517:	e8 d2 05 00 00       	call   800aee <cprintf>
  80051c:	83 c4 10             	add    $0x10,%esp
  80051f:	83 c3 04             	add    $0x4,%ebx
	argv[argc] = 0;

	// Print the command.
	if (debug) {
		cprintf("[%08x] SPAWN:", thisenv->env_id);
		for (i = 0; argv[i]; i++)
  800522:	8b 43 fc             	mov    -0x4(%ebx),%eax
  800525:	85 c0                	test   %eax,%eax
  800527:	75 e5                	jne    80050e <runcmd+0x305>
			cprintf(" %s", argv[i]);
		cprintf("\n");
  800529:	83 ec 0c             	sub    $0xc,%esp
  80052c:	68 e0 36 80 00       	push   $0x8036e0
  800531:	e8 b8 05 00 00       	call   800aee <cprintf>
  800536:	83 c4 10             	add    $0x10,%esp
	}

	// Spawn the command!
	if ((r = spawn(argv[0], (const char**) argv)) < 0)
  800539:	83 ec 08             	sub    $0x8,%esp
  80053c:	8d 45 a8             	lea    -0x58(%ebp),%eax
  80053f:	50                   	push   %eax
  800540:	ff 75 a8             	pushl  -0x58(%ebp)
  800543:	e8 72 1f 00 00       	call   8024ba <spawn>
  800548:	89 c3                	mov    %eax,%ebx
  80054a:	83 c4 10             	add    $0x10,%esp
  80054d:	85 c0                	test   %eax,%eax
  80054f:	0f 89 c3 00 00 00    	jns    800618 <runcmd+0x40f>
		cprintf("spawn %s: %e\n", argv[0], r);
  800555:	83 ec 04             	sub    $0x4,%esp
  800558:	50                   	push   %eax
  800559:	ff 75 a8             	pushl  -0x58(%ebp)
  80055c:	68 9d 37 80 00       	push   $0x80379d
  800561:	e8 88 05 00 00       	call   800aee <cprintf>

	// In the parent, close all file descriptors and wait for the
	// spawned command to exit.
	close_all();
  800566:	e8 d6 17 00 00       	call   801d41 <close_all>
  80056b:	83 c4 10             	add    $0x10,%esp
  80056e:	eb 4c                	jmp    8005bc <runcmd+0x3b3>
	if (r >= 0) {
		if (debug)
			cprintf("[%08x] WAIT %s %08x\n", thisenv->env_id, argv[0], r);
  800570:	a1 28 54 80 00       	mov    0x805428,%eax
  800575:	8b 40 48             	mov    0x48(%eax),%eax
  800578:	53                   	push   %ebx
  800579:	ff 75 a8             	pushl  -0x58(%ebp)
  80057c:	50                   	push   %eax
  80057d:	68 ab 37 80 00       	push   $0x8037ab
  800582:	e8 67 05 00 00       	call   800aee <cprintf>
  800587:	83 c4 10             	add    $0x10,%esp
		wait(r);
  80058a:	83 ec 0c             	sub    $0xc,%esp
  80058d:	53                   	push   %ebx
  80058e:	e8 9e 2c 00 00       	call   803231 <wait>
		if (debug)
  800593:	83 c4 10             	add    $0x10,%esp
  800596:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80059d:	0f 84 8c 00 00 00    	je     80062f <runcmd+0x426>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  8005a3:	a1 28 54 80 00       	mov    0x805428,%eax
  8005a8:	8b 40 48             	mov    0x48(%eax),%eax
  8005ab:	83 ec 08             	sub    $0x8,%esp
  8005ae:	50                   	push   %eax
  8005af:	68 c0 37 80 00       	push   $0x8037c0
  8005b4:	e8 35 05 00 00       	call   800aee <cprintf>
  8005b9:	83 c4 10             	add    $0x10,%esp
	}

	// If we were the left-hand part of a pipe,
	// wait for the right-hand part to finish.
	if (pipe_child) {
  8005bc:	85 ff                	test   %edi,%edi
  8005be:	74 51                	je     800611 <runcmd+0x408>
		if (debug)
  8005c0:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8005c7:	74 1a                	je     8005e3 <runcmd+0x3da>
			cprintf("[%08x] WAIT pipe_child %08x\n", thisenv->env_id, pipe_child);
  8005c9:	a1 28 54 80 00       	mov    0x805428,%eax
  8005ce:	8b 40 48             	mov    0x48(%eax),%eax
  8005d1:	83 ec 04             	sub    $0x4,%esp
  8005d4:	57                   	push   %edi
  8005d5:	50                   	push   %eax
  8005d6:	68 d6 37 80 00       	push   $0x8037d6
  8005db:	e8 0e 05 00 00       	call   800aee <cprintf>
  8005e0:	83 c4 10             	add    $0x10,%esp
		wait(pipe_child);
  8005e3:	83 ec 0c             	sub    $0xc,%esp
  8005e6:	57                   	push   %edi
  8005e7:	e8 45 2c 00 00       	call   803231 <wait>
		if (debug)
  8005ec:	83 c4 10             	add    $0x10,%esp
  8005ef:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8005f6:	74 19                	je     800611 <runcmd+0x408>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  8005f8:	a1 28 54 80 00       	mov    0x805428,%eax
  8005fd:	8b 40 48             	mov    0x48(%eax),%eax
  800600:	83 ec 08             	sub    $0x8,%esp
  800603:	50                   	push   %eax
  800604:	68 c0 37 80 00       	push   $0x8037c0
  800609:	e8 e0 04 00 00       	call   800aee <cprintf>
  80060e:	83 c4 10             	add    $0x10,%esp
	}

	// Done!
	exit();
  800611:	e8 e5 03 00 00       	call   8009fb <exit>
  800616:	eb 1d                	jmp    800635 <runcmd+0x42c>
	if ((r = spawn(argv[0], (const char**) argv)) < 0)
		cprintf("spawn %s: %e\n", argv[0], r);

	// In the parent, close all file descriptors and wait for the
	// spawned command to exit.
	close_all();
  800618:	e8 24 17 00 00       	call   801d41 <close_all>
	if (r >= 0) {
		if (debug)
  80061d:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800624:	0f 84 60 ff ff ff    	je     80058a <runcmd+0x381>
  80062a:	e9 41 ff ff ff       	jmp    800570 <runcmd+0x367>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
	}

	// If we were the left-hand part of a pipe,
	// wait for the right-hand part to finish.
	if (pipe_child) {
  80062f:	85 ff                	test   %edi,%edi
  800631:	75 b0                	jne    8005e3 <runcmd+0x3da>
  800633:	eb dc                	jmp    800611 <runcmd+0x408>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
	}

	// Done!
	exit();
}
  800635:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800638:	5b                   	pop    %ebx
  800639:	5e                   	pop    %esi
  80063a:	5f                   	pop    %edi
  80063b:	5d                   	pop    %ebp
  80063c:	c3                   	ret    

0080063d <usage>:
}


void
usage(void)
{
  80063d:	55                   	push   %ebp
  80063e:	89 e5                	mov    %esp,%ebp
  800640:	83 ec 14             	sub    $0x14,%esp
	cprintf("usage: sh [-dix] [command-file]\n");
  800643:	68 a0 38 80 00       	push   $0x8038a0
  800648:	e8 a1 04 00 00       	call   800aee <cprintf>
	exit();
  80064d:	e8 a9 03 00 00       	call   8009fb <exit>
}
  800652:	83 c4 10             	add    $0x10,%esp
  800655:	c9                   	leave  
  800656:	c3                   	ret    

00800657 <umain>:

void
umain(int argc, char **argv)
{
  800657:	55                   	push   %ebp
  800658:	89 e5                	mov    %esp,%ebp
  80065a:	57                   	push   %edi
  80065b:	56                   	push   %esi
  80065c:	53                   	push   %ebx
  80065d:	83 ec 30             	sub    $0x30,%esp
  800660:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
	argstart(&argc, argv, &args);
  800663:	8d 45 d8             	lea    -0x28(%ebp),%eax
  800666:	50                   	push   %eax
  800667:	57                   	push   %edi
  800668:	8d 45 08             	lea    0x8(%ebp),%eax
  80066b:	50                   	push   %eax
  80066c:	e8 b1 13 00 00       	call   801a22 <argstart>
	while ((r = argnext(&args)) >= 0)
  800671:	83 c4 10             	add    $0x10,%esp
{
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
  800674:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
umain(int argc, char **argv)
{
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
  80067b:	be 3f 00 00 00       	mov    $0x3f,%esi
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
  800680:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  800683:	eb 2f                	jmp    8006b4 <umain+0x5d>
		switch (r) {
  800685:	83 f8 69             	cmp    $0x69,%eax
  800688:	74 25                	je     8006af <umain+0x58>
  80068a:	83 f8 78             	cmp    $0x78,%eax
  80068d:	74 07                	je     800696 <umain+0x3f>
  80068f:	83 f8 64             	cmp    $0x64,%eax
  800692:	75 14                	jne    8006a8 <umain+0x51>
  800694:	eb 09                	jmp    80069f <umain+0x48>
			break;
		case 'i':
			interactive = 1;
			break;
		case 'x':
			echocmds = 1;
  800696:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  80069d:	eb 15                	jmp    8006b4 <umain+0x5d>
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
		switch (r) {
		case 'd':
			debug++;
  80069f:	83 05 00 50 80 00 01 	addl   $0x1,0x805000
			break;
  8006a6:	eb 0c                	jmp    8006b4 <umain+0x5d>
			break;
		case 'x':
			echocmds = 1;
			break;
		default:
			usage();
  8006a8:	e8 90 ff ff ff       	call   80063d <usage>
  8006ad:	eb 05                	jmp    8006b4 <umain+0x5d>
		switch (r) {
		case 'd':
			debug++;
			break;
		case 'i':
			interactive = 1;
  8006af:	be 01 00 00 00       	mov    $0x1,%esi
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
  8006b4:	83 ec 0c             	sub    $0xc,%esp
  8006b7:	53                   	push   %ebx
  8006b8:	e8 95 13 00 00       	call   801a52 <argnext>
  8006bd:	83 c4 10             	add    $0x10,%esp
  8006c0:	85 c0                	test   %eax,%eax
  8006c2:	79 c1                	jns    800685 <umain+0x2e>
			break;
		default:
			usage();
		}

	if (argc > 2)
  8006c4:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  8006c8:	7e 05                	jle    8006cf <umain+0x78>
		usage();
  8006ca:	e8 6e ff ff ff       	call   80063d <usage>
	if (argc == 2) {
  8006cf:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  8006d3:	75 56                	jne    80072b <umain+0xd4>
		close(0);
  8006d5:	83 ec 0c             	sub    $0xc,%esp
  8006d8:	6a 00                	push   $0x0
  8006da:	e8 37 16 00 00       	call   801d16 <close>
		if ((r = open(argv[1], O_RDONLY)) < 0)
  8006df:	83 c4 08             	add    $0x8,%esp
  8006e2:	6a 00                	push   $0x0
  8006e4:	ff 77 04             	pushl  0x4(%edi)
  8006e7:	e8 1a 1c 00 00       	call   802306 <open>
  8006ec:	83 c4 10             	add    $0x10,%esp
  8006ef:	85 c0                	test   %eax,%eax
  8006f1:	79 1b                	jns    80070e <umain+0xb7>
			panic("open %s: %e", argv[1], r);
  8006f3:	83 ec 0c             	sub    $0xc,%esp
  8006f6:	50                   	push   %eax
  8006f7:	ff 77 04             	pushl  0x4(%edi)
  8006fa:	68 f3 37 80 00       	push   $0x8037f3
  8006ff:	68 28 01 00 00       	push   $0x128
  800704:	68 76 37 80 00       	push   $0x803776
  800709:	e8 07 03 00 00       	call   800a15 <_panic>
		assert(r == 0);
  80070e:	85 c0                	test   %eax,%eax
  800710:	74 19                	je     80072b <umain+0xd4>
  800712:	68 ff 37 80 00       	push   $0x8037ff
  800717:	68 06 38 80 00       	push   $0x803806
  80071c:	68 29 01 00 00       	push   $0x129
  800721:	68 76 37 80 00       	push   $0x803776
  800726:	e8 ea 02 00 00       	call   800a15 <_panic>
	}
	if (interactive == '?')
  80072b:	83 fe 3f             	cmp    $0x3f,%esi
  80072e:	75 0f                	jne    80073f <umain+0xe8>
		interactive = iscons(0);
  800730:	83 ec 0c             	sub    $0xc,%esp
  800733:	6a 00                	push   $0x0
  800735:	e8 f5 01 00 00       	call   80092f <iscons>
  80073a:	89 c6                	mov    %eax,%esi
  80073c:	83 c4 10             	add    $0x10,%esp
  80073f:	85 f6                	test   %esi,%esi
  800741:	b8 00 00 00 00       	mov    $0x0,%eax
  800746:	bf 1b 38 80 00       	mov    $0x80381b,%edi
  80074b:	0f 44 f8             	cmove  %eax,%edi

	while (1) {
		char *buf;

		buf = readline(interactive ? "$ " : NULL);
  80074e:	83 ec 0c             	sub    $0xc,%esp
  800751:	57                   	push   %edi
  800752:	e8 e3 08 00 00       	call   80103a <readline>
  800757:	89 c3                	mov    %eax,%ebx
		if (buf == NULL) {
  800759:	83 c4 10             	add    $0x10,%esp
  80075c:	85 c0                	test   %eax,%eax
  80075e:	75 1e                	jne    80077e <umain+0x127>
			if (debug)
  800760:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800767:	74 10                	je     800779 <umain+0x122>
				cprintf("EXITING\n");
  800769:	83 ec 0c             	sub    $0xc,%esp
  80076c:	68 1e 38 80 00       	push   $0x80381e
  800771:	e8 78 03 00 00       	call   800aee <cprintf>
  800776:	83 c4 10             	add    $0x10,%esp
			exit();	// end of file
  800779:	e8 7d 02 00 00       	call   8009fb <exit>
		}
		if (debug)
  80077e:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800785:	74 11                	je     800798 <umain+0x141>
			cprintf("LINE: %s\n", buf);
  800787:	83 ec 08             	sub    $0x8,%esp
  80078a:	53                   	push   %ebx
  80078b:	68 27 38 80 00       	push   $0x803827
  800790:	e8 59 03 00 00       	call   800aee <cprintf>
  800795:	83 c4 10             	add    $0x10,%esp
		if (buf[0] == '#')
  800798:	80 3b 23             	cmpb   $0x23,(%ebx)
  80079b:	74 b1                	je     80074e <umain+0xf7>
			continue;
		if (echocmds)
  80079d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8007a1:	74 11                	je     8007b4 <umain+0x15d>
			printf("# %s\n", buf);
  8007a3:	83 ec 08             	sub    $0x8,%esp
  8007a6:	53                   	push   %ebx
  8007a7:	68 31 38 80 00       	push   $0x803831
  8007ac:	e8 f3 1c 00 00       	call   8024a4 <printf>
  8007b1:	83 c4 10             	add    $0x10,%esp
		if (debug)
  8007b4:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8007bb:	74 10                	je     8007cd <umain+0x176>
			cprintf("BEFORE FORK\n");
  8007bd:	83 ec 0c             	sub    $0xc,%esp
  8007c0:	68 37 38 80 00       	push   $0x803837
  8007c5:	e8 24 03 00 00       	call   800aee <cprintf>
  8007ca:	83 c4 10             	add    $0x10,%esp
		if ((r = fork()) < 0)
  8007cd:	e8 5b 11 00 00       	call   80192d <fork>
  8007d2:	89 c6                	mov    %eax,%esi
  8007d4:	85 c0                	test   %eax,%eax
  8007d6:	79 15                	jns    8007ed <umain+0x196>
			panic("fork: %e", r);
  8007d8:	50                   	push   %eax
  8007d9:	68 83 3c 80 00       	push   $0x803c83
  8007de:	68 40 01 00 00       	push   $0x140
  8007e3:	68 76 37 80 00       	push   $0x803776
  8007e8:	e8 28 02 00 00       	call   800a15 <_panic>
		if (debug)
  8007ed:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8007f4:	74 11                	je     800807 <umain+0x1b0>
			cprintf("FORK: %d\n", r);
  8007f6:	83 ec 08             	sub    $0x8,%esp
  8007f9:	50                   	push   %eax
  8007fa:	68 44 38 80 00       	push   $0x803844
  8007ff:	e8 ea 02 00 00       	call   800aee <cprintf>
  800804:	83 c4 10             	add    $0x10,%esp
		if (r == 0) {
  800807:	85 f6                	test   %esi,%esi
  800809:	75 16                	jne    800821 <umain+0x1ca>
			runcmd(buf);
  80080b:	83 ec 0c             	sub    $0xc,%esp
  80080e:	53                   	push   %ebx
  80080f:	e8 f5 f9 ff ff       	call   800209 <runcmd>
			exit();
  800814:	e8 e2 01 00 00       	call   8009fb <exit>
  800819:	83 c4 10             	add    $0x10,%esp
  80081c:	e9 2d ff ff ff       	jmp    80074e <umain+0xf7>
		} else
			wait(r);
  800821:	83 ec 0c             	sub    $0xc,%esp
  800824:	56                   	push   %esi
  800825:	e8 07 2a 00 00       	call   803231 <wait>
  80082a:	83 c4 10             	add    $0x10,%esp
  80082d:	e9 1c ff ff ff       	jmp    80074e <umain+0xf7>

00800832 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800832:	55                   	push   %ebp
  800833:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800835:	b8 00 00 00 00       	mov    $0x0,%eax
  80083a:	5d                   	pop    %ebp
  80083b:	c3                   	ret    

0080083c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80083c:	55                   	push   %ebp
  80083d:	89 e5                	mov    %esp,%ebp
  80083f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800842:	68 c1 38 80 00       	push   $0x8038c1
  800847:	ff 75 0c             	pushl  0xc(%ebp)
  80084a:	e8 17 09 00 00       	call   801166 <strcpy>
	return 0;
}
  80084f:	b8 00 00 00 00       	mov    $0x0,%eax
  800854:	c9                   	leave  
  800855:	c3                   	ret    

00800856 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800856:	55                   	push   %ebp
  800857:	89 e5                	mov    %esp,%ebp
  800859:	57                   	push   %edi
  80085a:	56                   	push   %esi
  80085b:	53                   	push   %ebx
  80085c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800862:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800867:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80086d:	eb 2d                	jmp    80089c <devcons_write+0x46>
		m = n - tot;
  80086f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800872:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800874:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800877:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80087c:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80087f:	83 ec 04             	sub    $0x4,%esp
  800882:	53                   	push   %ebx
  800883:	03 45 0c             	add    0xc(%ebp),%eax
  800886:	50                   	push   %eax
  800887:	57                   	push   %edi
  800888:	e8 6b 0a 00 00       	call   8012f8 <memmove>
		sys_cputs(buf, m);
  80088d:	83 c4 08             	add    $0x8,%esp
  800890:	53                   	push   %ebx
  800891:	57                   	push   %edi
  800892:	e8 16 0c 00 00       	call   8014ad <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800897:	01 de                	add    %ebx,%esi
  800899:	83 c4 10             	add    $0x10,%esp
  80089c:	89 f0                	mov    %esi,%eax
  80089e:	3b 75 10             	cmp    0x10(%ebp),%esi
  8008a1:	72 cc                	jb     80086f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8008a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008a6:	5b                   	pop    %ebx
  8008a7:	5e                   	pop    %esi
  8008a8:	5f                   	pop    %edi
  8008a9:	5d                   	pop    %ebp
  8008aa:	c3                   	ret    

008008ab <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	83 ec 08             	sub    $0x8,%esp
  8008b1:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8008b6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8008ba:	74 2a                	je     8008e6 <devcons_read+0x3b>
  8008bc:	eb 05                	jmp    8008c3 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8008be:	e8 87 0c 00 00       	call   80154a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8008c3:	e8 03 0c 00 00       	call   8014cb <sys_cgetc>
  8008c8:	85 c0                	test   %eax,%eax
  8008ca:	74 f2                	je     8008be <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8008cc:	85 c0                	test   %eax,%eax
  8008ce:	78 16                	js     8008e6 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8008d0:	83 f8 04             	cmp    $0x4,%eax
  8008d3:	74 0c                	je     8008e1 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8008d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008d8:	88 02                	mov    %al,(%edx)
	return 1;
  8008da:	b8 01 00 00 00       	mov    $0x1,%eax
  8008df:	eb 05                	jmp    8008e6 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8008e1:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8008e6:	c9                   	leave  
  8008e7:	c3                   	ret    

008008e8 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
  8008eb:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8008ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f1:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8008f4:	6a 01                	push   $0x1
  8008f6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8008f9:	50                   	push   %eax
  8008fa:	e8 ae 0b 00 00       	call   8014ad <sys_cputs>
}
  8008ff:	83 c4 10             	add    $0x10,%esp
  800902:	c9                   	leave  
  800903:	c3                   	ret    

00800904 <getchar>:

int
getchar(void)
{
  800904:	55                   	push   %ebp
  800905:	89 e5                	mov    %esp,%ebp
  800907:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80090a:	6a 01                	push   $0x1
  80090c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80090f:	50                   	push   %eax
  800910:	6a 00                	push   $0x0
  800912:	e8 3b 15 00 00       	call   801e52 <read>
	if (r < 0)
  800917:	83 c4 10             	add    $0x10,%esp
  80091a:	85 c0                	test   %eax,%eax
  80091c:	78 0f                	js     80092d <getchar+0x29>
		return r;
	if (r < 1)
  80091e:	85 c0                	test   %eax,%eax
  800920:	7e 06                	jle    800928 <getchar+0x24>
		return -E_EOF;
	return c;
  800922:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800926:	eb 05                	jmp    80092d <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800928:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80092d:	c9                   	leave  
  80092e:	c3                   	ret    

0080092f <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80092f:	55                   	push   %ebp
  800930:	89 e5                	mov    %esp,%ebp
  800932:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800935:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800938:	50                   	push   %eax
  800939:	ff 75 08             	pushl  0x8(%ebp)
  80093c:	e8 ab 12 00 00       	call   801bec <fd_lookup>
  800941:	83 c4 10             	add    $0x10,%esp
  800944:	85 c0                	test   %eax,%eax
  800946:	78 11                	js     800959 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800948:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80094b:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800951:	39 10                	cmp    %edx,(%eax)
  800953:	0f 94 c0             	sete   %al
  800956:	0f b6 c0             	movzbl %al,%eax
}
  800959:	c9                   	leave  
  80095a:	c3                   	ret    

0080095b <opencons>:

int
opencons(void)
{
  80095b:	55                   	push   %ebp
  80095c:	89 e5                	mov    %esp,%ebp
  80095e:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800961:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800964:	50                   	push   %eax
  800965:	e8 33 12 00 00       	call   801b9d <fd_alloc>
  80096a:	83 c4 10             	add    $0x10,%esp
		return r;
  80096d:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80096f:	85 c0                	test   %eax,%eax
  800971:	78 3e                	js     8009b1 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800973:	83 ec 04             	sub    $0x4,%esp
  800976:	68 07 04 00 00       	push   $0x407
  80097b:	ff 75 f4             	pushl  -0xc(%ebp)
  80097e:	6a 00                	push   $0x0
  800980:	e8 e4 0b 00 00       	call   801569 <sys_page_alloc>
  800985:	83 c4 10             	add    $0x10,%esp
		return r;
  800988:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80098a:	85 c0                	test   %eax,%eax
  80098c:	78 23                	js     8009b1 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80098e:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800994:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800997:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800999:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80099c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8009a3:	83 ec 0c             	sub    $0xc,%esp
  8009a6:	50                   	push   %eax
  8009a7:	e8 ca 11 00 00       	call   801b76 <fd2num>
  8009ac:	89 c2                	mov    %eax,%edx
  8009ae:	83 c4 10             	add    $0x10,%esp
}
  8009b1:	89 d0                	mov    %edx,%eax
  8009b3:	c9                   	leave  
  8009b4:	c3                   	ret    

008009b5 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8009b5:	55                   	push   %ebp
  8009b6:	89 e5                	mov    %esp,%ebp
  8009b8:	56                   	push   %esi
  8009b9:	53                   	push   %ebx
  8009ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009bd:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8009c0:	e8 66 0b 00 00       	call   80152b <sys_getenvid>
  8009c5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8009ca:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8009cd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8009d2:	a3 28 54 80 00       	mov    %eax,0x805428

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8009d7:	85 db                	test   %ebx,%ebx
  8009d9:	7e 07                	jle    8009e2 <libmain+0x2d>
		binaryname = argv[0];
  8009db:	8b 06                	mov    (%esi),%eax
  8009dd:	a3 1c 40 80 00       	mov    %eax,0x80401c

	// call user main routine
	umain(argc, argv);
  8009e2:	83 ec 08             	sub    $0x8,%esp
  8009e5:	56                   	push   %esi
  8009e6:	53                   	push   %ebx
  8009e7:	e8 6b fc ff ff       	call   800657 <umain>

	// exit gracefully
	exit();
  8009ec:	e8 0a 00 00 00       	call   8009fb <exit>
}
  8009f1:	83 c4 10             	add    $0x10,%esp
  8009f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009f7:	5b                   	pop    %ebx
  8009f8:	5e                   	pop    %esi
  8009f9:	5d                   	pop    %ebp
  8009fa:	c3                   	ret    

008009fb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8009fb:	55                   	push   %ebp
  8009fc:	89 e5                	mov    %esp,%ebp
  8009fe:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800a01:	e8 3b 13 00 00       	call   801d41 <close_all>
	sys_env_destroy(0);
  800a06:	83 ec 0c             	sub    $0xc,%esp
  800a09:	6a 00                	push   $0x0
  800a0b:	e8 da 0a 00 00       	call   8014ea <sys_env_destroy>
}
  800a10:	83 c4 10             	add    $0x10,%esp
  800a13:	c9                   	leave  
  800a14:	c3                   	ret    

00800a15 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800a15:	55                   	push   %ebp
  800a16:	89 e5                	mov    %esp,%ebp
  800a18:	56                   	push   %esi
  800a19:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800a1a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800a1d:	8b 35 1c 40 80 00    	mov    0x80401c,%esi
  800a23:	e8 03 0b 00 00       	call   80152b <sys_getenvid>
  800a28:	83 ec 0c             	sub    $0xc,%esp
  800a2b:	ff 75 0c             	pushl  0xc(%ebp)
  800a2e:	ff 75 08             	pushl  0x8(%ebp)
  800a31:	56                   	push   %esi
  800a32:	50                   	push   %eax
  800a33:	68 d8 38 80 00       	push   $0x8038d8
  800a38:	e8 b1 00 00 00       	call   800aee <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800a3d:	83 c4 18             	add    $0x18,%esp
  800a40:	53                   	push   %ebx
  800a41:	ff 75 10             	pushl  0x10(%ebp)
  800a44:	e8 54 00 00 00       	call   800a9d <vcprintf>
	cprintf("\n");
  800a49:	c7 04 24 e0 36 80 00 	movl   $0x8036e0,(%esp)
  800a50:	e8 99 00 00 00       	call   800aee <cprintf>
  800a55:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800a58:	cc                   	int3   
  800a59:	eb fd                	jmp    800a58 <_panic+0x43>

00800a5b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800a5b:	55                   	push   %ebp
  800a5c:	89 e5                	mov    %esp,%ebp
  800a5e:	53                   	push   %ebx
  800a5f:	83 ec 04             	sub    $0x4,%esp
  800a62:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800a65:	8b 13                	mov    (%ebx),%edx
  800a67:	8d 42 01             	lea    0x1(%edx),%eax
  800a6a:	89 03                	mov    %eax,(%ebx)
  800a6c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a6f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800a73:	3d ff 00 00 00       	cmp    $0xff,%eax
  800a78:	75 1a                	jne    800a94 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800a7a:	83 ec 08             	sub    $0x8,%esp
  800a7d:	68 ff 00 00 00       	push   $0xff
  800a82:	8d 43 08             	lea    0x8(%ebx),%eax
  800a85:	50                   	push   %eax
  800a86:	e8 22 0a 00 00       	call   8014ad <sys_cputs>
		b->idx = 0;
  800a8b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800a91:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800a94:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800a98:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a9b:	c9                   	leave  
  800a9c:	c3                   	ret    

00800a9d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800a9d:	55                   	push   %ebp
  800a9e:	89 e5                	mov    %esp,%ebp
  800aa0:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800aa6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800aad:	00 00 00 
	b.cnt = 0;
  800ab0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800ab7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800aba:	ff 75 0c             	pushl  0xc(%ebp)
  800abd:	ff 75 08             	pushl  0x8(%ebp)
  800ac0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800ac6:	50                   	push   %eax
  800ac7:	68 5b 0a 80 00       	push   $0x800a5b
  800acc:	e8 54 01 00 00       	call   800c25 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800ad1:	83 c4 08             	add    $0x8,%esp
  800ad4:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800ada:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800ae0:	50                   	push   %eax
  800ae1:	e8 c7 09 00 00       	call   8014ad <sys_cputs>

	return b.cnt;
}
  800ae6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800aec:	c9                   	leave  
  800aed:	c3                   	ret    

00800aee <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800aee:	55                   	push   %ebp
  800aef:	89 e5                	mov    %esp,%ebp
  800af1:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800af4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800af7:	50                   	push   %eax
  800af8:	ff 75 08             	pushl  0x8(%ebp)
  800afb:	e8 9d ff ff ff       	call   800a9d <vcprintf>
	va_end(ap);

	return cnt;
}
  800b00:	c9                   	leave  
  800b01:	c3                   	ret    

00800b02 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800b02:	55                   	push   %ebp
  800b03:	89 e5                	mov    %esp,%ebp
  800b05:	57                   	push   %edi
  800b06:	56                   	push   %esi
  800b07:	53                   	push   %ebx
  800b08:	83 ec 1c             	sub    $0x1c,%esp
  800b0b:	89 c7                	mov    %eax,%edi
  800b0d:	89 d6                	mov    %edx,%esi
  800b0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b12:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b15:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b18:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800b1b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b1e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b23:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800b26:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800b29:	39 d3                	cmp    %edx,%ebx
  800b2b:	72 05                	jb     800b32 <printnum+0x30>
  800b2d:	39 45 10             	cmp    %eax,0x10(%ebp)
  800b30:	77 45                	ja     800b77 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800b32:	83 ec 0c             	sub    $0xc,%esp
  800b35:	ff 75 18             	pushl  0x18(%ebp)
  800b38:	8b 45 14             	mov    0x14(%ebp),%eax
  800b3b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800b3e:	53                   	push   %ebx
  800b3f:	ff 75 10             	pushl  0x10(%ebp)
  800b42:	83 ec 08             	sub    $0x8,%esp
  800b45:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b48:	ff 75 e0             	pushl  -0x20(%ebp)
  800b4b:	ff 75 dc             	pushl  -0x24(%ebp)
  800b4e:	ff 75 d8             	pushl  -0x28(%ebp)
  800b51:	e8 da 28 00 00       	call   803430 <__udivdi3>
  800b56:	83 c4 18             	add    $0x18,%esp
  800b59:	52                   	push   %edx
  800b5a:	50                   	push   %eax
  800b5b:	89 f2                	mov    %esi,%edx
  800b5d:	89 f8                	mov    %edi,%eax
  800b5f:	e8 9e ff ff ff       	call   800b02 <printnum>
  800b64:	83 c4 20             	add    $0x20,%esp
  800b67:	eb 18                	jmp    800b81 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800b69:	83 ec 08             	sub    $0x8,%esp
  800b6c:	56                   	push   %esi
  800b6d:	ff 75 18             	pushl  0x18(%ebp)
  800b70:	ff d7                	call   *%edi
  800b72:	83 c4 10             	add    $0x10,%esp
  800b75:	eb 03                	jmp    800b7a <printnum+0x78>
  800b77:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800b7a:	83 eb 01             	sub    $0x1,%ebx
  800b7d:	85 db                	test   %ebx,%ebx
  800b7f:	7f e8                	jg     800b69 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800b81:	83 ec 08             	sub    $0x8,%esp
  800b84:	56                   	push   %esi
  800b85:	83 ec 04             	sub    $0x4,%esp
  800b88:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b8b:	ff 75 e0             	pushl  -0x20(%ebp)
  800b8e:	ff 75 dc             	pushl  -0x24(%ebp)
  800b91:	ff 75 d8             	pushl  -0x28(%ebp)
  800b94:	e8 c7 29 00 00       	call   803560 <__umoddi3>
  800b99:	83 c4 14             	add    $0x14,%esp
  800b9c:	0f be 80 fb 38 80 00 	movsbl 0x8038fb(%eax),%eax
  800ba3:	50                   	push   %eax
  800ba4:	ff d7                	call   *%edi
}
  800ba6:	83 c4 10             	add    $0x10,%esp
  800ba9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bac:	5b                   	pop    %ebx
  800bad:	5e                   	pop    %esi
  800bae:	5f                   	pop    %edi
  800baf:	5d                   	pop    %ebp
  800bb0:	c3                   	ret    

00800bb1 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800bb1:	55                   	push   %ebp
  800bb2:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800bb4:	83 fa 01             	cmp    $0x1,%edx
  800bb7:	7e 0e                	jle    800bc7 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800bb9:	8b 10                	mov    (%eax),%edx
  800bbb:	8d 4a 08             	lea    0x8(%edx),%ecx
  800bbe:	89 08                	mov    %ecx,(%eax)
  800bc0:	8b 02                	mov    (%edx),%eax
  800bc2:	8b 52 04             	mov    0x4(%edx),%edx
  800bc5:	eb 22                	jmp    800be9 <getuint+0x38>
	else if (lflag)
  800bc7:	85 d2                	test   %edx,%edx
  800bc9:	74 10                	je     800bdb <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800bcb:	8b 10                	mov    (%eax),%edx
  800bcd:	8d 4a 04             	lea    0x4(%edx),%ecx
  800bd0:	89 08                	mov    %ecx,(%eax)
  800bd2:	8b 02                	mov    (%edx),%eax
  800bd4:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd9:	eb 0e                	jmp    800be9 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800bdb:	8b 10                	mov    (%eax),%edx
  800bdd:	8d 4a 04             	lea    0x4(%edx),%ecx
  800be0:	89 08                	mov    %ecx,(%eax)
  800be2:	8b 02                	mov    (%edx),%eax
  800be4:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800be9:	5d                   	pop    %ebp
  800bea:	c3                   	ret    

00800beb <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800beb:	55                   	push   %ebp
  800bec:	89 e5                	mov    %esp,%ebp
  800bee:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800bf1:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800bf5:	8b 10                	mov    (%eax),%edx
  800bf7:	3b 50 04             	cmp    0x4(%eax),%edx
  800bfa:	73 0a                	jae    800c06 <sprintputch+0x1b>
		*b->buf++ = ch;
  800bfc:	8d 4a 01             	lea    0x1(%edx),%ecx
  800bff:	89 08                	mov    %ecx,(%eax)
  800c01:	8b 45 08             	mov    0x8(%ebp),%eax
  800c04:	88 02                	mov    %al,(%edx)
}
  800c06:	5d                   	pop    %ebp
  800c07:	c3                   	ret    

00800c08 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800c08:	55                   	push   %ebp
  800c09:	89 e5                	mov    %esp,%ebp
  800c0b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800c0e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800c11:	50                   	push   %eax
  800c12:	ff 75 10             	pushl  0x10(%ebp)
  800c15:	ff 75 0c             	pushl  0xc(%ebp)
  800c18:	ff 75 08             	pushl  0x8(%ebp)
  800c1b:	e8 05 00 00 00       	call   800c25 <vprintfmt>
	va_end(ap);
}
  800c20:	83 c4 10             	add    $0x10,%esp
  800c23:	c9                   	leave  
  800c24:	c3                   	ret    

00800c25 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800c25:	55                   	push   %ebp
  800c26:	89 e5                	mov    %esp,%ebp
  800c28:	57                   	push   %edi
  800c29:	56                   	push   %esi
  800c2a:	53                   	push   %ebx
  800c2b:	83 ec 2c             	sub    $0x2c,%esp
  800c2e:	8b 75 08             	mov    0x8(%ebp),%esi
  800c31:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c34:	8b 7d 10             	mov    0x10(%ebp),%edi
  800c37:	eb 12                	jmp    800c4b <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800c39:	85 c0                	test   %eax,%eax
  800c3b:	0f 84 89 03 00 00    	je     800fca <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800c41:	83 ec 08             	sub    $0x8,%esp
  800c44:	53                   	push   %ebx
  800c45:	50                   	push   %eax
  800c46:	ff d6                	call   *%esi
  800c48:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800c4b:	83 c7 01             	add    $0x1,%edi
  800c4e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800c52:	83 f8 25             	cmp    $0x25,%eax
  800c55:	75 e2                	jne    800c39 <vprintfmt+0x14>
  800c57:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800c5b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800c62:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800c69:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800c70:	ba 00 00 00 00       	mov    $0x0,%edx
  800c75:	eb 07                	jmp    800c7e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c77:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800c7a:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c7e:	8d 47 01             	lea    0x1(%edi),%eax
  800c81:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c84:	0f b6 07             	movzbl (%edi),%eax
  800c87:	0f b6 c8             	movzbl %al,%ecx
  800c8a:	83 e8 23             	sub    $0x23,%eax
  800c8d:	3c 55                	cmp    $0x55,%al
  800c8f:	0f 87 1a 03 00 00    	ja     800faf <vprintfmt+0x38a>
  800c95:	0f b6 c0             	movzbl %al,%eax
  800c98:	ff 24 85 40 3a 80 00 	jmp    *0x803a40(,%eax,4)
  800c9f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800ca2:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800ca6:	eb d6                	jmp    800c7e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ca8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800cab:	b8 00 00 00 00       	mov    $0x0,%eax
  800cb0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800cb3:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800cb6:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800cba:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800cbd:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800cc0:	83 fa 09             	cmp    $0x9,%edx
  800cc3:	77 39                	ja     800cfe <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800cc5:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800cc8:	eb e9                	jmp    800cb3 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800cca:	8b 45 14             	mov    0x14(%ebp),%eax
  800ccd:	8d 48 04             	lea    0x4(%eax),%ecx
  800cd0:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800cd3:	8b 00                	mov    (%eax),%eax
  800cd5:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cd8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800cdb:	eb 27                	jmp    800d04 <vprintfmt+0xdf>
  800cdd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ce0:	85 c0                	test   %eax,%eax
  800ce2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ce7:	0f 49 c8             	cmovns %eax,%ecx
  800cea:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ced:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800cf0:	eb 8c                	jmp    800c7e <vprintfmt+0x59>
  800cf2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800cf5:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800cfc:	eb 80                	jmp    800c7e <vprintfmt+0x59>
  800cfe:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800d01:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800d04:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800d08:	0f 89 70 ff ff ff    	jns    800c7e <vprintfmt+0x59>
				width = precision, precision = -1;
  800d0e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800d11:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800d14:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800d1b:	e9 5e ff ff ff       	jmp    800c7e <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800d20:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d23:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800d26:	e9 53 ff ff ff       	jmp    800c7e <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800d2b:	8b 45 14             	mov    0x14(%ebp),%eax
  800d2e:	8d 50 04             	lea    0x4(%eax),%edx
  800d31:	89 55 14             	mov    %edx,0x14(%ebp)
  800d34:	83 ec 08             	sub    $0x8,%esp
  800d37:	53                   	push   %ebx
  800d38:	ff 30                	pushl  (%eax)
  800d3a:	ff d6                	call   *%esi
			break;
  800d3c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d3f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800d42:	e9 04 ff ff ff       	jmp    800c4b <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800d47:	8b 45 14             	mov    0x14(%ebp),%eax
  800d4a:	8d 50 04             	lea    0x4(%eax),%edx
  800d4d:	89 55 14             	mov    %edx,0x14(%ebp)
  800d50:	8b 00                	mov    (%eax),%eax
  800d52:	99                   	cltd   
  800d53:	31 d0                	xor    %edx,%eax
  800d55:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800d57:	83 f8 0f             	cmp    $0xf,%eax
  800d5a:	7f 0b                	jg     800d67 <vprintfmt+0x142>
  800d5c:	8b 14 85 a0 3b 80 00 	mov    0x803ba0(,%eax,4),%edx
  800d63:	85 d2                	test   %edx,%edx
  800d65:	75 18                	jne    800d7f <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800d67:	50                   	push   %eax
  800d68:	68 13 39 80 00       	push   $0x803913
  800d6d:	53                   	push   %ebx
  800d6e:	56                   	push   %esi
  800d6f:	e8 94 fe ff ff       	call   800c08 <printfmt>
  800d74:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d77:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800d7a:	e9 cc fe ff ff       	jmp    800c4b <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800d7f:	52                   	push   %edx
  800d80:	68 18 38 80 00       	push   $0x803818
  800d85:	53                   	push   %ebx
  800d86:	56                   	push   %esi
  800d87:	e8 7c fe ff ff       	call   800c08 <printfmt>
  800d8c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d8f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800d92:	e9 b4 fe ff ff       	jmp    800c4b <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800d97:	8b 45 14             	mov    0x14(%ebp),%eax
  800d9a:	8d 50 04             	lea    0x4(%eax),%edx
  800d9d:	89 55 14             	mov    %edx,0x14(%ebp)
  800da0:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800da2:	85 ff                	test   %edi,%edi
  800da4:	b8 0c 39 80 00       	mov    $0x80390c,%eax
  800da9:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800dac:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800db0:	0f 8e 94 00 00 00    	jle    800e4a <vprintfmt+0x225>
  800db6:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800dba:	0f 84 98 00 00 00    	je     800e58 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800dc0:	83 ec 08             	sub    $0x8,%esp
  800dc3:	ff 75 d0             	pushl  -0x30(%ebp)
  800dc6:	57                   	push   %edi
  800dc7:	e8 79 03 00 00       	call   801145 <strnlen>
  800dcc:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800dcf:	29 c1                	sub    %eax,%ecx
  800dd1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800dd4:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800dd7:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800ddb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800dde:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800de1:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800de3:	eb 0f                	jmp    800df4 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800de5:	83 ec 08             	sub    $0x8,%esp
  800de8:	53                   	push   %ebx
  800de9:	ff 75 e0             	pushl  -0x20(%ebp)
  800dec:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800dee:	83 ef 01             	sub    $0x1,%edi
  800df1:	83 c4 10             	add    $0x10,%esp
  800df4:	85 ff                	test   %edi,%edi
  800df6:	7f ed                	jg     800de5 <vprintfmt+0x1c0>
  800df8:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800dfb:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800dfe:	85 c9                	test   %ecx,%ecx
  800e00:	b8 00 00 00 00       	mov    $0x0,%eax
  800e05:	0f 49 c1             	cmovns %ecx,%eax
  800e08:	29 c1                	sub    %eax,%ecx
  800e0a:	89 75 08             	mov    %esi,0x8(%ebp)
  800e0d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800e10:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800e13:	89 cb                	mov    %ecx,%ebx
  800e15:	eb 4d                	jmp    800e64 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800e17:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800e1b:	74 1b                	je     800e38 <vprintfmt+0x213>
  800e1d:	0f be c0             	movsbl %al,%eax
  800e20:	83 e8 20             	sub    $0x20,%eax
  800e23:	83 f8 5e             	cmp    $0x5e,%eax
  800e26:	76 10                	jbe    800e38 <vprintfmt+0x213>
					putch('?', putdat);
  800e28:	83 ec 08             	sub    $0x8,%esp
  800e2b:	ff 75 0c             	pushl  0xc(%ebp)
  800e2e:	6a 3f                	push   $0x3f
  800e30:	ff 55 08             	call   *0x8(%ebp)
  800e33:	83 c4 10             	add    $0x10,%esp
  800e36:	eb 0d                	jmp    800e45 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800e38:	83 ec 08             	sub    $0x8,%esp
  800e3b:	ff 75 0c             	pushl  0xc(%ebp)
  800e3e:	52                   	push   %edx
  800e3f:	ff 55 08             	call   *0x8(%ebp)
  800e42:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800e45:	83 eb 01             	sub    $0x1,%ebx
  800e48:	eb 1a                	jmp    800e64 <vprintfmt+0x23f>
  800e4a:	89 75 08             	mov    %esi,0x8(%ebp)
  800e4d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800e50:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800e53:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800e56:	eb 0c                	jmp    800e64 <vprintfmt+0x23f>
  800e58:	89 75 08             	mov    %esi,0x8(%ebp)
  800e5b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800e5e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800e61:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800e64:	83 c7 01             	add    $0x1,%edi
  800e67:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800e6b:	0f be d0             	movsbl %al,%edx
  800e6e:	85 d2                	test   %edx,%edx
  800e70:	74 23                	je     800e95 <vprintfmt+0x270>
  800e72:	85 f6                	test   %esi,%esi
  800e74:	78 a1                	js     800e17 <vprintfmt+0x1f2>
  800e76:	83 ee 01             	sub    $0x1,%esi
  800e79:	79 9c                	jns    800e17 <vprintfmt+0x1f2>
  800e7b:	89 df                	mov    %ebx,%edi
  800e7d:	8b 75 08             	mov    0x8(%ebp),%esi
  800e80:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e83:	eb 18                	jmp    800e9d <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800e85:	83 ec 08             	sub    $0x8,%esp
  800e88:	53                   	push   %ebx
  800e89:	6a 20                	push   $0x20
  800e8b:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800e8d:	83 ef 01             	sub    $0x1,%edi
  800e90:	83 c4 10             	add    $0x10,%esp
  800e93:	eb 08                	jmp    800e9d <vprintfmt+0x278>
  800e95:	89 df                	mov    %ebx,%edi
  800e97:	8b 75 08             	mov    0x8(%ebp),%esi
  800e9a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e9d:	85 ff                	test   %edi,%edi
  800e9f:	7f e4                	jg     800e85 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ea1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800ea4:	e9 a2 fd ff ff       	jmp    800c4b <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800ea9:	83 fa 01             	cmp    $0x1,%edx
  800eac:	7e 16                	jle    800ec4 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800eae:	8b 45 14             	mov    0x14(%ebp),%eax
  800eb1:	8d 50 08             	lea    0x8(%eax),%edx
  800eb4:	89 55 14             	mov    %edx,0x14(%ebp)
  800eb7:	8b 50 04             	mov    0x4(%eax),%edx
  800eba:	8b 00                	mov    (%eax),%eax
  800ebc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ebf:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800ec2:	eb 32                	jmp    800ef6 <vprintfmt+0x2d1>
	else if (lflag)
  800ec4:	85 d2                	test   %edx,%edx
  800ec6:	74 18                	je     800ee0 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800ec8:	8b 45 14             	mov    0x14(%ebp),%eax
  800ecb:	8d 50 04             	lea    0x4(%eax),%edx
  800ece:	89 55 14             	mov    %edx,0x14(%ebp)
  800ed1:	8b 00                	mov    (%eax),%eax
  800ed3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ed6:	89 c1                	mov    %eax,%ecx
  800ed8:	c1 f9 1f             	sar    $0x1f,%ecx
  800edb:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800ede:	eb 16                	jmp    800ef6 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800ee0:	8b 45 14             	mov    0x14(%ebp),%eax
  800ee3:	8d 50 04             	lea    0x4(%eax),%edx
  800ee6:	89 55 14             	mov    %edx,0x14(%ebp)
  800ee9:	8b 00                	mov    (%eax),%eax
  800eeb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800eee:	89 c1                	mov    %eax,%ecx
  800ef0:	c1 f9 1f             	sar    $0x1f,%ecx
  800ef3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800ef6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800ef9:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800efc:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800f01:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800f05:	79 74                	jns    800f7b <vprintfmt+0x356>
				putch('-', putdat);
  800f07:	83 ec 08             	sub    $0x8,%esp
  800f0a:	53                   	push   %ebx
  800f0b:	6a 2d                	push   $0x2d
  800f0d:	ff d6                	call   *%esi
				num = -(long long) num;
  800f0f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800f12:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800f15:	f7 d8                	neg    %eax
  800f17:	83 d2 00             	adc    $0x0,%edx
  800f1a:	f7 da                	neg    %edx
  800f1c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800f1f:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800f24:	eb 55                	jmp    800f7b <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800f26:	8d 45 14             	lea    0x14(%ebp),%eax
  800f29:	e8 83 fc ff ff       	call   800bb1 <getuint>
			base = 10;
  800f2e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800f33:	eb 46                	jmp    800f7b <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800f35:	8d 45 14             	lea    0x14(%ebp),%eax
  800f38:	e8 74 fc ff ff       	call   800bb1 <getuint>
                        base = 8;
  800f3d:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800f42:	eb 37                	jmp    800f7b <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800f44:	83 ec 08             	sub    $0x8,%esp
  800f47:	53                   	push   %ebx
  800f48:	6a 30                	push   $0x30
  800f4a:	ff d6                	call   *%esi
			putch('x', putdat);
  800f4c:	83 c4 08             	add    $0x8,%esp
  800f4f:	53                   	push   %ebx
  800f50:	6a 78                	push   $0x78
  800f52:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800f54:	8b 45 14             	mov    0x14(%ebp),%eax
  800f57:	8d 50 04             	lea    0x4(%eax),%edx
  800f5a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800f5d:	8b 00                	mov    (%eax),%eax
  800f5f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800f64:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800f67:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800f6c:	eb 0d                	jmp    800f7b <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800f6e:	8d 45 14             	lea    0x14(%ebp),%eax
  800f71:	e8 3b fc ff ff       	call   800bb1 <getuint>
			base = 16;
  800f76:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800f7b:	83 ec 0c             	sub    $0xc,%esp
  800f7e:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800f82:	57                   	push   %edi
  800f83:	ff 75 e0             	pushl  -0x20(%ebp)
  800f86:	51                   	push   %ecx
  800f87:	52                   	push   %edx
  800f88:	50                   	push   %eax
  800f89:	89 da                	mov    %ebx,%edx
  800f8b:	89 f0                	mov    %esi,%eax
  800f8d:	e8 70 fb ff ff       	call   800b02 <printnum>
			break;
  800f92:	83 c4 20             	add    $0x20,%esp
  800f95:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800f98:	e9 ae fc ff ff       	jmp    800c4b <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800f9d:	83 ec 08             	sub    $0x8,%esp
  800fa0:	53                   	push   %ebx
  800fa1:	51                   	push   %ecx
  800fa2:	ff d6                	call   *%esi
			break;
  800fa4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800fa7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800faa:	e9 9c fc ff ff       	jmp    800c4b <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800faf:	83 ec 08             	sub    $0x8,%esp
  800fb2:	53                   	push   %ebx
  800fb3:	6a 25                	push   $0x25
  800fb5:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800fb7:	83 c4 10             	add    $0x10,%esp
  800fba:	eb 03                	jmp    800fbf <vprintfmt+0x39a>
  800fbc:	83 ef 01             	sub    $0x1,%edi
  800fbf:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800fc3:	75 f7                	jne    800fbc <vprintfmt+0x397>
  800fc5:	e9 81 fc ff ff       	jmp    800c4b <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800fca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fcd:	5b                   	pop    %ebx
  800fce:	5e                   	pop    %esi
  800fcf:	5f                   	pop    %edi
  800fd0:	5d                   	pop    %ebp
  800fd1:	c3                   	ret    

00800fd2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800fd2:	55                   	push   %ebp
  800fd3:	89 e5                	mov    %esp,%ebp
  800fd5:	83 ec 18             	sub    $0x18,%esp
  800fd8:	8b 45 08             	mov    0x8(%ebp),%eax
  800fdb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800fde:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800fe1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800fe5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800fe8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800fef:	85 c0                	test   %eax,%eax
  800ff1:	74 26                	je     801019 <vsnprintf+0x47>
  800ff3:	85 d2                	test   %edx,%edx
  800ff5:	7e 22                	jle    801019 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800ff7:	ff 75 14             	pushl  0x14(%ebp)
  800ffa:	ff 75 10             	pushl  0x10(%ebp)
  800ffd:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801000:	50                   	push   %eax
  801001:	68 eb 0b 80 00       	push   $0x800beb
  801006:	e8 1a fc ff ff       	call   800c25 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80100b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80100e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801011:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801014:	83 c4 10             	add    $0x10,%esp
  801017:	eb 05                	jmp    80101e <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801019:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80101e:	c9                   	leave  
  80101f:	c3                   	ret    

00801020 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801020:	55                   	push   %ebp
  801021:	89 e5                	mov    %esp,%ebp
  801023:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801026:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801029:	50                   	push   %eax
  80102a:	ff 75 10             	pushl  0x10(%ebp)
  80102d:	ff 75 0c             	pushl  0xc(%ebp)
  801030:	ff 75 08             	pushl  0x8(%ebp)
  801033:	e8 9a ff ff ff       	call   800fd2 <vsnprintf>
	va_end(ap);

	return rc;
}
  801038:	c9                   	leave  
  801039:	c3                   	ret    

0080103a <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  80103a:	55                   	push   %ebp
  80103b:	89 e5                	mov    %esp,%ebp
  80103d:	57                   	push   %edi
  80103e:	56                   	push   %esi
  80103f:	53                   	push   %ebx
  801040:	83 ec 0c             	sub    $0xc,%esp
  801043:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  801046:	85 c0                	test   %eax,%eax
  801048:	74 13                	je     80105d <readline+0x23>
		fprintf(1, "%s", prompt);
  80104a:	83 ec 04             	sub    $0x4,%esp
  80104d:	50                   	push   %eax
  80104e:	68 18 38 80 00       	push   $0x803818
  801053:	6a 01                	push   $0x1
  801055:	e8 33 14 00 00       	call   80248d <fprintf>
  80105a:	83 c4 10             	add    $0x10,%esp
#endif

	i = 0;
	echoing = iscons(0);
  80105d:	83 ec 0c             	sub    $0xc,%esp
  801060:	6a 00                	push   $0x0
  801062:	e8 c8 f8 ff ff       	call   80092f <iscons>
  801067:	89 c7                	mov    %eax,%edi
  801069:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
  80106c:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
  801071:	e8 8e f8 ff ff       	call   800904 <getchar>
  801076:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  801078:	85 c0                	test   %eax,%eax
  80107a:	79 29                	jns    8010a5 <readline+0x6b>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
  80107c:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
  801081:	83 fb f8             	cmp    $0xfffffff8,%ebx
  801084:	0f 84 9b 00 00 00    	je     801125 <readline+0xeb>
				cprintf("read error: %e\n", c);
  80108a:	83 ec 08             	sub    $0x8,%esp
  80108d:	53                   	push   %ebx
  80108e:	68 ff 3b 80 00       	push   $0x803bff
  801093:	e8 56 fa ff ff       	call   800aee <cprintf>
  801098:	83 c4 10             	add    $0x10,%esp
			return NULL;
  80109b:	b8 00 00 00 00       	mov    $0x0,%eax
  8010a0:	e9 80 00 00 00       	jmp    801125 <readline+0xeb>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  8010a5:	83 f8 08             	cmp    $0x8,%eax
  8010a8:	0f 94 c2             	sete   %dl
  8010ab:	83 f8 7f             	cmp    $0x7f,%eax
  8010ae:	0f 94 c0             	sete   %al
  8010b1:	08 c2                	or     %al,%dl
  8010b3:	74 1a                	je     8010cf <readline+0x95>
  8010b5:	85 f6                	test   %esi,%esi
  8010b7:	7e 16                	jle    8010cf <readline+0x95>
			if (echoing)
  8010b9:	85 ff                	test   %edi,%edi
  8010bb:	74 0d                	je     8010ca <readline+0x90>
				cputchar('\b');
  8010bd:	83 ec 0c             	sub    $0xc,%esp
  8010c0:	6a 08                	push   $0x8
  8010c2:	e8 21 f8 ff ff       	call   8008e8 <cputchar>
  8010c7:	83 c4 10             	add    $0x10,%esp
			i--;
  8010ca:	83 ee 01             	sub    $0x1,%esi
  8010cd:	eb a2                	jmp    801071 <readline+0x37>
		} else if (c >= ' ' && i < BUFLEN-1) {
  8010cf:	83 fb 1f             	cmp    $0x1f,%ebx
  8010d2:	7e 26                	jle    8010fa <readline+0xc0>
  8010d4:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  8010da:	7f 1e                	jg     8010fa <readline+0xc0>
			if (echoing)
  8010dc:	85 ff                	test   %edi,%edi
  8010de:	74 0c                	je     8010ec <readline+0xb2>
				cputchar(c);
  8010e0:	83 ec 0c             	sub    $0xc,%esp
  8010e3:	53                   	push   %ebx
  8010e4:	e8 ff f7 ff ff       	call   8008e8 <cputchar>
  8010e9:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
  8010ec:	88 9e 20 50 80 00    	mov    %bl,0x805020(%esi)
  8010f2:	8d 76 01             	lea    0x1(%esi),%esi
  8010f5:	e9 77 ff ff ff       	jmp    801071 <readline+0x37>
		} else if (c == '\n' || c == '\r') {
  8010fa:	83 fb 0a             	cmp    $0xa,%ebx
  8010fd:	74 09                	je     801108 <readline+0xce>
  8010ff:	83 fb 0d             	cmp    $0xd,%ebx
  801102:	0f 85 69 ff ff ff    	jne    801071 <readline+0x37>
			if (echoing)
  801108:	85 ff                	test   %edi,%edi
  80110a:	74 0d                	je     801119 <readline+0xdf>
				cputchar('\n');
  80110c:	83 ec 0c             	sub    $0xc,%esp
  80110f:	6a 0a                	push   $0xa
  801111:	e8 d2 f7 ff ff       	call   8008e8 <cputchar>
  801116:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
  801119:	c6 86 20 50 80 00 00 	movb   $0x0,0x805020(%esi)
			return buf;
  801120:	b8 20 50 80 00       	mov    $0x805020,%eax
		}
	}
}
  801125:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801128:	5b                   	pop    %ebx
  801129:	5e                   	pop    %esi
  80112a:	5f                   	pop    %edi
  80112b:	5d                   	pop    %ebp
  80112c:	c3                   	ret    

0080112d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80112d:	55                   	push   %ebp
  80112e:	89 e5                	mov    %esp,%ebp
  801130:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801133:	b8 00 00 00 00       	mov    $0x0,%eax
  801138:	eb 03                	jmp    80113d <strlen+0x10>
		n++;
  80113a:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80113d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801141:	75 f7                	jne    80113a <strlen+0xd>
		n++;
	return n;
}
  801143:	5d                   	pop    %ebp
  801144:	c3                   	ret    

00801145 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801145:	55                   	push   %ebp
  801146:	89 e5                	mov    %esp,%ebp
  801148:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80114b:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80114e:	ba 00 00 00 00       	mov    $0x0,%edx
  801153:	eb 03                	jmp    801158 <strnlen+0x13>
		n++;
  801155:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801158:	39 c2                	cmp    %eax,%edx
  80115a:	74 08                	je     801164 <strnlen+0x1f>
  80115c:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801160:	75 f3                	jne    801155 <strnlen+0x10>
  801162:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801164:	5d                   	pop    %ebp
  801165:	c3                   	ret    

00801166 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801166:	55                   	push   %ebp
  801167:	89 e5                	mov    %esp,%ebp
  801169:	53                   	push   %ebx
  80116a:	8b 45 08             	mov    0x8(%ebp),%eax
  80116d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801170:	89 c2                	mov    %eax,%edx
  801172:	83 c2 01             	add    $0x1,%edx
  801175:	83 c1 01             	add    $0x1,%ecx
  801178:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80117c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80117f:	84 db                	test   %bl,%bl
  801181:	75 ef                	jne    801172 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801183:	5b                   	pop    %ebx
  801184:	5d                   	pop    %ebp
  801185:	c3                   	ret    

00801186 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801186:	55                   	push   %ebp
  801187:	89 e5                	mov    %esp,%ebp
  801189:	53                   	push   %ebx
  80118a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80118d:	53                   	push   %ebx
  80118e:	e8 9a ff ff ff       	call   80112d <strlen>
  801193:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801196:	ff 75 0c             	pushl  0xc(%ebp)
  801199:	01 d8                	add    %ebx,%eax
  80119b:	50                   	push   %eax
  80119c:	e8 c5 ff ff ff       	call   801166 <strcpy>
	return dst;
}
  8011a1:	89 d8                	mov    %ebx,%eax
  8011a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011a6:	c9                   	leave  
  8011a7:	c3                   	ret    

008011a8 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8011a8:	55                   	push   %ebp
  8011a9:	89 e5                	mov    %esp,%ebp
  8011ab:	56                   	push   %esi
  8011ac:	53                   	push   %ebx
  8011ad:	8b 75 08             	mov    0x8(%ebp),%esi
  8011b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011b3:	89 f3                	mov    %esi,%ebx
  8011b5:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8011b8:	89 f2                	mov    %esi,%edx
  8011ba:	eb 0f                	jmp    8011cb <strncpy+0x23>
		*dst++ = *src;
  8011bc:	83 c2 01             	add    $0x1,%edx
  8011bf:	0f b6 01             	movzbl (%ecx),%eax
  8011c2:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8011c5:	80 39 01             	cmpb   $0x1,(%ecx)
  8011c8:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8011cb:	39 da                	cmp    %ebx,%edx
  8011cd:	75 ed                	jne    8011bc <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8011cf:	89 f0                	mov    %esi,%eax
  8011d1:	5b                   	pop    %ebx
  8011d2:	5e                   	pop    %esi
  8011d3:	5d                   	pop    %ebp
  8011d4:	c3                   	ret    

008011d5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8011d5:	55                   	push   %ebp
  8011d6:	89 e5                	mov    %esp,%ebp
  8011d8:	56                   	push   %esi
  8011d9:	53                   	push   %ebx
  8011da:	8b 75 08             	mov    0x8(%ebp),%esi
  8011dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011e0:	8b 55 10             	mov    0x10(%ebp),%edx
  8011e3:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8011e5:	85 d2                	test   %edx,%edx
  8011e7:	74 21                	je     80120a <strlcpy+0x35>
  8011e9:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8011ed:	89 f2                	mov    %esi,%edx
  8011ef:	eb 09                	jmp    8011fa <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8011f1:	83 c2 01             	add    $0x1,%edx
  8011f4:	83 c1 01             	add    $0x1,%ecx
  8011f7:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8011fa:	39 c2                	cmp    %eax,%edx
  8011fc:	74 09                	je     801207 <strlcpy+0x32>
  8011fe:	0f b6 19             	movzbl (%ecx),%ebx
  801201:	84 db                	test   %bl,%bl
  801203:	75 ec                	jne    8011f1 <strlcpy+0x1c>
  801205:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801207:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80120a:	29 f0                	sub    %esi,%eax
}
  80120c:	5b                   	pop    %ebx
  80120d:	5e                   	pop    %esi
  80120e:	5d                   	pop    %ebp
  80120f:	c3                   	ret    

00801210 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801210:	55                   	push   %ebp
  801211:	89 e5                	mov    %esp,%ebp
  801213:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801216:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801219:	eb 06                	jmp    801221 <strcmp+0x11>
		p++, q++;
  80121b:	83 c1 01             	add    $0x1,%ecx
  80121e:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801221:	0f b6 01             	movzbl (%ecx),%eax
  801224:	84 c0                	test   %al,%al
  801226:	74 04                	je     80122c <strcmp+0x1c>
  801228:	3a 02                	cmp    (%edx),%al
  80122a:	74 ef                	je     80121b <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80122c:	0f b6 c0             	movzbl %al,%eax
  80122f:	0f b6 12             	movzbl (%edx),%edx
  801232:	29 d0                	sub    %edx,%eax
}
  801234:	5d                   	pop    %ebp
  801235:	c3                   	ret    

00801236 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801236:	55                   	push   %ebp
  801237:	89 e5                	mov    %esp,%ebp
  801239:	53                   	push   %ebx
  80123a:	8b 45 08             	mov    0x8(%ebp),%eax
  80123d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801240:	89 c3                	mov    %eax,%ebx
  801242:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801245:	eb 06                	jmp    80124d <strncmp+0x17>
		n--, p++, q++;
  801247:	83 c0 01             	add    $0x1,%eax
  80124a:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80124d:	39 d8                	cmp    %ebx,%eax
  80124f:	74 15                	je     801266 <strncmp+0x30>
  801251:	0f b6 08             	movzbl (%eax),%ecx
  801254:	84 c9                	test   %cl,%cl
  801256:	74 04                	je     80125c <strncmp+0x26>
  801258:	3a 0a                	cmp    (%edx),%cl
  80125a:	74 eb                	je     801247 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80125c:	0f b6 00             	movzbl (%eax),%eax
  80125f:	0f b6 12             	movzbl (%edx),%edx
  801262:	29 d0                	sub    %edx,%eax
  801264:	eb 05                	jmp    80126b <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801266:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80126b:	5b                   	pop    %ebx
  80126c:	5d                   	pop    %ebp
  80126d:	c3                   	ret    

0080126e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80126e:	55                   	push   %ebp
  80126f:	89 e5                	mov    %esp,%ebp
  801271:	8b 45 08             	mov    0x8(%ebp),%eax
  801274:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801278:	eb 07                	jmp    801281 <strchr+0x13>
		if (*s == c)
  80127a:	38 ca                	cmp    %cl,%dl
  80127c:	74 0f                	je     80128d <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80127e:	83 c0 01             	add    $0x1,%eax
  801281:	0f b6 10             	movzbl (%eax),%edx
  801284:	84 d2                	test   %dl,%dl
  801286:	75 f2                	jne    80127a <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801288:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80128d:	5d                   	pop    %ebp
  80128e:	c3                   	ret    

0080128f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80128f:	55                   	push   %ebp
  801290:	89 e5                	mov    %esp,%ebp
  801292:	8b 45 08             	mov    0x8(%ebp),%eax
  801295:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801299:	eb 03                	jmp    80129e <strfind+0xf>
  80129b:	83 c0 01             	add    $0x1,%eax
  80129e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8012a1:	38 ca                	cmp    %cl,%dl
  8012a3:	74 04                	je     8012a9 <strfind+0x1a>
  8012a5:	84 d2                	test   %dl,%dl
  8012a7:	75 f2                	jne    80129b <strfind+0xc>
			break;
	return (char *) s;
}
  8012a9:	5d                   	pop    %ebp
  8012aa:	c3                   	ret    

008012ab <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8012ab:	55                   	push   %ebp
  8012ac:	89 e5                	mov    %esp,%ebp
  8012ae:	57                   	push   %edi
  8012af:	56                   	push   %esi
  8012b0:	53                   	push   %ebx
  8012b1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012b4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8012b7:	85 c9                	test   %ecx,%ecx
  8012b9:	74 36                	je     8012f1 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8012bb:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8012c1:	75 28                	jne    8012eb <memset+0x40>
  8012c3:	f6 c1 03             	test   $0x3,%cl
  8012c6:	75 23                	jne    8012eb <memset+0x40>
		c &= 0xFF;
  8012c8:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8012cc:	89 d3                	mov    %edx,%ebx
  8012ce:	c1 e3 08             	shl    $0x8,%ebx
  8012d1:	89 d6                	mov    %edx,%esi
  8012d3:	c1 e6 18             	shl    $0x18,%esi
  8012d6:	89 d0                	mov    %edx,%eax
  8012d8:	c1 e0 10             	shl    $0x10,%eax
  8012db:	09 f0                	or     %esi,%eax
  8012dd:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8012df:	89 d8                	mov    %ebx,%eax
  8012e1:	09 d0                	or     %edx,%eax
  8012e3:	c1 e9 02             	shr    $0x2,%ecx
  8012e6:	fc                   	cld    
  8012e7:	f3 ab                	rep stos %eax,%es:(%edi)
  8012e9:	eb 06                	jmp    8012f1 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8012eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012ee:	fc                   	cld    
  8012ef:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8012f1:	89 f8                	mov    %edi,%eax
  8012f3:	5b                   	pop    %ebx
  8012f4:	5e                   	pop    %esi
  8012f5:	5f                   	pop    %edi
  8012f6:	5d                   	pop    %ebp
  8012f7:	c3                   	ret    

008012f8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8012f8:	55                   	push   %ebp
  8012f9:	89 e5                	mov    %esp,%ebp
  8012fb:	57                   	push   %edi
  8012fc:	56                   	push   %esi
  8012fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801300:	8b 75 0c             	mov    0xc(%ebp),%esi
  801303:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801306:	39 c6                	cmp    %eax,%esi
  801308:	73 35                	jae    80133f <memmove+0x47>
  80130a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80130d:	39 d0                	cmp    %edx,%eax
  80130f:	73 2e                	jae    80133f <memmove+0x47>
		s += n;
		d += n;
  801311:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801314:	89 d6                	mov    %edx,%esi
  801316:	09 fe                	or     %edi,%esi
  801318:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80131e:	75 13                	jne    801333 <memmove+0x3b>
  801320:	f6 c1 03             	test   $0x3,%cl
  801323:	75 0e                	jne    801333 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801325:	83 ef 04             	sub    $0x4,%edi
  801328:	8d 72 fc             	lea    -0x4(%edx),%esi
  80132b:	c1 e9 02             	shr    $0x2,%ecx
  80132e:	fd                   	std    
  80132f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801331:	eb 09                	jmp    80133c <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801333:	83 ef 01             	sub    $0x1,%edi
  801336:	8d 72 ff             	lea    -0x1(%edx),%esi
  801339:	fd                   	std    
  80133a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80133c:	fc                   	cld    
  80133d:	eb 1d                	jmp    80135c <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80133f:	89 f2                	mov    %esi,%edx
  801341:	09 c2                	or     %eax,%edx
  801343:	f6 c2 03             	test   $0x3,%dl
  801346:	75 0f                	jne    801357 <memmove+0x5f>
  801348:	f6 c1 03             	test   $0x3,%cl
  80134b:	75 0a                	jne    801357 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80134d:	c1 e9 02             	shr    $0x2,%ecx
  801350:	89 c7                	mov    %eax,%edi
  801352:	fc                   	cld    
  801353:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801355:	eb 05                	jmp    80135c <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801357:	89 c7                	mov    %eax,%edi
  801359:	fc                   	cld    
  80135a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80135c:	5e                   	pop    %esi
  80135d:	5f                   	pop    %edi
  80135e:	5d                   	pop    %ebp
  80135f:	c3                   	ret    

00801360 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801360:	55                   	push   %ebp
  801361:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801363:	ff 75 10             	pushl  0x10(%ebp)
  801366:	ff 75 0c             	pushl  0xc(%ebp)
  801369:	ff 75 08             	pushl  0x8(%ebp)
  80136c:	e8 87 ff ff ff       	call   8012f8 <memmove>
}
  801371:	c9                   	leave  
  801372:	c3                   	ret    

00801373 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801373:	55                   	push   %ebp
  801374:	89 e5                	mov    %esp,%ebp
  801376:	56                   	push   %esi
  801377:	53                   	push   %ebx
  801378:	8b 45 08             	mov    0x8(%ebp),%eax
  80137b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80137e:	89 c6                	mov    %eax,%esi
  801380:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801383:	eb 1a                	jmp    80139f <memcmp+0x2c>
		if (*s1 != *s2)
  801385:	0f b6 08             	movzbl (%eax),%ecx
  801388:	0f b6 1a             	movzbl (%edx),%ebx
  80138b:	38 d9                	cmp    %bl,%cl
  80138d:	74 0a                	je     801399 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80138f:	0f b6 c1             	movzbl %cl,%eax
  801392:	0f b6 db             	movzbl %bl,%ebx
  801395:	29 d8                	sub    %ebx,%eax
  801397:	eb 0f                	jmp    8013a8 <memcmp+0x35>
		s1++, s2++;
  801399:	83 c0 01             	add    $0x1,%eax
  80139c:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80139f:	39 f0                	cmp    %esi,%eax
  8013a1:	75 e2                	jne    801385 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8013a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013a8:	5b                   	pop    %ebx
  8013a9:	5e                   	pop    %esi
  8013aa:	5d                   	pop    %ebp
  8013ab:	c3                   	ret    

008013ac <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8013ac:	55                   	push   %ebp
  8013ad:	89 e5                	mov    %esp,%ebp
  8013af:	53                   	push   %ebx
  8013b0:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8013b3:	89 c1                	mov    %eax,%ecx
  8013b5:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8013b8:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8013bc:	eb 0a                	jmp    8013c8 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8013be:	0f b6 10             	movzbl (%eax),%edx
  8013c1:	39 da                	cmp    %ebx,%edx
  8013c3:	74 07                	je     8013cc <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8013c5:	83 c0 01             	add    $0x1,%eax
  8013c8:	39 c8                	cmp    %ecx,%eax
  8013ca:	72 f2                	jb     8013be <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8013cc:	5b                   	pop    %ebx
  8013cd:	5d                   	pop    %ebp
  8013ce:	c3                   	ret    

008013cf <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8013cf:	55                   	push   %ebp
  8013d0:	89 e5                	mov    %esp,%ebp
  8013d2:	57                   	push   %edi
  8013d3:	56                   	push   %esi
  8013d4:	53                   	push   %ebx
  8013d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013d8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8013db:	eb 03                	jmp    8013e0 <strtol+0x11>
		s++;
  8013dd:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8013e0:	0f b6 01             	movzbl (%ecx),%eax
  8013e3:	3c 20                	cmp    $0x20,%al
  8013e5:	74 f6                	je     8013dd <strtol+0xe>
  8013e7:	3c 09                	cmp    $0x9,%al
  8013e9:	74 f2                	je     8013dd <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8013eb:	3c 2b                	cmp    $0x2b,%al
  8013ed:	75 0a                	jne    8013f9 <strtol+0x2a>
		s++;
  8013ef:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8013f2:	bf 00 00 00 00       	mov    $0x0,%edi
  8013f7:	eb 11                	jmp    80140a <strtol+0x3b>
  8013f9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8013fe:	3c 2d                	cmp    $0x2d,%al
  801400:	75 08                	jne    80140a <strtol+0x3b>
		s++, neg = 1;
  801402:	83 c1 01             	add    $0x1,%ecx
  801405:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80140a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801410:	75 15                	jne    801427 <strtol+0x58>
  801412:	80 39 30             	cmpb   $0x30,(%ecx)
  801415:	75 10                	jne    801427 <strtol+0x58>
  801417:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80141b:	75 7c                	jne    801499 <strtol+0xca>
		s += 2, base = 16;
  80141d:	83 c1 02             	add    $0x2,%ecx
  801420:	bb 10 00 00 00       	mov    $0x10,%ebx
  801425:	eb 16                	jmp    80143d <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801427:	85 db                	test   %ebx,%ebx
  801429:	75 12                	jne    80143d <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80142b:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801430:	80 39 30             	cmpb   $0x30,(%ecx)
  801433:	75 08                	jne    80143d <strtol+0x6e>
		s++, base = 8;
  801435:	83 c1 01             	add    $0x1,%ecx
  801438:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  80143d:	b8 00 00 00 00       	mov    $0x0,%eax
  801442:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801445:	0f b6 11             	movzbl (%ecx),%edx
  801448:	8d 72 d0             	lea    -0x30(%edx),%esi
  80144b:	89 f3                	mov    %esi,%ebx
  80144d:	80 fb 09             	cmp    $0x9,%bl
  801450:	77 08                	ja     80145a <strtol+0x8b>
			dig = *s - '0';
  801452:	0f be d2             	movsbl %dl,%edx
  801455:	83 ea 30             	sub    $0x30,%edx
  801458:	eb 22                	jmp    80147c <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  80145a:	8d 72 9f             	lea    -0x61(%edx),%esi
  80145d:	89 f3                	mov    %esi,%ebx
  80145f:	80 fb 19             	cmp    $0x19,%bl
  801462:	77 08                	ja     80146c <strtol+0x9d>
			dig = *s - 'a' + 10;
  801464:	0f be d2             	movsbl %dl,%edx
  801467:	83 ea 57             	sub    $0x57,%edx
  80146a:	eb 10                	jmp    80147c <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  80146c:	8d 72 bf             	lea    -0x41(%edx),%esi
  80146f:	89 f3                	mov    %esi,%ebx
  801471:	80 fb 19             	cmp    $0x19,%bl
  801474:	77 16                	ja     80148c <strtol+0xbd>
			dig = *s - 'A' + 10;
  801476:	0f be d2             	movsbl %dl,%edx
  801479:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  80147c:	3b 55 10             	cmp    0x10(%ebp),%edx
  80147f:	7d 0b                	jge    80148c <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801481:	83 c1 01             	add    $0x1,%ecx
  801484:	0f af 45 10          	imul   0x10(%ebp),%eax
  801488:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  80148a:	eb b9                	jmp    801445 <strtol+0x76>

	if (endptr)
  80148c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801490:	74 0d                	je     80149f <strtol+0xd0>
		*endptr = (char *) s;
  801492:	8b 75 0c             	mov    0xc(%ebp),%esi
  801495:	89 0e                	mov    %ecx,(%esi)
  801497:	eb 06                	jmp    80149f <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801499:	85 db                	test   %ebx,%ebx
  80149b:	74 98                	je     801435 <strtol+0x66>
  80149d:	eb 9e                	jmp    80143d <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  80149f:	89 c2                	mov    %eax,%edx
  8014a1:	f7 da                	neg    %edx
  8014a3:	85 ff                	test   %edi,%edi
  8014a5:	0f 45 c2             	cmovne %edx,%eax
}
  8014a8:	5b                   	pop    %ebx
  8014a9:	5e                   	pop    %esi
  8014aa:	5f                   	pop    %edi
  8014ab:	5d                   	pop    %ebp
  8014ac:	c3                   	ret    

008014ad <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8014ad:	55                   	push   %ebp
  8014ae:	89 e5                	mov    %esp,%ebp
  8014b0:	57                   	push   %edi
  8014b1:	56                   	push   %esi
  8014b2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8014b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014bb:	8b 55 08             	mov    0x8(%ebp),%edx
  8014be:	89 c3                	mov    %eax,%ebx
  8014c0:	89 c7                	mov    %eax,%edi
  8014c2:	89 c6                	mov    %eax,%esi
  8014c4:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8014c6:	5b                   	pop    %ebx
  8014c7:	5e                   	pop    %esi
  8014c8:	5f                   	pop    %edi
  8014c9:	5d                   	pop    %ebp
  8014ca:	c3                   	ret    

008014cb <sys_cgetc>:

int
sys_cgetc(void)
{
  8014cb:	55                   	push   %ebp
  8014cc:	89 e5                	mov    %esp,%ebp
  8014ce:	57                   	push   %edi
  8014cf:	56                   	push   %esi
  8014d0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8014d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8014db:	89 d1                	mov    %edx,%ecx
  8014dd:	89 d3                	mov    %edx,%ebx
  8014df:	89 d7                	mov    %edx,%edi
  8014e1:	89 d6                	mov    %edx,%esi
  8014e3:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8014e5:	5b                   	pop    %ebx
  8014e6:	5e                   	pop    %esi
  8014e7:	5f                   	pop    %edi
  8014e8:	5d                   	pop    %ebp
  8014e9:	c3                   	ret    

008014ea <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8014ea:	55                   	push   %ebp
  8014eb:	89 e5                	mov    %esp,%ebp
  8014ed:	57                   	push   %edi
  8014ee:	56                   	push   %esi
  8014ef:	53                   	push   %ebx
  8014f0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014f3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8014f8:	b8 03 00 00 00       	mov    $0x3,%eax
  8014fd:	8b 55 08             	mov    0x8(%ebp),%edx
  801500:	89 cb                	mov    %ecx,%ebx
  801502:	89 cf                	mov    %ecx,%edi
  801504:	89 ce                	mov    %ecx,%esi
  801506:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801508:	85 c0                	test   %eax,%eax
  80150a:	7e 17                	jle    801523 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80150c:	83 ec 0c             	sub    $0xc,%esp
  80150f:	50                   	push   %eax
  801510:	6a 03                	push   $0x3
  801512:	68 0f 3c 80 00       	push   $0x803c0f
  801517:	6a 23                	push   $0x23
  801519:	68 2c 3c 80 00       	push   $0x803c2c
  80151e:	e8 f2 f4 ff ff       	call   800a15 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801523:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801526:	5b                   	pop    %ebx
  801527:	5e                   	pop    %esi
  801528:	5f                   	pop    %edi
  801529:	5d                   	pop    %ebp
  80152a:	c3                   	ret    

0080152b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80152b:	55                   	push   %ebp
  80152c:	89 e5                	mov    %esp,%ebp
  80152e:	57                   	push   %edi
  80152f:	56                   	push   %esi
  801530:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801531:	ba 00 00 00 00       	mov    $0x0,%edx
  801536:	b8 02 00 00 00       	mov    $0x2,%eax
  80153b:	89 d1                	mov    %edx,%ecx
  80153d:	89 d3                	mov    %edx,%ebx
  80153f:	89 d7                	mov    %edx,%edi
  801541:	89 d6                	mov    %edx,%esi
  801543:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801545:	5b                   	pop    %ebx
  801546:	5e                   	pop    %esi
  801547:	5f                   	pop    %edi
  801548:	5d                   	pop    %ebp
  801549:	c3                   	ret    

0080154a <sys_yield>:

void
sys_yield(void)
{
  80154a:	55                   	push   %ebp
  80154b:	89 e5                	mov    %esp,%ebp
  80154d:	57                   	push   %edi
  80154e:	56                   	push   %esi
  80154f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801550:	ba 00 00 00 00       	mov    $0x0,%edx
  801555:	b8 0b 00 00 00       	mov    $0xb,%eax
  80155a:	89 d1                	mov    %edx,%ecx
  80155c:	89 d3                	mov    %edx,%ebx
  80155e:	89 d7                	mov    %edx,%edi
  801560:	89 d6                	mov    %edx,%esi
  801562:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801564:	5b                   	pop    %ebx
  801565:	5e                   	pop    %esi
  801566:	5f                   	pop    %edi
  801567:	5d                   	pop    %ebp
  801568:	c3                   	ret    

00801569 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801569:	55                   	push   %ebp
  80156a:	89 e5                	mov    %esp,%ebp
  80156c:	57                   	push   %edi
  80156d:	56                   	push   %esi
  80156e:	53                   	push   %ebx
  80156f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801572:	be 00 00 00 00       	mov    $0x0,%esi
  801577:	b8 04 00 00 00       	mov    $0x4,%eax
  80157c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80157f:	8b 55 08             	mov    0x8(%ebp),%edx
  801582:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801585:	89 f7                	mov    %esi,%edi
  801587:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801589:	85 c0                	test   %eax,%eax
  80158b:	7e 17                	jle    8015a4 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80158d:	83 ec 0c             	sub    $0xc,%esp
  801590:	50                   	push   %eax
  801591:	6a 04                	push   $0x4
  801593:	68 0f 3c 80 00       	push   $0x803c0f
  801598:	6a 23                	push   $0x23
  80159a:	68 2c 3c 80 00       	push   $0x803c2c
  80159f:	e8 71 f4 ff ff       	call   800a15 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8015a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015a7:	5b                   	pop    %ebx
  8015a8:	5e                   	pop    %esi
  8015a9:	5f                   	pop    %edi
  8015aa:	5d                   	pop    %ebp
  8015ab:	c3                   	ret    

008015ac <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8015ac:	55                   	push   %ebp
  8015ad:	89 e5                	mov    %esp,%ebp
  8015af:	57                   	push   %edi
  8015b0:	56                   	push   %esi
  8015b1:	53                   	push   %ebx
  8015b2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8015b5:	b8 05 00 00 00       	mov    $0x5,%eax
  8015ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015bd:	8b 55 08             	mov    0x8(%ebp),%edx
  8015c0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8015c3:	8b 7d 14             	mov    0x14(%ebp),%edi
  8015c6:	8b 75 18             	mov    0x18(%ebp),%esi
  8015c9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8015cb:	85 c0                	test   %eax,%eax
  8015cd:	7e 17                	jle    8015e6 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8015cf:	83 ec 0c             	sub    $0xc,%esp
  8015d2:	50                   	push   %eax
  8015d3:	6a 05                	push   $0x5
  8015d5:	68 0f 3c 80 00       	push   $0x803c0f
  8015da:	6a 23                	push   $0x23
  8015dc:	68 2c 3c 80 00       	push   $0x803c2c
  8015e1:	e8 2f f4 ff ff       	call   800a15 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8015e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015e9:	5b                   	pop    %ebx
  8015ea:	5e                   	pop    %esi
  8015eb:	5f                   	pop    %edi
  8015ec:	5d                   	pop    %ebp
  8015ed:	c3                   	ret    

008015ee <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8015ee:	55                   	push   %ebp
  8015ef:	89 e5                	mov    %esp,%ebp
  8015f1:	57                   	push   %edi
  8015f2:	56                   	push   %esi
  8015f3:	53                   	push   %ebx
  8015f4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8015f7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015fc:	b8 06 00 00 00       	mov    $0x6,%eax
  801601:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801604:	8b 55 08             	mov    0x8(%ebp),%edx
  801607:	89 df                	mov    %ebx,%edi
  801609:	89 de                	mov    %ebx,%esi
  80160b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80160d:	85 c0                	test   %eax,%eax
  80160f:	7e 17                	jle    801628 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801611:	83 ec 0c             	sub    $0xc,%esp
  801614:	50                   	push   %eax
  801615:	6a 06                	push   $0x6
  801617:	68 0f 3c 80 00       	push   $0x803c0f
  80161c:	6a 23                	push   $0x23
  80161e:	68 2c 3c 80 00       	push   $0x803c2c
  801623:	e8 ed f3 ff ff       	call   800a15 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801628:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80162b:	5b                   	pop    %ebx
  80162c:	5e                   	pop    %esi
  80162d:	5f                   	pop    %edi
  80162e:	5d                   	pop    %ebp
  80162f:	c3                   	ret    

00801630 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801630:	55                   	push   %ebp
  801631:	89 e5                	mov    %esp,%ebp
  801633:	57                   	push   %edi
  801634:	56                   	push   %esi
  801635:	53                   	push   %ebx
  801636:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801639:	bb 00 00 00 00       	mov    $0x0,%ebx
  80163e:	b8 08 00 00 00       	mov    $0x8,%eax
  801643:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801646:	8b 55 08             	mov    0x8(%ebp),%edx
  801649:	89 df                	mov    %ebx,%edi
  80164b:	89 de                	mov    %ebx,%esi
  80164d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80164f:	85 c0                	test   %eax,%eax
  801651:	7e 17                	jle    80166a <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801653:	83 ec 0c             	sub    $0xc,%esp
  801656:	50                   	push   %eax
  801657:	6a 08                	push   $0x8
  801659:	68 0f 3c 80 00       	push   $0x803c0f
  80165e:	6a 23                	push   $0x23
  801660:	68 2c 3c 80 00       	push   $0x803c2c
  801665:	e8 ab f3 ff ff       	call   800a15 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80166a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80166d:	5b                   	pop    %ebx
  80166e:	5e                   	pop    %esi
  80166f:	5f                   	pop    %edi
  801670:	5d                   	pop    %ebp
  801671:	c3                   	ret    

00801672 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801672:	55                   	push   %ebp
  801673:	89 e5                	mov    %esp,%ebp
  801675:	57                   	push   %edi
  801676:	56                   	push   %esi
  801677:	53                   	push   %ebx
  801678:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80167b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801680:	b8 09 00 00 00       	mov    $0x9,%eax
  801685:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801688:	8b 55 08             	mov    0x8(%ebp),%edx
  80168b:	89 df                	mov    %ebx,%edi
  80168d:	89 de                	mov    %ebx,%esi
  80168f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801691:	85 c0                	test   %eax,%eax
  801693:	7e 17                	jle    8016ac <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801695:	83 ec 0c             	sub    $0xc,%esp
  801698:	50                   	push   %eax
  801699:	6a 09                	push   $0x9
  80169b:	68 0f 3c 80 00       	push   $0x803c0f
  8016a0:	6a 23                	push   $0x23
  8016a2:	68 2c 3c 80 00       	push   $0x803c2c
  8016a7:	e8 69 f3 ff ff       	call   800a15 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8016ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016af:	5b                   	pop    %ebx
  8016b0:	5e                   	pop    %esi
  8016b1:	5f                   	pop    %edi
  8016b2:	5d                   	pop    %ebp
  8016b3:	c3                   	ret    

008016b4 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8016b4:	55                   	push   %ebp
  8016b5:	89 e5                	mov    %esp,%ebp
  8016b7:	57                   	push   %edi
  8016b8:	56                   	push   %esi
  8016b9:	53                   	push   %ebx
  8016ba:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8016bd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016c2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8016c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8016cd:	89 df                	mov    %ebx,%edi
  8016cf:	89 de                	mov    %ebx,%esi
  8016d1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8016d3:	85 c0                	test   %eax,%eax
  8016d5:	7e 17                	jle    8016ee <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8016d7:	83 ec 0c             	sub    $0xc,%esp
  8016da:	50                   	push   %eax
  8016db:	6a 0a                	push   $0xa
  8016dd:	68 0f 3c 80 00       	push   $0x803c0f
  8016e2:	6a 23                	push   $0x23
  8016e4:	68 2c 3c 80 00       	push   $0x803c2c
  8016e9:	e8 27 f3 ff ff       	call   800a15 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8016ee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016f1:	5b                   	pop    %ebx
  8016f2:	5e                   	pop    %esi
  8016f3:	5f                   	pop    %edi
  8016f4:	5d                   	pop    %ebp
  8016f5:	c3                   	ret    

008016f6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8016f6:	55                   	push   %ebp
  8016f7:	89 e5                	mov    %esp,%ebp
  8016f9:	57                   	push   %edi
  8016fa:	56                   	push   %esi
  8016fb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8016fc:	be 00 00 00 00       	mov    $0x0,%esi
  801701:	b8 0c 00 00 00       	mov    $0xc,%eax
  801706:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801709:	8b 55 08             	mov    0x8(%ebp),%edx
  80170c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80170f:	8b 7d 14             	mov    0x14(%ebp),%edi
  801712:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801714:	5b                   	pop    %ebx
  801715:	5e                   	pop    %esi
  801716:	5f                   	pop    %edi
  801717:	5d                   	pop    %ebp
  801718:	c3                   	ret    

00801719 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801719:	55                   	push   %ebp
  80171a:	89 e5                	mov    %esp,%ebp
  80171c:	57                   	push   %edi
  80171d:	56                   	push   %esi
  80171e:	53                   	push   %ebx
  80171f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801722:	b9 00 00 00 00       	mov    $0x0,%ecx
  801727:	b8 0d 00 00 00       	mov    $0xd,%eax
  80172c:	8b 55 08             	mov    0x8(%ebp),%edx
  80172f:	89 cb                	mov    %ecx,%ebx
  801731:	89 cf                	mov    %ecx,%edi
  801733:	89 ce                	mov    %ecx,%esi
  801735:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801737:	85 c0                	test   %eax,%eax
  801739:	7e 17                	jle    801752 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80173b:	83 ec 0c             	sub    $0xc,%esp
  80173e:	50                   	push   %eax
  80173f:	6a 0d                	push   $0xd
  801741:	68 0f 3c 80 00       	push   $0x803c0f
  801746:	6a 23                	push   $0x23
  801748:	68 2c 3c 80 00       	push   $0x803c2c
  80174d:	e8 c3 f2 ff ff       	call   800a15 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801752:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801755:	5b                   	pop    %ebx
  801756:	5e                   	pop    %esi
  801757:	5f                   	pop    %edi
  801758:	5d                   	pop    %ebp
  801759:	c3                   	ret    

0080175a <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80175a:	55                   	push   %ebp
  80175b:	89 e5                	mov    %esp,%ebp
  80175d:	57                   	push   %edi
  80175e:	56                   	push   %esi
  80175f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801760:	ba 00 00 00 00       	mov    $0x0,%edx
  801765:	b8 0e 00 00 00       	mov    $0xe,%eax
  80176a:	89 d1                	mov    %edx,%ecx
  80176c:	89 d3                	mov    %edx,%ebx
  80176e:	89 d7                	mov    %edx,%edi
  801770:	89 d6                	mov    %edx,%esi
  801772:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  801774:	5b                   	pop    %ebx
  801775:	5e                   	pop    %esi
  801776:	5f                   	pop    %edi
  801777:	5d                   	pop    %ebp
  801778:	c3                   	ret    

00801779 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  801779:	55                   	push   %ebp
  80177a:	89 e5                	mov    %esp,%ebp
  80177c:	53                   	push   %ebx
  80177d:	83 ec 04             	sub    $0x4,%esp
	int r;
	void * address = (void *)(pn*PGSIZE);
  801780:	89 d3                	mov    %edx,%ebx
  801782:	c1 e3 0c             	shl    $0xc,%ebx
	
	if((uvpt[pn] & PTE_SHARE))
  801785:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  80178c:	f6 c5 04             	test   $0x4,%ch
  80178f:	74 38                	je     8017c9 <duppage+0x50>
	{
		if ((r = sys_page_map(0, address, envid, address, (uvpt[pn] | PTE_SYSCALL))) < 0)
  801791:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801798:	83 ec 0c             	sub    $0xc,%esp
  80179b:	81 ca 07 0e 00 00    	or     $0xe07,%edx
  8017a1:	52                   	push   %edx
  8017a2:	53                   	push   %ebx
  8017a3:	50                   	push   %eax
  8017a4:	53                   	push   %ebx
  8017a5:	6a 00                	push   $0x0
  8017a7:	e8 00 fe ff ff       	call   8015ac <sys_page_map>
  8017ac:	83 c4 20             	add    $0x20,%esp
  8017af:	85 c0                	test   %eax,%eax
  8017b1:	0f 89 b8 00 00 00    	jns    80186f <duppage+0xf6>
			panic("sys_page_map: %e", r);
  8017b7:	50                   	push   %eax
  8017b8:	68 3a 3c 80 00       	push   $0x803c3a
  8017bd:	6a 4e                	push   $0x4e
  8017bf:	68 4b 3c 80 00       	push   $0x803c4b
  8017c4:	e8 4c f2 ff ff       	call   800a15 <_panic>
	}
	else if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW))
  8017c9:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  8017d0:	f6 c1 02             	test   $0x2,%cl
  8017d3:	75 0c                	jne    8017e1 <duppage+0x68>
  8017d5:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  8017dc:	f6 c5 08             	test   $0x8,%ch
  8017df:	74 57                	je     801838 <duppage+0xbf>
	{
		int perm = 0;
		perm |= PTE_P|PTE_U|PTE_COW;
	
		if ((r = sys_page_map(0, address, envid, address, perm)) < 0)
  8017e1:	83 ec 0c             	sub    $0xc,%esp
  8017e4:	68 05 08 00 00       	push   $0x805
  8017e9:	53                   	push   %ebx
  8017ea:	50                   	push   %eax
  8017eb:	53                   	push   %ebx
  8017ec:	6a 00                	push   $0x0
  8017ee:	e8 b9 fd ff ff       	call   8015ac <sys_page_map>
  8017f3:	83 c4 20             	add    $0x20,%esp
  8017f6:	85 c0                	test   %eax,%eax
  8017f8:	79 12                	jns    80180c <duppage+0x93>
			panic("sys_page_map: %e", r);
  8017fa:	50                   	push   %eax
  8017fb:	68 3a 3c 80 00       	push   $0x803c3a
  801800:	6a 56                	push   $0x56
  801802:	68 4b 3c 80 00       	push   $0x803c4b
  801807:	e8 09 f2 ff ff       	call   800a15 <_panic>
		if ((r = sys_page_map(0, address, 0, address, perm)) < 0)
  80180c:	83 ec 0c             	sub    $0xc,%esp
  80180f:	68 05 08 00 00       	push   $0x805
  801814:	53                   	push   %ebx
  801815:	6a 00                	push   $0x0
  801817:	53                   	push   %ebx
  801818:	6a 00                	push   $0x0
  80181a:	e8 8d fd ff ff       	call   8015ac <sys_page_map>
  80181f:	83 c4 20             	add    $0x20,%esp
  801822:	85 c0                	test   %eax,%eax
  801824:	79 49                	jns    80186f <duppage+0xf6>
			panic("sys_page_map: %e", r);
  801826:	50                   	push   %eax
  801827:	68 3a 3c 80 00       	push   $0x803c3a
  80182c:	6a 58                	push   $0x58
  80182e:	68 4b 3c 80 00       	push   $0x803c4b
  801833:	e8 dd f1 ff ff       	call   800a15 <_panic>
	}
	else if((uvpt[pn] & ~PTE_U) == 0)
  801838:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80183f:	f7 c2 fb ff ff ff    	test   $0xfffffffb,%edx
  801845:	75 28                	jne    80186f <duppage+0xf6>
	{
		//cprintf("im here");
		if ((r = sys_page_map(0, address, envid, address, PTE_P|PTE_U)) < 0)
  801847:	83 ec 0c             	sub    $0xc,%esp
  80184a:	6a 05                	push   $0x5
  80184c:	53                   	push   %ebx
  80184d:	50                   	push   %eax
  80184e:	53                   	push   %ebx
  80184f:	6a 00                	push   $0x0
  801851:	e8 56 fd ff ff       	call   8015ac <sys_page_map>
  801856:	83 c4 20             	add    $0x20,%esp
  801859:	85 c0                	test   %eax,%eax
  80185b:	79 12                	jns    80186f <duppage+0xf6>
			panic("sys_page_map: %e", r);	
  80185d:	50                   	push   %eax
  80185e:	68 3a 3c 80 00       	push   $0x803c3a
  801863:	6a 5e                	push   $0x5e
  801865:	68 4b 3c 80 00       	push   $0x803c4b
  80186a:	e8 a6 f1 ff ff       	call   800a15 <_panic>
	}
	return 0;
}
  80186f:	b8 00 00 00 00       	mov    $0x0,%eax
  801874:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801877:	c9                   	leave  
  801878:	c3                   	ret    

00801879 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801879:	55                   	push   %ebp
  80187a:	89 e5                	mov    %esp,%ebp
  80187c:	53                   	push   %ebx
  80187d:	83 ec 08             	sub    $0x8,%esp
	void *addr = (void *) utf->utf_fault_va;
  801880:	8b 45 08             	mov    0x8(%ebp),%eax
  801883:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	unsigned pn = ((uint32_t)addr)/PGSIZE;
  801885:	89 d8                	mov    %ebx,%eax
  801887:	c1 e8 0c             	shr    $0xc,%eax
	pte_t pte = uvpt[pn];
  80188a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// Allocate a new page, mapped at temp location
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  801891:	6a 07                	push   $0x7
  801893:	68 00 f0 7f 00       	push   $0x7ff000
  801898:	6a 00                	push   $0x0
  80189a:	e8 ca fc ff ff       	call   801569 <sys_page_alloc>
  80189f:	83 c4 10             	add    $0x10,%esp
  8018a2:	85 c0                	test   %eax,%eax
  8018a4:	79 12                	jns    8018b8 <pgfault+0x3f>
		panic("sys_page_alloc: %e", r);
  8018a6:	50                   	push   %eax
  8018a7:	68 56 3c 80 00       	push   $0x803c56
  8018ac:	6a 2b                	push   $0x2b
  8018ae:	68 4b 3c 80 00       	push   $0x803c4b
  8018b3:	e8 5d f1 ff ff       	call   800a15 <_panic>

	// Copy the data from the old page to this new page
	void *addr_pgstart = (void *) ROUNDDOWN(addr, PGSIZE);
  8018b8:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr_pgstart, PGSIZE);
  8018be:	83 ec 04             	sub    $0x4,%esp
  8018c1:	68 00 10 00 00       	push   $0x1000
  8018c6:	53                   	push   %ebx
  8018c7:	68 00 f0 7f 00       	push   $0x7ff000
  8018cc:	e8 27 fa ff ff       	call   8012f8 <memmove>

	// Move the new page to the old page's address
	if ((r = sys_page_map(0, PFTEMP, 0, addr_pgstart, PTE_P|PTE_U|PTE_W)) < 0)
  8018d1:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  8018d8:	53                   	push   %ebx
  8018d9:	6a 00                	push   $0x0
  8018db:	68 00 f0 7f 00       	push   $0x7ff000
  8018e0:	6a 00                	push   $0x0
  8018e2:	e8 c5 fc ff ff       	call   8015ac <sys_page_map>
  8018e7:	83 c4 20             	add    $0x20,%esp
  8018ea:	85 c0                	test   %eax,%eax
  8018ec:	79 12                	jns    801900 <pgfault+0x87>
		panic("sys_page_map: %e", r);
  8018ee:	50                   	push   %eax
  8018ef:	68 3a 3c 80 00       	push   $0x803c3a
  8018f4:	6a 33                	push   $0x33
  8018f6:	68 4b 3c 80 00       	push   $0x803c4b
  8018fb:	e8 15 f1 ff ff       	call   800a15 <_panic>

	// Unmap the temp location
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  801900:	83 ec 08             	sub    $0x8,%esp
  801903:	68 00 f0 7f 00       	push   $0x7ff000
  801908:	6a 00                	push   $0x0
  80190a:	e8 df fc ff ff       	call   8015ee <sys_page_unmap>
  80190f:	83 c4 10             	add    $0x10,%esp
  801912:	85 c0                	test   %eax,%eax
  801914:	79 12                	jns    801928 <pgfault+0xaf>
		panic("sys_page_unmap: %e", r);
  801916:	50                   	push   %eax
  801917:	68 69 3c 80 00       	push   $0x803c69
  80191c:	6a 37                	push   $0x37
  80191e:	68 4b 3c 80 00       	push   $0x803c4b
  801923:	e8 ed f0 ff ff       	call   800a15 <_panic>
}
  801928:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80192b:	c9                   	leave  
  80192c:	c3                   	ret    

0080192d <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80192d:	55                   	push   %ebp
  80192e:	89 e5                	mov    %esp,%ebp
  801930:	56                   	push   %esi
  801931:	53                   	push   %ebx
  801932:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
	// Set up page fault handler
	set_pgfault_handler(&pgfault);
  801935:	68 79 18 80 00       	push   $0x801879
  80193a:	e8 41 19 00 00       	call   803280 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  80193f:	b8 07 00 00 00       	mov    $0x7,%eax
  801944:	cd 30                	int    $0x30

	// Create child
	envid_t envid = sys_exofork();
  801946:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (envid < 0) {
  801949:	83 c4 10             	add    $0x10,%esp
  80194c:	85 c0                	test   %eax,%eax
  80194e:	79 12                	jns    801962 <fork+0x35>
		panic("sys_exofork: %e", envid);
  801950:	50                   	push   %eax
  801951:	68 7c 3c 80 00       	push   $0x803c7c
  801956:	6a 7c                	push   $0x7c
  801958:	68 4b 3c 80 00       	push   $0x803c4b
  80195d:	e8 b3 f0 ff ff       	call   800a15 <_panic>
		return envid;
	}
	if (envid == 0) {
  801962:	85 c0                	test   %eax,%eax
  801964:	75 1e                	jne    801984 <fork+0x57>
		// We are the child.
		thisenv = &envs[ENVX(sys_getenvid())]; // Fix thisenv
  801966:	e8 c0 fb ff ff       	call   80152b <sys_getenvid>
  80196b:	25 ff 03 00 00       	and    $0x3ff,%eax
  801970:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801973:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801978:	a3 28 54 80 00       	mov    %eax,0x805428
		return 0;
  80197d:	b8 00 00 00 00       	mov    $0x0,%eax
  801982:	eb 7d                	jmp    801a01 <fork+0xd4>

	// Set page fault handler on the child.
	// The parent needs to do it, else the child wouldn't be able to handle
	// the fault when trying to access it's stack (which happens as soon it starts)
	extern void _pgfault_upcall(void);
	sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);
  801984:	83 ec 04             	sub    $0x4,%esp
  801987:	6a 07                	push   $0x7
  801989:	68 00 f0 bf ee       	push   $0xeebff000
  80198e:	50                   	push   %eax
  80198f:	e8 d5 fb ff ff       	call   801569 <sys_page_alloc>
	sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  801994:	83 c4 08             	add    $0x8,%esp
  801997:	68 c5 32 80 00       	push   $0x8032c5
  80199c:	ff 75 f4             	pushl  -0xc(%ebp)
  80199f:	e8 10 fd ff ff       	call   8016b4 <sys_env_set_pgfault_upcall>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  8019a4:	be 04 80 80 00       	mov    $0x808004,%esi
  8019a9:	c1 ee 0c             	shr    $0xc,%esi
  8019ac:	83 c4 10             	add    $0x10,%esp
  8019af:	bb 00 08 00 00       	mov    $0x800,%ebx
  8019b4:	eb 0d                	jmp    8019c3 <fork+0x96>
		duppage(envid, pn);
  8019b6:	89 da                	mov    %ebx,%edx
  8019b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019bb:	e8 b9 fd ff ff       	call   801779 <duppage>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  8019c0:	83 c3 01             	add    $0x1,%ebx
  8019c3:	39 f3                	cmp    %esi,%ebx
  8019c5:	76 ef                	jbe    8019b6 <fork+0x89>
	}

	// Also copy the stack we are currently running on
	// I think it should loop from ustacktop to this page, since the stack
	// can have more than 1 page
	duppage(envid, ((uint32_t) &envid)/PGSIZE);
  8019c7:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8019ca:	c1 ea 0c             	shr    $0xc,%edx
  8019cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019d0:	e8 a4 fd ff ff       	call   801779 <duppage>

	// Start the child environmnet running
	int r;
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  8019d5:	83 ec 08             	sub    $0x8,%esp
  8019d8:	6a 02                	push   $0x2
  8019da:	ff 75 f4             	pushl  -0xc(%ebp)
  8019dd:	e8 4e fc ff ff       	call   801630 <sys_env_set_status>
  8019e2:	83 c4 10             	add    $0x10,%esp
  8019e5:	85 c0                	test   %eax,%eax
  8019e7:	79 15                	jns    8019fe <fork+0xd1>
		panic("sys_env_set_status: %e", r);
  8019e9:	50                   	push   %eax
  8019ea:	68 8c 3c 80 00       	push   $0x803c8c
  8019ef:	68 9c 00 00 00       	push   $0x9c
  8019f4:	68 4b 3c 80 00       	push   $0x803c4b
  8019f9:	e8 17 f0 ff ff       	call   800a15 <_panic>
		return r;
	}

	return envid;
  8019fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  801a01:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a04:	5b                   	pop    %ebx
  801a05:	5e                   	pop    %esi
  801a06:	5d                   	pop    %ebp
  801a07:	c3                   	ret    

00801a08 <sfork>:

// Challenge!
int
sfork(void)
{
  801a08:	55                   	push   %ebp
  801a09:	89 e5                	mov    %esp,%ebp
  801a0b:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801a0e:	68 a3 3c 80 00       	push   $0x803ca3
  801a13:	68 a7 00 00 00       	push   $0xa7
  801a18:	68 4b 3c 80 00       	push   $0x803c4b
  801a1d:	e8 f3 ef ff ff       	call   800a15 <_panic>

00801a22 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  801a22:	55                   	push   %ebp
  801a23:	89 e5                	mov    %esp,%ebp
  801a25:	8b 55 08             	mov    0x8(%ebp),%edx
  801a28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a2b:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  801a2e:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  801a30:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  801a33:	83 3a 01             	cmpl   $0x1,(%edx)
  801a36:	7e 09                	jle    801a41 <argstart+0x1f>
  801a38:	ba e1 36 80 00       	mov    $0x8036e1,%edx
  801a3d:	85 c9                	test   %ecx,%ecx
  801a3f:	75 05                	jne    801a46 <argstart+0x24>
  801a41:	ba 00 00 00 00       	mov    $0x0,%edx
  801a46:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  801a49:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  801a50:	5d                   	pop    %ebp
  801a51:	c3                   	ret    

00801a52 <argnext>:

int
argnext(struct Argstate *args)
{
  801a52:	55                   	push   %ebp
  801a53:	89 e5                	mov    %esp,%ebp
  801a55:	53                   	push   %ebx
  801a56:	83 ec 04             	sub    $0x4,%esp
  801a59:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  801a5c:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  801a63:	8b 43 08             	mov    0x8(%ebx),%eax
  801a66:	85 c0                	test   %eax,%eax
  801a68:	74 6f                	je     801ad9 <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  801a6a:	80 38 00             	cmpb   $0x0,(%eax)
  801a6d:	75 4e                	jne    801abd <argnext+0x6b>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  801a6f:	8b 0b                	mov    (%ebx),%ecx
  801a71:	83 39 01             	cmpl   $0x1,(%ecx)
  801a74:	74 55                	je     801acb <argnext+0x79>
		    || args->argv[1][0] != '-'
  801a76:	8b 53 04             	mov    0x4(%ebx),%edx
  801a79:	8b 42 04             	mov    0x4(%edx),%eax
  801a7c:	80 38 2d             	cmpb   $0x2d,(%eax)
  801a7f:	75 4a                	jne    801acb <argnext+0x79>
		    || args->argv[1][1] == '\0')
  801a81:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801a85:	74 44                	je     801acb <argnext+0x79>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  801a87:	83 c0 01             	add    $0x1,%eax
  801a8a:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801a8d:	83 ec 04             	sub    $0x4,%esp
  801a90:	8b 01                	mov    (%ecx),%eax
  801a92:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801a99:	50                   	push   %eax
  801a9a:	8d 42 08             	lea    0x8(%edx),%eax
  801a9d:	50                   	push   %eax
  801a9e:	83 c2 04             	add    $0x4,%edx
  801aa1:	52                   	push   %edx
  801aa2:	e8 51 f8 ff ff       	call   8012f8 <memmove>
		(*args->argc)--;
  801aa7:	8b 03                	mov    (%ebx),%eax
  801aa9:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801aac:	8b 43 08             	mov    0x8(%ebx),%eax
  801aaf:	83 c4 10             	add    $0x10,%esp
  801ab2:	80 38 2d             	cmpb   $0x2d,(%eax)
  801ab5:	75 06                	jne    801abd <argnext+0x6b>
  801ab7:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801abb:	74 0e                	je     801acb <argnext+0x79>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  801abd:	8b 53 08             	mov    0x8(%ebx),%edx
  801ac0:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  801ac3:	83 c2 01             	add    $0x1,%edx
  801ac6:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  801ac9:	eb 13                	jmp    801ade <argnext+0x8c>

    endofargs:
	args->curarg = 0;
  801acb:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  801ad2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801ad7:	eb 05                	jmp    801ade <argnext+0x8c>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  801ad9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  801ade:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ae1:	c9                   	leave  
  801ae2:	c3                   	ret    

00801ae3 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  801ae3:	55                   	push   %ebp
  801ae4:	89 e5                	mov    %esp,%ebp
  801ae6:	53                   	push   %ebx
  801ae7:	83 ec 04             	sub    $0x4,%esp
  801aea:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  801aed:	8b 43 08             	mov    0x8(%ebx),%eax
  801af0:	85 c0                	test   %eax,%eax
  801af2:	74 58                	je     801b4c <argnextvalue+0x69>
		return 0;
	if (*args->curarg) {
  801af4:	80 38 00             	cmpb   $0x0,(%eax)
  801af7:	74 0c                	je     801b05 <argnextvalue+0x22>
		args->argvalue = args->curarg;
  801af9:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  801afc:	c7 43 08 e1 36 80 00 	movl   $0x8036e1,0x8(%ebx)
  801b03:	eb 42                	jmp    801b47 <argnextvalue+0x64>
	} else if (*args->argc > 1) {
  801b05:	8b 13                	mov    (%ebx),%edx
  801b07:	83 3a 01             	cmpl   $0x1,(%edx)
  801b0a:	7e 2d                	jle    801b39 <argnextvalue+0x56>
		args->argvalue = args->argv[1];
  801b0c:	8b 43 04             	mov    0x4(%ebx),%eax
  801b0f:	8b 48 04             	mov    0x4(%eax),%ecx
  801b12:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801b15:	83 ec 04             	sub    $0x4,%esp
  801b18:	8b 12                	mov    (%edx),%edx
  801b1a:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  801b21:	52                   	push   %edx
  801b22:	8d 50 08             	lea    0x8(%eax),%edx
  801b25:	52                   	push   %edx
  801b26:	83 c0 04             	add    $0x4,%eax
  801b29:	50                   	push   %eax
  801b2a:	e8 c9 f7 ff ff       	call   8012f8 <memmove>
		(*args->argc)--;
  801b2f:	8b 03                	mov    (%ebx),%eax
  801b31:	83 28 01             	subl   $0x1,(%eax)
  801b34:	83 c4 10             	add    $0x10,%esp
  801b37:	eb 0e                	jmp    801b47 <argnextvalue+0x64>
	} else {
		args->argvalue = 0;
  801b39:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  801b40:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  801b47:	8b 43 0c             	mov    0xc(%ebx),%eax
  801b4a:	eb 05                	jmp    801b51 <argnextvalue+0x6e>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  801b4c:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  801b51:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b54:	c9                   	leave  
  801b55:	c3                   	ret    

00801b56 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  801b56:	55                   	push   %ebp
  801b57:	89 e5                	mov    %esp,%ebp
  801b59:	83 ec 08             	sub    $0x8,%esp
  801b5c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801b5f:	8b 51 0c             	mov    0xc(%ecx),%edx
  801b62:	89 d0                	mov    %edx,%eax
  801b64:	85 d2                	test   %edx,%edx
  801b66:	75 0c                	jne    801b74 <argvalue+0x1e>
  801b68:	83 ec 0c             	sub    $0xc,%esp
  801b6b:	51                   	push   %ecx
  801b6c:	e8 72 ff ff ff       	call   801ae3 <argnextvalue>
  801b71:	83 c4 10             	add    $0x10,%esp
}
  801b74:	c9                   	leave  
  801b75:	c3                   	ret    

00801b76 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801b76:	55                   	push   %ebp
  801b77:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801b79:	8b 45 08             	mov    0x8(%ebp),%eax
  801b7c:	05 00 00 00 30       	add    $0x30000000,%eax
  801b81:	c1 e8 0c             	shr    $0xc,%eax
}
  801b84:	5d                   	pop    %ebp
  801b85:	c3                   	ret    

00801b86 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801b86:	55                   	push   %ebp
  801b87:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801b89:	8b 45 08             	mov    0x8(%ebp),%eax
  801b8c:	05 00 00 00 30       	add    $0x30000000,%eax
  801b91:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801b96:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801b9b:	5d                   	pop    %ebp
  801b9c:	c3                   	ret    

00801b9d <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801b9d:	55                   	push   %ebp
  801b9e:	89 e5                	mov    %esp,%ebp
  801ba0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ba3:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801ba8:	89 c2                	mov    %eax,%edx
  801baa:	c1 ea 16             	shr    $0x16,%edx
  801bad:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801bb4:	f6 c2 01             	test   $0x1,%dl
  801bb7:	74 11                	je     801bca <fd_alloc+0x2d>
  801bb9:	89 c2                	mov    %eax,%edx
  801bbb:	c1 ea 0c             	shr    $0xc,%edx
  801bbe:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801bc5:	f6 c2 01             	test   $0x1,%dl
  801bc8:	75 09                	jne    801bd3 <fd_alloc+0x36>
			*fd_store = fd;
  801bca:	89 01                	mov    %eax,(%ecx)
			return 0;
  801bcc:	b8 00 00 00 00       	mov    $0x0,%eax
  801bd1:	eb 17                	jmp    801bea <fd_alloc+0x4d>
  801bd3:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801bd8:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801bdd:	75 c9                	jne    801ba8 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801bdf:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801be5:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801bea:	5d                   	pop    %ebp
  801beb:	c3                   	ret    

00801bec <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801bec:	55                   	push   %ebp
  801bed:	89 e5                	mov    %esp,%ebp
  801bef:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801bf2:	83 f8 1f             	cmp    $0x1f,%eax
  801bf5:	77 36                	ja     801c2d <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801bf7:	c1 e0 0c             	shl    $0xc,%eax
  801bfa:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801bff:	89 c2                	mov    %eax,%edx
  801c01:	c1 ea 16             	shr    $0x16,%edx
  801c04:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801c0b:	f6 c2 01             	test   $0x1,%dl
  801c0e:	74 24                	je     801c34 <fd_lookup+0x48>
  801c10:	89 c2                	mov    %eax,%edx
  801c12:	c1 ea 0c             	shr    $0xc,%edx
  801c15:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801c1c:	f6 c2 01             	test   $0x1,%dl
  801c1f:	74 1a                	je     801c3b <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801c21:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c24:	89 02                	mov    %eax,(%edx)
	return 0;
  801c26:	b8 00 00 00 00       	mov    $0x0,%eax
  801c2b:	eb 13                	jmp    801c40 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801c2d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801c32:	eb 0c                	jmp    801c40 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801c34:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801c39:	eb 05                	jmp    801c40 <fd_lookup+0x54>
  801c3b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801c40:	5d                   	pop    %ebp
  801c41:	c3                   	ret    

00801c42 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801c42:	55                   	push   %ebp
  801c43:	89 e5                	mov    %esp,%ebp
  801c45:	83 ec 08             	sub    $0x8,%esp
  801c48:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c4b:	ba 38 3d 80 00       	mov    $0x803d38,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801c50:	eb 13                	jmp    801c65 <dev_lookup+0x23>
  801c52:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801c55:	39 08                	cmp    %ecx,(%eax)
  801c57:	75 0c                	jne    801c65 <dev_lookup+0x23>
			*dev = devtab[i];
  801c59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c5c:	89 01                	mov    %eax,(%ecx)
			return 0;
  801c5e:	b8 00 00 00 00       	mov    $0x0,%eax
  801c63:	eb 2e                	jmp    801c93 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801c65:	8b 02                	mov    (%edx),%eax
  801c67:	85 c0                	test   %eax,%eax
  801c69:	75 e7                	jne    801c52 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801c6b:	a1 28 54 80 00       	mov    0x805428,%eax
  801c70:	8b 40 48             	mov    0x48(%eax),%eax
  801c73:	83 ec 04             	sub    $0x4,%esp
  801c76:	51                   	push   %ecx
  801c77:	50                   	push   %eax
  801c78:	68 bc 3c 80 00       	push   $0x803cbc
  801c7d:	e8 6c ee ff ff       	call   800aee <cprintf>
	*dev = 0;
  801c82:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c85:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801c8b:	83 c4 10             	add    $0x10,%esp
  801c8e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801c93:	c9                   	leave  
  801c94:	c3                   	ret    

00801c95 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801c95:	55                   	push   %ebp
  801c96:	89 e5                	mov    %esp,%ebp
  801c98:	56                   	push   %esi
  801c99:	53                   	push   %ebx
  801c9a:	83 ec 10             	sub    $0x10,%esp
  801c9d:	8b 75 08             	mov    0x8(%ebp),%esi
  801ca0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801ca3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ca6:	50                   	push   %eax
  801ca7:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801cad:	c1 e8 0c             	shr    $0xc,%eax
  801cb0:	50                   	push   %eax
  801cb1:	e8 36 ff ff ff       	call   801bec <fd_lookup>
  801cb6:	83 c4 08             	add    $0x8,%esp
  801cb9:	85 c0                	test   %eax,%eax
  801cbb:	78 05                	js     801cc2 <fd_close+0x2d>
	    || fd != fd2)
  801cbd:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801cc0:	74 0c                	je     801cce <fd_close+0x39>
		return (must_exist ? r : 0);
  801cc2:	84 db                	test   %bl,%bl
  801cc4:	ba 00 00 00 00       	mov    $0x0,%edx
  801cc9:	0f 44 c2             	cmove  %edx,%eax
  801ccc:	eb 41                	jmp    801d0f <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801cce:	83 ec 08             	sub    $0x8,%esp
  801cd1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801cd4:	50                   	push   %eax
  801cd5:	ff 36                	pushl  (%esi)
  801cd7:	e8 66 ff ff ff       	call   801c42 <dev_lookup>
  801cdc:	89 c3                	mov    %eax,%ebx
  801cde:	83 c4 10             	add    $0x10,%esp
  801ce1:	85 c0                	test   %eax,%eax
  801ce3:	78 1a                	js     801cff <fd_close+0x6a>
		if (dev->dev_close)
  801ce5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ce8:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801ceb:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801cf0:	85 c0                	test   %eax,%eax
  801cf2:	74 0b                	je     801cff <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801cf4:	83 ec 0c             	sub    $0xc,%esp
  801cf7:	56                   	push   %esi
  801cf8:	ff d0                	call   *%eax
  801cfa:	89 c3                	mov    %eax,%ebx
  801cfc:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801cff:	83 ec 08             	sub    $0x8,%esp
  801d02:	56                   	push   %esi
  801d03:	6a 00                	push   $0x0
  801d05:	e8 e4 f8 ff ff       	call   8015ee <sys_page_unmap>
	return r;
  801d0a:	83 c4 10             	add    $0x10,%esp
  801d0d:	89 d8                	mov    %ebx,%eax
}
  801d0f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d12:	5b                   	pop    %ebx
  801d13:	5e                   	pop    %esi
  801d14:	5d                   	pop    %ebp
  801d15:	c3                   	ret    

00801d16 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801d16:	55                   	push   %ebp
  801d17:	89 e5                	mov    %esp,%ebp
  801d19:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d1c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d1f:	50                   	push   %eax
  801d20:	ff 75 08             	pushl  0x8(%ebp)
  801d23:	e8 c4 fe ff ff       	call   801bec <fd_lookup>
  801d28:	83 c4 08             	add    $0x8,%esp
  801d2b:	85 c0                	test   %eax,%eax
  801d2d:	78 10                	js     801d3f <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801d2f:	83 ec 08             	sub    $0x8,%esp
  801d32:	6a 01                	push   $0x1
  801d34:	ff 75 f4             	pushl  -0xc(%ebp)
  801d37:	e8 59 ff ff ff       	call   801c95 <fd_close>
  801d3c:	83 c4 10             	add    $0x10,%esp
}
  801d3f:	c9                   	leave  
  801d40:	c3                   	ret    

00801d41 <close_all>:

void
close_all(void)
{
  801d41:	55                   	push   %ebp
  801d42:	89 e5                	mov    %esp,%ebp
  801d44:	53                   	push   %ebx
  801d45:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801d48:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801d4d:	83 ec 0c             	sub    $0xc,%esp
  801d50:	53                   	push   %ebx
  801d51:	e8 c0 ff ff ff       	call   801d16 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801d56:	83 c3 01             	add    $0x1,%ebx
  801d59:	83 c4 10             	add    $0x10,%esp
  801d5c:	83 fb 20             	cmp    $0x20,%ebx
  801d5f:	75 ec                	jne    801d4d <close_all+0xc>
		close(i);
}
  801d61:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d64:	c9                   	leave  
  801d65:	c3                   	ret    

00801d66 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801d66:	55                   	push   %ebp
  801d67:	89 e5                	mov    %esp,%ebp
  801d69:	57                   	push   %edi
  801d6a:	56                   	push   %esi
  801d6b:	53                   	push   %ebx
  801d6c:	83 ec 2c             	sub    $0x2c,%esp
  801d6f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801d72:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801d75:	50                   	push   %eax
  801d76:	ff 75 08             	pushl  0x8(%ebp)
  801d79:	e8 6e fe ff ff       	call   801bec <fd_lookup>
  801d7e:	83 c4 08             	add    $0x8,%esp
  801d81:	85 c0                	test   %eax,%eax
  801d83:	0f 88 c1 00 00 00    	js     801e4a <dup+0xe4>
		return r;
	close(newfdnum);
  801d89:	83 ec 0c             	sub    $0xc,%esp
  801d8c:	56                   	push   %esi
  801d8d:	e8 84 ff ff ff       	call   801d16 <close>

	newfd = INDEX2FD(newfdnum);
  801d92:	89 f3                	mov    %esi,%ebx
  801d94:	c1 e3 0c             	shl    $0xc,%ebx
  801d97:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801d9d:	83 c4 04             	add    $0x4,%esp
  801da0:	ff 75 e4             	pushl  -0x1c(%ebp)
  801da3:	e8 de fd ff ff       	call   801b86 <fd2data>
  801da8:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801daa:	89 1c 24             	mov    %ebx,(%esp)
  801dad:	e8 d4 fd ff ff       	call   801b86 <fd2data>
  801db2:	83 c4 10             	add    $0x10,%esp
  801db5:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801db8:	89 f8                	mov    %edi,%eax
  801dba:	c1 e8 16             	shr    $0x16,%eax
  801dbd:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801dc4:	a8 01                	test   $0x1,%al
  801dc6:	74 37                	je     801dff <dup+0x99>
  801dc8:	89 f8                	mov    %edi,%eax
  801dca:	c1 e8 0c             	shr    $0xc,%eax
  801dcd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801dd4:	f6 c2 01             	test   $0x1,%dl
  801dd7:	74 26                	je     801dff <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801dd9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801de0:	83 ec 0c             	sub    $0xc,%esp
  801de3:	25 07 0e 00 00       	and    $0xe07,%eax
  801de8:	50                   	push   %eax
  801de9:	ff 75 d4             	pushl  -0x2c(%ebp)
  801dec:	6a 00                	push   $0x0
  801dee:	57                   	push   %edi
  801def:	6a 00                	push   $0x0
  801df1:	e8 b6 f7 ff ff       	call   8015ac <sys_page_map>
  801df6:	89 c7                	mov    %eax,%edi
  801df8:	83 c4 20             	add    $0x20,%esp
  801dfb:	85 c0                	test   %eax,%eax
  801dfd:	78 2e                	js     801e2d <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801dff:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801e02:	89 d0                	mov    %edx,%eax
  801e04:	c1 e8 0c             	shr    $0xc,%eax
  801e07:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801e0e:	83 ec 0c             	sub    $0xc,%esp
  801e11:	25 07 0e 00 00       	and    $0xe07,%eax
  801e16:	50                   	push   %eax
  801e17:	53                   	push   %ebx
  801e18:	6a 00                	push   $0x0
  801e1a:	52                   	push   %edx
  801e1b:	6a 00                	push   $0x0
  801e1d:	e8 8a f7 ff ff       	call   8015ac <sys_page_map>
  801e22:	89 c7                	mov    %eax,%edi
  801e24:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801e27:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801e29:	85 ff                	test   %edi,%edi
  801e2b:	79 1d                	jns    801e4a <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801e2d:	83 ec 08             	sub    $0x8,%esp
  801e30:	53                   	push   %ebx
  801e31:	6a 00                	push   $0x0
  801e33:	e8 b6 f7 ff ff       	call   8015ee <sys_page_unmap>
	sys_page_unmap(0, nva);
  801e38:	83 c4 08             	add    $0x8,%esp
  801e3b:	ff 75 d4             	pushl  -0x2c(%ebp)
  801e3e:	6a 00                	push   $0x0
  801e40:	e8 a9 f7 ff ff       	call   8015ee <sys_page_unmap>
	return r;
  801e45:	83 c4 10             	add    $0x10,%esp
  801e48:	89 f8                	mov    %edi,%eax
}
  801e4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e4d:	5b                   	pop    %ebx
  801e4e:	5e                   	pop    %esi
  801e4f:	5f                   	pop    %edi
  801e50:	5d                   	pop    %ebp
  801e51:	c3                   	ret    

00801e52 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801e52:	55                   	push   %ebp
  801e53:	89 e5                	mov    %esp,%ebp
  801e55:	53                   	push   %ebx
  801e56:	83 ec 14             	sub    $0x14,%esp
  801e59:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801e5c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e5f:	50                   	push   %eax
  801e60:	53                   	push   %ebx
  801e61:	e8 86 fd ff ff       	call   801bec <fd_lookup>
  801e66:	83 c4 08             	add    $0x8,%esp
  801e69:	89 c2                	mov    %eax,%edx
  801e6b:	85 c0                	test   %eax,%eax
  801e6d:	78 6d                	js     801edc <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801e6f:	83 ec 08             	sub    $0x8,%esp
  801e72:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e75:	50                   	push   %eax
  801e76:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e79:	ff 30                	pushl  (%eax)
  801e7b:	e8 c2 fd ff ff       	call   801c42 <dev_lookup>
  801e80:	83 c4 10             	add    $0x10,%esp
  801e83:	85 c0                	test   %eax,%eax
  801e85:	78 4c                	js     801ed3 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801e87:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801e8a:	8b 42 08             	mov    0x8(%edx),%eax
  801e8d:	83 e0 03             	and    $0x3,%eax
  801e90:	83 f8 01             	cmp    $0x1,%eax
  801e93:	75 21                	jne    801eb6 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801e95:	a1 28 54 80 00       	mov    0x805428,%eax
  801e9a:	8b 40 48             	mov    0x48(%eax),%eax
  801e9d:	83 ec 04             	sub    $0x4,%esp
  801ea0:	53                   	push   %ebx
  801ea1:	50                   	push   %eax
  801ea2:	68 fd 3c 80 00       	push   $0x803cfd
  801ea7:	e8 42 ec ff ff       	call   800aee <cprintf>
		return -E_INVAL;
  801eac:	83 c4 10             	add    $0x10,%esp
  801eaf:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801eb4:	eb 26                	jmp    801edc <read+0x8a>
	}
	if (!dev->dev_read)
  801eb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eb9:	8b 40 08             	mov    0x8(%eax),%eax
  801ebc:	85 c0                	test   %eax,%eax
  801ebe:	74 17                	je     801ed7 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801ec0:	83 ec 04             	sub    $0x4,%esp
  801ec3:	ff 75 10             	pushl  0x10(%ebp)
  801ec6:	ff 75 0c             	pushl  0xc(%ebp)
  801ec9:	52                   	push   %edx
  801eca:	ff d0                	call   *%eax
  801ecc:	89 c2                	mov    %eax,%edx
  801ece:	83 c4 10             	add    $0x10,%esp
  801ed1:	eb 09                	jmp    801edc <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801ed3:	89 c2                	mov    %eax,%edx
  801ed5:	eb 05                	jmp    801edc <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801ed7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801edc:	89 d0                	mov    %edx,%eax
  801ede:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ee1:	c9                   	leave  
  801ee2:	c3                   	ret    

00801ee3 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801ee3:	55                   	push   %ebp
  801ee4:	89 e5                	mov    %esp,%ebp
  801ee6:	57                   	push   %edi
  801ee7:	56                   	push   %esi
  801ee8:	53                   	push   %ebx
  801ee9:	83 ec 0c             	sub    $0xc,%esp
  801eec:	8b 7d 08             	mov    0x8(%ebp),%edi
  801eef:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801ef2:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ef7:	eb 21                	jmp    801f1a <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801ef9:	83 ec 04             	sub    $0x4,%esp
  801efc:	89 f0                	mov    %esi,%eax
  801efe:	29 d8                	sub    %ebx,%eax
  801f00:	50                   	push   %eax
  801f01:	89 d8                	mov    %ebx,%eax
  801f03:	03 45 0c             	add    0xc(%ebp),%eax
  801f06:	50                   	push   %eax
  801f07:	57                   	push   %edi
  801f08:	e8 45 ff ff ff       	call   801e52 <read>
		if (m < 0)
  801f0d:	83 c4 10             	add    $0x10,%esp
  801f10:	85 c0                	test   %eax,%eax
  801f12:	78 10                	js     801f24 <readn+0x41>
			return m;
		if (m == 0)
  801f14:	85 c0                	test   %eax,%eax
  801f16:	74 0a                	je     801f22 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801f18:	01 c3                	add    %eax,%ebx
  801f1a:	39 f3                	cmp    %esi,%ebx
  801f1c:	72 db                	jb     801ef9 <readn+0x16>
  801f1e:	89 d8                	mov    %ebx,%eax
  801f20:	eb 02                	jmp    801f24 <readn+0x41>
  801f22:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801f24:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f27:	5b                   	pop    %ebx
  801f28:	5e                   	pop    %esi
  801f29:	5f                   	pop    %edi
  801f2a:	5d                   	pop    %ebp
  801f2b:	c3                   	ret    

00801f2c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801f2c:	55                   	push   %ebp
  801f2d:	89 e5                	mov    %esp,%ebp
  801f2f:	53                   	push   %ebx
  801f30:	83 ec 14             	sub    $0x14,%esp
  801f33:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801f36:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f39:	50                   	push   %eax
  801f3a:	53                   	push   %ebx
  801f3b:	e8 ac fc ff ff       	call   801bec <fd_lookup>
  801f40:	83 c4 08             	add    $0x8,%esp
  801f43:	89 c2                	mov    %eax,%edx
  801f45:	85 c0                	test   %eax,%eax
  801f47:	78 68                	js     801fb1 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801f49:	83 ec 08             	sub    $0x8,%esp
  801f4c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f4f:	50                   	push   %eax
  801f50:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f53:	ff 30                	pushl  (%eax)
  801f55:	e8 e8 fc ff ff       	call   801c42 <dev_lookup>
  801f5a:	83 c4 10             	add    $0x10,%esp
  801f5d:	85 c0                	test   %eax,%eax
  801f5f:	78 47                	js     801fa8 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801f61:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f64:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801f68:	75 21                	jne    801f8b <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801f6a:	a1 28 54 80 00       	mov    0x805428,%eax
  801f6f:	8b 40 48             	mov    0x48(%eax),%eax
  801f72:	83 ec 04             	sub    $0x4,%esp
  801f75:	53                   	push   %ebx
  801f76:	50                   	push   %eax
  801f77:	68 19 3d 80 00       	push   $0x803d19
  801f7c:	e8 6d eb ff ff       	call   800aee <cprintf>
		return -E_INVAL;
  801f81:	83 c4 10             	add    $0x10,%esp
  801f84:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801f89:	eb 26                	jmp    801fb1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801f8b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f8e:	8b 52 0c             	mov    0xc(%edx),%edx
  801f91:	85 d2                	test   %edx,%edx
  801f93:	74 17                	je     801fac <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801f95:	83 ec 04             	sub    $0x4,%esp
  801f98:	ff 75 10             	pushl  0x10(%ebp)
  801f9b:	ff 75 0c             	pushl  0xc(%ebp)
  801f9e:	50                   	push   %eax
  801f9f:	ff d2                	call   *%edx
  801fa1:	89 c2                	mov    %eax,%edx
  801fa3:	83 c4 10             	add    $0x10,%esp
  801fa6:	eb 09                	jmp    801fb1 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801fa8:	89 c2                	mov    %eax,%edx
  801faa:	eb 05                	jmp    801fb1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801fac:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801fb1:	89 d0                	mov    %edx,%eax
  801fb3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fb6:	c9                   	leave  
  801fb7:	c3                   	ret    

00801fb8 <seek>:

int
seek(int fdnum, off_t offset)
{
  801fb8:	55                   	push   %ebp
  801fb9:	89 e5                	mov    %esp,%ebp
  801fbb:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fbe:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801fc1:	50                   	push   %eax
  801fc2:	ff 75 08             	pushl  0x8(%ebp)
  801fc5:	e8 22 fc ff ff       	call   801bec <fd_lookup>
  801fca:	83 c4 08             	add    $0x8,%esp
  801fcd:	85 c0                	test   %eax,%eax
  801fcf:	78 0e                	js     801fdf <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801fd1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801fd4:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fd7:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801fda:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801fdf:	c9                   	leave  
  801fe0:	c3                   	ret    

00801fe1 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801fe1:	55                   	push   %ebp
  801fe2:	89 e5                	mov    %esp,%ebp
  801fe4:	53                   	push   %ebx
  801fe5:	83 ec 14             	sub    $0x14,%esp
  801fe8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801feb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801fee:	50                   	push   %eax
  801fef:	53                   	push   %ebx
  801ff0:	e8 f7 fb ff ff       	call   801bec <fd_lookup>
  801ff5:	83 c4 08             	add    $0x8,%esp
  801ff8:	89 c2                	mov    %eax,%edx
  801ffa:	85 c0                	test   %eax,%eax
  801ffc:	78 65                	js     802063 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801ffe:	83 ec 08             	sub    $0x8,%esp
  802001:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802004:	50                   	push   %eax
  802005:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802008:	ff 30                	pushl  (%eax)
  80200a:	e8 33 fc ff ff       	call   801c42 <dev_lookup>
  80200f:	83 c4 10             	add    $0x10,%esp
  802012:	85 c0                	test   %eax,%eax
  802014:	78 44                	js     80205a <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802016:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802019:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80201d:	75 21                	jne    802040 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80201f:	a1 28 54 80 00       	mov    0x805428,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  802024:	8b 40 48             	mov    0x48(%eax),%eax
  802027:	83 ec 04             	sub    $0x4,%esp
  80202a:	53                   	push   %ebx
  80202b:	50                   	push   %eax
  80202c:	68 dc 3c 80 00       	push   $0x803cdc
  802031:	e8 b8 ea ff ff       	call   800aee <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  802036:	83 c4 10             	add    $0x10,%esp
  802039:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80203e:	eb 23                	jmp    802063 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  802040:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802043:	8b 52 18             	mov    0x18(%edx),%edx
  802046:	85 d2                	test   %edx,%edx
  802048:	74 14                	je     80205e <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80204a:	83 ec 08             	sub    $0x8,%esp
  80204d:	ff 75 0c             	pushl  0xc(%ebp)
  802050:	50                   	push   %eax
  802051:	ff d2                	call   *%edx
  802053:	89 c2                	mov    %eax,%edx
  802055:	83 c4 10             	add    $0x10,%esp
  802058:	eb 09                	jmp    802063 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80205a:	89 c2                	mov    %eax,%edx
  80205c:	eb 05                	jmp    802063 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80205e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  802063:	89 d0                	mov    %edx,%eax
  802065:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802068:	c9                   	leave  
  802069:	c3                   	ret    

0080206a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80206a:	55                   	push   %ebp
  80206b:	89 e5                	mov    %esp,%ebp
  80206d:	53                   	push   %ebx
  80206e:	83 ec 14             	sub    $0x14,%esp
  802071:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802074:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802077:	50                   	push   %eax
  802078:	ff 75 08             	pushl  0x8(%ebp)
  80207b:	e8 6c fb ff ff       	call   801bec <fd_lookup>
  802080:	83 c4 08             	add    $0x8,%esp
  802083:	89 c2                	mov    %eax,%edx
  802085:	85 c0                	test   %eax,%eax
  802087:	78 58                	js     8020e1 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802089:	83 ec 08             	sub    $0x8,%esp
  80208c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80208f:	50                   	push   %eax
  802090:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802093:	ff 30                	pushl  (%eax)
  802095:	e8 a8 fb ff ff       	call   801c42 <dev_lookup>
  80209a:	83 c4 10             	add    $0x10,%esp
  80209d:	85 c0                	test   %eax,%eax
  80209f:	78 37                	js     8020d8 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8020a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020a4:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8020a8:	74 32                	je     8020dc <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8020aa:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8020ad:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8020b4:	00 00 00 
	stat->st_isdir = 0;
  8020b7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8020be:	00 00 00 
	stat->st_dev = dev;
  8020c1:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8020c7:	83 ec 08             	sub    $0x8,%esp
  8020ca:	53                   	push   %ebx
  8020cb:	ff 75 f0             	pushl  -0x10(%ebp)
  8020ce:	ff 50 14             	call   *0x14(%eax)
  8020d1:	89 c2                	mov    %eax,%edx
  8020d3:	83 c4 10             	add    $0x10,%esp
  8020d6:	eb 09                	jmp    8020e1 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8020d8:	89 c2                	mov    %eax,%edx
  8020da:	eb 05                	jmp    8020e1 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8020dc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8020e1:	89 d0                	mov    %edx,%eax
  8020e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020e6:	c9                   	leave  
  8020e7:	c3                   	ret    

008020e8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8020e8:	55                   	push   %ebp
  8020e9:	89 e5                	mov    %esp,%ebp
  8020eb:	56                   	push   %esi
  8020ec:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8020ed:	83 ec 08             	sub    $0x8,%esp
  8020f0:	6a 00                	push   $0x0
  8020f2:	ff 75 08             	pushl  0x8(%ebp)
  8020f5:	e8 0c 02 00 00       	call   802306 <open>
  8020fa:	89 c3                	mov    %eax,%ebx
  8020fc:	83 c4 10             	add    $0x10,%esp
  8020ff:	85 c0                	test   %eax,%eax
  802101:	78 1b                	js     80211e <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  802103:	83 ec 08             	sub    $0x8,%esp
  802106:	ff 75 0c             	pushl  0xc(%ebp)
  802109:	50                   	push   %eax
  80210a:	e8 5b ff ff ff       	call   80206a <fstat>
  80210f:	89 c6                	mov    %eax,%esi
	close(fd);
  802111:	89 1c 24             	mov    %ebx,(%esp)
  802114:	e8 fd fb ff ff       	call   801d16 <close>
	return r;
  802119:	83 c4 10             	add    $0x10,%esp
  80211c:	89 f0                	mov    %esi,%eax
}
  80211e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802121:	5b                   	pop    %ebx
  802122:	5e                   	pop    %esi
  802123:	5d                   	pop    %ebp
  802124:	c3                   	ret    

00802125 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  802125:	55                   	push   %ebp
  802126:	89 e5                	mov    %esp,%ebp
  802128:	56                   	push   %esi
  802129:	53                   	push   %ebx
  80212a:	89 c6                	mov    %eax,%esi
  80212c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80212e:	83 3d 20 54 80 00 00 	cmpl   $0x0,0x805420
  802135:	75 12                	jne    802149 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802137:	83 ec 0c             	sub    $0xc,%esp
  80213a:	6a 01                	push   $0x1
  80213c:	e8 72 12 00 00       	call   8033b3 <ipc_find_env>
  802141:	a3 20 54 80 00       	mov    %eax,0x805420
  802146:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  802149:	6a 07                	push   $0x7
  80214b:	68 00 60 80 00       	push   $0x806000
  802150:	56                   	push   %esi
  802151:	ff 35 20 54 80 00    	pushl  0x805420
  802157:	e8 03 12 00 00       	call   80335f <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80215c:	83 c4 0c             	add    $0xc,%esp
  80215f:	6a 00                	push   $0x0
  802161:	53                   	push   %ebx
  802162:	6a 00                	push   $0x0
  802164:	e8 8d 11 00 00       	call   8032f6 <ipc_recv>
}
  802169:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80216c:	5b                   	pop    %ebx
  80216d:	5e                   	pop    %esi
  80216e:	5d                   	pop    %ebp
  80216f:	c3                   	ret    

00802170 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  802170:	55                   	push   %ebp
  802171:	89 e5                	mov    %esp,%ebp
  802173:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  802176:	8b 45 08             	mov    0x8(%ebp),%eax
  802179:	8b 40 0c             	mov    0xc(%eax),%eax
  80217c:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  802181:	8b 45 0c             	mov    0xc(%ebp),%eax
  802184:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  802189:	ba 00 00 00 00       	mov    $0x0,%edx
  80218e:	b8 02 00 00 00       	mov    $0x2,%eax
  802193:	e8 8d ff ff ff       	call   802125 <fsipc>
}
  802198:	c9                   	leave  
  802199:	c3                   	ret    

0080219a <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80219a:	55                   	push   %ebp
  80219b:	89 e5                	mov    %esp,%ebp
  80219d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8021a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8021a3:	8b 40 0c             	mov    0xc(%eax),%eax
  8021a6:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  8021ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8021b0:	b8 06 00 00 00       	mov    $0x6,%eax
  8021b5:	e8 6b ff ff ff       	call   802125 <fsipc>
}
  8021ba:	c9                   	leave  
  8021bb:	c3                   	ret    

008021bc <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8021bc:	55                   	push   %ebp
  8021bd:	89 e5                	mov    %esp,%ebp
  8021bf:	53                   	push   %ebx
  8021c0:	83 ec 04             	sub    $0x4,%esp
  8021c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8021c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8021c9:	8b 40 0c             	mov    0xc(%eax),%eax
  8021cc:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8021d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8021d6:	b8 05 00 00 00       	mov    $0x5,%eax
  8021db:	e8 45 ff ff ff       	call   802125 <fsipc>
  8021e0:	85 c0                	test   %eax,%eax
  8021e2:	78 2c                	js     802210 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8021e4:	83 ec 08             	sub    $0x8,%esp
  8021e7:	68 00 60 80 00       	push   $0x806000
  8021ec:	53                   	push   %ebx
  8021ed:	e8 74 ef ff ff       	call   801166 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8021f2:	a1 80 60 80 00       	mov    0x806080,%eax
  8021f7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8021fd:	a1 84 60 80 00       	mov    0x806084,%eax
  802202:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  802208:	83 c4 10             	add    $0x10,%esp
  80220b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802210:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802213:	c9                   	leave  
  802214:	c3                   	ret    

00802215 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  802215:	55                   	push   %ebp
  802216:	89 e5                	mov    %esp,%ebp
  802218:	53                   	push   %ebx
  802219:	83 ec 08             	sub    $0x8,%esp
  80221c:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80221f:	8b 55 08             	mov    0x8(%ebp),%edx
  802222:	8b 52 0c             	mov    0xc(%edx),%edx
  802225:	89 15 00 60 80 00    	mov    %edx,0x806000
  80222b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  802230:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  802235:	0f 46 d8             	cmovbe %eax,%ebx
	
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  802238:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  80223e:	53                   	push   %ebx
  80223f:	ff 75 0c             	pushl  0xc(%ebp)
  802242:	68 08 60 80 00       	push   $0x806008
  802247:	e8 ac f0 ff ff       	call   8012f8 <memmove>

	
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) 
  80224c:	ba 00 00 00 00       	mov    $0x0,%edx
  802251:	b8 04 00 00 00       	mov    $0x4,%eax
  802256:	e8 ca fe ff ff       	call   802125 <fsipc>
  80225b:	83 c4 10             	add    $0x10,%esp
  80225e:	85 c0                	test   %eax,%eax
  802260:	78 1d                	js     80227f <devfile_write+0x6a>
		return r;
	assert(r <= n_real); 
  802262:	39 d8                	cmp    %ebx,%eax
  802264:	76 19                	jbe    80227f <devfile_write+0x6a>
  802266:	68 4c 3d 80 00       	push   $0x803d4c
  80226b:	68 06 38 80 00       	push   $0x803806
  802270:	68 a3 00 00 00       	push   $0xa3
  802275:	68 58 3d 80 00       	push   $0x803d58
  80227a:	e8 96 e7 ff ff       	call   800a15 <_panic>
	return r;
}
  80227f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802282:	c9                   	leave  
  802283:	c3                   	ret    

00802284 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  802284:	55                   	push   %ebp
  802285:	89 e5                	mov    %esp,%ebp
  802287:	56                   	push   %esi
  802288:	53                   	push   %ebx
  802289:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80228c:	8b 45 08             	mov    0x8(%ebp),%eax
  80228f:	8b 40 0c             	mov    0xc(%eax),%eax
  802292:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  802297:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80229d:	ba 00 00 00 00       	mov    $0x0,%edx
  8022a2:	b8 03 00 00 00       	mov    $0x3,%eax
  8022a7:	e8 79 fe ff ff       	call   802125 <fsipc>
  8022ac:	89 c3                	mov    %eax,%ebx
  8022ae:	85 c0                	test   %eax,%eax
  8022b0:	78 4b                	js     8022fd <devfile_read+0x79>
		return r;
	assert(r <= n);
  8022b2:	39 c6                	cmp    %eax,%esi
  8022b4:	73 16                	jae    8022cc <devfile_read+0x48>
  8022b6:	68 63 3d 80 00       	push   $0x803d63
  8022bb:	68 06 38 80 00       	push   $0x803806
  8022c0:	6a 7c                	push   $0x7c
  8022c2:	68 58 3d 80 00       	push   $0x803d58
  8022c7:	e8 49 e7 ff ff       	call   800a15 <_panic>
	assert(r <= PGSIZE);
  8022cc:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8022d1:	7e 16                	jle    8022e9 <devfile_read+0x65>
  8022d3:	68 6a 3d 80 00       	push   $0x803d6a
  8022d8:	68 06 38 80 00       	push   $0x803806
  8022dd:	6a 7d                	push   $0x7d
  8022df:	68 58 3d 80 00       	push   $0x803d58
  8022e4:	e8 2c e7 ff ff       	call   800a15 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8022e9:	83 ec 04             	sub    $0x4,%esp
  8022ec:	50                   	push   %eax
  8022ed:	68 00 60 80 00       	push   $0x806000
  8022f2:	ff 75 0c             	pushl  0xc(%ebp)
  8022f5:	e8 fe ef ff ff       	call   8012f8 <memmove>
	return r;
  8022fa:	83 c4 10             	add    $0x10,%esp
}
  8022fd:	89 d8                	mov    %ebx,%eax
  8022ff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802302:	5b                   	pop    %ebx
  802303:	5e                   	pop    %esi
  802304:	5d                   	pop    %ebp
  802305:	c3                   	ret    

00802306 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  802306:	55                   	push   %ebp
  802307:	89 e5                	mov    %esp,%ebp
  802309:	53                   	push   %ebx
  80230a:	83 ec 20             	sub    $0x20,%esp
  80230d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  802310:	53                   	push   %ebx
  802311:	e8 17 ee ff ff       	call   80112d <strlen>
  802316:	83 c4 10             	add    $0x10,%esp
  802319:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80231e:	7f 67                	jg     802387 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  802320:	83 ec 0c             	sub    $0xc,%esp
  802323:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802326:	50                   	push   %eax
  802327:	e8 71 f8 ff ff       	call   801b9d <fd_alloc>
  80232c:	83 c4 10             	add    $0x10,%esp
		return r;
  80232f:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  802331:	85 c0                	test   %eax,%eax
  802333:	78 57                	js     80238c <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  802335:	83 ec 08             	sub    $0x8,%esp
  802338:	53                   	push   %ebx
  802339:	68 00 60 80 00       	push   $0x806000
  80233e:	e8 23 ee ff ff       	call   801166 <strcpy>
	fsipcbuf.open.req_omode = mode;
  802343:	8b 45 0c             	mov    0xc(%ebp),%eax
  802346:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80234b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80234e:	b8 01 00 00 00       	mov    $0x1,%eax
  802353:	e8 cd fd ff ff       	call   802125 <fsipc>
  802358:	89 c3                	mov    %eax,%ebx
  80235a:	83 c4 10             	add    $0x10,%esp
  80235d:	85 c0                	test   %eax,%eax
  80235f:	79 14                	jns    802375 <open+0x6f>
		fd_close(fd, 0);
  802361:	83 ec 08             	sub    $0x8,%esp
  802364:	6a 00                	push   $0x0
  802366:	ff 75 f4             	pushl  -0xc(%ebp)
  802369:	e8 27 f9 ff ff       	call   801c95 <fd_close>
		return r;
  80236e:	83 c4 10             	add    $0x10,%esp
  802371:	89 da                	mov    %ebx,%edx
  802373:	eb 17                	jmp    80238c <open+0x86>
	}

	return fd2num(fd);
  802375:	83 ec 0c             	sub    $0xc,%esp
  802378:	ff 75 f4             	pushl  -0xc(%ebp)
  80237b:	e8 f6 f7 ff ff       	call   801b76 <fd2num>
  802380:	89 c2                	mov    %eax,%edx
  802382:	83 c4 10             	add    $0x10,%esp
  802385:	eb 05                	jmp    80238c <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  802387:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80238c:	89 d0                	mov    %edx,%eax
  80238e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802391:	c9                   	leave  
  802392:	c3                   	ret    

00802393 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  802393:	55                   	push   %ebp
  802394:	89 e5                	mov    %esp,%ebp
  802396:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  802399:	ba 00 00 00 00       	mov    $0x0,%edx
  80239e:	b8 08 00 00 00       	mov    $0x8,%eax
  8023a3:	e8 7d fd ff ff       	call   802125 <fsipc>
}
  8023a8:	c9                   	leave  
  8023a9:	c3                   	ret    

008023aa <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  8023aa:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  8023ae:	7e 37                	jle    8023e7 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  8023b0:	55                   	push   %ebp
  8023b1:	89 e5                	mov    %esp,%ebp
  8023b3:	53                   	push   %ebx
  8023b4:	83 ec 08             	sub    $0x8,%esp
  8023b7:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  8023b9:	ff 70 04             	pushl  0x4(%eax)
  8023bc:	8d 40 10             	lea    0x10(%eax),%eax
  8023bf:	50                   	push   %eax
  8023c0:	ff 33                	pushl  (%ebx)
  8023c2:	e8 65 fb ff ff       	call   801f2c <write>
		if (result > 0)
  8023c7:	83 c4 10             	add    $0x10,%esp
  8023ca:	85 c0                	test   %eax,%eax
  8023cc:	7e 03                	jle    8023d1 <writebuf+0x27>
			b->result += result;
  8023ce:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8023d1:	3b 43 04             	cmp    0x4(%ebx),%eax
  8023d4:	74 0d                	je     8023e3 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  8023d6:	85 c0                	test   %eax,%eax
  8023d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8023dd:	0f 4f c2             	cmovg  %edx,%eax
  8023e0:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8023e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8023e6:	c9                   	leave  
  8023e7:	f3 c3                	repz ret 

008023e9 <putch>:

static void
putch(int ch, void *thunk)
{
  8023e9:	55                   	push   %ebp
  8023ea:	89 e5                	mov    %esp,%ebp
  8023ec:	53                   	push   %ebx
  8023ed:	83 ec 04             	sub    $0x4,%esp
  8023f0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8023f3:	8b 53 04             	mov    0x4(%ebx),%edx
  8023f6:	8d 42 01             	lea    0x1(%edx),%eax
  8023f9:	89 43 04             	mov    %eax,0x4(%ebx)
  8023fc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8023ff:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  802403:	3d 00 01 00 00       	cmp    $0x100,%eax
  802408:	75 0e                	jne    802418 <putch+0x2f>
		writebuf(b);
  80240a:	89 d8                	mov    %ebx,%eax
  80240c:	e8 99 ff ff ff       	call   8023aa <writebuf>
		b->idx = 0;
  802411:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  802418:	83 c4 04             	add    $0x4,%esp
  80241b:	5b                   	pop    %ebx
  80241c:	5d                   	pop    %ebp
  80241d:	c3                   	ret    

0080241e <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  80241e:	55                   	push   %ebp
  80241f:	89 e5                	mov    %esp,%ebp
  802421:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  802427:	8b 45 08             	mov    0x8(%ebp),%eax
  80242a:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  802430:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  802437:	00 00 00 
	b.result = 0;
  80243a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  802441:	00 00 00 
	b.error = 1;
  802444:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  80244b:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  80244e:	ff 75 10             	pushl  0x10(%ebp)
  802451:	ff 75 0c             	pushl  0xc(%ebp)
  802454:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80245a:	50                   	push   %eax
  80245b:	68 e9 23 80 00       	push   $0x8023e9
  802460:	e8 c0 e7 ff ff       	call   800c25 <vprintfmt>
	if (b.idx > 0)
  802465:	83 c4 10             	add    $0x10,%esp
  802468:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  80246f:	7e 0b                	jle    80247c <vfprintf+0x5e>
		writebuf(&b);
  802471:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  802477:	e8 2e ff ff ff       	call   8023aa <writebuf>

	return (b.result ? b.result : b.error);
  80247c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  802482:	85 c0                	test   %eax,%eax
  802484:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  80248b:	c9                   	leave  
  80248c:	c3                   	ret    

0080248d <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  80248d:	55                   	push   %ebp
  80248e:	89 e5                	mov    %esp,%ebp
  802490:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  802493:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  802496:	50                   	push   %eax
  802497:	ff 75 0c             	pushl  0xc(%ebp)
  80249a:	ff 75 08             	pushl  0x8(%ebp)
  80249d:	e8 7c ff ff ff       	call   80241e <vfprintf>
	va_end(ap);

	return cnt;
}
  8024a2:	c9                   	leave  
  8024a3:	c3                   	ret    

008024a4 <printf>:

int
printf(const char *fmt, ...)
{
  8024a4:	55                   	push   %ebp
  8024a5:	89 e5                	mov    %esp,%ebp
  8024a7:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8024aa:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  8024ad:	50                   	push   %eax
  8024ae:	ff 75 08             	pushl  0x8(%ebp)
  8024b1:	6a 01                	push   $0x1
  8024b3:	e8 66 ff ff ff       	call   80241e <vfprintf>
	va_end(ap);

	return cnt;
}
  8024b8:	c9                   	leave  
  8024b9:	c3                   	ret    

008024ba <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8024ba:	55                   	push   %ebp
  8024bb:	89 e5                	mov    %esp,%ebp
  8024bd:	57                   	push   %edi
  8024be:	56                   	push   %esi
  8024bf:	53                   	push   %ebx
  8024c0:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8024c6:	6a 00                	push   $0x0
  8024c8:	ff 75 08             	pushl  0x8(%ebp)
  8024cb:	e8 36 fe ff ff       	call   802306 <open>
  8024d0:	89 c7                	mov    %eax,%edi
  8024d2:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  8024d8:	83 c4 10             	add    $0x10,%esp
  8024db:	85 c0                	test   %eax,%eax
  8024dd:	0f 88 ae 04 00 00    	js     802991 <spawn+0x4d7>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8024e3:	83 ec 04             	sub    $0x4,%esp
  8024e6:	68 00 02 00 00       	push   $0x200
  8024eb:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8024f1:	50                   	push   %eax
  8024f2:	57                   	push   %edi
  8024f3:	e8 eb f9 ff ff       	call   801ee3 <readn>
  8024f8:	83 c4 10             	add    $0x10,%esp
  8024fb:	3d 00 02 00 00       	cmp    $0x200,%eax
  802500:	75 0c                	jne    80250e <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  802502:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  802509:	45 4c 46 
  80250c:	74 33                	je     802541 <spawn+0x87>
		close(fd);
  80250e:	83 ec 0c             	sub    $0xc,%esp
  802511:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802517:	e8 fa f7 ff ff       	call   801d16 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  80251c:	83 c4 0c             	add    $0xc,%esp
  80251f:	68 7f 45 4c 46       	push   $0x464c457f
  802524:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  80252a:	68 76 3d 80 00       	push   $0x803d76
  80252f:	e8 ba e5 ff ff       	call   800aee <cprintf>
		return -E_NOT_EXEC;
  802534:	83 c4 10             	add    $0x10,%esp
  802537:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  80253c:	e9 b0 04 00 00       	jmp    8029f1 <spawn+0x537>
  802541:	b8 07 00 00 00       	mov    $0x7,%eax
  802546:	cd 30                	int    $0x30
  802548:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  80254e:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  802554:	85 c0                	test   %eax,%eax
  802556:	0f 88 3d 04 00 00    	js     802999 <spawn+0x4df>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  80255c:	89 c6                	mov    %eax,%esi
  80255e:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  802564:	6b f6 7c             	imul   $0x7c,%esi,%esi
  802567:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  80256d:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  802573:	b9 11 00 00 00       	mov    $0x11,%ecx
  802578:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  80257a:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  802580:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  802586:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  80258b:	be 00 00 00 00       	mov    $0x0,%esi
  802590:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802593:	eb 13                	jmp    8025a8 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  802595:	83 ec 0c             	sub    $0xc,%esp
  802598:	50                   	push   %eax
  802599:	e8 8f eb ff ff       	call   80112d <strlen>
  80259e:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8025a2:	83 c3 01             	add    $0x1,%ebx
  8025a5:	83 c4 10             	add    $0x10,%esp
  8025a8:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  8025af:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  8025b2:	85 c0                	test   %eax,%eax
  8025b4:	75 df                	jne    802595 <spawn+0xdb>
  8025b6:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  8025bc:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8025c2:	bf 00 10 40 00       	mov    $0x401000,%edi
  8025c7:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  8025c9:	89 fa                	mov    %edi,%edx
  8025cb:	83 e2 fc             	and    $0xfffffffc,%edx
  8025ce:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  8025d5:	29 c2                	sub    %eax,%edx
  8025d7:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8025dd:	8d 42 f8             	lea    -0x8(%edx),%eax
  8025e0:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8025e5:	0f 86 be 03 00 00    	jbe    8029a9 <spawn+0x4ef>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8025eb:	83 ec 04             	sub    $0x4,%esp
  8025ee:	6a 07                	push   $0x7
  8025f0:	68 00 00 40 00       	push   $0x400000
  8025f5:	6a 00                	push   $0x0
  8025f7:	e8 6d ef ff ff       	call   801569 <sys_page_alloc>
  8025fc:	83 c4 10             	add    $0x10,%esp
  8025ff:	85 c0                	test   %eax,%eax
  802601:	0f 88 a9 03 00 00    	js     8029b0 <spawn+0x4f6>
  802607:	be 00 00 00 00       	mov    $0x0,%esi
  80260c:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  802612:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  802615:	eb 30                	jmp    802647 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  802617:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  80261d:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  802623:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  802626:	83 ec 08             	sub    $0x8,%esp
  802629:	ff 34 b3             	pushl  (%ebx,%esi,4)
  80262c:	57                   	push   %edi
  80262d:	e8 34 eb ff ff       	call   801166 <strcpy>
		string_store += strlen(argv[i]) + 1;
  802632:	83 c4 04             	add    $0x4,%esp
  802635:	ff 34 b3             	pushl  (%ebx,%esi,4)
  802638:	e8 f0 ea ff ff       	call   80112d <strlen>
  80263d:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  802641:	83 c6 01             	add    $0x1,%esi
  802644:	83 c4 10             	add    $0x10,%esp
  802647:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  80264d:	7f c8                	jg     802617 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  80264f:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  802655:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  80265b:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  802662:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  802668:	74 19                	je     802683 <spawn+0x1c9>
  80266a:	68 d4 3d 80 00       	push   $0x803dd4
  80266f:	68 06 38 80 00       	push   $0x803806
  802674:	68 f2 00 00 00       	push   $0xf2
  802679:	68 90 3d 80 00       	push   $0x803d90
  80267e:	e8 92 e3 ff ff       	call   800a15 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  802683:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  802689:	89 f8                	mov    %edi,%eax
  80268b:	2d 00 30 80 11       	sub    $0x11803000,%eax
  802690:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  802693:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802699:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  80269c:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  8026a2:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  8026a8:	83 ec 0c             	sub    $0xc,%esp
  8026ab:	6a 07                	push   $0x7
  8026ad:	68 00 d0 bf ee       	push   $0xeebfd000
  8026b2:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8026b8:	68 00 00 40 00       	push   $0x400000
  8026bd:	6a 00                	push   $0x0
  8026bf:	e8 e8 ee ff ff       	call   8015ac <sys_page_map>
  8026c4:	89 c3                	mov    %eax,%ebx
  8026c6:	83 c4 20             	add    $0x20,%esp
  8026c9:	85 c0                	test   %eax,%eax
  8026cb:	0f 88 0e 03 00 00    	js     8029df <spawn+0x525>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8026d1:	83 ec 08             	sub    $0x8,%esp
  8026d4:	68 00 00 40 00       	push   $0x400000
  8026d9:	6a 00                	push   $0x0
  8026db:	e8 0e ef ff ff       	call   8015ee <sys_page_unmap>
  8026e0:	89 c3                	mov    %eax,%ebx
  8026e2:	83 c4 10             	add    $0x10,%esp
  8026e5:	85 c0                	test   %eax,%eax
  8026e7:	0f 88 f2 02 00 00    	js     8029df <spawn+0x525>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  8026ed:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  8026f3:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  8026fa:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802700:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  802707:	00 00 00 
  80270a:	e9 88 01 00 00       	jmp    802897 <spawn+0x3dd>
		if (ph->p_type != ELF_PROG_LOAD)
  80270f:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  802715:	83 38 01             	cmpl   $0x1,(%eax)
  802718:	0f 85 6b 01 00 00    	jne    802889 <spawn+0x3cf>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  80271e:	89 c7                	mov    %eax,%edi
  802720:	8b 40 18             	mov    0x18(%eax),%eax
  802723:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  802729:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  80272c:	83 f8 01             	cmp    $0x1,%eax
  80272f:	19 c0                	sbb    %eax,%eax
  802731:	83 e0 fe             	and    $0xfffffffe,%eax
  802734:	83 c0 07             	add    $0x7,%eax
  802737:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  80273d:	89 f8                	mov    %edi,%eax
  80273f:	8b 7f 04             	mov    0x4(%edi),%edi
  802742:	89 f9                	mov    %edi,%ecx
  802744:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  80274a:	8b 78 10             	mov    0x10(%eax),%edi
  80274d:	8b 50 14             	mov    0x14(%eax),%edx
  802750:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  802756:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  802759:	89 f0                	mov    %esi,%eax
  80275b:	25 ff 0f 00 00       	and    $0xfff,%eax
  802760:	74 14                	je     802776 <spawn+0x2bc>
		va -= i;
  802762:	29 c6                	sub    %eax,%esi
		memsz += i;
  802764:	01 c2                	add    %eax,%edx
  802766:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  80276c:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  80276e:	29 c1                	sub    %eax,%ecx
  802770:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  802776:	bb 00 00 00 00       	mov    $0x0,%ebx
  80277b:	e9 f7 00 00 00       	jmp    802877 <spawn+0x3bd>
		if (i >= filesz) {
  802780:	39 df                	cmp    %ebx,%edi
  802782:	77 27                	ja     8027ab <spawn+0x2f1>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  802784:	83 ec 04             	sub    $0x4,%esp
  802787:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  80278d:	56                   	push   %esi
  80278e:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  802794:	e8 d0 ed ff ff       	call   801569 <sys_page_alloc>
  802799:	83 c4 10             	add    $0x10,%esp
  80279c:	85 c0                	test   %eax,%eax
  80279e:	0f 89 c7 00 00 00    	jns    80286b <spawn+0x3b1>
  8027a4:	89 c3                	mov    %eax,%ebx
  8027a6:	e9 13 02 00 00       	jmp    8029be <spawn+0x504>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8027ab:	83 ec 04             	sub    $0x4,%esp
  8027ae:	6a 07                	push   $0x7
  8027b0:	68 00 00 40 00       	push   $0x400000
  8027b5:	6a 00                	push   $0x0
  8027b7:	e8 ad ed ff ff       	call   801569 <sys_page_alloc>
  8027bc:	83 c4 10             	add    $0x10,%esp
  8027bf:	85 c0                	test   %eax,%eax
  8027c1:	0f 88 ed 01 00 00    	js     8029b4 <spawn+0x4fa>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  8027c7:	83 ec 08             	sub    $0x8,%esp
  8027ca:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  8027d0:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  8027d6:	50                   	push   %eax
  8027d7:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8027dd:	e8 d6 f7 ff ff       	call   801fb8 <seek>
  8027e2:	83 c4 10             	add    $0x10,%esp
  8027e5:	85 c0                	test   %eax,%eax
  8027e7:	0f 88 cb 01 00 00    	js     8029b8 <spawn+0x4fe>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  8027ed:	83 ec 04             	sub    $0x4,%esp
  8027f0:	89 f8                	mov    %edi,%eax
  8027f2:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  8027f8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8027fd:	ba 00 10 00 00       	mov    $0x1000,%edx
  802802:	0f 47 c2             	cmova  %edx,%eax
  802805:	50                   	push   %eax
  802806:	68 00 00 40 00       	push   $0x400000
  80280b:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802811:	e8 cd f6 ff ff       	call   801ee3 <readn>
  802816:	83 c4 10             	add    $0x10,%esp
  802819:	85 c0                	test   %eax,%eax
  80281b:	0f 88 9b 01 00 00    	js     8029bc <spawn+0x502>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  802821:	83 ec 0c             	sub    $0xc,%esp
  802824:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  80282a:	56                   	push   %esi
  80282b:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  802831:	68 00 00 40 00       	push   $0x400000
  802836:	6a 00                	push   $0x0
  802838:	e8 6f ed ff ff       	call   8015ac <sys_page_map>
  80283d:	83 c4 20             	add    $0x20,%esp
  802840:	85 c0                	test   %eax,%eax
  802842:	79 15                	jns    802859 <spawn+0x39f>
				panic("spawn: sys_page_map data: %e", r);
  802844:	50                   	push   %eax
  802845:	68 9c 3d 80 00       	push   $0x803d9c
  80284a:	68 25 01 00 00       	push   $0x125
  80284f:	68 90 3d 80 00       	push   $0x803d90
  802854:	e8 bc e1 ff ff       	call   800a15 <_panic>
			sys_page_unmap(0, UTEMP);
  802859:	83 ec 08             	sub    $0x8,%esp
  80285c:	68 00 00 40 00       	push   $0x400000
  802861:	6a 00                	push   $0x0
  802863:	e8 86 ed ff ff       	call   8015ee <sys_page_unmap>
  802868:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  80286b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802871:	81 c6 00 10 00 00    	add    $0x1000,%esi
  802877:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  80287d:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  802883:	0f 87 f7 fe ff ff    	ja     802780 <spawn+0x2c6>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802889:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  802890:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  802897:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  80289e:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  8028a4:	0f 8c 65 fe ff ff    	jl     80270f <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  8028aa:	83 ec 0c             	sub    $0xc,%esp
  8028ad:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8028b3:	e8 5e f4 ff ff       	call   801d16 <close>
  8028b8:	83 c4 10             	add    $0x10,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	uintptr_t i;
	for (i = 0; i < USTACKTOP; i += PGSIZE){
  8028bb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8028c0:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[PGNUM(i)] & PTE_P) && (uvpt[PGNUM(i)] & PTE_U) && (uvpt[PGNUM(i)] & PTE_SHARE)){
  8028c6:	89 d8                	mov    %ebx,%eax
  8028c8:	c1 e8 16             	shr    $0x16,%eax
  8028cb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8028d2:	a8 01                	test   $0x1,%al
  8028d4:	74 46                	je     80291c <spawn+0x462>
  8028d6:	89 d8                	mov    %ebx,%eax
  8028d8:	c1 e8 0c             	shr    $0xc,%eax
  8028db:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8028e2:	f6 c2 01             	test   $0x1,%dl
  8028e5:	74 35                	je     80291c <spawn+0x462>
  8028e7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8028ee:	f6 c2 04             	test   $0x4,%dl
  8028f1:	74 29                	je     80291c <spawn+0x462>
  8028f3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8028fa:	f6 c6 04             	test   $0x4,%dh
  8028fd:	74 1d                	je     80291c <spawn+0x462>
			sys_page_map(0, (void*)i,child, (void*)i,(uvpt[PGNUM(i)] | PTE_SYSCALL));
  8028ff:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802906:	83 ec 0c             	sub    $0xc,%esp
  802909:	0d 07 0e 00 00       	or     $0xe07,%eax
  80290e:	50                   	push   %eax
  80290f:	53                   	push   %ebx
  802910:	56                   	push   %esi
  802911:	53                   	push   %ebx
  802912:	6a 00                	push   $0x0
  802914:	e8 93 ec ff ff       	call   8015ac <sys_page_map>
  802919:	83 c4 20             	add    $0x20,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	uintptr_t i;
	for (i = 0; i < USTACKTOP; i += PGSIZE){
  80291c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802922:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  802928:	75 9c                	jne    8028c6 <spawn+0x40c>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  80292a:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  802931:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  802934:	83 ec 08             	sub    $0x8,%esp
  802937:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  80293d:	50                   	push   %eax
  80293e:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802944:	e8 29 ed ff ff       	call   801672 <sys_env_set_trapframe>
  802949:	83 c4 10             	add    $0x10,%esp
  80294c:	85 c0                	test   %eax,%eax
  80294e:	79 15                	jns    802965 <spawn+0x4ab>
		panic("sys_env_set_trapframe: %e", r);
  802950:	50                   	push   %eax
  802951:	68 b9 3d 80 00       	push   $0x803db9
  802956:	68 86 00 00 00       	push   $0x86
  80295b:	68 90 3d 80 00       	push   $0x803d90
  802960:	e8 b0 e0 ff ff       	call   800a15 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  802965:	83 ec 08             	sub    $0x8,%esp
  802968:	6a 02                	push   $0x2
  80296a:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802970:	e8 bb ec ff ff       	call   801630 <sys_env_set_status>
  802975:	83 c4 10             	add    $0x10,%esp
  802978:	85 c0                	test   %eax,%eax
  80297a:	79 25                	jns    8029a1 <spawn+0x4e7>
		panic("sys_env_set_status: %e", r);
  80297c:	50                   	push   %eax
  80297d:	68 8c 3c 80 00       	push   $0x803c8c
  802982:	68 89 00 00 00       	push   $0x89
  802987:	68 90 3d 80 00       	push   $0x803d90
  80298c:	e8 84 e0 ff ff       	call   800a15 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  802991:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  802997:	eb 58                	jmp    8029f1 <spawn+0x537>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  802999:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  80299f:	eb 50                	jmp    8029f1 <spawn+0x537>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  8029a1:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  8029a7:	eb 48                	jmp    8029f1 <spawn+0x537>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  8029a9:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  8029ae:	eb 41                	jmp    8029f1 <spawn+0x537>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  8029b0:	89 c3                	mov    %eax,%ebx
  8029b2:	eb 3d                	jmp    8029f1 <spawn+0x537>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8029b4:	89 c3                	mov    %eax,%ebx
  8029b6:	eb 06                	jmp    8029be <spawn+0x504>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  8029b8:	89 c3                	mov    %eax,%ebx
  8029ba:	eb 02                	jmp    8029be <spawn+0x504>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  8029bc:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  8029be:	83 ec 0c             	sub    $0xc,%esp
  8029c1:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8029c7:	e8 1e eb ff ff       	call   8014ea <sys_env_destroy>
	close(fd);
  8029cc:	83 c4 04             	add    $0x4,%esp
  8029cf:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8029d5:	e8 3c f3 ff ff       	call   801d16 <close>
	return r;
  8029da:	83 c4 10             	add    $0x10,%esp
  8029dd:	eb 12                	jmp    8029f1 <spawn+0x537>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  8029df:	83 ec 08             	sub    $0x8,%esp
  8029e2:	68 00 00 40 00       	push   $0x400000
  8029e7:	6a 00                	push   $0x0
  8029e9:	e8 00 ec ff ff       	call   8015ee <sys_page_unmap>
  8029ee:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  8029f1:	89 d8                	mov    %ebx,%eax
  8029f3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8029f6:	5b                   	pop    %ebx
  8029f7:	5e                   	pop    %esi
  8029f8:	5f                   	pop    %edi
  8029f9:	5d                   	pop    %ebp
  8029fa:	c3                   	ret    

008029fb <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  8029fb:	55                   	push   %ebp
  8029fc:	89 e5                	mov    %esp,%ebp
  8029fe:	56                   	push   %esi
  8029ff:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802a00:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  802a03:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802a08:	eb 03                	jmp    802a0d <spawnl+0x12>
		argc++;
  802a0a:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802a0d:	83 c2 04             	add    $0x4,%edx
  802a10:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  802a14:	75 f4                	jne    802a0a <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  802a16:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  802a1d:	83 e2 f0             	and    $0xfffffff0,%edx
  802a20:	29 d4                	sub    %edx,%esp
  802a22:	8d 54 24 03          	lea    0x3(%esp),%edx
  802a26:	c1 ea 02             	shr    $0x2,%edx
  802a29:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  802a30:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  802a32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802a35:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  802a3c:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  802a43:	00 
  802a44:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802a46:	b8 00 00 00 00       	mov    $0x0,%eax
  802a4b:	eb 0a                	jmp    802a57 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  802a4d:	83 c0 01             	add    $0x1,%eax
  802a50:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  802a54:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802a57:	39 d0                	cmp    %edx,%eax
  802a59:	75 f2                	jne    802a4d <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802a5b:	83 ec 08             	sub    $0x8,%esp
  802a5e:	56                   	push   %esi
  802a5f:	ff 75 08             	pushl  0x8(%ebp)
  802a62:	e8 53 fa ff ff       	call   8024ba <spawn>
}
  802a67:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802a6a:	5b                   	pop    %ebx
  802a6b:	5e                   	pop    %esi
  802a6c:	5d                   	pop    %ebp
  802a6d:	c3                   	ret    

00802a6e <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  802a6e:	55                   	push   %ebp
  802a6f:	89 e5                	mov    %esp,%ebp
  802a71:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  802a74:	68 fc 3d 80 00       	push   $0x803dfc
  802a79:	ff 75 0c             	pushl  0xc(%ebp)
  802a7c:	e8 e5 e6 ff ff       	call   801166 <strcpy>
	return 0;
}
  802a81:	b8 00 00 00 00       	mov    $0x0,%eax
  802a86:	c9                   	leave  
  802a87:	c3                   	ret    

00802a88 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  802a88:	55                   	push   %ebp
  802a89:	89 e5                	mov    %esp,%ebp
  802a8b:	53                   	push   %ebx
  802a8c:	83 ec 10             	sub    $0x10,%esp
  802a8f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  802a92:	53                   	push   %ebx
  802a93:	e8 54 09 00 00       	call   8033ec <pageref>
  802a98:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  802a9b:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  802aa0:	83 f8 01             	cmp    $0x1,%eax
  802aa3:	75 10                	jne    802ab5 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  802aa5:	83 ec 0c             	sub    $0xc,%esp
  802aa8:	ff 73 0c             	pushl  0xc(%ebx)
  802aab:	e8 c0 02 00 00       	call   802d70 <nsipc_close>
  802ab0:	89 c2                	mov    %eax,%edx
  802ab2:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  802ab5:	89 d0                	mov    %edx,%eax
  802ab7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802aba:	c9                   	leave  
  802abb:	c3                   	ret    

00802abc <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  802abc:	55                   	push   %ebp
  802abd:	89 e5                	mov    %esp,%ebp
  802abf:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  802ac2:	6a 00                	push   $0x0
  802ac4:	ff 75 10             	pushl  0x10(%ebp)
  802ac7:	ff 75 0c             	pushl  0xc(%ebp)
  802aca:	8b 45 08             	mov    0x8(%ebp),%eax
  802acd:	ff 70 0c             	pushl  0xc(%eax)
  802ad0:	e8 78 03 00 00       	call   802e4d <nsipc_send>
}
  802ad5:	c9                   	leave  
  802ad6:	c3                   	ret    

00802ad7 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  802ad7:	55                   	push   %ebp
  802ad8:	89 e5                	mov    %esp,%ebp
  802ada:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  802add:	6a 00                	push   $0x0
  802adf:	ff 75 10             	pushl  0x10(%ebp)
  802ae2:	ff 75 0c             	pushl  0xc(%ebp)
  802ae5:	8b 45 08             	mov    0x8(%ebp),%eax
  802ae8:	ff 70 0c             	pushl  0xc(%eax)
  802aeb:	e8 f1 02 00 00       	call   802de1 <nsipc_recv>
}
  802af0:	c9                   	leave  
  802af1:	c3                   	ret    

00802af2 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  802af2:	55                   	push   %ebp
  802af3:	89 e5                	mov    %esp,%ebp
  802af5:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  802af8:	8d 55 f4             	lea    -0xc(%ebp),%edx
  802afb:	52                   	push   %edx
  802afc:	50                   	push   %eax
  802afd:	e8 ea f0 ff ff       	call   801bec <fd_lookup>
  802b02:	83 c4 10             	add    $0x10,%esp
  802b05:	85 c0                	test   %eax,%eax
  802b07:	78 17                	js     802b20 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  802b09:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802b0c:	8b 0d 3c 40 80 00    	mov    0x80403c,%ecx
  802b12:	39 08                	cmp    %ecx,(%eax)
  802b14:	75 05                	jne    802b1b <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  802b16:	8b 40 0c             	mov    0xc(%eax),%eax
  802b19:	eb 05                	jmp    802b20 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  802b1b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  802b20:	c9                   	leave  
  802b21:	c3                   	ret    

00802b22 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  802b22:	55                   	push   %ebp
  802b23:	89 e5                	mov    %esp,%ebp
  802b25:	56                   	push   %esi
  802b26:	53                   	push   %ebx
  802b27:	83 ec 1c             	sub    $0x1c,%esp
  802b2a:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  802b2c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802b2f:	50                   	push   %eax
  802b30:	e8 68 f0 ff ff       	call   801b9d <fd_alloc>
  802b35:	89 c3                	mov    %eax,%ebx
  802b37:	83 c4 10             	add    $0x10,%esp
  802b3a:	85 c0                	test   %eax,%eax
  802b3c:	78 1b                	js     802b59 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  802b3e:	83 ec 04             	sub    $0x4,%esp
  802b41:	68 07 04 00 00       	push   $0x407
  802b46:	ff 75 f4             	pushl  -0xc(%ebp)
  802b49:	6a 00                	push   $0x0
  802b4b:	e8 19 ea ff ff       	call   801569 <sys_page_alloc>
  802b50:	89 c3                	mov    %eax,%ebx
  802b52:	83 c4 10             	add    $0x10,%esp
  802b55:	85 c0                	test   %eax,%eax
  802b57:	79 10                	jns    802b69 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  802b59:	83 ec 0c             	sub    $0xc,%esp
  802b5c:	56                   	push   %esi
  802b5d:	e8 0e 02 00 00       	call   802d70 <nsipc_close>
		return r;
  802b62:	83 c4 10             	add    $0x10,%esp
  802b65:	89 d8                	mov    %ebx,%eax
  802b67:	eb 24                	jmp    802b8d <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  802b69:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802b6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802b72:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  802b74:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802b77:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  802b7e:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  802b81:	83 ec 0c             	sub    $0xc,%esp
  802b84:	50                   	push   %eax
  802b85:	e8 ec ef ff ff       	call   801b76 <fd2num>
  802b8a:	83 c4 10             	add    $0x10,%esp
}
  802b8d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802b90:	5b                   	pop    %ebx
  802b91:	5e                   	pop    %esi
  802b92:	5d                   	pop    %ebp
  802b93:	c3                   	ret    

00802b94 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802b94:	55                   	push   %ebp
  802b95:	89 e5                	mov    %esp,%ebp
  802b97:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802b9a:	8b 45 08             	mov    0x8(%ebp),%eax
  802b9d:	e8 50 ff ff ff       	call   802af2 <fd2sockid>
		return r;
  802ba2:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  802ba4:	85 c0                	test   %eax,%eax
  802ba6:	78 1f                	js     802bc7 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802ba8:	83 ec 04             	sub    $0x4,%esp
  802bab:	ff 75 10             	pushl  0x10(%ebp)
  802bae:	ff 75 0c             	pushl  0xc(%ebp)
  802bb1:	50                   	push   %eax
  802bb2:	e8 12 01 00 00       	call   802cc9 <nsipc_accept>
  802bb7:	83 c4 10             	add    $0x10,%esp
		return r;
  802bba:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802bbc:	85 c0                	test   %eax,%eax
  802bbe:	78 07                	js     802bc7 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  802bc0:	e8 5d ff ff ff       	call   802b22 <alloc_sockfd>
  802bc5:	89 c1                	mov    %eax,%ecx
}
  802bc7:	89 c8                	mov    %ecx,%eax
  802bc9:	c9                   	leave  
  802bca:	c3                   	ret    

00802bcb <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802bcb:	55                   	push   %ebp
  802bcc:	89 e5                	mov    %esp,%ebp
  802bce:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802bd1:	8b 45 08             	mov    0x8(%ebp),%eax
  802bd4:	e8 19 ff ff ff       	call   802af2 <fd2sockid>
  802bd9:	85 c0                	test   %eax,%eax
  802bdb:	78 12                	js     802bef <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  802bdd:	83 ec 04             	sub    $0x4,%esp
  802be0:	ff 75 10             	pushl  0x10(%ebp)
  802be3:	ff 75 0c             	pushl  0xc(%ebp)
  802be6:	50                   	push   %eax
  802be7:	e8 2d 01 00 00       	call   802d19 <nsipc_bind>
  802bec:	83 c4 10             	add    $0x10,%esp
}
  802bef:	c9                   	leave  
  802bf0:	c3                   	ret    

00802bf1 <shutdown>:

int
shutdown(int s, int how)
{
  802bf1:	55                   	push   %ebp
  802bf2:	89 e5                	mov    %esp,%ebp
  802bf4:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802bf7:	8b 45 08             	mov    0x8(%ebp),%eax
  802bfa:	e8 f3 fe ff ff       	call   802af2 <fd2sockid>
  802bff:	85 c0                	test   %eax,%eax
  802c01:	78 0f                	js     802c12 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  802c03:	83 ec 08             	sub    $0x8,%esp
  802c06:	ff 75 0c             	pushl  0xc(%ebp)
  802c09:	50                   	push   %eax
  802c0a:	e8 3f 01 00 00       	call   802d4e <nsipc_shutdown>
  802c0f:	83 c4 10             	add    $0x10,%esp
}
  802c12:	c9                   	leave  
  802c13:	c3                   	ret    

00802c14 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802c14:	55                   	push   %ebp
  802c15:	89 e5                	mov    %esp,%ebp
  802c17:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802c1a:	8b 45 08             	mov    0x8(%ebp),%eax
  802c1d:	e8 d0 fe ff ff       	call   802af2 <fd2sockid>
  802c22:	85 c0                	test   %eax,%eax
  802c24:	78 12                	js     802c38 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  802c26:	83 ec 04             	sub    $0x4,%esp
  802c29:	ff 75 10             	pushl  0x10(%ebp)
  802c2c:	ff 75 0c             	pushl  0xc(%ebp)
  802c2f:	50                   	push   %eax
  802c30:	e8 55 01 00 00       	call   802d8a <nsipc_connect>
  802c35:	83 c4 10             	add    $0x10,%esp
}
  802c38:	c9                   	leave  
  802c39:	c3                   	ret    

00802c3a <listen>:

int
listen(int s, int backlog)
{
  802c3a:	55                   	push   %ebp
  802c3b:	89 e5                	mov    %esp,%ebp
  802c3d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802c40:	8b 45 08             	mov    0x8(%ebp),%eax
  802c43:	e8 aa fe ff ff       	call   802af2 <fd2sockid>
  802c48:	85 c0                	test   %eax,%eax
  802c4a:	78 0f                	js     802c5b <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  802c4c:	83 ec 08             	sub    $0x8,%esp
  802c4f:	ff 75 0c             	pushl  0xc(%ebp)
  802c52:	50                   	push   %eax
  802c53:	e8 67 01 00 00       	call   802dbf <nsipc_listen>
  802c58:	83 c4 10             	add    $0x10,%esp
}
  802c5b:	c9                   	leave  
  802c5c:	c3                   	ret    

00802c5d <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  802c5d:	55                   	push   %ebp
  802c5e:	89 e5                	mov    %esp,%ebp
  802c60:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  802c63:	ff 75 10             	pushl  0x10(%ebp)
  802c66:	ff 75 0c             	pushl  0xc(%ebp)
  802c69:	ff 75 08             	pushl  0x8(%ebp)
  802c6c:	e8 3a 02 00 00       	call   802eab <nsipc_socket>
  802c71:	83 c4 10             	add    $0x10,%esp
  802c74:	85 c0                	test   %eax,%eax
  802c76:	78 05                	js     802c7d <socket+0x20>
		return r;
	return alloc_sockfd(r);
  802c78:	e8 a5 fe ff ff       	call   802b22 <alloc_sockfd>
}
  802c7d:	c9                   	leave  
  802c7e:	c3                   	ret    

00802c7f <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  802c7f:	55                   	push   %ebp
  802c80:	89 e5                	mov    %esp,%ebp
  802c82:	53                   	push   %ebx
  802c83:	83 ec 04             	sub    $0x4,%esp
  802c86:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  802c88:	83 3d 24 54 80 00 00 	cmpl   $0x0,0x805424
  802c8f:	75 12                	jne    802ca3 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  802c91:	83 ec 0c             	sub    $0xc,%esp
  802c94:	6a 02                	push   $0x2
  802c96:	e8 18 07 00 00       	call   8033b3 <ipc_find_env>
  802c9b:	a3 24 54 80 00       	mov    %eax,0x805424
  802ca0:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802ca3:	6a 07                	push   $0x7
  802ca5:	68 00 70 80 00       	push   $0x807000
  802caa:	53                   	push   %ebx
  802cab:	ff 35 24 54 80 00    	pushl  0x805424
  802cb1:	e8 a9 06 00 00       	call   80335f <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802cb6:	83 c4 0c             	add    $0xc,%esp
  802cb9:	6a 00                	push   $0x0
  802cbb:	6a 00                	push   $0x0
  802cbd:	6a 00                	push   $0x0
  802cbf:	e8 32 06 00 00       	call   8032f6 <ipc_recv>
}
  802cc4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802cc7:	c9                   	leave  
  802cc8:	c3                   	ret    

00802cc9 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802cc9:	55                   	push   %ebp
  802cca:	89 e5                	mov    %esp,%ebp
  802ccc:	56                   	push   %esi
  802ccd:	53                   	push   %ebx
  802cce:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  802cd1:	8b 45 08             	mov    0x8(%ebp),%eax
  802cd4:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  802cd9:	8b 06                	mov    (%esi),%eax
  802cdb:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802ce0:	b8 01 00 00 00       	mov    $0x1,%eax
  802ce5:	e8 95 ff ff ff       	call   802c7f <nsipc>
  802cea:	89 c3                	mov    %eax,%ebx
  802cec:	85 c0                	test   %eax,%eax
  802cee:	78 20                	js     802d10 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802cf0:	83 ec 04             	sub    $0x4,%esp
  802cf3:	ff 35 10 70 80 00    	pushl  0x807010
  802cf9:	68 00 70 80 00       	push   $0x807000
  802cfe:	ff 75 0c             	pushl  0xc(%ebp)
  802d01:	e8 f2 e5 ff ff       	call   8012f8 <memmove>
		*addrlen = ret->ret_addrlen;
  802d06:	a1 10 70 80 00       	mov    0x807010,%eax
  802d0b:	89 06                	mov    %eax,(%esi)
  802d0d:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  802d10:	89 d8                	mov    %ebx,%eax
  802d12:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802d15:	5b                   	pop    %ebx
  802d16:	5e                   	pop    %esi
  802d17:	5d                   	pop    %ebp
  802d18:	c3                   	ret    

00802d19 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802d19:	55                   	push   %ebp
  802d1a:	89 e5                	mov    %esp,%ebp
  802d1c:	53                   	push   %ebx
  802d1d:	83 ec 08             	sub    $0x8,%esp
  802d20:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  802d23:	8b 45 08             	mov    0x8(%ebp),%eax
  802d26:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802d2b:	53                   	push   %ebx
  802d2c:	ff 75 0c             	pushl  0xc(%ebp)
  802d2f:	68 04 70 80 00       	push   $0x807004
  802d34:	e8 bf e5 ff ff       	call   8012f8 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802d39:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  802d3f:	b8 02 00 00 00       	mov    $0x2,%eax
  802d44:	e8 36 ff ff ff       	call   802c7f <nsipc>
}
  802d49:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802d4c:	c9                   	leave  
  802d4d:	c3                   	ret    

00802d4e <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  802d4e:	55                   	push   %ebp
  802d4f:	89 e5                	mov    %esp,%ebp
  802d51:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802d54:	8b 45 08             	mov    0x8(%ebp),%eax
  802d57:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  802d5c:	8b 45 0c             	mov    0xc(%ebp),%eax
  802d5f:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  802d64:	b8 03 00 00 00       	mov    $0x3,%eax
  802d69:	e8 11 ff ff ff       	call   802c7f <nsipc>
}
  802d6e:	c9                   	leave  
  802d6f:	c3                   	ret    

00802d70 <nsipc_close>:

int
nsipc_close(int s)
{
  802d70:	55                   	push   %ebp
  802d71:	89 e5                	mov    %esp,%ebp
  802d73:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802d76:	8b 45 08             	mov    0x8(%ebp),%eax
  802d79:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  802d7e:	b8 04 00 00 00       	mov    $0x4,%eax
  802d83:	e8 f7 fe ff ff       	call   802c7f <nsipc>
}
  802d88:	c9                   	leave  
  802d89:	c3                   	ret    

00802d8a <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802d8a:	55                   	push   %ebp
  802d8b:	89 e5                	mov    %esp,%ebp
  802d8d:	53                   	push   %ebx
  802d8e:	83 ec 08             	sub    $0x8,%esp
  802d91:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  802d94:	8b 45 08             	mov    0x8(%ebp),%eax
  802d97:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802d9c:	53                   	push   %ebx
  802d9d:	ff 75 0c             	pushl  0xc(%ebp)
  802da0:	68 04 70 80 00       	push   $0x807004
  802da5:	e8 4e e5 ff ff       	call   8012f8 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  802daa:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  802db0:	b8 05 00 00 00       	mov    $0x5,%eax
  802db5:	e8 c5 fe ff ff       	call   802c7f <nsipc>
}
  802dba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802dbd:	c9                   	leave  
  802dbe:	c3                   	ret    

00802dbf <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  802dbf:	55                   	push   %ebp
  802dc0:	89 e5                	mov    %esp,%ebp
  802dc2:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802dc5:	8b 45 08             	mov    0x8(%ebp),%eax
  802dc8:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  802dcd:	8b 45 0c             	mov    0xc(%ebp),%eax
  802dd0:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  802dd5:	b8 06 00 00 00       	mov    $0x6,%eax
  802dda:	e8 a0 fe ff ff       	call   802c7f <nsipc>
}
  802ddf:	c9                   	leave  
  802de0:	c3                   	ret    

00802de1 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802de1:	55                   	push   %ebp
  802de2:	89 e5                	mov    %esp,%ebp
  802de4:	56                   	push   %esi
  802de5:	53                   	push   %ebx
  802de6:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  802de9:	8b 45 08             	mov    0x8(%ebp),%eax
  802dec:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  802df1:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  802df7:	8b 45 14             	mov    0x14(%ebp),%eax
  802dfa:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802dff:	b8 07 00 00 00       	mov    $0x7,%eax
  802e04:	e8 76 fe ff ff       	call   802c7f <nsipc>
  802e09:	89 c3                	mov    %eax,%ebx
  802e0b:	85 c0                	test   %eax,%eax
  802e0d:	78 35                	js     802e44 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  802e0f:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802e14:	7f 04                	jg     802e1a <nsipc_recv+0x39>
  802e16:	39 c6                	cmp    %eax,%esi
  802e18:	7d 16                	jge    802e30 <nsipc_recv+0x4f>
  802e1a:	68 08 3e 80 00       	push   $0x803e08
  802e1f:	68 06 38 80 00       	push   $0x803806
  802e24:	6a 62                	push   $0x62
  802e26:	68 1d 3e 80 00       	push   $0x803e1d
  802e2b:	e8 e5 db ff ff       	call   800a15 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802e30:	83 ec 04             	sub    $0x4,%esp
  802e33:	50                   	push   %eax
  802e34:	68 00 70 80 00       	push   $0x807000
  802e39:	ff 75 0c             	pushl  0xc(%ebp)
  802e3c:	e8 b7 e4 ff ff       	call   8012f8 <memmove>
  802e41:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  802e44:	89 d8                	mov    %ebx,%eax
  802e46:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802e49:	5b                   	pop    %ebx
  802e4a:	5e                   	pop    %esi
  802e4b:	5d                   	pop    %ebp
  802e4c:	c3                   	ret    

00802e4d <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802e4d:	55                   	push   %ebp
  802e4e:	89 e5                	mov    %esp,%ebp
  802e50:	53                   	push   %ebx
  802e51:	83 ec 04             	sub    $0x4,%esp
  802e54:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802e57:	8b 45 08             	mov    0x8(%ebp),%eax
  802e5a:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  802e5f:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802e65:	7e 16                	jle    802e7d <nsipc_send+0x30>
  802e67:	68 29 3e 80 00       	push   $0x803e29
  802e6c:	68 06 38 80 00       	push   $0x803806
  802e71:	6a 6d                	push   $0x6d
  802e73:	68 1d 3e 80 00       	push   $0x803e1d
  802e78:	e8 98 db ff ff       	call   800a15 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  802e7d:	83 ec 04             	sub    $0x4,%esp
  802e80:	53                   	push   %ebx
  802e81:	ff 75 0c             	pushl  0xc(%ebp)
  802e84:	68 0c 70 80 00       	push   $0x80700c
  802e89:	e8 6a e4 ff ff       	call   8012f8 <memmove>
	nsipcbuf.send.req_size = size;
  802e8e:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  802e94:	8b 45 14             	mov    0x14(%ebp),%eax
  802e97:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  802e9c:	b8 08 00 00 00       	mov    $0x8,%eax
  802ea1:	e8 d9 fd ff ff       	call   802c7f <nsipc>
}
  802ea6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802ea9:	c9                   	leave  
  802eaa:	c3                   	ret    

00802eab <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  802eab:	55                   	push   %ebp
  802eac:	89 e5                	mov    %esp,%ebp
  802eae:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802eb1:	8b 45 08             	mov    0x8(%ebp),%eax
  802eb4:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  802eb9:	8b 45 0c             	mov    0xc(%ebp),%eax
  802ebc:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  802ec1:	8b 45 10             	mov    0x10(%ebp),%eax
  802ec4:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  802ec9:	b8 09 00 00 00       	mov    $0x9,%eax
  802ece:	e8 ac fd ff ff       	call   802c7f <nsipc>
}
  802ed3:	c9                   	leave  
  802ed4:	c3                   	ret    

00802ed5 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802ed5:	55                   	push   %ebp
  802ed6:	89 e5                	mov    %esp,%ebp
  802ed8:	56                   	push   %esi
  802ed9:	53                   	push   %ebx
  802eda:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802edd:	83 ec 0c             	sub    $0xc,%esp
  802ee0:	ff 75 08             	pushl  0x8(%ebp)
  802ee3:	e8 9e ec ff ff       	call   801b86 <fd2data>
  802ee8:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802eea:	83 c4 08             	add    $0x8,%esp
  802eed:	68 35 3e 80 00       	push   $0x803e35
  802ef2:	53                   	push   %ebx
  802ef3:	e8 6e e2 ff ff       	call   801166 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802ef8:	8b 46 04             	mov    0x4(%esi),%eax
  802efb:	2b 06                	sub    (%esi),%eax
  802efd:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802f03:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802f0a:	00 00 00 
	stat->st_dev = &devpipe;
  802f0d:	c7 83 88 00 00 00 58 	movl   $0x804058,0x88(%ebx)
  802f14:	40 80 00 
	return 0;
}
  802f17:	b8 00 00 00 00       	mov    $0x0,%eax
  802f1c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802f1f:	5b                   	pop    %ebx
  802f20:	5e                   	pop    %esi
  802f21:	5d                   	pop    %ebp
  802f22:	c3                   	ret    

00802f23 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802f23:	55                   	push   %ebp
  802f24:	89 e5                	mov    %esp,%ebp
  802f26:	53                   	push   %ebx
  802f27:	83 ec 0c             	sub    $0xc,%esp
  802f2a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802f2d:	53                   	push   %ebx
  802f2e:	6a 00                	push   $0x0
  802f30:	e8 b9 e6 ff ff       	call   8015ee <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802f35:	89 1c 24             	mov    %ebx,(%esp)
  802f38:	e8 49 ec ff ff       	call   801b86 <fd2data>
  802f3d:	83 c4 08             	add    $0x8,%esp
  802f40:	50                   	push   %eax
  802f41:	6a 00                	push   $0x0
  802f43:	e8 a6 e6 ff ff       	call   8015ee <sys_page_unmap>
}
  802f48:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802f4b:	c9                   	leave  
  802f4c:	c3                   	ret    

00802f4d <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802f4d:	55                   	push   %ebp
  802f4e:	89 e5                	mov    %esp,%ebp
  802f50:	57                   	push   %edi
  802f51:	56                   	push   %esi
  802f52:	53                   	push   %ebx
  802f53:	83 ec 1c             	sub    $0x1c,%esp
  802f56:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802f59:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802f5b:	a1 28 54 80 00       	mov    0x805428,%eax
  802f60:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  802f63:	83 ec 0c             	sub    $0xc,%esp
  802f66:	ff 75 e0             	pushl  -0x20(%ebp)
  802f69:	e8 7e 04 00 00       	call   8033ec <pageref>
  802f6e:	89 c3                	mov    %eax,%ebx
  802f70:	89 3c 24             	mov    %edi,(%esp)
  802f73:	e8 74 04 00 00       	call   8033ec <pageref>
  802f78:	83 c4 10             	add    $0x10,%esp
  802f7b:	39 c3                	cmp    %eax,%ebx
  802f7d:	0f 94 c1             	sete   %cl
  802f80:	0f b6 c9             	movzbl %cl,%ecx
  802f83:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  802f86:	8b 15 28 54 80 00    	mov    0x805428,%edx
  802f8c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802f8f:	39 ce                	cmp    %ecx,%esi
  802f91:	74 1b                	je     802fae <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802f93:	39 c3                	cmp    %eax,%ebx
  802f95:	75 c4                	jne    802f5b <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802f97:	8b 42 58             	mov    0x58(%edx),%eax
  802f9a:	ff 75 e4             	pushl  -0x1c(%ebp)
  802f9d:	50                   	push   %eax
  802f9e:	56                   	push   %esi
  802f9f:	68 3c 3e 80 00       	push   $0x803e3c
  802fa4:	e8 45 db ff ff       	call   800aee <cprintf>
  802fa9:	83 c4 10             	add    $0x10,%esp
  802fac:	eb ad                	jmp    802f5b <_pipeisclosed+0xe>
	}
}
  802fae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802fb1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802fb4:	5b                   	pop    %ebx
  802fb5:	5e                   	pop    %esi
  802fb6:	5f                   	pop    %edi
  802fb7:	5d                   	pop    %ebp
  802fb8:	c3                   	ret    

00802fb9 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802fb9:	55                   	push   %ebp
  802fba:	89 e5                	mov    %esp,%ebp
  802fbc:	57                   	push   %edi
  802fbd:	56                   	push   %esi
  802fbe:	53                   	push   %ebx
  802fbf:	83 ec 28             	sub    $0x28,%esp
  802fc2:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802fc5:	56                   	push   %esi
  802fc6:	e8 bb eb ff ff       	call   801b86 <fd2data>
  802fcb:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802fcd:	83 c4 10             	add    $0x10,%esp
  802fd0:	bf 00 00 00 00       	mov    $0x0,%edi
  802fd5:	eb 4b                	jmp    803022 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802fd7:	89 da                	mov    %ebx,%edx
  802fd9:	89 f0                	mov    %esi,%eax
  802fdb:	e8 6d ff ff ff       	call   802f4d <_pipeisclosed>
  802fe0:	85 c0                	test   %eax,%eax
  802fe2:	75 48                	jne    80302c <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802fe4:	e8 61 e5 ff ff       	call   80154a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802fe9:	8b 43 04             	mov    0x4(%ebx),%eax
  802fec:	8b 0b                	mov    (%ebx),%ecx
  802fee:	8d 51 20             	lea    0x20(%ecx),%edx
  802ff1:	39 d0                	cmp    %edx,%eax
  802ff3:	73 e2                	jae    802fd7 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802ff5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802ff8:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802ffc:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802fff:	89 c2                	mov    %eax,%edx
  803001:	c1 fa 1f             	sar    $0x1f,%edx
  803004:	89 d1                	mov    %edx,%ecx
  803006:	c1 e9 1b             	shr    $0x1b,%ecx
  803009:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80300c:	83 e2 1f             	and    $0x1f,%edx
  80300f:	29 ca                	sub    %ecx,%edx
  803011:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  803015:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  803019:	83 c0 01             	add    $0x1,%eax
  80301c:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80301f:	83 c7 01             	add    $0x1,%edi
  803022:	3b 7d 10             	cmp    0x10(%ebp),%edi
  803025:	75 c2                	jne    802fe9 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  803027:	8b 45 10             	mov    0x10(%ebp),%eax
  80302a:	eb 05                	jmp    803031 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80302c:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  803031:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803034:	5b                   	pop    %ebx
  803035:	5e                   	pop    %esi
  803036:	5f                   	pop    %edi
  803037:	5d                   	pop    %ebp
  803038:	c3                   	ret    

00803039 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  803039:	55                   	push   %ebp
  80303a:	89 e5                	mov    %esp,%ebp
  80303c:	57                   	push   %edi
  80303d:	56                   	push   %esi
  80303e:	53                   	push   %ebx
  80303f:	83 ec 18             	sub    $0x18,%esp
  803042:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  803045:	57                   	push   %edi
  803046:	e8 3b eb ff ff       	call   801b86 <fd2data>
  80304b:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80304d:	83 c4 10             	add    $0x10,%esp
  803050:	bb 00 00 00 00       	mov    $0x0,%ebx
  803055:	eb 3d                	jmp    803094 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  803057:	85 db                	test   %ebx,%ebx
  803059:	74 04                	je     80305f <devpipe_read+0x26>
				return i;
  80305b:	89 d8                	mov    %ebx,%eax
  80305d:	eb 44                	jmp    8030a3 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80305f:	89 f2                	mov    %esi,%edx
  803061:	89 f8                	mov    %edi,%eax
  803063:	e8 e5 fe ff ff       	call   802f4d <_pipeisclosed>
  803068:	85 c0                	test   %eax,%eax
  80306a:	75 32                	jne    80309e <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80306c:	e8 d9 e4 ff ff       	call   80154a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  803071:	8b 06                	mov    (%esi),%eax
  803073:	3b 46 04             	cmp    0x4(%esi),%eax
  803076:	74 df                	je     803057 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  803078:	99                   	cltd   
  803079:	c1 ea 1b             	shr    $0x1b,%edx
  80307c:	01 d0                	add    %edx,%eax
  80307e:	83 e0 1f             	and    $0x1f,%eax
  803081:	29 d0                	sub    %edx,%eax
  803083:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  803088:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80308b:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80308e:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  803091:	83 c3 01             	add    $0x1,%ebx
  803094:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  803097:	75 d8                	jne    803071 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  803099:	8b 45 10             	mov    0x10(%ebp),%eax
  80309c:	eb 05                	jmp    8030a3 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80309e:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8030a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8030a6:	5b                   	pop    %ebx
  8030a7:	5e                   	pop    %esi
  8030a8:	5f                   	pop    %edi
  8030a9:	5d                   	pop    %ebp
  8030aa:	c3                   	ret    

008030ab <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8030ab:	55                   	push   %ebp
  8030ac:	89 e5                	mov    %esp,%ebp
  8030ae:	56                   	push   %esi
  8030af:	53                   	push   %ebx
  8030b0:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8030b3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8030b6:	50                   	push   %eax
  8030b7:	e8 e1 ea ff ff       	call   801b9d <fd_alloc>
  8030bc:	83 c4 10             	add    $0x10,%esp
  8030bf:	89 c2                	mov    %eax,%edx
  8030c1:	85 c0                	test   %eax,%eax
  8030c3:	0f 88 2c 01 00 00    	js     8031f5 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8030c9:	83 ec 04             	sub    $0x4,%esp
  8030cc:	68 07 04 00 00       	push   $0x407
  8030d1:	ff 75 f4             	pushl  -0xc(%ebp)
  8030d4:	6a 00                	push   $0x0
  8030d6:	e8 8e e4 ff ff       	call   801569 <sys_page_alloc>
  8030db:	83 c4 10             	add    $0x10,%esp
  8030de:	89 c2                	mov    %eax,%edx
  8030e0:	85 c0                	test   %eax,%eax
  8030e2:	0f 88 0d 01 00 00    	js     8031f5 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8030e8:	83 ec 0c             	sub    $0xc,%esp
  8030eb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8030ee:	50                   	push   %eax
  8030ef:	e8 a9 ea ff ff       	call   801b9d <fd_alloc>
  8030f4:	89 c3                	mov    %eax,%ebx
  8030f6:	83 c4 10             	add    $0x10,%esp
  8030f9:	85 c0                	test   %eax,%eax
  8030fb:	0f 88 e2 00 00 00    	js     8031e3 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803101:	83 ec 04             	sub    $0x4,%esp
  803104:	68 07 04 00 00       	push   $0x407
  803109:	ff 75 f0             	pushl  -0x10(%ebp)
  80310c:	6a 00                	push   $0x0
  80310e:	e8 56 e4 ff ff       	call   801569 <sys_page_alloc>
  803113:	89 c3                	mov    %eax,%ebx
  803115:	83 c4 10             	add    $0x10,%esp
  803118:	85 c0                	test   %eax,%eax
  80311a:	0f 88 c3 00 00 00    	js     8031e3 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  803120:	83 ec 0c             	sub    $0xc,%esp
  803123:	ff 75 f4             	pushl  -0xc(%ebp)
  803126:	e8 5b ea ff ff       	call   801b86 <fd2data>
  80312b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80312d:	83 c4 0c             	add    $0xc,%esp
  803130:	68 07 04 00 00       	push   $0x407
  803135:	50                   	push   %eax
  803136:	6a 00                	push   $0x0
  803138:	e8 2c e4 ff ff       	call   801569 <sys_page_alloc>
  80313d:	89 c3                	mov    %eax,%ebx
  80313f:	83 c4 10             	add    $0x10,%esp
  803142:	85 c0                	test   %eax,%eax
  803144:	0f 88 89 00 00 00    	js     8031d3 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80314a:	83 ec 0c             	sub    $0xc,%esp
  80314d:	ff 75 f0             	pushl  -0x10(%ebp)
  803150:	e8 31 ea ff ff       	call   801b86 <fd2data>
  803155:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80315c:	50                   	push   %eax
  80315d:	6a 00                	push   $0x0
  80315f:	56                   	push   %esi
  803160:	6a 00                	push   $0x0
  803162:	e8 45 e4 ff ff       	call   8015ac <sys_page_map>
  803167:	89 c3                	mov    %eax,%ebx
  803169:	83 c4 20             	add    $0x20,%esp
  80316c:	85 c0                	test   %eax,%eax
  80316e:	78 55                	js     8031c5 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  803170:	8b 15 58 40 80 00    	mov    0x804058,%edx
  803176:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803179:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80317b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80317e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  803185:	8b 15 58 40 80 00    	mov    0x804058,%edx
  80318b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80318e:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  803190:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803193:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80319a:	83 ec 0c             	sub    $0xc,%esp
  80319d:	ff 75 f4             	pushl  -0xc(%ebp)
  8031a0:	e8 d1 e9 ff ff       	call   801b76 <fd2num>
  8031a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8031a8:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8031aa:	83 c4 04             	add    $0x4,%esp
  8031ad:	ff 75 f0             	pushl  -0x10(%ebp)
  8031b0:	e8 c1 e9 ff ff       	call   801b76 <fd2num>
  8031b5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8031b8:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8031bb:	83 c4 10             	add    $0x10,%esp
  8031be:	ba 00 00 00 00       	mov    $0x0,%edx
  8031c3:	eb 30                	jmp    8031f5 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8031c5:	83 ec 08             	sub    $0x8,%esp
  8031c8:	56                   	push   %esi
  8031c9:	6a 00                	push   $0x0
  8031cb:	e8 1e e4 ff ff       	call   8015ee <sys_page_unmap>
  8031d0:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8031d3:	83 ec 08             	sub    $0x8,%esp
  8031d6:	ff 75 f0             	pushl  -0x10(%ebp)
  8031d9:	6a 00                	push   $0x0
  8031db:	e8 0e e4 ff ff       	call   8015ee <sys_page_unmap>
  8031e0:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8031e3:	83 ec 08             	sub    $0x8,%esp
  8031e6:	ff 75 f4             	pushl  -0xc(%ebp)
  8031e9:	6a 00                	push   $0x0
  8031eb:	e8 fe e3 ff ff       	call   8015ee <sys_page_unmap>
  8031f0:	83 c4 10             	add    $0x10,%esp
  8031f3:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8031f5:	89 d0                	mov    %edx,%eax
  8031f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8031fa:	5b                   	pop    %ebx
  8031fb:	5e                   	pop    %esi
  8031fc:	5d                   	pop    %ebp
  8031fd:	c3                   	ret    

008031fe <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8031fe:	55                   	push   %ebp
  8031ff:	89 e5                	mov    %esp,%ebp
  803201:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  803204:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803207:	50                   	push   %eax
  803208:	ff 75 08             	pushl  0x8(%ebp)
  80320b:	e8 dc e9 ff ff       	call   801bec <fd_lookup>
  803210:	83 c4 10             	add    $0x10,%esp
  803213:	85 c0                	test   %eax,%eax
  803215:	78 18                	js     80322f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  803217:	83 ec 0c             	sub    $0xc,%esp
  80321a:	ff 75 f4             	pushl  -0xc(%ebp)
  80321d:	e8 64 e9 ff ff       	call   801b86 <fd2data>
	return _pipeisclosed(fd, p);
  803222:	89 c2                	mov    %eax,%edx
  803224:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803227:	e8 21 fd ff ff       	call   802f4d <_pipeisclosed>
  80322c:	83 c4 10             	add    $0x10,%esp
}
  80322f:	c9                   	leave  
  803230:	c3                   	ret    

00803231 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  803231:	55                   	push   %ebp
  803232:	89 e5                	mov    %esp,%ebp
  803234:	56                   	push   %esi
  803235:	53                   	push   %ebx
  803236:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  803239:	85 f6                	test   %esi,%esi
  80323b:	75 16                	jne    803253 <wait+0x22>
  80323d:	68 54 3e 80 00       	push   $0x803e54
  803242:	68 06 38 80 00       	push   $0x803806
  803247:	6a 09                	push   $0x9
  803249:	68 5f 3e 80 00       	push   $0x803e5f
  80324e:	e8 c2 d7 ff ff       	call   800a15 <_panic>
	e = &envs[ENVX(envid)];
  803253:	89 f3                	mov    %esi,%ebx
  803255:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80325b:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  80325e:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  803264:	eb 05                	jmp    80326b <wait+0x3a>
		sys_yield();
  803266:	e8 df e2 ff ff       	call   80154a <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80326b:	8b 43 48             	mov    0x48(%ebx),%eax
  80326e:	39 c6                	cmp    %eax,%esi
  803270:	75 07                	jne    803279 <wait+0x48>
  803272:	8b 43 54             	mov    0x54(%ebx),%eax
  803275:	85 c0                	test   %eax,%eax
  803277:	75 ed                	jne    803266 <wait+0x35>
		sys_yield();
}
  803279:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80327c:	5b                   	pop    %ebx
  80327d:	5e                   	pop    %esi
  80327e:	5d                   	pop    %ebp
  80327f:	c3                   	ret    

00803280 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  803280:	55                   	push   %ebp
  803281:	89 e5                	mov    %esp,%ebp
  803283:	53                   	push   %ebx
  803284:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  803287:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  80328e:	75 28                	jne    8032b8 <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  803290:	e8 96 e2 ff ff       	call   80152b <sys_getenvid>
  803295:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_U | PTE_W);
  803297:	83 ec 04             	sub    $0x4,%esp
  80329a:	6a 06                	push   $0x6
  80329c:	68 00 f0 bf ee       	push   $0xeebff000
  8032a1:	50                   	push   %eax
  8032a2:	e8 c2 e2 ff ff       	call   801569 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  8032a7:	83 c4 08             	add    $0x8,%esp
  8032aa:	68 c5 32 80 00       	push   $0x8032c5
  8032af:	53                   	push   %ebx
  8032b0:	e8 ff e3 ff ff       	call   8016b4 <sys_env_set_pgfault_upcall>
  8032b5:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8032b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8032bb:	a3 00 80 80 00       	mov    %eax,0x808000
}
  8032c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8032c3:	c9                   	leave  
  8032c4:	c3                   	ret    

008032c5 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8032c5:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8032c6:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  8032cb:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8032cd:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	# My method is different. Copy the values to the other stack
	# in a convinient way, and then pop everything.
	movl %esp, %ebp		# ebp refers to the exception stack
  8032d0:	89 e5                	mov    %esp,%ebp
	movl 48(%ebp), %esp 	# go to other stack
  8032d2:	8b 65 30             	mov    0x30(%ebp),%esp

	pushl 40(%ebp)		# eip - ORDER SWITCHED WITH EFLAGS
  8032d5:	ff 75 28             	pushl  0x28(%ebp)
	pushl 44(%ebp)      	# eflags
  8032d8:	ff 75 2c             	pushl  0x2c(%ebp)
	pushl 36(%ebp)		# all the 8 remaining regs
  8032db:	ff 75 24             	pushl  0x24(%ebp)
	pushl 32(%ebp)
  8032de:	ff 75 20             	pushl  0x20(%ebp)
	pushl 28(%ebp)
  8032e1:	ff 75 1c             	pushl  0x1c(%ebp)
	pushl 24(%ebp)
  8032e4:	ff 75 18             	pushl  0x18(%ebp)
	pushl 20(%ebp)
  8032e7:	ff 75 14             	pushl  0x14(%ebp)
	pushl 16(%ebp)
  8032ea:	ff 75 10             	pushl  0x10(%ebp)
	pushl 12(%ebp)
  8032ed:	ff 75 0c             	pushl  0xc(%ebp)
	pushl 8(%ebp)
  8032f0:	ff 75 08             	pushl  0x8(%ebp)

	popal			# now just pop everything!
  8032f3:	61                   	popa   
	popfl
  8032f4:	9d                   	popf   
	ret
  8032f5:	c3                   	ret    

008032f6 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8032f6:	55                   	push   %ebp
  8032f7:	89 e5                	mov    %esp,%ebp
  8032f9:	56                   	push   %esi
  8032fa:	53                   	push   %ebx
  8032fb:	8b 75 08             	mov    0x8(%ebp),%esi
  8032fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  803301:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  803304:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  803306:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  80330b:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  80330e:	83 ec 0c             	sub    $0xc,%esp
  803311:	50                   	push   %eax
  803312:	e8 02 e4 ff ff       	call   801719 <sys_ipc_recv>

	if (r < 0) {
  803317:	83 c4 10             	add    $0x10,%esp
  80331a:	85 c0                	test   %eax,%eax
  80331c:	79 16                	jns    803334 <ipc_recv+0x3e>
		if (from_env_store)
  80331e:	85 f6                	test   %esi,%esi
  803320:	74 06                	je     803328 <ipc_recv+0x32>
			*from_env_store = 0;
  803322:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  803328:	85 db                	test   %ebx,%ebx
  80332a:	74 2c                	je     803358 <ipc_recv+0x62>
			*perm_store = 0;
  80332c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  803332:	eb 24                	jmp    803358 <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  803334:	85 f6                	test   %esi,%esi
  803336:	74 0a                	je     803342 <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  803338:	a1 28 54 80 00       	mov    0x805428,%eax
  80333d:	8b 40 74             	mov    0x74(%eax),%eax
  803340:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  803342:	85 db                	test   %ebx,%ebx
  803344:	74 0a                	je     803350 <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  803346:	a1 28 54 80 00       	mov    0x805428,%eax
  80334b:	8b 40 78             	mov    0x78(%eax),%eax
  80334e:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  803350:	a1 28 54 80 00       	mov    0x805428,%eax
  803355:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  803358:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80335b:	5b                   	pop    %ebx
  80335c:	5e                   	pop    %esi
  80335d:	5d                   	pop    %ebp
  80335e:	c3                   	ret    

0080335f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80335f:	55                   	push   %ebp
  803360:	89 e5                	mov    %esp,%ebp
  803362:	57                   	push   %edi
  803363:	56                   	push   %esi
  803364:	53                   	push   %ebx
  803365:	83 ec 0c             	sub    $0xc,%esp
  803368:	8b 7d 08             	mov    0x8(%ebp),%edi
  80336b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80336e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  803371:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  803373:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  803378:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  80337b:	ff 75 14             	pushl  0x14(%ebp)
  80337e:	53                   	push   %ebx
  80337f:	56                   	push   %esi
  803380:	57                   	push   %edi
  803381:	e8 70 e3 ff ff       	call   8016f6 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  803386:	83 c4 10             	add    $0x10,%esp
  803389:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80338c:	75 07                	jne    803395 <ipc_send+0x36>
			sys_yield();
  80338e:	e8 b7 e1 ff ff       	call   80154a <sys_yield>
  803393:	eb e6                	jmp    80337b <ipc_send+0x1c>
		} else if (r < 0) {
  803395:	85 c0                	test   %eax,%eax
  803397:	79 12                	jns    8033ab <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  803399:	50                   	push   %eax
  80339a:	68 6a 3e 80 00       	push   $0x803e6a
  80339f:	6a 51                	push   $0x51
  8033a1:	68 77 3e 80 00       	push   $0x803e77
  8033a6:	e8 6a d6 ff ff       	call   800a15 <_panic>
		}
	}
}
  8033ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8033ae:	5b                   	pop    %ebx
  8033af:	5e                   	pop    %esi
  8033b0:	5f                   	pop    %edi
  8033b1:	5d                   	pop    %ebp
  8033b2:	c3                   	ret    

008033b3 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8033b3:	55                   	push   %ebp
  8033b4:	89 e5                	mov    %esp,%ebp
  8033b6:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8033b9:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8033be:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8033c1:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8033c7:	8b 52 50             	mov    0x50(%edx),%edx
  8033ca:	39 ca                	cmp    %ecx,%edx
  8033cc:	75 0d                	jne    8033db <ipc_find_env+0x28>
			return envs[i].env_id;
  8033ce:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8033d1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8033d6:	8b 40 48             	mov    0x48(%eax),%eax
  8033d9:	eb 0f                	jmp    8033ea <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8033db:	83 c0 01             	add    $0x1,%eax
  8033de:	3d 00 04 00 00       	cmp    $0x400,%eax
  8033e3:	75 d9                	jne    8033be <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8033e5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8033ea:	5d                   	pop    %ebp
  8033eb:	c3                   	ret    

008033ec <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8033ec:	55                   	push   %ebp
  8033ed:	89 e5                	mov    %esp,%ebp
  8033ef:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8033f2:	89 d0                	mov    %edx,%eax
  8033f4:	c1 e8 16             	shr    $0x16,%eax
  8033f7:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8033fe:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  803403:	f6 c1 01             	test   $0x1,%cl
  803406:	74 1d                	je     803425 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  803408:	c1 ea 0c             	shr    $0xc,%edx
  80340b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  803412:	f6 c2 01             	test   $0x1,%dl
  803415:	74 0e                	je     803425 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  803417:	c1 ea 0c             	shr    $0xc,%edx
  80341a:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  803421:	ef 
  803422:	0f b7 c0             	movzwl %ax,%eax
}
  803425:	5d                   	pop    %ebp
  803426:	c3                   	ret    
  803427:	66 90                	xchg   %ax,%ax
  803429:	66 90                	xchg   %ax,%ax
  80342b:	66 90                	xchg   %ax,%ax
  80342d:	66 90                	xchg   %ax,%ax
  80342f:	90                   	nop

00803430 <__udivdi3>:
  803430:	55                   	push   %ebp
  803431:	57                   	push   %edi
  803432:	56                   	push   %esi
  803433:	53                   	push   %ebx
  803434:	83 ec 1c             	sub    $0x1c,%esp
  803437:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80343b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80343f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  803443:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803447:	85 f6                	test   %esi,%esi
  803449:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80344d:	89 ca                	mov    %ecx,%edx
  80344f:	89 f8                	mov    %edi,%eax
  803451:	75 3d                	jne    803490 <__udivdi3+0x60>
  803453:	39 cf                	cmp    %ecx,%edi
  803455:	0f 87 c5 00 00 00    	ja     803520 <__udivdi3+0xf0>
  80345b:	85 ff                	test   %edi,%edi
  80345d:	89 fd                	mov    %edi,%ebp
  80345f:	75 0b                	jne    80346c <__udivdi3+0x3c>
  803461:	b8 01 00 00 00       	mov    $0x1,%eax
  803466:	31 d2                	xor    %edx,%edx
  803468:	f7 f7                	div    %edi
  80346a:	89 c5                	mov    %eax,%ebp
  80346c:	89 c8                	mov    %ecx,%eax
  80346e:	31 d2                	xor    %edx,%edx
  803470:	f7 f5                	div    %ebp
  803472:	89 c1                	mov    %eax,%ecx
  803474:	89 d8                	mov    %ebx,%eax
  803476:	89 cf                	mov    %ecx,%edi
  803478:	f7 f5                	div    %ebp
  80347a:	89 c3                	mov    %eax,%ebx
  80347c:	89 d8                	mov    %ebx,%eax
  80347e:	89 fa                	mov    %edi,%edx
  803480:	83 c4 1c             	add    $0x1c,%esp
  803483:	5b                   	pop    %ebx
  803484:	5e                   	pop    %esi
  803485:	5f                   	pop    %edi
  803486:	5d                   	pop    %ebp
  803487:	c3                   	ret    
  803488:	90                   	nop
  803489:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803490:	39 ce                	cmp    %ecx,%esi
  803492:	77 74                	ja     803508 <__udivdi3+0xd8>
  803494:	0f bd fe             	bsr    %esi,%edi
  803497:	83 f7 1f             	xor    $0x1f,%edi
  80349a:	0f 84 98 00 00 00    	je     803538 <__udivdi3+0x108>
  8034a0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8034a5:	89 f9                	mov    %edi,%ecx
  8034a7:	89 c5                	mov    %eax,%ebp
  8034a9:	29 fb                	sub    %edi,%ebx
  8034ab:	d3 e6                	shl    %cl,%esi
  8034ad:	89 d9                	mov    %ebx,%ecx
  8034af:	d3 ed                	shr    %cl,%ebp
  8034b1:	89 f9                	mov    %edi,%ecx
  8034b3:	d3 e0                	shl    %cl,%eax
  8034b5:	09 ee                	or     %ebp,%esi
  8034b7:	89 d9                	mov    %ebx,%ecx
  8034b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8034bd:	89 d5                	mov    %edx,%ebp
  8034bf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8034c3:	d3 ed                	shr    %cl,%ebp
  8034c5:	89 f9                	mov    %edi,%ecx
  8034c7:	d3 e2                	shl    %cl,%edx
  8034c9:	89 d9                	mov    %ebx,%ecx
  8034cb:	d3 e8                	shr    %cl,%eax
  8034cd:	09 c2                	or     %eax,%edx
  8034cf:	89 d0                	mov    %edx,%eax
  8034d1:	89 ea                	mov    %ebp,%edx
  8034d3:	f7 f6                	div    %esi
  8034d5:	89 d5                	mov    %edx,%ebp
  8034d7:	89 c3                	mov    %eax,%ebx
  8034d9:	f7 64 24 0c          	mull   0xc(%esp)
  8034dd:	39 d5                	cmp    %edx,%ebp
  8034df:	72 10                	jb     8034f1 <__udivdi3+0xc1>
  8034e1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8034e5:	89 f9                	mov    %edi,%ecx
  8034e7:	d3 e6                	shl    %cl,%esi
  8034e9:	39 c6                	cmp    %eax,%esi
  8034eb:	73 07                	jae    8034f4 <__udivdi3+0xc4>
  8034ed:	39 d5                	cmp    %edx,%ebp
  8034ef:	75 03                	jne    8034f4 <__udivdi3+0xc4>
  8034f1:	83 eb 01             	sub    $0x1,%ebx
  8034f4:	31 ff                	xor    %edi,%edi
  8034f6:	89 d8                	mov    %ebx,%eax
  8034f8:	89 fa                	mov    %edi,%edx
  8034fa:	83 c4 1c             	add    $0x1c,%esp
  8034fd:	5b                   	pop    %ebx
  8034fe:	5e                   	pop    %esi
  8034ff:	5f                   	pop    %edi
  803500:	5d                   	pop    %ebp
  803501:	c3                   	ret    
  803502:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803508:	31 ff                	xor    %edi,%edi
  80350a:	31 db                	xor    %ebx,%ebx
  80350c:	89 d8                	mov    %ebx,%eax
  80350e:	89 fa                	mov    %edi,%edx
  803510:	83 c4 1c             	add    $0x1c,%esp
  803513:	5b                   	pop    %ebx
  803514:	5e                   	pop    %esi
  803515:	5f                   	pop    %edi
  803516:	5d                   	pop    %ebp
  803517:	c3                   	ret    
  803518:	90                   	nop
  803519:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803520:	89 d8                	mov    %ebx,%eax
  803522:	f7 f7                	div    %edi
  803524:	31 ff                	xor    %edi,%edi
  803526:	89 c3                	mov    %eax,%ebx
  803528:	89 d8                	mov    %ebx,%eax
  80352a:	89 fa                	mov    %edi,%edx
  80352c:	83 c4 1c             	add    $0x1c,%esp
  80352f:	5b                   	pop    %ebx
  803530:	5e                   	pop    %esi
  803531:	5f                   	pop    %edi
  803532:	5d                   	pop    %ebp
  803533:	c3                   	ret    
  803534:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803538:	39 ce                	cmp    %ecx,%esi
  80353a:	72 0c                	jb     803548 <__udivdi3+0x118>
  80353c:	31 db                	xor    %ebx,%ebx
  80353e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  803542:	0f 87 34 ff ff ff    	ja     80347c <__udivdi3+0x4c>
  803548:	bb 01 00 00 00       	mov    $0x1,%ebx
  80354d:	e9 2a ff ff ff       	jmp    80347c <__udivdi3+0x4c>
  803552:	66 90                	xchg   %ax,%ax
  803554:	66 90                	xchg   %ax,%ax
  803556:	66 90                	xchg   %ax,%ax
  803558:	66 90                	xchg   %ax,%ax
  80355a:	66 90                	xchg   %ax,%ax
  80355c:	66 90                	xchg   %ax,%ax
  80355e:	66 90                	xchg   %ax,%ax

00803560 <__umoddi3>:
  803560:	55                   	push   %ebp
  803561:	57                   	push   %edi
  803562:	56                   	push   %esi
  803563:	53                   	push   %ebx
  803564:	83 ec 1c             	sub    $0x1c,%esp
  803567:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80356b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80356f:	8b 74 24 34          	mov    0x34(%esp),%esi
  803573:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803577:	85 d2                	test   %edx,%edx
  803579:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80357d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803581:	89 f3                	mov    %esi,%ebx
  803583:	89 3c 24             	mov    %edi,(%esp)
  803586:	89 74 24 04          	mov    %esi,0x4(%esp)
  80358a:	75 1c                	jne    8035a8 <__umoddi3+0x48>
  80358c:	39 f7                	cmp    %esi,%edi
  80358e:	76 50                	jbe    8035e0 <__umoddi3+0x80>
  803590:	89 c8                	mov    %ecx,%eax
  803592:	89 f2                	mov    %esi,%edx
  803594:	f7 f7                	div    %edi
  803596:	89 d0                	mov    %edx,%eax
  803598:	31 d2                	xor    %edx,%edx
  80359a:	83 c4 1c             	add    $0x1c,%esp
  80359d:	5b                   	pop    %ebx
  80359e:	5e                   	pop    %esi
  80359f:	5f                   	pop    %edi
  8035a0:	5d                   	pop    %ebp
  8035a1:	c3                   	ret    
  8035a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8035a8:	39 f2                	cmp    %esi,%edx
  8035aa:	89 d0                	mov    %edx,%eax
  8035ac:	77 52                	ja     803600 <__umoddi3+0xa0>
  8035ae:	0f bd ea             	bsr    %edx,%ebp
  8035b1:	83 f5 1f             	xor    $0x1f,%ebp
  8035b4:	75 5a                	jne    803610 <__umoddi3+0xb0>
  8035b6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8035ba:	0f 82 e0 00 00 00    	jb     8036a0 <__umoddi3+0x140>
  8035c0:	39 0c 24             	cmp    %ecx,(%esp)
  8035c3:	0f 86 d7 00 00 00    	jbe    8036a0 <__umoddi3+0x140>
  8035c9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8035cd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8035d1:	83 c4 1c             	add    $0x1c,%esp
  8035d4:	5b                   	pop    %ebx
  8035d5:	5e                   	pop    %esi
  8035d6:	5f                   	pop    %edi
  8035d7:	5d                   	pop    %ebp
  8035d8:	c3                   	ret    
  8035d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8035e0:	85 ff                	test   %edi,%edi
  8035e2:	89 fd                	mov    %edi,%ebp
  8035e4:	75 0b                	jne    8035f1 <__umoddi3+0x91>
  8035e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8035eb:	31 d2                	xor    %edx,%edx
  8035ed:	f7 f7                	div    %edi
  8035ef:	89 c5                	mov    %eax,%ebp
  8035f1:	89 f0                	mov    %esi,%eax
  8035f3:	31 d2                	xor    %edx,%edx
  8035f5:	f7 f5                	div    %ebp
  8035f7:	89 c8                	mov    %ecx,%eax
  8035f9:	f7 f5                	div    %ebp
  8035fb:	89 d0                	mov    %edx,%eax
  8035fd:	eb 99                	jmp    803598 <__umoddi3+0x38>
  8035ff:	90                   	nop
  803600:	89 c8                	mov    %ecx,%eax
  803602:	89 f2                	mov    %esi,%edx
  803604:	83 c4 1c             	add    $0x1c,%esp
  803607:	5b                   	pop    %ebx
  803608:	5e                   	pop    %esi
  803609:	5f                   	pop    %edi
  80360a:	5d                   	pop    %ebp
  80360b:	c3                   	ret    
  80360c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803610:	8b 34 24             	mov    (%esp),%esi
  803613:	bf 20 00 00 00       	mov    $0x20,%edi
  803618:	89 e9                	mov    %ebp,%ecx
  80361a:	29 ef                	sub    %ebp,%edi
  80361c:	d3 e0                	shl    %cl,%eax
  80361e:	89 f9                	mov    %edi,%ecx
  803620:	89 f2                	mov    %esi,%edx
  803622:	d3 ea                	shr    %cl,%edx
  803624:	89 e9                	mov    %ebp,%ecx
  803626:	09 c2                	or     %eax,%edx
  803628:	89 d8                	mov    %ebx,%eax
  80362a:	89 14 24             	mov    %edx,(%esp)
  80362d:	89 f2                	mov    %esi,%edx
  80362f:	d3 e2                	shl    %cl,%edx
  803631:	89 f9                	mov    %edi,%ecx
  803633:	89 54 24 04          	mov    %edx,0x4(%esp)
  803637:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80363b:	d3 e8                	shr    %cl,%eax
  80363d:	89 e9                	mov    %ebp,%ecx
  80363f:	89 c6                	mov    %eax,%esi
  803641:	d3 e3                	shl    %cl,%ebx
  803643:	89 f9                	mov    %edi,%ecx
  803645:	89 d0                	mov    %edx,%eax
  803647:	d3 e8                	shr    %cl,%eax
  803649:	89 e9                	mov    %ebp,%ecx
  80364b:	09 d8                	or     %ebx,%eax
  80364d:	89 d3                	mov    %edx,%ebx
  80364f:	89 f2                	mov    %esi,%edx
  803651:	f7 34 24             	divl   (%esp)
  803654:	89 d6                	mov    %edx,%esi
  803656:	d3 e3                	shl    %cl,%ebx
  803658:	f7 64 24 04          	mull   0x4(%esp)
  80365c:	39 d6                	cmp    %edx,%esi
  80365e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  803662:	89 d1                	mov    %edx,%ecx
  803664:	89 c3                	mov    %eax,%ebx
  803666:	72 08                	jb     803670 <__umoddi3+0x110>
  803668:	75 11                	jne    80367b <__umoddi3+0x11b>
  80366a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80366e:	73 0b                	jae    80367b <__umoddi3+0x11b>
  803670:	2b 44 24 04          	sub    0x4(%esp),%eax
  803674:	1b 14 24             	sbb    (%esp),%edx
  803677:	89 d1                	mov    %edx,%ecx
  803679:	89 c3                	mov    %eax,%ebx
  80367b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80367f:	29 da                	sub    %ebx,%edx
  803681:	19 ce                	sbb    %ecx,%esi
  803683:	89 f9                	mov    %edi,%ecx
  803685:	89 f0                	mov    %esi,%eax
  803687:	d3 e0                	shl    %cl,%eax
  803689:	89 e9                	mov    %ebp,%ecx
  80368b:	d3 ea                	shr    %cl,%edx
  80368d:	89 e9                	mov    %ebp,%ecx
  80368f:	d3 ee                	shr    %cl,%esi
  803691:	09 d0                	or     %edx,%eax
  803693:	89 f2                	mov    %esi,%edx
  803695:	83 c4 1c             	add    $0x1c,%esp
  803698:	5b                   	pop    %ebx
  803699:	5e                   	pop    %esi
  80369a:	5f                   	pop    %edi
  80369b:	5d                   	pop    %ebp
  80369c:	c3                   	ret    
  80369d:	8d 76 00             	lea    0x0(%esi),%esi
  8036a0:	29 f9                	sub    %edi,%ecx
  8036a2:	19 d6                	sbb    %edx,%esi
  8036a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8036a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8036ac:	e9 18 ff ff ff       	jmp    8035c9 <__umoddi3+0x69>
